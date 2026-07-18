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
| Greptile | yes | **summary always; inline usually** | Four PRs observed (#1, #2, #4, #5): a PR-level **summary comment every time**, with findings sometimes only inside it under "Comments Outside Diff". **Inline** comments on #2 (1), #4 (2), #5 (1) but **none on #1** — so inline is usual, not guaranteed. Read both channels; the summary is the one that has never been missing. **Completion signal: none you can block on.** `gh pr checks` displayed a "Greptile Review" entry for #4 and #5, but the check-runs and statuses APIs return no Greptile entry for any of those heads — the two tools disagree, so neither proves it has finished. Posts within ~4–11 min. |
| Cursor Bugbot | no | n/a | Comments only to say it is disabled for this account. Ignore. |

**Routing — these lists are authoritative.**

- **Wait for (block on it):** CodeRabbit. It has a status check, so `gh pr checks`
  going non-pending is proof it finished.
- **Process opportunistically (never block):** Greptile. Read whatever it has posted
  when the CodeRabbit-gated pass begins, in both channels. If it posts later, handle it
  as a follow-up.
- **Ignore:** Cursor Bugbot — disabled for this account, and it says so itself.

**Completion signal, per bot.** CodeRabbit posts a status, so `gh pr checks` shows it
and you can block on it.

**Greptile has no signal you can block on**, across four PRs: `gh pr checks` displayed a
"Greptile Review" entry for #4 and #5, while the check-runs and statuses APIs return no
Greptile entry for any observed head. Two tools, two answers, so neither is proof.

So: **process Greptile opportunistically, never block on it.** Do the CodeRabbit-gated
pass, and read whatever Greptile has posted at that moment via
`gh pr view --json comments,reviews` plus `gh api .../pulls/N/comments`. If it posts
later, process it as a follow-up. Waiting on it risks hanging forever; ignoring it drops
real findings, since every observed PR carried some.

**When querying, match the login exactly.** Issue comments are authored by
`greptile-apps[bot]`; a filter on `greptile-apps` returns zero and looks like absence.
That mistake is why an earlier version of this row claimed PR #1 had no summary.

`/dev-workflow:process-pr-review` routes on **these lists**, not on the table's column.
The column is descriptive — it records where a bot's findings have been observed, and
may be ambiguous, which is not a routing instruction.

The opportunistic category exists because Greptile forced it: a bot can be a real
findings source with no signal that says it has finished. Blocking on such a bot hangs
the loop; dropping it loses findings. Reading what is there and revisiting later is the
only option that does neither.


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
