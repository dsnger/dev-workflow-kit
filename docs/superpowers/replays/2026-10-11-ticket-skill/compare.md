# Compare — per run, per check

Mechanical rows (`M`, `V`) are the verbatim `checks.sh` output in `evidence/*-runs.md`, beside each run's init excerpt (model, plugin path and version, the `dev-workflow` skills loaded) and tool-call count. Every plugin copy's version (0.23.0, 0.24.0, 0.24.0) and both candidate skill hashes were checked against their commits before the runs. Reading rows
(`R`) were applied by the author to each valid run; the evidence column points at what was read.
✓ = pass, ✗ = fail, — = not a check of that case.

## Baseline — intake on 0.23.0 (`6b15993`), the counterfactual

| Run | V | M1 | M2 | M6 | What intake produced |
|---|---|---|---|---|---|
| K1-r1 | ✓ | ✗ (expected) | ✓ | — | a question round and a proposed profile; no file |
| K2-r1 | ✓ | ✗ (expected) | ✓ | — | a question round (which part of 41 min, what target); no file |
| K3-r1 | ✓ | — | ✓ | ✓ | named AC-1 and the amendment route, asked for the decision; no file |

No baseline run produced a ticket file. 0.23.0 ships no ticket skill; three runs show what intake did with these reports, not that a ticket could never appear.

## Set 1 — skill sha256 `1bdaa56b…e154` (`evidence/set1-skill.md`), FAILED

| Run | V | M1–M5 / M6 | R1 | R2 | R3 | R4 | R5 | R6 | R7 |
|---|---|---|---|---|---|---|---|---|---|
| K1-r1…r3 | ✓ | ✓ | ✗ category `regression` (R1 as then written required `bug`) | — | ✓ log line verbatim | ✓ failing test at nearest seam; red: `failed` with `published=true` | ✓ build hand-off | — | — |
| K2-r1…r3 | ✓ | ✗ no ticket file (M1, M3, M4, M5) | — | ✗ | ✗ no ticket | ✗ no ticket | ✗ no ticket | — | — |
| K3-r1…r3 | ✓ | ✓ | — | — | — | — | — | ✓ | — |
| L-r1 | ✓ | ✓ | — | — | — | — | — | — | ✓ |

**Cause 1 (K1, the oracle):** the K1 prompt states a prior good version ("1.4.1 did not do this"),
so `regression` is the correct category; R1 pinned `bug` alone. Answered by the spec amendment of
2026-10-12 (spec §3 change record; Gate-A cycle aavbeacgc3): R1 accepts `bug` or `regression`.
Set 1 is not rescored.

**Cause 2 (K2, the skill):** all three runs printed the intake Flow hand-off, reasoning that no
commitment names an export duration, so "faster" would be a new commitment. Answered by a skill-text
correction inside spec §2.3 step 4 (decision of the orchestrator, 2026-10-12 10:00): an improvement
that sets no new limit and breaks no commitment stays inside the commitment of the feature it
improves and quotes that feature's criterion; a missing target is a `needs-info` question.

## Set 2 — skill sha256 `52b78e5b…3d64` (`evidence/set2-skill.md`), PASSED

| Run | V | M | R1 | R2 | R3 | R4 | R5 | R6 | R7 |
|---|---|---|---|---|---|---|---|---|---|
| K1-r1 | ✓ | ✓ | ✓ regression · blocker · ready; AC-3 + invariant 1 | — | ✓ log line verbatim | ✓ failing test at nearest seam; red: `failed` with `published=true` | ✓ build hand-off | — | — |
| K1-r2 | ✓ | ✓ | ✓ same | — | ✓ | ✓ same loop; red: `failed` yet `published=true` | ✓ | — | — |
| K1-r3 | ✓ | ✓ | ✓ same | — | ✓ | ✓ same loop; bisection named as fallback | ✓ | — | — |
| K2-r1 | ✓ | ✓ | — | ✓ improvement · needs-info; AC-1 quoted; questions for target and severity; no duration invented | ✓ both log lines verbatim | ✓ failing test, first entry; red: processing time above the target (target a reporter question) | ✓ questions, not-ready line, no build hand-off | — | — |
| K2-r2 | ✓ | ✓ | — | ✓ same; three questions | ✓ | ✓ same | ✓ | — | — |
| K2-r3 | ✓ | ✓ | — | ✓ same; four questions | ✓ | ✓ throwaway harness, why earlier entries cannot go red without a target | ✓ | — | — |
| K3-r1…r3 | ✓ | ✓ (M2, M6) | — | — | — | — | — | ✓ amendment hand-off for the export story, AC-1 named, stopped | — |
| L-r1 | ✓ | ✓ (M2, M6) | — | — | — | — | — | — | ✓ needs-triage `(none)`; needs-info T-2, T-4; ready T-5, T-3; T-1 absent; no `needs repair` |

**After set 2 the candidate text changed** (Gate-B pass-1 to pass-3 repairs and the spec §2.3 step 7 amendment; the PR head's skill sha256 is in the PR body): Flow step 7's numbering scan (every local and remote-tracking branch, each ref passed as a quoted variable, instead of a spliced default-branch name; a failed listing or read stops without writing), the example's severity (`major` → `blocker`) and the `list` footer (repair guidance). No set 3 was run, by Daniel's decision of 2026-10-12 11:17; set 2 measured the text before these repairs.

**R4 on `needs-info` K2 tickets:** read under the collected spec Minor (cycle ocgrixmmce pass 3:1):
each names the observation that goes red against the target and asks the reporter for the target.

**Result:** every valid run of set 2 passes every check of its case (10 of 10). Against the
baseline: on 0.23.0 the same three reports produced no ticket in three runs; on the candidate, K1 and K2 produce a
committed ticket and K3 the amendment hand-off with nothing written.
