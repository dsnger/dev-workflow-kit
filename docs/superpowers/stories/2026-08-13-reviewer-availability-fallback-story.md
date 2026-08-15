# Reviewer-availability fallback — no sanctioned gate waiver; an optional-work record — Story

**Date:** 2026-08-13 · **Size:** story
**Risk:** standard · **Security:** none · **Validation:** battery+check

**Profile log:**
- 2026-08-14 · axis change · risk ↓, security ↓ · the closure: the `high` rationale named a sanctioned fail-open path, which design §2.2 now says explicitly does not exist, leaving §5 prompt discipline — the hardening-round precedent class, with its recorded delimitation; and the trust relationship "who reviews" left with the ladder, so a record form touches no asset, boundary, role or external system · drops both lens sets; mode recomputes to `battery+check`

> **CLOSED 2026-08-14 with a negative answer, and a small salvage.** Three design cycles and
> nine Gate-A passes (303 findings, none dismissed) found **no safe design for a sanctioned
> zero-pass gate closure** in the three classes tried, each failing for a recorded structural
> reason. That finding is this story's result, in
> `docs/superpowers/specs/2026-08-14-reviewer-availability-fallback-design.md` §1 — which is
> explicit that this is repeated structural failure, **not a proof of impossibility**: a class
> resting on authority outside the repository was never tried.
>
> What ships is the **record form** of a human exception (design §2), plus riders (b) and (c),
> which carried real discriminating checks throughout. **The form does not reach the stall**
> — it is scoped to things §5 never required, so it cannot close a gate cycle (design §2.0).
> Gated work blocked by an unavailable reviewer routes to **operational bridges** (a second
> key, another vendor) or to the tier-2 story if its containment proves buildable; if neither
> is available, work on gated changes stops until the reviewer returns (design §7).
>
> **The profile moved with the closure** (axis change, 2026-08-14, logged): the `high` risk
> rationale named a sanctioned fail-open path that §2.0 now says does not exist, and the
> "who reviews" trust relationship left with the ladder. What remains is §5 prompt discipline.
> Both lens sets drop; the derived mode is what the header now carries.

<!-- No profile log: the profile has never changed. A scoped "mode override" was briefly
     recorded here on 2026-08-14 and WITHDRAWN the same day, before any pass ran under it.
     The two-tier cycle's spec pass 3 (blocker 13) established it was not a valid §5 profile
     change — §5's grammar permits a whole effective mode in the header and requires the
     header to carry the override; there is no per-portion override, so recording one
     invented a mechanism the profile system does not have. The log block is absent rather
     than carrying a withdrawal entry because the log records profile CHANGES, and on this
     story no profile value has ever moved.

     UPDATED 2026-08-14 with the closure, and the log now exists — see the header. The
     `+check` that same pass named, a prompt-harness scenario driving an unavailable reviewer,
     belonged to tier 3, which no longer ships, and the stripped cycle's pass 3 found that
     construction unsound in any case. The salvage's `+check` is a **source-level assertion**
     (design §5.2): each of the two prompt copies must state the severity enum as a closed set
     of four tokens. It fails at `df850ab`, where neither does, and passes after. What it does
     NOT observe is reader behaviour — whether an out-of-enum pass is actually accepted or
     ruled INCOMPLETE. The prior-state behaviour is a **named verification** with evidence
     already in hand: PR #23 returned four `IMPORTANT` findings and they were accepted and
     filtered by interpretation. The after-state behaviour is unobserved, and the design says
     so rather than implying a symmetric result.

     The withdrawn override stays withdrawn. The axis change voids prior overrides by rule,
     and there is nothing further to void: the only one ever recorded was already withdrawn
     before any pass ran under it. -->

## 1. Problem statement

Both review gates depend on a single external reviewer, and there is no sanctioned
degraded path when it is unavailable. §5 requires a **minimum of three passes** per gate
with only the **final** pass clean, and permits an early exit below three only on a pass
returning zero findings; when the vendor is out of quota, no pass can be taken at all, so
no cycle can close and all work stops.
Observed: a five-day full process stall, 2026-08-05 to 2026-08-10, from one vendor's
quota.

The one degraded mode that exists is `/workflow-init` §2.13, and it does not reach this
case: it fires at **init time** when the preflight finds Codex unconfigured, and its
answer is to scaffold a project that is explicitly gateless. A project already running
the gates that loses its reviewer mid-flight falls outside it.

