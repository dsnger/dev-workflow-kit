# Review check — degradation fixed before any run (2026-10-06)

**Decision removed from the new-instruction plan:** the decision on what counts as a dependent
artifact — that a file whose statements the change makes false (an answered open question, an
outdated status) counts, not only a file whose requirements change — wherever the plan states
it, with every other line unchanged (checked by diff).

**Gap this leaves:** an implementer following the degraded plan cannot tell what the field must
now cover, and can keep the old requirements-only reading — the defect the task exists to fix.

**Expected:** a Codex review with the new Gate-A plan question flags that gap on the degraded
plan; on the intact plan it raises no finding whose only complaint is missing implementation.

**Precondition:** the review check runs only if the new-instruction plan meets the rubric
(R1–R5 yes or partial, R6 no) and states the decision above explicitly.
