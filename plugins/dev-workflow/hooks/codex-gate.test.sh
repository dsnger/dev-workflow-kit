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

# A HEAD commit must exist so `git diff HEAD` (the tree-hash input) is meaningful.
printf 'v1\n' > app.ts
git add app.ts >/dev/null 2>&1
git commit -qm init >/dev/null 2>&1

run() { printf '%s' "$1" | sh "$HOOK"; }
rev() { run '{"hook_event_name":"PostToolUse","tool_name":"mcp__codex__review","tool_input":{}}' >/dev/null; }
commitpre() { run '{"hook_event_name":"PreToolUse","tool_name":"Bash","tool_input":{"command":"git commit -m x"}}'; }
commitpost() { run '{"hook_event_name":"PostToolUse","tool_name":"Bash","tool_input":{"command":"git commit -m x"}}' >/dev/null; }
reset_all() { rm -f "$state" "$count" "$fresh" "$countA" "$floorf" "$toolsf" "$notedf"; }
codextool() { run "{\"hook_event_name\":\"PostToolUse\",\"tool_name\":\"$1\",\"tool_input\":{}}"; }

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

# 3c-bis. Untracked CONTENT counts, not just the name. `git add f && git commit` is one
# Bash call, so the hook sees `f` still untracked — a name-only hash would hand that
# commit a stale ✓ on edited content (invariant 3).
reset_all; rev; rev; rev   # re-review with brand-new.ts present, so its name is known
printf '%s' "$(commitpre)" | grep -q 'Gate B satisfied' && pass "setup: satisfied with untracked file present" || fail "setup: satisfied with untracked file present"
printf 'edited\n' > brand-new.ts   # same name, different content
printf '%s' "$(commitpre)" | grep -q 'not satisfied' && pass "edited untracked file -> NOT satisfied" || fail "edited untracked file -> NOT satisfied"

# ...and a file inside a NEW untracked directory too: porcelain would collapse that to
# a single `dir/` entry and never hash what is in it.
reset_all; rev; rev; rev
mkdir -p newdir && printf 'a\n' > newdir/f.ts
printf '%s' "$(commitpre)" | grep -q 'not satisfied' && pass "new untracked dir -> NOT satisfied" || fail "new untracked dir -> NOT satisfied"
reset_all; rev; rev; rev
printf 'b\n' > newdir/f.ts
printf '%s' "$(commitpre)" | grep -q 'not satisfied' && pass "edited file in untracked dir -> NOT satisfied" || fail "edited file in untracked dir -> NOT satisfied"
rm -rf newdir

# ...and paths git does not print literally. It C-quotes non-ASCII and control
# characters ("caf\303\251.txt", quotes included), which names no real file, so a
# shell-side content read would silently come back empty.
for name in "café ñ.ts" "$(printf 'tab\tnewline\nname.ts')"; do
  reset_all; rev; rev; rev
  printf 'a\n' > "$name"
  printf '%s' "$(commitpre)" | grep -q 'not satisfied' && pass "new exotic-path untracked file -> NOT satisfied" || fail "new exotic-path untracked file -> NOT satisfied"
  reset_all; rev; rev; rev
  printf 'b\n' > "$name"
  printf '%s' "$(commitpre)" | grep -q 'not satisfied' && pass "edited exotic-path untracked file -> NOT satisfied" || fail "edited exotic-path untracked file -> NOT satisfied"
  rm -f "$name"
done

# A commit stores a symlink's TARGET, so retargeting one is a content change even when
# both targets are absent — and reading through the link instead would compare the
# referents, or block forever on a link to a FIFO.
reset_all; rev; rev; rev
ln -s absent-a link.ts
printf '%s' "$(commitpre)" | grep -q 'not satisfied' && pass "new untracked symlink -> NOT satisfied" || fail "new untracked symlink -> NOT satisfied"
reset_all; rev; rev; rev
rm -f link.ts; ln -s absent-b link.ts
printf '%s' "$(commitpre)" | grep -q 'not satisfied' && pass "retargeted untracked symlink -> NOT satisfied" || fail "retargeted untracked symlink -> NOT satisfied"
rm -f link.ts

