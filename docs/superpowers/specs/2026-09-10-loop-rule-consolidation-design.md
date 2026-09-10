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
which the design was 173, and the remaining 58% — quoted OLD and NEW text, per-condition
dispositions, the parity divergence list, the verification substrings — took roughly half the
findings of every Gate-A pass while describing work the plan performs against real files. **It
is moved, not dropped.** The plan is the carrier and each section below names what it owes.

---

## 1. Intent

**What ships.** One closure ordering, stated once in each copy, that says which exit *closes* a
cycle and which merely *suspend* it, in what order a pass is read so the ranking is executable
rather than asserted, what any set of suspensions at once does, and which of the four standing
duties participate in that ordering versus gate it as preconditions. With it: the answer to what
a severity demotion does to the loop-health counts, and the standing sentences the ordering
falsifies or leaves ambiguous if they are not edited at their source — **five outside the
inventoried passages and fifteen inside them, eighteen replacing a sentence and two adding
one**.

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

The story's §4 table is the design's starting point and is not restated here; each decision is
cited below as **D1**…**D8**. **D9**, **D9b**, **D9c** and **D10** stay settled and move to the
successor with the material they govern (§9). Two implementation facts the parent cycle
established are read as given: a pass's cleanliness is a fact about what that pass found and is
**never rewritten** — an answer changes whether the *cycle* may close; and the findings files
establish the **inventory** of findings, not their resolutions.

What the table does not settle, this spec decides in the section that uses it: the evaluation
order and the file set each predicate reads; the duties' classification; which stop each of the
scope stop's two triggers raises and what each answer does; what a clearly-stuck or two-tell
answer produces; and the raw-severity rule for the health measures. **It defines no trigger,
duty or severity rule of its own** — each keeps its one definition where that definition already
lives, and where one had to change to agree with the ordering it changed **at its source**.

**Twenty source edits**, counting **one edit per contiguous replacement or addition at one
site**, which is the unit because a single sentence can be replaced once and a list added to once
without either being two. §4 lists all twenty. The **closure-ordering block is an addition
beside them**, not one of the twenty, so a reader counting changes to the two copies counts
twenty-one.

---

## 3. The closure ordering — the block that ships

It sits in §5 **immediately before** the paragraph "**What a loop absorbs, and what stops it**",
in both copies, byte-identical. It states the ordering once; the paragraphs after it keep their
triggers and point at it. Verbatim as it will ship:

