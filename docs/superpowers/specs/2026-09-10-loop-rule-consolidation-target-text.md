# §5 loop-rule consolidation — target text, NOT ACTIVE

**Date:** 2026-09-11 · **Status:** target text under Gate A, not approved and **not installed**
**Story:** `docs/superpowers/stories/2026-08-29-loop-rule-consolidation-story.md`
**Design:** `docs/superpowers/specs/2026-09-10-loop-rule-consolidation-design.md`
**Profile:** read from the story header at every pass, never from here.

## What this file is, and why it exists

**This is the §5 text as it will read after this change** — not a description of edits to it.
`CLAUDE.md` and the `/workflow-init` template are **untouched**; nothing here is active, and no
rule below governs any running cycle.

It was produced at the pass-17 mandatory two-tell stop, on the reading that the cycle's cost was
**four parallel descriptions of one change** — the ordering block, an edit table, the source
sentences and the rationales — which had to agree with each other simultaneously, so a repair to
any one of them fell out of step with the other three. Seventeen Gate-A passes and a Blocker count
flat at 1 for four of them. Collapsing the four into **one concrete text** removes three of them.
The design spec keeps the decisions and their reasons; it no longer re-narrates this text as
future work.

**This is not a Gate-A close and claims to be none.** §5's clearly-stuck exit says surfacing does
not close a cycle, no pass is credited clean and the findings stay open; that is exactly the state
this file was written in. Gate A stays open and is re-aimed at this text, with pass 17's nine
findings as the basis. The rules are not activated by this file. Gate B reviews the real
implementation diff later, and this file is not that diff.

**How to read a section.** Sections **A**–**H** carry proposed text and each is marked **NEW** or
**REPLACED**; a passage reproduced unchanged is labelled CARRIED where one appears. **§I is not
proposed text** — it is this file's own metadata and ships nowhere. A CARRIED passage
is reproduced from the current state unchanged, because the block cites it and a reader has to see
what it says; it is here to be read, not to be edited. Both prompt copies take every NEW and
REPLACED section **byte-identical**.

**What is deliberately not here:** the record-durability material (successor story), and the
per-condition disposition, parity diff and verification fragments (the plan, against real files).

---

## A. The closure ordering — NEW

Sits immediately before "**What a loop absorbs, and what stops it**" in both copies.

