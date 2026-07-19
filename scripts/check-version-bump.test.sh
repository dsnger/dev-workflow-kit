#!/bin/sh
# Regression suite for check-version-bump.sh.
#
# The checker is a CI gate, so what matters is not that it passes on a clean tree — it
# is that it FAILS on each violation it claims to catch, does not fail on the legitimate
# shapes next door, and fails CLOSED whenever git itself misbehaves. Three groups:
#
#   policy:      reaches the version comparison and rejects
#   operational: fails closed before any comparison (bad input, broken git, bad manifest)
#   accept:      must stay green
#
# The grouping is not cosmetic. The mutation check for this suite — replace the version
# comparison with `false` — must make exactly the policy rows fail and leave every
# operational and accept row green. Mixed groups would hide an ineffective mutation.
set -u

CHECKER="$(cd "$(dirname "$0")" && pwd)/check-version-bump.sh"
pass_n=0; fail_n=0
pass() { pass_n=$((pass_n + 1)); printf 'ok   - %s\n' "$1"; }
fail() { fail_n=$((fail_n + 1)); printf 'FAIL - %s\n' "$1"; }

work=$(mktemp -d) || work=''
# Abort rather than continue with an empty $work: every path below is built as
# "$work/r", so an empty value turns the fixture reset into `rm -rf /r`.
if [ -z "$work" ] || [ ! -d "$work" ]; then
  printf 'FAIL - could not create a temporary directory; refusing to run\n' >&2
  exit 1
fi
trap 'rm -rf "$work"' EXIT

MANIFEST=.claude-plugin/plugin.json

# Identity is passed per-invocation rather than written to config: the suite must not
# depend on, or touch, the developer's global git identity.
gitc() { git -c user.name=t -c user.email=t@example.com -c commit.gpgsign=false "$@"; }

# A repo with `main` holding one plugin at 0.4.0, and a `feature` branch checked out.
# Every fixture starts here and then diverges.
mkrepo() {
  rm -rf "${work:?}/r"; mkdir -p "$work/r/scripts"
  cp "$CHECKER" "$work/r/scripts/"
  (
    cd "$work/r" || exit 1
    gitc init -q -b main .
    mkdir -p "plugins/alpha/$(dirname $MANIFEST)" plugins/alpha/skills
    printf '{"name": "alpha", "version": "0.4.0"}\n' > "plugins/alpha/$MANIFEST"
    printf 'first\n' > plugins/alpha/skills/s.md
    printf 'readme\n' > README.md
    gitc add -A && gitc commit -qm base
    gitc checkout -qb feature
  )
}

run() { ( cd "$work/r" && sh scripts/check-version-bump.sh "$@" 2>&1 ); }

# A rejection must fire for the RIGHT reason: accepting any non-zero exit lets a case
# pass on an unrelated violation. Every reject names at least one expected substring,
# and ALL of them must appear — P4 relies on this to prove that both offenders are
# printed, which a single-pattern contract could not distinguish from a first-failure
# implementation that names only one.
expect_reject() { # $1 = name, $2 = base ref, then one or more required substrings
  er_name=$1; er_ref=$2; shift 2
  er_out=$(run "$er_ref"); er_st=$?
  if [ "$er_st" -eq 0 ]; then fail "$er_name (exited 0)"; return; fi
  for er_pat in "$@"; do
    if ! printf '%s' "$er_out" | grep -q "$er_pat"; then
      fail "$er_name (missing '$er_pat' in: $(printf '%s' "$er_out" | tr '\n' ' '))"
      return
    fi
  done
  pass "$er_name"
}

expect_accept() { # $1 = name, $2 = base ref
  ea_out=$(run "$2"); ea_st=$?
  if [ "$ea_st" -eq 0 ]; then pass "$1"
  else fail "$1 ($(printf '%s' "$ea_out" | tr '\n' ' '))"; fi
}

# A `git` earlier on PATH that fails ONE exact invocation and delegates everything else.
# Matching the full argument vector matters: enumeration and both presence lookups are
# all `ls-tree`, so a subcommand-only wrapper would trip on the first one and the later
# branches would never be reached while the suite still went green.
with_failing_git() { # $1 = glob matched against "$*", $2 = name, $3 = expected substring
  mkdir -p "$work/bin"
  real_git=$(command -v git)
  cat > "$work/bin/git" <<EOF
#!/bin/sh
case "\$*" in
  $1) printf 'simulated git failure\n' >&2; exit 128 ;;
esac
exec "$real_git" "\$@"
EOF
  chmod +x "$work/bin/git"
  wfg_out=$( cd "$work/r" && PATH="$work/bin:$PATH" sh scripts/check-version-bump.sh main 2>&1 )
  wfg_st=$?
  rm -rf "${work:?}/bin"
  if [ "$wfg_st" -eq 0 ]; then fail "$2 (exited 0 despite a failing git)"
  elif ! printf '%s' "$wfg_out" | grep -q "$3"; then
    fail "$2 (wrong diagnostic: $(printf '%s' "$wfg_out" | tr '\n' ' '))"
  else pass "$2"; fi
}

