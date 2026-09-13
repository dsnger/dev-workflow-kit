# §5 loop-rule consolidation: one closure ordering — Design

**Date:** 2026-09-10 · **Status:** DRAFT — in Gate A, not yet approved
**Story:** `docs/superpowers/stories/2026-08-29-loop-rule-consolidation-story.md`
**Profile:** read from that header at every pass, never from here — it is the only writable
copy, and a value copied here would be a remembered value.

Prompt-only, in two mirrored copies: `CLAUDE.md` §5 (**C** below) and the inline template in
`plugins/dev-workflow/commands/workflow-init.md` (**W** below). No file under
`plugins/dev-workflow/hooks/` changes. Condition ids `a1`…`j4` are defined in
`docs/superpowers/specs/2026-09-10-loop-rule-consolidation-condition-inventory.md` beside this
file: 135 conditions quoted from `7c0d475`, so a reader can check an accounting rather than
take it.

**Narrowed twice on 2026-09-10, and §9 lists what moved.** First the record-durability subject
went to a successor story. Then the bookkeeping went to the plan: this spec was 785 lines of
which the design was 173, and **58% of it sat in four bookkeeping sections** — quoted OLD and NEW
text, per-condition dispositions, the parity divergence list, the verification substrings, 456
lines between them — which took roughly half the
findings of every Gate-A pass while describing work the plan performs against real files. **It
is moved, not dropped.** The plan is the carrier and each section below names what it owes.

---

## 1. Intent

**What ships.** One closure ordering, stated once in each copy, that says which exit *closes* a
cycle and which merely *suspend* it, in what order a pass is read so the ranking is executable
rather than asserted, what any set of suspensions at once does, and which of the four standing
duties participate in that ordering versus gate it as preconditions. With it: the answer to what
a severity demotion does to the loop-health counts, and the standing sentences the ordering
falsifies or leaves ambiguous if they are not edited at their source. **§4 lists the sites row by
row and claims no total over them**, a count over spans that merge and split being bookkeeping the
plan re-derives against the files. **The falsified standing sentences are a different count**
and **only the target text's §F states it**, which is why no number for them appears here — a
second copy of that count is what went stale four times, because those are individually enumerated sentences rather than
spans.

**What does not:** the pass floor and severity semantics, which the parent shipped and this spec
reads as given, and everything §9 lists as moved or parked.

**Why the record split, since a reader of the ordering will look for the record.** Gate-A spec
pass 10 tripped the two-tell threshold and satisfied all three conditions of the clearly-stuck
reading. Nine of that pass's twenty findings belonged to **one subject this story never set out
to answer** — whether a record survives a session, a commit amend, a squash, a rollback or a
moved checkout — while the ordering's own five were small. Daniel split that subject out; §9
says what went and where.

---

## 2. Settled inputs

The story's §4 table is the design's starting point and is not restated here; decisions are cited
as **D1**…**D8** at the rules they settle, and no claim is made that each appears individually. **D9**, **D9b**, **D9c** and **D10** stay settled and move to the
successor with the material they govern (§9). Two implementation facts the parent cycle
established are read as given: a pass's cleanliness is a fact about what that pass found and is
**never rewritten** — an answer changes whether the *cycle* may close; and the findings files
establish the **inventory** of findings, not their resolutions.

What the table does not settle, this spec decides in the section that uses it: the evaluation
order and the file set each predicate reads; the duties' classification; which stop each of the
scope stop's two triggers raises and what each answer does; what a clearly-stuck or two-tell
answer produces; and the raw-severity rule for the health measures. **The block's ownership
boundary is stated once, in the target text's §A opening, and is deliberately not restated here** —
two copies of it are what let them drift, which is pass 20 finding 3. What this spec records is the
decision behind it: the block defines no trigger and no severity rule of its own, and every closure
precondition **that has a source of its own** keeps its one definition there, changed **at that
source** where it had to change to agree with the ordering.

