#!/bin/sh
# Regression suite for worktree-cleanup.sh: each case builds a bare origin and a clone with
# linked worktrees, puts stub gh and lsof first in PATH, runs the script and checks its rows and
# what --remove did. Spec: docs/superpowers/specs/2026-10-24-kit-044-field-cases-design.md §2.
set -u
SCRIPT="$(cd "$(dirname "$0")" && pwd)/worktree-cleanup.sh"
# CLEANUP_SH selects the shell the SCRIPT runs under (as HOOK_SH does for the hook suite).
CLEANUP_SH=${CLEANUP_SH:-sh}
pass_n=0; fail_n=0
pass() { pass_n=$((pass_n + 1)); printf 'ok   - %s\n' "$1"; }
fail() { fail_n=$((fail_n + 1)); printf 'FAIL - %s\n' "$1"; }
work=$(mktemp -d) || exit 1
[ -n "$work" ] && [ -d "$work" ] || exit 1
work=$(cd "$work" && pwd -P)
trap 'chmod -R u+rwx "$work" 2>/dev/null; rm -rf "$work"' EXIT HUP INT TERM

# Stubs. gh: records its arguments, prints $work/gh.out, exits with $work/gh.rc (default 0).
# lsof: counts its calls; on call <n> it first runs $work/lsof.on<n> when present, then prints
# $work/lsof.out and exits with $work/lsof.rc (default 0).
mkdir -p "$work/stub" "$work/bare"
cat > "$work/stub/gh" <<'EOF'
#!/bin/sh
printf '%s\n' "$@" > "$STUB_DIR/gh.args"
printf 'GH_REPO=%s GH_HOST=%s\n' "${GH_REPO:-}" "${GH_HOST:-}" >> "$STUB_DIR/gh.args"
[ -f "$STUB_DIR/gh.out" ] && cat "$STUB_DIR/gh.out"
exit "$(cat "$STUB_DIR/gh.rc" 2>/dev/null || echo 0)"
EOF
cat > "$work/stub/lsof" <<'EOF'
#!/bin/sh
n=$(( $(cat "$STUB_DIR/lsof.calls" 2>/dev/null || echo 0) + 1 ))
echo "$n" > "$STUB_DIR/lsof.calls"
[ -f "$STUB_DIR/lsof.on$n" ] && . "$STUB_DIR/lsof.on$n"
[ -f "$STUB_DIR/lsof.out" ] && cat "$STUB_DIR/lsof.out"
exit "$(cat "$STUB_DIR/lsof.rc" 2>/dev/null || echo 0)"
EOF
# cp: fails when $work/cp.fail exists, otherwise runs the real cp.
real_cp=$(command -v cp)
# shellcheck disable=SC2016  # $STUB_DIR and $@ expand when the stub runs
printf '#!/bin/sh\n[ -f "$STUB_DIR/cp.fail" ] && { echo "cp: stub failure" >&2; exit 1; }\nexec %s "$@"\n' "$real_cp" > "$work/stub/cp"
chmod +x "$work/stub/gh" "$work/stub/lsof" "$work/stub/cp"
# A PATH without gh and lsof: links to the other tools the script and stubs need.
for t in git sh "$CLEANUP_SH" sed awk grep mkdir cp date basename cat rm rmdir mktemp tr wc head chmod; do
  [ -e "$work/bare/$t" ] || { p=$(command -v "$t") && ln -s "$p" "$work/bare/$t"; }
done
export STUB_DIR="$work"

