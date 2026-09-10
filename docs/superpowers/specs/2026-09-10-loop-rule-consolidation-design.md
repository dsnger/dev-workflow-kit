# §5 loop-rule consolidation: one closure ordering — Design

**Date:** 2026-09-10 · **Status:** DRAFT — Gate A running (pass 1 revised)
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

**What does not.** The pass floor and severity semantics (the parent shipped them and this spec
reads them as given); hook code; and the items the story's §2 parks — the pass-counter anomaly,
the CodeRabbit plan-metadata contradiction, and the fixture-per-predicate question.

---

## 2. Settled inputs

The story's §4 table, decisions 1–10, is the design's starting point and is not restated here;
each is cited below as **D1**…**D10** (with **D9b**, **D9c**). Two implementation facts the parent
cycle established are read as given: a pass's cleanliness is a fact about what that pass found
and is **never rewritten** — an answer changes whether the *cycle* may close; and the findings
files establish the **inventory** of findings, not their resolutions.

This spec adds what the table does not settle, each decided in the section that uses it: the
evaluation order and the definition of a clean pass under a decline, read at effective
severity (§3); the two triggers of the scope stop and what each answer does (§3); what the
user's answer to a stuck or two-tell surface produces, including a stop (§3); the wording,
the nonce status and the recording point of the decline record (§4); and the raw-severity
rule for the health measures (§5, passage (g)).

---

## 3. The closure ordering — the block that ships

It sits in §5 **immediately before** the paragraph "**What a loop absorbs, and what stops it**",
in both copies, byte-identical. It states the ordering once; the paragraphs after it keep their
triggers and point at it. Verbatim as it will ship:

```
**How a cycle ends — one ordering, stated here and referenced everywhere else.** A pass is
read in a fixed order, because every rule below bears on one decision — may this cycle close —
and a stated order is what stops them qualifying each other. **First, clean completion**, read
on the pass's validated findings file at **effective** severity, after the Mechanics severity
ceiling: cleanliness is about what the cycle must repair, and the ceiling is what decides that.
**A pass is clean** when it carries no in-set Blocker or Major at effective severity that is
not matched by a decline recorded in this cycle (Mechanics, the decline record), and it
surfaced no scope stop; a pass with **zero** findings is clean whatever the floor. **A clean
pass at or above the derived floor, or a zero-finding pass, closes the cycle** — a plateau or
tells present on that pass go into the closing report and never block it, because reporting
"will not converge" on a converged loop is a false report, and the clearly-stuck paragraph
says the same of its own exit. Only the named health measures — the per-pass counts, the
clusters and the tells — read the reviewer-written field before the ceiling (Mechanics,
Severity). **Nothing else closes a cycle.**

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
question, takes the scope stop's answers at that same surface — it is not asked twice.

**What a suspension asks, and what ends it.** Only a scope stop raises a **hold**, on its
finding, and a hold ends with **any** answer, in either direction — a hold only accepting could
end would be the resolve duty under another name. At a membership stop the answer is
**accept** (the finding joins the fix set and resolves by its effective severity: Blocker or
Major before any pass can be clean, Minor or Nit collected and never iterated) or **decline**
(the finding stays outside, recorded, binding for the rest of this cycle — Mechanics, the
decline record). At a question stop the answer is the user's decision on the question, and
membership does not change: an in-set finding then resolves under that decision or is
dismissed with its one-line why; an out-of-set finding that opened the question is a
membership stop as well and takes accept or decline. **Decline is available only at a
membership stop.** The stuck and two-tell readings raise no hold: each asks one question,
**continue or stop**. Continue resumes the loop on the artifact as revised and the fix set as
the governing artifacts now assign it — where several plans or stories govern one cycle, the
union of the scopes they assign plus the obligations already accepted — and a finding that a
narrowing has put outside the set surfaces at the next pass as a membership stop. **Stop
leaves the suspension standing**: the cycle stays open under its nonce, resumable by a later
continue, nothing it wrote is a closing commit, and an open cycle nobody resumes is a human's
to resolve, exactly as the nonce rules already say of open cycles.

**Composition, and what cannot happen.** Every question is answered on its own, and the loop
resumes only when every answer resumes it — accept or decline at a membership stop, a decision
at a question stop, continue at the stuck or two-tell reading; one stop answer leaves the
whole suspension standing, because a loop resumed over an unanswered question decides it by
running. **No pass that surfaced a scope stop is credited as clean** — a fact about that pass
no later answer rewrites — so a decline never closes the cycle on the surfacing pass; the
next pass is clean or not on its own findings. Two states cannot co-occur, and no rule ranks
them: clean completion and a scope stop, since a pass that surfaced one is not clean; and a
zero-finding pass and any suspension, since it has nothing to surface, nothing regenerating,
no cluster and no require↔withdraw pair. The Gate-B triviality skip is outside this ordering:
a skipped cycle runs no passes and ends by its own rule.
```

