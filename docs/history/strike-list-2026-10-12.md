# Strike-list — 2026-10-12 kit shrink

Baseline: `pre-shrink` (`6b15993`). Authority: Daniel's shrink brief, addendum 1,
and the order to fix findings 1–10 from verification of `5731c45` in one round.
The original preflight escalation is resolved and preserved in git history.

## Reading this audit

Original-line coverage partitions every original line exactly once. Each KEPT range
is byte-identical and contiguous at its stated new-file range; ranges split at inserted
lines and moves. A line partly deleted is accounted as deleted/replaced here, while its
surviving sentence is traced below. Thus a KEPT two-blank-line block is never claimed
where the current text has only single separators.

Every new-file line not in a full-line KEPT range has one `NEWFILE` trace row, including
blank insertions, release/layout additions, partial-line survivors, descriptive edits,
and checker/metadata changes. Rows with `-` in the old-range field add nothing to old-line
coverage. B2/B3 also have whole-sentence source references below. Source references are
to the original at `pre-shrink`; add one for the archive's header line.

The workflow-init archive is its exact fenced 2.1a body; the coverage table covers the
whole command. All four archives retain the header `Archived, non-binding, see the strike-list`.

## Coverage and sizes

| File | Before bytes | After bytes | Original lines | Kept full lines | Deleted/replaced lines | Covered lines |
|---|---:|---:|---:|---:|---:|---:|
| .claude/review-gates.md | 139111 | 6401 | 1665 | 50 | 1615 | 1665 |
| plugins/dev-workflow/commands/workflow-init.md | 232086 | 101771 | 3143 | 1556 | 1587 | 3143 |
| plugins/dev-workflow/skills/harden-finding/SKILL.md | 11921 | 10201 | 193 | 171 | 22 | 193 |
| plugins/dev-workflow/skills/intake/SKILL.md | 32932 | 23501 | 519 | 385 | 134 | 519 |
| AGENTS.md | 23397 | 23368 | 301 | 300 | 1 | 301 |
| CLAUDE.md | 12045 | 11699 | 146 | 143 | 3 | 146 |
| docs/PRD.md | 2988 | 3018 | 43 | 41 | 2 | 43 |
| docs/ARCHITECTURE.md | 10324 | 10421 | 153 | 153 | 0 | 153 |
| plugins/dev-workflow/CHANGELOG.md | 62660 | 63484 | 848 | 848 | 0 | 848 |
| plugins/dev-workflow/.claude-plugin/plugin.json | 490 | 492 | 12 | 10 | 2 | 12 |
| scripts/check-invariants.sh | 57717 | 57720 | 976 | 975 | 1 | 976 |
| scripts/check-invariants.test.sh | 72845 | 72924 | 1284 | 1282 | 2 | 1284 |
| plugins/dev-workflow/commands/process-pr-review.md | 14624 | 14626 | 232 | 231 | 1 | 232 |

## Original-line coverage