bump() { # $1 = version, $2 = plugin dir name (default alpha)
  printf '{"name": "%s", "version": "%s"}\n' "${2:-alpha}" "$1" \
    > "$work/r/plugins/${2:-alpha}/$MANIFEST"
}

commit_all() { ( cd "$work/r" && gitc add -A && gitc commit -qm "$1" ); }

printf '\n--- policy rejects ---\n'

# P1 — the case the check exists for.
mkrepo
printf 'changed\n' >> "$work/r/plugins/alpha/skills/s.md"
commit_all p1
expect_reject "P1 plugin file changed, version unchanged" main "plugins/alpha" "0.4.0"

# P2 — pins the scope decision: examples/ ships in the package, so it is in scope.
mkrepo
mkdir -p "$work/r/plugins/alpha/examples"
printf 'example\n' > "$work/r/plugins/alpha/examples/demo.md"
commit_all p2
expect_reject "P2 examples/ changed, version unchanged" main "plugins/alpha"

# P3/P4 — two plugins. P4 is the accumulation proof: a first-failure implementation
# passes P3 and fails P4.
mkrepo
mkdir -p "$work/r/plugins/beta/.claude-plugin"
printf '{"name": "beta", "version": "1.0.0"}\n' > "$work/r/plugins/beta/$MANIFEST"
commit_all seed-beta
( cd "$work/r" && gitc checkout -q main && gitc merge -q feature && gitc checkout -q feature )
printf 'x\n' >> "$work/r/plugins/alpha/skills/s.md"
printf 'y\n' > "$work/r/plugins/beta/note.md"
bump 0.5.0 alpha
commit_all p3
expect_reject "P3 two plugins changed, only one bumped" main "plugins/beta"

mkrepo
mkdir -p "$work/r/plugins/beta/.claude-plugin"
printf '{"name": "beta", "version": "1.0.0"}\n' > "$work/r/plugins/beta/$MANIFEST"
commit_all seed-beta
( cd "$work/r" && gitc checkout -q main && gitc merge -q feature && gitc checkout -q feature )
printf 'x\n' >> "$work/r/plugins/alpha/skills/s.md"
printf 'y\n' > "$work/r/plugins/beta/note.md"
commit_all p4
expect_reject "P4 two plugins changed, neither bumped: BOTH named" main \
  "plugins/alpha" "plugins/beta"

# P7 — the comparison is on the value, not on the matched fragment. Without the
# normalization, a reformat reads as a bump.
mkrepo
printf 'changed\n' >> "$work/r/plugins/alpha/skills/s.md"
printf '{"name": "alpha","version":"0.4.0"}\n' > "$work/r/plugins/alpha/$MANIFEST"
commit_all p7
expect_reject "P7 manifest reformatted, version value identical" main "plugins/alpha"

# P8 — versions are read from commits: an uncommitted bump must not launder a committed
# un-bumped change.
mkrepo
printf 'changed\n' >> "$work/r/plugins/alpha/skills/s.md"
commit_all p8
bump 0.5.0   # working tree only, deliberately not committed
expect_reject "P8 bump present only in the working tree" main "plugins/alpha"

# P9 — enumeration comes from HEAD's tree, not a filesystem glob, so a dirty local
# deletion cannot hide a committed change.
mkrepo
printf 'changed\n' >> "$work/r/plugins/alpha/skills/s.md"
commit_all p9
rm -rf "$work/r/plugins/alpha"
expect_reject "P9 plugin directory deleted in the working tree only" main "plugins/alpha"

# P10 — the checker anchors itself at the repo root; a run from a subdirectory must not
# quietly enumerate nothing.
mkrepo
printf 'changed\n' >> "$work/r/plugins/alpha/skills/s.md"
commit_all p10
p10_out=$( cd "$work/r/scripts" && sh ./check-version-bump.sh main 2>&1 ); p10_st=$?
if [ "$p10_st" -eq 0 ]; then fail "P10 run from a subdirectory (exited 0)"
elif ! printf '%s' "$p10_out" | grep -q "plugins/alpha"; then
  fail "P10 run from a subdirectory (wrong diagnostic: $(printf '%s' "$p10_out" | tr '\n' ' '))"
else pass "P10 run from a subdirectory still rejects"; fi

printf '\n--- operational rejects (fail closed) ---\n'

mkrepo
printf 'changed\n' >> "$work/r/plugins/alpha/skills/s.md"
commit_all o1
expect_reject "O1 base ref does not resolve" no-such-ref "no merge-base"

