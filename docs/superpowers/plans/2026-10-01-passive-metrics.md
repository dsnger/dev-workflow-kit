# Passive Metrics Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Story:** `docs/superpowers/stories/2026-08-04-passive-metrics-over-the-ledger-story.md` — read the profile from its header at every gate call.

**Goal:** Add `scripts/ledger-metrics.py`, a read-only report over the hardening ledger and the review-cycle records in commit bodies, with its POSIX-sh regression suite, and wire the suite into the battery, CI and the docs.

**Architecture:** One Python 3.8+ standard-library script resolves one commit, reads the ledger blob and the `git log -z` bodies at it, parses the §5 record grammar with a small hand-written scanner (quoted strings, escapes, control characters), and prints the report. The suite builds throwaway, config-isolated repositories with fixed commit dates, so SHAs and output are deterministic, and compares the report with expected text.

**Tech Stack:** Python 3.8+ (standard library), `git`, POSIX `sh` for the suite, `shellcheck` 0.11.0.

**Spec:** `docs/superpowers/specs/2026-10-01-passive-metrics-design.md` — revision committed in `49b90f8` (Gate-A spec cycle `p9yvzn4fvi`, closed). It supersedes the awk revision (`c60b78b`).

**This plan replaces the awk plan reviewed in Gate-A plan pass 1** (`.context/codex-reviews/gate-a-plan-mtf7ua7qze-pass-1.md`). That pass's findings were about awk parsing, mawk semantics and suite isolation; the table at the end says where each landed.

