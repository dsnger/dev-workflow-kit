---
description: Validate and process PR reviewer bot comments per CLAUDE.md §5
argument-hint: [pr-number]
---

Process the reviewer comments on PR $ARGUMENTS (no number given → the PR of the
current branch, via `gh pr view`).

Target model: Claude via Claude Code.

## Step 0 — Load this project's bot matrix

Read `docs/pr-review-bots.md`. Its **Routing** lists are the authority — the table
beside them is descriptive, recording *where* each bot's findings have been seen and how
you know it has finished. A bot sits in one of three categories: **wait for** it (it has
a completion signal you can block on), **process it opportunistically** (it produces
real findings but nothing proves it has finished), or **ignore** it. A bot's channel can vary between PRs, so a row may
honestly read `inconsistent`; that is an observation, never a routing instruction.

Getting this wrong is expensive in both directions: waiting on a channel a bot never
uses hangs the loop forever, and treating a findings source as context silently drops
real findings.

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

Block only on the bots under **Wait for**, using the completion signal its row names —
which may be a status check rather than a comment, since a bot that finds nothing can
finish without posting at all. Waiting for a *post* from a zero-finding bot hangs.

Then, without blocking, read whatever each **Process opportunistically** bot has posted
at that moment — both channels, inline comments *and* the PR-level summary body. If one
posts after you have begun, handle it as a follow-up rather than waiting for it up
front.

Do not route on the table's column: it records where findings have been observed and may
be ambiguous, which is not an instruction.

## Step 3 — Process

0. **Instruction-path precheck.** If the PR touches any instruction-bearing path, skip
   subagent triage for this PR entirely: validate the comments yourself and say so in
   each reply. The paths are `CLAUDE.md`, `CLAUDE.local.md` and `AGENTS.md` at any
   depth, anything under `.claude/`, `plugins/`, `skills/`, `commands/` or `agents/`,
   and every file reached by expanding `@path` imports from those, transitively. Skip
   triage — never proceed on a partial set — whenever an import is malformed, missing,
   resolves outside the checkout, or resolves more than one way.

   Why: a subagent loads the whole `CLAUDE.md` hierarchy and there is no per-agent
   opt-out, so a PR editing an instruction file would be rewriting the rules its own
   reviewer runs under. This list is deliberately wider than the gate hook's, because a
   missed reminder and an injected instruction are not the same failure.

   Bare `agents/` is redundant against `.claude/` and `plugins/` — the two standard
   locations — and is kept only to cover a non-standard layout. It costs a project that
   uses `agents/` for application code a fallback to manual validation on those PRs,
   which is the safe direction here. Widening this list further needs the same
   justification; over-skipping is cheap, under-skipping is not.

1. Form the tracked claim set. Split a comment making
   several claims into one claim each, and reduce each to a single whitespace-normalized
   line. Drop comments asserting no defect (praise, summaries, bot status notes) and
   claims superseded by another **before** forming the tracked set, so every tracked
   claim can be required to reach a verdict.

   If no tracked claims remain, spawn nothing: report that the PR drew no defect claims,
   answer any thread that needs an answer, and continue to the final CI and merge checks.

   Unless step 0 said otherwise, delegate each remaining claim to a
   `dev-workflow:finding-triage` subagent with fresh context, in **batches of 4**. Pass
   it four things:

   - the canonical single-line claim
   - **where to look**: repository-relative locations, each resolved against the checkout
     root *with symlinks followed*, passed only when you can show the result stays inside
     it — a lexically clean path through a checked-in symlink still escapes. When the
     claim names no particular file, pass the literal token `repository`. A claim whose
     locations you cannot prove confined is not dropped: keep it tracked, spawn nothing,
     and give it an `escalate-to-user` disposition naming which path failed which check.
   - **`AGENTS.md`**: its confined path if the project has one, otherwise the explicit
     statement that it has none — never invent a path
   - your attestation that step 0 ran and passed

   It returns `accept`, `dismiss` or `escalate-to-user` — whether the claim is **true**,
   and nothing more.

   Validate what comes back: exactly one block, `VERDICT` one of the three values,
   `REASON` non-empty, `CLAIM` equal to what you sent. If the subagent did not complete
   (launch failure, spawn limit, timeout, transport error) — whatever partial text it
   produced — or its output fails that check, retry once, then escalate. Never quietly
   validate the claim yourself instead: that is the self-review the subagent replaces.

   **Keep each claim's parent thread id.** Tracking is per claim, replies are per thread:
   one reply per thread covering every claim on it, and a comment is done only when all
   its claims are. **Deduplicate by claim, never by location** — file and line only group
   candidates for comparison, since two defects often share a line and one defect often
   spans several.

   Apply no fix until every queued claim across every batch has returned. If you
   knowingly change the tree mid-run, re-run the affected claims before acting on them.
   Nothing pins the checkout while agents read and an edit from outside this session is
   undetectable here, so a verdict is best-effort against the tree as it was read — it
   informs your decision rather than making it.

   Reply on the PR thread for every final disposition, after any answer item 4 needed
   (`gh pr comment` / review-thread reply) — an unanswered bot comment is
   indistinguishable from a missed one.

