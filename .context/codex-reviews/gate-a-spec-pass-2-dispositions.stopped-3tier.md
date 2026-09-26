# Gate A — spec — pass 2 dispositions

Cycle: reviewer-availability fallback ladder. 39 findings (4 BLOCKER, 33 MAJOR, 2 MINOR).
Severity enum held again — no out-of-enum token, second live use of rider (b).

## The pass-2 headline

Pass 1 found holes in the *design*. Pass 2 finds that the **mechanism cannot execute as
written**, and that one premise I gave Daniel — which he then decided on — is false
against the shipped text. Findings 1, 2, 3 and 5 are the ones that matter; the rest are
mostly downstream of them or ordinary rigour.

## Blocker

1. ACCEPT — and self-inflicted in the pass-1 revision. I fixed the diff-truncation finding
   by having the reviewer produce the diff itself from `baseSha`/`headSha`, while in the
   same section limiting it to Read/Grep/Glob. None of those can compute a git range. Gate
   B tier 2 is currently unexecutable. REOPENS the capability question.
2. ACCEPT — "write to exactly one path" is stated as a capability and is not one. A
   prompt-only design has no path guard; Claude Code's Write tool grants general access.
   The containment claim is false as written. REOPENS Q2 (prompt-only vs shipped agent
   definition).
3. ACCEPT, and it is the sharpest finding of either pass — a non-fork subagent loads the
   repository's CLAUDE.md hierarchy as instructions, so "only the wrapper supplies
   authoritative instructions" is false before the reviewer ever reads the artifact. The
   trust boundary I wrote does not exist.
4. ACCEPT — genuinely self-referential and mine: §6 requires the debt row inside the
   snapshot before the final pass; §7 requires that row to name the landed SHA, which does
   not exist until the commit is written and changes again under squash. Needs a stable
   pre-land identity plus a post-land reconciliation step.

## Major — the premise reversal

5.  ACCEPT, and it overturns a decision already taken. I told Daniel that `.off` always sat
    outside invariant 2, and he chose to amend the invariant on that basis. CLAUDE.md's own
    §5 says of `.off`: "**the gates still apply**". So `.off` has always silenced reminders
    while leaving the gates in force; prescribing it as the posture for running *weaker
    gates* is a substantive change to what it means, not a scope clarification. The
    amendment as drafted is the disguised-exception shape the AGENTS.md Don't names.
    MUST GO BACK TO DANIEL — his decision rested on my false premise.

## Major — accepted, mechanism and procedure

6.  ACCEPT — `.off` is workspace-global; one outage authorization silences unrelated commits
    and unrelated cycles. Prescribing a global sentinel as if it were cycle-scoped.
7.  ACCEPT — no handling for a pre-existing `.off` (init-time, user opt-out, another cycle);
    entry overwrites its meaning and exit deletes it unconditionally.
8.  ACCEPT — no concurrency rule; one cycle's exit can re-enable another's workspace.
9.  ACCEPT — nothing requires an availability re-check, so tier 2 becomes the standing
    arrangement by never looking.
10. ACCEPT — the two entry predicates conflict: "vendor known unavailable" permits no call,
    yet the recovery attempt must be spent.
11. ACCEPT — tier 3's "unavailable **or unwarranted**" makes the broadest fail-open tier
    reachable through an uncheckable adjective. "Unwarranted" should go.
12. ACCEPT — tier 3 closes with no passes, yet §7 calls it a clean cycle and §9 demands a
    per-pass line for it. Incoherent; tier 3 needs its own no-pass closure shape.
13. ACCEPT — the marker schema cannot truthfully represent tier 3 (no reviewer model, no
    pass count, no final-pass cleanliness). Needs per-tier schemas.
14. ACCEPT — human authority is a prose block the agent can write. §15 admits it; the design
    adds no live-confirmation step. Injection or agent error fabricates the sole control.
15. ACCEPT — entry authorization lives in an ignored file that is deleted on exit, so `main`
    can show degradation was claimed but never that a human authorized it.