# O2 — a ref that resolves but shares no history. Built with commit-tree rather than
# `checkout --orphan`: an orphan checkout leaves the whole tree untracked, and switching
# back then aborts on "untracked files would be overwritten". This touches no worktree.
mkrepo
( cd "$work/r" &&
  o2_tree=$(gitc mktree < /dev/null) &&
  o2_commit=$(printf 'orphan\n' | gitc commit-tree "$o2_tree") &&
  gitc branch unrelated "$o2_commit" )
printf 'changed\n' >> "$work/r/plugins/alpha/skills/s.md"
commit_all o2
expect_reject "O2 unrelated histories, no merge-base" unrelated "no merge-base"

mkrepo
printf 'changed\n' >> "$work/r/plugins/alpha/skills/s.md"
printf '{"name": "alpha"}\n' > "$work/r/plugins/alpha/$MANIFEST"
commit_all o3
expect_reject "O3 HEAD manifest has no version field" main "found 0"

mkrepo
printf 'changed\n' >> "$work/r/plugins/alpha/skills/s.md"
printf '{"version": "0.5.0", "nested": {"version": "9.9.9"}}\n' > "$work/r/plugins/alpha/$MANIFEST"
commit_all o4
expect_reject "O4 HEAD manifest has two version matches" main "found 2"

# O5/O6 — the same two malformations on the BASE side. The exactly-one rule applies to
# both manifests, and only testing HEAD would leave half of it unpinned.
mkrepo
( cd "$work/r" && gitc checkout -q main )
printf '{"name": "alpha"}\n' > "$work/r/plugins/alpha/$MANIFEST"
commit_all o5-base
( cd "$work/r" && gitc checkout -q feature && gitc rebase -q main >/dev/null 2>&1 || true )
printf 'changed\n' >> "$work/r/plugins/alpha/skills/s.md"
bump 0.5.0
commit_all o5
expect_reject "O5 merge-base manifest has no version field" main "found 0"

mkrepo
( cd "$work/r" && gitc checkout -q main )
printf '{"version": "0.4.0", "nested": {"version": "1.1.1"}}\n' > "$work/r/plugins/alpha/$MANIFEST"
commit_all o6-base
( cd "$work/r" && gitc checkout -q feature && gitc rebase -q main >/dev/null 2>&1 || true )
printf 'changed\n' >> "$work/r/plugins/alpha/skills/s.md"
bump 0.5.0
commit_all o6
expect_reject "O6 merge-base manifest has two version matches" main "found 2"

# O7-O13 — git itself failing, one row per load-bearing call. Each pattern matches the
# FULL argv, so the intended call fails and not an earlier one that shares a subcommand.
mkrepo
printf 'changed\n' >> "$work/r/plugins/alpha/skills/s.md"
commit_all o7
with_failing_git '*merge-base*'            "O7 merge-base resolution fails"        "no merge-base"
with_failing_git '*ls-tree*-d*--name-only*' "O8 plugin directory enumeration fails" "ls-tree of plugins/"
with_failing_git '*diff*--quiet*'          "O9 change detection fails"             "git diff of"
with_failing_git '*ls-tree*HEAD*plugin.json*' "O10 HEAD manifest presence lookup fails" "ls-tree HEAD"
with_failing_git '*show*HEAD:*'            "O11 HEAD manifest read fails"          "git show HEAD:"

# O12 needs the base-side lookups to be reached, which means a bumped HEAD.
mkrepo
printf 'changed\n' >> "$work/r/plugins/alpha/skills/s.md"
bump 0.5.0
commit_all o12
mb_sha=$( cd "$work/r" && gitc merge-base main HEAD )
with_failing_git "*ls-tree*$mb_sha*plugin.json*" "O12 base manifest presence lookup fails" "ls-tree $mb_sha"
with_failing_git "*show*$mb_sha:*"               "O13 base manifest read fails"            "git show $mb_sha:"

# O14/O15 — the CLI contract is exit 2, asserted rather than described.
mkrepo
o14_out=$( cd "$work/r" && sh scripts/check-version-bump.sh 2>&1 ); o14_st=$?
if [ "$o14_st" -eq 2 ] && printf '%s' "$o14_out" | grep -q usage; then
  pass "O14 no argument: usage, exit 2"
else fail "O14 no argument (status $o14_st: $(printf '%s' "$o14_out" | tr '\n' ' '))"; fi

o15_out=$( cd "$work/r" && sh scripts/check-version-bump.sh main extra 2>&1 ); o15_st=$?
if [ "$o15_st" -eq 2 ] && printf '%s' "$o15_out" | grep -q usage; then
  pass "O15 two arguments: usage, exit 2"
else fail "O15 two arguments (status $o15_st: $(printf '%s' "$o15_out" | tr '\n' ' '))"; fi