# NOTE: the "tree could not be computed" guard in tree_hash has no regression test.
# Forcing it portably means making mktemp or git fail on demand — TMPDIR=/dev/null
# looks like it does that but BSD/macOS mktemp silently falls back to /var/folders, so
# such a test passes for the wrong reason. Tracked in todos.md.

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

# 3d. Reverting the tree back to the reviewed content -> satisfied again
#     (content-based, so an edit-then-undo is correctly NOT stale)
out=$(commitpre)
printf '%s' "$out" | grep -q 'Gate B satisfied' && pass "revert to reviewed tree -> satisfied again" || fail "revert to reviewed tree -> satisfied again"

# 3e. The hook's own .context/ churn must NOT change the hash (else it never matches itself)
rev  # writes state files
out=$(commitpre)
printf '%s' "$out" | grep -q 'Gate B satisfied' && pass ".context/ churn does not invalidate the hash" || fail ".context/ churn does not invalidate the hash"

# 3e-bis. ...including when .context/ is COMMITTED. Filtering only the untracked list
# leaves tracked state in `git diff HEAD`, where the hook's own writes invalidate the
# review it just recorded -> a permanent stale STOP. The adoption marker is meant to be
# shared, so a tracked .context/ is the normal case.
git add -f .context >/dev/null 2>&1; git commit -qm "track .context" >/dev/null 2>&1
reset_all
rev; rev; rev
printf '%s' "$(commitpre)" | grep -q 'Gate B satisfied' && pass "tracked .context/ state does not invalidate the hash" || fail "tracked .context/ state does not invalidate the hash"
rev  # more churn against the committed state
printf '%s' "$(commitpre)" | grep -q 'Gate B satisfied' && pass "tracked .context/ churn stays satisfied" || fail "tracked .context/ churn stays satisfied"
# ...while a real code change is still caught
printf 'code change\n' >> app.ts
printf '%s' "$(commitpre)" | grep -q 'not satisfied' && pass "tracked .context/: real code change still invalidates" || fail "tracked .context/: real code change still invalidates"
git checkout -- app.ts >/dev/null 2>&1
git rm -rq --cached .context >/dev/null 2>&1; git commit -qm "untrack .context" >/dev/null 2>&1
reset_all; rev; rev; rev

# 3f. DECIDED at spec §2 (2026-07-19-gate-b-index-tree-design.md): staging
#     already-reviewed content DOES invalidate. The hash covers the index tree, and
#     `git add` changes it. The bytes that would be committed are unchanged, so this is
#     a false invalidation — accepted under invariant 2 ("loose in the firing
#     direction"), and the STOP message explains that staging alone can cause it.
#     This test previously asserted the OPPOSITE as though it were a principle; the
#     behaviour was never decided, it fell out of an implementation choice.
reset_all
printf 'reviewed change\n' >> app.ts
rev; rev; rev                       # 3 passes covering the modified (unstaged) tree
printf '%s' "$(commitpre)" | grep -q 'Gate B satisfied' && pass "setup: satisfied on unstaged change" || fail "setup: satisfied on unstaged change"
git add app.ts >/dev/null 2>&1      # staging only — no content change
printf '%s' "$(commitpre)" | grep -q 'not satisfied' \
  && pass "staging a reviewed tracked file -> NOT satisfied (spec §2 decision)" \
  || fail "staging a reviewed tracked file -> NOT satisfied (spec §2 decision)"
