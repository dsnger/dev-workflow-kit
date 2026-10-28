#!/bin/sh
# Local CI: run the quality battery of one commit in a temporary detached worktree and post the
# result to GitHub as that commit's `quality` status.
# Spec: docs/superpowers/specs/2026-10-28-kit-local-ci-design.md §2.
#
# Usage: sh scripts/local-ci.sh [<commit>]
#   <commit>  any commit-ish (default HEAD) of the repository containing the current directory
#
# PRECONDITIONS, in this order; a failure prints one line, exits 64 and posts nothing:
#   1. <commit> resolves to a commit; the script works on its full SHA from then on
#   2. origin's URL names a github.com repository (https://, ssh://git@ or git@ form); owner and
#      repository come from it alone, never from GH_REPO or GH_HOST
#   3. gh is on PATH and `gh auth status --hostname github.com` succeeds
#   4. that commit's .github/workflows/ci.yml pins one shellcheck version (every
#      koalaman/shellcheck:v<version> agrees), and it is the `version:` of `shellcheck --version`
#   5. that commit's AGENTS.md has exactly one line starting with "| quality ", whose last cell is
#      one command in backticks; that text runs verbatim under `sh -c`
#
# WHAT IT DOES: unsets the repository-selecting GIT_* variables first, so an inherited GIT_DIR
# cannot aim the run at another repository; adds a detached worktree of the SHA in a `mktemp -d`
# directory under TMPDIR (default /tmp; uncommitted changes never reach it); runs the quality
# command there in the foreground, output passed through; posts state success (exit 0) or failure
# (any other status), context quality and the description
# "battery green|red: local run, shellcheck <v>, claude <v>" (claude "unknown" when its version
# cannot be read) with `gh api`, REST API version 2026-03-10; prints the SHA, state and
# description in one line. On every exit it removes the worktree (`git worktree remove --force`
# of that path only, never a prune) and the directory; a failed removal keeps both and prints the
# command that finishes it. Its own parsing runs under LC_ALL=C; the battery keeps the caller's
# locale, as in a manual run.
#
# SIGNALS: HUP, INT or TERM is handled once the running command returns (nothing forwards it, so
# a hung stage delays it); the worktree is then removed and the script exits 128+n without
# posting. Ctrl-C in a terminal reaches the whole process group and stops the command at once. A
# signal after the post was sent cannot undo it.
#
# WHAT IT DOES NOT: fetch (run `git fetch origin` first, so origin/main is current); push (an
# unpushed SHA fails the post with GitHub's 422, exit 75); judge whether the commit's code is safe
# to run; check claude's version against the CI pin; post pending, error or a target_url;
# serialize parallel runs; enable or disable the Actions workflow; interrupt a running stage.
#
# EXIT: 0 green and posted; the battery's own status when red and posted; 75 when the battery ran
# but the post failed, green or red; 64 on a usage error, a precondition or a setup failure
# (nothing ran, nothing posted); 128+n after signal n.
# shortcut: a battery stage that itself exits 64 or 75 reads like those outcomes by status alone
# (the printed line tells them apart; no stage exits either today), split the codes if one does.
# shortcut: a quality command containing `|` is not supported (its cell starts after the row's
# last `|`), move such a pipeline into a script if one is ever needed.
#
# POSIX sh plus git and gh. Regression suite: scripts/local-ci.test.sh.
set -u
unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_COMMON_DIR GIT_OBJECT_DIRECTORY \
  GIT_ALTERNATE_OBJECT_DIRECTORIES GIT_NAMESPACE GIT_CEILING_DIRECTORIES

usage() { printf 'usage: sh scripts/local-ci.sh [<commit>]\n' >&2; exit 64; }
# refuse <condition; what to do>: one line on stderr and exit 64, before anything ran.
refuse() { printf 'local-ci: %s\n' "$1" >&2; exit 64; }

[ $# -le 1 ] || usage
case ${1-} in -*) usage ;; esac
rev=${1:-HEAD}

git rev-parse --show-toplevel >/dev/null 2>&1 ||
  refuse 'the current directory is not inside a git work tree; run it from the repository root'
sha=$(git rev-parse --verify -q "$rev^{commit}" 2>/dev/null) ||
  refuse "$rev does not name a commit here; pass a commit, branch or tag of this repository"
