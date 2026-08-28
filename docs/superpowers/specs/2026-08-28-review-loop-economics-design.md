# Review-loop economics: pass floor, severity semantics, and the §5 loop-rule consolidation — Design

**Date:** 2026-08-28 · **Revision:** 3, after Gate-A passes 1 (27 findings) and 2 (30)
**Story:** `docs/superpowers/stories/2026-08-28-review-loop-economics-pass-floor-story.md`
**Profile (read from that header, not copied):** risk `high` · security `none` ·
validation `battery+check+verification`, no `+abuse-path`.

Prompt-only. No file under `plugins/dev-workflow/hooks/` changes.

**Surfaces edited.** `CLAUDE.md` §5 (65–589) and its mirror inside `/workflow-init`'s inline
`CLAUDE.md` template (`plugins/dev-workflow/commands/workflow-init.md`, fenced 192–778; §5 is
257–777). Plus the user-facing statements this change falsifies (§7). The two §5 copies already
differ on 192 lines across 20 hunks; this design touches only the rules it changes, per story
criterion 7, and states each deliberate variance where it creates one.

---

## 1. The finding this design is built on

**The loop has four exits and four standing duties**, each in its own bolded paragraph, each
qualifying the ones before it — and nowhere does §5 say which wins when two apply at once.

*Scope of that claim:* four exits **of the loop**. §5 carries other mandatory stops that are not
loop exits — a target file surviving deletion, an exhausted recovery budget, an unresolvable
profile, a blocking evidence or setup gap. Those halt the *procedure* rather than resolving the
*cycle*, they do not compete with clean completion, and this design does not reorder them.

The missing ordering is why the `fic2` cycle could not ship two small clauses without qualifying
three rules nobody proposed changing. So "consolidated, done once instead of clause-by-clause"
means **state the ordering once**, after which most answers are readings of it rather than new
rules.

### 1.1 Only one exit closes

Both facts are already in §5, in two places, and neither draws the conclusion:

> "Stopping this way is **not an exit from the gate**: the floor, the Blocker/Major filter and
> the clean-final-pass rule all stand, and the loop resumes on the revised artifact once the
> question is answered."

> "You surface *with the finding still open* — the resolve rule is not waived, no pass is
> credited as clean, and the loop resumes on whatever the user decides."

**Clean completion closes. The scope stop, the clearly-stuck exit and the two-tell stop
suspend.** Consequence: **suspension × suspension is not a conflict** — two at once means the
report carries both reasons. Three pairs, no ordering, one sentence.

### 1.2 Three of the four duties are not participants

- **The floor** is a quantity gating closure — "**Below the floor nothing closes**".
- **Blocker/Major must resolve** is definitional: a clean pass is Blocker/Major-free.
- **A surfaced finding stays open** is the *mechanism* making the other exits suspensions.
- **No pass carrying a surfaced finding counts as clean** is the only participant. Every
  remaining question lives there.

---

## 2. The precedence structure (part 3)

| Conflict | Resolution |
|---|---|
| clean completion × clearly-stuck | **Clean wins.** §5 already says so; preserved verbatim. Settled and probably unreachable — a clean pass has no regenerating Blocker/Major, so the exit's third condition fails. Kept because dropping a sentence §5 already spends is the dropped-condition failure criterion 6 exists to prevent. |
| clean completion × two-tell stop | **Clean wins.** Daniel's recorded decision, encoded not reopened. |
| clean completion × scope stop | **The scope stop outranks closure while any surfaced finding remains unresolved and undeclined.** A finding the user has explicitly declined is resolved *for this purpose* and no longer holds the cycle. |

**The third cell's wording is deliberate.** An earlier draft read "clean wins only when every
surfaced finding still open has been explicitly declined", which is self-contradictory: §2.1
defines a decline as *releasing* the finding, so a declined finding is not still open. The rule
is stated once, from the hold's side — what keeps a cycle open — so the decline's effect is
described in exactly one place.

**Why the third is the only one that needed deciding.** A scope stop is triggered by a *specific
finding*; while the duty stands unqualified that finding is open, so the triggering pass cannot
be clean and the scope stop wins automatically. The cell exists only because the duty may now be
qualified.

