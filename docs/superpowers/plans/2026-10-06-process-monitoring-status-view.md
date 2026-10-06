# Process monitoring — generated status view — Implementation Plan

**Story:** `docs/superpowers/stories/2026-10-06-process-monitoring-status-view-story.md` (read its profile fresh)
**Spec:** `docs/superpowers/specs/2026-10-06-process-monitoring-status-view-design.md` (Gate-A spec cycle `zz66702iyt` closed at `b1f76f1`)

**Plan form.** Compact, per `CLAUDE.md` §4 "Spec, plan and code", which outranks `writing-plans`
where they differ: each task states its outcome, files and reuse, prerequisites and settled
decisions, test situations with expected outcomes, and the implementer's decision space. No
function bodies or complete test code. Execution: Native (this session), then Gate B.

**Goal.** `scripts/status-view.py` and its suite, as the spec defines them, plus the battery and
documentation entries that make the new report part of this repository.

**Sources and impact boundary.** Read: the story and spec; `CLAUDE.md` §4; `AGENTS.md`
(Architecture, Boundaries, Commands, invariants 5 and 12, Don'ts); `scripts/run-analytics.py`
(sources, `scan_transcripts`, `scan_codex`, `read_lines`, `build_record`, `measure_tokens`,
`RE_MODEL`, `cycles_from_history`); `scripts/live-effort.py` (loader, membership, window);
`scripts/ledger-metrics.py` (`parse_record`, `read_commits`); `scripts/loop-usefulness.py`
(`classify`, `read_records`); `scripts/live-effort.test.sh` and `scripts/run-analytics.test.sh`
(fixture style); `.github/workflows/ci.yml`; `README.md` (where it lists the reports);
`~/.claude/plugins/installed_plugins.json` (shape: `{"version", "plugins": {name: [records with
scope, version, lastUpdated, gitCommitSha, installPath, installedAt]}}`); a read-only probe of local
transcripts (below). Impact ends at: the new script and suite, a per-file seam in
`scripts/run-analytics.py`, `AGENTS.md`, `ci.yml`, `README.md`, and `.context/status/` at run
time. Not touched: the plugin (no version bump), hooks, the other reports' behaviour, any store.

**Resolved uncertainty — which transcript events are load evidence (spec §7).** A read-only probe
of all local transcripts (2026-10-06) found versioned plugin paths in: `type: user` entries with
`isMeta: true` whose text starts "Base directory for this skill:" (13), and `type: attachment`
entries whose `attachment.type` is `invoked_skills` (11) — both harness-written, both for skills;
and otherwise only in assistant tool uses, tool results, user text and queue operations, which are
mentions. No harness event recorded a command's or a hook's versioned path. So **only those two
skill-load event kinds count**; commands and hooks show `unknown` as their loaded version. On
`cwd`: the probe's first count sampled only lines it pre-filtered (23,895 of 23,900 carried
`cwd`); the Gate-A plan review's full read-only scan of the same surface counted 673,347 entries,
487,291 of them with a string `cwd`. So `cwd` is common, not universal: a session whose entries
carry no member `cwd` is not counted as this repository's, and the corpus is large enough that the
first collection's full read is a real cost (Review focus 1).

