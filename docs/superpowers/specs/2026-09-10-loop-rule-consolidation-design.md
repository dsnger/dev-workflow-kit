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

**Narrowed 2026-09-10: §9 lists what moved out and where.** Read it before reading anything
here as missing.

---

## 1. Intent

**What ships.** One closure ordering, stated once in each copy, that says which exit *closes* a
cycle and which merely *suspend* it, in what order a pass is read so the ranking is executable
rather than asserted, what any set of suspensions at once does, and which of the four standing
duties participate in that ordering versus gate it as preconditions. With it: the answer to what
a severity demotion does to the loop-health counts, and the six standing sentences the ordering
falsifies or leaves ambiguous if they are not edited at their source.

**What does not:** the pass floor and severity semantics, which the parent shipped and this spec
reads as given, and everything §9 lists as moved or parked.

**Why the split, since a reader of the ordering will look for the record.** Gate-A spec pass 10
tripped the two-tell threshold and satisfied all three conditions of the clearly-stuck reading.
Nine of that pass's twenty findings belonged to **one subject this story never set out to
answer** — whether a record survives a session, a commit amend, a squash, a rollback or a moved
checkout — while the ordering's own five were small. Daniel split that subject out on
2026-09-10; §9 says what went and where.

---

## 2. Settled inputs

The story's §4 table is the design's starting point and is not restated here; each decision is
cited below as **D1**…**D8**. **D9**, **D9b**, **D9c** and **D10** stay settled and move to the
successor with the material they govern (§9). Two implementation facts the parent cycle
established are read as given: a pass's cleanliness is a fact about what that pass found and is
**never rewritten** — an answer changes whether the *cycle* may close; and the findings files
establish the **inventory** of findings, not their resolutions.

What the table does not settle, this spec decides in the section that uses it: the evaluation
order and the field and file set each predicate reads; the duties' classification; the scope
stop's two triggers and what each answer does; what a stuck or two-tell answer produces; and the
raw-severity rule for the health measures. Six standing sentences are edited at their source
rather than worked around, each one the ordering falsifies or leaves ambiguous (§4).

---

## 3. The closure ordering — the block that ships

It sits in §5 **immediately before** the paragraph "**What a loop absorbs, and what stops it**",
in both copies, byte-identical. It states the ordering once; the paragraphs after it keep their
triggers and point at it. Verbatim as it will ship:

