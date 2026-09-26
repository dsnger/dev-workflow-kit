#!/bin/sh
# Tests for codex-gate.sh. Run: sh plugins/dev-workflow/hooks/codex-gate.test.sh
# (from an installed plugin: sh "$CLAUDE_PLUGIN_ROOT"/hooks/codex-gate.test.sh)
set -u
HOOK="$(cd "$(dirname "$0")" && pwd)/codex-gate.sh"
FIXTURES="$(cd "$(dirname "$0")" && pwd)/fixtures"

# The shell the HOOK ITSELF runs under, resolved to an absolute path once. Every runner
# below goes through it, so `HOOK_SH=dash sh codex-gate.test.sh` really does execute all
# of the hook's code under dash — which is the only thing "green under sh and dash" can
# honestly mean.
#
# Before this was parameterized every runner hardcoded `sh` or `/bin/sh`, so running the
# FILE under dash exercised the HARNESS under dash and the hook under whatever `/bin/sh`
# is — bash on macOS. Only the handful of explicit `dash "$HOOK"` rows below ever reached
# dash, and the release evidence generalized from them to all 437. Gate B caught it.
#
# Absolute, because the restricted-PATH runners replace PATH wholesale and a bare name
# would not resolve inside them.
HOOK_SH=${HOOK_SH:-sh}
HOOK_SH_BIN=$(command -v "$HOOK_SH") \
  || { printf 'FATAL: HOOK_SH=%s not found on PATH\n' "$HOOK_SH"; exit 1; }
