# Gate A — spec — pass 15 dispositions

Artifact: `docs/superpowers/specs/2026-08-05-hardening-ledger-supersession-design.md`
4 findings: 3 Major, 1 Minor. **No Blocker.** All four valid. **None applied.**

Reviewer: `mcp-codex-dev@1.0.1`, `codex-cli 0.144.5`, model `gpt-5.6-sol`. No stray artifact.

Passes 4 → 15: **11, 14, 16, 15, 9, 10, 5, 12, 8, 6, 3, 4.**

## Reproduced

| # | Claim | Result |
|---|---|---|
| 1 | `finding()` mishandles an escaped backslash before a pipe | **Confirmed.** A row whose `finding` ends `…backslash \\` followed by the column pipe extracts as `[ends with backslash \\| next-col-value]` — the delimiter vanishes and the next column is swallowed. |
| 2 | candidate rows are never validated as complete rows | **Confirmed.** A truncated line `\| 2026-07-20 \| tt \|` matches `^\| RD \| FP \|` and counts as a match in the fragmentless branch: `n=1`, want 0. |
| 4 | the precheck story's count contradicts itself | **Confirmed.** `:64` says "Seven — six paired … and one inherited"; `:101` says "the six questions above". |

| # | Sev | Verdict | Note |
|---|---|---|---|
| 1 | Major | **Valid** | The scanner treats *any* backslash before a pipe as escaping it, without checking whether the backslash is itself escaped. Fix: count the parity of the consecutive backslash run and split on a pipe following an even-length run. Narrow in practice — it needs a `finding` ending in a literal backslash — but it is the same shape as the last two rounds, one layer deeper again. |
| 2 | Major | **Valid, and the more consequential of the two** | Nothing requires a candidate to *be* a table row. A truncated or malformed line matching the date+fingerprint prefix satisfies the gate, so an entry can be declared non-inert by a line that is not a row. Fix: assert the full row shape — a minimum count of unescaped delimiters — before counting, in **both** branches. |
| 3 | Major | **Valid** | §8's inventory omits the §2.2 calibration that append-day truth is unverifiable and the check enforces only non-decreasing recorded dates. Delete that from both surfaces and all 33 anchors stay green while a bounded claim becomes an overclaim. **Seventh consecutive pass** on this inventory. |
| 4 | Minor | **Valid, confirmed** | My phantom-hardening edit widened that story's §5 without touching §6's count. |

## Read

No design finding. Nothing touched a settled decision, the convention prose, the governing story's
amendments, or any claim about what the gates prove. Findings 1 and 2 are both inside the one
`finding()`/candidate-matching routine; 3 is the inventory; 4 is a stale numeral.

**On the inventory (finding 3).** Seven passes, seven holes, each a decision that turned out to be
anchorable. The rule-plus-list form did not stop it, and neither did "re-derive it" as an
instruction. The honest options are to stop claiming the list is complete, or to derive it
mechanically — every `**bold**` decision sentence in the shared region that is not a substring of
some anchor. That is a change to what §8 claims, so it goes to Daniel rather than being applied.
