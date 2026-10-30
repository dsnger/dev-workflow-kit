#!/bin/sh
# Regression suite for ci-switch.sh: each case builds a clone whose origin URL names
# github.com/acme/widgets, puts a stub gh first in PATH, runs the script from the clone and checks
# its exit status, its output, the gh calls it made and the switch log. It reaches no network.
# Spec: docs/superpowers/specs/2026-10-30-kit-052-hybrid-ci-design.md §2, §6.
set -u
SCRIPT="$(cd "$(dirname "$0")" && pwd)/ci-switch.sh"
CI_SWITCH_SH=${CI_SWITCH_SH:-sh}
pass_n=0; fail_n=0
pass() { pass_n=$((pass_n + 1)); printf 'ok   - %s\n' "$1"; }
fail() { fail_n=$((fail_n + 1)); printf 'FAIL - %s\n' "$1"; }
work=$(mktemp -d) || exit 1
[ -n "$work" ] && [ -d "$work" ] || exit 1
work=$(cd "$work" && pwd -P)
trap 'chmod -R u+rwx "$work" 2>/dev/null; rm -rf "$work"' EXIT
trap 'exit 1' HUP INT TERM

# Stub gh: appends each call's arguments, one per line, then "--", to $STUB_DIR/gh.args. auth exits
# with gh.auth.rc. A workflow read prints the first line of gh.states (removing it while more than
# one is left), exits with gh.state.rc. A PUT exits with gh.put.rc. A jobs read filters jobs.json,
# an annotations read ann.<id>.json, with the real jq and the call's --jq.
mkdir -p "$work/stub"
cat > "$work/stub/gh" <<'EOF'
#!/bin/sh
{ printf '%s\n' "$@"; echo --; } >> "$STUB_DIR/gh.args"
case $1 in auth) exit "$(cat "$STUB_DIR/gh.auth.rc" 2>/dev/null || echo 0)" ;; esac
f=; for a in "$@"; do [ "$f" = 1 ] && { f=$a; break; }; [ "$a" = --jq ] && f=1; done
case " $* " in
  *" PUT "*) exit "$(cat "$STUB_DIR/gh.put.rc" 2>/dev/null || echo 0)" ;;
  *"/actions/workflows/"*)
    rc=$(cat "$STUB_DIR/gh.state.rc" 2>/dev/null || echo 0); [ "$rc" = 0 ] || exit "$rc"
    sed -n 1p "$STUB_DIR/gh.states"
    [ "$(wc -l < "$STUB_DIR/gh.states")" -gt 1 ] && sed -i.bak 1d "$STUB_DIR/gh.states"; exit 0 ;;
  *"/jobs"*) [ -f "$STUB_DIR/jobs.json" ] || exit 1; "$REAL_JQ" -r "$f" "$STUB_DIR/jobs.json" ;;
  *"/check-runs/"*)
    id=$(printf '%s\n' "$*" | sed -n 's#.*/check-runs/\([0-9]*\)/annotations.*#\1#p')
    [ -f "$STUB_DIR/ann.$id.json" ] || exit 1; echo "$id" >> "$STUB_DIR/ann.read"
    "$REAL_JQ" -r "$f" "$STUB_DIR/ann.$id.json" ;;
  *) exit 1 ;;
esac
EOF
chmod +x "$work/stub/gh"
[ -x "$work/stub/gh" ] || { echo 'stub gh missing; abort' >&2; exit 1; }
REAL_JQ=$(command -v jq) || { echo 'jq missing; abort' >&2; exit 1; }
export STUB_DIR="$work" REAL_JQ

