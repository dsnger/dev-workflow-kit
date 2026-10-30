#!/bin/sh
# Regression suite for .agents/skills/gate-b-review/scripts/run-tests.sh: builds a fixture
# repository and a TMPDIR, both with a space in their path, runs the script under
# RUN_TESTS_SH (sh by default; the quality command also runs it under dash) with stdin from
# /dev/null, and checks its report line, exit status, environment, copy removal, process-group
# handling and the checkout fingerprint. No network. Spec:
# docs/superpowers/specs/2026-10-30-kit-051-codex-review-design.md §5.
# shellcheck disable=SC2016  # the test commands are single-quoted on purpose: they expand in the copy
set -u
SCRIPT="$(cd "$(dirname "$0")/.." && pwd)/.agents/skills/gate-b-review/scripts/run-tests.sh"
RUN_TESTS_SH=${RUN_TESTS_SH:-sh}
pass_n=0; fail_n=0
pass() { pass_n=$((pass_n + 1)); printf 'ok   - %s\n' "$1"; }
fail() { fail_n=$((fail_n + 1)); printf 'FAIL - %s\n' "$1"; }
work=$(mktemp -d) || exit 1
[ -n "$work" ] && [ -d "$work" ] || exit 1
work=$(cd "$work" && pwd -P)
# Survivors of the KILL cases are tracked here and killed at the end, whatever happens.
trap 'for g in $(cat "$work/groups" 2>/dev/null); do perl -e "kill 9, -\$ARGV[0]" "$g" 2>/dev/null; done; rm -rf "$work"' EXIT
trap 'exit 1' HUP INT TERM

repo="$work/re po"
TMPDIR="$work/t mp"; export TMPDIR
mkdir -p "$TMPDIR" "$repo"
git -C "$repo" init -q
git -C "$repo" config user.email t@example.invalid
git -C "$repo" config user.name t
printf 'tracked\n' > "$repo/a.txt"
printf '.context/\nignored.txt\n' > "$repo/.gitignore"
git -C "$repo" add a.txt .gitignore
git -C "$repo" commit -qm init
H=$(git -C "$repo" rev-parse HEAD)
printf 'secret\n' > "$repo/untracked.env"

out="$work/out"; err="$work/err"
# run <seconds> <command…>: runs the script, sets rc, leaves stdout in $out and stderr in $err.
run() {
  s=$1; shift
  "$RUN_TESTS_SH" "$SCRIPT" "$repo" "$H" "$s" -- "$@" </dev/null >"$out" 2>"$err"; rc=$?
}
copies() { find "$TMPDIR" -maxdepth 1 -name 'gate-b-review.*' | wc -l | tr -d ' '; }

run 30 sh -c 'exit 0'
[ $rc -eq 0 ] && grep -q '^sh -c exit 0 | exit 0 | [0-9]*s$' "$out" && pass 'a passing command: exit 0 and its report line' || fail "pass: rc=$rc out=$(cat "$out")"
[ "$(copies)" = 0 ] && pass 'copy removed after success' || fail 'copy left after success'

run 30 sh -c 'echo boom >&2; exit 3'
[ $rc -eq 3 ] && grep -q '| exit 3 |' "$out" && grep -q boom "$err" && pass 'a failing command: its status, report and output on stderr' || fail "fail: rc=$rc"
[ "$(copies)" = 0 ] && pass 'copy removed after failure' || fail 'copy left after failure'

run 30 sh -c 'echo a|cat'
[ "$(wc -l < "$out" | tr -d ' ')" = 1 ] && grep -q 'echo a\\|cat' "$out" && pass 'a pipe in the command is escaped in the one report line' || fail "pipe: $(cat "$out")"

GATE_B_SENTINEL=leak; export GATE_B_SENTINEL
run 30 sh -c 'env > env.out; cp env.out "$HOME/../env.copy"; [ -z "${GATE_B_SENTINEL-}" ] && [ "$LANG" = C ]'
unset GATE_B_SENTINEL
[ $rc -eq 0 ] && pass 'environment stripped: a sentinel variable is absent, LANG=C' || fail "env: rc=$rc"

run 30 sh -c '[ -f a.txt ] && [ ! -e untracked.env ] && [ "$(git rev-parse HEAD)" = "$0" ]' "$H"
[ $rc -eq 0 ] && pass 'the copy holds tracked files at the head, not the untracked file' || fail "copy content: rc=$rc"

run 30 sh -c 'cat; echo finished'
[ $rc -eq 0 ] && grep -q finished "$err" && pass 'stdin is /dev/null: a reading test does not hang' || fail "stdin: rc=$rc"

