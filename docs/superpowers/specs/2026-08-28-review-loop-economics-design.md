# Review-loop economics: pass floor and severity semantics — Design

**Date:** 2026-08-29 · **Revision:** 18 (rules only) · **Gate-A passes 1-16**
**Story:** `docs/superpowers/stories/2026-08-28-review-loop-economics-pass-floor-story.md`
**Profile:** read from that header, never from here.

Prompt-only, in two mirrored copies: `CLAUDE.md` §5 and `/workflow-init`'s inline template.
**No file under `plugins/dev-workflow/hooks/` changes, and no hook state file is written.**

**This document states rules and decisions.** Concrete formats, per-site wordings, the
old-conditions passage list, and every procedure live in the plan, reviewed there against this
spec. Two things stay pinned as *required properties* because a shipped criterion reads them and a
program parses them: the provenance line (§2.3) and the per-pass curve (§4).

**One constraint on the edit itself:** `codex-gate.sh:94` greps `CLAUDE.md` for the §5 heading to
build every reminder's citation, so **the heading must keep matching
`^#{1,6}[[:space:]]+([0-9]+\.)?[[:space:]]*Cross-Model Review`**.

---

## 1. Why these two parts ship together

Part 1 makes the mandatory pass floor a function of the story profile. Part 2 decides finding
severity by whether something in the system takes a different decision.

**They are coupled by an argument.** Part 2's test settles a part-1 question: a path-derived
`docs-only` arm for the floor would be **wrong here**, because `docs/hardening-log.md` is a
`docs/**.md` path that drives rung escalation. Splitting these two would separate a rule from the
argument that decides it.

The §5 loop-rule consolidation is **not** in this spec; it moved to
`docs/superpowers/stories/2026-08-29-loop-rule-consolidation-story.md`. Nothing here waits on it.

---

## 2. The pass floor (part 1)

**One predicate.** `max(risk, security) == 0` → floor **1**. Every resolvable profile above that,
and an **absent** profile, → **3**. Two levels, not three: `high` takes its rigor from lens sets
and evidence mode.

**A present but unresolvable profile is not "everything else".** §5 already requires it to **stop
and surface the cause**, and that rule stands unchanged — the predicate applies only to profiles
that resolve, and to artifacts citing no story. Reading an unresolvable profile as 3 would convert
an existing stop condition into a silent default.

**Unanimity across a cited set.** Floor 1 **if and only if the cited set is non-empty and every
member is profiled, resolvable, and at level 0** — all four conditions, because "every cited story"
is vacuously true of an empty set. **No story cited, or any cited story unprofiled, yields 3. Any
cited story whose profile is present but unresolvable stops and surfaces**, which is the §5 rule
above and not a floor of 3. This follows §5's own precedent — "skip-eligible only
if **every** cited story is" — and is the only reading consistent with invariant 2's firing
direction.

**One derived value governs the Gate-A spec loop, the Gate-A plan loop and the Gate-B cycle.** Not
because they are one cycle — §5 is explicit that they are **three separate cycles** — but because
they derive from **the same cited-story set**. Both copies state the rule and this reason.

### 2.1 The floor lives in the text

**Nothing here writes `.context/codex-gate.floor`.** The floor is derived and **stated**; §5's text
is what binds an agent.

**The knob stays the user's** — never written, never removed, never read for the derivation. It is
the **hook's reminder threshold** and never bound an agent: `$floor` appears in control flow, but
that flow only selects which advisory message fires, and the hook exits 0 on every branch
(invariant 1).

**Precedence, shipped as text:**

> **The derived floor controls whether a cycle may close. The hook's ratio is a reminder threshold
> and controls nothing.** Where the derived floor and the ordinary closure rules are satisfied, a
> below-threshold reminder is **noted in the pass report and disregarded.**

**Named residual, disclosed in both copies:** the hook's messages state its own threshold as an
obligation, so at level 0 they report a shortfall the cycle does not owe. **Hook text is out of
scope by decision**; the precedence rule plus invariant 1 are what make it tolerable, not the
reminder being harmless.

### 2.2 What a pass report states

