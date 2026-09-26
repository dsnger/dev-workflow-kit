# Dark Factory — target vision and decomposition

**Date:** 2026-08-30 · **Kind:** decomposition document, not an implementation spec.
Each *leaf* build item below becomes its own story through the normal workflow
— the numbered entries in §7 are ordering groups, and where one carries
lettered leaves (2a, 4a…, 5a…, 6a…) those leaves are the story owners
(intake → spec → Gate A → plan → Gate A → execute → Gate B). Nothing in this
document is executable on its own, and nothing here overrides a shipped rule.

Brainstormed 2026-08-30 (Daniel + sparring session); all decisions below are
Daniel's, taken in that session. Inspiration: the loop/graph-engineering framing
from an external video (four loop maturity stages; artifacts as the only handoff
between fresh-context nodes; a "dark factory" as a repository that ships its own
code, policed by an adversarial model with sampled human audit).

**Follow-up decision, 2026-09-17 (Daniel):** record generated HTML views and
review-loop usefulness assessment in the roadmap. This authorizes the planning
additions below, not their implementation or a change to current review rules.

## 1. The vision

Stories and ideas flow into a pool. The factory turns approved pool items into
merged, reviewed software with the human concentrated where human judgement
measurably matters — and, at full maturity, sampled rather than omnipresent:

```
Story-Pool — filling never triggers production          [missing]
  → Intake-Loop (PROACTIVE: a new story appearing triggers
    classification, debounced/batched; attaches the card,
    triggers NO production)                             [missing]
      ↳ reads the Architektur (AGENTS.md)               [exists, needs one extension]
      ↳ asks the Bewertungs-Loop for the architecture
        verdict, and attaches the answer it returns     [missing]
  ⟳ Bewertungs-Loop (the single producer of every
    architecture verdict: answers Intake's request,
    continuously re-evaluates the tree against the pool,
    produces the meta-stories of decision 3, and
    re-classifies the cards an architecture merge made
    stale)                                              [missing]
  → Freigabe (the ONLY production trigger; the human, or
    a standing rule the human installed — decision 7;
    reads a rendered wave plan)                         [human]
  → Takt-Loop (polls freigegebene stories of the active
    wave → wakes the orchestrator → a lane opens). The
    orchestrator is itself a model-operated node here,
    so the vet preflight, fresh context, artifact-only
    handoff and the judge all cover it                  [missing]
  → Spec-Loop   (design + Gate A — the item was already
    intaken and profiled at classification, so intake
    does not run twice)                                 [exists]
  → Plan-Loop   (writing-plans + Gate A)                [exists]
  → Bau-Loop    (executing-plans, goal-based, TDD)      [exists]
  → Verify      (battery + Gate B — adversarial model)  [exists]
  → PR (open it, then apply the routing table in
    docs/pr-review-bots.md — its Wait-for list is empty,
    so nothing blocks: read what the opportunistic bots
    have posted, handle later posts as follow-ups)      [exists]
  → Sample-Gate (draws x% of PRs for human audit)       [missing]
      ↳ drawn     → Audit (human, sampled)              [missing]
      ↳ not drawn → straight on (the ordinary path)     [missing]
  → Merge-Queue (serial: rebase onto main → smoke on the
    candidate → green lands, red returns to the lane)   [missing]
  → Merge — the factory ends here; release and deploy
    are the project's own CI (§8)                       [missing]

  ⟳ E2E-Loop (clock: nightly or at wave close; a failure
    is filed back into the Story-Pool, §9)              [missing]
  ⟳ Drift-Audit (clock: docs drift, reverse traceability;
    report-only, findings land in the Story-Pool)       [missing]

  ┄ Vet preflight — mechanical checks run before every
    model-operated node above (§10)                     [missing]
  ┄ Judge/watchdog — sidecar over the model loops and
    the queue; liveness only, escalates to the human    [missing]
```

Every *model-operated* node is a loop with its own fresh context — the pool is
a store, Freigabe and Audit are human, the merge queue is a mechanical
operation. Only the artifact crosses an edge (story, spec, plan, diff, PR) —
never the intermediate steps. A reviewer
therefore judges only the result, never the process: separate eyes need
separate heads, and separate heads come from separate context. Everything that
matters must be *in* the artifact; process facts reach a reviewer only reified
as artifacts (records, findings, evidence entries). The one deliberate
exception is the judge/watchdog: it watches process signals (idle, thrash, no
progress) and judges only liveness, never quality. Mandatory
stops, scope questions and architecture re-evaluations escalate to the human;
the factory stops and reports instead of spinning. A human override becomes a
labeled example for tightening the rules — and it moves only knobs the human
already owns: it never waives a mandatory stop, a gate obligation, profile
evidence or an AGENTS.md invariant (CLAUDE.md §5: such a record "supplies no
permission").

The kit already holds the middle of this pipeline, and in one respect exceeds
the inspiration: the adversarial verifier is a different model *family*
(Codex), not merely a different context.

## 2. Decisions (Daniel; 2026-08-30 unless dated otherwise)

1. **Orchestrator lives hybrid.** The orchestrator is kit prompts (a skill /
   agent definition any session can load — the product stays prompts). Only the
   *clock* uses platform mechanics: a scheduled/loop wake-up starts an
   orchestrator session. No daemon, no server-side infrastructure. The stage-4
   event wake (§3) is another adapter under this same boundary — a platform
   trigger that *starts* a session, never a resident listener. Where a platform
   offers no such trigger there is no stage-4 wake at all: the story waits for
   the next scheduled tick. That is stage-3 polling at the configured latency
   and is named as such rather than counted as proactive.
2. **Project truth is AGENTS.md, and the architecture tree is subordinate to
   the pool.** Three things can disagree and stay distinct: the **approved
   tree** in AGENTS.md (normative — what classification reads), the **code**
   (observed fact), and the **pool** (intent). On a green field the approved
   tree is built *from* the pool; on an existing codebase tree v1 is read from
   the code (§9). Phase 0's job is to make the approved tree agree with the
   code before it becomes authoritative. Afterwards a code/tree divergence is
   drift that the audit reports, and a pool/tree divergence is what produces a
   meta-story (decision 3) — neither is resolved silently. Either way
   the tree is continuously re-evaluated against the pool (Bewertungs-Loop),
   versioned, living in AGENTS.md beside the invariants and conventions. No
   second architecture document that could drift.
3. **Architecture re-evaluation is a meta-story through the same factory.**
   When a story breaks the tree, classification produces a story "extend the
   architecture for X" with a high risk profile (heavy review, human in the
   loop); the triggering story waits on it. A meta-story *is* the architecture
   amendment, so it is classified as one and never produces a further
   meta-story — that is what stops the recursion — while keeping the branch
   lock and the human escalation its high profile earns. One process for
   everything — the factory rebuilds itself the same way it builds features.
