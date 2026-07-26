#!/bin/sh
# Mechanical checks for the AGENTS.md invariants that a tool can decide.
#
# These checks exist because prose alone did not hold. Invariant 5 was written down
# and this repo's own CI still shipped `actions/checkout@v4` and `ubuntu-latest`;
# invariant 6 was believed to say the opposite of what it says, and the resulting
# duplicate-hooks manifest key stopped the plugin loading entirely (0.2.1). A rule a
# reader has to remember is worth less than one that fails the build.
#
# POSIX sh, no jq — this script's own requirement, because CI invokes it with `sh`.
# (NOT invariant 4: that one is about the hook running on machines we don't control.)
# Prints every offending line, not just the first.
# Regression suite: scripts/check-invariants.test.sh (run by the same CI step).
#
# Scope, stated so the gaps are known rather than assumed away: this is a
# line-oriented grep, not a YAML parser. It normalises quoting, which is the form
# that actually occurs, but a value written as a block scalar or split across lines
# would slip past. Locations are also recovered from grep's `file:line:` output, which
# assumes the filename has no colon in it. Both are accepted limits of a ~90-line
# checker — it raises the floor, it is not a proof.
#
# TESTED SPELLINGS ONLY: extend the fixtures before extending the regex.
#
# MUTATION RE-RUN PROCEDURE (manual; nothing automates it). The two prompt-conformance
# checks below are bracketed by `# --- BEGIN check 4a ---` / `# --- END check 4a ---`
# markers so a scratch copy can be neutered cleanly:
#
#   TMP=$(mktemp -d) || exit 1
#   [ -n "$TMP" ] && [ -d "$TMP" ] || exit 1   # else the copy below targets /repo
#   trap 'rm -rf "$TMP"' EXIT HUP INT TERM
#   mkdir -p "$TMP/repo"; tar cf - --exclude=.git . | (cd "$TMP/repo" && tar xf -)
#   sed '/BEGIN check 4a/,/END check 4a/d' scripts/check-invariants.sh \
#     > "$TMP/repo/scripts/check-invariants.sh"
#   sh scripts/check-invariants.test.sh > "$TMP/before" 2>&1; base=$?
#   ( cd "$TMP/repo" && sh scripts/check-invariants.test.sh ) > "$TMP/after" 2>&1; mut=$?
#   [ "$base" -eq 0 ] || { echo "VOID: baseline not green" >&2; exit 1; }
#   [ "$mut" -ne 0 ]  || { echo "VOID: check is not load-bearing" >&2; exit 1; }
#   diff "$TMP/before" "$TMP/after" | grep '^> FAIL' | sed 's/^> FAIL - //; s/ (.*)$//' \
#     > "$TMP/flipped"
#   [ -s "$TMP/flipped" ] || { echo "VOID: nothing flipped" >&2; exit 1; }
#   cat "$TMP/flipped"
#
# Each validity check EXITS rather than warning: a check that prints and continues lets
# a red baseline, a passing mutant or an empty flip set be recorded as evidence, which
# is the failure this procedure exists to prevent.
#
# The script's checks establish only that the baseline was green, the mutant failed, and
# something flipped. They do NOT establish the mutant failed for the right reason — a
# syntax error in the neutered copy would also flip cases. Comparing the flipped set
# against the fixture list, and confirming no accept case moved, is a HUMAN step and is
# mandatory. The recorded result lives in check-invariants.test.sh; re-run and update it
# when changing either marked check, its markers, its fixtures or assertion names, or
# the harness.
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
# skills/, commands/, agents/ and hooks/hooks.json load from their paths. A `hooks` key
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

