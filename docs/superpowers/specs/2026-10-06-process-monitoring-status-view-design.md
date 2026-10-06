# Process monitoring — generated status view — design

**Story:** `docs/superpowers/stories/2026-10-06-process-monitoring-status-view-story.md` — read the profile from its header at every gate call.

## §0 Scope

**What it is.** A new repo-local report, `scripts/status-view.py`, that generates one HTML page
about the work in this repository: current work, evidenced progress, open points, effort,
artifact growth and workflow version. It runs once, or as a manually started watch process that
regenerates the page at a fixed interval. It ships nothing in the plugin, so invariant 12 does not
apply. Decisions taken with Daniel on 2026-10-06 (brainstorming): watch mode plus a one-shot run;
merge-base with `main` as the default baseline; the rules in §2–§8.

**Out of scope** (story `AC-11`): orchestrator, agent control, automatic stops, new gate rules,
full cost accounting, human-attention metrics, the decision inbox, a second dashboard entry or
status mechanism, a permanently installed service, automatic detection of a story's first commit.

**Why a new script and not a change to `scripts/run-analytics.py`.** run-analytics is the one
writer of `.context/telemetry/` and rescans every source on each run. Making it incremental would
change a working tool's contract and suite for no gain here. The status view reuses run-analytics'
and ledger-metrics' parsing functions instead (§4), loaded the way `scripts/live-effort.py` loads
them, so a call is measured the same way in all three reports.

## §1 Interface

```
python3 -B scripts/status-view.py [--base <commit>] [--watch <seconds>]
```

- Without `--watch`: collect once, write the page, exit 0 on success, non-zero with the cause on
  stderr when no page could be written.
- With `--watch N` (N ≥ 5): collect and write every N seconds until interrupted. The page then
  carries an automatic browser reload at the same interval. Nothing is installed or registered;
  stopping the process stops the monitor.
- Output: `.context/status/index.html`, plus the script's own cache in `.context/status/`.
  `.context/*` is already git-ignored. Every write of the page is atomic (write to a temporary file
  in the same directory, then rename), so a reader never sees a half-written page.
- Requirements as the other reports: Python 3.8+, git 2.36+, standard library only, no model call
  (story `AC-9`).

## §2 Freshness and failure (story `AC-8`, `AC-9`)

- The page shows its **generation time** and, per source, the **as-of time** of the data it shows
  (for a file: its modification time or commit; for a log: the newest entry read). The two are
  never merged into one time.
- Each source has a state: `ok`, `missing` (the source does not exist), `stale` (a previous value
  kept after a failed read) or `error` (no value, with the cause). A stale value keeps its original
  as-of time and shows when and why the refresh failed.
- In watch mode a failed collection of one source keeps that source's last successful value,
  marked `stale`; the rest of the page updates. If the whole collection fails, the previous page
  stays in place and a failure banner with the time and the cause is added to it.
- The page checks its own age in the browser: when the generation time is older than three
  intervals, it shows "stale — monitor not running". A page from a one-shot run shows no reload and
  no such check, only its generation time.
- Re-rendering never refreshes an as-of time. Only a successful read of the source does.

## §3 Baseline (story `AC-5`)

- Default: `git merge-base HEAD main`. `--base <commit>` overrides it.
- The baseline commit is resolved **once at process start** and held for the life of a watch
  process, so a moving `main` does not shift the figures silently. The page shows the full commit
  name and how it was chosen (`merge-base with main` or `--base`).
- When no merge-base can be determined (no `main`, unrelated histories, shallow clone), the page
  shows the reason, and growth stays empty until `--base` is given. There is no search for a story's
  first commit.
- The growth section is labelled as a **branch comparison against that commit**, not the effort or
  growth of a single story.

## §4 Effort and incremental reading (story `AC-4`, `AC-9`, `AC-10`)

**Sources.** The same as run-analytics and live-effort: Claude Code transcripts under
`~/.claude/projects/` and Codex session logs under `~/.codex/sessions/`, measured with
run-analytics' functions. The store `.context/telemetry/gate-calls.jsonl` is **not** read, so an
old store cannot look current.

**Incremental.** The cache records, per source file, its size and modification time and what the
script extracted from it (gate-call uses and results; for a Codex log, its session and the facts
run-analytics derives). On each collection only new files and files whose size or modification
time changed are read again, in full; unchanged files are taken from the cache; vanished files are
dropped. Re-reading a changed file in full covers a log that grew and a pending call whose result
arrived later. Every file a collection lists is still stat'ed; what is avoided is re-reading
unchanged content. Commit bodies are read for the range baseline..`HEAD` only, never the whole
history; a call whose cycle is not recorded in that range is shown as unattributed rather than
looked up elsewhere. The page footer states how many files were read in this collection and how many
came from the cache.

**Reuse.** Where run-analytics only offers whole-tree scans (`scan_transcripts`, `scan_codex`), the
plan adds a per-file function to run-analytics that those scans then call. That is the only
permitted change to run-analytics: its output and its suite stay unchanged. The cross-file rule
run-analytics applies (the first occurrence of a call that has a result supplies its values) is
applied the same way to the cached per-file results.

**Shown, each figure separately:** gate calls; review passes (from slot names); tokens in, cached,
out and reasoning; summed call duration; elapsed time of each open cycle (now minus its first call).
Scope: calls of open cycles and calls attributable to commits on this branch since the baseline.
Session run time is not recorded anywhere and is shown as `unknown`. A figure that cannot be
measured is `unknown`, never 0. No composite score and no completion percentage anywhere on the
page (`AC-7`).

