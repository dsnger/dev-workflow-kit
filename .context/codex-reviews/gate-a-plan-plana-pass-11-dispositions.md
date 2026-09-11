# Gate A — Plan A cycle — pass 11 dispositions

Advisory human note. Not a findings file; participates in no pass validation.

## Result

Artifact 7208756 (revision 13). VALID pass: terminator exact, 8 finding lines, 0 non-finding
lines. **1 BLOCKER · 4 MAJOR · 2 MINOR · 1 NIT = 5 Blocker/Major.**

**MANDATORY STOP-AND-SURFACE — three tells. Second stop in three passes. Nothing repaired.**

## Trend — the whole cycle

| pass | findings | Blockers | Majors | B+M |
|---|---|---|---|---|
| 1 | 21 | 7 | 10 | 17 |
| 2 | 16 | 6 | 8 | 14 |
| 3 | 16 | 6 | 7 | 13 |
| 4 | 7 | 0 | 3 | 3 |
| 5 | 5 | 0 | 4 | 4 |
| **6** | **2** | **0** | **1** | **1** ← the bottom |
| 7 | 3 | 0 | 2 | 2 |
| 8 | 4 | 0 | 2 | 2 |
| 9 | 6 | 0 | 5 | 5 |
| 10 | 6 | 1 | 5 | 6 |
| 11 | 8 | 1 | 4 | 5 |

**The loop bottomed at pass 6 and has not returned in five passes.**

## Tells

| # | tell | present? |
|---|---|---|
| 1 | finding count rising | **YES** — 2, 3, 4, 6, 6, 8 |
| 2 | Blocker count failing to fall | **YES** — zero for six passes, then 1, 1 |
| 3 | clustering on the instrument | no — the instrument was stripped at pass 4 |
| 4 | clustering on **prose about** either | **YES** — 4 of 8 (findings 1, 5, 7, 8) are the plan's own declarations, accounting and rationale disagreeing with its own shipped text |
| 5 | require↔withdraw pair | not as a pair, but see the regeneration chain below |

**Three present. Stop is mandatory, not discretionary.**

## The regeneration chain, traced

Each round's repair produced the next round's finding, and it is traceable rather than
impressionistic:

- **pass 9** → ship §3 only, mark the deferral by naming the successor story.
- **pass 10 BLOCKER** → that named path ships into the `/workflow-init` template, which
  scaffolds `CLAUDE.md` into *other people's* repositories where the path does not exist.
- **revision 13** → make the pointer `CLAUDE.md`-only, a deliberate divergence.
- **pass 11 BLOCKER** → the divergence is *declared in prose* but never *implemented as a
  step*: the architecture still calls all thirteen edits mirrored, the constraint permits only
  pre-existing divergences, the accounting still names two diverging passages, and Task 12
  still supplies one identical both-copies replacement. **Executing the plan exactly produces
  identical text in both copies and never creates the pointer at all.**

That last one is mine and it is exact: the `CLAUDE.md`-only edit exists in the simulation
source but was never emitted into the plan as a task step, because the generator emits only
the thirteen tasks the notes file drives.

## Two findings worth naming individually

- **NIT 8 — a mis-cited invariant, and the conclusion was still right.** I justified the
  no-downstream-path rule with invariant 7. Invariant 7 governs `examples/` as read-only
  reference and says nothing about story paths in scaffolded templates. What actually supports
  it is the architecture dependency boundary and prompt-standards item 11. The rule I shipped
  is correct; the reason I gave for it was not, which teaches a future maintainer to lean on a
  rule that does not cover the case.
- **MINOR 7 — the accounting overclaims twice.** Row 1 says conditions d–h are "kept verbatim"
  when Task 1 rewrites their wording; row 8 says the hook-invalidation condition is kept when
  Task 7 deliberately *drops* that causal claim and replaces it. The accounting is the plan's
  sole stated guard against dropped conditions, so an inaccurate disposition is the guard
  overclaiming itself.

## The "clearly stuck" reading — offered, not taken

§5 requires three things **together**, and I can state two affirmatively:

1. **A plateau visible across passes** — yes. Six passes since the pass-6 bottom, none
   returning to it.
2. **Blocker/Major regenerating across genuine repair attempts** — yes, and the chain above
   traces it rather than asserting it.
3. **An affirmative judgement that coverage is sufficient** — **I can state this, with one
   caveat named.** Eleven passes have walked the shipped text of both copies, spec §§2–3 and
   §10, §9's exclusion list item by item, the old-conditions accounting, the downstream
   template, and the successor story's reciprocal. I know of no materially unreviewed area
   *within Plan A*. The caveat is that Plans B and C do not exist, so Plan A's interaction
   with them is unreviewed by construction — that is scope, not a coverage gap in this
   artifact.

**But the exit is not mine to take, and I am not taking it.** A clean completion takes
precedence over this exit and we do not have one; reporting "will not converge" would also be
premature while every finding is individually small and fixable. What I am reporting is that
the *shape* now matches the one §5 describes, and that the decision belongs to the human.

## Disposition

All five Blocker/Major carried open. Nothing repaired — the tells rule hands the decision over
rather than permitting another round.

**Cost of resuming, so the choice is informed:** every one of the eight is individually small
and mechanical. The Blocker is a missing task step plus four prose sites to bring into
agreement. None requires a new decision. The question is not whether this round can be fixed —
it can — but whether a loop that has produced a fix-generates-finding chain for five
consecutive passes should keep running in this form.
