#!/bin/sh
# shellcheck disable=SC2016  # expect() evals its single-quoted condition later, by design
# Pair-counting replay — the named verification for
# docs/superpowers/stories/2026-08-14-sequential-branch-calls-hook-story.md (spec §5).
# Runs the hook from this checkout and the hook from 205efd3 (dev-workflow 0.20.0) over the
# same throwaway repository and the same payload sequence, under sh and dash, with jq and
# with a jq-free PATH (the jq mode is skipped, with a skip line, on a host without jq).
# Prints one line per checkpoint x hook x shell x jq mode and exits 1
# if any expectation for the NEW hook, or the counterfactual for the OLD one, fails.
# Run from the repository root: sh docs/superpowers/replays/2026-10-09-pair-counting/replay.sh
set -u
root=$(git rev-parse --show-toplevel) || exit 1
work=$(mktemp -d); tools=$(mktemp -d)
trap 'rm -rf "$work" "$tools"' EXIT
git -C "$root" show 205efd3:plugins/dev-workflow/hooks/codex-gate.sh > "$work/old-hook.sh" || exit 1
cp "$root/plugins/dev-workflow/hooks/codex-gate.sh" "$work/new-hook.sh" || exit 1
for t in cat grep sed head tr git mkdir rm mv cp mktemp awk shasum sha1sum cksum; do
  p=$(command -v "$t" 2>/dev/null) && case "$p" in /*) ln -s "$p" "$tools/$t" ;; esac
done
unset GIT_CONFIG_PARAMETERS GIT_CONFIG_COUNT
GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_NOSYSTEM=1; export GIT_CONFIG_GLOBAL GIT_CONFIG_NOSYSTEM
repo="$work/repo"; mkdir "$repo"; cd "$repo" || exit 1
git init -q; git config user.email r@r; git config user.name r
printf 'v1\n' > app.js; git add app.js; git commit -qm init
mkdir -p .context; : > .context/codex-gate.on
printf 'v2\n' > app.js; git add app.js            # staged code, so the commit check is Gate B

B=1111111111111111111111111111111111111111
H1=2222222222222222222222222222222222222222
H2=3333333333333333333333333333333333333333
OK='[{"type":"text","text":"{\"success\": true, \"review\": \"ok\"}"}]'
bad=0

hk() { # $1 = hook file; payload on stdin
  if [ "$mode" = nojq ]; then PATH="$tools" "$shbin" "$1"; else "$shbin" "$1"; fi
}
branch() { # $1 = hook, $2 = reviewType, $3 = base, $4 = head
  printf '{"hook_event_name":"PostToolUse","tool_name":"mcp__codex__review","tool_input":{"reviewType":"%s","baseSha":"%s","headSha":"%s"},"tool_response":%s}' \
    "$2" "$3" "$4" "$OK" | hk "$1" >/dev/null
}
check() { printf '%s' '{"hook_event_name":"PreToolUse","tool_name":"Bash","tool_input":{"command":"git commit -m x"}}' | hk "$1"; }
count() { if [ "$2" = old ]; then cat .context/codex-gate.passCount 2>/dev/null || echo 0
          else cat .context/codex-gate.passes 2>/dev/null || echo 0; fi; }
fresh() { find .context -mindepth 1 ! -name codex-gate.on -exec rm -rf {} + 2>/dev/null; }
line() { # $1 checkpoint, $2 verdict, $3 detail
  printf '%-3s %-4s %-5s %-5s %-4s %s\n' "$1" "$which" "$sh" "$mode" "$2" "$3"
  [ "$2" = FAIL ] && bad=1
}
expect() { if eval "$1"; then line "$2" ok "$3"; else line "$2" FAIL "$3"; fi; }

for sh in sh dash; do
  shbin=$(command -v "$sh") || { printf 'skip: %s not found\n' "$sh"; continue; }
  for mode in jq nojq; do
    # The jq mode runs on the host PATH; without jq there it would be the jq-free mode
    # under the wrong expectations (PR #55, CodeRabbit).
    if [ "$mode" = jq ] && ! command -v jq >/dev/null 2>&1; then
      printf 'skip: jq mode under %s — no jq on this host\n' "$sh"; continue
    fi
    for which in old new; do
      hook="$work/$which-hook.sh"
      # C1 — three uninterrupted pairs.
      fresh
      for _ in 1 2 3; do branch "$hook" spec "$B" "$H1"; branch "$hook" quality "$B" "$H1"; done
      c=$(count "$hook" "$which"); out=$(check "$hook")
      sat=$(printf '%s' "$out" | grep -o "Codex Gate B: [0-9]*/3 pass(es) this cycle" | head -n1)
      if [ "$which" = new ]; then
        expect '[ "$c" = 3 ] && [ -n "$sat" ]' C1 "count=$c commit check: [$sat]"
      else
        expect '[ "$c" = 6 ] && [ -n "$sat" ]' C1 "count=$c commit check: [$sat] (counterfactual)"
      fi
      # C2 — then a lone spec branch, then a commit check.
      branch "$hook" spec "$B" "$H2"
      out=$(check "$hook")
      pend=$(printf '%s' "$out" | grep -c 'pending-branch state is present')
      sat=$(printf '%s' "$out" | grep -o "Codex Gate B: [0-9]*/3 pass(es) this cycle" | head -n1)
      if [ "$which" = new ]; then
        expect '[ "$pend" -ge 1 ] && [ "$(count "$hook" new)" = 3 ] && [ -n "$sat" ]' C2 "count=$(count "$hook" new) [$sat] pending-note=$pend"
      else
        expect '[ "$pend" = 0 ] && [ -n "$sat" ]' C2 "count=$(count "$hook" old) [$sat] pending-note=$pend (counterfactual)"
      fi
      # C3 — a WIP commit between a spec and a quality branch.
      fresh
      base=$(git rev-parse HEAD)
      branch "$hook" spec "$base" "$H1"
      printf '%s' '{"hook_event_name":"PreToolUse","tool_name":"Bash","tool_use_id":"toolu_r1","tool_input":{"command":"git commit -m '"'"'wip: snapshot'"'"'"}}' | hk "$hook" >/dev/null
      git commit -q --allow-empty -m 'wip: snapshot'
      printf '%s' '{"hook_event_name":"PostToolUse","tool_name":"Bash","tool_use_id":"toolu_r1","tool_input":{"command":"git commit -m \"wip: snapshot\""}}' | hk "$hook" >/dev/null
      kept=$([ -f .context/codex-gate.pendingBranch ] && echo yes || echo no)
      branch "$hook" quality "$base" "$(git rev-parse HEAD)"
      c=$(count "$hook" "$which")
      git reset -q --soft HEAD~1
      if [ "$which" = new ] && [ "$mode" = jq ]; then
        expect '[ "$kept" = yes ] && [ "$c" = 0 ]' C3 "pending kept over WIP=$kept, count after quality on new head=$c"
      elif [ "$which" = new ]; then
        expect '[ "$kept" = no ] && [ "$c" = 0 ]' C3 "jq-free WIP reset, pending kept=$kept, count=$c"
      else
        line C3 info "old hook observed: count=$c (counts calls; no pairing)"
      fi
    done
  done
done
exit "$bad"