```text
.claude/review-gates.md | 1-2 | KEPT B1 -> new 1-2
.claude/review-gates.md | 3-4 | This is `CLAUDE.md` §5 in full, moved here unchanged except  | not in keep-list
.claude/review-gates.md | 5-5 | KEPT B1 -> new 6-6
.claude/review-gates.md | 6-6 | KEPT B8 -> new 9-9
.claude/review-gates.md | 7-10 | Independent second opinion at two gates. Easiest steps to sk | not in keep-list
.claude/review-gates.md | 11-11 | KEPT B2 -> new 11-11
.claude/review-gates.md | 12-14 | **Both gates are a LOOP with a HARD FLOOR: a minimum number  | not in keep-list
.claude/review-gates.md | 15-15 | The derivation is max(risk, security): a value of 0 gives a  | not in keep-list (contradicts B6)
.claude/review-gates.md | 16-62 | resolvable profile above that, and an artifact citing no sto | not in keep-list
.claude/review-gates.md | 63-63 | KEPT B2 -> new 14-14
.claude/review-gates.md | 64-64 | **The derived floor is the pass count a cycle owes, and the  | not in keep-list (contradicts B6)
.claude/review-gates.md | 65-73 | threshold that controls nothing.** The hook still counts pas | not in keep-list
.claude/review-gates.md | 74-74 | KEPT B2 -> new 21-21
.claude/review-gates.md | 75-75 | **Named residual:** the hook's messages state its own thresh | not in keep-list
.claude/review-gates.md | 76-76 | floor of 1 they report a shortfall the cycle does not owe. * | not in keep-list (contradicts B6)
.claude/review-gates.md | 77-78 | What makes that tolerable is the precedence rule above plus  | not in keep-list
.claude/review-gates.md | 79-79 | KEPT B2 -> new 26-26
.claude/review-gates.md | 80-81 | **The gate-off surface — routes known today, not a complete  | not in keep-list
.claude/review-gates.md | 82-82 | the cited set does not license, which could not exist before | not in keep-list (contradicts B6)
.claude/review-gates.md | 83-88 | state. Pre-existing and unchanged: omitting a higher-risk ci | not in keep-list
.claude/review-gates.md | 89-89 | KEPT B2 -> new 30-30
.claude/review-gates.md | 90-110 | **When these rules bind.** From the commit that ships them,  | not in keep-list
.claude/review-gates.md | 111-111 | cycle a floor of 1 and skip passes on the strength of not kn | not in keep-list (contradicts B6)
.claude/review-gates.md | 112-114 | knob set above 3 is not lowered by this fallback. A revert i | not in keep-list
.claude/review-gates.md | 115-115 | KEPT B2 -> new 33-33
.claude/review-gates.md | 116-133 | **Downstream has no shipping commit.** Adoption binds from t | not in keep-list
.claude/review-gates.md | 134-134 | derived floor with no predicate to define it; **no definitio | not in keep-list (contradicts B6)
.claude/review-gates.md | 135-140 | at once**. A | not in keep-list
.claude/review-gates.md | 141-141 | KEPT B2 -> new 38-38
.claude/review-gates.md | 142-144 | **How a cycle ends — one ordering, stated here and reference | not in keep-list
.claude/review-gates.md | 145-145 | KEPT B3 -> new 40-40
.claude/review-gates.md | 146-152 | **What this paragraph owns.** It owns **how a pass is evalua | not in keep-list
.claude/review-gates.md | 153-153 | **those duties bind both gates alike**: the derived floor an | not in keep-list (contradicts B6)
.claude/review-gates.md | 154-155 | their definitions at their own sources and are read here for | not in keep-list
.claude/review-gates.md | 156-156 | KEPT B3 -> new 43-43
.claude/review-gates.md | 157-163 | **What belongs to a gate is what the two gates do differentl | not in keep-list
.claude/review-gates.md | 164-164 | KEPT B3 -> new 45-45
.claude/review-gates.md | 165-172 | **The conditions every cycle has, whatever its gate.** The d | not in keep-list
.claude/review-gates.md | 173-173 | KEPT B3 -> new 48-48
.claude/review-gates.md | 174-179 | **What a pass is read from.** Every finding-derived predicat | not in keep-list
.claude/review-gates.md | 180-180 | repeated here. Beyond the findings, closure reads the **deri | not in keep-list (contradicts B6)
.claude/review-gates.md | 181-190 | standing over this cycle**, any **hold still standing**, and | not in keep-list
.claude/review-gates.md | 191-191 | KEPT B3 -> new 52-52
.claude/review-gates.md | 192-195 | **The four branches are named, and a cross-reference anywher | not in keep-list
.claude/review-gates.md | 196-196 | KEPT B3 -> new 54-54
.claude/review-gates.md | 197-257 | **The source-block branch, read first.** **Where any unmet c | not in keep-list
.claude/review-gates.md | 258-258 | **Eligibility is exactly this and nothing more: a clean pass | not in keep-list (contradicts B6)
.claude/review-gates.md | 259-326 | zero-finding pass.** It is a property of the pass. **Closure | not in keep-list
.claude/review-gates.md | 327-327 | passes has reached its cap: the derived floor plus two until | not in keep-list (contradicts B6)
.claude/review-gates.md | 328-330 | from then on the count at the latest answer plus the further | not in keep-list
.claude/review-gates.md | 331-331 | KEPT B6 -> new 72-72
.claude/review-gates.md | 332-332 | passes it allows, at least one, and resumes the loop on the  | not in keep-list
.claude/review-gates.md | 333-333 | never closes the cycle, credits a pass, skips one or lowers  | not in keep-list (contradicts B7)
.claude/review-gates.md | 334-360 | derived, neither can the cap, and the cycle stops as that de | not in keep-list
.claude/review-gates.md | 361-361 | **The four standing duties, classified.** The **derived floo | not in keep-list (contradicts B6)
.claude/review-gates.md | 362-633 | it gates closing, discharged by the count of valid logical p | not in keep-list
.claude/review-gates.md | 634-634 | derived floor, the risk and security values read, and the ci | not in keep-list (contradicts B6)
.claude/review-gates.md | 635-712 | from. A report giving the number alone leaves a reader unabl | not in keep-list
.claude/review-gates.md | 713-720 | KEPT B4 -> new 55-62
.claude/review-gates.md | 721-724 | > | not in keep-list
.claude/review-gates.md | 725-725 | KEPT B4 -> new 63-63
.claude/review-gates.md | 726-726 | **Gate B takes one file per branch.** Under the default call | not in keep-list
.claude/review-gates.md | 727-727 | KEPT B5 -> new 67-67
.claude/review-gates.md | 728-735 | **Before each call, delete every target file and confirm it  | not in keep-list
.claude/review-gates.md | 736-736 | KEPT B6 -> new 74-74
.claude/review-gates.md | 737-740 | **Companions of a findings file, from field practice.** Two  | not in keep-list
.claude/review-gates.md | 741-741 | KEPT B7 -> new 76-76
.claude/review-gates.md | 742-749 | - `<slot>-dispositions.md` — **owed for every slot of a vali | not in keep-list
.claude/review-gates.md | 750-750 |   Every slot of a validated pass that holds a finding owes a | not in keep-list (contradicts B5)
.claude/review-gates.md | 751-753 | (blank line) | not in keep-list
.claude/review-gates.md | 754-754 |   slot's finding line numbers, 1 to k, each once. `same as < | not in keep-list (contradicts B5)
.claude/review-gates.md | 755-755 |   of a slot **of the same cycle** reporting **the same occur | not in keep-list
.claude/review-gates.md | 756-756 |   place, fixed by the same repair. A finding this cycle **de | not in keep-list (contradicts B5)
.claude/review-gates.md | 757-961 |   another finding's repair did to the same text: a decline b | not in keep-list
.claude/review-gates.md | 962-962 | - **Gate A — Spec, then plan (TWO runs, each its own loop at | not in keep-list (contradicts B6)
.claude/review-gates.md | 963-973 |   **spec** right after brainstorming (before `writing-plans` | not in keep-list
.claude/review-gates.md | 974-977 | KEPT B2 -> new 16-19
.claude/review-gates.md | 978-978 |   (@AGENTS.md) — plus anything else** (coverage floor, not a | not in keep-list
.claude/review-gates.md | 979-980 | KEPT B2 -> new 23-24
.claude/review-gates.md | 981-981 |   line between local choices and questions that need a decis | not in keep-list
.claude/review-gates.md | 982-982 | KEPT B2 -> new 28-28
.claude/review-gates.md | 983-985 |   include like any other content. Why: a plan exists to sett | not in keep-list
.claude/review-gates.md | 986-988 | KEPT B2 -> new 35-37
.claude/review-gates.md | 989-1023 |   Ask for one line per finding and a literal `NO FINDINGS` w | not in keep-list
.claude/review-gates.md | 1024-1024 | KEPT B3 -> new 50-50
.claude/review-gates.md | 1025-1363 |   format. **You filter to Blocker/Major for what must be rep | not in keep-list
.claude/review-gates.md | 1364-1364 | KEPT B5 -> new 66-66
.claude/review-gates.md | 1365-1374 |                                             a path containin | not in keep-list
.claude/review-gates.md | 1375-1375 |   ship, `none (pre-rule)` only for one that began before the | not in keep-list (contradicts B6)
.claude/review-gates.md | 1376-1522 |   cited set that produced it**, each member with its level a | not in keep-list
.claude/review-gates.md | 1523-1524 | KEPT B7 -> new 81-82
.claude/review-gates.md | 1525-1535 | (blank line) | not in keep-list
.claude/review-gates.md | 1536-1536 | KEPT B7 -> new 86-86
.claude/review-gates.md | 1537-1567 | (blank line) | not in keep-list
.claude/review-gates.md | 1568-1570 | KEPT B7 -> new 83-85
.claude/review-gates.md | 1571-1571 | KEPT B7 -> new 87-87
.claude/review-gates.md | 1572-1586 |   `<RUNG>` is one of `1`, `2`, `3`, `4`, `P`; `<REF>` is the | not in keep-list
.claude/review-gates.md | 1587-1587 | KEPT B9 -> new 89-89
.claude/review-gates.md | 1588-1665 |   **What the ledger check is worth.** An author-written reco | not in keep-list
plugins/dev-workflow/commands/workflow-init.md | 1-462 | KEPT outside rule keep-list / unchanged source -> new 1-462
plugins/dev-workflow/commands/workflow-init.md | 463-464 | The work loop includes the review gates: **spec ready → Gate | not in keep-list
plugins/dev-workflow/commands/workflow-init.md | 465-486 | KEPT outside rule keep-list / unchanged source -> new 463-484
plugins/dev-workflow/commands/workflow-init.md | 487-492 | preparing a merge, and deciding a change needs no gate.** Ev | not in keep-list
plugins/dev-workflow/commands/workflow-init.md | 493-514 | KEPT outside rule keep-list / unchanged source -> new 487-508
plugins/dev-workflow/commands/workflow-init.md | 515-517 | targets" (in 2.1) says. Why a separate file: inline, these r | not in keep-list
plugins/dev-workflow/commands/workflow-init.md | 518-519 | KEPT outside rule keep-list / unchanged source -> new 510-511
plugins/dev-workflow/commands/workflow-init.md | 520-530 | (blank line) | not in keep-list
plugins/dev-workflow/commands/workflow-init.md | 531-536 | KEPT outside rule keep-list / unchanged source -> new 512-517
plugins/dev-workflow/commands/workflow-init.md | 537-538 | KEPT B1 -> new 518-519
plugins/dev-workflow/commands/workflow-init.md | 539-540 | This is `CLAUDE.md` §5 in full, moved here unchanged except  | not in keep-list
plugins/dev-workflow/commands/workflow-init.md | 541-541 | KEPT B1 -> new 523-523
plugins/dev-workflow/commands/workflow-init.md | 542-553 | Independent second opinion at two gates. Easiest steps to sk | not in keep-list
plugins/dev-workflow/commands/workflow-init.md | 554-554 | KEPT B8 -> new 526-526
plugins/dev-workflow/commands/workflow-init.md | 555-557 | **Both gates are a LOOP with a HARD FLOOR: a minimum number  | not in keep-list
plugins/dev-workflow/commands/workflow-init.md | 558-558 | The derivation is max(risk, security): a value of 0 gives a  | not in keep-list (contradicts B6)
plugins/dev-workflow/commands/workflow-init.md | 559-605 | resolvable profile above that, and an artifact citing no sto | not in keep-list
plugins/dev-workflow/commands/workflow-init.md | 606-606 | KEPT B2 -> new 528-528
plugins/dev-workflow/commands/workflow-init.md | 607-607 | **The derived floor is the pass count a cycle owes, and the  | not in keep-list (contradicts B6)
plugins/dev-workflow/commands/workflow-init.md | 608-616 | threshold that controls nothing.** The hook still counts pas | not in keep-list
plugins/dev-workflow/commands/workflow-init.md | 617-617 | KEPT B2 -> new 531-531
plugins/dev-workflow/commands/workflow-init.md | 618-618 | **Named residual:** the hook's messages state its own thresh | not in keep-list
plugins/dev-workflow/commands/workflow-init.md | 619-619 | floor of 1 they report a shortfall the cycle does not owe. * | not in keep-list (contradicts B6)
plugins/dev-workflow/commands/workflow-init.md | 620-621 | What makes that tolerable is the precedence rule above plus  | not in keep-list
plugins/dev-workflow/commands/workflow-init.md | 622-622 | KEPT B2 -> new 538-538
plugins/dev-workflow/commands/workflow-init.md | 623-624 | **The gate-off surface — routes known today, not a complete  | not in keep-list
plugins/dev-workflow/commands/workflow-init.md | 625-625 | the cited set does not license, which could not exist before | not in keep-list (contradicts B6)
plugins/dev-workflow/commands/workflow-init.md | 626-631 | state. Pre-existing and unchanged: omitting a higher-risk ci | not in keep-list
plugins/dev-workflow/commands/workflow-init.md | 632-632 | KEPT B2 -> new 543-543
plugins/dev-workflow/commands/workflow-init.md | 633-653 | **When these rules bind.** From the commit that ships them,  | not in keep-list
plugins/dev-workflow/commands/workflow-init.md | 654-654 | cycle a floor of 1 and skip passes on the strength of not kn | not in keep-list (contradicts B6)
plugins/dev-workflow/commands/workflow-init.md | 655-657 | knob set above 3 is not lowered by this fallback. A revert i | not in keep-list
plugins/dev-workflow/commands/workflow-init.md | 658-658 | KEPT B2 -> new 547-547
plugins/dev-workflow/commands/workflow-init.md | 659-676 | **Downstream has no shipping commit.** Adoption binds from t | not in keep-list
plugins/dev-workflow/commands/workflow-init.md | 677-677 | derived floor with no predicate to define it; **no definitio | not in keep-list (contradicts B6)
plugins/dev-workflow/commands/workflow-init.md | 678-683 | at once**. A | not in keep-list
plugins/dev-workflow/commands/workflow-init.md | 684-684 | KEPT B2 -> new 550-550
plugins/dev-workflow/commands/workflow-init.md | 685-687 | **How a cycle ends — one ordering, stated here and reference | not in keep-list
plugins/dev-workflow/commands/workflow-init.md | 688-688 | KEPT B2 -> new 555-555
plugins/dev-workflow/commands/workflow-init.md | 689-695 | **What this paragraph owns.** It owns **how a pass is evalua | not in keep-list
plugins/dev-workflow/commands/workflow-init.md | 696-696 | **those duties bind both gates alike**: the derived floor an | not in keep-list (contradicts B6)
plugins/dev-workflow/commands/workflow-init.md | 697-698 | their definitions at their own sources and are read here for | not in keep-list
plugins/dev-workflow/commands/workflow-init.md | 699-699 | KEPT B3 -> new 557-557
plugins/dev-workflow/commands/workflow-init.md | 700-706 | **What belongs to a gate is what the two gates do differentl | not in keep-list
plugins/dev-workflow/commands/workflow-init.md | 707-707 | KEPT B3 -> new 560-560
plugins/dev-workflow/commands/workflow-init.md | 708-715 | **The conditions every cycle has, whatever its gate.** The d | not in keep-list
plugins/dev-workflow/commands/workflow-init.md | 716-716 | KEPT B3 -> new 562-562
plugins/dev-workflow/commands/workflow-init.md | 717-722 | **What a pass is read from.** Every finding-derived predicat | not in keep-list
plugins/dev-workflow/commands/workflow-init.md | 723-723 | repeated here. Beyond the findings, closure reads the **deri | not in keep-list (contradicts B6)
plugins/dev-workflow/commands/workflow-init.md | 724-733 | standing over this cycle**, any **hold still standing**, and | not in keep-list
plugins/dev-workflow/commands/workflow-init.md | 734-734 | KEPT B3 -> new 565-565
plugins/dev-workflow/commands/workflow-init.md | 735-738 | **The four branches are named, and a cross-reference anywher | not in keep-list
plugins/dev-workflow/commands/workflow-init.md | 739-739 | KEPT B3 -> new 569-569
plugins/dev-workflow/commands/workflow-init.md | 740-761 | **The source-block branch, read first.** **Where any unmet c | not in keep-list
plugins/dev-workflow/commands/workflow-init.md | 762-762 | KEPT B3 -> new 571-571
plugins/dev-workflow/commands/workflow-init.md | 763-800 | **Then the clean-completion branch, and eligibility is its o | not in keep-list
plugins/dev-workflow/commands/workflow-init.md | 801-801 | **Eligibility is exactly this and nothing more: a clean pass | not in keep-list (contradicts B6)
plugins/dev-workflow/commands/workflow-init.md | 802-890 | zero-finding pass.** It is a property of the pass. **Closure | not in keep-list
plugins/dev-workflow/commands/workflow-init.md | 891-891 | **The four standing duties, classified.** The **derived floo | not in keep-list (contradicts B6)
plugins/dev-workflow/commands/workflow-init.md | 892-1160 | it gates closing, discharged by the count of valid logical p | not in keep-list
plugins/dev-workflow/commands/workflow-init.md | 1161-1161 | derived floor, the risk and security values read, and the ci | not in keep-list (contradicts B6)
plugins/dev-workflow/commands/workflow-init.md | 1162-1230 | from. A report giving the number alone leaves a reader unabl | not in keep-list
plugins/dev-workflow/commands/workflow-init.md | 1231-1238 | KEPT B4 -> new 572-579
plugins/dev-workflow/commands/workflow-init.md | 1239-1242 | > | not in keep-list
plugins/dev-workflow/commands/workflow-init.md | 1243-1243 | KEPT B4 -> new 580-580
plugins/dev-workflow/commands/workflow-init.md | 1244-1244 | **Gate B takes one file per branch.** Under the default call | not in keep-list
plugins/dev-workflow/commands/workflow-init.md | 1245-1245 | KEPT B5 -> new 584-584
plugins/dev-workflow/commands/workflow-init.md | 1246-1253 | **Before each call, delete every target file and confirm it  | not in keep-list
plugins/dev-workflow/commands/workflow-init.md | 1254-1254 | KEPT B6 -> new 591-591
plugins/dev-workflow/commands/workflow-init.md | 1255-1258 | **Companions of a findings file, from field practice.** Two  | not in keep-list
plugins/dev-workflow/commands/workflow-init.md | 1259-1259 | KEPT B7 -> new 593-593
plugins/dev-workflow/commands/workflow-init.md | 1260-1267 | - `<slot>-dispositions.md` — **owed for every slot of a vali | not in keep-list
plugins/dev-workflow/commands/workflow-init.md | 1268-1268 |   Every slot of a validated pass that holds a finding owes a | not in keep-list (contradicts B5)
plugins/dev-workflow/commands/workflow-init.md | 1269-1271 | (blank line) | not in keep-list
plugins/dev-workflow/commands/workflow-init.md | 1272-1272 |   slot's finding line numbers, 1 to k, each once. `same as < | not in keep-list (contradicts B5)
plugins/dev-workflow/commands/workflow-init.md | 1273-1273 |   of a slot **of the same cycle** reporting **the same occur | not in keep-list
plugins/dev-workflow/commands/workflow-init.md | 1274-1274 |   place, fixed by the same repair. A finding this cycle **de | not in keep-list (contradicts B5)
plugins/dev-workflow/commands/workflow-init.md | 1275-1475 |   another finding's repair did to the same text: a decline b | not in keep-list
plugins/dev-workflow/commands/workflow-init.md | 1476-1476 | - **Gate A — Spec, then plan (TWO runs, each its own loop at | not in keep-list (contradicts B6)
plugins/dev-workflow/commands/workflow-init.md | 1477-1487 |   **spec** right after brainstorming (before `writing-plans` | not in keep-list
plugins/dev-workflow/commands/workflow-init.md | 1488-1491 | KEPT B2 -> new 533-536
plugins/dev-workflow/commands/workflow-init.md | 1492-1492 |   (@AGENTS.md) — plus anything else** (coverage floor, not a | not in keep-list
plugins/dev-workflow/commands/workflow-init.md | 1493-1494 | KEPT B2 -> new 540-541
plugins/dev-workflow/commands/workflow-init.md | 1495-1495 |   line between local choices and questions that need a decis | not in keep-list
plugins/dev-workflow/commands/workflow-init.md | 1496-1496 | KEPT B2 -> new 545-545
plugins/dev-workflow/commands/workflow-init.md | 1497-1499 |   include like any other content. Why: a plan exists to sett | not in keep-list
plugins/dev-workflow/commands/workflow-init.md | 1500-1501 | KEPT B2 -> new 552-553
plugins/dev-workflow/commands/workflow-init.md | 1502-1537 |   severity drops real findings silently. | not in keep-list
plugins/dev-workflow/commands/workflow-init.md | 1538-1538 | KEPT B3 -> new 567-567
plugins/dev-workflow/commands/workflow-init.md | 1539-1847 |   format. **You filter to Blocker/Major for what must be rep | not in keep-list
plugins/dev-workflow/commands/workflow-init.md | 1848-1848 | KEPT B5 -> new 583-583
plugins/dev-workflow/commands/workflow-init.md | 1849-1858 |                                             a path containin | not in keep-list
plugins/dev-workflow/commands/workflow-init.md | 1859-1859 |   ship, `none (pre-rule)` only for one that began before the | not in keep-list (contradicts B6)
plugins/dev-workflow/commands/workflow-init.md | 1860-2006 |   cited set that produced it**, each member with its level a | not in keep-list
plugins/dev-workflow/commands/workflow-init.md | 2007-2008 | KEPT B7 -> new 598-599
plugins/dev-workflow/commands/workflow-init.md | 2009-2019 | (blank line) | not in keep-list
plugins/dev-workflow/commands/workflow-init.md | 2020-2020 | KEPT B7 -> new 603-603
plugins/dev-workflow/commands/workflow-init.md | 2021-2051 | (blank line) | not in keep-list
plugins/dev-workflow/commands/workflow-init.md | 2052-2054 | KEPT B7 -> new 600-602
plugins/dev-workflow/commands/workflow-init.md | 2055-2055 | KEPT B7 -> new 604-604
plugins/dev-workflow/commands/workflow-init.md | 2056-2070 |   `<RUNG>` is one of `1`, `2`, `3`, `4`, `P`; `<REF>` is the | not in keep-list
plugins/dev-workflow/commands/workflow-init.md | 2071-2071 | KEPT B9 -> new 606-606
plugins/dev-workflow/commands/workflow-init.md | 2072-2149 |   **What the ledger check is worth.** An author-written reco | not in keep-list
plugins/dev-workflow/commands/workflow-init.md | 2150-3143 | KEPT outside rule keep-list / unchanged source -> new 609-1602
plugins/dev-workflow/skills/harden-finding/SKILL.md | 1-9 | KEPT outside rule keep-list / unchanged source -> new 1-9
plugins/dev-workflow/skills/harden-finding/SKILL.md | 10-11 | A review finding is only *closed* when the most deterministi | not in keep-list
plugins/dev-workflow/skills/harden-finding/SKILL.md | 12-45 | KEPT outside rule keep-list / unchanged source -> new 11-44
plugins/dev-workflow/skills/harden-finding/SKILL.md | 46-46 | \| 1 · prose \| a convention/judgment call no tool can adjudic | not in keep-list
plugins/dev-workflow/skills/harden-finding/SKILL.md | 47-47 | KEPT outside rule keep-list / unchanged source -> new 45-45
plugins/dev-workflow/skills/harden-finding/SKILL.md | 48-48 | \| 3 · type \| expressible in the type system \| the project's  | not in keep-list
plugins/dev-workflow/skills/harden-finding/SKILL.md | 49-49 | KEPT outside rule keep-list / unchanged source -> new 46-46
plugins/dev-workflow/skills/harden-finding/SKILL.md | 50-50 | \| P · prompt-standard \| the finding is in a prompt artifact  | not in keep-list
plugins/dev-workflow/skills/harden-finding/SKILL.md | 51-54 | KEPT outside rule keep-list / unchanged source -> new 47-50
plugins/dev-workflow/skills/harden-finding/SKILL.md | 55-63 | - Prefer the strongest deterministic rung that fits: a secur | not in keep-list
plugins/dev-workflow/skills/harden-finding/SKILL.md | 64-79 | KEPT outside rule keep-list / unchanged source -> new 51-66
plugins/dev-workflow/skills/harden-finding/SKILL.md | 80-81 |    - latest matching row is a real rung (1–4/P) → the prior  | not in keep-list
plugins/dev-workflow/skills/harden-finding/SKILL.md | 82-156 | KEPT outside rule keep-list / unchanged source -> new 67-141
plugins/dev-workflow/skills/harden-finding/SKILL.md | 157-161 | escaping. You supply: the canonical `fingerprint`, a short o | not in keep-list
plugins/dev-workflow/skills/harden-finding/SKILL.md | 162-187 | KEPT outside rule keep-list / unchanged source -> new 143-168
plugins/dev-workflow/skills/harden-finding/SKILL.md | 188-188 | - Filing an auth/ACL finding as prose when a lint/type/test  | not in keep-list
plugins/dev-workflow/skills/harden-finding/SKILL.md | 189-193 | KEPT outside rule keep-list / unchanged source -> new 169-173
plugins/dev-workflow/skills/intake/SKILL.md | 1-306 | KEPT outside rule keep-list / unchanged source -> new 1-306
plugins/dev-workflow/skills/intake/SKILL.md | 307-344 | A second route, separate from the Flow. Use it when an appro | not in keep-list
plugins/dev-workflow/skills/intake/SKILL.md | 345-345 | 5. **Assign a fate and an AC operation** to every enumerated | FORMATTING: remove dangling 5. marker only (finding 8)
plugins/dev-workflow/skills/intake/SKILL.md | 346-351 |    condition, or per run of criteria sharing a fate). Then c | not in keep-list
plugins/dev-workflow/skills/intake/SKILL.md | 352-352 | KEPT outside rule keep-list / unchanged source -> new 309-309
plugins/dev-workflow/skills/intake/SKILL.md | 353-395 |    in the row; a fate with no passage to quote is not a fate | not in keep-list
plugins/dev-workflow/skills/intake/SKILL.md | 396-420 | KEPT outside rule keep-list / unchanged source -> new 311-335
plugins/dev-workflow/skills/intake/SKILL.md | 421-463 | **Added without an earlier condition — the rules.** This fie | not in keep-list
plugins/dev-workflow/skills/intake/SKILL.md | 464-464 | KEPT outside rule keep-list / unchanged source -> new 336-336
plugins/dev-workflow/skills/intake/SKILL.md | 465-467 | (blank line) | not in keep-list
plugins/dev-workflow/skills/intake/SKILL.md | 468-519 | KEPT outside rule keep-list / unchanged source -> new 337-388
AGENTS.md | 1-12 | KEPT outside rule keep-list / unchanged source -> new 1-12
AGENTS.md | 13-13 | recurring finding escalates one rung harder (prose → lint →  | DESCRIBING / metadata update authorized by brief and Fix round 1
AGENTS.md | 14-301 | KEPT outside rule keep-list / unchanged source -> new 14-301
CLAUDE.md | 1-82 | KEPT outside rule keep-list / unchanged source -> new 1-82
CLAUDE.md | 83-84 | The work loop includes the review gates: **spec ready → Gate | DESCRIBING / metadata update authorized by brief and Fix round 1
CLAUDE.md | 85-116 | KEPT outside rule keep-list / unchanged source -> new 83-114
CLAUDE.md | 117-117 | §5 (its Mechanics, Profiles, closure ordering or gate prompt | DESCRIBING / metadata update authorized by brief and Fix round 1
CLAUDE.md | 118-146 | KEPT outside rule keep-list / unchanged source -> new 116-144
docs/PRD.md | 1-24 | KEPT outside rule keep-list / unchanged source -> new 1-24
docs/PRD.md | 25-25 | \| Review-loop pass curves per cycle \| `python3 -B scripts/lo | DESCRIBING / metadata update authorized by brief and Fix round 1
docs/PRD.md | 26-37 | KEPT outside rule keep-list / unchanged source -> new 26-37
docs/PRD.md | 38-38 | \| Review gates (Gate A on spec and plan, Gate B on the diff) | DESCRIBING / metadata update authorized by brief and Fix round 1
docs/PRD.md | 39-43 | KEPT outside rule keep-list / unchanged source -> new 39-43
docs/ARCHITECTURE.md | 1-60 | KEPT outside rule keep-list / unchanged source -> new 1-60
docs/ARCHITECTURE.md | 61-153 | KEPT outside rule keep-list / unchanged source -> new 62-154
plugins/dev-workflow/CHANGELOG.md | 1-23 | KEPT outside rule keep-list / unchanged source -> new 1-23
plugins/dev-workflow/CHANGELOG.md | 24-848 | KEPT outside rule keep-list / unchanged source -> new 37-861
plugins/dev-workflow/.claude-plugin/plugin.json | 1-3 | KEPT outside rule keep-list / unchanged source -> new 1-3
plugins/dev-workflow/.claude-plugin/plugin.json | 4-5 |   "version": "0.23.0", | DESCRIBING / metadata update authorized by brief and Fix round 1
plugins/dev-workflow/.claude-plugin/plugin.json | 6-12 | KEPT outside rule keep-list / unchanged source -> new 6-12
scripts/check-invariants.sh | 1-896 | KEPT outside rule keep-list / unchanged source -> new 1-896
scripts/check-invariants.sh | 897-897 | LR_REQ='Every slot of a validated pass that holds a finding  | CHECK: B5 verdict vocabulary / recorded mutation result
scripts/check-invariants.sh | 898-976 | KEPT outside rule keep-list / unchanged source -> new 898-976
scripts/check-invariants.test.sh | 1-34 | KEPT outside rule keep-list / unchanged source -> new 1-34
scripts/check-invariants.test.sh | 35-35 | LR_LINES='Every slot of a validated pass that holds a findin | CHECK: B5 verdict vocabulary / recorded mutation result
scripts/check-invariants.test.sh | 36-453 | KEPT outside rule keep-list / unchanged source -> new 36-453
scripts/check-invariants.test.sh | 454-454 | #              (measured 2026-10-10, when 4h was added). The | CHECK: B5 verdict vocabulary / recorded mutation result
scripts/check-invariants.test.sh | 455-1284 | KEPT outside rule keep-list / unchanged source -> new 456-1285
plugins/dev-workflow/commands/process-pr-review.md | 1-185 | KEPT outside rule keep-list / unchanged source -> new 1-185
plugins/dev-workflow/commands/process-pr-review.md | 186-186 |    open obligation (`.claude/review-gates.md`, Mechanics, th | DESCRIBING / metadata update authorized by brief and Fix round 1
plugins/dev-workflow/commands/process-pr-review.md | 187-232 | KEPT outside rule keep-list / unchanged source -> new 187-232
```

## Inserted-line and partial-line trace

```text
.claude/review-gates.md | - | NEWFILE 3-3: Gate A reviews every spec with `mcp__codex__exec`; a plan ge | NEW B1
.claude/review-gates.md | - | NEWFILE 4-4: Gate B reviews every code diff with `mcp__codex__review` aft | NEW B1
.claude/review-gates.md | - | NEWFILE 5-5: Docs-only means every staged path is explanatory Markdown un | NEW B1
.claude/review-gates.md | - | NEWFILE 7-7: Before Gate A, obtain human confirmation of one profile line | NEW B8
.claude/review-gates.md | - | NEWFILE 8-8: Evidence modes: `battery`, `battery+check`, or `battery+chec | NEW B8
.claude/review-gates.md | - | NEWFILE 10-10: ## Gate-A prompt | NEW B2
.claude/review-gates.md | - | NEWFILE 12-12: Tool: `mcp__codex__exec` (raw; | KEPT B2 sentence extract from .claude/review-gates.md:965
.claude/review-gates.md | - | NEWFILE 13-13:   reviews the TEXT you pass, not the git tree). | KEPT B2 sentence extract from .claude/review-gates.md:966
.claude/review-gates.md | - | NEWFILE 15-15: The prompt MUST open with | KEPT B2 sentence extract from .claude/review-gates.md:973
.claude/review-gates.md | - | NEWFILE 20-20:   (@AGENTS.md) — plus anything else** (coverage floor, not a | KEPT B2 sentence extract from .claude/review-gates.md:978
.claude/review-gates.md | - | NEWFILE 22-22: Ask also what the artifact is for: of a spec, whether its | KEPT B2 sentence extract from .claude/review-gates.md:978
.claude/review-gates.md | - | NEWFILE 25-25:   line between local choices and questions that need a decis | KEPT B2 sentence extract from .claude/review-gates.md:981
.claude/review-gates.md | - | NEWFILE 27-27: Report missing code or tests only where | KEPT B2 sentence extract from .claude/review-gates.md:981
.claude/review-gates.md | - | NEWFILE 29-29:   include like any other content. | KEPT B2 sentence extract from .claude/review-gates.md:983
.claude/review-gates.md | - | NEWFILE 31-31: Append the | KEPT B2 sentence extract from .claude/review-gates.md:984
.claude/review-gates.md | - | NEWFILE 32-32:   intent + artifact text + which invariants it touches. | KEPT B2 sentence extract from .claude/review-gates.md:985
.claude/review-gates.md | - | NEWFILE 34-34: Ask for **every** finding | KEPT B2 sentence extract from .claude/review-gates.md:985
.claude/review-gates.md | - | NEWFILE 39-39: ## Gate-B prompt | NEW B3
.claude/review-gates.md | - | NEWFILE 41-41: Tool: `mcp__codex__review` | KEPT B3 sentence extract from .claude/review-gates.md:1007
.claude/review-gates.md | - | NEWFILE 42-42:   (args `instruction`, `whatWasImplemented`, `baseSha`, `hea | KEPT B3 sentence extract from .claude/review-gates.md:1008
.claude/review-gates.md | - | NEWFILE 44-44: **Default call shape: two sequential single-branch calls per | KEPT B3 sentence extract from .claude/review-gates.md:1008
.claude/review-gates.md | - | NEWFILE 46-46: Check against | KEPT B3 sentence extract from .claude/review-gates.md:1008
.claude/review-gates.md | - | NEWFILE 47-47:   @AGENTS.md. | KEPT B3 sentence extract from .claude/review-gates.md:1009
.claude/review-gates.md | - | NEWFILE 49-49: Same coverage rule as Gate A: put "report every finding with | KEPT B3 sentence extract from .claude/review-gates.md:1023
.claude/review-gates.md | - | NEWFILE 51-51:   format. | KEPT B3 sentence extract from .claude/review-gates.md:1025
.claude/review-gates.md | - | NEWFILE 53-53: **Standing lens, every Gate-B call: "which existing statemen | KEPT B3 sentence extract from .claude/review-gates.md:1029
.claude/review-gates.md | - | NEWFILE 64-64: Choose a fresh cycle nonce of 8–16 lowercase letters or digi | NEW B5
.claude/review-gates.md | - | NEWFILE 65-65: For the provenance line, write a story set as `{docs/story.m | NEW B5
.claude/review-gates.md | - | NEWFILE 68-68: The floor is 3 valid passes; repair Blockers/Majors and reru | NEW B6
.claude/review-gates.md | - | NEWFILE 69-69: Collect Minors and Nits; never iterate on them. | NEW B6
.claude/review-gates.md | - | NEWFILE 70-70: Stop before a further pass at cap = floor + 2, or at the cou | NEW B6
.claude/review-gates.md | - | NEWFILE 71-71: It asks the user to choose — delete the mechanism the | KEPT B6 sentence extract from .claude/review-gates.md:330
.claude/review-gates.md | - | NEWFILE 73-73: passes it allows, at least one, and resumes the loop on the  | KEPT B6 sentence extract from .claude/review-gates.md:332
.claude/review-gates.md | - | NEWFILE 75-75: ## Closing act | NEW B7
.claude/review-gates.md | - | NEWFILE 77-77: A cap answer may instead be `close`; then, as for a clean pa | NEW B7
.claude/review-gates.md | - | NEWFILE 78-78: cycle <NONCE>; floor 3 per <story paths with levels, or none | NEW B7
.claude/review-gates.md | - | NEWFILE 79-79: cycle <NONCE>; <Gate-A spec\|Gate-A plan\|Gate B> (passes <asc | NEW B7
.claude/review-gates.md | - | NEWFILE 80-80: Every slot of a validated pass that holds a finding owes a d | NEW B5
.claude/review-gates.md | - | NEWFILE 88-88: To resume, read the cycle nonce and latest pass file and con | NEW B9
.claude/review-gates.md | - | NEWFILE 90-90: Classify a finding as MAJOR only for realistic inputs. | NEW B10
.claude/review-gates.md | - | NEWFILE 91-91: When a finding class regenerates across passes, shrink the m | NEW B10
plugins/dev-workflow/commands/workflow-init.md | - | NEWFILE 485-485: preparing a merge, and deciding a change needs no gate.** Ev | KEPT sentence extract from plugins/dev-workflow/commands/workflow-init.md:487
plugins/dev-workflow/commands/workflow-init.md | - | NEWFILE 486-486: means that file. | KEPT sentence extract from plugins/dev-workflow/commands/workflow-init.md:488
plugins/dev-workflow/commands/workflow-init.md | - | NEWFILE 509-509: targets" (in 2.1) says. This file is read when the pointer | KEPT sentence fragments from plugins/dev-workflow/commands/workflow-init.md:515,517 (deleted intervening size sentence)
plugins/dev-workflow/commands/workflow-init.md | - | NEWFILE 520-520: Gate A reviews every spec with `mcp__codex__exec`; a plan ge | NEW B1
plugins/dev-workflow/commands/workflow-init.md | - | NEWFILE 521-521: Gate B reviews every code diff with `mcp__codex__review` aft | NEW B1
plugins/dev-workflow/commands/workflow-init.md | - | NEWFILE 522-522: Docs-only means every staged path is explanatory Markdown un | NEW B1
plugins/dev-workflow/commands/workflow-init.md | - | NEWFILE 524-524: Before Gate A, obtain human confirmation of one profile line | NEW B8
plugins/dev-workflow/commands/workflow-init.md | - | NEWFILE 525-525: Evidence modes: `battery`, `battery+check`, or `battery+chec | NEW B8
plugins/dev-workflow/commands/workflow-init.md | - | NEWFILE 527-527: ## Gate-A prompt | NEW B2
plugins/dev-workflow/commands/workflow-init.md | - | NEWFILE 529-529: Tool: `mcp__codex__exec` (raw; | KEPT B2 sentence extract from plugins/dev-workflow/commands/workflow-init.md:1479
plugins/dev-workflow/commands/workflow-init.md | - | NEWFILE 530-530:   reviews the TEXT you pass, not the git tree). | KEPT B2 sentence extract from plugins/dev-workflow/commands/workflow-init.md:1480
plugins/dev-workflow/commands/workflow-init.md | - | NEWFILE 532-532: The prompt MUST open with | KEPT B2 sentence extract from plugins/dev-workflow/commands/workflow-init.md:1487
plugins/dev-workflow/commands/workflow-init.md | - | NEWFILE 537-537:   (@AGENTS.md) — plus anything else** (coverage floor, not a | KEPT B2 sentence extract from plugins/dev-workflow/commands/workflow-init.md:1492
plugins/dev-workflow/commands/workflow-init.md | - | NEWFILE 539-539: Ask also what the artifact is for: of a spec, whether its | KEPT B2 sentence extract from plugins/dev-workflow/commands/workflow-init.md:1492
plugins/dev-workflow/commands/workflow-init.md | - | NEWFILE 542-542:   line between local choices and questions that need a decis | KEPT B2 sentence extract from plugins/dev-workflow/commands/workflow-init.md:1495
plugins/dev-workflow/commands/workflow-init.md | - | NEWFILE 544-544: Report missing code or tests only where | KEPT B2 sentence extract from plugins/dev-workflow/commands/workflow-init.md:1495
plugins/dev-workflow/commands/workflow-init.md | - | NEWFILE 546-546:   include like any other content. | KEPT B2 sentence extract from plugins/dev-workflow/commands/workflow-init.md:1497
plugins/dev-workflow/commands/workflow-init.md | - | NEWFILE 548-548: Append the | KEPT B2 sentence extract from plugins/dev-workflow/commands/workflow-init.md:1498
plugins/dev-workflow/commands/workflow-init.md | - | NEWFILE 549-549:   intent + artifact text + which invariants it touches. | KEPT B2 sentence extract from plugins/dev-workflow/commands/workflow-init.md:1499
plugins/dev-workflow/commands/workflow-init.md | - | NEWFILE 551-551: Ask for **every** finding | KEPT B2 sentence extract from plugins/dev-workflow/commands/workflow-init.md:1499
plugins/dev-workflow/commands/workflow-init.md | - | NEWFILE 554-554:   severity drops real findings silently (`docs/prompt-standa | COPIED B2 from .claude/review-gates.md:988
plugins/dev-workflow/commands/workflow-init.md | - | NEWFILE 556-556: ## Gate-B prompt | NEW B3
plugins/dev-workflow/commands/workflow-init.md | - | NEWFILE 558-558: Tool: `mcp__codex__review` | KEPT B3 sentence extract from plugins/dev-workflow/commands/workflow-init.md:1521
plugins/dev-workflow/commands/workflow-init.md | - | NEWFILE 559-559:   (args `instruction`, `whatWasImplemented`, `baseSha`, `hea | KEPT B3 sentence extract from plugins/dev-workflow/commands/workflow-init.md:1522
plugins/dev-workflow/commands/workflow-init.md | - | NEWFILE 561-561: **Default call shape: two sequential single-branch calls per | KEPT B3 sentence extract from plugins/dev-workflow/commands/workflow-init.md:1522
plugins/dev-workflow/commands/workflow-init.md | - | NEWFILE 563-563: Check against | KEPT B3 sentence extract from plugins/dev-workflow/commands/workflow-init.md:1522
plugins/dev-workflow/commands/workflow-init.md | - | NEWFILE 564-564:   @AGENTS.md. | KEPT B3 sentence extract from plugins/dev-workflow/commands/workflow-init.md:1523
plugins/dev-workflow/commands/workflow-init.md | - | NEWFILE 566-566: Same coverage rule as Gate A: put "report every finding with | KEPT B3 sentence extract from plugins/dev-workflow/commands/workflow-init.md:1537
plugins/dev-workflow/commands/workflow-init.md | - | NEWFILE 568-568:   format. | KEPT B3 sentence extract from plugins/dev-workflow/commands/workflow-init.md:1539
plugins/dev-workflow/commands/workflow-init.md | - | NEWFILE 570-570: **Standing lens, every Gate-B call: "which existing statemen | KEPT B3 sentence extract from plugins/dev-workflow/commands/workflow-init.md:1543
plugins/dev-workflow/commands/workflow-init.md | - | NEWFILE 581-581: Choose a fresh cycle nonce of 8–16 lowercase letters or digi | NEW B5
plugins/dev-workflow/commands/workflow-init.md | - | NEWFILE 582-582: For the provenance line, write a story set as `{docs/story.m | NEW B5
plugins/dev-workflow/commands/workflow-init.md | - | NEWFILE 585-585: The floor is 3 valid passes; repair Blockers/Majors and reru | NEW B6
plugins/dev-workflow/commands/workflow-init.md | - | NEWFILE 586-586: Collect Minors and Nits; never iterate on them. | NEW B6
plugins/dev-workflow/commands/workflow-init.md | - | NEWFILE 587-587: Stop before a further pass at cap = floor + 2, or at the cou | NEW B6
plugins/dev-workflow/commands/workflow-init.md | - | NEWFILE 588-588: It asks the user to choose — delete the mechanism the | COPIED B6 from .claude/review-gates.md:330
plugins/dev-workflow/commands/workflow-init.md | - | NEWFILE 589-589: findings keep returning to, cut scope, or continue — and eve | COPIED B6 from .claude/review-gates.md:331
plugins/dev-workflow/commands/workflow-init.md | - | NEWFILE 590-590: passes it allows, at least one, and resumes the loop on the  | COPIED B6 from .claude/review-gates.md:332
plugins/dev-workflow/commands/workflow-init.md | - | NEWFILE 592-592: ## Closing act | NEW B7
plugins/dev-workflow/commands/workflow-init.md | - | NEWFILE 594-594: A cap answer may instead be `close`; then, as for a clean pa | NEW B7
plugins/dev-workflow/commands/workflow-init.md | - | NEWFILE 595-595: cycle <NONCE>; floor 3 per <story paths with levels, or none | NEW B7
plugins/dev-workflow/commands/workflow-init.md | - | NEWFILE 596-596: cycle <NONCE>; <Gate-A spec\|Gate-A plan\|Gate B> (passes <asc | NEW B7
plugins/dev-workflow/commands/workflow-init.md | - | NEWFILE 597-597: Every slot of a validated pass that holds a finding owes a d | NEW B5
plugins/dev-workflow/commands/workflow-init.md | - | NEWFILE 605-605: To resume, read the cycle nonce and latest pass file and con | NEW B9
plugins/dev-workflow/commands/workflow-init.md | - | NEWFILE 607-607: Classify a finding as MAJOR only for realistic inputs. | NEW B10
plugins/dev-workflow/commands/workflow-init.md | - | NEWFILE 608-608: When a finding class regenerates across passes, shrink the m | NEW B10
plugins/dev-workflow/skills/harden-finding/SKILL.md | - | NEWFILE 10-10: **What a deterministic tool can catch does not belong in the | KEPT sentence extract from plugins/dev-workflow/skills/harden-finding/SKILL.md:11
plugins/dev-workflow/skills/harden-finding/SKILL.md | - | NEWFILE 142-142: escaping. | KEPT sentence extract from plugins/dev-workflow/skills/harden-finding/SKILL.md:157
plugins/dev-workflow/skills/intake/SKILL.md | - | NEWFILE 307-307: **Assign a fate and an AC operation** to every enumerated co | KEPT sentence extract from plugins/dev-workflow/skills/intake/SKILL.md:345; FORMATTING: removed 5. only
plugins/dev-workflow/skills/intake/SKILL.md | - | NEWFILE 308-308:    condition, or per run of criteria sharing a fate). | KEPT sentence extract from plugins/dev-workflow/skills/intake/SKILL.md:346
plugins/dev-workflow/skills/intake/SKILL.md | - | NEWFILE 310-310:    in the row; a fate with no passage to quote is not a fate | KEPT sentence extract from plugins/dev-workflow/skills/intake/SKILL.md:353
AGENTS.md | - | NEWFILE 13-13: recurring finding is hardened with lint or a test, and one | DESCRIBING
CLAUDE.md | - | NEWFILE 115-115: §5 means that file. | DESCRIBING
docs/PRD.md | - | NEWFILE 25-25: \| Review-loop pass curves per cycle \| `python3 -B scripts/lo | DESCRIBING
docs/PRD.md | - | NEWFILE 38-38: \| Review gates (Gate A on every spec and high-risk plans, Ga | DESCRIBING
docs/ARCHITECTURE.md | - | NEWFILE 61-61:   history/                       # non-binding pre-shrink ar | NEW DESCRIBING layout entry (findings 6–7)
plugins/dev-workflow/CHANGELOG.md | - | NEWFILE 24-24: (blank line) | NEW release entry
plugins/dev-workflow/CHANGELOG.md | - | NEWFILE 25-25: ## 0.24.0 | NEW release entry
plugins/dev-workflow/CHANGELOG.md | - | NEWFILE 26-26: (blank line) | NEW release entry
plugins/dev-workflow/CHANGELOG.md | - | NEWFILE 27-27: - Delete the expanded gate procedures in favor of keep-list  | NEW release entry
plugins/dev-workflow/CHANGELOG.md | - | NEWFILE 28-28:   high-risk plans, Gate B on non-docs-only diffs, floor 3, c | NEW release entry
plugins/dev-workflow/CHANGELOG.md | - | NEWFILE 29-29:   compact pass/disposition records and the closing ledger re | NEW release entry
plugins/dev-workflow/CHANGELOG.md | - | NEWFILE 30-30: - Delete the working-record and replay duties; synchronize t | NEW release entry
plugins/dev-workflow/CHANGELOG.md | - | NEWFILE 31-31: - Delete prose, type and prompt-standard hardening branches; | NEW release entry
plugins/dev-workflow/CHANGELOG.md | - | NEWFILE 32-32:   Findings fitting neither remain findings without a hardeni | NEW release entry
plugins/dev-workflow/CHANGELOG.md | - | NEWFILE 33-33: - Delete intake amendment procedure prose and examples, reta | NEW release entry
plugins/dev-workflow/CHANGELOG.md | - | NEWFILE 34-34:   closed-set template. Align check 4h's dispositions vocabul | NEW release entry
plugins/dev-workflow/CHANGELOG.md | - | NEWFILE 35-35: - Verbatim pre-shrink archives and the deletion audit are in | NEW release entry
plugins/dev-workflow/CHANGELOG.md | - | NEWFILE 36-36:   see `docs/history/strike-list-2026-10-12.md`. | NEW release entry
plugins/dev-workflow/.claude-plugin/plugin.json | - | NEWFILE 4-4:   "version": "0.24.0", | NEW version metadata
plugins/dev-workflow/.claude-plugin/plugin.json | - | NEWFILE 5-5:   "description": "Spec-driven workflow with two independent  | DESCRIBING
scripts/check-invariants.sh | - | NEWFILE 897-897: LR_REQ='Every slot of a validated pass that holds a finding  | CHECK
scripts/check-invariants.test.sh | - | NEWFILE 35-35: LR_LINES='Every slot of a validated pass that holds a findin | CHECK
scripts/check-invariants.test.sh | - | NEWFILE 454-454: #              (re-measured 2026-10-12 after B5 changed the  | CHECK
scripts/check-invariants.test.sh | - | NEWFILE 455-455: #              Originally measured 2026-10-10. The shared in | CHECK
plugins/dev-workflow/commands/process-pr-review.md | - | NEWFILE 186-186:    open obligation (`.claude/review-gates.md`, Closing act,  | DESCRIBING
```

## KEPT B2/B3 sentence references — finding 9

```text
.claude/review-gates.md | - | Tool: `mcp__codex__exec` (raw;
  reviews the TEXT you pass,  | KEPT B2 from .claude/review-gates.md:965-966
plugins/dev-workflow/commands/workflow-init.md | - | Tool: `mcp__codex__exec` (raw;
  reviews the TEXT you pass,  | KEPT B2 from plugins/dev-workflow/commands/workflow-init.md:1479-1480
.claude/review-gates.md | - | The prompt MUST open with
  *"Use the superpowers:brainstorm | KEPT B2 from .claude/review-gates.md:973-978
plugins/dev-workflow/commands/workflow-init.md | - | The prompt MUST open with
  *"Use the superpowers:brainstorm | KEPT B2 from plugins/dev-workflow/commands/workflow-init.md:1487-1492
.claude/review-gates.md | - | Ask also what the artifact is for: of a spec, whether its
   | KEPT B2 from .claude/review-gates.md:978-981
plugins/dev-workflow/commands/workflow-init.md | - | Ask also what the artifact is for: of a spec, whether its
   | KEPT B2 from plugins/dev-workflow/commands/workflow-init.md:1492-1495
.claude/review-gates.md | - | Report missing code or tests only where
  their absence has  | KEPT B2 from .claude/review-gates.md:981-983
plugins/dev-workflow/commands/workflow-init.md | - | Report missing code or tests only where
  their absence has  | KEPT B2 from plugins/dev-workflow/commands/workflow-init.md:1495-1497
.claude/review-gates.md | - | Append the
  intent + artifact text + which invariants it to | KEPT B2 from .claude/review-gates.md:984-985
plugins/dev-workflow/commands/workflow-init.md | - | Append the
  intent + artifact text + which invariants it to | KEPT B2 from plugins/dev-workflow/commands/workflow-init.md:1498-1499
.claude/review-gates.md | - | Ask for **every** finding
  with severity and confidence — * | KEPT B2 from .claude/review-gates.md:985-988
plugins/dev-workflow/commands/workflow-init.md | - | Ask for **every** finding
  with severity and confidence — * | COPIED B2 from .claude/review-gates.md:985-988
.claude/review-gates.md | - | Tool: `mcp__codex__review`
  (args `instruction`, `whatWasIm | KEPT B3 from .claude/review-gates.md:1007-1008
plugins/dev-workflow/commands/workflow-init.md | - | Tool: `mcp__codex__review`
  (args `instruction`, `whatWasIm | KEPT B3 from plugins/dev-workflow/commands/workflow-init.md:1521-1522
.claude/review-gates.md | - | **Default call shape: two sequential single-branch calls per | KEPT B3 from .claude/review-gates.md:1008-1008
plugins/dev-workflow/commands/workflow-init.md | - | **Default call shape: two sequential single-branch calls per | KEPT B3 from plugins/dev-workflow/commands/workflow-init.md:1522-1522
.claude/review-gates.md | - | Check against
  @AGENTS.md. | KEPT B3 from .claude/review-gates.md:1008-1009
plugins/dev-workflow/commands/workflow-init.md | - | Check against
  @AGENTS.md. | KEPT B3 from plugins/dev-workflow/commands/workflow-init.md:1522-1523
.claude/review-gates.md | - | Same coverage rule as Gate A: put "report every finding with | KEPT B3 from .claude/review-gates.md:1023-1025
plugins/dev-workflow/commands/workflow-init.md | - | Same coverage rule as Gate A: put "report every finding with | KEPT B3 from plugins/dev-workflow/commands/workflow-init.md:1537-1539
.claude/review-gates.md | - | **Standing lens, every Gate-B call: "which existing statemen | KEPT B3 from .claude/review-gates.md:1029-1029
plugins/dev-workflow/commands/workflow-init.md | - | **Standing lens, every Gate-B call: "which existing statemen | KEPT B3 from plugins/dev-workflow/commands/workflow-init.md:1543-1543
```

## DESCRIBING

- AGENTS.md: the introductory mechanism description now says lint or test; the whole
  Key invariants section is byte-identical to `pre-shrink`.
- docs/PRD.md: Gate A's scope is specs/high-risk plans, and the curve pointer now names
  Closing act. Both replacements describe mechanisms removed by the shrink.
- CLAUDE.md: retain deletion of the old work-loop sentence because it described mandatory
  Gate A on every plan, contrary to B1; remove deleted section names from the §5 pointer.
  These are the only differences from `pre-shrink`, and both are describing-sentence fixes.
- workflow-init.md template 2.1: remove Mechanics/Profiles/closure-ordering names from
  the §5 pointer; its existing deletion of the mandatory-plan loop has the same B1 reason.
- process-pr-review.md: replace the ledger-check pointer's Mechanics with Closing act.
- plugin.json: replace the escalation-ladder description with lint/test hardening;
  the version remains 0.24.0.
- docs/ARCHITECTURE.md: retain only the history-directory layout description, the sole
  difference from `pre-shrink`. It describes the new archive/audit location, as AGENTS.md
  requires. No behavioral instruction is added. Its inserted line has a NEW row above.
- CHANGELOG.md: the 13-line release insertion is traced line by line as NEW; older entries
  remain history. Original KEPT blocks split around the insertion.

## CHECK and restored format

- Check 4h and its shared fixture still pin seven records, with B5's verdict vocabulary
  `fixed`, `accepted, not repaired`, `declined`. No checker changed in Fix round 1.
- Finding 1: restore harden-finding's complete original description verbatim from its archive.
- Finding 2: restore template 2.2 verbatim from `pre-shrink`, including the full Superseded
  rows convention and Columns definition. Its ledger format is not gate-loop prose.
- Finding 7: every current line outside a full-line KEPT block now has a trace row;
  this includes workflow-init's old 515/517 splice and both skills' partial-line survivors.
- Finding 8: delete only intake's dangling `5. ` prefix; the retained instruction is unchanged.
- Finding 9: remove the NEW B2/B3 paraphrases and retain the original prompt sentences,
  tool routing and sequential two-call shape. No new substantive B2/B3 sentence remains.
- Finding 10: keep 0.24.0 now; re-bump at rebase time if ticket-skill merges first.

## Scope

The hook, Python reports, examples, source-files, docs/superpowers and todos.md remain
untouched. Other historical workflow descriptions remain outside this ten-finding round.
No Gate B ran and this PR remains a draft. The four archived bodies are unchanged.
