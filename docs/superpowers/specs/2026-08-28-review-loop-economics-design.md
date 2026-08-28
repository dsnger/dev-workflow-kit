# Review-loop economics: pass floor, severity semantics, and the §5 loop-rule consolidation — Design

**Date:** 2026-08-28 · **Revision:** 2, after Gate-A pass 1 (27 findings; 5 Blocker, 19 Major)
**Story:** `docs/superpowers/stories/2026-08-28-review-loop-economics-pass-floor-story.md`
**Profile (read from that header, not copied):** risk `high` · security `none` ·
validation `battery+check+verification`, no `+abuse-path`.

Prompt-only. No file under `plugins/dev-workflow/hooks/` changes.

**Two surfaces, both edited in every change below:** `CLAUDE.md` §5 (lines 65–589) and its
mirror inside `/workflow-init`'s inline `CLAUDE.md` template
(`plugins/dev-workflow/commands/workflow-init.md`, fenced at 192–778; §5 is 257–777). The two
already differ on 192 lines across 20 hunks; this design touches only the rules it changes,
per story criterion 7, and states each deliberate variance where it creates one.

---

## 1. The finding this design is built on

**The loop has four exits and four standing duties**, each stated in its own bolded paragraph,
each qualifying the ones before it — and nowhere does §5 say which wins when two apply at once.

*Scope of that claim:* four exits **of the loop**. §5 carries other mandatory stops that are not
loop exits — a target file surviving deletion, an exhausted recovery budget, an unresolvable
profile, a blocking evidence or setup gap. Those halt the *procedure* rather than resolving the
*cycle*, they do not compete with clean completion, and this design does not reorder them.

The missing ordering is why the `fic2` cycle could not ship two small clauses without qualifying
three rules nobody proposed changing: two clauses met a lattice with no stated ordering, and the
lattice pushed back. The revert was correct.

So "consolidated, done once instead of clause-by-clause" does not mean *answer six questions in
one sitting*. It means **state the ordering once**, after which most of the answers are readings
of it rather than new rules.

### 1.1 Only one exit closes

Both facts are already in §5, in two separate places, and neither draws the conclusion:

> "Stopping this way is **not an exit from the gate**: the floor, the Blocker/Major filter and
> the clean-final-pass rule all stand, and the loop resumes on the revised artifact once the
> question is answered."

> "You surface *with the finding still open* — the resolve rule is not waived, no pass is
> credited as clean, and the loop resumes on whatever the user decides."

**Clean completion closes. The scope stop, the clearly-stuck exit and the two-tell stop
suspend** — they surface to the human and the loop resumes.

Consequence: **suspension × suspension is not a conflict.** Two suspensions at once means the
pass report carries both reasons. Three pairs, no ordering, one sentence.

### 1.2 Three of the four duties are not participants

- **The floor** is a quantity gating closure — "**Below the floor nothing closes**". Not
  orderable.
- **Blocker/Major must resolve** is definitional: a clean pass is Blocker/Major-free by
  construction.
- **A surfaced finding stays open** is the *mechanism* that makes the other three exits
  suspensions rather than closes.
- **No pass carrying a surfaced finding counts as clean** is the only genuine participant. It
  couples an open finding to closure, and every remaining question lives there.

---

## 2. The precedence structure (part 3)

Shipped as one short ordering, stated once per copy, with the individual rules referencing it
rather than restating it.

| Conflict | Resolution |
|---|---|
| clean completion × clearly-stuck | **Clean wins.** §5 already says so; preserved verbatim rather than re-derived. Recorded as settled and probably unreachable — a clean pass has no regenerating Blocker/Major, so the exit's third condition fails. Kept because dropping a sentence §5 already spends is the dropped-condition failure story criterion 6 exists to prevent. |
| clean completion × two-tell stop | **Clean wins.** Daniel's recorded decision, encoded not reopened. |
| clean completion × scope stop | **Clean wins only when every surfaced finding still open has been explicitly declined.** Otherwise the scope stop's finding keeps the pass unclean and outranks closure automatically. |

**Why the third is the only one that needed deciding.** A scope stop is triggered by a *specific
finding*. While the duty stands unqualified, that finding is open, so the triggering pass cannot
be clean, so the scope stop wins automatically — no cell required. The cell exists only because
the duty may now be qualified.