**Executed 2026-10-01 (PR #33).** Gate B and PR review added suite cases after this plan was approved, so the committed `scripts/ledger-metrics.test.sh` has more cases than the copy embedded below. The counts below (`30 passed`) describe the suite as the plan approved it; after PR #33's review fixes the committed suite has 32 cases. Ruling 1 below was also carried into the spec afterwards (its grammar paragraph is marked "updated after implementation"), so "the spec is not edited" describes the decision at planning time.

## Global Constraints

- Worktree `/Users/daniel/DEVELOPMENT/APPS/dwk-metrics`, branch `passive-metrics`. Paths are relative to it.
- The script is not shipped: no file under `plugins/` changes, so no version bump (spec §1).
- The script writes nothing itself: stdout only, and every git call is read-only (spec §2).
- Python 3.8 or later, standard library only; the suite passes `shellcheck --shell=sh --exclude=SC2015`, like the other suites.
- Every report states its limits verbatim: the three comparison caveats (spec §5) and the "cannot answer" list (spec §7).
- Unexpected repository state is a stop and a question to Daniel, never an automated stash, rebase or reset.

## Rulings carried from the spec cycle's collected Minors

The spec is closed and is not edited. Where the collected Minors of passes 2–3 (`.context/codex-reviews/gate-a-spec-p9yvzn4fvi-pass-2.md`, `-pass-3.md`) pointed at an implementation choice, the plan takes it as below; the Gate-B call names these.

1. **No pass-count ceiling.** The expanded pass count must equal the length of the supplied count series, and that is checked **before** anything is allocated, so a huge range costs nothing and needs no cap. Python's integer-digit cap (3.11+) is lifted at start, so every Python accepts the same pass numbers. (Replaces the spec's "more than 10000" sentence, which pass 2 found stricter than §5's grammar.)
2. **Git reads ignore grafts, shallow-file overrides and signatures and cannot be ambiguous:** every call sets `GIT_GRAFT_FILE` to the null device and drops an inherited `GIT_SHALLOW_FILE`, besides `--no-replace-objects`; `git log` adds `--no-show-signature` and ends with `<sha> --`.
3. **Shallow state is read before and after the walk**; either reading `true` marks the history truncated. A boundary that exists only between the two readings is not detected — a stated limit, printed in the report's "cannot answer" list.
4. **Output and the one-line error are UTF-8 whatever the locale** (`backslashreplace` for anything unencodable), and **every source-derived field** — fingerprints, rungs, story sets, skip excerpts, raw lines — goes through the same control-character display.
5. **The printed check command** is `git --no-replace-objects show …`, so it reads what the script read.
6. **A skip record's key is its marker plus the excerpt**, so two copies differing only after the first paragraph are one record. The excerpt label says the text is partial.
7. Left as stated limits, not changed: an undecodable byte becomes U+FFFD **before** grouping, so two fingerprints or story paths differing only in undecodable bytes count as one (this repository's ledger and commit bodies are UTF-8, so the case does not arise here); and `\xNN` display can coincide with a literal backslash sequence in what is printed. Both are printed in the report's "cannot answer" list.

## Review Focus

1. **A different Python on CI.** Ubuntu 24.04's `python3` (3.12) runs the suite in CI; locally 3.12 and 3.9 gave identical reports. → Task 3 Step 5 reads the CI log for `30 passed, 0 failed`.
2. **A real `main` with ~60 commits.** Expect a full report quickly and no unparsed lines. → Task 1 Step 6.
3. **A body line that starts with `cycle` in prose.** Expect it ignored. → fixture line "cycle closed on the zero-finding exit below the floor."
4. **Different git versions.** Fixture SHAs depend only on content, identity and dates; a mismatch on CI is a stop, not a re-record.
5. **Uncommitted ledger edits.** Expect them ignored. → suite case "working-tree ledger edit does not change the report".

---

## File map

| Path | Change | Task |
|---|---|---|
| `scripts/ledger-metrics.test.sh` | Create | 1 |
| `scripts/ledger-metrics.py` | Create | 1 |
| `AGENTS.md` | Layout tree, Boundaries, § Commands quality + lint rows, prerequisites | 2 |
| `.github/workflows/ci.yml` | Lint step, suite step, two comments | 2 |
| `README.md` | Contributing: wording + one paragraph on running the report | 2 |
| `CLAUDE.md` | §5 Mechanics: the sentence saying the metrics consumer "does not exist yet" | 2 |

---

### Task 1: The suite, then the script

**Files:**
- Create: `scripts/ledger-metrics.test.sh`
- Create: `scripts/ledger-metrics.py`

**Interfaces:**
- Produces: `python3 scripts/ledger-metrics.py [<ref>]` → report on stdout, exit 0; exit 1 with `ledger-metrics: <cause>` on stderr. `sh scripts/ledger-metrics.test.sh` → `ok   -`/`FAIL -` lines, then `<n> passed, <m> failed`, exit 0 only when `m` is 0.

- [ ] **Step 1: Write the suite**

Create `scripts/ledger-metrics.test.sh` with exactly this content:

````sh
#!/bin/sh
# Regression suite for ledger-metrics.py.
#
# Spec: docs/superpowers/specs/2026-10-01-passive-metrics-design.md §6. Every case builds
# a throwaway repository with fixed author/committer dates, so commit SHAs and therefore
# the report are deterministic, and compares the report against expected text.
#
# Order matters: the prior-state counterfactual and the negative control run FIRST, so
# a suite that cannot fail is caught before any green case is believed.
set -u

SCRIPT="$(cd "$(dirname "$0")" && pwd)/ledger-metrics.py"
pass_n=0; fail_n=0
pass() { pass_n=$((pass_n + 1)); printf 'ok   - %s\n' "$1"; }
fail() { fail_n=$((fail_n + 1)); printf 'FAIL - %s\n' "$1"; }

work=$(mktemp -d) || work=''
# Abort rather than continue with an empty $work: every path below is built under it.
if [ -z "$work" ] || [ ! -d "$work" ]; then
  printf 'FAIL - could not create a temporary directory; refusing to run\n' >&2
  exit 1
fi
trap 'rm -rf "$work"' EXIT
# An empty HOME and XDG_CONFIG_HOME: git finds no global attributes, ignore or config files
# there, so nothing from the developer's home can change what a fixture commit stores.
mkdir -p "$work/home/.config" && HOME="$work/home" && XDG_CONFIG_HOME="$work/home/.config" &&
  export HOME XDG_CONFIG_HOME

# Isolation: no global or system git config, no inherited repository variables, no init
# templates. Identity and dates are fixed per invocation, so every SHA is reproducible and
# the suite never touches the developer's git setup.
GIT_CONFIG_GLOBAL=/dev/null; GIT_CONFIG_NOSYSTEM=1; GIT_ATTR_NOSYSTEM=1
export GIT_CONFIG_GLOBAL GIT_CONFIG_NOSYSTEM GIT_ATTR_NOSYSTEM
unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_OBJECT_DIRECTORY GIT_ALTERNATE_OBJECT_DIRECTORIES \
      GIT_CEILING_DIRECTORIES GIT_DEFAULT_HASH GIT_COMMON_DIR GIT_NAMESPACE \
      GIT_CONFIG_COUNT GIT_CONFIG_PARAMETERS GIT_REPLACE_REF_BASE GIT_SHALLOW_FILE \
      GIT_GRAFT_FILE GIT_NO_REPLACE_OBJECTS
tick=1700000000
gitc() {
  GIT_AUTHOR_NAME=t GIT_AUTHOR_EMAIL=t@example.com GIT_COMMITTER_NAME=t GIT_COMMITTER_EMAIL=t@example.com \
  GIT_AUTHOR_DATE="$tick +0000" GIT_COMMITTER_DATE="$tick +0000" \
    git -c user.name=t -c user.email=t@example.com -c commit.gpgsign=false \
        -c init.defaultBranch=main "$@"
}
# Commit everything with the given message (printf %b escapes), one second later each time.
# The message is an argument, never piped in: a pipeline runs `commit` in a subshell,
# which would lose the tick increment and give every commit the same date.
commit() { tick=$((tick + 1)); printf '%b' "$1" > "$work/msg"; gitc add -A && gitc commit -q --allow-empty -F "$work/msg"; }

newrepo() { rm -rf "${work:?}/$1"; mkdir -p "$work/$1/docs" && (cd "$work/$1" && gitc init -q --template= --object-format=sha1 .); }
# Every run is wrapped in the no-write check: a run that changes the fixture leaves a marker
# outside it, and the suite fails at the end if any marker exists (spec §6).
# run DIR SCRIPT [REF]: stdout only, status preserved.
run() {
  _b=$(snapshot "$1")
  (cd "$1" && python3 "$2" ${3+"$3"}); _s=$?
  [ "$_b" = "$(snapshot "$1")" ] || : > "$work/WROTE.$(basename "$1")"
  return "$_s"
}
report() { run "$work/$1" "$2" ${3+"$3"} 2>&1; }

# A whole-directory fingerprint: every path with its mode and size, plus a checksum of
# every file's contents. Equal before and after a run means the run left no file
# changed, added or removed in the fixture (spec §6 states what this does NOT catch).
snapshot() { (cd "$1" && ls -lAR . && find . -type f -exec cksum {} + | sort); }

# The one comparison every golden case uses; the negative control calls it too, so a
# comparison that stopped comparing would be caught there.
same() { diff "$work/expected" "$work/actual" > "$work/diff"; }
expect() { # name, expected (stdin), actual
  printf '%s\n' "$2" > "$work/actual"
  cat > "$work/expected"
  if same; then pass "$1"
  else fail "$1"; sed 's/^/    /' "$work/diff"; fi
}

# ---- fixture: the ledger --------------------------------------------------------
LEDGER_HEAD='# Hardening log

Columns: date, fingerprint, finding, source, severity, rung, ref.

| date | fingerprint | finding | source | severity | rung | ref |
|------|-------------|---------|--------|----------|------|-----|'
mk_ledger_repo() {
  newrepo L
  {
    printf '%s\n' "$LEDGER_HEAD"
    printf '%s\n' '| 2026-01-01 | alpha-one | f1 | gate-a | major | 1 prose | r |'
    printf '%s\n' '| 2026-01-02 | beta | a \| piped finding | bot | minor | P std | r |'
    printf '%s\n' '| 2026-01-03 | alpha-one | f3 | bot | major | 2 lint | r |'
    printf '%s\n' '| 2026-01-04 | alpha-one | short row | bot |'
    printf '%s\n' '| 2026-01-05 | gamma | f5 | bot | nit | pending | r |'
    printf '%s\n' '| 2026-01-06 | Bad-Case | f6 | bot | nit | 1 prose | r |'
    printf '%s\n' '| 2026-01-07 | delta | f7 | bot | nit |  | r |'
    printf '%s\n' '| 2026-01-08 | delta | f8 | bot | nit | 0 | r |'
    printf '%s\n' "- 2026-01-09 · supersedes 2026-01-01 \`alpha-one\` \"f1\" · wrong · see row"
  } > "$work/L/docs/hardening-log.md"
  (cd "$work/L" && commit 'ledger\n')
}

ledger_section() { sed -n '/^== Ledger: recurrence/,/^== Git: review cycles/p' | sed '$d'; }
LEDGER_EXPECTED='== Ledger: recurrence (rows matched exactly as harden-finding greps column 2)
3  alpha-one  lines 7,9,10  rungs 1 prose > 2 lint > ?
2  delta  lines 13,14  rungs  > 0
1  Bad-Case  lines 12  rungs 1 prose
1  beta  lines 8  rungs P std
1  gamma  lines 11  rungs pending
check one count: git --no-replace-objects show <commit>:docs/hardening-log.md | grep -cE '"'"'^\| *[0-9-]{10} *\| *<fingerprint> *\|'"'"'
  (<commit> is the commit in the header; use a fingerprint from the list. No command fits an irregular fingerprint, because grep would read it as a pattern.)

== Ledger: rung holding
1 prose  landed 2  followed-by-same-fingerprint 1  last-of-fingerprint 1
2 lint  landed 1  followed-by-same-fingerprint 1  last-of-fingerprint 0
P std  landed 1  followed-by-same-fingerprint 0  last-of-fingerprint 1
pending 1
"followed" means a later row with the same fingerprint exists - nothing more. It does not mean
the rung failed (a later row can be a different sub-shape, an out-of-scope guard, or a resolved
prerequisite), and "last" does not mean it held (an unhardened recurrence leaves no row).

== Ledger: irregular rows
irregular width: line 10 (4 cells)
irregular fingerprint: line 12
irregular rung: line 13 (rung '"''"')
irregular rung: line 14 (rung '"'0'"')'

# ---- 1. counterfactual: the prior state has no script --------------------------
mk_ledger_repo
out=$(report L "$work/L/scripts/ledger-metrics.py"); st=$?
if [ "$st" -ne 0 ] && [ ! -e "$work/L/scripts/ledger-metrics.py" ]; then
  pass "prior state: no script exists, so no report can be produced (exit $st)"
else fail "prior state: expected a failing run with no script, got exit $st"; fi

# ---- 2. negative control: a count off by one must fail the count comparison ----------
# The broken copy must still run to completion (exit 0), and its report must differ from
# the expected text in the count column - here alpha-one reads 4 instead of 3. A copy
# that crashes, or whose report still matches, proves nothing about the comparison.
sed 's/n = len(by_fp\[fp\])$/n = len(by_fp[fp]) + 1/' "$SCRIPT" > "$work/broken.py"
if cmp -s "$SCRIPT" "$work/broken.py"; then
  fail "negative control: the mutation did not apply, so it proves nothing"
else
  out=$(report L "$work/broken.py"); st=$?
  printf '%s\n' "$LEDGER_EXPECTED" > "$work/expected"
  printf '%s\n' "$out" | ledger_section > "$work/actual"
  if [ "$st" -eq 0 ] && ! same &&
     grep -qx '4  alpha-one  lines 7,9,10  rungs 1 prose > 2 lint > ?' "$work/actual"; then
    pass "negative control: the broken copy exits 0 and the count comparison catches it"
  else
    fail "negative control: broken copy (exit $st) was not caught by the count comparison"
  fi
fi

# ---- 3. ledger section ------------------------------------------------------------
out=$(report L "$SCRIPT"); st=$?
[ "$st" -eq 0 ] && pass "ledger fixture: exit 0" || fail "ledger fixture: exit $st"
expect "ledger: recurrence, rung holding and irregular rows" "$(printf '%s\n' "$out" | ledger_section)" <<EOF
$LEDGER_EXPECTED
EOF

# The printed check command must agree with the reported count for a regular fingerprint.
# The printed check command, run as printed (placeholders filled), must agree with the count.
c=$(printf '%s\n' "$out" | sed -n 's/^commit \([0-9a-f]*\) .*/\1/p')
cmd=$(printf '%s\n' "$out" | sed -n 's/^check one count: //p' | sed "s/<commit>/$c/; s/<fingerprint>/alpha-one/")
n=$(cd "$work/L" && sh -c "$cmd")
[ "$n" = 3 ] && pass "printed check command reproduces alpha-one = 3" || fail "printed check command gave '$n' ($cmd)"

# The "cannot answer" footer is printed in full.
expect "footer: what the report cannot answer" "$(printf '%s\n' "$out" | sed -n '/^== What this report cannot answer/,$p')" <<'FOOTER'
== What this report cannot answer
- Unlogged recurrences: the ledger only knows recurrences someone hardened.
- Whether a guard held: row succession is not guard failure, and a missing later row is not success.
- Cycles with no record at all: before 0.11.0 the curve was a habit, not a rule. A cycle with no provenance line, curve or skip record is invisible; a malformed record shows up as unparsed only when its line still starts like a record ("cycle <token>;").
- Nonce attribution: records are grouped by nonce, which is collision-resistant, not collision-proof; two cycles that drew the same nonce read as one.
- Findings files: this script does not read .context/. It counts only what commit bodies say.
- Undecodable bytes: both sources are read as UTF-8 and an invalid byte becomes U+FFFD before anything is grouped, so two fingerprints or paths differing only in invalid bytes count as one. Control characters are shown as \xNN, which can look like a literal backslash sequence.
- A shallow boundary that appears and disappears during the run: shallow state is checked before and after reading history, not during it.
- Whether a curve is true: see point 1 above.
- Cost and duration: that is vision step 2c's telemetry, out of scope here.
FOOTER

# Uncommitted ledger edits are not read.
printf '%s\n' '| 2026-01-10 | alpha-one | uncommitted | bot | nit | 1 prose | r |' >> "$work/L/docs/hardening-log.md"
out2=$(report L "$SCRIPT"); st=$?
[ "$st" -eq 0 ] && [ "$out" = "$out2" ] && pass "working-tree ledger edit does not change the report" || fail "working-tree ledger edit changed the report"

# Empty ledger.
newrepo E; printf '%s\n' "$LEDGER_HEAD" > "$work/E/docs/hardening-log.md"; (cd "$work/E" && commit 'e\n')
oute=$(report E "$SCRIPT"); st=$?
[ "$st" -eq 0 ] && pass "empty ledger: exit 0" || fail "empty ledger: exit $st"
printf '%s\n' "$oute" | grep -qx 'no rows' && pass "empty ledger prints 'no rows'" || fail "empty ledger"
printf '%s\n' "$oute" | grep -qx 'no cycle records' && pass "no records prints 'no cycle records'" || fail "no cycle records"
printf '%s\n' "$oute" | grep -qx '  no profiled cycles with a curve' && pass "comparison empty state" || fail "comparison empty state"

# ---- 4. cycle records ------------------------------------------------------------------
newrepo C; printf '%s\n' "$LEDGER_HEAD" > "$work/C/docs/hardening-log.md"
(
  cd "$work/C" || exit 1
  commit 'ledger\n'
  commit 'joined\n\ncycle aaaaaaaa; floor 3 per {docs/s.md (level 1)}; hook reminder threshold absent\ncycle aaaaaaaa; Gate B (passes 1-3,5, codex): Findings 4,3,?,1. Blockers 1,0,0,0. Majors 2,1,0,0.\n'
  commit 'curve only\n\ncycle bbbbbbbb; Gate-A spec (passes 1, pass 1 codex+"my model"): Findings 2. Blockers 0. Majors 1.\n'
  commit 'provenance only, quoted path\n\ncycle cccccccc; floor 1 per {"docs/q\\"x.md" (level 0)}; hook reminder threshold 3\ncycle closed on the zero-finding exit below the floor.\n'
  commit 'skip with reason\n\ncycle dddddddd; Gate B: skipped (see skip reason)\nSkip reason: trivial,\nsecond line.\n\nafter the blank line\n'
  commit 'skip without reason\n\ncycle eeeeeeee; Gate B: skipped (see skip reason)\n'
  commit 'pre-rule\n\ncycle none (pre-rule); floor 3 per none; hook reminder threshold absent\ncycle none (pre-rule); Gate B (passes 1, codex): Findings 0. Blockers 0. Majors 0.\ncycle none (pre-rule); Gate B (passes 1, codex): Findings 0. Blockers 0. Majors 0.\n'
  commit 'duplicate copy\n\ncycle bbbbbbbb; Gate-A spec (passes 1, pass 1 codex+"my model"): Findings 2. Blockers 0. Majors 1.\n'
  commit 'conflicts\n\ncycle ffffffff; Gate B (passes 1, codex): Findings 1. Blockers 0. Majors 0.\ncycle ffffffff; Gate B (passes 1, codex): Findings 2. Blockers 0. Majors 0.\ncycle gggggggg; Gate B (passes 1, codex): Findings 1. Blockers 0. Majors 0.\ncycle gggggggg; Gate B: skipped (see skip reason)\nreason g\n\ncycle iiiiiiii; floor 3 per none; hook reminder threshold absent\ncycle iiiiiiii; floor 3 per {docs/s.md (level 0)}; hook reminder threshold absent\n'
  commit 'skip reason A\n\ncycle hhhhhhhh; Gate B: skipped (see skip reason)\nreason A\n'
  commit 'skip reason B\n\ncycle hhhhhhhh; Gate B: skipped (see skip reason)\nreason B\n'
  commit 'malformed\n\ncycle abcdefg; floor 3 per none; hook reminder threshold absent\ncycle jjjjjjjj;floor 3 per none; hook reminder threshold absent\ncycle jjjjjjjj; floor 3 per {a.md (level 1),a.md (level 1)}; hook reminder threshold absent\ncycle jjjjjjjj; Gate B (passes 1-2, codex): Findings 1,2,3. Blockers 0,0. Majors 0,0.\ncycle jjjjjjjj; Gate B (passes 1-2, pass 1 codex): Findings 1,2. Blockers 0,0. Majors 0,0.\ncycle jjjjjjjj; Gate B (passes 1, "bad\\q"): Findings 1. Blockers 0. Majors 0.\ncycle jjjjjjjj; Gate B (passes 1, "tab\there"): Findings 1. Blockers 0. Majors 0.\ncycle jjjjjjjj; floor 3 per {a.md (level 1),"a.md" (level 1)}; hook reminder threshold absent\ncycle oooooooo; Gate B (passes 1, "a; b): c"): Findings 1. Blockers 0. Majors 0.\n'
  commit 'skip then record\n\ncycle kkkkkkkk; Gate B: skipped (see skip reason)\ncycle llllllll; floor 1 per {docs/u.md (unprofiled)}; hook reminder threshold absent\n'
  commit 'grammar 2\n\ncycle pppppppp; Gate-A plan (passes 1-2, pass 1 "model+variant"; pass 2 "a\\\\\\\\b"+codex): Findings 1,0. Blockers 0,0. Majors 1,0.\ncycle rrrrrrrr; floor 1 per {docs/a.md (level 0),docs/b.md (level 1)}; hook reminder threshold absent\ncycle ssssssss; Gate B (passes 1-100000000, codex): Findings 1. Blockers 0. Majors 0.\n'
  gitc checkout -q -b side
  commit 'side branch record\n\ncycle mmmmmmmm; Gate B (passes 1, codex): Findings 0. Blockers 0. Majors 0.\n'
  gitc checkout -q main
  tick=$((tick + 1)); gitc merge -q --no-ff -m 'merge side' side
  commit 'licensed floor 1 recorded as floor 3\n\ncycle nnnnnnnn; floor 3 per {docs/z.md (level 0)}; hook reminder threshold absent\ncycle nnnnnnnn; Gate B (passes 1, codex): Findings 0. Blockers 0. Majors 0.\n'
)
git_section() { sed -n '/^== Git: review cycles/,/^== What this report cannot answer/p' | sed '1d;$d'; }
out=$(report C "$SCRIPT"); st=$?
[ "$st" -eq 0 ] && pass "cycle fixture: exit 0" || fail "cycle fixture: exit $st"
expect "cycles, conflicts, unparsed, comparison and checkpoint" "$(printf '%s\n' "$out" | git_section)" <<'EOF'
aaaaaaaa  Gate B  passes 1-3,5  floor 3  set {docs/s.md (level 1)}  findings 4,3,?,1 (? 1)  blockers 1,0,0,0 (? 0)  majors 2,1,0,0 (? 0)
bbbbbbbb  Gate-A spec  passes 1  floor -  set -  findings 2 (? 0)  blockers 0 (? 0)  majors 1 (? 0)
cccccccc  no curve  floor 1  set {"docs/q\"x.md" (level 0)}
dddddddd  Gate B  skipped  floor -  set -  reason excerpt: Skip reason: trivial, second line.  commit ae01f24cfccb
eeeeeeee  Gate B  skipped  floor -  set -  reason excerpt: no reason found  commit 68042820934b
none (pre-rule)  Gate B  passes 1  floor -  set -  findings 0 (? 0)  blockers 0 (? 0)  majors 0 (? 0)  commit 3333a18313c4  [may duplicate another pre-rule record]
none (pre-rule)  Gate B  passes 1  floor -  set -  findings 0 (? 0)  blockers 0 (? 0)  majors 0 (? 0)  commit 3333a18313c4  [may duplicate another pre-rule record]
none (pre-rule)  no curve  floor 3  set none  commit 3333a18313c4  [may duplicate another pre-rule record]
oooooooo  Gate B  passes 1  floor -  set -  findings 1 (? 0)  blockers 0 (? 0)  majors 0 (? 0)
kkkkkkkk  Gate B  skipped  floor -  set -  reason excerpt: no reason found  commit 13f09168f5c1
llllllll  no curve  floor 1  set {docs/u.md (unprofiled)}
pppppppp  Gate-A plan  passes 1-2  floor -  set -  findings 1,0 (? 0)  blockers 0,0 (? 0)  majors 1,0 (? 0)
rrrrrrrr  no curve  floor 1  set {docs/a.md (level 0),docs/b.md (level 1)}
mmmmmmmm  Gate B  passes 1  floor -  set -  findings 0 (? 0)  blockers 0 (? 0)  majors 0 (? 0)
nnnnnnnn  Gate B  passes 1  floor 3  set {docs/z.md (level 0)}  findings 0 (? 0)  blockers 0 (? 0)  majors 0 (? 0)
seen in several commits: cycle bbbbbbbb; Gate-A spec (passes 1, pass 1 codex+"my model"): Findings 2. Blockers 0. Majors 1. -> d61f00c143a8,34329462931c

== Git: conflicts (records sharing a nonce that disagree; not listed as cycles)
ffffffff  cycle ffffffff; Gate B (passes 1, codex): Findings 1. Blockers 0. Majors 0.
ffffffff  cycle ffffffff; Gate B (passes 1, codex): Findings 2. Blockers 0. Majors 0.
gggggggg  cycle gggggggg; Gate B (passes 1, codex): Findings 1. Blockers 0. Majors 0.
gggggggg  cycle gggggggg; Gate B: skipped (see skip reason) | reason g
iiiiiiii  cycle iiiiiiii; floor 3 per none; hook reminder threshold absent
iiiiiiii  cycle iiiiiiii; floor 3 per {docs/s.md (level 0)}; hook reminder threshold absent
hhhhhhhh  cycle hhhhhhhh; Gate B: skipped (see skip reason) | reason A
hhhhhhhh  cycle hhhhhhhh; Gate B: skipped (see skip reason) | reason B

== Git: unparsed candidate lines
7c5d9cd9db31  cycle abcdefg; floor 3 per none; hook reminder threshold absent
7c5d9cd9db31  cycle jjjjjjjj; Gate B (passes 1, "bad\q"): Findings 1. Blockers 0. Majors 0.
7c5d9cd9db31  cycle jjjjjjjj; Gate B (passes 1, "tab\x09here"): Findings 1. Blockers 0. Majors 0.
7c5d9cd9db31  cycle jjjjjjjj; Gate B (passes 1-2, codex): Findings 1,2,3. Blockers 0,0. Majors 0,0.
7c5d9cd9db31  cycle jjjjjjjj; Gate B (passes 1-2, pass 1 codex): Findings 1,2. Blockers 0,0. Majors 0,0.
7c5d9cd9db31  cycle jjjjjjjj; floor 3 per {a.md (level 1),"a.md" (level 1)}; hook reminder threshold absent
7c5d9cd9db31  cycle jjjjjjjj; floor 3 per {a.md (level 1),a.md (level 1)}; hook reminder threshold absent
7c5d9cd9db31  cycle jjjjjjjj;floor 3 per none; hook reminder threshold absent
4b1693862af7  cycle ssssssss; Gate B (passes 1-100000000, codex): Findings 1. Blockers 0. Majors 0.

== Comparison with the fic2 baseline (story criterion 5)
profiled cycles (joined, with a curve, set has a (level N) entry):
  aaaaaaaa  Gate B  passes 1-3,5  floor 3  set {docs/s.md (level 1)}  findings 4,3,?,1 (? 1)  blockers 1,0,0,0 (? 0)  majors 2,1,0,0 (? 0)
  nnnnnnnn  Gate B  passes 1  floor 3  set {docs/z.md (level 0)}  findings 0 (? 0)  blockers 0 (? 0)  majors 0 (? 0)
fic2 baseline (docs/field-reports/2026-08-26-fic2-cycle-evidence.md, passes 1-5; story §1, passes 6-7):
  findings 14,24,12,3,6,6,2 (? 0)  blockers 3,4,0,0,0,0,0 (? 0)  majors 5,13,6,2,5,?,? (? 2)
1. The curves are author-written and unchecked. Nothing compares them against the validated pass files, so they are self-reported and not measurement.
2. The cycles reviewed different artifacts, so a difference is evidence about the population as much as about the rule.
3. No demotion figure is derivable. That would need one finding classified under both rules, and nothing records that.

== First checkpoint: evidence (the reader decides)
provenance lines whose set licenses floor 1:
  cccccccc  recorded floor 1  commit 4364bb042d4d
  iiiiiiii  recorded floor 3  commit 85b7cc11dd38
  nnnnnnnn  recorded floor 3  commit 77b3167bb0fd
provenance lines recording floor 1:
  cccccccc  floor 1  set licenses it  commit 4364bb042d4d
  llllllll  floor 1  set does not license it  commit 13f09168f5c1
  rrrrrrrr  floor 1  set does not license it  commit 4b1693862af7
EOF

# A worktree file named like the commit SHA must not make `git log <sha>` ambiguous, and a
# caller's log.showSignature must not leak signature text into the parsed stream.
sha=$(cd "$work/C" && git rev-parse HEAD); : > "$work/C/$sha"
out3=$(GIT_CONFIG_COUNT=1 GIT_CONFIG_KEY_0=log.showSignature GIT_CONFIG_VALUE_0=true report C "$SCRIPT"); st=$?
rm -f "$work/C/$sha"
[ "$st" -eq 0 ] && [ "$out3" = "$out" ] &&
  pass "SHA-named worktree file and log.showSignature leave the report unchanged" ||
  fail "SHA-named file / showSignature changed the report (exit $st)"

# A 5001-digit pass number is valid under the §5 grammar on every Python (3.11+ caps int()
# at 4300 digits unless lifted), and a per-pass key that does not match its pass is unparsed.
newrepo T; printf '%s\n' "$LEDGER_HEAD" > "$work/T/docs/hardening-log.md"
long=$(printf '%05001d' 0 | tr 0 1)
(cd "$work/T" && commit "t\n\ncycle tttttttt; Gate B (passes $long, pass $long codex): Findings 1. Blockers 0. Majors 0.\ncycle uuuuuuuu; Gate B (passes 1, pass $long codex): Findings 1. Blockers 0. Majors 0.\n")
outt=$(report T "$SCRIPT"); st=$?
[ "$st" -eq 0 ] && printf '%s\n' "$outt" | grep -q '^tttttttt  Gate B  passes 1111' &&
  pass "5001-digit pass number: parsed as a cycle" || fail "5001-digit pass number (exit $st)"
printf '%s\n' "$outt" | grep -q '^[0-9a-f]\{12\}  cycle uuuuuuuu; Gate B (passes 1, pass 1111' &&
  pass "per-pass key not matching its pass: unparsed, no crash" || fail "mismatched per-pass key"

# Two conflict groups whose first records share a commit stay contiguous (group, then nonce).
newrepo O; printf '%s\n' "$LEDGER_HEAD" > "$work/O/docs/hardening-log.md"
(
  cd "$work/O" || exit 1
  commit 'o1\n\ncycle aaaaaaaa; Gate B (passes 1, codex): Findings 1. Blockers 0. Majors 0.\ncycle bbbbbbbb; Gate B (passes 1, codex): Findings 1. Blockers 0. Majors 0.\n'
  commit 'o2\n\ncycle bbbbbbbb; Gate B (passes 1, codex): Findings 2. Blockers 0. Majors 0.\n'
  commit 'o3\n\ncycle aaaaaaaa; Gate B (passes 1, codex): Findings 2. Blockers 0. Majors 0.\n'
)
outo=$(report O "$SCRIPT"); st=$?
order=$(printf '%s\n' "$outo" | sed -n '/^== Git: conflicts/,/^$/p' | sed -n 's/^\([a-z]*\)  cycle [a-z]*; Gate B (passes 1, codex): Findings \([0-9]\).*/\1\2/p' | tr '\n' ' ')
[ "$st" -eq 0 ] && [ "$order" = "aaaaaaaa1 aaaaaaaa2 bbbbbbbb1 bbbbbbbb2 " ] &&
  pass "tied conflict groups stay contiguous" || fail "conflict order: $order"

# A pre-rule skip names its commit once.
newrepo Q; printf '%s\n' "$LEDGER_HEAD" > "$work/Q/docs/hardening-log.md"
(cd "$work/Q" && commit 'q\n\ncycle none (pre-rule); Gate B: skipped (see skip reason)\nwhy\n')
outq=$(report Q "$SCRIPT"); st=$?
n=$(printf '%s\n' "$outq" | grep '^none (pre-rule)  Gate B  skipped' | grep -o '  commit ' | wc -l | tr -d ' ')
[ "$st" -eq 0 ] && [ "$n" = 1 ] && pass "pre-rule skip names its commit once" || fail "pre-rule skip: exit $st, commit count $n"

# An escaped final pipe does not close a row, and CRLF rows read like LF rows.
newrepo X
{ printf '%s\n' "$LEDGER_HEAD"
  printf '%s\n' '| 2026-01-01 | esc | f | bot | nit | 1 prose | ref ends r\|'
  printf '%s\r\n' '| 2026-01-02 | crlf | f | bot | nit | 2 lint | r |'
} > "$work/X/docs/hardening-log.md"
(cd "$work/X" && commit 'x\n')
outx=$(report X "$SCRIPT"); st=$?
[ "$st" -eq 0 ] && printf '%s\n' "$outx" | grep -qx '1  esc  lines 7  rungs 1 prose' &&
  printf '%s\n' "$outx" | grep -qx '1  crlf  lines 8  rungs 2 lint' &&
  printf '%s\n' "$outx" | sed -n '/^== Ledger: irregular rows/,+1p' | grep -qx 'none' &&
  pass "escaped final pipe and CRLF rows are regular" || fail "escaped pipe / CRLF rows"

# The one-line error is UTF-8 whatever the locale says.
PYTHONIOENCODING=latin1 run "$work/L" "$SCRIPT" "$(printf 'caf\303\251')" > /dev/null 2> "$work/err"; st=$?
e=$(od -An -tx1 < "$work/err" | tr -d ' \n')
case $st:$e in 1:*c3a9*) pass "error message is UTF-8 under a latin1 locale (exit 1)" ;; *) fail "UTF-8 error: exit $st, bytes $e" ;; esac