```
**How a cycle ends — one ordering, stated here and referenced everywhere else.** A pass is read
in a fixed order, because every rule bearing on one decision — may this cycle close — otherwise
qualifies the others and the ranking survives only in a reader's head. **This paragraph owns how a
pass is evaluated and what follows from that**: the evaluation order, **what each predicate is
read from**, closure and its eligibility, the hold a surfaced finding places and what discharges
it, the composition of several suspensions, the pairs that cannot co-occur, and — as a stated
exception, because precedence is evaluation order — the clearly-stuck precedence sentence quoted
into it below. **No number is put on that list.** Whether the read model counts as part of the
evaluation order or as a thing beside it is a question of wording, not of authority, and a count
turns that wording into an argument about whether the paragraph has overrun its own boundary. **Everything else it names it cites**:
the scope triggers, the assigned fix set, every severity rule, and every closure precondition
**that has a source of its own** keep their one definition in the paragraph that owns them, and a
reader who finds one of *those* defined here has found a defect. **The closing-time sameness
tests below are defined here and are not an exception to that**: they borrow no rule and have no
other source, being part of the closure decision this paragraph owns rather than a precondition
stated elsewhere and read from here.

**What a pass is read from.** Every finding-derived predicate reads the validated findings file
**or files** of the logical pass as **the concatenation of their finding lines after each file
has been validated separately** — a `full` Gate-B pass has two, one branch alone is already an
incomplete pass, each file's terminator is not a finding line, and a branch whose body is
`NO FINDINGS` contributes an empty sequence rather than a line. **Which severity field each
predicate reads is settled in Mechanics · Severity**, which is where that split lives and is not
repeated here. Beyond the findings, closure reads the **derived floor**, the final-acceptance
preconditions the floor section states, the **resolve duty's standing over this cycle**, and any
**hold still standing**; **in a Gate-B cycle it also reads the evidence entry's revalidation
rule** — a changed entry meaning the clean pass no longer covers what is being committed — which
is a Gate-B precondition because the entry is about the diff being committed and a Gate-A cycle
produces none. The scope triggers read the **current assigned fix set** as the absorb paragraph
defines it, and the answers already given; the clearly-stuck reading adds its own coverage
judgement. **A line in one branch file and a line in the other are distinct findings for holds
and answers**, so a `full` pass asks twice rather than risk resuming over one it never asked
about. **Within one running cycle an answer binds to the finding or question as the pass that
raised it recorded them** — which is what an agent running the cycle can do with nothing written
down. Recognising the same finding or question across a lost session needs a record these rules
do not ship.

**First, clean completion, and eligibility is its own test.** §5 uses *clean* in two senses and
now says which is which: a **clean findings file** is the `NO FINDINGS` signal the protocol
defines, and a **clean pass** is the predicate here, read on the logical pass with every required
branch file combined, so one branch's clean file never establishes a clean pass. **A pass is
clean** when its findings carry no in-set Blocker or Major at effective severity and **no
scope-stop trigger** — the two the absorb paragraph defines, read there and not redefined here,
each already carrying the qualification **an answer given before that pass ran** puts on it.
**A pass's cleanliness is settled on what it found and on the answers standing when it ran**, and
a later answer never rewrites it: an answer discharges the holds it was asked for and leaves the
pass that raised them exactly as clean or unclean as it was, which is the same fact the duties
paragraph states of no-clean-credit. Reading a later answer back onto an earlier pass would let a
cycle close on a pass that was surfaced, answered and never re-run. A pass with
**zero** findings is clean whatever the floor, because a floor buys further looks at an artifact
that keeps yielding findings, and one yielding none has already given what those looks were for;
don't manufacture findings to pad.

**Eligibility is exactly this and nothing more: a clean pass at or above the derived floor, or a
zero-finding pass.** It is a property of the pass. **Closure is eligibility plus every closure
precondition holding plus the cycle's closing act**, and the preconditions are properties of the
*cycle*, not of the pass — so an eligible pass whose preconditions are unmet closes nothing, and
is not thereby made unclean. Keeping the two apart is what lets the order decide the case where
they disagree, which the branches below do.

**The closing act, by cycle kind.** A **Gate-B** cycle closes with the closing amend
Mechanics · Finishing the cycle describes. A **Gate-A** cycle has no WIP snapshot to replace, so
it closes by **writing the closing commit — or the closing message of one that already exists —
carrying the records this cycle already owes**: its provenance line and its per-pass curve, in the
forms Mechanics fixes, **neither of them altered**. **Closure introduces no new kind of record, and
it excuses none**: every other record this cycle owes, a human-exception record among them, is
owed and written exactly as before. Writing that body once every closure condition holds is the
closing act, and nothing before it closes anything.

**The order is fixed, and the second step never repairs the first.** **First** every closure
condition is established, among them that **the artifact as it now stands carries the text that
went into the final pass's review request, unchanged**. **Only then** is the closing act performed,
and the shape it takes is read off the repository as it stands. **That reading decides how a cycle
closes, never whether it may**: where the artifact has moved since that request, the sameness
condition has already failed, the pass is not final and another is owed — and **putting the request's
old text back is not a way through**, being a revision no pass has run against.

**Two cases, told apart by the repository's current state rather than by which commit introduced
what; the safe git sequence for each belongs to the plan.**
- **`HEAD` already carries that text at the artifact path.** Close by **amending `HEAD`'s message**
  to add the records. Nothing at the artifact path moves.
- **`HEAD` does not, the reviewed text being still uncommitted.** **Commit it unchanged** and close
  in that commit. This case had no answer before: an eligible pass over repairs nobody had
  committed could neither close nor suspend.

**What the sameness condition is, and all it is.** It compares the artifact against **the text
included in the final pass's review request** — not against a commit name, and **not against what
the reviewer consumed**, which nothing here establishes: Gate A hands the reviewer text rather than
a git range, so no part of this act is offered as evidence of the review payload.

**A human-exception record this cycle owes goes in the commit its closing act uses**, so the two
never land in different places. **No new revision of the artifact is made to close a Gate-A
cycle**, a new revision being one no pass has run against — and committing already-reviewed text
that was never committed is not one. Nothing is
closed before that act, and
what changes in between still gates it: the **profile**, the **cited set**, the **assigned fix
set**, the **artifact measured against the final pass's request text**, and — in a Gate-B cycle —
the **evidence entry**. Any of them differing at the closing act makes that pass non-final and
owes another, which is the same answer a mid-pass change already gets. **Sameness is read on the
artifact and the duties, never on the branch tip**: writing the closing body is itself a commit,
so a commit that only records the closure changes neither, while an edit to the artifact or a
broadening of the set changes one and costs the pass. **A commit the hook reads as cycle-closing is a separate matter**: a non-`WIP` commit
mid-cycle makes the hook read the cycle as closed and discards the passes counted so far, which
is an observation about the counter — the cycle itself stays open until the conditions above
hold, so an accidental commit destroys the pass credit and closes nothing. A plateau or tells on
**the pass that closes** go into **that pass's status report to the user** — the carrier the
three-line duty already names, and no second report form is introduced — and never block it,
because reporting "will not converge" on a converged loop is a false report; on an eligible pass
that does **not** close they go into the same place, a pass reporting what it read of the loop
whether or not it closes. **No other pass outcome makes a cycle eligible
to close**, because every other pass either leaves a required repair, a hold or a question
outstanding **or has not reached the floor** — and closing over any of those is the failure this
ordering exists to prevent. The floor is named separately because a below-floor pass whose only
findings are Minors leaves nothing outstanding and is still not eligible. The one termination
that is not a pass outcome is the Gate-B triviality skip, which runs no passes and is outside
this ordering.

**Second, only a pass that is not a clean completion can suspend — and *clean completion* here
means the whole first branch, eligibility included.** So a clean pass **below** the floor is not
a clean completion and can suspend, while an **eligible** pass cannot, whatever its preconditions
do. That is what makes "clean completion outranks the two-tell stop" executable rather than
asserted, and cleanliness alone never decides it. Three suspensions,
by the names their paragraphs use and read by those paragraphs: the **scope stop**, raised by
either trigger above — a **membership stop** by the first, a **question stop** by the second; the
**clearly-stuck exit**; and the **two-tell stop**. A suspension waives nothing. Any non-empty set
of them can apply to one pass: **one surface, every reason reported, every question asked**,
because a reason left out is a decision made by omission. A finding the clearly-stuck reading
surfaces that also carries either trigger takes the scope stop's answers at that same surface, so
it is not asked twice; the two-tell stop surfaces tells and not a finding.

**Third, a pass that neither closes nor suspends continues** — the loop runs another pass on the
**current** artifact, revised where the severity and scope rules require a repair and unrevised
where they do not. **An eligible pass with an unmet closure precondition lands here**: clean
completion did not close it, and being eligible it cannot suspend, so the loop continues on whatever
the unmet precondition requires — most often a repair still owed from an earlier pass.
**Where that precondition's own source prescribes stop-and-surface instead** — a profile present
but unresolvable, governing headers that disagree, a `Story:` header that cannot be read — **the
cycle stays open, that source decides what must be repaired or answered, and no further pass runs
while its block stands.** It is neither a suspension nor a continue, and it needs no name and no
procedure of its own: the source rule already carries both, and the ordering's part is to send the
reader there rather than to run a pass over a cycle another rule has stopped. A
below-floor clean pass lands here too, **only where no suspension applies to it**; where one does,
the second branch has already taken it, because clean completion did not close the pass and only
closing outranks a suspension. So does a pass whose only findings are Minors and Nits, which are
collected and never iterated and may leave nothing to revise. It is a branch and not an inference,
because "does not close" read alone says nothing about whether to run again.

**The four standing duties, classified.** The **derived floor** is a **precondition on closure**:
it gates closing, discharged by the count of valid logical passes reaching it with the last of
them clean, or by the zero-finding exit. The **Blocker/Major-resolve duty** is a **precondition on
closure**: Mechanics · Severity, scoped to the assigned fix set, states what it demands and what
discharges it — a repair or a validated dismissal — and what a dismissal is, all at that source.
**It is discharged per finding and tracked across the cycle, never inferred from a later pass.** A
findings file establishes the **inventory** of what that pass found and not the resolution of
anything, so a later pass that does not mention an earlier in-set Blocker or Major says nothing
about whether it was repaired or dismissed; reading its absence as discharge would let an omission
close a cycle. **The duty is not a second test on whether a pass is clean, and the two are not run
together.** A pass is clean on its own findings. Stated as the case that separates them, because a
reader who conflates them decides it wrongly: **pass 1 raises an in-set Major; it is neither
repaired nor dismissed; pass 2 finds nothing.** Pass 2 **is** clean, and at or above the floor it
is **eligible** — and the cycle **still cannot close**, the duty being unmet; it continues on the
third branch until that Major is discharged. What the open Major does *not* do is make pass 2
unclean. The **hold** a surfaced finding places on closure **participates in the ordering**: it
gates closing while it stands, and is discharged by the answers that surface requires. **It
attaches to every surfaced finding, whichever suspension surfaced it** — clean completion creates
none, because it wins before anything is surfaced. **No-clean-credit** — no pass carrying a
scope-stop trigger is credited as clean — also participates, and is a fact about that pass that
nothing discharges, a later pass being judged on its own findings. It is not a second test beside
the clean predicate but that predicate's second half, which is why it is stated in its words.

**What a suspension asks, and what ends it.** **A hold ends when every answer its finding requires
has been given, in whichever direction each is given** — one **scope-stop** answer for a
single-trigger finding, both for one carrying both. That is **one rule with two parts**, how many
answers and which way each may go, and neither is a test the other has to pass. Where a health
suspension applies to the same pass, its shared continue-or-stop answer is **additional** to those
and not counted among them, the health readings asking about the loop rather than about this
finding. **The two health readings differ in what they surface, and therefore in what they hold.**
The **two-tell stop surfaces tells and no finding**, so it creates no hold; what it leaves
outstanding is its own continue-or-stop question, which the composition rule below holds the cycle
on until it is answered. The **clearly-stuck reading surfaces findings** — **the findings of the
pass being read that satisfy its regeneration condition, and only those**; earlier members of a
regeneration chain that were repaired or dismissed are history the reading consults and never
findings it re-surfaces, so no discharged finding takes a second hold. Each surfaced finding takes
a hold like any other. **A re-raised valid dismissal stays discharged for the resolve duty** — the
dismissal was the resolution and a reviewer repeating the finding does not undo it, so no second
dismissal is owed — and what the recurrence creates is the **clearly-stuck hold**, ended by
that reading's continue-or-stop answer. Any trigger the recurrence independently carries raises its
own stop as usual. **Where one finding is surfaced by both, it carries two hold components and
each is discharged by its own answer**: the **membership**
component ends on the membership answer **in either direction**, a decline releasing it exactly as
an accept does; the **clearly-stuck** component ends on the reading's continue-or-stop answer. Neither
answer discharges the other's component, and where the finding carries no scope-stop trigger the
continue-or-stop answer is the only one its surface asks for and discharges the only component
there is. **Resumption is still the composition rule's**, which waits for every outstanding
answer. At a **membership stop** the answer is **accept**, the finding joining the fix set where
Mechanics · Severity governs it, or **decline**, the finding staying outside and binding so for
the rest of this cycle. A later answer that contradicts a decline **does not reverse it**: the
decline **remains binding** and the contradiction is **surfaced to the user as information**,
changing neither membership, nor the cycle's state, nor any outstanding question — **whether the
loop resumes is decided by the composition rule below and by nothing here**, so a contradictory
answer is never itself a resumption and cannot step past a hold or a health question still
awaiting its own answer. Nothing here turns one answer into another, since that would let a
finding be moved out of the set and back into it to escape what it owes inside it. **There is no
withdrawal inside the cycle that declined**, a decline binding for the remainder of
its cycle and admitting no exception; a reconsideration is a later cycle's, where that decline has
no effect at all and the finding takes the ordinary route. Either answer is an
**explicit, attributable decision on that specific finding** — never silence, never a general
remark about scope, never inferred, because a fix set changed by inference is a fix set nobody
chose. **Membership is answered against the set as the absorb paragraph fixes it for the pass that
raised the question**: a later broadening is a new fact the **next** pass reads and never
discharges a standing hold, a hold discharged by a scope change being a hold nobody answered. At a
**question stop** the answer is the user's decision on the question and membership does not
change; an out-of-set finding that opened one is a membership stop as well. **Decline is available
only at a membership stop**, that being the only stop whose question is whether a finding belongs
to the set. The **clearly-stuck and two-tell readings** ask **continue or stop**. **Continue
consumes the reading that raised the suspension**: a further health suspension needs that reading
recomputed over a pass run after the answer, which is new data — so continue produces a distinct
next state, and the same reading cannot return the same stop unanswered. It permits an
**unrevised** artifact **only where no repair is owed**; where effective severity or scope requires
one, that repair comes before the post-answer pass, since a pass run over an unrepaired in-set
Blocker or Major spends a look on text the rules already say must change. **Stop parks the
cycle**: open, not running, spending no passes, restarted only by an explicit later continue — a
distinct state from the suspended-awaiting-answer one it was in before the answer. **That continue
restarts the cycle and never skips an answer**: where any question the suspension raised is still
outstanding, it returns the cycle to suspended-awaiting-answer, and only once every answer the
composition rule requires has been given does the next pass run. So a cycle parked with an
unanswered membership or question stop cannot be continued into a pass, and cannot sit parked with
no transition either — the continue is always available and always moves it. Nothing a parked
cycle wrote is a closing commit, and a parked cycle nobody restarts is a human's to resolve,
exactly as the nonce rules already say of open cycles.

**Composition, and what cannot happen.** Every **question** is answered on its own and the loop
resumes only when every answer resumes it — accept or decline at a membership stop, a decision at
a question stop, continue at the health readings; one stop answer parks the whole suspension,
because a loop resumed over an unanswered question decides it by running. **The clearly-stuck and
two-tell readings raise one question between them, not two**, both asking continue or stop, so one
answer carrying every reason ends both — an instance of the sentence before it, not an exception.
**Two pairings cannot occur**, and no rule ranks them: clean completion and a **scope stop**, since
that stop's triggers are the clean predicate's own second half, so a pass raising one is not clean;
and a zero-finding pass and any suspension, since it has nothing to surface, nothing regenerating,
no cluster and no require↔withdraw pair. **Clean completion and the clearly-stuck exit can**, and
the overlap is admitted rather than argued away: the two read different severity fields, as
Mechanics · Severity sets out, so an **in-set** Blocker or Major the ceiling demotes below Major can regenerate across passes on
a pass that is clean. **A declined finding is not a route into that reading**: the third condition
admits regeneration across repair attempts and a re-raised validated dismissal, and a decline is
neither — it is the user's decision that a *true* finding stays outside the set, and it binds
for the cycle. **The order decides it and no new rule is needed.** The clearly-stuck paragraph's own
precedence sentence is stated here rather than there, because precedence is evaluation order and
this paragraph is where evaluation order is stated once; its opening words point back to that
paragraph, which is where the reading itself lives. That third condition is what makes a plateau
rather than a finish, and it is why **a clean completion takes precedence over this exit**: a
Blocker/Major-free pass **at or above the floor** has satisfied the clean-final-pass rule —
collect the Minors and Nits and close — and reporting "will not converge" on a converged loop is a
false report. Below the floor the pass **suspends**, clean completion having not closed it.
```

