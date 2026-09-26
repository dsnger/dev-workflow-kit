## Mechanical sweep before pass 9 — 13 checks, 8 defects found and fixed

| # | Check | Result |
|---|---|---|
| 1 | `sh -n` on all fenced `sh` blocks | clean |
| 2 | `sh -n` + content invariants on the 10 message assignments (no newline, no apostrophe, target prefix, four tags, §5 cleanup, retry budget) | **1 defect**: `NORESULT_CTX` bounded the retry but never tied it to §5's shared budget |
| 3 | Scratch-clone dry run, Task 0 → Task 7 Step 6 | clean; confirmed `CHANGELOG.md` shows `??` after `reset --soft` and must be staged |
| 4 | Scratch-clone dry run: Step 8 fix loop, Step 2 counterfactual, Step 5 rollback resolution | **1 defect**: `git log -S'"version": "0.7.1"'` resolves to the **0.8.0 bump that removed it**, so the rollback byte-check would compare the cached 0.7.1 hook against 0.8.0's bytes. "The commit that set it" is wrong too — a later docs commit can change the hook at the same version |
| 5 | `verify.sh` labels vs the plan's port inventory | **1 defect**: 53 call sites produce 56 assertions; the plan called both "56 rows" |
| 6 | Task 6 census greps, run verbatim | **2 defects**: grep 1 returns 7 lines for 5 sites (two sentences wrap), so a count comparison reports a phantom discrepancy; grep 2 has two undispositioned hits in `codex-gate.test.sh` asserting the retired "accurate" claim |
| 7 | Plan's battery block vs the `AGENTS.md` quality row | clean — 11 vs 12, sole delta `check-version-bump.sh main`, exactly as stated |
| 8 | Fixture source names vs `.context/probe-payloads/` | **1 defect**: seven destinations and one rename (`shape1-fast-fail-execution-failed.json` → `shape1-fast-fail.json`) were never named |
| 9 | All 14 `file:line` references say what the plan claims | clean |
| 10 | `is_wip_commit` against the plan's four exact commit commands | clean — three cycle-internal, the closing amend correctly a real commit |
| 11 | `shellcheck --shell=sh` on every extracted block | clean |
| 12 | Cross-artifact refs: 14 spec §§, 5 prompt-standards items, 6 invariants, `hooks.json` | **1 defect**: `hooks.json` has **two** matchers — `PostToolUse` is `^(Bash\|Skill\|mcp__codex__.*)$`, `PreToolUse` is the unanchored `Bash\|Skill` — and the plan cited one unqualified |
| 13 | `harness.sh` seed header | **1 defect**: stale 53/53 |

All eight fixed. Post-fix state: 7 blocks + 10 assignments `sh -n` and `shellcheck` clean; drafts 56/56 under `sh` and `dash`.
