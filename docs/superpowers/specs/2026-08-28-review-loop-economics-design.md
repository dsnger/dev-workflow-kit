# Review-loop economics: pass floor, severity semantics, and the §5 loop-rule consolidation — Design

**Date:** 2026-08-28
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

§5 has **four ways a cycle can stop** and **four standing duties**, each stated in its own
bolded paragraph, each qualifying the ones before it — and nowhere does §5 say which wins when
two apply at once.

That is not a wording gap. It is why the `fic2` cycle could not ship two small clauses without
qualifying three rules nobody proposed changing: two clauses met an eight-way lattice with no
stated ordering, and the lattice pushed back. The revert was correct.

So "consolidated, done once instead of clause-by-clause" does not mean *answer six questions in
one sitting*. It means **state the ordering once**, after which most of the answers are
readings of it rather than new rules.

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
| clean completion × scope stop | **Clean wins only when every open surfaced finding has been explicitly declined.** Otherwise the scope stop's finding keeps the pass unclean and outranks closure automatically. |

**Why the third is the only one that needed deciding, and why it reads as it does.** A scope
stop is triggered by a *specific finding*. While the duty stands unqualified, that finding is
open, so the triggering pass cannot be clean, so the scope stop wins automatically — no cell
required. The cell exists only because the duty may now be qualified.

**The asymmetry that explains the whole history:** the two-tell stop is triggered by
*statistics about findings* — the five tells — not by a finding. Nothing is left open, the duty
does not bite, and clean can win. The scope stop's trigger **is** a finding. The reverted clause
tried to unbite that by qualifying three universal rules at once. The lattice was not being
awkward; it was correct.

### 2.1 The qualification

**The duty "no pass carrying a surfaced finding counts as clean" is qualified for, and only
for, a finding the user has explicitly declined.**

Per story criterion 5, this qualification appears **at each of the three universal rules** in
both copies — the Blocker/Major-resolve duty, the surfaced-finding-stays-open rule, and the
no-clean-pass-carrying-it rule — not only at the new clause. Placing it only at the new clause
is what made the earlier attempt unshippable.

**"Explicitly declined" is defined tightly, because the safety of the whole qualification rests
on it.** A decline is a **recorded user decision on that specific finding**, attributable and
unambiguous, durably written down — the `<slot>-dispositions.md` companion is the natural home.
It is **never** silence, never a general remark about scope, and never the agent inferring a
decline from context. The shipped text says all three negatives explicitly; a loose reading here
converts a human gate into an agent's judgement, which is the failure the whole rule exists to
prevent.

**Consequence for Q4, encoded rather than asked again:** a decline binds for the remainder of
the cycle. A declined finding does not re-stop later passes. An *undecided* out-of-set finding
still holds the cycle open — nothing closes unanswered.

**What this makes shippable:** the reverted clause, in decline-keyed form.

---

## 3. Severity semantics (part 2)

**The rule.** Blocker and Major claim product behaviour, an invariant, or a contract. A finding
whose subject is narration, prose about a mechanism, or a test instrument's internals is
**Minor** — collect, never iterate — **except** an instrument finding demonstrating a false
green on product behaviour, which keeps its severity.

**The decision procedure, keyed on consequence and not on artifact kind:**

> Name the gate, skill, rule, escalation procedure or scaffolded template that reads this text,
> and the decision it takes differently if the text is wrong. If you cannot name an in-system
> reader and a changed decision, it is Minor.

**A human reader never satisfies the test.** That cost class is already priced as non-gating by
§5's prose exemption — "a wrong sentence costs a confused reader, not broken behaviour". Without
this clause the test admits everything, since a future maintainer reads every file.

**Why not a list of demotable artifact kinds.** The field record already falsifies that form. Of
three `fic2` pass-5 findings on one parked story's acceptance criterion, two were correctly
parked and **one was correctly acted on** — "the pass-4 activation boundary — because a future
rewrite could otherwise move the duty to pass 1 while checking off every other listed
condition." Same artifact, same pass, same cluster, opposite correct answers. Artifact class
gets that wrong; consequence gets it right. An enumeration would also travel into scaffolded
repos whose artifact kinds we have never seen, which is invariant 10's stack-neutrality problem
in a new place.

**Kinship, stated in the shipped text.** This is the **finding-level analog of the path-level
prose exemption** — one principle at two granularities: text that *describes* the product versus
text that *is* the product. Naming the kinship makes each rule the other's consistency check and
gives Gate A something to check the predicate against. Two rules sharing an unstated principle
drift apart.

