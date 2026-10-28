# Kit local CI: the quality battery on the Mac, reported to GitHub — Design

**Story:** `docs/superpowers/stories/2026-10-28-kit-local-ci-story.md` (risk standard, security standard,
battery+check, checkpoints none; amended 2026-10-28 09:41: both paths stay open). **Date:** 2026-10-28.
**Plugin version:** 0.47.0 (the gate-rules template and `process-pr-review` change, §5). **Gate A:** runs — risk
standard; security standard; evidence battery+check (security not `none`; `strict`: two passes, full then verify).

## 1. Intent

Daniel's decisions: the GitHub Actions budget is used up, so the battery must be runnable on the Mac and reported to
GitHub (D63, 2026-10-28 09:18); and both paths stay open (09:41): the Actions job stays the default with its
triggers, and the local run is the opt-in for when the budget is used up or Daniel chooses local up front. Whether
Actions still run here is Daniel's call from the budget; the run for this pull request's first push did start and
pass (§8). One script runs the quality command from `AGENTS.md § Commands` on one commit, in a clean checkout, and
posts the result to GitHub as the commit status `quality`, the context the ruleset `protect-main.` (id 19168350)
requires on `main`. Once Daniel lets the ruleset accept the check from any source (§8, outside the repository),
either producer satisfies it: a pull request merges on a locally produced green, and the merge commit on `main` gets
its own status from the same script. The local path is switched on by disabling the workflow on GitHub and off by
enabling it again (§4), so one producer reports per commit. The repository's instructions read correctly for a
check that a local run reports.

**Non-goals:** switching the Actions job off or to manual start in the file (Daniel 09:41 keeps both paths); a
self-hosted runner (public repository: a fork's pull request could run code on the Mac); a GitHub App or bot identity
for the status; a `pending` status while the battery runs; a `target_url` (a local run has no public log); a lock
against parallel heavy runs (`todos.md` already carries that row); running any other project's battery; changing the
ruleset or the workflow's enabled state from inside the script; `/workflow-init` templates beyond the byte-identical
gate-rules mirror that check 4j forces; the kit's docs for other projects (`docs/setup.md` step 8,
`docs/getting-started.md`, `docs/coding-workflow.md`), which describe a project with a running CI; bounded
cancellation of a running battery (D-19).

**Anti-goals:** a `success` status for content that never ran (uncommitted edits, another SHA, another repository, a
skipped stage); a status from a shellcheck version other than the one CI pins; a secret, token, environment value or
home-directory path in the status; a temporary worktree left behind without the user being told; a post that fails
without the user seeing it; a run of an unread commit's code on the Mac; a CI job that checks less than the battery;
an instruction that still demands a CI run where the check came from the local run.

## 2. The script `scripts/local-ci.sh` (story AC-1–AC-4)

