# A §5 version stamp, so a scaffolded CLAUDE.md can tell it lags the plugin — Story

**Date:** 2026-08-04 · **Size:** story

**Unprofiled, deliberately** — a split from a designed round, so it bypassed
`dev-workflow:intake`. A profile written now would look confirmed without being confirmed;
acceptance criterion 1 carries the debt instead.

## 1. Problem statement

`/workflow-init` scaffolds `CLAUDE.md` §5 from an inline template. When the plugin's §5 changes,
every previously scaffolded copy silently lags, and nothing in the scaffolded file tells its
reader so. One known-stale instance exists and is being re-synced by hand.

### Conditions inherited from the source row

From `todos.md`, "**Finding B — a §5 version stamp, so a scaffolded CLAUDE.md can tell it lags
the installed plugin.**":

| Condition | Disposition |
|---|---|
| A semantic §5 locator is needed — `/workflow-init` may append the section renumbered, so "no §5 heading" can misread a valid section and append a duplicate | **kept** |
| Per-state merge semantics: invariant 9 forbids a silent overwrite, and "re-run init to sync" promises what the command cannot give | **kept** |
| Stamp cardinality: absent, duplicate, malformed | **kept** |
| The binding must be real on **every** push path; the version-bump coupling first proposed was false, since invariant 12's checker is `pull_request`-only | **kept** — the false coupling is recorded so it is not re-proposed |
| A stamp is a **wire format**: shipping a provisional one writes legacy into every scaffolded file | **kept** — it is why a provisional stamp is unacceptable |
| The one known-stale instance is being re-synced by hand, so this carries no schedule pressure | **kept** — the work is not urgent |
| Trigger: the next round that touches the §5 template | **moved** — fired by the 2026-08-03 round, recorded here |

## 2. Desired outcome

A reader of a scaffolded `CLAUDE.md` can tell whether its §5 matches the installed plugin's,
without comparing the two by hand.

## 3. Acceptance criteria

- [ ] Before design resumes on this story, whoever picks it up proposes both axes and the mode
      derived from them, pauses for Daniel's confirmation, and writes the confirmed profile into
      this header. Design continues only after that.
- [ ] A scaffolded `CLAUDE.md` whose §5 lags the installed plugin is detectable as such.
- [ ] Re-running `/workflow-init` on a stale file behaves per invariant 9 — it does not silently
      overwrite accumulated content.
- [ ] Whatever binding the design chooses holds on every push path, not only on pull requests.

## 4. Affected AGENTS.md invariants

- `## Key invariants` → `### Prompts and scaffolding` — "8. **`/workflow-init`'s templates stay
  inline** in the command body. Claude Code does not expand `${CLAUDE_PLUGIN_ROOT}` inside
  command markdown (verified), and the cache path is not an API."
- `## Key invariants` → `### Prompts and scaffolding` — "9. **`/workflow-init` never overwrites
  silently.**"
- `## Key invariants` → `### Prompts and scaffolding` — "11. **Prompt changes pass
  `docs/prompt-standards.md`** — all 12 checklist items."
- `## Key invariants` → `### Packaging` — "12. **A plugin change requires a version bump.**"

## 5. Open questions

- How can a scaffolded `CLAUDE.md` tell its reader that it lags the installed plugin?

## 6. Suggested size

`story` — one stamp format and its detection, one spec → plan → PR. Not a chore: a wire format
shipped provisionally cannot be taken back.
