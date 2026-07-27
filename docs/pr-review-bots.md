# PR review bots — dev-workflow-kit

Which automated reviewers run on this repo, and what each one *actually produces*.
`/dev-workflow:process-pr-review` routes on the **Wait for** list below — that list is
the authority. This table is descriptive: it records where each bot's findings have
been *observed*, which may be `inconsistent`.

Getting this wrong is expensive in both directions: waiting on a channel a bot never
uses hangs the loop, and treating a channel as context silently drops real findings.

| Bot | Enabled | Where findings appear | Notes (plan/tier limits, completion signal, quirks) |
|---|---|---|---|
| CodeRabbit | yes | **inline** | Posts real inline review comments on the diff, each with severity and a committable suggestion, plus a walkthrough summary comment. Read the inline comments — the walkthrough is not a findings source. Observed on #1 and #18 (profile CHILL). **Plan: Free** (per Daniel); the "Pro Plus" recorded here earlier was observed on PR #1 only and no longer describes the account — the review-limit behaviour below is what a Free plan produces. **Routed opportunistically since #18** — five consecutive unreviewed heads (#12, #13, #15, #16, #17), then a genuine review. Two quirks that look like signals and are not: **its status check goes green whether or not a review happened**, so a green check never proves the final head was reviewed (the per-head count is the arbiter); and **`@coderabbitai review` is a no-op while automatic reviews are active** — the bot says so itself ("This command is applicable only when automatic reviews are paused", #17), which is why #14's re-trigger produced nothing. |
| Greptile | yes | **summary always; inline usually** | Four PRs observed (#1, #2, #4, #5): a PR-level **summary comment every time**, with findings sometimes only inside it under "Comments Outside Diff". **Inline** comments on #2 (1), #4 (2), #5 (1) but **none on #1** — so inline is usual, not guaranteed. Read both channels; the summary is the one that has never been missing. **Completion signal: none you can block on.** `gh pr checks` displayed a "Greptile Review" entry for #4 and #5, but the check-runs and statuses APIs return no Greptile entry for any of those heads — the two tools disagree, so neither proves it has finished. Posts within ~4–11 min. |
| Cursor Bugbot | no | n/a | Comments only to say it is disabled for this account. Ignore. |

**Routing — these lists are authoritative.**

- **Wait for (block on it):** *none.* CodeRabbit sat here until #18 and no longer does —
  grounds below.
- **Process opportunistically (never block):** CodeRabbit and Greptile. Read whatever
  each has posted when the pass begins, in both channels. If one posts later, handle it
  as a follow-up.
- **Ignore:** Cursor Bugbot — disabled for this account, and it says so itself.

**Why CodeRabbit moved.** It has a status check, so blocking on it always *terminated* —
what it stopped doing was delivering. Five consecutive heads went unreviewed (#12, #13,
#15, #16, #17), the last with **zero review records on the PR at all**; then #18 came
back genuinely reviewed with three findings. That is the opportunistic category exactly
as this file defines it: a real findings source whose delivery is unpredictable and whose
completion signal proves nothing about whether a review happened. Greptile set the
precedent for a different reason — no signal at all — and CodeRabbit arrives at the same
place by a signal that exists and does not mean what it appears to mean.

**What the routing change does *not* touch: the per-head count.** The verification below
is unchanged and stays exactly as #17 left it. Note only what its scope now is: it is a
**merge-time** check, and the *blocking* half of the completion-signal distinction below
now binds no bot, because nothing sits under **Wait for**. The count is still how you
learn whether a given head was reviewed; it is no longer paired with a bot you wait on.

**Completion signal, per bot.** CodeRabbit posts a status — visible in `gh pr checks`,
and it finishes whether or not a review happened. **Two different things, and conflating
them merges unreviewed heads.**

- *The check stopped pending* — a blocking signal, and the reason CodeRabbit looked
  waitable. Nothing is blocked on it now.
- *The final head was reviewed* — a separate verification, and the one that decides
  whether you may merge. **This is settled behaviour, not a hazard that might occur:
  never merge on the check alone — the review count is the arbiter.** Five occurrences,
  the last three caught by running the count rather than by luck:
  - **#12 and #13** — the check passed while the issue comment read "Review rate
    limited"; on #13 the only CodeRabbit **review record** carried `commit_id` `eed589c`
    while the merged head was `92de0d2`. The head that merged was never reviewed.
  - **#15** — green check, "Review rate limited", and the count returned `0` for the live
    head. Merging there would have shipped an unreviewed head; waiting until the count
    reached `1` cost about three minutes.
  - **#16** — twice in one PR, and the occurrence that settled the rule's final form: on
    head `c6c1850` the check was green, the comment read "Review rate limited", and the
    count was `0` — unreviewed. Two heads later the comment read "Review rate limited"
    again while the count was `1` — reviewed.
  - **#17** — the fifth, and the one that moved CodeRabbit out of **Wait for**: green
    check, count `0` before and after a re-trigger, and **zero CodeRabbit review records
    on the PR for any head**. Its first comment was not "Review rate limited" but *"Review
    limit reached — you've reached your PR review limit, so we couldn't start this
    review"*; the re-trigger then answered *"Review finished… does not re-review already
    reviewed commits"* and produced nothing, so a review that never started was booked as
    done. Merged as a recorded human exception (#14 precedent).
  - **#18** — reviewed, with three findings on the live head and a count of `1`. Five
    unreviewed heads then a genuine review is the whole argument for the move: the bot
    delivers real findings, on no schedule you can predict or wait on.

  **The message is noise. The count is signal. In both directions.** "Review rate
  limited" appears on heads that were never reviewed and on heads that were, so it tells
  you nothing either way; there is no interpretation left to do, and nothing to weigh —
  one integer per head decides it. `0` means do not merge. Anything else means the head
  was reviewed. What the green tick establishes is that CodeRabbit's *check* finished,
  which is a different fact about a different thing.

  **Verification is per head, not per PR.** Every push moves the head and the previous
  answer expires with it; a PR that takes three pushes takes three verifications. #16
  took exactly that, and its final push had to be dropped and re-landed separately
  because the new head went unreviewed past the point of waiting.

Verify the second before merging — a deterministic boolean, so it can gate rather than be
eyeballed. Run it on every merge, including the ones where the check looks unambiguous:

```sh
head=$(gh pr view <n> --json headRefOid --jq .headRefOid)   # the LIVE head, not local HEAD
gh api --paginate repos/<owner>/<repo>/pulls/<n>/reviews | jq -s "
  [ .[][]
    | select(.user.login==\"coderabbitai[bot]\")
    | select(.commit_id==\"$head\")
    | select((.body // \"\") | test(\"rate limit\"; \"i\") | not)
    | select(.state==\"COMMENTED\" or .state==\"APPROVED\" or .state==\"CHANGES_REQUESTED\")
  ] | length" | grep -qv '^0$'
```

**`--slurp` cannot be used here, and an earlier draft of this file said it could.**
`gh api --slurp` is rejected outright when combined with `--jq`
("the `--slurp` option is not supported with `--jq` or `--template`"), so that command
failed with a usage error rather than returning a boolean. Pipe the paginated raw pages
to `jq -s` instead — `--paginate` emits one JSON array per page, `-s` wraps them, which is
why the filter iterates `.[][]`. **Verified against #13, and the two stages report differently — say which you mean:** the
`jq` stage prints the count, `0` for the merged head `92de0d2` and `1` for `eed589c`, the
commit actually reviewed; the full pipeline prints nothing and communicates through its
**exit status**, `1` for the merged head and `0` for the reviewed commit. That inversion
is deliberate — exit 0 means "a qualifying review exists", so the pipeline can gate a
merge directly. Documenting
the unrun form broke this repo's own rule against documenting a command nobody ran.

**Four observations now, and the fourth is the one that mattered.** #12 and #13 both
*merged* heads that were never reviewed — the miss was only found afterwards. On **#14**
the check said `pass` while the comment said "Review rate limited", and this query
returned `0` for head `787dd9a` **before** the merge: the re-trigger produced nothing, and
the PR merged on an explicit human decision with the exception recorded, the unreviewed
delta being a one-word prose correction the reviewer had itself requested. That is the
intended shape — this query is what tells you whether a review actually happened, and
when it disagrees with the check a human decides. (Written while CodeRabbit was still
under **Wait for**, so it read "the check is a signal you block on"; nothing is blocked
on now, and the rest of the shape is unchanged.) **#17 explains the "re-trigger produced
nothing" here:** `@coderabbitai review` is a no-op while automatic reviews are active.

`--paginate` matters: without it only page one is read, so a qualifying review can sit on
page two and be read as absent. `jq -s` is what slurps the pages — `gh api --slurp` cannot
do it here, being rejected outright when combined with `--jq`. `DISMISSED` is excluded — a dismissed review is not
a review of that head. If no qualifying record exists, re-trigger once (expect nothing —
`@coderabbitai review` is a no-op while automatic reviews are active, so the attempt
costs a wait and is kept only because it is cheap and has not been observed to hurt); if
it is still absent, **merge only on an explicit human decision**, recording that the head
went unreviewed.

What was actually measured, stated exactly: the rate-limit warning appeared in the **issue
comment**, while the review record was an earlier completed review of an earlier commit.
So the demonstrated failure is a *missing* review for the final head — which the
`commit_id` comparison catches. No rate-limited *review record* has been observed; the
body filter is bounded defensive filtering, not a check against something seen.

**Greptile has no signal you can block on**, across four PRs: `gh pr checks` displayed a
"Greptile Review" entry for #4 and #5, while the check-runs and statuses APIs return no
Greptile entry for any observed head. Two tools, two answers, so neither is proof.

So: **process Greptile opportunistically, never block on it.** Begin the pass — nothing
gates it now — and read whatever Greptile has posted at that moment via
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

CodeRabbit widened the category rather than fitting the original shape. Greptile has *no*
completion signal; CodeRabbit has one that always fires and carries no information about
whether a review happened. The category turns out to be about **whether a signal predicts
delivery**, not about whether a signal exists — a distinction only visible once a bot
supplied the second case. Both belong here for the same practical reason: what they post
is worth reading, and when they post is not something you can wait on.


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
