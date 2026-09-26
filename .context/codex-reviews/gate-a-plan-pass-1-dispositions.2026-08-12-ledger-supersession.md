# Gate A — plan — pass 1 dispositions

Artifact: `docs/superpowers/plans/2026-08-12-hardening-ledger-supersession.md`.
18 findings: **2 Blocker**, 12 Major, 4 Minor. All eighteen valid. **All eighteen applied.**

Reviewer: `mcp-codex-dev@1.0.1`, `codex-cli 0.144.5`, model `gpt-5.6-sol`. Pass file valid:
19 lines, 18 finding lines, terminator exact.

Prior cycles' bare-named plan slots were archived to `*.2026-08-04-hardening-round.md` before this
pass claimed `gate-a-plan-pass-1.md`.

## Settled by the pre-pass sweep, before the pass ran

Two findings the sweep caught first, applied before pass 1 was called — rider 4, immediately:
**428 lines of shell in the plan** (31 fences) against the spec's own "the executable form is
written at execution time, carried in the plan with one label per check" → cut to labels, properties
and oracles, 0 lines of shell. And **check 1's candidates were never bounded to the
label-to-`Columns:` interval**, contradicting spec §6's own 1d oracle — which is also §8 held item
4's trace.

## The two Blockers

| # | Verdict |
|---|---|
| 4 | **Valid.** Task 8 soft-reset to *the parent of the first WIP* and then ran Gate B **before creating a replacement commit** — an empty range — and Step 5's `--amend` would then have rewritten `BASE` itself, folding the Gate-A closure artifacts into an unreviewed final commit. Now: reset to `$BASE`, create one consolidated `WIP:` commit, review `$BASE..HEAD`, amend that. |
| 5 | **Valid.** After a Gate-B fix the plan said only "re-review". `mcp__codex__review` reads the **committed** range, so a worktree-only fix re-reviews the stale diff and reports a clean pass on code the reviewer never saw. Now: amend every fix into the WIP commit, prefix retained, before the next call. |

## The twelve Majors

| # | Verdict | Applied as |
|---|---|---|
| 1 | **Valid.** The plan itself was untracked and no task committed it; Task 1's expected `git status` could not be observed. | Plan added to Task 1's files, status expectation, prose-only classification and commit. |
| 2 | **Valid — the cycle's signature pattern, reintroduced.** Task 4 quoted the end sentinel **with** the editorial ellipsis — the exact defect Gate-A spec pass 18 fixed in the spec. | Replaced with the literal bytes. |
| 6 | **Valid.** The plan claimed the execution-time shell is "reviewed by Gate B" while the harness is scratch and never enters a git range — an overclaim about what a gate proves. | The opening contract now states Gate B reviews the implementation diff and **not** the checks, whose only guards are the self-test, `shellcheck` and the counter-checks; the residual is recorded. |
| 7 | **Valid.** "Nothing standing is added" sat one bullet below the item-2 remedy and reinstated the claim the remedy exists to narrow. | → "**No standing check** is added", with the authoring convention held separate. |
| 8 | **Valid, and the sharpest of the twelve.** "§6 governs on any disagreement" would instruct the executor to discard the four §8 remedies, which exist *because* §6 is wrong there. | Precedence now carves out the four held items and makes their remedies authoritative. |
| 9 | **Valid.** Invariant 9 was absent although the story and spec both name it. | Added with spec §4's verdict (nothing needed; present-and-different routes to diff-and-ask) and folded into Task 8's conformance read. |
| 10 | **Valid — rider 4's unreachable-state cut.** `C1e` validates the ledger's pre-existing chronology; this change appends no row, so it passes before and after and its falsifying observation needs a hand mutation. | `C1e` and `rows-backdated` deleted; recorded in **spec §8** and in `todos.md`'s parked row. Eight labels now, not nine. |
| 11 | **Valid.** The fixture set omitted many-match, the on-date boundary, a calendar-invalid entry date, an overlong row, and empty-field-vs-parse-failure. | Fixture table rebuilt as a matrix of fifteen with an expected outcome and the distinction each kills. |
| 12 | **Valid.** "Each fixture must be able to fail" is wrong for `rows-escapes`, a **valid** adversarial row a correct parser must accept. | Expected-outcome matrix with PASS rows as well as FAIL rows. |
| 13 | **Valid.** Only `C2a` and `C3` had discrimination steps; `C1b`, `C1c` and `C2b` could have been no-ops. | Counter-checks added: mutate the protected row; mutate each surface's header paragraph independently **and** remove a bounding delimiter (the mutation a three-input implementation fails); change one surface's region only. Stderr-as-failure added to the self-test. |
| 15 | **Valid.** §5 protocol was restated through WIP behaviour, reset mechanics, `baseSha`, branch-file deletion, re-review, spec-update, evidence and amend rules — **and the duplicate had already drifted into both Blockers**, which is the argument for the rider. | Stripped to a citation plus the change-resolved values. |
| 3 | **Valid (Minor).** `entry-future-dated` was mapped to `C1d`.6; the distinction it exercises is the eligibility bound in `C1d`.4. | Renamed `entry-before-row`, remapped to `.4`, noted that it manifests as zero matches. |

## The four Minors

14 → blank-line cardinality and adjacency added to `C3`, with the below-the-list blank named as the
mutation every other label survives. 16 → plan-wide narration stripped. 17 → the check table's third
column renamed **"Falsifying observation"**, with the five labels that genuinely fail on the
untouched tree named and `C1b`/`C1c` marked protective. 18 → Task 8 Step 6 now requires `0.8.2` in
the closing body, matching Task 6's promise.

## Sweep after applying

Ellipsis sentinel gone; eight labels defined and used, `C1e` appearing only where its absence is
recorded; 35 anchors byte-identical to the spec; 14 fence lines, balanced; 0 lines of shell; five
held-not-fixed traces; every narration probe returns 0; `reset --soft $BASE`.
