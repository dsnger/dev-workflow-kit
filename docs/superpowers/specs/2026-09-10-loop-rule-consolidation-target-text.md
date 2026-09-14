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

## A. The closure ordering and the two gates' closure — NEW

Three paragraphs, in this order, sitting immediately before "**What a loop absorbs, and what stops
it**" in both copies. **A1 is the ordering and is gate-general; A2 and A3 are each gate's own
closure.** The split is the answer to pass 26's Blocker: the ordering stated one closure condition
cycle-generally while its explanation and its two cases were Gate-A's, leaving an eligible Gate-B
pass with no value to test.

### A1 — the ordering

```
**How a cycle ends — one ordering, stated here and referenced everywhere else.** A pass is read in
a fixed order, because every rule bearing on one decision — may this cycle close — otherwise
qualifies the others and the ranking survives only in a reader's head.

**What this paragraph owns.** It owns **how a pass is evaluated and what follows from that**: the
evaluation order, what each predicate is read from, the eligibility test, the hold a surfaced
finding places and what discharges it, the composition of several suspensions, the pairs that
cannot co-occur, and — as a stated exception, because precedence is evaluation order — the
clearly-stuck precedence clause quoted into it below. **No number is put on that list.** Whether
the read model counts as part of the evaluation order or as a thing beside it is a question of
wording, not of authority. It also owns the **classification** of the standing duties below, and
**those duties bind both gates alike**: the derived floor and the Blocker/Major-resolve duty keep
their definitions at their own sources and are read here for every cycle whatever its gate, while
the hold and no-clean-credit are defined here, being properties of the evaluation itself.

**What belongs to a gate is what the two gates do differently: the content condition its closure
requires, where it has one, and the closing act.** **Gate A has such a condition and Gate B has
none**; each paragraph below states its own and is read from there, and **neither gate's paragraph restates the conditions this one gives every cycle**, so
neither is a complete inventory on its own. **Everything else this paragraph names it cites**: the
scope triggers, the assigned fix set, every severity rule and every closure precondition with a
source of its own keep their one definition in the paragraph that owns them, and a reader who finds
one of *those* defined here has found a defect.

**The conditions every cycle has, whatever its gate.** The duties classified below; and the
**profile**, the **cited set** and the **assigned fix set**, each gating as its own source says and
cited here without restatement. **The profile and the assigned fix set answer a change and not a
differing value**, which is why one of them changed and then undone still costs a pass. **The cited
set answers as its own source says**, and that source says two things: a governing header changed
**during** a pass makes that pass not final, and the final clean pass runs against the **current**
set. The contrast that matters is against a gate's own content condition, which may be a comparison
of current values and says so where it is stated.

**What a pass is read from.** Every finding-derived predicate reads the validated findings file
**or files** of the logical pass as **the concatenation of their finding lines after each file has
been validated separately** — a `full` Gate-B pass has two, one branch alone is already an
incomplete pass, each file's terminator is not a finding line, and a branch whose body is
`NO FINDINGS` contributes an empty sequence rather than a line. **Which severity field each
predicate reads is settled in Mechanics · Severity**, which is where that split lives and is not
repeated here. Beyond the findings, closure reads the **derived floor**, the **resolve duty's
standing over this cycle**, any **hold still standing**, and **every closure condition this cycle
has** — those above and this cycle's gate's. The scope triggers read the **current assigned fix
set** as the absorb paragraph defines it, and the answers already given; the clearly-stuck reading
adds its own coverage judgement. **A line in one branch file and a line in the other are distinct
findings for holds and answers**, so a `full` pass asks twice rather than risk resuming over one it
never asked about. **Within one running cycle an answer binds to the finding or question as the
pass that raised it recorded them** — which is what an agent running the cycle can do with nothing
written down. Recognising the same finding or question **across a lost session** has no mandatory
identity, sameness or recovery rule in these rules; the optional `<slot>-dispositions.md` note is
advisory and authoritative for nothing.

**The four branches are named, and a cross-reference anywhere in this section names the branch
rather than its position**, so reordering them breaks no reference. **They are read once, on the
pass, before any closing act is attempted** — so a pass that reached the act has already been
classified and is not classified again by what the act does.

**The source-block branch, read first.** **Where any unmet closure condition's own source
prescribes stop-and-surface** — a profile present but unresolvable, governing headers that
disagree, a `Story:` header that cannot be read, an unobservable counterfactual, and **any other
source rule that prescribes it; the list is examples and not the set** — **the cycle stays open, that source decides what
must be repaired or answered, and no further pass runs while its block stands.** It is neither a
suspension nor a continue and needs no name and no procedure of its own: the source rule carries
both, and this ordering's part is to send the reader there rather than to run a pass over a cycle
another rule has stopped. **Once its source condition is repaired**, a block that stood **before any pass of this cycle was
read** — the ones its floor derivation and its cited set raise among them — leaves the cycle to run
its next pass, there being no pass to read again; a block that stood **on a pass already read** has
**that pass read again through the ordering**, no closing act
having been attempted on it — **and where that pass also carried a suspension, this branch
releases only its own block**: the composition rule still holds the cycle on every answer that
suspension asked for, a continue still leads to a pass run after the answer, and a stop still parks
the cycle until an explicit later continue — so the reread happens where no suspension of that
pass is outstanding, and otherwise the suspension's own route runs first — the read-once rule below is about a pass that reached the act, not
about one a block held before it, and without this a repair that moves no pass-cost value would
leave a clean eligible pass with no route to the act and none to a suspension.
**It is read first and it silences nothing.** Where the same pass also
carries a suspension, that suspension is surfaced with its reasons and its questions exactly as the
suspension branch requires and its answers are collected; what the block adds is that **no next
pass runs until its own source condition is repaired**, whatever those answers were.

**Then the clean-completion branch, and eligibility is its own test.** §5 uses *clean* in two
senses and now says which is which: a **clean findings file** is the `NO FINDINGS` signal the
protocol defines, and a **clean pass** is the predicate here, read on the logical pass with every
required branch file combined, so one branch's clean file never establishes a clean pass. **A pass
is clean** when its findings carry no in-set Blocker or Major at effective severity and **no
scope-stop trigger** — the two the absorb paragraph defines, read there and not redefined here,
each already carrying the qualification **an answer given before that pass ran** puts on it. **A
pass's cleanliness is settled on what it found and on the answers standing when it ran**, and a
later answer never rewrites it: an answer discharges the holds it was asked for and leaves the pass
that raised them exactly as clean or unclean as it was, which is the same fact the duties paragraph
states of no-clean-credit. Reading a later answer back onto an earlier pass would let a cycle close
on a pass that was surfaced, answered and never re-run. A pass with **zero** findings is clean
whatever the floor, because a floor buys further looks at an artifact that keeps yielding findings,
and one yielding none has already given what those looks were for; don't manufacture findings to
pad.

**A repetition of a finding this cycle has validly dismissed does not, on its own, make a pass
unclean.** Every part of this is required and the exclusion is narrow: the **dismissal was made in
an earlier pass of this cycle**, its stated reason is **still true of the artifact as it now
stands**, and the later finding **makes the same complaint and brings no new evidence** — no
observation the dismissal did not answer, and no change to the text the reason turned on. Where any
part fails — new evidence, relevant content changed, or genuine doubt that this finding is that
one — the finding is read afresh like any other, and **doubt never resolves in the exclusion's
favour**. Without it the standing duty *dismiss validly, then run another pass* cannot finish,
because a reviewer repeating its own refuted claim would decide whether that claim had been dealt
with. **It reaches only a dismissal this cycle made**, which is what an agent running the cycle
knows; nothing here ships a record, and recognising a dismissal across a lost session has no more
support than the paragraph above gives it.

**It changes cleanliness and nothing else, which is what keeps it from being a waiver.** The
repetition is **still a finding**: it stands in its pass's findings file, and every loop-health
reading counts it exactly as it counts any other, so a loop spending passes on a point it keeps
refuting still shows up as one. It remains the clearly-stuck reading's re-raise condition. **No
earlier pass becomes clean in retrospect** — a pass's cleanliness is settled on what it found and
is never rewritten, which this exclusion leaves untouched: it decides the pass being read and no
other. And it is **not** a second dismissal; the resolve duty was discharged when the finding was
dismissed and there is nothing here to discharge again.

**Eligibility is exactly this and nothing more: a clean pass at or above the derived floor, or a
zero-finding pass.** It is a property of the pass. **Closure is eligibility plus every closure
condition of this cycle holding plus this cycle's gate's closing act**, and those conditions are
properties of the *cycle*, not of the pass — so an eligible pass whose conditions are unmet closes
nothing, and is not thereby made unclean. Keeping the two apart is what lets the order decide the
case where they disagree, which the branches do. **The order inside closure is fixed: every
condition is established first, and only then is the closing act performed.**

**An act that does not complete has not closed the cycle**, and it is not a branch: the branches
below decide what a *pass* is, and this cycle's pass already took the clean-completion branch and
reached closure. **A failed act returns to the closure step it failed in, not to the branches.**
**Nothing is assumed about what the attempt left behind** — a hook can modify and stage content
before failing, so the attempt itself can move what a condition is read from — so surface the
concrete command failure and **re-establish every closure condition against the repository as it
now stands.** Where they all still hold, perform the act again. Where the attempt or its repair
moved anything a condition is read from, **that condition has changed and its own rule decides what
it costs**, a further pass included, and the cycle is back in the ordering with that pass owed.
**Where the failure cannot be repaired at all** — a signing key nobody has, a permission nobody can
grant — **surface it and leave the cycle parked**: open, not running, spending no passes, restarted
by an explicit later continue, which is the state a stop answer already produces and is named here
rather than invented. A cycle that can neither close nor be parked is the outcome this sentence
exists to prevent.

**Closure introduces no new kind of record, and it excuses none**: every other record this cycle
owes, a human-exception record among them, is owed and written exactly as before, and **a
human-exception record this cycle owes goes in the commit its closing act uses**, so the two never
land in different places. **No closure condition is read on the branch tip**, the conditions being
read where their sources say and not off the tip. **That is not a claim that the act publishes what
the pass read.** A commit is written from the effective index, so a staged edit the working tree
does not show lands in the closing commit; where the edit changes something a **source rule**
governs — a profile value, cited-set membership, the assigned fix set — **the change has happened
and that source's own rule applies**, so a further pass is owed and no condition is added here for
it. **Where it changes a review input no source rule governs** — a cited story's acceptance
criteria or settled decisions, say — **nothing here reaches it, and nothing in this section does**:
the artifact's own equality condition covers the artifact, and the inputs beside it have only the
rules their sources give them.

A plateau or tells on **the pass that closes** go into **that pass's status report to the user** —
the carrier the three-line duty already names, and no second report form is introduced — and never
block it, because reporting "will not converge" on a converged loop is a false report; on an
eligible pass that does **not** close they go into the same place, a pass reporting what it read of
the loop whether or not it closes. **No other pass outcome makes a cycle eligible to close**,
because every other pass either leaves a required repair, a hold or a question outstanding, **or
has not reached the floor, or is itself unclean on its own findings** — and closing over any of
those is the failure this ordering exists to prevent. The floor is named separately because a
below-floor pass whose only findings are Minors leaves nothing outstanding and is still not
eligible; **pass-level uncleanliness is named separately** because an in-set Blocker or Major
repaired after the pass that raised it discharges the resolve duty without making that pass clean,
so a cycle can owe nothing and still hold no pass it may close on. The one termination that is not a pass outcome is the Gate-B triviality skip, which runs
no passes and is outside this ordering.

**Then the suspension branch, which a pass reaches where the clean-completion branch did not take
it and a suspension applies to it.** **Clean completion outranks a suspension by taking the pass to
the closing act, not by eligibility alone**: a pass that took the branch above, met
every closure condition and had the closing act performed has ended the cycle, and a suspension has
nothing left to suspend. **A pass the clean-completion branch did not take reaches this branch
whatever its cleanliness, where a suspension applies to it** — a clean pass below the floor, and
equally an eligible pass whose unmet closure conditions kept that branch from taking it. Cleanliness is what this branch stops
asking about; whether a suspension applies is still what puts a pass here, and where none does the
continue branch has it. That is what makes "clean completion outranks the two-tell stop"
executable rather than asserted, and cleanliness alone never decides it. **What D2 and D3 forbid is
reporting "will not converge" on a loop that converged, and a loop still owing a repair, an answer
or a closure condition has not converged** — so a mandatory two-tell stop and the clearly-stuck
reading stay reachable exactly where the loop is still running, which is the only place their
question means anything. Three suspensions, by the names their
paragraphs use and read by those paragraphs: the **scope stop**, raised by either trigger above — a
**membership stop** by the first, a **question stop** by the second; the **clearly-stuck exit**;
and the **two-tell stop**. A suspension waives nothing. Any non-empty set of them can apply to one
pass: **one surface, every reason reported, every question asked**, because a reason left out is a
decision made by omission. A finding the clearly-stuck reading surfaces that also carries either
trigger takes the scope stop's answers at that same surface, so it is not asked twice; the two-tell
stop surfaces tells and not a finding.

**Otherwise the continue branch, which no source block reaches: where none stands and neither of
the two branches above took the pass, it continues** — the loop
runs another pass on the **current** artifact, revised where the severity and scope rules require a
repair and unrevised where they do not. **An eligible pass with an unmet closure condition lands
here**, and like every other non-closing pass **only where no suspension applies to it**: clean
completion did not take it, so the loop continues on whatever the unmet condition requires — most
often a repair still owed from an earlier pass. A below-floor clean pass lands here on the same
terms; where a suspension does apply, the suspension branch has already taken it, because only
the clean-completion branch outranks a suspension. So does a pass whose only findings are Minors and
Nits **and which carries no scope-stop trigger** — those are collected and never iterated and may
leave nothing to revise, while a Minor or Nit **carrying a scope-stop trigger as the absorb
passage defines one** carries it like any other finding, is not clean, and has already been taken
by the suspension branch — **severity does not raise a trigger and does not suppress one**, and
which findings raise one is that passage's entire, an already-declined finding and an
already-answered question raising none. It is a branch and
not an inference, because "does not close" read alone says nothing about whether to run again.

**The four standing duties, classified.** The **derived floor** is a **precondition on closure**:
it gates closing, discharged by the count of valid logical passes reaching it with the last of them
clean, or by the zero-finding exit. The **Blocker/Major-resolve duty** is a **precondition on
closure**: Mechanics · Severity, scoped to the assigned fix set, states what it demands and what
discharges it, at that source and not here. **It is discharged per finding and tracked across the
cycle, never inferred from a later pass.** A findings file establishes the **inventory** of what
that pass found and not the resolution of anything, so a later pass that does not mention an
earlier in-set Blocker or Major says nothing about whether it was resolved; reading its absence as
discharge would let an omission close a cycle. **The duty is not a second test on whether a pass is
clean, and the two are not run together.** A pass is clean on its own findings. Stated as the case
that separates them, because a reader who conflates them decides it wrongly: **pass 1 raises an
in-set Major; it is not resolved; pass 2 finds nothing.** Pass 2 **is** clean, and at or above the
floor it is **eligible** — and the cycle **still cannot close**, the duty being unmet; it takes the
continue branch until that Major is discharged. What the open Major does *not* do is make pass 2
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
a hold like any other. **A re-raised valid dismissal stays discharged for the resolve duty on
exactly the terms the clean predicate sets out above** — the same complaint, no new evidence, no
change to the text the dismissal turned on, and the dismissal's reason still true of the artifact.
The dismissal was the resolution and a reviewer repeating it does not undo it, so no second
dismissal is owed. **Where any of those fails the recurrence is an ordinary fresh finding** and is
handled as one — by the severity and scope rules at their own sources, which decide whether it is
in set and what it owes; reading the old dismissal as covering it would let a finding that has
since become true close a cycle. What a
qualifying recurrence creates is the **clearly-stuck hold**, ended by that reading's
continue-or-stop answer. Any trigger the recurrence independently carries raises its own
stop as usual. **Where one finding is surfaced by more than one route it carries a hold
component per route, and each is discharged by its own answer**: the **membership** component by
the membership answer **in either direction**, a decline releasing it exactly as an accept does;
the **question** component by the user's decision on that question; the **clearly-stuck** component
by that reading's continue-or-stop answer. **No answer discharges another route's component**, and
a finding surfaced by one route has one component, discharged by the one answer its surface asks
for. **Resumption is still the
composition rule's**, which waits for every outstanding answer. At a **membership stop** the answer is **accept** or **decline**;
**what each does to the assigned fix set is the absorb paragraph's, which defines that set from
these outcomes**, and what an in-set finding then owes is Mechanics · Severity's. A later answer
that contradicts a decline **does not reverse it**: the decline **remains binding** and the
contradiction is **surfaced to the user as information**, changing neither membership, nor the
cycle's state, nor any outstanding question — **whether the loop resumes is decided by the
composition rule below and by nothing here**, so a contradictory answer is never itself a
resumption and cannot step past a hold or a health question still awaiting its own answer. Nothing
here turns one answer into another, since that would let a finding be moved out of the set and back
into it to escape what it owes inside it. **There is no withdrawal inside the cycle that
declined**, a decline binding for the remainder of its cycle and admitting no exception; a
reconsideration is a later cycle's, where that decline has no effect at all and the finding takes
the ordinary route. Either answer is an **explicit, attributable decision on that specific
finding** — never silence, never a general remark about scope, never inferred, because a fix set
changed by inference is a fix set nobody chose. **Membership is answered against the set as the
absorb paragraph fixes it for the pass that raised the question**: a later broadening is a new fact
the **next** pass reads and never discharges a standing hold, a hold discharged by a scope change
being a hold nobody answered. At a **question stop** the answer is the user's decision on the
question and membership does not change; an out-of-set finding that opened one is a membership stop
as well. **Decline is available only at a membership stop**, that being the only stop whose
question is whether a finding belongs to the set. The **clearly-stuck and two-tell readings** ask
**continue or stop**. **Continue consumes the reading that raised the suspension**: a further
health suspension needs that reading recomputed over a pass run after the answer, which is new
data — so continue produces a distinct next state, and the same reading cannot return the same stop
unanswered. It permits an **unrevised** artifact **only where no repair is owed**; where effective
severity or scope requires one, that repair comes before the post-answer pass, since a pass run
over an unrepaired in-set Blocker or Major spends a look on text the rules already say must change.
**Stop parks the cycle**: open, not running, spending no passes, restarted only by an explicit
later continue — a distinct state from the suspended-awaiting-answer one it was in before the
answer. **That continue restarts the cycle and never skips an answer**: where any question the
suspension raised is still outstanding, it returns the cycle to suspended-awaiting-answer, and only
once every answer the composition rule requires has been given does the next pass run. So a cycle
parked with an unanswered membership or question stop cannot be continued into a pass, and cannot
sit parked with no transition either — the continue is always available and always moves it.
Nothing a parked cycle wrote is a closing commit, and a parked cycle nobody restarts is a human's
to resolve, exactly as the nonce rules already say of open cycles.

**Composition, and what cannot happen.** Every **question** is answered on its own and the loop
resumes only when every answer resumes it — accept or decline at a membership stop, a decision at a
question stop, continue at the health readings; one stop answer parks the whole suspension, because
a loop resumed over an unanswered question decides it by running. **The clearly-stuck and two-tell
readings raise one question between them, not two**, both asking continue or stop, so one answer
carrying every reason ends both — an instance of the sentence before it, not an exception. **Two
pairings cannot occur**, and no rule ranks them: clean completion and a **scope stop**, since that
stop's triggers are the clean predicate's own second half, so a pass raising one is not clean; and
a zero-finding pass and any suspension, since it has nothing to surface, nothing regenerating, no
cluster and no require↔withdraw pair. **Clean completion and the clearly-stuck exit can**, and the
overlap is admitted rather than argued away: the two read different severity fields, as
Mechanics · Severity sets out, so an **in-set** Blocker or Major the ceiling demotes below Major
can regenerate across passes on a pass that is clean. **A declined finding is not a route into that
reading**: the third condition admits regeneration across repair attempts and a qualifying
re-raised validated dismissal, and a decline is neither — it is the user's decision that a *true* finding stays outside
the set, and it binds for the cycle. **The order decides it and no new rule is needed.** The
clearly-stuck paragraph's own precedence clause is stated here rather than there, because
precedence is evaluation order and this paragraph is where evaluation order is stated once; the
rationale that clause turns on stays beside the reading in that paragraph, which is where the
reading itself lives. **A clean completion takes precedence over this exit**: a Blocker/Major-free
pass **at or above the floor** has satisfied the clean-final-pass rule — collect the Minors and
Nits and close — and reporting "will not converge" on a converged loop is a false report. Below the
floor the pass **suspends**, the clean pass having failed eligibility. **That sentence ranks two
readings and licenses no closure**, its "close" being the closure this ordering defines and
carrying every condition that closure carries: a Minor or Nit bearing a scope-stop trigger makes
the pass unclean, so the sentence does not reach it, and an undischarged duty, a standing hold or
an unmet gate condition means the pass does not close — leaving it on the suspension branch where
one applies and the continue branch where none does, exactly as those branches say.
```

