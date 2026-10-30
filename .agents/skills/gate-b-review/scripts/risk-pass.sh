#!/bin/sh
# risk-pass.sh — runs Gate B's one high-effort risk pass through `codex exec` (dev-workflow kit 0.51,
# spec docs/superpowers/specs/2026-10-30-kit-051-codex-review-design.md §6). The main session runs it
# as a background Bash call and waits for its exit; the hook does not see it.
#
# Usage: risk-pass.sh <repo> <baseSha> <headSha> <nonce> <n> [<seconds>]
#   <baseSha>  the cycle base: must equal the `base` line of
#              <repo>/.context/codex-reviews/gate-b-cycle-<nonce>.state, which the main session
#              writes before Gate B pass 1
#   <headSha>  the head under review; both SHAs 40 lowercase hex
#   <nonce>    the cycle nonce, 8-16 of [a-z0-9]; <n> the pass number, a positive integer
#   <seconds>  time limit, 1-7200; empty or absent means 2400
# Exit: 0 a valid result promoted to the canonical findings file; 1 Codex failed or its findings
# file is invalid (one retry, as for any failed pass); 2 bad arguments; 3 timeout; 4 the slot is
# busy (a live earlier attempt); 5 no process supervisor (perl); 6 a Codex CLI other than the pin.
#
# Files, all under <repo>/.context/codex-reviews/: per attempt <a>,
# gate-b-risk-<nonce>-pass-<n>-attempt-<a>.md (findings, written by Codex), …-attempt-<a>-evidence.md,
# …-attempt-<a>-reply.md (Codex's last message) and …-attempt-<a>.events.jsonl (its --json log, kept in a temporary
# directory while Codex runs, since run-tests.sh fingerprints this directory, and placed here after it ends). Only
# while holding the slot lock (gate-b-risk-<nonce>-pass-<n>.lock) is a valid attempt copied to the
# canonical gate-b-risk-<nonce>-pass-<n>.md, and the state file gains
# `risk <n> done <a> <headSha> <sha256>`; otherwise `risk <n> failed <a> <exit>`. A late writer from an
# earlier attempt can therefore write only its own attempt file. The closing act accepts the canonical
# file only when its sha256 matches the slot's last `done` line (spec §6).
set -u
CODEX_PIN='codex-cli 0.162.1'