# O15b — an escaped value parses equal to the base but spells differently, which would
# otherwise read as a bump.
mkrepo
printf 'changed\n' >> "$work/r/plugins/alpha/skills/s.md"
printf '{"name": "alpha", "version": "0.4.\\u0030"}\n' > "$work/r/plugins/alpha/$MANIFEST"
commit_all o15b
expect_reject "O15b version value carries a backslash escape" main "backslash escape"

# O18 — the directory survives and its content still ships, but there is no manifest and
# so no version to key on. Carved out at first ("nothing to bump"); Gate B pushed back
# twice, and rightly: full-directory deletion is out of scope, a shipped plugin with no
# manifest is a defect. A5 stays accepted, which is the asymmetry made visible.
mkrepo
rm -f "$work/r/plugins/alpha/$MANIFEST"
# Nothing else is touched: deleting the manifest is itself a change under plugins/alpha/,
# and the pre-existing skills file keeps the directory present at HEAD. Editing a second
# file here would let a regression that ignores manifest-only changes keep this row green.
commit_all o18
expect_reject "O18 manifest alone deleted, directory and its content remain" main \
  "no version to key on"

# O16/O17 — names the loop cannot round-trip. O16 (a space) is rejected by the grammar
# but is NOT quoted by git; O17 is, and it is the row that pins the silent-skip
# regression the grammar exists to prevent.
mkrepo
mkdir -p "$work/r/plugins/bad name/.claude-plugin"
printf '{"name": "bad", "version": "1.0.0"}\n' > "$work/r/plugins/bad name/$MANIFEST"
commit_all o16
expect_reject "O16 plugin directory name with a space" main "outside \[A-Za-z0-9._-\]"

mkrepo
mkdir -p "$work/r/plugins/bad$(printf '\t')tab/.claude-plugin"
printf '{"name": "bad", "version": "1.0.0"}\n' > "$work/r/plugins/bad$(printf '\t')tab/$MANIFEST"
commit_all o17
expect_reject "O17 plugin directory name git C-quotes (tab)" main "outside \[A-Za-z0-9._-\]"

printf '\n--- accepts ---\n'

mkrepo
printf 'changed\n' >> "$work/r/plugins/alpha/skills/s.md"
bump 0.5.0
commit_all a1
expect_accept "A1 plugin changed and bumped" main

mkrepo
printf 'docs\n' >> "$work/r/README.md"
commit_all a2
expect_accept "A2 nothing under plugins/ changed" main

mkrepo
bump 0.5.0
commit_all a3
expect_accept "A3 bump-only change" main

mkrepo
mkdir -p "$work/r/plugins/gamma/.claude-plugin"
printf '{"name": "gamma", "version": "0.1.0"}\n' > "$work/r/plugins/gamma/$MANIFEST"
commit_all a4
expect_accept "A4 newly added plugin (no manifest at the merge-base)" main

mkrepo
rm -rf "$work/r/plugins/alpha"
commit_all a5
expect_accept "A5 plugin directory deleted at HEAD" main


mkrepo
mkdir -p "$work/r/plugins/beta/.claude-plugin"
printf '{"name": "beta", "version": "1.0.0"}\n' > "$work/r/plugins/beta/$MANIFEST"
commit_all seed-beta
( cd "$work/r" && gitc checkout -q main && gitc merge -q feature && gitc checkout -q feature )
printf 'x\n' >> "$work/r/plugins/alpha/skills/s.md"
printf 'y\n' > "$work/r/plugins/beta/note.md"
bump 0.5.0 alpha
bump 1.1.0 beta
commit_all a7
expect_accept "A7 two plugins changed, both bumped" main

# A8 — pins the documented "direction is not checked" limitation as tested behaviour.
mkrepo
printf 'changed\n' >> "$work/r/plugins/alpha/skills/s.md"
bump 0.3.9
commit_all a8
expect_accept "A8 version decreased (direction is not checked)" main

# A9 — a rename is a gap in DETECTION only; renamed-and-bumped must not be rejected.
mkrepo
( cd "$work/r" && gitc mv plugins/alpha plugins/alpha-renamed )
bump 0.5.0 alpha-renamed
commit_all a9
expect_accept "A9 plugin directory renamed with a bump" main

# A10 — a blob directly under plugins/. The spaced name is deliberate: with a
# grammar-conforming name, an implementation missing `ls-tree -d` would enumerate the
# blob, append `/`, diff a path that does not exist, report unchanged and pass anyway.
mkrepo
printf 'notes\n' > "$work/r/plugins/release notes.md"
commit_all a10
expect_accept "A10 non-directory entry under plugins/ is ignored" main

printf '\n---\n'
if [ "$fail_n" -eq 0 ]; then printf 'all passed (%s assertions)\n' "$pass_n"; else
  printf '%s passed, %s FAILED\n' "$pass_n" "$fail_n"; exit 1
fi
