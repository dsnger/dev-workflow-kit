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
| `source-files/CLAUDE.md` | discipline rules §1–5 | seed for the /workflow-init template — **not** the root `CLAUDE.md`, see below |
| prompt-standards.md | 11-criteria checklist | template + the plugin repo's own standard |
| hardening-log.md | FORMAT reference ONLY (sanitized: real findings removed) | template: empty ledger with header/convention |
| coding-workflow.md | neutral overall documentation | basis for the plugin README |
| .gitattributes | union merge for the ledger | template line |
| pnpm-workspace.yaml | supply-chain policy (minimumReleaseAge) | template |
| ci.yml | quality CI workflow | template (mark the battery steps as stack-specific) |
| knip.json, .fallowrc.jsonc | battery configs | examples ONLY — stack-specific, not plugin content |
| codex-config.toml, .mcp.json | reviewer pin + MCP wiring | templates |
| eslint-rules/ | custom rules | example ONLY (Convex-specific) — document, don't generalize |

**Three different `CLAUDE.md` files, and the bare name above once cost a review.** Every
row in this table names a path under `source-files/`, but read alone the unqualified
`CLAUDE.md` resolves to the repo root — a PR bot did exactly that on #18 and raised a
Major saying the root file was "a reusable template" that must not hardcode a user's
name. It is not. The three:

- **`source-files/CLAUDE.md`** — the frozen extraction seed this row describes. Never
  edited (see the header above).
- **The inline copy inside `plugins/dev-workflow/commands/workflow-init.md`** — the
  *operative* scaffold, the only one a user's project ever receives. Invariant 8 keeps it
  inline in the command body, so nothing reads a template off disk. It covers **§1–§5**,
  and `/workflow-init` §2.1 scaffolds it by that name.
- **The repo-root `CLAUDE.md`** — this project's own instance of the rules, governing
  work in this repo. It is not a template and is not read by `/workflow-init`.

**Root `CLAUDE.md` additionally carries a repo-local §6 (context canary) that sits
deliberately outside the §1–§5 template range and must never be synced into the
scaffolded template.** The canary names one user; propagating it would address every
initialized project's user by that name. The section number is the guard — a sync that
copies §1–§5 leaves it behind by construction — and this sentence is the durable record
of why, since nothing mechanical enforces the range.

## Not included (deliberately)
- AGENTS.md (the source project's invariants — written fresh per project; /workflow-init walks you through it)
- Ledger CONTENTS, baselines, todo contents (project state)
- Superpowers (external dependency, documented as a prerequisite)