**Collected Minor from Gate-A spec pass 6, decided here within spec §0 and §4:** a session's
latest-entry time is always shown as session-wide ("last entry in this session — may include work
in other repositories"). The cache holds only the latest-entry time spec §4 allows; no
per-directory time is kept.

**Global constraints.** Python 3.8+, git 2.36+, standard library only; no model call; writes only
under `.context/status/`, with containment checked before the first write (Task 2); `sys.dont_write_bytecode` set before other imports, as the other reports
do; every path and environment rule the other reports apply to git calls (`GIT_SELECTORS`,
`--no-replace-objects` or equivalent, signature display off) applies here too.

**Handover boundary.** The merged PR (completed story). If the session must end earlier, the
closed Gate-A plan cycle is the boundary; handover in `.context/handover-monitoring.md`, replaced
as a current summary.

---

### Task 1: Per-file seam in run-analytics

**Outcome.** run-analytics gains one function per source kind that extracts one file's facts —
for a transcript, its gate-call uses and results in the form `scan_transcripts` builds today; for a
Codex log, the fact `scan_codex` builds — and `scan_transcripts` / `scan_codex` call them. Output
and suite unchanged.
**Files.** `scripts/run-analytics.py`.
**Tests.** `sh scripts/run-analytics.test.sh` passes unchanged before and after; `live-effort` and
`loop-usefulness` suites too. No new run-analytics test: the seam adds no behaviour, and the
existing expected-text suite is the check that none changed.
**Decision space.** Function names and signatures; whether the first-session-id check moves into
the Codex per-file function. Not open: changing any output, the six-hour rule or the store.

### Task 2: Skeleton — CLI, lock, collection loop, page shell

**Outcome.** `python3 -B scripts/status-view.py [--base <commit>] [--watch <seconds>]` runs once
or in watch mode (N ≥ 5, else usage error), holds an exclusive lock on `.context/status/` for its
life, collects every section into a per-source state (`ok` / `missing` / `stale` / `error`, each
with its as-of time), and writes `index.html` atomically. In watch mode: the baseline is resolved
once at start; a source whose refresh is incomplete keeps its last value marked `stale`; a whole
failed collection keeps the previous page and adds a failure banner; each collection pins `HEAD`
once and is discarded if `HEAD` or the branch moves during it; a branch differing from the start
branch is marked. The page escapes every file-derived string, loads nothing external, shows
generation time and per-source as-of times, and in watch mode carries a reload and an age check
that shows "stale: no successful refresh observed within three intervals" with last success and
last failure. One-shot exit codes as spec §1.
**Files.** `scripts/status-view.py` (new), `scripts/status-view.test.sh` (new).
**Output containment.** Before the first write: `.context` and `.context/status` must be real
directories, not symlinks (created when absent); the lock, cache, temporary and page files are
opened relative to the status directory's descriptor without following symlinks, reusing the
directory-descriptor and no-follow approach run-analytics uses for its store where it fits. Any
violation → no write, non-zero exit naming the path.
**Reuse.** Loader pattern and git environment handling from `live-effort.py` / `loop-usefulness.py`;
run-analytics' store-opening approach.
**Tests (fixture repo + fixture home, expected text with times masked):**
- a second invocation while the lock is held → writes nothing, exits non-zero naming the lock (case 15);
- a forced failure of one source → that section `stale` with its original as-of time, others `ok`; a forced failure of the whole collection → previous page kept, banner added (spec §2, the source-failure and whole-collection-failure bullets);
- `HEAD` moved during a collection (through the suite's documented hook) → that collection is not published, the previous page stays, the next names one pinned commit (spec §2, checkout consistency);
- `.context` or `.context/status` a symlink, and a symlinked lock, cache or page file → nothing written, the outside targets unchanged, non-zero exit;
- page contains no completion percentage and no composite score (case 16);
- read-only snapshot: nothing outside `.context/status/` changes (case 18);
- a string with `<script>` in a repository file appears escaped.
**Decision space.** Internal module layout (one file, sections as functions), page markup and
styling, how a test forces a source failure (an environment hook used only by the suite is
acceptable if documented in the script header), cache file format.

### Task 3: Effort — incremental reading, cycles, calls

**Outcome.** Spec §4 entire: per-file cache keyed by path with size and mtime; only new and
changed files are re-read; deletion only on the file's own "does not exist"; incomplete reads keep
previous facts as `stale`; a trailing partial line is not an error. The cache holds only the
allowlisted facts, projected recursively (token keys validated, models through `RE_MODEL`, all
else dropped), plus per transcript its session ID, latest entry time (session-wide only), skill-load observations and `cwd` set. Every collection recomputes measurements,
membership and cycles from all cached facts. Cycles from records in baseline..`HEAD` via
`parse_record` and `classify`, with the spec's mapping (`open` + "conflicting provenance lines" →
`conflicting`). Display rules: no closing record in range → "no closing record observed in this
range", only when the first call is after the baseline commit time; calls without a result
always, "no result observed since <time>"; without a baseline, calls with a result from the last
24 hours. Figures shown separately; valid passes only from a closing curve, else "validity
unknown"; session run time `unknown`. Footer: files read vs from cache.
**Files.** `scripts/status-view.py`, `scripts/status-view.test.sh`.
**Reuse.** Task 1's per-file functions; `build_record`, `measure_tokens` (or the functions
live-effort uses for tokens and membership); `parse_record`; `classify`.
**Tests:**
- unchanged transcript not re-read (footer count); grown transcript's pending call shows its result; call older than 6 h without result still shown; deleted file drops out (case 9);
- late Codex log fills an unchanged completed call's tokens; a resume in another transcript makes the earlier call's tokens `unknown` (case 9);
- unreadable file, malformed line, failed listing → previous facts `stale`; trailing partial line → no error (case 10);
- `INCOMPLETE` reply's slot counts as an attempt, not a valid pass (case 11);
- markers in a tool input, a tool result, transcript text, an extra nested token field and a bare and a quoted free-text model value → absent from page and cache (case 12);
- a cache-only restart still shows loaded versions and last activity for a member session without gate calls, and not for another repository's session (case 9);
- a transcript spanning two repositories, and one whose latest entry has no `cwd` → its latest-entry time is labelled session-wide (collected Minor); a session with no member `cwd` is not shown as this repository's;
- no baseline → recent calls with a result and an old call without a result stay visible (case 7).
**Decision space.** Cache format and invalidation mechanics, how the suite counts re-reads, how
the session-wide label is worded.

