#!/bin/sh
# Regression suite for .agents/skills/gate-b-review/scripts/risk-pass.sh: a fixture repository with
# a cycle state file, a stub `codex` first on PATH whose behaviour a file selects, and the script
# under RISK_PASS_SH (sh by default; the quality command also runs it under dash). It checks exit
# statuses, the state file's start/done/failed lines, promotion to the canonical findings file,
# the slot lock and the findings grammar. No network, no real Codex. Spec:
# docs/superpowers/specs/2026-10-30-kit-051-codex-review-design.md §6.
# shellcheck disable=SC2016  # stub bodies are single-quoted on purpose
set -u
SCRIPT="$(cd "$(dirname "$0")/.." && pwd)/.agents/skills/gate-b-review/scripts/risk-pass.sh"
RISK_PASS_SH=${RISK_PASS_SH:-sh}
pass_n=0; fail_n=0
pass() { pass_n=$((pass_n + 1)); printf 'ok   - %s\n' "$1"; }
fail() { fail_n=$((fail_n + 1)); printf 'FAIL - %s\n' "$1"; }
work=$(mktemp -d) || exit 1
[ -n "$work" ] && [ -d "$work" ] || exit 1
work=$(cd "$work" && pwd -P)
trap 'rm -rf "$work"' EXIT
trap 'exit 1' HUP INT TERM

# Stub codex. `--version` prints $STUB_DIR/version. `exec` reads the prompt on stdin, finds the
# `Findings file:` path in it, runs $STUB_DIR/before when present, then acts on $STUB_DIR/mode:
# write (copy $STUB_DIR/findings there), none (write nothing), fail (exit 1), hang (sleep).
# It prints one --json event naming a model and writes the -o file.
mkdir -p "$work/stub"
cat > "$work/stub/codex" <<'EOF'
#!/bin/sh
[ "$1" = --version ] && { cat "$STUB_DIR/version"; exit 0; }
o=; prev=
for x in "$@"; do [ "$prev" = -o ] && o=$x; prev=$x; done
prompt=$(cat)
f=$(printf '%s\n' "$prompt" | sed -n 's/^Findings file: //p')
printf '%s\n' "$prompt" > "$STUB_DIR/last-prompt"
[ -f "$STUB_DIR/before" ] && sh "$STUB_DIR/before"
[ -f "$STUB_DIR/nomodel" ] || printf '{"type":"thread.started","model":"stub-model"}\n'
case $(cat "$STUB_DIR/mode") in
  write) cp "$STUB_DIR/findings" "$f" ;;
  none) ;;
  fail) echo 'stub: failed' >&2; exit 1 ;;
  hang) sleep 30 ;;
esac
echo 'BLOCKER 0 | MAJOR 1' > "$o"
EOF
chmod +x "$work/stub/codex"
STUB_DIR="$work/stub"; export STUB_DIR
PATH="$work/stub:$PATH"; export PATH
echo 'codex-cli 0.162.1' > "$work/stub/version"

repo="$work/re po"
mkdir -p "$repo"
git -C "$repo" init -q
git -C "$repo" config user.email t@example.invalid
git -C "$repo" config user.name t
echo a > "$repo/a"; git -C "$repo" add a; git -C "$repo" commit -qm base
B=$(git -C "$repo" rev-parse HEAD)
echo b > "$repo/a"; git -C "$repo" commit -qam head
H=$(git -C "$repo" rev-parse HEAD)
N=abcd1234
d="$repo/.context/codex-reviews"; mkdir -p "$d"
state="$d/gate-b-cycle-$N.state"
canon() { printf '%s/gate-b-risk-%s-pass-%s.md' "$d" "$N" "$1"; }
att() { printf '%s/gate-b-risk-%s-pass-%s-attempt-%s.md' "$d" "$N" "$1" "$2"; }
sha() { perl -MDigest::SHA -e 'print Digest::SHA->new(256)->addfile($ARGV[0])->hexdigest' "$1"; }
reset() { rm -rf "$d"; mkdir -p "$d"; printf 'base %s\n' "$B" > "$state"; rm -f "$STUB_DIR/before"; }
run() { "$RISK_PASS_SH" "$SCRIPT" "$repo" "$B" "$H" "$N" "$@" </dev/null >"$work/out" 2>"$work/err"; rc=$?; }
findings() { printf '%s\n' "$@" > "$STUB_DIR/findings"; echo write > "$STUB_DIR/mode"; }

