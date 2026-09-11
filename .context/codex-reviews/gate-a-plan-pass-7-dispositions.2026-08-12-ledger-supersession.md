# Gate A — plan — pass 7 dispositions (CLOSING PASS)

Artifact: `docs/superpowers/plans/2026-08-12-hardening-ledger-supersession.md`.
2 findings: **2 Minor. Zero Blocker, zero Major.** Both valid. **Both applied.**

Reviewer: `mcp-codex-dev@1.0.1`, `codex-cli 0.144.5`, model `gpt-5.6-sol`. Pass file valid:
3 lines, 2 finding lines, terminator exact.

Plan passes: **18, 11, 9, 8, 6, 2, 2.** Blockers: **2, 1, 4, 3, 1, 0, 0.**

| # | Verdict | Applied as |
|---|---|---|
| 1 | **Valid.** Task 6's Interfaces pointed the `0.8.2` closing-body deliverable at Task 8 **Step 6**, which amends fixes into the WIP; the real closing body is Step 7. The reference sent an auditor to a step that cannot establish the claim. | Reference corrected to Step 7. |
| 2 | **Valid.** Self-Review mapped spec §4 to Tasks 3, 4, 6 and 7 and named the three pre-landed files, omitting the **governing story's amendments** — which §4 requires and Task 1 commits. The plan's own coverage summary disagreed with its task mapping, making a required change look unaccounted for. | Task 1 added to the §4 mapping, with the three outside-scope files named explicitly. |

## Why this closes the gate

§5's loop is a **Blocker/Major** loop — Minor and Nit are collected, never iterated — so a pass
returning none is its exit condition. Both Minors were applied rather than collected because each is
a one-line cross-reference fix, not a judgement call worth carrying forward.

Neither is the cycle's dominant failure mode. Both are internal cross-references that were correct
when written and went stale when a step was inserted (Task 8 gained a step at pass 4) or a task's
scope widened (Task 1 gained the plan at pass 1) — drift *behind* a fix rather than a fix landing in
one site only. That class produced a Blocker in each of passes 3, 4 and 5 and has produced none
since it was named directly in the pass-5 and pass-6 prompts.

Closure record: `gate-a-plan-CLOSURE.md`.