# The old trailing assertion ("untracked file on a staged tree -> not satisfied") is
# GONE on purpose: once staging alone invalidates, it passes regardless of the untracked
# file and tests nothing. Test 3c already covers untracked content.
git reset -q >/dev/null 2>&1; git checkout -- app.ts >/dev/null 2>&1
reset_all; rev; rev; rev

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
[ -z "$(commitpre)" ] && pass "non-adopted repo: unreviewed commit -> no STOP" || fail "non-adopted repo: unreviewed commit -> no STOP"
out=$(run '{"hook_event_name":"PreToolUse","tool_name":"Skill","tool_input":{"skill":"superpowers:executing-plans"}}')
[ -z "$out" ] && pass "non-adopted repo: Gate A -> silent" || fail "non-adopted repo: Gate A -> silent"
[ -z "$(codextool mcp__codex__codex)" ] && pass "non-adopted repo: unknown-tool note -> silent" || fail "non-adopted repo: unknown-tool note -> silent"
out=$(run '{"hook_event_name":"PreToolUse","tool_name":"Bash","tool_input":{"command":"git commit -m \"wip: x\""}}')
[ -z "$out" ] && pass "non-adopted repo: WIP note -> silent" || fail "non-adopted repo: WIP note -> silent"
# Silent is not enough: a non-adopted repo must be INERT. Writing state would litter an
# unrelated project with a .context/ it never asked for.
reset_all
rev; run '{"hook_event_name":"PostToolUse","tool_name":"mcp__codex__exec","tool_input":{}}' >/dev/null
[ ! -f "$state" ] && [ ! -f "$count" ] && [ ! -f "$countA" ] && pass "non-adopted repo writes no state" || fail "non-adopted repo writes no state"
# ...even into a .context/ that does not exist yet (the dir itself must not appear)
sub=$(mktemp -d); (cd "$sub" && git init -q && git config user.email t@t && git config user.name t && printf 'x\n' > a.ts && git add -A && git commit -qm i) >/dev/null 2>&1
out=$(printf '%s' '{"hook_event_name":"PostToolUse","tool_name":"mcp__codex__review","tool_input":{}}' | (cd "$sub" && sh "$HOOK"))
[ ! -d "$sub/.context" ] && pass "non-adopted repo: no .context/ directory created" || fail "non-adopted repo: no .context/ directory created"
rm -rf "$sub"

# 22b. Either adoption marker is enough, and it takes effect without a restart.
#      (Each CLAUDE.md write is itself a tree change, so the passes are re-run after
#      one — otherwise a stale-tree STOP would masquerade as non-adoption.)
reset_all
printf '# p\n\n## 5. Something else entirely\n' > CLAUDE.md      # a CLAUDE.md without the gates
rm -f "$on"
rev; rev; rev                                                    # inert: these must not register
[ -z "$(commitpre)" ] && pass "unrelated CLAUDE.md -> not adopted" || fail "unrelated CLAUDE.md -> not adopted"
: > "$on"                                                        # the explicit marker
rev; rev; rev                                                    # passes only count once adopted
printf '%s' "$(commitpre)" | grep -q 'Gate B satisfied' && pass ".on marker alone -> adopted" || fail ".on marker alone -> adopted"
rm -f "$on"
[ -z "$(commitpre)" ] && pass "removing the marker -> silent again" || fail "removing the marker -> silent again"
printf '# p\n\n## 5. Cross-Model Review (Codex)\n' > CLAUDE.md   # the committed, team-wide signal
rev; rev; rev
printf '%s' "$(commitpre)" | grep -q 'Gate B satisfied' && pass "CLAUDE.md gate heading -> adopted" || fail "CLAUDE.md gate heading -> adopted"

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
printf '%s' "$out" | grep -q 'STOP' && pass "marker-only: still STOPs" || fail "marker-only: still STOPs"
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

# 24. Failure contract: an uncomputable hash must never satisfy, and repeated failures
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
printf '%s' "$out" | grep -q 'not satisfied' && pass "silent checksum -> not satisfied" || fail "silent checksum -> not satisfied"
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
printf '%s' "$out" | grep -q 'not satisfied' && pass "checksum prints then fails -> not satisfied" || fail "checksum prints then fails -> not satisfied"
[ "$(cat "$fresh" 2>/dev/null || echo 0)" = 0 ] && pass "unhashable pass leaves freshCount 0" || fail "unhashable pass leaves freshCount 0"

