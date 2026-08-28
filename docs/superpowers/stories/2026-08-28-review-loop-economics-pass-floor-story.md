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
reviewing, and a docs-only or trivial story pays the same toll as one that rewrites a gate.

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
   charging every cycle the same three passes per gate. A trivial or docs-only story stops
   paying a toll that buys nothing; a standard or high story keeps the floor it has today.
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

## 3. Acceptance criteria

- [ ] **The floor scales by profile, and both copies say which gates it moves.** `CLAUDE.md`
      §5 and the `/workflow-init` inline template mirror each state a mandatory pass floor of
      **1** for a trivial or docs-only cycle and **3** otherwise, and each states that this one
      value governs **Gate A and Gate B alike**. Two levels, not three: `high` gets no extra
      mandatory passes, taking its added rigor from lens sets and evidence mode instead.
      Checkable by reading both copies. The two-gates clause is not decoration —
      `codex-gate.sh:119` sets a single `floor`, consumed at `:946` for Gate B and at `:966`
      for Gate A — which is why the docs-only arm is phrased as a **Gate-A** claim in both
      copies: a docs-only cycle already has no Gate B to floor.
- [ ] **A non-default floor leaves a trace in history.** Both copies require a cycle that ran
      a floor other than the default to record `floor N per <story path>` in its closing
      commit body. Checkable: the requirement is stated in both copies, and any cycle in this
      story's own branch that runs a reduced floor carries the line.
- [ ] **The gate-off residual is named in the shipped text, not merely avoided.** Both copies
      state that the floor value is agent-written, lives in per-clone gitignored state that no
      reviewer sees in a diff, and that nothing verifies the written value against the story
      profile — and that a floor of 1 is therefore the cheapest available gate-off lever.
      Checkable by reading. This is a disclosure, not a guard: no mechanism is claimed for it.
- [ ] **Severity is pinned as a closed decision in both copies, with the carve-out stated at
      the same place.** Both state that Blocker and Major claim product behaviour, an
      invariant, or a contract, and that a finding whose subject is narration, prose about a
      mechanism, or a test instrument's internals is **Minor** — collect, never iterate —
      **except** an instrument finding that demonstrates a false green on product behaviour,
      which keeps its severity. Both also still state that the reviewer reports every finding
      with severity and confidence and that the filter is applied downstream by us; a copy that
      drops coverage-first fails this criterion even if the severity rule is correct.
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
- **What floor does an unprofiled cycle get?** §5 has three defined cases for an unresolvable
  or absent profile; the default of 3 is the obvious answer, but it is currently unstated.

## 6. Suggested size

`story` — three parts, but one coherent change to one subsystem's rules in two mirrored
copies. Part 3's value *is* being done once; splitting it would reproduce the clause-by-clause
churn the story exists to end.
