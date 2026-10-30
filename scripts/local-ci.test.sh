#!/bin/sh
# Regression suite for local-ci.sh: each group builds a bare origin and a clone whose origin URL
# names github.com/acme/widgets, puts stub gh, shellcheck and claude and a git wrapper first in
# PATH, runs the script from the clone and checks its exit status, the gh calls it made, what the
# fixture's battery recorded and that no worktree or directory is left. It runs no real battery
# and reaches no network. Spec: docs/superpowers/specs/2026-10-28-kit-local-ci-design.md §3.
set -u
SCRIPT="$(cd "$(dirname "$0")" && pwd)/local-ci.sh"
# LOCAL_CI_SH selects the shell the SCRIPT runs under (as HOOK_SH does for the hook suite).
LOCAL_CI_SH=${LOCAL_CI_SH:-sh}
pass_n=0; fail_n=0
pass() { pass_n=$((pass_n + 1)); printf 'ok   - %s\n' "$1"; }
fail() { fail_n=$((fail_n + 1)); printf 'FAIL - %s\n' "$1"; }
work=$(mktemp -d) || exit 1
[ -n "$work" ] && [ -d "$work" ] || exit 1
work=$(cd "$work" && pwd -P)
bg=''
# shellcheck disable=SC2086  # $bg is a list of pids
trap 'kill $bg 2>/dev/null; chmod -R u+rwx "$work" 2>/dev/null; rm -rf "$work"' EXIT
# 0.52: no inherited heavy-lock setting reaches a run (this suite runs inside a locked battery, whose
# SFX_HEAVY_HELD would skip every lock case), and HOME is the suite's own, so no run finds the real
# machine-wide lock; each lock case sets its own values.
unset SFX_HEAVY_LOCK SFX_HEAVY_HELD HEAVY_LOCK_WAIT_SECS LOCAL_CI_TEST_WALK_PAUSE
HOME=$work/home; export HOME; mkdir -p "$HOME"
trap 'exit 1' HUP INT TERM

# Stubs. gh: appends each call's arguments, one per line, then one "env ..." line with GH_TOKEN,
# HOME, GH_REPO and GH_HOST, to $work/gh.args; `auth` exits with $work/gh.auth.rc, `api` prints a
# canned body and exits with $work/gh.rc (default 0 each). shellcheck: a --version text whose
# version line is $work/shellcheck.v. claude: prints $work/claude.out when present, else
# "9.9.9 (stub)". git: fails `worktree add` when $work/git.failadd exists and `worktree remove`
# when $work/git.failrm exists, otherwise runs the real git.
mkdir -p "$work/stub" "$work/tools"
cat > "$work/stub/gh" <<'EOF'
#!/bin/sh
{ printf '%s\n' "$@"
  printf 'env GH_TOKEN=%s HOME=%s GH_REPO=%s GH_HOST=%s\n' "${GH_TOKEN-}" "${HOME-}" "${GH_REPO-}" "${GH_HOST-}"
} >> "$STUB_DIR/gh.args"
case $1 in
  auth) exit "$(cat "$STUB_DIR/gh.auth.rc" 2>/dev/null || echo 0)" ;;
esac
# A status read (an api call with --jq and no --method, 0.50): $STUB_DIR/gh.status as the body,
# filtered by that --jq with the real jq; exits with $STUB_DIR/gh.status.rc when present.
case " $* " in *" --method "*) ;; *" --jq "*)
  f=; for a in "$@"; do [ "$f" = 1 ] && { f=$a; break; }; [ "$a" = --jq ] && f=1; done
  rc=$(cat "$STUB_DIR/gh.status.rc" 2>/dev/null || echo 0); [ "$rc" = 0 ] || exit "$rc"
  [ -f "$STUB_DIR/gh.onread" ] && sh "$STUB_DIR/gh.onread"
  "$REAL_JQ" -r "$f" "$STUB_DIR/gh.status"; exit ;;
esac
case $1 in
  api) echo '{"stub":"body"}'; rc=$(cat "$STUB_DIR/gh.rc" 2>/dev/null || echo 0)
       [ "$rc" = 0 ] || echo 'gh: stub failure (HTTP 422)' >&2
       exit "$rc" ;;
esac
EOF
cat > "$work/stub/shellcheck" <<'EOF'
#!/bin/sh
printf 'ShellCheck - shell script analysis tool\nversion: %s\nlicense: GNU General Public License, version 3\n' "$(cat "$STUB_DIR/shellcheck.v")"
EOF
cat > "$work/stub/claude" <<'EOF'
#!/bin/sh
if [ -f "$STUB_DIR/claude.out" ]; then cat "$STUB_DIR/claude.out"; else echo '9.9.9 (stub)'; fi
EOF
cat > "$work/stub/git" <<'EOF'
#!/bin/sh
case " $* " in
  *" worktree add "*) [ -f "$STUB_DIR/git.failadd" ] && { echo 'stub: worktree add failed' >&2; exit 128; } ;;
  *" worktree remove "*) [ -f "$STUB_DIR/git.failrm" ] && { echo 'stub: worktree remove failed' >&2; exit 128; } ;;
  *" diff --name-only "*) [ -f "$STUB_DIR/git.faildiff" ] && { echo 'stub: diff failed' >&2; exit 128; } ;;
esac
exec "$REAL_GIT" "$@"
EOF
chmod +x "$work/stub/gh" "$work/stub/shellcheck" "$work/stub/claude" "$work/stub/git"
# No stub, no run: with a logged-in gh on PATH a missing stub would make a real, authenticated call.
for s in gh shellcheck claude git; do [ -x "$work/stub/$s" ] || { echo "stub $s missing; abort" >&2; exit 1; }; done
# PATHs without gh or without claude: the other stubs plus links to the tools the script, the
# stubs and the battery need.
cp -R "$work/stub" "$work/nogh" && rm "$work/nogh/gh"
cp -R "$work/stub" "$work/noclaude" && rm "$work/noclaude/claude"
for t in sh "$LOCAL_CI_SH" env sed awk mktemp rm cat ls grep tail; do
  [ -e "$work/tools/$t" ] || { p=$(command -v "$t") && ln -s "$p" "$work/tools/$t"; }
done
REAL_GIT=$(command -v git)
REAL_JQ=$(command -v jq) || { echo 'jq missing; the 0.50 lane cases need it; abort' >&2; exit 1; }
export STUB_DIR="$work" REAL_GIT REAL_JQ

# The fixture's battery: records where and at which commit it ran, under which LC_ALL, and the
# worktree's file names; passes output through; exits with the committed exit.code.
# 0.52: it also records the SFX_HEAVY_HELD it got, and whether a lock holder had finished first.
cat > "$work/battery.src" <<'EOF'
printf '%s' "${SFX_HEAVY_HELD-unset}" > "$STUB_DIR/battery.held"
[ -e "$STUB_DIR/holder.done" ] && touch "$STUB_DIR/after.holder"
printf '%s\n%s\nLC_ALL=%s\n' "$(pwd -P)" "$(git rev-parse HEAD)" "${LC_ALL-unset}" > "$STUB_DIR/battery.ran"
ls -A > "$STUB_DIR/battery.ls"
echo battery-stdout; echo battery-stderr >&2
exit "$(cat exit.code)"
EOF

