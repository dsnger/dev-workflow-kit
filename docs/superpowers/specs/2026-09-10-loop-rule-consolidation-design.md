# §5 loop-rule consolidation: one closure ordering — Design

**Date:** 2026-09-10 · **Status:** DRAFT — in Gate A, not yet approved
**Story:** `docs/superpowers/stories/2026-08-29-loop-rule-consolidation-story.md`
**Profile:** read from that header at every pass, never from here — it is the only writable
copy, and a value copied here would be a remembered value.

Prompt-only, in two mirrored copies: `CLAUDE.md` §5 (**C** below) and the inline template in
`plugins/dev-workflow/commands/workflow-init.md` (**W** below). No file under
`plugins/dev-workflow/hooks/` changes. Line numbers cite the tree at `7c0d475` (main) and are
re-read at execution; the plan carries the `grep -n` sites. The old-conditions accounting in §5
cites ids `a1`…`j4`, defined in
`docs/superpowers/specs/2026-09-10-loop-rule-consolidation-condition-inventory.md` beside this
file: 135 conditions (22 + 18 + 20 + 7 + 11 + 7 + 4 + 26 + 16 + 4) quoted from `7c0d475`, so a
reader can check the accounting rather than take it. A sentence outside those passages is
cited by its lead phrase and C line.

---

## 1. Intent

**What ships.** One closure ordering, stated once in each copy, that says which exit *closes* a
cycle and which merely *suspend* it, in what order a pass is read so the ranking is executable
rather than asserted, what any set of suspensions at once does, and which of the four standing
duties participate in that ordering versus gate it as preconditions. On top of it: one
commit-body record form with two labels, `Accepted:` and `Declined:`, so a user's answer on a
surfaced finding has one rule in both directions and is legible in history to whoever reads it;
the answer to what a severity demotion does to the loop-health counts; the answer to the pass-4
report when prior-pass history is unavailable; and the deferred slot discriminator, dissolved
rather than shipped. **What does not:** the pass floor and severity semantics, which the parent
shipped and this spec reads as given, and everything §11 lists as parked.

---

## 2. Settled inputs

The story's §4 table, decisions 1–10, is the design's starting point and is not restated here;
each is cited below as **D1**…**D10** (with **D9b**, **D9c**). Two implementation facts the
parent cycle established are read as given: a pass's cleanliness is a fact about what that pass
found and is **never rewritten** — an answer changes whether the *cycle* may close; and the
findings files establish the **inventory** of findings, not their resolutions. What the table
does not settle, this spec decides in the section that uses it: the evaluation order and the
field and file set each predicate reads; the duties' classification; the scope stop's two
triggers and what each answer does; what a stuck or two-tell answer produces; the records'
wording, attribution and recording point and the `Accepted:` label; and the raw-severity rule.
Five standing sentences are edited at their source rather than worked around — the two that
use *clean* in the file's sense, the resolve duty that never stated its scope, the curve's `?`
rationale, which answered the unavailable-history question the other way, and the Gate-A
cadence, which made a revision unconditional (§4 items 11–15).

---

## 3. The closure ordering — the block that ships

It sits in §5 **immediately before** the paragraph "**What a loop absorbs, and what stops it**",
in both copies, byte-identical. It states the ordering once; the paragraphs after it keep their
triggers and point at it. Verbatim as it will ship:

