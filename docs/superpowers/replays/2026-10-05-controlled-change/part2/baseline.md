# Review-loop usefulness assessment (vision step 2c, part 2) — Story

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
For every closed review cycle, a maintainer can read an assessment along the vision §4
dimensions — yield, repair effects, effort and coverage — with an explained traffic light: which
evidence put the cycle at that colour, and which evidence was missing. The assessment
distinguishes direct product work from plan/execution machinery and from non-operative material,
so loops spending effort far from the product are flagged earlier. It informs a human; it changes
no gate, floor, severity or pass-validity rule.

## 3. Acceptance criteria
- [ ] For every closed cycle in the history read, the assessment shows the four dimensions
      (yield, repair effects, effort, coverage) separately, each with its value or an explicit
      "unknown" and the reason it is unknown. Unknown is never shown as zero or as a good result.
- [ ] Each cycle gets a traffic light (green / amber / red) with a one-line explanation naming the
      evidence that decided it. No composite numeric score is shown.
- [ ] The thresholds behind the colours are stated in one place, and each cites the recorded cycles
      it was checked against (at least the cycles named in the vision §4 calibration cases and the
      field reports under `docs/field-reports/`). A threshold that cannot be checked against recorded
      data is marked provisional.
- [ ] A cycle's product distance (direct product, plan/execution machinery, non-operative) is shown,
      and how it was determined. Where it cannot be determined it is shown as unknown, not defaulted
      to low risk. More distant work reaches amber earlier at the same effort.
- [ ] A cycle with few or zero findings is not marked red for that reason alone, and a cycle with
      many findings is not marked green for that reason alone.
- [ ] The assessment says what it cannot establish (for example: whether a finding was true, causal
      attribution of repair effects, cost in money), in the report itself.
- [ ] Building the assessment changes no gate, hook, floor, severity rule, pass-validity rule or
      commit-body record format, and writes no file outside the existing per-clone telemetry
      location.

## 4. Affected AGENTS.md invariants
- `## Don'ts` — "**Never describe what a gate proves without checking what it actually compares.**"
- `### Packaging` — "5. **Every version pinned exactly.**"
- `### Packaging` — "12. **A plugin change requires a version bump.**" (binds only if anything
  ships in the plugin; placement is repo-local, like parts 1 and 2b)

## 5. Open questions
- Which recorded cycles form the calibration sample, given that most findings files live only in
  local `.context/` archives and the commit-body curves are author-written?
- How is a finding "confirmed" for the yield dimension when dispositions files are optional and
  sparse?
- How is a cycle's product distance determined from what the records hold?

## 6. Suggested size
story — one repo-local report over the evidence parts 1 and 2b already produce; one spec → plan → PR.
