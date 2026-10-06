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
change a working tool's contract and suite for no gain here. The status view reuses run-analytics',
ledger-metrics' and loop-usefulness' functions instead (§4, §5), loaded the way
`scripts/live-effort.py` loads them, so a call and a cycle are read the same way in all reports.

**The governing rule of every section: an observation is shown as what it is.** A file, a commit,
a record or a log entry establishes that it exists and when; it does not establish that work is
running. Where the sources cannot establish a value, the page says `unknown` and why.

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
- **One writer.** A running invocation holds an exclusive lock on its status directory for its
  whole life. A second invocation — a second watcher or a one-shot run beside a watcher — does not
  write; it exits non-zero, naming the cause. So a page and cache always belong to one process with
  one baseline.
- Requirements as the other reports: Python 3.8+, git 2.36+, standard library only, no model call
  (story `AC-9`).

## §2 Freshness, consistency and failure (story `AC-8`, `AC-9`)

- The page shows its **generation time** and, per source, the **as-of time** of the data it shows
  (for a file: its modification time or commit; for a log: the newest entry read). The two are
  never merged into one time.
- Each source has a state: `ok`, `missing` (the source does not exist), `stale` (a previous value
  kept after an incomplete or failed read) or `error` (no value, with the cause). A stale value
  keeps its original as-of time and shows when and why the refresh failed.
- **A refresh of a source succeeds only when it is complete.** A read that raises, an unreadable
  file, a malformed line other than a trailing line still being written, or a directory that could
  not be fully listed makes that refresh incomplete: the previous facts for the affected files are
  kept and marked `stale`. A trailing partial line is not an error; it is read once the file has
  grown past it. A file is dropped from the cache only when its own lookup reports that it no
  longer exists — never because it is absent from a listing that failed.
- In watch mode a failed collection of one source keeps that source's last successful value; the
  rest of the page updates. If the whole collection fails, the previous page stays in place and a
  failure banner with the time and the cause is added to it.
- **Checkout consistency.** Each collection reads `HEAD` once and pins every git read of that
  collection to that commit; the page names that commit. If the branch or `HEAD` changes while one
  collection runs, that collection is discarded and the next interval collects again. If the
  branch differs from the one at process start, the page marks this visibly — "branch changed since
  monitor start (was X); baseline still the one chosen at start" — and keeps the baseline, so a
  restart is the way to a new one.
- The page checks its own age in the browser: when the generation time is older than three
  intervals, it shows "stale: no successful refresh observed within three intervals", with the
  last success and last failure times. It claims nothing about whether the process still runs. A
  page from a one-shot run shows no reload and no such check, only its generation time.
- Re-rendering never refreshes an as-of time. Only a successful read of the source does.

## §3 Baseline (story `AC-5`)

- Default: `git merge-base HEAD main`. `--base <commit>` overrides it.
- The baseline commit is resolved **once at process start** and held for the life of a watch
  process, so a moving `main` does not shift the figures silently. The page shows the full commit
  name and how it was chosen (`merge-base with main` or `--base`).
- The growth section is labelled as a **branch comparison against that commit**, not the effort or
  growth of a single story.
- **No baseline** (no `main`, unrelated histories, shallow clone, or a `--base` that does not
  resolve): the page shows the reason. Only what depends on the baseline is unavailable — net
  change per file, the branch's changed artifacts, records in the range, and branch attribution of
  effort; each shows "unavailable: no baseline (reason)". Current file sizes, the handover, open
  cycles' calls, and the version section are still shown. There is no search for a story's first
  commit.

## §4 Effort and incremental reading (story `AC-4`, `AC-9`, `AC-10`)

**Sources.** The same as run-analytics and live-effort: Claude Code transcripts under
`~/.claude/projects/` and Codex session logs under `~/.codex/sessions/`, measured with
run-analytics' functions. The store `.context/telemetry/gate-calls.jsonl` is **not** read, so an
old store cannot look current. Like live-effort, the scope is the repository (every worktree
sharing its git directory), and the page says so; calls are not attributed to one checkout.

