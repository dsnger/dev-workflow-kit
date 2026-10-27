---
name: harden-finding
description: Use when a review finding (Codex Gate A/B, a PR bot, or manual review) has been surfaced and you want it to never silently return — turning a one-off fix into a lint rule, type constraint, test, or documented convention. Use also when a finding you've seen before recurs.
---

# harden-finding

## Overview

**What a deterministic tool can catch does not belong in the
Codex gate.** This skill takes one finding, hardens it at the right rung of the
ladder, verifies, and records it in `docs/hardening-log.md` so recurrence is
mechanical.

Target model: Claude via Claude Code. This skill is a prompt artifact and follows
the checklist in `docs/prompt-standards.md`.

## Project files this skill reads

Both are scaffolded by `/dev-workflow:workflow-init`. If one is missing, say so and
offer to run that command — guessing a project's rungs or classes produces a log
nobody can grep.

| File | What it supplies |
|---|---|
| `AGENTS.md` | the invariants, and (under `## Commands`) the project's real lint/typecheck/test/quality commands |
| `docs/hardening-taxonomy.md` | the project's **own** fingerprint classes, extending the base classes below |
| `docs/hardening-log.md` | the append-only ledger you grep and append to |

## When to use

- A Gate A/B, PR-bot, or manual finding was raised and you want it permanently
  prevented, not just fixed once.
- A finding feels familiar — the recurrence check tells you if it's been logged.

## The ladder

Pick the rung that **matches the finding's nature** — not always the highest. The
*Where* and *Verify with* columns name roles, not tools: resolve them to this
project's actual config files and commands from `AGENTS.md § Commands`.

| Rung | Fits when | Where | Verify with |
|---|---|---|---|
| 0 · already caught | an existing **required** check already **fails the gate** on it | — | note it, stop |
| 2 · lint | a mechanical code pattern | the project's linter/static-analysis config | the project's lint command |
| 4 · test | a behavioral / logic invariant | the project's test suite, next to the code under test | the project's test command |

- A non-blocking **warning** (a `warn`-level rule, a diagnostic that doesn't fail the
  quality command) is **not** rung 0 — it slipped through because nothing blocked it.
  Making it block (warn→error, zero-tolerance flag) is a rung-2 hardening.

## Flow

1. **Intake** — the finding text, `source` (gate-a|gate-b|bot|manual), and
   `severity` (blocker|major|minor|nit). Ask if any is missing, so the log row is
   complete.
2. **Fingerprint** — map the finding to a **canonical** class, searching the base
   classes below *and* `docs/hardening-taxonomy.md`. Mapping is judgment aided by
   each class's alias hint; the log always stores the canonical class, keeping
   recurrence a mechanical grep. Mint a new class only if none fits — and add it to
   `docs/hardening-taxonomy.md` in the same change (never to this skill file: the
   plugin ships the base classes, the project owns its own).
3. **Recurrence check** — re-read the log, then grep column 2 anchored so it can't
   match the `finding`/`ref` columns:
   `grep -nE '^\| *[0-9-]{10} *\| *<fingerprint> *\|' docs/hardening-log.md`
   - no match → new; continue with the fitting rung.
   - latest matching row is `pending` → report **blocked by an existing
     prerequisite** (point at its `ref`); do not escalate — no hardening landed yet.
4. **Propose rung** — state the rung and *why* in one clause. If it fits two rungs, take
   rung 2, the cheaper check, and say so. If you cannot tell whether a tool can decide it,
   try the project's lint and test setup on it; if that still settles nothing, leave
   `docs/hardening-log.md` unchanged, add a `todos.md` row naming the finding as *rung
   undetermined*, and end this run there, so the obligation stays open instead of being
   discharged by a guess. Unless the project's gate mode is `classic`
   (`.claude/codex-gate.mode`): when it is settled that neither lint nor a test can decide it, the
   rung is `1 prose` (an instruction in a rule file), and the row's `ref` says why neither
   can; write no prose row without that reason. Why: in the dev-workflow-kit's own ledger, prose fixes
   recurred 13 times in 14, tests 10 in 15.
5. **Apply** — implement at the chosen rung. Prefer existing rules/config over new
   dependencies; a new lint plugin obeys the project's dependency-freshness policy
   (`AGENTS.md`) — never lower it. If the plugin is too new to pass, log `pending`
   with a prerequisite ref instead of bypassing the policy.
6. **Verify** — run the matching slice while iterating, then the project's full
   quality command before declaring done when code or config changed (a new rule can
   ripple into dead-code/duplication checks). Report the real command + result; claim
   green only with a tool result to point at.
7. **Log** — re-read the log again, then append one row (below) if no matching-
   fingerprint row appeared meanwhile. Unless the gate mode is `classic`, the row is also the learning record: `finding`
   names the symptom and its cause; `ref` names the change, its location and the evidence —
   the cycle nonce for a row a gate cycle owed, else the source (a PR comment, a manual note). Rung 0 is not logged — the log is a ledger of
   hardenings.

**Prerequisite-blocked hardening:** if the fitting rung can't land without breaking
the gate (e.g. flipping a rule warn→error while live warnings still exist), leave the breaking
change unapplied — log `rung=pending` with a `ref` to the prerequisite story and
state the sequencing. This keeps the gate green while recording intent.

