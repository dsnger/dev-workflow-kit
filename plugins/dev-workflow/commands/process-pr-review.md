---
description: Validate and process PR reviewer bot comments per CLAUDE.md §5
argument-hint: [pr-number]
---

Process the reviewer comments on PR $ARGUMENTS (no number given → the PR of the
current branch, via `gh pr view`).

Target model: Claude via Claude Code.

## Step 0 — Load this project's bot matrix

Read `docs/pr-review-bots.md`. It states which bots run on this repo, **which of
them actually post line-by-line findings**, and which only post a summary. This
distinction is the whole point of the file: waiting on a bot that structurally
cannot post line comments hangs the loop forever, and treating a summary as a
findings source silently drops real findings.

If `docs/pr-review-bots.md` is missing: do not guess the matrix. Run
`gh pr view --json comments,reviews` to see which bots have actually posted on this
PR, process only what is visibly there, and tell the user to run
`/dev-workflow:workflow-init` (or write the file by hand) so the next run can wait
on the right bot.

## Step 1 — Check CI first

`gh pr checks`. The required, branch-protected quality check must be green — a red
required check makes the PR unmergeable regardless of review outcomes, and the
failure is itself a finding to process. If it is red, fix the failing step **before**
processing bot comments. If it is still running, note it and proceed — re-verify at
the end.

## Step 2 — Wait for the findings bots

Wait only for the bots `docs/pr-review-bots.md` lists as **posting line-by-line
findings**. Once each of those has posted its review (even with zero comments),
begin. Summary-only bots are context, never a findings source — do not wait for line
comments from them.

## Step 3 — Process

1. Validate each comment against the actual code and `AGENTS.md`. Verdict per
   comment: accept or dismiss. Dismissals get a one-line reason; reply on the PR
   thread either way (`gh pr comment` / review-thread reply) — an unanswered bot
   comment is indistinguishable from a missed one.
2. Implement accepted findings. Severity gate per CLAUDE.md §5: a trivial fix
   (one-liner, comment, naming) → commit with a documented Gate-B triviality skip in
   the commit message; a substantial fix (logic, new/changed paths) → run Gate B
   (`mcp__codex__review` on the new diff) before committing.
3. If a finding implies a scope change or contradicts a settled decision: stop and
   ask the user — do not implement.
4. Check accepted findings against `docs/hardening-log.md` (anchored column-2 grep,
   per the `harden-finding` skill). If one matches an existing class, or a new class
   is clearly warranted, run `dev-workflow:harden-finding` on it — a bot finding that
   only gets fixed once will be back.
5. Report grounded (CLAUDE.md §4): per comment — verdict + reason + action + the tool
   result that verifies it. If code changed: the project's quality command
   (`AGENTS.md § Commands`) green locally **and** the CI quality check green on the
   final pushed head (`gh pr checks` after the run completes). CI is the enforced
   authority; the local run is the fast pre-check.

## Done

Every comment has a verdict and a thread reply, fixes are committed per rule 2, CI
checks are green on the final head, `mergeStateStatus` is CLEAN — PR ready to merge.
