#!/bin/sh
# Local CI: run the quality battery of one commit in a temporary detached worktree and post the
# result to GitHub as that commit's `quality` status.
# From the dev-workflow kit, which ships it to projects as `/workflow-init` 2.22 (the same bytes);
# its regression suite is the kit's scripts/local-ci.test.sh.
#
# Usage: sh scripts/local-ci.sh [--from <green>] [<commit>]
#        sh scripts/local-ci.sh --lane <base> [<commit>]
#   <commit>  any commit-ish (default HEAD) of the repository containing the current directory
#   <green>   a commit whose `quality` commit status is success (for example the PR's last checked head)
#   --lane    (0.52) prints `light` or `full`: the lane the change <base>..<commit> takes by the light-lane
#             rule below, with <base> as the lane base. Runs precondition 1 only and reads only the
#             quality-light row (none: full); no gh, no lock, no reminder, no worktree, no post. Exit 0, or
#             64 when <base> or <commit> does not resolve. The Actions job calls it to pick its lane.
#
# LANES (0.50; this header is the contract, the kit's docs point here). Every lane posts context
# `quality`; the first that applies is taken:
#   same tree   --from given and its tree equals <commit>'s (a squash-merge of that head): posts success
#               "inherited green from <green12>: same tree"; nothing runs.
#   records     --from given and every path changed since it is under .context/ or is todos.md (a
#               closing commit): posts success "inherited green from <green12>: records only"; nothing runs.
#   light       AGENTS.md at <commit> has exactly one "| quality-light " row with one command in
#               backticks, and the change since the lane base (--from, else the merge-base with origin/main)
#               is docs or release only: every path is Markdown or text, or an image under docs/, never an
#               instruction path (CLAUDE.md, AGENTS.md, .claude/, plugins/, skills/, commands/, agents/,
#               hooks/), or a CHANGELOG*, or a package.json/composer.json whose only change is its top-level
#               "version" (compared with jq; no jq: not light), or a VERSION file or a file on AGENTS.md's
#               "**Version sites:**" line (read at the base) whose only change is one line holding just a
#               version or "version": "<version>"; one old and one new version across them. Runs that row
#               instead of the quality row; posts "light lane green|red: docs/release only, local run, ...".
#   full        otherwise: the quality row, as below. A project narrows the light lane only by its row:
#               without one, every change that does not inherit takes the full lane. Anything the check
#               does not recognise: full.
#   With --from, its status is read once (precondition 6); the lanes compare that resolved SHA only.
#
# PRECONDITIONS, in this order; a failure prints one line, exits 64 and posts nothing:
#   1. <commit> resolves to a commit; the script works on its full SHA from then on
#   2. origin's URL names a github.com repository (https://, ssh://git@ or git@ form); owner and
#      repository come from it alone, never from GH_REPO or GH_HOST
#   3. gh is on PATH and `gh auth status --hostname github.com` succeeds
#   4. when that commit's .github/workflows/ci.yml names koalaman/shellcheck:v<version>, every
#      such pin agrees, and it is the `version:` of `shellcheck --version`; a commit without that
#      file or without a pin skips this check
#   5. that commit's AGENTS.md has exactly one line starting with "| quality ", whose last cell is
#      one command in backticks; that text runs verbatim under `sh -c`
#   6. with --from: <green> resolves to a commit, and GET repos/<owner>/<repo>/commits/<sha>/status
#      ?per_page=100 (REST 2026-03-10; latest status per context) succeeds, lists at most 100
#      contexts and holds context quality with state success
#
# WHAT IT DOES: unsets the repository-selecting GIT_* variables first, so an inherited GIT_DIR
# cannot aim the run at another repository; adds a detached worktree of the SHA in a `mktemp -d`
# directory under TMPDIR (default /tmp; uncommitted changes never reach it); runs the quality
# command there in the foreground, output passed through; posts state success (exit 0) or failure
# (any other status), context quality and the description
# "battery green|red: local run, shellcheck <v>, claude <v>" (the shellcheck part only with a
# pin; claude "unknown" when its version cannot be read; "light lane" for "battery" in that lane) with `gh api`, REST API version 2026-03-10; prints the SHA, state and
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
# REMINDER (0.52): a run that posts (any lane, never --lane) prints one stderr line when
# scripts/ci-switch.sh's log in the main worktree (.context/ci-switch.log) last recorded a switch to
# local in an earlier UTC month: the Actions budget is renewed, and the command back to hosted. It
# reads the log only, so a switch made outside that script is not seen.
#
# WHAT IT DOES NOT: fetch (run `git fetch origin` first, so origin/main and a merge commit are current); push (an
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
# POSIX sh plus git and gh; jq only for the light lane's manifest comparison.
set -u
unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_COMMON_DIR GIT_OBJECT_DIRECTORY \
  GIT_ALTERNATE_OBJECT_DIRECTORIES GIT_NAMESPACE GIT_CEILING_DIRECTORIES

