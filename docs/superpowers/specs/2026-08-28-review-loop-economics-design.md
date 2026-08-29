# Review-loop economics: pass floor and severity semantics — Design

**Date:** 2026-08-29 · **Revision:** 14, after Gate-A passes 1-12
(27, 30, 54, 40, 33, 34, 32, 33, 28, 27, 38, 24 findings)
**Story:** `docs/superpowers/stories/2026-08-28-review-loop-economics-pass-floor-story.md`
**Profile (read from that header, not copied):** risk `high` · security `none` ·
validation `battery+check+verification`, no `+abuse-path`.

**What this document is, after revision 10.** Contract level only: settled decisions with their
reasons, rules stated as required properties, named interfaces, and scope. **Exact replacement wordings,
command lines and step-by-step procedures live in the plan**, where they get their own Gate A
against this spec once it is stable. **Two formats are the exception and are pinned here**: the
provenance line (§3.1) and the per-pass curve (§4), because **something other than a person
parses them** — that is the test separating detail from contract here, not length. Nothing escapes review by moving;
what changes is when it is reviewed. Revision 10 is a level-of-detail change and moves no
decision — §10 lists what went where.

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

## 1. What these two parts change, and why they ship together

**Part 1** makes the mandatory pass floor a function of the story profile instead of a flat 3.
**Part 2** decides finding severity by whether something in the system takes a different decision,
instead of by what kind of file the text lives in.

**They are coupled by an argument, not by convenience.** Part 2's reachability test is what settles
a part-1 question: a path-derived `docs-only` arm for the floor would be **wrong in this repo**,
because `docs/hardening-log.md` is a `docs/**.md` path that drives rung escalation — "docs" does
not imply "changes nothing". Splitting these two would separate a rule from the argument that
decides it.

**The §5 loop-rule consolidation is no longer in this spec.** It moved to
`docs/superpowers/stories/2026-08-29-loop-rule-consolidation-story.md` after Gate-A attribution
showed it generating 10, 11 and 14 Blocker/Major over three passes while these two parts held at
4/1, 8/1 and 7/1. Every decision that cycle bought is carried there as a settled input. **Nothing
here depends on that work landing first**, which is what made the split available: the floor and
severity rules bind on their own.

### 1.1 The cycle nonce

Both records these parts ship — the provenance line (§3.1) and the per-pass curve (§4) — are read
by something other than a person, and a record that cannot be attributed to a cycle is not usable
by the measurement that reads it. So each carries a **cycle nonce**.

Generated once at cycle start, immutable, and **collision-resistant in an operational sense rather
than an aspirational one: at least 8 characters drawn uniformly from `[a-z0-9]`, from a source of
randomness** — never derived from a name, a timestamp or a commit, each of which collides exactly
where sibling cycles do. It matches `[a-z0-9]{8,16}`, so it is also safe as a slot infix and a path
component. **It appears in every record the cycle writes.**

**Recovery has two sources, because a Gate-A loop's commit does not exist while it runs:** during
the loop the nonce lives in the advisory working record beside the findings files, and it becomes
history at the loop's commit. A cycle recovering it from **either** keeps its identity. **A cycle
that can recover it from neither — or whose sources disagree, or which finds more than one
candidate — has no identity and starts a new cycle**, which costs passes rather than letting one
cycle's records be read as another's.

**The advisory working record is a cycle record too**: it carries the nonce, and §5's per-cycle
infix and refuse-on-collision rule apply to it as they do to findings slots. §5's
optional-companion rules are otherwise unchanged.

## 2. Severity semantics (part 2)

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

## 3. The pass floor (part 1)

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

### 3.1 The floor lives in the text, not in a file

**Nothing here writes `.context/codex-gate.floor`.** The floor is derived and **stated** — in every
pass report and in the commit-body provenance line — and §5's text is what binds an agent.

**What a pass report states**, since the story requires it and the floor is otherwise invisible
until the cycle closes: the **derived floor**, the **risk and security values it read**, and the
**cited stories it read them from**. A report giving the number alone leaves a reader unable to
check the derivation while passes are still being spent, which is the only time checking it is
cheap.

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

**Named residual:** the hook's messages state its own threshold as an obligation — "MUST reach a
minimum" (`codex-gate.sh:933`), the Gate-B floor line (`:947`) and the Gate-A floor line (`:967`),
each rendering a ratio against `$floor` — all of which at level 0 report a shortfall against a
number the cycle does not owe. **Hook text is out
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
cycle <NONCE>; floor <N> per <STORY-SET>; hook reminder threshold <KNOB>