**The asymmetry that explains the history:** the two-tell stop is triggered by *statistics about
findings*, not by a finding. Nothing is left open, the duty does not bite, clean can win. The
scope stop's trigger **is** a finding. The reverted clause tried to unbite that by qualifying
three universal rules at once. The lattice was correct.

### 2.1 The qualification, and how a decision on a finding is recorded

**The duty is qualified for, and only for, a finding the user has explicitly declined.** Per
story criterion 5, the qualification appears **at each of the three universal rules** in both
copies — not only at the new clause. Placing it only at the new clause is what made the earlier
attempt unshippable.

**All three branches, stated symmetrically.** §5 already says the loop "resumes the moment the
user says whether the set now includes it" — resumption *is* the hold ending, whichever way the
answer went.

- **Declined** → released as recorded-declined; stops holding the cycle for the remainder of it,
  and does not re-stop later passes.
- **Accepted** → enters the assigned set, where **severity governs exactly as Mechanics already
  says**: accepted Blocker or Major must resolve; accepted Minor or Nit is collected, never
  iterated. In-set Minors have never blocked a clean pass at or above the floor, so there is no
  deadlock — the apparent one assumed the hold outlives the user's answer, and the resume
  sentence says it does not.
- **Undecided** → the hold stands. Nothing closes unanswered.

**Where the decision is recorded — the commit body, on rails §5 already ships.** The
human-exception machinery already solves this transport: "an ungated change records it in that
commit; a Gate-A cycle in the spec or plan commit; a Gate-B cycle in the WIP commit, restated by
the closing amend", folded in mid-cycle by amend, carried into the squash body, empty commit as
last resort. **The decline reuses that transport as a different record type:**

```
Declined finding: <pass>/<slot>/<line> · <location field, verbatim> · <handle> · <date>
Defect: <the finding's defect field, verbatim>
Reason: <one line>
```

**The distinction from the human-exception form is stated explicitly — this is the substance of
the Blocker-4 repair.** They are not the same record:

- The **human-exception form authorizes nothing** — §5 says so in its own words, and says it is
  never the answer to a below-floor pass, an unclean final pass, or a `STOP and surface`, and
  that neither a human's assent nor the record lets an agent close or continue a cycle.
- The **decline record has §5-defined effect**: it releases one specific finding from the hold.
  That effect comes from the loop's own scope rule — which already routes set membership to the
  user and already resumes on the answer — not from human assent overriding a mandatory rule.
  Every other mandatory rule stands: the floor, the Blocker/Major filter, the clean-final-pass
  requirement.

**What the record can and cannot establish, said plainly.** Like the human-exception record it
sits beside, this is an **unverified assertion**: the commit body is author-written, and nothing
checks that the handle belongs to whoever decided or that a human was asked. A reader learns
that *the commit claims* the user declined this finding. It is the same standing §5 already
gives the human-exception form, and the shipped text says so rather than implying the record is
evidence. What makes the mechanism safe is not verification but **narrowness**: it releases one
named finding and nothing else.

**"Explicitly declined" is defined tightly.** A **recorded user decision on that specific
finding**, attributable and unambiguous. **Never** silence, never a general remark about scope,
never the agent inferring a decline from context. All three negatives ship.

**Identity — how a declined finding is recognized again.** Findings carry no stable identifier,
so the record names pass, slot and line, plus the **verbatim location and defect fields**.
A later finding is the same finding when **location and defect both match**. **Any change to
severity, consequence or suggested fix makes it a new finding**, because each can change what
the finding asks for even where the defect reads the same — a Minor re-raised as a Blocker is
not the thing that was declined. **Where sameness is unclear it is a new finding and the hold
applies**, which costs a question and never a silent release. This mirrors §5's existing
treatment of unclear set membership, which resolves toward *outside* for the same reason.

**The dispositions companion stays what §5 says it is** — the advisory working copy, deletable
and rebuildable. The commit body is the record.

---

## 3. Severity semantics (part 2)

**The decision procedure is the rule. The subject list is illustration.**

> Name the gate, skill, rule, escalation procedure or scaffolded template that reads this text,
> and the decision it takes differently if the text is wrong. If you cannot name an in-system
> reader and a changed decision, the finding is **Minor** — collect, never iterate.

