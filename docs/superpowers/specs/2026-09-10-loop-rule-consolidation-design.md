# §5 loop-rule consolidation: one closure ordering — Design

**Date:** 2026-09-10 · **Status:** DRAFT — Gate A running (pass 3 revised)
**Story:** `docs/superpowers/stories/2026-08-29-loop-rule-consolidation-story.md`
**Profile:** read from that header at every pass, never from here — the header is the only
writable copy, and a value copied into this file would be a remembered value.

Prompt-only, in two mirrored copies: `CLAUDE.md` §5 (**C** below) and the inline template in
`plugins/dev-workflow/commands/workflow-init.md` (**W** below). No file under
`plugins/dev-workflow/hooks/` changes. Line numbers cite the tree at `7c0d475` (main) and are
re-read at execution; the plan carries the `grep -n` sites.

Two research inventories were taken before this spec and the plan re-reads them: a
135-condition inventory of the passages this spec rewrites (ids `a1`…`j4`, cited below;
22 + 18 + 20 + 7 + 11 + 7 + 4 + 26 + 16 + 4), and a site map of every sentence that
enumerates the records a commit body carries. Where a sentence outside those passages is cited,
it is quoted by its lead phrase and C line.

---

## 1. Intent

**What ships.** One closure ordering, stated once in each copy, that says which exit *closes* a
cycle and which merely *suspend* it, in what order a pass is read so the ranking is executable
rather than asserted, what any set of suspensions at once does, and which of the four standing
duties participate in that ordering versus gate it as preconditions. On top of it: a decline
rule with a commit-body record, so a user's answer on a surfaced finding has one rule in both
directions; the answer to what a severity demotion does to the loop-health counts; the answer
to the pass-4 report when prior-pass history is unavailable; and the deferred slot
discriminator, dissolved rather than shipped.

**What does not.** The pass floor and severity semantics — the parent shipped them and this
spec reads them as given — and everything §11 lists as parked or out of scope.

---

## 2. Settled inputs

The story's §4 table, decisions 1–10, is the design's starting point and is not restated here;
each is cited below as **D1**…**D10** (with **D9b**, **D9c**). Two implementation facts the parent
cycle established are read as given: a pass's cleanliness is a fact about what that pass found
and is **never rewritten** — an answer changes whether the *cycle* may close; and the findings
files establish the **inventory** of findings, not their resolutions.

This spec adds what the table does not settle — the evaluation order and the field and file
set every predicate reads; the four duties' classification; the scope stop's two triggers and
what each answer does; what a stuck or two-tell answer produces, a stop included; the decline
record's wording, attribution and recording point, and what a cycle does when it loses the
state no record carries; and the raw-severity rule for the health measures — each decided in
the section that uses it (§3, §4, and §5 passage (g)).

---

## 3. The closure ordering — the block that ships

It sits in §5 **immediately before** the paragraph "**What a loop absorbs, and what stops it**",
in both copies, byte-identical. It states the ordering once; the paragraphs after it keep their
triggers and point at it. Verbatim as it will ship:

```
**How a cycle ends — one ordering, stated here and referenced everywhere else.** A pass is
read in a fixed order, because every rule below bears on one decision — may this cycle close —
and a stated order is what stops them qualifying each other. Every predicate here reads the
validated findings file **or files** of the logical pass as one set — a `full` Gate-B pass
has two, and one branch alone is already an incomplete pass — at **effective** severity, after
the Mechanics severity ceiling, because cleanliness is about what the cycle must repair and
the ceiling is what decides that; only the **health measures** read the reviewer-written field
before it (Mechanics, Severity): the per-pass counts, the clusters, the tells, and **both**
conditions of the stuck reading — its Blocker curve and its regenerating Blocker or Major
findings — since a predicate reading one field for half of itself could not be read at all.

**First, clean completion.** A pass is clean when it carries no Blocker or Major at effective
severity that is **in the assigned fix set**, and it surfaced no scope stop; a pass with
**zero** findings is clean whatever the floor. A finding matched by a decline recorded in
this cycle is outside the set by that decision (Mechanics, the decline record) — a decline
keeps a finding out and never excuses one that is in, so a declined finding the set later
comes to include owes resolution like any other. **A clean pass at or above the derived floor,
or a zero-finding pass, closes the cycle**, under the final-acceptance preconditions the floor
section already states and this ordering does not restate — the cited set and every profile
re-read before the pass is accepted as final, a header or profile that changed during it
making the pass not final and costing the further pass that section requires. A plateau or
tells present on the closing pass go into the
closing report and never block it, because reporting "will not converge" on a converged loop
is a false report, and the clearly-stuck paragraph says the same of its own exit. **Nothing
else closes a cycle.**

**Second, only a pass that is not a clean completion can suspend** — that order is what makes
"clean completion outranks the two-tell stop" executable rather than asserted. Three
suspensions, by the names their paragraphs use: the **scope stop**, with two triggers — a
**membership stop** (a finding outside the assigned fix set) and a **question stop** (a
finding, in-set or not, opening a new structural or contract question); the **clearly-stuck
exit**; and the **two-tell stop**. A suspension waives nothing — the floor, the Blocker/Major
filter and the clean-final-pass rule stand while it does. Any non-empty set of them can apply
to one pass: **one surface, every reason reported, every question asked**, because a reason
left out is a decision made by omission. A finding surfaced solely by the stuck or two-tell
reading is not a scope-stop finding; one that is also outside the set, or also opens a
question, takes the scope stop's answers at that same surface — it is not asked twice. A
re-raised finding that a decline of this cycle matches on all five fields raises **no
membership stop and no membership hold**, and that alone: the five recorded fields record no
question, so a **question stop still fires** on it unless that same question has already been
answered in this cycle. A difference in any of the five fields, or genuine uncertainty, is a
new finding and a new stop of either kind.

**Third, a pass that neither closes nor suspends continues** — the loop runs another pass on
the revised artifact. This is the ordinary case and not a residue: a clean pass below the
floor lands here, and so does a pass whose only findings are Minors and Nits, collected and
never iterated. It is a branch and not an inference, because "does not close" read alone says
nothing about whether to run again.

**The four standing duties, classified.** The **derived floor** is a precondition on
closure: it gates closing, and is discharged by the count of valid logical passes reaching
the floor with the last of them clean, or by the zero-finding exit. The **Blocker/Major-resolve
duty** is a precondition on closure and on any pass being clean: it gates both, and is
discharged, for every in-set Blocker and Major, by a validated repair **or a validated
dismissal carrying its one-line why** — the advisory rule above, unchanged — followed by a
pass that finds none. **A dismissal is not a decline**: a dismissal is the author's judgement
that the finding is not true of the artifact, a decline is the user's decision that a true
finding stays outside the fix set, and only the second is an answer at a membership stop.
The **hold** a surfaced finding places on closure is part of the ordering: it gates closing
while it stands, and is discharged by the answers that finding requires, below.
**No-clean-credit** — no pass that surfaced a scope stop is credited as clean — is part of
the ordering and a fact about that pass, discharged by nothing: a later pass is judged on its
own findings, so a decline never closes the cycle on the pass that surfaced the finding.

**What a suspension asks, and what ends it.** Only a scope stop raises a **hold**, on its
finding, and the hold ends when every answer that finding requires has been given — one for a
single-trigger finding, both the question decision and the membership answer for one carrying
both triggers — and in either direction: a hold only accepting could end would be the resolve
duty under another name. At a membership stop the answer is **accept** (the finding joins the
fix set and resolves by its effective severity: Blocker or Major before any pass can be clean,
Minor or Nit collected and never iterated) or **decline** (the finding stays outside,
recorded, binding for the rest of this cycle — Mechanics, the decline record). At a question
stop the answer is the user's decision on the question, and membership does not change: an
in-set finding then resolves under that decision or is dismissed with its one-line why; an
out-of-set finding that opened the question is a membership stop as well and takes accept or
decline. **Decline is available only at a membership stop.** The stuck and two-tell readings
raise no hold: each asks one question, **continue or stop**. Continue resumes the loop on the
artifact as revised and the fix set as the governing artifacts now assign it — where several
plans or stories govern one cycle, the union of the scopes they assign — **plus the accepted
obligations this cycle can still recover**, from the running session or from its own records.
One it cannot recover is not in the set, and the reviewer raises its finding again on the next
pass like any other, which is the ordinary route and not a special one. A finding that a
narrowing has put outside the set surfaces at the next pass as a membership stop. **Stop
leaves the suspension standing**: the cycle stays open under its nonce, resumable by a later
continue, nothing it wrote is a closing commit, and an open cycle nobody resumes is a human's
to resolve, exactly as the nonce rules already say of open cycles.

**Composition, and what cannot happen.** Every question is answered on its own, and the loop
resumes only when every answer resumes it — accept or decline at a membership stop, a decision
at a question stop, continue at the stuck or two-tell reading; one stop answer leaves the
whole suspension standing, because a loop resumed over an unanswered question decides it by
running. Two states cannot co-occur, and no rule ranks them: clean completion and a scope
stop, since a pass that surfaced one is not clean; and a zero-finding pass and any
suspension, since it has nothing to surface, nothing regenerating, no cluster and no
require↔withdraw pair. The Gate-B triviality skip is outside this ordering: a skipped cycle
runs no passes and ends by its own rule. **This ordering, the decline record in Mechanics and
the severity rule's raw-versus-effective split are one contract**: the hold's declined
direction is released by that record and by nothing else, and the split says which field each
predicate here reads, so any one of the three present without the others is a partial adoption
that stops under the one-contract rule there.
```

Why the shape, where the block's own sentences do not already carry it. The evaluation order
answers the objection that a ranking between clean completion and the two-tell stop cannot
fire if the stop can make the pass unclean: clean completion is read first, so a suspension is
only ever evaluated on a pass that did not close. The three branches are story AC 4 — every
pass has a next state, and the third exists because "does not close" is not an instruction.
The duties paragraph is AC 2; the composition and cannot-co-occur sentences are AC 1's demand
that every reachable conflict be covered and every unreachable one named with its reason. The
scope stop's two triggers are `b11` (membership) and `b13` (question) read separately, because
an in-set finding that opens a question can neither join nor stay outside the set and needs
its own answer — which is also why a matching decline suppresses the membership trigger only.
The preconditions the close sentence points at are at C:116–118 ("again before a clean pass is
accepted as the cycle's final pass") and C:760–764 ("Any profile change costs at least one
further pass"). The stop answer is the one new
state this spec supplies beyond the table, and it reuses only shipped mechanisms: resumption
on the revised artifact (`b18`), the membership stop (`b11`), and the nonce rules' treatment
of open cycles ("they stay open, keep their own nonces, and are a human's to resolve",
C:422–424). **D3** keeps the clearly-stuck paragraph's own precedence sentence verbatim (§5,
passage (c)), so the block cites it instead of restating its consequence clause. The block
defines neither the floor nor the tells nor the stuck reading — those stay in their paragraphs
("exactly one definition of the floor must be present", C:176) — and restates no rule it does
not own (`a13`).

