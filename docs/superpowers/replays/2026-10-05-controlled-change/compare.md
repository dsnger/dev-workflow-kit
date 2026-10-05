# Comparison — replay on this package (2026-10-05)

The recorded run is **run 6**: rules read from commit
`067611998c84ad93ba54404de16c666e12256ea5` (intake, review-gates, AGENTS.md); a fresh
general-purpose agent (sonnet) given only `part1/`, `part2/` and those three files.

AC-12 asks whether the replay's deviations from the route are found and named, and whether every
row that differs from the historical table is reported with its cause. Since intake's "changed text is not a decision" rule, a `moved` or `dropped` fate must
quote the passage of the decision that covers it; a fate without one is a procedure failure.

A historical row counts as reproduced when every condition it covers gets the historical fate
(Narrowed → kept plus a moved or dropped remainder; Replaced → withdrawn plus added; Deferred →
moved; Kept → kept) and the AC operation the shipped rules prescribe. Causes: **rule** (the
history predates a rule the replay applies), **history** (the replay accounts for a change the
historical table did not), **input** (no decision in the package covers it, so it is
Unaccounted).

## Part 1 (9fb981f → f9aae57; the pass-1 amendment and the pass-4 narrowing, one change)

| Historical row | Historical fate | Replay (`out/part1-record.md`) | Result |
|---|---|---|---|
| Desired outcome "for any review cycle or story" | Narrowed | kept (counts, durations, tokens, never-closed cycles included); dropped — other-clone calls and story answers without provenance, each quoting the decision; also dropped — the per-cycle answer (deviation 4); moved → AC-9 | differs (deviation): the history narrows story attribution only |
| Criterion 1: every call in a transcript | Narrowed | kept for calls with a log; dropped — other-clone calls (quoted); operation none, added AC-8 for transcript calls without a log | differs (rule): kept text plus an added criterion instead of a narrowing; AC-8's content is the agent's flagged reading (below) |
| Criterion 2: attributed "wherever determinable" | Replaced | dropped (quoted), moved → AC-9 (quoted); withdrawn + added AC-9; AC-9 also drops per-cycle attribution (deviation 4) | differs (deviation): the history replaces story attribution only |
| Criteria 3–7 | Kept | AC-3..AC-6 kept; AC-7 (credit-balance label) → Unaccounted | differs (input): 3–6 reproduced, 7 belongs to the next row |
| Pass-1 amendment: credit balance removed | dropped | Unaccounted: the message names no decider for the pass-1 change | differs (input) |
| Pass-1 amendment: criterion 1 re-keyed on the transcript | changed | AC-8 (transcript calls), as the agent's flagged reading | differs (input): no quoted decision covers it |

Dependent artifacts: `docs/superpowers/specs/2026-10-02-run-analytics-design.md` (named).
Unaccounted: the credit-balance conditions (§1, §2, AC-1, AC-7).

## Part 2 (5fcc072 → 32609a0)

| Historical row | Historical fate | Replay (`out/part2-record.md`) | Result |
|---|---|---|---|
| Outcome: four-dimension assessment | Narrowed + deferred | kept explained evidence; dropped — yield, repair effects, coverage readout and green (quoted); moved → epic and `todos.md` | reproduced |
| Criterion 1: four dimensions with values | Narrowed | kept values and unknowns; dropped and moved (quoted); withdrawn + added AC-8 | differs (rule): a replacement under the narrowed-or-replaced test |
| Criterion 2: green / amber / red | Replaced | green dropped (quoted); withdrawn + added AC-9; AC-9's four states rest on the agent's unquoted reading | differs (deviation 2): the replacement operation has no covering decision for the added states |
| Criterion 3: thresholds calibrated | Kept | core kept; provisional marking and calibration additions → Unaccounted | differs (history and input) |
| Criterion 4: product distance | Narrowed | core kept; the distance classes, the earlier amber and "how it was determined" → Unaccounted | differs (input): Daniel confirmed on 2026-10-05 that the assessment's condition 3 limits what a classification may be derived from and does not decide dropping the classes |
| Criteria 5–7 | Kept, reworded | AC-5 "many findings … not green" dropped (quoted), withdrawn + added AC-10; AC-6 kept, added AC-11; AC-7's "writes no file" → Unaccounted | differs (history and input) |
| Whether a loop was worth its effort | Deferred | moved → epic and `todos.md` (outcome row) | reproduced |

Dependent artifacts: the epic story and `todos.md` (updated in this change); the part-2 spec as
"blocks" (historically updated in the following commit).
Unaccounted: product distance (classes, earlier amber, how determined), AC-3's provisional
marking and calibration additions, AC-7's "writes no file", AC-6's extra wording.

## Deviations found by review (Gate B cycle z090q10qsv, pass 3)

Checked condition by condition against the route, run 6 is **not compliant**. Its record
deviates from the route at these places (1–5 found in pass 3, 6–8 in pass 4, 9 in pass 5 and extended in pass 6, 10 in pass 6 of Gate B cycle z090q10qsv):

1. `out/part1-record.md` (AC-1 row): `added AC-8` (recording transcript calls without a Codex
   log) without a quoted covering decision; the agent labels it "a reading". An undecided
   addition belongs under Unaccounted.
