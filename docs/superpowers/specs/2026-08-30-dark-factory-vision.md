# Dark Factory — target vision and decomposition

**Date:** 2026-08-30 · **Kind:** decomposition document, not an implementation spec.
Each build step below becomes its own story through the normal workflow
(intake → spec → Gate A → plan → Gate A → execute → Gate B). Nothing in this
document is executable on its own, and nothing here overrides a shipped rule.

Brainstormed 2026-08-30 (Daniel + sparring session); all decisions below are
Daniel's, taken in that session. Inspiration: the loop/graph-engineering framing
from an external video (four loop maturity stages; artifacts as the only handoff
between fresh-context nodes; a "dark factory" as a repository that ships its own
code, policed by an adversarial model with sampled human audit).

## 1. The vision

Stories and ideas flow into a pool. The factory turns approved pool items into
merged, reviewed software with the human concentrated where human judgement
measurably matters — and, at full maturity, sampled rather than omnipresent:

```
Story-Pool (status: draft → freigegeben)
  → Takt-Loop (polls the pool)                          [missing]
  → Klassifizierung (classification card, may reject/split/ask)  [missing]
  → reads Projekt-Wahrheit: AGENTS.md                   [exists, needs one extension]
  → Spec-Loop   (intake + design + Gate A)              [exists]
  → Plan-Loop   (writing-plans + Gate A)                [exists]
  → Bau-Loop    (executing-plans, goal-based, TDD)      [exists]
  → Verify      (battery + Gate B — adversarial model)  [exists]
  → Sample-Gate (draws x% of PRs for human audit)       [missing]
  → Audit (human, sampled) → Merge/Deploy               [missing]
```

Every node is a loop with its own fresh context; only the artifact crosses an
edge (story, spec, plan, diff, PR) — never the intermediate steps. Mandatory
stops, scope questions and architecture re-evaluations escalate to the human;
the factory stops and reports instead of spinning. A human override becomes a
labeled example for tightening the rules.

The kit already holds the middle of this pipeline, and in one respect exceeds
the inspiration: the adversarial verifier is a different model *family*
(Codex), not merely a different context.

## 2. Decisions (all 2026-08-30, Daniel)

1. **Orchestrator lives hybrid.** The orchestrator is kit prompts (a skill /
   agent definition any session can load — the product stays prompts). Only the
   *clock* uses platform mechanics: a scheduled/loop wake-up starts an
   orchestrator session. No daemon, no server-side infrastructure.
2. **Project truth is AGENTS.md, and the architecture tree is subordinate to
   the pool.** The architecture is built *from* the pool initially and
   continuously re-evaluated against it (Bewertungs-Loop), versioned, living in
   AGENTS.md beside the invariants and conventions. No second architecture
   document that could drift.
3. **Architecture re-evaluation is a meta-story through the same factory.**
   When a story breaks the tree, classification produces a story "extend the
   architecture for X" with a high risk profile (heavy review, human in the
   loop); the triggering story waits on it. One process for everything — the
   factory rebuilds itself the same way it builds features.
4. **Classification is the mandatory first station.** Every new pool item gets
   the card (§5 below) before anything else; only "freigegeben" is pulled by
   the clock.
5. **End state is sampled audit, not per-merge approval.** The adversarial
   gate checks every merge; the human audits a sample. No merge skips both
   gates. (Until step 6 of the build path matures, merge remains human.)

## 3. Maturity ladder

| Stage | Loop kind | Status in the kit |
|---|---|---|
| 1 | Turn-based — skills with self-checks, red-first tests | shipped |
| 2 | Goal-based — acceptance criteria as target, gates loop to clean with mandatory stops | shipped |
| 3 | Time-based — clock loops: poll the pool, drift audits, PR-bot processing | missing |
| 4 | Proactive — event-triggered: a spec turns "freigegeben" and the factory runs | missing |

## 4. Conventions and roadmap — where each truth lives

- **Kit conventions** (travel with the plugin): the workflow itself — gates,
  profiles, loop rules, prompt standards, the classification card. Home: the
  kit's prompts. They are the product.