<NONCE>     := [a-z0-9]{8,16}                  the cycle nonce (§1.1)
<N>         := <positive integer>              the derived floor
<STORY-SET> := "none"                          the artifact cites no story
             | "{" <ENTRY> ("," <ENTRY>)* "}"
<ENTRY>     := <PATH> " (level " <0|1|2> ")"   a profiled story
             | <PATH> " (unprofiled)"          a cited story with no profile
<PATH>      := <bare-path> | <quoted-path>
<KNOB>      := "absent" | <positive integer> | "unusable(" <CAUSE> ")"
<CAUSE>     := "unreadable" | "empty" | "non-numeric" | "out-of-range"
```

A `<bare-path>` is repo-relative and contains none of `,` `{` `}` `;` `"` or whitespace; any other
path is a `<quoted-path>` — double-quoted, with `\` and `"` backslash-escaped and no other escape
recognized. **The nonce leads every pinned form**, which is what lets §1.1's rule that it appears
in *every* record be something the formats can satisfy.

One instance per variant, all parsing under the grammar above:

```
cycle k7m2q9xa; floor 1 per {docs/superpowers/stories/A-story.md (level 0)}; hook reminder threshold absent
cycle k7m2q9xa; floor 3 per {A-story.md (level 0), B-story.md (level 2)}; hook reminder threshold 3
cycle k7m2q9xa; floor 3 per {A-story.md (level 0), C-story.md (unprofiled)}; hook reminder threshold 1
cycle k7m2q9xa; floor 3 per none; hook reminder threshold unusable(non-numeric)
cycle k7m2q9xa; floor 3 per {"docs/stories/odd, name.md" (level 2)}; hook reminder threshold absent
```

**Everything that quotes this line elsewhere quotes an instance of the grammar.** A shorthand in a
story criterion, a commit body or a report is either a valid instance or it is wrong — there is no
informal variant, because the only reader that matters parses rather than reads. **The same reasoning fixes the curve's form in §5.1**: both are
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
  the hook ignores such a value and the line describes what the hook will do. **The unusable cases
  are distinguished rather than merged**: unreadable, empty, non-numeric and out-of-range need
  different fixes — a permission problem is not a typo — and a single `unusable` token would tell a
  reader only that something is wrong, which prompt-standards item 10 treats as naming a symptom
  instead of a cause.
- It is **machine-extractable**, because the deferred P8 measurement reads it, and **one form
  covers every case** — a second pinned form for a special case is what made earlier revisions
  unparseable.

### 3.2 A profile that moves mid-cycle

Three existing rules compose; no new rule. The floor derives from the **current** profile at each
pass; **passes already run keep counting**; **closing requires the floor as currently derived.**

**The cited *set* can move too, not only a profile's values** — a story added, removed or
corrected mid-cycle — and the same three rules cover it: the set is re-read at each pass, the
floor is re-derived from it under unanimity, and closure requires the floor the current set
yields. **Adding or removing a story changes the derived floor only if it changes the
unanimity verdict** — adding a level-0 story to an all-level-0 set moves nothing, and removing one
non-zero story from a set with two leaves the floor at 3. Where the verdict does move, **upward is
a raise** and carries the one-further-pass consequence; **downward lowers the floor and releases
nothing else**: an accepted in-set
Blocker or Major stays in the set and must still resolve, because it entered by the user's answer
and not by the story that first raised it. A set change moves the floor; it is not a route to
discharge findings.

**The consequence that must be stated:** a **raise costs at least one further pass regardless of
the arithmetic**, because §5 already requires the final clean pass to run under the current
profile — so even a raise leaving the floor unchanged costs a pass. **A lowering** drops the floor,
the lens sets and the evidence mode together, so a `high` cycle lowered to `trivial` can close on
**one further pass after the lowering**. That is the pre-existing profile-change path,
human-confirmed and logged; the variable floor rides it and does not create it.

---

## 4. The per-pass curve

**Each of the three loops records its own per-pass finding and Blocker counts in its own commit
body**, labelled with the loop it describes. **Gate B alone would leave the dominant cost
unmeasured** — the loops this story cites as evidence are Gate-A loops.

**The form is pinned here**, for the same reason as the provenance line: P8 reads it, so leaving
it to the plan would leave a durable interface undecided.

