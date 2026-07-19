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
# that proves the content is unchanged since the review, not that Codex read it).
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
    # gate pointed at a tool that never fires, which is the failure this parse guards.
    trim='s/^[[:space:]]*//; s/[[:space:]]*$//'
    k=$(printf '%s' "${k:-}" | sed "$trim")
    v=$(printf '%s' "${v:-}" | sed "$trim")
    # Same rigor as the floor file: only a plausible tool name is honored. Anything
    # else — empty, a comment, a glob character, an unknown key — is ignored, so a
    # typo'd mapping can't silently point a gate at a tool that never fires.
    case "$v" in '' | *[!A-Za-z0-9_-]*) continue ;; esac
    case "$k" in
      execTool) exec_tool="$v" ;;
      reviewTool) review_tool="$v" ;;
    esac
  done < "$tools_file" 2>/dev/null
fi

read_count() { if [ -f "$1" ]; then cat "$1" 2>/dev/null || echo 0; else echo 0; fi; }
bump_count() { n=$(read_count "$1"); { printf '%s' "$((n + 1))" > "$1"; } 2>/dev/null || true; }

# Hash of everything that could end up in a commit: the diff of tracked files
# against HEAD (staged + unstaged), a tree id for the EFFECTIVE INDEX, and a tree id
# for the WORKTREE's untracked paths, contents and modes, via a throwaway-index (see
# below). `.context/` is excluded because the hook writes its own state there —
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
  # State tracking (SET/INVALIDATE/RESET) keeps running so re-enabling is accurate.
  #
  # Returns 1 when suppressed, 0 when something was actually written — callers that
  # dedupe a one-time note key their marker off that, so a note suppressed here is
  # still available once the workspace opts back in.
  [ -f "$off_file" ] && return 1
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