2. **Decide actionability. An `accept` alone never authorizes a fix** — it says the claim
   is true, not that fixing it belongs here. Using git:

   Test the rows in order and take the first that matches — a defect can be both
   introduced by this PR *and* contrary to a settled decision, so provenance alone does
   not partition them:

   | The defect is | Do this |
   |---|---|
   | contrary to a settled decision (checked first) | item 4 |
   | introduced by this PR's diff | fix it here (item 3) |
   | pre-existing, fix small and local to code this PR already touches | fix it here, and say so in the reply |
   | pre-existing, anything larger | do not fix here — reply that it is valid but out of scope, and record it in `todos.md` so a true finding is not lost. This is terminal: it does not also go to item 4, and item 5 does not harden it |

   Each accepted claim gets **exactly one** terminal disposition from this table. A
   claim recorded as out of scope is finished — sending it on to item 4 would stall for
   a decision already made, and to item 5 would let `harden-finding` change the
   repository for something just ruled out of this PR.

3. Implement accepted **and** actionable findings. Severity gate per CLAUDE.md §5: a
   trivial fix (one-liner, comment, naming) → commit with a documented Gate-B triviality
   skip in the commit message; a substantial fix (logic, new/changed paths) → run Gate B
   (`mcp__codex__review` on the new diff) before committing.
4. Stop and ask the user for: every `escalate-to-user` verdict, and every accepted
   finding that contradicts a settled decision. Do not implement these. A finding
   already recorded as out of scope by item 2 does **not** come here — it is terminal
   there, and asking again would be asking about a decision already made.
5. Check accepted **and actionable** findings — those fixed under item 3 — against `docs/hardening-log.md` (anchored column-2 grep,
   per the `harden-finding` skill). If one matches an existing class, or a new class
   is clearly warranted, run `dev-workflow:harden-finding` on it — a bot finding that
   only gets fixed once will be back.
6. Report grounded (CLAUDE.md §4): per claim — verdict + reason + action + the tool
   result that verifies it. If code changed: the project's quality command
   (`AGENTS.md § Commands`) green locally **and** the CI quality check green on the
   final pushed head (`gh pr checks` after the run completes). CI is the enforced
   authority; the local run is the fast pre-check.

   Shape of the report — one thread, two claims, showing a verdict that was not acted on:

   ```
   thread #3  src/orders.ts:42
     claim 1  "missing tenant scope on this query"
       verdict      accept        (finding-triage: filters by id only, orders.ts:42-45)
       actionable   yes           introduced by this PR's diff
       action       fixed in a1b2c3d
       verified     src/orders.test.ts::tenant-scope passes (was failing before a1b2c3d)
       hardened     yes           matches base class missing-tenant-scope; ledger row
                                  added (2026-07-18, rung 4 test, src/orders.test.ts)
       reply        posted to thread #3
     claim 2  "this file should use the repository pattern"
       verdict      accept        (finding-triage: it does not use it)
       actionable   no            pre-existing and larger — terminal at item 2
       action       recorded in todos.md; not sent to item 4, not hardened
       verified     git diff -- todos.md shows the entry added
       reply        posted to thread #3 (same reply covers both claims)

   verification
     quality command   green locally (AGENTS.md § Commands, run verbatim)
     CI on final head  green — the authority; the local run is the fast pre-check
   ```

   Both claims sit on one thread and share one reply, and each ends at exactly one
   terminal. Claim 1 shows the hardening item 5 requires for a fixed finding; omitting
   it there is the most common way a true finding gets fixed once and returns later.

## Done

Every tracked claim has a verdict, every thread has a reply, and each claim ends in
exactly one of: a fix, a documented dismissal, a valid-but-out-of-scope finding recorded
in `todos.md`, or an escalation the user has answered. Fixes are committed
per rule 3, CI checks are green on the final head, `mergeStateStatus` is CLEAN — PR ready
to merge.