```
cycle <NONCE>; <Loop> (passes <SPEC>, <MODELS>): Findings <COUNTS>. Blockers <COUNTS>.

<NONCE>    := [a-z0-9]{8,16}                 the cycle nonce (§1.1)
<Loop>     := "Gate-A spec loop" | "Gate-A plan loop" | "Gate B"
<SPEC>     := <RANGE> ("," <RANGE>)*         strictly ascending, non-overlapping
<RANGE>    := <p> | <p> "-" <p>              the second greater than the first
<p>        := [1-9][0-9]*                    a pass number
<COUNTS>   := <n> ("," <n>)*                 one per pass in <SPEC>, same order
<n>        := 0 | [1-9][0-9]*                a finding or Blocker count
<MODELS>   := <model> | <PER-PASS> ("; " <PER-PASS>)*
<PER-PASS> := "pass " <p> " " <model> ("+" <model>)*
<model>    := [^ ;:,()]+ | "undetermined"    verbatim as the call reported it
```

`<COUNTS>` has exactly as many entries as `<SPEC>` enumerates, so a reader can map each number to
its pass without inference. `<model>` is deliberately permissive about punctuation because
provider-qualified identifiers like `moonshotai/kimi-k3` are already in this repo's records; what
it excludes is the grammar's own delimiters.

One bare `<model>` means every covered pass ran under it. `<PER-PASS>` entries are
semicolon-separated and must cover **every** pass the `<SPEC>` names; a pass assembled from calls
under different models joins them with `+`. **A model that cannot be determined is written
`undetermined`**, never omitted and never guessed — `docs/coding-workflow.md` already requires
recording it that way where neither config level names one.

A skipped loop writes `cycle <NONCE>; <Loop>: skipped (see skip reason)` and no counts — the
nonce leads **every** form, skipped included, or a skip cannot be attributed to the cycle that
took it.

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
nothing here fills that gap. And it is **author-written and unchecked** —
nothing compares it against the validated pass files, so **P8 reads a self-reported curve** and the
text says so rather than letting it be treated as measurement.

**Squash carry.** §5's rule names only evidence entries and human-exception records; the
**provenance line, these curves and a skipped loop's skip record** are added, in both copies.
(The successor story adds the decline record to the same list; the two changes touch one passage
and the second must not drop what the first added.) A skip record that does not survive the squash leaves an unexplained gap in exactly the
history P8 reads.

---

## 5. Old-conditions accounting

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
**it owes its own labelled curve** in the commit that carries the artifact — a gate exempt from the
rules it enforces would be the gate-off path in miniature —
and **failure means no replacement text is written** rather than a note and a continuation.
**A finding that changes the passage list, a disposition or the spec itself feeds back rather than
being absorbed**: the artifact is regenerated against the corrected text and re-reviewed, and where
the finding changes *this spec*, the spec's own Gate A reopens on the changed rule. The artifact is
downstream of the spec, so it cannot silently amend it. The
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
without extending the list. **The list is re-checked whenever the design adds a rule** — pass 10 added rows 22 and 23 for exactly that reason, the nonce rule having reached records the list never named —, and the
plan's gate reads it against the final text rather than trusting it.

### 5.1 Floor-wording sites are generated, not hand-derived

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

### 5.2 The passages this change rewrites

Each present exactly once in both copies. **Eighteen; the conditions artifact is incomplete without
all of them.**

**A passage both changes rewrite appears in both accountings**, each covering its own change. That
is not duplication: the AGENTS.md Don't asks what *this* change does to a passage's conditions, and
two changes to one passage owe two answers. Getting this wrong is how a condition is dropped —
Gate-A pass 12 found six passages assigned wholly to the successor that **this** change also
rewrites, including the clearly-stuck paragraph, whose "pass 1 carrying a Minor" sentence §5.1
identifies as false under floor 1. Assigning it away would have dropped the floor change's own
condition into a story whose scope excludes the floor.

| # | Passage | Rewritten by |
|---|---|---|
| 1 | "Both gates are a LOOP with a HARD FLOOR" | part 1 — the floor statement |
| 2 | The early-exit sentence (`:79/:279`) | part 1 — the zero-finding exit |
| 3 | The incomplete-pass rule (`:236/:421`) | part 1 |
| 4 | "Lenses are different questions…" (`:403/:582`) | part 1 |
| 5 | "The Gate-B triviality skip…" | part 1 — adjacent relaxation, checked for consistency |
| 6 | "A cycle citing several stories" | part 1 — the floor dimension under unanimity |
| 7 | "Gate A — Spec, then plan…" (`:300/:485`) | part 1 |
| 8 | "Gate B — Code" (`:335/:519`) | part 1 |
| 9 | "**Severity:** Blocker … Nit" | part 2 |
| 10 | "Changing a profile" | §4.2 |
| 11 | The findings-slot naming paragraph | §5 — the grammar gains an optional per-cycle infix |
| 12 | "Before each call, delete every target file…" (`:199/:386`) | §5 — the infix, and a **refuse-on-collision** case where the target belongs to another cycle |
| 13 | "Recognizing \"clearly stuck\"" | **part 1** — its "pass 1 carrying a Minor" sentence is false under floor 1 (§5.1). *The successor also rewrites this passage for the ordering; both accountings owe it.* |
| 14 | "Recording a human exception" | §1.1 — the nonce appears in every cycle record, this one included |
| 15 | "The evidence entry lives in the commit body" | §1.1 — same |
| 16 | "Optional companions, from field practice" | §1.1 — the nonce, plus the working record's role and the collision rule; §5's optional-companion *status* is unchanged |
| 17 | "On squash-merge, copy every evidence entry…" | §4 — the provenance line, curves and skip records added to the carry. *The successor adds the decline record; both accountings owe it.* |
| 18 | The `baseSha`/WIP/closing-amend block (`:500-517`, template `:679-696`) | §4 — the closing body must carry the provenance line and curve. *The successor adds the WIP-amend properties; both accountings owe it.* |

