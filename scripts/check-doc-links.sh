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
# the slug (after `%XX` escapes in the fragment are decoded, except control bytes `%00`-`%1F`) of one of its ATX headings (`#` to `######`, up to three spaces of indent, outside
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
# apart from a typo); links inside fenced code blocks (also inside a list or blockquote) or
# inside a code span that opens and closes on one line (both skipped, since they are code
# samples, not links); a code span over several lines and indented code blocks (checked like
# any other line); external URLs; targets
# containing a space or parenthesis (so a link with a title is skipped) or written in angle
# brackets (`(<path>)`, reported broken).
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
# The Markdown file $1 with fenced code blocks blanked and one-line code spans replaced by a
# space, one output line per input line, so grep's line numbers stay right. A fence is found
# after any leading blockquote `>` and list markers and any indent, so one inside a list or quote
# counts too (and an indented code line made of backticks is taken for a fence). A fence ends at
# its closing fence or when the blockquote it opened in ends; one in a list item that is never
# closed runs on past the list's end.
strip_code() {
  awk '
    # x without its leading indent, list markers (when lists is set) and up to maxq quote markers;
    # sets qd to the number of quote markers removed
    function pfx(x, maxq, lists) {
      qd = 0
      while (1) {
        sub(/^[ \t]+/, "", x)
        if (x ~ /^>/ && qd < maxq) { x = substr(x, 2); qd++ }
        else if (lists && match(x, /^([-*+]|[0-9]+[.)])[ \t]/)) x = substr(x, RLENGTH + 1)
        else return x
      }
    }
    { t = $0; sub(/\r$/, "", t); o = pfx(t, 1000, 1); d = qd }
    # a fence ends with its blockquote: a line with fewer quote markers than its opener had
    fl > 0 && d < fd { fl = 0 }
    # a backtick fence has no backtick after its opening run; with one, the line is a code span
    fl == 0 && match(o, /^(```+|~~~+)/) && !(o ~ /^`/ && index(substr(o, RLENGTH + 1), "`")) {
      fl = RLENGTH; fc = substr(o, 1, 1); fd = d; print ""; next }
    # a closer is read with only as many quote markers removed as the opener had, so a quoted
    # fence inside a code sample stays sample text
    fl > 0 { c = pfx(t, fd, 0); sub(/[ \t]+$/, "", c)
             if (c ~ /^(```+|~~~+)$/ && substr(c, 1, 1) == fc && length(c) >= fl) fl = 0
             print ""; next }
    {
      out = ""; s = $0
      while (match(s, /`+/)) {
        # a backtick after an odd number of backslashes is an escaped, literal one
        pre = out substr(s, 1, RSTART - 1); k = 0
        while (k < length(pre) && substr(pre, length(pre) - k, 1) == "\\") k++
        if (k % 2) { out = pre "`"; s = substr(s, RSTART + 1); continue }
        n = RLENGTH; out = pre; run = substr(s, RSTART, n)
        s = substr(s, RSTART + n); r = s; c = 0
        while (match(r, /`+/)) { if (RLENGTH == n) { c = 1; break }; r = substr(r, RSTART + RLENGTH) }
        # a run with no closing run of the same length is literal text, as CommonMark reads it
        if (c) { s = substr(r, RSTART + n); out = out " " } else out = out run
      }
      print out s
    }
  ' "$1"
}
# $1 with each %XX escape decoded to its byte, as a browser decodes a fragment, except %00-%1F.
pct_decode() {
  printf '%b' "$(printf '%s' "$1" | sed 's/\\/\\\\/g' | awk '{
    out = ""; s = $0
    while (match(s, /%[0-9A-Fa-f][0-9A-Fa-f]/)) {
      v = index("0123456789abcdef", tolower(substr(s, RSTART + 1, 1))) * 16 - 16 \
        + index("0123456789abcdef", tolower(substr(s, RSTART + 2, 1))) - 1
      # A control byte stays encoded: decoded, a newline would split the grep pattern below.
      out = out substr(s, 1, RSTART - 1) (v < 32 ? substr(s, RSTART, 3) : sprintf("\\0%03o", v))
      s = substr(s, RSTART + 3)
    }
    print out s
  }')"
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
  strip_code "$f" | grep -no '](\([^)( ]*\))' | sed 's/:](/:/; s/)$//' | while IFS= read -r m; do
    t=${m#*:}
    case "$t" in (''|*:*) continue ;; esac
    p=${t%%#*}
    case "$p" in ('') p=$f ;; (/*) p=".$p" ;; (*) p="$d/$p" ;; esac
    if [ ! -e "$p" ]; then printf '%s:%s: broken link: %s\n' "$f" "${m%%:*}" "$t"; continue; fi
    case "$t" in (*\#*) ;; (*) continue ;; esac
    case "$p" in (*.md) [ -f "$p" ] || continue ;; (*) continue ;; esac
    fr=${t#*#}
    case "$fr" in (*%*) fr=$(pct_decode "$fr") ;; esac
    anchors "$p" | grep -qxF -- "$fr" || printf '%s:%s: broken fragment: %s\n' "$f" "${m%%:*}" "$t"
  done
done)
if [ -n "$broken" ]; then printf '%s\n' "$broken"; exit 1; fi
printf 'doc links: ok\n'