4. **Classification is the mandatory first station.** Every new pool item gets
   the card (§5 below) before anything else; only "freigegeben" is pulled by
   the clock.
5. **End state is sampled audit, not per-merge approval.** The adversarial
   gate checks every merge; the human audits a sample. No merge skips both
   gates — so **reviewer availability is an input to authorization**, and the
   answer to an outage is to **wait where the outage happens**: a Gate-A
   outage stops the lane before any candidate exists, a Gate-B outage holds
   the work at Verify, and a candidate already queued stays queued. Nothing
   advances past an unfinished gate, and **no human substitutes for the
   gate**.
   Sampled audit is QA, never authorization, and never stands in for an active
   gate. "Gateless" exists only as a *declared project state*, and the shipped
   declaration is the tracked **INACTIVE notice** `/workflow-init` writes into
   the project's own CLAUDE.md ("the gates below do not run"). The
   `.context/codex-gate.off` marker beside it is not that declaration: it
   suppresses the hook reminder in one workspace, and shipped CLAUDE.md says
   plainly that with it in place "the gates still apply". (Whether a clone
   sees the marker depends on the repo: this kit ignores all of `.context/`,
   while `/workflow-init` has target projects ignore `/.context/codex-reviews/`
   specifically — so in a scaffolded project the marker is visible and
   committable.) Neither file authorizes anything. That leaves the
   reviewer-availability question exactly where its own record left it. (Until step 6 of the build path
   matures, merge remains human anyway.)
6. **Filling the pool never triggers production; classification is a
   proactive loop of its own.** (It is not free of *all* consequence — it
   spends tokens, writes a card and a status, may create a meta-story and may
   queue a question. What it cannot do is open a lane or merge code.) A new story's appearance (debounced into
   mini-batches) triggers exactly one thing: the Intake-Loop attaches the
   classification card and the architecture verdict. Production starts only
   through the human's Freigabe plus the clock. Two rules guard the seam: the
   Intake-Loop only attaches cards, status changes only through defined
   operations (human: freigeben; loop: klassifiziert; a standing rule:
   freigeben, carrying the committed rule as its authority and leaving its own
   audit record — decision 7) — never free-form edits by several writers on
   one field; and in Phase 0 the architecture verdict
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
   auto-Freigabe (notified, not asked; the standing rule sets the status
   *freigegeben* itself, so decision 4 holds — the clock still pulls only
   *freigegeben*). Three things hold on every rung: flags
   always escalate (high profile, architecture ⚠, rückfragen, scope doubt);
   the knob is human-owned and committed, changed only by defined operation
   (like `lanes`); and the plan is rendered on every rung — as a question or
   as a notice. Raising the rung follows measured P8 evidence, never precedes
   it (§8, "No autonomy expansion ahead of the measured evidence").
8. **Four-eyes principle, with a scaling guard.** No artifact passes only its
   author. The second pair of eyes is another model *family*; where a project
   has none configured, the honest answer is to be **gateless and say so** — a
   declared, visible project state, never self-reviewed and not a same-family
   agent either. A *runtime* outage is a different thing and is no licence to
   close a cycle: the work waits (decision 5). What ships today is "be
   gateless — not self-reviewed" (`docs/coding-workflow.md`,
   `/workflow-init`), and this vision assumes nothing beyond it. What was
   closed with a negative answer is narrower than "a same-family reviewer":
   three fallback designs across nine Gate-A passes and 303 findings failed to
   produce a safe *sanctioned zero-pass closure*
   (`docs/superpowers/specs/2026-08-14-reviewer-availability-fallback-design.md`).
   A same-family tier-2 reviewer is a different question and is **still open**
   as a tracked, unshipped story
   (`docs/superpowers/stories/2026-08-14-tier-2-same-family-reviewer-story.md`)
   — "a weaker review is still a review", per that design's §7, if its
   containment proves buildable. If it ever ships, this decision follows it;
   until then the second pair of eyes is another family, or none. Human eyes only where the frequency is bounded — O(waves +
   exceptions), never O(stories) — **as the end state**, which the rollout
   deliberately does not satisfy yet: decision 7's lower rungs are per-story
   and decision 5 keeps merge human until step 6. The bound is the target the
   knobs move toward, not a rule the bootstrap already obeys. Every mandatory
   human touchpoint carries a maturity knob that lowers with
   P8 evidence — but a knob exists only at *routine* touchpoints: Freigabe
   granularity, sample rates, wave opening. The four paths §8 protects (mandatory stops,
   profile confirmations, scope changes, architecture meta-stories) carry no
   such knob and stay human at every rung. Where a knob does exist, presence
   is a dial that falls with trust and rises again on adverse evidence, never
   a ratchet.
   Two concrete rules: an architecture merge triggers re-classification of
   the cards on the touched branches (their architecture verdicts are stale —
   mechanical, no human involved); and the Sample-Gate draws architecture
   merges at 100% as the starting value, knob downward with evidence —
   bounded, because architecture changes batch into one meta-story per wave
   (§9).
9. **Acceptance criteria are read-only inside a lane** (2026-08-31). A
   builder never edits the acceptance criteria of the story it builds — that
   is the reward-hacking vector the inspiration warns about. An acceptance
   criterion found wrong during build is a story mutation, not a spec edit:
   the lane stops, the story returns to the pool flagged "AC change needed",
   the human decides (an exception path, so O(exceptions)), and the story
   re-enters classification. Descriptive spec details a fix changes are
   still updated in the same commit (CLAUDE.md §5 stands); every spec change
   is captured as spec-delta (§10, step 2c) and shown to the reviewer beside
   the diff, so baseline and change are both visible. Mechanically:
   acceptance criteria carry IDs (§10 second sweep), the AC block's
   fingerprint is compared at Gate B, and a changed block without the pool
   round-trip is a Blocker.

## 3. Maturity ladder