**Incremental.** The cache records, per source file, its size and modification time and the facts
extracted from it. On each collection only new files and files whose size or modification time
changed are read again, in full; unchanged files are taken from the cache. Re-reading a changed file
in full covers a log that grew and a pending call whose result arrived later. Every listed file is
still looked up; what is avoided is re-reading unchanged content. Commit bodies are read for the
range baseline..`HEAD` only, never the whole history. The page footer states how many files were
read in this collection and how many came from the cache.

**What the cache may hold — an allowlist.** Raw tool inputs and raw results stay in memory during a
read and are never written. The cache holds only: call ID, tool, review type, start and result
times, whether a result was observed, the slot names and session IDs derived from the call, the
call's working directory (a path, needed for repository membership), the success flag, model
identifiers, token counts, and per Codex log its session ID, timestamps and token and model facts.
The projection is applied to nested values too: token facts keep only the token keys run-analytics
measures, each a validated number or `unknown`; a model identifier is kept only when it matches
run-analytics' bounded identifier pattern (`RE_MODEL`), otherwise it is written `undetermined`
(the curve grammar is not that test: it also admits quoted free text); every other field is dropped
before anything is written. Per Claude Code transcript the cache may also hold, beside its
calls: its session ID, the time of its latest entry, its load observations (§7) as component,
version and time, and the working directories (`cwd`) its entries record. A session without gate
calls belongs to this repository when one of those working directories lies in a checkout sharing
this repository's git common directory — the same membership test live-effort applies to a call's
working directory, re-evaluated at every collection. These are what §5 and §7 need, so they survive a restart without re-reading an
unchanged transcript. Where run-analytics only offers whole-tree scans (`scan_transcripts`,
`scan_codex`), the plan adds a per-file function to run-analytics that those scans then call; that
is the only permitted change to run-analytics, and its output and suite stay unchanged. The
projection to the allowlist happens in the status view. The cross-file rule run-analytics applies
(the first occurrence of a call that has a result supplies its values) is applied the same way.
**Only per-file facts are cached, never a measurement.** Every collection recomputes every call's
measurement, its repository membership (from the cached working directory against the current git
common directory, as live-effort does) and every cycle from the full set of facts, so a change in
one file — a late Codex log, a resume of the same Codex session found in another transcript — reaches
every call it affects.

**Calls without a result.** A call whose result has not been observed is shown as "no result
observed since <time>", however old it is. The six-hour transition run-analytics applies is not
used for this display; run-analytics' own output is unchanged. "No result observed" makes no claim
that the call is still running.

**Cycles.** A cycle is identified by its nonce (from slot names). Its state comes from the records
in baseline..`HEAD`, read with ledger-metrics' parser and classified with loop-usefulness'
`classify`, mapped as follows: `closed` and `skipped` as they are; `conflicting` with its reason;
`open` with the reason "conflicting provenance lines" is shown as `conflicting` with that reason;
any other `open` as "curve without provenance line". loop-usefulness itself is not changed. A nonce with calls but no record in the range is shown as "no closing
record observed in this range" — never as proven open — and only when its first call is later than
the baseline commit's time; older calls without a record are not shown. Calls with no nonce are
listed as unattributed. **Without a baseline** (§3) there is no range and no cutoff: calls from the
last 24 hours, the window live-effort uses for calls with no cycle, are shown grouped by nonce with
closure and branch attribution "unavailable: no baseline", nonce-bearing and nonce-less alike. A
call without an observed result is shown regardless of age in every case, baseline or not; the
24-hour window applies only to calls that have a result.

**Shown, each figure separately:** gate calls; observed call slots (attempts, including incomplete
ones); valid passes, taken only from a closing curve and labelled as the author's self-reported
count, otherwise "validity unknown"; tokens in, cached, out and reasoning; summed call duration;
elapsed time of a cycle without a closing record (now minus its first call). Session run time is
not recorded anywhere and is shown as `unknown`. A figure that cannot be measured is `unknown`,
never 0. No composite score and no completion percentage anywhere on the page (`AC-7`).

## §5 Current work, progress and open points (story `AC-1`–`AC-3`)

**Current task.** The page never states the current task as established; it shows candidates,
each with its source and date: the stories this branch changes against the baseline; the stories
cited in provenance lines in the range; and the body of the newest handover's next-task section
(the section whose heading starts with "Next"), shown verbatim as a task description. When the
story candidates name exactly one story, it is shown as "inferred current story (only candidate;
last evidence <date>)"; otherwise "current task not established", with the candidates. Nothing is
chosen by recency alone, and a handover description is linked to a story only where it names that
story's path.

