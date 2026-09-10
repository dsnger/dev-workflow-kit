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
order and the file set each predicate reads; the duties' classification; which stop each of the
scope stop's two triggers raises and what each answer does; what a clearly-stuck or two-tell
answer produces; and the raw-severity rule for the health measures. **It defines no trigger,
duty or severity rule of its own** — each keeps its one definition where that definition already
lives, and where one had to change to agree with the ordering it changed **at its source**.

**Nineteen edits in all**, counting **one edit per contiguous replacement or addition at one
site**, which is the unit because a single sentence can be replaced once and a list added to once
without either being two: **five** sentences outside the inventoried passages (§4 items 1–5), and
**fourteen** inside them (§5). One of the fourteen — §4 item 6, passage (i)'s list addition — is
described in §4 for locality and counted here in §5(i), never twice.

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
the floor section states, and any **hold still standing**; the scope triggers read the **current
assigned fix set** as the absorb paragraph defines it, and the answers already given; the
clearly-stuck reading adds its own coverage judgement. **A line in one branch file and a line in
the other are distinct findings for holds and answers**, so a `full` pass asks twice rather than
risk resuming over one it never asked about.

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
those looks were for. **A clean pass at or above the derived floor, or a zero-finding pass,
closes the cycle**, under those final-acceptance preconditions. A plateau or tells on the closing
pass go into the closing report and never block it, because reporting "will not converge" on a
converged loop is a false report. **No other pass outcome closes a cycle**, because every other
pass leaves a required repair, a hold or a question outstanding, or has an unmet closure
precondition — and closing over any of those is the failure this ordering exists to prevent. The
one termination that is not a pass outcome is the Gate-B triviality skip, which runs no passes
and is outside this ordering.

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
the **current** artifact, revised or not. A below-floor clean pass lands here **only where no
suspension applies to it**; where one does, the second branch has already taken it, because
clean completion did not close the pass and only closing outranks a suspension. So does a pass
whose only findings are Minors and Nits, which may leave nothing to revise. It is a branch and
not an inference, because "does not close" read alone says nothing about whether to run again.

**The four standing duties, classified.** The **derived floor** is a **precondition on closure**:
it gates closing, discharged by the count of valid logical passes reaching it with the last of
them clean, or by the zero-finding exit. The **Blocker/Major-resolve duty** is a **precondition
on closure and on any pass being clean**: Mechanics Severity, scoped to the assigned fix set,
states what it demands and what discharges it, and a validated pass finding **no in-set Blocker
or Major at effective severity** is what shows it discharged — the clean predicate's own wording,
so the two cannot drift. **A dismissal is not a decline**: a dismissal is the author's judgement
that the finding is not true of the artifact, a decline the user's decision that a true finding
stays outside the set, and only the second is an answer at a membership stop. The **hold** a
surfaced finding places on closure **participates in the ordering**: it gates closing while it
stands, and is discharged by the answers that surface requires. **It attaches to every surfaced
finding, whichever suspension surfaced it** — clean completion creates none, because it wins
before anything is surfaced. **No-clean-credit** — no pass carrying a scope-stop trigger is
credited as clean — also participates, and is a fact about that pass that nothing discharges, a
later pass being judged on its own findings. It is not a second test beside the clean predicate
but that predicate's second half, which is why it is stated in its words.

