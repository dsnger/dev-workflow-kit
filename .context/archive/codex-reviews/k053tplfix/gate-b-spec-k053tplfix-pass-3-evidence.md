Review: spec, strict full pass, cycle k053tplfix, pass 3.
Range: 28243c3fee8bf173a0f3bf4a71c054368dc837a4..c3d1b83102d447ba23f2b272d5ca7a09a431c29d.
Requirements: supplied F1-F6, regressions, version and docs; no cited story. Read exact-head scripts, diffs, test assertions, AGENTS.md, CLAUDE.md, gate rules and all 12 prompt standards.
Review hypotheses: reachable scratch may still redirect parent writes; evidence failures may still promote; signal exits may skip fingerprints; extraction failures may read as no links.
Code discovery: graph tools unavailable; used exact-head git show/git grep. Human refresh recorded at todos.md:1426: codebase-memory-mcp cli index_repository --repo-path <checkout root>. No graph mutation.
Battery: user supplied quality exit 0 on this head after 3324s. Accepted as supplied evidence; not rerun and no duplicate battery failure finding.

TESTS: sh .agents/skills/gate-b-review/scripts/run-tests.sh "$PWD" c3d1b83102d447ba23f2b272d5ca7a09a431c29d 1800 -- python3 -c <watchdog directory-swap probe below> | exit 0 | 4s; wrapper exit 0, reproduction assertions passed, reviewed checkout unchanged
TESTS: read-only Python git-show comparison | exit 0 | templates 2.21/2.25/2.26 byte-identical; manifest, 2.23 and .claude/dev-workflow-version all 0.53.0
TESTS: existing suites not rerun — supplied full-battery evidence covers this head; inspected changed regressions.

F1: partial. create/place use exclusive no-follow creates; reply extracted from events, no Codex -o; scratch identity recorded at 171-172 and compared after group shutdown at 211. This closes the post-review directory-swap writes. However watchdog at 204 runs before shutdown and resolves the scratch directory pathname. O_NOFOLLOW protects only the final timed-out component. A replaced parent directory redirects this new file creation, reproduced without a racing/escaped process. No existing host-file overwrite claimed. Current regression at scripts/gate-b-risk-pass.test.sh:231-236 exits promptly, so the watchdog never reaches its write.
F2: append at risk-pass.sh:128-130 adds O_NONBLOCK and retains fd-based regular-file/link-count checks plus print/close checks. Test 212-217 swaps the state for a FIFO and requires bounded exit 1.
F3: event/reply/evidence placement failures accumulated at 215-238, TESTS/CALLERS required at 240, canonical/hash/done failures checked at 268 onward. Missing-evidence and missing-CALLERS regressions at 218-224; successful stub provides evidence. No pass promoted on these result-write failures.
F4: check-doc-links.sh:133-138 checks stripping, grep and sed separately, accepts grep exit 1, and feeds errors into final broken result. Tests 126-135 inject awk/grep errors. Documented headings/fragment-decoding limitations retained.
F5: run-tests.sh:118-128,165-166 uses finish for normal/timeout/HUP/INT/TERM, ignores additional signals, cleans groups and copy, then fingerprints. INT-after-write regression at suite 101-107 asserts exit 4. Setup failures occur before test execution.
F6: risk-pass.sh:175-185 uses the exact hook is_prompt_path regex (hook 1509-1512), checks head for standards, interpolates conditional instruction. Suite 80/225-229 covers negative/positive classification.
Version/docs: requested 0.53.0 records confirmed; CHANGELOG lists six fixes, docs/reference explains boundaries, AGENTS 4c adds exception. No unrelated feature additions. Prompt standards checked in context; watchdog guarantee gap reported once as F1.
Test-first chronology: commits combine tests and fixes; cannot independently establish temporal red-before-green from this history. Regression assertions cover prior defects by inspection; chronology left unverified.

