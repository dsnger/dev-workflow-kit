#!/bin/sh
# Internal link check for the docs: every relative inline Markdown link (`]` then `(target)`) in a tracked
# *.md file must name a path that exists in this checkout, and a `#fragment` on a Markdown
# target (or a bare `#fragment`, meaning the linking file) must name a heading there.
#
# Usage: sh scripts/check-doc-links.sh [skip-prefix ...], from the repository root. A tracked
# file whose path starts with a skip prefix (for example `docs/history/`) is not checked as a
# linking file; links into it still are.
#
# WHAT IT CHECKS: inline links, `]` directly followed by `(target)`, whose target has no scheme. The part
# before `#` is resolved against the linking file's directory (a leading `/` against the
# repository root) and must exist. When that path is a `.md` file, the fragment must equal
# the slug of one of its ATX headings (`#` to `######`, up to three spaces of indent, outside
# fenced code blocks) or an `id="…"`/`name="…"` attribute in it (not `data-id=` and the like;
# an attribute written in a code span still counts). Slug, as GitHub writes it for plain headings:
# lowercase; ASCII punctuation except `-` and `_` removed; `—` `–` `§` `·` `…` and curly
# quotes removed; each space a `-`; a repeated slug gets `-1`, `-2`, ….
# WHAT IT DOES NOT: setext headings; other Unicode punctuation, non-ASCII capitals, and link
# or emphasis syntax inside a heading are not slugged as GitHub does; two different headings
# that slug alike, or a generated `-1` colliding with a literal heading, are not
# disambiguated as GitHub does — such a link can be reported broken or accepted.
# Fragments on non-Markdown targets; reference-style links (`[x]: path`); backticked paths
# (they name files in other projects, placeholders and future artifacts; nothing tells those
# apart from a typo); links inside code spans or fences (they are checked like any other
# line); external URLs; targets containing a space or parenthesis (so a link with a title is
# skipped) or written in angle brackets (`(<path>)`, reported broken).
#
# POSIX sh plus git, grep, sed and awk; no other dependency. Regression suite:
# scripts/check-doc-links.test.sh in the kit repository.
set -u
# One anchor per line for the Markdown file $1.
anchors() {
  # shellcheck disable=SC1112  # the curly quotes below are awk regex text, not shell quotes
  awk '
    { line = $0; sub(/\r$/, "", line); sub(/^ ? ? ?/, "", line) }
    fl == 0 && match(line, /^(```+|~~~+)/) { fl = RLENGTH; fc = substr(line, 1, 1); next }
    fl > 0 { t = line; sub(/[ \t]+$/, "", t)
             if (t ~ /^(```+|~~~+)$/ && substr(t, 1, 1) == fc && length(t) >= fl) fl = 0
             next }
    {
      s = line
      while (match(s, /(^|[ \t<])(id|name)="[^"]*"/)) {
        a = substr(s, RSTART, RLENGTH); sub(/^[^"]*"/, "", a); sub(/"$/, "", a); print a
        s = substr(s, RSTART + RLENGTH)
      }
    }
    line ~ /^##?#?#?#?#?[ \t]/ {
      h = line; sub(/^#+[ \t]+/, "", h); sub(/[ \t]+#+[ \t]*$/, "", h); sub(/[ \t]+$/, "", h)
      h = tolower(h)
      gsub(/[]!"#$%&'\''()*+,.\/:;<=>?@[\\^`{|}~]/, "", h)
      gsub(/—|–|§|·|…|“|”|‘|’/, "", h)
      gsub(/ /, "-", h)
      if (seen[h]++) print h "-" (seen[h] - 1); else print h
    }
  ' "$1"
}
files=$(git -c core.quotePath=false ls-files -- '*.md') || { echo "doc links: git ls-files failed" >&2; exit 1; }
broken=$(printf '%s\n' "$files" | while IFS= read -r f; do
  [ -n "$f" ] || continue
  skip=0
  for s in "$@"; do case "$f" in ("$s"*) skip=1 ;; esac; done
  [ "$skip" -eq 0 ] || continue
  [ -r "$f" ] || { printf '%s: unreadable, links not checked\n' "$f"; continue; }
  d=$(dirname "$f")
  # One record per link: `<line>:<target>`.
  grep -no '](\([^)( ]*\))' "$f" | sed 's/:](/:/; s/)$//' | while IFS= read -r m; do
    t=${m#*:}
    case "$t" in (''|*:*) continue ;; esac
    p=${t%%#*}
    case "$p" in ('') p=$f ;; (/*) p=".$p" ;; (*) p="$d/$p" ;; esac
    if [ ! -e "$p" ]; then printf '%s:%s: broken link: %s\n' "$f" "${m%%:*}" "$t"; continue; fi
    case "$t" in (*\#*) ;; (*) continue ;; esac
    case "$p" in (*.md) [ -f "$p" ] || continue ;; (*) continue ;; esac
    anchors "$p" | grep -qxF -- "${t#*#}" || printf '%s:%s: broken fragment: %s\n' "$f" "${m%%:*}" "$t"
  done
done)
if [ -n "$broken" ]; then printf '%s\n' "$broken"; exit 1; fi
printf 'doc links: ok\n'
