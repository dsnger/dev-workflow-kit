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
# The report header, compared line for line: commit and ref, the working-tree disclosure,
# the git-writes limit and the history state.
csha=$(cd "$work/L" && git rev-parse HEAD)
expect "header: commit, ref, sources and history state" "$(printf '%s\n' "$out" | sed -n '1,5p')" <<HEADER
ledger-metrics — read-only report
commit $csha (from HEAD)
ledger: docs/hardening-log.md at that commit; the working tree is not read
git writes: this script only runs read-only git commands; git may still write when your environment tells it to (e.g. GIT_TRACE to a file, partial-clone fetches)
history: complete
HEADER
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
expect "checkpoint: both evidence lists empty" "$(printf '%s\n' "$oute" | sed -n '/^== First checkpoint/,/^$/p' | sed '$d')" <<'CHECKPOINT'
== First checkpoint: evidence (the reader decides)
provenance lines whose set licenses floor 1:
  none
provenance lines recording floor 1:
  none
CHECKPOINT

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