### Task 4: Current work, progress, open points

**Outcome.** Spec §3 and §5: baseline resolution (merge-base with `main` or `--base`, held for the
process, reason shown when unavailable, only baseline-dependent items "unavailable"); checkout
root, branch, `HEAD`, uncommitted count; story candidates and the handover's next-task body,
"inferred current story (only candidate; last evidence <date>)" or "current task not
established"; per-story last evidenced phase from the table, skipped label, unassociated evidence
apart; observations (`WIP:` snapshot, no-result call, last entry) never as phase or activity;
"current activity unknown" without stronger evidence; last `closed`/`skipped` cycle and last
commit; open points from the four sources with source and revision, "source states none", or
`unknown`.
**Files.** `scripts/status-view.py`, `scripts/status-view.test.sh`.
**Reuse.** Task 3's cycle states; `read_commits`.
**Tests:** cases 1–5, 8 of spec §9 (plan without later evidence; WIP and no-result call as
observations; the cycle-state set incl. ordinary skip and one curve with two provenance lines;
several vs one candidate and the handover body; open-point `unknown` vs "source states none";
baseline held when `main` moves, branch change marked), and case 7's work-section part (reason
shown, `--base` fills it).
**Decision space.** How the handover's next-task section is located beyond "heading starts with
Next"; ordering and wording on the page.

### Task 5: Artifact growth

**Outcome.** Spec §6: baseline tree vs the named checkout root's current files incl. uncommitted
and untracked non-ignored, `.context/` excluded; per file status, bytes and lines before/now, net
change; groups by the first matching row; without a baseline current sizes only. Handovers listed
apart with change since first observed (first size kept in the cache), deleted ones kept with last
size, "first observed now" on first sight. Label "branch comparison against <commit> — not story
effort".
**Files.** `scripts/status-view.py`, `scripts/status-view.test.sh`.
**Tests:** case 6 (added, modified, shrunk, deleted, untracked, uncommitted; code and tests apart;
checkout root named; handover grows, shrinks, disappears) and case 7's growth part (no baseline →
current sizes, net change "unavailable"; `--base` fills it).
**Decision space.** Binary files (bytes only, lines "n/a"); sort order.

### Task 6: Workflow version

