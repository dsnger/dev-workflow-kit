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
    # contains a literal } or an escaped quote — the run stops at the first unescaped
    # quote — and decodes \n, \t, \r, \" and \\ as jq does; any other escaped character
    # stands for itself, and a \u escape becomes `?`.
    printf '%s' "$payload" | sed 's/.*"tool_input"[[:space:]]*:[[:space:]]*{//' \
      | grep -oE "\"$1\"[[:space:]]*:[[:space:]]*\"([^\"\\\\]|\\\\.)*\"" | head -n1 \
      | sed 's/^[^:]*:[[:space:]]*"//; s/"$//' \
      | awk 'BEGIN { RS = "\001" } {
          s = $0; o = ""
          while ((i = index(s, "\\")) > 0) {
            o = o substr(s, 1, i - 1); c = substr(s, i + 1, 1)
            if (c == "n") o = o "\n"; else if (c == "t") o = o "\t"; else if (c == "r") o = o "\r"
            else if (c == "u") { o = o "?"; s = substr(s, i + 6); continue }
            else o = o c
            s = substr(s, i + 2)
          }
          printf "%s", o s
        }'
  fi
}

# tool_input.sessionId is non-empty, read with jq only. Without jq the call counts, as before
# 0.40: three jq-free readers in a row drew new boundary or failure-path findings at Gate B
# (PR 91), so the mechanism was cut rather than repaired again (rules: shrink a regenerating class).
# The findings-file check below applies without jq too; only this exclusion needs jq.
exec_resumed() { command -v jq >/dev/null 2>&1 && [ -n "$(input_field sessionId)" ]; }

# 0.45: a Gate A call counts only when its instruction labels one findings file, `Findings file: <path>`,
# and that file is complete (kit-044 k044ga7q: a reply-only call, cut by the server, counted as a pass).
# Prints the failed condition, or nothing. It checks structure only — the terminator, the count, each
# body line's severity prefix — not the six fields, not which run wrote the file, not what it reviewed.
# Without jq, input_field's fallback reads `instruction` (a required input of the exec tool); a path
# written with a \u escape decodes to `?` and does not match, so the call is not counted.
exec_findings() {
  _t=''; _two=''
  # Plain shell past grep: no sed here, so a broken sed (section 39b) does not change the count.
  # shellcheck disable=SC2016  # the backticks are a literal label quote, not a command
  while IFS= read -r _l; do
    _l=${_l#Findings file: }
    case "$_l" in '`'*) _l=${_l#?} ;; esac
    # The match ends in the delimiter after `.md` (so `x.md.tmp` is no `x.md`); drop it again.
    while :; do case "$_l" in *.md | '') break ;; *) _l=${_l%?} ;; esac; done
    if [ -z "$_t" ]; then _t=$_l; elif [ "$_l" != "$_t" ]; then _two=1; fi
  done <<EOF_FINDINGS
$(input_field instruction | grep -oE 'Findings file: `?[^[:space:]`]*\.context/codex-reviews/gate-a-(spec|plan)-[a-z0-9]{8,16}-pass-[1-9][0-9]*\.md([[:space:]`),;]|\.([[:space:]]|$)|$)')
EOF_FINDINGS
  [ -n "$_t" ] || { echo 'names no findings file'; return; }
  [ -z "$_two" ] || { echo 'names two findings files'; return; }
  _n=${_t##*/}
  case "$_t" in
    .context/codex-reviews/"$_n" | "$repo_root"/.context/codex-reviews/"$_n") ;;
    *) echo 'findings file elsewhere'; return ;;
  esac
  _f="$repo_root/.context/codex-reviews/$_n"
  if [ -L "$_f" ] || [ ! -f "$_f" ]; then echo 'findings file missing'; return; fi
  _r=$(awk '{ l[NR] = $0 }
    END {
      n = NR
      if (n < 2 || l[n] !~ /^END OF FINDINGS \([0-9]+ total\)$/) { print "incomplete"; exit }
      t = l[n]; sub(/^END OF FINDINGS \(/, "", t); sub(/ total\)$/, "", t); t = t + 0
      if (t == 0) { print ((n == 2 && l[1] == "NO FINDINGS") ? "ok" : "incomplete"); exit }
      if (n - 1 != t) { print "incomplete"; exit }
      for (i = 1; i < n; i++) if (l[i] !~ /^(BLOCKER|MAJOR|MINOR|NIT) \| /) { print "incomplete"; exit }
      print "ok"
    }' "$_f" 2>/dev/null)
  case "$_r" in
    ok) ;;
    incomplete) echo 'findings file incomplete' ;;
    *) echo 'findings file unreadable' ;;
  esac
}

event=$(field hook_event_name)
tool=$(field tool_name)

repo_root=$(git rev-parse --show-toplevel 2>/dev/null) || exit 0
state_dir="$repo_root/.context"
state_file="$state_dir/codex-gate.gateB"          # holds the reviewed tree-hash
off_file="$state_dir/codex-gate.off"
on_file="$state_dir/codex-gate.on"                # workflow-adoption marker
floor_file="$state_dir/codex-gate.floor"          # optional per-project floor override
cap_file="$state_dir/codex-gate.cap"              # optional per-project pass-cap override
capextra_file="$state_dir/codex-gate.cap-extra"   # the cap answer: passes allowed past the cap
tools_file="$state_dir/codex-gate.tools"          # optional Codex tool-name mapping
noted_file="$state_dir/codex-gate.toolNote"       # marks the unknown-tool note as said
# Gate-B passes since the last commit: one per `full` call or matched spec+quality pair.
# Renamed in 0.21.0 because the unit changed — the old names counted CALLS, and a cycle
# spanning the upgrade must start from zero rather than inherit per-call counts.
count_file="$state_dir/codex-gate.passes"
fresh_file="$state_dir/codex-gate.freshPasses"    # Gate B passes covering the CURRENT tree
pending_file="$state_dir/codex-gate.pendingBranch" # one single-branch call awaiting its partner
legacy_count="$state_dir/codex-gate.passCount"     # pre-0.21.0 names: retired, never read
legacy_fresh="$state_dir/codex-gate.freshCount"
countA_file="$state_dir/codex-gate.passCountA"    # Gate A (exec) passes since last plan execution
mode_file="$repo_root/.claude/codex-gate.mode"    # committed gate mode: lean | strict | classic
modeA_file="$state_dir/codex-gate.modeA"          # the mode read at Gate A's first counted pass
modeB_file="$state_dir/codex-gate.modeB"          # the same for Gate B
# Diagnostic markers. These are NOT gate-pass state: they dedupe one-time disclosures,
# and every write is best-effort. `bgAdvice` is independent of the other two;
# `unverified` means the uncertainty disclosure was shown, `unverifiedPending` that it is
# owed because the flush that would have shown it was suppressed or failed.
bgadv_file="$state_dir/codex-gate.bgAdvice"
unver_file="$state_dir/codex-gate.unverified"
pend_file="$state_dir/codex-gate.unverifiedPending"
wipbase_prefix="$state_dir/codex-gate.wipBase."   # + tool_use_id: one `-m wip` record per tool call
headpre_prefix="$state_dir/codex-gate.headPre."   # + tool_use_id: HEAD before this commit-matching call

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
# read Codex's findings or measure a change's size (so it can't auto-detect the
# "zero-findings" early exit or Gate B's small-change close — those judgments stay
# with the model per §5), but it CAN count passes and flag
# when the floor isn't met. This is what backs Gate A, which has no content check
# behind it (unlike Gate B, which at least compares a content fingerprint — though
# that proves the current fingerprint matches the recorded one, not that Codex read
# those bytes).
# The default numbers come from the gate mode (below); this per-project override,
# .context/codex-gate.floor holding a positive integer, sets the floor of both gates.
floor=''
if [ -f "$floor_file" ]; then
  f=$(cat "$floor_file" 2>/dev/null | tr -d '[:space:]')
  # Positive integer only; anything else (0, -1, "three", empty) keeps the default,
  # so a typo'd override can't silently disable the gate. Leading zeros are dropped
  # BEFORE the value is kept: `08` has always been accepted here (`test` reads it as 8),
  # and the cap derivation below hands the floor to `$(( ))`, which reads `08` as an
  # invalid octal — a shell error, so a non-zero exit (this story's Gate B, pass 1).
  # Refusing it instead would drop a configured floor of 8 to 3: a false ✓ (pass 2).
  case "$f" in
    '' | *[!0-9]*) ;;
    *) f=${f#"${f%%[!0]*}"}; [ "$f" -gt 0 ] 2>/dev/null && floor="$f" ;;
  esac
fi

# §5 PASS CAP: the closure ordering's pass-cap stop is a count — the mode's cap per gate
# (classic: the floor plus two), and from a cap answer onward that many more — so the hook reports it the way it reports
# the floor. Reaching it changes nothing here (invariant 1): the message asks for the
# answer (the human's when a Blocker remains, the agent's otherwise), and it goes in .context/codex-gate.cap-extra as a positive integer, which raises
# the cap for the current cycle until the commit reset clears it with the pass counter.
# Per-project override: .context/codex-gate.cap, a positive integer like the floor file.
#
# Where the cap files differ from the floor file, and why. Edges trimmed (surrounding
# blank lines included), not every whitespace deleted: `2 3` deleted to `23` would allow
# twenty-three more passes, the gate-off direction, where the same slip on the floor file
# only asks for more. At most nine digits: these two values are ADDED, and nine digits keep
# every sum far below any overflow. The floor keeps its wider acceptance; one too long for
# the arithmetic is its own cap, compared as a string of digits by `test` below.
pos_int() { # prints $1 as a decimal when it is a positive integer of at most nine digits
  case "$1" in '' | *[!0-9]*) return 1 ;; esac
  _p=${1#"${1%%[!0]*}"}
  case "$_p" in '' | ??????????*) return 1 ;; esac
  printf '%s' "$_p"
}
trim_file() { tr '\n\r' '  ' < "$1" 2>/dev/null | sed 's/^[[:space:]]*//; s/[[:space:]]*$//'; }
read_int_file() { pos_int "$(trim_file "$1")"; }

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

# A count is digits only, as bump_count writes it; anything else (empty after a cut-short
# write, conflict text, `1 2`) reads as 0, and leading zeros go, so `$(( ))` never sees
# an invalid octal like `08`
read_count() {
  _c=; [ -f "$1" ] && _c=$(cat "$1" 2>/dev/null)   # a FIFO would block `cat`
  case "$_c" in '' | *[!0-9]*) _c=0 ;; *) _c=${_c#"${_c%%[!0]*}"} ;; esac
  echo "${_c:-0}"
}
bump_count() { n=$(read_count "$1"); { printf '%s' "$((n + 1))" > "$1"; } 2>/dev/null || true; }

# GATE MODE (0.46). The committed .claude/codex-gate.mode sets each gate's default floor and
# cap. No file, or one that is not exactly a known word once its edges are trimmed, is
# classic: the 0.45 numbers, so a project that never chose a mode reminds as before.
read_mode() { # prints the mode word held in $1, or fails
  [ -f "$1" ] || return 1          # a FIFO would block the read
  _w=$(trim_file "$1")
  case "$_w" in lean | strict | classic) printf '%s' "$_w" ;; *) return 1 ;; esac
}
mode_nums() { # $1 = mode -> nfA ncA nfB ncB (floor and cap per gate)
  case "$1" in
    lean) nfA=2 ncA=2 nfB=1 ncB=3 ;;
    strict) nfA=2 ncA=2 nfB=1 ncB=5 ;;
    *) nfA=3 ncA=5 nfB=3 ncB=5 ;;
  esac
}
mode_bad=0
if ! mode=$(read_mode "$mode_file"); then
  mode=classic
  if [ -e "$mode_file" ] || [ -L "$mode_file" ]; then mode_bad=1; fi