# Fresh fixture: origin (bare) and clone r, one commit with AGENTS.md (a backtick in the quality
# row's label), ci.yml (one shellcheck pin), battery.sh and exit.code 0; runs start in r.
fixture() {
  rm -rf "$work/o.git" "$work/r" "$work/other" "$work/lane" "$work/stale" "$work/tmp" "$work/tmp dir" \
    "$work"/gh.* "$work"/git.* "$work/claude.out" "$work/light.ran" "$work/home/.cache" "$work/lk" \
    "$work/held" "$work/holder.done" "$work/after.holder" "$work/battery.held" "$work/stage1" "$work/go" "$work/orphan.pid"
  mkdir -p "$work/tmp"; echo 0.11.0 > "$work/shellcheck.v"
  cwd=$work/r; path=$work/stub:$PATH
  git init -q --bare -b main "$work/o.git"
  git clone -q "$work/o.git" "$work/r" 2>/dev/null
  mkdir -p "$work/r/.github/workflows"
  cp "$work/battery.src" "$work/r/battery.sh"; echo 0 > "$work/r/exit.code"
  cat > "$work/r/AGENTS.md" <<'EOF'
| Role | Command |
|---|---|
| quality (fixture, `x`) | `sh ./battery.sh` |
| lint | `true` |
EOF
  echo '      - run: docker run --rm koalaman/shellcheck:v0.11.0 --shell=sh x.sh' > "$work/r/.github/workflows/ci.yml"
  ( cd "$work/r" && git config user.email t@t && git config user.name t &&
    git remote set-url origin https://github.com/acme/widgets.git && git config remote.origin.pushurl "$work/o.git" &&
    git add -A && git commit -q -m init && git push -q origin main 2>/dev/null )
}
# put <file>: stdin becomes <file> in the clone, committed.
put() { cat > "$work/r/$1" && git -C "$work/r" add "$1" && git -C "$work/r" commit -q -m "$1"; }
sha_of() { git -C "$work/r" rev-parse "$1"; }
# go [NAME=value]... <command>...: run it from $cwd with PATH=$path, TMPDIR=$work/tmp and the
# given environment; stdout, stderr and the exit status land in $work/out, $work/err and $work/rc.
go() {
  rm -f "$work/gh.args" "$work/battery.ran" "$work/battery.ls"
  ( cd "$cwd" && exec env PATH="$path" TMPDIR="$work/tmp" "$@" ) > "$work/out" 2> "$work/err"
  echo $? > "$work/rc"
}
run() { go "$LOCAL_CI_SH" "$SCRIPT" "$@"; }
# runenv NAME=value...: the same run with extra environment for the script.
runenv() { go "$@" "$LOCAL_CI_SH" "$SCRIPT"; }
rc_is() { [ "$(cat "$work/rc")" = "$1" ]; }
diag() {
  printf 'rc %s; out: %s; err: %s; gh: %s' "$(cat "$work/rc" 2>/dev/null)" "$(cat "$work/out" 2>/dev/null)" \
    "$(cat "$work/err" 2>/dev/null)" "$(cat "$work/gh.args" 2>/dev/null | tr '\n' ' ')"
}
wts() { git -C "$work/r" worktree list --porcelain | sed -n 's/^worktree //p'; }
# clean: the clone is the only worktree and the temporary directory holds nothing.
clean() { [ "$(wts)" = "$work/r" ] && [ -z "$(ls -A "$work/tmp")" ]; }
ran_at() { [ "$(sed -n 2p "$work/battery.ran" 2>/dev/null)" = "$1" ]; }
not_posted() { ! grep -qx -- --method "$work/gh.args" 2>/dev/null; }
# last_api: the arguments of the last gh api call (a post follows any status read).
last_api() { awk '/^api$/ { b = "" } { b = b $0 "\n" } END { printf "%s", b }' "$work/gh.args" 2>/dev/null | grep -v '^env '; }
auth_call() { [ "$(sed -n 1,4p "$work/gh.args" 2>/dev/null)" = "$(printf '%s\n' auth status --hostname github.com)" ]; }
# called <state> <word> <sha> [<claude version>]: exactly one api call, argument for argument.
called() {
  [ "$(last_api)" = "$(printf '%s\n' api \
    --hostname github.com --method POST -H 'X-GitHub-Api-Version: 2026-03-10' "repos/acme/widgets/statuses/$3" \
    -f "state=$1" -f context=quality -f "description=battery $2: local run, ${SCP-shellcheck 0.11.0, }claude ${4:-9.9.9}")" ]
}
# posted: called, and the last stdout line reports that post.
posted() {
  called "$@" &&
    [ "$(tail -n 1 "$work/out")" = "local-ci: posted quality=$1 on $3: battery $2: local run, ${SCP-shellcheck 0.11.0, }claude ${4:-9.9.9}" ]
}
# finished <rc> <state> <word> <sha> [<claude version>]: exit <rc>, the battery ran at <sha>, that
# post was made and reported, and nothing is left behind.
finished() { rc_is "$1" && ran_at "$4" && posted "$2" "$3" "$4" ${5:+"$5"} && clean; }
# refused <name> <line>: exit 64 with exactly that line on stderr and nothing on stdout; the
# battery never ran, nothing was posted, nothing is left behind.
refused() {
  if rc_is 64 && [ "$(cat "$work/err")" = "$2" ] && [ ! -s "$work/out" ] && [ ! -e "$work/battery.ran" ] &&
     not_posted && clean; then pass "$1"; else fail "$1 ($(diag))"; fi
}
ROW_MSG='has no single quality row with one command in backticks as its last cell; keep exactly one "| quality " row'
USAGE='usage: sh scripts/local-ci.sh [--from <green> | --lane <base>] [<commit>]'
URL_MSG='local-ci: origin is missing or not a github.com repository URL; point origin at https://github.com/<owner>/<repo>.git'

# --- 1: green battery ---
fixture; sha=$(sha_of HEAD); run
finished 0 success green "$sha" && pass "1 green battery: success posted to the SHA, exit 0" || fail "1 green battery ($(diag))"
auth_call && pass "1 gh auth status --hostname github.com was asked first" || fail "1 auth call ($(diag))"
d=$(sed -n 1p "$work/battery.ran" 2>/dev/null)
case $d in "$work/tmp/"*/wt) pass "1 the battery ran in a temporary worktree under TMPDIR" ;;
  *) fail "1 the battery ran in ${d:-nowhere}" ;; esac
[ "$(cat "$work/out")" = "$(printf 'battery-stdout\n%s' "local-ci: posted quality=success on $sha: battery green: local run, shellcheck 0.11.0, claude 9.9.9")" ] &&
  [ "$(cat "$work/err")" = battery-stderr ] && pass "1 battery output passes through; gh's body and git's chatter do not" || fail "1 output ($(diag))"

# --- 2, 3: red battery; the exit status is the battery's ---
fixture; echo 1 | put exit.code; sha=$(sha_of HEAD); run
finished 1 failure red "$sha" && pass "2 red battery: failure posted, exit 1" || fail "2 red battery ($(diag))"
for c in 7 2 3; do
  echo "$c" | put exit.code; sha=$(sha_of HEAD); run
  finished "$c" failure red "$sha" && pass "3 battery exit $c: failure posted, exit $c" || fail "3 battery exit $c ($(diag))"
done

# --- 4: the post fails ---
fixture; sha=$(sha_of HEAD); echo 1 > "$work/gh.rc"; run
rc_is 75 && ran_at "$sha" && called success green "$sha" && ! grep -q 'local-ci: posted' "$work/out" && clean &&
  grep -qxF "local-ci: post failed for quality=success on $sha; rerun after fixing gh" "$work/err" &&
  pass "4 green battery, failing post: exit 75, stderr names success and the SHA" || fail "4 green, failing post ($(diag))"
echo 1 | put exit.code; sha=$(sha_of HEAD); run
rc_is 75 && ran_at "$sha" && called failure red "$sha" && clean &&
  grep -qxF "local-ci: post failed for quality=failure on $sha; rerun after fixing gh" "$work/err" &&
  pass "4 red battery, failing post: exit 75, stderr names failure" || fail "4 red, failing post ($(diag))"

