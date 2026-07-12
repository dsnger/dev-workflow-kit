#!/bin/sh
# Tests for codex-gate.sh. Run: sh plugins/dev-workflow/hooks/codex-gate.test.sh
# (from an installed plugin: sh "$CLAUDE_PLUGIN_ROOT"/hooks/codex-gate.test.sh)
set -u
HOOK="$(cd "$(dirname "$0")" && pwd)/codex-gate.sh"
fails=0
pass() { printf 'ok   - %s\n' "$1"; }
fail() { printf 'FAIL - %s\n' "$1"; fails=$((fails + 1)); }

work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
cd "$work" || exit 1
git init -q
mkdir -p .context
state=".context/codex-gate.gateB"
count=".context/codex-gate.passCount"
countA=".context/codex-gate.passCountA"
run() { printf '%s' "$1" | sh "$HOOK"; }
rev() { run '{"hook_event_name":"PostToolUse","tool_name":"mcp__codex__review","tool_input":{}}' >/dev/null; }
commitpre() { run '{"hook_event_name":"PreToolUse","tool_name":"Bash","tool_input":{"command":"git commit -m x"}}'; }

# 1. SET on review + bump pass count
rev
[ -f "$state" ] && pass "review creates state" || fail "review creates state"
[ "$(cat "$count" 2>/dev/null)" = 1 ] && pass "review bumps pass count to 1" || fail "review bumps pass count to 1"

# 2. Below floor (1/3) -> NOT satisfied yet; reaching floor (3/3) -> satisfied
out=$(commitpre)
printf '%s' "$out" | grep -q 'below floor\|floor NOT met' && pass "1/3 passes -> below floor" || fail "1/3 passes -> below floor"
printf '%s' "$out" | grep -q 'hookSpecificOutput' && pass "emits JSON additionalContext" || fail "emits JSON additionalContext"
rev; rev  # reach the floor: 3 passes total
out=$(commitpre)
printf '%s' "$out" | grep -q 'Gate B satisfied' && pass "3/3 passes -> satisfied" || fail "3/3 passes -> satisfied"

# 3. INVALIDATE on edit flips to not-satisfied (the Major)
run '{"hook_event_name":"PostToolUse","tool_name":"Edit","tool_input":{"file_path":"a"}}' >/dev/null
[ ! -f "$state" ] && pass "edit invalidates state" || fail "edit invalidates state"
out=$(run '{"hook_event_name":"PreToolUse","tool_name":"Bash","tool_input":{"command":"git commit -m x"}}')
printf '%s' "$out" | grep -q 'not satisfied' && pass "commit after edit -> warn" || fail "commit after edit -> warn"

# 4. Gate A exec must NOT satisfy Gate B (separate state)
rm -f "$state"
run '{"hook_event_name":"PostToolUse","tool_name":"mcp__codex__exec","tool_input":{}}' >/dev/null
[ ! -f "$state" ] && pass "exec does not set Gate B" || fail "exec does not set Gate B"

# 5. RESET on commit
: > "$state"
run '{"hook_event_name":"PostToolUse","tool_name":"Bash","tool_input":{"command":"git commit -m x"}}' >/dev/null
[ ! -f "$state" ] && pass "commit resets state" || fail "commit resets state"

# 6. Gate A reminder only for plan-execution skills
out=$(run '{"hook_event_name":"PreToolUse","tool_name":"Skill","tool_input":{"skill":"superpowers:executing-plans"}}')
printf '%s' "$out" | grep -q 'Gate A' && pass "executing-plans -> Gate A reminder" || fail "executing-plans -> Gate A reminder"
out=$(run '{"hook_event_name":"PreToolUse","tool_name":"Skill","tool_input":{"skill":"superpowers:brainstorming"}}')
[ -z "$out" ] && pass "other skill -> no reminder" || fail "other skill -> no reminder"

# 7. Loose commit matcher (incl. no-space and semicolon separators)
: > "$state"
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

# 9. jq-absent fallback (best effort: build a PATH without jq)
nojq="$work/nojq"; mkdir -p "$nojq"; ok=1
for t in git grep sed head cat mkdir rm touch; do
  p=$(command -v "$t" 2>/dev/null) && ln -s "$p" "$nojq/$t" 2>/dev/null || ok=0
