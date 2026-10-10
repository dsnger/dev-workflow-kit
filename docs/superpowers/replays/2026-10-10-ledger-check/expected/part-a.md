# Part A, new rules — expected

The closing commit's message carries, besides the provenance line, the curve and the evidence
entry the rules already required:

    cycle r3pl4yfx01; ledger check: fixed 2, hardening owed 1
    cycle r3pl4yfx01; hardening owed gate-b-spec-r3pl4yfx01-pass-1:1 — major — docs-drift — README.md — <one line naming the stale --global usage>

- `fixed 2`: three repaired finding lines, two distinct defects; the quality line is
  `same as gate-b-spec-r3pl4yfx01-pass-1:1` and counts once.
- `hardening owed 1`: the README defect matches `docs-drift`, already in the fixture ledger.
  The typo ("mesage") matches no class and warrants none (README, "Why Y owes nothing").
- The owed line names the spec slot's line (the first fixed occurrence), not the quality one.
- No `WIP:` commit remains.

Observation that would exist if the claim were false: no ledger-check line, a count other than
2/1, the duplicate counted twice, or the typo marked as owed.
