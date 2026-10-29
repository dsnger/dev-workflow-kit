# Kit 0.49 learnings — Plan

**Spec:** `docs/superpowers/specs/2026-10-29-kit-049-learnings-design.md`. **Gate A:** skipped (plan at risk standard;
the spec's Gate A closed as cycle k049lrn1).

1. Hook + hooks.json + suite (spec §2): `version_line`, matcher `startup|resume|clear|compact` → verify: new hook
   cases green under `sh` and `dash`; lint row green. Pass-2 finding 1 of k049lrn1 is resolved in the wording.
2. `.claude/dev-workflow-version`, 2.23 template, check 4n + cases (§2) → verify: `sh scripts/check-invariants.test.sh`.
3. `scripts/local-ci.sh` generalized + suite cases; 2.22 template; check 4m + cases (§4) → verify:
   `sh scripts/local-ci.test.sh`, check-invariants suite.
4. Rule text: `CLAUDE.md` + 2.1 template "Waiting on external work"; `process-pr-review` Steps 1–4, Done, report
   example; no-bot line after the Wait-for step (§3, §7; k049lrn1 pass-2 findings 2 and 3 decided here) → verify:
   AC-3, AC-8 read in the text.
5. 2.1 Rule 2 pointer form (§6); 2.5 Greptile (§5); this repo's `docs/pr-review-bots.md` (§7) → verify: AC-6 by
   `grep -rni 'every push' plugins/ docs/setup.md docs/reference.md docs/getting-started.md README.md`; AC-7 text.
6. ~~Release-only (§8a)~~ — moved to 0.50 with item 8 (story AC-11 withdrawn).
7. Docs (reference, setup, getting-started, README, ARCHITECTURE, TECH-STACK, AGENTS boundaries/checks), CHANGELOG,
   version 0.49.0, `todos.md` rows closed (AC-9 + the three k049lrn1 rows) → verify: doc-link check.
8. Quality command → Gate B (strict, floor 1, cap 5) → PR → `/dev-workflow:process-pr-review` → squash-merge.

**Long runs:** the quality command (battery), about 35 minutes, once per Gate B pass plus once on the final head
through `scripts/local-ci.sh` (est. 2–3 runs); limit 60 minutes per run; the script removes its worktree on any exit.
Each run needs the orchestrator's go first (machine load). Under the 2-hour unit limit only at 3 runs; a fourth run
moves past a boundary at the close of the Gate B cycle.
**Handover boundary:** the merged story; handover `.context/handover-kit-049-learnings.md`.
**Sources and impact boundary:** as spec §10; GitHub REST via Context7 `/websites/github_en_rest`, API 2026-03-10.
**Actions outside the repository:** `gh workflow disable ci.yml` is already the state (brief); posting the
`quality` status with `scripts/local-ci.sh` per head (authorized by the brief). None needs the human.