fi
mode_nums "$mode"; floorA=$nfA capA=$ncA floorB=$nfB capB=$ncB
mtA="mode $mode" mtB="mode $mode"
cmA=$mode cmB=$mode   # the cycle's mode per gate: the recorded one while the counter is positive
# The file can change while a cycle is open. Each gate's first counted pass records the mode
# (modeA/modeB, cleared with that gate's counter); while the counter is positive the higher
# floor and the lower cap of the recorded and the current mode apply, so a change mid-cycle
# makes the reminders stricter, never laxer (invariant 2). A positive counter with no usable
# record, a cycle begun under 0.45 or a failed write, counts as a recorded classic.
# Gate A's count is the live one, else the closed one plan execution reads.
cA=$(read_count "$countA_file"); [ -f "$countA_file" ] || cA=$(read_count "$countA_file.closed")
if [ "$cA" != 0 ]; then
  rA=$(read_mode "$modeA_file") || rA=classic
  cmA=$rA
  if [ "$rA" != "$mode" ]; then
    mode_nums "$rA"
    if [ "$nfA" -gt "$floorA" ]; then floorA=$nfA; fi
    if [ "$ncA" -lt "$capA" ]; then capA=$ncA; fi
    mtA="mode $mode, cycle begun under $rA: the higher floor and lower cap of the two"
  fi
fi
if [ "$(read_count "$count_file")" != 0 ]; then
  rB=$(read_mode "$modeB_file") || rB=classic
  cmB=$rB
  if [ "$rB" != "$mode" ]; then
    mode_nums "$rB"
    if [ "$nfB" -gt "$floorB" ]; then floorB=$nfB; fi
    if [ "$ncB" -lt "$capB" ]; then capB=$ncB; fi
    mtB="mode $mode, cycle begun under $rB: the higher floor and lower cap of the two"
  fi
fi
# The override files keep overriding both gates exactly as before 0.46: a floor file sets
# the floor and, unless a cap file is set, the cap at that floor plus two.
ovr=''
if [ -n "$floor" ]; then
  floorA=$floor floorB=$floor ovr=1
  case "$floor" in ??????????*) capA=$floor ;; *) capA=$((floor + 2)) ;; esac
  capB=$capA
fi
if [ -f "$cap_file" ] && c=$(read_int_file "$cap_file"); then capA="$c" capB="$c" ovr=1; fi
if [ -n "$ovr" ]; then
  mtA="$mtA, overridden by a .context/ floor or cap file" mtB="$mtB, overridden by a .context/ floor or cap file"
fi
if [ -f "$capextra_file" ] && c=$(read_int_file "$capextra_file"); then
  case "$capA" in ??????????*) ;; *) capA=$((capA + c)) ;; esac
  case "$capB" in ??????????*) ;; *) capB=$((capB + c)) ;; esac
fi
# Records the mode at a gate's first counted pass. $1 = that gate's count file, $2 = its mode file.
remember_mode() { [ "$(read_count "$1")" = 0 ] && { printf '%s\n' "$mode" > "$2"; } 2>/dev/null; return 0; }

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
# excludes it via the same `:(exclude)` pathspec on `add -A`, plus that `git rm --cached`
# for the retry an ignored `.context/` needs (see the step). `.context/` is committed
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
  ok=1; why=''   # `why`: the FIRST component that failed, named in `unavailable <why>`
  # Same fallback order as before; no checksum tool at all is itself a failure.
  sum_cmd=$(command -v shasum || command -v sha1sum || command -v cksum) || { ok=0; why=checksum; }
  # mktemp -d, not a predictable "$TMPDIR/name.$$": on a shared /tmp a predictable name
  # is a symlink target an attacker can plant.
  tmp_dir=$(mktemp -d 2>/dev/null) || { tmp_dir=''; ok=0; why=${why:-temp dir}; }
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
        git -C "$repo_root" diff HEAD -- . ':(exclude).context' 2>/dev/null || { ok=0; why=${why:-diff}; }
      elif git -C "$repo_root" symbolic-ref -q HEAD >/dev/null 2>&1; then
        printf 'no-head\n'
      else
        ok=0; why=${why:-diff}
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
         GIT_INDEX_FILE="$tmp_index" git -C "$repo_root" write-tree 2>/dev/null
      then
        # Where `.context/` is gitignored (canvas, Bricks), git reports the exclude
        # pathspec as naming an ignored path and exits 1, so every pass stored
        # `unavailable` (S5). The retry without it skips the ignored directory anyway, and
        # the `rm --cached` drops any tracked `.context` path it re-added. Same tree as the
        # first form wherever that form works; a real failure fails the retry too.
        if { GIT_INDEX_FILE="$tmp_index" git -C "$repo_root" add -A \
               -- . ':(exclude).context' >/dev/null 2>&1 ||
             GIT_INDEX_FILE="$tmp_index" git -C "$repo_root" add -A -- . >/dev/null 2>&1; } &&
           GIT_INDEX_FILE="$tmp_index" git -C "$repo_root" rm -rfq --cached \
             --ignore-unmatch -- .context >/dev/null 2>&1 &&
           GIT_INDEX_FILE="$tmp_index" git -C "$repo_root" write-tree 2>/dev/null
        then :; else ok=0; why=${why:-worktree tree}; fi
      else ok=0; why=${why:-index tree}; fi
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
  if [ -n "$h" ]; then printf '%s\n' "$h"; else printf 'unavailable %s\n' "${why:-checksum}"; fi
}
# Runs tree_hash and splits its line: `fp` is the hash or the literal `unavailable` (the
# only value ever stored or compared), `fp_note` a one-line diagnosis when it failed.
fingerprint() {
  fp=$(tree_hash); fp_note=''
  case "$fp" in unavailable*)
    fp_note="⚠ Codex Gate B: fingerprint not computable (${fp#unavailable } failed); recorded as unavailable, which never matches."
    fp=unavailable ;;
  esac
}

