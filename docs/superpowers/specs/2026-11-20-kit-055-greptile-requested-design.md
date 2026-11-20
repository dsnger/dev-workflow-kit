# Kit 0.55: the review loop asks Greptile once per PR, where it pays — Design

**Story:** `docs/superpowers/stories/2026-11-20-kit-055-greptile-requested-story.md` (risk standard, security
standard, battery+check, checkpoints none). **Date:** 2026-11-20. **Plugin version:** 0.55.0.
**Gate A:** runs — risk standard; security standard; evidence battery+check (`strict`: security not `none`; the
loop posts to GitHub and starts a paid run of an external service).

## 1. Intent
A project can let `/dev-workflow:process-pr-review` request one Greptile review per PR, only where the project's own
rule says it pays, wait for it within a limit, and process what it finds. Everything else about bots stays as 0.48
left it. This supersedes the 0.48 design's §1 sentence "never something it waits for or asks for" for an entry with
the new mark (change record: the 0.48 story § 6).

## 2. Shared contract: `docs/pr-review-bots.md`
- **New qualifier** on a **Process opportunistically** entry: `requested by the review loop`, always together with
  `once per PR`. Only Greptile uses it in this version; the request text is Greptile's.
- **New paragraph `**Request when**`** in the bot file: the rule that decides whether a PR is worth a request. The
  kit writes its default there (§3); a project edits it. No such paragraph: nothing is requested, and the record line
  says `Greptile: not requested — no Request when rule in docs/pr-review-bots.md`.
- **Prerequisite, stated in the row:** Greptile keeps its default output, a PR summary comment
  (`statusCommentsEnabled` and `shouldUpdateDescription` left unset), and `"autoReview": []`; both are the user's
  settings. Other output settings are outside this mode: the loop reads only the summary comment, review records and
  inline comments.

## 3. The kit default `Request when` rule
All values first: the PR number `<n>` matches `^[0-9]+$` before any command uses it (else nothing runs and
the report names the bad argument); `baseRefName` and `headRefName` (`gh pr view <n> --json
baseRefName,headRefName,headRefOid,isDraft,body`) match `^[A-Za-z0-9._/-]+$` and the head `^[0-9a-f]{40}$`; a
failure requests nothing (`Greptile: not requested — unsafe ref name`). After `git fetch origin`, the range is
`<mb>..<head>`, `<mb>` = `git merge-base "origin/<baseRefName>" <head>`; a failed merge-base requests nothing
(`Greptile: not requested — range unknown`).
Request only when all four hold; the first that fails is the one-line reason:
1. **Not a kit refresh:** the head branch does not start with `chore/kit-`.
2. **Not docs-only:** some path in `git diff --name-only <mb> <head>` is not docs-only as `.claude/review-gates.md`
   defines it.
3. **Not release-only:** some such path is also not a `CHANGELOG.md` and not a version record whose diff over the
   range (`git diff <mb> <head> -- <path>`) changes only lines holding the version. Version records: the files on
   the project's `AGENTS.md` `**Version sites:**` line, a plugin manifest, `.claude/dev-workflow-version`, `VERSION`.
   Decided over the whole range, not by the hook's per-commit `release-only:` note, so a feature PR with a separate
   bump commit still counts. Anything the reader cannot tell: counts as not release-only (a request).
4. **Not a small change:** the PR is not a small change as `.claude/review-gates.md` defines it, measured over
   `<mb>..<head>` with `git diff --numstat` and the cited story's profile. A cited story at risk `high` or security
   above `none`, or any prompt path, is never small.
Why this rule: it reuses definitions every initialized project already has, so it is checkable from the PR alone and
needs no CI configuration; this repository's prompts are never "small", which matches Daniel's observation that
Greptile paid off here; small PHP fixes in Bricks Child are not reviewed.

