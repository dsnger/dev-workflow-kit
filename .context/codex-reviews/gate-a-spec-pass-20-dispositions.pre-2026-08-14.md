# Gate A — spec — pass 20 dispositions

Artifact: `docs/superpowers/specs/2026-08-05-hardening-ledger-supersession-design.md`.
6 findings: 6 Major. **No Blocker, no Minor, no Nit.** All six valid. **All six applied.**

Reviewer: `mcp-codex-dev@1.0.1`, `codex-cli 0.144.5`, model `gpt-5.6-sol`. Pass file valid:
7 lines, 6 finding lines, terminator exact, no stray artifact.

Passes 4 → 20: **11, 14, 16, 15, 9, 10, 5, 12, 8, 6, 3, 4, 7, 6, 6, 5, 6.**

## Shape of the pass

**Five of six land on check 1d — the property pass 19 rewrote.** That is the cycle's standing
pattern (the previous pass's fix is subtly wrong) but at a severity and concentration the last
three passes did not show: pass 19 replaced an unsatisfiable property with a satisfiable one and
under-specified almost everything the replacement newly needed. None of the six is claim-sharpening,
so the termination rule does not fire.

## Verdicts

| # | Sev | Verdict | Applied as |
|---|---|---|---|
| 1 | Major | **Valid — the replacement property is weaker than it reads.** "No inert added entry stands uncorrected" is satisfied by any later non-inert added entry, including one marking an unrelated row. Nothing links two entries, and the only mechanism that could — an entry identity — is the wire format §2.2 refuses. So the old check caught the mistyped-locator case and the new one can pass while the target row stays unmarked. | 1d split into an explicitly **unequal** pair: a mechanical **positional floor** that says what it is, and the repair judgement moved to **1f**, which now owes five confirmations for the successor entry. §8's human-read bullet records the gap. |
| 2 | Major | **Valid, and mechanically checkable.** CommonMark needs a blank line between the entry list and the `Columns:` paragraph or `Columns:` renders inside the list item — so the prescribed layout puts a non-entry line inside the block, and an oracle demanding every added line in the block parse would reject the design's own layout. | The candidate interval is now stated (label → `Columns:`, both exclusive) and candidates are its **non-blank** lines; the structural blank is named as required rather than exempted by silence. |
| 3 | Major | **Valid — the withdrawn uniqueness guarantee can survive in the implementation.** §3.1's entry is fragmentless and matches exactly one row today, so a checker that ignored fragments or still demanded exactly one match passes this change. No oracle covered fragment-aware matching, zero/one/many, or the on-or-before boundary. | A third oracle, with named fixtures: the fragmentless locator matching **both** `2026-07-18` `docs-drift` rows, a fragment narrowing that pair to one, a fragment matching neither, and rows before / **on** / after the entry date. |
| 4 | Major | **Valid, low blast radius here.** Identical duplicate entry lines — which `merge=union` can produce — make occurrence alignment ambiguous, and in an *inert, valid, inert* sequence the verdict would depend on which occurrence a differ attributed to the base. For **this** change the base carries no block at all, so the added set is unambiguous; the property was still stated undecidably. | The alignment is pinned: the base entry sequence must remain an **exact prefix**, added entries are the remaining suffix, and the empty-prefix case for this change is named. |
| 5 | Major | **Valid — and it is the gap I named in pass 19's own dispositions.** §2.1's resolution floor is stated for rows; §2.2 said "never edited, never removed" with no floor, so when an entry becomes immutable was left to analogy — which is exactly how the amendable class came back three times at row level. 1d's whole rationale depends on the answer. | The floor is written into the **shared prose** (so it reaches every scaffolded ledger) and given a rationale paragraph in §2.1. New **anchor 35**. |
| 6 | Major | **Valid.** Entry recognition named the two prose fields without requiring content, and 1f covered only the mandated entry — so a locator-valid line with empty fields could count as the non-inert successor for an earlier typo, and no read would ever open it. | Recognition now requires **both prose fields non-empty**; 1f's new paragraph extends the four confirmations to the successor entry. |

## Also applied, not from a finding

Two clauses added to the shared prose across passes 19–20 (the fragment-narrowing limitation, the
entry floor) were unanchored, so check 2 could not detect their deletion from both surfaces. Both
now carry anchors — **34** and **35** — the count claims moved thirty-three → **thirty-five** at
both sites, and §8's known-unanchored list was corrected: the narrowing is anchored now, its
no-double-quote condition still is not.

## Sweep after applying

35 anchors, numbering contiguous, each exactly once in the convention prose, none a substring of
another, no CommonMark padding asymmetry; six fence lines, balanced; both count claims read
thirty-five.