```
**How a cycle ends — one ordering, stated here and referenced everywhere else.** A pass is read
in a fixed order, because every rule bearing on one decision — may this cycle close — otherwise
qualifies the others and the ranking survives only in a reader's head. **This paragraph is
authoritative for that order and for closure, and for nothing else.** Every trigger, duty and
severity rule it names keeps its one definition where that definition already lives; a reader
who finds a rule defined here rather than cited has found a defect.

**What a pass is read from.** Every finding-derived predicate reads the validated findings file
**or files** of the logical pass as their **concatenation** — a `full` Gate-B pass has two, and
one branch alone is already an incomplete pass. **Which severity field each of them reads is
settled in Mechanics, Severity**, which is where that split lives and is not repeated here.
Beyond the findings, closure reads the **derived floor** and the final-acceptance preconditions
the floor section states, the **evidence entry's revalidation rule** — a changed entry meaning
the clean pass no longer covers what is being committed — and any **hold still standing**; the
scope triggers read the **current assigned fix set** as the absorb paragraph defines it, and the
answers already given; the clearly-stuck reading adds its own coverage judgement. **A line in
one branch file and a line in the other are distinct findings for holds and answers**, so a
`full` pass asks twice rather than risk resuming over one it never asked about. **Within one
running cycle an answer binds to the finding or question as the pass that raised it recorded
them** — which is what an agent running the cycle can do with nothing written down. Recognising
the same finding or question across a lost session needs a record these rules do not ship.

**First, clean completion.** §5 uses *clean* in two senses and now says which is which: a **clean
findings file** is the `NO FINDINGS` signal the protocol defines, and a **clean pass** is the
predicate here, read on the logical pass with every required branch file combined, so one
branch's clean file never establishes a clean pass. **A pass is clean** when its findings carry
no in-set Blocker or Major at effective severity and **no scope-stop trigger** — the two the
absorb paragraph defines, read there and not redefined here, each already carrying the
qualification an answer given in this cycle puts on it. Both are properties of the findings and
the set as that paragraph reads them, settled before any branch below runs, which is what makes
this order executable rather than asserted. A pass with **zero** findings is clean whatever the floor, because a floor buys further
looks at an artifact that keeps yielding findings, and one yielding none has already given what
those looks were for. **A clean pass at or above the derived floor, or a zero-finding pass, makes
the cycle eligible to close**, under those final-acceptance preconditions; **the closing amend
Mechanics · Finishing the cycle describes is the closure itself**, so nothing is closed before
it, and a profile, cited set or evidence entry that changes in between still gates it. A plateau
or tells on that pass go into the closing report and never block it, because reporting "will not
converge" on a converged loop is a false report. **No other pass outcome makes a cycle eligible
to close**, because every other pass leaves a required repair, a hold or a question outstanding,
or has an unmet closure precondition — and closing over any of those is the failure this ordering
exists to prevent. The one termination that is not a pass outcome is the Gate-B triviality skip,
which runs no passes and is outside this ordering.

**Second, only a pass that is not a clean completion can suspend** — that order is what makes
"clean completion outranks the two-tell stop" executable rather than asserted. Three suspensions,
by the names their paragraphs use and read by those paragraphs: the **scope stop**, raised by
either trigger above — a **membership stop** by the first, a **question stop** by the second; the
**clearly-stuck exit**; and the **two-tell stop**. A suspension waives nothing. Any non-empty set
of them can apply to one pass: **one surface, every reason reported, every question asked**,
because a reason left out is a decision made by omission. A finding the clearly-stuck reading
surfaces that also carries either trigger takes the scope stop's answers at that same surface, so
it is not asked twice; the two-tell stop surfaces tells and not a finding.

**Third, a pass that neither closes nor suspends continues** — the loop runs another pass on
the **current** artifact, revised where the severity and scope rules require a repair and
unrevised where they do not. A below-floor clean pass lands here **only where no suspension
applies to it**; where one does, the second branch has already taken it, because clean completion
did not close the pass and only closing outranks a suspension. So does a pass whose only findings
are Minors and Nits, which are collected and never iterated and may leave nothing to revise. It
is a branch and not an inference, because "does not close" read alone says nothing about whether
to run again.

**The four standing duties, classified.** The **derived floor** is a **precondition on closure**:
it gates closing, discharged by the count of valid logical passes reaching it with the last of
them clean, or by the zero-finding exit. The **Blocker/Major-resolve duty** is a **precondition
on closure and on any pass being clean**: Mechanics Severity, scoped to the assigned fix set,
states what it demands and what discharges it, and a validated pass finding **no in-set Blocker
or Major at effective severity** is what shows it discharged — the clean predicate's own wording,
so the two cannot drift. It is discharged by a **repair** or by a **validated dismissal**: the
author's judgement, carrying the one-line why this section already requires of a dismissed
finding, that the finding is not true of the artifact. A dismissal does not rewrite the pass that
found it, and the later clean pass is still owed. **A dismissal is not a decline**: a dismissal
says the finding is false, a decline is the user's decision that a **true** finding stays outside
the set, and only the second is an answer at a membership stop. **A dismissal the reviewer keeps
re-raising across passes is regeneration**, counting toward the clearly-stuck reading's third
condition — so a false positive that returns every pass reaches that suspension instead of
continuing forever. The **hold** a surfaced finding places on closure **participates in the
ordering**: it gates closing while it stands, and is discharged by the answers that surface
requires. **It attaches to every surfaced finding, whichever suspension surfaced it** — clean
completion creates none, because it wins before anything is surfaced. **No-clean-credit** — no
pass carrying a scope-stop trigger is credited as clean — also participates, and is a fact about
that pass that nothing discharges, a later pass being judged on its own findings. It is not a
second test beside the clean predicate but that predicate's second half, which is why it is
stated in its words.

**What a suspension asks, and what ends it.** **A hold ends when every answer its finding
requires has been given, in whichever direction each is given** — one **scope-stop** answer for a
single-trigger finding, both for one carrying both. That is **one rule with two parts**, how many
answers and which way each may go, and neither is a test the other has to pass. Where a health
suspension applies to the same pass, its shared continue-or-stop answer is **additional** to
those and not counted among them, the health readings asking about the loop rather than about
this finding. At a **membership stop** the answer is **accept**, the finding joining the fix set
where Mechanics Severity governs it, or **decline**, the finding staying outside and binding so
for the rest of this cycle. A later answer that contradicts a decline **does not reverse it**:
the decline **remains binding**, the contradiction is **surfaced to the user as information**,
and the **cycle continues** — nothing here turns one answer into another, since that would let a
finding be moved out of the set and back into it to escape what it owes inside it, and **D7**
admits no exception. What the user may do is **withdraw** the decline, which is not a reversal by
these rules but a fresh explicit decision by the same authority that declined; the finding then
takes the ordinary route at the next pass that raises it. Either answer is an **explicit,
attributable decision on that specific finding** — never silence, never a general remark about
scope, never inferred, because a fix set changed by inference is a fix set nobody chose.
**Membership is answered against the set as the absorb paragraph fixes it for the pass that
raised the question**: a later broadening is a new fact the **next** pass reads and never
discharges a standing hold, a hold discharged by a scope change being a hold nobody answered. At
a **question stop** the answer is the user's decision on the question and membership does not
change; an out-of-set finding that opened one is a membership stop as well. **Decline is
available only at a membership stop**, that being the only stop whose question is whether a
finding belongs to the set. The **clearly-stuck and two-tell readings** ask **continue or stop**.
**Continue consumes the reading that raised the suspension**: a further health suspension needs
that reading recomputed over a pass run after the answer, which is new data — so continue
produces a distinct next state, and the same reading cannot return the same stop unanswered. It
permits an **unrevised** artifact **only where no repair is owed**; where effective severity or
scope requires one, that repair comes before the post-answer pass, since a pass run over an
unrepaired in-set Blocker or Major spends a look on text the rules already say must change.
**Stop parks the cycle**: open, not running, spending no passes, restarted only by an
explicit later continue — a distinct state from the suspended-awaiting-answer one it was in
before the answer. Nothing a parked cycle wrote is a closing commit, and a parked cycle nobody
restarts is a human's to resolve, exactly as the nonce rules already say of open cycles.

**Composition, and what cannot happen.** Every **question** is answered on its own and the loop
resumes only when every answer resumes it — accept or decline at a membership stop, a decision at
a question stop, continue at the health readings; one stop answer parks the whole suspension,
because a loop resumed over an unanswered question decides it by running. **The clearly-stuck and
two-tell readings raise one question between them, not two**, both asking continue or stop, so
one answer carrying every reason ends both — an instance of the sentence before it, not an
exception. **Two pairings cannot occur**, and no rule ranks them: clean completion and a **scope
stop**, since that stop's triggers are the clean predicate's own second half, so a pass raising
one is not clean; and a zero-finding pass and any suspension, since it has nothing to surface,
nothing regenerating, no cluster and no require↔withdraw pair. **Clean completion and the
clearly-stuck exit can**, and the overlap is admitted rather than argued away: the two read
different severity fields, as Mechanics · Severity sets out, so an **in-set** Blocker or Major the
ceiling demotes below Major, or an **out-of-set** one this cycle has declined, can regenerate
across passes on a pass that is clean. **The order decides it and no new rule is needed.** The
clearly-stuck paragraph's own precedence sentence is stated here rather than there, because
precedence is evaluation order and this paragraph is where evaluation order is stated once; its
opening words point back to that paragraph, which is where the reading itself lives. That third
condition is what makes a plateau rather than a finish, and it is why **a clean completion takes
precedence over this exit**: a Blocker/Major-free pass **at or above the floor** has satisfied the
clean-final-pass rule — collect the Minors and Nits and close — and reporting "will not converge"
on a converged loop is a false report. Below the floor the pass **suspends**, clean completion
having not closed it.
```