case "$HOOK_SH_BIN" in
  /*) ;;
  *) printf 'FATAL: HOOK_SH=%s did not resolve to an absolute path (%s)\n' "$HOOK_SH" "$HOOK_SH_BIN"; exit 1 ;;
esac
printf '# hook under test runs with: %s\n' "$HOOK_SH_BIN"
fails=0
pass() { printf 'ok   - %s\n' "$1"; }
fail() { printf 'FAIL - %s\n' "$1"; fails=$((fails + 1)); }

work=$(mktemp -d)
# Restricted-PATH and shim directories live OUTSIDE the test repo. Under $work they
# would be untracked worktree content, so creating one would move the hook's own
# worktree tree id (invariant 3) and every fingerprint assertion after it would drift
# for a reason no label mentions.
sandbox=$(mktemp -d)
trap 'rm -rf "$work" "$sandbox"' EXIT
cd "$work" || exit 1
git init -q
git config user.email t@t; git config user.name t
mkdir -p .context
# This project has adopted the workflow (Finding G) — without a marker the hook is
# silent by design, and every reminder assertion below would pass vacuously. Section 22
# covers the non-adopted repo.
: > .context/codex-gate.on
state=".context/codex-gate.gateB"
count=".context/codex-gate.passCount"
fresh=".context/codex-gate.freshCount"
countA=".context/codex-gate.passCountA"
floorf=".context/codex-gate.floor"
toolsf=".context/codex-gate.tools"
notedf=".context/codex-gate.toolNote"
offf=".context/codex-gate.off"
# The three diagnostic markers. They are written from 0.8.0 onward; naming them here
# lets `reset_all` clear them from the first task, so no section inherits one.
bgadvf=".context/codex-gate.bgAdvice"
unverf=".context/codex-gate.unverified"
pendf=".context/codex-gate.unverifiedPending"

# A HEAD commit must exist so `git diff HEAD` (the tree-hash input) is meaningful.
printf 'v1\n' > app.ts
git add app.ts >/dev/null 2>&1
git commit -qm init >/dev/null 2>&1

# --- payload builders -------------------------------------------------------------
# `printf` and `cat` only, never `jq`: the suite has to run where jq does not, and a
# jq-built payload would make the driver the thing under test instead of the hook.
payload() { # $1 = tool name, $2 = a tool_response ARRAY
  printf '{"hook_event_name":"PostToolUse","tool_name":"%s","tool_input":{},"tool_response":%s}' "$1" "$2"
}
resp() { printf '[{"type":"text","text":"%s"}]' "$1"; }   # $1 = ESCAPED text bytes
resp_from() { cat "$FIXTURES/$1.response.json"; }
resp_success() { resp_from shape0-success; }
unrec() { resp 'not an envelope this hook knows'; }
# Retarget a whole captured fixture to another tool name. `sed` with no /g replaces the
# FIRST match on the line, and every fixture carries its top-level "tool_name" before
# "tool_response", so no response byte is touched.
payload_from() { sed "s|\"tool_name\":\"[^\"]*\"|\"tool_name\":\"$2\"|" "$FIXTURES/$1.json"; }

# --- runners. Named for what they are: a SILENT runner behind a message assertion
# --- makes that assertion vacuous, so the capturing ones say so.
run() { printf '%s' "$1" | "$HOOK_SH_BIN" "$HOOK"; }                                  # capturing
rev() { run "$(payload mcp__codex__review "$(resp_success)")" >/dev/null; }   # silent
revout() { run "$(payload mcp__codex__review "$(resp_success)")"; }           # capturing
execp() { run "$(payload mcp__codex__exec "$(resp_success)")" >/dev/null; }   # silent
# The ONE result-less gate payload the suite still builds, kept so the `no-result`
# path has an input. Everything else that should count carries a real envelope.
rev_noresult() { run '{"hook_event_name":"PostToolUse","tool_name":"mcp__codex__review","tool_input":{}}'; }
codextool() { run "$(payload "$1" "$(resp_success)")"; }                  # capturing
codextool_unrec() { run "$(payload "$1" "$(unrec)")"; }                   # capturing
commitpre() { run '{"hook_event_name":"PreToolUse","tool_name":"Bash","tool_input":{"command":"git commit -m x"}}'; }
commitpost() { run '{"hook_event_name":"PostToolUse","tool_name":"Bash","tool_input":{"command":"git commit -m x"}}' >/dev/null; }

# stdout closed / jq-free, in both combinations. Each RETURNS the hook's status rather
# than printing it: a `PATH=…` scalar cannot be expanded as a command prefix, so the
# redirection has to live inside a function.
run_closed() { printf '%s' "$1" | "$HOOK_SH_BIN" "$HOOK" >&- 2>/dev/null; }
nojq_run() { printf '%s' "$1" | PATH="$nojq" "$HOOK_SH_BIN" "$HOOK"; }
nojq_run_closed() { printf '%s' "$1" | PATH="$nojq" "$HOOK_SH_BIN" "$HOOK" >&- 2>/dev/null; }

# --- restricted PATH builder. The command list is passed as positional parameters, not
# --- as an unquoted variable: `mk_path nojq $HOOK_CMDS` trips SC2086, and the repo's
# --- battery runs shellcheck --shell=sh over this file.
mk_path() { # $1 = directory name under $sandbox, $2.. = commands to link
  _d="$sandbox/$1"; mkdir -p "$_d"; shift
  for _t in "$@"; do
    _p=$(command -v "$_t" 2>/dev/null) || continue
    # `command -v` on a builtin returns a bare name, and symlinking that makes a dangling
    # link that reports "present" to `command -v` inside the hook.
    case "$_p" in /*) ;; *) continue ;; esac
    ln -sf "$_p" "$_d/$_t"
  done
  printf '%s' "$_d"
}

# EVERY external command the hook runs must be linked, not just the one being varied.
# tree_hash shells out to mktemp and cp; without them every jq-free Gate-B scenario
# computes `unavailable` and takes a different branch, so a matrix claiming to compare
# jq and jq-free would be comparing two different code paths. The oracle for that is
# asserted below, right after the PATH is built.
nojq=$(mk_path nojq cat grep sed head tr git mkdir rm cp mktemp awk shasum sha1sum cksum)

# A jq-free PATH whose `sed` fails ONLY for the fallback emitter's escaping pass. Prints
# nothing when the real sed cannot be located, so the caller can skip its assertions.
mk_sedfail_path() {
  _real=$(command -v sed 2>/dev/null) || return 0
  case "$_real" in /*) ;; *) return 0 ;; esac
  _sd=$(mk_path sedfail cat grep head tr git mkdir rm cp mktemp awk shasum sha1sum cksum)
  cat > "$_sd/sed" <<SH
#!/bin/sh
for a in "\$@"; do
  case "\$a" in *'s/"/\\\\"/g'*) exit 1 ;; esac
done
exec $_real "\$@"
SH
  chmod +x "$_sd/sed" || return 0
  printf '%s' "$_sd"
}

reset_gate_state() { rm -f "$state" "$count" "$fresh" "$countA"; }
# Full reset INCLUDING the opt-out marker and the three diagnostic markers. A section
# that wants the gate off must set the marker after calling this.
reset_all() {
  rm -f "$state" "$count" "$fresh" "$countA" "$floorf" "$toolsf" "$notedf" \
        "$bgadvf" "$unverf" "$pendf" "$offf"
}

# 0. THE jq-FREE PATH IS USABLE. Asserted before anything depends on it: if tree_hash
#    cannot run under $nojq it returns the literal `unavailable`, which never matches
#    itself, and every jq-free Gate-B row below would exercise the unhashable branch
#    while its label claimed a jq/jq-free comparison. So require a real, self-matching
#    fingerprint — not merely a non-empty file.
reset_all
nojq_run "$(payload mcp__codex__review "$(resp_success)")" >/dev/null
h_nojq=$(cat "$state" 2>/dev/null || echo '')
case "$h_nojq" in
  '' | unavailable) fail "jq-free PATH records a usable fingerprint (got [$h_nojq])" ;;
  *) pass "jq-free PATH records a usable fingerprint" ;;
esac
nojq_run "$(payload mcp__codex__review "$(resp_success)")" >/dev/null
[ "$(cat "$fresh" 2>/dev/null)" = 2 ] \
  && pass "jq-free fingerprint matches itself across two passes" \
  || fail "jq-free fingerprint matches itself across two passes"
reset_all

# 1. SET on review + bump pass count
rev
[ -f "$state" ] && pass "review creates state" || fail "review creates state"
[ -s "$state" ] && pass "state holds a tree hash (non-empty)" || fail "state holds a tree hash (non-empty)"
[ "$(cat "$count" 2>/dev/null)" = 1 ] && pass "review bumps pass count to 1" || fail "review bumps pass count to 1"

# 2. Below floor (1/3) -> below-floor reminder; reaching floor (3/3) -> hook checks passed
out=$(commitpre)
printf '%s' "$out" | grep -qE 'below floor|floor NOT met' && pass "1/3 passes -> below floor" || fail "1/3 passes -> below floor"
printf '%s' "$out" | grep -q 'hookSpecificOutput' && pass "emits JSON additionalContext" || fail "emits JSON additionalContext"
rev; rev  # reach the floor: 3 passes total, tree unchanged
out=$(commitpre)
printf '%s' "$out" | grep -q 'Gate B hook checks passed' && pass "3/3 passes, unchanged tree -> hook checks passed" || fail "3/3 passes, unchanged tree -> hook checks passed"

# 3. FINDING 1 — content-based invalidation.
#    (Replaces the old event-based assertion `[ ! -f state ]` after an Edit. The state
#    file now legitimately SURVIVES a change — it holds the reviewed hash — so the
#    intent "a change means the hook cannot confirm the reviewed content" is asserted at the BEHAVIOR level.)
# 3a. Edit-tool change -> stale
printf 'v2\n' >> app.ts
run '{"hook_event_name":"PostToolUse","tool_name":"Edit","tool_input":{"file_path":"app.ts"}}' >/dev/null
out=$(commitpre)
printf '%s' "$out" | grep -q 'Codex gate state:' && pass "Edit-tool change -> gate-state reminder" || fail "Edit-tool change -> gate-state reminder"
printf '%s' "$out" | grep -q 'cannot confirm' && pass "Edit-tool change -> reported as unconfirmed" || fail "Edit-tool change -> reported as unconfirmed"

# 3b. THE MAJOR: a file changed through BASH (no Edit/Write event at all) -> stale.
#     Under the old event-based scheme this produced a false ✓.
reset_all
rev; rev; rev                       # 3 clean passes on the current tree
out=$(commitpre)
printf '%s' "$out" | grep -q 'Gate B hook checks passed' && pass "setup: hook checks passed before bash edit" || fail "setup: hook checks passed before bash edit"
printf 'sed-style in-place edit\n' >> app.ts   # NO hook event fires for this
out=$(commitpre)
printf '%s' "$out" | grep -q 'Codex gate state:' && pass "bash-modified file after review -> gate-state reminder (Finding 1)" || fail "bash-modified file after review -> gate-state reminder (Finding 1)"

# 3c. Untracked new file after review -> stale
git checkout -- app.ts >/dev/null 2>&1
reset_all
rev; rev; rev
printf '%s' "$(commitpre)" | grep -q 'Gate B hook checks passed' && pass "setup: hook checks passed on clean tree" || fail "setup: hook checks passed on clean tree"
printf 'new\n' > brand-new.ts
out=$(commitpre)
printf '%s' "$out" | grep -q 'Codex gate state:' && pass "untracked new file after review -> gate-state reminder" || fail "untracked new file after review -> gate-state reminder"

# 3c-bis. Untracked CONTENT counts, not just the name. `git add f && git commit` is one
# Bash call, so the hook sees `f` still untracked — a name-only hash would hand that
# commit a stale ✓ on edited content (invariant 3).
reset_all; rev; rev; rev   # re-review with brand-new.ts present, so its name is known
printf '%s' "$(commitpre)" | grep -q 'Gate B hook checks passed' && pass "setup: hook checks passed with untracked file present" || fail "setup: hook checks passed with untracked file present"
printf 'edited\n' > brand-new.ts   # same name, different content
printf '%s' "$(commitpre)" | grep -q 'Codex gate state:' && pass "edited untracked file -> gate-state reminder" || fail "edited untracked file -> gate-state reminder"

# ...and a file inside a NEW untracked directory too: porcelain would collapse that to
# a single `dir/` entry and never hash what is in it.
reset_all; rev; rev; rev
mkdir -p newdir && printf 'a\n' > newdir/f.ts
printf '%s' "$(commitpre)" | grep -q 'Codex gate state:' && pass "new untracked dir -> gate-state reminder" || fail "new untracked dir -> gate-state reminder"
reset_all; rev; rev; rev
printf 'b\n' > newdir/f.ts
printf '%s' "$(commitpre)" | grep -q 'Codex gate state:' && pass "edited file in untracked dir -> gate-state reminder" || fail "edited file in untracked dir -> gate-state reminder"
rm -rf newdir

# ...and paths git does not print literally. It C-quotes non-ASCII and control
# characters ("caf\303\251.txt", quotes included), which names no real file, so a
# shell-side content read would silently come back empty.
for name in "café ñ.ts" "$(printf 'tab\tnewline\nname.ts')"; do
  reset_all; rev; rev; rev
  printf 'a\n' > "$name"
  printf '%s' "$(commitpre)" | grep -q 'Codex gate state:' && pass "new exotic-path untracked file -> gate-state reminder" || fail "new exotic-path untracked file -> gate-state reminder"
  reset_all; rev; rev; rev
  printf 'b\n' > "$name"
  printf '%s' "$(commitpre)" | grep -q 'Codex gate state:' && pass "edited exotic-path untracked file -> gate-state reminder" || fail "edited exotic-path untracked file -> gate-state reminder"
  rm -f "$name"
done

# A commit stores a symlink's TARGET, so retargeting one is a content change even when
# both targets are absent — and reading through the link instead would compare the
# referents, or block forever on a link to a FIFO.
reset_all; rev; rev; rev
ln -s absent-a link.ts
printf '%s' "$(commitpre)" | grep -q 'Codex gate state:' && pass "new untracked symlink -> gate-state reminder" || fail "new untracked symlink -> gate-state reminder"
reset_all; rev; rev; rev
rm -f link.ts; ln -s absent-b link.ts
printf '%s' "$(commitpre)" | grep -q 'Codex gate state:' && pass "retargeted untracked symlink -> gate-state reminder" || fail "retargeted untracked symlink -> gate-state reminder"
rm -f link.ts

# NOTE: sections 24-25 cover the "could not be computed" guard for checksum, seed-copy,
# git-dir and diff failures. Still uncovered: a `git add`/`write-tree` failure inside the
# throwaway index (see the tree-unavailable row in todos.md, which stays parked).

# A FIFO is not committable content; hashing must skip it rather than block on a
# reader that never arrives. The hook is advisory and must not be able to wedge a
# commit — so this asserts termination, not a particular verdict.
if command -v mkfifo >/dev/null 2>&1; then
  reset_all; rev; rev; rev
  mkfifo pipe.ts 2>/dev/null
  ( commitpre >/dev/null 2>&1 ) & fifo_pid=$!
  ( sleep 10; kill -9 $fifo_pid 2>/dev/null ) & killer=$!
  wait $fifo_pid 2>/dev/null; fifo_rc=$?
  # Reap the watchdog, don't just signal it: an unreaped killed job makes the shell
  # print "Terminated: 15" into the quality command's output on every green run.
  kill $killer 2>/dev/null
  wait $killer 2>/dev/null || true
  # Any signal death is >128; testing only 137 assumes a SIGKILL status POSIX does
  # not guarantee. What is asserted is termination, not a particular verdict.
  [ "$fifo_rc" -le 128 ] && pass "untracked FIFO does not hang the hook" || fail "untracked FIFO does not hang the hook"
  rm -f pipe.ts
fi

rm -f brand-new.ts
reset_all; rev; rev; rev

# 3d. Reverting the tree back to the reviewed content -> hook checks pass again
#     (content-based, so an edit-then-undo is correctly NOT stale)
out=$(commitpre)
printf '%s' "$out" | grep -q 'Gate B hook checks passed' && pass "revert to reviewed tree -> hook checks pass again" || fail "revert to reviewed tree -> hook checks pass again"

# 3e. The hook's own .context/ churn must NOT change the hash (else it never matches itself)
rev  # writes state files
out=$(commitpre)
printf '%s' "$out" | grep -q 'Gate B hook checks passed' && pass ".context/ churn does not invalidate the hash" || fail ".context/ churn does not invalidate the hash"

# 3e-bis. ...including when .context/ is COMMITTED. Filtering only the untracked list
# leaves tracked state in `git diff HEAD`, where the hook's own writes invalidate the
# review it just recorded -> a permanent stale-fingerprint reminder. The adoption marker is meant to be
# shared, so a tracked .context/ is the normal case.
git add -f .context >/dev/null 2>&1; git commit -qm "track .context" >/dev/null 2>&1
reset_all
rev; rev; rev
printf '%s' "$(commitpre)" | grep -q 'Gate B hook checks passed' && pass "tracked .context/ state does not invalidate the hash" || fail "tracked .context/ state does not invalidate the hash"
rev  # more churn against the committed state
printf '%s' "$(commitpre)" | grep -q 'Gate B hook checks passed' && pass "tracked .context/ churn still passes the hook checks" || fail "tracked .context/ churn still passes the hook checks"

# 3e-ter. GAP 1 — the INDEX-tree component must exclude .context/ too, not just the
# diff-HEAD and worktree-tree components (each guarded by its own `:(exclude)`
# pathspec, untouched by this bug). Unstaged .context/ churn never reaches the real git
# index, so the two assertions above never exercise the `git rm --cached ... .context`
# line at all: nothing forces it to matter. STAGING the churn is the only way to make it
# matter — but staging .context ALONE trips the docs-only branch (is_docs_only treats
# .context/ as documentation) before Gate B is even evaluated, so a second staged,
# non-.context file is needed just to reach the fingerprint comparison at all.
# sidefile.ts is a throwaway file kept byte-identical for the whole test, so it cannot
# be the thing that (in)validates — only the .context staging can.
printf 'side\n' > sidefile.ts; git add sidefile.ts >/dev/null 2>&1
rev; rev; rev
printf '%s' "$(commitpre)" | grep -q 'Gate B hook checks passed' && pass "setup: hook checks passed with sidefile.ts staged" || fail "setup: hook checks passed with sidefile.ts staged"
rev                                       # hook writes fresh state into .context/
git add -f .context >/dev/null 2>&1       # stage the hook's own churn (sidefile.ts untouched)
out=$(commitpre)
printf '%s' "$out" | grep -q 'Gate B hook checks passed' \
  && pass "staged .context churn does not invalidate (index-tree .context exclusion)" \
  || fail "staged .context churn does not invalidate (index-tree .context exclusion)"
git rm -q --cached sidefile.ts >/dev/null 2>&1; rm -f sidefile.ts
git reset -q -- .context >/dev/null 2>&1  # unstage; real index back to HEAD for .context/

# ...while a real code change is still caught
printf 'code change\n' >> app.ts
printf '%s' "$(commitpre)" | grep -q 'Codex gate state:' && pass "tracked .context/: real code change still invalidates" || fail "tracked .context/: real code change still invalidates"
git checkout -- app.ts >/dev/null 2>&1
git rm -rq --cached .context >/dev/null 2>&1; git commit -qm "untrack .context" >/dev/null 2>&1
reset_all; rev; rev; rev

# 3f. DECIDED at spec §2 (2026-07-19-gate-b-index-tree-design.md): staging
#     already-reviewed content DOES invalidate. The hash covers the index tree, and
#     `git add` changes it. The bytes that would be committed are unchanged, so this is
#     a false invalidation — accepted under invariant 2 ("loose in the firing
#     direction"), and the stale-fingerprint message explains that staging alone can cause it.
#     This test previously asserted the OPPOSITE as though it were a principle; the
#     behaviour was never decided, it fell out of an implementation choice.
reset_all
printf 'reviewed change\n' >> app.ts
rev; rev; rev                       # 3 passes covering the modified (unstaged) tree
printf '%s' "$(commitpre)" | grep -q 'Gate B hook checks passed' && pass "setup: hook checks passed on unstaged change" || fail "setup: hook checks passed on unstaged change"
git add app.ts >/dev/null 2>&1      # staging only — no content change
printf '%s' "$(commitpre)" | grep -q 'Codex gate state:' \
  && pass "staging a reviewed tracked file -> gate-state reminder (spec §2 decision)" \
  || fail "staging a reviewed tracked file -> gate-state reminder (spec §2 decision)"
# The old trailing assertion ("untracked file on a staged tree -> gate-state reminder") is
# GONE on purpose: once staging alone invalidates, it passes regardless of the untracked
# file and tests nothing. Test 3c already covers untracked content.
git reset -q >/dev/null 2>&1; git checkout -- app.ts >/dev/null 2>&1
reset_all; rev; rev; rev

# 4. Gate A exec must NOT count toward Gate B (separate state)
reset_all
execp
[ ! -f "$state" ] && pass "exec does not set Gate B" || fail "exec does not set Gate B"

# 5. RESET on commit
reset_all
rev
[ -f "$state" ] && commitpost && [ ! -f "$state" ] && pass "commit resets state" || fail "commit resets state"
[ ! -f "$count" ] && pass "commit resets pass count" || fail "commit resets pass count"
[ ! -f "$fresh" ] && pass "commit resets fresh count" || fail "commit resets fresh count"

# 6. Gate A reminder only for plan-execution skills
out=$(run '{"hook_event_name":"PreToolUse","tool_name":"Skill","tool_input":{"skill":"superpowers:executing-plans"}}')
printf '%s' "$out" | grep -q 'Gate A' && pass "executing-plans -> Gate A reminder" || fail "executing-plans -> Gate A reminder"
out=$(run '{"hook_event_name":"PreToolUse","tool_name":"Skill","tool_input":{"skill":"superpowers:brainstorming"}}')
[ -z "$out" ] && pass "other skill -> no reminder" || fail "other skill -> no reminder"

# 7. Loose commit matcher (incl. no-space and semicolon separators)
reset_all
for c in "git commit --amend" "git -c user.x=y commit" "pnpm test && git commit -m x" "a&&git commit -m x" "a;git commit -m x"; do
  out=$(run "{\"hook_event_name\":\"PreToolUse\",\"tool_name\":\"Bash\",\"tool_input\":{\"command\":\"$c\"}}")
  printf '%s' "$out" | grep -q 'Gate B' && pass "matches: $c" || fail "matches: $c"
done

# 8. Non-commit Bash -> silent
out=$(run '{"hook_event_name":"PreToolUse","tool_name":"Bash","tool_input":{"command":"ls -la"}}')
[ -z "$out" ] && pass "non-commit bash -> silent" || fail "non-commit bash -> silent"

# 8b. Word boundary: "git" embedded in another word must NOT trigger
out=$(run '{"hook_event_name":"PreToolUse","tool_name":"Bash","tool_input":{"command":"echo digit commit"}}')
[ -z "$out" ] && pass "embedded 'digit commit' -> silent (word boundary)" || fail "embedded 'digit commit' -> silent (word boundary)"

# 9. jq-absent fallback, on the SHARED $nojq built at the top of this file under
#    $sandbox. This section used to REASSIGN $nojq to "$work/nojq" — untracked content
#    inside the test repo, so creating it moved the hook's own worktree tree id
#    (invariant 3) — and its command list omitted `cp`/`mktemp`, which tree_hash shells
#    out to, so every later jq-free fingerprint row took the `unavailable` branch while
#    its label claimed a jq/jq-free comparison. Section 0 asserts this PATH's contract.
if PATH="$nojq" command -v git >/dev/null 2>&1 && ! PATH="$nojq" command -v jq >/dev/null 2>&1; then
  reset_all
  out=$(printf '%s' '{"hook_event_name":"PreToolUse","tool_name":"Bash","tool_input":{"command":"git commit -m x"}}' | PATH="$nojq" "$HOOK_SH_BIN" "$HOOK")
  printf '%s' "$out" | grep -q 'Gate B' && pass "jq-absent fallback works" || fail "jq-absent fallback works"
  # 9b. fallback must not be confused by a literal } inside the command
  out=$(printf '%s' '{"hook_event_name":"PreToolUse","tool_name":"Bash","tool_input":{"command":"git commit -m }"}}' | PATH="$nojq" "$HOOK_SH_BIN" "$HOOK")
  printf '%s' "$out" | grep -q 'Gate B' && pass "jq-absent: brace in command still matches" || fail "jq-absent: brace in command still matches"
else
  printf 'skip - jq-absent fallback (could not build jq-free PATH)\n'
fi

# 10. additionalContext JSON field is present + non-empty (the emit channel; Finding 8)
if command -v jq >/dev/null 2>&1; then
  out=$(run '{"hook_event_name":"PreToolUse","tool_name":"Skill","tool_input":{"skill":"superpowers:executing-plans"}}')
  ctx=$(printf '%s' "$out" | jq -r '.hookSpecificOutput.additionalContext // empty')
  [ -n "$ctx" ] && pass "additionalContext field present + non-empty" || fail "additionalContext field present + non-empty"
fi

# 11. State-write failure must still exit 0 (special-builtin redirection regression)
rm -rf .context; : > .context  # make .context a FILE so the state dir cannot be created
printf '%s' "$(payload mcp__codex__review "$(resp_success)")" | "$HOOK_SH_BIN" "$HOOK"; rc=$?
[ "$rc" = 0 ] && pass "state-write failure still exits 0" || fail "state-write failure still exits 0 (got $rc)"
rm -f .context; mkdir -p .context; : > .context/codex-gate.on  # restore (incl. adoption)

# 12. Per-workspace opt-out: .context/codex-gate.off silences reminders
off=".context/codex-gate.off"
reset_all
: > "$off"
rev  # would normally produce a ✓/floor reminder
out=$(commitpre)
[ -z "$out" ] && pass "off marker silences Gate B reminder" || fail "off marker silences Gate B reminder"
out=$(run '{"hook_event_name":"PreToolUse","tool_name":"Skill","tool_input":{"skill":"superpowers:executing-plans"}}')
[ -z "$out" ] && pass "off marker silences Gate A reminder" || fail "off marker silences Gate A reminder"

# 13. Full state machine keeps running while off (same counting semantics as gate-on,
#     not evidence of review)
# `reset_all` now clears the opt-out marker too, so it has to be re-set here — without
# this the two assertions below still pass, but with the gate ON, and the words "while
# off" in their labels would be false.
reset_all
: > "$off"
rev
[ -f "$state" ] && pass "review still SETs state while off" || fail "review still SETs state while off"
commitpost
[ ! -f "$state" ] && pass "commit still RESETs state while off" || fail "commit still RESETs state while off"
rm -f "$off"  # re-enable
reset_all
rev; rev; rev
out=$(commitpre)
printf '%s' "$out" | grep -q 'Gate B hook checks passed' && pass "re-enable sees same counting semantics as gate-on, not evidence of review" || fail "re-enable sees same counting semantics as gate-on, not evidence of review"

# 14. Below-floor reminder shows N/floor
reset_all
rev; rev
out=$(commitpre)
printf '%s' "$out" | grep -q '2/3' && pass "below-floor reminder shows N/3" || fail "below-floor reminder shows N/3"

# 14b. Docs-only commit -> gentle N/A note; mixed and undeterminable commits still fire.
reset_all   # state ABSENT -> would normally emit the no-fingerprint reminder on a code commit
mkdir -p docs
printf 'spec\n' > docs/plan.md; printf 'readme\n' > NOTES.md
git add docs/plan.md NOTES.md >/dev/null 2>&1
out=$(commitpre)
printf '%s' "$out" | grep -q 'docs-only commit' && pass "docs-only staged -> N/A note" || fail "docs-only staged -> N/A note"
printf '%s' "$out" | grep -q 'Codex gate state:' && fail "docs-only must not emit the gate-state reminder" || pass "docs-only does not emit the gate-state reminder"
printf 'code\n' > extra.ts; git add extra.ts >/dev/null 2>&1
out=$(commitpre)
printf '%s' "$out" | grep -q 'Gate B' && pass "mixed staged -> Gate B fires" || fail "mixed staged -> Gate B fires"
git rm -q --cached extra.ts >/dev/null 2>&1; rm -f extra.ts

# Prompt Markdown is product, not docs: a .md-only commit touching a skill, a slash
# command, plugin content or an instruction file must still fire Gate B.
for p in skills/x/SKILL.md commands/y.md plugins/p/skills/z/SKILL.md .claude/w.md CLAUDE.md AGENTS.md; do
  mkdir -p "$(dirname "$p")" 2>/dev/null
  printf 'prompt\n' > "$p"; git add "$p" >/dev/null 2>&1
  out=$(commitpre)
  # Assert positively on the reminder AND negatively on the N/A note: checking only
  # for the absence of "docs-only commit" would pass on empty output.
  printf '%s' "$out" | grep -q 'Gate B' && pass "prompt .md ($p) -> Gate B fires" || fail "prompt .md ($p) -> Gate B fires"
  printf '%s' "$out" | grep -q 'docs-only commit' && fail "prompt .md ($p) must not be N/A" || pass "prompt .md ($p) not N/A"
  git rm -q --cached "$p" >/dev/null 2>&1; rm -f "$p"
done

# The any-depth match is deliberate (invariant 2): prose under a directory named
# `commands/` fires too. Pinned as intended behaviour, not left to be "fixed" later.
mkdir -p docs/commands
printf 'prose\n' > docs/commands/reference.md; git add docs/commands/reference.md >/dev/null 2>&1
out=$(commitpre)
printf '%s' "$out" | grep -q 'Gate B' && pass "docs/commands/*.md over-fires by design" || fail "docs/commands/*.md over-fires by design"
git rm -q --cached docs/commands/reference.md >/dev/null 2>&1
rm -rf docs/commands
rm -rf skills commands plugins .claude CLAUDE.md AGENTS.md
printf 'code\n' > extra.ts; git add extra.ts >/dev/null 2>&1
git commit -qm seed >/dev/null 2>&1
printf 'spec1b\n' >> docs/plan.md; git add docs/plan.md >/dev/null 2>&1
out=$(run '{"hook_event_name":"PreToolUse","tool_name":"Bash","tool_input":{"command":"git commit -am x"}}')
printf '%s' "$out" | grep -q 'docs-only commit' && pass "-am docs-only, no unstaged code -> N/A note" || fail "-am docs-only, no unstaged code -> N/A note"
printf 'changed\n' >> extra.ts   # tracked-unstaged code change swept in by -a
out=$(run '{"hook_event_name":"PreToolUse","tool_name":"Bash","tool_input":{"command":"git commit -am x"}}')
printf '%s' "$out" | grep -q 'Gate B' && pass "-am with unstaged code -> Gate B fires" || fail "-am with unstaged code -> Gate B fires"
git checkout -- extra.ts >/dev/null 2>&1
git rm -q --cached docs/plan.md NOTES.md >/dev/null 2>&1
rm -f NOTES.md docs/plan.md; rmdir docs 2>/dev/null
git add -A >/dev/null 2>&1; git commit -qm cleanup >/dev/null 2>&1
reset_all

# 15. Gate A floor: exec bumps its own counter; plan-execution skill enforces + resets
rm -f "$countA"
execp
[ "$(cat "$countA" 2>/dev/null)" = 1 ] && pass "exec bumps Gate A count to 1" || fail "exec bumps Gate A count to 1"
out=$(run '{"hook_event_name":"PreToolUse","tool_name":"Skill","tool_input":{"skill":"superpowers:executing-plans"}}')
printf '%s' "$out" | grep -qE 'below floor|floor NOT met' && pass "1/3 exec -> Gate A below floor" || fail "1/3 exec -> Gate A below floor"
execp
execp
out=$(run '{"hook_event_name":"PreToolUse","tool_name":"Skill","tool_input":{"skill":"superpowers:executing-plans"}}')
printf '%s' "$out" | grep -q 'floor met' && pass "3/3 exec -> Gate A floor met" || fail "3/3 exec -> Gate A floor met"
# FINDING 12: the Gate-A floor-met wording must NOT overstate — it counts calls only.
printf '%s' "$out" | grep -qE 'count only|COUNT ONLY' && pass "Gate A floor-met message says 'count only' (Finding 12)" || fail "Gate A floor-met message says 'count only' (Finding 12)"
run '{"hook_event_name":"PostToolUse","tool_name":"Skill","tool_input":{"skill":"superpowers:executing-plans"}}' >/dev/null
[ ! -f "$countA" ] && pass "plan execution resets Gate A count" || fail "plan execution resets Gate A count"

# 16. Every other Gate-A reset trigger zeroes a stale count
for s in superpowers:brainstorming superpowers:writing-plans superpowers:subagent-driven-development; do
  execp
  [ -f "$countA" ] || fail "setup: exec should create countA for $s"
  run "{\"hook_event_name\":\"PostToolUse\",\"tool_name\":\"Skill\",\"tool_input\":{\"skill\":\"$s\"}}" >/dev/null
  [ ! -f "$countA" ] && pass "$s resets stale Gate A count" || fail "$s resets stale Gate A count"
done

# 17. FINDING 6 — per-project floor override via .context/codex-gate.floor
reset_all
printf '1' > "$floorf"
rev
out=$(commitpre)
printf '%s' "$out" | grep -q '1/1' && pass "floor override 1 -> hook checks pass at 1 pass" || fail "floor override 1 -> hook checks pass at 1 pass"
printf '%s' "$out" | grep -q 'Gate B hook checks passed' && pass "floor override 1 -> reports hook checks passed" || fail "floor override 1 -> reports hook checks passed"
reset_all
printf '5' > "$floorf"
rev; rev; rev
out=$(commitpre)
printf '%s' "$out" | grep -q '3/5' && pass "floor override 5 -> 3 passes below floor" || fail "floor override 5 -> 3 passes below floor"
# Invalid overrides fall back to the default 3 (a typo must not disable the gate)
for bad in 0 -2 three ""; do
  reset_all
  printf '%s' "$bad" > "$floorf"
  rev; rev
  out=$(commitpre)
  printf '%s' "$out" | grep -q '2/3' && pass "invalid floor '$bad' -> falls back to 3" || fail "invalid floor '$bad' -> falls back to 3"
done
rm -f "$floorf"

# 18. FINDING 9 — hook-checks-passed message distinguishes fresh passes from cycle passes
reset_all
rev; rev; rev            # 3 passes on the current tree
printf 'post-review rewrite\n' >> app.ts   # big change AFTER the passes
rev                      # one fresh pass on the new tree
out=$(commitpre)
printf '%s' "$out" | grep -q '4/3' && pass "cycle total counts all 4 passes" || fail "cycle total counts all 4 passes"
# -F on the real wording: the old pattern's first alternative ("1 cover the CURRENT
# tree") was renamed to "CURRENT content fingerprint" by this PR and matched nothing,
# leaving the assertion resting on `\|` — alternation only under GNU-style BRE, literal
# under POSIX, so it would have failed on a stock BSD grep (invariant 4: machines we do
# not control).
printf '%s' "$out" | grep -qF 'of which 1 cover the CURRENT content fingerprint' && pass "fresh count reports only 1 pass covers current code (Finding 9)" || fail "fresh count reports only 1 pass covers current code (Finding 9)"
git checkout -- app.ts >/dev/null 2>&1
reset_all

# 19. FINDING 11 — WIP commit is cycle-internal: gentle note, no gate-state reminder, no reset
reset_all
rev; rev                                   # 2 passes accumulated
wip() { run "{\"hook_event_name\":\"PreToolUse\",\"tool_name\":\"Bash\",\"tool_input\":{\"command\":\"$1\"}}"; }
out=$(wip "git commit -m 'wip: pre-review snapshot'")
printf '%s' "$out" | grep -q 'Codex gate state:' && fail "WIP commit must not emit the gate-state reminder" || pass "WIP commit does not emit the gate-state reminder"
printf '%s' "$out" | grep -q 'WIP commit' && pass "WIP commit -> gentle note" || fail "WIP commit -> gentle note"
out=$(wip "git commit -m 'WIP: caps variant'")
printf '%s' "$out" | grep -q 'WIP commit' && pass "WIP matcher is case-insensitive" || fail "WIP matcher is case-insensitive"
# PostToolUse: a WIP commit must PRESERVE the counters (the cycle is still open)
run '{"hook_event_name":"PostToolUse","tool_name":"Bash","tool_input":{"command":"git commit -m \"wip: snapshot\""}}' >/dev/null
[ "$(cat "$count" 2>/dev/null)" = 2 ] && pass "WIP commit preserves pass count (Finding 11)" || fail "WIP commit preserves pass count (Finding 11)"
[ -f "$state" ] && pass "WIP commit preserves Gate B state" || fail "WIP commit preserves Gate B state"
# A real (non-WIP) commit still resets
commitpost
[ ! -f "$count" ] && pass "non-WIP commit still resets counters" || fail "non-WIP commit still resets counters"

# 20. FINDING F — a Codex server whose tools the gates can't attribute
reset_all
out=$(codextool mcp__codex__codex)
printf '%s' "$out" | grep -q 'not counted' && pass "unknown codex tool -> note" || fail "unknown codex tool -> note"
printf '%s' "$out" | grep -q 'mcp__codex__codex' && pass "note names the offending tool" || fail "note names the offending tool"
printf '%s' "$out" | grep -q 'codex-gate.tools' && pass "note points at the mapping file" || fail "note points at the mapping file"
[ ! -f "$state" ] && [ ! -f "$countA" ] && pass "unknown codex tool bumps no counter" || fail "unknown codex tool bumps no counter"
# ...and it stays said exactly once
out=$(codextool mcp__codex__codex)
[ -z "$out" ] && pass "unknown codex tool note is one-time" || fail "unknown codex tool note is one-time"
out=$(codextool mcp__codex__codex-reply)
[ -z "$out" ] && pass "marker also silences a second unknown tool" || fail "marker also silences a second unknown tool"
# A suppressed note must not burn the marker — else re-enabling never surfaces it.
reset_all
: > "$off"
out=$(codextool mcp__codex__codex)
[ -z "$out" ] && pass "off marker silences the unknown-tool note" || fail "off marker silences the unknown-tool note"
[ ! -f "$notedf" ] && pass "suppressed note does not burn its one-time marker" || fail "suppressed note does not burn its one-time marker"
rm -f "$off"
out=$(codextool mcp__codex__codex)
printf '%s' "$out" | grep -q 'not counted' && pass "re-enable still surfaces the note" || fail "re-enable still surfaces the note"

# 21. FINDING F — .context/codex-gate.tools maps the gates onto other tool names
reset_all
printf 'execTool=mcp__codex__codex\nreviewTool=mcp__codex__codex_review\n' > "$toolsf"
codextool mcp__codex__codex >/dev/null
[ "$(cat "$countA" 2>/dev/null)" = 1 ] && pass "mapped execTool bumps Gate A count" || fail "mapped execTool bumps Gate A count"
codextool mcp__codex__codex_review >/dev/null
[ "$(cat "$count" 2>/dev/null)" = 1 ] && pass "mapped reviewTool bumps Gate B count" || fail "mapped reviewTool bumps Gate B count"
[ -s "$state" ] && pass "mapped reviewTool sets the tree hash" || fail "mapped reviewTool sets the tree hash"
printf '5' > "$floorf"; codextool mcp__codex__codex_review >/dev/null
out=$(commitpre)
printf '%s' "$out" | grep -q '2/5' && pass "mapped review passes reach the Gate B reminder" || fail "mapped review passes reach the Gate B reminder"
rm -f "$floorf"
# A mapping is a replacement, not an addition: the default names now go uncounted,
# and the unknown-tool note is what tells the user so.
out=$(codextool mcp__codex__exec)
printf '%s' "$out" | grep -q 'not counted' && pass "mapping displaces the default names" || fail "mapping displaces the default names"
# No trailing newline on the last line must still parse
reset_all
printf 'execTool=mcp__codex__codex' > "$toolsf"
codextool mcp__codex__codex >/dev/null
[ "$(cat "$countA" 2>/dev/null)" = 1 ] && pass "mapping without trailing newline parses" || fail "mapping without trailing newline parses"
# Invalid mappings are ignored -> defaults stand (a typo must not silently unhook a gate)
for bad in 'execTool=' 'execTool=has space' 'execTool=glob*' '# comment' 'bogusKey=x' ''; do
  reset_all
  printf '%s\n' "$bad" > "$toolsf"
  codextool mcp__codex__exec >/dev/null
  [ "$(cat "$countA" 2>/dev/null)" = 1 ] && pass "invalid mapping '$bad' -> default exec name still counts" || fail "invalid mapping '$bad' -> default exec name still counts"
done
reset_all

# 22. FINDING G — the hook is global; adoption is per project. A repo that never ran
#     /workflow-init has no §5 to cite, so it hears nothing at all.
reset_all
on=".context/codex-gate.on"
rm -f "$on"
rev; rev; rev
[ -z "$(commitpre)" ] && pass "non-adopted repo: commit -> silent" || fail "non-adopted repo: commit -> silent"
reset_all
[ -z "$(commitpre)" ] && pass "non-adopted repo: unreviewed commit -> no reminder" || fail "non-adopted repo: unreviewed commit -> no reminder"
out=$(run '{"hook_event_name":"PreToolUse","tool_name":"Skill","tool_input":{"skill":"superpowers:executing-plans"}}')
[ -z "$out" ] && pass "non-adopted repo: Gate A -> silent" || fail "non-adopted repo: Gate A -> silent"
[ -z "$(codextool mcp__codex__codex)" ] && pass "non-adopted repo: unknown-tool note -> silent" || fail "non-adopted repo: unknown-tool note -> silent"
out=$(run '{"hook_event_name":"PreToolUse","tool_name":"Bash","tool_input":{"command":"git commit -m \"wip: x\""}}')
[ -z "$out" ] && pass "non-adopted repo: WIP note -> silent" || fail "non-adopted repo: WIP note -> silent"
# Silent is not enough: a non-adopted repo must be INERT. Writing state would litter an
# unrelated project with a .context/ it never asked for.
reset_all
rev; execp
[ ! -f "$state" ] && [ ! -f "$count" ] && [ ! -f "$countA" ] && pass "non-adopted repo writes no state" || fail "non-adopted repo writes no state"
# ...even into a .context/ that does not exist yet (the dir itself must not appear)
sub=$(mktemp -d); (cd "$sub" && git init -q && git config user.email t@t && git config user.name t && printf 'x\n' > a.ts && git add -A && git commit -qm i) >/dev/null 2>&1
out=$(printf '%s' "$(payload mcp__codex__review "$(resp_success)")" | (cd "$sub" && "$HOOK_SH_BIN" "$HOOK"))
[ ! -d "$sub/.context" ] && pass "non-adopted repo: no .context/ directory created" || fail "non-adopted repo: no .context/ directory created"
rm -rf "$sub"

# 22b. Either adoption marker is enough, and it takes effect without a restart.
#      (Each CLAUDE.md write is itself a tree change, so the passes are re-run after
#      one — otherwise a stale-fingerprint reminder would masquerade as non-adoption.)
reset_all
printf '# p\n\n## 5. Something else entirely\n' > CLAUDE.md      # a CLAUDE.md without the gates
rm -f "$on"
rev; rev; rev                                                    # inert: these must not register
[ -z "$(commitpre)" ] && pass "unrelated CLAUDE.md -> not adopted" || fail "unrelated CLAUDE.md -> not adopted"
: > "$on"                                                        # the explicit marker
rev; rev; rev                                                    # passes only count once adopted
printf '%s' "$(commitpre)" | grep -q 'Gate B hook checks passed' && pass ".on marker alone -> adopted" || fail ".on marker alone -> adopted"
rm -f "$on"
[ -z "$(commitpre)" ] && pass "removing the marker -> silent again" || fail "removing the marker -> silent again"
printf '# p\n\n## 5. Cross-Model Review (Codex)\n' > CLAUDE.md   # the committed, team-wide signal
rev; rev; rev
printf '%s' "$(commitpre)" | grep -q 'Gate B hook checks passed' && pass "CLAUDE.md gate heading -> adopted" || fail "CLAUDE.md gate heading -> adopted"

# 22bis. Adoption needs the gate SECTION, not the words. A substring grep adopts a
#        project on a passing mention — including one that says the opposite.
reset_all
rm -f "$on"
adopt_md() { printf '%s\n' "$1" > CLAUDE.md; reset_all; rev; rev; rev; }
# Prose mentions must NOT adopt
for prose in \
  'This project does not use Cross-Model Review.' \
  'We evaluated Cross-Model Review and rejected it.' \
  '## Appendix: why we dropped Cross-Model Review'
do
  adopt_md "# proj

$prose"
  [ -z "$(commitpre)" ] && pass "prose/mention '$(printf '%.28s' "$prose")…' -> not adopted" || fail "prose/mention '$(printf '%.28s' "$prose")…' -> not adopted"
done
# The real heading adopts, at any level, and is cited by its OWN number (the template
# renumbers the section when the file already uses §5).
adopt_md "# proj

## 5. Cross-Model Review (Codex) — TWO MANDATORY GATES"
printf '%s' "$(commitpre)" | grep -q 'CLAUDE.md §5' && pass "gate heading -> adopted, cites §5" || fail "gate heading -> adopted, cites §5"
adopt_md "# proj

## 7. Cross-Model Review (Codex)"
out=$(commitpre)
printf '%s' "$out" | grep -q 'CLAUDE.md §7' && pass "renumbered heading -> cites §7, not §5" || fail "renumbered heading -> cites §7, not §5"
printf '%s' "$out" | grep -q '§5' && fail "renumbered heading must not cite §5" || pass "renumbered heading never says §5"
adopt_md "# proj

#### 5. Cross-Model Review (Codex)"
printf '%s' "$(commitpre)" | grep -q 'Gate B' && pass "deeper heading level -> adopted" || fail "deeper heading level -> adopted"
adopt_md "# proj

## Cross-Model Review"
out=$(commitpre)
printf '%s' "$out" | grep -q 'CLAUDE.md' && pass "unnumbered heading -> cites the file" || fail "unnumbered heading -> cites the file"
printf '%s' "$out" | grep -q '§' && fail "unnumbered heading must not invent a §" || pass "unnumbered heading invents no §"
rm -f CLAUDE.md; reset_all

# 22c. The reminders must cite rules the reader can actually open. Adopted via the
#      marker alone, there is no CLAUDE.md §5 to point at — citing it anyway is the
#      same misleading noise Finding G is about, just in an adopted project.
reset_all
rm -f CLAUDE.md "$on"; : > "$on"      # marker-only adoption, no CLAUDE.md at all
out=$(commitpre)
printf '%s' "$out" | grep -q 'Codex gate state:' && pass "marker-only: still emits the gate-state reminder" || fail "marker-only: still emits the gate-state reminder"
printf '%s' "$out" | grep -q 'CLAUDE.md' && fail "marker-only must not cite CLAUDE.md" || pass "marker-only: cites no CLAUDE.md"
printf '%s' "$out" | grep -q "this project's review policy" && pass "marker-only: cites the project's policy generically" || fail "marker-only: cites the project's policy generically"
out=$(run '{"hook_event_name":"PreToolUse","tool_name":"Skill","tool_input":{"skill":"superpowers:executing-plans"}}')
printf '%s' "$out" | grep -q 'CLAUDE.md' && fail "marker-only: Gate A must not cite CLAUDE.md" || pass "marker-only: Gate A cites no CLAUDE.md"
# A CLAUDE.md WITH the gate section is cited by name — the concrete pointer is the
# whole value in the common case, so it must survive.
printf '# p\n\n## 5. Cross-Model Review (Codex)\n' > CLAUDE.md
rev; rev; rev
printf '%s' "$(commitpre)" | grep -q 'CLAUDE.md §5' && pass "with §5: reminder cites CLAUDE.md §5 by name" || fail "with §5: reminder cites CLAUDE.md §5 by name"
# .off still wins over adoption (an adopted project can still ask for quiet)
: > "$off"
[ -z "$(commitpre)" ] && pass "off marker beats adoption" || fail "off marker beats adoption"
rm -f "$off"
rm -f CLAUDE.md
: > "$on"   # restore the suite's adopted baseline
git checkout -- . >/dev/null 2>&1
reset_all

# 24. Failure contract: an uncomputable hash must never pass the hook checks, and repeated failures
#     must never match each other. Spec §3 "The nonce goes away".
#     Each fault spans BOTH the stored and the recomputed fingerprint — with the fault
#     applied only at commit time, a mismatch proves nothing about the handling.
stub_dir=$(mktemp -d)
# Snapshot PATH before any stubbing, for the containment guard at the end of this
# section (24f) — a prefix assignment on a SHELL FUNCTION call (rev/commitpre are
# functions, not external commands) persists in the shell after the call returns,
# same defect class as the GIT_INDEX_FILE leak fixed in section 27. Every bare
# (not already inside `$(...)`) `PATH=... rev` below must be run in a subshell.
path_before_24="$PATH"
reset_all
printf '1' > "$floorf"        # floor is checked LAST; without this a faulted run
                              # reports "below floor" and the test passes vacuously

# 24a. every checksum tool fails silently (exit 0, no output)
for t in shasum sha1sum cksum; do
  printf '#!/bin/sh\nexit 0\n' > "$stub_dir/$t"; chmod +x "$stub_dir/$t"
done
( PATH="$stub_dir:$PATH" rev )
out=$(PATH="$stub_dir:$PATH" commitpre)
printf '%s' "$out" | grep -q 'Codex gate state:' && pass "silent checksum -> gate-state reminder" || fail "silent checksum -> gate-state reminder"
# Absence is asserted by inverting the RESULT, not with `grep -v` — `grep -qv` means
# "some line lacks the pattern", which is a different question and was observed to
# return 1 regardless on the dev machine.
printf '%s' "$out" | grep -qF 'no mcp__codex__review has run' \
  && fail "silent checksum -> not the never-run branch" \
  || pass "silent checksum -> not the never-run branch"

# 24b. a checksum that PRINTS a plausible token and then fails
for t in shasum sha1sum cksum; do
  printf '#!/bin/sh\nprintf "deadbeef  -\\n"\nexit 1\n' > "$stub_dir/$t"; chmod +x "$stub_dir/$t"
done
reset_all; printf '1' > "$floorf"
( PATH="$stub_dir:$PATH" rev )
out=$(PATH="$stub_dir:$PATH" commitpre)
printf '%s' "$out" | grep -q 'Codex gate state:' && pass "checksum prints then fails -> gate-state reminder" || fail "checksum prints then fails -> gate-state reminder"
[ "$(cat "$fresh" 2>/dev/null || echo 0)" = 0 ] && pass "unhashable pass leaves freshCount 0" || fail "unhashable pass leaves freshCount 0"

# 24b-bis. GAP 2 — a SECOND consecutive unhashable pass must not be treated as a
# fresh-fingerprint match. Both fingerprints are the literal marker `unavailable`, and
# the guard against that is `[ "$h" != unavailable ] && [ "$h" = "$prev" ]`; a single
# unhashable pass can't distinguish it from the weaker `[ "$h" = "$prev" ]`, because
# `prev` is still empty on the first pass either way. Only a second consecutive
# unhashable pass gives `prev` the value `unavailable`, which is the only case where
# the two conditions disagree.
( PATH="$stub_dir:$PATH" rev )
[ "$(cat "$fresh" 2>/dev/null || echo 0)" = 0 ] && pass "second consecutive unhashable pass still leaves freshCount 0" || fail "second consecutive unhashable pass still leaves freshCount 0"

# 24c. seed-copy failure (stub cp) must fire, not silently hash an empty index
printf '#!/bin/sh\nexit 1\n' > "$stub_dir/cp"; chmod +x "$stub_dir/cp"
rm -f "$stub_dir/shasum" "$stub_dir/sha1sum" "$stub_dir/cksum"
reset_all; printf '1' > "$floorf"
( PATH="$stub_dir:$PATH" rev )
printf '%s' "$(PATH="$stub_dir:$PATH" commitpre)" | grep -q 'Codex gate state:' \
  && pass "seed-copy failure -> gate-state reminder" || fail "seed-copy failure -> gate-state reminder"
rm -f "$stub_dir/cp"

# 24d. a selective git wrapper that fails ONLY `diff`
cat > "$stub_dir/git" <<'STUB'
#!/bin/sh
for a in "$@"; do case "$a" in diff) exit 1 ;; esac; done
exec "$REAL_GIT" "$@"
STUB
chmod +x "$stub_dir/git"
REAL_GIT=$(command -v git); export REAL_GIT
reset_all; printf '1' > "$floorf"
( PATH="$stub_dir:$PATH" rev )
printf '%s' "$(PATH="$stub_dir:$PATH" commitpre)" | grep -q 'Codex gate state:' \
  && pass "git diff failure -> gate-state reminder" || fail "git diff failure -> gate-state reminder"

# 24e. a selective git wrapper that fails ONLY `rev-parse --absolute-git-dir`
cat > "$stub_dir/git" <<'STUB'
#!/bin/sh
case "$*" in *"--absolute-git-dir"*) exit 1 ;; esac
exec "$REAL_GIT" "$@"
STUB
chmod +x "$stub_dir/git"
reset_all; printf '1' > "$floorf"
( PATH="$stub_dir:$PATH" rev )
printf '%s' "$(PATH="$stub_dir:$PATH" commitpre)" | grep -q 'Codex gate state:' \
  && pass "unresolvable git-dir -> gate-state reminder" || fail "unresolvable git-dir -> gate-state reminder"
rm -f "$stub_dir/git"
rm -rf "$stub_dir"   # GAP 3 — stub_dir (mktemp -d) outlives its own guard otherwise
unset REAL_GIT       # GAP 3 — exported at 24d, never unset otherwise
rm -f "$floorf"
reset_all; rev; rev; rev

# 24f. Guard: confirm section 24's PATH containment held, and that REAL_GIT (exported
# at 24d for the selective git wrappers) was unset again. If a future edit
# reintroduces either leak (e.g. drops a subshell above, or a new `export REAL_GIT`
# without matching cleanup), this fails loudly instead of stale state silently
# weakening isolation in every later section — the same "guard the variable you
# happened to remember" gap this section's own comment warns about, closed for both
# variables instead of just PATH.
[ "$PATH" = "$path_before_24" ] && pass "PATH not leaked out of section 24" || fail "PATH not leaked out of section 24"
[ -z "${REAL_GIT+x}" ] && pass "REAL_GIT unset after section 24" || fail "REAL_GIT unset after section 24"
# ...and the stub directory itself. Guarding only the variables was the same partial
# fix again: dropping `rm -rf "$stub_dir"` left every assertion green, so the suite
# could leak a temp dir per run undetected. $work's EXIT trap does not cover it —
# stub_dir is its own mktemp -d outside that tree.
[ ! -d "$stub_dir" ] && pass "stub_dir removed after section 24" || fail "stub_dir removed after section 24"

# 25. Unborn repo: no commits and no .git/index must still hash and self-match, or the
#     first commit in a fresh repo gets the gate-state reminder forever. Spec §3 "But an absent index is not a
#     failed copy".
unborn=$(mktemp -d)
(
  cd "$unborn" || exit 1
  git init -q; git config user.email t@t; git config user.name t
  mkdir -p .context; : > .context/codex-gate.on
  printf '1' > .context/codex-gate.floor      # one pass is enough for this fixture
  printf 'x\n' > a.ts
  R=$(payload mcp__codex__review "$(resp_success)")
  printf '%s' "$R" | "$HOOK_SH_BIN" "$HOOK" >/dev/null
  h1=$(cat .context/codex-gate.gateB 2>/dev/null)
  printf '%s' "$R" | "$HOOK_SH_BIN" "$HOOK" >/dev/null
  h2=$(cat .context/codex-gate.gateB 2>/dev/null)
  [ -n "$h1" ] && [ "$h1" != unavailable ] && [ "$h1" = "$h2" ] || exit 1
  # ...and the FIRST commit must actually be able to reach hook checks passed. Hashing and
  # self-matching is not enough: a consumer-side regression could still remind on every
  # first commit forever, which is the failure this fixture exists to catch.
  out=$(printf '%s' '{"hook_event_name":"PreToolUse","tool_name":"Bash","tool_input":{"command":"git commit --allow-empty -m init"}}' | "$HOOK_SH_BIN" "$HOOK")
  printf '%s' "$out" | grep -q 'Gate B hook checks passed' || exit 1
) && pass "unborn repo hashes, self-matches, and can reach hook checks passed" \
  || fail "unborn repo hashes, self-matches, and can reach hook checks passed"
rm -rf "$unborn"

# 26. THE DEFECT (spec §1): staged content diverging from the worktree.
#     NOTE: the revert is a direct byte write, NOT `git checkout -- app.ts` — checkout
#     restores the worktree FROM THE INDEX, which would install v2 on disk and destroy
#     the divergence, making this test pass against the unfixed hook.
reset_all
rev; rev; rev
printf '%s' "$(commitpre)" | grep -q 'Gate B hook checks passed' && pass "setup: hook checks passed on clean tree" || fail "setup: hook checks passed on clean tree"
printf 'v2\n' > app.ts; git add app.ts >/dev/null 2>&1   # index: v2
printf 'v1\n' > app.ts                                   # worktree: back to HEAD bytes
printf '%s' "$(commitpre)" | grep -q 'Codex gate state:' \
  && pass "staged-vs-worktree divergence -> gate-state reminder" \
  || fail "staged-vs-worktree divergence -> gate-state reminder"
git reset -q >/dev/null 2>&1; git checkout -- app.ts >/dev/null 2>&1

# 27. Ambient alternate index. Three shapes: a negative-only test would be passed by
#     an implementation that fires whenever GIT_INDEX_FILE is set — a permanent gate-state reminder.
alt_dir=$(mktemp -d)
# 27a. divergent: fingerprint recorded WITHOUT the alternate index, alternate enabled
#      only for the commit check.
reset_all; printf '1' > "$floorf"
rev
cp .git/index "$alt_dir/alt"
printf 'SNEAKY\n' > app.ts; GIT_INDEX_FILE="$alt_dir/alt" git add app.ts >/dev/null 2>&1
printf 'v1\n' > app.ts
printf '%s' "$(GIT_INDEX_FILE="$alt_dir/alt" commitpre)" | grep -q 'Codex gate state:' \
  && pass "ambient divergent alternate index -> gate-state reminder" \
  || fail "ambient divergent alternate index -> gate-state reminder"
# 27b. stable: same unchanged alternate index across review AND commit -> hook checks passed,
#      with each index file byte-identical to its OWN pre-hook snapshot.
cp .git/index "$alt_dir/default.before"; cp "$alt_dir/alt" "$alt_dir/alt.before"
reset_all; printf '1' > "$floorf"
# Subshell: a prefix assignment on a SHELL FUNCTION call (rev/commitpre are functions,
# not external commands) persists in the shell after the call returns — unlike the same
# prefix on an external command. Without containment, GIT_INDEX_FILE leaks out of
# section 27 and corrupts every later section's fixtures (notably section 28).
( GIT_INDEX_FILE="$alt_dir/alt" rev )
printf '%s' "$(GIT_INDEX_FILE="$alt_dir/alt" commitpre)" | grep -q 'Gate B hook checks passed' \
  && pass "ambient stable alternate index -> hook checks passed" \
  || fail "ambient stable alternate index -> hook checks passed"
cmp -s .git/index "$alt_dir/default.before" && pass "default index untouched" || fail "default index untouched"
cmp -s "$alt_dir/alt" "$alt_dir/alt.before" && pass "alternate index untouched" || fail "alternate index untouched"
# 27c. missing path: git treats a nonexistent GIT_INDEX_FILE as an EMPTY index, so the
#      hook must hash and self-match rather than returning `unavailable`.
reset_all; printf '1' > "$floorf"
( GIT_INDEX_FILE="$alt_dir/does-not-exist" rev )
h1=$(cat "$state" 2>/dev/null)
( GIT_INDEX_FILE="$alt_dir/does-not-exist" rev )
h2=$(cat "$state" 2>/dev/null)
{ [ -n "$h1" ] && [ "$h1" != unavailable ] && [ "$h1" = "$h2" ]; } \
  && pass "missing alternate index hashes and self-matches" \
  || fail "missing alternate index hashes and self-matches"
rm -rf "$alt_dir"; rm -f "$floorf"
git checkout -- app.ts >/dev/null 2>&1; git reset -q >/dev/null 2>&1
reset_all; rev; rev; rev

# 27d. Guard: confirm section 27's containment held. If a future edit reintroduces the
# leak (e.g. drops a subshell above), this fails loudly instead of section 28 quietly
# going vacuous against a stale, since-deleted GIT_INDEX_FILE path.
[ -z "${GIT_INDEX_FILE+x}" ] && pass "GIT_INDEX_FILE not leaked out of section 27" || fail "GIT_INDEX_FILE not leaked out of section 27"

# 27e. FINDING 1 — a RELATIVE ambient GIT_INDEX_FILE must resolve against the
#      repository TOP-LEVEL, exactly as git itself does — not against the hook's own
#      cwd. The shell-side `[ ! -e ]` test and `cp` are plain shell commands (unlike
#      every git call in the hook, which uses `-C "$repo_root"`), so an unnormalized
#      relative path resolves differently depending on where the hook happens to run
#      from. Run BOTH the review pass and the commit check from a SUBDIRECTORY with a
#      relative alt index that actually lives at the repo root: an unnormalized hook
#      can't find it either time, takes the same absent-index carve-out both times, and
#      the two constant empty-tree hashes MATCH — a false "hook checks passed" even though the
#      alt index stages content the worktree does not have.
#      The alt index file lives under `.context/` — excluded from the diff-HEAD and
#      worktree-tree components by their own `:(exclude).context` pathspec — so it is
#      never picked up as an untracked file by `add -A` itself; the only way it can
#      affect the hash is through eff_index resolution, which is exactly what this
#      test needs to isolate.
reset_all; printf '1' > "$floorf"
mkdir -p sub
cp .git/index "$work/.context/rel-idx"          # a copy of the CURRENT (matching) index
( cd sub && GIT_INDEX_FILE=.context/rel-idx rev )   # review, from a subdir, relative alt index
printf 'SNEAKY\n' > app.ts
GIT_INDEX_FILE="$work/.context/rel-idx" git add app.ts >/dev/null 2>&1   # stage into the ALT index only
printf 'v1\n' > app.ts                          # worktree stays at the reviewed bytes
out=$(cd sub && GIT_INDEX_FILE=.context/rel-idx commitpre)
printf '%s' "$out" | grep -q 'Codex gate state:' \
  && pass "relative ambient GIT_INDEX_FILE from a subdirectory -> gate-state reminder (Finding 1)" \
  || fail "relative ambient GIT_INDEX_FILE from a subdirectory -> gate-state reminder (Finding 1)"
rm -f "$work/.context/rel-idx"; rm -rf sub
git checkout -- app.ts >/dev/null 2>&1; git reset -q >/dev/null 2>&1
reset_all; rev; rev; rev

# 28. Tracked .context/ diverging THREE ways (index differs from both HEAD and worktree)
#     is exactly the state where `git rm --cached` refuses without -f, silently (stderr
#     is redirected). The hash must still be computable and self-match, and the user's
#     real index must be untouched — the forced removal runs on the throwaway index only.
git add -f .context >/dev/null 2>&1; git commit -qm "track .context" >/dev/null 2>&1
printf 'staged\n' > .context/codex-gate.on; git add .context/codex-gate.on >/dev/null 2>&1
printf 'worktree\n' > .context/codex-gate.on
before_tree=$(git write-tree 2>/dev/null)
before_blob=$(git rev-parse :.context/codex-gate.on 2>/dev/null)
# Compare the index's ENTRIES, not its bytes. An earlier version of this test ran
# `cmp` on .git/index and passed on macOS while failing on Linux CI: git rewrites the
# index's stat cache during ordinary read-only operations, and the hook runs
# `git diff HEAD`, so byte-identity is a property the hook neither guarantees nor
# claims. `ls-files --stage` covers mode, object id, stage and path for EVERY entry,
# which is the property actually asserted — the hook must not change what the user's
# index means — and it is immune to benign stat-cache rewrites.
before_stage=$(git ls-files --stage 2>/dev/null)
reset_all
rev; h1=$(cat "$state" 2>/dev/null)
rev; h2=$(cat "$state" 2>/dev/null)
{ [ -n "$h1" ] && [ "$h1" != unavailable ] && [ "$h1" = "$h2" ]; } \
  && pass "three-way .context divergence hashes and self-matches" \
  || fail "three-way .context divergence hashes and self-matches"
[ "$(git write-tree 2>/dev/null)" = "$before_tree" ] && pass "real index tree unchanged" || fail "real index tree unchanged"
[ "$(git rev-parse :.context/codex-gate.on 2>/dev/null)" = "$before_blob" ] && pass "staged .context blob unchanged" || fail "staged .context blob unchanged"
[ "$(git ls-files --stage 2>/dev/null)" = "$before_stage" ] \
  && pass "real index entries unchanged" || fail "real index entries unchanged"
: > .context/codex-gate.on
git rm -rq --cached .context >/dev/null 2>&1; git commit -qm "untrack .context" >/dev/null 2>&1
reset_all; rev; rev; rev

# 29. Message contracts (spec §4). These are shipped prompts — the product itself, not
#     incidental output — so each branch's COMPLETE additionalContext and systemMessage
#     is pinned as a golden fixture and compared EXACTLY, replacing the old per-clause
#     greps: a clause list only catches a regression someone thought to enumerate
#     (inserting "do not " before an asserted clause, or "Usually" -> "Always", stayed
#     green under it); an exact comparison catches any wording change. $passes, $floor
#     and $fresh are pinned by the setup immediately before each assertion, so every
#     fixture below is deterministic.
json_field() { # $1 = json text, $2 = key -> prints the string value. No jq required —
                # same fallback idiom as the hook's own field(): safe here because none
                # of the three golden messages below contain a literal backslash or quote.
  printf '%s' "$1" | grep -o "\"$2\"[[:space:]]*:[[:space:]]*\"[^\"]*\"" | head -n1 | sed 's/^.*:[[:space:]]*"\(.*\)"$/\1/'
}

# 29a. STALE branch: 1 recorded pass this cycle, default floor 3, no CLAUDE.md (so the
#      generic policy phrase), a change made through the Edit tool.
# A `rev` baseline is required before the edit: without one, `reviewed` is empty and
# the edit below lands in the EMPTY-STATE branch, not the STALE branch this fixture
# describes (matches the existing pattern in section 3a).
reset_all; rev
printf 'edit\n' >> app.ts
run '{"hook_event_name":"PostToolUse","tool_name":"Edit","tool_input":{"file_path":"app.ts"}}' >/dev/null
out=$(commitpre)
ctx=$(json_field "$out" additionalContext)
msg=$(json_field "$out" systemMessage)
expected_ctx="Codex gate state: the hook cannot confirm that the content you are about to commit is the content mcp__codex__review last saw (1 recorded pass(es) this cycle). Usually that means the working tree or the index changed since the review. It can also mean you only staged already-reviewed content — the bytes are fine, but the hook cannot tell staging from editing; that this hook was upgraded and the recorded fingerprint uses the older format (see CHANGELOG); or that the fresh fingerprint could not be computed or could not be stored. A fresh Gate-B pass is the complete remedy for the staging and post-upgrade cases too, and when this cycle may run one is this project's review policy's closure ordering's, read there entire. If a fresh pass leaves this unchanged, check the worktree and the index first — the fingerprint moves when either does, staging included, and another hook can stage during the commit attempt. Where neither changed, the fault is in the machinery rather than the code: check that .context/ is writable, that TMPDIR is writable, that a checksum tool (shasum, sha1sum or cksum) runs, that git status works, and that the disk is not full — a store that fails again leaves the hook unable to confirm a fingerprint and may return either fingerprint-state diagnosis. Per this project's review policy you MUST re-review after every fix."
expected_msg="⚠ Codex Gate B: cannot confirm reviewed content"
[ "$ctx" = "$expected_ctx" ] && pass "stale additionalContext matches exactly" || fail "stale additionalContext matches exactly"
[ "$msg" = "$expected_msg" ] && pass "stale systemMessage matches exactly" || fail "stale systemMessage matches exactly"
git checkout -- app.ts >/dev/null 2>&1

# 29b. HOOK-CHECKS-PASSED branch: 3/3 passes this cycle, all 3 fresh (unchanged tree). The hook
#      fingerprints disk; mcp__codex__review reads a git range (spec §7) — the exact
#      fixture below is what pins that the message never claims Codex read the bytes.
reset_all; rev; rev; rev
out=$(commitpre)
ctx=$(json_field "$out" additionalContext)
msg=$(json_field "$out" systemMessage)
expected_ctx="Codex Gate B: 3/3 pass(es) this cycle, of which 3 cover the CURRENT content fingerprint (unchanged since that review). The floor counts the cycle; only the fresh pass(es) carry the same fingerprint as what you are committing. Per this project's review policy, commit only if your final pass was clean and every other closure condition holds, both as it defines them."
expected_msg="✓ Codex Gate B hook checks passed (3/3 cycle, 3 on current fingerprint)"
[ "$ctx" = "$expected_ctx" ] && pass "hook-checks-passed additionalContext matches exactly" || fail "hook-checks-passed additionalContext matches exactly"
[ "$msg" = "$expected_msg" ] && pass "hook-checks-passed systemMessage matches exactly" || fail "hook-checks-passed systemMessage matches exactly"

# 29c. EMPTY-STATE branch: no fingerprint recorded this cycle, default floor 3.
reset_all
out=$(commitpre)
ctx=$(json_field "$out" additionalContext)
msg=$(json_field "$out" systemMessage)
expected_ctx="Codex gate state: no fingerprint is recorded for this cycle. The hook cannot tell why — no mcp__codex__review has run, the last one's fingerprint could not be written or read back, or a non-WIP commit attempt cleared it while the cycle itself stayed open. What this cycle does next, the floor it owes included, is this project's review policy's closure ordering's, read there entire, and this reminder decides none of it. If this repeats, check that .context/ and the state file inside it are readable and writable; if the file exists but is unreadable or empty, delete it — which restores no passes, and lets the next pass the ordering permits record a fingerprint."
expected_msg="⚠ Codex Gate B: no recorded fingerprint"
[ "$ctx" = "$expected_ctx" ] && pass "empty-state additionalContext matches exactly" || fail "empty-state additionalContext matches exactly"
[ "$msg" = "$expected_msg" ] && pass "empty-state systemMessage matches exactly" || fail "empty-state systemMessage matches exactly"
reset_all; rev; rev; rev

# 30. UNSTORABLE STATE (spec §5 test 11). Cause 5 lives OUTSIDE tree_hash: the store path
#     writes with `2>/dev/null || true` because the hook must always exit 0, so a pass can
#     hash perfectly and still leave the old fingerprint behind. Three shapes, because
#     they reach the branch by different routes.
#     Each shape depends on chmod actually DENYING access, which is false under an
#     effective root uid — a root-run CI job would take the success path and then fail the
#     assertion, reporting a product defect that is really a privilege artefact. Probe the
#     exact operation each shape needs, restore what the probe changed, and skip loudly.
probe_denies() {   # $1 = probe command; returns 0 when the operation was DENIED
  ( eval "$1" ) >/dev/null 2>&1 && return 1 || return 0
}
skip() { printf 'skip - %s\n' "$1"; }

# 30a. replacement fails: the state file itself is read-only
reset_all; rev
before=$(cat "$state")
chmod 0444 "$state" 2>/dev/null
if probe_denies "printf x >> \"$state\""; then
  printf 'later edit\n' >> app.ts
  rev                                   # hashes fine, but cannot replace the fingerprint
  [ "$(cat "$state")" = "$before" ] && pass "unwritable state file keeps the old fingerprint" || fail "unwritable state file keeps the old fingerprint"
  printf '%s' "$(commitpre)" | grep -q 'cannot confirm' \
    && pass "stale fingerprint after a failed store -> cannot confirm" \
    || fail "stale fingerprint after a failed store -> cannot confirm"
else
  skip "unwritable state file (chmod does not deny writes here — running as root?)"
fi
chmod 0644 "$state" 2>/dev/null
git checkout -- app.ts >/dev/null 2>&1

# 30b. first write fails: no prior state, and the directory refuses a new file
reset_all
chmod 0555 .context 2>/dev/null
if probe_denies "touch .context/probe-$$"; then
  rev                                   # cannot create the state file at all
  out=$(commitpre)
  printf '%s' "$out" | grep -qF 'no fingerprint is recorded' \
    && pass "unwritable .context -> empty-state branch" || fail "unwritable .context -> empty-state branch"
  printf '%s' "$out" | grep -qF 'could not be written or read back' \
    && pass "empty-state branch admits a failed first write" || fail "empty-state branch admits a failed first write"
else
  skip "unwritable .context directory (chmod does not deny creation here — running as root?)"
fi
chmod 0755 .context 2>/dev/null; rm -f ".context/probe-$$"

# 30c. read fails: the state file exists and is non-empty but cannot be read
reset_all; rev
chmod 0000 "$state" 2>/dev/null
if probe_denies "cat \"$state\""; then
  out=$(commitpre)
  printf '%s' "$out" | grep -qF 'no fingerprint is recorded' \
    && pass "unreadable state file -> empty-state branch" || fail "unreadable state file -> empty-state branch"
  # invariant 1: advisory hook, always exit 0, even when its own state is unreadable.
  # Checked with `if`, not `[ $? -eq 0 ]` — the latter is SC2181 and the test file
  # excludes only SC2015, so it would fail lint.
  if run '{"hook_event_name":"PreToolUse","tool_name":"Bash","tool_input":{"command":"git commit -m x"}}' >/dev/null 2>&1; then
    pass "unreadable state file -> hook still exits 0"
  else
    fail "unreadable state file -> hook still exits 0"
  fi
else
  skip "unreadable state file (chmod does not deny reads here — running as root?)"
fi
chmod 0644 "$state" 2>/dev/null
reset_all; rev; rev; rev

# 33. emit REPORTS WHETHER IT ACTUALLY WROTE (spec §6).
#     Marker-writing is conditional on "a complete hook JSON document was written", so a
#     caller that dedupes a one-time note must be able to tell a real write from a failed
#     one. Every assertion below is driven through the UNKNOWN-TOOL note, because it is
#     the one branch that both emits and burns a one-shot marker: a review PostToolUse
#     emits nothing, so closing stdout on it exercises no writer at all and both outcomes
#     would hold before this change.
reset_all
run_closed "$(payload mcp__codex__codex "$(resp_success)")"; rc=$?
[ "$rc" = 0 ] && pass "hook exits 0 with stdout closed" || fail "hook exits 0 with stdout closed (got $rc)"
[ ! -f "$notedf" ] && pass "a failed write does not burn the one-shot" || fail "a failed write does not burn the one-shot"

reset_all
nojq_run_closed "$(payload mcp__codex__codex "$(resp_success)")"; rc=$?
[ "$rc" = 0 ] && pass "jq-free: hook exits 0 with stdout closed" || fail "jq-free: hook exits 0 with stdout closed (got $rc)"
[ ! -f "$notedf" ] && pass "jq-free: failed write does not burn the one-shot" || fail "jq-free: failed write does not burn the one-shot"

# The SELECTIVE sed shim. Removing sed outright breaks field()'s jq-free routing, so the
# hook would never reach emit and an encoder-failure test would pass for an unrelated
# reason. This one fails only a sed whose script carries the encoder's own substitution.
sedfail=$(mk_sedfail_path)
if [ -n "$sedfail" ] &&
   [ "$(printf 'x\n' | PATH="$sedfail" sed 's/x/y/' 2>/dev/null)" = y ] &&
   ! printf 'x\n' | PATH="$sedfail" sed 's/\\/\\\\/g; s/"/\\"/g' >/dev/null 2>&1
then
  # Both directions verified: ordinary substitutions still work, the encoder's fails.
  reset_all
  out=$(printf '%s' "$(payload mcp__codex__codex "$(resp_success)")" | PATH="$sedfail" "$HOOK_SH_BIN" "$HOOK" 2>/dev/null); rc=$?
  [ "$rc" = 0 ] && pass "encoder failure exits 0" || fail "encoder failure exits 0 (got $rc)"
  [ -z "$out" ] && pass "encoder failure prints nothing" || fail "encoder failure prints nothing (got [$out])"
  [ ! -f "$notedf" ] && pass "encoder failure burns nothing" || fail "encoder failure burns nothing"
else
  # The dependent assertions are skipped WITH the shim, not left to run against a
  # working sed and report three green rows that tested nothing.
  skip "selective sed shim unavailable — encoder-failure assertions not run"
fi
reset_all

# 34. ONE INVOCATION WRITES ONE DOCUMENT (spec §6, A6/A7).
#     Output is buffered and written once at the end, so every emitting branch must still
#     produce EXACTLY one document — `= 1`, never `-le 1`, because `-le 1` passes a
#     dropped message, which is the failure this whole section exists to catch. One
#     document per line, so counting lines carrying the envelope key counts documents.
ndocs() { printf '%s' "$1" | grep -c 'hookSpecificOutput'; }
one_doc() { # $1 = label, $2 = captured output
  n=$(ndocs "$2")
  [ "$n" = 1 ] && pass "$1 emits exactly one document" || fail "$1 emits exactly one document (got $n)"
}

git checkout -- app.ts >/dev/null 2>&1
git reset -q >/dev/null 2>&1
rm -f brand-new.ts NOTES.md; rm -rf docs
reset_all

# 1/9 unknown Codex tool
one_doc "unknown-tool note" "$(codextool mcp__codex__codex)"
# 2/9 WIP commit
reset_all
one_doc "WIP commit" "$(run '{"hook_event_name":"PreToolUse","tool_name":"Bash","tool_input":{"command":"git commit -m \"wip: snapshot\""}}')"
# 3/9 docs-only commit
reset_all
mkdir -p docs && printf 'spec\n' > docs/plan.md && git add docs/plan.md >/dev/null 2>&1
one_doc "docs-only commit" "$(commitpre)"
git reset -q >/dev/null 2>&1; rm -rf docs
# 4/9 no fingerprint recorded
reset_all
one_doc "no recorded fingerprint" "$(commitpre)"
# 5/9 stale fingerprint
reset_all; rev
printf 'churn\n' >> app.ts
one_doc "stale fingerprint" "$(commitpre)"
git checkout -- app.ts >/dev/null 2>&1
# 6/9 below the Gate-B floor
reset_all; rev
one_doc "Gate B below floor" "$(commitpre)"
# 7/9 Gate B hook checks passed
reset_all; rev; rev; rev
one_doc "Gate B hook checks passed" "$(commitpre)"
# 8/9 Gate A below floor
reset_all
one_doc "Gate A below floor" "$(run '{"hook_event_name":"PreToolUse","tool_name":"Skill","tool_input":{"skill":"superpowers:executing-plans"}}')"
# 9/9 Gate A floor met
reset_all; execp; execp; execp
one_doc "Gate A floor met" "$(run '{"hook_event_name":"PreToolUse","tool_name":"Skill","tool_input":{"skill":"superpowers:executing-plans"}}')"

# A SILENT event must stay silent. It has to be an event the hook ACTUALLY RECEIVES:
# hooks.json registers PostToolUse as ^(Bash|Skill|mcp__codex__.*)$, so a PostToolUse for
# Edit never arrives in production and a flush test built on it would prove nothing about
# a reachable invocation. A non-commit Bash PostToolUse is reachable and emits nothing.
reset_all
out=$(run '{"hook_event_name":"PostToolUse","tool_name":"Bash","tool_input":{"command":"ls -la"}}')
[ -z "$out" ] && pass "a silent event emits nothing" || fail "a silent event emits nothing (got [$out])"

# 35. INVARIANT 1 AT THE MARKER WRITE. `: > f` is a POSIX SPECIAL BUILTIN: a redirection
#     failure on one makes the shell EXIT, ignoring the enclosing `{ … } 2>/dev/null ||
#     true` and even an `if`. With a DIRECTORY at the target the `:` form exits 2 under
#     dash — and Ubuntu's /bin/sh IS dash, which is what CI runs. macOS sh does not expose
#     it, which is why the existing regression test stood while the defect shipped.
reset_all
mkdir -p "$notedf"
codextool mcp__codex__codex >/dev/null 2>&1; rc=$?
[ "$rc" = 0 ] && pass "exits 0 with a directory at the marker path" || fail "exits 0 with a directory at the marker path (got $rc)"
if command -v dash >/dev/null 2>&1; then
  printf '%s' "$(payload mcp__codex__codex "$(resp_success)")" | dash "$HOOK" >/dev/null 2>&1; rc=$?
  [ "$rc" = 0 ] && pass "dash: exits 0 with a directory at the marker path" || fail "dash: exits 0 with a directory at the marker path (got $rc)"
else
  skip "dash unavailable — the special-builtin assertion did not run"
fi
rmdir "$notedf" 2>/dev/null
reset_all

# =====================================================================================
# 36-41. GATE-PASS RESULT CLASSIFICATION (0.8.0).
# =====================================================================================
# $nojq is the shared PATH from the top of this file; section 9 no longer reassigns it.
# Re-assert section 0's contract HERE anyway, immediately before the rows that depend on
# it: a PATH nobody re-checks at its point of use is how the earlier reassignment went
# unnoticed — every jq-free fingerprint row took the `unavailable` branch while its label
# claimed a jq/jq-free comparison, and each row still passed.
reset_all
nojq_run "$(payload mcp__codex__review "$(resp_success)")" >/dev/null
h_nojq=$(cat "$state" 2>/dev/null || echo '')
nojq_run "$(payload mcp__codex__review "$(resp_success)")" >/dev/null
case "$h_nojq" in
  '' | unavailable) fail "jq-free PATH at point of use records a usable fingerprint (got [$h_nojq])" ;;
  *) [ "$(cat "$fresh" 2>/dev/null)" = 2 ] \
       && pass "jq-free PATH at point of use records a usable, self-matching fingerprint" \
       || fail "jq-free PATH at point of use records a usable, self-matching fingerprint" ;;
esac
reset_all

# --- classification helpers ---------------------------------------------------------
# The corpus is driven through the EXEC tool: it routes identically and skips tree_hash,
# which the classification rows do not test and which dominates the runtime.
cpay() { # $1 = the tool_response VALUE -> a routable gate payload
  printf '{"hook_event_name":"PostToolUse","tool_name":"mcp__codex__exec","tool_input":{},"tool_response":%s}' "$1"
}
ctext() { cpay "[{\"type\":\"text\",\"text\":\"$1\"}]"; }   # $1 = ESCAPED text bytes

# One invocation's class from THAT invocation's own effects: an exact message substring
# AND the pass-state effect. The substring alone would let a discarded class that still
# counted read as correctly discarded, which is the false ✓ direction. No cross-test
# global state: every call resets first.
class_of() { # $1 = a full hook payload
  reset_all
  _o=$(run "$1")
  _n=$(( $(cat "$count" 2>/dev/null || printf 0) + $(cat "$countA" 2>/dev/null || printf 0) ))
  case "$_o" in
    *'this Codex call returned an envelope reporting failure'*) _k=failure ;;
    *'carried no result text the hook could read'*) _k=no-result ;;
    *'moved to the background at the auto-background threshold'* \
      | *'was backgrounded and its result never reached the hook'*) _k=backgrounded ;;
    *'classified at least one gate call as countable'*) _k=unrecognized ;;
    '') _k=success ;;
    *) _k=other ;;
  esac
  case "$_k" in
    success | unrecognized) [ "$_n" = 1 ] || _k="$_k+notcounted" ;;
    failure | no-result | backgrounded) [ "$_n" = 0 ] || _k="$_k+counted" ;;
  esac
  printf '%s' "$_k"
}
cls_is() { # $1 = label, $2 = got, $3 = want
  [ "$2" = "$3" ] && pass "class: $1" || fail "class: $1 (got [$2], want [$3])"
}
cls_text() { cls_is "$1" "$(class_of "$(ctext "$2")")" "$3"; }
cls_resp() { cls_is "$1" "$(class_of "$(cpay "$2")")" "$3"; }
cls_pay()  { cls_is "$1" "$(class_of "$2")" "$3"; }

# 36. THE CLASSIFICATION CORPUS, ported label-by-label from the verified drafts
#     (.context/plan-drafts/verify.sh, 53 call sites / 56 assertions). Every row whose
#     document is VALID JSON runs end-to-end through the hook; the rows whose OUTER
#     document is malformed run at LOCATOR level in section 36b, because their
#     routability — not their classification — differs between the jq and grep paths,
#     which is not the classifier doing anything.

# 36a/1-4. the four real captures, as whole payloads retargeted onto a gate tool.
for pair in shape0-success:success shape1-fast-fail:failure \
            shape2-executor-timeout:failure shape3-backgrounding-notice:backgrounded; do
  f=${pair%%:*}; want=${pair##*:}
  cls_pay "fixture $f" "$(payload_from "$f" mcp__codex__exec)" "$want"
done
# ...and the review-tool capture, which must NOT reach the fail-open terminal class.
# Count and fingerprint alone cannot see that: assert the class.
cls_pay "fixture shape0-success-review" "$(payload_from shape0-success-review mcp__codex__exec)" success

# 36a/5-11. polarity grammar (A3): the whitespace points, and the glued token.
cls_text "compact"            '{\"success\":true}' success
cls_text "tab around colon"   '{\t\"success\"\t:\ttrue}' success
cls_text "CRLF after brace"   '{\r\n\"success\": false}' failure
cls_text "space before colon" '{ \"success\" : true}' success
cls_text "reordered envelope" '{\"status\": \"error\", \"success\": false}' unrecognized
cls_text "glued token truely" '{\"success\": truely}' unrecognized
ws70=$(i=0; while [ $i -lt 70 ]; do printf ' '; i=$((i + 1)); done)
cls_text "whitespace past 64 after the brace" "{$ws70\\\"success\\\": true}" unrecognized
# P9-3: one bound row per remaining strip_ws site, not only the one after `{`.
cls_text "whitespace past 64 after the key"   "{\\\"success\\\"$ws70: true}" unrecognized
cls_text "whitespace past 64 after the colon" "{\\\"success\\\":${ws70}true}" unrecognized
cls_text "whitespace past 64 after the value" "{\\\"success\\\": true$ws70}" unrecognized

# 36a/12-13. collisions: a summary quoting the marker literals. The FAILURE direction is
# where a mistake produces the false ✓, so both directions are pinned — synthetically
# here, and through the shipped collision fixtures immediately after.
cls_text "success quotes both" '{\"success\": true, \"summary\": \"x \\\"success\\\": false\"}' success
cls_text "failure quotes true" '{\"success\": false, \"summary\": \"x \\\"success\\\": true\"}' failure
cls_pay "fixture collision-success-quotes-both" \
  "$(payload_from collision-success-quotes-both mcp__codex__exec)" success
cls_pay "fixture collision-failure-quotes-true" \
  "$(payload_from collision-failure-quotes-true mcp__codex__exec)" failure

# 36a/14-19. the backgrounding anchor (A4) and its four near-misses.
cls_text "notice, exec"   'MCP tool \"codex/exec\" is still running after 120s (task abc)' backgrounded
cls_text "notice, mapped" 'MCP tool \"other/thing\" is still running after 5m' backgrounded
cls_text "notice quoted in an envelope" \
  '{\"success\": false, \"summary\": \"MCP tool \\\"codex/exec\\\" is still running after 120s\"}' failure
cls_text "prefix without the segment" 'MCP tool \"codex/exec\" finished' unrecognized
cls_text "segment after a newline"    'MCP tool \"codex/exec\"\n is still running after 120s' unrecognized
cls_text "phrase later in the text"   'The gate is still running after the fix' unrecognized

# 36a/20-28. every no-result shape (spec §3.3) — none of them may count.
cls_pay "absent tool_response" \
  '{"hook_event_name":"PostToolUse","tool_name":"mcp__codex__exec","tool_input":{}}' no-result
cls_resp "null tool_response"    'null' no-result
cls_resp "empty array"           '[]' no-result
cls_resp "non-array container"   '{"type":"text","text":"x"}' no-result
cls_resp "no text-type element"  '[{"type":"image","data":"x"}]' no-result
cls_resp "text not a string"     '[{"type":"text","text":123}]' no-result
cls_text "empty text"            '' no-result
cls_text "blank escaped ws"      '  \n\t ' no-result
cls_text "unicode-escaped space" '\u0020' unrecognized

# 36a/29-31. locating: decoys in both directions, and block selection.
cls_pay "tool_input decoy quotes the key BEFORE the real field" \
  '{"hook_event_name":"PostToolUse","tool_name":"mcp__codex__exec","tool_input":{"instruction":"see \"tool_response\" docs"},"tool_response":[{"type":"text","text":"{\"success\": true}"}]}' \
  success
cls_resp "non-object element skipped" '["x",{"type":"text","text":"{\"success\": true}"}]' success
# BLOCK SELECTION: an `element [0]` implementation passes every no-result and capture row
# while violating spec §3.1's settled first-`text`-element rule. This row is what fails.
cls_resp "non-text block skipped, classified from the text block" \
  '[{"type":"image","data":"x"},{"type":"text","text":"{\"success\": false}"}]' failure

# 36a/32-33. duplicate depth-1 keys — last-wins would classify an ambiguous payload.
cls_pay "duplicate depth-1 key" \
  '{"hook_event_name":"PostToolUse","tool_name":"mcp__codex__exec","tool_response":[{"type":"text","text":"{\"success\": true}"}],"tool_response":[{"type":"text","text":"{\"success\": false}"}]}' \
  unrecognized
cls_pay "duplicate depth-1 key, reversed" \
  '{"hook_event_name":"PostToolUse","tool_name":"mcp__codex__exec","tool_response":[{"type":"text","text":"{\"success\": false}"}],"tool_response":[{"type":"text","text":"{\"success\": true}"}]}' \
  unrecognized

# 36a/34-37. duplicate classification-relevant members. The PRECEDING-element rows pin a
# refusal stricter than the first-text-element rule requires: without them the generic
# duplicate rows are all satisfied by selected-element duplicates and the stricter
# behaviour could regress with every named check still green. P9-5 adds the `text`
# counterpart to the `type` one the drafts carried.
cls_resp "duplicate text member" \
  '[{"type":"text","text":"{\"success\": false}","text":"{\"success\": true}"}]' unrecognized
cls_resp "duplicate type member" \
  '[{"type":"image","type":"text","text":"{\"success\": true}"}]' unrecognized
cls_resp "duplicate type in a PRECEDING non-text element" \
  '[{"type":"image","type":"image"},{"type":"text","text":"{\"success\": true}"}]' unrecognized
cls_resp "duplicate text in a PRECEDING non-text element" \
  '[{"type":"image","text":"a","text":"b"},{"type":"text","text":"{\"success\": true}"}]' unrecognized

# 36a/38-39. ordinary nesting is unaffected, and a later mention of the key does not
# return a byte-position heuristic to life.
shallow=$(awk 'BEGIN{s="";for(i=0;i<8;i++)s=s "[";for(i=0;i<8;i++)s=s "]";print s}')
cls_pay "ordinary nesting is unaffected" \
  "{\"hook_event_name\":\"PostToolUse\",\"tool_name\":\"mcp__codex__exec\",\"junk\":$shallow,\"tool_response\":[{\"type\":\"text\",\"text\":\"{\\\"success\\\": true}\"}]}" \
  success
cls_resp "response quotes the key AFTER the real field" \
  '[{"type":"text","text":"{\"success\": true} plus a later mention of \\\"tool_response\\\""}]' success

# 36a/40. the key SPELLED with Unicode escapes, six bytes each. The locator must SUCCEED
# and the matcher must refuse — an earlier draft supplied raw quotes, which made the outer
# payload malformed and reached `unrecognized` from the locator instead.
cls_text "unicode-escaped marker key" '{\u0022success\u0022: true}' unrecognized

# 36a/40b. P9-6, CHARACTERIZED rather than fixed — this row exists so the boundary is a
# tested fact instead of an unexamined assumption. The `type` VALUE is compared as raw
# bytes, so a Unicode-escaped spelling of `text` — semantically `text`, and valid JSON a
# conforming serializer may emit — is not recognized as a text element. With no other
# element the locator reports "nothing there" and the class is `no-result`: fail-CLOSED,
# so a real result is discarded rather than miscounted, which is the safe direction but
# is still a wrong verdict on a legal payload. Spec 3.1's "first text element" is a
# SEMANTIC contract while this is a byte comparison; the gap is stated in the spec and
# carried in todos.md with a trigger. If the comparison is ever made semantic, this is
# the row that must change — deliberately, not by accident.
cls_pay "P9-6 escaped type value reads as no-result" \
  "$(payload mcp__codex__exec '[{"type":"\u0074ext","text":"{\"success\": true}"}]')" no-result

# 36a/41-42. the length ceiling, and a pretty-printed payload.
big=$(awk 'BEGIN{s="";while(length(s)<1100000)s=s "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa";print s}')
cls_pay "payload past the ceiling" \
  "{\"hook_event_name\":\"PostToolUse\",\"tool_name\":\"mcp__codex__exec\",\"pad\":\"$big\",\"tool_response\":[{\"type\":\"text\",\"text\":\"{\\\"success\\\": true}\"}]}" \
  unrecognized
unset big
cls_pay "pretty-printed payload" '{
  "hook_event_name": "PostToolUse",
  "tool_name": "mcp__codex__exec",
  "tool_response": [
    { "type": "text", "text": "{\"success\": true}" }
  ]
}' success

# 36b. LOCATOR-LEVEL ROWS. Every remaining draft row has a MALFORMED OUTER document, so
#      whether the hook routes it at all depends on jq (jq refuses, the grep fallback
#      reads a tool name anyway) — two different behaviours in two environments, neither
#      of them the classifier deciding anything. Their claim is about the locator, so they
#      are asserted at that level, against the hook's OWN embedded program rather than a
#      copy that could drift.
extract_locate_awk() { sed -n "/^LOCATE_AWK='\$/,/^'\$/p" "$HOOK" | sed '1d;$d'; }
LOCATE_PROG=$(extract_locate_awk)
loc_verdict() { # $1 = a raw document -> located:<bytes> | nothing | refused
  _b=$(printf '%s' "$1" | awk "$LOCATE_PROG" 2>/dev/null); _r=$?
  case "$_r" in
    0) printf 'located:%s' "$_b" ;;
    1) printf 'nothing' ;;
    *) printf 'refused' ;;
  esac
}
loc_is() { [ "$2" = "$3" ] && pass "locator: $1" || fail "locator: $1 (got [$2], want [$3])"; }
E_OK='{\"success\": true}'
# The extraction is self-verified in both directions before anything depends on it: a
# known-good document must locate its known bytes, and a known-refusable one must refuse.
#
# Every document below is built into `p` on its OWN LINE first. Writing
# `"$(loc_verdict "{\"a\":…}")"` inline does NOT survive the nesting — the outer quotes
# close early and the verdict is computed over the wrong bytes, which is exactly how the
# self-verification below first reported a working extraction as unusable, skipping all
# fifteen rows while every one of them would have passed.
EL="{\"type\":\"text\",\"text\":\"$E_OK\"}"
p="{\"tool_response\":[$EL]}"
sv1=$(loc_verdict "$p")
sv2=$(loc_verdict 'nonsense')
if [ -n "$LOCATE_PROG" ] && [ "$sv1" = "located:$E_OK" ] && [ "$sv2" = refused ]; then
  loc_is "not an object" "$(loc_verdict '[1,2]')" refused
  p="{\"tool_response\":[$EL"
  loc_is "truncated array" "$(loc_verdict "$p")" refused
  p="{\"tool_response\":[{\"type\":\"text\",\"text\":\"$E_OK\""
  loc_is "truncated element" "$(loc_verdict "$p")" refused
  p="{\"junk\":[1,2},\"tool_response\":[$EL]}"
  loc_is "mismatched container before the field" "$(loc_verdict "$p")" refused
  p="{\"tool_response\":[{\"type\":\"text\",\"text\":\"$E_OK\",\"m\":[1}}]}"
  loc_is "mismatched container inside the array" "$(loc_verdict "$p")" refused
  p="{\"tool_response\":[$EL]}junk"
  loc_is "trailing garbage after the object" "$(loc_verdict "$p")" refused
  p="{\"tool_response\":[{\"type\":\"text\",,\"text\":\"$E_OK\"}]}"
  loc_is "stray comma between members" "$(loc_verdict "$p")" refused
  p="{\"tool_response\":[,$EL]}"
  loc_is "malformation BEFORE the selected element refuses" "$(loc_verdict "$p")" refused
  p="{\"junk\":tru,\"tool_response\":[$EL]}"
  loc_is "bare primitive token" "$(loc_verdict "$p")" refused
  p="{\"junk\":\"oops,\"tool_response\":[$EL]}"
  loc_is "unterminated string before the field" "$(loc_verdict "$p")" refused
  # The array is walked only as far as the selected element, so malformation AFTER it
  # cannot change which bytes were located. Stated as behaviour rather than argued.
  p="{\"tool_response\":[$EL,]}"
  loc_is "trailing comma AFTER the selected element is not walked" "$(loc_verdict "$p")" "located:$E_OK"
  # The DEPTH CAP at 201 openers, and the ordinary-nesting row that makes it safe to
  # tighten: without the second, a cap set low enough to refuse real payloads still passes.
  deep=$(awk 'BEGIN{s="";for(i=0;i<201;i++)s=s "[";print s}')
  p="{\"junk\":$deep,\"tool_response\":[$EL]}"
  loc_is "nesting past the depth cap" "$(loc_verdict "$p")" refused
  unset deep
  # WALKABLE-BUT-INVALID, pinned to TODAY's behaviour on purpose: the scan walks past the
  # invalid part and locates the real block (status 0). If someone later tightens the
  # locator into a validator, or re-widens a claim about validation, one of these moves.
  p="{\"junk\":[1,],\"tool_response\":[$EL]}"
  loc_is "walkable: balanced-but-invalid sibling array" "$(loc_verdict "$p")" "located:$E_OK"
  p="{\"junk\":{\"a\" 1},\"tool_response\":[$EL]}"
  loc_is "walkable: sibling member with no colon" "$(loc_verdict "$p")" "located:$E_OK"
  p='{"junk":"\q","tool_response":['"$EL"']}'
  loc_is "walkable: invalid string escape in a sibling" "$(loc_verdict "$p")" "located:$E_OK"
else
  fail "locator program could not be extracted and self-verified (sv1=[$sv1] sv2=[$sv2]) — 15 locator-level rows not run"
fi

# 36c. FIXTURE / SLICE PARITY — the permanent form of Task 1 Step 7, reading only tracked
#      paths. A fixture edited without its slice leaves every classification row green
#      while the README byte-exact claim about the duplicated representation is false.
#      Both locator statuses must be 0 BEFORE the bytes are compared: two failed
#      extractions produce two equal empty strings.
if [ -n "$LOCATE_PROG" ]; then
  for f in shape0-success shape0-success-review shape1-fast-fail shape2-executor-timeout \
           shape3-backgrounding-notice collision-success-quotes-both collision-failure-quotes-true; do
    a=$(awk "$LOCATE_PROG" < "$FIXTURES/$f.json" 2>/dev/null); ra=$?
    b=$(printf '{"tool_response":%s}' "$(cat "$FIXTURES/$f.response.json")" | awk "$LOCATE_PROG" 2>/dev/null); rb=$?
    if [ "$ra" = 0 ] && [ "$rb" = 0 ] && [ "$a" = "$b" ]; then
      pass "$f: payload and response slice locate identical bytes"
    else
      fail "$f: payload and response slice locate identical bytes (rc $ra/$rb)"
    fi
  done
else
  fail "locator program unavailable — 7 fixture/slice parity rows not run"
fi

# 37. STATE EFFECTS. Three discarded classes x both gates x both tool-name sources x both
#     emitters. `writes no gate-pass state from clean` and `preserves earned state` are
#     different failures: byte preservation alone cannot see an implementation that
#     recomputes and stores the CURRENT fingerprint over a seeded identical one, which is
#     why the seed is a sentinel rather than a real hash.
MAPPING='execTool=mcp__codex__gateA
reviewTool=mcp__codex__gateB'
disc_payload() { # $1 = class, $2 = tool name
  case "$1" in
    failure)      _tr=$(resp_from shape1-fast-fail) ;;
    timeout)      _tr=$(resp_from shape2-executor-timeout) ;;
    no-result)    _tr='null' ;;
    backgrounded) _tr=$(resp_from shape3-backgrounding-notice) ;;
    unrecognized) _tr=$(unrec) ;;
  esac
  printf '{"hook_event_name":"PostToolUse","tool_name":"%s","tool_input":{},"tool_response":%s}' "$2" "$_tr"
}
run_as() { # $1 = jq|nojq, $2 = payload  (silent: these rows assert state, not messages)
  case "$1" in
    jq)   run "$2" >/dev/null ;;
    nojq) nojq_run "$2" >/dev/null ;;
  esac
}
tool_for() { # $1 = source, $2 = gate
  case "$1/$2" in
    default/review) printf 'mcp__codex__review' ;;
    default/exec)   printf 'mcp__codex__exec' ;;
    mapped/review)  printf 'mcp__codex__gateB' ;;
    mapped/exec)    printf 'mcp__codex__gateA' ;;
  esac
}
apply_mapping() { [ "$1" = mapped ] && printf '%s\n' "$MAPPING" > "$toolsf"; return 0; }
state_snapshot() {
  printf '%s|%s|%s|%s' "$(cat "$state" 2>/dev/null)" "$(cat "$count" 2>/dev/null)" \
                       "$(cat "$fresh" 2>/dev/null)" "$(cat "$countA" 2>/dev/null)"
}
# `timeout` is the CAPTURED shape2 executor-timeout envelope, driven through the same
# seeded-state matrix as the other discarded classes. The plan required a seeded-state
# TIMEOUT preservation row specifically; an earlier revision satisfied that with a
# classification-only row and the seeded matrix used the fast-failure fixture alone, so
# nothing proved the old hook advanced counters and fingerprint for the captured timeout
# payload under seeded state. Restored rather than re-dispositioned (Gate-B pass 4/6).
for k in failure timeout no-result backgrounded; do
  for gate in review exec; do
    for src in default mapped; do
      for rn in jq nojq; do
        tn=$(tool_for "$src" "$gate"); lbl="$k/$gate/$src/$rn"
        reset_all; apply_mapping "$src"
        run_as "$rn" "$(disc_payload "$k" "$tn")"
        if [ ! -f "$state" ] && [ ! -f "$count" ] && [ ! -f "$fresh" ] && [ ! -f "$countA" ]; then
          pass "$lbl writes no gate-pass state from clean"
        else
          fail "$lbl writes no gate-pass state from clean"
        fi
        reset_all; apply_mapping "$src"
        printf 'SEEDED-FINGERPRINT' > "$state"; printf '7' > "$count"
        printf '5' > "$fresh"; printf '4' > "$countA"
        before=$(state_snapshot)
        run_as "$rn" "$(disc_payload "$k" "$tn")"
        [ "$(state_snapshot)" = "$before" ] \
          && pass "$lbl preserves passCount/freshCount/fingerprint/passCountA" \
          || fail "$lbl preserves passCount/freshCount/fingerprint/passCountA"
      done
    done
  done
done
reset_all

# 37b. `unrecognized` is the FAIL-OPEN class: it must behave exactly like `success` on
#      state, over the same four combinations (P9-14), and additionally disclose.
for src in default mapped; do
  for gate in review exec; do
    for rn in jq nojq; do
      tn=$(tool_for "$src" "$gate"); lbl="unrecognized/$gate/$src/$rn"
      reset_all; apply_mapping "$src"
      run_as "$rn" "$(disc_payload unrecognized "$tn")"
      if [ "$gate" = review ]; then _got=$(cat "$count" 2>/dev/null || printf -)
      else _got=$(cat "$countA" 2>/dev/null || printf -); fi
      [ "$_got" = 1 ] && pass "$lbl counts" || fail "$lbl counts (got [$_got])"
      [ -f "$unverf" ] && pass "$lbl records the disclosure marker" \
                       || fail "$lbl records the disclosure marker"
    done
  done
done
reset_all

# 37c. The two state families must not be conflated: a discarded class writes no
#      DIAGNOSTIC marker either, except `backgrounded`, whose advice marker is by design.
for k in failure no-result; do
  reset_all
  run "$(disc_payload "$k" mcp__codex__review)" >/dev/null
  if [ ! -f "$bgadvf" ] && [ ! -f "$unverf" ] && [ ! -f "$pendf" ]; then
    pass "$k creates no diagnostic marker"
  else
    fail "$k creates no diagnostic marker"
  fi
done
reset_all
run "$(disc_payload backgrounded mcp__codex__review)" >/dev/null
[ -f "$bgadvf" ] && pass "backgrounded creates its diagnostic marker" \
                 || fail "backgrounded creates its diagnostic marker"
[ ! -f "$unverf" ] && [ ! -f "$pendf" ] \
  && pass "backgrounded creates no disclosure marker" \
  || fail "backgrounded creates no disclosure marker"

# 37d. `success` and `unrecognized` have IDENTICAL counter and fingerprint effects by
#      design, so only the marker and the message separate them.
reset_all
rev
[ "$(cat "$count" 2>/dev/null)" = 1 ] && pass "success counts" || fail "success counts"
[ ! -f "$unverf" ] && [ ! -f "$pendf" ] \
  && pass "success creates no disclosure marker" || fail "success creates no disclosure marker"
reset_all

# 38. THE A5 MARKER TABLE, row by row. Each needs a SURGICAL fault: replacing .context
#     with a file removes the adoption marker so the hook exits before classifying, and
#     chmod 500 .context breaks the counter writes while stdout still succeeds. What
#     separates the operations: a DIRECTORY at a marker path fails `printf > f`.
unrec_rev() { run "$(disc_payload unrecognized mcp__codex__review)"; }

# 38a. on: writes shown, owes nothing
reset_all
out=$(unrec_rev)
[ -f "$unverf" ] && [ ! -f "$pendf" ] && pass "on: writes shown, owes nothing" \
                                     || fail "on: writes shown, owes nothing"
printf '%s' "$out" | grep -q 'classified at least one gate call as countable' \
  && pass "on: the disclosure is delivered" || fail "on: the disclosure is delivered"

# 38b. off: owes pending, no shown
reset_all; : > "$offf"
out=$(unrec_rev)
[ -z "$out" ] && pass "off: nothing is delivered" || fail "off: nothing is delivered"
[ -f "$pendf" ] && [ ! -f "$unverf" ] && pass "off: owes pending, no shown" \
                                      || fail "off: owes pending, no shown"
[ "$(cat "$count" 2>/dev/null)" = 1 ] && pass "off: the unrecognized pass still counts" \
                                      || fail "off: the unrecognized pass still counts"
rm -f "$offf"

# 38c. failed write: owes pending
reset_all
run_closed "$(disc_payload unrecognized mcp__codex__review)"; rc=$?
[ "$rc" = 0 ] && pass "failed write: exits 0" || fail "failed write: exits 0 (got $rc)"
[ -f "$pendf" ] && [ ! -f "$unverf" ] && pass "failed write: owes pending" \
                                      || fail "failed write: owes pending"

# 38d. shown-write failure keeps the debt — the debt must not die with the marker.
reset_all
mkdir -p "$unverf"
unrec_rev >/dev/null 2>&1; rc=$?
[ "$rc" = 0 ] && pass "shown-write failure: exits 0" || fail "shown-write failure: exits 0 (got $rc)"
[ -f "$pendf" ] && pass "shown-write failure keeps the debt" || fail "shown-write failure keeps the debt"
rmdir "$unverf" 2>/dev/null
reset_all

# 38e. a carried disclosure is PREFIXED, and clears on delivery. The setup must not itself
#      emit, or it flushes the debt first: keep the gate off through setup and remove the
#      marker immediately before the observed event.
reset_all; : > "$offf"
unrec_rev >/dev/null                       # earns the debt while suppressed
rm -f "$offf"
# `revout`, not `rev`: `rev` is the SILENT runner, and a message assertion behind it is
# vacuous — it reported an empty capture as a missing prefix.
out=$(revout)                              # a success pass: owes nothing of its own
printf '%s' "$out" | grep -q 'Earlier: Claude via Claude Code — gate hook' \
  && pass "pending flushes prefixed" || fail "pending flushes prefixed"
[ ! -f "$pendf" ] && [ -f "$unverf" ] && pass "flush clears pending" || fail "flush clears pending"

# 38f. pending + a currently-unrecognized call: ONE message, NOT prefixed, and pending
#      clears. The statement is about THIS call, so `note_unverified` takes precedence
#      over the pending check — inverting that precedence is what this row fails on.
reset_all; : > "$offf"
unrec_rev >/dev/null
rm -f "$offf"
# The debt-earning call counted too, so the counters are zeroed WITHOUT touching the
# markers — otherwise `still counts` reads 2 and fails for a setup reason.
reset_gate_state
out=$(unrec_rev)
printf '%s' "$out" | grep -q 'Earlier: ' \
  && fail "pending+unrecognized: not prefixed" || pass "pending+unrecognized: not prefixed"
[ "$(printf '%s' "$out" | grep -c 'classified at least one gate call as countable')" = 1 ] \
  && pass "pending+unrecognized: exactly one disclosure" \
  || fail "pending+unrecognized: exactly one disclosure"
[ -f "$unverf" ] && [ ! -f "$pendf" ] && pass "pending+unrecognized: shown written, pending cleared" \
                                      || fail "pending+unrecognized: shown written, pending cleared"
[ "$(cat "$count" 2>/dev/null)" = 1 ] && pass "pending+unrecognized: still counts" \
                                      || fail "pending+unrecognized: still counts"

# 38g. shown + pending coexisting resolves to shown, silently. A REAL pending file is
#      required: a directory there is not seen as pending at all.
#      `revout`, NOT `rev`: `rev` redirects the hook's stdout to /dev/null, so a silence
#      assertion behind it compares an always-empty capture and passes against a hook that
#      shouts. Gate-B pass 5 mutation-tested exactly this row and it survived the bug. The
#      suite names the two runners apart for this reason, and this is the second time the
#      silent one has been used behind a message assertion.
reset_all
printf '%s' '' > "$unverf"; printf '%s' '' > "$pendf"
out=$(revout)
[ -z "$out" ] && pass "shown+pending resolves to shown (silent)" || fail "shown+pending resolves to shown (silent)"
[ ! -f "$pendf" ] && pass "the next event clears the coexistence" || fail "the next event clears the coexistence"
out=$(revout)
[ -z "$out" ] && pass "coexistence cleanup does not repeat" || fail "coexistence cleanup does not repeat"

# 38h. shown means silent: a spent one-shot must not re-fire.
reset_all
unrec_rev >/dev/null
out=$(unrec_rev)
[ -z "$out" ] && pass "shown means silent" || fail "shown means silent (got [$out])"
[ ! -f "$pendf" ] && pass "shown means silent writes nothing" || fail "shown means silent writes nothing"

# 38i. C2, BOTH DIRECTIONS — the accepted residual: counted, nothing delivered, nothing
#      recorded. Neither direction may be quietly closed OR widened.
reset_all; : > "$offf"; mkdir -p "$pendf"
out=$(unrec_rev); rc=$?
[ "$rc" = 0 ] && [ -z "$out" ] && pass "C2/1 (suppressed): exits 0, no output" \
                              || fail "C2/1 (suppressed): exits 0, no output"
[ ! -f "$unverf" ] && pass "C2/1: neither marker recorded" || fail "C2/1: neither marker recorded"
[ "$(cat "$count" 2>/dev/null)" = 1 ] && pass "C2/1: counted silently" || fail "C2/1: counted silently"
rm -f "$offf"
# rmdir BEFORE the reset: `reset_all` calls `rm -f` on the marker paths, which prints an
# is-a-directory error to an unredirected stderr and pollutes every later run.
rmdir "$pendf" 2>/dev/null
reset_all; mkdir -p "$pendf"
run_closed "$(disc_payload unrecognized mcp__codex__review)"; rc=$?
[ "$rc" = 0 ] && pass "C2/2 (failed write): exits 0" || fail "C2/2 (failed write): exits 0 (got $rc)"
[ ! -f "$unverf" ] && pass "C2/2: neither marker recorded" || fail "C2/2: neither marker recorded"
[ "$(cat "$count" 2>/dev/null)" = 1 ] && pass "C2/2: counted silently" || fail "C2/2: counted silently"
rmdir "$pendf" 2>/dev/null
reset_all

# 38j. The bgAdvice one-shot. It must not burn on a message nobody saw.
bg_rev() { run "$(disc_payload backgrounded mcp__codex__review)"; }
reset_all
out=$(bg_rev)
printf '%s' "$out" | grep -q 'moved to the background at the auto-background threshold' \
  && pass "long advice is shown first" || fail "long advice is shown first"
[ -f "$bgadvf" ] && pass "long advice writes its marker" || fail "long advice writes its marker"
out=$(bg_rev)
printf '%s' "$out" | grep -q 'CLAUDE_CODE_MCP_AUTO_BACKGROUND_MS' \
  && pass "short form names the variable" || fail "short form names the variable"
printf '%s' "$out" | grep -q 'moved to the background at the auto-background threshold' \
  && fail "short form must not repeat the long guidance" || pass "short form replaces the long guidance"
reset_all; : > "$offf"
bg_rev >/dev/null
[ ! -f "$bgadvf" ] && pass "off: does not burn the bg one-shot" || fail "off: does not burn the bg one-shot"
rm -f "$offf"
reset_all
run_closed "$(disc_payload backgrounded mcp__codex__review)"
[ ! -f "$bgadvf" ] && pass "failed write: does not burn the bg one-shot" \
                   || fail "failed write: does not burn the bg one-shot"
reset_all
mkdir -p "$bgadvf"
out=$(bg_rev 2>/dev/null)
printf '%s' "$out" | grep -q 'moved to the background at the auto-background threshold' \
  && pass "bgAdvice write failure repeats the long form" || fail "bgAdvice write failure repeats the long form"
rmdir "$bgadvf" 2>/dev/null
reset_all

# 38k. Invariant 1 at EVERY marker path, under sh and under dash.
for mk in "$bgadvf" "$unverf" "$pendf"; do
  reset_all
  mkdir -p "$mk"
  case "$mk" in
    "$bgadvf") pl=$(disc_payload backgrounded mcp__codex__review) ;;
    *)         pl=$(disc_payload unrecognized mcp__codex__review) ;;
  esac
  printf '%s' "$pl" | "$HOOK_SH_BIN" "$HOOK" >/dev/null 2>&1; rc=$?
  [ "$rc" = 0 ] && pass "exits 0 with a directory at $(basename "$mk")" \
                || fail "exits 0 with a directory at $(basename "$mk") (got $rc)"
  if command -v dash >/dev/null 2>&1; then
    printf '%s' "$pl" | dash "$HOOK" >/dev/null 2>&1; rc=$?
    [ "$rc" = 0 ] && pass "dash: exits 0 with a directory at $(basename "$mk")" \
                  || fail "dash: exits 0 with a directory at $(basename "$mk") (got $rc)"
  else
    skip "dash unavailable — the special-builtin assertion for $(basename "$mk") did not run"
  fi
  rmdir "$mk" 2>/dev/null
done
reset_all
# The A5 row `flush wrote, unverified written, pending DELETE fails` has no surgical fault
# available: one permission governs both operations on .context, and a directory at the
# pending path is not seen as pending at all, so the disclosure never fires. Recorded as
# an open Gate-B obligation (P9-9) rather than asserted by a row that proves something else.
skip "A5 row 'pending delete fails' — no operation-specific fault available (P9-9)"

# 39. FAULT TOLERANCE OF THE TWO LOAD-BEARING TOOLS. Three shapes each — absent, nonzero
#     exit, partial output then failure — through both gate tools. Every shim is verified
#     in BOTH directions before an assertion depends on it, and a shim that cannot be
#     built skips its dependent assertions WITH it.
mk_shim() { # $1 = dir name, $2 = command, $3 = script body -> prints the dir, or nothing
  _sd="$sandbox/$1"; mkdir -p "$_sd" || return 0
  printf '#!/bin/sh\n%s\n' "$3" > "$_sd/$2" || return 0
  chmod +x "$_sd/$2" || return 0
  printf '%s' "$_sd"
}
shim_run() { printf '%s' "$2" | PATH="$1:$PATH" "$HOOK_SH_BIN" "$HOOK"; }

# 39a. awk faults. Input is a real FAILURE envelope — the one case where fail-open costs a
#      real count, so `discards it anyway` would be fail-CLOSED on pass state.
awk_absent=$(mk_path noawk cat grep sed head tr git mkdir rm cp mktemp jq shasum sha1sum cksum)
awk_fail=$(mk_shim awkfail awk 'exit 3')
# The partial shim exits 2, not 1: status 1 is the locator saying "unambiguously nothing
# there", a DOCUMENTED verdict a healthy awk returns. A shim exiting 1 would be asserting
# that the hook mistrusts a legitimate answer, not that it refuses to classify from
# partial bytes, which is the property this row exists to pin.
awk_partial=$(mk_shim awkpartial awk 'printf "partial"; exit 2')
for pair in "absent:$awk_absent:absolute" "nonzero:$awk_fail:prefix" "partial:$awk_partial:prefix"; do
  shape=${pair%%:*}; rest=${pair#*:}; d=${rest%:*}; mode=${rest##*:}
  if [ -z "$d" ]; then
    skip "awk fault '$shape' — shim could not be built; its assertions did not run"
    continue
  fi
  # Both directions: awk must be broken under the fault PATH, and still work outside it.
  if [ "$mode" = absolute ]; then
    faultpath="$d"
    PATH="$faultpath" command -v awk >/dev/null 2>&1 && { skip "awk fault '$shape' — awk still present"; continue; }
    PATH="$faultpath" command -v git >/dev/null 2>&1 || { skip "awk fault '$shape' — git missing from the fault PATH"; continue; }
  else
    faultpath="$d:$PATH"
    printf 'x\n' | PATH="$faultpath" awk '{print}' >/dev/null 2>&1 && { skip "awk fault '$shape' — the shim does not fail"; continue; }
  fi
  [ "$(printf 'x\n' | awk '{print}' 2>/dev/null)" = x ] || { skip "awk fault '$shape' — the real awk is unusable"; continue; }
  reset_all
  out=$(printf '%s' "$(disc_payload failure mcp__codex__review)" | PATH="$faultpath" "$HOOK_SH_BIN" "$HOOK"); rc=$?
  [ "$rc" = 0 ] && pass "awk $shape: exits 0" || fail "awk $shape: exits 0 (got $rc)"
  [ "$(cat "$count" 2>/dev/null)" = 1 ] && pass "awk $shape: review counts (fail-open)" \
                                        || fail "awk $shape: review counts (fail-open)"
  h=$(cat "$state" 2>/dev/null || echo '')
  case "$h" in '' | unavailable) fail "awk $shape: stores a usable fingerprint (got [$h])" ;;
               *) pass "awk $shape: stores a usable fingerprint" ;; esac
  printf '%s' "$out" | grep -q 'classified at least one gate call as countable' \
    && pass "awk $shape: discloses the uncertainty" || fail "awk $shape: discloses the uncertainty"
  reset_all
  printf '%s' "$(disc_payload failure mcp__codex__exec)" | PATH="$faultpath" "$HOOK_SH_BIN" "$HOOK" >/dev/null
  [ "$(cat "$countA" 2>/dev/null)" = 1 ] && pass "awk $shape: exec counts (fail-open)" \
                                         || fail "awk $shape: exec counts (fail-open)"
done
reset_all

# 39b. sed faults. jq stays on the PATH, so field() routing does not need sed and the
#      classifier is the only consumer left. Input is a real SUCCESS envelope: the blank
#      test yields an empty string on a broken sed, which would read as blank and turn a
#      genuine success into `no-result` — fail-CLOSED, the direction this design refuses.
sed_fail=$(mk_shim sedfail2 sed 'exit 3')
sed_partial=$(mk_shim sedpartial sed 'printf "partial"; exit 1')
for pair in "nonzero:$sed_fail" "partial:$sed_partial"; do
  shape=${pair%%:*}; d=${pair#*:}
  if [ -z "$d" ]; then
    skip "sed fault '$shape' — shim could not be built; its assertions did not run"
    continue
  fi
  faultpath="$d:$PATH"
  printf 'x\n' | PATH="$faultpath" sed 's/x/y/' >/dev/null 2>&1 && { skip "sed fault '$shape' — the shim does not fail"; continue; }
  [ "$(printf 'x\n' | sed 's/x/y/' 2>/dev/null)" = y ] || { skip "sed fault '$shape' — the real sed is unusable"; continue; }
  reset_all
  out=$(printf '%s' "$(payload mcp__codex__review "$(resp_success)")" | PATH="$faultpath" "$HOOK_SH_BIN" "$HOOK"); rc=$?
  [ "$rc" = 0 ] && pass "sed $shape: exits 0" || fail "sed $shape: exits 0 (got $rc)"
  [ "$(cat "$count" 2>/dev/null)" = 1 ] && pass "sed $shape: a success envelope still counts" \
                                        || fail "sed $shape: a success envelope still counts"
  # P9-15: the review side carries the usable-fingerprint oracle its awk counterpart has.
  h=$(cat "$state" 2>/dev/null || echo '')
  case "$h" in '' | unavailable) fail "sed $shape: stores a usable fingerprint (got [$h])" ;;
               *) pass "sed $shape: stores a usable fingerprint" ;; esac
  printf '%s' "$out" | grep -q 'classified at least one gate call as countable' \
    && pass "sed $shape: discloses the uncertainty" || fail "sed $shape: discloses the uncertainty"
  reset_all
  printf '%s' "$(payload mcp__codex__exec "$(resp_success)")" | PATH="$faultpath" "$HOOK_SH_BIN" "$HOOK" >/dev/null
  [ "$(cat "$countA" 2>/dev/null)" = 1 ] && pass "sed $shape: exec counts" || fail "sed $shape: exec counts"
done
reset_all

# 40. MESSAGES AND COMPOSITION. Exact comparison on BOTH fields — a clause grep catches
#     neither a negation, nor a dropped remedy, nor a reordered composition. Expected
#     values are LITERAL COPIES: a golden that read the hook's own variable would agree
#     with any text the hook emits.
#
#     Every comparison goes through ONE helper that returns the field's ESCAPED bytes,
#     because the jq-free extractor cannot decode and every message here contains quotes.
#     Both emitters escape exactly backslash and quote, so the two agree byte for byte.
CTX_TERM='"},"systemMessage"'
MSG_TERM='"}'
field_of() { # $1 = document, $2 = ctx|msg -> the field's ESCAPED bytes
  case "$2" in
    ctx) _t=${1#*additionalContext\":\"}; printf '%s' "${_t%%"$CTX_TERM"*}" ;;
    msg) _t=${1#*systemMessage\":\"};     printf '%s' "${_t%"$MSG_TERM"}" ;;
  esac
}
golden() { # $1 = label, $2 = document, $3 = expected ctx, $4 = expected msg
  _g=$(field_of "$2" ctx)
  [ "$_g" = "$3" ] && pass "$1: ctx exact" || fail "$1: ctx exact (got [$_g])"
  _g=$(field_of "$2" msg)
  [ "$_g" = "$4" ] && pass "$1: msg exact" || fail "$1: msg exact (got [$_g])"
}

G_FAILURE_CTX='Claude via Claude Code — gate hook. <state>this Codex call returned an envelope reporting failure.</state> <consequence>Not counted as a gate pass, no review fingerprint stored, does not count toward the floor.</consequence> <next>Read error.code in the tool result. CODEX_EXECUTION_FAILED is the pinned server generic failure code and does NOT tell you whether the call started, so check the accompanying error message and any session artifacts before assuming nothing ran; a call that did start may have left work behind. CODEX_TIMEOUT means the executor gave up mid-run: re-run the SAME call with the SAME scope. Any other code, or no code at all, is unclassified: this state covers every envelope the hook managed to route AND read as carrying success false as its first property, which is not limited to the two codes named here — routing, locating the result text and the raw key spelling each gate it, and an envelope failing any of those lands in a different state instead. So re-run once with the same scope and, if it repeats, report the code and message verbatim together with the effective server name and version from claude mcp list — an unfamiliar code is itself evidence about which server answered. Never retry with a narrower instruction or a smaller range, because that would count a pass for less than the artifact or diff the gate requires. Report one line: \"gate pass discarded | error-code | started yes/no/unknown\". Before re-running, delete the target findings file for the pass and confirm it is gone — both branch files for a full Gate-B re-run, only the failed branch for a single-branch resume. The checks on that file establish its structure — terminator present, count matching, nothing but finding lines — and not which run produced it.</next> <stop>One retry per pass is the whole recovery budget under CLAUDE.md section 5. If the retry also fails, stop and surface that line; the operator note carries the configuration remedy.</stop>'
G_FAILURE_MSG='⚠ Codex call failed — not counted as a gate pass. If the code was CODEX_TIMEOUT, the fix is configuration and only you can apply it: raise the executor timeout for the Codex MCP server, or reduce load outside the review. Do not ask for a smaller review scope — a narrower pass is worth less than a slow one.'
G_NORESULT_CTX='Claude via Claude Code — gate hook. <state>this gate call carried no result text the hook could read.</state> <consequence>Not counted as a gate pass, no review fingerprint stored.</consequence> <next>Treat the pass as not run and report it. Two causes produce this shape and the tool name cannot separate them: a hooks-API payload change, or a third-party tool returning empty or non-text content — which reaches the gates either through a mapping in .context/codex-gate.tools or as a server registered under the default name codex, so an absent mapping does not rule it out. Report one line: \"gate call unreadable | mapped yes/no from .context/codex-gate.tools | claude-code version\". Before re-running, delete the target findings file for the pass and confirm it is gone — both branch files for a full Gate-B re-run, only the failed branch for a single-branch resume. The checks on that file establish its structure — terminator present, count matching, nothing but finding lines — and not which run produced it.</next> <stop>One retry per pass is the whole recovery budget under CLAUDE.md section 5. A repeat is configuration or contract, not a transient failure, so stop and surface it; the operator note carries both checks.</stop>'
# shellcheck disable=SC2016  # a literal copy of a shipped prompt; the backticks are its own
G_NORESULT_MSG='⚠ Gate call returned no readable result — not counted. Run both checks before concluding. First: does .context/codex-gate.tools map a tool name? Second: what does `claude mcp list` show as the effective server and version — not what .mcp.json says, because scope precedence can make a different entry of the same name effective. These checks narrow the cause; they do not prove it. If a mapping or a third-party server is in play, that tool may be returning empty or non-text content, which it can do legitimately: unmap it, or replace it with a server exposing exec and review. If both checks show the pinned server at its pinned version, a payload-contract change is the remaining explanation — record your Claude Code version and report it.'
G_BG_LONG_CTX='Claude via Claude Code — gate hook. <state>this gate call was moved to the background at the auto-background threshold, 120 s by default, so its result never reached the hook.</state> <consequence>The pass was discarded and not counted, and no fingerprint was stored.</consequence> <next>The original call may still be running and can still write its findings file later. If the tool result carries a task id, stop that task by it; if it carries none, wait for the call to finish. Do that before deleting that slot or re-running the pass. Before re-running, delete the target findings file for the pass and confirm it is gone — both branch files for a full Gate-B re-run, only the failed branch for a single-branch resume. The checks on that file establish its structure — terminator present, count matching, nothing but finding lines — and not which run produced it.</next> <stop>Do not re-run while that task is active: a late writer landing in a slot you already re-ran leaves a correctly terminated file from the wrong run, and no downstream check can detect that. One retry per pass is the whole recovery budget under CLAUDE.md section 5. If the call backgrounds a second time, stop and surface it as a setup problem rather than retrying again, reporting one line: \"gate pass discarded | backgrounded | second occurrence | CLAUDE_CODE_MCP_AUTO_BACKGROUND_MS set yes/no\".</stop>'
G_BG_LONG_MSG='⚠ Gate pass discarded (backgrounded) — a setup gap, not a failed review. Set CLAUDE_CODE_MCP_AUTO_BACKGROUND_MS in the environment Claude Code is launched from, then restart Claude Code: it reads the value at process start, so exporting it inside a tool shell leaves the running session unchanged. Use 0 to disable auto-backgrounding, or a positive value that exceeds your longest gate call, since a positive value shorter than the call still backgrounds it. Requires Claude Code 2.1.212 or newer.'
G_BG_SHORT_CTX='Claude via Claude Code — gate hook. <state>this gate call was backgrounded and its result never reached the hook.</state> <consequence>The pass was discarded and not counted, and no fingerprint was stored.</consequence> <next>If the tool result carries a task id, stop that task by it; if it carries none, await the original call. Do that before re-running the pass. Before re-running, delete the target findings file for the pass and confirm it is gone — both branch files for a full Gate-B re-run, only the failed branch for a single-branch resume. The checks on that file establish its structure — terminator present, count matching, nothing but finding lines — and not which run produced it.</next> <stop>Do not re-run while that task is active, so a late writer cannot land in a slot you already re-ran. One retry per pass is the whole recovery budget under CLAUDE.md section 5. If the call backgrounds a second time, stop and surface it rather than retrying again, reporting one line: \"gate pass discarded | backgrounded | second occurrence | CLAUDE_CODE_MCP_AUTO_BACKGROUND_MS set yes/no\".</stop>'
G_BG_SHORT_MSG='⚠ Gate pass discarded (backgrounded) — not counted. Set CLAUDE_CODE_MCP_AUTO_BACKGROUND_MS in the environment Claude Code is launched from and restart Claude Code; the full guidance was shown once earlier in this workspace.'
G_UNVERIFIED_CTX='Claude via Claude Code — gate hook. <state>this workspace has classified at least one gate call as countable without being able to interpret its result, and attempted to record it.</state> <consequence>The counter is a mechanical tally, not a count of completed reviews: it can include calls that failed or reviewed nothing, so it can overstate them.</consequence> <next>Judge every pass on its findings artifact and discount any incomplete or unverified call, whatever the counter says.</next> <stop>Normally said once per workspace. It repeats when its marker cannot be persisted, when two hook runs race, or when that marker is deleted by hand or by a tool that cleans .context, so treat a repeat as a marker problem rather than as new information.</stop>'
# shellcheck disable=SC2016  # a literal copy of a shipped prompt; the backticks are its own
G_UNVERIFIED_MSG='ℹ A gate call was classified as countable without inspection, and recording it was attempted. Causes with a check and a fix: a pinned-server envelope whose key order or formatting changed — compare the version in .mcp.json with the server actually serving the tools (`claude mcp list`), and pinning it back fixes it; a reworded backgrounding notice — set CLAUDE_CODE_MCP_AUTO_BACKGROUND_MS in the environment Claude Code is launched from and restart Claude Code, using 0 to disable auto-backgrounding or a positive value exceeding your longest gate call, needing Claude Code 2.1.212 or newer; a broken awk or sed, which classification requires — check them functionally rather than by version flag, since --version is not POSIX and BSD sed exits nonzero for it on a healthy macOS: `printf \"x\\\\n\" | awk \"{print}\"` must print x and `printf \"x\\\\n\" | sed s/x/y/` must print y, each exiting 0. Causes with no user-side fix: a third-party tool whose envelope this hook cannot read — .context/codex-gate.tools names it only if it is mapped, and a third-party server registered under the default codex name reaches the gates with no mapping at all, so an absent mapping does not rule this out; where a mapping does exist, unmapping removes the gate rather than fixing the envelope; a payload the scan refused — four families land here: past the 1 Mi-unit size bound, past the 200-frame nesting-depth cap, structure the scan could not walk, and an ambiguity such as a duplicated tool_response, type or text key. Measuring the payload against those first two bounds rules them in or out; the remaining two produce this same message and the same state and are **not distinguishable from each other**, so record them as unresolved rather than guessing; and a defect in this hook parser — same situation. For either, keep the payload **locally and access-restricted**: it can contain prompts, absolute paths, review content, session identifiers and unrelated concurrent call data, so strip those before showing it to anyone, and never attach it unsanitized to a report. The list is not exhaustive: unrecognized is the terminal class, so any future unmatched shape lands here too.'

reset_all
golden "failure" "$(run "$(disc_payload failure mcp__codex__review)")" "$G_FAILURE_CTX" "$G_FAILURE_MSG"
reset_all
golden "no-result" "$(run "$(disc_payload no-result mcp__codex__review)")" "$G_NORESULT_CTX" "$G_NORESULT_MSG"
reset_all
golden "backgrounded long" "$(bg_rev)" "$G_BG_LONG_CTX" "$G_BG_LONG_MSG"
golden "backgrounded short" "$(bg_rev)" "$G_BG_SHORT_CTX" "$G_BG_SHORT_MSG"
reset_all
golden "disclosure alone" "$(unrec_rev)" "$G_UNVERIFIED_CTX" "$G_UNVERIFIED_MSG"

# 40b. COMPOSITION. A7: additionalContext bodies join with " — ", systemMessage bodies
#      with a single space, and a carried disclosure is prefixed `Earlier: ` in BOTH
#      fields so the two copies cannot disagree about which call the statement is about.
reset_all; : > "$offf"
unrec_rev >/dev/null                       # earn the debt without flushing it
rm -f "$offf"
composed=$(run "$(disc_payload failure mcp__codex__review)")
golden "composed failure+carried disclosure" "$composed" \
  "Earlier: $G_UNVERIFIED_CTX — $G_FAILURE_CTX" \
  "Earlier: $G_UNVERIFIED_MSG $G_FAILURE_MSG"
[ "$(ndocs "$composed")" = 1 ] && pass "composed pair: exactly one document" \
                               || fail "composed pair: exactly one document"

# 40c. A branch that emits NOTHING of its own must still flush the debt — alone, with no
#      separator. A non-commit Bash PostToolUse is the reachable silent event.
reset_all; : > "$offf"
unrec_rev >/dev/null
rm -f "$offf"
silent_out=$(run '{"hook_event_name":"PostToolUse","tool_name":"Bash","tool_input":{"command":"ls -la"}}')
golden "silent event flushes the debt alone" "$silent_out" \
  "Earlier: $G_UNVERIFIED_CTX" "Earlier: $G_UNVERIFIED_MSG"
printf '%s' "$silent_out" | grep -q ' — Earlier' \
  && fail "silent event: no separator" || pass "silent event: no separator"
reset_all

# 40d. The longest, most punctuated string the FALLBACK escaper ever handles, both fields
#      exact — and then parsed by a real JSON parser, since a well-formed-looking string
#      comparison cannot tell a valid document from an invalid one.
reset_all; : > "$offf"
nojq_run "$(disc_payload unrecognized mcp__codex__review)" >/dev/null
rm -f "$offf"
nojq_composed=$(nojq_run "$(disc_payload failure mcp__codex__review)")
golden "jq-free composed pair" "$nojq_composed" \
  "Earlier: $G_UNVERIFIED_CTX — $G_FAILURE_CTX" \
  "Earlier: $G_UNVERIFIED_MSG $G_FAILURE_MSG"
if command -v jq >/dev/null 2>&1; then
  printf '%s' "$nojq_composed" | jq -e . >/dev/null 2>&1 \
    && pass "jq-free composed document parses as JSON" || fail "jq-free composed document parses as JSON"
else
  skip "jq unavailable — the fallback document was not parsed"
fi
reset_all

# 40e. ONE DOCUMENT PER INVOCATION, for the five branches this change adds — the nine
#      pre-existing ones are section 34. Fourteen in total; `= 1`, never `-le 1`.
reset_all; one_doc "failure" "$(run "$(disc_payload failure mcp__codex__review)")"
reset_all; one_doc "no-result" "$(run "$(disc_payload no-result mcp__codex__review)")"
reset_all; one_doc "backgrounded long" "$(bg_rev)"
one_doc "backgrounded short" "$(bg_rev)"
reset_all; one_doc "disclosure alone" "$(unrec_rev)"
reset_all

# 40f. The unknown-tool note, BOTH fields exact. Section 20 asserts it by clause grep,
#      which accepts any rewording that keeps three substrings; this pins the shipped
#      bytes. DOUBLE-quoted, unlike the five constants above, because this prompt is
#      built inline in the hook and legitimately contains apostrophes — so the `$`
#      ending its matcher literal is escaped here rather than the quotes changed.
G_UNKNOWN_CTX="Claude via Claude Code — gate hook. <state>Codex tool 'mcp__codex__codex' is not counted by the review gates. The gates count 'mcp__codex__exec' (Gate A, reviews TEXT) and 'mcp__codex__review' (Gate B, reviews a DIFF); your Codex server exposes a surface that cannot be attributed to one gate or the other.</state> <consequence>Passes made through it stay invisible and Gate B will keep reporting 'not run', because a gate that cannot attribute a call cannot credit it.</consequence> <next>Treat reviews run through this tool as uncounted and say so when you report gate status; do not read a satisfied count as covering them. Every remedy is a configuration change on the operator machine — installing a server, editing .mcp.json, writing a mapping file — so it is addressed to the operator in the note beside this one, and there is nothing here for you to apply.</next> <stop>Said once per workspace, so treat a repeat as a marker problem rather than as new information.</stop>"
G_UNKNOWN_MSG="ℹ Codex tool 'mcp__codex__codex' is not counted by the gates. The gates count 'mcp__codex__exec' (Gate A, reviews TEXT) and 'mcp__codex__review' (Gate B, reviews a DIFF). Fix, in order of preference. First: install the pinned mcp-codex-dev server, which exposes both — /dev-workflow:workflow-init writes it into .mcp.json. Second, only if your server genuinely has two tools that separate reviewing TEXT from reviewing a DIFF: map the names in .context/codex-gate.tools ('execTool=<name>' / 'reviewTool=<name>'). Pointing both gates at one general-purpose tool moves the counters without either gate meaning what it says, which is a false checkmark and worse than this note. Either way the tool name must start with mcp__codex__: this hook is invoked by a hooks.json matcher of ^(Bash|Skill|mcp__codex__.*)\$, so an out-of-namespace name is either never delivered to this hook at all — the mapping looks applied and does nothing — or, for the two reserved names Bash and Skill, is delivered and hijacks a lifecycle event. Both are refused. Register the server under the name codex to place its tools there."
golden "unknown-tool note" "$(codextool mcp__codex__codex)" "$G_UNKNOWN_CTX" "$G_UNKNOWN_MSG"

# 40g. P9-35. The hook's "an unusable sed goes to unrecognized" guarantee is POST-ROUTING
#      only, and this pins the boundary. `field()` needs sed on the jq-free path too, so
#      with jq absent AND sed absent the event and tool names come back empty, the payload
#      routes nowhere, and classification is never reached: no class, no count, no
#      disclosure. Read as unconditional, that guarantee would promise a message the hook
#      has no path to emit — and invariant 1 still requires exit 0 through all of it.
nosed=$(mk_path nosed cat grep head tr git mkdir rm cp mktemp awk shasum sha1sum cksum)
if PATH="$nosed" command -v sed >/dev/null 2>&1 || PATH="$nosed" command -v jq >/dev/null 2>&1; then
  skip "no-route oracle — could not build a PATH lacking both jq and sed"
else
  reset_all
  out=$(printf '%s' "$(payload mcp__codex__review "$(resp_success)")" | PATH="$nosed" "$HOOK_SH_BIN" "$HOOK")
  st=$?
  [ "$st" = 0 ] && pass "no jq and no sed: hook still exits 0" \
                || fail "no jq and no sed: hook still exits 0 (got $st)"
  [ -z "$out" ] && pass "no jq and no sed: says nothing" \
                || fail "no jq and no sed: says nothing (got [$out])"
  [ ! -f "$count" ] && [ ! -f "$state" ] && [ ! -f "$unverf" ] && [ ! -f "$pendf" ] \
    && pass "no jq and no sed: writes no gate-pass or diagnostic state" \
    || fail "no jq and no sed: writes no gate-pass or diagnostic state"
fi

# 41. THE LOCATOR HAS A TIME BOUND, not only two size bounds. Gate-B pass 1 on 0.8.0
#     measured the shipped scan at 10.9 s for a 150 KB text block — ONE synchronous hook
#     invocation, on a payload comfortably under the 1 Mi-unit ceiling, which is roughly
#     7x larger again. Both documented bounds are SIZE bounds; neither bounds the work,
#     and a real Gate-B review result is routinely this size, so this is ordinary input
#     rather than an attack. This row is the counterfactual check for the buffering
#     rewrite and was written before it: against the pre-rewrite locator it fails by
#     about 5x its own bound.
#
#     The bound is wall-clock seconds at 1 s granularity — `date +%s` is what POSIX
#     gives, and %N is not portable. 2 s is deliberately loose for a slow or loaded CI
#     runner: a linear scan does this in well under a second (measured ~0.05 s), and the
#     defect it has to catch is 10.9 s, so the gap swallows any granularity argument.
PERF_KB=150
PERF_BOUND_S=2
perf_big=$(awk 'BEGIN{ s=sprintf("%1024s",""); gsub(/ /,"x",s); r=""
                       for (i=0; i<'"$PERF_KB"'; i++) r = r s
                       printf "%s", r }')
if [ "${#perf_big}" -lt $((PERF_KB * 1024)) ]; then
  fail "perf fixture: could not build a ${PERF_KB}KB body (got ${#perf_big} chars)"
else
  # Built on its own line, then interpolated: a literal \" written inline inside $(...)
  # inside "..." does not survive, which is this suite's documented nesting trap.
  perf_body='{\"success\": true, \"summary\": \"'"$perf_big"'\"}'
  perf_payload=$(payload mcp__codex__review "$(resp "$perf_body")")
  perf_start=$(date +%s)
  perf_cls=$(class_of "$perf_payload")
  perf_el=$(( $(date +%s) - perf_start ))
  [ "$perf_cls" = success ] \
    && pass "perf: ${PERF_KB}KB under-ceiling payload still classifies as success" \
    || fail "perf: ${PERF_KB}KB under-ceiling payload still classifies as success (got [$perf_cls])"
  [ "$perf_el" -le "$PERF_BOUND_S" ] \
    && pass "perf: ${PERF_KB}KB payload classified within ${PERF_BOUND_S}s (took ${perf_el}s)" \
    || fail "perf: ${PERF_KB}KB payload classified within ${PERF_BOUND_S}s (took ${perf_el}s)"

  # 41b. THE ANCHOR-PREFIXED NEAR MISS — the shape the first perf fix did NOT cover, and
  #      the reason the row above was not enough on its own. Gate-B pass 2 found it: the
  #      `backgrounded` test was only GUARDED by the literal anchor prefix, so a block
  #      that DOES start with `MCP tool \"` and then never completes the notice still ran
  #      the quadratic longest-suffix expansion — 5.9 s at 150 KB, 23.1 s at 300 KB. The
  #      row above begins with an envelope, so it takes the guard's cheap path and is
  #      blind to this entirely. That is the general lesson worth keeping: a timed row
  #      only covers the branch its fixture reaches.
  #
  #      Both `\n` placements, because they cost differently and only one is obvious: with
  #      NO `\n` the expansion scans the whole block, and with a LATE `\n` it scans to the
  #      newline — so a "does it contain \n" guard fixes the first and not the second.
  #      Measured 5.6 s and 5.5 s respectively before the bounded head.
  for nm_case in no-newline late-newline; do
    case "$nm_case" in
      no-newline)   nm_body='MCP tool \"'"$perf_big" ;;
      late-newline) nm_body='MCP tool \"'"$perf_big"'\nend' ;;
    esac
    nm_payload=$(payload mcp__codex__review "$(resp "$nm_body")")
    nm_start=$(date +%s)
    nm_cls=$(class_of "$nm_payload")
    nm_el=$(( $(date +%s) - nm_start ))
    [ "$nm_cls" = unrecognized ] \
      && pass "perf: anchor-prefixed near miss (${nm_case}) is unrecognized, not backgrounded" \
      || fail "perf: anchor-prefixed near miss (${nm_case}) is unrecognized, not backgrounded (got [$nm_cls])"
    [ "$nm_el" -le "$PERF_BOUND_S" ] \
      && pass "perf: anchor-prefixed near miss (${nm_case}) classified within ${PERF_BOUND_S}s (took ${nm_el}s)" \
      || fail "perf: anchor-prefixed near miss (${nm_case}) classified within ${PERF_BOUND_S}s (took ${nm_el}s)"
  done
fi


# 41d. RESERVED-NAME MAPPING HIJACK (Gate-B pass 3). The mapping parser accepted any
#      plausible token, and the mapped cases are tested BEFORE the native `Bash` and
#      `Skill` cases — so `reviewTool=Bash` made a `git commit` COUNT a Gate-B pass
#      instead of resetting the cycle, and `execTool=Skill` counted a skill invocation as
#      a Gate-A pass. Both are false checkmarks in recorded state, reachable from a
#      plausible typo, and this diff is what introduced the contract they contradict
#      (`hooks.json` matches `^(Bash|Skill|mcp__codex__.*)$`, so only those two reserved
#      names outside the namespace fire at all). Mapped names must now lie in
#      `mcp__codex__*` and are otherwise ignored, like any other unusable line.
#      SEEDED, not from clean. Asserting only that no counter APPEARS would pass against a
#      hook that had simply stopped handling the event at all; the property is that the
#      NATIVE branch still runs, so the commit must still RESET a cycle that is in flight.
reset_all
printf 'execTool=Skill\nreviewTool=Bash\n' > "$toolsf"
printf '2' > "$count"; printf '2' > "$countA"; printf 'seeded' > "$state"
run '{"hook_event_name":"PostToolUse","tool_name":"Skill","tool_input":{"skill":"superpowers:writing-plans"},"tool_response":[{"type":"text","text":"{\"success\": true}"}]}' >/dev/null
# `writing-plans` is a Gate-A RESET point, so the native branch clears the seeded count.
# That is the sharper assertion: a bumped count means the mapped case ran, an unchanged
# count would mean neither ran, and only the reset proves the native branch handled it.
[ ! -f "$countA" ] && pass "mapping hijack: execTool=Skill reaches the native Skill branch (Gate-A reset)" \
                   || fail "mapping hijack: execTool=Skill reaches the native Skill branch (Gate-A reset) (countA=$(cat "$countA" 2>/dev/null))"
run '{"hook_event_name":"PostToolUse","tool_name":"Bash","tool_input":{"command":"git commit -m x"},"tool_response":[{"type":"text","text":"{\"success\": true}"}]}' >/dev/null
[ ! -f "$count" ] && [ ! -f "$state" ] \
  && pass "mapping hijack: reviewTool=Bash still RESETS the cycle on commit" \
  || fail "mapping hijack: reviewTool=Bash still RESETS the cycle on commit (count=$([ -f "$count" ] && cat "$count"), state=$([ -f "$state" ] && echo present))"
# ...and a LEGITIMATE in-namespace mapping is untouched by the new check.
reset_all
printf 'execTool=mcp__codex__gateA\n' > "$toolsf"
run '{"hook_event_name":"PostToolUse","tool_name":"mcp__codex__gateA","tool_input":{},"tool_response":[{"type":"text","text":"{\"success\": true}"}]}' >/dev/null
[ -f "$countA" ] && pass "in-namespace mapping still counts" || fail "in-namespace mapping still counts"
reset_all

# 41e. THE 4096-UNIT NOTICE BOUND, on both sides. The bounded head that made the
#      anchor-prefixed near miss cheap also narrows the `backgrounded` class: a notice
#      whose segment falls past the cutoff is counted instead of discarded, which is the
#      wrong direction. Pass 3 asked for a genuine notice immediately INSIDE and OUTSIDE
#      it, so the boundary is a tested fact rather than an assumed one.
#
#      ONE UNIT apart, not "roughly either side". Pass 4 caught the first version padding
#      3900/4200: both rows stayed green for any cutoff in a 300-unit band, so they pinned
#      a region rather than the constant. The block is `MCP tool \"` (11 units) + pad +
#      `\" is still running after ` (26 units), so the segment ends at pad+37 and the two
#      pads below put that at exactly 4096 and 4097.
PERF_NOTICE_IN=4059
PERF_NOTICE_OUT=4060
for _side in inside outside; do
  case "$_side" in
    inside)  _padlen=$PERF_NOTICE_IN  ; _want=backgrounded ;;
    outside) _padlen=$PERF_NOTICE_OUT ; _want=unrecognized ;;
  esac
  _pad=$(awk -v n="$_padlen" 'BEGIN{s="";while(length(s)<n)s=s "n";printf "%s",substr(s,1,n)}')
  [ "${#_pad}" = "$_padlen" ] || fail "notice bound/$_side: pad is ${#_pad}, want $_padlen"
  _notice='MCP tool \"'"$_pad"'\" is still running after 120s'
  _cls=$(class_of "$(payload mcp__codex__review "$(resp "$_notice")")")
  [ "$_cls" = "$_want" ] \
    && pass "notice bound/$_side cutoff -> $_want" \
    || fail "notice bound/$_side cutoff -> $_want (got [$_cls])"
done
reset_all

# 41c. P9-12, promoted from "inherited" to a CORRECTNESS bug by Gate-B pass 2, because the
#      two halves combine into a malformed document. `flush_notes` ran unconditionally, so
#      an event the hook could not route still reached `emit`; and the jq-free emitter
#      interpolated `$event` without escaping while escaping ctx and msg. An event name
#      carrying a trailing backslash therefore emitted
#      `"hookEventName":"Bogus\","` — the backslash escapes the closing quote and Claude
#      Code receives invalid JSON. Spec §3.3 requires no output and no state for an
#      unroutable payload, which is also the fix.
#
#      Asserted in BOTH runners: the routing gate is shell-independent, and the malformed
#      document only appeared on the jq-free path, so testing one would have missed it.
MALFORMED_EVT='{"hook_event_name":"Bogus\"Evt","tool_name":"Bash","tool_input":{"command":"ls"}}'
for _r in normal nojq; do
  reset_all; : > "$offf"
  unrec_rev >/dev/null                       # earn the debt while suppressed
  rm -f "$offf"
  [ -f "$pendf" ] || fail "P9-12/$_r: setup — pending debt was not earned"
  case "$_r" in
    normal) mal_out=$(run "$MALFORMED_EVT") ;;
    nojq)   mal_out=$(nojq_run "$MALFORMED_EVT") ;;
  esac
  [ -z "$mal_out" ] \
    && pass "P9-12/$_r: unroutable event emits nothing" \
    || fail "P9-12/$_r: unroutable event emits nothing (got [$mal_out])"
  [ -f "$pendf" ] \
    && pass "P9-12/$_r: unroutable event preserves the pending debt" \
    || fail "P9-12/$_r: unroutable event preserves the pending debt"
  # Belt and braces: whatever it emits must at least be parseable. This is the assertion
  # that actually failed before the fix, and it stays so a future change that re-opens the
  # flush cannot re-open the malformed document silently.
  if [ -n "$mal_out" ] && command -v jq >/dev/null 2>&1; then
    printf '%s' "$mal_out" | jq -e . >/dev/null 2>&1 \
      && pass "P9-12/$_r: emitted document parses as JSON" \
      || fail "P9-12/$_r: emitted document parses as JSON"
  fi
done
reset_all

reset_all
echo "---"
[ "$fails" -eq 0 ] && { echo "all passed"; exit 0; } || { echo "$fails failed"; exit 1; }