**The asymmetry that explains the whole history:** the two-tell stop is triggered by *statistics
about findings* — the five tells — not by a finding. Nothing is left open, the duty does not
bite, and clean can win. The scope stop's trigger **is** a finding. The reverted clause tried to
unbite that by qualifying three universal rules at once. The lattice was not being awkward; it
was correct.

### 2.1 The qualification, and how a decision on a finding is recorded

**The duty "no pass carrying a surfaced finding counts as clean" is qualified for, and only
for, a finding the user has explicitly declined.**

Per story criterion 5, this qualification appears **at each of the three universal rules** in
both copies — the Blocker/Major-resolve duty, the surfaced-finding-stays-open rule, and the
no-clean-pass-carrying-it rule — not only at the new clause. Placing it only at the new clause
is what made the earlier attempt unshippable.

**Both branches, stated symmetrically in one sentence.** §5 already says the loop "resumes the
moment the user says whether the set now includes it" — resumption *is* the hold ending, and it
ends whichever way the answer went. So:

- **Declined** → the finding is released as recorded-declined and stops blocking closure for the
  remainder of the cycle. It does not re-stop later passes.
- **Accepted** → the finding enters the assigned set, where its **severity governs exactly as
  Mechanics already says**: an accepted Blocker or Major must resolve; an accepted Minor or Nit
  is collected and never iterated. In-set Minors have never blocked a clean pass at or above the
  floor, so there is no deadlock — the apparent one assumes the surfaced-finding hold outlives
  the user's answer, and the resume sentence says it does not.
- **Undecided** → the hold stands. Nothing closes unanswered.

**Where the decision is recorded — the commit body, on rails §5 already ships.** The
human-exception machinery already solves exactly this transport problem: "an ungated change
records it in that commit; a Gate-A cycle in the spec or plan commit; a Gate-B cycle in the WIP
commit, restated by the closing amend", folded in mid-cycle by amend, carried into the squash
body, with an empty commit as a last-resort destination. **The decline reuses that transport and
is a different record type**, with its own label:

```
Declined finding: <identifier> · <handle> · <date>
Reason: <one line>
```

**The distinction from the human-exception form is stated explicitly in the shipped text, and it
is the substance of the Blocker-4 repair.** They are not the same record and must not read as
one:

- The **human-exception form authorizes nothing** — §5 says so in its own words, and says it is
  never the answer to a below-floor pass, an unclean final pass, or a `STOP and surface`, and
  that neither a human's assent nor the record lets an agent close or continue a cycle.
- The **decline record has §5-defined effect**: it releases one specific finding from the
  surfaced-finding hold. That effect comes from the loop's own scope rule — which already routes
  set membership to the user and already resumes on the answer — not from human assent
  overriding a mandatory rule. Every other mandatory rule stands: the floor, the Blocker/Major
  filter, the clean-final-pass requirement.

Without that paragraph a reader meets two instructions that give opposite actions for the same
declined scope finding.

**"Explicitly declined" is defined tightly, because the safety of the whole qualification rests
on it.** A decline is a **recorded user decision on that specific finding**, attributable and
unambiguous. It is **never** silence, never a general remark about scope, and never the agent
inferring a decline from context. The shipped text carries all three negatives; a loose reading
converts a human gate into an agent's judgement, which is the failure the rule exists to prevent.

**Identity — how a declined finding is recognized again.** Findings carry no stable identifier,
so the decline record names the finding by **pass number, slot and line position at the time of
decline, plus its verbatim location field and a short quotation of its defect field**. A later
finding is the same finding when its location and defect match; **when that is unclear it is a
new finding and the hold applies**, which costs a question and never a silent release. A finding
that is split, merged or materially reworded is new by that test. This mirrors §5's existing
treatment of unclear set membership, which resolves toward *outside* for the same reason.

**The dispositions companion stays what §5 says it is** — the advisory working copy, deletable
and rebuildable. The commit body is the record. No new artifact class, no `.gitignore` change.

**What this makes shippable:** the reverted clause, in decline-keyed form.

---

## 3. Severity semantics (part 2)

**The decision procedure is the rule. The subject list is illustration.**