### A2 — Gate A's closure

```
**Gate A's content condition, and its closing act.** These are what Gate A adds to the conditions
the ordering states for every cycle; that list is there and is not repeated here.

**Its content condition: the artifact as it now stands is identical to the text that went into the
final pass's review request.** Gate A hands the reviewer text rather than a git range, which is why
this condition is Gate A's and is written nowhere else. It is **current equality and deliberately
nothing more**: it does **not** say the artifact went untouched in between, and text edited and
then restored byte for byte satisfies it — stated here because the ordering's conditions answer a change
instead, and said of this condition rather than as a claim about every other.
That is a decision rather than an oversight: a content comparison cannot tell those two states
apart, and a condition nobody can check is a condition nobody applies. It likewise says nothing
about **what the reviewer consumed**: no part of this act is offered as evidence of the review
payload.

**The act.** A Gate-A cycle has no WIP snapshot to replace, so it closes by **writing the closing
commit — or the closing message of one that already exists — carrying the records this cycle
already owes**: its provenance line and its per-pass curve, in the forms Mechanics fixes, neither
of them altered. **The content must survive into that commit, and carrying it there is part of the
act**: the equality above is read on the artifact, while the commit is written from the effective
index, so an act that does not carry that same content through has checked the condition without
performing it. **The commit that closes the cycle contains, at the artifact path, exactly the text
the condition was read against.** The safe command sequence and whatever demonstrates it belong to
the plan; **the duty belongs here**, and it needs no new fingerprint and no new record.

**Two cases, told apart by the repository's current state rather than by which commit introduced
what; the safe git sequence for each belongs to the plan. That reading decides how a cycle closes,
never whether it may.**
- **`HEAD` already carries that text at the artifact path.** Close by **amending `HEAD`'s message**
  to add the records, leaving that path as it stands.
- **`HEAD` does not, the reviewed text being still uncommitted.** **Commit it unchanged** and close
  in that commit. This case had no answer before: an eligible pass over repairs nobody had
  committed could neither close nor suspend.

**No new revision of the artifact is made to close a Gate-A cycle**, a new revision being one no
pass has run against — and committing already-reviewed text that was never committed is not one.
```

