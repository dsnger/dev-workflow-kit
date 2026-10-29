# Kit 0.49: learnings from the 0.48 project refresh — Story

**Date:** 2026-10-29 · **Size:** story · **Checkpoints:** none
**Risk:** standard · **Security:** standard · **Validation:** battery+check

## 1. Problem statement
Refreshing six projects to kit 0.48 (D82) showed six gaps (Daniel, D83, 2026-10-29 18:00; order
`.context/sparring/20261029-1800-kit-049-learnings-prompt.md`, list `.context/sparring/kit-049-candidates.md`
items 1–5 and 7):
1. Nothing tells a session that a project's scaffolded files are older than the installed plugin.
2. With the GitHub Actions budget used up, the api-builder session stopped on the "waiting on external work" rule
   although its target branch required no check: a CI run that never starts reads as a failed check.
3. Only this repository has the local path (`scripts/local-ci.sh`); a project whose branch requires a
   `quality` check has no way to post it without Actions.
4. The kit's Greptile text calls per-push review Greptile's default (its `greptile.json` reference gives
   `autoReview` the default `["open"]`) and does not describe the on-request path (`autoReview: []`, a review only
   on an `@greptileai` comment), which is the one Daniel chose for his projects.
5. `/workflow-init` 2.1 classifies a `CLAUDE.md` §5 pointer written by kit 0.26–0.43 (it has "Before you
   conclude", lacks the Codex-probe paragraph added in 0.44.0) as **mixed** and stops, though replacing it with the
   template pointer is exactly the fix (infinite-portfolio-canvas `docs/handovers/kit-048-init.md`, Deviations).
6. CodeRabbit is removed (Daniel, 2026-10-29 17:44) and Greptile runs on request only, so a PR with no bot review is
   now normal; `process-pr-review` and this repository's `docs/pr-review-bots.md` still treat CodeRabbit as active.

## 2. Desired outcome
A stale project copy is named to the session; a missing CI run on a branch that requires no check is no stop, and
a required check without a runner is reported, not waited on; projects can take the local path; the Greptile text
is true; the 0.26–0.43 pointer is refreshed instead of stopping the run; and a PR with no bot review ends the bot
step quickly. The two open 0.48 rows in `todos.md` that this touches are closed.

## 3. Acceptance criteria
_IDs are permanent once the story is committed: never renumber or reuse one; a new criterion takes the next number unused here and on the branch it merges into, and a collision stops for a human; a removed one stays, struck through and dated; a narrowed one keeps its ID with a dated note; cite as `<story path> AC-<n>`; full rules: dev-workflow:intake, "Acceptance-criterion IDs"._
- [ ] **AC-1** `/workflow-init` records in the project the kit version it ran as; when that record is missing or
  differs from the installed plugin's version in an adopted project, a session is told at its start, and in a
  project that is not adopted nothing is said. The hook still always exits 0.
- [ ] **AC-2** A version bump that leaves the version `/workflow-init` records different from the plugin manifest's
  fails the quality command.
- [ ] **AC-3** The "waiting on external work" rule (this repository's `CLAUDE.md` and the scaffolded template) and
  `process-pr-review` say: when the target branch requires no status check (its branch protection and the rulesets
  that apply to it), the quality command on the final head is the green, recorded in the PR body with the run id
  absent, the reason, the SHA, the exit status and the duration; when it requires one that nothing will produce,
  stop and report instead of waiting.
- [ ] **AC-4** `/workflow-init` offers `scripts/local-ci.sh` to a project as an inline template, the shipped text
  is byte-identical to this repository's `scripts/local-ci.sh`, and the quality command fails when the two differ;
  the script works in a project without this repository's `ci.yml` shellcheck pin.
- [ ] **AC-5** The docs say how a project switches to the local path and that changing the ruleset or branch
  protection is the human's.
- [ ] **AC-6** The kit's Greptile text describes the on-request path (`autoReview: []`, review on an `@greptileai`
  comment) beside the label path, and no live surface calls per-push review Greptile's default.
- [ ] **AC-7** `/workflow-init` 2.1 classifies a §5 body equal to the template pointer with the Codex-probe
  paragraph, the "Before you conclude" paragraph, or both missing as pointer form and offers the replacement; it
  does not stop on it.
- [ ] **AC-8** `process-pr-review` with no bot on for the PR, or none that reviewed, says so in one line and goes
  on to the merge step; this repository's `docs/pr-review-bots.md` lists CodeRabbit under Ignore.
- [ ] **AC-9** The `todos.md` rows "'Greptile reviews every push' is stated as its default" and
  "`docs/pr-review-bots.md`: two passages still give the CodeRabbit count for any bot" are closed.
- [ ] **AC-10** Version 0.49.0; CHANGELOG, README and docs updated; the quality command green.
- [ ] **AC-11** ~~The gate rules let a release-only commit skip Gate B: one whose every change is a version value at a site the project's `AGENTS.md` lists as a version site, or inside the `CHANGELOG.md` entry for that version; a commit with any other change keeps Gate B, and a project that lists no version sites has no release-only skip. The hook may still remind (invariant 2).~~ — withdrawn 2026-10-29: moved to the 0.50 proportional-gates story (split check)

**Changed 2026-10-29 — changed requirement.** Decided by Daniel, D85 (18:11), relayed by the orchestrator
`dev-workflow-kit-26` and added as item 7 to `.context/sparring/20261029-1800-kit-049-learnings-prompt.md`.
Baseline: `42a56b8`. A field case (sfx-bricks-api-builder release 1.14.0, PR #105) ran a Gate B pass on a commit
that only bumped versions.

| Earlier condition | Fate | AC operation |
|---|---|---|
| AC-1 … AC-10 | kept | none |

- **Added without an earlier condition:** AC-11: "a release-only commit skips Gate B like docs-only" → per the
  decision: "A commit whose diff changes only version fields and the CHANGELOG entry for that version skips Gate B,
  like a docs-only commit; any other change in it keeps Gate B."
- **Unaccounted:** none.
- **Intervening changes:** none.
- **Scope boundary:** in: the gate rules (both copies), version sites in `AGENTS.md` (this repository) and the
  `/workflow-init` AGENTS.md walk, the docs that describe docs-only; out: the hook's docs-only matcher.
- **Open questions:** none.
- **Dependent artifacts:** `docs/superpowers/specs/2026-10-29-kit-049-learnings-design.md` → updated in this change.
- **Reviews already run:** Gate A cycle k049lrn1 (spec) → closed before this change; the added section is reviewed
  at Gate B with the diff, per `.claude/review-gates.md` ("A spec is approved when its Gate A closes …; then it
  changes only by `intake`'s amendment route"), which names no rerun of Gate A.

## 4. Affected AGENTS.md invariants
- `## Key invariants` / Hook — "1. **The hook always exits 0.**"; "4. **POSIX `sh`, and `jq` is optional.**"
- `## Key invariants` / Prompts and scaffolding — "8. **`/workflow-init`'s templates stay inline** in the command
  body."; "9. **`/workflow-init` never overwrites silently.**"; "11. **Prompt changes pass
  `docs/prompt-standards.md`**"
- `## Key invariants` / Packaging — "12. **A plugin change requires a version bump.**"; "6. **The manifest never
  re-declares convention-loaded components.**" (a hooks.json change is convention-loaded)
- `### Boundaries (binding)` — "4b. `scripts/local-ci.{sh,test.sh}` (reads; creates and removes one temporary
  worktree …; posts one commit status to GitHub …)"; "5. the hook ships in the plugin, the checkers and the reports
  do not (the docs link checker's text ships only as `/workflow-init`'s `### 2.21` template …)"; "7. Nothing may
  depend on this repo's internal layout"

## 5. Open questions
- None. (Item 6 of the candidates list, Ponytail skipped once, is an observation only; part 2 of the Greptile
  order stays waiting on sfx-factory #106/#107.)

## 6. Suggested size
story — six small learnings from one refresh, one spec → plan → PR, ordered by D83 as one 0.49.

**Changed 2026-10-29 — change of direction.** Decided by this session's splitting check, which the orchestrator
`dev-workflow-kit-26` delegated with item 8 ("If this makes 0.49 too large by the splitting check, split it into its
own PR after 0.49", brief item 8, Daniel 18:17). Baseline: `bc18fda`. Item 8 redefines item 7's release-only check
as a deterministic one, so both move together.

| Earlier condition | Fate | AC operation |
|---|---|---|
| AC-1 … AC-10 | kept | none |
| AC-11 | moved → the 0.50 proportional-gates story | withdrawn |

- **Added without an earlier condition:** none.
- **Unaccounted:** none.
- **Intervening changes:** none.
- **Scope boundary:** in: AC-1 … AC-10; out: release-only and proportional gates (0.50).
- **Open questions:** D86 (docs-only and Gate B) → the 0.50 story.
- **Dependent artifacts:** the spec → updated in this change; the plan → updated in this change.
- **Reviews already run:** none on AC-11.