```
**How a cycle ends — one ordering, stated here and referenced everywhere else.** A pass is
read in a fixed order, because every rule below bears on one decision — may this cycle close —
and a stated order is what stops them qualifying each other. Every predicate here reads the
validated findings file **or files** of the logical pass as their **concatenation** — a `full`
Gate-B pass has two, and one branch alone is already an incomplete pass — at **effective**
severity, after the Mechanics severity ceiling, because cleanliness is about what the cycle
must repair and the ceiling is what decides that. **Both branches' lines count** for the health
measures, the curve rule already summing the branches into one entry; a finding whose five
fields match one in the other branch is **one** finding for holds and answers, so it is
answered once. Two things read the reviewer-written field from before the
ceiling: the **health measures** (Mechanics, Severity) — the per-pass counts, the clusters,
the tells, and **both severity-bearing conditions of the three-condition stuck reading**, its
Blocker curve and its regenerating Blocker or Major findings, since a predicate reading one
field for half of itself could not be read at all, while its third condition, the stated
coverage-sufficiency judgement, reads no severity field and the ceiling does not touch it —
and the **five-field key** the answer records match on, whose severity field is the one the
reviewer wrote, so that a ceiling cannot make two findings the same one.

**First, clean completion.** §5 uses *clean* in two senses and now says which is which. A
**clean findings file** is the `NO FINDINGS` signal the protocol defines. A **clean pass** is
the predicate below, read on the **logical pass with every required branch file combined**:
one branch's clean findings file never establishes a clean pass, the other being free to carry
an in-set Blocker. Every required file carrying that signal gives one, and a clean pass need
not have it, because a pass carrying only Minors and Nits, or findings a decline of this cycle
matches, is clean without being empty. **A pass is clean** when its findings carry no Blocker
or Major at effective severity that is **in the assigned fix set**, and **no scope-stop
trigger**. There are two triggers, defined here and nowhere else, so that cleanliness and
suspension read the same words: a **membership trigger** is a finding outside the current
assigned fix set **and not matched by a binding decline of this cycle** — such a decline having
put it outside by the user's own answer, for as long as the current set still excludes it — and
a **question trigger** is a finding opening a new structural or contract question, in-set or
not, which a decline never suppresses, the five fields it records identifying a finding and
never a question. Both are properties of the findings and the set, read before any branch below
runs, which is what makes this order executable rather than asserted: no predicate here waits
on an act a lower branch performs. A pass
with **zero** findings is clean whatever the floor, because a floor buys further looks at an
artifact that keeps yielding findings, and one yielding none has already given what those
looks were for. **A clean pass at or above the derived floor,
or a zero-finding pass, closes the cycle**, under the final-acceptance preconditions the floor
section already states and this ordering does not restate — the cited set and every profile
re-read before the pass is accepted as final, a header or profile that changed during it
making the pass not final and costing the further pass that section requires. A plateau or
tells present on the closing pass go into the
closing report and never block it, because reporting "will not converge" on a converged loop
is a false report, and the clearly-stuck paragraph says the same of its own exit. **No other
pass outcome closes a cycle**, because every other pass either leaves a required repair, a
finding hold or a question outstanding, or has an unmet closure precondition such as the
floor — and closing over any of those is the failure this ordering exists to prevent. The one
termination that is not a pass outcome is the Gate-B triviality skip, which ends a cycle
having run no passes and is outside this ordering entirely.

**Second, only a pass that is not a clean completion can suspend** — that order is what makes
"clean completion outranks the two-tell stop" executable rather than asserted. Three
suspensions, by the names their paragraphs use: the **scope stop**, raised by either trigger
defined above — a **membership stop** by the first, a **question stop** by the second; the
**clearly-stuck exit**; and the **two-tell stop**. A suspension waives nothing — the floor, the
Blocker/Major filter and the clean-final-pass rule stand while it does. Any non-empty set of
them can apply to one pass: **one surface, every reason reported, every question asked**,
because a reason left out is a decision made by omission. A finding surfaced solely by the
stuck or two-tell reading is not a scope-stop finding; one that also carries either trigger
takes the scope stop's answers at that same surface — it is not asked twice. This branch
defines nothing: the triggers are the first branch's, and what a changed field does to a
re-raised finding is Mechanics', in the answer records. A reader who finds a rule here that is
not in one of those two has found a defect.

**Third, a pass that neither closes nor suspends continues** — the loop runs another pass on
the **current** artifact, revised or not. Below the floor a clean pass lands here, and so does
a pass whose only findings are Minors and Nits, which are collected and never iterated and so
may leave nothing to revise. It is a branch and not an inference, because "does not close"
read alone says nothing about whether to run again.

**The four standing duties, classified.** The **derived floor** is a precondition on
closure: it gates closing, and is discharged by the count of valid logical passes reaching
the floor with the last of them clean, or by the zero-finding exit. The **Blocker/Major-resolve
duty** is a precondition on closure and on any pass being clean: it gates both, and is
discharged, for every in-set Blocker and Major, by a validated repair **or a validated
dismissal carrying its one-line why** — the advisory rule above, unchanged — followed by a
validated pass that finds **no in-set Blocker or Major at effective severity**, which is the
clean predicate's own wording so that the duty and the predicate cannot drift apart.
**A dismissal is not a decline**: a dismissal is the author's judgement
that the finding is not true of the artifact, a decline is the user's decision that a true
finding stays outside the fix set, and only the second is an answer at a membership stop.
The **hold** a surfaced finding places on closure is part of the ordering: it gates closing
while it stands, and is discharged by the answers that finding requires, below. **A scope stop
is the only stop that holds a finding**, because it is the only one whose question is about a
finding; the health exits hold nothing, which is why their answer is continue or stop rather
than a direction on anything. **No-clean-credit** — no pass carrying a scope-stop trigger is
credited as clean — is part of the ordering and a fact about that pass, discharged by nothing:
a later pass is judged on its own findings, so an answer never closes the cycle on the pass
that surfaced the finding. **It is not a second test beside the clean predicate; it is that
predicate's second half**, which is why it is stated in the same words: the trigger makes the
pass unclean directly, so nothing has to read the act of surfacing.
**Where the other two exits stand in this duty**, said here so no reader supplies a rule for
them. The two-tell stop surfaces tells and not a finding, and was never in its domain. The
clearly-stuck exit does surface findings, and where those carry a scope-stop trigger the duty
reaches them exactly as it reaches any other. Where they do not — the two shapes the
composition paragraph names, a demoted in-set finding and a declined out-of-set one — the
pass is clean at effective severity, the two predicates reading different fields on purpose,
and **clean completion wins by D3**: the pass closes at or above the floor and continues below
it. The order decides that; the duty never needed to.

**What a suspension asks, and what ends it.** Only a scope stop raises a **hold**, on its
finding. **The hold ends when every answer that finding requires has been given, in whichever
direction each is given** — one answer for a single-trigger finding, both the question decision
and the membership answer for one carrying both. That is **one rule with two parts**, how many
answers and which way each may go, and neither part is a test the other has to pass: a hold
only accepting could end would be the resolve duty under another name.
At a membership stop the answer is **accept** (the finding joins the
fix set, where its effective severity governs it) or **decline** (the finding stays outside,
binding for the rest of this cycle). Either answer is **recorded** — Mechanics, the answer
records — and that record is where a later pass reads it.
**Membership is answered against the set as it stood at the pass that raised the question**,
not against the set as it is when the answer arrives, and an explicit attributable answer is
required whatever the governing artifacts do meanwhile — a hold discharged by a scope change
is a hold nobody answered. A later broadening is a new fact the **next** pass reads; it never
discharges a standing hold. At a question
stop the answer is the user's decision on the question, and membership does not change: an
in-set finding then routes through its effective severity like any other, under that decision;
an out-of-set finding that opened the question is a membership stop as well and takes accept or
decline. **Effective severity routes an in-set finding in one place only** — the resolve duty
above, which says what a Blocker or Major owes and that a Minor or Nit is collected and never
iterated — and every branch here that puts a finding in the set hands it to that duty rather
than restating it. **Decline is available only at a membership stop**, because that is the only stop
whose question is whether a finding belongs to the set, and a decline anywhere else would
waive work the cycle owes. The stuck and two-tell readings
raise no hold: each asks one question, **continue or stop**. Continue is that suspension's
resuming answer, and where it is the last one outstanding the loop resumes on the
artifact as revised and the fix set as the governing artifacts now assign it — where several
plans or stories govern one cycle, the union of the scopes they assign — **plus the findings
this cycle accepted into it**, which its commit bodies record (Mechanics, the answer records).
One no body records is not in the set, and the reviewer raises it again on the next pass like
any other, which is the ordinary route and not a special one. A finding that a
narrowing has put outside the set surfaces at the next pass as a membership stop. **Stop
leaves the suspension standing**: the cycle stays open under its nonce, resumable by a later
continue, nothing it wrote is a closing commit, and an open cycle nobody resumes is a human's
to resolve, exactly as the nonce rules already say of open cycles.

**Composition, and what cannot happen.** Every **question** is answered on its own, and the
loop resumes only when every answer resumes it — accept or decline at a membership stop, a
decision at a question stop, continue at the health readings; one stop answer leaves the
whole suspension standing, because a loop resumed over an unanswered question decides it by
running. **The stuck and two-tell readings raise one question between them, not two**, both
asking continue or stop, so one answer carrying every reason ends both — which is not an
exception to the sentence before it but an instance of it, there being one question there to
answer. **Two pairings cannot occur**, and
no rule ranks them: clean completion and a **scope stop**, since that stop's triggers are the
clean predicate's own second half, so a pass raising one is not clean; and a zero-finding pass
and any suspension, since it has nothing to surface, nothing regenerating, no cluster and no
require↔withdraw pair. **Clean completion and the clearly-stuck exit can**, and the overlap is
admitted rather than argued away. **Two shapes reach it**, since that exit reads
reviewer-written severity and membership while cleanliness reads effective severity and the
set: an **in-set** Blocker or Major the ceiling demotes below Major, and an **out-of-set** one
matched by a binding decline of this cycle, which raises no membership trigger and sits outside
the set the clean predicate reads. Either can regenerate across passes on a pass that is clean.
**The order decides both and no new rule is needed** — the pass closes at or
above the floor, ranking the exit exactly as the clearly-stuck paragraph's own precedence
sentence says, and continues below it, where nothing closes anyway. **This ordering is one component of the
closure-record contract** the one-contract rule names, and a copy carrying it without the
rest of that list is a partial adoption that stops there.
```

Where the block maps onto the criteria: the three branches are AC 4, the duties paragraph
AC 2, the composition sentences AC 1. The scope stop's two triggers are `b11` (membership) and
`b13` (question) read separately, because an in-set finding that opens a question can neither
join nor stay outside the set and needs its own answer. Sentences the block points at rather
than restating (`a13` as §5(a) replaces it): C:116–118, C:760–764, C:422–424, C:176, and the
clearly-stuck precedence sentence, kept verbatim under **D3**.

---

## 4. The answer records — one form, two labels

**The rule ships as the block below**, which is the text and not a summary of it; this section
adds only what the block does not carry. Decisions implemented: **D6** availability, **D7**
binding, **D8** the explicit decision, **D9b** the sameness test, **D9c** the unverified
reading, **D9** the transport — whose "closing commit body" is therefore the *last* body to
carry a record, not the first. **D5** is why §3's clean predicate names the fix set rather than
the decline: a decline is only ever a fact about membership, so it cannot be read as excusing
an in-set finding, which is the gate-off route a fabricated record would otherwise open.

**The `Accepted:` label was beyond the story's *original* scope and is now authorised by it**:
Daniel decided it at this cycle's Gate-A pass-4 scope stop, and the story records the expansion
in its §2 and adds acceptance criterion 7 (at `4625679`). Three passes had found the same hole
— an acceptance put a finding in the fix set and no artifact carried it, so a cycle could close
over work it had agreed to do with nothing left saying so. The cheapest close was a second
label on a record whose form, transport, nonce and carry rules already existed. **What the
label closes and what it leaves open** is criterion 7's second half and the block states it:
the decision becomes legible to a human reading the history, and no more — a later revision of
this spec had it drive an automatic recovery procedure, which grew an identity line, a
snapshot rule, an authoritative-body rule and a branch search, produced Blockers on each of
three successive passes, and was cut back to this on Daniel's decision at the pass-9 two-tell
stop. This cycle runs under the
pre-change rules and writes no such record for its own acceptance; the dispositions file and
the working record are what today's rules provide.

