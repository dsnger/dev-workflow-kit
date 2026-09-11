# Gate A — Plan A cycle — passes 6 and 7 dispositions

Advisory human note. Not a findings file; participates in no pass validation.

## The three pass-report lines

**1 — Trend.**

| pass | findings | Blockers | Majors | B+M | instrument share |
|---|---|---|---|---|---|
| 1 | 21 | 7 | 10 | 17 | most |
| 2 | 16 | 6 | 8 | 14 | 5 of 6 Blockers |
| 3 | 16 | 6 | 7 | 13 | 12 of 13 B+M (92%) |
| 4 | 7 | 0 | 3 | 3 | **0** |
| 5 | 5 | 0 | 4 | 4 | **0** |
| 6 | 2 | 0 | 1 | 1 | **0** |
| 7 | 3 | 0 | 2 | 2 | **0** |

**2 — Cluster.** Product behaviour, four passes running. Zero instrument since the strip.

**3 — require↔withdraw.** None across the cycle. The repeated findings on the cited-set axis
(pass 5 M1 → pass 6 MAJOR → pass 7 MAJOR 1) are **successive refinements of one unsettled
question**, not a pass demanding what an earlier pass removed.

**Tells:** one marginal — findings rose 2 → 3. Blockers have been zero for four passes, the
cluster is on product behaviour, and there is no require↔withdraw pair. **One tell is not
two**, so no mandatory stop from that rule. The loop stops on pass 7 MAJOR 1's novelty
instead.

## Pass 6

- **MAJOR — absorbed.** No authority for cited-set membership. Absorbed on the reasoning that
  §2 already contracts one set, so supplying a stop for when reality disagrees implements the
  assertion rather than changing it. Pass 7 shows that reasoning was **too generous** — see
  below.
- **NIT — fixed while the row was being edited.** Accounting row 1 said condition b
  ("Blocker/Major only") was kept outside the replaced range; it is inside Task 1's OLD block
  and re-emitted in its NEW block. Disposition split. A Nit earns no repair round of its own
  and did not get one.

## Pass 7

- **MAJOR 2 — absorbed.** The downstream adoption trigger ran one direction only. It stopped
  when the predicate landed beside a surviving fixed-number obligation, but not the inverse:
  a merge can take Task 6's or Task 8's derived-floor language while Task 1 is absent, leaving
  a project claiming a derived floor with nothing defining it. `/workflow-init` explicitly
  permits a user-selected partial merge, so both states are reachable. Restated as a
  **bidirectional coherence requirement**: exactly one floor definition present, and every
  pass-count and closure statement resolving to it.
- **NIT — fixed, verified mechanically.** Task 1 said a raise costs a further pass "as above".
  `grep` for `further pass` before Task 1 (line 160): **0 occurrences**; it first appears at
  line 689, inside Task 11. The cross-reference pointed backward at nothing and now points
  forward.

## MAJOR 1 — routed, and my pass-6 absorption reconsidered

This is the third finding on the cited-set axis. It asks for **one change-level carrier for
the governing cited set**, with each cycle reconciling against it, and says outright: *"If
choosing that carrier is not already a settled contract, route that choice to the human
rather than absorbing it."*

**It is not settled.** §2 asserts the three cycles derive from "the same cited-story set" and
never says **where that set lives**. A carrier is therefore a new mechanism, not an
implementation of an approved sentence. §5's rule for a genuinely unclear boundary is to
treat the finding as **outside** — "which costs a question and never a silent expansion."

**Its supporting example is wrong, and I checked before routing.** The finding says the spec
cites the successor loop-rule story while the plan cites only the pass-floor story. Verified:

```
spec  :4  **Story:** …/2026-08-28-review-loop-economics-pass-floor-story.md
spec  :32 …/2026-08-29-loop-rule-consolidation-story.md   <- a scope DISCLAIMER
plan  :19 **Story:** …/2026-08-28-review-loop-economics-pass-floor-story.md
```

Both governing `**Story:**` headers cite the **same** story. Line 32 states the consolidation
is *not* in the spec. **The artifacts do not disagree.**

**The gap survives the bad example**, which is why it routes rather than being dismissed:
nothing in the shipped text distinguishes a **governing citation** from an **incidental
mention**, and an agent grepping story paths finds two in the spec and one in the plan. Two
fixes exist and they are not the same size — naming the `**Story:**` header as the governing
citation, or the carrier-plus-reconciliation the finding asks for. Choosing between them is
the routed question.

**On my pass-6 absorption.** I absorbed the set-authority finding on the ground that a fix
implementing the approved sentence existed. That was defensible and it was also the more
generous of two readings, and the question came straight back one pass later in sharper
form. The rule I should have applied is the one §5 states for exactly this case: where
membership is genuinely unclear, treat it as outside. Two rounds on one axis is the signal
that it was unclear.