fixture() {
  rm -rf "$work/r" "$work/w2" "$work"/gh.* "$work"/ann.* "$work/jobs.json"
  git init -q -b main "$work/r"
  mkdir -p "$work/r/.github/workflows"; echo 'name: CI' > "$work/r/.github/workflows/ci.yml"
  ( cd "$work/r" && git config user.email t@t && git config user.name t &&
    git remote add origin https://github.com/acme/widgets.git && git add -A && git commit -q -m init )
  echo active > "$work/gh.states"; cwd=$work/r
}
LOG() { printf '%s' "$work/r/.context/ci-switch.log"; }
# go [stdin text] -- args: run from $cwd; stdout, stderr, status in out, err, rc.
go() {
  rm -f "$work/gh.args" "$work/ann.read"
  inp=$1; shift
  printf '%s' "$inp" | ( cd "$cwd" && exec env PATH="$work/stub:$PATH" "$CI_SWITCH_SH" "$SCRIPT" "$@" ) > "$work/out" 2> "$work/err"
  echo $? > "$work/rc"
}
rc_is() { [ "$(cat "$work/rc")" = "$1" ]; }
diag() { printf 'rc %s; out: %s; err: %s' "$(cat "$work/rc")" "$(cat "$work/out")" "$(cat "$work/err")"; }
puts() { cat "$work/gh.args" 2>/dev/null | grep -c '^PUT$'; }
# last: the last output line without the question before it (stdin is no terminal, so no newline).
last() { tail -n 1 "$work/out" | sed 's/^Switch .*\] //'; }
put_path() { awk 'p { print; exit } /^PUT$/ { p = 1 }' "$work/gh.args"; }
nolog() { [ ! -s "$(LOG)" ]; }
month=$(date -u +%Y-%m)

# --- 1: show ---
fixture; go ''
rc_is 0 && [ "$(cat "$work/out")" = 'ci-switch: acme/widgets is hosted (ci.yml: active)' ] && [ ! -s "$work/err" ] &&
  grep -qx 'repos/acme/widgets/actions/workflows/ci.yml' "$work/gh.args" && [ "$(puts)" = 0 ] &&
  pass "1 show hosted (active), no PUT" || fail "1 ($(diag))"
fixture; echo disabled_manually > "$work/gh.states"; go ''
rc_is 0 && [ "$(cat "$work/out")" = 'ci-switch: acme/widgets is local (ci.yml: disabled_manually)' ] && pass "1 show local" || fail "1 local ($(diag))"
fixture; echo disabled_inactivity > "$work/gh.states"; go ''
rc_is 0 && grep -q 'is local (ci.yml: disabled_inactivity)' "$work/out" && pass "1 disabled_inactivity is local" || fail "1 inactivity ($(diag))"
for st in disabled_fork deleted ''; do
  fixture; echo "$st" > "$work/gh.states"; go ''
  rc_is 64 && [ "$(cat "$work/err")" = "ci-switch: the workflow ci.yml of acme/widgets reads state '${st:-none}', neither hosted nor local; look at it on GitHub" ] &&
    pass "1 state '$st' refuses (64)" || fail "1 state '$st' ($(diag))"
done
fixture; echo 1 > "$work/gh.state.rc"; go ''
rc_is 64 && grep -q "reads state 'none'" "$work/err" && pass "1 a failed state read refuses (64)" || fail "1 failed read ($(diag))"

# --- 2: flip ---
fixture; printf 'active\ndisabled_manually\n' > "$work/gh.states"; echo active > "$work/gh.states"
go 'y
' local 'Actions budget used up'
l=$(cat "$(LOG)" 2>/dev/null)
rc_is 0 && [ "$(puts)" = 1 ] && [ "$(put_path)" = 'repos/acme/widgets/actions/workflows/ci.yml/disable' ] &&
  grep -qF 'Switch acme/widgets CI from hosted to local (ci.yml; reason: Actions budget used up)? [y/N] ' "$work/out" &&
  [ "$(last)" = 'ci-switch: acme/widgets switched from hosted to local' ] &&
  [ "$(printf '%s\n' "$l" | wc -l | tr -d ' ')" = 1 ] &&
  [ "$(printf '%s\n' "$l" | awk -F '\t' '{ print NF "|" $2 "|" $3 "|" $4 "|" $5 }')" = '5|hosted|local|ci.yml|Actions budget used up' ] &&
  printf '%s\n' "$l" | grep -qE "^${month}-[0-9][0-9]T[0-9:]+Z	" &&
  pass "2 y: one PUT to .../disable, one five-field log line" || fail "2 y ($(diag); log: $l)"
fixture; echo disabled_manually > "$work/gh.states"; go 'YES
' hosted 'budget renewed'
rc_is 0 && [ "$(put_path)" = 'repos/acme/widgets/actions/workflows/ci.yml/enable' ] && grep -q '	local	hosted	ci.yml	budget renewed$' "$(LOG)" &&
  pass "2 YES: .../enable, logged" || fail "2 YES ($(diag))"
for a in 'n
' '
' '' 'yep
'; do
  fixture; go "$a" local 'x'
  rc_is 1 && [ "$(puts)" = 0 ] && nolog && [ "$(last)" = 'ci-switch: not switched' ] &&
    pass "2 answer '$(printf '%s' "$a" | tr '\n' '/')': not switched, exit 1, no PUT, no line" || fail "2 answer ($(diag))"
done
fixture; go 'y
' hosted 'x'
rc_is 0 && [ "$(puts)" = 0 ] && nolog && grep -qx 'ci-switch: already hosted; nothing switched' "$work/out" &&
  pass "2 already in the target state: no PUT, no line" || fail "2 already ($(diag))"
fixture; printf 'active\ndisabled_manually\n' > "$work/gh.states"; go 'y
' local 'x'
rc_is 1 && [ "$(puts)" = 0 ] && nolog && [ "$(last)" = 'ci-switch: the state changed to disabled_manually meanwhile; not switched' ] &&
  pass "2 state changed between question and PUT: no PUT" || fail "2 changed ($(diag))"
fixture; go 'y
' local "$(printf 'two\tparts\nand a line')"
rc_is 0 && [ "$(awk -F '\t' '{ print NF "|" $5 }' "$(LOG)")" = '5|two parts and a line' ] &&
  pass "2 tabs and line breaks in the reason become spaces" || fail "2 reason ($(diag))"
for r in '' '  '; do
  fixture; go 'y
' local "$r"
  rc_is 64 && [ "$(puts)" = 0 ] && grep -q '^usage:' "$work/err" && pass "2 reason '$r': usage, 64" || fail "2 empty reason ($(diag))"
done
fixture; mkdir -p "$work/r/.context"; : > "$(LOG)"; chmod 444 "$(LOG)"; go 'y
' local 'x'
rc_is 64 && [ "$(puts)" = 0 ] && ! grep -q 'Switch ' "$work/out" && grep -qx "ci-switch: cannot write the switch log $(LOG); fix that, then switch" "$work/err" &&
  pass "2 unwritable log: 64 before the question, no PUT" || fail "2 unwritable ($(diag))"
fixture; echo 1 > "$work/gh.put.rc"; go 'y
' local 'x'
rc_is 75 && nolog && grep -qx 'ci-switch: the switch request failed; acme/widgets is still hosted' "$work/err" &&
  pass "2 PUT fails, state unchanged: 75, nothing logged" || fail "2 put fails ($(diag))"
fixture; echo 1 > "$work/gh.put.rc"; printf 'active\nactive\ndisabled_manually\n' > "$work/gh.states"; go 'y
' local 'x'
rc_is 0 && grep -q '	hosted	local	ci.yml	x (reply failed, state read back)$' "$(LOG)" &&
  pass "2 PUT reply lost, state reads back as the target: logged, marked" || fail "2 lost reply ($(diag))"

# --- 3: preconditions and usage ---
fixture; echo 'name: Q' > "$work/r/.github/workflows/quality.yml"; go ''
rc_is 64 && grep -qx "ci-switch: found 2 of .github/workflows/quality.yml and .github/workflows/ci.yml in $work/r; exactly one names the quality workflow" "$work/err" &&
  pass "3 both workflow files: 64" || fail "3 both ($(diag))"
fixture; rm "$work/r/.github/workflows/ci.yml"; go ''
rc_is 64 && grep -q 'found 0 of' "$work/err" && pass "3 neither workflow file: 64" || fail "3 neither ($(diag))"
fixture; mv "$work/r/.github/workflows/ci.yml" "$work/r/.github/workflows/quality.yml"; go ''
rc_is 0 && grep -q '(quality.yml: active)' "$work/out" && grep -qx 'repos/acme/widgets/actions/workflows/quality.yml' "$work/gh.args" &&
  pass "3 a project's quality.yml is the workflow" || fail "3 quality.yml ($(diag))"
fixture; git -C "$work/r" remote set-url origin https://gitlab.com/acme/widgets.git; go ''
rc_is 64 && grep -q 'not a github.com repository URL' "$work/err" && [ ! -e "$work/gh.args" ] && pass "3 a non-github origin: 64, no gh call" || fail "3 origin ($(diag))"
fixture; echo 1 > "$work/gh.auth.rc"; go ''
rc_is 64 && grep -q 'gh auth status --hostname github.com failed' "$work/err" && pass "3 gh not logged in: 64" || fail "3 auth ($(diag))"
fixture; for a in 'sideways x' 'hosted' 'check' 'check 12a' 'check -1' 'a b c'; do
  # shellcheck disable=SC2086  # the words are the arguments
  go '' $a
  rc_is 64 && grep -q '^usage:' "$work/err" || { fail "3 usage for '$a' ($(diag))"; continue; }
  pass "3 '$a': usage, 64"
done

# --- 4: a shared log from a second worktree; the reminder ---
fixture; git -C "$work/r" worktree add -q --detach "$work/w2" 2>/dev/null; cwd=$work/w2; go 'y
' local 'x'
rc_is 0 && [ -s "$(LOG)" ] && [ ! -e "$work/w2/.context/ci-switch.log" ] && pass "4 a flip from a linked worktree logs in the main one" || fail "4 shared ($(diag))"
REM='ci-switch: a new month renews the Actions budget (last recorded switch to local: 2000-01); back to hosted: sh scripts/ci-switch.sh hosted "budget renewed"'
fixture; echo disabled_manually > "$work/gh.states"; mkdir -p "$work/r/.context"
printf '2000-01-31T23:00:00Z\thosted\tlocal\tci.yml\tbudget\n' > "$(LOG)"; go ''
rc_is 0 && [ "$(cat "$work/err")" = "$REM" ] && pass "4 local, last switch to local in an earlier month: reminder" || fail "4 reminder ($(diag))"
printf '%s-01T00:00:00Z\thosted\tlocal\tci.yml\tbudget\n' "$month" > "$(LOG)"; go ''
rc_is 0 && [ ! -s "$work/err" ] && pass "4 last switch to local this month: silent" || fail "4 this month ($(diag))"
printf '2000-01-31T23:00:00Z\thosted\tlocal\tci.yml\tb\n2000-02-01T00:00:00Z\tlocal\thosted\tci.yml\tb\n' > "$(LOG)"; go ''
rc_is 0 && [ ! -s "$work/err" ] && pass "4 last switch to hosted: silent" || fail "4 hosted last ($(diag))"
printf '2000-01-31T23:00:00Z\thosted\tlocal\tci.yml\tb\n' > "$(LOG)"; echo active > "$work/gh.states"; go ''
rc_is 0 && [ ! -s "$work/err" ] && pass "4 GitHub reads hosted (switched outside the script): silent" || fail "4 api hosted ($(diag))"
rm -f "$(LOG)"; echo disabled_manually > "$work/gh.states"; go ''
rc_is 0 && [ ! -s "$work/err" ] && pass "4 no log: silent" || fail "4 no log ($(diag))"

# --- 5: billing check ---
BILL='The job was not started because recent account payments have failed or your spending limit needs to be increased. Please check the '"'"'Billing & plans'"'"' section of your settings.'
jobs() { printf '{"total_count": 2, "jobs": [%s]}\n' "$1" > "$work/jobs.json"; }
J_BLOCKED='{"id": 11, "name": "quality", "conclusion": "failure", "steps": [], "check_run_url": "https://api.github.com/repos/acme/widgets/check-runs/11"}'
J_TESTFAIL='{"id": 12, "name": "quality", "conclusion": "failure", "steps": [{"name": "Run tests", "conclusion": "failure"}], "check_run_url": "https://api.github.com/repos/acme/widgets/check-runs/12"}'
fixture; jobs "$J_BLOCKED"; printf '[{"message": "%s"}]\n' "$BILL" > "$work/ann.11.json"; go '' check 4242
rc_is 0 && [ "$(sed -n 1p "$work/out")" = "ci-switch: run 4242: job \"quality\" was not started: $BILL" ] &&
  [ "$(sed -n 2p "$work/out")" = 'ci-switch: GitHub Actions is blocked by billing for acme/widgets; switch to local: sh scripts/ci-switch.sh local "Actions budget used up"' ] &&
  sed -n 3p "$work/out" | grep -q 'push a new head and run sh scripts/local-ci.sh on it: a quality check run Actions already created' &&
  [ "$(puts)" = 0 ] && grep -qx 'repos/acme/widgets/actions/runs/4242/jobs?per_page=100' "$work/gh.args" &&
  grep -qx 'repos/acme/widgets/check-runs/11/annotations?per_page=100' "$work/gh.args" &&
  pass "5 a never-started job with the billing annotation: three lines, exit 0, no PUT" || fail "5 blocked ($(diag))"
fixture; jobs "$J_TESTFAIL"; echo '[{"message": "test: spending limit exceeded in fixture"}]' > "$work/ann.12.json"; go '' check 4243
rc_is 1 && [ ! -e "$work/ann.read" ] && grep -qx 'ci-switch: run 4243 shows no billing block (no job GitHub never started with a billing annotation)' "$work/out" &&
  pass "5 a failed test job mentioning a spending limit: no hit, its annotations never read" || fail "5 test failure ($(diag))"
fixture; jobs "$J_BLOCKED"; echo '[{"message": "The runner was lost"}]' > "$work/ann.11.json"; go '' check 4244
rc_is 1 && [ "$(cat "$work/ann.read")" = 11 ] && pass "5 a never-started job without a billing message: no hit" || fail "5 other message ($(diag))"
fixture; jobs '{"name": "q", "conclusion": "failure", "steps": [], "check_run_url": "https://api.github.com/repos/acme/widgets/check-runs/x"}'; go '' check 4245
rc_is 64 && grep -q 'has no check run id' "$work/err" && pass "5 a check_run_url without a numeric tail: 64" || fail "5 url ($(diag))"
fixture; go '' check 4246
rc_is 64 && grep -qx 'ci-switch: could not read the jobs of run 4246 in acme/widgets; check the run id' "$work/err" && pass "5 a failed jobs read: 64" || fail "5 read ($(diag))"
fixture; jobs "$J_BLOCKED"; go '' check 4247
rc_is 64 && grep -q 'could not read the annotations of check run 11' "$work/err" && pass "5 a failed annotations read: 64" || fail "5 ann read ($(diag))"

printf '\n---\n'
if [ "$fail_n" -eq 0 ]; then printf 'all passed (%s assertions)\n' "$pass_n"; else
  printf '%s passed, %s FAILED\n' "$pass_n" "$fail_n"; exit 1
fi