Where the block maps onto the criteria: the three branches are AC 4, the duties paragraph
AC 2, the composition sentences AC 1.

**One authority per rule.** The block cites nine rules and defines none of them. Each has exactly
one definition in the shipped text, and where that definition had to change to agree with the
ordering, it changed **at its source** (§4) rather than being restated here:

| Rule the block cites | Its one definition |
|---|---|
| membership trigger | `b11`, the absorb paragraph, qualified by §4 |
| question trigger | `b13`, the absorb paragraph, qualified by §4 |
| the assigned fix set, and what is in it | `b7` and `b8`, the absorb paragraph, both edited by §4 |
| effective vs reviewer-written severity | the (g) replacement, in Mechanics · Severity |
| what a Blocker, Major, Minor or Nit demands | Mechanics · Severity, scoped by §4 |
| the derived floor and final-acceptance preconditions | the floor section |
| the evidence entry's revalidation rule | the profiles section, unedited |
| the clearly-stuck reading | the clearly-stuck paragraph |
| the two-tell threshold | the five-tells paragraph, qualified by §4 |

The scope stop's two triggers are `b11` and `b13` read separately, because an in-set finding
that opens a question can neither join nor stay outside the set and needs its own answer.

**One rule runs the other way, and it is the one exception to the table.** The clearly-stuck
exit's **precedence** against a clean completion is not part of that exit's reading; it is
evaluation order, which is the block's own subject. So `c9`'s sentence — the one **D3** requires
preserved verbatim — **moves into the block** rather than being cited from where it stood, and
the clearly-stuck paragraph keeps only its reading and points forward. Stated in both places, it
would be exactly the drift this table exists to prevent; stated only in the clearly-stuck
paragraph, it would put evaluation order somewhere the ordering does not govern. The sentence's
words are untouched by the move, and the block says whose sentence it is where it quotes it.