**The boundary case, shipped with its example.** Rationale prose inside a rule file — §5's
"Recorded rationale" paragraphs, the why-sentences under AGENTS.md invariants — states no rule,
so no decision flips if it is wrong. **Minor.** Named explicitly because "it's in `CLAUDE.md`,
agents read `CLAUDE.md`" is the first stretch a reviewer will try.

**Coverage-first is unchanged and stated alongside:** the reviewer reports every finding with
severity and confidence; the filter is ours, never Codex's.

**Expected effect, stated so Gate A reads it as designed rather than finding it as a gap.**
PR #23-class distributions — 16 findings in a scratch harness, 10 in narration — demote almost
entirely. `fic2`'s pass-2 meta cluster demotes only **partially**: ledger rows keep their
severity because rung escalation reads the recurrence count, and story criteria keep theirs
because the assigned-fix-set rule reads them. **This design demotes less than the story's
problem statement might suggest, and that is correct rather than a shortfall.**

---

## 4. The pass floor (part 1)

**One predicate.** `max(risk, security) == 0` → floor **1**. Everything else → **3**, unprofiled
cycles included.

Two levels, not three: `high` gets no extra mandatory passes, taking its added rigor from lens
sets and evidence mode. Raising the high floor would worsen the cost this story exists to reduce.

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

**Mechanism and its residual, disclosed in the shipped text.** The floor is carried by the
already-shipped `.context/codex-gate.floor` knob, written by the agent from the story's profile.
The text states plainly that the value is agent-written, that it lives in per-clone gitignored
state no reviewer sees in a diff, that nothing verifies it against the story profile, and that
a floor of 1 is therefore the cheapest available gate-off lever. **This is a disclosure, not a
guard** — no mechanism is claimed for it. The knob rejects `0` and non-numeric input
(`codex-gate.sh:124-127`), which bounds typos and not intent.

**Provenance.** A cycle running a floor other than the default records `floor N per <story
path>` in its closing commit body, so the value is auditable in history rather than only in
per-clone state.

### 4.1 A profile that moves mid-cycle

Composed from three rules §5 already has; no new rule.

- The floor derives from the **current** profile at each pass — §5 already requires the header
  to be read fresh at each pass, never remembered or copied.
- **Passes already run keep counting**, per the existing rule.
- **Closing requires meeting the floor as currently derived.**

A raise moves the target prospectively; a lower lets already-banked passes suffice sooner.

**The consequence that must be stated, or the arithmetic reads wrong:** under a **raise**, at
least one further pass is required *regardless of the floor arithmetic*, because §5 already
requires the final clean pass to run under the current profile. A previously-final clean pass
stops qualifying the moment the profile moves — so even a raise that leaves the floor unchanged
(`standard` → `high`, both 3) still costs a pass. Without this, "passes already run keep
counting" reads as "nothing further is needed."

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

**The disclosure is not optional, and names the cause.** The report says which tells could not
be computed **and why** — a fresh checkout, a cleared `.context/`, another machine, a cycle
resumed elsewhere — so the human sees a degraded reading rather than a clean one.

**Why the alternatives are rejected**, recorded per story criterion 5: making the resume note
mandatory changes an artifact §5 explicitly calls advisory ("Nothing depends on it existing");
treating unavailable history as its own stop condition would halt every cycle resumed on a
fresh checkout; restarting the pass-4 clock at the first *visible* pass silently lowers coverage
without saying so.

**Stated risk, because this answer has a direction.** Reporting rather than stopping fails
*toward continuing* the loop, which is the direction AGENTS.md invariant 2 questions for the
hook. The mandatory cause-naming disclosure is what makes the answer acceptable; without it the
design would take a different one.

### 5.1 Q6's durable half

Closing commit bodies carry the per-pass finding and Blocker counts, in one pinned greppable
form following the `3cdd075` precedent:

```
Findings 14, 24, 12, 3, 6, 6, 2. Blockers 3, 4, 0, 0, 0, 0, 0.
```

Two reasons, both load-bearing. **History that survives**: a curve in a commit body outlives a
fresh checkout, a cleared `.context/` and a different machine, which is exactly the availability
gap Q6 names. **A measurable subset**: the economics measurement deferred to the P8 story is
otherwise answerable only for cycles whose author happened to write the curve down — `3cdd075`
and `baa75c1` did, `7bbdb14` recorded the pass total and no distribution — because the findings
files behind those numbers live under gitignored `.context/`. Without this, P8 would report on a
self-selected subset with nothing marking that it did.

