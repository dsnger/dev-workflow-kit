# Kit 0.41: six field cases from 2026-10-21 and 2026-10-22 — Design

**No story:** the work comes from the orchestrator brief
`.context/sparring/20261022-154500-kit-041-prompt.md` (six field cases, 2026-10-21 to 2026-10-22);
there is no story file.
**Profile (derived, as intake does):** `risk high; security none; evidence battery+check` — risk `high`
because it changes the hook's WIP recognition, `/workflow-init` templates and `process-pr-review`'s
merge step (contracts every initialized project follows); security `none` because no secret,
permission or trust boundary is touched (the attribution setting only removes text); `battery+check`
because the hook suite pins the WIP behaviour and checks 4e/4g/4i/4j measure the changed texts.
**Date:** 2026-10-22 · **Version:** dev-workflow 0.41.0 (minor: hook behaviour and two new
`/workflow-init` offers).

## Decisions

Taken in this note (autonomous run, CLAUDE.md §4), each a choice, not a source fact. One Gate A covers
spec and plan: the plan is §8 of this note, as in 0.40.0.

| # | Case | Verdict | Reason |
|---|---|---|---|
| 1 | Chained `git add … && git commit` resets the count | **adopt** | `git add` cannot move HEAD or its reflog, and the hook's after-commit check already proves HEAD is this call's WIP commit, so one leading `git add <plain words> &&` keeps the same guarantee. |
| 2 | "Hook count matched: no" without a cause | **adapt** | The cause was a misread term (the session compared hook state *file* names, 19 vs 20), and the term lives only in orchestrator briefs; the kit documents how to read the hook's count and that a mismatch names its cause or says `cause unknown`. |
| 3 | Docs-only delta after a green battery | **adapt** | The rerun rule for the final head lives in `process-pr-review` Step 3 item 6, not in the capped rules file; the delta rule goes there, so the rules file keeps its bytes. |
| 4 | No `Co-Authored-By` in initialized projects | **adapt** | `includeCoAuthoredBy` is deprecated (Claude Code settings reference); `/workflow-init` merges `attribution` with empty `commit` and `pr` instead, and the squash body is written from the commits minus Claude Code's default `Co-authored-by` trailer, keeping human co-authors and the cycle record lines the reports read. |
| 5 | `.context/` scratch piles up | **adopt** | 2.18 offers a second block, `/.context/*` with the five `!` settings, recommending it when only those settings are tracked there and showing the tracked paths otherwise. |
| 6 | Human approvals arrive mid-build | **adopt** | The Plan bullet lists each action outside the repository that needs the human, and the autonomous-run stops ask for them once when the plan closes. |

## 1. Evidence