| Stage | Loop kind | Status in the kit |
|---|---|---|
| 1 | Turn-based — skills with self-checks, red-first tests | shipped |
| 2 | Goal-based — acceptance criteria as target, gates loop to clean with mandatory stops | shipped |
| 3 | Time-based — clock loops: poll the pool, drift audits, PR-bot processing | missing |
| 4 | Proactive — event-triggered: first instance is the intake zone (a story appearing triggers classification, decision 6); later a story turning "freigegeben" wakes the orchestrator without waiting for the tick | missing |

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
- **The live status is a computed view too — the dashboard (decided
  2026-08-31).** The orchestrator writes a state snapshot every tick;
  deterministic code — never a model, so a tick costs no tokens — renders
  it into a local `status.html` (auto-refresh, with a visible staleness
  stamp: "Stand 17:03 · Tick 42" — a dashboard that silently ages is worse
  than none), a status-line ticker, and optionally a menu-bar script; a
  console command renders the same snapshot on demand. The top element is
  always the human's decision queue (flags, rückfragen, mandatory stops,
  drawn audits) — the queue that throttles the factory. Events that need
  the human push (§10); the dashboard is for looking, never for polling.
  LLM summaries only on demand. Rejected: a daemon/TUI and a hosted
  artifact page (account-bound). The wave plan and the dashboard share one
  renderer — the plan is the forecast, the dashboard is the now.
- **HTML is a generated presentation, not another maintained source
  (decided 2026-09-17).** Existing Markdown todos, stories and planning
  documents remain the authored sources; task lists, task details and progress
  views are rendered from them and the available workflow records. Do not
  replace them with hand-maintained HTML or maintain status in both formats.
  The owning story must define stable item identities, explicit status,
  priority, dependencies, parking triggers and evidence links. Missing values
  remain unknown; an unchecked backlog box alone does not establish active
  work, and raw checkbox counts are not a completion percentage. Every view
  shows its source revision and generation time; live views also show the
  snapshot/tick freshness above. A first static snapshot view may precede live
  telemetry, provided it is labelled as a snapshot. This does not decide the
  future pool's storage format (4a).
  **Consumer evidence, 2026-09-17:** the [SFX field report](../../field-reports/2026-09-17-sfx-review-loop-economics.md)
  adds two source requirements: display installed workflow version, observed
  loaded version (or unknown) and project-local rule revision separately;
  bind implementation, test evidence and review/acceptance status to their own
  revisions. An older handover or a reported test result must not silently
  become verification of the current HEAD, nor a single green completion state.
- **Review-loop usefulness is a separate dashboard requirement
  (recorded 2026-09-17; not implemented).** Step 2c owns the measurement and
  assessment design, using P8's evidence where available without widening P8.
  Begin with visible dimensions and an explained traffic-light assessment;
  a composite score follows only once its calibration is supported by data:
  - yield: confirmed, distinct material findings, linked to their evidence;
  - repair effects: recurrence, reopened findings and findings introduced by
    a repair, with uncertain attribution labelled as such;
  - effort: elapsed time, tokens and cost where attributable;
  - coverage: reviewed scope and known gaps, including evidence limitations.
  Few findings do not establish poor usefulness or sufficient coverage, and
  many findings do not establish high usefulness. A clean verification pass
  can be useful. An instrument finding is judged by its consequence, not
  discounted solely because it concerns the instrument.
  **Product impact governs review effort (Daniel, 2026-09-17).** The more
  indirect the evidenced effect on the operating product, the less tolerance
  there is for additional review and repair rounds without a concrete failure
  consequence and a justified expected benefit. Distance means the causal path
  to product behaviour, not the file extension: shipped prompts can act directly
  on the product, and plan shell commands can invalidate its verification.
  Product behaviour, security and data integrity receive the strongest scrutiny.
  Execution and verification machinery is checked for reliable outcomes;
  further hardening or optimization must justify its benefit. Explanatory prose,
  presentation and hypothetical edge cases without an operative consequence
  receive less effort and do not justify continued repair loops.

  **Lower thresholds mean earlier reassessment, not lower severity.** The
  threshold design must distinguish direct product work, plan/execution
  machinery and non-operative material, with earlier warnings and escalation
  for repeated instrument work when its marginal benefit is unsubstantiated.
  Unknown impact requires clarification, not an automatic low-risk label.
  A real security or correctness defect is not discounted by its location;
  false-green, false-red and valid-change-blocking failures retain the existing
  consequence-based assessment. Purely hypothetical robustness gains and
  performance tuning of rarely executed helpers need a demonstrated use case
  and material cost to justify further rounds.
  Show time and repair rounds spent on the instrument alongside evidenced
  benefits and any observable delay to product work; a high instrument share
  is a warning, not proof of waste. Escalation offers simplification, a different
  review method or stopping the approach, without automatically continuing
  repairs or advancing to implementation with unmet conditions.
  **Calibration acceptance cases:** distinguish harmless explanatory polish
  from a plan command that corrupts review evidence; distinguish speculative
  helper optimization from an observed product bottleneck; keep a useful clean
  verification pass distinct from a pass with unknown coverage. Record the
  evidence and expected recommendation for each, rather than assigning priority
  solely from the artifact's name. This is a future assessment requirement,
  not the experimental one-repair-round cap parked in `todos.md`.

  **Field-informed calibration requirements:** the SFX report above supplies
  recounted curves, not calibrated cutoffs. Record finding origin (including
  repair-induced, with attribution evidence/confidence) separately from its
  product consequence and effort; distinguish optional Minor/Nit repairs from
  required fixes. Classify helper tools by the files/state they can change and
  decisions they affect, not by a `docs/` path. Compare cycles under documented
  workflow/rule revisions and profiles; preserve unknowns rather than claiming
  an efficiency improvement from raw counts or mixing incompatible contexts.

  **Before implementation:** specify each metric's source, counting and
  deduplication rules, comparison window and missing-data behaviour; define
  candidate warning/escalation thresholds and any score weights; evaluate
  them on recorded cycles and document their limitations. Link each proposed
  threshold to an explained recommendation (continue, change review method,
  or stop and surface). Missing evidence must not become a green assessment.
  No numeric thresholds or weights are settled here. Existing pass floors,
  mandatory tells, finding-resolution duties and closure conditions remain
  unchanged: the assessment cannot waive them or close an unclean cycle.
  Automatic actions or changes to those rules need a separately authorized
  design; this entry introduces neither.