So the gap is narrow and specific: **there is no authorized way to close a gate cycle
when no reviewer can run.** Work stops, and the only alternative reachable today is to
abandon the gates entirely — which §2.13 offers a *new* project and offers no one else.

*(Amended 2026-08-14, fifth amendment. **Kept, and still true** — every sentence of this
problem statement, including the five-day incident and §2.13's failure to reach the
mid-flight case. The problem is real and is **not solved by this story**. What changed is the
answer: three design cycles established that the authorized closure this section asks for
cannot be built safely here, so the gap is now a **stated limitation** rather than an open
requirement, and the stall routes to operational bridges or the tier-2 story, and if neither
is available, work on gated changes stops until the reviewer returns — design §7.)*

> **Amended 2026-08-14 (second amendment) — Gate-A pass 1 findings 21 and 22.** The first
> amendment claimed tier 2 moved "in its entirety" and left this section still framing the
> problem as *"the workflow has no vocabulary for a review that happened but was weaker
> than tier 1"*. That was untrue of the text, and the claim is withdrawn.
> **Old-condition accounting for this section:** **kept** — the availability stall, the
> five-day incident, and §2.13's failure to reach the mid-flight case. **Moved by name** —
> the four-prohibition-site survey and the `docs/sparring-briefing.md` family-granularity
> premise, to
> `docs/superpowers/stories/2026-08-14-tier-2-same-family-reviewer-story.md`, which is the
> only story whose fallback those sites forbid; a human exception is not a model reviewing
> its own work. **Overturned** — the "no vocabulary for a weaker review" framing, which
> described tier 2's problem, not this story's. This story's problem is that a cycle
> cannot be *closed* at all.

## 2. Desired outcome

~~A reviewer-availability ladder exists for **both** gates, with each tier's standing stated
and its degradation visible in the durable record~~ — **the ladder is overturned** (below);
what survives is the second half of that sentence, applied to a human's decision rather than
to a tier. The original outcome is kept in place so the reversal is legible:

- **tier 1** — cross-model, a different model family than the implementer. Today's
  normal, unchanged, and the only tier that satisfies a gate without qualification.
- [~] ~~**tier 3** — the human exception, mid-flight: a zero-pass closure, a gate waiver
  authorized by a human, disclosed in the durable record~~ — **OVERTURNED 2026-08-14, fifth
  amendment.** Recorded rather than deleted, because a criterion that vanishes is
  indistinguishable from one never written. **Old-condition accounting:** **overturned** —
  that a human may *authorize* a zero-pass closure at all, since three cycles established the
  authorization cannot be given the properties it needs (design §1.3: every control landed
  unenforceable or recursive; the outage that justifies the waiver is manufacturable by
  whoever benefits; the preconditions cannot be established in the case they exist for).
  **Kept, and now the whole of what ships** — that when a human makes an exception, the
  decision is **written into the durable record** and identifiable from `main` alone. What
  reversed is the direction of the claim: the record no longer certifies the decision, it
  preserves it. **Kept, untouched** — §2.13's init-time gateless answer. **Moved** — nothing;
  there is no third story.
  *(The two earlier amendments to this bullet — second amendment / pass 1 finding 21, which
  overturned "tier 3 exists today for the init-time case", and fourth amendment / pass 1
  finding 14, which narrowed "re-review debt" to "untracked re-review obligation" — are
  subsumed by this one. Both concerned a tier that no longer ships.)*

~~Degrading is a **fail-open-with-disclosure**: work continues, and the weakening is
recorded rather than silently absorbed.~~ — **OVERTURNED with tier 3.** There is no
degraded mode left to fail open into: §5's gates are unchanged in every particular, and
nothing this story ships lets work continue past a gate. **Kept in full, and it is the
reason the salvage is worth shipping at all** — the failure this must not produce is a
weakened cycle indistinguishable from a normal one after the fact. Design §2.1 answers
that for the one case that remains: a human who decides to proceed leaves a record saying
so. **Kept** — that this is the false ✓ the current prohibition exists to prevent.

The change carries two riders and one backlog append that amend the same §5 region, so one
Gate-B cycle covers all of it. **After the closure these are the majority of the change**,
not its trim.

