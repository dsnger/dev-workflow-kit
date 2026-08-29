# Review-loop economics: pass floor and severity semantics — Story

**Date:** 2026-08-28 · **Size:** story
**Risk:** high · **Security:** none · **Validation:** battery+check+verification

## 1. Problem statement

Development drags. Review loops are opaque for minutes to hours at a stretch, and
Blocker/Major assessment is mis-calibrated, so a loop burns passes on trivia and on its
own test instruments before any product behaviour has been examined. (Daniel, 2026-08-26.)

Four measurements, each citable:

- **Loops do not converge on count.** In the kit's heaviest consumer, one design spec past
  2800 lines ran nineteen measured Gate-A passes; findings fell from 43 into a 2–19 range
  after pass 6 and never reached zero, while Blockers fell from 11 to 0–1 from pass 7 on
  (`CLAUDE.md:157-159`). **What that shows is that the count did not converge — and not that the
  substance did.** Reading a falling Blocker curve as convergence is an inference
  `docs/hardening-log.md` retracted at entries 78, 84, 85 and 87, and `CLAUDE.md` says in the same
  paragraph that neither curve measures coverage, so a low count can sit beside an unreviewed
  subsystem. The measurement is the numbers; the convergence reading is not part of it.
- **Severity lands on the instrument, not the product.** PR #23's closing commit records
  that "of 27 Blocker/Major findings, 16 were in the never-committed scratch harness, 10 in
  the design spec's narration, 1 in the plan" (`7bbdb14`, quoted at `todos.md:268-270`) —
  16 of 27 on the instrument, in that row's own summary of it.
- **The most recent cycle reproduced both.** Gate-B cycle `fic2` ran findings 14 · 24 · 12 ·
  3 · 6 · 6 · 2 across seven passes. The pass-2 spike was caused by mid-cycle scope
  expansion; pass 5 returned **zero** product-behaviour findings and still cost a full pass
  each on two branches. Two mandatory stop-and-surfaces, one revert, and two false
  counterfactuals that each survived a full clean pass before the next one caught them.
  (`docs/field-reports/2026-08-26-fic2-cycle-evidence.md`.)
- **Individual passes are slow.** Five Gate-A passes of the 2026-08-03 round ran 458 s,
  550 s, 757 s, 663 s and 780 s (`todos.md:463-469`). That row states its own limit and this
  story carries it unchanged: **no control run was made**, so this is a correlation observed
  under one setting, not a demonstration of what caused those durations.

A three-pass floor is charged to every cycle regardless of what the change is worth
reviewing, so a story with no behavioural surface pays the same toll as one that rewrites a
gate.

**A worked example of the same class, found while writing this story.** The brief that
commissioned it cited "34 Gate-A passes on one 2848-line spec" against the 2026-08-17 ledger
row. That row says exactly that, and it has been superseded five times
(`docs/hardening-log.md:78,81,84,85,87`) — the line count is expressly excluded from the
consumer's evidence, and the pass total was taken from counting artifacts and then
attributed to a record that does not carry it. Supersession deliberately never alters a row,
so the row is still present, still matching its own grep, still counting, and still handing a
reader two retracted figures. Nothing was broken; the convention worked as designed. It is
recorded here as narrative evidence of what an opaque review record costs, not as a defect
this story repairs.

## 2. Desired outcome

Two outcomes, each observable in the shipped prompt text.

1. **A cycle's mandatory pass count reflects what the story is worth reviewing**, instead of
   charging every cycle the same three passes per gate. A story the profile puts at level 0
   stops paying a toll that buys nothing; a standard or high story keeps the floor it has
   today.
2. **Severity means product behaviour.** A reader of either §5 copy can decide, **by a stated
   test rather than by taste**, whether a finding about narration, about prose describing a
   mechanism, or about a test instrument's internals is allowed to hold the loop open — the
   test being whether an in-system reader takes a different decision if the text is wrong — and
   knows that an instrument finding still holds the loop open whenever it shows the instrument
   changes what the gate concludes about product behaviour, **in either direction**: a false
   green, and equally a false red or a check that blocks a valid change. Coverage-first is
   unchanged: the reviewer still reports everything, and the filter stays ours.
   *(Revised 2026-08-28 after Gate-A pass 3. Two corrections: this outcome still described the
   false-green-only carve-out that criterion 5 had already moved past; and "without judgement
   calls" promised more than any prose rule can deliver — a stated test removes arbitrariness,
   not judgement, and the spec says so plainly, so the story must not promise otherwise.)*