# --- 5, 6: gh ---
fixture; path=$work/nogh:$work/tools; run
refused "5 gh not on PATH: exit 64, nothing ran or posted" \
  'local-ci: gh is not on PATH; install the GitHub CLI, then run gh auth login --hostname github.com'
fixture; echo 1 > "$work/gh.auth.rc"; run
refused "6 gh auth status failing: exit 64" \
  'local-ci: gh auth status --hostname github.com failed; run it to see why, then gh auth login --hostname github.com'

# --- 7, 8: shellcheck parity with the commit's ci.yml ---
fixture; echo 0.10.0 > "$work/shellcheck.v"; run
refused "7 shellcheck 0.10.0 against a 0.11.0 pin: exit 64, nothing ran" \
  'local-ci: local shellcheck is 0.10.0, ci.yml pins 0.11.0; install shellcheck 0.11.0'
fixture; printf 'a: koalaman/shellcheck:v0.11.0\nb: koalaman/shellcheck:v0.10.0\n' | put .github/workflows/ci.yml; run
refused "8 ci.yml pinning two versions: exit 64" \
  "local-ci: .github/workflows/ci.yml at $(sha_of HEAD) pins more than one shellcheck version; pin one koalaman/shellcheck:v<version>"
# 0.49: a project without the kit's pin (no ci.yml, or one without a shellcheck pin) skips the
# parity check, and the description drops the shellcheck part; a mismatched local shellcheck
# proves the check did not run.
echo 'no pin' | put .github/workflows/ci.yml; echo 0.10.0 > "$work/shellcheck.v"; run
SCP=''; finished 0 success green "$(sha_of HEAD)" && pass "8 ci.yml without a pin: no parity check, no shellcheck part" ||
  fail "8 ci.yml without a pin ($(diag))"
fixture; git -C "$work/r" rm -q .github/workflows/ci.yml && git -C "$work/r" commit -q -m 'no ci'
echo 0.10.0 > "$work/shellcheck.v"; run
finished 0 success green "$(sha_of HEAD)" && pass "8 no ci.yml: no parity check, no shellcheck part" ||
  fail "8 no ci.yml ($(diag))"
unset SCP; echo 0.11.0 > "$work/shellcheck.v"
fixture
printf 'a: koalaman/shellcheck:v0.11.0 \\\nb: koalaman/shellcheck:v0.11.0\n' | put .github/workflows/ci.yml; run
finished 0 success green "$(sha_of HEAD)" && pass "8 several pins of one version pass" || fail "8 one version twice ($(diag))"

# --- 9, 9b: the quality row; usage; precondition 1 ---
fixture
put AGENTS.md <<'EOF'
| Role | Command |
| lint | `true` |
EOF
run
refused "9 quality row missing: exit 64" "local-ci: AGENTS.md at $(sha_of HEAD) $ROW_MSG"
put AGENTS.md <<'EOF'
| quality a | `sh ./battery.sh` |
| quality b | `true` |
EOF
run
refused "9 two quality rows: exit 64" "local-ci: AGENTS.md at $(sha_of HEAD) $ROW_MSG"
echo '| quality (fixture) | sh ./battery.sh |' | put AGENTS.md; run
refused "9 a quality row whose last cell is not in backticks: exit 64" "local-ci: AGENTS.md at $(sha_of HEAD) $ROW_MSG"
fixture; run HEAD extra
refused "9 a second argument: usage, exit 64" "$USAGE"
run --help
refused "9 an option-like argument: usage, exit 64" "$USAGE"
run nosuchref
refused "9 a name that is no commit: exit 64" \
  'local-ci: nosuchref does not name a commit here; pass a commit, branch or tag of this repository'
cwd=$work; run
refused "9 outside a git work tree: exit 64" \
  'local-ci: the current directory is not inside a git work tree; run it from the repository root'
fixture
put AGENTS.md <<'EOF'
| quality (a \| b, `x`) | `sh ./battery.sh && echo second-command` |
EOF
run
finished 0 success green "$(sha_of HEAD)" && grep -qx second-command "$work/out" &&
  pass "9b a label holding \\| and backticks: the last cell runs, verbatim" || fail "9b ($(diag))"

# --- 10: uncommitted and untracked changes stay out ---
fixture; sha=$(sha_of HEAD)
echo 1 > "$work/r/exit.code"; git -C "$work/r" add exit.code; echo u > "$work/r/untracked.txt"; run
finished 0 success green "$sha" && pass "10 a staged edit to exit 1 does not reach the run: green" || fail "10 edit ($(diag))"
grep -qx battery.sh "$work/battery.ls" && ! grep -qx untracked.txt "$work/battery.ls" &&
  pass "10 an untracked file in the clone is not in the worktree" || fail "10 untracked: $(cat "$work/battery.ls")"
[ "$(git -C "$work/r" status --porcelain)" = "$(printf 'M  exit.code\n?? untracked.txt')" ] &&
  pass "10 the caller's changes stay as they were" || fail "10 caller changed: $(git -C "$work/r" status --porcelain)"

# --- 11: an explicit older commit ---
fixture; echo 1 | put exit.code; old=$(sha_of HEAD); echo 0 | put exit.code; new=$(sha_of HEAD); run main~1
finished 1 failure red "$old" && pass "11 main~1: failure posted to its full SHA" || fail "11 ($(diag))"
[ "$(sha_of HEAD)" = "$new" ] && [ "$(git -C "$work/r" symbolic-ref HEAD)" = refs/heads/main ] &&
  pass "11 HEAD unchanged" || fail "11 HEAD moved"

# --- 12, 12b, 13: the origin URL ---
fixture
for u in https://gitlab.com/acme/widgets.git https://github.com.evil.example/acme/widgets.git; do
  git -C "$work/r" remote set-url origin "$u"; run
  refused "12 origin $u: exit 64" "$URL_MSG"
done
git -C "$work/r" remote set-url origin https://github.com/acme/widgets/; run
refused "12b origin with a trailing slash: exit 64, no guessed slug" "$URL_MSG"
for u in git@github.com:acme/widgets.git ssh://git@github.com/acme/widgets.git https://github.com/acme/widgets; do
  git -C "$work/r" remote set-url origin "$u"; run
  finished 0 success green "$(sha_of HEAD)" && pass "13 origin $u posts to repos/acme/widgets" || fail "13 $u ($(diag))"
done
git -C "$work/r" remote remove origin; run
refused "12 origin missing: exit 64" "$URL_MSG"

# --- 14: the token and HOME stay out of the arguments (finished compares them exactly) and the output ---
fixture; sha=$(sha_of HEAD); runenv GH_TOKEN=stubsecret HOME="$work"
finished 0 success green "$sha" && ! grep -qF stubsecret "$work/out" "$work/err" &&
  grep -qF "env GH_TOKEN=stubsecret HOME=$work " "$work/gh.args" &&
  pass "14 GH_TOKEN and HOME reach gh by environment only, never in an argument or the description" || fail "14 ($(diag))"

# --- 15: TERM while the battery runs ---
fixture
put battery.sh <<'EOF'
touch "$STUB_DIR/stage1"
sleep 2
touch "$STUB_DIR/stage2"
EOF
rm -f "$work/gh.args" "$work/stage1" "$work/stage2"
( cd "$cwd" && exec env PATH="$path" TMPDIR="$work/tmp" "$LOCAL_CI_SH" "$SCRIPT" ) > "$work/out" 2> "$work/err" &
pid=$!
i=0; while [ ! -e "$work/stage1" ] && [ "$i" -lt 100 ]; do sleep 0.1; i=$((i + 1)); done
kill -TERM "$pid"; wait "$pid"; echo $? > "$work/rc"
[ -e "$work/stage2" ] && not_posted && clean &&
  pass "15 TERM during the run: the command ran through, nothing posted, no worktree left" || fail "15 ($(diag))"
