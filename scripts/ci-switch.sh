#!/bin/sh
# CI switch: show whether this repository's quality workflow runs on GitHub Actions (hosted, the
# default) or is disabled so scripts/local-ci.sh posts the check (local, the fallback or an up-front
# choice); flip it after a yes; check a failed run for a billing block; remind when a new month
# renews the Actions budget.
# From the dev-workflow kit, which ships it to projects as `/workflow-init` 2.27 (the same bytes);
# its regression suite is the kit's scripts/ci-switch.test.sh.
#
# Usage: sh scripts/ci-switch.sh                         show the state
#        sh scripts/ci-switch.sh hosted|local "<reason>"  flip, after a yes read from stdin
#        sh scripts/ci-switch.sh check <run-id>           was this failed run blocked by billing?
#
# PRECONDITIONS (each failure: one line, exit 64): inside a git work tree; origin's URL names a
# github.com repository (owner and repository come from it alone, never from GH_REPO or GH_HOST);
# gh on PATH and `gh auth status --hostname github.com` succeeds; exactly one of
# .github/workflows/quality.yml and .github/workflows/ci.yml exists in the work tree.
#
# STATE: GET repos/<o>/<r>/actions/workflows/<file> (REST API version 2026-03-10), field state:
# active is hosted; disabled_manually and disabled_inactivity are local; anything else, empty or a
# failed read refuses (64).
#
# FLIP: already in the target state: says so, exit 0, nothing logged. Otherwise it checks the log
# can be appended (64 before asking if not), asks one question and reads one line; y or yes (any
# case) goes on, anything else or end of input: "not switched", exit 1. It reads the state again
# (changed meanwhile: not switched, exit 1), then PUTs .../enable (to hosted) or .../disable (to
# local). A failed PUT is followed by one read: the target reached (a lost reply) is logged with
# "(reply failed, state read back)", exit 0; else exit 75, nothing logged. Nothing else is ever
# written to GitHub: no ruleset, branch protection, variable, billing or spending limit.
#
# LOG: <main>/.context/ci-switch.log, <main> the first entry of `git worktree list` (every worktree
# of one clone shares it), untracked. One tab-separated line per flip: UTC time, from, to, workflow
# file, reason (tabs and line breaks in it become spaces). An append that fails after the flip is
# reported; the flip stands, exit 0. A change made outside this script (the web UI, another clone)
# is not logged; two flips at the same moment are not serialised beyond the read after the yes.
#
# REMINDER: when the log's last switch went to local in an earlier calendar month (UTC) and GitHub
# still reads local, one line on stderr names the command back to hosted. scripts/local-ci.sh
# prints the same line from the log alone. A billing cycle that renews on another day is not seen.
#
# CHECK: GET .../actions/runs/<run-id>/jobs, every page; a job whose conclusion is failure and whose
# steps are empty never started; its check run (the id ending its check_run_url) has its
# annotations read, and a message matching "spending limit" or "payments have failed" (any case) is
# a billing block: it prints the job, the message, the switch command and what else the switch
# needs, exit 0. No such job or message: exit 1. A job with steps is never read, so a test whose
# output mentions billing is no hit. A failed read, or a selected job without a numeric check run id: 64.
# It flips nothing.
#
# EXIT: 0 done (check: block found); 1 not switched (check: no block); 64 usage, precondition or
# read failure; 75 the flip request failed and the state is not the target.
#
# POSIX sh plus git and gh (gh's own --jq).
set -u
unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_COMMON_DIR GIT_OBJECT_DIRECTORY \
  GIT_ALTERNATE_OBJECT_DIRECTORIES GIT_NAMESPACE GIT_CEILING_DIRECTORIES

usage() { printf 'usage: sh scripts/ci-switch.sh [hosted|local "<reason>" | check <run-id>]\n' >&2; exit 64; }
refuse() { printf 'ci-switch: %s\n' "$1" >&2; exit 64; }

mode=show arg=''
case $# in
  0) ;;
  2) case $1 in hosted|local|check) mode=$1 arg=$2 ;; *) usage ;; esac ;;
  *) usage ;;
esac
if [ "$mode" = check ]; then
  case $arg in ''|*[!0-9]*) usage ;; esac
elif [ "$mode" != show ]; then
  reason=$(printf '%s' "$arg" | tr '\t\r\n' '   ')
  case $reason in *[![:space:]]*) ;; *) usage ;; esac
fi

top=$(git rev-parse --show-toplevel 2>/dev/null) ||
  refuse 'the current directory is not inside a git work tree; run it from the repository root'
url=$(git remote get-url origin 2>/dev/null)
slug=$(printf '%s\n' "$url" | LC_ALL=C sed -n -E 's#^(https://|ssh://git@|git@)github\.com[:/]([A-Za-z0-9._-]+)/([A-Za-z0-9._-]+)$#\2/\3#p' | LC_ALL=C sed 's/\.git$//')
[ -n "$slug" ] ||
  refuse 'origin is missing or not a github.com repository URL; point origin at https://github.com/<owner>/<repo>.git'
command -v gh >/dev/null 2>&1 ||
  refuse 'gh is not on PATH; install the GitHub CLI, then run gh auth login --hostname github.com'
gh auth status --hostname github.com >/dev/null 2>&1 ||
  refuse 'gh auth status --hostname github.com failed; run it to see why, then gh auth login --hostname github.com'