**One behaviour decision was added after the split, on Daniel's decision of 2026-09-13, and it
changes the clean predicate.** A finding this cycle has **validly dismissed** and a later pass
merely repeats, with no new evidence and no relevant change to the text the dismissal turned on,
**does not on its own make that later pass unclean**. Without it the standing duty *dismiss
validly, then run another pass* cannot finish: the reviewer would be the authority on whether its
own refuted claim had been dealt with, and a cycle could be held permanently unclean by a repeated
false positive. **It is deliberately narrow and it is not a waiver** — the repetition stays a
finding in its file, every loop-health reading counts it, it remains the clearly-stuck reading's
re-raise condition, no earlier pass becomes clean in retrospect, and doubt about whether it is the
same complaint is resolved against the exclusion. **No new suspension type and no record mechanism
were introduced for it**, which two earlier candidate answers would have required. **Its three
qualifications are carried to every site that states the discharge** — the ordering's suspension
paragraph, §C's third condition and §H's surfacing sentence — because stated only at the clean
predicate they would leave a recurrence that has *become* true reading as discharged (pass 28
finding 3). **It also has an unknown-start strict reading**: unavailable where a cycle cannot
establish that its starting rules contained it, since the standing fallback says each rule this
change ships adds its own (pass 28 finding 6). **The Blocker
that prompted it is accepted on that core and not on its reasoning**: pass 27 argued the cycle
could *never* close, resting on a six-pass plateau the text does not set as a threshold and on a
coverage judgement that is a fact about now rather than forever. The repeated-refuted-complaint
problem stands on its own without either.

**Clean completion outranks a suspension by closing the cycle, not by being eligible** (pass 29
finding 1). The earlier wording barred every eligible pass from suspending, which let a clean pass
blocked by an unresolved prior Major, a standing hold or stale evidence walk past §D's **mandatory**
two-tell stop and keep spending passes. **This narrows a rule this change itself wrote, and
contradicts no settled decision**: D2 and D3 forbid reporting "will not converge" on a loop that
converged, and a loop still owing a repair, an answer or a closure condition has not converged.
Two other pass-29 repairs are compliance rather than decision — the unknown-start list gains the
remaining rules this change ships, and §G's membership test reaches rules deciding termination
**without** a pass, the Gate-B triviality skip being the only such route. A third, sharpening the
index condition to a tree-to-tree comparison, **left with that condition** in the 2026-09-13 cut.

**A closing act that does not complete has not closed the cycle, and a failed command is not a
pass outcome** (pass 30 finding 4). **The first wording of this was wrong and pass 31 said why**:
it claimed every condition stayed established, which a pre-commit hook that modifies and stages
content before failing falsifies, and it added a "no branch is taken" clause contradicting the
pass-29 rule that a non-closing pass reaches the suspension branch. **The rule was shrunk rather
than extended**: nothing is assumed about what a failed attempt left behind, every closure
condition is re-established against the repository as it stands, the act is performed again where
they hold, and where the attempt or its repair moved anything a condition is read from that
condition's own rule decides the cost. **It introduces no branch and no mechanism.** Recorded
because adopting a reviewer's suggested fix wholesale is what produced three Majors here.

**One gap is named and not closed** (pass 29 finding 2, and §I carries it): a Gate-A closing act is
written from the effective index, so a staged edit to a review input **no source rule governs** — a
cited story's acceptance criteria, say — is published by the closing commit unchecked. Profile
values, cited-set membership and the assigned fix set are governed and answer themselves. **Neither gate answers this after the
2026-09-13 cut**: Gate B's own version of the hazard is deferred with that condition, and Gate A's
has never been decided. The text states both residuals instead of inventing a rule for either.

**The ordering is split into three paragraphs on Daniel's decision of 2026-09-12, and that split is
the answer to pass 26's Blocker.** The ordering had stated one closure condition — the artifact's
equality with the text sent to the reviewer — cycle-generally, while its explanation and its two
repository cases were Gate-A's alone; Gate B passes a git range rather than artifact text, so an
otherwise eligible Gate-B pass had no value with which to evaluate it and, being eligible, could
not suspend either. **What is gate-general stays gate-general and what differs goes to the gate**:
the ordering keeps the evaluation of a pass, the classification of the duties, and the closure
conditions both gates share — the floor, the resolve duty, the hold, no-clean-credit, and the
profile, cited-set and assigned-fix-set gates; each gate states only **its own content condition
and its own closing act**, and neither gate's paragraph is an inventory of what that gate requires.
**No closing-time test is an exception to the block's citation rule any more**, because the one
that was is now Gate A's own condition stated at Gate A's paragraph. **The split buys ownership and
not brevity** — the three paragraphs together run slightly longer than the single block did.

