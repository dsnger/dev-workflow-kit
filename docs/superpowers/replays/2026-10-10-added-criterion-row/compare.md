# Comparison — every run, every check

Checks are spec §3's (`docs/superpowers/specs/2026-10-10-added-criterion-row-design.md`). **M** =
mechanical (`checks.md`), **R** = reading check (made against `evidence/set1-artifacts.md` and
`evidence/set2-artifacts.md`). ✓ pass · ✗ fail · n/a does not apply.

| # | Check | Kind |
|---|---|---|
| 1 | Amendment route: the existing story changed, no new story file | M |
| 2 | Every baseline condition (AC-1…AC-4, §2 outcome, §2 exclusion) has a row (a run of criteria sharing a fate may share a row) | R |
| 3 | Every table row names a baseline condition; no `—`/empty/new-condition row | M |
| 4 | Baseline commit named; docs-only commit naming decider and date; nothing resumed | R |
| 5 | Four closed sets: one valid reason class; fate and AC-operation cells from their sets; dependent-artifact status valid or `none` | M + R |
| 6 | Every `moved`/`dropped` fate quotes a covering passage | R |
| 7 | §2 outcome and §2 exclusion unchanged in the story | M |
| 8 | Change record at the end of §3 | M |
| 9 | Header line and all seven field lines present | M |
| 10 | The CSV requirement recorded in exactly one valid shape, with a quoted passage that covers it | R |
| 11 | §3 holds the CSV criterion as AC-5 (next unused ID) with the same text as the record | M |
| 12 | AC-1…AC-4 present with their IDs, each changed only as the decision covers | M + R |
| 13 | B only: AC-2 narrowed with a dated note | R |

## Set 1 — skill at `cb134cc`

| Run | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 | 11 | 12 | 13 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| D1 | ✓ | ✓ | ✓ | ✓ | ✓ | n/a | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | n/a |
| D2 | ✓ | ✓ | ✓ | ✓ | ✓ | n/a | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | n/a |
| D3 | ✓ | ✓ | ✓ | ✓ | ✓ | n/a | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | n/a |
| D4 | ✓ | ✓ | ✓ | ✓ | ✓ | n/a | ✓ | ✓ | ✓ | **✗** | ✓ | ✓ | n/a |
| D5 | ✓ | ✓ | ✓ | ✓ | ✓ | n/a | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | n/a |
| B1 | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| B2 | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| B3 | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |

**The failure — D run 4, check 10** (`evidence/set1-artifacts.md`, "D run 4"): the record's entry
reads `AC-5: "A customer can request an export of their account data as a CSV file from the
account page." → per the decision: "add CSV to the export story"`. The decision names no place;
"from the account page" was taken from AC-1. Under the route's own rule ("reading a covering
decision into nearby wording is the same as having none") the location is not covered. D1, D2 and
D3 left the location out and said why; the pilot accepted the same wording in its baseline runs.
**Cause:** the field rules said each entry carries a covering passage, but not that the
requirement text is limited to what the passage covers. **Ruling:** Daniel, 2026-10-10, counted it
as a failure and chose a one-sentence correction (commit `53a88a4`), reviewed in Gate-B cycle
`lmyfo487jwdq`, followed by a fresh, complete set.

Other observations, none a failure: D5's fate cells read `kept (already format-independent)` — the
value is `kept` with a remark, counted as `kept` by the pilot's prefix rule (`runner.md` at b348b9c);
D2, D4 and B1 grouped criteria sharing a fate in one row; B2 created a branch because it was on
`main`, and resumed nothing.

## Set 2 — skill at `53a88a4`

| Run | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 | 11 | 12 | 13 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| D1 | ✓ | ✓ | ✓ | ✓ | ✓ | n/a | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | n/a |
| D2 | ✓ | ✓ | ✓ | ✓ | ✓ | n/a | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | n/a |
| D3 | ✓ | ✓ | ✓ | ✓ | ✓ | n/a | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | n/a |
| D4 | ✓ | ✓ | ✓ | ✓ | ✓ | n/a | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | n/a |
| D5 | ✓ | ✓ | ✓ | ✓ | ✓ | n/a | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | n/a |
| B1 | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| B2 | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| B3 | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |

All eight runs put the CSV criterion in *Added without an earlier condition* with its ID, text and a
quoted covering passage; none wrote a placeholder row. None carried AC-1's location into AC-5:
D1, D3, D4, D5, B2 and B3 recorded the location as an open question, D2 and B1 under *Unaccounted*.
D4's AC-5 says "in addition to XLSX", which the decision's "add" covers on its own (adding a
format leaves XLSX in place); D4 also quotes the request's "exports should also be offered as
CSV", which is not the decision and is not what the verdict rests on.

Other observations, none a failure: D4's grouped row reads `kept (their wording is format-independent
and already covers CSV files)` — the value `kept` with a remark, the same shape as the skill's own
example row `kept: on demand; dropped — …`, and counted as `kept` like set 1's D5; D2 added a §1 row and B3 a §4 row (baseline text, both kept);
D1 recorded "Reviews already run" as pending a human confirmation that no review ran on the
baseline — a stricter reading than other runs, within the field's shape.

## Before and after

| | 0.22.0 (pilot baseline, cited) | Set 1 | Set 2 |
|---|---|---|---|
| D runs with a row outside the closed sets | 1 of 3 | 0 of 5 | 0 of 5 |
| B runs with a row outside the closed sets | 0 of 1 | 0 of 3 | 0 of 3 |
| Runs passing every check | — (pilot checks differ) | 7 of 8 | 8 of 8 |

**Acceptance (spec §3):** met by set 2 — all 8 runs on one unchanged revision pass every check.
Set 1 stays here as the failed set that led to the correction.
