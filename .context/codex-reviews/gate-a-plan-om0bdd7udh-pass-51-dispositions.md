# Pass 51 dispositions — cycle `om0bdd7udh`

Advisory companion per CLAUDE.md §5. One line per finding: verdict + reason. Not the findings file.
**No repair was made and none is authorized.** Verdicts recorded 2026-09-17 by checking each claim
against the worktree plan at blob `974e223ed71d52b49c6b368695372ccb72e510f1`.

Reviewer claims are marked **[R]**; what I established myself is marked **[V]**.

1. BLOCKER — step 4b commits after the battery and 4c | **CONFIRMED, accepted** | [V] Task 15 order is step 4 (`:2895`) → **4c (`:2945`)** → **4b (`:3074`)** → step 5 (`:3145`) → step 6 (`:3181`), and 4b's own heading says "and commit the result before Gate B". So a new WIP commit lands **after** 4c certified a head, and [R] the first-pass path runs no complete rerun before step 6 although a zero-finding first pass may close. A 4b repair to a shipped prompt or hook is then absent from 4c's merge result entirely.
2. BLOCKER — 4c's `HEADID` and step 6's reviewed head are not tied | **CONFIRMED, accepted** | [V] `HEADID` is an operator placeholder at `:2959`; step 6 independently runs `git rev-parse HEAD > .context/loop-rule-reviewed-head` at `:3188`. Nothing compares them. [R] A ref move between the two lets 4c certify one candidate while Gate B reviews another.
3. MAJOR — 4c has no durable record | **CONFIRMED, accepted** | [V] 4c only prints; the step 5 / 7b region (`:3145`–`:3260`) contains **zero** mentions of 4c, so the "result goes into the closing commit body" claim I wrote has **no mechanism behind it**. [R] The closing body can omit 4c or carry a stale result. Note the shape: this is the same defect class as pass 48's marker — new state with no record, recovery or cleanup rule.
4. MAJOR — the synthetic merge reverses CI's parent direction | **CONFIRMED as described, accepted** | [V] 4c checks out `HEADID` (`:2968`) and merges `BASEID` into it (`:2980`); CI's `refs/pull/N/merge` is the base with the head merged in. [R] With direction-sensitive merge behaviour the trees can differ. Reviewer's own confidence is `medium` and I did not construct a case where the trees actually diverge — **the direction mismatch is established, a resulting tree difference is not**.
5. MINOR — the plugin-diff pipeline is unguarded | **CONFIRMED, collected** | [V] `:2997` embeds `git diff --name-only … \| tr` in a command substitution, so the status is `tr`'s and a failed diff yields a silent empty evidence line. This is the exact defect class passes 43 and 44 swept for — **and I reintroduced it in new code**.
6. NIT — the `mktemp -d` directory is never removed | **CONFIRMED, collected** | [V] The only `trap` match in the plan is the English word in unrelated prose at `:1798`. No cleanup on any branch.

## Provenance of these findings, which is the uncomfortable part

**Four of six are in machinery I added in the last two revisions** (findings 3, 4, 5, 6 are all step
4c; finding 2 is 4c's interface to step 6). **Findings 5 and 6 are defect classes this cycle had
already swept for** — an unguarded pipeline whose status a following command consumes, and state
created without a cleanup rule. Writing new code reintroduced both. That is regeneration from the
repairs, not discovery in unswept territory, and it should be read that way.

**Finding 1 is the most consequential and is not about 4c's internals at all** — it is about where 4c
sits in the sequence. Adding a verification step in the wrong place bought less than it appeared to.