emit() { # $1 = additionalContext (model-visible), $2 = systemMessage (user)
  # hookSpecificOutput.additionalContext IS honored on PreToolUse (and PostToolUse):
  # per https://code.claude.com/docs/en/hooks.md the PreToolUse decision-control
  # table lists additionalContext as "String added to Claude's context alongside the
  # tool result". On those two events plain stdout on exit 0 is NOT surfaced to the
  # model, so this is the supported channel for a non-blocking reminder the model must
  # actually read. SessionStart does add plain stdout to the model's context, which the
  # compaction branch in the routing below relies on.
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
    # Fallback (no jq): escape backslash, quote and newline. The reminders carry no other
    # control character, so this is sufficient; the newline is there because the pass-cap
    # message is two lines, and a raw line break inside a JSON string is invalid JSON.
    # `$!N` rather than `N` on the last line: POSIX leaves whether a failing N prints the
    # pattern space to the implementation, and GNU and BSD sed answer it differently.
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
    ev=$(printf '%s' "$event" | sed -e ':a' -e '$!N' -e '$!ba' -e 's/\\/\\\\/g; s/"/\\"/g; s/\n/\\n/g') || return 2
    ctx=$(printf '%s' "$1" | sed -e ':a' -e '$!N' -e '$!ba' -e 's/\\/\\\\/g; s/"/\\"/g; s/\n/\\n/g') || return 2
    msg=$(printf '%s' "$2" | sed -e ':a' -e '$!N' -e '$!ba' -e 's/\\/\\\\/g; s/"/\\"/g; s/\n/\\n/g') || return 2
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
# shellcheck disable=SC2016  # $CODEX_HOME is text for the reader to run, not expanded here
FAILURE_CTX='Claude via Claude Code — gate hook. <state>this Codex call returned an envelope reporting failure.</state> <consequence>Not counted as a gate pass, no review fingerprint stored, does not count toward the floor.</consequence> <next>Read error.code in the tool result. CODEX_EXECUTION_FAILED is the pinned server generic failure code and does NOT tell you whether the call started, so check the accompanying error message and any session artifacts before assuming nothing ran; a call that did start may have left work behind. CODEX_TIMEOUT means the executor gave up mid-run: re-run the SAME call with the SAME scope. Any other code, or no code at all, is unclassified: this state covers every envelope the hook managed to route AND read as carrying success false as its first property, which is not limited to the two codes named here — routing, locating the result text and the raw key spelling each gate it, and an envelope failing any of those lands in a different state instead. When the message is empty, run a direct probe from this same session before the retry: codex exec --skip-git-repo-check "Reply with OK" </dev/null, and echo $CODEX_HOME (empty means the default home, ~/.codex). A usage-limit answer is missing access: stop and tell the human, naming that home, because a probe from another session can use another account and say OK. Otherwise re-run once with the same scope and, if it repeats, report the code and message verbatim together with the effective server name and version from claude mcp list — an unfamiliar code is itself evidence about which server answered. Never retry with a narrower instruction or a smaller range, because that would count a pass for less than the artifact or diff the gate requires. Report one line: "gate pass discarded | error-code | started yes/no/unknown". Before re-running, delete the target findings file for the pass and confirm it is gone — both branch files for a full Gate-B re-run, only the failed branch for a single-branch resume. The checks on that file establish its structure — terminator present, count matching, nothing but finding lines — and not which run produced it.</next> <stop>One retry per pass is the whole recovery budget under CLAUDE.md section 5. If the retry also fails, stop and surface that line; the operator note carries the configuration remedy.</stop>'
FAILURE_MSG='⚠ Codex call failed — not counted as a gate pass. If the code was CODEX_TIMEOUT, the fix is configuration and only you can apply it: raise the executor timeout for the Codex MCP server, or reduce load outside the review. Do not ask for a smaller review scope — a narrower pass is worth less than a slow one.'

NORESULT_CTX='Claude via Claude Code — gate hook. <state>this gate call carried no result text the hook could read.</state> <consequence>Not counted as a gate pass, no review fingerprint stored.</consequence> <next>Treat the pass as not run and report it. Report one line: "gate call unreadable | mapped yes/no from .context/codex-gate.tools | claude-code version". Before re-running, delete the target findings file for the pass and confirm it is gone — both branch files for a full Gate-B re-run, only the failed branch for a single-branch resume. The checks on that file establish its structure — terminator present, count matching, nothing but finding lines — and not which run produced it.</next> <stop>One retry per pass is the whole recovery budget under CLAUDE.md section 5. A repeat is configuration or contract, not a transient failure, so stop and surface it; the operator note carries both checks.</stop>'
# shellcheck disable=SC2016  # the backticks quote a command for a human to read, verbatim
NORESULT_MSG='⚠ Gate call returned no readable result — not counted. Next: check whether .context/codex-gate.tools maps a tool name, and run `claude mcp list` for the effective Codex server and version. Causes and fixes: https://github.com/dsnger/dev-workflow-kit/blob/main/docs/reference.md#hook-messages'

BG_LONG_CTX='Claude via Claude Code — gate hook. <state>this gate call was moved to the background at the auto-background threshold, 120 s by default, so its result never reached the hook.</state> <consequence>The pass was discarded and not counted, and no fingerprint was stored.</consequence> <next>The original call may still be running and can still write its findings file later. If the tool result carries a task id, stop that task by it; if it carries none, wait for the call to finish. Do that before deleting that slot or re-running the pass. Before re-running, delete the target findings file for the pass and confirm it is gone — both branch files for a full Gate-B re-run, only the failed branch for a single-branch resume. The checks on that file establish its structure — terminator present, count matching, nothing but finding lines — and not which run produced it.</next> <stop>Do not re-run while that task is active: a late writer landing in a slot you already re-ran leaves a correctly terminated file from the wrong run, and no downstream check can detect that. One retry per pass is the whole recovery budget under CLAUDE.md section 5. If the call backgrounds a second time, stop and surface it as a setup problem rather than retrying again, reporting one line: "gate pass discarded | backgrounded | second occurrence | CLAUDE_CODE_MCP_AUTO_BACKGROUND_MS set yes/no".</stop>'
BG_LONG_MSG='⚠ Gate pass discarded (backgrounded) — a setup gap, not a failed review. Set CLAUDE_CODE_MCP_AUTO_BACKGROUND_MS in the environment Claude Code is launched from, then restart Claude Code: it reads the value at process start, so exporting it inside a tool shell leaves the running session unchanged. Use 0 to disable auto-backgrounding, or a positive value that exceeds your longest gate call, since a positive value shorter than the call still backgrounds it. Requires Claude Code 2.1.212 or newer.'

BG_SHORT_CTX='Claude via Claude Code — gate hook. <state>this gate call was backgrounded and its result never reached the hook.</state> <consequence>The pass was discarded and not counted, and no fingerprint was stored.</consequence> <next>If the tool result carries a task id, stop that task by it; if it carries none, await the original call. Do that before re-running the pass. Before re-running, delete the target findings file for the pass and confirm it is gone — both branch files for a full Gate-B re-run, only the failed branch for a single-branch resume. The checks on that file establish its structure — terminator present, count matching, nothing but finding lines — and not which run produced it.</next> <stop>Do not re-run while that task is active, so a late writer cannot land in a slot you already re-ran. One retry per pass is the whole recovery budget under CLAUDE.md section 5. If the call backgrounds a second time, stop and surface it rather than retrying again, reporting one line: "gate pass discarded | backgrounded | second occurrence | CLAUDE_CODE_MCP_AUTO_BACKGROUND_MS set yes/no".</stop>'
BG_SHORT_MSG='⚠ Gate pass discarded (backgrounded) — not counted. Set CLAUDE_CODE_MCP_AUTO_BACKGROUND_MS in the environment Claude Code is launched from and restart Claude Code; the full guidance was shown once earlier in this workspace.'

UNVERIFIED_CTX='Claude via Claude Code — gate hook. <state>this workspace has classified at least one gate call as countable without being able to interpret its result, and attempted to record it.</state> <consequence>The counter is a mechanical tally, not a count of completed reviews: it can include calls that failed or reviewed nothing, so it can overstate them.</consequence> <next>Judge every pass on its findings artifact and discount any incomplete or unverified call, whatever the counter says.</next> <stop>Normally said once per workspace. It repeats when its marker cannot be persisted, when two hook runs race, or when that marker is deleted by hand or by a tool that cleans .context, so treat a repeat as a marker problem rather than as new information.</stop>'
UNVERIFIED_MSG='ℹ A gate call was classified as countable without the hook reading its result, and recording it was attempted, so the pass counter can overstate completed reviews. Judge each pass on its findings file. If you report this, keep the raw hook payload local: it can hold prompts, paths and review content. Causes and checks: https://github.com/dsnger/dev-workflow-kit/blob/main/docs/reference.md#hook-messages'

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
# The string, span and whitespace helpers, the whole-input read and the top-level walk are
# shared with REQUEST_AWK and CALLID_AWK below, so all three scans decide string boundaries
# and the outer object the same way.
# shellcheck disable=SC2016  # an awk program, not shell: $0 and $1 are awk fields
JSON_AWK_FUNCS='
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
# THE TOP-LEVEL WALK. Walks the outer object of s once and returns the index where the
# value of its member named `want` starts, 0 when there is none. Refuses (status 2) a
# payload past the ceiling, an outer value that is not an object, a malformed member, a
# repeated `want`, an unclosed object and trailing garbage; with `noesc` set, also any
# top-level key containing a backslash, since an escaped key might decode to `want`.
# exit inside a function ends the whole program, the same as it did inline in END.
function topmember(want, noesc,   i, c, e, key, first, closed, at) {
  if (over) exit 2
  # ONE length() for the whole scan. Every loop tests against SLEN rather than calling
  # length(s) per iteration, and the accumulator above tracks a running total rather than
  # re-measuring what it just built.
  SLEN=length(s); i=skipws(s,1)
  if (substr(s,i,1) != "{") exit 2
  i++; first=1; closed=0; at=0
  while (i<=SLEN) { i=skipws(s,i); c=substr(s,i,1)
    if (c=="}") { i++; closed=1; break }
    if (!first) { if (c!=",") exit 2; i=skipws(s,i+1); c=substr(s,i,1) }
    first=0
    if (c!="\"") exit 2
    e=readstr(s,i); if(!e) exit 2
    key=RAWSTR; i=skipws(s,e+1)
    if (noesc && index(key, "\\")) exit 2
    if (substr(s,i,1)!=":") exit 2
    i=skipws(s,i+1)
    if (key==want) { if (at) exit 2; at=i }
    i=skipval(s,i); if(!i) exit 2 }
  if (!closed) exit 2
  if (skipws(s,i) <= SLEN) exit 2          # trailing garbage after the outer object
  return at
}
'
# shellcheck disable=SC2016  # an awk program, not shell: $0 and $1 are awk fields
LOCATE_AWK="$JSON_AWK_FUNCS"'
END {
  i=topmember("tool_response", 0); n=SLEN
  if (!i) exit 1
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

# --- REQUEST READER (0.21.0) -------------------------------------------------------
# Reads reviewType, baseSha and headSha from the DIRECT members of the top-level
# `tool_input` object and nowhere else — a review result in `tool_response` can quote any
# of those names. Prints one line of three verdicts, `<reviewType> <baseSha> <headSha>`:
# reviewType is absent | spec | quality | full | other; each SHA is absent | bad | its 40
# lowercase hex characters. Prints `uncertain` when the request cannot be read at all.
# Every verdict is decided inside jq or awk, never on a shell capture of the value: jq
# checks the DECODED value, awk the RAW escaped spelling (so an escape anywhere in a value
# makes it fail the exact comparison, the conservative direction). The shell must not
# decide: command substitution strips trailing newlines, so a captured "full" plus a
# newline would read as full. A usable SHA is safe to capture because it can then hold only hex.
# The jq check compares code points rather than using test(): jq regex `$` also matches
# before a final newline, so 39 hex characters plus a newline would pass a length check
# and an anchored pattern together.
#
# The jq-free scan walks with the locator helpers above and carries the same size bound.
# It is uncertain when it finds no top-level tool_input, no closing brace, a member that is
# not a string, a repeated member, or ANY member key containing a backslash — an escaped
# key might decode to one of the three names, and reading it as absent would default a
# single branch to a whole `full` pass.
# SINGLE-QUOTED, so no ASCII apostrophe may appear below.
# shellcheck disable=SC2016  # an awk program, not shell
REQUEST_AWK="$JSON_AWK_FUNCS"'
function rtv(p, v) { if (!p) return "absent"; if (v=="spec"||v=="quality"||v=="full") return v; return "other" }
function shav(p, v) { if (!p) return "absent"; if (length(v)==40 && v !~ /[^0-9a-f]/) return v; return "bad" }
END {
  i=topmember("tool_input", 0); n=SLEN
  if (!i) exit 2
  if (substr(s,i,1)!="{") exit 2
  i++; firstm=1; oclosed=0
  while (i<=n) { i=skipws(s,i); c=substr(s,i,1)
    if (c=="}") { oclosed=1; break }
    if (!firstm) { if (c!=",") exit 2; i=skipws(s,i+1); c=substr(s,i,1) }
    firstm=0
    if (c!="\"") exit 2
    e=readstr(s,i); if(!e) exit 2
    k=RAWSTR; i=skipws(s,e+1)
    if (index(k, "\\")) exit 2
    if (substr(s,i,1)!=":") exit 2
    i=skipws(s,i+1)
    if (k=="reviewType" || k=="baseSha" || k=="headSha") {
      if (k in seen) exit 2
      seen[k]=1
      if (substr(s,i,1)!="\"") exit 2
      e=readstr(s,i); if(!e) exit 2
      val[k]=RAWSTR; i=e+1; continue }
    i=skipval(s,i); if(!i) exit 2 }
  if (!oclosed) exit 2
  printf "%s %s %s", rtv(("reviewType" in seen), val["reviewType"]), shav(("baseSha" in seen), val["baseSha"]), shav(("headSha" in seen), val["headSha"])
  exit 0
}
'
# The jq-free reader of this call's id (call_record_path): the top-level `tool_use_id` member
# only, under the same size bound and the same refusals as the request reader above, so a
# nested key, a key with an escape or a repeated member yields no id. Prints the encoded id
# call_record_path describes; exit 1 when the value is not usable, 2 when unreadable.
# SINGLE-QUOTED, so no ASCII apostrophe may appear below.
# shellcheck disable=SC2016  # an awk program, not shell
CALLID_AWK="$JSON_AWK_FUNCS"'
END {
  i=topmember("tool_use_id", 1)
  if (!i) exit 2
  if (substr(s,i,1)!="\"") exit 1
  readstr(s,i); id=RAWSTR
  if (id !~ /^[A-Za-z0-9_-]+$/ || length(id) > 100) exit 1
  o = ""
  for (k = 1; k <= length(id); k++) { c = substr(id, k, 1)
    if (c == "_") o = o "__"; else if (c ~ /[A-Z]/) o = o "_" tolower(c); else o = o c }
  printf "%s", o
  exit 0
}
'
# shellcheck disable=SC2016  # a jq program, not shell
REQUEST_JQ='
def rt: if has("reviewType") | not then "absent"
  elif (.reviewType | type) != "string" then "uncertain"
  elif .reviewType == "spec" or .reviewType == "quality" or .reviewType == "full" then .reviewType
  else "other" end;
def sha($k): if has($k) | not then "absent"
  elif (.[$k] | type) != "string" then "uncertain"
  elif (.[$k] | length) == 40 and (.[$k] | explode | all(.[]; (. >= 48 and . <= 57) or (. >= 97 and . <= 102))) then .[$k]
  else "bad" end;
if (.tool_input | type) != "object" then "uncertain"
else .tool_input | [rt, sha("baseSha"), sha("headSha")]
  | if any(.[]; . == "uncertain") then "uncertain" else join(" ") end end'
read_request() {
  if command -v jq >/dev/null 2>&1; then
    _req=$(printf '%s' "$payload" | jq -r "$REQUEST_JQ" 2>/dev/null) || _req=uncertain
  else
    _req=$(printf '%s' "$payload" | awk "$REQUEST_AWK" 2>/dev/null) || _req=uncertain
  fi
  # Exactly three space-separated tokens, or nothing usable.
  case "$_req" in
    *' '*' '*' '* | ' '* | *' ' | *'  '*) _req=uncertain ;;
    *' '*' '*) ;;
    *) _req=uncertain ;;
  esac
  printf '%s' "$_req"
}

