#!/bin/sh
# Worktree cleanup: report a repository's linked worktrees and local branches, and with --remove
# delete only those the report marks removable.
# Spec: docs/superpowers/specs/2026-10-24-kit-044-field-cases-design.md §2.
#
# Usage: sh scripts/worktree-cleanup.sh [--remove [--discard-ignored]] [--root <dir>]... [<repo>]
#   <repo>             any path in the repository (default: the current directory)
#   --root <dir>       an absolute directory that also counts as a worktree root (for example a
#                      sibling "<repo>-lanes" directory); <main>/.claude/worktrees/ and
#                      <main>/.worktrees/ always count
#   --remove           remove the removable rows after reporting them
#   --discard-ignored  with --remove: a worktree holding ignored files (outside .context/) may be
#                      removed, deleting those files
#
# WHO RUNS IT: the orchestrator or the human, never the session working in one of the worktrees.
# A session whose worktree is removed under it keeps running plugin hooks, which then write into
# a deleted path or fall back to the main checkout.
#
# REMOVABLE means: inside a worktree root (physical path, so a symlink pointing out does not
# count), not locked, not detached, no .gitmodules, merged (its tip is an ancestor of the local
# default ref, or equals the head of a merged PR into the default branch, asked of gh with an
# explicit -R github.com/<owner>/<repo> from origin's URL), no tracked changes or untracked files,
# no process with its working directory inside (lsof), and no ignored files outside .context/
# unless --discard-ignored. A branch checked out nowhere is removable when merged. Any check that
# cannot be answered reads "unknown", which keeps the row.
#
# --remove, per removable worktree: copy its .context/ to <main>/.context/archive-worktree-<name>
# (-2, -3, ... when taken); recheck branch, tip, status, ignored files and sessions; `git worktree
# remove` without --force; then delete the branch with `git update-ref -d <ref> <reported tip>`,
# which fails if the branch moved. Remote branches are never touched. Exit 0 when nothing failed,
# 1 when an action failed, the repository cannot be read or another run holds the lock, 2 on a
# usage error or a bare repository.
#
# QUIESCENCE: --remove assumes the sessions in the removed worktrees are closed and nothing else
# checks out or moves branches during the run. Two windows stay open, each between two adjacent
# git calls: a process starting in a worktree (or a file written there) after the recheck and
# before `git worktree remove`, and a checkout of the branch elsewhere after the checkout check and
# before `update-ref` (its commits are kept: the tip is merged). No session registry or
# repository-wide lock exists to close them.
#
# WHAT IT DOES NOT: fetch (run `git fetch --prune` first; a stale or rewritten default ref is
# trusted as it is); see processes lsof cannot see (another user's) or sessions without a process
# whose cwd is inside, or compare a path holding bytes outside printable ASCII or a backslash with
# lsof's escaped names (session then reads unknown); detect squash merges without gh, for a remote not named origin or not on
# github.com, or beyond 100 merged PRs for one branch name (those read unknown); handle paths
# containing a tab or newline; judge whether a kept row is still wanted.
#
# POSIX sh plus git; gh and lsof optional. Regression suite: scripts/worktree-cleanup.test.sh.
set -u
LC_ALL=C; export LC_ALL
tab=$(printf '\t')

usage() {
  printf 'usage: sh scripts/worktree-cleanup.sh [--remove [--discard-ignored]] [--root <dir>]... [<repo>]\n' >&2
  exit 2
}

