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
git config user.email t@t; git config user.name t
mkdir -p .context
state=".context/codex-gate.gateB"
count=".context/codex-gate.passCount"
fresh=".context/codex-gate.freshCount"
countA=".context/codex-gate.passCountA"
floorf=".context/codex-gate.floor"

# A HEAD commit must exist so `git diff HEAD` (the tree-hash input) is meaningful.
printf 'v1\n' > app.ts
git add app.ts >/dev/null 2>&1
git commit -qm init >/dev/null 2>&1

run() { printf '%s' "$1" | sh "$HOOK"; }
rev() { run '{"hook_event_name":"PostToolUse","tool_name":"mcp__codex__review","tool_input":{}}' >/dev/null; }
commitpre() { run '{"hook_event_name":"PreToolUse","tool_name":"Bash","tool_input":{"command":"git commit -m x"}}'; }
commitpost() { run '{"hook_event_name":"PostToolUse","tool_name":"Bash","tool_input":{"command":"git commit -m x"}}' >/dev/null; }
reset_all() { rm -f "$state" "$count" "$fresh" "$countA" "$floorf"; }

# 1. SET on review + bump pass count
rev
[ -f "$state" ] && pass "review creates state" || fail "review creates state"
[ -s "$state" ] && pass "state holds a tree hash (non-empty)" || fail "state holds a tree hash (non-empty)"
[ "$(cat "$count" 2>/dev/null)" = 1 ] && pass "review bumps pass count to 1" || fail "review bumps pass count to 1"

# 2. Below floor (1/3) -> NOT satisfied yet; reaching floor (3/3) -> satisfied
out=$(commitpre)
printf '%s' "$out" | grep -q 'below floor\|floor NOT met' && pass "1/3 passes -> below floor" || fail "1/3 passes -> below floor"
printf '%s' "$out" | grep -q 'hookSpecificOutput' && pass "emits JSON additionalContext" || fail "emits JSON additionalContext"
rev; rev  # reach the floor: 3 passes total, tree unchanged
out=$(commitpre)
printf '%s' "$out" | grep -q 'Gate B satisfied' && pass "3/3 passes, unchanged tree -> satisfied" || fail "3/3 passes, unchanged tree -> satisfied"

# 3. FINDING 1 — content-based invalidation.
#    (Replaces the old event-based assertion `[ ! -f state ]` after an Edit. The state
#    file now legitimately SURVIVES a change — it holds the reviewed hash — so the
#    intent "a change means Gate B is not satisfied" is asserted at the BEHAVIOR level.)
# 3a. Edit-tool change -> stale
printf 'v2\n' >> app.ts
run '{"hook_event_name":"PostToolUse","tool_name":"Edit","tool_input":{"file_path":"app.ts"}}' >/dev/null
out=$(commitpre)
printf '%s' "$out" | grep -q 'not satisfied' && pass "Edit-tool change -> not satisfied" || fail "Edit-tool change -> not satisfied"
printf '%s' "$out" | grep -q 'tree has CHANGED' && pass "Edit-tool change -> reported as stale tree" || fail "Edit-tool change -> reported as stale tree"

# 3b. THE MAJOR: a file changed through BASH (no Edit/Write event at all) -> stale.
#     Under the old event-based scheme this produced a false ✓.
reset_all
rev; rev; rev                       # 3 clean passes on the current tree
out=$(commitpre)
printf '%s' "$out" | grep -q 'Gate B satisfied' && pass "setup: satisfied before bash edit" || fail "setup: satisfied before bash edit"
printf 'sed-style in-place edit\n' >> app.ts   # NO hook event fires for this
out=$(commitpre)
printf '%s' "$out" | grep -q 'not satisfied' && pass "bash-modified file after review -> NOT satisfied (Finding 1)" || fail "bash-modified file after review -> NOT satisfied (Finding 1)"

# 3c. Untracked new file after review -> stale
git checkout -- app.ts >/dev/null 2>&1
reset_all
rev; rev; rev
printf '%s' "$(commitpre)" | grep -q 'Gate B satisfied' && pass "setup: satisfied on clean tree" || fail "setup: satisfied on clean tree"
printf 'new\n' > brand-new.ts
out=$(commitpre)
printf '%s' "$out" | grep -q 'not satisfied' && pass "untracked new file after review -> NOT satisfied" || fail "untracked new file after review -> NOT satisfied"
rm -f brand-new.ts

# 3d. Reverting the tree back to the reviewed content -> satisfied again
#     (content-based, so an edit-then-undo is correctly NOT stale)
out=$(commitpre)
printf '%s' "$out" | grep -q 'Gate B satisfied' && pass "revert to reviewed tree -> satisfied again" || fail "revert to reviewed tree -> satisfied again"