**The Gate-B tree-equality condition is deferred out of this change on Daniel's decision of
2026-09-13, as a bounded scope cut.** Writing Gate B's closure down had exposed a real gap (pass 27
finding 4): the gate reviews a `baseSha`..`headSha` range while the closing amend commits the
**effective index**, so content staged before the review, or staged by a hook during the commit,
reaches the closing commit through neither branch. The condition written for it, and the widened
re-review duty it carried, **are removed from the target text**; the gap is recorded in §I as a
later task and is **not** worked out here. **The price is stated rather than implied**: this
delivery does not close that gap. Gate B's existing review, re-review and evidence duties stand
unchanged and are not a substitute, and **the gate hook is not one either** — its fingerprint is
advisory and compares its own inputs across its own invocations, so content staged before the
review call and still staged at the commit leaves it unmoved between the two. **Faster convergence
is plausible, not guaranteed.** What the cut removes is two of pass 32's six Blocker/Majors, both
collisions this condition created — against the ordering's pre-act requirement and against the
branch-tip sentence. **Pass 32's finding 4 is expressly not resolved by it**: §A1's failed-act rule
contradicts §F item 1's pass-credit sentence without either mentioning the tree.

**Gate A's mirror of the same hazard is not a second condition**: a staged edit to a cited story or
a profile header is published by A2's closing commit, and the source rules answer what they govern —
a profile change costs a further pass — so A2 says where those rules bite at the closing act and
adds nothing (pass 28 finding 4). Where the staged edit touches a review input **no** source rule
governs, nothing reaches it, which §I carries as its own residual (pass 29 finding 2).

**The closure-ordering block is an addition beside the source edits**, not one of them. §4 lists
the edits; **no total is stated here or there**, because the unit — one contiguous replacement at
one site — is not stable across revisions that merge or split a span, and a stated total then
disagrees with its own table. The plan counts what it writes.

---
## 3. Where the text is

**The §5 text this change ships is written out in full, as it will read, in
`docs/superpowers/specs/2026-09-10-loop-rule-consolidation-target-text.md`.** That file is the
artifact; this one is the decisions behind it.

**Why the split, and it is the pass-17 answer.** Until pass 17 this spec carried the ordering
block, a twenty-two row edit table, the source sentences and the rationales as **four parallel
descriptions of one change**, which had to agree with one another simultaneously — so a repair to
any one of them fell out of step with the other three, and a pass found the gap. Seventeen Gate-A
passes, a Blocker count flat at 1 for four of them, and three findings in pass 17 alone from one
mechanism: a standing sentence the block falsifies that the edit table did not name.

**What was wrong with the diagnosis that produced this, said because it was carried with force.**
The claim was that a spec *cannot* determine which sentences a change touches. That is too broad:
the standing text is on disk and greppable. What a spec cannot do is keep four descriptions of a
*future* text in agreement while all four are being revised. Writing the future text once removes
three of them, and the remaining enumeration question — whether every affected site was found —
is a sweep against real files, which §7 assigns to the plan and §I of the target text states as
an open residual rather than a closed claim.

**What this spec still owns**, and none of it is in the target text: the settled inputs it reads
(§2), the passage map (§5), parity (§6), verification (§7), the invariants touched (§8), and what
moved or is parked (§9).

**This is not a Gate-A close.** §5's clearly-stuck exit says surfacing closes nothing, credits no
pass as clean and leaves the findings open. Gate A stays open and re-aims at the target text with
pass 17's findings as its basis; the rules are not activated; Gate B reviews the implementation
diff later, and neither file is that diff.

---

## 4. The edits, by site

**No sentence is quoted here and no replacement is written here** — the target text carries every
one, in final form, grouped by passage. This table exists so the passage map in §5 has something
to point at and so a reader can see the shape of the change without reading the whole target text.

