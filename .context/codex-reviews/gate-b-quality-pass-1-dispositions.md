# Gate B — quality branch — pass 1 dispositions

2 findings (1 Major, 1 Minor). Both accepted. Neither requires a spec change.

1  MAJOR intake lets a human correction set any value with no recompute or bounds — ACCEPT, sharpest finding of the pass. "A correction may set any value, up or down" was written for the AXES and silently licensed an arbitrary Validation value too, so intake could write security `high` with `battery` — a header §5 then classifies as unresolvable and stops on. The spec already bounds this; the prompt did not carry it. Fixed in the intake skill: an axis correction RECOMPUTES the mode, an explicit mode override may raise or lower but never drops `+abuse-path` while security is `high`, and an intake-time override writes the documented `mode override` log entry.
2  MINOR docs/coding-workflow.md "lighter questions" — ACCEPT. Same defect the spec branch reported as its finding 3; one fix closes both. Two independent reviewers landing on the same sentence is the reason it gets rewritten rather than argued with.