> Name the gate, skill, rule, escalation procedure or scaffolded template that reads this text,
> and the decision it takes differently if the text is wrong. If you cannot name an in-system
> reader and a changed decision, the finding is **Minor** — collect, never iterate.

Findings about narration, about prose describing a mechanism, and about a test instrument's
internals are the **cases this usually catches**, and they are shipped as examples of the test,
not as a second rule beside it. Stating them as a categorical demotion *and* stating the test
would give two procedures that can disagree on the same finding; the test governs.

**A human reader never satisfies the test.** That cost class is already priced as non-gating by
§5's prose exemption — "a wrong sentence costs a confused reader, not broken behaviour". Without
this clause the test admits everything, since a future maintainer reads every file.

**The instrument carve-out runs in both directions.** An instrument finding keeps its severity
when it shows the instrument **changes what the gate concludes about product behaviour** — a
false green, and equally a false red, a check that blocks a valid change, or instrument logic
that would drive an unnecessary product rewrite. A false green is the most common case, not the
only one; naming it alone would demote a check that fails for wiring reasons and costs a
correct change.

**Why not a list of demotable artifact kinds.** The field record already falsifies that form. Of
three `fic2` pass-5 findings on one parked story's acceptance criterion, two were correctly
parked and **one was correctly acted on** — "the pass-4 activation boundary — because a future
rewrite could otherwise move the duty to pass 1 while checking off every other listed
condition." Same artifact, same pass, same cluster, opposite correct answers. An enumeration
would also travel into scaffolded repos whose artifact kinds we have never seen, which is
invariant 10's stack-neutrality problem in a new place.

**Kinship, stated in the shipped text.** This is the **finding-level analog of the path-level
prose exemption** — one principle at two granularities: text that *describes* the product versus
text that *is* the product. Naming the kinship makes each rule the other's consistency check and
gives Gate A something to check the predicate against.

**The boundary case, qualified rather than blanket.** Rationale prose inside a rule file — §5's
"Recorded rationale" paragraphs, the why-sentences under AGENTS.md invariants — is **Minor when
no rule's application depends on it**. It is **not** categorically Minor:
`docs/prompt-standards.md:49-51` requires that "Rules carry their why", on the stated ground that
"models follow motivated rules better, and reviewers can judge whether the rule still applies" —
and invariant 11 makes that checklist binding. So rationale that a reader must consult to decide
whether or how a rule applies **is** read by an in-system reader and passes the test. What is
Minor is rationale that only explains, historically or motivationally, a rule whose application
is fully determined without it. Named explicitly because "it's in `CLAUDE.md`, agents read
`CLAUDE.md`" is the first stretch a reviewer will try, and the blanket form of this exclusion
would have contradicted a checklist item this project is required to pass.

**Coverage-first is unchanged and stated alongside:** the reviewer reports every finding with
severity and confidence; the filter is ours, never Codex's.

**Expected effect, stated with its limit.** The intent is that distributions like PR #23's — 16
findings in a never-committed scratch harness, 10 in narration, 1 in a plan — demote
substantially. **How much is not predictable from the recorded counts**, because `7bbdb14`'s own
body describes harness defects that could make checks pass for wiring reasons, and those are
exactly what the two-directional carve-out keeps. `fic2`'s pass-2 meta cluster demotes only
partially: ledger rows keep their severity because rung escalation reads the recurrence count,
and story criteria keep theirs because the assigned-fix-set rule reads them. **This design
demotes less than the story's problem statement might suggest, and the amount is a prediction
rather than a measurement** — which is why the story routes the measurement to P8 instead of
asserting an outcome here.

---

## 4. The pass floor (part 1)

**One predicate.** `max(risk, security) == 0` → floor **1**. Everything else → **3**, unprofiled
cycles included.

Two levels, not three: `high` gets no extra mandatory passes, taking its added rigor from lens
sets and evidence mode. Raising the high floor would worsen the cost this story exists to reduce.

**A cycle citing several stories: unanimity.** Floor 1 **if and only if every cited story is
profiled and every one is at level 0**. Any other set — mixed levels, any unprofiled member, any
higher profile — yields 3. This is §5's own aggregation precedent for the analogous relaxation
("the cycle is skip-eligible only if **every** cited story is") applied to a new dimension, and
it is the only reading consistent with invariant 2's firing direction: the lowest-cited-floor
reading would under-review a cycle that also touches a high-risk story.