remove=0; discard=0; extra_roots=''; repo=''
while [ $# -gt 0 ]; do
  case $1 in
    --remove) remove=1 ;;
    --discard-ignored) discard=1 ;;
    --root)
      [ $# -ge 2 ] || usage
      case $2 in /*) ;; *) usage ;; esac
      r=$(cd "$2" 2>/dev/null && pwd -P) || usage
      extra_roots="$extra_roots$r
"
      shift ;;
    -*) usage ;;
    *) [ -z "$repo" ] || usage; repo=$1 ;;
  esac
  shift
done
[ "$discard" -eq 1 ] && [ "$remove" -eq 0 ] && usage
[ -n "$repo" ] || repo=.

wl=$(git -C "$repo" worktree list --porcelain 2>/dev/null) || {
  printf 'worktree-cleanup: %s is not in a git repository\n' "$repo" >&2; exit 1; }
if printf '%s\n' "$wl" | awk 'NF == 0 { exit } $1 == "bare" { b = 1 } END { exit !b }'; then
  printf 'worktree-cleanup: bare repository: no main worktree\n' >&2; exit 2
fi
main=$(printf '%s\n' "$wl" | sed -n '1s/^worktree //p')
main_phys=$(cd "$main" 2>/dev/null && pwd -P) || {
  printf 'worktree-cleanup: cannot enter the main worktree %s\n' "$main" >&2; exit 1; }
common=$(git -C "$main" rev-parse --path-format=absolute --git-common-dir 2>/dev/null) || {
  printf 'worktree-cleanup: cannot read the git directory of %s\n' "$main" >&2; exit 1; }

lock=$common/worktree-cleanup.lock
if ! mkdir "$lock" 2>/dev/null; then
  printf 'worktree-cleanup: %s exists: another worktree-cleanup run holds it, or a killed run left it; remove that directory once no run is active\n' "$lock" >&2
  exit 1
fi
tmp=''
trap 'rmdir "$lock" 2>/dev/null; [ -n "$tmp" ] && rm -rf "$tmp"' EXIT
trap 'exit 1' HUP INT TERM
tmp=$(mktemp -d) || exit 1

roots=''
for r in "$main_phys/.claude/worktrees" "$main_phys/.worktrees"; do
  [ -d "$r" ] && roots="$roots$(cd "$r" && pwd -P)
"
done
roots="$roots$extra_roots"

# Default ref: origin/HEAD's target, else origin/main, else origin/master.
def=$(git -C "$main" symbolic-ref -q refs/remotes/origin/HEAD 2>/dev/null)
def=${def#refs/remotes/}
if [ -z "$def" ]; then
  for c in origin/main origin/master; do
    if git -C "$main" rev-parse -q --verify "refs/remotes/$c^{commit}" >/dev/null 2>&1; then def=$c; break; fi
  done
fi
defname=${def#origin/}

url=$(git -C "$main" remote get-url origin 2>/dev/null)
slug=$(printf '%s\n' "$url" | sed -n -E 's#^(https://|ssh://git@|git@)github\.com[:/]([A-Za-z0-9._-]+)/([A-Za-z0-9._-]+)$#\2/\3#p' | sed 's/\.git$//')
gh_ok=0
[ -n "$slug" ] && [ -n "$defname" ] && command -v gh >/dev/null 2>&1 && gh_ok=1

# One lsof snapshot of process working directories into $1; returns 1 when it cannot be had.
snapshot() {
  command -v lsof >/dev/null 2>&1 || return 1
  lsof -w -nP -d cwd -Fn </dev/null > "$1.raw" 2>/dev/null || return 1
  sed -n 's/^n//p' "$1.raw" | grep '^/' > "$1" || return 1
}
# Session state of physical path $1 against snapshot file $2 (empty name: no snapshot). lsof
# escapes bytes outside printable ASCII (and so writes a backslash as an escape), so a path holding
# any of them cannot be compared literally and reads unknown.
session_of() {
  [ -n "$2" ] || { echo unknown; return; }
  case $1 in *[!\ -~]*|*\\*) echo unknown; return ;; esac
  if P=$1 awk 'BEGIN { p = ENVIRON["P"] } $0 == p || index($0, p "/") == 1 { f = 1; exit } END { exit !f }' "$2"
  then echo yes; else echo no; fi
}
# merged state of branch $1 at tip $2: ancestor | pr#<n> | no | unknown.
merged_of() {
  anc=unknown
  if [ -n "$def" ]; then
    git -C "$main" merge-base --is-ancestor "$2" "refs/remotes/$def" 2>/dev/null
    case $? in 0) echo ancestor; return ;; 1) anc=no ;; esac
  fi
  [ "$gh_ok" -eq 1 ] || { echo unknown; return; }
  out=$(cd "$main" && gh pr list -R "github.com/$slug" --state merged --base "$defname" --head "$1" \
        --json number,headRefOid --limit 100 --jq '.[] | "\(.number) \(.headRefOid)"' </dev/null 2>/dev/null) || {
    echo unknown; return; }
  [ "$(printf '%s\n' "$out" | grep -c .)" -ge 100 ] && { echo unknown; return; }
  m=$(printf '%s\n' "$out" | awk -v t="$2" '$2 == t { print $1; exit }')
  if [ -n "$m" ]; then echo "pr#$m"; else echo "$anc"; fi
}
# dirty state of worktree $1: yes | no | unknown.
dirty_of() {
  s=$(git -C "$1" status --porcelain 2>/dev/null) || { echo unknown; return; }
  if [ -n "$s" ]; then echo yes; else echo no; fi
}
# Ignored entries of worktree $1 outside .context/, written to $2; prints the count or unknown.
ignored_of() {
  git -C "$1" status --porcelain --ignored=matching > "$2.all" 2>/dev/null || { echo unknown; return; }
  sed -n 's/^!! //p' "$2.all" | grep -v '^\.context/' > "$2"
  wc -l < "$2" | tr -d ' '
}
inside_root() {
  printf '%s' "$roots" | while IFS= read -r r; do
    [ -n "$r" ] || continue
    case $1 in "$r"/*) echo y; break ;; esac
  done
}

# Linked worktrees, one per line: path, HEAD, branch ("-" when none; read collapses empty fields), detached, locked.
printf '%s\n' "$wl" | awk -v OFS="$tab" '
  function flush() { if (n > 1 && p != "") print p, h, (b == "" ? "-" : b), d, l; p = ""; h = ""; b = ""; d = 0; l = 0 }
  /^worktree / { flush(); n++; p = substr($0, 10) }
  /^HEAD / { h = substr($0, 6) }
  /^branch / { b = substr($0, 8); sub(/^refs\/heads\//, "", b) }
  /^detached$/ { d = 1 }
  /^locked/ { l = 1 }
  END { flush() }' > "$tmp/wts"
checked_out() { printf '%s\n' "$wl" | sed -n 's#^branch refs/heads/##p'; }

now=$(date +%s)
age_of() { ct=$(git -C "$main" log -1 --format=%ct "$1" 2>/dev/null) || ct=$now; echo $(( (now - ct) / 86400 )); }
ahead_of() { git -C "$main" rev-list --count "$1" --not --remotes 2>/dev/null || echo unknown; }

snap="$tmp/snap"; snapshot "$snap" || snap=''
printf '# default ref: %s (the local copy; run git fetch --prune first)\n' "${def:-none}"
if [ "$gh_ok" -eq 1 ]; then printf '# merged PRs: gh -R github.com/%s, base %s\n' "$slug" "$defname"
else printf '# merged PRs: unavailable (gh missing, origin not on github.com, or no default ref); squash merges read unknown\n'; fi
[ -n "$snap" ] || printf '# sessions: lsof unavailable or saw nothing; every worktree reads session=unknown\n'
printf '# remote branches are never touched\n'

: > "$tmp/rm-wts"
while IFS="$tab" read -r p h b d l <&3; do
  [ "$b" = - ] && b=''
  phys=$(cd "$p" 2>/dev/null && pwd -P)
  if [ -z "$phys" ]; then
    printf 'worktree %s  branch=%s  -> keep: missing\n' "$p" "${b:--}"; continue
  fi
  merged=-; dirty=$(dirty_of "$p"); ign=$(ignored_of "$p" "$tmp/ign")
  sess=$(session_of "$phys" "$snap")
  [ -n "$b" ] && merged=$(merged_of "$b" "$h")
  verdict=removable
  if [ -z "$(inside_root "$phys")" ]; then verdict='keep: outside worktree roots'
  elif [ "$l" = 1 ]; then verdict='keep: locked'
  elif [ "$d" = 1 ] || [ -z "$b" ]; then verdict='keep: detached'
  elif [ -e "$p/.gitmodules" ]; then verdict='keep: submodules'
  else
    case $merged in ancestor|pr#*) ;; *) verdict="keep: not merged ($merged)" ;; esac
  fi
  if [ "$verdict" = removable ]; then
    if [ "$dirty" != no ]; then verdict="keep: dirty ($dirty)"
    elif [ "$ign" = unknown ] || { [ "$ign" != 0 ] && [ "$discard" -eq 0 ]; }; then verdict="keep: ignored files ($ign)"
    elif [ "$sess" != no ]; then verdict="keep: session ($sess)"
    fi
  fi
  printf 'worktree %s  branch=%s  merged=%s  dirty=%s  ignored=%s  ahead=%s  age=%sd  session=%s  -> %s\n' \
    "$p" "${b:--}" "$merged" "$dirty" "$ign" "$(ahead_of "$h")" "$(age_of "$h")" "$sess" "$verdict"
  [ "$ign" != unknown ] && [ "$ign" != 0 ] && head -n 5 "$tmp/ign" | sed 's/^/  ignored: /'
  [ "$verdict" = removable ] && printf '%s\t%s\t%s\t%s\n' "$p" "$phys" "$b" "$h" >> "$tmp/rm-wts"
done 3< "$tmp/wts"

: > "$tmp/rm-brs"
git -C "$main" for-each-ref --format='%(refname)%09%(objectname)' refs/heads/ > "$tmp/brs"
checked_out > "$tmp/co"
while IFS="$tab" read -r ref h <&3; do
  b=${ref#refs/heads/}
  [ "$b" = "$defname" ] && continue
  grep -qxF -- "$b" "$tmp/co" && continue
  merged=$(merged_of "$b" "$h"); verdict=removable
  case $merged in ancestor|pr#*) ;; *) verdict="keep: not merged ($merged)" ;; esac
  printf 'branch %s  merged=%s  ahead=%s  age=%sd  -> %s\n' "$b" "$merged" "$(ahead_of "$h")" "$(age_of "$h")" "$verdict"
  [ "$verdict" = removable ] && printf '%s\t%s\n' "$b" "$h" >> "$tmp/rm-brs"
done 3< "$tmp/brs"

[ "$remove" -eq 1 ] || exit 0

failed=0
# Delete branch $1 when checked out nowhere and still at tip $2.
delete_branch() {
  if git -C "$main" worktree list --porcelain 2>/dev/null | grep -qxF -- "branch refs/heads/$1"; then
    printf 'skipped branch %s: checked out again\n' "$1"; return
  fi
  if msg=$(git -C "$main" update-ref -d "refs/heads/$1" "$2" 2>&1); then printf 'removed branch %s\n' "$1"
  else printf 'failed branch %s: %s\n' "$1" "$msg"; failed=1; fi
}
while IFS="$tab" read -r p phys b h <&3; do
  if [ -d "$p/.context" ]; then
    base="$main/.context/archive-worktree-$(basename "$p")"; dest=$base; i=1; ok=1
    mkdir -p "$main/.context" 2>/dev/null || ok=0
    while [ "$ok" -eq 1 ] && ! mkdir "$dest" 2>/dev/null; do
      if { [ -e "$dest" ] || [ -L "$dest" ]; } && [ "$i" -lt 1000 ]; then i=$((i + 1)); dest="$base-$i"; else ok=0; fi
    done
    if [ "$ok" -eq 0 ]; then printf 'failed %s: cannot create an archive directory under %s/.context\n' "$p" "$main"; failed=1; continue; fi
    if ! msg=$(cp -R "$p/.context/." "$dest/" 2>&1); then
      printf 'failed %s: archive copy to %s: %s\n' "$p" "$dest" "$msg"; failed=1; continue
    fi
    printf 'archived %s/.context to %s\n' "$p" "$dest"
  fi
  # Recheck: sessions first (a fresh lsof run), then the entry, status and ignored files.
  s2="$tmp/snap2"; snapshot "$s2" || s2=''
  now_entry=$(git -C "$main" worktree list --porcelain 2>/dev/null | awk -v OFS="$tab" -v want="$p" '
    /^worktree / { p = substr($0, 10); h = ""; b = "" }
    /^HEAD / { h = substr($0, 6) }
    /^branch / { b = substr($0, 8); sub(/^refs\/heads\//, "", b) }
    /^$/ { if (p == want) { print h, b; found = 1; exit } p = "" }
    END { if (!found && p == want) print h, b }')
  why=''
  if [ "$(session_of "$phys" "$s2")" != no ]; then why=session
  elif [ "$now_entry" != "$h$tab$b" ]; then why='branch or tip'
  elif [ "$(dirty_of "$p")" != no ]; then why=dirty
  else
    ign=$(ignored_of "$p" "$tmp/ign2")
    if [ "$ign" = unknown ] || { [ "$ign" != 0 ] && [ "$discard" -eq 0 ]; }; then why='ignored files'; fi
  fi
  if [ -n "$why" ]; then printf 'skipped %s: changed since the report (%s)\n' "$p" "$why"; continue; fi
  if ! msg=$(git -C "$main" worktree remove "$p" 2>&1); then printf 'failed %s: %s\n' "$p" "$msg"; failed=1; continue; fi
  printf 'removed worktree %s\n' "$p"
  delete_branch "$b" "$h"
done 3< "$tmp/rm-wts"
while IFS="$tab" read -r b h <&3; do delete_branch "$b" "$h"; done 3< "$tmp/rm-brs"
exit "$failed"
