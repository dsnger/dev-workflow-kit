# Review-loop warning light (vision step 2c, part 2) — Story

**Date:** 2026-10-02 · **Size:** story
**Risk:** standard · **Security:** none · **Validation:** battery+check

## 1. Problem statement
Part 2 of the epic `docs/superpowers/stories/2026-10-02-telemetry-and-review-loop-usefulness-story.md`.
Review loops are judged only by finding counts. The kit now records each cycle's curve
(`scripts/ledger-metrics.py`) and each gate call's duration and tokens (`scripts/run-analytics.py`),
but nothing puts these together into a judgement of whether a loop was worth its effort. The
vision (`docs/superpowers/specs/2026-08-30-dark-factory-vision.md` §4) records that few findings do
not establish poor usefulness and many findings do not establish high usefulness. It also records
that the more indirect a loop's evidenced effect on the product, the earlier further review effort
must be reassessed (Daniel, 2026-09-17). Today a maintainer cannot see, per cycle, what a loop
found, what its repairs caused, what it cost and what it did not cover — so a 65-pass loop and a
3-pass loop look alike until someone reads every commit body.

## 2. Desired outcome
**Narrowed 2026-10-03 (Daniel): this part delivers a warning light, not a usefulness assessment.**
For every closed review cycle, a maintainer can see whether the recorded numbers reach a warning
threshold that calls for **reassessing further review effort** — a loop running far past its
floor, or reporting more material findings after a pass than before it — together with the
evidence behind the warning and what the data could not show. A warning means "reassess", never
"waste proven"; the absence of a warning means "no threshold reached in the available data",
never "useful". Where the data cannot settle the warning state, the report says so instead of
showing no warning. The full usefulness assessment the epic and the vision §4 describe — whether a
loop was worth its effort — stays open in the epic and in `todos.md`. The report informs a human;
it changes no gate, floor, severity or pass-validity rule.

## 3. Acceptance criteria
- [ ] For every closed cycle in the history read, the report shows the recorded evidence behind
      the warning light (passes against the floor, material findings per pass, increases between
      passes, stored effort), each with its value or an explicit "unknown" and the reason.
      Unknown is never shown as zero.
- [ ] Each cycle gets exactly one of four states, each with a one-line explanation naming the
      evidence that decided it: **red** and **amber** (reassess, with a different urgency),
      **no warning** ("no threshold reached in the available data; usefulness unknown"), and
      **not determinable** (missing data could change the state). A threshold already reached
      stays visible even when other data is missing. No green and no numeric score are shown.
- [ ] Each warning threshold is stated in one place and checked against the recorded cycles and
      the field reports under `docs/field-reports/`, each case with its expected state, and the
      vision §4 calibration cases are walked through. A case the warning light cannot distinguish
      is listed as a limit, not counted as passed.
- [ ] A cycle's product distance is shown only where the changed files establish it (a shipped
      plugin path, or an executable of this repository); otherwise it is unknown, with "classify
      by hand". Unknown is never treated as low risk.
- [ ] A cycle with few or zero findings is not warned about for that reason alone.
- [ ] The report states what it cannot establish (for example: whether a finding was true, that
      a repair caused an increase, what the reviewer examined, whether the loop was worth its
      effort, cost in money), in the report itself.
- [ ] Building the report changes no gate, hook, floor, severity rule, pass-validity rule or
      commit-body record format, and it writes no file.

**Scope narrowed 2026-10-03 (Daniel, on the reviewer's assessment
`.context/sparring/20261003-104113-loop-usefulness-warning-assessment.md`), after Gate-A spec pass 1
found that a green light would rest on evidence the report does not read.** What changed:

| Earlier criterion or promise | Fate |
|---|---|
| Outcome: an assessment along yield, repair effects, effort and coverage | **Narrowed** to a warning light over recorded counts and stored effort. Confirmed distinct yield, repair origin and reviewed scope are **deferred** to the epic's open usefulness assessment. |
| Criterion 1: four dimensions with values | **Narrowed** to the recorded evidence behind the warning; the dimensions the records cannot supply are shown as unknown. |
| Criterion 2: green / amber / red | **Replaced** by red / amber / no warning / not determinable. Green is dropped: missing evidence must not become a green assessment (vision §4). |
| Criterion 3: thresholds calibrated against recorded cycles and field reports | **Kept**, with indistinguishable cases listed as limits. |
| Criterion 4: product distance, earlier amber for distant work | **Narrowed**: distance only where the changed files establish it; otherwise unknown. |
| Criteria 5–7 | **Kept**, reworded for the warning light. |
| Whether a loop was worth its effort | **Deferred** to the epic (criterion 5) and `todos.md`. |

## 4. Affected AGENTS.md invariants
- `## Don'ts` — "**Never describe what a gate proves without checking what it actually compares.**"
- `### Packaging` — "5. **Every version pinned exactly.**"
- `### Packaging` — "12. **A plugin change requires a version bump.**" (binds only if anything
  ships in the plugin; placement is repo-local, like parts 1 and 2b)

## 5. Open questions
- Which recorded cycles form the calibration sample, given that most findings files live only in
  local `.context/` archives and the commit-body curves are author-written?
- How is a cycle's product distance determined from what the records hold?

## 6. Suggested size
story — one repo-local report over the evidence parts 1 and 2b already produce; one spec → plan → PR.
