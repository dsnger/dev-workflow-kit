# Kit local CI: the quality battery on the Mac, reported to GitHub — Design

**Story:** `docs/superpowers/stories/2026-10-28-kit-local-ci-story.md` (risk standard, security standard,
battery+check, checkpoints none; amended 2026-10-28 09:41: both paths stay open). **Date:** 2026-10-28.
**Plugin version:** 0.47.0 (the gate-rules template changes, §5). **Gate A:** runs — risk standard; security
standard; evidence battery+check (security not `none`; `strict`: two passes, full then verify).

## 1. Intent

The GitHub Actions budget is used up and Actions do not run for this repository now (story §1 and its change
record). Daniel's decision (D63, then 09:41): both paths stay open. The Actions job stays the default and keeps its
triggers. Beside it, one script runs the quality command from `AGENTS.md § Commands` on one commit, in a clean
checkout, and posts the result to GitHub as the commit status `quality`, the context the ruleset `protect-main.`
(id 19168350) requires on `main`; it is the opt-in path for when the budget is used up or Daniel chooses local up
front. Once Daniel lets the ruleset accept the check from any source (§8, outside the repository), either path
satisfies it: a pull request merges on a locally produced green, and the merge commit on `main` gets its own status
from the same script. The repository's instructions read correctly for a check that a local run reports.

**Non-goals:** switching the Actions job off or to manual start (Daniel 09:41 keeps both paths); a self-hosted runner
(public repository: a fork's pull request could run code on the Mac); a GitHub App or bot identity for the status; a
`pending` status while the battery runs; a `target_url` (a local run has no public log); a lock against parallel
heavy runs (`todos.md` already carries that row); running any other project's battery; changing the ruleset from
inside the repository; `/workflow-init` templates beyond the byte-identical gate-rules mirror that check 4j forces;
`process-pr-review` (§5, D-8); the kit's docs for other projects (`docs/setup.md` step 8, `docs/getting-started.md`,
`docs/coding-workflow.md`), which describe a project with a running CI.

**Anti-goals:** a `success` status for content that never ran (uncommitted edits, another SHA, a skipped stage); a
status from a shellcheck version other than the one CI pins; a secret, token, environment value or home-directory path
in the status; a temporary worktree left behind; a post that fails without the user seeing it; a run of an unread
commit's code on the Mac; a CI job that checks less than the battery.

## 2. The script `scripts/local-ci.sh` (story AC-1–AC-4)

**Usage:** `sh scripts/local-ci.sh [<commit>]`, from any directory inside the repository (main checkout or a linked
worktree). `<commit>` is any commit-ish; default `HEAD`. No other options.

