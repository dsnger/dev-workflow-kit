# Reviewer-availability fallback — a degraded-mode ladder for the gates — Story

**Date:** 2026-08-13 · **Size:** story
**Risk:** high · **Security:** standard · **Validation:** battery+check+verification

<!-- No profile log: the profile has never changed. A scoped "mode override" was briefly
     recorded here on 2026-08-14 and WITHDRAWN the same day, before any pass ran under it.
     Gate-A spec pass 3 (blocker 13) established it was not a valid §5 profile change —
     §5's grammar permits a whole effective mode in the header and requires the header to
     carry the override; there is no per-portion override, so recording one invented a
     mechanism the profile system does not have. Pass 3 (finding 14) also established the
     evidence gap it was taken for was not real: a prompt-harness scenario discriminates —
     drive an unavailable reviewer and assert prior refusal versus new conditional closure.
     `battery+check+verification` therefore stands in full and `+check` is owed. The log
     block is absent rather than carrying a withdrawal entry because the log records
     profile CHANGES, and on this story no profile value has ever moved. -->

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

A reviewer-availability ladder exists for **both** gates, with each tier's standing
stated and its degradation visible in the durable record:

- **tier 1** — cross-model, a different model family than the implementer. Today's
  normal, unchanged, and the only tier that satisfies a gate without qualification.
- **tier 3** — the human exception, mid-flight. A **new** exception, not an extension of
  an existing one: §2.13's init-time path scaffolds a gateless project and closes no
  active gate, so nothing today authorizes closing a live cycle. Tier 3 is a **zero-pass
  closure** — a gate waiver, authorized by a human, disclosed in the durable record and
  carrying a re-review debt.
  *(Amended 2026-08-14, second amendment, Gate-A pass 1 finding 21. **Overturned** — the
  claim that tier 3 "exists today for the init-time case". It does not: §2.13 is not a
  tier and waives no active gate, and the design was correct where this story was wrong.
  **Kept** — that §2.13 remains untouched and keeps its gateless answer.)*

Degrading is a **fail-open-with-disclosure**: work continues, and the weakening is
recorded rather than silently absorbed. The failure this must not produce is a degraded
cycle indistinguishable from a tier-1 cycle after the fact — that is the false ✓ the
current prohibition exists to prevent, and the ladder has to answer it rather than
inherit it.

The change also carries two riders and one backlog append that amend the same §5 region,
so one Gate-B cycle covers all of it.

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

- [ ] §5 documents a **two-tier** reviewer ladder covering **both** Gate A and Gate B,
      naming for each tier what it is and whether a cycle closed there satisfies the gate.
      *(Amended 2026-08-14. **Kept** — §5 documents the ladder, covers both gates, and
      states each tier's standing. **Narrowed** — three tiers to two. **Moved by name** —
      tier 2's standing to the tier-2 story. Also **narrowed**: "whether a pass taken
      there satisfies the gate" becomes "whether a cycle closed there satisfies it",
      because tier 3 is a zero-pass closure and has no passes to qualify.)*
- [ ] A degraded cycle is identifiable as such from `main`'s history alone — the
      cycle-closing commit body distinguishes it from a tier-1 cycle, without reference
      to the session that produced it.
      *(Amended 2026-08-14. **Kept** in full — this is the hinge of the narrowing
      argument and is unchanged in force. **Narrowed** — the unit is the cycle rather
      than the pass, following the tier-3 shape; per-pass identification moves to the
      tier-2 story, where passes exist.)*
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
      token to `MAJOR` with the mapping recorded in that pass's dispositions.
      *(Amended 2026-08-14, Gate-A spec pass 2 finding 23. Old-condition accounting —
      **kept**: the enum is closed, stated rather than exemplified, in both §5 and the
      template; **narrowed**: "closed" binds the writer's prompt, not the reader's
      acceptance rule. Reason: discarding a well-formed pass over a token would have
      thrown away four real findings on PR #23, which is the incident this rider exists
      for.)*
- [ ] Rider (c): §5 Mechanics states that on squash-merge the evidence entry is carried
      into the squash body explicitly, because main's tip is the durable record.
- [ ] The compound-commands row in `todos.md` carries occurrence 3 — `git add` and
      `git commit` in one Bash call, empty staged set at PreToolUse, loose STOP —
      observed on PR #23's close.
- [ ] §5 and its `/workflow-init` inline-template mirror agree after the change.

## 4. Affected AGENTS.md invariants

- `## What this project is` — "two independent cross-model review gates (a different
  model reviews the design at Gate A and the diff at Gate B)" — tier 3 qualifies this
  sentence by making the gate waivable, not by changing who reviews.
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
  first.**" — `README.md` links the `coding-workflow.md` anchor
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
- **Settled, then reshaped** — "does a `high`-risk profile owe a cross-model final pass
  once availability returns": every tier-3 closure owes a re-review at any profile,
  because a zero-pass closure means no review happened at all. Profile scales the
  repayment, not whether one is owed.
- **Moved by name** — "how does the hook treat a non-Codex reviewer pass", to the tier-2
  story. Tier 3 takes no passes, so the hook has nothing to treat.
- **Moved by name** — "is the same-model prohibition narrowed or overturned", to the
  tier-2 story, together with the four sites it governs.

## 6. Suggested size

`story` — one coherent decision: may a human close a gate cycle when no reviewer can run,
and what must be true when they do. Everything else (the disclosure schemas, the carry
chain, the re-review debt) follows from that one answer.

*(Amended 2026-08-14, second amendment, Gate-A pass 1 finding 22. **Overturned** — the
original sizing, which was framed around "what does a tier-2 pass mean" and named a split
condition for Gate B's tier-2 mechanism. **Kept** — the `story` size itself and the
judgement that one coherent decision drives the rest. The split it anticipated has since
happened twice, to the tier-2 and sequential-branch-calls stories.)*
