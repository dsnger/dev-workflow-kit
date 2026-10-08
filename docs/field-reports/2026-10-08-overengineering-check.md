# Over-engineering check — report

Delivery report for `docs/superpowers/stories/2026-10-08-overengineering-check-story.md` (story AC-9).
The design, the inventory and the reasons for each fate are in
`docs/superpowers/specs/2026-10-08-overengineering-check-design.md`. This report links to them and
does not repeat them.

## Results

- **Already covered:** spec §3 lists the existing rules, gates and checks by phase, with citations.
  Most of them are instructions or reviewer judgement. One is mechanical: check 4e, the size of the
  scaffolded `CLAUDE.md` template.
- **Closed:** this repository's own `CLAUDE.md` + `AGENTS.md` had no size check. Check 4g in
  `scripts/check-invariants.sh` now fails when the two exceed 150,000 characters, a budget set for
  this repository (spec §5).
- **Not closed:** every other candidate and its fate is in spec §4. The method statement at the loop
  halt and the proportionality question were routed to their existing `todos.md` rows. A Gate A
  question on unneeded scope is not evidenced; Gate B already asks one, through the pinned
  reviewer's templates (spec §3). Canvas's `AGENTS.md` is problem evidence noted at
  G3c; trimming it is canvas's own work.
- **Owners of related items**, unchanged and without a second entry: plan form and the spec/plan
  roles stay with G3a; effort metrics and "was it worth it" stay with "Review-loop usefulness —
  metrics, scoring and calibrated thresholds"; the method statement stays with "The arms-race
  remedy exists as an observation and not as a procedure"; proportionality stays with
  "EXPERIMENTAL — proportionality for findings whose subject is a test instrument" (all in `todos.md`).
- **Earlier recommendations** relied on, with their verdicts: spec §7.

## Evidence

- **Counter-check on the historical contents**, run 2026-10-08:
  - Setup: a copy of the tree at `f5d7740` (`git archive f5d7740`) with only `CLAUDE.md` and
    `AGENTS.md` replaced by `git show b18e7db:<file>`; then `sh scripts/check-invariants.sh` in it.
    First run at `9655adc`, a commit later folded into `f5d7740`, with the same result.
  - Result: exit 1, with 4g's line as the only failure: `repo instruction size: CLAUDE.md + AGENTS.md
    is 151246 characters, over the 150000 budget.`
  - The same check on the unmodified copy printed `invariant checks: ok`, exit 0.
- **Tests:** `sh scripts/check-invariants.test.sh` reported `all passed (233 assertions)` under `sh`
  and under `dash`. That is 14 new 4g cases (3 accept, 11 reject) and the 219 earlier ones, unchanged.
  - The reject cases cover: over the budget (summed, single file, and through a symlink to a readable
    file, which is counted like its target); a missing file, a directory, an unreadable file
    (non-root); no UTF-8 locale; a failed read; an empty count; a non-numeric count.
- **Mutation:** with the 4g block deleted, exactly the 11 4g reject cases flipped, and no accept case.
  4a–4f were re-measured after the shared fixture change: 20, 22, 20, 22, 7, 32, unchanged. The
  record is in `scripts/check-invariants.test.sh`.

## Size of the two files, in characters

| | `CLAUDE.md` | `AGENTS.md` | total |
|---|---|---|---|
| `b18e7db` (the overrun) | 127,835 | 23,411 | 151,246 |
| `a9743c4` (before) | 11,929 | 26,523 | 38,452 |
| after this delivery | 11,929 | 27,007 | 38,936 |

`AGENTS.md` grew by 484 characters: the 4g row label and its boundary paragraph.

## What a later reader can observe

- A future 4g failure.
- `scripts/status-view.py`'s "rule files" group, in bytes and lines.

Both are observations. Neither shows a benefit, and this delivery claims no saving in complexity,
scope or review effort.

## Limits

- 4g measures two files at fixed paths. It does not measure:
  - the user's own instruction files;
  - memory;
  - plugin, skill and hook text;
  - `.claude/review-gates.md`;
  - any later import.
- The budget is this repository's. It is not a client's current limit.
- Nothing reaches initialized projects: no file under `plugins/` changed, and 4g, like 4e, runs only
  in this repository.
- A size budget limits size, not complexity.
