# PR review bots — dev-workflow-kit

Which automated reviewers run on this repo, and what each one *actually produces*.
`/dev-workflow:process-pr-review` routes on the **Wait for** list below — that list is
the authority. This table is descriptive: it records where each bot's findings have
been *observed*, which may be `inconsistent`.

Getting this wrong is expensive in both directions: waiting on a channel a bot never
uses hangs the loop, and treating a channel as context silently drops real findings.

| Bot | Enabled | Where findings appear | Notes (plan/tier limits, completion signal, quirks) |
|---|---|---|---|
| CodeRabbit | yes | **inline** | Observed on PR #1 (plan: Pro Plus, profile CHILL): posts real inline review comments on the diff, each with severity and a committable suggestion, plus a walkthrough summary comment. Read the inline comments — the walkthrough is not a findings source. |
| Greptile | yes | **inconsistent — see notes** | **PR #1:** a single PR-level summary and nothing inline; its two findings sat *inside* that summary under "Comments Outside Diff". **PR #4:** two inline P2 comments, both valid and both accepted. Same repo, same account, the same day roughly seven hours apart (PR #4's inline comments are timestamped 2026-07-18T19:12Z). Behaviour is not predictable from two observations, so read **both** the inline comments and the summary body. Re-evaluate after the next observation, and keep this as `inconsistent` until evidence explains a *stable rule* — one more data point may add a third behaviour rather than settle anything, and reclassifying on thin evidence is what produced the wrong entry the first time. Took ~5–10 min to post on both. |
| Cursor Bugbot | no | n/a | Comments only to say it is disabled for this account. Ignore. |

**Wait for — this list is authoritative.** CodeRabbit (inline findings) and Greptile
(inline *and* summary — check both, see its row).

**Completion signal, per bot.** CodeRabbit posts a status, so `gh pr checks` shows it.
Greptile's is unreliable: `gh pr checks` listed a "Greptile Review" entry for PR #4
while it was open, but the check-runs and statuses API for that same head
(`bf875b1`) returns only `quality` and `CodeRabbit` — so do not treat `gh pr checks`
alone as proof Greptile has finished. Wait for its review or summary comment to
appear via `gh pr view --json comments,reviews`.

`/dev-workflow:process-pr-review` routes on **this list**, not on the table's column.
The column is descriptive — it says where a bot's findings tend to appear, and may read
`inconsistent`, which is not a routing instruction. A bot named here is waited for and
both of its channels are read; a bot absent here is not waited for.
**Context only:** _(none)_ — Cursor Bugbot is disabled, not context.

A bot belongs under **Wait for** only once it has been *seen* producing findings
here. Listing an unconfirmed bot there is the failure this file exists to prevent —
`/dev-workflow:process-pr-review` would block on findings that never arrive.

**Note the trap Greptile sets:** on PR #1 nothing appeared in
`gh api .../pulls/N/comments`, yet it was *not* summary-only in the "context, no
findings" sense — both findings were real and accepted. On PR #4 it posted inline
instead. Either way the findings were real, so the safe reading is: check both
channels and treat whatever it produces as a findings source.

This row is deliberately left ambiguous rather than resolved. The file's job is to say
what is actually known, and what is known today is that the behaviour varied between
two observations. A confident-looking entry backed by one PR is what put "no" here in
the first place.

**Revisit when:** a bot's plan/tier changes (a Free→Pro upgrade can turn a
summary-only bot into a findings bot), or a bot is enabled/disabled.