# --- PAIRING MESSAGES (0.21.0) ------------------------------------------------------
# Target model: Claude Sonnet 4.5 / Opus 4.1 via Claude Code — same family and same
# prompting-guidance check as the classification messages above. Single-quoted ones carry
# no ASCII apostrophe; the two that interpolate a path or field name are built in their
# functions below.
PAIR_RECORDED_CTX='Claude via Claude Code — gate hook. <state>This mcp__codex__review call ran one branch (reviewType spec or quality) and is recorded as a pending branch. It is not counted.</state> <consequence>The hook counts one pass when the other branch runs on the same baseSha and headSha, and counts nothing for a branch whose partner never runs.</consequence> <next>If this branch is half of a logical pass not yet credited, run the other branch with exactly the same baseSha and headSha. If it re-ran a branch of a pass already credited (a recovery), it needs no partner, and a call made only to complete the count is not a review pass.</next> <stop>Said on every unpaired branch call.</stop>'
PAIR_RECORDED_MSG='ℹ Codex Gate B: this review branch is recorded; no matching partner was credited, so it is not counted.'
PAIR_UNCONFIRMED_CTX='Claude via Claude Code — gate hook. <state>This single-branch mcp__codex__review call was not counted, and recording it as the first half of a pass could not be confirmed: writing .context/codex-gate.pendingBranch and reading it back did not return the same record.</state> <consequence>Its partner may not pair with it, so this pass may stay uncounted.</consequence> <next>Treat the pass as uncounted unless a later reminder shows it counted; a recovery of a branch whose pass is already credited needs no partner either way. The cause is not determined here: the write may have failed (check that .context/ is writable), the file may be unreadable or not a regular file (check its type and permissions), or another hook process may have claimed it first (check for review calls running at the same time, and run the branches one after the other).</next> <stop>Said on every call where this happens.</stop>'
PAIR_UNCONFIRMED_MSG='ℹ Codex Gate B: recording this review branch could not be confirmed. Check that .context/ is writable and that no two review calls run at once.'
# shellcheck disable=SC2016  # the backticks quote commands for a human to read, verbatim
REQ_UNREAD_CTX='Claude via Claude Code — gate hook. <state>This mcp__codex__review call was not counted because its request fields (reviewType, baseSha, headSha) could not be read from tool_input.</state> <consequence>The hook cannot tell a whole pass from one branch of a pass, so it counts nothing and leaves any waiting branch as it was.</consequence> <next>Treat this call as uncounted when you report gate status. Causes, each with its check: the request itself — tool_input missing or not an object, reviewType, baseSha or headSha not a plain string, repeated, or written with an escape in its name (check the arguments of the call you made, and pass the three as plain strings); without jq, a payload past the 1 Mi-unit scan bound or the 200-frame nesting-depth cap, or a malformed one (rare for a real call; measure its size and nesting depth if this repeats); a jq that fails (check that `jq --version` runs); or, without jq, an awk that fails (check that `printf "x\\n" | awk "{print}"` prints x). This message cannot tell those apart, so where none of the checks finds the cause, record it as undetermined.</next> <stop>Said on every such call.</stop>'
REQ_UNREAD_MSG='ℹ Codex Gate B: a review call was not counted because its request fields could not be read.'
RT_UNKNOWN_CTX='Claude via Claude Code — gate hook. <state>This mcp__codex__review call carried a reviewType value other than exactly spec, quality or full, so it was not counted.</state> <consequence>The hook credits only shapes it recognizes; an unknown value is never read as a whole pass.</consequence> <next>Use reviewType spec, then quality, on the same baseSha and headSha.</next> <stop>Said on every such call.</stop>'
RT_UNKNOWN_MSG='ℹ Codex Gate B: a review call with an unrecognized reviewType value was not counted.'
PENDING_AT_COMMIT_CTX='Claude via Claude Code — gate hook. <state>Gate-B pending-branch state is present (.context/codex-gate.pendingBranch): a single-branch review call may have run whose partner was never credited. It is not counted, and the hook has not checked that the record is usable.</state> <consequence>Any pass count reported beside this counts hook credits only — full calls and matched spec+quality pairs — and adds nothing for this file. A credit is not a validated findings file.</consequence> <next>If that branch is the first half of your final pass, run its partner on the same baseSha and headSha before closing the cycle. If it was a recovery of a branch whose pass is already counted, it needs no partner, and a call made only to complete the count is not a review pass.</next> <stop>Said at every Gate-B commit check while the file exists.</stop>'
PENDING_AT_COMMIT_MSG='ℹ Codex Gate B: pending-branch state is present, unverified and not counted.'

note_unusable_sha() { # $1 = which field(s)
  note "Claude via Claude Code — gate hook. <state>This single-branch mcp__codex__review call cannot be paired: its $1 is missing or is not a full 40-character lowercase object name.</state> <consequence>It is not counted and is not recorded as half of a pass; any branch already waiting is kept.</consequence> <next>Resolve baseSha and headSha to full 40-character object names (git rev-parse) once per pass and pass the same two values to both branches. The tool default HEAD is symbolic and cannot bind a pair.</next> <stop>Said on every such call.</stop>" \
       "ℹ Codex Gate B: a review branch was not counted — its $1 is not a full 40-character object name."
}
note_stale() { # $1 = absolute path that survived removal
  _rel=${1#"$repo_root"/}
  note "Claude via Claude Code — gate hook. <state>Credit for this mcp__codex__review call was withheld because $_rel could not be removed before counting.</state> <consequence>Nothing was counted and no fingerprint was written, so stale state cannot be read as a fresh pass.</consequence> <next>Remove the path and run the pass again. Causes, if it survives: https://github.com/dsnger/dev-workflow-kit/blob/main/docs/reference.md#hook-messages</next> <stop>Said on every call while the path survives.</stop>" \
       "⚠ Codex Gate B: credit withheld — $_rel could not be removed. Check that .context/ is writable and that the path is a plain file."
}

# --- PAIRING (0.21.0) -----------------------------------------------------------------
# A credit happens only after every stale file it depends on is CONFIRMED GONE — the path
# absent after the attempt. Removal and writes fail independently (an unwritable directory
# still lets existing files be overwritten), so the test is absence, not a write status.
gone() { ! { [ -e "$1" ] || [ -L "$1" ]; }; }
retire() { gone "$1" && return 0; rm -f "$1" 2>/dev/null; gone "$1"; }
retire_legacy() { # $1 = quiet: best effort, no note, carries on past a survivor
  for _lf in "$legacy_count" "$legacy_fresh"; do
    retire "$_lf" && continue
    [ "${1-}" = quiet ] && continue
    note_stale "$_lf"; return 1
  done
  return 0
}
# CLAIM by rename: one rename(2) inside .context/, so at most one hook process can take a
# given pending file, and only the claimant reads it. A failed rename means "nothing
# claimed", which credits nothing. A leftover claim file is never read again.
claim_pending() {
  _claim="$state_dir/codex-gate.pendingClaim.$$"
  mv "$pending_file" "$_claim" 2>/dev/null || return 1
  printf '%s' "$_claim"
}

# Today's counting block, unchanged except that it now runs once per PASS.
credit_pass() {
  fingerprint; h=$fp
  [ -n "$fp_note" ] && note "$fp_note" "$fp_note"
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
  # A failed write must not leave the previous pass's fingerprint standing as if it were
  # this one's (S5, F1): remove it, so the commit check reports "no fingerprint" instead.
  if ! { printf '%s' "$h" > "$state_file"; } 2>/dev/null; then
    rm -f "$state_file" 2>/dev/null
    _m='⚠ Codex Gate B: fingerprint could not be stored; .context/ or its state file is not writable.'
    note "$_m" "$_m"
  fi
  remember_mode "$count_file" "$modeB_file"
  bump_count "$count_file"
}

# One routed, non-discarded review call. $1 = its classification (success | unrecognized).
# The unverified disclosure says recording was ATTEMPTED, so it is raised only on paths
# that attempt a credit or a pending record, never on a call rejected before that.
review_call() {
  mkdir -p "$state_dir" 2>/dev/null
  # Spec §3.1: the old names are retired on every review call classification lets through,
  # before the request is read, so a rejected request still leaves no legacy count behind.
  retire_legacy || return 0
  _req=$(read_request)
  if [ "$_req" = uncertain ]; then note "$REQ_UNREAD_CTX" "$REQ_UNREAD_MSG"; return 0; fi
  _rt=${_req%% *}; _rest=${_req#* }; _base=${_rest%% *}; _head=${_rest#* }
  case "$_rt" in
    absent | full)
      # A whole pass supersedes a half one; a half that cannot be retired blocks it.
      if ! gone "$pending_file"; then
        _c=$(claim_pending) && rm -f "$_c" 2>/dev/null
        gone "$pending_file" || { note_stale "$pending_file"; return 0; }
      fi
      [ "$1" = unrecognized ] && note_unverified
      credit_pass
      ;;
    spec | quality)
      _bad=''
      case "$_base" in absent | bad) _bad=baseSha ;; esac
      case "$_head" in absent | bad) _bad="${_bad:+$_bad and }headSha" ;; esac
      if [ -n "$_bad" ]; then note_unusable_sha "$_bad"; return 0; fi
      # Every path below attempts a credit or a pending record, so the disclosure is true.
      [ "$1" = unrecognized ] && note_unverified
      if [ "$_rt" = spec ]; then _other=quality; else _other=spec; fi
      if _c=$(claim_pending); then
        _rec=$(cat "$_c" 2>/dev/null)
        rm -f "$_c" 2>/dev/null
        if [ "$_rec" = "$_other $_base $_head" ]; then credit_pass; return 0; fi
      fi
      _line="$_rt $_base $_head"
      { printf '%s' "$_line" > "$pending_file"; } 2>/dev/null
      if [ "$(cat "$pending_file" 2>/dev/null)" = "$_line" ]; then
        note "$PAIR_RECORDED_CTX" "$PAIR_RECORDED_MSG"
      else
        note "$PAIR_UNCONFIRMED_CTX" "$PAIR_UNCONFIRMED_MSG"
      fi
      ;;
    *) note "$RT_UNKNOWN_CTX" "$RT_UNKNOWN_MSG" ;;
  esac
  return 0
}

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
# dash, space); `systemMessage` bodies with a single space. A body may carry a line break
# (the pass-cap message is two lines): both emitters write it as the `\n` escape, so the
# serialized document is always ONE line of JSON. No other control character is allowed
# in a body, because the jq-free emitter escapes only backslash, quote and newline.
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

