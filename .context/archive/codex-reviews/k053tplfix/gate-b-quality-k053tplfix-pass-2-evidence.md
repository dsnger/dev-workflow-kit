Review: Gate B quality, cycle k053tplfix, pass 2, strict/full.
Range: 28243c3fee8bf173a0f3bf4a71c054368dc837a4..9efe9161b5bdf2a60f551ac6055f8bb36dbaf643.
Scope: six template fixes and pass-1 repairs; no 0.53 story/spec was cited. Read committed sources via git diff/show, AGENTS.md, CLAUDE.md, gate rules and all 12 prompt-standard checklist items.
Hypotheses checked: scratch replacement might retain write-through; missing evidence or failed publication might promote success; interruption might bypass checkout comparison; extraction failures might still appear successful. Implementation claims checked against source.
TESTS: AGENTS.md full quality command | caller-supplied exit 0 at 9efe916 after 3190s | not rerun; no battery failure finding
TESTS: sh .agents/skills/gate-b-review/scripts/run-tests.sh "$PWD" 9efe9161b5bdf2a60f551ac6055f8bb36dbaf643 1800 -- sh scripts/check-doc-links.test.sh | exit 0 | child 16s, 59 assertions; wrapper exit 0
TESTS: same disposable-copy runner/head/1800 limit, -- sh -c reproduction below | exit 1 | child 2s, wrapper exit 1; intentional assertion detects a parent write through a scratch-directory symlink; inner risk-pass exits 1 after making the write
TESTS: other existing suites not rerun | source inspection plus supplied head-specific battery evidence
CHECK: git diff --check 28243c3..9efe916 | exit 0
CHECK: direct git-show byte comparison | 2.21, 2.25 and 2.26 identical to their scripts
CHECK: manifest, .claude/dev-workflow-version and inline 2.23 | 0.53.0
Code discovery: no codebase-memory tools available; used direct head-tree git grep. Human refresh recorded at todos.md:1426: codebase-memory-mcp cli index_repository --repo-path <checkout root>. No indexing performed.

CALLERS: risk-pass.sh work/gitdir — scratch allocation at 166-167, prompt/streams at 175-196, watchdog at 199-200, publication at 209-228 and canonical copy at 262, cleanup at 103. Scratch-directory replacement defeats final-component no-follow protection. This is a new reproduction beyond the supplied green battery, not a report of a battery failure.
CALLERS: create — reply at 215, evidence at 228, canon at 262; exclusive creation rejects leaf links but follows a symlink directory. Inline 2.26 duplicates the same behavior.
CALLERS: sread — reply decoding 212-214, model extraction 217, failure diagnostics 231; no-follow/nonblocking regular-file opens reject leaf FIFOs and symlinks. Intermediate scratch directories are not protected.
CALLERS: place/dirs_ok — event log 209, reply 215, evidence 228, canon 262; output directory checks and exclusive temporary creation/rename preserve existing output-file safety, but do not protect the scratch directory.
CALLERS: append/O_NONBLOCK — start at 155, failed at 158, done at 266; regular-file and single-link checks retained; added flag prevents blocking before FIFO type check. Regression tests cover FIFO and hard-link state replacements.
CALLERS: werr/ev/evidence — 209-235 rejects event/evidence/reply placement errors and requires TESTS:/CALLERS: before validation/promotion; SKILL.md output contract requires both. Missing evidence and absent CALLERS regressions inspected.
CALLERS: reply/no -o/JSON::PP — launch 194-196, event parser 212-214, placement 215; risk-suite stub now emits item.completed agent_message, first success case checks published reply. Leaf output link replacement is tested.
CALLERS: timeout marker — exclusive no-follow watchdog create at 199 and regular test at 230; same intermediate-directory issue applies. Existing process-group cleanup and timeout branches inspected.
CALLERS: standards — 171-173 interpolated at 180; exact regex matches hooks/codex-gate.sh:1509-1512; tests cover a skills range with standards and a range without prompt paths. New instruction explicitly asks for head-version standards. Existing path-classifier limitations are unchanged.
CALLERS: risk-pass interface/status — SKILL.md:77, .claude/review-gates.md:37, docs/reference.md:568-599; argument and status contract unchanged except required evidence/write failure. Lock takeover, busy, invalid findings, failure and cleanup paths read.
CALLERS: run-tests finish/fp_before/cleanup — traps at 128 and normal/timeout endings at 165-166; cleanup before comparison, additional signals ignored during finalization, EXIT cleanup idempotent. SKILL.md interprets exit 4 as checkout change. Added INT-after-write regression asserts both exit 4 and diagnostic.
CALLERS: check-doc-links strip_code/c/l/st — extraction loop 134-139 and final broken accumulator at 154-156; anchors/pct_decode downstream behavior remains outside the newly stated error checks. AGENTS quality and CI callers rely on nonzero exit. Added awk/grep failures exercised in the 59-assertion suite.
CALLERS: suite stub/reset/run/RH — risk suite now supplies evidence and event reply, clears missing-evidence state on reset, bounds calls by alarm, selects alternate prompt-range head. Scratch attack test at 206-210 attacks leaf files simultaneously; it does not replace their containing directory. Add a separate directory-swap case.
CALLERS: template sections 2.21/2.25/2.26 — workflow-init scaffold consumers; check-invariants.sh:1140-1167 (4l) and 1215 onward (4o) enforce byte identity. No headings renamed/deleted.
CALLERS: version fields/template 2.23 — check 4n consumes all three version records; version bump present; only manifest version changed.
CALLERS: AGENTS.md:57-58, docs/reference.md:570-590, CHANGELOG.md:31-38 and inline 2.26 — safety descriptions depend on the incomplete scratch protection; included in the single security finding, not counted again as prose defects.
CALLERS: pass-1 findings/dispositions/evidence and cycle state — review-gates output/closing contract; cycle base matches requested range; historical artifacts describe prior head and are not current claims.
CALLERS: todos.md:2311-2316 — repaired FIFO and missing-evidence rows are closed and cite regressions.

