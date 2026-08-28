# Review-loop economics: pass floor, severity semantics, and the §5 loop-rule consolidation — Design

**Date:** 2026-08-28 · **Revision:** 4, after Gate-A passes 1 (27), 2 (30), 3 (54 findings)
**Story:** `docs/superpowers/stories/2026-08-28-review-loop-economics-pass-floor-story.md`
**Profile (read from that header, not copied):** risk `high` · security `none` ·
validation `battery+check+verification`, no `+abuse-path`.

Prompt-only. No file under `plugins/dev-workflow/hooks/` changes, and **no file the hook reads
is written by this design.**

**Surfaces edited.** `CLAUDE.md` §5 (65–589) and its mirror inside `/workflow-init`'s inline
`CLAUDE.md` template (`plugins/dev-workflow/commands/workflow-init.md`, fenced 192–778; §5 is
257–777), plus the user-facing statements this change falsifies (§7). The two §5 copies already
differ on 192 lines across 20 hunks; this design touches only the rules it changes, per story
criterion 7.

---

## 1. The finding this design is built on

**The loop has four exits and four standing duties**, each in its own bolded paragraph, each
qualifying the ones before it — and nowhere does §5 say which wins when two apply at once.

*Scope of that claim:* four exits **of the loop**. §5 carries other mandatory stops that are not
loop exits — a target surviving deletion, an exhausted recovery budget, an unresolvable profile,
a blocking evidence or setup gap. Those halt the *procedure* rather than resolving the *cycle*,
do not compete with clean completion, and are not reordered here.

### 1.1 Only one exit closes

Already in §5, in two places, with the conclusion never drawn:

> "Stopping this way is **not an exit from the gate**: the floor, the Blocker/Major filter and
> the clean-final-pass rule all stand, and the loop resumes on the revised artifact once the
> question is answered."

> "You surface *with the finding still open* — the resolve rule is not waived, no pass is
> credited as clean, and the loop resumes on whatever the user decides."

**Clean completion closes. The scope stop, the clearly-stuck exit and the two-tell stop
suspend.** So **suspension × suspension is not a conflict** — two at once means the report
carries both reasons. Three pairs, one sentence, no ordering.

### 1.2 Three of the four duties are not participants

- **The floor** is a quantity gating closure — "**Below the floor nothing closes**".
- **Blocker/Major must resolve** is a **precondition on closure, and it is not discharged by a
  quiet pass.** A pass that raises no *new* Blocker or Major is not evidence that a previously
  surfaced one was resolved; the resolution is a separate fact, and the closing report names
  each surfaced Blocker/Major and how it was resolved. (An earlier revision called this
  "definitional", which is the describe-what-a-gate-proves failure: the clean-pass condition
  proves what the reviewer found *this* pass, not what happened to earlier findings.)
- **A surfaced finding stays open** is the *mechanism* making the other exits suspensions.
- **No pass carrying a surfaced finding counts as clean** is the only participant in ordering.

---

## 2. The precedence structure (part 3)

| Conflict | Resolution |
|---|---|
| clean completion × clearly-stuck | **Clean wins.** §5 already says so; preserved verbatim. Settled and probably unreachable — a clean pass has no regenerating Blocker/Major, so the exit's third condition fails. Kept because dropping a sentence §5 already spends is the failure criterion 6 exists to prevent. |
| clean completion × two-tell stop | **Clean wins.** Daniel's recorded decision, encoded not reopened. |
| clean completion × scope stop | **The scope stop outranks closure while any surfaced finding remains unresolved and undeclined.** A finding the user has explicitly declined is resolved *for this purpose* and no longer holds the cycle. |

**The third cell's wording is deliberate.** An earlier draft read "clean wins only when every
surfaced finding still open has been explicitly declined", which is self-contradictory: §2.1
defines a decline as *releasing* the finding. The rule is stated once, from the hold's side.

**Why the third is the only one that needed deciding.** A scope stop is triggered by a *specific
finding*; while the duty stands unqualified that finding is open, so the pass cannot be clean and
the scope stop wins automatically. The cell exists only because the duty may now be qualified.

**The asymmetry that explains the history:** the two-tell stop is triggered by *statistics about
findings*, not by a finding — nothing is left open, the duty does not bite, clean can win. The
scope stop's trigger **is** a finding. The reverted clause tried to unbite that by qualifying
three universal rules at once. The lattice was correct.

### 2.1 The qualification, and how a decision on a finding is recorded

**The duty is qualified for, and only for, a finding the user has explicitly declined.** Per
story criterion 5, the qualification appears **at each of the three universal rules** in both
copies — not only at the new clause, which is what made the earlier attempt unshippable.

