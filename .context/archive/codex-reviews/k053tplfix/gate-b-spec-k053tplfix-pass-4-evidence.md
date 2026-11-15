Review: spec, strict full pass, cycle k053tplfix, pass 4.
Range: 28243c3fee8bf173a0f3bf4a71c054368dc837a4..4686424c4ebe41e1741954a2250c6f43578144f3.
Requirements: supplied F1-F6, regressions, version and docs; no cited story.
Read exact-head scripts, full implementation/template diff, regression assertions, manifest, AGENTS.md, CLAUDE.md, gate rules and prompt standards. No missing implementation or unnecessary feature found.
Review hypotheses checked: reachable scratch could redirect parent writes; missing evidence or failed result writes could promote; signals could bypass fingerprinting; extractor errors could disappear.
Code discovery: graph tools unavailable in tool inventory; used exact-head git show/git grep. Human refresh recorded at todos.md:1426: codebase-memory-mcp cli index_repository --repo-path <checkout root>. No graph mutation.
Battery: supplied quality command exit 0 on 4686424 after 3645s; not independently rerun.

TESTS: none — no additional executable suites; supplied full battery covers this head and changed regressions were inspected.
TESTS: read-only Python git-show comparison | exit 0 | templates 2.21/2.25/2.26 byte-identical to scripts; manifest, 2.23 and .claude/dev-workflow-version all 0.53.0

F1: risk-pass.sh:137-153 creates scratch results and destination temporary files exclusively with O_NOFOLLOW; source reads reject nonregular files and use nonblocking no-follow opens. Scratch is allocated in gitdir at 167-173, with device/inode identity checked after group shutdown at 215. This handles the documented temporary-root exception. Codex receives no -o argument; reply comes from events (200-225). Watchdog 206-210 now only sleeps/signals; it creates no marker. Timeout is checked by elapsed time at 240. Regression scripts/gate-b-risk-pass.test.sh:194-211 checks actual scratch location and planted files; 233-245 checks replaced directory both with prompt completion and while running into timeout. No post-review scratch write precedes the identity check.
F2: risk-pass.sh:128-130 adds O_NONBLOCK and retains fd-based regular-file/link-count, print and close checks. Suite 212-217 replaces state with a FIFO and requires bounded exit 1.
F3: risk-pass.sh:219-245 accumulates event/reply/evidence write errors and requires TESTS and CALLERS before promotion; 272-279 checks canonical creation/placement, hash and done append. Suite 218-224 checks absent evidence and missing CALLERS; valid stub supplies both lines. Existing failure paths retain failure status even if failed-state append fails.
F4: check-doc-links.sh:133-138 separately checks stripping, grep and sed status, treats grep 1 as no link, and sends error messages into broken aggregate (exit 1). Tests 126-135 inject awk/grep failures; ordinary no-link cases remain valid. Heading/fragment extraction limits are explicitly documented.
F5: run-tests.sh:118-128 and 165-166 route normal, timeout, HUP, INT and TERM through finish: ignore further signals, stop groups/remove copy, compare fingerprint, exit. Test suite 101-107 changes checkout before INT and requires exit 4. Setup errors precede test execution.
F6: risk-pass.sh:174-186 uses the exact regex from hook is_prompt_path:1509-1512, checks standards existence at reviewed head, adds the instruction to the risk prompt. Suite 80 and 225-230 checks negative/positive prompt cases.
Version/docs: all three required version records are 0.53.0. CHANGELOG:25 onward and docs/reference.md:533-538,570-596,871 describe the six changes. AGENTS.md:57-59 and shipped header explicitly qualify gitdir isolation for temporary-root checkouts. No heading renames, added shipped paths, new dependencies or unrelated features.
Test-first chronology: tests and initial implementation share commit 027e8fa; red-before-green execution order cannot be independently established from this git history. Regression assertions exercise the old defects by inspection; chronology remains unverified, not evidence of a missing implementation.
Prompt review: all 12 checklist items considered against changed prompt/template content. Conditional standards instruction retains existing task/output boundaries and uses the established classifier; inline copies preserve scaffold rules. No new prompt defect identified.

Earlier pass 1 spec #1 MAJOR: fixed at risk-pass.sh:137-153,167-173,215,225,238,272; inline 2.26 identical. Exclusive output creation and directory identity check close reported scratch overwrite paths.
Earlier pass 2 spec #1 MINOR: fixed at AGENTS.md:57-59, risk-pass.sh:21-23 and workflow-init.md:2835-2837; temporary-root exception stated.
Earlier pass 3 spec #1 MINOR Security: fixed at risk-pass.sh:206-210 and workflow-init.md:3020-3024; watchdog marker creation removed. Regression scripts/gate-b-risk-pass.test.sh:239-245 waits into timeout after replacing scratch directory.

CALLERS: work/gitdir/work_id/wid — risk-pass.sh:167-173 allocation/identity, 215 post-stop guard, cleanup:101-106; result operations follow guard; docs/reference and CHANGELOG describe temporary-root exception.
CALLERS: append — risk-pass.sh:156 start,159 failure,278 done; all retain checked status and fd-based type/link validation; FIFO regression covers final append.
CALLERS: create/sread/place — risk-pass.sh:219 events,222-225 reply,227 model,236-239 evidence,241 stderr,272 canonical; inline 2.26 byte-identical.
CALLERS: watchdog/t0 — risk-pass.sh:204,209-214,240; no marker consumer remains; timeout and directory-swap test cases cover altered behavior.
CALLERS: evidence/werr — risk-pass.sh:219-245 precedes canonical promotion; SKILL.md output requires TESTS/CALLERS; gate rules consume done/hash.
CALLERS: standards — risk-pass.sh:177-186; hook is_prompt_path:1509-1512 supplies matching classifier; suite last-prompt checks positive and negative cases.
CALLERS: run-tests finish/fp_before — signal traps:128 and completion:165-166; EXIT cleanup remains idempotent; SKILL.md targeted-test rules and docs/reference consume checkout-change exit 4; template 2.25 identical.
CALLERS: check-doc-links strip_code/c/l/st — per-file extraction:133-138, broken aggregate final exit; CI:185 and AGENTS quality consume status; template 2.21 identical.
CALLERS: templates 2.21/2.23/2.25/2.26 and version — check-invariants 4l/4n/4o compare copies; plugin manifest version-only change read directly.
CALLERS: documentation/todos/review artifacts — no renamed headings; todos closed FIFO/evidence entries correspond to F2/F3; previous findings/dispositions are historical gate evidence.
