# Risk, security, and validation profiles for the workflow — Story

**Date:** 2026-07-26 · **Size:** story

## 1. Problem statement

Review cost is the limiting factor of this workflow, and every story pays the same
price regardless of what it risks. Counted from the review artifacts:
infinite-portfolio-canvas spent 51 Gate-A pass files across 2 stories (spec 14, plan
14, replan 4, amend 12, a3-spec 7); this repo's just-closed canvas field-findings round
spent 23 Gate-A pass files and 160 findings across its two PRs — 6 on the combined
plan, then 9 and 8 after the 2-PR split — of which the second PR's 8 passes and 45
findings went on prompt-text and docs changes alone. The gates have one intensity and
no vocabulary separating "this touches payments" from "this fixes a typo", so a trivial
change is reviewed like a migration, and a high-risk change is reviewed with the same
generic questions as a trivial one. Nothing records what a story risks, so CLAUDE.md
§5's "Skip ONLY trivial changes" rests on unrecorded judgement.

## 2. Desired outcome

Every story carries two human-confirmed profile axes — risk and security relevance —
plus a validation mode derived from them, and the gates spend effort in proportion:
high risk asks *different* review questions (threats, abuse, rollback, data loss,
idempotency, compatibility, observability), trivial legitimizes the documented skip
with a recorded reason. Different questions, not more identical passes. Why: profiles
are the economics lever on the workflow's dominant cost, and the precondition for the
batch/orchestrator mode parked in todos — that mode cannot decide what to batch without
knowing what each item risks.

## 3. Acceptance criteria

- [ ] Intake proposes both axes with their levels (risk: trivial | standard | high;
      security relevance: none | standard | high) and the human confirms or corrects
      them before the story is written.
- [ ] Risk `high` is reachable by named domain triggers — auth, permissions, payments,
      migrations, data deletion, public APIs, personal data, supply chain — not by
      unaided judgement.
- [ ] The validation mode is derived from the two axes and presented as a
      recommendation the human can override; it is never asked as a third question.
- [ ] All three values are recorded in one fixed location that survives spec revisions,
      so a later reader and a later gate read the same profile.
- [ ] A mid-story finding revealing higher risk than the intake profile assumed can
      upgrade the profile, and the upgrade is recorded — silently continuing under a
      stale profile is not an available outcome.
- [ ] The §5 gate prompts consume the profile: at risk `high` they carry the additional
      lenses; at `trivial` the documented skip is available with its reason recorded.
- [ ] For security relevance standard | high, the story states *where* security content
      lives (the spec's existing sections and AGENTS.md invariants) — no new standalone
      security section is introduced anywhere.
- [ ] Whatever the profile changes about CLAUDE.md §5, the 3-pass floor included,
      changes in both the `/workflow-init` template and this repo's own CLAUDE.md in the
      same commit.
- [ ] `todos.md` reflects what shipped: the P2+P6 row is **split** — the profile and lens
      work closes, while P6's promised "security sections in the intake, spec and gate
      templates" is recorded as deliberately rejected with its reason — and P5 light's
      trigger is re-pointed at "the first story that runs under profiles".
      *(Amended 2026-07-26 during Gate A, spec pass 6: the original criterion said "P2+P6
      closed", which would claim scope that was deliberately not built.)*
- [ ] Scope holds: nothing under `plugins/dev-workflow/hooks/` changes, and no new
      script is added.

## 4. Affected AGENTS.md invariants

- `## Prompts and scaffolding` — "8. **`/workflow-init`'s templates stay inline** in the
  command body."
- `## Prompts and scaffolding` — "9. **`/workflow-init` never overwrites silently.**
  Idempotent: missing → write; identical → report unchanged; present and different →
  show the diff and ask; additive files … → merge."
- `## Prompts and scaffolding` — "10. **The base taxonomy stays stack-neutral.** Project
  vocabulary — tables, auth helpers, framework APIs — goes only in that project's
  `docs/hardening-taxonomy.md`".
- `## Prompts and scaffolding` — "11. **Prompt changes pass
  `docs/prompt-standards.md`** — all 12 checklist items, for any skill, command, agent
  definition, hook message, or scaffolded template."
- `## Packaging` — "12. **A plugin change requires a version bump.**"
- `## Don'ts` — "**Never rename or delete a doc section without grepping for references
  first.**"
- `## Don'ts` — "**Never describe what a gate proves without checking what it actually
  compares.**"

## 5. Open questions

- Do profiles apply to stories already in flight (canvas has two on a long-lived
  branch), or only to stories entering intake after this ships?
- Does `trivial` relax Gate A as well, or only the Gate-B triviality skip that §5
  documents today?
- Deferred by decision, not open: a dedicated spec security section is *not* built now
  — if field use shows high-security content scattering incoherently across spec
  sections, that recurrence is its trigger.

## 6. Suggested size

story — one coherent decision (two axes + derived mode + lens paragraphs) that fits one
spec → plan → PR, even though it touches the intake skill, the `/workflow-init`
templates, §5 in both copies, and docs.
