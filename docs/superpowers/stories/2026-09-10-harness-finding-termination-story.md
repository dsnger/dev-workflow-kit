# Harness findings: what blocks a commit, and when one mechanism's loop ends — Story

**Date:** 2026-09-10 · **Size:** story
**Risk:** *(proposed)* high · **Security:** *(proposed)* none · **Validation:** *(proposed)* battery+check+verification

> **DRAFT — the profile above is proposed, not confirmed.** Per §5 a profile is confirmed by the
> human, and until it is this story is not executable. Nothing depends on it yet. The proposal's
> reasons are in §5.

## 1. Problem statement

**Daniel's question, from another project, was whether the workflow needs an agent that keeps a
whole-project overview and makes triage calls so review loops stop spinning on edge-case
definitions.** The answer he brought back and endorses is that the missing thing is **not an agent
but a criterion** — a second agent would need the first one's entire context, hold no authority
because the human decides, and have to read the code to triage honestly; anything triaging on
plausibility alone dismisses the real defect as an unrealistic edge case.

**The criterion he proposes is three lines:**

1. A Major **in the product** blocks the commit, always.
2. A Major **in the harness** blocks only if it makes a claim about the code being committed
   vacuous; otherwise it becomes a ticket with a tripwire.
3. **The second finding of the same shape against the same mechanism ends the loop for that
   mechanism**: narrow the claim, print the residual, escalate by ticket rather than by another
   round.

**Two of the three already have most of a counterpart, and a design that ignores that would
rebuild them.** `CLAUDE.md` §5's severity procedure carries an **instrument carve-out** — "an
instrument finding keeps its severity whenever it shows the instrument changes what a gate
concludes about product behaviour — a false green, and equally a false red or a check blocking a
valid change" — which is close to lines 1 and 2. The five tells include "findings clustering on the
**instrument** rather than on product behaviour", so the kit **detects** harness drift and makes
stop-and-surface mandatory at two tells. And `dev-workflow:harden-finding` with the fingerprinted
ledger already handles recurrence, which AGENTS.md describes as "a recurring finding escalates one
rung harder (prose → lint → type → test)".

**What none of them does is the part that costs rounds.**

- **The severity procedure decides severity and never says what a non-vacuous harness Major
  *becomes*.** It sets a ceiling — "the finding is Minor or below: collect, never iterate" — and
  "collect" names no destination. Nothing is ticketed, nothing is tripwired, and the finding leaves
  no trace outside that pass's report.
- **The tells stop the whole loop, not one mechanism.** Two tells hand the entire cycle to the
  human. There is no way to end one mechanism's rounds while the loop keeps working on everything
  else.
- **Line 3 has no counterpart at all.** `harden-finding` escalates a *fix* after a finding is
  closed; it is not a move a running loop can make to stop re-examining a mechanism.

**The concrete miss is measurable in this repository's own cycle.** Gate-A spec cycle nonce
`awsf1ec771` on the loop-rule consolidation design ran twelve passes without a clean pass.
Blocker+Major by pass: **20, 15, 10, 11, 15, 13, 9, 8, 12, 17, 14, 14.** The pass-by-pass record is
`.context/codex-reviews/gate-a-spec-awsf1ec771-resume.md`, tracked since 2026-09-10 — the figures
are quoted here because they were quoted before that path was tracked, and they now cite something
a reader can open.

**Two mechanisms inside that cycle each produced the same shape of finding for four rounds, and
each was repaired one instance at a time.** The spec's own verification assert list produced
"an assertion that does not detect what it claims" at passes 8, 11 and 12 — one found by the
reviewer, three more by the revision's own audit, then four more, then three more. Separately, the
one-authority principle produced four "the block still restates what it cites" findings across
passes 11 and 12. Under line 3 each would have ended after its second instance, with the claim
narrowed and the residual printed.

**Why it kept happening, in Daniel's words: cheap to fix is not the criterion, and treating it as
one is exactly the drift a written rule prevents.** Every individual repair was a few lines, so
every one was absorbed rather than ending the round.

## 2. Desired outcome

**A reviewer and an author can tell, without inferring it, whether a given Major blocks this
commit or becomes tracked work** — and when it becomes tracked work, where that work is recorded
and what would catch its return.

**One mechanism's repeated findings can be ended without ending the loop.** A running cycle gains a
move between "absorb another round of this" and "hand the whole cycle to the human", so a mechanism
that keeps producing the same shape of finding stops consuming rounds while the loop continues on
everything else.

**Two bounds exist that today do not. Both were proposed on 2026-09-10 as mandatory mechanisms and
both were cut back on 2026-09-10 after an independent assessment read the field record against
them** (`.context/assessment-brief.md`; the reading is in this section). The diagnosis that prompted
them was that the cycle was slow because **the loop had no ceiling and the artifact had no size
limit**. The first half survives as a *visibility* gap; the second half does not survive contact
with the record.

