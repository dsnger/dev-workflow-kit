# Process monitoring — generated status view — Story

**Date:** 2026-10-06 · **Size:** story
**Risk:** standard · **Security:** standard · **Validation:** battery+check

## 1. Problem statement
While work runs in this repository, there is no single place that shows what is being
worked on, what is evidenced as done, what is open, what it cost and how much the
artifacts grew. The facts exist, scattered across git, commit-body review records, the
handover file, `scripts/run-analytics.py`, `scripts/live-effort.py` and
`scripts/loop-usefulness.py`, so answering "where do we stand" takes a model session or
manual reading. Whether a session runs on the current workflow version and rule revision
is not visible at all. Owner: `todos.md` "Generated status HTML — task, progress and KPI
views" (trigger fired 2026-10-06).

## 2. Desired outcome
A local, generated HTML status view for this repository that a human can refresh during
work and read at a glance: activity, evidenced result and effort side by side, each fact
with its source and revision, and stale, missing or unknown data visibly marked rather than
guessed. Markdown and the existing records stay the authored source; the view only reads
them.

## 3. Acceptance criteria
_IDs are permanent once the story is committed: never renumber or reuse one; a new criterion takes the next number unused here and on the branch it merges into, and a collision stops for a human; a removed one stays, struck through and dated; a narrowed one keeps its ID with a dated note; cite as `<story path> AC-<n>`; full rules: dev-workflow:intake, "Acceptance-criterion IDs"._
- [ ] **AC-1** Current work: the view shows the current story or task, its phase, its artifacts and the last observed activity, each with its source; a phase that no record states is shown as unknown or as inferred, labelled as such.
- [ ] **AC-2** Evidenced progress: the view shows the last closed step with the source and the revision that evidence it; a step with no evidencing record is not shown as closed.
- [ ] **AC-3** Open points: the view lists open decisions, blockers and waits from the existing records; where none can be read, it says "unknown", never "none".
- [ ] **AC-4** Effort: run time, tokens, gate calls and review passes are shown as separate figures; any figure that cannot be measured is shown as unknown, not as zero.
- [ ] **AC-5** Artifact growth: the view shows the current size and the change of the spec, the plan, the instruction files and the handovers, including uncommitted changes; new files stay visible; the baseline and the checkout looked at are named in the view; code and tests are reported apart.
- [ ] **AC-6** Workflow version: the view shows separately the dev-workflow version installed, the version observed loaded in the session concerned (or "unknown"), the version this repository's manifest declares, and the revision of the local rules; the rule revision on disk is not presented as the revision a running session loaded.
- [ ] **AC-7** No checkbox-completion percentage and no composite score appear anywhere in the view.
- [ ] **AC-8** Every shown fact carries its source and revision or timestamp; stale or missing data is visibly marked.
- [ ] **AC-9** A refresh takes in newly available evidence and the current file states, without a model call and without rescanning the whole history on each refresh; the view's generation time and the as-of time of its underlying data are shown separately.
- [ ] **AC-10** The view writes nothing outside its own output and changes no record it reads; the view's output contains no session text from transcripts or logs.
- [ ] **AC-11** Out of scope and absent from the delivery: orchestrator, agent control, automatic stops, new gate rules, full cost accounting, human-attention metrics, the decision inbox, and any second dashboard entry or status mechanism besides the owning `todos.md` row.
- [ ] **AC-12** On a real piece of work in this repository, it is shown that an evidenced state change and artifact growth become visible after a refresh; additional test cases show that missing, contradictory or stale data produce no false closed or active status.

## 4. Affected AGENTS.md invariants
- `## Architecture` (Boundaries) — "plus five Python reports with their suites: … `scripts/run-analytics.{py,test.sh}` (writes only its own store under `.context/telemetry/`) — the hook ships in the plugin, the checkers and the reports do not"
- `## Architecture` — the layout tree is part of the surface: "The same applies to adding files: the layout tree above is part of the surface that drifts." (`## Don'ts`)
- `## Commands` — "`scripts/run-analytics.py`, `scripts/loop-usefulness.py`, `scripts/spec-delta.py` and `scripts/live-effort.py` also need git 2.36 or later and check for it."; "The metrics report's suite also needs **`python3`** 3.8 or later"
- `## Key invariants` / Packaging, 12 — "A pull request that changes any path under a `plugins/<name>/` directory … must also change that plugin manifest's `version`" (applies only if the delivery touches `plugins/`)

## 5. Open questions
- Which baseline AC-5 names by default (for example the story's first commit or the merge-base with `main`) — a requirement choice to settle in brainstorming. **Answered 2026-10-06 (Daniel, brainstorming):** merge-base with `main`, overridable with an explicit commit; see the spec, §3.
- Whether "phase" (AC-1) should become an explicitly recorded field later, or stay inferred in this first delivery. **Answered for this delivery 2026-10-06 (Daniel, brainstorming):** derived from evidence only, labelled as such (spec §5); a recorded phase field later stays open.

## 6. Suggested size
story — one local generated view over existing sources, one spec → plan → PR.