done
if [ "$ok" = 1 ] && ! PATH="$nojq" command -v jq >/dev/null 2>&1; then
  : > "$state"
  out=$(printf '%s' '{"hook_event_name":"PreToolUse","tool_name":"Bash","tool_input":{"command":"git commit -m x"}}' | PATH="$nojq" /bin/sh "$HOOK")
  printf '%s' "$out" | grep -q 'Gate B' && pass "jq-absent fallback works" || fail "jq-absent fallback works"
  # 9b. fallback must not be confused by a literal } inside the command (false-negative regression)
  : > "$state"
  out=$(printf '%s' '{"hook_event_name":"PreToolUse","tool_name":"Bash","tool_input":{"command":"git commit -m }"}}' | PATH="$nojq" /bin/sh "$HOOK")
  printf '%s' "$out" | grep -q 'Gate B' && pass "jq-absent: brace in command still matches" || fail "jq-absent: brace in command still matches"
else
  printf 'skip - jq-absent fallback (could not build jq-free PATH)\n'
fi

# 10. additionalContext JSON field is present + non-empty (the emit channel)
if command -v jq >/dev/null 2>&1; then
  out=$(run '{"hook_event_name":"PreToolUse","tool_name":"Skill","tool_input":{"skill":"superpowers:executing-plans"}}')
  ctx=$(printf '%s' "$out" | jq -r '.hookSpecificOutput.additionalContext // empty')
  [ -n "$ctx" ] && pass "additionalContext field present + non-empty" || fail "additionalContext field present + non-empty"
fi

# 11. State-write failure must still exit 0 (Critical regression: special-builtin redirection)
rm -rf .context; : > .context  # make .context a FILE so the state dir cannot be created
printf '%s' '{"hook_event_name":"PostToolUse","tool_name":"mcp__codex__review","tool_input":{}}' | sh "$HOOK"; rc=$?
[ "$rc" = 0 ] && pass "state-write failure still exits 0" || fail "state-write failure still exits 0 (got $rc)"
rm -f .context; mkdir -p .context  # restore

# 12. Per-workspace opt-out: .context/codex-gate.off silences reminders
off=".context/codex-gate.off"
: > "$off"
: > "$state"  # would normally produce a ✓ reminder
out=$(run '{"hook_event_name":"PreToolUse","tool_name":"Bash","tool_input":{"command":"git commit -m x"}}')
[ -z "$out" ] && pass "off marker silences Gate B reminder" || fail "off marker silences Gate B reminder"
out=$(run '{"hook_event_name":"PreToolUse","tool_name":"Skill","tool_input":{"skill":"superpowers:executing-plans"}}')
[ -z "$out" ] && pass "off marker silences Gate A reminder" || fail "off marker silences Gate A reminder"

# 13. Full state machine keeps running while off (so re-enable is accurate)
rm -f "$state"
run '{"hook_event_name":"PostToolUse","tool_name":"mcp__codex__review","tool_input":{}}' >/dev/null
[ -f "$state" ] && pass "review still SETs state while off" || fail "review still SETs state while off"
run '{"hook_event_name":"PostToolUse","tool_name":"Edit","tool_input":{"file_path":"a"}}' >/dev/null
[ ! -f "$state" ] && pass "edit still INVALIDATEs state while off" || fail "edit still INVALIDATEs state while off"
: > "$state"
run '{"hook_event_name":"PostToolUse","tool_name":"Bash","tool_input":{"command":"git commit -m x"}}' >/dev/null
[ ! -f "$state" ] && pass "commit still RESETs state while off" || fail "commit still RESETs state while off"
rm -f "$off"  # re-enable
rm -f "$state" "$count"
rev; rev; rev  # reach floor with state set
out=$(commitpre)
printf '%s' "$out" | grep -q 'Gate B satisfied' && pass "re-enable sees accurate state" || fail "re-enable sees accurate state"

# 14. Gate B floor display + reset on commit
rm -f "$state" "$count"
rev
[ "$(cat "$count" 2>/dev/null)" = 1 ] && pass "review bumps count to 1" || fail "review bumps count to 1"
rev
out=$(commitpre)
printf '%s' "$out" | grep -q '2/3' && pass "below-floor reminder shows N/3" || fail "below-floor reminder shows N/3"
run '{"hook_event_name":"PostToolUse","tool_name":"Bash","tool_input":{"command":"git commit -m x"}}' >/dev/null
[ ! -f "$count" ] && pass "commit resets pass count" || fail "commit resets pass count"

