Review: spec branch, strict mode, pass 1, cycle k051rp99.
Range: 2a5a4d06e35143f43c04db538a27d145cddd5cf5..14d5b3c1f9bfda4bec887c8ad3faad8e53390e01. HEAD equals the requested head; tracked working tree is unchanged.
Inputs: read AGENTS.md, CLAUDE.md, .claude/review-gates.md, docs/prompt-standards.md, the cited story, design and plan, and implementation diffs. Implementer commit subjects are claims, not verification evidence.
Hypotheses checked: classic compatibility may lose old conditions; remembered modes may diverge from reminder advice; archive/approval changes may leave dependent prompts stale. The threshold-advice mismatch is the reported finding.
Graph: no evidence establishes that the available graph indexes this head. Used direct head-tree searches, as the review skill requires. Human refresh recorded at todos.md:1394: codebase-memory-mcp cli index_repository --repo-path <checkout root>. No indexing performed.
TESTS: none — static review chosen; the supplied runner creates disposable copies outside the repository, conflicting with the call's repository-only constraint. Read the hook section-50 cases and changed report suites. No full-battery result is claimed; AC-13's green-battery condition remains unverified, as the call explicitly supplies no battery evidence.

Acceptance map (implementation; asserting test or none):
AC-1: .claude/review-gates.md:52-59 gives lean B floor/cap 1/3, closure and cap routing; hook mode_nums and cap_check supply advisory numbers. Hook suite section 50 asserts lean floor/cap; prompt closure behavior has no executable test.
AC-2: review-gates.md:23-24,53 supplies earlier findings/verdicts, fix-diff base and unknown-head fallback, and collecting new ordinary Majors. Strict full reviews are the explicitly specified exception. Test: none (prompt reading).
AC-3: review-gates.md:3,52-59 and committed .claude/codex-gate.mode = strict; workflow-init section 2.1a covers initialization/declined targets; hook mode_nums and remembered-mode reconciliation. Section 50 tests default, classic, lean, strict, invalid words, whitespace, legacy counters and mode changes. Threshold exception reported.
AC-4: review-gates.md:4-5,9-11,52-53 gives risk/security threshold, approval and two-pass Gate A; intake checkpoint/handoff and CLAUDE section 4 align. Section 50 tests A numbers/threshold text; no executable prompt-routing test.
AC-5: CLAUDE.md:95,99 and workflow-init equivalent specify five rounds, missing/crashing/timed-out tools red and untouched-test exception; review-gates.md:40 suppresses duplicate known battery failures while preserving coverage review. Test: none (prompt reading).
AC-6: CLAUDE.md:86 and workflow-init:525 require each UI AC's real-app run and evidence location, with classic exemption. Test: none (prompt reading).
AC-7: harden-finding steps 4-7 retain lint/test selection and require a reason for prose when neither can decide; ledger/scaffold Columns paragraph aligns. Test: none (prompt reading).
AC-8: hook mode parsing, floor/cap messages and always-advisory exit paths reviewed; section 50's lean 1/1 assertion would fail on the base hook's 1/3 output. workflow-init closing checklist recommends default-branch protection without setting it. Threshold mismatch reported; suites not executed.
AC-9: review-gates.md:63,77 archives cycle files before closing, refuses overwrite and resumes from archive; .gitignore includes archive; harden-finding/ledger/scaffold define learning-row contents. Test: none (prompt reading).
AC-10: design section 6 O1-O19 compared against old/new rule text. Core gate conditions preserved or deliberately changed; Library APIs and Ponytail moved intact to CLAUDE section 4 and scaffold, documented in CHANGELOG.
AC-11: ledger-metrics parser accepts positive floor integers; only display labels changed. New ledger-metrics section 9 and loop-usefulness final fixture assert standard-risk floor-1 alongside floor-3 history; existing fixtures also exercise historical floor-1. Other report consumers retain the shared record parser or transcript inputs; records did not change syntax.
AC-12: both inline rule copies inspected; checks 4e/4i/4j provide mechanical size/equality assertions. Prompt standards reviewed statically; no runtime claim about model conformance or external prompting-page freshness. See finding for inconsistent advice.
AC-13: plugin.json version 0.46.0, CHANGELOG entry, README and docs changes present. Battery not run on this head per supplied evidence; green status not established.

