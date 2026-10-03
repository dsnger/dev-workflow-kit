#!/bin/sh
# Regression suite for loop-usefulness.py.
#
# Spec: docs/superpowers/specs/2026-10-02-loop-usefulness-design.md §7. Builds a fixture repository
# whose commit bodies carry cycle records (each commit changes the files that set its distance)
# and a fixture run-analytics store, runs the report, and compares it with expected text.
set -u

HERE="$(cd "$(dirname "$0")" && pwd)"
SCRIPT="$HERE/loop-usefulness.py"
LEDGER="$HERE/ledger-metrics.py"
pass_n=0; fail_n=0
pass() { pass_n=$((pass_n + 1)); printf 'ok   - %s\n' "$1"; }
fail() { fail_n=$((fail_n + 1)); printf 'FAIL - %s\n' "$1"; }

work=$(mktemp -d) || work=''
if [ -z "$work" ] || [ ! -d "$work" ]; then
  printf 'FAIL - could not create a temporary directory; refusing to run\n' >&2
  exit 1
fi
trap 'rm -rf "$work"' EXIT
work=$(cd "$work" && pwd -P)

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
    git -c commit.gpgsign=false -c init.defaultBranch=main "$@"
}
# rc FILE MESSAGE: change FILE (which sets the commit's distance), then commit with MESSAGE.
rc() {
  tick=$((tick + 100)); mkdir -p "$(dirname "$1")"; printf '%s\n' "$tick" >> "$1"
  printf '%b' "$2" > "$work/msg"; gitc add -A && gitc commit -q -F "$work/msg"
}
prov() { printf 'cycle %s; floor %s per {docs/superpowers/stories/s-story.md (level 1)}; hook reminder threshold absent' "$1" "$2"; }  # nonce floor
curve() { printf 'cycle %s; %s (passes %s, codex): Findings %s. Blockers %s. Majors %s.' "$1" "$2" "$3" "$4" "$5" "$6"; }