**Outcome.** Spec §7: installed (every `dev-workflow@dev-workflow-kit` record with scope; applying
= `user` or a project record for this repository; one → version, several → "ambiguous", none or
unknown shape → `unknown`); loaded per member session from the two skill-load event kinds only,
with component and time, "conflicting" when one session shows two versions, commands and hooks
`unknown`; declared at `HEAD` and in the worktree when different; rule revision per file with last
commit and uncommitted flag; mismatches marked.
**Files.** `scripts/status-view.py`, `scripts/status-view.test.sh`.
**Tests:** case 13 (versioned path in user text or a tool result does not count; two versions in
one session → "conflicting"); case 14 (two applying records → "ambiguous"); case 17 (four values
separate; installed ≠ declared marked; uncommitted rule file marked).
**Decision space.** What a project-scoped record's repository field is called, if one ever
appears (none exists today): treat any project record as non-applying unless a path field equals
this checkout root, and say so in the script header.

### Task 7: Battery, docs, real run, Gate B

**Outcome.** The suite in the battery and CI; documentation names the new report; `AC-12` shown.
**Files.** `AGENTS.md` (layout tree two lines; Boundaries: the report count and that status-view
writes only under `.context/status/`; Commands: quality and lint rows gain `shellcheck --shell=sh
--exclude=SC2015 scripts/status-view.test.sh` and `sh scripts/status-view.test.sh`, the git 2.36 /
Python 3.8 sentence names it, the typecheck row's count); `.github/workflows/ci.yml` (lint and run
steps beside live-effort's); `README.md` (where it lists the reports).
**Steps.** Before editing, grep for every statement of the report count and list
(`grep -rn "Python reports\|five \|live-effort" AGENTS.md README.md .github docs/architecture.md`),
per AGENTS.md's Don'ts on docs drift. Run the full quality command from `AGENTS.md` and record it.
**Real run (`AC-12`).** On real revisions of this branch, with one fixed baseline
(`--base 62ebb90`, this branch's merge-base with `main`): run the implemented report in a temporary
worktree checked out at `fc0b43d` (spec committed, Gate-A spec cycle open), then move that worktree
to `b1f76f1` (the commit carrying the closing records of Gate-A spec cycle `zz66702iyt`) and let the
running watch process refresh. Expected: the last evidenced phase moves from "spec written" to
"spec reviewed" with `b1f76f1` as source, and the spec's growth figure changes (the spec grew
between the two revisions). The evidence entry quotes both pages' phase and growth lines and both
generation times. The temporary worktree is removed afterwards. A `WIP:` commit is not used: it is
an observation, not a closing step (spec §5).
**Browser age check (named verification).** Open a watch-mode page in a browser, stop the watch
process, keep the tab open past three intervals while it keeps reloading, and observe "stale: no
successful refresh observed within three intervals" with the original last-success time; open a
one-shot page and observe no reload and no age check. The evidence entry names what was observed.
**Evidence entry (validation `battery+check`).** Battery green, plus the suite's counterfactual:
for at least the cases tied to `AC-3`, `AC-6`, `AC-9` and `AC-10`, name the observation that would
exist if the behaviour were absent and show the case failing against a mutant that removes it.
**Gate B.** `reviewType: full`, `baseSha` = merge-base with `main`, story path and evidence entry
quoted, per `.claude/review-gates.md`.

## Review focus

1. A real transcript far larger than the fixtures (tens of MB): the first run reads everything
   once; later collections must stay fast — Task 3's footer shows it; check on this machine during
   the real run.
2. `main` absent locally (fresh clone on a branch) → reason shown, nothing crashes — Task 4 case 7.
3. Browser opened on the file while a write happens → atomic rename; never a half page — Task 2.
4. A handover renamed rather than edited → old one "deleted", new one "first observed now" —
   Task 5.
5. Watch interval shorter than one collection → no overlapping collections in one process; the
   next starts after the previous ends — Task 2 (state it in the header; no test needed beyond
   sequential design).