| Passage or site | What changes |
|---|---|
| the closure ordering | **new**, and it is section A of the target text |
| (a) the floor paragraphs | §H |
| (b) what a loop absorbs | §B |
| (c) recognizing clearly stuck | §C |
| (e) the five tells | §D |
| Mechanics · Severity | the resolve duty is scoped and gains its discharge rule; the handed-over question is replaced by its answer |
| Mechanics · `baseSha` | two sentences: the `WIP:` warning stops claiming a closure the rules do not grant, and the `Finishing the cycle` lead-in performs the amend only where the ordering permits closing |
| Mechanics, recording a human exception | two sentences: a prescribed continuation answer is distinguished from blanket assent, and the Gate-A destination follows the closing act rather than naming the spec or plan commit. The answer-record material stays moved to the successor |
| Gate B, the coverage instruction | `NO FINDINGS` only when the branch found none |
| Mechanics, the curve's Majors rationale | rewritten on the pre-ceiling reading |
| Mechanics, the one-contract paragraph | membership widened, with a semantic test a downstream reader can apply |
| (i) when these rules bind | §H |
| the Gate-A section and the gate-prompt template | the two senses of *clean* are separated; the cadence makes revision conditional; the broad-prompt instruction stops assuming the artifact is revised between passes, keeping its breadth demand |
| the profiles section, the lens paragraph | its unchanged-list is scoped to the lens sets |
| the §5 loop rule, the HARD FLOOR parenthetical | "(Blocker/Major only)" no longer describes what the floor is spent on, a scope-stop trigger and an accepted Minor both bearing on it (pass 47 finding 1); §F item 8a |
| the Gate-A section, the coverage instruction's filter clause | the filter is scoped to what must be repaired, every line still being read for cleanliness, the triggers, the fix set and loop health (pass 47 finding 2); §F item 8b |
| Mechanics, the cycle nonce's mid-run recovery sentence | a Gate-A cycle does have a commit of its own where `HEAD` already carries the reviewed text (pass 48 finding 1); §F item 7a |
| the profiles section, the evidence-entry revalidation trigger | scoped to the commit the closing act produces rather than to the amend (pass 46 finding 2); §F item 9a |
| Mechanics · Severity, the severity-deciding fallback | "collect, never iterate" scoped to the severity's own cost (pass 44 finding 2); §F item 9b |
| the profiles section, the profile-change paragraph | its claim that a stray non-`WIP` commit "would discard the accumulated passes" is narrowed to the hook's count of them (pass 33 finding 7); §F item 8 |
| the profiles section, the evidence-entry revalidation remedy | its fix-re-review-close instruction becomes conditional on the ordering selecting continuation, a non-closing pass taking any applicable suspension first (pass 30 finding 3). The eighth falsified standing sentence, and the sixth sharing §F's mechanism |

**Two sentences are deliberately not edited**, named so nobody looks for them: the "Copy every
record into the squash body" sentence inside the human-exception block, and the "records every
cycle owes" list. This change ships no record.

**No total is claimed, here or in the target text.** A count over spans that merge and split
disagrees with its own table at the next revision, which is what pass 15 found. The plan counts
what it writes.

---

## 5. The passage map, and who carries the accounting

**The plan carries the kept / moved / replaced / dropped disposition for every one of the 135
conditions in the committed inventory**, per passage, **beside the edit it belongs to** — which
is the only place it can be checked against the file being changed. **Story acceptance criterion
5 is satisfied by that list, not by this section**, and nothing here is dropped by being absent
here. This table says what happens to each inventoried passage, so the map stays complete at ten.

