# PR review bots — dev-workflow-kit

Which automated reviewers run on this repo, and what each one *actually produces*.
`/dev-workflow:process-pr-review` reads this file to decide **which bots to wait for**
(only those that post line-by-line findings) and which to treat as context only.

Getting this wrong is expensive in both directions: waiting on a bot that structurally
cannot post line comments hangs the loop, and reading a summary as a findings source
silently drops real findings.

| Bot | Enabled | Posts line-by-line findings | Notes (plan/tier limits, quirks) |
|---|---|---|---|
| Greptile | yes | **unconfirmed** | Greptile can post inline comments plus a PR-level summary, but line-comment volume is tier-dependent and this repo's tier has not been observed yet. Confirm on the first PR: if it posts inline comments, move it to **Wait for** and set this to yes; if only a summary, set it to no and leave it under Context only. |

**Wait for:** _(none yet)_
**Context only:** Greptile, until its behaviour on this repo is observed.

A bot belongs under **Wait for** only once it has been *seen* posting line comments
here. Listing an unconfirmed bot there is the failure this file exists to prevent —
`/dev-workflow:process-pr-review` would block on findings that never arrive.

**Revisit when:** a bot's plan/tier changes (a Free→Pro upgrade can turn a
summary-only bot into a findings bot), or a bot is enabled/disabled.
