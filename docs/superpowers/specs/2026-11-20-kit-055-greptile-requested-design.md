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
3. **Not release-only:** some such path is also none of these: a `CHANGELOG.md`; a version record whose diff over
   the range (`git diff <mb> <head> -- <path>`) changes only lines holding the version; a gettext translation
   catalogue (a `.pot` or `.po` file, or its compiled `.mo`; another kind of file with such an ending counts; since
   0.55.1, § 9, a Greptile-only widening that the gate rules' release-only does not share). Version records: the files on
   the project's `AGENTS.md` `**Version sites:**` line, a plugin manifest, `.claude/dev-workflow-version`, `VERSION`.
   Decided over the whole range, not by the hook's per-commit `release-only:` note, so a feature PR with a separate
   bump commit still counts. Anything the reader cannot tell: counts as not release-only (a request).
4. **Not a small change:** the PR is not a small change as `.claude/review-gates.md` defines it, measured over
   `<mb>..<head>` with `git diff --numstat` and the cited story's profile. A cited story at risk `high` or security
   above `none`, or any prompt path, is never small.
Why this rule: it reuses definitions every initialized project already has (since 0.55.1 with one addition of its
own, the catalogues in rule 3), so it is checkable from the PR alone and
needs no CI configuration; this repository's prompts are never "small", which matches Daniel's observation that
Greptile paid off here; small PHP fixes in Bricks Child are not reviewed.

## 4. `process-pr-review` changes
Step 2 gets a new paragraph **Request a review once per PR** for an entry marked `requested by the review loop`:
1. **When.** The PR is not a draft (`isDraft` false; a draft: `Greptile: not requested yet — draft`, and the next
   run asks again, since nothing was spent); Step 1 read the required check green on the head (none required: Step
   1's record; still running: decide once Step 1's re-verification reads it green);
   and Gate B is closed on the head: take `C`, the last commit in the range whose body carries a Gate B cycle line
   (`cycle <nonce>; Gate B (passes`), and `<mbC>` = `git merge-base "origin/<baseRefName>" C`. For every path in
   `git diff --name-only <mb> <head>` or `git diff --name-only <mbC> C`, compare the PR diff at both heads with
   `git diff <mb> <head> -- <path> | git patch-id --verbatim` against `git diff <mbC> C -- <path> | git patch-id
   --verbatim`. Closed when every path whose ids differ is docs-only, a `CHANGELOG.md` or a version record changing
   only version lines (rule 3). So a base merge (the PR diff is unchanged), a docs commit and a version bump after
   `C` compose, and an unreviewed code change does not. No `C`, a failed command, or another differing path:
   `Greptile: not requested yet — Gate B not closed on <sha12>`; a later run asks again. Order: the **Request when**
   rule (3) runs first, so a docs- or release-only PR, which has no cycle line, is excluded with its own reason
   (since 0.55.1 a release PR with a catalogue may carry a cycle line, D12; rule 3 excludes it all the same).
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
- D11: Gate B closure is compared per path between the PR diff at the closing commit and at the head, so permitted
  successors (base merge, docs, version bump) compose (Gate A pass 3; repaired after the cap on Daniel's answer,
  reviewed at Gate B).
- D10: the duplicate guard and the completion evidence are separate: any Greptile activity suppresses a request
  (AC-2); only a summary with `Last reviewed commit` counts as a review (D6).
- D12 (0.55.1): gettext translation catalogues join rule 3's release-only: a `.pot` or `.po` file or its compiled
  `.mo`, recognised as a catalogue, not by the ending alone (`.mo` is also Modelica and Motoko source; such a file,
  and any file the reader cannot tell, counts, as rule 3's last sentence says). Every change to a catalogue is
  excluded, a release's regeneration and a hand edit alike: the rule asks for no evidence of how the file came to
  change, since none is in the PR. Accepted cost: a hand edit to a `.po` header's `Plural-Forms` expression, which
  runs at runtime, gets no Greptile review when nothing else in the PR counts; Gate B still reviews it. Not a new
  project list and not the head branch `release/*`: gettext's formats are the same in every stack that uses them,
  so the rule names no project's vocabulary (AGENTS.md invariant 10), and a branch name says nothing about the
  content, so a fix carried on a release branch would lose its request. A PR that changes code and a catalogue
  still has a path that counts, so it requests as before. This widens D3 for this rule only: the hook and the gate
  rules keep their release-only (version and changelog), so a release commit that regenerates a catalogue still
  takes Gate B, and its PR carries a cycle line. Not solved here: a version file the project has not put on its
  `**Version sites:**` line still counts; that is the project's line to write.

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

## 9. Changes

**Changed 2026-11-21 — gap found.** Decided by the gate rules' shrink rule ("When a finding class regenerates across
passes, shrink the mechanism (platform parser, narrower scope, deletion)"), Gate B cycle g55gateb1 passes 1–3.
Baseline: 6a54660.

| Earlier condition | Fate | AC operation |
|---|---|---|
| §4 item 1 and D11: Gate B closure by a per-path patch-id comparison between the PR diff at `C` and at the head | dropped — "shrink the mechanism … deletion": the comparison drew new Majors in Gate A passes 2–3 and Gate B passes 1–3; replaced by "a commit body in the range holds a Gate B cycle line, and the head commit is not `WIP:`" | none |
| §4 item 2 "not on for this PR" for earlier Greptile activity without an artifact | kept, except that Step 4's last read still reads Greptile (risk pass 5; fixed after the cap on Daniel's answer, 2026-11-21) | none |

- **Added without an earlier condition:** none.
- **Unaccounted:** none.
- **Intervening changes:** none.
- **Scope boundary:** in: `process-pr-review` Step 2; out: everything else.
- **Open questions:** none.
- **Dependent artifacts:** `plugins/dev-workflow/commands/process-pr-review.md` → updated in this change.
- **Reviews already run:** Gate B passes 1–4 (cycle g55gateb1) → pass 4 reviewed the shrunk rule clean; the risk-pass fix is unreviewed and recorded in `todos.md`, per `.claude/review-gates.md` (at the cap the human decides).
- **Residual accepted:** a `WIP:` commit followed by a non-WIP commit (for example a base merge) can request before that cycle closes; the cost is still one review per PR.

**Changed 2026-11-22 — gap found.** Decided by Daniel, order to session kit-0551-release (2026-11-22): "0.55.1 jetzt",
on his rule of 2026-11-20 (story § 1: "aber auch nur bei Dingen, wo es sich lohnt"); release PRs are excluded
(story AC-3). Baseline: 0f99f36. Evidence: dsnger/sfx-bricks-child#98 "Release v0.38.0" (kit 0.55.0), files
`CHANGELOG.md` +3/-3, `languages/sfxtheme.pot` +770/-266, `style.css` +1/-1; its body records `Greptile: requested
on c8f6cd0a930d … reviewed — 5/5, no findings`. Rule 3 counted the regenerated `.pot` as a path that is neither
changelog nor version record. Plugin version: 0.55.1.

| Earlier condition | Fate | AC operation |
|---|---|---|
| §3 rule 3: release-only is `CHANGELOG.md` and version records whose diff changes only version lines | kept, and widened by gettext translation catalogues (`.pot`, `.po`, compiled `.mo`; any change to one, D12) — story AC-3: "The kit default excludes docs-only and release-only PRs" | none |
| D3: "the kit default reuses the docs-only, release-only and small-change definitions of `.claude/review-gates.md`" | kept for docs-only and small change; for release-only kept and widened in this rule only (D12) — Daniel: "0.55.1 jetzt"; the gate rules and the hook are unchanged | none |
| §3 rule 3: "Anything the reader cannot tell: counts as not release-only (a request)" | kept | none |
| §3 rules 1, 2, 4 and the range | kept | none |
| Story AC-1–AC-8 | kept (AC-8's version is 0.55.0's; this change carries 0.55.1 at the same three sites) | none |

- **Added without an earlier condition:** none.
- **Unaccounted:** none.
- **Intervening changes:** none (`git log 0f99f36..` is empty at the branch point).
- **Scope boundary:** in: rule 3 in `docs/pr-review-bots.md` and in the `/workflow-init` 2.5 template, version
  0.55.1, CHANGELOG and reference; out: `process-pr-review` (it applies the paragraph as written), the hook's
  per-commit `release-only:` note (it still does not know catalogues, so such a release commit takes Gate B), the
  gate rules, and every initialized project's own bot file and `**Version sites:**` line (the rollout's).
- **Open questions:** none.
- **Dependent artifacts:** `docs/pr-review-bots.md` → updated in this change;
  `plugins/dev-workflow/commands/workflow-init.md` (template 2.5, 2.23) → updated in this change;
  `plugins/dev-workflow/CHANGELOG.md`, `docs/reference.md` → updated in this change.
- **Reviews already run:** Gate A and Gate B of 0.55.0 (cycles in the 0.55 PR #111) → they reviewed the earlier
  rule; this change takes its own Gate A on this section and its own Gate B, per `.claude/review-gates.md` ("Gate A
  … reviews a spec … only at risk `high` or security not `none`"; the story's security is `standard`).
- **Sources and impact boundary:** read: this spec, the 0.55 story, both rule copies, `process-pr-review.md` Step 2,
  `.claude/review-gates.md`, `.agents/skills/gate-b-review/SKILL.md` § Risk pass, sfx-bricks-child PRs #95–#98 and
  its `AGENTS.md` and bot file through `gh` (read only). No third-party API is used. Not touched: the hook, the
  gate rules, any project.
