# Gate-B pass 2 — dispositions (both branches)

Range f9ed886..8647b8d. Run as **two sequential single-branch calls** — `reviewType:
spec`, then `reviewType: quality` — each naming only its own slot, after pass 1's
both-write race. Both branches reviewed the same commit; the quality call ran before any
pass-2 fix was amended, so the pass covers one tree. Both files validated.

Spec branch: 3 findings (1 MAJOR, 2 MINOR). Quality branch: 1 finding (1 MAJOR).

## Applied — committed diff

1. **MAJOR (spec) — §6 still mandates check 1e while §8 says it was never implemented.**
   ACCEPTED, verified. §6 read "**Six** properties, 1a through 1f. All must hold", and
   1e was written as live ("this checks recorded order", "this is a floor under it")
   while §8 says "Check 1e is therefore not implemented … No chronology validation
   exists". A surviving synonym of pass 1's finding 1, in the section that defines what
   the checks are. Recast: §6 now says five must hold for this change (1a–1d, 1f) and
   names 1e as specified-but-deliberately-unimplemented; 1e's own oracle moved to the
   conditional, closing with "a floor that does not exist today".

## Applied — scratch harness and the evidence entry

2. **MINOR (spec) — the counterfactual mis-describes C1d's diagnostics.** ACCEPTED. The
   entry enumerated "a parse, locator or eligibility diagnostic" while its own preceding
   bullet quotes `undecidable interval`, and an empty block yields "the interval holds no
   candidate line". Rewritten to enumerate the diagnostic belonging to each falsified
   dimension, including both absence cases.

3. **MINOR (spec) — `rows-two-matching` is built by `cp` + append and asserted nowhere**,
   while the entry claimed every fixture is asserted to differ from its input. ACCEPTED
   as a real overclaim I introduced in pass 1. Added an assertion that the locator
   matches exactly two complete rows. Mutation-tested: suppressing the append gives
   "rows-two-matching carries 1 complete row(s) matching the locator, want 2".

4. **MAJOR (quality) — `entry-bad-date-locator`'s appended row is not asserted.**
   ACCEPTED. Its advertised dimension is a calendar-invalid locator on an entry that
   would *otherwise* match a complete row; lose the append and it still fails, for the
   weaker "locator matches nothing" reason `entry-wrong-rowdate` already covers. Added an
   assertion that exactly one complete row carries 2026-02-30.
   **Extended beyond the reported site:** `entry-outside-block` has the identical
   unasserted-append shape — lose its append and the fixture becomes "no entry anywhere",
   which is not what it advertises. Asserted that the entry occurs exactly once and below
   `Columns:`. Both mutation-tested; each fails with its own diagnostic.

## Found by the author while validating, not reported by either branch

5. **The evidence entry claimed "All 28 matrix rows".** `grep -c '^row '` gives **27**.
   The number was introduced in the pass-1 rewrite of the entry and never verified —
   the same stated-count defect this cycle exists to address. Corrected to 27, and the
   arithmetic checked: 18 C1d rows (12 FAIL + 6 PASS) + 5 C1a + 2 C1b + 2 C1c = 27.

6. **"Twelve constructed ledgers" was loose.** One of the twelve is
   `ledger-unreadable`, a *directory* standing in for an unreadable ledger, not a ledger.
   Reworded to "twelve constructed inputs … eleven of them ledgers, the twelfth a
   directory standing in for an unreadable one".

## Collected, not iterated on

Nothing outstanding: both MINORs above were fixed because they concerned the accuracy of
the evidence entry, which goes into the commit body as a durable claim.