**What a suspension asks, and what ends it.** **A hold ends when every answer its finding
requires has been given, in whichever direction each is given** — one answer for a
single-trigger finding, both for one carrying both. That is **one rule with two parts**, how many
answers and which way each may go, and neither is a test the other has to pass. At a **membership
stop** the answer is **accept**, the finding joining the fix set where Mechanics Severity governs
it, or **decline**, the finding staying outside and binding so for the rest of this cycle.
A later answer that contradicts a decline is a **contradiction to surface**, not a reversal these
rules permit: **D7** admits no exception, and allowing one would let a finding be moved out of the
set and back into it to escape what it owes inside it. Either answer is an **explicit,
attributable decision on that specific finding** — never silence, never a general remark about
scope, never inferred,
because a fix set changed by inference is a fix set nobody chose. **Membership is answered
against the set as the absorb paragraph fixes it for the pass that raised the question**: a later broadening is a new
fact the **next** pass reads and never discharges a standing hold, a hold discharged by a scope
change being a hold nobody answered. At a **question stop** the answer is the user's decision on
the question and membership does not change; an out-of-set finding that opened one is a
membership stop as well. **Decline is available only at a membership stop**, that being the only
stop whose question is whether a finding belongs to the set. The **clearly-stuck and two-tell
readings** ask **continue or stop**. **Continue consumes the reading that raised the
suspension**: a further health suspension needs that reading recomputed over a pass run after the
answer, which is new data — so continue produces a distinct next state even on an unrevised
artifact, and the same reading cannot return the same stop unanswered. **Stop parks the cycle**:
open, not running, spending no passes, restarted only by an explicit later continue — a distinct
state from the suspended-awaiting-answer one it was in before the answer. Nothing a parked cycle
wrote is a closing commit, and a parked cycle nobody restarts is a human's to resolve, exactly as
the nonce rules already say of open cycles.

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

**One authority per rule — the check finding 14 of pass 11 asked for.** The block cites eight
rules and defines none of them. Each has exactly one definition in the shipped text, and where
that definition had to change to agree with the ordering, it changed **at its source** (§4, §5)
rather than being restated here:

| Rule the block cites | Its one definition |
|---|---|
| membership trigger | `b11`, the absorb paragraph (C:206 / W:413), qualified by §5(b) |
| question trigger | `b13`, the absorb paragraph (C:209–213 / W:416–420) |
| the assigned fix set | `b7`, the absorb paragraph (C:200–202 / W:407–409), edited by §5(b) |
| effective vs reviewer-written severity | the (g) replacement, in Mechanics · Severity (§5(g)) |
| what a Blocker, Major, Minor or Nit demands | Mechanics · Severity (C:783–784 / W:969–970), scoped by §4 item 3 |
| the derived floor and final-acceptance preconditions | the floor section (C:116–118, C:760–764) |
| the clearly-stuck reading | the clearly-stuck paragraph (C:225–246 / W:428–449) |
| the two-tell threshold | the five-tells paragraph (C:263–268 / W:467–472), qualified by §5(e) |

The scope stop's two triggers are `b11` and `b13` read separately, because an in-set finding
that opens a question can neither join nor stay outside the set and needs its own answer.

**One rule runs the other way, and it is the one exception to the table.** The clearly-stuck
exit's **precedence** against a clean completion is not part of that exit's reading; it is
evaluation order, which is the block's own subject. So `c9`'s sentence — the one **D3** requires
preserved verbatim — **moves into the block** rather than being cited from where it stood, and
the clearly-stuck paragraph keeps only its reading and points forward (§5(c)). Stated in both
places, it would be exactly the drift this table exists to prevent, and stated only in the
clearly-stuck paragraph it would put evaluation order somewhere the ordering does not govern.
The sentence's words are untouched by the move; its opening clause refers back to that
paragraph's third condition, and the block says so where it quotes it.

**Two things the ordering names and does not define, both the successor's** (§9): what makes a
later finding *the same one* this cycle declined, and what form carries an answer into the
commit body. The ordering says what an answer does — a decline keeps a finding out of the set
for the cycle, an acceptance puts one in until the cycle closes — and **D9b** and **D9** say how
it is recognised and written down. **Two consequences are stated in the block rather than left
to be discovered**: until a sameness rule ships, a line in one branch file and a line in the
other are distinct findings for holds and answers, so a `full` Gate-B pass may ask twice rather
than risk resuming over an unanswered one; and an answer binds within the session that made it,
the reviewer re-raising what it cannot read, which is the ordinary route and not a special one.

---

## 4. The standing sentences edited at their source

Six items, five of them outside the passages §5 accounts for; the sixth is passage (i)'s list
addition, described here because it belongs with these and counted in §5(i). Working around any
of them would ship two instructions that disagree.

**How each OLD is located, and what this section does not do.** A sentence quoted here is quoted
whole, and several **wrap across two lines** in one or both copies, so each item gives the
sentence's real line range in **both**. This section identifies the sentence and states what
changes; it does **not** name the substrings a check would count. Those are built in the plan,
against the real files, for the reason §7 gives.

