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
# $5 = diagnostic a reject must carry, $6 = optional skip prefix passed to the checker.
# The repo always holds docs/real.md.
dl_case() {
  rm -rf "$work/r"; mkdir -p "$work/r/docs" "$work/r/$(dirname "$3")"
  # shellcheck disable=SC2016  # the backticks are fixture text
  printf '# real\n\n## Same\n\n## Same\n\n## Gate — `x` (y) §2\n\n<a id="anc"></a> <a name="nm"></a> <div data-id="dat"></div>\n\n  ## Indented\n\n    ## Code block\n\n## Crlf\r\n\n## Café 100%%\n\n## -Café\n\n```sh\n# fenced\n```\n' > "$work/r/docs/real.md"
  printf '%s\n' "$4" > "$work/r/$3"
  ( cd "$work/r" && git init -q && git add -A ) || { fail "$1 (fixture)"; return; }
  out=$( cd "$work/r" && sh "$CHECKER" ${6:+"$6"} 2>&1 ); st=$?
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
dl_case "fragment naming a heading accepted"         0 README.md '[a](docs/real.md#real)' ''
dl_case "root-absolute link accepted"                0 docs/x.md '[a](/docs/real.md)' ''
dl_case "directory link accepted"                    0 README.md '[a](docs/)' ''
dl_case "URL and mailto skipped"                     0 README.md '[a](https://x.invalid/y) [b](mailto:a@b.c)' ''
dl_case "broken fragment in another file rejected"  1 README.md '[a](docs/real.md#top)' 'README.md:1: broken fragment: docs/real.md#top'
dl_case "bare fragment checked against own file"    1 README.md '# Here
[c](#here) [d](#gone)' 'README.md:2: broken fragment: #gone'
dl_case "bare fragment to own heading accepted"     0 README.md '# Here
[c](#here)' ''
dl_case "repeated heading gets -1"                  0 README.md '[a](docs/real.md#same) [b](docs/real.md#same-1)' ''
dl_case "third slug of a repeated heading absent"   1 README.md '[a](docs/real.md#same-2)' 'broken fragment: docs/real.md#same-2'
dl_case "dash, backticks, parens and § slugged"     0 README.md '[a](docs/real.md#gate--x-y-2)' ''
dl_case "id attribute counts as anchor"             0 README.md '[a](docs/real.md#anc)' ''
dl_case "name attribute counts as anchor"           0 README.md '[a](docs/real.md#nm)' ''
dl_case "data-id attribute not counted"             1 README.md '[a](docs/real.md#dat)' 'broken fragment: docs/real.md#dat'
dl_case "heading indented up to three spaces counts" 0 README.md '[a](docs/real.md#indented)' ''
dl_case "four-space indented code not a heading"    1 README.md '[a](docs/real.md#code-block)' 'broken fragment: docs/real.md#code-block'
dl_case "CRLF heading slugged without the CR"       0 README.md '[a](docs/real.md#crlf)' ''
dl_case "percent-encoded fragment decoded"          0 README.md '[a](docs/real.md#caf%C3%A9-100)' ''
dl_case "raw non-ASCII fragment accepted"           0 README.md '[a](docs/real.md#café-100)' ''
dl_case "encoded fragment starting with - decoded"  0 README.md '[a](docs/real.md#-caf%C3%A9)' ''
dl_case "encoded newline cannot split the pattern"  1 README.md '[a](docs/real.md#real%0Agone)' 'broken fragment: docs/real.md#real%0Agone'
dl_case "encoded NUL cannot cut the pattern"        1 README.md '[a](docs/real.md#real%00gone)' 'broken fragment: docs/real.md#real%00gone'
dl_case "encoded fragment still checked"            1 README.md '[a](docs/real.md#caf%C3%A9-200)' 'broken fragment: docs/real.md#caf%C3%A9-200'
dl_case "heading inside a code fence not counted"   1 README.md '[a](docs/real.md#fenced)' 'broken fragment: docs/real.md#fenced'
dl_case "fragment on a non-Markdown target ignored" 0 README.md '[a](docs/#L3)' ''
dl_case "broken relative link rejected"              1 README.md '[a](docs/gone.md)' 'README.md:1: broken link: docs/gone.md'
dl_case "second link on a line checked"              1 README.md '[a](docs/real.md) [b](docs/gone.md)' 'docs/gone.md'
dl_case "broken link with fragment rejected"         1 README.md '[a](docs/gone.md#x)' 'docs/gone.md#x'
dl_case "path relative to the wrong dir rejected"    1 docs/x.md '[a](docs/real.md)' 'docs/x.md:1: broken link'
dl_case "file name with a space checked"             1 'docs/a b.md' '[a](gone.md)' 'docs/a b.md:1'
dl_case "non-ASCII file name checked, not unreadable" 1 'docs/café.md' '[a](gone.md)' 'docs/café.md:1: broken link'
dl_case "glob-like target not expanded"              1 README.md '[a](docs/*.md)' 'docs/*.md'
dl_case "skip prefix argument skips a tree"          0 docs/history/old.md '[a](gone.md)' '' docs/history/
dl_case "no skip prefix: that tree is checked"      1 docs/history/old.md '[a](gone.md)' 'docs/history/old.md:1: broken link'
# shellcheck disable=SC2016  # the backticks are fixture text
{
dl_case "link inside a backtick fence skipped"      0 README.md '```md
[a](gone.md)
```' ''
dl_case "link inside a tilde fence skipped"         0 README.md '  ~~~~
[a](gone.md)
~~~
~~~~' ''
dl_case "link after a closed fence checked"         1 README.md '```
x
```
[a](gone.md)' 'README.md:4: broken link: gone.md'
dl_case "link inside a code span skipped"           0 README.md 'see `[a](gone.md)` here' ''
dl_case "double-backtick span holding a backtick"   0 README.md '``[a](gone.md) ` x``' ''
dl_case "link after a code span checked"            1 README.md '`x` [a](gone.md)' 'README.md:1: broken link: gone.md'
dl_case "unclosed backtick is text, link checked"   1 README.md '`x [a](gone.md)' 'README.md:1: broken link: gone.md'
dl_case "one-line triple-backtick span is no fence"  1 README.md '```x``` y
[a](gone.md)' 'README.md:2: broken link: gone.md'
dl_case "fence inside a list item skipped"          0 README.md '- item
  ```
  [a](gone.md)
  ```' ''
dl_case "fence inside a blockquote skipped"         0 README.md '> ```
> [a](gone.md)
> ```' ''
dl_case "link after a list fence checked"           1 README.md '1. x
   ```
   y
   ```
[a](gone.md)' 'README.md:5: broken link: gone.md'
dl_case "escaped backticks are no code span"        1 README.md '\`[a](gone.md)\`' 'README.md:1: broken link: gone.md'
dl_case "escaped backslash before a span opener"    0 README.md '\\`[a](gone.md)`' ''
dl_case "removed span cannot join a link"           0 README.md '[a]`code`(gone.md)' ''
dl_case "quoted fence inside a top-level fence"     0 README.md '```markdown
> ```
[a](gone.md)
```' ''
dl_case "unclosed quoted fence ends with the quote" 1 README.md '> ```
> x

[a](gone.md)' 'README.md:4: broken link: gone.md'
dl_case "nested quote fence ends with its quote"    1 README.md '> > ```
> > x
> [a](gone.md)' 'README.md:3: broken link: gone.md'
dl_case "closed list-and-quote fence, link after"  1 README.md '- > ```
  > [b](gone.md)
  > ```

[a](gone.md)' 'README.md:5: broken link: gone.md'
dl_case "bare ]( before a code span is no target"   0 README.md '](`[a](gone.md)`)' ''
dl_case "runs of unequal length do not close"       1 README.md '``x` [a](gone.md)' 'broken link: gone.md'
}
dl_case "untracked file not checked"                 0 README.md '' ''
printf '[a](gone.md)\n' > "$work/r/untracked.md"
out=$( cd "$work/r" && sh "$CHECKER" 2>&1 ) && pass "untracked file still not checked" || fail "untracked file checked: $out"

printf '\n---\n'
if [ "$fail_n" -eq 0 ]; then printf 'all passed (%s assertions)\n' "$pass_n"; else
  printf '%s passed, %s FAILED\n' "$pass_n" "$fail_n"; exit 1
fi
