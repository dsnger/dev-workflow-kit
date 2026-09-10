# §5 loop-rule consolidation: one closure ordering — Design

**Date:** 2026-09-10 · **Status:** DRAFT — Gate A not yet run
**Story:** `docs/superpowers/stories/2026-08-29-loop-rule-consolidation-story.md`
**Profile:** read from that header at every pass, never from here (it is `high / none /
battery+check+verification` as this is written, and the header is the only writable copy).

Prompt-only, in two mirrored copies: `CLAUDE.md` §5 (**C** below) and the inline template in
`plugins/dev-workflow/commands/workflow-init.md` (**W** below). No file under
`plugins/dev-workflow/hooks/` changes. Line numbers cite the tree at `7c0d475` (main) and are
re-read at execution; the plan carries the `grep -n` sites.

Two research inventories were taken before this spec and the plan re-reads them: a
135-condition inventory of the passages this spec rewrites (ids `a1`…`j4`, cited below), and a
site map of every sentence that enumerates the records a commit body carries.

---

## 1. Intent

**What ships.** One closure ordering, stated once in each copy, that says which exit *closes* a
cycle and which merely *suspend* it, what two suspensions at once do, and which of the four
standing duties participate in that ordering versus gate it as preconditions. On top of it: a
decline rule with a commit-body record, so a user's answer on a surfaced finding has one rule in
both directions; the answer to what a severity demotion does to the loop-health counts; the
answer to the pass-4 report when prior-pass history is unavailable; and the deferred slot
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

This spec adds four things the table does not settle, each decided in the section that uses
it: the definition of a clean pass under a decline (§3); what the user's answer to a stuck or
two-tell surface produces (§3, last paragraph); the wording and the nonce status of the decline
record (§4); and the raw-severity rule for the counts (§5, passage (g)).

---

## 3. The closure ordering — the block that ships

It sits in §5 **immediately before** the paragraph "**What a loop absorbs, and what stops it**",
in both copies, byte-identical. It states the ordering once; the paragraphs after it keep their
triggers and point at it. Verbatim as it will ship:

```
**How a cycle ends — one ordering, stated here and referenced everywhere else.** A running
cycle stops spending passes in exactly four ways, and only one of them closes it. **Clean
completion closes**: a clean pass at or above the derived floor, or the one early exit below it —
a pass with **zero** findings, which surfaces nothing and can trip none of the stops below. The
other three are **suspensions**: the **scope stop** (a finding outside the assigned fix set, or
one opening a new structural or contract question), the **clearly-stuck exit**, and the
**two-tell stop**. A suspension surfaces to the user with the finding still open and every duty
standing — the floor, the Blocker/Major filter and the clean-final-pass rule are not waived by
stopping — and the loop resumes on the answer. **Nothing else ends a cycle**: a cycle the user
stops without a clean pass is not closed, it is left open, and none of its records is a closing
commit.

**Four duties, and what each one is.** Two are **preconditions on closure**: the **derived
floor** gates closing and is discharged by the count of valid passes, the last of them clean,
or by the zero-finding exit above; the **Blocker/Major-resolve duty** gates closing and the cleanliness of every pass, is discharged
by repair followed by a clean pass, and applies to **in-set** findings only. Two are the
ordering itself: **a surfaced finding holds closure** until the user answers — that hold is what
makes a suspension a suspension — and **any answer ends it, in either direction**; and **no pass
that raised a hold is credited as clean**, a fact about that pass that no later answer rewrites.
So a decline never closes the cycle on the pass that surfaced the finding: the next pass is
clean or not on its own findings, and that further pass is one more pass, not a licence to
close.

**A pass is clean** when its validated findings file carries no Blocker or Major except one
matched by a decline recorded in this cycle (Mechanics, the decline record) — such a finding is
outside the set by the user's own decision and reopens nothing — and when the pass raised no
hold. Accepting a surfaced finding puts it in the fix set: a Blocker or Major then owes
resolution before any pass can be clean, a Minor or Nit is collected and never iterated.

**When two apply at once.** Two suspensions compose: one surface, both reasons in the report,
resume when every question raised is answered. Clean completion outranks the two-tell stop,
exactly as the clearly-stuck paragraph already says of its own exit — a clean pass at or above
the floor closes, and a plateau or the tells go into the closing report rather than blocking
it; reporting "will not converge" on a converged loop is a false report. Clean completion and the scope stop **cannot co-occur**, and
no rule ranks them: the scope stop is raised by a surfaced finding, and a pass that surfaced
one is not clean. Neither can a zero-finding pass meet any suspension: it has nothing to
surface, nothing regenerating, no cluster and no require↔withdraw pair. The Gate-B triviality
skip is outside this ordering — a skipped cycle runs no passes and ends by its own rule.

**The answer to a clearly-stuck or two-tell surface** is continue or stop. Continue resumes
the loop, on the artifact as revised and the fix set as the story or plan now assigns it — a
finding that narrowing has put outside the set surfaces at the next pass as a scope stop and
can be declined there. Stop closes nothing, as above.
```