1. **The findings-file protocol's clean sentence**, inside the gate-prompt template both gates
   paste. Sentence at **C:328–329 / W:522–523**, the word "A" ending the first line. OLD: "A clean pass is the
   single body line `NO FINDINGS` with `END OF FINDINGS (0 total)`." NEW: "A **clean findings
   file** is the single body line `NO FINDINGS` with `END OF FINDINGS (0 total)`." It describes
   a file and always did; the word *pass* in it is what makes §3's predicate look like a
   redefinition instead of the other sense. Old condition — what a reviewer writes when it
   finds nothing — unchanged.

2. **The Gate-A clean-signal sentence**. Sentence at **C:565–566**, wrapped, and **W:757**,
   whole on one line.
   OLD: "…when a pass is clean — the explicit clean signal is what lets you exit the loop:".
   NEW: "…when a pass finds nothing — the explicit signal is what lets a pass be read as clean
   without inspecting it further:".
   Old condition: a `NO FINDINGS` file is what permits loop exit. Kept: the signal and why it
   is demanded. **Replaced**: it makes a pass readable as clean rather than being the only way
   to be clean, since a pass carrying Minors alone is clean under the ordering and could never
   produce this file. The other **six** uses of "clean pass" in each copy (C:117, 728, 750,
   761, 769, 827; W:324, 914, 936, 947, 955, 1011) are the closure sense the ordering defines
   and are correct as they stand — counted and checked, not assumed.

3. **The Severity bullet's resolve duty**, the one place the duty is stated and the only one
   without a scope. Sentence at **C:783–784 / W:969–970**, wrapped in both. OLD: "- **Severity:** Blocker
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

4. **The lens paragraph's unchanged-list**, which asserts of two rules this change alters that
   they are unchanged. Sentence at **C:653–654 / W:839–840**. OLD:
   "clean-final-pass rule are unchanged." NEW: "clean-final-pass rule are unchanged **by the lens sets**, which is
   what this paragraph is about — the closure ordering above does change both, scoping the
   filter to the assigned fix set and defining a clean pass at effective severity, and says so
   there." Old conditions: lenses change what a pass asks and never how many passes a cycle
   owes (**kept**); the Blocker/Major filter, the file-first findings protocol and the
   clean-final-pass rule are unchanged (**replaced** — scoped to the lens sets, because two of
   the three are changed by the ordering and an unscoped claim leaves both copies denying an
   edit they carry); the floor is not among them (**kept**).

5. **The Gate-A cadence**, which makes a revision unconditional between passes. Sentence at
   **C:573 / W:764**, single-line in both.
   OLD: "Each pass: validate, revise, re-run." NEW: "Each pass: validate, revise
   **where the severity and scope rules require a repair**, re-run." Old condition: every
   pass is followed by a revision before the next. Kept: the cadence and its order — validate
   first, re-run last. **Replaced**: the revision is conditional, because the ordering's
   continue branch reaches a below-floor pass whose only findings are Minors and Nits, which
   are collected and never iterated, and an unconditional "revise" tells that pass to
   manufacture the repair the severity rule forbids.

6. **The unknown-start fallback** (C:153–167 / W:360–374, `i4`–`i8`, extended at `i12`'s
   invitation) — an addition to a list rather than a change of meaning, so it is checked by
   presence and not as a pair. The strict-reading list, at **C:157 / W:364**, gains "**every
   suspension binding**". `i12`'s sentence stays as
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