---

## B. Passage (b) — what a loop absorbs — REPLACED, common span

**This is the passage's common replacement span, written out as it will read** — the run both
copies take byte-identical, from the paragraph's opening through its closing rationale. **It stops
short of the paragraph's last sentence**, the field-mint parenthetical, which closes this
paragraph in `CLAUDE.md`, is absent from the template, and is left exactly as each copy has it.
That divergence is pre-existing; this change neither creates nor removes it, and the plan's
divergence list carries it. Earlier revisions split this passage's replacements across two
sections and left one sentence half in each, which is how §B and §H came to instruct the plan
differently about the same clause. **The replacement bytes for this passage appear here and
nowhere else in this file** — other sections cite what this paragraph defines, as §A cites the fix
set and the two triggers, and citing is not a second copy.

**Changed:** `b3`, `b7`, `b8`, `b11`, `b12`, `b13`, `b16`, `b17`–`b18`. **Carried:** every other
sentence. The rationales follow the text.

```
**What a loop absorbs, and what stops it — a question of scope, not of action.** A finding
that corrects the correction you just made **and stays inside the assigned fix set** is
**inside this loop's scope**: keep it here rather than handing it back, then act on it by its
severity exactly as Mechanics · Severity says. Ancestry decides where a finding belongs; it
never decides what you do with it, and it grants no Minor or Nit a repair round it would not
otherwise get. **The assigned fix set is fixed before the pass you are answering: it is the
union of the scope every approved story or plan governing this change assigns to this cycle,
plus repair obligations you already accepted in earlier passes, minus every finding this cycle
has declined.** A finding is in-set when repairing it stays inside **the assigned fix set as
just defined** — never merely because it arrived in the current pass, which would put every new
finding in the set by definition and leave the boundary deciding nothing. Where membership is
genuinely unclear treat the finding as **outside**, which costs a question and never a silent
expansion. **A correction that leaves that set stops the loop like any other out-of-scope
finding** — except one this cycle has already declined, which is outside the set by that
decision and **raises no membership trigger on that account**, its membership being the one
question already answered — even when it opens no new question at all, and the membership
answer ends that finding's membership hold; **what the pass does next is the closure
ordering's**, which resumes only when every answer outstanding on that surface has been given.
A finding that opens a **new structural or contract question** — new meaning not already
answered in this cycle, so an answered question raised again stops nothing — stops the loop and
goes to the user — **size is not the test, novelty of the question is**, so a structural finding
that is genuinely small still stops it, while a long correction still aimed at the last
correction does not — provided that correction, too, stays inside the set, which its ancestry
never supplies on its own. **When a finding is both** — it corrects the last correction *and*
opens a new structural or contract question — **the new question wins and the loop stops**:
novelty overrides correction ancestry, because absorbing on ancestry is exactly how a contract
decision gets made without anyone choosing it. **Novelty overrides ancestry and nothing else:
where the finding is also out of set, both triggers hold and both answers are owed**, since a
question answered about a finding nobody placed in or out of the set leaves its membership
decided by default. Stopping this way is **not an exit from the gate**: it is a **suspension**
in the closure ordering's sense, the floor, the Blocker/Major filter and the clean-final-pass
rule all stand, and what the answer does is stated there — what the stop prevents is a loop
committing you to a design you never chose, which is a different failure from an unfinished
review.
```

