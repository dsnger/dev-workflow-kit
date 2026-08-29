# Review-loop economics: pass floor, severity semantics, and the §5 loop-rule consolidation — Design

**Date:** 2026-08-28 · **Revision:** 11, after Gate-A passes 1-9
(27, 30, 54, 40, 33, 34, 32, 33, 28 findings)
**Story:** `docs/superpowers/stories/2026-08-28-review-loop-economics-pass-floor-story.md`
**Profile (read from that header, not copied):** risk `high` · security `none` ·
validation `battery+check+verification`, no `+abuse-path`.

**What this document is, after revision 10.** Contract level only: settled decisions with their
reasons, rules stated as required properties, named interfaces, and scope. **Exact replacement
wordings, concrete formats, command lines and step-by-step procedures live in the plan**, where
they get their own Gate A against this spec once it is stable. Nothing escapes review by moving;
what changes is when it is reviewed. Revision 10 is a level-of-detail change and moves no
decision — §11 lists what went where.

Prompt-only. **No file under `plugins/dev-workflow/hooks/` changes, and no hook *state* file is
written.** One file the hook *reads* is edited: `codex-gate.sh:94` greps `CLAUDE.md` for the §5
heading to build every reminder's citation, so **the §5 heading must keep matching
`^#{1,6}[[:space:]]+([0-9]+\.)?[[:space:]]*Cross-Model Review`** or the citation degrades to a
generic fallback.

**Surfaces.** `CLAUDE.md` §5 (65–589); its mirror in `/workflow-init`'s inline template
(`plugins/dev-workflow/commands/workflow-init.md`, fenced 192–778, §5 at 257–777); the
user-facing statements §7 lists; and this story's own acceptance criteria. The two §5 copies
already differ on 192 lines; only the rules this change touches are brought to parity.

---

## 1. The finding this rests on

**The loop has four exits and four standing duties, and §5 never says which wins when two apply.**
That is why the `fic2` cycle could not ship two clauses without qualifying three rules nobody
proposed changing. Consolidation therefore means **stating the ordering once**, after which most
answers are readings of it.

*Scope:* four exits **of the loop**. §5's other mandatory stops — a target surviving deletion, an
exhausted recovery budget, an unresolvable profile, a blocking evidence gap — halt the *procedure*
rather than resolving the *cycle*, and are not reordered.

**Only one exit closes**, which §5 already says twice without drawing the conclusion:

> "Stopping this way is **not an exit from the gate**: the floor, the Blocker/Major filter and the
> clean-final-pass rule all stand, and the loop resumes…"

> "You surface *with the finding still open* — the resolve rule is not waived, no pass is credited
> as clean, and the loop resumes on whatever the user decides."

Clean completion **closes**. The scope stop, the clearly-stuck exit and the two-tell stop
**suspend**. So suspension × suspension is not a conflict: two at once means the report carries
both reasons.

**Three of the four duties are not participants in ordering.** The floor is a quantity gating
closure. **Blocker/Major-must-resolve applies to in-set findings and is a precondition on closure
not discharged by a quiet pass** — a pass raising no *new* Blocker/Major is not evidence an
earlier one was resolved, so the closing report inventories each in-set Blocker/Major and its
resolution from the per-pass findings files. **Where those files are unavailable, that is a
disclosure, not a discharge: a cycle that cannot establish resolution does not close.** "Cannot
tell" and "was resolved" are different states and only one permits closing. "A surfaced finding
stays open" is the mechanism making the other exits suspensions. **"No pass carrying a surfaced
finding counts as clean" is the only participant.**

---

## 2. The precedence structure (part 3)

| Conflict | Resolution |
|---|---|
| clean × clearly-stuck | **Clean wins.** §5 already says so; preserved verbatim. Settled and probably unreachable — a clean pass has no regenerating Blocker/Major — and kept because dropping a sentence §5 spends is the failure criterion 6 exists to prevent. |
| clean × two-tell stop | **Clean wins.** Daniel's recorded decision, encoded not reopened. |
| clean × scope stop | **The scope stop outranks closure while any surfaced finding is still awaiting the user's answer. Any answer ends the hold**, either direction. What follows is §2.1's business, not this cell's. |

**Why only the third needed deciding.** A scope stop is triggered by a *specific finding*; while
the duty stands unqualified that finding is open, so the pass cannot be clean and the scope stop
wins automatically. **The asymmetry:** the two-tell stop is triggered by *statistics about
findings*, so nothing is left open and clean can win. The scope stop's trigger **is** a finding.

### 2.1 The hold, the decline, and the record

**The rule, stated in full rather than as a decline-only carve-out:**

> **A surfaced finding holds closure while it awaits the user's answer. Any answer ends the hold,
> in either direction. After the answer the ordinary rules govern and the hold plays no part.**