> **Amended 2026-08-14 — the ladder narrows from three tiers to two.** Gate-A spec passes
> 1–3 returned 116 findings, none dismissed, with blockers rising; the cycle was stopped
> under §5's stuck condition. **Old-condition accounting for the three-tier framing:**
> **kept** — tier 1's standing, the fail-open-with-disclosure principle, and the
> requirement that degradation be visible in the durable record. **Moved by name** — tier 2
> in its entirety, to
> `docs/superpowers/stories/2026-08-14-tier-2-same-family-reviewer-story.md`, carrying
> pass-3 blockers 2, 3 and 4 as opening evidence and the sanitized-external-checkout
> direction as its design question. **Narrowed** — "each tier's standing" now covers two
> tiers rather than three. Nothing was dropped: tier 2 is deferred, not abandoned, and the
> reason is that every stopping blocker except rider (a)'s belonged to it.

## 3. Acceptance criteria

- [~] ~~§5 documents a **two-tier** reviewer ladder covering both Gate A and Gate B, naming
      for each tier what it is and whether a cycle closed there satisfies the gate~~ —
      **OVERTURNED 2026-08-14, fifth amendment.** No ladder ships: there is one tier, the
      existing one, and §5's account of it is unchanged.
      *(**Kept** — that §5 must state plainly what does and does not satisfy a gate, which it
      already does and which the salvage is careful not to blur: design §2.2 says in terms
      that the exception record is not a waiver, clears no floor, and satisfies no gate.
      **Overturned** — the ladder, the tier vocabulary, and "whether a cycle closed there
      satisfies the gate", which presupposes a tier where one could.)*
- [ ] A **recorded human exception** is identifiable from `main`'s history alone — the
      closing commit body carries it, without reference to the session that produced it.
      *(Amended 2026-08-14, fifth amendment. **Kept in force, narrowed in subject** — the
      requirement that a weakening be visible in the durable record is the one thing that
      survives the closure intact, and design §2.1 delivers it. **Narrowed** — the subject
      is a human's recorded decision rather than "a degraded cycle", because no degraded
      cycle exists to identify. **Kept** — no reference to the producing session; the record
      stands alone. Earlier amendments moved this from the pass to the cycle; this one moves
      it from the cycle to the decision.)*
- [ ] Every site currently forbidding a same-model fallback is accounted for explicitly
      — `/workflow-init` §2.13, `docs/coding-workflow.md` § *The two gates…*, `README.md`,
      `plugins/dev-workflow/agents/finding-triage.md`, and
      `docs/sparring-briefing.md`'s family-granularity premise — with each condition
      marked kept, narrowed, or deliberately overturned per the AGENTS.md decision-procedure
      Don't. No site is left asserting the ladder is forbidden.
      *(Amended 2026-08-14. **Moved by name** — to the tier-2 story in its entirety. The
      four prohibition sites forbid a **same-model reviewer**, which tier 3 is not: a
      human exception is not a model reviewing its own work. So this change leaves their
      wording untouched, and the narrowing principle ships only insofar as tier 3 needs
      it. **Kept** — the accounting obligation itself, which the tier-2 story inherits
      unchanged.)*
      *(Amended again 2026-08-14, third amendment, Gate-A spec pass 3 finding 27 — the
      amendment above was **partly false and is corrected here**.
      `docs/sparring-briefing.md` does not only state a same-family premise. Lines 41–44
      also say: "**Advisory, never exempt.** … Do not design around the gates, and do not
      treat a satisfied human as a substitute for a clean pass." **Tier 3 is exactly a
      satisfied human substituting for a clean pass**, so those clauses are this story's
      to face, not the tier-2 story's. Corrected accounting: **moved by name** — only the
      same-family premise, to the tier-2 story; **overturned here, explicitly** — the
      never-exempt and human-substitution clauses, which this change contradicts and must
      therefore amend in that file rather than leave standing.)*
      *(Amended a fourth time 2026-08-14, fifth amendment, Gate-A pass 2 finding 17 — the
      third amendment is **overturned**. It was correct about tier 3: a satisfied human
      closing a gate *was* exactly what `docs/sparring-briefing.md` lines 41–44 forbid, so
      those clauses would have had to be amended. **Tier 3 does not ship.** Under design
      §2.0's scope the record form applies only to things §5 never required, so it never
      substitutes a satisfied human for a clean pass. **Kept, unchanged, and now relied
      upon** — "Advisory, never exempt… do not treat a satisfied human as a substitute for a
      clean pass", which design §4 lists among the files verified true as written. **Kept** —
      the same-family premise's move to the tier-2 story, which the closure does not touch.)*
- [~] ~~Gate B's tier 2 states its own mechanism, named separately from Gate A's~~ —
      **MOVED 2026-08-14** to
      `docs/superpowers/stories/2026-08-14-tier-2-same-family-reviewer-story.md`. Recorded
      here rather than deleted, because a criterion that disappears is indistinguishable
      from one that was never written. Nothing of it is dropped: the asymmetry it names
      (`exec` reviews passed text, `review` reads a git range) is the tier-2 story's
      opening constraint, alongside pass-3 blocker 2, which found the mechanism it called
      for is not achievable in-repo.
- [~] ~~Rider (a): sequential single-branch gate calls are the documented default~~ —
      **MOVED 2026-08-14** to
      `docs/superpowers/stories/2026-08-14-sequential-branch-calls-hook-story.md`. Pass-3
      blocker 1 is why: the unchanged hook counts **each** call as a pass, so the rider
      double-counts the floor in **tier-1 normal operation**. It is a hook change, not the
      §5 prose edit it was bundled as. Nothing dropped — the row's evidence (PR #23's
      sixteen consecutive single-branch calls) moves with it, and its `todos.md` row
      re-points there.
- [ ] Rider (b): the finding-line severity is stated in §5 and in `/workflow-init`'s
      template as a **closed set of permitted tokens** for what the prompt demands of the
      writer, not shown by example only; and the **reader** normalizes an out-of-enum
      token to `MAJOR`.
      *(Amended 2026-08-14, Gate-A spec pass 2 finding 23. Old-condition accounting —
      **kept**: the enum is closed, stated rather than exemplified, in both §5 and the
      template; **narrowed**: "closed" binds the writer's prompt, not the reader's
      acceptance rule. Reason: discarding a well-formed pass over a token would have
      thrown away four real findings on PR #23, which is the incident this rider exists
      for.)*
      *(Amended again 2026-08-15, Gate-A spec pass 4. **Overturned** — "with the mapping
      recorded in that pass's dispositions". Its premise was that normalization would
      otherwise be silent, and pass 4 falsified that: the findings file preserves the original
      token verbatim on the finding line, so the drift is visible to the reader at the moment
      the pass is validated — which is when it matters. No permanence is claimed for either
      artifact: `.context/` is git-ignored and slot collisions have destroyed findings in this
      repository, so the companion bought durability the rest of the system does not provide. **Kept** — the closed enum, the reader's normalization, and the
      PR #23 reason, which are the whole of the rider. Design §6 parks a recording mechanism
      with its trigger; §3 records what the cut clause cost across four passes.)*
- [ ] Rider (c): §5 Mechanics states that on squash-merge the evidence entry is carried
      into the squash body explicitly, because main's tip is the durable record.
- [ ] The compound-commands row in `todos.md` carries occurrence 3 — `git add` and
      `git commit` in one Bash call, empty staged set at PreToolUse, loose STOP —
      observed on PR #23's close.
- [ ] §5 and its `/workflow-init` inline-template mirror agree after the change.
      *(Amended 2026-08-15, Gate-A spec pass 5 finding 10, corrected at pass 9 finding 6.
      **Narrowed** — "agree" means the regions this change edits are identical in both copies:
      edit both, diff those regions, and record in the commit body that they matched.
      **Overturned** — a whole-section reading, since the two §5 copies are not byte-identical
      today and this change does not make them so. **Also overturned** — an interim version of
      this amendment promised enumerated anchors and an extract-and-diff procedure in design
      §5.3; that procedure was **cut** at the termination assessment as prose specifying prose,
      so citing it would demand a mechanism the final design rejects. **Kept** — the obligation
      that the two copies not diverge on what this change writes, and the explicit admission
      that nothing checks the claim. **Dropped** — nothing.)*

## 4. Affected AGENTS.md invariants

- `## What this project is` — "two independent cross-model review gates (a different
  model reviews the design at Gate A and the diff at Gate B)" — ~~tier 3 qualifies this
  sentence by making the gate waivable~~. *(Amended 2026-08-14, fifth amendment, Gate-A pass 2
  finding 18. **Overturned** — no qualification ships. The sentence stays **true and
  unchanged**: nothing in the salvage makes a gate waivable. *(The `AGENTS.md` **file** does
  change — invariant 11's count of the narrow checks in `scripts/check-invariants.sh` goes from
  two to three, design §4. The quoted cross-model-gate sentence is what stays true and
  unchanged; an earlier version of this bullet said the file needed no edit at all.)* **Kept** — that this was the invariant the
  withdrawn design would have had to amend, which is why it is still listed here.)*
