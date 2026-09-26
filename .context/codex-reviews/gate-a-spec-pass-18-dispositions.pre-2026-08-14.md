# Gate A — spec — pass 18 dispositions

Artifact: `docs/superpowers/specs/2026-08-05-hardening-ledger-supersession-design.md`
6 findings: 4 Major, 2 Minor. **No Blocker.** All six valid. **None applied.**

Reviewer: `mcp-codex-dev@1.0.1`, `codex-cli 0.144.5`, model `gpt-5.6-sol`. No stray artifact.

Passes 4 → 18: **11, 14, 16, 15, 9, 10, 5, 12, 8, 6, 3, 4, 7, 6, 6.**

## Verified

| # | Claim | Result |
|---|---|---|
| 1 | the narrowed limitation is still too narrow | **Confirmed by construction.** Enumerating every substring of `foo`: **none** fails to also match `foobar`. So two rows with *non-identical* findings can still be inseparable. My narrowing named the wrong condition. |
| 2 | §4's end sentinel is not literal text | **Confirmed.** `:335` quotes `` `…and nothing checks the difference.` `` — with a literal `…` **inside** the code span. The convention text at `:162` has no ellipsis. A check taking the documented sentinel literally can never match. |
| 6 | anchor 15 renders with a trailing space | **Confirmed.** CommonMark strips padding only when the span has **both** a leading and a trailing space. ` ``block above the `Columns:` `` ` renders as `block above the \`Columns:\` ` — trailing space included. |

| # | Sev | Verdict | Note |
|---|---|---|---|
| 1 | Major | **Valid — and my pass-17 fix under-corrected** | The real condition is not "identical in date, fingerprint and `finding`" but "**the target row has no permitted distinguishing fragment**" — which also covers a `finding` that is a substring of its sibling's, and pairs where the only separating text contains a double quote (barred by the no-double-quote rule). Both the limitation and its reopen trigger need generalising. Daniel settled the *shape* (record a limitation, no new syntax); this is that limitation stated correctly, so I read it as inside the settlement rather than reopening it — flagging in case he disagrees. |
| 2 | Major | **Valid, confirmed** | An editorial ellipsis inside a code span that is quoted as literal sentinel text. Present since the sentinel was introduced and missed by every prior sweep, including the ones that checked the sentinel was "unchanged". |
| 3 | Major | **Valid** | Story AC 4 promises a reader can determine *which* claims no longer hold; the design supplies only *recorded* corrections, and §2.1 explicitly leaves a removed hardening unmarkable. The desired outcome was narrowed at pass 5; AC 4 was not brought with it. |
| 4 | Major | **Valid** | Check 1f's named read covers "names the claim that does not hold" and the citation resolving, but not §2.2's other two requirements: saying **which cause** (stopped holding vs never true) and **citing without restating**. An entry violating either passes every stated check. |
| 5 | Minor | **Valid** | §2.1 says the hardening "still stands" and that ejecting the row would misreport class history — but for a wrong-fingerprint or phantom row the lineage **already** misreports it. The design knowingly preserves that; the rationale claims the opposite. |
| 6 | Minor | **Valid, confirmed** | My pass-17 rendering fix was itself subtly wrong. |

## Read

Two of six (1 and 6) are cases where **my fix from the previous pass was subtly wrong** — the
pattern continues, at diminishing severity: pass 17's version of each was closer than pass 16's,
and this one closer still. None of the six is a mechanism defect and none touches §6's oracles;
rider 4 came back empty for the second consecutive pass.

Findings 1, 3 and 5 are all one shape: **a claim about the design that is not exactly true** —
a limitation stated too narrowly, an acceptance criterion promising more than the design delivers,
and a rationale asserting the opposite of a case the design knowingly accepts. That is the class
worth spending passes on, and it is now the only class left.
