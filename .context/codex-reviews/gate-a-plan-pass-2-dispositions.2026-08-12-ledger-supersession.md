# Gate A — plan — pass 2 dispositions

Artifact: `docs/superpowers/plans/2026-08-12-hardening-ledger-supersession.md`.
11 findings: **1 Blocker**, 8 Major, 2 Minor. All eleven valid. **All eleven applied.**

Reviewer: `mcp-codex-dev@1.0.1`, `codex-cli 0.144.5`, model `gpt-5.6-sol`. Pass file valid:
12 lines, 11 finding lines, terminator exact.

Plan passes: **18, 11.**

## The Blocker

**Task 4 Step 9 through Task 8 Step 5 — `git add -A` stages what it must not.** The working tree
carries `docs/research/`, untracked and not ours, and the executor creates fixtures. Either could be
swept into a commit or an amend — changing the Gate-B range, and publishing an unrelated tree.
Applied as three constraints: never a pathspec broader than the step's own file list; **assert the
staged set equals the intended paths before every commit and amend**, via
`git diff --cached --name-only`; and the harness lives **outside the repository working tree**, so
nothing the executor creates appears in `git status` at all. Task 8 Step 5 and Task 1 Step 3 were
rewritten to stage explicitly.

## The eight Majors

| Finding | Verdict | Applied as |
|---|---|---|
| "Counter-check every pattern against the pre-edit tree: it must return 0 there" | **Valid, and self-contradictory as written.** Carried over from the spec's fence rider, where it meant *the pattern must not match*; sitting beside an exit-status convention where 0 is success and a table saying five labels must **fail** pre-change, it instructs the executor to record the required counterfactual as a harness defect. | Replaced with an explicit clean-tree outcome table: five labels must fail, two must pass, and each direction's failure mode named. |
| `rows-truncated` / `rows-overlong` expected only `C1a` to fail | **Valid.** `C1d`.7 independently requires `C1d` to reject incomplete and overlong rows; a matcher accepting them passed every stated outcome. | Both cells now **FAIL `C1a`, `C1d`**. |
| No fixture pairs a good mandated entry with an extra inert one | **Valid — this is what closes §8 item 3 with evidence rather than words.** A checker still quantifying over every added entry passed the whole matrix and the real tree. | `entry-good` now carries the mandated entry **plus a second inert entry**, expected PASS. |
| `entry-bad-date` invalidated only the entry date | **Valid.** `C1d`.5 covers the locator's row date too; a checker validating one satisfied every listed outcome. | Split into `entry-bad-date-entry` and `entry-bad-date-locator`, both FAIL. |
| `entry-empty-field` said "one prose field empty", unspecified | **Valid.** The oracle requires both fields independently. | Split into `entry-empty-first-field` and `entry-empty-second-field`. |
| Matrix rows naming `C3` were to be run in Task 4, before `C3` exists | **Valid — an ordering defect, not a wording one.** The step could not be completed as written, and Task 5 never re-ran them. | Task 4 Step 3 now runs only rows naming `C1a`/`C1d`; Task 5 gained a step running the deferred `C3` rows. |
| Task 5's counter-check moved the whole block | **Valid.** A moved block still has every entry inside its own interval, so the interval oracle stayed unverified. | Added: append a second entry-shaped line **below the table while the valid block stays in place**. |
| `C1c`'s counter-check mutated "one input" | **Valid, and precise.** A three-input implementation reads both current surfaces and one base; mutating any of those three still fails, so the mutation did not identify the omitted input. | Now names it: corrupt the **base version of the template** specifically, confirm the guard fires before comparison. |
| Task 8 restated §5's target-file deletion rule as "delete both before each call" | **Valid on both counts.** It violates the citation-only rider **and** contradicts §5, which requires a single-branch resume to delete only the failed branch — deleting both makes the both-files check fail by construction and can spend the sole recovery attempt on a path that cannot succeed. | Reduced to `reviewType: full` plus a citation; the lifecycle and recovery rules stay §5's. |

## The two Minors

"Two prose paragraphs" → **"Two convention blocks"**, since §2.2's block is an intro paragraph, an
indented example and a closing paragraph. Narration stripped at three sites: the landed-files list
reframed as *outside this execution's scope, verify and do not rewrite*; Task 1's commit message
described by artifact content rather than by cycle closure; Self-Review's §7 line reworded to what
§7 is rather than to the state of a finished review.

## Sweep after applying

Step numbering contiguous in all eight tasks (Task 5's insertion renumbered); 17 fixture rows with
no stale count claim anywhere; eight labels, `C1e` appearing only where its absence is recorded; 35
anchors byte-identical to the spec; 12 fence lines, balanced; every stated count — eight labels,
five falsifying labels, four inputs, seven distinctions, thirty-five anchors, twelve items —
verified against what it counts; `add -A` appears once, in the constraint forbidding it.