Earlier quality findings:
1 fixed — scripts/check-doc-links.sh:32-33; workflow-init.md:1928-1929; docs/reference.md:869; CHANGELOG.md:46-48. All four now bound checked failures to code stripping/link search/link parsing and name unchecked heading/fragment decoding failures.
2 fixed — todos.md:2311 and 2314. Both rows closed with 0.53.0 and regression references.

Strengths: focused changes; nonblocking FIFO rejection; evidence validation before promotion; shared signal/normal finalization; matching inline templates and version records.
Assessment: not ready to merge; one MAJOR/high Security finding. The remaining write-through needs no surviving process or race. It creates new files at fixed scratch basenames in a parent-writable target directory; this reproduction does not claim overwrite of an existing regular file because O_EXCL rejects it.
Limits: used a stub reviewer to reproduce parent path handling, not a live Codex sandbox escape. The accepted reviewer-writable TMPDIR case is expressly described in the implementation. Test-first chronology is not independently establishable from the two aggregate WIP commits.

Reproduction command passed to the disposable runner (all fixture writes stay in its copy):
```sh
set -eu
mkdir fixture bin outside
git -C fixture init -q
git -C fixture -c user.name=t -c user.email=t@example.invalid commit --allow-empty -qm base
h=$(git -C fixture rev-parse HEAD)
r="$PWD/fixture"
mkdir -p "$r/.context/codex-reviews"
printf 'base %s\n' "$h" > "$r/.context/codex-reviews/gate-b-cycle-abcd1234.state"
export TEST_OUTSIDE="$PWD/outside"
cat > bin/codex <<'EOF'
#!/bin/sh
if [ "$1" = --version ]; then echo 'codex-cli 0.162.1'; exit; fi
p=$(cat)
f=$(printf '%s\n' "$p" | sed -n 's/^Findings file: //p')
printf 'NO FINDINGS\nEND OF FINDINGS (0 total)\n' > "$f"
printf 'TESTS: none\nCALLERS: none\n' > "${f%.md}-evidence.md"
for w in .git/gate-b-risk.*; do
  mv "$w" "$w.old"
  ln -s "$TEST_OUTSIDE" "$w"
done
EOF
chmod +x bin/codex
set +e
PATH="$PWD/bin:$PATH" sh .agents/skills/gate-b-review/scripts/risk-pass.sh "$r" "$h" "$h" abcd1234 1 30
rc=$?

printf 'risk runner exit: %s\n' "$rc"
if [ -f outside/evidence ]; then
 echo 'REPRODUCED: parent wrote evidence through scratch-directory symlink'
 cat outside/evidence
 exit 1
fi

```
Observed:
risk runner exit: 1
REPRODUCED: parent wrote evidence through scratch-directory symlink
The outside/evidence file contained the parent CLI/HEAD/MODEL/EXIT header and reviewer TESTS:/CALLERS: lines.