**Usage:** `sh scripts/local-ci.sh [<commit>]` from the repository root (the path is relative; from another directory
inside the repository give the script's path). The repository checked is the one containing the current directory.
`<commit>` is any commit-ish; default `HEAD`. Any other argument is a usage error (exit 64).

**Environment.** Before its first git call the script unsets every repository-selecting git variable: `GIT_DIR`,
`GIT_WORK_TREE`, `GIT_INDEX_FILE`, `GIT_COMMON_DIR`, `GIT_OBJECT_DIRECTORY`, `GIT_ALTERNATE_OBJECT_DIRECTORIES`,
`GIT_NAMESPACE`, `GIT_CEILING_DIRECTORIES`. An inherited `GIT_DIR` or `GIT_WORK_TREE` would otherwise override
`git -C` inside the temporary worktree and make the battery read, and possibly write, the caller's repository while the
status goes to the requested SHA (D-21).

**Preconditions, checked in this order before anything runs.** Each failure prints one line to stderr naming the
condition and what to do, exits 64, and posts nothing:

1. `<commit>` resolves to a commit (`git rev-parse --verify "<commit>^{commit}"`); the script works on the
   40-character SHA from then on.
2. The `origin` remote's URL names a repository on github.com, parsed with the same pattern
   `scripts/worktree-cleanup.sh` uses (`https://`, `ssh://git@` and `git@` forms, `.git` stripped). Owner and
   repository come from here only; `GH_REPO` and `GH_HOST` are not consulted (D-12).
3. `gh` is on `PATH` and `gh auth status --hostname github.com` exits 0.
4. **Shellcheck parity:** the version `.github/workflows/ci.yml` **of that commit** pins (every match of
   `koalaman/shellcheck:v<version>` in `git show <sha>:.github/workflows/ci.yml`, which must agree on exactly one
   version) equals the `version:` line of `shellcheck --version`. Reading the commit's file keeps one source for the
   pin (invariant 5: bump it in `ci.yml`, and this check follows).
5. **The quality row** of `AGENTS.md` **of that commit**: the lines of `git show <sha>:AGENTS.md` that start with
   `| quality ` and whose **last** cell is one command in backticks (the label cell may hold backticks of its own).
   Exactly one such line; its command text is taken verbatim. That text is already shell source in
   `AGENTS.md § Commands` (humans run it by copy and paste), so the script neither quotes nor rewrites it; the bound
   (AGENTS.md Don'ts, splicing) is the count of exactly one row and the source, a tracked file of the very commit being
   checked, which is the same trust as the scripts that command runs. The command runs under `sh -c` (D-2).

**Setup.** The script creates a temporary directory with `mktemp -d` and a detached worktree of the SHA inside it
(`git worktree add --detach`). A trap set before the worktree exists removes the worktree (`git worktree remove
--force` of that path only; no `git worktree prune`, which would touch other registrations, D-20) and the directory on
every exit, normal or by `HUP`, `INT` or `TERM`. A failure of `mktemp` or `git worktree add` exits 64 with the message;
nothing ran, nothing is posted.

**Run.** The quality command runs in that worktree as a foreground `sh -c`, with stdout and stderr passed through,
and the script records its exit status. The worktree shares the repository's refs, so the quality row's
`check-version-bump.sh origin/main` (D-17) compares against `origin/main` as of the last fetch; `git fetch origin`
before a local run keeps that ref current. Uncommitted changes in the caller's checkout never reach the run: the
worktree holds the SHA's content only (D-1). A `HUP`, `INT` or `TERM` to the script is handled after the quality
command returns: nothing forwards the signal, so the command runs through its remaining stages, then the trap removes
the worktree and the script exits without posting; Ctrl-C in a terminal reaches the whole foreground process group, so
the command stops at once; a signal that arrives after the post was sent cannot undo it; a hung stage delays the
cleanup until it ends (D-19).

**Post.** One call after the run:
`gh api --hostname github.com --method POST -H "X-GitHub-Api-Version: 2026-03-10" repos/<owner>/<repo>/statuses/<sha>
-f state=<state> -f context=quality -f description=<description>`, with `state` `success` when the quality command
exited 0 and `failure` otherwise, and the REST API version the Context7 lookup documents (D-15). The description is
fixed text plus two tool versions, for example `battery green: local run, shellcheck 0.11.0, claude 2.1.312`
(`unknown` where a tool cannot be asked); it carries no path, user name, host name, environment value or token
(D-6). No `target_url`, no `pending` (D-5). The script prints one line with the SHA, the state and the description it
posted. A SHA GitHub does not have (unpushed) fails the post with GitHub's 422, exit 75.

**Cleanup.** After the post, the trap removes the worktree and the directory. When the removal fails, the script
prints the path that remains and the command that removes it (`git worktree remove --force <path>`) to stderr; the
exit status stays what the run determined, because the result is already decided and, when posted, on GitHub.

**Exit status (D-4, D-18):** `0` when the battery passed and the status was posted; the battery's own non-zero
status when the battery failed and the `failure` status was posted; `75` when the battery ran but the post failed,
green or red, with a line naming the state it tried to post and the SHA, so the user can rerun after fixing `gh`;
`64` on a usage error, a precondition or a setup failure (nothing ran, nothing posted). The script never posts
`success` for a run it did not observe passing, and never posts for a SHA other than the one the worktree holds. A
battery stage that itself exits 64 or 75 would be indistinguishable from those outcomes by the exit status alone;
the printed line tells them apart, and no stage of the battery exits either (shellcheck uses 1–4).

**What it does not do:** fetch (run `git fetch origin` first, so `origin/main` is current for the version-bump check
and a merge commit can be named as `origin/main`); push; run on a commit you have not read (the battery is that
commit's code, and a fork's head runs on the Mac; §7); check the `claude` CLI version against the CI pin (§5 states
the difference; `todos.md` row); post `pending` or `error`; serialize parallel runs; enable or disable the workflow
(§4 says who does); interrupt a running stage (D-19).

## 3. The suite `scripts/local-ci.test.sh` (story AC-5)

Shape of `scripts/worktree-cleanup.test.sh`: `set -u`, `pass`/`fail` counters, a `mktemp -d` work directory removed
on exit, `LOCAL_CI_SH` selecting the shell the script runs under, stubs first in `PATH`, and a fixture repository per
group of cases. The fixture is a bare origin plus a clone whose `origin` URL is `https://github.com/acme/widgets.git`
(push URL the bare repository); it commits an `AGENTS.md` whose quality row is `| quality (fixture, \`x\`) | \`sh
./battery.sh\` |` (a backtick in the label, so the parser must take the last cell), a `.github/workflows/ci.yml` with
one `koalaman/shellcheck:v0.11.0` line, and `battery.sh`, which records its working directory and `git rev-parse HEAD`
into a file under the work directory and exits with a committed code. Stubs: `gh` (records its arguments and
environment; `auth status` exits per a file, `api` exits per another and prints a canned body), `shellcheck` (prints
`version: <file content>`), `claude` (prints a fixed version), and a `git` wrapper that fails `worktree add` or
`worktree remove` when a marker file exists and otherwise runs the real git. The suite runs no real battery and
reaches no network.

Cases, each asserting the exit status, the `gh` arguments and the worktree list afterwards:

1. green battery → `api` called with `--method POST`, the `X-GitHub-Api-Version: 2026-03-10` header,
   `repos/acme/widgets/statuses/<sha>`, `state=success`, `context=quality`; exit 0; `battery.sh` ran in a directory
   other than the clone, at the expected SHA; the temporary worktree is gone (`git worktree list` shows the clone only).
2. red battery (exit 1) → `state=failure`, exit 1. 3. battery exit 7 → exit 7; battery exit 2 → exit 2; exit 3 → 3.
4. green battery, `api` fails → exit 75, stderr names `success` and the SHA; red battery, `api` fails → exit 75,
   stderr names `failure`.
5. `gh` absent from `PATH` → exit 64, `battery.sh` never ran, nothing posted. 6. `gh auth status` fails → exit 64.
7. shellcheck `0.10.0` against a `0.11.0` pin → exit 64, nothing ran. 8. `ci.yml` pins two versions → exit 64.
9. quality row missing → exit 64; two quality rows → exit 64. A second argument → exit 64.
10. uncommitted edit: the committed `battery.sh` exits 0, the working copy is changed to exit 1 → the run is green
    (committed content only); an untracked file in the clone does not appear in the worktree.
11. an explicit older commit whose `battery.sh` exits 1 → `failure` posted to that SHA, `HEAD` unchanged.
12. `origin` not on github.com, and `origin` missing → exit 64. 13. SSH-form `origin` URL → the same `repos/acme/widgets`.
14. `GH_TOKEN=stubsecret`, `HOME` set to the work directory: neither string appears in the recorded `gh` arguments or
    the description.
15. `TERM` to the script while a two-stage `battery.sh` sleeps in its first stage → the second stage's marker exists
    (the command ran through), nothing posted, no worktree left.
16. `GH_REPO=evil/other GH_HOST=ghe.example.com` → the call still names `--hostname github.com` and `repos/acme/widgets`.
17. `GIT_DIR` and `GIT_WORK_TREE` pointing at a second repository with a different `HEAD` → the battery records the
    fixture's requested SHA, the second repository's `HEAD` and index are unchanged, and the status names that SHA.
18. `git worktree add` fails → exit 64, nothing ran, nothing posted, no directory left.
19. `git worktree remove` fails after a green run → exit 0, the status was posted, stderr names the remaining path and
    the removal command; an unrelated stale worktree registration (a worktree whose directory was deleted by hand)
    is still listed afterwards, so nothing was pruned.

The quality and lint rows of `AGENTS.md § Commands` gain `shellcheck --shell=sh scripts/local-ci.sh`, `shellcheck
--shell=sh --exclude=SC2015 scripts/local-ci.test.sh` and `sh scripts/local-ci.test.sh`; `ci.yml`'s lint and suite
steps gain the same lines (§4).

## 4. `ci.yml` and the switch between the paths (story AC-11)

The triggers (`pull_request`, `push` to `main`), the `concurrency` block, the job and its steps stay as they are. The
only edit: the lint step gains the two shellcheck lines and the suite step gains `sh scripts/local-ci.test.sh`, as
0.44.0 added them for `worktree-cleanup`, so the job checks what the battery checks (D-9). No `workflow_dispatch`
trigger is added (D-11).

**The switch (D-16).** GitHub's rules, read in its docs on 2026-10-28 (Context7 `/github/docs`, "Troubleshooting
required status checks" and "Disabling and enabling a workflow"): required checks may be check runs or commit
statuses; when a check run and a commit status carry the same required name, **both must pass**; a disabled workflow
does not respond to its triggers. So the local path is used with the workflow disabled, which costs nothing and
leaves one producer per commit: `gh workflow disable ci.yml` switches to local, `gh workflow enable ci.yml` switches
back; both are GitHub settings, not files, done by Daniel or a session with write access, never by the script. While
the workflow is enabled, a local status on a commit the job also checked is additive: both must be green, and a red
or pending run cannot be rescued by a local green. A commit checked before the switch keeps its check run. The docs
(§5) say this in three sentences: when to switch, the two commands, and the both-must-pass rule.

## 5. Instructions and docs (story AC-7, AC-8, AC-11)

- **CLAUDE.md §4 "Waiting on external work":** one added clause, after the paragraph's first sentence: a check this
  session produces itself — `sh scripts/local-ci.sh` runs the battery here and posts the `quality` status — is not
  external work; its result is the script's exit status, and one read of the status on that SHA (`gh api
  repos/<owner>/<repo>/commits/<sha>/status`) confirms the post. Nothing waits. The rule's conditions for a run outside
  the session, a CI run included, stay as they are (§6).
- **Gate rules** (`.claude/review-gates.md` and the `### 2.1a` template, byte-identical, check 4j): in the untouched-
  test sentence, `the PR head's required CI check` becomes `the PR head's required check` and `A red CI stops.`
  becomes `A red check stops.` The byte count stays at 9,998 of 10,000 (check 4i): the two edits cancel. The battery-
  evidence sentence (`local run, or pending PR CI under the timeout rule`) stays: a locally reported check is its
  first branch. The template changes with it, so the plugin version becomes 0.47.0 with a CHANGELOG entry (invariant
  12); the change is neutral for an initialized project with its own CI: a required check is a required check (D-7).
- **`plugins/dev-workflow/commands/process-pr-review.md`** (D-8), generic wording, every old condition kept (§6):
  Step 1 adds one sentence: a project whose battery runs locally and reports the check as a commit status
  (`AGENTS.md § Commands` names the reporter) shows it in `gh pr checks` too, and then there is no run to wait for.
  Step 3 item 6: "the CI quality check green on the final pushed head (`gh pr checks` after the run completes, within
  CLAUDE.md §4's limit for waiting on external work). CI is the enforced authority; the local run is the fast
  pre-check." becomes "the required quality check green on the final pushed head (`gh pr checks`): from CI once its
  run completes, within CLAUDE.md §4's limit for waiting on external work, or from the local reporter the project's
  `AGENTS.md § Commands` names, which posts the local run's result as that check. The required check is the enforced
  authority; a local run that is not reported is the fast pre-check."; in its two exceptions "the green CI check on
  the head stands in" and "the green CI check on the final head stands for the rest" become "the green required check
  on the head / on the final head" (with a local reporter, a rerun through it); the report shape's line reads
  `required check on final head  green — the authority (CI, or the local reporter's status)`. Step 4: "the required
  CI check is green on the head" becomes "the required check is green on the head", and "the head this run checked CI
  and claims on" becomes "the head this run checked and claims on". Done: "CI checks are green on the final head"
  becomes "the required check is green on the final head". Headings stay (no renamed section).
- **`AGENTS.md`:** Boundaries get item 4b: `scripts/local-ci.{sh,test.sh}` (reads the repository; creates and removes
  one temporary worktree under a `mktemp -d` directory; posts one commit status to GitHub; never fetches, pushes,
  prunes, changes a ruleset, a workflow's state, a branch or a remote). § Commands: the quality row's label reads
  "the whole battery — what CI runs, and what `scripts/local-ci.sh` runs on the Mac when the Actions budget is used
  up or local is chosen"; a new row `local CI (runs the quality row on one commit in a temporary worktree and posts it
  as the \`quality\` status; the opt-in path beside CI, used with the workflow disabled; needs a logged-in gh)` with
  `sh scripts/local-ci.sh [<commit>]`, written only after it was run and observed; the prerequisites paragraph adds
  that `scripts/local-ci.sh` refuses to run with a shellcheck other than the `ci.yml` pin and needs `gh` logged in
  (`gh` addressed by name, as before). The quality row and the `invariant check (12 version bump)` row run
  `sh scripts/check-version-bump.sh origin/main` instead of `main` (D-17), and the precondition paragraph says to
  `git fetch origin` first so that ref is current; the "CI runs the parts as separate steps" paragraph stays, with its
  version-bump sentence reading "with HEAD at `origin/main`, where the merge-base is HEAD, it passes trivially".
- **`README.md` § Contributing:** CI runs the battery; when the Actions budget is used up, or you choose local up
  front, disable the workflow and run `sh scripts/local-ci.sh` on the Mac, which posts the same required `quality`
  check; link to the reference.
- **`docs/ARCHITECTURE.md`:** tree lines for the two new files; the Components paragraph names the runner and its
  suite.
- **`docs/TECH-STACK.md`:** the shellcheck row adds that `local-ci.sh` requires the local version to equal the
  `ci.yml` pin; a `gh` row (addressed by name; `local-ci.sh` requires it, `worktree-cleanup.sh` uses it when present).
- **`docs/reference.md` § Contributing:** a paragraph on the two paths: when the local one is used and the switch
  (§4: disable, run per commit, enable), how (`git fetch origin` first; the merge commit as `origin/main`), that the
  ruleset accepts the `quality` check from either source after Daniel's change (§8), the both-must-pass rule, the
  local run's differences to the job (local shellcheck binary at the pinned version, the local `claude` CLI instead
  of the npm pin, macOS tools instead of ubuntu-24.04's `/bin/sh` and awk) and the consequence in §7; its two
  `required CI check` phrases in the review-gates section become `required check`, as in the rules.
- **`plugins/dev-workflow/CHANGELOG.md`** entry 0.47.0; `plugin.json` version 0.47.0.
- **`todos.md`**, new section "From kit 0.47.0 local CI (2026-10-28) — backlog only": `/workflow-init`'s scaffolded
  `ci.yml` template and `docs/setup.md` step 8 for a project that wants the local option (trigger: a second project
  loses Actions); the `claude` CLI version difference between the local run and the CI pin (trigger: `claude plugin
  validate` disagreeing between the two); bounded cancellation of a running battery (trigger: a run that had to be
  killed by hand).

Every changed prompt passes `docs/prompt-standards.md` (invariant 11). No `/workflow-init` template changes besides
`### 2.1a`.

## 6. Old conditions accounted for (story AC-8)

| Earlier condition | Fate |
|---|---|
| CLAUDE.md §4: confirm an external run exists for its trigger (id seen, status read) | kept, for every run outside the session, a CI run included |
| §4: queued, in progress or waiting → wait; finished → read its result | kept |
| §4: no run within 5 minutes, unreadable status, or the wait limit → a failed check, cause and times reported | kept |
| §4's "Why" (the 15-hour wait) | kept |
| — (none) | added: a check this session posts itself is not external work; exit status plus one status read |
| Gate rules: a timeout in an untouched test that passes alone is recorded with its evidence (load, solo run) | kept |
| Gate rules: "the PR head's required CI check is then the battery evidence, without a stop" | kept, widened: "required check"; a CI check as before, or the status `local-ci.sh` posts, which is green only after a green run of the script, so on the local path the exception means a rerun through the script, posted green |
| Gate rules: "A red CI stops." | kept, widened: "A red check stops." |
| Gate rules: battery evidence named to Codex as "local run, or pending PR CI under the timeout rule" | kept unchanged; a locally reported check is the first branch |
| `docs/reference.md`: the same two sentences restated | kept, widened the same way |
| `process-pr-review` Step 1: `gh pr checks`; the required quality check must be green; red → fix first; still running → note and re-verify at the end | kept; one sentence added for a locally reported check (no run to wait for) |
| `process-pr-review` Step 3 item 6: quality command green locally **and** the CI quality check green on the final pushed head, read with `gh pr checks` after the run completes within §4's limit; CI the authority, the local run the fast pre-check | kept for CI; widened: the required check may come from the local reporter; the authority is the required check; an unreported local run stays the pre-check |
| `process-pr-review` Step 3 item 6, exception 1 (untouched-test timeout → the green CI check on the head stands in) and exception 2 (docs-only paths since a named full run → stages rerun, the green CI check on the final head stands for the rest) | kept, widened to "required check" |
| `process-pr-review` Step 3 report shape: `CI on final head  green — the authority; the local run is the fast pre-check` | kept, reworded to the required check and its two producers |
| `process-pr-review` Step 4: required CI check green on the head; `mergeStateStatus` CLEAN; `headRefOid` equal to the head this run checked CI and claims on; a different head → Steps 1–3 again | kept, "required check" and "checked"; everything else unchanged |
| `process-pr-review` Done: CI checks green on the final head, `mergeStateStatus` CLEAN, squash-merged or ready | kept, "the required check" |
| AGENTS.md § Commands: the quality row is what CI runs | kept, extended: and what `local-ci.sh` runs on the Mac |
| AGENTS.md § Commands: `check-version-bump.sh main` is in the quality row because that row claims to be what CI runs; CI passes the PR's base ref; the precondition of a committed state and a current base ref | kept; the base becomes `origin/main` (D-17): in a lane layout the local `main` moves only when pulled in the main checkout and can lag behind a branch point, and a diff from a lagging merge-base can contain another commit's bump, which lets a missing bump pass; `origin/main` cannot lag behind a branch taken from it. The precondition now reads "committed, and fetched" |
| AGENTS.md § Commands: CI runs the parts as separate steps for readable failures; the chained form is the single command a human runs | kept unchanged |
| `docs/reference.md` § Contributing: CI runs four checks on every PR and push to main; a fifth on pull requests only | kept; the local path is added as the alternative that runs the whole battery, the version-bump check against `origin/main` included |
| `docs/reference.md` § Contributing: a PR with a green `quality` check is the only way into `main`, admins included, no bypass actors; the version-bump step runs inside that job | kept with its new meaning: the check comes from the job or from `local-ci.sh`, either source after §8; the consequence in §7 is stated |
| `ci.yml`: `pull_request` and `push` to `main` start the job; PR runs supersede each other; the version-bump step runs on `pull_request` | kept unchanged (Daniel 09:41); the enabled state on GitHub is the switch (§4) |
| `docs/setup.md` step 8, `docs/getting-started.md`, `docs/coding-workflow.md`: a project's CI runs the battery | kept unchanged: they describe other projects (non-goal) |

## 7. Security (security standard)

- The status is posted under the user's own `gh` login (token scopes include `repo`); the script never reads, prints or
  passes the token, and `gh` handles authentication.
- The description is fixed text and two tool versions. No path, user or host name, environment value or secret.
- After §8 the required check is satisfiable by any status named `quality` that a collaborator with write access
  posts, by this script or by hand, without a battery run; GitHub's docs say the author of each status can be checked
  by hand in the merge box. That is the guarantee D63 trades away, and `docs/reference.md` § Contributing says so in
  one sentence; the repository has one maintainer, and a mitigation (an App identity, a verified source) is a
  non-goal.
- The script runs the quality command of the commit it checks, which runs that commit's scripts: the same trust as
  running the battery by hand. The docs say: run it only on commits you have read; never on a fork's head, which is
  the reason there is no self-hosted runner. The script unsets the git environment variables that could redirect it
  to another repository (§2).
- The Actions job keeps running for a fork's pull request exactly as before; nothing here changes its permissions.

## 8. Outside the repository (Daniel; story AC-9)

The ruleset `protect-main.` (id 19168350) requires `quality` with `integration_id` 15368 (GitHub Actions), so a status
from this script does not satisfy it until the integration restriction is dropped. The plan lists this action with the
exact call: a `PUT` of the ruleset with its current body (read on 2026-10-28; `name`, `target`, `enforcement`,
`bypass_actors`, `conditions`, `rules`) and the required check reduced to `{"context":"quality"}`; the update endpoint
replaces `rules` as a whole, so the body carries all three rules. A read of the ruleset afterwards shows
`required_status_checks: [{"context":"quality"}]`, which the Actions job's check run and the script's status both
satisfy. The plan also lists the switch of §4 as the second action outside the repository, for the moment Daniel
chooses the local path. Nothing in the repository changes the ruleset or the workflow's state.

Observed for this pull request (#100, draft, opened 2026-10-28 08:51Z with the story and spec commits): GitHub
started Actions run 40659778216 for the `pull_request` event and it completed with conclusion `success` at 08:55:42Z
(4m29s); `gh pr checks 100` shows `quality` as `pass`. The PR body records this (AC-9). It means the PR head carries
an Actions check run named `quality`, so a local status on the same head is additive (both must pass, §4); the
local status is posted on the final head once the ruleset accepts it, and the merge commit gets one as well, beside
the check run the push to `main` produces while the workflow is enabled.

## 9. Acceptance evidence

| Story AC | Evidence |
|---|---|
| AC-1 | suite cases 1, 10, 11, 15, 17, 18; a real run on the PR head |
| AC-2 | suite case 1 (arguments, header), 13; `gh api repos/dsnger/dev-workflow-kit/commits/<sha>/status` on the PR head |
| AC-3 | suite cases 4, 5, 6, 11, 18 |
| AC-4 | suite cases 7, 8; §5 docs (`AGENTS.md` prerequisites, `docs/TECH-STACK.md`, `docs/reference.md`) |
| AC-5 | `shellcheck --shell=sh` on both files in the battery; `sh scripts/local-ci.test.sh` in the quality row; the suite's stubs (no network, no real battery) |
| AC-7 | the files of §5, each run or read; the `local CI` row written after an observed run |
| AC-8 | §6 table; checks 4i and 4j green; `process-pr-review` against `docs/prompt-standards.md` |
| AC-9 | the plan's "outside the repository" section with the `gh api` call and the switch; the PR body line on Actions (run 40659778216, success) |
| AC-10 | `plugin.json` 0.47.0 + CHANGELOG; battery green on the final head, its version-bump stage run as `check-version-bump.sh origin/main` and observed; `quality` status on the merge commit |
| AC-11 | `git diff` of `ci.yml`: the three parity lines only; README and `docs/reference.md` name both paths, the switch and the both-must-pass rule |

## 10. Decisions

- D-1 Always a temporary worktree, never a dirty-tree refusal: it makes "committed content only" structural, lets the
  script check `origin/main` after a merge without switching branches, and leaves the caller's checkout untouched.
- D-2 The quality command is read from the checked commit's `AGENTS.md` rather than copied into the script: one
  source (CLAUDE.md §4 "one source of green"), no third copy to drift; executing it is the same trust as the battery.
- D-3 The shellcheck pin is read from the checked commit's `ci.yml`, not hard-coded, for the same reason.
- D-4 Exit statuses 0 / battery's / 64 / 75 as in §2: "exit code follows the battery" (the brief) for every run that
  posted; a failed post and a failure before the run are distinct from the battery's codes (AC-3), which are 1–4 for
  the tools in it, so a chained command cannot mistake either for green or for red.
- D-5 No `target_url` and no `pending`: there is no log to link, and a `pending` left by a killed run would need an
  `error` path for no gain.
- D-6 The description names the result and the two tool versions that differ from CI (shellcheck, `claude`), nothing
  else, so the difference to CI is visible where the check is read.
- D-7 The gate rules change by two word swaps, mirrored into `### 2.1a` (check 4j), hence plugin 0.47.0. The
  alternative, leaving "required CI check" in this repository's rules, contradicts the brief.
- D-8 `process-pr-review` changes in generic words (§5): this repository runs the command, and its Step 3 item 6 and
  Step 4 demanded a CI result that the local path does not produce (Gate A pass 1). `gh pr checks` lists a commit
  status, so Step 1 needed one sentence only.
- D-9 `ci.yml` gains only the parity lines for the new lint and suite, as every new script's did; a job that checks
  less than the battery would make the quality row's "what CI runs" false.
- D-10 The builder check of `superpowers:brainstorming` ran once (one subagent) before Gate A; Gate A is the approval.
- D-11 No `workflow_dispatch` trigger: nobody asked for a by-hand start, and the job keeps its triggers (Daniel 09:41).
- D-12 Owner and repository from `origin`'s URL only, with `--hostname github.com`: the same choice as
  `worktree-cleanup.sh`, so `GH_REPO`/`GH_HOST` in a session's environment cannot redirect a post.
- D-13 The script and suite are repository tooling under `scripts/`, outside the plugin (Boundaries 5).
- D-14 A draft pull request was opened right after the spec commit and not waited on; the run that started and
  passed is recorded in the PR body (AC-9) and in §8.
- D-15 Context7 (`/websites/github_en_rest`, read 2026-10-28; its examples carry `X-GitHub-Api-Version:
  2026-03-10`, which GitHub confirmed as the most recent supported version beside `2022-11-28` on a probe the same
  day) is the source for the statuses `POST` fields (`state`, `context`, `description`, `target_url`) and the
  rulesets `PUT` body (`rules` required as a whole, `integration_id` optional per check); the script sends that
  version header explicitly, since `gh` 2.96.0 defaults to `2022-11-28`. `/github/docs` (same day) is the source for
  the required-check rules in §4.
- D-16 The switch between the paths is the workflow's enabled state on GitHub (§4), because GitHub counts a check run
  and a status of the same required name together; a file-level switch would contradict Daniel's 09:41 decision, and
  a `[skip ci]` commit message leaves the check pending (GitHub docs, "Handling skipped but required checks").
- D-17 The quality row's version-bump stage compares against `origin/main`, not the local `main` (builder check,
  2026-10-28): a local `main` behind the branch point lets a missing bump pass as green, and on the local path this
  script is the only producer of the required check. `origin/main` is what CI compares against too (`origin/<base>`).
  The script itself does not fetch (one less side effect on shared refs; the docs say to fetch first).
- D-18 The script's own codes are 64 and 75, outside the 1–4 the battery's tools use; the collision that remains (a
  stage exiting 64 or 75) is stated as a limit in §2 and in the script's header, with the printed line as the
  tie-breaker.
- D-19 A signal to the script does not interrupt the running command (Gate A pass 1 verified that a foreground
  `sh -c` runs its remaining stages first): forwarding it would need a background run plus `wait` and signal
  bookkeeping, which nobody asked for (a `todos.md` row); Ctrl-C in a terminal reaches the whole foreground process
  group anyway. §2 states the limits, including a post that was already sent.
- D-20 No `git worktree prune`: `git worktree remove --force` of the one path unregisters it, and a prune would touch
  other registrations, outside the boundary of §5 (Boundaries 4b); a failed removal is reported, not hidden.
- D-21 The script unsets the repository-selecting git variables rather than refusing when they are set: a session may
  carry `GIT_INDEX_FILE` from a hook, and the repository is defined by the current directory in every case.