# The pass-cap message, one per gate call or commit attempt at or past the cap. Two lines
# on purpose, the same text on both channels: the model has to stop and answer, and the human
# has to know where the answer goes. The composed document stays one line because `emit`
# escapes the break (jq does, and the fallback does since this message exists).
cap_check() { # $1 = gate letter, $2 = that gate's count file
  mode_note
  case "$1" in A) _cap=$capA _mt=$mtA _cm=$cmA ;; *) _cap=$capB _mt=$mtB _cm=$cmB ;; esac
  _n=$(read_count "$2")
  case "$_n" in
    '' | *[!0-9]*) return 0 ;;          # not a count: nothing to compare
    ???????????????????*) ;;            # nineteen digits or more: past any cap this hook
                                        # can hold, and past what `test` can compare
    *) [ "$_n" -ge "$_cap" ] || return 0 ;;
  esac
  # Target model: Claude via Claude Code. Under lean and strict the cap closes the cycle
  # unless a finding the human must judge is open (spec 0.46 §4); classic keeps its text.
  if [ "$_cm" != classic ]; then
    _m="⚠ Codex Gate $1: pass cap reached ($_n/$_cap). STOP: an open Blocker, Security-class or violated-AC finding, or a cut to an approved commitment, goes to the human; otherwise close the cycle, each open finding a todos.md row.
   Passes the human allows go in .context/codex-gate.cap-extra as an integer. Numbers from $_mt."
    note "$_m" "$_m"; return 0
  fi
  _m="⚠ Codex Gate $1: pass cap reached ($_n/$_cap). STOP: a remaining Blocker, or a cut to an approved commitment, goes to the human; otherwise choose and record why: delete the mechanism, cut scope, or allow N more passes.
   Record the answer as an integer in .context/codex-gate.cap-extra (passes allowed beyond the cap). Numbers from $_mt."
  note "$_m" "$_m"
}
# A present but unusable mode file is said beside every gate number the hook reports; cap_check
# runs at each of those points (gate calls, commit attempts, plan execution), once per run.
mode_said=0
mode_note() {
  [ "$mode_bad" = 1 ] && [ "$mode_said" = 0 ] || return 0
  mode_said=1
  # Target model: Claude via Claude Code.
  note "Codex gate mode: .claude/codex-gate.mode is present but unusable (empty, unreadable, or not exactly one of lean, strict, classic), so the current file counts as classic. An open cycle keeps the mode it began with; the numbers reported beside this note are the ones in force. Say so when you report gate status, and fix the file in your next commit." "⚠ .claude/codex-gate.mode is unusable: the file counts as classic"
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
# false-fire, while still catching `&& git`, `;git`, `/path/git`, etc. Newlines are
# folded first, so a commit split over lines (`git \` newline `commit`) still matches.
is_commit() { printf '%s' "$1" | tr '\n' ' ' | grep -Eq '(^|[^[:alnum:]])git[[:space:]].*commit'; }

# The reset after the command needs more than that match: HEAD or its reflog moved during
# the call, or the hook cannot tell (head_moved). runs_git_commit no longer resets on its own
# (0.37.3); it only decides where PreToolUse adds the not-WIP sentence. Its subcommand
# test wants `git` at a command position — the start, or after `;`, `&`, `|`, `(`, `{`, `!`
# or a backtick, past any `VAR=value` words and the wrappers `sudo`, `command`, `exec`,
# `env`, `nohup`, `time`, `nice` and the keywords `if`, `elif`, `then`, `else`, `while`,
# `until`, `do` — and then only global
# options, where `-C`, `-c`, `--git-dir`, `--work-tree`, `--namespace` and `--config-env`
# take their operand, so `echo git commit` and `git --work-tree commit status` keep the
# cycle's passes. Quoted text without an escaped quote inside is one opaque word, so
# `git log --grep="git commit"` and `git log | grep -i commit` keep them too, and a commit
# hidden in quotes (`sh -c "git commit"`) or behind another prefix (`xargs git commit`) is
# left to head_moved. A line continuation is folded into a space; any other newline
# separates commands. Neither matcher sees an alias (`git ci`).
runs_git_commit() {
  _t="[^[:space:];&|()]+"
  _w="([A-Za-z_][A-Za-z0-9_]*=${_t}[[:space:]]+|(sudo|command|exec|env|nohup|time|nice|if|elif|then|else|while|until|do)[[:space:]]+)*"
  printf '%s' "$1" | awk 'BEGIN { RS = "\001" } { gsub(/\\\n/, " "); gsub(/\n/, " ; "); printf "%s", $0 }' |
    sed -E "s/'[^']*'|\"[^\"]*\"/Q/g; s/--(git-dir|work-tree|namespace|config-env)[[:space:]]+/--\1=/g" |
    grep -Eq "(^|[;&|({!\`])[[:space:]]*$_w([^[:space:];&|()]*/)?git([[:space:]]+(-C|-c)[[:space:]]+$_t|[[:space:]]+-([^Cc[:space:];&|()]|[^[:space:];&|()]{2,}))*[[:space:]]+commit([[:space:];&|()<>\`\"']|\$)"
}

# A WIP commit is cycle-internal, not a cycle boundary. CLAUDE.md §5 tells the user
# to make one so `mcp__codex__review` has a non-empty range to read (baseSha=HEAD is
# an empty HEAD..HEAD range pre-commit). Treating it as a real commit would fire a
# spurious STOP and reset the very counters the review loop is accumulating — the
# documented workaround would fight the hook. So: gentle note, no reset.
#
# Two questions, answered separately, because they are asked at different times:
# PreToolUse decides whether to show the WIP note instead of the Gate-B reminder, before the
# commit runs; PostToolUse decides whether to keep the counters, after it ran. A reminder
# shown in doubt costs nothing, so is_wip_commit_pre refuses whenever anything could change
# the message; is_wip_commit_post can read the commit that resulted, so it keeps the counters
# only when that commit is WIP. Every other commit resets, the safe direction; a call that
# made none keeps them (head_moved).
#
# `-m "wip…"`: an allow-list again — one line of exactly `git commit`, then only `-a`,
# `--all`, `-q`, `--quiet`, `--no-verify`, `-n`, `--amend` or `--allow-empty`, and exactly one
# `-m` whose single-quoted, double-quoted or bare value starts with `wip`; nothing else, so no
# editor (`-e`), `--fixup`, `-F`, second `-m`, `cd`, `git -C`, chain (but one leading `git add
# <plain words> &&`, dropped first) or redirect, and no shell
# metacharacter or backslash anywhere, except `(` and `)` inside single quotes in a command
# with no double quote, where the shell reads them as text (the result is attributed through the call's top-level
# `tool_use_id`, see the record below). Before the
# commit, a repository whose hooks or settings could rewrite the message gets the Gate-B
# reminder instead of the note; after it, the counters stay only if HEAD's subject starts with
# `wip` AND HEAD is attributable to this command. PreToolUse records HEAD, its parent, the
# number of entries in HEAD's reflog, and whether `--amend` is one of the command's options
# (looked for outside quoted text, so a message mentioning it does not count). Afterwards
# either HEAD and the reflog are both unchanged (the commit failed; the WIP commit already
# there stays), or the reflog grew by exactly one entry and HEAD sits directly on the
# recorded HEAD (a new commit) or, for `--amend`, shares the recorded parent. Any other
# change to HEAD in between — a hook that commits, amends or resets — adds reflog entries and
# resets, as does a missing or unreadable record, and so does a repository whose HEAD
# reflog is empty or unreadable before or after: without it neither branch can be told apart
# from a hook that moved HEAD and moved it back. A Bash call that was sent to the background
# (`run_in_background`, or a result carrying a `backgroundTaskId`) is refused too: its
# PostToolUse arrives before the commit has finished, so an unchanged HEAD proves nothing.
# The record belongs to one tool call: it is named after the payload's `tool_use_id`, which
# that call's PreToolUse and PostToolUse share, so overlapping calls cannot read, take or
# delete each other's record. The id is read as a top-level string, by jq
# or, without jq, by CALLID_AWK, and checked there; a call whose id is missing, not a string,
# longer than 100 characters or not made of [A-Za-z0-9_-] gets no record and so resets, as
# does one whose payload the jq-free reader refuses (past its size bound, an escaped or
# repeated key). The file name
# encodes the id so that ids differing only in letter case stay apart on a case-insensitive
# filesystem. PostToolUse removes the call's own
# record; one whose PostToolUse never arrives stays behind as an inert file in `.context/`,
# outside the fingerprint.
#
# `git commit --amend --no-edit` carries no `-m` and normally keeps HEAD's message. It is an
# allow-list, never a deny-list: one line of exactly `git commit` followed only by `--amend`,
# `--no-edit`, `--no-verify`, `-a`, `--all`, `-q` or `--quiet`, both of the first two present,
# with no quote, `#`, backslash or shell metacharacter anywhere, so no quoting trick, comment,
# pathspec, `cd`, `git -C` or chained command can qualify, and global `git -c` is refused
# (its operand can expand into `-C <repo>` or set `commit.cleanup`). It also requires, in
# both phases, that nothing could rewrite the message (below) and that HEAD's subject starts
# with `wip`.
#
# "Could rewrite the message": a custom comment character (cleanup can then strip a `WIP`
# line); any `core.hooksPath` at all, refused rather than resolved, since a path this shell
# cannot carry exactly (a trailing newline, say) would send the check to the wrong directory;
# or a hooks directory holding anything but `*.sample` files — deliberately stricter than
# Git's own rule (Git runs only executable files with hook names), because a message hook
# can rewrite the message (`--no-verify` does not skip `prepare-commit-msg`) and an earlier
# hook such as `pre-commit` can install one mid-commit. Hook contents are never read, and a
# hooks directory this check cannot list counts as able to. The check sees the repository
# as it is when the hook runs, not what another process does afterwards.
msg_may_be_rewritten() {
  git -C "$repo_root" config --get-regexp '^core\.comment(char|string)$' >/dev/null 2>&1 && return 0
  git -C "$repo_root" config --get core.hooksPath >/dev/null 2>&1 && return 0
  _hooks=$(git -C "$repo_root" rev-parse --git-path hooks 2>/dev/null) || return 0
  [ -n "$_hooks" ] || return 0
  case $_hooks in /*) ;; *) _hooks="$repo_root/$_hooks" ;; esac
  if [ -e "$_hooks" ] || [ -L "$_hooks" ]; then
    [ -d "$_hooks" ] && [ -r "$_hooks" ] && [ -x "$_hooks" ] || return 0
    for _f in "$_hooks"/* "$_hooks"/.[!.]* "$_hooks"/..?*; do
      [ -e "$_f" ] || [ -L "$_f" ] || continue
      case ${_f##*/} in *.sample) ;; *) return 0 ;; esac
    done
  fi
  return 1
}
head_is_wip() { git -C "$repo_root" log -1 --format=%s 2>/dev/null | grep -Eiq '^[[:space:]]*wip'; }
# One leading `git add <plain words> &&` is dropped first (0.41.0, canvas 2026-10-22): `git add`
# writes no HEAD reflog entry, so is_wip_commit_post still ties HEAD to this call's one commit
strip_add_prefix() { printf '%s' "$1" | sed -E 's#^[[:space:]]*git[[:space:]]+add([[:space:]]+[A-Za-z0-9._/@+=,:%~-]+)+[[:space:]]*&&##'; }
is_wip_message_cmd() {
  case $1 in *'
'*) return 1 ;; esac
  set -- "$(strip_add_prefix "$1")"
  printf '%s' "$1" | grep -q '[;&|<>$`\\]' && return 1
  # a double quote anywhere keeps them refused: an apostrophe pair inside it is no quoting
  printf '%s' "$1" | sed "/\"/!s/'[^']*'//g" | grep -q '[()]' && return 1
  _ok='(-a|--all|-q|--quiet|--no-verify|-n|--amend|--allow-empty)'
  printf '%s' "$1" | grep -Eiq -- "^[[:space:]]*git[[:space:]]+commit([[:space:]]+$_ok)*[[:space:]]+-m[[:space:]]*('[[:space:]]*wip[^']*'|\"[[:space:]]*wip[^\"]*\"|wip[^[:space:]'\"]*)([[:space:]]+$_ok)*[[:space:]]*$"
}
# A commit message that starts with `wip` in a call is_wip_message_cmd refuses (a `cd`,
# `git -C`, other chain or heredoc) and runs_git_commit sees: PreToolUse says the counters are cleared
# unless HEAD and its reflog stay unchanged. Loose on purpose;
# a heredoc body line starting with `wip` matches too, and an extra sentence costs nothing.
looks_wip_cmd() { printf '%s\n' "$1" | grep -Eiq -- "(-[[:alpha:]]*m|--message)[[:space:]=]*[$]?['\"]?[[:space:]]*wip|^[[:space:]]*['\"]?[[:space:]]*wip"; }
is_wip_amend_cmd() {
  case $1 in *'
'*) return 1 ;; esac
  printf '%s' "$1" | grep -q '[;&|<>$`()\\#"]' && return 1
  printf '%s' "$1" | grep -q "'" && return 1
  printf '%s' "$1" | grep -Eq '^[[:space:]]*git[[:space:]]+commit([[:space:]]+(--amend|--no-edit|--no-verify|-a|--all|-q|--quiet))+[[:space:]]*$' || return 1
  printf '%s ' "$1" | grep -Eq '[[:space:]]--amend[[:space:]]' || return 1
  printf '%s ' "$1" | grep -Eq '[[:space:]]--no-edit[[:space:]]' || return 1
  ! msg_may_be_rewritten && head_is_wip
}
head_reflog_len() { git -C "$repo_root" reflog show --format=%H HEAD 2>/dev/null | grep -c ''; }
wip_record_path() { call_record_path "$wipbase_prefix"; }
call_record_path() { # $1 = prefix; this call's record path; fails when the id is unusable
  # The top-level member only, read by jq or, without jq, by CALLID_AWK; a shell capture
  # would strip a trailing newline before any check could see it, so the type, characters
  # and length are checked inside jq or awk, on the decoded value (awk refuses any escape)
  # and then written as a name no case-insensitive filesystem can merge with another id's:
  # `_` becomes `__` and an upper-case letter `X` becomes `_x`, which decodes uniquely
  if command -v jq >/dev/null 2>&1; then
    _id=$(printf '%s' "$payload" | jq -r '.tool_use_id | if type == "string" and test("\\A[A-Za-z0-9_-]{1,100}\\z") then (gsub("_"; "__") | gsub("(?<c>[A-Z])"; "_" + (.c | ascii_downcase))) else empty end' 2>/dev/null) || return 1
  else
    _id=$(printf '%s' "$payload" | awk "$CALLID_AWK" 2>/dev/null) || return 1
  fi
  case $_id in '' | *[!a-z0-9_-]*) return 1 ;; esac
  printf '%s%s' "$1" "$_id"
}

