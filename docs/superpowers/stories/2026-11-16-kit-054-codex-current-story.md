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
sends the user back. What the exact pin guarded stays in view: each assumption about Codex is either checked at
run time, where a break fails the attempt and never passes it, or shown to hold on the current CLI and named as
unchecked. A session whose risk pass cannot run knows from the rules what to do.

## 3. Acceptance criteria
_IDs are permanent once the story is committed: never renumber or reuse one; a new criterion takes the next number unused here and on the branch it merges into, and a collision stops for a human; a removed one stays, struck through and dated; a narrowed one keeps its ID with a dated note; cite as `<story path> AC-<n>`; full rules: dev-workflow:intake, "Acceptance-criterion IDs"._
- [ ] **AC-1** The risk pass accepts Codex CLI 0.169.0 and later releases without any change to the user's
  installation; a CLI below the stated minimum and a version line it cannot read are refused before anything is
  written, and the message says which of the two it was.
- [ ] **AC-2** The evidence file the script completes for an attempt starts with the version line of the CLI
  that ran it. A raw evidence file the reviewer left in an attempt that ended before that step carries no such
  line, and its first line tells the two apart. (narrowed 2026-11-16: the script adds the line after Codex ends;
  see the change record below)
- [ ] **AC-3** For each assumption the pin guarded — the scratch directory in the git directory is out of the
  reviewer's reach under `workspace-write`; the reply is the last agent message of the `--json` event log; Codex
  discovers the review skill under `.agents/skills/` — either a break fails the attempt at run time, or the
  assumption is shown to hold on 0.169.0 with the observed result recorded and is named as not checked at run
  time; a check that exists fails the attempt and never passes it. Whether the model follows the skill's method
  stays an instruction, as before. (narrowed 2026-11-16: the order says "keep each one as a runtime check or show
  it still holds on 0.169.0" and names "the skill discovery"; see the change record below)
- [ ] **AC-4** The rules a session reads at Gate B say what it does for a risk pass that cannot run or keeps
  failing, and under them a cycle never closes without the pass's `done` record.
- [ ] **AC-5** No shipped text names 0.162.1 as a requirement or tells the user to install an older or a fixed
  Codex CLI; notes of what was verified at 0.162.1 stay as history.
- [ ] **AC-6** The kit's copies and the `/workflow-init` templates are identical (checks 4j and 4o), the version
  record reads 0.54.0 in its three places (check 4n), the CHANGELOG has a § 0.54.0, and the quality command is green.

**Changed 2026-11-16 — gap found.** Decided by this session in the autonomous run, against the order
`.context/sparring/20261116-0930-kit-054-codex-current-prompt.md` ("What to settle"), before the spec's Gate A
closed and so before anything was approved. Baseline: `ed2a5c5`. Gate A on the spec (cycle `k054spec1`, pass 1
findings 1 and 4, pass 2 findings 1 and 2) showed three places where this session's first wording outran the
order and the script: AC-3 asked for a run-time failure for every assumption, where the order says "keep each one
as a runtime check or show it still holds on 0.169.0"; AC-3 named "Codex follows the review skill", where the
order names "the skill discovery under `.agents/skills/`" (a script cannot see whether a model followed an
instruction); and AC-2 promised the CLI line in every attempt's evidence file, while the reviewer writes that
file and the script adds the line only once Codex has ended.

| Earlier condition | Fate | AC operation |
|---|---|---|
| §2 "an assumption about Codex that stops holding fails the attempt and never passes it" | kept — narrowed to the assumptions that get a run-time check; the others are shown and named as unchecked | none (not a criterion) |
| AC-2 "Every attempt's evidence file records the version line" | kept — narrowed to the evidence file the script completes; a raw file from an attempt that ended earlier has no such line and is told apart by its first line | narrowed |
| AC-3 "a break fails the attempt at run time" for each assumption | kept — narrowed to the order's alternative: a run-time check, or shown to hold on 0.169.0 and named as not checked at run time | narrowed |
| AC-3 "Codex follows the review skill under `.agents/skills/`" | kept — narrowed to the order's "skill discovery"; following the method stays an instruction, as before 0.54 | narrowed |
| AC-3 "shown to hold on 0.169.0 with the observed result recorded" | kept | none |
| AC-1, AC-4, AC-5, AC-6 | kept | none |

- **Added without an earlier condition:** none.
- **Unaccounted:** none.
- **Intervening changes:** none since `ed2a5c5` on this story.
- **Scope boundary:** in: which assumptions get a run-time check and which are shown and named; what an evidence
  file's first line says; out: a sandbox probe before each run, any proof that the model followed the skill, and
  a CLI record for attempts that end before the script's evidence step.
- **Open questions:** none.
- **Dependent artifacts:** `docs/superpowers/specs/2026-11-16-kit-054-codex-current-design.md` → updated in this change.
- **Reviews already run:** Gate A spec cycle `k054spec1` passes 1 and 2 → the cap (2) was reached with pass 2's
  two findings open; per `.claude/review-gates.md` ("At the cap … an open Blocker, Security-class or violated-AC
  finding, goes to the human") Daniel answered on 2026-11-16 in this session: "Jetzt schließen" — close with the
  repairs above and no further pass; the plan's Gate A reads this story and the spec again.

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