The **derived floor**, the **risk and security values read**, and the **cited stories they were
read from**. A report giving the number alone leaves a reader unable to check the derivation while
passes are still being spent, which is the only time checking it is cheap.

### 2.3 The provenance line — required properties

One line per cycle, in its closing commit body. **The grammar is pinned here, not in the plan** —
the parent story requires one form and says this spec states it, and P8 parses it. (Revision 15
moved it out and was wrong to; pass 9 had already settled this, and the test it settled on is
whether anything but a person parses it.)

```
cycle <NONCE>; floor <N> per <STORY-SET>; hook reminder threshold <KNOB>

<NONCE>     := [a-z0-9]{8,16}
<N>         := [1-9][0-9]*
<STORY-SET> := "none" | "{" <ENTRY> ("," <ENTRY>)* "}"
<ENTRY>     := <PATH> " (level " ("0"|"1"|"2") ")" | <PATH> " (unprofiled)"
<PATH>      := <bare> | <quoted>          bare excludes , { } ; " and whitespace;
                                          quoted is double-quoted with \ and " escaped
<KNOB>      := "absent" | [1-9][0-9]* | "unusable(" <CAUSE> ")"
<CAUSE>     := "unreadable" | "empty" | "non-numeric" | "out-of-range"
```

Everything that quotes this line elsewhere quotes an instance of it; there is no informal variant.
The properties the grammar exists to satisfy:

- **Every cycle records it**, default floor or not, so an absent line is never ambiguous between
  "the default applied" and "someone forgot". **Three cycles means three lines**, one per cycle.
- It carries that cycle's **nonce** (§5), the **derived floor**, and **the cited set that produced
  it with each member's level as a numeral** — one floor and one set, not an entry per story,
  since unanimity makes the floor a property of the set.
- It distinguishes **a cited story with no profile** from **no story cited**.
- It records the **workspace knob whenever the file exists**, including when present but unusable,
  **naming the cause** — unreadable, empty, non-numeric, out-of-range — because those need
  different fixes and one token names a symptom rather than a cause.
- It is **machine-extractable and has one form covering every case**, because the deferred P8
  measurement parses it.

### 2.4 A profile or cited set that moves mid-cycle

Three existing rules compose; no new rule. The floor derives from the **current** profile at each
pass; **passes already run keep counting**; **closing requires the floor as currently derived.**

**Any profile change costs at least one further pass**, in either direction and whether or not the
floor number moves, because §5 already requires the **final clean pass** to run under the current
profile — so no already-banked pass can be it. **That further pass must be clean and every other
closure duty must be satisfied**; it is one more pass, not a licence to close on the next one. A
lowering additionally drops the lens sets and the evidence mode along with any change in the floor.
That is the pre-existing profile-change path; the variable floor rides it.

**The cited set is re-read at each pass, and the final clean pass runs against the current set** —
**whenever its membership changes, not only when the floor number moves.** Adding a high-risk story
to a set already at floor 3 leaves the number alone while adding that story's lens set, its
evidence obligations and its review scope; a pass run before it joined did not cover them.

**A profile change moves the number only sometimes, in both directions**: level 2 → level 1 leaves
the floor at 3, exactly as level 0 → level 0 leaves it at 1. The one-further-pass consequence
attaches to the **profile or set changing**, not to the number moving — the final clean pass must
run under the current profile and against the current set regardless. Where the number does move,
upward is a raise and downward a lowering. **What a removal discharges, precisely:** obligations are
recomputed from the current set, so removing a story does remove *that story's* lenses and evidence
duty. It **never discharges an accepted in-set Blocker or Major** — the user's acceptance put that
finding in the fix set, not the citation, so removing the citation does not take it out.

---

## 3. Severity semantics (part 2)

**One procedure decides severity. The subject list is illustration, not a second rule.**

> Name **what in the system consumes this text** — whatever *acts* on it — and the decision that
> act takes differently if the text is wrong. **Both are required.** If you cannot name both, the
> finding is **Minor or below**; collect, never iterate.

The exclusions are contract, not commentary:

- **The reader must consume the text in the system's *operation*, not in reviewing it. The review
  pass raising the finding is not an in-system reader of the text it reviews.** Without this the
  test demotes nothing. **Gates remain legitimate readers** of rule text they will later apply.