**One value, both gates, stated in both copies.** `codex-gate.sh:119` sets a single `floor`,
consumed at `:946` for Gate B and `:966` for Gate A. A reader who does not know this will write
a rule for one gate and silently move the other.

**Why there is no `docs-only` arm.** A diff-derived reading cannot serve Gate A at all — Gate A
runs on a spec, before any diff exists. A story-declared reading is already subsumed: intake
defines `trivial` as "no behavioural effect in the artifact's own execution context", which a
documentation change has none of. And a path-derived arm would be **wrong in this repo
specifically**: `docs/hardening-log.md` is a `docs/**.md` path that drives rung escalation, so
"docs" does not imply "changes nothing." That is §3's reachability test deciding a §4 question,
which is the argument for shipping the two parts together.

### 4.1 The knob's lifecycle

Without this, a floor of 1 written by one trivial cycle persists into the next high or
unprofiled cycle and silently costs two required passes. That is the gate-off lever firing *by
accident*, which is worse than by intent because nobody chose it, and it runs against invariant
2's firing direction.

**Absence of the file is the safe state** — the hook defaults to 3 when it is missing
(`codex-gate.sh:119`), and it rejects `0` and non-numeric values (`:124-127`), which bounds
typos and not intent.

- **Write** `.context/codex-gate.floor` at **cycle start**, derived from the complete cited-story
  set by the unanimity rule above.
- **Re-derive and re-assert** it whenever the cited set or any cited profile changes mid-cycle
  (§4.2), and **verify the stored value** rather than assuming the write took.
- **Remove** it as part of the **closing amend step**, so the next cycle starts from the default.

A floor that must be re-asserted each cycle cannot silently persist into the next one, and
removal-on-close introduces no new state.

**Exposure, so the value is not invisible until closure.** Every pass report states the **parsed
axes, the derived floor, and the knob value actually read back**. Without this the only account
of the floor is the closing line, written by the same agent that chose it, after every pass has
already been skipped or run.

**A stated limitation, not a guarded one.** `.context/codex-gate.floor` is one checkout-global
mutable value. Two cycles running concurrently in one checkout with different profiles would
share it, and nothing serializes them. Cycles are sequential by construction here, so this is a
**stated limitation** in the same shape as §5's existing note that concurrent calls on one slot
race — not a mechanism, and the shipped text says so rather than implying safety.

**Provenance.** A cycle records `floor N per <story path>` in its closing commit body — for
every cited story, so a multi-story cycle's derivation is reconstructible — making the value
auditable in history rather than only in per-clone state.

### 4.2 A profile that moves mid-cycle

Composed from three rules §5 already has; no new rule.

- The floor derives from the **current** profile at each pass — §5 already requires the header
  to be read fresh at each pass, never remembered or copied.
- **Passes already run keep counting**, per the existing rule.
- **Closing requires meeting the floor as currently derived.**

**The consequence that must be stated, or the arithmetic reads wrong:** under a **raise**, at
least one further pass is required *regardless of the floor arithmetic*, because §5 already
requires the final clean pass to run under the current profile. A previously-final clean pass
stops qualifying the moment the profile moves — so even a raise that leaves the floor unchanged
(`standard` → `high`, both 3) still costs a pass.

**On lowering, recorded so nobody later reads the floor as having opened this.** A lower drops
the floor *and* the lens sets *and* the evidence mode, so a `high` cycle lowered to `trivial`
can close on one pass. That is the pre-existing profile-change path — human-confirmed in both
directions and logged. The variable floor rides that path; it does not create it.

---

## 5. Q6 — the pass-4 report when prior-pass history is unavailable

**Answer: report what is computable, name what is not and why, and disclose the reduced
sensitivity.** Not a new stop condition, and not a mandatory resume note.

The reasoning is arithmetic. Of the five tells, **three need history** — finding count rising,
Blocker count failing to fall, a require↔withdraw pair — and **two are computable from the
current pass alone**: findings clustering on the instrument, and findings clustering on prose.
So with no prior record the two-tell threshold **remains reachable** on the cluster pair. The
duty does not become inoperative; it loses sensitivity.