rc_is 143 && pass "15 ... and the script exits 143" || fail "15 exit ($(diag))"

# --- 16: GH_REPO and GH_HOST are not consulted ---
fixture; sha=$(sha_of HEAD); runenv GH_REPO=evil/other GH_HOST=ghe.example.com
finished 0 success green "$sha" && auth_call &&
  pass "16 GH_REPO/GH_HOST set: auth and post still name github.com and repos/acme/widgets" || fail "16 ($(diag))"

# --- 17: inherited GIT_DIR, GIT_WORK_TREE and GIT_INDEX_FILE aim at another repository ---
fixture; sha=$(sha_of HEAD)
git init -q -b main "$work/other"
( cd "$work/other" && git config user.email t@t && git config user.name t && echo o > o && git add o && git commit -q -m other )
state_other() { git -C "$work/other" rev-parse HEAD; cksum < "$work/other/.git/index"; git -C "$work/other" worktree list --porcelain; }
before=$(state_other)
runenv GIT_DIR="$work/other/.git" GIT_WORK_TREE="$work/other" GIT_INDEX_FILE="$work/other/.git/index"
finished 0 success green "$sha" && [ "$(state_other)" = "$before" ] &&
  pass "17 git variables aimed elsewhere: the battery ran at the requested SHA, the other repository is unchanged" ||
  fail "17 ($(diag))"

# --- 18: setup failures ---
fixture; : > "$work/git.failadd"; run
rc_is 64 && grep -qxF "local-ci: could not add a worktree of $(sha_of HEAD); see the git error above" "$work/err" &&
  [ ! -e "$work/battery.ran" ] && not_posted && clean &&
  pass "18 git worktree add failing: exit 64, nothing ran or posted, no directory left" || fail "18 add ($(diag))"
rm -f "$work/git.failadd"; runenv TMPDIR="$work/missing"
rc_is 64 && grep -qxF 'local-ci: could not create a temporary directory; check TMPDIR' "$work/err" &&
  [ ! -e "$work/battery.ran" ] && not_posted && clean && pass "18 mktemp failing: exit 64" || fail "18 mktemp ($(diag))"

# --- 19: the removal fails ---
fixture; sha=$(sha_of HEAD)
git -C "$work/r" worktree add -q --detach "$work/stale" HEAD && rm -rf "$work/stale"
: > "$work/git.failrm"; run
p=$(sed -n 1p "$work/battery.ran" 2>/dev/null)
rc_is 0 && posted success green "$sha" && [ -d "$p" ] &&
  grep -qxF "local-ci: could not remove $p; run: git worktree remove --force '$p'" "$work/err" &&
  pass "19 failing removal after a green run: exit 0, posted, stderr names the path and the command" || fail "19 ($(diag))"
rm -f "$work/git.failrm"
git -C "$work/r" worktree remove --force "$p" && [ "$(wts)" = "$(printf '%s\n' "$work/r" "$work/stale")" ] &&
  pass "19 the printed command removes it; the unrelated stale registration was not pruned" || fail "19 list: $(wts)"
run
rc_is 0 && posted success green "$sha" && [ "$(wts)" = "$(printf '%s\n' "$work/r" "$work/stale")" ] &&
  pass "19 a removal that works prunes nothing either" || fail "19 second run ($(diag); worktrees: $(wts))"

# --- 20: called from a linked worktree ---
fixture
git -C "$work/r" worktree add -q -b lane "$work/lane" main
( cd "$work/lane" && echo l > l && git add l && git commit -q -m lane )
lane=$(git -C "$work/lane" rev-parse HEAD); cwd=$work/lane; run
rc_is 0 && posted success green "$lane" && ran_at "$lane" && [ "$(wts)" = "$(printf '%s\n' "$work/r" "$work/lane")" ] &&
  [ -z "$(ls -A "$work/tmp")" ] && pass "20 run from a linked worktree: its HEAD posted, only the temporary worktree removed" ||
  fail "20 ($(diag); worktrees: $(wts))"

# --- 21: claude's version cannot be read ---
fixture; path=$work/noclaude:$work/tools; run
finished 0 success green "$(sha_of HEAD)" unknown &&
  pass "21 claude not on PATH: the description says claude unknown, exit 0" || fail "21 green ($(diag))"
echo 1 | put exit.code; run
finished 1 failure red "$(sha_of HEAD)" unknown && pass "21 ... and a red battery exits 1" || fail "21 red ($(diag))"
path=$work/stub:$PATH; echo '/Users/someone/bin/claude: warning' > "$work/claude.out"; run
finished 1 failure red "$(sha_of HEAD)" unknown &&
  pass "21 a first word that is no version (a path) reads unknown" || fail "21 path ($(diag))"

# --- 22: TMPDIR holding a space ---
fixture; mkdir -p "$work/tmp dir"; runenv TMPDIR="$work/tmp dir"
d=$(sed -n 1p "$work/battery.ran" 2>/dev/null)
case $d in "$work/tmp dir/"*/wt) in_tmp=y ;; *) in_tmp=n ;; esac
finished 0 success green "$(sha_of HEAD)" && [ "$in_tmp" = y ] && [ -z "$(ls -A "$work/tmp dir")" ] &&
  pass "22 TMPDIR with a space: the run and the cleanup work" || fail "22 ($(diag); ran in $d)"

# --- the battery keeps the caller's locale ---
fixture; runenv LC_ALL=POSIX
finished 0 success green "$(sha_of HEAD)" && [ "$(sed -n 3p "$work/battery.ran" 2>/dev/null)" = LC_ALL=POSIX ] &&
  pass "the battery runs under the caller's LC_ALL, not the script's C" || fail "locale ($(cat "$work/battery.ran" 2>/dev/null))"