Findings about narration, mechanism prose, and test-instrument internals are the cases this
usually catches, shipped as **worked examples of the test, not as a second rule beside it**.
Stating a categorical demotion *and* the test would give two procedures that can disagree on one
finding; the test governs.

**A human reader never satisfies the test.** That cost class is already priced as non-gating by
§5's prose exemption — "a wrong sentence costs a confused reader, not broken behaviour". Without
this the test admits everything.

**The instrument carve-out runs in both directions.** An instrument finding keeps its severity
when it shows the instrument **changes what the gate concludes about product behaviour** — a
false green, and equally a false red, a check that blocks a valid change, or instrument logic
that would drive an unnecessary product rewrite. Naming false green alone would demote a check
that fails for wiring reasons and costs a correct change.

**Why not a list of demotable artifact kinds.** The field record falsifies that form. Of three
`fic2` pass-5 findings on one parked story's acceptance criterion, two were correctly parked and
**one was correctly acted on** — "the pass-4 activation boundary — because a future rewrite could
otherwise move the duty to pass 1 while checking off every other listed condition." Same
artifact, same pass, opposite correct answers. An enumeration would also travel into scaffolded
repos whose artifact kinds we have never seen — invariant 10's stack-neutrality problem in a new
place.

**Kinship, stated in the shipped text.** The **finding-level analog of the path-level prose
exemption** — one principle at two granularities: text that *describes* the product versus text
that *is* the product. Naming it makes each rule the other's consistency check.

**The boundary case, qualified rather than blanket.** Rationale prose inside a rule file — §5's
"Recorded rationale" paragraphs, the why-sentences under AGENTS.md invariants — is **Minor when
no rule's application depends on it**, and **not** categorically Minor.
`docs/prompt-standards.md:49-51` requires that "Rules carry their why", because "models follow
motivated rules better, and reviewers can judge whether the rule still applies", and invariant 11
makes that checklist binding. Rationale a reader must consult to decide whether or how a rule
applies **is** read by an in-system reader and passes the test. What is Minor is rationale that
only explains, historically or motivationally, a rule whose application is fully determined
without it. Named explicitly because "it's in `CLAUDE.md`, agents read `CLAUDE.md`" is the first
stretch a reviewer will try — and because the blanket form would have contradicted a checklist
item this project must pass.

**Coverage-first unchanged:** the reviewer reports every finding with severity and confidence;
the filter is ours, never Codex's.

**Expected effect, with its limit.** The intent is that distributions like PR #23's — 16 in a
never-committed scratch harness, 10 in narration, 1 in a plan — demote substantially. **How much
is not predictable from the recorded counts**, because `7bbdb14`'s own body describes harness
defects that could make checks pass for wiring reasons, and those are exactly what the
two-directional carve-out keeps. `fic2`'s pass-2 meta cluster demotes only partially: ledger rows
keep severity because rung escalation reads the recurrence count, story criteria because the
assigned-fix-set rule reads them. **This demotes less than the problem statement might suggest,
and the amount is a prediction rather than a measurement** — which is why the story routes the
measurement to P8 instead of asserting an outcome.

---

## 4. The pass floor (part 1)

**One predicate.** `max(risk, security) == 0` → floor **1**. Everything else → **3**, unprofiled
included. Two levels, not three: `high` takes its added rigor from lens sets and evidence mode.

**Several cited stories: unanimity.** Floor 1 **if and only if every cited story is profiled and
every one is at level 0**. Any other set — mixed levels, any unprofiled member, any higher
profile — yields 3. This is §5's own aggregation precedent for the analogous relaxation ("the
cycle is skip-eligible only if **every** cited story is") applied to a new dimension, and the only
reading consistent with invariant 2's firing direction.

**One value, both gates.** `codex-gate.sh:119` sets a single `floor`, consumed at `:946` for
Gate B and `:966` for Gate A. Stated in both copies: a reader who does not know this will write a
rule for one gate and silently move the other.

**Why there is no `docs-only` arm.** A diff-derived reading cannot serve Gate A, which runs on a
spec before any diff exists. A story-declared reading is subsumed: intake defines `trivial` as
"no behavioural effect in the artifact's own execution context". And a path-derived arm would be
**wrong in this repo**: `docs/hardening-log.md` is a `docs/**.md` path that drives rung
escalation. That is §3's reachability test deciding a §4 question.

