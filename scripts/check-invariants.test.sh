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

# Every fixture repo needs a valid, agreeing pair of checklist definitions, because the
# prompt-conformance check treats a missing/empty/duplicated checklist as malformed and
# fires. Without this, all four fixture builders below would produce repos that fail on
# a missing checklist BEFORE reaching their own invariant-5/6 assertion: accept cases
# turn red and reject cases start passing for the wrong reason — the exact
# diagnostic-isolation failure the $5-substring guard exists to prevent. Measured before
# this existed: 25 of 61 assertions failed.
#
# One initializer, called from all four builders. Extending only `run_with` would leave
# `sh_case` and the two inline blocks broken.
init_prompt_fixtures() { # $1 = fixture repo root
  mkdir -p "$1/docs" "$1/plugins/dev-workflow/commands"
  for pf in "$1/docs/prompt-standards.md" "$1/plugins/dev-workflow/commands/workflow-init.md"; do
    { printf '# Prompt Standards\n\n## Checklist (each item must be verifiably true)\n\n'
      i=1
      while [ "$i" -le 12 ]; do printf '%s. **item %s**\n' "$i" "$i"; i=$((i + 1)); done
      printf '\n## After\n\nReviewed against all 12 items.\n'
    } > "$pf"
  done
}

work=$(mktemp -d) || work=''
# Abort rather than continue with an empty $work: every path below is built as
# "$work/r", so an empty value turns the fixture reset into `rm -rf /r`.
if [ -z "$work" ] || [ ! -d "$work" ]; then
  printf 'FAIL - could not create a temporary directory; refusing to run\n' >&2
  exit 1
fi
# Restore any mode-000 fixture directory BEFORE removing the tree: the scan-error
# fixture chmods one to 000, and an abort between that and its restore would leave a
# directory this cleanup cannot traverse as a non-root user.
cleanup() { [ -d "$work/r/docs/locked" ] && chmod 755 "$work/r/docs/locked" 2>/dev/null; rm -rf "$work"; }
trap cleanup EXIT HUP INT TERM

