# Live effort counters for running review cycles (2c part 4a) — Story

**Date:** 2026-10-05 · **Size:** story
**Risk:** standard · **Security:** none · **Validation:** battery+check

## 1. Problem statement
Review effort is visible only after the fact. `scripts/run-analytics.py` (2c part 1) reports gate
calls, duration and tokens per cycle and story once the calls are collected, so a review loop that
burns effort is noticed only when someone runs that report later. The vision names this gap:
post-run analytics detect overspend after it happened (§11, "Live cost visibility"), the "token
furnace" §10 records from prior art. Part 4 of the telemetry story
(`docs/superpowers/stories/2026-10-02-telemetry-and-review-loop-usefulness-story.md`) bundled live
counters with a minimum-cost INCOMPLETE rule that would change pass validity. Daniel split it on
2026-10-05: measurement comes first (this story, part 4a), and any validity rule comes later, on
calibrated data (part 4b).

## 2. Desired outcome
While a review cycle is still running, and already while a single gate call is still running, the
human can see how much effort it has taken so far: gate calls, time and tokens, per open cycle and
per story, with every value that cannot be determined shown as unknown. Repo-local first: a terminal
report the human can re-run at any moment. This is measurement only: no gate rule, pass count,
floor, closure condition or hook behaviour changes, nothing is blocked or stopped, and no threshold
warning is raised. It gives part 4b and the review-loop usefulness work real data to calibrate
against. Status-line integration and shipping it in the plugin are later steps; money cost stays
explicitly unmeasured, as in part 1.

## 3. Acceptance criteria
_IDs are permanent once the story is committed: never renumber or reuse one; a new criterion takes the next number unused here and on the branch it merges into, and a collision stops for a human; a removed one stays, struck through and dated; a narrowed one keeps its ID with a dated note; cite as `<story path> AC-<n>`; full rules: dev-workflow:intake, "Acceptance-criterion IDs"._
- [ ] **AC-1** For a review cycle that has not closed, the report shows the effort so far, including
      a gate call that is still running. Before that call's result exists, it shows only the values
      the spec has shown to be attributable at that point; anything not yet attributable to a cycle
      or story is shown as unattributed, not guessed.
- [ ] **AC-2** Time and counts are named distinctly: the cycle's elapsed wall-clock time, the summed
      duration of its gate calls, and the running time of a call still open, which differ when
      reviews run in parallel. The report says that a gate call is not a valid review pass and does
      not count passes.
- [ ] **AC-3** Each report shows when it was produced and, separately, when the newest measured value
      in it was observed, so a freshly rendered report over old data is recognizable. A total with
      unknown parts is shown as the known partial sum plus the number of unknown contributions,
      never as a complete total and never with unknowns read as zero.
- [ ] **AC-4** Reconciliation with run analytics: for the same completed calls and the same state of
      the sources, the measures both report agree. A provisional value for a running call is
      replaced when the call completes, never counted twice. Every expected difference has a named,
      concrete cause in the report or its documentation.
- [ ] **AC-5** No gate rule, pass-validity rule, floor, closure condition or hook behaviour changes,
      and nothing blocks, stops, warns on a threshold or discounts a pass on the basis of these
      counters. Money cost is not reported.
- [ ] **AC-6** What the report cannot see is stated where it is shown, at least the limits run
      analytics already names (other clones, removed worktrees, calls outside Claude Code).

## 4. Affected AGENTS.md invariants
- `## Architecture` — "`scripts/run-analytics.{py,test.sh}` (writes only its own store under `.context/telemetry/`) — the hook ships in the plugin, the checkers and the reports do not"
- `### Hook` — "1. **The hook always exits 0.**"
- `### Hook` — "3. **Gate-B validity is content-derived, never event-derived.**"
- `## Don'ts` — "**Never describe what a gate proves without checking what it actually compares.**"
- `### Packaging` — "12. **A plugin change requires a version bump.**" (only if the solution touches the plugin)

## 5. Open questions
- Which live sources exist for a call that has not returned yet (Claude Code transcripts, Codex
  session logs), and which values do they make attributable before the result? The spec must show
  this before relying on it; existing measurement logic is reused where it applies.
- Scope recorded 2026-10-05 (Daniel, on the reviewer's recommendation): repo-local, counters only,
  a re-runnable terminal report. Status line, plugin shipping and threshold warnings are later and
  out of this story.

## 6. Suggested size
story — one measurement report for running cycles, reusing run analytics' logic; one spec → plan →
PR.
