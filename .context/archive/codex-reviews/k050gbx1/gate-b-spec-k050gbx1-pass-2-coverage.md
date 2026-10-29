# Spec coverage — k050gbx1 pass 2

Range: f3269ce4ee6f9155282f4f856f7c4cd212987074..abe0ef088af648a900bfc0c4225b23cca9967659.

Hypotheses checked: release classification could admit non-version changes; inheritance could use a moved source ref or conceal base changes; existing green-evidence consumers could still demand the full lane. Reviewed the actual classifiers, their call sites, both suites, the rules and scaffold copies, and the changed docs against the story, design and plan. Shell and Markdown were read directly.

| AC | Test or other evidence |
|---|---|
| AC-1 | Hook test section 14c, lines 687 and 705; local-ci cases 25 and 28. Actual release note and gate rule inspected. |
| AC-2 | Hook section 14c dependency/code/pair/nested/instruction cases; local-ci cases 24, 26–29, 31–33. Run markers distinguish full and light lanes. |
| AC-3 | Existing hook section 14b and new section 14c docs/mixed fixtures; original docs-only branch unchanged. |
| AC-4 | local-ci cases 23–35, including docs-only with no light row at 461–462 and failure posting at 463–466. Light command and base-commit site lookup inspected. |
| AC-5 | local-ci cases 36–40: same tree, records, moved ref during read, gitlink, base-only rebase, unsuccessful/missing/unreadable status and failed diff. Inheritance asserts neither run marker exists. |
| AC-6 | Status assertions in local-ci suite; every product post goes through context=quality. No diff in .github/workflows/ci.yml. |
| AC-7 | none (prose requirement); line inspected at docs/reference.md:317 and README table. |
| AC-8 | Hook section 14c and local-ci cases 23–26 and 39 cover the five named situations. |
| AC-9 | none yet; final-head measurements and PR reporting explicitly follow Gate B under plan T5 and the review request. Deferred obligation, not claimed complete. |
| AC-10 | check-invariants.sh checks 4m/4n and direct inspection of manifest 0.50.0, version record, CHANGELOG, README, reference and scaffold additions. Publication remains downstream of this review. |

Pass-1 dispositions independently checked:
1. fixed — process-pr-review.md:47, 233–240, 270–274, 338–339; docs/reference.md:360, 816.
2. fixed — scripts/local-ci.test.sh:461–462 now changes only docs against a base without a light row.
3. fixed — scripts/local-ci.test.sh:439–441, 470–473; hook suite:688–689, 708. The status stub invokes gh.onread before returning, moving the branch while the runner must retain its resolved SHA.

Invariants reviewed: hook remains advisory and the new branch falls through on uncertainty; shell remains POSIX and missing jq conservatively rejects manifest releases; templates remain inline; rule trims preserve conditions; version changes 0.49.0 to 0.50.0; inherited paths return before temporary worktree creation; no new product fetch/push/prune or branch/workflow/ruleset mutation. Prompt changes checked against the 12-item checklist. Mechanical check-invariants.sh passed in this review, including 4i/4j/4m/4n. Supplied full-battery evidence was not represented as a new run here.

Independent test run in this review: scripts/local-ci.test.sh completed with all 89 assertions passing. Log: /tmp/k050-spec-pass2-local-ci.log. The hook suite and full battery were not rerun here.