url=$(git remote get-url origin 2>/dev/null)
slug=$(printf '%s\n' "$url" | LC_ALL=C sed -n -E 's#^(https://|ssh://git@|git@)github\.com[:/]([A-Za-z0-9._-]+)/([A-Za-z0-9._-]+)$#\2/\3#p' | LC_ALL=C sed 's/\.git$//')
[ -n "$slug" ] ||
  refuse 'origin is missing or not a github.com repository URL; point origin at https://github.com/<owner>/<repo>.git'
command -v gh >/dev/null 2>&1 ||
  refuse 'gh is not on PATH; install the GitHub CLI, then run gh auth login --hostname github.com'
gh auth status --hostname github.com >/dev/null 2>&1 ||
  refuse 'gh auth status --hostname github.com failed; run it to see why, then gh auth login --hostname github.com'
# The distinct versions of every koalaman/shellcheck:v<version>; exactly one passes (printed).
pin=$(git show "$sha:.github/workflows/ci.yml" 2>/dev/null | LC_ALL=C awk '
  { s = $0
    while (match(s, /koalaman\/shellcheck:v[A-Za-z0-9_.-]+/)) {
      v = substr(s, RSTART + 21, RLENGTH - 21); if (!(v in seen)) { seen[v] = 1; n++ }
      s = substr(s, RSTART + RLENGTH) } }
  END { if (n == 1) print v; exit (n != 1) }') ||
  refuse ".github/workflows/ci.yml at $sha does not pin exactly one shellcheck version; pin one koalaman/shellcheck:v<version>"
have=$(shellcheck --version 2>/dev/null | LC_ALL=C sed -n 's/^version: //p')
[ "$have" = "$pin" ] ||
  refuse "local shellcheck is ${have:-missing}, ci.yml pins $pin; install shellcheck $pin"
# The quality row's last cell, the text between its backticks; the label may hold backticks or \|.
cmd=$(git show "$sha:AGENTS.md" 2>/dev/null | LC_ALL=C awk '
  index($0, "| quality ") == 1 { n++; row = $0 }
  END {
    if (n != 1) exit 1
    sub(/[ \t]*[|][ \t]*$/, "", row)
    cell = substr(row, match(row, /[|][^|]*$/) + 1)
    gsub(/^[ \t]+|[ \t]+$/, "", cell)
    if (cell !~ /^`[^`]*[^` \t][^`]*`$/) exit 1
    print substr(cell, 2, length(cell) - 2) }') ||
  refuse "AGENTS.md at $sha has no single quality row with one command in backticks as its last cell; keep exactly one \"| quality \" row"
# Only a version-shaped first word goes into the public description, never a path or a name.
cv=$(claude --version 2>/dev/null | LC_ALL=C awk 'NR == 1 && $1 ~ /^[0-9][0-9A-Za-z.+-]*$/ { print $1 }')

tmp='' added=''
# Remove the worktree (that path only, never a prune) and the directory; a failed removal keeps
# both and names the command that finishes it. The exit status stays the run's.
# shellcheck disable=SC2329  # run by the EXIT trap; every path below ends in exit, which hides that
cleanup() {
  [ -n "$tmp" ] || return
  if [ -n "$added" ] && ! git worktree remove --force "$tmp/wt" >/dev/null 2>&1; then
    printf "local-ci: could not remove %s; run: git worktree remove --force '%s'\n" "$tmp/wt" "$tmp/wt" >&2
  else
    rm -rf "$tmp"
  fi
}
trap cleanup EXIT
trap 'exit 129' HUP; trap 'exit 130' INT; trap 'exit 143' TERM
# An explicit template: macOS's bare `mktemp -d` ignores TMPDIR.
tmp=$(mktemp -d "${TMPDIR:-/tmp}/local-ci.XXXXXX") || refuse 'could not create a temporary directory; check TMPDIR'
git worktree add --quiet --detach "$tmp/wt" "$sha" || refuse "could not add a worktree of $sha; see the git error above"
added=1

(cd "$tmp/wt" && sh -c "$cmd")
st=$?

if [ "$st" -eq 0 ]; then state=success; desc='battery green'; else state=failure; desc='battery red'; fi
desc="$desc: local run, shellcheck $pin, claude ${cv:-unknown}"
if gh api --hostname github.com --method POST -H "X-GitHub-Api-Version: 2026-03-10" "repos/$slug/statuses/$sha" \
  -f state="$state" -f context=quality -f description="$desc" >/dev/null; then
  printf 'local-ci: posted quality=%s on %s: %s\n' "$state" "$sha" "$desc"
  exit "$st"
fi
printf 'local-ci: post failed for quality=%s on %s; rerun after fixing gh\n' "$state" "$sha" >&2
exit 75
