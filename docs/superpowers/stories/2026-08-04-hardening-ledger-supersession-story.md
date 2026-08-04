# The hardening ledger has no supersession convention — Story

**Date:** 2026-08-04 · **Size:** story

**Unprofiled, deliberately** — a split from a designed round, so it bypassed
`dev-workflow:intake`, which excludes work already in solution design. A profile written now
would look confirmed without being confirmed, and nothing would reveal that; acceptance
criterion 1 carries the debt instead.

## 1. Problem statement

`docs/hardening-log.md`'s header says never edit a row, and one row per hardening. When a row's
"what this does NOT do" narration is later falsified by a feature change, neither move is
sanctioned: editing breaks the first rule, appending breaks the second.

This is live. The 2026-07-20 row describes pre-0.8.0 counting behaviour as current, and a reader
who trusts it is misled about how the gate hook counts today. That is the second falsified row,
which is the condition the parked backlog row named as its trigger.

### Conditions inherited from the source row

From `todos.md`, "**The hardening ledger has no supersession convention.**":

| Condition | Disposition |
|---|---|
| Never edit a row | **kept** — any solution must preserve it |
| One row per hardening | **kept** — any solution must preserve it |
| The 2026-07-20 row now describes pre-0.8.0 behaviour as current | **kept** as the motivating instance |
| The 2026-07-20 *spec* took a version-qualified supersession note and it worked | **kept** as prior art the design should evaluate first |
| Alternative: an explicit "rows are historical, read the newest row for current behaviour" header statement | **kept** as a candidate |
| Trigger: the next row falsified by a later change — this is the second | **moved** — fired, and recorded here |

## 2. Desired outcome

A reader who opens any ledger row can tell whether it still describes current behaviour, and a
row falsified by a later change can be marked as such without breaking either standing rule.

## 3. Acceptance criteria

- [ ] Before design resumes on this story, whoever picks it up proposes both axes and the mode
      derived from them, pauses for Daniel's confirmation, and writes the confirmed profile into
      this header. Design continues only after that.
- [ ] The 2026-07-20 row no longer reads as current behaviour, and it was not edited.
- [ ] The append-only rule and the one-row-per-hardening rule both still hold after the change.
- [ ] A reader can determine, from the ledger alone, which row to trust for current behaviour.

## 4. Affected AGENTS.md invariants

- `## Key invariants` → `### Prompts and scaffolding` — "8. **`/workflow-init`'s templates stay
  inline** in the command body."
- `## Key invariants` → `### Prompts and scaffolding` — "9. **`/workflow-init` never overwrites
  silently.** Idempotent: missing → write; identical → report unchanged; present and different →
  show the diff and ask; additive files (`.gitattributes`, `.mcp.json`, …) → merge."
- **Conditional, if the design reaches the scaffolded template** — "11. **Prompt changes pass
  `docs/prompt-standards.md`**" and "12. **A plugin change requires a version bump.**" Both bind
  only if the convention must reach `/workflow-init`'s inline ledger header, which is §5's open
  question.

## 5. Open questions

- Which artifacts must the convention reach before a reader can trust any row — this repo's
  ledger alone, or every ledger `/workflow-init` scaffolds? A repo-only fix ships a rule this
  kit's ledger obeys and every scaffolded one does not.

## 6. Suggested size

`story` — one file's header convention plus possibly one inline template, one spec → plan → PR.