## 4. `process-pr-review` changes
Step 2 gets a new paragraph **Request a review once per PR** for an entry marked `requested by the review loop`:
1. **When.** The PR is not a draft (`isDraft` false; a draft: `Greptile: not requested yet — draft`, and the next
   run asks again, since nothing was spent); Step 1 read the required check green on the head (none required: Step
   1's record; still running: decide once Step 1's re-verification reads it green); the head commit's subject does
   and Gate B is closed on the head: take `C`, the last commit in the range whose body carries a Gate B cycle line
   (`cycle <nonce>; Gate B (passes`); it is closed when either every commit after `C` is a non-merge commit and
   `git diff --name-only C <head>` lists only docs-only paths (none: `C` is the head), or Step 4's patch-id check
   finds the PR diff unchanged between `C` and the head (a base update). No `C`, or neither holds: `Greptile: not
   requested yet — Gate B not closed on <sha12>`; a later run asks again. Order: the **Request when** rule (3) runs
   first, so a docs- or release-only PR, which has no cycle line, is excluded with its own reason.
2. **Already requested or reviewed?** Read, each with `gh api --paginate` and a zero exit, the issue comments
   (`repos/<owner>/<repo>/issues/<n>/comments`), the review records (`pulls/<n>/reviews`) and inline comments
   (`pulls/<n>/comments`). A read that fails: request nothing (`Greptile: not requested — PR comments unreadable`).
   - An issue comment whose body, trimmed, starts with `@greptileai` or `@greptile` (a request, by anyone): requested;
     its `created_at` is the request time; go to 5 (it may still be inside the limit).
   - No request, but a review artifact (5): reviewed without a request; go to 5's "arrived" branch, no wait.
   - No request and no review artifact, but any `greptile-apps[bot]` issue comment, review record or inline comment
     (an earlier automatic attempt, an error, an answer): request nothing and wait for nothing; read what is there
     (`Greptile: earlier Greptile activity, no review artifact`).
   - Neither: go to 3.
   This reads only GitHub, so a restarted session or a later push gets the same answer (AC-2, AC-5).
3. **Worth it?** Apply the bot file's **Request when** rule (§2, §3). No match: request nothing.
4. **Request,** once in this run: `gh api repos/<owner>/<repo>/issues/<n>/comments -f body='@greptileai' --jq
   .created_at` — the bare tag, because Greptile answers extra text as a question. Its printed `created_at` is the
   request time. A failed or unclear result is never retried: read the issue comments once more; a request comment
   from this run's `gh` user found there is the request, none found records `Greptile: request undetermined` and
   ends this paragraph.
5. **Wait.** Up to 15 minutes from the request time, read the issue comments every 2 minutes. The review has
   arrived when a `greptile-apps[bot]` issue comment is a **review artifact**: its body holds `Last reviewed commit`
   (the summary footer), and its `created_at` or `updated_at` is at or after the request time (Greptile edits its
   summary in place). Then read the summary, review records and inline comments and go on to Step 3. Another
   Greptile reply (an answer, an error) is no review. Past the limit: record and go on; nothing blocks. A restarted
   session counts from the same request time, so the limit never restarts. This wait is the one exception to "never
   block" for this mark, and it is not CLAUDE.md §4's waiting on external work: no check depends on it and its limit
   and outcome are these.
