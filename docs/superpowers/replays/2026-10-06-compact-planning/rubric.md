# Rubric — fixed before any run (2026-10-06)

Scored per plan by reading it; each item yes / partial / no, with a quoted line as evidence.
Derived from the story's AC-1 (plan side).

- **R1 Outcome** — each meaningful step states what is true when it is done.
- **R2 Components and reuse** — the affected files/sections are named, and what existing text
  or mechanism is reused.
- **R3 Prerequisites and settled decisions** — order, prerequisites and the decisions that must
  already be settled are stated (e.g. version bump, prompt standards, which artifacts count).
- **R4 Test situations** — concrete situations with expected outcomes, including at least one
  failure or negative case.
- **R5 Decision space** — what the implementer may still decide locally is stated or clearly
  bounded.
- **R6 Implementation in full** — yes if any step contains the complete replacement prompt or
  template text for the change (the full new wording of the field or of a paragraph of it),
  or complete test code. A short phrase quoted to locate an edit is not implementation in
  full.

**Qualifying observation (the check that fails without the change):** the old-instruction plan
scores R6 = yes, and the new-instruction plan scores R6 = no while scoring yes or partial on
R1–R5. Anything else is reported as it is; "no observed difference" is a valid result, and no
run is repeated to obtain a different one.