### 4.1 The knob, which is a user's before it is ours

**`.context/codex-gate.floor` is a shipped, documented user capability.** `README.md:130` lists
it under "Per-workspace knobs" — "a positive integer; moves the 3-passes-per-gate floor" — and
`docs/getting-started.md:85-86` says the same. An earlier draft had the agent writing and
deleting it unconditionally, which would silently overwrite and then destroy a deliberate user
setting. The design does not do that.

**Two states, distinguished by a marker.**

- **A floor file with no marker beside it is user-set.** It is **never overwritten and never
  removed**, and it **is** the effective floor — the hook reads it and this design does not
  contradict the hook. The cycle discloses the divergence rather than resolving it:
  `floor N per workspace knob; profile derivation M per <cited set>`.
  This is the shape §5 already uses for a human override of a derived value — the mode override,
  which may raise or lower and is logged with its reason. A workspace knob is that shape at
  workspace level.
- **The agent writes only when no user value exists**: the derived floor, plus a marker file
  beside it (`.context/codex-gate.floor.derived`) recording the cited-story set and the derived
  value. Both are removed at cycle close. A **marker-bearing file found at cycle start is stale
  agent state from a crashed or abandoned cycle** — re-derive and overwrite. The marker is agent
  bookkeeping under `.context/`, the same class as pass files and resume notes; **no hook reads
  it**, so this stays prompt-only.

Absence of both files is the safe state — the hook defaults to 3 (`codex-gate.sh:119`) and
rejects `0` and non-numeric values (`:124-127`), which bounds typos and not intent.

**Closure is not only a Gate-B amend.** One knob governs both gates, so cleanup attaches to
**each cycle type's own closing event**: the Gate-A spec loop ends at the spec commit, the
Gate-A plan loop at the plan commit, the Gate-B cycle at the closing amend. Attaching cleanup to
the Gate-B amend alone would leave a Gate-A-derived floor standing through everything that
follows.

**Failure has a terminal action, not a silent pass.** Write, then **read back and compare**. On a
failed write, a failed read-back, a mismatch between the value read and the value derived, or a
failed removal at close: **stop and name which of the four occurred**. "Could not set the floor"
alone sends a reader retrying the wrong thing, and continuing on an unverified floor is exactly
the missed-passes outcome invariant 2 calls the dangerous direction. A **final read-back at
close** confirms removal.

**Exposure, so the value is not invisible until closure.** Every pass report states the **parsed
axes, the derived floor, whether a user knob is in force, and the value actually read back**.
Without this the only account of the floor is a closing line written by the same agent that
chose it, after every pass has already been run or skipped.

**A stated limitation, not a guarded one.** `.context/codex-gate.floor` is one checkout-global
mutable value. Overlapping Gate-A and Gate-B cycles in one checkout, or cycles run by separate
sessions, would share it and nothing serializes them. §5's existing note that concurrent calls on
one slot race has the same shape. The shipped text states this rather than implying safety, and
does not claim cycles are sequential by construction — nothing enforces that.

**Provenance.** Every cycle records `floor N per <cited story path>` in its closing commit body,
one entry per cited story, plus the divergence form above where a user knob is in force. Every
cycle, not only a non-default one: an absent line must not be ambiguous between "default" and
"forgotten".

### 4.2 A profile that moves mid-cycle

Composed from three rules §5 already has; no new rule. The floor derives from the **current**
profile at each pass (§5 already requires the header read fresh); **passes already run keep
counting**; **closing requires meeting the floor as currently derived**.

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
| **malformed** | fails the pass-acceptance checks: terminator, count match, no non-finding lines | treat as absent for that pass, **never** as zero findings; a count from a file that failed validation is not evidence. Distinct from *unreadable* below because the remedy differs: a malformed file is a review that ran and wrote badly — the pass may be re-runnable from its `sessionId` |
| **unreadable** | the file exists but cannot be opened or decoded | treat as absent; report the OS-level cause, because permissions and a full disk need different fixes from a bad write |
| **stale** | the slot carries no cycle identity, or an identity other than this cycle's | treat as absent **and report its presence** — a foreign curve is worse than no curve |