**All three branches, symmetrically.** §5 already says the loop "resumes the moment the user says
whether the set now includes it" — resumption *is* the hold ending, whichever way the answer went.

- **Declined** → released as recorded-declined; stops holding the cycle for the remainder of it,
  and does not re-stop later passes.
- **Accepted** → enters the assigned set, where **severity governs exactly as Mechanics already
  says**: an accepted Blocker or Major must resolve, **and the pass that surfaced it is still not
  clean until it does** — acceptance ends the *hold*, not the resolve duty. An accepted Minor or
  Nit is collected, never iterated, and in-set Minors have never blocked a clean pass at or above
  the floor. There is no deadlock; the apparent one assumed the hold outlives the answer.
- **Undecided** → the hold stands. Nothing closes unanswered.

**Where the decision is recorded — the commit body, on rails §5 already ships.** The
human-exception machinery already solves this transport: "an ungated change records it in that
commit; a Gate-A cycle in the spec or plan commit; a Gate-B cycle in the WIP commit, restated by
the closing amend", folded in mid-cycle by amend, carried into the squash body. **The decline
reuses that transport as a different record type:**

```
Declined finding: <cycle id> · <pass>/<slot>/<line> · <handle> · <date>
Location: <the finding's location field, verbatim>
Defect: <the finding's defect field, verbatim>
Severity: <BLOCKER|MAJOR|MINOR|NIT>  Consequence: <verbatim>  Fix: <verbatim>
Reason: <one line>
```

**The record stores exactly what the sameness test reads.** An earlier revision stored location
and defect while testing sameness against severity, consequence and suggested fix — a test
reading fields the record lacks, which is the same class as the wiring failure §8 warns about.
Both now carry all five.

**Identity.** A later finding is the same finding when **all five recorded fields match**. Any
difference — including a severity change, since a Minor re-raised as a Blocker is not the thing
that was declined — makes it a **new finding, and the hold applies**. Where sameness is unclear
it is likewise new, which costs a question and never a silent release. This mirrors §5's existing
treatment of unclear set membership.

**A decline binds one cycle only.** The record carries a cycle identifier and **has no effect in
any later cycle**, even though the record itself persists into commit and squash history. Without
that bound, a decline recorded once would silently release the same finding in every future
cycle, which nobody decided.

**The distinction from the human-exception form is stated explicitly.** They are not the same
record:
- The **human-exception form authorizes nothing** — §5 says so in its own words, and says it is
  never the answer to a below-floor pass, an unclean final pass, or a `STOP and surface`.
- The **decline record has §5-defined effect**: it releases one specific finding from the hold.
  That effect comes from the loop's own scope rule — which already routes set membership to the
  user and already resumes on the answer — not from human assent overriding a mandatory rule.
  Every other mandatory rule stands.

**What the record establishes, said plainly.** Like the human-exception record beside it, this is
an **unverified assertion**: the commit body is author-written, and nothing checks that the handle
belongs to whoever decided. A reader learns that *the commit claims* the user declined this
finding. The shipped text says so rather than implying evidence. What makes it safe is not
verification but **narrowness** — it releases one fully-identified finding, in one cycle.

**"Explicitly declined" is defined tightly.** A **recorded user decision on that specific
finding**, attributable and unambiguous. **Never** silence, never a general remark about scope,
never the agent inferring a decline from context. All three negatives ship.

**The dispositions companion stays what §5 says it is** — the advisory working copy. The commit
body is the record.

---

## 3. Severity semantics (part 2)

**The decision procedure is the rule. The subject list is illustration.**

> Name the gate, skill, rule, escalation procedure or scaffolded template that reads this text,
> and the decision it takes differently if the text is wrong. If you cannot name an in-system
> reader and a changed decision, the finding is **Minor** — collect, never iterate.

Findings about narration, mechanism prose and test-instrument internals are the cases this
usually catches, shipped as **worked examples of the test, not a second rule beside it**. Stating
a categorical demotion *and* the test would give two procedures that can disagree on one finding.

**A human reader never satisfies the test.** That cost class is already priced as non-gating by
§5's prose exemption — "a wrong sentence costs a confused reader, not broken behaviour".

**The instrument carve-out runs in both directions.** An instrument finding keeps its severity
when it shows the instrument **changes what the gate concludes about product behaviour** — a
false green, and equally a false red, a check that blocks a valid change, or instrument logic
driving an unnecessary rewrite. Naming false green alone would demote a check that fails for
wiring reasons and costs a correct change.

**Why not a list of demotable artifact kinds.** The field record falsifies that form. Of three
`fic2` pass-5 findings on one parked story's criterion, two were correctly parked and **one was
correctly acted on** — "the pass-4 activation boundary — because a future rewrite could otherwise
move the duty to pass 1 while checking off every other listed condition." Same artifact, same
pass, opposite correct answers. An enumeration would also travel into scaffolded repos whose
artifact kinds we have never seen — invariant 10's problem in a new place.