**Two things the ordering names and does not define, both the successor's** (§9): what makes a
later finding *the same one* this cycle declined, and what form carries an answer into the commit
body. The ordering says what an answer does; **D9b** and **D9** say how it is recognised across
sessions and written down. **Within one cycle the block supplies what it needs and says so**: a
line in each branch file is a distinct finding for holds and answers, and an answer binds to the
finding or question as the pass that raised it recorded them. Both sentences are in the block
above — the ordering claims no in-session consequence it does not state there.

---

## 4. The standing sentences edited at their source

Twenty edits. Each row names the sentence, where it lives, what changes and why, and whether it
is a replacement or an addition. **No OLD or NEW text and no line numbers appear here**: the plan
quotes each sentence from the real file, writes the replacement, and re-greps the site, for the
reason §7 gives. Working around any of these would ship two instructions that disagree.

| # | Sentence | Where | Change, and why | Kind |
|---|---|---|---|---|
| 1 | the findings-file protocol's clean sentence | the gate-prompt template both gates paste, C and W | it calls a `NO FINDINGS` file a *clean pass*; renamed a **clean findings file**, which is what it always described, so §3's predicate is not read as redefining it | replacement |
| 2 | the Gate-A clean-signal sentence | the Gate-A section, C and W | it makes the `NO FINDINGS` signal the only route to clean; it becomes what lets a pass be read as clean without inspecting it, since a pass carrying Minors alone is clean and could never produce that file | replacement |
| 3 | the Severity bullet's resolve duty | Mechanics · Severity, C and W | the only statement of the duty and the only one without a scope; scoped to **the assigned fix set**, the boundary **D5** implied and no sentence carried. It names the set and never a decline — AC 3's second half, since naming one here would read as a waiver of resolution rather than the membership decision it is | replacement |
| 4 | the lens paragraph's unchanged-list | the profiles section, C and W | it asserts the Blocker/Major filter and the clean-final-pass rule are unchanged, which the ordering falsifies; scoped to **the lens sets**, which is what that paragraph is about | replacement |
| 5 | the Gate-A cadence | the Gate-A section, C and W | "validate, revise, re-run" makes a revision unconditional, telling a Minor-only pass to manufacture the repair the severity rule forbids; the revision becomes conditional on a repair being required | replacement |
| 6 | `a17`–`a19`, the floor paragraph's closure sentences | passage (a), C and W | they state closure and the early exit in the paragraph that owns the floor; trimmed to point at the ordering, which states them once | replacement |
| 7 | `a13` | passage (a) | "no rule about how a cycle closes is restated" becomes categorically false once the ordering exists; scoped to that paragraph, which is what it was written to police | replacement |
| 8 | `a16` | passage (a) | "fix Blocker/Major after each" stands unscoped beside a Severity bullet item 3 now scopes; it points at that rule instead of restating an unscoped version | replacement |
| 9 | `b3` | passage (b), C and W | it points at Mechanics and then **restates the four severity actions**, giving them two definitions; it becomes a pure pointer. W's pointer also changes target, matching C (§6) | replacement |
| 10 | `b7`, the fix-set definition | passage (b) | singular "the approved story or plan" leaves a cycle governed by several with no set at all; it becomes their **union**, plus obligations already accepted, **minus this cycle's declines** | replacement |
| 11 | `b8`, the membership test | passage (b) | it tests a finding against "that scope" independently, so a broadened scope puts back a finding `b7` keeps out; it tests against **the assigned fix set as `b7` computes it** | replacement |
| 12 | `b11`, the membership trigger | passage (b) | unqualified, it and the clean predicate decide a re-raised declined finding in opposite directions; it excludes a finding this cycle has already declined | replacement |
| 13 | `b12` | passage (b) | it resumes on the membership answer alone; it says the answer ends the hold and **defers to the ordering** for what the pass does next | replacement |
| 14 | `b13`, the question trigger | passage (b) | *new* is undefined, so an answered question re-raised stops the loop again on every pass; *new* excludes a question already answered in this cycle | replacement |
| 15 | `b17`–`b18` | passage (b) | they state their own version of what ends a suspension; they name it a suspension and defer to the ordering | replacement |
| 16 | the clearly-stuck closure sentences | passage (c), from the third condition to the end | they carry evaluation order in the paragraph that owns the reading; the paragraph keeps its reading, and the precedence sentence moves into the block **word for word**, which is what satisfies **D3** | replacement |
| 17 | `e7`, the two-tell threshold | passage (e) | unqualified, it and the ordering decide a clean two-tell pass at or above the floor in opposite directions; it is read **after** the clean-completion branch. Authority **D2** | replacement |
| 18 | the five-tells pointer | passage (e) | the passage says nothing about what its answer does; one sentence names the stop a suspension and defers to the ordering | addition |
| 19 | the handed-over severity question | Mechanics · Severity, passage (g) | the paragraph says the demotion/loop-health question is unsettled and mandates a stop; replaced by the answer, which is the (g) text below | replacement |
| 20 | the unknown-start strict-reading list | passage (i) | the list of what a cycle takes at its strictest omits the suspensions this change ships; it gains **every suspension binding, since unknown starting rules cannot waive an open hold** — the reason carried inline, as prompt-standards item 6 requires of the clause itself | addition |