- **Declined** → out-of-set; neither duty attaches; does not re-stop later passes in that cycle.
- **Accepted** → in-set; **severity governs as Mechanics already says.** An accepted Blocker or
  Major must resolve and until it does **the cycle does not close** — a statement about closure,
  never about re-scoring a pass. **A pass's cleanliness is a fact about what that pass found and
  is never rewritten**; closure needs a *subsequent* clean pass at or above the floor.
  An accepted Minor or Nit is collected, never iterated, and blocks nothing.
- **Undecided** → the hold stands.

**What can be declined.** Only a finding surfaced by a **scope stop** — out-of-set, or opening a
new structural or contract question. **An in-set Blocker or Major cannot be declined**: it was
never awaiting a membership answer, and treating it as declinable would make this a general
waiver, which "Scope, and it is narrow" forbids.

**Stated at every rule it modifies, in both copies, and at no rule it does not.** It modifies
"a surfaced finding stays open" (stops *awaiting a decision*, not thereby resolved), "no pass
carrying a surfaced finding counts as clean" (gates **closure** while unanswered), and "the loop
resumes on whatever the user decides" (resumption *is* the hold ending). **The
Blocker/Major-resolve duty is not modified and carries no qualification** — §1 scopes it to in-set
findings, so a decline never reaches it, and a qualification there would imply an exception that
does not exist.

**"Explicitly declined"** is a **recorded user decision on that specific finding**, attributable
and unambiguous. Never silence, never a general remark about scope, never the agent inferring one.

**Required properties of the record** — the plan fixes the format:
- Lives in the **commit body**, reusing the human-exception transport (Gate-A loops: the spec or
  plan commit, written at close; Gate B: the `WIP:` body by amend, restated by the closing amend)
  — **as a distinct record type carrying its own label**, never merged into or mistaken for a
  human-exception record. The two differ in force and the shipped text says so: the
  human-exception form **authorizes nothing**, while a decline has §5-defined effect on one named
  finding. A reader who cannot tell them apart has the wrong rule for both.
  During a loop the decision lives in the advisory working record and *becomes* the record at
  commit; the decline's effect never waits for the commit.
- Carries enough of the finding to **re-identify it**: location, defect, severity, consequence and
  suggested fix. **The record stores exactly what the sameness test reads** — a test reading
  fields the record lacks is the wiring failure §8 warns about. Sameness requires all five to
  match; **any difference, including severity, makes it a new finding and the hold applies**, as
  does any genuine uncertainty.
- Names **who decided and when**, and survives the squash carry.
- **Bound to one cycle** by the cycle nonce below. A decline has no effect in any later cycle.
- **Reads as an unverified assertion**, exactly like the human-exception record beside it: nothing
  checks that the handle belongs to whoever decided. **Narrowness bounds what a false record can do — one fully-identified finding, one cycle — and
  that is not the same as making it safe.** A fabricated decline still releases a real hold on a
  real finding, and nothing detects it. The shipped text says exactly that, because "narrow" read
  as "safe" is the overclaim this repo logs most often.

**The cycle nonce.** Generated once at cycle start, immutable, **collision-resistant**, and
matching `[a-z0-9]{4,16}` so it is safe as a slot infix and as a path component. **It appears in
every record the cycle writes**, not merely somewhere in history — a record without it cannot be
attributed to a cycle, which is the whole function. **Deriving it from a gate plus a commit does not work**: sibling
worktrees and restarted loops share loop names and base commits, and a `WIP:` parent identifies
the base rather than the artifact reviewed. **The reviewed commit or tree id is tracked
separately**, because "which cycle is this" and "did both branches see the same thing" are
different questions. **Recovery has two sources, because a Gate-A loop's commit does not exist while it runs:** during
the loop the nonce lives in the advisory working record beside the findings files, and it becomes
history at the loop's commit. A cycle that can recover it from **either** keeps its identity; a
cycle that can recover it from **neither** has no identity and starts a new cycle — which costs
passes rather than silently inheriting a decline.

**The mid-cycle amend must preserve what it amends.** Required properties: the resulting message
**begins `WIP:`** — the hook recognizes a WIP commit from the message the command supplies, and an
amend that loses the prefix reads as the cycle *closing*, resetting counters and discarding
accumulated passes — and **contains every record the previous message contained**, plus the new
one. The **non-`WIP:` amend is reserved for final closure alone.**

---

## 3. Severity semantics (part 2)

**One procedure decides severity, and the subject list is illustration, not a second rule.**

> Name **what in the system consumes this text** — whatever *acts* on it — and the decision that
> act takes differently if the text is wrong. **Both are required.** If you cannot name **both**
> — the act, and the decision it takes differently — the finding is **Minor or below**; collect,
> never iterate.