**Stale needs an identity to detect, and slots do not carry one.** Pass slots are numbered, not
cycle-keyed, so a pass-2 file from a previous cycle is indistinguishable from this cycle's by
content alone. Two mitigations, both prompt-only: this design's **slot discriminator convention**
(a cycle uses a per-cycle infix, as this cycle's `rle` does, following the `fic2` and `pr15`
precedent), and **§5's existing delete-and-confirm-before-each-call rule**, which already
guarantees the file you are about to write is not a previous cycle's. Neither makes stale
detectable *after the fact*; the report says so rather than implying detection.

**The disclosure is not optional and names the cause.** The report says which tells could not be
computed, **which shape applies**, and which pass numbers are affected — so the human sees a
degraded reading rather than a clean one.

**Why the alternatives are rejected**, per story criterion 5: making the resume note mandatory
changes an artifact §5 explicitly calls advisory ("Nothing depends on it existing"); treating
unavailable history as its own stop would halt every cycle resumed on a fresh checkout;
restarting the pass-4 clock at the first *visible* pass silently lowers coverage.

**Stated risk.** Reporting rather than stopping fails *toward continuing* the loop, the direction
AGENTS.md invariant 2 questions for the hook. The mandatory disclosure is what makes it
acceptable.

### 5.1 The curve in the commit body — all three loops

**Each of the three loops records its own per-pass finding and Blocker counts in its own commit
body:** the **Gate-A spec loop** in the spec's commit, the **Gate-A plan loop** in the plan's
commit, the **Gate-B cycle** in the closing amend. Form pinned to the `3cdd075` precedent:

```
Findings 14, 24, 12, 3, 6, 6, 2. Blockers 3, 4, 0, 0, 0, 0, 0.
```

**Gate B alone would leave the dominant cost unmeasured.** The loops this story cites as evidence
are Gate-A loops — nineteen measured Gate-A passes on one spec. P8 without Gate-A curves cannot
measure the thing the problem statement is about. (An earlier revision narrowed this to Gate B on
a pass-1 finding, and pass 2 found the narrowing wrong; the scope is settled here rather than
oscillating.)

**The form is pinned, because an unpinned one is unparseable.** One entry per **valid** pass, in
pass order, comma-separated.
- A `reviewType: full` Gate-B pass contributes **one entry, the sum of its two branch files** —
  the pass is the unit the floor counts.
- **Separate `spec` and `quality` calls, and a single-branch recovery resume, are branches of one
  logical pass** and likewise contribute one summed entry. The hook counts calls; the curve counts
  passes, and the two are deliberately not the same number. Where they differ, the body says so:
  `(N calls, M passes)`.
- **Incomplete passes are excluded** — they are not reviews, and §5 already says they do not count.
- **A valid pass with zero findings is written as `0`**, never omitted, so position equals pass
  number.

**What it reaches.** The durable half **across cycles** — surviving a fresh checkout, a cleared
`.context/`, a different machine, which is what P8 and any future resumption need. **It does not
restore history within a running cycle**: the commit does not exist until the loop closes, so it
is no help at pass 4 of the loop still running. There §5's degraded-sensitivity answer governs. A
cycle wanting mid-cycle durability may fold the running curve into the `WIP:` body by amend —
**permitted, not required.**

**Squash carry.** §5's squash-merge rule names only evidence entries and human-exception records.
The **decline records (§2.1), the floor provenance line (§4.1) and these curves** are added to
that list, in both copies. A record that does not survive the squash is unreachable from `main`'s
history, which is why that rule exists.

---

## 6. Old-conditions accounting

Required by the AGENTS.md Don't and by story criterion 6. **It covers every passage this change
rewrites, and the accounting is performed here** — deferring the thing that constitutes
compliance while claiming compliance is the failure the Don't describes.

### 6.1 The floor-wording inventory is generated, not hand-derived

I hand-derived this table three times and got a different count each time. The inventory is now
**the output of a stated command**, so the count cannot drift from the enumeration. Run in the
repo root, against both copies:

```
grep -nE "min 3 passes|below 3|3-pass|3 passes|where the 3 come from|3-passes-per-gate" \
  CLAUDE.md plugins/dev-workflow/commands/workflow-init.md
```