**Passage (g)'s replacement is design rather than bookkeeping, so it is stated here in full:**

```
  **The demotion changes what a cycle must resolve, never what it counts.** The per-pass
  counts, the finding clusters and the tell thresholds read the severity the reviewer wrote in
  the findings file, before the ceiling is applied: a demoted finding still counts in the
  finding total and in its cluster, and a Blocker demoted to Minor is still a Blocker to the
  curve. Cleanliness and the resolve duty read the effective severity, after the ceiling (the
  closure ordering above). Two reasons for the split. The curve must stay derivable from the
  findings files alone — counting finding lines and leading `BLOCKER` fields per pass
  reproduces it, which is the only thing that makes a self-reported curve checkable. And the
  demotion is the author's judgement about **the finding's repair severity**, never about
  which findings the fix set contains — a separate predicate the closure ordering defines, and
  one this must not be read as touching; a loop spending passes on findings the author keeps
  demoting is exactly what the prose-cluster tell exists to surface, and lowering the counts by
  that same judgement would hide it.
```

Two sentences are **not** edited and are named so nobody looks for them: the "Copy every record
into the squash body" sentence inside the human-exception block, and the "records every cycle
owes" list. This change ships no record.

---

## 5. The passage map, and who carries the accounting

**The plan carries the kept / moved / replaced / dropped disposition for every one of the 135
conditions in the committed inventory**, per passage, **beside the edit it belongs to** — which
is the only place it can be checked against the file being changed. **Story acceptance criterion
5 is satisfied by that list, not by this section**, and nothing here is dropped by being absent
here. This table says what happens to each inventoried passage, so the map stays complete at ten.

