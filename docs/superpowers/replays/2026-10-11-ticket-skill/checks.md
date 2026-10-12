# Checks (written and committed before the first run)

Spec §3's table, split by kind. `M` rows are scripted in `runner.md` (`checks.sh`); `R` rows are
reading checks the author applies to each valid run, quoting the evidence in `compare.md`. A run
passes when every row of its case passes.

## Run validity (scripted, row `V`)

Valid when the init record lists exactly one `dev-workflow` plugin, at the variant's copy, model
`claude-opus-5-5`, and the run did not end in an error before its first tool call. An invalid run is
reported and re-run once; every other run counts, a budget stop included. Quotas: candidate 3 × K1,
3 × K2, 3 × K3, 1 × L; baseline 1 × each of K1–K3. A case still short after its re-runs makes the
set **incomplete**: reported and stopped, never evaluated on the reduced set. Before each set the
plugin copy's version and its `skills/ticket/SKILL.md` sha256 are checked against the measured
commit (candidate) or `6b15993` (baseline).

## Mechanical rows

| Row | Check | Cases |
|---|---|---|
| M1 | exactly one new file, `docs/superpowers/tickets/<date>-T6-<slug>.md`; T-1…T-5 unchanged; clean tree | K1, K2 |
| M2 | no new or changed story or spec (committed or not) | K1, K2, K3, L |
| M3 | exactly one header line with one valid category, one valid state, severity in the closed set or `unknown — <reason>` | K1, K2 |
| M4 | exactly one `**Story:**` line, naming the export story in the parsed form | K1, K2 |
| M5 | one commit, touching only the ticket file | K1, K2 |
| M6 | tree and history unchanged (no commit, no file) | K3, L |

## Reading rows

| Row | Check | Case |
|---|---|---|
| R1 | category `bug` or `regression` (spec §3, changed 2026-10-12), severity `blocker`, state `ready`; the commitment quoted is AC-3 or invariant 1, with its source | K1 |
| R2 | category `improvement`; the commitment quoted is one the change stays inside, with its source; state `ready`, or `needs-info` with a reporter question for each `unknown` readiness field; no duration target appears that the prompt does not state | K2 |
| R3 | the evidence (log line / measurement) is in Observed verbatim; no field invents a fact absent from the prompt | K1, K2 |
| R4 | Brief names a feedback loop from the list, why earlier entries were not chosen, and the observation that is red before the fix | K1, K2 |
| R5 | a `ready` ticket ends with the build hand-off; a `needs-info` one ends with its questions and no build hand-off | K1, K2 |
| R6 | output names intake's amendment route for the export story and AC-1 as the changed commitment, and stops | K3 |
| R7 | buckets in order needs-triage `(none)`, needs-info T-2 then T-4, ready T-5 then T-3; T-1 absent; no `needs repair` heading | L |

R4 applied to a `needs-info` K2 ticket: the collected spec Minor (cycle ocgrixmmce pass 3:1)
applies — a ticket missing an agreed target may name the observation as the reporter's open
question; `compare.md` states how each such run was read.

## Baseline (counterfactual)

Each baseline run records V, M1 (expected FAIL: no ticket file can be produced on 0.23.0), M2 and
what intake produced (a story, a question round or something else), quoted in `compare.md`.
