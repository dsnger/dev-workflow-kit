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
