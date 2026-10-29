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

A bot is **on for this PR** unless it is under **Ignore** (a bot that is off sits there, its
row reading `Enabled: no`) or its list entry says `only with label <name>` and the PR does not
carry that label (`gh pr view <n> --json labels`, `<n>` the PR this run processes). A bot that is not on for this PR is not read,
waited for or reported. An entry saying `once per PR` means the bot reviews one head of the PR,
not every push: a review of any head of this PR counts, and the report names that head. Why:
a bot that reviews every push can cost more than the work it reviews, so a project may run it
only where it asked for it.

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
the end. A project whose battery runs locally and reports the check as a commit status
(`AGENTS.md § Commands` names the reporter) shows it in `gh pr checks` too, and then there
is no run to wait for. A target branch that requires no check (`CLAUDE.md` §4 "Waiting on external
work" says how to read that) has no required check to be green: the quality command passing on the final
head (or `scripts/local-ci.sh`'s light or inherited lane on it), recorded in the PR body as that rule says, stands in for it here and in Step 3 item 6, Step 4 and
Done. A required check that nothing will produce stops the run as that rule says.

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

**No review is not no comments.** Before you conclude that a bot on for this PR found
nothing, check that it actually reviewed the current head (`once per PR`: any head of this
PR): a review record whose `commit_id` is that SHA (`gh api --paginate
repos/<owner>/<repo>/pulls/<n>/reviews`), or the proof its row in `docs/pr-review-bots.md`
names. A green status check alone is no proof: some bots pass it without reviewing. A review
of an earlier head counts for the current one when only the base moved between them: run
Step 4's check (its value checks and patch-id command) with the reviewed head in place of the
checked one; anything but equal ids means it does not count. A bot on for this PR that did not run is reported by name —
`<bot>: no review on <sha>` — and never counted as clean. Why: a bot that is rate-limited or
skipping the PR posts nothing, which looks exactly like a clean review.

**No bot ran.** After the **Wait for** bots have given their completion signals, when no bot is on for
this PR, or none on for it reviewed, write one line, `PR bots: none ran on <sha>`, beside any
`<bot>: no review on <sha>` lines, and wait for nothing more. This is a normal state, not a fault:
Gate B was the review. Step 3 item 1's route for an empty claim set still runs (answer any thread that
needs it, item 6), then Step 4.

Read what each bot posted if it ran; the only review this command starts is Gate B for a
fix (Step 3 item 3). Why: every bot request is a paid run, and Gate B is the workflow's
review.

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
   name each bot on for this PR that did not review the head (Step 2), answer any thread that needs an
   answer, and continue to the final check and merge steps (item 6, Step 4).

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

3. Implement accepted **and** actionable findings. Severity gate per CLAUDE.md §5. **Every
   substantial fix (logic, new or changed paths) runs Gate B** (`mcp__codex__review` on the
   new diff) before committing — no profile makes a substantial fix skippable. A skip needs
   **both** conditions, never either alone:
   - the **fix is trivial** — judged by **behavioural effect, not line count**: a comment,
     a doc typo, a rename nothing resolves against. A one-line change that alters
     behaviour is not trivial, and in a prompt product the text *is* behaviour; **and**
   - **every cited story is eligible.** Resolve the cited story path(s) first, looking in
     **both** the PR body and the **commit bodies in the range** — the workflow puts the
     story path in the closing commit message, so a PR that cites nothing in its
     description may still be profiled. **This reads a record, and is not §5's
     governing-set derivation**, which takes the cited set from a reviewed artifact's own
     `Story:` header and forbids grepping an artifact body for story paths. A closing
     commit body carries the path deliberately, as an evidence entry; an artifact body
     mentioning one may be a disclaimer. Different question, different source — and this one
     never relaxes the other: where no record carries a citation, that is an absence **in the
     PR record**, and it takes the unprofiled judgement call for *this command's* skip
     decision only. It is not §5's "no story cited" case, it cannot set a floor, and it can
     neither override nor substitute for a governing set derived from a reviewed artifact's
     `Story:` header. Where neither carries a citation, take the unprofiled judgement call
     for this decision — without calling it §5's "no story cited" case, which is about a
     reviewed artifact's header and not about this record. A profiled story is
     eligible only at effective level 0 (risk `trivial` *and* security `none`); an
     unprofiled story is eligible on the old judgement call. With several cited stories, each must be
     eligible on its own; one eligible story does not carry the rest. A cited profile that
     is **present but unresolvable** (§5's fourth case) stops the run — surface the cause;
     it is never treated as unprofiled.

   A skip removes the review and never the evidence. Every skipped cycle runs the battery
   and records, in the commit body, **the skip reason and the battery result** — and, like
   every other cycle, **its provenance line and, in place of a curve, its skip record**. On
   top of that: one mode-derived evidence entry per cited **profiled** story, and none for an
   unprofiled one — which owes the reason, the battery result, the provenance line and the
   skip record, and nothing further.
4. Stop and ask the user for: every `escalate-to-user` verdict, and every accepted
   finding that contradicts a settled decision. Do not implement these. A finding
   already recorded as out of scope by item 2 does **not** come here — it is terminal
   there, and asking again would be asking about a decision already made.
5. Check accepted **and actionable** findings — those fixed under item 3 — against `docs/hardening-log.md` (anchored column-2 grep,
   per the `harden-finding` skill). If one matches an existing class, or a new class
   is clearly warranted, run `dev-workflow:harden-finding` on it — a bot finding that
   only gets fixed once will be back. **One exception, for findings a review gate already
   checked:** a bot finding that reports the same occurrence as a `hardening owed` line
   written by a gate cycle inside this pull request's own range (merge-base to head) is not
   checked again and is not counted as a new occurrence — that line already carries it as an
   open obligation (`.claude/review-gates.md`, Closing act, the ledger check). Same occurrence
   means the same defect at the same place, still unrepaired or repaired by that cycle; your
   report names the owed line it matched. A defect reintroduced after that repair, or any
   doubt about the match, takes the ordinary route above. Only owed lines are matched: a bot
   finding that duplicates a gate finding which owed nothing is checked here as usual, which
   costs one repeated check and nothing more, since no ledger row exists for it to miscount.
6. Report grounded (CLAUDE.md §4): per claim — verdict + reason + action + the tool
   result that verifies it. If code changed: the project's quality command
   (`AGENTS.md § Commands`) green locally **and** the required quality check green on the
   final pushed head (`gh pr checks`): from CI once its run completes, within CLAUDE.md §4's limit for
   waiting on external work, or from the local reporter the project's `AGENTS.md § Commands` names, which
   posts the local run's result as that check. The required check is the enforced
   authority; a local run that is not reported is the fast pre-check. A status the local reporter
   posts from its light or inherited lane (`scripts/local-ci.sh`'s header defines both) stands for the
   quality command on that head: it ran what its lane owes, or carried a verdict from a green head with
   the same tree or with only record paths changed. With no required check (Step 1), the
   full quality command on the final head, or a light or inherited lane result of `scripts/local-ci.sh` on
   it, recorded in the PR body, is the evidence, and neither exception
   below applies, since both lean on a required check for the rest. Two exceptions. A local timeout in a test
   the diff did not touch that passes alone takes the load-flake rule in `.claude/review-gates.md`
   (Gate-B prompt): record it, and the green required check on the head stands in (with a local reporter, a rerun through it). And when the
   quality command passed in full on a commit you can name (its SHA, from that run's output or
   record), that commit is an ancestor of the final head, and every path changed between them is
   docs-only as `.claude/review-gates.md` defines it: rerun only the stages of the quality
   command that read those paths, and name the stages and that SHA in the report; the green required
   check on the final head stands for the rest. Why: rerunning a long battery for a few lines of
   prose spends the time on stages that never read them. No named commit, one that is not an
   ancestor (a rebase), or a stage whose inputs you cannot tell: run the full command.

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
     quality command   green locally (AGENTS.md § Commands, run verbatim;
                       or the local-ci lane line, e.g. "inherited green from <sha12>: records only")
     required check on final head  green — the authority (CI, or the local reporter's status)
                                   (none required: "quality command green on <sha>, run id: none, <reason>,
                                   exit 0, <duration>", as recorded in the PR body)
   ```

   Both claims sit on one thread and share one reply, and each ends at exactly one
   terminal. Claim 1 shows the hardening item 5 requires for a fixed finding; omitting
   it there is the most common way a true finding gets fixed once and returns later.

## Step 4 — Merge

Squash-merge once all of these hold: a last read of both channels of every bot on for this PR (Step 2),
filtered as Step 3 item 1 forms the tracked set, adds no claim — a new one goes through
Step 3 first; every tracked
claim has a verdict, a terminal disposition and a reply; no item-4 question is unanswered;
the required check is green on the head (none required: Step 1's record on it); and `gh pr view <n> --json mergeStateStatus,headRefOid` reads `CLEAN`, with a
`headRefOid` equal to the head this run checked and claims on. With no required check, `UNSTABLE` counts as
`CLEAN` when Step 1's record is green on that head: it means only that a check nobody requires is not
passing; name each such check and its state in the report. A different head means
commits arrived meanwhile: run Steps 1-3 again on it first. **A base update alone starts no
review.** Take `baseRefName` from `gh pr view <n> --json baseRefName`; before filling it or a
`<sha>` into the command below, check that the name matches `^[A-Za-z0-9._/-]+$` and each
`<sha>` matches `^[0-9a-f]{40}$`, because a branch name may legally hold shell syntax. When a
value fails, run nothing and treat the diff as changed. After `git fetch origin`, compute for
the checked head and the new one
`git diff "$(git merge-base "origin/<baseRefName>" <sha>)" <sha> | git patch-id --verbatim`.
Equal, non-empty first fields mean the PR diff is unchanged: the base update itself needs no
Gate B, every review of the checked head counts for the new one, and Step 1 and the last read
still run; a fix that a claim from them needs still follows Step 3 item 3. An empty output, a
failed command or different ids: the diff changed, as before. `--verbatim`, not `--stable`:
the stable id strips whitespace, so a changed indentation would read as unchanged. Why: a
branch update that only brings the base in changes no line anyone reviewed. Merge that head and no other,
with a squash body you write:
`gh pr merge <n> --squash --match-head-commit <headRefOid> --body-file .context/squash-body-<n>.md`.
Write the body from the pull request's own commits, as GitHub lists them, so no local ref or
merge base can add or drop one (`<n>` is the PR number, digits only):
`gh api --paginate 'repos/{owner}/{repo}/pulls/<n>/commits?per_page=100' --jq '.[] | .commit.message + "\n"'`.
Remove every line matching
`^co-authored-by:[[:space:]]*claude[^<]*<noreply@anthropic\.com>[[:space:]]*$` (any case), the
trailer Claude Code adds by default, and keep every other line. Run these as separate steps. Merge only
when `gh` succeeded, the body is non-empty, and the number of commits listed
(the same call with `--jq '.[].sha'`, one per line) equals
`gh api 'repos/{owner}/{repo}/pulls/<n>' --jq .commits` exactly; otherwise leave the PR unmerged
and report which of the three checks failed. GitHub lists at most 250 commits of a pull request,
and a cut list would drop the later commits' lines without an error. Why: GitHub's default squash body
joins the commit messages, so that trailer reaches the main branch from any commit carrying it,
while a human co-author's trailer, a project's own attribution and the cycle record lines the
reports read from the main branch's commit bodies must survive.
If it fails because the head moved, run Steps 1-3 on the new head before another attempt.
After three such rounds without a merge, end with the PR unmerged and say why in the report
and the handover, so late claims or pushes cannot keep the run cycling.
A bot recorded as `<bot>: no review on <sha>` (Step 2) does not block the merge and is not
counted as clean; the report keeps that line.

Do not merge, and end with the PR ready, when a cited story's `**Checkpoints:**` line
includes `merge` — the stories resolved as in Step 3 item 3, from the PR body and the
commit bodies in the range; a story without the line, or no cited story, sets none. Why:
a closed gate and green checks are the approval by default, and a human stop is opt-in
per story. After the merge, confirm it with `gh pr view <n> --json state,mergeCommit`
and write the unit's handover.

## Done

Every tracked claim has a verdict, every thread has a reply, and each claim ends in
exactly one of: a fix, a documented dismissal, a valid-but-out-of-scope finding recorded
in `todos.md`, or an escalation the user has answered. Fixes are committed
per rule 3, the required check is green on the final head (none required: the quality command's record on
it, or a local-ci lane's), `mergeStateStatus` is CLEAN (or UNSTABLE as Step 4 allows), and the PR
is squash-merged — or, under a `merge` checkpoint, ready to merge.