Why each part is there, briefly. The first paragraph is **D1** and **D3** with the three
suspensions named as the existing paragraphs name them (`b11`/`b13`, `c4`, `e7`). The
"nothing else ends a cycle" sentence exists for story AC 4: every stop now has an answer that
changes state, and the answer that is not "continue" is named rather than left to be inferred.
The duties paragraph is the story's four duties, classified as AC 2 requires; the "further
pass" sentence carries the never-rewritten fact and mirrors the profile-change rule's "one more
pass, not a licence to close" (`o16`), so the two rules read alike. The clean-pass paragraph is
**D4**–**D7** turned into one definition; it is where the cycle would otherwise be unable to
close after a decline. The conflicts paragraph is **D2**, **D3**, and AC 1's demand that
unreachable conflicts be named with their reason instead of legislated (the `fic2` record
documents the instrument that legislating built). **D3** preserves the clearly-stuck
paragraph's sentence "a clean completion takes precedence over this exit" verbatim, so the
block defers to it for that exit rather than stating the same ranking twice; the ordering is
still stated once, and the kept sentence agrees with it. The last paragraph is the one new
answer this spec supplies beyond the table — what "hand the decision to the user" produces —
and it uses only mechanisms already shipped: resumption on the revised artifact (`b18`), and
the scope stop (`b11`).

What the block deliberately does not do: it does not define the floor, the tells, or the
stuck reading — those stay in their paragraphs (`o24`'s one-definition requirement, `o2`'s
independence of the other predicates from the floor). It does not restate any rule it does not
own (`a13`).

---

## 4. The decline rule and record

**The rule.** A decline is the user's recorded answer on a finding surfaced by the scope stop —
that it stays outside the assigned fix set — and it is available for no other finding (**D6**):
an in-set Blocker or Major cannot be declined, and a finding surfaced by the stuck or two-tell
stop is not a scope-stop finding until a later pass raises it as one (§3, last paragraph). It
binds for the remainder of its cycle and has no effect in any later one (**D7**); it must be an
explicit, attributable decision on that specific finding — never silence, a general remark
about scope, or an inference (**D8**). A later pass's finding is **the same finding** when all
five of location, defect, severity, consequence and suggested fix match (**D9b**); the match is
read on meaning, not on bytes, because a reviewer rewrites its sentences between passes — and
any difference, severity included, or any genuine uncertainty, makes it a new finding and the
hold applies. A decline releases the hold and never qualifies the Blocker/Major-resolve duty,
which the finding never reached (**D5**).

**The record**, in the closing commit body, reusing the human-exception transport as a distinct
record type (**D9**):

```
Declined: <handle> · <date> · cycle <nonce>
Finding: <severity> | <location> | <defect> | <consequence> | <suggested fix>
```

The `Finding:` line is the finding line from the pass's findings file with its confidence
field removed — the five fields the sameness test reads, in the file's order, a literal pipe
escaped as `\|` exactly as there. **Which commit:** the same rule as the human exception — a
Gate-A cycle in the spec or plan commit, a Gate-B cycle in the WIP commit restated by the
closing amend; several accumulate, order means nothing. **It carries the cycle nonce**, because
**D7** keys it to one cycle and a record that cannot be attributed to its cycle cannot bind to
it; it therefore joins the named set of records the nonce appears in, and the human-exception
record stays outside that set. **What it is worth:** an unverified assertion of the same kind
as the human exception — nothing checks the handle, the asking, or the reason (**D9c**).
**How it differs in force:** it releases a hold, which the human-exception form never does;
narrowness bounds what a false one can do — one fully identified finding, one cycle — and that
is not the same as making it safe. Where the human-exception form is never the answer to a
`STOP and surface`, the decline record is the answer to exactly one of them, the scope stop,
and to nothing else on that list: never a below-floor pass, an unclean final pass, a stuck or
two-tell surface, a Gate-A or Gate-B obligation, or an evidence requirement.