## §5 Current work, progress and open points (story `AC-1`–`AC-3`)

**Current work.** Branch, `HEAD`, the number of uncommitted paths, and the stories, specs and plans
this branch changes against the baseline. The **last evidenced phase** is derived only from
evidence, each with its source commit:

| Evidence | Phase shown |
|---|---|
| story committed on this branch | story |
| spec committed | spec written |
| Gate-A spec record (provenance line + curve) in a commit body | spec reviewed |
| plan committed | plan written |
| Gate-A plan record | plan reviewed |
| a `WIP:` commit | Gate B running |
| Gate-B record | Gate B closed |

Files alone show the documentation state, not the current activity. The page therefore says, for
example, "plan present; last evidenced phase: plan reviewed; current activity unknown". The only
activity it shows is evidenced: the time of the last transcript entry for this project and any
gate call still pending.

**Evidenced progress.** The last closed review cycle (its records and commit) and the last commit.
A step with no record is not shown as closed (`AC-2`).

**Open points.** Collected, each with its source path and revision (a commit, or `uncommitted`):
- the newest `.context/handover-*.md`: the sections whose heading contains `open`, `unresolved`,
  `blocker` or `wait` (case-insensitive), shown verbatim;
- §5 "Open questions" of the stories this branch changes;
- `**Unaccounted:**` lines in artifacts this branch changes;
- open review cycles (a cycle with calls and no closing record).

A source that explicitly says none is shown as "source states none". When no source can be read,
the section says `unknown`, never "none" (`AC-3`).

## §6 Artifact growth (story `AC-5`)

The baseline tree against the current files, including uncommitted changes and untracked,
non-ignored files; `.context/` is excluded. Per file: status (added, modified, deleted), bytes and
lines at the baseline and now, and the net change; shrinking and deletion are shown like growth.
Groups:

| Group | Paths |
|---|---|
| stories | `docs/superpowers/stories/**` |
| specs | `docs/superpowers/specs/**` |
| plans | `docs/superpowers/plans/**` |
| rule files | `CLAUDE.md`, `AGENTS.md`, `.claude/**` |
| prompts | `plugins/**/*.md` |
| tests | `*.test.sh`, `plugins/**/fixtures/**` |
| code | other files under `scripts/` and `plugins/` |
| other | everything else |

The first matching row decides. Handovers (`.context/handover-*.md`) are not in git, so they are
listed separately with their current size and modification time and "no baseline".

## §7 Workflow version (story `AC-6`)

Shown separately, never merged:
- **installed:** `~/.claude/plugins/installed_plugins.json`, entry `dev-workflow@dev-workflow-kit`:
  version, last update, commit;
- **loaded:** per Claude Code session of this project, the version in the newest versioned plugin
  path its transcript records (`…/plugins/cache/dev-workflow-kit/dev-workflow/<version>/…`), with
  the session's last activity time. A session that invoked no plugin skill, command or hook path
  shows `unknown`;
- **declared:** `plugins/dev-workflow/.claude-plugin/plugin.json` at `HEAD`, and in the working tree
  when it differs;
- **rule revision:** for `CLAUDE.md`, `AGENTS.md` and `.claude/review-gates.md`, the last commit
  that changed each, and whether it has uncommitted changes.

The rule state on disk is never presented as the state a running session loaded. Disagreements
(installed ≠ declared, a recent session's loaded ≠ installed, uncommitted rule changes) are
visibly marked.

## §8 Safety (story `AC-10`)

- The script writes only under `.context/status/`. It changes no record it reads.
- No session text reaches the page or the cache: only versions, times, counts, identifiers and
  short session IDs. Repository files (handover, stories) are repository content and may be shown.
- Every string taken from a file is HTML-escaped. The page loads nothing external.

## §9 Verification (validation mode `battery+check`)

**Suite:** `scripts/status-view.test.sh`, in the style of the existing report suites (fixture repo
plus fixture home, expected output, a read-only snapshot check). Each case must fail without the
behaviour it covers. Cases:

1. A plan without later evidence shows "current activity unknown" and the last evidenced phase.
2. No open-point source readable → `unknown`; a handover that says none → "source states none".
3. Growth: added, modified, shrunk, deleted, untracked and uncommitted files, with code and tests
   apart.
4. No merge-base → the reason is shown and growth is empty; `--base` fills it.
5. Watch mode keeps the baseline when `main` moves between two collections.
6. Incremental: an unchanged file is not read again; a grown transcript whose pending call received
   its result shows the result; a deleted file drops out.
7. A failed source read keeps the previous value marked `stale` with its original as-of time.
8. A marker string placed in transcript text never appears in the page or the cache.
9. The page contains no percentage of completion and no composite score.
10. Installed, loaded, declared and rule revision show separately; a mismatch and an uncommitted
    rule file are marked.
11. The script writes nothing outside `.context/status/`.

**Real run (story `AC-12`):** on this branch, the page is generated before and after a commit that
closes a step, and the evidenced change and the growth are visible after the refresh. The evidence
entry names both runs.

**Battery.** The suite joins the quality battery: `AGENTS.md` (layout tree, the Boundaries count of
Python reports, `## Commands`) and `.github/workflows/ci.yml` gain it, and the typecheck row's
count of untyped Python reports is updated. If run-analytics gains a per-file function (§4), its
own suite must pass unchanged.