mkrepo() { # dir
  rm -rf "${work:?}/$1"; mkdir -p "$work/$1/scripts"
  cp "$SCRIPT" "$LEDGER" "$work/$1/scripts/"
  (
    cd "$work/$1" || exit 1
    gitc init -q --template= --object-format=sha1 .
    printf '.context/\n' > .gitignore
    rc docs/base.md 'base\n'
    C=plugins/p/commands/c.md; S=scripts/x.sh; D=docs/x.md
    # product: thresholds on both sides (excess 3 / 4 / 8 / 9; increases 1 / 2 / 3 / 4)
    rc $C "p green\n\n$(prov prodgrn1 3)\n$(curve prodgrn1 'Gate-A spec' 1-3 '20,9,4' '2,0,0' '3,3,1')\n"
    rc $C "p bound\n\n$(prov prodbnd3 3)\n$(curve prodbnd3 'Gate B' 1-6 '1,1,1,1,1,1' '0,0,0,0,0,0' '1,1,1,1,1,1')\n"
    rc $C "p amber\n\n$(prov prodamb4 3)\n$(curve prodamb4 'Gate B' 1-7 '1,1,1,1,1,1,1' '0,0,0,0,0,0,0' '1,1,1,1,1,1,1')\n"
    rc $C "p amber 8\n\n$(prov prodamb8 3)\n$(curve prodamb8 'Gate B' 1-11 '1,1,1,1,1,1,1,1,1,1,1' '0,0,0,0,0,0,0,0,0,0,0' '1,1,1,1,1,1,1,1,1,1,1')\n"
    rc $C "p red\n\n$(prov prodred9 3)\n$(curve prodred9 'Gate B' 1-12 '1,1,1,1,1,1,1,1,1,1,1,1' '0,0,0,0,0,0,0,0,0,0,0,0' '1,1,1,1,1,1,1,1,1,1,1,1')\n"
    rc $C "p inc1\n\n$(prov prodinc1 3)\n$(curve prodinc1 'Gate B' 1-3 '1,2,0' '0,0,0' '1,2,0')\n"
    rc $C "p inc2\n\n$(prov prodinc2 3)\n$(curve prodinc2 'Gate B' 1-5 '0,1,0,1,0' '0,0,0,0,0' '0,1,0,1,0')\n"
    # floors 6 and 8 keep excess at 0, so only the increases can warn (ruling 6)
    rc $C "p inc3\n\n$(prov prodinc3 6)\n$(curve prodinc3 'Gate B' 1-6 '0,1,0,1,0,1' '0,0,0,0,0,0' '0,1,0,1,0,1')\n"
    # floor 5 keeps excess at 3, so only the four increases can make it red (negative control)
    rc $C "p inc4\n\n$(prov prodinc4 5)\n$(curve prodinc4 'Gate B' 1-8 '0,1,0,1,0,1,0,1' '0,0,0,0,0,0,0,0' '0,1,0,1,0,1,0,1')\n"
    rc $C "p zero\n\n$(prov prodzero 3)\n$(curve prodzero 'Gate B' 1 '0' '0' '0')\n"
    # machinery: excess 2 / 3 / 6
    rc $S "m bound\n\n$(prov machbnd2 3)\n$(curve machbnd2 'Gate B' 1-5 '1,1,1,1,1' '0,0,0,0,0' '1,1,1,1,1')\n"
    rc $S "m amber\n\n$(prov machamb3 3)\n$(curve machamb3 'Gate B' 1-6 '1,1,1,1,1,1' '0,0,0,0,0,0' '1,1,1,1,1,1')\n"
    rc $S "m excess 5\n\n$(prov machexc5 3)\n$(curve machexc5 'Gate B' 1-8 '1,1,1,1,1,1,1,1' '0,0,0,0,0,0,0,0' '1,1,1,1,1,1,1,1')\n"
    rc $S "m red\n\n$(prov machred6 3)\n$(curve machred6 'Gate B' 1-9 '1,1,1,1,1,1,1,1,1' '0,0,0,0,0,0,0,0,0' '1,1,1,1,1,1,1,1,1')\n"
    # machinery increases: 1 / 2 / 4 with no excess, and an unknown comparison
    rc $S "m inc1\n\n$(prov machinc1 3)\n$(curve machinc1 'Gate B' 1-3 '1,2,0' '0,0,0' '1,2,0')\n"
    rc $S "m inc2\n\n$(prov machinc2 6)\n$(curve machinc2 'Gate B' 1-5 '0,1,0,1,0' '0,0,0,0,0' '0,1,0,1,0')\n"
    rc $S "m inc3\n\n$(prov machinc3 7)\n$(curve machinc3 'Gate B' 1-7 '0,1,0,1,0,1,0' '0,0,0,0,0,0,0' '0,1,0,1,0,1,0')\n"
    rc $S "m inc4\n\n$(prov machinc4 8)\n$(curve machinc4 'Gate B' 1-8 '0,1,0,1,0,1,0,1' '0,0,0,0,0,0,0,0' '0,1,0,1,0,1,0,1')\n"
    rc $S "m q\n\n$(prov machqmrk 3)\n$(curve machqmrk 'Gate B' 1-3 '2,?,0' '1,?,0' '1,1,0')\n"
    # unknown distance: agree / machinery-only warning / amber beside red
    rc $D "u agree\n\n$(prov unkagree 3)\n$(curve unkagree 'Gate-A plan' 1-3 '1,1,1' '0,0,0' '1,1,1')\n"
    rc $D "u disagree\n\n$(prov unkdisag 3)\n$(curve unkdisag 'Gate-A plan' 1-6 '1,1,1,1,1,1' '0,0,0,0,0,0' '1,1,1,1,1,1')\n"
    rc $D "u amber red\n\n$(prov unkamred 3)\n$(curve unkamred 'Gate-A plan' 1-9 '1,1,1,1,1,1,1,1,1' '0,0,0,0,0,0,0,0,0' '1,1,1,1,1,1,1,1,1')\n"
    # unknown counts, and a gap in pass numbers
    rc $C "q\n\n$(prov qmarkqqq 3)\n$(curve qmarkqqq 'Gate B' 1-3 '2,?,0' '1,?,0' '1,1,0')\n"
    rc $C "q warn\n\n$(prov qwarnqqq 3)\n$(curve qwarnqqq 'Gate B' 1,3,5,7,9 '0,1,0,1,1' '0,0,0,0,?' '0,1,0,1,1')\n"
    # record sets
    rc $C "skip\n\n$(prov skip1aaa 3)\ncycle skip1aaa; Gate B: skipped (see skip reason)\nSkip reason: trivial.\n"
    rc $C "skip+curve\n\n$(prov skipcurv 3)\ncycle skipcurv; Gate B: skipped (see skip reason)\nSkip reason: trivial.\n$(curve skipcurv 'Gate B' 1 '0' '0' '0')\n"
    rc $C "skip a\n\n$(prov skiptwoo 3)\ncycle skiptwoo; Gate B: skipped (see skip reason)\nSkip reason: one.\n"
    rc $C "skip b\n\ncycle skiptwoo; Gate B: skipped (see skip reason)\nSkip reason: two.\n"
    rc $C "skip conflicting prov a\n\n$(prov skipconf 3)\ncycle skipconf; Gate B: skipped (see skip reason)\nSkip reason: one.\n"
    rc $C "skip conflicting prov b\n\n$(prov skipconf 1)\n"
    rc $C "open red\n\n$(curve openred1 'Gate B' 1-8 '0,1,0,1,0,1,0,1' '0,0,0,0,0,0,0,0' '0,1,0,1,0,1,0,1')\n"
    rc $C "open none\n\n$(curve opennone 'Gate B' 1 '0' '0' '0')\n"
    rc $C "prov only\n\n$(prov provonly 3)\n"
    rc $C "two prov a\n\n$(prov twoprovv 3)\n$(curve twoprovv 'Gate B' 1-8 '0,1,0,1,0,1,0,1' '0,0,0,0,0,0,0,0' '0,1,0,1,0,1,0,1')\n"
    rc $C "two prov b\n\n$(prov twoprovv 1)\n"
    rc $C "two curves a\n\n$(prov twocurve 3)\n$(curve twocurve 'Gate B' 1 '0' '0' '0')\n"
    rc $C "two curves b\n\n$(curve twocurve 'Gate B' 1 '1' '0' '1')\n"
    rc $D "same 1\n\n$(prov sameprov 3)\n$(curve sameprov 'Gate B' 1-6 '1,1,1,1,1,1' '0,0,0,0,0,0' '1,1,1,1,1,1')\n"
    rc $S "same 2\n\n$(prov sameprov 3)\n"
    # a product file moved into docs: without rename detection the old product path still counts (ruling 1)
    rc plugins/p/commands/mv.md "add mv\n"
    mkdir -p docs; git mv plugins/p/commands/mv.md docs/mv.md
    printf '%b' "moved\n\n$(prov movedmv1 3)\n$(curve movedmv1 'Gate B' 1 '0' '0' '0')\n" > "$work/msg"
    tick=$((tick + 100)); gitc commit -q -F "$work/msg"
    rc $D "pre-rule and unparsed\n\ncycle none (pre-rule); Gate B (passes 1, codex): Findings 0. Blockers 0. Majors 0.\ncycle zzzzzzzz; not a record\n"
  )
}