**The block that ships**, in Mechanics, placed **immediately after the whole human-exception
passage** — after "**What the record is worth.**" (C:1028–1033 / W:1212–1217) and before
"- **Timeout / abort:**" (C:1034 / W:1218), at the same two-space indent. Verbatim,
byte-identical in both copies:

````
  **Recording an answer at a membership stop.** A membership stop asks whether a surfaced
  finding joins the assigned fix set, and the user's answer is recorded under one of two
  labels sharing one form. **Accepted** puts the finding in the set, where the resolve duty
  governs it — this block adds nothing to what that duty says. **Declined** keeps it out and
  ends the membership half of its hold — the
  whole of it where membership was all that finding raised. Both are available at a
  membership stop and nowhere else: not for an in-set
  Blocker or Major, which owes resolution already, and neither is the answer to a question
  stop, a stuck or two-tell surface, a below-floor pass, an unclean final pass, or any Gate-A,
  Gate-B or evidence obligation — of the list the human-exception form is never the answer to,
  the membership stop is the one item these records answer. Each must be an **explicit,
  attributable decision on that specific finding** — never silence, never a general remark
  about scope, never inferred — because a fix set changed by inference is a fix set nobody
  chose.

  ```
  Accepted: <handle> · <date> · cycle <nonce>
  Finding: <severity> | <location> | <defect> | <consequence> | <suggested fix>

  Declined: <handle> · <date> · cycle <nonce>
  Finding: <severity> | <location> | <defect> | <consequence> | <suggested fix>
  ```

  The `Finding:` line is the finding line from the pass's findings file with its confidence
  field removed — the five fields the sameness test reads, in the file's order, a literal pipe
  escaped as `\|` exactly as there.

  **Rules both labels share.** Each carries the **cycle nonce**, because a record that cannot
  be attributed to its cycle cannot bind to it. Each is **written when made**, into the cycle's
  next commit body on the branch — a spec or plan revision commit for a Gate-A cycle, the
  `WIP:` amend for Gate B — **and that commit is made before the next pass runs**: an answer
  held only in a session is one compaction away from being lost; the advisory working record
  may carry it meanwhile and does not bind. Where the cycle has no artifact revision to carry
  it — the answered finding was that pass's only one — the record goes in an **empty commit of
  its own**, the destination the human-exception rule above already blesses: "An empty commit
  carrying only the record is a legitimate destination". Each is **restated in the cycle's
  closing body**, so that the record a reader of history meets is not buried in an intermediate
  commit, and each is **copied on squash-merge** (the carry rule above). Each is an
  **unverified assertion** of the same kind as the human exception — nothing checks that the
  handle belongs to whoever decided, that a human was asked, or that the reason is honest.

  **Binding, and the sameness test.** A decline **binds for the remainder of its cycle**, with
  no effect in any later one, and never qualifies the Blocker/Major-resolve duty — which the
  declined finding does not reach **while it stays outside the set**, the duty being scoped to
  what is in it. A later pass raises **the same finding** when all five of
  location, defect, severity, consequence and suggested fix match, read on meaning rather than
  bytes, since a reviewer rewrites its sentences between passes; the severity read is the one
  the reviewer wrote, per the ordering's field rule. **At most one effective label per cycle
  and five-field key.** Exactly equivalent same-label records collapse to one, which is what
  makes a restatement idempotent; two records disagreeing on that key — opposite labels, or one
  label with disagreeing attribution — are **a question for the user**, answered and recorded
  like any other answer, because a finding both in the set and kept out of it has no reading,
  and picking either would let a fabricated or replayed record decide which. It is a question
  and not a cycle state: the loop already knows how to stop on one and resume on its answer.
  What a matching decline does to a re-raised finding is the closure
  ordering's membership trigger, which is defined there and not restated here. **Any
  difference — severity included — or any
  genuine uncertainty makes it a new finding**, classified afresh against the current fix set
  and the question predicate rather than inheriting a stop from the finding it resembles. A
  decline keeps a finding out and never excuses one that is in: a declined finding the fix set
  later comes to include owes resolution like any other. **The binding and the set are
  different things**, which is how both hold at once: the decline binds the *decision* for the
  rest of the cycle, so that question is never re-asked, while membership is owned by the
  governing artifacts — a broadening puts the finding in the set without the decline having
  expired, and every exclusion this record grants reads "while the current set still excludes
  it". An acceptance does not expire with
  its pass: the finding is in the set until the cycle closes.

  **What each is worth.** A decline **releases a hold** and an acceptance **puts a finding in
  the fix set**, neither of which the human-exception form ever does. Narrowness bounds what a
  false record can do — one fully identified finding, one cycle, **as far as distinct nonces
  allow**: two cycles sharing or redrawing a nonce are indistinguishable to these records as
  to every other, so a replayed answer can bind to the wrong cycle, and a bound is not safety.
  **What a record buys, and what it does not.** It makes the decision **legible in history to
  a human reading it**, and that is the whole of it. It does not make an agent's recovery
  automatic: nothing checks that a later cycle looked, no procedure is obliged to search for
  it, and a cycle that lost its session is not promised its own answers back. Nor does any
  record carry a question stop's decision where that changed no membership — the five fields
  identify a finding and never a question — or a stuck or two-tell surface with its
  continue-or-stop answer; after a lost session neither is reconstructable at all. A cycle that
  resumes **continues on what it can read**, and the reviewer re-raises whatever is still true
  of the artifact, which is the ordinary route and not a special one. So a replacement cycle
  can review and close the same artifact while an older one stays open. The record makes that
  discoverable to whoever reads the history, which is less than preventing it and is what this
  record is for.

  **These records are one component of the closure-record contract** the one-contract rule
  above names, and a copy carrying them without the rest of that list is a partial adoption
  that stops there.
````

**Which rules the answer modifies** (story AC 3): the scope stop's resume sentence (`b12`),
and the hold and the clean-pass definition, both in the §3 block — and no other, not the
Blocker/Major-resolve duty, the floor, the tells or the stuck reading. The Severity bullet's
edit (item 13) is not a counter-example: it states **the duty's own scope**, which **D5**
always implied, and names no decline. A reader finding either label
qualifying a *closure* rule outside those three has found a defect; a reader finding the
records absent from any transport, attribution, activation or threat site listed next has
found the opposite one. The two lists answer different questions: what the answer *changes*,
and what must *carry* it.

**Existing sentences that must name them**, both copies, old → new. Line numbers are C's; W's
are in the site map and re-read at execution.

1. **Squash carry** (C:892 / W:1076, `j1`). OLD: "…copy every evidence entry, every
   human-exception record, the provenance lines, the curves and any skipped cycle's skip
   record TOGETHER WITH THE SKIP REASON IT POINTS AT…". NEW: "…copy every evidence entry,
   every human-exception record, **every answer record (part of the closure-record contract
   above; a copy carrying this without the rest stops there)**, the provenance lines, the
   curves and any skipped cycle's skip record TOGETHER WITH THE SKIP REASON IT POINTS AT…".
   Six members. A record restated in the closing body and copied here reaches the squash body
   once, because exactly equivalent same-label records collapse under the sameness rule.
2. **The named nonce set** (C:385–387 / W:579–581). OLD: "**and that set is named rather than
   left open**: the provenance line, the per-pass curve (including a skip record standing in
   for one), the cycle's findings slots, and its advisory working record." NEW: "**and that set
   is named rather than left open**: the provenance line, the per-pass curve (including a skip
   record standing in for one), **any answer record (Mechanics; part of the closure-record
   contract below, and a copy carrying this without the rest stops there)**, the cycle's
   findings slots, and its advisory working record."
