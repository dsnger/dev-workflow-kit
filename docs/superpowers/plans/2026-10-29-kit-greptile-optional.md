# Kit 0.48 Greptile optional — Plan

**Spec:** `docs/superpowers/specs/2026-10-29-kit-greptile-optional-design.md`. **Gate A:** skipped (risk standard).

1. Edit `process-pr-review.md` Steps 2–4 (spec §4.1) → verify: AC-1..3 read in the text; check 4a–4c green.
2. Edit `workflow-init.md` 2.5 (spec §4.2) → verify: AC-4; invariant 9 (asks, records) holds.
3. This repo's `docs/pr-review-bots.md`, setup, reference, getting-started (§4.3–4.4) → verify: AC-5, AC-6 by
   `grep -rni greptile` over `plugins/ docs/setup.md docs/reference.md docs/getting-started.md README.md`.
4. Version 0.48.0, CHANGELOG → verify: `sh scripts/check-version-bump.sh origin/main` after the WIP commit.
5. Quality command → Gate B (strict, floor 1, cap 5) → PR → `/dev-workflow:process-pr-review` → squash-merge.

**Long runs:** the quality command, about 30–35 minutes, once per Gate B pass (est. 1–2 runs); limit 60 minutes per
run; it is under the 2-hour unit limit. Over 15 minutes, so the orchestrator gives a go before each run.
**Handover boundary:** the merged story; handover `.context/handover-kit-048-greptile.md`.
**Sources and impact boundary:** as spec §6. **Actions outside the repository:** none for the kit; turning
Greptile's own settings off or to the label path for this repository is Daniel's (noted in the PR body).
