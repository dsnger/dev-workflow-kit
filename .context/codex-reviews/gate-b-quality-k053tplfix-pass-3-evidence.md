Review: Gate B quality, cycle k053tplfix, pass 3, strict/full.
Range: 28243c3fee8bf173a0f3bf4a71c054368dc837a4..c3d1b83102d447ba23f2b272d5ca7a09a431c29d.
Scope: full production diff, changed regressions, inline templates, version records, AGENTS.md, CLAUDE.md, .claude/review-gates.md, docs/prompt-standards.md, docs/reference.md, CHANGELOG and relevant todos. No story/spec specifically cited for 0.53; original task's six fixes are the requirements.
Hypotheses checked: scratch protection must cover writes before as well as after group termination; signals must retain the checkout comparison; absent evidence and extraction failures must not report success; shipped copies and prose must match actual checks.
Code discovery: graph tools unavailable; direct committed-head git grep and git show used. Human refresh recorded in todos.md Tooling revalidation: codebase-memory-mcp cli index_repository --repo-path <checkout root>. No index changes.
Battery: supplied evidence says the AGENTS.md quality command exited 0 on this exact head after 3324s. Accepted as supplied, not independently rerun. The finding below is a new targeted reproduction, not a duplicate battery failure.
TESTS: targeted scratch-directory-swap/timeout probe using the fixture prefix of scripts/gate-b-risk-pass.test.sh, run through sh .agents/skills/gate-b-review/scripts/run-tests.sh "$PWD" c3d1b83102d447ba23f2b272d5ca7a09a431c29d 1800 -- python3 -c <probe below> | exit 1 | 3s
The outer runner did not report checkout changed. Only its disposable copy's test file was modified. The stub uses no network or real Codex. Its before hook substitutes a scratch directory symlink once, then hangs until the 2-second watchdog fires. No escaped process or concurrent repeated swap is needed. Observed runner exit 1; diagnostic "the scratch directory was replaced while Codex ran; nothing written"; the linked destination nevertheless contains timed-out. Probe target stays inside the disposable fixture for safety; path resolution is the same when the unsandboxed watchdog has rights to a destination outside the reviewer's roots. O_EXCL bounds impact to creation of a previously absent timed-out file, not overwriting an existing file.
TESTS: full existing suites not rerun — exact-head successful battery supplied; targeted test used to resolve the uncovered timeout path.
Checks: git diff --check base..head exited 0. Read-only extraction of head's inline sh fences found 2.21, 2.25, 2.26 byte-identical to their scripts. Manifest version, local version record and template 2.23 all read 0.53.0.

CALLERS: append — risk-pass.sh:156,159,272; start/failure/done records now use O_NONBLOCK and verify regular single-link files. State FIFO fixture tests actual OS FIFO behavior.
CALLERS: create — risk-pass.sh:221,234,268; reply, evidence and canonical copy use exclusive no-follow creates after group shutdown and identity comparison.
CALLERS: sread — risk-pass.sh:218,223,237; event parsing/model lookup/stderr tail use nonblocking regular-file input.
CALLERS: place — risk-pass.sh:215,221,234,268; destination temporary files use exclusive creates then rename; failed writes feed werr or finish.
CALLERS: work/gitdir/wid/work_id — risk-pass.sh:168-172,180,201,204-211,215-240,268 and cleanup:104. Main post-run writes are guarded, but watchdog:204 writes before identity comparison:211. The regression at scripts/gate-b-risk-pass.test.sh:226-229 uses an immediately exiting stub and never reaches watchdog expiry.
CALLERS: reply/events — risk-pass.sh:199-223; Codex no longer receives -o, JSON agent_message is extracted for the reply, event log remains outside the fingerprinted review directory during execution. Stub updated to emit this event.
CALLERS: evidence/werr — risk-pass.sh:232-241; reviewer evidence is retained, TESTS and CALLERS prefixes required before promotion:264-273. Missing and incomplete evidence cases are in the suite.
CALLERS: standards — risk-pass.sh:175-185; regex matches hooks/codex-gate.sh:1509-1512 and checks head for standards existence. Added sentence references head's standards; prompt checklist considered against the existing Codex prompt and referenced skill.
CALLERS: run-tests finish/fp_before/cleanup — run-tests.sh:108-128,132,165-166; normal and HUP/INT/TERM paths stop groups and remove copy before post-fingerprint. scripts/gate-b-run-tests.test.sh:101-108 adds interruption after a real fixture checkout write.
CALLERS: check-doc-links strip_code/c/l/st — check-doc-links.sh:132-139; downstream link loop consumes same line:target records; awk and grep crash regressions added at scripts/check-doc-links.test.sh:126-137. No-link grep exit 1 stays valid. Remaining target-heading and fragment-decoding limitations explicitly stated.
CALLERS: template 2.21 — workflow-init.md:1877; check-invariants.sh check 4l compares script bytes; docs/reference.md:867 and CHANGELOG 0.53 document the bounded extractor change.
CALLERS: templates 2.25/2.26 — workflow-init.md:2628,2806; check-invariants.sh check 4o compares script bytes; .agents/skills/gate-b-review/SKILL.md:44,77 and .claude/review-gates.md:37 consume the runners.
CALLERS: version 0.53.0 — plugin.json:4, .claude/dev-workflow-version:1 and workflow-init.md:2512; check 4n compares the records, CHANGELOG adds the release.
CALLERS: scratch guarantees — AGENTS.md boundary 4c, docs/reference.md:570-589, CHANGELOG 0.53 and script header. TMPDIR exception is documented but the watchdog still violates the stated no-write-through protection.
CALLERS: resolved todos — todos.md:2311-2316; FIFO and evidence items now checked off with regression references.

Previous findings:
- Pass 2 quality #1: not fixed as a class. risk-pass.sh:171-172,211 fixes post-exit parent writes, but watchdog:204-205 still follows the directory symlink on timeout; mirrored workflow-init.md:3018-3019.
- Pass 1 quality #1: fixed. check-doc-links.sh:32-33, docs/reference.md:870, CHANGELOG 0.53 and template 2.21 now bound failure handling to link extraction and explicitly exclude headings/fragment decoding.
- Pass 1 quality #2: fixed. todos.md:2311-2316 closes both repaired items.

Reproduction Python passed as one quoted -c argument:
```python
from pathlib import Path
import subprocess
p=Path("scripts/gate-b-risk-pass.test.sh")
prefix=p.read_text().split("\nF1=")[0]
probe=r'''
reset; echo hang > "$STUB_DIR/mode"; mkdir -p "$work/elsewhere"
printf 'for w in "%s"/.git/gate-b-risk.*; do rm -rf "$w"; ln -s "%s" "$w"; done\n' "$repo" "$work/elsewhere" > "$STUB_DIR/before"
run 1 2
printf 'runner exit: %s\n' "$rc"
cat "$work/err"
if [ -f "$work/elsewhere/timed-out" ]; then
  echo "FAIL: watchdog created timed-out through substituted scratch directory"
  exit 1
fi
echo "PASS: outside directory unchanged"
'''
p.write_text(prefix+probe)
raise SystemExit(subprocess.call(["sh",str(p)]))

```