- **The reader must consume the text in the system's *operation*, not in reviewing it. The review
  pass raising the finding is not an in-system reader of the text it reviews.** Without this the
  test demotes nothing, since any review finding could name the review itself. **Gates remain
  legitimate readers** of rule text they will later apply.
- **A human reader never satisfies the test** — §5's prose exemption already prices that cost as
  non-gating: "a wrong sentence costs a confused reader, not broken behaviour".
- **The list of reader kinds is illustrative, not closed.** This ships into projects whose readers
  we have never seen (invariant 10).
- **The test sets a ceiling, not a floor**, and **never chooses between Blocker and Major** —
  Mechanics still decides that.
- **The instrument carve-out is symmetric**: an instrument finding keeps its severity whenever it
  shows the instrument changes what a gate concludes about product behaviour — a false green, and
  equally a false red or a check blocking a valid change.
- **Rationale prose is Minor only when no rule's application depends on it**, not categorically.
  `docs/prompt-standards.md:49-51` requires that "Rules carry their why", because "models follow
  motivated rules better", and invariant 11 makes that binding — so rationale a reader must
  consult to apply a rule passes the test.
- **This removes arbitrariness, not judgement**, and the shipped text says so.
- **Coverage-first is unchanged**: the reviewer reports every finding with severity and
  confidence; the filter is ours.

**Kinship, stated in the shipped text:** this is the **finding-level analog of the path-level
prose exemption** — one principle at two granularities, text that *describes* the product versus
text that *is* the product. Each becomes the other's consistency check.

**Why not artifact kinds.** The field record falsifies that form: of three `fic2` pass-5 findings
on one story's acceptance criterion, two were correctly parked and **one correctly acted on**.
Same artifact, same pass, opposite correct answers.

**Expected effect, with its limit.** PR #23-class distributions should demote substantially. **How
much is not predictable** — `7bbdb14`'s own body describes harness defects that could make checks
pass for wiring reasons, which the symmetric carve-out keeps. `fic2`'s meta cluster demotes only
partially: ledger rows and story criteria keep their severity because escalation and the
assigned-fix-set rule read them. **The amount is a prediction, not a measurement**, which is why
the story routes it to P8.

---

## 4. The pass floor (part 1)

**One predicate.** `max(risk, security) == 0` → floor **1**; everything else → **3**, unprofiled
included. Two levels, not three: `high` takes its rigor from lens sets and evidence mode.

**Unanimity across a cited set.** Floor 1 **if and only if every cited story is profiled and every
one is at level 0**. This follows §5's own precedent — "skip-eligible only if **every** cited
story is" — and is the only reading consistent with invariant 2's firing direction.

**One derived value governs every loop of the cycle** — Gate-A spec, Gate-A plan, Gate B — because
those loops cite the same stories. Both copies say so and say why.

**No `docs-only` arm.** A diff-derived reading cannot serve Gate A, which runs before a diff
exists; a story-declared one is subsumed, since intake defines `trivial` as no behavioural effect;
and path-derived would be **wrong here**, because `docs/hardening-log.md` is a `docs/**.md` path
that drives rung escalation.

### 4.1 The floor lives in the text, not in a file

**Nothing here writes `.context/codex-gate.floor`.** The floor is derived and **stated** — in every
pass report and in the commit-body provenance line — and §5's text is what binds an agent.

**The knob stays the user's, and is the hook's reminder threshold.** Never written, never removed,
never read for the derivation. It never bound an agent: `$floor` does appear in control flow
(`:946`, `:966`), but that flow only selects **which advisory message fires**, and the hook exits 0
on every branch (invariant 1).

**Precedence, shipped as text, because a reminder is not an instruction:**

> **The derived floor controls whether the cycle may close. The hook's ratio is a reminder
> threshold and controls nothing.** Where the derived floor and the ordinary closure rules are
> satisfied, a below-threshold reminder is **noted in the pass report and disregarded.**

**The first eligible floor-1 cycle is P8's first checkpoint.** The story cannot demonstrate floor 1
on this branch — it is risk `high` — so the demonstration is deferred: **the first post-merge cycle
whose cited set licenses floor 1 must carry the floor-1 provenance line, and the P8 measurement
reads it.** That is what makes the reduced floor observable at all, and it is why the provenance
grammar is pinned here rather than downstream.

**Named residual:** the hook's own message says a cycle "MUST reach a minimum" at its threshold
(`codex-gate.sh:933`), which at level 0 contradicts a legitimate one-pass close. **Hook text is out
of scope by decision**, so this is disclosed, not fixed; what makes it tolerable is the precedence
rule plus invariant 1.