### A3 — Gate B's closure

```
**Gate B's content condition, and its closing act.** These are what Gate B adds to the conditions
the ordering states for every cycle; that list is there and is not repeated here, so nothing below
is an inventory of what this gate requires. **This gate adds no content condition of its own**,
and the next paragraph says why.

**Its content condition is not an artifact/request equality, and none is written for it.** Gate B
reviews a **diff** identified by `baseSha` and `headSha` rather than a text handed to the reviewer,
so there is no reviewed text to compare an artifact against, and **nothing is put in its place**:
content the final review request did not select can reach the closing commit, and **no rule in this
section reaches it**. **What this gate does have is every Gate-B duty this section already
states, at the paragraphs that state them, and none of them is summarised here** — a compressed
inventory is where a load-bearing part goes missing while the list still looks complete.

**The act** is the one Mechanics · Finishing the cycle describes, in whichever shape that section
gives the repository's current state. **This paragraph says when it is performed and never which
shape it takes**: once the ordering reaches it, on an eligible pass with every closure condition
holding, **never a clean pass on its own**.

**A commit the hook reads as cycle-closing is a Gate-B matter.** A non-`WIP` commit mid-cycle makes
the hook drop its Gate-B review state and that gate's counter — an observation about the counter,
since the cycle itself stays open until the conditions hold, so an accidental commit resets what
the hook reports and closes nothing; **what the reset erases is counter state, and it does not
invalidate a pass that already satisfied the validation rules this section states** — which is
where what makes a pass valid stays. **A stray commit that succeeds and does not amend also leaves the
`WIP:` snapshot as an ancestor**, an amend replacing the tip instead —
so in that one shape **the closing act still owes what Mechanics already requires of it: no `WIP:`
commit left in history.** Which git sequence reaches that from this state
belongs to the plan, as every other closing sequence does. **It does not reach a Gate-A cycle's count**, which the hook
clears at the skill boundaries that start a new Gate-A cycle rather than on any commit.
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

**Changed:** `b3`, `b7`, `b8`, `b11`, `b12`, `b13`, `b16`, `b17`–`b18`. **Added:** the closing-time
change rule, which no inventoried condition carried, because none existed. **Carried:** every other
sentence. The rationales follow the text.

```
**What a loop absorbs, and what stops it — a question of scope, not of action.** A finding
that corrects the correction you just made **and stays inside the assigned fix set** is
**inside this loop's scope**: keep it here rather than handing it back, then act on it by its
severity exactly as Mechanics · Severity says. Ancestry decides where a finding belongs; it
never decides what you do with it, and it grants no Minor or Nit a repair round it would not
otherwise get. **The assigned fix set is fixed before the pass you are answering: it is the
union of the scope every approved story or plan governing this change assigns to this cycle,
plus every finding this cycle has accepted at a membership stop together with any repair
obligation accepted with it, minus every finding this cycle has declined.** **An accept puts the
finding in the set whatever its severity**: membership and the repair duty are different things,
so a Minor or Nit accepted into the set is in it though Mechanics · Severity asks no repair for
it, and a later pass that recomputed it as outside would raise the membership question a second
time and make the accept decide nothing. A finding is in-set when repairing it stays inside **the assigned fix set as
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
review. **A change to this set costs the cycle at least one further pass.** The set a pass was
begun under is the set its closure would rely on, so the window opens **when that set is fixed
for the pass**, as this paragraph defines it, and runs to the closing act; a change anywhere in
that window costs a further pass, **in either direction and whether or not the change is later
undone**, the set having governed the pass differently while it stood. That further pass must
itself be clean and every other closure duty must be satisfied; it is one more pass, not a
licence to close on the next one.
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