```
**How a cycle ends — one ordering, stated here and referenced everywhere else.** A pass is
read in a fixed order, because every rule below bears on one decision — may this cycle close —
and a stated order is what stops them qualifying each other. **Every finding-derived predicate
here** reads the validated findings file **or files** of the logical pass as their
**concatenation** — a `full` Gate-B pass has two, and one branch alone is already an incomplete
pass — at **effective** severity, after the Mechanics severity ceiling, because cleanliness is
about what the cycle must repair and the ceiling is what decides that. **Both branches' lines
count** for the health measures, the curve rule already summing the branches into one entry; a
finding matching one in the other branch is **one** finding for holds and answers, so it is
answered once. The **health measures** (Mechanics, Severity) read the reviewer-written field
from before the ceiling — the per-pass counts, the clusters, the tells, and **both
severity-bearing conditions of the three-condition stuck reading**, its Blocker curve and its
regenerating Blocker or Major findings, since a predicate reading one field for half of itself
could not be read at all, while its third condition, the stated coverage-sufficiency judgement,
reads no severity field and the ceiling does not touch it. **The branches read more than the
findings**, named here so nobody applies the order to the findings file alone: closure reads the
**derived floor**, the **cited set and every profile** as re-read for final acceptance, and any
**hold still standing**; the membership trigger reads the **current assigned fix set** and the
answers this cycle has already given; the stuck reading adds its coverage judgement.

**First, clean completion.** §5 uses *clean* in two senses and now says which is which. A
**clean findings file** is the `NO FINDINGS` signal the protocol defines. A **clean pass** is
the predicate below, read on the **logical pass with every required branch file combined**:
one branch's clean findings file never establishes a clean pass, the other being free to carry
an in-set Blocker. Every required file carrying that signal gives one, and a clean pass need
not have it, because a pass carrying only Minors and Nits, or findings this cycle has declined,
is clean without being empty. **A pass is clean** when its findings carry no Blocker
or Major at effective severity that is **in the assigned fix set**, and **no scope-stop
trigger**. There are two triggers, and this branch is where cleanliness and suspension both read
them, in the same words so they cannot drift: a **membership trigger** is a finding outside the
current assigned fix set **and not one this cycle has already declined** — such a decline having
put it outside by the user's own answer, for as long as the current set still excludes it, so
that an answered question is not asked again — and a **question trigger** is a finding opening a
new structural or contract question, in-set or not, which a decline never suppresses, an answer
about membership being no answer to a question. Both are properties of the findings and the set,
read before any branch below runs, which is what makes this order executable rather than
asserted: no predicate here waits on an act a lower branch performs. A pass
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
clearly-stuck reading is not a scope-stop finding; one that also carries either trigger takes
the scope stop's answers at that same surface — it is not asked twice. The two-tell stop
surfaces tells and not a finding, so no finding is surfaced by it at all. This branch defines
nothing: the triggers are the first branch's, and a reader who finds a rule here that is not
there has found a defect.

**Third, a pass that neither closes nor suspends continues** — the loop runs another pass on
the **current** artifact, revised or not. A below-floor clean pass lands here **only where no
suspension applies to it**; where one does, the second branch has already taken it, because
clean completion did not close the pass and only closing outranks a suspension. So does a pass
whose only findings are Minors and Nits, which are collected and never iterated and so may
leave nothing to revise. It is a branch and not an inference, because "does not close"
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
binding for the rest of this cycle). Either is an **explicit, attributable decision on that
specific finding** — never silence, never a general remark about scope, never inferred, because
a fix set changed by inference is a fix set nobody chose.
**Membership is answered against the set as it stood at the pass that raised the question**,
not against the set as it is when the answer arrives, and an explicit answer is
required whatever the governing artifacts do meanwhile — a hold discharged by a scope change
is a hold nobody answered. A later broadening is a new fact the **next** pass reads; it never
discharges a standing hold. A decline keeps a finding out and never excuses one that is in: a
declined finding the fix set later comes to include owes resolution like any other. At a question
stop the answer is the user's decision on the question, and membership does not change: an
in-set finding then routes through its effective severity like any other, under that decision;
an out-of-set finding that opened the question is a membership stop as well and takes accept or
decline. **Effective severity routes an in-set finding in one place only** — the Mechanics
severity rule, where a Blocker or Major's obligation to resolve and a Minor or Nit's collection
without iteration are both stated, and whose discharge the resolve duty above defines — and
every branch here that puts a finding in the set hands it there rather than restating it.
**Decline is available only at a membership stop**, because that is the only stop
whose question is whether a finding belongs to the set, and a decline anywhere else would
waive work the cycle owes. The stuck and two-tell readings
raise no hold: each asks one question, **continue or stop**. Continue is that suspension's
resuming answer, and where it is the last one outstanding the loop resumes on the
artifact as revised and the fix set as the governing artifacts now assign it — where several
plans or stories govern one cycle, the union of the scopes they assign — **plus the findings
this cycle accepted into it**. A finding that a
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
this cycle has declined, which raises no membership trigger and sits outside
the set the clean predicate reads. Either can regenerate across passes on a pass that is clean.
**The order decides both and no new rule is needed** — the pass closes at or
above the floor, ranking the exit exactly as the clearly-stuck paragraph's own precedence
sentence says, and continues below it, where nothing closes anyway.
```

Where the block maps onto the criteria: the three branches are AC 4, the duties paragraph
AC 2, the composition sentences AC 1. The scope stop's two triggers are `b11` (membership) and
`b13` (question) read separately, because an in-set finding that opens a question can neither
join nor stay outside the set and needs its own answer. Sentences the block points at rather
than restating (`a13` as §5(a) replaces it): C:116–118, C:760–764, C:176, and the
clearly-stuck precedence sentence, kept verbatim under **D3**.

