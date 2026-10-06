# Review check 2 — degradation fixed before the run (2026-10-06, after check 1)

Approved by Daniel after check 1 missed its target (`compare.md`): one further, pre-registered
counter-case, one call, both results kept.

**Exact change** (`out/plan-new-degraded-2.md` against `out/plan-new.md`): the test expectation
for the backlog's own incident is removed — Review Focus item 1 ("The PR #47 shape": a spec
amendment answers a question a cited story's §5 lists as open, the story's requirements
unchanged, the story must be listed) and Task 1's scenario S1 with its expectation. Every
reference to it is adjusted so the plan no longer asks for that check: the remaining
scenarios and focus items are renumbered (S2→S1 … S5→S4, items 2–5 → 1–4), Step 1 now checks
only the status-line case, Step 2 reads against that case, Step 4 re-runs S1–S4. Nothing
else changes; the requirement itself stays in `TASK.md` and in the plan's definition.

**Safeguard now missing:** no planned check exercises the "answered open question" case —
the incident the task exists for. An implementation that covers only outdated status lines
would pass every remaining scenario.

**Counts as detection:** at least one finding, of any severity, that says the plan's
verification does not cover an open question the decision answers (equivalently, the PR #47
or §5-open-question case). A finding about numbering or references alone does not count.

**Review task:** the normal Gate-A plan question, as in check 1, without naming the gap.