# Fresh fixture: origin (bare), clone r with main pushed, worktree roots present.
fixture() {
  rm -rf "$work/o.git" "$work/r" "$work/out" "$work"/gh.* "$work"/lsof.* "$work/cp.fail" "$work/elsewhere"
  git init -q --bare -b main "$work/o.git"
  git clone -q "$work/o.git" "$work/r" 2>/dev/null
  ( cd "$work/r" && git config user.email t@t && git config user.name t &&
    git remote set-url origin https://github.com/acme/widgets.git &&
    git config remote.origin.pushurl "$work/o.git" &&
    echo a > a && git add a && git commit -q -m init && git push -q origin main 2>/dev/null &&
    git fetch -q "$work/o.git" main:refs/remotes/origin/main &&
    git symbolic-ref refs/remotes/origin/HEAD refs/remotes/origin/main &&
    mkdir -p .claude/worktrees .worktrees && printf '.claude/\n.worktrees/\n.context/\n' > .gitignore &&
    git add .gitignore && git commit -q -m ignore && git push -q origin main 2>/dev/null &&
    git update-ref refs/remotes/origin/main HEAD )
  printf 'p1\nfcwd\nn/\n' > "$work/lsof.out"
}
# Worktree $1 on new branch $2 under .claude/worktrees, with one commit.
add_wt() {
  ( cd "$work/r" && git worktree add -q -b "$2" ".claude/worktrees/$1" main 2>/dev/null &&
    cd ".claude/worktrees/$1" && echo "$2" > "$2.txt" && git add "$2.txt" && git commit -q -m "$2" )
}
# Merge branch $1 into main by fast-forward and move origin/main there.
merge_ff() { ( cd "$work/r" && git merge -q --ff-only "$1" && git update-ref refs/remotes/origin/main main ); }
tip() { git -C "$work/r" rev-parse "$1"; }
run() { ( cd "$work/r" && PATH="$work/stub:$PATH" "$CLEANUP_SH" "$SCRIPT" "$@" ) > "$work/out" 2>&1; echo $? > "$work/rc"; }
run_bare() { ( cd "$work/r" && PATH="$work/bare" "$CLEANUP_SH" "$SCRIPT" ) > "$work/out" 2>&1; echo $? > "$work/rc"; }
has() { grep -qF -- "$1" "$work/out"; }
rc_is() { [ "$(cat "$work/rc")" = "$1" ]; }
# $1 name, $2 text the row line for worktree/branch $3 must contain.
row() {
  line=$(grep -F -- "$3" "$work/out" | grep -E '^(worktree|branch) ' | head -n 1)
  case $line in *"$2"*) pass "$1" ;; *) fail "$1 (row: ${line:-none}; out: $(cat "$work/out"))" ;; esac
}
wt_exists() { [ -d "$work/r/.claude/worktrees/$1" ]; }
br_exists() { git -C "$work/r" rev-parse -q --verify "refs/heads/$1" >/dev/null; }

# --- report and removal of an ancestor-merged worktree ---
fixture; add_wt w1 b1; merge_ff b1
mkdir -p "$work/r/.claude/worktrees/w1/.context"; echo note > "$work/r/.claude/worktrees/w1/.context/handover.md"
before=$(git -C "$work/r" worktree list --porcelain; git -C "$work/r" branch)
run
row "ancestor-merged clean worktree is removable" "merged=ancestor" "worktrees/w1"
row "  ... with verdict removable" "-> removable" "worktrees/w1"
after=$(git -C "$work/r" worktree list --porcelain; git -C "$work/r" branch)
[ "$before" = "$after" ] && [ ! -e "$work/r/.context" ] && rc_is 0 && pass "report mode changes nothing" || fail "report mode changed state"
run --remove
if ! wt_exists w1 && ! br_exists b1 && [ "$(cat "$work/r/.context/archive-worktree-w1/handover.md" 2>/dev/null)" = note ] && rc_is 0; then
  pass "--remove removes worktree, archives .context/, deletes branch"
else fail "--remove result: $(cat "$work/out")"; fi

# --- archive suffix when the name exists ---
fixture; add_wt w1 b1; merge_ff b1
mkdir -p "$work/r/.claude/worktrees/w1/.context" "$work/r/.context/archive-worktree-w1"; echo x > "$work/r/.claude/worktrees/w1/.context/f"
run --remove
[ -f "$work/r/.context/archive-worktree-w1-2/f" ] && pass "existing archive name gets -2" || fail "suffix: $(cat "$work/out")"

