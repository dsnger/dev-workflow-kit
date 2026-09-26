# Gate-B pass 3 — dispositions (both branches)

Range f9ed886..c22019b, two sequential single-branch calls. Both files validated.
Spec branch: 2 findings. Quality branch: 4 findings.

**Format note:** the quality branch used the severity token `IMPORTANT`, which is not one
of §5's four (Blocker/Major/Minor/Nit). The file is otherwise well-formed — four finding
lines, correct terminator, matching count — so the pass was accepted and all four were
treated as Major-equivalent on their content. The pass-4 prompts name the enum explicitly.

## Applied — committed diff

1. **MAJOR (spec) — the format-example residual understates the guard.** ACCEPTED,
   verified. The residual said "nothing enforces that distinction beyond its shape", while
   §8's own held-item list already recorded that claim as wrong: for this change C1d
   confines candidates to the label-to-`Columns:` interval and C3 rejects entry-shaped
   lines outside it. This is the *understatement* direction of the repo's signature defect,
   which the pass-3 prompt explicitly asked to be checked. Rewrote the residual to say both
   — two checks guard it once, shape alone guards it thereafter — and marked the §8 held
   item as corrected rather than held. Also corrected that bullet's own stated count
   ("Four things … deliberately held, not fixed"), which had become false: three of the
   four have since been acted on, two by the checks and one by this correction. Marked the
   two check-actioned items `*Done:*` with what the check now does.

2. **IMPORTANT (quality) — the spec's `todos.md` change-surface row names only check 1d**,
   while the landed `todos.md` row covers both entry validation *and* the unimplemented
   chronology check 1e, matching §8. ACCEPTED, verified by reading both. The spec was stale
   against what shipped. Updated the row to name both properties.

## Applied — scratch harness

3. **IMPORTANT (quality) — `FNR == NR` misdispatches when the ledger is empty.**
   ACCEPTED and **reproduced**: with an empty ledger and the real BASE as second input, the
   check reported `undecidable interval: 0 label(s), 1 Columns: paragraph(s)` — BASE's
   shape. Every BASE line had landed in the ledger's array, and the `nl == 0`
   "empty or unreadable" branch was unreachable for any non-empty BASE, which is always.
   Replaced with `FILENAME == ARGV[1]` / `FILENAME == ARGV[2]`. Re-tested: the same input
   now reports "the ledger under test is empty or unreadable".

4. **IMPORTANT (quality) — both calendar-validation fixtures fail without calendar
   validation.** ACCEPTED. `entry-bad-date-entry` was sought with the unmutated
   `ENTRY_DATE`, and `entry-bad-date-locator` with a hard-coded `ROWDATE`, so identification
   failed first and `isdate()` was never reached. Fixed three ways: `ROWDATE` is now
   overridable like `ENTRY_DATE`; the matrix passes the mutated date(s) per row; and the
   invalid entry date moved from `2026-02-30` to **`2026-08-32`**, which must be both
   calendar-invalid *and* lexically on or after the row date, or the on-or-before bound
   rejects it and the row again proves nothing.
   **Mutation-tested:** replacing `isdate` with a shape-only check flips exactly these two
   rows to passing and leaves the other twenty-eight unchanged.

5. **IMPORTANT (quality) — awk on the directory fixture is host-dependent.** ACCEPTED.
   Confirmed this host runs BSD awk (version 20200816), which reads a directory as empty and
   says nothing; GNU awk writes a "is a directory: skipped" warning to stderr, which the
   runner and matrix both treat as an infrastructure disagreement rather than the expected
   failure. So the sh/dash evidence was awk-dependent in a way neither shell run could
   reveal. All three checks now stop before any parsing once an input is unreadable, after
   the readable-file assertion has recorded the failure.

## Why pass 3 is not the closing pass

Both branches returned Major-equivalent findings, so the cycle continues. Every fix above
is amended into the WIP commit, and pass 4 reviews the result.
