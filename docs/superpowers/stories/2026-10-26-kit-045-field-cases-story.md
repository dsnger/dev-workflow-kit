# Kit 0.45 field cases: cut-off Gate A replies, codebase-memory watchers, unbounded CI waits — Story

**Date:** 2026-10-26 · **Size:** story · **Checkpoints:** none
**Risk:** standard · **Security:** standard · **Validation:** battery+check

## 1. Problem statement
Three field cases from 2026-10-21 to 2026-10-25:

1. **A cut-off Codex reply is counted as a Gate A pass.** In Gate A `k044ga7q` (kit 0.44, 2026-10-24) the
   first `mcp__codex__exec` call asked for the findings in the reply. The server cut the reply after the first
   finding, and no findings file existed. The session ran pass 1 again into a file. The hook counted both calls:
   hook count 5, valid passes 4. The canvas S4 Gate A on 2026-10-21 showed the same mismatch, and the backlog row
   "Gate A replies truncated in transport again" (`todos.md`, from 0.40.0) records an earlier one. The gate rules
   name the pass file path but do not say that Codex writes it.
2. **codebase-memory watchers overload the machine.** On 2026-10-25 15:47 a merge and pull renamed hundreds of
   files. Every open session's own codebase-memory-mcp instance (about 27) re-indexed the same repository at once:
   8 workers at about 85 % CPU, load 70 on 16 cores. Daniel then set `auto_watch = false` globally. On the installed
   0.9.0, `config` lists `auto_watch default=true  Register background git watcher on session connect`. The kit's
   optional integration (`/workflow-init` 2.14–2.15, AGENTS.md invariant 5's fourth exception) does not mention it.
3. **A wait on CI with no limit.** On 2026-10-25 a session waited about 15 hours on a GitHub Actions run that never
   existed: the workflow file was invalid, so GitHub started no job. The long-run rules (CLAUDE.md §4, 0.44) cover
   local runs only.

## 2. Desired outcome
The hook's Gate A count matches the valid passes when a reply is cut off or no findings file is written. The rules
say who writes the pass file. The optional codebase-memory integration warns about watchers in many sessions and
recommends turning them off and refreshing on purpose. Every wait on external work first checks that the run exists,
has a time limit, and ends with a report instead of waiting forever. Initialized projects get the same rules.

## 3. Acceptance criteria
_IDs are permanent once the story is committed: never renumber or reuse one; a new criterion takes the next number unused here and on the branch it merges into, and a collision stops for a human; a removed one stays, struck through and dated; a narrowed one keeps its ID with a dated note; cite as `<story path> AC-<n>`; full rules: dev-workflow:intake, "Acceptance-criterion IDs"._
- [ ] **AC-1** The hook does not count a Gate A `exec` call that leaves no complete findings file (terminator present, count matching) where its pass was to be written, and it tells the session so. A call that leaves one is still counted. A hook test replays the kit-044 shape (findings asked in the reply, no file) and fails on 0.44.0.
- [ ] **AC-2** The gate rules say that Codex writes each pass's findings to the pass file the prompt names, and that a reply-only call is no pass. Both rule copies stay byte-identical (check 4j) and within 10,000 bytes (check 4i).
- [ ] **AC-3** Every statement of what the hook's Gate A count compares, in prompts and docs, names the comparison the code makes and what it does not establish.
- [ ] **AC-4** The `todos.md` rows on truncated Gate A replies are closed or updated by this change.
- [ ] **AC-5** `/workflow-init` 2.14 and AGENTS.md invariant 5's fourth exception state the watcher risk seen on 2026-10-25 and recommend `auto_watch` off plus a deliberate human refresh, with the key name and default as the installed 0.9.0 states them. The kit still sets no server configuration itself.
- [ ] **AC-6** This repository's `todos.md` § Tooling revalidation identity row records the watcher setting.
- [ ] **AC-7** CLAUDE.md §4 and its `/workflow-init` 2.1 template require that any wait on external work (a CI run, a deploy) first confirms the run exists (its id seen, status queued or in progress), has a time limit, and reports at that limit or when no run appears instead of waiting on. The template stays within check 4e's budget.
- [ ] **AC-8** The plugin version is 0.45.0, with a CHANGELOG entry and README/docs updates in the same PR, and the quality battery is green.

## 4. Affected AGENTS.md invariants
- `## Key invariants` › `### Hook` — "1. **The hook always exits 0.**" and "2. **Loose in the firing direction.** On uncertainty, fire."
- `## Key invariants` › `### Hook` — "4. **POSIX `sh`, and `jq` is optional.** No bash-isms; correct behaviour via fallback parsing when `jq` is absent."
- `## Key invariants` › `### Packaging` — "The fourth applies to **the optional codebase-memory MCP integration only** … The kit only restricts that server: it never installs, configures or registers it."
- `## Key invariants` › `### Packaging` — "12. **A plugin change requires a version bump.**"
- `## Key invariants` › `### Prompts and scaffolding` — "8. **`/workflow-init`'s templates stay inline** in the command body." and "Check 4e … fails when the `CLAUDE.md` template passes 20,000 characters"
- `## Key invariants` › `### Prompts and scaffolding` — "11. **Prompt changes pass `docs/prompt-standards.md`** — all 12 checklist items"
- `## Don'ts` — "**Never describe what a gate proves without checking what it actually compares.**"

## 5. Open questions
- None.

## 6. Suggested size
story — three small field cases with one shared release, one spec → plan → PR.
