# Subagent definitions: task-verifier + finding-triage — Design

**Date:** 2026-07-18 · **Status:** approved, pre-Gate-A

## 1. Problem

Two points in the workflow ask the main agent to check its own work, which is the
one thing it is worst at: confirming a plan task actually meets its success criteria,
and deciding whether a PR-bot comment is right. In both cases the agent that judges
is the agent that just formed the belief being judged, so it shares every assumption
that produced the belief.

Claude Code subagents give each check its own context window. That does not make the
check independent of the *model* — it makes it independent of the *conversation*,
which is what these two checks actually need.

## 2. Scope

Add two agent definitions to the plugin. Integrate them at six documented points.
Nothing else becomes an agent, and the hook is not touched.

**Explicit non-goal:** these agents do not replace, supplement, or count toward the
Codex gates. See §5.

## 3. Verified platform facts

Read from the Claude Code docs before designing; recorded here so a future reader can
tell what was checked from what was assumed.

| Fact | Source |
|---|---|
| Plugin agents live in `agents/` in the plugin root, as markdown with YAML frontmatter | plugins reference, "Agents" |
| Only `name` and `description` are required | sub-agents, "Supported frontmatter fields" |
| `tools` is an allowlist — **inherits all tools if omitted** | same |
| `disallowedTools` removes tools "from inherited or specified list" | same |
| `model` defaults to `inherit` when omitted | same |
| `permissionMode`, `hooks` and `mcpServers` are **ignored for plugin agents** | plugins reference + sub-agents note |
| Plugin agents are invoked as `plugin-name:agent-name` | plugins reference, "Integration points" |

The last two drive two decisions below: there is no per-agent way to constrain Bash,
and prose must use the scoped name.

## 4. The read-only constraint, and where it is real

Both agents are verifiers, not builders. Neither may edit.

`finding-triage` gets `tools: Read, Grep, Glob`. It needs no shell, so its read-only
property is **mechanically enforced with no residual**.

`task-verifier` must run the project's test and quality commands — producing its own
evidence is the entire point — which requires `Bash`, and `Bash` can write. The
per-agent escapes are all closed: `permissionMode` is ignored for plugin agents,
per-agent `hooks` are ignored, and `permissions.allow` in settings is session-wide
rather than per-agent. So for this one agent, read-only is **partly instruction-backed
and that is stated in the definition rather than implied away.**

Two things bound the residual:

1. `disallowedTools: Edit, Write, NotebookEdit` closes the convenient write paths.
   This is redundant against today's allowlist and is kept deliberately, with its
   reason written next to it: because `tools` inherits *everything* when omitted,
   the denylist is the backstop if a future edit deletes the `tools:` line. It
   survives that mistake; the allowlist alone does not.
2. Any write the verifier does make changes the working tree, which flips the
   content-hash Gate-B state to unreviewed. A verifier that breaks its contract
   cannot do so invisibly — the hook cannot attribute the change, but it does catch
   the side effect. Defense in depth, not a loophole.

## 5. Neither agent is a gate

Each definition carries one line stating that it never counts as a Gate A or Gate B
pass: CLAUDE.md §5 requires cross-model independence, and a same-model subagent
shares this model's blind spots. The agents complement the gates; they never
substitute for one.

This is in the definitions rather than only in the docs because the definition is
what the agent itself reads.

## 6. The definitions

### 6.1 `task-verifier`

```yaml
---
name: task-verifier
description: Verifies an implemented plan task against its success criteria with
  fresh context. Use after a task is implemented, before marking it done.
tools: Read, Grep, Glob, Bash
disallowedTools: Edit, Write, NotebookEdit
---
```

`model`, `effort` and `maxTurns` are omitted. The first two default to `inherit`,
which is what a verifier wants. `maxTurns` is omitted because an arbitrary cap can
truncate a legitimate verification mid-way; the stop condition belongs in the prompt
body, where prompt-standards item 3 requires it regardless.

**Input contract**, stated in the definition: the task's text from the plan (files,
interfaces, steps, success criteria) plus the current diff.

**Behavior:** check each success criterion against evidence the agent produces
itself — run the project's test command resolved from `AGENTS.md § Commands`, read
the diff, read the touched files.

**Bash scope**, phrased positively per item 9: use Bash to run the project's
test/quality commands as resolved from `AGENTS.md § Commands`, and nothing else.
Then the two constraint sentences from §4.

**Verdict per criterion:** `met` (with the tool result that proves it) / `not met`
(with what is missing) / `not verifiable` (with why).

**Hard boundary:** no fixes and no suggestions beyond the verdict. A verifier that
starts patching has spent the fresh context that made it worth calling.

**Output format** (shown, per item 4):

