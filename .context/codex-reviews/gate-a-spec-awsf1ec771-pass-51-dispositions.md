# Pass-51 dispositions — reconciled 2026-09-13 against the files, not the labels

Reconciliation ordered by Daniel's advisory of 2026-09-13 19:22, which was raised against
`2044147` and is **confirmed**. Locations below were found by quoted content; every section label
and line number in the findings file was checked rather than trusted.

| # | Sev | Label in the findings file | Actual location | Repair in `2044147` | Open after it |
|---|---|---|---|---|---|
| 1 | MAJOR | design §4, passage (b) | **design §5, line 174** | **wrong site.** §4 line 143 already read `\| (b) what a loop absorbs \| §B \|` before the commit; the repair rewrote that clean pointer and left §5's text untouched | **YES — now repaired** |
| 2 | MAJOR | design §4, passage (b) | **design §5, line 174** | same wrong site, same row | **YES — now repaired** |
| 3 | MAJOR | design §7 "consumption clause" | design §7, as labelled | replaced by a pointer to target §A | no — verified absent |
| 4 | MAJOR | design §9 partial-adoption terminal action | design §9, as labelled | replaced by a pointer to §G | no — verified absent |
| 5 | MAJOR | §A3 "What this gate does have" | target §A3, as labelled | the seven-duty summary deleted; duties stay at the paragraphs that state them | no — verified absent |
| 6 | MAJOR | §A3 and §F item 5 "The act" | target §A3 **and §F item 9a's rationale** | §A3 and item 5 repaired; **item 9a's rationale still restated the case split** | **partly — now repaired** |

## What the mis-location cost, recorded because it is the lesson

The findings file named §4 and I edited §4. **§4 was already correct.** The repair therefore
*added* a restatement to a clean pointer row while the offending row two sections down was never
touched — a repair that made one site worse and the named defect no worth of progress. **A finding's
section label is a claim about the artifact and gets the same verification as any other claim**;
locating by quoted content would have cost one grep.

Finding 6 shows the second half of the same habit: the two sites the finding named were repaired
and a third site carrying the same duplication was not looked for.

## Repairs now applied

- **design §4** restored to `| (b) what a loop absorbs | §B |`, the pointer it was.
- **design §5's passage (b) row** keeps the decision provenance — decision 2 in §2, and pass 27
  finding 2 for the accept rule — and states no operative rule, pointing at target §B.
- **§F item 9a's rationale** points at item 5 instead of restating the amend-versus-reset split.

Re-read after repair: §4 line 143 and §5 line 174 both verified in place; the precheck exits 0 on
both files; `grep` confirms no surviving copy of the consumption clause, the §9 terminal action or
the Gate-B duty summary.

**This is local repair verification and not a clean gate pass.** Pass 52 ran against `2044147` and
its findings are open; the cycle continues under its own rules.