**Row 18's change is a replacement, not an addition beside it.** Today's grammar admits three exact
names; an infixed name satisfies none. The shipped text replaces each with one admitting an
optional per-cycle infix, so there is **one rule** and bare slots stay valid — with the infix
**required whenever more than one cycle could write that slot** — which includes a bare slot
already occupied *and* the case two new cycles start concurrently, where neither finds an occupied
slot and both would take the bare name. In practice: **a cycle that has a nonce uses it**, so the
bare form is reserved for the single-cycle case it already serves. Plus a
**refuse-rather-than-overwrite** rule when the target belongs to another cycle, and **uniqueness**
from the §1.1 nonce.

---

## 6. Prerequisite, rollout, and what this change falsifies

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

## 7. Evidence plan

Mode `battery+check+verification` (no `+abuse-path`).

- **Battery** — the full `AGENTS.md` § Commands chain, green.
- **A check that fails without the change.** No automated test is possible for prose, so this takes
  §5's other permitted route — a **named verification** owing the same counterfactual. Subject:
  §5.1's site inventory, differential by construction — **posed as a question about behaviour under
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
- **Parity across every changed rule**, per story criterion 7 — §5.1's fourteen sites, §5.2's eighteen
  passages, and every rule §§1.1–4 insert — the nonce's generation, recovery, record and
  collision duties included — plus §9's residual disclosure and §3.1's
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

## 8. Out of scope