| Passage | This change | Target text |
|---|---|---|
| (a) the floor paragraphs | edited — closure sentences trimmed to a pointer, the no-restating prohibition scoped, the per-pass fix command pointed at Mechanics | §H |
| (b) what a loop absorbs | edited — owns both triggers and the fix set, so every qualification the ordering needs is made **here**, which is what keeps one definition per rule; **gains the closing-time rule for a change to the set**, which no inventoried condition carried because none existed (Daniel, 2026-09-12: a change costs at least one further pass, in either direction and whether or not it is later undone, the window opening where the set is fixed for the pass); **an accept at a membership stop puts the finding in the set whatever its severity** (pass 27 finding 2), membership and the repair duty being different things, so an accepted Minor is in the set although Severity asks no repair for it | §B |
| (c) recognizing clearly stuck | edited — keeps its three-condition reading, stops carrying evaluation order; **its precedence sentence is split**, the operative clause moving into the block unchanged and capitalized there while the plateau rationale stays at this source (pass 26 finding 9, pass 27 finding 6); the third condition is widened here to admit a re-raised validated dismissal, and its reason is restated because the deadlock it named is now answered by the clean predicate | §C |
| (d) from pass 4 onward | **no longer edited.** The unavailable-history block moved to the successor with **D10** | — |
| (e) the five tells | edited — the threshold is read after clean completion, and a pointer says what its answer does | §D |
| (f) the two rules above do not compete | **unchanged.** "The two rules above" still names the absorb rule and the stuck reading; the block sits before both and adds no third rule between them | — |
| (g) Mechanics · Severity, the handed-over question | edited — the unsettled statement and its interim report-and-stop duty are replaced by the answer, in both copies, removing the one deliberate story-path divergence | §E |
| (h) recording a human exception | **edited in two sentences** — a prescribed continuation answer is distinguished from blanket assent, which the ordering makes the restart of a parked cycle; and the Gate-A destination follows the closing act, the spec-or-plan commit being that commit on only one of three closing paths. The answer-record block that was to follow it stays moved to the successor with **D9**, and nothing else in the passage changes | §F |
| (i) when these rules bind | edited — the strict-reading list is added to, not rewritten | §H |
| (j) the squash carry | **no longer edited.** It was to name the answer record, which moved; this change ships no record for it to carry | — |

**Three reversals are recorded here rather than left as silent narrowings**, because each was
made in an earlier revision of this spec and each contradicted something settled. Membership was
briefly re-read when the answer arrived, which `b6` and **D4** both forbid. The hold was briefly
narrowed to scope stops, which contradicted `c16` and the story's own third standing duty; it
attaches to **every** surfaced finding. And `c18` — no pass credited as clean on a clearly-stuck
surface — is **replaced** rather than kept: where that exit's regenerating findings are in-set
and the ceiling demotes them below Major, the pass is clean at effective severity, closes at or
above the floor and suspends below it. Authority **D3**, under which the old reading and D3's own
preserved sentence decide that pass in opposite directions.

---

## 6. Parity

The two copies must agree on every rule this change ships: the block, the (g) replacement and
every edit in §4 are byte-identical in C and W. **The plan carries the divergence list** — which
pre-existing wording differences are deliberate and stay, which are not and are aligned — and
**performs the extraction and diff**, passage by passage, against the real files. One divergence
is decided here because it is a correctness call rather than a wording one: W's `b3` pointer
names "the severity rule" on the inventory's reasoning that W has no Mechanics section, which is
false, so W takes C's wording (`b3`, target text §B).

The same extraction runs a second check within each copy: that `b11` and `b13` as edited say what
the block cites them as saying, **comparing the complete predicates and not a shared phrase** —
including `b11`'s already-declined exception and `b13`'s already-answered qualification, in both
directions. A condition in the block and not in the source ships two triggers that disagree; one
in the source and not in the block means the block cites a rule it has not read.

---
## 7. Verification

**The mode is read from the story's header at execution**, never from here — the same rule this
spec's header states. What follows is what each level of that mode obliges.

**Battery.** The quality command in `AGENTS.md` § Commands runs once, green, at the Gate-B WIP
commit (`scripts/check-version-bump.sh main` needs the committed bump, §8).

**The check — what it must establish, and where it is built.** Every edit that changes a standing
meaning owes a **discriminating pair of counts**: one showing the new wording present, one
showing the old wording gone. Each half runs in **both copies** and against **both** the working
tree and the parent tree, so every assertion is observed passing where the change exists and
failing where it does not. A one-sided presence check is not enough: a copy carrying the new
wording **and** the old one satisfies it, which is the two-instructions-that-disagree failure §4
exists to prevent. **An edit that only adds, replacing no wording, is checked by presence alone**, because there is
no old text whose absence could be counted; **which edits those are the plan classifies against the
real files**, an add-only edit being one whose site carries no wording the change removes. Neither
this section nor §4 classifies them: a list of item numbers here is the bookkeeping that has to be
re-derived whenever a span merges. **The plan builds each pair
against the real files and runs both directions there**, under two constraints: a counted
fragment must be **single-line in the file it is grepped from**, since one spanning a line break
makes `grep -F` count zero and read as a failure; and the new wording must therefore be
**installed unwrapped**.

