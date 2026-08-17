# Tier 2 — a fresh-context same-family gate reviewer — Story

**Date:** 2026-08-14 · **Size:** story
**Risk:** high · **Security:** high · **Validation:** battery+check+verification+abuse-path

## 1. Problem statement

> **Amended 2026-08-14 — the parent story closed, and tier 3 does not ship.**
> `docs/superpowers/stories/2026-08-13-reviewer-availability-fallback-story.md` was closed
> with a negative answer after nine Gate-A passes: no safe sanctioned zero-pass closure was
> found, and its design records why each class failed
> (`docs/superpowers/specs/2026-08-14-reviewer-availability-fallback-design.md` §1).
> **Old-condition accounting for this section:** **kept** — the problem, unchanged and now
> sharper: when the cross-model reviewer is unavailable there is no reviewing fallback at
> all. **Overturned** — the premise that tier 3 exists as the floor beneath tier 2, and with
> it "tier 3 unblocks work", which nothing now does. **Kept** — that a same-family reviewer
> would sit between tier 1 and nothing, which is the case for building it.

When the cross-model reviewer is unavailable, there is **no fallback that reviews anything**.
Tier 1 (cross-model) is the only tier that ships, and below it the cycle simply does not
close. Between them sits the tier the parent story was originally designed around and could
not ship: a **fresh-context same-family reviewer** whose passes actually review something.

Nothing unblocks work today. Tier 2 would review — worse than tier 1, better
than nothing — and `docs/prompt-standards.md` line 136 records that fresh-context verifier
subagents outperform self-critique. That note grounds *tier 2 beats nothing*; it has never
grounded *tier 2 ≈ tier 1*.

Tier 2 was cut from the parent cycle after Gate-A spec passes 1–3 (116 findings, none
dismissed) established that **its containment is not achievable in-repo**. The three
blockers are the opening evidence, not a blank page:

- **Pass-3 blocker 2 — the trust boundary does not exist.** A custom agent definition does
  not prevent the repository's `CLAUDE.md` hierarchy loading as instructions, and Claude
  Code offers no per-agent switch to omit it. So the prompt product under review can
  address its own reviewer *before* that reviewer treats anything as data. An agent
  definition improves the tool allowlist; it never creates the boundary.
- **Pass-3 M14 — Bash is a capability, not an instruction.** The reviewer needs a git range
  to review a diff, which needs Bash; Bash in the main checkout grants arbitrary repository
  writes, process execution and environment reads. A reviewer that can alter the artifact it
  certifies, while its findings file looks clean, is a worse failure than no reviewer.
- **Pass-3 blocker 4 and pass-2 blocker 1 — capability and input are entangled.** Read/Grep/
  Glob cannot compute a git range; handing over pasted diff text has no truncation
  detection, so a clean findings file can certify a lossy diff. Each fix breaks the other.

The direction to explore is a **sanitized external checkout** — a reviewer surface that does
not load the reviewed repository's instructions and cannot write to it — but that is a
design question, not a decided answer, which is why this is a story and not a patch.

## 2. Desired outcome

A same-family reviewer can take gate passes that are **worth counting**, under a containment
story that is actually true:

- The reviewer does not load instructions from the repository it is reviewing, so the
  artifact under review cannot steer it.
- The reviewer cannot write to the reviewed repository, so it cannot alter what it certifies.
  *(Amended 2026-08-14, Gate-A pass 2 finding 20. **Narrowed** — "or exfiltrate what it reads"
  is withdrawn: a reviewer that reads content and emits findings already has an output
  channel, and an externally executed one may add network and environment channels, so a
  write barrier is an **integrity** control and not a confidentiality one. **Kept** — the
  write barrier itself and its reason. **Open** — whether an exfiltration control is wanted
  at all, and what would demonstrate it, now belongs in §5.)*
- It can still read the reviewed content losslessly — including a complete git range for
  Gate B, and the files outside the diff that §5's standing falsification lens requires.
- Its passes are **disclosed as same-family** in the cycle-closing commit body, and are never
  presentable as tier 1. *(Amended 2026-08-14, Gate-A pass 2 finding 19. **Narrowed** — from
  "wherever the ladder already discloses degradation": there is no ladder and no such site, so
  this story owes its **own** disclosure form rather than inheriting one. **Kept** in full —
  that a tier-2 pass is disclosed as same-family and never counted as tier 1, which is the
  requirement, not the mechanism.)*
- Where containment cannot be demonstrated, tier 2 reports itself **unavailable** rather
  than running with a boundary it does not have.

## 3. Acceptance criteria