# Scan domain for the two prompt-conformance checks below: Markdown only, because both
# rules are about prompt text. The wider yml/json/toml domain used by invariant 5 is
# deliberately NOT reused — a `Target model:` line in a JSON fixture is not a prompt
# claim. `grep -r` does not follow symlinks (`-R` would), which is the intended form.
#
# Exclusions, each for its own reason. Anchored `($|:)` at the end, NOT `$`: the file
# scan emits bare paths while the claim scan emits `path:line:match`, and a `$`-anchored
# pattern silently matches nothing in the second form — an exclusion that looks applied
# and is not.
#   source-files/      frozen extraction archive, never edited (MANIFEST.md)
#   docs/superpowers/  historical artifacts; its plans legitimately say "all 11 checklist
#                      items", so excluding it is load-bearing, not tidy
#   .context/          generated Gate A/B review artifacts; the quality command must not
#                      depend on ephemeral review wording
#   hardening-log.md   the ledger QUOTES defects, so a row describing either defect below
#                      trips the very check that row records. It carries both a quoted
#                      assertion phrase and the historical `all ten items`.
# No .sh exclusion is needed: `--include='*.md'` already puts this script and its suite
# out of scope.
PROMPT_EXCL='(^|/)source-files/|(^|/)docs/superpowers/|(^|/)\.context/|(^|/)hardening-log\.md($|:)'

# --- BEGIN check 4a ---
# A file asserting it follows docs/prompt-standards.md must name exactly one executing
# model. Prose alone did not hold: a doc shipped claiming conformance while giving its
# target model as "any capable chat model", which names no model at all.
#
# WHAT THIS CATCHES, exactly — the rest of the class stays instruction-backed:
# the missing/duplicated/unnamed/multi-model spellings of the `Target model:` line, in
# files carrying the tested assertion spelling `prompt artifact and follows`. A bare
# `Target model: Claude` naming no execution surface PASSES, as does any value whose
# prose is wrong in a way no token test can see.
#
# Two independent rules, and neither subsumes the other: the value must BEGIN with a
# recognized token (a token merely present accepts "any capable chat model (… developed
# with Claude …)", which is the exact defect this exists for), and it must contain
# exactly one DISTINCT recognized token (which rejects "Claude or Codex" without needing
# a separator grammar).
# The offenders are COLLECTED and reported once, matching this file's existing idiom
# (`bad_npx`, `bad_keys`). Calling `fail` inside the loop would not work: a `while read`
# fed by a pipeline runs in a subshell, so the `rc=1` it sets is discarded and the
# checker would print every violation and still exit 0.
# The scan's status is captured BEFORE filtering. `grep` exits 0 on a match and 1 on no
# match, but >=2 on a real error (unreadable path, I/O failure, bad option). Piping
# straight into the filter would report the FILTER's status and turn any traversal
# failure into an empty offender set — the checker would print success without having
# looked, which is the fail-open direction invariant 2 forbids.
model_scan=$(grep -rl 'prompt artifact and follows' --include='*.md' . 2>/dev/null)
model_scan_st=$?
[ "$model_scan_st" -le 1 ] ||
  fail "Prompt standards: the 4a scan failed; results are not trustworthy." \
       "grep exited $model_scan_st"
# The FILTER gets its own status check too. Capturing only the scan's status closed
# traversal errors but left the next stage open: a `grep -vE` failure also yields an
# empty offender set, which reads as clean.
model_files=$(printf '%s\n' "$model_scan" | grep -vE "$PROMPT_EXCL"); model_filter_st=$?
[ "$model_filter_st" -le 1 ] ||
  fail "Prompt standards: the 4a exclusion filter failed; results are not trustworthy." \
       "grep -v exited $model_filter_st"