# 24c. seed-copy failure (stub cp) must fire, not silently hash an empty index
printf '#!/bin/sh\nexit 1\n' > "$stub_dir/cp"; chmod +x "$stub_dir/cp"
rm -f "$stub_dir/shasum" "$stub_dir/sha1sum" "$stub_dir/cksum"
reset_all; printf '1' > "$floorf"
( PATH="$stub_dir:$PATH" rev )
printf '%s' "$(PATH="$stub_dir:$PATH" commitpre)" | grep -q 'not satisfied' \
  && pass "seed-copy failure -> not satisfied" || fail "seed-copy failure -> not satisfied"
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
printf '%s' "$(PATH="$stub_dir:$PATH" commitpre)" | grep -q 'not satisfied' \
  && pass "git diff failure -> not satisfied" || fail "git diff failure -> not satisfied"

# 24e. a selective git wrapper that fails ONLY `rev-parse --absolute-git-dir`
cat > "$stub_dir/git" <<'STUB'
#!/bin/sh
case "$*" in *"--absolute-git-dir"*) exit 1 ;; esac
exec "$REAL_GIT" "$@"
STUB
chmod +x "$stub_dir/git"
reset_all; printf '1' > "$floorf"
( PATH="$stub_dir:$PATH" rev )
printf '%s' "$(PATH="$stub_dir:$PATH" commitpre)" | grep -q 'not satisfied' \
  && pass "unresolvable git-dir -> not satisfied" || fail "unresolvable git-dir -> not satisfied"
rm -f "$stub_dir/git"
rm -f "$floorf"
reset_all; rev; rev; rev

# 24f. Guard: confirm section 24's PATH containment held. If a future edit
# reintroduces the leak (e.g. drops a subshell above), this fails loudly instead of
# a stale stub PATH silently weakening isolation in every later section.
[ "$PATH" = "$path_before_24" ] && pass "PATH not leaked out of section 24" || fail "PATH not leaked out of section 24"

# 25. Unborn repo: no commits and no .git/index must still hash and self-match, or the
#     first commit in a fresh repo STOPs forever. Spec §3 "But an absent index is not a
#     failed copy".
unborn=$(mktemp -d)
(
  cd "$unborn" || exit 1
  git init -q; git config user.email t@t; git config user.name t
  mkdir -p .context; : > .context/codex-gate.on
  printf '1' > .context/codex-gate.floor      # one pass is enough for this fixture
  printf 'x\n' > a.ts
  R='{"hook_event_name":"PostToolUse","tool_name":"mcp__codex__review","tool_input":{}}'
  printf '%s' "$R" | sh "$HOOK" >/dev/null
  h1=$(cat .context/codex-gate.gateB 2>/dev/null)
  printf '%s' "$R" | sh "$HOOK" >/dev/null
  h2=$(cat .context/codex-gate.gateB 2>/dev/null)
  [ -n "$h1" ] && [ "$h1" != unavailable ] && [ "$h1" = "$h2" ] || exit 1
  # ...and the FIRST commit must actually be able to reach satisfied. Hashing and
  # self-matching is not enough: a consumer-side regression could still STOP every
  # first commit forever, which is the failure this fixture exists to catch.
  out=$(printf '%s' '{"hook_event_name":"PreToolUse","tool_name":"Bash","tool_input":{"command":"git commit --allow-empty -m init"}}' | sh "$HOOK")
  printf '%s' "$out" | grep -q 'Gate B satisfied' || exit 1
) && pass "unborn repo hashes, self-matches, and can reach satisfied" \
  || fail "unborn repo hashes, self-matches, and can reach satisfied"
rm -rf "$unborn"

# 26. THE DEFECT (spec §1): staged content diverging from the worktree.
#     NOTE: the revert is a direct byte write, NOT `git checkout -- app.ts` — checkout
#     restores the worktree FROM THE INDEX, which would install v2 on disk and destroy
#     the divergence, making this test pass against the unfixed hook.
reset_all
rev; rev; rev
printf '%s' "$(commitpre)" | grep -q 'Gate B satisfied' && pass "setup: satisfied on clean tree" || fail "setup: satisfied on clean tree"
printf 'v2\n' > app.ts; git add app.ts >/dev/null 2>&1   # index: v2
printf 'v1\n' > app.ts                                   # worktree: back to HEAD bytes
printf '%s' "$(commitpre)" | grep -q 'not satisfied' \
  && pass "staged-vs-worktree divergence -> NOT satisfied" \
  || fail "staged-vs-worktree divergence -> NOT satisfied"
