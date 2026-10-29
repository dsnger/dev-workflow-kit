# Kit 0.48: Greptile optional, no review on unchanged content — Design

**Story:** `docs/superpowers/stories/2026-10-29-kit-greptile-optional-story.md` (risk standard, security none,
battery+check, checkpoints none). **Date:** 2026-10-29. **Plugin version:** 0.48.0.
**Gate A:** skipped — risk standard; security none; evidence battery+check (`strict`: Gate A only at risk `high` or
security not `none`).

## 1. Intent
Make every PR bot, Greptile first, something the kit reads when it ran, never something it waits for or asks for, and
let a project say a bot is off or runs only on labelled PRs. Stop the kit's own steps from asking for a review when
only the base moved.

## 2. Shared contract: the routing lists in `docs/pr-review-bots.md`
The three lists stay the authority. Two additions, both written in the routing list entry itself:
- **Off** is a bot under **Ignore** whose table row reads `Enabled: no`. It is not read, waited for or reported.
- **Qualifier** after a bot under **Wait for** or **Process opportunistically**: `only with label <name>` (the bot is
  off on a PR without that label) and/or `once per PR` (a review of any head of the PR counts; report which head).

## 3. What already holds (item 4)
- Gate B: `mcp__codex__review` runs only when the session starts it, on a diff the session wrote. The hook reads only
  `git commit` calls; a GitHub branch update or a local `git rebase` starts nothing. Its fingerprint is content-derived
  (invariant 3) and does change on a base update, which only matters if a cycle commits after a rebase; that is the
  deliberate superset invariant 3 states, and it stays.
- `process-pr-review` Step 3 item 3 runs Gate B only for a substantial fix, never for a base update, and the
  CodeRabbit re-trigger is optional prose in this repo's bot file only.
- Missing: Step 4 says to run Steps 1–3 again on any new head, and Step 2 reports every bot with no review record on
  the live head, so a base update reads as "no review" and invites a re-trigger. Added: the patch-id rule (AC-3):
  check `baseRefName` against `^[A-Za-z0-9._/-]+$` and each SHA against `^[0-9a-f]{40}$` (a failure: no command,
  diff counts as changed), `git fetch origin`, then for each SHA `git diff "$(git merge-base "origin/<baseRefName>"
  <sha>)" <sha> | git patch-id --verbatim`; equal non-empty first fields mean the PR diff is unchanged. Verified on a
  scratch repository (git 2.52.0): a merge of the base gives the same id, a content change a new one, and an
  indentation-only change a new one with `--verbatim` but the same one with `--stable` (Gate B pass 1, cycle
  gr48optl, changed `--stable` to `--verbatim` and added the value check). An empty diff, a failed command or a
  conflict resolution that changed content counts as changed. A fix a claim needs after the base update still
  follows Step 3 item 3.

## 4. Changes
1. `commands/process-pr-review.md` Step 2 and Step 4: off bots, qualifiers, patch-id rule; Step 3 item 1's
   "name each bot that did not review" reads "each bot on for this PR".
2. `commands/workflow-init.md` 2.5: ask about Greptile (default no); template carries the off/qualifier forms and,
   for yes, the Greptile settings the human sets: `labels: ["greptile"]` and `autoReview: ["open"]` (Greptile's
   `greptile.json` reference: `labels` reviews only PRs with those labels; `autoReview` `["open"]` reviews on open,
   not on push or rebase), in Greptile's dashboard or a `greptile.json` the human commits. Unknown and stated: whether
   a label added after opening starts a review; then one `@greptileai` comment starts it.
3. `docs/pr-review-bots.md` (this repo): Greptile row `no`, under Ignore; its history stays as record.
4. `docs/setup.md` step 9, `docs/reference.md` § PR review bots, `docs/getting-started.md` PR bot step: the default.
5. Version 0.48.0, CHANGELOG.

## 5. Decisions
- D1: qualifiers live in the routing list entry, not a new table column, so the lists stay the one authority.
- D2: "once per PR" counts a review of any head, and the report names that head, rather than demanding the live head;
  the label path exists to stop per-push reviews.
- D3: the kit writes no `greptile.json`; the order puts Greptile's settings with Daniel.
- D4: invariant 3 is not loosened for base updates (§3).

## 6. Sources and impact boundary
Read: the order files, `.claude/review-gates.md`, `process-pr-review.md`, `workflow-init.md` 2.5, this repo's
`docs/pr-review-bots.md`, `docs/setup.md`, `docs/reference.md`, `docs/getting-started.md`, the hook's commit matcher.
Greptile: its own docs (`greptile.com/docs/code-review-bot/greptile-json.md`, `trigger-code-review.md`, read
2026-10-29); not a library API, no Context7 entry used. Not touched: the hook, the gate rules, CodeRabbit routing.
