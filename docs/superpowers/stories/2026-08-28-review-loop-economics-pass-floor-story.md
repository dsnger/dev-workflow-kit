# Review-loop economics: pass floor, severity semantics, and the §5 loop-rule consolidation — Story

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
  (`CLAUDE.md:157-159`). The substance converged and the number did not.
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

Three outcomes, each observable in the shipped prompt text.

1. **A cycle's mandatory pass count reflects what the story is worth reviewing**, instead of
   charging every cycle the same three passes per gate. A story the profile puts at level 0
   stops paying a toll that buys nothing; a standard or high story keeps the floor it has
   today.
2. **Severity means product behaviour.** A reader of either §5 copy can decide, without
   judgement calls, whether a finding about narration, about prose describing a mechanism, or
   about a test instrument's internals is allowed to hold the loop open — and knows the one
   case where an instrument finding still must (it demonstrates a false green on product
   behaviour). Coverage-first is unchanged: the reviewer still reports everything, and the
   filter stays ours.
3. **The §5 loop rules stop being amended one clause at a time.** The six open contract
   questions the `fic2` cycle raised and declined to answer get one coherent answer, taken
   together, with Daniel's five recorded decisions as settled inputs. The alternative —
   answering them as they surface — is what produced two stop-and-surfaces and a revert
   inside a single cycle.

**Why now, and why together.** Parts 1 and 2 each change what a loop is allowed to do; part
3 is the accumulated debt of changing that a clause at a time. Shipping them separately would
reproduce the churn this story exists to end, which is why the consolidation is the
deliverable rather than a convenience.

**Named out of scope**, so no criterion below absorbs them:

- **Hook code.** No change to any file under `plugins/dev-workflow/hooks/`. Part 1 is
  prompt-only policy over the already-shipped `.context/codex-gate.floor` knob (Daniel,
  2026-08-27). If design concludes prompt-only cannot hold, that is a stop-and-ask, not a
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
- **The economic measurement itself** — whether loops actually got cheaper. It cannot be
  observed inside this cycle: the severity rule's effect appears only across several cycles
  run under it, and claiming otherwise from a single cycle would be the fabricated-evidence
  failure §5 names. It is **deferred to a named vehicle rather than to a new backlog row** —
  `docs/superpowers/stories/2026-08-04-passive-metrics-over-the-ledger-story.md` (the P8
  passive-metrics story, `todos.md:546`), annotated with this trigger: after roughly three
  profiled cycles under the new rules, read their pass counts and finding distributions
  against the `fic2` baseline curve of 14 · 24 · 12 · 3 · 6 · 6 · 2
  (`docs/field-reports/2026-08-26-fic2-cycle-evidence.md`). A named vehicle rather than a
  fresh row because loose deferred items rot here — the pass-counter anomaly, the
  fixture-per-predicate question and the durations row's missing control run are all still
  open, and all three are named above or in §1.

## 3. Acceptance criteria

- [ ] **The floor scales by profile, on one predicate, and both copies say which gates it
      moves.** `CLAUDE.md` §5 and the `/workflow-init` inline template mirror each state a
      mandatory pass floor of **1** where `max(risk, security)` is 0 and **3** otherwise —
      unprofiled cycles included, which keep today's 3. Two levels, not three: `high` gets no
      extra mandatory passes, taking its added rigor from lens sets and evidence mode instead.
      Each copy also states that this one value governs **Gate A and Gate B alike**, which is
      not decoration: `codex-gate.sh:119` sets a single `floor`, consumed at `:946` for Gate B
      and at `:966` for Gate A.
      **One predicate, not two** (Daniel, 2026-08-28). An earlier draft added a `docs-only`
      arm; it is dropped because it does no work and, read path-wise, does the wrong work.
      A diff-derived reading cannot serve Gate A at all — Gate A runs on a spec, before any
      diff exists. A story-declared reading is already subsumed: intake defines `trivial` as
      "no behavioural effect in the artifact's own execution context", which a documentation
      change has none of. And a path-derived arm would be **wrong in this repo specifically** —
      `docs/hardening-log.md` is a `docs/**.md` path that drives rung escalation, so "docs"
      does not imply "changes nothing". That is Section A's reachability test deciding a floor
      question, which is why the two parts belong in one change.