# Whether the Bash call that matched is_commit moved HEAD: the reset's only test, so a commit
# no spelling test sees (`sh -c "git commit"`, an option it does not know) resets as well.
# PreToolUse records HEAD under this call's tool_use_id, the same per-call naming as the
# `-m wip` record, with the HEAD reflog's length; PostToolUse compares both and removes it.
# In doubt it answers "moved", so the caller resets, the safe direction: no usable id, no
# record, an unreadable one, or a call sent to the background, whose PostToolUse arrives
# before it has finished.
record_head() { # PreToolUse; best effort. "<HEAD or -> <HEAD reflog length>"
  _f=$(call_record_path "$headpre_prefix") || return 0
  _h=$(git -C "$repo_root" rev-parse -q --verify HEAD 2>/dev/null) || _h=-
  mkdir -p "$state_dir" 2>/dev/null
  { printf '%s %s\n' "$_h" "$(head_reflog_len)" > "$_f"; } 2>/dev/null || true
}
head_moved() { # PostToolUse
  _f=$(call_record_path "$headpre_prefix") || return 0
  [ -f "$_f" ] || return 0
  _was='' _wasn=''; read -r _was _wasn 2>/dev/null < "$_f"
  rm -f "$_f" 2>/dev/null
  [ -n "$_was" ] || return 0
  bash_backgrounded && return 0
  _h=$(git -C "$repo_root" rev-parse -q --verify HEAD 2>/dev/null) || _h=-
  [ "$_h" != "$_was" ] && return 0
  # an unchanged HEAD after a commit undone in the same call (`git commit && git reset
  # --soft HEAD^`) still grew the reflog; without a reflog to compare, in doubt it moved
  case $_wasn in '' | 0 | *[!0-9]*) return 0 ;; esac
  [ "$(head_reflog_len)" != "$_wasn" ]
}
record_wip_base() { # PreToolUse: "<HEAD> <parent or -> <reflog length> <amend|new>"; best effort
  wipbase_file=$(wip_record_path) || return 0
  rm -f "$wipbase_file" 2>/dev/null
  is_wip_message_cmd "$1" || return 0
  _h=$(git -C "$repo_root" rev-parse -q --verify HEAD 2>/dev/null) || return 0
  _p=$(git -C "$repo_root" rev-parse -q --verify HEAD^ 2>/dev/null) || _p=-
  _n=$(head_reflog_len)
  case $_n in '' | 0 | 0* | *[!0-9]* | ??????????*) return 0 ;; esac
  _m=new
  printf '%s ' "$(strip_add_prefix "$1")" | sed "s/'[^']*'//g; s/\"[^\"]*\"//g" | grep -Eiq '[[:space:]]--amend[[:space:]]' && _m=amend
  mkdir -p "$state_dir" 2>/dev/null
  { printf '%s %s %s %s\n' "$_h" "$_p" "$_n" "$_m" > "$wipbase_file"; } 2>/dev/null || true
}
bash_backgrounded() { printf '%s' "$payload" | grep -Eq '"run_in_background"[[:space:]]*:[[:space:]]*true|"backgroundTaskId"'; }
wip_base_holds() { # PostToolUse: is HEAD this command's own result, or unchanged?
  _rh='' _rp='' _rn='' _rm='' _rx=''
  wipbase_file=$(wip_record_path) || return 1
  [ -f "$wipbase_file" ] || return 1
  read -r _rh _rp _rn _rm _rx 2>/dev/null < "$wipbase_file"
  rm -f "$wipbase_file" 2>/dev/null
  [ -n "$_rh" ] && [ -n "$_rp" ] && [ -n "$_rm" ] && [ -z "$_rx" ] || return 1
  # a positive decimal with no leading zero and at most nine digits, so the arithmetic
  # below can neither read it as octal nor overflow
  case $_rn in '' | 0* | *[!0-9]* | ??????????*) return 1 ;; esac
  _h=$(git -C "$repo_root" rev-parse -q --verify HEAD 2>/dev/null) || return 1
  _n=$(head_reflog_len)
  case $_n in '' | 0* | *[!0-9]* | ??????????*) return 1 ;; esac
  if [ "$_h" = "$_rh" ]; then [ "$_n" = "$_rn" ]; return; fi
  [ "$_n" = "$((_rn + 1))" ] || return 1
  _p=$(git -C "$repo_root" rev-parse -q --verify HEAD^ 2>/dev/null) || return 1
  if [ "$_rm" = amend ]; then [ "$_p" = "$_rp" ]; else [ "$_p" = "$_rh" ]; fi
}
is_wip_commit_pre() {
  is_wip_message_cmd "$1" && ! msg_may_be_rewritten && return 0
  is_wip_amend_cmd "$1"
}
is_wip_commit_post() {
  is_wip_message_cmd "$1" && ! bash_backgrounded && head_is_wip && wip_base_holds && return 0
  is_wip_amend_cmd "$1"
}

# A commit that stages all tracked changes (-a / -am / --all) also sweeps in
# tracked-but-unstaged edits that `git diff --cached` alone won't show, so the
# docs-only check below must consult the unstaged set too. (`--amend` is two
# dashes and never matches, so it isn't mistaken for -a.)
has_all_flag() { printf '%s' "$1" | grep -Eq '(^|[[:space:]])(-[a-z]*a[a-z]*|--all)([[:space:]]|$)'; }

