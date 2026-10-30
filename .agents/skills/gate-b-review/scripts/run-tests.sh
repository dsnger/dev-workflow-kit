#!/bin/sh
# run-tests.sh — runs one targeted test command for a Gate B reviewer in a disposable copy of the
# repository (dev-workflow kit 0.51, spec docs/superpowers/specs/2026-10-30-kit-051-codex-review-design.md §5).
#
# Usage: run-tests.sh <repo> <headSha> <seconds> -- <command…>
#   <repo>     a git work tree (the reviewed checkout)
#   <headSha>  the reviewed head, 40 lowercase hex, reachable from a ref of <repo>
#   <seconds>  time limit, 1-1800; empty means 600
# Stdout: one line `<command> | exit <n> | <s>s` (`exit timeout` after a kill). The command's own
# output goes to stderr, its last 200 lines only.
# Exit: the command's status; 124 timeout; 2 bad arguments or no copy made; 4 checkout changed;
# 5 no process supervisor (perl).
#
# What it guarantees and what it does not:
# - The copy is `git clone --no-local --no-checkout` + a detached checkout of <headSha>: tracked
#   files only, no alternates back to <repo>. Never `git worktree add`.
# - The command runs under `env -i` with only PATH, HOME and TMPDIR (both inside the copy's
#   directory) and LANG=C, stdin from /dev/null, as the leader of its own process group
#   (perl setpgrp; `set -m` does nothing in a non-interactive dash). After <seconds> the group
#   gets TERM, 5 s later KILL. On every exit both groups (command, watchdog) are killed and the
#   copy is removed.
# - Not prevented: reading host files by absolute path, network (the Codex sandbox decides that),
#   a secret committed to tracked files, a process that leaves the group with its own setsid, and
#   a KILL of this script itself (the next run reports such a copy; see stale_scan).
# - The reviewed checkout is fingerprinted before and after (see fingerprint; `.context/`
#   excluded except .context/codex-reviews/). A difference exits 4. It detects, it does not
#   prevent; ignored files, the rest of `.context/` and `.git/` beyond HEAD and the index are
#   outside it.
set -u

die() { printf 'run-tests.sh: %s\n' "$1" >&2; exit "${2:-2}"; }
usage() { die "$1 (usage: run-tests.sh <repo> <headSha> <seconds> -- <command…>)" 2; }