case "$event" in
  PostToolUse)
    case "$tool" in
      "$review_tool")
        mkdir -p "$state_dir" 2>/dev/null
        h=$(tree_hash)
        prev=$(cat "$state_file" 2>/dev/null || echo '')
        # A pass covering the SAME tree as the previous pass adds to the fresh count;
        # a pass on a changed tree starts the fresh count over. This is what lets the
        # satisfied message say how many passes cover the code being committed,
        # rather than how many happened at some point this cycle (Finding 9).
        # An unhashable pass covers nothing, so it neither counts as "same tree as last
        # pass" nor starts a fresh streak at 1 — two `unavailable` values are not a match.
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
      "$exec_tool") mkdir -p "$state_dir" 2>/dev/null; bump_count "$countA_file" ;;
      mcp__codex__*)
        # FINDING F: a Codex server is connected, but under tool names the gates can't
        # attribute. Left silent, this is the worst failure mode the hook has: reviews
        # run, counters stay 0, and the STOP fires on every commit forever — which
        # trains the user to ignore the hook. Say it once (the marker), not per call.
        if [ ! -f "$noted_file" ]; then
          if emit "Codex tool '$tool' is not counted by the review gates. The gates count '$exec_tool' (Gate A, reviews TEXT) and '$review_tool' (Gate B, reviews a DIFF); your Codex server exposes a surface that cannot be attributed to one gate or the other, so passes made through it stay invisible and Gate B will keep reporting 'not run'. The fix is to install the pinned mcp-codex-dev server, which exposes both (/dev-workflow:workflow-init writes it into .mcp.json). Mapping the names in .context/codex-gate.tools ('execTool=<name>' / 'reviewTool=<name>') is only an option if your server genuinely has two tools that separate reviewing TEXT from reviewing a DIFF — pointing both gates at one general-purpose tool moves the counters without either gate meaning what it says, which is a false ✓ and worse than this note. Said once per workspace." "ℹ Codex tool '$tool' is not counted by the gates — see the note"; then
            mkdir -p "$state_dir" 2>/dev/null
            { : > "$noted_file"; } 2>/dev/null || true
          fi
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
    case "$tool" in
      Bash)
        cmd=$(input_field command)
        if is_commit "$cmd"; then
          if is_wip_commit "$cmd"; then
            emit "WIP commit — cycle-internal, per $policy: this exists so mcp__codex__review has a non-empty range to read (baseSha = this commit's parent). Gate B is not evaluated here and your pass counters are preserved. Run the review against this commit, then make the real commit when your final pass is clean." "ℹ WIP commit (Codex cycle preserved)"
          else
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
              emit "STOP — Codex Gate B not satisfied: no fingerprint is recorded for this cycle — either no mcp__codex__review has run, or the last one's fingerprint could not be written or read back. Per $policy you MUST reach a minimum of $floor passes per cycle. Run Gate B (mcp__codex__review) now; if this repeats, check that .context/ and the state file inside it are readable and writable, and if the file exists but is unreadable or empty, delete it and run a fresh pass." "⚠ Codex Gate B: no recorded review"
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
              emit "STOP — Codex Gate B not satisfied: the hook cannot confirm that the content you are about to commit is the content mcp__codex__review last saw ($passes recorded pass(es) this cycle). Usually that means the working tree or the index changed since the review. It can also mean you only staged already-reviewed content — the bytes are fine, but the hook cannot tell staging from editing; that this hook was upgraded and the recorded fingerprint uses the older format (see CHANGELOG); or that the fresh fingerprint could not be computed or could not be stored. Run Gate B (mcp__codex__review) now — one clean pass is the complete remedy for the staging and post-upgrade cases too. If a fresh pass leaves this unchanged with nothing edited in between, the fault is in the machinery rather than the code: check that .context/ is writable, that TMPDIR is writable, that a checksum tool (shasum, sha1sum or cksum) runs, that git status works, and that the disk is not full — then run one more pass to record a usable fingerprint. Per $policy you MUST re-review after every fix." "⚠ Codex Gate B not satisfied (cannot confirm review)"
            elif [ "$passes" -lt "$floor" ]; then
              emit "Codex Gate B floor NOT met: only $passes/$floor mcp__codex__review pass(es) since the last commit. Per $policy the review is a LOOP with a hard minimum of $floor passes — run more (the ONLY early exit is a pass that returned zero findings), or proceed only if this change is trivial." "⚠ Codex Gate B below floor ($passes/$floor)"
            else
              # Distinguish the two counts (Finding 9): the cycle total includes passes
              # made BEFORE later edits, which no longer cover the code being committed.
              # FINGERPRINT EQUALITY IS ALL THIS PROVES. The hook compares a hash of
              # disk; mcp__codex__review reads a git range — so a match does NOT
              # establish that Codex read these bytes (spec §7, and the review-range row
              # in todos.md). The stronger phrasing was here and was removed; do not
              # restore it as a clarity improvement.
              emit "Codex Gate B: $passes/$floor pass(es) this cycle, of which $fresh cover the CURRENT content fingerprint (unchanged since that review). The floor counts the cycle; only the fresh pass(es) carry the same fingerprint as what you are committing. Per $policy, commit only if your final pass was clean — no new Blocker/Major." "✓ Codex Gate B satisfied ($passes/$floor cycle, $fresh on current fingerprint)"
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
              emit "Codex Gate A floor NOT met: only $passesA/$floor mcp__codex__exec pass(es) on this spec/plan. Per $policy Gate A is a LOOP with a hard minimum of $floor passes (start each instruction with the superpowers:brainstorming directive; the ONLY early exit is a pass that returned zero findings). Gate A has no content check behind it — this floor is the only thing keeping the spec review honest. Run more passes before executing." "⚠ Codex Gate A below floor ($passesA/$floor)"
            else
              # Deliberately weaker wording than Gate B (Finding 12): countA counts
              # mcp__codex__exec CALLS, bound to no artifact. Hashing the artifact would
              # be wrong — a spec is SUPPOSED to change between passes — so the hook
              # cannot verify what was reviewed, and must not imply that it did.
              emit "Codex Gate A: $passesA/$floor mcp__codex__exec pass(es) on this spec/plan — floor met by COUNT ONLY. The hook counts calls; it cannot verify what was reviewed or that findings were addressed. Proceed only if your final pass was clean — no new Blocker/Major." "✓ Codex Gate A floor met ($passesA/$floor passes, count only)"
            fi
            ;;
        esac
        ;;
    esac
    ;;
esac

exit 0
