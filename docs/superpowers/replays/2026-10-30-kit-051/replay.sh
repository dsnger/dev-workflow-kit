#!/bin/sh
# replay.sh — kit 0.51 proof replay (spec docs/superpowers/specs/2026-10-30-kit-051-codex-review-design.md §8,
# plan T7). Not shipped. Replays the new Gate B review on one historical PR at its pre-fix head, in a clone
# that holds no later history, and keeps every reply, findings file and --json event log for scoring
# against answer-key.md (committed before any run).
#
# Usage: replay.sh <case> <outdir>     one case (97 49 41 56 43 40 99 95); <outdir>/case-<case> must not exist
#        replay.sh --all <outdir>      every case, two at a time; every case runs even after a failed one
# Per case: a `spec` and a `quality` call (sequential, as the gate rules' call shape), rendered from
# mcp-codex-dev@1.0.1's templates with the kit's additionalContext and run as that server runs them
# (`codex exec - --json --sandbox workspace-write -c approval_policy=on-request`, cwd the clone); then the
# risk pass through the skill's risk-pass.sh when a forcing path of spec §6 is in the range.
# Each call has a 1200 s watchdog that kills its process group. The clone lives under a mktemp -d directory,
# removed on every exit. Exit: 0 every call finished, 1 a call failed or timed out, 2 bad arguments.
set -u

die() { printf 'replay.sh: %s\n' "$1" >&2; exit "${2:-2}"; }
here=$(cd "$(dirname "$0")" && pwd) || die 'cannot find the script directory'
kit=$(git -C "$here" rev-parse --show-toplevel) || die 'not inside the kit repository'
tpl_dir=${MCP_CODEX_DEV_TEMPLATES:-}
limit=1200

# PR, pre-fix head, base (the PR's merge-base), fix commit (must be absent from the clone)
cases='97 8f0cd823339df40977b512bd188d5ff12bf71a24 a56ef4455c3c3381e5fdb05fd2e3c3afb25b82ca 8a3baca
49 00faea5e081f8aefd37609f4e21df0b6877fc896 62ebb90992ec5dda61349371cb47ee90e55efea2 cb5068f
41 97471fb7cdf9ec3d3f29d4a5c8ed7d9d6367a0ba 70bb54e99df52626e1edc70e65746093b3d23de9 ebf124b
56 2230d90308615c5f8ba157a7ad359877b95bac8e 860e56cf69a0cdd921e40f394ca4fbba62d9322e 36b5857
43 9071b91c89bd6b44da3b0e9c3c877f12a574f9d1 62931c35d49234b41185180ec51a8093c233aa69 f8f9d18
40 4972cb18c6bb42c058169eb566fa59a2c7ae87a2 b18e7db386a20efe0e751111e241a6b88eceb9d6 2164624
99 14d5b3c1f9bfda4bec887c8ad3faad8e53390e01 2a5a4d06e35143f43c04db538a27d145cddd5cf5 e109a49
95 770e7e56ec2bd68913ba19fbf6f0465855ca5659 405738de006e5295443cc938cc3992f6b1a5b04e f61955a'

