# Gate-B pass 4 — dispositions (both branches)

Range f9ed886..d83f5e5, two sequential single-branch calls. Both files validated, both
using the correct severity enum after pass 3's `IMPORTANT` drift.
Spec branch: 1 MINOR. Quality branch: 1 MAJOR + 1 MINOR.

## Applied — scratch harness

1. **MAJOR (quality) — `entry-wrong-fingerprint` and `entry-wrong-rowdate` never reach the
   locator-equality loop they exist to exercise.** ACCEPTED and **reproduced**: both failed
   with `C1d: 0 candidate(s) are the mandated entry`, i.e. at *identification*, because the
   matrix left `FP` and `ROWDATE` at their defaults while the fixture mutated them. Deleting
   both locator equality comparisons outright left both rows still failing — so they proved
   nothing about the property they name.

   This is the third instance of one defect class this cycle (after the append assertions in
   pass 2 and the calendar dates in pass 3): **a fixture that mutates part of the locator must
   pass the mutated value in, or the check rejects it before the advertised dimension.** Fixed:
   `FP` is now overridable, `row()` takes a sixth positional, and both rows pass their own
   mutated locator. They now fail with the locator diagnostic
   (`matches 0 row(s) by locator, 0 eligible`), and deleting the equality comparison flips
   five rows including these two.

   **It also falsified a claim I had committed.** At pass 3 I marked spec §8 held item 1
   `*Done:*` — "the check compares both fields before the bound, and `entry-wrong-rowdate` is
   that fixture". The check did compare them; the fixture did not exercise it. That `*Done:*`
   note is now rewritten to say what is actually true and to record the mutation test.

## Applied — committed diff

2. **MINOR (spec) — §1 describes the pre-change gap in the present tense** ("neither move is
   sanctioned", "The gap is live") in the same document whose §2 sanctions the move. ACCEPTED,
   verified. Normally a MINOR is collected rather than acted on, but this cycle was already
   going to pass 5 for finding 1, and it is the same "a change falsifies its own spec" family
   the whole cycle has been about. Added an explicit pre-change framing sentence — which the
   story already carries — and moved the section to the past tense.

3. **MINOR (quality) — two sites still call the correction "prose-only".** ACCEPTED. §8's own
   held item 2 names both sites and states the accurate wording ("no standing machine
   consumer": the syntax *is* a standing convention every future author must honour, and §6
   adds only a validation-only parser making no ongoing compatibility promise). Corrected both,
   and marked held item 2 done. With that, all four of §8's held items are closed, so the
   bullet's own summary sentence was corrected too — it had said the second still stands.

## Note on the pattern

Three of this cycle's four passes found the same shape of defect in the evidence harness: a
fixture reporting an expected failure that would have reported it just as loudly with the
tested property removed. The fix each time was to make the check reach the property. The
general lesson is recorded in the harness comments and in the evidence entry, not just in
the individual fixes.

## Why pass 4 is not the closing pass

The quality branch returned a MAJOR. All fixes above are amended into the WIP commit
(556cbfe), and pass 5 reviews the result.