**Kinship, stated in the shipped text.** The **finding-level analog of the path-level prose
exemption** — one principle at two granularities: text that *describes* the product versus text
that *is* the product.

**The boundary case, qualified rather than blanket.** Rationale prose inside a rule file is
**Minor when no rule's application depends on it**, and **not** categorically Minor.
`docs/prompt-standards.md:49-51` requires that "Rules carry their why", because "models follow
motivated rules better, and reviewers can judge whether the rule still applies", and invariant 11
makes that checklist binding. Rationale a reader must consult to decide whether or how a rule
applies **is** read by an in-system reader and passes the test.

**This test removes arbitrariness, not judgement**, and the shipped text says so. Two readers can
still disagree about whether a named reader's decision changes; what they can no longer do is
decide by taste, because the test names what must be produced — a reader and a changed decision.
Claiming a judgement-free rule would be a promise no prose rule keeps.

**Coverage-first unchanged:** the reviewer reports every finding with severity and confidence;
the filter is ours.

**Expected effect, with its limit.** The intent is that distributions like PR #23's — 16 in a
never-committed scratch harness, 10 in narration, 1 in a plan — demote substantially. **How much
is not predictable from the recorded counts**, because `7bbdb14`'s own body describes harness
defects that could make checks pass for wiring reasons, which the two-directional carve-out keeps.
`fic2`'s pass-2 meta cluster demotes only partially: ledger rows keep severity because escalation
reads the recurrence count, story criteria because the assigned-fix-set rule reads them. **The
amount is a prediction rather than a measurement**, which is why the story routes it to P8.

---

## 4. The pass floor (part 1)

**One predicate.** `max(risk, security) == 0` → floor **1**. Everything else → **3**, unprofiled
included. Two levels, not three: `high` takes its rigor from lens sets and evidence mode.

**Several cited stories: unanimity.** Floor 1 **if and only if every cited story is profiled and
every one is at level 0**. Any other set — mixed levels, any unprofiled member, any higher
profile — yields 3. §5's own precedent for the analogous relaxation ("skip-eligible only if
**every** cited story is"), and the only reading consistent with invariant 2's firing direction.

**Why the text must say the floor governs both gates.** `codex-gate.sh:119` sets a single
`floor`, consumed at `:946` for Gate B and `:966` for Gate A. A reader who does not know this
will write a rule for one gate and assume the other is untouched.

**Why there is no `docs-only` arm.** A diff-derived reading cannot serve Gate A, which runs on a
spec before any diff exists. A story-declared reading is subsumed: intake defines `trivial` as
"no behavioural effect in the artifact's own execution context". And a path-derived arm would be
**wrong in this repo**: `docs/hardening-log.md` is a `docs/**.md` path that drives rung
escalation. That is §3's reachability test deciding a §4 question.

### 4.1 The floor lives in the text, not in a file

**Nothing in this design writes `.context/codex-gate.floor`.** The agent derives the floor from
the profile and **states it** — in every pass report and in the commit-body provenance line. That
is where the floor lives, and §5's text is what binds the agent, as it always was.

**The workspace knob stays exactly what it always was: the hook's reminder threshold.** It is
never written, never removed, and never read for our derivation. Mechanically it never bound an
agent — `$floor` appears only inside the hook's advisory `note` messages (`:933`, `:946-947`,
`:956`, `:966-967`, `:973`), and the hook is advisory by invariant 1. Where the user's knob and
the derived floor diverge, the provenance line **discloses both** rather than resolving them:

```
floor N per <cited story path>; hook reminder threshold M per workspace knob
```

**The consequence, accepted rather than engineered around: a level-0 cycle closing at one pass
draws a hook reminder saying "below floor (1/3)".** That reminder is **the invariant working**,
not a defect — AGENTS.md invariant 2: *"On uncertainty, fire. A missed commit (false ✓) is the
dangerous direction; **a redundant warning is the accepted price.**"* A hook taught to fall silent
at 1 would be the false ✓ the invariant names as dangerous.

**Why an earlier revision's marker mechanism was deleted rather than repaired.** It had the agent
write the knob plus a marker distinguishing agent writes from user writes. Gate-A pass 3 returned
sixteen Majors against it — write ordering, removal ordering, cross-cycle ownership, staleness,
rollback contamination — and one that settled it: **the cheapest bypass was marker-specific.**
Write `1` without a marker, or delete the marker afterwards, and an agent-chosen floor is
camouflaged as a user decision. A protection that makes the attack indistinguishable from the
protected case is not incomplete; it is inverted. Deleting it removes every one of those findings,
the concurrency exposure on a shared mutable file, and the whole class of crash-recovery rules
written in prose for an advisory file.

