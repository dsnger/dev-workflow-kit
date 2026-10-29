# Spec review coverage — dc478c4

Hypotheses: manifest comparison may accept non-release changes; instruction paths may bypass exclusions; lane inheritance or consumers may omit required checks; assertions may pass for unrelated reasons.

| AC | Test or inspection |
|---|---|
| AC-1 | Hook suite 14c, lines 690 and 696; local-ci case 25, line 424; gate-rule note inspected. |
| AC-2 | Hook 14c dependency/code/nested cases, lines 691–695; local-ci 26–28, lines 425–431. Distinct cross-file version-pair case absent (finding 3). |
| AC-3 | Existing hook docs-only tests and 14c lines 693–701, plus unchanged is_docs_only/first branch inspected. |
| AC-4 | local-ci cases 23–35, lines 422–455; no-light-row case is confounded (finding 2). |
| AC-5 | local-ci cases 36–40, lines 457–483; actual moving-ref case absent (finding 3). |
| AC-6 | local-ci posted/inherited helpers assert quality; ci.yml unchanged in range, no paths-ignore addition. |
| AC-7 | none; inspected docs/reference.md:317 for requested sentence. |
| AC-8 | Hook 14c and local-ci 23–26,39 cover the five named scenarios. Additional design/plan cases are incomplete (finding 3). |
| AC-9 | none in this diff; explicitly deferred until final head, as instructed. |
| AC-10 | check-invariants 4n and version-bump suite; inspected manifest/template/record all 0.50.0, CHANGELOG/README/docs changes. |

Independent focused probes extracted the actual release_only function into a temporary repository: staged top-level version change accepted; dependency change and nested-only change rejected. Instruction-path guards inspected in both identical classifier copies. No defect found in the jq comparison for these cases.

Independent byte comparisons: 2.1a equals .claude/review-gates.md; 2.22 equals scripts/local-ci.sh. Gate rules are 9,998 bytes. Version records agree. Full battery not repeated; supplied evidence is all 35 stages green on this head. No source files changed by this review.