bad_model=$(printf '%s\n' "$model_files" |
  while IFS= read -r f; do
    [ -n "$f" ] || continue
    # Per-file statuses are checked too, and an operational failure is emitted as an
    # `ERROR:` sentinel line rather than swallowed. The loop runs inside `$( )`, so it
    # cannot set rc directly; without the sentinel a `grep` that printed a partial
    # count and exited >=2 would leave the offender set empty and the gate would pass.
    decls=$(grep -c '^Target model:' "$f"); decls_st=$?
    if [ "$decls_st" -gt 1 ]; then
      printf 'ERROR: %s: counting declarations failed (grep exited %s)\n' "$f" "$decls_st"
      continue
    fi
    if [ "$decls" -ne 1 ]; then
      printf '%s: %s "Target model:" declarations, need exactly 1\n' "$f" "$decls"
      continue
    fi
    # ONE status-bearing command, deliberately not a pipeline. `grep | head | sed` put
    # only sed's status in $?, so a grep that printed a valid line and THEN failed
    # (status 2) left the file looking conformant — a fail-open path that survived three
    # rounds of status-checking because the pipeline's shape hid it. awk also replaces
    # `head -1` (`-m` is not POSIX) via `exit` after the first match.
    value=$(awk '/^Target model:/ {          # extract-target-model
                   sub(/^Target model:[[:space:]]*/, ""); print; exit }' "$f")
    value_st=$?
    if [ "$value_st" -ne 0 ]; then
      printf 'ERROR: %s: extracting the value failed (pipeline exited %s)\n' "$f" "$value_st"
      continue
    fi
    if ! printf '%s\n' "$value" | grep -qE '^(Claude|Codex|GPT)([^[:alnum:]_]|$)'; then
      printf '%s: names no executing model -> Target model: %s\n' "$f" "$value"
      continue
    fi
    distinct=0; tok_err=
    for tok in Claude Codex GPT; do
      printf '%s\n' "$value" | grep -qE "(^|[^[:alnum:]_])$tok([^[:alnum:]_]|\$)"; tst=$?
      if [ "$tst" -eq 0 ]; then distinct=$((distinct + 1))
      elif [ "$tst" -gt 1 ]; then tok_err="grep exited $tst on $tok"; fi
    done
    if [ -n "$tok_err" ]; then
      printf 'ERROR: %s: token matching failed (%s)\n' "$f" "$tok_err"
      continue
    fi
    [ "$distinct" -eq 1 ] ||
      printf '%s: names %s models, exactly one executes it -> Target model: %s\n' \
        "$f" "$distinct" "$value"
  done)
# An operational failure and a real violation are different diagnoses and must not
# share one message: the first means the check did not complete, the second means it did.
if printf '%s\n' "$bad_model" | grep -q '^ERROR: '; then
  fail "Prompt standards: the 4a per-file checks failed; results are not trustworthy." \
       "$bad_model"
elif [ -n "$bad_model" ]; then
  fail "Prompt standards item 1: a file claiming conformance does not name one executing model." \
       "$bad_model"
fi
# --- END check 4a ---

# --- BEGIN check 4b ---
# A prose count of the prompt-standards checklist must equal the number of items in it.
# The motivating occurrence was the WORD form "all ten items" against a 12-item list, so
# word forms one..twenty are in scope; above twenty, ordinals, hyphenated compounds and
# split-line claims are not, and stay instruction-backed.
#
# Claims are recognized in TWO stages on purpose. A canonical-only pattern would make a
# malformed claim invisible rather than rejected: `all 012 items` matches no canonical
# claim and would be silently ignored. So stage 1 matches any digit run, and stage 2
# requires it to be canonical decimal.
# Prints the item count, or 'BAD' for a malformed definition. Returns 2 if the PARSER
# itself failed, which is not the same thing: an awk that cannot run yields empty output,
# and empty matches neither 'BAD' nor a number, so the caller's comparison merely errors
# into a false condition and execution continues with rc still 0 — the checker reporting
# success without having parsed either checklist.
prompt_checklist_count() { # $1 = file
  # `grep -c` exits 1 when the count is ZERO, which is a valid answer here (a file with
  # no checklist heading is malformed, not unreadable). Only >=2 is a real error, so the
  # status is captured and compared rather than used as a bare `||`.
  heads=$(grep -cE '^## Checklist([[:space:]].*)?$' "$1"); heads_st=$?
  [ "$heads_st" -le 1 ] || return 2
  [ "$heads" -eq 1 ] || { printf 'BAD'; return 0; }
  # Any numbered label inside the section is CONSIDERED, not only canonically-formatted
  # ones. Matching `^[0-9]+\. \*\*` as the guard skipped a non-bold `13. item`
  # entirely, so appending one to both definitions left N at 12 and let a now-stale
  # `all 12 items` claim pass — failing open exactly when the checklist changes.
  awk '
    /^## Checklist([[:space:]].*)?$/ { inlist = 1; next }
    inlist && /^## / { inlist = 0 }
    inlist && /^[0-9]+\./ {
      if ($0 !~ /^[1-9][0-9]*\. \*\*/) { bad = 1; next }   # 0., leading zero, or non-bold
      sub(/\..*/, "", $0); n += 1
      if ($0 "" != n "") bad = 1     # string compare: an oversized label must not overflow
    }
    END { if (bad || n == 0) print "BAD"; else print n }
  ' "$1" || return 2
}
n_repo=$(prompt_checklist_count docs/prompt-standards.md); st_repo=$?
n_tmpl=$(prompt_checklist_count plugins/dev-workflow/commands/workflow-init.md); st_tmpl=$?
if [ "$st_repo" -ne 0 ] || [ "$st_tmpl" -ne 0 ]; then
  fail "Prompt standards: the checklist parser failed; results are not trustworthy." \
       "parser exited $st_repo (repo) / $st_tmpl (template)"