# Only conflicting records: the cycle list says why it is empty.
newrepo K; printf '%s\n' "$LEDGER_HEAD" > "$work/K/docs/hardening-log.md"
(cd "$work/K" && commit 'k\n\ncycle qqqqqqqq; Gate B (passes 1, codex): Findings 1. Blockers 0. Majors 0.\ncycle qqqqqqqq; Gate B (passes 1, codex): Findings 2. Blockers 0. Majors 0.\n')
outk=$(report K "$SCRIPT"); st=$?
[ "$st" -eq 0 ] && printf '%s\n' "$outk" | grep -qx 'no joined cycles (every record is in a conflict below)' &&
  pass "conflict-only history: the cycle list says why it is empty" || fail "conflict-only empty label"

# ---- 5. exit-1 causes -----------------------------------------------------------------
bad() { # name, expected stderr substring, dir, [ref]
  e=$(run "$3" "$SCRIPT" ${4+"$4"} 2>&1 >/dev/null); s=$?
  if [ "$s" -eq 1 ] && printf '%s' "$e" | grep -qF "$2"; then pass "$1"; else fail "$1 (exit $s: $e)"; fi
}
mkdir -p "$work/norepo"
bad "not a git repository" "ledger-metrics: not a git repository" "$work/norepo"
bad "unresolvable ref" "ledger-metrics: ref does not resolve to a commit: nope" "$work/L" nope
newrepo A; (cd "$work/A" && printf 'x\n' > x && commit 'x\n')
bad "ledger absent" "ledger-metrics: ledger absent at" "$work/A"
newrepo D; mkdir -p "$work/D/docs/hardening-log.md" && printf 'x\n' > "$work/D/docs/hardening-log.md/f"; (cd "$work/D" && commit 'd\n')
bad "ledger is a directory" "ledger-metrics: ledger is not a regular file" "$work/D"
newrepo S; printf '%s\n' "$LEDGER_HEAD" > "$work/S/real.md"; ln -s ../real.md "$work/S/docs/hardening-log.md"; (cd "$work/S" && commit 's\n')
bad "ledger is a symlink" "ledger-metrics: ledger is not a regular file" "$work/S"
newrepo G; printf '%s\n' "$LEDGER_HEAD" > "$work/G/docs/hardening-log.md"
(cd "$work/G" && commit 'one\n' && printf 'y\n' > y && commit 'two\n')
first=$(cd "$work/G" && git rev-parse HEAD~1)
rm -f "$work/G/.git/objects/$(printf '%s' "$first" | cut -c1-2)/$(printf '%s' "$first" | cut -c3-)"
bad "git log fails" "ledger-metrics: git log failed" "$work/G"
newrepo U; printf '%s\n' "$LEDGER_HEAD" > "$work/U/docs/hardening-log.md"; (cd "$work/U" && commit 'u\n')
blob=$(cd "$work/U" && git rev-parse HEAD:docs/hardening-log.md)
rm -f "$work/U/.git/objects/$(printf '%s' "$blob" | cut -c1-2)/$(printf '%s' "$blob" | cut -c3-)"
bad "ledger cannot be read" "ledger-metrics: ledger cannot be read" "$work/U"