---

## 4. The decline rule and record

**The rule ships as the block below**, which is the text and not a summary of it; this section
adds only what the block does not carry. The decisions it implements: availability at a
membership stop and nowhere else is **D6**; the remainder-of-cycle binding **D7**; the
explicit attributable decision **D8**; the five-field sameness test **D9b**; the
unverified-assertion reading **D9c**; the transport **D9**, whose "closing commit body" is
therefore the *last* of the bodies that carry the record, not the first. That a decline never
qualifies the Blocker/Major-resolve duty is **D5**, and it is why the clean predicate in §3
names the fix set and not the decline: a decline is only ever a fact about membership, so it
cannot be read as excusing an in-set finding — the gate-off route a fabricated record would
otherwise open. That accepted obligations and standing suspensions get **no new mandatory
record** is deliberate: **D10** refused one for the same class of state, and the existing
no-identity rule ("**No candidate, disagreeing sources, or more than one candidate → no
identity: start a new cycle**", C:419–420 / W:613–614) already answers the loss in the safe
direction, at the cost of passes.

**The block that ships**, in Mechanics, placed **immediately after the whole human-exception
passage** — after its last paragraph "**What the record is worth.**" (C:1028–1033 /
W:1212–1217) and before the next bullet "- **Timeout / abort:**" (C:1034 / W:1218), at the same
two-space indent. Verbatim, byte-identical in both copies:

````
  **Recording a decline.** A decline is the user's answer at a **membership stop** (the
  closure ordering above) that the surfaced finding stays outside the assigned fix set. It is
  available there and nowhere else: not for an in-set Blocker or Major, which owes resolution,
  and not as the answer to a question stop, a stuck or two-tell surface, a below-floor pass, an
  unclean final pass, or any Gate-A, Gate-B or evidence obligation — of the list the
  human-exception form is never the answer to, the membership stop is the one item this
  record answers. It must be an **explicit, attributable decision on that specific finding** —
  never silence, never a general remark about scope, never inferred — because a hold released
  by inference is a hold nobody chose to release. It **releases the hold** and **binds for the
  remainder of this cycle**, with no effect in any later one; it never qualifies the
  Blocker/Major-resolve duty, which the finding never reached. A later pass raises **the same
  finding** when all five of location, defect, severity, consequence and suggested fix match,
  read on meaning rather than bytes, since a reviewer rewrites its sentences between passes.
  A matching finding raises **no membership stop and no membership hold**, so a decline is not
  re-asked every pass — **and that alone**: the five fields record no question, so a **question
  stop** still fires on it unless that same question has already been answered in this cycle
  (the closure ordering above). **Any difference — severity included — or any genuine
  uncertainty makes it a new finding, and the hold applies.** A decline keeps a finding out and
  never excuses one that is in: a declined finding the fix set later comes to include owes
  resolution like any other.

  ```
  Declined: <handle> · <date> · cycle <nonce>
  Finding: <severity> | <location> | <defect> | <consequence> | <suggested fix>
  ```

  The `Finding:` line is the finding line from the pass's findings file with its confidence
  field removed — the five fields the sameness test reads, in the file's order, a literal pipe
  escaped as `\|` exactly as there. **It carries the cycle nonce**, because it binds to one
  cycle and a record that cannot be attributed to its cycle cannot bind to it. **When and
  where:** written when made, into the cycle's next commit body on the branch — a spec or plan
  revision commit for a Gate-A cycle, the `WIP:` amend for Gate B — **and that commit is made
  before the next pass runs**: no pass runs on a decline that no commit body on the branch
  carries, because a decline held only in a session is one compaction away from a re-asked
  question; the advisory working record may carry it meanwhile and does not bind. Where a
  Gate-A cycle has no artifact revision to carry it — the declined finding was that pass's
  only one — the record goes in an **empty commit of its own**, the destination the
  human-exception rule above already blesses: "An empty commit carrying only the record is a
  legitimate destination". It is
  restated in every later body of that cycle, the closing one included, because a body that
  drops it releases nothing and re-asks the question. A cycle that resumes with no commit body
  carrying a decline **treats it as absent and the hold applies again** — the reading the
  unknown-start fallback gives, and the safe direction. It is copied on squash-merge with the
  other records (the carry rule above). **What it is worth:** an unverified assertion of the
  same kind as the human exception — nothing checks that the handle belongs to whoever
  decided, that a human was asked, or that the reason is honest. **How it differs in force:**
  it releases a hold, which the human-exception form never does; narrowness bounds what a
  false one can do — one fully identified finding, one cycle, **as far as distinct nonces
  allow**: two cycles sharing or redrawing a nonce are indistinguishable to this record as to
  every other, and a replayed decline can then bind to the wrong cycle — and a bound is not
  the same as safety. **This record, the closure ordering and the severity rule's
  raw-versus-effective split are one contract**: this record releases the hold that ordering
  defines, and that split says which severity field each of its predicates reads, so any one
  of the three present without the others is a partial adoption that stops under the
  one-contract rule above. **What the body does not record, said here
  rather than discovered:** an accepted finding, a stuck or two-tell surface and its
  continue-or-stop answer leave no record of their own — from a closing body a reader can
  infer the close and any declines, and nothing else about which suspensions the cycle passed
  through. They live in the running session and, optionally, the working record; a cycle that
  cannot recover them has no identity and starts a new cycle under the recovery rule above,
  which costs passes and closes nothing — the reviewer re-reads the whole artifact each pass,
  so an unrepaired accepted finding is re-raised and one outside the new cycle's scope is
  re-asked as a membership stop, a repeated question rather than a silent close.