run 30 sh -c 'i=0; while [ $i -lt 1000 ]; do echo line$i; i=$((i+1)); done'
[ "$(wc -l < "$err" | tr -d ' ')" = 200 ] && grep -q line999 "$err" && pass 'output bounded to its last 200 lines' || fail "bounded: $(wc -l < "$err")"

# Timeout: the command spawns a child that ignores TERM; the whole group is gone afterwards.
start=$(date +%s)
run 2 sh -c 'sh -c "trap \"\" TERM; echo \$\$ > \"$0\"; while :; do sleep 1; done" & wait' "$work/child.pid"
dur=$(( $(date +%s) - start ))
child=$(cat "$work/child.pid" 2>/dev/null)
[ $rc -eq 124 ] && grep -q '| exit timeout |' "$out" && pass 'timeout: exit 124 and `exit timeout`' || fail "timeout: rc=$rc out=$(cat "$out")"
[ -n "$child" ] && ! kill -0 "$child" 2>/dev/null && pass 'timeout: the TERM-ignoring child is killed' || fail "timeout child $child alive"
[ $dur -lt 20 ] && pass "timeout bounded (${dur}s)" || fail "timeout took ${dur}s"
[ "$(copies)" = 0 ] && pass 'copy removed after timeout' || fail 'copy left after timeout'

# A background child left behind by a passing command is stopped too.
run 30 sh -c 'sh -c "echo \$\$ > \"$0\"; sleep 60" & exit 0' "$work/bg.pid"
sleep 1; bg=$(cat "$work/bg.pid" 2>/dev/null)
[ $rc -eq 0 ] && [ -n "$bg" ] && ! kill -0 "$bg" 2>/dev/null && pass 'a leftover background child is stopped on normal exit' || fail "bg $bg alive"

# INT to the runner: copy and group gone. A background job of a non-interactive shell starts
# with INT ignored (POSIX), so perl restores the default before starting the runner.
perl -e '$SIG{INT} = "DEFAULT"; exec @ARGV' "$RUN_TESTS_SH" "$SCRIPT" "$repo" "$H" 60 -- sh -c 'sleep 60' </dev/null >"$out" 2>"$err" &
r=$!; sleep 2; kill -INT $r; wait $r; rc=$?
[ $rc -eq 130 ] && pass 'INT: exit 130' || fail "INT rc=$rc"
[ "$(copies)" = 0 ] && pass 'copy removed after INT' || fail 'copy left after INT'

# The runner killed with KILL while its command survives: the next run reports and keeps that
# copy; once the group is gone, the next run removes it.
"$RUN_TESTS_SH" "$SCRIPT" "$repo" "$H" 60 -- sh -c 'sleep 60' </dev/null >/dev/null 2>&1 &
r=$!; sleep 2
d=$(find "$TMPDIR" -maxdepth 1 -name 'gate-b-review.*' | head -1)
g=$(cat "$d/group.pid" 2>/dev/null); w=$(pgrep -P "$r" | head -5)
echo "$g" >> "$work/groups"
for p in $w; do kill -0 "$p" 2>/dev/null && [ "$p" != "$g" ] && perl -e 'kill 9, -$ARGV[0]' "$p"; done
kill -KILL $r; wait $r 2>/dev/null
run 30 sh -c 'exit 0'
[ -d "$d" ] && grep -q "stale copy .* with live process group $g" "$err" && pass 'stale copy with a live group: reported and left' || fail "stale live: $(cat "$err")"
perl -e 'kill 9, -$ARGV[0]' "$g"; sleep 1
run 30 sh -c 'exit 0'
[ ! -d "$d" ] && pass 'stale copy with runner and group gone: removed' || fail 'stale dead copy left'
# A runner this process may not signal (EPERM, as Codex's sandbox sees a parallel review's runner) is alive.
d="$TMPDIR/gate-b-review.eperm"; mkdir -p "$d"; echo 1 > "$d/runner.pid"
run 30 sh -c 'exit 0'
[ -d "$d" ] && pass 'stale scan: a runner it may not signal counts as alive, its copy is kept' || fail 'EPERM runner: copy removed'
rm -rf "$d"