6. **Record.** One line, both in the run's report and in the PR body: `Greptile: requested on <sha12> at <time>;
   reviewed <sha12 from the footer's commit link>` · `Greptile: requested on <sha12> at <time>; no review within 15
   min` · `Greptile: reviewed <sha12> without a request` · `Greptile: request undetermined` · `Greptile: not
   requested[ yet] — <reason>`. The body keeps one such line between `<!-- greptile-request -->` and
   `<!-- /greptile-request -->`: read the body, replace or append that block only, re-read the body just before
   `gh pr edit <n> --body-file`, and when it changed since the first read, redo the edit once on the new body; a
   second change or a failed edit posts the line as a PR comment instead. `gh pr edit` has no conditional write, so
   an edit landing between that last read and the write is still lost; the window is one command long, and this is
   accepted (D9).
A Greptile entry with the mark that was not requested and has no review artifact is not on for this PR: no
`no review on <sha>` line. The 0.48 sentence "the only review this command starts is Gate B for a fix" gains "and the
one request this paragraph allows".
**Concurrency scope.** The duplicate check guards against restarts, pushes and later runs, which is how the
workflow runs a PR: one session at a time. Two sessions processing the same PR at once can both post; after its
request the run reads the issue comments again, and an earlier request from someone else records `Greptile:
duplicate request` (the run is spent; nothing undoes it). No lock is added: none exists on GitHub that both
sessions could take, and the workflow does not run two loops on one PR.

## 5. `/workflow-init` 2.5
Ask whether Greptile is installed on the repository. Four answers: **No** (default when it is not installed),
**On request, by the review loop** (recommended when it is installed): Greptile under Process opportunistically as
`once per PR, requested by the review loop`, plus the default **Request when** paragraph; the user sets only
`"autoReview": []` in Greptile. **On request** (a human comments) and **Label** stay as they are. The template gains
the qualifier, the paragraph and the row's wording. The kit writes no Greptile setting.

## 6. This repository
`docs/pr-review-bots.md`: Greptile `Enabled: yes (requested by the review loop since 0.55.0)`, moved from Ignore to
Process opportunistically, the default **Request when** paragraph. No Greptile review was observed on #102–#110
(checked on #105 and #107–#110: zero `greptile-apps[bot]` comments), so its automatic reviews read as off; whether
the app is still installed is unknown and the first request will show it (no review in 15 min is recorded, not a
stop).

## 7. Decisions
- D1: trigger by comment `@greptileai` through `gh api` (it returns `created_at`), not the Greptile MCP
  `trigger_code_review`: the comment needs only `gh`, which the loop already uses, and it leaves the record that makes
  the duplicate check work after a restart. The MCP needed a fresh sign-in in this very session.
- D2: the duplicate check counts any `@greptileai` comment and any Greptile comment, by anyone: a human's request
  already cost a run.
- D3: the rule lives in each project's bot file (Daniel's addendum); the kit default reuses the docs-only, release-only
  and small-change definitions of `.claude/review-gates.md` rather than a new threshold or `scripts/local-ci.sh
  --lane`, whose `full` also means "no light row" and which compares against the base tip (Gate A pass 1).
- D4: 15 minutes, counted from the GitHub time of the request comment: Greptile took 2–4 min in Bricks Child and
  4–11 min here; the limit sits above both, and a GitHub timestamp survives a restart.
- D5: kit refresh is matched by head branch `chore/kit-*` only, the name the orchestrator uses for refresh PRs.
- D6: completion is a Greptile summary comment (footer `Last reviewed commit`) created or edited after the request,
  not a status check: the checks APIs showed no Greptile entry here (bot file), and the summary is the one channel
  never missing. A Greptile reply without that footer is no review.
- D7: a draft PR waits: Greptile skips drafts by default, so a request there would spend the one attempt for nothing.
- D8: no lock against two simultaneous sessions (§4 Concurrency scope); a duplicate is recorded, not prevented.
- D9: the record stays in the PR body, as Daniel's order asks, with a re-read before the write; the remaining
  lost-update window between that read and `gh pr edit` is accepted and named, not claimed away (Gate A pass 2).
- D10: the duplicate guard and the completion evidence are separate: any Greptile activity suppresses a request
  (AC-2); only a summary with `Last reviewed commit` counts as a review (D6).

## 8. Sources and impact boundary
Greptile docs through Context7 (`/websites/greptile`, current docs, no version: a hosted service) on 2026-11-20:
`autoReview` (`[]` = never, manual `@greptileai` still works; default `["open"]`), triggering by `@greptileai`
(extra text is a question), the summary footer ("Reviews (n) · Last reviewed commit"), `statusCommentsEnabled` and
`shouldUpdateDescription` (other output channels), drafts skipped by default. GitHub REST through Context7
(`/websites/github_en_rest`, API version 2022-11-28, the `gh` default): list issue comments (`per_page` ≤ 100,
pagination, ascending id, `created_at`/`updated_at`), create issue comment (201 returns the comment). Observed: PR #100's summary
footer. Read: `process-pr-review.md`, `workflow-init.md` 2.5 and 2.23, `scripts/local-ci.sh` header § LANES,
`.claude/review-gates.md`, this repo's bot file, the 0.48 story and design, README, setup, reference,
getting-started. Not touched: the hook, the gate rules, CodeRabbit routing, other projects.