git reset -q >/dev/null 2>&1; git checkout -- app.ts >/dev/null 2>&1

# 27. Ambient alternate index. Three shapes: a negative-only test would be satisfied by
#     an implementation that fires whenever GIT_INDEX_FILE is set — a permanent STOP.
alt_dir=$(mktemp -d)
# 27a. divergent: fingerprint recorded WITHOUT the alternate index, alternate enabled
#      only for the commit check.
reset_all; printf '1' > "$floorf"
rev
cp .git/index "$alt_dir/alt"
printf 'SNEAKY\n' > app.ts; GIT_INDEX_FILE="$alt_dir/alt" git add app.ts >/dev/null 2>&1
printf 'v1\n' > app.ts
printf '%s' "$(GIT_INDEX_FILE="$alt_dir/alt" commitpre)" | grep -q 'not satisfied' \
  && pass "ambient divergent alternate index -> NOT satisfied" \
  || fail "ambient divergent alternate index -> NOT satisfied"
# 27b. stable: same unchanged alternate index across review AND commit -> satisfied,
#      with each index file byte-identical to its OWN pre-hook snapshot.
cp .git/index "$alt_dir/default.before"; cp "$alt_dir/alt" "$alt_dir/alt.before"
reset_all; printf '1' > "$floorf"
# Subshell: a prefix assignment on a SHELL FUNCTION call (rev/commitpre are functions,
# not external commands) persists in the shell after the call returns — unlike the same
# prefix on an external command. Without containment, GIT_INDEX_FILE leaks out of
# section 27 and corrupts every later section's fixtures (notably section 28).
( GIT_INDEX_FILE="$alt_dir/alt" rev )
printf '%s' "$(GIT_INDEX_FILE="$alt_dir/alt" commitpre)" | grep -q 'Gate B satisfied' \
  && pass "ambient stable alternate index -> satisfied" \
  || fail "ambient stable alternate index -> satisfied"
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
#      the two constant empty-tree hashes MATCH — a false "satisfied" even though the
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
printf '%s' "$out" | grep -q 'not satisfied' \
  && pass "relative ambient GIT_INDEX_FILE from a subdirectory -> NOT satisfied (Finding 1)" \
  || fail "relative ambient GIT_INDEX_FILE from a subdirectory -> NOT satisfied (Finding 1)"
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
# Snapshot AFTER the two read-only commands above, not before: `write-tree` and
# `rev-parse` can trigger git's benign racy-clean stat-cache rewrite of .git/index,
# which would flip index bytes with no content change and make the byte comparison
# below flaky for reasons unrelated to tree_hash().
cp .git/index "$work/index.before"
reset_all
rev; h1=$(cat "$state" 2>/dev/null)
rev; h2=$(cat "$state" 2>/dev/null)
{ [ -n "$h1" ] && [ "$h1" != unavailable ] && [ "$h1" = "$h2" ]; } \
  && pass "three-way .context divergence hashes and self-matches" \
  || fail "three-way .context divergence hashes and self-matches"
[ "$(git write-tree 2>/dev/null)" = "$before_tree" ] && pass "real index tree unchanged" || fail "real index tree unchanged"
[ "$(git rev-parse :.context/codex-gate.on 2>/dev/null)" = "$before_blob" ] && pass "staged .context blob unchanged" || fail "staged .context blob unchanged"
cmp -s .git/index "$work/index.before" && pass "real index bytes unchanged" || fail "real index bytes unchanged"
: > .context/codex-gate.on
git rm -rq --cached .context >/dev/null 2>&1; git commit -qm "untrack .context" >/dev/null 2>&1
reset_all; rev; rev; rev

echo "---"
[ "$fails" -eq 0 ] && { echo "all passed"; exit 0; } || { echo "$fails failed"; exit 1; }
