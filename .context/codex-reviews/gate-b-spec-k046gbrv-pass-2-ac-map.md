# Pass 2 spec review evidence

Range: `2a5a4d06e35143f43c04db538a27d145cddd5cf5..7f887d370e7b4bf5ff6dea7d74436794bafd539a`. HEAD independently resolved to the requested head. Implementation files were read rather than relying on the implementer's summary.

## Hypotheses checked

1. Compressed rules might lose classic's old conditions. Compared the old rules and design O1-O19 with both new rule surfaces. The pass-1 non-close cap defect is fixed.
2. Verify passes or cap routing might lose earlier blocking findings. The rules retain carry-forward, late-finding classification, human escalation and full-range fallback; remaining documentation discrepancies are finding 1.
3. Initialization might enable lean over stale rules. The command requires both rule surfaces current, preserves an existing setting, reports a stale-surface mismatch and offers the specified remedies.
4. Changed modes and archived files might invalidate documentation or cycle readers. Readers retain commit-body records and parse the new floor; documentation and collision handling produce findings 1 and 2.

## AC to asserting test

| AC | Test, or none | Inspection result / limits |
|---|---|---|
| AC-1 | None for agent closure; hook suite section 50 checks B floor 1/cap 3 reminders | Gate rules implement lean closure and cap disposition; the hook does not decide findings. |
| AC-2 | None | Gate rules specify previous-head range, earlier blocking findings, verification and late ordinary-Major collection. |
| AC-3 | Hook suite section 50, partial | Mode defaults, fallback, strict floor/cap reminders and remembered modes are tested; classic prompt restoration and initializer migration are reading checks. |
| AC-4 | Hook suite section 50 threshold-note and A floor/cap cases, partial | Rules implement threshold, two passes, profile header and plan high-risk threshold; no agent-behavior harness. |
| AC-5 | None | Both CLAUDE surfaces contain five rounds, failure states and timeout exception; gate prompt excludes battery-visible failures while retaining coverage review. |
| AC-6 | None | Both CLAUDE Plan paragraphs require a real app run and evidence per UI AC outside classic. |
| AC-7 | None | harden-finding step 4 requires the prose reason outside classic, with lint/test preference retained. |
| AC-8 | Hook suite section 50 at codex-gate.test.sh:3832-3929, section 48 docs-only wording, existing advisory-exit cases | Lean numeric assertions would fail on 0.45; branch-protection recommendation is a reading check. |
| AC-9 | None | Rules name archive paths, resume lookup and learning rows; explicit collision stop-and-compare is missing (finding 2). |
| AC-10 | None | Design section 6 accounts for O1-O19; compared with previous rules. Relocated Context7 and Ponytail conditions survive in CLAUDE and its template. |
| AC-11 | ledger-metrics.test.sh:509-528; loop-usefulness.test.sh:579-594; historical reader fixtures | New floor-1 and historical records are asserted. Reader data source remains commit records rather than current pass-file locations. |
| AC-12 | check-invariants.sh checks 4e, 4i, 4j; prompt checks are partial | Invariant checks passed here. Prompt semantics require reading; remaining discrepancies are in the findings file. |
| AC-13 | Version-bump checker and supplied battery evidence, partial | Manifest reads 0.46.0; CHANGELOG, README and docs change in this range. Full battery evidence supplied for d0f1134 and both hook suites for head; not rerun in this review. |

No reviewed assertion was found incapable of failure. The strict-cap test checks presence of a cap warning at pass 5 but does not alone exclude an earlier cap; this is narrower coverage than its label suggests, not an implementation failure or an unfailable test.

## Independent checks run

- `sh scripts/ledger-metrics.test.sh`: exit 0, 46 passed.
- `sh scripts/loop-usefulness.test.sh`: exit 0, 17 passed.
- `sh scripts/check-invariants.sh`: exit 0.

## Earlier finding disposition

Pass-1 line 1: **fixed** at `.claude/review-gates.md:60` and `plugins/dev-workflow/commands/workflow-init.md:675`. Each non-close classic cap answer names N >= 1 more passes and resumes review on the remaining artifact. Pass-1's documentation class has surviving siblings recorded as finding 1 of this pass.
