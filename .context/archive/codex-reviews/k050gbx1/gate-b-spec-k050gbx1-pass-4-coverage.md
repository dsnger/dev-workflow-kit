# Spec coverage — k050gbx1 pass 4

Range: f3269ce4ee6f9155282f4f856f7c4cd212987074..6db460ae57757bdae4f37287a0ae985124162969.

Initial hypotheses: light classification could admit non-release content; version/path parsing could broaden eligibility; gate-rule trims or green-evidence consumers could contradict retained requirements. Checked against actual diff, source, story, design and plan, rather than the implementation claim.

| AC | Test or other evidence | Assessment |
|---|---|---|
| AC-1 | Hook suite section 14c (starts at line 659), release and listed-site cases; local-ci cases 25 and 28. Read both release_only implementations and the hook note/rules. | Implemented. |
| AC-2 | Hook section 14c dependency, code, differing version pairs, nested version, instruction paths, malformed tokens and unlisted sites; local-ci cases 24, 26–29, 31–33. | Implemented; negative fixtures exercise the conservative fallback. |
| AC-3 | Existing hook section 14b at line 588, plus section 14c docs and docs+code cases. Original docs-only function and branch remain unchanged and ahead of release classification. | Implemented. |
| AC-4 | local-ci cases 23–35, including binary docs image, instruction paths, no light row, and failing light command. lane_is checks the command marker, output and cleanup; full checks the actual battery SHA and posted status. | Implemented. |
| AC-5 | local-ci cases 36–40: same tree, records, moving source ref, gitlinks, rebase/base-code change, failed status reads and failed path diff. inherited asserts neither command ran and checks source SHA, description and cleanup. | Implemented. |
| AC-6 | local-ci posted/lane_is/inherited assertions require quality; direct diff inspection confirms ci.yml is unchanged. | Implemented. |
| AC-7 | none (prose inspection): docs/reference.md under The review gates and README contain the requested line. | Implemented. |
| AC-8 | Hook section 14c and local-ci cases 23–26 and 39 cover the five required situations. Inspected fixture changes and assertion helpers, including run markers; assertions can fail on incorrect lane behavior. | Implemented. |
| AC-9 | none yet: approved plan T5 and user context schedule measurements after the final green head. | Pending at the planned later stage; not a finding for this review. |
| AC-10 | check-invariants.sh passed during this review, including version record and template-copy checks. Manifest, record and inline template are 0.50.0; CHANGELOG, README and workflow docs inspected. | Release contents implemented; publishing/closing workflow remains outside this review. |

Verification performed here: check-invariants.sh exited 0. Independently extracted each actual release_only function and exercised escaped-site rejection, NUL-version rejection and valid-release acceptance in a scratch repository, each under sh and dash (12 expected outcomes). No real status posts. The full battery and complete suites were not rerun; their supplied execution evidence is separate from these observations.

Prompt/invariant inspection: checked changed prompts against the 12-item prompt checklist, retained retry/failure/final-head conditions, inline scaffolding and the narrow gate-rule trims. The hook retains its advisory exit behavior and conservative jq-free manifest fallback. local-ci retains its write boundaries; inherited lanes post before allocating a worktree. No additional feature or dropped binding decision condition identified. Source discovery used direct reads/searches of shell scripts and Markdown, the stated graph-search exceptions; no index completeness claim.

Earlier pass-3 finding: fixed. scripts/local-ci.sh:181 and plugins/dev-workflow/hooks/codex-gate.sh:1563 split ENVIRON["sites"], rather than an awk -v decoded value; check 4m confirms the inline copy. The focused escaped-site checks reject metadata/v2, and both suites contain the regression. Manifest token validation is anchored inside jq at scripts/local-ci.sh:217 and plugins/dev-workflow/hooks/codex-gate.sh:1599, before shell extraction.