Earlier pass 1 spec #1 MAJOR: fixed for the reported host-file overwrite paths at risk-pass.sh:137-153,200,221,234,268; directory identity at 171-172/211 additionally closes post-review directory swaps. Remaining watchdog new-file creation is a narrower new F1/Security finding, not an existing-file overwrite claim.
Earlier pass 2 spec #1 MINOR: fixed at AGENTS.md:57-59, risk-pass.sh:21-23 and inline copy: temporary-root exception now stated explicitly.

CALLERS: work/gitdir/work_id/wid — allocation 167-172; post-stop comparison 211 gates place/create; cleanup 101-106 removes scratch; watchdog 204 does not use identity. Inline 2.26 identical; docs/reference:570-587 and CHANGELOG describe protections.
CALLERS: append — start 156, failure 159, done 272; fd checks retained, FIFO regression tests final append.
CALLERS: create/sread/place — events 215, reply 218-221, model 223, evidence 232-235, stderr 237, canonical 268; exclusive output, no-follow nonblocking input. Inline 2.26 consumers identical.
CALLERS: reply/events/watchdog — Codex launch 199-201, JSON parser 218-220, marker reader 236; changed stub emits item.completed agent_message. Watchdog write is the reported gap.
CALLERS: evidence/werr — checks 238-241 precede validation/promotion; SKILL.md output requires evidence, gate rules risk completion consumes state done/hash.
CALLERS: standards — prompt 185; hook classifier 1509-1512 matches; suite inspects last-prompt.
CALLERS: run-tests finish/fp_before — traps 128 and completion 165-166; EXIT cleanup idempotent; SKILL.md:44 and docs/reference:533-538 consume checkout-change exit 4; inline 2.25 identical.
CALLERS: check-doc-links strip_code/c/l/st — per-file extraction and final broken aggregate; CI:185 and AGENTS quality consume exit; inline 2.21 identical.
CALLERS: templates 2.21/2.23/2.25/2.26 and version — check-invariants 4l/4n/4o compare copies; manifest inspected, change version-only.
CALLERS: documentation/todos/review records — no heading renames or new shipped paths; closed todos match F2/F3; historical review records are evidence only.

Probe limitation: stub Codex models a reviewer-writable scratch directory; both target and fixture are disposable under the outer runner. No actual external host directory was written and no live Codex sandbox was invoked. The real watchdog performs the redirected write; outside-sandbox impact follows from its unsandboxed launch and unrestricted directory resolution.
Observed output:
runner exit: 1
risk-pass.sh: the scratch directory was replaced while Codex ran; nothing written
redirected timeout marker exists: True

Exact probe Python:
```python
import os,pathlib,subprocess,tempfile
root=pathlib.Path.cwd(); script=root/'.agents/skills/gate-b-review/scripts/risk-pass.sh'
with tempfile.TemporaryDirectory() as t:
 p=pathlib.Path(t); repo=p/'repo'; repo.mkdir(); target=p/'outside'; target.mkdir(); bin=p/'bin'; bin.mkdir()
 def git(*args): return subprocess.check_output(['git','-C',str(repo),*args],text=True).strip()
 git('init','-q'); git('-c','user.name=Test','-c','user.email=test@example.invalid','commit','--allow-empty','-qm','base'); h=git('rev-parse','HEAD')
 d=repo/'.context/codex-reviews'; d.mkdir(parents=True); (d/'gate-b-cycle-k053test.state').write_text('base '+h+'\n')
 stub=bin/'codex'; stub.write_text('#!/bin/sh\nif [ "$1" = --version ]; then echo "codex-cli 0.162.1"; exit; fi\ncat >/dev/null\nfor w in .git/gate-b-risk.*; do rm -rf "$w"; ln -s "$TARGET" "$w"; done\nsleep 20\n'); stub.chmod(0o755)
 env=dict(os.environ,PATH=str(bin)+':'+os.environ['PATH'],TARGET=str(target))
 r=subprocess.run(['sh',str(script),str(repo),h,h,'k053test','1','2'],env=env,text=True,capture_output=True,timeout=25)
 print('runner exit:',r.returncode); print(r.stderr.strip()); print('redirected timeout marker exists:',(target/'timed-out').exists())
 assert r.returncode==1 and (target/'timed-out').exists(), 'reproduction did not match'

```