# ---- 6. shallow clone -------------------------------------------------------------------
rm -rf "$work/shallow"; git clone -q --depth 1 "file://$work/C" "$work/shallow" 2>/dev/null
out=$(report shallow "$SCRIPT"); st=$?
[ "$st" -eq 0 ] && printf '%s\n' "$out" | grep -qx 'history: truncated (shallow clone): absence not established' &&
  pass "shallow clone: header says history is truncated" || fail "shallow clone header"

set -- "$work"/WROTE.*
if [ -e "$1" ]; then fail "no-write: a run changed its fixture ($*)"
else pass "no-write: no run changed its fixture"; fi

printf '\n%d passed, %d failed\n' "$pass_n" "$fail_n"
[ "$fail_n" -eq 0 ]
````

- [ ] **Step 2: Run it before the script exists**

Run: `sh scripts/ledger-metrics.test.sh > /tmp/lm-red.log 2>&1; echo "exit=$?"; tail -1 /tmp/lm-red.log`
Expected: `exit=1`, and the last line reports failures. The prior-state case passes; the negative-control case fails (its mutation has nothing to apply to).

- [ ] **Step 3: Write the script**

Create `scripts/ledger-metrics.py` with exactly this content:

````python
#!/usr/bin/env python3
"""Read-only report over docs/hardening-log.md and the review-cycle records in git commit bodies.

Spec: docs/superpowers/specs/2026-10-01-passive-metrics-design.md
Usage: python3 scripts/ledger-metrics.py [<ref>]   (default HEAD)

Reads the ledger and the commit bodies at ONE resolved commit, never the working tree, and
prints a report on stdout. It writes no file, ref or config itself; git can still write when
the caller's environment tells it to (spec §2), which the report header states.
Standard library only; Python 3.8 or later.
"""
import os
import re
import subprocess
import sys

