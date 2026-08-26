# The arms-race remedy as a procedure, not an observation — Story

**Date:** 2026-08-17 · **Size:** story

**Unprofiled, deliberately.** This story is a split from a field-intake round, not a raw idea,
so it did not pass through `dev-workflow:intake` — intake excludes items that have moved into
solution design. A profile is proposed and human-confirmed at intake time. Writing one here
would produce a header that **looks** confirmed and is not, and nothing would reveal that:
`CLAUDE.md` §5 stops on a profile that is malformed or internally inconsistent, not on one whose
values are well-formed but unconfirmed. Same reasoning, and the same debt-as-criterion answer, as
`2026-08-04-harden-finding-guard-scope-precheck-story.md`, which this story inherits from.

## 1. Problem statement

A series of review passes can stop converging without any single pass looking wrong: each
correction closes the findings it was aimed at and enables the next findings of the same shape,
so the count oscillates and same-shape lineages recur across passes. What that does **not**
establish is that the artifact is finished — the same record states that coverage was never
measured and that a low Blocker count can coexist with an unreviewed subsystem, so "the substance
has converged" is exactly the clearance inference this repo now forbids at the §5 exit. The field
has a name for the pattern — the instrument is checking at the wrong level — and a remedy that
worked: change what is being checked rather than patch once more, and stop with a named state.

The kit has part of it, as of the same change that parks this story, and the gap is what remains.
`CLAUDE.md` §5 now carries **one** recognition heuristic and a terminal action: read the Blocker
curve across passes rather than any single total, and surface the stuck state only on three
conditions together — a visible plateau, an affirmative sufficient-coverage judgement, and
Blocker/Major findings that keep regenerating across repair attempts, with a clean pass taking
precedence over the exit. (Six passes is where the field observed a plateau, not a point at which
stopping becomes authorized.) That covers a *review loop over one artifact* and nothing else. What has
no home is the general case — a series of passes over an **instrument** that keeps finding one
more spelling its own claim text seemed to cover — and, with it, the **moves** (scope the reviewer
to changed regions, change the instrument's layer, relocate the residual to the layer that already
catches it), the **integration with the rung ladder**, and the **durable named state** the stop
should leave behind. `harden-finding` still escalates one rung when a fingerprint recurs, and that
rule mis-reads this case: one more arm of the same rung is the same rung applied again, which the
kit's own parked invariant-checker row states locally ("adding one more regex arm per
newly-discovered spelling is *not* the ladder working") and nowhere generally.

**So this story either extends or replaces a decision path that now exists**, and it must say
which. The §5 heuristic is not to be silently superseded: whoever takes this up lists what that
paragraph requires today and marks each condition kept, moved or dropped, the same accounting
`AGENTS.md` demands of any decision-procedure rewrite. **That inventory covers both stop paths,
not just the recurrence step and the "clearly stuck" clause**: the pass-4-onward reporting duty
ships in the same block and shares the same decision path — its three-line carrier, its five
tells, and the rule that any two of them make stop-and-surface mandatory are conditions this
story can silently drop exactly as easily, and dropping them is the defect `AGENTS.md` names.

The cost is re-derivation. In `infinite-portfolio-canvas` the remedy was reached from scratch
after four consecutive passes had each found one more spelling the claim text seemed to cover;
changing the instrument's form rather than adding a fifth pattern took the findings from nine to
zero. Three sites record it there — its `docs/hardening-taxonomy.md` corollary,
`.context/a5-t2a-resume.md`, and `.context/gate-b-a5-t2a-dispositionen.md`, where six of six
findings were about the checker's grammar and none about product behaviour.

## 2. Desired outcome

A reader inside a non-converging series recognizes it as one, has a named set of moves rather
than an instinct, and reaches a **named terminal state** instead of running another round. The
rung decision accounts for it, so "another arm of the same rung" is never proposed as though it
were escalation. Whoever reads the result can tell which move was taken and why, after the
session that took it has ended.

## 3. Acceptance criteria