*Why the added closing-time rule (pass 26 finding 3):* §A cited this paragraph as the source
governing a closing-time change to the set, and **no such rule existed anywhere** — this paragraph
fixed the set before a pass, and §A said only that a later broadening is read by the **next** pass.
Neither answers what a narrowing, another kind of change, or a change since undone does at the
closing act, so a final pass could be accepted after the set changed under it. **Daniel decided the
behaviour on 2026-09-12**, choosing a change-costs-a-pass rule over "only a broadening counts" and
over "nothing at closing time": a narrowing is not harmless for having been inside a superset,
since it changes which findings are in the set and what follows from that. **The window opens where
the set is fixed for the pass**, not where that pass's findings arrive, so a change made while the
pass runs is inside it. It is written here because this paragraph owns the set, which is what makes
§A's citation true.

---

## C. Passage (c) — recognizing clearly stuck — REPLACED, from the third condition

**The three-condition sentence entire**, so nothing here begins mid-clause. **Changed within it:**
the third condition gains the re-raised-dismissal clause. The plateau and coverage conditions are
carried word for word. Of the two sentences after it, the first is the live sentence's opening
clause left standing alone — its second half, the precedence sentence, moves into the block — and
the second is new.

```
So this exit needs three things **together**, and a missing one means only that *this* exit does not apply — what the pass does instead is the closure ordering's, read there in full: a plateau
visible across passes (six or more is where the field saw one); an **affirmative judgement that
coverage is sufficient**, stated — a known materially unreviewed area forbids this exit outright,
and disclosing it does not license it; and **Blocker or Major findings that keep regenerating
across genuine repair attempts**, each round's fix producing the next — **or a finding the author
has validly dismissed that the reviewer re-raises across passes on the terms the closure ordering
sets**, a recurrence failing them being an ordinary fresh finding and not a re-raise at all, the
re-raise standing in for
the regenerating fix, since a dismissal gets no repair and produces none, and a reviewer returning
to the same refuted point every pass says the same thing about the loop that a fix producing the
next finding says. That third condition is what makes a plateau rather than a finish. **Where this reading and a clean
completion both apply, the closure ordering decides it** — the precedence sentence lives there,
because precedence is evaluation order.
```