# --- 23-40: lanes (0.50, spec docs/superpowers/specs/2026-10-29-kit-050-proportional-gates-design.md §4, §6) ---
# lanefix: the fixture plus a light row (light.sh records its run, exits with light.code), root
# release files at 0.1.0, a Version sites line naming app.version, tools.cfg and pyproject.toml,
# all pushed, so origin/main is the lane base of every later commit.
lanefix() {
  fixture
  # shellcheck disable=SC2016  # the fixture's script text, expanded when it runs
  printf 'echo light-ran > "$STUB_DIR/light.ran"\nexit "$(cat light.code)"\n' > "$work/r/light.sh"; echo "${LIGHT_RC:-0}" > "$work/r/light.code"
  cat >> "$work/r/AGENTS.md" <<'EOF'
| quality-light (fixture) | `sh ./light.sh` |

**Version sites:** `app.version` `tools.cfg` `pyproject.toml` `.claude/ver` `a` `release metadata/version` `release\nmetadata/v2`
EOF
  echo 0.1.0 > "$work/r/VERSION"; echo 0.1.0 > "$work/r/app.version"; echo 'shellcheck 0.1.0' > "$work/r/tools.cfg"
  printf '[project]\nversion = "0.1.0"\n' > "$work/r/pyproject.toml"; mkdir -p "$work/r/.claude" "$work/r/a b"
  echo 0.1.0 > "$work/r/.claude/ver"; mkdir -p "$work/r/b" "$work/r/metadata"; echo 0.1.0 > "$work/r/metadata/version"; echo 0.1.0 > "$work/r/metadata/v2"
  printf '{\n  "name": "s",\n  "version": "0.1.0",\n  "dependencies": { "z": "1.0.0" }\n}\n' > "$work/r/a b/package.json"
  printf '{\n  "version": "0.1.0"\n}\n' > "$work/r/a"; printf '{\n  "name": "t",\n  "version": "0.1.0"\n}\n' > "$work/r/b/package.json"
  printf '{\n  "name": "w",\n  "version": "0.1.0",\n  "dependencies": {\n    "a": "1.0.0"\n  }\n}\n' > "$work/r/package.json"
  printf '{\n"name": "c",\n"version": "0.1.0",\n"repositories": [{\n"package": {\n"name": "p",\n"version": "0.1.0"\n}\n}]\n}\n' > "$work/r/composer.json"
  echo '# Changelog' > "$work/r/CHANGELOG.md"; mkdir -p "$work/r/docs"; echo doc > "$work/r/docs/a.md"
  ( cd "$work/r" && git add -A && git commit -q -m lanes && git push -q origin main 2>/dev/null )
  rm -f "$work/light.ran"
}
# edit <commit message> <shell>: run the shell in the clone, then commit everything.
edit() { ( cd "$work/r" && sh -c "$2" && git add -A && git commit -q -m "$1" ); rm -f "$work/light.ran"; }
bump() { echo 'sed -i.bak "s/0\.1\.0/0.1.1/" VERSION && rm -f VERSION.bak && sed -i.bak "s/\"version\": \"0\.1\.0\"/\"version\": \"0.1.1\"/" package.json && rm -f package.json.bak && echo "- 0.1.1" >> CHANGELOG.md'; }
light_ran() { [ -e "$work/light.ran" ]; }
# lane_is <light|full> <name>: which command ran, and what was posted.
lane_is() {
  if [ "$1" = light ]; then
    if rc_is 0 && light_ran && [ ! -e "$work/battery.ran" ] && clean &&
       [ "$(tail -n 1 "$work/out")" = "local-ci: posted quality=success on $(sha_of HEAD): light lane green: docs/release only, local run, shellcheck 0.11.0, claude 9.9.9" ]
    then pass "$2: light lane"; else fail "$2: expected light ($(diag))"; fi
  else
    if finished 0 success green "$(sha_of HEAD)" && ! light_ran; then pass "$2: full lane"; else fail "$2: expected full ($(diag))"; fi
  fi
}
green_status() { printf '{"total_count": 1, "statuses": [{"context": "quality", "state": "%s"}]}\n' "${1:-success}" > "$work/gh.status"; }
# inherited <how> <from sha> <name>: exit 0, nothing ran, the status read named the full SHA, the post
# names <how> and the first 12 characters of <from>.
inherited() {
  f12=$(printf %.12s "$2")
  if rc_is 0 && [ ! -e "$work/battery.ran" ] && ! light_ran && clean &&
     grep -qxF "repos/acme/widgets/commits/$2/status?per_page=100" "$work/gh.args" &&
     grep -qxF "description=inherited green from $f12: $1" "$work/gh.args" &&
     [ "$(tail -n 1 "$work/out")" = "local-ci: posted quality=success on $(sha_of HEAD): inherited green from $f12: $1" ]
  then pass "$3"; else fail "$3 ($(diag))"; fi
}

lanefix; edit docs 'echo more >> docs/a.md'; run; lane_is light "23 docs only"
lanefix; edit 'docs+code' 'echo more >> docs/a.md; echo x >> battery.sh'; run; lane_is full "24 docs plus one code file"
lanefix; edit release "$(bump)"; run; lane_is light "25 release-only (VERSION, package.json version, CHANGELOG)"
lanefix; edit 'release+dep' "$(bump); sed -i.bak 's/\"1.0.0\"/\"1.0.1\"/' package.json; rm -f package.json.bak"; run
lane_is full "26 version plus one dependency"
lanefix; edit nested "sed -i.bak '7s/0.1.0/0.1.1/' composer.json; rm -f composer.json.bak; sed -i.bak s/0.1.0/0.1.1/ VERSION; rm -f VERSION.bak"; run
lane_is full "27 a nested-only composer version, keys at column zero, beside a same-number VERSION bump"
lanefix; edit site 'echo 0.1.1 > app.version; echo 0.1.1 > VERSION'; run; lane_is light "28 a listed bare-version site"
lanefix; edit pin 'echo "shellcheck 0.1.1" > tools.cfg; echo 0.1.1 > VERSION'; run; lane_is full "28 a listed site line with a same-number tool pin"
lanefix; edit toml "sed -i.bak 's/0.1.0/0.1.1/' pyproject.toml; rm -f pyproject.toml.bak"; run; lane_is full "28 a TOML site line (unrecognised form)"
for d in commands agents .claude plugins/x; do
  lanefix; edit "cl $d" "mkdir -p $d && echo '- x' > $d/CHANGELOG.md"; run; lane_is full "29 a changelog under $d/"
done
lanefix; edit split "sed -i.bak 's/0\.1\.0/0.1.1/' VERSION && sed -i.bak 's/\"version\": \"0\.1\.0\"/\"version\": \"0.1.2\"/' package.json && rm -f VERSION.bak package.json.bak"; run
lane_is full "28 two different version pairs (VERSION 0.1.1, package.json 0.1.2)"
lanefix; edit instsite 'echo 0.1.1 > .claude/ver; echo 0.1.1 > VERSION'; run; lane_is full "29 a listed site under an instruction path"
lanefix
( cd "$work/r" && for f in a b/package.json 'a b/package.json'; do sed -i.bak 's/0\.1\.0/0.1.1/' "$f" && rm -f "$f.bak"; done &&
  sed -i.bak 's/1\.0\.0/1.0.1/' 'a b/package.json' && rm -f 'a b/package.json.bak' && git add -A && git commit -q -m space ); run
lane_is full "29 a dependency change in 'a b/package.json' whose split halves (a, b/package.json) are valid release files: refused"
lanefix; edit unlisted 'echo 0.1.1 > metadata/version; echo 0.1.1 > VERSION'; run
lane_is full "29 a site declared with a blank (release metadata/version) authorizes no part of it (metadata/version)"
lanefix; edit nlver "sed -i.bak 's/\"version\": \"0\\.1\\.0\"/\"version\": \"0.1.1\\\\nx\"/' package.json && rm -f package.json.bak"; run
lane_is full "29 a manifest version holding a newline (\"0.1.1\\nx\") is no version"
lanefix; edit nul "sed -i.bak 's/\"version\": \"0\\.1\\.0\"/\"version\": \"0.1.1\\\\u0000\"/' package.json && rm -f package.json.bak"; run
lane_is full "29 a manifest version holding \\u0000 is no version"
lanefix; edit escsite 'echo 0.1.1 > metadata/v2; echo 0.1.1 > VERSION'; run
lane_is full "29 a site declared as release\\nmetadata/v2 is taken literally, never as metadata/v2"
lanefix; edit agentmd 'mkdir -p agents && echo a > agents/x.md'; run; lane_is full "29 agents/x.md is no doc"
lanefix; edit png "printf '\\211PNG\\r\\n\\032\\n\\000\\000\\001' > docs/i.png"; run; lane_is light "30 a binary PNG under docs/"
lanefix; git -C "$work/r" update-index --add --cacheinfo "160000,$(sha_of HEAD),docs/sub.md"; git -C "$work/r" commit -q -m gl; run
lane_is full "31 a gitlink named like a doc"
lanefix; for c in 'diff.noprefix true' 'diff.ignoreSubmodules all' 'diff.fake.textconv true'; do git -C "$work/r" config "${c% *}" "${c#* }"; done
echo '*.json diff=fake' > "$work/r/.git/info/attributes"
edit release "$(bump)"; run; lane_is light "32 noprefix, ignoreSubmodules=all and a textconv driver configured: release still light"
edit 'dep' "sed -i.bak 's/\"1.0.0\"/\"1.0.1\"/' package.json; rm -f package.json.bak"; run
lane_is full "32 ... and a dependency still full"
git -C "$work/r" update-index --add --cacheinfo "160000,$(sha_of HEAD),docs/sub.md"; git -C "$work/r" commit -q -m gl; run
lane_is full "32 ... and a gitlink still full"
lanefix; edit docs 'echo more >> docs/a.md'; path=$work/stub:$work/tools; run; path=$work/stub:$PATH
lane_is light "33 no jq: docs only stays light"
edit release "$(bump)"; path=$work/stub:$work/tools; run; path=$work/stub:$PATH
lane_is full "33 no jq: a manifest bump takes the full lane"
fixture; edit docs 'mkdir -p docs; echo d > docs/b.md'; run
finished 0 success green "$(sha_of HEAD)" && pass "34 no light row: docs only takes the full lane" || fail "34 ($(diag))"
LIGHT_RC=1 lanefix; edit docs 'echo more >> docs/a.md'; run
rc_is 1 && light_ran && [ ! -e "$work/battery.ran" ] && clean &&
  [ "$(tail -n 1 "$work/out")" = "local-ci: posted quality=failure on $(sha_of HEAD): light lane red: docs/release only, local run, shellcheck 0.11.0, claude 9.9.9" ] &&
  pass "35 light row red: failure posted, exit 1" || fail "35 ($(diag))"