- [ ] **Every cycle's closing commit body carries its per-pass shape — all three cycle types.**
      Both copies require the **Gate-A spec loop** (in the spec's commit body), the **Gate-A
      plan loop** (in the plan's commit body) and the **Gate-B cycle** (in the closing amend) to
      record that loop's per-pass finding and Blocker counts, in one pinned greppable form,
      following the `3cdd075` precedent
      (`Findings 14, 24, 12, 3, 6, 6, 2. Blockers 3, 4, 0, 0, 0, 0, 0.`). Checkable: the
      requirement is stated in both copies, and this story's own commits carry it for each loop
      that ran.
      **All three, not Gate B alone** (revised 2026-08-28 after Gate-A pass 2). A Gate-B-only
      requirement would leave the *dominant* cost unmeasured: the loops this story cites as
      evidence are Gate-A loops — nineteen measured Gate-A passes on one spec, and this story's
      own Gate-A run — so P8 without Gate-A curves cannot measure the thing the problem
      statement is about.
      **Why it is in scope** (approved as a scope addition, Daniel, 2026-08-28): the deferred
      economics measurement routed to P8 is otherwise answerable only for cycles whose author
      happened to write the curve down — `3cdd075` and `baa75c1` did, `7bbdb14` recorded the
      pass total and no distribution — because the findings files behind those numbers live
      under gitignored `.context/`. It is also the durable half of Q6: a curve in a commit body
      survives a fresh checkout, a cleared `.context/` and a different machine.
- [ ] **Every cycle's floor leaves a trace in history, default or not.** Both copies require a
      cycle to record `floor N per <cited story path>` in its closing commit body — one entry
      per cited story — and, where a workspace knob set by the user diverges from the profile
      derivation, to record both: `floor N per workspace knob; profile derivation M per <cited
      set>`. Checkable: the requirement is stated in both copies, and this story's own closing
      commits carry it.
      **Every cycle, not only a non-default one** (revised 2026-08-28 after Gate-A pass 2).
      An earlier wording required the line only for a non-default floor, which contradicted
      criterion 9 — this story is risk `high` and runs at the default 3, yet must demonstrate
      the provenance path. It also made an absent line ambiguous between "default floor" and
      "someone forgot", and left the user-knob divergence with nowhere to be disclosed.
- [ ] **The gate-off residual is named in the shipped text, not merely avoided.** Both copies
      state that the floor value is agent-written, lives in per-clone gitignored state that no
      reviewer sees in a diff, and that nothing verifies the written value against the story
      profile — and that a floor of 1 is therefore the cheapest available gate-off lever.
      Checkable by reading. This is a disclosure, not a guard: no mechanism is claimed for it.
- [ ] **Severity is pinned as a closed decision in both copies, keyed on consequence, with the
      carve-out stated at the same place.** Both state that Blocker and Major claim product
      behaviour, an invariant, or a contract, and both state the deciding test: **name the
      in-system reader of this text — a gate, skill, rule, escalation procedure or scaffolded
      template — and the decision it takes differently if the text is wrong; if you can name
      neither, the finding is Minor, collect and never iterate.** A human reader never
      satisfies the test. Findings about narration, prose describing a mechanism, and test
      instrument internals appear as **worked examples of that test, not as a second rule
      beside it** — a copy stating a categorical demotion by subject *and* the test fails this
      criterion, because two procedures can disagree on one finding.
      **The instrument carve-out runs in both directions:** an instrument finding keeps its
      severity when it shows the instrument changes what the gate concludes about product
      behaviour — a false green, and equally a false red or a check that blocks a valid change.
      Naming only false green would demote a check that fails for wiring reasons and costs a
      correct change.
      Both copies also still state that the reviewer reports every finding with severity and
      confidence and that the filter is applied downstream by us; a copy that drops
      coverage-first fails this criterion even if the severity rule is correct.
      *(Revised 2026-08-28 after Gate-A pass 2 found this criterion still describing the
      pre-decision form — artifact-kind demotion with a false-green-only carve-out — which no
      implementation could satisfy alongside the settled contract. Encodes the settled
      consequence-keyed decision and the bidirectional carve-out; sparring session, under
      Daniel's 2026-08-28 delegation.)*
- [ ] **Each of Q1–Q6 is answered or rejected in the shipped text, with a reason, and the
      answers do not contradict each other.** Q1 (clean-completion precedence), Q2 (a declined
      expansion's exit), Q3 (scope stop vs. clean completion), Q4 (whether a decline binds
      later passes in the same cycle), Q5 (whether the three universal rules may carry an
      in-set qualification), Q6 (what the pass-4 report does when prior-pass history is
      unavailable) — as stated in `docs/field-reports/2026-08-26-fic2-cycle-evidence.md`. Where
      an answer qualifies one of the three universal rules — the Blocker/Major-resolve duty,
      the rule that a surfaced finding stays open with resolution unwaived, and the rule that
      no pass carrying it counts as clean — the qualification appears **at each of those three
      rules** in both copies, not only at the new clause. Q2 was reverted last cycle precisely
      because that did not happen.
- [ ] **Every condition of the replaced prose is accounted for.** The change lists what each
      replaced §5 passage required and marks each requirement kept, moved, or deliberately
      dropped, per the AGENTS.md Don't quoted in §4. Checkable: the accounting exists and
      covers every rule the diff rewrites. The failure this guards against has occurred: the
      profiles cycle lost conditions ten times, once making an eligible profile *sufficient*
      for a Gate-B skip — the gate-off path that change existed to close.
- [ ] **The two copies stay in parity.** Every rule this story changes reads the same in
      `CLAUDE.md` §5 and in the `/workflow-init` template, except where a wording difference is
      deliberate and stated as such. Checkable by diffing the two regions.
- [ ] **The provenance path is demonstrated end to end on this branch, at the floor this
      branch actually licenses.** This story is risk `high`, so every cycle citing it owes
      floor **3** — and its closing commit body carries `floor 3 per <story path>`, showing the
      derivation and the provenance line working at a real value.
      **The floor-1 demonstration is not on this branch, deliberately.** It was in an earlier
      draft and was unsatisfiable: a criterion demanding a floor-1 cycle here contradicts this
      story's own profile, and the only way to satisfy it as written would have been to mint a
      level-0 micro-story for the purpose — a fixture built to make a criterion pass, which is
      the fabricated-evidence class §5 names. Instead the floor-1 case becomes the **first
      checkpoint of the P8 measurement**: the first post-merge cycle whose cited-story set
      licenses floor 1 must carry the floor-1 provenance line, and P8 reads it.
      **What is demonstrated here stays bounded, and the wording forecloses reading it wider:**
      the derivation, the knob and the provenance path work. It is not evidence that review
      loops became cheaper. Reading a working mechanism as an improved outcome is the overclaim
      class AGENTS.md names as this repo's most persistent defect, and the economics are
      measured afterwards by the follow-up named in §2.
      *(Revised 2026-08-28 after Gate-A pass 1 found the original unsatisfiable — sparring
      session, under Daniel's 2026-08-28 delegation; flagged to Daniel for final-version review
      because criterion 8 was his explicit choice. The falsifiability he chose is preserved by
      the §8 differential verification, the provenance line now, and the P8 checkpoint later.)*

## 4. Affected AGENTS.md invariants

- `## Hook` — "**The hook always exits 0.** It is advisory; a reminder that can fail closed
  would make the workflow unusable whenever Codex is down or the environment is odd." The
  prompt-only decision for part 1 rests on this: today's floor of 3 is already advisory, so an
  agent-written floor adds no new enforcement class.
- `## Hook` — "**Loose in the firing direction.** On uncertainty, fire. A missed commit
  (false ✓) is the dangerous direction; a redundant warning is the accepted price." Lowering a
  floor moves against this direction, which is what the residual-risk criterion discloses.
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
  deliberately dropped." This is the governing constraint on part 3 and the basis of its
  criterion.
- `## Don'ts` — "**Never describe what a gate proves without checking what it actually
  compares.**… for every sentence about a gate, name the exact comparison the code performs,
  and delete any part of the sentence that outruns it." Every sentence this story writes about
  what a floor or a severity class *does* is subject to it.

## 5. Open questions

- **Which floor governs a cycle citing several stories with different profiles?** §5 already
  aggregates the other dimensions explicitly — the battery runs once, each profiled story
  satisfies its own mode, lens sets are unioned, skip-eligibility requires unanimity — and a
  scaled floor adds a dimension with no aggregation rule. Lowest, highest, and per-story are
  all defensible and they disagree.
- **Does a profile change mid-cycle move the floor for passes already run?** §5 makes the
  story header the single writable copy, read fresh at each pass, and says passes run under a
  lower profile keep counting toward the floor. If the floor itself is now profile-derived, a
  mid-cycle raise changes the target after some passes are already banked.
- ~~**What floor does an unprofiled cycle get?**~~ **Answered 2026-08-28** by the
  single-predicate decision in criterion 1: no profile means `max(risk, security)` is not 0,
  so the default of 3 stands. Kept rather than deleted, because the answer is only obvious
  once the predicate is one thing.

## 6. Suggested size

`story` — three parts, but one coherent change to one subsystem's rules in two mirrored
copies. Part 3's value *is* being done once; splitting it would reproduce the clause-by-clause
churn the story exists to end.