````

**Which rules the answer modifies** (story AC 3): the scope stop's resume sentence (`b12`,
which gains "accepting or declining"), and the hold and the clean-pass definition (both in the
§3 block, where the answer's two directions are one rule). Those are the rules whose **closure
behaviour** the answer qualifies, and it qualifies **no other closure rule**: not the
Blocker/Major-resolve duty (Mechanics, Severity: "both must resolve", C:784 — **D5**: it stays
unqualified because a declined finding never enters its scope), not the floor, not the tells,
not the stuck reading. A reader finding "decline" qualifying any *closure* rule outside those
three has found a defect. The decline is also **named**, without qualifying closure, at the
transport, attribution, activation and threat sites listed next — the squash carry, the nonce
set and exemption, the "Both shipped records" count, the unknown-start fallback, the gate-off
surface, the closing-message carry and the one-contract paragraph — and a reader finding it
absent from any of those has found the opposite defect.

**Existing sentences that must name it**, both copies, old → new. Line numbers are C's; W's
are in the site map and re-read at execution.

1. **Squash carry** (C:892 / W:1076, `j1`). OLD: "…copy every evidence entry, every
   human-exception record, the provenance lines, the curves and any skipped cycle's skip
   record TOGETHER WITH THE SKIP REASON IT POINTS AT…". NEW: "…copy every evidence entry,
   every human-exception record, **every decline record**, the provenance lines, the curves
   and any skipped cycle's skip record TOGETHER WITH THE SKIP REASON IT POINTS AT…". Six
   members; the rest of the sentence unchanged.
2. **The named nonce set** (C:385–387 / W:579–581). OLD: "**and that set is named rather than
   left open**: the provenance line, the per-pass curve (including a skip record standing in
   for one), the cycle's findings slots, and its advisory working record." NEW: "**and that set
   is named rather than left open**: the provenance line, the per-pass curve (including a skip
   record standing in for one), **any decline record (Mechanics)**, the cycle's findings
   slots, and its advisory working record."
3. **The nonce exemption** (C:397–399 / W:591–593). OLD: "The nonce is not required in records
   this change neither introduces nor keys to a cycle — the evidence entry and a
   human-exception record among them." NEW: "The nonce is not required in records that are not
   keyed to a cycle — the evidence entry and a human-exception record among them; **a decline
   record is keyed to its cycle and carries it**." (The old sentence's "this change" dated it
   to the parent; the new one states the criterion.)
4. **"Both shipped records below"** (C:367 / W:561). OLD: "Both shipped records below carry a
   **cycle field**, because…". NEW: "Both shipped records below carry a **cycle field** — and
   so does the decline record in Mechanics — because…". A load-bearing count that a third
   cycle-attributed record would otherwise falsify.
5. **The unknown-start fallback** (C:153–167 / W:360–374, `i4`–`i8`, extended at `i12`'s
   invitation). OLD: "…at minimum floor 3, severity classified without the demotion, the
   provenance-line duty owed, the curve duty owed, and the nonce duties at their strictest…".
   NEW: "…at minimum floor 3, severity classified without the demotion, the provenance-line
   duty owed, the curve duty owed, the nonce duties at their strictest, **every suspension
   binding, and decline records not attributable to the nonce this fallback minted treated as
   absent, so that no inherited hold is released — declines recorded under that nonce are
   honoured**…". `i12`'s sentence stays as written; this is the addition it invites. The
   bound in time matters: the fallback mints a post-rule nonce, and a decline the cycle then
   makes and records under it is its own, not an inherited one — treating every decline as
   absent would leave that cycle unable to release any hold it raises, **D7** unmet.
6. **The human-exception "which commit" rule** (C:988–990 / W:1172–1174, `h3`–`h6`). Unchanged
   in wording. The decline block carries its own rule, deliberately different — written when
   made and restated in every later body — because a decline must survive to the next pass
   while the human exception only has to survive to history.
7. **The gate-off surface** (C:143–151 / W:350–358). OLD tail: "…silencing reminders; or not
   running a pass and reporting that it ran." NEW tail: "…silencing reminders; not running a
   pass and reporting that it ran; **or recording a decline nobody made, or one on an in-set
   finding**." The list says it is not complete; this change creates a route and names it,
   as the parent did for the stated floor.
8. **The closing message and the soft-reset path** (C:834–838 / W:1018–1022, with the
   `git reset --soft` sentence at C:829–830 / W:1013–1014). OLD: "**The closing message
   carries the validated evidence entry for every cited profiled story** — one each, and none
   for a cited unprofiled story, which owes no entry. The amend replaces the WIP message
   wholesale, so an entry written only into the WIP body is destroyed exactly when the cycle
   closes." NEW: "**The closing message carries the validated evidence entry for every cited
   profiled story** — one each, and none for a cited unprofiled story, which owes no entry —
   **and every decline record the cycle made, including any held only in WIP bodies a
   `git reset --soft` collapsed**: the single commit after the reset carries all of them,
   because a body the reset discards is unreachable from the commit that replaces it. The
   amend replaces the WIP message wholesale, so an entry or record written only into the WIP
   body is destroyed exactly when the cycle closes." The soft-reset sentence itself is
   unchanged; this sentence is where the carry duty already lives.