- `## What this project is` — "**The product is prompts.** … There is no application
  code, so there is no typechecker to catch a defect; review and
  `docs/prompt-standards.md` are the only gates a prompt passes through." — why
  weakening review costs more here than in a project with a compiler.
- `## Architecture` (Dependency direction) — "on a Codex MCP server exposing both
  `exec` and `review` (the gates key on those two tool names)" — that single dependency
  becoming unavailable is the whole motivating condition.
- `## Key invariants` → Hook, 1 — "**The hook always exits 0.** It is advisory; a
  reminder that can fail closed would make the workflow unusable whenever Codex is down
  or the environment is odd." — already names the motivating condition.
- `## Key invariants` → Hook, 2 — "**Loose in the firing direction.** On uncertainty,
  fire. A missed commit (false ✓) is the dangerous direction" — the fail-open half of
  the pattern must not become a false ✓.
- `## Key invariants` → Prompts and scaffolding, 11 — "**Prompt changes pass
  `docs/prompt-standards.md`** — all 12 checklist items, for any skill, command, agent
  definition, hook message, or scaffolded template."
- `## Don'ts` — "**Never replace a decision procedure without accounting for its old
  conditions.** List what the previous prose required, then mark each one kept, moved,
  or deliberately dropped." — the governing invariant for this change.