3. **The nonce exemption** (C:397–399 / W:591–593). OLD: "The nonce is not required in records
   this change neither introduces nor keys to a cycle — the evidence entry and a
   human-exception record among them." NEW: "The nonce is not required in records that are not
   keyed to a cycle — the evidence entry and a human-exception record among them; **an answer
   record is keyed to its cycle and carries it (part of the closure-record contract below; a
   copy carrying this without the rest stops there)**." The old "this change" dated the
   sentence to the parent; the new one states the criterion.
4. **"Both shipped records below"** (C:367 / W:561). OLD: "Both shipped records below carry a
   **cycle field**, because…". NEW: "Both shipped records below carry a **cycle field** — and
   so do the answer records in Mechanics, part of the closure-record contract below, a copy
   carrying this without the rest stopping there — because…". A load-bearing count a third
   cycle-attributed record would otherwise falsify.
5. **The unknown-start fallback** (C:153–167 / W:360–374, `i4`–`i8`, extended at `i12`'s
   invitation). OLD: "…at minimum floor 3, severity classified without the demotion, the
   provenance-line duty owed, the curve duty owed, and the nonce duties at their strictest…".
   NEW: "…at minimum floor 3, severity classified without the demotion, the provenance-line
   duty owed, the curve duty owed, the nonce duties at their strictest, **every suspension
   binding, and answer records not attributable to the nonce this fallback minted treated as
   absent, so that no inherited hold is released and no inherited acceptance is claimed —
   records made and recorded under that nonce are the cycle's own and are honoured (part of the
   closure-record contract below; a copy carrying this without the rest stops there)**…".
   `i12`'s sentence stays as written; this is the addition it invites. The time bound matters:
   treating *every* answer as absent would leave a fallback cycle unable to release a hold it
   raised itself, **D7** unmet.
6. **The human-exception "which commit" rule** (C:988–990 / W:1172–1174, `h3`–`h6`). Unchanged.
   The answer records carry their own, deliberately different, because an answer must survive
   to the next pass while the human exception only has to survive to history.
7. **The gate-off surface** (C:143–151 / W:350–358). OLD tail: "…silencing reminders; or not
   running a pass and reporting that it ran." NEW tail: "…silencing reminders; not running a
   pass and reporting that it ran; **recording a decline nobody made, or one on an in-set
   finding; or omitting an acceptance the cycle owes from the body that would carry it (part
   of the closure-record contract below; a copy carrying this without the rest stops there)**."
   The list says it is not complete; this change opens those routes and names them, as the
   parent did for the stated floor.
8. **The closing message and the soft-reset path** (C:834–838 / W:1018–1022). Two insertions
   into a sentence whose other clauses are unchanged. After "…which owes no entry" add: "—
   **and the cycle's answer records, including any held only in WIP bodies a
   `git reset --soft` collapsed**: the single commit after the reset carries them all, because
   a body the reset discards is unreachable from the commit that replaces it
   (part of the closure-record contract below; a copy carrying this without the rest stops
   there)". In the
   sentence after it, "so an entry written only into the WIP body" becomes "so an entry **or
   record** written only into the WIP body". The `git reset --soft` sentence itself
   (C:829–830 / W:1013–1014) is unchanged.
9. **The one-contract paragraph** (C:879–890 / W:1063–1074), which is where the contract gets
   its **one name and one membership list**, so that each mergeable piece cites the name
   instead of naming every peer. OLD opening: "…this carry rule
   **and the unknown-start activation semantics that say what a cycle owes when its starting
   rules cannot be established** depend on one another," NEW opening: "…this carry rule, **the
   closure-record contract — the closure ordering, the answer records, the severity rule's
   raw-versus-effective split and its assigned-fix-set boundary, the two clean-vocabulary
   edits, the answer records' membership in the named nonce set and the nonce exemption's
   criterion, the cycle-field count they falsify, the unknown-start item covering them, the
   closing-message carry, the squash carry, the curve's validity rule, the Gate-A cadence,
   the no-identity report, the gate-off routes they open, the four pointer sentences that send
   a reader to the ordering — in the floor paragraph, the absorb rule, the clearly-stuck
   paragraph and the tells paragraph — and the pass-4 report's unavailable-history block with
   its root condition** — and **the unknown-start activation semantics that say what a cycle owes
   when its starting rules cannot be established** depend on one another," and after "and a
   carry rule naming records a project does not produce is inert." (C:885) add: "an ordering
   without the answer records is a membership stop whose two answers nothing carries; answer
   records without the ordering are a release and a set change with no stop that asks for them;
   an ordering whose raw-versus-effective split has no counterpart in the severity rule, or a
   severity rule still calling that question unsettled and mandating a stop beside an ordering
   that decides it, is two answers to one question; and an answer record missing from the
   squash carry or the nonce set cannot survive a merge or be attributed." The stop sentence
   that follows is unchanged and now covers these states.
   Then, before it: "**A project carrying any component of this contract owes all of them.**
   The pieces are separately mergeable and are not separately adoptable, so a copy holding one
   without the rest is an incomplete adoption and stops here." **Both halves of the guard ship,
   and that reverses this cycle's earlier choice.** Pass 6 offered a central list or a marker
   on every mergeable hunk; the list was taken alone, and pass 7 showed why that is not enough
   — a list cannot police a merge that omits the list. So every hunk in this section also
   carries a short marker naming the contract, and the three blocks keep the longer sentence
   they already had. The list is what defines membership; the markers are what a partial merge
   still sees. **Rollback.** A cycle open when the text is
   reverted is governed by "a cycle already running finishes under the rules it started with"
   and "A revert is itself a shipping commit for the old rules" (C:153–154, C:165–166) where it
   can still establish those rules, and by the unknown-start fallback where it cannot. **Where
   the rollback removes the fallback too, neither is available and nothing here replaces
   them**: no record identifies the rule revision a cycle started under, so that cycle has no
   text describing what it owes. A residual, named and left to a human — not a stop this change
   can claim, since a stop needs shipped text and the rollback removed it.
10. **The no-identity rule's aftermath** (C:422–424 / W:616–618). OLD: "**Starting a new cycle
   does not close, adopt or retire the cycles those candidates belong to** — they stay open,
   keep their own nonces, and are a human's to resolve; the new cycle simply does not claim
   them." NEW: "**Starting a new cycle does not close, adopt or retire the cycles those
   candidates belong to** — they stay open, keep their own nonces, and are a human's to
   resolve; the new cycle simply does not claim them, **and names them in its first pass
   report, marking their exit and their answers unknown**, so the human this rule makes
   responsible learns they exist and nobody reads the new cycle as continuing them. **It
   inherits no answer**: whatever those cycles accepted or declined, this one asks again (part
   of the closure-record contract above; a copy carrying this without the rest stops there)."
   It adds no record — the report names state the workspace already holds — and closes the one
   shape "a human's to resolve" cannot reach: an open cycle nobody is told about.
11. **The findings-file protocol's clean sentence** (C:329 / W:523), inside the gate-prompt
   template both gates paste. OLD: "A clean pass is the single body line `NO FINDINGS` with
   `END OF FINDINGS (0 total)`." NEW: "A **clean findings file** is the single body line
   `NO FINDINGS` with `END OF FINDINGS (0 total)`." It describes a file and always did; the
   word *pass* in it is what makes §3's predicate look like a redefinition instead of the
   other sense. Its condition — what a reviewer writes when it finds nothing — is unchanged.
   Part of the closure-record contract below; a copy carrying this without the rest stops there.