- **Waves structure a new project.** Phase 0 assigns every initial pool item a
  wave mark (wave 1, 2, … or named milestones) — the deliberate "these
  subareas develop together first, those later" decision, usually aligned with
  tree branches but not required to be. The orchestrator pulls only from the
  active wave (a focus throttle beside the lanes budget: lanes = how much at
  once, wave = what at all). Opening the next wave is the human's call; it
  becomes automatic on prior-wave completion only where the human has raised
  decision 7's knob to a standing rule for it, because an unasked wave opening
  is a production trigger like any other (settled by build step 4).
  Later stories get their wave mark at classification.
- **The kit's own roadmap** to this vision is §7 of this document.

## 5. The classification card

Every new pool item is classified before anything else. Dimensions 1–4 exist
in the intake skill today; 5–8 are new:

1. **Size** — story, or epic that must be split.
2. **Risk/security profile** — drives lenses, evidence mode **and the pass
   floor**. The floor became profile-derived when build step 1 shipped
   (0.11.0); before that the kit had a fixed 3-pass floor, and this line said
   so. Lenses remain different questions rather than more passes.
3. **Completeness** — too thin → one question round back to the human (several
   targeted questions in it, as the shipped intake skill does); nothing is
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
   dependency and wave dimensions). *(missing)*
3. Architecture tree + Bewertungs-Loop in AGENTS.md. *(missing)*
4. Orchestrator as product — the sparring-session practice codified as
   skill/agent: question routing, artifact handoff, prediction ledger, batched
   human decisions. *(missing; exists as practice)*
5. Time-based and proactive loops (stage 3/4). *(missing)*
6. Sample-Gate + sampled audit. *(missing)*
7. Fresh context per stage is convention, not enforced — long sessions
   measurably degrade. *(partial)*
8. Same-repo parallelism — N worktrees × 1 agent works today; the record/nonce
   rules the review-economics story shipped in 0.11.0 are the foundation for
   more. *(foundation shipped; the parallelism itself is not)*

## 7. Build path (each *leaf* is one story; numbered entries are ordering groups)

1. ~~Finish the review-economics story~~ — **shipped in 0.11.0**: floors by
   profile, severity by reachable consequence, and the two measurable records.
   Without calibrated review economics every factory is a token furnace, which
   is why this was step 1.
2. **Measure before automating further** — three ordered leaves, not one
   story:
   - **2a** loop-rule consolidation (the successor story to step 1).
   - **2b** the tracked P8 passive-metrics story
     (`docs/superpowers/stories/2026-08-04-passive-metrics-over-the-ledger-story.md`),
     which is **read-only over the ledger and git** and stays that way. This
     vision does not widen it.
   - **2c** a separate telemetry story for everything this vision adds that P8
     does not do: run analytics with cost and duration per step, a trace ID
     carried through every stage artifact, mechanical spec-delta capture, and
     live cost counters. That is new state and new instrumentation, so it
     cannot ride inside 2b. It also owns the review-loop usefulness metrics,
     threshold calibration and explainable assessment specified in §4;
     dashboard presentation consumes those results. P8 alone cannot supply
     all of these inputs. The generated HTML view has a separate owning-leaf
     question below (§11), including a possible initial static snapshot.
3. Orchestrator story (codify the role as skill/agent per decision 1) — the
   role, the artifact handoff, and the *interface* of the tick execution plan.
   The working dry-run reads the pool, the projection, waves, lanes and the
   tick, so it lands after 4d and 5a rather than here (§4).
4. **Story pool and classification** (decisions 2, 4, 6, 7 and 9). An epic, so
   §5's own split rule applies to it; the ordered stories, behind named
   interfaces:
   - **4a** pool storage, item identity, and the status state machine — every
     state, its authorizing operation, its precondition and its terminal or
     resumable outcome.
   - **4b** classification: the eight card dimensions, the verdicts, the split
     and dependency rules — including the proactive Intake-Loop, which is the
     factory's first stage-4 loop (decision 6), so stage 4 starts here rather
     than at step 6.
   - **4c** architecture: Phase 0 and tree v1 (§9), the machine-readable
     projection generated from AGENTS.md, **and the Bewertungs-Loop runtime**
     — its continuous pool-versus-tree evaluation, its meta-story batching per
     wave, and the re-classification an architecture merge triggers. The
     bootstrap alone would leave §1's Bewertungs-Loop unbuilt.
   - **4d** Freigabe and wave control: the rendered wave plan, the granularity
     knob and its standing rules, wave opening and closing (decision 7). No
     other step owned this, and the pipeline cannot run without it.
   - **4e** decision 9's mechanics: acceptance-criterion IDs, the read-only
     rule inside a lane, the AC-block comparison at Gate B and the pool
     round-trip — plus given/when/then normalization and the per-AC test
     report as a handoff artifact, which is the machine-checkable goal
     condition the fingerprint protects and which no other leaf owned.
     Ordered **before any autonomous lane execution** — it is the
     reward-hacking guard, and a build path that ships lanes without it looks
     complete while the guard is missing.
5. **Stage 3, plus the merge queue** (polling, drift audits, PR polling — and
   one station, 5b, that is not a clock loop at all). Also an epic; its
   stories are separate failure domains behind one shared contract:
   - **5a** the clock-loop contract itself: tick, run lock, environment
     preflight, usage-limit hold/resume, the report-only default, and the
     branch-claim and lane-budget rules the scheduler needs.
   - **5b** the merge-queue station (rebase + smoke on the candidate, §9). It
     is **not** a clock loop: it is a serial mechanical station triggered by
     queue entry, so it takes the run-lock and artifact halves of 5a's
     contract and none of the tick, usage-hold or report-only halves.
   - **5c** the E2E clock loop (failures auto-filed as pool stories, §9).
   - **5d** the drift audits: docs drift and reverse traceability,
     report-only, findings filed as pool items.
   - **5e** the PR poller: a report-only clock loop that notices a PR needing
     attention and wakes the shipped `process-pr-review` station inside a
     lane. It does not process the PR itself — that command fixes, commits and
     hardens, which is lane work and not something a report-only clock loop
     may do.
