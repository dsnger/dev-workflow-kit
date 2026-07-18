#!/bin/sh
# Mechanical checks for the AGENTS.md invariants that a tool can decide.
#
# Both checks exist because prose alone did not hold. Invariant 5 was written down
# and this repo's own CI still shipped `actions/checkout@v4` and `ubuntu-latest`;
# invariant 6 was believed to say the opposite of what it says, and the resulting
# duplicate-hooks manifest key stopped the plugin loading entirely (0.2.1). A rule a
# reader has to remember is worth less than one that fails the build.
#
# POSIX sh, no jq (invariant 4). Prints every offending line, not just the first.
# Regression suite: scripts/check-invariants.test.sh (run by the same CI step).
#
# Scope, stated so the gaps are known rather than assumed away: this is a
# line-oriented grep, not a YAML parser. It normalises quoting, which is the form
# that actually occurs, but a value written as a block scalar or split across lines
# would slip past. Locations are also recovered from grep's `file:line:` output, which
# assumes the filename has no colon in it. Both are accepted limits of a ~90-line
# checker — it raises the floor, it is not a proof.
set -u

root=$(cd "$(dirname "$0")/.." && pwd)
cd "$root" || exit 1
rc=0

# `source-files/` is a frozen extraction archive that is never edited (AGENTS.md
# invariant 5, exception 1; MANIFEST.md). Scanning it would report violations that
# are deliberately preserved history.
scan() { grep -rn "$1" --include='*.yml' --include='*.yaml' --include='*.md' \
  --include='*.json' --include='*.toml' . 2>/dev/null | grep -v '^\./source-files/'; }

# Same, but emits one output line per MATCH (-o) rather than per source line. Needed
# wherever a single line can carry several independent things to check: filtering
# whole lines would let one pinned package on a line clear an unpinned one beside it.
scan_each() { grep -rno "$1" --include='*.yml' --include='*.yaml' --include='*.md' \
  --include='*.json' --include='*.toml' . 2>/dev/null | grep -v '^\./source-files/'; }

# YAML quotes its scalars optionally, so `uses: "actions/checkout@v4"` is the same
# step as the unquoted form. Strip the quotes around a uses:/runs-on: value before
# matching, or the check is trivially evaded by adding a quote.
# Two -e expressions rather than one `\(uses:\|runs-on:\)` alternation: BSD sed (still
# /usr/bin/sed on macOS) has no `\|` in a BRE, so the alternation silently matched
# nothing and every quoted ref fell through to the "no ref at all" branch — rejected,
# but for the wrong reason, which the accept-case test caught.
# `g` on both: without it only the FIRST quoted occurrence on a line was normalised,
# so a second valid quoted ref kept its quote and was rejected.
unquote() {
  sed -e 's/uses:[[:space:]]*["'\'']\([^"'\'']*\)["'\'']/uses: \1/g' \
      -e 's/runs-on:[[:space:]]*["'\'']\([^"'\'']*\)["'\'']/runs-on: \1/g'
}

# Drop the YAML comment from a `file:line:text` record. Prose ABOUT a floating
# dependency is not one. Two forms: a comment after whitespace, and a comment at
# column zero — which sits immediately after grep's `file:line:` prefix, so a
# whitespace-anchored pattern alone missed it.
strip_comment() { sed -e 's/[[:space:]]#.*$//' -e 's/^\(\.[^:]*:[0-9]*:\)[[:space:]]*#.*$/\1/'; }

# One argument, printed as a block. Passing the lines as "$@" would word-split them
# on spaces and mangle every message.
fail() { rc=1; printf '\n%s\n' "$1"; printf '%s\n' "$2" | sed 's/^/  /'; }