**Scope narrowed 2026-08-29 — the loop-rule consolidation moved to a successor story.** A third
outcome once sat here: answering the six open §5 contract questions in one coherent pass.
**Those answers are all decided and recorded**; what did not converge was writing them down. Gate-A
attribution over three consecutive passes measured it — parts 1 and 2 produced 4/1, 8/1 and 7/1
Blocker/Major while the loop-rule sections produced 10, 11 and 14 and rising, each repair creating
an interaction the next pass found. See
`docs/superpowers/stories/2026-08-29-loop-rule-consolidation-story.md`, which carries every
recorded decision as a settled input rather than reopening any of them.

**Why parts 1 and 2 still ship together.** They are not merely adjacent: part 2's reachability test
is what decides a part-1 question — a path-derived `docs-only` arm would be wrong here because
`docs/hardening-log.md` is a `docs/**.md` path that drives rung escalation. Splitting *those two*
would separate a rule from the argument that settles it.

**Named out of scope**, so no criterion below absorbs them:

- **Hook code.** No change to any file under `plugins/dev-workflow/hooks/`. Part 1 is
  prompt-only: the floor is derived from the profile and **stated in the text**, and the
  already-shipped `.context/codex-gate.floor` knob is neither read for that derivation nor written
  (Daniel, 2026-08-27; refined as the design settled). If design concludes prompt-only cannot hold, that is a stop-and-ask, not a
  silent expansion.
- **Gate-call observability** — upstream in `mcp-codex-dev`, a different repo.
- **The pass-counter anomaly.** During `fic2`, seven validated passes were reported by the
  hook as one. The cause is undiagnosed and diagnosing it needs hook-state inspection; it is
  its own finding.
- **The CodeRabbit plan-metadata contradiction** — a docs follow-up, and only after
  diagnosis.
- **The fixture-per-predicate question** — how much instrument a one-paragraph prose rule is
  worth. The evidence doc carries it as an open question, not a commitment.
- **Any remedy to the supersession convention** the worked example above illustrates. Parked
  as a `todos.md` candidate.
- **Whether loops actually got cheaper.** The honest form of that question is narrower than
  "measure the rule's effect", and the design says why: no finding is ever classified under both
  the old and new rules, so **no demotion figure is derivable** and what a later reader can compare
  is *recorded severity mixes across cycles that reviewed different artifacts* — evidence about the
  population as much as about the rule. It certainly cannot be observed inside this cycle, and
  claiming otherwise from one cycle would be the fabricated-evidence failure §5 names. It is
  **deferred to a named vehicle rather than to a new backlog row** —
  `docs/superpowers/stories/2026-08-04-passive-metrics-over-the-ledger-story.md` (the P8
  passive-metrics story, `todos.md:546`), annotated with this trigger: after roughly three
  profiled cycles under the new rules, compare their recorded severity mixes against the `fic2`
  baseline curve of 14 · 24 · 12 · 3 · 6 · 6 · 2, with both confounds named
  (`docs/field-reports/2026-08-26-fic2-cycle-evidence.md`). A named vehicle rather than a
  fresh row because loose deferred items rot here — the pass-counter anomaly, the
  fixture-per-predicate question and the durations row's missing control run are all still
  open, and all three are named above or in §1.

## 3. Acceptance criteria

