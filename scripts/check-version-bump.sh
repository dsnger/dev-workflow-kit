#!/bin/sh
# A change under plugins/<name>/ must come with a version bump in that plugin's
# manifest — mechanically, on every pull request.
#
# An installed plugin lives under a version-keyed cache path, so a change that ships
# without a new version never reaches an installed copy: the machine keeps running the
# old code with no signal that it is stale. That happened twice here (a machine sat on
# 0.1.0 while main was at 0.4.0; the 0.4.0 bump itself had to be asked for during PR
# review), and main was ALREADY stale when this check was written — two commits had
# changed the plugin after 0.4.0 shipped. "Bump when you change the plugin" was a
# convention, and conventions are what this repo's hardening ledger is a list of.
#
# WHAT IT DOES NOT CATCH. It verifies that a bump is PRESENT, not that it is right. It
# does not check: semantic correctness (a patch where a minor was due passes);
# direction (any different string passes, including a decrease); anything outside a
# pull_request event (a direct push to main bypasses it entirely); deletion of an entire
# plugin directory; any change to which directory the marketplace entry points at
# (rename, copy, or `source`
# repoint); two PRs branched from the same version each bumping to the same new one;
# and whether the version was ever released or tagged.
#
# Scope is every path under plugins/<name>/, with no exemptions — examples/ included,
# because it ships inside the package a user receives (it is never scaffolded into a
# user's project, which is invariant 7 and a different claim). An exemption list would
# make the check judge which paths "matter", and that judgment is what failed as a
# convention.
#
# POSIX sh, no jq — the same constraint as scripts/check-invariants.sh, and for the same
# reason: CI invokes it with `sh`. NOT invariant 4, which is about the hook running on
# machines we do not control.
#
# Version reading is a line-oriented grep, not a JSON parser. Three ceilings, stated so
# they are known rather than assumed away: a nested "version" key elsewhere in the
# manifest is matched too; a manifest that splits the key, colon and value across lines
# is valid JSON but yields no match and FAILS CLOSED; and the comparison is on the
# spelling of the value, not the parsed value, which is why a value containing a
# backslash is rejected outright rather than compared.
#
# Every git call's exit status is checked, and anything unexpected fails closed. A false
# skip is the dangerous direction here: a silent green on exactly the defect this script
# exists to catch.
#
# Regression suite: scripts/check-version-bump.test.sh — run unconditionally in CI's
# invariant-suite step, while this checker itself runs in a separate pull-request-only
# step (it needs a base branch to diff against).
# TESTED SPELLINGS ONLY: extend the fixtures before extending the logic.
set -u

usage() {
  printf 'usage: %s <base-ref>\n' "$0" >&2
  printf '  compares HEAD against the merge-base with <base-ref>\n' >&2
  exit 2
}
[ "$#" -eq 1 ] || usage

# The pathspecs below are relative, so a run from a subdirectory would enumerate nothing
# and exit clean — a false pass. `set -u` does not abort on a failed cd, hence the `||`.
cd "$(dirname "$0")/.." || exit 1

rc=0

# Pathspec magic is not disabled by `--`: a directory named `*` or `[x]` would be read
# as a pattern. Every call goes through this wrapper instead of bare `git`.
g() { git --literal-pathspecs "$@"; }

# An operational problem — a ref that will not resolve, a git call that errors, a
# manifest we cannot parse — is not a clean tree. Stop; do not fall through to a verdict.
die() { printf '\ncheck-version-bump: %s\n' "$1" >&2; exit 1; }

# A policy violation, by contrast, is collected: every offending plugin is named before
# exiting, matching check-invariants.sh's "prints every offending line, not just the
# first". A first-failure exit hides the second un-bumped plugin.
fail() { rc=1; printf '\n%s\n' "$1"; }

# Exactly one "version" match, reduced to the quoted value. Two steps, because comparing
# the whole matched fragment would make `"version": "0.4.0"` and `"version":"0.4.0"`
# differ — a reformat would read as a bump and let an un-bumped change through.
#
# Called via $( ), i.e. in a subshell, so `die` here exits only that subshell: every
# call site adds `|| exit 1` to propagate it. Without that, a fail-closed branch would
# print its diagnostic and then carry on with an empty version.
extract_version() { # $1 = manifest text, $2 = label for diagnostics
  ev_matches=$(printf '%s\n' "$1" | grep -o '"version"[[:space:]]*:[[:space:]]*"[^"]*"')
  if [ -z "$ev_matches" ]; then
    ev_count=0
  else
    ev_count=$(printf '%s\n' "$ev_matches" | wc -l | tr -d '[:space:]')
  fi
  [ "$ev_count" -eq 1 ] ||
    die "$2: expected exactly one \"version\" field, found $ev_count."
  ev_value=${ev_matches#*:}
  ev_value=$(printf '%s' "$ev_value" | sed -e 's/^[[:space:]]*"//' -e 's/"$//')
  # A backslash means a JSON escape, and an escape makes spelling and value diverge:
  # `0.4.\u0030` parses as `0.4.0` but does not compare equal to it, so a manifest
  # could "change version" while the plugin's actual version stood still.
  case "$ev_value" in
    *\\*) die "$2: version value contains a backslash escape; refusing to compare spellings." ;;
  esac
  printf '%s' "$ev_value"
}

