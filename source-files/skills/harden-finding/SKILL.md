---
name: harden-finding
description: Use when a review finding (Codex Gate A/B, CodeRabbit, or manual review) has been surfaced and you want it to never silently return — turning a one-off fix into a lint rule, type constraint, test, or documented convention. Use also when a finding you've seen before recurs.
---

# harden-finding

## Overview

A review finding is only *closed* when the most deterministic tool that fits will
catch it next time. **What a deterministic tool can catch does not belong in the
Codex gate.** This skill takes one finding, hardens it at the right rung of the
ladder, verifies, and records it in `docs/hardening-log.md` so recurrence is
mechanical.

Target model: Claude via Claude Code. This skill is a prompt artifact and follows
`docs/prompt-standards.md` (checked against its dated "Verified model-specific
notes", read 2026-07-04).

## When to use

- A Gate A/B, CodeRabbit, or manual finding was raised and you want it permanently
  prevented, not just fixed once.
- A finding feels familiar — the recurrence check tells you if it's been logged.

## The ladder

Pick the rung that **matches the finding's nature** — not always the highest.

| Rung | Fits when | Where | Verify with |
|---|---|---|---|
| 0 · already caught | an existing **required** check already **fails the gate** on it | — | note it, stop |
| 1 · prose | a convention/judgment call no tool can adjudicate | `AGENTS.md` | grep the rule is present, no contradiction |
| 2 · lint | a mechanical code pattern | `eslint.config.js` | `pnpm lint` |
| 3 · type | expressible in the type system | `tsconfig*` / types | `pnpm typecheck` |
| 4 · test | a behavioral / logic invariant | vitest in `convex/lib/` or `src/lib/` | `pnpm test` |
| P · prompt-standard | the finding is in a prompt artifact (skill, gate prompt, hook) | `docs/prompt-standards.md` | checklist self-review |

- A non-blocking **warning** (a `warn` lint rule, a diagnostic that doesn't fail
  `pnpm quality`) is **not** rung 0 — it slipped through because nothing blocked it.
  Making it block (warn→error, `--max-warnings=0`) is a rung-2 hardening.
- Prefer the strongest deterministic rung that fits: a security/ACL finding
  (e.g. `convex-missing-auth`) tries lint/type/test **before** prose, because a tool
  that fails the build beats a convention someone can forget.
- **"One rung stronger" for non-mechanical rungs (1, P):** escalation isn't always a
  higher number. Rung 1 → jump to a mechanical rung if the pattern turned out
  tool-decidable; else sharpen the AGENTS.md wording and record that *no
  deterministic rung exists* (the log's recurrence count is then the signal). Rung P
  → sharpen the checklist item / add a concrete example → (future) a spec/plan
  template or gate-hook enforcement if already in scope.

## Flow

1. **Intake** — the finding text, `source` (gate-a|gate-b|coderabbit|manual), and
   `severity`. Ask if any is missing, so the log row is complete.
2. **Fingerprint** — map the finding to a **canonical** class (see Taxonomy). Mapping
   is judgment aided by each class's alias hint; the log always stores the canonical
   class, keeping recurrence a mechanical grep. Mint a new class only if none fits —
   and add it to the Taxonomy section here in the same change.
3. **Recurrence check** — re-read the log, then grep column 2 anchored so it can't
   match `finding`/`ref`:
   `grep -nE '^\| *[0-9-]{10} *\| *<fingerprint> *\|' docs/hardening-log.md`
   - no match → new; continue with the fitting rung.
   - latest matching row is a real rung (1–4/P) → the prior rung didn't hold;
     propose **one rung stronger**, with reasoning.
   - latest matching row is `pending` → report **blocked by an existing
     prerequisite** (point at its `ref`); do not escalate — no hardening landed yet.
4. **Propose rung** — state the rung and *why* in one clause. If it's ambiguous (fits
   two rungs, or unclear whether a tool can decide it), ask rather than guess.
5. **Apply** — implement at the chosen rung. Prefer existing rules/config; a new
   ESLint plugin obeys the `pnpm` `minimumReleaseAge` policy (AGENTS.md Don'ts) —
   never lower it. If the plugin is too new to pass, log `pending` with a
   prerequisite ref instead of bypassing the policy.
6. **Verify** — run the matching slice while iterating, then full `pnpm quality`
   before declaring done when code or config changed (a new rule can ripple into
   knip/fallow). Report the real command + result; never claim green without a tool
   result.
7. **Log** — re-read the log again, then append one row (below) if no matching-
   fingerprint row appeared meanwhile. Rung 0 is not logged — the log is a ledger of
   hardenings.

**Prerequisite-blocked hardening:** if the fitting rung can't land without breaking
the gate (e.g. flipping `exhaustive-deps` warn→error with 32 live warnings), do not
apply the breaking change — log `rung=pending` with a `ref` to the prerequisite
story and state the sequencing. This keeps the gate green while recording intent.

## Fingerprint taxonomy

Canonical, low-cardinality classes (intentionally minimal — expand per domain before
first use there). Each carries an alias hint for repeatable mapping:

- `promise-unawaited` — floating / un-awaited async
- `convex-missing-auth` — requireAuth/requireMembership/requireRole absent
- `convex-unindexed-query` — filter-in-query / table scan
- `missing-workspace-scope` — query without `workspaceId`
- `board-acl-bypass` — canReadBoard/canManageBoard skipped
- `direct-notification-create` — createNotification() not via logActivity()
- `legacy-card-status` — string `status`/`columnId` instead of `statusId`/`labelIds`
- `raw-string-id` — string ID instead of `v.id`/`Id<>`
- `missing-expected-version` — optimistic-concurrency check absent
- `raw-client-error-message` — `error.message` instead of `getConvexErrorMessage`
- `docs-drift` — docs contradict each other / the code
- `lint-warning-not-blocking` — a `warn` rule lets regressions through
- `lint-scope-includes-ignored` — eslint walks gitignored/scratch paths it should ignore
- `prompt-vague-criteria` — prompt lacks checkable success criteria
- `prompt-missing-stop-condition` — looping prompt has no stop/escalate rule
- `any-type-leak` — `any` where a real type exists
- `raw-error-thrown` — `new Error` instead of `ConvexError`
- `mcp-call-no-timeout` — an MCP tool call can hang unbounded (missing/oversized per-server `timeout`)
- `mcp-server-unpinned` — MCP server launched via unpinned `npx -y <pkg>` (executes latest-on-npm at launch, bypasses `minimumReleaseAge`)
- `lookup-before-auth` — state/existence checks precede auth in a mutation
- `tenant-ref-unvalidated` — a cross-table reference arg accepted without workspace-scope/membership validation
- `deleted-parent-write-allowed` — a mutation writes under a soft-deleted parent entity
- `activity-payload-incomplete` — logActivity called without a contextual field (e.g. boardId) that downstream notification/activity consumers require; linkTo or other derived data silently absent
- `validator-unbounded-numeric` — a numeric field declared as `v.number()` with no range constraint; out-of-domain values pass validators but throw at deep runtime callsites
- `soft-delete-transparent-lookup` — a row fetched via `ctx.db.get` without checking `deletedAt`; soft-deleted row's stale data steers routing or matching as if the record were live
- `restore-resurrects-independent-descendants` — a cascade restore clears `deletedAt` on all descendant rows currently in trash, including ones soft-deleted independently before the parent's own cascade delete, even though the cascade delete itself skipped them
- `restore-skips-status-validation` — a restore/undelete operation clears `deletedAt` without revalidating that the row's own referenced state (e.g. `statusId`) is still live, leaving it pointing at an invalid/deleted reference until a later mutation throws
- `archive-trash-asymmetry` — sibling lifecycle mutations on the same entity (soft-delete/restore/hard-delete) enforce a parent-chain state guard (e.g. an archived-board check) inconsistently, so one path rejects while its siblings silently succeed
- `deleted-parent-ref-survives` — hard-deleting a parent entity leaves dangling references to it in other tables/fields instead of cascading the delete or nulling the reference
- `hard-delete-frees-R2-not-provable` — a test-harness limitation (e.g. an unresolvable sub-component registration) prevents asserting that a hard-delete actually frees an external resource; only the skip/no-op path can be pinned
- `bulk-skips-log-activity` — a bulk/batch mutation writes to entities without calling `logActivity()`, so no activity event is recorded and no downstream notification is ever generated
- `pre-auth-early-returns` — a mutation's state checks or input short-circuits execute and can return or throw before the auth check runs, exposing state-specific errors or silent no-ops to unauthenticated/unauthorized callers
- `missing-returns-validator` — a public Convex function (`mutation`/`query`/`action`) declared without a `returns` validator, though AGENTS.md mandates args+returns validators everywhere; sibling of `missing-expected-version` (docs mandate a guardrail the code lacks broadly). The installed `@convex-dev/eslint-plugin` covers args (`require-args-validator`) but ships no returns rule, so mechanical closure needs a custom rule

**Extension:** before minting a class, grep the column for the closest match (the
alias hints are the synonyms). New classes are kebab `domain-problem-class`, added
here in the same change.

## Log format

Append to `docs/hardening-log.md` — its header defines the columns, enums, and
escaping. You supply: the canonical `fingerprint`, a short one-line escaped
`finding` (escape any `|` as `\|`), the `rung` short-name (`2 lint`, `4 test`,
`1 prose`, `P std`, `pending`), and a concrete `ref`. Resolve a `pending` row by
appending a new row (same fingerprint, `ref` naming the prior row's date + anchor);
never edit an existing row.

## Example

**Intake** — finding: "`cards.create` writes a card under a board the caller cannot access";
source: `gate-b`; severity: `major`.

1. **Fingerprint** → `board-acl-bypass` (alias "canReadBoard/canManageBoard skipped").
2. **Recurrence** → re-read the log, then `grep -nE '^\| *[0-9-]{10} *\| *board-acl-bypass *\|' docs/hardening-log.md` → no match → new.
3. **Rung** → 4 (test): a behavioral invariant — "caller without board access cannot create cards" — that a convex-test pins durably; no lint rule decides board ACL logic.
4. **Apply** → add a convex-test for `cards.create` with a caller that has workspace membership but lacks board-ACL (`visibility: 'private'`, non-owner member) → asserting `Forbidden: no access to this board`.
5. **Verify** → `pnpm test` → pass; then full `pnpm quality` (code changed) → green.
6. **Log** → re-read the log; if no `board-acl-bypass` row appeared meanwhile, append:
   `| 2026-07-05 | board-acl-bypass | cards.create writable without board-ACL check for private boards | gate-b | major | 4 test | convex/cards.test.ts |`

## Stop and ask

- Intake is missing the finding text, source, or severity.
- The finding fits two rungs, or it's unclear whether a tool can decide it.
- Hardening would break the gate and no prerequisite story exists to reference.

## Common mistakes

- Logging a rung-0 already-caught finding (the log is a hardening ledger).
- Treating a non-blocking warning as rung 0 (making it block is rung 2).
- Filing an auth/ACL finding as prose when a lint/type/test would catch it.
- Grepping the whole log line instead of the anchored column-2 pattern (false hits
  on `finding`/`ref`).
- Escalating a `pending` recurrence instead of reporting blocked-by-prerequisite.