## Base fingerprint taxonomy

Canonical, low-cardinality, stack-neutral classes with an alias hint each. These ship
with the plugin. A project's own domain classes (its entities, its frameworks, its
invariants) go in `docs/hardening-taxonomy.md` — read it together with this list on
every fingerprint step, and check both before minting.

**Auth & tenancy**
- `missing-auth-check` — an authn/authz call the handler is required to make is absent
- `lookup-before-auth` — state/existence reads precede the auth barrier (existence oracle)
- `pre-auth-early-return` — a state check or input short-circuit can return/throw before auth runs
- `acl-bypass` — a per-resource permission check skipped on a path that needs it
- `missing-tenant-scope` — a query or write not scoped to the caller's tenant/workspace/org
- `tenant-ref-unvalidated` — a cross-entity reference arg accepted without validating it belongs to the caller's tenant
- `over-exposed-response` — a response returns fields a lower-privileged role should not see

**Data & lifecycle**
- `unindexed-query` — filter-in-query / full-table scan where an index is required
- `missing-expected-version` — optimistic-concurrency check absent on a concurrent-write path
- `soft-delete-transparent-lookup` — a row fetched without checking its deleted marker; stale data steers logic as if live
- `deleted-parent-write-allowed` — a write succeeds under a soft-deleted/archived parent
- `deleted-parent-ref-survives` — hard-deleting a parent leaves dangling references instead of cascading or nulling
- `bulk-path-skips-side-effect` — a bulk/batch path omits a side effect (audit log, event, notification) the single-item path performs

**Types & validation**
- `missing-input-validation` — a public entry point accepts an argument with no schema/validator
- `validator-unbounded-input` — a validated field carries no domain constraint (range, length, enum); out-of-domain values pass and throw deeper
- `any-type-leak` — an escape-hatch type where a real type exists
- `raw-string-id` — a primitive string/number where a branded/typed ID exists

**Errors & async**
- `promise-unawaited` — floating / un-awaited async
- `raw-error-thrown` — a generic error type instead of the project's domain error type
- `raw-client-error-message` — a raw internal error surfaced to the client instead of the sanitizing mapper

**Tooling & supply chain**
- `lint-warning-not-blocking` — a `warn`-level rule lets regressions through the gate
- `lint-scope-includes-ignored` — static analysis walks ignored/scratch paths it should skip
- `dependency-unpinned` — a tool/server/action launched unpinned (executes latest-at-launch, bypassing the freshness policy)
- `external-call-no-timeout` — an outbound call (MCP, HTTP, subprocess) can hang unbounded

**Docs & prompts**
- `docs-drift` — docs contradict each other or the code
- `prompt-vague-criteria` — a prompt lacks checkable success criteria
- `prompt-missing-stop-condition` — a looping prompt has no stop/escalate rule

**Minting a class:** first grep both lists for the closest match (the alias hints are
the synonyms) — a near-miss class you reuse is worth more than a precise class nobody
greps for. New classes are kebab-case `domain-problem-class` and land in
`docs/hardening-taxonomy.md` in the same change as the hardening.

## Log format

Append to `docs/hardening-log.md` — its header defines the columns, enums, and
escaping.

## Example

**Intake** — finding: "`orders.create` writes an order into a project the caller cannot
access"; source: `gate-b`; severity: `major`.

1. **Fingerprint** → `acl-bypass` (alias "per-resource permission check skipped").
2. **Recurrence** → re-read the log, then `grep -nE '^\| *[0-9-]{10} *\| *acl-bypass *\|' docs/hardening-log.md` → no match → new.
3. **Rung** → 4 (test): a behavioral invariant — "a caller without project access cannot create orders" — that a test pins durably; no lint rule decides project-ACL logic.
4. **Apply** → add a test for `orders.create` with a caller who has org membership but lacks project ACL → asserting `Forbidden: no access to this project`.
5. **Verify** → the project's test command → pass; then the full quality command (code changed) → green.
6. **Log** → re-read the log; if no `acl-bypass` row appeared meanwhile, append:
   `| 2026-07-12 | acl-bypass | orders.create writable without project-ACL check: the handler skipped the project-ACL helper | gate-b | major | 4 test | test added in src/orders/orders.test.ts for orders.create; cycle k7q2m9xa |`

## Stop and ask

- Intake is missing the finding text, source, or severity.
- Hardening would break the gate and no prerequisite story exists to reference.
- `docs/hardening-log.md`, `docs/hardening-taxonomy.md`, or `AGENTS.md § Commands` is
  missing — offer `/dev-workflow:workflow-init`.

## Common mistakes

- Logging a rung-0 already-caught finding (the log is a hardening ledger).
- Treating a non-blocking warning as rung 0 (making it block is rung 2).
- Grepping the whole log line instead of the anchored column-2 pattern (false hits
  on the `finding`/`ref` columns).
- Escalating a `pending` recurrence instead of reporting blocked-by-prerequisite.
- Adding a project-specific class to this skill file instead of
  `docs/hardening-taxonomy.md` (the plugin is shared across projects; the class is not).