- [ ] A named abuse scenario is demonstrated: an instruction planted in a reviewed artifact
      attempts to steer the reviewer, and the expected control **rejects or contains it**,
      with the observation recorded. (The `+abuse-path` obligation; this criterion is the
      story's forcing function.)
- [ ] The reviewer provably does not load the reviewed repository's `CLAUDE.md` hierarchy —
      demonstrated, not asserted.
- [ ] The reviewer cannot write to the reviewed repository, demonstrated by an attempted
      write that fails.
- [ ] A Gate-B tier-2 pass reviews a **complete** range: the authoritative source set is
      named, and an exact comparison — content hashes over the diff's paths plus the
      out-of-diff files the falsification lens requires — establishes the reviewed input
      matches it, with any residual case bounded rather than assumed.
      *(Amended 2026-08-14, Gate-A pass 2 finding 21. **Narrowed** — "a check that would fail
      if the input were truncated" detects one mutation and does not establish losslessness,
      which is the gate-proof calibration Don't. **Kept** — that completeness must be
      demonstrated rather than assumed.)*
- [ ] A tier-2 pass is identifiable as same-family from `main`'s history alone, in a record
      form **this story defines**, and is never counted or presented as tier 1.
      *(Amended 2026-08-14, Gate-A pass 2 finding 19. **Overturned** — the delegation to the
      parent story's AC 2, which now covers a human's decision about optional work and
      supplies nothing a tier-2 pass could use. **Kept** in full — the requirement itself,
      which was always this story's to satisfy.)*
- [ ] When the containment preconditions cannot be met, tier 2 is unavailable and says so
      with a named cause — it never degrades silently into an uncontained reviewer.
- [ ] The four prohibition sites — `/workflow-init` §2.13, `docs/coding-workflow.md` § *The
      two gates…*, `README.md`, `plugins/dev-workflow/agents/finding-triage.md` — plus
      `docs/sparring-briefing.md`'s family-granularity premise are accounted for explicitly,
      each condition marked kept, narrowed or deliberately overturned. **Inherited unchanged
      from the parent story's AC 4**, which deferred it here because a human exception is not
      a model reviewing its own work. *(Amended 2026-08-14: the parent's reason is unchanged
      by its closure — the four sites forbid a same-model **reviewer**, which is this story's
      subject and was never the parent's.)*

## 4. Affected AGENTS.md invariants

- `## What this project is` — "two independent cross-model review gates (a different model
  reviews the design at Gate A and the diff at Gate B)" — tier 2 is the clause that qualifies
  this most directly.
- `## What this project is` — "**The product is prompts.** … review and
  `docs/prompt-standards.md` are the only gates a prompt passes through." — and here the
  product being reviewed is what can steer the reviewer.
- `## Architecture` (Dependency direction) — "on a Codex MCP server exposing both `exec` and
  `review` (the gates key on those two tool names)" — a tier-2 reviewer is not that server.
- `## Key invariants` → Hook, 2 — "**Loose in the firing direction.** … A missed commit
  (false ✓) is the dangerous direction."
- `## Key invariants` → Prompts and scaffolding, 11 — "**Prompt changes pass
  `docs/prompt-standards.md`** — all 12 checklist items, for any skill, command, agent
  definition, hook message, or scaffolded template."
- `## Don'ts` — "**Never describe what a gate proves without checking what it actually
  compares.**"
- `## Don'ts` — "**Never replace a decision procedure without accounting for its old
  conditions.**"

## 5. Open questions

- What is the reviewer surface? A sanitized external checkout, a separate harness with an
  independently controlled system prompt, or something else — and what does each cost an
  ordinary user who has no infrastructure?
- Can a reviewer be given a lossless git range **without** general Bash? If not, is a
  read-only worktree plus a narrowly scoped diff helper sufficient?
- Do tier-2 passes count toward the three-pass floor at all, given the parent cycle
  established the hook cannot see them?
- Is tier 2 worth building, given nothing else unblocks work? *(Amended 2026-08-14.
  **Overturned** — the original framing, "once tier 3 exists", and its premise that tier 3
  unblocks work. **Kept, and strengthened** — the question itself: tier 2 adds review quality
  at real complexity cost. What changed is the alternative it is weighed against, which is no
  longer a zero-pass closure but **stopping until the reviewer returns**, or an operational
  bridge such as a second key or another vendor.)*
- Does a contained tier-2 reviewer change what the four prohibition sites should say?
  *(Amended 2026-08-14, Gate-A pass 2 finding 19. **Overturned** — "or does the narrowing
  principle the parent shipped already cover it": the parent shipped no narrowing principle,
  since tier 3 was withdrawn and the four sites were left untouched. **Kept** — the question,
  which this story must now answer from scratch.)*
- **New, from the parent's closure:** what is the disclosure record form for a same-family
  pass, and what confidentiality boundary (if any) does containment owe (findings 19, 20)?

## 6. Suggested size

`story` — one coherent question (can a same-family reviewer be contained well enough to be
worth counting) with a bounded set of candidate surfaces. It becomes
`epic-needs-splitting` if the answer requires new infrastructure a user must install, in
which case the split is reviewer-surface first, ladder integration second.
