# Reviewer-availability fallback — a degraded-mode ladder for the gates — Story

**Date:** 2026-08-13 · **Size:** story
**Risk:** high · **Security:** standard · **Validation:** battery+check+verification

## 1. Problem statement

Both review gates depend on a single external reviewer, and there is no sanctioned
degraded path when it is unavailable. §5 requires three clean passes per gate; when the
vendor is out of quota, no pass can be taken, so no cycle can close and all work stops.
Observed: a five-day full process stall, 2026-08-05 to 2026-08-10, from one vendor's
quota.

The one degraded mode that exists is `/workflow-init` §2.13, and it does not reach this
case: it fires at **init time** when the preflight finds Codex unconfigured, and its
answer is to scaffold a project that is explicitly gateless. A project already running
the gates that loses its reviewer mid-flight falls outside it.

Four shipped sites currently forbid the obvious fallback, and they forbid it in a form
that covers what is proposed here: `/workflow-init` §2.13 ("Do not offer a same-model
fallback reviewer… explicitly gateless is honest while implicitly self-reviewed is a
false ✓"), `docs/coding-workflow.md` § *The two gates, and why independence is the
point* ("be gateless — not self-reviewed… strictly worse than no review, because a
false ✓ *stops you looking*"), `README.md`'s without-Codex paragraph, and
`plugins/dev-workflow/agents/finding-triage.md` ("You never count as a Gate A or Gate B
pass"). `docs/sparring-briefing.md` states the premise at **family** granularity — "the
same model family as the coding agent, so you share its blind spots" — so a
fresh-context same-family reviewer is inside the prohibition as written, not a case it
failed to anticipate.

So the problem is not only that availability blocks work. It is that the only relief
currently reachable is total gatelessness, and the workflow has no vocabulary for a
review that happened but was weaker than tier 1.

## 2. Desired outcome

A reviewer-availability ladder exists for **both** gates, with each tier's standing
stated and its degradation visible in the durable record:

- **tier 1** — cross-model, a different model family than the implementer. Today's
  normal, unchanged, and the only tier that satisfies a gate without qualification.
- **tier 2** — a fresh-context same-family reviewer. Passes taken here count toward the
  floor and are **disclosed as same-family** in the pass record and again in the
  cycle-closing commit body, so a later reader of `main` can tell which passes were
  degraded without access to the session that took them.
- **tier 3** — the documented human exception. Exists today for the init-time case;
  its reach over the mid-flight case is settled by this change.

Degrading is a **fail-open-with-disclosure**: work continues, and the weakening is
recorded rather than silently absorbed. The failure this must not produce is a tier-2
pass indistinguishable from a tier-1 pass after the fact — that is the false ✓ the
current prohibition exists to prevent, and the ladder has to answer it rather than
inherit it.

The change also carries three riders and one backlog append that amend the same §5
region, so one Gate-B cycle covers all of it.

## 3. Acceptance criteria

- [ ] §5 documents a three-tier reviewer ladder covering **both** Gate A and Gate B,
      naming for each tier what it is and whether a pass taken there satisfies the gate.
- [ ] A tier-2 pass is identifiable as such from `main`'s history alone — the
      cycle-closing commit body distinguishes it from a tier-1 pass, without reference
      to the session that took it.
- [ ] Gate B's tier 2 states its own mechanism, named separately from Gate A's, because
      `mcp__codex__exec` reviews text the caller passes while `mcp__codex__review` reads
      a git range.
- [ ] Every site currently forbidding a same-model fallback is accounted for explicitly
      — `/workflow-init` §2.13, `docs/coding-workflow.md` § *The two gates…*, `README.md`,
      `plugins/dev-workflow/agents/finding-triage.md`, and
      `docs/sparring-briefing.md`'s family-granularity premise — with each condition
      marked kept, narrowed, or deliberately overturned per the AGENTS.md decision-procedure
      Don't. No site is left asserting the ladder is forbidden.
- [ ] Rider (a): sequential single-branch gate calls (`reviewType: spec`, then
      `quality`) are the documented default in §5 and in `/workflow-init`'s template,
      replacing the per-branch-file prescription as the primary instruction.
- [ ] Rider (b): the finding-line severity is stated in §5 and in `/workflow-init`'s
      template as a **closed set of permitted tokens**, not shown by example only.
- [ ] Rider (c): §5 Mechanics states that on squash-merge the evidence entry is carried
      into the squash body explicitly, because main's tip is the durable record.
- [ ] The compound-commands row in `todos.md` carries occurrence 3 — `git add` and
      `git commit` in one Bash call, empty staged set at PreToolUse, loose STOP —
      observed on PR #23's close.
- [ ] §5 and its `/workflow-init` inline-template mirror agree after the change.

## 4. Affected AGENTS.md invariants

- `## What this project is` — "two independent cross-model review gates (a different
  model reviews the design at Gate A and the diff at Gate B)" — the ladder qualifies
  this sentence directly; tier 2 is not a different model.
- `## What this project is` — "**The product is prompts.** … There is no application
  code, so there is no typechecker to catch a defect; review and
  `docs/prompt-standards.md` are the only gates a prompt passes through." — why
  weakening review costs more here than in a project with a compiler.
- `## Architecture` (Dependency direction) — "on a Codex MCP server exposing both
  `exec` and `review` (the gates key on those two tool names)" — a tier-2 reviewer is
  not that server, and the hook keys on those names.
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

- How does the hook treat a non-Codex reviewer pass? The counter is not evidence —
  findings files are — and the hook keys on `mcp__codex__*` tool names, so a tier-2
  pass may be uncountable by construction.
- Does a `high`-risk profile owe a cross-model final pass once availability returns, or
  does a disclosed tier-2 clean pass close the cycle permanently?
- What exactly does the disclosure look like in the closing commit body, and how does it
  sit beside the evidence entry that body already carries?
- Is the shipped same-model prohibition **narrowed** (fresh-context same-family is
  admitted as a distinct case) or **overturned** (the false-✓ argument is judged wrong)?
  The answer determines what happens to four shipped sites.
- Does the ladder extend `/workflow-init` §2.13's degraded mode to the mid-flight case,
  or stand beside it as a separate mechanism?

## 6. Suggested size

`story` — one coherent decision (does a degraded tier exist, and what does a tier-2 pass
mean) with everything else following from it. It sits at the top of the band: if
brainstorming finds that Gate B's tier-2 mechanism needs its own design rather than a
paragraph, split that out as a second spec and keep the ladder, riders and disclosure
here.
