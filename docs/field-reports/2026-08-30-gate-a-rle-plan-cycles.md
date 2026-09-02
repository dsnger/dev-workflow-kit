# Review cycles `rle` — the four Gate-A plan cycles and the Gate-B cycle, preserved

Companion to `2026-08-29-gate-a-rle-cycle-evidence.md`, which holds the **spec** cycle. This file
holds the **four plan** cycles for the same change, and — since 2026-09-02 — the single
**Gate-B** cycle that reviewed their combined diff. Their validated findings files live under
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

**Plan C — rollout, packaging, evidence, the close.** 7 passes, **closed as not converged**
(Daniel, 2026-08-30). No clean pass was reached and none is claimed anywhere. The record is
`.context/codex-reviews/gate-a-plan-planc-CLOSURE.md`.

```
Findings 18, 20, 20, 23, 22, 19, 29
Blockers  5,  4,  2,  4,  5,  2,  2
Majors   11, 13, 13, 16, 13, 16, 19
```

Blocker/Major never left the 15–21 band, and both the highest finding total and the highest
Blocker+Major of the cycle are **pass 7 — the last one**.

**Plan C1 — the user-facing floor description.** The first carve-out of the split. 3 passes,
**stopped on the two-tell rule**, never closed.

```
Findings 14, 12, 17
Blockers  0,  1,  0
Majors    8,  7, 10
```

The finding count rose and Blocker+Major rose (8, 8, 10) — two of §5's five tells, which makes
stop-and-surface mandatory rather than discretionary. **Daniel's decision, 2026-09-01: do not
resume the loop. C1 is dissolved and its payload is reviewed at Gate B, on the artifact.**

One operational note the cycle paid for: the slots are
`gate-a-plan-planc1-pass-{1,2,3}.md`, with **no revision infix**. Four plan revisions were
committed (bb358c2, 476236b, 7e42947, 52192d1) and three passes recorded, and which pass ran
against which revision is not recoverable from the artifacts. A dispositions file must carry the
revision it reviewed; this record cannot reconstruct it.

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

**C1 turns that into a second data point, and it generalizes further than the first.** C1 *was*
the remedy for Plan C's non-convergence: take one statement site out, make the plan small, give it
its own cycle. C1 is nine sentences in eight replacements across two files — about as small as a
plan of this kind gets — and its curve rose anyway. So the cost is not carried by the plan's
**size**.

What both artifacts share is that they are prose describing replacements of prose, and a reviewer
reading one has no decidable question to answer. Plan B is the contrast that makes this visible:
its grammars can be checked against themselves, so a pass either finds an unreachable production
or it does not. A sentence-replacement list can only be checked against a fresh reading of two
other documents, and every pass brings a fresh reading. **A plan made of prose about prose has
now failed to converge under Gate A twice, at two very different sizes.**

Where that evidence points is Gate B: the same eight replacements, read as a diff against the
files they changed, are a question with an answer.

## The Gate-B cycle — five passes, closed as not converged

The four cycles above are Gate-A. This one is the single Gate-B cycle over the combined
A+B+C diff, and it closed the same way Plan C's did: **on the clearly-stuck exit, with no
clean pass and none claimed.** Numbers extracted mechanically from
`.context/codex-reviews/gate-b-{spec,quality}-rle-pass-{1..5}.md`, the same way the rest of
this file was taken.

```
pass      1   2   3   4   5
Findings 16  29  25  25  23
Blockers  4  15   6   5  10
Majors    5   2   9  10   6
B+M       9  17  15  15  16
```

**Pass 2 is discounted and not counted toward the floor.** Both branch files were
structurally valid — correct terminators, exact counts, six fields, no stray lines — but the
reply contradicted itself: each of the two parallel reviewers reported *the other* branch
`INCOMPLETE`, having mistaken its counterpart's legitimate file for a foreign write. The
findings were acted on, because a file that passes every structural check is provably not the
partial list the rule guards against; the pass was not credited, because an `INCOMPLETE` reply
is an incomplete pass by rule. **A protocol note in the next call's `additionalContext` —
"finding the other branch's file present is EXPECTED and is not a collision" — fixed it, and
it did not recur in passes 3, 4 or 5.** This failure shape is worth naming because nothing in
the file protocol anticipates it: `reviewType: full` runs two writers, and the rule that
protects them from racing on one path does not tell either that the other exists.

### What made it stick: one mechanism, four wrong descriptions

Every round's Blocker/Major cluster traced to prose describing **what the hook does with the
`.context/codex-gate.floor` knob**. The corrections, in order:

| round | what was written | why it was wrong |
|---|---|---|
| 1 | "trims trailing newlines"; "exceeds the hook's accepted maximum" | the hook runs `tr -d '[:space:]'`, and it defines no maximum |
| 2 | rewritten against the hook source, cause by cause | it gates on `-f` before reading, so a broken symlink never reaches the read, and a failed `cat` is indistinguishable from an empty file |
| 3 | walkthrough deleted, one summary sentence kept: "an unusable value leaves the hook's default standing" | false. Tested: `printf '1\0002' > knob.bin` is **accepted as twelve** in `sh`, `dash` and `bash` — command substitution drops the NUL, and `1` `2` becomes `12` |
| 4 | the claim deleted entirely, `<CAUSE>` dropped from the grammar | the note explaining *why* the description was deleted is itself a description of the hook |

That last row is the one to remember. **There is no version of that paragraph that survives
its own rule** — the remedy consumes any explanation of why the remedy was applied.
`docs/prompt-standards.md` item 11 already prescribes deletion after a fourth correction; what
this cycle adds is that the deletion has to include its own rationale, and the rationale then
lives here, in a field report, where describing the hook is the point rather than a claim the
product makes.

The capability cost was accepted knowingly on 2026-09-02: the provenance record now says
**that** a knob was unusable and no longer **why**. Whoever needs why reads the file and the
hook.

### Why the exit was taken rather than a sixth round

All three §5 conditions were affirmed, not assumed:

- **A plateau across passes.** Blocker+Major never returned to its pass-1 level of 9 and rose
  on the last pass.
- **Coverage affirmatively sufficient.** Across five passes the reviewers covered both prompt
  copies, the spec, the story, all three plans, the hook source and the user docs. No
  materially unreviewed area is known — and this file states that as a judgement, which the
  exit requires, rather than inferring it from a low count.
- **Blocker/Major regenerating across genuine repair attempts.** Each round's fix produced the
  next round's findings on the same mechanism, four times.

One further signal, and it is the one that settled it: **pass 5 returned as Blockers the very
requirement the human had withdrawn the day before** — that `unusable` and `undetermined`
distinguish their causes. The reviewer is not wrong that a collapsed record is less useful.
But a gate cannot clear a finding whose resolution the human has already declined, and a loop
that re-raises a decided question is no longer measuring the artifact. That is a
require↔withdraw pair in the §5 sense, and it is what made the stop mandatory rather than
discretionary.

Open findings and their dispositions, including the two marked as a chosen cost rather than a
missed defect, are in `.context/codex-reviews/gate-b-rle-pass-5-dispositions.md` — which is
git-ignored, so what survives a clone is this section.

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
