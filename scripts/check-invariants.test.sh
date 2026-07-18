#!/bin/sh
# Regression suite for check-invariants.sh.
#
# The checker is a CI gate, so the thing that matters is not that it passes on a
# clean tree — it is that it FAILS on each violation it claims to catch, and does
# not fail on the legitimate shapes next door. Every case below is therefore a pair:
# what must be rejected, and the near-miss that must still be accepted.
set -u

CHECKER="$(cd "$(dirname "$0")" && pwd)/check-invariants.sh"
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

# Build a minimal repo whose only content is $1 (a workflow file body), run the
# checker in it, and report its exit status.
run_with() { # $1 = workflow body, $2 = optional manifest body, $3 = optional .mcp.json
  rm -rf "$work/r"; mkdir -p "$work/r/scripts" "$work/r/.github/workflows" \
    "$work/r/plugins/p/.claude-plugin"
  cp "$CHECKER" "$work/r/scripts/"
  printf '%s\n' "$1" > "$work/r/.github/workflows/ci.yml"
  # Single-quoted default: inside double quotes `\{` stays a literal backslash, which
  # produced an invalid-JSON fixture. Harmless against a grep, but a fixture that is
  # not what it claims to be is how a suite starts passing for the wrong reason.
  default_manifest='{"name": "p", "version": "1.0.0"}'
  printf '%s\n' "${2:-$default_manifest}" > "$work/r/plugins/p/.claude-plugin/plugin.json"
  [ -n "${3:-}" ] && printf '%s\n' "$3" > "$work/r/.mcp.json"
  ( cd "$work/r" && sh scripts/check-invariants.sh 2>&1 )
}

# A rejection must fire for the RIGHT reason. Accepting any non-zero exit lets a case
# pass on an unrelated violation — the same "green for the wrong reason" bug the sed
# alternation had, and worth guarding against in the guard itself. $5 is a substring
# of the expected diagnostic; every reject case must name one.
expect_reject() {
  out=$(run_with "$1" "${3:-}" "${4:-}"); st=$?
  if [ "$st" -eq 0 ]; then fail "$2 (exited 0)"
  elif ! printf '%s' "$out" | grep -q "$5"; then fail "$2 (wrong diagnostic: $(printf '%s' "$out" | tr '\n' ' '))"
  else pass "$2"; fi
}
expect_accept() {
  out=$(run_with "$1" "${3:-}" "${4:-}"); st=$?
  if [ "$st" -eq 0 ]; then pass "$2"
  else fail "$2 ($(printf '%s' "$out" | tr '\n' ' '))"; fi
}

ACTION='action ref not pinned'
RUNNER='moving \*-latest'
NPX='without an exact @version'
MANIFEST='re-declares a convention-loaded'

SHA=34e114876b0b11c390a56381ad16ebd13914f8d5
PINNED="jobs:
  q:
    runs-on: ubuntu-24.04
    steps:
      - uses: actions/checkout@$SHA # v4.3.1"

# --- Invariant 5: action refs -----------------------------------------------------
expect_accept "$PINNED" "40-char SHA ref accepted"
expect_reject "$PINNED
      - uses: actions/setup-node@v4" "major-only ref rejected" "" "" "$ACTION"
expect_reject "$PINNED
      - uses: actions/setup-node@main" "branch ref rejected" "" "" "$ACTION"
expect_reject "$PINNED
      - uses: actions/setup-node" "ref omitted entirely rejected" "" "" "$ACTION"
# Quoting is optional in YAML, so it must not become an escape hatch.
expect_reject "$PINNED
      - uses: \"actions/setup-node@v4\"" "double-quoted floating ref rejected" "" "" "$ACTION"
expect_reject "$PINNED
      - uses: 'actions/setup-node@v4'" "single-quoted floating ref rejected" "" "" "$ACTION"
expect_accept "jobs:
  q:
    runs-on: ubuntu-24.04
    steps:
      - uses: \"actions/checkout@$SHA\"" "quoted SHA ref accepted"
# Local actions are versioned by the commit under test; docker refs pin differently.
expect_accept "$PINNED
      - uses: ./.github/actions/build" "local composite action accepted"
# docker:// pins by tag or digest, so it gets its own rule rather than a blanket
# exemption — a blanket skip let `docker://alpine:latest` through untouched.
expect_accept "$PINNED
      - uses: docker://alpine:3.19" "docker:// exact tag accepted"
