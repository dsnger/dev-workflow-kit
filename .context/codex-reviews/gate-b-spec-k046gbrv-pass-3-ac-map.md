# Pass 3 spec review evidence

Range: `2a5a4d06e35143f43c04db538a27d145cddd5cf5..5f340f19085bfd55149b78f96257a123605e07d4`. HEAD independently resolved to the requested head. Implementation and tests inspected directly; supplied battery results were not treated as semantic coverage.

## Hypotheses checked

1. A mid-cycle mode change could weaken reminders. The hook remembers each gate's initial mode and takes the higher floor/lower cap, with legacy counters treated as classic; section 50 asserts these cases.
2. Skipped Gate A could leave stale approval instructions. Approval, checkpoint and amendment instructions are updated; the remaining universal Gate-A claim is the findings file's single issue.
3. Compressed rules could drop classic conditions. Compared the original rules against design O1–O19: the non-close cap answers again require further review; Context7 and Ponytail duties moved into both CLAUDE surfaces.
4. New tests could assert less than their labels suggest. Assertions inspect actual mode numbers and reader output and can fail; no unfailable test found. Strict-cap coverage checks the warning at five but does not alone exclude an earlier warning.

## AC-to-test mapping

| AC | Asserting test, or none | Scope and inspection result |
|---|---|---|
| AC-1 | Hook suite section 50, partial; none for agent closure | Lean B floor/cap reminders tested; prompt specifies closure and cap routing. |
| AC-2 | none | Rules specify previous-head fix diff, carry-forward and late-finding treatment, with full-review fallback. |
| AC-3 | Hook suite section 50, partial | Modes, fallback, overrides and remembered modes tested; classic restoration and initializer migration checked by reading. |
| AC-4 | Hook suite section 50 A floor/cap and threshold-note cases, partial | Rules specify threshold, profile header and high-risk plans; reference.md:717 conflicts with the threshold. |
| AC-5 | none | Both CLAUDE surfaces specify five rounds and failure states, preserving untouched-test timeout exception; Gate B retains coverage review. |
| AC-6 | none | Both Plan paragraphs require a real app run and recorded evidence per UI AC outside classic. |
| AC-7 | none | harden-finding requires a reason for prose outside classic and retains lint/test preference. |
| AC-8 | Hook suite section 50; existing advisory-exit cases and section 48 | Lean numbers fail on the old implementation; protection recommendation is prose, not enforcement. |
| AC-9 | none | Both rule copies require archive collision stop-and-compare and resume lookup; skill and ledger columns specify learning fields. |
| AC-10 | none | Design O1–O19 checked against old and new rules; relocated duties preserved. |
| AC-11 | ledger-metrics.test.sh section 9; loop-usefulness.test.sh final floor-1 fixture; historical fixtures | Both floors asserted in mixed historical/new records. Commit-record format unchanged; archive relocation does not change transcript paths already recorded by analytics. |
| AC-12 | check-invariants.sh 4e, 4i, 4j, plus narrow prompt checks | Invariant checks passed here; prompt semantics checked by reading rather than inferred from byte checks. |
| AC-13 | check-version-bump suite and supplied battery evidence, partial | Manifest is 0.46.0; changelog, README and docs updated. Full battery supplied for d0f1134 and both hook suites for this head, not rerun here. |

## Earlier findings

Pass-1 cap-answer, classic hardening and branch-protection findings are fixed. The documentation class has the surviving sibling reported at reference.md:717. Both pass-2 findings are fixed at their cited sites: Gate B limits and carry-forward are explicit, skipped-spec approval includes the checkpoint, and archive collisions require stopping and comparing. The implementer's additional unusable-mode-note, setup approval and hardening-example claims match the current files.

## Independent verification

- `sh scripts/check-invariants.sh`: exit 0.
- `sh scripts/ledger-metrics.test.sh`: exit 0, 46 passed.
- `sh scripts/loop-usefulness.test.sh`: exit 0, 17 passed.
