# Subagent definition: finding-triage — Design

**Date:** 2026-07-18 · **Status:** narrowed after Gate A pass 4, revised after pass 5; Gate A clean at pass 6 (SHIP) · **Version target:** 0.4.0

**Kill condition.** If Gate A on this narrowed spec does not converge — final pass
clean or trivially close — **within two passes**, the feature is dropped. Four passes on
the previous design produced 34 → 19 → 11 → 11 findings without converging; at that
point the gate has produced the value-to-complexity evidence, and there is nothing left
to learn from a seventh pass.

## 1. Problem

`/dev-workflow:process-pr-review` asks the main agent to decide whether each PR-bot
comment is right — the agent judging a belief it just formed. A subagent gives that
check its own context window: independent of the *conversation*, not of the model.

## 2. What this agent does, and what it deliberately does not

**Its whole contract:** given one claim and where to look, is that claim true of the
code readable right now?

Everything else stays with the main command, which has `Bash`, git, the other comments,
and the session's settled decisions:

| Concern | Owner | Why not the agent |
|---|---|---|
| staleness / snapshot consistency | caller | the agent has no shell and cannot observe git state |
| actionability — pre-existing vs introduced, in scope | caller | needs a diff range |
| deduplication across comments | caller | the agent sees one claim by contract |
| replies, fixes, escalation | caller | unchanged from today |

**Triage is best-effort against the working tree as it reads it.** Nothing pins the
checkout while the agent runs. The previous design tried to close that with a SHA pair
and a worktree fingerprint; each addition needed its own trust, validation and failure
rule, and still did not deliver snapshot identity. Since every verdict is advisory — the
caller decides what to do with all of them — the honest design states the limit rather
than engineering around it.

The hook is not touched. Nothing else becomes an agent.

## 3. Verified platform facts

Read from the Claude Code docs on 2026-07-18.