# 14b. Docs-only commit -> gentle N/A note (not the STOP/floor reminder); mixed
#      and undeterminable (nothing staged) commits still fire Gate B.
rm -f "$state" "$count"  # state ABSENT -> would normally STOP on a code commit
git config user.email t@t >/dev/null 2>&1; git config user.name t >/dev/null 2>&1
mkdir -p docs
printf 'spec\n' > docs/plan.md; printf 'readme\n' > NOTES.md
git add docs/plan.md NOTES.md >/dev/null 2>&1
out=$(commitpre)
printf '%s' "$out" | grep -q 'docs-only commit' && pass "docs-only staged -> N/A note" || fail "docs-only staged -> N/A note"
printf '%s' "$out" | grep -q 'STOP' && fail "docs-only must not STOP" || pass "docs-only does not STOP"
# add a code file to the staged set -> no longer docs-only -> Gate B fires
printf 'code\n' > app.ts; git add app.ts >/dev/null 2>&1
out=$(commitpre)
printf '%s' "$out" | grep -q 'Gate B' && pass "mixed staged -> Gate B fires" || fail "mixed staged -> Gate B fires"
git commit -qm seed >/dev/null 2>&1  # commit app.ts so it's tracked (clean tree)
# -am with only docs staged AND no tracked-unstaged code -> still docs-only -> N/A
printf 'spec1b\n' >> docs/plan.md; git add docs/plan.md >/dev/null 2>&1
out=$(run '{"hook_event_name":"PreToolUse","tool_name":"Bash","tool_input":{"command":"git commit -am x"}}')
printf '%s' "$out" | grep -q 'docs-only commit' && pass "-am docs-only, no unstaged code -> N/A note" || fail "-am docs-only, no unstaged code -> N/A note"
# -a sweeps tracked-unstaged code: docs staged, leave a tracked .ts modified
printf 'changed\n' >> app.ts       # tracked-unstaged code change
out=$(run '{"hook_event_name":"PreToolUse","tool_name":"Bash","tool_input":{"command":"git commit -am x"}}')
printf '%s' "$out" | grep -q 'Gate B' && pass "-am with unstaged code -> Gate B fires" || fail "-am with unstaged code -> Gate B fires"
git checkout -- app.ts >/dev/null 2>&1; rm -f NOTES.md docs/plan.md app.ts; rmdir docs 2>/dev/null
rm -f "$state" "$count"

# 15. Gate A floor: exec bumps its own counter; plan-execution skill enforces + resets
rm -f "$countA"
run '{"hook_event_name":"PostToolUse","tool_name":"mcp__codex__exec","tool_input":{}}' >/dev/null
[ "$(cat "$countA" 2>/dev/null)" = 1 ] && pass "exec bumps Gate A count to 1" || fail "exec bumps Gate A count to 1"
out=$(run '{"hook_event_name":"PreToolUse","tool_name":"Skill","tool_input":{"skill":"superpowers:executing-plans"}}')
printf '%s' "$out" | grep -q 'below floor\|floor NOT met' && pass "1/3 exec -> Gate A below floor" || fail "1/3 exec -> Gate A below floor"
run '{"hook_event_name":"PostToolUse","tool_name":"mcp__codex__exec","tool_input":{}}' >/dev/null
run '{"hook_event_name":"PostToolUse","tool_name":"mcp__codex__exec","tool_input":{}}' >/dev/null
out=$(run '{"hook_event_name":"PreToolUse","tool_name":"Skill","tool_input":{"skill":"superpowers:executing-plans"}}')
printf '%s' "$out" | grep -q 'Gate A satisfied\|floor met' && pass "3/3 exec -> Gate A satisfied" || fail "3/3 exec -> Gate A satisfied"
run '{"hook_event_name":"PostToolUse","tool_name":"Skill","tool_input":{"skill":"superpowers:executing-plans"}}' >/dev/null
[ ! -f "$countA" ] && pass "plan execution resets Gate A count" || fail "plan execution resets Gate A count"

# 16. Every other Gate-A reset trigger zeroes a stale count — spec OPEN
#     (brainstorming / writing-plans) and the other CLOSE (subagent-driven-development);
#     executing-plans is covered by test 15.
for s in superpowers:brainstorming superpowers:writing-plans superpowers:subagent-driven-development; do
  run '{"hook_event_name":"PostToolUse","tool_name":"mcp__codex__exec","tool_input":{}}' >/dev/null  # stale countA=1
  [ -f "$countA" ] || fail "setup: exec should create countA for $s"
  run "{\"hook_event_name\":\"PostToolUse\",\"tool_name\":\"Skill\",\"tool_input\":{\"skill\":\"$s\"}}" >/dev/null
  [ ! -f "$countA" ] && pass "$s resets stale Gate A count" || fail "$s resets stale Gate A count"
done

echo "---"
[ "$fails" -eq 0 ] && { echo "all passed"; exit 0; } || { echo "$fails failed"; exit 1; }