n=0 wf=''
for f in quality.yml ci.yml; do [ -f "$top/.github/workflows/$f" ] && n=$((n + 1)) wf=$f; done
[ "$n" -eq 1 ] ||
  refuse "found $n of .github/workflows/quality.yml and .github/workflows/ci.yml in $top; exactly one names the quality workflow"

api() { gh api --hostname github.com -H "X-GitHub-Api-Version: 2026-03-10" "$@"; }
state() { api "repos/$slug/actions/workflows/$wf" --jq .state 2>/dev/null; }
# side <state>: hosted or local; any other state: status 1.
side() { case $1 in active) echo hosted ;; disabled_manually|disabled_inactivity) echo local ;; *) return 1 ;; esac; }

if [ "$mode" = check ]; then
  tab=$(printf '\t')
  jobs=$(api --paginate "repos/$slug/actions/runs/$arg/jobs?per_page=100" \
    --jq '.jobs[] | select(.conclusion == "failure" and (.steps | length) == 0) | [.name, .check_run_url] | @tsv' 2>/dev/null) ||
    refuse "could not read the jobs of run $arg in $slug; check the run id"
  hit=''
  while IFS=$tab read -r name curl; do
    [ -n "$name$curl" ] || continue  # the one empty line of no selected job
    id=${curl##*/}
    case $id in ''|*[!0-9]*) refuse "job \"$name\" of run $arg has no check run id in $curl" ;; esac
    msgs=$(api --paginate "repos/$slug/check-runs/$id/annotations?per_page=100" --jq '.[].message' 2>/dev/null) ||
      refuse "could not read the annotations of check run $id (run $arg)"
    m=$(printf '%s\n' "$msgs" | grep -iE 'spending limit|payments have failed' | sed -n 1p)
    [ -n "$m" ] || continue
    printf 'ci-switch: run %s: job "%s" was not started: %s\n' "$arg" "$name" "$m"
    hit=1
  done <<EOF
$jobs
EOF
  if [ -z "$hit" ]; then
    printf 'ci-switch: run %s shows no billing block (no job GitHub never started with a billing annotation)\n' "$arg"
    exit 1
  fi
  printf 'ci-switch: GitHub Actions is blocked by billing for %s; switch to local: sh scripts/ci-switch.sh local "Actions budget used up"\n' "$slug"
  printf 'ci-switch: then push a new head and run sh scripts/local-ci.sh on it: a quality check run Actions already created on a commit stays there and must pass too; a required quality check restricted to one source cannot be met by local-ci.sh, and lifting that is yours\n'
  exit 0
fi

cur=$(state)
from=$(side "$cur") ||
  refuse "the workflow $wf of $slug reads state '${cur:-none}', neither hosted nor local; look at it on GitHub"
printf 'ci-switch: %s is %s (%s: %s)\n' "$slug" "$from" "$wf" "$cur"
main=$(git worktree list --porcelain 2>/dev/null | sed -n '1s/^worktree //p')
log=${main:-$top}/.context/ci-switch.log

if [ "$mode" = show ]; then
  if [ "$from" = local ]; then
    last=$(LC_ALL=C awk -F '\t' '$3 == "hosted" || $3 == "local" { l = $0 } END { print l }' "$log" 2>/dev/null)
    m=$(printf '%s\n' "$last" | LC_ALL=C awk -F '\t' '$3 == "local" && $1 ~ /^[0-9][0-9][0-9][0-9]-[0-9][0-9]/ { print substr($1, 1, 7) }')
    [ -z "$m" ] || [ "$m" = "$(date -u +%Y-%m)" ] ||
      printf 'ci-switch: a new month renews the Actions budget (last recorded switch to local: %s); back to hosted: sh scripts/ci-switch.sh hosted "budget renewed"\n' "$m" >&2
  fi
  exit 0
fi

to=$mode
if [ "$from" = "$to" ]; then printf 'ci-switch: already %s; nothing switched\n' "$to"; exit 0; fi
if ! { mkdir -p "${log%/*}" && true >> "$log"; } 2>/dev/null; then
  refuse "cannot write the switch log $log; fix that, then switch"
fi
printf 'Switch %s CI from %s to %s (%s; reason: %s)? [y/N] ' "$slug" "$from" "$to" "$wf" "$reason"
ans=''
read -r ans || ans=''
case $ans in [yY]|[yY][eE][sS]) ;; *) printf 'ci-switch: not switched\n'; exit 1 ;; esac
now=$(state)
if [ "$now" != "$cur" ]; then printf 'ci-switch: the state changed to %s meanwhile; not switched\n' "${now:-unknown}"; exit 1; fi
verb=enable; [ "$to" = local ] && verb=disable
note=''
if ! api --method PUT "repos/$slug/actions/workflows/$wf/$verb" >/dev/null; then
  back=$(state); got=$(side "$back") || got=''
  if [ "$got" != "$to" ]; then
    printf 'ci-switch: the switch request failed; %s is still %s\n' "$slug" "${got:-unknown}" >&2
    exit 75
  fi
  note=' (reply failed, state read back)'
fi
line=$(printf '%s\t%s\t%s\t%s\t%s%s' "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$from" "$to" "$wf" "$reason" "$note")
printf '%s\n' "$line" >> "$log" 2>/dev/null ||
  printf 'ci-switch: switched, but the log line could not be written: %s\n' "$line" >&2
printf 'ci-switch: %s switched from %s to %s%s\n' "$slug" "$from" "$to" "$note"