Why each part is there, briefly. The evaluation order is the answer to the objection that a
ranking between clean completion and the two-tell stop cannot fire if the stop can make the
pass unclean: clean completion is read first, so a suspension is only ever evaluated on a pass
that did not close. Reading cleanliness at effective severity keeps the resolve duty and the
clean-pass test on one field, and leaves the health measures — passage (g) — on the other;
a demoted finding cannot then keep a pass unclean while owing no repair. The first paragraph
is **D1**, **D2** and **D3**, the three suspensions named as their paragraphs name them
(`b11`/`b13`, `c4`, `e7`); "nothing else closes a cycle" exists for story AC 4. The two
triggers of the scope stop are `b11` (membership) and `b13` (question) read separately,
because an in-set finding that opens a question can neither "join" nor "stay outside" the set
and needs its own answer. The composition paragraph is AC 1's demand that every reachable
conflict be covered and every unreachable one named with its reason (the `fic2` record
documents the instrument that legislating built). The stop answer is the one new state this
spec supplies beyond the table — a standing suspension, resumable, never a close — and it
uses only mechanisms already shipped: resumption on the revised artifact (`b18`), the
membership stop (`b11`), and the nonce rules' existing treatment of open cycles ("they stay
open, keep their own nonces, and are a human's to resolve", C:423–424). **D3** keeps the
clearly-stuck paragraph's own precedence sentence verbatim (§5, passage (c)); the block cites
it rather than restating its consequence clause. The "further pass" reading mirrors the
profile-change rule — "it is one more pass, not a licence to close on the next one" (C:763–764)
— so the two read alike.

