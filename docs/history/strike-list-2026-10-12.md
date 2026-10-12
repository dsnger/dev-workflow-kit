# Strike-list — 2026-10-12 kit shrink

Baseline: `pre-shrink` (`6b15993`). Authority: shrink brief and addendum 1,
Daniel via `dev-workflow-kit-d4`, 2026-10-12 11:35.
The preflight escalation in 42cb193 is resolved; it is preserved in git history.

## Reading this audit

The coverage block partitions every original line of every modified existing source
file exactly once. KEPT ranges are byte-identical line runs; other ranges cover deleted
or replaced original lines. When a whole sentence survives from a partly deleted line,
that original line is counted with the deleted/replaced ranges, and the sentence is
traced separately below. Output-trace rows use `-`, contribute zero to original-line
coverage, and distinguish sentence extraction, COPIED text and NEW text.
Unchanged skill/scaffold content is outside the B1–B10 rules-file keep-list; it is kept.
Blank lines and Markdown headings carry structure, not extra rules.

The workflow-init archive contains only the exact fenced template 2.1a body; coverage
below covers the entire original command, including unaffected templates.
The added one-line archive header is `Archived, non-binding, see the strike-list`.

## Coverage and sizes

| File | Before bytes | After bytes | Original lines | Kept full lines | Deleted/replaced lines | Covered lines |
|---|---:|---:|---:|---:|---:|---:|
| .claude/review-gates.md | 139111 | 5491 | 1665 | 30 | 1635 | 1665 |
| plugins/dev-workflow/commands/workflow-init.md | 232086 | 95756 | 3143 | 1472 | 1671 | 3143 |
| plugins/dev-workflow/skills/harden-finding/SKILL.md | 11921 | 9978 | 193 | 170 | 23 | 193 |
| plugins/dev-workflow/skills/intake/SKILL.md | 32932 | 23504 | 519 | 386 | 133 | 519 |
| AGENTS.md | 23397 | 23368 | 301 | 300 | 1 | 301 |
| CLAUDE.md | 12045 | 11758 | 146 | 144 | 2 | 146 |
| docs/PRD.md | 2988 | 3018 | 43 | 41 | 2 | 43 |
| docs/ARCHITECTURE.md | 10324 | 10421 | 153 | 153 | 0 | 153 |
| plugins/dev-workflow/CHANGELOG.md | 62660 | 63484 | 848 | 848 | 0 | 848 |
| plugins/dev-workflow/.claude-plugin/plugin.json | 490 | 490 | 12 | 11 | 1 | 12 |
| scripts/check-invariants.sh | 57717 | 57720 | 976 | 975 | 1 | 976 |
| scripts/check-invariants.test.sh | 72845 | 72924 | 1284 | 1282 | 2 | 1284 |

## Original-line coverage