2. `out/part2-record.md` (AC-2 row): `moved → AC-9` and `withdrawn; added AC-9` for the four
   light states, labelled "reading, not a quoted decision" — a fate and an operation without a
   covering decision.
3. `out/part2-record.md` (AC-5 row): "not red" strengthened to "not warned about" as a new
   requirement, with no covering decision.
4. `out/part1-record.md` (outcome and AC-2 rows): the per-cycle answer is dropped by quoting
   "attribution by provenance only", a passage that limits *story* attribution, not per-cycle
   reporting — the quote is present but does not decide the fate.
5. `out/part1-record.md` (§6 row) and `out/part2-record.md`: baseline scope conditions are not
   enumerated — part 1's "read-only collector over existing logs", part 2's "one repo-local
   report over the evidence parts 1 and 2b already produce" — neither given a fate nor listed
   as Unaccounted.
6. Both records: the story's own §4 (the quoted AGENTS.md invariants) is not accounted for in
   either part (part 2's "§4" row is the *vision's* §4, a different text).
7. `out/part2-record.md` (AC-3 row): the baseline's minimum calibration sample — "at least the
   cycles named in the vision §4 calibration cases and the field reports" — is neither kept nor
   listed as Unaccounted; the row keeps only "checked against recorded cycles".
8. `out/part2-record.md` (AC-4 row vs *Unaccounted*): "how it was determined" is marked kept in
   the row and listed as Unaccounted at the same time.
9. Both records' *Open questions* fields are incomplete: part 1 omits the baseline's question which
   transcript timing belongs to a gate call versus the whole session; part 2 omits the question which
   recorded cycles form the calibration sample and how a cycle's product distance is determined.
   All stay open in the after-texts' §5, and the route requires the record to state the
   questions left open.
10. Both records' *Reviews already run*: where the record says no gate rule decides the
    consequence for a review input (acceptance criteria — `out/part1-record.md`, and the
    open-cycle branch of `out/part2-record.md`), it gives neither the human's decision nor
    "pending" with the continuation it blocks, which the route requires.

**This list is what review found (Gate B cycle z090q10qsv, passes 3–6); it is not proven
exhaustive.** Each pass found more, so a further check may find another. The conclusion does not
depend on the list being complete: one deviation already makes the run non-compliant.

The earlier runs deviated at other places (below). Six runs on rules that tightened after each
one did not produce a compliant run: the route's text decides these cases, but a fresh agent
does not follow it reliably.

## Result

13 historical rows; 2 reproduced exactly (part 1: 0 of 6, part 2: 2 of 7). Eleven differences,
each with its cause: part 1 — 2 deviation (outcome, criterion 2), 1 rule (criterion 1), 3 input
(criteria 3–7, the credit balance, the re-keying); part 2 — 1 rule (criterion 1), 1 deviation
(criterion 2), 3 with an input part (criteria 3, 4 and 5–7), of which criteria 3 and 5–7 also have
a history part. Dependent
artifacts are named in both parts.

**Run 6 complied with the route: no** — ten deviations found, listed above (not proven exhaustive).
**Pass condition (story AC-12): met** — the deviations are found and named with their
locations, every differing row is reported with its cause, and the run's compliance is stated.
AC-12 replaced AC-11 on 2026-10-05 (Daniel), because "no procedure failure" measured the agent
rather than the procedure.

## Input overlap

What the inputs already state, so the replay cannot be credited with finding it: part 1's commit
message says the credit balance was dropped, unattributed effort kept and attribution by
provenance only; both decision-evidence excerpts recommend the narrowings the records encode
(part 2's names the spec's line-111 contradiction); the after-texts carry the new criteria
wording. The withheld part is the fate table, the fate verdicts and the record itself.

## Earlier runs

- **Runs 1 and 2** used the full local assessments, before this package existed (local files only).
  - Run 1 (head 3e1fc4f), before the narrowed-or-replaced test: both Replaced rows recorded as narrowed (Gate B cycle xby91gy4in, pass 1, found it). Unaccounted: part 1's credit-balance conditions; part 2's AC-7 write permission.
  - Run 2 (head 803a55a), with the test: Unaccounted: part 1's credit-balance conditions and per-cycle answer; part 2's earlier amber.
- **Runs 3 to 5** used this package.
  - Run 3: the part-1 attribution line read "Decision by Daniel" for the whole message, and the replay attributed the pass-1 credit-balance change to Daniel (Gate B cycle z090q10qsv, pass 1, found it). The line now states only what the message says.
  - Run 4: gave the AC-7 write permission, the provisional marking and the distance classes fates no decision covered (pass 2 found it). Intake then gained "the changed text is not a decision".
  - Run 5: still gave the distance classes a fate citing condition 3. Daniel confirmed it does not decide that. Intake then required every moved or dropped fate to quote its covering passage; run 6 ran under that rule and still violated it (deviation 2).

Which conditions a run lists as Unaccounted, and where it deviates, varies between runs on the same
rules. A later run may differ again; AC-12 asks that the deviations be found and named.
