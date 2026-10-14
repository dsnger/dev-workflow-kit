#!/bin/sh
# Regression suite for check-doc-links.sh: each case builds a small git repo and runs the
# checker in it. A reject case must exit non-zero and name the broken link.
set -u
CHECKER="$(cd "$(dirname "$0")" && pwd)/check-doc-links.sh"
pass_n=0; fail_n=0
pass() { pass_n=$((pass_n + 1)); printf 'ok   - %s\n' "$1"; }
fail() { fail_n=$((fail_n + 1)); printf 'FAIL - %s\n' "$1"; }
work=$(mktemp -d) || exit 1
[ -n "$work" ] && [ -d "$work" ] || exit 1
trap 'rm -rf "$work"' EXIT HUP INT TERM

# $1 = name, $2 = 1|0 expect reject, $3 = path of the linking file, $4 = its content,
# $5 = diagnostic a reject must carry. The repo always holds docs/real.md.
dl_case() {
  rm -rf "$work/r"; mkdir -p "$work/r/docs" "$work/r/$(dirname "$3")"
  printf '# real\n' > "$work/r/docs/real.md"
  printf '%s\n' "$4" > "$work/r/$3"
  ( cd "$work/r" && git init -q && git add -A ) || { fail "$1 (fixture)"; return; }
  out=$( cd "$work/r" && sh "$CHECKER" 2>&1 ); st=$?
  if [ "$2" -eq 1 ]; then
    if [ "$st" -eq 0 ]; then fail "$1 (exited 0)"
    elif ! printf '%s' "$out" | grep -qF -- "$5"; then fail "$1 (wrong diagnostic: $out)"
    else pass "$1"; fi
  else
    if [ "$st" -eq 0 ]; then pass "$1"; else fail "$1 (exited $st: $out)"; fi
  fi
}

dl_case "relative link resolving accepted"          0 README.md '[a](docs/real.md)' ''
dl_case "link from a subdirectory accepted"          0 docs/s/x.md '[a](../real.md) [b](../../docs/)' ''
dl_case "fragment cut before resolving accepted"     0 README.md '[a](docs/real.md#top)' ''
dl_case "root-absolute link accepted"                0 docs/x.md '[a](/docs/real.md)' ''
dl_case "directory link accepted"                    0 README.md '[a](docs/)' ''
dl_case "URL, mailto and bare anchor skipped"        0 README.md '[a](https://x.invalid/y) [b](mailto:a@b.c) [c](#here)' ''
dl_case "broken relative link rejected"              1 README.md '[a](docs/gone.md)' 'README.md:1: broken link: docs/gone.md'
dl_case "second link on a line checked"              1 README.md '[a](docs/real.md) [b](docs/gone.md)' 'docs/gone.md'
dl_case "broken link with fragment rejected"         1 README.md '[a](docs/gone.md#x)' 'docs/gone.md#x'
dl_case "path relative to the wrong dir rejected"    1 docs/x.md '[a](docs/real.md)' 'docs/x.md:1: broken link'
dl_case "file name with a space checked"             1 'docs/a b.md' '[a](gone.md)' 'docs/a b.md:1'
dl_case "non-ASCII file name checked, not unreadable" 1 'docs/café.md' '[a](gone.md)' 'docs/café.md:1: broken link'
dl_case "glob-like target not expanded"              1 README.md '[a](docs/*.md)' 'docs/*.md'
dl_case "skipped tree not checked"                   0 docs/history/old.md '[a](gone.md)' ''
dl_case "untracked file not checked"                 0 README.md '' ''
printf '[a](gone.md)\n' > "$work/r/untracked.md"
out=$( cd "$work/r" && sh "$CHECKER" 2>&1 ) && pass "untracked file still not checked" || fail "untracked file checked: $out"

printf '\n---\n'
if [ "$fail_n" -eq 0 ]; then printf 'all passed (%s assertions)\n' "$pass_n"; else
  printf '%s passed, %s FAILED\n' "$pass_n" "$fail_n"; exit 1
fi
