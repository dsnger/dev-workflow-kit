# Gate A — plan — pass 5 dispositions

Artifact: `docs/superpowers/plans/2026-08-12-hardening-ledger-supersession.md` (one finding landed
in the spec). 6 findings: **1 Blocker**, 3 Major, 2 Minor. All six valid. **All six applied.**

Reviewer: `mcp-codex-dev@1.0.1`, `codex-cli 0.144.5`, model `gpt-5.6-sol`. Pass file valid:
7 lines, 6 finding lines, terminator exact.

Plan passes: **18, 11, 9, 8, 6.** Blockers: **2, 1, 4, 3, 1.**

## The Blocker

**`BASE` contains the plan, so `$BASE..HEAD` excludes it — while spec §8, as pass 4 rewrote it, said
the committed plan falls inside the reviewed range.** The pass-4 correction had landed in the spec
and not in its plan mirror, which is the failure mode this pass was aimed at and found once more.

Resolved toward the classification Task 1 already establishes rather than by moving the baseline:
the plan is a Gate-A artifact committed as prose, so it is **not** in the Gate-B range, and §8 now
says so — neither the plan nor the check source is inside it, both reach the reviewer as context.
Moving `BASE` to the Task-1 commit's parent was rejected: it would drag the spec and story into a
range they were classified out of, replacing one contradiction with a worse one. Task 8's
`additionalContext` now carries the plan's path alongside the story's.

## The three Majors

**Task 2 Step 5 called the self-test, `shellcheck` and the counter-checks the harness's "only
review"** — contradicting the opening contract, Task 8 and spec §8, all of which add the reviewer's
read of the pasted source. Two incompatible accounts of the same guard. Now: *outside the reviewed
range* is the true claim, *unreviewed* is not, and the reviewer read is listed with the rest.

**`entry-outside-block` had no determinate expected result.** "An entry-shaped line below the table"
is two different fixtures: the mandated entry **moved** there (must fail `C1d`) or an extra line
added while the mandated entry stays (must **pass**, under `C1d`.1 and `.2`). Building the second
and expecting failure would have made the pass-2 scope remedy look broken. Defined as the move, with
the addition left to Task 5's separate counter-check, and both constructions named in the cell.

**`C1c`'s counter-check never re-ran after the final restore.** The last green result predated the
mutations, so an incomplete restore could have been committed under a verdict that never saw it. A
green run on the restored real surfaces, both shells, now closes the step before the commit.

## The two Minors

Task 4 Step 5's "everything else is verbatim from §3.1" also covered the `**Superseded rows:**`
label, which is §2.2's — the verbatim claim is now scoped to the entry line, with the label
attributed separately. Task 8 Step 3's restatement of what the `WIP: ` prefix does was replaced by a
citation; the leftover duplicate sentence was removed in the same edit.

## Sweep after applying

Step numbering contiguous in all eight tasks; the WIP-prefix restatement gone; 35 anchors
byte-identical; 12 fence lines, balanced.

## Trend

Findings **18 → 11 → 9 → 8 → 6**; Blockers **2 → 1 → 4 → 3 → 1**. Monotone in the count since pass 2
and falling in severity since pass 3. The class has narrowed to one shape — *a fix that landed in
one site and not in its mirror* — which is what passes 4 and 5 were aimed at, and pass 5 found one
instance where pass 4 found three. Not oscillating.