**The sanctioned lever for wanting fewer obliged passes is the profile** — proposed, human-
confirmed, logged — **or `codex-gate.off` for the reminders.** Not the floor knob, which moves
what the hook says and never what §5 obliges.

### 4.2 A profile that moves mid-cycle

Composed from three rules §5 already has; no new rule, and nothing to re-write on disk. The floor
derives from the **current** profile at each pass (§5 already requires the header read fresh);
**passes already run keep counting**; **closing requires meeting the floor as currently derived.**

**The consequence that must be stated, or the arithmetic reads wrong:** under a **raise**, at
least one further pass is required *regardless of the floor arithmetic*, because §5 already
requires the final clean pass to run under the current profile. A previously-final clean pass
stops qualifying the moment the profile moves — so even a raise leaving the floor unchanged
(`standard` → `high`, both 3) costs a pass.

**On lowering.** A lower drops the floor *and* the lens sets *and* the evidence mode, so a `high`
cycle lowered to `trivial` can close on one pass. That is the pre-existing profile-change path,
human-confirmed in both directions and logged. The variable floor rides it; it does not create it.

---

## 5. Q6 — the pass-4 report when prior-pass history is unavailable

**Answer: report what is computable, name what is not and why, disclose the reduced sensitivity.**
Not a new stop condition, not a mandatory resume note.

Of the five tells, **three need history** — finding count rising, Blocker count failing to fall, a
require↔withdraw pair — and **two are computable from the current pass alone**: clustering on the
instrument, clustering on prose. With no prior record the two-tell threshold **remains reachable**
on the cluster pair. The duty loses sensitivity; it does not become inoperative.

**Four shapes, each with its own check and remedy** — symptoms alone would be prompt-standards
item 10's failure:

| Shape | Check | Treatment |
|---|---|---|
| **absent** | the slot file does not exist | uncomputable; report which pass numbers are missing |
| **partial** | some pass slots present, others not | compute historical tells over the passes present and **name the missing pass numbers** — a trend over an unstated subset reads as a trend over the cycle |
| **malformed** | fails the pass-acceptance checks: terminator, count match, no non-finding lines | treat as absent for that pass, **never** as zero findings. Distinct from *unreadable*: a malformed file is a review that ran and wrote badly, so **if its `sessionId` is still to hand** the pass may be re-runnable — and where it is not, say so rather than implying a recovery route that no longer exists |
| **unreadable** | exists but cannot be opened or decoded | treat as absent; report the OS-level cause, since permissions and a full disk need different fixes |
| **stale** | the slot's cycle discriminator is absent or is another cycle's | treat as absent **and report its presence** — a foreign curve is worse than no curve |

**Stale is only partly detectable, and the text says which part.** Bare numbered slots carry no
cycle identity, so a pass-2 file from a previous cycle is indistinguishable by content. Two
prompt-only mitigations: the **slot discriminator convention** — a cycle uses a per-cycle infix,
as this cycle's `rle` does, following the `fic2` and `pr15` precedent, which makes *its own* slots
identifiable — and **§5's existing delete-and-confirm-before-each-call rule**, which guarantees the
file you are about to write is not a previous cycle's. Neither makes a bare-slot file's origin
recoverable after the fact, and the report says so rather than implying detection. (The
discriminator convention also prevents the destruction this cycle caused once: deleting a bare
slot destroyed a previous cycle's findings record, which the dispositions companion happened to
survive.)

**The disclosure is not optional and names the cause.** The report says which tells could not be
computed, **which shape applies**, and which pass numbers are affected.

**Why the alternatives are rejected**, per story criterion 5: making the resume note mandatory
changes an artifact §5 explicitly calls advisory; treating unavailable history as its own stop
would halt every cycle resumed on a fresh checkout; restarting the pass-4 clock at the first
*visible* pass silently lowers coverage.

**Stated risk.** Reporting rather than stopping fails *toward continuing* the loop, the direction
invariant 2 questions. The mandatory disclosure is what makes it acceptable.

### 5.1 The curve in the commit body — all three loops

**Each loop records its own per-pass finding and Blocker counts in its own commit body**, each
line **labelled with the loop it describes** so a squash body carrying several stays unambiguous:

```
Gate-A spec loop: Findings 27, 30, 54. Blockers 5, 2, 0.
Gate-A plan loop: Findings 8, 3. Blockers 1, 0.
Gate B: Findings 14, 24, 12. Blockers 3, 4, 0.
```