*Why `b3`:* the four severity actions are restated beside a pointer to the section that defines
them, which is two authorities per copy. The template took C's wording on the inventory's
reasoning that it has no Mechanics section, which is false.

*Why `b7`:* the singular "the approved story or plan" leaves a cycle governed by several with no
set at all, and a declined finding has to leave the set or the resolve duty reaches it.

*Why `b8`:* tested against "that scope" independently, a broadened scope puts back a finding the
set-defining sentence keeps out. It reads "as just defined" and not by condition id, an inventory
id being this file's vocabulary and meaningless in the installed prompt.

*Why `b11` (pass 19 finding 3):* unqualified, the exception and the clean predicate decide a
re-raised declined finding in opposite directions. Scoped to the **membership** trigger, since
that is the question the decline answered; the question trigger in the next sentence is
independent and reaches a declined finding like any other.

*Why `b12`:* it is the immediate-resumption command, **replaced** rather than appended to, because
the ordering resumes on every outstanding answer and not on one.

*Why `b16` (pass 17 finding 4):* without the added clause an agent follows the surviving source,
asks only the structural question, and absorbs out-of-set work silently.

*Why `b17`–`b18`:* the stop is named a suspension and defers to the ordering rather than restating
what ends it.

---

## C. Passage (c) — recognizing clearly stuck — REPLACED, from the third condition

