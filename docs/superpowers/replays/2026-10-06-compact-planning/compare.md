# Compact planning replay — results (2026-10-06)

Story: `docs/superpowers/stories/2026-10-06-compact-planning-context-handover-story.md` AC-12.
Rubric, removal and task were written and committed before any run (`rubric.md`, `removal.md`,
`TASK.md`, in a work-in-progress snapshot that the branch's Gate-B close later squashed). That
snapshot is not in `main`'s history, so the ordering rests on this record and the session that
made it, not on a resolvable commit. One run per variant; nothing was repeated.

## Setup actually used

Two fixture directories, identical except `CLAUDE.md` (`fixture/CLAUDE-old.md` = `main`'s,
`fixture/CLAUDE-new.md` = this change as tested, an earlier snapshot kept unchanged as the
record); the other fixture files are `AGENTS.md`, `.claude/review-gates.md`, the intake
`SKILL.md`, `TASK.md` and `inputs/`. After the runs, the PR #48 review fixes changed the
shipped text twice: the handover rule gained the cross-checkout sentence and the
no-publication clause, which the planning task did not exercise; and the Gate-A sentence was
reworded positively — the review checks below used its earlier wording, "A missing function
body or complete test is not by itself a finding", so they tested that wording, not the
shipped one. Each run: `claude -p` with `--plugin-dir` on superpowers
6.4.1, `--setting-sources project`, `--strict-mcp-config`, `--permission-mode acceptEdits`,
the prompt in `prompt.txt`. Init records (`out/probe-and-runs.txt`) show the same model and
client version, only superpowers 6.4.1 plus built-in plugins, no MCP servers, a fresh memory
directory and the default output style in both runs.

## Rubric scores (by the author of this change — self-scored, quotes in the plans)

| Item | old (`out/plan-old.md`) | new (`out/plan-new.md`) |
|---|---|---|
| R1 outcome | yes — each step has an Expected line | yes — "Settled by this plan" and per-step Expected |
| R2 components and reuse | yes — Files, line ranges | yes — Files, line ranges, closed set reused unchanged |
| R3 prerequisites, settled decisions | yes — Global Constraints, open questions | yes — Global Constraints, D1–D3 |
| R4 test situations incl. failure | yes — scenario A–E, C negative | yes — S1–S5, S3 negative |
| R5 decision space | partial — none stated; the text is fixed in Step 4 | yes — "Implementer's decision space" |
| R6 implementation in full | **yes** — Step 4 gives the complete replacement paragraphs (lines 165–219) | **no** — no replacement text; one grep command |

**Qualifying observation holds:** old R6 = yes; new R6 = no with R1–R5 yes. Measured
alongside, one sample each: old 344 lines / 17,200 bytes / 62 fenced lines, 14 turns, 190 s,
reported 16,647 output tokens and USD 1.01; new 127 lines / 13,316 bytes / 0 fenced lines,
12 turns, 102 s, 9,859 output tokens and USD 0.61. One sample per variant shows a direction,
not a saving rate.

## Review check (Codex, the new Gate-A plan question; not a gate cycle)

Preconditions held: the new plan met the rubric and stated the decision named in
`removal.md` (Goal line, and the first "Settled by this plan" bullet). The degraded plan
removes exactly those two statements (`out/plan-new-degraded.md`; diff: line 5 shortened,
line 74 removed).

- **(a) Intact plan** (`out/review-intact.md`, 4 findings): none complains only about missing
  implementation. The four are real defects of this sample plan (a malformed `Story:` header,
  an inferred waiver of the own-story requirement, a misreading of intake step 6, a WIP
  commit subject). **Expected result met.**
- **(b) Degraded plan** (`out/review-degraded.md`, 5 findings): no finding names the removed
  decision as missing. One finding says "the approved spec already establishes falsified
  statements as dependencies" — the decision also lives in `TASK.md`, the plan's spec, so
  removing it from the plan left no implementation gap the reviewer had to flag.
  **Expected result not met.** The cause is in `removal.md`'s choice, made before the runs: it
  picked a decision the spec already settles, so its removal was not material to the plan.

## Review check 2 (approved by Daniel after check 1; registered in `removal-2.md` before the run, in a work-in-progress snapshot later squashed — same limit as above)

The degraded plan `out/plan-new-degraded-2.md` drops the test expectation for the task's own
incident (an answered question still listed as open in a story whose requirements are
unchanged): Review Focus item 1 and scenario S1, with every reference adjusted so the plan no
longer asks for that check. The requirement itself stays in `TASK.md` and in the plan's
definition. One call, normal review task, the gap not named.

**Result** (`out/review-degraded-2.md`, 6 findings): the sixth finding says the reading checks
"never [exercise] the incident that motivated the change: an answered question still listed
as open in a story whose requirements are unchanged", with the consequence that a change
handling only status markers "can satisfy every listed scenario". **Detection criterion met.**
It was graded **MINOR**: under the gate rules a Minor is collected and buys no repair round,
so in a real cycle this gap would have been reported but not required to be fixed. The other
five findings repeat check 1's real defects of the sample plan, plus an index check.

## AC-12, part by part

- Same task and inputs under old and new instructions, isolated, rubric fixed in advance — met.
- The new output supplies the planning decisions and test expectations without defaulting to
  full implementation — met (one sample).
- Missing implementation bodies alone are not findings — met in (a).
- A deliberately omitted material decision or critical test expectation is identified —
  check 1 (an omitted decision that the spec also states): **not identified**; check 2 (an
  omitted critical test expectation, approved and registered after check 1): **identified**,
  at Minor severity. Shown for this one sample under these conditions; it says nothing about
  how reliably Gate A finds such gaps in general.

## Limits

One sample per variant; self-scored rubric; check 2 was chosen after check 1's result (both kept);
compact planning is not error-free planning — the new sample plan had four real defects; the fixture omits files the plan refers to
(plugin manifest, CHANGELOG, scripts), which both plans noticed. Token and cost figures are
the client's reported values, not a billing record.