- `## Don'ts` — "**Never describe what a gate proves without checking what it actually
  compares.**"
- `## Don'ts` — "**Never rename or delete a doc section without grepping for references
  first.**" — `README.md` links the `docs/coding-workflow.md` anchor
  `#the-two-gates-and-why-independence-is-the-point`.

## 5. Open questions

- None remain open for this story. All five original questions were settled during design
  or moved with tier 2.

*(Amended 2026-08-14, second amendment, Gate-A pass 1 finding 22. The five original
questions are accounted for individually rather than deleted — a question that vanishes is
indistinguishable from one never asked.)*

- **Settled** — "what exactly does the disclosure look like in the closing commit body,
  and how does it sit beside the evidence entry": answered by the design's marker schema
  and carry chain, which carry both.
- **Settled** — "does the ladder extend §2.13's degraded mode or stand beside it": it
  stands beside it; §2.13 is untouched.
- **Settled, then reshaped, then narrowed, then moot** — "does a `high`-risk profile owe a
  cross-model final pass once availability returns": moot as of the fifth amendment, since no
  closure ships that skips a review. The obligation had no owner once the debt machinery went;
  now it has no subject either. Design §6 keeps the tracked-debt row parked with its trigger,
  so the question returns if a recorded exception ever proves to have gone un-followed-up.
  *(Amended 2026-08-14, fourth amendment, Gate-A spec pass 1 finding 14, then subsumed by the
  fifth. The fourth overturned "the profile scales the repayment" — no repayment operation
  existed for a profile to scale. The fifth removes the closure the obligation attached to.)*
- **Moved by name** — "how does the hook treat a non-Codex reviewer pass", to the tier-2
  story. Tier 3 takes no passes, so the hook has nothing to treat.
- **Moved by name** — "is the same-model prohibition narrowed or overturned", to the
  tier-2 story, together with the four sites it governs.

## 6. Suggested size

`story` — one coherent decision: may a human close a gate cycle when no reviewer can run,
and what must be true when they do. Everything else (the disclosure schemas, the carry
chain, the re-review debt) follows from that one answer.

*(Amended 2026-08-14, fifth amendment. **Kept** — the sizing judgement and the framing: one
coherent decision did drive everything else, and the answer turned out to be **no**, which
collapsed the rest exactly as this section predicted it would follow. **Narrowed** — what
remains is well under a `story` as a *decision*, though not as a diff: design §4's path table
is the actual surface, and it is not two files. Describing the residue as "two prompt edits and
a paragraph" understated it and is withdrawn (Gate-A pass 4 finding 19). It is **not**
re-sized down, because the decision that produced it cost three design cycles and nine Gate-A
passes, and a `patch` label on the residue would misrepresent what was decided. The size
records the question, not the diff.)*

*(Amended 2026-08-14, second amendment, Gate-A pass 1 finding 22. **Overturned** — the
original sizing, which was framed around "what does a tier-2 pass mean" and named a split
condition for Gate B's tier-2 mechanism. **Kept** — the `story` size itself and the
judgement that one coherent decision drives the rest. The split it anticipated has since
happened twice, to the tier-2 and sequential-branch-calls stories.)*