**The three-condition sentence entire**, so nothing here begins mid-clause. **Changed within it:**
the third condition gains the re-raised-dismissal clause. The plateau and coverage conditions are
carried word for word. Of the two sentences after it, the first is the live sentence's opening
clause left standing alone — its second half, the precedence sentence, moves into the block — and
the second is new.

```
So this exit needs three things **together**, and a missing one means keep going: a plateau
visible across passes (six or more is where the field saw one); an **affirmative judgement that
coverage is sufficient**, stated — a known materially unreviewed area forbids this exit outright,
and disclosing it does not license it; and **Blocker or Major findings that keep regenerating
across genuine repair attempts**, each round's fix producing the next — **or a finding the author
has validly dismissed that the reviewer re-raises across passes**, the re-raise standing in for
the regenerating fix, since a dismissal gets no repair and produces none and a false positive that
returns every pass would otherwise leave the cycle unable to close and unable to suspend. That
third condition is what makes a plateau rather than a finish. **Where this reading and a clean
completion both apply, the closure ordering decides it** — the precedence sentence lives there,
because precedence is evaluation order.
```

*What follows in the live paragraph, and the two are not treated alike (pass 19 finding 8).* The
**precedence sentence** moves into the block above **word for word**, which is what satisfies
**D3**. The **below-the-floor sentence does not move at all — it is replaced**: it says a
Blocker/Major-free pass below the floor carrying a Minor "keeps looping", while the ordering
splits that case, such a pass **suspending** where any suspension applies to it and **continuing**
where none does. Its two halves live in the ordering's second and third branches, and no copy of
the live wording survives beside them — carrying it word for word would install an unconditional
continuation next to the conditional one and give the same pass two answers.

