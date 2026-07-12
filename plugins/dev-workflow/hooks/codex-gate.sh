#!/bin/sh
# Codex review gate reminders (CLAUDE.md §5). Non-blocking: ALWAYS exits 0.
# Reads a Claude Code hook payload (JSON) on stdin, maintains a Gate-B state
# file, and emits hookSpecificOutput.additionalContext reminders.
set -u

payload=$(cat)

field() { # top-level string field: $1 = key
  if command -v jq >/dev/null 2>&1; then
    printf '%s' "$payload" | jq -r --arg k "$1" '.[$k] // empty'
  else
    printf '%s' "$payload" | grep -o "\"$1\"[[:space:]]*:[[:space:]]*\"[^\"]*\"" | head -n1 | sed 's/^.*:[[:space:]]*"\(.*\)"$/\1/'
  fi
}

input_field() { # string field inside tool_input: $1 = key
  if command -v jq >/dev/null 2>&1; then
    printf '%s' "$payload" | jq -r --arg k "$1" '.tool_input[$k] // empty'
  else
    # Fallback: strip everything up to "tool_input":{ so a same-named top-level
    # key can't shadow it, then read the key. Stays correct when the value
    # contains a literal } — the [^"]* run stops at the closing quote, not a brace.
    printf '%s' "$payload" | sed 's/.*"tool_input"[[:space:]]*:[[:space:]]*{//' \
      | grep -o "\"$1\"[[:space:]]*:[[:space:]]*\"[^\"]*\"" | head -n1 | sed 's/^.*:[[:space:]]*"\(.*\)"$/\1/'
  fi
}

event=$(field hook_event_name)
tool=$(field tool_name)

repo_root=$(git rev-parse --show-toplevel 2>/dev/null) || exit 0
state_file="$repo_root/.context/codex-gate.gateB"
off_file="$repo_root/.context/codex-gate.off"
# §5 HARD FLOOR: minimum Codex passes per gate before exiting it. The hook can't
# read Codex's findings (so it can't auto-detect the "zero-findings" early exit
# — that judgment stays with the model per §5), but it CAN count passes and flag
# when the floor isn't met. This is what backs Gate A, which has no other
# mechanism (unlike Gate B, where any edit invalidates the review).
floor=3
count_file="$repo_root/.context/codex-gate.passCount"    # Gate B (review) passes since last commit
countA_file="$repo_root/.context/codex-gate.passCountA"  # Gate A (exec) passes since last plan execution

read_count() { if [ -f "$1" ]; then cat "$1" 2>/dev/null || echo 0; else echo 0; fi; }
bump_count() { n=$(read_count "$1"); { printf '%s' "$((n + 1))" > "$1"; } 2>/dev/null || true; }

