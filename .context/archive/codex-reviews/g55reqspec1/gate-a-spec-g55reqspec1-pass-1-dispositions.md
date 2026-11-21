1 | accepted, not repaired | guarantee scoped instead of a lock: §4 Concurrency scope states one session per PR (how the workflow runs) and records a duplicate after a post-request re-read; D8 records why no lock (none exists on GitHub both sessions could take)
2 | fixed | §4 items 2 and 4: reads need zero exit, a failed read requests nothing; a failed/unclear POST is never retried, one re-read decides, else `request undetermined`
3 | fixed | §4 item 5 and D6: arrival needs a review artifact (summary footer `Last reviewed commit`); other Greptile replies are no review
4 | fixed | §2 prerequisite: default output (summary comment) is required and stated as the user's setting; §4 item 2 also scans review records and inline comments for duplicates
5 | fixed | §3: merge-base computed once, `<mb>..<head>` used for every test; local-ci `--lane` dropped
6 | fixed | §3 rules 2 and 3: docs-only and release-only use the review-gates definitions directly (release-only = the hook note quoted in the PR body); no CI-lane dependency (D3)
7 | fixed | §4 item 1: head commit must not be `WIP:` and a Gate B cycle line must be in the range
8 | fixed | §4 item 5: the wait is named as the one exception to "never block" for this mark and as outside CLAUDE.md §4's external-work rule; build carries it into the command, the 2.5 template and this repo's bot file
9 | fixed | §4 item 1 and D7: a draft defers without spending the attempt
10 | fixed | §4 item 6: delimited block, re-read before edit, one redo, else a PR comment
11 | fixed | §4 item 2: reviewed-without-request state, no wait, its own record line
12 | fixed | §3: PR number validated before any command
13 | fixed | §8: Context7 GitHub REST lookup named with API version
