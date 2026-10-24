# Kit 0.44: cleanup report, long-run rules, Codex preflight, skip prefixes — Design

**No story:** the work comes from the orchestrator brief
`.context/sparring/20261024-115500-kit-044-prompt.md` (four field cases, 2026-10-22 to 2026-10-24,
main checkout); there is no story file.
**Profile (derived, as intake does):** `risk high; security standard; evidence battery+check` — risk
`high` because it changes the scaffolded `CLAUDE.md` template (a contract every initialized project
follows) and adds a script that deletes worktrees and branches; security `standard` because that
script removes data and must stay inside a path boundary, but touches no secret, permission or
credential; `battery+check` because the new script's suite runs in the battery and checks 4e, 4g,
4i and 4l measure the changed texts.
**Date:** 2026-10-24 · **Version:** dev-workflow 0.44.0 (minor: new template guidance and a new
`/workflow-init` question text).

## Decisions

Taken in this note (autonomous run, CLAUDE.md §4), each a choice, not a source fact. One Gate A covers
spec and plan: the plan is §7 of this note, as in 0.41.0.

| # | Case | Verdict | Reason |
|---|---|---|---|
| 1 | Cleanup is manual and fragile | **adopt** | A repo script `scripts/worktree-cleanup.sh`: a report by default, removal only with `--remove` and only of rows the report marks removable. |
| 1a | Where it lives | **repo only, not shipped** | Same boundary as the other reports (AGENTS.md Boundaries 5): the orchestrator and the human run it from a kit checkout against any repository path. Shipping it would need a `/workflow-init` template plus a copy check, for a tool the unit's own session must not run. |
| 1b | Remote branches | **not touched** | Deleting a remote branch is outward-facing and not undone by the script; GitHub's delete-head-branch setting covers merged PR branches. The report says so. |
| 1c | "Live session" | **a process whose working directory is the worktree or inside it** (`lsof`) | No session registry exists across Claude Code, Codex and Orca; a process cwd is what each of them leaves. Missing, failing or empty `lsof` output is `unknown`, which blocks removal; the remaining race is stated (§2). |
| 1d | Ignored files | **block unless `--discard-ignored`** | `git worktree remove` deletes ignored files; only `.context/` is archived, so anything else ignored needs an explicit flag. |
| 2 | Long runs | **adapt** | The rule goes into the Plan bullet's long-run list in the `CLAUDE.md` template and this repo's `CLAUDE.md` as one clause (template stays far under check 4e's 20,000), with the why and examples in `docs/coding-workflow.md`. A pointer alone would point initialized projects at a kit doc they do not have. |
| 3 | Codex preflight | **adapt** | `.claude/review-gates.md` has 5 bytes left under check 4i, so the probe goes into `CLAUDE.md` §5 (template and repo), which is read at session start: run it once before the session's first Codex call. The rules file is untouched. The probe is not one of invariant 5's P6 commands (§4). |
| 4 | Skip prefixes too broad | **adopt** | `/workflow-init` 2.21's question asks for folders that hold only dated records and says a folder that also holds current specs or feature docs is named by its dated subfolder instead. |

## 1. Evidence

- **Case 1.** Board 2026-10-22 14:55: cleanup by the orchestrator across five projects (13 SFX lanes,
  `.context/` archived to `<main>/.context/archive-lane-<name>/`, branches matched "tip = merged PR head
  or ancestor of base"). Board 17:40: a remember plugin hook ran at the end of a session whose worktree
  had already been removed, found its project directory empty and committed the main checkout's
  `.remember/` to `v2` ("sessions must not remove their own worktree before ending"). This checkout:
  `git worktree list` shows two `agent-*` worktrees under `.claude/worktrees/` (branches
  `status-view-daily`, `intake-skill-pilot`) and one Orca workspace outside the repository. Worktrees
  observed in the field live under `<repo>/.claude/worktrees/`, `<repo>/.worktrees/`, a sibling
  `<repo>-lanes/` directory and Orca's `~/orca/workspaces/` (board lines 350, 575, 613; `git worktree
  list` here).
- **Case 2.** Brief items 2a–2c (a stage hung 6 h 24 min at 0 % CPU; board 2026-10-24 05:36–05:57: 32
  CPU burners outlived their test, load 330, until a trap was added; a measurement run stopped at its
  first setup error four times, 16–75 min each).
- **Case 3.** Board 2026-10-23 15:12: an Orca account at its Codex usage limit; the gate calls showed
  empty failures. 0.43.0 put the probe into `docs/reference.md` § Hook messages and the hook's
  failure message; the brief makes it part of every session's start.
- **Case 4.** Board 2026-10-24 08:01: the skills project skipped all of `docs/superpowers/`,
  current specs included.

## 2. Case 1 — `scripts/worktree-cleanup.sh`

**Usage.** `sh scripts/worktree-cleanup.sh [--remove [--discard-ignored]] [--root <dir>]... [<repo>]`.
`<repo>` defaults to the current directory. The main worktree is the first entry of `git -C <repo>
worktree list --porcelain`; when that entry is `bare`, the script exits 2 (`bare repository: no main
worktree`) before reading anything else. It does not fetch, and a default ref is trusted as it is:
the report's first line says to run `git fetch --prune` first, and that `ancestor` means "contained in
the local copy of the default ref", which a rewritten remote history can make stale in either
direction.

**One run at a time.** Before any read beyond the main worktree, the script takes the lock
`<git-common-dir>/worktree-cleanup.lock` with `mkdir` (atomic) and removes it on every exit (trap on
EXIT, INT, TERM, HUP). The lock exists → exit 1 with `<path> exists: another worktree-cleanup run
holds it, or a killed run left it; remove that directory once no run is active`. It is never taken
over silently. This covers concurrent cleanup runs only, not other writers (below).

**Worktree roots.** `<main>/.claude/worktrees/` and `<main>/.worktrees/`, plus each `--root` (an
existing directory, absolute). A worktree is inside a root when its physical path (`pwd -P` after
`cd`) starts with the root's physical path followed by `/`; the root itself is not inside it.
Anything else — the main worktree, an Orca workspace, a sibling directory not passed as `--root`, a
symlink inside a root that resolves outside it — is `keep: outside worktree roots`; a path that no
longer exists is `keep: missing`. Neither is ever removed.

**Default ref.** `refs/remotes/origin/HEAD`'s target, else `origin/main`, else `origin/master`; none →
every ancestry answer is `unknown`. Its branch name (`main`) is the PR base below.

**Rows.** One per linked worktree, then one per local branch that is checked out nowhere and is not
the default branch's name. Fields, one line per row, `key=value` separated by two spaces:

- `merged`: `ancestor` (tip is an ancestor of the default ref) | `pr#<n>` | `no` | `unknown`.
  `pr#<n>`: `gh pr list -R github.com/<owner>/<repo> --state merged --base <default branch> --head <branch>
  --json number,headRefOid --limit 100`, `<owner>/
  <repo>` parsed from `origin`'s URL (`github.com[:/]<owner>/<repo>[.git]`), finds a PR whose
  `headRefOid` equals the tip. `-R` with the host fixes the repository, so `GH_REPO`, `GH_HOST` and
  gh's default-repository choice do not apply. A merged PR whose head differs from the tip, with no matching one, is `no`:
  commits after the merge would be lost. `unknown`: not an ancestor and gh missing, failing, an
  unparseable `origin` URL, or 100 results (the list may be incomplete); or no default ref.
- `dirty` (worktrees): `yes` when `git -C <wt> status --porcelain` prints anything (tracked changes
  or untracked, unignored files), else `no`; a failing status is `unknown`.
- `ignored` (worktrees): the number of entries `git -C <wt> status --porcelain --ignored=matching`
  marks `!!` outside `.context/` (an ignored directory counts once); a failing status is `unknown`.
- `ahead`: commits on the tip not reachable from any remote-tracking ref (`git rev-list --count <tip>
  --not --remotes`); information only.
- `age`: days since the tip's committer date.
- `session` (worktrees): `yes` | `no` | `unknown`. One `lsof -w -nP -d cwd -Fn` run lists the working
  directory of every process lsof can see (the current user's at least); `yes` when one equals the
  worktree's physical path or lies under it. `unknown` when lsof is missing, exits non-zero, or prints
  no `n/` line at all (it then saw nothing, not "no process"). A process lsof cannot see counts as
  absent: the script cannot tell, and the header says so.
- verdict: `removable` or `keep: <first failing reason>`.

**Removable** = inside a root, not locked (porcelain `locked`), not detached, no `.gitmodules` in the
worktree (unforced `git worktree remove` refuses submodules), `merged` is `ancestor` or `pr#<n>`,
`dirty=no`, `session=no`, and `ignored=0` — or `ignored` a number above 0 when `--discard-ignored` is
given, which says the run may delete those ignored files (the report lists the first five). A
branch row: `merged` is `ancestor` or `pr#<n>`.

**`--remove`.** Report first, then for each removable worktree, in report order:

1. When `<wt>/.context/` exists: `mkdir -p <main>/.context`, then `mkdir
   <main>/.context/archive-worktree-<basename>` (then `-2`, `-3`, … while `mkdir` fails because the
   name exists; `mkdir` does not follow an existing symlink), then `cp -R <wt>/.context/. <that
   dir>/`. Any other `mkdir` failure or a failing `cp` → `failed`, and the worktree stays.
2. Recheck right before removing (after the copy, so the copy's duration is not inside the window):
   the porcelain entry still names the same branch and tip, and `dirty`, `ignored` and `session` (a
   fresh `lsof` run for this path) still give the removable values. Any change → `skipped <wt>:
   changed since the report (<field>)`; the archive copy stays.
3. `git worktree remove <wt>` without `--force` (git still refuses tracked changes, untracked files
   and submodules it finds then).
4. `git worktree list --porcelain` must show the branch checked out nowhere, then `git update-ref -d
   refs/heads/<branch> <reported tip>`: an atomic delete that fails when the branch moved.

Then each removable branch row: step 4 with its reported tip.
Each action prints `removed …`, `skipped …` or `failed …: <git's message>`; a failure or skip stops
that row's later steps and the run continues. Exit status: 0 when nothing failed (report mode: 0
unless the repository cannot be read), 1 when an action failed or the lock is held, 2 on a usage
error or a bare repository. Remote branches are never touched.

**Quiescence contract and remaining windows (stated in the header and the docs).** `--remove` is for a
repository whose sessions in the removed worktrees are closed and where nothing else checks out or
moves branches during the run; the caller (the orchestrator or the human) establishes that. The
script narrows what it cannot prevent to two windows, each between two adjacent `git` calls: a
process that starts in the worktree, or a file written there, after step 2 and before step 3 (the
process loses its directory, an ignored file is deleted with it); and a checkout of the branch in
another worktree after step 4's check and before `update-ref` (that worktree is left on a branch with
no ref; its commits are not lost, since the tip is merged). Nothing short of a session registry and a
repository-wide lock closes them, and git offers neither.

**Not covered (stated in the script header):** paths containing a newline; a session with no visible
process whose cwd is inside the worktree (another user's process, a client that changed directory);
squash merges without `gh` (they read `unknown`); repositories whose remote is not named `origin` or
is not on github.com (`unknown` for squash merges); whether a `keep` row is still wanted.

**Executed tools.** `git`, `lsof`, `gh`, `mkdir`, `cp` are addressed by name like `git`, `dash` and
`python3` in AGENTS.md § Commands' prerequisites: they are system tools, not pinned packages, and
invariant 5's scope (CI actions, npm packages, Docker images, MCP servers) does not include them.
`gh` and `lsof` are optional (their absence reads `unknown`, which blocks removal); the suite stubs
both, so CI needs neither. The prerequisites paragraph names them.

**Who runs it** (README, `docs/reference.md`, script header): the orchestrator or the human, never
the unit's own session — a session whose worktree is removed under it keeps running plugin hooks,
which then write into a deleted path or fall back to the main checkout (board 2026-10-22 17:40).

**Ships:** no. AGENTS.md Boundaries gains the script (reads; in both modes creates and removes its
lock directory under the git common dir; with `--remove` removes only reported worktrees and local
branches and writes `<main>/.context/archive-worktree-*`), and the battery, the lint
row and CI gain its shellcheck and suite.

## 3. Case 2 — long runs

Plan bullet (template and repo `CLAUDE.md` §4), inside the long-run parenthesis: `(its name, what it
proves, an estimated duration and how often it runs; a time limit per stage, cleanup of its helper
processes on any exit, and, where stages are independent, every failure recorded in one run;
evidence run on the final head counts in the unit that runs it)`. `docs/coding-workflow.md` gets the
same three items where it lists the long runs, with the three field cases as the why. **Conditions
accounting:** every existing item of that parenthesis is kept; three are added.

## 4. Case 3 — Codex preflight

`CLAUDE.md` §5, template and repo, after the bold first paragraph: **Before the session's first Codex
call,** run `echo $CODEX_HOME` (empty means the default home, `~/.codex`) and `codex exec
--skip-git-repo-check "Reply with OK" </dev/null` in this session, giving the probe at most two
minutes (the Bash call's timeout). Success is exit 0 with a reply holding `OK`. A reply naming a usage
limit or an authentication failure is missing access, a stop in §4: stop and tell the human, quoting
it and naming that home. Anything else (`codex` not found, a non-zero exit without such a message, an
empty reply, no answer in time) is undetermined: say so with the output and go on; a gate call that
then fails with an empty error follows the hook's recovery for it (probe again, one retry). Why: an account at its limit
showed only as empty gate failures, and another session may use another account.
**Invariant 5 (P6) does not apply:** P6 names `/workflow-init` Step 1's Codex-preflight health
commands, `claude mcp list` and `claude mcp get codex` (`workflow-init.md`, Step 1, "One exception to
running it"), which start every Claude Code MCP server. The probe starts Codex from the user's own
configuration exactly as each gate call does (the Codex MCP server's `exec` tool invokes the same
CLI under the same home), so it adds no launch path the gates do not already take. `docs/reference.md` § Hook messages points to it. **Not done:** no rules-file bytes; the hook's
failure message stays (it already names the same probe for an empty error).
Codex CLI: Context7 `/openai/codex/rust-v0.155.1` (newest
version it holds) documents the git-repository check and its skip option and `CODEX_HOME` defaulting to
`~/.codex`; the local `codex-cli` is 0.162.1, not indexed, so `codex exec --help` there (it lists
`--skip-git-repo-check`) is the Library APIs fallback.

## 5. Case 4 — skip prefixes

2.21's question becomes: ask which folders hold only dated or historical records (old plans,
reviews, handovers, reports, archives, replays), e.g. `docs/history/`, `docs/archive/`,
`docs/superpowers/replays/`. A folder that also holds current specs, plans or feature docs is not a
skip prefix (`docs/superpowers/` holds current specs; skipping it hides their broken links): name
its dated subfolder instead, or none. The rest of 2.21 (the prefix pattern, the why) stays. The
script itself does not change, so check 4l stays green.

## 6. Docs

README (cleanup usage, who runs it), `docs/reference.md` (cleanup section; preflight pointer; the
Living docs paragraph that describes 2.21's skip question),
`docs/ARCHITECTURE.md` (tree, scripts inventory), AGENTS.md Boundaries and § Commands rows,
`docs/coding-workflow.md`, `plugins/dev-workflow/CHANGELOG.md`, `todos.md`.

## 7. Plan

Handover boundary: the merged PR. No run of 45 minutes or more (battery about 15 min with both hook
suites; prompt eval once, about 10 min). Sources and impact boundary: `scripts/` (new script and
suite, modelled on `check-doc-links.test.sh`'s fixture repos), `.github/workflows/ci.yml`,
`workflow-init.md` (`### 2.1` template §4 and §5, `### 2.21` prose), repo `CLAUDE.md`, AGENTS.md,
the docs in §6. Library APIs: `gh pr list` (`--state merged`, `--head`, `--json number,headRefOid`,
`--limit`, `-R [HOST/]OWNER/REPO`) — Context7 `/websites/cli_github_manual` (unversioned: it lists those flags and
fields), so the version check is the Library APIs fallback: `gh pr list --help` on the local `gh`
2.96.0 shows the same flags; `-R` with the host is what binds the repository (gh's override takes the
default host when none is given, so the host is spelled out). git (local 2.52.0): `git worktree list --porcelain` and its `bare` /
`locked` / `detached` lines from the local `git worktree --help`; `git update-ref -d <ref> <oldvalue>`
and `git status --ignored=matching` from the local `git help`. lsof (local revision 4.91): `-F n`
field output, `-d cwd`, `-w` from its man page. Context7 does not hold git or lsof by version; the
local manuals are the fallback. Outside the repository: the prompt eval (paid, about $2), authorized
by the brief; nothing else.

1. **Script, test first.** Fixture: a bare origin, a clone, worktrees under `.claude/worktrees/`, a
   PATH with stub `gh` and `lsof`. Cases and expected results: ancestor-merged clean worktree →
   `removable`, and `--remove` removes it, archives its `.context/` and deletes its branch; tip equals
   stub PR head → `pr#7` `removable`, and the stub saw `-R github.com/<owner>/<repo>` and `--base
   main` with `GH_REPO` and `GH_HOST` set to another repository and host; stub PR head differs → `no`; stub returns 100 rows →
   `unknown`; `gh` missing → `unknown`, kept; dirty (untracked file) → kept; an ignored file outside
   `.context/` → kept, and removable with `--discard-ignored`; stub `lsof` shows a cwd inside →
   `session=yes`, kept; `lsof` missing, exiting 1, or printing no `n/` line → `unknown`, kept; worktree
   outside the roots → kept, even with `--remove`; its parent passed as `--root` → removable; the
   worktree path itself passed as `--root` → kept; symlinked root escape → kept; locked → kept;
   detached → kept; `.gitmodules` present → kept; merged branch without worktree → removable and
   deleted; unmerged branch → kept; report mode leaves `git worktree list`, `git branch` and the
   archive directory unchanged; a session appearing between report and removal (a stub that answers
   differently on its second call) → `skipped`; a worktree's tip moved between report and recheck →
   `skipped`, worktree and branch stay; a branch-only row whose ref moves between report and
   removal (a stub `lsof`, called once per run before the branch rows, moves it) → `failed` from
   `update-ref`, new ref kept; `git status` failing in a worktree (a `.git` file pointing nowhere) →
   `dirty=unknown`, `ignored=unknown`, kept, no destructive step for it; status failing only at the
   recheck (a stub `lsof` that breaks the worktree's `.git` file on its second call) → `skipped`; an existing archive directory → the `-2` suffix; a main checkout
   without `.context/` → created, archive written; an unreadable file in `<wt>/.context/` (cp fails) →
   `failed`, worktree and branch stay, and the next removable row is still removed with exit 1; the
   lock held → exit 1 and the stale-lock message; a bare repository and a usage error → exit 2. → verify: suite under `sh` and `dash`,
   shellcheck `--shell=sh`.
2. **Battery wiring**: AGENTS.md quality and lint rows, prerequisites paragraph, CI steps. → verify:
   run the quality row.
3. **Template and repo `CLAUDE.md`** (§4 clause, §5 preflight). → verify: checks 4e, 4g; then read the
   changed template text against all 12 items of `docs/prompt-standards.md` and record the result per
   item in the PR body. Scenario check: walk the preflight sentence through its replies (`OK` with exit 0,
   `OK` with a non-zero exit, a usage-limit message, an authentication error, `command not found`,
   empty, a timeout) and the long-run clause through the three field
   cases, and note the action each yields. The prompt eval's seven cases do not cover these texts; it
   runs as the regression check for the rest.
4. **2.21 prose.** → verify: check 4l, `check-doc-links.sh`, the same 12-item read.
5. **Docs** per §6. → verify: doc links.
6. **Prompt eval once, then version 0.44.0**, battery. → verify: battery exit 0.