F1='MAJOR | high | a:1 | p | c | s'
reset; findings "$F1" 'END OF FINDINGS (1 total)'
run 1 30
[ $rc -eq 0 ] && cmp -s "$(canon 1)" "$(att 1 1)" && pass 'a valid result: exit 0, promoted to the canonical file' || fail "valid rc=$rc $(cat "$work/err")"
grep -q "^risk 1 start 1 $H [0-9]*$" "$state" && grep -q "^risk 1 done 1 $H $(sha "$(canon 1)")$" "$state" && pass 'state: start and done lines bind attempt, head and sha256' || fail "state: $(cat "$state")"
e="$d/gate-b-risk-$N-pass-1-attempt-1-evidence.md"
grep -q '^CLI: codex-cli 0.162.1$' "$e" && grep -q "^HEAD: $H$" "$e" && grep -q '^MODEL: stub-model$' "$e" && pass 'evidence: CLI version, head and model from the event log' || fail "evidence: $(cat "$e" 2>/dev/null)"
grep -q 'branch `risk`' "$STUB_DIR/last-prompt" && grep -q "$B..$H" "$STUB_DIR/last-prompt" && pass 'the prompt names the risk branch and the range' || fail 'prompt'
[ ! -d "$d/gate-b-risk-$N-pass-1.lock" ] && pass 'lock released after success' || fail 'lock left'

# The live event log stays outside the reviewed checkout while Codex runs (run-tests.sh fingerprints
# .context/codex-reviews/), and is placed beside the attempt afterwards.
reset; findings 'NO FINDINGS' 'END OF FINDINGS (0 total)'; rm -f "$STUB_DIR/live"
printf 'ls "%s" | grep -q events && touch "%s/live"; :\n' "$d" "$STUB_DIR" > "$STUB_DIR/before"
run 1 30
[ $rc -eq 0 ] && [ ! -e "$STUB_DIR/live" ] && grep -q stub-model "$d/gate-b-risk-$N-pass-1-attempt-1.events.jsonl" && pass 'event log: outside the checkout during the run, placed after' || fail "live log rc=$rc"
# No model in the event log (Codex 0.162.1): the top-level `model` of $CODEX_HOME/config.toml.
reset; findings 'NO FINDINGS' 'END OF FINDINGS (0 total)'; touch "$STUB_DIR/nomodel"
mkdir -p "$work/ch"; printf '# c\nmodel = "cfg-model"\n[profiles.x]\nmodel = "other"\n' > "$work/ch/config.toml"
CODEX_HOME="$work/ch" run 1 30
grep -q '^MODEL: cfg-model (config.toml)$' "$e" && pass 'evidence: model from config.toml when the event log names none' || fail "config model: $(cat "$e" 2>/dev/null)"
rm -f "$STUB_DIR/nomodel"
# A takeover already in progress: busy, the dead lock left to that run.
reset; mkdir "$d/gate-b-risk-$N-pass-1.lock" "$d/gate-b-risk-$N-pass-1.lock.takeover"
echo 999999 > "$d/gate-b-risk-$N-pass-1.lock/runner.pid"
run 1 30
[ $rc -eq 4 ] && grep -q 'taking over' "$work/err" && [ "$(cat "$d/gate-b-risk-$N-pass-1.lock/runner.pid")" = 999999 ] && pass 'a takeover in progress: busy, exit 4, lock untouched' || fail "takeover rc=$rc"
rm -rf "$d/gate-b-risk-$N-pass-1.lock.takeover"
# A lock runner this process may not signal (EPERM) counts as alive.
reset; mkdir "$d/gate-b-risk-$N-pass-1.lock"; echo 1 > "$d/gate-b-risk-$N-pass-1.lock/runner.pid"
run 1 30
[ $rc -eq 4 ] && pass 'lock held by a runner it may not signal: busy, exit 4' || fail "EPERM lock rc=$rc"

