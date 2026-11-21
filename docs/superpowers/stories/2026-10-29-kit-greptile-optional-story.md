# Kit 0.48: Greptile optional, no review on unchanged content — Story

**Date:** 2026-10-29 · **Size:** story · **Checkpoints:** none
**Risk:** standard · **Security:** none · **Validation:** battery+check

## 1. Problem statement
Greptile cost over 700 USD in a few days (Daniel, 2026-10-29), because it reviews every push of every pull request,
and a branch update to the base counts as a push. The kit treats a PR bot as a findings source that
`/dev-workflow:process-pr-review` reads on every pass, and its templates give no way to say that a bot is off or
runs only on some PRs. Order: `.context/sparring/20261029-1205-kit-greptile-optional-prompt.md` (part 1: items 1
and 4 of `.context/sparring/20261029-1145-greptile-optional-review-prompt.md`).

## 2. Desired outcome
Greptile is off unless a project turns it on. When on, it reviews only a PR labelled `greptile`, once per PR. The
kit reads a bot's review when it ran and never asks for one; a bot that is off is not reported as missing. A pure
base update with an unchanged PR diff starts no review the kit controls.

## 3. Acceptance criteria
- **AC-1** `process-pr-review` reads, waits for and reports only the bots that are on for this PR: a bot routed
  under Ignore (off) is not reported as `<bot>: no review on <sha>`; a bot limited to a label is off on a PR
  without that label; a bot that is on for the PR and left no review still is reported.
- **AC-2** A bot that reviews once per PR has reviewed when it reviewed any head of the PR; the report names that
  head.
- **AC-3** A head that differs from the head the claims were checked on only by a base update (the same
  `git patch-id --verbatim` of the PR diff) starts no Gate B and no bot request, and an earlier head's review counts
  for it. _Narrowed 2026-10-29 at Gate B pass 1 (cycle gr48optl): `--stable` became `--verbatim`, because the stable
  id strips whitespace and an indentation change read as unchanged; the base name and SHAs are checked before they
  enter the command._
- **AC-4** `/workflow-init` 2.5 asks whether Greptile is wanted, default no, and records the answer in the
  scaffolded `docs/pr-review-bots.md`; when yes, it tells the human what to set in Greptile (label `greptile`,
  review on open only) and writes no Greptile setting itself.
- **AC-5** This repository's `docs/pr-review-bots.md` records Greptile as off.
- **AC-6** No rule, command, template or doc in the kit says to wait for or read Greptile before a merge without
  "if it ran"; `grep -rni greptile` over live surfaces shows each remaining site as history or as the optional path.
- **AC-7** Version 0.48.0; CHANGELOG, README (if affected) and docs updated; quality command green.

## 4. Affected AGENTS.md invariants
11 (prompt changes pass `docs/prompt-standards.md`), 9 (`/workflow-init` asks, never overwrites), 12 (version bump).
Invariant 3 (Gate B content fingerprint) is read, not changed: see the design §3.

## 5. Out of scope
Part 2 (factory-review skill, runnable tests, risk lens, Semgrep) waits for sfx-factory #106/#107. D79: the rule
that agents never index with codebase-memory stays. Greptile billing, app or dashboard settings are Daniel's.

## 6. Changes

**Changed 2026-11-20 — change of direction.** Decided by Daniel, order to session kit-055-greptile (2026-11-20).
Baseline: b144f77. Daniel: "Das Kit ruft es selbst. Das würde ich aber nicht nur bei Bricks Child, sondern eben
global jetzt im Kit noch mal festlegen." and "Also insbesondere pull-request-basiert, aber auch nur bei Dingen, wo es
sich lohnt." The new mode lives in `docs/superpowers/stories/2026-11-20-kit-055-greptile-requested-story.md`.

| Earlier condition | Fate | AC operation |
|---|---|---|
| §2 "The kit reads a bot's review when it ran and never asks for one" | moved → 0.55 story AC-1–AC-5: a bot entry marked `requested by the review loop` is requested once per PR; without the mark, kept | none |
| AC-1, AC-2, AC-3, AC-4 | kept | none |
| AC-5 "This repository's `docs/pr-review-bots.md` records Greptile as off" | dropped — "global jetzt im Kit noch mal festlegen"; replaced by 0.55 story AC-7 | withdrawn |
| AC-6 "No rule … says to wait for or read Greptile before a merge without 'if it ran'" | kept, except the bounded wait of the requested mode (0.55 story AC-4), which blocks nothing | narrowed |
| AC-7 (0.48.0, CHANGELOG, docs) | kept | none |

- **Added without an earlier condition:** none here; the new criteria live in the 0.55 story.
- **Unaccounted:** none.
- **Intervening changes:** 0.49.0 (f3269ce) added the on-request answer (`autoReview: []`, a human `@greptileai` comment) and corrected Greptile's default to `["open"]` (`git log -S greptile 1bbf57e..b144f77 -- plugins/`) → kept; the 0.55 mode builds on that answer.
- **Scope boundary:** in: the kit and this repository's bot file; out: other projects and Greptile's own settings.
- **Open questions:** none.
- **Dependent artifacts:** `docs/superpowers/specs/2026-10-29-kit-greptile-optional-design.md` → open — permitted by the amendment route: a shipped design is history; `docs/superpowers/specs/2026-11-20-kit-055-greptile-requested-design.md` supersedes its §1 sentence "never something it waits for or asks for".
- **Reviews already run:** cycle gr48optl (Gate B, 0.48) → stays valid for 0.48.0; the 0.55 change takes its own gates, per `.claude/review-gates.md` (Gate B reviews every code diff).