# 3e. The hook's own .context/ churn must NOT change the hash (else it never matches itself)
rev  # writes state files
out=$(commitpre)
printf '%s' "$out" | grep -q 'Gate B satisfied' && pass ".context/ churn does not invalidate the hash" || fail ".context/ churn does not invalidate the hash"

# 3f. FINDING B — pure staging must NOT invalidate: `git diff HEAD` covers staged and
#     unstaged tracked content alike, so `git add` of an already-reviewed file changes
#     nothing that could end up in the commit.
reset_all
printf 'reviewed change\n' >> app.ts
rev; rev; rev                       # 3 passes covering the modified (unstaged) tree
printf '%s' "$(commitpre)" | grep -q 'Gate B satisfied' && pass "setup: satisfied on unstaged change" || fail "setup: satisfied on unstaged change"
git add app.ts >/dev/null 2>&1      # staging only — no content change
out=$(commitpre)
printf '%s' "$out" | grep -q 'Gate B satisfied' && pass "staging a reviewed tracked file -> still satisfied (Finding B)" || fail "staging a reviewed tracked file -> still satisfied (Finding B)"
# ...and an untracked file added on top still invalidates (direction preserved)
printf 'new\n' > also-new.ts
printf '%s' "$(commitpre)" | grep -q 'not satisfied' && pass "untracked file on a staged tree -> NOT satisfied" || fail "untracked file on a staged tree -> NOT satisfied"
rm -f also-new.ts
git reset -q >/dev/null 2>&1; git checkout -- app.ts >/dev/null 2>&1

# 4. Gate A exec must NOT satisfy Gate B (separate state)
reset_all
run '{"hook_event_name":"PostToolUse","tool_name":"mcp__codex__exec","tool_input":{}}' >/dev/null
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

# 9. jq-absent fallback (best effort: build a PATH without jq)
nojq="$work/nojq"; mkdir -p "$nojq"; ok=1
for t in git grep sed head cat mkdir rm touch awk shasum sha1sum cksum tr; do
  p=$(command -v "$t" 2>/dev/null) && ln -s "$p" "$nojq/$t" 2>/dev/null || true
done
command -v git >/dev/null 2>&1 || ok=0
if [ "$ok" = 1 ] && ! PATH="$nojq" command -v jq >/dev/null 2>&1; then
  reset_all
  out=$(printf '%s' '{"hook_event_name":"PreToolUse","tool_name":"Bash","tool_input":{"command":"git commit -m x"}}' | PATH="$nojq" /bin/sh "$HOOK")
  printf '%s' "$out" | grep -q 'Gate B' && pass "jq-absent fallback works" || fail "jq-absent fallback works"
  # 9b. fallback must not be confused by a literal } inside the command
  out=$(printf '%s' '{"hook_event_name":"PreToolUse","tool_name":"Bash","tool_input":{"command":"git commit -m }"}}' | PATH="$nojq" /bin/sh "$HOOK")
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
printf '%s' '{"hook_event_name":"PostToolUse","tool_name":"mcp__codex__review","tool_input":{}}' | sh "$HOOK"; rc=$?
[ "$rc" = 0 ] && pass "state-write failure still exits 0" || fail "state-write failure still exits 0 (got $rc)"
rm -f .context; mkdir -p .context  # restore

# 12. Per-workspace opt-out: .context/codex-gate.off silences reminders
off=".context/codex-gate.off"
reset_all
: > "$off"
rev  # would normally produce a ✓/floor reminder
out=$(commitpre)
[ -z "$out" ] && pass "off marker silences Gate B reminder" || fail "off marker silences Gate B reminder"
out=$(run '{"hook_event_name":"PreToolUse","tool_name":"Skill","tool_input":{"skill":"superpowers:executing-plans"}}')
[ -z "$out" ] && pass "off marker silences Gate A reminder" || fail "off marker silences Gate A reminder"

# 13. Full state machine keeps running while off (so re-enable is accurate)
reset_all
rev
[ -f "$state" ] && pass "review still SETs state while off" || fail "review still SETs state while off"
commitpost
[ ! -f "$state" ] && pass "commit still RESETs state while off" || fail "commit still RESETs state while off"
rm -f "$off"  # re-enable
reset_all
rev; rev; rev
out=$(commitpre)
printf '%s' "$out" | grep -q 'Gate B satisfied' && pass "re-enable sees accurate state" || fail "re-enable sees accurate state"

# 14. Below-floor reminder shows N/floor
reset_all
rev; rev
out=$(commitpre)
printf '%s' "$out" | grep -q '2/3' && pass "below-floor reminder shows N/3" || fail "below-floor reminder shows N/3"