- **A human reader never satisfies the test** — §5's prose exemption already prices that cost as
  non-gating.
- **The list of reader kinds is illustrative, not closed**, because this ships into projects whose
  readers we have never seen (invariant 10).
- **The test sets a ceiling, not a floor**, and **never chooses between Blocker and Major** —
  Mechanics still decides that.
- **The instrument carve-out is symmetric**: an instrument finding keeps its severity whenever it
  shows the instrument changes what a gate concludes about product behaviour — a false green, and
  equally a false red or a check blocking a valid change.
- **Rationale prose is Minor only when no rule's application depends on it**, not categorically.
  `docs/prompt-standards.md` requires that rules carry their why, because models follow motivated
  rules better, and invariant 11 makes that binding — so rationale a reader must consult to apply
  a rule passes the test.
- **This removes arbitrariness, not judgement**, and the shipped text says so.
- **Coverage-first is unchanged**: the reviewer reports every finding with severity and confidence;
  the filter is ours.

**Kinship, stated in the shipped text:** the **finding-level analog of the path-level prose
exemption** — one principle at two granularities, text that *describes* the product versus text
that *is* the product.

**Expected effect, with its limit, disclosed rather than claimed.** Distributions like PR #23's
should demote substantially, but **how much is not predictable** — that commit's own body describes
harness defects the symmetric carve-out keeps. Ledger rows and story criteria keep their severity
because escalation and the assigned-fix-set rule read them. **The amount is a prediction, not a
measurement**, which is why the story routes it to P8.

---

## 4. The per-pass curve — required properties

Each of the three cycles records its own per-pass finding and Blocker counts in its own commit
body, labelled with the cycle it describes. **Gate B alone would leave the dominant cost
unmeasured** — the loops this story cites as evidence are Gate-A loops. **Pinned here for the same
reason as the provenance line:**

```
cycle <NONCE>; <CYCLE> (passes <SPEC>, <MODELS>): Findings <COUNTS>. Blockers <COUNTS>.

<CYCLE>    := "Gate-A spec" | "Gate-A plan" | "Gate B"
<SPEC>     := <RANGE> ("," <RANGE>)*      strictly ascending, non-overlapping
<RANGE>    := <p> | <p> "-" <p>
<p>        := [1-9][0-9]*
<COUNTS>   := <n> ("," <n>)*              exactly as many entries as <SPEC> enumerates
<n>        := 0 | [1-9][0-9]*
<MODELS>   := <model> | <PER-PASS> ("; " <PER-PASS>)*
<PER-PASS> := "pass " <p> " " <model> ("+" <model>)*
<model>    := <bare-model> | <quoted-model> | "undetermined"
<bare-model> := [^ ;:,()+"]+              excludes the grammar's own delimiters, "+" included
<quoted-model> := '"' ... '"'             for a reported identifier containing any of them,
                                          with \ and " escaped
```

**`<PER-PASS>` keys must be exactly the passes `<SPEC>` expands to, each once, ascending** — a
per-pass model list that omits or repeats a pass is malformed, not partially informative. **Every
model contributing to a split logical pass is listed** for that pass, joined by `+`; recording one
of two contributing models is the same loss as recording none.

A skipped cycle writes `cycle <NONCE>; <CYCLE>: skipped (see skip reason)` and no counts. The
properties the form exists to satisfy:

- Carries that cycle's **nonce**, so a curve can be attributed to the cycle that produced it.
- **One entry per valid pass**, and because incomplete passes are excluded and consume pass
  numbers, the record **states which pass numbers it covers**. A valid zero-finding pass is
  recorded as zero, never omitted.
- A `full` Gate-B pass, separate `spec`/`quality` calls, and a single-branch recovery are
  **branches of one logical pass** contributing one summed entry. **The curve counts logical
  passes; the hook counts calls**, and where they differ the body says so.