reset; findings 'NO FINDINGS' 'END OF FINDINGS (0 total)'; run 1 30
[ $rc -eq 0 ] && pass 'a clean findings file is valid' || fail "clean rc=$rc"
reset; findings 'NIT | low | a | p | c | s' 'END OF FINDINGS (1 total)'; run 1 30
[ $rc -eq 0 ] && pass 'NIT is a valid severity' || fail "nit rc=$rc"
reset; findings 'MAJOR | high | a \| b | p | c | s' 'END OF FINDINGS (1 total)'; run 1 30
[ $rc -eq 0 ] && pass 'an escaped pipe is no separator' || fail "escaped rc=$rc"

bad() {
  reset; printf '%s\n' "$@" > "$STUB_DIR/findings"; echo write > "$STUB_DIR/mode"; run 1 30
  [ $rc -eq 1 ] && [ ! -f "$(canon 1)" ] && grep -q '^risk 1 failed 1 1$' "$state" && pass "invalid rejected: $*" || fail "invalid accepted ($rc): $*"
}
bad "$F1" 'END OF FINDINGS (2 total)'
bad 'NO FINDINGS' "$F1" 'END OF FINDINGS (1 total)'
bad 'NO FINDINGS' 'END OF FINDINGS (1 total)'
bad 'HIGH | high | a | p | c | s' 'END OF FINDINGS (1 total)'
bad 'MAJOR | high | a | p | c' 'END OF FINDINGS (1 total)'
bad 'MAJOR | high | a | p |  | s' 'END OF FINDINGS (1 total)'
bad "$F1" '' 'END OF FINDINGS (1 total)'
bad "$F1"
bad 'END OF FINDINGS (0 total)'

reset; echo none > "$STUB_DIR/mode"; run 1 30
[ $rc -eq 1 ] && [ ! -f "$(canon 1)" ] && pass 'no findings file: exit 1' || fail "none rc=$rc"
reset; echo fail > "$STUB_DIR/mode"; run 1 30
[ $rc -eq 1 ] && grep -q '^risk 1 failed 1 1$' "$state" && pass 'codex failing: exit 1, failed line' || fail "fail rc=$rc"
reset; echo hang > "$STUB_DIR/mode"; t0=$(date +%s); run 1 2; dt=$(( $(date +%s) - t0 ))
[ $rc -eq 3 ] && [ $dt -lt 15 ] && grep -q '^risk 1 failed 1 3$' "$state" && ! pgrep -f "$work/stub/codex" >/dev/null && pass "timeout: exit 3 in ${dt}s, codex stopped" || fail "timeout rc=$rc dt=$dt"

# A stale file from an earlier attempt and a late writer: attempt 1 left a valid file but never
# finished; attempt 2's codex, before and after the promotion, overwrites attempt 1's file.
reset; printf 'risk 1 start 1 %s 1\n' "$H" >> "$state"
printf '%s\n' "$F1" 'END OF FINDINGS (1 total)' > "$(att 1 1)"
findings 'NO FINDINGS' 'END OF FINDINGS (0 total)'
printf 'printf "late\\n" > "%s"\n' "$(att 1 1)" > "$STUB_DIR/before"
run 1 30
printf 'later\n' > "$(att 1 1)"
[ $rc -eq 0 ] && cmp -s "$(canon 1)" "$(att 1 2)" && grep -q '^NO FINDINGS$' "$(canon 1)" && pass 'a late writer of an earlier attempt cannot replace the result' || fail "late rc=$rc"
[ "$(grep -c "^risk 1 done " "$state")" = 1 ] && grep -q "^risk 1 done 2 $H $(sha "$(canon 1)")$" "$state" && pass 'the done line names attempt 2 and matches the canonical file' || fail "late state: $(cat "$state")"