**Why the earlier marker mechanism was deleted rather than repaired.** It had the agent write the
knob plus a marker distinguishing agent writes from user writes; Gate-A pass 3 returned sixteen
Majors against it and one that settled it — **the cheapest bypass was marker-specific**, so a
protection made the attack indistinguishable from the protected case. **What deletion does not
remove:** anyone can still write the gitignored knob and quiet the hook. What it removes is this
design's reliance on writing it, and with that the ambiguity — a floor file is now **always** a
user artifact.

**The provenance line's grammar is pinned here, not in the plan.** It is a **durable interface a
later reader consumes** — story criterion 3 requires one form and says the spec states which — so
unlike a replacement wording it cannot be settled downstream without leaving P8's input to the
plan. Revision 10 moved it and was wrong to; that is the one place the slimming crossed from
detail into contract, and it is the reason the restructuring guard exists.

```
floor <N> per <STORY-SET>; hook reminder threshold <KNOB>

<STORY-SET> := "none"                          the artifact cites no story
             | "{" <ENTRY> ("," <ENTRY>)* "}"
<ENTRY>     := <path> " (level " <0|1|2> ")"   a profiled story
             | <path> " (unprofiled)"          a cited story with no profile
<KNOB>      := "absent" | <positive integer> | "unusable"
```

Paths are repo-relative and contain no `,`, `{`, `}` or `;`; a path that would is written in
double quotes with `\"` escaping. **The same reasoning fixes the curve's form in §5.1**: both are
read by something other than a human.

**The residual disclosure this implies ships in both copies**, in the words the story requires:
that the floor a cycle owes is **produced by the agent**, that **nothing checks it** against the
cited profiles, and by what routes it can therefore be wrong (§10). A copy carrying the grammar
without the disclosure would present a parseable number as a verified one.

**Required properties the grammar exists to satisfy:**
- **Every cycle records it**, default or not, so an absent line is never ambiguous between "the
  default applied" and "someone forgot".
- It states **one floor and the cited set that produced it, with each member's level as a
  numeral** — not an entry per story, since unanimity makes the floor a property of the set.
- It distinguishes a **cited story with no profile** from **no story cited**.
- The **knob is recorded whenever the file exists**, including when present but unusable, since
  the hook ignores such a value and the line describes what the hook will do.
- It is **machine-extractable**, because the deferred P8 measurement reads it, and **one form
  covers every case** — a second pinned form for a special case is what made earlier revisions
  unparseable.

### 4.2 A profile that moves mid-cycle

Three existing rules compose; no new rule. The floor derives from the **current** profile at each
pass; **passes already run keep counting**; **closing requires the floor as currently derived.**

**The cited *set* can move too, not only a profile's values** — a story added, removed or
corrected mid-cycle — and the same three rules cover it: the set is re-read at each pass, the
floor is re-derived from it under unanimity, and closure requires the floor the current set
yields. **Adding a story is a raise for this purpose** and carries the same one-further-pass
consequence.

**The consequence that must be stated:** a **raise costs at least one further pass regardless of
the arithmetic**, because §5 already requires the final clean pass to run under the current
profile — so even a raise leaving the floor unchanged costs a pass. **A lowering** drops the floor,
the lens sets and the evidence mode together, so a `high` cycle lowered to `trivial` can close on
**one further pass after the lowering**. That is the pre-existing profile-change path,
human-confirmed and logged; the variable floor rides it and does not create it.

---

## 5. Q6 — the pass-4 report when prior-pass history is unavailable

**Report what is computable, name what is not and why, and disclose the reduced sensitivity.** Not
a new stop condition, not a mandatory resume note.

Three of the five tells need history — the finding count rising, the Blocker count failing to
fall, and a require↔withdraw pair. **Two are computable from the current pass alone: findings
clustering on the instrument, and findings clustering on prose about either.** So the two-tell
threshold **remains reachable** on that pair. The duty loses sensitivity; it does not become
inoperative.