**Current work** also shows the checkout root (the resolved top-level directory of the checkout
the page describes), branch, `HEAD`, the number of uncommitted paths, and the specs and plans
this branch changes. Per story, a **last evidenced phase**, derived only from evidence associated
with that story, each with its source commit:

| Evidence | Phase shown |
|---|---|
| story committed on this branch | story |
| spec citing it committed | spec written |
| a `closed` Gate-A spec cycle citing it | spec reviewed |
| plan citing it committed | plan written |
| a `closed` Gate-A plan cycle citing it | plan reviewed |
| a `closed` Gate-B cycle citing it | Gate B closed |
| a `skipped` cycle citing it | "<cycle kind> skipped (reason in commit <sha>)" — never "reviewed" or "closed" |

A record is associated with a story through the story set in its provenance line, and an artifact
through its `**Story:**` header. Evidence that names no story, or a different one, is shown
separately as unassociated. Only `closed` and `skipped` cycles advance a phase, each with its own label; `open` and
`conflicting` cycles are shown with their state and never as a phase.

Observations that are **not** phases and **not** current activity are shown as observations with
their time: a `WIP:` commit ("Gate-B snapshot at <time>; review state unknown"), a call without a
result ("no result observed since <time>"), and the time of the last transcript entry for this
project. Files alone show the documentation state: the page says, for example, "plan present; last
evidenced phase: plan reviewed; current activity unknown". Without stronger evidence, current
activity is `unknown`.

**Evidenced progress.** The last `closed` or `skipped` cycle with its records and commit, and the
last commit. A step with no record, or with only `open` or `conflicting` records, is not shown as
closed (`AC-2`).

**Open points.** Collected, each with its source path and revision (a commit, or `uncommitted`):
- the newest `.context/handover-*.md`: the sections whose heading contains `open`, `unresolved`,
  `blocker` or `wait` (case-insensitive), shown verbatim;
- §5 "Open questions" of the stories this branch changes, verbatim, so an answer recorded in that
  section is shown with it;
- `**Unaccounted:**` lines in artifacts this branch changes;
- cycles without a closing record in the range, and `conflicting` cycles.

A source that explicitly says none is shown as "source states none". When no source can be read,
the section says `unknown`, never "none" (`AC-3`).

## §6 Artifact growth (story `AC-5`)

The baseline tree against the current files of the named checkout root, including uncommitted
changes and untracked, non-ignored files; `.context/` is excluded. The checkout root is shown here
and kept apart from the repository-wide scope of the effort section. Per file: status (added, modified, deleted), bytes and
lines at the baseline and now, and the net change; shrinking and deletion are shown like growth.
Without a baseline, current sizes are shown and the net change is unavailable (§3). Groups:

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

The first matching row decides. Handovers (`.context/handover-*.md`) are not in git and have no
baseline commit. They are listed separately: current size, lines and modification time, and the
change since this status directory first observed each one (its size at that first observation is
kept in the cache), labelled "change since first observed at <time> — not the branch baseline". A
handover that disappears stays listed as deleted with its last observed size. A handover first seen
in the current collection shows "first observed now".

## §7 Workflow version (story `AC-6`)

Shown separately, never merged:
- **installed:** `~/.claude/plugins/installed_plugins.json`, every record under
  `dev-workflow@dev-workflow-kit` with its scope, version, last update and commit. A record applies
  when its scope is `user`, or when it is a project-scoped record for this repository. Exactly one
  applying record is the installed version; several, or none, are shown as "ambiguous" or
  `unknown`. An unrecognized file shape is `unknown`.