**History is unavailable in more shapes than total loss**, and the rule covers each:

| Shape | Treatment |
|---|---|
| absent — fresh checkout, cleared `.context/`, another machine, cycle resumed elsewhere | the tell is uncomputable; report it as such |
| **partial** — some passes present, others missing | compute the historical tells over the passes present and **say which pass numbers are missing**; a trend over an unstated subset reads as a trend over the cycle |
| **malformed or unreadable** — a file failing the pass-acceptance checks | treated as absent for that pass, **never** as a zero-finding pass; a count read from a file that failed validation is not evidence |
| **stale** — a file at the slot from an earlier cycle | treated as absent, and its presence reported, because a foreign curve is worse than no curve |

**The disclosure is not optional, and names the cause.** The report says which tells could not be
computed, **which shape above applies**, and which pass numbers are affected — so the human sees
a degraded reading rather than a clean one.

**Why the alternatives are rejected**, recorded per story criterion 5: making the resume note
mandatory changes an artifact §5 explicitly calls advisory ("Nothing depends on it existing");
treating unavailable history as its own stop condition would halt every cycle resumed on a fresh
checkout; restarting the pass-4 clock at the first *visible* pass silently lowers coverage
without saying so.

**Stated risk, because this answer has a direction.** Reporting rather than stopping fails
*toward continuing* the loop, which is the direction AGENTS.md invariant 2 questions for the
hook. The mandatory disclosure is what makes the answer acceptable; without it the design would
take a different one.

### 5.1 The curve in the closing body — what it does and does not reach

The closing commit of a **Gate-B cycle** carries the per-pass finding and Blocker counts, in one
pinned greppable form following the `3cdd075` precedent:

```
Findings 14, 24, 12, 3, 6, 6, 2. Blockers 3, 4, 0, 0, 0, 0, 0.
```

**The form is pinned, because an unpinned one is unparseable.** One entry per **valid** pass, in
pass order, comma-separated. A `reviewType: full` pass contributes **one entry, the sum of its
two branch files**, since the pass is the unit the floor counts. **Incomplete passes are
excluded** — they are not reviews, and §5 already says they do not count. A **valid pass with
zero findings is written as `0`**, never omitted, so position always equals pass number.

**What it reaches, corrected.** This is the durable half **across cycles** — it survives a fresh
checkout, a cleared `.context/` and a different machine, which is what P8 and any future
resumption need. **It does not restore history within a running cycle**: the closing commit does
not exist until the cycle closes, so it is no help at pass 4 of the cycle still running. There
the §5 degraded-sensitivity answer governs. A cycle that wants mid-cycle durability may fold the
running curve into the `WIP:` body by amend — **permitted, not required.**

**Without the curve requirement**, the economics measurement deferred to the P8 story is
answerable only for cycles whose author happened to write it down — `3cdd075` and `baa75c1` did,
`7bbdb14` recorded the pass total and no distribution — because the findings files behind those
numbers live under gitignored `.context/`. P8 would report on a self-selected subset with
nothing marking that it did.

**Squash carry.** §5's existing squash-merge rule names only evidence entries and human-exception
records. The **decline records (§2.1), the floor provenance line (§4.1) and this curve** are
added to that list, in both copies. A record that does not survive the squash is unreachable from
`main`'s history, which is the whole reason that rule exists.

---

## 6. Old-conditions accounting

Required by the AGENTS.md Don't and by story criterion 6. **It covers every passage this change
rewrites, not only the floor wording** — an accounting scoped to one part, inside a section
citing that Don't, is the failure the Don't describes.

**Method:** for each passage below, list what the existing prose required, then mark each
requirement **kept**, **moved**, or **deliberately dropped**. The plan carries the marked list
per passage and the exact replacement wording; the spec fixes the enumeration, so no passage is
rewritten without an accounting existing for it.

**Every passage rewritten, by its bold lead-in — each verified present exactly once in both
copies:**

