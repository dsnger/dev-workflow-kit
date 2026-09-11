# Gate A — Plan A cycle — pass 9 dispositions

Advisory human note. Not a findings file; participates in no pass validation.

## Result

Artifact 3b95e10 (revision 11). VALID pass: terminator exact, 6 finding lines, 0 non-finding
lines. **0 BLOCKER · 5 MAJOR · 1 MINOR = 5 Blocker/Major.**

**MANDATORY STOP-AND-SURFACE. Three tells present. Nothing repaired this pass.**

## The three pass-report lines

**1 — Trend.**

| pass | findings | Blockers | Majors | B+M |
|---|---|---|---|---|
| 1 | 21 | 7 | 10 | 17 |
| 2 | 16 | 6 | 8 | 14 |
| 3 | 16 | 6 | 7 | 13 |
| 4 | 7 | 0 | 3 | 3 |
| 5 | 5 | 0 | 4 | 4 |
| 6 | **2** | 0 | 1 | **1** |
| 7 | 3 | 0 | 2 | 2 |
| 8 | 4 | 0 | 2 | 2 |
| 9 | **6** | 0 | 5 | **5** |

Findings bottomed at 2 on pass 6 and have risen every pass since: **2 → 3 → 4 → 6**. B+M
**1 → 2 → 2 → 5**.

**2 — Cluster.** Split, and the split is the point. Three of six (findings 2, 3, 6) are the
plan's **own descriptive prose contradicting its own shipped text** — a stale task preamble
still describing a rule that was withdrawn, an accounting row whose claims no longer match,
and an expansion from two states to four that left "either" in the sentences below it. The
other three are product behaviour. **Half the pass is now spent on the plan describing
itself inconsistently**, which is where passes 1-3 went before the strip, in a different
costume.

**3 — require↔withdraw.** **PRESENT, and it is a chain rather than a pair.** The
demotion/tells interaction has now been:

- **pass 4 M1** — *required*: the collision between demotion and the five-tells rule must be
  resolved; state the precedence.
- **pass 5 M2** — *required narrower*: the precedence is too broad, limit it to the two-tell
  stop.
- **pass 8 MAJOR 1** — *required removed*: the precedence is out of scope under spec §9 and
  must go. It went.
- **pass 9 finding 3** — *requires more removed*: the remaining per-tell text is also §4 and
  successor-story material, not §3, and should follow it out.

A second, shorter chain in the same pass: **pass 8 MINOR 4** required the coherence rule be
narrowed to normative statements; it was; **pass 9 finding 5** says that narrowing
over-triggers and must be narrowed again.

## Tells

| # | tell | present? |
|---|---|---|
| 1 | finding count rising | **YES** — 2 → 3 → 4 → 6 across four passes |
| 2 | Blocker count failing to fall | no — zero for six passes; it cannot fall further |
| 3 | clustering on the instrument | not as such; the instrument was stripped |
| 4 | clustering on **prose about** either | **YES** — 3 of 6 |
| 5 | a require↔withdraw pair | **YES** — two chains, above |

**Three present. Any two make stop-and-surface mandatory, not discretionary.** Reported and
handed over; no fixes applied, per the rule.

## What I think is happening, offered as a reading and not a decision

**One task is generating most of this: Task 12.** Spec §3 is the severity procedure and that
is what Plan A is licensed to ship. Everything I have added around it — how demotion affects
the finding total, the clusters, the require↔withdraw comparison and the Blocker curve, and
what that means for the two-tell stop — is **spec §4 (the per-pass curve) and successor-story
material**, and §9 excludes both. Each pass has removed one layer of that reach and found
another underneath.

The withdrawal at revision 11 removed the *conclusion* I had drawn. Finding 3 says the
*premises* are equally out of scope. On the text, it is right: "the Blocker curve reads
severity after the ceiling" is a statement about the curve, and the curve is §4, which is
Plan B's.

**The available move is to ship §3 and only §3** — the procedure, the exclusions, the
symmetric instrument carve-out, the rationale rule, coverage-first and the kinship sentence —
and keep every statement about what demotion does to the curve and the tells in **non-shipped
plan prose**, or hand it to the successor story. That is a reduction in what Plan A delivers,
which is why it is not mine to take.

**Findings 1 and 4 are separate and would survive that move**: the governing-header mapping
is still not closed for the multi-plan case this very change executes (Gate B reviews a
combined A+B+C diff and is assigned "the plan's" header, singular), and no rule re-reads the
profile or the header *after* a pass and before accepting it as final, so a concurrent change
during the last pass is invisible. Both are real. Neither was repaired, because the stop
applies to the pass, not to a selection of it.
