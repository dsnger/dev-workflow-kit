# Gate A — spec — pass 19 dispositions

Artifact: `docs/superpowers/specs/2026-08-05-hardening-ledger-supersession-design.md`
(plus the governing story, which finding 3 lands in).
5 findings: 4 Major, 1 Minor. **No Blocker.** All five valid. **None applied** — held for Daniel
under the pinned exit ("anything new comes to Daniel").

Reviewer: `mcp-codex-dev@1.0.1`, `codex-cli 0.144.5`, model `gpt-5.6-sol`. Pass file valid:
6 lines, 5 finding lines, terminator exact, no stray artifact.

Passes 4 → 19: **11, 14, 16, 15, 9, 10, 5, 12, 8, 6, 3, 4, 7, 6, 6, 5.**

## Premises verified mechanically before judging

| Claim | Result |
|---|---|
| the resolution floor is stated for **rows** only | **Confirmed.** §2.1:49 says "Drafting before a row exists… is below the rule's resolution". §2.2:161 says "Entries are never edited, never removed" and states **no** floor of its own. |
| the shipped prose promises narrowing **to one** | **Confirmed verbatim.** §2.2: "To narrow it to one, add `"<row fragment>"`… pick one containing no double quote." No path is given for a row that has no permitted fragment. |
| 1d's five oracles never define entry recognition | **Confirmed.** The five are: which entries are in scope · a row from a non-row · a delimiter from an escaped pipe · parse failure from an empty field · a read failure from a clean pass. Four of the five specify **row** parsing; none defines what a well-formed *entry* is. |
| the ledger's dates are non-decreasing today | **Confirmed.** 22 rows, no decrease — so 1e passes on the current file, and finding 1's backdating half is a future-state claim, not a present failure. |

## Verdicts

| # | Sev | Verdict | Note |
|---|---|---|---|
| 1 | Major | **Valid — and it is a design gap, not a claim** | Two irreparable states. (a) An entry written with a mistyped locator is, by the letter of §2.2, an entry the moment it exists in the file, and entries are never removed — so appending the correction leaves the inert one inside 1d's *against-base* scope and 1d ("no entry this change appends is inert") can never pass. The convention **sanctions** that state ("append a new entry with a locator that matches, and leave the inert one standing as history"); only §6 refuses it, so §6 is what is wrong. (b) A backdated row is likewise unrepairable and 1e can never be restored — true, and out of this change's reach, since this change appends no row. |
| 2 | Major | **Valid** | The overstatement is in the **shipped** convention prose, so it propagates into every scaffolded ledger while the limitation that qualifies it stays behind in the spec's §8. An author meeting the no-permitted-fragment case is told to do something the design says is impossible, and given no fallback. Inside the pass-17 settlement (record a limitation, add no locator syntax) — it records the limitation where the instruction lives. |
| 3 | Major | **Valid — the third instance of AC 4 promising more than the design delivers** | Pass 1 narrowed it, pass 5 brought §2's desired outcome into line, pass 18 narrowed it to *recorded* corrections and named the removed-hardening exclusion. This is a fourth gap in the same criterion: where siblings are inseparable, one fragmentless entry marks an accurate row too, so a reader determines something **false** about that row — a wrong answer, not a missing one, which is worse than the case pass 18 closed. Needs a **story** amendment, and story amendments in this cycle are human-confirmed. |
| 4 | Major | **Valid — and the first oracle-coverage finding in three passes** | Rider 4 came back empty at passes 17 and 18; this is a real missing distinction. 1d quantifies over "every entry added by the change" and never says how an added entry is **recognised**, so a checker that silently drops a malformed entry-shaped line from its candidate set reports "every recognised entry is non-inert" and establishes less than the property claims — the read-failure-from-clean-pass mistake, one level up, on the half of the match the oracles never describe. |
| 5 | Minor | **Valid as a sharpening, premise partly overstated** | My wording is *"a pair separated **only** by text containing a double quote"*, and Codex's counterexample (`alpha"x` vs `alpha"y`) is separated by `x` and `y`, so the clause correctly does not apply to it. But the phrasing is pair-level and sits inside a condition I had just made per-row, which is the inconsistency worth fixing. Codex's directional example (`foo` vs `foo"`) is better: the longer row's only unique substrings all carry the quote. |

## Read

**The termination rule does not fire.** It says stop if pass 19's findings are *only*
claim-sharpening. Findings 3 and 5 are that class. **Findings 1, 2 and 4 are not**: one is a
validation property the convention's own text contradicts, one is an overstatement in the
**deliverable prose** rather than in the spec's narration about itself, and one is a missing
oracle distinction after two empty rider-4 passes. Two of the three would survive into the plan
and the diff.

**Suggested fixes, if Daniel says continue:**
1. Restate 1d's bound from "no entry this change appends is inert" to "**the entry §3.1
   specifies** matches at least one row dated on or before its date" — the property this change
   actually needs, decidable, and consistent with §2.2 sanctioning inert entries. Record in §8 the
   two irreparable states (a landed inert entry; a backdated row) as residuals of absolutism.
2. Rewrite the shared sentence: a fragment narrows the **match set**, and singles out one row only
   where a permitted distinguishing fragment exists; otherwise the entry necessarily marks every
   matching sibling. Shared prose → lands in both surfaces; re-run the 33-anchor sweep after.
3. Extend AC 4 to the rows the convention can distinguish, with old-condition accounting.
4. Add a sixth oracle to 1d: bound the block, define complete entry syntax (locator, optional
   fragment, date), and separate "no added entries" from "an added entry that could not be parsed".
5. Replace the double-quote example with the directional one, per-row.
