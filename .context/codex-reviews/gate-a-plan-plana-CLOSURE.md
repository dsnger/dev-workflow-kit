# Gate A — Plan A cycle — CLOSED CLEAN at pass 12

Advisory human note. Not a findings file; participates in no pass validation.

## Closure

**Artifact:** `docs/superpowers/plans/2026-08-29-review-loop-economics-plan-a-rules.md`
at commit `89056e6` (revision 14).

**Pass 12: CLEAN.** File validated structurally, not assumed:

```
NO FINDINGS␊
END OF FINDINGS (0 total)␊
```

Exactly two lines; line 1 exactly `NO FINDINGS`; line 2 exactly the terminator. Valid clean
pass under the file-first protocol.

**Floor satisfied.** The cited story is
`docs/superpowers/stories/2026-08-28-review-loop-economics-pass-floor-story.md`, read fresh at
close: `**Risk:** high · **Security:** none`. Under the rules in force — the constant 3, since
this cycle runs under the OLD rules by its own activation constraint — the floor is 3. Twelve
passes were run. **Final pass clean. The cycle closes.**

## Curve

| pass | findings | Blockers | Majors | B+M |
|---|---|---|---|---|
| 1 | 21 | 7 | 10 | 17 |
| 2 | 16 | 6 | 8 | 14 |
| 3 | 16 | 6 | 7 | 13 |
| 4 | 7 | 0 | 3 | 3 |
| 5 | 5 | 0 | 4 | 4 |
| 6 | 2 | 0 | 1 | 1 |
| 7 | 3 | 0 | 2 | 2 |
| 8 | 4 | 0 | 2 | 2 |
| 9 | 6 | 0 | 5 | 5 |
| 10 | 6 | 1 | 5 | 6 |
| 11 | 8 | 1 | 4 | 5 |
| **12** | **0** | **0** | **0** | **0** |

## Coverage statement

Stated affirmatively, as the closure requires, and bounded honestly.

**Reviewed across the twelve passes:** the shipped replacement text of all fourteen edits, read
as final §5 rather than as a diff; both prompt copies, including the two passages where they
already diverge and the one where this plan makes them diverge deliberately; spec §2, §2.1,
§2.2, §2.4, §3 and §10 against the text that implements them; **spec §9's exclusion list item
by item**, which was decisive twice; the old-conditions accounting against the actual old text
of all eleven passages; the downstream `/workflow-init` template for dependencies on this
repo's layout, which found one Blocker; the successor story's reciprocal obligation; the commit
protocol against the hook's actual source; and the fourteen assert-new patterns executed
against a simulated post-edit tree.

**Not covered, by construction rather than omission:** Plan A's interaction with Plans B and C,
which do not exist yet. That is scope, not a gap in this artifact, and Plan C's five inherited
obligations are named in the plan so they cannot be lost between documents.

**What this closure does not claim.** Gate A reviewed the plan. It did not review the edits —
the plan describes fourteen prose replacements and Gate B will read the real diff. Each task's
single check establishes that its edit landed at its site, and nothing more; correctness of
what landed is Gate B's.

## The traced regeneration chain — preserved verbatim for the field record

The best single specimen this cycle produced of fix-generates-finding in a prose artifact.
Each step is a repair that created the next round's finding:

- **pass 9** → ship §3 only, mark the deferral by naming the successor story.
- **pass 10 BLOCKER** → that named path ships into the `/workflow-init` template, which
  scaffolds `CLAUDE.md` into *other people's* repositories, where the path does not exist.
- **revision 13** → make the pointer `CLAUDE.md`-only, a deliberate divergence.
- **pass 11 BLOCKER** → the divergence is *declared in prose* but never *implemented as a step*:
  the architecture still called all thirteen edits mirrored, the constraint permitted only
  pre-existing divergences, the accounting still named two diverging passages, and Task 12 still
  supplied one identical both-copies replacement. **Executing the plan exactly produced
  identical copies and no pointer at all.**
- **revision 14** → emit it as Task 14, an actual step with an asymmetric check (1 in
  `CLAUDE.md`, 0 in the template), and **delete the declaration layer that kept disagreeing with
  the shipped text** rather than reconciling it again.
- **pass 12** → clean.

**What broke the chain was deletion, not reconciliation** — the third time in this cycle that
deletion was the cure. Pass 4 deleted the verification machinery after it drew 92% of findings.
Pass 10's decision deleted the out-of-scope reach into the loop rules. Pass 12 followed the
deletion of the plan's self-description. Every attempt to *reconcile* a describing layer with
the thing it described produced another finding; every *deletion* of one produced a drop.

## Two mandatory stops, and what they cost

Passes 9 and 11 were mandatory stop-and-surfaces under the five-tells rule — three tells each
time. Both were correct to take: pass 9's stop produced the §3-only reduction, and pass 11's
produced the deletion of the declaration layer. **Neither would have been reached by iterating**
— both times the available repair was a smaller reconciliation, and both times the right answer
was a structural cut that only a human could authorize.

## Residue

**None open.** All findings from passes 1-11 are resolved, routed and answered, or explicitly
collected as Minor/Nit per §5. Pass 12 found nothing.
