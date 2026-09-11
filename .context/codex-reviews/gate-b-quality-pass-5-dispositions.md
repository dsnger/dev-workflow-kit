# Gate-B pass 5 — dispositions (quality branch)

Range f9ed886..556cbfe. Quality branch only: pass 4's spec MINORs were fixed alongside
its MAJOR, so the spec branch is re-run in the closing round rather than against a tree
already superseded. 1 finding, MAJOR, validated file.

## Applied — scratch harness

1. **MAJOR — the unreadable-ledger C2 row records only C2a.** ACCEPTED and **reproduced**:
   `check-c2.sh` on the directory fixture emitted `FAIL C2a: the ledger is a readable file`
   and then returned, with no C2b line anywhere in the output. The plan (Task 3 Step 6)
   requires *both* labels to fail on that input.

   **This was self-inflicted, by pass 3's own fix.** The early bail-out I added at pass 3 —
   correct in itself, since handing awk a directory is host-dependent — cut C2b's assertions
   out of that run. Worse, the `matrix.sh` comment I wrote in the same pass still asserted
   "both emit their own FAIL lines", which had been true *before* the bail-out and was false
   after it. A fix introduced a stale claim about itself, in the check whose whole purpose is
   catching stale claims.

   Fixed: the guard now records C2b's own verdict before stopping — on readability, so no
   parser is reached and the host-dependence stays closed. Both labels now emit a FAIL line
   (`--- C2: 2 failure(s)`), stderr is still empty, and C3's single label still fails as the
   plan requires. The `matrix.sh` comment is corrected and now states plainly what the row's
   exit status can and cannot establish, and records the earlier version as the cautionary
   case.

## The pattern, now four for four

Every pass of this cycle found the same defect class in the evidence harness: **a fixture or
check reporting an expected failure that would report it just as loudly with the tested
property removed.** Passes 2 (unasserted appends), 3 (calendar dates unreachable), 4 (locator
equality unreachable), 5 (C2b unreachable). The fix is always the same shape — make the check
reach the property — and the recurrence is itself the finding: this is what the hardening
ledger exists to record, and it is a candidate row of its own.

## Committed diff

Unchanged. This fix touched only the never-committed harness, so `556cbfe` still stands and
nothing was amended. The closing round reviews that same commit with the corrected harness.