**Two things the ordering names and does not define, both the successor's** (§9): what makes a
later finding *the same one* this cycle declined, and what form carries an answer into the
commit body. The ordering says what an answer does — a decline keeps a finding out of the set
for the cycle, an acceptance puts one in until the cycle closes — and **D9b** and **D9** say how
it is recognised and written down. Until the successor ships, an answer binds within the session
that made it and the reviewer re-raises what it cannot read, which is the ordinary route and not
a special one.

---

## 4. The standing sentences edited at their source

Six, and no more — working around any of them would ship two instructions that disagree. Line
numbers are C's; W's are re-read at execution. **Every OLD fragment quoted here is a single line
in the file it is grepped from**, verified at 1 in both copies (§7).

1. **The findings-file protocol's clean sentence** (C:329 / W:523), inside the gate-prompt
   template both gates paste. OLD: "A clean pass is the single body line `NO FINDINGS` with
   `END OF FINDINGS (0 total)`." NEW: "A **clean findings file** is the single body line
   `NO FINDINGS` with `END OF FINDINGS (0 total)`." It describes a file and always did; the
   word *pass* in it is what makes §3's predicate look like a redefinition instead of the
   other sense. Old condition — what a reviewer writes when it finds nothing — unchanged.

2. **The Gate-A clean-signal sentence** (C:565–566 / W:756–757; the two copies wrap it
   differently, so the shared fragment is what is quoted). OLD: "…when a pass is clean — the
   explicit clean signal is what lets you exit the loop:". NEW: "…when a pass finds nothing —
   the explicit signal is what lets a pass be read as clean without inspecting it further:".
   Old condition: a `NO FINDINGS` file is what permits loop exit. Kept: the signal and why it
   is demanded. **Replaced**: it makes a pass readable as clean rather than being the only way
   to be clean, since a pass carrying Minors alone is clean under the ordering and could never
   produce this file. The other **six** uses of "clean pass" in each copy (C:117, 728, 750,
   761, 769, 827; W:324, 914, 936, 947, 955, 1011) are the closure sense the ordering defines
   and are correct as they stand — counted and checked, not assumed.

3. **The Severity bullet's resolve duty** (C:783–784 / W:969–970), which is the one place the
   duty is stated and the only one without a scope. OLD: "- **Severity:** Blocker
   (wrong/unsafe/breaks invariant) · Major (design flaw → rework) → both must resolve. Minor ·
   Nit → collect, never iterate." NEW: "- **Severity:** Blocker (wrong/unsafe/breaks
   invariant) · Major (design flaw → rework) → both must resolve, **for every finding in the
   assigned fix set** (the closure ordering above). Minor · Nit → collect, never iterate."
   Old condition: every Blocker and Major resolves, unbounded. **Replaced**: the boundary
   **D5** always implied and no sentence carried. Without it a declined finding must stay
   outside the set and still bars closure, which is a pass that can neither close nor suspend.
   **The edit names the set and never a decline**, which is AC 3's second half: the answer
   moves a finding into or out of the set, and this duty says only what it demands of what is
   in it — a mention of the decline here would read as a direct waiver of Blocker/Major
   resolution rather than the membership decision it is. The (c) pointer that calls this "the
   resolve rule" (`c17`) needs no edit: it names the rule, and the rule now carries its own
   scope.

4. **The lens paragraph's unchanged-list** (C:653–655 / W:839–841), which asserts of two rules
   this change alters that they are unchanged. OLD, the single-line fragment: "clean-final-pass
   rule are unchanged." NEW: "clean-final-pass rule are unchanged **by the lens sets**, which is
   what this paragraph is about — the closure ordering above does change both, scoping the
   filter to the assigned fix set and defining a clean pass at effective severity, and says so
   there." Old conditions: lenses change what a pass asks and never how many passes a cycle
   owes (**kept**); the Blocker/Major filter, the file-first findings protocol and the
   clean-final-pass rule are unchanged (**replaced** — scoped to the lens sets, because two of
   the three are changed by the ordering and an unscoped claim leaves both copies denying an
   edit they carry); the floor is not among them (**kept**).