**Why no fragment is named here, stated as a residual rather than repaired again.** Four
consecutive revisions of this spec listed them, and each list held at least one fragment that
could not do what it claimed: one preserved inside its own replacement, so its
old-wording-gone count could never reach zero; three quoted across their line wraps, so they
counted zero in a correct tree; one meaning-changing passage with no pair at all. The cause is
structural — an exact check for text that does not yet exist can only be guessed, and a wrong
guess reads as a failed check rather than a wrong one. **Nothing verifies that §4's list is
complete or that the plan's fragments discriminate.** The enumeration moved to where the text
exists; the completeness claim did not, because nothing supports it.

**The counterfactual splits, and stating it as one understates what is owed.** For the **ordering
and the two gate-closure paragraphs beside it** it is **ABSENT and is claimed as absent**: the
parent carries none of the three, so no old wording of them can be shown to disappear and presence
alone is the check. For **every replacement**
the parent carries the old wording and the change removes it, so each owes the
old-wording-gone half of its pair. **The obligation reaches every passage the target text marks
REPLACED, and no list of them is kept here** — a second enumeration beside the markers is the
bookkeeping that goes stale, which it did: the list this sentence used to carry omitted §G while
§G was marked REPLACED. **The plan reads the markers off the target text**, where the concrete
replacements live. **§F states the falsified standing sentences and their count**, and the plan reads
both off §F rather than from here; the count has moved at five passes and a copy of it here would
be stale again by the next. Nothing is
claimed as "contradictory" — the second of the two defects Gate B found in the `fic2` instrument.

**The named verification of the risk path** (story AC 4) is a **next-state table**, written in the
plan and quoted by the closing commit body. **Its claim is narrow and stated as such: it covers
answer-state transitions once the predicates producing them are established**, which is the first
`fic2` defect — a state's inputs must include every input the rule reads — answered by
restricting the claim rather than by widening the table. So the plan writes **separate named
checks** for what the table therefore does not establish: that a logical pass was validated
across every required branch file, and that **every closure condition the block states held at the
closing act**. That set is **not enumerated here** — an enumeration is how this section came to
name three of them while the block states more, which is pass 20 finding 4. **The plan reads the
set off the block and writes one check per condition**, and fails where the block states a
condition the plan has no check for. **No fixture per predicate is built**; that question is parked
in the story's §2 and is not reopened.

**That list is not exhaustive, and reading it as exhaustive is how the evidence entry would
overclaim.** Two further things the table does not establish, named because they are the ones a
reader would otherwise assume it covers: **how each predicate was derived** — the table takes a
row's predicates as given and checks the transition out of them, so a wrongly derived predicate
produces a row that passes; and **whether the enumerated rows cover every reachable combination**
of the clean, scope and health predicates — nothing enumerates that space, so a missing
combination is invisible rather than failing. Both stay unestablished here: closing either is the
parked fixture-per-predicate question, which this change does not reopen. **The evidence entry
states the table's claim at this width**, not wider.

**The oracle.** A row **fails** when its required answer does not produce a **distinct** resumable
or closed state — **the same stop returning with its reading unconsumed, that is, without an
intervening validated pass run after the answer** — or when it closes on anything other than the
route the block states. **The closure conditions are read from the block and not re-enumerated
here**: a re-enumeration is a second definition that drifts, and pass 15 found this list already
missing two of them. Concretely the row must **enter closure from the clean-completion branch**, a
zero-finding pass being an eligibility route inside that branch rather than a branch of its own — so a pass carrying a scope-stop trigger cannot close on the answer to that
trigger, no-clean-credit being the clean predicate's own second half — and every precondition the block names must hold
**when it is established, immediately before the closing act**, which is the window the block
fixes. **The oracle does not require a precondition to be re-read on what the act produces** — the
condition that would have demanded that left with the 2026-09-13 cut, and the gap it addressed is
recorded in the target text's §I rather than checked here. Naming only the distinct-state half would pass
the exact no-progress defect AC 4 cites from the parent cycle. **The
consumption clause is what keeps the oracle and the shipped text in agreement**: the target text's
§A says continue consumes the reading that raised the suspension and a further health suspension
needs it recomputed over a
pass run after the answer, so the *same* two-tell or clearly-stuck result **after** such a pass is
new data and a legitimate row, not a failed transition. An earlier wording failed it "whether or
not an input was consumed", which would have classified that legitimate case as a defect.

