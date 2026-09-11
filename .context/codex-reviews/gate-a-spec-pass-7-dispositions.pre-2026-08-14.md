# Gate A — spec — pass 7 dispositions

Artifact: `docs/superpowers/specs/2026-08-05-hardening-ledger-supersession-design.md`
15 findings: **1 Blocker**, 9 Major, 4 Minor, 1 Nit. All read as correct. **None applied.**

Reviewer: `mcp-codex-dev@1.0.1`, `codex-cli 0.144.5`, model `gpt-5.6-sol`. Same as passes 4–6.

## The blocker

**Finding 9.** §2.1 says *"If that file cannot be read at that ref, treat the row as landed."*
§9 says every non-confident outcome — including **a stale ref** — "is *landed*, **by the rule in
§2.1**". §2.1 carries no such rule: a stale-but-**readable** `origin/main` yields a confident
*absent* for a row that is published on the real remote, and the convention then authorizes
editing it. That is the append-only breach the whole design exists to prevent.

Verified: `docs/…-design.md:58` covers only *cannot be read*; `:653–658` claims stale resolves
to landed by that rule. The two disagree, and the safe reading is not the one §2.1 states.

This is the **third instantiation of one defect**, each time in the sentence written to fix the
previous one: pass 6 finding 12 killed "the repository always answers"; the replacement narrowed
to "confident present / confident absent"; and *confident absent* is itself unsound when the ref
is stale. The undefined step keeps moving instead of closing.

## Verified mechanically

| # | Claim | Result |
|---|---|---|
| 9 | §2.1 and §9 disagree on a stale readable ref | **Confirmed**, lines 58 and 653–658. |
| 11 | §3.1 still teaches the cut model | **Confirmed**, line 257: "The entry is falsification-scoped, not row-scoped". The cut executed in §2.2 and not in the worked example — the exact wording-not-mechanism failure this pass was told to hunt. |
| 6 | check 2 dirties the worktree | **Confirmed**, lines 497–499 write `region.*.txt` into the repo root with no cleanup. |

## Table

| # | Sev | Verdict | Note |
|---|---|---|---|
| 9 | **Blocker** | **Valid, confirmed** | See above. |
| 1 | Major | **Valid** | §2.2 defines `<date>` as the day the entry is written; §3.1 and all three checks hard-code `2026-08-05`, and implementation is later. Either the first entry violates the convention on day one, or fixing the date breaks the checks. |
| 3 | Major | **Valid** | The re-derived table omits three of the old rule's conditions — marks text never the hardening, keeps fingerprint and counting, later removal out of scope. The first is *materially changed* by the phantom-hardening case, so the omission hides a widening. Same class as pass 6's findings 7–9, on the table rewritten to fix them. |
| 4 | Major | **Valid** | §9's "complete" unanchored list is not complete: amendment of an absent row, one-way landedness, the date+fingerprint locator, the `YYYY-MM-DD` requirement, phantom-hardening, and fingerprint/counting preservation are in neither the 16 anchors nor the list. |
| 10 | Major | **Valid** | "Unknown authorship" was not widened into "ref unreadable" — the triggers are incomparable, and a *readable absent* ref flips unknown-provenance rows from landed to amendable. The changed-verdict table claiming completeness omits that case and two others. |
| 11 | Major | **Valid, confirmed** | See above. |
| 12 | Major | **Valid** | The "cover the row as it now stands" duty lives only in design rationale, outside the prose copied to both surfaces. A downstream author following the shipped convention can write a narrow second marker and make an earlier still-false claim non-governing — breaking AC 4. |
| 13 | Major | **Valid** | Supersession entries target *landed* rows, so they sit outside the unpublished-region single-writer assumption entirely; the concurrency rationale invokes an assumption that does not cover the case. And §9 still says the old rule carried the same assumption, which §2.1 now correctly says it did not — the two contradict inside one document. |
| 14 | Major | **Valid** | `merge=union` does not "overwrite"; it keeps both edited variants, producing two rows with one locator — which corrupts recurrence counts, a worse and different failure than the one §9 describes. |
| 15 | Major | **Valid** | "Damage cannot reach merged history without passing through the PR that merges it" — nothing requires publication through a PR, and `AGENTS.md` already records direct-push bypass for invariant 12. Enforcement-overclaim class, again. |
| 2 | Minor | **Valid** | Table row 1's quote inserts a `…` not present at `5e295f0` while the prose claims each row carries the old rule's own sentence verbatim. |
| 5 | Minor | **Valid** | Assertion 2 uses `grep -cF` — lines, not occurrences, and substring not line-shape — so it does not prove the sentinel cardinality it claims. The same defect pass 5 fixed in assertion 1, reintroduced in assertion 2. |
| 6 | Minor | **Valid, confirmed** | Worktree dirtied by the validation itself. |
| 7 | Minor | **Valid** | Template label check is column-zero exact; a leading-space label passes as "no label". |
| 8 | Nit | **Valid** | "Four assertions on line numbers" — assertion 4 produces no line number. |

## Recommendation recorded with the pass

Passes 4–7 returned **11, 14, 16, 15**. Four consecutive passes, three stable failure modes, and
the same defect class re-instantiated three times inside its own fixes. This is not a list to
grind down; the loop is not converging and the next pass should not be more of the same.