*What follows in the live paragraph, and the two are not treated alike (pass 19 finding 8).* **Only the operative precedence clause moves into the block above**, from "a clean completion takes
precedence over this exit" to the end of the sentence, **capitalized there as a standalone
sentence**; its opening clause — the plateau rationale — **stays here**, which is pass 26 finding
9. So the words that move are unchanged and the sentence is **split, not moved whole**: saying it
moves word for word would be false of the sentence and would have the plan preserve bytes that are
not the proposed text. **D3 is satisfied by the operative clause surviving unchanged**, which is
what D3 is about. The **below-the-floor sentence does not move at all — it is replaced**: it says a
Blocker/Major-free pass below the floor carrying a Minor "keeps looping", while the ordering
splits that case, such a pass **suspending** where any suspension applies to it and **continuing**
where none does. Its two halves live in the ordering's suspension and continue branches, and no
copy of the live wording survives beside them — carrying it word for word would install an unconditional
continuation next to the conditional one and give the same pass two answers.

---

## D. Passage (e) — the five tells — REPLACED, in part

**`e7`, the threshold.** Gains one clause; the sentence is given entire.
```
**Any two present makes stop-and-surface mandatory, not discretionary** — read **after** the
clean-completion branch of the closure ordering, which outranks it **by taking the pass to the
closing act and only then** — and you report the tells and hand the decision to the user, and the "clearly stuck"
reading above is not a precondition for it.
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
  being the user's decision that a **true** finding stays outside the set. Minor · Nit → collect;
  **their severity buys no repair round and no further pass.** Where accepting one into the
  assigned fix set costs a pass, that cost is the **set change's** and is stated at the absorb
  paragraph, not this severity's.
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
  here. Two reasons for the split. The curve's **three numeric series** must stay derivable from
  the validated findings files alone wherever those files remain available — the rest of the curve
  is not and does not claim to be, its cycle field, pass ranges and model identifiers coming from
  elsewhere, and an unrecoverable count being written `?` exactly as the standing grammar allows —
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

## F. The twenty-two standing sentences this change falsifies — REPLACED

Each is a live sentence that the block makes wrong. All twenty-two are **known contradictions** and
none is deferred. **Seventeen of them share one mechanism** — an entry point other than the ordering
carrying an unqualified instruction — which is why each is **replaced** rather than given an
exception to point at. **Fifteen live in the two prompt copies and cite a line in each; the last
seven live in the shipped hook**, which has one copy and no template mirror. The hook holds eight
gate reminders in all; the one this change leaves alone is the docs-only notice, which states no
closure permission. **Three of the seven are pinned by exact-match expectations in
`plugins/dev-workflow/hooks/codex-gate.test.sh`** — items 12, 15 and 16, at that file's three
`expected_ctx` assignments — and each is replaced there with its complete resulting message in the
same change. The remaining four are matched by loose patterns these repairs leave standing.

**1. The `WIP:` naming warning** (Mechanics · `baseSha`).
```
A pre-review snapshot named anything else reads to the hook as a real commit: the hook treats the
cycle as closed and **discards its count of the passes you just accumulated**, while the cycle
itself stays open until the closure ordering's conditions hold. **What the hook loses is its counter state**, and that
counter is not what makes a pass valid — so the reminder now understates what you hold, and no
close was intended or made. **What such a commit does to the repository, and what the closing act
then owes, is in the Gate-B closure paragraph**, not here.
```
*The sibling sentence in the profile-change paragraph claims no closure* — it says such a commit
"reads **to the hook** as the cycle closing" — **but its second half is falsified by this same
repair and is item 8 below.**

**2. The Gate-B coverage instruction** (Gate B section).
```
Same coverage rule as Gate A: put "report every finding with severity and confidence; write
`NO FINDINGS` only when the branch found none" in `additionalContext`, with the same one-line
format. **You filter to Blocker/Major for what must be repaired, and read every line for
everything else** — cleanliness, the scope triggers, the assigned fix set and the loop-health
readings all take Minor and Nit lines. Codex never filters.
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
continue a cycle. **The answers a suspension asks for are not assent of that kind**: they are the
answers the closure ordering prescribes, and both which answers those are and what they produce are
stated there.
```
*Why (pass 19 finding 4):* the live sentence says no human answer lets an agent continue a cycle,
while the ordering makes **continue** the prescribed answer that restarts a parked one. Left as
it stands, an agent following it refuses the exact transition the ordering requires. The
distinction the repair draws is between a human waving a rule through — which this paragraph
still forbids — and answering the question a suspension actually asked.
*And (pass 26 finding 5):* an earlier repair named **continue or stop** as the answer, which is the
two health readings' vocabulary and not a membership stop's accept-or-decline. The replacement
**refers** to the ordering rather than enumerating the three, because an enumeration here is the
second description of the answer rules that finding 5 was raised about — this paragraph is not
their definition site.

**5. The `Finishing the cycle` lead-in** (Mechanics · `baseSha`). It wraps across C 827–828 and
W 1011–1012.
```
**Finishing the cycle:** **when a Gate-B cycle's closing act is performed is the closure
ordering's, stated there entire**; this section gives only the operation. Close it with
`git commit --amend -m "<real message>"`, which replaces the WIP commit; **where a `WIP:` snapshot
would survive the amend** — several piled up, or a stray non-amending commit made one an
ancestor — **reset to the parent of the first and commit once instead**. This section is the only
place either shape is defined. **The hook treats any
non-`WIP` commit *attempt* as a Gate-B boundary and clears its state even where the command
fails**, so a failed closing act leaves that counter cleared — a fact about the
counter and not about the cycle. This section states the operation and never whether the cycle may
close.
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
Use ONE broad prompt: **its review question stays the same every pass, while the artifact text it
carries and the dimensions it asks for are always the current ones** — the lens sets the profiles
section derives are recomputed from the current profile and cited set each pass and appended, since
a profile or cited-set change changes what is owed. Re-running it over an **unrevised** artifact
is legitimate wherever no repair is owed, an edit made to justify a pass being no reason to run
one. Don't narrow per-dimension: new findings surface because the artifact changed, because an
answer given since the last pass changed what the rules require of it, or because a broad prompt
reaches what the last reading did not.
```
*Why (pass 21 finding 1):* the live wording says to re-run "over the revised artifact … because
the artifact changes between passes", which the ordering's continue branch contradicts — that
branch continues on an **unrevised** artifact wherever no repair is owed. A pass whose only findings were
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
closing act uses; a Gate-B cycle in the WIP commit, restated by the commit its closing act
produces.
```
*Why (pass 22 finding 3):* the live clause sends a Gate-A cycle's exception record to "the spec or
plan commit", which is the closing commit only where the artifact's existing commit **is** the
closing commit. Wherever it is not, the record and the closure would land in different commits.
Naming the closing act instead keeps them together in every case, without changing the record's
form or force.

