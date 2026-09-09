<!-- Provenance note added when this file moved into the repo; nothing below it was altered. -->
> **Why this is committed.** Written during the cycle at
> `.context/codex-reviews/gate-b-fic2-parked-review-economics.md`, where `.gitignore`
> excludes all of `.context/` and each gate cycle overwrites the previous cycle's slots.
> It is the opening evidence for the review-economics story, so it is committed here
> rather than left to a `.context/` clear. Verbatim copy: no machine-local absolute
> paths were present, so the field-report path-neutrality convention required no
> substitution. The 14 `fic2` pass files it cites stay local — their per-pass figures
> are carried in the tables below.

# Parked: opening-evidence package for the review-economics story

Written 2026-08-26 during Gate-B cycle `fic2` on branch `field-intake-canvas-a1-a5`.
Not a findings file — it participates in no pass validation. It exists because the
material below was produced by a live loop and would otherwise die with the session.

**Disposition (Daniel, 2026-08-26): revert and park.** The cycle does not absorb the §5
surgery these findings imply. The assigned fix set contracts back to the eleven
dispositions plus the two loop rules that survived the earlier 12-pass cycle, plus this
cycle's verified error fixes. Everything below moves to a story, unanswered.

## What was reverted, and why it is not a retreat

Two clauses were written into CLAUDE.md §5 and the `/workflow-init` template mirror
during this cycle and then taken back out:

- **Q1 — clean completion outranks the two-tell stop.** A Blocker/Major-free pass at or
  above the floor would close even with two or more tells present, the tells going into
  the closing status report rather than blocking the close.
- **Q2 — a declined expansion has a defined exit.** A finding the user declines to bring
  in-set leaves the cycle as a recorded out-of-scope item, with the Blocker/Major-resolve
  duty scoped to in-set findings.

Both were correct answers to real defects. Pass 1 found the defects; Daniel confirmed both
answers. Pass 2 then found that shipping them requires qualifying **three §5 rules nobody
proposed changing** — the universal Blocker/Major-resolve duty, the rule that a surfaced
finding stays open with resolution unwaived, and the rule that no pass carrying it counts
as clean. That is the scope expansion the cycle declined.

## The three questions that go to the story unanswered

- **Q3.** Does a *scope stop* outrank clean completion, or the reverse? "Clean completion
  outranks both exits" was written, but §5 has three exits — the scope stop, the
  clearly-stuck exit, and the two-tell stop. If scope is included, the sentence
  contradicts the rule that even a Minor opening a contract question must stop.
- **Q4.** Does a decline bind *later passes in the same cycle*? As drafted it governed one
  stop only, so the same out-of-set Blocker could stop every subsequent pass and re-ask the
  same question indefinitely.
- **Q5.** Is qualifying the three universal rules with an in-set boundary acceptable at
  all? Yes makes Q2 shippable and is §5 surgery; no means Q2 cannot ship in that form.

## The instrument is broken, and that is the most reusable finding here

The `battery+check` evidence for a prose-only change was a decision matrix: N review
states, complete inputs, one expected output each, scored against the old text and the new
text and against both copies independently. Two defects were found in it by Gate B, and
both are properties of the *technique*, not of this instance:

1. **A state's inputs must include every input the rule reads.** Rows 3 and 10 carried
   identical recorded inputs and different expected outputs, because the user's expansion
   answer was never an input column. A matrix that omits an input cannot distinguish the
   states that input separates, and it will still look complete.
2. **A counterfactual must distinguish ABSENT from CONTRADICTORY.** The entry claimed the
   parent commit was "contradictory" on one state. `git show 17d5ad3:CLAUDE.md` has no
   two-tell rule at all — only the undefined phrase "clearly stuck" at line 78. The
   contradiction existed solely in an intermediate draft produced *inside this cycle*, so
   the check reported a failure mode the prior state could not produce.

Both survived a full Gate-B pass before being caught on the next one.

## Loop economics, measured on this cycle

| Pass | Findings | Blocker | Major |
|---|---|---|---|
| 1 | 14 | 3 | 5 |
| 2 | 24 | 4 | 13 |

Four of the five tells present at pass 2: finding count rising; Blocker count failing to
fall; findings clustering on the **instrument** (6 of 24, on the matrix rather than on the
rules it scores); findings clustering on **prose about** the rules (9 of 24 — CHANGELOG,
closure record, ledger entry, a parked story). No require↔withdraw pair: pass 2 narrowed
what pass 1 required, which is a qualification and not a withdrawal.