5. **The Gate-A cadence** (C:573 / W:764), which makes a revision unconditional between
   passes. OLD: "Each pass: validate, revise, re-run." NEW: "Each pass: validate, revise
   **where the severity and scope rules require a repair**, re-run." Old condition: every
   pass is followed by a revision before the next. Kept: the cadence and its order — validate
   first, re-run last. **Replaced**: the revision is conditional, because the ordering's
   continue branch reaches a below-floor pass whose only findings are Minors and Nits, which
   are collected and never iterated, and an unconditional "revise" tells that pass to
   manufacture the repair the severity rule forbids.

6. **The unknown-start fallback** (C:153–167 / W:360–374, `i4`–`i8`, extended at `i12`'s
   invitation) — an addition to a list rather than a change of meaning, so it is checked by
   presence and not as a pair. After the single-line anchor "duty owed, and the nonce duties at
   their strictest" the list gains "**every suspension binding**". `i12`'s sentence stays as
   written; this is the addition it invites, and it is what this change owes that list: a cycle
   that cannot establish its starting rules treats a suspension as binding rather than as
   advisory, which is the strict reading of the rules §3 ships.

The shorter "Copy every record into the squash body" sentence inside the human-exception block
(C:1004–1007) is not edited, and neither is the "records every cycle owes" list (C:698): this
change ships no record.

---

## 5. Edits to the existing passages, with the old-conditions accounting

Ids are the committed inventory's (§ header). "Kept" = the sentence stays; "moved" = it now
lives in the §3 block; "replaced" = the condition changes, and says how; "dropped" carries its
reason. **Every inventoried passage has an entry**, including the four this narrowing no longer
edits, so that the accounting stays a complete map of the ten rather than a shorter list.

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
stated once and in order." Accounting: `a1`–`a12`, `a14`–`a17`, `a20`–`a22` kept; `a18`, `a19`
moved; **`a13` replaced**. Old condition: *no* rule about how a cycle closes is restated
anywhere. Kept: the prohibition and its reason, scoped to the paragraph it was written to
police. Changed: the ordering does restate closure rules, deliberately and as the one
authority, so a categorical reading would leave the shipped text contradicting itself — the
failure `a13` exists to prevent, arriving from the other direction.

**(b) What a loop absorbs** (C:195–223 / W:402–426) — **three sentence edits**, the triggers
stay. `b12` OLD: "…and it resumes the moment the user says whether the set now includes it."
NEW: "…and it resumes once the user has said whether the set now includes it — accepting or
declining it — **together with every other answer that pass's suspensions require**, under the
closure ordering above." `b17`–`b18` OLD:
"Stopping this way is **not an exit from the gate**: the floor, the Blocker/Major filter and
the clean-final-pass rule all stand, and the loop resumes on the revised artifact once the
question is answered — what the stop prevents…" NEW: "Stopping this way is a **suspension**
under the closure ordering above, and the loop resumes on the revised artifact **once every
answer that pass's suspensions require has been given** — what the stop prevents…". Third, in
**W only**, "…by its severity exactly as the severity rule already says…" becomes "…exactly as
Mechanics already says…", matching C for the reason §6's first row gives.