**8. The profile-change paragraph's pass claim** (the profiles section). It wraps across C 752–753
and W 938–939.
```
Inside an active Gate-B cycle, the edit must end up **in the content the next review reads** —
folded into the active `WIP:` snapshot by amend where that snapshot is the tip, and otherwise
reviewed as its own change, since no amend reaches a snapshot a stray commit has made an ancestor
and this section prescribes no operation that does. A non-`WIP` commit reads to the hook as the
cycle closing and would discard **the hook's count of** the accumulated passes.
```
*Why (pass 33 finding 7):* the live clause says such a commit "would discard the accumulated
passes". A pass is established by its validated findings file; what the commit reaches is the
hook's counter. Left standing it tells an author that a stray commit destroyed review work it
cannot reach. **This one does not share the section's shared mechanism** — it is a false claim
about a mechanism rather than an entry point carrying an unqualified instruction.

**7a. The mid-run recovery sentence** (Mechanics, the cycle nonce). It wraps across C 416–417 and
W 610–611.
```
A Gate-A cycle has such a commit only once its own closing commit exists — an already-committed
revision of the reviewed text is not one, carrying no provenance line and no curve for a nonce to
be taken from — so mid-run it has only the working record.
```
*Why (pass 48 finding 1):* the live sentence says a Gate-A cycle mid-run has no commit of its own
and therefore has only the working record. §A2 admits the case where `HEAD` already carries the
reviewed text, and there the cycle does have a commit a later reader can read. Left standing, the
two describe the same mid-run state incompatibly and a recovering run cannot tell whether history
is a source.

**8a. The HARD FLOOR parenthetical** (the §5 loop rule). It wraps across C 72–73 and W 279–280.
```
**Both gates are a LOOP with a HARD FLOOR: a minimum number of passes per run (a clean final pass
being what the floor is spent on, and cleanliness taking more than Blocker/Major), derived from the
cited story's profile.**
```
*Why (pass 47 finding 1):* the live parenthetical reads "(Blocker/Major only)". Under the ordering
a scope-stop trigger makes a pass unclean whatever the finding's severity, and an assigned-fix-set
change costs a further pass even where the accepted finding is a Minor. A reader entering here can
treat a Minor-or-Nit-only outcome as outside the floor's business, which it no longer is.

**8b. The Gate-A coverage instruction's filter clause** (the Gate A section). It wraps across
C 561–564 and W 753–756.
```
with severity and confidence — **you filter to Blocker/Major for what must be repaired and read
every line for everything else**, Codex never filters, because a model told to report only high
severity drops real findings silently
```
*Why (pass 47 finding 2):* "you filter to Blocker/Major downstream" is now false of the reading
rather than of the repairing. Cleanliness, the two scope triggers, the fix set and every
loop-health reading take Minor and Nit lines, so an author who discards them before those
predicates run can close on a pass that was never clean. It is the ninth and tenth sentences
sharing this section's mechanism, with 8a.

**9a. The evidence-entry revalidation trigger** (the profiles section). It wraps across C 726–727
and W 912–913.
```
and is **revalidated before every Gate-B re-review and before the commit its closing act
produces** — a fix changes the diff even when the profile sits still.
```
*Why (pass 46 finding 2):* the live clause names "the cycle-closing amend", which is one of the
shapes a Gate-B closing act takes, item 5 above defining the other and being the only place either
is defined; where that other shape applies, no amend occurs. Scoped
to the amend, the final revalidation is owed on one path and skipped on the others. It is the
eighth sentence sharing this section's mechanism.

**9b. The severity-deciding fallback** (Mechanics · Severity). It wraps across C 788–789 and
W 974–975.
```
If you cannot name both, the finding is Minor or below: collect; **its severity buys no repair
round and no further pass**, and any pass a later scope decision costs is that decision's.
```
*Why (pass 44 finding 2):* the live clause ends "collect, never iterate", which is an unqualified
command at an entry point other than the ordering. Accepting an out-of-set Minor changes the
assigned fix set, and that change costs a further pass — owed by the set change, not by the
Minor's severity. Left standing, the two instructions decide the same pass in opposite directions.
It is the seventh sentence sharing this section's mechanism.

**9. The evidence-entry revalidation remedy** (the profiles section). It wraps across C 728–729 and
W 914–915.
```
If revalidation changes the entry, the pass was read against an entry that no longer stands: **fix the
entry and re-review on it**, and **which branch the pass takes meanwhile is the closure ordering's,
read there in full** — this paragraph states the repair and never the branch. The pass
that follows is read by that ordering like any other and closes only if it reaches closure, on the
entry revalidated for it.
```
*Why (pass 30 finding 3):* the live sentence is a complete instruction to whoever enters through
the profiles section — fix, re-review, close — and under the ordering a non-closing pass takes any
applicable suspension first. An eligible pass with stale evidence and two tells could follow this
path straight past a mandatory stop. It is the sixth sentence of this section's shared mechanism,
an entry point other than the ordering carrying an unqualified instruction, and it takes the same
repair: the **operation** stays here, the **permission** is the ordering's.