Per the AGENTS.md Don't on replacing a decision procedure, what each proposal required and what
became of it:

- **A pass ceiling — kept as a report line, dropped as a stop.** *Kept:* the gap it named is real
  and measured. §5 fixes a floor and no maximum, and its two ways out both need a *reading*, so a
  flat loop can trip nothing: pass 12 of `awsf1ec771` sat at Blocker+Major 14 with **zero of five
  tells**, invisible to every rule the kit has. Cycle `awsf1ec771` ran **thirteen** Gate-A spec
  passes against a floor of 3 and reached no clean pass. *Dropped:* the mandatory stop-and-surface,
  on two grounds. **§5 already has three exits and they fire** — `awsf1ec771` at passes 9 and 10,
  Plan C at passes 4 and 5 — and the answer was "continue" every time, because a stop hands a
  question over and ends nothing; a fourth stop asks the same question a fourth time. And **it
  costs where the loop works**: the `rle` spec cycle ran 34 passes, closed clean, and still returned
  Blockers at passes 30–32 (`docs/field-reports/2026-08-29-gate-a-rle-cycle-evidence.md`) — a
  floor+3 ceiling would have interrupted it roughly nine times for no new information. *What ships
  instead:* the pass report already carries the floor and the trend; it also carries **passes run
  against the derived floor**, as a number. That makes the flat loop visible, obliges no new
  reading, and composes with nothing.
- **An artifact size limit — replaced by a restatement prohibition.** *Kept:* the observation that
  an oversized artifact must be dealt with before pass 1 rather than diagnosed after it, and both
  measurements behind it. The `awsf1ec771` spec reached **989 lines** of which the design was
  **173**; cutting it to 532 (design 192) took Blocker+Major from 14 to 10, and the `rle` spec cut
  from 604 to 332 lines took it from 28 to 12. *Dropped:* the line count as the test. **C1
  falsifies it.** That plan was nine sentences in eight replacements — about as small as a plan of
  this kind gets — and its curve rose anyway (Blocker+Major 8, 8, 10) until it stopped on two
  tells; the field record draws the conclusion itself: "the cost is not carried by the plan's
  **size**" (`docs/field-reports/2026-08-30-gate-a-rle-plan-cycles.md`). A line limit would pass a
  200-line artifact made entirely of restatement and split a 600-line one made entirely of design.
  *What ships instead:* the rule states what both successful cuts actually removed — **an artifact
  quotes no text it does not change, and restates no rule its own repo already states.** That is
  the one generator every field report names independently: "the remedy is never a better summary";
  "a plan that restates a protocol its own repo already governs creates a second copy that drifts,
  and Gate A will review the copy instead of the work"; "the block restates rules their own
  paragraphs still own". Checkable by reading, before pass 1.

**A third bound already exists in §5 and was simply not honoured**, which is worth recording because
it needed no new rule: the instruction to settle mechanically what a parser can decide before
spending a read pass on it. A precheck script was written before pass 1 of that cycle and then never
run again, and roughly a quarter of the later passes' findings were things it decides in seconds.

**Out of scope**, named so nothing absorbs them:
- **The severity definitions.** Blocker, Major, Minor and Nit keep their current meanings; this
  story changes what follows from a severity, not what earns one.
- **The loop-health counts and the two-tell threshold.** `CLAUDE.md` §5 already defers how a
  *demoted* finding bears on "the per-pass counts, the finding clusters and the stop thresholds" to
  `docs/superpowers/stories/2026-08-29-loop-rule-consolidation-story.md`. That story owns counting;
  this one owns blocking and terminating. Neither reopens the other.
- **Any triage agent.** Considered and rejected, with the reason recorded above: it would need the
  reviewing agent's whole context, hold no authority, and triage on plausibility unless it read the
  code.
- **Hook code** (anything under `plugins/dev-workflow/hooks/`).

## 3. Acceptance criteria

- [ ] **Every Major has exactly one stated disposition, determinable from the finding and the diff
      rather than from judgement about intent.** A reader can decide whether a given Major blocks
      this commit or becomes tracked work without consulting a person.
- [ ] **A harness Major that is not vacuum-making has a named destination.** "Collect" resolves to
      a specific artifact a later reader can open, and the shipped text says which one. Falsifiable
      by reading: a disposition that ends at "collect" with no destination fails.
- [ ] **A tracked harness finding carries something that would catch its return**, and the shipped
      text says what that is and who writes it. A ticket with no tripwire is the state this
      criterion exists to prevent.