---

## D. Passage (e) — the five tells — REPLACED, in part

**`e7`, the threshold.** Gains one clause; the sentence is given entire.
```
**Any two present makes stop-and-surface mandatory, not discretionary** — read **after** the
clean-completion branch of the closure ordering, which outranks it — and you report the
tells and hand the decision to the user, and the "clearly stuck" reading above is not a
precondition for it.
```

**A pointer is added** at the end of the passage:
```
**What the answer does** is the closure ordering's, which is where this stop's place among the
suspensions and what its answer produces are both stated.
```

---

## E. Mechanics · Severity — REPLACED, in part

**The resolve duty, which is the only statement of it.**
```
- **Severity:** Blocker (wrong/unsafe/breaks invariant) · Major (design flaw → rework) → both
  must resolve, **for every finding in the assigned fix set as the absorb paragraph computes it**.
  **A finding is resolved by a repair or by a validated dismissal** — the author's judgement,
  carrying the one-line why this section already requires, that the finding is not true of the
  artifact. A dismissal does not rewrite the pass that found it and the later clean pass is still
  owed; **a dismissal is not a decline**, a dismissal saying the finding is false and a decline
  being the user's decision that a **true** finding stays outside the set. Minor · Nit → collect,
  never iterate.
```

**The handed-over question, replaced by its answer.**
```
  **The demotion changes what a cycle must resolve, never what it observes.** **Every loop-health
  reading observes the findings as the reviewer produced them, before the ceiling is applied** —
  so a demoted finding still counts in the finding total and in its cluster, and a Blocker demoted
  to Minor is still a Blocker to the curve and still regeneration to the clearly-stuck reading's
  third condition. Where such a reading uses severity at all it takes the **reader-normalized
  pre-ceiling severity**, which is what the Reader paragraph above already produces from the
  findings file — case-folded, and a non-empty unrecognized token read as `MAJOR` — never the raw
  token, so a finding written `IMPORTANT` enters the curve as a Major. **The ceiling is applied
  after that and only to what the cycle owes**: cleanliness and the resolve duty read the
  effective severity, so the same finding can be a Major to the curve and a Minor **at effective
  severity**, and that difference is the point rather than a discrepancy. It stays in the fix set
  either way; the ceiling moves what the cycle owes for it and never whether it is in. The line is **what the cycle owes
  versus what it observes about itself**, which is why no list of readings has to be kept complete
  here. Two reasons for the split. The curve must stay derivable from the findings files alone —
  the finding total counts finding lines and the Blocker and Major series count the lines whose
  normalized severity is each, which is the only thing that makes a self-reported curve checkable;
  the subject clusters use no severity at all, being a judgement per finding that no count
  reproduces. And the demotion is the author's judgement about **the finding's repair severity**,
  never about which findings the fix set contains — a separate predicate the absorb paragraph
  defines, and one this must not be read as touching; a loop spending passes on findings the
  author keeps demoting is exactly what the prose-cluster tell exists to surface, and lowering the
  counts by that same judgement would hide it.
```
*Why the last sentence of the previous draft went (pass 17 finding 6):* it claimed `IMPORTANT`
counts for the curve "exactly as it counts for the pass", which is false wherever the ceiling
demotes it — the two counts are meant to differ.

---

## F. The seven standing sentences this change falsifies — REPLACED

Each is a live sentence that the block makes wrong. All seven are **known contradictions** and
none is deferred. **Five of them share one mechanism** — an entry point other than the ordering
carrying an unqualified instruction — which is why each is **replaced** rather than given an
exception to point at.

**1. The `WIP:` naming warning** (Mechanics · `baseSha`).
```
A pre-review snapshot named anything else reads to the hook as a real commit: the hook treats the
cycle as closed and **discards the passes you just accumulated**, while the cycle itself stays
open until the closure ordering's conditions hold. The cost of the mistake is the lost pass
credit, not a close nobody intended.
```
*The sibling sentence in the profile-change paragraph needs no edit* — it already says such a
commit "reads **to the hook** as the cycle closing", which claims no closure.

**2. The Gate-B coverage instruction** (Gate B section).
```
Same coverage rule as Gate A: put "report every finding with severity and confidence; write
`NO FINDINGS` only when the branch found none" in `additionalContext`, with the same one-line
format. You filter to Blocker/Major, Codex never does.
```
*Why (pass 17 finding 5):* "say `NO FINDINGS` if clean" plus the ordering's clean-pass-with-Minors
tells a reviewer to emit an empty file over real Minors.

**3. The curve's Majors rationale** (Mechanics, the per-pass curve).
```
**Majors are recorded as well as Findings and Blockers**, because the three series are read
before the ceiling and the mix among them is what a later reader compares; the ceiling moves what
a cycle owes and leaves these counts alone, so totals and Blockers alone could not show even a
change in the mix.
```
*Why (pass 17 finding 7):* the live rationale says the severity rule "moves the Blocker/Major
line rather than the total", which contradicts the pre-ceiling decision above.

