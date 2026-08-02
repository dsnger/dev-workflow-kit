#!/bin/sh
# Codex review gate reminders (CLAUDE.md §5). Non-blocking: ALWAYS exits 0.
# Reads a Claude Code hook payload (JSON) on stdin, maintains Gate-A/Gate-B state,
# and emits reminders.
#
# Gate B is verified by CONTENT, not by events: the state file holds a fingerprint of
# the index and the working tree taken at review time, and the commit check
# recomputes it. An event-based scheme (invalidate on Edit/Write) is blind to a file
# changed through Bash — `sed -i`, `eslint --fix`, `git apply`, a codegen step — which
# would leave a stale "reviewed" marker standing. A false ✓ is the dangerous
# direction, so the hook compares three components at invocation time: `git diff HEAD`
# for tracked content, a tree id for the effective index, and a tree id for the worktree.
# That is a deliberate SUPERSET of any one commit's payload — a plain `git commit` carries
# only the index — because firing on more than strictly necessary is the safe direction.
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
state_dir="$repo_root/.context"
state_file="$state_dir/codex-gate.gateB"          # holds the reviewed tree-hash
off_file="$state_dir/codex-gate.off"
on_file="$state_dir/codex-gate.on"                # workflow-adoption marker
floor_file="$state_dir/codex-gate.floor"          # optional per-project floor override
tools_file="$state_dir/codex-gate.tools"          # optional Codex tool-name mapping
noted_file="$state_dir/codex-gate.toolNote"       # marks the unknown-tool note as said
count_file="$state_dir/codex-gate.passCount"      # Gate B (review) passes since last commit
fresh_file="$state_dir/codex-gate.freshCount"     # Gate B passes covering the CURRENT tree
countA_file="$state_dir/codex-gate.passCountA"    # Gate A (exec) passes since last plan execution
# Diagnostic markers. These are NOT gate-pass state: they dedupe one-time disclosures,
# and every write is best-effort. `bgAdvice` is independent of the other two;
# `unverified` means the uncertainty disclosure was shown, `unverifiedPending` that it is
# owed because the flush that would have shown it was suppressed or failed.
bgadv_file="$state_dir/codex-gate.bgAdvice"
unver_file="$state_dir/codex-gate.unverified"
pend_file="$state_dir/codex-gate.unverifiedPending"

# FINDING G: the plugin is installed globally, but the workflow is adopted per project.
# A repo that never ran /workflow-init has no gate to enforce, so the hook does NOTHING
# there — no reminder, and no state either. Silent-but-writing would still litter an
# unrelated project with a .context/ directory it never asked for, and this hook exists
# to stay out of the way of projects that didn't opt in.
#
# Adoption is either marker:
#   · CLAUDE.md carries the §5 gate heading — the team-wide signal, since CLAUDE.md is
#     committed, so a clone is adopted without anyone re-running anything;
#   · .context/codex-gate.on — the explicit one /workflow-init writes, which also covers
#     a project that keeps the gate rules somewhere other than CLAUDE.md.
# Read from disk every run, so adopting a project takes effect without a restart.
#
# The cost is that counters start at zero on the day a project adopts, rather than
# carrying in passes made before it. That is the honest direction: a gate should start
# counting when the project takes the gate on.
# Does CLAUDE.md carry the gate SECTION? Prints how to cite it and succeeds; prints
# nothing and fails when it doesn't. Adoption and the citation share this one predicate
# so they can never disagree about whether the section is there.
#
# Anchored to a Markdown heading whose title STARTS with the section name. A bare
# `grep 'Cross-Model Review'` matches prose — "This project does not use Cross-Model
# Review" adopted a project that said the exact opposite — and so does a heading that
# only mentions it in passing ("## Appendix: why we dropped Cross-Model Review").
# Erring tight is the safe direction here: a project whose heading is worded oddly goes
# silent and is fixed with the .on marker, whereas erring loose is the Finding-G noise
# in a project that opted out.
#
# The number is read from the heading, not assumed to be 5: /workflow-init renumbers the
# section when the file already uses that number, and a citation pointing at the WRONG
# section is the same defect as one pointing at a missing section. An unnumbered heading
# cites the file alone.
gate_citation() {
  h=$(grep -Em1 '^#{1,6}[[:space:]]+([0-9]+\.)?[[:space:]]*Cross-Model Review' "$repo_root/CLAUDE.md" 2>/dev/null) || return 1
  [ -n "$h" ] || return 1
  n=$(printf '%s' "$h" | sed -n 's/^#\{1,6\}[[:space:]]*\([0-9]\{1,\}\)\..*/\1/p')
  if [ -n "$n" ]; then printf 'CLAUDE.md §%s' "$n"; else printf 'CLAUDE.md'; fi
}

is_adopted() {
  [ -f "$on_file" ] && return 0
  gate_citation >/dev/null
}
is_adopted || exit 0

# Cite the rules the project actually has. Adoption via the marker alone means they may
# live anywhere, and a reminder pointing at a section the reader cannot open is exactly
# the Finding-G noise this hook just stopped making.
policy=$(gate_citation) || policy="this project's review policy"

# §5 HARD FLOOR: minimum Codex passes per gate before exiting it. The hook can't
# read Codex's findings (so it can't auto-detect the "zero-findings" early exit
# — that judgment stays with the model per §5), but it CAN count passes and flag
# when the floor isn't met. This is what backs Gate A, which has no content check
# behind it (unlike Gate B, which at least compares a content fingerprint — though
# that proves the current fingerprint matches the recorded one, not that Codex read
# those bytes).
# Per-project override: .context/codex-gate.floor holding a positive integer.
floor=3
if [ -f "$floor_file" ]; then
  f=$(cat "$floor_file" 2>/dev/null | tr -d '[:space:]')
  # Positive integer only; anything else (0, -1, "three", empty) keeps the default,
  # so a typo'd override can't silently disable the gate.
  case "$f" in
    '' | *[!0-9]*) ;;
    *) [ "$f" -gt 0 ] 2>/dev/null && floor="$f" ;;
  esac
fi

# Which Codex MCP tools back the gates. The pinned mcp-codex-dev server (written by
# /workflow-init) exposes exec + review, which map 1:1 onto Gate A (reviews TEXT) and
# Gate B (reviews a DIFF). Other Codex servers expose other surfaces — notably the
# official `codex mcp-server`, whose single `codex` tool cannot be attributed to either
# gate. Counting an unattributable tool toward a gate would be a false ✓, so unmapped
# tools are NOT counted; the note below tells the user instead of silently doing nothing.
# Per-project override: .context/codex-gate.tools with `execTool=<name>` / `reviewTool=<name>`.
exec_tool=mcp__codex__exec
review_tool=mcp__codex__review
if [ -f "$tools_file" ]; then
  # `|| [ -n "$k" ]` so a final line without a trailing newline is still read.
  while IFS='=' read -r k v || [ -n "${k:-}" ]; do
    # Trim the EDGES only. Deleting all whitespace would rewrite `execTool=has space`
    # into the perfectly valid name `hasspace` and honor it — turning a typo into a
    # gate pointed at a tool the hook is never invoked for, which this parse guards.
    trim='s/^[[:space:]]*//; s/[[:space:]]*$//'
    k=$(printf '%s' "${k:-}" | sed "$trim")
    v=$(printf '%s' "${v:-}" | sed "$trim")
    # Same rigor as the floor file: only a plausible tool name is honored. Anything
    # else — empty, a comment, a glob character, an unknown key — is ignored, so a
    # typo'd mapping can't silently point a gate at a tool the hook never sees.
    case "$v" in '' | *[!A-Za-z0-9_-]*) continue ;; esac
    # ...and it must lie in the `mcp__codex__*` namespace, which is a CORRECTNESS check
    # and not merely consistency with the documented contract. `hooks.json` matches
    # `^(Bash|Skill|mcp__codex__.*)$`, so a name outside that namespace either never
    # fires — a mapping that looks applied and does nothing — or, for the two reserved
    # names that DO fire, hijacks them: the mapped cases below precede the native `Bash`
    # and `Skill` cases, so `reviewTool=Bash` made a `git commit` COUNT a Gate-B pass
    # instead of resetting the cycle, and `execTool=Skill` counted a skill invocation as
    # a Gate-A pass. Both are false ✓ in recorded state — the direction invariant 2 calls
    # dangerous — reachable from a plausible typo. Ignored like any other unusable line.
    case "$v" in mcp__codex__?*) ;; *) continue ;; esac
    case "$k" in
      execTool) exec_tool="$v" ;;
      reviewTool) review_tool="$v" ;;
    esac
  done < "$tools_file" 2>/dev/null