9. **The one-contract paragraph** (C:879–890 / W:1063–1074). OLD opening: "**These records are
   one contract, and a partial adoption breaks it.** The nonce, the slot naming, the
   provenance line, the curve, this carry rule **and the unknown-start activation semantics
   that say what a cycle owes when its starting rules cannot be established** depend on one
   another," NEW opening: "**These records are one contract, and a partial adoption breaks
   it.** The nonce, the slot naming, the provenance line, the curve, this carry rule, **the
   closure ordering, the decline record and the severity rule's raw-versus-effective split**,
   and **the unknown-start activation semantics that say what a cycle owes when its starting
   rules cannot be established** depend on one another," and after "and a carry rule naming
   records a project does not produce is inert." (C:885) add: "an ordering without the decline
   record is a hold whose declined direction has no release rule; a decline record without the
   ordering is a release with no hold to release; an ordering whose raw-versus-effective split
   has no counterpart in the severity rule, or a severity rule still calling that question
   unsettled and mandating a stop beside an ordering that decides it, is two answers to one
   question; and a decline record missing from the squash carry or the nonce set is a record
   that cannot survive a merge or be attributed." The stop sentence that follows is unchanged
   and now covers these states. Because `/workflow-init` can merge this paragraph and the
   pieces independently, the two blocks each carry a reciprocal one-contract sentence of their
   own (§3, last sentence; §4, the decline block), so a copy holding one without the others
   stops on the text it has, not only on a paragraph it may not have. A rollback while a cycle
   is open under the new text needs no new mechanism: "a cycle already running finishes under
   the rules it started with" and "A revert is itself a shipping commit for the old rules"
   (C:153–154, C:165–166) already govern it — and where a rollback leaves that cycle unable to
   establish the rules it started with, the unknown-start fallback is the answer, extended by
   item 5 with the loop rules. The residual, stated rather than papered over: the rule text a
   cycle ran under is recorded nowhere, so "finishes under the rules it started with" is
   recoverable only while that text is still present, and the fallback is what covers the rest.
10. **The no-identity rule's aftermath** (C:422–424 / W:616–618). OLD: "**Starting a new cycle
   does not close, adopt or retire the cycles those candidates belong to** — they stay open,
   keep their own nonces, and are a human's to resolve; the new cycle simply does not claim
   them." NEW: "**Starting a new cycle does not close, adopt or retire the cycles those
   candidates belong to** — they stay open, keep their own nonces, and are a human's to
   resolve; the new cycle simply does not claim them, **and names them in its first pass
   report**, so the human this rule makes responsible learns they exist." It adds no record:
   the report names state the workspace already holds, and a cycle left open that nobody is
   told about is the one shape this rule's "a human's to resolve" cannot reach.

The shorter "Copy every record into the squash body" sentence inside the human-exception block
(C:1004–1007) is generic and already covers a decline record; it is not edited. The "records
every cycle owes" list (C:698) enumerates unconditional records only; a decline record is
conditional, like the human exception, and is not added.

---

## 5. Edits to the existing passages, with the old-conditions accounting

Ids are the inventory's. "Kept" = the sentence stays; "moved" = it now lives in the §3 block;
"replaced" = the condition changes, and says how; "dropped" carries its reason.

**(a) The floor paragraphs** (C:72–136 / W:279–343) — **trim** `a17`–`a19` and point at the
block. OLD: "Your final pass must be clean — if the pass at the floor still finds
Blocker/Major, keep going until clean or clearly stuck → then STOP and surface to the user. The
only early exit below the floor is a pass with **zero** findings; don't manufacture findings to
pad." NEW: "Your final pass must be clean; how a cycle closes, and what stops it short of
closing, is the closure ordering below — don't manufacture findings to pad." Accounting:
`a1`–`a16`, `a20`–`a22` kept; `a17` kept (the clause survives); `a18`, `a19` moved. `a13`'s
prohibition on restating is what the pointer form obeys.

**(b) What a loop absorbs** (C:195–223 / W:402–426) — **two sentence edits**, the triggers stay.
`b12` OLD: "…and it resumes the moment the user says whether the set now includes it." NEW:
"…and it resumes once the user has said whether the set now includes it — accepting or
declining it — together with every other answer that pass's suspensions require, any decline
among them recorded as Mechanics requires, under the closure ordering above." `b17`–`b18` OLD: "Stopping this way is **not
an exit from the gate**: the floor, the Blocker/Major filter and the clean-final-pass rule all
stand, and the loop resumes on the revised artifact once the question is answered — what the
stop prevents…" NEW: "Stopping this way is a **suspension** under the closure ordering above,
and the loop resumes on the revised artifact once the question is answered — what the stop
prevents…". Accounting: `b1`–`b16`, `b18` kept; `b17` moved (the block's "a suspension waives
nothing" sentence). W's three wording differences in this passage are untouched (§6).