# 14b. Docs-only commit -> gentle N/A note; mixed and undeterminable commits still fire.
reset_all   # state ABSENT -> would normally STOP on a code commit
mkdir -p docs
printf 'spec\n' > docs/plan.md; printf 'readme\n' > NOTES.md
git add docs/plan.md NOTES.md >/dev/null 2>&1
out=$(commitpre)
printf '%s' "$out" | grep -q 'docs-only commit' && pass "docs-only staged -> N/A note" || fail "docs-only staged -> N/A note"
printf '%s' "$out" | grep -q 'STOP' && fail "docs-only must not STOP" || pass "docs-only does not STOP"
printf 'code\n' > extra.ts; git add extra.ts >/dev/null 2>&1
out=$(commitpre)
printf '%s' "$out" | grep -q 'Gate B' && pass "mixed staged -> Gate B fires" || fail "mixed staged -> Gate B fires"
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
run '{"hook_event_name":"PostToolUse","tool_name":"mcp__codex__exec","tool_input":{}}' >/dev/null
[ "$(cat "$countA" 2>/dev/null)" = 1 ] && pass "exec bumps Gate A count to 1" || fail "exec bumps Gate A count to 1"
out=$(run '{"hook_event_name":"PreToolUse","tool_name":"Skill","tool_input":{"skill":"superpowers:executing-plans"}}')
printf '%s' "$out" | grep -q 'below floor\|floor NOT met' && pass "1/3 exec -> Gate A below floor" || fail "1/3 exec -> Gate A below floor"
run '{"hook_event_name":"PostToolUse","tool_name":"mcp__codex__exec","tool_input":{}}' >/dev/null
run '{"hook_event_name":"PostToolUse","tool_name":"mcp__codex__exec","tool_input":{}}' >/dev/null
out=$(run '{"hook_event_name":"PreToolUse","tool_name":"Skill","tool_input":{"skill":"superpowers:executing-plans"}}')
printf '%s' "$out" | grep -q 'floor met' && pass "3/3 exec -> Gate A satisfied" || fail "3/3 exec -> Gate A satisfied"
# FINDING 12: the Gate-A satisfied wording must NOT overstate — it counts calls only.
printf '%s' "$out" | grep -q 'count only\|COUNT ONLY' && pass "Gate A satisfied says 'count only' (Finding 12)" || fail "Gate A satisfied says 'count only' (Finding 12)"
run '{"hook_event_name":"PostToolUse","tool_name":"Skill","tool_input":{"skill":"superpowers:executing-plans"}}' >/dev/null
[ ! -f "$countA" ] && pass "plan execution resets Gate A count" || fail "plan execution resets Gate A count"

# 16. Every other Gate-A reset trigger zeroes a stale count
for s in superpowers:brainstorming superpowers:writing-plans superpowers:subagent-driven-development; do
  run '{"hook_event_name":"PostToolUse","tool_name":"mcp__codex__exec","tool_input":{}}' >/dev/null
  [ -f "$countA" ] || fail "setup: exec should create countA for $s"
  run "{\"hook_event_name\":\"PostToolUse\",\"tool_name\":\"Skill\",\"tool_input\":{\"skill\":\"$s\"}}" >/dev/null
  [ ! -f "$countA" ] && pass "$s resets stale Gate A count" || fail "$s resets stale Gate A count"
done

# 17. FINDING 6 — per-project floor override via .context/codex-gate.floor
reset_all
printf '1' > "$floorf"
rev
out=$(commitpre)
printf '%s' "$out" | grep -q '1/1' && pass "floor override 1 -> satisfied at 1 pass" || fail "floor override 1 -> satisfied at 1 pass"
printf '%s' "$out" | grep -q 'Gate B satisfied' && pass "floor override 1 -> reports satisfied" || fail "floor override 1 -> reports satisfied"
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

# 18. FINDING 9 — satisfied message distinguishes fresh passes from cycle passes
reset_all
rev; rev; rev            # 3 passes on the current tree
printf 'post-review rewrite\n' >> app.ts   # big change AFTER the passes
rev                      # one fresh pass on the new tree
out=$(commitpre)
printf '%s' "$out" | grep -q '4/3' && pass "cycle total counts all 4 passes" || fail "cycle total counts all 4 passes"
printf '%s' "$out" | grep -q '1 cover the CURRENT tree\|of which 1' && pass "fresh count reports only 1 pass covers current code (Finding 9)" || fail "fresh count reports only 1 pass covers current code (Finding 9)"
git checkout -- app.ts >/dev/null 2>&1
reset_all

# 19. FINDING 11 — WIP commit is cycle-internal: gentle note, no STOP, no reset
reset_all
rev; rev                                   # 2 passes accumulated
wip() { run "{\"hook_event_name\":\"PreToolUse\",\"tool_name\":\"Bash\",\"tool_input\":{\"command\":\"$1\"}}"; }
out=$(wip "git commit -m 'wip: pre-review snapshot'")
printf '%s' "$out" | grep -q 'STOP' && fail "WIP commit must not STOP" || pass "WIP commit does not STOP"
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

echo "---"
[ "$fails" -eq 0 ] && { echo "all passed"; exit 0; } || { echo "$fails failed"; exit 1; }