- **Case 1.** Board 2026-10-22 07:58 and 08:28: canvas S5 unit 1, Gate B `s5bau1q7x2k`, WIP `34c4405`
  made as a chained `git add … && git commit -m 'WIP: …'`; hook saw 1 of 2 passes ("third case
  today"); 10:40 "hook no: chained commit 34c4405". 00:15: canvas S4 "chained subagent commit". The
  brief forbade the form; `docs/reference.md` § Hook messages names chains as refused, and the hook's
  PreToolUse sentence names them at the moment. Rule text and message both existed and did not hold.
- **Case 2.** Board 2026-10-22 08:28: kit 0.40.1 (#92) "hook count no (cause not stated)". The
  session transcript (`~/.claude/projects/-Users-daniel-DEVELOPMENT-APPS-dev-workflow-kit--claude-worktrees-kit-0401/326b8365-….jsonl`)
  reports "Hook count matched: no. The hook names 20, not 19 (cap-extra …)": it answered about the
  number of hook state-file names its brief listed, not the pass count. Its hook messages show every
  WIP commit recognised, one `review` call with a 7-character `headSha` not counted and re-run with
  the full SHA, and both closing commits taking the docs-only path, which prints no count. The state
  files were not archived (`.context/archive-lane-kit-0401/` holds only `codex-gate.on`), so whether
  the gate count matched is **unknown**. "Hook count matched" appears in no kit file
  (`grep -rniE 'count matched'`), only in orchestrator briefs.
- **Case 3.** Board 2026-10-22 04:05: canvas S5 spec, 85-minute battery rerun for three Markdown
  lines declined; static stages plus CI, recorded in PR #53.
- **Case 4.** Board 10:32 and 10:40: SFX and canvas merges carried `Co-Authored-By`; their sessions
  set the setting by hand. This repo's `.claude/settings.json` has `"includeCoAuthoredBy": false`.
  Context7 `/websites/code_claude` (settings reference, current): `includeCoAuthoredBy` "Deprecated
  since v2.0.62, when `attribution` replaced it"; `attribution` takes `commit`, `pr` strings and a
  `sessionUrl` boolean, or `false` (v2.1.281+, earlier versions skip the whole file); "In a settings
  file that earlier versions also read, set `commit` and `pr` to empty strings and `sessionUrl` to
  `false`". GitHub's default squash body joins the commit messages, so a trailer in any commit
  reaches `main`.
- **Case 5.** Board 12:55 and 13:00: SFX 1,120 and bricks-api 5,045 untracked `.context/` files,
  hidden by a local `.git/info/exclude`; canvas already ignores `.context/`.
- **Case 6.** Board 11:06 and 14:34: SFX P0 waited about 2 h for decision D20 (trust entries in
  `~/.claude.json`), knowable when the plan was written.

## 2. Case 1 — one leading `git add` before a WIP commit

- `is_wip_message_cmd` (`codex-gate.sh`) first removes one leading prefix
  `git add` followed by one or more words, each made only of `[A-Za-z0-9._/@+=,:%~-]`, then optional
  spaces and `&&`; the rest must pass the existing checks unchanged (one line; no `;&|<>$` backtick
  or backslash; the option allow-list; one `-m` starting `wip`). Without that exact prefix nothing is
  removed and the `&` refuses the command as today.
- **Why it is safe (invariant 2, the false-✓ direction).** Keeping the counters still needs
  `is_wip_commit_post`: HEAD's subject starts with `wip`, HEAD's reflog grew by exactly one, HEAD's
  parent is the HEAD recorded before the call (for `--amend`, which the option allow-list already
  admits, HEAD's parent is the recorded parent instead), and the call was not backgrounded. `git add` does not
  write HEAD's reflog, so anything that does (a filter or hook that commits) fails that check and
  resets. If `git add` fails, `&&` skips the commit, HEAD and the reflog stay, and the counters stay,
  as for a failed plain commit. The allowed word characters exclude quotes, globs, `$`, backtick,
  backslash and every shell operator, so no word can become a second command or change the message.
  `msg_may_be_rewritten` still sends a repository with hooks or a comment character to the reminder.
- **Not changed.** The docs-only check (`names_no_paths`) still refuses the chain, so a closing commit
  in that form gets the full check, as 0.40.0 documented. `cd`, `git -C`, `git add` after the commit,
  a second chain link, heredocs, and quoted or spaced paths stay refused. `git -C <dir> add` is not
  the prefix. No rules-file text changes: the rule's plain form stays the one it prescribes.
- **Not-WIP sentence**: `…with no cd, git -C, chain or heredoc;` becomes
  `…with no cd, git -C, heredoc, or chain other than one leading git add <paths> &&;` (both copies:
  the hook and `docs/reference.md`). The surrounding text that says chains are never kept as WIP
  (`docs/reference.md` § Hook messages, the hook's WIP comment block) is updated with it: the rule
  still prescribes the plain form; the hook also keeps this one chain.

## 3. Case 2 — reading the hook's count

- `docs/reference.md`, after the `✓ Codex Gate B hook checks passed` paragraph, one paragraph
  "Comparing the hook's count with your record": the count is the first number of that ✓ line; a WIP
  or docs-only commit prints none, and the current value is in `.context/codex-gate.passes` (Gate B)
  and `.context/codex-gate.passCountA` (Gate A), cleared when the counters reset. Compare it with the
  cycle line's pass count before the closing commit. A report that says they differ names the cause:
  one of the hook's earlier messages in this cycle (a commit not counted as WIP, a `headSha` that is
  not a full SHA, an unpaired branch, a resumed `exec`, a withheld result), or `cause unknown`.
- **Not done:** the kit has no "hook count matched" field to change; the status-line wording is the
  orchestrator's. The final status line tells the orchestrator the cause and suggests defining the
  term as "the hook's pass count equals the cycle line's".

## 4. Case 3 — docs-only delta after a green battery

`process-pr-review` Step 3 item 6, after "If code changed: …": when the quality command passed in
full on a commit this run can name (its SHA, from that run's output or record) and every path changed
from that commit to the final head is docs-only as `.claude/review-gates.md` defines it, rerun only
the stages of the quality command that read those paths, name them and the baseline SHA in the report,
and let the required CI check on the final head stand for the rest. No named baseline, a baseline that
is not an ancestor of the head (a rebase), or stages whose inputs cannot be told: run the full command.
The item's load-flake sentence stays; the item then names two exceptions, not one. `docs/reference.md` ("The battery is always owed, with one exception") names the second one in the same change: the full run on the named baseline plus CI on the final head is the battery evidence. `docs/coding-workflow.md`
gets one sentence where it describes the final-head battery, if it does. No rules-file bytes.

## 5. Case 4 — no attribution lines

- **`/workflow-init` new `### 2.19 .claude/settings.json — no commit or PR attribution`.** Merge
  `{"attribution": {"commit": "", "pr": "", "sessionUrl": false}}` (the form older clients also read;
  `false` alone would make a pre-2.1.281 client skip the whole file). Branches, in order, first match
  wins: (1) missing file → write it with this block, `merged`; (2) not valid JSON → touch nothing,
  `skipped (not valid JSON)`; (3) the root is not an object → touch nothing, `skipped (root is not an
  object)`; (4) no `attribution` key → add it, `merged`; (5) `attribution` deep-equal to this block →
  `unchanged`; (6) `attribution` is `false` → show it and ask keep / replace, saying a client older than
  2.1.281 skips the whole file (the deny lines of 2.17 included) while it stays; (7) `attribution` is an
  object with other values → show it and ask keep / replace (a project may want its own trailer); (8)
  anything else (null, string, array, number) → touch nothing, `skipped (attribution is neither an
  object nor false)`. An existing `includeCoAuthoredBy` stays; the report notes it is deprecated and
  ignored once `attribution.commit` is set. Why, in the step: the trailer reaches `main` through the
  squash body.
- **`process-pr-review` Step 4.** Merge with `--body-file <file>`: the body is the range's commit
  messages (`git log --reverse --format='%s%n%n%b' <merge-base>..<head>`), with every line matching
  `^co-authored-by:[[:space:]]*claude[^<]*<noreply@anthropic\.com>[[:space:]]*$` (any case), Claude Code's default trailer (its name is `Claude`, `Claude Code` or `Claude <model>`, its address `noreply@anthropic.com`), removed and all other
  lines kept: a human co-author's trailer and a project's own attribution chosen at (7) survive, so init
  and merge follow one policy (remove the default, keep what a person chose), and the cycle record lines
  the reports read from `main`'s commit bodies survive too. The file lives under `.context/`.
- **Library APIs.** Claude Code: Context7 `/websites/code_claude` (settings reference) is unversioned;
  its own text dates the behaviour (`attribution` since v2.0.62, `false` since v2.1.281), which is the
  Library APIs fallback for the version question; the object form with empty strings is therefore read
  by every client from 2.0.62 on, including the CI pin 2.1.207 and the local 2.1.308. GitHub CLI:
  Context7 `/websites/cli_github_manual` is unversioned; fallback `gh pr merge --help` on the local
  `gh` 2.96.0 shows `-F, --body-file`, `-s, --squash`, `--match-head-commit`.

## 6. Case 5 — `.context/` scratch

2.18 item 4, **Offer the scratch block**, after item 3:

```gitignore
# dev-workflow: session scratch in .context/ stays local. The exceptions are
# the hook settings.
/.context/*
!/.context/codex-gate.on
!/.context/codex-gate.off
!/.context/codex-gate.floor
!/.context/codex-gate.cap
!/.context/codex-gate.tools
```

The `!` lines are those the 2.18 block kept: a setting whose `!` line item 1 dropped at the project's
request is left out here too. Branches, in order: its first comment line present → `unchanged`.
`git check-ignore --no-index -v .context/dwk-scratch-probe`: exit 0 and the named rule's pattern covers
all of `.context/` (`.context`, `.context/`, `.context/*` or `.context/**`, with or without a leading
`/`) → ask nothing, report `already ignored`; exit 0 with a narrower rule, or exit 1 → go on; any other
exit → report the error and offer nothing. Then run `git ls-files -- .context`: only kept settings (or
nothing) → offer it, recommending yes; other paths → list them and ask, saying they stay tracked but
new files beside them would be ignored, so a project that tracks handovers there adds its own `!` line.
Appended at the end, after the 2.18 block. After appending, item 2's settings check runs again on the
kept settings. `/.context/*` (not `.context/`) so the `!` lines can re-include files. Why, in the step:
a `git add -A` would sweep thousands of scratch files in.

## 7. Case 6 — approvals outside the repository

- Repo `CLAUDE.md` §4 and the `/workflow-init` CLAUDE.md template, Plan bullet: "…a short **Sources
  and impact boundary** note, and every action outside the repository that needs the human (a file
  under the home directory, an account, a paid run)." Autonomous run, the stops sentence gains: "the
  plan's actions outside the repository, asked for together once its Gate A closes, or once it is
  written when it gets none".
- `docs/coding-workflow.md` gets the same clause where it lists the plan's contents.
- **Conditions accounting** (AGENTS.md Don'ts): the stops list keeps all four stops and the checkpoint
  line; one stop is added. The Plan bullet keeps every listed item.

## 8. Plan

Handover boundary: the merged PR. No run of 45 minutes or more (battery ~5 min; prompt eval once,
about 10 min). Sources and impact boundary: `codex-gate.sh` (`is_wip_message_cmd`, the not-WIP note),
`codex-gate.test.sh` (sections m5, 46, 48 and the `mlife` helper), `workflow-init.md` (2.18, new 2.19,
CLAUDE.md template, Step 4 checklist if it lists steps), `process-pr-review.md` (Step 3 item 6,
Step 4), repo `CLAUDE.md`, `docs/reference.md`, `docs/coding-workflow.md`, README. Library APIs:
Claude Code `attribution` setting and `gh pr merge` per §5. Outside the repository: the prompt eval
(paid, about $2) is the one action needing the human, and the brief already authorizes one run; nothing
else.

1. **Hook, case 1** (test first). Lifecycle tests (both readers), each asserting that the commit
   landed where one is expected: `git add app.ts && git commit -q -m 'WIP: a'` keeps the counters and
   shows the WIP note; `git add -A && …` keeps; `git add a.ts b.ts && …` keeps; `git add app.ts && git
   commit -q --amend -m 'WIP: a'` keeps; `git add missing.ts && …` (add fails, no commit) keeps.
   Refused (reminder, no WIP note), and reset when HEAD moved: `git add 'a b.ts' && …`, `git add x;
   git commit …`, `git add x && git commit -m 'WIP: a' && true`, `git commit -m 'WIP: a' && git add
   x`, `git -C . add x && …`, `git add $(x) && …`; a chained form where a post-commit hook adds a
   second commit resets. Section 46
   moves the chained case to the no-sentence list and pins the new sentence. Section 48's chained
   docs-only case still gets "cannot confirm". → verify: suite under `sh` and `dash`, shellcheck.
2. **Docs, case 2**: `docs/reference.md` paragraph and the sentence. → verify: `check-doc-links.sh`.
3. **`process-pr-review`, cases 3 and 4.** → verify: read against the prompt-standards checklist; run the documented body filter on a sample holding a `Claude Opus 5.5 <noreply@anthropic.com>` trailer, a human `<someone@anthropic.com>` trailer and a cycle line: only the first goes.
4. **`/workflow-init`, cases 4 and 5**: 2.18 item 4, 2.19, report lines in Step 4 if it lists them.
   → verify: check 4k (2.17 untouched), invariant checks.
5. **CLAUDE.md, case 6**: repo and template. → verify: 4e, 4g.
6. **Docs**: README, `docs/coding-workflow.md`, CHANGELOG, `docs/hardening-log.md` (case 1 hardened by
   test, rung 4), `todos.md`. → verify: doc links.
7. **Version** 0.41.0; prompt eval once before the bump; battery. → verify: battery exit 0.