LEDGER = "docs/hardening-log.md"
ALLOWED_RUNGS = ("1 prose", "2 lint", "3 type", "4 test", "P std", "pending")
FIC2 = ("  findings 14,24,12,3,6,6,2 (? 0)  blockers 3,4,0,0,0,0,0 (? 0)"
        "  majors 5,13,6,2,5,?,? (? 2)")
CAVEATS = (
    "1. The curves are author-written and unchecked. Nothing compares them against the validated"
    " pass files, so they are self-reported and not measurement.",
    "2. The cycles reviewed different artifacts, so a difference is evidence about the population"
    " as much as about the rule.",
    "3. No demotion figure is derivable. That would need one finding classified under both rules,"
    " and nothing records that.",
)
CANNOT = """
== What this report cannot answer
- Unlogged recurrences: the ledger only knows recurrences someone hardened.
- Whether a guard held: row succession is not guard failure, and a missing later row is not success.
- Cycles with no record at all: before 0.11.0 the curve was a habit, not a rule. A cycle with no provenance line, curve or skip record is invisible; a malformed record shows up as unparsed only when its line still starts like a record ("cycle <token>;").
- Nonce attribution: records are grouped by nonce, which is collision-resistant, not collision-proof; two cycles that drew the same nonce read as one.
- Findings files: this script does not read .context/. It counts only what commit bodies say.
- Undecodable bytes: both sources are read as UTF-8 and an invalid byte becomes U+FFFD before anything is grouped, so two fingerprints or paths differing only in invalid bytes count as one. Control characters are shown as \\xNN, which can look like a literal backslash sequence.
- A shallow boundary that appears and disappears during the run: shallow state is checked before and after reading history, not during it.
- Whether a curve is true: see point 1 above.
- Cost and duration: that is vision step 2c's telemetry, out of scope here."""


def die(msg):
    sys.stderr.buffer.write(("ledger-metrics: %s\n" % msg).encode("utf-8", "backslashreplace"))
    sys.stderr.flush()
    sys.exit(1)