6. **Stage 4 and sampled audit** (decision 5) — the highest-risk step, so it
   splits like the others:
   - **6a** the stage-4 orchestrator wake: a story turning *freigegeben* wakes
     the orchestrator without waiting for the tick.
   - **6b** the Sample-Gate and the audit state: the drawing rule, the audit
     verdict's binding to the candidate it reviewed, and the rejection path
     back to the lane.
   - **6c** graduated automatic merge: mechanical risk thresholds beneath the
     semantic profile, starting with level-0 stories only.
   - **6d** the promotion path past level 0 — the profile threshold at which
     automation widens to standard and high stories, the evidence that moves
     it, and its downgrade triggers. Without this leaf every other story can
     finish while most work still waits for per-merge human approval, and the
     end state is never reached.
   Merge stays human until 6c ships and holds.

## 8. Non-goals

- No daemon or server-side runner (decision 1).
- No second architecture or roadmap document (decisions 2, §4).
- No removal of the human from mandatory stops, profile confirmations, scope
  changes, or architecture meta-stories — "dark" means sampled presence, not
  absence.
- No autonomy expansion ahead of the measured evidence (P8) that the review
  economics support it.
- No deployment stage. The factory ends at the merge; what follows (release
  tags, environments, direct deploy) is the project's own CI.

## 9. Parallelism and flow control (decisions 2026-08-30, Daniel)

- **Phase 0 exists once.** Initial brainstorming builds architecture tree v1
  plus goals/out-of-scope before production starts. It is the only
  everything-waits moment; after it, intake never freezes. It has two inputs:
  a green field derives tree v1 from the pool; an existing project reads it
  from the codebase (natural home: a `/workflow-init` extension). Tree v1 need
  only be good enough to judge with — meta-stories correct it in use
  (decision 3). A single incoming story is simply a mini-wave: the views
  collapse to one line and no *station* is bypassed — though a behaviourally
  trivial change can still take the shipped Gate-B triviality skip, and an
  undrawn PR does not reach Audit; §11 records the first as an open end-state
  question.
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
  architecture verdicts yield the schedule. Within a story the stages stay
  serial — the plan needs the spec, the build needs the plan, Verify needs the
  diff — but independent work *inside* one stage may fan out to subagents, as
  Gate B's two review branches already do. What does
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
  bandwidth, not compute. The first of those is a **global** brake, and it
  narrows the branch-only guarantee above: architecture churn parks *stories*
  per branch, but a mandatory stop in any lane halts *new lanes everywhere*
  until it clears. Running lanes drain either way.
- **Three test layers, three cost classes** (decided 2026-08-31). The lane
  battery (seconds, every cycle, exists) · a **smoke gate in the merge queue**
  (minutes, every merge, new) · the **full E2E suite as a clock loop** (hours,
  nightly or at wave close, stage 3). The merge queue is a station of its own:
  serial, per candidate rebase onto current main → smoke on the composed
  candidate → green lands, red returns to the lane as an artifact (like Gate-B
  findings) while the queue continues with the next branch; repeated failure
  escalates via the judge. The bounded claim: the queue never lands a
  candidate whose configured smoke command fails. That is not a claim about
  main's full-system health — only the E2E layer speaks to that, and it can
  still find a failure on already-merged main. Landing is automatic from
  build step 6 onward; until then the green outcome is a human merge
  (decision 5).
  This closes the parallelism blind spot (disjoint lanes each green, their
  composition broken) and owns the merge-coordinator mechanics (rebase,
  retry). An E2E failure becomes a pool story automatically, classified by
  the normal intake, carrying the trace ID of the suspect merge. Concrete
  tools stay project truth: AGENTS.md gains the command roles `smoke` and
  `e2e`. Cadence and flaky rules belong to step 5.
- **Role separation across running agents (decided 2026-08-31).** Spawned
  subagents separate automatically — one task, fresh context, no shared
  chat. Long-lived interactive sessions do not, so three rules hold:
  **star, not mesh** — lanes never talk to each other or sideways;
  everything crosses the orchestrator or is an artifact. **Role = task** —
  an input artifact and an output artifact define a role, never chat
  history; only the orchestrator lives long, and even it wakes fresh per
  tick with the pool as its memory. **Identity lives in artifacts, not
  session names** (names proved unstable across a restart on 2026-08-31):
  lock files, slot infixes, status fields with defined writers. Enforced
  by mechanics already decided: one worktree per lane, the run lock,
  defined status operations, the record/nonce rules. The human-facing
  sparring chat is the one persistent conversation; its boundary is
  decisions and questions, never production. [owner: step 3]
- **Shortcuts are shorter lanes, never side doors (decided 2026-08-31).**
  Everything enters through the pool (seconds) and leaves through Verify
  and the merge-queue smoke; what shrinks in between is decided by the
  card, never by the builder (decision 8: an author never rates itself
  trivial). Four cases: a **trivial lane** collapses Spec- and Plan-Loop —
  the story text is the spec, no plan — with the light review the profile
  rules already grant; a **hotfix lane** gets speed from priority, not
  from skipped review — a standing "hotfix" wave bypasses wave steering
  and jumps the queue, Verify stays full; an **experiment** runs in a
  throwaway worktree and never merges — its artifact is a report, not a
  diff, so no gates apply where nothing lands, and learnings become pool
  stories; and **hand work by the human** is always allowed, but what
  wants onto main passes the same gates — four eyes has no owner
  exception. [owner: step 4 (card-driven depth), step 5 (hotfix wave)]