**Preconditions, checked in this order before anything runs.** Each failure prints one line to stderr naming the
condition and what to do, exits 2, and posts nothing:

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
   `| quality ` and whose last cell is one command in backticks. Exactly one such line; its command text is taken
   verbatim. That text is already shell source in `AGENTS.md § Commands` (humans run it by copy and paste), so the
   script neither quotes nor rewrites it; the bound (AGENTS.md Don'ts, splicing) is the count of exactly one row and the
   source, a tracked file of the very commit being checked, which is the same trust as the scripts that command runs.
   The command runs under `sh -c` (D-2).

**Run.** The script creates a temporary directory with `mktemp -d` and a detached worktree of the SHA inside it
(`git worktree add --detach`). A trap set before the worktree exists removes the worktree (`git worktree remove
--force`, then `git worktree prune`) and the directory on every exit, normal or by `HUP`, `INT` or `TERM`. The quality
command runs in that worktree with stdout and stderr passed through, and the script records its exit status. The
worktree shares the repository's refs, so the quality row's `check-version-bump.sh origin/main` (D-17) compares against
`origin/main` as of the last fetch; `git fetch origin` before a local run keeps that ref current. Uncommitted changes
in the caller's checkout never reach the run: the worktree holds the SHA's content only (D-1). A `TERM` or `INT` to the
script lets the running stage finish (the quality command is a foreground `sh -c`; nothing forwards the signal), then
the trap removes the worktree and the script exits without posting (D-19).

**Post.** One call after the run:
`gh api --hostname github.com --method POST repos/<owner>/<repo>/statuses/<sha> -f state=<state> -f context=quality
-f description=<description>`, with `state` `success` when the quality command exited 0 and `failure` otherwise. The
description is fixed text plus two tool versions, for example `battery green: local run, shellcheck 0.11.0, claude
2.1.312` (`unknown` where a tool cannot be asked); it carries no path, user name, host name, environment value or
token (D-6). No `target_url`, no `pending` (D-5). The script prints one line with the SHA, the state and the
description it posted.

**Exit status (D-4):** `0` when the battery passed and the status was posted; the battery's own non-zero status when
the battery failed (the `failure` status is posted first); `3` when the battery ran but the post failed, with a line
naming the state it tried to post and the SHA, so the user can rerun after fixing `gh`; `2` on a precondition above.
The script never posts `success` for a run it did not observe passing, and never posts for a SHA other than the one
the worktree holds. A battery stage that itself exits 3 is indistinguishable from a failed post by the exit status
alone; the printed line tells them apart, and no current stage exits 3 (D-18).

**What it does not do:** fetch (run `git fetch origin` first, so `origin/main` is current for the version-bump check
and a merge commit can be named as `origin/main`); push (a SHA GitHub does not have fails the post with 422, exit 3); run
on a commit you have not read (the battery is that commit's code, and a fork's head runs on the Mac; §7); check the
`claude` CLI version against the CI pin (§5 states the difference; `todos.md` row); post `pending` or `error`; serialize
parallel runs; decide which path a commit takes (§5 says when the local path is used).

## 3. The suite `scripts/local-ci.test.sh` (story AC-5)

Shape of `scripts/worktree-cleanup.test.sh`: `set -u`, `pass`/`fail` counters, a `mktemp -d` work directory removed
on exit, `LOCAL_CI_SH` selecting the shell the script runs under, stubs first in `PATH`, and a fixture repository per
group of cases. The fixture is a bare origin plus a clone whose `origin` URL is `https://github.com/acme/widgets.git`
(push URL the bare repository); it commits an `AGENTS.md` whose quality row is `| quality (fixture) | \`sh
./battery.sh\` |`, a `.github/workflows/ci.yml` with one `koalaman/shellcheck:v0.11.0` line, and `battery.sh`, which
records its working directory and `git rev-parse HEAD` into a file under the work directory and exits with a committed
code. Stubs: `gh` (records its arguments and environment; `auth status` exits per a file, `api` exits per another and
prints a canned body), `shellcheck` (prints `version: <file content>`), `claude` (prints a fixed version). The suite
runs no real battery and reaches no network.

Cases, each asserting the exit status, the `gh` arguments and the worktree list afterwards:

1. green battery → `api` called with `--method POST`, `repos/acme/widgets/statuses/<sha>`, `state=success`,
   `context=quality`; exit 0; `battery.sh` ran in a directory other than the clone, at the expected SHA; the
   temporary worktree is gone (`git worktree list` shows the clone only).
2. red battery (exit 1) → `state=failure`, exit 1. 3. battery exit 7 → exit 7.
4. green battery, `api` fails → exit 3, stderr names `success` and the SHA.
5. `gh` absent from `PATH` → exit 2, `battery.sh` never ran, nothing posted. 6. `gh auth status` fails → exit 2.
7. shellcheck `0.10.0` against a `0.11.0` pin → exit 2, nothing ran. 8. `ci.yml` pins two versions → exit 2.
9. quality row missing → exit 2; two quality rows → exit 2.
10. uncommitted edit: the committed `battery.sh` exits 0, the working copy is changed to exit 1 → the run is green
    (committed content only); an untracked file in the clone does not appear in the worktree.
11. an explicit older commit whose `battery.sh` exits 1 → `failure` posted to that SHA, `HEAD` unchanged.
12. `origin` not on github.com, and `origin` missing → exit 2. 13. SSH-form `origin` URL → the same `repos/acme/widgets`.
14. `GH_TOKEN=stubsecret`, `HOME` set to the work directory: neither string appears in the recorded `gh` arguments or
    the description.
15. the battery is killed (`TERM` to the script while `battery.sh` sleeps) → no worktree left, nothing posted.
16. `GH_REPO=evil/other GH_HOST=ghe.example.com` → the call still names `--hostname github.com` and `repos/acme/widgets`.

The quality and lint rows of `AGENTS.md § Commands` gain `shellcheck --shell=sh scripts/local-ci.sh`, `shellcheck
--shell=sh --exclude=SC2015 scripts/local-ci.test.sh` and `sh scripts/local-ci.test.sh`; `ci.yml`'s lint and suite
steps gain the same lines (§4).

## 4. `ci.yml` (story AC-11)

The triggers (`pull_request`, `push` to `main`), the `concurrency` block, the job and its steps stay as they are. The
only edit: the lint step gains the two shellcheck lines and the suite step gains `sh scripts/local-ci.test.sh`, as
0.44.0 added them for `worktree-cleanup`, so the job checks what the battery checks (D-9). No `workflow_dispatch`
trigger is added (D-11).

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
- **`AGENTS.md`:** Boundaries get item 4b: `scripts/local-ci.{sh,test.sh}` (reads the repository; creates and removes
  one temporary worktree under a `mktemp -d` directory; posts one commit status to GitHub; never changes a ruleset,
  a branch or a remote). § Commands: the quality row's label reads "the whole battery — what CI runs, and what
  `scripts/local-ci.sh` runs on the Mac when the Actions budget is used up or local is chosen"; a new row `local CI
  (runs the quality row on one commit in a temporary worktree and posts it as the \`quality\` status; the opt-in path
  beside CI; needs a logged-in gh)` with `sh scripts/local-ci.sh [<commit>]`, written only after it was run and
  observed; the prerequisites paragraph adds that `scripts/local-ci.sh` refuses to run with a shellcheck other than the
  `ci.yml` pin and needs `gh` logged in (`gh` addressed by name, as before). The quality row and the `invariant check
  (12 version bump)` row run `sh scripts/check-version-bump.sh origin/main` instead of `main` (D-17), and the
  precondition paragraph says to `git fetch origin` first so that ref is current; the "CI runs the parts as separate
  steps" paragraph stays, with its version-bump sentence reading "with HEAD at `origin/main`, where the merge-base is
  HEAD, it passes trivially".
- **`README.md` § Contributing:** CI runs the battery; when the Actions budget is used up, or you choose local up
  front, `sh scripts/local-ci.sh` runs it on the Mac and posts the same required `quality` check.
- **`docs/ARCHITECTURE.md`:** tree lines for the two new files; the Components paragraph names the runner and its
  suite.
- **`docs/TECH-STACK.md`:** the shellcheck row adds that `local-ci.sh` requires the local version to equal the
  `ci.yml` pin; a `gh` row (addressed by name; `local-ci.sh` requires it, `worktree-cleanup.sh` uses it when present).
- **`docs/reference.md` § Contributing:** a paragraph on the two paths: when the local one is used, how
  (`git fetch origin` first for a merge commit), that the ruleset accepts the `quality` check from either source after
  Daniel's change (§8), one path per commit (D-16), the local run's differences to the job (local shellcheck binary at
  the pinned version, the local `claude` CLI instead of the npm pin, macOS tools instead of ubuntu-24.04's `/bin/sh`
  and awk) and the consequence in §7; its two `required CI check` phrases in the review-gates section become
  `required check`, as in the rules.
- **`plugins/dev-workflow/CHANGELOG.md`** entry 0.47.0; `plugin.json` version 0.47.0.
- **`todos.md`**, new section "From kit 0.47.0 local CI (2026-10-28) — backlog only": `/workflow-init`'s scaffolded
  `ci.yml` template and `docs/setup.md` step 8 for a project that wants the local option (trigger: a second project
  loses Actions); `process-pr-review`'s "CI is the enforced authority" wording for a locally reported check (same
  trigger); the `claude` CLI version difference between the local run and the CI pin (trigger: `claude plugin
  validate` disagreeing between the two); which of two same-named results GitHub counts when both paths post on one
  commit (trigger: it happens).

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
| AGENTS.md § Commands: the quality row is what CI runs | kept, extended: and what `local-ci.sh` runs on the Mac |
| AGENTS.md § Commands: `check-version-bump.sh main` is in the quality row because that row claims to be what CI runs; CI passes the PR's base ref; the precondition of a committed state and a current base ref | kept; the base becomes `origin/main` (D-17): in a lane layout the local `main` moves only when pulled in the main checkout and can lag behind a branch point, and a diff from a lagging merge-base can contain another commit's bump, which lets a missing bump pass; `origin/main` cannot lag behind a branch taken from it. The precondition now reads "committed, and fetched" |
| AGENTS.md § Commands: CI runs the parts as separate steps for readable failures; the chained form is the single command a human runs | kept unchanged |
| `docs/reference.md` § Contributing: CI runs four checks on every PR and push to main; a fifth on pull requests only | kept; the local path is added as the alternative that runs the whole battery, the version-bump check against `main` included |
| `docs/reference.md` § Contributing: a PR with a green `quality` check is the only way into `main`, admins included, no bypass actors; the version-bump step runs inside that job | kept with its new meaning: the check comes from the job or from `local-ci.sh`, either source after §8; the consequence in §7 is stated |
| `ci.yml`: `pull_request` and `push` to `main` start the job; PR runs supersede each other; the version-bump step runs on `pull_request` | kept unchanged (Daniel 09:41) |
| `docs/setup.md` step 8, `docs/getting-started.md`, `docs/coding-workflow.md`: a project's CI runs the battery | kept unchanged: they describe other projects (non-goal) |

## 7. Security (security standard)

- The status is posted under the user's own `gh` login (token scopes include `repo`); the script never reads, prints or
  passes the token, and `gh` handles authentication.
- The description is fixed text and two tool versions. No path, user or host name, environment value or secret.
- After §8 the required check is satisfiable by any status named `quality` that a collaborator with write access
  posts, by this script or by hand, without a battery run. That is the guarantee D63 trades away, and
  `docs/reference.md` § Contributing says so in one sentence; the repository has one maintainer, and a mitigation (an
  App identity, a verified source) is a non-goal.
- The script runs the quality command of the commit it checks, which runs that commit's scripts: the same trust as
  running the battery by hand. The docs say: run it only on commits you have read; never on a fork's head, which is
  the reason there is no self-hosted runner.
- The Actions job keeps running for a fork's pull request exactly as before; nothing here changes its permissions.

## 8. Outside the repository (Daniel; story AC-9)

The ruleset `protect-main.` (id 19168350) requires `quality` with `integration_id` 15368 (GitHub Actions), so a status
from this script does not satisfy it until the integration restriction is dropped. The plan lists this action with the
exact call: a `PUT` of the ruleset with its current body (read on 2026-10-28) and the required check reduced to
`{"context":"quality"}`; the update endpoint replaces `rules` as a whole, so the body carries all three rules. A read of
the ruleset afterwards shows `required_status_checks: [{"context":"quality"}]`, which the Actions job's check run and
the script's status both satisfy. Nothing in the repository changes the ruleset. Until the change is made, a pull
request of this repository cannot merge. Actions do not run for this repository now, the free allowance included
(Daniel through the orchestrator, 09:40): a run that never starts for this pull request is the expected observation,
and the PR body records it as such, with the run id if one appears. Which result GitHub counts when an Actions check
run and a local status, both named `quality`, exist on one commit is not established here; the docs say one path per
commit (D-16).

## 9. Acceptance evidence

| Story AC | Evidence |
|---|---|
| AC-1 | suite cases 1, 10, 11, 15; a real run on the PR head |
| AC-2 | suite case 1 (arguments), 13; `gh api repos/dsnger/dev-workflow-kit/commits/<sha>/status` on the PR head |
| AC-3 | suite cases 4, 5, 6, 11 |
| AC-4 | suite cases 7, 8; §5 docs (`AGENTS.md` prerequisites, `docs/TECH-STACK.md`, `docs/reference.md`) |
| AC-5 | `shellcheck --shell=sh` on both files in the battery; `sh scripts/local-ci.test.sh` in the quality row; the suite's stubs (no network, no real battery) |
| AC-7 | the files of §5, each run or read; the `local CI` row written after an observed run |
| AC-8 | §6 table; checks 4i and 4j green |
| AC-9 | the plan's "outside the repository" section with the `gh api` call; the PR body line on Actions |
| AC-10 | `plugin.json` 0.47.0 + CHANGELOG; battery green on the final head, its version-bump stage run as `check-version-bump.sh origin/main` and observed; `quality` status on the merge commit |
| AC-11 | `git diff` of `ci.yml`: the three parity lines only; README and `docs/reference.md` name both paths and when |

## 10. Decisions

- D-1 Always a temporary worktree, never a dirty-tree refusal: it makes "committed content only" structural, lets the
  script check `origin/main` after a merge without switching branches, and leaves the caller's checkout untouched.
- D-2 The quality command is read from the checked commit's `AGENTS.md` rather than copied into the script: one
  source (CLAUDE.md §4 "one source of green"), no third copy to drift; executing it is the same trust as the battery.
- D-3 The shellcheck pin is read from the checked commit's `ci.yml`, not hard-coded, for the same reason.
- D-4 Exit statuses 0 / battery's / 2 / 3 as in §2: "exit code follows the battery" (the brief) for every run that
  posted; a failed post is distinct so a chained command cannot mistake it for green.
- D-5 No `target_url` and no `pending`: there is no log to link, and a `pending` left by a killed run would need an
  `error` path for no gain.
- D-6 The description names the result and the two tool versions that differ from CI (shellcheck, `claude`), nothing
  else, so the difference to CI is visible where the check is read.
- D-7 The gate rules change by two word swaps, mirrored into `### 2.1a` (check 4j), hence plugin 0.47.0. The
  alternative, leaving "required CI check" in this repository's rules, contradicts the brief.
- D-8 `process-pr-review` stays unchanged: `gh pr checks` lists a commit status, so its Step 1 and Step 4 read
  correctly; its "CI is the enforced authority" sentence is right for the default path and gets a `todos.md` row.
- D-9 `ci.yml` gains only the parity lines for the new lint and suite, as every new script's did; a job that checks
  less than the battery would make the quality row's "what CI runs" false.
- D-10 The builder check of `superpowers:brainstorming` runs once (one subagent) before Gate A; Gate A is the approval.
- D-11 No `workflow_dispatch` trigger: nobody asked for a by-hand start, and the job keeps its triggers (Daniel 09:41).
- D-12 Owner and repository from `origin`'s URL only, with `--hostname github.com`: the same choice as
  `worktree-cleanup.sh`, so `GH_REPO`/`GH_HOST` in a session's environment cannot redirect a post.
- D-13 The script and suite are repository tooling under `scripts/`, outside the plugin (Boundaries 5).
- D-14 A draft pull request is opened right after this spec is committed (docs-only branch state) and not waited on:
  a run that never starts is the expected observation, recorded in the PR body (AC-9).
- D-15 Context7 (`/websites/github_en_rest`, read 2026-10-28) is the source for the statuses `POST` fields
  (`state`, `context`, `description`, `target_url`) and the rulesets `PUT` body (`rules` required as a whole,
  `integration_id` optional per check); `gh` 2.96.0 is the local client.
- D-16 One path per commit: the docs tell the user to post the local status only for a commit the job did not check,
  because the precedence between two same-named results is not established (a `todos.md` row).
- D-17 The quality row's version-bump stage compares against `origin/main`, not the local `main` (builder check,
  2026-10-28): a local `main` behind the branch point lets a missing bump pass as green, and on the local path this
  script is the only producer of the required check. `origin/main` is what CI compares against too (`origin/<base>`).
  The script itself does not fetch (one less side effect on shared refs; the docs say to fetch first).
- D-18 Exit 3 for a failed post is kept although a stage exiting 3 would collide: no stage of the battery exits 3 today,
  the printed line names the cause, and a code outside every tool's range does not exist. Stated as a limit.
- D-19 A signal to the script does not interrupt the running stage: forwarding it to the `sh -c` child would need a
  background run plus `wait` and signal bookkeeping for a case nobody asked for; Ctrl-C in a terminal reaches the whole
  foreground process group anyway. The worktree is removed and nothing is posted in every case.
