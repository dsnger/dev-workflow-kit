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
# The whole suite runs with no global or system git config and an empty init template, so
# a developer's core.hooksPath, comment character or template hooks can neither change
# what the hook decides nor be written to by the cases that install hook scripts.
# Command-scope config handed down through the environment is dropped too.
mkdir "$sandbox/template"
unset GIT_CONFIG_PARAMETERS GIT_CONFIG_COUNT
GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_NOSYSTEM=1 GIT_TEMPLATE_DIR=$sandbox/template
export GIT_CONFIG_GLOBAL GIT_CONFIG_NOSYSTEM GIT_TEMPLATE_DIR
cd "$work" || exit 1
git init -q
git config user.email t@t; git config user.name t
mkdir -p .context
# This project has adopted the workflow (Finding G) — without a marker the hook is
# silent by design, and every reminder assertion below would pass vacuously. Section 22
# covers the non-adopted repo.
: > .context/codex-gate.on
state=".context/codex-gate.gateB"
count=".context/codex-gate.passes"
fresh=".context/codex-gate.freshPasses"
# The pending half of a single-branch pair, and the pre-0.21.0 per-call counter names
# the hook retires (spec 2026-10-09 §3.1).
pendb=".context/codex-gate.pendingBranch"
old_count=".context/codex-gate.passCount"
old_fresh=".context/codex-gate.freshCount"
countA=".context/codex-gate.passCountA"
floorf=".context/codex-gate.floor"
capf=".context/codex-gate.cap"            # per-project cap override (section 43)
capxf=".context/codex-gate.cap-extra"     # passes a human allowed beyond the cap
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
nojq=$(mk_path nojq cat grep sed head tr ls git mkdir rm mv cp mktemp awk shasum sha1sum cksum)