**(c) Recognizing clearly stuck** (C:225–246 / W:428–449) — **keep** the precedence sentence
in full and **trim** what follows it. The sentence kept byte-for-byte (**D3**): "That third
condition is what makes a plateau rather than a finish, and it is why **a clean completion
takes precedence over this exit**: a Blocker/Major-free pass **at or above the floor** has
satisfied the clean-final-pass rule — collect the Minors and Nits and close — and reporting
"will not converge" on a converged loop is a false report." OLD, from "**Below the floor
nothing closes**" to the end of "…and then nothing could satisfy both.": replaced by
"**Below the floor nothing closes**, exactly as the closure ordering above says. This exit is
a **suspension** under that ordering: you surface with the findings still open, the resolve
rule is not waived by surfacing, and the loop resumes when every answer that pass's
suspensions require has been given." Accounting: `c1`–`c8`
kept; `c9`, `c10`, `c11` kept verbatim; `c12` kept (pointer form); `c13` moved (the
zero-finding exception); `c14` moved **to the ordering's continue branch** — the
Minor-below-floor pass that "keeps looping" is precisely a pass that neither closes nor
suspends, and the branch states it rather than leaving it to be read out of a negation, which
is what finding 1 of pass 3 caught; `c15`, `c16`, `c17` kept in the pointer sentence; `c18`
**replaced, narrowed** — old: a clearly-stuck surface credits no pass as clean; new: no pass
that surfaced a *scope stop* is credited as clean. Deliberate, with its authority: the story
states the fourth duty as "no pass carrying a surfaced *finding* counts as clean" (story §1),
and the clearly-stuck exit requires regenerating Blocker/Major findings, so a pass surfacing
it is already unclean by the ordering's first step without a separate rule. The two-tell stop
surfaces no finding, so a Blocker/Major-free pass below the floor tripping two tells is clean
*as a pass* and still cannot close — below the floor nothing closes, and at or above it clean
completion outranks the tells by **D2** — so the narrowing opens no bypass in either region;
`c19` **replaced** — old: the loop resumes on whatever the user decides,
unconditionally; new: it resumes on a resuming answer and a stop leaves the suspension
standing — because an unconditional resume is the stop-with-no-transition path AC 4 forbids;
`c20` **dropped** — it argued that reading the exit as "stop instead of fixing" would put it
in competition with the resolve duty, and the block classifies the exit as a suspension that
waives nothing, which is that argument's conclusion stated as a rule; a rationale for a
competition the ordering no longer permits would be prose about a rule that no longer
applies.

**(d) From pass 4 onward** (C:255–261 / W:459–465) — **add** the Q6 sentence (§7). `d1`–`d7`
kept, unchanged.

**(e) The five tells** (C:263–268 / W:467–472) — **add** one pointer sentence after `e10`:
"This stop is a **suspension** under the closure ordering above, and the loop resumes when
every answer that pass's suspensions require has been given." `e1`–`e11` kept.

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
  demotion is the author's judgement about the fix set; a loop spending passes on findings the
  author keeps demoting is exactly what the prose-cluster tell exists to surface, and lowering
  the counts by that same judgement would hide it.