The reporting duty formally begins at pass 4. These were readable at pass 2, which is the
argument for the duty starting earlier — or for the trend being computed rather than
narrated.

## Cross-references

- Findings: `.context/codex-reviews/gate-b-{spec,quality}-fic2-pass-{1,2}.md`
- The matrix as it now stands (nine states, both clauses removed):
  `docs/field-reports/2026-08-16-canvas-a1-a5-dispositions.md`, section "The named
  verification behind the `battery+check` entry"
- Slot-name variance for this cycle: `fic2` discriminates it from the 2026-08-17 cycle
  whose records occupy the bare `gate-b-{spec,quality}-pass-N` slots.

---

## Parked at pass 5 (Daniel, 2026-08-26: bounded fix, then close)

Four findings from Gate-B pass 5 were parked rather than repaired. All four are true. All four
are about the *instrument* or about the entry conditions of unstarted work, and none is about
what §5 tells an agent to do. Pass 5 returned **zero product-behaviour findings**.

### The one that is this story's subject matter, verbatim

**A prose rule's check demands a fixture per predicate.** Pass 4 found that the nine-state matrix
could not see the reporting duty at all — no input it read changed when that duty was deleted. A
five-state table was added. Pass 5 then found that the new table takes the *tell count* as a
precomputed input rather than deriving it from raw observations, so a draft could delete or invert
one of the five tell definitions and every row would keep its expected result. The repair asked for
is raw input columns exercising each of the five tell predicates, against both prompt copies at both
revisions: roughly 5 × 2 × 2 hand-scored fixtures, for a rule whose entire product surface is one
paragraph.

The finding is correct and the repair is disproportionate. That gap — **what differential evidence
a prose-only rule can actually carry, and where the cost of the fixture exceeds the value of the
coverage** — is the question. `battery+check` says "a check that fails without the change" and says
nothing about how much instrument a one-paragraph rule is worth.

Sequence worth keeping: pass 4 asked for the table, pass 5 asked for it to be rebuilt, and the thing
being measured did not change between them.

### Three on a parked story's acceptance criterion

`docs/superpowers/stories/2026-08-17-arms-race-remedy-as-procedure-story.md`. Its kept/moved/dropped
criterion should enumerate individually, per pass 5: the three line contents; all five tell
definitions; and the threshold's consequence (report the triggering tells, hand the decision to the
user). Its problem statement also says §5 carries "one recognition heuristic and a terminal action"
while the same story later inventories two stop paths — a contradiction in the story's own opening.

Each is true. Each refines the entry conditions of work nobody has begun. One condition from this
group *was* applied rather than parked — the pass-4 activation boundary — because a future rewrite
could otherwise move the duty to pass 1 while checking off every other listed condition.

### Cycle shape at the point of closing

| Pass | Findings | Blocker | Major |
|---|---|---|---|
| 1 | 14 | 3 | 5 |
| 2 | 24 | 4 | 13 |
| 3 | 12 | 0 | 6 |
| 4 | 3 | 0 | 2 |
| 5 | 6 | 0 | 5 |

Two stop-and-surfaces, at pass 2 (four tells) and pass 5 (three tells). Only the pass-5 stop was
required by the shipped duty, which begins at pass 4; the pass-2 stop was an early surface chosen
because the tells were already readable, which is the argument the duty's activation boundary
invites rather than a rule it enforces. The pass-2 stop produced a revert; the pass-5 stop produced
this bounded close. Both were decided by the maintainer, neither by the loop.

---

## Observation recorded 2026-08-26: pass counter disagreed with the pass record

Raw facts only. **The cause is UNDIAGNOSED**, and no attribution to any existing ledger row
is made here — attribution without diagnosis is the class the ledger polices.

- Cycle: `fic2`, branch `field-intake-canvas-a1-a5`, closed 2026-08-26 at commit `3cdd075`.
- Passes actually run and validated: **7**. Each wrote both branch files, each file carried a
  well-formed terminator and a count matching its finding lines:
  `.context/codex-reviews/gate-b-{spec,quality}-fic2-pass-{1..7}.md` — 14 files on disk.
- What the gate hook reported at the closing commit: **"only 1/3 mcp__codex__review pass(es)
  since the last commit"**.
- What it reported at each intermediate amend: **"1 recorded pass(es) this cycle"**, from the
  amend following pass 1 onward. The value did not advance across passes 2 through 7.
