# Gate A (spec) — dark-factory vision — pass 2 dispositions
34 findings: 1 BLOCKER, 25 MAJOR, 7 MINOR, 1 NIT. Unprofiled run.
Trend: pass 1 = 52 findings / 41 Blocker+Major; pass 2 = 34 / 26.

## Fixed (all Blocker/Major, plus the cheap Minors)
BLOCKER 1 — gateless plus automatic merge could land an author-only candidate during a
reviewer outage. Decision 5 now makes reviewer availability an input to merge
authorization: a gateless candidate never lands automatically.

Corrections of pass-1 corrections (absorbed, in scope):
- P2-4  my decision-2 edit left AGENTS.md/code/pool as a three-way ambiguity → the three are now named and kept distinct.
- P2-5  my decision-1 edit promised the event "shortens the next tick", which nothing can observe → named as stage-3 polling.
- P2-20 my 5b sat under a clock-loop contract that does not fit a serial station → contract narrowed.
- P2-15 my epic split made the preamble's "each step is one story" false → the unit is the leaf.
- P2-33 step 4's "(decisions 2 and 4)" went stale when 4b/4d/4e were added.
- P2-30 my decision-8 rewrite overstated the evidence: three fallback designs failed, only the first was the same-family tier-2 shape. Corrected — this is the overclaim class AGENTS.md names.

Pre-existing contradictions:
- P2-2  §1 called Freigabe human-only while decision 7 lets a standing rule write it → the pipeline names the authorization state, and decision 6 names the standing-rule operation.
- P2-3  decision 8's knob-everywhere vs §8's four protected paths → knobs are routine touchpoints only.
- P2-6  a meta-story could spawn a meta-story forever → a meta-story is the amendment and produces no further one.
- P2-7  "churn blocks branches, never the factory" vs a global mandatory-stop throttle → the global brake is stated and the guarantee narrowed.
- P2-23 "every clock loop starts report-only" vs the E2E loop filing a story → report-only defined as no code and no status change; filing is the one write.
- P2-29 "filling the pool is always consequence-free" — totality overclaim → "never triggers production", with what it does cost stated.

Missing stations and owners:
- P2-9/10/11/12/13 pipeline gained PR, Bewertungs-Loop, Drift-Audit, the vet preflight and the judge sidecar.
- P2-16/17 step 2 split into 2a/2b/2c; the tracked P8 story stays read-only over the ledger and git, and the vision's analytics, tracing, spec-delta and live cost move to a new 2c. Five stale "[step 2]" references repointed.
- P2-19 step 3 owns the plan interface; the working dry-run lands after 4d and 5a.
- P2-21/22 step 6 split into 6a-6d, giving the promotion path past level-0 an owner.
- P2-28 the blocking hook also meets invariants 2 and 4; the meta-story must say which it amends and which it preserves.
- P2-31/32 the gap-sweep paths are no longer cited, since a clone cannot reach them.
- P2-34 §11's heading no longer claims every question has an owner; the three parked ones are marked.

Recorded in §11 rather than specified (the approved shape): P2-8 Gate B vs the rebase [5b],
P2-14 the hardening ledger has no station [4b/5d], P2-18 promotion evidence [6d],
P2-24 wave-close ordering [4d], P2-25 AC canonicalization [4e], P2-26 the stopped lane [4e],
P2-27 given/when/then and the per-AC test report [4e], P2-9 PR readiness before the queue [5d].

## Collected, not iterated
None outstanding — every pass-2 Minor and the Nit were cheap enough to fix in place.