16. ACCEPT — the inherited recovery procedure is MCP-specific (`sessionId`,
    `specSessionId`/`qualitySessionId`); tier 2 runs through a different surface entirely
    and has no valid one-attempt procedure. Resuming may also break fresh-context isolation.
17. ACCEPT — §6's identity rule is scoped to tier 2, but rider (a) changes tier 1 too, so
    tier-1 sequential pairs can still review different content.
18. ACCEPT — `git status --porcelain` empty output without checking exit status: a git error
    reads as a clean tree. Exactly the false ✓ the section exists to prevent.
19. ACCEPT — endpoint clean-checks do not exclude a concurrent writer mutating and restoring
    between them.
20. ACCEPT — tier-switch cleanup covers only a prior tier-1 task, not tier-2 agents or any
    other writer to the slot.
21. ACCEPT — "each pass records baseSha and headSha" names no file, actor or acceptance
    check, and the findings grammar forbids metadata lines. Needs a provenance record.
22. ACCEPT — rider (a) prose and its accounting table give two different recovery graphs.
23. ACCEPT — normalization vs story AC 6's "closed set of permitted tokens". Either make
    non-enum INCOMPLETE or amend the story. MUST GO BACK TO DANIEL — he decided the
    behaviour; the story wording is what conflicts.
24. ACCEPT — who writes the required per-pass dispositions line, given the reviewer may write
    only the findings path? Unreconciled.
25. ACCEPT — the three schemas are field lists with no literal examples or delimiters;
    prompt-standards item 4.
26. ACCEPT — "the re-review ran" specifies no floor, no final-clean rule, no disposition
    authority. A token pass could discharge the compensating control.
27. ACCEPT — nothing detects availability's return, so the debt trigger is observationally
    empty.
28. ACCEPT — rebase-merge and cherry-pick change the landed SHA outside the squash rule.
29. ACCEPT — the squash hop depends on a merge-time actor the design never assigns.
30. ACCEPT — the old-condition inventory is partial. §5's "gates still apply", "the gate
    itself is not optional", loop-closure and incomplete-pass conditions are untouched by my
    tables. The AGENTS.md rule wants the complete inventory.
31. ACCEPT — more falsified sites: `plugin.json`'s description, marketplace metadata,
    README's product summary. Search the claim, not the phrase — the repo's own recipe.
32. ACCEPT — the evidence covers one happy Gate-B path; Gate A, tier 3, mixed tiers,
    recovery, concurrency, multi-WIP, real squash and the debt lifecycle are untested.
33. ACCEPT — restates B3 from pass 1 at product level: the installed user base is exactly the
    population the incident hit. Daniel scoped this out; finding 33 argues the release claim
    must then narrow too. Worth honouring in the wording.
34. ACCEPT — the slot-collision fix should land in THIS change, since the new protocol makes
    per-pass records load-bearing. Stronger than my "park it" plan, and it already bit twice
    this cycle.
35. ACCEPT — no rollback path; reverting the prompts while `.off` persists leaves an older
    §5 saying gates apply with reminders globally silent.
36. ACCEPT (security lens) — failure shapes, causes and vendor diagnostics go into commit
    history with no redaction rule; auth errors can carry account identifiers or endpoints.
37. ACCEPT — tier 3 is described as existing practice and "no new waiver mechanism", but
    init-time gateless closes no active gate and a profile override changes evidence mode
    rather than authorizing zero-pass closure. It IS a new exception and should say so.

## Minor — collected

38. "HEAD is the complete content identity" outruns the comparison — ignored files, untracked
    content. The gate-proof wording rule, and I wrote it in the section that exists to
    prevent exactly this.
39. Marker dedup has no identity key.

## Verdict

Nothing dismissed across two passes: 71 findings, 69 actioned, 0 rejected. The design is
not converging at the mechanism layer — pass 2's blockers are about whether tier 2 can run
at all, which pass 1 never reached because the design was too vague to be tested that way.
Three items go back to Daniel: finding 5 (his invariant-2 decision rested on a premise the
shipped text contradicts), findings 1-2-3 (prompt-only cannot deliver the stated
containment, reopening Q2), and finding 23 (story AC 6's wording).
