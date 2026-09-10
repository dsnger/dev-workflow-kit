# §5 record durability: sessions, commits, squashes and rollbacks — Story

**Date:** 2026-09-10 · **Size:** story
**Risk:** *(proposed)* high · **Security:** *(proposed)* none · **Validation:** *(proposed)* battery+check+verification

> **DRAFT — the profile above is proposed, not confirmed.** Per §5 a profile is confirmed by the
> human, and until it is this story is not executable. Nothing depends on it yet: the work it
> describes was split out of a cycle that is still running, and the successor starts when someone
> picks it up. The proposal's reasons are in §5.

## 1. Problem statement

**One question runs under every finding this story inherits: does a record survive?** §5 asks an
agent to write decisions into commit bodies and then to act on them a pass, a session or a merge
later. It never says what happens to a record across the six boundaries it will actually meet: a
**lost session**, an ordinary **`WIP:` amend**, a **`git reset --soft`** collapse of several WIP
snapshots into one, a **squash merge**, a **rollback** of the very rules that define the record,
and a **checkout whose root is not the one the pass ran in**.

**The reliance is older than any of the records.** §5 already puts "repair obligations you already
accepted in earlier passes" inside the assigned fix set, and nothing anywhere holds them: they
live in the running session and vanish with it. Every record this story inherits inherits that
problem too.

**The evidence is a cycle that could not converge while carrying this subject.** The
`Accepted:`/`Declined:` record was authorised into
`docs/superpowers/stories/2026-08-29-loop-rule-consolidation-story.md` on 2026-09-10 and split
back out the same day. Ten Gate-A spec passes ran on that story's design under cycle nonce
`awsf1ec771`. Blocker+Major went **20, 15, 10, 11, 15, 13, 9, 8, 12, 17** and never reached zero;
findings went **24, 17, 12, 18, 17, 16, 14, 12, 14, 20**.

**What the last pass's distribution showed is why this is its own story.** Of pass 10's twenty
findings, **nine belonged to this subject** — four on whether the record survives commits, three
on the checkout-root condition the unavailable-history report had grown, two on rollback and on
legacy cycles that hold no nonce. The closure ordering's own five findings were small. One
artifact was carrying two subjects, and only one of them was converging.

**Where the pass-by-pass evidence lives:** `.context/codex-reviews/gate-a-spec-awsf1ec771-resume.md`,
with the per-pass findings files beside it. That directory is gitignored, so the figures above are
quoted here rather than only cited — a reader on another machine has no way to open them.

**Parent:** `docs/superpowers/stories/2026-08-29-loop-rule-consolidation-story.md`, whose §2
records the split and whose §4 holds the decisions this story implements.

## 2. Desired outcome

**One coherent answer to durability, covering every inherited decision, with each mechanism's
residual stated rather than mechanised.** A reader of either §5 copy can answer, without
judgement: what a record is worth after a session ends; which commit carries it through an amend,
a soft reset and a squash; what a cycle reads when the rules it started under are gone; and what
an unavailable prior-pass record does to the report and to the floor.

**Prefer a stated residual to a built mechanism.** This is the parent's most expensive lesson and
it is an input here, not a discovery to be repeated — see §4.

**Out of scope**, named so nothing absorbs them:
- **The closure ordering, the duty classification and the severity/loop-health answer.** The
  parent story ships all three; this story treats them as given.
- **Reopening any decision in §4.** They are settled and paid for; the design starts from them.
- **Hook code** (anything under `plugins/dev-workflow/hooks/`).
- **The pass-counter anomaly**, the CodeRabbit plan-metadata contradiction, and the
  fixture-per-predicate question — all still parked, as they were for the parent.

## 3. Acceptance criteria

