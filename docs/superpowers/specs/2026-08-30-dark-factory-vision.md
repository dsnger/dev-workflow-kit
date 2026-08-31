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
Story-Pool — filling is always consequence-free         [missing]
  → Intake-Loop (PROACTIVE: a new story appearing triggers
    classification + architecture verdict, debounced/batched;
    attaches the card, triggers NO production)          [missing]
      ↳ reads the Architektur (AGENTS.md)               [exists, needs one extension]
  → Freigabe (human — the ONLY production trigger;
    reads a rendered wave plan, granularity knob:
    decision 7)                                         [human]
  → Takt-Loop (polls freigegebene stories of the active
    wave → wakes the orchestrator → a lane opens)       [missing]
  → Spec-Loop   (intake + design + Gate A)              [exists]
  → Plan-Loop   (writing-plans + Gate A)                [exists]
  → Bau-Loop    (executing-plans, goal-based, TDD)      [exists]
  → Verify      (battery + Gate B — adversarial model)  [exists]
  → Sample-Gate (draws x% of PRs for human audit)       [missing]
  → Audit (human, sampled)                              [missing]
  → Merge-Queue (serial: rebase onto main → smoke on the
    candidate → green lands, red returns to the lane)   [missing]
  → Merge/Deploy                                        [missing]