[ $# -eq 2 ] || die 'usage: replay.sh <case>|--all <outdir>'
case $2 in /*) out=$2 ;; *) out=$PWD/$2 ;; esac
mkdir -p "$out" || die "cannot create $out"

if [ "$1" = --all ]; then
  rc=0
  for pair in '97 49' '41 56' '43 40' '99 95'; do
    # shellcheck disable=SC2086  # split the pair on purpose
    set -- $pair
    sh "$0" "$1" "$out" > "$out/driver-$1.log" 2>&1 & p1=$!
    sh "$0" "$2" "$out" > "$out/driver-$2.log" 2>&1 & p2=$!
    wait "$p1" || rc=1
    wait "$p2" || rc=1
  done
  exit "$rc"
fi

pr=$1
line=$(printf '%s\n' "$cases" | awk -v p="$pr" '$1 == p')
[ -n "$line" ] || die "unknown case $pr"
# shellcheck disable=SC2086  # split the table row on purpose
set -- $line
head=$2; base=$3; fix=$4
[ -n "$tpl_dir" ] || die 'set MCP_CODEX_DEV_TEMPLATES to mcp-codex-dev@1.0.1/templates'
grep -q '"version": "1.0.1"' "$tpl_dir/../package.json" 2>/dev/null || die "$tpl_dir is not mcp-codex-dev 1.0.1"
co="$out/case-$pr"
[ -e "$co" ] && die "$co exists; a rerun goes to a new outdir"
mkdir "$co" || die "cannot create $co"

work=
# shellcheck disable=SC2329  # run by the EXIT trap
cleanup() { [ -n "$work" ] && rm -rf "$work"; }
trap cleanup EXIT
trap 'exit 1' HUP INT TERM
work=$(mktemp -d "${TMPDIR:-/tmp}/k051-replay.XXXXXX") || die 'mktemp failed' 1
clone="$work/repo"

# A copy holding only the pre-fix head's history: the old heads are reachable from no branch any more
# (squash merges), so a clone would not carry them; a fresh repository fetches the one SHA (objects copied,
# no alternates), then FETCH_HEAD (it names the source path) and the reflog go. No remote, no ref.
{ git init --quiet "$clone" &&
  git -C "$clone" fetch --quiet --no-tags --upload-pack='git -c uploadpack.allowAnySHA1InWant=true upload-pack' "$kit" "$head" &&
  git -C "$clone" checkout --quiet --detach "$head" &&
  rm -f "$clone/.git/FETCH_HEAD" &&
  git -C "$clone" reflog expire --expire=now --all &&
  git -C "$clone" gc --quiet --prune=now; } || die 'clone setup failed' 1
[ -z "$(git -C "$clone" for-each-ref)" ] || die 'clone holds refs' 1
git -C "$clone" cat-file -e "$fix^{commit}" 2>/dev/null && die "fix $fix is still in the clone" 1
[ "$(git -C "$clone" rev-list --all | wc -l)" -eq "$(git -C "$clone" rev-list HEAD | wc -l)" ] || die 'clone holds commits beyond HEAD' 1
git -C "$clone" cat-file -e "$base^{commit}" || die "base $base missing from the clone" 1
if ! { mkdir -p "$clone/.agents/skills" "$clone/.context/codex-reviews" &&
  cp -R "$kit/.agents/skills/gate-b-review" "$clone/.agents/skills/"; }; then die "skill copy failed" 1; fi

nonce="k051rp$pr"
docs=$(git -C "$clone" diff --name-only "$base..$head" -- 'docs/superpowers/stories' 'docs/superpowers/specs' 'docs/superpowers/plans' | sed 's/^/- /')
instruction="Review the change of pull request #$pr (range $base..$head) against the story and spec it cites and against AGENTS.md.
Story, spec and plan files changed in the range:
${docs:-- none in the range; check the change against AGENTS.md and the documents its commits cite}"
implemented=$(git -C "$clone" log --reverse --format='- %s' "$base..$head")

render() { # <template> <slot>
  f=".context/codex-reviews/gate-b-$2-$nonce-pass-1.md"
  perl -0pe '
    BEGIN { ($t, $w, $b, $h) = @ENV{qw(R_TASK R_IMPL R_BASE R_HEAD)} }
    s/\{TASK_SECTION\}/$t/g; s/\{WHAT_WAS_IMPLEMENTED\}/$w/g; s/\{BASE_SHA\}/$b/g; s/\{HEAD_SHA\}/$h/g' "$1"
  cat <<EOF


## Additional Context

Gate B pass 1, cycle $nonce, branch \`$2\`, gate mode \`strict\`. Follow the skill at
.agents/skills/gate-b-review/SKILL.md, branch \`$2\` (method, AGENTS.md, finding rules).
Battery evidence for this head: none — the quality command was not run on this head; judge the tests by reading
them, or run targeted ones as the skill allows.
Work only inside this repository: no network, no \`gh\`, no reads of paths outside it.
Findings file: $f
Write the findings file yourself, in exactly this format:
One finding per line: \`SEVERITY | confidence | location | problem | consequence | suggested fix\`; escape a literal pipe as \`\\|\`.
Severity is one of exactly: BLOCKER | MAJOR | MINOR | NIT.
Every line before the terminator is one finding line — no blank lines, headings, prose or wrapped continuations.
The last line reads exactly \`END OF FINDINGS (<n> total)\`, \`<n>\` the number of finding lines.
A clean findings file is the single body line \`NO FINDINGS\` with \`END OF FINDINGS (0 total)\`.
Write nothing else in the repository except that file and its \`-evidence.md\` beside it.
EOF
}

rc=0
cli=$(codex --version 2>/dev/null | head -n 1)
printf 'case %s head %s base %s cli %s model-config %s\n' "$pr" "$head" "$base" "$cli" \
  "$(sed -n 's/^model = "\(.*\)"$/\1/p' "${CODEX_HOME:-$HOME/.codex}/config.toml" | head -n 1)" > "$co/run.txt"

call() { # <slot> <template>
  R_TASK=$instruction R_IMPL=$implemented R_BASE=$base R_HEAD=$head render "$2" "$1" > "$co/$1-prompt.md"
  t0=$(date +%s)
  ( cd "$clone" && exec perl -e 'setpgrp(0,0) or die "setpgrp: $!\n"; exec { $ARGV[0] } @ARGV or die "exec: $!\n"' -- \
      codex exec - --json --sandbox workspace-write -c approval_policy=on-request -o "$co/$1-reply.md" ) \
    < "$co/$1-prompt.md" > "$co/$1.events.jsonl" 2> "$co/$1.stderr" &
  cp=$!
  perl -e 'setpgrp(0,0); sleep $ARGV[0]; open(my $f, ">", $ARGV[2]); close $f;
           kill "TERM", -$ARGV[1]; sleep 5; kill "KILL", -$ARGV[1];' "$limit" "$cp" "$work/timeout-$1" \
    </dev/null >/dev/null 2>&1 &
  wp=$!
  wait "$cp"; c=$?
  perl -e 'kill "KILL", -$ARGV[0]' "$wp" 2>/dev/null; { wait "$wp"; } 2>/dev/null
  perl -e 'kill "TERM", -$ARGV[0]' "$cp" 2>/dev/null
  [ -f "$work/timeout-$1" ] && c=timeout
  printf 'call %s exit %s secs %s\n' "$1" "$c" "$(( $(date +%s) - t0 ))" >> "$co/run.txt"
  [ "$c" = 0 ] || rc=1
}

call spec "$tpl_dir/spec-reviewer.md"
call quality "$tpl_dir/code-reviewer.md"

# Spec §6's forcing paths; the content judgement for ranges without one is recorded in answer-key.md.
risk=none
for p in $(git -C "$clone" diff --name-only "$base..$head"); do
  case $p in
    scripts/*|bin/*|*.sh|hooks/*|*/hooks/*|.github/workflows/*|CLAUDE.md|AGENTS.md|.claude/*|.agents/*|.mcp.json|\
    plugins/*|*/plugins/*|skills/*|*/skills/*|commands/*|*/commands/*|agents/*|*/agents/*|*migrations/*|*migrate*) risk=forced ;;
  esac
done
printf 'risk %s\n' "$risk" >> "$co/run.txt"
if [ "$risk" = forced ]; then
  st="$clone/.context/codex-reviews/gate-b-cycle-$nonce.state"
  # Codex ran in the clone: a planted link must not redirect this write (noclobber after removing it).
  { [ ! -L "$clone/.context" ] && [ ! -L "$clone/.context/codex-reviews" ] && rm -f "$st" &&
    ( set -C; printf 'base %s\n' "$base" > "$st" ); } || die 'cannot write the cycle state file safely' 1
  t0=$(date +%s)
  # The trusted copy runs: Codex can write in the clone, and this script has the user's full rights.
  diff -r "$kit/.agents/skills/gate-b-review" "$clone/.agents/skills/gate-b-review" > "$co/skill-diff.txt" 2>&1 ||
    printf 'skill copy changed before the risk pass (see skill-diff.txt)\n' >> "$co/run.txt"
  sh "$kit/.agents/skills/gate-b-review/scripts/risk-pass.sh" "$clone" "$base" "$head" "$nonce" 2 "$limit" \
    > "$co/risk.stdout" 2> "$co/risk.stderr"; c=$?
  printf 'call risk exit %s secs %s\n' "$c" "$(( $(date +%s) - t0 ))" >> "$co/run.txt"
  [ "$c" = 0 ] || rc=1
fi

mkdir "$co/codex-reviews" && cp -P "$clone/.context/codex-reviews/"*"$nonce"* "$co/codex-reviews/" || rc=1
git -C "$clone" status --porcelain --untracked-files=all > "$co/clone-status.txt"

# Contamination audit (spec §8): every command each call ran, and the ones that reach outside the clone.
for ev in "$co"/*.events.jsonl "$co"/codex-reviews/*.events.jsonl; do
  [ -f "$ev" ] || continue
  n=$(jq -c 'select(.type == "item.completed")' "$ev" 2>/dev/null | wc -l)
  [ "$n" -gt 0 ] || { printf 'UNVERIFIED %s (no readable events)\n' "$ev"; continue; }
  jq -r 'select(.type == "item.completed" and .item.type == "command_execution") | .item.command' "$ev" |
    grep -nE '(^|[^a-z])(gh|curl|wget|nc|ssh)( |$)|git (fetch|pull|clone|remote|ls-remote)|https?://|/Users/|kit-051|DEVELOPMENT/APPS|replays/2026-10-30|answer-key|report\.md|factory-review|\.\./' |
    sed "s|^|FLAG $(basename "$ev"):|"
done > "$co/audit.txt"
printf 'audit flags %s\n' "$(wc -l < "$co/audit.txt" | tr -d ' ')" >> "$co/run.txt"
exit "$rc"