What the block deliberately does not do: it does not define the floor, the tells, or the
stuck reading — those stay in their paragraphs ("exactly one definition of the floor must be
present", C:176; "the other closure and stop predicates … not required to derive from the
floor", C:181–185). It does not restate any rule it does not own (`a13`).

---

## 4. The decline rule and record

**The rule.** A decline is the user's recorded answer at a membership stop — that the surfaced
finding stays outside the assigned fix set — and it is available for no other finding
(**D6**): not for an in-set Blocker or Major, and not as the answer to a question stop, a stuck
or two-tell surface, or any obligation. It binds for the remainder of its cycle and has no
effect in any later one (**D7**); it must be an explicit, attributable decision on that specific
finding — never silence, a general remark about scope, or an inference (**D8**). A later pass's
finding is **the same finding** when all five of location, defect, severity, consequence and
suggested fix match (**D9b**); the match is read on meaning, not on bytes, because a reviewer
rewrites its sentences between passes — and any difference, severity included, or any genuine
uncertainty, makes it a new finding and the hold applies. A decline releases the hold and never
qualifies the Blocker/Major-resolve duty, which the finding never reached (**D5**).

**When it is recorded.** When made, into the cycle's next commit body on the branch — a spec or
plan revision commit for a Gate-A cycle, the `WIP:` amend for a Gate-B cycle — and restated in
every later body of that cycle, the closing one included. The advisory working record may
carry it too. A cycle that resumes with no commit body carrying a decline treats it as absent
and the hold applies again — the reading the unknown-start fallback gives, and the safe
direction: a lost decline costs a repeated question, an invented one releases a hold nobody
chose to release. **D9**'s "closing commit body" is therefore the last of the bodies that carry
it, not the first.

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
  read on meaning rather than bytes, since a reviewer rewrites its sentences between passes;
  **any difference — severity included — or any genuine uncertainty makes it a new finding,
  and the hold applies.**

  ```
  Declined: <handle> · <date> · cycle <nonce>
  Finding: <severity> | <location> | <defect> | <consequence> | <suggested fix>
  ```

  The `Finding:` line is the finding line from the pass's findings file with its confidence
  field removed — the five fields the sameness test reads, in the file's order, a literal pipe
  escaped as `\|` exactly as there. **It carries the cycle nonce**, because it binds to one
  cycle and a record that cannot be attributed to its cycle cannot bind to it. **When and
  where:** written when made, into the cycle's next commit body on the branch — a spec or plan
  revision commit for a Gate-A cycle, the `WIP:` amend for Gate B — and restated in every later
  body of that cycle, the closing one included, because a body that drops it releases nothing
  and re-asks the question; the advisory working record may carry it as well. A cycle that
  resumes with no commit body carrying a decline **treats it as absent and the hold applies
  again** — the reading the unknown-start fallback gives, and the safe direction. It is copied
  on squash-merge with the other records (the carry rule above). **What it is worth:** an
  unverified assertion of the same kind as the human exception — nothing checks that the
  handle belongs to whoever decided, that a human was asked, or that the reason is honest.
  **How it differs in force:** it releases a hold, which the human-exception form never does;
  narrowness bounds what a false one can do — one fully identified finding, one cycle — and
  that is not the same as making it safe. **What the body does not record, said here rather
  than discovered:** an accepted finding, a stuck or two-tell surface and its continue-or-stop
  answer leave no record of their own — from a closing body a reader can infer the close and
  any declines, and nothing else about which suspensions the cycle passed through.
````

**Which rules the answer modifies** (story AC 3): the scope stop's resume sentence (`b12`,
which gains "accepting or declining"), and the hold and the clean-pass definition (both in the
§3 block, where the answer's two directions are one rule). It modifies **no other rule**, and
none other carries the qualification: not the Blocker/Major-resolve duty (Mechanics, Severity:
"both must resolve", C:784 — **D5**: it stays unqualified because a declined finding never
enters its scope), not the floor, not the tells, not the stuck reading. A reader finding
"decline" at any rule outside those three has found a defect.

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
   binding, and decline records treated as absent so that no hold is released**…". `i12`'s
   sentence stays as written; this is the addition it invites.
6. **The human-exception "which commit" rule** (C:988–990 / W:1172–1174, `h3`–`h6`). Unchanged
   in wording. The decline block carries its own rule, which deliberately differs — written
   when made and restated in every later body, not written once into the closing body —
   because a decline must survive to the next pass while the human exception only has to
   survive to history.
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
   closure ordering and the decline record**, and **the unknown-start activation semantics
   that say what a cycle owes when its starting rules cannot be established** depend on one
   another," and after "and a carry rule naming records a project does not produce is
   inert." (C:885) add: "an ordering without the decline record is a hold whose declined
   direction has no release rule, a decline record without the ordering is a release with no
   hold to release, and a decline record missing from the squash carry or the nonce set is a
   record that cannot survive a merge or be attributed." The stop sentence that follows is
   unchanged and now covers these states.

The shorter "Copy every record into the squash body" sentence inside the human-exception block
(C:1004–1007) is generic and already covers a decline record; it is not edited. The "records
every cycle owes" list (C:698) enumerates unconditional records only; a decline record is
conditional, like the human exception, and is not added.

---

## 5. Edits to the existing passages, with the old-conditions accounting

Ids are the inventory's. "Kept" means the sentence stays in its passage; "moved" means it now
lives in the §3 block and leaves the passage; "replaced" means the condition changes and says
how; "dropped" carries its reason.

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
"…and it resumes the moment the user says whether the set now includes it — accepting or
declining it, under the closure ordering above." `b17`–`b18` OLD: "Stopping this way is **not
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
rule is not waived by surfacing, and the loop resumes on a continue." Accounting: `c1`–`c8`
kept; `c9`, `c10`, `c11` kept verbatim; `c12` kept (pointer form); `c13`, `c14` moved (the
zero-finding exception; the Minor-below-floor case is the block's "clean pass at or above the
derived floor" read in the negative); `c15`, `c16`, `c17` kept in the pointer sentence; `c18`
moved (no pass that surfaced a scope stop is credited as clean — narrowed to the scope stop,
because a stuck or two-tell surface on a below-floor clean pass leaves that pass's cleanliness
as it was); `c19` **replaced** — old: the loop resumes on whatever the user decides,
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
"This stop is a **suspension** under the closure ordering above." `e1`–`e11` kept.

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

Also touched, outside the inventoried passages: the nonce set, the nonce exemption, the "Both
shipped records" count, the gate-off list, the closing-message sentence and the one-contract
paragraph (§4 items 2, 3, 4, 7, 8, 9).

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
of the evidence entry (§9).

The decline block and the human-exception block it follows are byte-identical between copies
today (the site map confirmed C:840–1033 = W:1024–1217), and stay so.

---

## 7. Q6 — the pass-4 report without prior-pass history

Appended to the "**From pass 4 onward**" paragraph, both copies, after "…demanding what an
earlier pass had removed.":

```
**Where an earlier pass's findings file is unavailable** — its slot path absent from
`.context/codex-reviews/` in this workspace, as after a fresh checkout, a cleared `.context/`
or a cycle resumed elsewhere; a file that is present but fails validation is an incomplete
pass, already excluded, and a path resolved against the wrong root is the existing stop — the
report first reads the cycle's working record if one exists and says whether it used it, then
states which of the three lines it computed from the files it has, names the ones it could
not and why, and says that the two-tell threshold is being read on that reduced record. The
sensitivity is reduced concretely: the trend and the require↔withdraw comparison read only
the passes present, so a rising count or a pair that spans a missing pass cannot be seen. It
is not a stop of its own, and it does not make the working record mandatory: a report that
says what it could not see is the duty; a report that invents the trend, or omits the line
without saying so, is the failure.
```

This is **D10**. The trend and the require↔withdraw pair are derivable from the mandated
findings files alone (the `fic2` record verified that derivation reproduces the reported
figures), so unavailability is a property of the workspace, not of the format, and the answer
is disclosure rather than a new stop or a new mandatory artifact. The three causes named are
partitioned by what the agent observes — path absent, file present but invalid, path resolved
against the wrong root — and only the first is this state; the other two already have their
own rules, which is why the sentence points at them rather than restating them.

---

## 8. The slot discriminator — dissolved

Plan C's Tasks 19 and 20 (`docs/superpowers/plans/2026-08-30-review-loop-economics-plan-c-rollout.md`,
the drop note under Task 19) deferred "a general production" for a short deterministic
discriminator in the nonce's slot position to this story. It ships nothing here, because the
case it served no longer exists: every cycle started after the parent's rules bind holds a
nonce, and a cycle whose start cannot be established mints one rather than claiming `none
(pre-rule)` (`i11`). A rule for a no-nonce cycle would legislate for an unreachable state,
which is AC 1's prohibition. The `rle` naming that cycle used stays what its closing body
recorded it as — a plan-local exception under the old rules. This section and the story's §5
are the record; no prompt text changes.

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
names — membership stop, question stop, clearly-stuck exit, two-tell stop, a hold awaiting its
answer, accept, decline, a stop answer, two or three suspensions at once, a below-floor clean
pass, a zero-finding pass, the unknown-start fallback — and write the **next-state table**: for
each, the input that ends it and the state the cycle is in afterwards, citing the shipped line
the row reads, in both copies. The table lives in the plan and is quoted by the closing commit
body, not here. What would be observed if the claim "no path leaves a cycle unable to close
and unable to suspend" were false: a row whose next state is the same stop with no input
consumed — the shape the parent cycle shipped once (a stop whose only answer resumed a cycle
that immediately stopped again). The wiring can produce it because every row is filled from
the shipped text, not from this spec, and the inputs the `fic2` instrument omitted — the user's
answer, and the decline — are input columns here; so is the stop answer, whose next state is a
standing suspension by design and must read as one in the table, not as the same stop
re-raised.

**What this is not.** It is not the `fic2` decision matrix: that instrument scored N states
against old and new text with an expected output each, and Gate B found two defects in the
technique — a state's inputs must include every input the rule reads (the user's answer was
never a column), and a counterfactual must distinguish ABSENT from CONTRADICTORY. The check
above is a presence test whose parent state is absent by inspection; the walk above takes the
answer as an input and produces a next state rather than a scored expected output. **No fixture
per predicate is built** — that question is parked in the story's §2 and is not reopened.

**Evidence entry**, in the closing commit body, names: the battery run; the five assert pairs
with their working-tree and parent-tree counts; the §6 parity diff — the passages extracted,
the differences observed, and that each is one of the permitted rows; and the next-state
table's location in the plan plus its row count. It is revalidated before every Gate-B
re-review and before the closing amend, as §5 requires.

---

## 10. AGENTS.md invariants touched

- **Invariant 11 — `docs/prompt-standards.md`, all 12 items.** Most at risk here: item 6
  (rules carry their why — each constraint in the §3 block and the decline block carries its
  reason in the same sentence, and the (g) replacement gives two; the plan's review reads each
  sentence for one); item 8 (token-lean — the block replaces closure sentences rather than
  adding beside them, and `a13` is the reason the old sentences leave); item 10 (diagnostic
  states name their causes — the Q6 sentence partitions the unavailable state from its two
  neighbours and points each at its rule); and item 3 (stop conditions defined — the block's
  stop answer is a named, resumable state).
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