# The staged list is read before the command runs, so a command that stages (`git add
# x && git commit`) or names paths (`git commit -m x a.ts`) is judged on paths it does
# not show. Docs-only is therefore offered only to a command that is exactly `git commit`
# plus the options below, each quoted text counted as one word; any other word (a path,
# an attached value like `-mx`, `--pathspec-from-file`, `&&`, a prefix) fires. So does any
# `\`, `$` or backtick (escapes and substitutions), any
# quote left after one left-to-right pass, which is how the shell pairs them, and any
# unquoted operator or glob character, since `-am docs>app.ts` or `-m *` hides a path.
names_no_paths() {
  case "$1" in *[\\\$\`]*) return 1 ;; esac
  _r=$(printf '%s' "$1" | tr '\n' ' ' | sed -E "s/'[^']*'|\"[^\"]*\"/Q/g")
  case "$_r" in *[\'\"\<\>\|\&\;\*\?\[\{\}\(\)]*) return 1 ;; esac
  _r=${_r#"${_r%%[![:space:]]*}"}
  case "$_r" in 'git commit' | 'git commit '*) _r=${_r#git commit} ;; *) return 1 ;; esac
  _v=
  set -f
  for _w in $_r; do
    if [ -n "$_v" ]; then _v=; continue; fi
    case "$_w" in
      -m | -am | -F | --message | --file) _v=1 ;;
      -a | -q | -s | -n | -v | --all | --amend | --no-edit | --no-verify | --quiet | --signoff | --allow-empty) ;;
      *) set +f; return 1 ;;
    esac
  done
  set +f
  [ -z "$_v" ]
}

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

# True ONLY when the file list is non-empty AND every path is a doc artifact (the
# rules' docs-only list: Markdown under docs/, README.md, MANIFEST.md, todos.md, plus
# .context/) AND none of them is a prompt. Restricted to the .md extension on purpose:
# a non-Markdown file under docs/ (e.g. a script) IS code and must still hit Gate B,
# so we do NOT exempt the docs/ directory wholesale. An empty/undeterminable list returns false, so the caller falls
# through to the loose Gate-B default (fire) — keeping "missed code commit" the
# safe direction.
is_docs_only() {
  [ -n "$1" ] || return 1
  printf '%s\n' "$1" | grep -vE '^docs/.*\.md$|^(README|MANIFEST|todos)\.md$|^\.context/' | grep -q . && return 1
  is_prompt_path "$1" && return 1
  return 0
}

# --- COMPACTION RE-INJECTION ------------------------------------------------------
# hooks.json registers SessionStart with the matcher `compact` only, and this checks
# `source` as well, so a wider registration cannot announce a compaction that did not
# happen. Claude Code adds a SessionStart hook's PLAIN stdout to the model's context
# (https://code.claude.com/docs/en/hooks, exit code 0), so this prints text rather than
# the JSON document the tool events use, and `routed` stays 0 so no buffered note is
# flushed after it. The opt-out marker silences it like every other output. At most
# three lines, each segment from state that exists. No gate state is written; the
# fingerprint recomputation uses tree_hash, which stages into a throwaway index and so
# leaves blobs and trees in the object database exactly as every commit check does — the
# effective index and the worktree are untouched. Line 1 names the rules file
# /workflow-init scaffolds.
compact_count() { # $1 = label, $2 = count file, $3 = floor, $4 = cap. Sets `unknown` or `atcap`; `?` where the
                  # file exists but no number can be read (an unreadable count may hide a
                  # pending stop, so the open stop then reads `unknown`, never `none`).
  # Present-but-not-regular (a FIFO, a directory) is unknown and never read: `cat` on a
  # FIFO blocks until a writer appears.
  { [ -e "$2" ] || [ -L "$2" ]; } || return 0
  c=''; [ -f "$2" ] && c=$(cat "$2" 2>/dev/null | tr -d '[:space:]')
  case "$c" in
    '' | *[!0-9]*) c='?'; unknown=1 ;;
    ???????????????????*) atcap=1 ;;      # nineteen digits or more: past any cap, as in cap_check
    *) [ "$c" -ge "$4" ] && atcap=1 ;;
  esac
  seg="${seg:+$seg · }$1 passes $c/$3"
}
compact_lines() {
  [ -f "$off_file" ] && return 0
  case "$(field source)" in compact | '') ;; *) return 0 ;; esac
  printf '%s\n' 'dev-workflow: context was compacted. Binding rules file: .claude/review-gates.md (read it before gate work).'
  seg=''; unknown=0; atcap=0
  # The nonce comes from the newest USABLE findings slot, `gate-<kind>-<nonce>-pass-<p>.md`:
  # a regular file whose token between the kind and `-pass-` is 8 to 16 of [a-z0-9]. A
  # legacy bare slot (`gate-b-spec-pass-1.md`) yields its branch name there, which the
  # length bound rejects, and a directory in the namespace is listed as itself (`-d`) and
  # skipped; neither hides an older slot that qualifies. Newest by mtime (`-t`), which is
  # why this is `ls` and not a glob: POSIX `test` has no `-nt`. Listed from INSIDE the
  # directory so only basenames are split: the checkout path may contain spaces, a usable
  # slot name cannot, and a name that does split yields pieces the `-f` test rejects.
  # The archive counts too (0.46): a close interrupted after its files moved there but before
  # its commit landed is still the open cycle. Paths are listed relative to .context/, so the
  # checkout path is never split; a name with a space splits into pieces the `-f` test rejects.
  # shellcheck disable=SC2012,SC2045  # relative paths only; see above
  for f in $(cd "$state_dir" 2>/dev/null && ls -td codex-reviews/gate-*-pass-*.md archive/codex-reviews/*/gate-*-pass-*.md 2>/dev/null); do
    [ -f "$state_dir/$f" ] || continue
    n=${f%-pass-*}; n=${n##*-}
    case "$n" in
      *[!a-z0-9]* | ?????????????????*) continue ;;
      ????????*) seg="nonce $n"; break ;;
    esac
  done
  compact_count 'Gate A' "$countA_file" "$floorA" "$capA"
  compact_count 'Gate B' "$count_file" "$floorB" "$capB"
  if [ -e "$state_file" ] || [ -L "$state_file" ]; then
    # Read exactly as the commit check reads it, so the two can never disagree about the
    # same bytes; `unavailable` on either side is never fresh. Not read at all when it is
    # not a regular file, for the FIFO reason above.
    reviewed=''; [ -f "$state_file" ] && reviewed=$(cat "$state_file" 2>/dev/null || echo '')
    # A read-only state file is refused here as at the commit check (S5).
    if [ -z "$reviewed" ] || [ "$reviewed" = unavailable ] || [ ! -w "$state_file" ]; then fp=unavailable
    else
      fingerprint; current=$fp
      if [ "$current" = unavailable ]; then fp=unavailable
      elif [ "$current" = "$reviewed" ]; then fp=fresh
      else fp=stale
      fi
    fi
    seg="${seg:+$seg · }fingerprint $fp"
  fi
  [ -n "$seg" ] || return 0
  printf 'Gate cycle: %s\n' "$seg"
  if [ "$atcap" -eq 1 ]; then stop='pass cap reached — answer pending'
  elif [ "$unknown" -eq 1 ]; then stop='unknown (unreadable pass count)'
  else stop=none
  fi
  printf 'Open stop: %s\n' "$stop"
}

# `routed` gates the flush below. Spec §3.3: a payload the hook cannot ROUTE produces no
# output and touches no state — but `flush_notes` used to run unconditionally, so a pending
# disclosure was emitted (and cleared) on an event no branch here recognized. That is also
# how an untrusted event name reached the fallback emitter.
routed=0
case "$event" in
  SessionStart) compact_lines ;;
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
            review_call "$cls"
            ;;
        esac
        cap_check B "$count_file"
        ;;
      "$exec_tool")
        cls=$(classify)
        case "$cls" in
          failure | no-result | backgrounded) note_discarded "$cls" ;;
          # A resumed session is no pass of its own (canvas 2026-10-21: re-fetching a truncated
          # reply counted). Undercounting a pass resumed by mistake fires more, invariant 2's side.
          # Target model: Claude via Claude Code.
          *) if exec_resumed; then
            note "Claude via Claude Code — gate hook. <state>This $exec_tool call carries a sessionId in its input, so it resumes a Codex session and is not counted as a Gate A pass.</state> <next>A call that fetches the rest of a truncated reply belongs to the pass it completes. If this call was a pass of its own, run it again without sessionId, because a pass reviews the artifact as it stands, not as an earlier session saw it.</next>" "ℹ Codex Gate A: resumed session not counted as a pass"
          elif why=$(exec_findings) && [ -n "$why" ]; then
            case "$why" in
              'names no findings file') what='its instruction names no findings file (a line Findings file: <path>)' ;;
              'names two findings files') what='its instruction names two different findings files' ;;
              'findings file elsewhere') what="the findings file it names is outside this checkout's .context/codex-reviews/" ;;
              'findings file missing') what='the findings file it names is missing, or is a symbolic link' ;;
              'findings file incomplete') what='the findings file it names is incomplete: its terminator, its count or a severity prefix is wrong' ;;
              *) what='the findings file it names could not be checked (awk failed)' ;;
            esac
            note "Claude via Claude Code — gate hook. <state>This $exec_tool call was not counted as a Gate A pass: $what.</state> <consequence>It counts toward neither the floor nor the cap.</consequence> <next>A call that leaves no complete labelled findings file is an incomplete pass that counts for nothing; a cut-off reply alone does not invalidate a complete file. Repair the cause first, then re-run the pass with Codex writing the labelled file, deleting a partial file before; one retry per pass is the budget. Causes, checks and fixes: https://github.com/dsnger/dev-workflow-kit/blob/main/docs/reference.md#hook-messages. The check reads the file's structure only (terminator, count, severity prefixes), not which run wrote it.</next> <stop>Said on every such call.</stop>" "ℹ Codex Gate A: not counted — $why"
          else
            [ "$cls" = unrecognized ] && note_unverified
            mkdir -p "$state_dir" 2>/dev/null
            remember_mode "$countA_file" "$modeA_file"
            bump_count "$countA_file"
          fi ;;
        esac
        cap_check A "$countA_file"
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
        # RESET on commit closes the Gate-B cycle, and moves the live Gate-A count aside
        # to `.closed`, which only the plan-execution floor check reads, so a stale count
        # never reaches a later cap check. A WIP commit does NOT close it
        # (see is_wip_commit_post).
        #
        # The Bash tool_response is documented as {stdout, stderr, interrupted, isImage}
        # (https://code.claude.com/docs/en/hooks.md): no exit status. So the hook judges
        # the effect, not the text: a call that left HEAD and the HEAD reflog unchanged
        # made no commit here (a failed commit, a heredoc or printf naming `git commit`)
        # and keeps the counters (0.37.3; before, the spelling alone reset). In doubt
        # head_moved answers "moved" and the cycle resets, the safe direction.
        # shortcut: a commit sent off with a shell `&` that lands after the call returns
        # leaves HEAD unchanged at PostToolUse and keeps the counters; no field case yet.
        if is_commit "$cmd" && head_moved && ! is_wip_commit_post "$cmd"; then
          rm -f "$state_file" "$count_file" "$fresh_file" "$pending_file" "$capextra_file" "$modeB_file"
          retire_legacy quiet
          # The closing act's commit precedes plan execution, which still reads the closed
          # count for its floor check; the cap check reads only the live one
          [ -f "$countA_file" ] && mv -f "$countA_file" "$countA_file.closed" 2>/dev/null
        fi
        # This call's `-m wip` record belongs to this one command, whatever the decision above was
        if is_commit "$cmd" && wipbase_file=$(wip_record_path); then rm -f "$wipbase_file" 2>/dev/null; fi
        ;;
      Skill)
        case "$(input_field skill)" in
          # Reset the Gate-A pass count at both ends of a spec cycle: plan execution
          # CLOSES one, and brainstorming / writing-plans OPENS the next — so a new
          # spec zeroes any stale count abandoned by a previous (un-executed) one. Not
          # `intake` or `ticket`: their change-record, `list` and `T-<n>` forms run inside
          # an open cycle, where a reset would hide a pending cap stop.
          superpowers:executing-plans | superpowers:subagent-driven-development \
            | superpowers:brainstorming) rm -f "$countA_file" "$countA_file.closed" "$countA_file.spec" "$modeA_file" ;;
          # writing-plans opens the plan's Gate-A cycle and sets the earlier one's count
          # aside, so plan execution can tell "no Gate A on this plan" from "below floor"
          superpowers:writing-plans)
            rm -f "$countA_file.spec"
            if [ -f "$countA_file" ]; then mv -f "$countA_file" "$countA_file.spec" 2>/dev/null
            elif [ -f "$countA_file.closed" ]; then mv -f "$countA_file.closed" "$countA_file.spec" 2>/dev/null; fi
            rm -f "$countA_file" "$countA_file.closed" "$modeA_file" ;;
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
          record_head
          record_wip_base "$cmd"
          if is_wip_commit_pre "$cmd"; then
            note "WIP commit — cycle-internal, per $policy: this exists so mcp__codex__review has a non-empty range to read (baseSha = this commit's parent). Gate B's fingerprint and floor are not evaluated here. Whether your pass counters are kept is decided after the commit, under the conditions $policy states for a WIP commit; where those do not hold they are cleared. Use this commit as the review range; whether this cycle runs a review now, and when its closing act may be performed, are both $policy's closure ordering's, read there in full." "ℹ WIP commit (Codex cycle decided after the commit)"
          else
          # Docs-only commits (spec/plan .md files) carry no code diff,
          # so Gate B (mcp__codex__review reviews a code diff) cannot apply — emit a
          # gentle note instead of the STOP/floor reminders. Only when the file list
          # is POSITIVELY confirmed docs-only; an empty list falls through to fire.
          files=$(git -C "$repo_root" diff --cached --name-only 2>/dev/null)
          has_all_flag "$cmd" && files=$(printf '%s\n%s\n' "$files" "$(git -C "$repo_root" diff --name-only 2>/dev/null)")
          files=$(printf '%s\n' "$files" | sed '/^$/d')
          if names_no_paths "$cmd" && is_docs_only "$files"; then
            note "Docs-only commit — no code is staged, so Codex Gate B's fingerprint and floor checks do not apply here (mcp__codex__review reviews a code diff). If this commit includes a spec or plan, confirm it went through Gate A (mcp__codex__exec) where $policy requires one; the gate mode decides which specs do." "ℹ Codex Gate B N/A (docs-only commit)"
          else
            retire_legacy quiet   # best effort; nothing is credited here
            passes=$(read_count "$count_file")
            fresh=$(read_count "$fresh_file")
            reviewed=$(cat "$state_file" 2>/dev/null || echo '')
            fingerprint; current=$fp
            [ -n "$fp_note" ] && note "$fp_note" "$fp_note"
            if [ -z "$reviewed" ]; then
              # No count ratio here on purpose: no fingerprint is recorded for this
              # cycle, so showing "N/3" would read as floor progress. `-z "$reviewed"`
              # does not mean only "no pass this cycle": a FIRST write that fails (no
              # prior fingerprint to fall back to), or a state file that cannot be read
              # back, leaves it empty too, and so does a failed REPLACEMENT write, which
              # removes the older fingerprint (S5). Where even that removal fails, the
              # file is read-only and the branch below refuses it as unconfirmable.
              # The message names the absent FINGERPRINT,
              # not an absent review.
              note "Codex gate state: no fingerprint is recorded for this cycle. The hook cannot tell why; causes: https://github.com/dsnger/dev-workflow-kit/blob/main/docs/reference.md#hook-messages. The fingerprint is Gate B's (mcp__codex__review) alone; Gate A (mcp__codex__exec) passes are counted per call that left its labelled findings file complete, and never record one. What this cycle does next, the floor it owes included, is $policy's closure ordering's, read there entire, and this reminder decides none of it. If this repeats, check that .context/ and the state file inside it are readable and writable; if the file exists but is unreadable or empty, delete it — which restores no passes, and lets the next Gate B pass the ordering permits record a fingerprint." "⚠ Codex Gate B: no recorded fingerprint"
            # `unavailable` on EITHER side is never a match: an uncomputable fingerprint
            # must read as unverified, and two of them must not cancel out.
            # A read-only state file cannot have taken the last pass's write, so what it
            # holds may be an older pass's fingerprint: never confirmed (S5).
            elif [ "$current" = unavailable ] || [ "$reviewed" = unavailable ] ||
                 [ "$reviewed" != "$current" ] || [ ! -w "$state_file" ]; then
              # Content check, not event check: this fires for a change made through ANY
              # tool — Edit/Write, or a Bash `sed -i` / `eslint --fix` / `git apply`.
              # It names the STATE, never a cause: five states reach here and the hook
              # cannot tell them apart (spec §4). Do not "improve" this into asserting
              # that the tree changed — under a repeated computation failure nothing
              # changed, and under a failed state write the content may be exactly what
              # was reviewed.
              note "Codex gate state: the hook cannot confirm that the content you are about to commit is the content mcp__codex__review last saw ($passes recorded pass(es) this cycle). Usually the working tree or the index changed since the review. Next: a fresh Gate-B pass, and when this cycle may run one is $policy's closure ordering's, read there entire. If a fresh pass leaves this unchanged, other causes and checks: https://github.com/dsnger/dev-workflow-kit/blob/main/docs/reference.md#hook-messages. Per $policy you MUST re-review after every fix." "⚠ Codex Gate B: cannot confirm reviewed content"
            elif [ "$passes" -lt "$floorB" ]; then
              # Target model: Claude via Claude Code. lean/strict: no early-close advice (spec 0.46 §3).
              if [ "$cmB" != classic ]; then
                note "Codex Gate B below floor: $passes/$floorB mcp__codex__review pass(es) since the last commit. The hook reads no findings or size. Follow $policy's closure ordering. Numbers from $mtB." "⚠ Codex Gate B below floor ($passes/$floorB) · $mtB"
              else
              note "Codex Gate B below floor: $passes/$floorB mcp__codex__review pass(es) since the last commit. The hook reads no findings or size. A zero-finding pass may close early; a small change's pass with no Blocker/Major closes. Else: $policy's closure ordering. Numbers from $mtB." "⚠ Codex Gate B below floor ($passes/$floorB): may close after a zero-finding pass, or a small change's pass with no Blocker or Major · $mtB"
              fi
            else
              # Distinguish the two counts (Finding 9): the cycle total includes passes
              # made BEFORE later edits, so they carry a different fingerprint.
              # FINGERPRINT EQUALITY IS ALL THIS PROVES. The hook compares a hash of
              # disk; mcp__codex__review reads a git range — so a match does NOT
              # establish that Codex read these bytes (spec §7, and the review-range row
              # in todos.md). The stronger phrasing was here and was removed; do not
              # restore it as a clarity improvement.
              # Target model: Claude via Claude Code.
              note "Codex Gate B: $passes/$floorB pass(es) this cycle, of which $fresh cover the CURRENT content fingerprint (unchanged since that review). The floor counts the cycle; only the fresh pass(es) carry the same fingerprint as what you are committing. Per $policy, commit only if your final pass was clean and every other closure condition holds, both as it defines them. Numbers from $mtB." "✓ Codex Gate B hook checks passed ($passes/$floorB cycle, $fresh on current fingerprint) · $mtB"
            fi
            # A half pass is never part of the count above; say so beside whichever
            # message that chain printed (spec 2026-10-09 §3.4). Existence is the test.
            gone "$pending_file" || note "$PENDING_AT_COMMIT_CTX" "$PENDING_AT_COMMIT_MSG"
          fi
          # Target model: Claude via Claude Code. The count is said here because a commit that
          # lands removes its file, so read afterwards it is gone (T-9, 2026-10-23).
          if [ -e "$count_file" ] || [ -L "$count_file" ]; then
            # read_count reads a malformed file as 0; this note reports it as unknown instead
            _n=''; [ -f "$count_file" ] && _n=$(cat "$count_file" 2>/dev/null)
            case $_n in '' | *[!0-9]*) _n='unknown (the count file cannot be read)' ;; *) _n=$(read_count "$count_file") ;; esac
            note "Gate-B hook count before this commit: $_n credited pass(es). A commit that lands and is not kept as WIP clears it, so take the count for any comparison with your cycle line from this message: afterwards it may be gone." "ℹ Gate-B hook count before this commit: $_n (a commit that lands may clear it)"
          fi
          # Target model: Claude via Claude Code. The causes are in docs/reference.md § Hook messages.
          # runs_git_commit: only where `git commit` stands as a command of its own; the
          # sentence states head_moved's rule, so it holds whether or not the commit succeeds.
          if looks_wip_cmd "$cmd" && ! is_wip_message_cmd "$cmd" && runs_git_commit "$cmd"; then
            note "This call is not counted as a WIP commit, so the pass counters are cleared after it unless the hook sees HEAD and its reflog unchanged. If they are cleared, the hook count is from then on lower than your cycle passes; when you compare the two, name this call as the cause. A WIP commit is one git commit -m 'WIP: <subject>' Bash call with a plain subject, run from the repository, and nothing else in the call but one leading git add <paths> &&: a command chained before or after it (x && git commit ..., git commit ...; y), a second line, cd, git -C or a heredoc is not, so stage in the call before. Causes: https://github.com/dsnger/dev-workflow-kit/blob/main/docs/reference.md#hook-messages." "ℹ Not counted as a WIP commit: pass counters cleared if HEAD moves"
          fi
          fi
          # Every commit attempt, WIP and docs-only included, and both gates: a cap
          # reached is a stop wherever a further pass would otherwise run, a Gate-A cycle
          # reaches its closing commit this way too, and firing on a commit that needed no
          # Gate B is the redundant reminder invariant 2 accepts. The WIP note and the
          # docs-only note above say Gate B's fingerprint and floor are not evaluated on
          # their paths; the cap still is.
          cap_check A "$countA_file"
          cap_check B "$count_file"
        fi
        ;;
      Skill)
        case "$(input_field skill)" in
          superpowers:executing-plans | superpowers:subagent-driven-development)
            passesA=$(read_count "$countA_file")
            [ -f "$countA_file" ] || passesA=$(read_count "$countA_file.closed")
            # No exec call since writing-plans: a standard-risk plan needs none (section 5),
            # so the floor is not reported as missed; the reminder still fires, naming both cases.
            if [ ! -f "$countA_file" ] && [ ! -f "$countA_file.closed" ] && [ -f "$countA_file.spec" ]; then
              passesS=$(read_count "$countA_file.spec")
              # Target model: Claude via Claude Code.
              note "Codex Gate A: no mcp__codex__exec pass since writing-plans, so this plan has had no Gate A. Per $policy a plan needs Gate A only when its recorded risk is high: for a standard-risk plan this is expected; for a high-risk plan its Gate A floor is NOT met (0/$floorA). The Gate-A cycle before writing-plans, normally the spec's, recorded $passesS/$floorA pass(es), counted as calls that left a complete findings file, with no check of what was reviewed. Numbers from $mtA." "⚠ Codex Gate A: none on this plan (needed at risk high; before it $passesS/$floorA) · $mtA"
            elif [ "$passesA" -lt "$floorA" ]; then
              # Target model: Claude via Claude Code. lean/strict: Gate A is two passes (spec 0.46 §3).
              if [ "$cmA" != classic ]; then
                note "Codex Gate A below floor: $passesA/$floorA mcp__codex__exec pass(es) on this spec/plan, each a complete findings file the hook does not weigh: in this mode a Gate A that runs is exactly two passes, full then verify; a spec below the threshold needs none (see the threshold note). Otherwise follow $policy's closure ordering. Numbers from $mtA." "⚠ Codex Gate A below floor ($passesA/$floorA): two passes when Gate A runs · $mtA"
              else
              note "Codex Gate A below floor: $passesA/$floorA mcp__codex__exec pass(es) on this spec/plan, each a complete findings file the hook does not weigh: a zero-finding last pass may close early; otherwise follow $policy's closure ordering, normally another pass. Numbers from $mtA." "⚠ Codex Gate A below floor ($passesA/$floorA): a zero-finding last pass may close early · $mtA"
              fi
            else
              # Deliberately weaker wording than Gate B (Finding 12): countA counts
              # mcp__codex__exec calls that left a complete findings file, bound to no artifact. Hashing the artifact would
              # be wrong — a spec is SUPPOSED to change between passes — so the hook
              # cannot verify what was reviewed, and must not imply that it did.
              # Target model: Claude via Claude Code.
              note "Codex Gate A: $passesA/$floorA mcp__codex__exec pass(es) — floor met by COUNT ONLY; the hook cannot verify what was reviewed or that findings were addressed. Proceed only once this cycle has closed under $policy's closure ordering. Numbers from $mtA." "✓ Codex Gate A floor met ($passesA/$floorA passes, count only) · $mtA"
            fi
            # Target model: Claude via Claude Code. The spec threshold of the mode in force, so a
            # standard spec that skipped Gate A under lean or strict reads as expected (spec 0.46 §2).
            case "$mode" in
              lean | strict) note "Codex Gate A threshold, mode $mode (.claude/codex-gate.mode): a spec needs Gate A only at risk high or security not none, and a plan only at risk high, so a spec at risk standard with security none, or a plan below risk high, is expected to have none." "ℹ Codex Gate A, mode $mode: a spec needs it only at risk high or security not none; a plan only at risk high" ;;
              *) note "Codex Gate A threshold, mode classic: every spec needs Gate A, and a plan only at risk high." "ℹ Codex Gate A, mode classic: every spec needs it; a plan only at risk high" ;;
            esac
            cap_check A "$countA_file"
            ;;
        esac
        ;;
    esac
    ;;
esac

# Unroutable payload: no output, no state, debt preserved for a later routable event.
[ "$routed" -eq 1 ] && flush_notes
exit 0
