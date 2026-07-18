# dev-workflow-kit — seed (extracted from the source project, as of 2026-07-10)

Unmodified copies of the workflow artifacts. The source is no longer needed — this
archive is the complete extraction base.

## source-files/ — what is what

| File/folder | Role | Plugin target |
|---|---|---|
| skills/intake, skills/harden-finding | the two project skills | plugin (generalize! taxonomy split for harden-finding) |
| commands/process-pr-review.md | PR bot processor | plugin (make bot names configurable) |
| hooks/codex-gate.sh + .test.sh | gate counter/reminder | plugin (loaded by convention from `hooks/hooks.json` — never declared in the manifest) |
| claude-settings.json | shows HOW the hook is wired up in a *project* (settings.json), which the plugin replaces with convention loading | reference only |
| CLAUDE.md | discipline rules §1–5 | /workflow-init template (project file) |
| prompt-standards.md | 10-criteria checklist | template + the plugin repo's own standard |
| hardening-log.md | FORMAT reference ONLY (sanitized: real findings removed) | template: empty ledger with header/convention |
| coding-workflow.md | neutral overall documentation | basis for the plugin README |
| .gitattributes | union merge for the ledger | template line |
| pnpm-workspace.yaml | supply-chain policy (minimumReleaseAge) | template |
| ci.yml | quality CI workflow | template (mark the battery steps as stack-specific) |
| knip.json, .fallowrc.jsonc | battery configs | examples ONLY — stack-specific, not plugin content |
| codex-config.toml, .mcp.json | reviewer pin + MCP wiring | templates |
| eslint-rules/ | custom rules | example ONLY (Convex-specific) — document, don't generalize |

## Not included (deliberately)
- AGENTS.md (the source project's invariants — written fresh per project; /workflow-init walks you through it)
- Ledger CONTENTS, baselines, todo contents (project state)
- Superpowers (external dependency, documented as a prerequisite)