# --- squash merges through gh ---
fixture; add_wt w2 b2
printf '7 %s\n' "$(tip b2)" > "$work/gh.out"
GH_REPO=evil/other GH_HOST=ghe.example.com run
row "tip equal to a merged PR head reads pr#7" "merged=pr#7" "worktrees/w2"
row "  ... and is removable" "-> removable" "worktrees/w2"
if grep -qx 'github.com/acme/widgets' "$work/gh.args" && grep -qx -- '--base' "$work/gh.args" &&
   grep -qx main "$work/gh.args" && grep -qx -- '-R' "$work/gh.args"; then
  pass "gh gets -R github.com/<owner>/<repo> and --base main despite GH_REPO/GH_HOST"
else fail "gh args: $(cat "$work/gh.args")"; fi
printf '7 %s\n' "$(tip main)" > "$work/gh.out"; run
row "merged PR head different from the tip reads no" "merged=no" "worktrees/w2"
: > "$work/gh.out"; i=1; while [ $i -le 100 ]; do printf '%s 0000\n' "$i" >> "$work/gh.out"; i=$((i + 1)); done; run
row "100 PRs without a match read unknown" "merged=unknown" "worktrees/w2"
printf '7 %s\n' "$(tip b2)" >> "$work/gh.out"; run
row "101 PRs with a match still read unknown" "merged=unknown" "worktrees/w2"
echo 1 > "$work/gh.rc"; : > "$work/gh.out"; run
row "failing gh reads unknown" "merged=unknown" "worktrees/w2"
run_bare
row "missing gh reads unknown" "merged=unknown" "worktrees/w2"
row "  ... and is kept" "keep: not merged (unknown)" "worktrees/w2"

# --- dirty, ignored, submodules, locked, detached ---
fixture; add_wt w1 b1; merge_ff b1; echo u > "$work/r/.claude/worktrees/w1/untracked.txt"; run
row "untracked file makes it dirty and kept" "keep: dirty (yes)" "worktrees/w1"
fixture; add_wt w1 b1; merge_ff b1
mkdir -p "$work/r/.claude/worktrees/w1/.context"; echo x > "$work/r/.claude/worktrees/w1/.context/keep"
mkdir -p "$work/r/.claude/worktrees/w1/.worktrees"; echo e > "$work/r/.claude/worktrees/w1/.worktrees/env"
run
row "ignored file outside .context/ keeps it" "keep: ignored files (1)" "worktrees/w1"
has "ignored: .worktrees/" && pass "report lists the ignored path" || fail "ignored path not listed: $(cat "$work/out")"
run --remove --discard-ignored
! wt_exists w1 && rc_is 0 && pass "--discard-ignored lets it go" || fail "discard-ignored: $(cat "$work/out")"
fixture; add_wt w1 b1; merge_ff b1; ( cd "$work/r/.claude/worktrees/w1" && echo x > .gitmodules && git add .gitmodules && git commit -q -m sm ); merge_ff b1; run
row ".gitmodules keeps it" "keep: submodules" "worktrees/w1"
fixture; add_wt w1 b1; merge_ff b1; git -C "$work/r" worktree lock "$work/r/.claude/worktrees/w1"; run --remove
row "locked worktree kept" "keep: locked" "worktrees/w1"
wt_exists w1 && pass "  ... and not removed" || fail "locked worktree removed"
fixture; ( cd "$work/r" && git worktree add -q --detach .claude/worktrees/d1 main 2>/dev/null ); run
row "detached worktree kept" "keep: detached" "worktrees/d1"

