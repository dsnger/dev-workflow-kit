#!/bin/sh
# Internal link check for the docs: every relative Markdown link `](target)` in a tracked
# *.md file must name a path that exists in this checkout.
#
# WHAT IT CHECKS: inline links of the form `](target)` whose target has no scheme and is not
# a bare `#anchor`; the `#fragment` is cut off and the rest is resolved against the linking
# file's directory (a leading `/` against the repository root). WHAT IT DOES NOT: anchors
# (no heading is matched), reference-style links (`[x]: path`), backticked paths (on
# 2026-10-14, 153 distinct ones did not resolve, because they name files in initialized
# projects, placeholders and future artifacts; nothing tells those apart from a typo),
# links inside code spans or fences (they are checked like any other line), external URLs,
# and targets containing a space or parenthesis (so a link with a title is skipped) or written
# in angle brackets (`](<path>)`, reported broken). Skipped trees: `source-files/` (frozen
# archive), `docs/history/` and `docs/superpowers/replays/` (records that cite paths as they
# were).
#
# POSIX sh plus git, grep and sed; no other dependency. Regression suite:
# scripts/check-doc-links.test.sh. Run from the repository root.
set -u
files=$(git -c core.quotePath=false ls-files -- '*.md') || { echo "doc links: git ls-files failed" >&2; exit 1; }
broken=$(printf '%s\n' "$files" | while IFS= read -r f; do
  case "$f" in (''|source-files/*|docs/history/*|docs/superpowers/replays/*) continue ;; esac
  [ -r "$f" ] || { printf '%s: unreadable, links not checked\n' "$f"; continue; }
  d=$(dirname "$f")
  # One record per link: `<line>:<target>`.
  grep -no '](\([^)( ]*\))' "$f" | sed 's/:](/:/; s/)$//' | while IFS= read -r m; do
    t=${m#*:}
    case "$t" in (''|\#*|*:*) continue ;; esac
    p=${t%%#*}
    case "$p" in (/*) p=".$p" ;; (*) p="$d/$p" ;; esac
    [ -e "$p" ] || printf '%s:%s: broken link: %s\n' "$f" "${m%%:*}" "$t"
  done
done)
if [ -n "$broken" ]; then printf '%s\n' "$broken"; exit 1; fi
printf 'doc links: ok\n'