**Evidence entry**, in the closing commit body, names: the battery run; every pair the plan built
with its counts in each copy and each tree, and every presence check beside them; the §6 parity
diff and the `b11`/`b13` equivalence result; and the next-state table's location plus its row
count. It is revalidated before every Gate-B re-review and before the commit that gate's closing act
produces, as the target text's §F item 9a requires — the amend being one of the shapes that act
takes.

**One observability residual, stated because the lens set asks for it and nothing here answers
it.** A closing commit body records that a cycle closed and what its curve was; it records
**nothing about which exit the cycle took** — whether a scope stop, a clearly-stuck surface or
two tells ever suspended it, what was asked, or how it was answered. A reader of history cannot
audit that every suspension was answered before the cycle closed. Neither the evidence entry nor
the curve supplies this, and saying otherwise would be the overclaim `AGENTS.md` calls this
repo's most persistent defect. The transport that could carry it left with the record (§9), and
**no story has taken it** — naming one that has not is the same defect in a smaller place. An
**admitted gap of this change**: unowned, unguarded, open to whoever picks it up.

---
## 8. AGENTS.md invariants touched

- **Invariant 11 — `docs/prompt-standards.md`, all 12 items.** Most at risk: item 6, every
  constraint in the shipped block carrying its reason in the same sentence — **including the
  three exempted until pass 6**, which now carry theirs inline in the target text's §A: that no
  other pass outcome makes a cycle eligible to close, that a zero-finding pass is clean whatever
  the floor, and that decline is available only at a membership stop. The exemption was wrong twice over: item 6
  admits no "settled elsewhere" clause, and a scaffolded copy cannot reach the story the reasons
  were said to live in. The unknown-start clause carries its reason inline for the same reason.
  Then **item 8 (token-lean), which an earlier revision claimed on the wrong ground** — it said
  the block replaces closure sentences rather than adding beside them, while the block was in
  fact restating triggers, duties, preconditions and the severity answer that their own
  paragraphs still defined, which is two authorities per copy. The claim now rests on what the
  block does: **it owns the evaluation of a pass and what follows from it, as the target text's §A
  opening states that boundary** — not restated here, one statement of it being the point — and
  **cites** every other rule where that rule is defined, so each has one definition in the shipped
  text; **§4's site table is the check**. Then item 3 (the stop
  answer produces a named state, **parked**, with its own restart transition).
- **Don't: "Never replace a decision procedure without accounting for its old conditions."**
  Satisfied by the plan's per-condition disposition list against the committed inventory (§5),
  with this spec's passage map keeping the ten-passage set complete.
- **Don't: "Never rename or delete a doc section without grepping for references first."** The
  (g) sentence names the story path; the grep finds it at `CLAUDE.md:815` (the site itself)
  and in three artifacts of the parent cycle
  (`docs/superpowers/plans/2026-08-29-review-loop-economics-plan-a-rules.md:878`,
  `docs/superpowers/specs/2026-08-28-review-loop-economics-design.md:33`,
  `docs/superpowers/stories/2026-08-28-review-loop-economics-pass-floor-story.md:78`). All cite
  the story file, which continues to exist; none cites the sentence. Nothing breaks.
- **Invariant 12 — a plugin change requires a version bump.**
  `plugins/dev-workflow/commands/workflow-init.md` is under `plugins/`, so
  `plugins/dev-workflow/.claude-plugin/plugin.json` goes `0.11.0 → 0.12.0` with a
  `plugins/dev-workflow/CHANGELOG.md` entry: a minor bump, the template gaining a closure
  ordering and the edited or extended sentences §4 lists.
- **Invariant 4 / the hook.** Untouched: `plugins/dev-workflow/hooks/codex-gate.sh` is not
  edited, and the §5 heading it greps (`Cross-Model Review`) does not move.

**Every path in this spec is written repository-relative and in full** — no ellipsis shorthand
and no bare basename. An abbreviated citation fails the path-existence check a review pass runs
mechanically, and five of them did.

---
## 9. Moved, out of scope, and parked

