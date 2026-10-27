# Acceptance-criterion evidence map

Reviewed range: `2a5a4d06e35143f43c04db538a27d145cddd5cf5..d0f113477b49091312a7f4f8250ed4a795479af2`.
The supplied full-battery success is accepted as run evidence, not evidence of semantic coverage. No full battery rerun was needed for this review.

| Criterion | Test asserting it, or none | Inspection scope / limitation |
|---|---|---|
| AC-1 | Hook suite section 50, `codex-gate.test.sh:3847` onward, partial | Asserts lean floor 1, cap 3 and cap message. Actual agent closure/defer behavior has no execution test; read gate rules lines 55–66. |
| AC-2 | none | Read rules lines 24–25, 32, 56: previous findings, common fix range, full fallback and new-Major collection are prompt instructions. |
| AC-3 | Hook suite section 50, partial | Mode numbers, fallback and remembered mode are tested. No test asserts restoration of all classic prompt behavior; findings identify gaps. Repo mode is strict. |
| AC-4 | Hook suite section 50, partial | Asserts A floor/cap and threshold reminder. No test executes threshold selection or header creation; inspected rules lines 3–5 and 55–57. |
| AC-5 | none | Read CLAUDE.md one-source-of-green/stop paragraphs and template, plus gate prompt line 39 and timeout exception line 62. No agent-execution assertion. |
| AC-6 | none | UI real-app-run duty is in CLAUDE.md Plan paragraph and corresponding inline template, exempting classic. |
| AC-7 | none | Read harden-finding steps 4 and 7. Prose reason exists; classic exemption is missing. |
| AC-8 | Hook suite section 50 and existing hook exit/fallback tests, partial | New lean one-pass floor assertion distinguishes 0.45 behavior. Branch-protection recommendation is a reading check; no settings are applied. The enforcement overclaim is a finding. |
| AC-9 | none | Closing act specifies move before closing commit and resume includes archive; ledger row fields appear in skill and scaffold. No test executes archiving or learning creation. |
| AC-10 | none | Compared spec O1–O19 to old/new gate rules and CLAUDE.md. O14's every-answer further-review condition was dropped. |
| AC-11 | `scripts/ledger-metrics.test.sh:509` and `scripts/loop-usefulness.test.sh:579`, plus historical fixtures | New standard-risk floor-1 records are asserted alongside historical floor-3 records. Ledger historical floor-1 fixtures remain at lines 217 onward. Record grammar is unchanged; reader implementation change is labels only. |
| AC-12 | `scripts/check-invariants.sh` checks 4e/4i/4j and its suite, partial | Byte identity and budgets are mechanically checked. Prompt semantics and the 12 standards remain reading checks; battery success does not establish them. |
| AC-13 | `scripts/check-version-bump.sh` and suite, full quality battery supplied by caller, partial | Bump checker checks a changed version, not exact 0.46.0; manifest, CHANGELOG and README/docs inspected directly for release content. |

No inspected new test was inherently unable to fail. The strict cap test checks firing at pass 5, but does not independently assert absence at earlier passes; this is limited coverage, not a vacuous test.