# Quoted forms of the non-owner/repo refs: extracting before unquoting left a dangling
# quote on the token and got these rejected.
expect_accept "$PINNED
      - uses: \"./.github/actions/build\"" "quoted local action accepted"
expect_accept "$PINNED
      - uses: \"docker://alpine:3.19\"" "quoted docker ref accepted"
expect_accept "$PINNED
      - uses: docker://alpine@sha256:0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef" \
  "docker:// full 64-hex digest accepted"
# A digest is only a pin if it is a real one; accepting any @sha256: suffix meant the
# checker asserted something it had not checked.
expect_reject "$PINNED
      - uses: docker://alpine@sha256:abc123" "docker:// truncated digest rejected" "" "" "$ACTION"
expect_reject "$PINNED
      - uses: docker://alpine@sha256:" "docker:// empty digest rejected" "" "" "$ACTION"
expect_reject "$PINNED
      - uses: docker://alpine:latest" "docker:// :latest rejected" "" "" "$ACTION"
expect_reject "$PINNED
      - uses: docker://alpine" "docker:// untagged rejected" "" "" "$ACTION"
# A registry port carries a colon too — mistaking it for the tag separator read an
# untagged image as pinned.
expect_reject "$PINNED
      - uses: docker://reg:5000/img" "docker:// untagged behind a registry port rejected" "" "" "$ACTION"
expect_accept "$PINNED
      - uses: docker://reg:5000/img:1.0" "docker:// tagged behind a registry port accepted"
# One line can carry several `uses:` tokens; taking only the first let the rest hide.
# (A ref merely MENTIONED in a trailing comment is prose, not a step, and is not a
# dependency — so it is deliberately not asserted here.)
expect_reject "$PINNED
      - uses: ./local-action    - uses: actions/setup-node@v4" \
  "second uses: on the same line still rejected" "" "" "$ACTION"
expect_accept "$PINNED
      - uses: ./local-action    - uses: actions/checkout@$SHA" \
  "two uses: on one line, both legitimate, accepted"
# The placeholder exemption must be exactly the documented token, not any <...>.
# Asserted UNcommented: with a leading `#`, strip_comment removes the line entirely
# and the exemption branch is never reached — the test would stay green if it broke.
expect_accept "$PINNED
      - uses: pnpm/action-setup@<sha>" "documented <sha> placeholder accepted"
expect_accept "$PINNED
      # - uses: pnpm/action-setup@v4" "commented-out example not checked"
# Two quoted refs on one line: a non-global unquote left the second one quoted.
expect_accept "$PINNED
      - uses: \"actions/checkout@$SHA\"    - uses: \"actions/setup-node@$SHA\"" \
  "two quoted pinned refs on one line accepted"
expect_reject "$PINNED
      - uses: pnpm/action-setup@<latest>" "arbitrary <...> ref is not a bypass" "" "" "$ACTION"

# --- Invariant 5: runner ----------------------------------------------------------
expect_reject "jobs:
  q:
    runs-on: ubuntu-latest" "ubuntu-latest rejected" "" "" "$RUNNER"
expect_reject "jobs:
  q:
    runs-on: \"ubuntu-latest\"" "quoted ubuntu-latest rejected" "" "" "$RUNNER"
expect_accept "jobs:
  q:
    runs-on: ubuntu-24.04" "pinned OS release accepted"
# A matrix moves the moving value out from under `runs-on:` entirely — inline and, in
# the form that is easiest to miss, as a multi-line list.
expect_reject "jobs:
  q:
    strategy:
      matrix:
        os: [ubuntu-latest]
    runs-on: \${{ matrix.os }}" "matrix ubuntu-latest rejected" "" "" "$RUNNER"
expect_reject "jobs:
  q:
    strategy:
      matrix:
        os:
          - ubuntu-latest
          - windows-latest
    runs-on: \${{ matrix.os }}" "multi-line matrix list rejected" "" "" "$RUNNER"
expect_reject "jobs:
  q:
    runs-on: ubuntu-latest # todo pin" "runs-on with trailing comment rejected" "" "" "$RUNNER"
expect_reject "jobs:
  q:
    runs-on: windows-latest" "windows-latest rejected" "" "" "$RUNNER"