**Five shapes, each with its own check and remedy** — the plan carries the check specifics:
**absent** (no file — and *for the trend* it is unrecoverable, since a fresh run produces a
different pass rather than that one; this does not touch §5's single shared recovery attempt,
which applies to the pass being run now, not to reconstructing an earlier one); **partial** (some
slots present — compute over what exists and **name the missing pass numbers**, since a trend over
an unstated subset reads as a trend over the cycle); **malformed** (fails any pass-acceptance
check — treated as absent, **never** as zero findings, and re-runnable only while its `sessionId`
is still to hand); **unreadable** (environmental, and the OS cause is reported because permissions
and a full disk need different fixes); **stale** (another cycle's, or unattributable).

**Stale is only partly detectable and the text says which part.** Bare numbered slots carry no
cycle identity, so a bare file is *unattributable* rather than known-foreign. Two prompt-only
mitigations: the **per-cycle slot infix**, which makes a cycle's own slots identifiable, and §5's
existing delete-and-confirm rule. Neither recovers a bare file's origin after the fact.

**The disclosure is not optional and names the cause**, the shape, and the affected passes.

**Rejected, with reasons:** a mandatory resume note changes an artifact §5 calls advisory;
unavailable history as its own stop would halt every cycle resumed on a fresh checkout; restarting
the pass-4 clock at the first visible pass silently lowers coverage.

**Stated risk:** this fails *toward continuing* the loop, the direction invariant 2 questions. The
mandatory disclosure is what makes it acceptable.

### 5.1 The per-pass curve

**Each of the three loops records its own per-pass finding and Blocker counts in its own commit
body**, labelled with the loop it describes. **Gate B alone would leave the dominant cost
unmeasured** — the loops this story cites as evidence are Gate-A loops.

**The form is pinned here**, for the same reason as the provenance line: P8 reads it, so leaving
it to the plan would leave a durable interface undecided.

```
<Loop> (passes <SPEC>, <MODELS>): Findings <n>, <n>, …. Blockers <n>, <n>, ….
<Loop>    := "Gate-A spec loop" | "Gate-A plan loop" | "Gate B"
<SPEC>    := a comma-and-range list of the pass numbers covered, e.g. "1-3" or "1,2,4"
<MODELS>  := one model name, or "pass <p> <model>" entries where they differ
```

A skipped loop writes `<Loop>: skipped (see skip reason)` and no counts.

**Required properties the form exists to satisfy:**
- One entry per **valid** pass, in pass order; **incomplete passes are excluded**, and because
  they consume pass numbers the record **states which pass numbers it covers**. A valid
  zero-finding pass is recorded as zero, never omitted.
- A `full` Gate-B pass, and separate `spec`/`quality` calls, and a single-branch recovery, are
  **branches of one logical pass** contributing one summed entry. **The curve counts logical
  passes; the hook counts calls**, and where they differ the body says so.
- **Both branches of one logical pass must have reviewed the same artifact revision**, identified
  by the tracked reviewed commit. If it changed between them they are not one pass: the completed
  branch is an incomplete pass and the second begins a new one.
- **The model each pass ran under is recorded**, per the existing convention at
  `docs/coding-workflow.md:261-266`, with each contributing model listed where a pass was
  assembled from calls under different models.
- A **legitimately skipped** loop records the skip rather than a silent gap.

**What it reaches.** Durable **across cycles** — surviving a fresh checkout, a cleared `.context/`,
another machine. **Not within a running loop**: the commit does not exist until the loop closes, so
§5's degraded-sensitivity answer governs there. And it is **author-written and unchecked** —
nothing compares it against the validated pass files, so **P8 reads a self-reported curve** and the
text says so rather than letting it be treated as measurement.

**Squash carry.** §5's rule names only evidence entries and human-exception records; the **decline
records, the provenance line, these curves and a skipped loop's skip record** are added, in both
copies. A skip record that does not survive the squash leaves an unexplained gap in exactly the
history P8 reads.

---

## 6. Old-conditions accounting

Required by the AGENTS.md Don't and story criterion 6.

**Method — the stable half, and it stays here.** For each passage: list what its existing prose
requires, then mark each requirement **kept**, **moved**, or **deliberately dropped**. A
requirement neither kept nor explicitly dropped is a dropped condition. **No passage is rewritten
without its accounting.**

**Where the dispositions are produced and gated.** In one artifact,
`docs/superpowers/specs/2026-08-28-review-loop-economics-conditions.md`, written **once against
the frozen final text** and **reviewed before any replacement text is written**. The gate is a
gate, so it has the parts a gate has: it is **a Gate-A review of that artifact** under this
story's profile, its **acceptance condition is a clean pass at the derived floor** like any other,
and **failure means no replacement text is written** rather than a note and a continuation. The
plan names where in its sequence that falls.

**The pass-2 tension, recorded rather than resolved by hindsight.** Gate-A pass 2 raised a Blocker
demanding the inventory live *in this spec* rather than being deferred to the plan — correct, since
deferring what constitutes compliance while claiming compliance is the failure the Don't describes.
**The frozen-text artifact is a third option neither pass had**, and it preserves what pass 2
required: the accounting exists and is reviewed *before the replacement is approved*. What moved is
when it is produced.

**The price of the split, stated.** Once dispositions are deferred, **the passage list is the sole
guard against a dropped condition**, and the conditions artifact cannot catch what the list never
named. Rows 20 and 21 were missing until pass 8 because revision 8 added rules rewriting them
without extending the list. **The list is re-checked whenever the design adds a rule**, and the
plan's gate reads it against the final text rather than trusting it.

### 6.1 Floor-wording sites are generated, not hand-derived

Hand-derived three times, three different counts. The inventory is the output of a stated command:

```
grep -nE "min 3 passes|below 3|3-pass|3 passes|where the 3 come from|3-passes-per-gate" \
  CLAUDE.md plugins/dev-workflow/commands/workflow-init.md
```

**Six sites per copy, symmetric — twelve, all changing.** Two limitations, stated because a
generated list reads as complete: **it finds digit sites only**, and the site that matters most
spells none — `:126/:322`, "*a Blocker/Major-free **pass 1** carrying a Minor keeps looping*",
correct under floor 3 and **false under floor 1** where pass 1 is *at* the floor. **Fourteen sites
in total, all changing.** And **it is a floor, not coverage**: another digit-free formulation would
escape it. It correctly does not match `:249/:434`, which cites a historical pass rather than
stating a rule.

### 6.2 The passages this change rewrites

Each present exactly once in both copies. **Twenty-one; the conditions artifact is incomplete
without all of them.**

| # | Passage | Rewritten by |
|---|---|---|
| 1 | "Both gates are a LOOP with a HARD FLOOR" | part 1 — the floor statement |
| 2 | The early-exit sentence (`:79/:279`) | part 1 — the zero-finding exit |
| 3 | The incomplete-pass rule (`:236/:421`) | part 1 |
| 4 | "What a loop absorbs, and what stops it" | part 3 — the scope stop becomes an ordered suspension |
| 5 | "Recognizing \"clearly stuck\"" | part 3 — becomes a suspension; clean precedence moves to the ordering |
| 6 | "Surfacing does not close the cycle" | part 3 — the hold mechanism |
| 7 | "From pass 4 onward…" | part 3 and §5 — two-tell stop, and Q6's answer |
| 8 | "The two rules above do not compete" | part 3 — superseded by the ordering, kept or retired explicitly |
| 9 | "Lenses are different questions…" (`:403/:582`) | part 1 |
| 10 | "The Gate-B triviality skip…" | part 1 — adjacent relaxation, checked for consistency |
| 11 | "A cycle citing several stories" | part 1 — the floor dimension under unanimity |
| 12 | "Gate A — Spec, then plan…" (`:300/:485`) | part 1 |
| 13 | "Gate B — Code" (`:335/:519`) | part 1 |
| 14 | "**Severity:** Blocker … Nit" | part 2 |
| 15 | "Scope, and it is narrow" | part 3 — distinguishing the human-exception form from the decline |
| 16 | "Recording a human exception" | part 3 — the decline reuses this transport |
| 17 | "Changing a profile" | §4.2 |
| 18 | The findings-slot naming paragraph | §5 — the grammar gains an optional per-cycle infix |
| 19 | "On squash-merge, copy every evidence entry…" | §5.1 — three record types added |
| 20 | "Before each call, delete every target file…" (`:199/:386`) | §5 — the infix, and a **refuse-on-collision** case where the target belongs to another cycle |
| 21 | The `baseSha`/WIP/closing-amend block (`:500-517`, template `:679-696`) | §2.1 — the WIP-amend properties; §4.1 and §5.1 add records the closing body must carry |

**Row 18's change is a replacement, not an addition beside it.** Today's grammar admits three exact
names; an infixed name satisfies none. The shipped text replaces each with one admitting an
optional per-cycle infix, so there is **one rule** and bare slots stay valid — with the infix
**required whenever more than one cycle could write that slot** — which includes a bare slot
already occupied *and* the case two new cycles start concurrently, where neither finds an occupied
slot and both would take the bare name. In practice: **a cycle that has a nonce uses it**, so the
bare form is reserved for the single-cycle case it already serves. Plus a
**refuse-rather-than-overwrite** rule when the target belongs to another cycle, and **uniqueness**
from the §2.1 nonce.

---

## 7. Prerequisite, rollout, and what this change falsifies

**The template lacks the sentence §3's kinship points at** — "a wrong sentence costs a confused
reader, not broken behaviour" is in `CLAUDE.md` and absent from the template. **The template gets
it**, a deliberate one-seam reduction of the 192-line divergence because the new rule depends on
it, not a general reconciliation.

**Statements this change falsifies**, from the standing lens — a change makes sentences wrong in
files it never touches:

| Site | Why it is false after |
|---|---|
| `README.md:130` | the §5 floor is derived and not 3; the knob moves the **hook's reminder threshold**, which is all it moved |
| `docs/getting-started.md:34, :40, :53` | three-pass minimums, not true at level 0 |
| `:44-45` | says the hook reports when the Gate-A floor is unmet — it reports against **its own** threshold, so at level 0 it fires when nothing is owed |
| `:58-59` | waits for `✓ … (3/3 …)` before the closing amend; at level 0 that message never comes |
| `:86` | "moves the 3-pass floor" |
| `docs/coding-workflow.md:79-80` | "Gate A's floor and the baseline questions are the same at every level" — **directly contradicted**, the same claim as `:84` in a second file |

**The rewording is honest, not cosmetic**: README and getting-started describe the knob as what it
mechanically is, and name the **sanctioned lever** for wanting fewer obliged passes — the profile,
or `codex-gate.off` for reminders. Nothing is deprecated.

**Gate-B classification of the doc edits.** §5's exemption requires **every** staged path to be
explanatory documentation, and **a mixed commit forfeits it**. So the doc edits either land in
their own docs-only commit (N/A applies) or ride with the prompt change (full Gate B applies to the
whole commit). **The plan chooses and states which.**

**What the template edit reaches.** It changes what `/workflow-init` writes into **new or
re-initialized** projects. It does **not** update a downstream project's existing `CLAUDE.md` —
invariant 9 forbids silent overwriting. Adoption is by re-running the scaffolder.

**Packaging.** Editing `plugins/dev-workflow/commands/workflow-init.md` triggers invariant 12: a
`plugin.json` version bump and a `CHANGELOG.md` entry are in the implementation surface.

---

## 8. Evidence plan

Mode `battery+check+verification` (no `+abuse-path`).

- **Battery** — the full `AGENTS.md` § Commands chain, green.
- **A check that fails without the change.** No automated test is possible for prose, so this takes
  §5's other permitted route — a **named verification** owing the same counterfactual. Subject:
  §6.1's site inventory, differential by construction — **posed as a question about behaviour under
  floor 1, the pre-change text answers wrongly at identified sites** (`:79` states the exit as
  "below 3"; `:126` says a Blocker/Major-free pass 1 carrying a Minor keeps looping, where floor 1
  requires it to close) **while the post-change text answers correctly.** **Both revisions get
  read** — a verification consulting only the post-change text cannot fail and would report success
  because of how it was wired.
- **A named verification of the risk path.** The risk path is that **the floor is derived by the
  agent and nothing mechanical checks the derivation**. It recomputes each provenance line's floor
  from the cited stories' headers; the observation that would exist if the claim were false is a
  line whose number the profiles do not license. It also confirms **no floor file is present at
  close where none was present at start** — which detects a *persisting* write and **cannot** detect
  a transient one, stated rather than implied.
- **A conditional verification that a user's knob survives untouched** — byte-identical across a
  cycle where one exists; **recorded not-applicable with its reason where none does.** An agent must
  not create one to make a check runnable, which would be a fixture supplying its own input.
- **Parity across every changed rule**, per story criterion 7 — §6.1's fourteen sites, §6.2's
  twenty-one passages, and every rule §§2–5 insert, including §10's residual disclosure and §4.1's
  provenance properties, which the story requires in **both** copies. The copies already differ on
  192 lines, so parity cannot be asserted from a whole-section diff.
- **A fresh twelve-item `docs/prompt-standards.md` pass** over every changed prompt region. **Item
  7 is read against the whole resulting prompt**, not only changed regions — a contradiction is a
  relation between an edited passage and an unedited one.

**When produced and revalidated.** §5 requires revalidation before every re-review and before the
closing amend. Verifications reading closing commits are produced against the `WIP:` snapshot and
**re-read against the content the close will carry** — the amend *is* the closing act, so re-reading
"the final commit" is circular. **What that establishes is bounded**: the index can change between
the read and the commit.

**Instrument discipline, from this story's own evidence.** Two `fic2` defects were properties of
the technique: **a state's inputs must include every input the rule reads**, and **a counterfactual
must distinguish ABSENT from CONTRADICTORY**. Both survived a full clean pass before being caught.

---

## 9. Out of scope

Hook code (anything under `plugins/dev-workflow/hooks/`, including the reminder's own wording);
gate-call observability (upstream); the pass-counter anomaly; the CodeRabbit plan-metadata
contradiction; the fixture-per-predicate question; any remedy to the supersession convention;
deprecating or repurposing the user-facing floor knob; teaching the hook about profiles; and
general reconciliation of the 192-line divergence beyond §7's one seam.

---

## 10. Risks and activation

**Everything in this section that is a rule rather than a note appears in both shipped copies**,
per the story's activation criterion: when the rules bind, the unknown-start fallback with its
named parts, and the partial-adoption consequence. The risks that are *observations about this
design* rather than instructions to a future agent stay here.

- **When these rules bind.** From the commit that ships them, and **a loop already running finishes
  under the rules it started with** — re-deriving a floor mid-loop from a rule that did not exist
  when passes were banked would invalidate a count nobody could reconstruct. **Where a loop's starting rules cannot be established it takes the stricter reading of every part
  this change touches**, named rather than left to interpretation: **floor 3**; **severity
  classified without the demotion**, so nothing is collected that would otherwise iterate; **every
  suspension treated as binding**; **decline records treated as absent**, so no hold is released;
  and **the curve duty treated as owed**. Not a re-derivation, which could hand a level-0 loop a
  floor of 1 and *skip* passes on the strength of not knowing when it started.
- **Downstream has no shipping commit.** The template travels into repositories whose history does
  not contain this change, so adoption binds from the `/workflow-init` run that **actually writes**
  the text — which invariant 9 permits to write nothing, be declined, or be merged in part. **The
  rules bind only over the text a project's `CLAUDE.md` contains**, and a partial adoption can
  persist undetected. **This is in tension with §1's coupling argument and the tension is real**: a
  project taking the severity rule without the ordering gets a loop this design never evaluated.
  What prompt text can do is done; what it cannot is said.
- **The gate-off surface — routes known today, not a complete list**, since an enumeration read as
  complete guarantees what it omits. **One route is created here and is named as such**: a stated
  floor the cited set does not license, which could not exist before there was a derived floor to
  state. Pre-existing and unchanged: omitting a higher-risk cited story, minting or editing a
  profile to level 0, presenting an incomplete set, falsifying evidence entries, silencing
  reminders, or not running a pass and reporting that it ran. **None of this is a guard**, and the
  profile-minting path is bounded only by §5's existing human-confirmation rule.
- **Rollback, once a rule has been adopted.** In this repo a bad rule is reverted like any other
  commit, and the §10 activation rule then applies to loops in flight. **Downstream there is no
  revert**: a project's `CLAUDE.md` is its own file, so withdrawing a rule means shipping a
  corrected template and waiting for each project to re-run the scaffolder and accept the diff —
  the same partial-adoption path, with the same absence of detection. **A rule that turns out
  wrong is therefore cheap to stop shipping and slow to un-ship**, which is an argument for the
  gates rather than a gap this design can close.
- **A user-set floor is not the gate-off lever**, and the text keeps them distinct: it moves what
  the hook says; the lever is a *stated* floor the profiles do not license.
- **The reachability test needs judgement** where §5 is trying to remove it; the phrasing removes
  arbitrariness, not judgement, and §3 says so.
- **Q6's answer fails toward continuing the loop**, with the disclosure that makes it acceptable.
- **The curve is self-reported**; P8 inherits that limit.
- **The expected demotion is a prediction**; P8 measures it. If it demotes far less than hoped, the
  rule is still correct and the economics claim was what was wrong.

---

## 11. What revision 10 moved, and what it did not

**Mostly a level-of-detail change — and revision 11 records where that claim was wrong.** Gate-A
pass 9 reviewed the restructuring against exactly this claim and found **two Blockers and six
Majors where compression had weakened or dropped a normative detail**, not merely relocated it.
The clearest: the severity test had become "if you can name neither", which demotes only when
*both* a reader and a changed decision are absent — inverting a rule that requires both. The
provenance grammar and the curve format had gone to the plan although both are **durable
interfaces a later reader consumes** and the story requires the spec to state them.

All eight are repaired above, and the lesson is recorded rather than smoothed over: **a
restructuring guard that only asks "did a decision move?" misses the case where a rule survives in
outline and loses its force.** The check that caught it was asking the reviewer to judge the claim
directly.

**Moved to the plan** — each reviewed in the plan's own Gate A against this spec: command lines
for the mid-cycle amend (§2.1 keeps the required properties, which is what made the earlier pinned
`-m` form's defect visible); the per-shape diagnostic check specifics in §5; per-site replacement
wordings for §6.1's fourteen sites and §6.2's twenty-one passages; and the conditions artifact's
production procedure (§6 keeps the method and the gate's acceptance condition).

**Returned to the spec after pass 9:** the provenance grammar and the curve form. Both are read by
something other than a human, so leaving them downstream would leave P8's input undecided — the
test that separates detail from contract here is **"does anything but a person parse it"**, not
length.

**Kept here, deliberately:** every settled decision with its reason; every rule stated as a
required property; the precedence table; the hold rule; the reachability test and its exclusions;
the floor predicate, unanimity and the hook-precedence rule; Q6's answer and the rejected
alternatives with reasons; the accounting method, the passage list and the split's price; the
falsified-statement inventory; the evidence plan's shape and counterfactuals; scope; and the risks
with their stated limits.

**Dropped, not moved:** narration of what earlier revisions of *this document* got wrong. Where
such an error produced a rule, the rule is here and the history is in the commit bodies and in
`docs/field-reports/2026-08-16-canvas-a1-a5-dispositions.md`, which is where a reader looking for
the lesson should be sent.