STORE_LINES='{"tool_use_id":"t1","slots":["gate-b-spec-prodgrn1-pass-1","gate-b-quality-prodgrn1-pass-1"],"duration_s":10.0,"tokens_in":100,"tokens_cached":50,"tokens_out":10,"tokens_reasoning":5,"tokens_unknown":null}
{"tool_use_id":"t2","slots":["gate-a-spec-prodgrn1-pass-3"],"duration_s":20.0,"tokens_in":null,"tokens_cached":null,"tokens_out":null,"tokens_reasoning":null,"tokens_unknown":"shared"}
{not json
{"tool_use_id":"t3","slots":["gate-a-spec-prodgrn1-pass-2"],"duration_s":"x","tokens_in":1,"tokens_cached":1,"tokens_out":1,"tokens_reasoning":1,"tokens_unknown":null}
{"tool_use_id":"t1","slots":["gate-a-spec-prodgrn1-pass-2"],"duration_s":5.0,"tokens_in":1,"tokens_cached":1,"tokens_out":1,"tokens_reasoning":1,"tokens_unknown":null}
{"tool_use_id":"t4","slots":["gate-a-spec-prodgrn1-pass-2"],"duration_s":5.0,"tokens_in":null,"tokens_cached":1,"tokens_out":1,"tokens_reasoning":1,"tokens_unknown":null}
   '

build() {
  rm -rf "${work:?}/home"; mkdir -p "$work/home"
  mkrepo repo
  mkdir -p "$work/repo/.context/telemetry"
  printf '%s\n' "$STORE_LINES" > "$work/repo/.context/telemetry/gate-calls.jsonl"
}
raw() { (cd "$1" && HOME="$work/home" python3 -B scripts/loop-usefulness.py ${2+"$2"}); }
run() { raw "$@" 2>&1; }
# Every path under $1, ignored ones included: mode, size, mtime in nanoseconds, content hash.
snapshot() { python3 - "$1" <<'SNAP'
import hashlib, os, sys
for d, dirs, files in sorted(os.walk(sys.argv[1])):
    for n in sorted(dirs + files):
        p = os.path.join(d, n); st = os.lstat(p)
        h = hashlib.sha256(open(p, "rb").read()).hexdigest() if os.path.isfile(p) and not os.path.islink(p) else "-"
        print(os.path.relpath(p, sys.argv[1]), oct(st.st_mode), st.st_size, st.st_mtime_ns, h)
SNAP
}
expect() { # name, actual (expected on stdin)
  printf '%s\n' "$2" > "$work/actual"; cat > "$work/expected"
  if diff "$work/expected" "$work/actual" > "$work/diff"; then pass "$1"; else fail "$1"; sed 's/^/    /' "$work/diff"; fi
}
bad() { # name, expected message, dir, [ref] — exit 1, the reason on stderr, nothing on stdout
  name=$1; msg=$2; shift 2
  raw "$@" > "$work/bad.out" 2> "$work/bad.err"; s=$?
  e=$(cat "$work/bad.err")
  if [ "$s" -eq 1 ] && printf '%s' "$e" | grep -qF "loop-usefulness: $msg" && [ ! -s "$work/bad.out" ]; then pass "$name"
  else fail "$name (exit $s: $e; stdout $(wc -c < "$work/bad.out") bytes)"; fi
}

# ---- 1. the main report -----------------------------------------------------------------------------
build
before=$(snapshot "$work/repo"; snapshot "$work/home")
out=$(run "$work/repo"); st=$?
[ "$st" -eq 0 ] && pass "main run exits 0" || fail "main run exit $st"
[ "$(snapshot "$work/repo"; snapshot "$work/home")" = "$before" ] &&
  pass "the run writes nothing (repository and HOME, ignored files included)" || fail "the run wrote a file"
[ ! -e "$work/repo/scripts/__pycache__" ] && pass "no __pycache__ written" || fail "__pycache__ written"
expect "report" "$(printf '%s\n' "$out" | sed -E 's/commit [0-9a-f]{12} [0-9-]{10}/commit SHA DATE/; s/commit [0-9a-f]{12}$/commit SHA/; s/^ref HEAD \([0-9a-f]{12}\)/ref HEAD (SHA)/')" <<'EOF'
loop-usefulness — a warning light over recorded review cycles (reassess effort; not a usefulness verdict)
ref HEAD (SHA)
nonces: closed 26  open or unclosed 3  skipped 1  conflicting or incomplete 5;  pre-rule records 1  unparsed record lines 1
run-analytics store: read; skipped store lines 5
states: red 6  amber 11  no warning 8  not determinable 9

== Cycles (newest first)
movedmv1  Gate B  no warning: 0 excess passes, 0 increases (amber at 4 / 2, product); usefulness unknown
  recommendation: no action suggested; usefulness unknown
  context: closed, commit SHA DATE, floor 3, stories {docs/superpowers/stories/s-story.md (level 1)}; workflow-rule version unknown
  distance: product (plugins/p/commands/mv.md)
  material findings (reported, not confirmed, not deduplicated): per pass 0  occurrences 0 (? 0 of 1)
  increases: 0  comparisons unknown: 0  (cause of an increase unknown)
  coverage (recorded only): passes 1 against floor 3; final pass Blocker+Major 0; final pass zero findings yes; reviewed scope unknown
  stored effort: unknown — no stored call; cause not known (possible: older than the store, made outside this clone or from a worktree removed before collection, still pending, or not yet collected)

sameprov  Gate B  amber: 3 excess passes (amber at 3, machinery)
  recommendation: reassess whether further passes of a similar loop have a concrete expected benefit
  context: closed, commit SHA DATE, floor 3, stories {docs/superpowers/stories/s-story.md (level 1)}; workflow-rule version unknown
  distance: machinery (scripts/x.sh)
  material findings (reported, not confirmed, not deduplicated): per pass 1,1,1,1,1,1  occurrences 6 (? 0 of 6)
  increases: 0  comparisons unknown: 0  (cause of an increase unknown)
  coverage (recorded only): passes 6 against floor 3; final pass Blocker+Major 1; final pass zero findings no; reviewed scope unknown
  stored effort: unknown — no stored call; cause not known (possible: older than the store, made outside this clone or from a worktree removed before collection, still pending, or not yet collected)

twocurve  not determinable: several curves (conflicting or incomplete records)
  recommendation: supply the missing data or classify by hand before relying on this state

twoprovv  Gate B  red: 4 increases (red at 4, product)
  recommendation: surface to a human before running a similar loop again; change the review method or stop the approach
  context: open or unclosed (conflicting provenance lines), commit SHA DATE, floor unknown, stories unknown; workflow-rule version unknown
  distance: product (plugins/p/commands/c.md)
  material findings (reported, not confirmed, not deduplicated): per pass 0,1,0,1,0,1,0,1  occurrences 4 (? 0 of 8)
  increases: 4  comparisons unknown: 0  (cause of an increase unknown)
  coverage (recorded only): passes 8 against floor unknown; final pass Blocker+Major 1; final pass zero findings no; reviewed scope unknown
  stored effort: unknown — no stored call; cause not known (possible: older than the store, made outside this clone or from a worktree removed before collection, still pending, or not yet collected)

provonly  not determinable: no curve (conflicting or incomplete records)
  recommendation: supply the missing data or classify by hand before relying on this state

opennone  Gate B  not determinable: excess unknown without a single provenance line; 0 increases
  recommendation: supply the missing data or classify by hand before relying on this state
  context: open or unclosed (no provenance line), commit SHA DATE, floor unknown, stories unknown; workflow-rule version unknown
  distance: product (plugins/p/commands/c.md)
  material findings (reported, not confirmed, not deduplicated): per pass 0  occurrences 0 (? 0 of 1)
  increases: 0  comparisons unknown: 0  (cause of an increase unknown)
  coverage (recorded only): passes 1 against floor unknown; final pass Blocker+Major 0; final pass zero findings yes; reviewed scope unknown
  stored effort: unknown — no stored call; cause not known (possible: older than the store, made outside this clone or from a worktree removed before collection, still pending, or not yet collected)

openred1  Gate B  red: 4 increases (red at 4, product)
  recommendation: surface to a human before running a similar loop again; change the review method or stop the approach
  context: open or unclosed (no provenance line), commit SHA DATE, floor unknown, stories unknown; workflow-rule version unknown
  distance: product (plugins/p/commands/c.md)
  material findings (reported, not confirmed, not deduplicated): per pass 0,1,0,1,0,1,0,1  occurrences 4 (? 0 of 8)
  increases: 4  comparisons unknown: 0  (cause of an increase unknown)
  coverage (recorded only): passes 8 against floor unknown; final pass Blocker+Major 1; final pass zero findings no; reviewed scope unknown
  stored effort: unknown — no stored call; cause not known (possible: older than the store, made outside this clone or from a worktree removed before collection, still pending, or not yet collected)

skipconf  not determinable: conflicting provenance lines (conflicting or incomplete records)
  recommendation: supply the missing data or classify by hand before relying on this state

skiptwoo  not determinable: several skip records (conflicting or incomplete records)
  recommendation: supply the missing data or classify by hand before relying on this state

skipcurv  not determinable: a skip record beside a curve (conflicting or incomplete records)
  recommendation: supply the missing data or classify by hand before relying on this state

skip1aaa  skipped — no loop ran, no state  commit SHA

qwarnqqq  Gate B  amber: 2 increases (amber at 2, product)
  recommendation: reassess whether further passes of a similar loop have a concrete expected benefit
  context: closed, commit SHA DATE, floor 3, stories {docs/superpowers/stories/s-story.md (level 1)}; workflow-rule version unknown
  distance: product (plugins/p/commands/c.md)
  material findings (reported, not confirmed, not deduplicated): per pass 0,1,0,1,?  occurrences 2 (? 1 of 5)
  increases: 2  comparisons unknown: 1  (cause of an increase unknown)
  coverage (recorded only): passes 5 against floor 3; final pass Blocker+Major ?; final pass zero findings no; reviewed scope unknown
  stored effort: unknown — no stored call; cause not known (possible: older than the store, made outside this clone or from a worktree removed before collection, still pending, or not yet collected)

qmarkqqq  Gate B  not determinable: 2 comparisons unknown; 0 excess passes, 0 increases
  recommendation: supply the missing data or classify by hand before relying on this state
  context: closed, commit SHA DATE, floor 3, stories {docs/superpowers/stories/s-story.md (level 1)}; workflow-rule version unknown
  distance: product (plugins/p/commands/c.md)
  material findings (reported, not confirmed, not deduplicated): per pass 2,?,0  occurrences 2 (? 1 of 3)
  increases: 0  comparisons unknown: 2  (cause of an increase unknown)
  coverage (recorded only): passes 3 against floor 3; final pass Blocker+Major 0; final pass zero findings yes; reviewed scope unknown
  stored effort: unknown — no stored call; cause not known (possible: older than the store, made outside this clone or from a worktree removed before collection, still pending, or not yet collected)

unkamred  Gate-A plan  amber: 6 excess passes (amber at 4, product); red under machinery thresholds
  recommendation: reassess whether further passes of a similar loop have a concrete expected benefit
  context: closed, commit SHA DATE, floor 3, stories {docs/superpowers/stories/s-story.md (level 1)}; workflow-rule version unknown
  distance: unknown (no changed file establishes it — classify by hand)
  material findings (reported, not confirmed, not deduplicated): per pass 1,1,1,1,1,1,1,1,1  occurrences 9 (? 0 of 9)
  increases: 0  comparisons unknown: 0  (cause of an increase unknown)
  coverage (recorded only): passes 9 against floor 3; final pass Blocker+Major 1; final pass zero findings no; reviewed scope unknown
  stored effort: unknown — no stored call; cause not known (possible: older than the store, made outside this clone or from a worktree removed before collection, still pending, or not yet collected)

unkdisag  Gate-A plan  not determinable: amber under machinery thresholds, no warning under product thresholds
  recommendation: supply the missing data or classify by hand before relying on this state
  context: closed, commit SHA DATE, floor 3, stories {docs/superpowers/stories/s-story.md (level 1)}; workflow-rule version unknown
  distance: unknown (no changed file establishes it — classify by hand)
  material findings (reported, not confirmed, not deduplicated): per pass 1,1,1,1,1,1  occurrences 6 (? 0 of 6)
  increases: 0  comparisons unknown: 0  (cause of an increase unknown)
  coverage (recorded only): passes 6 against floor 3; final pass Blocker+Major 1; final pass zero findings no; reviewed scope unknown
  stored effort: unknown — no stored call; cause not known (possible: older than the store, made outside this clone or from a worktree removed before collection, still pending, or not yet collected)

unkagree  Gate-A plan  no warning: 0 excess passes, 0 increases (amber at 4 / 2, product); usefulness unknown
  recommendation: no action suggested; usefulness unknown
  context: closed, commit SHA DATE, floor 3, stories {docs/superpowers/stories/s-story.md (level 1)}; workflow-rule version unknown
  distance: unknown (no changed file establishes it — classify by hand)
  material findings (reported, not confirmed, not deduplicated): per pass 1,1,1  occurrences 3 (? 0 of 3)
  increases: 0  comparisons unknown: 0  (cause of an increase unknown)
  coverage (recorded only): passes 3 against floor 3; final pass Blocker+Major 1; final pass zero findings no; reviewed scope unknown
  stored effort: unknown — no stored call; cause not known (possible: older than the store, made outside this clone or from a worktree removed before collection, still pending, or not yet collected)

machqmrk  Gate B  not determinable: 2 comparisons unknown; 0 excess passes, 0 increases
  recommendation: supply the missing data or classify by hand before relying on this state
  context: closed, commit SHA DATE, floor 3, stories {docs/superpowers/stories/s-story.md (level 1)}; workflow-rule version unknown
  distance: machinery (scripts/x.sh)
  material findings (reported, not confirmed, not deduplicated): per pass 2,?,0  occurrences 2 (? 1 of 3)
  increases: 0  comparisons unknown: 2  (cause of an increase unknown)
  coverage (recorded only): passes 3 against floor 3; final pass Blocker+Major 0; final pass zero findings yes; reviewed scope unknown
  stored effort: unknown — no stored call; cause not known (possible: older than the store, made outside this clone or from a worktree removed before collection, still pending, or not yet collected)

machinc4  Gate B  red: 4 increases (red at 4, machinery)
  recommendation: surface to a human before running a similar loop again; change the review method or stop the approach
  context: closed, commit SHA DATE, floor 8, stories {docs/superpowers/stories/s-story.md (level 1)}; workflow-rule version unknown
  distance: machinery (scripts/x.sh)
  material findings (reported, not confirmed, not deduplicated): per pass 0,1,0,1,0,1,0,1  occurrences 4 (? 0 of 8)
  increases: 4  comparisons unknown: 0  (cause of an increase unknown)
  coverage (recorded only): passes 8 against floor 8; final pass Blocker+Major 1; final pass zero findings no; reviewed scope unknown
  stored effort: unknown — no stored call; cause not known (possible: older than the store, made outside this clone or from a worktree removed before collection, still pending, or not yet collected)

machinc3  Gate B  amber: 3 increases (amber at 2, machinery)
  recommendation: reassess whether further passes of a similar loop have a concrete expected benefit
  context: closed, commit SHA DATE, floor 7, stories {docs/superpowers/stories/s-story.md (level 1)}; workflow-rule version unknown
  distance: machinery (scripts/x.sh)
  material findings (reported, not confirmed, not deduplicated): per pass 0,1,0,1,0,1,0  occurrences 3 (? 0 of 7)
  increases: 3  comparisons unknown: 0  (cause of an increase unknown)
  coverage (recorded only): passes 7 against floor 7; final pass Blocker+Major 0; final pass zero findings yes; reviewed scope unknown
  stored effort: unknown — no stored call; cause not known (possible: older than the store, made outside this clone or from a worktree removed before collection, still pending, or not yet collected)

machinc2  Gate B  amber: 2 increases (amber at 2, machinery)
  recommendation: reassess whether further passes of a similar loop have a concrete expected benefit
  context: closed, commit SHA DATE, floor 6, stories {docs/superpowers/stories/s-story.md (level 1)}; workflow-rule version unknown
  distance: machinery (scripts/x.sh)
  material findings (reported, not confirmed, not deduplicated): per pass 0,1,0,1,0  occurrences 2 (? 0 of 5)
  increases: 2  comparisons unknown: 0  (cause of an increase unknown)
  coverage (recorded only): passes 5 against floor 6; final pass Blocker+Major 0; final pass zero findings yes; reviewed scope unknown
  stored effort: unknown — no stored call; cause not known (possible: older than the store, made outside this clone or from a worktree removed before collection, still pending, or not yet collected)

machinc1  Gate B  no warning: 0 excess passes, 1 increases (amber at 3 / 2, machinery); usefulness unknown
  recommendation: no action suggested; usefulness unknown
  context: closed, commit SHA DATE, floor 3, stories {docs/superpowers/stories/s-story.md (level 1)}; workflow-rule version unknown
  distance: machinery (scripts/x.sh)
  material findings (reported, not confirmed, not deduplicated): per pass 1,2,0  occurrences 3 (? 0 of 3)
  increases: 1  comparisons unknown: 0  (cause of an increase unknown)
  coverage (recorded only): passes 3 against floor 3; final pass Blocker+Major 0; final pass zero findings yes; reviewed scope unknown
  stored effort: unknown — no stored call; cause not known (possible: older than the store, made outside this clone or from a worktree removed before collection, still pending, or not yet collected)

machred6  Gate B  red: 6 excess passes (red at 6, machinery)
  recommendation: surface to a human before running a similar loop again; change the review method or stop the approach
  context: closed, commit SHA DATE, floor 3, stories {docs/superpowers/stories/s-story.md (level 1)}; workflow-rule version unknown
  distance: machinery (scripts/x.sh)
  material findings (reported, not confirmed, not deduplicated): per pass 1,1,1,1,1,1,1,1,1  occurrences 9 (? 0 of 9)
  increases: 0  comparisons unknown: 0  (cause of an increase unknown)
  coverage (recorded only): passes 9 against floor 3; final pass Blocker+Major 1; final pass zero findings no; reviewed scope unknown
  stored effort: unknown — no stored call; cause not known (possible: older than the store, made outside this clone or from a worktree removed before collection, still pending, or not yet collected)

machexc5  Gate B  amber: 5 excess passes (amber at 3, machinery)
  recommendation: reassess whether further passes of a similar loop have a concrete expected benefit
  context: closed, commit SHA DATE, floor 3, stories {docs/superpowers/stories/s-story.md (level 1)}; workflow-rule version unknown
  distance: machinery (scripts/x.sh)
  material findings (reported, not confirmed, not deduplicated): per pass 1,1,1,1,1,1,1,1  occurrences 8 (? 0 of 8)
  increases: 0  comparisons unknown: 0  (cause of an increase unknown)
  coverage (recorded only): passes 8 against floor 3; final pass Blocker+Major 1; final pass zero findings no; reviewed scope unknown
  stored effort: unknown — no stored call; cause not known (possible: older than the store, made outside this clone or from a worktree removed before collection, still pending, or not yet collected)

machamb3  Gate B  amber: 3 excess passes (amber at 3, machinery)
  recommendation: reassess whether further passes of a similar loop have a concrete expected benefit
  context: closed, commit SHA DATE, floor 3, stories {docs/superpowers/stories/s-story.md (level 1)}; workflow-rule version unknown
  distance: machinery (scripts/x.sh)
  material findings (reported, not confirmed, not deduplicated): per pass 1,1,1,1,1,1  occurrences 6 (? 0 of 6)
  increases: 0  comparisons unknown: 0  (cause of an increase unknown)
  coverage (recorded only): passes 6 against floor 3; final pass Blocker+Major 1; final pass zero findings no; reviewed scope unknown
  stored effort: unknown — no stored call; cause not known (possible: older than the store, made outside this clone or from a worktree removed before collection, still pending, or not yet collected)

machbnd2  Gate B  no warning: 2 excess passes, 0 increases (amber at 3 / 2, machinery); usefulness unknown
  recommendation: no action suggested; usefulness unknown
  context: closed, commit SHA DATE, floor 3, stories {docs/superpowers/stories/s-story.md (level 1)}; workflow-rule version unknown
  distance: machinery (scripts/x.sh)
  material findings (reported, not confirmed, not deduplicated): per pass 1,1,1,1,1  occurrences 5 (? 0 of 5)
  increases: 0  comparisons unknown: 0  (cause of an increase unknown)
  coverage (recorded only): passes 5 against floor 3; final pass Blocker+Major 1; final pass zero findings no; reviewed scope unknown
  stored effort: unknown — no stored call; cause not known (possible: older than the store, made outside this clone or from a worktree removed before collection, still pending, or not yet collected)

prodzero  Gate B  no warning: 0 excess passes, 0 increases (amber at 4 / 2, product); usefulness unknown
  recommendation: no action suggested; usefulness unknown
  context: closed, commit SHA DATE, floor 3, stories {docs/superpowers/stories/s-story.md (level 1)}; workflow-rule version unknown
  distance: product (plugins/p/commands/c.md)
  material findings (reported, not confirmed, not deduplicated): per pass 0  occurrences 0 (? 0 of 1)
  increases: 0  comparisons unknown: 0  (cause of an increase unknown)
  coverage (recorded only): passes 1 against floor 3; final pass Blocker+Major 0; final pass zero findings yes; reviewed scope unknown
  stored effort: unknown — no stored call; cause not known (possible: older than the store, made outside this clone or from a worktree removed before collection, still pending, or not yet collected)

prodinc4  Gate B  red: 4 increases (red at 4, product)
  recommendation: surface to a human before running a similar loop again; change the review method or stop the approach
  context: closed, commit SHA DATE, floor 5, stories {docs/superpowers/stories/s-story.md (level 1)}; workflow-rule version unknown
  distance: product (plugins/p/commands/c.md)
  material findings (reported, not confirmed, not deduplicated): per pass 0,1,0,1,0,1,0,1  occurrences 4 (? 0 of 8)
  increases: 4  comparisons unknown: 0  (cause of an increase unknown)
  coverage (recorded only): passes 8 against floor 5; final pass Blocker+Major 1; final pass zero findings no; reviewed scope unknown
  stored effort: unknown — no stored call; cause not known (possible: older than the store, made outside this clone or from a worktree removed before collection, still pending, or not yet collected)

prodinc3  Gate B  amber: 3 increases (amber at 2, product)
  recommendation: reassess whether further passes of a similar loop have a concrete expected benefit
  context: closed, commit SHA DATE, floor 6, stories {docs/superpowers/stories/s-story.md (level 1)}; workflow-rule version unknown
  distance: product (plugins/p/commands/c.md)
  material findings (reported, not confirmed, not deduplicated): per pass 0,1,0,1,0,1  occurrences 3 (? 0 of 6)
  increases: 3  comparisons unknown: 0  (cause of an increase unknown)
  coverage (recorded only): passes 6 against floor 6; final pass Blocker+Major 1; final pass zero findings no; reviewed scope unknown
  stored effort: unknown — no stored call; cause not known (possible: older than the store, made outside this clone or from a worktree removed before collection, still pending, or not yet collected)

prodinc2  Gate B  amber: 2 increases (amber at 2, product)
  recommendation: reassess whether further passes of a similar loop have a concrete expected benefit
  context: closed, commit SHA DATE, floor 3, stories {docs/superpowers/stories/s-story.md (level 1)}; workflow-rule version unknown
  distance: product (plugins/p/commands/c.md)
  material findings (reported, not confirmed, not deduplicated): per pass 0,1,0,1,0  occurrences 2 (? 0 of 5)
  increases: 2  comparisons unknown: 0  (cause of an increase unknown)
  coverage (recorded only): passes 5 against floor 3; final pass Blocker+Major 0; final pass zero findings yes; reviewed scope unknown
  stored effort: unknown — no stored call; cause not known (possible: older than the store, made outside this clone or from a worktree removed before collection, still pending, or not yet collected)

prodinc1  Gate B  no warning: 0 excess passes, 1 increases (amber at 4 / 2, product); usefulness unknown
  recommendation: no action suggested; usefulness unknown
  context: closed, commit SHA DATE, floor 3, stories {docs/superpowers/stories/s-story.md (level 1)}; workflow-rule version unknown
  distance: product (plugins/p/commands/c.md)
  material findings (reported, not confirmed, not deduplicated): per pass 1,2,0  occurrences 3 (? 0 of 3)
  increases: 1  comparisons unknown: 0  (cause of an increase unknown)
  coverage (recorded only): passes 3 against floor 3; final pass Blocker+Major 0; final pass zero findings yes; reviewed scope unknown
  stored effort: unknown — no stored call; cause not known (possible: older than the store, made outside this clone or from a worktree removed before collection, still pending, or not yet collected)

prodred9  Gate B  red: 9 excess passes (red at 9, product)
  recommendation: surface to a human before running a similar loop again; change the review method or stop the approach
  context: closed, commit SHA DATE, floor 3, stories {docs/superpowers/stories/s-story.md (level 1)}; workflow-rule version unknown
  distance: product (plugins/p/commands/c.md)
  material findings (reported, not confirmed, not deduplicated): per pass 1,1,1,1,1,1,1,1,1,1,1,1  occurrences 12 (? 0 of 12)
  increases: 0  comparisons unknown: 0  (cause of an increase unknown)
  coverage (recorded only): passes 12 against floor 3; final pass Blocker+Major 1; final pass zero findings no; reviewed scope unknown
  stored effort: unknown — no stored call; cause not known (possible: older than the store, made outside this clone or from a worktree removed before collection, still pending, or not yet collected)

prodamb8  Gate B  amber: 8 excess passes (amber at 4, product)
  recommendation: reassess whether further passes of a similar loop have a concrete expected benefit
  context: closed, commit SHA DATE, floor 3, stories {docs/superpowers/stories/s-story.md (level 1)}; workflow-rule version unknown
  distance: product (plugins/p/commands/c.md)
  material findings (reported, not confirmed, not deduplicated): per pass 1,1,1,1,1,1,1,1,1,1,1  occurrences 11 (? 0 of 11)
  increases: 0  comparisons unknown: 0  (cause of an increase unknown)
  coverage (recorded only): passes 11 against floor 3; final pass Blocker+Major 1; final pass zero findings no; reviewed scope unknown
  stored effort: unknown — no stored call; cause not known (possible: older than the store, made outside this clone or from a worktree removed before collection, still pending, or not yet collected)

prodamb4  Gate B  amber: 4 excess passes (amber at 4, product)
  recommendation: reassess whether further passes of a similar loop have a concrete expected benefit
  context: closed, commit SHA DATE, floor 3, stories {docs/superpowers/stories/s-story.md (level 1)}; workflow-rule version unknown
  distance: product (plugins/p/commands/c.md)
  material findings (reported, not confirmed, not deduplicated): per pass 1,1,1,1,1,1,1  occurrences 7 (? 0 of 7)
  increases: 0  comparisons unknown: 0  (cause of an increase unknown)
  coverage (recorded only): passes 7 against floor 3; final pass Blocker+Major 1; final pass zero findings no; reviewed scope unknown
  stored effort: unknown — no stored call; cause not known (possible: older than the store, made outside this clone or from a worktree removed before collection, still pending, or not yet collected)

prodbnd3  Gate B  no warning: 3 excess passes, 0 increases (amber at 4 / 2, product); usefulness unknown
  recommendation: no action suggested; usefulness unknown
  context: closed, commit SHA DATE, floor 3, stories {docs/superpowers/stories/s-story.md (level 1)}; workflow-rule version unknown
  distance: product (plugins/p/commands/c.md)
  material findings (reported, not confirmed, not deduplicated): per pass 1,1,1,1,1,1  occurrences 6 (? 0 of 6)
  increases: 0  comparisons unknown: 0  (cause of an increase unknown)
  coverage (recorded only): passes 6 against floor 3; final pass Blocker+Major 1; final pass zero findings no; reviewed scope unknown
  stored effort: unknown — no stored call; cause not known (possible: older than the store, made outside this clone or from a worktree removed before collection, still pending, or not yet collected)

prodgrn1  Gate-A spec  no warning: 0 excess passes, 0 increases (amber at 4 / 2, product); usefulness unknown
  recommendation: no action suggested; usefulness unknown
  context: closed, commit SHA DATE, floor 3, stories {docs/superpowers/stories/s-story.md (level 1)}; workflow-rule version unknown
  distance: product (plugins/p/commands/c.md)
  material findings (reported, not confirmed, not deduplicated): per pass 5,3,1  occurrences 9 (? 0 of 3)
  increases: 0  comparisons unknown: 0  (cause of an increase unknown)
  coverage (recorded only): passes 3 against floor 3; final pass Blocker+Major 1; final pass zero findings no; reviewed scope unknown
  stored effort (observed): calls 2  stored for passes 1,3 of 1-3  duration_s 30.0 (? 0 of 2)
    tokens_in 100 (? 1 of 2)  tokens_cached 50 (? 1 of 2)  tokens_out 10 (? 1 of 2)  tokens_reasoning 5 (? 1 of 2)  tokens unknown: shared 1

== Thresholds (provisional, calibrated 2026-10-03; spec §5)
product    amber: excess >= 4 or increases >= 2   red: excess >= 9 or increases >= 4
machinery  amber: excess >= 3 or increases >= 2   red: excess >= 6 or increases >= 4
unknown distance: product thresholds; not determinable where machinery would warn and product would not

== What this report cannot answer
- Whether any finding was true, or how many distinct findings there were: no findings file is read.
- That a repair caused an increase, or that a finding recurred or was reopened.
- What the reviewer examined: coverage beyond the recorded counts is not recorded.
- Whether a loop was worth its effort: a warning means reassess, and no warning means only that no threshold was reached.
- Cost in money, and effort for cycles without stored calls.
- A cycle's distance where the changed files do not establish it, and which workflow-rule version governed a cycle.
- Whether the curves are right: they are author-written and unchecked.
- The vision's calibration cases (polish vs evidence-corrupting command, speculative vs needed optimization, useful clean pass vs unknown coverage): same counts can mean either.
- Cycles that left no record in the history read.
- Signals hidden by conflicting records: several curves, several skip records or a skip beside a curve make a
  nonce not determinable, and conflicting provenance lines make its excess unknown (its increases still count),
  even where the difference could not change a signal.
EOF

# ---- 2. failures ------------------------------------------------------------------------------------
bad "unresolvable ref" "the ref does not resolve to a commit" "$work/repo" nosuchref
build; (cd "$work/repo" && git config extensions.partialClone origin)
bad "partial clone refused" "partial clones are not supported" "$work/repo"
build
base=$(cd "$work/repo" && git rev-list --max-parents=0 HEAD)
rm -f "$work/repo/.git/objects/$(printf '%s' "$base" | cut -c1-2)/$(printf '%s' "$base" | cut -c3-)"
bad "history that cannot be read" "history could not be read" "$work/repo"
build; rm -f "$work/repo/.context/telemetry/gate-calls.jsonl"
out2=$(run "$work/repo")
printf '%s\n' "$out2" | grep -q '^run-analytics store: not read (absent or unreadable); skipped store lines 0$' &&
  printf '%s\n' "$out2" | grep -q '^  stored effort: unknown — store not read (absent or unreadable)$' &&
  pass "absent store: effort unknown, header says so" || fail "absent store"

build; (cd "$work/repo" && git config diff.relative true)
rel=$( (cd "$work/repo/scripts" && HOME="$work/home" python3 -B loop-usefulness.py) 2>&1)
printf '%s\n' "$rel" | grep -q '^sameprov  Gate B  amber: 3 excess passes (amber at 3, machinery)$' &&
  pass "run from a subdirectory with diff.relative set: distance still from repository-root paths" ||
  fail "diff.relative changed the distance"

# ---- 3. negative control ----------------------------------------------------------------------------
build
python3 - "$work/repo/scripts/loop-usefulness.py" "$work/repo/scripts/noinc.py" <<'PY'
import sys
s = open(sys.argv[1]).read()
a = "def state_for(dist, excess, inc, unk):\n"
assert s.count(a) == 1
open(sys.argv[2], "w").write(s.replace(a, a + "    inc = 0  # mutant: ignore increases\n"))
PY
mut=$( (cd "$work/repo" && HOME="$work/home" python3 -B scripts/noinc.py) 2>&1)
printf '%s\n' "$mut" | grep -q '^prodinc4  Gate B  no warning' &&
  printf '%s\n' "$out" | grep -q '^prodinc4  Gate B  red: 4 increases' &&
  pass "negative control: ignoring increases turns the four-increase cycle from red into no warning" ||
  fail "negative control not caught"

printf '\n%d passed, %d failed\n' "$pass_n" "$fail_n"
[ "$fail_n" -eq 0 ]