- [ ] **A user's answer that puts work into the fix set leaves a record on the same terms as one
      that keeps work out.** Both labels share one form, one transport, one attribution rule and
      one carry rule, **each stated once**; recording an answer is a precondition to running the
      next pass; and what the record does *not* buy is stated — it makes a decision legible, not
      automatically recovered, and nothing checks that a later cycle looked. Falsifiable by
      reading: two labels with one set of rules, and a residual paragraph that does not overclaim.
      *(Carried from the parent's criterion 7, which moved here with the split.)*
- [ ] **A record made under a cycle survives that cycle's own git housekeeping**, and both copies
      say how. Checkable by walking the three operations §5 already prescribes — a `WIP:` amend, a
      `git reset --soft` onto the parent of the first WIP, and the closing `--amend` — and asking
      of each which body holds the record afterwards. An operation whose answer is "none" is a
      defect, not an accepted cost.
- [ ] **The squash-carry rule names every record this story ships**, and the enumeration matches
      what the shipped text actually produces. The parent's members — evidence entries, human
      exception records, provenance lines, curves, skip records with their reasons — are
      **extended, never replaced**: a rewrite that drops one silently unships it.
- [ ] **A cycle whose starting rules cannot be established has a stated reading for every record
      this story ships**, and that reading is the conservative one. Checkable against the
      unknown-start fallback's existing list, which this story extends rather than rewrites.
- [ ] **An unavailable prior-pass record has one stated effect on the report and one on the
      floor**, and they do not disagree. A reader can determine, for a slot that is absent, present
      but invalid, or present under a root that cannot be established, whether the pass counts
      toward the floor, what its curve entry is, and what the report must disclose.
- [ ] **The checkout root is answered one way and stated once** — a pass-validity condition or a
      disclosure, not both and not a third thing in a third place. The parent reworked it three
      times across passes 4, 8 and 9 and pass 10 still found it self-contradictory, which is what
      this criterion exists to prevent.
- [ ] **Every condition of the replaced prose is accounted for** — for each rewritten passage, what
      it required, each requirement marked kept, moved or deliberately dropped, per the AGENTS.md
      Don't. A requirement neither kept nor explicitly dropped is a dropped condition.
- [ ] **The two copies stay in parity** on every rule this story changes, deliberate wording
      differences stated as such.

## 4. Settled inputs — inherited, not reopened

Four decisions come across from `docs/superpowers/stories/2026-08-29-loop-rule-consolidation-story.md`
§4, confirmed by Daniel during the parent cycle and **implemented here rather than re-decided**.
Their substance is reproduced so a reader need not hold both files open; the parent remains the
place they were settled.

| # | Decision, as inherited |
|---|---|
| 9 | **The answer is recorded in the commit body**, reusing the human-exception transport as a **distinct record type** — the two differ in force, since the human-exception form authorizes nothing. |
| 9b | **The record stores exactly what the sameness test reads: location, defect, severity, consequence and suggested fix.** A test reading fields the record lacks is a wiring failure. Sameness requires all five to match; **any difference — including severity — makes it a new finding and the hold applies**, as does any genuine uncertainty. |
| 9c | **The record reads as an unverified assertion**, like the human-exception record beside it: nothing checks that the handle belongs to whoever decided. **Narrowness bounds what a false record can do — one fully-identified finding, one cycle — and that is not the same as making it safe.** |
| 10 | **When prior-pass history is unavailable**, the pass report states what is computable, names what is not and why, and discloses the reduced sensitivity. **Not a new stop condition**, not a mandatory resume note. |

**A fifth input, from the parent's ten passes rather than from a decision: prefer a stated
residual to a built mechanism.** The parent grew a snapshot rule, an identity line, an
authoritative-body rule, a newest-first branch search, a malformed-snapshot stop and a
durable-validity proof, all to make records recover automatically. Pass 9 deleted roughly ninety
lines of that machinery on Daniel's decision, and pass 10 still returned Majors at **15**, the
pass-1 figure, with Blocker+Major up from 8 to 17. **So the machinery was not the whole cost —
but it was the part that regenerated**, each round's repair producing the next round's findings.
A design here that answers a durability question by building recovery, rather than by saying what
survives and what does not, is repeating a measured failure.

**Two implementation facts the parent cycle established, carried so they are not rediscovered:** a
pass's cleanliness is a fact about what that pass found and is **never rewritten**; and the
findings files establish the **inventory** of findings, not their resolutions, which they do not
contain.

**Passages shared with the parent.** The squash-carry rule and the unknown-start fallback are
rewritten by both stories. **This story extends what the parent leaves behind rather than
replacing it** — the parent's accounting covers its own half, and a replacement drops it silently.

## 5. Open questions

- **The profile.** Proposed `high / none / battery+check+verification`, on the same reasoning its
  sibling used: the surface is the review gate itself, and a wrong rule mis-steers every future
  cycle. **No named `high` trigger matches literally**, so this is a judgement call under intake's
  "surfaces, not words", and the human decides it. The parent's experience is evidence for rather
  than against: ten passes, two mandatory two-tell stops and a split.
- **Is the checkout root a pass-validity condition or a disclosure?** Settled decision 10 says
  unavailable history is "not a new stop condition", and the parent's pass 10 read the root gate as
  contradicting it. Answering it a validity condition means a pass can end INCOMPLETE for a reason
  unrelated to its findings; answering it a disclosure means a wrong checkout can be reported as
  benign missing history. The parent tried both and shipped neither cleanly.
- **Does the sameness test read the five fields byte-exact or on meaning?** This **interprets**
  decision 9b rather than reopening it: 9b settles that any difference makes a new finding and is
  silent on what counts as a difference. The parent read it as meaning, because a reviewer
  rewrites its sentences between passes and byte equality would re-ask every declined finding;
  pass 10 read it as bytes, citing 9b's own wording. Both readings satisfy the decision as
  written, which is why a human answers it — it is the difference between a record that binds too
  little and one that binds too much.
- **Does a rollback that removes these rules owe an open cycle any transition?** §5's activation
  rule says a cycle finishes under the rules it started with, and nothing records which rules
  those were. A rollback can therefore leave a cycle open with no text describing what it owes.
  Whether that is a state to define or a residual to disclose is a requirement question.

## 6. Suggested size

`story` — one coherent subject, durability of records across boundaries, in two mirrored copies.
Not `chore`: it answers four open requirement questions and rewrites standing carry rules. Not
`epic-needs-splitting`: the boundaries are six named ones, and the decisions behind the records
are already made.