- One intermediate amend instead reported **"no fingerprint is recorded for this cycle"**.
- `.context/codex-gate.passCount` read `7` at the start of the session, before this cycle began;
  that value belongs to the previous cycle and was not re-read afterwards.
- Every one of the 7 calls returned `success: true` with a normal result envelope. None timed
  out, none was aborted, none returned an `INCOMPLETE` reply.
- The cycle used a slot-name discriminator (`fic2`) rather than the bare
  `gate-b-{spec,quality}-pass-N` names. Whether that is related is **not established** — the
  hook is documented as never reading the findings file at all.
- Each pass was followed by `git commit --amend` on a single `WIP:`-prefixed commit.

Not diagnosed, and deliberately not guessed at: whether the counter was reset, never
incremented, incremented and overwritten, or read from a different key than it was written to.
Nobody inspected the hook's state files during the cycle, so there is no evidence either way.

Consequence for this cycle: none. `CLAUDE.md` §5 says the counter is not evidence and that every
incomplete pass is discounted regardless of what it says; the close rested on the 14 validated
findings files, not on the counter. The observation matters for the instrument, not for this
artifact.

---

## Parked from PR #25 review (Daniel, 2026-08-26): the unavailable-history gap

Greptile raised one P1 on PR #25 against `CLAUDE.md:143`, the pass-4-onward reporting duty.
Thread: https://github.com/dsnger/dev-workflow-kit/pull/25#discussion_r3864986788

**Split verdict.**

*The stated mechanism is FALSE.* The claim was that "the mandatory findings format cannot
retain all of that history". It can. §5 mandates one findings file per pass per branch at a
**pass-numbered** slot, one finding per line, severity as a leading closed-set field, and a
terminator carrying the count. Both historical inputs the three-line report needs are
therefore derivable from the mandated artifacts alone — trend by counting finding lines and
`^BLOCKER` lines per pass, require↔withdraw by comparing across those same files. Run over
this cycle it reproduced the reported figures exactly (findings 14, 24, 12, 3, 6, 6, 2;
Blockers 3, 4, 0, 0, 0, 0, 0) with no optional artifact consulted. The deletion rule does not
erase history either: §5 deletes only the slot about to be written, and slots are numbered.

*The gap is REAL, and it is availability rather than format.* Where prior-pass files are
genuinely absent — a fresh checkout, a cleared `.context/`, another machine, a cycle resumed
elsewhere — §5 defines **no behaviour** for the report from pass 4 onward. The cycle-stable
resume note is not the fallback: it is explicitly optional, and `CLAUDE.md:224` says "Nothing
depends on it existing." An agent in that position must invent the trend, omit the line, or
decide for itself, and the two-tell threshold is mandatory on top of whatever it decides.

**Why parked rather than fixed:** closing it needs new normative §5 content, which is the
surgery this cycle declined twice. It joins Q3-Q5 above as a fourth open question of the same
shape — a gap in the shipped rule whose repair is a contract decision.

**Q6.** What does the pass-4-onward report do when the prior-pass record is unavailable? The
candidate answers are not obviously equal: report the lines that *are* computable and say
which are not; treat unavailable history as a stop condition of its own; make the resume note
mandatory for cycles that cross a session boundary (which changes an artifact §5 currently
calls advisory); or start the duty's clock at the first pass of the *current* record rather
than of the cycle.

## Raw observation, undiagnosed: CodeRabbit plan metadata disagrees with the routing file

Recorded 2026-08-26, not attributed and not acted on.

- CodeRabbit's run configuration on PR #25 reports **`Plan: Pro Plus`** (Run ID
  `cdbb25fa-8c3d-45fb-a259-6b973b2ea965`, review profile CHILL).
- `docs/pr-review-bots.md`'s CodeRabbit row records **Plan: Free** "(per Daniel)", and states
  that the earlier Pro Plus reading "was observed on PR #1 only and no longer describes the
  account".
- These disagree. **The cause is UNDIAGNOSED.** Two candidates, not distinguished: the plan
  actually changed since that row was written, or the run-configuration metadata is
  unreliable.
- Why it matters: that row's review-limit reasoning — and part of the argument for routing
  CodeRabbit opportunistically rather than blocking on it — rests on the Free reading.
- Not this PR's business; `docs/pr-review-bots.md` is untouched by PR #25. A docs-only
  follow-up can correct it **after** diagnosis, not before.