fi

read_count() { if [ -f "$1" ]; then cat "$1" 2>/dev/null || echo 0; else echo 0; fi; }
bump_count() { n=$(read_count "$1"); { printf '%s' "$((n + 1))" > "$1"; } 2>/dev/null || true; }

# Fingerprint used for the Gate-B comparison, computed at hook invocation: the diff of
# tracked files against HEAD (staged + unstaged), a tree id for the EFFECTIVE INDEX, and
# a tree id for the WORKTREE's untracked paths, contents and modes, via a throwaway
# index (see below). `.context/` is excluded because the hook writes its own state there —
# including it would make the hash change every time the hook runs, so it could never
# match itself.
#
# ALL THREE components must exclude it, and each does so a different way. The tracked
# diff excludes it via a `:(exclude)` pathspec. The index tree excludes it by `git rm
# --cached` against the throwaway index before that tree is written. The worktree tree
# excludes it via the same `:(exclude)` pathspec on `add -A`. `.context/` is committed
# in some projects — the adoption marker is meant to be shared, so this is the normal
# case, not an exotic one — and a tracked state file left in would land in `git diff
# HEAD`, where the hook's own write would invalidate the review it just recorded and
# STOP every commit forever.
#
# Tracked CONTENT comes from `git diff HEAD`, which is staging-independent. The INDEX
# tree is hashed separately, so `git add` of an already-reviewed file DOES invalidate:
# decided at docs/superpowers/specs/2026-07-19-gate-b-index-tree-design.md §2. The
# committed bytes are unchanged in that case, so it is a false invalidation — accepted
# under invariant 2, and the STOP message says staging alone can cause it.
#
# The seed copy is correctness-critical, not just a speed optimisation: `write-tree` on
# an empty index SUCCEEDS with the well-known empty tree, so a silently-failed copy would
# make the index component a constant that matches itself.
#
# Untracked files contribute NAME AND CONTENT. Name alone is not enough: `git add f
# && git commit` is one Bash call, so the hook is consulted while `f` is still
# untracked — and if `f` already existed at review time, editing its contents would
# leave the hash unchanged and hand the commit a stale ✓ on unreviewed content. That
# is the false-✓ direction invariant 3 exists to close, so content is hashed here
# rather than relied upon to show up later in `git diff HEAD`.
#
# That component is produced by staging into a THROWAWAY index and asking git for the
# tree id, rather than by walking the file list and reading each file in shell. The
# shell version has to re-derive what git already knows, and got it wrong three
# separate ways: git C-quotes a non-ASCII path (`"caf\303\251.txt"`, quotes included)
# so the read silently missed it; `cat` follows a symlink to its referent, while a
# commit stores the link target, so a retargeted symlink looked unchanged — and could
# hang outright on a link to a FIFO or /dev/zero; and concatenating name+content with
# no framing lets two different layouts hash alike. `write-tree` has none of those
# failure modes because it is the same code path a real commit takes: exact bytes,
# file modes, symlinks as targets, non-regular files skipped, any path encoding.
#
# GIT_INDEX_FILE keeps this off the real index, so the user's staging area is
# untouched. `add -A` respects .gitignore, so ignored files stay out.
tree_hash() {
  ok=1
  # Same fallback order as before; no checksum tool at all is itself a failure.
  sum_cmd=$(command -v shasum || command -v sha1sum || command -v cksum) || ok=0
  # mktemp -d, not a predictable "$TMPDIR/name.$$": on a shared /tmp a predictable name
  # is a symlink target an attacker can plant.
  tmp_dir=$(mktemp -d 2>/dev/null) || { tmp_dir=''; ok=0; }
  if [ -n "$tmp_dir" ]; then
    tmp_index="$tmp_dir/index"
    # The component stream is BUFFERED and checksummed only on full success (below).
    # Printing a failure marker in-stream would checksum the marker together with the
    # partial output, so no consumer would ever see the literal `unavailable` and two
    # failing runs could produce equal hashes — the false-✓ direction.
    {
      # (0) tracked content. `git diff HEAD` is staging-independent, so it sees staged
      # and unstaged edits alike. An unborn branch is identified POSITIVELY: a bare
      # "--verify failed" also covers a corrupt or unreadable HEAD, and emitting the
      # constant `no-head` for those would self-match.
      if git -C "$repo_root" rev-parse --verify -q HEAD >/dev/null 2>&1; then
        git -C "$repo_root" diff HEAD -- . ':(exclude).context' 2>/dev/null || ok=0
      elif git -C "$repo_root" symbolic-ref -q HEAD >/dev/null 2>&1; then
        printf 'no-head\n'
      else
        ok=0
      fi

      # (1) INDEX tree and (2) WORKTREE tree, from one throwaway index.
      # The index tree is taken BEFORE `add -A` brings the temp index up to the
      # worktree, because `git commit` commits the index — that is the whole defect.
      # `eff_index`, not `$git_dir/index`: git honours GIT_INDEX_FILE, and a missing
      # alternate index is an EMPTY index to git, so the carve-out must follow the same
      # path git will.
      # A RELATIVE GIT_INDEX_FILE must then be normalized against $repo_root before the
      # `[ ! -e ]` test and `cp` below: those are plain shell commands, resolved against
      # the hook's OWN cwd — while every git call here uses `-C "$repo_root"`, and git
      # itself resolves a relative GIT_INDEX_FILE against the repository TOP-LEVEL, not
      # the caller's cwd. Left unnormalized, running the hook from a subdirectory with a
      # relative ambient GIT_INDEX_FILE makes the shell half look in the wrong place,
      # find nothing, and take the absent-index carve-out — hashing a CONSTANT empty tree
      # while the real index has content (a false "satisfied", not a false STOP).
      # $repo_root is already absolute (from `git rev-parse --show-toplevel`), so
      # prefixing it is enough; an already-absolute eff_index (incl. the $git_dir/index
      # default) is left as-is.
      # `rm -rfq --cached`: without -f git refuses to remove a path whose staged content
      # differs from both HEAD and the worktree — exactly the divergent state this story
      # is about — and does so silently, since stderr is redirected. It runs against the
      # THROWAWAY index; the user's real staging area is untouched.
      if git_dir=$(git -C "$repo_root" rev-parse --absolute-git-dir 2>/dev/null) &&
         [ -n "$git_dir" ] &&
         eff_index=${GIT_INDEX_FILE:-$git_dir/index} &&
         case "$eff_index" in
           /*) : ;;
           *) eff_index="$repo_root/$eff_index" ;;
         esac &&
         { [ ! -e "$eff_index" ] || cp "$eff_index" "$tmp_index" 2>/dev/null; } &&
         GIT_INDEX_FILE="$tmp_index" git -C "$repo_root" rm -rfq --cached \
           --ignore-unmatch -- .context >/dev/null 2>&1 &&
         GIT_INDEX_FILE="$tmp_index" git -C "$repo_root" write-tree 2>/dev/null &&
         GIT_INDEX_FILE="$tmp_index" git -C "$repo_root" add -A \
           -- . ':(exclude).context' >/dev/null 2>&1 &&
         GIT_INDEX_FILE="$tmp_index" git -C "$repo_root" write-tree 2>/dev/null
      then :; else ok=0; fi
    } > "$tmp_dir/stream" 2>/dev/null || ok=0
  fi

  h=''
  if [ "$ok" -eq 1 ]; then
    # The checksum's OWN status must be seen: `cmd < file | awk` reports awk's status,
    # so a checksum failing after emitting a partial line would be stored as a real
    # fingerprint. Parse with a shell expansion — `${raw%% *}` has no exit status to mask.
    if raw=$("$sum_cmd" < "$tmp_dir/stream" 2>/dev/null); then
      h=${raw%% *}
    fi
  fi
  if [ -n "${tmp_dir:-}" ]; then rm -rf "$tmp_dir" 2>/dev/null; fi
  # A checksum that runs but emits nothing is a failure too, not an empty tree. The
  # marker is a CONSTANT, not a nonce: `date +%s`+`$$` can repeat under PID reuse inside
  # one second, and two colliding failures would compare equal and report satisfied.
  # Never-matching is enforced at the comparison sites instead.
  if [ -n "$h" ]; then printf '%s\n' "$h"; else printf 'unavailable\n'; fi
}

emit() { # $1 = additionalContext (model-visible), $2 = systemMessage (user)
  # hookSpecificOutput.additionalContext IS honored on PreToolUse (and PostToolUse):
  # per https://code.claude.com/docs/en/hooks.md the PreToolUse decision-control
  # table lists additionalContext as "String added to Claude's context alongside the
  # tool result". Plain stdout on exit 0 is NOT surfaced to the model, so this is the
  # supported channel for a non-blocking reminder the model must actually read.
  #
  # Per-workspace opt-out: while .context/codex-gate.off exists, stay silent.
  # State tracking (SET/INVALIDATE/RESET) keeps running while off, so re-enabling
  # carries the same counting semantics as if the gate had been on — not a guarantee
  # that every counted call was reviewed.
  #
  # THREE statuses, and callers must treat ONLY 0 as "shown":
  #   0 — a complete hook JSON document was written
  #   1 — suppressed by the off-switch
  #   2 — the write failed
  # A one-time note keys its marker off 0 alone. Returning 0 after a failed write burns
  # the one-shot on a message nobody can read, and the note never comes back.
  [ -f "$off_file" ] && return 1
  if command -v jq >/dev/null 2>&1; then
    # jq encodes the strings, so any character (incl. control chars) is escaped correctly.
    jq -cn --arg ev "$event" --arg ctx "$1" --arg msg "$2" \
      '{hookSpecificOutput:{hookEventName:$ev,additionalContext:$ctx},systemMessage:$msg}' || return 2
  else
    # Fallback (no jq): escape backslash + quote. The supported reminders are
    # static and control-char-free, so this is sufficient.
    #
    # BOTH substitutions are status-checked. A failed one yields an EMPTY field while
    # `printf` still exits 0, so without the check a document reading
    # `additionalContext:""` would be written and reported as a successful write —
    # well-formed, empty, and having spent the one-shot.
    # `$event` is escaped TOO, and it is the one field that was not. It comes from the
    # payload, so it is untrusted: an event name ending in a backslash emitted
    # `"hookEventName":"Bogus\","`, where the backslash escapes the closing quote and
    # Claude Code receives invalid JSON. The jq branch above never had this — `--arg`
    # encodes it — so the defect existed only on the fallback path. Routing now also
    # refuses to flush an unroutable event, which closes the only route that reached
    # here with a hostile name; this escape is the second of the two, kept because a
    # field interpolated raw next to two escaped ones is a trap for the next editor.
    ev=$(printf '%s' "$event" | sed 's/\\/\\\\/g; s/"/\\"/g') || return 2
    ctx=$(printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g') || return 2
    msg=$(printf '%s' "$2" | sed 's/\\/\\\\/g; s/"/\\"/g') || return 2
    printf '{"hookSpecificOutput":{"hookEventName":"%s","additionalContext":"%s"},"systemMessage":"%s"}\n' "$ev" "$ctx" "$msg" || return 2
  fi
  return 0
}

# --- RESULT CLASSIFICATION MESSAGES -------------------------------------------------
# Target model: Claude Sonnet 4.5 / Opus 4.1 via Claude Code (prompting guidance checked
# for that model family). FIVE PAIRS, ten strings, all declared unconditionally so `set
# -u` cannot abort on any path.
#
# The field split follows spec §6: `additionalContext` is read by Claude via Claude Code,
# `systemMessage` by the operator. A remedy only a human can perform — restarting Claude
# Code, editing a config, changing a server timeout, unmapping a tool — belongs in
# `systemMessage`, because the model receiving `additionalContext` cannot do any of it.
#
# Each is a SINGLE-QUOTED shell string, so no ASCII apostrophe may appear inside one:
# POSIX shell cannot escape an apostrophe within single quotes. Inner examples use double
# quotes and possessives are phrased around it.
FAILURE_CTX='Claude via Claude Code — gate hook. <state>this Codex call returned an envelope reporting failure.</state> <consequence>Not counted as a gate pass, no review fingerprint stored, does not count toward the floor.</consequence> <next>Read error.code in the tool result. CODEX_EXECUTION_FAILED is the pinned server generic failure code and does NOT tell you whether the call started, so check the accompanying error message and any session artifacts before assuming nothing ran; a call that did start may have left work behind. CODEX_TIMEOUT means the executor gave up mid-run: re-run the SAME call with the SAME scope. Any other code, or no code at all, is unclassified: this state covers every envelope the hook managed to route AND read as carrying success false as its first property, which is not limited to the two codes named here — routing, locating the result text and the raw key spelling each gate it, and an envelope failing any of those lands in a different state instead. So re-run once with the same scope and, if it repeats, report the code and message verbatim together with the effective server name and version from claude mcp list — an unfamiliar code is itself evidence about which server answered. Never retry with a narrower instruction or a smaller range, because that would count a pass for less than the artifact or diff the gate requires. Report one line: "gate pass discarded | error-code | started yes/no/unknown". Before re-running, delete the target findings file for the pass and confirm it is gone — both branch files for a full Gate-B re-run, only the failed branch for a single-branch resume. The checks on that file establish its structure — terminator present, count matching, nothing but finding lines — and not which run produced it.</next> <stop>One retry per pass is the whole recovery budget under CLAUDE.md section 5. If the retry also fails, stop and surface that line; the operator note carries the configuration remedy.</stop>'
FAILURE_MSG='⚠ Codex call failed — not counted as a gate pass. If the code was CODEX_TIMEOUT, the fix is configuration and only you can apply it: raise the executor timeout for the Codex MCP server, or reduce load outside the review. Do not ask for a smaller review scope — a narrower pass is worth less than a slow one.'

NORESULT_CTX='Claude via Claude Code — gate hook. <state>this gate call carried no result text the hook could read.</state> <consequence>Not counted as a gate pass, no review fingerprint stored.</consequence> <next>Treat the pass as not run and report it. Two causes produce this shape and the tool name cannot separate them: a hooks-API payload change, or a third-party tool returning empty or non-text content — which reaches the gates either through a mapping in .context/codex-gate.tools or as a server registered under the default name codex, so an absent mapping does not rule it out. Report one line: "gate call unreadable | mapped yes/no from .context/codex-gate.tools | claude-code version". Before re-running, delete the target findings file for the pass and confirm it is gone — both branch files for a full Gate-B re-run, only the failed branch for a single-branch resume. The checks on that file establish its structure — terminator present, count matching, nothing but finding lines — and not which run produced it.</next> <stop>One retry per pass is the whole recovery budget under CLAUDE.md section 5. A repeat is configuration or contract, not a transient failure, so stop and surface it; the operator note carries both checks.</stop>'
# shellcheck disable=SC2016  # the backticks quote a command for a human to read, verbatim
NORESULT_MSG='⚠ Gate call returned no readable result — not counted. Run both checks before concluding. First: does .context/codex-gate.tools map a tool name? Second: what does `claude mcp list` show as the effective server and version — not what .mcp.json says, because scope precedence can make a different entry of the same name effective. These checks narrow the cause; they do not prove it. If a mapping or a third-party server is in play, that tool may be returning empty or non-text content, which it can do legitimately: unmap it, or replace it with a server exposing exec and review. If both checks show the pinned server at its pinned version, a payload-contract change is the remaining explanation — record your Claude Code version and report it.'

BG_LONG_CTX='Claude via Claude Code — gate hook. <state>this gate call was moved to the background at the auto-background threshold, 120 s by default, so its result never reached the hook.</state> <consequence>The pass was discarded and not counted, and no fingerprint was stored.</consequence> <next>The original call may still be running and can still write its findings file later. If the tool result carries a task id, stop that task by it; if it carries none, wait for the call to finish. Do that before deleting that slot or re-running the pass. Before re-running, delete the target findings file for the pass and confirm it is gone — both branch files for a full Gate-B re-run, only the failed branch for a single-branch resume. The checks on that file establish its structure — terminator present, count matching, nothing but finding lines — and not which run produced it.</next> <stop>Do not re-run while that task is active: a late writer landing in a slot you already re-ran leaves a correctly terminated file from the wrong run, and no downstream check can detect that. One retry per pass is the whole recovery budget under CLAUDE.md section 5. If the call backgrounds a second time, stop and surface it as a setup problem rather than retrying again, reporting one line: "gate pass discarded | backgrounded | second occurrence | CLAUDE_CODE_MCP_AUTO_BACKGROUND_MS set yes/no".</stop>'
BG_LONG_MSG='⚠ Gate pass discarded (backgrounded) — a setup gap, not a failed review. Set CLAUDE_CODE_MCP_AUTO_BACKGROUND_MS in the environment Claude Code is launched from, then restart Claude Code: it reads the value at process start, so exporting it inside a tool shell leaves the running session unchanged. Use 0 to disable auto-backgrounding, or a positive value that exceeds your longest gate call, since a positive value shorter than the call still backgrounds it. Requires Claude Code 2.1.212 or newer.'

BG_SHORT_CTX='Claude via Claude Code — gate hook. <state>this gate call was backgrounded and its result never reached the hook.</state> <consequence>The pass was discarded and not counted, and no fingerprint was stored.</consequence> <next>If the tool result carries a task id, stop that task by it; if it carries none, await the original call. Do that before re-running the pass. Before re-running, delete the target findings file for the pass and confirm it is gone — both branch files for a full Gate-B re-run, only the failed branch for a single-branch resume. The checks on that file establish its structure — terminator present, count matching, nothing but finding lines — and not which run produced it.</next> <stop>Do not re-run while that task is active, so a late writer cannot land in a slot you already re-ran. One retry per pass is the whole recovery budget under CLAUDE.md section 5. If the call backgrounds a second time, stop and surface it rather than retrying again, reporting one line: "gate pass discarded | backgrounded | second occurrence | CLAUDE_CODE_MCP_AUTO_BACKGROUND_MS set yes/no".</stop>'
BG_SHORT_MSG='⚠ Gate pass discarded (backgrounded) — not counted. Set CLAUDE_CODE_MCP_AUTO_BACKGROUND_MS in the environment Claude Code is launched from and restart Claude Code; the full guidance was shown once earlier in this workspace.'

UNVERIFIED_CTX='Claude via Claude Code — gate hook. <state>this workspace has classified at least one gate call as countable without being able to interpret its result, and attempted to record it.</state> <consequence>The counter is a mechanical tally, not a count of completed reviews: it can include calls that failed or reviewed nothing, so it can overstate them.</consequence> <next>Judge every pass on its findings artifact and discount any incomplete or unverified call, whatever the counter says.</next> <stop>Normally said once per workspace. It repeats when its marker cannot be persisted, when two hook runs race, or when that marker is deleted by hand or by a tool that cleans .context, so treat a repeat as a marker problem rather than as new information.</stop>'
# shellcheck disable=SC2016  # the backticks quote commands for a human to read, verbatim
UNVERIFIED_MSG='ℹ A gate call was classified as countable without inspection, and recording it was attempted. Causes with a check and a fix: a pinned-server envelope whose key order or formatting changed — compare the version in .mcp.json with the server actually serving the tools (`claude mcp list`), and pinning it back fixes it; a reworded backgrounding notice — set CLAUDE_CODE_MCP_AUTO_BACKGROUND_MS in the environment Claude Code is launched from and restart Claude Code, using 0 to disable auto-backgrounding or a positive value exceeding your longest gate call, needing Claude Code 2.1.212 or newer; a broken awk or sed, which classification requires — check them functionally rather than by version flag, since --version is not POSIX and BSD sed exits nonzero for it on a healthy macOS: `printf "x\\n" | awk "{print}"` must print x and `printf "x\\n" | sed s/x/y/` must print y, each exiting 0. Causes with no user-side fix: a third-party tool whose envelope this hook cannot read — .context/codex-gate.tools names it only if it is mapped, and a third-party server registered under the default codex name reaches the gates with no mapping at all, so an absent mapping does not rule this out; where a mapping does exist, unmapping removes the gate rather than fixing the envelope; a payload the scan refused — four families land here: past the 1 Mi-unit size bound, past the 200-frame nesting-depth cap, structure the scan could not walk, and an ambiguity such as a duplicated tool_response, type or text key. Measuring the payload against those first two bounds rules them in or out; the remaining two produce this same message and the same state and are **not distinguishable from each other**, so record them as unresolved rather than guessing; and a defect in this hook parser — same situation. For either, keep the payload **locally and access-restricted**: it can contain prompts, absolute paths, review content, session identifiers and unrelated concurrent call data, so strip those before showing it to anyone, and never attach it unsanitized to a report. The list is not exhaustive: unrecognized is the terminal class, so any future unmatched shape lands here too.'

# --- RESULT LOCATOR ------------------------------------------------------------------
# ONE escape-aware scan locates the first `text` element of `tool_response` and yields its
# ESCAPED bytes. `jq` is NEVER used here: it would reserialize, erasing exactly the escape
# and whitespace variants the matcher reads.
#
# Statuses: 0 located (block on stdout) · 1 unambiguously nothing there · anything else
# cannot-determine. A caller must not collapse "anything else" onto a class.
#
# `locate_result` is a LOCATOR, NOT A VALIDATOR. What makes the walk trustworthy is
# string-boundary tracking and nothing else: `readstr` decides where every JSON string
# starts and ends from quote state and backslash parity alone, so a `tool_response`
# mentioned INSIDE a string is never mistaken for the key. Malformation outside a string
# boundary may be stepped over; it cannot move where the next string begins. A
# walkable-invalid document is therefore walked past and the real block located.
#
# SINGLE-QUOTED, so no ASCII apostrophe may appear anywhere below, comments included —
# one would terminate the quote and leave this hook unparseable.
# shellcheck disable=SC2016  # an awk program, not shell: $0 and $1 are awk fields
LOCATE_AWK='
function skipws(s, i,   c) {
  while (i <= SLEN) { c = substr(s,i,1)
    if (c==" "||c=="\t"||c=="\n"||c=="\r") i++; else break }
  return i
}
# Consumes a JSON string from its opening quote. Returns the index of the closing
# quote, 0 if unterminated. RAWSTR is the RAW bytes strictly between the quotes, so
# backslash parity falls out of `esc`: a backslash takes the next byte verbatim whatever
# it is, so `\\` ends parity and the following `"` closes the string, while `\"` does not.
#
# The scan tracks parity WITHOUT building the result, then extracts once with substr.
# Appending byte-by-byte was quadratic — each append reallocates and copies a string that
# grows to the length of the value — and a 150 KB text block, ordinary for a Gate-B review
# result and well under the ceiling below, took 10.9 s in one synchronous hook invocation.
# Every byte the loop passes over is a byte of the result, none skipped or transformed, so
# the single substr is exactly what the loop used to accumulate.
function readstr(s, i,   tail) {
  RAWSTR=""
  tail = substr(s, i+1)
  if (match(tail, /^([^"\\]|\\(.|\n))*"/)) {
    RAWSTR = substr(tail, 1, RLENGTH-1)
    return i + RLENGTH
  }
  return 0
}
# Consumes one SPAN and returns the index after it, 0 if it cannot. Not "one JSON
# value": containers keep a CLOSER STACK, so `[1}` is rejected rather than balanced by
# an undifferentiated depth counter, but the members INSIDE a balanced span are not
# parsed — `[1,]` is consumed, not refused. Primitives must be a complete JSON token;
# arbitrary bytes up to the next delimiter are rejected.
function skipval(s, i,   c, st, e, j, tok) {
  c = substr(s,i,1)
  if (c=="\"") { e=readstr(s,i); return e ? e+1 : 0 }
  if (c=="{" || c=="[") { st=""
    while (i<=SLEN) { c=substr(s,i,1)
      if (c=="\"") { e=readstr(s,i); if(!e) return 0; i=e+1; continue }
      if (c=="{" || c=="[") {
        # DEPTH CAP. The stack is a string, so each push is O(len) and deep nesting is
        # quadratic in shell-visible time — work an external MCP result could dictate.
        # Real payloads nest a handful deep; 200 is far above anything Claude Code emits
        # and far below anything that costs. Past it: refuse, which is `unrecognized`.
        if (length(st) >= 200) return 0
        st = st (c=="{" ? "}" : "]")
      }
      else if (c=="}" || c=="]") {
        if (st=="" || substr(st,length(st),1)!=c) return 0
        st = substr(st,1,length(st)-1)
        if (st=="") return i+1
      }
      i++ }
    return 0 }
  j=i
  while (j<=SLEN) { c=substr(s,j,1)
    if (c==","||c=="}"||c=="]"||c==" "||c=="\t"||c=="\n"||c=="\r") break
    j++ }
  tok = substr(s,i,j-i)
  if (tok=="true" || tok=="false" || tok=="null") return j
  if (tok ~ /^-?(0|[1-9][0-9]*)([.][0-9]+)?([eE][-+]?[0-9]+)?$/) return j
  return 0
}
# Read the WHOLE input by accumulating records; the newline put back is the separator
# awk stripped. RS="\0" would be shorter and is NOT portable across POSIX awks.
# CEILING: a payload past the bound is refused rather than SCANNED. It does not bound
# memory or read work — the calling shell already holds the whole input and awk still
# ingests it — so this caps the state-machine string work and nothing else. And a SIZE
# bound only bounds that work if the per-byte cost is constant, which here it is not:
# `substr(s,i,1)` is O(len) per call in BWK awk. A 150 KB block well under this ceiling
# cost 10.9 s in one invocation until `readstr` and the `backgrounded` test were fixed.
# THIS CEILING IS LOAD-BEARING, not a formality: `skipval` still walks containers one
# character at a time, so a large valid sibling container before `tool_response` costs
# 3.2 s at 200 KB and 11.5 s at 400 KB, and this bound is the only thing that stops it —
# a payload just under it still costs tens of seconds. Do not raise it without making
# that walk cheaper first. The unit is
# awk length() units, not bytes: POSIX length() counts characters and implementations
# differ on multibyte input, so the cut-off is not identical between awks.
# Refusal is status 2, which the classifier routes to `unrecognized`: counted, disclosed.
BEGIN { MAXLEN = 1048576; over = 0; tot = 0 }
{ if (over || tot + length($0) + 1 > MAXLEN) over = 1; else { s = s $0 "\n"; tot += length($0) + 1 } }
END {
  if (over) exit 2
  # ONE length() for the whole scan. Every loop below tests against SLEN rather than
  # calling length(s) per iteration, and the accumulator above tracks a running total
  # rather than re-measuring what it just built.
  SLEN=length(s); n=SLEN; i=skipws(s,1)
  if (substr(s,i,1) != "{") exit 2
  i++; found=0; first=1; closed=0
  while (i<=n) { i=skipws(s,i); c=substr(s,i,1)
    if (c=="}") { i++; closed=1; break }
    if (!first) { if (c!=",") exit 2; i=skipws(s,i+1); c=substr(s,i,1) }
    first=0
    if (c!="\"") exit 2
    e=readstr(s,i); if(!e) exit 2
    key=RAWSTR; i=skipws(s,e+1)
    if (substr(s,i,1)!=":") exit 2
    i=skipws(s,i+1)
    if (key=="tool_response") { if (found) exit 2; found=1; tr=i }
    i=skipval(s,i); if(!i) exit 2 }
  if (!closed) exit 2
  if (skipws(s,i) <= n) exit 2          # trailing garbage after the outer object
  if (!found) exit 1
  i=tr
  if (substr(s,i,1)!="[") exit 1        # absent / null / non-array container
  i++; firstel=1
  while (i<=n) { i=skipws(s,i); c=substr(s,i,1)
    if (c=="]") exit 1                  # walked the array, no text element
    if (!firstel) { if (c!=",") exit 2; i=skipws(s,i+1); c=substr(s,i,1)
                    if (c=="]") exit 2 }
    firstel=0
    if (c!="{") { i=skipval(s,i); if(!i) exit 2; continue }
    j=i+1; ttype=""; ttext=""; hastype=0; hastext=0; textisstr=0; firstm=1; oclosed=0
    while (j<=n) { j=skipws(s,j); c=substr(s,j,1)
      if (c=="}") { j++; oclosed=1; break }
      if (!firstm) { if (c!=",") exit 2; j=skipws(s,j+1); c=substr(s,j,1) }
      firstm=0
      if (c!="\"") exit 2
      e=readstr(s,j); if(!e) exit 2
      k=RAWSTR; j=skipws(s,e+1)
      if (substr(s,j,1)!=":") exit 2
      j=skipws(s,j+1)
      # A repeated classification-relevant member is ambiguity, not last-wins.
      if (k=="type") { if (hastype) exit 2; hastype=1
        if (substr(s,j,1)=="\"") { e=readstr(s,j); if(!e) exit 2; ttype=RAWSTR; j=e+1; continue } }
      if (k=="text") { if (hastext) exit 2; hastext=1
        if (substr(s,j,1)=="\"") { e=readstr(s,j); if(!e) exit 2; ttext=RAWSTR; textisstr=1; j=e+1; continue } }
      j=skipval(s,j); if(!j) exit 2 }
    if (!oclosed) exit 2
    if (ttype=="text") { if (!hastext || !textisstr) exit 1; printf "%s", ttext; exit 0 }
    i=j }
  exit 2                                # ran off the end without a closing ]
}
'

# Feed $payload UNCHANGED to the scan and return awk status untouched. No pre-processing,
# no jq, no collapsing of statuses. The program accumulates records and works in END,
# restoring the newline awk stripped, and prints with `printf "%s"` so no trailing newline
# is appended — the caller reads it through command substitution, which strips trailing
# newlines, harmless only because a JSON string cannot contain a raw newline.
locate_result() { printf '%s' "$payload" | awk "$LOCATE_AWK"; }

# --- THE MATCHER, over the ESCAPED bytes the locator produced -------------------------
# strip_ws is BOUNDED at 64 units: real JSON whitespace runs are 0-3 bytes, and an
# unbounded shell loop over externally supplied text is work an arbitrarily large result
# can dictate. Past the bound the leading whitespace remains, so the prefix match fails
# and the block is `unrecognized` — counted and disclosed, the fail-open direction.
strip_ws() { # strips leading literal spaces and the TWO-BYTE escapes \n \t \r
  _v=$1; _i=0
  while [ "$_i" -lt 64 ]; do
    case "$_v" in
      ' '*) _v=${_v# } ;;
      '\n'*|'\t'*|'\r'*) _v=${_v#??} ;;
      *) break ;;
    esac
    _i=$((_i + 1))
  done
  printf '%s' "$_v"
}

# Is the value token `true`/`false` and nothing glued to it? `true*` alone would accept
# `truely`, which is a false SUCCESS — the dangerous direction.
_token_ends() { # $1 = the bytes after the literal
  case "$(strip_ws "$1")" in '' | ,* | '}'*) return 0 ;; esac
  return 1
}

classify_block() {
  b=$1
  # no-result: blank on the located bytes. One sed pass, so a huge blank block costs
  # linear work in sed rather than iterations of the bounded shell loop above.
  #
  # sed's STATUS is checked, because sed is load-bearing here: a missing or failing sed
  # yields an empty substitution, which would read as blank and classify a genuine
  # success envelope as `no-result` — fail-CLOSED, the one direction this design refuses
  # for a result it can see. An unusable sed is uncertainty, so it goes to `unrecognized`.
  #
  # SCOPE: that guarantee is POST-ROUTING only. `field()` also needs sed on the jq-free
  # path, so with jq absent AND sed absent `hook_event_name` and `tool_name` come back
  # empty, the payload routes nowhere, and classification is never reached — nothing is
  # counted and nothing is disclosed. Read as unconditional, the sentence above would
  # promise a disclosure the hook has no path to make.
  if _stripped=$(printf '%s' "$b" | sed 's/\\[ntr]//g; s/ //g'); then
    case "$_stripped" in '') printf no-result; return ;; esac
  else
    printf unrecognized; return
  fi
  # backgrounded: the anchor at start of text, with `" is still running after `
  # occurring BEFORE any newline — ${b%%\\n*} is the text up to the first \n escape.
  #
  # TWO guards, and the second exists because the first was not enough. `%%` removes the
  # LONGEST matching suffix, which bash 3.2 — macOS /bin/sh, what this hook runs under —
  # evaluates by trying successively longer suffixes, at a cost quadratic in the distance
  # to the first `\n`. Measured: 5.4 s at 150 KB, 21.6 s at 300 KB, in ONE synchronous
  # invocation.
  #
  #   1. The literal anchor prefix. Not an optimization that changes what matches:
  #      ${b%%\n*} is a PREFIX of $b, so a block not starting with the anchor cannot
  #      produce a prefix that does. It skips the expansion for ordinary envelopes.
  #   2. A BOUNDED head. Guard 1 alone still ran the full expansion on any block that
  #      does start with the anchor and then never completes the notice — 5.9 s at 150 KB
  #      (Gate-B pass 2 found this; the first timed fixture began with an envelope and
  #      took guard 1's cheap path, so it never saw the branch). Truncating first makes
  #      the expansion's input constant-size. A "does it contain \n" test does NOT fix
  #      it: with the newline near the END the expansion still scans to it, 5.5 s.
  #
  # `printf '%.Ns'` is POSIX string precision and works in both sh and dash (verified).
  # THE LIMIT THIS BUYS, stated rather than left to be discovered: the segment must fall
  # within the first 4096 characters, so a notice whose quoted tool name is ~4070+ chars
  # long is classified `unrecognized` instead of `backgrounded` — it COUNTS rather than
  # being discarded, which is the wrong direction. 4096 is ~200x the longest real tool
  # name, and this is the same kind of bounded backstop as the 64-unit whitespace bound
  # and the 200-frame depth cap, failing the same way.
  case "$b" in
    'MCP tool \"'*)
      _bg_head=$(printf '%.4096s' "$b")
      _bg_head=${_bg_head%%\\n*}
      case "$_bg_head" in
        'MCP tool \"'*'\" is still running after '*) printf backgrounded; return ;;
      esac ;;
  esac
  # envelope polarity, immediately-first, tolerating encoded whitespace at each of
  # the three grammar points: after `{`, after the key, after the colon.
  case "$b" in '{'*) ;; *) printf unrecognized; return ;; esac
  p=$(strip_ws "${b#\{}")
  case "$p" in '\"success\"'*) ;; *) printf unrecognized; return ;; esac
  p=$(strip_ws "${p#'\"success\"'}")
  case "$p" in ':'*) ;; *) printf unrecognized; return ;; esac
  v=$(strip_ws "${p#:}")
  case "$v" in
    true*)  if _token_ends "${v#true}";  then printf success; return; fi ;;
    false*) if _token_ends "${v#false}"; then printf failure; return; fi ;;
  esac
  printf unrecognized
}

# `[ "$rc" = 0 ] ||` rather than `[ "$rc" = 2 ] &&`: a missing or failing awk exits 127,
# and every status that is not "located" or "nothing there" must reach the fail-open class
# rather than fall through to a matcher holding an empty string.
classify() {
  blk=$(locate_result); rc=$?
  [ "$rc" = 1 ] && { printf 'no-result'; return 0; }
  [ "$rc" = 0 ] || { printf 'unrecognized'; return 0; }
  classify_block "$blk"
}

# --- OUTPUT BUFFER ----------------------------------------------------------------
# Spec §6: an invocation that owes TWO messages composes them into ONE document. That is
# impossible while each branch writes as it decides, so branches call `note` and the
# single write happens in `flush_notes`, immediately before the final exit. `emit` is
# called from `flush_notes` and nowhere else.
#
# A7 — SEPARATORS AND ENCODING. `additionalContext` bodies join with " — " (space, em
# dash, space); `systemMessage` bodies with a single space. NO NEWLINE anywhere: the
# jq-free emitter escapes only backslash and quote, so a literal newline would produce an
# invalid JSON document.
notes_ctx=''
notes_msg=''
have_notes=0
note() { # $1 = additionalContext body, $2 = systemMessage body
  if [ "$have_notes" -eq 0 ]; then
    notes_ctx="$1"; notes_msg="$2"
  else
    notes_ctx="$notes_ctx — $1"; notes_msg="$notes_msg $2"
  fi
  have_notes=1
}

# Same buffer, opposite end. Spec §6 fixes the composed order as **disclosure first, then
# the per-occurrence message**, and the per-occurrence message is buffered during routing
# while the disclosure is only decided in the flush — so the flush has to prepend. It used
# to call `note`, which appended, silently inverting a settled order; the golden froze the
# inversion, so nothing caught it until a reviewer read the spec against the test.
note_front() { # $1 = additionalContext body, $2 = systemMessage body
  if [ "$have_notes" -eq 0 ]; then
    notes_ctx="$1"; notes_msg="$2"
  else
    notes_ctx="$1 — $notes_ctx"; notes_msg="$2 $notes_msg"
  fi
  have_notes=1
}

# --- THE DIAGNOSTIC INTERFACE -------------------------------------------------------
# `note_unverified` sets a flag and NOTHING else: the decision is here, the delivery and
# the state are in the flush, because only the flush knows whether anything was written.
mark_noted=0
mark_bgadv=0
want_unverified=0
note_unverified() { want_unverified=1; }
note_discarded() { # $1 = the class whose pass is being discarded
  case "$1" in
    failure)   note "$FAILURE_CTX" "$FAILURE_MSG" ;;
    no-result) note "$NORESULT_CTX" "$NORESULT_MSG" ;;
    backgrounded)
      if [ -f "$bgadv_file" ]; then
        note "$BG_SHORT_CTX" "$BG_SHORT_MSG"
      else
        note "$BG_LONG_CTX" "$BG_LONG_MSG"; mark_bgadv=1
      fi
      ;;
  esac
}

# One-shot markers are applied HERE, not at the branch that asked for them, because only
# the flush knows whether anything was actually written. `emit` status 0 alone means
# shown; 1 (suppressed) and 2 (write failed) both leave the one-shot unspent.
#
# The A5 marker table, in code. `Earlier: ` says whose call the statement describes, not
# where the debt came from: a carried disclosure must not read as a statement about the
# current call, and when the current call is ITSELF unrecognized the statement IS about
# it, so no prefix — which is why `want_unverified` takes precedence over the pending
# check. Every marker write is best-effort: a failure proceeds and exits 0, with the debt
# retained (duplicate beats loss) rather than dropped.
flush_notes() {
  # shown + owed cannot both stand: drop the debt, best-effort, and disclose nothing.
  if [ -f "$unver_file" ] && [ -f "$pend_file" ]; then
    rm -f "$pend_file" 2>/dev/null || true
  fi
  _disclose=0
  _prefix=''
  if [ "$want_unverified" -eq 1 ]; then
    [ -f "$unver_file" ] || _disclose=1
  elif [ ! -f "$unver_file" ] && [ -f "$pend_file" ]; then
    _disclose=1
    _prefix='Earlier: '
  fi
  if [ "$_disclose" -eq 1 ]; then
    note_front "$_prefix$UNVERIFIED_CTX" "$_prefix$UNVERIFIED_MSG"
  fi
  [ "$have_notes" -eq 1 ] || return 0
  emit "$notes_ctx" "$notes_msg"
  _flushed=$?
  if [ "$_flushed" -eq 0 ]; then
    mkdir -p "$state_dir" 2>/dev/null
    if [ "$mark_noted" -eq 1 ]; then
      # `printf '%s' '' > f`, NEVER `: > f`. `:` is a POSIX SPECIAL BUILTIN, so a
      # redirection failure on one makes the shell EXIT — ignoring this `{ … }
      # 2>/dev/null || true` and even an enclosing `if`. With a directory at the target
      # the `:` form exits 2 under dash, and Ubuntu's /bin/sh IS dash. Invariant 1 says
      # the hook always exits 0; this is the form that keeps it.
      { printf '%s' '' > "$noted_file"; } 2>/dev/null || true
    fi
    if [ "$mark_bgadv" -eq 1 ]; then
      { printf '%s' '' > "$bgadv_file"; } 2>/dev/null || true
    fi
    if [ "$_disclose" -eq 1 ]; then
      if { printf '%s' '' > "$unver_file"; } 2>/dev/null; then
        rm -f "$pend_file" 2>/dev/null || true
      else
        # The debt outlives the marker it could not write.
        { printf '%s' '' > "$pend_file"; } 2>/dev/null || true
      fi
    fi
  elif [ "$_disclose" -eq 1 ] && [ ! -f "$pend_file" ]; then
    mkdir -p "$state_dir" 2>/dev/null
    { printf '%s' '' > "$pend_file"; } 2>/dev/null || true
  fi
  return 0
}

# Loose by design (a missed commit = false ✓ = the dangerous direction). The
# leading (^|[^[:alnum:]]) anchors `git` as a word so "digit commit" doesn't
# false-fire, while still catching `&& git`, `;git`, `/path/git`, etc.
is_commit() { printf '%s' "$1" | grep -Eq '(^|[^[:alnum:]])git[[:space:]].*commit'; }

# A WIP commit is cycle-internal, not a cycle boundary. CLAUDE.md §5 tells the user
# to make one so `mcp__codex__review` has a non-empty range to read (baseSha=HEAD is
# an empty HEAD..HEAD range pre-commit). Treating it as a real commit would fire a
# spurious STOP and reset the very counters the review loop is accumulating — the
# documented workaround would fight the hook. So: gentle note, no reset.
is_wip_commit() { printf '%s' "$1" | grep -Eiq -- "-m[[:space:]]*['\"]?[[:space:]]*wip"; }

# A commit that stages all tracked changes (-a / -am / --all) also sweeps in
# tracked-but-unstaged edits that `git diff --cached` alone won't show, so the
# docs-only check below must consult the unstaged set too. (`--amend` is two
# dashes and never matches, so it isn't mistaken for -a.)
has_all_flag() { printf '%s' "$1" | grep -Eq '(^|[[:space:]])(-[a-z]*a[a-z]*|--all)([[:space:]]|$)'; }

# Prompts are Markdown too, and a prompt is product, not documentation: skills,
# slash commands, plugin content and the instruction files all end in .md. Exempting
# them would hand a false "N/A" to exactly the change that most needs Gate B — the
# dangerous direction. These are Claude Code convention paths, not this repo's
# layout, so the test stays project-neutral.
#
# The directory names match at ANY depth, deliberately: a monorepo keeps prompts at
# `packages/*/.claude/`, and root-anchoring would miss them (a false N/A, the wrong
# direction — invariant 2). The price is that prose under a directory happening to be
# named `commands/` or `skills/` — e.g. `docs/commands/reference.md` — fires Gate B
# too. That is a redundant reminder on an advisory hook, which is the cost invariant 2
# accepts by name.
is_prompt_path() {
  printf '%s\n' "$1" |
    grep -Eq '(^|/)(CLAUDE|AGENTS)\.md$|(^|/)(\.claude|plugins|skills|commands)/'
}

# True ONLY when the file list is non-empty AND every path is a doc artifact
# (*.md anywhere, or under .context/) AND none of them is a prompt. Restricted to
# the .md extension on purpose: a non-Markdown file under docs/ (e.g. a script) IS
# code and must still hit Gate B, so we do NOT exempt the docs/ directory
# wholesale. An empty/undeterminable list returns false, so the caller falls
# through to the loose Gate-B default (fire) — keeping "missed code commit" the
# safe direction.
is_docs_only() {
  [ -n "$1" ] || return 1
  printf '%s\n' "$1" | grep -vE '(\.md$|^\.context/)' | grep -q . && return 1
  is_prompt_path "$1" && return 1
  return 0
}

# `routed` gates the flush below. Spec §3.3: a payload the hook cannot ROUTE produces no
# output and touches no state — but `flush_notes` used to run unconditionally, so a pending
# disclosure was emitted (and cleared) on an event no branch here recognized. That is also
# how an untrusted event name reached the fallback emitter.
routed=0
case "$event" in
  PostToolUse)
    routed=1
    case "$tool" in
      "$review_tool")
        # CLASSIFY BEFORE TOUCHING ANY PASS STATE. Three classes write none of it and
        # say why; `success` and `unrecognized` behave exactly as before, the second
        # adding the disclosure that the count was taken without inspection. There is no
        # `exit 0` in the discarded branch — the message just buffered has to reach
        # `flush_notes` at the bottom.
        cls=$(classify)
        case "$cls" in
          failure | no-result | backgrounded) note_discarded "$cls" ;;
          *)
        [ "$cls" = unrecognized ] && note_unverified
        mkdir -p "$state_dir" 2>/dev/null
        h=$(tree_hash)
        prev=$(cat "$state_file" 2>/dev/null || echo '')
        # A pass carrying the SAME fingerprint as the previous pass adds to the fresh
        # count; a pass on a changed fingerprint starts the count over. That is what lets
        # the satisfied message report how many passes carry the CURRENT fingerprint,
        # rather than how many happened at some point this cycle (Finding 9). It does not
        # establish that Codex read those bytes — see the note at the satisfied branch.
        # An unhashable pass carries no fingerprint, so it neither counts as a match with
        # the last pass nor starts a fresh streak at 1 — two `unavailable` values are not
        # a match.
        if [ "$h" != unavailable ] && [ "$h" = "$prev" ]; then
          bump_count "$fresh_file"
        elif [ "$h" = unavailable ]; then
          { printf '%s' 0 > "$fresh_file"; } 2>/dev/null || true
        else
          { printf '%s' 1 > "$fresh_file"; } 2>/dev/null || true
        fi
        { printf '%s' "$h" > "$state_file"; } 2>/dev/null || true
        bump_count "$count_file"
            ;;
        esac
        ;;
      "$exec_tool")
        cls=$(classify)
        case "$cls" in
          failure | no-result | backgrounded) note_discarded "$cls" ;;
          *)
            [ "$cls" = unrecognized ] && note_unverified
            mkdir -p "$state_dir" 2>/dev/null
            bump_count "$countA_file"
            ;;
        esac
        ;;
      mcp__codex__*)
        # FINDING F: a Codex server is connected, but under tool names the gates can't
        # attribute. Left silent, this is the worst failure mode the hook has: reviews
        # run, counters stay 0, and the STOP fires on every commit forever — which
        # trains the user to ignore the hook. Say it once (the marker), not per call.
        #
        # Target model: Claude Sonnet 4.5 / Opus 4.1 via Claude Code — same family and
        # same prompting-guidance check as the five constants above. DOUBLE-quoted,
        # unlike those, because it interpolates the three tool names, which is also why
        # the `$` closing its matcher literal is escaped.
        if [ ! -f "$noted_file" ]; then
          mark_noted=1
          note "Claude via Claude Code — gate hook. <state>Codex tool '$tool' is not counted by the review gates. The gates count '$exec_tool' (Gate A, reviews TEXT) and '$review_tool' (Gate B, reviews a DIFF); your Codex server exposes a surface that cannot be attributed to one gate or the other.</state> <consequence>Passes made through it stay invisible and Gate B will keep reporting 'not run', because a gate that cannot attribute a call cannot credit it.</consequence> <next>Treat reviews run through this tool as uncounted and say so when you report gate status; do not read a satisfied count as covering them. Every remedy is a configuration change on the operator machine — installing a server, editing .mcp.json, writing a mapping file — so it is addressed to the operator in the note beside this one, and there is nothing here for you to apply.</next> <stop>Said once per workspace, so treat a repeat as a marker problem rather than as new information.</stop>" "ℹ Codex tool '$tool' is not counted by the gates. The gates count '$exec_tool' (Gate A, reviews TEXT) and '$review_tool' (Gate B, reviews a DIFF). Fix, in order of preference. First: install the pinned mcp-codex-dev server, which exposes both — /dev-workflow:workflow-init writes it into .mcp.json. Second, only if your server genuinely has two tools that separate reviewing TEXT from reviewing a DIFF: map the names in .context/codex-gate.tools ('execTool=<name>' / 'reviewTool=<name>'). Pointing both gates at one general-purpose tool moves the counters without either gate meaning what it says, which is a false checkmark and worse than this note. Either way the tool name must start with mcp__codex__: this hook is invoked by a hooks.json matcher of ^(Bash|Skill|mcp__codex__.*)\$, so an out-of-namespace name is either never delivered to this hook at all — the mapping looks applied and does nothing — or, for the two reserved names Bash and Skill, is delivered and hijacks a lifecycle event. Both are refused. Register the server under the name codex to place its tools there."
        fi
        ;;
      Bash)
        cmd=$(input_field command)
        # RESET on commit closes the Gate-B cycle. A WIP commit does NOT close it
        # (see is_wip_commit).
        #
        # We reset regardless of whether the commit actually SUCCEEDED. The Bash
        # tool_response shape is documented as {stdout, stderr, interrupted, isImage}
        # (https://code.claude.com/docs/en/hooks.md) — it carries NO exit status, so a
        # failed commit is not reliably distinguishable from a successful one, and
        # scraping stderr for git's error prose would be a guess that breaks silently.
        # So we take the safe direction: a failed commit that resets costs only
        # re-running the passes. The opposite error — skipping a reset because we
        # wrongly judged the commit failed — would carry passes across a real cycle
        # boundary and produce a false ✓, which is the failure this hook exists to
        # prevent. Revisit if an exit-status field is ever documented.
        if is_commit "$cmd" && ! is_wip_commit "$cmd"; then
          rm -f "$state_file" "$count_file" "$fresh_file"
        fi
        ;;
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
    routed=1
    case "$tool" in
      Bash)
        cmd=$(input_field command)
        if is_commit "$cmd"; then
          if is_wip_commit "$cmd"; then
            note "WIP commit — cycle-internal, per $policy: this exists so mcp__codex__review has a non-empty range to read (baseSha = this commit's parent). Gate B is not evaluated here and your pass counters are preserved. Run the review against this commit, then make the real commit when your final pass is clean." "ℹ WIP commit (Codex cycle preserved)"
          else
          # Docs-only commits (spec/plan .md files) carry no code diff,
          # so Gate B (mcp__codex__review reviews a code diff) cannot apply — emit a
          # gentle note instead of the STOP/floor reminders. Only when the file list
          # is POSITIVELY confirmed docs-only; an empty list falls through to fire.
          files=$(git -C "$repo_root" diff --cached --name-only 2>/dev/null)
          has_all_flag "$cmd" && files=$(printf '%s\n%s\n' "$files" "$(git -C "$repo_root" diff --name-only 2>/dev/null)")
          files=$(printf '%s\n' "$files" | sed '/^$/d')
          if is_docs_only "$files"; then
            note "Docs-only commit — no code is staged, so Codex Gate B (mcp__codex__review reviews a code diff) does not apply here. If this commit includes a spec or plan, confirm it went through Gate A (mcp__codex__exec) instead." "ℹ Codex Gate B N/A (docs-only commit)"
          else
            passes=$(read_count "$count_file")
            fresh=$(read_count "$fresh_file")
            reviewed=$(cat "$state_file" 2>/dev/null || echo '')
            current=$(tree_hash)
            if [ -z "$reviewed" ]; then
              # No count ratio here on purpose: no fingerprint is recorded for this
              # cycle, so showing "N/3" would read as floor progress. `-z "$reviewed"`
              # does not mean only "no pass this cycle": a FIRST write that fails (no
              # prior fingerprint to fall back to), or a state file that cannot be read
              # back, leaves it empty too. A failed REPLACEMENT write is different — it
              # preserves the older, now-stale fingerprint, which reaches the STALE
              # branch below, not this one. The message names the absent FINGERPRINT,
              # not an absent review.
              note "STOP — Codex Gate B not satisfied: no fingerprint is recorded for this cycle — either no mcp__codex__review has run, or the last one's fingerprint could not be written or read back. Per $policy you MUST reach a minimum of $floor passes per cycle. Run Gate B (mcp__codex__review) now; if this repeats, check that .context/ and the state file inside it are readable and writable, and if the file exists but is unreadable or empty, delete it and run a fresh pass." "⚠ Codex Gate B: no recorded review"
            # `unavailable` on EITHER side is never a match: an uncomputable fingerprint
            # must read as unverified, and two of them must not cancel out.
            elif [ "$current" = unavailable ] || [ "$reviewed" = unavailable ] ||
                 [ "$reviewed" != "$current" ]; then
              # Content check, not event check: this fires for a change made through ANY
              # tool — Edit/Write, or a Bash `sed -i` / `eslint --fix` / `git apply`.
              # It names the STATE, never a cause: five states reach here and the hook
              # cannot tell them apart (spec §4). Do not "improve" this into asserting
              # that the tree changed — under a repeated computation failure nothing
              # changed, and under a failed state write the content may be exactly what
              # was reviewed.
              note "STOP — Codex Gate B not satisfied: the hook cannot confirm that the content you are about to commit is the content mcp__codex__review last saw ($passes recorded pass(es) this cycle). Usually that means the working tree or the index changed since the review. It can also mean you only staged already-reviewed content — the bytes are fine, but the hook cannot tell staging from editing; that this hook was upgraded and the recorded fingerprint uses the older format (see CHANGELOG); or that the fresh fingerprint could not be computed or could not be stored. Run Gate B (mcp__codex__review) now — one clean pass is the complete remedy for the staging and post-upgrade cases too. If a fresh pass leaves this unchanged with nothing edited in between, the fault is in the machinery rather than the code: check that .context/ is writable, that TMPDIR is writable, that a checksum tool (shasum, sha1sum or cksum) runs, that git status works, and that the disk is not full — then run one more pass to record a usable fingerprint. Per $policy you MUST re-review after every fix." "⚠ Codex Gate B not satisfied (cannot confirm review)"
            elif [ "$passes" -lt "$floor" ]; then
              note "Codex Gate B floor NOT met: only $passes/$floor mcp__codex__review pass(es) since the last commit. Per $policy the review is a LOOP with a hard minimum of $floor passes — run more (the ONLY early exit is a pass that returned zero findings), or proceed only if $policy's skip rule applies to this change — if you cannot locate and check that rule, run the remaining passes." "⚠ Codex Gate B below floor ($passes/$floor)"
            else
              # Distinguish the two counts (Finding 9): the cycle total includes passes
              # made BEFORE later edits, so they carry a different fingerprint.
              # FINGERPRINT EQUALITY IS ALL THIS PROVES. The hook compares a hash of
              # disk; mcp__codex__review reads a git range — so a match does NOT
              # establish that Codex read these bytes (spec §7, and the review-range row
              # in todos.md). The stronger phrasing was here and was removed; do not
              # restore it as a clarity improvement.
              note "Codex Gate B: $passes/$floor pass(es) this cycle, of which $fresh cover the CURRENT content fingerprint (unchanged since that review). The floor counts the cycle; only the fresh pass(es) carry the same fingerprint as what you are committing. Per $policy, commit only if your final pass was clean — no new Blocker/Major." "✓ Codex Gate B satisfied ($passes/$floor cycle, $fresh on current fingerprint)"
            fi
          fi
          fi
        fi
        ;;
      Skill)
        case "$(input_field skill)" in
          superpowers:executing-plans | superpowers:subagent-driven-development)
            passesA=$(read_count "$countA_file")
            if [ "$passesA" -lt "$floor" ]; then
              note "Codex Gate A floor NOT met: only $passesA/$floor mcp__codex__exec pass(es) on this spec/plan. Per $policy Gate A is a LOOP with a hard minimum of $floor passes (start each instruction with the superpowers:brainstorming directive; the ONLY early exit is a pass that returned zero findings). Gate A has no content check behind it — this floor is the only thing keeping the spec review honest. Run more passes before executing." "⚠ Codex Gate A below floor ($passesA/$floor)"
            else
              # Deliberately weaker wording than Gate B (Finding 12): countA counts
              # mcp__codex__exec CALLS, bound to no artifact. Hashing the artifact would
              # be wrong — a spec is SUPPOSED to change between passes — so the hook
              # cannot verify what was reviewed, and must not imply that it did.
              note "Codex Gate A: $passesA/$floor mcp__codex__exec pass(es) on this spec/plan — floor met by COUNT ONLY. The hook counts calls; it cannot verify what was reviewed or that findings were addressed. Proceed only if your final pass was clean — no new Blocker/Major." "✓ Codex Gate A floor met ($passesA/$floor passes, count only)"
            fi
            ;;
        esac
        ;;
    esac
    ;;
esac

# Unroutable payload: no output, no state, debt preserved for a later routable event.
[ "$routed" -eq 1 ] && flush_notes
exit 0