**Moved to `docs/superpowers/stories/2026-09-10-record-durability-story.md`** on Daniel's
decision of 2026-09-10, with the evidence in §1:

- the `Accepted:`/`Declined:` answer record, its form, transport, attribution, recording point
  and squash carry (**D9**), the sameness test by which a later pass recognises the same
  finding (**D9b**), and the unverified-assertion reading (**D9c**);
- the pass-4 report's unavailable-history block (**D10**) and the checkout-root condition that
  report grew;
- the rollback reading — **what an open cycle owes when a revert removes the rules it started
  under**. This change does not answer it and no longer claims to. An earlier revision said the
  activation paragraph already supplies the transition; that is wrong in a specific way. A revert
  of this change removes the ordering, the source edits **and the unknown-start list's suspension-binding
  extension together**, so the stricter reading such a cycle would fall back to is itself part of
  what the revert takes away, and it no longer mentions the suspensions that cycle is holding.
  What remains is the pre-change §5 — the loose ordering this story exists to replace — read by a
  cycle that started under a different one. **Whether that is enough is unanswered here and
  nothing is shipped for it**, since no record identifies the rule revision a cycle started
  under. An admitted residual, and the successor's question;
- the slot-discriminator dissolution deferred here by Plan C's Tasks 19 and 20;
- **the partial-adoption guard as it applied to the record.** It was built as a "closure-record
  contract" naming the record, with a marker on every mergeable hunk, and it leaves with the
  record it was named for.

**Moved to the plan** — the implementation artifact, not a story: the per-condition disposition
list for all 135 inventoried conditions (§5); the OLD and NEW text of every §4 edit with its
line ranges (§4); the parity divergence list and the extraction-and-diff (§6); and every
verification fragment with its counts (§7). Each is work this change still owes; none of it is
work a spec can do correctly, because all four are checked against files the plan edits.

**Partial adoption — answered by the one-contract paragraph (target text §G), and what that answer is worth.**
The set is mutually dependent, and **the membership rule is stated once, in the target text's §G,
and is deliberately not restated here** — a second telling of it is a second definition, which is
pass 21 finding 5. §G reads what a live rule **states** rather than what changing it would do, and
it reaches a wider set than the paragraph did before: previously only the nonce, the slots, the
provenance line, the curve, the carry rule and the unknown-start semantics. **An earlier revision
of this section named the members as a list of item numbers and the list was wrong**, and a later
one defined membership here by the edits the block cites or depends on — a test decidable only
against this repository's own spec. Both are why the
rule is stated and **the plan derives the membership against the real files**, where dependence is
decidable and the numbering does not exist.

**Stated as what it is.** That paragraph is **an instruction to the agent**: a project whose text
carries some members and not others, or versions that disagree, **stops and has a human complete,
revert or reconcile the adoption before running a gate under it**. §G widens whom that
sentence is about. It is not a guard and not a mechanical check, and this change builds neither —
**nothing detects a partial adoption**, and the stop happens only where an agent reads the
sentence and acts on it.

**What it therefore does not buy, said rather than implied.** A project that adopts the block
without adopting that paragraph is not reached at all, which is the partial-adoption case applied to the
rule against partial adoption; the existing paragraph has the same property and the widening neither
worsens nor repairs it. Nor does it detect a *silent* half-merge in a project that did adopt it —
it obliges a stop once someone notices, which is a different thing from noticing. **What it
removes is the narrower state this spec previously admitted**: that the coherence rule did not
name this material at all, so an agent reading the sentence and willing to act on it had nothing
to act on. Two earlier revisions got this wrong in opposite directions — one claimed the existing
rule already caught the block, and one assigned the guard to the successor story, whose scope is
record durability and **excludes the closure ordering by name**. Both named a mechanism that did
not exist; §G names a sentence that does, and claims only what that sentence does.

**Out of scope and parked**, unchanged:

- The pass-counter anomaly (`fic2` record).
- The CodeRabbit plan-metadata contradiction (`fic2` record).
- The fixture-per-predicate question (`fic2` record; story §2).
- Hook code under `plugins/dev-workflow/hooks/`.
- `todos.md`: both-branches-misread-each-other; self-consuming-deletion (prompt-standards item
  11); the three bot findings in resolved plans.
