# Spec coverage — k050gbx1 pass 3

Range: f3269ce4ee6f9155282f4f856f7c4cd212987074..99445753db86601540105f595d0e96799b15e0b5. HEAD verified equal to the requested head.

Initial hypotheses: lighter lanes could bypass an existing gate condition; release classification could miss accompanying content; inline templates could drift from repository rules. Read story, design, plan, actual diff, both classifier implementations and call sites, both test additions and helpers, gate-rule changes and consumers, scaffold changes and release documentation. Shell and Markdown were read directly under the graph-discovery exception for shell scripts and non-code files.

| AC | Test or other evidence |
|---|---|
| AC-1 | Hook section 14c release and listed-site cases; local-ci cases 25 and 28. Release note and gate rule inspected. Finding 1 identifies an unlisted-site false positive. |
| AC-2 | Hook section 14c dependency/code/nested/pair/instruction fixtures; local-ci cases 24, 26–29, 31–33. Finding 1 is the remaining escape-decoding hole. |
| AC-3 | Existing docs-only predicate and branch unchanged in the diff; section 14c docs-only and docs-plus-code cases. |
| AC-4 | local-ci cases 23–35: docs, release, instruction exclusions, binary docs image, absent light row and red light command. Run markers distinguish the two commands. Finding 1 affects this classifier too. |
| AC-5 | local-ci cases 36–40: same tree, records, source ref moved during read, differing gitlink, base-only rebase, missing/failed status and failed diff. Helpers assert no battery/light marker for inheritance and full source SHA in the read. |
| AC-6 | All posts use context=quality; status assertions inspect it. No .github diff in the reviewed range. |
| AC-7 | none (prose requirement); docs/reference.md:317 contains the required line, README adds the entry. |
| AC-8 | Hook section 14c and local-ci cases 23–26 and 39 cover all five requested situations. No inherently non-failing test identified. |
| AC-9 | none yet; measurements and PR reporting follow the final head under plan T5 and the review request. Deferred obligation, not a finding or a claim of completion. |
| AC-10 | Manifest, scaffold version and repository version record are 0.50.0; CHANGELOG, README and docs updated. check-invariants.sh passed, including 4i/4j/4m/4n. Release publication is downstream. |

Invariants/boundaries: original advisory exit behavior and docs-only branch retained; new release branch rejects amend/all and falls through on classification failure; missing jq rejects manifest release classification; templates remain inline; trimmed gate prose preserves prior conditions; plugin version is bumped; new inherited paths return before worktree creation and product code adds no fetch/push/prune or branch/ruleset/workflow mutation. The new finding is an exception to invariant 2's conservative classifier behavior. Green consumers accept lane results while retaining final-head, failure, source and retry requirements.

Earlier finding disposition: fixed — scripts/local-ci.sh:217, codex-gate.sh:1599, workflow-init.md:2294. The jq guard rejects embedded newline/CR/space before shell token splitting. Targeted executions rejected newline, CR, space and tab versions and accepted a valid 0.1.1 version. Both suites contain a newline regression case. The pass-2 review was clean.

New finding reproduction: base AGENTS.md contains the literal text **Version sites:** `release\nmetadata/version`; metadata/version contains 0.1.0. Change only metadata/version to 0.1.1. Extracted the actual functions without edits into a temporary fixture repository: hook staged classifier returned 0 under sh and dash; local-ci committed classifier returned 0. awk -v decodes the escape and split(sites, S, " ") produces metadata/version as a separate authorized site. Expected rejection. Temporary fixtures were removed.

Verification performed here: check-invariants.sh passed; targeted parser reproductions as above. Supplied suite/battery results remain external evidence; no full battery or live status posting was run by this review.