- **loaded:** per Claude Code session of this project, the versions in versioned plugin paths
  (`…/plugins/cache/dev-workflow-kit/dev-workflow/<version>/…`) that occur in **harness-generated
  load events only** — such as the meta entry a skill load writes ("Base directory for this
  skill: …"). A path in user or assistant text, in a tool input or in a tool result is a mention,
  not a load, and does not count. The plan establishes, from real transcripts, which event kinds
  qualify; only those count. Each observation keeps its component (which skill, command or hook)
  and its time. One version observed → that version for the component, with its time; several
  versions in one session → "conflicting"; none → `unknown`.
- **declared:** `plugins/dev-workflow/.claude-plugin/plugin.json` at `HEAD`, and in the working tree
  when it differs;
- **rule revision:** for `CLAUDE.md`, `AGENTS.md` and `.claude/review-gates.md`, the last commit
  that changed each, and whether it has uncommitted changes.

The rule state on disk is never presented as the state a running session loaded. Disagreements
(installed ≠ declared, a recent session's loaded ≠ installed, uncommitted rule changes) are
visibly marked.

## §8 Safety (story `AC-10`)

- The script writes only under `.context/status/`. It changes no record it reads.
- No session text reaches the page or the cache: only the allowlisted facts (§4) and versions,
  times, counts, identifiers and short session IDs. Repository files (handover, stories) are
  repository content and may be shown.
- Every string taken from a file is HTML-escaped. The page loads nothing external.

## §9 Verification (validation mode `battery+check`)

**Suite:** `scripts/status-view.test.sh`, in the style of the existing report suites (fixture repo
plus fixture home, expected output, a read-only snapshot check). Each case must fail without the
behaviour it covers. Cases:

1. A plan without later evidence shows "current activity unknown" and the last evidenced phase.
2. A `WIP:` commit with no review, and a call without a result, are shown as observations; neither
   becomes a phase or current activity.
3. Cycle states: a closed cycle advances the phase; an ordinary skip shows its skipped label; a
   curve without provenance, one curve with two distinct provenance lines, two conflicting curves
   and a skip beside a curve do not advance it, and show their state.
4. Several candidate stories → "current task not established" with the candidates; one candidate →
   "inferred"; the handover's next-task body is shown as a description; evidence for another story
   is shown as unassociated.
5. No open-point source readable → `unknown`; a handover that says none → "source states none".
6. Growth: added, modified, shrunk, deleted, untracked and uncommitted files, with code and tests
   apart, under the named checkout root; a handover that grows, shrinks or disappears shows its change since first observed.
7. No merge-base → the reason is shown, current sizes stay, net change and range items show
   "unavailable", recent nonce-bearing and nonce-less calls stay visible, and so does a call without a result older
than 24 hours; `--base` fills them.
8. Watch mode keeps the baseline when `main` moves between two collections, and marks a branch
   change.
9. Incremental: an unchanged file is not read again, and after a restart with unchanged
   transcripts the loaded versions and last activity are still shown — for a session of this
   repository without gate calls, and not for one of another repository; a grown transcript whose pending call received
   its result shows the result; a call older than six hours without a result is still shown; a
   deleted file drops out; a late Codex log fills an unchanged completed call's tokens; a resume
   found in another transcript makes an earlier call's tokens shared and so `unknown`.
10. Incomplete reads: an unreadable file, a malformed line and a failed listing keep the previous
    facts marked `stale` with their original as-of time; a trailing partial line is not an error.
11. Valid passes: an `INCOMPLETE` reply's slot counts as an attempt, not a valid pass.
12. Marker strings placed in a tool input, a tool result, ordinary transcript text, an extra nested
    token field and a free-text model value, bare or quoted, in a Codex log never appear in the page or the cache.
13. Loaded version: a versioned path in user text or a tool result does not count; two versions in
    one session show "conflicting".
14. Installed version: several applying records show "ambiguous".
15. A second invocation while one holds the lock writes nothing and exits non-zero.
16. The page contains no percentage of completion and no composite score.
17. Installed, loaded, declared and rule revision show separately; a mismatch and an uncommitted
    rule file are marked.
18. The script writes nothing outside `.context/status/`.

**Real run (story `AC-12`):** on this branch, the page is generated before and after a commit that
closes a step, and the evidenced change and the growth are visible after the refresh. The evidence
entry names both runs.

**Battery and docs.** The suite joins the quality battery. `AGENTS.md` gains the new report in the
layout tree and in Boundaries — including that it writes only under `.context/status/` — the
updated count of Python reports, its git 2.36 and Python 3.8 requirement in `## Commands`, and the
suite in the quality and lint rows; the typecheck row's count of untyped Python reports is updated;
`.github/workflows/ci.yml` runs the suite. If run-analytics gains a per-file function (§4), its own
suite must pass unchanged.