# Build a minimal repo whose only content is $1 (a workflow file body), run the
# checker in it, and report its exit status.
run_with() { # $1 = workflow body, $2 = optional manifest body, $3 = optional .mcp.json
  rm -rf "$work/r"; mkdir -p "$work/r/scripts" "$work/r/.github/workflows" \
    "$work/r/plugins/p/.claude-plugin"
  cp "$CHECKER" "$work/r/scripts/"
  init_prompt_fixtures "$work/r"
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
  init_prompt_fixtures "$work/r"
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
init_prompt_fixtures "$work/r"
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
  init_prompt_fixtures "$work/r"
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

# --- Prompt conformance: checks 4a and 4b ------------------------------------------
#
# MUTATION EVIDENCE (recorded 2026-07-26). This is a DOCUMENTED DEVELOPMENT-TIME RUN,
# not automated enforcement: nothing re-runs it, and nothing here fails if it goes stale.
# The procedure lives in the checker's header comment.
#
# Deleting the `BEGIN check 4a`/`END check 4a` block flipped exactly 20 assertions
# (baseline exit 0, mutant exit 1): every `4a:` reject fixture (15), the four
# `exclusion: neighbouring …` controls, which depend on 4a because they carry the
# assertion phrase, and `4a value extraction failure fires`, whose stage 4a alone reaches.
# Deleting the `4b` block flipped exactly 22: every `4b:` reject fixture (16), the four
# `4b exclusion: neighbouring …` controls, and the two stage-failure fixtures that reach
# their stage only through 4b — `checklist parser failure fires` and
# `4b claim validator failure fires`, since deleting the block means neither the parser
# nor the validator is ever called.
# Two fixtures flip in NEITHER mutation, and that is the expected result rather than an
# omission: `scan error fires` and `4a/4b exclusion filter failure fires` break a stage
# that BOTH checks use, so the surviving check still fires when its sibling is deleted.
# In both runs no accept case moved and no unrelated case moved — the second half of the
# check, and the one a non-empty flip set alone does not establish.
#
# An earlier version of this block recorded 17 and 11. Those were true when written and
# went stale the moment fixtures were added — which is exactly the failure the trigger
# below exists to prevent, and it was caught at Gate B rather than by the trigger. If you
# add a fixture, you are changing this mapping.
#
# RE-RUN TRIGGER — broader than "the scan logic", because the mapping above is
# invalidated by more than that: re-run and update BOTH this block and the PR record
# after changing either marked check, its markers, any of these fixtures or their
# assertion names, or the harness that runs them.
# Diagnostics these cases must name, so none can pass on an unrelated violation.
MODEL='name one executing model'
CLAIM='count claim disagrees'
DEFN='checklist definition is missing'
MISMATCH='scaffolded template disagree'

# Build a fixture repo, drop $4 at path $3, run the checker. $2=1 expects rejection.
prompt_case() { # $1 = name, $2 = 1|0, $3 = relative path, $4 = body, $5 = diagnostic
  rm -rf "$work/r"; mkdir -p "$work/r/scripts" "$work/r/.github/workflows" \
    "$work/r/plugins/p/.claude-plugin"
  cp "$CHECKER" "$work/r/scripts/"
  init_prompt_fixtures "$work/r"
  printf '%s\n' '{"name": "p", "version": "1.0.0"}' > "$work/r/plugins/p/.claude-plugin/plugin.json"
  printf '%s\n' "$PINNED" > "$work/r/.github/workflows/ci.yml"
  mkdir -p "$work/r/$(dirname "$3")"
  printf '%s\n' "$4" > "$work/r/$3"
  out=$( cd "$work/r" && sh scripts/check-invariants.sh 2>&1 ); st=$?
  if [ "$2" -eq 1 ]; then
    if [ "$st" -eq 0 ]; then fail "$1 (exited 0)"
    elif ! printf '%s' "$out" | grep -q "$5"; then
      fail "$1 (wrong diagnostic: $(printf '%s' "$out" | tr '\n' ' '))"
    else pass "$1"; fi
  else
    if [ "$st" -eq 0 ]; then pass "$1"
    else fail "$1 ($(printf '%s' "$out" | tr '\n' ' '))"; fi
  fi
}

# 4a — a file claiming conformance must name exactly one executing model.
A='prompt artifact and follows docs/prompt-standards.md'
prompt_case "4a: no Target model line rejected" 1 docs/a.md "$A" "$MODEL"
prompt_case "4a: two declarations rejected" 1 docs/a.md \
  "Target model: Claude via Claude Code
Target model: Codex via mcp__codex__*
$A" "$MODEL"
prompt_case "4a: a valid plus an empty declaration rejected" 1 docs/a.md \
  "Target model: Claude via Claude Code
Target model:
$A" "$MODEL"
prompt_case "4a: empty value rejected" 1 docs/a.md "Target model:
$A" "$MODEL"
# The exact PR #12 defect: names a model CLASS, and mentions Claude only as provenance.
prompt_case "4a: unnamed model naming Claude only as provenance rejected" 1 docs/a.md \
  "Target model: any capable chat model (developed with Claude as the sparring partner)
$A" "$MODEL"
# Token prefixes are not the token. Without a portable boundary these all pass.
prompt_case "4a: token-prefix ClaudeX rejected" 1 docs/a.md "Target model: ClaudeX
$A" "$MODEL"
prompt_case "4a: token-prefix Codex2 rejected" 1 docs/a.md "Target model: Codex2
$A" "$MODEL"
prompt_case "4a: token-prefix GPTfoo rejected" 1 docs/a.md "Target model: GPTfoo
$A" "$MODEL"
# Two distinct models, one per separator: the verdict is separator-independent.
prompt_case "4a: two models via or rejected" 1 docs/a.md "Target model: Claude or Codex
$A" "$MODEL"
prompt_case "4a: two models via slash rejected" 1 docs/a.md "Target model: GPT/Codex
$A" "$MODEL"
prompt_case "4a: two models via comma rejected" 1 docs/a.md "Target model: Codex, Claude
$A" "$MODEL"
prompt_case "4a: two models via and rejected" 1 docs/a.md "Target model: Claude and Codex
$A" "$MODEL"
prompt_case "4a: repeated same token accepted" 0 docs/a.md \
  "Target model: Claude via Claude Code
$A" ""
prompt_case "4a: chat-interface form accepted" 0 docs/a.md \
  "Target model: Claude in a chat interface, upstream of Claude Code
$A" ""
prompt_case "4a: one model with two surfaces accepted" 0 docs/a.md \
  "Target model: Claude via Claude Code or the API
$A" ""
# The settled boundary: a token PREFIX in second position is not a second model.
prompt_case "4a: second-position token prefix accepted" 0 docs/a.md \
  "Target model: Claude or Codex2
$A" ""
prompt_case "4a: indented declaration does not count" 1 docs/a.md "  Target model: Claude
$A" "$MODEL"
prompt_case "4a: blockquoted declaration does not count" 1 docs/a.md "> Target model: Claude via Claude Code
$A" "$MODEL"
prompt_case "4a: mid-sentence mention does not count" 1 docs/a.md \
  "The Target model: field is set elsewhere.
$A" "$MODEL"
prompt_case "4a: file without the assertion is not scanned" 0 docs/a.md \
  "just prose, no conformance claim" ""

# 4b — a prose count claim must equal the checklist it counts (N = 12 in fixtures).
prompt_case "4b: wrong digit claim rejected" 1 docs/c.md "all 11 items" "$CLAIM"
# The motivating 2026-07-25 occurrence was the WORD form.
prompt_case "4b: word-form claim disagreeing rejected" 1 docs/c.md "all ten items" "$CLAIM"
# LESSON LOCK: a canonical-only grammar makes malformed input invisible, not rejected.
prompt_case "4b: non-canonical 012 rejected as malformed" 1 docs/c.md "all 012 items" "$CLAIM"
prompt_case "4b: 40-digit claim rejected" 1 docs/c.md \
  "all 1234567890123456789012345678901234567890 items" "$CLAIM"
prompt_case "4b: correct digit claim accepted" 0 docs/c.md "all 12 items" ""
prompt_case "4b: correct word claim accepted" 0 docs/c.md "all twelve items" ""
prompt_case "4b: two agreeing claims accepted" 0 docs/c.md \
  "all 12 items and later all 12 checklist items" ""
# Outer boundaries: without them these read as claims and reject unrelated prose.
prompt_case "4b: embedded-prefix near-miss accepted" 0 docs/c.md "small ten items" ""
prompt_case "4b: embedded-suffix near-miss accepted" 0 docs/c.md "all ten itemsized" ""

# 4b — malformed checklist DEFINITIONS fire rather than comparing 0 to 0.
prompt_case "4b: absent checklist section rejected" 1 docs/prompt-standards.md \
  "# X
no checklist here" "$DEFN"
prompt_case "4b: empty checklist section rejected" 1 docs/prompt-standards.md \
  "## Checklist (each item must be verifiably true)

## After" "$DEFN"
prompt_case "4b: duplicate Checklist heading rejected" 1 docs/prompt-standards.md \
  "## Checklist (a)
1. **x**
## Checklist (b)
2. **y**" "$DEFN"
prompt_case "4b: non-contiguous labels rejected" 1 docs/prompt-standards.md \
  "## Checklist
1. **a**
1. **b**
3. **c**
## After" "$DEFN"
prompt_case "4b: leading-zero label rejected" 1 docs/prompt-standards.md \
  "## Checklist
01. **a**
## After" "$DEFN"
prompt_case "4b: near-miss heading ## Checklists is not a definition" 1 docs/prompt-standards.md \
  "## Checklists
1. **a**
## After" "$DEFN"
prompt_case "4b: near-miss heading ### Checklist is not a definition" 1 docs/prompt-standards.md \
  "### Checklist
1. **a**
## After" "$DEFN"
prompt_case "4b: near-miss heading ## Checklist-ish is not a definition" 1 docs/prompt-standards.md \
  "## Checklist-ish
1. **a**
## After" "$DEFN"
prompt_case "4b: zero label rejected" 1 docs/prompt-standards.md \
  "## Checklist
0. **a**
## After" "$DEFN"
# A numbered line that is not a canonical item must make the definition BAD, not be
# skipped: skipping it left N unchanged, so adding an item to BOTH definitions kept a
# now-stale count claim passing — a fail-open path exactly when the checklist changes.
prompt_case "4b: trailing non-bold numbered item rejected" 1 docs/prompt-standards.md \
  "## Checklist
1. **a**
2. item two
## After" "$DEFN"
prompt_case "4b: interspersed non-bold numbered item rejected" 1 docs/prompt-standards.md \
  "## Checklist
1. **a**
2. plain
3. **c**
## After" "$DEFN"
prompt_case "4b: definitions disagreeing rejected" 1 docs/prompt-standards.md \
  "## Checklist
1. **a**
## After" "$MISMATCH"

# Exclusions. Each pair uses the SAME violating content inside and outside the excluded
# path, which is what proves the exclusion is load-bearing rather than an overbroad
# filter — or a fixture that never matched the rule at all.
prompt_case "exclusion: source-files/ accepted" 0 source-files/x.md "$A" ""
prompt_case "exclusion: neighbouring source-filesX/ still scanned" 1 source-filesX/x.md "$A" "$MODEL"
prompt_case "exclusion: docs/superpowers/ accepted" 0 docs/superpowers/x.md "$A" ""
prompt_case "exclusion: neighbouring docs/superpowersX/ still scanned" 1 docs/superpowersX/x.md "$A" "$MODEL"
prompt_case "exclusion: .context/ accepted" 0 .context/x.md "$A" ""
prompt_case "exclusion: neighbouring contextX/ still scanned" 1 contextX/x.md "$A" "$MODEL"
# LESSON LOCK: the ledger QUOTES defects, so scanning it self-rejects forever. It carries
# both a quoted assertion phrase and the historical `all ten items`.
prompt_case "exclusion: hardening-log.md quoting both defects accepted" 0 docs/hardening-log.md \
  "| 2026-07-25 | docs-drift | said \"all ten items\" while $A | bot | minor | 2 lint | x |" ""
prompt_case "exclusion: neighbouring hardening-log-notes.md still scanned" 1 docs/hardening-log-notes.md \
  "$A" "$MODEL"

# The pairs above carry 4a's assertion phrase and therefore prove only 4a's filtering.
# A broken or overbroad 4b exclusion would ship with every other assertion green, so
# each excluded path gets a second pair carrying a DISAGREEING count claim instead.
# The hardening-log pair matters most: 4b scanning the ledger is what would reject the
# real repository forever, since the ledger quotes `all ten items` as evidence.
D='all ten items'
prompt_case "4b exclusion: source-files/ accepted" 0 source-files/n.md "$D" ""
prompt_case "4b exclusion: neighbouring source-filesX/ still scanned" 1 source-filesX/n.md "$D" "$CLAIM"
prompt_case "4b exclusion: docs/superpowers/ accepted" 0 docs/superpowers/n.md "$D" ""
prompt_case "4b exclusion: neighbouring docs/superpowersX/ still scanned" 1 docs/superpowersX/n.md "$D" "$CLAIM"
prompt_case "4b exclusion: .context/ accepted" 0 .context/n.md "$D" ""
prompt_case "4b exclusion: neighbouring contextX/ still scanned" 1 contextX/n.md "$D" "$CLAIM"
prompt_case "4b exclusion: hardening-log.md quoting a stale count accepted" 0 docs/hardening-log.md \
  "| 2026-07-25 | docs-drift | said \"$D\" while its checklist ran 1-12 | bot | minor | pending | x |" ""
prompt_case "4b exclusion: neighbouring hardening-log-notes.md still scanned" 1 docs/hardening-log-notes.md \
  "$D" "$CLAIM"

# A scan that ERRORS must not read as "no offenders". grep exits >=2 on a traversal
# failure, and piping it straight into the exclusion filter would report the filter's
# status instead — the checker would print success without having looked.
# Skipped as root, where an unreadable directory is still readable and the fixture
# cannot produce the condition it tests.
if [ "$(id -u)" -eq 0 ]; then
  pass "scan error fires (skipped: running as root)"
else
  rm -rf "$work/r"; mkdir -p "$work/r/scripts" "$work/r/.github/workflows" \
    "$work/r/plugins/p/.claude-plugin"
  cp "$CHECKER" "$work/r/scripts/"
  init_prompt_fixtures "$work/r"
  printf '%s\n' '{"name": "p", "version": "1.0.0"}' > "$work/r/plugins/p/.claude-plugin/plugin.json"
  printf '%s\n' "$PINNED" > "$work/r/.github/workflows/ci.yml"
  mkdir -p "$work/r/docs/locked"; printf 'x\n' > "$work/r/docs/locked/x.md"
  chmod 000 "$work/r/docs/locked"
  out=$( cd "$work/r" && sh scripts/check-invariants.sh 2>&1 ); st=$?
  chmod 755 "$work/r/docs/locked"
  if [ "$st" -eq 0 ]; then fail "scan error fires (exited 0 - scan failure read as clean)"
  elif ! printf '%s' "$out" | grep -q 'scan failed'; then
    fail "scan error fires (wrong diagnostic: $(printf '%s' "$out" | tr '\n' ' '))"
  else pass "scan error fires"; fi
fi

# A parser that cannot RUN must fire, not fall through. With awk broken, the count
# substitution yields empty, which matches neither 'BAD' nor a number, so the comparison
# merely errors into a false condition and execution continues with rc still 0 — the
# checker reporting success without having parsed either checklist. Injected via PATH
# because the checker calls `awk` unqualified.
rm -rf "$work/r"; mkdir -p "$work/r/scripts" "$work/r/.github/workflows" \
  "$work/r/plugins/p/.claude-plugin" "$work/r/fakebin"
cp "$CHECKER" "$work/r/scripts/"
init_prompt_fixtures "$work/r"
printf '%s\n' '{"name": "p", "version": "1.0.0"}' > "$work/r/plugins/p/.claude-plugin/plugin.json"
printf '%s\n' "$PINNED" > "$work/r/.github/workflows/ci.yml"
printf '#!/bin/sh\nexit 2\n' > "$work/r/fakebin/awk"
chmod +x "$work/r/fakebin/awk"
out=$( cd "$work/r" && PATH="$work/r/fakebin:$PATH" sh scripts/check-invariants.sh 2>&1 ); st=$?
if [ "$st" -eq 0 ]; then fail "checklist parser failure fires (exited 0 - parser failure read as clean)"
elif ! printf '%s' "$out" | grep -q 'parser failed'; then
  fail "checklist parser failure fires (wrong diagnostic: $(printf '%s' "$out" | tr '\n' ' '))"
else pass "checklist parser failure fires"; fi

# Selective PATH wrappers. The fake `awk` above exits on the FIRST call, which is the
# checklist parser, so execution never reaches the claim validator or the exclusion
# filters — meaning those newly-checked statuses had no fixture and could be deleted
# while the suite stayed green. Each wrapper below delegates to the real tool and fails
# only for the one invocation under test, identified by an argument unique to it.
inject_case() { # $1 = name, $2 = tool, $3 = match-arg, $4 = expected diagnostic
  rm -rf "$work/r"; mkdir -p "$work/r/scripts" "$work/r/.github/workflows" \
    "$work/r/plugins/p/.claude-plugin" "$work/r/fakebin"
  cp "$CHECKER" "$work/r/scripts/"
  init_prompt_fixtures "$work/r"
  printf '%s\n' '{"name": "p", "version": "1.0.0"}' > "$work/r/plugins/p/.claude-plugin/plugin.json"
  printf '%s\n' "$PINNED" > "$work/r/.github/workflows/ci.yml"
  # A VALID claiming file, so check 4a's per-file path actually executes. Without one
  # the 4a scan matches nothing, the loop body never runs, and a wrapper aimed at the
  # extraction step would never be reached — the fixture would pass by not testing.
  printf 'Target model: Claude via Claude Code\nprompt artifact and follows docs/prompt-standards.md\n' \
    > "$work/r/docs/claiming.md"
  real=$(command -v "$2")
  { printf '#!/bin/sh\n'
    # shellcheck disable=SC2016  # deliberate: $@ must stay literal in the GENERATED script
    printf 'for a in "$@"; do case "$a" in %s) exit 2 ;; esac; done\n' "$3"
    printf 'exec %s "$@"\n' "$real"
  } > "$work/r/fakebin/$2"
  chmod +x "$work/r/fakebin/$2"
  out=$( cd "$work/r" && PATH="$work/r/fakebin:$PATH" sh scripts/check-invariants.sh 2>&1 ); st=$?
  if [ "$st" -eq 0 ]; then fail "$1 (exited 0 - stage failure read as clean)"
  elif ! printf '%s' "$out" | grep -q "$4"; then
    fail "$1 (wrong diagnostic: $(printf '%s' "$out" | tr '\n' ' '))"
  else pass "$1"; fi
}
# `-vE` is used only by the two exclusion filters; invariant 5's filter uses plain -v.
inject_case "4a/4b exclusion filter failure fires" grep '-vE' 'exclusion filter failed'
# `-v words=...` is unique to the 4b claim validator; the checklist parser takes none.
inject_case "4b claim validator failure fires" awk 'words=*' 'claim validator failed'
# The 4a value extraction is identified by a marker comment inside its awk program, so
# this wrapper fails ONLY that invocation and not the parser or the claim validator.
inject_case "4a value extraction failure fires" awk '*extract-target-model*' \
  'per-file checks failed'

printf '\n---\n'
if [ "$fail_n" -eq 0 ]; then printf 'all passed (%s assertions)\n' "$pass_n"; else
  printf '%s passed, %s FAILED\n' "$pass_n" "$fail_n"; exit 1
fi