Hook code (anything under `plugins/dev-workflow/hooks/`, including the reminder's own wording);
gate-call observability (upstream); the pass-counter anomaly; the CodeRabbit plan-metadata
contradiction; the fixture-per-predicate question; any remedy to the supersession convention;
deprecating or repurposing the user-facing floor knob; teaching the hook about profiles; and
general reconciliation of the 192-line divergence beyond §7's one seam.

---

## 9. Risks and activation

**Everything in this section that is a rule rather than a note appears in both shipped copies**,
per the story's activation criterion: when the rules bind, the unknown-start fallback with its
named parts, and the partial-adoption consequence. The risks that are *observations about this
design* rather than instructions to a future agent stay here.

- **When these rules bind.** From the commit that ships them, and **a loop already running finishes
  under the rules it started with** — re-deriving a floor mid-loop from a rule that did not exist
  when passes were banked would invalidate a count nobody could reconstruct. **Where a loop's starting rules cannot be established it takes the stricter reading of every part
  this change touches**, named rather than left to interpretation: **floor 3**; **severity
  classified without the demotion**, so nothing is collected that would otherwise iterate; **every
  and **the curve duty treated as owed**. **That list covers this change's rules; it is not a list of everything a
  cycle owes.** The parts this change touches are the floor, severity, the curve, and the cycle
  nonce with the record and collision duties that follow from it — and each is treated at its
  strictest: the nonce is required, recovery ambiguity resolves to a new cycle, and the
  collision-refusal rule applies. A part not named here is a part this change did not touch. (The successor story extends this fallback to the loop rules
  it ships; extending a list is safe where replacing it would not be.) **A user knob set above 3
  is not lowered by the fallback**: the knob moves the hook's reminder threshold while the fallback
  sets the *obliged* floor, so a workspace asking for louder reminders keeps them. Not a
  re-derivation, which could hand a level-0 loop a
  floor of 1 and *skip* passes on the strength of not knowing when it started.
- **Downstream has no shipping commit.** The template travels into repositories whose history does
  not contain this change, so adoption binds from the `/workflow-init` run that **actually writes**
  the text — which invariant 9 permits to write nothing, be declined, or be merged in part. **The
  rules bind only over the text a project's `CLAUDE.md` contains**, and a partial adoption can
  persist undetected. **This is in tension with §1's coupling argument and the tension is real**: a
  project taking the floor rule without the severity test gets a floor whose `docs-only` question
  §1 says the severity test settles.
  What prompt text can do is done; what it cannot is said.
- **The gate-off surface — routes known today, not a complete list**, since an enumeration read as
  complete guarantees what it omits. **One route is created here and is named as such**: a stated
  floor the cited set does not license, which could not exist before there was a derived floor to
  state. Pre-existing and unchanged: omitting a higher-risk cited story, minting or editing a profile to level 0,
  presenting an incomplete set, falsifying evidence entries, silencing reminders, or not running a
  pass and reporting that it ran. **None of this is a guard**, and the
  profile-minting path is bounded only by §5's existing human-confirmation rule.
- **Rollback, once a rule has been adopted.** In this repo a bad rule is reverted like any other
  commit — **and the revert is itself a shipping commit for the *old* rules.** A loop in flight across it
  therefore has two answers available and they disagree: the activation rule says a loop finishes
  under the rules it started with, while the fallback says an indeterminate start takes the
  stricter reading. **The activation rule wins where the start is determinable** — a loop whose
  own first pass artifact predates the revert finishes under the rules it began with, which is
  what that rule is for. The fallback applies only where the start cannot be established. Stating
  the precedence is the point; without it a revert makes every in-flight loop ambiguous. **Downstream there is no
  revert**: a project's `CLAUDE.md` is its own file, so withdrawing a rule means shipping a
  corrected template and waiting for each project to re-run the scaffolder and accept the diff —
  the same partial-adoption path, with the same absence of detection. **A rule that turns out
  wrong is therefore cheap to stop shipping and slow to un-ship**, which is an argument for the
  gates rather than a gap this design can close.
- **A user-set floor is not the gate-off lever**, and the text keeps them distinct: it moves what
  the hook says; the lever is a *stated* floor the profiles do not license.
- **The reachability test needs judgement** where §5 is trying to remove it; the phrasing removes
  arbitrariness, not judgement, and §3 says so.
- **The curve is self-reported**; P8 inherits that limit.
- **The expected demotion is a prediction**; P8 measures it. If it demotes far less than hoped, the
  rule is still correct and the economics claim was what was wrong.

---

## 10. What this spec keeps and what moved out

**Revision 13 reduced this spec to parts 1 and 2.** Part 3 — the §5 loop-rule consolidation — moved
to `docs/superpowers/stories/2026-08-29-loop-rule-consolidation-story.md` with every decision the
parent cycle bought, carried there as settled inputs rather than reopened.

**Why, in numbers.** Eleven Gate-A passes never brought Blocker/Major below 22. Attributed over the
last three: parts 1 and 2 produced **4/1, 8/1 and 7/1**; the loop-rule sections produced **10, 11
and 14**, rising, with each repair creating an interaction the next pass found. Two of pass 11's
Blockers were generated by the immediately preceding repair, one of them a deadlock fix that
deadlocked one level up.

**Moved out with part 3:** the exits-and-duties analysis and the precedence table; the hold, the
decline and its record; Q6's unavailable-history answer; and the eleven §5 passages only those rules
rewrite — the loop-absorb paragraph, the clearly-stuck and surfacing paragraphs, the pass-4 report,
the two-rules paragraph, the human-exception and scope-narrow blocks, and the `baseSha`/WIP/amend
block. The successor's accounting owes those.

**Kept here, and the test that decided each:** *does anything but a person parse it, and does a
shipped criterion read it?* The **provenance line** and the **per-pass curve** both pass — P8 reads
them — so their grammars stay pinned rather than descending to the plan. The **cycle nonce** stays
because both records carry it; that also settles the successor story's open question about where the
nonce lives. The floor predicate, unanimity, the hook-precedence rule, the severity test with its
exclusions, the accounting method and passage list, the falsified-statement inventory, the evidence
plan, scope and the risks all stay.

**Earlier revisions moved detail to the plan** — exact replacement wordings, the scaffolder's edit
procedures, the per-site texts for §5.1's fourteen sites and §5.2's eighteen passages, and the
conditions artifact's production procedure. **Two of those moves were wrong and were reversed**:
the provenance grammar and the curve form, which pass 9 caught. **A restructuring guard that asks
only "did a decision move?" misses the case where a rule survives in outline and loses its force** —
pass 9 found eight of those in one revision. That sentence is the most transferable thing this
cycle produced.

**Nothing here waits on the successor.** The floor and severity rules bind on their own, which is
what made the split available rather than merely desirable.
