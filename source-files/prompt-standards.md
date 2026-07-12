# Prompt Standards

Skills (`.claude/skills/`), gate prompts (CLAUDE.md §5), hook messages
(`.claude/hooks/`), and spec/plan templates are prompts. When authoring or
changing one, it must pass the checklist below — Gate A reviews skill specs
against these criteria via AGENTS.md.

Living references (consult, don't copy — copies go stale):

- Anthropic prompting best practices: https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/claude-prompting-best-practices
- Model-specific pages (pick the target model's page): https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/overview
- OpenAI/Codex prompting guide — applies to the Codex gate prompts (Gate A/B
  run on an OpenAI model, not Claude): https://developers.openai.com/codex

## Checklist (each item must be verifiably true)

1. **Target model named.** The prompt states which model executes it (Claude
   via Claude Code, or Codex via `mcp__codex__*`), and the author checked that
   model's current prompting page. Why: recommendations differ per model and
   change between generations.
2. **Success criteria explicit.** The prompt defines what "done" looks like in
   checkable terms (e.g. "tsc exit 0", "story has ≥3 acceptance criteria"),
   never "make it good". Why: strong criteria let agents loop independently
   (CLAUDE.md §4).
3. **Stop conditions defined.** When to stop, escalate, or ask the user —
   especially for looping/agentic prompts. Why: prevents runaway loops and
   silent scope drift.
4. **Output format specified with an example.** Expected structure shown, not
   described. Why: examples constrain format better than prose.
5. **Structured sections.** Context → task → rules → output format, separated
   by headings or XML tags. Why: models parse delimited structure more
   reliably than flowing prose.
6. **Rules carry their why.** Each constraint states its reason in one clause.
   Why: models follow motivated rules better, and reviewers can judge whether
   the rule still applies.
7. **No contradictions with CLAUDE.md / AGENTS.md.** New prompt text must not
   conflict with existing instructions; if it supersedes one, update the old
   text in the same change. Why: contradictory instructions degrade
   compliance unpredictably.
8. **Token-lean.** No duplicated content from AGENTS.md/CLAUDE.md (reference
   instead), no boilerplate. Why: context budget is shared with the actual
   task.
9. **Positive instructions.** Say what to do, not what to avoid ("write
   flowing prose" instead of "don't use markdown"). Why: per Anthropic's best
   practices, positive framing steers current models more reliably.
10. **Calibrated emphasis.** Reserve MUST/CRITICAL/ALL-CAPS for genuinely hard
    rules; default to plain wording ("Use X when …"). Why: Claude 4.6+ models
    follow instructions more literally and overtrigger on aggressive language
    (documented in the best-practices page). Existing heavy emphasis (e.g.
    CLAUDE.md §5 gate language) is a deliberate exception for discipline
    gates — new prompts need a stated reason to use it.

## Verified model-specific notes (read 2026-07-04 — re-verify per Revalidation)

Distilled from the model-specific pages; the linked pages are authoritative.

- **Less scaffolding on stronger models.** Skills/prompts written for prior
  models are often too prescriptive and degrade output quality on newer ones
  (Fable 5 page). On a model upgrade, test with instructions *removed* before
  adding more.
- **Review prompts: coverage first, filter later.** "Only report high-severity"
  makes current models silently drop real findings. Finding stage must ask for
  every issue with confidence + severity; ranking/filtering is a separate step
  (Opus 4.8 / Sonnet 5 pages). Gate B's Blocker/Major filter is downstream —
  the finding prompt itself must request full coverage.
- **Ground progress claims.** In long runs, instruct: audit each claim against
  a tool result before reporting; unverified work is reported as unverified
  (Fable 5 page). Belongs in executing/TDD prompts.
- **Fresh-context verifier subagents outperform self-critique** (Fable 5 page)
  — independent confirmation of the cross-model gate design.
- **Never instruct "show your reasoning in the response".** Triggers the
  reasoning-extraction refusal category on Fable 5; read structured thinking
  output instead.
- **Literal instruction following.** Current models don't generalize scope on
  their own — state it ("apply to every section, not just the first").

## Escalation

Recurring prompt-quality findings follow the same ladder as code findings
(CLAUDE.md): prose note → checklist item here → template change. Prompts are
artifacts; `harden-finding` treats them like code. Run the `harden-finding` skill
(`.claude/skills/harden-finding/SKILL.md`) to apply a rung and record it in
`docs/hardening-log.md`.

## Revalidation

On a model generation change (new Claude model in Claude Code, new Codex
model for the gates): re-check this doc against the then-current
model-specific pages. Tracked with the tooling revalidation entry in todos.md.