# Checkout writes: by absolute path, staged-and-restored, executable bit of an untracked file.
run 30 sh -c 'echo x >> "$0/a.txt"' "$repo"
[ $rc -eq 4 ] && grep -q 'checkout changed' "$err" && pass 'a write to the checkout by absolute path: exit 4' || fail "abs write rc=$rc"
git -C "$repo" checkout -q -- a.txt
run 30 sh -c 'cd "$0" && echo y >> a.txt && git add a.txt && git show HEAD:a.txt > a.txt' "$repo"
[ $rc -eq 4 ] && pass 'staged change with the working file restored: exit 4' || fail "staged rc=$rc"
git -C "$repo" reset -q; git -C "$repo" checkout -q -- a.txt
run 30 chmod +x "$repo/untracked.env"
[ $rc -eq 4 ] && pass 'executable bit set on an untracked file: exit 4' || fail "chmod rc=$rc"
chmod -x "$repo/untracked.env"
run 30 sh -c 'echo z > "$0/ignored.txt"; mkdir -p "$0/.context"; echo z > "$0/.context/x"' "$repo"
[ $rc -eq 0 ] && pass 'ignored files and .context/ are outside the fingerprint (stated limit)' || fail "ignored rc=$rc"

mkdir -p "$repo/.context/codex-reviews"
run 30 sh -c 'echo forged > "$0/.context/codex-reviews/gate-b-quality-x-pass-1.md"' "$repo"
[ $rc -eq 4 ] && pass 'a write to .context/codex-reviews/ (the gate records): exit 4' || fail "records rc=$rc"
rm -f "$repo/.context/codex-reviews/gate-b-quality-x-pass-1.md"
mkfifo "$repo/.context/codex-reviews/fifo"
t0=$(date +%s); run 30 sh -c 'exit 0'; dt=$(( $(date +%s) - t0 ))
[ $rc -eq 0 ] && [ $dt -lt 20 ] && pass 'a FIFO among the gate records does not block the fingerprint' || fail "fifo rc=$rc dt=$dt"
rm -f "$repo/.context/codex-reviews/fifo"
run 30 sh -c '[ -z "$(git remote)" ]'
[ $rc -eq 0 ] && pass 'the copy has no remote' || fail "remote rc=$rc"

# No perl on PATH: exit 5, nothing run. The PATH holds only links to what the script needs.
mkdir "$work/bin"
for t in git sh "$RUN_TESTS_SH" cat date tail sed tr mktemp rm mkdir find dirname; do
  p=$(command -v "$t") && ln -sf "$p" "$work/bin/$t"
done
PATH="$work/bin" "$RUN_TESTS_SH" "$SCRIPT" "$repo" "$H" 30 -- sh -c 'touch "$0/ran"' "$work" </dev/null >"$out" 2>"$err"; rc=$?
[ $rc -eq 5 ] && [ ! -e "$work/ran" ] && grep -q 'no process supervisor' "$err" && pass 'no perl: exit 5, nothing run' || fail "no perl rc=$rc"

# Two runs at once: the second's stale scan leaves the first's live copy alone.
"$RUN_TESTS_SH" "$SCRIPT" "$repo" "$H" 60 -- sh -c 'sleep 4; exit 0' </dev/null >"$work/out1" 2>&1 &
r=$!; sleep 1
run 30 sh -c 'exit 0'
wait $r; rc1=$?
[ $rc1 -eq 0 ] && [ $rc -eq 0 ] && pass 'concurrent runs: both succeed, neither removes the other' || fail "concurrent rc1=$rc1 rc=$rc $(cat "$work/out1")"

# Validation: exit 2, nothing created.
before=$(copies)
v() { "$RUN_TESTS_SH" "$SCRIPT" "$@" </dev/null >/dev/null 2>"$err"; vrc=$?; [ $vrc -eq 2 ] && [ "$(copies)" = "$before" ] && pass "rejected: $1 | $2 | $3 | ${4-}" || fail "not rejected ($vrc): $*"; }
v "$repo" "$H" 30
v "$repo" "$H" 30 x true
v "$repo" ABC 30 -- true
v "$repo" "$(printf '%040d' 0 | tr 0 G)" 30 -- true
v "$repo" "$(printf '%039d' 0)" 30 -- true
v "$repo" "$(printf '%s' "$H" | tr abcdef ABCDEF)" 30 -- true
v "$repo" "$(printf 'f%.0s' $(seq 40))" 30 -- true
v "$repo" "$H" 0 -- true
v "$repo" "$H" 1801 -- true
v "$repo" "$H" 1x -- true
v "$work/nope" "$H" 30 -- true
v "$work" "$H" 30 -- true
run '' sh -c 'exit 0'
[ $rc -eq 0 ] && pass 'empty seconds means the default' || fail "default rc=$rc"

printf '\n%d passed, %d failed\n' "$pass_n" "$fail_n"
[ "$fail_n" -eq 0 ]