**4. The human-exception scope sentence** (Mechanics, recording a human exception). It wraps
across C 1014–1015 and W 1198–1199.
```
Those have their own terminal actions and this paragraph changes none of them: on a STOP you
still stop, and **neither a human's general assent nor this record** lets an agent close or
continue a cycle. **The answer a suspension asks for is not assent of that kind**: continue and
stop are the answers the closure ordering prescribes, given on the question that suspension
raised, and what each produces is stated there.
```
*Why (pass 19 finding 4):* the live sentence says no human answer lets an agent continue a cycle,
while the ordering makes **continue** the prescribed answer that restarts a parked one. Left as
it stands, an agent following it refuses the exact transition the ordering requires. The
distinction the repair draws is between a human waving a rule through — which this paragraph
still forbids — and answering the question a suspension actually asked.

**5. The `Finishing the cycle` lead-in** (Mechanics · `baseSha`). It wraps across C 827–828 and
W 1011–1012.
```
**Finishing the cycle:** once the closure ordering reaches a Gate-B cycle's closing act — an
eligible pass with every closure precondition holding, never a clean pass on its own — close it
with `git commit --amend -m "<real message>"`; that replaces the WIP commit, and the hook reads
the amend as the real cycle-closing commit. This section states the operation and never whether
the cycle may close.
```
*Why (pass 20 finding 5):* the live sentence says "after the final clean pass, close it with
`git commit --amend`", which is a complete instruction to whoever enters through Mechanics — and
under the ordering a clean eligible pass is not enough, an unmet precondition leaving the cycle
open. A reader entering there could amend over a standing hold, an undischarged Major or a changed
evidence entry. The repair makes this section the **operation** and the ordering the **permission**,
which is the split every sentence of this mechanism takes.

**6. The Gate-A broad-prompt instruction** (Gate A section). It wraps across C 553–555 and
W 745–747.
```
Use ONE broad prompt: **its review question and dimensions stay the same every pass, while the
artifact text it carries is always the current one**. Re-running it over an **unrevised** artifact
is legitimate wherever no repair is owed, an edit made to justify a pass being no reason to run
one. Don't narrow per-dimension: new findings surface because the artifact changed, because an
answer given since the last pass changed what the rules require of it, or because a broad prompt
reaches what the last reading did not.
```
*Why (pass 21 finding 1):* the live wording says to re-run "over the revised artifact … because
the artifact changes between passes", which the ordering's third branch contradicts — that branch
continues on an **unrevised** artifact wherever no repair is owed. A pass whose only findings were
Minors, or one run after a health answer with nothing left to repair, receives two instructions
and can satisfy the live one only by manufacturing a change. **The replacement keeps the breadth
demand**, which is what that sentence exists for and the reason it must not be narrowed
per-dimension; it drops only the claim that a revision always precedes a pass.
*And (pass 22 finding 5):* an earlier wording said to re-run the prompt "unchanged", which a Gate-A
prompt cannot be while also carrying the artifact text it reviews. **Unchanged** now scopes to the
question and the dimensions; the payload is replaced every pass, so no pass can be run against
last pass's text.

**7. The human-exception destination** (Mechanics, recording a human exception). It wraps across
C 988–989 and W 1172–1173; only the Gate-A clause changes.
```
**Which commit:** an ungated change records it in that commit; a Gate-A cycle in the commit its
closing act uses; a Gate-B cycle in the WIP commit, restated by the closing amend.
```
*Why (pass 22 finding 3):* the live clause sends a Gate-A cycle's exception record to "the spec or
plan commit", which is the closing commit only on the first of the three closing paths. On the
other two the record and the closure would land in different commits. Naming the closing act
instead keeps them together on all three without changing the record's form or force.

---

## G. The one-contract paragraph — REPLACED

```
**These rules and records are one contract, and a partial adoption breaks it.** The nonce, the
slot naming, the provenance line, the curve, the carry rule, the unknown-start activation
semantics **and the closure ordering together with every rule it reads** depend on one another,
and the requirement is that the adopted definitions **agree**, not merely that all of them are
present. **Membership is decided by a test a reader can apply to the text in front of them, with
no list to consult, and the test reads what a rule states rather than what changing it would do:
a live rule belongs to this contract when what it says determines or supplies an input the
closure ordering reads, which branch a pass takes, what a hold is or what discharges it,
whether a cycle may close, or the production, identity or transport of any record this section
obliges a cycle to write.** **Read it on the sentence, never on the section the sentence sits in.**
A sentence is a member when **it itself** fixes one of those things — what counts as a valid
finding line, which files or records are owed, what ends a hold. It is not a member when it only
shapes what a review produces, as the choice of reviewer, the lens set and the wording of a prompt
do: those change the findings without deciding what a finding *is* or what the ordering may do with
one. **No paragraph is exempt as a paragraph** — a sentence inside a routing or prompt paragraph
that fixes a valid input or an owed file is a member, and a sentence anywhere that only influences
the findings is not. The examples follow the test; they do not stand in for it.
Asking instead what an imagined edit would do decides nothing, because
any rule can be edited into deciding a branch and none decides one when edited cosmetically, so
membership would follow the edit a reader pictured rather than the text in front of them. The
last clause is why the squash carry belongs: it moves no pass and
decides no branch, and a record that does not survive the merge is unreachable from the squash
commit and from `main`'s history. A curve without a cycle field cannot be told from another
cycle's where several are read together, a slot rule without a nonce cannot keep sibling cycles
apart — the bare names staying reserved for the legacy single-cycle case they already serve — a
carry rule naming records a project does not produce is inert, and a clean predicate without the
fix-set boundary it reads decides membership by accident.
**A project whose text carries some of them and not others, or carries all of them in versions
that disagree, stops and has a human complete, revert or reconcile the adoption before running a
gate under it.**
```

