# Gate A — plan — **CLOSED on dispositions, with four post-pass fixes**

Closed 2026-08-16 by Daniel's decision, after pass 6.

| Pass | 1 | 2 | 3 | 4 | 5 | 6 |
|---|---|---|---|---|---|---|
| Findings | 18 | 20 | 17 | 15 | 9 | 9 |
| Blockers | 1 | 0 | 1 | 1 | 1 | 1 |

**88 findings, none dismissed.** Six passes; the floor was met at pass 3 and the loop continued
because no pass was clean.

## Why this closes on dispositions rather than a clean pass

**The checker's verification channel is execution, not review.** Every defect check 4c ever
had was found by running it, and none by reading it:

| Defect | Found by |
|---|---|
| Fence-mode parser returned `MULTIEND` on the real file — the check could never pass | running the `awk` against `workflow-init.md` |
| `checklist parser failure fires` had stopped testing 4b (its grep matched 4c's diagnostic too) | the mutation run — 21 flips against a recorded 22 |
| Whole-file counting silently dropped the placement guarantee | planting the line in the command file's prose and watching the battery stay green |
| Placement failed open when its terminator moved | renaming `### 2.2` and planting a line in the widened gap |

Four review passes read the first as prose without finding it. The last two were found in
minutes by executing the thing.

**So the remaining assurance comes from the tools and from Gate B, not from a seventh pass.**
The scripts are in the reviewed range: `baseSha` = `c0a6ed2`, and the WIP snapshot carries
`scripts/check-invariants.{sh,test.sh}` along with the spec and this plan. Gate B reads them
**as code**, which is the review they should have had all along.

## The four post-pass fixes

1. **Terminator validation.** The placement range's end must be `### 2.2`; anything else fails
   loudly, naming what it found. Three fixtures, including the verified exploit — rename the
   terminator, plant the line in the widened gap. Confirmed rejected.
2. **Mutation re-measured.** 4c flips **19** (18 rejects + the parser case), no accept case
   moved. It read 13 before the placement fixtures and 16 before the terminator ones; each
   superseded number was replaced by re-running, never extrapolated. The block now says so.
3. **Task 0 deleted.** It committed the spec, plan and scripts immediately before the WIP —
   making that commit the WIP *parent*, which `baseSha..HEAD` excludes, so Gate B would have
   excluded exactly what it existed to include. It was also a non-WIP commit of executable
   code with a red battery and no Gate-B loop. The one-line fix it should have been: the WIP
   snapshot carries those four files, `baseSha` = `c0a6ed2`.
4. **Self-review and inventory rewritten from the code as built** — `severity_rule_scan <file>`
   returning four integers, not the withdrawn `severity_rule_count(file, mode)` sentinel API;
   24 `sev_case` cases, not 15. And Task 4 Step 4 now follows §6's settled **TRIGGER FIRED**
   rather than reopening it.

## State at closure

- **148 assertions** green under `sh` and `dash` (123 before), shellcheck clean on both scripts.
- **The counterfactual is observed, not asserted:** with 4c present and the canonical line not
  yet in either prompt copy, `sh scripts/check-invariants.sh` exits 1 naming only 4c on both
  files. The battery is **red by design** until Task 1's prose edits land.
- Uncommitted: the twice-amended spec, this plan, both scripts. `c0a6ed2` is the only commit.

## What Gate A did not settle

The plan's prose has been the slow part, not the design: passes 5 and 6 were dominated by
descriptions going stale as the code changed under them. Gate B reviews the code and the
shipped prompt text; it does **not** re-review this plan. A reader following the plan should
treat the built scripts as authoritative where the two disagree.

## Next

Execution: test-first, battery green before the Gate-B loop, §5 cited rather than restated,
evidence per `battery+check` with the observed counterfactual.