```text
.claude/review-gates.md | 1-1 | KEPT B1
.claude/review-gates.md | 2-2 | KEPT B1 (blank separator)
.claude/review-gates.md | 3-4 | This is `CLAUDE.md` §5 in full, moved here unchanged except  | not in keep-list
.claude/review-gates.md | 5-6 | KEPT B1 (blank separator)
.claude/review-gates.md | 7-10 | Independent second opinion at two gates. Easiest steps to sk | not in keep-list
.claude/review-gates.md | 11-11 | KEPT B1 (blank separator)
.claude/review-gates.md | 12-14 | **Both gates are a LOOP with a HARD FLOOR: a minimum number  | not in keep-list
.claude/review-gates.md | 15-15 | The derivation is max(risk, security): a value of 0 gives a  | not in keep-list (contradicts B6)
.claude/review-gates.md | 16-62 | resolvable profile above that, and an artifact citing no sto | not in keep-list
.claude/review-gates.md | 63-63 | KEPT B1 (blank separator)
.claude/review-gates.md | 64-64 | **The derived floor is the pass count a cycle owes, and the  | not in keep-list (contradicts B6)
.claude/review-gates.md | 65-73 | threshold that controls nothing.** The hook still counts pas | not in keep-list
.claude/review-gates.md | 74-74 | KEPT B1 (blank separator)
.claude/review-gates.md | 75-75 | **Named residual:** the hook's messages state its own thresh | not in keep-list
.claude/review-gates.md | 76-76 | floor of 1 they report a shortfall the cycle does not owe. * | not in keep-list (contradicts B6)
.claude/review-gates.md | 77-78 | What makes that tolerable is the precedence rule above plus  | not in keep-list
.claude/review-gates.md | 79-79 | KEPT B1 (blank separator)
.claude/review-gates.md | 80-81 | **The gate-off surface — routes known today, not a complete  | not in keep-list
.claude/review-gates.md | 82-82 | the cited set does not license, which could not exist before | not in keep-list (contradicts B6)
.claude/review-gates.md | 83-110 | state. Pre-existing and unchanged: omitting a higher-risk ci | not in keep-list
.claude/review-gates.md | 111-111 | cycle a floor of 1 and skip passes on the strength of not kn | not in keep-list (contradicts B6)
.claude/review-gates.md | 112-133 | knob set above 3 is not lowered by this fallback. A revert i | not in keep-list
.claude/review-gates.md | 134-134 | derived floor with no predicate to define it; **no definitio | not in keep-list (contradicts B6)
.claude/review-gates.md | 135-152 | at once**. A | not in keep-list
.claude/review-gates.md | 153-153 | **those duties bind both gates alike**: the derived floor an | not in keep-list (contradicts B6)
.claude/review-gates.md | 154-179 | their definitions at their own sources and are read here for | not in keep-list
.claude/review-gates.md | 180-180 | repeated here. Beyond the findings, closure reads the **deri | not in keep-list (contradicts B6)
.claude/review-gates.md | 181-257 | standing over this cycle**, any **hold still standing**, and | not in keep-list
.claude/review-gates.md | 258-258 | **Eligibility is exactly this and nothing more: a clean pass | not in keep-list (contradicts B6)
.claude/review-gates.md | 259-326 | zero-finding pass.** It is a property of the pass. **Closure | not in keep-list
.claude/review-gates.md | 327-327 | passes has reached its cap: the derived floor plus two until | not in keep-list (contradicts B6)
.claude/review-gates.md | 328-330 | from then on the count at the latest answer plus the further | not in keep-list
.claude/review-gates.md | 331-331 | KEPT B6
.claude/review-gates.md | 332-332 | passes it allows, at least one, and resumes the loop on the  | not in keep-list
.claude/review-gates.md | 333-333 | never closes the cycle, credits a pass, skips one or lowers  | not in keep-list (contradicts B7)
.claude/review-gates.md | 334-360 | derived, neither can the cap, and the cycle stops as that de | not in keep-list
.claude/review-gates.md | 361-361 | **The four standing duties, classified.** The **derived floo | not in keep-list (contradicts B6)
.claude/review-gates.md | 362-633 | it gates closing, discharged by the count of valid logical p | not in keep-list
.claude/review-gates.md | 634-634 | derived floor, the risk and security values read, and the ci | not in keep-list (contradicts B6)
.claude/review-gates.md | 635-712 | from. A report giving the number alone leaves a reader unabl | not in keep-list
.claude/review-gates.md | 713-720 | KEPT B4
.claude/review-gates.md | 721-724 | > | not in keep-list
.claude/review-gates.md | 725-725 | KEPT B1 (blank separator)
.claude/review-gates.md | 726-726 | **Gate B takes one file per branch.** Under the default call | not in keep-list
.claude/review-gates.md | 727-727 | KEPT B1 (blank separator)
.claude/review-gates.md | 728-735 | **Before each call, delete every target file and confirm it  | not in keep-list
.claude/review-gates.md | 736-736 | KEPT B1 (blank separator)
.claude/review-gates.md | 737-740 | **Companions of a findings file, from field practice.** Two  | not in keep-list
.claude/review-gates.md | 741-741 | KEPT B1 (blank separator)
.claude/review-gates.md | 742-749 | - `<slot>-dispositions.md` — **owed for every slot of a vali | not in keep-list
.claude/review-gates.md | 750-750 |   Every slot of a validated pass that holds a finding owes a | not in keep-list (contradicts B5)
.claude/review-gates.md | 751-753 |  | not in keep-list
.claude/review-gates.md | 754-754 |   slot's finding line numbers, 1 to k, each once. `same as < | not in keep-list (contradicts B5)
.claude/review-gates.md | 755-755 |   of a slot **of the same cycle** reporting **the same occur | not in keep-list
.claude/review-gates.md | 756-756 |   place, fixed by the same repair. A finding this cycle **de | not in keep-list (contradicts B5)
.claude/review-gates.md | 757-961 |   another finding's repair did to the same text: a decline b | not in keep-list
.claude/review-gates.md | 962-962 | - **Gate A — Spec, then plan (TWO runs, each its own loop at | not in keep-list (contradicts B6)
.claude/review-gates.md | 963-1363 |   **spec** right after brainstorming (before `writing-plans` | not in keep-list
.claude/review-gates.md | 1364-1364 | KEPT B5
.claude/review-gates.md | 1365-1374 |                                             a path containin | not in keep-list
.claude/review-gates.md | 1375-1375 |   ship, `none (pre-rule)` only for one that began before the | not in keep-list (contradicts B6)
.claude/review-gates.md | 1376-1522 |   cited set that produced it**, each member with its level a | not in keep-list
.claude/review-gates.md | 1523-1524 | KEPT B7
.claude/review-gates.md | 1525-1535 |  | not in keep-list
.claude/review-gates.md | 1536-1536 | KEPT B7
.claude/review-gates.md | 1537-1567 |  | not in keep-list
.claude/review-gates.md | 1568-1570 | KEPT B7
.claude/review-gates.md | 1571-1571 | KEPT B1 (blank separator)
.claude/review-gates.md | 1572-1586 |   `<RUNG>` is one of `1`, `2`, `3`, `4`, `P`; `<REF>` is the | not in keep-list
.claude/review-gates.md | 1587-1587 | KEPT B1 (blank separator)
.claude/review-gates.md | 1588-1665 |   **What the ledger check is worth.** An author-written reco | not in keep-list
plugins/dev-workflow/commands/workflow-init.md | 1-462 | KEPT outside rule keep-list / unchanged scaffold, skill, invariant, metadata or documentation
plugins/dev-workflow/commands/workflow-init.md | 463-463 | The work loop includes the review gates: **spec ready → Gate | not in keep-list (contradicts B1)
plugins/dev-workflow/commands/workflow-init.md | 464-464 |  | not in keep-list
plugins/dev-workflow/commands/workflow-init.md | 465-489 | KEPT outside rule keep-list / unchanged scaffold, skill, invariant, metadata or documentation
plugins/dev-workflow/commands/workflow-init.md | 490-493 | **It is longer than one read returns.** Read it in parts, ea | not in keep-list
plugins/dev-workflow/commands/workflow-init.md | 494-514 | KEPT outside rule keep-list / unchanged scaffold, skill, invariant, metadata or documentation
plugins/dev-workflow/commands/workflow-init.md | 515-517 | targets" (in 2.1) says. Why a separate file: inline, these r | not in keep-list
plugins/dev-workflow/commands/workflow-init.md | 518-519 | KEPT outside rule keep-list / unchanged scaffold, skill, invariant, metadata or documentation
plugins/dev-workflow/commands/workflow-init.md | 520-530 |  | not in keep-list
plugins/dev-workflow/commands/workflow-init.md | 531-536 | KEPT outside rule keep-list / unchanged scaffold, skill, invariant, metadata or documentation
plugins/dev-workflow/commands/workflow-init.md | 537-537 | KEPT B1
plugins/dev-workflow/commands/workflow-init.md | 538-538 | KEPT B1 (blank separator)
plugins/dev-workflow/commands/workflow-init.md | 539-540 | This is `CLAUDE.md` §5 in full, moved here unchanged except  | not in keep-list
plugins/dev-workflow/commands/workflow-init.md | 541-541 | KEPT B1 (blank separator)
plugins/dev-workflow/commands/workflow-init.md | 542-553 | Independent second opinion at two gates. Easiest steps to sk | not in keep-list
plugins/dev-workflow/commands/workflow-init.md | 554-554 | KEPT B1 (blank separator)
plugins/dev-workflow/commands/workflow-init.md | 555-557 | **Both gates are a LOOP with a HARD FLOOR: a minimum number  | not in keep-list
plugins/dev-workflow/commands/workflow-init.md | 558-558 | The derivation is max(risk, security): a value of 0 gives a  | not in keep-list (contradicts B6)
plugins/dev-workflow/commands/workflow-init.md | 559-605 | resolvable profile above that, and an artifact citing no sto | not in keep-list
plugins/dev-workflow/commands/workflow-init.md | 606-606 | KEPT B1 (blank separator)
plugins/dev-workflow/commands/workflow-init.md | 607-607 | **The derived floor is the pass count a cycle owes, and the  | not in keep-list (contradicts B6)
plugins/dev-workflow/commands/workflow-init.md | 608-616 | threshold that controls nothing.** The hook still counts pas | not in keep-list
plugins/dev-workflow/commands/workflow-init.md | 617-617 | KEPT B1 (blank separator)
plugins/dev-workflow/commands/workflow-init.md | 618-618 | **Named residual:** the hook's messages state its own thresh | not in keep-list
plugins/dev-workflow/commands/workflow-init.md | 619-619 | floor of 1 they report a shortfall the cycle does not owe. * | not in keep-list (contradicts B6)
plugins/dev-workflow/commands/workflow-init.md | 620-621 | What makes that tolerable is the precedence rule above plus  | not in keep-list
plugins/dev-workflow/commands/workflow-init.md | 622-622 | KEPT B1 (blank separator)
plugins/dev-workflow/commands/workflow-init.md | 623-624 | **The gate-off surface — routes known today, not a complete  | not in keep-list
plugins/dev-workflow/commands/workflow-init.md | 625-625 | the cited set does not license, which could not exist before | not in keep-list (contradicts B6)
plugins/dev-workflow/commands/workflow-init.md | 626-631 | state. Pre-existing and unchanged: omitting a higher-risk ci | not in keep-list
plugins/dev-workflow/commands/workflow-init.md | 632-632 | KEPT B1 (blank separator)
plugins/dev-workflow/commands/workflow-init.md | 633-653 | **When these rules bind.** From the commit that ships them,  | not in keep-list
plugins/dev-workflow/commands/workflow-init.md | 654-654 | cycle a floor of 1 and skip passes on the strength of not kn | not in keep-list (contradicts B6)
plugins/dev-workflow/commands/workflow-init.md | 655-676 | knob set above 3 is not lowered by this fallback. A revert i | not in keep-list
plugins/dev-workflow/commands/workflow-init.md | 677-677 | derived floor with no predicate to define it; **no definitio | not in keep-list (contradicts B6)
plugins/dev-workflow/commands/workflow-init.md | 678-695 | at once**. A | not in keep-list
plugins/dev-workflow/commands/workflow-init.md | 696-696 | **those duties bind both gates alike**: the derived floor an | not in keep-list (contradicts B6)
plugins/dev-workflow/commands/workflow-init.md | 697-722 | their definitions at their own sources and are read here for | not in keep-list
plugins/dev-workflow/commands/workflow-init.md | 723-723 | repeated here. Beyond the findings, closure reads the **deri | not in keep-list (contradicts B6)
plugins/dev-workflow/commands/workflow-init.md | 724-800 | standing over this cycle**, any **hold still standing**, and | not in keep-list
plugins/dev-workflow/commands/workflow-init.md | 801-801 | **Eligibility is exactly this and nothing more: a clean pass | not in keep-list (contradicts B6)
plugins/dev-workflow/commands/workflow-init.md | 802-890 | zero-finding pass.** It is a property of the pass. **Closure | not in keep-list
plugins/dev-workflow/commands/workflow-init.md | 891-891 | **The four standing duties, classified.** The **derived floo | not in keep-list (contradicts B6)
plugins/dev-workflow/commands/workflow-init.md | 892-1160 | it gates closing, discharged by the count of valid logical p | not in keep-list
plugins/dev-workflow/commands/workflow-init.md | 1161-1161 | derived floor, the risk and security values read, and the ci | not in keep-list (contradicts B6)
plugins/dev-workflow/commands/workflow-init.md | 1162-1230 | from. A report giving the number alone leaves a reader unabl | not in keep-list
plugins/dev-workflow/commands/workflow-init.md | 1231-1238 | KEPT B4
plugins/dev-workflow/commands/workflow-init.md | 1239-1242 | > | not in keep-list
plugins/dev-workflow/commands/workflow-init.md | 1243-1243 | KEPT B1 (blank separator)
plugins/dev-workflow/commands/workflow-init.md | 1244-1244 | **Gate B takes one file per branch.** Under the default call | not in keep-list
plugins/dev-workflow/commands/workflow-init.md | 1245-1245 | KEPT B1 (blank separator)
plugins/dev-workflow/commands/workflow-init.md | 1246-1253 | **Before each call, delete every target file and confirm it  | not in keep-list
plugins/dev-workflow/commands/workflow-init.md | 1254-1254 | KEPT B1 (blank separator)
plugins/dev-workflow/commands/workflow-init.md | 1255-1258 | **Companions of a findings file, from field practice.** Two  | not in keep-list
plugins/dev-workflow/commands/workflow-init.md | 1259-1259 | KEPT B1 (blank separator)
plugins/dev-workflow/commands/workflow-init.md | 1260-1267 | - `<slot>-dispositions.md` — **owed for every slot of a vali | not in keep-list
plugins/dev-workflow/commands/workflow-init.md | 1268-1268 |   Every slot of a validated pass that holds a finding owes a | not in keep-list (contradicts B5)
plugins/dev-workflow/commands/workflow-init.md | 1269-1271 |  | not in keep-list
plugins/dev-workflow/commands/workflow-init.md | 1272-1272 |   slot's finding line numbers, 1 to k, each once. `same as < | not in keep-list (contradicts B5)
plugins/dev-workflow/commands/workflow-init.md | 1273-1273 |   of a slot **of the same cycle** reporting **the same occur | not in keep-list
plugins/dev-workflow/commands/workflow-init.md | 1274-1274 |   place, fixed by the same repair. A finding this cycle **de | not in keep-list (contradicts B5)
plugins/dev-workflow/commands/workflow-init.md | 1275-1475 |   another finding's repair did to the same text: a decline b | not in keep-list
plugins/dev-workflow/commands/workflow-init.md | 1476-1476 | - **Gate A — Spec, then plan (TWO runs, each its own loop at | not in keep-list (contradicts B6)
plugins/dev-workflow/commands/workflow-init.md | 1477-1847 |   **spec** right after brainstorming (before `writing-plans` | not in keep-list
plugins/dev-workflow/commands/workflow-init.md | 1848-1848 | KEPT B5
plugins/dev-workflow/commands/workflow-init.md | 1849-1858 |                                             a path containin | not in keep-list
plugins/dev-workflow/commands/workflow-init.md | 1859-1859 |   ship, `none (pre-rule)` only for one that began before the | not in keep-list (contradicts B6)
plugins/dev-workflow/commands/workflow-init.md | 1860-2006 |   cited set that produced it**, each member with its level a | not in keep-list
plugins/dev-workflow/commands/workflow-init.md | 2007-2008 | KEPT B7
plugins/dev-workflow/commands/workflow-init.md | 2009-2019 |  | not in keep-list
plugins/dev-workflow/commands/workflow-init.md | 2020-2020 | KEPT B7
plugins/dev-workflow/commands/workflow-init.md | 2021-2051 |  | not in keep-list
plugins/dev-workflow/commands/workflow-init.md | 2052-2054 | KEPT B7
plugins/dev-workflow/commands/workflow-init.md | 2055-2055 | KEPT B1 (blank separator)
plugins/dev-workflow/commands/workflow-init.md | 2056-2070 |   `<RUNG>` is one of `1`, `2`, `3`, `4`, `P`; `<REF>` is the | not in keep-list
plugins/dev-workflow/commands/workflow-init.md | 2071-2071 | KEPT B1 (blank separator)
plugins/dev-workflow/commands/workflow-init.md | 2072-2149 |   **What the ledger check is worth.** An author-written reco | not in keep-list
plugins/dev-workflow/commands/workflow-init.md | 2150-2165 | KEPT outside rule keep-list / unchanged scaffold, skill, invariant, metadata or documentation
plugins/dev-workflow/commands/workflow-init.md | 2166-2232 |  | not in keep-list
plugins/dev-workflow/commands/workflow-init.md | 2233-3143 | KEPT outside rule keep-list / unchanged scaffold, skill, invariant, metadata or documentation
plugins/dev-workflow/skills/harden-finding/SKILL.md | 1-2 | KEPT outside rule keep-list / unchanged scaffold, skill, invariant, metadata or documentation
plugins/dev-workflow/skills/harden-finding/SKILL.md | 3-3 | description: Use when a review finding (Codex Gate A/B, a PR | not in keep-list
plugins/dev-workflow/skills/harden-finding/SKILL.md | 4-9 | KEPT outside rule keep-list / unchanged scaffold, skill, invariant, metadata or documentation
plugins/dev-workflow/skills/harden-finding/SKILL.md | 10-11 | A review finding is only *closed* when the most deterministi | not in keep-list
plugins/dev-workflow/skills/harden-finding/SKILL.md | 12-45 | KEPT outside rule keep-list / unchanged scaffold, skill, invariant, metadata or documentation
plugins/dev-workflow/skills/harden-finding/SKILL.md | 46-46 | \| 1 · prose \| a convention/judgment call no tool can adjudic | not in keep-list
plugins/dev-workflow/skills/harden-finding/SKILL.md | 47-47 | KEPT outside rule keep-list / unchanged scaffold, skill, invariant, metadata or documentation
plugins/dev-workflow/skills/harden-finding/SKILL.md | 48-48 | \| 3 · type \| expressible in the type system \| the project's  | not in keep-list
plugins/dev-workflow/skills/harden-finding/SKILL.md | 49-49 | KEPT outside rule keep-list / unchanged scaffold, skill, invariant, metadata or documentation
plugins/dev-workflow/skills/harden-finding/SKILL.md | 50-50 | \| P · prompt-standard \| the finding is in a prompt artifact  | not in keep-list
plugins/dev-workflow/skills/harden-finding/SKILL.md | 51-54 | KEPT outside rule keep-list / unchanged scaffold, skill, invariant, metadata or documentation
plugins/dev-workflow/skills/harden-finding/SKILL.md | 55-63 | - Prefer the strongest deterministic rung that fits: a secur | not in keep-list
plugins/dev-workflow/skills/harden-finding/SKILL.md | 64-79 | KEPT outside rule keep-list / unchanged scaffold, skill, invariant, metadata or documentation
plugins/dev-workflow/skills/harden-finding/SKILL.md | 80-81 |    - latest matching row is a real rung (1–4/P) → the prior  | not in keep-list
plugins/dev-workflow/skills/harden-finding/SKILL.md | 82-156 | KEPT outside rule keep-list / unchanged scaffold, skill, invariant, metadata or documentation
plugins/dev-workflow/skills/harden-finding/SKILL.md | 157-161 | escaping. You supply: the canonical `fingerprint`, a short o | not in keep-list
plugins/dev-workflow/skills/harden-finding/SKILL.md | 162-187 | KEPT outside rule keep-list / unchanged scaffold, skill, invariant, metadata or documentation
plugins/dev-workflow/skills/harden-finding/SKILL.md | 188-188 | - Filing an auth/ACL finding as prose when a lint/type/test  | not in keep-list
plugins/dev-workflow/skills/harden-finding/SKILL.md | 189-193 | KEPT outside rule keep-list / unchanged scaffold, skill, invariant, metadata or documentation
plugins/dev-workflow/skills/intake/SKILL.md | 1-306 | KEPT outside rule keep-list / unchanged scaffold, skill, invariant, metadata or documentation
plugins/dev-workflow/skills/intake/SKILL.md | 307-344 | A second route, separate from the Flow. Use it when an appro | not in keep-list
plugins/dev-workflow/skills/intake/SKILL.md | 345-345 | KEPT outside rule keep-list / unchanged scaffold, skill, invariant, metadata or documentation
plugins/dev-workflow/skills/intake/SKILL.md | 346-351 |    condition, or per run of criteria sharing a fate). Then c | not in keep-list
plugins/dev-workflow/skills/intake/SKILL.md | 352-352 | KEPT outside rule keep-list / unchanged scaffold, skill, invariant, metadata or documentation
plugins/dev-workflow/skills/intake/SKILL.md | 353-395 |    in the row; a fate with no passage to quote is not a fate | not in keep-list
plugins/dev-workflow/skills/intake/SKILL.md | 396-420 | KEPT outside rule keep-list / unchanged scaffold, skill, invariant, metadata or documentation
plugins/dev-workflow/skills/intake/SKILL.md | 421-463 | **Added without an earlier condition — the rules.** This fie | not in keep-list
plugins/dev-workflow/skills/intake/SKILL.md | 464-464 | KEPT outside rule keep-list / unchanged scaffold, skill, invariant, metadata or documentation
plugins/dev-workflow/skills/intake/SKILL.md | 465-467 |  | not in keep-list
plugins/dev-workflow/skills/intake/SKILL.md | 468-519 | KEPT outside rule keep-list / unchanged scaffold, skill, invariant, metadata or documentation
AGENTS.md | 1-12 | KEPT outside rule keep-list / unchanged scaffold, skill, invariant, metadata or documentation
AGENTS.md | 13-13 | recurring finding escalates one rung harder (prose → lint →  | describing-sentence update / release entry authorized by brief
AGENTS.md | 14-301 | KEPT outside rule keep-list / unchanged scaffold, skill, invariant, metadata or documentation
CLAUDE.md | 1-82 | KEPT outside rule keep-list / unchanged scaffold, skill, invariant, metadata or documentation
CLAUDE.md | 83-84 | The work loop includes the review gates: **spec ready → Gate | not in keep-list
CLAUDE.md | 85-146 | KEPT outside rule keep-list / unchanged scaffold, skill, invariant, metadata or documentation
docs/PRD.md | 1-24 | KEPT outside rule keep-list / unchanged scaffold, skill, invariant, metadata or documentation
docs/PRD.md | 25-25 | \| Review-loop pass curves per cycle \| `python3 -B scripts/lo | describing-sentence update / release entry authorized by brief
docs/PRD.md | 26-37 | KEPT outside rule keep-list / unchanged scaffold, skill, invariant, metadata or documentation
docs/PRD.md | 38-38 | \| Review gates (Gate A on spec and plan, Gate B on the diff) | describing-sentence update / release entry authorized by brief
docs/PRD.md | 39-43 | KEPT outside rule keep-list / unchanged scaffold, skill, invariant, metadata or documentation
docs/ARCHITECTURE.md | 1-153 | KEPT outside rule keep-list / unchanged scaffold, skill, invariant, metadata or documentation
plugins/dev-workflow/CHANGELOG.md | 1-848 | KEPT outside rule keep-list / unchanged scaffold, skill, invariant, metadata or documentation
plugins/dev-workflow/.claude-plugin/plugin.json | 1-3 | KEPT outside rule keep-list / unchanged scaffold, skill, invariant, metadata or documentation
plugins/dev-workflow/.claude-plugin/plugin.json | 4-4 |   "version": "0.23.0", | minor version bump required by invariant 12
plugins/dev-workflow/.claude-plugin/plugin.json | 5-12 | KEPT outside rule keep-list / unchanged scaffold, skill, invariant, metadata or documentation
scripts/check-invariants.sh | 1-896 | KEPT outside rule keep-list / unchanged scaffold, skill, invariant, metadata or documentation
scripts/check-invariants.sh | 897-897 | LR_REQ='Every slot of a validated pass that holds a finding  | CHECK: replace old dispositions vocabulary (contradicts B5); keep seven record forms
scripts/check-invariants.sh | 898-976 | KEPT outside rule keep-list / unchanged scaffold, skill, invariant, metadata or documentation
scripts/check-invariants.test.sh | 1-34 | KEPT outside rule keep-list / unchanged scaffold, skill, invariant, metadata or documentation
scripts/check-invariants.test.sh | 35-35 | LR_LINES='Every slot of a validated pass that holds a findin | CHECK: replace old dispositions vocabulary (contradicts B5); keep seven record forms
scripts/check-invariants.test.sh | 36-453 | KEPT outside rule keep-list / unchanged scaffold, skill, invariant, metadata or documentation
scripts/check-invariants.test.sh | 454-454 | #              (measured 2026-10-10, when 4h was added). The | CHECK: replace old dispositions vocabulary (contradicts B5); keep seven record forms
scripts/check-invariants.test.sh | 455-1284 | KEPT outside rule keep-list / unchanged scaffold, skill, invariant, metadata or documentation
```

## Rule output trace

```text
.claude/review-gates.md | - | output rule line 1: # Cross-Model Review (Codex) — TWO MANDATORY GATES | KEPT B1 sentence/line from .claude/review-gates.md:1
.claude/review-gates.md | - | output rule line 3: Gate A reviews every spec with `mcp__codex__exec`; a plan ge | NEW B1
.claude/review-gates.md | - | output rule line 4: Gate B reviews every code diff with `mcp__codex__review` aft | NEW B1
.claude/review-gates.md | - | output rule line 5: Docs-only means every staged path is explanatory Markdown un | NEW B1
.claude/review-gates.md | - | output rule line 7: Before Gate A, obtain human confirmation of one profile line | NEW B8
.claude/review-gates.md | - | output rule line 8: Evidence modes: `battery`, `battery+check`, or `battery+chec | NEW B8
.claude/review-gates.md | - | output rule line 10: ## Gate-A prompt | NEW B2
.claude/review-gates.md | - | output rule line 12: Use the superpowers:brainstorming skill to review this spec. | NEW B2
.claude/review-gates.md | - | output rule line 13: Check the supplied intent and artifact against settled decis | NEW B2
.claude/review-gates.md | - | output rule line 14: For a high-risk plan, review whether decisions, dependencies | NEW B2
.claude/review-gates.md | - | output rule line 15: Report every finding with severity and confidence to this pa | NEW B2
.claude/review-gates.md | - | output rule line 17: ## Gate-B prompt | NEW B3
.claude/review-gates.md | - | output rule line 19: Tool: `mcp__codex__review`. **Default call shape: two sequen | KEPT B3 sentences from .claude/review-gates.md:1007-1008; sentence extraction, no rewording
.claude/review-gates.md | - | output rule line 20: For the spec branch: compare the diff with the supplied appr | NEW B3
.claude/review-gates.md | - | output rule line 21: For the quality branch: compare the diff with AGENTS.md and  | NEW B3
.claude/review-gates.md | - | output rule line 23: > One finding per line, in the format | KEPT B4 sentence/line from .claude/review-gates.md:713
.claude/review-gates.md | - | output rule line 24: > `SEVERITY \| confidence \| location \| problem \| consequence  | KEPT B4 sentence/line from .claude/review-gates.md:714
.claude/review-gates.md | - | output rule line 25: > `\\|`. | KEPT B4 sentence/line from .claude/review-gates.md:715
.claude/review-gates.md | - | output rule line 26: > Severity is one of exactly: BLOCKER \| MAJOR \| MINOR \| NIT  | KEPT B4 sentence/line from .claude/review-gates.md:716
.claude/review-gates.md | - | output rule line 27: > Every line before the terminator is exactly one finding li | KEPT B4 sentence/line from .claude/review-gates.md:717
.claude/review-gates.md | - | output rule line 28: > headings, prose or wrapped continuations. End the file wit | KEPT B4 sentence/line from .claude/review-gates.md:718
.claude/review-gates.md | - | output rule line 29: > exactly `END OF FINDINGS (<n> total)`, `<n>` being the num | KEPT B4 sentence/line from .claude/review-gates.md:719
.claude/review-gates.md | - | output rule line 30: > A **clean findings file** is the single body line `NO FIND | KEPT B4 sentence/line from .claude/review-gates.md:720
.claude/review-gates.md | - | output rule line 32: Choose a fresh cycle nonce of 8–16 lowercase letters or digi | NEW B5
.claude/review-gates.md | - | output rule line 33: For the provenance line, write a story set as `{docs/story.m | NEW B5
.claude/review-gates.md | - | output rule line 34:   <quoted>    := a double-quoted string, non-empty, whose on | KEPT B5 sentence/line from .claude/review-gates.md:1364
.claude/review-gates.md | - | output rule line 36: The floor is 3 valid passes; repair Blockers/Majors and reru | NEW B6
.claude/review-gates.md | - | output rule line 37: Collect Minors and Nits; never iterate on them. | NEW B6
.claude/review-gates.md | - | output rule line 38: Stop before a further pass at cap = floor + 2, or at the cou | NEW B6
.claude/review-gates.md | - | output rule line 39: It asks the user to choose — delete the mechanism the | KEPT B6 sentence/line from .claude/review-gates.md:330
.claude/review-gates.md | - | output rule line 40: findings keep returning to, cut scope, or continue — and eve | KEPT B6 sentence/line from .claude/review-gates.md:331
.claude/review-gates.md | - | output rule line 41: passes it allows, at least one, and resumes the loop on the  | KEPT B6 sentence/line from .claude/review-gates.md:332
.claude/review-gates.md | - | output rule line 43: ## Closing act | NEW B7
.claude/review-gates.md | - | output rule line 45: A cap answer may instead be `close`; then, as for a clean pa | NEW B7
.claude/review-gates.md | - | output rule line 46: cycle <NONCE>; floor 3 per <story paths with levels, or none | NEW B7
.claude/review-gates.md | - | output rule line 47: cycle <NONCE>; <Gate-A spec\|Gate-A plan\|Gate B> (passes <asc | NEW B7
.claude/review-gates.md | - | output rule line 48: Every slot of a validated pass that holds a finding owes a d | NEW B5
.claude/review-gates.md | - | output rule line 49:   cycle <NONCE>; ledger check: fixed <N>, hardening owed <M> | KEPT B7 sentence/line from .claude/review-gates.md:1523
.claude/review-gates.md | - | output rule line 50:   cycle <NONCE>; hardening owed <SLOT>:<n> — <SEVERITY> — <C | KEPT B7 sentence/line from .claude/review-gates.md:1524
.claude/review-gates.md | - | output rule line 51:   cycle <NONCE>; hardening <SLOT>:<n>: rung <RUNG> | KEPT B7 sentence/line from .claude/review-gates.md:1568
.claude/review-gates.md | - | output rule line 52:   cycle <NONCE>; hardening <SLOT>:<n>: pending <REF> | KEPT B7 sentence/line from .claude/review-gates.md:1569
.claude/review-gates.md | - | output rule line 53:   cycle <NONCE>; hardening <SLOT>:<n>: rung 0 — <CHECK> | KEPT B7 sentence/line from .claude/review-gates.md:1570
.claude/review-gates.md | - | output rule line 54:   A `<TARGET>` containing ` — ` or a double quote is written | KEPT B7 sentence/line from .claude/review-gates.md:1536
.claude/review-gates.md | - | output rule line 56: To resume, read the cycle nonce and latest pass file and con | NEW B9
.claude/review-gates.md | - | output rule line 58: Classify a finding as MAJOR only for realistic inputs. | NEW B10
.claude/review-gates.md | - | output rule line 59: When a finding class regenerates across passes, shrink the m | NEW B10
plugins/dev-workflow/commands/workflow-init.md | - | output rule line 1: # Cross-Model Review (Codex) — TWO MANDATORY GATES | KEPT B1 sentence/line from plugins/dev-workflow/commands/workflow-init.md:537
plugins/dev-workflow/commands/workflow-init.md | - | output rule line 3: Gate A reviews every spec with `mcp__codex__exec`; a plan ge | NEW B1
plugins/dev-workflow/commands/workflow-init.md | - | output rule line 4: Gate B reviews every code diff with `mcp__codex__review` aft | NEW B1
plugins/dev-workflow/commands/workflow-init.md | - | output rule line 5: Docs-only means every staged path is explanatory Markdown un | NEW B1
plugins/dev-workflow/commands/workflow-init.md | - | output rule line 7: Before Gate A, obtain human confirmation of one profile line | NEW B8
plugins/dev-workflow/commands/workflow-init.md | - | output rule line 8: Evidence modes: `battery`, `battery+check`, or `battery+chec | NEW B8
plugins/dev-workflow/commands/workflow-init.md | - | output rule line 10: ## Gate-A prompt | NEW B2
plugins/dev-workflow/commands/workflow-init.md | - | output rule line 12: Use the superpowers:brainstorming skill to review this spec. | NEW B2
plugins/dev-workflow/commands/workflow-init.md | - | output rule line 13: Check the supplied intent and artifact against settled decis | NEW B2
plugins/dev-workflow/commands/workflow-init.md | - | output rule line 14: For a high-risk plan, review whether decisions, dependencies | NEW B2
plugins/dev-workflow/commands/workflow-init.md | - | output rule line 15: Report every finding with severity and confidence to this pa | NEW B2
plugins/dev-workflow/commands/workflow-init.md | - | output rule line 17: ## Gate-B prompt | NEW B3
plugins/dev-workflow/commands/workflow-init.md | - | output rule line 19: Tool: `mcp__codex__review`. **Default call shape: two sequen | KEPT B3 sentences from .claude/review-gates.md:1007-1008; sentence extraction, no rewording
plugins/dev-workflow/commands/workflow-init.md | - | output rule line 20: For the spec branch: compare the diff with the supplied appr | NEW B3
plugins/dev-workflow/commands/workflow-init.md | - | output rule line 21: For the quality branch: compare the diff with AGENTS.md and  | NEW B3
plugins/dev-workflow/commands/workflow-init.md | - | output rule line 23: > One finding per line, in the format | KEPT B4 sentence/line from plugins/dev-workflow/commands/workflow-init.md:1231
plugins/dev-workflow/commands/workflow-init.md | - | output rule line 24: > `SEVERITY \| confidence \| location \| problem \| consequence  | KEPT B4 sentence/line from plugins/dev-workflow/commands/workflow-init.md:1232
plugins/dev-workflow/commands/workflow-init.md | - | output rule line 25: > `\\|`. | KEPT B4 sentence/line from plugins/dev-workflow/commands/workflow-init.md:1233
plugins/dev-workflow/commands/workflow-init.md | - | output rule line 26: > Severity is one of exactly: BLOCKER \| MAJOR \| MINOR \| NIT  | KEPT B4 sentence/line from plugins/dev-workflow/commands/workflow-init.md:1234
plugins/dev-workflow/commands/workflow-init.md | - | output rule line 27: > Every line before the terminator is exactly one finding li | KEPT B4 sentence/line from plugins/dev-workflow/commands/workflow-init.md:1235
plugins/dev-workflow/commands/workflow-init.md | - | output rule line 28: > headings, prose or wrapped continuations. End the file wit | KEPT B4 sentence/line from plugins/dev-workflow/commands/workflow-init.md:1236
plugins/dev-workflow/commands/workflow-init.md | - | output rule line 29: > exactly `END OF FINDINGS (<n> total)`, `<n>` being the num | KEPT B4 sentence/line from plugins/dev-workflow/commands/workflow-init.md:1237
plugins/dev-workflow/commands/workflow-init.md | - | output rule line 30: > A **clean findings file** is the single body line `NO FIND | KEPT B4 sentence/line from plugins/dev-workflow/commands/workflow-init.md:1238
plugins/dev-workflow/commands/workflow-init.md | - | output rule line 32: Choose a fresh cycle nonce of 8–16 lowercase letters or digi | NEW B5
plugins/dev-workflow/commands/workflow-init.md | - | output rule line 33: For the provenance line, write a story set as `{docs/story.m | NEW B5
plugins/dev-workflow/commands/workflow-init.md | - | output rule line 34:   <quoted>    := a double-quoted string, non-empty, whose on | KEPT B5 sentence/line from plugins/dev-workflow/commands/workflow-init.md:1848
plugins/dev-workflow/commands/workflow-init.md | - | output rule line 36: The floor is 3 valid passes; repair Blockers/Majors and reru | NEW B6
plugins/dev-workflow/commands/workflow-init.md | - | output rule line 37: Collect Minors and Nits; never iterate on them. | NEW B6
plugins/dev-workflow/commands/workflow-init.md | - | output rule line 38: Stop before a further pass at cap = floor + 2, or at the cou | NEW B6
plugins/dev-workflow/commands/workflow-init.md | - | output rule line 39: It asks the user to choose — delete the mechanism the | COPIED B6 from .claude/review-gates.md:330
plugins/dev-workflow/commands/workflow-init.md | - | output rule line 40: findings keep returning to, cut scope, or continue — and eve | COPIED B6 from .claude/review-gates.md:331
plugins/dev-workflow/commands/workflow-init.md | - | output rule line 41: passes it allows, at least one, and resumes the loop on the  | COPIED B6 from .claude/review-gates.md:332
plugins/dev-workflow/commands/workflow-init.md | - | output rule line 43: ## Closing act | NEW B7
plugins/dev-workflow/commands/workflow-init.md | - | output rule line 45: A cap answer may instead be `close`; then, as for a clean pa | NEW B7
plugins/dev-workflow/commands/workflow-init.md | - | output rule line 46: cycle <NONCE>; floor 3 per <story paths with levels, or none | NEW B7
plugins/dev-workflow/commands/workflow-init.md | - | output rule line 47: cycle <NONCE>; <Gate-A spec\|Gate-A plan\|Gate B> (passes <asc | NEW B7
plugins/dev-workflow/commands/workflow-init.md | - | output rule line 48: Every slot of a validated pass that holds a finding owes a d | NEW B5
plugins/dev-workflow/commands/workflow-init.md | - | output rule line 49:   cycle <NONCE>; ledger check: fixed <N>, hardening owed <M> | KEPT B7 sentence/line from plugins/dev-workflow/commands/workflow-init.md:2007
plugins/dev-workflow/commands/workflow-init.md | - | output rule line 50:   cycle <NONCE>; hardening owed <SLOT>:<n> — <SEVERITY> — <C | KEPT B7 sentence/line from plugins/dev-workflow/commands/workflow-init.md:2008
plugins/dev-workflow/commands/workflow-init.md | - | output rule line 51:   cycle <NONCE>; hardening <SLOT>:<n>: rung <RUNG> | KEPT B7 sentence/line from plugins/dev-workflow/commands/workflow-init.md:2052
plugins/dev-workflow/commands/workflow-init.md | - | output rule line 52:   cycle <NONCE>; hardening <SLOT>:<n>: pending <REF> | KEPT B7 sentence/line from plugins/dev-workflow/commands/workflow-init.md:2053
plugins/dev-workflow/commands/workflow-init.md | - | output rule line 53:   cycle <NONCE>; hardening <SLOT>:<n>: rung 0 — <CHECK> | KEPT B7 sentence/line from plugins/dev-workflow/commands/workflow-init.md:2054
plugins/dev-workflow/commands/workflow-init.md | - | output rule line 54:   A `<TARGET>` containing ` — ` or a double quote is written | KEPT B7 sentence/line from plugins/dev-workflow/commands/workflow-init.md:2020
plugins/dev-workflow/commands/workflow-init.md | - | output rule line 56: To resume, read the cycle nonce and latest pass file and con | NEW B9
plugins/dev-workflow/commands/workflow-init.md | - | output rule line 58: Classify a finding as MAJOR only for realistic inputs. | NEW B10
plugins/dev-workflow/commands/workflow-init.md | - | output rule line 59: When a finding class regenerates across passes, shrink the m | NEW B10
```

## CHECK and describing-file amendments

- CHECK 4h: keep seven required records; replace `not fixed` / `same as <SLOT>:<m>`
  with B5's `accepted, not repaired` / `declined` in the check and its shared fixture.
  The old enum is clearly contrary to B5; addendum 1 makes the keep-list authoritative.
  The other six record lines and their placement check remain unchanged.
- NEW B1: docs-only list gains `todos.md`; plan review is restricted to high risk.
- NEW B2/B3: standalone prompt sentences replace procedural narration; the original
  two-call sentence is retained verbatim. NEW B5 supplies nonce/path context.
- COPIED B6: the three-line cap-answer sentence from repository lines 330–332 is
  extracted unchanged and copied to the scaffold; obsolete surrounding conditions go.
- NEW B6: fixed floor and cap replace the profile-derived floor and closure machinery.
- NEW B7: cap `close` runs the closing act; the old `never closes` sentence is deleted.
  Only lint/test hardening is owed; the old prose/type/prompt-standard routes go.
- NEW B8/B9/B10: compact profile, resume and realistic-input/shrink rules use the
  target form authorized by the addendum. No working-record or replay duty survives
  in either rule copy.
- AGENTS.md: the introductory mechanism description now says lint or test;
  the invariant section is byte-identical to baseline.
- docs/PRD.md: Gate A's scope and the curve-section pointer match the reduced rules.
- CHANGELOG.md: add the current release entry; earlier release entries remain history.
- CLAUDE.md: delete the complete repeated work-loop sentence that mandated all plan
  gates. Its §5 pointer remains; no replacement sentence was introduced.
- docs/ARCHITECTURE.md: list the new history directory as required by AGENTS.md's
  layout-drift rule. The manifest was read before editing it.
- harden-finding: deleting the description's first sentence leaves its second sentence
  verbatim; the Overview likewise drops one complete sentence. No retained sentence
  was rewritten. Prose, type and prompt-standard branches are removed by deletion.
- intake: keep the original condition/fate instruction and its moved/dropped-reason
  sentence, plus the exact template and closed sets. Surrounding procedure and examples go.

## Scope notes for the separate verification session

The hook and reports are unchanged, as requested. Their old reminder thresholds and
historical parsers are not claimed to enforce these new rules. Other out-of-scope
workflow docs/prompts may still describe the earlier workflow; section references
were searched before deletion, rather than silently renamed across the repository.
The next session should review this audit and the compact prompts; no Gate B was run.