elif [ "$n_repo" = BAD ] || [ "$n_tmpl" = BAD ]; then
  fail "Prompt standards: a checklist definition is missing, empty, duplicated or misnumbered." \
       "docs/prompt-standards.md=$n_repo workflow-init.md=$n_tmpl"
elif [ "$n_repo" -ne "$n_tmpl" ]; then
  fail "Prompt standards: the repo checklist and the scaffolded template disagree." \
       "docs/prompt-standards.md=$n_repo workflow-init.md=$n_tmpl"
else
  # One scan for both spellings, one awk to judge them. Digit comparison is done as
  # STRINGS after canonicalisation, never `+0`, so a 40-digit claim cannot overflow its
  # way to a wrong verdict.
  words='one|two|three|four|five|six|seven|eight|nine|ten|eleven|twelve|thirteen|fourteen|fifteen|sixteen|seventeen|eighteen|nineteen|twenty'
  # Same status capture as the 4a scan, and for the same reason.
  claim_scan=$(grep -rnoE "(^|[^[:alnum:]_])all ([0-9]+|$words)( checklist)? items([^[:alnum:]_]|\$)" \
                 --include='*.md' . 2>/dev/null)
  claim_scan_st=$?
  [ "$claim_scan_st" -le 1 ] ||
    fail "Prompt standards: the 4b claim scan failed; results are not trustworthy." \
         "grep exited $claim_scan_st"
  # Filter and validator each get their own status, for the same reason as 4a's.
  claim_filtered=$(printf '%s\n' "$claim_scan" | grep -vE "$PROMPT_EXCL"); claim_filter_st=$?
  [ "$claim_filter_st" -le 1 ] ||
    fail "Prompt standards: the 4b exclusion filter failed; results are not trustworthy." \
         "grep -v exited $claim_filter_st"
  bad_claims=$(printf '%s\n' "$claim_filtered" |
    awk -v n="$n_repo" -v words="$words" '
      BEGIN { c = split(words, w, "|"); for (i = 1; i <= c; i++) val[w[i]] = i }
      {
        tok = $0; sub(/.*all /, "", tok); sub(/[^0-9a-zA-Z].*/, "", tok)
        if (tok ~ /^[0-9]+$/) {
          if (tok !~ /^[1-9][0-9]*$/) { print $0 "  <- non-canonical number"; next }
          # Same forced-string idiom as prompt_checklist_count above. n arrives via -v,
          # which makes it a strnum, so a bare tok != n leans on awk type inference to
          # stay a string compare. It does today on every awk tested, but the header
          # credits this idiom precisely so overflow on a long digit run cannot depend
          # on that inference. (No apostrophes in here: this program is inside a
          # single-quoted shell string, and one terminated it.)
          if (tok "" != n "") print $0 "  <- checklist has " n
        } else if (tok in val) {
          if (val[tok] != n + 0) print $0 "  <- checklist has " n
        }
      }'); claim_awk_st=$?
  [ "$claim_awk_st" -eq 0 ] ||
    fail "Prompt standards: the 4b claim validator failed; results are not trustworthy." \
         "awk exited $claim_awk_st"
  [ -n "$bad_claims" ] &&
    fail "Prompt standards: a checklist count claim disagrees with the checklist." "$bad_claims"
fi
# --- END check 4b ---

[ "$rc" -eq 0 ] && printf 'invariant checks: ok\n'
exit "$rc"