12. **The Gate-A clean-signal sentence** (C:565–566 / W:756–757; the two copies wrap it
   differently, so the shared fragment is what is quoted). OLD: "…when a pass is clean — the
   explicit clean signal is what lets you exit the loop:". NEW: "…when a pass finds nothing —
   the explicit signal is what lets a pass be read as clean without inspecting it further:".
   Old condition: a `NO FINDINGS` file is what permits loop exit. Kept: the signal and why it
   is demanded. Changed: it makes a pass readable as clean rather than being the only way to
   be clean, since a pass carrying Minors alone is clean under the ordering and could never
   produce this file. Part of the closure-record contract below; a copy carrying this without
   the rest stops there. The other **six** uses of "clean pass" in each copy (C:117, 728, 750,
   761, 769, 827; W:324, 914, 936, 947, 955, 1011) are the closure sense the ordering defines
   and are correct as they stand — counted and checked, not assumed.
13. **The Severity bullet's resolve duty** (C:783–784 / W:969–970), which is the one place the
   duty is stated and the only one without a scope. OLD: "- **Severity:** Blocker
   (wrong/unsafe/breaks invariant) · Major (design flaw → rework) → both must resolve. Minor ·
   Nit → collect, never iterate." NEW: "- **Severity:** Blocker (wrong/unsafe/breaks
   invariant) · Major (design flaw → rework) → both must resolve, **for every finding in the
   assigned fix set** (the closure ordering above; part of the closure-record contract below,
   and a copy carrying this without the rest stops there). Minor · Nit → collect, never
   iterate." Old condition:
   every Blocker and Major resolves, unbounded. **Replaced**: the boundary **D5** always
   implied and no sentence carried. Without it a declined finding must stay outside the set
   and still bars closure, which is a pass that can neither close nor suspend. **The edit names
   the set and never a decline**, which is AC 3's second half: the answer moves a finding into
   or out of the set, and this duty says only what it demands of what is in it — a mention of
   the decline here would read as a direct waiver of Blocker/Major resolution rather than the
   membership decision it is. The (c)
   pointer that calls this "the resolve rule" (`c17`) needs no edit: it names the rule, and
   the rule now carries its own scope.

14. **The curve's one-entry-per-valid-pass paragraph** (C:943–950 / W:1127–1134), which is
   where `?` gets its rationale and where that rationale currently answers Q6 the other way.
   OLD, the clause: "so a resumed cycle may know a pass happened and not what it found, and
   zero and unknown are different facts." NEW: "so a cycle may have **validated a pass this
   session** and no longer hold what it found, and zero and unknown are different facts.
   **Knowing that a pass ran is not knowing it was valid**: where this session did not validate
   it and the slot is gone or unreadable, the pass is
   **omitted from the pass specification** rather than entered with `?`, because this grammar
   takes one entry per *valid* pass and has no way to say "may not have been one", and the
   report names the numbers it omitted (part of the closure-record contract above; a copy
   carrying this without the rest stops there)." Old condition: a resumed cycle's knowledge
   that a pass happened is enough to keep its entry, with `?` for the counts. **Replaced**:
   knowledge that it ran is separated from validation, using **§7's own predicate — this
   session validated it** — rather than a durability test no artifact satisfies, since this
   change introduces no pass-validity record. Kept: `?` itself, per series, for a validated
   pass whose counts are not recoverable. Without this edit the same missing slot both keeps an
   entry and is omitted.

15. **The Gate-A cadence** (C:573 / W:764), which makes a revision unconditional between
   passes. OLD: "Each pass: validate, revise, re-run." NEW: "Each pass: validate, revise
   **where the severity and scope rules require a repair**, re-run (part of the closure-record
   contract below; a copy carrying this without the rest stops there)." Old condition: every
   pass is followed by a revision before the next. Kept: the cadence and its order — validate
   first, re-run last. **Replaced**: the revision is conditional, because the ordering's
   continue branch reaches a below-floor pass whose only findings are Minors and Nits, which
   are collected and never iterated, and an unconditional "revise" tells that pass to
   manufacture the repair the severity rule forbids.

The shorter "Copy every record into the squash body" sentence inside the human-exception block
(C:1004–1007) is generic and already covers an answer record; it is not edited. The "records
every cycle owes" list (C:698) enumerates unconditional records only; an answer record is
conditional, like the human exception, and is not added.

---

## 5. Edits to the existing passages, with the old-conditions accounting

Ids are the committed inventory's (§2). "Kept" = the sentence stays; "moved" = it now lives in
the §3 block; "replaced" = the condition changes, and says how; "dropped" carries its reason.

**(a) The floor paragraphs** (C:72–136 / W:279–343) — **two edits**. First, **trim**
`a17`–`a19` and point at the block. OLD: "Your final pass must be clean — if the pass at the
floor still finds Blocker/Major, keep going until clean or clearly stuck → then STOP and
surface to the user. The only early exit below the floor is a pass with **zero** findings;
don't manufacture findings to pad." NEW: "Your final pass must be clean; how a cycle closes,
and what stops it short of closing, is the closure ordering below — don't manufacture findings
to pad." Second, `a13`. OLD: "Every other rule stated here about how a
cycle closes stands as written, and none of them is restated — a summary is where their
conditions would get dropped." NEW: "**This paragraph** restates none of them — a summary is
where their conditions would get dropped — and the closure ordering below is where they are
stated once and in order (part of the closure-record contract below; a copy carrying this
without the rest stops there)." Accounting: `a1`–`a12`, `a14`–`a17`, `a20`–`a22` kept; `a18`, `a19`
moved; **`a13` replaced**. Old condition: *no* rule about how a cycle closes is restated
anywhere. Kept: the prohibition and its reason, scoped to the paragraph it was written to
police. Changed: the ordering does restate closure rules, deliberately and as the one
authority, so a categorical reading would leave the shipped text contradicting itself — the
failure `a13` exists to prevent, arriving from the other direction.

**(b) What a loop absorbs** (C:195–223 / W:402–426) — **three sentence edits**, the triggers
stay. `b12` OLD: "…and it resumes the moment the user says whether the set now includes it."
NEW: "…and it resumes once the user has said whether the set now includes it — accepting or
declining it — **together with every other answer that pass's suspensions require, each
recorded as Mechanics requires**, under the closure ordering above." `b17`–`b18` OLD:
"Stopping this way is **not an exit from the gate**: the floor, the Blocker/Major filter and
the clean-final-pass rule all stand, and the loop resumes on the revised artifact once the
question is answered — what the stop prevents…" NEW: "Stopping this way is a **suspension**
under the closure ordering above (part of the closure-record contract below; a copy carrying
this without the rest stops there), and the loop resumes on the revised artifact **once every
answer that pass's suspensions require has been given** — what the stop prevents…". Third, in
**W only**, "…by its severity exactly as the severity rule already says…" becomes "…exactly as
Mechanics already says…", matching C for the reason §6's first row gives.

