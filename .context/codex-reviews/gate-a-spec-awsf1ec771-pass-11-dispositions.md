# Gate-A spec pass 11 — dispositions (cycle awsf1ec771)

Advisory companion. One line per finding: verdict + reason. Spec revised at the commit whose
subject is `docs(specs): loop-rule consolidation — Gate-A pass 11 revision (one authority per rule)`.

**The centrepiece was finding 14**, and findings 3, 4 and 6 were its symptoms. The block was
restating triggers, duties, preconditions and the severity answer that their own paragraphs still
defined, so each prompt copy held two authorities and they had already drifted. The repair
inverts it: the block is authoritative for the evaluation order and for closure and **cites**
every other rule where that rule lives; where a cited rule had to change to agree, it changed at
its source. §3 now carries a one-authority table naming all eight cited rules and their single
definitions, which is the check finding 14 was really asking for.

1 | fixed | The rollback transition already exists — the activation paragraph's stricter reading, which §4 item 6 extends with "every suspension binding". §9 no longer implies a gap; what is open is whether that reading is *sufficient*, and that is the successor's.
2 | fixed | File aggregation and severity selection separated into two sentences; severity now points at the (g) replacement as the single authority instead of restating the partition.
3 | fixed | A below-floor clean pass carrying a health reading **suspends**. Corrected at all three sites — the third branch, the composition paragraph's closing sentence, and §5(c)'s `c18` entry — and §7's health-reading row already expects the suspension.
4 | fixed | The hold **attaches to every surfaced finding, whichever suspension surfaced it**, discharged by the answers that surface requires. This reverses the passes 6–7 narrowing to scope stops, which contradicted both `c16` and the story's own third standing duty; `c16` returns to **kept** and the reversal is recorded in §5(c) rather than left silent.
5 | fixed | A declined finding stays excluded for the cycle unless the user explicitly reverses that decision. The current set is now stated once, in `b7`: what every governing artifact assigns, plus what this cycle accepted, minus what it declined.
6 | fixed | `b11` qualified at both source sites with the already-declined exception, marked **replaced** in the accounting, and §6's equivalence check rebuilt to compare **complete predicates** in a four-row table — comparing a shared phrase is what let the earlier revision call two unequal wordings equivalent.
7 | fixed | A structural or contract question already answered in this cycle is no longer new, so re-raising it opens no question stop. Within-cycle only, no durable record. Two rows added to the next-state table.
8 | fixed | **Continue consumes the reading** that raised the suspension; a further health suspension needs it recomputed over a pass run after the answer, which is new data. That gives continue a distinct next state even on an unrevised artifact. Row added.
9 | fixed | Stop **parks** the cycle — open, not running, spending no passes, restarted only by an explicit later continue — a named state distinct from the suspended-awaiting-answer one it was in before the answer. `c19`'s accounting updated to match.
10 | fixed | Conservative, since sameness is deferred: a line in one branch file and a line in the other are **distinct** findings for holds and answers, so a `full` pass asks twice rather than risk resuming over one it never asked about. Stated as a rule in the shipped block, not as a temporal hedge.
11 | fixed | `b7` edited at its source in both copies with an OLD/NEW pair and its accounting: the union where several artifacts govern one cycle. The singular reading left a multi-plan Gate-B cycle with no defined fix set on its **first** pass, before any suspension could raise the question.
12 | fixed | Overclaim corrected. The live one-contract paragraph (C:880–890 / W:1063–1074) names the nonce, slots, provenance, curve, carry and unknown-start records and **not** this block or its coupled edits, so its coherence rule does not reach them. §9 now states an **admitted unsafe state**, not protection.
13 | fixed | Seven OLD/NEW assert pairs added for the §5 passage edits (`a17`, `a13`, `b7`, `b11`, `b12`, the (c) trim, `e7`), plus `b3` checked in W alone with C required unchanged, which is what makes it an alignment rather than a two-copy edit.
14 | fixed | See the note above. §8's item-8 claim also corrected: it rested on "replaces rather than adds beside", which was false while the block was restating; it now rests on what the block does, with §3's table as the check.
15 | fixed | Profile-change-while-a-hold-stands row added, run against both answer directions, with the further pass the change costs; the profile as currently read is now a column.
16 | fixed | Observability residual stated plainly: a closing body records that a cycle closed and its curve, and **nothing about which exit it took**, so a reader cannot audit that every suspension was answered. Assigned to the successor; the evidence entry and curve are explicitly not claimed to supply it.
17 | fixed | `b3` taken out of the blanket kept range and marked an **edited cross-reference whose operative condition is kept**; its edit is checked in §7 like any other.
18 | fixed | Real ranges cited (C:328–329 / W:522–523) and the counted single-line substring named.
19 | fixed | Real ranges cited (C:565–566 wrapped, W:757 whole) and the counted substring named — the part single-line in **both**, which is why the check uses it rather than the displayed sentence.
20 | fixed | Real ranges cited (C:783–784 / W:969–970) and the counted substring named.

**18–20 also produced a general repair.** §4's preamble no longer claims every quoted OLD is a
single line. It now says a sentence is quoted whole, that several wrap, and that each item gives
its real range in both copies plus the single-line substring the check counts — because a
displayed sentence spanning a wrap cannot be counted with `grep -F`, and quoting one as though it
could is what made three earlier checks read as false reds. **Every OLD fragment was then
re-verified on that basis**, not only the three named: all fourteen shared substrings count 1/1.

**One thing found while re-reading that no finding raised**, repaired: the shipped block carried
"Until the sameness rule ships…", a temporal hedge that means nothing in a scaffolded copy where
no successor is coming. It is now stated as the rule it is; the fact that a successor may replace
it is spec commentary in §3, not prompt text.