```

Accounting: `g1` **dropped** (the unsettled statement, now settled); `g2`, `g3` **dropped**
(the interim report-and-stop duty existed only until the question was settled, and its trigger
no longer exists); `g4` **dropped** in C (the ownership sentence, discharged by this change),
and W, which never carried it, gets the same replacement paragraph — so the one deliberate
story-path difference between the copies is removed.

**(h) Recording a human exception** (C:977–1033 / W:1161–1217) — **unchanged**, and the
"**Recording a decline.**" block (§4, verbatim) is added immediately after its last paragraph,
before "- **Timeout / abort:**". `h1`–`h26` kept; `h17` stays true of the human-exception form,
and the decline block says which one item of that list it *is* the answer to.

**(i) When these rules bind** (C:153–167 / W:360–374) — **extend** the strict-reading list
(§4 item 5). `i1`–`i16` kept.

**(j) The squash carry** (C:892 / W:1076) — **extend** (§4 item 1). `j1`–`j4` kept.

Also touched, outside the inventoried passages (§4 items 2, 3, 4, 7, 8, 9, 10): the nonce set
and exemption, the "Both shipped records" count, the gate-off list, the closing-message
sentence, the one-contract paragraph, the no-identity rule's aftermath.

---

## 6. Parity

The two copies must agree on every rule this spec changes. The block (§3), the decline block
(§4), the (g) replacement, the Q6 sentence and every list extension ship byte-identical in C
and W. The pre-existing divergences the inventory found are handled as follows:

| Divergence | Kind | This change |
|---|---|---|
| (b) cross-reference "Mechanics" (C) vs "the severity rule" (W) | deliberate: W has no section by that name | **as-is**, stated |
| (b) "exactly how" (C) vs "is how" (W); closing rationale reworded; C-only `infinite-portfolio-canvas` parenthetical | rationale and field citation | **as-is**, stated |
| (e) "you report" (C) vs "report" (W); C-only "Recorded rationale" Bricks paragraph | rationale | **as-is**, stated |
| (f) evidence framing; C-only hypothesis qualifier; punctuation of the late-Blockers clause | rationale | **as-is**, stated; (f) is not edited |
| (c)/(d) paragraph break: C fuses the surfacing block onto "Every pass report states three things" (no blank line at C:246/247); W separates them | structural | **aligned**: the (c) edit re-paragraphs the surfacing block, and C gains the blank line, so the floor-report paragraph stands alone in both |
| (e)/(f) paragraph break: W runs the five-tells paragraph into "The two rules above" (no blank line at W:472/473); C has the Bricks paragraph between | structural | **aligned**: W gains a blank line before "The two rules above"; the Bricks paragraph stays C-only |

The parity check at execution: extract each edited passage from both files by its lead phrase
and `diff` them; the only differences permitted are the rows marked as-is above, and the (g)
row is gone. Any other difference is a defect, not a wording choice. The check's result is part
of the evidence entry (§9). The Mechanics region the decline block joins is byte-identical
between the copies today (the site map confirmed C:840–1033 = W:1024–1217) and stays so.

---

## 7. Q6 — the pass-4 report without prior-pass history

Appended to the "**From pass 4 onward**" paragraph, both copies, after "…demanding what an
earlier pass had removed.":

```
**Where an earlier pass's findings file is unavailable**, the report says so before it reads
anything, and it establishes what "unavailable" means by two checks. First the root: the
slots live in `.context/codex-reviews/` under the top-level directory of the checkout this
cycle is running in — the same root every pass call passes as `workingDirectory` — and a
report reading any other directory would count files it never wrote or miss files it did, so
a mismatch is a **wrong-root state**, reported as such and never as absent history; this
check is what detects it, nothing upstream does. Then, per earlier pass, one of three states,
told apart by what the slot holds: the slot path **absent** — after a fresh checkout, a
cleared `.context/`, a cycle resumed elsewhere — is unavailable history; the slot **present,
accepted when it ran, and now failing validation** is a formerly valid pass whose artifact is
unusable, and its pass number stays counted while its series read `?` in every comparison
that uses them, as the curve already admits, since a corrupted record does not un-run a pass;
a pass **known incomplete when it ran** is excluded, as today, and a present-but-invalid slot
whose acceptance nothing records is read as that case — the direction that costs a pass
rather than credits one. The report then reads the cycle's working record if one exists and
says whether it used it, states which of the three lines it computed from the files it has,
names the ones it could not and why, and says that the two-tell threshold is being read on
that reduced record — reduced concretely: the trend and the require↔withdraw comparison read
only the passes present, so a rising count or a pair that spans a missing or unusable pass
cannot be seen. **A gap does not break the series**: the consecutive *available* pass numbers
compare, and the report **names the missing pass numbers** so a reader can see which
comparison spans one. Refusing to compare across a gap would silence tell detection exactly
where the record is thinnest, and the tells read the direction of the loop rather than any one
adjacent pair. It is not a stop of its own, and it does not make the working record
mandatory: a report that says what it could not see is the duty; a report that invents the
trend, or omits the line without saying so, is the failure.
```

This is **D10**. The trend and the require↔withdraw pair are derivable from the mandated
findings files alone (the `fic2` record verified that derivation reproduces the reported
figures), so unavailability is a property of the workspace, not of the format, and the answer
is disclosure rather than a new stop or a new mandatory artifact. The partition is by what the
agent observes, per `docs/prompt-standards.md` item 10, and the middle state exists because a
file validated when its pass was accepted can be truncated or replaced afterwards: reading it
as incomplete would retroactively uncount a pass, reading it as usable would feed a broken
record into the trend, and `?` is the curve grammar's word for exactly that.

---

## 8. The slot discriminator — dissolved

Plan C's Tasks 19 and 20 (`docs/superpowers/plans/2026-08-30-review-loop-economics-plan-c-rollout.md`,
the drop note under Task 19) deferred "a general production" for a short deterministic
discriminator in the nonce's slot position to this story. It ships nothing here, because the
case it served no longer exists: every cycle started after the parent's rules bind holds a
nonce, and a cycle whose start cannot be established mints one rather than claiming `none
(pre-rule)` (`i11`). A rule for a no-nonce cycle would legislate for an unreachable state,
which is AC 1's prohibition. The `rle` naming that cycle used stays what its closing body
recorded it as — a plan-local exception under the old rules. The durable prior record is Plan
C's two drop notes (the Task 19 heading at line 970 and the Task 20 heading at line 1047 of
that plan, each followed by its note) and Task 23's second point (line 1298), which records
the `rle` exception; this section is the record of the dissolution; no prompt text changes.

---

## 9. Verification — mode `battery+check+verification`

**Battery.** The quality command in `AGENTS.md` § Commands runs once, green, at the Gate-B WIP
commit (`check-version-bump.sh main` needs the committed bump, §10).

**The check.** Inline shell asserts in the plan, run against the working tree and against the
parent tree, so the same assertion is observed passing where the change exists and failing
where it does not:

- lead phrase of the §3 block, `**How a cycle ends — one ordering`, count **1** in C and **1**
  in W; the same greps against `git show 7c0d475:CLAUDE.md` and
  `git show 7c0d475:plugins/dev-workflow/commands/workflow-init.md` count **0**;
- the (g) sentence "That question is owned by the loop-rule consolidation work" count **0** in
  both; against the parent tree, **1** in C and **0** in W;
- the (g) replacement's lead phrase `**The demotion changes what a cycle must resolve, never
  what it counts.**` count **1** in C and **1** in W; **0** in the parent tree. This pair is
  what the removal check above cannot do alone: deleting the old sentence and installing
  nothing satisfies the removal count and the parity diff, and reports the central
  demotion/loop-health outcome as verified while both copies carry no answer at all;
- lead phrase `**Recording a decline.**` count **1** in each; **0** in the parent tree;
- the six-member squash-carry sentence: `every decline record` count **1** in each; **0** in
  the parent tree;
- the Q6 lead phrase `**Where an earlier pass's findings file is unavailable**` count **1** in
  each; **0** in the parent tree.

