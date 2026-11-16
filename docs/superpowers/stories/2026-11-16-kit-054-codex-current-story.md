# Kit 0.54: the risk pass runs on the current Codex CLI — Story

**Date:** 2026-11-16 · **Size:** story · **Checkpoints:** none
**Risk:** high · **Security:** standard · **Validation:** battery+check+verification

## 1. Problem statement
`risk-pass.sh` (`/workflow-init` 2.26, kit copy `.agents/skills/gate-b-review/scripts/risk-pass.sh`) refuses any
Codex CLI but `codex-cli 0.162.1` (exit 6). On 2026-11-16 09:09 this Mac's global Codex became 0.169.0, so every
session's risk pass refuses, and the gate rules name no route for a risk pass that cannot run (finding from the
kit-053-search refresh session). Order: `.context/sparring/20261116-0930-kit-054-codex-current-prompt.md`.
Profile, set in an autonomous run without a question round (CLAUDE.md §4): risk is `high` because the change
replaces an exact version pin on a third-party tool the gate executes (supply chain); security is `standard`
because the pin guarded assumptions about Codex's sandbox, a trust boundary whose permissions do not change.

## 2. Desired outcome
The risk pass runs on the Codex CLI the user has installed globally, in its current version, and keeps running
when that CLI updates, because Daniel decided on 2026-11-16: "Wir gehen auf keinen Fall zurück. Codex läuft global
und da soll die neueste Version laufen." No downgrade, no wrapper around an older version, no install step that
sends the user back. What the exact pin protected stays protected: an assumption about Codex that stops holding
fails the attempt and never passes it. A session whose risk pass cannot run knows from the rules what to do.

## 3. Acceptance criteria
_IDs are permanent once the story is committed: never renumber or reuse one; a new criterion takes the next number unused here and on the branch it merges into, and a collision stops for a human; a removed one stays, struck through and dated; a narrowed one keeps its ID with a dated note; cite as `<story path> AC-<n>`; full rules: dev-workflow:intake, "Acceptance-criterion IDs"._
- [ ] **AC-1** The risk pass accepts Codex CLI 0.169.0 and later releases without any change to the user's
  installation; a CLI below the stated minimum and a version line it cannot read are refused before anything is
  written, and the message says which of the two it was.
- [ ] **AC-2** Every attempt's evidence file records the version line of the CLI that ran it.
- [ ] **AC-3** For each assumption the pin guarded — the scratch directory in the git directory is out of the
  reviewer's reach under `workspace-write`; the reply is the last agent message of the `--json` event log; Codex
  follows the review skill under `.agents/skills/` — a break fails the attempt at run time, and the assumption is
  shown to hold on 0.169.0 with the observed result recorded.
- [ ] **AC-4** The rules a session reads at Gate B say what it does for a risk pass that cannot run or keeps
  failing, and under them a cycle never closes without the pass's `done` record.
- [ ] **AC-5** No shipped text names 0.162.1 as a requirement or tells the user to install an older or a fixed
  Codex CLI; notes of what was verified at 0.162.1 stay as history.
- [ ] **AC-6** The kit's copies and the `/workflow-init` templates are identical (checks 4j and 4o), the version
  record reads 0.54.0 in its three places (check 4n), the CHANGELOG has a § 0.54.0, and the quality command is green.

## 4. Affected AGENTS.md invariants
- `## Key invariants` › Packaging — "5. **Every version pinned exactly.** No floating `npx -y <pkg>`, `@latest`,
  or major-only action ref (`actions/checkout@v4`), anywhere — CI, `.mcp.json`, docs, and the inline templates
  `/workflow-init` writes" and "Four bounded exceptions, stated rather than silent"
- `## Key invariants` › Packaging — "12. **A plugin change requires a version bump.**"
- `## Key invariants` › Prompts and scaffolding — "8. **`/workflow-init`'s templates stay inline** in the command
  body." and "11. **Prompt changes pass `docs/prompt-standards.md`** — all 12 checklist items"
- `### Boundaries (binding)` — "4c. … `.agents/skills/gate-b-review/scripts/risk-pass.sh` and
  `scripts/gate-b-risk-pass.test.sh` (runs `codex exec`; writes only under `.context/codex-reviews/` … plus one
  `mktemp -d` scratch directory in the repository's git directory, removed on exit, since 0.53; out of the Codex
  sandbox's reach unless the checkout lies in `TMPDIR` or `/tmp`, where exclusive no-follow creates and an identity
  check of that directory stand in)"
- `## Commands` — "`risk-pass.sh` refuses any Codex CLI but `codex-cli 0.162.1` (exit 6); its suite stubs `codex`."
  and "**Check 4i caps the gate rules at 10,000 bytes**"
- `## Don'ts` — "**Never describe what a gate proves without checking what it actually compares.**", "**Never
  replace a decision procedure without accounting for its old conditions.**" and "**Never document a command that
  wasn't run.**"

## 5. Open questions
- None.

## 6. Suggested size
story — one script rule, its route in the rules and the texts that name the old pin; one spec, one plan, one PR.