- [ ] **The floor scales by profile, on one predicate, and both copies say which gates it
      moves.** `CLAUDE.md` §5 and the `/workflow-init` inline template mirror each state a
      mandatory pass floor of **1** only where the cited set is non-empty and every member is
      profiled, resolvable and at level 0; **3** where no story is cited or any member is
      unprofiled; and — stated, not left to a fallback — **a member whose profile is present but
      unresolvable stops and surfaces**, per §5's existing rule, rather than yielding 3. A copy
      that reads an unresolvable profile as 3 fails this criterion, because it converts a stop
      condition into a silent default. Two levels, not three: `high` gets no
      extra mandatory passes, taking its added rigor from lens sets and evidence mode instead.
      **A cycle citing several stories reaches the reduced floor only unanimously** — every
      cited story profiled, every one at level 0 — so a single higher-profile or unprofiled
      member returns the cycle to 3. Stated in both copies, and falsifiable: a copy silent on
      the multi-story case leaves the cheapest wrong reading available.
      **Every pass report states the floor it derived, the risk and security axes it read, and
      which cited stories it read them from**, so the value is
      visible while passes are still being spent rather than only in the closing commit.
      Each copy also states that **one derived value governs all three cycles** — the Gate-A spec
      cycle, the Gate-A plan cycle and the Gate-B cycle, which §5 defines as **three separate
      cycles** — and says *why*: they derive from **the same cited-story set**, not from being one
      cycle. A copy that states the floor for one gate and leaves the others to inference fails
      this criterion, and so does one that gives the shared-cycle reason, which is false.
      Both copies also state that — **for a cycle §5 says is still running a gate**, the scope the
      spec sets and which §5 alone decides — **a change to the cited set *or to any cited profile*
      requires the final clean pass to run against the current set and under the current profile,
      even when the floor number does not move** — a new member brings its
      lenses and evidence duties with it — and that **removing a citation never discharges an
      already accepted in-set Blocker or Major**, since acceptance and not the citation put it in
      the fix set.
      **One predicate, not two** (Daniel, 2026-08-28). An earlier draft added a `docs-only`
      arm; it is dropped because it does no work and, read path-wise, does the wrong work.
      A diff-derived reading cannot serve Gate A at all — Gate A runs on a spec, before any
      diff exists. A story-declared reading is already subsumed: intake defines `trivial` as
      "no behavioural effect in the artifact's own execution context", which a documentation
      change has none of. And a path-derived arm would be **wrong in this repo specifically** —
      `docs/hardening-log.md` is a `docs/**.md` path that drives rung escalation, so "docs"
      does not imply "changes nothing". That is the design's severity test (part 2) deciding a floor
      question, which is why the two parts belong in one change.