```
CRITERION  typecheck exits 0
VERDICT    met
EVIDENCE   `pnpm typecheck` → exit 0, 0 errors

CRITERION  invalid input returns 422
VERDICT    not met
MISSING    no test covers a malformed body; the handler has no validation branch

CRITERION  p95 latency under 200ms
VERDICT    not verifiable
WHY        no load-test harness in this repo
```

### 6.2 `finding-triage`

```yaml
---
name: finding-triage
description: Validates a single PR-bot review comment against the code and the
  project's invariants. Use once per comment when processing PR review.
tools: Read, Grep, Glob
---
```

**Input contract:** one comment (text, file, line), the relevant code, and
`AGENTS.md`. One comment per invocation — the isolation is the point.

**Verdict:** `accept` / `dismiss` / `escalate-to-user`, each with a one-line reason.
A dismissal must cite what in the code or in the invariants contradicts the comment;
"looks fine" is not a dismissal.

**Output format** (shown, per item 4):

```
COMMENT  src/orders.ts:42 — "missing tenant scope on this query"
VERDICT  accept
REASON   the query filters by id only; AGENTS.md "Data & tenancy" requires every
         read scoped to the caller's workspace

COMMENT  src/orders.ts:88 — "unvalidated input"
VERDICT  dismiss
REASON   validation happens in the caller at src/orders.ts:31, outside the
         comment's context window
```

## 7. Integration

Each is one sentence unless noted. Every mention uses the scoped name
(`dev-workflow:task-verifier`), matching the existing skill rows; frontmatter carries
the unscoped name. Same name, differently qualified — no drift.

| # | File | Change |
|---|---|---|
| 1 | `commands/process-pr-review.md`, Step 3 | each comment MAY be validated by a `dev-workflow:finding-triage` subagent with fresh context, in parallel; the main agent aggregates and stays responsible for replies and fixes |
| 2 | `commands/workflow-init.md`, §4 template | task completion claims can be checked by `dev-workflow:task-verifier`; its verdict is the "tool result" a progress claim points to |
| 3 | `README.md` component table | two rows, one line each |
| 4 | `docs/getting-started.md` | one sentence in step 5 (verifier), one in step 8 (triage) — see length rule below |
| 5 | `AGENTS.md` architecture tree | add `agents/` |
| 6 | `docs/architecture.md` layout | add `agents/` |

Rows 5 and 6 are additions to the brief, required by this repo's own Don'ts: "the
layout tree above is part of the surface that drifts."

**Length rule for row 4, made explicit.** No length budget for
`docs/getting-started.md` is documented anywhere, so "respect the budget" was
ambiguous. Resolved here rather than left to interpretation: the file is 94 lines
today and its worth is being readable in one sitting, so it **ends at 100 lines or
fewer**. If the two sentences would push it past that, trim adjacent prose in the same
change instead of letting the file grow. This is a rule for this change, not a new
project-wide invariant — it is not added to `AGENTS.md`.

**Invariant 6:** `agents/` is convention-loaded, so nothing is added to
`plugin.json`. `scripts/check-invariants.sh` already greps for an `agents` key in the
manifest, so that regression is mechanically caught.

## 8. Not built: `ledger-scribe`

A third agent was scoped to map a finding to taxonomy classes and draft a ledger row
for approval. It is **not** built.

The motivation was real: the risk it addressed is the unwritten ledger row at the end
of a long cycle, when attention is spent. That concern is already carried by
`harden-finding`'s own flow and by `process-pr-review` step 4, which mandates the
ledger check — so the problem was **located elsewhere, not dismissed**.

The constraint was **expressible but redundant**. Expressible: `tools: Read, Grep,
Glob` with no Write, Edit or Bash makes the agent mechanically incapable of touching
`docs/hardening-log.md`, cleanly, with no instruction-backed residual. Redundant:
`harden-finding` already greps the base taxonomy and the project taxonomy and maps
the finding to a canonical class. Fresh context is a *disadvantage* there — correct
fingerprinting depends on the conversation the finding arose in.

That wording tells a future reader what would have to change for the agent to become
worth adding: `harden-finding` losing its fingerprint step, or classification
becoming genuinely context-free.

## 9. Verification

No new tests. Prompts have no typechecker; this repo's answer to that is review
against `docs/prompt-standards.md`.

- `claude plugin validate . --strict` passes with the new `agents/` directory
- both definitions self-reviewed against all 11 prompt-standards items, result
  stated per item
- the hook suite still passes, unchanged — nothing in `hooks/` is touched
- `scripts/check-invariants.sh` passes
- every mention of an agent matches its frontmatter name

## 10. Delivery

Three commits: `task-verifier`, `finding-triage`, then integration + docs + version.

Version `0.4.0` in `plugins/dev-workflow/.claude-plugin/plugin.json` — minor, new
capability, no breaking change to existing components. Nothing else in that manifest
changes (invariant 6).