- **Hooks are subscribers to station-boundary events (decided
  2026-08-31).** The factory emits an event at every station boundary
  (story arrived, classified, freigegeben, lane opened, merge landed,
  escalation, audit drawn) — the trace infrastructure (2c) produces these
  anyway. Project-owned hooks subscribe in two classes: **passive** hooks
  notify, render or log (push, status line, dashboard and analytics are
  the first four subscribers) and may change nothing; **active** hooks may
  do exactly one thing — put a story into the pool (per the fix-permission
  rule: never a direct fix), so everything mutating passes classification
  and Freigabe. The E2E loop is the first active hook. [owner: 2c
  (events), step 5 (subscriptions)]

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
  stage artifact, and mechanical spec-delta capture. [step 2c — new state and
  instrumentation, so not the read-only P8 story]
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
daemon/Docker/GitHub as hard requirements (§8, "No daemon or server-side
runner", stands); stop-the-world
sequential milestones (branch-scoped locks and the lanes budget replace it).

**Their documented scars, kept as constraints here:** manual state mutation
under an automated resolver breaks it — every hand-edit of pool status must
be a defined operation; planning artifacts need a defined home so they never
contaminate implementation branches; run artifacts need a retention stance
from day one (their P0 gap: unbounded disk growth); absent real-time cost
visibility is what makes a token furnace invisible (their P0 gap; ours is
2c's live counters — not the read-only P8 story, which is forbidden to
instrument anything).

**Second sweep (2026-08-31), against their full docs and the inspiration
video.** The sweep produced two working notes that live outside the repo and
are deliberately not cited by path, because they do not survive a clone. The
durable record is the list below.
Adopted, with owning step:
- Mechanical write protection for pool status, the `lanes` knob and the
  architecture section of AGENTS.md (their `protected_paths` /
  `denied_commands`). This would be the kit's first *blocking* hook, and
  invariant 1 ("the hook always exits 0") forbids one. Arguing that a
  local-state check carries none of the external dependency invariant 1 names
  is an argument *for amending* it, not an exemption from it — so this item's
  prerequisite is an **architecture meta-story amending invariant 1**
  (decision 3). Invariant 1 is not the only one it meets: invariant 2 ("on
  uncertainty, fire") would turn every parse or environment failure into a
  denied write, and invariant 4 keeps the hook POSIX `sh` with `jq` optional.
  The meta-story must decide fail-open or fail-closed for each local failure
  mode and say which of the three invariants it amends and which it preserves.
  Until it lands there is no mechanical write protection at all. What exists
  is **authorized-write tooling** (a repo-owned command an agent may choose to
  use) and **merge-time detection** (a required CI check). Neither prevents an
  unauthorized local write, and the factory can schedule or build from one for
  as long as it takes a commit to reach CI. That bypass window is the reason
  the blocking mechanism is wanted, and the interim path does not close it.
  [prerequisite meta-story, then step 4/5]
- A run lock per orchestrator tick with stale-lock cleanup by the judge, so
  a double-firing clock never runs two orchestrators. [step 5]
- Usage-limit hold/resume: a hit rate limit pauses the run with a countdown
  and resumes — never counted as a failure (their v0.18 lesson). [step 5]
- Model strength per role as a project knob (cheap builder, strong
  reviewer), with one asymmetry rule: the reviewer is never weaker than the
  builder — cross-model stays. [step 1/3]
- Minimum review cost/duration as an INCOMPLETE signal: a pass under the
  floor does not count toward the pass floor. No new gate — the kit's
  existing INCOMPLETE semantics, fed by 2c's measurements. [step 2c]
- Audit rejection flows back automatically: the human's "changes requested"
  returns to the lane as an artifact (like a red smoke), and a PR once
  rejected by the human is always re-audited by the human, never re-drawn.
  [step 6]
- Environment preflight before every tick (`doctor`: required env, host
  services) — a clock session on a broken environment only burns tokens.
  [step 5]
- Phase 0 on an existing codebase also *reports* agent-hostile patterns
  (codegen magic, implicit behaviour) — report only, never fixes. [Phase 0 /
  `workflow-init`]
- Wave close renders an as-built view (what was actually built, grounded in
  code) — a generated view like the roadmap, never maintained; the standing
  defence against docs drift. [step 4/5]
- From the video: a hard round cap per Bau-Loop and a token budget per
  story as preventive limits — reaching one is a mandatory stop, never a
  silent kill; the caps apply to build loops, not to review loops, which
  keep their floor and tells. [step 3/5] Acceptance criteria with IDs in
  given/when/then form and a per-AC test report as a handoff artifact (the
  machine-checkable goal condition; also what decision 9's fingerprint
  protects). [step 1/4] Reverse traceability (code with no spec behind it)
  as drift-audit content, report only. [step 5] Every clock loop starts
  report-only — meaning it changes no product code and no pool *status*;
  filing a new pool item is the one write it does make, because a report
  nobody can act on is not a report (that is how the E2E loop files its
  failure, §9). "Fix permission" is a maturity knob per loop, and it means
  exactly one thing: the loop may **create and advance a normally classified
  pool story**. It never means editing code directly. Every fix a loop wants
  travels through classification, Freigabe and a wave like any other story —
  decision 3's one process for everything covers the loops too. [step 5]
  Deployment is out of scope (§8).

Redirected: their merge coordinator is our merge-queue station (§9); their
`report` (executive summary over the analytics window) belongs to the
dashboard topic (§11); their harness-as-router (CLAUDE.md compressed to a
20-line signpost) becomes a kit story once 2c measures harness tokens per
session — with fresh context per station, every story pays the harness
size times its stations.

Not adopted: the rollup branch (issue PRs into a wave branch, one rollup PR
to main). It is a part of their stop-the-world milestone model, already
rejected. What replaces it is weaker, and saying so is the point: incremental
smoke on each composed candidate *before* it lands, plus an E2E run over a
wave that is already on main. There is no atomic whole-wave candidate and no
pre-main whole-wave checkpoint, so some integration failures surface only
after a partial wave has shipped. The as-built view gives the wave-level
reading, and
a wave branch would break the kit's merge-base-with-main semantics and make
hotfixes a two-way merge — the opposite of flexible shortcuts (§11). A
project that needs "main = whole waves only" does not get it here: the queue
lands individual candidates throughout a wave, so main is incremental by
construction. Release tags in its own CI (§8) give that project release
*boundaries*, which is a different thing and the most this design offers. Also not adopted, noted as a lesson only: hard byte
caps on verify output and PR diffs in prompts (unbounded diffs blow context
and cost). Irrelevant here: per-module monorepo batteries, LangGraph as a
framework, knowledge-graph disambiguation.

## 11. Open questions

Most carry the leaf or step that will answer them. Some do not: the one
parked topic below — hidden verification scenarios — and
the stations near the end of this section that §1 draws but no
leaf yet owns. Those are marked as such rather than counted as decomposed.

- Sample percentage and drawing rule for the Sample-Gate (step 6).
- Storage form of the pool (files in-repo vs. external board) — step 4.
- Hidden verification scenarios (checks written before build, unseen by the
  builder) as a Gate-B supplement — candidate small story, unscheduled.
- How the clock's platform mechanics (loop/schedule) are configured per
  project — step 5.
- Process dashboard / console status — decided 2026-08-31 and recorded as
  the live-status view in §4 (snapshot per tick, rendered by code into
  status.html / status line / optional menu bar, decision queue first,
  staleness visible); still open: the snapshot schema and the owning leaf,
  fed by 2c's traces and analytics. The 2026-09-17 source/presentation decision
  in §4 adds generated task and progress views with Markdown sources; choose
  the initial static-view scope and source mapping in that leaf, without
  requiring live telemetry for a labelled snapshot. [2c / dashboard]
- Review-loop usefulness — the requirement and dimensions are recorded in
  §4; metric definitions, evidence availability, calibration sample, numeric
  thresholds by evidenced product impact, any composite weights and
  recommendation mapping remain to be designed. The direction is settled:
  indirect impact requires earlier reassessment of further effort, not an
  automatic severity demotion. Distinguish usefulness assessment from §10's proposed minimum
  review cost/duration signal: spending longer or more is not proof of useful
  review. Neither proposal changes current pass-validity rules. [2c]
- Hooks and shortcuts — decided 2026-08-31 and recorded in §9 (shortcuts
  are shorter lanes, never side doors; hooks are subscribers to
  station-boundary events, passive or story-creating). Still open: the
  event schema, with 2c. [2c / step 5]
- Test layers are decided (§9); still open: whether a smoke failure that
  returns to a lane is surfaced to the human (a dashboard question), and the
  E2E cadence / flaky-handling rules — step 5.

**Recorded by Gate A pass 1 (2026-08-31).** Gaps this document does not close,
each with the step that owns it. They are named rather than specified: a
decomposition document that invented them would be taking design decisions
nobody took, and a gap named here cannot be silently invented later by whoever
writes the story.

- *Pool and state* — cycles, self-dependencies and dangling targets; what a
  dependency becomes when its target is split or rejected; the atomic
  transition when the last dependency clears; which terminal statuses count as
  resolved for wave closure and where carried-over items go; Phase 0's
  empty-pool outcome; and whether an external board can satisfy the committed,
  history-bearing, compare-and-set assumptions the `lanes` knob makes. [4a]
- *Intake concurrency* — stable item IDs and idempotent classification writes,
  so a re-delivered or overlapping debounce batch cannot produce a second card
  or a second meta-story. [4b]
- *The classification transaction* — the complete set of writes one
  classification may make (card, status, meta-story, dependency link) and its
  atomicity. Decision 6's "attaches cards only" and decision 3's meta-story
  creation are the same act, so the seam guard needs the full list. [4b]
- *Naming* — the verdict `freigeben` and the status `freigegeben` are one
  letter apart, and the first must never produce the second. The classification
  outcome needs a non-authorizing name. [4b]
- *Architecture staleness* — an architecture merge makes verdicts stale, but
  nothing yet revokes an already-*freigegeben* card or stops a running lane
  whose verdict aged out mid-build. Binding cards and lanes to a tree version
  is the candidate. [4c]
- *Projection freshness* — what the generated projection does on a stale
  digest, a parse failure, or a detected cycle. [4c]
- *Approval binding* — the wave plan the human approves is recomputed every
  tick from mutable inputs, so the clock can execute a materially different
  plan than the one approved. Binding an approval to an input digest and
  re-rendering when it moves is the candidate. [4d]
- *The decision-queue throttle's `N`* — a committed knob with a default, a
  range and an exact comparison, distinct from `lanes`. [5a]
- *Branch-claim semantics* — "disjoint branches" is undefined for
  ancestor/descendant overlap, shared roots, multi-branch stories, and a lane
  whose touched set grows during the build. [5a]
- *Orchestrator exclusion* — stale-lock cleanup is not exclusion: a live owner
  paused in a usage-limit hold is exactly what a staleness heuristic
  misreads. A lease with a heartbeat and a fencing token that every mutating
  write checks is the candidate. [5a]
- *Merge-queue terminal paths* — rebase conflict, unclean worktree, a branch
  deleted while queued, a retry invalidated by newer main: each needs its
  artifact, its return transition and a retry cap. [5b]
- *E2E attribution* — a nightly or wave-close run covers many merges, so "the
  trace ID of the suspect merge" is not derivable from it. Carrying the tested
  merge range and marking attribution unknown unless deterministically
  isolated is the candidate. [5c]
- *Telemetry gaps* — analytics writes are non-fatal, yet review cost and
  duration decide whether a pass counts. A missing or unattributable gate
  measurement must read as INCOMPLETE, never as a cheap pass. [2c]
- *Live cost visibility* — post-run analytics detect overspend after it
  happened, which is not the control §10 keeps from their P0 gap. Live
  counters, alerts and stop thresholds are a different mechanism from P8's
  passive record. [2c / dashboard]
- *Retention* — run artifacts need a retention, compaction and deletion stance
  from the first story that writes them; their P0 gap was exactly this. [2c]
- *Planning-artifact home* — where plans and specs live so they never
  contaminate an implementation branch, and which of them are tracked. [step 3]
- *Model strength order* — "the reviewer is never weaker than the builder"
  needs a project-owned order across families and a fail-closed path for an
  unknown or newly released model. [step 1/3]
- *The triviality gap in decision 5* — "no merge skips both gates" does not
  hold today: the shipped Gate-B triviality skip plus an undrawn Sample-Gate
  leaves a change with neither. Whether the end state removes that skip, or
  makes every Gate-B-skipped change a mandatory draw, is open. [step 6]
- *Audit binding* — a draw and an audit verdict are not bound to the bytes
  reviewed, so a later fix, rebase or Gate-B round can inherit an audit of
  something else. Which mutations force resampling and re-audit is open. [step 6]
- *Autonomy downgrade* — every knob lowers human presence on good evidence and
  nothing raises it back on bad (audit rejection, repeated smoke failure,
  deteriorating metrics). Triggers, authority, hysteresis and the immediate
  safe state belong to 6d, which owns the promotion path in both directions;
  until 6d defines them "a dial, never a ratchet" is only half true. [6d]
- *Meta-story batching versus the split rule* — one architecture meta-story per
  wave can combine independent subsystems and mixed profiles, which §5 says
  must split. Batching by compatible branch and profile group is the candidate,
  and the O(waves) bound then counts batches rather than waves. [4c / step 6]
- *The hardening ledger covers only one of three finding sources* — the
  fingerprinted ledger and `harden-finding` are one of the kit's three
  defining mechanisms (AGENTS.md), and `process-pr-review` item 5 already
  routes accepted actionable **bot** findings into it. Two sources have no
  station: accepted **Gate A and Gate B** findings, and accepted findings from
  a **sampled human audit** — the latter being the factory's highest-value
  signal, since an audit finding is something the gates that ran did not
  catch, or that no gate saw at all where Gate B was legitimately skipped and
  Gate A reviewed only the spec and the plan. Repairing those instances without recording fingerprints loses the
  escalation that turns a recurring finding into a rule. Gate findings belong
  to the loop-rule owner rather than to the classifier — 4b is pre-production
  and never sees a review loop. [gate findings 2a, audit findings 6b]
- *Gate B and the rebase* — the queue rebases onto newer main after Gate B ran
  and then runs only smoke, so what lands is not byte-for-byte what the
  adversarial gate reviewed. Whether Gate B re-runs on the composed candidate,
  or the claim is narrowed, is open — and until it is settled, "the adversarial
  gate checks every merge" (decision 5) is a claim about the pre-rebase diff.
  [5b]
- *PR readiness before the queue* — nothing sequences PR opening, the routed
  review bots (`docs/pr-review-bots.md`) and required CI against Sample-Gate
  entry and queue entry. [5e]

**Stations drawn in §1 that no leaf yet owns.** Each needs a leaf assigned
before step 4 or step 5 planning begins; naming them here is what stops a
roadmap from reading complete while a drawn station is unbuilt.

- *The vet preflight* — §10 assigns it to step 4 as a whole, but 4a, 4b and 4c
  divide storage, classification and architecture between them and none owns a
  runner that fires before **every** model-operated node, including nodes that
  do not exist yet. Candidate: its own leaf under the shared contract, with
  its pool, split-threshold and projection checks mapped to 4a, 4b and 4c.
- *The judge / watchdog* — §10 assigns it to step 5 as a whole, and it appears
  in no leaf. It supervises the model loops **and** the merge queue, which is
  not a clock loop, so it does not fall out of 5a either. Candidate: its own
  leaf covering every supervised node plus the push notifications.
- *The working orchestrator dry-run* — step 3 owns the plan interface and
  says the runnable dry-run lands after 4d and 5a, but no later leaf owns it
  and §10 still points at step 3. Candidate: a leaf after 5a, with §10
  repointed to it.
- *The as-built view at wave close* — §10 assigns it to steps 4 and 5, it is
  in no leaf, and it is not drawn in §1. Candidate: 5d generates it and 4d
  requires it in the wave-close transition.
- *Punchlist generation* — §10 promises it as the artifact a sampled audit
  reads, assigned to step 6 as a whole; 6b owns the draw and the audit state,
  6c owns the merge thresholds, and neither owns producing the punchlist.
  Candidate: 6b, since it is what the audit consumes.
- *Model strength per role* — §10 assigns it to step 1/3, but the tracked
  review-economics story contains no model-strength knob and step 3's
  definition omits it, so both cited owners can finish without it. Candidate:
  2a with the other loop rules, with §10 repointed.

**Unresolved at close (Gate A pass 5, 2026-08-31).** The gate was closed on a
scope disposition rather than a clean pass: leaf-level mechanics are outside
this decomposition document, and each item below is owned by the named leaf
story and its own Gate A. Pass 5 returned 15 findings and **zero Blockers**
(the series ran 52, 34, 32, 26, 15). These went unfixed by decision, not by
oversight, and a later reader should treat them as known:

- *Labeled examples have no owner* — §1 turns a human override into a labeled
  example, and decision 7 does the same for a Freigabe that repeatedly needs
  deep thought, but no leaf captures, stores, routes or consumes them.
  Candidate: 2a with the loop rules. [unowned]
- *The orchestrator product is wider than step 3* — §6 gap 4 names question
  routing, artifact handoff, a prediction ledger and batched human decisions;
  step 3 owns the role, the handoff and the plan interface only. Three
  capabilities have no leaf. [3, needs widening]
- *"This closes the parallelism blind spot"* (§9) overstates what smoke
  proves: it shows the configured smoke command passed on the composed
  candidate, not that independently green lanes compose correctly outside
  smoke coverage. The E2E layer is what reaches the rest, later. [5b / 5c]
- *"Promotion evidence" names one owner for several knobs* — 6d owns the
  automatic-merge threshold, but the Freigabe and wave-opening knobs belong to
  4d and the sample rate to 6b, so the entry's single [6d] owner is too
  narrow. [4d, 6b, 6d]
- *Coarse owners remain on four top-level questions* — the Sample-Gate rule,
  pool storage, clock platform configuration and E2E cadence still cite step
  6, step 4 and step 5 rather than leaves, although this document makes the
  leaf the unit of ownership. [6b, 4a, 5a, 5c]
These are the whole remainder. Six further pass-5 findings named wordings that
pass 4 had reported as fixed but had not written to disk — the §7 heading, step
5's title, decision 8's "every mandatory touchpoint", the autonomy-downgrade
owner, the §11 opening count, the dashboard's P8 attribution and the mini-wave
"no stage is skipped". Those were applied at close rather than recorded, and
the miss is noted here because a reader comparing the pass-4 record against the
document would otherwise find them inconsistent.
- *AC canonicalization* — decision 9's fingerprint needs a canonical
  serialization of the AC block, a baseline captured at lane opening, a
  durable record of the authorizing pool round-trip, and the exact evidence
  Gate B compares. Without them the check cannot separate an authorized
  correction from reward hacking. [4e]
- *The stopped lane* — when a lane stops for an AC change, whether its partial
  work, plan, evidence and review counters are discarded, quarantined or
  resumed after reclassification is undefined, and each choice changes the
  Gate-B baseline. [4e]
- *Given/when/then and the per-AC test report* — §10 assigns these to steps 1
  and 4, but step 1's tracked story does not contain them. 4e now owns them
  explicitly (see §7), so what remains is repointing §10 away from step 1. [4e]
- *Promotion evidence* — "measured P8 evidence" is the condition on every
  autonomy knob, but P8 measures ledger recurrence and review-severity mixes,
  not Freigabe accuracy, audit escapes or merge safety. Each knob needs its own
  outcome metric, adverse-event measure, window and threshold. [6d]
- *Wave-close ordering* — the order of the wave-close E2E run, the as-built
  view, wave closure and any standing auto-open rule is undefined, so a wave can
  open before the previous one's integration result exists, and a late E2E
  failure has no defined wave. [4d]