- **Both branches of one logical pass must have reviewed the same artifact revision**, identified
  by the **tracked reviewed commit** — the plan fixes how it is encoded, but which thing is
  compared is a decision, not a format. **If it changed between them they are not one pass**: the
  completed branch is recorded as an incomplete pass and excluded, and the later branch begins a
  new one. Ending the pass is the conservative direction; merging two revisions would produce one
  entry describing two different artifacts.
- **The model each pass ran under is recorded**, per the existing convention in
  `docs/coding-workflow.md`, written `undetermined` where it cannot be determined rather than
  guessed, and admitting provider-qualified identifiers.
- A **legitimately skipped** cycle records the skip rather than a silent gap.

**What it is worth, stated rather than implied.** Durable **across cycles**. **Not within a running
cycle** — the commit does not exist until the cycle closes. And **author-written and unchecked**:
nothing compares it against the validated pass files, so **P8 reads a self-reported curve** and
must not present it as measurement.

**Squash carry.** §5's rule names only evidence entries and human-exception records; the
**provenance lines, the curves and a skipped cycle's skip record** are added. *(The successor story
adds the decline record to the same passage; extending is required, replacing would unship these.)*

---

## 5. The cycle nonce

Both shipped records carry it, and a record that cannot be attributed to a cycle is unusable by the
measurement that reads it. **§5 defines three cycles — the Gate-A spec loop, the Gate-A plan loop
and the Gate-B cycle — so a run of all three produces three nonces, not one.**

- Generated once at cycle start, immutable, and **collision-resistant operationally: at least 8
  characters drawn uniformly from `[a-z0-9]`, from a source of randomness** — never derived from a
  name, a timestamp or a commit, each of which collides exactly where sibling cycles do.
- Constrained so it is **safe as a slot infix and a path component**.
- **It appears in every record the cycle writes.**
- **A nonce is a *candidate* for recovery only if it is keyed to this cycle's type (Gate-A spec,
  Gate-A plan, or Gate B) and this cycle's artifact, and that cycle is still open.** History
  normally holds many closed cycles' nonces and they are not candidates; a working record left by a
  closed cycle is not one either, and **the working record is retired at closure** so it cannot
  become one later.
- **Recovery has two sources**, because a Gate-A cycle's commit does not exist while it runs: the
  advisory working record during the cycle, and history at its commit. Recovering a single
  candidate from **either** keeps identity. **No candidate, disagreeing sources, or more than one
  candidate → no identity, start a new cycle** — which costs passes rather than letting one cycle's
  records read as another's.
- **A cycle does not start without a valid, unique nonce.** Where generation fails — randomness
  unavailable, an invalid value, or a collision with an open cycle — retry within a bounded policy
  the plan fixes, then **stop and surface**. **No deterministic fallback**, since a derived value
  collides exactly where sibling cycles do, which is the property the nonce exists to avoid.
- **The advisory working record is a cycle record too**: it carries the nonce, and the slot rules
  below apply to it as they do to findings slots. §5's optional-companion *status* is unchanged.

**Slot rules this change adds** — the plan fixes the spelling, these are the properties. §5's
current slot grammar admits three exact names and no per-cycle component, which is why this is an
addition rather than a reference:
- **A cycle that has a nonce uses it in every slot more than one cycle could write.** The bare name
  is reserved for the legacy single-cycle case it already serves.
- **A target owned by another nonce is refused, not overwritten**, and the refusal names the
  collision. §5 already stops on a target that survives deletion; this extends that to a target
  that must not be deleted at all.
- These rules exist because a bare slot was in fact overwritten during this cycle, destroying a
  previous cycle's findings file.

---

## 6. Old-conditions accounting

**Method.** For each passage this change rewrites: list what its existing prose requires, then mark
each requirement **kept**, **moved**, or **deliberately dropped**. A requirement neither kept nor
explicitly dropped is a dropped condition. **No passage is rewritten without its accounting.**

**A passage that both this change and the successor rewrite appears in both accountings**, each
covering its own change — two changes to one passage owe two answers.

