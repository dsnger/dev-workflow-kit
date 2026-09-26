# Gate A — Plan C cycle — CLOSED AS NOT CONVERGED at pass 7

Advisory human note. Not a findings file; participates in no pass validation.

**Artifact:** `docs/superpowers/plans/2026-08-30-review-loop-economics-plan-c-rollout.md`
at `bcd45dc` (revision 7). **No clean pass was reached, and none is claimed anywhere.**

**Decision (Daniel, 2026-08-30):** close the cycle as not-converged and split Plan C by
statement site into C1, C2 and C3, each its own Gate-A cycle. The split is the fallback he
named at the pass-6 tripwire and chose against then; it is chosen now on the data below.

## The curve

```
pass      1   2   3   4   5   6   7
Findings 18  20  20  23  22  19  29
Blockers  5   4   2   4   5   2   2
Majors   11  13  13  16  13  16  19
B+M      16  17  15  20  18  18  21
```

Seven passes, seven revisions. **Blocker/Major never left the 15–21 band**, and the highest
total and highest B+M of the cycle are both pass 7 — the last one. For contrast, from the same
change: Plan A cleared its Blockers by pass 4 and closed clean at 12; Plan B carried one Blocker
in its whole cycle and closed clean at 7.

## Two mandatory stops and one tripwire

| Pass | What fired | What it produced |
|---|---|---|
| 4 | two-tell stop (4 of 5 tells) | revision 5 deleted the plan's copy of `CLAUDE.md` §5 |
| 5 | two-tell stop + both standing route-immediately conditions | revision 6 moved the pre-rule records out of the commit body |
| 6 | Daniel's numeric tripwire (≤8 B+M, instrument share collapsing) | revision 7's claim sweep |
| 7 | bounded contract expired, not clean | this closure and the split |

## The claim sweep, and its honest outcome

Revision 7's method was Daniel's: enumerate the contested **claims**, grep every statement site
of each, fix every occurrence in one pass — `AGENTS.md`'s own recipe (*search for the claim, not
the phrase*) applied as a method rather than as a warning.

**Three of six held. Two regenerated inside the sweep itself.**

| Claim | Outcome at pass 7 |
|---|---|
| 1 — what the hook stores and counts | **fixed**, not re-contested |
| 5 — the WIP preflight's desired-state exit code | **fixed** |
| 4 — what a `grep -E` match can decide | **improved, incomplete** — per-pass model-key duplication and ordering uncovered; cross-record nonce agreement has only a positive case |
| 6 — completing the field report | **new task, two new findings** — updates the curve but not the analysis prose a clean close falsifies; its assert checks removal without checking insertion |
| 2 — whether a parser exists | **still open** — the sweep found the spec site it had missed and **missed two more**: both shipped prompt copies still carry Plan B's *"because the deferred metrics work parses it"* |
| 3 — which slot forms are valid | **worse; both remaining Blockers** — shipping the discriminator production is out of Plan C's §7/§8 scope **and unreachable**: this cycle runs under the old rules by the plan's own activation constraint, so a production shipping in the same commit cannot bind it |

**The finding that matters more than any individual one:** a sweep whose entire premise was
*find every site* missed two sites of the very claim it was sweeping, and the fix written for a
contradiction was itself contradictory. **That is a width result, not a care result** — Plan C
carried a rollout across seven files, a spec, a CHANGELOG and a live Gate-B cycle in one
artifact, and at that width a single agent's sweep does not converge.

**Cross-reference for the field record:** this is the strongest evidence so far for the
machine-readable architecture projection in `docs/superpowers/specs/2026-08-30-dark-factory-vision.md`
§10 — *generated from* `AGENTS.md`, never a second source. What defeated the sweep is exactly
what a projection would make mechanical: knowing every site a claim occupies.

## The six standing structural findings, unrepaired

Carried into C2 and C3 rather than fixed here:

1. No task instantiates the preflight; the only one is a placeholder template.
2. No task constructs or stores the evidence entry every Gate-B call must quote verbatim.
3. The knob before-state has no storage location or resumption rule (inherited M9).
4. The grammar check has no actual EREs, fixtures or fail-capable assertions.
5. The `mktemp` closing-body obligation (inherited MINOR 12) is declared moot while a multiline
   body still has to be composed with no named mechanism.
6. The risk-path verification reads one `Story:` header where the shipped rule requires the
   union across the spec and all three plans.

## What replaces Plan C

`C1` user-facing docs · `C2` packaging and descriptions · `C3` the close. Sequential, each its
own Gate-A cycle at floor 3, slot infixes `planc1` / `planc2` / `planc3`. One combined Gate-B
cycle at the end, unchanged.

**Bootstrap fix carried into C3:** the discriminator production ships **for future cycles**;
this cycle's slot naming rests on the `fic2`/`pr15` field-practice precedent. The plan claims no
production binds the cycle that ships it — which dissolves both standing Blockers by removing
the unreachable claim rather than by arguing with it.