**Gate B alone would leave the dominant cost unmeasured.** The loops this story cites as evidence
are Gate-A loops — nineteen measured Gate-A passes on one spec. P8 without Gate-A curves cannot
measure the thing the problem statement is about. (Pass 1 narrowed this to Gate B and pass 2 found
the narrowing wrong; settled here rather than oscillating.)

**The form is pinned, because an unpinned one is unparseable.** One entry per **valid** pass, in
pass order, comma-separated.
- A `reviewType: full` Gate-B pass contributes **one entry, the sum of its two branch files**.
- **Separate `spec` and `quality` calls, and a single-branch recovery resume, are branches of one
  logical pass** and likewise contribute one summed entry.
- **The curve counts logical passes; the hook counts calls.** These are deliberately different
  numbers and §5 already says the counter is not evidence. Where they differ the body says so:
  `(N calls, M passes)`.
- **Both branches of one logical pass must review the same artifact revision.** If the artifact
  changes between them they are not one pass, and the second branch starts a new one.
- **Incomplete passes are excluded** — §5 already says they do not count.
- **A valid pass with zero findings is written as `0`**, never omitted, so position equals pass
  number.

**What it reaches, and what it is worth.** The durable half **across cycles** — surviving a fresh
checkout, a cleared `.context/`, a different machine. **It does not restore history within a
running loop**: the commit does not exist until the loop closes, so it is no help at pass 4 of the
loop still running; there §5's degraded-sensitivity answer governs. And it is **author-written and
unchecked** — nothing compares the numbers against the validated pass files, so P8 reads a
self-reported curve. That is the same standing as every other commit-body record here, it is
better than the nothing that exists today, and the shipped text says it plainly rather than
letting P8 treat it as measurement.

**Squash carry.** §5's squash-merge rule names only evidence entries and human-exception records.
The **decline records (§2.1), the floor provenance line (§4.1) and these labelled curves** are
added, in both copies.

---

## 6. Old-conditions accounting

Required by the AGENTS.md Don't and by story criterion 6, **and performed here** — deferring the
thing that constitutes compliance while claiming compliance is the failure the Don't describes.

### 6.1 The floor-wording inventory is generated, not hand-derived

Hand-derived three times, three different counts. It is now **the output of a stated command**:

```
grep -nE "min 3 passes|below 3|3-pass|3 passes|where the 3 come from|3-passes-per-gate" \
  CLAUDE.md plugins/dev-workflow/commands/workflow-init.md
```

**Six sites per copy, symmetric** — `:72/:272`, `:79/:279`, `:236/:421`, `:300/:485`,
`:335/:519`, `:403/:582` — **twelve sites, all changing.**

**Two limitations, stated because a generated list reads as complete:**
1. **Digit sites only.** The site that matters most spells no digit — `:126/:322`, "*a
   Blocker/Major-free **pass 1** carrying a Minor keeps looping*", correct under floor 3 and
   **false under floor 1**, where pass 1 is *at* the floor and closes. Two more sites, found by
   hand. **Fourteen in total, all changing.**
2. **A floor, not coverage.** Another digit-free formulation would escape it exactly as that one
   did. The hand-check is not optional.

It correctly does **not** match `:249/:434` — "PR #23's Gate-B pass 3 returned all four findings
at `IMPORTANT`" — which cites a historical pass rather than stating a rule, and stays.

**Every site maps to a §6.2 row**, so no site is edited without an accounting: `:72` → row 1,
`:79` → row 2, `:126` → row 5, `:236` → row 3, `:300` → row 12, `:335` → row 13, `:403` → row 9.

### 6.2 Condition inventory

What each passage's existing prose requires, and the disposition of each requirement. Listed are
the conditions this change **touches or could drop**; the plan carries the replacement wording.