It returns **six sites per copy, symmetric** — `:72/:272`, `:79/:279`, `:236/:421`, `:300/:485`,
`:335/:519`, `:403/:582` — **twelve sites, all changing.** Each states a rule that a variable
floor falsifies: the floor itself; the zero-finding early exit "below 3"; the incomplete-pass
rule; Gate A's "each its own 3-pass loop"; "where the 3 come from"; and the lens-set sentence.

**Two limitations, stated because a generated list reads as complete:**
1. **It finds digit sites only.** The site that matters most spells no digit — `:126/:322`,
   "*a Blocker/Major-free **pass 1** carrying a Minor keeps looping*", correct under floor 3 and
   **false under floor 1**, where pass 1 is *at* the floor and therefore closes. Two more sites,
   both changing, found by hand and listed alongside. **Fourteen sites in total, all changing.**
2. **It is a floor, not coverage.** Another digit-free formulation would escape it exactly as
   this one did. The hand-check is not optional.

It correctly does **not** match `:249/:434` — "PR #23's Gate-B pass 3 returned all four findings
at `IMPORTANT`" — which cites an actual historical pass rather than stating a rule, and stays.

### 6.2 Condition inventory for every rewritten passage

For each passage: what its existing prose requires, and the disposition of each requirement.
The plan carries the replacement wording; the accounting is here.

| Passage (bold lead-in, present once in both copies) | What it currently requires | Disposition |
|---|---|---|
| "**Both gates are a LOOP with a HARD FLOOR**" | min 3 per run; Blocker/Major only; counted by the hook; a TodoWrite per pass; final pass clean; the only early exit below floor is a zero-finding pass | floor value **moved** to the profile predicate; every other requirement **kept** verbatim |
| "What a loop absorbs, and what stops it" | in-set findings absorbed and acted on by severity; ancestry never decides action; assigned fix set fixed before the pass; unclear membership resolves outside; out-of-set correction stops the loop; a new structural/contract question stops it, novelty not size; stopping is not an exit from the gate | all **kept**; the scope stop is **moved** into §2's ordering as one of three suspensions, and gains the decline qualification |
| "Recognizing \"clearly stuck\"" | read the Blocker curve across passes; neither curve measures coverage; three conditions together; clean completion takes precedence; below the floor nothing closes; zero-finding pass the only exception | all **kept**; the precedence sentence is **moved** into §2's table and preserved verbatim there; the "pass 1" clause is **changed** to "below the floor" (§6.1 limitation 1) |
| "Surfacing does not close the cycle" | surface with the finding still open; resolve rule not waived; no pass credited clean; loop resumes on the user's decision | all **kept**; this is §1.2's mechanism sentence, and the decline is the single named exception to the third |
| "From pass 4 onward every pass report carries three lines" | carrier is the status report, never the Codex reply or findings file; three lines; five tells; any two mandatory | all **kept**; §5 **adds** the unavailable-history behaviour, which the passage currently leaves undefined |
| "The two rules above do not compete" | absorb decides finding scope, stuck-reading decides loop convergence; neither overrides the other | **kept**, and **moved** to reference §2's ordering rather than restating the relationship |
| "The Gate-B triviality skip needs two independent conditions" | behaviourally trivial **and** `max(risk, security)` is 0; an eligible profile never makes a behaviour-changing diff skippable; skip reason in the commit body; a skip removes the review never the evidence | all **kept**; checked for consistency with the floor predicate, which uses the same level-0 test for a different purpose — **deliberately not merged**, since one relaxes review count and the other removes review entirely |
| "A cycle citing several stories" | battery once; each profiled story satisfies its own mode; lens sets unioned; skip-eligible only if every cited story is | all **kept**; the floor **added** as a new dimension under the same unanimity shape |
| "**Severity:** Blocker … Major … Minor · Nit" | Blocker wrong/unsafe/breaks invariant; Major design flaw → rework; both must resolve; Minor and Nit collect, never iterate | all **kept**; the reachability test **added** as the classifier, with the subject list as worked examples |
| "Scope, and it is narrow" | the human-exception form supplies no permission; never the answer to a below-floor pass, unclean final pass or STOP; authorizes nothing any mandatory rule requires; not for things never owed | all **kept without exception**; §2.1 **adds** the decline as a distinct record type on the same transport and states the distinction, precisely so this passage is not weakened |
| "Recording a human exception" | the three-line form; which commit carries it; decisions after a commit closed; an empty commit is legitimate; the record is an unverified assertion | all **kept**; the decline record **reuses the transport** and adopts the same unverified-assertion honesty |
| "On squash-merge, copy every evidence entry…" | every evidence entry and human-exception record in the range copied into the squash body; nothing performs or checks the carry | **kept**; three record types **added** to the list |

