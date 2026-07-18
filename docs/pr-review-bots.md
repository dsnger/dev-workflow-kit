# PR review bots — dev-workflow-kit

Which automated reviewers run on this repo, and what each one *actually produces*.
`/dev-workflow:process-pr-review` reads this file to decide **which bots to wait for**
(only those that post line-by-line findings) and which to treat as context only.

Getting this wrong is expensive in both directions: waiting on a bot that structurally
cannot post line comments hangs the loop, and reading a summary as a findings source
silently drops real findings.

| Bot | Enabled | Posts line-by-line findings | Notes (plan/tier limits, quirks) |
|---|---|---|---|
| CodeRabbit | yes | **yes** | Observed on PR #1 (plan: Pro Plus, profile CHILL): posts real inline review comments on the diff, each with severity and a committable suggestion, plus a walkthrough summary comment. Read the inline comments — the walkthrough is not a findings source. |
| Greptile | yes | **no** | Observed on PR #1: posts a single PR-level summary comment and nothing inline. Its findings live *inside* that summary under a "Comments Outside Diff" section, so they are easy to miss — parse the summary body, do not wait for line comments that never come. Took ~10 min to post. |
| Cursor Bugbot | no | n/a | Comments only to say it is disabled for this account. Ignore. |

**Wait for:** CodeRabbit (inline findings) and Greptile (its summary carries the
findings) — both post a check, so `gh pr checks` going non-pending is the signal.
**Context only:** _(none)_ — Cursor Bugbot is disabled, not context.

A bot belongs under **Wait for** only once it has been *seen* producing findings
here. Listing an unconfirmed bot there is the failure this file exists to prevent —
`/dev-workflow:process-pr-review` would block on findings that never arrive.

**Note the trap Greptile sets:** it is *not* a line-comment bot, so nothing appears
in `gh api .../pulls/N/comments` — but it is also *not* summary-only in the
"context, no findings" sense. Both of its PR #1 findings were real and were accepted.
Treating it as context-only would have silently dropped them.

**Revisit when:** a bot's plan/tier changes (a Free→Pro upgrade can turn a
summary-only bot into a findings bot), or a bot is enabled/disabled.