**Where it is produced and gated.** In one artifact, written **once against the frozen final text**
and **reviewed before any replacement text is written**. **That review is part of the Gate-A plan
cycle, not a fourth cycle** — the topology stays at three, and the artifact is an input the plan
cycle reviews alongside the plan. Its acceptance is that plan cycle's clean pass; **no replacement
text is written while it is outstanding**, and a finding against it **feeds back** — the artifact
is regenerated against corrected text — rather than being absorbed. **The plan carries the passage list and executes
this method against it** — and because the dispositions are deferred, **that list is the sole guard
against a dropped condition**, so it is re-checked whenever the design adds a rule.

**The two copies are accounted for separately** where their text differs, since they already
diverge substantially and one accounting cannot cover both.

---

## 7. Rollout, and what this change falsifies

**The template lacks the sentence §3's kinship points at** — the prose-exemption rationale is in
`CLAUDE.md` and absent from the template. **The template gets it**: a one-seam reduction of the
divergence, because the new rule depends on it, not a general reconciliation.

**Statements this change falsifies must be corrected in the same change** — in `README.md`,
`docs/getting-started.md` and `docs/coding-workflow.md`, wherever they assert a fixed three-pass
floor, describe the knob as moving the §5 floor, say the hook reports an unmet Gate-A floor, or
wait for a `3/3` message before closing. The plan carries the site list. **The rewording describes
the knob as what it mechanically is** and names the sanctioned lever for fewer obliged passes — the
profile, or `codex-gate.off` for reminders. Nothing is deprecated.

**Gate-B classification of the doc edits.** §5's exemption requires **every** staged path to be
explanatory documentation, and **a mixed commit forfeits it**. So the doc edits either land in
their own docs-only commit or ride with the prompt change and take full Gate B. **The plan chooses
and states which.**

**What the template edit reaches.** It changes what `/workflow-init` writes into **new or
re-initialized** projects. It does **not** update a downstream project's existing `CLAUDE.md` —
invariant 9 forbids silent overwriting. Adoption is by re-running the scaffolder.

**Packaging.** Editing the template triggers invariant 12: a `plugin.json` version bump and a
`CHANGELOG.md` entry are in the implementation surface.

---

## 8. Evidence plan

Mode `battery+check+verification` (no `+abuse-path`; security is `none`).

- **Battery** — the full `AGENTS.md` § Commands chain, green.
- **A check that fails without the change.** No automated test is possible for prose, so this takes
  §5's other permitted route — a **named verification** owing the same counterfactual. Posed as a
  question about behaviour under floor 1, **the pre-change text answers wrongly at identified
  sites** and the post-change text answers correctly. **Both revisions get read**: a verification
  consulting only the post-change text cannot fail and would report success because of how it was
  wired.
- **A named verification of the risk path** — that the floor is derived by the agent and nothing
  mechanical checks it. It recomputes each provenance line's floor from the cited stories' headers;
  the observation that would exist if the claim were false is a line whose number the profiles do
  not license. It also confirms **no floor file is present at close where none was present at
  start**, which detects a *persisting* write and **cannot** detect a transient one.
- **A conditional verification that a user's knob survives untouched** — byte-identical across a
  cycle where one exists; **recorded not-applicable with its reason where none does**, since
  creating one would be a fixture supplying its own input.
- **A parse check over both pinned grammars.** The branch's own instances cannot exercise them:
  three lines cannot cover quoted paths, each unusable-knob cause, gapped pass ranges, split-model
  passes, a skipped cycle, or the cardinality rule that `<COUNTS>` matches `<SPEC>`. **The check
  reads a set of constructed strings — valid ones that must parse and invalid ones that must be
  rejected** — and records which grammar features each exercises. A grammar nothing ever parsed is
  a format claim, not a format.
- **Parity across every changed rule**, in both copies, since they already diverge and parity
  cannot be asserted from a whole-section diff.
- **A fresh twelve-item `docs/prompt-standards.md` pass.** Invariant 11 binds **each changed
  prompt artifact as a complete prompt**, not the diff — so the items are read against the
  resulting `CLAUDE.md` and the resulting scaffolded template, with the changed regions as the
  reason the pass is owed rather than its scope. Item 7's whole-artifact reading is the clearest
  case, not the only one.
  **One known failure, fixed rather than routed.** Neither resulting prompt carries a
  `Target model:` line, which item 1 requires — `workflow-init.md` names one for the outer command
  and those bytes are not scaffolded. **Both resulting prompts get one.** An earlier revision
  proposed routing it as out of scope, which cannot stand beside the sentence above: a change
  cannot require each resulting prompt to pass all twelve items and knowingly leave one false. It
  is one line per copy, in a file this change already edits, and the invariant that makes the pass
  binding is the same invariant that makes the line required.