**Which rules the answer modifies** (story AC 3): the scope stop's resume sentence (`b12`,
which gains "accepting or declining"), the hold and the clean-pass definition (both in the §3
block, where the answer's two directions are one rule). It modifies **no other rule**, and
none other carries the qualification: not the Blocker/Major-resolve duty (`o19`, **D5** — its
"both must resolve" stays unqualified because a declined finding never enters its scope), not
the floor, not the tells, not the stuck reading. A reader finding "decline" at any rule
outside those three has found a defect.

**Existing sentences that must name it**, both copies, old → new. Line numbers are C's; W's
are in the site map and re-read at execution.

1. **Squash carry** (C:892 / W:1076, `j1`). OLD: "…copy every evidence entry, every
   human-exception record, the provenance lines, the curves and any skipped cycle's skip
   record TOGETHER WITH THE SKIP REASON IT POINTS AT…". NEW: "…copy every evidence entry,
   every human-exception record, **every decline record**, the provenance lines, the curves
   and any skipped cycle's skip record TOGETHER WITH THE SKIP REASON IT POINTS AT…". Six
   members; the rest of the sentence unchanged.
2. **The named nonce set** (C:384–387 / W:578–581). OLD: "…and that set is named rather than
   left open: the provenance line, the per-pass curve (including a skip record standing in for
   one), the cycle's findings slots, and its advisory working record." NEW: "…and that set is
   named rather than left open: the provenance line, the per-pass curve (including a skip
   record standing in for one), **any decline record (Mechanics)**, the cycle's findings
   slots, and its advisory working record."
3. **The nonce exemption** (C:397–399 / W:591–593). OLD: "The nonce is not required in
   records this change neither introduces nor keys to a cycle — the evidence entry and a
   human-exception record among them." NEW: "The nonce is not required in records that are
   not keyed to a cycle — the evidence entry and a human-exception record among them; **a
   decline record is keyed to its cycle and carries it**." (The old sentence's "this change"
   dated it to the parent; the new one states the criterion.)
4. **"Both shipped records below"** (C:367 / W:561). OLD: "Both shipped records below carry a
   **cycle field**, because…". NEW: "Both shipped records below carry a **cycle field** — and
   so does the decline record in Mechanics — because…". A load-bearing count that a third
   cycle-attributed record would otherwise falsify.
5. **The unknown-start fallback** (C:153–167 / W:360–374, `i4`–`i8`, extended at `i12`'s
   invitation). OLD list: "…at minimum floor 3, severity classified without the demotion, the
   provenance-line duty owed, the curve duty owed, and the nonce duties at their strictest…".
   NEW: "…at minimum floor 3, severity classified without the demotion, the provenance-line
   duty owed, the curve duty owed, the nonce duties at their strictest, **every suspension
   binding, and decline records treated as absent so that no hold is released**…". `i12`'s
   sentence stays as written; this is the addition it invites.
6. **The human-exception "which commit" rule** (C:988–990 / W:1172–1174, `h3`–`h6`).
   Unchanged in wording; the decline record's own paragraph (below the human-exception block,
   §5 passage (h)) says "which commit: the same rule as the human exception" and points here,
   so the rule is stated once.
7. **The gate-off surface** (C:143–151 / W:350–358). OLD tail: "…silencing reminders; or not
   running a pass and reporting that it ran." NEW tail: "…silencing reminders; not running a
   pass and reporting that it ran; **or recording a decline nobody made, or one on an in-set
   finding**." The list says it is not complete; this change creates a route and names it,
   as the parent did for the stated floor.

The shorter "Copy every record into the squash body" sentence inside the human-exception block
(C:1004–1007) is generic and already covers a decline record; it is not edited. The "records
every cycle owes" list (C:698) enumerates unconditional records only; a decline record is
conditional, like the human exception, and is not added.