Accounting: `b1`–`b11`, `b13`–`b16` kept — `b6` among them, and it is worth naming: it fixes
the assigned set **before the pass being answered**, and the ordering's membership answer is
read against that same set rather than against a later one, so the two agree and `b6` needs no
edit. An earlier revision of this spec had membership re-read when the answer arrived, which
`b6` and **D4** both forbid — **D4** requiring a user answer for the hold to end at all — and
the reversal is recorded here rather than left as a silent narrowing. `b12` **replaced** — old: an *immediate* resume on
the membership answer alone. Kept: that the membership answer is what the stop asks for and
that either direction ends it. Changed: the resume waits for every answer the pass's
suspensions require, each recorded, because a loop resumed over an unanswered question decides
it by running. `b17` moved (the block's "a suspension waives nothing" sentence); `b18`
**replaced** the same way and for the same reason — old: resume once *the* question is
answered; new: once *every* required answer is given. W's remaining wording differences here
are untouched (§6).

**(c) Recognizing clearly stuck** (C:225–246 / W:428–449) — **keep** the precedence sentence
in full and **trim** what follows it. The sentence kept byte-for-byte (**D3**): "That third
condition is what makes a plateau rather than a finish, and it is why **a clean completion
takes precedence over this exit**: a Blocker/Major-free pass **at or above the floor** has
satisfied the clean-final-pass rule — collect the Minors and Nits and close — and reporting
"will not converge" on a converged loop is a false report." OLD, from "**Below the floor
nothing closes**" to the end of "…and then nothing could satisfy both.": replaced by
"That example is a clean-completion candidate only where the pass carries **no scope-stop
trigger** — a finding outside the assigned fix set, or one opening a new structural or
contract question — since a pass carrying either is not clean and the ordering above says
why. **Below the floor nothing closes**, exactly as that ordering says. This exit is
a **suspension** under it (part of the closure-record contract below; a copy carrying this
without the rest stops there): you surface with the findings still open, the resolve
rule is not waived by surfacing, and the loop resumes when every answer that pass's
suspensions require has been given." The kept sentence is not touched; the qualification is
adjacent to it, which is how **D3**'s verbatim requirement and the ordering can both hold —
edited, the sentence would say a Blocker/Major-free pass carrying a new out-of-set Minor
closes, and the ordering says it suspends. Accounting: `c1`–`c8`
kept; `c9`, `c10`, `c11` **kept verbatim and qualified** — the sentence is unchanged and a new
sentence beside it names the condition its example assumed and never stated, so the conditions
`c10` carries are narrowed by adjacency rather than by edit; `c12` kept (pointer form); `c13` moved (the
zero-finding exception); `c14` moved **to the ordering's continue branch** — the
Minor-below-floor pass that "keeps looping" is precisely one that neither closes nor suspends,
and the branch states it rather than leaving it to be read out of a negation; `c15`, `c17`
kept in the pointer sentence, `c17`'s "resolve rule" now reading with the assigned-fix-set
boundary §4 item 13 gives it, so the pointer needs no edit of its own; `c16` **replaced** —
old: a clearly-stuck surface leaves its finding open, which read alone gives this exit a hold.
Kept: that the findings are still open at the surface, and that the resolve duty is what keeps
them so. Changed: the **hold** belongs to the scope stop, the only stop whose question is about
a finding, while this exit asks continue or stop and holds nothing. Authority **D1**, which
makes all three exits suspensions and gives a suspension its own transitions; `c18`
**replaced** — old: no pass is credited as clean on a clearly-stuck surface, unconditionally.
Kept: the rule wherever it decides anything — a pass carrying a scope-stop trigger is unclean,
and this exit is reached only on a pass that did not close. Changed: where the exit's
regenerating findings are in-set and the ceiling demotes them below Major, the pass is clean at
effective severity and closes at or above the floor. Authority **D3**, which ranks clean
completion above this exit — under the old reading D3's own preserved sentence and `c18` would
decide that pass in opposite directions. The two-tell
stop was never in either condition's domain, surfacing tells and not a finding, and the
ordering says so rather than leaving it inferred; `c19` **replaced** — old: the loop resumes on
whatever the user decides, unconditionally; new: it resumes on a resuming answer and a stop
leaves the suspension standing, because an unconditional resume is the stop-with-no-transition
path AC 4 forbids; `c20` **dropped** — it argued that reading the exit as "stop instead of
fixing" would compete with the resolve duty, and the block states that argument's conclusion
as a rule instead.

**(d) From pass 4 onward** (C:255–261 / W:459–465) — **add** the Q6 sentence (§7). `d1`–`d7`
kept, unchanged.

**(e) The five tells** (C:263–268 / W:467–472) — **one edit and one added sentence**. The edit
is `e7`, the shared fragment both copies carry (C:266 / W:470). OLD: "**Any two present makes
stop-and-surface mandatory, not discretionary**". NEW: "**Any two present makes stop-and-surface
mandatory, not discretionary, where the clean-completion branch did not close the pass**". Then
the pointer, after `e10`: "This stop is a **suspension** under the closure ordering above (part
of the closure-record contract below; a copy carrying this without the rest stops there), and
the loop resumes when every answer that pass's suspensions require has been given."

Accounting: `e1`–`e6`, `e8`–`e11` kept; `e7` **qualified** — old: two tells make the stop
mandatory, unconditionally. Kept: the threshold, its mandatory force, and that the stuck reading
is not a precondition for it. Changed: it is read after clean completion, not beside it.
Authority **D2**, which ranks clean completion above this stop — unqualified, `e7` and the
ordering decide a clean two-tell pass at or above the floor in opposite directions, which is
AC 1's reachable conflict and the one thing this passage must not leave standing.

**(f) The two rules above do not compete** (C:275–287 / W:473–483) — **unchanged**. "The two
rules above" still names the absorb rule and the stuck reading; the block sits before both and
adds no third rule between them. Accounting: `f1`–`f7` kept, unchanged; `f1` remains true
because the block composes the suspensions and ranks none over another.

**(g) Mechanics · Severity · the handed-over question** (C:810–815 / W:996–999) — **replace**
the whole paragraph, both copies, with the answer. NEW:

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
  that same judgement would hide it. **This split is one component of the closure-record
  contract** the one-contract rule below names, and a copy carrying it without the rest of
  that list is a partial adoption that stops there.
