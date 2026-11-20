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
  kit writes its default there (§3); a project edits it. No such paragraph: nothing is requested, and the PR body
  says `Greptile: not requested — no Request when rule in docs/pr-review-bots.md`.

## 3. The kit default `Request when` rule
Request only when all three hold; the first that fails is the one-line reason:
1. **Not a kit refresh:** the head branch (`gh pr view <n> --json headRefName`) does not start with `chore/kit-`.
2. **Not docs- or release-only:** where `scripts/local-ci.sh` exists, `sh scripts/local-ci.sh --lane
   origin/<baseRefName> <head>` prints `full` (its light lane is exactly docs- or release-only, header § LANES);
   elsewhere, some changed path (`git diff --name-only "$(git merge-base origin/<baseRefName> <head>)" <head>`) is not
   docs-only as `.claude/review-gates.md` defines it, and not only `CHANGELOG.md` files and version sites.
3. **Not a small change:** the PR is not a small change as `.claude/review-gates.md` defines it (risk `standard`,
   security `none` from the cited story; ≤197 lines added+deleted outside test-only files, measured over the PR's
   merge-base..head with `git diff --numstat`; no prompt path, migration, shared contract or invariant path). A cited
   story at risk `high` or security above `none` is never small, so it always passes this test.
Values filled into these commands are checked first: `baseRefName` and `headRefName` against `^[A-Za-z0-9._/-]+$`,
the head against `^[0-9a-f]{40}$`; a failure requests nothing (`Greptile: not requested — unsafe ref name`).
Why this rule: it reuses three tests every initialized project already has, each with its own owner, so it is
checkable from the PR alone; this repository's prompts are never "small", which matches Daniel's observation that
Greptile paid off here; Bricks Child's small PHP fixes are not reviewed.

## 4. `process-pr-review` changes
Step 2 gets a new paragraph **Request a review once per PR** for an entry marked `requested by the review loop`:
1. **When.** After Step 1 reads the required check green on the head (none required: Step 1's record), and when a
   commit body in the PR's range carries a Gate B cycle line (`cycle <nonce>; Gate B (passes`) or the rule excludes
   the PR anyway. Check still running: request when Step 1's re-verification reads it green.
2. **Already requested?** Read every issue comment (`gh api --paginate repos/<owner>/<repo>/issues/<n>/comments`).
   A comment whose body, trimmed, starts with `@greptileai` or `@greptile` (a request, by anyone), or any comment by
   `greptile-apps[bot]`, means a request was made or a review ran: request nothing. The first such request's
   `created_at` is the request time. This reads only GitHub, so a restarted session gets the same answer; a push
   changes nothing here (AC-5).
3. **Worth it?** Apply the bot file's **Request when** rule (§2, §3). No match: request nothing.
4. **Request.** `gh pr comment <n> --body '@greptileai'`: the bare tag, because Greptile answers extra text as a
   question rather than a review. `<n>` is checked against `^[0-9]+$`. Its `created_at` is the request time.
5. **Wait.** Up to 15 minutes from the request time, read the issue comments every 2 minutes; the review has
   arrived when a `greptile-apps[bot]` comment has `created_at` or `updated_at` at or after the request time
   (Greptile edits its summary in place on a re-review). Then read both channels (summary and inline,
   `pulls/<n>/comments`) and go on to Step 3. Past the limit: record it and go on; nothing blocks. A restarted
   session counts from the same request time, so the limit never restarts.
6. **Record.** One line in the PR body, replacing an earlier `Greptile:` line (`gh pr view <n> --json body`, then
   `gh pr edit <n> --body-file`): `Greptile: requested on <sha12> at <time>; reviewed <sha12 from its "Last reviewed
   commit" footer, or "summary updated">` · `Greptile: requested on <sha12> at <time>; no review within 15 min` ·
   `Greptile: already requested at <time>` · `Greptile: not requested — <reason from §3>`. The run's report carries
   the same line.
A Greptile entry with the mark that was not requested and has no Greptile comment on the PR is not on for this PR:
no `no review on <sha>` line. The 0.48 sentence "the only review this command starts is Gate B for a fix" gains
"and the one request this paragraph allows".

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
- D1: trigger by comment `@greptileai`, not the Greptile MCP `trigger_code_review`: the comment needs only `gh`, which
  the loop already uses, and it leaves the record that makes the duplicate check work after a restart. The MCP needed
  a fresh sign-in in this very session.
- D2: the duplicate check counts any `@greptileai` comment and any Greptile comment, by anyone: a human's request
  already cost a run.
- D3: the rule lives in each project's bot file (Daniel's addendum); the kit default reuses the light lane, the
  docs-only definition and the small-change definition rather than a new threshold.
- D4: 15 minutes, counted from the GitHub time of the request comment: Greptile took 2–4 min in Bricks Child and
  4–11 min here; the limit sits above both, and a GitHub timestamp survives a restart.
- D5: kit refresh is matched by head branch `chore/kit-*` only, the name the orchestrator uses for refresh PRs.
- D6: completion is a Greptile comment created or edited after the request, not the review counter or a status
  check: the checks APIs showed no Greptile entry here (bot file), and the summary is the one channel never missing.

## 8. Sources and impact boundary
Greptile docs through Context7 (`/websites/greptile`, current docs, no version: a hosted service) on 2026-11-20:
`autoReview` (`[]` = never, manual `@greptileai` still works; default `["open"]`), triggering by `@greptileai`
(extra text is a question), the summary footer ("Reviews (n) · Last reviewed commit"). Observed: PR #100's summary
footer. Read: `process-pr-review.md`, `workflow-init.md` 2.5 and 2.23, `scripts/local-ci.sh` header § LANES,
`.claude/review-gates.md`, this repo's bot file, the 0.48 story and design, README, setup, reference,
getting-started. Not touched: the hook, the gate rules, CodeRabbit routing, other projects.