| Passage | Rewritten by |
|---|---|
| "What a loop absorbs, and what stops it" | part 3 — the scope stop becomes an exit in a stated ordering |
| "Recognizing \"clearly stuck\"" | part 3 — becomes a suspension; clean-completion precedence moves into the ordering |
| "Surfacing does not close the cycle" | part 3 — this is the mechanism sentence §1.2 names |
| "From pass 4 onward every pass report carries three lines" | part 3 (two-tell stop as suspension) and §5 (Q6 computability and disclosure) |
| "The two rules above do not compete" | part 3 — superseded by the ordering, kept or retired explicitly |
| "**Both gates are a LOOP with a HARD FLOOR**" | part 1 — the floor statement itself |
| "The Gate-B triviality skip needs two independent conditions" | part 1 — adjacent profile-derived relaxation; checked for consistency with the floor predicate |
| "A cycle citing several stories" | part 1 — gains the floor dimension under unanimity |
| "**Severity:** Blocker (wrong/unsafe/breaks invariant)…" | part 2 — the severity definition |
| "Scope, and it is narrow" | part 3 — must distinguish the human-exception form from the decline record |
| "Recording a human exception" | part 3 — the decline record reuses this transport and must not be confused with it |
| "On squash-merge, copy every evidence entry…" | §5.1 — three new record types added to the carry |

**Plus the floor-wording sites, which are mechanical.** Making the floor variable falsifies prose
that assumes it is 3. **Twelve sites, ten changing**, identical in both copies: five paired rows
(ten sites, of which row 5's pair stays) plus the paired sentence that follows.

| # | `CLAUDE.md` | template | Text | Disposition |
|---|---|---|---|---|
| 1 | `:72` | `:272` | "min 3 passes per run" | **changes** — the floor statement itself |
| 2 | `:77` | `:277` | "if pass 3 still finds Blocker/Major, keep going until clean" | **changes** — at floor 1 the relevant pass is not pass 3 |
| 3 | `:236` | `:421` | "don't count it toward the 3-pass floor" | **changes** → "the floor" |
| 4 | `:403` | `:582` | "The 3-pass floor, the Blocker/Major filter…" | **changes** → "the floor" |
| 5 | `:249` | `:434` | "PR #23's Gate-B pass 3 returned all four findings at `IMPORTANT`" | **stays 3** — cites an actual historical pass, not a rule |

**Plus the one that no search for "3" finds**, in both copies:

> "**Below the floor nothing closes**, and a zero-finding pass remains the only exception,
> exactly as above; a Blocker/Major-free pass 1 carrying a Minor keeps looping."

Correct under floor 3. **False under floor 1**, where pass 1 is *at* the floor and therefore
closes. It becomes "a Blocker/Major-free pass **below the floor** carrying a Minor keeps
looping." This is the site worth the most attention in the whole change: a rule that silently
inverts in exactly the configuration part 1 introduces, invisible to any grep for the digit
because it says "pass 1."

---

## 7. Prerequisite and rollout

**The template lacks the sentence §3's kinship points at.** The rationale sentence — "a wrong
sentence costs a confused reader, not broken behaviour" — exists in `CLAUDE.md` and is **absent
from the `/workflow-init` template**. **Resolution: the template gets it**, so the kinship claim
has a referent in both copies. A deliberate reduction of the existing 192-line divergence at
exactly one seam, made because the new rule depends on it — not a general reconciliation, which
stays out of scope.

**What the template edit does and does not reach.** Editing the inline template changes what
`/workflow-init` **writes into new or re-initialized projects**. It does **not** update the
`CLAUDE.md` already sitting in a downstream project that ran `/workflow-init` earlier — those
are ordinary project files that accumulate local content, and invariant 9 forbids overwriting
them silently. So downstream repos adopt these rules by re-running `/workflow-init` and taking
the diff it offers, not by upgrading the plugin. The spec states this rather than leaving a
reader to assume a plugin bump propagates rules.

**Packaging.** The change edits `plugins/dev-workflow/commands/workflow-init.md`, so invariant 12
applies: the implementation surface includes a `plugins/dev-workflow/.claude-plugin/plugin.json`
**version bump** and a `CHANGELOG.md` entry. CI enforces the bump on pull requests
(`scripts/check-version-bump.sh`); the CHANGELOG entry is a convention this repo keeps for every
manifest version.

---

## 8. Evidence plan

Mode `battery+check+verification` (no `+abuse-path`; security is `none`).

- **Battery** — the full `AGENTS.md` § Commands chain, green.
- **A check that fails without the change.** No automated test is possible for prose, so this
  takes §5's other permitted route — a **named verification**, which owes the same
  counterfactual. The subject is the §6 site list, which is differential by construction:
  **posed as a question about behaviour under floor 1, the pre-change text answers two sites
  wrongly** — site 2 sends a reader to "pass 3" when the floor is 1, and the "pass 1 carrying a
  Minor keeps looping" sentence says a pass loops where floor 1 requires it to close — **while
  the post-change text answers both correctly.** That is the observation that would exist if the
  claim were false, and it is observable: a reading of two identified sentences at two revisions,
  not a derivation from the change itself.
  **The wiring must be able to produce the failure.** A verification consulting only the
  post-change text cannot fail and would report success because of how it was wired. Both
  revisions get read, and the entry says which sentences were read at which revision.
- **A named verification of the risk path.** The risk path is the gate-off lever: a floor of 1
  in effect without a profile licensing it. The verification exercises the §4.1 lifecycle —
  a floor written by a level-0 cycle must be **absent** at the start of the next cycle, and the
  observation that would exist if the claim were false is a surviving `1` after a close.
- **Parity verification across every changed rule**, per story criterion 7. The two copies
  already differ on 192 lines, so parity cannot be asserted from a whole-section diff. The
  verification walks **each passage named in §6's first table** and compares its post-change text
  across the two copies, recording each difference as deliberate-and-stated or as a defect. The
  narrow severity-spelling check in `scripts/check-invariants.sh` covers one item and is not
  coverage; nothing mechanical checks the rest, which is invariant 11's stated condition.

**Instrument discipline, learned from this story's own evidence.** Two defects in the `fic2`
cycle's decision matrix were properties of the technique, not of that instance, and both apply
here: **a state's inputs must include every input the rule reads** (a matrix omitting an input
cannot distinguish the states that input separates, and still looks complete), and **a
counterfactual must distinguish ABSENT from CONTRADICTORY** (claiming a prior state contradicted
a rule it never contained reports a failure mode that state could not produce). Both survived a
full clean pass before being caught.