- [ ] The unprofiled header above is resolved at design time: a profile is proposed, confirmed by
      the human, and written before the change ships — or the change ships with the header
      absent and this criterion records why, never with an unconfirmed header that looks
      confirmed.
- [ ] The procedure names three things separately: the **recognition signal** (what makes a
      series non-converging rather than merely long), the **moves** available, and the
      **terminal state** it stops in. A reader can check each against a transcript.
- [ ] Exactly one place decides which rung a recurrence gets. The procedure composes with
      `harden-finding`'s recurrence rule and its guard-scope precheck without adding a second
      decision branch on the same question.
- [ ] Every condition imposed by the current recurrence step **and by both of §5's stop paths** is
      listed and marked kept, moved, or deliberately dropped (`AGENTS.md`, "Never replace a
      decision procedure without accounting for its old conditions"). The two paths are the
      "clearly stuck" clause **and** the pass-4-onward reporting duty, which is a separate path
      and not a part of that clause: its conditions are the three-line report, its carrier being
      the agent's own status report to the user, the five tells, the rule that any two of them
      make stop-and-surface mandatory, and **the activation boundary — the duty begins at pass 4
      and binds on every pass after it**, which calling the path "the pass-4-onward reporting
      duty" names without accounting for. Naming the reporting duty in prose does not satisfy this —
      each of those conditions is accounted for individually.
- [ ] The wording is stack-neutral: no vocabulary from the consumer the evidence came from
      (invariant 10).
- [ ] The evidence's limits are stated where the procedure claims field support — three sites in
      **one** consumer, one of which is that consumer's own taxonomy prose rather than an
      application of it, plus one corroborating distribution from this repo (`7bbdb14`).

## 4. Affected AGENTS.md invariants

- `### Prompts and scaffolding` — "10. **The base taxonomy stays stack-neutral.** Project
  vocabulary — tables, auth helpers, framework APIs — goes only in that project's
  `docs/hardening-taxonomy.md`, never into the `harden-finding` skill. Otherwise one project
  leaks into every other."
- `### Prompts and scaffolding` — "11. **Prompt changes pass `docs/prompt-standards.md`** — all
  12 checklist items, for any skill, command, agent definition, hook message, or scaffolded
  template."
- `### Packaging` — "12. **A plugin change requires a version bump.**"
- `## Don'ts` — "**Never replace a decision procedure without accounting for its old
  conditions.** List what the previous prose required, then mark each one kept, moved, or
  deliberately dropped."

## 5. Open questions

- **What separates a non-converging series from a long one?** The field read the *Blocker curve*
  rather than the total, on the ground that substance can converge while the count does not. Is
  that the signal here, a count of same-shape findings, or something a reader can apply without
  having seen the whole series?
- **Who owns the stop?** §5's loop now has a criterion for "clearly stuck" and a mandatory
  reporting duty beside it, both added by the round that parked this story — so the open question
  is *not* whether that criterion is missing. It is whether the instrument case needs its own
  terminal state alongside them, or whether reporting the tells is already the whole answer for a
  series over an instrument.
- **What is a "named state"?** The field's version was a ticket with its own budget whose
  trigger is a relapse. Does the kit require a durable artifact, and if so which — a `todos.md`
  row, a ledger row at the fitting rung, or a note at the site?
- **Inherited** from `2026-08-04-harden-finding-guard-scope-precheck-story.md`, and inherited
  back: that story redesigns the branch deciding which rung a recurrence gets, and this one adds
  a case that branch must handle — a recurrence whose right answer is *not a rung at all* but a
  change of instrument. Both edit one decision path, so **whichever is picked up first must read
  the other and carry its conditions**, rather than re-deriving them; two rules landing
  separately on one branch is the shape that produced the bug that story was filed against.

## 6. Suggested size

`story` — one procedure, one decision path, one spec → plan → PR. Above a chore because it
changes what a reader does at a mandatory loop's exit, and it cannot be written without settling
how it composes with the recurrence rule.