Accounting: `b1`–`b11`, `b13`–`b16` kept. Two are worth naming. `b6` fixes
the assigned set **before the pass being answered**, and the ordering's membership answer is
read against that same set rather than against a later one, so the two agree and `b6` needs no
edit. An earlier revision of this spec had membership re-read when the answer arrived, which
`b6` and **D4** both forbid — **D4** requiring a user answer for the hold to end at all — and
the reversal is recorded here rather than left as a silent narrowing. `b11` and `b13` are the
two trigger descriptions and **stay in their own words**, checked equivalent to the block's
definitions rather than merged into them, because editing them would rewrite the passage this
change deliberately leaves standing; §6 is where that check runs. `b12` **replaced** — old: an *immediate*
resume on the membership answer alone. Kept: that the membership answer is what the stop asks
for and that either direction ends it. Changed: the resume waits for every answer the pass's
suspensions require, because a loop resumed over an unanswered question decides it by running.
`b17` moved (the block's "a suspension waives nothing" sentence); `b18`
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
a **suspension** under it: you surface with the findings still open, the resolve
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
boundary §4 item 3 gives it, so the pointer needs no edit of its own; `c16` **replaced** —
old: a clearly-stuck surface leaves its finding open, which read alone gives this exit a hold.
Kept: that the findings are still open and that the resolve duty is what keeps them so.
Changed: the **hold** belongs to the scope stop, the only stop whose question is about a
finding, while this exit asks continue or stop. Authority **D1**, which makes all three exits
suspensions with their own transitions; `c18` **replaced** — old: no pass is credited as clean
on a clearly-stuck surface, unconditionally. Kept: the rule wherever it decides anything — a
pass carrying a scope-stop trigger is unclean, and this exit is reached only on a pass that did
not close. Changed: where the exit's regenerating findings are in-set and the ceiling demotes
them below Major, the pass is clean at effective severity and closes at or above the floor.
Authority **D3** — under the old reading D3's own preserved sentence and `c18` decide that pass
in opposite directions. The two-tell stop was never in either condition's domain, surfacing
tells and not a finding; `c19` **replaced** — old: the loop resumes on whatever the user
decides, unconditionally; new: it resumes on a resuming answer and a stop leaves the suspension
standing, because an unconditional resume is the stop-with-no-transition path AC 4 forbids;
`c20` **dropped** — it argued that reading the exit as "stop instead of fixing" would compete
with the resolve duty, and the block states that argument's conclusion as a rule instead.

**(d) From pass 4 onward** (C:255–261 / W:459–465) — **no longer edited.** The Q6
unavailable-history block this passage was to receive moved to the successor with **D10**, and
nothing the narrowed change ships touches the three-line duty. `d1`–`d7` kept, unedited.

**(e) The five tells** (C:263–268 / W:467–472) — **one edit and one added sentence**. The edit
is `e7`, the shared fragment both copies carry (C:266 / W:470). OLD: "**Any two present makes
stop-and-surface mandatory, not discretionary**". NEW: "**Any two present makes stop-and-surface
mandatory, not discretionary, where the clean-completion branch did not close the pass**". Then
the pointer, after `e10`: "This stop is a **suspension** under the closure ordering above, and
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
  that same judgement would hide it.
```

Accounting: `g1` **dropped** (the unsettled statement, now settled); `g2`, `g3` **dropped**
(the interim report-and-stop duty existed only until the question was settled); `g4`
**dropped** in C (the ownership sentence, discharged by this change), and W, which never
carried it, gets the same replacement — removing the one deliberate story-path difference.

**(h) Recording a human exception** (C:977–1033 / W:1161–1217) — **no longer edited.** The
answer-record block that was to follow it moved to the successor with **D9**. `h1`–`h26` kept,
unedited.

**(i) When these rules bind** (C:153–167 / W:360–374) — **extend** the strict-reading list with
one item (§4 item 6); `i1`–`i16` kept, none replaced, the list being added to rather than
rewritten.

**(j) The squash carry** (C:892 / W:1076) — **no longer edited.** It was extended to name the
answer record, which moved to the successor; this change ships no record for it to carry.
`j1`–`j4` kept, unedited.

Also touched, outside the inventoried passages: §4 items 1–5.

---

## 6. Parity

The two copies must agree on every rule this spec changes. The block (§3), the (g) replacement
and every source edit ship byte-identical in C and W. The pre-existing divergences the inventory
found are handled as follows:

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
part of the evidence entry (§7). Any other difference is a defect, not a wording choice. The
same extraction also compares `b11` and `b13` against the block's two trigger definitions, per
§5(b) — a parity check between copies and an equivalence check within each. The correspondence
it confirms: `b11`'s "a correction that leaves that set" and "out-of-scope finding" is the
block's *outside the current assigned fix set*, and `b13`'s "opens a **new structural or
contract question**" is the block's question trigger word for word.

---

## 7. Verification

**The mode is read from the story's header at execution**, never from here — the same rule the
spec's own header states, and the reason no value is named in this heading. What follows is
what each level of that mode obliges, so that whichever it carries has its evidence described:
the battery, the check, and the named verification of the risk path.

**Battery.** The quality command in `AGENTS.md` § Commands runs once, green, at the Gate-B WIP
commit (`check-version-bump.sh main` needs the committed bump, §8).

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
- the **five paired source edits** (§4 items 1–5), each as an OLD/NEW pair, because each is a
  standing sentence changing meaning rather than new text appearing, and a one-sided presence
  check would pass on a copy carrying both wordings. Each NEW counts **1** in each copy and
  **0** in the parent tree, each OLD the reverse: `A **clean findings file** is the single body
  line` against `clean pass is the single body line`; `when a pass finds nothing` against `when
  a pass is clean`; `for every finding in the assigned fix set` against `both must resolve.
  Minor`; `clean-final-pass rule are unchanged **by the lens sets**` against `clean-final-pass
  rule are unchanged.`; and `revise **where the severity and scope rules require a repair**`
  against `Each pass: validate, revise, re-run`. **Every fragment is a single line in the file
  it is grepped from**, and the NEW ones must be installed unwrapped, because a fragment
  spanning a line break makes `grep -F` count 0 and read as a failure — an earlier revision
  quoted three of these across their wraps. That is a constraint on how the plan writes the
  edits, not on what they mean;
- §4 item 6, the unknown-start addition, by presence alone since it adds to a list rather than
  changing a meaning: `every suspension binding` count **1** in each and **0** in the parent.

If the claim "the ordering ships in both copies" were false, one working-tree count would be
**0** or the parent-tree counts would not differ from it. The wiring can produce that
observation: each grep reads the file bytes at the named revision and nothing supplies its own
input. **The counterfactual is ABSENT, and is claimed as absent** — the parent carries no
ordering block, and the (g) count is the one site where the parent is present and the change
removes it. Nothing is claimed as "contradictory".

**The named verification of the risk path** (story AC 4) is a **next-state table**, in the plan
and quoted by the closing commit body. **Rows** — every stop the shipped text names: membership
stop, question stop, a finding carrying both triggers, clearly-stuck exit, two-tell stop, a hold
awaiting its answer, accept, decline, a stop answer, two or three suspensions at once, a
below-floor clean pass with no suspension, **a below-floor clean pass carrying a health
reading** — whose next state is the suspension, the row that tests the third branch's
qualification — a zero-finding pass, and the unknown-start fallback; **and the stateful
transitions**: a finding this cycle declined re-raised on a later pass, **the fix set broadened
while a hold is still awaiting its answer** — whose next state is the hold still standing, the
row that tests the frozen reading — a fix set narrowed so an in-set finding falls outside it,
and a `full` Gate-B pass with one branch clean and the other carrying an in-set Blocker.
**Columns** — the **governing-scope state** (the fix set as currently assigned) and the
**answers already given in this cycle**, beside the user's answer for this row, then the input
that ends the row, the state afterwards, and the shipped line the row reads, in both copies.

**The oracle.** A row **fails** when its required answer does not produce a **distinct**
resumable or closed state — the same stop returning, whether or not an input was consumed —
or when it closes with **any** closure precondition unmet: an in-set Blocker or Major, a
standing hold, an unanswered question, the derived floor, or a cited-set or profile change
during the pass. Naming only the first two would pass the exact no-progress defect AC 4 cites
from the parent cycle. The wiring can produce that observation because every row is filled from
the shipped text rather than from this spec, and the inputs the `fic2` instrument omitted — the
user's answer and the governing-scope state — are columns here. That is what makes this **not
the `fic2` decision matrix**, whose two defects Gate B found in the technique itself: a state's
inputs must include every input the rule reads, and a counterfactual must distinguish ABSENT
from CONTRADICTORY. **No fixture per predicate is built** — parked in the story's §2, not
reopened.

**Evidence entry**, in the closing commit body, names: the battery run; every assert pair above
with its working-tree and parent-tree counts; the §6 parity diff — the passages extracted, the
differences observed, that each is one of the permitted rows, and the `b11`/`b13` equivalence
result; and the next-state table's location in the plan plus its row count. It is revalidated
before every Gate-B re-review and before the closing amend, as §5 requires.

---

## 8. AGENTS.md invariants touched

- **Invariant 11 — `docs/prompt-standards.md`, all 12 items.** Most at risk: item 6, every
  constraint in the shipped block carrying its reason in the same sentence — **including the
  three exempted until pass 6**, which now carry theirs inline in §3: that no other pass outcome
  closes, that a zero-finding pass is clean whatever the floor, and that decline is available
  only at a membership stop. The exemption was wrong twice over: item 6 admits no "settled
  elsewhere" clause, and a scaffolded copy cannot reach the story the reasons were said to live
  in. Then item 8 (token-lean — the block replaces closure sentences rather than adding beside
  them) and item 3 (the stop answer is a named, resumable state).
- **Don't: "Never replace a decision procedure without accounting for its old conditions."**
  Satisfied by §5, against the committed inventory, with an entry for every inventoried passage
  including the four this narrowing no longer edits.
- **Don't: "Never rename or delete a doc section without grepping for references first."** The
  (g) sentence names the story path; the grep finds it at `CLAUDE.md:815` (the site itself)
  and in three artifacts of the parent cycle (`…plan-a-rules.md:878`,
  `…review-loop-economics-design.md:33`, `…pass-floor-story.md:78`). All cite the story file,
  which continues to exist; none cites the sentence. Nothing breaks.
- **Invariant 12 — a plugin change requires a version bump.** `workflow-init.md` is under
  `plugins/`, so `plugins/dev-workflow/.claude-plugin/plugin.json` goes `0.11.0 → 0.12.0` with
  a `CHANGELOG.md` entry: a minor bump, the template gaining a closure ordering and six edited
  sentences.
- **Invariant 4 / the hook.** Untouched: `codex-gate.sh` is not edited, and the §5 heading it
  greps (`Cross-Model Review`) does not move.

---

## 9. Moved, out of scope, and parked

**Moved to `docs/superpowers/stories/2026-09-10-record-durability-story.md`** on Daniel's
decision of 2026-09-10, with the evidence in §1:

- the `Accepted:`/`Declined:` answer record, its form, transport, attribution, recording point
  and squash carry (**D9**), the sameness test by which a later pass recognises the same
  finding (**D9b**), and the unverified-assertion reading (**D9c**);
- the pass-4 report's unavailable-history block (**D10**) and the checkout-root condition that
  report grew;
- the rollback reading — what an open cycle owes when a revert removes the text it started
  under;
- the slot-discriminator dissolution deferred here by Plan C's Tasks 19 and 20;
- **the partial-adoption guard for the whole set.** It was built as a "closure-record contract"
  naming the record, with a marker on every mergeable hunk, and it leaves with the record it was
  named for. The narrowed set is still mutually dependent — the ordering's clean predicate needs
  §4 item 3's boundary, and its two senses of *clean* need items 1 and 2 — and **nothing here
  guards that**. It belongs with the successor because the two sets are adopted together in
  practice and one guard should name both; until then a partial `/workflow-init` merge of these
  edits is caught only by the existing one-contract paragraph's semantic coherence rule, which
  does not name them. Stated as a residual, not as protection.

**Out of scope and parked**, unchanged:

- The pass-counter anomaly (`fic2` record).
- The CodeRabbit plan-metadata contradiction (`fic2` record).
- The fixture-per-predicate question (`fic2` record; story §2).
- Hook code under `plugins/dev-workflow/hooks/`.
- `todos.md`: both-branches-misread-each-other; self-consuming-deletion (prompt-standards item
  11); the three bot findings in resolved plans.
