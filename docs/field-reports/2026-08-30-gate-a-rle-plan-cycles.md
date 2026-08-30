# Gate-A plan cycles `rle` — A, B and C, the record preserved

Companion to `2026-08-29-gate-a-rle-cycle-evidence.md`, which holds the **spec** cycle. This file
holds the **three plan** cycles for the same change. Their validated findings files live under
`.context/codex-reviews/`, which is gitignored and whose slots are reused, so this is the durable
record — the same reason the spec file and `2026-08-26-fic2-cycle-evidence.md` exist.

Every number below was extracted mechanically from those files
(`grep -cE '^(BLOCKER|MAJOR|MINOR|NIT) \|'`, `grep -c '^BLOCKER'`, `grep -c '^MAJOR'` per pass),
not recalled.

**Why the records are here and not in a commit body.** The four Gate-A cycles for this change —
one spec, three plans — all closed, or are closing, **before the record rules they helped write
are active**. An earlier revision of Plan C tried to reconstruct them into the implementation
commit's body with a marker saying they were reconstructed. Three Gate-A passes contested that in
a row, on three separate grounds: the destination is wrong (the settled rule puts each cycle's
record in *that cycle's* closing body), the marker could not live inside a record without breaking
the pinned grammar, and moved beside the record it was not covered by the squash-carry rule, which
enumerates records and not prose. **Daniel's resolution, 2026-08-30: the reconstruction leaves the
commit body entirely.** Pre-rule history goes to this channel, which is committed prose that git
carries on its own. The implementation commit carries only the native records of
its own Gate-B cycle. **That cycle is also pre-rule** — it began before these rules shipped, so
its records carry `cycle none (pre-rule)` like the rest. It writes them natively not because the
new operational rules bind it, but because this branch's own acceptance and evidence criteria
require them.

## The three curves

**Plan A — the floor predicate and the severity test.** 12 passes, closed clean.

```
Findings 21, 16, 16, 7, 5, 2, 3, 4, 6, 6, 8, 0
Blockers  7,  6,  6, 0, 0, 0, 0, 0, 0, 1, 1, 0
Majors   10,  8,  7, 3, 4, 1, 2, 2, 5, 5, 4, 0
```

**Plan B — the provenance line, the per-pass curve, the cycle nonce, slot naming.** 7 passes,
closed clean.

```
Findings 11, 3, 6, 10, 9, 7, 0
Blockers  2, 0, 0,  0, 0, 0, 0
Majors    7, 3, 4,  7, 5, 6, 0
```

**Plan C — rollout, packaging, evidence, the close.** Open at 5 passes when this file was written.
Its closing figures belong in a later revision of this file, and its absence from the list below
is a statement that the cycle had not closed, not that it closed at five.

```
Findings 18, 20, 20, 23, 22
Blockers  5,  4,  2,  4,  5
Majors   11, 13, 13, 16, 13
```

## What the three cost, and why they differ

**Plan A's shape is the ordinary one**: Blockers exhausted in three passes, then a long tail of
Majors, then clean. Its late Blockers at passes 10 and 11 were its own fixes regenerating —
the pattern the spec cycle recorded from pass 10 onward.

**Plan B is the cheap cycle**, and it is worth saying why, because it is the only counterexample
in the set. It ships four record *forms* — pinned grammars with named fields. A grammar is
checkable by reading it against itself: a reviewer can ask whether every field has a production
and whether every production is reachable, and get a decidable answer. It never needed a second
structural revision.

**Plan C never got its Blocker line to zero**, and both of its mandatory stops trace to the same
cause: **the plan restating rules that live somewhere else.**

| Revision | What changed | Next pass |
|---|---|---|
| 1–2 | ordinary repair rounds | 16 → 17 Blocker/Major |
| 3 | six unfailable checks stripped | 15 B+M — and the strip took two real actions with it |
| 4 | those two restored | 20 B+M, 17 of 23 findings on the plan's own copy of `CLAUDE.md` §5 |
| 5 | that copy deleted; the plan defers to §5 | 18 B+M, 16 of 22 still on what the deferral left unspecified |

Two mandatory two-tell stops fired, at passes 4 and 5. The first produced revision 5's
de-restatement; the second produced the resolution recorded at the top of this file.

**The finding that generalizes:** a plan that restates a protocol its own repo already governs
creates a second copy that drifts, and Gate A will review the copy instead of the work. Plan A and
Plan B state rules; Plan C had to *use* rules, and using them tempted it into repeating them. The
remedy was the same one the spec cycle recorded for restatements generally — **not a better
restatement, a deletion** — but deleting a restatement leaves a gap where the plan-specific facts
were tangled up in it, and pass 5 is a list of those.

## The superseded single-plan artifact

`docs/superpowers/plans/2026-08-29-review-loop-economics.md` is the single-plan version of this
change. It **opened at 31 Blocker/Major on its first Gate-A pass** and was replaced by the three
plans above. It is still in the tree, unmarked.

This is recorded as history, not as a task. Plan C's revision 4 shipped a task to mark the file
in place; the approved spec puts any remedy to the supersession convention out of scope, Gate-A
pass 4 said so, and revision 5's replacement — a line in the closing commit body — was itself the
same remedy relocated, which pass 5 also said. The convention is a real gap and it belongs to a
story of its own; it is not this cycle's to fix, and a note here is not a mechanism.

## Known limits of this record

The per-pass files behind these numbers stay in `.context/` and will be overwritten by later
cycles; what survives is the counts above and the dispositions files committed beside them. No
finding is classified under both the old and the new severity rules in any of the three cycles,
so — exactly as the spec cycle recorded — **no demotion figure is derivable from this data**, only
a comparison of recorded mixes across cycles that reviewed different artifacts.
