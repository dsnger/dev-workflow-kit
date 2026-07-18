# Subagent definition: finding-triage — Design

**Date:** 2026-07-18 · **Status:** revised after Gate A pass 1 · **Version target:** 0.4.0

Originally scoped as two agents. `task-verifier` was dropped at Gate A when review
showed it duplicated an existing superpowers mechanism; see §8.2. One agent ships.

## 1. Problem

`/dev-workflow:process-pr-review` asks the main agent to decide whether each PR-bot
comment is right. That is the agent judging a belief it just formed, sharing every
assumption that produced it. Bot comments are also the case where being wrong is
expensive in both directions: accepting a false finding produces a pointless change,
dismissing a true one silently drops a real defect.

A subagent gives each comment its own context window. That does not make the check
independent of the *model* — it makes it independent of the *conversation*, which is
what this check needs.

## 2. Scope

Add one agent definition, `finding-triage`, and integrate it at the documented points
in §7. Nothing else becomes an agent. The hook is not touched.

**Explicit non-goal:** this agent does not substitute for the Codex gates (§5).

## 3. Verified platform facts

Read from the Claude Code docs on 2026-07-18 before designing, and recorded so a
future reader can tell what was checked from what was assumed.

| Fact | Source |
|---|---|
| Plugin agents live in `agents/` in the plugin root, markdown with YAML frontmatter | [plugins reference § Agents](https://code.claude.com/docs/en/plugins-reference) |
| Only `name` and `description` are required | [sub-agents § Supported frontmatter fields](https://code.claude.com/docs/en/sub-agents) |
| `tools` is an allowlist — **inherits all tools if omitted** | same |
| `disallowedTools` removes tools "from inherited or specified list" | same |
| `model` defaults to `inherit` when omitted | same |
| `permissionMode`, `hooks`, `mcpServers` are **ignored for plugin agents** | [plugins reference](https://code.claude.com/docs/en/plugins-reference) + sub-agents note |
| Plugin agents are invoked as `plugin-name:agent-name` | plugins reference § Integration points |

## 4. Read-only, with no residual

`finding-triage` gets `tools: Read, Grep, Glob`. It needs no shell, so its read-only
property is **mechanically enforced**: the allowlist omits Edit, Write and Bash, and
the agent is incapable of mutating anything.

This is why the agent that survived review is the one that never needed Bash. The
dropped `task-verifier` required it (§8.2), and with it came an instruction-backed
gap that could not be closed per-agent: `permissionMode` is ignored for plugin
agents, per-agent `hooks` are ignored, and `permissions.allow` is session-wide.

`disallowedTools` is **not** set. Against a `tools` allowlist that already omits every
write tool it would be redundant today, and its only value — a backstop if a future
edit deletes the `tools:` line, since omission inherits everything — is better served
by the comment in the definition telling the reader not to delete that line.

**On detecting a rogue subagent write.** No Bash-capable agent ships here, so the
question is largely moot. Where it still matters — anyone adding one later — the
honest statement is that the Gate-B content hash gives **best-effort detection of
most commit-relevant worktree changes**, not a guarantee. Known gaps, all recorded in
`todos.md`: staged-vs-worktree divergence, a compound `mutate && git commit` hashed
before the mutation, `.context/` exclusion, and gitignored paths. A claim in one
document must not overstate what another document in the same repo already refutes.

## 5. Not a gate

The definition carries one line stating it never counts as a Gate A or Gate B pass:
CLAUDE.md §5 requires cross-model independence, and a same-model subagent shares this
model's blind spots. It **complements** the gates and never **substitutes** for one.

It lives in the definition, not only in the docs, because the definition is what the
agent itself reads.

## 6. The definition

```yaml
---
name: finding-triage
description: Validates a single PR-bot review comment against the code and the
  project's invariants. Use once per comment when processing PR review.
tools: Read, Grep, Glob
---
```

`model` and `effort` are omitted: both default to `inherit`, which is what a checker
wants. `maxTurns` is omitted because one comment against one file is bounded by the
stop conditions below, and an arbitrary cap can truncate a legitimate check.

**Target model** (item 1): the body states it runs as Claude via Claude Code, and
records that Anthropic's current prompting page was checked on 2026-07-18.

### 6.1 Input contract

The caller passes, per invocation:

| Field | Required | On absence |
|---|---|---|
| comment text | yes | `escalate-to-user`, naming the missing field |
| file path and line | yes | `escalate-to-user`, naming the missing field |
| the head SHA the comment was made against | yes | `escalate-to-user` |
| path to `AGENTS.md` (or a statement that the project has none) | yes | `escalate-to-user` |

**One comment per invocation.** The isolation is the point; batching re-creates the
shared context the agent exists to avoid.

The agent reads the code itself via Read/Grep/Glob — the caller passes locations, not
file contents, so the agent cannot be fed a curated excerpt.

**Never infer a missing field.** An incomplete payload returns `escalate-to-user`
naming exactly which fields are missing. Guessing the alleged defect is the failure
mode that makes the whole check worthless.

### 6.2 Staleness and moved code

The agent compares the comment's head SHA against the current checkout's HEAD. If
they differ, it says so in its reason — a verdict reached against different code than
the comment was written against is not a verdict.

If the referenced file or line no longer holds the code described:

- the code is findable elsewhere (moved/renamed) → judge it there, verdict as normal,
  reason naming the new location
- the described defect is already fixed → `dismiss`, reason "already resolved at
  `<location>`"
- the code cannot be located → `escalate-to-user`

### 6.3 Verdicts

Three, mutually exclusive. **Factual validity and actionability are separate
questions**; conflating them is how a technically-correct comment turns into an
out-of-scope change.

| Verdict | When |
|---|---|
| `accept` | the comment identifies a real defect in this PR's changes, and fixing it belongs in this PR |
| `dismiss` | the comment is factually wrong, already resolved, or a duplicate of another comment on the same code — the reason must cite what in the code or in the invariants contradicts it |
| `escalate-to-user` | valid but not actionable here: pre-existing and outside this PR's diff, a scope expansion, contradicts a settled decision — **or** any required input is missing, the code cannot be located, or the SHAs diverge |

"Looks fine" is not a dismissal. A dismissal cites evidence.

### 6.4 Stop conditions (item 3)

Stop and emit the verdict block as soon as one verdict is reached for the comment.
Escalate immediately rather than continuing on: a missing required field, an
unlocatable file, or a SHA mismatch. Never search beyond the file and its immediate
callers looking for a way to make a comment true.

### 6.5 Output format (item 4 — shown, all three verdicts)

```
COMMENT  src/orders.ts:42 — "missing tenant scope on this query"
VERDICT  accept
REASON   the query filters by id only; AGENTS.md "Data & tenancy" requires every
         read scoped to the caller's workspace

COMMENT  src/orders.ts:88 — "unvalidated input"
VERDICT  dismiss
REASON   validation happens in the caller at src/orders.ts:31, outside the
         comment's context window

COMMENT  src/legacy/report.ts:12 — "N+1 query in this loop"
VERDICT  escalate-to-user
REASON   real, but pre-existing and untouched by this PR's diff — fixing it is a
         scope expansion
```

## 7. Integration

Every mention uses the scoped name `dev-workflow:finding-triage`, matching the
existing skill rows; frontmatter carries the unscoped `finding-triage`. Same name,
differently qualified.

| # | File | Change |
|---|---|---|
| 1 | `commands/process-pr-review.md`, Step 3 | each comment is validated by a `dev-workflow:finding-triage` subagent with fresh context, in parallel; the main agent aggregates and stays responsible for replies and fixes |
| 2 | `README.md` component table | one row |
| 3 | `docs/getting-started.md`, step 8 | one sentence |
| 4 | `AGENTS.md` architecture tree | add `agents/` |
| 5 | `AGENTS.md` **Boundaries** paragraph | add `agents/` to the convention-loaded enumeration |
| 6 | `AGENTS.md` **invariant 6** | add `agents/` to the components the manifest must not re-declare |
| 7 | `AGENTS.md` **invariant 11** | add agent definitions to the governed prompt artifacts |
| 8 | `docs/architecture.md` layout + convention-loading prose | add `agents/` in both places |
| 9 | `docs/prompt-standards.md` scope paragraph | add agent definitions to the enumerated prompt artifacts |

Rows 4–9 are additions to the original brief. Rows 4, 5, 6 and 8 are required by this
repo's own Don'ts — "the layout tree above is part of the surface that drifts" — and
by the grep recipe added with the manifest rule, which finds every convention-loading
declaration rather than only the tree.

Rows 7 and 9 close a gap this change itself creates: invariant 11 and
`docs/prompt-standards.md` currently enumerate skills, commands, hook messages and
templates. Adding `agents/` is precisely what makes that enumeration incomplete, so
the change that introduces the gap closes it. Without this, the spec would assert a
checklist governs artifacts its own scope excludes.

**`/workflow-init` note:** the §4 template integration from the original brief is
dropped with `task-verifier`. `docs/prompt-standards.md` is scaffolded into initialized
projects, so row 9's wording must read correctly for a project that has no agents yet.

**Invariant 6:** `agents/` is convention-loaded, so nothing is added to `plugin.json`.
`scripts/check-invariants.sh` already greps for an `agents` key, so that regression is
mechanically caught.

**Invocation is the default, not an option.** Step 3 triages every comment that
asserts a defect. Legitimate skips, stated: a comment that asserts no defect (praise,
a summary, a bot's own status note), and a comment superseded by another on the same
lines. Everything else is triaged. Contradictory verdicts across parallel invocations
are resolved by the main agent before replying — it aggregates by file and line and
escalates a genuine conflict rather than picking one.

**No length cap on `getting-started.md`.** Pass 1 flagged that the 100-line budget in
the previous draft was invented, and that authorizing "trim adjacent prose" to meet an
invented number licenses unrelated edits against CLAUDE.md §§2–3. Add the sentence and
judge readability directly.

## 8. Not built

### 8.1 `ledger-scribe`

Scoped to map a finding to taxonomy classes and draft a ledger row for approval.

The motivation was real: the unwritten ledger row at the end of a long cycle, when
attention is spent. That concern is already carried by `harden-finding`'s own flow and
by `process-pr-review` step 4, which mandates the ledger check — the problem was
**located elsewhere, not dismissed**.

**Expressible but redundant.** Expressible: `tools: Read, Grep, Glob` makes it
mechanically incapable of touching `docs/hardening-log.md`. Redundant:
`harden-finding` already greps both taxonomies and maps the finding to a canonical
class. That redundancy alone is sufficient reason. A secondary judgment — that fresh
context is a disadvantage for fingerprinting, since classification draws on how the
finding arose — is offered as opinion, not established fact; `harden-finding` takes an
explicit intake contract, so a parameterized agent could receive the same inputs.

What would have to change for it to be worth adding: `harden-finding` losing its
fingerprint step, or classification becoming genuinely context-free.

### 8.2 `task-verifier`

Scoped to verify an implemented plan task against its success criteria with fresh
context. Dropped at Gate A pass 1.

**Duplicates an existing mechanism.** `superpowers:subagent-driven-development`
already dispatches "a task review (spec compliance + code quality) after each" task,
with a re-review loop after fixes. "Spec compliance" is "checks the success criteria."
The remaining path, `executing-plans`, explicitly says: "If subagents are available,
use superpowers:subagent-driven-development instead of this skill." So on the platform
where a subagent can run, the reviewer already exists; the path lacking one is the
path that cannot run subagents. The niche collapses.

This is the same redundancy test applied to `ledger-scribe`, applied consistently.

**The residual distinction is real but thin.** Per-criterion verdicts backed by
self-produced evidence serve CLAUDE.md §4's "ground progress claims against a tool
result" *outside* plan execution — for example, fixes made during
`process-pr-review`, where no superpowers reviewer is dispatched at all.

**Trigger condition.** If progress claims outside `subagent-driven-development`
repeatedly turn out ungrounded in real use, that recurrence justifies a
narrowly-scoped verifier — rescoped to **claims**, not plan tasks, and reconciled
against superpowers' reviewer inside the definition. Until that recurrence, adding it
is speculative (CLAUDE.md §2).

## 9. Verification

No new tests. Prompts have no typechecker; this repo's answer is review against
`docs/prompt-standards.md`.

- the canonical quality command from `AGENTS.md § Commands` is run **verbatim** and
  its observed result reported — not a hand-picked subset
- `claude plugin validate . --strict` passes with the new `agents/` directory (it is
  part of that command)
- the definition is self-reviewed against all 11 prompt-standards items, result stated
  per item
- nothing in `hooks/` changes
- every mention of the agent resolves to the frontmatter name: prose uses
  `dev-workflow:finding-triage`, frontmatter uses `finding-triage`. The check is that
  the unscoped basename matches and the scope prefix is correct for context — not
  literal string equality, which the settled naming rule would fail by design

## 10. Delivery

**One commit.** Dropping `task-verifier` makes the change small enough that the
original three-commit plan would create three Gate-B cycles for one coherent unit —
every commit resets the cycle and none could share a final pass. One commit, one
cycle, one Gate-B loop closing it.

Version `0.4.0` in `plugins/dev-workflow/.claude-plugin/plugin.json` — minor, new
capability, no breaking change. One new agent is still a new capability. Nothing else
in that manifest changes (invariant 6).