# The slot lock: busy while its runner lives; taken over once runner and group are gone.
reset; findings 'NO FINDINGS' 'END OF FINDINGS (0 total)'
mkdir "$d/gate-b-risk-$N-pass-1.lock"; echo $$ > "$d/gate-b-risk-$N-pass-1.lock/runner.pid"
run 1 30
[ $rc -eq 4 ] && [ "$(grep -c '^risk' "$state")" = 0 ] && pass 'busy lock: exit 4, nothing touched' || fail "busy rc=$rc"
sh -c 'exit 0' & dead=$!; wait $dead
echo "$dead" > "$d/gate-b-risk-$N-pass-1.lock/runner.pid"; echo "$dead" > "$d/gate-b-risk-$N-pass-1.lock/group.pid"
printf 'risk 1 start 1 %s 1\n' "$H" >> "$state"
run 1 30
[ $rc -eq 0 ] && grep -q "^risk 1 done 2 $H " "$state" && pass 'an interrupted attempt is taken over: the run resumes as attempt 2' || fail "resume rc=$rc $(cat "$work/err")"

# Symlinks planted by a reviewer are never written through.
reset; findings 'NO FINDINGS' 'END OF FINDINGS (0 total)'
printf 'keep\n' > "$work/target"; ln -s "$work/target" "$(canon 1)"
run 1 30
[ $rc -eq 0 ] && [ ! -L "$(canon 1)" ] && [ "$(cat "$work/target")" = keep ] && pass 'a symlink at the canonical path is replaced, its target untouched' || fail "canon link rc=$rc"
reset; ln -s "$work/target" "$d/gate-b-risk-$N-pass-1-attempt-1.events.jsonl"
run 1 30
[ $rc -eq 1 ] && [ "$(cat "$work/target")" = keep ] && grep -q 'already exists' "$work/err" && pass 'a planted attempt file: exit 1, its target untouched' || fail "attempt link rc=$rc"
reset; findings 'NO FINDINGS' 'END OF FINDINGS (0 total)'
printf 'printf "late\\n" > "%s.real"; ln -s "%s.real" "%s"\n' "$work/target" "$work/target" "$(att 1 1)" > "$STUB_DIR/before"
echo none > "$STUB_DIR/mode"; run 1 30
[ $rc -eq 1 ] && [ ! -f "$(canon 1)" ] && pass 'a findings file that is a symlink is not promoted' || fail "findings link rc=$rc"
reset; mv "$d" "$work/real-reviews"; ln -s "$work/real-reviews" "$d"
run 1 30
[ $rc -eq 2 ] && grep -q 'is a symlink' "$work/err" && pass 'a symlinked .context/codex-reviews: exit 2' || fail "dir link rc=$rc"
rm -f "$d"; mkdir -p "$d"