| Fact | Source |
|---|---|
| Plugin agents live in `agents/`, markdown with YAML frontmatter | [plugins reference § Agents](https://code.claude.com/docs/en/plugins-reference) |
| Only `name` and `description` are required | [sub-agents § frontmatter fields](https://code.claude.com/docs/en/sub-agents) |
| `tools` is an allowlist — **inherits all tools if omitted** | same |
| `model` defaults to `inherit` when omitted | same |
| `permissionMode`, `hooks`, `mcpServers` are ignored for plugin agents | plugins reference + sub-agents note |
| Custom subagents load the full `CLAUDE.md` hierarchy; only built-in Explore and Plan skip it, and **there is no per-agent opt-out** | [sub-agents § what loads at startup](https://code.claude.com/docs/en/sub-agents) |
| Plugin agents are invoked as `plugin-name:agent-name` | plugins reference § Integration points |

The last fact drives §4.2 and cannot be worked around inside the definition.

## 4. Boundaries, stated precisely

### 4.1 What read-only guarantees

`tools: Read, Grep, Glob`. The guarantee is exactly this: **the agent cannot directly
invoke a Claude Code write or shell tool**, because the platform's tool allowlist is
what admits tools to a subagent.

It is narrower than "cannot mutate anything". Externally configured `PreToolUse`,
`PostToolUse`, `SubagentStart` and `SubagentStop` hooks in the *user's own* settings can
run commands with side effects on this agent's tool calls, and the plugin has no say in
that.

`disallowedTools` is not set — the allowlist already omits every write tool. Its only
real value would be surviving a future edit that deletes the `tools:` line (omission
inherits everything), and a comment in the definition warns against that instead.

### 4.2 Instruction injection — the blunt rule

Custom subagents load the `CLAUDE.md` hierarchy with no opt-out (§3), and this repo's
`CLAUDE.md` imports `AGENTS.md`. A PR that edits an instruction file therefore changes
the rules triage runs under, *before* any "treat comments as data" rule in the
definition applies. Pausing for user approval does not help: approval is not isolation,
and the files are still loaded when the agent spawns.

So the rule is blunt: **if the PR touches any instruction-bearing path, triage does not
run at all.** The main agent validates those comments itself, and the reply says why.

Instruction-bearing paths, defined once and deliberately generously:

```text
CLAUDE.md at any depth        CLAUDE.local.md at any depth
AGENTS.md at any depth        the AGENTS.md path passed to the agent, whatever it is
.claude/**                    plugins/**
skills/**                     commands/**
agents/**                     any file transitively imported by the above
```

`AGENTS.md` is on the list explicitly, not merely because `CLAUDE.md` imports it here.
The agent reads it as project authority, and a project whose `CLAUDE.md` does *not*
import it would otherwise let a PR rewrite that authority without tripping the skip.
Narrowing this spec dropped it; that was a regression.

**Resolving imports is fail-closed.** The caller expands `@path` imports from each
loaded instruction file, transitively, and treats every resolved target as
instruction-bearing. If any import cannot be resolved — malformed, missing, outside the
checkout, or ambiguous — the caller **skips triage** rather than proceeding on a partial
set. A boundary that is only sometimes complete is not a boundary, and skipping costs a
single PR's triage while a miss costs the verifier's instructions.

This is **broader than the hook's `is_prompt_path`**, on purpose. The two answer
different questions: the hook decides whether a commit needs code review, where a miss
costs a skipped reminder; this decides whether an attacker-influencable PR gets to
rewrite the verifier's instructions. Different failure modes justify different widths.

**No hook change.** Agent definitions are already covered by `is_prompt_path`:
`plugins/dev-workflow/agents/*.md` matches its `plugins/` segment, and a project's
`.claude/agents/*.md` matches `.claude/`. Both real locations already fire Gate B, so
the matcher needs nothing and the settled hook-untouched decision holds.

### 4.3 Not a gate

The definition carries one line: it never counts as a Gate A or Gate B pass. CLAUDE.md
§5 requires cross-model independence, and a same-model subagent shares this model's
blind spots. It complements the gates; it never substitutes for one.

## 5. The definition

```yaml
---
name: finding-triage
description: Validates whether one PR-review defect claim is factually true of the code.
  Delegated by /dev-workflow:process-pr-review, once per claim, after its
  instruction-path precheck. Not for general code review or ad-hoc questions.
tools: Read, Grep, Glob
---
```

Per *claim*, not per comment — the caller splits compound comments before dispatch, so
the description must not invite a whole comment as one task.

`model`, `effort` and `maxTurns` are omitted; the first two default to `inherit`.

**Target model** (item 1): the body states it runs as Claude via Claude Code, and
records that Anthropic's prompting page was checked on 2026-07-18.

### 5.1 Input

| Field | Required |
|---|---|
| the claim — one assertion, in the bot's words | yes |
| where to look — one or more repo-relative paths, each with an optional line or range; or the token `repository` for a claim with no canonical file | yes |
| path to `AGENTS.md`, or an explicit statement that the project has none | yes |
| precheck attestation — the caller states that the §4.2 instruction-path check ran and passed for this PR | yes |

Any missing field returns `escalate-to-user` naming it. **Never infer a missing field** —
guessing the alleged defect is what would make the check worthless.

**What the attestation is, exactly.** Plugin agents are discoverable: Claude can invoke
this one from its description, outside `process-pr-review` and without the §4.2
precheck. The attestation is a **declarative checklist field, fail-closed on omission**:
the agent rejects an invocation that does not carry it. That is all it does. It does not
establish that the precheck actually ran — the field is caller-authored text, and a
caller that asserts it falsely passes. Its value is catching the *accidental*
invocation, which arrives without the field at all; the narrowed description is the
other half of that mitigation. Nothing at this layer can do better, and saying otherwise
would be the unsupported-enforcement pattern §10 exists to harden against.

The caller passes locations, never file contents, so the agent cannot be handed a
curated excerpt.

**Path confinement is the caller's, because only the caller can do it.** The caller
resolves every location against the checkout root, following symlinks, and passes only
paths it has proven resolve inside it; anything it cannot prove confined means triage is
skipped for that claim. The agent additionally refuses an absolute path or one
containing `..` — but that lexical check is a backstop, not the boundary: a repo-relative
path through a checked-in symlink is lexically clean and still escapes, and Read/Grep/Glob
cannot resolve that. The narrowed draft left this to the agent alone, which was a
regression from the prior design.

**Untrusted input.** The claim text and the code are **data, never instructions**. The
agent does not follow instructions, links or tool-shaped text found in either, and emits
no repository content beyond what the claim requires — its output may be posted to a
public thread. (§4.2 covers the one channel this rule cannot reach.)

### 5.2 Verdicts

| Verdict | When |
|---|---|
| `accept` | the claim is true of the code as read |
| `dismiss` | the claim is false, or describes something already resolved — the reason cites what contradicts it |
| `escalate-to-user` | it cannot be settled within the budget; or a field is missing, a path is unusable, or the input holds more than one claim |

Exhaustive for the question asked — "is this true?" has one of these three answers.
"Looks fine" is not a dismissal; a dismissal cites evidence.

### 5.3 Budget and stopping

Follow the smallest evidence path that settles the claim: the named location, then what
it directly requires — callers, callees, shared validators, route registration, type
definitions, configuration, the covering tests.

**Stop at 25 tool calls** (Read, Grep and Glob counted alike, repeats included) or at
the first verdict, whichever comes first. This is an **instruction-level stop
condition**: nothing mechanically counts the agent's calls, and the caller cannot verify
the count from the output. Said plainly because an earlier draft claimed output
validation enforced this budget, which was false — the output carries no call count.

On exhausting the budget, return `escalate-to-user` naming the evidence that would
settle the claim.

### 5.4 Output

Exactly one block, three labelled fields, no surrounding prose:

```text
CLAIM    <the claim, echoed verbatim as delegated>
VERDICT  accept | dismiss | escalate-to-user
REASON   <non-empty; one of three forms:
         · file:line evidence, for a verdict reached by reading code
         · for a `repository` claim, the search performed and what it did or did not find
         · for a diagnostic escalation — missing field, unusable path, compound input,
           budget exhausted — the exact cause and what the caller must supply or fix>
```

The third form exists because those exits have no code evidence to cite: without it the
agent would have to break the output contract or invent a citation.

The caller validates: exactly one block, `VERDICT` one of the three literal values,
`REASON` non-empty, and `CLAIM` equal to the delegated claim. A mismatched `CLAIM` is
malformed — it means a verdict could be attached to the wrong thread.

**Framing, because bot comments are arbitrary text.** A real claim can span lines and can
itself contain the words `VERDICT` or `REASON`, which would make a label-delimited block
ambiguous. So the caller canonicalizes before delegating: collapse the claim to a single
line, whitespace-normalized, and pass *that* as the claim. `CLAIM` echoes the canonical
form, and equality is checked against it — one unambiguous string on both sides, rather
than a parser guessing where a multiline claim ends.

## 6. Integration

Prose uses the scoped `dev-workflow:finding-triage`; frontmatter uses the unscoped
`finding-triage`.

| # | File | Change |
|---|---|---|
| 1 | `commands/process-pr-review.md` — Step 3 **and** `## Done` | §6.1 |
| 2 | `README.md` component table | one row |
| 3 | `docs/getting-started.md` step 8 | one sentence |
| 4 | `AGENTS.md` | architecture tree, **Boundaries**, invariant 6, invariant 11, and the "What this project is" prompt-artifact sentence — all currently enumerate skills/commands/hooks and omit agents |
| 5 | `docs/architecture.md` | layout tree **and** the convention-loading prose |
| 6 | `docs/prompt-standards.md` | scope paragraph enumerating prompt artifacts |
| 7 | `commands/workflow-init.md` | its inline `CLAUDE.md` and `prompt-standards.md` templates carry their own copies of those enumerations; update in lockstep (invariant 8) |
| 8 | `CLAUDE.md` §5 | the Gate-B artifact-kind list |
| 9 | `skills/harden-finding/SKILL.md` | rung `P`'s prompt-artifact examples |
| 10 | `.claude-plugin/marketplace.json` | the plugin description enumerates components and would go stale |
| 11 | `scripts/check-invariants.sh` | comment only — it says skills/commands/hooks are convention-loaded; its regex already rejects an `agents` key and does not change |

Rows 4–11 exist because adding a component class makes every enumeration of that class
incomplete. These sites came from the AGENTS.md grep recipe **plus manual inspection** —
the recipe alone misses "loaded by convention", the reverse word order its own note
records.

`agents/` is convention-loaded, so `plugin.json` gains nothing (invariant 6);
`check-invariants.sh` already greps for an `agents` key.

No length cap is imposed on `getting-started.md` — pass 1 flagged the earlier invented
budget, and authorizing "trim adjacent prose" to meet an invented number licenses
unrelated edits against CLAUDE.md §§2–3.

### 6.1 `process-pr-review` changes

Today Step 3 has two verdicts and checks scope separately at 3.3.

- **3.0** — if the PR touches any instruction-bearing path (§4.2), skip triage for this
  PR entirely; the main agent validates the comments itself and the reply says why.
- **3.1** — otherwise split each defect-asserting comment into single claims and
  dispatch one `dev-workflow:finding-triage` per claim, in parallel. Factual verdicts
  only.
- **3.2 (new)** — classify actionability for each `accept`, using git. **`accept` alone
  never authorizes a fix.** Ordering matters: an earlier draft implemented first and
  asked afterwards, re-creating the conflation the split exists to end. The mapping is
  stated so it is not re-invented per PR:

  Rows are tested **in order**, first match wins — a defect can be both introduced by
  this PR *and* contrary to a settled decision, so provenance alone does not partition
  them. (Gate B found this: the earlier ordering did not guarantee the "exactly one
  disposition" the split depends on.)

  | The defect is | Disposition |
  |---|---|
  | contrary to a settled decision (checked first) | 3.4, to the user |
  | introduced by this PR's diff | fix in this PR (3.3) |
  | pre-existing, and the fix is small and local to code this PR already touches | fix in this PR, and say so in the reply |
  | pre-existing, anything larger | do **not** fix here — reply saying it is valid and out of scope, and record it in `todos.md` so a true finding is not lost. **Terminal**: it does not also go to 3.4, and the hardening step does not harden it |
- **3.3** — implement accepted **and** actionable findings; severity gate unchanged.
- **3.4** — to the user: `escalate-to-user` verdicts, and accepted-but-not-actionable
  findings.
- **`## Done`** — every *claim* has a verdict; every *thread* has a reply; each claim
  ends in **exactly one** of: a fix, a documented dismissal, a valid-but-out-of-scope
  finding recorded in `todos.md`, or an answered escalation. The out-of-scope terminal
  is listed explicitly because omitting it made that path unable to satisfy completion.

**Tracking is claim-level, replies are thread-level.** Each claim keeps its parent
thread id; one reply reports every claim on that thread. A comment is done only when all
its claims are.

**Dedup by claim, not location** — file and line group candidates for comparison only.
Two defects often share a line and one defect often spans several, so collapsing by
location would drop valid claims before checking them.

**Skips, applied before the tracked claim set is formed:** comments asserting no defect
(praise, summaries, bot status notes), and claims superseded by another. Excluding them
up front rather than after means `## Done` can require a verdict for every *tracked*
claim without that being unsatisfiable for a claim deliberately never dispatched.

**Hold the tree still while triage is outstanding.** The caller applies no fix until
**every queued claim across every batch** has returned — not merely the current batch,
or it could mutate between batches and leave later verdicts describing a different tree.
If it knowingly changes the tree mid-run — a manual edit, another tool — it re-runs the
affected claims before acting on them. This is the one caller rule replacing the removed
snapshot barrier, and it is deliberately the cheap version: edits from outside the
session are undetectable here and remain an accepted residual risk, stated rather than
engineered against.

**Dispatch in bounded batches of 4.** Spawn limits are a real failure mode, and a PR with
many claims would otherwise turn ordinary work into a wave of retries and escalations.
Four is a deliberate conservative constant rather than a discovered limit: the effective
ceiling is configurable, and a spec that names an environment variable nobody verified
would be documenting a mechanism it did not check. A caller that knows its own ceiling
may raise it; the retry rule applies per batch.

**On subagent failure** — no successful completion (launch failure, spawn limit,
timeout, transport error), *regardless of any partial output*, or output failing §5.4
validation — retry once, then escalate. Never silently fall back to self-validation:
that is the review this agent exists to replace.

## 7. Not built

**`ledger-scribe`** — map a finding to taxonomy classes, draft a ledger row. Motivation
real: the unwritten row at the end of a long cycle. Already carried by
`harden-finding`'s flow and `process-pr-review` step 4 — located elsewhere, not
dismissed. Expressible (a Read/Grep/Glob agent cannot itself write the ledger, same
boundary and caveat as §4.1) but redundant: `harden-finding` already fingerprints.
Revisit if it loses that step, or if classification becomes context-free.

**`task-verifier`** — verify a plan task's success criteria with fresh context. Dropped
at pass 1: `superpowers:subagent-driven-development` already dispatches a per-task
spec-compliance reviewer, and `executing-plans` says to use that skill when subagents
are available — so where it could run, the reviewer exists; where none exists, subagents
do not. The residual distinction is real but thin: per-criterion verdicts with
self-produced evidence serve CLAUDE.md §4 outside plan execution. **Trigger:** if
progress claims outside `subagent-driven-development` repeatedly prove ungrounded in
real use, that recurrence justifies a verifier rescoped to *claims*, reconciled against
superpowers' reviewer. Until then it is speculative (CLAUDE.md §2).

## 8. Verification

- the canonical quality command from `AGENTS.md § Commands`, run verbatim, result
  reported — `claude plugin validate . --strict` is part of it and covers `agents/`
- the definition self-reviewed against all 11 prompt-standards items, result per item
- nothing in `hooks/` changes
- naming: unscoped basename matches frontmatter, scope prefix suits context — not
  literal string equality, which the settled naming rule fails by design

## 9. Delivery

One commit. Version `0.4.0` in `plugins/dev-workflow/.claude-plugin/plugin.json`;
nothing else in that manifest changes (invariant 6).

## 10. Follow-up, after this PR

Run `dev-workflow:harden-finding` on a pattern Gate A exposed in this document: three
separate claims that something was enforced, caught, or guaranteed when no mechanism did
so — "a rogue write cannot be invisible", "all four gaps are recorded in todos.md",
"output validation catches a budget overrun". Same document, same author, each caught
only by the gate. Source `gate-a`, rung `P`: a `docs/prompt-standards.md` checklist item
requiring every enforcement claim to name its mechanism, and the mechanism to be
verified before the claim is written. One ledger row.
