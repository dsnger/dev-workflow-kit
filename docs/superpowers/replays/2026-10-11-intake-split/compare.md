# Comparison — baseline 0.23.0 vs split

Raw lines: `evidence/checks-output.txt` (the checks script, `runner.md`). Reading checks were made by
the author of the change. Every case run below passed the run-validity rule (spec §4): an init
record with one `dev-workflow` plugin at the variant's copy, model `claude-opus-5-5`, a final
`result` with `is_error` false, no non-zero exit.

**Verdict: not adopted** (story AC-7, spec §4 "Set 2" bound). AC-6 failed in both sets; in set 2
case B r1 also missed a check its baseline met.

## Set 1 — split at WIP `344dfda`

| Case | baseline | split | Verdict |
|---|---|---|---|
| A (3 turns) | profile + one round, draft, one-file commit; 6 sections, rule line, AC-1…k, header | same; route file read with the Read tool before the first step | equal |
| B | AC-2 narrowed, CSV = AC-5 in *Added without an earlier condition*, every row a baseline condition | AC-2 narrowed; CSV as AC-1's replacement (AC-1 withdrawn, AC-5 added); an extra row for the §4 invariants | missed two checks as the spec stood then (shape, cell) — the shape was the oracle's error (amendment `5c9139c`), the §4 row is a real miss |
| C | not invoked, nothing written | same | equal |
| D r1–r3 | AC-5 in the field, AC-1–4 unchanged, cell check met (3/3) | same (3/3) | equal (AC-4 met) |
| E (2 turns) | question round, then grounding-floor stop, nothing written | same | equal |
| F (2 turns) | stop without writing, both collisions named | same | equal |
| G r1–r3 | asks and waits in r1, r3; **r2 wrote** (took the request as the decision) | asks and waits in 3/3 | equal or better |
| H (4 turns) | compaction recorded; H2 wrote an *Unaccounted* record for CSV; H3 completed | compaction recorded; **no route-file read after it**; H2 wrote the same kind of record; H3 completed as a replacement | **fail** (AC-6: no re-read) |

## Set 2 — split at WIP `f811cd9` (unconditional re-read sentence)

| Case | baseline2 | split2 | Verdict |
|---|---|---|---|
| B r1 | every check met | every check met except the cell check: an extra §4-invariants row | **regression** |
| B r2 | every check met | every check met | equal |
| B r3 | every check met | every check met | equal |
| H (4 turns) | compaction recorded; H2 wrote an *Unaccounted* record; H3 completed | compaction recorded; **again no route-file read after it** (`evidence/h-traces.md`); H2 wrote, H3 completed as a replacement | **fail** (AC-6) |
| Installed run (AC-5) | — | **not run**: non-adoption was already settled by H, and the run would have touched Daniel's `~/.claude/plugins` for no verdict | not produced |

## What the H traces show

In all four H runs the compaction is recorded (`system/compact_boundary`, `trigger: manual`). After
it, neither split run reads `amend-approved-artifact.md` — not with the conditional sentence (set 1)
and not with the unconditional one (set 2); the stream of turn 3 does not mention the file at all.
The post-compaction context of the split runs is larger than the baseline's (`post_tokens` 5,969 and
5,739 against 2,439 and 2,557), consistent with the root `SKILL.md` being carried across the
compaction while the route file is not — an observation, not a measured cause; what the split agent
still had in context after the compaction was not measured. The baselines behaved differently at the
same point: baseline2's H2 turn searched for the skill text and read the change-record section from
the installed plugin cache (`evidence/h-traces.md`), baseline (set 1) did not.

**The H records did not all pass either, on both variants.** Set 1: split/H has `badop=1` (a row
whose operation reads `none (operation recorded on AC-1)`, outside the closed set) and `badrow=1`
(a row for the previous record's *Unaccounted* entry); baseline/H has `badop=0` and `badrow=2`
(rows for the previous record's *Unaccounted* entry and for a §5 question). Set 2: both 0. These
rows come from the second record that H3 writes over the first, a shape no other case produces; the
spec's diagnostic rule therefore marks the H record checks as possibly faulty, while the missed
re-read — a trace fact, not a record check — stands on its own.

## Size (AC-1, measured on the set-2 tree)

| Route | 0.23.0 | split | Change |
|---|---|---|---|
| capture: `SKILL.md` + `capture-new-story.md` | 32,627 | 11,977 + 11,658 = 23,635 | −27.6 % |
| amend: `SKILL.md` + `amend-approved-artifact.md` | 32,627 | 11,977 + 11,685 = 23,662 | −27.5 % |

Characters, not bytes. The saving is real; it is not what failed.

## Effort

Every turn of both sets, from its `result` record: **$15.57** (set 1 $10.46 when it was reported,
the rest set 2). The two print-mode probes before the plan are not included.

Per variant, summed over every `claude -p` invocation (replicates included; `num_turns` is the
result record's model-turn count, which the checks script's `t1`, `t2` labels do not show):

| Variant | invocations | model turns | cost |
|---|---|---|---|
| baseline | 19 | 65 | $5.42 |
| baseline2 | 7 | 35 | $2.55 |
| split | 19 | 79 | $5.04 |
| split2 | 7 | 39 | $2.55 |

Set 1: 79 split against 65 baseline model turns over the same 19 invocations. Not attributed: the
split made 11 route-file reads there, and other per-case differences also count (C took 3 turns on
the split and 2 on the baseline with no route read in either; baseline G r2 wrote where split G r2
waited).