| # | Passage | What it currently requires | Disposition |
|---|---|---|---|
| 1 | "**Both gates are a LOOP with a HARD FLOOR**" | min 3 per run; Blocker/Major only; counted by the hook; hook cannot read findings nor tell the spec run from the plan run; a satisfied count is not a clean review; a TodoWrite per pass; fix Blocker/Major after each; final pass clean; keep going until clean or clearly stuck; only early exit below floor is a zero-finding pass; don't manufacture findings; Codex advisory, validate before applying; dismissed finding gets a one-line why | floor **value moved** to the profile predicate; **every other requirement kept verbatim**, including the counter-is-not-evidence caveats, which this design leans on harder than before |
| 2 | The early-exit sentence at `:79/:279` | the only exit below the floor is a zero-finding pass | **kept**, with "below 3" **changed** to "below the floor" |
| 3 | The incomplete-pass rule at `:236/:421` | don't act on a partial list; don't count it toward the floor; don't read "no Blocker/Major visible" as clean | **kept**, "3-pass floor" **changed** to "the floor" |
| 4 | "What a loop absorbs, and what stops it" | in-set findings absorbed, acted on by severity; ancestry decides *where*, never *what you do*; ancestry grants no Minor a repair round; assigned fix set fixed **before** the pass; unclear membership resolves **outside**; an out-of-set correction stops the loop even opening no new question; a new structural/contract question stops it; **novelty not size**; **when a finding is both, novelty wins**; stopping is **not an exit** — floor, filter and clean-final-pass all stand | all **kept**; the scope stop is **moved** into §2's ordering as one of three suspensions and gains the decline qualification |
| 5 | "Recognizing \"clearly stuck\"" | read the Blocker curve **across passes**, not one total; one low count is a snapshot not a plateau; **neither curve measures coverage**; three conditions **together**, a missing one means keep going; six-plus passes is where the field saw one and is **not a threshold**; an affirmative coverage judgement must be **stated**; a known unreviewed area **forbids the exit**; Blocker/Major **regenerating** across genuine repairs; **clean completion takes precedence**; below the floor nothing closes; zero-finding pass the only exception; a Blocker/Major-free pass 1 carrying a Minor keeps looping | all **kept**; the precedence sentence **moved** into §2's table and preserved verbatim there; the "pass 1" clause **changed** to "below the floor" per §6.1 |
| 6 | "Surfacing does not close the cycle" | surface **with the finding still open**; the resolve rule is **not waived**; **no pass credited clean**; loop resumes on the user's decision | all **kept**. The decline is an exception to **the third condition only where the user has declined that finding** — it does not waive the resolve rule generally, and an accepted Blocker/Major still blocks clean until resolved (§2.1) |
| 7 | "From pass 4 onward every pass report carries three lines" | duty **activates at pass 4** and binds every pass after; carrier is **your status report**, never the Codex reply, never the findings file; the three line contents; all five tell definitions; **any two mandatory, not discretionary**; report the tells and hand the decision to the user; the stuck reading is **not a precondition** | all **kept**; §5 **adds** the unavailable-history behaviour, which the passage currently leaves undefined |
| 8 | "The two rules above do not compete" | absorb decides *a finding's* scope; the stuck reading decides whether *the loop* converges; neither overrides the other; a small in-set correction is not itself evidence of a plateau | **kept**, **moved** to reference §2's ordering rather than restate the relationship |
| 9 | "Lenses are different questions, not more passes" (`:403/:582`) | lens sets add questions, not passes; the 3-pass floor, the Blocker/Major filter, the file-first protocol and the clean-final-pass rule are **unchanged** by lenses | **kept**; "3-pass floor" **changed** to "the floor", and the unchanged-by-lenses claim now reads against a derived floor |
| 10 | "The Gate-B triviality skip needs two independent conditions" | behaviourally trivial **and** `max(risk, security)` is 0; an eligible profile never makes a behaviour-changing diff skippable; skip reason in the commit body, not the profile log; a skip removes the review **never the evidence**; profiled story runs the battery and lands its evidence entry; unprofiled records reason and battery result and nothing more | all **kept**; checked against the floor predicate, which uses the same level-0 test for a different purpose — **deliberately not merged**, since one relaxes review count and the other removes review entirely |
| 11 | "A cycle citing several stories" | battery once per cycle; each cited profiled story satisfies its own mode with its own named evidence entry; an unprofiled cited story owes no entry; lens sets **unioned**; skip-eligible only if **every** cited story is | all **kept**; the floor **added** as a new dimension under the same unanimity shape |
| 12 | "Gate A — Spec, then plan (TWO runs, each its own 3-pass loop)" (`:300/:485`) | two separate runs, each its own loop; run on the spec before `writing-plans` and the plan before executing; one broad prompt re-run each pass; the brainstorming directive opens it; coverage floor not a cage; every finding with severity and confidence; `NO FINDINGS` when clean; mechanical settle before each read pass | all **kept**; "3-pass loop" **changed** to reference the derived floor, and each of the two runs derives it independently |
| 13 | "Gate B — Code" (`:335/:519`) | tests green before commit; skip only trivial changes; check against AGENTS.md; re-review after every fix; a fix changes the diff and the hook invalidates the prior pass, **which is where the 3 come from**; the standing falsification lens; same coverage rule as Gate A | all **kept**; the "where the 3 come from" clause **changed** to derive from the floor — the *reasoning* (re-review after every fix) is what generates the number, and it survives a variable floor unchanged |
| 14 | "**Severity:** Blocker … Major … Minor · Nit" | Blocker = wrong/unsafe/breaks invariant; Major = design flaw → rework; both must resolve; Minor and Nit collect, never iterate | **kept**, and **narrowed**: the reachability test is added as the classifier, so a finding that would once have been Major on subject alone can now be Minor. That narrowing is deliberate and is the change; it is recorded here as a **changed** condition, not a kept one |
| 15 | "Scope, and it is narrow" | the form supplies no permission; never the answer to a below-floor pass, an unclean final pass, a STOP, a Gate-A/B obligation or a profile-derived evidence requirement; authorizes nothing any mandatory rule requires; mandatory is not limited to this file; not for things never owed | all **kept without exception**; §2.1 **adds** the decline as a distinct record type on the same transport and states the distinction, precisely so this passage is not weakened |
| 16 | "Recording a human exception" | the three-line form; which commit carries it; decisions made after a commit closed; an empty commit is a legitimate destination; several records accumulate; the record is an **unverified assertion** | all **kept**; the decline record **reuses the transport** and adopts the same unverified-assertion honesty |
| 17 | "On squash-merge, copy every evidence entry…" | every evidence entry and human-exception record in the range copied into the squash body; nothing performs or checks the carry; a disagreement between copies is a copying error to fix, not to choose between | **kept**; three record types **added** |