# A jq-free PATH whose `sed` fails ONLY for the fallback emitter's escaping pass. Prints
# nothing when the real sed cannot be located, so the caller can skip its assertions.
mk_sedfail_path() {
  _real=$(command -v sed 2>/dev/null) || return 0
  case "$_real" in /*) ;; *) return 0 ;; esac
  _sd=$(mk_path sedfail cat grep head tr git mkdir rm mv cp mktemp awk shasum sha1sum cksum)
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

reset_gate_state() { rm -f "$state" "$count" "$fresh" "$countA" "$countA.closed" "$countA.spec" "$pendb" "$old_count" "$old_fresh"; }
# Full reset INCLUDING the opt-out marker and the three diagnostic markers. A section
# that wants the gate off must set the marker after calling this.
reset_all() {
  rm -f "$state" "$count" "$fresh" "$countA" "$countA.closed" "$countA.spec" "$floorf" "$toolsf" "$notedf" \
        "$bgadvf" "$unverf" "$pendf" "$offf" .context/codex-gate.wipBase.* \
        "$pendb" "$old_count" "$old_fresh" .context/codex-gate.pendingClaim.* \
        "$capf" "$capxf"
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

# 8c. The reset after a Bash call that matches `commit` needs HEAD or its reflog moved during
#     the call, or no usable record (0.37.3; before, git's subcommand spelling alone reset). PreToolUse
#     records HEAD under the call's tool_use_id, read by jq or, without jq, by the hook's awk
#     reader; the test moves HEAD itself where a command would have. Every row runs with and
#     without jq. $1 = expected (reset|kept), $2 = move|stay, $3 = the command as JSON string
#     bytes, $4 = extra top-level members.
head_case() {
  printf '1\n' > "$count"
  "$hc" "{\"hook_event_name\":\"PreToolUse\",\"tool_name\":\"Bash\",\"tool_use_id\":\"toolu_h1\",\"tool_input\":{\"command\":\"$3\"}}" >/dev/null
  [ "$2" = move ] && git commit -q --allow-empty -m "8c move" >/dev/null 2>&1
  "$hc" "{\"hook_event_name\":\"PostToolUse\",\"tool_name\":\"Bash\",\"tool_use_id\":\"toolu_h1\",\"tool_input\":{\"command\":\"$3\"}${4:-}}" >/dev/null
  if [ -f "$count" ]; then _got=kept; else _got=reset; fi
  [ "$_got" = "$1" ] && pass "8c $hc: $1 ($2): $3" || fail "8c $hc: $1 ($2): $3 (got $_got)"
  [ ! -f .context/codex-gate.headPre.toolu__h1 ] && pass "8c $hc: HEAD record removed ($3)" || fail "8c $hc: HEAD record removed ($3)"
}
for hc in run nojq_run; do
  reset_all
  head_case kept stay 'git log --oneline | grep -i commit'
  head_case kept stay 'git log --grep=\"git commit\"'
  head_case kept stay 'git -C commit status'
  head_case kept stay 'echo git; echo commit'
  head_case kept stay 'git status\necho commit'
  # plain text naming git commit, also past an escaped quote (todos: 0.31.0 kit031gb1018)
  head_case kept stay 'echo git commit'
  head_case kept stay 'printf %s git commit'
  head_case kept stay 'git log --grep=\"a \\\" git commit \\\" b\"'
  # an operand-taking long option written with a space: its operand is not the subcommand
  head_case kept stay 'git --work-tree commit status'
  head_case kept stay 'git --git-dir commit log'
  head_case kept stay 'git --namespace commit log'
  head_case kept stay 'git --config-env commit status'
  # since 0.37.3 the spelling alone does not reset: HEAD and its reflog unchanged (a failed
  # commit, text naming one) keep the counters; the same calls reset when HEAD moved
  # (field evidence 2026-10-20: a heredoc and a printf naming `git commit` cleared a cycle)
  for c in 'git commit -m x' 'git -C x commit -m y' 'nohup git commit -m y &' \
           "cat > f.sh <<'EOF'\\ngit commit -m y &\\nEOF" "printf '%s\\\\n' 'run \`git commit\` here'"; do
    head_case kept stay "$c"
  done
  # an amend replaces HEAD: reset
  printf '1\n' > "$count"
  "$hc" '{"hook_event_name":"PreToolUse","tool_name":"Bash","tool_use_id":"toolu_h1","tool_input":{"command":"git commit --amend -m y"}}' >/dev/null
  git commit -q --allow-empty --amend -m "8c amend" >/dev/null 2>&1
  "$hc" '{"hook_event_name":"PostToolUse","tool_name":"Bash","tool_use_id":"toolu_h1","tool_input":{"command":"git commit --amend -m y"}}' >/dev/null
  [ ! -f "$count" ] && pass "8c $hc: amend -> reset" || fail "8c $hc: amend -> reset"
  head_case reset move 'git commit -m x'
  head_case reset move 'git -C x commit -m y'
  head_case reset move 'git --work-tree x commit -m y'
  head_case reset move 'git --git-dir=.git commit -m y'
  head_case reset move 'cd \"a b\" && git commit -m y'
  head_case reset move 'git -c user.name=\"A B\" commit'
  head_case reset move 'git --no-pager commit -m y'
  head_case reset move 'FOO=1 git commit -m y'
  head_case reset move 'nohup git commit -m y &'
  head_case reset move 'if true; then git commit -m y; fi'
  head_case reset move 'if git commit -m y; then :; fi'
  head_case reset move 'while git commit -m y; do :; done'
  head_case reset move 'until git commit -m y; do :; done'
  head_case reset move 'if false; then :; elif git commit -m y; then :; fi'
  head_case reset move '/usr/bin/git commit -m y'
  # shellcheck disable=SC2016  # a literal command substitution, the input under test
  head_case reset move 'x=$(git commit -m y)'
  head_case reset move 'git \\\ncommit -m y'
  head_case reset move "cat > f.sh <<'EOF'\\ngit commit -m y &\\nEOF"
  # shortcut kept by design: a shell `&` job is judged by HEAD at PostToolUse, like any call
  head_case reset move 'sh -c \"sleep 2; git commit -m y\" >/dev/null 2>&1 &'
  head_case kept stay 'sh -c \"sleep 2; git commit -m y\" >/dev/null 2>&1 &'
  head_case reset move 'sh -c \"git commit -m y &\"'
  # `&&` and redirections are not background jobs
  head_case kept stay 'git log 2>&1 | grep commit && echo git commit'
  head_case kept stay 'git log &>/dev/null; echo git commit'
  # a spelling the subcommand test misses resets when HEAD moved
  head_case reset move 'sh -c \"git commit -m y\"'
  head_case reset move 'echo git commit'
  # a commit undone in the same call leaves HEAD where it was but grows the reflog
  printf '1\n' > "$count"
  "$hc" '{"hook_event_name":"PreToolUse","tool_name":"Bash","tool_use_id":"toolu_h1","tool_input":{"command":"sh -c \"git commit -m y && git reset --soft HEAD^\""}}' >/dev/null
  git commit -q --allow-empty -m "8c undone" >/dev/null 2>&1 && git reset -q --soft HEAD^ >/dev/null 2>&1
  "$hc" '{"hook_event_name":"PostToolUse","tool_name":"Bash","tool_use_id":"toolu_h1","tool_input":{"command":"sh -c \"git commit -m y && git reset --soft HEAD^\""}}' >/dev/null
  [ ! -f "$count" ] && pass "8c $hc: commit undone in the same call -> reset" || fail "8c $hc: commit undone in the same call -> reset"
  head_case kept stay 'sh -c \"git commit -m y\"'
  # a call sent to the background reports before its commit has run: reset regardless
  head_case reset stay 'sh -c \"git commit -m y\"' ',"tool_response":{"backgroundTaskId":"b1"}'
  # no PreToolUse record for this call: in doubt, reset
  printf '1\n' > "$count"
  "$hc" '{"hook_event_name":"PostToolUse","tool_name":"Bash","tool_use_id":"toolu_h2","tool_input":{"command":"git log | grep commit"}}' >/dev/null
  [ ! -f "$count" ] && pass "8c $hc: no HEAD record -> reset" || fail "8c $hc: no HEAD record -> reset"
  # a call id only jq decodes (repeated, escaped key): the awk reader refuses it, so without
  # jq there is no record and, in doubt, a reset; jq reads it, so the cycle is kept. A nested
  # id alone is no id either way.
  _x=kept; { [ "$hc" = nojq_run ] || ! command -v jq >/dev/null 2>&1; } && _x=reset
  for ids in '"tool_use_id":"toolu_h1","tool_use_id":"toolu_h1",' '"tool_\u0075se_id":"toolu_h1",' ''; do
    [ -n "$ids" ] || _x=reset
    printf '1\n' > "$count"
    "$hc" "{\"hook_event_name\":\"PreToolUse\",\"tool_name\":\"Bash\",$ids\"tool_input\":{\"command\":\"git log | grep commit\"}}" >/dev/null
    "$hc" "{\"hook_event_name\":\"PostToolUse\",\"tool_name\":\"Bash\",$ids\"tool_input\":{\"command\":\"git log | grep commit\"},\"tool_response\":{\"tool_use_id\":\"toolu_h1\"}}" >/dev/null
    if [ -f "$count" ]; then _got=kept; else _got=reset; fi
    [ "$_got" = "$_x" ] && pass "8c $hc: call id [$ids] -> $_x" || fail "8c $hc: call id [$ids] -> $_x (got $_got)"
  done
  rm -f .context/codex-gate.headPre.*
done
reset_all
for r in run nojq_run; do
  out=$("$r" '{"hook_event_name":"PreToolUse","tool_name":"Bash","tool_input":{"command":"git \\\ncommit -m y"}}')
  printf '%s' "$out" | grep -q 'Gate B' && pass "8c $r: commit split over lines -> reminder" || fail "8c $r: commit split over lines -> reminder"
  out=$("$r" '{"hook_event_name":"PreToolUse","tool_name":"Bash","tool_input":{"command":"cd \"a b\" && git commit -m y"}}')
  printf '%s' "$out" | grep -q 'Gate B' && pass "8c $r: escaped quote before the commit -> reminder" || fail "8c $r: escaped quote before the commit -> reminder"
done
reset_all

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
printf 'spec\n' > docs/plan.md; printf 'readme\n' > README.md
git add docs/plan.md README.md >/dev/null 2>&1
out=$(commitpre)
printf '%s' "$out" | grep -q 'docs-only commit' && pass "docs-only staged -> N/A note" || fail "docs-only staged -> N/A note"
printf '%s' "$out" | grep -q 'Codex gate state:' && fail "docs-only must not emit the gate-state reminder" || pass "docs-only does not emit the gate-state reminder"
# Docs-only is the rule's allow-list, not any .md: other Markdown fires
for p in NOTES.md src/prompts/system.md; do
  mkdir -p "$(dirname "$p")"; printf 'x\n' > "$p"; git add "$p" >/dev/null 2>&1
  out=$(commitpre)
  printf '%s' "$out" | grep -q 'docs-only commit' && fail "$p is not docs-only" || pass "$p is not docs-only"
  git rm -q --cached "$p" >/dev/null 2>&1; rm -f "$p"
done
rm -rf src
# A command that stages or names paths itself is judged before they are staged: it fires
# shellcheck disable=SC2016  # the $( ) is payload text for the hook, never expanded here
for c in 'git add extra.ts && git commit -m x' 'git commit -m x docs/plan.md extra.ts' 'git commit -m x -- extra.ts' "git commit -m 'x y' extra.ts" \
         'git commit -mfixit extra.ts' 'git commit -m x --pathspec-from-file=p' 'git -C . add extra.ts && git commit -m x' \
         "git commit -m \\\"don't\\\" extra.ts -m \\\"don't\\\"" 'git commit -m \"$(git add extra.ts)\"' \
         'git commit -am docs>extra.ts' 'git commit -m *'; do
  out=$(run "{\"hook_event_name\":\"PreToolUse\",\"tool_name\":\"Bash\",\"tool_input\":{\"command\":\"$c\"}}")
  printf '%s' "$out" | grep -q 'docs-only commit' && fail "'$c' is not docs-only" || pass "'$c' is not docs-only"
done
# jq-free, the decoded command keeps the path after the quoted message, so it is not docs-only
out=$(nojq_run '{"hook_event_name":"PreToolUse","tool_name":"Bash","tool_input":{"command":"git commit -m \"fix\" extra.ts"}}')
printf '%s' "$out" | grep -q 'docs-only commit' && fail "jq-free: quoted message plus path is not docs-only" || pass "jq-free: quoted message plus path is not docs-only"
out=$(run "{\"hook_event_name\":\"PreToolUse\",\"tool_name\":\"Bash\",\"tool_input\":{\"command\":\"git commit -m 'plain docs'\"}}")
printf '%s' "$out" | grep -q 'docs-only commit' && pass "plain quoted message, docs staged -> N/A note" || fail "plain quoted message, docs staged -> N/A note"
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
git rm -q --cached docs/plan.md README.md >/dev/null 2>&1
rm -f README.md docs/plan.md; rmdir docs 2>/dev/null
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
# 16a. `intake` and `ticket` keep the count: their change-record, list and show forms run
#      inside an open cycle, where a reset would hide a pending cap stop
for s in dev-workflow:intake dev-workflow:ticket; do
  rm -f "$countA"; execp
  run "{\"hook_event_name\":\"PostToolUse\",\"tool_name\":\"Skill\",\"tool_input\":{\"skill\":\"$s\"}}" >/dev/null
  [ "$(cat "$countA" 2>/dev/null)" = 1 ] && pass "$s keeps Gate A count" || fail "$s keeps Gate A count"
done
# 16b. A non-WIP commit closes the Gate-A count too (a WIP commit keeps it: see kept() in 19d)
execp; commitpost
[ ! -f "$countA" ] && pass "non-WIP commit resets Gate A count" || fail "non-WIP commit resets Gate A count"
# 16c. ...but the closing act's commit precedes plan execution, so the floor check still
#      sees the closed cycle's passes, the cap check does not, and plan execution clears both
rm -f "$countA" "$countA.closed"; execp; execp; execp; commitpost
out=$(run '{"hook_event_name":"PreToolUse","tool_name":"Skill","tool_input":{"skill":"superpowers:executing-plans"}}')
printf '%s' "$out" | grep -q 'floor met' && pass "closing commit, then executing-plans -> Gate A floor met" || fail "closing commit, then executing-plans -> Gate A floor met"
execp; out=$(run '{"hook_event_name":"PreToolUse","tool_name":"Skill","tool_input":{"skill":"superpowers:executing-plans"}}')
printf '%s' "$out" | grep -q '1/3' && pass "a pass after the closing commit counts from zero" || fail "a pass after the closing commit counts from zero"
run '{"hook_event_name":"PostToolUse","tool_name":"Skill","tool_input":{"skill":"superpowers:executing-plans"}}' >/dev/null
[ ! -f "$countA" ] && [ ! -f "$countA.closed" ] && pass "plan execution clears the closed Gate A count" || fail "plan execution clears the closed Gate A count"
# A cycle closed AT the cap: the floor check sees it met, and no cap stop reads the closed count
rm -f "$countA" "$countA.closed"; execp; execp; execp; execp; execp; commitpost
out=$(run '{"hook_event_name":"PreToolUse","tool_name":"Skill","tool_input":{"skill":"superpowers:executing-plans"}}')
printf '%s' "$out" | grep -q 'floor met' && ! printf '%s' "$out" | grep -q 'pass cap reached' && pass "closed at the cap -> floor met, no cap stop" || fail "closed at the cap -> floor met, no cap stop"
rm -f "$countA.closed"
# 16e. writing-plans sets the earlier Gate-A count aside: a plan with no exec call since then
#      gets the conditional reminder (needed only at risk high), not "below floor"; a plan
#      Gate A, closed or open, is checked against the floor as before
planexec() { run '{"hook_event_name":"PreToolUse","tool_name":"Skill","tool_input":{"skill":"superpowers:executing-plans"}}'; }
writeplans() { run '{"hook_event_name":"PostToolUse","tool_name":"Skill","tool_input":{"skill":"superpowers:writing-plans"}}' >/dev/null; }
rm -f "$countA" "$countA.closed" "$countA.spec"; execp; execp; execp; commitpost; writeplans
[ ! -f "$countA" ] && [ ! -f "$countA.closed" ] && [ "$(cat "$countA.spec" 2>/dev/null)" = 3 ] && pass "writing-plans sets the closed spec count aside" || fail "writing-plans sets the closed spec count aside"
out=$(planexec)
printf '%s' "$out" | grep -q 'none on this plan' && printf '%s' "$out" | grep -q 'before it 3/3' && ! printf '%s' "$out" | grep -q 'below floor' \
  && pass "standard plan after a closed spec Gate A -> conditional reminder, not below floor" || fail "standard plan after a closed spec Gate A -> conditional reminder, not below floor"
printf '%s' "$out" | grep -q 'risk is high' && pass "conditional reminder names the high-risk case" || fail "conditional reminder names the high-risk case"
execp; out=$(planexec)
printf '%s' "$out" | grep -q 'below floor (1/3)' && pass "plan Gate A 1/3 after writing-plans -> below floor" || fail "plan Gate A 1/3 after writing-plans -> below floor"
execp; execp; commitpost; out=$(planexec)
printf '%s' "$out" | grep -q 'floor met (3/3' && pass "closed plan Gate A 3/3 -> floor met" || fail "closed plan Gate A 3/3 -> floor met"
run '{"hook_event_name":"PostToolUse","tool_name":"Skill","tool_input":{"skill":"superpowers:executing-plans"}}' >/dev/null
[ ! -f "$countA.spec" ] && pass "plan execution clears the set-aside count" || fail "plan execution clears the set-aside count"
rm -f "$countA" "$countA.closed" "$countA.spec"; execp; writeplans
[ "$(cat "$countA.spec" 2>/dev/null)" = 1 ] && pass "writing-plans sets an open count aside" || fail "writing-plans sets an open count aside"
out=$(planexec)
printf '%s' "$out" | grep -q 'before it 1/3' && pass "open spec count 1/3 is named in the reminder" || fail "open spec count 1/3 is named in the reminder"
rm -f "$countA" "$countA.closed" "$countA.spec"; writeplans; out=$(planexec)
[ ! -f "$countA.spec" ] && printf '%s' "$out" | grep -q 'below floor (0/3)' && pass "no Gate A at all -> below floor 0/3" || fail "no Gate A at all -> below floor 0/3"
execp; execp; execp; commitpost; writeplans
out=$(nojq_run '{"hook_event_name":"PreToolUse","tool_name":"Skill","tool_input":{"skill":"superpowers:executing-plans"}}')
printf '%s' "$out" | grep -q 'none on this plan' && printf '%s' "$out" | grep -q 'before it 3/3' && pass "jq-free: conditional plan reminder" || fail "jq-free: conditional plan reminder"
rm -f "$countA" "$countA.closed" "$countA.spec"
execp; writeplans; run '{"hook_event_name":"PostToolUse","tool_name":"Skill","tool_input":{"skill":"superpowers:brainstorming"}}' >/dev/null
[ ! -f "$countA.spec" ] && pass "brainstorming clears the set-aside count" || fail "brainstorming clears the set-aside count"
# 16d. A count file that is not a number reads as 0: never a false floor-met, never a
#      shell arithmetic error (exit non-zero) when bumped
: > "$countA"
out=$(run '{"hook_event_name":"PreToolUse","tool_name":"Skill","tool_input":{"skill":"superpowers:executing-plans"}}')
printf '%s' "$out" | grep -q '0/3' && pass "empty Gate A count -> below floor 0/3" || fail "empty Gate A count -> below floor 0/3"
printf '1\n2\n' > "$countA"
out=$(run '{"hook_event_name":"PreToolUse","tool_name":"Skill","tool_input":{"skill":"superpowers:executing-plans"}}')
printf '%s' "$out" | grep -q '0/3' && pass "two-line Gate A count -> 0, not 12" || fail "two-line Gate A count -> 0, not 12"
printf '08' > "$countA"; execp; rc=$?
[ "$rc" = 0 ] && [ "$(cat "$countA")" = 9 ] && pass "count 08 bumps to 9, exit 0" || fail "count 08 bumps to 9, exit 0"
printf '<<<<<<< HEAD\n3\n' > "$countA"; execp; rc=$?
[ "$rc" = 0 ] && [ "$(cat "$countA")" = 1 ] && pass "conflict text in count -> bumps from 0, exit 0" || fail "conflict text in count -> bumps from 0, exit 0"
rm -f "$countA"; mkfifo "$countA"   # never read: `cat` on a FIFO blocks (a hang here is the failure)
out=$(run '{"hook_event_name":"PreToolUse","tool_name":"Skill","tool_input":{"skill":"superpowers:executing-plans"}}')
printf '%s' "$out" | grep -q '0/3' && pass "FIFO Gate A count -> not read, below floor 0/3" || fail "FIFO Gate A count -> not read, below floor 0/3"
rm -f "$countA"

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
wip() { run "{\"hook_event_name\":\"PreToolUse\",\"tool_name\":\"Bash\",\"tool_use_id\":\"${2:-toolu_t1}\",\"tool_input\":{\"command\":\"$1\"}}"; }
out=$(wip "git commit -m 'wip: pre-review snapshot'")
printf '%s' "$out" | grep -q 'Codex gate state:' && fail "WIP commit must not emit the gate-state reminder" || pass "WIP commit does not emit the gate-state reminder"
printf '%s' "$out" | grep -q 'WIP commit' && pass "WIP commit -> gentle note" || fail "WIP commit -> gentle note"
out=$(wip "git commit -m 'WIP: caps variant'")
printf '%s' "$out" | grep -q 'WIP commit' && pass "WIP matcher is case-insensitive" || fail "WIP matcher is case-insensitive"
# PostToolUse: a WIP commit must PRESERVE the counters (the cycle is still open). Since
# 0.13.3 PostToolUse reads the commit that resulted, so a WIP commit is made for real here
# (empty, so no fingerprint input moves) and undone afterwards.
wip "git commit -m 'wip: snapshot'" >/dev/null
git commit -q --allow-empty -m 'wip: snapshot' >/dev/null 2>&1
run '{"hook_event_name":"PostToolUse","tool_name":"Bash","tool_use_id":"toolu_t1","tool_input":{"command":"git commit -m \"wip: snapshot\""}}' >/dev/null
[ "$(cat "$count" 2>/dev/null)" = 2 ] && pass "WIP commit preserves pass count (Finding 11)" || fail "WIP commit preserves pass count (Finding 11)"
[ -f "$state" ] && pass "WIP commit preserves Gate B state" || fail "WIP commit preserves Gate B state"
git reset -q --soft HEAD~1 >/dev/null 2>&1
# ...and the same command on a HEAD that is not WIP (the commit did not happen, or a hook
# rewrote it) resets
rev
run '{"hook_event_name":"PostToolUse","tool_name":"Bash","tool_input":{"command":"git commit -m \"wip: snapshot\""}}' >/dev/null
[ ! -f "$count" ] && pass "-m wip with a non-WIP HEAD afterwards resets" || fail "-m wip with a non-WIP HEAD afterwards resets"
reset_all; rev; rev
# A real (non-WIP) commit still resets
commitpost
[ ! -f "$count" ] && pass "non-WIP commit still resets counters" || fail "non-WIP commit still resets counters"
# A `(WIP)` suffix is not a WIP commit: the PR #69 cycle read "1/3" after three passes this way
reset_all; rev; rev
wip "git commit -m 'pass 1 fixes (WIP)'" >/dev/null
git commit -q --allow-empty -m 'pass 1 fixes (WIP)' >/dev/null 2>&1
run '{"hook_event_name":"PostToolUse","tool_name":"Bash","tool_use_id":"toolu_t1","tool_input":{"command":"git commit -m \"pass 1 fixes (WIP)\""}}' >/dev/null
[ ! -f "$count" ] && pass "(WIP) suffix commit resets counters" || fail "(WIP) suffix commit resets counters"
git reset -q --soft HEAD~1 >/dev/null 2>&1

# 19b. `git commit --amend --no-edit` on a WIP HEAD keeps the WIP message, so it is
# cycle-internal too — but it carries no `-m`, and a command-string match alone reset it.
# The empty commit keeps HEAD's tree, so no fingerprint input moves; it is undone below.
git commit -q --allow-empty -m 'WIP: snapshot' >/dev/null 2>&1
amendpost() { run "{\"hook_event_name\":\"PostToolUse\",\"tool_name\":\"Bash\",\"tool_use_id\":\"${2:-toolu_t1}\",\"tool_input\":{\"command\":\"$1\"}}" >/dev/null; }
reset_all; rev; rev
out=$(wip "git commit --amend --no-edit")
printf '%s' "$out" | grep -q 'Codex cycle decided after' && pass "amend --no-edit on WIP HEAD -> WIP note" || fail "amend --no-edit on WIP HEAD -> WIP note"
amendpost "git commit --amend --no-edit"
[ "$(cat "$count" 2>/dev/null)" = 2 ] && [ -f "$state" ] && pass "amend --no-edit on WIP HEAD preserves the cycle" || fail "amend --no-edit on WIP HEAD preserves the cycle"
# A new message is a closing act (or a stray commit) and still resets
amendpost "git commit --amend --no-edit -m 'real message'"
[ ! -f "$count" ] && pass "amend with -m on WIP HEAD still resets" || fail "amend with -m on WIP HEAD still resets"
# Forms outside the allow-list: message flags (quoted, split, abbreviated, -e/--edit), another
# repository, a comment, a pathspec decoy, --no-amend cancelling --amend, and any global
# `git -c` (its operand can expand into `-C <repo>` or strip the WIP subject via cleanup).
# Since 0.37.3 a call that leaves HEAD and its reflog unchanged keeps the cycle whatever its
# text, so each runs with HEAD replaced by an amend; then only the command decides here.
for c in "git commit --amend --no-edit '-m' 'real'" "git commit --amend --no-edit --mes=real" "git commit --amend --no-edit --edit" \
         "git commit --amend --no-edit -e" "git -C /elsewhere commit --amend --no-edit" "cd /elsewhere && git commit --amend --no-edit" \
         "git commit --amend --no-edit -''m real" "git commit --amend # --no-edit" "git commit ./file--amend--no-edit" \
         "git commit --amend --no-edit --no-amend" "git -c {core.quotePath=false,-C,/elsewhere} commit --amend --no-edit" \
         "git -c core.quotePath=false commit --amend --no-edit"; do
  reset_all; rev
  printf '%s' "$(wip "$c")" | grep -q 'Codex cycle decided after' && fail "not WIP: $c" || pass "not WIP: $c"
  git commit -q --allow-empty --amend --no-edit >/dev/null 2>&1
  amendpost "$c"
  [ ! -f "$count" ] && pass "resets: $c" || fail "resets: $c"
done
# A custom comment character lets cleanup strip the WIP line, so the plain form is refused too
git config core.commentChar W
reset_all; rev
printf '%s' "$(wip "git commit --amend --no-edit")" | grep -q 'Codex cycle decided after' && fail "custom commentChar: no WIP note" || pass "custom commentChar: no WIP note"
git commit -q --allow-empty --amend --no-edit >/dev/null 2>&1
amendpost "git commit --amend --no-edit"
[ ! -f "$count" ] && pass "custom commentChar: resets" || fail "custom commentChar: resets"
git config --unset core.commentChar
# Without jq the decoded command keeps the quoted `"-m"`, and the quote must still decline
# the exemption. (JSON: \" inside the command string.)
reset_all; rev
out=$(nojq_run '{"hook_event_name":"PreToolUse","tool_name":"Bash","tool_input":{"command":"git commit --amend --no-edit \"-m\" \"real\""}}')
printf '%s' "$out" | grep -q 'Codex cycle decided after' && fail "jq-free: double-quoted -m gets no WIP note" || pass "jq-free: double-quoted -m gets no WIP note"
nojq_run '{"hook_event_name":"PostToolUse","tool_name":"Bash","tool_input":{"command":"git commit --amend --no-edit \"-m\" \"real\""}}' >/dev/null
[ ! -f "$count" ] && pass "jq-free: double-quoted -m still resets" || fail "jq-free: double-quoted -m still resets"
# 19c. The real lifecycle: PreToolUse, an ACTUAL `git commit --amend --no-edit`, PostToolUse.
# Git refuses to amend an empty commit into an empty one, so 19b's empty WIP commit is
# replaced by one that adds a file; it is removed again below. Hook scripts live in the git
# dir or the sandbox, never in the worktree.
# These cases write hook scripts into a fresh hooks directory. The suite's empty template
# means `git init` made none, but whatever is there is moved aside (mv moves a link, never
# its target) and restored below, so no write can reach a directory outside this repo.
git reset -q --soft HEAD~1 >/dev/null 2>&1
printf 'wip\n' > wip.txt; git add wip.txt >/dev/null 2>&1; git commit -q -m 'WIP: snapshot' >/dev/null 2>&1
hooksd=$(git rev-parse --git-path hooks)
if [ "$hooksd" = "$(git rev-parse --git-dir)/hooks" ] && { [ ! -e "$hooksd" ] && [ ! -L "$hooksd" ] || mv "$hooksd" "$sandbox/orig-hooks"; } \
   && mkdir "$hooksd"; then :; else
  # The cases below run real commits, which would execute whatever hooks that directory holds
  fail "19c: could not set up the test repo's own hooks directory ($hooksd); aborting the suite"
  exit 1
fi
# shellcheck disable=SC2016  # $1 belongs to the git hook, expanded when git runs it
rewrite_hook='#!/bin/sh
printf "real subject\n" > "$1"
'
lifecycle() { # runs one real amend between the two hook events; leaves $pre, $subj, $moved
  reset_all; rev; rev
  pre=$(wip "git commit --amend --no-edit")
  before=$(git rev-parse HEAD)
  # A same-second amend of an unchanged tree recreates the same commit, so stage a change
  printf 'x\n' >> wip.txt; git add wip.txt >/dev/null 2>&1
  git commit -q --amend --no-edit >/dev/null 2>&1
  [ "$(git rev-parse HEAD)" != "$before" ] && moved=yes || moved=no
  subj=$(git log -1 --format=%s)
  amendpost "git commit --amend --no-edit"
}
# (a) no hooks at all: the amend keeps the WIP subject and the cycle survives
lifecycle
printf '%s' "$pre" | grep -q 'Codex cycle decided after' && [ "$moved" = yes ] && [ "$subj" = 'WIP: snapshot' ] && [ "$(cat "$count" 2>/dev/null)" = 2 ] \
  && pass "real amend, no hooks: WIP note, subject kept, cycle preserved" || fail "real amend, no hooks: WIP note, subject kept, cycle preserved"
# (a2) *.sample files are the one thing the hooks directory may hold
printf '#!/bin/sh\nexit 1\n' > "$hooksd/commit-msg.sample"; chmod +x "$hooksd/commit-msg.sample"
lifecycle
printf '%s' "$pre" | grep -q 'Codex cycle decided after' && [ "$moved" = yes ] && [ "$(cat "$count" 2>/dev/null)" = 2 ] \
  && pass "real amend, only *.sample hooks: cycle preserved" || fail "real amend, only *.sample hooks: cycle preserved"
rm -f "$hooksd/commit-msg.sample"
# (b) an amend aborted with no hook present (a held index lock) leaves HEAD WIP: cycle kept
: > "$(git rev-parse --git-dir)/index.lock"
lifecycle
rm -f "$(git rev-parse --git-dir)/index.lock"
printf '%s' "$pre" | grep -q 'Codex cycle decided after' && [ "$moved" = no ] && [ "$subj" = 'WIP: snapshot' ] && [ "$(cat "$count" 2>/dev/null)" = 2 ] \
  && pass "aborted real amend, no hooks: cycle preserved" || fail "aborted real amend, no hooks: cycle preserved"
# (b2) Before PR #30's review this case expected preservation: a pre-commit hook that
# aborts. Under the any-hook rule its mere presence refuses the exemption; since 0.37.3 the
# aborted amend left HEAD and its reflog unchanged, so the cycle is kept anyway.
printf '#!/bin/sh\nexit 1\n' > "$hooksd/pre-commit"; chmod +x "$hooksd/pre-commit"
lifecycle
{ printf '%s' "$pre" | grep -q 'Codex cycle decided after'; } && fail "pre-commit hook present: no WIP note" || pass "pre-commit hook present: no WIP note"
[ "$moved" = no ] && [ "$(cat "$count" 2>/dev/null)" = 2 ] && pass "pre-commit hook present, amend aborted: cycle kept" || fail "pre-commit hook present, amend aborted: cycle kept"
rm -f "$hooksd/pre-commit"
# (f) a pre-commit hook that installs a rewriting prepare-commit-msg mid-commit
printf '%s' "$rewrite_hook" > "$sandbox/rewrite-hook"
printf '#!/bin/sh\ncp "%s" "%s/prepare-commit-msg" && chmod +x "%s/prepare-commit-msg"\n' "$sandbox/rewrite-hook" "$hooksd" "$hooksd" > "$hooksd/pre-commit"
chmod +x "$hooksd/pre-commit"
lifecycle
{ printf '%s' "$pre" | grep -q 'Codex cycle decided after'; } && fail "pre-commit installing a message hook: no WIP note" || pass "pre-commit installing a message hook: no WIP note"
[ "$subj" = 'real subject' ] && [ ! -f "$count" ] && pass "pre-commit installing a message hook: subject rewritten, cycle reset" || fail "pre-commit installing a message hook: subject rewritten, cycle reset"
rm -f "$hooksd/pre-commit" "$hooksd/prepare-commit-msg" "$sandbox/rewrite-hook"; git commit -q --amend -m 'WIP: snapshot' >/dev/null 2>&1
# (c) prepare-commit-msg rewrites the subject into a real one: no WIP note before, reset after
printf '%s' "$rewrite_hook" > "$hooksd/prepare-commit-msg"; chmod +x "$hooksd/prepare-commit-msg"
lifecycle
{ printf '%s' "$pre" | grep -q 'Codex cycle decided after'; } && fail "message hook: no WIP note before the amend" || pass "message hook: no WIP note before the amend"
[ "$subj" = 'real subject' ] && [ ! -f "$count" ] && pass "message hook: subject rewritten, cycle reset" || fail "message hook: subject rewritten, cycle reset"
rm -f "$hooksd/prepare-commit-msg"; git commit -q --amend -m 'WIP: snapshot' >/dev/null 2>&1
# (d) commit-msg rejects the amend: a message hook is present, but no commit happened, so kept
printf '#!/bin/sh\nexit 1\n' > "$hooksd/commit-msg"; chmod +x "$hooksd/commit-msg"
lifecycle
{ printf '%s' "$pre" | grep -q 'Codex cycle decided after'; } && fail "rejecting commit-msg: no WIP note" || pass "rejecting commit-msg: no WIP note"
[ "$moved" = no ] && [ "$subj" = 'WIP: snapshot' ] && [ "$(cat "$count" 2>/dev/null)" = 2 ] && pass "rejecting commit-msg: HEAD still WIP, cycle kept" || fail "rejecting commit-msg: HEAD still WIP, cycle kept"
rm -f "$hooksd/commit-msg"
# (e) any core.hooksPath refuses the exemption; this one also rewrites the subject
mkdir -p "$sandbox/hooks"
printf '%s' "$rewrite_hook" > "$sandbox/hooks/prepare-commit-msg"; chmod +x "$sandbox/hooks/prepare-commit-msg"
git config core.hooksPath "$sandbox/hooks"
lifecycle
{ printf '%s' "$pre" | grep -q 'Codex cycle decided after'; } && fail "core.hooksPath message hook: no WIP note" || pass "core.hooksPath message hook: no WIP note"
[ "$subj" = 'real subject' ] && [ ! -f "$count" ] && pass "core.hooksPath message hook: subject rewritten, cycle reset" || fail "core.hooksPath message hook: subject rewritten, cycle reset"
git config --unset core.hooksPath; rm -rf "$sandbox/hooks"; git commit -q --amend -m 'WIP: snapshot' >/dev/null 2>&1
# a hooksPath ending in a newline is refused too, not resolved to a neighbouring directory
git config core.hooksPath "$sandbox/nl
"
reset_all; rev
[ "$(git log -1 --format=%s)" = 'WIP: snapshot' ] && ! { printf '%s' "$(wip "git commit --amend --no-edit")" | grep -q 'Codex cycle decided after'; } \
  && pass "newline-ending core.hooksPath on a WIP HEAD: no WIP note" || fail "newline-ending core.hooksPath on a WIP HEAD: no WIP note"
git config --unset core.hooksPath
# 19d. The `-m "wip…"` path, as real commits: PreToolUse, the command itself, PostToolUse.
# Commands use single quotes so they embed in the JSON payload as they are.
base19d=$(git rev-parse HEAD)
mlife() { # $1 = the command; runs it for real between the two hook events
  reset_all; rev; rev; execp
  pre=$(wip "$1")
  before=$(git rev-parse HEAD)
  printf 'x\n' >> wip.txt; git add wip.txt >/dev/null 2>&1
  sh -c "$1" >/dev/null 2>&1
  [ "$(git rev-parse HEAD)" != "$before" ] && moved=yes || moved=no
  subj=$(git log -1 --format=%s)
  amendpost "$1"
}
noted() { printf '%s' "$pre" | grep -q 'Codex cycle decided after'; }
kept() { [ "$(cat "$count" 2>/dev/null)" = 2 ] && [ "$(cat "$countA" 2>/dev/null)" = 1 ]; }
# (m1) plain `-m 'WIP…'`, no hooks: note before, commit is WIP, cycle kept
mlife "git commit -q -m 'WIP: next'"
noted && [ "$moved" = yes ] && [ "$subj" = 'WIP: next' ] && kept && pass "-m wip, no hooks: note, WIP commit, cycle kept" || fail "-m wip, no hooks: note, WIP commit, cycle kept"
# (m2) a hook that leaves the message alone: reminder before (it could have), cycle kept after
printf '#!/bin/sh\nexit 0\n' > "$hooksd/pre-commit"; chmod +x "$hooksd/pre-commit"
mlife "git commit -q -m 'WIP: next'"
! noted && [ "$moved" = yes ] && [ "$subj" = 'WIP: next' ] && kept && pass "-m wip, harmless hook: reminder before, cycle kept" || fail "-m wip, harmless hook: reminder before, cycle kept"
rm -f "$hooksd/pre-commit"
# (m3) a hook rewrites the WIP message into a real one: reminder before, reset after
printf '%s' "$rewrite_hook" > "$hooksd/prepare-commit-msg"; chmod +x "$hooksd/prepare-commit-msg"
mlife "git commit -q -m 'WIP: next'"
! noted && [ "$subj" = 'real subject' ] && [ ! -f "$count" ] && pass "-m wip rewritten by a hook: reminder before, reset after" || fail "-m wip rewritten by a hook: reminder before, reset after"
rm -f "$hooksd/prepare-commit-msg"; git commit -q --amend -m 'WIP: snapshot' >/dev/null 2>&1
# (m4) the commit fails with a WIP HEAD already there: no boundary, cycle kept
: > "$(git rev-parse --git-dir)/index.lock"
mlife "git commit -q -m 'WIP: next'"
rm -f "$(git rev-parse --git-dir)/index.lock"
noted && [ "$moved" = no ] && kept && pass "-m wip that fails on a WIP HEAD: cycle kept" || fail "-m wip that fails on a WIP HEAD: cycle kept"
# (m4b) 0.37.3: a non-WIP commit that fails keeps the cycle; one that lands resets
: > "$(git rev-parse --git-dir)/index.lock"
mlife "git commit -q -m 'real'"
rm -f "$(git rev-parse --git-dir)/index.lock"
[ "$moved" = no ] && kept && pass "non-WIP commit that fails: cycle kept" || fail "non-WIP commit that fails: cycle kept"
mlife "git commit -q -m 'real'"
[ "$moved" = yes ] && [ ! -f "$count" ] && pass "non-WIP commit that lands: reset" || fail "non-WIP commit that lands: reset"
git commit -q --amend -m 'WIP: snapshot' >/dev/null 2>&1
# (m4c) 0.37.3: parentheses inside a single-quoted WIP subject are text, under both readers;
# inside double quotes they are still refused
for r in run nojq_run; do
  reset_all; rev; rev; execp
  pre=$($r "{\"hook_event_name\":\"PreToolUse\",\"tool_name\":\"Bash\",\"tool_use_id\":\"toolu_t1\",\"tool_input\":{\"command\":\"git commit -q -m 'WIP: x (y)'\"}}")
  printf 'x\n' >> wip.txt; git add wip.txt >/dev/null 2>&1; git commit -q -m 'WIP: x (y)' >/dev/null 2>&1
  $r "{\"hook_event_name\":\"PostToolUse\",\"tool_name\":\"Bash\",\"tool_use_id\":\"toolu_t1\",\"tool_input\":{\"command\":\"git commit -q -m 'WIP: x (y)'\"}}" >/dev/null
  noted && kept && pass "$r: -m 'WIP: x (y)': note, cycle kept" || fail "$r: -m 'WIP: x (y)': note, cycle kept"
  git commit -q --amend -m 'WIP: snapshot' >/dev/null 2>&1
  pre=$($r '{"hook_event_name":"PreToolUse","tool_name":"Bash","tool_use_id":"toolu_t2","tool_input":{"command":"git commit -q -m \"WIP: x (y)\""}}')
  ! noted && pass "$r: -m \"WIP: x (y)\" is still refused" || fail "$r: -m \"WIP: x (y)\" is still refused"
  pre=$($r '{"hook_event_name":"PreToolUse","tool_name":"Bash","tool_use_id":"toolu_t2","tool_input":{"command":"git commit -q -m \"WIP: x '"'"'(y)'"'"'\""}}')
  ! noted && pass "$r: apostrophes inside double quotes do not qualify ( )" || fail "$r: apostrophes inside double quotes do not qualify ( )"
  rm -f .context/codex-gate.headPre.* .context/codex-gate.wipBase.*
done
# (m5) chains either way round, and a first `-m` that is not WIP: reminder before; reset after
# when a commit landed, kept when git refused the command (`-m -m WIP`, `-F -m`)
for c in "git commit -q -m 'real' && git commit -q --allow-empty -m 'WIP: next'" \
         "git commit -q -m 'WIP: next' && git commit -q --allow-empty -m 'real'" \
         "git commit -q -m 'real' -m 'WIP: next'" "git commit -q -m -m WIP" \
         "git commit -q -m 'WIP: next' --fixup=HEAD" "git commit -q -F -m WIP"; do
  mlife "$c"
  if [ "$moved" = yes ]; then [ ! -f "$count" ]; else kept; fi && ! noted && pass "reminder, reset only if HEAD moved ($moved): $c" || fail "reminder, reset only if HEAD moved ($moved): $c"
  git commit -q --amend -m 'WIP: snapshot' >/dev/null 2>&1
done
# (m6) an editor could replace the message, so -e gets the reminder (not run: no editor here)
pre=$(wip "git commit -q -e -m 'WIP: next'")
! noted && pass "reminder before: -e with a WIP message" || fail "reminder before: -e with a WIP message"
# (m7) without jq the call id is read by the hook's awk reader, so the WIP commit keeps the
# cycle as it does with jq
reset_all; rev; rev
nojq_run "{\"hook_event_name\":\"PreToolUse\",\"tool_name\":\"Bash\",\"tool_use_id\":\"toolu_t1\",\"tool_input\":{\"command\":\"git commit -m 'WIP: next'\"}}" >/dev/null
git commit -q --allow-empty -m 'WIP: next' >/dev/null 2>&1
nojq_run "{\"hook_event_name\":\"PostToolUse\",\"tool_name\":\"Bash\",\"tool_use_id\":\"toolu_t1\",\"tool_input\":{\"command\":\"git commit -m 'WIP: next'\"}}" >/dev/null
[ "$(cat "$count" 2>/dev/null)" = 2 ] && pass "jq-free: -m wip keeps the cycle (call id read without jq)" || fail "jq-free: -m wip keeps the cycle (call id read without jq)"
# (m8) a post-commit hook that makes a real commit and then a WIP one: HEAD is WIP, but it
# no longer sits on the commit that was HEAD when the command started, so reset
printf '#!/bin/sh\ngit -c core.hooksPath=/dev/null commit -q --allow-empty -m real >/dev/null 2>&1\ngit -c core.hooksPath=/dev/null commit -q --allow-empty -m "WIP: from a hook" >/dev/null 2>&1\n' > "$hooksd/post-commit"
chmod +x "$hooksd/post-commit"
mlife "git commit -q -m 'WIP: next'"
[ "$subj" = 'WIP: from a hook' ] && [ ! -f "$count" ] && pass "-m wip, then a hook adds real + WIP commits: reset" || fail "-m wip, then a hook adds real + WIP commits: reset"
rm -f "$hooksd/post-commit"
# (m9) no record from PreToolUse (it never ran): the result cannot be attributed, so reset
reset_all; rev; rev
git commit -q --allow-empty -m 'WIP: next' >/dev/null 2>&1
amendpost "git commit -m 'WIP: next'"
[ ! -f "$count" ] && pass "-m wip with no PreToolUse record: reset" || fail "-m wip with no PreToolUse record: reset"
# (m10) --amend -m 'WIP…' keeps the cycle: the new HEAD shares the recorded parent
mlife "git commit -q --amend -m 'WIP: amended'"
[ "$moved" = yes ] && [ "$subj" = 'WIP: amended' ] && kept && [ ! -f .context/codex-gate.wipBase.toolu__t1 ] \
  && pass "--amend -m wip: same parent, cycle kept, record removed" || fail "--amend -m wip: same parent, cycle kept, record removed"
# (m11) a hook rewrites the WIP message to a real one, then amends that real commit back to
# WIP: the final HEAD still sits on the recorded HEAD, but the reflog grew by two, so reset
printf '%s' "$rewrite_hook" > "$hooksd/prepare-commit-msg"; chmod +x "$hooksd/prepare-commit-msg"
printf '#!/bin/sh\ngit -c core.hooksPath=/dev/null commit -q --allow-empty --amend -m "WIP: amended real" >/dev/null 2>&1\n' > "$hooksd/post-commit"
chmod +x "$hooksd/post-commit"
mlife "git commit -q -m 'WIP: next'"
[ "$subj" = 'WIP: amended real' ] && [ ! -f "$count" ] && pass "hook amends a real commit back to WIP: reset" || fail "hook amends a real commit back to WIP: reset"
rm -f "$hooksd/prepare-commit-msg" "$hooksd/post-commit"
# (m12) `--amend` inside the message is not the option: a hook that replaces HEAD with a WIP
# sibling must not pass as an amend
printf '#!/bin/sh\ngit reset -q --soft HEAD~2 >/dev/null 2>&1\ngit -c core.hooksPath=/dev/null commit -q --allow-empty -m "WIP: sibling" >/dev/null 2>&1\n' > "$hooksd/post-commit"
chmod +x "$hooksd/post-commit"
mlife "git commit -q -m 'WIP: --amend explained'"
[ "$subj" = 'WIP: sibling' ] && [ ! -f "$count" ] && pass "--amend inside the message is not an option: reset" || fail "--amend inside the message is not an option: reset"
rm -f "$hooksd/post-commit"; git commit -q --amend -m 'WIP: snapshot' >/dev/null 2>&1
# (m13) no HEAD reflog: a hook that makes a real commit and moves HEAD back would look like a
# failed commit, so without reflog evidence the exemption is refused and the cycle resets
gd=$(git rev-parse --git-dir)
mv "$gd/logs" "$sandbox/logs-aside"; git config core.logAllRefUpdates false
printf '%s' "$rewrite_hook" > "$hooksd/prepare-commit-msg"; chmod +x "$hooksd/prepare-commit-msg"
printf '#!/bin/sh\ngit reset -q --soft HEAD~1 >/dev/null 2>&1\n' > "$hooksd/post-commit"; chmod +x "$hooksd/post-commit"
mlife "git commit -q -m 'WIP: next'"
[ "$moved" = no ] && [ "$subj" = 'WIP: snapshot' ] && [ ! -f "$count" ] && pass "no HEAD reflog, real commit undone by a hook: reset" || fail "no HEAD reflog, real commit undone by a hook: reset"
rm -f "$hooksd/prepare-commit-msg" "$hooksd/post-commit"
git config --unset core.logAllRefUpdates; rm -rf "$gd/logs"; mv "$sandbox/logs-aside" "$gd/logs"
git commit -q --amend -m 'WIP: snapshot' >/dev/null 2>&1
# (m14) a corrupt record (a leading-zero count, read as octal by shell arithmetic) must neither
# make the hook fail nor keep the cycle
reset_all; rev; rev
printf '%s - 08 new\n' "$(git rev-parse HEAD)" > .context/codex-gate.wipBase.toolu__t1
git commit -q --allow-empty -m 'WIP: next' >/dev/null 2>&1
run '{"hook_event_name":"PostToolUse","tool_name":"Bash","tool_use_id":"toolu_t1","tool_input":{"command":"git commit -m '"'"'WIP: next'"'"'"}}' >/dev/null; rc=$?
[ "$rc" -eq 0 ] && [ ! -f "$count" ] && pass "corrupt record (08): exit 0 and reset" || fail "corrupt record (08): exit 0 and reset"
# (m15) a backgrounded Bash call: PostToolUse arrives before the commit ran, HEAD looks
# unchanged, and that is no evidence of a failed commit — reset
reset_all; rev; rev
wip "git commit -m 'WIP: next'" >/dev/null
run '{"hook_event_name":"PostToolUse","tool_name":"Bash","tool_use_id":"toolu_t1","tool_input":{"command":"git commit -m '"'"'WIP: next'"'"'","run_in_background":true},"tool_response":{"backgroundTaskId":"b1"}}' >/dev/null
[ ! -f "$count" ] && pass "backgrounded -m wip commit: reset" || fail "backgrounded -m wip commit: reset"
# (m16) overlapping calls, Greptile's order: A's Pre, A's commit, B's Pre, A's Post, B's
# commit, B's Post. Each call reads its own record, so both valid WIP commits keep the cycle
reset_all; rev; rev; execp
wip "git commit -q -m 'WIP: a'" toolu_a >/dev/null
git commit -q --allow-empty -m 'WIP: a' >/dev/null 2>&1
wip "git commit -q -m 'WIP: b'" toolu_b >/dev/null
amendpost "git commit -q -m 'WIP: a'" toolu_a
git commit -q --allow-empty -m 'WIP: b' >/dev/null 2>&1
amendpost "git commit -q -m 'WIP: b'" toolu_b
kept && pass "overlapping WIP calls each keep the cycle" || fail "overlapping WIP calls each keep the cycle"
# (m17) the other direction: a hook turns A's WIP commit into a real one, then B makes a WIP
# commit on top. A's decision must not come from B's record: A resets
reset_all; rev; rev
printf '%s' "$rewrite_hook" > "$hooksd/prepare-commit-msg"; chmod +x "$hooksd/prepare-commit-msg"
wip "git commit -q -m 'WIP: a'" toolu_a >/dev/null
git commit -q --allow-empty -m 'WIP: a' >/dev/null 2>&1
rm -f "$hooksd/prepare-commit-msg"
wip "git commit -q -m 'WIP: b'" toolu_b >/dev/null
git commit -q --allow-empty -m 'WIP: b' >/dev/null 2>&1
amendpost "git commit -q -m 'WIP: a'" toolu_a
[ ! -f "$count" ] && pass "A rewritten to real, B WIP on top: A's Post resets" || fail "A rewritten to real, B WIP on top: A's Post resets"
# (m18) an unusable call id gets no record, so the WIP commit resets
reset_all; rev; rev
wip "git commit -q -m 'WIP: c'" 'bad/id' >/dev/null
git commit -q --allow-empty -m 'WIP: c' >/dev/null 2>&1
amendpost "git commit -q -m 'WIP: c'" 'bad/id'
[ ! -f "$count" ] && ! ls .context/codex-gate.wipBase.* >/dev/null 2>&1 && pass "unusable call id: no record, reset" || fail "unusable call id: no record, reset"
# (m19) malformed ids that a lossy read would turn into a valid one: a trailing newline, and
# a number. Each must reset without reading or removing call B's record
for bad in '"toolu_b\n"' '123'; do
  reset_all; rev; rev
  printf '%s' "$rewrite_hook" > "$hooksd/prepare-commit-msg"; chmod +x "$hooksd/prepare-commit-msg"
  run "{\"hook_event_name\":\"PreToolUse\",\"tool_name\":\"Bash\",\"tool_use_id\":$bad,\"tool_input\":{\"command\":\"git commit -q -m 'WIP: a'\"}}" >/dev/null
  git commit -q --allow-empty -m 'WIP: a' >/dev/null 2>&1
  rm -f "$hooksd/prepare-commit-msg"
  wip "git commit -q -m 'WIP: b'" toolu_b >/dev/null
  git commit -q --allow-empty -m 'WIP: b' >/dev/null 2>&1
  run "{\"hook_event_name\":\"PostToolUse\",\"tool_name\":\"Bash\",\"tool_use_id\":$bad,\"tool_input\":{\"command\":\"git commit -q -m 'WIP: a'\"}}" >/dev/null
  [ ! -f "$count" ] && [ -f .context/codex-gate.wipBase.toolu__b ] && pass "malformed id $bad: reset, B's record untouched" || fail "malformed id $bad: reset, B's record untouched"
done
# (m20) without jq, a nested tool_use_id with no top-level one must not be taken for this
# call's id (the awk reader reads the top level only): reset, B untouched
reset_all; rev; rev
wip "git commit -q -m 'WIP: b'" toolu_b >/dev/null
git commit -q --allow-empty -m 'WIP: b' >/dev/null 2>&1
nojq_run '{"hook_event_name":"PostToolUse","tool_name":"Bash","tool_input":{"command":"git commit -q -m '"'"'WIP: b'"'"'"},"tool_response":{"tool_use_id":"toolu_b"}}' >/dev/null
[ ! -f "$count" ] && [ -f .context/codex-gate.wipBase.toolu__b ] && pass "nested-only id: reset, B's record untouched" || fail "nested-only id: reset, B's record untouched"
rm -f .context/codex-gate.wipBase.*
# (m21) ids differing only in letter case are different calls, also on a case-insensitive
# filesystem: A (toolu_A) is rewritten to real, B (toolu_a) makes a WIP commit on top; A resets
# and B's record survives
reset_all; rev; rev
printf '%s' "$rewrite_hook" > "$hooksd/prepare-commit-msg"; chmod +x "$hooksd/prepare-commit-msg"
wip "git commit -q -m 'WIP: a'" toolu_A >/dev/null
git commit -q --allow-empty -m 'WIP: a' >/dev/null 2>&1
rm -f "$hooksd/prepare-commit-msg"
wip "git commit -q -m 'WIP: b'" toolu_a >/dev/null
git commit -q --allow-empty -m 'WIP: b' >/dev/null 2>&1
amendpost "git commit -q -m 'WIP: a'" toolu_A
[ ! -f "$count" ] && [ -f .context/codex-gate.wipBase.toolu__a ] && pass "ids differing in case stay apart: A resets, B's record kept" || fail "ids differing in case stay apart: A resets, B's record kept"
rm -f .context/codex-gate.wipBase.*
# (m22) one leading `git add <plain words> &&` before the WIP commit keeps the cycle (0.41.0;
# canvas 2026-10-22, `34c4405`: the chain reset the count three times). The chain stages its own
# files; both readers. A path named `--amend` in the prefix is not the commit's option.
# $1 = runner, $2 = the command
clife() {
  reset_all; rev; rev; execp
  pre=$($1 "{\"hook_event_name\":\"PreToolUse\",\"tool_name\":\"Bash\",\"tool_use_id\":\"toolu_t22\",\"tool_input\":{\"command\":\"$2\"}}")
  before=$(git rev-parse HEAD)
  printf 'x\n' >> wip.txt; printf 'y\n' >> wip2.txt; printf 'z\n' >> 'wip 2.txt'; printf 'a\n' >> ./--amend
  sh -c "$2" >/dev/null 2>&1
  [ "$(git rev-parse HEAD)" != "$before" ] && moved=yes || moved=no
  subj=$(git log -1 --format=%s)
  $1 "{\"hook_event_name\":\"PostToolUse\",\"tool_name\":\"Bash\",\"tool_use_id\":\"toolu_t22\",\"tool_input\":{\"command\":\"$2\"}}" >/dev/null
}
for r in run nojq_run; do
  for c in "git add wip.txt && git commit -q -m 'WIP: c1'" "git add -A wip.txt && git commit -q -m 'WIP: c2'" \
           "git add wip.txt wip2.txt && git commit -q -m 'WIP: c3'" \
           "git add -- wip.txt && git commit -q --amend -m 'WIP: c4'" \
           "git add -- --amend && git commit -q -m 'WIP: c7'"; do
    clife "$r" "$c"
    noted && [ "$moved" = yes ] && [ "${subj#WIP: c}" != "$subj" ] && kept && pass "m22 $r: note, WIP commit, cycle kept: $c" || fail "m22 $r: note, WIP commit, cycle kept: $c"
  done
  # git add fails, so && skips the commit: HEAD and its reflog stay, so does the cycle
  clife "$r" "git add missing.ts && git commit -q -m 'WIP: c5'"
  noted && [ "$moved" = no ] && kept && pass "m22 $r: failed add, no commit, cycle kept" || fail "m22 $r: failed add, no commit, cycle kept"
  # refused: reminder before; each commits, so each resets
  # shellcheck disable=SC2016  # the $( ) is command text for the hook and sh -c
  for c in "git add 'wip 2.txt' && git commit -q -m 'WIP: r1'" "git add wip.txt; git commit -q -m 'WIP: r2'" \
           "git add wip.txt && git commit -q -m 'WIP: r3' && true" "git commit -q -am 'WIP: r4' && git add wip2.txt" \
           "git -C . add wip.txt && git commit -q -m 'WIP: r5'" "git add \$(echo wip.txt) && git commit -q -m 'WIP: r6'" \
           "git add wip.txt && git add wip2.txt && git commit -q -m 'WIP: r7'"; do
    clife "$r" "$c"
    [ "$moved" = yes ] && [ ! -f "$count" ] && ! noted && pass "m22 $r: refused, commit landed, reset: $c" || fail "m22 $r: refused, commit landed, reset: $c"
  done
  # a post-commit hook adds a second commit after the chained WIP one: the reflog grew by two, reset
  printf '#!/bin/sh\ngit -c core.hooksPath=/dev/null commit -q --allow-empty -m "WIP: from a hook" >/dev/null 2>&1\n' > "$hooksd/post-commit"
  chmod +x "$hooksd/post-commit"
  clife "$r" "git add wip.txt && git commit -q -m 'WIP: c6'"
  [ "$subj" = 'WIP: from a hook' ] && [ ! -f "$count" ] && pass "m22 $r: chained WIP, then a hook commits again: reset" || fail "m22 $r: chained WIP, then a hook commits again: reset"
  rm -f "$hooksd/post-commit"
  # (m23) the field shapes (2026-10-23/24: a chained WIP commit, hook count one short): a command
  # before the commit, one after it, and two lines. Each lands and resets; the sentence before it
  # names the shape and the consequence, and the count note gives the count still readable.
  for c in "true && git commit -q --allow-empty -m 'WIP: s1'" "git commit -q --allow-empty -m 'WIP: s2'; true"; do
    clife "$r" "$c"
    [ "$moved" = yes ] && [ ! -f "$count" ] && printf '%s' "$pre" | grep -qF 'a command chained before or after it' \
      && printf '%s' "$pre" | grep -qF 'Gate-B hook count before this commit: 2 credited' \
      && pass "m23 $r: chained WIP lands, reset, shape and count said: $c" || fail "m23 $r: chained WIP lands, reset, shape and count said: $c"
  done
  reset_all; rev; rev; execp
  pre=$($r '{"hook_event_name":"PreToolUse","tool_name":"Bash","tool_use_id":"toolu_t23","tool_input":{"command":"git add wip.txt\ngit commit -q -m '"'"'WIP: s3'"'"'"}}')
  before=$(git rev-parse HEAD); printf 'x\n' >> wip.txt
  git add wip.txt >/dev/null 2>&1; git commit -q -m 'WIP: s3' >/dev/null 2>&1
  $r '{"hook_event_name":"PostToolUse","tool_name":"Bash","tool_use_id":"toolu_t23","tool_input":{"command":"git add wip.txt\ngit commit -q -m '"'"'WIP: s3'"'"'"}}' >/dev/null
  [ "$(git rev-parse HEAD)" != "$before" ] && [ ! -f "$count" ] && printf '%s' "$pre" | grep -qF 'a second line' \
    && pass "m23 $r: two-line WIP commit lands, reset, shape said" || fail "m23 $r: two-line WIP commit lands, reset, shape said"
done
rm -f .context/codex-gate.wipBase.*
git rm -q --cached -- wip2.txt 'wip 2.txt' --amend >/dev/null 2>&1; rm -f wip2.txt 'wip 2.txt' ./--amend
git reset -q --soft "$base19d" >/dev/null 2>&1
git reset -q --soft HEAD~1 >/dev/null 2>&1; git rm -q --cached wip.txt >/dev/null 2>&1; rm -f wip.txt
rm -rf "$hooksd"; { [ -e "$sandbox/orig-hooks" ] || [ -L "$sandbox/orig-hooks" ]; } && mv "$sandbox/orig-hooks" "$hooksd"
# On a non-WIP HEAD the kept message is a real one, so the reset stands
reset_all; rev; rev
amendpost "git commit --amend --no-edit"
[ ! -f "$count" ] && pass "amend --no-edit on non-WIP HEAD still resets" || fail "amend --no-edit on non-WIP HEAD still resets"

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
printf '%s' "$out" | grep -qF 'no mcp__codex__review has been credited' \
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

# The count note every non-WIP commit check adds while the cycle has a Gate-B count (0.43.0)
cnote_ctx() { printf ' — Gate-B hook count before this commit: %s credited pass(es). If this commit lands, the hook clears it, so take the count for any comparison with your cycle line from this message: afterwards it cannot be read.' "$1"; }
cnote_msg() { printf ' ℹ Gate-B hook count before this commit: %s (cleared once it lands)' "$1"; }

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
expected_ctx="Codex gate state: the hook cannot confirm that the content you are about to commit is the content mcp__codex__review last saw (1 recorded pass(es) this cycle). Usually the working tree or the index changed since the review. Next: a fresh Gate-B pass, and when this cycle may run one is this project's review policy's closure ordering's, read there entire. If a fresh pass leaves this unchanged, other causes and checks: https://github.com/dsnger/dev-workflow-kit/blob/main/docs/reference.md#hook-messages. Per this project's review policy you MUST re-review after every fix."
expected_msg="⚠ Codex Gate B: cannot confirm reviewed content"
[ "$ctx" = "$expected_ctx$(cnote_ctx 1)" ] && pass "stale additionalContext matches exactly" || fail "stale additionalContext matches exactly"
[ "$msg" = "$expected_msg$(cnote_msg 1)" ] && pass "stale systemMessage matches exactly" || fail "stale systemMessage matches exactly"
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
[ "$ctx" = "$expected_ctx$(cnote_ctx 3)" ] && pass "hook-checks-passed additionalContext matches exactly" || fail "hook-checks-passed additionalContext matches exactly"
[ "$msg" = "$expected_msg$(cnote_msg 3)" ] && pass "hook-checks-passed systemMessage matches exactly" || fail "hook-checks-passed systemMessage matches exactly"

# 29c. EMPTY-STATE branch: no fingerprint recorded this cycle, default floor 3.
reset_all
out=$(commitpre)
ctx=$(json_field "$out" additionalContext)
msg=$(json_field "$out" systemMessage)
expected_ctx="Codex gate state: no fingerprint is recorded for this cycle. The hook cannot tell why; causes: https://github.com/dsnger/dev-workflow-kit/blob/main/docs/reference.md#hook-messages. The fingerprint is Gate B's (mcp__codex__review) alone; Gate A (mcp__codex__exec) passes are counted by call and never record one. What this cycle does next, the floor it owes included, is this project's review policy's closure ordering's, read there entire, and this reminder decides none of it. If this repeats, check that .context/ and the state file inside it are readable and writable; if the file exists but is unreadable or empty, delete it — which restores no passes, and lets the next Gate B pass the ordering permits record a fingerprint."
expected_msg="⚠ Codex Gate B: no recorded fingerprint"
[ "$ctx" = "$expected_ctx" ] && pass "empty-state additionalContext matches exactly" || fail "empty-state additionalContext matches exactly"
[ "$msg" = "$expected_msg" ] && pass "empty-state systemMessage matches exactly" || fail "empty-state systemMessage matches exactly"
reset_all; rev; rev; rev

# 29d. BELOW-FLOOR branches, Gate B at 1/3 and Gate A at 1/3, each with jq and jq-free.
#      The hook reads no findings, so these must say a zero-finding last pass may close
#      early (the field read "floor NOT met 2/3" after a legal early close as a hook defect).
#      Gate B also names the small-change close (0.38.0), with its condition; Gate A does not.
belowB_ctx="Codex Gate B below floor: 1/3 mcp__codex__review pass(es) since the last commit. The hook reads no findings or size. A zero-finding pass may close early; a small change's pass with no Blocker/Major closes. Else: this project's review policy's closure ordering."
belowB_msg="⚠ Codex Gate B below floor (1/3): may close after a zero-finding pass, or a small change's pass with no Blocker or Major"
belowA_ctx="Codex Gate A below floor: 1/3 mcp__codex__exec pass(es) on this spec/plan, counted as calls. The hook reads no findings: a zero-finding last pass may close early; otherwise follow this project's review policy's closure ordering, normally another pass."
belowA_msg="⚠ Codex Gate A below floor (1/3): a zero-finding last pass may close early"
commitp='{"hook_event_name":"PreToolUse","tool_name":"Bash","tool_input":{"command":"git commit -m x"}}'
skillp='{"hook_event_name":"PreToolUse","tool_name":"Skill","tool_input":{"skill":"superpowers:executing-plans"}}'
exact_pair() { # $1 = label, $2 = output, $3 = expected ctx, $4 = expected msg
  [ "$(json_field "$2" additionalContext)" = "$3" ] && pass "$1 additionalContext matches exactly" || fail "$1 additionalContext matches exactly"
  [ "$(json_field "$2" systemMessage)" = "$4" ] && pass "$1 systemMessage matches exactly" || fail "$1 systemMessage matches exactly"
}
reset_all; rev
exact_pair "Gate B below floor" "$(run "$commitp")" "$belowB_ctx$(cnote_ctx 1)" "$belowB_msg$(cnote_msg 1)"
reset_all; nojq_run "$(payload mcp__codex__review "$(resp_success)")" >/dev/null
exact_pair "Gate B below floor (jq-free)" "$(nojq_run "$commitp")" "$belowB_ctx$(cnote_ctx 1)" "$belowB_msg$(cnote_msg 1)"
reset_all; execp
exact_pair "Gate A below floor" "$(run "$skillp")" "$belowA_ctx" "$belowA_msg"
reset_all; nojq_run "$(payload mcp__codex__exec "$(resp_success)")" >/dev/null
exact_pair "Gate A below floor (jq-free)" "$(nojq_run "$skillp")" "$belowA_ctx" "$belowA_msg"
# A raised hook threshold is not the rules' floor: at 3/5 the message must not say only a
# zero-finding pass may close (three valid passes with only Minors may close under the rules).
reset_all; printf '5' > "$floorf"; rev; rev; rev
out=$(run "$commitp")
printf '%s' "$out" | grep -qF 'below floor (3/5): may close after a zero-finding pass' && ! printf '%s' "$out" | grep -qF 'only if' \
  && pass "floor override 5 at 3 passes -> no 'only if' closure claim" || fail "floor override 5 at 3 passes -> no 'only if' closure claim"
rm -f "$floorf"
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
  # S5 F1: the old fingerprint is removed, not left standing as if it were current.
  [ ! -e "$state" ] && pass "unwritable state file -> old fingerprint removed ($before)" || fail "unwritable state file -> old fingerprint removed"
  printf '%s' "$(commitpre)" | grep -q 'no fingerprint is recorded' \
    && pass "failed store -> no recorded fingerprint, not a stale one" \
    || fail "failed store -> no recorded fingerprint, not a stale one"
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
  printf '%s' "$out" | grep -qF 'docs/reference.md#hook-messages' \
    && pass "empty-state branch links the causes (a failed first write among them)" || fail "empty-state branch links the causes (a failed first write among them)"
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
# Since 0.21.0 the program is the shared JSON_AWK_FUNCS block followed by the locator's own
# body, so the extraction joins the two exactly as the hook's assignment does.
extract_locate_awk() {
  sed -n "/^JSON_AWK_FUNCS='\$/,/^'\$/p" "$HOOK" | sed '1d;$d'
  sed -n "/^LOCATE_AWK=\"\\\$JSON_AWK_FUNCS\"'\$/,/^'\$/p" "$HOOK" | sed '1d;$d'
}
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
awk_absent=$(mk_path noawk cat grep sed head tr git mkdir rm mv cp mktemp jq shasum sha1sum cksum)
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
  # With jq the request reader does not need awk, which is what this variant asserts; the
  # jq-free variant below covers a host without jq (PR #55, Greptile).
  PATH="$faultpath" command -v jq >/dev/null 2>&1 || { skip "awk fault '$shape' — no jq on this host; the jq-free variant covers it"; continue; }
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
# 39a, jq-free. Without jq the Gate-B request reader needs awk, so a broken awk makes the
# request unreadable: no credit and no fingerprint write (spec 2026-10-09 §3.2, plan Task 2).
# Gate A does not read the request, so its fail-open count is unchanged.
awk_absent_nojq=$(mk_path noawknojq cat grep sed head tr git mkdir rm mv cp mktemp shasum sha1sum cksum)
for pair in "absent:$awk_absent_nojq:absolute" "nonzero:$awk_fail:prefix" "partial:$awk_partial:prefix"; do
  shape=${pair%%:*}; rest=${pair#*:}; d=${rest%:*}; mode=${rest##*:}
  if [ -z "$d" ]; then
    skip "awk fault '$shape' without jq — shim could not be built; its assertions did not run"
    continue
  fi
  if [ "$mode" = absolute ]; then faultpath="$d"; else faultpath="$d:$nojq"; fi
  PATH="$faultpath" command -v jq >/dev/null 2>&1 && { skip "awk fault '$shape' without jq — jq still present"; continue; }
  printf 'x\n' | PATH="$faultpath" awk '{print}' >/dev/null 2>&1 && { skip "awk fault '$shape' without jq — awk still works"; continue; }
  reset_all
  out=$(printf '%s' "$(disc_payload failure mcp__codex__review)" | PATH="$faultpath" "$HOOK_SH_BIN" "$HOOK"); rc=$?
  [ "$rc" = 0 ] && pass "awk $shape, no jq: exits 0" || fail "awk $shape, no jq: exits 0 (got $rc)"
  [ "$(cat "$count" 2>/dev/null || echo 0)" = 0 ] && pass "awk $shape, no jq: review credits nothing" \
                                                  || fail "awk $shape, no jq: review credits nothing"
  [ -e "$state" ] && fail "awk $shape, no jq: writes no fingerprint" \
                  || pass "awk $shape, no jq: writes no fingerprint"
  printf '%s' "$out" | grep -q 'could not be read' \
    && pass "awk $shape, no jq: says the request could not be read" \
    || fail "awk $shape, no jq: says the request could not be read"
  reset_all
  printf '%s' "$(disc_payload failure mcp__codex__exec)" | PATH="$faultpath" "$HOOK_SH_BIN" "$HOOK" >/dev/null
  [ "$(cat "$countA" 2>/dev/null)" = 1 ] && pass "awk $shape, no jq: exec counts (fail-open)" \
                                         || fail "awk $shape, no jq: exec counts (fail-open)"
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

# shellcheck disable=SC2016  # $CODEX_HOME is text for the reader to run, not expanded here
G_FAILURE_CTX='Claude via Claude Code — gate hook. <state>this Codex call returned an envelope reporting failure.</state> <consequence>Not counted as a gate pass, no review fingerprint stored, does not count toward the floor.</consequence> <next>Read error.code in the tool result. CODEX_EXECUTION_FAILED is the pinned server generic failure code and does NOT tell you whether the call started, so check the accompanying error message and any session artifacts before assuming nothing ran; a call that did start may have left work behind. CODEX_TIMEOUT means the executor gave up mid-run: re-run the SAME call with the SAME scope. Any other code, or no code at all, is unclassified: this state covers every envelope the hook managed to route AND read as carrying success false as its first property, which is not limited to the two codes named here — routing, locating the result text and the raw key spelling each gate it, and an envelope failing any of those lands in a different state instead. When the message is empty, run a direct probe from this same session before the retry: codex exec --skip-git-repo-check \"Reply with OK\" </dev/null, and echo $CODEX_HOME. A usage-limit answer is missing access: stop and tell the human, naming that CODEX_HOME, because a probe from another session can use another account and say OK. Otherwise re-run once with the same scope and, if it repeats, report the code and message verbatim together with the effective server name and version from claude mcp list — an unfamiliar code is itself evidence about which server answered. Never retry with a narrower instruction or a smaller range, because that would count a pass for less than the artifact or diff the gate requires. Report one line: \"gate pass discarded | error-code | started yes/no/unknown\". Before re-running, delete the target findings file for the pass and confirm it is gone — both branch files for a full Gate-B re-run, only the failed branch for a single-branch resume. The checks on that file establish its structure — terminator present, count matching, nothing but finding lines — and not which run produced it.</next> <stop>One retry per pass is the whole recovery budget under CLAUDE.md section 5. If the retry also fails, stop and surface that line; the operator note carries the configuration remedy.</stop>'
G_FAILURE_MSG='⚠ Codex call failed — not counted as a gate pass. If the code was CODEX_TIMEOUT, the fix is configuration and only you can apply it: raise the executor timeout for the Codex MCP server, or reduce load outside the review. Do not ask for a smaller review scope — a narrower pass is worth less than a slow one.'
G_NORESULT_CTX='Claude via Claude Code — gate hook. <state>this gate call carried no result text the hook could read.</state> <consequence>Not counted as a gate pass, no review fingerprint stored.</consequence> <next>Treat the pass as not run and report it. Report one line: \"gate call unreadable | mapped yes/no from .context/codex-gate.tools | claude-code version\". Before re-running, delete the target findings file for the pass and confirm it is gone — both branch files for a full Gate-B re-run, only the failed branch for a single-branch resume. The checks on that file establish its structure — terminator present, count matching, nothing but finding lines — and not which run produced it.</next> <stop>One retry per pass is the whole recovery budget under CLAUDE.md section 5. A repeat is configuration or contract, not a transient failure, so stop and surface it; the operator note carries both checks.</stop>'
# shellcheck disable=SC2016  # a literal copy of a shipped prompt; the backticks are its own
G_NORESULT_MSG='⚠ Gate call returned no readable result — not counted. Next: check whether .context/codex-gate.tools maps a tool name, and run `claude mcp list` for the effective Codex server and version. Causes and fixes: https://github.com/dsnger/dev-workflow-kit/blob/main/docs/reference.md#hook-messages'
G_BG_LONG_CTX='Claude via Claude Code — gate hook. <state>this gate call was moved to the background at the auto-background threshold, 120 s by default, so its result never reached the hook.</state> <consequence>The pass was discarded and not counted, and no fingerprint was stored.</consequence> <next>The original call may still be running and can still write its findings file later. If the tool result carries a task id, stop that task by it; if it carries none, wait for the call to finish. Do that before deleting that slot or re-running the pass. Before re-running, delete the target findings file for the pass and confirm it is gone — both branch files for a full Gate-B re-run, only the failed branch for a single-branch resume. The checks on that file establish its structure — terminator present, count matching, nothing but finding lines — and not which run produced it.</next> <stop>Do not re-run while that task is active: a late writer landing in a slot you already re-ran leaves a correctly terminated file from the wrong run, and no downstream check can detect that. One retry per pass is the whole recovery budget under CLAUDE.md section 5. If the call backgrounds a second time, stop and surface it as a setup problem rather than retrying again, reporting one line: \"gate pass discarded | backgrounded | second occurrence | CLAUDE_CODE_MCP_AUTO_BACKGROUND_MS set yes/no\".</stop>'
G_BG_LONG_MSG='⚠ Gate pass discarded (backgrounded) — a setup gap, not a failed review. Set CLAUDE_CODE_MCP_AUTO_BACKGROUND_MS in the environment Claude Code is launched from, then restart Claude Code: it reads the value at process start, so exporting it inside a tool shell leaves the running session unchanged. Use 0 to disable auto-backgrounding, or a positive value that exceeds your longest gate call, since a positive value shorter than the call still backgrounds it. Requires Claude Code 2.1.212 or newer.'
G_BG_SHORT_CTX='Claude via Claude Code — gate hook. <state>this gate call was backgrounded and its result never reached the hook.</state> <consequence>The pass was discarded and not counted, and no fingerprint was stored.</consequence> <next>If the tool result carries a task id, stop that task by it; if it carries none, await the original call. Do that before re-running the pass. Before re-running, delete the target findings file for the pass and confirm it is gone — both branch files for a full Gate-B re-run, only the failed branch for a single-branch resume. The checks on that file establish its structure — terminator present, count matching, nothing but finding lines — and not which run produced it.</next> <stop>Do not re-run while that task is active, so a late writer cannot land in a slot you already re-ran. One retry per pass is the whole recovery budget under CLAUDE.md section 5. If the call backgrounds a second time, stop and surface it rather than retrying again, reporting one line: \"gate pass discarded | backgrounded | second occurrence | CLAUDE_CODE_MCP_AUTO_BACKGROUND_MS set yes/no\".</stop>'
G_BG_SHORT_MSG='⚠ Gate pass discarded (backgrounded) — not counted. Set CLAUDE_CODE_MCP_AUTO_BACKGROUND_MS in the environment Claude Code is launched from and restart Claude Code; the full guidance was shown once earlier in this workspace.'
G_UNVERIFIED_CTX='Claude via Claude Code — gate hook. <state>this workspace has classified at least one gate call as countable without being able to interpret its result, and attempted to record it.</state> <consequence>The counter is a mechanical tally, not a count of completed reviews: it can include calls that failed or reviewed nothing, so it can overstate them.</consequence> <next>Judge every pass on its findings artifact and discount any incomplete or unverified call, whatever the counter says.</next> <stop>Normally said once per workspace. It repeats when its marker cannot be persisted, when two hook runs race, or when that marker is deleted by hand or by a tool that cleans .context, so treat a repeat as a marker problem rather than as new information.</stop>'
G_UNVERIFIED_MSG='ℹ A gate call was classified as countable without the hook reading its result, and recording it was attempted, so the pass counter can overstate completed reviews. Judge each pass on its findings file. If you report this, keep the raw hook payload local: it can hold prompts, paths and review content. Causes and checks: https://github.com/dsnger/dev-workflow-kit/blob/main/docs/reference.md#hook-messages'

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
nosed=$(mk_path nosed cat grep head tr git mkdir rm mv cp mktemp awk shasum sha1sum cksum)
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

# 42. SEQUENTIAL SINGLE-BRANCH CALLS (spec docs/superpowers/specs/2026-10-09-sequential-
#     branch-calls-hook-design.md, story AC-1..AC-5). A `spec` call and a `quality` call
#     on identical 40-hex baseSha/headSha are ONE pass; a lone branch counts nothing.
#     Request fields come from `tool_input` only. The loop runs each case twice: once on
#     the host PATH (the jq reader where jq is installed, else the awk one) and once on
#     the jq-free PATH. Cases specific to one reader skip when it is unavailable, and the
#     read-only `.context` cases skip when a write probe shows the chmod did not take.
B1=1111111111111111111111111111111111111111
B2=4444444444444444444444444444444444444444
H1=2222222222222222222222222222222222222222
H2=3333333333333333333333333333333333333333
SEEDFP=seeded-fingerprint-not-a-real-one
# $1 = tool_input JSON, $2 = tool_response JSON (default: a real success envelope)
rvp() { printf '{"hook_event_name":"PostToolUse","tool_name":"mcp__codex__review","tool_input":%s,"tool_response":%s}' "$1" "${2:-$(resp_success)}"; }
ti() { printf '{"reviewType":"%s","baseSha":"%s","headSha":"%s"}' "$1" "$2" "$3"; }
# Every section-42 hook invocation records a nonzero exit in a file, so the record survives
# command substitutions and background jobs; one assertion at the end reads it (AC-5, inv. 1).
rc42f="$sandbox/rc42"; : > "$rc42f"
chk42() { "$@"; _rc42=$?; [ "$_rc42" = 0 ] || printf '%s %s: %s\n' "$m42" "$_rc42" "$1" >> "$rc42f"; return "$_rc42"; }
r42() { if [ "$m42" = nojq ]; then chk42 nojq_run "$1"; else chk42 run "$1"; fi; }
br() { r42 "$(rvp "$(ti "$1" "$2" "$3")" "${4:-}")"; }       # capturing branch call
seed42() { printf '%s' 5 > "$count"; printf '%s' 2 > "$fresh"; printf '%s' "$SEEDFP" > "$state"
           printf '%s' "spec $B1 $H1" > "$pendb"; }
# The preservation oracle: no-credit paths leave the counters and the fingerprint alone,
# and (where §3.2 says so) the pending record too.
kept42() { # $1 = label, $2 = "pend" to also require the pending record unchanged
  [ "$(cat "$count" 2>/dev/null)" = 5 ] && [ "$(cat "$fresh" 2>/dev/null)" = 2 ] \
    && [ "$(cat "$state" 2>/dev/null)" = "$SEEDFP" ] \
    && pass "42/$m42: $1 — counters and fingerprint unchanged" \
    || fail "42/$m42: $1 — counters and fingerprint unchanged (passes=$(cat "$count" 2>/dev/null) fresh=$(cat "$fresh" 2>/dev/null))"
  if [ "${2:-}" = pend ]; then
    [ "$(cat "$pendb" 2>/dev/null)" = "spec $B1 $H1" ] \
      && pass "42/$m42: $1 — pending record unchanged" \
      || fail "42/$m42: $1 — pending record unchanged (got [$(cat "$pendb" 2>/dev/null)])"
  fi
}
cnt() { cat "$count" 2>/dev/null || echo 0; }
eq42() { [ "$2" = "$3" ] && pass "42/$m42: $1" || fail "42/$m42: $1 (got [$2], want [$3])"; }
has42() { printf '%s' "$2" | grep -q "$3" && pass "42/$m42: $1" || fail "42/$m42: $1 (no [$3])"; }

PATH="$nojq" command -v mv >/dev/null 2>&1 \
  && pass "42: the jq-free PATH carries mv, so a claim can succeed there" \
  || fail "42: the jq-free PATH carries mv, so a claim can succeed there"

real_mv=$(command -v mv)
mv_vanish=$(mk_shim mvvanish mv "case \"\$1\" in *codex-gate.pendingBranch) rm -f \"\$1\" ;; esac
exec $real_mv \"\$@\"")
if [ -n "$mv_vanish" ]; then
  printf x > "$sandbox/mvv-a"; PATH="$mv_vanish:$PATH" mv "$sandbox/mvv-a" "$sandbox/mvv-b" 2>/dev/null
  printf x > "$sandbox/codex-gate.pendingBranch"
  if [ -e "$sandbox/mvv-b" ] && ! PATH="$mv_vanish:$PATH" mv "$sandbox/codex-gate.pendingBranch" "$sandbox/mvv-c" 2>/dev/null \
     && [ ! -e "$sandbox/codex-gate.pendingBranch" ] && [ ! -e "$sandbox/mvv-c" ]; then
    pass "42: the mv shim moves ordinary files and makes a pending-file claim fail"
  else
    fail "42: the mv shim moves ordinary files and makes a pending-file claim fail"; mv_vanish=''
  fi
  rm -f "$sandbox/mvv-a" "$sandbox/mvv-b" "$sandbox/mvv-c"
fi

for m42 in normal nojq; do
  # AC-1 — three pairs are three passes, and the commit check reports them as satisfied.
  reset_all
  for _p in 1 2 3; do br spec "$B1" "$H1" >/dev/null; br quality "$B1" "$H1" >/dev/null; done
  eq42 "AC-1: three spec->quality pairs count 3" "$(cnt)" 3
  [ -e "$pendb" ] && fail "42/$m42: AC-1: no pending branch left after complete pairs" \
                  || pass "42/$m42: AC-1: no pending branch left after complete pairs"
  out=$(chk42 commitpre)
  has42 "AC-1: commit check reports the floor met" "$out" '3/3 pass(es) this cycle'
  # AC-2 — a lone branch is not counted, and the commit check says so.
  reset_all
  br spec "$B1" "$H1" >/dev/null; br quality "$B1" "$H1" >/dev/null
  out=$(br spec "$B1" "$H1")
  eq42 "AC-2: pair + lone spec counts 1" "$(cnt)" 1
  has42 "AC-2: the lone branch says it is recorded and awaited" "$out" 'this review branch is recorded'
  out=$(chk42 commitpre)
  has42 "AC-2: commit check carries the pending note" "$out" 'pending-branch state is present'
  reset_all
  for _p in 1 2 3; do br spec "$B1" "$H1" >/dev/null; br quality "$B1" "$H1" >/dev/null; done
  br spec "$B1" "$H2" >/dev/null
  out=$(chk42 commitpre)
  has42 "AC-2: three pairs + lone spec still print the satisfied line" "$out" '3/3 pass(es) this cycle'
  has42 "AC-2: ...and the pending note beside it" "$out" 'pending-branch state is present'
  # AC-3 — full and absent reviewType count one each, as before.
  reset_all
  r42 "$(rvp '{}')" >/dev/null
  eq42 "AC-3: absent reviewType counts 1" "$(cnt)" 1
  r42 "$(rvp "$(ti full "$B1" "$H1")")" >/dev/null
  eq42 "AC-3: reviewType full counts 1 more" "$(cnt)" 2
  # AC-4 — the pair state machine.
  reset_all
  br spec "$B1" "$H1" "$(resp_from shape1-fast-fail)" >/dev/null
  eq42 "AC-4: failed first branch counts nothing" "$(cnt)" 0
  [ -e "$pendb" ] && fail "42/$m42: AC-4: failed first branch records nothing" \
                  || pass "42/$m42: AC-4: failed first branch records nothing"
  br spec "$B1" "$H1" >/dev/null; br quality "$B1" "$H1" >/dev/null
  eq42 "AC-4: retry then partner counts 1" "$(cnt)" 1
  reset_all
  br spec "$B1" "$H1" >/dev/null; br quality "$B1" "$H1" "$(resp_from shape1-fast-fail)" >/dev/null
  eq42 "AC-4: failed second branch counts nothing" "$(cnt)" 0
  eq42 "AC-4: failed second branch keeps the pending half" "$(cat "$pendb" 2>/dev/null)" "spec $B1 $H1"
  reset_all
  br quality "$B1" "$H1" >/dev/null; br spec "$B1" "$H1" >/dev/null
  eq42 "AC-4: quality before spec counts 1" "$(cnt)" 1
  reset_all
  br spec "$B1" "$H1" >/dev/null; br spec "$B1" "$H2" >/dev/null
  eq42 "AC-4: same branch twice counts nothing" "$(cnt)" 0
  eq42 "AC-4: same branch twice replaces the pending half" "$(cat "$pendb" 2>/dev/null)" "spec $B1 $H2"
  for _rt in spec quality; do
    if [ "$_rt" = spec ]; then _ot=quality; else _ot=spec; fi
    reset_all
    br "$_rt" "$B1" "$H1" >/dev/null; br "$_rt" "$B1" "$H1" >/dev/null
    eq42 "AC-4: $_rt twice on identical SHAs counts nothing" "$(cnt)" 0
    eq42 "AC-4: ...and keeps one $_rt half pending" "$(cat "$pendb" 2>/dev/null)" "$_rt $B1 $H1"
    br "$_ot" "$B1" "$H1" >/dev/null
    eq42 "AC-4: ...then $_ot on those SHAs counts 1" "$(cnt)" 1
  done
  reset_all
  br spec "$B1" "$H1" >/dev/null; br quality "$B2" "$H1" >/dev/null
  eq42 "AC-4: same head, different base counts nothing" "$(cnt)" 0
  eq42 "AC-4: ...and the later call becomes the pending half" "$(cat "$pendb" 2>/dev/null)" "quality $B2 $H1"
  br spec "$B2" "$H1" >/dev/null
  eq42 "AC-4: a partner on that base pairs with it" "$(cnt)" 1
  reset_all
  br spec "$B1" "$H1" >/dev/null; chk42 commitpost
  [ -e "$pendb" ] && fail "42/$m42: AC-4: a non-WIP commit removes the pending half" \
                  || pass "42/$m42: AC-4: a non-WIP commit removes the pending half"
  reset_all
  br spec "$B1" "$H1" >/dev/null; r42 "$(rvp "$(ti full "$B1" "$H1")")" >/dev/null
  eq42 "AC-4: full with a pending half counts 1" "$(cnt)" 1
  [ -e "$pendb" ] && fail "42/$m42: AC-4: full retires the pending half" \
                  || pass "42/$m42: AC-4: full retires the pending half"
  # Request rejections — each under the preservation oracle.
  for _bad in HEAD 2222222 2222222222222222222222222222222222222AAA; do
    reset_all; seed42; out=$(br quality "$B1" "$_bad")
    kept42 "unusable headSha [$_bad]" pend
    has42 "unusable headSha [$_bad] says why" "$out" 'cannot be paired'
  done
  reset_all; seed42; out=$(r42 "$(rvp "$(ti both "$B1" "$H1")")")
  kept42 "unknown reviewType" pend
  has42 "unknown reviewType is named" "$out" 'reviewType value'
  for _ti in null '"spec"'; do
    reset_all; seed42; out=$(r42 "$(rvp "$_ti")")
    kept42 "tool_input $_ti is uncertain" pend
    has42 "tool_input $_ti says the request could not be read" "$out" 'could not be read'
  done
  reset_all; seed42
  out=$(r42 "$(printf '{"hook_event_name":"PostToolUse","tool_name":"mcp__codex__review","tool_response":%s}' "$(resp_success)")")
  kept42 "missing tool_input is uncertain" pend
  reset_all; seed42; r42 "$(rvp "$(printf '{"reviewType":"quality","baseSha":"%s","headSha":"%s\\n"}' "$B1" "$H1")")" >/dev/null
  kept42 "headSha with a trailing escaped newline is unusable" pend
  # 39 hex + a newline is 40 characters, and jq's `$` also matches before a final newline,
  # so a length check plus an anchored regex would accept it (final review, Important).
  H39=$(printf '%s' "$H1" | cut -c1-39); B39=$(printf '%s' "$B1" | cut -c1-39)
  reset_all; seed42; r42 "$(rvp "$(printf '{"reviewType":"quality","baseSha":"%s","headSha":"%s\\n"}' "$B1" "$H39")")" >/dev/null
  kept42 "headSha of 39 hex plus an escaped newline is unusable" pend
  reset_all; seed42; r42 "$(rvp "$(printf '{"reviewType":"quality","baseSha":"%s\\n","headSha":"%s"}' "$B39" "$H1")")" >/dev/null
  kept42 "baseSha of 39 hex plus an escaped newline is unusable" pend
  for _rt in full spec; do
    reset_all; seed42; r42 "$(rvp "$(printf '{"reviewType":"%s\\n","baseSha":"%s","headSha":"%s"}' "$_rt" "$B1" "$H1")")" >/dev/null
    kept42 "reviewType $_rt with a trailing escaped newline is not $_rt" pend
  done
  # Field ownership — values come from tool_input and nowhere else.
  reset_all; seed42
  r42 "$(printf '{"hook_event_name":"PostToolUse","tool_name":"mcp__codex__review","tool_input":{"reviewType":"quality","baseSha":"%s"},"extra":{"headSha":"%s"},"tool_response":%s}' "$B1" "$H1" "$(resp_success)")" >/dev/null
  kept42 "headSha in a sibling object is not read" pend
  reset_all; seed42
  r42 "$(rvp "$(printf '{"reviewType":"quality","baseSha":"%s"}' "$B1")" "$(resp "{\\\"headSha\\\": \\\"$H1\\\"}")")" >/dev/null
  kept42 "headSha inside tool_response is not read" pend
  reset_all
  br spec "$B1" "$H1" >/dev/null
  r42 "$(printf '{"hook_event_name":"PostToolUse","tool_name":"mcp__codex__review","tool_response":%s,"tool_input":%s}' "$(resp_success)" "$(ti quality "$B1" "$H1")")" >/dev/null
  eq42 "tool_response before tool_input pairs normally" "$(cnt)" 1
  reset_all
  br spec "$B1" "$H1" >/dev/null
  r42 "$(printf '{"hook_event_name":"PostToolUse","tool_name":"mcp__codex__review","decoy":"x \\"tool_input\\":{\\"reviewType\\":\\"full\\"}","tool_input":%s,"tool_response":%s}' "$(ti quality "$B1" "$H1")" "$(resp_success)")" >/dev/null
  eq42 "an escaped tool_input inside a string is not the key" "$(cnt)" 1
  # Synthetic: the full capture, retargeted to the two branches.
  reset_all
  sed 's/"reviewType":"full"/"reviewType":"spec"/' "$FIXTURES/shape0-success-review.json" > "$sandbox/syn-spec.json"
  sed 's/"reviewType":"full"/"reviewType":"quality"/' "$FIXTURES/shape0-success-review.json" > "$sandbox/syn-quality.json"
  r42 "$(cat "$sandbox/syn-spec.json")" >/dev/null; r42 "$(cat "$sandbox/syn-quality.json")" >/dev/null
  eq42 "synthetic (full capture retargeted): spec + quality count 1" "$(cnt)" 1
  # Upgrade: a legacy per-call count is ignored and retired.
  reset_all; printf '%s' 3 > "$old_count"; printf '%s' 3 > "$old_fresh"
  br spec "$B1" "$H1" >/dev/null; br quality "$B1" "$H1" >/dev/null
  eq42 "upgrade: legacy passCount 3 is ignored" "$(cnt)" 1
  [ -e "$old_count" ] || [ -e "$old_fresh" ] \
    && fail "42/$m42: upgrade: legacy counter names are retired" \
    || pass "42/$m42: upgrade: legacy counter names are retired"
  # Retirement runs on every call classification lets through, rejected requests included.
  for _rq in "$(ti quality "$B1" HEAD)" "$(ti both "$B1" "$H1")" null; do
    reset_all; seed42; printf '%s' 3 > "$old_count"; printf '%s' 3 > "$old_fresh"
    r42 "$(rvp "$_rq")" >/dev/null
    kept42 "rejected request [$_rq]" pend
    [ -e "$old_count" ] || [ -e "$old_fresh" ] \
      && fail "42/$m42: rejected request [$_rq] still retires the legacy names" \
      || pass "42/$m42: rejected request [$_rq] still retires the legacy names"
  done
  reset_all; printf '%s' 3 > "$old_count"; chk42 commitpost
  [ -e "$old_count" ] && fail "42/$m42: a reset removes the legacy names too" \
                      || pass "42/$m42: a reset removes the legacy names too"
  # Stale state that cannot be removed blocks the credit.
  reset_all; seed42; rm -f "$pendb"; mkdir -p "$old_count/x"
  out=$(r42 "$(rvp "$(ti full "$B1" "$H1")")")
  kept42 "a legacy counter that cannot be removed blocks credit"
  has42 "...and the note names that path" "$out" 'codex-gate.passCount'
  rm -rf "$old_count"
  # Unwritable .context: the claim fails, so nothing is credited. Root ignores directory
  # write permission, so each case first proves the chmod took (PR #55, CodeRabbit).
  ro42() { chmod a-w .context
           # printf, never `:` — a failed redirection on the special builtin `:` exits dash.
           if { printf '' > .context/.ro-probe; } 2>/dev/null; then rm -f .context/.ro-probe; chmod u+w .context; return 1; fi; }
  reset_all; seed42
  if ro42; then
    out=$(br quality "$B1" "$H1")
    chmod u+w .context
    kept42 "read-only .context: the claim fails, quality credits nothing"
  else skip "42/$m42: read-only .context — the directory stays writable (root?)"; fi
  reset_all; seed42
  if ro42; then
    out=$(r42 "$(rvp "$(ti full "$B1" "$H1")")")
    chmod u+w .context
    kept42 "read-only .context: a pending half that cannot be retired blocks full" pend
    has42 "...and the note names the pending path" "$out" 'codex-gate.pendingBranch'
  else skip "42/$m42: read-only .context (full) — the directory stays writable (root?)"; fi
  reset_all
  if ro42; then
    out=$(br spec "$B1" "$H1")
    chmod u+w .context
    has42 "read-only .context, no pending file: recording could not be confirmed" "$out" 'could not be confirmed'
  else skip "42/$m42: read-only .context (no pending) — the directory stays writable (root?)"; fi
  # The claim is exclusive: a claim file is never read, and a vanished pending file
  # credits nothing. A hook that read the pending file without renaming it first would
  # still fail the first assertion below only if the file were there — so the second
  # case plants the record ONLY where a non-claiming reader would never look.
  reset_all
  printf '%s' "spec $B1 $H1" > .context/codex-gate.pendingClaim.99999
  br quality "$B1" "$H1" >/dev/null
  eq42 "a leftover claim file is never read" "$(cnt)" 0
  # The pending file vanishes immediately before the rename, as when another hook process
  # claims it first: an mv shim removes it and then runs the real mv, which fails. A hook
  # that read the pending file without renaming it would credit here, so the count
  # assertion below is the one that version fails.
  if [ -n "$mv_vanish" ]; then
    reset_all; seed42
    if [ "$m42" = nojq ]; then _vp="$mv_vanish:$nojq"; else _vp="$mv_vanish:$PATH"; fi
    out=$(printf '%s' "$(rvp "$(ti quality "$B1" "$H1")")" | PATH="$_vp" "$HOOK_SH_BIN" "$HOOK"); _rc=$?
    eq42 "vanished before the rename: exits 0" "$_rc" 0
    kept42 "vanished before the rename credits nothing"
  else
    skip "42/$m42: vanished-before-rename — mv shim could not be built"
  fi
  # Unverified disclosure: a rejected call creates no new disclosure and no debt.
  reset_all
  out=$(r42 "$(rvp "$(ti spec "$B1" HEAD)" "$(unrec)")")
  printf '%s' "$out" | grep -q 'classified at least one gate call as countable' \
    && fail "42/$m42: a rejected unrecognized call discloses nothing" \
    || pass "42/$m42: a rejected unrecognized call discloses nothing"
  [ -f "$pendf" ] && fail "42/$m42: a rejected unrecognized call leaves no debt" \
                  || pass "42/$m42: a rejected unrecognized call leaves no debt"
done
# jq-free only: a key spelled with a unicode escape might be reviewType, so it is uncertain.
m42=nojq; reset_all; seed42
r42 "$(printf '{"hook_event_name":"PostToolUse","tool_name":"mcp__codex__review","tool_input":{"\\u0072eviewType":"spec","baseSha":"%s","headSha":"%s"},"tool_response":%s}' "$B1" "$H1" "$(resp_success)")" >/dev/null
kept42 "a unicode-escaped key is uncertain without jq" pend
# ...while jq decodes it to spec, so it pairs with the seeded half's partner shape. This and
# the next two blocks assert jq-path behaviour, so they skip on a host without jq (PR #55).
have_jq42=0; command -v jq >/dev/null 2>&1 && have_jq42=1
if [ "$have_jq42" = 1 ]; then
m42=normal; reset_all
br quality "$B1" "$H1" >/dev/null
r42 "$(printf '{"hook_event_name":"PostToolUse","tool_name":"mcp__codex__review","tool_input":{"\\u0072eviewType":"spec","baseSha":"%s","headSha":"%s"},"tool_response":%s}' "$B1" "$H1" "$(resp_success)")" >/dev/null
eq42 "a unicode-escaped key decodes to spec under jq" "$(cnt)" 1
else skip "42: unicode-escaped key under jq — no jq on this host"; fi
# jq-free only: a truncated payload is uncertain; the jq path refuses it at routing.
m42=nojq; reset_all; seed42
r42 "$(printf '{"hook_event_name":"PostToolUse","tool_name":"mcp__codex__review","tool_input":{"reviewType":"spec","baseSha":"%s"' "$B1")" >/dev/null; rc=$?
eq42 "truncated payload exits 0" "$rc" 0
kept42 "truncated payload is uncertain" pend
if [ "$have_jq42" = 1 ]; then
m42=normal; reset_all
out=$(r42 "$(printf '{"hook_event_name":"PostToolUse","tool_name":"mcp__codex__review","tool_input":{"reviewType":"spec"')"); rc=$?
eq42 "truncated payload exits 0" "$rc" 0
eq42 "truncated payload is not routed" "$out" ''
else skip "42: truncated payload refused at jq routing — no jq on this host"; fi
# jq with a WIP commit between the branches: the second carries the new head, no pair.
if [ "$have_jq42" = 1 ]; then
m42=normal; reset_all
wip_base=$(git rev-parse HEAD)
br spec "$wip_base" "$H1" >/dev/null
chk42 wip "git commit -m 'wip: snapshot'" >/dev/null
git commit -q --allow-empty -m 'wip: snapshot' >/dev/null 2>&1
chk42 run '{"hook_event_name":"PostToolUse","tool_name":"Bash","tool_use_id":"toolu_t1","tool_input":{"command":"git commit -m \"wip: snapshot\""}}' >/dev/null
eq42 "WIP commit between branches keeps the pending half" "$(cat "$pendb" 2>/dev/null)" "spec $wip_base $H1"
br quality "$wip_base" "$(git rev-parse HEAD)" >/dev/null
eq42 "WIP commit between branches: the new head does not pair" "$(cnt)" 0
git reset -q --soft HEAD~1 >/dev/null 2>&1
else skip "42: WIP commit between branches under jq — no jq on this host"; fi
# jq-free scan bound: a sibling past the ceiling before tool_input is uncertain, quickly.
m42=nojq; reset_all; seed42
big42=$(awk 'BEGIN{ s=sprintf("%1024s",""); gsub(/ /,"x",s); r=""; for(i=0;i<1100;i++) r=r s; printf "%s", r }')
t0=$(date +%s)
r42 "$(printf '{"hook_event_name":"PostToolUse","tool_name":"mcp__codex__review","big":"%s","tool_input":%s,"tool_response":%s}' "$big42" "$(ti quality "$B1" "$H1")" "$(resp_success)")" >/dev/null
el=$(( $(date +%s) - t0 ))
kept42 "a payload past the scan bound is uncertain" pend
[ "$el" -le 10 ] && pass "42/nojq: the bounded refusal finished in ${el}s" || fail "42/nojq: the bounded refusal finished in ${el}s (limit 10s)"
# Concurrency smoke, not proof (bump_count is a read-modify-write): two partners against
# one pending half never credit more than one pass.
m42=normal; over42=0
for _i in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20; do
  reset_all; printf '%s' "spec $B1 $H1" > "$pendb"
  br quality "$B1" "$H1" >/dev/null & br quality "$B1" "$H1" >/dev/null & wait
  [ "$(cnt)" -le 1 ] || over42=$((over42 + 1))
done
eq42 "concurrency smoke: no repetition credited more than one pass" "$over42" 0
reset_all
eq42 "every section-42 hook invocation exited 0" "$(cat "$rc42f")" ''

# 43. THE PASS CAP LIVES IN THE HOOK (story S3, 2026-10-12). §5's pass-cap stop is a count:
#     the derived floor plus two, raised by whatever a human's answer allows. The hook
#     already counts passes per gate, so it reports the cap the same way it reports the
#     floor — on every gate call and every commit attempt once the count is at or past it,
#     once per call — and blocks nothing (invariant 1). The cap is floor + 2 by default,
#     `.context/codex-gate.cap` overrides it like the floor file, and the answer file
#     `.context/codex-gate.cap-extra` adds its passes until the commit reset clears it
#     with the pass counter.
# Occurrences in ONE field of the document (the operator channel): the same text goes to
# both channels, so counting the whole document would read every message as two.
ncap() { json_field "$1" systemMessage | grep -o 'pass cap reached' | grep -c ''; }
skillpre() { run '{"hook_event_name":"PreToolUse","tool_name":"Skill","tool_input":{"skill":"superpowers:executing-plans"}}'; }
execout() { run "$(payload mcp__codex__exec "$(resp_success)")"; }       # capturing exec call
cap_line1='STOP: a remaining Blocker, or a cut to an approved commitment, goes to the human; otherwise choose and record why: delete the mechanism, cut scope, or allow N more passes.'
cap_line2='Record the answer as an integer in .context/codex-gate.cap-extra (passes allowed beyond the cap).'

# 43a. Gate B at the default cap of 5: four passes are silent, the fifth call carries the
#      message once, and so does every commit attempt and call after it.
reset_all; rev; rev; rev
out=$(revout)
[ "$(ncap "$out")" = 0 ] && pass "43a: 4/5 Gate-B passes -> no cap message" || fail "43a: 4/5 Gate-B passes -> no cap message"
out=$(revout)
[ "$(ncap "$out")" = 1 ] && pass "43a: 5th review call -> cap message once" || fail "43a: 5th review call -> cap message once (got $(ncap "$out"))"
printf '%s' "$out" | grep -qF "⚠ Codex Gate B: pass cap reached (5/5). $cap_line1" \
  && pass "43a: cap message line 1 is exact" || fail "43a: cap message line 1 is exact"
printf '%s' "$out" | grep -qF "$cap_line2" && pass "43a: cap message line 2 is exact" || fail "43a: cap message line 2 is exact"
out=$(commitpre)
[ "$(ncap "$out")" = 1 ] && pass "43a: commit attempt at the cap -> cap message once" || fail "43a: commit attempt at the cap -> cap message once (got $(ncap "$out"))"
one_doc "43a: commit attempt at the cap" "$out"
rev
out=$(commitpre)
printf '%s' "$out" | grep -qF 'pass cap reached (6/5)' && pass "43a: past the cap the count keeps rising (6/5)" || fail "43a: past the cap the count keeps rising (6/5)"

# 43b. cap-extra = 2 raises the cap to 7 for this cycle: silent at 5 and 6, message at 7.
reset_all; printf '2' > "$capxf"
rev; rev; rev; rev
out=$(revout)
[ "$(ncap "$out")" = 0 ] && pass "43b: cap-extra 2 -> 5/7 silent" || fail "43b: cap-extra 2 -> 5/7 silent"
rev
out=$(commitpre)
[ "$(ncap "$out")" = 0 ] && pass "43b: cap-extra 2 -> commit at 6/7 silent" || fail "43b: cap-extra 2 -> commit at 6/7 silent"
out=$(revout)
printf '%s' "$out" | grep -qF 'pass cap reached (7/7)' && pass "43b: cap-extra 2 -> message at 7/7" || fail "43b: cap-extra 2 -> message at 7/7"

# 43c. An unusable cap-extra is ignored, never read as 0 passes or as a silence.
for bad in two 0 -1 '' '2 3' 99999999999; do
  reset_all; printf '%s' "$bad" > "$capxf"
  rev; rev; rev; rev
  out=$(revout)
  [ "$(ncap "$out")" = 1 ] && pass "43c: cap-extra [$bad] ignored -> message at 5/5" || fail "43c: cap-extra [$bad] ignored -> message at 5/5"
done

# 43d. The commit reset that clears the pass counter clears the answer too — one reset
#      path, so the next cycle starts at the default cap.
reset_all; printf '2' > "$capxf"; rev
commitpost
[ ! -e "$capxf" ] && pass "43d: commit reset clears cap-extra" || fail "43d: commit reset clears cap-extra"
[ ! -e "$count" ] && pass "43d: commit reset still clears the pass counter" || fail "43d: commit reset still clears the pass counter"

# 43e. Per-project cap override, parsed like the floor file: a positive integer is the cap,
#      anything else keeps the default.
reset_all; printf '3' > "$capf"; rev; rev
out=$(revout)
printf '%s' "$out" | grep -qF 'pass cap reached (3/3)' && pass "43e: cap override 3 -> message at 3/3" || fail "43e: cap override 3 -> message at 3/3"
reset_all; printf 'three' > "$capf"; rev; rev; rev; rev
[ "$(ncap "$(revout)")" = 1 ] && pass "43e: unusable cap override -> default 5" || fail "43e: unusable cap override -> default 5"
reset_all; printf '3' > "$capf"; printf '1' > "$capxf"; rev; rev; rev
[ "$(ncap "$(revout)")" = 1 ] && pass "43e: override 3 + extra 1 -> message at 4/4" || fail "43e: override 3 + extra 1 -> message at 4/4"

# 43f. Gate A counts its own cap on exec calls and on the plan-execution skill.
reset_all; execp; execp; execp; execp
out=$(execout)
printf '%s' "$out" | grep -qF '⚠ Codex Gate A: pass cap reached (5/5).' && pass "43f: 5th exec call -> Gate A cap message" || fail "43f: 5th exec call -> Gate A cap message"
[ "$(ncap "$out")" = 1 ] && pass "43f: Gate A cap message once per call" || fail "43f: Gate A cap message once per call"
out=$(skillpre)
[ "$(ncap "$out")" = 1 ] && pass "43f: plan-execution skill at the cap -> cap message once" || fail "43f: plan-execution skill at the cap -> cap message once"
one_doc "43f: plan-execution skill at the cap" "$out"
reset_all; execp; execp; execp
[ "$(ncap "$(skillpre)")" = 0 ] && pass "43f: Gate A below the cap -> no cap message" || fail "43f: Gate A below the cap -> no cap message"

# 43g. Every message the hook prints is at most two lines. The emitted document is JSON, so
#      a line break inside a field is the two-byte escape \n: at most one per field. The
#      three floor reminders this story shortened are bounded in length as well, since a
#      one-line string of 600 characters is not two lines of anything.
nl_escapes() { printf '%s' "$1" | grep -o '\\n' | grep -c ''; }
two_lines() { # $1 = label, $2 = captured output, $3 = max additionalContext length
  _c=$(json_field "$2" additionalContext); _m=$(json_field "$2" systemMessage)
  [ "$(nl_escapes "$_c")" -le 1 ] && [ "$(nl_escapes "$_m")" -le 1 ] \
    && pass "43g: $1 -> at most two lines" || fail "43g: $1 -> at most two lines"
  [ "${#_c}" -le "$3" ] && pass "43g: $1 additionalContext within $3 chars" \
    || fail "43g: $1 additionalContext within $3 chars (got ${#_c})"
}
reset_all; rev
two_lines "Gate B below floor" "$(commitpre)" 260
reset_all; execp
two_lines "Gate A below floor" "$(skillpre)" 260
reset_all; execp; execp; execp
two_lines "Gate A floor met" "$(skillpre)" 260
reset_all; rev; rev; rev; rev; rev
two_lines "Gate B cap reached" "$(commitpre)" 1000
reset_all; execp; execp; execp; execp; execp
two_lines "Gate A cap reached" "$(skillpre)" 1000

# 43h. The cap message carries a real line break, so the jq-free emitter has to escape it:
#      the document must stay one line of valid JSON, with the break as the \n escape.
reset_all; nojq_run "$(payload mcp__codex__review "$(resp_success)")" >/dev/null
nojq_run "$(payload mcp__codex__review "$(resp_success)")" >/dev/null
nojq_run "$(payload mcp__codex__review "$(resp_success)")" >/dev/null
nojq_run "$(payload mcp__codex__review "$(resp_success)")" >/dev/null
out=$(nojq_run "$(payload mcp__codex__review "$(resp_success)")"); rc=$?
[ "$rc" = 0 ] && pass "43h: jq-free cap message exits 0" || fail "43h: jq-free cap message exits 0 (got $rc)"
[ "$(printf '%s\n' "$out" | grep -c '')" = 1 ] && pass "43h: jq-free cap document is one line" || fail "43h: jq-free cap document is one line"
printf '%s' "$out" | grep -qF 'allow N more passes.\n   Record the answer' && pass "43h: jq-free line break is the \\n escape" || fail "43h: jq-free line break is the \\n escape"
if command -v jq >/dev/null 2>&1; then
  printf '%s' "$out" | jq -e . >/dev/null 2>&1 && pass "43h: jq-free cap document parses as JSON" || fail "43h: jq-free cap document parses as JSON"
fi

# 43i. Leading zeros and huge values (Gate-B passes 1 and 2 of this story): `08` is a
#      positive integer to `test` and an invalid octal to `$(( ))`, where the error is a
#      shell error and a shell error is a non-zero exit. The floor file accepted `08` as 8
#      before the cap existed, so it still does — the value is read as decimal, never
#      refused, because a refused floor falls to 3 and a lowered floor is a false ✓. A
#      floor too long for the arithmetic is its own cap, compared as a string of digits.
for v in 08 010; do
  reset_all; printf '%s' "$v" > "$floorf"; rev
  out=$(commitpre); rc=$?
  [ "$rc" = 0 ] && pass "43i: floor [$v] -> hook exits 0" || fail "43i: floor [$v] -> hook exits 0 (got $rc)"
  printf '%s' "$out" | grep -qF "below floor (1/${v#0})" && pass "43i: floor [$v] -> read as decimal ${v#0}" || fail "43i: floor [$v] -> read as decimal ${v#0}"
done
reset_all; printf '08' > "$floorf"; execp; execp; execp
printf '%s' "$(skillpre)" | grep -qF 'below floor (3/8)' && pass "43i: floor [08] keeps Gate A below floor at 3 passes" || fail "43i: floor [08] keeps Gate A below floor at 3 passes"
reset_all; printf '9223372036854775807' > "$floorf"; rev
out=$(commitpre); rc=$?
[ "$rc" = 0 ] && pass "43i: floor at the 64-bit maximum -> hook exits 0" || fail "43i: floor at the 64-bit maximum -> hook exits 0 (got $rc)"
printf '%s' "$out" | grep -qF 'below floor (1/9223372036854775807)' && pass "43i: floor at the 64-bit maximum is kept" || fail "43i: floor at the 64-bit maximum is kept"
[ "$(ncap "$out")" = 0 ] && pass "43i: floor at the 64-bit maximum -> no cap message" || fail "43i: floor at the 64-bit maximum -> no cap message"
# The cap files read leading zeros the same way, and a value past nine digits is unusable.
reset_all; printf '08' > "$capxf"; rev; rev; rev; rev; rev
out=$(revout); rc=$?
[ "$rc" = 0 ] && pass "43i: cap-extra [08] -> hook exits 0" || fail "43i: cap-extra [08] -> hook exits 0 (got $rc)"
[ "$(ncap "$out")" = 0 ] && pass "43i: cap-extra [08] read as 8 -> 6/13 silent" || fail "43i: cap-extra [08] read as 8 -> 6/13 silent"
reset_all; printf '010' > "$capf"; printf '1' > "$capxf"; rev; rev; rev; rev; rev; rev; rev; rev; rev; rev
out=$(revout); rc=$?
[ "$rc" = 0 ] && pass "43i: cap [010] + extra 1 -> hook exits 0" || fail "43i: cap [010] + extra 1 -> hook exits 0 (got $rc)"
printf '%s' "$out" | grep -qF 'pass cap reached (11/11)' && pass "43i: cap [010] read as 10, extra 1 -> 11/11" || fail "43i: cap [010] read as 10, extra 1 -> 11/11"
reset_all; printf '9223372036854775807' > "$capxf"; rev; rev; rev; rev
out=$(revout); rc=$?
[ "$rc" = 0 ] && pass "43i: cap-extra past nine digits -> hook exits 0" || fail "43i: cap-extra past nine digits -> hook exits 0 (got $rc)"
[ "$(ncap "$out")" = 1 ] && pass "43i: cap-extra past nine digits ignored -> message at 5/5" || fail "43i: cap-extra past nine digits ignored -> message at 5/5"
# A COUNT is compared with the effective cap as long as the comparison is representable:
# two nine-digit values can sum to ten digits, and a count below that sum is below the cap.
# Nineteen digits or more is past any cap this hook can hold, so it fires (invariant 2).
reset_all; printf '999999999' > "$capf"; printf '999999999' > "$capxf"; printf 'x' > "$state"
printf '1000000000' > "$count"
[ "$(ncap "$(commitpre)")" = 0 ] && pass "43i: ten-digit count below a ten-digit cap -> silent" || fail "43i: ten-digit count below a ten-digit cap -> silent"
printf '1999999998' > "$count"
printf '%s' "$(commitpre)" | grep -qF 'pass cap reached (1999999998/1999999998)' && pass "43i: ten-digit count at a ten-digit cap -> message" || fail "43i: ten-digit count at a ten-digit cap -> message"
reset_all; printf '1000000000000000000' > "$count"; printf 'x' > "$state"
[ "$(ncap "$(commitpre)")" = 1 ] && pass "43i: nineteen-digit pass count -> cap message" || fail "43i: nineteen-digit pass count -> cap message"
# Surrounding blank lines are edges too; an internal break is still not.
reset_all; printf '\n 3 \n' > "$capf"; rev; rev
printf '%s' "$(revout)" | grep -qF 'pass cap reached (3/3)' && pass "43i: cap file padded with blank lines -> 3" || fail "43i: cap file padded with blank lines -> 3"
reset_all; printf '2\n3' > "$capxf"; rev; rev; rev; rev
[ "$(ncap "$(revout)")" = 1 ] && pass "43i: cap-extra with an internal line break ignored" || fail "43i: cap-extra with an internal line break ignored"

# 43j. A Gate-A cycle at its cap reaches its closing commit through a commit attempt, so the
#      commit attempt carries the Gate-A cap message too (spec branch, pass 1).
reset_all; execp; execp; execp; execp; execp
out=$(commitpre)
printf '%s' "$out" | grep -qF '⚠ Codex Gate A: pass cap reached (5/5).' && pass "43j: commit attempt at the Gate-A cap -> Gate A cap message" || fail "43j: commit attempt at the Gate-A cap -> Gate A cap message"
one_doc "43j: commit attempt at the Gate-A cap" "$out"
# The WIP and docs-only notes say what they skip — the fingerprint and floor checks — so
# the cap message beside them is not a contradiction (pass 2, both branches).
reset_all; rev; rev; rev; rev; rev
out=$(run '{"hook_event_name":"PreToolUse","tool_name":"Bash","tool_input":{"command":"git commit -m \"wip: snapshot\""}}')
printf '%s' "$out" | grep -qF 'fingerprint and floor are not evaluated here' && pass "43j: WIP note names what it skips" || fail "43j: WIP note names what it skips"
[ "$(ncap "$out")" = 1 ] && pass "43j: WIP commit at the cap -> cap message once" || fail "43j: WIP commit at the cap -> cap message once"
one_doc "43j: WIP commit at the cap" "$out"
mkdir -p docs && printf 'spec\n' > docs/plan.md && git add docs/plan.md >/dev/null 2>&1
out=$(commitpre)
printf '%s' "$out" | grep -qF 'fingerprint and floor checks do not apply' && pass "43j: docs-only note names what it skips" || fail "43j: docs-only note names what it skips"
[ "$(ncap "$out")" = 1 ] && pass "43j: docs-only commit at the cap -> cap message once" || fail "43j: docs-only commit at the cap -> cap message once"
git reset -q >/dev/null 2>&1; rm -rf docs
reset_all

# 44. COMPACTION RE-INJECTION (story S4, 2026-10-12). hooks.json registers SessionStart with
#     matcher `compact`; Claude Code adds a SessionStart hook's plain stdout to the model's
#     context, so the hook prints at most ten plain lines from state that exists and exits 0:
#     line 1 always (the rules pointer); line 2 the cycle (nonce from the newest findings
#     slot, both counts over the floor, the fingerprint freshness); line 3 the open stop.
#     No JSON, no new state file.
compact() { run '{"hook_event_name":"SessionStart","source":"compact","session_id":"s","cwd":"."}'; }
nlines() { printf '%s\n' "$1" | grep -c ''; }
line1='dev-workflow: context was compacted. Binding rules file: .claude/review-gates.md (read it before gate work).'
reviews=.context/codex-reviews
mkdir -p "$reviews"

# 44a. no state -> exactly line 1, no JSON, exit 0. The opt-out marker silences this too
#      (README and the degraded-mode setup promise silence while it exists), a repository
#      that has not adopted the workflow hears nothing, and a SessionStart that is not a
#      compaction prints nothing (the registration matches `compact` only; the branch
#      checks `source` so a wider registration cannot announce a compaction that was not).
reset_all; rm -f "$reviews"/gate-*
out=$(compact); rc=$?
[ "$rc" = 0 ] && pass "44a: compaction with no state exits 0" || fail "44a: compaction with no state exits 0 (got $rc)"
[ "$out" = "$line1" ] && pass "44a: no state -> exactly line 1" || fail "44a: no state -> exactly line 1 (got [$out])"
: > "$offf"
out=$(compact); rc=$?
[ "$rc" = 0 ] && [ -z "$out" ] && pass "44a: opt-out marker -> compaction prints nothing" || fail "44a: opt-out marker -> compaction prints nothing (rc $rc, got [$out])"
rm -f "$offf"
mv .context/codex-gate.on "$sandbox/on.bak"
out=$(compact); rc=$?
[ "$rc" = 0 ] && [ -z "$out" ] && pass "44a: non-adopted repository -> compaction prints nothing" || fail "44a: non-adopted repository -> compaction prints nothing (rc $rc, got [$out])"
mv "$sandbox/on.bak" .context/codex-gate.on
out=$(run '{"hook_event_name":"SessionStart","source":"startup","session_id":"s","cwd":"."}'); rc=$?
[ "$rc" = 0 ] && [ -z "$out" ] && pass "44a: SessionStart with source startup -> nothing" || fail "44a: SessionStart with source startup -> nothing (rc $rc, got [$out])"

# 44b. full state -> three lines, every segment from its source
reset_all; rev; rev; execp
printf 'MAJOR | high | x | y | z | w\nEND OF FINDINGS (1 total)\n' > "$reviews/gate-b-spec-abcdefgh-pass-1.md"
out=$(compact); rc=$?
[ "$rc" = 0 ] && pass "44b: compaction with full state exits 0" || fail "44b: compaction with full state exits 0 (got $rc)"
[ "$(nlines "$out")" = 3 ] && pass "44b: full state -> three lines" || fail "44b: full state -> three lines (got $(nlines "$out"))"
[ "$(printf '%s\n' "$out" | sed -n 1p)" = "$line1" ] && pass "44b: line 1 is the rules pointer" || fail "44b: line 1 is the rules pointer"
l2=$(printf '%s\n' "$out" | sed -n 2p)
[ "$l2" = 'Gate cycle: nonce abcdefgh · Gate A passes 1/3 · Gate B passes 2/3 · fingerprint fresh' ] \
  && pass "44b: line 2 carries nonce, both counts and a fresh fingerprint" || fail "44b: line 2 carries nonce, both counts and a fresh fingerprint (got [$l2])"
[ "$(printf '%s\n' "$out" | sed -n 3p)" = 'Open stop: none' ] && pass "44b: line 3 reports no open stop" || fail "44b: line 3 reports no open stop"
printf '%s' "$out" | grep -q 'hookSpecificOutput' && fail "44b: compaction output is plain text, not JSON" || pass "44b: compaction output is plain text, not JSON"

# 44c. the fingerprint segment: stale after an edit, unavailable when recorded so, and the
#      recorded value is read exactly as the commit check reads it — a stored hash with a
#      space in it cannot confirm anything there, so it is stale here, never fresh.
printf 'edit\n' >> app.ts
printf '%s' "$(compact)" | grep -q 'fingerprint stale' && pass "44c: edit after review -> fingerprint stale" || fail "44c: edit after review -> fingerprint stale"
git checkout -- app.ts >/dev/null 2>&1
h44=$(cat "$state")
printf ' %s' "$h44" > "$state"
printf '%s' "$(compact)" | grep -q 'fingerprint stale' && pass "44c: whitespace inside the recorded fingerprint -> stale, as at commit" || fail "44c: whitespace inside the recorded fingerprint -> stale, as at commit"
printf '%s' "$h44" > "$state"
printf 'unavailable' > "$state"
printf '%s' "$(compact)" | grep -q 'fingerprint unavailable' && pass "44c: recorded unavailable -> fingerprint unavailable" || fail "44c: recorded unavailable -> fingerprint unavailable"

# 44d. the newest USABLE slot wins — by mtime, not by name, and a newer directory or legacy
#      bare slot does not hide an older file that carries a nonce; a legacy slot alone
#      carries none; partial state prints only the segments it has.
# The older slot sorts FIRST by name, so a listing that lost its mtime order would pick it.
rm -f "$reviews"/gate-*
printf 'NO FINDINGS\nEND OF FINDINGS (0 total)\n' > "$reviews/gate-a-plan-aa11aa11aa-pass-1.md"
printf 'NO FINDINGS\nEND OF FINDINGS (0 total)\n' > "$reviews/gate-b-spec-zz99zz99zz-pass-2.md"
touch -t 202601010000 "$reviews/gate-a-plan-aa11aa11aa-pass-1.md"
touch -t 202601020000 "$reviews/gate-b-spec-zz99zz99zz-pass-2.md"
printf '%s' "$(compact)" | grep -q 'nonce zz99zz99zz' && pass "44d: newest slot by mtime supplies the nonce" || fail "44d: newest slot by mtime supplies the nonce"
touch -t 202601030000 "$reviews/gate-a-plan-aa11aa11aa-pass-1.md"
printf '%s' "$(compact)" | grep -q 'nonce aa11aa11aa' && pass "44d: touching the name-first slot makes it newest" || fail "44d: touching the name-first slot makes it newest"
# The rules name a pass's dispositions `…-pass-<n>-dispositions.md`; written last, it is the newest
printf '1 | fixed | x\n' > "$reviews/gate-b-spec-zz99zz99zz-pass-2-dispositions.md"
touch -t 202601040000 "$reviews/gate-b-spec-zz99zz99zz-pass-2-dispositions.md"
printf '%s' "$(compact)" | grep -q 'nonce zz99zz99zz' && pass "44d: a newer dispositions file supplies its own slot's nonce" || fail "44d: a newer dispositions file supplies its own slot's nonce"
rm -f "$reviews/gate-b-spec-zz99zz99zz-pass-2-dispositions.md"
rm -f "$reviews/gate-a-plan-aa11aa11aa-pass-1.md"
mkdir -p "$reviews/gate-b-spec-newdir0000-pass-9.md"
printf 'NO FINDINGS\nEND OF FINDINGS (0 total)\n' > "$reviews/gate-b-spec-pass-1.md"
printf '%s' "$(compact)" | grep -q 'nonce zz99zz99zz' && pass "44d: newer directory and legacy slot do not hide the older nonce" || fail "44d: newer directory and legacy slot do not hide the older nonce"
rmdir "$reviews/gate-b-spec-newdir0000-pass-9.md"
rm -f "$reviews"/gate-*
printf 'NO FINDINGS\nEND OF FINDINGS (0 total)\n' > "$reviews/gate-b-spec-pass-1.md"
out=$(compact)
printf '%s' "$out" | grep -q 'nonce' && fail "44d: legacy bare slot -> no nonce segment" || pass "44d: legacy bare slot -> no nonce segment"
reset_all; rm -f "$reviews"/gate-*; execp
l2=$(printf '%s\n' "$(compact)" | sed -n 2p)
[ "$l2" = 'Gate cycle: Gate A passes 1/3' ] && pass "44d: Gate A count alone -> only that segment" || fail "44d: Gate A count alone -> only that segment (got [$l2])"

# 44e. the open stop: a gate at its cap
reset_all; rm -f "$reviews"/gate-*; rev; rev; rev; rev; rev
printf '%s' "$(compact)" | grep -q 'Open stop: pass cap reached — answer pending' && pass "44e: cap reached -> open stop reported" || fail "44e: cap reached -> open stop reported"
printf '2' > "$capxf"
printf '%s' "$(compact)" | grep -q 'Open stop: none' && pass "44e: cap-extra on file -> no open stop" || fail "44e: cap-extra on file -> no open stop"

# 44f. corrupt state -> exit 0, prints what it can, never more than ten lines. A count that
#      exists but cannot be read as a number is `?`, and with one in play the open stop is
#      `unknown`, never `none`: an unreadable counter may hide a pending cap stop.
reset_all; rm -f "$reviews"/gate-*
printf 'garbage\n\n\n' > "$count"; printf '1' > "$countA"; printf '\n' > "$state"
out=$(compact); rc=$?
[ "$rc" = 0 ] && pass "44f: corrupt state exits 0" || fail "44f: corrupt state exits 0 (got $rc)"
[ "$(nlines "$out")" -le 10 ] && pass "44f: corrupt state -> at most ten lines" || fail "44f: corrupt state -> at most ten lines"
[ "$(printf '%s\n' "$out" | sed -n 1p)" = "$line1" ] && pass "44f: corrupt state -> line 1 still printed" || fail "44f: corrupt state -> line 1 still printed"
printf '%s' "$out" | grep -q 'Gate B passes ?/3' && pass "44f: unreadable count prints ?" || fail "44f: unreadable count prints ?"
printf '%s' "$out" | grep -q 'fingerprint unavailable' && pass "44f: blank recorded fingerprint -> unavailable" || fail "44f: blank recorded fingerprint -> unavailable"
printf '%s' "$out" | grep -q 'Open stop: unknown (unreadable pass count)' && pass "44f: unreadable count -> open stop unknown" || fail "44f: unreadable count -> open stop unknown"
# A huge numeric count is a number past any cap: it fires, as cap_check does, and the
# line stays one line.
reset_all; printf '%s\n' "$(printf '%0400d' 0)" > "$countA"
out=$(compact); rc=$?
[ "$rc" = 0 ] && [ "$(nlines "$out")" = 3 ] && pass "44f: a 400-digit count -> three lines, exit 0" || fail "44f: a 400-digit count -> three lines, exit 0 (rc $rc, $(nlines "$out") lines)"
printf '%s' "$out" | grep -q 'Open stop: pass cap reached' && pass "44f: a 400-digit count -> past the cap" || fail "44f: a 400-digit count -> past the cap"
reset_all; printf '5' > "$count"; chmod 0000 "$count" 2>/dev/null
if probe_denies "cat \"$count\""; then
  out=$(compact); rc=$?
  [ "$rc" = 0 ] && pass "44f: count file denied -> exits 0" || fail "44f: count file denied -> exits 0 (got $rc)"
  printf '%s' "$out" | grep -q 'Gate B passes ?/3' && pass "44f: count file denied -> ?, not 0" || fail "44f: count file denied -> ?, not 0"
  printf '%s' "$out" | grep -q 'Open stop: unknown' && pass "44f: count file denied -> open stop unknown" || fail "44f: count file denied -> open stop unknown"
else
  skip "44f: unreadable count file (chmod does not deny reads here — running as root?)"
fi
chmod 0644 "$count" 2>/dev/null
# A FIFO at a state path is never read (cat would block until a writer appears). Bounded
# wait, so a regression fails instead of hanging the suite.
reset_all; rm -f "$count" "$state"; mkfifo "$count" "$state" 2>/dev/null
if [ -p "$count" ] && [ -p "$state" ]; then
  compact > "$sandbox/fifo.out" 2>/dev/null & fp44=$!
  i44=0; while kill -0 "$fp44" 2>/dev/null && [ "$i44" -lt 5 ]; do sleep 1; i44=$((i44 + 1)); done
  if kill -0 "$fp44" 2>/dev/null; then
    kill "$fp44" 2>/dev/null; : > "$count" 2>/dev/null & : > "$state" 2>/dev/null & wait
    fail "44f: FIFO at a state path -> hook finishes (it blocked)"
  else
    wait "$fp44"; pass "44f: FIFO at a state path -> hook finishes"
    out=$(cat "$sandbox/fifo.out")
    printf '%s' "$out" | grep -q 'Gate B passes ?/3' && pass "44f: FIFO count -> ?" || fail "44f: FIFO count -> ?"
    printf '%s' "$out" | grep -q 'fingerprint unavailable' && pass "44f: FIFO fingerprint -> unavailable" || fail "44f: FIFO fingerprint -> unavailable"
  fi
else
  skip "44f: mkfifo unavailable here"
fi
rm -f "$count" "$state" "$sandbox/fifo.out"

# 44h. A checkout path with spaces keeps the nonce: only basenames are word-split.
sp44="$sandbox/repo with space"
mkdir -p "$sp44/.context/codex-reviews"
( cd "$sp44" && git init -q && : > .context/codex-gate.on \
  && printf 'NO FINDINGS\nEND OF FINDINGS (0 total)\n' > .context/codex-reviews/gate-b-spec-spaced001-pass-1.md \
  && printf '%s' '{"hook_event_name":"SessionStart","source":"compact","session_id":"s","cwd":"."}' | "$HOOK_SH_BIN" "$HOOK" ) > "$sandbox/sp.out" 2>/dev/null
grep -q 'nonce spaced001' "$sandbox/sp.out" && pass "44h: checkout path with spaces keeps the nonce" || fail "44h: checkout path with spaces keeps the nonce"
rm -rf "$sp44" "$sandbox/sp.out"

# 44g. jq-free path: the same first line with no state, and the full three lines with state.
reset_all; rm -f "$reviews"/gate-*
out=$(nojq_run '{"hook_event_name":"SessionStart","source":"compact","session_id":"s","cwd":"."}')
[ "$out" = "$line1" ] && pass "44g: jq-free compaction -> line 1" || fail "44g: jq-free compaction -> line 1 (got [$out])"
reset_all; rev; rev; execp
printf 'NO FINDINGS\nEND OF FINDINGS (0 total)\n' > "$reviews/gate-b-quality-jqfree001-pass-1.md"
out=$(nojq_run '{"hook_event_name":"SessionStart","source":"compact","session_id":"s","cwd":"."}')
[ "$(printf '%s\n' "$out" | sed -n 2p)" = 'Gate cycle: nonce jqfree001 · Gate A passes 1/3 · Gate B passes 2/3 · fingerprint fresh' ] \
  && pass "44g: jq-free compaction -> full line 2" || fail "44g: jq-free compaction -> full line 2 (got [$(printf '%s\n' "$out" | sed -n 2p)])"
[ "$(printf '%s\n' "$out" | sed -n 3p)" = 'Open stop: none' ] && pass "44g: jq-free compaction -> line 3" || fail "44g: jq-free compaction -> line 3"
rm -f "$reviews"/gate-*
reset_all

# 45. Field defects (S5). Each case gets its own repo under $sandbox, so the suite repo's
# fingerprint is untouched.
mk45() { # $1 = repo dir: an adopted repo with one commit
  mkdir -p "$1" && ( cd "$1" && git init -q && git config user.email t@t && git config user.name t \
    && mkdir -p .context && : > .context/codex-gate.on && printf 'v1\n' > app.ts \
    && git add app.ts && git commit -qm init ) >/dev/null 2>&1
}
in45() { ( cd "$1" && printf '%s' "$2" | "$HOOK_SH_BIN" "$HOOK" ) 2>/dev/null; } # $1 = cwd, $2 = payload
rev45="$(payload mcp__codex__review "$(resp_success)")"
pre45() { printf '{"hook_event_name":"PreToolUse","tool_name":"Bash","tool_input":{"command":"%s"}}' "$1"; }

# 45a. A gitignored .context/ (canvas, Bricks) made `add -A` with the exclude pathspec fail,
# so every pass stored `unavailable`. Both ignore spellings and info/exclude.
for ig in '.context/' '.context' 'exclude'; do
  r="$sandbox/r45a"; rm -rf "$r"; mk45 "$r"
  if [ "$ig" = exclude ]; then mkdir -p "$r/.git/info"; printf '.context/\n' >> "$r/.git/info/exclude"
  else printf '%s\n' "$ig" > "$r/.gitignore"; (cd "$r" && git add .gitignore && git commit -qm ig) >/dev/null 2>&1; fi
  in45 "$r" "$rev45" >/dev/null
  h=$(cat "$r/.context/codex-gate.gateB" 2>/dev/null)
  [ -n "$h" ] && [ "$h" != unavailable ] && pass "45a: ignored .context ($ig) -> pass stores a fingerprint" \
    || fail "45a: ignored .context ($ig) -> pass stores a fingerprint (got [$h])"
  out=$(in45 "$r" "$(pre45 'git commit -m x')")
  case "$out" in *'below floor (1/3)'*) pass "45a: ignored .context ($ig) -> unchanged content is not 'cannot confirm'" ;;
    *) fail "45a: ignored .context ($ig) -> unchanged content is not 'cannot confirm' (got [$out])" ;; esac
done

# 45b. An uncomputable fingerprint stays `unavailable` and the hook names the component.
r="$sandbox/r45b"; rm -rf "$r"; mk45 "$r"; printf 's\n' > "$r/secret"; chmod 000 "$r/secret"
if [ -r "$r/secret" ]; then
  skip "45b: chmod 000 does not deny reads here (root?)"
else
  out=$(in45 "$r" "$rev45")
  [ "$(cat "$r/.context/codex-gate.gateB" 2>/dev/null)" = unavailable ] && pass "45b: unreadable file -> state is unavailable" \
    || fail "45b: unreadable file -> state is unavailable"
  case "$out" in *'worktree tree'*) pass "45b: review pass names the failing component" ;;
    *) fail "45b: review pass names the failing component (got [$out])" ;; esac
  out=$(in45 "$r" "$(pre45 'git commit -m x')")
  case "$out" in *'worktree tree'*) pass "45b: commit check names the failing component" ;;
    *) fail "45b: commit check names the failing component (got [$out])" ;; esac
fi
chmod 600 "$r/secret" 2>/dev/null

# 45c. A failed state write must not leave the previous fingerprint standing.
r="$sandbox/r45c"; rm -rf "$r"; mk45 "$r"
in45 "$r" "$rev45" >/dev/null; printf 'v2\n' > "$r/app.ts"; chmod 444 "$r/.context/codex-gate.gateB"
out=$(in45 "$r" "$rev45")
[ ! -e "$r/.context/codex-gate.gateB" ] && pass "45c: unwritable state file -> no stale fingerprint left" \
  || fail "45c: unwritable state file -> no stale fingerprint left (got [$(cat "$r/.context/codex-gate.gateB")])"
case "$out" in *'could not be stored'*) pass "45c: failed write is reported" ;;
  *) fail "45c: failed write is reported (got [$out])" ;; esac

# 45d. A read-only state file in a read-only .context/ keeps an older fingerprint; it is
# never confirmed, even once the content matches it again.
r="$sandbox/r45d"; rm -rf "$r"; mk45 "$r"
in45 "$r" "$rev45" >/dev/null; in45 "$r" "$rev45" >/dev/null; in45 "$r" "$rev45" >/dev/null
chmod 444 "$r/.context/codex-gate.gateB"; chmod 555 "$r/.context"
if probe_denies "rm -f \"$r/.context/codex-gate.gateB\""; then
  printf 'v2\n' > "$r/app.ts"; in45 "$r" "$rev45" >/dev/null; printf 'v1\n' > "$r/app.ts"
  out=$(in45 "$r" "$(pre45 'git commit -m x')")
  case "$out" in *'cannot confirm'*) pass "45d: unremovable stale fingerprint -> cannot confirm" ;;
    *) fail "45d: unremovable stale fingerprint -> cannot confirm (got [$out])" ;; esac
  out=$(in45 "$r" '{"hook_event_name":"SessionStart","source":"compact","session_id":"s","cwd":"."}')
  case "$out" in *'fingerprint unavailable'*) pass "45d: compaction agrees: unavailable" ;;
    *) fail "45d: compaction agrees: unavailable (got [$out])" ;; esac
else
  skip "45d: chmod does not deny removal here (root?)"
fi
chmod 755 "$r/.context"; chmod 644 "$r/.context/codex-gate.gateB" 2>/dev/null

# 45e. An unreadable file inside a NOT-ignored .context/ does not make the fingerprint
# uncomputable: .context is excluded before it is read.
r="$sandbox/r45e"; rm -rf "$r"; mk45 "$r"; printf 'p\n' > "$r/.context/private"; chmod 000 "$r/.context/private"
in45 "$r" "$rev45" >/dev/null
h=$(cat "$r/.context/codex-gate.gateB" 2>/dev/null)
[ -n "$h" ] && [ "$h" != unavailable ] && pass "45e: unreadable .context file -> fingerprint still computed" \
  || fail "45e: unreadable .context file -> fingerprint still computed (got [$h])"
chmod 600 "$r/.context/private"
rm -rf "$sandbox/r45a" "$sandbox/r45b" "$sandbox/r45c" "$sandbox/r45d" "$sandbox/r45e"

# 46. A WIP-looking commit the WIP allow-list refuses, with `git commit` at a command
# position, gets one more sentence before the
# commit (field evidence 2026-10-19/20: `cd …;` and `git -C` WIP commits read as kept).
# $1 = the command as a JSON string body. Both readers, every refused form, and neither
# the plain WIP form nor a non-WIP commit.
wipsent="This call is not counted as a WIP commit, so the pass counters are cleared after it unless the hook sees HEAD and its reflog unchanged; a WIP commit is one git commit -m 'WIP: <subject>' Bash call with a plain subject, run from the repository, with no cd, git -C, heredoc, or chain other than one leading git add <paths> &&; causes: https://github.com/dsnger/dev-workflow-kit/blob/main/docs/reference.md#hook-messages."
pre46() { printf '{"hook_event_name":"PreToolUse","tool_name":"Bash","tool_use_id":"toolu_t46","tool_input":{"command":"%s"}}' "$1"; }
for r in run nojq_run; do
  # shellcheck disable=SC2016  # the $( ) is payload text for the hook, never expanded here
  for c in "cd $work; git commit -m 'WIP: a'" \
           "git -C $work commit -m 'WIP: a'" \
           "git add app.ts && git add b.ts && git commit -m 'WIP: a'" \
           "git commit -am 'WIP: a' && true" \
           'git commit -m \"$(cat <<'"'"'EOF'"'"'\nWIP: a\nEOF\n)\"' \
           "git commit -m \$'WIP: a'" \
           "git commit -m \\\\\n'WIP: a'"; do
    reset_all; rev
    out=$($r "$(pre46 "$c")")
    printf '%s' "$out" | grep -qF "$wipsent" && pass "46 $r: refused WIP form gets the sentence: $c" \
      || fail "46 $r: refused WIP form gets the sentence: $c [$out]"
  done
  # The sentence goes only where `git commit` stands as a command of its own (runs_git_commit):
  # not on a plain WIP form (one leading git add included), a non-WIP message, or a commit hidden in quotes.
  for c in "git commit -m 'WIP: a'" "git add app.ts && git commit -m 'WIP: a'" "git commit -m 'fix: a'" "cd $work; git commit -m 'fix: a'" \
           "sh -c \\\"git commit -m 'WIP: a'\\\""; do
    reset_all; rev
    out=$($r "$(pre46 "$c")")
    printf '%s' "$out" | grep -qF 'not counted as a WIP commit' && fail "46 $r: no sentence: $c [$out]" \
      || pass "46 $r: no sentence: $c"
  done
done

# 47. An exec call whose input carries a sessionId resumes a Codex session (canvas field case
# 2026-10-21: a call that only re-fetched a truncated reply was counted as a Gate-A pass).
# Read with jq only; without jq every call counts, as before 0.40.
resumedA_ctx="Claude via Claude Code — gate hook. <state>This mcp__codex__exec call carries a sessionId in its input, so it resumes a Codex session and is not counted as a Gate A pass.</state> <next>A call that fetches the rest of a truncated reply belongs to the pass it completes. If this call was a pass of its own, run it again without sessionId, because a pass reviews the artifact as it stands, not as an earlier session saw it.</next>"
resumedA_msg="ℹ Codex Gate A: resumed session not counted as a pass"
exec47() { printf '{"hook_event_name":"PostToolUse","tool_name":"mcp__codex__exec","tool_input":{%s},"tool_response":%s}' "$1" "$2"; }
nA() { cat "$countA" 2>/dev/null || printf '0'; }
# The detection cases need jq on this host; the jq-free case at the end runs everywhere.
if command -v jq >/dev/null 2>&1; then
reset_all; execp
out=$(run "$(exec47 '"instruction":"more","sessionId":"abc"' "$(resp_success)")")
[ "$(nA)" = 1 ] && pass "47: resumed exec not counted" || fail "47: resumed exec not counted (count $(nA))"
exact_pair "47: resumed exec note" "$out" "$resumedA_ctx" "$resumedA_msg"
reset_all
run "$(exec47 '"instruction":"more","sessionId":"abc"' "$(unrec)")" >/dev/null
[ "$(nA)" = 0 ] && pass "47: resumed unrecognized exec not counted" || fail "47: resumed unrecognized exec not counted (count $(nA))"
reset_all
run "$(exec47 '"instruction":"x","sessionId":""' "$(resp_success)")" >/dev/null
[ "$(nA)" = 1 ] && pass "47: empty sessionId counts" || fail "47: empty sessionId counts (count $(nA))"
reset_all
out=$(run "$(exec47 '"instruction":"x","sessionId":"abc"' "$(resp_from shape1-fast-fail)")")
[ "$(nA)" = 0 ] && printf '%s' "$out" | grep -qF 'not counted as a gate pass' && ! printf '%s' "$out" | grep -qF 'resumed session' \
  && pass "47: resumed failure takes the discard note" || fail "47: resumed failure takes the discard note [$out]"
# A response that names sessionId does not answer for the input: escaped inside the text (every
# real envelope), or as a structured key; nor does a pretty-printed payload change that.
reset_all
run "$(exec47 '"instruction":"x"' "$(resp_success)")" >/dev/null
run "$(exec47 '"instruction":"x"' '[{"type":"text","text":"{\"success\": true}","sessionId":"x"}]')" >/dev/null
run "$(printf '{"hook_event_name":"PostToolUse","tool_name":"mcp__codex__exec","tool_input":{\n "instruction":"x",\n "sessionId":"abc"\n},\n"tool_response":%s}' "$(resp_success)")" >/dev/null
[ "$(nA)" = 2 ] && pass "47: response-only sessionId counts; multiline input sessionId does not" || fail "47: response-only sessionId counts; multiline input sessionId does not (count $(nA))"
else
  skip "47: sessionId detection cases — no jq on this host; the jq-free case below still runs"
fi
# Without jq the hook does not read sessionId: the resumed call counts, as before 0.40.
reset_all
out=$(nojq_run "$(exec47 '"instruction":"more","sessionId":"abc"' "$(resp_success)")")
[ "$(nA)" = 1 ] && ! printf '%s' "$out" | grep -qF 'resumed session' && pass "47 nojq: resumed exec counts, no note" \
  || fail "47 nojq: resumed exec counts, no note (count $(nA)) [$out]"

# 48. The closing-commit recipe the rules prescribe (canvas s4nachl1/s4bau2gb, 2026-10-21): a
# staged todos.md committed by a plain `git commit -F .context/<msg>` reaches the docs-only
# note; the chained form the field used does not. Behaviour is unchanged; this pins the recipe.
pre48() { printf '{"hook_event_name":"PreToolUse","tool_name":"Bash","tool_input":{"command":"%s"}}' "$1"; }
for r in run nojq_run; do
  reset_all; rev; rev; rev
  printf 'cycle lines\n' > .context/msg
  printf 'row\n' > todos.md; git add todos.md
  out=$($r "$(pre48 'git commit -F .context/msg')")
  printf '%s' "$out" | grep -qF 'Codex Gate B N/A (docs-only commit)' && pass "48 $r: staged todos.md + plain -F -> docs-only" \
    || fail "48 $r: staged todos.md + plain -F -> docs-only [$out]"
  out=$($r "$(pre48 'git add todos.md && git commit -F .context/msg')")
  printf '%s' "$out" | grep -qF 'cannot confirm reviewed content' && pass "48 $r: chained form -> cannot confirm" \
    || fail "48 $r: chained form -> cannot confirm [$out]"
  printf 'v2\n' > app.ts; git add app.ts
  out=$($r "$(pre48 'git commit -F .context/msg')")
  printf '%s' "$out" | grep -qF 'cannot confirm reviewed content' && pass "48 $r: todos.md + code -> full check" \
    || fail "48 $r: todos.md + code -> full check [$out]"
  git rm -q --cached todos.md; rm -f todos.md; git checkout -q HEAD -- app.ts
  reset_all; rev; rev; rev
  printf 'cycle lines, written after the review\n' > .context/msg
  out=$($r "$(pre48 'git commit --allow-empty -F .context/msg')")
  printf '%s' "$out" | grep -qF '✓ Codex Gate B hook checks passed (3/3 cycle' && pass "48 $r: empty closing commit, message in .context/ -> ✓" \
    || fail "48 $r: empty closing commit, message in .context/ -> ✓ [$out]"
  rm -f .context/msg
done

reset_all
echo "---"
[ "$fails" -eq 0 ] && { echo "all passed"; exit 0; } || { echo "$fails failed"; exit 1; }