unset LIGHT_RC  # a prefix assignment to a function call stays set in sh

lanefix; g=$(sha_of HEAD); git -C "$work/r" commit -q --allow-empty -m same; green_status; run --from "$g"
inherited 'same tree' "$g" "36 --from a green head with the same tree: inherited, nothing ran"
lanefix; g=$(sha_of HEAD); edit records 'mkdir -p .context/archive && echo r > .context/archive/x.md && echo "- [x] row" > todos.md'
git -C "$work/r" branch -f green "$g"; echo "git -C '$work/r' branch -f green HEAD" > "$work/gh.onread"
green_status; run --from green
inherited 'records only' "$g" "37 records only since --from a branch the status read moves: the SHA resolved first is used"
lanefix; g=$(sha_of HEAD); git -C "$work/r" update-index --add --cacheinfo "160000,$g,sub"; git -C "$work/r" commit -q -m gl
git -C "$work/r" config diff.ignoreSubmodules all; green_status; run --from "$g"
lane_is full "38 a differing gitlink with diff.ignoreSubmodules=all is not inherited"
lanefix; edit docs 'echo d >> docs/a.md'; g=$(sha_of HEAD)
git -C "$work/r" checkout -q -b base-moved main~1; edit code 'echo x >> battery.sh'; git -C "$work/r" push -q -f origin base-moved:main 2>/dev/null
git -C "$work/r" checkout -q main; git -C "$work/r" rebase -q base-moved 2>/dev/null; green_status; run --from "$g"
lane_is full "39 base-only update: --from the old green head after a rebase onto changed code"
for st in failure none; do
  lanefix; g=$(sha_of HEAD); edit docs 'echo d >> docs/a.md'
  if [ "$st" = none ]; then echo '{"total_count": 1, "statuses": [{"context": "other", "state": "success"}]}' > "$work/gh.status"
  else green_status failure; fi
  run --from "$g"
  refused "40 --from with quality $st: exit 64" "local-ci: --from $g has no success quality status ($st); run the battery on it first"
done
echo '{"total_count": 101, "statuses": []}' > "$work/gh.status"; run --from "$g"
refused "40 --from with more than 100 contexts: exit 64" "local-ci: --from $g has no success quality status (too many contexts); run the battery on it first"
green_status; echo 1 > "$work/gh.status.rc"; run --from "$g"
refused "40 --from whose status read fails: exit 64" "local-ci: --from $g has no success quality status (a failed read); run the battery on it first"
rm -f "$work/gh.status.rc"; run --from nosuchref
refused "40 --from naming no commit: exit 64" "local-ci: --from nosuchref does not name a commit here; pass the green head's SHA"
: > "$work/git.faildiff"; run --from "$g"
refused "40 a failed records diff: exit 64, after git's own error" "$(printf 'stub: diff failed\nlocal-ci: could not list the paths changed since %s; see the git error above' "$g")"
rm -f "$work/git.faildiff"; run --from
refused "40 --from without a value: usage" "$USAGE"

# --- 41-44: --lane (0.52, spec docs/superpowers/specs/2026-10-30-kit-052-hybrid-ci-design.md §3) ---
# lane_out <expected> <name>: exit 0, exactly that word on stdout, no gh call, nothing ran or is left.
lane_out() {
  if rc_is 0 && [ "$(cat "$work/out")" = "$1" ] && [ ! -e "$work/gh.args" ] && [ ! -e "$work/battery.ran" ] &&
     ! light_ran && clean; then pass "$2"; else fail "$2 ($(diag))"; fi
}
lanefix; edit docs 'echo more >> docs/a.md'; run --lane origin/main HEAD; lane_out light "41 --lane: docs only is light"
lanefix; edit release "$(bump)"; run --lane origin/main; lane_out light "41 --lane: release-only is light (commit defaults to HEAD)"
lanefix; edit code 'echo x >> battery.sh'; run --lane origin/main HEAD; lane_out full "41 --lane: a code change is full"
fixture; edit docs 'mkdir -p docs && echo d > docs/a.md'; run --lane origin/main; lane_out full "42 --lane: no light row is full"
# --lane needs no gh, no github origin and no shellcheck parity: all three are broken here.
lanefix; edit docs 'echo more >> docs/a.md'; echo 0.10.0 > "$work/shellcheck.v"; git -C "$work/r" remote set-url origin "$work/o.git"
path=$work/nogh:$work/tools; run --lane origin/main; path=$work/stub:$PATH
lane_out light "42 --lane without gh, a github origin or shellcheck parity: still decided"
lanefix; run --lane nosuchbase
refused "43 --lane naming no commit: exit 64" 'local-ci: --lane nosuchbase does not name a commit here; pass the base branch or commit'
run --lane origin/main --from x; refused "43 --lane with --from: usage" "$USAGE"
run --from x --lane origin/main; refused "43 --from with --lane: usage" "$USAGE"
run --lane; refused "43 --lane without a value: usage" "$USAGE"
run --lane ''; refused "43 --lane with an empty value: usage" "$USAGE"
# The Actions lane step itself, run here: its run: block from ci.yml, with BASE and GITHUB_OUTPUT as
# the job gives them and the repository's own local-ci.sh at scripts/local-ci.sh.
CI_YML="$(cd "$(dirname "$0")/.." && pwd)/.github/workflows/ci.yml"
awk '/^      - name: / { inlane = 0 } /^        id: lane$/ { inlane = 1 }
  inlane && /^        run: \|$/ { body = 1; next } inlane && body && /^          / { print substr($0, 11) }' "$CI_YML" > "$work/lane-step.sh"