**(a) The floor paragraphs** (C:72–136 / W:279–343) — **three edits**. First, **trim**
`a17`–`a19` and point at the block. OLD: "Your final pass must be clean — if the pass at the
floor still finds Blocker/Major, keep going until clean or clearly stuck → then STOP and
surface to the user. The only early exit below the floor is a pass with **zero** findings;
don't manufacture findings to pad." NEW: "Your final pass must be clean; how a cycle closes,
and what stops it short of closing, is the closure ordering below — don't manufacture findings
to pad." Second, `a13`. OLD: "Every other rule stated here about how a
cycle closes stands as written, and none of them is restated — a summary is where their
conditions would get dropped." NEW: "**This paragraph** restates none of them — a summary is
where their conditions would get dropped — and the closure ordering below is where they are
stated once and in order." Third, `a16`, single-line at **C:132 / W:339**. OLD: "Open a
TodoWrite "Codex pass N" per pass; fix Blocker/Major after each." NEW: "Open a TodoWrite "Codex
pass N" per pass; fix Blocker/Major after each **as Mechanics · Severity requires**."
Accounting: `a1`–`a12`, `a14`, `a15`, `a17`, `a20`–`a22` kept; `a18`, `a19`
moved; **`a13` replaced**; **`a16` replaced**. Old condition: *no* rule about how a cycle closes is restated
anywhere. Kept: the prohibition and its reason, scoped to the paragraph it was written to
police. Changed: the ordering does restate closure rules, deliberately and as the one
authority, so a categorical reading would leave the shipped text contradicting itself — the
failure `a13` exists to prevent, arriving from the other direction. `a16`'s old condition:
**every** Blocker and Major is fixed after each pass, unbounded, standing beside a Severity
bullet §4 item 3 now scopes to the assigned fix set. Kept: the per-pass cadence and the duty
itself. Changed: it points at the rule that carries the scope instead of restating an unscoped
version of it — a declined finding is out of the set and owes nothing, and an unscoped `a16`
commands its repair anyway, which is the same both-must-resolve contradiction §4 item 3 exists
to close, one paragraph earlier.

**(b) What a loop absorbs** (C:195–223 / W:402–426) — **six sentence edits**. This passage owns
the two triggers and the fix set, so where the ordering needs them qualified, they are qualified
**here**, which is what keeps one definition per rule. **None of these edits states what an
answer then does** — that is the ordering's, and each pointer below defers to it rather than
repeating a version of it that can drift.

`b7`, the fix-set definition (C:200–202 / W:407–409). OLD: "…it is the scope the approved story
or plan assigns to this cycle, plus repair obligations you already accepted in earlier passes."
NEW: "…it is the scope **every governing story or plan** assigns to this cycle — their union
where several do, since a cycle a single artifact does not govern has no set at all under the
singular reading — plus repair obligations you already accepted in earlier passes, **minus any
finding this cycle has declined**, a decline being the user's answer that it stays out."

`b11`, the membership trigger (C:206 / W:413). OLD: "**A correction
that leaves that set stops the loop like any other out-of-scope finding**, even when it opens no
new question at all…" NEW: "**A correction that leaves that set stops the loop like any other
out-of-scope finding**, even when it opens no new question at all — **unless this cycle has
already declined that same finding, which put it outside by the user's own answer**…"

`b13`, the question trigger (C:209–213 / W:416–420). OLD: "…that opens a **new structural or
contract question** stops the loop and goes to the user…" NEW: "…that opens a **new structural
or contract question** — new meaning **not already answered in this cycle**, since an answered
question re-raised is the same question and asking it again on every pass is a loop that cannot
end — stops the loop and goes to the user…"

`b12` OLD: "…and it resumes the moment the user says whether the set now includes it."
NEW: "…and the user's answer, accepting or declining it, is what ends the hold; **what the pass
does then, once every answer its suspensions require has been given, is the closure ordering
above**." `b17`–`b18` OLD:
"Stopping this way is **not an exit from the gate**: the floor, the Blocker/Major filter and
the clean-final-pass rule all stand, and the loop resumes on the revised artifact once the
question is answered — what the stop prevents…" NEW: "Stopping this way is a **suspension**
under the closure ordering above, and **what ends it, and what the loop does next, are stated
there** — what the stop prevents…". Sixth, in
**W only**, `b3`: "…by its severity exactly as the severity rule already says…" becomes
"…exactly as Mechanics already says…", matching C for the reason §6's first row gives.