---

## 7. Prerequisite, rollout, and what this change falsifies

**The template lacks the sentence §3's kinship points at.** "a wrong sentence costs a confused
reader, not broken behaviour" is in `CLAUDE.md` and **absent from the template**. **Resolution:
the template gets it**, so the kinship claim has a referent in both copies. A deliberate reduction
of the 192-line divergence at exactly one seam, because the new rule depends on it — not a general
reconciliation, which stays out of scope.

**User-facing statements this change falsifies, and which are therefore in the fix set.** The
standing Gate-B lens — "which existing statements does this diff falsify?" — applied to shipped
documentation, where a change makes sentences wrong in files it never touches:

| Site | What it says | Why it is false after |
|---|---|---|
| `README.md:130` | "`codex-gate.floor` — a positive integer; moves the 3-passes-per-gate floor" | the floor is no longer fixed at 3; the knob now also interacts with a derived value |
| `docs/getting-started.md:34` | "three passes minimum, final pass clean" | not at level 0 |
| `:40` | "the same 3-pass" loop for the plan | not at level 0 |
| `:53` | Gate B "three passes, final clean" | not at level 0 |
| `:84` | "Gate A's floor is unchanged at every level" | **directly contradicted** — this sentence is specifically about profile levels |
| `:86` | "moves the 3-pass floor" | same as README |

These are `docs/**.md` and `README.md`, so prose and Gate-B N/A, but they are **in the fix set**
and criterion-visible. `:84` is the one worth naming twice: a sentence that was true when written
and that this change makes false, in a file the change does not otherwise touch.

**What the template edit does and does not reach.** Editing the inline template changes what
`/workflow-init` **writes into new or re-initialized projects**. It does **not** update the
`CLAUDE.md` already sitting in a downstream project — those are ordinary project files that
accumulate local content, and invariant 9 forbids silent overwriting. Downstream repos adopt
these rules by re-running `/workflow-init` and taking the diff it offers, not by upgrading the
plugin. Stated rather than left to an assumption that a plugin bump propagates rules.

**Packaging.** The change edits `plugins/dev-workflow/commands/workflow-init.md`, so invariant 12
applies: the implementation surface includes a `plugins/dev-workflow/.claude-plugin/plugin.json`
**version bump** and a `CHANGELOG.md` entry. CI enforces the bump on pull requests
(`scripts/check-version-bump.sh`).

---

## 8. Evidence plan

Mode `battery+check+verification` (no `+abuse-path`; security is `none`).

- **Battery** — the full `AGENTS.md` § Commands chain, green.
- **A check that fails without the change.** No automated test is possible for prose, so this
  takes §5's other permitted route — a **named verification**, owing the same counterfactual. The
  subject is §6.1's inventory, which is differential by construction: **posed as a question about
  behaviour under floor 1, the pre-change text answers wrongly at identified sites** — `:79`
  states the early exit as "below 3" where the floor may be 1, and `:126` says a Blocker/Major-free
  pass 1 carrying a Minor keeps looping where floor 1 requires it to close — **while the
  post-change text answers correctly.** That is the observation that would exist if the claim were
  false, and it is observable: a reading of identified sentences at two revisions, not a
  derivation from the change itself.
  **The wiring must be able to produce the failure.** A verification consulting only the
  post-change text cannot fail and would report success because of how it was wired. Both
  revisions get read, and the entry records which sentences were read at which revision.