- **This branch's own three closing bodies carry the final forms**, since two story criteria
  require it. **No reconstruction is needed and none is claimed:** the Gate-A spec cycle has not
  closed — it is still in Gate A as this is written — and the Gate-A plan cycle has not started, so
  both write their closing bodies natively in the pinned forms.
  **The nonce is the one field this branch's spec cycle cannot supply natively, and the activation
  rule already governs it.** That cycle began before the nonce rule existed; its slot discriminator
  is short and deterministic, so it is not a nonce, and minting one now would be late-created
  provenance dressed as a cycle record. **A cycle already running finishes under the rules it
  started with** (§10), so this one records its provenance line and curve with the nonce field
  marked `pre-rule` and says so. **The first cycle started after these rules ship carries a real
  one**, and the verification confirms that rather than pretending this branch demonstrates it.
  **The verification confirms all three bodies before closure**, because a demonstration the branch
  does not contain is not a demonstration.

**Revalidation.** §5 requires it before every re-review and before the closing amend. Verifications
reading closing commits are produced against the `WIP:` snapshot and **re-read against the content
the close will carry** — the amend *is* the closing act. **What that establishes is bounded**: the
index can change between the read and the commit.

---

## 9. Out of scope

Hook code, including the reminder's own wording; gate-call observability; the pass-counter anomaly;
the CodeRabbit plan-metadata contradiction; the fixture-per-predicate question; any remedy to the
supersession convention; deprecating or repurposing the user-facing floor knob; teaching the hook
about profiles; the §5 loop-rule consolidation and everything its successor story owns; and general
reconciliation of the two copies' divergence beyond §7's one seam.

---

## 10. Risks and activation

- **When these rules bind.** From the commit that ships them, and **a cycle already running
  finishes under the rules it started with**. **Where a cycle's starting rules cannot be
  established it takes the stricter reading of every part this change touches** — floor 3, severity
  classified without the demotion, the curve duty owed, and the nonce duties at their strictest. Not
  a re-derivation, which could hand a level-0 cycle a floor of 1 and *skip* passes on the strength
  of not knowing when it started. A user knob set above 3 is not lowered by this fallback. *(The
  successor extends this list to the rules it ships; extending is safe, replacing is not.)*
- **A revert is itself a shipping commit for the old rules.** **The activation rule wins where the
  start is determinable**; the fallback covers only where it is not. Without that precedence a
  revert makes every in-flight cycle ambiguous.
- **Downstream has no shipping commit.** Adoption binds from the `/workflow-init` run that
  **actually writes** the text, which invariant 9 permits to write nothing, be declined, or be
  merged in part. **The rules bind only over the text a project's `CLAUDE.md` contains**, and a
  partial adoption can persist undetected. **This is in tension with §1's coupling argument and the
  tension is real**: a project taking the floor rule without the severity test gets a floor whose
  `docs-only` question §1 says the severity test settles. What prompt text can do is done; what it
  cannot is said.
- **The gate-off surface — routes known today, not a complete list**, since an enumeration read as
  complete guarantees what it omits. **One route is created here**: a stated floor the cited set
  does not license, which could not exist before there was a derived floor to state. Pre-existing
  and unchanged: omitting a higher-risk cited story, minting or editing a profile to level 0,
  presenting an incomplete set, falsifying evidence entries, silencing reminders, or not running a
  pass and reporting that it ran. **None of this is a guard.**
- **A user-set floor is not the gate-off lever**: it moves what the hook says. The lever is a
  *stated* floor the profiles do not license.
- **The reachability test needs judgement** where §5 is trying to remove it; §3 says so.
- **The curve is self-reported**; P8 inherits that limit.
- **The expected demotion is a prediction**; P8 measures it. If it demotes far less than hoped, the
  rule is still correct and the economics claim was what was wrong.