---

## 5. Edits to the existing passages, with the old-conditions accounting

Ids are the inventory's. "Kept" means the sentence stays in its passage; "moved" means it now
lives in the §3 block and leaves the passage; "dropped" carries its reason.

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
prevents…". Accounting: `b1`–`b16`, `b18` kept; `b17` moved (the "every duty standing" sentence
of the block). W's three wording differences in this passage are untouched (§6).

**(c) Recognizing clearly stuck** (C:225–246 / W:428–449) — **trim** the closure sentences and
the surfacing block. OLD, from "That third condition is what makes a plateau…" to the end of
"…and then nothing could satisfy both.": replaced by "That third condition is what makes a
plateau rather than a finish, and it is why **a clean completion takes precedence over this
exit**. This exit is a **suspension** under the closure ordering above: you surface with the
findings still open, and the resolve rule is not waived by surfacing."
Accounting: `c1`–`c8` kept; `c9` kept verbatim (**D3**); `c10`, `c12`, `c13`, `c14` moved
(at-or-above-floor clean pass closes; below the floor nothing closes; the zero-finding
exception; the Minor-below-floor case is the block's "clean pass at or above the derived
floor" read in the negative); `c11` moved (the false-report sentence); `c15`, `c16`, `c17`
kept in the pointer sentence; `c18` moved (no pass that raised a hold is credited as clean);
`c19` moved (resumes on the answer); `c20` **dropped** — it argued that reading the
exit as "stop instead of fixing" would put it in competition with the resolve duty, and the
block now classifies the exit as a suspension that waives nothing, which is that argument's
conclusion stated as a rule. A rationale for a competition the ordering no longer permits
would be prose about a rule that no longer applies.

**(d) From pass 4 onward** (C:255–261 / W:459–465) — **add** the Q6 sentence (§7). `d1`–`d7`
kept, unchanged.

**(e) The five tells** (C:263–268 / W:467–472) — **add** one pointer sentence after `e10`:
"This stop is a **suspension** under the closure ordering above." `e1`–`e11` kept.

**(f) The two rules above do not compete** (C:275–287 / W:473–483) — **unchanged**. "The two
rules above" still names the absorb rule and the stuck reading; the block sits before both and
adds no third rule between them. `f1` remains true: the block composes the two suspensions
and ranks neither over the other.

**(g) Mechanics · Severity · the handed-over question** (C:810–815 / W:996–999) — **replace**
the whole paragraph, both copies, with the answer. NEW:

```
  **The demotion changes what a cycle must resolve, never what it counts.** The per-pass
  counts, the finding clusters and the tell thresholds read the severity the reviewer wrote in
  the findings file, before the ceiling is applied: a demoted finding still counts in the
  finding total and in its cluster, and a Blocker demoted to Minor is still a Blocker to the
  curve. Two reasons. The curve must stay derivable from the findings files alone — counting
  finding lines and leading `BLOCKER` fields per pass reproduces it, which is the only thing
  that makes a self-reported curve checkable. And the demotion is the author's judgement about
  the fix set; a loop spending passes on findings the author keeps demoting is exactly what the
  prose-cluster tell exists to surface, and lowering the counts by that same judgement would
  hide it.
```

Accounting: `g1` **dropped** (the unsettled statement, now settled); `g2`, `g3` **dropped**
(the interim report-and-stop duty existed only until the question was settled, and its trigger
no longer exists); `g4` **dropped** in C (the ownership sentence, discharged by this change),
and W, which never carried it, gets the same replacement paragraph — so the one deliberate
story-path difference between the copies is removed.

**(h) Recording a human exception** (C:977–1033 / W:1161–1217) — **unchanged**, and a new
block **"Recording a decline."** is added immediately after it (before "**Do not expect
silence from the gate hook**"), carrying §4's rule, form, which-commit pointer, worth, and force
paragraphs. `h1`–`h26` kept; `h17` stays true of the human-exception form, and the decline
block says which one item of that list it *is* the answer to.

**(i) When these rules bind** (C:153–167 / W:360–374) — **extend** the strict-reading list
(§4 item 5). `i1`–`i16` kept.

**(j) The squash carry** (C:892 / W:1076) — **extend** (§4 item 1). `j1`–`j4` kept.

Also touched, outside the inventoried passages: the nonce set, the nonce exemption, the "Both
shipped records" count and the gate-off list (§4 items 2, 3, 4, 7).

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
row is gone. Any other difference is a defect, not a wording choice.

The decline block and the human-exception block it follows are byte-identical between copies
today (the site map confirmed C:840–1033 = W:1024–1217), and stay so.

---

## 7. Q6 — the pass-4 report without prior-pass history

Appended to the "**From pass 4 onward**" paragraph, both copies, after "…demanding what an
earlier pass had removed.":

```
**Where the earlier passes' findings files are unavailable** — a fresh checkout, a cleared
`.context/`, a cycle resumed elsewhere — the report states which of the three lines it can
compute from the files it has, names the ones it cannot and why, and says that the two-tell
threshold is being read on that reduced record. It is not a stop of its own, and it does not
make the working record mandatory: a report that says what it could not see is the duty; a
report that invents the trend, or omits the line without saying so, is the failure.
```

This is **D10**. The trend and the require↔withdraw pair are derivable from the mandated
findings files alone (the `fic2` record verified that derivation reproduces the reported
figures), so unavailability is a property of the workspace, not of the format, and the answer
is disclosure rather than a new stop or a new mandatory artifact.

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
  the parent tree.

If the claim "the ordering and the record ship in both copies" were false, one of the
working-tree counts would be **0** or the parent-tree counts would not differ from it. The
wiring can produce that observation: each grep reads the file bytes at the named revision,
nothing supplies its own input, and the parent tree is the actual prior state. **The
counterfactual is ABSENT, and is claimed as absent**: the parent carries no ordering block and
no decline record, and the (g) count is the one site where the parent is present and the change
removes it. No count against the parent is claimed as "contradictory".

**The named verification of the risk path** (story AC 4). Walk every stop the shipped text
names — scope stop, clearly-stuck exit, two-tell stop, a hold awaiting its answer, accept,
decline, two suspensions at once, a below-floor unclean pass, a zero-finding pass, the
unknown-start fallback — and write the **next-state table**: for each, the input that ends
it and the state the cycle is in afterwards, citing the shipped line the row reads, in both
copies. The table lives in the plan and is quoted by the closing commit body, not here. What
would be observed if the claim "no path leaves a cycle unable to close and unable to stop"
were false: a row whose next state is the same stop with no input consumed — the shape the
parent cycle shipped once (a stop whose only answer resumed a cycle that immediately stopped
again). The wiring can produce it because every row is filled from the shipped text, not from
this spec, and the two inputs the `fic2` instrument omitted — the user's answer, and the
decline — are input columns here.

**What this is not.** It is not the `fic2` decision matrix: that instrument scored N states
against old and new text with an expected output each, and Gate B found two defects in the
technique — a state's inputs must include every input the rule reads (the user's answer was
never a column), and a counterfactual must distinguish ABSENT from CONTRADICTORY. The check
above is a presence test whose parent state is absent by inspection; the walk above takes the
answer as an input and produces a next state rather than a scored expected output. **No fixture
per predicate is built** — that question is parked in the story's §2 and is not reopened.

**Evidence entry**, in the closing commit body, names: the battery run; the four assert pairs
with their working-tree and parent-tree counts; and the next-state table's location in the plan
plus its row count. It is revalidated before every Gate-B re-review and before the closing
amend, as §5 requires.

---

## 10. AGENTS.md invariants touched

- **Invariant 11 — `docs/prompt-standards.md`, all 12 items.** Most at risk here: item 6
  (rules carry their why — every sentence of the §3 block carries its reason inline, and the
  (g) replacement gives two); item 8 (token-lean — the block replaces closure sentences rather
  than adding beside them, and `a13` is the reason the old sentences leave); item 10
  (diagnostic states name their causes — the Q6 sentence names what could not be computed and
  why); and item 3 (stop conditions defined — the block's last paragraph is what "hand the
  decision to the user" now produces).
- **Don't: "Never replace a decision procedure without accounting for its old conditions."**
  Satisfied by §5: every inventory id for every edited passage is marked kept, moved or
  dropped with a reason.
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
