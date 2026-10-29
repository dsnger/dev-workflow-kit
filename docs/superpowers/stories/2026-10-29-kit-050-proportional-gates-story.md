# Kit 0.50 proportional gates — Story

**Date:** 2026-10-29 · **Size:** story · **Checkpoints:** none
**Risk:** high · **Security:** standard · **Validation:** battery+check+verification

## 1. Problem statement

Gate effort does not scale with the change. A release that only bumps version numbers and the CHANGELOG ran a
full Gate B pass (sfx-bricks-api-builder release 1.14.0, PR #105). Daniel, 2026-10-29: "A release that only
changes version numbers and the CHANGELOG needs no Gate B." "None of this may escalate like that." One-line
docs PRs ran the whole battery for hours. Kit 0.49's closing commit only added cycle lines and moved review
archives, yet its new head needed a second ~39-minute `scripts/local-ci.sh` run just to carry the `quality`
status (`todos.md`, "0.50 field case"). A squash-merge whose tree equals the PR's final head (PR #102) has no
way to carry that head's verdict either.

Sources: `.context/sparring/20261029-1820-proportional-gates-prompt.md` (Daniel's order),
`.context/sparring/20261029-1800-kit-049-learnings-prompt.md` items 7–8, decisions D85 and D86, and the 0.49
story's change record moving item 7 here (all in the main checkout's `.context/` or this repository).

## 2. Desired outcome

Gate effort scales with the change, decided deterministically: a release-only commit needs no Gate B (D85); a
docs-only change keeps skipping Gate B as today, while instruction-bearing paths always get it (D86); a
docs-only or release-only change runs a light battery instead of the whole one; a head that differs from an
already-green head only in records, or not at all, inherits that verdict instead of re-running the battery.
Required check names stay. A 1-line docs or release PR costs almost nothing. The kit builds its own logic;
nothing is taken from sfx-factory (#121/#123).

## 3. Acceptance criteria
_IDs are permanent once the story is committed: never renumber or reuse one; a new criterion takes the next number unused here and on the branch it merges into, and a collision stops for a human; a removed one stays, struck through and dated; a narrowed one keeps its ID with a dated note; cite as `<story path> AC-<n>`; full rules: dev-workflow:intake, "Acceptance-criterion IDs"._
- [ ] **AC-1** A commit whose diff changes only `CHANGELOG*` files, the `"version"` line of `package.json` /
  `composer.json`, and lines of `VERSION` or of a version site the project names that differ from the old line
  only in the released version, is classified release-only by a deterministic check; the gate rules let it skip
  Gate B, and the hook records `release-only: version + changelog, no review` for it.
- [ ] **AC-2** A diff that adds anything else to a release (one dependency, one code line, a second version
  number) is not release-only: Gate B and the full battery apply as today.
- [ ] **AC-3** Gate B for docs-only commits is unchanged (D86): the hook's docs-only list and its prompt-path
  exclusion (CLAUDE.md, AGENTS.md, `.claude/`, plugins, skills, commands) behave as before; docs plus one code
  file takes Gate B.
- [ ] **AC-4** A light lane exists for the battery: a change that is docs-only by the kit's fixed list (`*.md`,
  `docs/**`, `*.txt`, images under `docs/`; instruction-bearing paths are never docs) or release-only runs the
  project's light command (format/lint of docs, secrets, guards; no tests) instead of the quality command; a
  project can only narrow which changes take it; without a light command the whole battery runs.
- [ ] **AC-5** A head whose tree equals an already-green head's tree, or differs from it only in record paths,
  gets the `quality` verdict carried over without a battery run, and the carried status names its source
  commit; anything else runs normally.
- [ ] **AC-6** Required check names stay unchanged (`quality`), and no required check gains `paths-ignore`.
- [ ] **AC-7** The kit's workflow docs carry one line: gate effort scales with the change; a 1-line docs or
  release PR costs almost nothing.
- [ ] **AC-8** Tests cover: release-only; version plus one dependency; docs only; docs plus one code file; a
  base-only update.
- [ ] **AC-9** The PR body gives duration and model calls of a release-only and a docs-only PR, before and
  after. (clarified 2026-10-29: "before" is 0.49's path — one full battery, measured on 0.49's heads, plus the
  rule-owed Gate B calls, labelled as such; "after" is measured on fixtures. Orchestrator dev-workflow-kit-26,
  21:47.)
- [ ] **AC-10** Released as 0.50.0 with CHANGELOG, README and docs updated.

## 4. Affected AGENTS.md invariants
- `## Key invariants` › Hook — "1. **The hook always exits 0.** It is advisory"
- `## Key invariants` › Hook — "2. **Loose in the firing direction.** On uncertainty, fire. A missed commit (false ✓) is the dangerous direction"
- `## Key invariants` › Hook — "4. **POSIX `sh`, and `jq` is optional.**"
- `## Key invariants` › Prompts and scaffolding — "8. **`/workflow-init`'s templates stay inline** in the command body."
- `## Key invariants` › Prompts and scaffolding — "11. **Prompt changes pass `docs/prompt-standards.md`**"
- `## Key invariants` › Packaging — "12. **A plugin change requires a version bump.**"
- `### Boundaries (binding)` — "4b. `scripts/local-ci.{sh,test.sh}` (reads; creates and removes one temporary worktree under a `mktemp -d` directory; posts one commit status to GitHub; never fetches, pushes, prunes, changes a ruleset, a workflow's state, a branch or a remote)."
- `## Commands` — "**Check 4i caps the gate rules at 10,000 bytes**"; "**check 4m** for `scripts/local-ci.sh` and `### 2.22`"
- `## Don'ts` — "**Never describe what a gate proves without checking what it actually compares.**"

## 5. Open questions
- None.

## 6. Suggested size
story — one coherent feature (proportional gates); the release-only definition is shared by the Gate B skip and
the light lane, so they ship together.