---

## 6. Old-conditions accounting

Required by the AGENTS.md Don't and by story criterion 6. Making the floor variable falsifies
prose that assumes it is 3. **Ten sites, eight changing**, identical in both copies.

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

The plan carries the exact replacement wording per site.

---

## 7. Prerequisite: the template lacks the sentence §3's kinship points at

§3 names the new severity rule as the finding-level analog of the path-level prose exemption.
The rationale sentence it points at — "a wrong sentence costs a confused reader, not broken
behaviour" — exists in `CLAUDE.md` and is **absent from the `/workflow-init` template**.

**Resolution: the template gets the rationale sentence**, so the kinship claim has a referent in
both copies. This is a deliberate reduction of the existing 192-line divergence at exactly one
seam, made because the new rule depends on it — not a general reconciliation, which stays out of
scope.

---

## 8. Evidence plan

Mode `battery+check+verification` (no `+abuse-path`; security is `none`).

- **Battery** — the full `AGENTS.md` § Commands chain, green.
- **A check that fails without the change.** No automated test is possible for prose, so this
  takes §5's other permitted route — a **named verification**, which owes the same
  counterfactual. The subject is the §6 site list, which is differential by construction:
  **posed as a question about behaviour under floor 1, the pre-change text answers two sites
  wrongly** — site 2 sends a reader to "pass 3" when the floor is 1, and the "pass 1 carrying a
  Minor keeps looping" sentence says a pass closes-or-loops opposite to what floor 1 requires —
  **while the post-change text answers both correctly.** That is the observation that would
  exist if the claim were false, and it is observable: it is a reading of two identified
  sentences at two revisions, not a derivation from the change itself.
  **The wiring must be able to produce the failure.** A verification that consults only the
  post-change text cannot fail and would report success because of how it was wired. Both
  revisions get read, and the entry says which sentences were read at which revision. The plan
  pins the exact procedure; the spec fixes only its shape and its counterfactual.
- **A named verification of the risk path.** The risk path is the gate-off lever: a floor of 1
  in effect without a profile licensing it. Named here, procedure in the plan.

**Instrument discipline, learned from this story's own evidence.** Two defects in the `fic2`
cycle's decision matrix were properties of the technique, not of that instance, and both apply
here: **a state's inputs must include every input the rule reads** (a matrix omitting an input
cannot distinguish the states that input separates, and still looks complete), and **a
counterfactual must distinguish ABSENT from CONTRADICTORY** (claiming a prior state contradicted
a rule it never contained reports a failure mode that state could not produce). Both survived a
full clean pass before being caught.

**Known open question, not resolved here.** How much instrument a one-paragraph prose rule is
worth is carried by the evidence doc as a question, not a commitment. This design does not
answer it and does not pretend the fixture-per-predicate demand is settled.

---

## 9. Out of scope

Named so no part of the design absorbs them: hook code (any change under
`plugins/dev-workflow/hooks/`); gate-call observability (upstream, `mcp-codex-dev`); the
pass-counter anomaly, undiagnosed and needing hook-state inspection; the CodeRabbit
plan-metadata contradiction; the fixture-per-predicate question; any remedy to the supersession
convention; and general reconciliation of the two copies' 192-line divergence beyond the one
seam §7 names.

---

## 10. Risks

- **The disclosed gate-off lever is real and unguarded.** A floor of 1 in per-clone gitignored
  state, agent-written, unverified against the profile. The design discloses it and claims no
  mechanism. If that is unacceptable, the answer is hook code, which is out of scope by
  decision — and re-opening it is a stop-and-ask, not a silent expansion.
- **The reachability test needs judgement** at the moment §5 is trying to remove judgement. The
  named-reader-and-changed-decision phrasing is what makes it decidable; if Gate A finds it
  admits or excludes a case wrongly, that is a finding about this design, not about the settled
  contract.
- **Q6's answer fails toward continuing the loop.** Stated in §5 with the disclosure that makes
  it acceptable.
- **This spec edits the rules that govern its own review.** Its Gate A runs under the old rules;
  the new ones bind afterwards. Nothing here is retroactive, and the design does not assume
  otherwise.