grep -q 'local-ci.sh --lane' "$work/lane-step.sh" && pass "44 ci.yml has a lane step calling local-ci.sh --lane" || fail "44 lane step not found in ci.yml"
# step <base> <expected> <name>: runs the step in the clone; GITHUB_OUTPUT gets exactly lane=<expected>.
step() {
  mkdir -p "$work/r/scripts"; cp "$SCRIPT" "$work/r/scripts/local-ci.sh"
  : > "$work/gho"
  ( cd "$work/r" && env PATH="$work/stub:$PATH" BASE="$1" GITHUB_OUTPUT="$work/gho" sh "$work/lane-step.sh" ) > "$work/out" 2> "$work/err"
  [ "$(cat "$work/gho")" = "lane=$2" ] && pass "$3" || fail "$3 (out: $(cat "$work/out"); gho: $(cat "$work/gho"))"
}
lanefix; edit docs 'echo more >> docs/a.md'; step origin/main light "44 the Actions lane step: docs only is light"
lanefix; edit code 'echo x >> battery.sh'; step origin/main full "44 the Actions lane step: a code change is full"
lanefix; edit docs 'echo more >> docs/a.md'; step 0000000000000000000000000000000000000000 full "44 the Actions lane step: an all-zero push base is full"
lanefix; edit docs 'echo more >> docs/a.md'; step '' full "44 the Actions lane step: an empty base is full"
# conds: the step names that carry the light-lane condition; exactly the four heavy ones.
conds=$(awk '/^      - name: / { n = substr($0, 15) } /^        if: steps.lane.outputs.lane != .light.$/ { print n }' "$CI_YML")
[ "$conds" = "$(printf '%s\n' 'Lint shell scripts (POSIX sh)' 'Hook state-machine tests (sh)' 'Hook state-machine tests (dash)' 'Checker and report suites')" ] &&
  pass "44 exactly the lint, both hook-test and the suites steps skip in the light lane" || fail "44 conditioned steps: $conds"

# --- 45-56: the heavy lock (0.52, spec docs/superpowers/specs/2026-10-30-kit-052-hybrid-ci-design.md §4) ---
LK=$work/lk/locks/heavy.lock
deflock() { mkdir -p "$work/home/.cache/sfx-factory"; chmod 755 "$work/home/.cache"; chmod 700 "$work/home/.cache/sfx-factory"; }
ovrlock() { mkdir -p "$work/lk/locks"; chmod 700 "$work/lk/locks"; }
# hold <path> <seconds>: a background flock holder with a note, like another tool's; touches
# holder.done just before it lets go; returns once it holds the lock.
hold() {
  rm -f "$work/held" "$work/holder.done"
  perl -MFcntl=:flock -e 'open(my $f, ">>", $ARGV[0]) or die; flock($f, LOCK_EX) or die; truncate($f, 0);
    syswrite($f, "4242\n/holder/dir\n"); open(my $h, ">", $ARGV[2]) and close $h; sleep $ARGV[1];
    open(my $d, ">", $ARGV[3]) and close $d' "$1" "$2" "$work/held" "$work/holder.done" &
  hpid=$!; bg="$bg $hpid"
  i=0; while [ ! -e "$work/held" ] && [ "$i" -lt 100 ]; do sleep 0.1; i=$((i + 1)); done
}
# lockable <path>: another process can take the lock now.
lockable() { perl -MFcntl=:flock -e 'open(my $f, ">>", $ARGV[0]) or exit 2; exit(flock($f, LOCK_EX | LOCK_NB) ? 0 : 1)' "$1"; }
# bgrun [NAME=value]...: the script in the background, as go runs it; sets rpid.
bgrun() {
  rm -f "$work/gh.args" "$work/battery.ran" "$work/rc"
  ( cd "$cwd" && exec env PATH="$path" TMPDIR="$work/tmp" "$@" "$LOCAL_CI_SH" "$SCRIPT" ) > "$work/out" 2> "$work/err" &
  rpid=$!; bg="$bg $rpid"
}
# lockrefused <name> <line>: exit 64, that line last on stderr, nothing ran, posted or left behind.
lockrefused() {
  if rc_is 64 && [ "$(tail -n 1 "$work/err")" = "local-ci: $2" ] && [ ! -e "$work/battery.ran" ] && not_posted && clean
  then pass "$1"; else fail "$1 ($(diag))"; fi
}

fixture; sha=$(sha_of HEAD); run
finished 0 success green "$sha" && [ ! -e "$work/home/.cache" ] && [ "$(cat "$work/battery.held")" = unset ] &&
  pass "45 no SFX_HEAVY_LOCK and no default directory: no lock, nothing created" || fail "45 ($(diag))"
fixture; deflock; sha=$(sha_of HEAD); run
f=$work/home/.cache/sfx-factory/heavy.lock
finished 0 success green "$sha" && [ -f "$f" ] && [ "$(stat -f %Lp "$f" 2>/dev/null || stat -c %a "$f")" = 600 ] &&
  [ -n "$(cat "$work/battery.held")" ] && [ "$(cat "$work/battery.held")" != unset ] && [ "$(sed -n 1p "$f")" = "$(cat "$work/battery.held")" ] &&
  pass "46 default directory present: the full battery ran under the lock (0600 file, note = holder pid = the battery's SFX_HEAVY_HELD)" || fail "46 ($(diag))"
[ "$(ls -A "$work/home/.cache/sfx-factory")" = heavy.lock ] && pass "46 ... and nothing besides the lock file appeared (no queue)" || fail "46 other entries appeared"
lockable "$f" && pass "47 after the run another process takes the lock at once" || fail "47 lock still held after the run"

fixture; ovrlock; sha=$(sha_of HEAD); hold "$LK" 3; runenv SFX_HEAVY_LOCK="$LK"
finished 0 success green "$sha" && [ -e "$work/after.holder" ] &&
  grep -qxF "local-ci: waiting for the heavy lock $LK (pid 4242 in /holder/dir)" "$work/err" &&
  pass "48 another holder has it: the run waits, names the holder, and the battery starts only after it let go" || fail "48 ($(diag))"
wait "$hpid" 2>/dev/null

fixture; ovrlock; sha=$(sha_of HEAD); hold "$LK" 4; runenv SFX_HEAVY_LOCK="$LK" HEAVY_LOCK_WAIT_SECS=1
lockrefused "49 a holder past HEAVY_LOCK_WAIT_SECS: exit 64, nothing posted" \
  "waited 1 s for the heavy lock $LK; red rather than hang (HEAVY_LOCK_WAIT_SECS)"
fixture; ovrlock; sha=$(sha_of HEAD); runenv SFX_HEAVY_LOCK="$LK" SFX_HEAVY_HELD=777
finished 0 success green "$sha" && [ ! -e "$work/after.holder" ] && [ "$(cat "$work/battery.held")" = 777 ] &&
  pass "50 SFX_HEAVY_HELD non-empty (inside a holder's step): no wait on a held lock" || fail "50 ($(diag))"
wait "$hpid" 2>/dev/null
fixture; ovrlock; sha=$(sha_of HEAD); runenv SFX_HEAVY_LOCK="$LK" SFX_HEAVY_HELD=
finished 0 success green "$sha" && [ -f "$LK" ] && [ "$(cat "$work/battery.held")" != "" ] &&
  pass "50 SFX_HEAVY_HELD empty: the lock is taken" || fail "50 empty ($(diag))"

for w in '' abc 0 007 inf 1234567890; do
  fixture; deflock; runenv HEAVY_LOCK_WAIT_SECS="$w"
  lockrefused "51 HEAVY_LOCK_WAIT_SECS='$w': exit 64 before waiting" "HEAVY_LOCK_WAIT_SECS must be a whole number of seconds from 1, not '$w'"
done
fixture; runenv SFX_HEAVY_LOCK=rel/heavy.lock
lockrefused "51 a relative SFX_HEAVY_LOCK: exit 64" "SFX_HEAVY_LOCK must be an absolute path to a file, not 'rel/heavy.lock'"

