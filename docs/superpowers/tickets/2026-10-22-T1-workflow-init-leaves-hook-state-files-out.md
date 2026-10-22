# T-1 — `/workflow-init` leaves the hook's state files out of `.gitignore`

**Category:** improvement · **State:** in-progress · **Severity:** major · **First seen:** unknown — every `/workflow-init` version so far writes no `.gitignore` lines; checked at `35d8596` only
**No story:** the commitment comes from `AGENTS.md` invariants 3 and 9 and `/workflow-init` 2.12; the fix's Gate-B provenance line names `none`
**Feature:** `/workflow-init` Step 2 (scaffolded files), `plugins/dev-workflow/commands/workflow-init.md`

## Commitment
"additive files (`.gitattributes`, `.mcp.json`, …) → merge. Scaffolded project files accumulate real content, and a silent overwrite destroys it." — `AGENTS.md` invariant 9

"**Commit it.** `CLAUDE.md` is committed, so a clone is adopted the moment it lands; leaving the marker untracked would make adoption depend on who ran this command." — `plugins/dev-workflow/commands/workflow-init.md` § 2.12

The hook's own state is per clone: "`.context/` is committed in some projects — the adoption marker is meant to be shared" — `plugins/dev-workflow/hooks/codex-gate.sh` (fingerprint comment); this repository's `.gitignore` states the consequence: "a committed pass count (`codex-gate.passes`) hands every fresh clone a pre-counted Gate-B pass."

## Observed
SFX ignores the hook's state files by hand, name by name; its `.gitignore` lists five and missed `codex-gate.freshPasses` and `codex-gate.passes`, which were committed once inside a cycle — evidence: SFX T-7 (2026-10-22), as reported in `.context/sparring/20261022-065500-kit-0401-prompt.md`. `grep -nE 'gitignore' plugins/dev-workflow/commands/workflow-init.md` finds no step that writes `.gitignore` lines for them.

The hook names 20 file names under `.context/` (`grep -noE 'codex-gate\.[A-Za-z0-9_.$-]+'`, plus the `cap-extra` and `.<id>`-suffixed names the narrower `[A-Za-z]+` grep misses). It only reads `on`, `off`, `floor`, `cap` and `tools` (no write or delete of those variables in the hook); it writes or deletes all the others.

## Expected
`/workflow-init` merges one block into `.gitignore` that ignores the hook's state and keeps the five human-written settings trackable; it reports already tracked state files with the `git rm --cached` command and never removes them itself — source: invariant 9 (merge additive files), § 2.12 (the marker is committed); requested by: orchestrator session `dev-workflow-kit-82`, prompt `.context/sparring/20261022-065500-kit-0401-prompt.md`.

## Repro
1. Run `/dev-workflow:workflow-init` in a project, run a Gate-B pass.
2. `git status` lists `.context/codex-gate.passes` and the other counters as untracked; `git add -A` commits them.

## Brief
- Fix scope: a new `/workflow-init` step that merges the block (pattern `.context/codex-gate.*` with `!` exceptions for `on`, `off`, `floor`, `cap`, `tools`), checks that `codex-gate.on` is not ignored after the merge, and reports tracked state files with `git rm --cached`; `docs/reference.md`, `CHANGELOG.md`, `todos.md`; version bump.
- Out of scope: the rest of `.context/` (handovers, evidence, `codex-reviews/`); this repository's own `.gitignore`; any hook behaviour change.
- Feedback loop: throwaway harness — a scratch git repo with the block, `git check-ignore --no-index` over every name the hook uses. A failing test at a seam is not feasible: the deliverable is a prompt, and no suite runs `/workflow-init`. Red before the fix: with no block, every `codex-gate.*` state file is reported not ignored.
- Read first: `AGENTS.md` invariants 3, 8, 9, 11; `/workflow-init` § 2.6 and § 2.12; `docs/reference.md` state-file table.

## Log
- 2026-10-22 · created · ready
- 2026-10-22 · in-progress · fix on branch kit/0.40.1
