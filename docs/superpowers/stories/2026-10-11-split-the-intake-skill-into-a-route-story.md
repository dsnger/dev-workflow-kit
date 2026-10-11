# Split the intake skill into a route choice and route files — Story

**Date:** 2026-10-11 · **Size:** story
**Risk:** standard · **Security:** none · **Validation:** battery+check

## 1. Problem statement
`plugins/dev-workflow/skills/intake/SKILL.md` (dev-workflow 0.23.0, 32,932 bytes) holds two
routes that share no steps: capturing a new story (the Flow) and amending an approved story or
spec. Every intake run loads both, although each run follows one. The strand-C pilot
(`docs/superpowers/replays/2026-10-10-intake-skill-pilot/` on branch `intake-skill-pilot`,
`b348b9c`) measured a split into a route-choosing page plus one file per route at −21 % (capture)
and −30 % (amend) of the text a run reads, with no change in cost. That pilot was built on the
skill at `860e56c`, before 0.23.0 changed the amendment route, and it left three things
unshown: case D equal to the baseline, a run with an installed (not `--plugin-dir`) plugin, and a
run through a compaction (handover `.context/handover-mcp-security.md`, entry 2026-10-10 18:00).

## 2. Desired outcome
An intake run reads the shared part of the skill plus only the route it follows, and behaves
exactly as the 0.23.0 skill does: no duty, stop, approval boundary, identifier rule, output
format or hand-off is lost. The split ships only if a replay shows that, including the three
runs the pilot left open; otherwise it is not adopted and the shipped skill stays as it is.

## 3. Acceptance criteria
_IDs are permanent once the story is committed: never renumber or reuse one; a new criterion takes the next number unused here and on the branch it merges into, and a collision stops for a human; a removed one stays, struck through and dated; a narrowed one keeps its ID with a dated note; cite as `<story path> AC-<n>`; full rules: dev-workflow:intake, "Acceptance-criterion IDs"._
- [ ] **AC-1** For each of the two routes, the text an intake run following that route must read is smaller, in characters, than the 0.23.0 `SKILL.md`.
- [ ] **AC-2** Every duty, stop, approval boundary, acceptance-criterion-ID rule, output format and hand-off of the 0.23.0 skill is present after the split, and a complete old→new account marks each part of the 0.23.0 skill as verbatim, moved or reworded; none is marked dropped.
- [ ] **AC-3** A replay of the pilot's cases A–G, each once, and of D and G three times each, with the 0.23.0 skill and with the split, shows no regression: no check the 0.23.0 run meets is missed by the split run, using the pilot's definition of regression.
- [ ] **AC-4** In case D, every replicate run with the split meets every check its baseline run meets.
- [ ] **AC-5** A run with the split installed as a plugin (from a marketplace into the plugin cache, not loaded with `--plugin-dir`) reads its route file and completes its route.
- [ ] **AC-6** A run in which a compaction happens after a route has started still applies that route's remaining steps, including its approval stops, after the compaction.
- [ ] **AC-7** If any of AC-3 to AC-6 fails, the split is not shipped: the skill on `main` stays the 0.23.0 text, and the failed result is recorded in the replay package.
- [ ] **AC-8** Invocation and outputs are unchanged: the skill name, its trigger description, the story path and file format, and the change-record format are the same as in 0.23.0.
- [ ] **AC-9** The repository's quality battery is green, and each mechanical check that reads the intake skill reads the text where it now lives.
- [ ] **AC-10** The plugin version is raised and `CHANGELOG.md` has an entry for the change.

## 4. Affected AGENTS.md invariants
- `## Key invariants` (Prompts and scaffolding) — "11. **Prompt changes pass `docs/prompt-standards.md`** — all 12 checklist items, for any skill, command, agent definition, hook message, or scaffolded template." Its list of narrow checks names "the `intake` story template's `AC-<n>` criterion rows under their rule line" and "the `intake` amendment route's change-record template and its closed sets".
- `## Key invariants` (Packaging) — "12. **A plugin change requires a version bump.** A pull request that changes any path under a `plugins/<name>/` directory **that still exists at HEAD** … must also change that plugin manifest's `version`, or CI fails."
- `## Key invariants` (Packaging) — "6. **The manifest never re-declares convention-loaded components.** `skills/`, `commands/`, `agents/` and `hooks/hooks.json` load automatically".
- `## Architecture` — the layout tree line "skills/{intake,harden-finding,sparring}/SKILL.md".
- `## Don'ts` — "**Never rename or delete a doc section without grepping for references first.**"

## 5. Open questions
- None. Decided 2026-10-11 by the orchestrator under Daniel's sprint instruction (relayed by `dev-workflow-kit-d4`): the three deferred intake Minors (`todos.md`, "From the added-criterion change") stay out of this story, so one measurement has one cause; the replay is the pilot's full after-check plus the two handover runs; the split is rebuilt on 0.23.0's text, not on the pilot's candidate.

## 6. Suggested size
story — one skill restructured, one replay, one spec → plan → PR.