def git(*args):
    """Run a read-only git command; return (returncode, stdout bytes). Stderr is not shown,
    so the only error a caller sees is this script's own one-line message."""
    try:
        # --no-replace-objects and an empty graft file: read the objects and history the SHA
        # names, not `git replace` substitutes or legacy grafts. Both affect reading only.
        env = dict(os.environ, GIT_GRAFT_FILE=os.devnull)
        env.pop("GIT_SHALLOW_FILE", None)  # the repository's own shallow file, not an override
        p = subprocess.run(("git", "--no-replace-objects") + args, env=env,
                           stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    except OSError:
        die("git could not be run")
    return p.returncode, p.stdout


# ---- grammar (CLAUDE.md §5 Mechanics) ------------------------------------------------------

NONCE = r"[a-z0-9]{8,16}"
FIELD = r"(none \(pre-rule\)|" + NONCE + r")"
KIND = r"(Gate-A spec|Gate-A plan|Gate B)"
CANDIDATE = re.compile(r"^cycle (none \(pre-rule\)|[^ ;]*);")
BARE_PATH = re.compile(r"[A-Za-z0-9._/-]+")
BARE_MODEL = re.compile(r"[!#-'*\-./0-9<-~]+")  # printable ASCII minus space " ( ) + , : ;
COUNT = re.compile(r"0|[1-9][0-9]*|\?")


def is_control(c):
    """C0, DEL and the C1 range U+0080-U+009F."""
    o = ord(c)
    return o < 0x20 or 0x7F <= o <= 0x9F


def read_quoted(s, i):
    """s[i] == '"'. Return (decoded, next_index) or None. Escapes \\" and \\\\ only; any
    control character makes the value unrepresentable, so the record is malformed."""
    out, i = [], i + 1
    while i < len(s):
        c = s[i]
        if is_control(c):
            return None
        if c == "\\":
            if i + 1 < len(s) and s[i + 1] in "\"\\":
                out.append(s[i + 1])
                i += 2
                continue
            return None
        if c == '"':
            return ("".join(out), i + 1) if out else None
        out.append(c)
        i += 1
    return None


def parse_set(s, i):
    """Parse <STORY-SET> at s[i:]. Return (entries, next_index) or None. entries is None for
    `none`, else a list of (decoded_path, level) with level '0'..'2' or 'unprofiled'."""
    if s.startswith("none", i):
        return None, i + 4
    if not s.startswith("{", i):
        return None
    i += 1
    entries, seen = [], set()
    while True:
        if i < len(s) and s[i] == '"':
            q = read_quoted(s, i)
            if q is None:
                return None
            path, i = q
        else:
            m = BARE_PATH.match(s, i)
            if not m:
                return None
            path, i = m.group(0), m.end()
        m = re.compile(r" \((level ([012])|unprofiled)\)").match(s, i)
        if not m:
            return None
        level = m.group(2) if m.group(2) is not None else "unprofiled"
        i = m.end()
        if path in seen:  # compared decoded, so "a.md" and a.md are the same path
            return None
        seen.add(path)
        entries.append((path, level))
        if s.startswith(",", i):
            i += 1
            continue
        if s.startswith("}", i):
            return entries, i + 1
        return None


def parse_model(s, i):
    """One <model> at s[i:]; return next index or None."""
    if i < len(s) and s[i] == '"':
        q = read_quoted(s, i)
        return None if q is None else q[1]
    m = BARE_MODEL.match(s, i)
    return m.end() if m else None


def expand(spec, limit):
    """Expand "1-3,5" to [1, 2, 3, 5]. The total is checked against `limit` (the length of the
    supplied count series) BEFORE anything is allocated, so a huge range costs nothing. Python's
    integer-digit cap is lifted at start (see __main__); the ValueError guard is a last resort."""
    bounds, prev, total = [], 0, 0
    for part in spec.split(","):
        m = re.fullmatch(r"([1-9][0-9]*)(?:-([1-9][0-9]*))?", part)
        if not m:
            return None
        try:
            a = int(m.group(1))
            b = int(m.group(2)) if m.group(2) else a
        except ValueError:
            return None
        if a <= prev or b < a:
            return None
        total += b - a + 1
        if total > limit:
            return None
        bounds.append((a, b))
        prev = b
    if total != limit:
        return None
    return [p for a, b in bounds for p in range(a, b + 1)]


def parse_curve(rest):
    """rest is the text after '<field>; '. Return dict or None."""
    m = re.compile(KIND + r" \(passes ([0-9,-]+), ").match(rest)
    if not m:
        return None
    kind, spec, i = m.group(1), m.group(2), m.end()
    tail = re.compile(r"\): Findings ([^ ]+)\. Blockers ([^ ]+)\. Majors ([^ ]+)\.$").search(rest)
    if not tail:
        return None
    passes = expand(spec, len(tail.group(1).split(",")))
    if passes is None:
        return None
    if rest.startswith("pass ", i):  # per-pass models
        for k, p in enumerate(passes):
            if k:
                if not rest.startswith("; ", i):
                    return None
                i += 2
            m = re.compile(r"pass ([1-9][0-9]*) ").match(rest, i)
            if not m or m.group(1) != str(p):  # compared as text: no int() on untrusted digits
                return None
            i = m.end()
            while True:
                j = parse_model(rest, i)
                if j is None:
                    return None
                i = j
                if rest.startswith("+", i):
                    i += 1
                    continue
                break
    else:
        j = parse_model(rest, i)
        if j is None:
            return None
        i = j
    m = re.compile(r"\): Findings ([^ ]+)\. Blockers ([^ ]+)\. Majors ([^ ]+)\.$").match(rest, i)
    if not m:
        return None
    series = []
    for raw in m.groups():
        vals = raw.split(",")
        if len(vals) != len(passes) or not all(COUNT.fullmatch(v) for v in vals):
            return None
        series.append(raw)
    return {"kind": kind, "spec": spec, "f": series[0], "b": series[1], "m": series[2]}


def parse_record(line):
    """Return (field, type, data) for a valid record, or None for a malformed candidate."""
    m = re.compile(r"^cycle " + FIELD + r"; ").match(line)
    if not m:
        return None
    field, rest = m.group(1), line[m.end():]
    m = re.compile(r"floor ([1-9][0-9]*) per ").match(rest)
    if m:
        parsed = parse_set(rest, m.end())
        if parsed is None:
            return None
        entries, i = parsed
        if not re.compile(r"; hook reminder threshold (absent|unusable|[1-9][0-9]*)$").fullmatch(rest, i):
            return None
        return field, "prov", {"floor": m.group(1), "set": rest[m.end():i], "entries": entries}
    m = re.fullmatch(KIND + r": skipped \(see skip reason\)", rest)
    if m:
        return field, "skip", {"kind": m.group(1)}
    c = parse_curve(rest)
    if c:
        return field, "curve", c
    return None


# ---- sections ------------------------------------------------------------------------------

def shown(text):
    """Render a raw line for output: control characters become \\xNN, so a malformed record
    cannot move the cursor or break the report's line structure."""
    return "".join("\\x%02x" % ord(c) if is_control(c) else c for c in text)


def ledger_section(text):
    out = ["", "== Ledger: recurrence (rows matched exactly as harden-finding greps column 2)"]
    rowre = re.compile(r"^\| *[0-9-]{10} *\| *([^|]*?) *\|")
    rows, irregular = [], []
    for no, line in enumerate(text.split("\n"), 1):
        line = line[:-1] if line.endswith("\r") else line  # CRLF ledgers read like LF ones
        m = rowre.match(line)
        if not m:
            continue
        cells = re.split(r"(?<!\\)\|", line)
        closed = re.search(r"(?<!\\)\| *$", line) is not None  # an escaped final pipe does not close the row
        cells = cells[1:-1] if closed else cells[1:]
        fp = cells[1].strip(" ") if len(cells) > 1 else m.group(1)
        width_ok = len(cells) == 7
        rung = cells[5].strip(" ") if width_ok else None
        rows.append((no, fp, rung))
        if not width_ok:
            irregular.append("irregular width: line %d (%d cells)" % (no, len(cells)))
        if not re.fullmatch(r"[a-z0-9]+(-[a-z0-9]+)*", fp):
            irregular.append("irregular fingerprint: line %d" % no)
    if not rows:
        out.append("no rows")
        return out
    by_fp = {}
    for no, fp, rung in rows:
        by_fp.setdefault(fp, []).append((no, rung))
    order = sorted(by_fp, key=lambda f: (-len(by_fp[f]), f))
    for fp in order:
        n = len(by_fp[fp])
        out.append("%d  %s  lines %s  rungs %s" % (
            n, shown(fp), ",".join(str(no) for no, _ in by_fp[fp]),
            " > ".join("?" if r is None else shown(r) for _, r in by_fp[fp])))
    out.append("check one count: git --no-replace-objects show <commit>:docs/hardening-log.md | grep -cE"
               " '^\\| *[0-9-]{10} *\\| *<fingerprint> *\\|'")
    out.append("  (<commit> is the commit in the header; use a fingerprint from the list. No command"
               " fits an irregular fingerprint, because grep would read it as a pattern.)")
    out += ["", "== Ledger: rung holding"]
    last = {fp: max(no for no, _ in v) for fp, v in by_fp.items()}
    landed, followed, pending = {}, {}, 0
    for no, fp, rung in rows:
        if rung is None:
            continue
        if rung not in ALLOWED_RUNGS:
            irregular.append("irregular rung: line %d (rung '%s')" % (no, shown(rung)))
            continue
        if rung == "pending":
            pending += 1
            continue
        landed[rung] = landed.get(rung, 0) + 1
        if no < last[fp]:
            followed[rung] = followed.get(rung, 0) + 1
    for rung in sorted(landed):  # only ALLOWED_RUNGS reach here, so no escaping is needed
        f = followed.get(rung, 0)
        out.append("%s  landed %d  followed-by-same-fingerprint %d  last-of-fingerprint %d"
                   % (rung, landed[rung], f, landed[rung] - f))
    out.append("pending %d" % pending)
    out.append('"followed" means a later row with the same fingerprint exists - nothing more. It does not mean')
    out.append("the rung failed (a later row can be a different sub-shape, an out-of-scope guard, or a resolved")
    out.append('prerequisite), and "last" does not mean it held (an unhardened recurrence leaves no row).')
    out += ["", "== Ledger: irregular rows"]
    irregular.sort(key=lambda s: (int(re.search(r"line (\d+)", s).group(1)), s))
    out += irregular or ["none"]
    return out


def read_commits(raw):
    """Parse `git log -z --format='%H %ct%n%B'` output into (sha, ct, body_lines)."""
    commits = []
    for rec in raw.split("\0"):
        if not rec.strip("\n"):
            continue
        head, _, body = rec.lstrip("\n").partition("\n")
        m = re.fullmatch(r"([0-9a-f]{40}) ([0-9]+)", head)
        if not m:
            die("git log produced an unexpected record header")
        commits.append((m.group(1), int(m.group(2)), body.split("\n")))
    return commits


def git_sections(commits, absence):
    recs = {}      # key -> record dict (key: line text; pre-rule keys also carry the sha)
    unparsed = []  # (ct, sha, line)
    for sha, ct, lines in commits:
        seen_here = set()
        i = 0
        while i < len(lines):
            line = lines[i]
            pos = i
            i += 1
            if not CANDIDATE.match(line):
                continue
            parsed = parse_record(line)
            if parsed is None:
                unparsed.append((ct, sha, line))
                continue
            field, typ, data = parsed
            text = line
            if typ == "skip":  # the reason is the text right after the marker (CLAUDE.md §5)
                reason = []
                while i < len(lines) and lines[i] != "" and not CANDIDATE.match(lines[i]):
                    reason.append(lines[i])
                    i += 1
                data["reason"] = " ".join(reason)
                text = line + " | " + data["reason"]  # identity uses the excerpt as found
            # pre-rule records identify nothing, so every occurrence stays separate (commit + position)
            key = (text, sha, pos) if field == "none (pre-rule)" else (text, None, None)
            if key in seen_here:
                continue
            seen_here.add(key)
            r = recs.setdefault(key, {"field": field, "type": typ, "data": data, "text": text,
                                      "commits": []})
            r["commits"].append((ct, sha))
    for r in recs.values():
        r["commits"].sort()
        r["first"] = r["commits"][0]

    groups = {}
    for key, r in recs.items():
        gkey = ("pre", key) if r["field"] == "none (pre-rule)" else ("n", r["field"])
        groups.setdefault(gkey, []).append(r)

    out = []
    cycles, conflicts, prof, lic, f1 = [], [], [], [], []
    for gkey, rs in groups.items():
        first = min(r["first"] for r in rs)
        provs = [r for r in rs if r["type"] == "prov"]
        rest = [r for r in rs if r["type"] != "prov"]
        for p in provs:  # checkpoint evidence comes from every valid provenance line, conflicts included
            ents = p["data"]["entries"]
            licensed = bool(ents) and all(lv == "0" for _, lv in ents)
            sha = p["first"][1][:12]
            if licensed:
                lic.append((p["first"], "%s  recorded floor %s  commit %s" % (p["field"], p["data"]["floor"], sha)))
            if p["data"]["floor"] == "1":
                f1.append((p["first"], "%s  floor 1  set %s  commit %s" % (
                    p["field"], "licenses it" if licensed else "does not license it", sha)))
        if len(provs) > 1 or len(rest) > 1:
            for r in rs:  # groups sort by earliest record, then nonce; records inside by their own
                conflicts.append((first, rs[0]["field"], r["first"], "%s  %s" % (r["field"], shown(r["text"]))))
            continue
        p = provs[0] if provs else None
        c = rest[0] if rest else None
        fld = rs[0]["field"]
        floor = p["data"]["floor"] if p else "-"
        sset = p["data"]["set"] if p else "-"
        if c is None:
            line = "%s  no curve  floor %s  set %s" % (fld, floor, shown(sset))
        elif c["type"] == "skip":
            line = "%s  %s  skipped  floor %s  set %s  reason excerpt: %s  commit %s" % (
                fld, c["data"]["kind"], floor, shown(sset),
                shown(c["data"]["reason"]) or "no reason found", c["first"][1][:12])
        else:
            d = c["data"]
            line = "%s  %s  passes %s  floor %s  set %s  findings %s (? %d)  blockers %s (? %d)  majors %s (? %d)" % (
                fld, d["kind"], d["spec"], floor, shown(sset), d["f"], d["f"].split(",").count("?"),
                d["b"], d["b"].split(",").count("?"), d["m"], d["m"].split(",").count("?"))
        if gkey[0] == "pre":
            if not (c and c["type"] == "skip"):  # a skip line already names its commit
                line += "  commit %s" % rs[0]["first"][1][:12]
            line += "  [may duplicate another pre-rule record]"
        cycles.append((first, line))
        if p and c and c["type"] == "curve" and p["data"]["entries"] and \
                any(lv != "unprofiled" for _, lv in p["data"]["entries"]):
            prof.append((first, "  " + line))

    def emit(items, empty):
        items.sort(key=lambda t: t[:-1] + (t[-1],))
        if not items:
            out.append(empty)
        out.extend(t[-1] for t in items)

    emit(cycles, ("no joined cycles (every record is in a conflict below)" if conflicts else
                  "no cycle records") + absence)
    several = sorted((r["first"], shown(r["text"]), ",".join(s[:12] for _, s in r["commits"]))
                     for r in recs.values() if len(r["commits"]) > 1)
    out.extend("seen in several commits: %s -> %s" % (t, c) for _, t, c in several)
    out += ["", "== Git: conflicts (records sharing a nonce that disagree; not listed as cycles)"]
    emit(conflicts, "no conflicts" + absence)
    out += ["", "== Git: unparsed candidate lines"]
    emit([((ct, sha), "%s  %s" % (sha[:12], shown(line))) for ct, sha, line in unparsed],
         "no unparsed lines" + absence)
    out += ["", "== Comparison with the fic2 baseline (story criterion 5)",
            "profiled cycles (joined, with a curve, set has a (level N) entry):"]
    emit(prof, "  no profiled cycles with a curve" + absence)
    out.append("fic2 baseline (docs/field-reports/2026-08-26-fic2-cycle-evidence.md, passes 1-5; story §1, passes 6-7):")
    out.append(FIC2)
    out += list(CAVEATS)
    out += ["", "== First checkpoint: evidence (the reader decides)",
            "provenance lines whose set licenses floor 1:"]
    emit([(k, "  " + v) for k, v in lic], "  none" + absence)
    out.append("provenance lines recording floor 1:")
    emit([(k, "  " + v) for k, v in f1], "  none" + absence)
    return out


def is_shallow():
    rc, out = git("rev-parse", "--is-shallow-repository")
    if rc != 0:
        die("git rev-parse --is-shallow-repository failed")
    return out.decode().strip() == "true"


def main(argv):
    if len(argv) > 2:
        die("usage: ledger-metrics.py [<ref>]")
    ref = argv[1] if len(argv) == 2 else "HEAD"
    rc, _ = git("rev-parse", "--git-dir")
    if rc != 0:
        die("not a git repository")
    rc, out = git("rev-parse", "--verify", "--quiet", ref + "^{commit}")
    if rc != 0:
        die("ref does not resolve to a commit: %s" % shown(ref))
    sha = out.decode().strip()
    rc, out = git("ls-tree", "--full-tree", sha, "--", LEDGER)
    if rc != 0:
        die("git ls-tree failed at %s" % sha)
    entry = out.decode("utf-8", "replace").strip()
    if not entry:
        die("ledger absent at %s: %s" % (sha, LEDGER))
    if not re.match(r"^100(644|755) blob ", entry):
        die("ledger is not a regular file at %s: %s" % (sha, LEDGER))
    rc, out = git("cat-file", "blob", "%s:%s" % (sha, LEDGER))
    if rc != 0:
        die("ledger cannot be read at %s: %s" % (sha, LEDGER))
    ledger = out.decode("utf-8", "replace")
    shallow = is_shallow()
    # Bodies re-encoded to UTF-8 whatever i18n.logOutputEncoding says, so NUL framing holds;
    # no signature output, which would land in the same stream; `--` so a file named like the
    # SHA cannot make the argument ambiguous.
    rc, out = git("-c", "i18n.logOutputEncoding=UTF-8", "log", "--encoding=UTF-8", "--no-show-signature",
                  "-z", "--format=%H %ct%n%B", sha, "--")
    if rc != 0:
        die("git log failed at %s" % sha)
    commits = read_commits(out.decode("utf-8", "replace"))
    shallow = is_shallow() or shallow  # checked before and after the walk: either means truncated
    absence = " (history truncated: absence not established)" if shallow else ""

    lines = [
        "ledger-metrics — read-only report",
        "commit %s (from %s)" % (sha, shown(ref)),
        "ledger: %s at that commit; the working tree is not read" % LEDGER,
        "git writes: this script only runs read-only git commands; git may still write when your"
        " environment tells it to (e.g. GIT_TRACE to a file, partial-clone fetches)",
        "history: " + ("truncated (shallow clone): absence not established" if shallow else "complete"),
    ]
    lines += ledger_section(ledger)
    lines += ["", "== Git: review cycles (all commits reachable from %s)" % sha]
    lines += git_sections(commits, absence)
    # UTF-8 whatever the locale says, so a valid non-ASCII path can always be printed.
    out = "\n".join(lines) + "\n" + CANNOT + "\n"
    sys.stdout.buffer.write(out.encode("utf-8", "backslashreplace"))
    sys.stdout.flush()
    return 0


if __name__ == "__main__":
    # One integer limit on every Python: 3.11+ caps int() at 4300 digits by default, 3.8-3.10
    # do not, and the §5 grammar has no digit limit. Lift the cap where it exists.
    if hasattr(sys, "set_int_max_str_digits"):
        sys.set_int_max_str_digits(0)
    sys.exit(main(sys.argv))
````

- [ ] **Step 4: Run the suite under both shells, reading each exit status**

Run: `sh scripts/ledger-metrics.test.sh > /tmp/lm-sh.log 2>&1; echo "sh=$?"; dash scripts/ledger-metrics.test.sh > /tmp/lm-dash.log 2>&1; echo "dash=$?"; tail -1 /tmp/lm-sh.log /tmp/lm-dash.log`
Expected: `sh=0`, `dash=0`, and `30 passed, 0 failed` in both logs (measured on the prototype 2026-10-01). The second run checks the suite's own portability; the script runs under `python3` either way.

- [ ] **Step 5: Lint the suite**

Run: `shellcheck --shell=sh --exclude=SC2015 scripts/ledger-metrics.test.sh; echo "lint=$?"`
Expected: `lint=0`.

- [ ] **Step 6: Run it on the real repository**

Run: `python3 scripts/ledger-metrics.py main > /tmp/lm-main.txt; echo "exit=$?"; sed -n '/^== Git: unparsed/,+1p' /tmp/lm-main.txt`
Expected: `exit=0` and `no unparsed lines`.

No commit (Task 3 makes the single Gate-B snapshot).

---

### Task 2: Battery, CI and docs

**Files:**
- Modify: `AGENTS.md`, `CLAUDE.md`, `.github/workflows/ci.yml`, `README.md`

- [ ] **Step 1: Find every place that enumerates the executables or suites, and every manifest claim**

```sh
grep -rnE 'two repo-local|both checker|all three executables|three suites|two checkers|both checkers' --include='*.md' --include='*.yml' --include='*.sh' . | grep -vE 'source-files/|docs/superpowers/|\.context/|hardening-log|CHANGELOG'
grep -rniE 'declare[sd]?|convention[- ]load' --include='*.md' . | grep -v source-files/
cat plugins/dev-workflow/.claude-plugin/plugin.json
grep -rn 'consumer does not exist' --include='*.md' . | grep -v source-files/
```
Expected (measured 2026-10-01): the first grep finds `README.md:160`, `README.md:163`, `.github/workflows/ci.yml:40`, `:46`, `:60`, `:92`. Lines 46 and 60 say "the two repo-local checkers" about **checkers** and stay true, because the report is not a checker. The second grep's hits are claims about the plugin manifest; read them against the `cat` output — this change adds nothing to the plugin, so each should stay true. The third grep finds `CLAUDE.md` (§5 Mechanics) and `plugins/dev-workflow/commands/workflow-init.md`: the repository's own `CLAUDE.md` sentence becomes false with this change and is edited below; the scaffolded template's copy stays, because a consumer project gets no metrics script and its consumer still does not exist. Any other first-grep hit is a stop: surface it before editing.

- [ ] **Step 2: Apply the edits**

Save this as a temporary file outside the repository (for example `$TMPDIR/docs-edit.py`) and run it from the repository root with `python3`. It writes nothing unless every replacement matches exactly once.

```python
# Applies the Task 2 documentation and CI edits. Every replacement must match exactly
# once, or the script stops before writing anything.
import sys
edits = {
 "AGENTS.md": [
  ("scripts/check-version-bump.test.sh # its regression suite — policy/operational/accept\n",
   "scripts/check-version-bump.test.sh # its regression suite — policy/operational/accept\n"
   "scripts/ledger-metrics.py         # read-only report over the ledger + git (vision step 2b)\n"
   "scripts/ledger-metrics.test.sh    # its regression suite — fixture repos, expected text\n"),
  ("repo-local CI checkers and their tests (`scripts/check-invariants.{sh,test.sh}` and\n"
   "`scripts/check-version-bump.{sh,test.sh}`) — the hook ships in the plugin, the checkers\n"
   "do not; everything else is text read by a model.",
   "repo-local CI checkers and their tests (`scripts/check-invariants.{sh,test.sh}` and\n"
   "`scripts/check-version-bump.{sh,test.sh}`), plus the read-only Python report\n"
   "`scripts/ledger-metrics.py` and its suite `scripts/ledger-metrics.test.sh` — the hook ships\n"
   "in the plugin, the checkers and the report do not; everything else is text read by a model."),
  # quality row and lint row each contain one of these two substrings
  ("shellcheck --shell=sh scripts/check-version-bump.test.sh && HOOK_SH=sh",
   "shellcheck --shell=sh scripts/check-version-bump.test.sh && shellcheck --shell=sh --exclude=SC2015 scripts/ledger-metrics.test.sh && HOOK_SH=sh"),
  ("shellcheck --shell=sh scripts/check-version-bump.test.sh` |",
   "shellcheck --shell=sh scripts/check-version-bump.test.sh && shellcheck --shell=sh --exclude=SC2015 scripts/ledger-metrics.test.sh` |"),
  ("sh scripts/check-version-bump.sh main && claude plugin validate . --strict` |",
   "sh scripts/check-version-bump.sh main && sh scripts/ledger-metrics.test.sh && claude plugin validate . --strict` |"),
  ("| typecheck | n/a — no typed sources (shell + markdown) |",
   "| typecheck | n/a — no typed sources (shell, one untyped Python report, markdown) |"),
  ("tool. Without it the second run cannot start, and dropping that run is what let a\n"
   "`dash`-only defect ship once already.\n",
   "tool. Without it the second run cannot start, and dropping that run is what let a\n"
   "`dash`-only defect ship once already. The metrics report's suite also needs\n"
   "**`python3`** 3.8 or later, addressed by name for the same reason as `dash`: it is the\n"
   "system interpreter, not a pinned tool.\n"),
 ],
 "CLAUDE.md": [
  ("variant; anything quoting this form elsewhere quotes an instance of it, because the deferred\n"
   "  metrics work is intended to parse it — that consumer does not exist yet, and the form is pinned\n"
   "  now so that it can.\n",
   "variant; anything quoting this form elsewhere quotes an instance of it, because tooling parses\n"
   "  it — in this repository `scripts/ledger-metrics.py` (dark-factory vision step 2b) — and the\n"
   "  form is pinned so that it can.\n"),
 ],
 ".github/workflows/ci.yml": [
  ("      # The hook, the two checkers and their three suites are the only executables here,\n",
   "      # The hook, the two checkers, the Python metrics report and their four suites are\n"
   "      # the only executables here,\n"),
  ("            --shell=sh scripts/check-version-bump.test.sh\n",
   "            --shell=sh scripts/check-version-bump.test.sh\n"
   "          # The metrics report's suite (vision step 2b). The report itself is Python, so\n"
   "          # only its POSIX-sh suite is linted here; the suite runs the report under the\n"
   "          # runner's python3. Same `[ c ] && pass || fail` lines as the other suites,\n"
   "          # hence SC2015.\n"
   "          docker run --rm -v \"$PWD:/mnt\" -w /mnt koalaman/shellcheck:v0.11.0 \\\n"
   "            --shell=sh --exclude=SC2015 scripts/ledger-metrics.test.sh\n"),
  ("      - name: Invariant checks (pinning, manifest, prompt conformance) + both checker suites\n",
   "      - name: Invariant checks (pinning, manifest, prompt conformance) + checker and report suites\n"),
  ("          sh scripts/check-version-bump.test.sh\n\n",
   "          sh scripts/check-version-bump.test.sh\n          sh scripts/ledger-metrics.test.sh\n\n"),
 ],
 "README.md": [
  ("PR and push to main: `shellcheck --shell=sh` over all three executables and their test\nfiles,",
   "PR and push to main: `shellcheck --shell=sh` over the three shell executables and every\nshell test file,"),
  ("both checkers' regression suites, and `claude plugin validate . --strict`.\n",
   "both checkers' regression suites, the metrics report's suite, and\n`claude plugin validate . --strict`.\n\n"
   "`python3 scripts/ledger-metrics.py` prints a read-only report over the hardening ledger\n"
   "and the review-cycle records in commit bodies: which fingerprints recur, how rungs were\n"
   "followed, and each cycle's recorded curve beside the `fic2` baseline. It writes nothing.\n"),
 ],
}
new = {}
for path, reps in edits.items():
    s = open(path).read()
    for old, rep in reps:
        n = s.count(old)
        if n != 1:
            sys.exit(f"STOP: {path}: expected exactly 1 match, found {n}: {old[:70]!r}")
        s = s.replace(old, rep)
    new[path] = s
