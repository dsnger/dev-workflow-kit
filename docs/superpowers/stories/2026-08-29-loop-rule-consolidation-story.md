# §5 loop-rule consolidation: exits, duties, and the decline — Story

**Date:** 2026-08-29 · **Size:** story
**Risk:** high · **Security:** none · **Validation:** battery+check+verification

**Profile log:**
- 2026-09-10 · adoption · proposed 2026-08-29 at the split from the parent cycle, confirmed by Daniel as proposed after the parent shipped (PR #26) · gates now read this header

## 1. Problem statement

**§5's loop has four exits and four standing duties, and nowhere says which wins when two apply at
once.** Clean completion, the scope stop, the clearly-stuck exit and the two-tell stop; the floor,
the Blocker/Major-resolve duty, the rule that a surfaced finding stays open, and the rule that no
pass carrying one counts as clean. Every one is stated in its own paragraph, each qualifying the
ones before it, and the ordering exists only in a reader's head.

**That gap has already cost a cycle.** The `fic2` cycle could not ship two small clauses without
qualifying three rules nobody had proposed changing, and reverted — correctly. The revert is the
evidence: two clauses met an unordered lattice and the lattice pushed back.
(`docs/field-reports/2026-08-26-fic2-cycle-evidence.md`.)

**Why this is a story rather than a paragraph.** The answers are not the hard part — they are all
settled and listed in §4 below. **Writing them down is.** Eleven Gate-A passes on the parent
story's spec never brought Blocker/Major below 22, and the last three attributed **10, 11 and 14**
of them to exactly these rules while the floor and severity parts held at 4/1, 8/1 and 7/1. Each
repair to one loop rule created an interaction the next pass found. **The subject here is
interaction density among rules that all bear on one decision — may this cycle close — and it needs
its own artifact and its own review budget.**

**Parent:** `docs/superpowers/stories/2026-08-28-review-loop-economics-pass-floor-story.md`, which
ships the pass floor and severity semantics and whose §6 records why the split was refused first
and then taken.

## 2. Desired outcome

**One stated ordering, written once, that a reader can apply without inferring it** — after which
the individual rules reference the ordering instead of qualifying each other. Specifically, a reader
of either §5 copy can answer, without judgement: which exits *close* a cycle and which merely
*suspend* it; what happens when two apply at once; which duties participate in that ordering and
which are preconditions; and what a user's answer on a surfaced finding does in **both** directions.

**Out of scope**, named so nothing absorbs them:
- **The pass floor and severity semantics** — the parent story ships those, and this story treats
  them as given rather than adjusting them.
- **Reopening any decision in §4.** They are settled and paid for; the design starts from them.
- **Hook behaviour** (anything under `plugins/dev-workflow/hooks/` that decides what the hook
  does): its control flow, counters, fingerprint computation, routing and event handling, all
  unchanged from the parent. **One narrow exception, authorised 2026-09-13:** the seven reminder
  **strings** this change makes contradictory, and the single exact-match expectation in
  `plugins/dev-workflow/hooks/codex-gate.test.sh` that pins one of them, are in scope — listed as
  items 10–13 and 15–17 of the target text's §F. Prompt-standards item 7 requires a superseded instruction
  to be corrected in the same change, and a hook reminder is prompt text the agent acts on. The
  Gate-B fingerprint overclaim in the same message stays parked.
- **The pass-counter anomaly**, the CodeRabbit plan-metadata contradiction, and the
  fixture-per-predicate question — all still parked.

**One expansion, authorised 2026-09-10 and then split out again on the same day.** Gate-A spec
pass 4 raised, as a scope stop, that an accepted repair obligation lives only in the running
session. Daniel accepted it into scope, and the change grew a second record label, `Accepted:`,
beside the decline record. Six passes later the loop had not converged and the evidence said why:
of pass 10's twenty findings, nine belonged to **one subject this story never set out to
answer** — whether a record survives a session, a commit amend, a squash, a rollback or a moved
checkout. The closure ordering itself had converged, its remaining findings small.

**Split 2026-09-10 on Daniel's decision. Deferred to
`docs/superpowers/stories/2026-09-10-record-durability-story.md`**, whose subject is exactly that
one: the `Accepted:`/`Declined:` record and its transport (settled decisions 9, 9b and 9c), the
unavailable-history report (settled decision 10), the checkout-root condition that report grew,
the rollback reading, and the slot-discriminator dissolution. **Those decisions stay settled** —
they are not reopened, they are implemented there. Criterion 7 moves with them.

**What this story keeps** is what its problem statement asked for: the ordering, the duty
classification, and the severity/loop-health answer handed to it by the parent. The rule covering
both directions of a user's answer stays here, because it is a rule about the loop; only the
record that transports it moves.

## 3. Acceptance criteria

- [ ] **The ordering is stated once, in both copies, and covers every reachable conflict.** A
      reader can determine which exits close and which suspend, and what happens when two apply
      together, without inferring it from paragraphs that qualify one another. Conflicts that
      **cannot** co-occur are named as such with the reason, rather than given invented rules — an
      ordering that legislates for unreachable states rebuilds the broken instrument the `fic2`
      record already documents.
- [ ] **Every duty is classified, and each classification is visible.** For each of the four
      standing duties, both copies say whether it participates in the ordering or is a
      precondition on closure — and a duty that is a precondition says what it gates and what
      discharges it.
- [ ] **A user's answer on a surfaced finding has one rule covering both directions**, and the
      rules it modifies carry the qualification **at each rule it modifies and at no rule it does
      not**. Both halves are falsifiable by reading: a modified rule that does not mention it
      leaves two instructions disagreeing; an unmodified rule that mentions it implies an exception
      that does not exist.
- [ ] **No path leaves a cycle unable to close and unable to stop.** Every terminal condition the
      change introduces has an answer that changes the cycle's state. Checkable by walking each
      stop the shipped text names and asking what the next state is — the parent cycle shipped a
      stop whose only answer resumed a cycle that immediately stopped again, and that is the
      failure this criterion exists to catch.
- [ ] **Every condition of the replaced prose is accounted for** — for each rewritten passage, what
      it required, each requirement marked kept, moved or deliberately dropped, per the AGENTS.md
      Don't. A requirement neither kept nor explicitly dropped is a dropped condition.
- [ ] **The two copies stay in parity** on every rule this story changes, deliberate wording
      differences stated as such.
*(Criterion 7 — that a user's answer putting work into the fix set leaves a record on the same
terms as one keeping work out — was added 2026-09-10 and moved the same day to
`docs/superpowers/stories/2026-09-10-record-durability-story.md` with the split recorded in §2.
It is not withdrawn, and it is not this story's to satisfy.)*

## 4. Settled inputs — decided, paid for, and not to be reopened

Each was confirmed by Daniel during the parent cycle. **The durable record is that cycle's commit
bodies**, which carry every one of them. `docs/field-reports/2026-08-26-fic2-cycle-evidence.md` is
where the *questions* were parked, not where they were answered — it states Q3–Q5 as unanswered and
gives Q6 only as candidate answers, because it was written before the answers existed. Citing it as
the source of the decisions would send a reader to a document that predates them. **The design
begins from the table below.**

| # | Decision |
|---|---|
| 1 | **Only clean completion closes a cycle.** The scope stop, the clearly-stuck exit and the two-tell stop **suspend** — they surface and the loop resumes. Two suspensions at once compose; the report carries both reasons. |
| 2 | **Clean completion outranks the two-tell stop** (Q1). |
| 3 | **Clean completion outranks the clearly-stuck exit** — §5 already says so and the sentence is preserved verbatim. |
| 4 | **A surfaced finding holds closure while it awaits the user's answer; any answer ends the hold, in either direction** (C3/Q5, and the accept branch). After the answer the ordinary rules govern. |
| 5 | **A decline releases the hold and never qualifies the Blocker/Major-resolve duty**, which applies to in-set findings a decline never reaches. |
| 6 | **A decline is available only for a finding surfaced by a scope stop.** An in-set Blocker or Major cannot be declined; treating it as declinable would make this a general waiver. |
| 7 | **A decline binds for the remainder of its cycle and has no effect in any later one** (Q4). |
| 8 | **"Explicitly declined" is a recorded user decision on that specific finding**, attributable and unambiguous — never silence, never a general remark about scope, never inferred. |
| 9 | **The decline is recorded in the commit body**, reusing the human-exception transport as a **distinct record type** — the two differ in force, since the human-exception form authorizes nothing. |
| 9b | **The record stores exactly what the sameness test reads: location, defect, severity, consequence and suggested fix.** A test reading fields the record lacks is a wiring failure. Sameness requires all five to match; **any difference — including severity, since a Minor re-raised as a Blocker is not the thing that was declined — makes it a new finding and the hold applies**, as does any genuine uncertainty. |
| 9c | **The record reads as an unverified assertion**, like the human-exception record beside it: nothing checks that the handle belongs to whoever decided. **Narrowness bounds what a false record can do — one fully-identified finding, one cycle — and that is not the same as making it safe**; a fabricated decline still releases a real hold and nothing detects it. |
| 10 | **Q6:** when prior-pass history is unavailable, the pass report states what is computable, names what is not and why, and discloses the reduced sensitivity. Not a new stop condition, not a mandatory resume note. |

**Two implementation facts the parent cycle established, carried so they are not rediscovered:** a
pass's cleanliness is a fact about what that pass found and is **never rewritten** — what a later
answer changes is whether the *cycle* may close; and the findings files establish the **inventory**
of in-set findings, not their resolutions, which they do not contain.

### Three passages this story shares with the parent

Both changes rewrite these, and **this story must extend rather than replace what the parent added**
— the parent's accounting already covers its own half:

- **The squash-carry rule.** The parent adds the provenance line, the per-pass curves and a skipped
  loop's skip record to what a squash must carry. **This story adds the decline record**, and a
  rewrite that drops the parent's three would silently unship them.
- **The unknown-start fallback** (what a loop does when its starting rules cannot be established).
  The parent covers five parts at their strictest — floor, severity, the provenance line, the curve,
  and the nonce duties. **This story extends
  the same list to the loop rules it ships** — suspensions binding, decline records
  treated as absent so no hold is released. Extending is safe; replacing is not.

A third, for the same reason: the **clearly-stuck paragraph** is rewritten by both — by the parent
because its "pass 1 carrying a Minor" sentence is false under a floor of 1, and by this story
because the exit becomes a suspension in the ordering. **Both accountings owe it.**

**A fourth, handed over rather than shared — the demotion/loop-health interaction.** The parent's
severity test demotes a finding when nothing in the system takes a different decision from it.
That bears directly on the loop-health measures this story owns: what a demoted finding does to
the per-pass counts, to the finding clusters, and to the stop thresholds. The parent **does not
settle it** — three of its revisions tried, each reaching past its own §9 exclusion of "the §5
loop-rule consolidation and everything its successor story owns", and each removal found another
layer underneath. What it ships is one sentence saying the interaction is **not settled
there**, together with the conservative action for a pass that would turn on it — report the
question and stop rather than deciding it. Only this repository's `CLAUDE.md` also names this
story as the owner; the scaffolded template deliberately does not, because it writes into
projects where this path does not exist. **This paragraph is the reciprocal**: the obligation is named in both documents so it
cannot fall between them, which is the failure the passage list demonstrated in that same cycle.
The design owes an answer covering at least: whether a demoted finding still counts toward the
finding total and the clusters, and whether the Blocker curve reads severity before or after the
ceiling.

## 5. Open questions

- **The profile.** Proposed `high / none / battery+check+verification`, on the same reasoning the
  parent used: the surface is the review gate itself, and a wrong rule mis-steers every future
  cycle. **No named `high` trigger matches literally**, so this is a judgement call under intake's
  "surfaces, not words", and the human decides it. The parent's experience is evidence for rather
  than against: eleven passes and three mandatory stops on this material.
  *(Resolved 2026-09-10: confirmed as proposed — see the profile log.)*
- **How much of the ordering is new text versus reference.** §5 already contains the two sentences
  from which "only clean completion closes" follows; whether the ordering is stated fresh or
  assembled from what is there changes the old-conditions accounting and the parity surface.
*(Resolved 2026-08-29: the cycle nonce stays with the parent, which ships it because both of the
records parts 1+2 produce carry it. **This story consumes it and does not define it** — it uses the
nonce to bind a decline to one cycle, per settled decision 7.)*

## 6. Suggested size

`story` — one coherent change to one subsystem's rules in two mirrored copies. Not `chore`: it
answers a structural question and rewrites standing duties. Not `epic-needs-splitting`: the
decisions are already made, which is what made the parent's version expensive.
