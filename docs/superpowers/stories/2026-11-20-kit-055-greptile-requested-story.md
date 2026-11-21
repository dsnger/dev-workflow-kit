# Kit 0.55: the review loop asks Greptile once per PR, where it pays — Story

**Date:** 2026-11-20 · **Size:** story · **Checkpoints:** none
**Risk:** standard · **Security:** standard · **Validation:** battery+check

## 1. Problem statement
Since kit 0.48 `/dev-workflow:process-pr-review` asks no bot for a review, and Greptile runs only when a human
comments `@greptileai` or labels a PR. Nobody does, so Greptile, which "hat eigentlich bei dem DevWorkflow-Kit immer
gut gewirkt", reviews nothing. Daniel, 2026-11-20: "Das Kit ruft es selbst. Das würde ich aber nicht nur bei Bricks
Child, sondern eben global jetzt im Kit noch mal festlegen." Before that: "Ich möchte aber auch nicht, dass es auf
jeden Pull Request automatisch antwortet, sondern dass wir das aus dem Projekt heraus steuern oder aus dem
Repository-Prozess." Addendum: "Also insbesondere pull-request-basiert, aber auch nur bei Dingen, wo es sich lohnt."

## 2. Desired outcome
A project can say in `docs/pr-review-bots.md` that the review loop requests Greptile. Then
`process-pr-review` requests exactly one Greptile review per PR, only when the project's rule says the PR is worth
it, waits for it within a limit and processes its findings as any bot's. A push after the request requests nothing
more. Every PR records in its body whether Greptile was requested and why not, if not.

## 3. Acceptance criteria
- **AC-1** A Greptile entry marked `requested by the review loop` makes `process-pr-review` request one review on
  the PR, after Step 1 reads the quality check green on the head and the PR's Gate B cycle is closed; without that
  mark it requests nothing, as in 0.48.
- **AC-2** Before requesting, it checks the PR for an earlier request or a Greptile review (a comment carrying the
  request, or any `greptile-apps[bot]` comment); finding one, it requests nothing. The check reads only the PR, so a
  restarted session finds the same answer.
- **AC-3** The request happens only when the bot file's **Request when** rule matches the PR. The kit default
  excludes docs-only and release-only PRs, kit-refresh PRs (head branch `chore/kit-*`) and small changes; with no rule
  in the file, nothing is requested. No match: no request, and the PR body says why in one line.
- **AC-4** After a request it waits at most 15 minutes, counted from the request comment's time on GitHub, for a
  Greptile comment created or edited after it; then it processes the findings as Step 3 does. No review in the limit:
  it records that in the report and the PR body and goes on; nothing blocks.
- **AC-5** A push after the request starts no second request, and Greptile's review of an earlier head counts for
  the PR (`once per PR`).
- **AC-6** `/workflow-init` 2.5 offers the new answer, recommended when Greptile is installed on the repository;
  default `no` otherwise. The user sets only `autoReview: []` in Greptile; the kit writes no Greptile setting.
- **AC-7** This repository's `docs/pr-review-bots.md` turns Greptile on in this mode.
- **AC-8** Version 0.55.0 in the manifest, `### 2.23` and `.claude/dev-workflow-version`; CHANGELOG, README,
  `docs/setup.md`, `docs/reference.md`, `docs/getting-started.md` updated; quality command green.

## 4. Affected AGENTS.md invariants
11 (prompt changes pass `docs/prompt-standards.md`), 9 (`/workflow-init` asks, never overwrites), 12 (version bump),
5 (nothing new executes; Greptile is a hosted app, not a pinned tool). Shell values spliced into commands (Don'ts:
bounding spliced data) apply to the PR number and head branch.

## 5. Out of scope
Other projects (Bricks Child included) and their refresh; Greptile's dashboard, billing and `autoReview` setting
(Daniel's); CodeRabbit; the label path and the human `@greptileai` path, which stay as they are.

## 6. Amends
`docs/superpowers/stories/2026-10-29-kit-greptile-optional-story.md` §2 ("never asks for one"), by its change record.