for path, s in new.items():
    open(path, "w").write(s)
print("edited:", ", ".join(new))
```

Expected: `edited: AGENTS.md, CLAUDE.md, .github/workflows/ci.yml, README.md`; then `git diff --stat` lists those four files only.

- [ ] **Step 3: Run the AGENTS.md quality row, verbatim**

Copy the quality row from `AGENTS.md` § Commands as it now stands and run it into a log: `sh -c '<row>' > /tmp/lm-quality.log 2>&1; echo "quality=$?"`. Expected: `quality=0`, and the log contains `30 passed, 0 failed` (measured on a copy of the repository 2026-10-01).

No commit.

---

### Task 3: Evidence, Gate B, close

- [ ] **Step 1: Base check before the snapshot**

Run each separately and read its status: `git fetch origin`; `git merge-base --is-ancestor origin/main HEAD; echo "anc=$?"`.
Expected: `anc=0`. `anc=1` is a stop: ask Daniel. No plugin path changes, so there is no version to reconcile.

- [ ] **Step 2: Stage and snapshot**

```sh
git add scripts/ledger-metrics.py scripts/ledger-metrics.test.sh AGENTS.md CLAUDE.md .github/workflows/ci.yml README.md && git diff --cached --name-only
```
Expected: exactly those six paths. Then, **as its own one-line tool call from inside the repository** (the recommended form CLAUDE.md §5 Mechanics describes):

```sh
git commit -m 'WIP: passive metrics candidate'
```

- [ ] **Step 3: Evidence run**

Run each and read its result: `git rev-parse HEAD` (record it); `git status --porcelain --untracked-files=no` (must print nothing); `test "$(git rev-parse main)" = "$(git rev-parse origin/main)"; echo "main-fresh=$?"` (non-zero is a stop — ask Daniel to update local `main`); the AGENTS.md quality row verbatim into a log, exit 0; `dash scripts/ledger-metrics.test.sh > /tmp/lm-dash.log 2>&1; echo "dash=$?"` (must be `dash=0` with `30 passed, 0 failed`); `git ls-tree c60b78b -- scripts/ledger-metrics.py scripts/ledger-metrics.sh` (must print nothing: the prior state, observed at a named commit); then the first two again (same `HEAD`, still nothing).

Evidence entry for the commit body:

```
Evidence — docs/superpowers/stories/2026-08-04-passive-metrics-over-the-ledger-story.md
Battery: AGENTS.md quality row, exit 0 at <headSha>.
Check (counterfactual): at c60b78b no metrics script exists (git ls-tree prints
nothing), and the suite's first case observes that an absent script produces no
report. Negative control: a copy whose fingerprint count is off by one runs to
completion, and the same comparison every golden case uses rejects its report
(suite case 2). Suite 30/30 under sh (in the quality row) and under dash.
```

- [ ] **Step 4: Gate B**

CLAUDE.md §5: new nonce; floor 3 (story `standard`/`none`). First check `mcp__codex__health` → `config.effective.model` is `gpt-6-astra`; anything else is a stop (the ChatGPT Codex app rewrites `~/.codex/config.toml`). `baseSha` = parent of the WIP commit. **Immediately before each of the two calls**, resolve `headSha` with `git rev-parse HEAD` and pass that full value; keep each branch's `baseSha`/`headSha` with its result and require them equal before summing. Two separate `mcp__codex__review` calls (`spec`, then `quality`), each with its own findings file. Each call carries: the story path; the evidence entry verbatim; the seven rulings above; the standing lens "which existing statements does this diff falsify?", naming what this diff changes — the executable and suite counts, the CI step name, the AGENTS.md command rows, typecheck row and prerequisites, and the `CLAUDE.md` consumer sentence.

Fixes: `git add` the paths, then `git commit --amend -m 'WIP: passive metrics candidate'` as its own one-line tool call, then an evidence run, then re-review.

- [ ] **Step 5: Close and PR**

When the §5 closure ordering allows it: evidence run again; `git log --format='%h %s' origin/main..HEAD` must show the WIP commit on top of the plan commit, `49b90f8` and `c60b78b`, and nothing staged — any other shape is a stop. Then `git commit --amend -m "<real message>"`, whose body carries the evidence entry, the Gate-B provenance line, the Gate-B curve, and a prose line saying the spec and quality calls of each pass together counted as one logical pass. No trailers. Push, open a PR, then read CI's `quality` log for `30 passed, 0 failed`.

---

## Where Gate-A plan pass 1's findings landed

| Pass-1 finding (awk plan) | Now |
|---|---|
| mawk array-membership semantics; first-match model/curve parsing; control characters in quoted values; decoded duplicate paths; fields rebuilt from decorated keys; level/unprofiled substring search; unbounded range expansion; record-separator spoofing; unchecked awk/sort status | **Removed by the language change**: Python dictionaries, a quote-aware scanner, `read_quoted` rejecting control characters, decoded-path comparison, parsed fields kept as data, entry levels parsed per entry, a length check before expansion, `-z` NUL framing with a validated header, and `git()` checking every return code. |
| `rowre` without the column-2 cell | The row pattern includes the cell and its closing pipe. |
| Conflict groups skipped before the checkpoint lists | Every valid provenance line feeds the checkpoint lists, conflicts included (fixture `iiiiiiii`). |
| `tail` hiding the suite's status | Every command in this plan reads its own exit status. |
| `HOOK_SH=dash` not running the product under dash | The product is Python now; the suite runs under `sh` and `dash` for its own portability. |
| No-write snapshot around one run only | `report()` snapshots around every run; one marker per changed fixture, checked at the end. |
| Inherited git config, identity, templates | `GIT_CONFIG_GLOBAL=/dev/null`, `GIT_CONFIG_NOSYSTEM=1`, inherited variables unset, `--template=`, `--object-format=sha1`. |
| `headSha` reused across the two Gate-B calls | Resolved immediately before each call and kept with its result. |
| Plan pass 2 (Python plan): an `int()` on per-pass keys, error runs bypassing the no-write check, report statuses not asserted, inherited `GIT_AUTHOR_*`/`GIT_COMMITTER_*`, dash not in the evidence run | Keys compared as text (5001-digit fixture); `run()` wraps every invocation, errors included; each report's status asserted; identity variables fixed in `gitc`; dash run in Task 3 Step 3. Minors: fingerprint from the split cell, group-level conflict ordering, commit shown on pre-rule and skip lines, excerpt identity without the fallback text, control-safe ref, C1 controls, printed check command executed as printed, footer asserted, wider manifest grep, `CLAUDE.md` consumer sentence, typecheck row. |
| Plan pass 3: inherited `GIT_SHALLOW_FILE` broke four suite cases | Unset in the suite (with `GIT_GRAFT_FILE`, `GIT_NO_REPLACE_OBJECTS`) and dropped by the script; suite passes with it set. Minors: group-then-nonce conflict ordering, escaped final pipe, CRLF rows, UTF-8 stderr, one integer limit on every Python, pre-rule skip commit printed once. Left as stated limits: U+FFFD before grouping (ruling 7), a transient shallow boundary (ruling 3). |
| Plan pass 4: the pass-3 repairs had no regression cases | Six cases added, one per repair — tied conflict order, escaped final pipe and CRLF, UTF-8 stderr under a latin1 locale, a 5001-digit pass number parsed as a cycle, a pre-rule skip naming its commit once. Each was checked by reverting its repair in a copy: exactly that case failed. The two kept limits are now printed in the report. |
| Plan pass 5: the UTF-8 error case bypassed `run()`; two new cases ignored the script's exit status; global git attributes from `XDG_CONFIG_HOME` could change fixture commits | The UTF-8 case runs through `run()` and requires exit 1; the pre-rule-skip case asserts exit 0; the suite sets an empty `HOME` and `XDG_CONFIG_HOME` and `GIT_ATTR_NOSYSTEM=1` (suite green with a hostile `XDG_CONFIG_HOME/git/attributes`). Minor: several-commit notices sort by the printed text. |
| The Minors (escaped-pipe restore, pre-rule positions, ordering ties, `<commit>` placeholder, conflict/unparsed empty states and suffixes, nonce caveat, git stderr before the one-line error, `ls-tree` relative path, "cannot be read" case, Task 2 manifest-claim search, closing-message prose) | Each handled in the script, the suite or the steps above. |

## Self-review (2026-10-01)

- **Spec coverage:** §1 → Tasks 1–2. §2 → `main()`/`git()` and suite exit cases. §3 → `ledger_section` + ledger fixture. §4 → `parse_record`, `git_sections` + cycle fixture. §5 → comparison and checkpoint output + fixture. §6 → the suite (isolation, prior state, negative control, no-write around every run). §7 → `CANNOT`. §8 → nothing beyond.
- **Story ACs:** 1 done (profile, `c60b78b`); 2 → no-write check + script reading; 3 → printed command + suite case "check command reproduces"; 4 → printed "cannot answer"; 5 → comparison section, `(? n)` per series, caveats, checkpoint evidence.
- **Placeholders:** `<headSha>` and `<real message>` are run-time values.
