---
description: Validate and process PR reviewer comments (Greptile/CodeRabbit) per CLAUDE.md §5
argument-hint: [pr-number]
---

Process the reviewer comments on PR $ARGUMENTS (no number given → the PR of
the current branch, via `gh pr view`).

**Check CI first:** `gh pr checks` — the `quality` check is a required,
branch-protected check. If it is red, investigate and fix the failing step
BEFORE processing bot comments (a red required check makes the PR
unmergeable regardless of review outcomes; the failure itself is a finding
to process). If it is still running, note it and proceed — re-verify at the
end.

**Which bot produces findings (repo-specific):** **Greptile** is the only bot
that posts line-by-line review comments — wait for its review before starting.
**CodeRabbit is on the Free plan for this repo: it only ever posts a
high-level summary/walkthrough, never line-by-line findings.** Treat that
summary as context only, never as a findings source, and do NOT wait for
CodeRabbit line comments — they structurally cannot arrive. (Cursor Bugbot is
disabled.) So "reviews still pending" means *Greptile hasn't posted yet* — wait
and re-check for Greptile only; once Greptile's review is in (even with zero
comments), begin. If someone upgrades CodeRabbit to Pro or enables Bugbot later,
revisit this assumption.

1. Validate each comment against the actual code and AGENTS.md. Verdict per
   comment: accept or dismiss. Dismissals get a one-line reason; reply on the
   PR thread either way (`gh pr comment` / review-thread reply).
2. Implement accepted findings. Severity gate per CLAUDE.md §5: trivial fix
   (one-liner, comment, naming) → commit with a documented Gate-B triviality
   skip in the commit message; substantial fix (logic, new/changed paths) →
   run Gate B (`mcp__codex__review` on the new diff) before committing.
3. If a finding implies a scope change or contradicts a settled decision:
   stop and ask me — do not implement.
4. Check accepted findings against docs/hardening-log.md (anchored column-2
   grep). If one matches an existing class, or a new class is clearly
   warranted, run the harden-finding skill on it.
5. Report grounded (CLAUDE.md §4): per comment verdict + reason + action +
   the tool result that verifies it. If code changed: `pnpm quality` green
   locally AND the CI `quality` check green on the final pushed head
   (`gh pr checks` after the run completes) — CI is the enforced authority,
   the local run is the fast pre-check.

Done = every comment has a verdict and a thread reply, fixes are committed
per rule 2, CI checks green on the final head, mergeStateStatus CLEAN —
PR ready to merge.