- [ ] **Every cycle's closing commit body carries its per-pass shape — all three cycle types.**
      Both copies require the **Gate-A spec loop** (in the spec's commit body), the **Gate-A
      plan loop** (in the plan's commit body) and the **Gate-B cycle** (in the closing amend) to
      record that loop's per-pass **Findings, Blockers and Majors**, in one pinned greppable form,
      following the `3cdd075` precedent
      (`Findings 14, 24, 12, 3, 6, 6, 2. Blockers 3, 4, 0, 0, 0, 0, 0.`). The form is complete
      enough that a reader can tell **which pass each number belongs to** — incomplete passes are
      excluded and they consume pass numbers — and **which model each pass ran under**, which an
      existing convention already requires beside a finding count. A **legitimately skipped** loop
      records the skip rather than leaving a silent gap. **A count that cannot be recovered is
      recorded as unknown rather than as zero, per series** — a pass may have one series lost and
      the others intact — and a reader excludes an unknown value only from the comparisons that
      read it. Both copies also state when separate calls
      are **one logical pass**: only when they reviewed the **same tracked revision** — and that a
      revision mismatch **ends the first as an incomplete pass** before the later one starts a new
      pass, rather than merging two revisions into a single entry. Checkable: the requirement is
      stated in both copies, and this story's own commits carry it for each cycle that ran —
      **every field of the pinned form except the identifier, which no cycle on this branch can
      supply.** Those records carry the reserved pre-rule value, which by construction **does not
      name a cycle**; what the branch demonstrates is the field's presence and grammar, not
      attribution (see the identifier criterion).
      **All three, not Gate B alone** (revised 2026-08-28 after Gate-A pass 2). A Gate-B-only
      requirement would leave the *dominant* cost unrecorded: the loops this story cites as
      evidence are Gate-A loops — nineteen measured Gate-A passes on one spec, and this story's
      own Gate-A run — so P8 without Gate-A curves would be comparing the smaller half of what the
      problem statement is about.
      **Why it is in scope** (approved as a scope addition, Daniel, 2026-08-28): the deferred
      economics comparison routed to P8 is otherwise answerable only for cycles whose author
      happened to write the curve down — `3cdd075` and `baa75c1` did, `7bbdb14` recorded the
      pass total and no distribution — because the findings files behind those numbers live
      under gitignored `.context/`. It is also the durable half of Q6: a curve in a commit body
      survives a fresh checkout, a cleared `.context/` and a different machine.
- [ ] **Every cycle's floor is reconstructible from history alone, default or not.** From a
      cycle's closing commit body, without consulting the spec or any per-clone state, a reader
      can determine: **which floor §5 obliged**, **which stories derived it**, and — where a
      user's workspace knob was set — **that its number is the hook's reminder threshold and not
      the obligation**. Every cycle, so an absent record is never ambiguous between "the default
      applied" and "someone forgot". The record is **machine-extractable**, because the deferred
      P8 measurement reads it; both copies pin one form, and the spec states which.
- [ ] **The gate-off residual is disclosed in the shipped text, not merely avoided.** A reader of
      either copy learns, without inferring it: **that the floor a cycle owes is produced by the
      agent rather than established by any mechanism**; **that nothing checks it against the
      cited profiles**; and **by what specific routes it can therefore be wrong** — the routes
      enumerated, and the enumeration stated as a floor rather than as a complete list. The text
      claims **no guard**: a reader must not be able to come away believing the residual is
      mitigated by anything the design ships. Checkable by reading either copy.
      **And both copies oblige the agent to leave the user's floor knob alone** — never written,
      never removed by any rule this change ships; where one exists a cycle discloses it rather
      than acting on it. Observable on this branch: a knob present before a cycle is byte-identical
      after it.
- [ ] **Severity is decided by one stated test in both copies, and the test is keyed on
      consequence.**
      Five properties, each checkable by reading either copy.
      **(a)** Exactly **one** procedure decides severity. A copy that states a categorical
      demotion by subject *alongside* the test fails, because two procedures can disagree on one
      finding; subject-based cases may appear only as worked examples of the test.
      **(b)** The test requires **both** halves to be nameable: **what in the system consumes the
      text**, and **the decision it takes differently** if the text is wrong. Failing to name
      either makes the finding Minor-or-below. It does not turn on what kind of file the text
      lives in, nor on a human reader, whose cost §5's prose exemption already prices as
      non-gating. A copy demoting only when *both* are absent inverts the rule.
      **(c)** The instrument carve-out is **symmetric**: an instrument finding keeps its severity
      whenever it shows the instrument changes what a gate concludes about product behaviour,
      in **either** direction. A copy naming only a false green fails, because it would demote a
      check that fails for wiring reasons and costs a correct change.
      **(d)** Coverage-first survives: the reviewer still reports every finding with severity and
      confidence, and the filter is ours. A copy that drops this fails even if (a)–(c) hold.
      **(e)** **The pass raising a finding is not an in-system reader of the text it is
      reviewing.** Without this the test demotes nothing — any review finding could name the
      review itself as the reader — so a copy stating (a)–(d) and omitting (e) fails. Gates must
      remain legitimate readers of rule text they will later apply; what is excluded is the
      reviewing pass, not gates.

- [ ] **A cycle's records can be told apart from another cycle's.** Both copies require **each
      cycle started after these rules ship** to hold an identifier created at its start, unique
      among cycles open when it was generated, and present in **a named set of records** — the
      provenance line, the per-pass curve (or the skip record standing in for one), the cycle's
      findings slots, and its advisory working record — **and not required in records this change
      neither introduces nor keys to a cycle**, so a reader can tell whether a given record is in
      scope — **one per cycle, so a run of all three holds three**. Both copies also state the **bounded, self-terminating exception**:
      a cycle already running when the rules land has no identifier, cannot acquire one, and writes
      a reserved value that says so — and no later cycle can enter that state. They
      state how it is recovered by a cycle resumed after an interruption, what happens when it
      cannot be recovered unambiguously, that a cycle does not start without one, and that a slot
      another cycle owns is refused rather than overwritten. Checkable by reading either copy, and
      **What this branch can and cannot demonstrate, stated rather than assumed:** its three cycles
      all began before these rules ship, so each closing body carries the reserved pre-rule cycle
      field and **none of them demonstrates a real identifier**. The branch demonstrates the field's
      presence and grammar; **a future cycle demonstrates a real one and the attribution it buys** —
      the obligation is recorded at implementation and discharged by **any** cycle that both starts
      under these rules and closes — not assigned in advance to a cycle that concurrent siblings and
      a possible revert make impossible to name, and not to "the first", which concurrent closers
      cannot agree on. A duplicate discharge is harmless and allowed.
- [ ] **The shipped text says when it starts binding, and what an adopter gets when it does not
      fully arrive.** Both copies state: that a loop already running finishes under the rules it
      started with; what a loop does when its starting rules cannot be established, covering
      **every part this change touches and not the floor alone**; and that a downstream project
      adopts by re-running the scaffolder, which may write nothing, be declined, or be merged in
      part — with the consequence of a partial adoption stated rather than assumed away.
      Checkable by reading either copy.
- [ ] **The change leaves no shipped sentence contradicting it, and the package it ships in is
      valid.** Every user-facing statement this change falsifies is corrected in the same change —
      a reviewer can check each corrected line against the site list the plan carries — and the plugin
      manifest's version and `CHANGELOG.md` are updated. Both are checkable after the fact: no
      corrected sentence still asserts a fixed three-pass floor, and the manifest version differs
      from its value on the base ref. **Only the version bump is CI-enforced** — the changelog
      entry is this repo's convention and nothing checks it, so this criterion is what carries it.
      **Prompt conformance is judged item by item, and this change records exactly one n/a**:
      item 1 for the scaffolded `CLAUDE.md`, because that artifact is model-agnostic by design and
      a target-model line would be false in every repo it lands in. **Every other item binds it,
      and every item binds the outer command prompt.** An n/a is admissible only where the reason
      **establishes that the item cannot truthfully be met** — the answer `AGENTS.md`'s commands
      table already gives; "we would rather not" is not such a reason. What fails this criterion is
      an item left unanswered, answered falsely, or answered n/a on a reason that does not hold.
- [ ] **Every condition of the replaced prose is accounted for.** The change lists what each
      replaced §5 passage required and marks each requirement kept, moved, or deliberately
      dropped, per the AGENTS.md Don't quoted in §4. Checkable: the accounting exists and
      covers every rule the diff rewrites. The failure this guards against has occurred: the
      profiles cycle lost conditions ten times, once making an eligible profile *sufficient*
      for a Gate-B skip — the gate-off path that change existed to close.
- [ ] **The two copies stay in parity.** Every rule this story changes reads the same in
      `CLAUDE.md` §5 and in the `/workflow-init` template, except where a wording difference is
      deliberate and stated as such. Checkable by diffing the two regions.
- [ ] **The provenance path is demonstrated on this branch as far as this branch can demonstrate
      it, at the floor it actually licenses.** Not "end to end": two fields are out of reach here
      and the criterion names both rather than claiming coverage it lacks — the **cycle identifier**
      (every cycle here predates the rule) and the **user-knob clause's non-absent form** (this
      workspace has no knob, so the design's conditional verification records not-applicable rather
      than satisfied). Every other field is shown. This story is risk `high`, so every cycle citing it owes
      floor **3** — and its closing commit body carries a provenance line **in the one pinned form**,
      recording that floor and this story at its level, so the derivation and the line are shown
      working at a real value. **The cycle field is the one it cannot demonstrate**: every cycle on
      this branch predates the identifier rule, so each carries the reserved pre-rule value, which
      by construction attributes nothing. This branch shows the line's derivation, its grammar and its
      remaining fields; **attribution is demonstrated at the checkpoint named in the identifier
      criterion**, not here.
      **The floor-1 demonstration is not on this branch, deliberately.** It was in an earlier
      draft and was unsatisfiable: a criterion demanding a floor-1 cycle here contradicts this
      story's own profile, and the only way to satisfy it as written would have been to mint a
      level-0 micro-story for the purpose — a fixture built to make a criterion pass, which is
      the fabricated-evidence class §5 names. Instead the floor-1 case becomes the **first
      checkpoint of the P8 comparison**: the first post-merge cycle whose cited-story set licenses
      floor 1 must carry the floor-1 provenance line, and P8 reads it.
      **What is demonstrated here stays bounded, and the wording forecloses reading it wider:**
      the derivation and the provenance path work. It is not evidence that review
      loops became cheaper. Reading a working mechanism as an improved outcome is the overclaim
      class AGENTS.md names as this repo's most persistent defect, and the economics are
      compared afterwards by the follow-up named in §2 — compared, because §2 explains why no
      measurement of the rule's effect is derivable from what the record carries.
      *(Revised 2026-08-28 after Gate-A pass 1 found the original unsatisfiable — sparring
      session, under Daniel's 2026-08-28 delegation; flagged to Daniel for final-version review
      because the provenance-demonstration criterion was his explicit choice. The falsifiability he chose is preserved by
      the design's §8 differential verification, the provenance line now, and the P8 checkpoint later.)*

## 4. Affected AGENTS.md invariants

- `## Hook` — "**The hook always exits 0.** It is advisory; a reminder that can fail closed
  would make the workflow unusable whenever Codex is down or the environment is odd." The
  prompt-only decision for part 1 rests on this: the hook's floor was only ever a reminder
  threshold, and §5's text is what obliges an agent — so deriving the floor in the text adds no
  new enforcement class and removes none.
- `## Hook` — "**Loose in the firing direction.** On uncertainty, fire. A missed commit
  (false ✓) is the dangerous direction; a redundant warning is the accepted price." This is what
  licenses the accepted cost: a level-0 cycle draws a hook reminder its derived floor does not
  owe, and a redundant warning is the price named here. Teaching the hook to fall silent would
  be the false ✓ the same sentence calls dangerous.
- `## Prompts and scaffolding` — "**`/workflow-init` never overwrites silently.** Idempotent:
  missing → write; identical → report unchanged; present and different → show the diff and ask."
  This is why a downstream project adopts by re-running the scaffolder and can sit on a partial
  adoption — the spec's rollout section rests on it.
- `## Prompts and scaffolding` — "**The base taxonomy stays stack-neutral.** Project vocabulary…
  goes only in that project's `docs/hardening-taxonomy.md`… Otherwise one project leaks into every
  other." The severity test ships into projects whose reader kinds we have never seen, which is
  why its list of readers is illustrative rather than closed.
- `## Prompts and scaffolding` — "**`/workflow-init`'s templates stay inline** in the command
  body." The mirror edit lands in the command body, never in a file read from disk.
- `## Prompts and scaffolding` — "**Prompt changes pass `docs/prompt-standards.md`** — all 12
  checklist items… **no comprehensive mechanical checker exists for them**: review is the
  gate." Named because one of the three narrow checks that *do* exist is "the finding-severity
  vocabulary stated as a closed set in both prompt copies", which part 2 edits directly.
- `## Packaging` — "**A plugin change requires a version bump.** A pull request that changes
  any path under a `plugins/<name>/` directory **that still exists at HEAD**… must also change
  that plugin manifest's `version`, or CI fails." The template mirror is under
  `plugins/dev-workflow/`, so this fires.
- `## Don'ts` — "**Never replace a decision procedure without accounting for its old
  conditions.** List what the previous prose required, then mark each one kept, moved, or
  deliberately dropped." This is the governing constraint on the accounting and the basis of its
  criterion.
- `## Don'ts` — "**Never describe what a gate proves without checking what it actually
  compares.**… for every sentence about a gate, name the exact comparison the code performs,
  and delete any part of the sentence that outruns it." Every sentence this story writes about
  what a floor or a severity class *does* is subject to it.

## 5. Open questions

- ~~**Which floor governs a cycle citing several stories with different profiles?**~~
  **Answered 2026-08-28: unanimity.** Floor 1 only if the cited set is non-empty and every member
  is profiled, resolvable and at level 0. A set with no story or any unprofiled member yields 3;
  **a set containing a present-but-unresolvable profile stops and surfaces** rather than yielding
  anything. It follows §5's own precedent for the analogous
  relaxation — "skip-eligible only if **every** cited story is" — and it is the only reading
  consistent with invariant 2's firing direction, since a lowest-cited-floor rule would
  under-review a cycle that also touches a high-risk story.
- ~~**Does a profile change mid-cycle move the floor for passes already run?**~~
  **Answered 2026-08-28**, and it needed no new rule — three existing ones compose. The floor
  derives from the current profile at each pass; passes already run keep counting; closing
  requires the floor as currently derived. The consequence worth stating is that **any profile
  change costs at least one further clean pass, in either direction and whether or not the floor
  number moves**, because §5 already requires the final clean pass to run under the current
  profile — so no already-banked pass can be it.
- ~~**What floor does an unprofiled cycle get?**~~ **Answered 2026-08-28** by the
  single-predicate decision in criterion 1: no profile means `max(risk, security)` is not 0,
  so the default of 3 stands. Kept rather than deleted, because the answer is only obvious
  once the predicate is one thing.

## 6. Suggested size

`story` — two coupled parts, one change to one subsystem's rules in two mirrored copies.

**This note said the opposite until 2026-08-29, and the correction is worth keeping.** It read:
"Part 3's value *is* being done once; splitting it would reproduce the clause-by-clause churn the
story exists to end." **That reasoning was about the contract questions**, which were genuinely
entangled — answering one moved the others — and it was right about them. They are now all settled
and recorded, so the entanglement it described has been paid for.

**What did not converge was a different problem with a different remedy.** Eleven Gate-A passes
never brought Blocker/Major below 22, and the last three attributed 10, 11 and 14 of them to the
loop-rule sections while parts 1 and 2 held at 4/1, 8/1 and 7/1. Each repair to one loop rule
created an interaction the next pass found — density among shipped rules, not entanglement among
open questions. Splitting is the standard remedy for the first and the failure mode for the second,
which is why the same story can correctly refuse a split and then correctly take one.
