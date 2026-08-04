# A route from a fixed finding to the ledger, for projects that never open PRs — Story

**Date:** 2026-08-04 · **Size:** story

**Unprofiled, deliberately** — a split from a designed round, so it bypassed
`dev-workflow:intake`. A profile written now would look confirmed without being confirmed;
acceptance criterion 1 carries the debt instead.

## 1. Problem statement

The only mandated ledger check lives in `/dev-workflow:process-pr-review` step 5, so a project
that never opens a pull request never reaches it. One project has 51 Gate-A pass files and
**zero** ledger rows: findings were raised, validated and fixed, and none was ever considered
for hardening.

### Conditions inherited from the source row

From `todos.md`, "**Finding A — a route from a fixed finding to the ledger for projects that
never open PRs.**":

| Condition | Disposition |
|---|---|
| Scope must match `process-pr-review` step 5 **exactly** — check every accepted actionable fixed finding, but invoke `harden-finding` only when a class matches or a new one is clearly warranted | **kept** — every approximating draft got this wrong |
| Cannot rest on same-session memory: a compaction, interruption or handoff loses the fixed-finding set and nothing detects the loss | **kept** |
| A durable handoff needs real design — identity, deduplication, consumption semantics | **kept**, and it is why this is a story rather than a mid-round addition |
| It mints `mandatory-step-anchored-to-optional-path` when it lands; minting earlier leaves a class no row uses | **kept** — the class is minted by the change that uses it |
| Evidence: canvas has 51 Gate-A pass files and 0 ledger rows | **kept** as the motivating instance |
| Trigger, first alternative: the next round that touches §5 | **moved** — fired by the 2026-08-03 round, recorded here |
| Trigger, second alternative: a project reporting an empty ledger across cycles that fixed findings | **kept** — it did not fire, and it remains the condition that would raise this independently |

## 2. Desired outcome

A project that fixes review findings without opening a pull request still reaches the ledger
check, and a fixed finding that warrants hardening is not lost to a compaction, an interruption
or a handoff.

## 3. Acceptance criteria

- [ ] Before design resumes on this story, whoever picks it up proposes both axes and the mode
      derived from them, pauses for Daniel's confirmation, and writes the confirmed profile into
      this header. Design continues only after that.
- [ ] A project with no pull requests reaches a ledger check on the findings it fixed.
- [ ] The route does not depend on same-session memory.
- [ ] The check's scope matches `process-pr-review` step 5 exactly — no wider, no narrower.

## 4. Affected AGENTS.md invariants

- `## Key invariants` → `### Prompts and scaffolding` — "11. **Prompt changes pass
  `docs/prompt-standards.md`** — all 12 checklist items, for any skill, command, agent
  definition, hook message, or scaffolded template."
- `## Key invariants` → `### Packaging` — "12. **A plugin change requires a version bump.**"

## 5. Open questions

- What has to be true for a fixed finding to reach the ledger in a project that never opens a
  pull request?

## 6. Suggested size

`story` — one route, one spec → plan → PR.