If the claim "the ordering and the record ship in both copies" were false, one of the
working-tree counts would be **0** or the parent-tree counts would not differ from it. The
wiring can produce that observation: each grep reads the file bytes at the named revision,
nothing supplies its own input, and the parent tree is the actual prior state. **The
counterfactual is ABSENT, and is claimed as absent**: the parent carries no ordering block and
no decline record, and the (g) count is the one site where the parent is present and the change
removes it. No count against the parent is claimed as "contradictory".

**The named verification of the risk path** (story AC 4). Walk every stop the shipped text
names — membership stop, question stop, a finding carrying both triggers, clearly-stuck exit,
two-tell stop, a hold awaiting its answer, accept, decline, a stop answer, two or three
suspensions at once, a below-floor clean pass, a zero-finding pass, the unknown-start
fallback — **and the stateful transitions** — a declined finding re-raised matching on all
five fields, and re-raised with one field changed; the fix set broadened to include a
declined finding; recovery after an accept and after a stop with the session lost (no
identity → new cycle); a `full` Gate-B pass with one branch clean and the other carrying an
in-set Blocker; a rollback with a cycle open under the new rules; a copy adopting the
ordering without the decline block, and the reverse — and write the **next-state table**:
for each row, the **record state** (which decline records the bodies carry, which working
record exists) and the **governing-scope state** (the fix set as currently assigned) as
explicit input columns beside the user's answer, then the input that ends the row and the
state the cycle is in afterwards, citing the shipped line the row reads, in both copies. The
table lives in the plan and is quoted by the closing commit body, not here. What would be
observed if the claim "no path leaves a cycle unable to close and unable to suspend" were
false: a row whose next state is the same stop with no input consumed — the shape the parent
cycle shipped once — or a row that closes with an in-set Blocker standing. The wiring can
produce it because every row is filled from the shipped text rather than from this spec, and
the inputs the `fic2` instrument omitted — the user's answer, and the decline — are columns
here; so is the stop answer, whose next state is a standing suspension by design and must
read as one, not as the same stop re-raised.

**What this is not.** Not the `fic2` decision matrix: that instrument scored N states against
old and new text with an expected output each, and Gate B found two defects in the technique —
a state's inputs must include every input the rule reads (the user's answer was never a
column), and a counterfactual must distinguish ABSENT from CONTRADICTORY. The check above is a
presence test whose parent state is absent by inspection; the walk takes the answer as an
input and produces a next state rather than a scored output. **No fixture per predicate is
built** — parked in the story's §2, not reopened.

**Evidence entry**, in the closing commit body, names: the battery run; the six assert pairs
with their working-tree and parent-tree counts; the §6 parity diff — the passages extracted,
the differences observed, and that each is one of the permitted rows; and the next-state
table's location in the plan plus its row count. It is revalidated before every Gate-B
re-review and before the closing amend, as §5 requires.

---

## 10. AGENTS.md invariants touched

- **Invariant 11 — `docs/prompt-standards.md`, all 12 items.** Most at risk: item 6 (rules
  carry their why — each constraint in both shipped blocks carries its reason in the same
  sentence, and the plan's review reads each sentence for one); item 8 (token-lean — the
  blocks replace closure sentences rather than adding beside them, `a13` being why the old
  ones leave); item 10 (the Q6 partition and its root check); and item 3 (stop conditions
  defined — the stop answer is a named, resumable state).
- **Don't: "Never replace a decision procedure without accounting for its old conditions."**
  Satisfied by §5: every inventory id for every edited passage is marked kept, moved, replaced
  or dropped with a reason.
- **Don't: "Never rename or delete a doc section without grepping for references first."** The
  (g) sentence names the story path; the grep finds it at `CLAUDE.md:815` (the site itself),
  `docs/superpowers/plans/2026-08-29-review-loop-economics-plan-a-rules.md:878`,
  `docs/superpowers/specs/2026-08-28-review-loop-economics-design.md:33` and
  `docs/superpowers/stories/2026-08-28-review-loop-economics-pass-floor-story.md:78`. All
  four cite the story file, which continues to exist; none cites the sentence. Nothing breaks.
- **Invariant 12 — a plugin change requires a version bump.** `workflow-init.md` is under
  `plugins/`, so `plugins/dev-workflow/.claude-plugin/plugin.json` goes `0.11.0 → 0.12.0` with a
  `CHANGELOG.md` entry: a minor bump, because the template gains a record type and a rule.
  The entry also notes that the squash-carry sentence now lists six record kinds (the 0.9.0
  entry described two, and history entries are not edited).
- **Invariant 4 / the hook.** Untouched: `codex-gate.sh` is not edited, and the §5 heading it
  greps (`Cross-Model Review`) does not move.

---

## 11. Out of scope / parked

- The pass-counter anomaly (`fic2` record).
- The CodeRabbit plan-metadata contradiction (`fic2` record).
- The fixture-per-predicate question (`fic2` record; story §2).
- Hook code under `plugins/dev-workflow/hooks/`.
- `todos.md`: both-branches-misread-each-other; self-consuming-deletion (prompt-standards
  item 11); the three bot findings in resolved plans.
