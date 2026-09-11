# Gate A — spec — pass 11 dispositions

Artifact: `docs/superpowers/specs/2026-08-05-hardening-ledger-supersession-design.md`
12 findings: 7 Major, 2 Minor, 3 Nit. **No Blocker.** All read as correct. **None applied.**

Reviewer: `mcp-codex-dev@1.0.1`, `codex-cli 0.144.5`, model `gpt-5.6-sol`. Same as passes 4–10.

Passes 4 → 11: **11, 14, 16, 15, 9, 10, 5, 12.**

**Read the rise honestly.** Pass 10 was 5 because the artifact had stopped changing much. Pass 11
is 12 because pass 10's fixes **added new mechanism** — an executable inert-entry assertion and a
new inert semantics — and new mechanism generates new findings. Six of the twelve land on things
that did not exist before this round (findings 1, 3, 4, 5, 10, 11). That is a different curve
from passes 4–7, where each pass found the *previous fix* unsound; here the settled decisions
drew no objection at all.

## Reproduced, not taken on the reviewer's word

| # | Claim | Result |
|---|---|---|
| 3 | the new inert assertion's `rc` is lost to a pipeline subshell | **Reproduced under both `sh` and `dash`.** `grep … \| while … rc=1` runs the loop in a subshell; the fence prints `INERT: 2099-01-01 missing-fp matches no row` and **exits 0**. The assertion detects and does not fail. My prototype test checked the printed output and never the exit status — a check wired to pass, written while building a check against wording-not-mechanism. |
| 11 | `**Cite, do not restate.*` has an unmatched delimiter | **Confirmed**, `:228`. My scripted edit broke it. |

| # | Sev | Verdict | Note |
|---|---|---|---|
| 3 | Major | **Valid, reproduced** | See above. Fix: redirect a guarded temp file into `while` instead of piping, and verify an inert fixture exits nonzero under both shells. |
| 4 | Major | **Valid** | The assertion's `sed` ignores an optional `"<row fragment>"`, so an entry whose pair matches but whose fragment matches no `finding` is inert under §2.2 and passes. |
| 5 | Major | **Valid, and genuinely new** | Matching is defined dynamically, so an **inert entry can activate later** when a row with that locator is appended — a zero-to-nonzero transition neither the settlement nor §8 contemplates. A mistyped entry left as history can silently come to govern an unrelated future row. Needs Daniel: is inertness permanent or current-only? |
| 1 | Major | **Valid** | "an unresolvable locator is a stop" survives in §2.2's rationale — a stop for a state that is now either valid (many) or inert (zero). |
| 2 | Major | **Valid** | §3.1 still explains the omitted fragment by exact-one cardinality and misquotes §2.2 as "already resolves". The worked example teaches the withdrawn procedure. |
| 6 | Major | **Valid** | §8's inventory omits two shared-region decisions — the block sitting above `Columns:`, and the label carrying one appended line per supersession. Fourth pass on this inventory; the rule-plus-list form did not stop it drifting. |
| 7 | Major | **Valid** | `docs/coding-workflow.md:204` uses `entry` for a hardening *row*, while this design reserves `entry` for supersession markers and forbids entries referencing one another. As written it reads as reopening the cut correcting-entry path. My rewrite introduced the collision. |
| 8 | Minor | **Valid** | "Nothing mechanical reads this block" is absolute while checks 1 and 3 grep, parse and position-check it during this change. Enforcement-claim class; the intended claim is about *standing* tooling. |
| 9 | Minor | **Valid** | §4's `todos.md` row does not say what the resolved source row says, which status it lands in, or where the parked item goes — the docs-drift class this repo treats as recurring. |
| 10 | Nit | **Valid** | Anchor numbering off by one: the citation phrase is anchor 20, not 19. |
| 11 | Nit | **Valid, confirmed** | Broken bold, mine. |
| 12 | Nit | **Valid** | The spec attributes the restoration to pass 8, the story to pass 7. Both are defensible (finding pass vs fix pass) and they disagree. |

## Needs Daniel

**Finding 5 only.** Everything else is mechanical or editorial.
