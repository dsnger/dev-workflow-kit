# T-4 — Queue order looks wrong after the 1.4.0 deploy

**Category:** regression · **State:** needs-info · **Severity:** unknown — no job order was captured · **First seen:** 1.4.0
**No story:** the commitment comes from AGENTS.md Key invariant 2; Gate B runs unprofiled (floor 3)
**Feature:** export queue, AGENTS.md § Key invariants › Exports 2

## Commitment
"The queue is strictly ordered. Jobs run in the order they were queued; no job skips ahead." — AGENTS.md § Key invariants, 2

## Observed
An operator thinks a later job finished first — evidence: unknown — no worker log was attached

## Expected
Jobs run in queue order — source: AGENTS.md § Key invariants, 2

## Repro
1. unknown — no job ids were given

## Brief
- Fix scope: worker job ordering.
- Out of scope: notification timing.
- Feedback loop: bisection harness — the behaviour may predate 1.4.0, and no single test case is known.
- Read first: AGENTS.md § Key invariants › Exports, § Architecture (worker/).

## Questions for the reporter
- Which two job ids ran out of order, with their worker log lines?

## Log
- 2026-10-03 · created · needs-info