[ $# -ge 5 ] || usage 'too few arguments'
repo=$1; head=$2; secs=$3
[ "$4" = -- ] || usage 'the fourth argument must be --'
shift 4
# Explicit character lists: in a bash locale a range such as a-z also matches capitals.
case $head in *[!0123456789abcdef]*|'') usage 'headSha must be 40 lowercase hex' ;; esac
[ ${#head} -eq 40 ] || usage 'headSha must be 40 lowercase hex'
[ -n "$secs" ] || secs=600
case $secs in *[!0-9]*) usage 'seconds must be an integer 1-1800' ;; esac
[ ${#secs} -le 4 ] && [ "$secs" -ge 1 ] && [ "$secs" -le 1800 ] || usage 'seconds must be an integer 1-1800'
repo=$(git -C "$repo" rev-parse --show-toplevel 2>/dev/null) && [ -n "$repo" ] || usage 'repo is not a git work tree'
git -C "$repo" cat-file -e "$head^{commit}" 2>/dev/null || usage "headSha $head is not a commit in $repo"
command -v perl >/dev/null 2>&1 || die 'no process supervisor: perl not found, nothing run' 5

# Process-group helpers in perl, so sh and dash behave alike.
group_alive() { perl -e 'exit(kill(0, -$ARGV[0]) ? 0 : 1)' "$1" 2>/dev/null; }
group_signal() { perl -e 'kill $ARGV[0], -$ARGV[1]' "$1" "$2" 2>/dev/null; }
pid_alive() { perl -e 'exit(kill(0, $ARGV[0]) ? 0 : 1)' "$1" 2>/dev/null; }
# TERM, up to 5 s, then KILL, then wait until the group is empty (KILL cannot be ignored).
group_stop() {
  group_alive "$1" || return 0
  group_signal TERM "$1"; i=0
  while group_alive "$1" && [ $i -lt 50 ]; do sleep 0.1; i=$((i + 1)); done
  group_signal KILL "$1"
  while group_alive "$1"; do sleep 0.1; done
}

# Fingerprint of the reviewed checkout, as one hash; fails (status 1) when any part fails. Read-only
# git calls only, because the Codex sandbox keeps .git read-only: HEAD, the effective index as
# `ls-files -s` lists it, `diff HEAD --binary` (tracked content and modes), and each untracked,
# not-ignored path and everything under .context/codex-reviews/ with its lstat mode and the sha256
# of its content (a symlink: of its target; anything but a regular file: of nothing, so a FIFO
# cannot block the read).
fingerprint() {
  fp_dir=$(mktemp -d "${TMPDIR%/}/gate-b-fp.XXXXXX") || return 1
  # shellcheck disable=SC2016  # perl source
  if {
       git --no-optional-locks -C "$repo" rev-parse HEAD &&
       git --no-optional-locks -C "$repo" ls-files -s &&
       git --no-optional-locks -C "$repo" diff HEAD --binary -- . ':(exclude).context' &&
       git --no-optional-locks -C "$repo" ls-files -z -o --exclude-standard -- . ':(exclude).context' > "$fp_dir/untracked" &&
       # The gate's own records are in: a test must not forge a findings or state file.
       { [ ! -d "$repo/.context/codex-reviews" ] ||
         ( cd "$repo" && find .context/codex-reviews -print0 ) >> "$fp_dir/untracked"; } &&
       ( cd "$repo" && perl -0 -MDigest::SHA -ne 'chomp; my @s = lstat($_) or exit 1;
           my $d = Digest::SHA->new(256); -l _ ? $d->add(readlink($_)) : -f _ ? $d->addfile($_) : 0;
           printf "%o %s %s\n", $s[2], $d->hexdigest, $_;' < "$fp_dir/untracked" )
     } > "$fp_dir/stream" 2>/dev/null; then
    git hash-object --stdin < "$fp_dir/stream"; st=$?
  else st=1; fi
  rm -rf "$fp_dir"; return $st
}

# Earlier copies: runner and group both gone → removed; runner alive → another run, left alone;
# runner gone but group alive → left in place and reported (we never kill a group we cannot prove
# we own, and never delete beneath a live writer). A copy without runner.pid is left and reported.
stale_scan() {
  for d in "${TMPDIR%/}"/gate-b-review.*; do
    [ -d "$d" ] || continue
    rp=$(cat "$d/runner.pid" 2>/dev/null) || rp=
    gp=$(cat "$d/group.pid" 2>/dev/null) || gp=
    case $rp in ''|*[!0-9]*) printf 'run-tests.sh: stale copy %s has no runner record; left in place\n' "$d" >&2; continue ;; esac
    pid_alive "$rp" && continue
    case $gp in *[!0-9]*) gp= ;; esac
    if [ -n "$gp" ] && group_alive "$gp"; then
      printf 'run-tests.sh: stale copy %s with live process group %s; left in place\n' "$d" "$gp" >&2
    else
      rm -rf "$d"
    fi
  done
}

tmp=; cpid=; wpid=
cleanup() {
  [ -n "$wpid" ] && group_stop "$wpid"
  [ -n "$cpid" ] && group_stop "$cpid"
  [ -n "$tmp" ] && rm -rf "$tmp"
  tmp=; cpid=; wpid=
}
trap cleanup EXIT
trap 'exit 129' HUP; trap 'exit 130' INT; trap 'exit 143' TERM

TMPDIR=${TMPDIR:-/tmp}
stale_scan
fp_before=$(fingerprint) || die 'cannot fingerprint the reviewed checkout; nothing run' 2
# An explicit template: macOS's bare `mktemp -d` ignores TMPDIR.
tmp=$(mktemp -d "${TMPDIR%/}/gate-b-review.XXXXXX") || die 'could not create a temporary directory; check TMPDIR' 2
printf '%s\n' "$$" > "$tmp/runner.pid"
mkdir "$tmp/home" "$tmp/tmp" || die 'could not prepare the copy' 2
if ! git clone --quiet --no-local --no-checkout -- "$repo" "$tmp/src" 2>/dev/null ||
   ! git -C "$tmp/src" checkout --quiet --detach "$head" 2>/dev/null; then
  die "could not make a copy at $head (is it reachable from a ref of $repo?)" 2
fi
git -C "$tmp/src" remote remove origin 2>/dev/null || :

start=$(date +%s)
# shellcheck disable=SC2016  # perl source: $ARGV and $! are perl's, not the shell's
( cd "$tmp/src" && exec env -i PATH="$PATH" HOME="$tmp/home" TMPDIR="$tmp/tmp" LANG=C \
    perl -e 'setpgrp(0,0) or die "setpgrp: $!\n"; exec { $ARGV[0] } @ARGV or die "exec $ARGV[0]: $!\n"' -- "$@" ) \
  </dev/null >"$tmp/out" 2>&1 &
cpid=$!
printf '%s\n' "$cpid" > "$tmp/group.pid"
# The watchdog: its own group too, so cleanup can stop it; it marks a timeout before signalling.
perl -e 'setpgrp(0,0); sleep $ARGV[0]; open(my $f, ">", $ARGV[2]); close $f;
         kill "TERM", -$ARGV[1]; sleep 5; kill "KILL", -$ARGV[1];' "$secs" "$cpid" "$tmp/timed-out" \
  </dev/null >/dev/null 2>&1 &
wpid=$!
wait "$cpid"; rc=$?
end=$(date +%s)
[ -f "$tmp/timed-out" ] && rc=timeout
tail -n 200 "$tmp/out" >&2
cleanup
fp_after=$(fingerprint) || fp_after=unavailable

# A literal pipe in the command is escaped, so the report stays one `|`-separated line.
printf '%s | exit %s | %ss\n' "$(printf '%s' "$*" | sed 's/|/\\|/g' | tr '\n' ' ')" "$rc" "$((end - start))"
[ "$fp_after" = "$fp_before" ] || die 'checkout changed: the reviewed checkout differs from before the run' 4
[ "$rc" = timeout ] && exit 124
exit "$rc"