**10. The Gate-A below-floor reminder's honesty claim** (the shipped hook,
`plugins/dev-workflow/hooks/codex-gate.sh` — one copy, no template mirror).
```
Gate A has no content check in this hook; what the gate itself requires of the reviewed artifact is stated in $policy and is instruction-backed. What this cycle does next is that policy's closure ordering's, a further pass being one of its answers and not the only one.
```
*Why (pass 55 finding 6):* the same reminder's tail reads "Run more passes before executing",
which is the same unqualified next action as items 15–17 and is replaced with them; a below-floor
pass carrying a suspension owes that suspension's answer first.
*Why (pass 53 finding 19):* the live string says "Gate A has no content check behind it — this
floor is the only thing keeping the spec review honest", which the Gate-A content condition
falsifies: the floor is no longer the only thing, and a reader who believes it may treat the
condition as optional. The repair keeps the true half — **this hook** checks only the count — and
sends the reader to the gate's own text for what else is owed. It is the eleventh sentence sharing
this section's mechanism, and the first of three that live in the hook rather than in either
prompt copy.

**11. The Gate-A satisfied reminder's clean definition** (the shipped hook, same file).
```
Proceed only if your final pass was clean and every other closure condition holds, both as $policy defines them.
```
*Why (pass 53 finding 20):* the live string defines a clean final pass as "no new Blocker/Major",
an abbreviated second copy of a definition the ordering now states in full — a pass carrying a
scope-stop trigger is not clean under it, whatever the severity of what triggered it. Left
standing, the hook presents such a pass as clean at exactly the moment an author is deciding
whether to proceed. The repair **cites** the definition rather than restating it, which is also
what keeps a later change to the definition from falsifying this string again. It is the twelfth
sentence sharing this section's mechanism.

**12. The Gate-B satisfied reminder's clean definition** (the shipped hook, same file). **Its
fingerprint clause is untouched**: that overclaim predates this change, is parked with the
Gate-B tree-equality material, and no condition here reaches it.
```
Per $policy, commit only if your final pass was clean and every other closure condition holds, both as it defines them.
```
*Why (pass 53 finding 20):* the same abbreviated definition, in the branch an author reads
immediately before committing, and it takes the same repair. It is the thirteenth sentence sharing
this section's mechanism. This message is one of the three pinned by an exact-match expectation,
replaced there with the complete resulting message as the section opening requires.

**13. The WIP-commit reminder's closing permission** (the shipped hook, same file).
```
Use this commit as the review range; whether this cycle runs a review now, and when its closing act may be performed, are both $policy's closure ordering's, read there in full.
```
*Why (pass 54 finding 2):* the live string ends "then make the real commit when your final pass is
clean", which makes cleanliness the whole permission — and it reaches the author at the one moment
the ordering exists to govern. Under the ordering a clean eligible pass closes nothing while a
precondition is unmet, so an author entering here can amend over a below-floor count, a standing
hold or an undischarged Major. It is the fourteenth sentence sharing this section's mechanism, and
the fourth found in the hook; the first three were found at pass 53 and this one at pass 54, which
is why §I records the edit set as established by sweeping rather than by this file.

**14. The Named residual's blanket exemption** (the §5 loop rule, the named residual). It wraps
after "here" in each copy: C 139–140 and W 346–347.
```
**That particular overstatement is out of scope here by decision, and it is not a blanket exemption for hook text** — a reminder this change's own rules falsify is corrected in the same change, as the standing sentences above require.
```
*Why (pass 55 finding 2):* the live sentence reads "Hook text is out of scope here by decision",
which the narrow scope opening of 2026-09-13 falsifies: seven reminder strings are edited by this
change. Left standing, the installed text tells a reader the opposite of what the change did, and
a plan following it omits the authorised repairs. The residual it was written for — the hook
reporting its own threshold as an obligation at a floor of 1 — is untouched and stays out of
scope. This one is **not** an entry point carrying an unqualified instruction; it is a false
statement about scope, so it does not join that count.

**15. The no-fingerprint reminder's next action** (the shipped hook, same file).
```
What this cycle does next is $policy's closure ordering's, read there entire, and this reminder decides none of it — including whether the state file's deletion below is followed by a pass.
```
*Why (pass 55 finding 3):* the live string says "Run Gate B (mcp__codex__review) now", which sends
the author into another pass whatever the cycle's state is — including a pass that carried a
suspension whose answers are still outstanding, which the composition rule holds the cycle on. The
diagnostic half, and the machinery checks after it, are kept: they are what the message is for.
*And (pass 57 findings 2 and 3):* an earlier wording enumerated the ordering's routes as a pass, a
suspension's answer or a source block's repair, which **omits the closing act** — an absent
fingerprint is not a closure condition and Gate B has no content condition, so a clean eligible
cycle whose fingerprint merely could not be stored still has its commit route. The enumeration is
removed rather than extended, per this section's own preference. The same finding's second half
reaches the sentence's tail, "delete it and run a fresh pass": the deletion stays as a remedy, the
pass after it does not, and the new sentence says so where a reader meets it.

**16. The stale-fingerprint reminder's two instructions** (the shipped hook, same file).
```
A fresh Gate-B pass is the complete remedy for the staging and post-upgrade cases too, and when this cycle may run one is $policy's closure ordering's; where it may, that pass records a usable fingerprint.
```
*Why (pass 55 finding 4):* the live string carries two unqualified imperatives — "Run Gate B
(mcp__codex__review) now" and "then run one more pass to record a usable fingerprint" — in the
branch an author reads immediately before committing. Both step past a suspension or a source
block that the ordering says is answered first. The long diagnostic list between them is untouched.

**17. The Gate-B below-floor reminder's instruction** (the shipped hook, same file).
```
Per $policy the review is a LOOP with a hard minimum of $floor passes, and what this cycle does next — a further pass, an answer, or a repair — is that policy's closure ordering's; $policy's skip rule decides only whether a cycle runs at all, never whether one already running may stop short.
```
*Why (pass 55 finding 5):* the live string says "run more … or proceed only if $policy's skip rule
applies to this change", which offers the triviality skip as an exit from a running cycle. The
skip runs **no** passes and is decided before the cycle starts, so a below-floor cycle cannot
reach it; and "run more" alone ignores a suspension the ordering sends that pass to.

---

## G. The one-contract paragraph — REPLACED