usage() { printf 'usage: sh scripts/local-ci.sh [--from <green> | --lane <base>] [<commit>]\n' >&2; exit 64; }
# refuse <condition; what to do>: one line on stderr and exit 64, before anything ran.
refuse() { printf 'local-ci: %s\n' "$1" >&2; exit 64; }

from='' lbase=''
if [ "${1-}" = --from ]; then [ $# -ge 2 ] || usage; from=$2; shift 2
elif [ "${1-}" = --lane ]; then [ $# -ge 2 ] && [ -n "$2" ] || usage; lbase=$2; shift 2; fi
[ $# -le 1 ] || usage
case ${1-} in -*) usage ;; esac
case $from$lbase in -*) usage ;; esac
rev=${1:-HEAD}

git rev-parse --show-toplevel >/dev/null 2>&1 ||
  refuse 'the current directory is not inside a git work tree; run it from the repository root'
sha=$(git rev-parse --verify -q "$rev^{commit}" 2>/dev/null) ||
  refuse "$rev does not name a commit here; pass a commit, branch or tag of this repository"
# --lane needs none of preconditions 2-4 and no quality row.
if [ -z "$lbase" ]; then
  url=$(git remote get-url origin 2>/dev/null)
  slug=$(printf '%s\n' "$url" | LC_ALL=C sed -n -E 's#^(https://|ssh://git@|git@)github\.com[:/]([A-Za-z0-9._-]+)/([A-Za-z0-9._-]+)$#\2/\3#p' | LC_ALL=C sed 's/\.git$//')
  [ -n "$slug" ] ||
    refuse 'origin is missing or not a github.com repository URL; point origin at https://github.com/<owner>/<repo>.git'
  command -v gh >/dev/null 2>&1 ||
    refuse 'gh is not on PATH; install the GitHub CLI, then run gh auth login --hostname github.com'
  gh auth status --hostname github.com >/dev/null 2>&1 ||
    refuse 'gh auth status --hostname github.com failed; run it to see why, then gh auth login --hostname github.com'
  # The distinct versions of every koalaman/shellcheck:v<version>: none skips the check (empty pin),
  # one passes (printed), more refuse.
  pin=$(git show "$sha:.github/workflows/ci.yml" 2>/dev/null | LC_ALL=C awk '
    { s = $0
      while (match(s, /koalaman\/shellcheck:v[A-Za-z0-9_.-]+/)) {
        v = substr(s, RSTART + 21, RLENGTH - 21); if (!(v in seen)) { seen[v] = 1; n++ }
        s = substr(s, RSTART + RLENGTH) } }
    END { if (n == 1) print v; exit (n > 1) }') ||
    refuse ".github/workflows/ci.yml at $sha pins more than one shellcheck version; pin one koalaman/shellcheck:v<version>"
  if [ -n "$pin" ]; then
    have=$(shellcheck --version 2>/dev/null | LC_ALL=C sed -n 's/^version: //p')
    [ "$have" = "$pin" ] ||
      refuse "local shellcheck is ${have:-missing}, ci.yml pins $pin; install shellcheck $pin"
  fi
fi
# row <label>: the last cell of AGENTS.md's one "| <label> " row at the commit, the text between its
# backticks; the label may hold backticks or \|. No such single row: status 1.
row() {
  git show "$sha:AGENTS.md" 2>/dev/null | LC_ALL=C awk -v p="| $1 " '
  index($0, p) == 1 { n++; row = $0 }
  END {
    if (n != 1) exit 1
    sub(/[ \t]*[|][ \t]*$/, "", row)
    cell = substr(row, match(row, /[|][^|]*$/) + 1)
    gsub(/^[ \t]+|[ \t]+$/, "", cell)
    if (cell !~ /^`[^`]*[^` \t][^`]*`$/) exit 1
    print substr(cell, 2, length(cell) - 2) }'
}
cmd=''
[ -n "$lbase" ] || cmd=$(row quality) ||
  refuse "AGENTS.md at $sha has no single quality row with one command in backticks as its last cell; keep exactly one \"| quality \" row"
light=$(row quality-light) || light=''
fsha=''
if [ -n "$from" ]; then
  fsha=$(git rev-parse --verify -q "$from^{commit}" 2>/dev/null) ||
    refuse "--from $from does not name a commit here; pass the green head's SHA"
  fstate=$(gh api --hostname github.com -H "X-GitHub-Api-Version: 2026-03-10" "repos/$slug/commits/$fsha/status?per_page=100" \
    --jq 'if .total_count > 100 then "too many contexts" else ([.statuses[] | select(.context == "quality") | .state] | first // "none") end' 2>/dev/null) ||
    fstate='a failed read'
  [ "$fstate" = success ] ||
    refuse "--from $fsha has no success quality status ($fstate); run the battery on it first"
fi
# Only a version-shaped first word goes into the public description, never a path or a name.
cv=$(claude --version 2>/dev/null | LC_ALL=C awk 'NR == 1 && $1 ~ /^[0-9][0-9A-Za-z.+-]*$/ { print $1 }')

# --- RELEASE-ONLY CHECK (0.50; the hook carries the same program, spec §2) --------------------
# release_only <docs mode: hook|light> <base> [<new>]: true when the diff base..new (no new: the
# index) names at least one file and every file is docs (by mode), a changelog, a manifest whose
# only change is its top-level "version", or a VERSION / AGENTS.md "Version sites" file whose only
# change is one version line; one old version and one new version across them. Anything the check
# does not recognise, any failure, no jq for a manifest: false.
release_only() {
  _m=$1 _b=$2 _n=${3-}
  _sites=$(git cat-file blob "$_b:AGENTS.md" 2>/dev/null | LC_ALL=C awk 'index($0, "**Version sites:**") == 1 {
    s = substr($0, 19); while (match(s, /`[^`]+`/)) { v = substr(s, RSTART + 1, RLENGTH - 2)
    if (v !~ /[ \t]/) printf "%s ", v; s = substr(s, RSTART + RLENGTH) } }')  # a path with a blank is never a site
  if [ -n "$_n" ]; then set -- "$_b" "$_n"; else set -- --cached "$_b"; fi
  _out=$(git -c core.quotePath=true -c diff.noprefix=false diff --no-color --no-ext-diff --no-textconv \
    --no-renames --no-relative --ignore-submodules=none --submodule=short --src-prefix=a/ --dst-prefix=b/ -U0 \
    "$@" 2>/dev/null) || return 1
  _out=$(printf '%s\n' "$_out" | sites=$_sites LC_ALL=C awk -v mode="$_m" '
    function prompt(p) { return p ~ /(^|\/)(CLAUDE|AGENTS)\.md$/ || p ~ /(^|\/)(\.claude|plugins|skills|commands|agents|hooks)\// }
    function docs(p) {
      if (prompt(p)) return 0
      if (mode == "hook") return p ~ /^docs\/.*\.md$/ || p ~ /^(README|MANIFEST|todos)\.md$/ || p ~ /^\.context\//
      return p ~ /\.(md|txt)$/ || p ~ /^docs\/.*\.(png|jpg|jpeg|gif|svg|webp)$/ }
    # vline <line>: the line with its version token replaced by X when it is a version form, else "".
    function vline(l,   s) {
      s = l; sub(/^[ \t]+/, "", s); sub(/[ \t]+$/, "", s)
      if (s ~ /^[0-9]+\.[0-9]+\.[0-9]+(-[0-9A-Za-z.]+)?$/ || s ~ /^"version"[ \t]*:[ \t]*"[0-9]+\.[0-9]+\.[0-9]+(-[0-9A-Za-z.]+)?",?$/) {
        match(l, /[0-9]+\.[0-9]+\.[0-9]+(-[0-9A-Za-z.]+)?/); tok = substr(l, RSTART, RLENGTH)
        return substr(l, 1, RSTART - 1) "X" substr(l, RSTART + RLENGTH) }
      return "" }
    function same(v, t) { if (v == "") { return t } else if (v != t) { bad = 1 } return v }
    function finish(   a, b, ta) {
      if (path == "" || kind != "V") return
      if (hunks != 1 || nrem != 1 || nadd != 1) { bad = 1; return }
      a = vline(rem); ta = tok; b = vline(add)
      if (a == "" || b == "" || a != b) { bad = 1; return }
      old = same(old, ta); new = same(new, tok) }
    BEGIN { n = split(ENVIRON["sites"], S, " "); for (i = 1; i <= n; i++) site[S[i]] = 1 }
    /^diff --git / {
      finish(); state = "h"; hunks = nrem = nadd = 0; kind = ""; path = ""
      l = substr($0, 12); L = length(l)
      if ((L - 1) % 2) { bad = 1; next }
      h = (L - 1) / 2; a = substr(l, 1, h); b = substr(l, h + 2)
      if (substr(a, 1, 2) != "a/" || substr(b, 1, 2) != "b/" || substr(a, 3) != substr(b, 3)) { bad = 1; next }
      path = substr(a, 3); files++; base = path; sub(/.*\//, "", base)
      if (path ~ /[ \t*?[]/) { bad = 1; next }  # a blank or glob character: the shell loop below would split it
      if (docs(path)) kind = "D"
      else if (prompt(path)) bad = 1
      else if (base ~ /^CHANGELOG/) kind = "C"
      else if (base == "package.json" || base == "composer.json") { kind = "R"; print "R " path }
      else if (base == "VERSION" || (path in site)) kind = "V"
      else bad = 1
      next }
    state == "h" && /^(old mode|new mode|similarity|rename|copy) / { bad = 1; next }
    state == "h" && /^(new file mode|deleted file mode) / { if (kind == "R" || $0 ~ /160000/) bad = 1; next }
    state == "h" && /^index / { if ($0 ~ /160000/) bad = 1; next }
    state == "h" && /^Binary files / { if (!(mode == "light" && kind == "D" && path ~ /^docs\/.*\.(png|jpg|jpeg|gif|svg|webp)$/)) bad = 1; next }
    state == "h" && /^(---|\+\+\+) / { next }
    /^@@ / { state = "u"; hunks++; next }
    state == "u" && /^-/ { nrem++; rem = substr($0, 2); next }
    state == "u" && /^\+/ { nadd++; add = substr($0, 2); next }
    state == "u" && /^\\/ { next }
    { bad = 1 }
    END { finish(); if (bad || !files) print "NO"; else print "OK " old " " new }')
  _last=$(printf '%s\n' "$_out" | sed '$!d')
  case $_last in OK*) ;; *) return 1 ;; esac
  _old=${_last#OK }; _new=${_old#* }; _old=${_old%% *}
  for _p in $(printf '%s\n' "$_out" | sed -n 's/^R //p'); do
    command -v jq >/dev/null 2>&1 || return 1
    _o=$(git cat-file blob "$_b:$_p" 2>/dev/null | jq -c -s 'if length == 1 and (.[0] | type) == "object" then .[0] else error("") end' 2>/dev/null) &&
      _w=$(git cat-file blob "$_n:$_p" 2>/dev/null | jq -c -s 'if length == 1 and (.[0] | type) == "object" then .[0] else error("") end' 2>/dev/null) &&
      _v=$(jq -n -r --argjson o "$_o" --argjson n "$_w" '
        if ($o | del(.version)) == ($n | del(.version)) and ($o.version | type) == "string" and ($n.version | type) == "string"
          and ([$o.version, $n.version] | all(test("\\A[0-9]+[.][0-9]+[.][0-9]+(-[0-9A-Za-z.]+)?\\z")))
        then "\($o.version) \($n.version)" else "NO" end' 2>/dev/null) || return 1
    _vo=${_v%% *} _vn=${_v#* }
    [ "$_v" != NO ] || return 1
    [ -z "$_old" ] || [ "$_old" = "$_vo" ] || return 1
    [ -z "$_new" ] || [ "$_new" = "$_vn" ] || return 1
    _old=$_vo _new=$_vn
  done
  [ "$_old" != "$_new" ] || [ -z "$_old" ]
}

if [ -n "$lbase" ]; then
  lb=$(git rev-parse --verify -q "$lbase^{commit}" 2>/dev/null) ||
    refuse "--lane $lbase does not name a commit here; pass the base branch or commit"
  if [ -n "$light" ] && release_only light "$lb" "$sha"; then echo light; else echo full; fi
  exit 0
fi
# The month reminder (0.52), from scripts/ci-switch.sh's log in the main worktree alone, a recorded
# state (no workflow read): its last switch went to local in an earlier UTC month.
rm_main=$(git worktree list --porcelain 2>/dev/null | sed -n '1s/^worktree //p')
rm_m=$(LC_ALL=C awk -F '\t' '$3 == "hosted" || $3 == "local" { l = $0 } END { print l }' "${rm_main:-.}/.context/ci-switch.log" 2>/dev/null |
  LC_ALL=C awk -F '\t' '$3 == "local" && $1 ~ /^[0-9][0-9][0-9][0-9]-[0-9][0-9]/ { print substr($1, 1, 7) }')
[ -z "$rm_m" ] || [ "$rm_m" = "$(date -u +%Y-%m)" ] ||
  printf 'ci-switch: a new month renews the Actions budget (last recorded switch to local: %s); back to hosted: sh scripts/ci-switch.sh hosted "budget renewed"\n' "$rm_m" >&2
lane=full
if [ -n "$fsha" ]; then
  if [ "$(git rev-parse "$fsha^{tree}")" = "$(git rev-parse "$sha^{tree}")" ]; then lane=same
  else
    names=$(git -c core.quotePath=true diff --name-only --no-renames --no-relative --ignore-submodules=none "$fsha" "$sha") ||
      refuse "could not list the paths changed since $fsha; see the git error above"
    [ -n "$names" ] && ! printf '%s\n' "$names" | LC_ALL=C grep -vqE '^(\.context/|todos\.md$)' && lane=records
  fi
fi
if [ "$lane" = full ] && [ -n "$light" ]; then
  lb=${fsha:-$(git merge-base "$sha" origin/main 2>/dev/null)}
  [ -n "$lb" ] && release_only light "$lb" "$sha" && lane=light
fi

# --- HEAVY LOCK (0.52, spec docs/superpowers/specs/2026-10-30-kit-052-hybrid-ci-design.md §4) ---
# The full lane's battery runs under an exclusive flock on the machine-wide heavy lock that other
# tools on this machine may share (sfx-factory's protocol): $SFX_HEAVY_LOCK when set, else
# $HOME/.cache/sfx-factory/heavy.lock when that directory exists, else no lock. SFX_HEAVY_HELD
# non-empty means a holder's own step runs this, so it takes no lock (waiting would deadlock).
hl=''
if [ "$lane" = full ] && [ -z "${SFX_HEAVY_HELD-}" ]; then
  if [ -n "${SFX_HEAVY_LOCK-}" ]; then hl=$SFX_HEAVY_LOCK
  elif [ -d "${HOME-}/.cache/sfx-factory" ]; then hl=$HOME/.cache/sfx-factory/heavy.lock; fi
fi
hw=${HEAVY_LOCK_WAIT_SECS-7200}
if [ -n "$hl" ]; then
  case $hl in /*[!/]) ;; *) refuse "SFX_HEAVY_LOCK must be an absolute path to a file, not '$hl'" ;; esac
  case $hw in ''|0*|*[!0-9]*) refuse "HEAVY_LOCK_WAIT_SECS must be a whole number of seconds from 1, not '$hw'" ;; esac
  [ "${#hw}" -le 9 ] || refuse "HEAVY_LOCK_WAIT_SECS must be a whole number of seconds from 1, not '$hw'"
  command -v perl >/dev/null 2>&1 || refuse "perl is not on PATH; the heavy lock $hl needs it"
fi
# The holder (macOS has no flock command). Arguments: lock path, wait seconds, refusal marker,
# worktree, command, "override" when the path came from SFX_HEAVY_LOCK. It walks from an anchor the
# factory also trusts ($HOME; for an override the lock's grandparent) into each directory below it
# by chdir, each one checked by lstat (a directory of this user without group or other write) and
# then matched by device and inode from inside, so a swapped entry is refused and a later rename
# cannot redirect the open; opens the file relative to that, O_NOFOLLOW, mode 0600 when created;
# waits once a second, printing who holds it at once and then once a minute; writes its note
# (pid, directory, since); runs the command in a process group of its own with SFX_HEAVY_HELD set;
# on HUP, INT or TERM, and at the end, stops that group (TERM, KILL after 5 s) before it exits and
# the lock goes. A refusal writes its line to the marker and exits 64. Limits: a SIGKILL of the
# holder releases the lock with the group still running; it does not join the factory's FIFO
# ticket queue, so a waiting run here can take the lock before a factory step that waited longer;
# it never touches <lock>.queue. LOCAL_CI_TEST_WALK_PAUSE (digits, a test seam) only says so on stderr
# and sleeps between a directory's check and its entry.
# shellcheck disable=SC2016  # perl source, not shell
HOLD='use strict; use warnings;
use Fcntl qw(O_RDWR O_CREAT O_NOFOLLOW O_NONBLOCK LOCK_EX LOCK_NB S_ISDIR S_ISREG);
use File::Basename qw(basename dirname); use POSIX qw(WNOHANG);
my ($lock, $wait, $mark, $wt, $cmd, $how) = @ARGV;
sub bail { if (open(my $m, ">", $mark)) { print $m "$_[0]\n"; close $m } exit 64 }
my $pause = $ENV{LOCAL_CI_TEST_WALK_PAUSE} // "0"; $pause = 0 unless $pause =~ /\A[0-9]{1,2}\z/;
my ($anchor, $file, @parts) = ($ENV{HOME}, "heavy.lock", ".cache", "sfx-factory");
($anchor, $file, @parts) = (dirname(dirname($lock)), basename($lock), basename(dirname($lock))) if $how eq "override";
chdir($anchor) or bail("cannot enter $anchor for the heavy lock $lock: $!");
for my $p (@parts) {
  my @l = lstat($p) or bail("the heavy lock directory $p under $anchor is missing: $!");
  S_ISDIR($l[2]) && $l[4] == $< && !($l[2] & 022)
    or bail("$p under $anchor must be a directory of this user without group or other write, not a link (heavy lock $lock)");
  if ($pause) { print STDERR "local-ci: test pause after checking $p\n"; sleep $pause }
  chdir($p) or bail("cannot enter $p for the heavy lock $lock: $!");
  my @c = stat(".");
  $c[0] == $l[0] && $c[1] == $l[1] or bail("$p under $anchor changed while it was checked (heavy lock $lock)");
  $anchor .= "/$p";
}
sysopen(my $fh, $file, O_RDWR | O_CREAT | O_NOFOLLOW | O_NONBLOCK, 0600) or bail("cannot open the heavy lock $lock: $!");
my @f = stat($fh);
S_ISREG($f[2]) && $f[4] == $< && !($f[2] & 022) or bail("the heavy lock $lock must be a regular file of this user without group or other write");
my ($t0, $said) = (time, undef);
until (flock($fh, LOCK_EX | LOCK_NB)) {
  bail("waited $wait s for the heavy lock $lock; red rather than hang (HEAVY_LOCK_WAIT_SECS)") if time - $t0 >= $wait;
  if (!defined $said || time - $said >= 60) {
    my $note = ""; sysseek($fh, 0, 0); sysread($fh, $note, 4096);
    my @w = ((split /\n/, $note), "?", "?");
    print STDERR "local-ci: waiting for the heavy lock $lock (pid $w[0] in $w[1])\n"; $said = time;
  }
  sleep 1;
}
my $note = "$$\n$wt\nlocal-ci since " . scalar(localtime) . "\n";
sysseek($fh, 0, 0); syswrite($fh, $note); truncate($fh, length $note);
my $got = 0;
$SIG{$_->[0]} = do { my $n = $_->[1]; sub { $got ||= $n } } for [HUP => 1], [INT => 2], [TERM => 15];
my $holder = $$;
my $kid = fork; defined $kid or bail("could not start the battery: $!");
if (!$kid) {
  $SIG{$_} = "DEFAULT" for qw(HUP INT TERM);
  setpgrp(0, 0); $ENV{SFX_HEAVY_HELD} = $holder;
  chdir($wt) or POSIX::_exit(127);
  exec("sh", "-c", $cmd) or POSIX::_exit(127);
}
setpgrp($kid, $kid);
my ($st, $done) = (0, 0);
sub stop { kill("TERM", -$kid); for (1 .. 50) { waitpid($kid, WNOHANG) == $kid and ($st, $done) = ($?, 1);
  return if !kill(0, -$kid); select(undef, undef, undef, 0.1) } kill("KILL", -$kid);
  for (1 .. 50) { waitpid($kid, WNOHANG) == $kid and ($st, $done) = ($?, 1); return if !kill(0, -$kid); select(undef, undef, undef, 0.1) } }
until ($done) {
  if (waitpid($kid, WNOHANG) == $kid) { ($st, $done) = ($?, 1); last }
  if ($got) { stop(); last }
  select(undef, undef, undef, 0.2);
}
stop() if kill(0, -$kid);
exit(128 + $got) if $got;
exit($st & 127 ? 128 + ($st & 127) : $st >> 8);'

# post <state> <description>: the one status post; exits with the run's status, 75 when the post fails.
post() {
  if gh api --hostname github.com --method POST -H "X-GitHub-Api-Version: 2026-03-10" "repos/$slug/statuses/$sha" \
    -f state="$1" -f context=quality -f description="$2" >/dev/null; then
    printf 'local-ci: posted quality=%s on %s: %s\n' "$1" "$sha" "$2"
    exit "$st"
  fi
  printf 'local-ci: post failed for quality=%s on %s; rerun after fixing gh\n' "$1" "$sha" >&2
  exit 75
}
st=0
case $lane in
  same) post success "inherited green from $(printf %.12s "$fsha"): same tree" ;;
  records) post success "inherited green from $(printf %.12s "$fsha"): records only" ;;
  light) cmd=$light ;;
esac

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

if [ -n "$hl" ]; then
  perl -e "$HOLD" "$hl" "$hw" "$tmp/lock.refused" "$tmp/wt" "$cmd" "${SFX_HEAVY_LOCK:+override}"
  st=$?
  [ ! -e "$tmp/lock.refused" ] || refuse "$(cat "$tmp/lock.refused")"
else
  (cd "$tmp/wt" && sh -c "$cmd")
  st=$?
fi

word=battery; [ "$lane" = light ] && word='light lane'
if [ "$st" -eq 0 ]; then state=success; desc="$word green"; else state=failure; desc="$word red"; fi
if [ "$lane" = light ]; then desc="$desc: docs/release only, local run"; else desc="$desc: local run"; fi
post "$state" "$desc,${pin:+ shellcheck $pin,} claude ${cv:-unknown}"