| Passage | This change | Edits (§4) |
|---|---|---|
| (a) the floor paragraphs | edited — closure sentences trimmed to a pointer, the no-restating prohibition scoped, the per-pass fix command pointed at Mechanics | 6, 7, 8 |
| (b) what a loop absorbs | edited — owns both triggers and the fix set, so every qualification the ordering needs is made **here**, which is what keeps one definition per rule | 9, 10, 11, 12, 13, 14, 15 |
| (c) recognizing clearly stuck | edited — keeps its three-condition reading, stops carrying evaluation order; its precedence sentence moves into the block unchanged | 16 |
| (d) from pass 4 onward | **no longer edited.** The unavailable-history block moved to the successor with **D10** | — |
| (e) the five tells | edited — the threshold is read after clean completion, and a pointer says what its answer does | 17, 18 |
| (f) the two rules above do not compete | **unchanged.** "The two rules above" still names the absorb rule and the stuck reading; the block sits before both and adds no third rule between them | — |
| (g) Mechanics · Severity, the handed-over question | edited — the unsettled statement and its interim report-and-stop duty are replaced by the answer, in both copies, removing the one deliberate story-path divergence | 19 |
| (h) recording a human exception | **no longer edited.** The answer-record block that was to follow it moved to the successor with **D9** | — |
| (i) when these rules bind | edited — the strict-reading list is added to, not rewritten | 20 |
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
false, so W takes C's wording (§4 item 9).

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
exists to prevent. An edit that only adds to a list — §4 items 18 and 20, and the block itself —
is checked by **presence alone**, because nothing is being replaced. **The plan builds each pair
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

The counterfactual is **ABSENT and is claimed as absent**: the parent carries no ordering block,
and passage (g)'s old sentence is the one site where the parent is present and the change removes
it. Nothing is claimed as "contradictory" — the second of the two defects Gate B found in the
`fic2` instrument.

**The named verification of the risk path** (story AC 4) is a **next-state table**, written in the
plan and quoted by the closing commit body. **Its claim is narrow and stated as such: it covers
answer-state transitions once the predicates producing them are established**, which is the first
`fic2` defect — a state's inputs must include every input the rule reads — answered by
restricting the claim rather than by widening the table. So the plan writes **separate named
checks** for what the table therefore does not establish: that a logical pass was validated
across every required branch file, and that each final-acceptance precondition the block cites
held — the floor, the cited set and profile, and the evidence entry's revalidation. **No fixture
per predicate is built**; that question is parked in the story's §2 and is not reopened.