- **Project conventions** (per target project): AGENTS.md — architecture tree,
  invariants, verified commands, conventions, **plus one extension this vision
  requires: project goals and an explicit out-of-scope list**, which the
  classification's reject verdict reads. One document, read by gates, bots and
  triage alike.
- **A project's roadmap is a view, not a document**: pool items plus status,
  priority and dependencies (from classification) yield the order. The pool is
  the single source; a separate roadmap file would be a second copy that
  drifts.
- **The kit's own roadmap** to this vision is §7 of this document.

## 5. The classification card

Every new pool item is classified before anything else. Dimensions 1–4 exist
in the intake skill today; 5–7 are new:

1. **Size** — story, or epic that must be split.
2. **Risk/security profile** — drives floor, lenses, evidence mode.
3. **Completeness** — too thin → one question back to the human; nothing is
   invented.
4. **Invariant touch-list** — which AGENTS.md invariants the item affects.
5. **Scope verdict** — inside project goals? Duplicate of a pooled or in-flight
   story? Violates an invariant by design? (Source: the goals/out-of-scope
   extension of AGENTS.md.)
6. **Architecture verdict** — from the Bewertungs-Loop: seamless, or
   re-evaluation needed (→ meta-story per decision 3).
7. **Dependencies** — needs story Y first → wait mark and ordering.

Verdicts: **freigeben / teilen / rückfragen / warten-auf / ablehnen** (with
reason, back to the human — rejection is never deletion). Split rules: multiple
independent subsystems in one item; mixed profiles in one item (so the cheap
part gets the cheap floor); mixed architecture verdict (the seamless part
proceeds, the breaking part waits on the meta-story).

## 6. Gaps (current state → vision)

1. Story pool with status — the factory's trigger. *(missing)*
2. Classification station beyond intake's current card (scope, architecture,
   dependency dimensions). *(missing)*
3. Architecture tree + Bewertungs-Loop in AGENTS.md. *(missing)*
4. Orchestrator as product — the sparring-session practice codified as
   skill/agent: question routing, artifact handoff, prediction ledger, batched
   human decisions. *(missing; exists as practice)*
5. Time-based and proactive loops (stage 3/4). *(missing)*
6. Sample-Gate + sampled audit. *(missing)*
7. Fresh context per stage is convention, not enforced — long sessions
   measurably degrade. *(partial)*
8. Same-repo parallelism — N worktrees × 1 agent works today; the record/nonce
   rules of the in-flight review-economics story are the foundation for more.
   *(in flight)*

## 7. Build path (each step = one story through the normal workflow)

1. Finish the review-economics story (in flight) — floors by profile, severity
   calibration, measurable records. Without calibrated review economics every
   factory is a token furnace.
2. Loop-rule consolidation (successor story) + P8 passive metrics — measure
   before automating further.
3. Orchestrator story (codify the role as skill/agent per decision 1).
4. Story pool + status + classification + architecture tree (decisions 2 and 4).
5. Stage 3: clock and event loops (poll, audit, PR processing).
6. Stage 4 + sampled audit (decision 5) — full automation first only for
   level-0 stories; merge stays human until this step ships and holds.

## 8. Non-goals

- No daemon or server-side runner (decision 1).
- No second architecture or roadmap document (decisions 2, §4).
- No removal of the human from mandatory stops, profile confirmations, scope
  changes, or architecture meta-stories — "dark" means sampled presence, not
  absence.
- No autonomy expansion ahead of the measured evidence (P8) that the review
  economics support it.

## 9. Open questions (owned by the stories that will answer them)

- Sample percentage and drawing rule for the Sample-Gate (step 6).
- Storage form of the pool (files in-repo vs. external board) — step 4.
- Hidden verification scenarios (checks written before build, unseen by the
  builder) as a Gate-B supplement — candidate small story, unscheduled.
- How the clock's platform mechanics (loop/schedule) are configured per
  project — step 5.
