# Gate A — spec — pass 23 dispositions (CLOSING PASS)

Artifact: `docs/superpowers/specs/2026-08-05-hardening-ledger-supersession-design.md`.
4 findings: 2 Major, 2 Minor. **No Blocker.** All four valid. **ALL FOUR HELD-NOT-FIXED**,
recorded as §8 residuals per the stop decision taken before the pass ran.

Reviewer: `mcp-codex-dev@1.0.1`, `codex-cli 0.144.5`, model `gpt-5.6-sol`. Pass file valid:
5 lines, 4 finding lines, terminator exact, no stray artifact.

Passes 4 → 23: **11, 14, 16, 15, 9, 10, 5, 12, 8, 6, 3, 4, 7, 6, 6, 5, 6, 7, 5, 4.**

## Verdicts

| # | Sev | Verdict |
|---|---|---|
| 1 | Major | **Valid, and the most consequential of the four.** 1d's narrowed matching oracle names zero-from-at-least-one and the on-or-before bound; it never says the locator's **row date** must match exactly. A checker comparing fingerprint only passes the mandated entry, the two-row fixture and all three date positions, while reporting non-inert an entry whose locator matches no row — the property 1d exists to decide. The narrowing at pass 22 removed the fixture set that had incidentally covered it. |
| 2 | Major | **Valid.** Pass 22's Format repair was right about consumers and overreached on persistence: it called the grammar validation-only and binding "nothing after" this change, while the shared prose makes the shape, the ` · ` ban, calendar dates and the completeness boundary **standing rules for every future author**. §5 and §8's discriminator bullet still carry the old broader "prose-only / nothing consumes" wording. The accurate claim is *no standing machine consumer*; the syntax is a standing human convention. |
| 3 | Minor | **Valid.** 1d's scope oracle reads plural — "The mandated entry, and only entries this change adds" — and can be quantified over every added entry, recreating the unsatisfiable property pass 21 removed. |
| 4 | Minor | **Valid.** §8's format-example bullet says shape is "the whole guard". For this change, location guards it too: 1d bounds candidates to the label-to-`Columns:` interval and check 3 rejects entry-shaped lines outside it. The claim is correct about **standing** enforcement and wrong about this change's validation. |

## Why none was fixed

Daniel took the stop decision **before** pass 23 ran, precisely so the closing pass could not
reopen the loop: clean or dispositions-only → normal close; anything else → §8 residuals, stated
as held-not-fixed. Repairing findings 1 and 2 would have produced another revision no pass had
seen — the exact state pass 23 existed to end, and the state that generated four of this cycle's
worst passes. All four are recorded in §8 with the concrete remedy, and findings 1 and 3 land on
the executable check, which the plan writes and **Gate B reviews against the real diff**, where a
check finally has something to be checked against.

Two of the four (1 and 4) are the cycle's signature pattern once more: **the previous pass's fix
was subtly wrong.** Pass 22 narrowed 1d's oracle and took a needed distinction with it; pass 22
narrowed §2.2's Format claim and left two sites carrying the old one. Diminishing, and never zero.