# --- sessions ---
fixture; add_wt w1 b1; merge_ff b1
printf 'p1\nfcwd\nn%s/sub\n' "$work/r/.claude/worktrees/w1" > "$work/lsof.out"; run --remove
row "process cwd inside reads session=yes" "keep: session (yes)" "worktrees/w1"
wt_exists w1 && pass "  ... and not removed" || fail "live worktree removed"
printf 'p1\nfcwd\nn%s-other\n' "$work/r/.claude/worktrees/w1" > "$work/lsof.out"; run
row "a sibling path with the same prefix is no session" "session=no" "worktrees/w1"
echo 1 > "$work/lsof.rc"; run
row "lsof exiting 1 reads unknown" "keep: session (unknown)" "worktrees/w1"
rm -f "$work/lsof.rc"; printf 'p1\nfcwd\n' > "$work/lsof.out"; run
row "lsof without an n/ line reads unknown" "keep: session (unknown)" "worktrees/w1"
run_bare
row "missing lsof reads unknown" "session=unknown" "worktrees/w1"
fixture; ( cd "$work/r" && git worktree add -q -b bc ".claude/worktrees/café" main 2>/dev/null ); merge_ff bc; run
row "non-ASCII path reads session unknown (lsof escapes it)" "keep: session (unknown)" "worktrees/caf"
fixture; ( cd "$work/r" && git worktree add -q -b bs '.claude/worktrees/a\b' main 2>/dev/null ); merge_ff bs; run
row "backslash path reads session unknown" "keep: session (unknown)" "worktrees/a"

# --- roots ---
fixture; add_wt w1 b1; merge_ff b1
( cd "$work/r" && git worktree add -q -b b3 "$work/elsewhere/w3" main 2>/dev/null ); merge_ff b3
run --remove
row "worktree outside the roots kept" "keep: outside worktree roots" "elsewhere/w3"
[ -d "$work/elsewhere/w3" ] && pass "  ... and not removed by --remove" || fail "outside worktree removed"
run --root "$work/elsewhere"
row "its parent as --root makes it removable" "-> removable" "elsewhere/w3"
run --root "$work/elsewhere/w3"
row "the worktree itself as --root is not inside it" "keep: outside worktree roots" "elsewhere/w3"
fixture; mkdir -p "$work/elsewhere"; ln -s "$work/elsewhere" "$work/r/.claude/worktrees/esc"
( cd "$work/r" && git worktree add -q -b b4 .claude/worktrees/esc/w4 main 2>/dev/null ); merge_ff b4; run
row "symlink in a root resolving outside kept" "keep: outside worktree roots" "w4"

# --- branch rows ---
fixture; ( cd "$work/r" && git branch m1 main && git checkout -q -b u1 && echo u > u && git add u && git commit -q -m u && git checkout -q main ); run --remove
br_exists m1 && fail "merged branch without worktree not deleted: $(cat "$work/out")" || pass "merged branch without worktree deleted"
br_exists u1 && pass "unmerged branch kept" || fail "unmerged branch deleted"
br_exists main && pass "default branch never listed" || fail "main deleted"
fixture; ( cd "$work/r" && git checkout -q -b side ); run --remove
br_exists main && ! grep -q '^branch main ' "$work/out" && pass "default branch not checked out is still never listed" || fail "main listed: $(cat "$work/out")"

# --- changes between report and removal ---
fixture; add_wt w1 b1; merge_ff b1
printf 'p1\nfcwd\nn%s\n' "$work/r/.claude/worktrees/w1" > "$work/lsof.on2.out"
# shellcheck disable=SC2016  # $STUB_DIR expands when the stub sources this file
printf 'cp "$STUB_DIR/lsof.on2.out" "$STUB_DIR/lsof.out"\n' > "$work/lsof.on2"; run --remove
has "skipped" && wt_exists w1 && br_exists b1 && pass "session appearing before removal skips the row" || fail "late session: $(cat "$work/out")"
fixture; add_wt w1 b1; merge_ff b1
printf '( cd "%s" && echo z > z && git add z && git commit -q -m z )\n' "$work/r/.claude/worktrees/w1" > "$work/lsof.on2"; run --remove
has "skipped" && wt_exists w1 && br_exists b1 && pass "tip moved before recheck skips the row" || fail "moved tip: $(cat "$work/out")"
# The second lsof call is the recheck of the worktree row, after the report read m1's tip.
fixture; add_wt w1 b1; merge_ff b1
( cd "$work/r" && git branch m1 main~1 )
printf 'git -C "%s" update-ref refs/heads/m1 main\n' "$work/r" > "$work/lsof.on2"; run --remove
[ "$(tip m1)" = "$(tip main)" ] && ! wt_exists w1 && pass "branch moved after the report keeps its new ref" || fail "moved branch: $(cat "$work/out")"
rc_is 1 && has "failed" && pass "  ... reported failed, exit 1" || fail "moved branch exit/report: $(cat "$work/out")"