---

## 7. Prerequisite, rollout, and what this change falsifies

**The template lacks the sentence §3's kinship points at.** "a wrong sentence costs a confused
reader, not broken behaviour" is in `CLAUDE.md` and **absent from the template**. **The template
gets it**, so the kinship claim has a referent in both copies — a deliberate one-seam reduction of
the 192-line divergence, because the new rule depends on it.

**User-facing statements this change falsifies**, from the standing lens "which existing
statements does this diff falsify?" — a change makes sentences wrong in files it never touches:

| Site | What it says | Why it is false after |
|---|---|---|
| `README.md:130` | "`codex-gate.floor` — a positive integer; moves the 3-passes-per-gate floor" | the §5 floor is derived and is not 3; the knob moves the **hook's reminder threshold**, which is all it ever moved |
| `docs/getting-started.md:34` | "three passes minimum, final pass clean" | not at level 0 |
| `:40` | "the same 3-pass" loop for the plan | not at level 0 |
| `:53` | Gate B "three passes, final clean" | not at level 0 |
| `:84` | "Gate A's floor is unchanged at every level" | **directly contradicted** — a sentence specifically about profile levels |
| `:86` | "moves the 3-pass floor" | same as README |
| `docs/coding-workflow.md:79-80` | the axes "never subtract any: **Gate A's floor** and the baseline questions are the same at every level" | **directly contradicted**, and missed until Gate-A pass 3 — the same claim as `:84` in a second file |

**The rewording is honest rather than cosmetic.** README and getting-started describe the knob as
what it mechanically is — the hook's reminder threshold — and name the **sanctioned lever** for
wanting fewer obliged passes: the profile, or `codex-gate.off` for the reminders. Nothing is
deprecated; the file and its behaviour are preserved. What is removed is a promise the mechanism
never kept.

**Gate-B classification of the doc edits — corrected.** An earlier revision called these paths
"Gate-B N/A". That is wrong when they ride with the prompt changes: §5's exemption requires
**every** staged path to be explanatory documentation, and a **mixed commit forfeits it**. So
either the doc edits land in their own docs-only commit (N/A applies) or they ride with the
prompt change (full Gate B applies to the whole commit). **The plan chooses and states which**;
what is not available is calling them exempt inside a mixed commit.

**What the template edit does and does not reach.** It changes what `/workflow-init` **writes into
new or re-initialized projects**. It does **not** update the `CLAUDE.md` already in a downstream
project — those accumulate local content and invariant 9 forbids silent overwriting. Downstream
repos adopt by re-running `/workflow-init` and taking the diff it offers.

**Packaging.** The change edits `plugins/dev-workflow/commands/workflow-init.md`, so invariant 12
applies: a `plugin.json` **version bump** and a `CHANGELOG.md` entry are in the implementation
surface. CI enforces the bump on pull requests.

---

## 8. Evidence plan

Mode `battery+check+verification` (no `+abuse-path`; security is `none`).

- **Battery** — the full `AGENTS.md` § Commands chain, green.
- **A check that fails without the change.** No automated test is possible for prose, so this
  takes §5's other permitted route — a **named verification**, owing the same counterfactual. The
  subject is §6.1's inventory, differential by construction: **posed as a question about behaviour
  under floor 1, the pre-change text answers wrongly at identified sites** — `:79` states the early
  exit as "below 3" where the floor may be 1, and `:126` says a Blocker/Major-free pass 1 carrying
  a Minor keeps looping where floor 1 requires it to close — **while the post-change text answers
  correctly.** That is the observation that would exist if the claim were false.
  **The wiring must be able to produce the failure.** A verification consulting only the
  post-change text cannot fail and would report success because of how it was wired. Both
  revisions get read, and the entry records which sentences were read at which revision.