# --- Invariant 5: every version pinned exactly ------------------------------------
# An action ref must be a 40-char commit SHA. The ref token is extracted rather than
# the line stripped of comments: the scaffolded template shows a COMMENTED example
# step, so "delete from the first #" would blank the whole line and flag it.
# scan_each, not scan: one line can carry more than one `uses:`, and skipping or
# accepting a whole line on the strength of its FIRST ref let a floating action hide
# behind a pinned or local one beside it.
# Comments stripped first, for the same reason as the runner check and to match the
# documented rule: a ref MENTIONED in a trailing comment is prose, not a step.
# unquote runs BEFORE extraction: `grep -o` stops at the closing quote, so extracting
# first left a dangling `"` on the token and got valid quoted local and docker://
# actions rejected.
bad_uses=$(scan 'uses:' | strip_comment | unquote | while IFS= read -r rec; do
    # Keep grep's `./file:NN:` prefix and re-attach it to each occurrence, so a CI
    # failure still says WHERE. Extracting the tokens alone lost that.
    #
    # Re-attached with printf, never `sed "s|^|$loc|"`: a filename containing the sed
    # delimiter (`a|b.yml`) made sed error out, and the checker then went on to print
    # "ok" — a real violation passing a blocking gate, the one direction that must
    # never happen.
    loc=$(printf '%s' "$rec" | sed -n 's/^\(\.[^:]*:[0-9]*:\).*/\1/p')
    printf '%s' "$rec" | grep -o 'uses:[[:space:]]*[^[:space:]]\{1,\}' |
      while IFS= read -r tok; do printf '%s%s\n' "$loc" "$tok"; done
  done |
  while IFS= read -r occ; do
    # Prefix/suffix stripping throughout instead of `case`: bash 3.2 (still /bin/sh on
    # macOS) mis-parses a case pattern's `)` inside `$( )` as the closing paren of the
    # substitution, which is a syntax error, not a subtle bug.
    ref_part=${occ##*uses:}
    ref_part=$(printf '%s' "$ref_part" | tr -d '[:space:]')
    # A local composite action (`uses: ./.github/actions/x`) lives in this repo and is
    # versioned by the commit under test — there is nothing to pin.
    [ "${ref_part#./}" != "$ref_part" ] && continue
    # A docker:// ref pins by tag or digest rather than by SHA, so it gets its own
    # rule instead of a blanket exemption: `docker://alpine:latest`, and an untagged
    # image (which resolves to :latest), float exactly like `@v4` does.
    if [ "${ref_part#docker://}" != "$ref_part" ]; then
      img=${ref_part#docker://}
      # Digest-pinned — but only if the digest is real. Accepting any `@sha256:`
      # suffix let `@sha256:abc123` and even a bare `@sha256:` read as pinned, which
      # is the checker asserting something it had not actually checked.
      if [ "${img#*@sha256:}" != "$img" ]; then
        dig=${img##*@sha256:}
        if [ "${#dig}" -eq 64 ] && [ -z "$(printf '%s' "$dig" | tr -d '0-9a-f')" ]; then
          continue
        fi
        printf '%s\n' "$occ"; continue
      fi
      # Look for the tag in the FINAL path component only: a registry port
      # (`reg:5000/img`) also contains a colon, and treating that as the tag read an
      # untagged image as pinned.
      last=${img##*/}
      if [ "${last#*:}" = "$last" ]; then printf '%s\n' "$occ"; continue; fi  # no tag
      tag=${last##*:}
      if [ -z "$tag" ] || [ "$tag" = latest ]; then printf '%s\n' "$occ"; fi
      continue
    fi
    # Only owner/repo refs are actions; anything else on a uses: line is not ours.
    [ "${ref_part#*/}" = "$ref_part" ] && continue
    if [ "${ref_part#*@}" = "$ref_part" ]; then
      printf '%s\n' "$occ"; continue          # `uses: owner/repo` with no ref at all
    fi
    ref=${ref_part##*@}
    # ONLY the literal `<sha>` placeholder the scaffolded template ships, and nothing
    # else. Allowing any `<...>` would make `@<latest>` a general bypass.
    [ "$ref" = "<sha>" ] && continue
    # 40 lowercase hex characters, and nothing else.
    if [ "${#ref}" -ne 40 ] || [ -n "$(printf '%s' "$ref" | tr -d '0-9a-f')" ]; then
      printf '%s\n' "$occ"
    fi
  done)
[ -n "$bad_uses" ] && fail "Invariant 5: action ref not pinned to a 40-char commit SHA." "$bad_uses"

# `*-latest` is a moving runner image. Pin an OS release instead — that is exception
# 2, which bounds the drift rather than eliminating it.
# Two passes. The `runs-on:` form is checked everywhere (it appears in the scaffolded
# template too). The bare-token form is checked only inside real workflow YAML,
# because `runs-on: ${{ matrix.os }}` moves the moving value into a matrix list —
# `os: [ubuntu-latest]` — where no `runs-on:` prefix appears at all. Restricting the
# broad form to *.yml/*.yaml keeps prose that merely mentions ubuntu-latest out of it.
# Comments are stripped before re-matching: prose ABOUT a moving runner ("pin the
# release rather than `ubuntu-latest`") is not a moving runner, and the broad token
# scan flagged this repo's own explanatory comment until it was.
bad_runner=$(
  { scan 'runs-on:[[:space:]]*["'\'']\?[A-Za-z0-9._-]*-latest' | unquote
    # Only where a runner value can actually live: an `os:`/`runner:` key, or a bare
    # list item (`- ubuntu-latest`), which is how a matrix spells it. Matching every
    # `*-latest` token in the file flagged unrelated values — `RELEASE_CHANNEL:
    # product-latest` — with a "moving runner" diagnostic and blocked valid workflows.
    # The second alternative matches a bare list item (`  - ubuntu-latest`), which is
    # how a multi-line matrix spells it. Anchored to the start of the FILE line, not to
    # grep's `file:line:` output prefix — anchoring to the prefix meant it never matched
    # anything, silently missing every multi-line matrix.
    #
    # A bare list item carries no key to identify it, so it is restricted to the known
    # GitHub runner-image prefixes. Matching any `- *-latest` treated unrelated lists —
    # a `workflow_dispatch` input whose options include `product-latest` — as runners
    # and failed valid workflows. This is a heuristic, and deliberately the narrow kind:
    # a runner label outside these prefixes is missed by this pass, but the `os:`/
    # `runner:`/`runs-on:` alternative above still covers every keyed form.
    grep -rnE '(^|[[:space:]])(os|runner|runs-on)[[:space:]]*:[^#]*[A-Za-z0-9]-latest|^[[:space:]]*-[[:space:]]*["'\'']?(ubuntu|windows|macos|macOS)-latest' \
      --include='*.yml' --include='*.yaml' ./.github/workflows 2>/dev/null | unquote
  } | strip_comment | grep '[A-Za-z0-9]-latest' | sort -u || true)
[ -n "$bad_runner" ] && fail "Invariant 5: runner pinned to a moving *-latest image." "$bad_runner"

# `npx -y <pkg>` with no exact version executes latest-on-npm at launch. Both the
# JSON args form (`"-y", "pkg"`) and the shell form (`npx -y pkg`) are checked, and
# an exact version means major.minor.patch — `@1` and `@1.x` still float.
#
# scan_each, not scan: filtering whole LINES here meant that
# `["-y", "floating", "-y", "pinned@1.0.0"]` was cleared by the pinned package on the
# same line, silently passing the floating one beside it.
# The version must END after the patch digits: without a trailing boundary,
# `pkg@1.2.3oops` matched the prefix and was accepted as exact.
exact='@[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\([^0-9A-Za-z.]\|$\)'
# The optional quote, `$` and `{}` matter: the shell strips quotes before exec, so
# `npx -y "floating-pkg"` runs exactly like the bare form, and `npx -y "$pkg"` cannot
# be shown to be pinned at all — both must be flagged.
# shellcheck disable=SC2016  # those are literal regex characters matching a variable
# in the SCANNED file, not an expansion in this one.
npx_shell_re='npx[[:space:]]\{1,\}\(-y\|--yes\)[[:space:]]\{1,\}["'\''$]\?[A-Za-z0-9@/._${}-]\{1,\}'
bad_npx=$(
  { scan_each '"\(-y\|--yes\)",[[:space:]]*"[A-Za-z0-9@/._-]\{1,\}"'
    # The shell form also scans *.sh — a shell script is precisely where an unpinned
    # npx call actually executes, and omitting that extension left an executable
    # surface unguarded. The JSON form above deliberately does NOT scan *.sh: this
    # suite embeds JSON fixtures as shell string literals and would flag its own data.
    #
    # This checker and its suite are excluded from the shell scan: they necessarily
    # contain the very literals they search for, in the search pattern, in the
    # explanatory comments, and in the fixtures. A tool cannot lint its own pattern
    # text. These two files are covered by review and by the gates instead.
    grep -rn 'npx[[:space:]]\{1,\}\(-y\|--yes\)' \
      --include='*.yml' --include='*.yaml' --include='*.md' --include='*.json' \
      --include='*.toml' --include='*.sh' . 2>/dev/null |
      grep -v '^\./source-files/' |
      # EXACT paths, not a prefix: `grep -v '^\./scripts/check-invariants'` also
      # exempted every future sibling like check-invariants-extra.sh, quietly widening
      # a two-file exception into a whole-namespace one.
      grep -v '^\./scripts/check-invariants\.sh:' |
      grep -v '^\./scripts/check-invariants\.test\.sh:' |
      # Comments are not executions. Stripped before extraction, so a shell file that
      # merely documents an unpinned call is not treated as making one.
      strip_comment |
      # The optional quote and `$` matter: the shell strips quotes before exec, so
      # `npx -y "floating-pkg"` runs exactly like the bare form, and `npx -y "$pkg"`
      # cannot be shown to be pinned at all — both are flagged.
      grep -o "$npx_shell_re"
  } | grep -v "$exact" | sort -u)
[ -n "$bad_npx" ] && fail "Invariant 5: npx package launched without an exact @version." "$bad_npx"

# --- Invariant 6: the manifest never re-declares convention-loaded components ------
# skills/, commands/ and hooks/hooks.json load from their paths. A `hooks` key
# alongside the convention-loaded file is a duplicate-hooks error that stops the
# plugin loading at all — the 0.2.1 failure. Manifest keys are only for files
# OUTSIDE the convention paths. Newlines are squeezed first so a key and its colon
# split across lines (valid JSON) cannot slip through a line-oriented grep.
for manifest in plugins/*/.claude-plugin/plugin.json; do
  [ -f "$manifest" ] || continue
  bad_keys=$(tr '\n' ' ' < "$manifest" |
    grep -o '"\(skills\|commands\|hooks\|agents\)"[[:space:]]*:' || true)
  [ -n "$bad_keys" ] &&
    fail "Invariant 6: $manifest re-declares a convention-loaded component." "$bad_keys"
done

[ "$rc" -eq 0 ] && printf 'invariant checks: ok\n'
exit "$rc"