```

Every node is a loop with its own fresh context; only the artifact crosses an
edge (story, spec, plan, diff, PR) — never the intermediate steps. A reviewer
therefore judges only the result, never the process: separate eyes need
separate heads, and separate heads come from separate context. Everything that
matters must be *in* the artifact; process facts reach a reviewer only reified
as artifacts (records, findings, evidence entries). The one deliberate
exception is the judge/watchdog: it watches process signals (idle, thrash, no
progress) and judges only liveness, never quality. Mandatory
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
6. **Filling the pool is always consequence-free; classification is a
   proactive loop of its own.** A new story's appearance (debounced into
   mini-batches) triggers exactly one thing: the Intake-Loop attaches the
   classification card and the architecture verdict. Production starts only
   through the human's Freigabe plus the clock. Two rules guard the seam: the
   Intake-Loop only attaches cards, status changes only through defined
   operations (human: freigeben; loop: klassifiziert) — never free-form edits
   by both writers on one field; and in Phase 0 the architecture verdict
   waits until tree v1 exists. The intake zone (pool, Intake-Loop,
   Architektur) is the factory's first stage-4 proactive loop — at the front
   of the pipeline, not the end. "Unclassified" is a transient marker, never a
   working state: the pool is the single entry, and the marker exists only as
   the intake trigger, as visible backlog when the loop stalls, and for Phase
   0's deferred architecture verdicts.
7. **Freigabe reads a rendered wave plan; its granularity is a maturity knob.**
   The card answers "can this be built" — Freigabe answers "should this be
   built now": value and timing, profile confirmation, capacity, and a
   spot-check of the card (a Freigabe that regularly needs deep thought means
   the card is missing a dimension → labeled example, tighten intake). The
   knob: per story → batch → wave ("Go" on the rendered wave plan) → standing
   auto-Freigabe (notified, not asked). Three things hold on every rung: flags
   always escalate (high profile, architecture ⚠, rückfragen, scope doubt);
   the knob is human-owned and committed, changed only by defined operation
   (like `lanes`); and the plan is rendered on every rung — as a question or
   as a notice. Raising the rung follows measured P8 evidence, never precedes
   it (non-goal 4).
8. **Four-eyes principle, with a scaling guard.** No artifact passes only its
   author. The second pair of eyes is another model by default; in the
   availability emergency (reviewer down, tokens exhausted) the same model as
   a **different agent with fresh context** — never the same agent (the kit's
   shipped two-tier reviewer fallback embodies this). Human eyes only where
   the frequency is bounded — O(waves + exceptions), never O(stories) — and
   every mandatory human touchpoint carries a maturity knob that lowers with
   P8 evidence: presence is a dial that falls with trust, never a ratchet.
   Two concrete rules: an architecture merge triggers re-classification of
   the cards on the touched branches (their architecture verdicts are stale —
   mechanical, no human involved); and the Sample-Gate draws architecture
   merges at 100% as the starting value, knob downward with evidence —
   bounded, because architecture changes batch into one meta-story per wave
   (§9).

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
  invariants, verified commands, conventions, **plus two extensions this vision
  requires: project goals and an explicit out-of-scope list**, which the
  classification's reject verdict reads, **and two verified command roles,
  `smoke` and `e2e`**, beside quality/lint/test (test layers, §9). One document, read by gates, bots and
  triage alike.
- **A project's roadmap is a view, not a document**: pool items plus status,
  priority, dependencies and **wave** yield the order. The pool is the single
  source; a separate roadmap file would be a second copy that drifts.
- **The execution plan is a computed view too** — the wave dry-run: dependency
  graph (classification) + tree topology (the parallelism map) + waves and
  priorities (human) + lanes and throttles yield lane assignments and order.
  Recomputed at wave opening and every tick, never stored; the human
  intervenes through the inputs, never by editing the plan. It generalizes
  the orchestrator dry-run (build step 3). Waves are milestones that also
  *steer* — the clock pulls only the active wave — so the roadmap is the
  milestone-level view and the wave plan its per-milestone detail.
- **Waves structure a new project.** Phase 0 assigns every initial pool item a
  wave mark (wave 1, 2, … or named milestones) — the deliberate "these
  subareas develop together first, those later" decision, usually aligned with
  tree branches but not required to be. The orchestrator pulls only from the
  active wave (a focus throttle beside the lanes budget: lanes = how much at
  once, wave = what at all). Opening the next wave is the human's call (or
  automatic when the prior wave is fully merged — settled by build step 4).
  Later stories get their wave mark at classification.
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
8. **Wave** — which development wave the item belongs to (§4); assigned in
   Phase 0 for initial items, at classification for later ones.

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
5. Stage 3: clock and event loops (poll, audit, PR processing) — including the
   E2E clock loop (failures auto-filed as pool stories) and the merge-queue
   station (rebase + smoke on the candidate), see §9.
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

## 9. Parallelism and flow control (decisions 2026-08-30, Daniel)

- **Phase 0 exists once.** Initial brainstorming builds architecture tree v1
  plus goals/out-of-scope before production starts. It is the only
  everything-waits moment; after it, intake never freezes. It has two inputs:
  a green field derives tree v1 from the pool; an existing project reads it
  from the codebase (natural home: a `/workflow-init` extension). Tree v1 need
  only be good enough to judge with — meta-stories correct it in use
  (decision 3). A single incoming story is simply a mini-wave: the views
  collapse to one line, no stage is skipped.
- **Architecture churn blocks branches, never the factory.** An
  architecture-relevant story is not rejected: classification parks it with
  warten-auf behind its meta-story, and the meta-story locks exactly the tree
  branches it touches. Stories on other branches keep flowing. The
  Bewertungs-Loop batches architecture-relevant items into one meta-story per
  wave instead of serial tree churn; the meta-story's priority is the human's
  knob (pull it forward to unlock branches sooner, or defer it and let the
  parked stories wait).
- **The tree is the parallelism map.** Disjoint branches run in parallel
  (N worktrees × one pipeline each — possible today; the record/nonce rules
  are the foundation); same branch serializes. Classification's dependency and
  architecture verdicts yield the schedule. Within a story, stages fan out to
  subagents; Gate B's two review branches already run in parallel. What does
  not parallelize: the serial passes of one review loop, the merge queue to
  main, and the human's decisions.
- **The parallelism budget is a user-owned knob.** It lives in the story
  pool's header (one committed, visible place, e.g. `lanes: 3`), is never
  written by an agent, and is read fresh by the orchestrator at every tick —
  raising it buys throughput while the tree has disjoint branches; lowering it
  throttles token spend (`lanes: 0` pauses intake of new lanes; running lanes
  drain). Two automatic throttles on top: no new lane opens while any lane
  stands in a mandatory stop, and no new lane opens while more than N
  decisions are queued for the human — the measured bottleneck is decision
  bandwidth, not compute.
- **Three test layers, three cost classes** (decided 2026-08-31). The lane
  battery (seconds, every cycle, exists) · a **smoke gate in the merge queue**
  (minutes, every merge, new) · the **full E2E suite as a clock loop** (hours,
  nightly or at wave close, stage 3). The merge queue is a station of its own:
  serial, per candidate rebase onto current main → smoke on the composed
  candidate → green lands, red returns to the lane as an artifact (like Gate-B
  findings) while the queue continues with the next branch — main is never
  red and no human is involved; repeated failure escalates via the judge.
  This closes the parallelism blind spot (disjoint lanes each green, their
  composition broken) and owns the merge-coordinator mechanics (rebase,
  retry). An E2E failure becomes a pool story automatically, classified by
  the normal intake, carrying the trace ID of the suspect merge. Concrete
  tools stay project truth: AGENTS.md gains the command roles `smoke` and
  `e2e`. Cadence and flaky rules belong to step 5.

## 10. Prior art: godarkfactory.com (reviewed 2026-08-30)

A shipped, self-hosted dark factory (Go binary `godark`, Elastic License 2.0,
beta): GitHub issues grouped into milestone "phases", topological dependency
waves, a three-agent loop (implement → quality+functional review → auto-merge)
in Docker sandboxes, all agents Claude. Validates most of this vision's shape
— milestones↔waves, scenario specs↔pre-build checks, define-architecture /
define-conventions↔Phase 0, watch↔clock loops, needs-human-review↔escalation.

**Adopted into the build path** (owning step in brackets):
- Local SQLite analytics — cost/duration/retries per step, written
  non-fatally post-run; plus a trace ID per story propagated through every
  stage artifact, and mechanical spec-delta capture. [step 2 — this is P8's
  concrete shape]
- Orchestrator dry-run (print the tick's execution plan before spending
  tokens) and a forced-fresh-session knob (`max_resume_retries` analog) —
  turns gap 7 into a mechanism. [step 3]
- Mechanical vet preflight on pool items and artifacts before any model pass;
  numeric split thresholds for the teilen verdict (their working values: max
  5 acceptance criteria, 7 test cases); a machine-readable architecture
  projection (may_depend_on / must_not_depend_on, cycle-checked) *generated
  from* AGENTS.md — never a second source. Their GitHub-issues-as-pool is a
  working data point for the pool-storage question. [step 4]
- A judge watchdog (idle / tool-thrash / no-progress supervisor that is not
  the hanging model) and push notifications on run events — the human is the
  bottleneck; push, don't make them poll. [step 5]
- Graduated auto-merge with mechanical risk thresholds (max lines/files) as
  an independent floor under the semantic profile; punchlist generation as
  the artifact a sampled audit works from. [step 6]

**Deliberately not adopted:** `quality_strictness_decay` (their default —
review gates weaken as retries mount; the inverse of the clean-final-pass
rule); same-model review (their implementer and reviewers share one model
family — correlated blind spots; our adversarial gate stays cross-model);
daemon/Docker/GitHub as hard requirements (non-goal 1 stands); stop-the-world
sequential milestones (branch-scoped locks and the lanes budget replace it).

**Their documented scars, kept as constraints here:** manual state mutation
under an automated resolver breaks it — every hand-edit of pool status must
be a defined operation; planning artifacts need a defined home so they never
contaminate implementation branches; run artifacts need a retention stance
from day one (their P0 gap: unbounded disk growth); absent real-time cost
visibility is what makes a token furnace invisible (their P0 gap, our P8).

## 11. Open questions (owned by the stories that will answer them)

- Sample percentage and drawing rule for the Sample-Gate (step 6).
- Storage form of the pool (files in-repo vs. external board) — step 4.
- Hidden verification scenarios (checks written before build, unseen by the
  builder) as a Gate-B supplement — candidate small story, unscheduled.
- How the clock's platform mechanics (loop/schedule) are configured per
  project — step 5.
- Process dashboard / console status — "when is what running where"; builds
  on the computed views plus P8 trace/analytics. Parked 2026-08-30, design
  session planned 2026-08-31.
- Sensible hooks and shortcuts through the pipeline for flexible use cases.
  Parked 2026-08-30, same session.
- Test layers are decided (§9); still open: whether a smoke failure that
  returns to a lane is surfaced to the human (a dashboard question), and the
  E2E cadence / flaky-handling rules — step 5.