- **A named verification of the risk path.** The risk path is now narrow and specific: **the §5
  floor is derived from a cited-story set, and nothing mechanical checks the derivation.** The
  verification takes this branch's own closing commits and confirms that **each provenance line's
  stated floor equals the floor the cited stories' profiles actually derive**, recomputed from
  those headers — the observation that would exist if the claim were false being a provenance line
  whose number the profiles do not license. It also confirms that **no floor file was written**,
  which under this design must hold on every path, including where none existed before.
  *Two failure modes this deliberately avoids:* an absence check alone would pass vacuously if the
  design never wrote a file (which it now never does), and a floor-1 demonstration is impossible on
  this branch, whose cited story is risk `high` — story criterion 9 forbids manufacturing a level-0
  fixture for it.
- **A verification that a user's knob survives untouched.** An existing `codex-gate.floor` set
  before a cycle starts is byte-identical after it closes, and the cycle's provenance line
  discloses both values. This exercises the settled user-knob rule, which no other check reaches.
- **Parity verification across every changed rule**, per story criterion 7, covering **§6.1's
  fourteen sites, §6.2's seventeen rows, and every rule §§2–5 newly insert.** The copies already
  differ on 192 lines, so parity cannot be asserted from a whole-section diff; the verification
  walks each named item and records every difference as deliberate-and-stated or as a defect.
  `scripts/check-invariants.sh` covers one severity spelling and is not coverage — invariant 11's
  stated condition.

**Instrument discipline, from this story's own evidence.** Two defects in the `fic2` decision
matrix were properties of the technique: **a state's inputs must include every input the rule
reads**, and **a counterfactual must distinguish ABSENT from CONTRADICTORY**. Both survived a full
clean pass before being caught.

**Known open question, not resolved here.** How much instrument a one-paragraph prose rule is
worth is carried by the evidence doc as a question, not a commitment.

---

## 9. Out of scope

Hook code (anything under `plugins/dev-workflow/hooks/`); gate-call observability (upstream,
`mcp-codex-dev`); the pass-counter anomaly, undiagnosed; the CodeRabbit plan-metadata
contradiction; the fixture-per-predicate question; any remedy to the supersession convention;
deprecating or repurposing the user-facing floor knob; teaching the hook about profiles; and
general reconciliation of the two copies' 192-line divergence beyond the one seam §7 names.

---

## 10. Risks and activation

- **When these rules bind.** From the commit that ships them, and **a loop already in flight
  finishes under the rules it started with** — re-deriving a floor mid-loop from a rule that did
  not exist when passes were banked would invalidate a count nobody could reconstruct. **Where a
  loop's starting rules cannot be established, treat it as new and re-derive**, which costs passes
  and never skips them. An earlier revision proposed git timestamps plus file mtime as a start
  marker; that does not survive checkout, copy or clock skew, so no marker is claimed and the
  fallback carries the case. This also disposes of this design's own Gate A, which runs under the
  old rules.
- **Downstream adoption has no shipping commit.** The template travels into other repositories
  whose history does not contain this change, so "from the commit that ships them" is a statement
  about *this* repo. Downstream, the rules bind from the `/workflow-init` run that writes them, and
  the same treat-as-new fallback applies.
- **The gate-off surface, honestly enumerated.** Deleting the marker mechanism removed the
  camouflage path and every crash-recovery path. What remains: **writing a provenance line the
  cited set does not license; omitting a higher-risk cited story from the set; minting or editing a
  story profile to level 0; presenting an incomplete cited-story set.** All four are *statement*
  attacks now rather than *file* attacks — they live in the commit body, where a reader who checks
  the branch's actual work can see them, and where §8's risk-path verification recomputes the
  derivation. None of this is a guard, and the profile-minting path is bounded only by the
  human-confirmation rule §5 already imposes on profile changes.
- **A user-set floor is not the gate-off lever, and the text keeps them distinct.** It moves what
  the hook says. The lever is a *stated* floor the cited profiles do not license.
- **The reachability test needs judgement** where §5 is trying to remove it; the
  named-reader-and-changed-decision phrasing removes arbitrariness, not judgement, and §3 says so.
- **Q6's answer fails toward continuing the loop.** Stated in §5 with the disclosure that makes it
  acceptable.
- **The curve is self-reported.** §5.1 says so; P8 inherits that limit and must not present a
  self-reported curve as measurement.
- **The expected demotion is a prediction.** §3 says so; P8 measures it. If it demotes far less
  than hoped, the rule is still correct and the economics claim was what was wrong.