# A bare list item has no key to identify it, so an unrelated list must not be read
# as a matrix of runners.
expect_accept "on:
  workflow_dispatch:
    inputs:
      channel:
        options:
          - product-latest
          - product-stable
jobs:
  q:
    runs-on: ubuntu-24.04" "unrelated *-latest list item accepted"
expect_accept "jobs:
  q:
    strategy:
      matrix:
        os: [ubuntu-24.04]
    runs-on: \${{ matrix.os }}" "matrix with pinned release accepted"
# Prose ABOUT a moving runner is not a moving runner.
expect_accept "jobs:
  q:
    # pin the release rather than ubuntu-latest, which drifts
    runs-on: ubuntu-24.04" "comment mentioning ubuntu-latest accepted"
# A *-latest token that is not a runner value at all must not be diagnosed as one.
expect_accept "jobs:
  q:
    runs-on: ubuntu-24.04
    env:
      RELEASE_CHANNEL: product-latest" "unrelated *-latest env value accepted"

# --- Invariant 5: npx -------------------------------------------------------------
expect_accept "$PINNED" "clean tree, no mcp config" "" ''
expect_reject "$PINNED" "unpinned npx in JSON args rejected" "" '{"args": ["-y", "mcp-codex-dev"]}' "$NPX"
expect_accept "$PINNED" "exact npx version accepted" "" '{"args": ["-y", "mcp-codex-dev@1.0.1"]}'
# A version is only exact at major.minor.patch — these still float.
expect_reject "$PINNED" "major-only npx version rejected" "" '{"args": ["-y", "mcp-codex-dev@1"]}' "$NPX"
expect_reject "$PINNED" "wildcard npx version rejected" "" '{"args": ["-y", "mcp-codex-dev@1.x"]}' "$NPX"
expect_reject "$PINNED" "unpinned --yes long flag rejected" "" '{"args": ["--yes", "mcp-codex-dev"]}' "$NPX"
# One pinned package on a line must not clear an unpinned one beside it: a whole-line
# inverted match let exactly this through.
expect_reject "$PINNED" "unpinned package alongside a pinned one still rejected" "" \
  '{"args": ["-y", "floating-pkg", "-y", "pinned-pkg@1.0.0"]}' "$NPX"
expect_accept "$PINNED" "two pinned packages on one line accepted" "" \
  '{"args": ["-y", "a-pkg@1.0.0", "-y", "b-pkg@2.3.4"]}'
# The version must END at the patch digits, or a prefix match calls this exact.
expect_reject "$PINNED" "trailing-garbage version rejected" "" \
  '{"args": ["-y", "mcp-codex-dev@1.2.3oops"]}' "$NPX"
expect_accept "$PINNED" "prerelease version accepted" "" \
  '{"args": ["-y", "mcp-codex-dev@1.2.3-beta.1"]}'

# --- Invariant 6: manifest --------------------------------------------------------
expect_accept "$PINNED" "manifest with no component keys accepted" '{"name": "p", "version": "1.0.0"}'
expect_reject "$PINNED" "hooks key rejected" '{"name": "p", "hooks": "./hooks/hooks.json"}' "" "$MANIFEST"
expect_reject "$PINNED" "skills key rejected" '{"name": "p", "skills": ["./skills/x"]}' "" "$MANIFEST"
# Valid JSON may put the key and its colon on separate lines.
expect_reject "$PINNED" "key/colon split across lines rejected" '{"name": "p", "hooks"
  : "./hooks/hooks.json"}' "" "$MANIFEST"

