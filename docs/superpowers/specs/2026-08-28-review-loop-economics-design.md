# Review-loop economics: pass floor and severity semantics — Design

**Date:** 2026-08-29 · **Revision:** 15 (rules only) · **Gate-A passes 1-13**
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

**Unanimity across a cited set.** Floor 1 **if and only if every cited story is profiled and every
one is at level 0**. Any other set yields 3. This follows §5's own precedent — "skip-eligible only
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

One line per cycle, in its closing commit body. The plan fixes the grammar; these properties are
the contract:

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

**A raise costs at least one further pass regardless of the arithmetic**, because §5 already
requires the final clean pass to run under the current profile — so even a raise leaving the floor
unchanged costs a pass. **A lowering** drops the floor, the lens sets and the evidence mode
together, so it closes on **one further pass after the lowering**. That is the pre-existing
profile-change path; the variable floor rides it.

**A cited-set change moves the floor only if it changes the unanimity verdict** — adding a level-0
story to an all-level-0 set moves nothing. Where the verdict moves, upward is a raise with the
same one-further-pass consequence; downward lowers the floor and **releases nothing else**.

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
unmeasured** — the loops this story cites as evidence are Gate-A loops. The plan fixes the format;
these are the contract:

- Carries that cycle's **nonce**, so a curve can be attributed to the cycle that produced it.
- **One entry per valid pass**, and because incomplete passes are excluded and consume pass
  numbers, the record **states which pass numbers it covers**. A valid zero-finding pass is
  recorded as zero, never omitted.
- A `full` Gate-B pass, separate `spec`/`quality` calls, and a single-branch recovery are
  **branches of one logical pass** contributing one summed entry. **The curve counts logical
  passes; the hook counts calls**, and where they differ the body says so.
- **Both branches of one logical pass must have reviewed the same artifact revision.** If it
  changed between them they are not one pass.
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
- **Recovery has two sources**, because a Gate-A cycle's commit does not exist while it runs: the
  advisory working record during the cycle, and history at its commit. Recovering from **either**
  keeps identity. **Neither, or sources that disagree, or more than one candidate → no identity,
  start a new cycle** — which costs passes rather than letting one cycle's records read as
  another's.
- **The advisory working record is a cycle record too**: it carries the nonce, and §5's per-cycle
  infix and refuse-on-collision rules apply to it. §5's optional-companion status is unchanged.

---

## 6. Old-conditions accounting

**Method.** For each passage this change rewrites: list what its existing prose requires, then mark
each requirement **kept**, **moved**, or **deliberately dropped**. A requirement neither kept nor
explicitly dropped is a dropped condition. **No passage is rewritten without its accounting.**

**A passage that both this change and the successor rewrite appears in both accountings**, each
covering its own change — two changes to one passage owe two answers.

**Where it is produced and gated.** In one artifact, written **once against the frozen final text**
and **reviewed before any replacement text is written**, as a Gate-A review under this story's
profile with a clean pass as its acceptance condition and no replacement text on failure. A finding
there **feeds back** rather than being absorbed. **The plan carries the passage list and executes
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
- **Parity across every changed rule**, in both copies, since they already diverge and parity
  cannot be asserted from a whole-section diff.
- **A fresh twelve-item `docs/prompt-standards.md` pass** over every changed prompt region, with
  **item 7 read against the whole resulting prompt** — a contradiction is a relation between an
  edited passage and an unedited one.

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