die() { printf 'risk-pass.sh: %s\n' "$1" >&2; exit "${2:-2}"; }
usage() { die "$1 (usage: risk-pass.sh <repo> <baseSha> <headSha> <nonce> <n> [<seconds>])" 2; }
# Explicit character lists: in a bash locale a range such as a-z also matches capitals.
is_sha() { case $1 in *[!0123456789abcdef]*|'') return 1 ;; esac; [ ${#1} -eq 40 ]; }

[ $# -ge 5 ] && [ $# -le 6 ] || usage 'wrong number of arguments'
repo=$1; base=$2; head=$3; nonce=$4; n=$5; secs=${6-}
is_sha "$base" || usage 'baseSha must be 40 lowercase hex'
is_sha "$head" || usage 'headSha must be 40 lowercase hex'
case $nonce in *[!abcdefghijklmnopqrstuvwxyz0123456789]*|'') usage 'nonce must be 8-16 of [a-z0-9]' ;; esac
[ ${#nonce} -ge 8 ] && [ ${#nonce} -le 16 ] || usage 'nonce must be 8-16 of [a-z0-9]'
case $n in *[!0-9]*|''|0*) usage 'n must be a positive integer' ;; esac
[ ${#n} -le 3 ] || usage 'n must be a positive integer below 1000'
[ -n "$secs" ] || secs=2400
case $secs in *[!0-9]*) usage 'seconds must be an integer 1-7200' ;; esac
[ ${#secs} -le 4 ] && [ "$secs" -ge 1 ] && [ "$secs" -le 7200 ] || usage 'seconds must be an integer 1-7200'
repo=$(git -C "$repo" rev-parse --show-toplevel 2>/dev/null) && [ -n "$repo" ] || usage 'repo is not a git work tree'
git -C "$repo" cat-file -e "$base^{commit}" 2>/dev/null || usage "baseSha $base is not a commit in $repo"
git -C "$repo" cat-file -e "$head^{commit}" 2>/dev/null || usage "headSha $head is not a commit in $repo"
dir="$repo/.context/codex-reviews"
state="$dir/gate-b-cycle-$nonce.state"
# Codex can write in the repository, and this script runs with the user's full rights: it never
# writes through a symlink, so a planted link cannot redirect a write outside the workspace.
for x in "$repo/.context" "$dir" "$state"; do [ -L "$x" ] && usage "$x is a symlink; refusing to write through it"; done
[ -f "$state" ] || usage "no cycle base: $state is missing (the main session writes it before pass 1)"
recorded=$(sed -n 's/^base \([0-9a-f]\{40\}\)$/\1/p' "$state" | head -n 1)
[ "$recorded" = "$base" ] || usage "baseSha differs from the cycle base recorded in $state"
command -v perl >/dev/null 2>&1 || die 'no process supervisor: perl not found, nothing run' 5
v=$(codex --version 2>/dev/null | head -n 1)
[ "$v" = "$CODEX_PIN" ] || die "Codex CLI is '${v:-not found}', this script is verified on '$CODEX_PIN' only; installing that version is the user's step (see /workflow-init)" 6

# EPERM means the process exists (see run-tests.sh).
group_alive() { perl -e 'exit((kill(0, -$ARGV[0]) || $!{EPERM}) ? 0 : 1)' "$1" 2>/dev/null; }
group_signal() { perl -e 'kill $ARGV[0], -$ARGV[1]' "$1" "$2" 2>/dev/null; }
pid_alive() { perl -e 'exit((kill(0, $ARGV[0]) || $!{EPERM}) ? 0 : 1)' "$1" 2>/dev/null; }
group_stop() {
  group_alive "$1" || return 0
  group_signal TERM "$1"; i=0
  while group_alive "$1" && [ $i -lt 50 ]; do sleep 0.1; i=$((i + 1)); done
  group_signal KILL "$1"
  while group_alive "$1"; do sleep 0.1; done
}
num() { case $1 in ''|*[!0-9]*) return 1 ;; esac; }

# The slot lock. A held lock whose runner or group is alive: busy. Both gone: an interrupted
# attempt, taken over (its state line stays `start` without `done`).
lock="$dir/gate-b-risk-$nonce-pass-$n.lock"
if ! mkdir "$lock" 2>/dev/null; then
  rp=$(cat "$lock/runner.pid" 2>/dev/null) || rp=
  gp=$(cat "$lock/group.pid" 2>/dev/null) || gp=
  if { num "$rp" && pid_alive "$rp"; } || { num "$gp" && group_alive "$gp"; }; then
    die "slot busy: $lock is held by a live attempt" 4
  fi
  [ -n "$rp" ] || die "slot busy: $lock has no runner record (an attempt may be starting)" 4
  rm -rf "$lock"
  mkdir "$lock" 2>/dev/null || die "slot busy: could not take over $lock" 4
fi
printf '%s\n' "$$" > "$lock/runner.pid"
cpid=; wpid=; work=
# shellcheck disable=SC2329  # run by the EXIT trap
cleanup() {
  [ -n "$wpid" ] && group_stop "$wpid"
  [ -n "$cpid" ] && group_stop "$cpid"
  [ -n "$work" ] && rm -rf "$work"
  rm -rf "$lock"
  cpid=; wpid=; work=
}
trap cleanup EXIT
trap 'exit 129' HUP; trap 'exit 130' INT; trap 'exit 143' TERM

a=$(( $(grep -c "^risk $n start " "$state") + 1 ))
pre="$dir/gate-b-risk-$nonce-pass-$n-attempt-$a"
findings_rel=".context/codex-reviews/gate-b-risk-$nonce-pass-$n-attempt-$a.md"
canon="$dir/gate-b-risk-$nonce-pass-$n.md"
for x in "$pre.md" "$pre-evidence.md" "$pre-reply.md" "$pre.events.jsonl"; do
  { [ -e "$x" ] || [ -L "$x" ]; } && die "attempt file $x already exists; refusing to reuse it" 1
done
# Every write goes through these two, because the reviewer may have replaced a directory or file
# with a symlink, a hard link or a FIFO while it ran: the directories are checked again before each
# write, a file is appended to only when it opens without following a link and is a regular file
# with one link, and a result is renamed into place (rename never follows or enters the target).
# shortcut: a process that escaped the killed group could still race these checks; the group kill
# is the main bound.
dirs_ok() { [ ! -L "$repo/.context" ] && [ ! -L "$dir" ] && [ -d "$dir" ]; }
# shellcheck disable=SC2016  # perl source
append() {
  dirs_ok && perl -e 'use Fcntl; sysopen(my $f, $ARGV[0], O_WRONLY | O_APPEND | O_NOFOLLOW) or exit 1;
    my @s = stat $f; exit 1 unless -f _ && $s[3] == 1; print $f $ARGV[1] or exit 1; close $f or exit 1' "$1" "$2"
}
# shellcheck disable=SC2016  # perl source
place() {
  dirs_ok || return 1
  t=$(mktemp "$dir/.risk-pass.XXXXXX") || return 1
  if cp "$1" "$t" && perl -e 'rename($ARGV[0], $ARGV[1]) or exit 1' "$t" "$2"; then return 0; fi
  rm -f "$t"; return 1
}
regular() { [ -f "$1" ] && [ ! -L "$1" ]; }
append "$state" "$(printf 'risk %s start %s %s %s' "$n" "$a" "$head" "$(date +%s)")
" || die "could not record the start in $state (not a regular file with one link?)" 1
finish() {
  append "$state" "$(printf 'risk %s failed %s %s' "$n" "$a" "$1")
" || printf 'risk-pass.sh: could not record the failure in %s\n' "$state" >&2
  [ -n "${2-}" ] && printf 'risk-pass.sh: %s\n' "$2" >&2; exit "$1"
}

work=$(mktemp -d "${TMPDIR:-/tmp}/gate-b-risk.XXXXXX") || finish 1 'could not create a temporary directory'
cat > "$work/prompt" <<EOF
You are the risk pass of Gate B, cycle $nonce, pass $n, attempt $a. Follow the skill at
.agents/skills/gate-b-review/SKILL.md, branch \`risk\`: only edge cases and failure paths of the change, deeper
than an ordinary pass — empty, error, concurrent, interrupted and boundary inputs; what happens when each
external call, file or process fails; which existing statements the change makes false. Review the range
$base..$head of this repository (read it with git; the working tree may differ). Check against AGENTS.md.
Report every finding with severity and confidence; write NO FINDINGS only when you found none.
Findings file: $findings_rel
Write the findings file yourself, in exactly this format:
One finding per line: \`SEVERITY | confidence | location | problem | consequence | suggested fix\`; escape a literal pipe as \`\\|\`.
Severity is one of exactly: BLOCKER | MAJOR | MINOR | NIT.
Every line before the terminator is one finding line — no blank lines, headings, prose or wrapped continuations.
The last line reads exactly \`END OF FINDINGS (<n> total)\`, \`<n>\` the number of finding lines.
A clean findings file is the single body line \`NO FINDINGS\` with \`END OF FINDINGS (0 total)\`.
Write nothing else in the repository except that file and $(basename "$pre")-evidence.md beside it (its TESTS:
and CALLERS: lines, as the skill says). Reply with one line: the counts per severity.
EOF

# shellcheck disable=SC2016  # perl source: $ARGV and $! are perl's, not the shell's
( cd "$repo" && exec perl -e 'setpgrp(0,0) or die "setpgrp: $!\n"; exec { $ARGV[0] } @ARGV or die "exec $ARGV[0]: $!\n"' -- \
    codex exec --json -s workspace-write -c 'model_reasoning_effort="high"' -C "$repo" -o "$pre-reply.md" - ) \
  < "$work/prompt" > "$work/events" 2> "$work/stderr" &
cpid=$!
printf '%s\n' "$cpid" > "$lock/group.pid"
perl -e 'setpgrp(0,0); sleep $ARGV[0]; open(my $f, ">", $ARGV[2]); close $f;
         kill "TERM", -$ARGV[1]; sleep 5; kill "KILL", -$ARGV[1];' "$secs" "$cpid" "$work/timed-out" \
  </dev/null >/dev/null 2>&1 &
wpid=$!
wait "$cpid"; rc=$?
group_stop "$wpid"; wpid=
group_stop "$cpid"; cpid=

place "$work/events" "$pre.events.jsonl" || printf 'risk-pass.sh: could not place the event log at %s\n' "$pre.events.jsonl" >&2
model=$(sed -n 's/.*"model":"\([^"]*\)".*/\1/p' "$work/events" | head -n 1)
# Codex 0.162.1's events name no model: then the top-level `model` key of its config, which this call
# uses unless a `profile` selects another.
# shortcut: a `profile` in config.toml is not followed; read it too if one is ever set for Gate B.
cfg="${CODEX_HOME:-$HOME/.codex}/config.toml"
if [ -z "$model" ] && regular "$cfg"; then
  model=$(awk '/^[[:space:]]*\[/ { exit } /^[[:space:]]*model[[:space:]]*=[[:space:]]*"/ { sub(/^[^"]*"/, ""); sub(/".*/, ""); print; exit }' "$cfg")
  [ -z "$model" ] || model="$model (config.toml)"
fi
{ printf 'CLI: %s\nHEAD: %s\nMODEL: %s\nEXIT: %s\n' "$v" "$head" "${model:-unknown}" "$rc"
  if regular "$pre-evidence.md"; then cat "$pre-evidence.md"; fi; } > "$work/evidence" && place "$work/evidence" "$pre-evidence.md"
[ -f "$work/timed-out" ] && finish 3 "timed out after ${secs}s"
[ "$rc" -eq 0 ] || { tail -n 20 "$work/stderr" >&2; finish 1 "codex exited $rc"; }

# The findings grammar of the gate rules: finding lines of six non-empty fields (an escaped pipe
# is no separator) with a severity from the closed set, or the single clean line; then the
# terminator counting the finding lines.
valid() {
  awk '
    { line[NR] = $0 }
    END {
      if (NR < 2) exit 1
      t = line[NR]
      if (t !~ /^END OF FINDINGS \([0-9]+ total\)$/) exit 1
      k = t; sub(/^END OF FINDINGS \(/, "", k); sub(/ total\)$/, "", k)
      if (NR == 2 && line[1] == "NO FINDINGS") exit (k + 0 == 0 ? 0 : 1)
      for (i = 1; i < NR; i++) {
        l = line[i]; gsub(/\\\|/, "", l)
        if (split(l, f, / \| /) != 6) exit 1
        if (f[1] !~ /^(BLOCKER|MAJOR|MINOR|NIT)$/) exit 1
        for (j = 2; j <= 6; j++) if (f[j] == "") exit 1
      }
      exit (k + 0 == NR - 1 ? 0 : 1)
    }' "$1"
}
regular "$pre.md" || finish 1 "no findings file $pre.md (or not a regular file)"
valid "$pre.md" || finish 1 "findings file $pre.md is not in the gate rules' format"

# The copy is validated again, so a file changed after the first check cannot be promoted.
if ! { cp "$pre.md" "$work/canon" && valid "$work/canon" && place "$work/canon" "$canon"; }; then
  finish 1 "could not write $canon"
fi
sum=$(perl -MDigest::SHA -e 'print Digest::SHA->new(256)->addfile($ARGV[0])->hexdigest' "$canon") || finish 1 'could not hash the canonical file'
append "$state" "$(printf 'risk %s done %s %s %s' "$n" "$a" "$head" "$sum")
" || die "could not record the result in $state" 1
printf 'risk pass %s attempt %s: %s\n' "$n" "$a" "$(tail -n 1 "$canon")"
exit 0