# --- Invariant 5: npx inside a shell script ---------------------------------------
# A *.sh file is where `npx -y pkg` actually runs, so omitting that extension from the
# scan left an executable surface unguarded while the suite stayed green.
sh_case() { # $1 = script body, $2 = name, $3 = expect_reject? (1/0)
  rm -rf "$work/r"; mkdir -p "$work/r/scripts" "$work/r/.github/workflows" \
    "$work/r/plugins/p/.claude-plugin"
  cp "$CHECKER" "$work/r/scripts/"
  printf '%s\n' '{"name": "p"}' > "$work/r/plugins/p/.claude-plugin/plugin.json"
  printf '%s\n' "$PINNED" > "$work/r/.github/workflows/ci.yml"
  printf '#!/bin/sh\n%s\n' "$1" > "$work/r/run.sh"
  out=$( cd "$work/r" && sh scripts/check-invariants.sh 2>&1 ); st=$?
  if [ "$3" = 1 ]; then
    if [ "$st" -eq 0 ]; then fail "$2 (got green)"
    elif ! printf '%s' "$out" | grep -q "$NPX"; then fail "$2 (wrong diagnostic)"
    else pass "$2"; fi
  else
    if [ "$st" -eq 0 ]; then pass "$2"; else fail "$2 ($(printf '%s' "$out" | tr '\n' ' '))"; fi
  fi
}
sh_case 'npx -y floating-pkg' "unpinned npx in a shell script rejected" 1
sh_case 'npx --yes floating-pkg' "unpinned npx --yes in a shell script rejected" 1
sh_case 'npx -y pinned-pkg@1.2.3' "pinned npx in a shell script accepted" 0
# The shell strips quotes before exec, so a quoted spec runs exactly like a bare one.
sh_case 'npx -y "floating-pkg"' "quoted unpinned npx rejected" 1
sh_case "npx --yes 'floating-pkg'" "single-quoted unpinned npx rejected" 1
sh_case 'npx -y "pinned-pkg@1.2.3"' "quoted pinned npx accepted" 0
# A package from a variable cannot be shown to be pinned; firing is the safe direction.
# shellcheck disable=SC2016  # `$pkg` is fixture text written into the scanned script,
# deliberately unexpanded here.
sh_case 'npx -y "$pkg"' "dynamic npx package rejected" 1
# A comment documents, it does not execute.
sh_case '# never run npx -y floating-example' "npx inside a shell comment accepted" 0

# The self-exclusion covers exactly two files. A sibling that merely starts with the
# same characters must still be scanned — a prefix match quietly exempted a namespace.
rm -rf "$work/r"; mkdir -p "$work/r/scripts" "$work/r/.github/workflows" \
  "$work/r/plugins/p/.claude-plugin"
cp "$CHECKER" "$work/r/scripts/"
printf '%s\n' '{"name": "p"}' > "$work/r/plugins/p/.claude-plugin/plugin.json"
printf '%s\n' "$PINNED" > "$work/r/.github/workflows/ci.yml"
printf '#!/bin/sh\nnpx -y floating-extra\n' > "$work/r/scripts/check-invariants-extra.sh"
out=$( cd "$work/r" && sh scripts/check-invariants.sh 2>&1 ); st=$?
if [ "$st" -eq 0 ]; then fail "similarly-named sibling script is still scanned (got green)"
elif ! printf '%s' "$out" | grep -q "$NPX"; then fail "similarly-named sibling: wrong diagnostic"
else pass "similarly-named sibling script is still scanned"; fi

# --- Adversarial filenames --------------------------------------------------------
# A filename carrying a sed metacharacter must not corrupt the checker. This is the
# dangerous direction: the earlier `sed "s|^|$loc|"` errored on `a|b.yml` and the
# checker then printed "ok", passing a real violation through a blocking gate.
for badname in 'a|b' 'a&b' 'a\b'; do
  rm -rf "$work/r"; mkdir -p "$work/r/scripts" "$work/r/.github/workflows" \
    "$work/r/plugins/p/.claude-plugin"
  cp "$CHECKER" "$work/r/scripts/"
  printf '%s\n' '{"name": "p"}' > "$work/r/plugins/p/.claude-plugin/plugin.json"
  printf '%s\n' "$PINNED" > "$work/r/.github/workflows/ci.yml"
  printf 'jobs:\n  q:\n    steps:\n      - uses: actions/setup-node@v4\n' \
    > "$work/r/.github/workflows/$badname.yml"
  out=$( cd "$work/r" && sh scripts/check-invariants.sh 2>&1 ); st=$?
  if [ "$st" -eq 0 ]; then fail "violation in '$badname.yml' must not pass (got green)"
  elif ! printf '%s' "$out" | grep -q "$ACTION"; then
    fail "violation in '$badname.yml' wrong diagnostic: $(printf '%s' "$out" | tr '\n' ' ')"
  else pass "violation in filename '$badname.yml' still rejected"; fi
done

printf '\n---\n'
if [ "$fail_n" -eq 0 ]; then printf 'all passed (%s assertions)\n' "$pass_n"; else
  printf '%s passed, %s FAILED\n' "$pass_n" "$fail_n"; exit 1
fi