- **A named verification of the risk path.** The risk path is the **agent-written** gate-off
  lever. It exercises §4.1's lifecycle without requiring a floor-1 cycle on this branch — which
  story criterion 9 forbids, and which no cycle citing this risk-`high` story could produce
  anyway. The observation that would exist if the claim were false is **an agent-written floor
  file or marker surviving a cycle close**; the verification checks for both after this branch's
  own closes, where the derived floor is 3 and the lifecycle still runs.
- **Parity verification across every changed rule**, per story criterion 7, covering **§6.1's
  fourteen sites, §6.2's twelve passages, and every rule §§2–5 newly insert** — lifecycle,
  exposure, history shapes, curve format, provenance, activation. The two copies already differ on
  192 lines, so parity cannot be asserted from a whole-section diff; the verification walks each
  named item and records every difference as deliberate-and-stated or as a defect. The narrow
  severity-spelling check in `scripts/check-invariants.sh` covers one item and is not coverage;
  nothing mechanical checks the rest, which is invariant 11's stated condition.

**Instrument discipline, from this story's own evidence.** Two defects in the `fic2` decision
matrix were properties of the technique: **a state's inputs must include every input the rule
reads**, and **a counterfactual must distinguish ABSENT from CONTRADICTORY**. Both survived a full
clean pass before being caught.

**Known open question, not resolved here.** How much instrument a one-paragraph prose rule is
worth is carried by the evidence doc as a question, not a commitment.

---

## 9. Out of scope

Hook code (any change under `plugins/dev-workflow/hooks/`); gate-call observability (upstream,
`mcp-codex-dev`); the pass-counter anomaly, undiagnosed and needing hook-state inspection; the
CodeRabbit plan-metadata contradiction; the fixture-per-predicate question; any remedy to the
supersession convention; deprecating the user-facing floor knob (a documented capability, whose
removal is Daniel's decision and unnecessary given §4.1); a hook-read marker or separate
agent-floor file (needs hook code); and general reconciliation of the two copies' 192-line
divergence beyond the one seam §7 names.

---

## 10. Risks and activation

- **When these rules bind.** They take effect from the commit that ships them, and **a loop
  already in flight finishes under the rules it started with** — re-deriving a floor mid-loop
  from a rule that did not exist when passes were banked would invalidate a count nobody could
  reconstruct. **The start marker is the loop's own first pass artifact**: a loop whose pass-1
  slot predates the shipping commit started under the old rules. That is recoverable from git
  plus file mtime, and where neither is available the shipped text says to **treat the loop as
  new and re-derive**, which costs passes and never skips them. This also disposes of this
  design's own case: its Gate A runs under the old rules.
- **Abandonment and rollback.** Cleanup at close covers the successful path only. A loop
  abandoned, or halted by a blocking profile or setup stop, **leaves its marker file behind by
  design** — §4.1 treats a marker-bearing file at cycle start as stale agent state and
  re-derives, so the next cycle self-heals rather than inheriting. **Rollback to prompt text that
  predates this change** leaves a marker no rule mentions; it is inert (no hook reads it) and the
  floor file it accompanies reverts to being read exactly as the old rules read it.
- **The gate-off lever is narrower than before but not closed, and it has more than one shape.**
  §4.1's lifecycle removes the accidental-persistence path. What remains, and is disclosed:
  writing a derived floor the cited set does not license; **omitting a higher-risk cited story
  from the set**; **minting or editing a story profile to level 0**; and presenting an incomplete
  cited-story set. The first is bounded by §4.1's read-back; the rest are bounded only by the
  provenance line naming *which* stories were cited, which makes an omission visible to a reader
  who checks the branch's actual work. None of this is a guard.
- **A user-set floor of 1 is not the gate-off lever, and the text keeps them distinct.** It is a
  human decision on a documented knob, disclosed in the provenance line. The lever is an
  *agent-written* floor without a licensing profile. Conflating them would either make a shipped
  user capability read as an attack or make the real lever read as sanctioned.
- **The reachability test needs judgement** where §5 is trying to remove it. The
  named-reader-and-changed-decision phrasing is what makes it decidable.
- **Q6's answer fails toward continuing the loop.** Stated in §5 with the disclosure that makes it
  acceptable.
- **The expected demotion is a prediction.** §3 says so; P8 measures it. If it demotes far less
  than hoped, the rule is still correct and the economics claim was what was wrong.