# Trust boundary: each refused before anything ran.
fixture; mkdir -p "$work/lk/real"; chmod 700 "$work/lk/real"; ln -s real "$work/lk/locks"; runenv SFX_HEAVY_LOCK="$LK"
lockrefused "52 a symlinked lock directory: exit 64" "locks under $work/lk must be a directory of this user without group or other write, not a link (heavy lock $LK)"
fixture; mkdir -p "$work/home/real/sfx-factory"; chmod 700 "$work/home/real/sfx-factory"; ln -s real "$work/home/.cache"; run
lockrefused "52 a symlinked .cache on the default path: exit 64" "$(printf '%s' ".cache under $work/home must be a directory of this user without group or other write, not a link (heavy lock $work/home/.cache/sfx-factory/heavy.lock)")"
rm -rf "$work/home/real"
fixture; deflock; chmod 775 "$work/home/.cache"; run
lockrefused "52 a group-writable .cache: exit 64" ".cache under $work/home must be a directory of this user without group or other write, not a link (heavy lock $work/home/.cache/sfx-factory/heavy.lock)"
fixture; ovrlock; chmod 770 "$work/lk/locks"; runenv SFX_HEAVY_LOCK="$LK"
lockrefused "52 a group-writable lock directory: exit 64" "locks under $work/lk must be a directory of this user without group or other write, not a link (heavy lock $LK)"
fixture; ovrlock; : > "$LK"; chmod 660 "$LK"; runenv SFX_HEAVY_LOCK="$LK"
lockrefused "52 an existing group-writable lock file: exit 64" "the heavy lock $LK must be a regular file of this user without group or other write"
fixture; ovrlock; ln -s elsewhere "$LK"; runenv SFX_HEAVY_LOCK="$LK"
[ "$(cat "$work/rc")" = 64 ] && [ ! -e "$work/battery.ran" ] && not_posted && clean &&
  pass "52 a symlinked lock file: exit 64 (O_NOFOLLOW)" || fail "52 symlinked file ($(diag))"
fixture; runenv SFX_HEAVY_LOCK="$work/nosuch/locks/heavy.lock"
[ "$(cat "$work/rc")" = 64 ] && [ ! -e "$work/battery.ran" ] && not_posted && clean && [ ! -e "$work/nosuch" ] &&
  pass "52 a missing lock directory: exit 64, nothing created" || fail "52 missing dir ($(diag))"

# 53: a directory swapped between its check and its entry is refused (the test seam only sleeps).
fixture; ovrlock; bgrun SFX_HEAVY_LOCK="$LK" LOCAL_CI_TEST_WALK_PAUSE=2
sleep 1; mv "$work/lk/locks" "$work/lk/locks.old"; mkdir "$work/lk/locks"; chmod 700 "$work/lk/locks"
wait "$rpid"; echo $? > "$work/rc"
lockrefused "53 a lock directory swapped between check and entry: exit 64" "locks under $work/lk changed while it was checked (heavy lock $LK)"

# 54: swapped after the walk, while the run waits: the run keeps the original inode. The first
# holder lets go; the battery then runs, and only the original file is locked.
fixture; ovrlock; sha=$(sha_of HEAD)
put battery.sh <<'EOF'
touch "$STUB_DIR/stage1"
i=0; while [ ! -e "$STUB_DIR/go" ] && [ "$i" -lt 200 ]; do sleep 0.1; i=$((i + 1)); done
EOF
sha=$(sha_of HEAD); hold "$LK" 3; bgrun SFX_HEAVY_LOCK="$LK"
i=0; while ! grep -q 'waiting for the heavy lock' "$work/err" 2>/dev/null && [ "$i" -lt 50 ]; do sleep 0.1; i=$((i + 1)); done
mv "$work/lk/locks" "$work/lk/locks.old"; mkdir "$work/lk/locks"; chmod 700 "$work/lk/locks"
wait "$hpid" 2>/dev/null
i=0; while [ ! -e "$work/stage1" ] && [ "$i" -lt 100 ]; do sleep 0.1; i=$((i + 1)); done
[ -e "$work/stage1" ] && ! lockable "$work/lk/locks.old/heavy.lock" && lockable "$LK" &&
  pass "54 swapped after the walk: the run holds the original file, the new path stays free" || fail "54 ($(diag))"
touch "$work/go"; wait "$rpid"; echo $? > "$work/rc"
rc_is 0 && called success green "$sha" && clean && pass "54 ... and the run then finishes green" || fail "54 finish ($(diag))"

# 55: TERM to the holder while the battery runs: the battery's group, a background child included,
# is gone before the lock is free; the run posts red.
fixture; deflock
put battery.sh <<'EOF'
sleep 30 & echo $! > "$STUB_DIR/orphan.pid"
touch "$STUB_DIR/stage1"
sleep 30
EOF
sha=$(sha_of HEAD); bgrun
i=0; while [ ! -e "$work/stage1" ] && [ "$i" -lt 100 ]; do sleep 0.1; i=$((i + 1)); done
f=$work/home/.cache/sfx-factory/heavy.lock; h=$(sed -n 1p "$f")
kill -TERM "$h"
i=0; while ! lockable "$f" && [ "$i" -lt 150 ]; do sleep 0.1; i=$((i + 1)); done
o=$(cat "$work/orphan.pid" 2>/dev/null)
lockable "$f" && [ -n "$o" ] && ! kill -0 "$o" 2>/dev/null &&
  pass "55 TERM to the holder: the battery and its background child are stopped before the lock is free" || fail "55 (orphan ${o:-?})"
wait "$rpid"; echo $? > "$work/rc"
rc_is 143 && called failure red "$sha" && clean && pass "55 ... the run posts red and exits 143" || fail "55 post ($(diag))"

# 56: the light lane takes no lock.
lanefix; deflock; edit docs 'echo more >> docs/a.md'; run
lane_is light "56 light lane with the lock directory present" && [ ! -e "$work/home/.cache/sfx-factory/heavy.lock" ] &&
  pass "56 ... and no lock was taken" || fail "56 lock taken in the light lane"

# --- 57: the month reminder from ci-switch.sh's log (0.52, spec §2.2) ---
REM='ci-switch: a new month renews the Actions budget (last recorded switch to local: 2000-01); back to hosted: sh scripts/ci-switch.sh hosted "budget renewed"'
fixture; mkdir -p "$work/r/.context"; printf '2000-01-31T23:00:00Z\thosted\tlocal\tci.yml\tbudget\n' > "$work/r/.context/ci-switch.log"
sha=$(sha_of HEAD); run
finished 0 success green "$sha" && [ "$(sed -n 1p "$work/err")" = "$REM" ] && pass "57 last switch to local in an earlier month: reminder, run goes on" || fail "57 ($(diag))"
git -C "$work/r" worktree add -q --detach "$work/other" 2>/dev/null; cwd=$work/other; run
grep -qxF "$REM" "$work/err" && pass "57 ... also from a linked worktree (the main worktree's log)" || fail "57 linked ($(diag))"
git -C "$work/r" worktree remove --force "$work/other"; cwd=$work/r
run --lane HEAD~0; [ ! -s "$work/err" ] && pass "57 --lane never prints it" || fail "57 lane ($(diag))"
printf '%s-01T00:00:00Z\thosted\tlocal\tci.yml\tb\n' "$(date -u +%Y-%m)" > "$work/r/.context/ci-switch.log"; run
[ "$(cat "$work/err")" = battery-stderr ] && pass "57 last switch to local this month: silent" || fail "57 this month ($(diag))"
printf '2000-01-31T23:00:00Z\thosted\tlocal\tci.yml\tb\n2000-02-01T00:00:00Z\tlocal\thosted\tci.yml\tb\n' > "$work/r/.context/ci-switch.log"; run
[ "$(cat "$work/err")" = battery-stderr ] && pass "57 last switch to hosted: silent" || fail "57 hosted ($(diag))"

printf '\n---\n'
if [ "$fail_n" -eq 0 ]; then printf 'all passed (%s assertions)\n' "$pass_n"; else
  printf '%s passed, %s FAILED\n' "$pass_n" "$fail_n"; exit 1
fi