# Swaps made while Codex runs (the stub's `before` hook plays the reviewer).
reset; findings 'NO FINDINGS' 'END OF FINDINGS (0 total)'
printf 'mv "%s" "%s"; ln -s "%s" "%s"\n' "$d" "$work/moved" "$work/moved" "$d" > "$STUB_DIR/before"
run 1 30
[ $rc -ne 0 ] && [ ! -f "$work/moved/gate-b-risk-$N-pass-1.md" ] && ! grep -q '^risk 1 \(done\|failed\)' "$work/moved/gate-b-cycle-$N.state" && pass 'the directory swapped for a symlink mid-run: nothing written through it' || fail "dir swap rc=$rc"
rm -f "$d"; rm -rf "$work/moved"; mkdir -p "$d"
reset; findings 'NO FINDINGS' 'END OF FINDINGS (0 total)'
printf 'cp "%s" "%s"; rm -f "%s"; ln "%s" "%s"\n' "$state" "$work/outside" "$state" "$work/outside" "$state" > "$STUB_DIR/before"
run 1 30
[ $rc -ne 0 ] && ! grep -q '^risk 1 done' "$work/outside" && pass 'the state file replaced by a hard link mid-run: not appended to' || fail "hardlink rc=$rc $(cat "$work/outside")"
reset; findings 'NO FINDINGS' 'END OF FINDINGS (0 total)'
mkdir -p "$work/somedir"; ln -s "$work/somedir" "$(canon 1)"
run 1 30
[ $rc -eq 0 ] && [ -f "$(canon 1)" ] && [ ! -L "$(canon 1)" ] && [ -z "$(ls "$work/somedir")" ] && pass 'a symlink to a directory at the canonical path is replaced, the directory untouched' || fail "dir link rc=$rc"
reset; findings 'NO FINDINGS' 'END OF FINDINGS (0 total)'
printf 'mkfifo "%s"; mkfifo "%s.tmp"; rm -f "%s"; mv "%s.tmp" "%s"\n' "$d/gate-b-risk-$N-pass-1-attempt-1-evidence.md" "$d/ev" "$d/gate-b-risk-$N-pass-1-attempt-1.events.jsonl" "$d/ev" "$d/gate-b-risk-$N-pass-1-attempt-1.events.jsonl" > "$STUB_DIR/before"
t0=$(date +%s); run 1 30; dt=$(( $(date +%s) - t0 ))
[ $dt -lt 20 ] && pass "FIFOs planted as evidence and event log: no hang (${dt}s, exit $rc)" || fail "fifo took ${dt}s"

# Refusals before anything is written.
reset; echo 'codex-cli 0.163.0' > "$work/stub/version"; run 1 30
[ $rc -eq 6 ] && [ "$(grep -c '^risk' "$state")" = 0 ] && pass 'another Codex CLI version: exit 6' || fail "version rc=$rc"
echo 'codex-cli 0.162.1' > "$work/stub/version"
rm -f "$state"; run 1 30
[ $rc -eq 2 ] && grep -q 'no cycle base' "$work/err" && pass 'no state file: exit 2' || fail "nostate rc=$rc"
printf 'base %s\n' "$H" > "$state"; run 1 30
[ $rc -eq 2 ] && grep -q 'differs from the cycle base' "$work/err" && pass 'baseSha not the cycle base: exit 2' || fail "base rc=$rc"
reset
mkdir "$work/bin"
for t in git sh "$RISK_PASS_SH" cat sed head grep date mktemp rm mkdir cp awk tail basename dirname; do
  p=$(command -v "$t") && ln -sf "$p" "$work/bin/$t"
done
ln -sf "$work/stub/codex" "$work/bin/codex"
PATH="$work/bin" "$RISK_PASS_SH" "$SCRIPT" "$repo" "$B" "$H" "$N" 1 30 </dev/null >/dev/null 2>"$work/err"; rc=$?
[ $rc -eq 5 ] && grep -q 'no process supervisor' "$work/err" && pass 'no perl: exit 5' || fail "noperl rc=$rc"

v() { "$RISK_PASS_SH" "$SCRIPT" "$@" </dev/null >/dev/null 2>"$work/err"; vrc=$?; [ $vrc -eq 2 ] && [ "$(grep -c '^risk' "$state")" = 0 ] && pass "rejected: $*" || fail "not rejected ($vrc): $*"; }
v "$repo" "$B" "$H" "$N"
v "$repo" ABC "$H" "$N" 1
v "$repo" "$B" "$(printf '%039d' 0)" "$N" 1
v "$repo" "$B" "$H" short 1
v "$repo" "$B" "$H" ABCD1234 1
v "$repo" "$B" "$H" abcd1234abcd1234x 1
v "$repo" "$B" "$H" "$N" 0
v "$repo" "$B" "$H" "$N" 01
v "$repo" "$B" "$H" "$N" x
v "$repo" "$B" "$H" "$N" 1 0
v "$repo" "$B" "$H" "$N" 1 7201
v "$work/nope" "$B" "$H" "$N" 1
v "$repo" "$B" "$(printf 'f%.0s' $(seq 40))" "$N" 1

printf '\n%d passed, %d failed\n' "$pass_n" "$fail_n"
[ "$fail_n" -eq 0 ]