# `ls-tree` rather than `cat-file -e`: cat-file returns 128 both for an absent path and
# for a lookup failure, so "new plugin" and "broken object database" would be
# indistinguishable — and the safe direction is to fail, not to pass with an empty base
# version. ls-tree separates them: non-zero exit = error, empty output = absent.
tree_has() { # $1 = tree-ish, $2 = path -> 0 present, 1 absent, dies on error
  th_out=$(g ls-tree "$1" -- "$2") || die "git ls-tree $1 -- $2 failed."
  [ -n "$th_out" ]
}

base_ref=$1
mb=$(g merge-base "$base_ref" HEAD) ||
  die "no merge-base between '$base_ref' and HEAD (unresolvable ref, or unrelated histories)."

# -d, so a blob directly under plugins/ (a stray notes file) is not run through the
# directory-name grammar or, worse, processed as though it were a plugin. Status is
# captured separately from output: an unchecked failure yields an empty list, an empty
# list means "no plugins changed", and that is a false clean exit before any per-plugin
# check can run.
dirs=$(g ls-tree -d --name-only HEAD plugins/) ||
  die "git ls-tree of plugins/ at HEAD failed."

# Newline-only IFS and globbing off, so the loop body runs in THIS shell — `fail` has to
# accumulate into rc, which a `while read` on the right of a pipe (a subshell) could not
# do. Every name is validated against the grammar below before it reaches git.
saved_ifs=$IFS
IFS='
'
set -f
for dir in $dirs; do
  [ -n "$dir" ] || continue
  name=${dir#plugins/}
  # Plugin directory names are ours to choose, so this is a constraint on the repo, not
  # a limitation of the checker — and it has to be enforced rather than assumed:
  # `ls-tree --name-only` C-quotes exotic names, and feeding a quoted display form back
  # to git as a literal path makes `diff` report a non-existent path as unchanged, so
  # the plugin would be skipped in silence. POSIX sh cannot read NUL-delimited input,
  # so -z is not an option.
  # No IFS/`set -f` restore before any `die` below: `die` exits the shell, so nothing
  # after it runs and the restore would be dead code. Two of these paths used to carry
  # one, which was harmless but implied the cleanup was sometimes load-bearing. One
  # convention, stated once: `die` exits, restores happen after the loop.
  case "$name" in
    ''|*[!A-Za-z0-9._-]*)
      die "plugin directory name '$name' is outside [A-Za-z0-9._-]+; refusing to guess."
      ;;
  esac

  manifest="$dir/.claude-plugin/plugin.json"

  # 0 = unchanged (skip), 1 = changed (continue), anything else = git itself failed.
  g diff --quiet "$mb" HEAD -- "$dir/"
  case $? in
    0) continue ;;
    1) ;;
    *) die "git diff of $dir/ failed." ;;
  esac

  # The directory is still in HEAD's tree and something in it changed, so this plugin
  # still ships — but it has no manifest, and therefore no version anything could be
  # keyed on. That is not a carve-out, it is a broken plugin: fail closed.
  #
  # (Deleting a plugin *entirely* is different and is genuinely out of scope: the
  # directory is absent from the enumeration above, so it is never reached. The
  # asymmetry is the point — a whole plugin going away is a marketplace-level change,
  # a plugin that ships without a manifest is a defect.)
  #
  # This was a carve-out at first, on the reasoning that a missing manifest leaves no
  # version to bump. Gate B pushed back twice: the directory survives, its content still
  # reaches users, and "no exemptions" in invariant 12 was false while this stood.
  tree_has HEAD "$manifest" ||
    die "$dir changed and still exists at HEAD, but has no $manifest — a shipped plugin with no version to key on."

  head_json=$(g show "HEAD:$manifest") || die "git show HEAD:$manifest failed."
  head_ver=$(extract_version "$head_json" "HEAD:$manifest") || exit 1

  # The base side is read ONLY if it exists — an unconditional read of a known-absent
  # manifest would die and turn the new-plugin case into a failure.
  if tree_has "$mb" "$manifest"; then
    base_json=$(g show "$mb:$manifest") || die "git show $mb:$manifest failed."
    base_ver=$(extract_version "$base_json" "$mb:$manifest") || exit 1
  else
    base_ver=''   # new plugin: differs from any real version, so it passes
  fi

  if [ "$base_ver" = "$head_ver" ]; then
    fail "$dir changed but its version is still $head_ver (base $mb).
  Bump \"version\" in $manifest — an installed copy is keyed by it."
  fi
done
set +f
IFS=$saved_ifs

[ "$rc" -eq 0 ] && printf 'version-bump check: ok\n'
exit "$rc"
