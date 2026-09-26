# Gate A (spec) — dark-factory vision — pass 1 dispositions
52 findings: 2 BLOCKER, 39 MAJOR, 10 MINOR, 1 NIT. Unprofiled run (the artifact cites no story).

## Fixed in this pass (commit "docs(vision): Gate A pass 1")
- F4  MAJOR  pipeline ended at "Merge/Deploy" vs non-goal 5 → terminus is Merge; deploy named as outside.
- F5  MAJOR  §9 "no human involved" vs decision 5 → sequenced: automatic landing from step 6, human merge until then.
- F24 MINOR  Sample-Gate→Audit drawn unconditional → drawn / not-drawn branches added.
- F28 MAJOR  §5 dim 2 claimed the profile drives the pass floor → shipped CLAUDE.md has a fixed 3-pass floor; corrected to lenses+evidence today, floor after step 1.
- F29 MINOR  "one question back" misstated the intake skill → "one question round".
- F30 MINOR  "5–7 are new" vs 8 listed dimensions → "5–8".
- F31 MINOR  gap 2 omitted the Wave dimension → added.
- F36 MAJOR  stage labels incoherent (step 5 "Stage 3" but carried event loops) → stage 4 starts at step 4 with the Intake-Loop per decision 6; step 5 is clock loops only; step 6 owns the freigegeben-wake.
- F37 MINOR  E2E clock loop absent from the canonical pipeline → added as an asynchronous loop with its edge back to the pool.
- F38 MAJOR  "main is never red" — gate overclaim, the class AGENTS.md forbids by name → replaced with the bounded claim (no candidate lands whose smoke fails; E2E can still find main-level failures).
- F46 MAJOR  cited gap-sweep files sit under a git-ignored docs/research/ and are in no commit → citation now says they are local notes and the durable record is the list itself.
- F47 MINOR  "non-goal 4" does not resolve (§8 bullets are unnumbered) → cited by title.
- F48 MINOR  "non-goal 1" ditto → cited by title.
- F49 MAJOR  "a human override" unconstrained vs CLAUDE.md §5 ("supplies no permission") → constrained to human-owned knobs.
- F52 NIT    "Every node is a loop with its own fresh context" false for stores, humans and the queue → narrowed to model-operated nodes.

## Collected, not iterated (Minor)
- F23 MINOR  undefined `N` in the decision-queue throttle. Real, but naming a knob and its range is step-4/5 mechanism, not vision text.
- F50 MINOR  Phase 0 has no empty-pool outcome. Belongs to the Phase 0 / workflow-init story.
- F51 MINOR  "prior wave is fully merged" undefined for rejected/split/deferred items. Belongs to the wave-control story.

## Routed to the human (loop paused, findings open)
Decision-touching: F1, F2, F3, F9, F10, F11, F19, F21, F22, F27.
Unowned mechanism, proposed for §11/§7 rather than specification here:
F6, F7, F8, F12, F13, F14, F15, F16, F17, F18, F20, F25, F26, F32, F33, F34, F35, F39, F40, F41, F42, F43, F44, F45.
