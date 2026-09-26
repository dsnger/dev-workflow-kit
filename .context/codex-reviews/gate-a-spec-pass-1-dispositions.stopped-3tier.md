# Gate A — spec — pass 1 dispositions

Cycle: reviewer-availability fallback ladder (story 2026-08-13, spec 2026-08-14).
37 findings returned; 4 BLOCKER + 28 MAJOR actioned, 5 MINOR collected.
Severity enum held on first live use of rider (b) — no out-of-enum token.

## Blocker

1. ACCEPT — correct and the most serious. Invariant 3's content-derived validity is
   delivered by the hook's fingerprint, which is only written on `mcp__codex__review`
   calls. Tier 2 makes none, so no fingerprint exists to invalidate; silencing is not
   even required for the hole to open. Needs a content-identity record + pre-close
   equality check. NEEDS DECISION (form of the record).
2. ACCEPT — real structural hole I introduced. The WIP body is a Gate-B artifact; both
   Gate-A cycles complete before any WIP commit exists, so a Gate-A tier-2 pass has no
   durable record at all. Candidate fix: the spec/plan docs commit body is the Gate-A
   marker's home, carried forward into the implementation cycle's closing body.
3. ACCEPT — already-initialized projects keep their copied CLAUDE.md with the old
   prohibition, so 0.9.0 ships them no ladder. Overlaps the parked "§5 version stamp"
   row, which exists because this is a design of its own. NEEDS DECISION (solve here vs
   scope + cross-reference).
4. ACCEPT — rider (a) introduces this: two calls, no bound snapshot, both files
   structurally valid, potentially different diffs, counted as one pass. A provenance
   false ✓ in the replacement for the mechanism that had one.

## Major — accepted, mechanical or wording fixes

18. ACCEPT (wording) — "closed set" vs accepted out-of-enum tokens is a genuine
    contradiction in how I wrote it, not a reversal of the decided behaviour. Fix by
    separating canonical syntax from a tolerant normalization rule.
19. ACCEPT — §9 requires the mapping be recorded; §12 says the file may not exist. The
    design both requires and disclaims its own audit evidence. Make dispositions
    conditionally mandatory when normalization occurs.
33. ACCEPT (MINOR, fixed anyway) — §1 says "three clean passes are required"; §5 requires
    min 3 passes with only the FINAL one clean, plus a zero-finding early exit. A factual
    misstatement of the procedure this design promises to preserve.
34. ACCEPT (MINOR, fixed anyway) — "Tier 1 … unchanged in every respect" is contradicted
    by riders (a) and (b) in the same document. Narrow to reviewer independence.

## Major — accepted, structural

2, 6, 10, 22 are the four that change the shape of the design rather than its wording.

6.  ACCEPT — and it contradicts my own §1. §1 says §2.13 does not reach the mid-flight
    case; §3 then lists tier 3 as "the documented human exception, unchanged". For
    mid-flight, tier 3 as described does not exist. NEEDS DECISION (define vs remove).
7.  ACCEPT — no entry/exit predicate for "unavailable"/"temporary". Without one the
    fallback is available whenever review is inconvenient, which is the standing
    arrangement the narrowing forbids.
8.  ACCEPT — the safety argument rests on "human-attended" and nothing requires a human.
    The reviewed actor can silence the reminders and authorize its own weaker reviewer.
9.  ACCEPT — no canonical marker schema, so "carried by name" cannot be validated and two
    readers produce different histories that both satisfy the prose.
10. ACCEPT — the story disclosed per-pass AND per-cycle; the design dropped the per-pass
    surface without accounting. Exactly the decision-procedure Don't. NEEDS DECISION
    (define a per-pass record vs amend the story with accounting).
11. ACCEPT — a Gate-B-shaped post-merge review cannot repay a missed Gate-A design review.
12. ACCEPT — "merge-base range" is not a durable identity after squash or later merges.
13. ACCEPT — the debt row must not close on a result that still carries Blocker/Major.
14. ACCEPT — "no new waiver mechanism" is an enforcement overclaim; the profile override
    vocabulary is not defined for this use. AGENTS.md overclaim Don't.
15. ACCEPT — my singular max rule contradicts §5's explicit multi-story rule that each
    profiled story satisfies its own obligations with no winning max.
16. ACCEPT — `full` stays supported with its demonstrated two-writer loss, so the rider
    closes the backlog row without closing the defect. NEEDS DECISION (prohibit vs keep
    row open).
17. ACCEPT — pass pairing and the shared single recovery attempt are undefined once one
    pass is two calls.
20. ACCEPT — and this one is an evidence defect, not a doc defect. The proposed check
    passes or fails identically before and after the prompt change, so it cannot
    discriminate. Fails CLAUDE.md's own "confirm the wiring could have produced the
    failing observation" rule.
21. ACCEPT — the verification proves hook-invisibility, not that a tier-2 pass is
    identifiable from main. It can pass while disclosure is absent or stale.
22. ACCEPT — silencing every reminder is the dangerous direction under invariant 2 while
    the design claims the invariant is untouched. NEEDS DECISION (scope the invariant
    with rationale vs retain one visible degraded reminder).
23. ACCEPT — touching a sentinel file states no reason; no content schema is given.
24. ACCEPT — no procedure for availability returning mid-cycle, mixed-tier pass sets, or
    which tier the closed cycle is finally recorded as.
25. ACCEPT — the gate prompts are Codex-facing and open with a Codex-directed skill
    instruction; tier 2 executes on Claude. Prompt-standard item 1.
26. ACCEPT — "fresh" and "same-family" are unverifiable as written; no named invocation,
    no context-isolation guarantee, no behaviour when the configured subagent differs.
27. ACCEPT (security lens) — a reviewer reading repo content is never told to treat that
    content as data rather than instructions. Prompt injection steers the weaker reviewer.
28. ACCEPT (security lens, and the sharpest of them) — a "fresh" reviewer can read
    `.context/` and inherit prior passes' conclusions through the filesystem, collapsing
    the 3-pass loop into one answer repeated.
29. ACCEPT — diff-as-prompt-text has no truncation detection; `mcp__codex__review` reads
    the range itself and cannot silently truncate. A clean findings file can certify a
    lossy diff.
30. ACCEPT — §5's several-WIP `git reset --soft` collapse path is omitted from my
    carry-forward chain, so markers in earlier WIP bodies are destroyed outside the named
    hop.
31. ACCEPT — the obligation row must exist before the final pass and inside the reviewed
    snapshot, or it lands unreviewed.
32. ACCEPT — a late tier-1 result can overwrite a valid tier-2 findings file, and every
    shape check still passes.
5.  ACCEPT — the file-first protocol requires the reviewer to WRITE; the design grants
    only read. NEEDS DECISION (narrow write capability to the one path vs parent-mediated
    write, which reintroduces the truncation risk file-first exists to prevent).

## Minor — collected, not iterated

35. Parked-row trigger has no threshold or owner.
36. No rollback procedure for an active degraded cycle or outstanding debts.
37. The "two tool names" are never actually named, and routing is version-dependent.

## Note

No finding was dismissed. Six carry NEEDS DECISION and are going to Daniel before pass 2,
because each leads to materially different work rather than a different sentence.