Accounting: `b1`, `b2`, `b4`–`b6`, `b8`–`b10`, `b14`–`b16` kept. Six are worth naming.
`b3` is an **edited cross-reference whose operative condition is kept** — W's pointer changes
target while what it points at is unchanged, so it is not in the kept range above and it is
checked in §7 like any other edit. `b6` fixes
the assigned set **before the pass being answered**, and the ordering's membership answer is
read against that same set rather than against a later one, so the two agree and `b6` needs no
edit. An earlier revision of this spec had membership re-read when the answer arrived, which
`b6` and **D4** both forbid — **D4** requiring a user answer for the hold to end at all — and
the reversal is recorded here rather than left as a silent narrowing. `b7` **replaced** — old:
the scope *the* approved story or plan assigns, singular, with no subtraction. Kept: that the
set is fixed before the pass being answered and carries the obligations already accepted.
Changed: it is the union where several artifacts govern one cycle, and it subtracts this cycle's
declines — the singular reading left a Gate-B cycle fed by several plans, or a Gate-A artifact
citing several stories, with no defined set on its **first** pass, before any suspension could
have raised the question. `b11` **replaced** — old: any out-of-set finding stops the loop,
unconditionally. Kept: the trigger and its reason. Changed: a finding this cycle has already
declined does not raise it again, because unqualified `b11` and the ordering's clean predicate
decide a re-raised declined finding in opposite directions, and re-asking an answered question
on every pass is the non-idempotent path AC 4 forbids. `b13` **replaced** — old: any finding
opening a new structural or contract question stops the loop, with *new* undefined. Kept: the
trigger, the novelty test and its reason, and that size is not the test. Changed: *new* now
excludes a question this cycle has already answered, because unqualified it and the ordering's
clean predicate decide a re-raised answered question in opposite directions — the same
non-idempotent path as `b11`'s, arriving through the other trigger. The qualification is added
**here rather than in the block**, which is what keeps both triggers to one definition each;
§6 checks that the block's reference and this sentence say the same thing. `b12` **replaced** — old: an *immediate*
resume on the membership answer alone. Kept: that the membership answer is what the stop asks
for and that either direction ends the hold. Changed: it says the answer ends the hold and
**defers to the ordering** for what the pass does next, because a loop resumed over an unanswered
question decides it by running, and because a second statement of what an answer does is a second
authority — an earlier revision of this spec had four of them, each saying the loop resumes once
every answer is given and none saying a stop answer parks the cycle.
`b17` moved (the block's "a suspension waives nothing" sentence); `b18`
**replaced** the same way and for the same reason — old: resume once *the* question is
answered; new: the ordering says what ends the suspension and what follows. W's remaining wording
differences here are untouched (§6).

**(c) Recognizing clearly stuck** (C:225–246 / W:428–449) — **one replacement**, from "That
third condition is what makes a plateau rather than a finish" to the end of "…and then nothing
could satisfy both." The paragraph keeps its reading — the three conditions and why each is
needed — and stops carrying evaluation order. NEW: "**What that third condition means for
closure — how this exit ranks against a clean completion, and what happens below the floor —
is the closure ordering above**, which carries this paragraph's precedence sentence word for
word so evaluation order is stated in one place. This exit is a **suspension** under that
ordering: you surface with the findings still open, the resolve rule is not waived by
surfacing, and **what its answer does is stated there**."

**The precedence sentence is moved, not rewritten, and that is what satisfies D3.** Its words
are untouched; only the paragraph it sits in changes, because precedence is evaluation order
and the block is where evaluation order is stated once (§3). Left here it would be a second
authority for the one thing the block exists to own — and an earlier revision of this spec kept
it here *and* stated the same ranking in the block, which is the drift the one-authority check
was added to catch. Accounting: `c1`–`c8`
kept; `c9`, `c10`, `c11` **moved** — the sentence in full, into the block's composition
paragraph, where the block names it as this paragraph's and says why its opening clause points
back here; `c12` kept (pointer form); `c13` moved (the
zero-finding exception); `c14` moved **to the ordering's continue branch** — the
Minor-below-floor pass that "keeps looping" is precisely one that neither closes nor suspends,
and the branch states it rather than leaving it to be read out of a negation; `c15`, `c17`
kept in the pointer sentence, `c17`'s "resolve rule" now reading with the assigned-fix-set
boundary §4 item 3 gives it, so the pointer needs no edit of its own; `c16` **kept** — a
clearly-stuck surface leaves its finding open, and the ordering's hold attaches to **every**
surfaced finding, whichever suspension surfaced it, discharged by the answers that surface
requires. An earlier revision of this spec narrowed the hold to scope stops, which contradicted
both `c16` and the story's own third standing duty; the reversal is recorded here rather than
left as a silent narrowing, and it is why the duties paragraph now says "every surfaced
finding" instead of naming one stop; `c18` **replaced** — old: no pass is credited as clean
on a clearly-stuck surface, unconditionally. Kept: the rule wherever it decides anything — a
pass carrying a scope-stop trigger is unclean, and this exit is reached only on a pass that did
not close. Changed: where the exit's regenerating findings are in-set and the ceiling demotes
them below Major, the pass is clean at effective severity — it closes at or above the floor and
**suspends below it**, clean completion having not closed it. Authority **D3** — under the old
reading D3's own preserved sentence and `c18` decide that pass in opposite directions. The
two-tell stop was never in this condition's domain, surfacing
tells and not a finding; `c19` **replaced** — old: the loop resumes on whatever the user
decides, unconditionally. Kept: that an answer is what moves the cycle. Changed: this passage no
longer says what the answer does and defers to the ordering, which states it once — a resuming
answer resumes, a stop **parks**. An unconditional resume is the stop-with-no-transition path
AC 4 forbids, and a passage carrying its own version of the transition is how four sites came to
disagree with the block about a stop answer;
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
**what its answer does is stated there**."

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
part of the evidence entry (§7). Any other difference is a defect, not a wording choice.

The same extraction runs a second, different check within each copy: that `b11` and `b13` as
edited say what the block cites them as saying. **It compares the complete predicates, not a
shared phrase** — comparing only the phrase both carry is what let an earlier revision call two
wordings equivalent while one of them lacked the decline exception the other had. Each side is
read whole:

| Block cites | `b11`/`b13` as edited must carry |
|---|---|
| a finding **outside the assigned fix set** | `b11`'s "a correction that leaves that set… like any other out-of-scope finding" |
| …**and not one this cycle has declined** | `b11`'s "unless this cycle has already declined that same finding" (§5(b)) |
| a finding **opening a new structural or contract question** | `b13`'s "opens a **new structural or contract question**", word for word |
| in-set or not | `b13` carries no membership condition, and adding one would narrow it |

A difference in either direction is a defect: a condition in the block and not in `b11`/`b13`
ships two triggers that disagree, and one in `b11`/`b13` and not in the block means the block
cites a rule it has not read.

---

## 7. Verification

**The mode is read from the story's header at execution**, never from here — the same rule the
spec's own header states, and the reason no value is named in this heading. What follows is
what each level of that mode obliges, so that whichever it carries has its evidence described:
the battery, the check, and the named verification of the risk path.

**Battery.** The quality command in `AGENTS.md` § Commands runs once, green, at the Gate-B WIP
commit (`scripts/check-version-bump.sh main` needs the committed bump, §8).

**The check — what it must establish, and where it is built.** Every edit that changes a
standing meaning owes a **discriminating pair of counts**: one showing the new wording present,
one showing the old wording gone. Each half is run in **both copies** and against **both** the
working tree and the parent tree (`git show 7c0d475:CLAUDE.md` and
`git show 7c0d475:plugins/dev-workflow/commands/workflow-init.md`), so every assertion is
observed passing where the change exists and failing where it does not. A one-sided presence
check is not enough: a copy carrying the new wording **and** the old one satisfies it, which is
exactly the two-instructions-that-disagree failure §4 exists to prevent. An edit that only adds
to a list is checked by **presence alone**, because nothing is being replaced.

**Which edits owe a pair**, named here because this spec knows which sentences it changes:
§4 items 1–5; and in §5, `a17`–`a19` and `a13` and `a16` in (a); `b7`, `b11`, `b12`, `b13`,
`b17`–`b18` in (b), plus `b3` in **W alone**, since C already carries that target wording and
must be unchanged, which is what makes it an alignment rather than an edit to both; the
replacement in (c); `e7` in (e); and the paragraph replacement in (g), whose old sentence is the
one site where the parent is present and the change removes it. **Presence alone:** the §3
block's lead phrase, the (e) pointer sentence, and §4 item 6.

**The plan builds each pair against the real files and runs both directions there.** It carries
two constraints: a counted fragment must be **single-line in the file it is grepped from**, since
one spanning a line break makes `grep -F` count 0 and read as a failure; and the new wording must
therefore be **installed unwrapped**. Both are constraints on how an edit is written, not on what
it means.

**Why the fragments are not enumerated here, stated as a residual rather than repaired again.**
Four consecutive revisions of this spec listed them, and each list contained at least one
fragment that could not do what it claimed — a substring preserved inside its own replacement, so
the old-wording-gone count could never reach zero; three quoted across their line wraps, so they
counted zero in a correct tree; and a meaning-changing passage with no pair at all. The cause is
structural: an exact substring check for text that does not yet exist can only be guessed, and a
guess that is wrong reads as a failed check rather than as a wrong check. **Nothing here verifies
that the list of edits above is complete, or that the plan's chosen fragments discriminate.** The
enumeration moved to where the text exists; the completeness claim did not move with it, because
nothing supports it.

If the claim "the ordering ships in both copies" were false, one working-tree count would be
**0** or the parent-tree counts would not differ from it. The wiring can produce that
observation: each grep reads the file bytes at the named revision and nothing supplies its own
input. **The counterfactual is ABSENT, and is claimed as absent** — the parent carries no
ordering block, and the (g) sentence is the one site where the parent is present and the change
removes it. Nothing is claimed as "contradictory".

**The named verification of the risk path** (story AC 4) is a **next-state table**, in the plan
and quoted by the closing commit body. **Rows** — every stop the shipped text names: membership
stop, question stop, a finding carrying both triggers, clearly-stuck exit, two-tell stop, a hold
awaiting its answer, accept, decline, **a continue answer on an artifact left unrevised** —
whose next state is a further pass, the row that tests that continue consumes the reading —
**a stop answer** — whose next state is the **parked** cycle, distinct from the
suspended-awaiting-answer state it was in before, the row that tests AC 4 at the one transition
that produces no pass — two or three suspensions at once, a
below-floor clean pass with no suspension, **a below-floor clean pass carrying a health
reading** — whose next state is the **suspension**, the row that tests the third branch's
qualification — a zero-finding pass, and the unknown-start fallback; **and the stateful
transitions**: **a finding this cycle declined re-raised on a later pass** — whose next state is
no membership trigger and a pass still eligible for clean, the row that tests `b11`'s
qualification — **a structural question this cycle answered, re-raised** — whose next state is
no question stop, the row that tests `b13`'s — **a decline that leaves nothing to revise** —
whose next state is a further pass on the **unrevised** artifact, the row that tests the continue
branch against a valid path with no repair in it — an **accepted** finding re-raised before
repair, **the fix set broadened
while a hold is still awaiting its answer** — whose next state is the hold still standing, the
row that tests the frozen reading — and **a confirmed profile change while a hold is still
awaiting its answer**, which is **two rows and not one**: the profile change itself, whose next
state is the hold still standing and **no pass run**, since a standing hold forbids one; and then
the answer, **in each direction**, whose next state is the parked cycle or a resume, with only a
resuming answer starting the further pass under the current profile that a profile change costs.
Split because final acceptance re-reads every profile, and a hold surviving a profile change is
not the same claim as an answer paying for one — a single row asserting both would have to run a
pass through an unanswered hold to be filled in. Then a
fix set narrowed so an in-set finding falls outside it, and a `full` Gate-B pass with one branch
clean and the other carrying an in-set Blocker.
**Columns** — the **governing-scope state** (the fix set as currently assigned), the
**answers already given in this cycle**, and the **profile as currently read**, beside the
user's answer for this row, then the input that ends the row, the state afterwards, and the
shipped line the row reads, in both copies.

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

**Evidence entry**, in the closing commit body, names: the battery run; every pair the plan
built, with the fragment it counted and its working-tree and parent-tree counts in each copy,
and every presence check beside them; the §6 parity diff — the passages extracted, the
differences observed, that each is one of the permitted rows, and the `b11`/`b13` equivalence
result; and the next-state table's location in the plan plus its row count. It is revalidated
before every Gate-B re-review and before the closing amend, as §5 requires.

**One observability residual, stated because the lens set asks for it and nothing here answers
it.** A closing commit body records that a cycle closed and what its curve was; it records
**nothing about which exit the cycle took** — whether a scope stop, a clearly-stuck surface or
two tells ever suspended it, what was asked, or how it was answered. A reader of history
therefore cannot audit that every suspension was answered before the cycle closed. Neither the
evidence entry above nor the per-pass curve supplies this, and saying otherwise would be the
overclaim `AGENTS.md` names as this repo's most persistent defect. The transport that could
carry it left with the record (§9). **No story has taken it**, and naming one that has not is
the same defect in a smaller place, so it is recorded here as an **admitted gap of this change**
— unowned, unguarded, and available to whoever picks it up.

---

## 8. AGENTS.md invariants touched

- **Invariant 11 — `docs/prompt-standards.md`, all 12 items.** Most at risk: item 6, every
  constraint in the shipped block carrying its reason in the same sentence — **including the
  three exempted until pass 6**, which now carry theirs inline in §3: that no other pass outcome
  closes, that a zero-finding pass is clean whatever the floor, and that decline is available
  only at a membership stop. The exemption was wrong twice over: item 6 admits no "settled
  elsewhere" clause, and a scaffolded copy cannot reach the story the reasons were said to live
  in. Then **item 8 (token-lean), which an earlier revision claimed on the wrong ground** — it
  said the block replaces closure sentences rather than adding beside them, while the block was
  in fact restating triggers, duties, preconditions and the severity answer that their own
  paragraphs still defined, which is two authorities per copy and the drift had already begun.
  The claim now rests on what the block does: it is authoritative for the evaluation order and
  for closure and **cites** every other rule where that rule is defined, so each has one
  definition in the shipped text and §3's table is the check; where a cited rule had to change
  to agree, it changed at its source (§4, §5) rather than being restated. Then item 3 (the stop
  answer produces a named state, **parked**, with its own restart transition).
- **Don't: "Never replace a decision procedure without accounting for its old conditions."**
  Satisfied by §5, against the committed inventory, with an entry for every inventoried passage
  including the four this narrowing no longer edits.
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
  ordering and nineteen edited or extended sentences.
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
  of this change removes the ordering, the source edits **and §4 item 6's "every suspension
  binding" extension together**, so the stricter reading such a cycle would fall back to is
  itself part of what the revert takes away, and it no longer mentions the suspensions that cycle
  is holding. What remains is the pre-change §5 — the loose ordering this story exists to
  replace — read by a cycle that started under a different one. **Whether that is enough is
  unanswered here and nothing is shipped for it**, since no record identifies the rule revision a
  cycle started under. An admitted residual, and the successor's question;
- the slot-discriminator dissolution deferred here by Plan C's Tasks 19 and 20;
- **the partial-adoption guard as it applied to the record.** It was built as a "closure-record
  contract" naming the record, with a marker on every mergeable hunk, and it leaves with the
  record it was named for.

**One residual this change owns rather than moves: partial adoption of the narrowed set.** The
set is mutually dependent — the ordering's clean predicate needs §4 item 3's boundary, its two
senses of *clean* need items 1 and 2, and its triggers need §5(b)'s `b7`, `b11` and `b13` — and
**nothing catches a downstream merge that takes some of it**. Said exactly: the live one-contract
paragraph (C:880–890 / W:1063–1074) names the nonce, the slots, the provenance line, the curve,
the carry rule and the unknown-start semantics, and **it does not name this block or any of its
coupled edits**, so its coherence rule does not reach them. An earlier revision of this spec said
that rule caught them; it does not, and a project can take the clean predicate without the scoped
resolve duty, or either sense of *clean* without the other, and run. **That is an admitted unsafe
state, not a guarded one, and it is this change's own.** An earlier revision assigned the guard to
the successor; that was wrong on the face of the successor's own scope, which is record
durability and **excludes the closure ordering by name**, so the assignment named an owner that
had not taken it — the same defect as claiming a mechanism that does not exist. Nothing here
builds one, and a downstream project gets no coverage for this set.

**Out of scope and parked**, unchanged:

- The pass-counter anomaly (`fic2` record).
- The CodeRabbit plan-metadata contradiction (`fic2` record).
- The fixture-per-predicate question (`fic2` record; story §2).
- Hook code under `plugins/dev-workflow/hooks/`.
- `todos.md`: both-branches-misread-each-other; self-consuming-deletion (prompt-standards item
  11); the three bot findings in resolved plans.