**What this is, stated so nothing reads it as more:** an **instruction to the agent**, over a
wider membership and now with a test that a downstream reader can actually apply — the earlier
draft's "every source edit it cites or depends on" named an edit set that exists only in this
repository's spec, so a downstream agent willing to obey it had nothing to check against (pass 17
finding 8). It is **not a checker**; nothing mechanical detects a partial adoption, a project that
does not adopt this paragraph is not reached by it, and it obliges a stop once someone notices
rather than doing the noticing.

---

## H. The remaining replacements, written out — REPLACED

Each is the final wording. Nothing here is a paraphrase; the plan installs these strings.
**Passage (b) is not among them** — it is written out whole in §B, which is the only place this
file states anything about it.

**`c18` and the surfacing sentence** — the two clauses findings 7 and 8 name. The resolve and hold
duties are kept; the blanket no-clean-credit and the one-answer resumption go, because the
ordering decides both and decided them differently.
```
**Surfacing does not close the cycle, and that is what makes this reachable.** You surface *with
the cycle and the new hold still open* — the resolve rule stands over the finding exactly as
Mechanics · Severity states it, which means **repaired or validly dismissed**, so a recurrence of
one already validly dismissed **stays resolved** and owes neither a second dismissal nor a repair;
the hold stands until
its answers are given, and **what the answer does is the closure ordering's**.
**A pass is credited clean or not on its own findings**, as that ordering defines cleanliness;
surfacing a finding that carries a scope-stop trigger is what withholds the credit, and no
credit is withheld for surfacing alone. Reading this as "stop instead of fixing" would put the
exit in competition with the rule that every Blocker and Major resolves, and then nothing could
satisfy both.
```

**`a13`** — scoped to its own paragraph, which is what it was written to police. *(It wraps
across three lines in each copy: C 129–131, W 336–338.)*
```
Every other rule stated **in this paragraph** about how a cycle closes stands as written, and
none of them is restated — a summary is where their conditions would get dropped.
```

**`a16`** — points at Mechanics instead of carrying an unscoped copy.
```
Open a TodoWrite "Codex pass N" per pass; resolve Blocker/Major after each as
Mechanics · Severity requires.
```

**`a17`–`a22`** — the floor paragraph stops stating closure and the early exit, and points at the
ordering that states them once. `a20` moves to §A unchanged, beside the zero-finding rule it
qualifies; `a21` and `a22` are carried unchanged, reproduced here because the plan installs one
contiguous string. The per-condition accounting is the plan's.
```
What a clean final pass and the zero-finding early exit mean for closing is stated once in the
closure ordering. Codex is advisory — validate before applying; dismissed finding → one-line why.
```

**The Gate-A clean-signal sentence** — the signal stops being the only route to clean.
```
Ask for one line per finding and a literal `NO FINDINGS` when a pass found none — that explicit
signal is what lets a pass be read as clean without inspecting it, and a pass carrying only
Minors is clean too and could never produce that file:
```

**The gate-prompt template's clean sentence**, in the block both gates paste.
```
A **clean findings file** is the single body line `NO FINDINGS` with `END OF FINDINGS (0 total)`.
```

**The Gate-A cadence** — revision becomes conditional, since unconditional it tells a Minor-only
pass to manufacture the repair the severity rule forbids.
```
Each pass: validate, revise **where a repair is required**, re-run.
```

**The lens paragraph's unchanged-list** — scoped to the lens sets, which is what that paragraph is
about.
```
Lenses change what a pass asks, never how many a cycle owes: **the lens sets** leave every other
rule in this section alone.
```

**The unknown-start strict-reading list** — gains the suspensions, reason inline. The whole
dash-delimited list is given, the last item being the addition.
```
— at minimum floor 3, severity classified without the demotion, the provenance-line duty owed,
the curve duty owed, the nonce duties at their strictest, and **every suspension binding, since
starting rules that cannot be established cannot be read as having waived an open hold** —
```

---

## I. What this text does not settle

- **Minor, collected and open (pass 17 finding 9 is resolved above; this is the remainder):**
  nothing in this file establishes that the edit set is complete. It is the sites known at pass
  17. **The plan sweeps both copies against the rule** — a live sentence the ordering falsifies
  gets edited — and prints what it found; a spec cannot establish that claim against text the same
  change rewrites, which is the mechanism that produced a finding at passes 15, 16 and 17.
- **Partial adoption is instructed against, never detected.** §G says so in its own words.
- **Which exit a cycle took is not observable from history.** The transport left with the record
  (successor story) and no story has taken it. An admitted gap, unowned.
