# Kit local CI Implementation Plan

> **For agentic workers:** Use superpowers:subagent-driven-development for Task 1 and inline execution for Tasks 2–5 (see Deviations). Steps use checkbox (`- [ ]`) syntax.

**Goal:** Ship dev-workflow 0.47.0 with `scripts/local-ci.sh`, which runs the quality battery on one commit in a temporary worktree and posts it to GitHub as the `quality` commit status, beside the unchanged Actions job; instructions and docs read correctly for a locally reported check.

**Architecture:** One POSIX `sh` script under `scripts/` (repository tooling, not shipped) with a stub-based suite in the battery; three parity lines in `ci.yml`; two word swaps in the gate rules mirrored into the `### 2.1a` template; generic rewording in `process-pr-review`; one clause in CLAUDE.md §4; docs. The switch between the paths is the workflow's enabled state on GitHub.

**Tech Stack:** POSIX `sh` (shellcheck 0.11.0, `dash` and `sh`), git 2.52, `gh` 2.96.0 (GitHub REST API version `2026-03-10`), Markdown prompts.

**Spec:** `docs/superpowers/specs/2026-10-28-kit-local-ci-design.md` (story `docs/superpowers/stories/2026-10-28-kit-local-ci-story.md`, risk standard → this plan gets no Gate A; Gate A on the spec closed as cycle `k047lci1028`).

## Global Constraints