```

Accounting: `g1` **dropped** (the unsettled statement, now settled); `g2`, `g3` **dropped**
(the interim report-and-stop duty existed only until the question was settled); `g4`
**dropped** in C (the ownership sentence, discharged by this change), and W, which never
carried it, gets the same replacement — removing the one deliberate story-path difference.

**(h) Recording a human exception** (C:977–1033 / W:1161–1217) — **unchanged**, and the
"**Recording an answer at a membership stop.**" block (§4, verbatim) is added immediately after
its last paragraph, before "- **Timeout / abort:**". `h1`–`h26` kept; `h17` stays true of the
human-exception form, and the answer-record block says which item of that list it *is* the
answer to.

**(i) When these rules bind** (C:153–167 / W:360–374) — **extend** the strict-reading list
(§4 item 5); `i1`–`i16` kept. **(j) The squash carry** (C:892 / W:1076) — **extend** (§4 item
1); `j1`–`j4` kept. Also touched, outside the inventoried passages: §4 items 2, 3, 4, 7–15.

---

## 6. Parity

The two copies must agree on every rule this spec changes. The block (§3), the answer-record
block (§4), the (g) replacement, the Q6 text and every list extension ship byte-identical in C
and W. The pre-existing divergences the inventory found are handled as follows:

| Divergence | Kind | This change |
|---|---|---|
| (b) cross-reference "Mechanics" (C) vs "the severity rule" (W) | **not deliberate**: the inventory's reason — that W has no such section — is false (W:968) | **aligned**: W takes C's wording (§5(b)) |
| (b) "exactly how" (C) vs "is how" (W); closing rationale reworded; C-only `infinite-portfolio-canvas` parenthetical | rationale and field citation | **as-is**, stated |
| (e) "you report" (C) vs "report" (W); C-only "Recorded rationale" Bricks paragraph | rationale | **as-is**, stated |
| (f) evidence framing; C-only hypothesis qualifier; punctuation of the late-Blockers clause | rationale | **as-is**, stated; (f) is not edited |
| (c)/(d) paragraph break: C fuses the surfacing block onto "Every pass report states three things" (no blank line at C:246/247); W separates them | structural | **aligned**: the (c) edit re-paragraphs the surfacing block, and C gains the blank line, so the floor-report paragraph stands alone in both |
| (e)/(f) paragraph break: W runs the five-tells paragraph into "The two rules above" (no blank line at W:472/473); C has the Bricks paragraph between | structural | **aligned**: W gains a blank line before "The two rules above"; the Bricks paragraph stays C-only |

The parity check at execution: extract each edited passage from both files by its lead phrase
and `diff` them; the only differences permitted are the rows marked as-is, and the result is
part of the evidence entry (§9). Any other difference is a defect, not a wording choice. The
Mechanics region the answer-record block joins is byte-identical between the copies today
(C:840–1033 = W:1024–1217) and stays so.

---

## 7. Q6 — the pass-4 report without prior-pass history

Appended to the "**From pass 4 onward**" paragraph, both copies, after "…demanding what an
earlier pass had removed.":

```
**Where an earlier pass's findings file is unavailable**, the report says so before it reads
anything. **First the root**, which is a condition on the current pass being valid at all and
not a stop of its own. The slots live in `.context/codex-reviews/` under the top-level
directory of the checkout this cycle is running in — the same root the pass call is given as
`workingDirectory`, the two compared after both are **canonicalized**, so that a symlink or a
trailing slash is not a mismatch. That is **one condition**: either the slots being read are
under that checkout or they are not.
A pass whose root cannot be established is an **INCOMPLETE pass** — the
state this section already defines, already uncounted toward the floor and already excluded
from the curve — so nothing new is ranked in the closure ordering. The report carries **git's
own message verbatim** and files it under no shape of its own: that message is the
discriminator, and prose cannot partition git's failures better than git does — a partition
written here would send a caller to the wrong repair on every case it guessed wrong, which is
the whole of what such a list would add. What no check reaches: a
slot written under a different root **in the past** is **indistinguishable from an absent
slot**, because nothing records where a past call ran. Unobservable, not detected.
**Then, per earlier pass, two questions.** Is the slot present and valid? And is the pass
**known accepted** — meaning **this session validated it**? Present and valid is the ordinary
case. **A known-accepted pass whose slot is now absent or invalid** is a real pass whose
artifact is unusable: its number **stays counted** and its series read `?`, which the curve
grammar already admits for a **valid** pass whose counts cannot be recovered, since a corrupted
or missing record does not un-run a pass. **After a
lost session nothing is known accepted**, so every absent or present-but-invalid slot is
**acceptance unknown**: **not counted toward the floor** and **omitted from the durable
curve**, which takes one entry per *valid* pass and has no way to say "may not have been
one" — `?` is a missing count, not a missing pass. The omission is named in the report beside
the reduced-sensitivity line, so it is disclosed where it is decided rather than inferred from
a gap in the curve. Crediting an unvalidated pass is the dangerous direction and this is the
other one — and no pass-acceptance record is invented to escape the cost, since the cost is
one pass and the record would be a permanent duty. A pass **known incomplete when it ran** is
excluded, exactly as today.
**Then the report.** It reads the cycle's working record if one exists and says whether it
used it; states which of the three lines it computed and from which passes; **names the pass
numbers it could not read**, and why; and says the two-tell threshold is being read on that
reduced record. **A gap does not break the series**: the consecutive *available* passes
compare across a missing one, and a comparison that spans a gap is **visible but weaker
evidence**, named as such — while a comparison needing the missing pass as one of its two
endpoints is simply unavailable. Refusing to compare across a gap would silence tell detection
exactly where the record is thinnest, and the tells read the direction of the loop rather than
any one adjacent pair. This is not a stop of its own, and it does not make the working record
mandatory: a report that says what it could not see is the duty; one that invents the trend,
or omits a line without saying so, is the failure. This report and its root condition are one
component of the closure-record contract (Mechanics); a copy carrying them without the rest of
that list is a partial adoption that stops there. Filled, over passes 1, 2 and 4 with 3
unreadable:

    Root: `.context/codex-reviews/` under this checkout — confirmed. (Unconfirmable:
      this pass is INCOMPLETE, root not established — git said: "<message>".)
    Trend: findings 24, 17, —, 18; Blockers 5, 2, —, 1 — pass 3 omitted: slot absent,
      acceptance unknown, so it is neither counted toward the floor nor entered in the
      curve. 2→4 spans that gap: rising, weaker evidence. Cluster: product behaviour
      12 of 18. require↔withdraw: none visible; a pair with pass 3 as an endpoint
      cannot be read. Threshold read on 3 of 4.
