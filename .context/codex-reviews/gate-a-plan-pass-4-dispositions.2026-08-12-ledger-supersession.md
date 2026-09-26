# Gate A — plan — pass 4 dispositions

Artifact: `docs/superpowers/plans/2026-08-12-hardening-ledger-supersession.md` (two findings landed
in the spec). 8 findings: **3 Blocker**, 4 Major, 1 Minor. All eight valid. **All eight applied.**

Reviewer: `mcp-codex-dev@1.0.1`, `codex-cli 0.144.5`, model `gpt-5.6-sol`. Pass file valid:
9 lines, 8 finding lines, terminator exact.

Plan passes: **18, 11, 9, 8.** Blockers: **2, 1, 4, 3.**

## The three Blockers — all three are the same shape

Every one is a place where pass 3's fix landed in one site and not in its mirror.

**1 — spec §8's held-not-fixed intro still said Gate B reviews the plan and the executable checks
"against the real diff",** contradicting the §6 sentence and the §8 residual pass 3 had just
written. Task 1 would have committed a spec disagreeing with itself about the exact review boundary
the plan depends on. Corrected to the settled division: Gate B compares the **implementation
range**; the plan is committed and inside it, the scratch check source is context and never
range-reviewed.

**2 — the plan promised the reviewer sees the check source, and Task 8 never supplied it.** The
opening contract and spec §8 both rest the checks' only review on a paste into `additionalContext`
that the `additionalContext` list did not contain. Now required there in full — harness, every
check, and the fixture definitions — with the reason stated, since omitting it makes the recorded
residual false rather than merely incomplete.

**3 — nothing composed the evidence entry before the Gate-B call.** §5 requires it at every call and
re-review; the plan first mentioned it at the closing amend and the placeholder scan deferred it
there deliberately. A new Step 4 composes and validates it — battery result, the named failing
label, the counterfactual — and every later step quotes and revalidates that text.

## The four Majors

**The `C2a` oracle still said "two anchors begin with `-`".** Pass 3 corrected the anchor-data line
and the spec's oracle and missed the plan's own copy of the same sentence — the third site of a
two-site fix. Exactly one anchor begins with `-`; five contain backticks.

**`git reset --soft` cannot be repaired by adding paths.** The soft reset leaves everything since
`BASE` staged, and an explicit `add` does not *unstage* an extra path — so in the very state the
step warns about, the equality assertion halts execution with no route forward. Changed to
`--mixed`, which clears the index and leaves the worktree, then stage the five and assert.

**`C1d`.2 was mis-credited with closing §8 item 4.** The candidate interval makes `C1d` **ignore**
an entry-shaped line outside the block — the opposite of detecting one. `C3`'s whole-file rule and
Task 5's below-the-table counter-check are the executable guard; the interval is the half that keeps
the format example out of the candidate set. Both the oracle and the Self-Review trace now say so.

**§5 protocol was still being restated** at Task 1 Step 3 and Task 8 Steps 3, 5 and 6 — WIP/amend
mechanics, stale-range reasoning, evidence revalidation. Trimmed to the change-resolved values and
pointed citations; the imperative steps and the corrections that pass 1 and 2 established are kept,
the explanations of why §5 works that way are not.

## The Minor

"Assert exit status, never printed output" contradicted Task 2's self-test, which must assert that
the deliberate failure was **printed**. The rule is now scoped to properties and fixture outcomes,
with the harness meta-test named as the single carve-out.

## Sweep after applying

Step numbering contiguous in all eight tasks, verified per task rather than by eye; the hyphen claim
gone from all three sites; `reset --mixed` at both mentions; 35 anchors byte-identical; 12 fence
lines, balanced.
