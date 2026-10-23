# Living docs adopted into the kit (pilot-tested elements) — Story

**Date:** 2026-10-23 · **Size:** story · **Checkpoints:** none
**Risk:** standard · **Security:** none · **Validation:** battery+check

## 1. Problem statement
The living-docs pilot on the SFX dashboard ended with the recommendation *adapt*
(`docs/field-reports/2026-10-23-living-docs-pilot-report.md`, § Recommendation). Nothing of the
model is in the kit yet: a project initialized with `/workflow-init` gets no rule for structure
documents, feature docs, a documentation map or a build record, so each project would reinvent
them, and the pilot's own setup lived in one project's files only. The pilot also found four gaps
in what it exercised: P7 left three affected feature docs stale because the build record listed
only the docs it edited; the kit's `CLAUDE.md` template still says architecture lives in
`@AGENTS.md` (`plugins/dev-workflow/commands/workflow-init.md:567`), and SFX's 0.39.0 adoption put
that sentence back over the pilot's; the pilot's link checker lived in a scratchpad and its
replacement lost heading-fragment coverage; and most setup and upkeep effort was not captured.

## 2. Desired outcome
Daniel decided on 2026-10-23 at 08:40 (D22, orchestrator prompt
`.context/sparring/20261023-084500-kit-042-living-docs-prompt.md`) to adopt the elements the pilot
exercised, with the pilot's four changes, and nothing else. A project that runs `/workflow-init`
can take up living docs: structure documents with a feature map, feature docs, the documentation
map in `AGENTS.md` (the signpost), docs updated in the same change, a build record
`changed | checked, unchanged` at the end of a change, and a size soft alarm. The four changes hold:
the build record covers every affected feature doc and the instruction files' authority claims,
the scaffolded `CLAUDE.md` agrees with the signpost, a link check that also checks heading
fragments is kept in the repository, and effort is stamped per piece. Existing projects take it
up through `/workflow-init`'s normal rules, never silently. The elements the pilot did not
exercise stay out: they are not tested, and the report draws no conclusion about them.

## 3. Acceptance criteria
_IDs are permanent once the story is committed: never renumber or reuse one; a new criterion takes the next number unused here and on the branch it merges into, and a collision stops for a human; a removed one stays, struck through and dated; a narrowed one keeps its ID with a dated note; cite as `<story path> AC-<n>`; full rules: dev-workflow:intake, "Acceptance-criterion IDs"._
- [x] **AC-1** `/workflow-init` scaffolds the living-docs rules for the exercised elements: structure documents with a feature map, feature docs with descriptive authority and provenance, the documentation map in `AGENTS.md`, docs updated in the same change, the build record `changed | checked, unchanged`, and a size soft alarm that never fails a check. It writes no empty structure document.
- [x] **AC-2** The build-record rule requires one line for every feature doc whose described behaviour or `Planned` section the change affects, neighbours included, not only the docs the change edited; a missing line is a finding.
- [x] **AC-3** The build-record rule covers the instruction files that carry authority claims (`CLAUDE.md`, the documentation map), and the scaffolded `CLAUDE.md` template's sentence about where architecture lives agrees with the documentation map instead of naming `@AGENTS.md` as its home.
- [x] **AC-4** A link check that resolves relative Markdown links and their heading fragments is kept in the repository: this repo's `scripts/check-doc-links.sh` checks fragments, and an initialized project can get the same checker from `/workflow-init` without a second hand-kept copy drifting from it.
- [x] **AC-5** The rules require effort to be stamped per piece of setup and upkeep work, with its unit and how it was captured, and `unknown` where it was not captured.
- [x] **AC-6** An existing project takes up the change only through `/workflow-init`'s idempotent rules (missing → write; identical → unchanged; different → diff and ask); nothing it already has is overwritten silently.
- [x] **AC-7** No project vocabulary from the pilot (SFX feature, file or tool names) appears in the scaffolded templates or skills.
- [x] **AC-8** The unexercised elements — features named at intake, map-guided builder context, cross-feature flows, the impact-check end, the conflict and composed-candidate checks, removal, the splitting decision, capability levels — are named as non-goals in the spec and in the user docs, and no new rule enacts them.
- [x] **AC-9** The gate rules stay at 10,000 bytes or less (check 4i) and the `CLAUDE.md` template under 20,000 characters (check 4e); the quality battery is green.
- [x] **AC-10** The pilot report's AC-4 line on the P7 heavy-run go states that the go was given on 2026-10-22 at 23:16, citing the orchestrator board line "sfx P7 u2 go for p7-demo".
- [x] **AC-11** The docs describing changed behaviour are updated in the same change (README, `docs/reference.md`, `docs/ARCHITECTURE.md` when files are added, `plugins/dev-workflow/CHANGELOG.md`), the plugin version is 0.42.0, the pilot story's AC-9 notes that adoption is this story, and the `todos.md` rows this story settles are closed.

_Status 2026-10-23: all ticked on the branch head before the PR: Gate A cycle lda7k42q (3 passes), Gate B cycle kgb42x7m (2 passes, the second clean), battery green, check 4e 12,762 characters, `.claude/review-gates.md` 9,995 bytes, prompt eval 7/7._

## 4. Affected AGENTS.md invariants
- `## Key invariants` — "8. **`/workflow-init`'s templates stay inline** in the command body."
- `## Key invariants` — "9. **`/workflow-init` never overwrites silently.** Idempotent: missing → write; identical → report unchanged; present and different → show the diff and ask; additive files (`.gitattributes`, `.mcp.json`, …) → merge."
- `## Key invariants` — "10. **The base taxonomy stays stack-neutral.**"
- `## Key invariants` — "11. **Prompt changes pass `docs/prompt-standards.md`** — all 12 checklist items, for any skill, command, agent definition, hook message, or scaffolded template."
- `## Key invariants` — "12. **A plugin change requires a version bump.**"
- `## Don'ts` — "**Never rename or delete a doc section without grepping for references first.**"
- `## Don'ts` — "**Never describe what a gate proves without checking what it actually compares.**"
- `## Commands` — "Check 4i caps the gate rules at 10,000 bytes"; check 4e (the `CLAUDE.md` template budget, invariant 8).

## 5. Open questions
- None. Scope and the four changes are settled by D22; design choices are the spec's.

## 6. Suggested size
story — one coherent kit change: one rules text, one template sentence, one checker extension, docs; one spec → plan → PR.