# --- inspection failures ---
fixture; add_wt w1 b1; merge_ff b1; echo 'gitdir: /nonexistent' > "$work/r/.claude/worktrees/w1/.git"; run --remove
row "failing status reads dirty=unknown" "dirty=unknown" "worktrees/w1"
row "  ... and ignored=unknown" "ignored=unknown" "worktrees/w1"
wt_exists w1 && br_exists b1 && pass "  ... and nothing destructive ran" || fail "broken worktree touched"
fixture; add_wt w1 b1; merge_ff b1
printf 'cp "%s/.git" "%s/git.bak"; echo "gitdir: /nonexistent" > "%s/.git"\n' \
  "$work/r/.claude/worktrees/w1" "$work" "$work/r/.claude/worktrees/w1" > "$work/lsof.on2"; run --remove
has "skipped" && wt_exists w1 && br_exists b1 && pass "status failing at the recheck skips the row" || fail "recheck status: $(cat "$work/out")"

# --- archive copy failure, continuation ---
fixture; add_wt w1 b1; merge_ff b1; add_wt w2 b2; merge_ff b2
mkdir -p "$work/r/.claude/worktrees/w1/.context"; echo s > "$work/r/.claude/worktrees/w1/.context/s"
: > "$work/cp.fail"
# Only w1 has a .context/, so only its archive copy calls cp.
run --remove
if wt_exists w1 && br_exists b1 && ! wt_exists w2 && rc_is 1 && has "failed"; then
  pass "failing archive copy keeps that row, next row still removed, exit 1"
else fail "copy failure: $(cat "$work/out")"; fi
fixture; add_wt w1 b1; merge_ff b1; rm -rf "$work/r/.context"; mkdir -p "$work/r/.claude/worktrees/w1/.context"; echo n > "$work/r/.claude/worktrees/w1/.context/n"
run --remove
[ -f "$work/r/.context/archive-worktree-w1/n" ] && pass "main checkout without .context/ gets one" || fail "no main .context: $(cat "$work/out")"

# --- lock, usage, bare ---
fixture; mkdir "$(git -C "$work/r" rev-parse --path-format=absolute --git-common-dir)/worktree-cleanup.lock"; run
rc_is 1 && has "a killed run left it" && pass "held lock exits 1 with the recovery message" || fail "lock: $(cat "$work/out")"
fixture; run --bogus; rc_is 2 && pass "unknown option exits 2" || fail "usage rc $(cat "$work/rc")"
run --discard-ignored; rc_is 2 && pass "--discard-ignored without --remove exits 2" || fail "discard alone rc $(cat "$work/rc")"
run --root relative/dir; rc_is 2 && pass "relative --root exits 2" || fail "relative root rc $(cat "$work/rc")"
( cd "$work" && PATH="$work/stub:$PATH" "$CLEANUP_SH" "$SCRIPT" "$work/o.git" ) > "$work/out" 2>&1; echo $? > "$work/rc"
rc_is 2 && has "bare repository" && pass "bare repository exits 2" || fail "bare: $(cat "$work/out")"
[ -e "$work/o.git/worktree-cleanup.lock" ] && fail "bare run left a lock" || pass "bare run takes no lock"
fixture; run; [ ! -e "$(git -C "$work/r" rev-parse --path-format=absolute --git-common-dir)/worktree-cleanup.lock" ] &&
  pass "lock removed after a run" || fail "lock left behind"

printf '\n---\n'
if [ "$fail_n" -eq 0 ]; then printf 'all passed (%s assertions)\n' "$pass_n"; else
  printf '%s passed, %s FAILED\n' "$pass_n" "$fail_n"; exit 1
fi