CALLERS: mode_file / mode / mode_bad — read_mode initialization, mode_note, remember_mode, threshold message at hook:1844; workflow-init:603 and README:73 configure it; reference Gate modes documents it.
CALLERS: trim_file — read_int_file and read_mode; cap_file and capextra_file parsing preserve the existing numeric override path.
CALLERS: read_mode — current mode initialization and remembered modeA/modeB reconciliation; section 50 covers malformed/current and missing remembered state.
CALLERS: mode_nums / nfA / ncA / nfB / ncB — initialization and remembered-mode reconciliation at hook:305-333.
CALLERS: modeA_file / cmA / rA / cA — reconciliation at hook:314-323; remember_mode at exec credit:1651; reset at Skill completion:1705,1712; cap_check and A below-floor advice use cmA, but threshold advice uses mode.
CALLERS: modeB_file / cmB / rB — reconciliation at hook:325-333; credit_pass:935 remembers it; commit reset:1688 clears it; cap_check and B below-floor advice use cmB.
CALLERS: remember_mode — credit_pass and Gate A successful exec counting; reset_gate_state/reset_all in the test harness remove both remembered files.
CALLERS: floor / floorA / floorB / capA / capB / ovr / mtA / mtB — override handling:337-350; compact_lines:1577-1578; cap_check:1133; commit reminders:1769-1785; plan reminders:1826-1840. No remaining shared floor/cap consumers missed in changed paths.
CALLERS: cap_check / mode_note / mode_said — gate-call, commit and plan-execution event paths; section 50 verifies cap wording and invalid-file notes.
CALLERS: compact_count — compact_lines supplies separate per-gate floor/cap; compact nonce discovery still scans current findings directory, while the agent resume rule explicitly includes archive.
CALLERS: docs-only hook note — PreToolUse Bash classification; section 48 asserts gate-mode threshold wording in jq and fallback runs.
CALLERS: setmode / has50 / mode_ctx / mode_msg / thr_ctx / thr_msg — section 50 mode assertions and section 29 exact-output/length assertions in hook suite; threshold cases cover static modes, not a change during a positive Gate A cycle.
CALLERS: gate rules headings, approval, blocking, closure and cycle provenance — CLAUDE section 5 pointer, section 4 run order, intake checkpoints/handoff, workflow-init inline templates and reference/getting-started/coding-workflow/setup docs reviewed. Classic small-change and cap-answer routes remain explicit.
CALLERS: Library APIs (Context7) / Ponytail (optional) moved headings — CLAUDE.md:103,105; workflow-init section 2.1, Context7 setup paragraph and section 2.16; reference optional companion text updated. Gate-A prompt points to CLAUDE fallback.
CALLERS: workflow-init 2.1a mode initialization — two-target migration/overwrite decision table and final scaffold report; existing modes are reported unchanged, stale lean/strict surfaces require an answer.
CALLERS: archive/codex-reviews/<nonce> — closing and resume rule, workflow-init rule copy, reference closing act, .gitignore exception and todos deferred historical cleanup. No report newly reads archived file contents.
CALLERS: harden-finding step 4 and step 7 / ledger Columns — gate closing ledger duties, docs/hardening-log.md and workflow-init 2.2; example row updated with cause, change, location and nonce.
CALLERS: git_sections display labels — ledger-metrics main:631, exact-output expectations in ledger-metrics.test.sh:206,291,526; parser behavior unchanged.
CALLERS: cycle-record parser — loop-usefulness.py:25, run-analytics.py:60 and spec-delta.py:83 load ledger-metrics; live-effort/status-view consume report/transcript information rather than moving pass-file contents.
CALLERS: plugin version — convention-loaded plugin manifest and release CHANGELOG; no added manifest component declarations. README/reference/setup explain mode adoption.
