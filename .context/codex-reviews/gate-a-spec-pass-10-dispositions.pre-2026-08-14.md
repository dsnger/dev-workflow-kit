# Gate A — spec — pass 10 dispositions

Artifact: `docs/superpowers/specs/2026-08-05-hardening-ledger-supersession-design.md`
5 findings: 3 Major, 2 Minor. **No Blocker.** All read as correct. **None applied.**

Reviewer: `mcp-codex-dev@1.0.1`, `codex-cli 0.144.5`, model `gpt-5.6-sol`. Same as passes 4–9.

Passes 4 → 10: **11, 14, 16, 15, 9, 10, 5.** First pass since the cycle began with no Blocker,
and the smallest count of the run. Both human-settled changes (the row-bound floor, match
semantics) drew no objection to the decision itself — only to remnants left beside them.

## Verified, not taken on the reviewer's word

| # | Claim | Result |
|---|---|---|
| 1 | assertion 2's "self-contained" fence is broken | **Reproduced.** The fence defines `unwrap() { :; }` — a stub I wrote as a placeholder with the comment "as defined in assertion 1". With it, `occurrences()` reads no input and returns `0` for text that is present: checked at a shell, `occurrences('hello')` on a file containing `hello` returns **0**, not 1. Every sentinel assertion then fails and the block exits before extracting either region. **Pass 9's finding 6 was not actually applied** — the fix made the block self-contained and non-functional. |
| 2 | uniqueness remnants survive | **Confirmed**, `:588` ("an entry's locator resolves to exactly one row") and `:633` ("its locator selects one row"). |
| 5 | "nothing detects it" contradicts check 3 | **Confirmed**, `:641` against check 3's duplicate-label assertion. |

| # | Sev | Verdict | Note |
|---|---|---|---|
| 1 | Major | **Valid, reproduced** | Mine, and the cycle's signature failure in miniature: the fix for "not self-contained" produced a block that is self-contained and does nothing. A stub is not an implementation. |
| 2 | Major | **Valid, confirmed** | Match semantics was applied to §2.2's rule and not to the two places that consume the withdrawn guarantee. Also correctly notes an open question the settlement did not answer: **is a zero-match locator a stop?** Match semantics says an entry applies to what it matches; it does not say what a locator matching *nothing* means. |
| 3 | Major | **Valid** | `D=$(mktemp -d)` is unchecked before the trap and the redirects. On failure `D` is empty and the block writes `/hardening-log.md.region`, outside the scratch dir the paragraph promises. Same class as finding 1 — the no-artifact claim rests on a step that can fail silently. |
| 4 | Minor | **Valid** | §7's stored riders are not what pass 10 actually ran: the append-only rider lists six cases, not the seven including the pre-row state, and carries no match-semantics walk. The section claims to be "verbatim in every pass prompt". |
| 5 | Minor | **Valid, confirmed** | Gate-coverage overclaim class: "nothing detects it" while check 3 rejects duplicate labels once, during this change. |

## Read

Nothing here reopens a settled decision. Three of the five are defects in the *mechanics* of §6's
checks (a stub helper, an unchecked `mktemp`, an overclaim about what a check proves); two are
remnants of the withdrawn uniqueness rule. One genuine open question falls out of finding 2 —
what a **zero-match** locator means — which the match-semantics settlement did not cover.