```
**These rules and records are one contract, and a partial adoption breaks it.** The nonce, the
slot naming, the provenance line, the curve, the carry rule, the unknown-start activation
semantics **and the closure ordering together with every rule it reads** depend on one another,
and the requirement is that the adopted definitions **agree**, not merely that all of them are
present. **Membership is decided by a test a reader can apply to the text in front of them, with
no list to consult, and the test reads what a rule states rather than what changing it would do:
a live rule belongs to this contract when what it says **defines the validity of an input the
closure ordering reads, or how that input is read**, which branch a pass takes, what a hold is or what discharges it, **what a suspension asks, or what state its answer or an
incomplete closing act produces**, **what a gate's closing act is**, **which version of these rules
governs a cycle**,
whether a cycle may close **or may terminate without running a pass at all, the Gate-B triviality
skip being the one such route and its eligibility test therefore a member**, or the production,
identity or transport of **any §5 cycle record, required or optional** — §5 entire and not the
Mechanics subsection this paragraph sits in, record duties being stated in both, and the optional
companions' slot rules carrying the nonce that keeps sibling cycles apart.** **Read it on the sentence, never on the section the sentence sits in.**
A sentence is a member when **it itself** fixes one of those things — what counts as a valid
finding line, which files or records are owed, what ends a hold. It is not a member when it only
shapes what a review produces, as the choice of reviewer, the lens set and **prompt wording that only frames the
review question** do: those change the findings without deciding what a finding *is* or what the
ordering may do with one. **Prompt wording that fixes a valid input is a member**, the gate-prompt
sentences defining a finding line and the `NO FINDINGS` signal being exactly that. **No paragraph is exempt as a paragraph** — a sentence inside a routing or prompt paragraph
that fixes a valid input or an owed file is a member, and a sentence anywhere that only influences
the findings is not. The examples follow the test; they do not stand in for it.
Asking instead what an imagined edit would do decides nothing, because
any rule can be edited into deciding a branch and none decides one when edited cosmetically, so
membership would follow the edit a reader pictured rather than the text in front of them. The
last clause is why the squash carry belongs: it moves no pass and
decides no branch, and a record that does not survive the merge is unreachable from the squash
commit and from `main`'s history. A curve without a cycle field cannot be reliably told from
another cycle's in every multi-cycle context — kind and surrounding context sometimes separate
them, which is why the standing rule calls missing attribution a limitation rather than a
disqualification — a slot rule without a nonce cannot keep sibling cycles
apart — the bare names staying reserved for the legacy single-cycle case they already serve — a
carry rule naming records a project does not produce is inert, and a clean predicate without the
fix-set boundary it reads decides membership by accident.
**A project whose text carries some of them and not others, or carries all of them in versions
that disagree, stops and has a human complete, revert or reconcile the adoption before running a
gate under it.** **The test classifies sentences that are present, and completeness is not among
what it establishes**: where an adoption drops a member together with every sentence that would
refer to it, what remains reads as coherent and nothing in it marks the absence. **That bounds
what this text lets a reader detect, never what the rule obliges** — a partial adoption is a stop
however it becomes known, and learning of it from outside this text is learning of it.
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
Mechanics · Severity states it, **which scopes it to the assigned fix set**, so a recurrence of
one already validly dismissed **stays resolved on the terms the closure ordering sets** and owes
neither a second dismissal nor a repair, while a recurrence failing any of them is an ordinary
fresh finding;
the hold stands until
its answers are given, and **what the answer does is the closure ordering's**.
**A pass is credited clean or not on its own findings**, as that ordering defines cleanliness;
surfacing a finding that carries a scope-stop trigger is what withholds the credit, and no
credit is withheld for surfacing alone. Reading this as "stop instead of fixing" would put the
exit in competition with the rule that every **in-set** Blocker and Major resolves, and then
nothing could satisfy both.
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
signal is what lets a pass be read as clean without inspecting it, and a pass carrying only Minors
**and no scope-stop trigger** is clean too and could never produce that file:
```

**The gate-prompt template's clean sentence**, in the block both gates paste.
```
A **clean findings file** is the single body line `NO FINDINGS` with `END OF FINDINGS (0 total)`.
```

**The Gate-A cadence** — revision becomes conditional, since unconditional it tells a Minor-only
pass to manufacture the repair the severity rule forbids.
```
Each pass: validate, revise **where a repair is required**, and re-run **where the closure
ordering selects its continue branch** — where it selects a suspension instead, the answer comes
first and that ordering says what the answer produces.
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
the curve duty owed, the nonce duties at their strictest, **every suspension binding, since
starting rules that cannot be established cannot be read as having waived an open hold**, **the
repeated-dismissal cleanliness exclusion unavailable, a cycle that cannot establish its starting
rules being unable to establish that they contained it**, **the parked state binding after a closing act that cannot
be repaired, a cycle whose starting rules cannot be established being the last one that should be
left with no terminal transition**, and **every closure condition and
pass-cost rule this change ships owed rather than waived — Gate A's content condition and its
commit-carry duty, and the further pass an assigned-fix-set change costs — since a rule that cannot
be established as absent is cheaper to owe than to skip** —
```

---

## I. What this text does not settle

- **Minor, collected and open (pass 17 finding 9 is resolved above; this is the remainder):**
  nothing in this file establishes that the edit set is complete. It is the sites known at pass
  17, plus the seven hook reminder strings §F items 10–13 and 15–17 added at passes 53, 54 and 55 — which is itself
  evidence that the set was not complete. **The plan sweeps both prompt copies and the shipped
  hook's reminder strings against the rule** — a live sentence the ordering falsifies gets
  edited — and prints what it found; a spec cannot establish that claim against text the same
  change rewrites, which is the mechanism that produced a finding at passes 15, 16 and 17.
- **Partial adoption is instructed against, never detected.** §G says so in its own words.
- **Which exit a cycle took is not observable from history.** The transport left with the record
  (successor story) and no story has taken it. An admitted gap, unowned.
- **Deferred out of this change on Daniel's decision of 2026-09-13: a Gate-B tree-equality
  condition.** Its purpose was to close the gap between what the final review request selected and
  what the closing commit carries — content staged before the review, or staged by a hook during
  the commit, reaches the closing commit through neither review branch. **The gap is real and this
  change does not close it.** Gate B's existing review, re-review and evidence duties are unchanged
  and are not a substitute; **the gate hook is not one either**, its fingerprint being advisory and
  comparing its own inputs across its own invocations. Named as a later task and deliberately not
  worked out here.
- **A Gate-A closing act can publish a review input the final pass never read** (pass 29 finding
  2). The commit is written from the effective index, so a staged edit to a cited story's
  acceptance criteria or settled decisions — anything no source rule governs, profile values,
  cited-set membership and the assigned fix set being the ones that are governed — lands in the
  closing commit unchecked. **Neither gate answers this**: Gate B's own version of the
  hazard is the bullet above, deferred out of this delivery, and Gate A's has never been decided. Named here rather than answered, because answering it is a
  behaviour decision this change has not been given.
