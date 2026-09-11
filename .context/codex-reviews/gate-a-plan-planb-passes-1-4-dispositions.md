# Gate A — Plan B cycle — passes 1-4 dispositions

Advisory human note. Not a findings file; participates in no pass validation.

## Curve

| pass | findings | Blockers | Majors | B+M | instrument + prose-about |
|---|---|---|---|---|---|
| 1 | 11 | 2 | 7 | 9 | 2 of 11 (18%) |
| 2 | 3 | 0 | 3 | 3 | 0 |
| 3 | 6 | 0 | 4 | 4 | 1 of 6 (17%) |
| 4 | 10 | 0 | 7 | 7 | 2 of 10 (20%) |

Written lean from the start, so there was no declaration layer to shed: pass 1 opened at 9 B+M
against Plan A's 17. **Instrument and prose-about stayed below a third in every pass**, so the
immediate-routeback condition never fired. This is product churn, not Plan A's disease.

## The cycle-cardinality reading — CONFIRMED, and recorded where it survives

The story's criterion reads *"one per cycle, so a run of all three holds three."* This change
runs **five** cycles: one Gate-A spec, three Gate-A plan, one Gate B.

**Confirmed reading: "one per cycle" is the rule; the clause after "so" is a worked example**
written before the three-plan split existed, and a stale example does not outrank the rule it
illustrates. The five-cycle shape is a consequence of two decisions already taken — the plan
split, and the single Gate-B topology — not a new claim by this plan.

**Recorded in three places on purpose, because two of them do not survive.** This file and the
closure record are under `.context/`, which is gitignored and per-clone: a reading recorded only
here reaches nobody. So it also went into **the plan's binding constraints**, which are
committed, and into the commit body. The example clause itself gets a one-line touch-up in the
final-round story-edit batch, so the next reader meets the corrected example rather than
re-deriving this. **That gitignored records do not reach the next reader is this cycle's own
availability lesson, applied to itself.**

## Absorb-versus-route, and the line this cycle sharpened

Pass 4 said my weakened nonce property contradicted the approved spec and story. **Checking it
changed the fix, and the finding was half wrong** — the first review finding this cycle that did
not survive verification.

```
spec §8: "it must differ from that of any cycle open at the time it was generated
          — which is the uniqueness the rule actually requires, and all it can check."
story:   "unique among cycles open when it was generated"
```

The governing artifacts already say what I shipped. What they also do, and I had collapsed, is
**separate the requirement from what a check can establish** — §5 states the rule, §8 explains
the limit. Restoring that separation implements the contract rather than amending it.

**That is the line between absorb and route**, stated more precisely than before: **a finding is
absorbable when a fix implementing the approved sentence exists** — and here the spec's own
requirement-versus-check structure demonstrated the shape of that fix. Plan A's pass-5 M1 routed
because no such fix existed: every option there changed what the spec promised. Third round on
one axis is a signal to look for the route, not a rule that forces it.

## What my own tooling caught that the review did not

Editing the slot sentence broke Task 1's assert pattern, which still grepped the old wording —
**the plan's own check would have failed at execution.** The generator now refuses to build
unless every assert pattern occurs exactly once in its task's NEW text and zero times in its OLD.

**The first test of that guard did not fire**, because I sabotaged a pattern by truncating a word
and the truncation was still a prefix of the real text — a falsification test that could not
falsify. Re-tested with a genuinely absent pattern and with one that also appears in the OLD
text; the guard fires on both, with the pattern and both counts named. This is §8's wiring rule —
*name the observation that would exist if the claim were false, and confirm the wiring could have
produced it* — practised on my own tooling.

## Collected, not iterated

Three Minors from pass 4: the curve grammar carries no field for the logical-pass versus
hook-call discrepancy its own prose requires be stated; the rejected-bytes record for a
control-bearing model identifier has no defined form; and the accounting calls Tasks 5 and 6 pure
appends when each also rewords a clause.