**The oracle.** A row **fails** when its required answer does not produce a **distinct** resumable
or closed state — the same stop returning, whether or not an input was consumed — or when it
closes with **any** closure precondition unmet: an in-set Blocker or Major, a standing hold, an
unanswered question, the derived floor, a changed evidence entry, or a cited-set or profile change
during the pass. Naming only the first would pass the exact no-progress defect AC 4 cites from
the parent cycle.

**Evidence entry**, in the closing commit body, names: the battery run; every pair the plan built
with its counts in each copy and each tree, and every presence check beside them; the §6 parity
diff and the `b11`/`b13` equivalence result; and the next-state table's location plus its row
count. It is revalidated before every Gate-B re-review and before the closing amend, as §5
requires.

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
  three exempted until pass 6**, which now carry theirs inline in §3: that no other pass outcome
  makes a cycle eligible to close, that a zero-finding pass is clean whatever the floor, and that
  decline is available only at a membership stop. The exemption was wrong twice over: item 6
  admits no "settled elsewhere" clause, and a scaffolded copy cannot reach the story the reasons
  were said to live in. §4 item 20 carries its reason in the shipped clause for the same reason.
  Then **item 8 (token-lean), which an earlier revision claimed on the wrong ground** — it said
  the block replaces closure sentences rather than adding beside them, while the block was in
  fact restating triggers, duties, preconditions and the severity answer that their own
  paragraphs still defined, which is two authorities per copy. The claim now rests on what the
  block does: it is authoritative for the evaluation order and for closure and **cites** every
  other rule where that rule is defined, so each has one definition in the shipped text and §3's
  table is the check. Then item 3 (the stop answer produces a named state, **parked**, with its
  own restart transition).
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
  ordering and twenty edited or extended sentences.
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
  of this change removes the ordering, the source edits **and §4 item 20's suspension-binding
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
list for all 135 inventoried conditions (§5); the OLD and NEW text of all twenty edits with their
line ranges (§4); the parity divergence list and the extraction-and-diff (§6); and every
verification fragment with its counts (§7). Each is work this change still owes; none of it is
work a spec can do correctly, because all four are checked against files the plan edits.

**One residual this change owns rather than moves: partial adoption of the narrowed set.** The
set is mutually dependent — the ordering's clean predicate needs §4 item 3's boundary, its two
senses of *clean* need items 1 and 2, and its triggers need items 10 through 14 — and **nothing
catches a downstream merge that takes some of it**. Said exactly: the live one-contract paragraph
names the nonce, the slots, the provenance line, the curve, the carry rule and the unknown-start
semantics, and **it does not name this block or any of its coupled edits**, so its coherence rule
does not reach them. An earlier revision of this spec said that rule caught them; it does not, and
a project can take the clean predicate without the scoped resolve duty, or either sense of *clean*
without the other, and run. **That is an admitted unsafe state, not a guarded one, and it is this
change's own.** An earlier revision assigned the guard to the successor; that was wrong on the
face of the successor's own scope, which is record durability and **excludes the closure ordering
by name**, so the assignment named an owner that had not taken it — the same defect as claiming a
mechanism that does not exist. Nothing here builds one.

**Out of scope and parked**, unchanged:

- The pass-counter anomaly (`fic2` record).
- The CodeRabbit plan-metadata contradiction (`fic2` record).
- The fixture-per-predicate question (`fic2` record; story §2).
- Hook code under `plugins/dev-workflow/hooks/`.
- `todos.md`: both-branches-misread-each-other; self-consuming-deletion (prompt-standards item
  11); the three bot findings in resolved plans.