```

This is **D10**. Both historical lines are derivable from the mandated findings files alone
(the `fic2` record verified that), so unavailability is a property of the workspace and the
answer is disclosure, not a new stop or a mandatory artifact — the root condition reuses the
INCOMPLETE state rather than adding one, so **D10**'s "not a new stop condition" stands as
written. The per-pass partition is by what the agent can observe
(`docs/prompt-standards.md` item 10): presence and validity from the slot, acceptance from this
session alone, and where acceptance cannot be established the count moves in the direction that
costs a pass. The root is deliberately **not** partitioned — item 10 asks that a diagnostic
state name its cause and its fix, and here git's message is the cause, named verbatim, while
any prose list would be this spec guessing at causes it cannot observe. The example is
there for item 4.

---

## 8. The slot discriminator — dissolved

Plan C's Tasks 19 and 20 (`docs/superpowers/plans/2026-08-30-review-loop-economics-plan-c-rollout.md`,
the drop note under Task 19) deferred "a general production" for a short deterministic
discriminator in the nonce's slot position to this story. It ships nothing here, because for
**post-rule and unknown-start cycles** the case it served does not arise: every cycle started
after the parent's rules bind holds a nonce, and one whose start cannot be established mints
one rather than claiming `none (pre-rule)` (`i11`). A production for those would legislate for
an unreachable state, AC 1's prohibition. **The claim reaches no further.** A cycle that began
before the parent's rules shipped has no nonce, cannot acquire one, and writes
`cycle none (pre-rule)`; a rollback can make old-rule cycles reachable again. That set is
bounded and self-terminating, but while two such cycles are observably live they compute the
same bare slot paths and can delete each other's findings files — the incident the parent
records. **Nothing shipped here prevents that**, and no text in this change reaches a cycle
running under the old rules that never reads this document. The trade, stated rather than
dressed as protection: a permanent production for a closing set costs more than the exposure
it removes, and the exposure is real meanwhile. The `rle` naming stays what its closing body
recorded — a plan-local exception under the old rules. The durable prior record is that plan's
drop notes (Task 19, line 970; Task 20, line 1047) and Task 23's second point (line 1298).

---

## 9. Verification

**The mode is read from the story's header at execution**, never from here — the same rule the
spec's own header states, and the reason no value is named in this heading. What follows is
what each level of that mode obliges, so that whichever it carries has its evidence described:
the battery, the check, and the named verification of the risk path.

**Battery.** The quality command in `AGENTS.md` § Commands runs once, green, at the Gate-B WIP
commit (`check-version-bump.sh main` needs the committed bump, §10).

**The check.** Inline shell asserts in the plan, run against the working tree and the parent
tree, so each assertion is observed passing where the change exists and failing where it does
not:

- lead phrase of the §3 block, `**How a cycle ends — one ordering`, count **1** in C and **1**
  in W; the same greps against `git show 7c0d475:CLAUDE.md` and
  `git show 7c0d475:plugins/dev-workflow/commands/workflow-init.md` count **0**;
- the (g) sentence "That question is owned by the loop-rule consolidation work" count **0** in
  both; against the parent tree, **1** in C and **0** in W;
- the (g) replacement's lead phrase `**The demotion changes what a cycle must resolve, never
  what it counts.**` count **1** in C and **1** in W; **0** in the parent tree. The removal
  check above cannot do this alone: deleting the old sentence and installing nothing satisfies
  it and the parity diff, reporting the demotion/loop-health outcome as verified while both
  copies carry no answer at all;
- lead phrase `**Recording an answer at a membership stop.**` count **1** in each; **0** in the
  parent tree, and with it both labels: `Accepted: <handle>` and `Declined: <handle>` count
  **1** in each and **0** there, since one label shipping without the other is the shape the
  block's whole form exists to prevent;
- the six-member squash-carry sentence: `every answer record (part of the closure-record` count
  **1** in each; **0** in the parent tree — the phrase checked against §4 item 1's NEW text
  rather than assumed to match it;
- the Q6 lead phrase `**Where an earlier pass's findings file is unavailable**` count **1** in
  each; **0** in the parent tree;
- the **five** source edits, each as a pair, because each is a standing sentence changing
  meaning rather than new text appearing, and a one-sided presence check would pass on a copy
  carrying both wordings. **Every fragment here is a single line in the file it is grepped
  from**, each OLD verified at 1 in both copies of the parent tree, because a fragment spanning
  a line break makes `grep -F` count 0 and read as a failure — an earlier revision quoted
  three of them across their wraps: `A **clean findings file** is the single body line` at
  **1** in each and **0** in the parent, with `clean pass is the single body line` at **0** and
  **1**; `when a pass finds nothing` at **1** and **0**, with `when a pass is clean` at **0**
  and **1**; `for every finding in the assigned fix set` at **1** and **0**, with `both must
  resolve. Minor` at **0** and **1**; `Knowing that a pass ran is not knowing it was valid` at
  **1** and **0**, with `may know a pass happened` at **0** and **1**; and
  `revise **where the severity and scope rules require a repair**` at **1** and **0**, with
  `Each pass: validate, revise, re-run` at **0** and **1**. The NEW fragments must be installed
  unwrapped at those points — a constraint on how the plan writes the edits, not on what they
  mean;
- the contract markers, since a partial merge sees them and not the membership list: `part of
  the closure-record contract` **case-insensitively** at **17** in each and **0** in the parent
  — one per source edit in §4 except items 6 and 9, which are respectively unchanged and the
  contract itself (thirteen), plus one on each of the four pointer sentences §5(a), (b), (c)
  and (e) install; several open a sentence and capitalise, which is why the count is
  case-insensitive and why a case-sensitive one would under-count and read as a failure — plus
  the four block-level sentences (`This ordering is one component`, `These records are one
  component`, `This split is one component`, `This report and its root condition are one
  component`) at **1** each and **0** there. **Twenty-one** markers in each copy. **Every one
  of the twenty-one must be installed on a single line**, the same constraint the source-edit
  fragments carry and for the same reason: this spec itself wraps the marker phrase at several
  of the sites that quote it, and a wrapped marker in the shipped copy makes `grep -F` count it
  as absent. The constraint is on how the plan writes the line, not on the sentence's meaning,
  which is why the marker sentences are short enough to fit one.

If the claim "the ordering and the records ship in both copies" were false, one working-tree
count would be **0** or the parent-tree counts would not differ from it. The wiring can produce
that observation: each grep reads the file bytes at the named revision and nothing supplies its
own input. **The counterfactual is ABSENT, and is claimed as absent** — the parent carries no
ordering block and no answer records, and the (g) count is the one site where the parent is
present and the change removes it. Nothing is claimed as "contradictory".

**The named verification of the risk path** (story AC 4) is a **next-state table**, in the
plan and quoted by the closing commit body. **Rows** — every stop the shipped text names:
membership stop, question stop, a finding carrying both triggers, clearly-stuck exit, two-tell
stop, a hold awaiting its answer, accept, decline, a stop answer, two or three suspensions at
once, a below-floor clean pass, a zero-finding pass, the unknown-start fallback; **and the
stateful transitions**: a declined finding re-raised matching on all five fields and re-raised
with one changed, the fix set broadened to include a declined finding, **the fix set broadened
while a hold is still awaiting its answer** — whose next state is the hold still standing, the
row that tests the frozen reading — two records disagreeing on one five-field key, recovery
after an accept and after a stop with the session lost (no identity → new cycle),
a `full` Gate-B pass with one branch
clean and the other carrying an in-set Blocker, a rollback with a cycle open under the new
rules, and a copy adopting the ordering without the answer records, the reverse, or either
without the severity split. **Columns** — the **record state** (which answer records the bodies
carry, which working record exists) and the **governing-scope state** (the fix set as currently
assigned) beside the user's answer, then the input that ends the row, the state afterwards, and
the shipped line the row reads, in both copies. What would be observed if "no path leaves a
cycle unable to close and unable to suspend" were false: a row whose next state is the same
stop with no input consumed, or one that closes with an in-set Blocker standing. The wiring can
produce it because every row is filled from the shipped text rather than from this spec, and
the inputs the `fic2` instrument omitted — the user's answer and the record state — are columns
here. That is what makes this **not the `fic2` decision matrix**, whose two defects Gate B found
in the technique itself: a state's inputs must include every input the rule reads, and a
counterfactual must distinguish ABSENT from CONTRADICTORY. **No fixture per predicate is
built** — parked in the story's §2, not reopened.

**Evidence entry**, in the closing commit body, names: the battery run; every assert pair
above with its working-tree and parent-tree counts; the §6 parity diff — the passages
extracted, the differences observed, and that each is one of the permitted rows; and the
next-state table's location in the plan plus its row count. It is revalidated before every
Gate-B re-review and before the closing amend, as §5 requires.

---

## 10. AGENTS.md invariants touched

- **Invariant 11 — `docs/prompt-standards.md`, all 12 items.** Most at risk: item 6 (every
  constraint in the shipped blocks carries its reason in the same sentence — **including the
  three that were exempted until pass 6**: no other pass outcome closes a cycle *because every
  other pass either leaves a required repair, a finding hold or a question outstanding, or has
  an unmet closure precondition such as the floor*; a zero-finding pass is clean whatever the
  floor *because a floor buys further looks at an artifact that keeps yielding findings*;
  decline is available only at a membership stop *because that is the only stop whose question
  is whether a finding belongs to the set*. The exemption was wrong twice over: item 6 admits no
  "settled elsewhere" clause, and a scaffolded copy cannot reach the story the reasons were
  said to live in); item 8 (token-lean — the blocks replace closure
  sentences rather than adding beside them); item 4 (the Q6 example); item 10 (the Q6 per-pass
  partition, and the root condition, whose cause is git's own message rather than a partition
  written here — item 10 asks for a cause and a fix, and a guessed cause is neither);
  item 3 (the stop answer is a named, resumable state).
- **Don't: "Never replace a decision procedure without accounting for its old conditions."**
  Satisfied by §5, against the committed inventory.
- **Don't: "Never rename or delete a doc section without grepping for references first."** The
  (g) sentence names the story path; the grep finds it at `CLAUDE.md:815` (the site itself)
  and in three artifacts of the parent cycle (`…plan-a-rules.md:878`,
  `…review-loop-economics-design.md:33`, `…pass-floor-story.md:78`). All cite the story file,
  which continues to exist; none cites the sentence. Nothing breaks.
- **Invariant 12 — a plugin change requires a version bump.** `workflow-init.md` is under
  `plugins/`, so `plugins/dev-workflow/.claude-plugin/plugin.json` goes `0.11.0 → 0.12.0` with
  a `CHANGELOG.md` entry: a minor bump, the template gaining a record form and a rule. The
  entry also notes that the squash-carry sentence now lists six record kinds.
- **Invariant 4 / the hook.** Untouched: `codex-gate.sh` is not edited, and the §5 heading it
  greps (`Cross-Model Review`) does not move.

---

## 11. Out of scope / parked

- The pass-counter anomaly (`fic2` record).
- The CodeRabbit plan-metadata contradiction (`fic2` record).
- The fixture-per-predicate question (`fic2` record; story §2).
- Hook code under `plugins/dev-workflow/hooks/`.
- `todos.md`: both-branches-misread-each-other; self-consuming-deletion (prompt-standards item
  11); the three bot findings in resolved plans.