- [ ] **"The same shape against the same mechanism" is defined precisely enough that two readers,
      given the same two findings, agree on whether they match.** Checkable by applying the
      definition to the two instances in §1 — the assert-list findings and the one-authority
      findings — and to a deliberate near-miss.
- [ ] **"Narrow the claim, print the residual" obliges specific written output**, and the shipped
      text names it. A reader can tell whether an author who ended a mechanism's loop actually did
      so or merely stopped looking.
- [ ] **Per-mechanism termination and the existing five tells do not duplicate or contradict each
      other.** Both copies say which applies when both would fire, and neither weakens the two-tell
      mandatory stop.
- [ ] **A loop that is going nowhere is visible without anyone reading a curve.** Every pass report
      states the passes run against the derived floor, as a number, from pass 1 onward. Falsifiable
      by reading a report: the number is there or it is not. **It creates no stop and no exit**, so
      the shipped text adds no rule about how it ranks against the three that exist — a criterion
      that demanded one would rebuild the lattice this change exists to avoid.
- [ ] **An oversized artifact is stopped before the cycle starts, not diagnosed after it** — and the
      test is restatement, not length. The shipped text says an artifact quotes no text it does not
      change and restates no rule its own repo already states, and says what an offending artifact
      does instead: delete the restatement and cite, or move the detail to the plan behind a named
      interface. Falsifiable by reading one artifact against the rules it cites. **No line count
      appears**, because C1 converged worse at nine sentences than the `rle` spec did at 332 lines.
- [ ] **Neither bound adds a reading to the loop.** The visibility line is reported and never
      evaluated; the restatement rule applies before pass 1 and is spent by then. The shipped text
      states both facts, so no reader looks for a composition rule against the existing exits.
- [ ] **Every condition of the replaced prose is accounted for**, each marked kept, moved or
      deliberately dropped, per the AGENTS.md Don't — and **the two prompt copies stay in parity**
      on every rule this story changes, deliberate wording differences stated as such.

## 4. Affected AGENTS.md invariants

- `## What this project is` — "**The product is prompts.** Skills, slash commands, agent
  definitions, hook reminder messages and every template `/workflow-init` scaffolds are the
  deliverable — plus one POSIX-shell hook."
- `## What this project is` — "There is no application code, so there is no typechecker to catch a
  defect; review and `docs/prompt-standards.md` are the only gates a prompt passes through."
- `## What this project is` — "a fingerprinted hardening ledger where a recurring finding escalates
  one rung harder (prose → lint → type → test), and one repo-enforced quality command."
- `### Prompts and scaffolding` — "11. **Prompt changes pass `docs/prompt-standards.md`** — all 12
  checklist items, for any skill, command, agent definition, hook message, or scaffolded template.
  The prompts are the product, and **no comprehensive mechanical checker exists for them**: review
  is the gate."
- `## Don'ts` — "**Never describe what a gate proves without checking what it actually compares.**"
- `## Don'ts` — "**Never replace a decision procedure without accounting for its old conditions.**"

## 5. Open questions

- **The profile.** Proposed `high / none / battery+check+verification`. The surface is the review
  gate's own severity ladder, and a wrong rule there mis-steers every future cycle in every project
  that adopts the kit. **No named `high` trigger matches literally**, so this is a judgement call
  under intake's "surfaces, not words", and the human decides it.
- **Is "harness" definable without a per-project list?** In this repository the product is prompts
  and the harness is shell test suites and CI checkers, so the line is unusually clean. Elsewhere a
  test helper can be both. Whether one definition transfers, or each project names its own the way
  `docs/hardening-taxonomy.md` holds project vocabulary, is a requirement question — and invariant
  10 says project vocabulary must not leak into the shipped skill.
- **Where does a tracked harness finding live — `docs/hardening-log.md` or `todos.md`?** The ledger
  is append-only, fingerprinted and recurrence-grepped, which fits a tripwire; `todos.md` holds the
  backlog that `pending` ledger rows already point to by `ref`. Both are plausible and they behave
  differently on recurrence.
- **Does the rule bind Gate A, Gate B, or both?** Gate A reviews text with no test harness in the
  usual sense, yet this cycle's four repeated findings were all Gate A, against the spec's own
  verification section. Whether "harness" at Gate A means the spec's instrument, and whether that
  reading holds downstream, is unsettled.
- **How does per-mechanism termination interact with the existing escalation ladder?** Hardening a
  harness finding escalates toward a test — which is the harness. Whether the ladder's rungs mean
  something different for a harness finding, or whether termination bypasses the ladder, is open.

## 6. Suggested size

`story` — one coherent change to the severity ladder's consequences in two mirrored copies, plus
one new loop move. Not `chore`: it answers a structural question and changes what a standing duty
produces. Not `epic-needs-splitting`: blocking and terminating are one decision procedure, and the
counting half is already owned elsewhere.