- POSIX `sh`, no bash-isms; `shellcheck --shell=sh` clean (the suite with `--exclude=SC2015` like the other suites); the suite runs under `sh` and `dash`; no network, no real battery in the suite (spec §3).
- Exit statuses: `0` green and posted; the battery's own status when red and posted; `75` post failed; `64` usage, precondition or setup failure (spec §2).
- Gate rules ≤ 10,000 bytes and byte-identical in both copies (checks 4i, 4j; now 9,998); `CLAUDE.md` + `AGENTS.md` ≤ 150,000 chars (4g).
- Every changed prompt passes the 12 items of `docs/prompt-standards.md`; version 0.47.0 in `plugins/dev-workflow/.claude-plugin/plugin.json` with a CHANGELOG entry (invariant 12).
- `ci.yml` keeps its triggers, concurrency block, job and steps; only the three parity lines are added (story AC-11, spec §4).
- Every command documented in `AGENTS.md § Commands` was run in this unit and observed (AGENTS.md Don'ts).
- No `Co-Authored-By`/`Generated with` lines; WIP commits as plain `git commit -m 'WIP: <subject>'` after a separate staging call.

## Review Focus

1. An `origin` URL with a trailing slash (`https://github.com/acme/widgets/`): no post to a guessed slug; exit 64 (Task 1 case 12b).
2. A quality row whose label cell holds an escaped pipe (`\|`) and backticks: the last cell is still the command (Task 1 case 9b); a command containing a pipe is a stated limit in the script header.
3. The caller is itself a linked worktree of the repository: the temporary worktree is created and removed, the status names the requested SHA (Task 1 case 20).
4. `claude` not on `PATH`: the description reads `claude unknown`, the exit status follows the battery (Task 1 case 21).
5. `TMPDIR` containing a space: the worktree path is quoted everywhere; the run and the cleanup work (Task 1 case 22).

## Sources and impact boundary

Read: the spec and story; `AGENTS.md` (Boundaries 29–52, § Commands 246–293); CLAUDE.md §4 (97) and §5; `.claude/review-gates.md` (39, 62) and `workflow-init.md` 686; `.github/workflows/ci.yml`; `scripts/worktree-cleanup.sh` (header, 115–120 origin parsing) and its suite (1–60 stubs); `scripts/check-version-bump.sh` (base handling); `scripts/check-invariants.sh` 999–1070 (4i, 4j); `plugins/dev-workflow/commands/process-pr-review.md` 30–36, 203–216, 239, 252–253, 289; `docs/reference.md` 341–343, 731–752; README 81–83; `docs/ARCHITECTURE.md` 26, 45–46, 79–87; `docs/TECH-STACK.md`; `todos.md` 2164–2176; `plugins/dev-workflow/CHANGELOG.md` 1–40. Library APIs via Context7 on 2026-10-28: `/websites/github_en_rest` (create a commit status `POST /repos/{owner}/{repo}/statuses/{sha}`: `state`, `context`, `description`, `target_url`; update a repository ruleset `PUT /repos/{owner}/{repo}/rulesets/{ruleset_id}`: `rules` replaced as a whole, `integration_id` optional) at REST API version `2026-03-10` (confirmed supported by a probe; `gh` 2.96.0 defaults to `2022-11-28`); `/github/docs` (required checks: check runs or statuses, both must pass under one name; a disabled workflow ignores its triggers; `gh workflow disable|enable`).
Impact: two new files under `scripts/`; `AGENTS.md`, `CLAUDE.md`, `.claude/review-gates.md`, `.github/workflows/ci.yml`, README, `docs/ARCHITECTURE.md`, `docs/TECH-STACK.md`, `docs/reference.md`, `todos.md`; under `plugins/dev-workflow/`: `commands/workflow-init.md` (`### 2.1a` only), `commands/process-pr-review.md`, `CHANGELOG.md`, `.claude-plugin/plugin.json`. Not touched: the hook and its suite, the skills, `examples/`, `source-files/`, the other scripts, `docs/setup.md`, `docs/getting-started.md`, `docs/coding-workflow.md`, any ruleset or workflow state.

## Long runs, handover, outside actions

- No run is expected to take 45 minutes. The full battery takes 20–25 minutes on this Mac (two hook-suite runs of about 9 minutes each; CI took 4m29s on ubuntu); it runs through `scripts/local-ci.sh` three times (the WIP head before Gate B, the final head, the merge commit), about 75 minutes in all, each announced to the orchestrator in one line first (brief: heavy runs ≥ 15 minutes wait for "go"). The suite itself runs in seconds.
- Handover boundary: the merged PR with the merge commit's status (one unit).
- Actions outside the repository (Daniel), asked once when this plan is written, not waited on until the merge:
  1. **Ruleset 19168350:** make the required check `quality` accept any source. Body at `/private/tmp/claude-501/-Users-daniel-DEVELOPMENT-APPS-dev-workflow-kit-lanes-kit-local-ci/e5e1a85c-8cd1-4a78-819f-866fe00fe108/scratchpad/ruleset-19168350-any-source.json` (the current body read 2026-10-28, `integration_id` removed, read-only fields dropped). Call: `gh api --method PUT -H "X-GitHub-Api-Version: 2026-03-10" repos/dsnger/dev-workflow-kit/rulesets/19168350 --input <that file>`. Check: `gh api repos/dsnger/dev-workflow-kit/rulesets/19168350 --jq '.rules[] | select(.type=="required_status_checks") | .parameters.required_status_checks'` prints `[{"context":"quality"}]`. Until then the Actions check run alone satisfies the ruleset and the local status is additive but not counted.
  2. **The switch, when the local path is chosen:** `gh workflow disable ci.yml` (and `gh workflow enable ci.yml` to go back), run by Daniel or a session, never by the script. Not needed for this unit: Actions ran for PR #100.
  3. `claude plugin update` after the merge is the orchestrator's.

---

### Task 1: `scripts/local-ci.sh` and its suite (subagent)

**Files:** Create `scripts/local-ci.sh`, `scripts/local-ci.test.sh`. Patterns: `scripts/worktree-cleanup.sh` (header comment style: usage, what it does, what it does not, exit statuses; `set -u`; `LC_ALL=C`; origin parsing at 115–120) and `scripts/worktree-cleanup.test.sh` (stubs, fixture, `pass`/`fail`, `run`, shell selection).

**Interfaces (produces):**
- `sh scripts/local-ci.sh [<commit>]` from the repository root; the repository is the one containing the current directory; default `HEAD`; a second argument → usage, exit 64.
- Environment: unsets `GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_COMMON_DIR GIT_OBJECT_DIRECTORY GIT_ALTERNATE_OBJECT_DIRECTORIES GIT_NAMESPACE GIT_CEILING_DIRECTORIES` first; `LC_ALL=C`.
- Preconditions in the spec's order (§2 items 1–5), each one line on stderr `local-ci: <condition>; <what to do>`, exit 64, nothing posted. The shellcheck pin: every `koalaman/shellcheck:v<version>` match in `git show <sha>:.github/workflows/ci.yml`, one distinct version, equal to the `version:` line of `shellcheck --version`. The quality row: lines of `git show <sha>:AGENTS.md` starting with `| quality `, exactly one; the command is the content of the last cell's backticks (the label may hold backticks and `\|`); a command containing a bare `|` is a stated limit.
- Setup: `tmp=$(mktemp -d)`; `git worktree add --detach "$tmp/wt" "$sha"`; trap on `EXIT HUP INT TERM` removes `"$tmp/wt"` with `git worktree remove --force` (that path only; no prune) and `rm -rf "$tmp"`; a failed removal prints `local-ci: could not remove <path>; run: git worktree remove --force <path>` to stderr and leaves the exit status unchanged. Setup failure → exit 64.
- Run: `(cd "$tmp/wt" && sh -c "$cmd")` in the foreground, output passed through; `st=$?`.
- Post: `gh api --hostname github.com --method POST -H "X-GitHub-Api-Version: 2026-03-10" "repos/$slug/statuses/$sha" -f state=<success|failure> -f context=quality -f description="<desc>"` with `<desc>` = `battery green: local run, shellcheck <v>, claude <v>` or `battery red: …` (`<v>` the first word of `claude --version`, `unknown` when absent). On success print `local-ci: posted quality=<state> on <sha>: <desc>`; on failure print `local-ci: post failed for quality=<state> on <sha>; rerun after fixing gh` to stderr, exit 75.
- Exit: 0 green+posted; `$st` red+posted; 75 post failed; 64 before the run. Header `shortcut:` note for the 64/75 collision limit and the pipe limit.

- [ ] **Step 1: Write `scripts/local-ci.test.sh`** with the fixture (bare origin + clone, origin URL `https://github.com/acme/widgets.git`, committed `AGENTS.md` row ``| quality (fixture, `x`) | `sh ./battery.sh` |``, `.github/workflows/ci.yml` with `koalaman/shellcheck:v0.11.0`, `battery.sh` recording `pwd -P` and `git rev-parse HEAD` into `$STUB_DIR/battery.ran` and exiting per a committed `exit.code` file), the stubs (`gh` recording `"$@"` one per line plus `GH_TOKEN`/`HOME`/`GH_REPO`/`GH_HOST` lines into `gh.args`, `auth status` exiting per `gh.auth.rc`, `api` exiting per `gh.rc`; `shellcheck` printing `version: $(cat shellcheck.v)`; `claude` printing `9.9.9 (stub)`; a `git` wrapper failing `worktree add` when `git.failadd` exists and `worktree remove` when `git.failrm` exists, otherwise `exec`ing the real git), `LOCAL_CI_SH=${LOCAL_CI_SH:-sh}`, and the spec's cases 1–19 plus 9b, 12b, 20, 21, 22 of the Review Focus. Assertions per case: exit status, the `gh.args` lines (`--method`, `POST`, `-H`, `X-GitHub-Api-Version: 2026-03-10`, `repos/acme/widgets/statuses/<sha>`, `state=…`, `context=quality`, `description=…`), `battery.ran` content, `git worktree list --porcelain` afterwards (only the clone, plus the stale registration in case 19).
- [ ] **Step 2: Run `sh scripts/local-ci.test.sh`** — expected: every case FAIL or the harness stops at the missing script.
- [ ] **Step 3: Write `scripts/local-ci.sh`** to the interface above, header comment in the style of `worktree-cleanup.sh` (usage, preconditions, what it does, what it does not, exit statuses, the two limits, "Regression suite: scripts/local-ci.test.sh", spec path).
- [ ] **Step 4: Run `sh scripts/local-ci.test.sh && LOCAL_CI_SH=dash dash scripts/local-ci.test.sh`** — expected: all cases `ok`, summary line, exit 0 under both shells.
- [ ] **Step 5: Run `shellcheck --shell=sh scripts/local-ci.sh && shellcheck --shell=sh --exclude=SC2015 scripts/local-ci.test.sh`** — expected: no output, exit 0.
- [ ] **Step 6: Stage both files; commit `WIP: local-ci script and suite`** (separate plain Bash calls).

### Task 2: `AGENTS.md` and `ci.yml` (inline)

**Files:** Modify `AGENTS.md` 39–45 (Boundaries: new item 4b after 4a), 252 (quality row: label and command), 254 (lint row), 258 (version-bump row), 263–275 (prerequisites), 284–293 (precondition and separate-steps paragraphs); a new row `local CI` after 259. Modify `.github/workflows/ci.yml` 101–103 (two shellcheck lines after the worktree-cleanup pair) and 136 (`sh scripts/local-ci.test.sh` after the worktree-cleanup suite).

- [ ] **Step 1: Edit `AGENTS.md`** per spec §5: Boundaries 4b (`scripts/local-ci.{sh,test.sh}`: reads; creates and removes one temporary worktree under a `mktemp -d` directory; posts one commit status to GitHub; never fetches, pushes, prunes, changes a ruleset, a workflow's state, a branch or a remote); quality row label "the whole battery — what CI runs, and what `scripts/local-ci.sh` runs on the Mac when the Actions budget is used up or local is chosen", its command gaining the two shellcheck calls after the worktree-cleanup pair and `sh scripts/local-ci.test.sh` after `sh scripts/worktree-cleanup.test.sh`, and `check-version-bump.sh origin/main`; the lint row gaining the two shellcheck calls; the version-bump row `sh scripts/check-version-bump.sh origin/main`; the `local CI` row with `sh scripts/local-ci.sh [<commit>]` (left as a draft until Step 3 observed the run — the row is committed only in Task 5 after that run); prerequisites: `local-ci.sh` refuses a shellcheck other than the `ci.yml` pin and needs `gh` logged in; precondition paragraph: `origin/main`, `git fetch origin` first; the separate-steps paragraph's last sentence: "with HEAD at `origin/main`, where the merge-base is HEAD, it passes trivially".
- [ ] **Step 2: Edit `ci.yml`** — the three parity lines, each with a one-line comment like the worktree-cleanup ones.
- [ ] **Step 3: Run the changed rows' new parts:** `shellcheck --shell=sh scripts/local-ci.sh && shellcheck --shell=sh --exclude=SC2015 scripts/local-ci.test.sh && sh scripts/local-ci.test.sh && sh scripts/check-version-bump.test.sh && sh scripts/check-version-bump.sh origin/main` — expected: exit 0, the version-bump check reporting the plugin paths changed (none yet) or clean.
- [ ] **Step 4: Stage `AGENTS.md`, `.github/workflows/ci.yml`; commit `WIP: AGENTS.md commands and boundaries, ci.yml parity`.**

### Task 3: Rules, CLAUDE.md §4, `process-pr-review`, version (inline)

**Files:** Modify `.claude/review-gates.md` 62 and `plugins/dev-workflow/commands/workflow-init.md` 686 (identical edit); `CLAUDE.md` 97; `plugins/dev-workflow/commands/process-pr-review.md` 30–36, 203–216, 239, 252–253, 289; `plugins/dev-workflow/.claude-plugin/plugin.json` 4; `plugins/dev-workflow/CHANGELOG.md` (new `## 0.47.0` above `## 0.46.0`).

- [ ] **Step 1: Gate rules:** in both copies replace `the PR head's required CI check is then the battery evidence` with `the PR head's required check is then the battery evidence` and `A red CI stops.` with `A red check stops.`
- [ ] **Step 2: Verify:** `wc -c .claude/review-gates.md` prints `9998`; `sh scripts/check-invariants.test.sh && sh scripts/check-invariants.sh` exits 0 (4i, 4j, 4e, 4g).
- [ ] **Step 3: CLAUDE.md §4:** after the first sentence of "Waiting on external work" add: "A check this session produces itself — `sh scripts/local-ci.sh` runs the battery here and posts the `quality` status — is not external work: its result is the script's exit status, and one read of the status on that SHA (`gh api repos/<owner>/<repo>/commits/<sha>/status`) confirms the post; nothing waits."
- [ ] **Step 4: `process-pr-review.md`:** the five edits of spec §5 (Step 1 sentence; Step 3 item 6 and its two exceptions and the report line; Step 4 two phrases; Done one phrase), headings unchanged. Read the result against the 12 items of `docs/prompt-standards.md` and note the pass in the WIP commit body.
- [ ] **Step 5: Version:** `plugin.json` `"version": "0.47.0"`; CHANGELOG entry `## 0.47.0` naming the story and spec, the gate-rules swap, the `process-pr-review` wording, and that the new script is repository tooling and does not ship.
- [ ] **Step 6: Verify:** `claude plugin validate . --strict` exits 0; `grep -rn 'required CI check' . --include='*.md' | grep -vE 'source-files/|docs/history/|docs/superpowers/'` lists only `docs/reference.md` (fixed in Task 4).
- [ ] **Step 7: Stage the six files; commit `WIP: gate rules, CLAUDE.md, process-pr-review for a locally reported check, 0.47.0`.**

### Task 4: Docs and todos (inline)

**Files:** Modify `README.md` 81–83; `docs/ARCHITECTURE.md` 26, after 46 (two tree lines), 79–87 (Components); `docs/TECH-STACK.md` 13 and a `gh` row before 20; `docs/reference.md` 341–343 and 731–752; `todos.md` after 2176 (new section).

- [ ] **Step 1: Edit** per spec §5: README (CI runs the battery; when the Actions budget is used up or you choose local, disable the workflow and run `sh scripts/local-ci.sh`, which posts the same required `quality` check; link `docs/reference.md#contributing`); ARCHITECTURE tree (`scripts/local-ci.sh # runs the quality row on one commit in a temporary worktree, posts the quality status`, `scripts/local-ci.test.sh # its regression suite — fixture repos, stub gh, shellcheck, claude, git`) and the Components paragraph ("plus one shell runner with its suite, `scripts/local-ci.{sh,test.sh}`"); TECH-STACK shellcheck row ("local: the prerequisites paragraph; `scripts/local-ci.sh` refuses a version other than the `ci.yml` pin") and a `gh` row (addressed by name; `local-ci.sh` requires it logged in, `worktree-cleanup.sh` uses it when present); reference.md 341–343 `required check` twice, and § Contributing: the two paths, the switch (`gh workflow disable ci.yml` / `enable`), `git fetch origin` first and the merge commit as `origin/main`, the ruleset accepting `quality` from either source after Daniel's change, the both-must-pass rule, the differences to the job (local shellcheck binary at the pinned version, the local `claude` CLI instead of the npm pin, macOS `/bin/sh` and awk instead of ubuntu-24.04's), the consequence (any collaborator with write access can post `quality` by hand; the author is visible in the merge box) and "run it only on commits you have read, never on a fork's head"; todos section "From kit 0.47.0 local CI (2026-10-28) — backlog only, nothing implemented here" with the three rows of spec §5.
- [ ] **Step 2: Verify:** `sh scripts/check-doc-links.test.sh && sh scripts/check-doc-links.sh source-files/ docs/history/ docs/superpowers/replays/` exits 0; the AGENTS.md Don'ts recipes: the gate-claim grep (`grep -rniE '(everything|anything|all content|any change)[^.]{0,80}\b(commit|fingerprint|hash)\b|…'`) adds no new hit; `grep -rn 'required CI check' --include='*.md' . | grep -vE 'source-files/|docs/history/|docs/superpowers/'` prints nothing.
- [ ] **Step 3: Stage the five files; commit `WIP: docs for the local path`.**

### Task 5: Battery through the script, Ponytail, Gate B, PR, merge, status on the merge commit

- [ ] **Step 1: Push the branch.** One line to the orchestrator: the full battery through `scripts/local-ci.sh` (~25 minutes) is about to run; wait for "go".
- [ ] **Step 2: `git fetch origin && sh scripts/local-ci.sh`** on the WIP head — expected: the battery output, then `local-ci: posted quality=success on <sha>: battery green: local run, shellcheck 0.11.0, claude 2.1.312`, exit 0; `gh api repos/dsnger/dev-workflow-kit/commits/<sha>/status --jq '.statuses[] | select(.context=="quality") | .state'` prints `success`. A red battery: fix, rerun (at most 5 rounds, CLAUDE.md §4). Then write the `local CI` row into `AGENTS.md § Commands` (Task 2's draft) and commit `WIP: local CI row, observed`.
- [ ] **Step 3: Ponytail pre-review** (`/ponytail:ponytail-review` on the branch diff, once): fix real defects; apply or reject each cut in one line; list them under "Ponytail pre-review" in the PR body.
- [ ] **Step 4: Gate B** (`strict`, floor 1, cap 5, full passes): fresh nonce; per pass two `mcp__codex__review` calls (`spec`, then `quality`) on `baseSha` = the merge-base with `origin/main` (b8b08f7, 40 characters) and `headSha` = the WIP head, `additionalContext` naming the slot, the one-line format, the AC map, and this head's battery evidence (the local run of Step 2, posted as the status); repair blocking findings (Blocker, Major, Security, violated AC), WIP commit, rerun; collect the rest; dispositions per pass. Closing act: archive the pass files, closing commit `git commit -F .context/<msg>` with the cycle lines, ledger check and any owed hardening lines; `harden-finding` for each distinct fixed finding that fits lint or test.
- [ ] **Step 5: Push; `sh scripts/local-ci.sh`** on the final head (announce first) — expected as Step 2; then the PR body (`gh pr edit 100 --body-file`): summary; decisions (spec §10 by number); AC-9 observation (run 40659778216 started at 08:51:13Z and passed at 08:55:42Z; the ruleset still requires Actions until Daniel's change); the local status on the final head; Ponytail pre-review; the cycle lines; mark the PR ready (`gh pr ready 100`).
- [ ] **Step 6: `/dev-workflow:process-pr-review 100`**, then squash-merge with a body written from the PR's commits (no attribution lines), `--match-head-commit <headRefOid>`.
- [ ] **Step 7: `git fetch origin && sh scripts/local-ci.sh origin/main`** (announce first) — expected: `local-ci: posted quality=success on <merge sha>`; `gh api repos/dsnger/dev-workflow-kit/commits/<merge sha>/status --jq '.state'` prints `success`. Then one line to the orchestrator (merge SHA, status, what changed) and the handover at `.context/handover-kit-local-ci.md`.

## Deviations

- Task 1 runs as subagent-driven development (one implementer, one reviewer); Tasks 2–5 inline: they are edits to instruction files and docs that need this session's context, and Gate B reviews the whole diff.
- The `local CI` row is committed only after the run of Task 5 Step 2 was observed (AGENTS.md Don'ts).