emit() { # $1 = additionalContext (model-visible), $2 = systemMessage (user)
  # Per-workspace opt-out: while .context/codex-gate.off exists, stay silent.
  # State tracking (SET/INVALIDATE/RESET) keeps running so re-enabling is accurate.
  [ -f "$off_file" ] && return 0
  if command -v jq >/dev/null 2>&1; then
    # jq encodes the strings, so any character (incl. control chars) is escaped correctly.
    jq -cn --arg ev "$event" --arg ctx "$1" --arg msg "$2" \
      '{hookSpecificOutput:{hookEventName:$ev,additionalContext:$ctx},systemMessage:$msg}'
  else
    # Fallback (no jq): escape backslash + quote. The supported reminders are
    # static and control-char-free, so this is sufficient.
    ctx=$(printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g')
    msg=$(printf '%s' "$2" | sed 's/\\/\\\\/g; s/"/\\"/g')
    printf '{"hookSpecificOutput":{"hookEventName":"%s","additionalContext":"%s"},"systemMessage":"%s"}\n' "$event" "$ctx" "$msg"
  fi
}

# Loose by design (a missed commit = false ✓ = the dangerous direction). The
# leading (^|[^[:alnum:]]) anchors `git` as a word so "digit commit" doesn't
# false-fire, while still catching `&& git`, `;git`, `/path/git`, etc.
is_commit() { printf '%s' "$1" | grep -Eq '(^|[^[:alnum:]])git[[:space:]].*commit'; }

# A commit that stages all tracked changes (-a / -am / --all) also sweeps in
# tracked-but-unstaged edits that `git diff --cached` alone won't show, so the
# docs-only check below must consult the unstaged set too. (`--amend` is two
# dashes and never matches, so it isn't mistaken for -a.)
has_all_flag() { printf '%s' "$1" | grep -Eq '(^|[[:space:]])(-[a-z]*a[a-z]*|--all)([[:space:]]|$)'; }

# True ONLY when the file list is non-empty AND every path is a doc artifact
# (*.md anywhere, or under .context/). Restricted to the .md extension on purpose:
# a non-Markdown file under docs/ (e.g. a script) IS code and must still hit Gate
# B, so we do NOT exempt the docs/ directory wholesale. An empty/undeterminable
# list returns false, so the caller falls through to the loose Gate-B default
# (fire) — keeping "missed code commit" the safe direction.
is_docs_only() {
  [ -n "$1" ] || return 1
  printf '%s\n' "$1" | grep -vE '(\.md$|^\.context/)' | grep -q . && return 1
  return 0
}

case "$event" in
  PostToolUse)
    case "$tool" in
      mcp__codex__review) mkdir -p "$repo_root/.context" 2>/dev/null; touch "$state_file" 2>/dev/null || true; bump_count "$count_file" ;;
      mcp__codex__exec) mkdir -p "$repo_root/.context" 2>/dev/null; bump_count "$countA_file" ;;
      Edit | Write | MultiEdit | NotebookEdit) rm -f "$state_file" ;;
      Bash) is_commit "$(input_field command)" && { rm -f "$state_file" "$count_file"; } ;;
      Skill)
        case "$(input_field skill)" in
          # Reset the Gate-A pass count at both ends of a spec cycle: plan execution
          # CLOSES one, and brainstorming / writing-plans OPENS the next — so a new
          # spec zeroes any stale count abandoned by a previous (un-executed) one.
          superpowers:executing-plans | superpowers:subagent-driven-development \
            | superpowers:brainstorming | superpowers:writing-plans) rm -f "$countA_file" ;;
        esac
        ;;
    esac
    ;;
  PreToolUse)
    case "$tool" in
      Bash)
        cmd=$(input_field command)
        if is_commit "$cmd"; then
          # Docs-only commits (spec/plan .md files) carry no code diff,
          # so Gate B (mcp__codex__review reviews a code diff) cannot apply — emit a
          # gentle note instead of the STOP/floor reminders. Only when the file list
          # is POSITIVELY confirmed docs-only; an empty list falls through to fire.
          files=$(git -C "$repo_root" diff --cached --name-only 2>/dev/null)
          has_all_flag "$cmd" && files=$(printf '%s\n%s\n' "$files" "$(git -C "$repo_root" diff --name-only 2>/dev/null)")
          files=$(printf '%s\n' "$files" | sed '/^$/d')
          if is_docs_only "$files"; then
            emit "Docs-only commit — no code is staged, so Codex Gate B (mcp__codex__review reviews a code diff) does not apply here. If this commit includes a spec or plan, confirm it went through Gate A (mcp__codex__exec) instead." "ℹ Codex Gate B N/A (docs-only commit)"
          else
            passes=$(read_count "$count_file")
            if [ ! -f "$state_file" ]; then
              # No count ratio here on purpose: an edit invalidated the prior review(s),
              # so any passes this cycle covered pre-edit code — showing "N/3" would read
              # as floor progress and contradict "not satisfied".
              emit "STOP — Codex Gate B not satisfied: no mcp__codex__review has run since your last code edit, so the CURRENT code is unreviewed (the $passes pass(es) earlier this cycle covered pre-edit code). Per CLAUDE.md §5 you MUST re-review after every fix AND reach a minimum of $floor passes per cycle. Run Gate B (mcp__codex__review) now, or proceed only if this change is trivial." "⚠ Codex Gate B not run"
            elif [ "$passes" -lt "$floor" ]; then
              emit "Codex Gate B floor NOT met: only $passes/$floor mcp__codex__review pass(es) since the last commit. Per CLAUDE.md §5 the review is a LOOP with a hard minimum of $floor passes — run more (the ONLY early exit is a pass that returned zero findings), or proceed only if this change is trivial." "⚠ Codex Gate B below floor ($passes/$floor)"
            else
              emit "Codex Gate B satisfied: $passes/$floor mcp__codex__review pass(es) and no code edits since the last review. Per §5, commit only if your final pass was clean — no new Blocker/Major." "✓ Codex Gate B satisfied ($passes/$floor passes)"
            fi
          fi
        fi
        ;;
      Skill)
        case "$(input_field skill)" in
          superpowers:executing-plans | superpowers:subagent-driven-development)
            passesA=$(read_count "$countA_file")
            if [ "$passesA" -lt "$floor" ]; then
              emit "Codex Gate A floor NOT met: only $passesA/$floor mcp__codex__exec pass(es) on this spec/plan. Per CLAUDE.md §5 Gate A is a LOOP with a hard minimum of $floor passes (start each instruction with the superpowers:brainstorming directive; the ONLY early exit is a pass that returned zero findings). Gate A has no edit-invalidation backing it — this floor is the only thing keeping the spec review honest. Run more passes before executing." "⚠ Codex Gate A below floor ($passesA/$floor)"
            else
              emit "Codex Gate A: $passesA/$floor mcp__codex__exec pass(es) on the spec/plan (floor met). Proceed only if your final pass was clean — no new Blocker/Major." "✓ Codex Gate A satisfied ($passesA/$floor passes)"
            fi
            ;;
        esac
        ;;
    esac
    ;;
esac

exit 0