**Known open question, not resolved here.** How much instrument a one-paragraph prose rule is
worth is carried by the evidence doc as a question, not a commitment. This design does not answer
it and does not pretend the fixture-per-predicate demand is settled.

---

## 9. Out of scope

Named so no part of the design absorbs them: hook code (any change under
`plugins/dev-workflow/hooks/`); gate-call observability (upstream, `mcp-codex-dev`); the
pass-counter anomaly, undiagnosed and needing hook-state inspection; the CodeRabbit
plan-metadata contradiction; the fixture-per-predicate question; any remedy to the supersession
convention; and general reconciliation of the two copies' 192-line divergence beyond the one
seam §7 names.

---

## 10. Risks and activation

- **When these rules bind.** They take effect from the commit that ships them. **A cycle already
  in flight finishes under the rules it started with** — the floor it derived, the severity
  definition it applied, the exits it knew — because re-deriving a floor mid-cycle from a rule
  that did not exist when passes were banked would invalidate a count nobody could reconstruct.
  This is stated in the shipped text, not left to inference. It also disposes of this design's
  own case: its Gate A runs under the old rules, and nothing here is retroactive.
- **The disclosed gate-off lever is real and only partly mitigated.** §4.1's lifecycle removes
  the *accidental* persistence path; the *deliberate* one remains — an agent-written value in
  per-clone gitignored state, unverified against the profile. §4.1's exposure requirement and
  §4's provenance line make it visible in the pass report and in history; neither is a guard. If
  that is unacceptable, the answer is hook code, which is out of scope by decision — and
  re-opening it is a stop-and-ask, not a silent expansion.
- **The reachability test needs judgement** at the moment §5 is trying to remove judgement. The
  named-reader-and-changed-decision phrasing is what makes it decidable; if Gate A finds it
  admits or excludes a case wrongly, that is a finding about this design, not about the settled
  contract.
- **Q6's answer fails toward continuing the loop.** Stated in §5 with the disclosure that makes
  it acceptable.
- **The expected demotion is a prediction.** §3 says so; P8 measures it. If it demotes far less
  than hoped, the rule is still correct and the economics claim was the thing that was wrong.
