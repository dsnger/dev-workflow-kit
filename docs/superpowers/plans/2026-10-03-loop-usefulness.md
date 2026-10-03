# Review-loop Warning Light Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Story:** `docs/superpowers/stories/2026-10-02-review-loop-usefulness-assessment-story.md` — read the profile from its header at every gate call.

**Goal:** Add `scripts/loop-usefulness.py`, a read-only report that gives every recorded review cycle except a skipped one (which ran no loop) one of four states — red, amber, no warning or not determinable — from its recorded passes against the floor and the increases in Blocker + Major between passes. Add its POSIX-sh suite, and wire the suite into the battery, CI and the docs.

**Architecture:** One Python 3.8+ standard-library script. It refuses a partial clone and resolves the ref. It reads commit-body records through `scripts/ledger-metrics.py`'s parser, loaded with `importlib` and with bytecode writing off. It reads the run-analytics store read-only, groups records by nonce, classifies each nonce, reads one commit's changed paths for the distance, and prints the report. It writes nothing. The suite builds one fixture repository in which each commit's changed file sets that cycle's distance, adds a fixture store, and compares the whole report with expected text.

**Tech Stack:** Python 3.8+ (standard library), git 2.36+, POSIX `sh` for the suite, `shellcheck` 0.11.0.

**Spec:** `docs/superpowers/specs/2026-10-02-loop-usefulness-design.md` (Gate-A spec cycle `b6d8vzijb6`, closed in `3345bf7`).

## Global Constraints

- Worktree `/Users/daniel/DEVELOPMENT/APPS/dwk-usefulness`, branch `usefulness`. Paths are relative to it.
- Not shipped: no file under `plugins/` changes, so there is no version bump (spec §1).
- Writes nothing. No findings file, dispositions file or session text is read (story profile: security none).
- P8 (`scripts/ledger-metrics.py`) is imported and never changed (epic criterion 8).
- The suite passes `shellcheck --shell=sh --exclude=SC2015`, like the other suites.
- Unexpected repository state is a stop and a question to Daniel; no automated stash, rebase or reset.

## Rulings — spec cycle Minors and implementation choices

The spec is closed and is not edited. Where the implementation settles something the spec left open, the ruling is stated here, and the Gate-B call names it.

1. **Changed paths ignore rename detection** (`git show --no-renames`), so a file moved out of a product path still reports its old path (spec pass-6 Minor).
2. **Skip precedence.** A nonce with skip records and no curve is *skipped* only with exactly one distinct skip text and at most one provenance text. Several skip texts, or a skip with conflicting provenance, make it *conflicting or incomplete* (spec pass-6 Minor).
3. **Conflicting texts stay conflicting** even where the disputed field could not change a signal (spec pass-4/5/6 Minor, kept for simplicity). For a closed or open cycle the text's whole identity decides, as in P8.
4. **The history format** `%H%x00%ct%n%B` with `-z` yields alternating hash and body tokens; the script reads them pairwise.
5. **The store** is found in the main worktree reported first by `git worktree list --porcelain -z`, as in part 1. A call's covered passes are the pass numbers of its slots that name the nonce.
6. **Some fixtures use floors 5, 6 or 8** (`prodinc4`, `prodinc3`, `machinc2`, `machinc4`), so that excess stays below amber and only the increases can warn. The parser accepts any positive floor, and the report does not validate floors.
7. **Bytecode is off before any other import**, and the documented invocation is `python3 -B`, which also stops the interpreter's own startup from writing bytecode (plan passes 1 and 2). The script cannot reach what the interpreter does before it runs, so the "writes nothing" check in the suite runs with `-B` as documented. The store reader requires every field to be present and accepts integer durations. It rejects a duration above 10^12 seconds, about 31,700 years, so sums stay finite (a stated bound beyond spec §2). It counts blank lines as skipped and keeps an empty `tokens_unknown` string as a reason. A commit date outside the range Python can render prints as "date unknown".

## Review Focus

1. **Real history.** The report over `main` at `7cbbce4` gives red 4, amber 1, no warning 21, one skipped and two pre-rule records, as spec §5a states (measured on the prototype on 2026-10-03). The plan does not need to repeat this run; Task 3 records it as evidence.
2. **CI's Linux runner** is the first non-macOS run. The suite needs `git`, `python3` and POSIX utilities (`mkdir`, `cat`, `wc`, `grep`, `sed`, `diff`). Read the CI log (Task 3).
3. **A signed history.** Every `log` and `show` call disables signature display, so no verifier runs (spec §2). The suite's fixture commits are unsigned; the main repository's squash commits are signed and were read without a verifier on 2026-10-03.
4. **A large history** costs one `git log` plus one `git show` per nonce. That is 27 on `main` today. No limit is set.

---

## File map

| Path | Change | Task |
|---|---|---|
| `scripts/loop-usefulness.test.sh` | Create | 1 |
| `scripts/loop-usefulness.py` | Create | 1 |
| `AGENTS.md` | Layout tree, Boundaries, quality, lint and typecheck rows, prerequisites | 2 |
| `.github/workflows/ci.yml` | Lint step, suite step, one comment | 2 |
| `README.md` | Contributing: the suites line and one paragraph | 2 |

---

### Task 1: The suite, then the script

**Files:** Create `scripts/loop-usefulness.test.sh`, `scripts/loop-usefulness.py`.

- [ ] **Step 1: Write the suite**

Create `scripts/loop-usefulness.test.sh` with exactly this content:

````sh
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
````

- [ ] **Step 2: Run it before the script exists**

Run: `sh scripts/loop-usefulness.test.sh > /tmp/lu-red.log 2>&1; echo "exit=$?"; tail -1 /tmp/lu-red.log`
Expected: `exit=1`. The fixture repository copies `scripts/loop-usefulness.py`, which does not exist yet.

- [ ] **Step 3: Write the script**

Create `scripts/loop-usefulness.py` with exactly this content:

````python
#!/usr/bin/env python3
"""A warning light over recorded review cycles: red, amber, no warning or not determinable.

Spec: docs/superpowers/specs/2026-10-02-loop-usefulness-design.md
Usage: python3 -B scripts/loop-usefulness.py [<ref>]   (-B also stops the interpreter's own startup
from writing bytecode; the script turns bytecode off before its first import either way)

Read-only: reads commit-body records (through scripts/ledger-metrics.py's parser) and the
run-analytics store, and writes nothing. A warning means "reassess review effort", never "waste
proven"; no state says a loop was useful. Standard library only; Python 3.8+; git 2.36+.
"""
import sys

sys.dont_write_bytecode = True  # before any other import: the report writes nothing, .pyc included

import datetime  # noqa: E402
import importlib.util
import json
import math
import os
import re
import subprocess

GIT_SELECTORS = ("GIT_DIR", "GIT_WORK_TREE", "GIT_COMMON_DIR", "GIT_INDEX_FILE",
                 "GIT_OBJECT_DIRECTORY", "GIT_ALTERNATE_OBJECT_DIRECTORIES",
                 "GIT_CEILING_DIRECTORIES", "GIT_DISCOVERY_ACROSS_FILESYSTEM", "GIT_NAMESPACE")
NO_SIG = ("-c", "log.showSignature=false")
RE_SLOT = re.compile(r"gate-a-(?:spec|plan)(?:-([a-z0-9]{8,16}))?-pass-([1-9][0-9]*)"
                     r"|gate-b-(?:spec|quality)(?:-([a-z0-9]{8,16}))?-pass-([1-9][0-9]*)")
TOKEN_FIELDS = ("tokens_in", "tokens_cached", "tokens_out", "tokens_reasoning")
PRODUCT = re.compile(r"plugins/[^/]+/(?:skills|commands|agents)/.+|plugins/[^/]+/hooks/hooks\.json"
                     r"|plugins/[^/]+/hooks/(?![^/]*\.test\.sh$)[^/]+\.sh|plugins/[^/]+/\.claude-plugin/plugin\.json", re.S)
MACHINERY = re.compile(r"scripts/[^/]+\.(?:sh|py)|\.github/workflows/[^/]+|plugins/[^/]+/hooks/[^/]+\.test\.sh"
                       r"|CLAUDE\.md|AGENTS\.md|\.mcp\.json")
# Provisional thresholds (spec §5): (amber excess, amber increases), (red excess, red increases).
THRESHOLDS = {"product": ((4, 2), (9, 4)), "machinery": ((3, 2), (6, 4))}
CALIBRATED = "2026-10-03"
RANK = {"no warning": 0, "amber": 1, "red": 2}
RECOMMEND = {
    "red": "surface to a human before running a similar loop again; change the review method or stop the approach",
    "amber": "reassess whether further passes of a similar loop have a concrete expected benefit",
    "no warning": "no action suggested; usefulness unknown",
    "not determinable": "supply the missing data or classify by hand before relying on this state",
}

CANNOT = """== What this report cannot answer
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
  even where the difference could not change a signal."""


def shown(text):
    return "".join("\\x%02x" % ord(c) if ord(c) < 0x20 or 0x7F <= ord(c) <= 0x9F else c for c in str(text))


def die(msg):
    sys.stderr.buffer.write(("loop-usefulness: %s\n" % shown(msg)).encode("utf-8", "backslashreplace"))
    sys.stderr.flush()
    sys.exit(1)


def git_env():
    env = {k: v for k, v in os.environ.items() if not k.startswith("GIT_TRACE")}
    for k in GIT_SELECTORS:
        env.pop(k, None)
    env.update(GIT_TRACE2="0", GIT_TRACE2_EVENT="0", GIT_TRACE2_PERF="0")
    return env


def git(args, cwd="."):
    try:
        p = subprocess.run(("git",) + tuple(args), cwd=cwd, env=git_env(),
                           stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    except OSError:
        return 127, b""
    return p.returncode, p.stdout


def load_parser(here):
    spec = importlib.util.spec_from_file_location("ledger_metrics", os.path.join(here, "ledger-metrics.py"))
    try:
        mod = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(mod)
    except (OSError, SyntaxError, AttributeError):
        die("the record parser scripts/ledger-metrics.py cannot be loaded")
    return mod


# ---- records ---------------------------------------------------------------------------------------

def read_records(sha, lm):
    """nonce -> {"curve"|"prov"|"skip": {text: [(ct, sha), ...]}}, plus pre-rule and unparsed counts."""
    rc, out = git(NO_SIG + ("-c", "i18n.logOutputEncoding=UTF-8", "log", "--no-show-signature", "-z",
                            "--format=%H%x00%ct%n%B", sha))
    if rc != 0:
        die("history could not be read")
    parts = out.decode("utf-8", "replace").split("\0")
    nonces, prerule, unparsed = {}, 0, 0
    for i in range(0, len(parts) - 1, 2):
        csha = parts[i].lstrip("\n")
        head, _, body = parts[i + 1].partition("\n")
        ct = int(head) if head.isdigit() else 0
        lines, j, seen = body.split("\n"), 0, set()
        while j < len(lines):
            line = lines[j]
            j += 1
            if not lm.CANDIDATE.match(line):
                continue
            parsed = lm.parse_record(line)
            if parsed is None:
                unparsed += 1
                continue
            field, typ, _data = parsed
            text = line
            if typ == "skip":  # the reason after the marker is part of its identity, as in P8
                reason = []
                while j < len(lines) and lines[j] != "" and not lm.CANDIDATE.match(lines[j]):
                    reason.append(lines[j])
                    j += 1
                text = line + " | " + " ".join(reason)
            if field == "none (pre-rule)":
                prerule += 1
                continue
            if (typ, text) in seen:
                continue
            seen.add((typ, text))
            nonces.setdefault(field, {}).setdefault(typ, {}).setdefault(text, []).append((ct, csha))
    return nonces, prerule, unparsed


def newest(occurrences):
    return max(occurrences)  # (ct, sha): newest commit date, ties by the greater sha


def classify(recs):
    """Return (listing, reason): skipped, closed, open, or conflicting (spec §3)."""
    curves, provs, skips = recs.get("curve", {}), recs.get("prov", {}), recs.get("skip", {})
    if skips and not curves:
        if len(skips) == 1 and len(provs) <= 1:
            return "skipped", None
        return "conflicting", "several skip records" if len(skips) > 1 else "conflicting provenance lines"
    if len(curves) == 1 and not skips:
        if len(provs) == 1:
            return "closed", None
        return "open", "no provenance line" if not provs else "conflicting provenance lines"
    if not curves:
        return "conflicting", "no curve"
    return "conflicting", "several curves" if len(curves) > 1 else "a skip record beside a curve"


def parse_counts(lm, curve_text):
    data = lm.parse_record(curve_text)[2]
    f, b, m = (data[k].split(",") for k in ("f", "b", "m"))
    passes = lm.expand(data["spec"], len(f))
    num = lambda v: None if v == "?" else int(v)
    bm = [None if num(x) is None or num(y) is None else num(x) + num(y) for x, y in zip(b, m)]
    return data["kind"], passes, bm


# ---- distance and state ----------------------------------------------------------------------------

def distance(sha):
    rc, out = git(NO_SIG + ("show", "--no-show-signature", "--first-parent", "--no-renames", "--no-relative",
                            "--name-only", "--format=", "-z", sha))
    if rc != 0:
        return "unknown", "commit cannot be read — classify by hand"
    paths = sorted(p for p in out.decode("utf-8", "replace").split("\0") if p)
    for p in paths:
        if PRODUCT.fullmatch(p):
            return "product", p
    for p in paths:
        if MACHINERY.fullmatch(p):
            return "machinery", p
    return "unknown", "no changed file establishes it — classify by hand"


def state_for(dist, excess, inc, unk):
    (ae, ai), (re_, ri) = THRESHOLDS[dist]
    if (excess is not None and excess >= re_) or inc >= ri:
        why = "%d excess passes (red at %d" % (excess, re_) if excess is not None and excess >= re_ \
            else "%d increases (red at %d" % (inc, ri)
        return "red", why + ", %s)" % dist
    if (excess is not None and excess >= ae) or inc >= ai:
        why = "%d excess passes (amber at %d" % (excess, ae) if excess is not None and excess >= ae \
            else "%d increases (amber at %d" % (inc, ai)
        return "amber", why + ", %s)" % dist
    if excess is None:
        return "not determinable", "excess unknown without a single provenance line; %d increases" % inc
    if unk:
        return "not determinable", "%d comparisons unknown; %d excess passes, %d increases" % (unk, excess, inc)
    return "no warning", "%d excess passes, %d increases (amber at %d / %d, %s); usefulness unknown" % (
        excess, inc, ae, ai, dist)


def decide(dist, excess, inc, unk):
    if dist != "unknown":
        return state_for(dist, excess, inc, unk)
    sp, wp = state_for("product", excess, inc, unk)
    sm = state_for("machinery", excess, inc, unk)[0]
    if sp == "no warning" and sm in RANK and RANK[sm] > 0:
        return "not determinable", "%s under machinery thresholds, no warning under product thresholds" % sm
    if sp in ("amber", "red") and sm in RANK and RANK[sm] > RANK[sp]:
        return sp, "%s; %s under machinery thresholds" % (wp, sm)
    return sp, wp


# ---- store -----------------------------------------------------------------------------------------

STORE_FIELDS = ("tool_use_id", "slots", "duration_s", "tokens_unknown") + TOKEN_FIELDS


def valid_line(r):
    if not isinstance(r, dict) or not all(k in r for k in STORE_FIELDS) or not isinstance(r["tool_use_id"], str):
        return False
    if not isinstance(r.get("slots"), list) or not all(isinstance(s, str) for s in r["slots"]):
        return False
    d = r.get("duration_s")
    if d is not None and (isinstance(d, bool) or not isinstance(d, (int, float)) or d < 0
                          or (isinstance(d, float) and not math.isfinite(d)) or d > 1e12):
        return False
    toks = [r.get(f) for f in TOKEN_FIELDS]
    if not all(t is None or (isinstance(t, int) and not isinstance(t, bool) and t >= 0) for t in toks):
        return False
    tu = r.get("tokens_unknown")
    if tu is not None and not isinstance(tu, str):
        return False
    return (tu is None) == all(isinstance(t, int) for t in toks)


def read_store():
    """nonce -> {tool_use_id: (record, {pass numbers})}; plus status text and skipped-line count."""
    rc, out = git(("worktree", "list", "--porcelain", "-z"))
    main = None
    if rc == 0:
        for f in out.split(b"\0"):
            if f.startswith(b"worktree "):
                main = os.fsdecode(f[len(b"worktree "):])
                break
    if main is None:
        return {}, "not read (main worktree unknown)", 0
    path = os.path.join(main, ".context", "telemetry", "gate-calls.jsonl")
    try:
        with open(path, "rb") as fh:
            raw = fh.read().decode("utf-8", "replace").split("\n")
    except OSError:
        return {}, "not read (absent or unreadable)", 0
    by_nonce, seen, skipped = {}, set(), 0
    if raw and raw[-1] == "":
        raw.pop()  # the newline that ends the last line
    for line in raw:
        if not line.strip():
            skipped += 1
            continue
        try:
            r = json.loads(line)
        except (ValueError, RecursionError):
            skipped += 1
            continue
        if not valid_line(r) or r["tool_use_id"] in seen:
            skipped += 1
            continue
        seen.add(r["tool_use_id"])
        for s in r["slots"]:
            m = RE_SLOT.fullmatch(s)
            n = m and (m.group(1) or m.group(3))
            if n:
                entry = by_nonce.setdefault(n, {}).setdefault(r["tool_use_id"], (r, set()))
                entry[1].add(int(m.group(2) or m.group(4)))
    return by_nonce, "read", skipped


def ranges(nums):
    out, nums = [], sorted(nums)
    i = 0
    while i < len(nums):
        j = i
        while j + 1 < len(nums) and nums[j + 1] == nums[j] + 1:
            j += 1
        out.append(str(nums[i]) if i == j else "%d-%d" % (nums[i], nums[j]))
        i = j + 1
    return ",".join(out) or "-"


def total(values, fmt):
    known = [v for v in values if v is not None]
    return "%s (? %d of %d)" % (fmt(sum(known)) if known else "?", len(values) - len(known), len(values))


def effort_lines(calls, passes, store_status):
    if store_status != "read":
        return ["  stored effort: unknown — store %s" % store_status]
    if not calls:
        return ["  stored effort: unknown — no stored call; cause not known (possible: older than the store, made "
                "outside this clone or from a worktree removed before collection, still pending, or not yet "
                "collected)"]
    recs = [r for r, _p in calls.values()]
    covered = set().union(*(p for _r, p in calls.values()))
    reasons = {}
    for r in recs:
        if r.get("tokens_unknown") is not None:
            reasons[r["tokens_unknown"]] = reasons.get(r["tokens_unknown"], 0) + 1
    line = "  stored effort (observed): calls %d  stored for passes %s of %s  duration_s %s" % (
        len(recs), ranges(covered), ranges(passes), total([r.get("duration_s") for r in recs], lambda x: "%.1f" % x))
    toks = "  ".join("%s %s" % (f, total([r.get(f) for r in recs], str)) for f in TOKEN_FIELDS)
    why = ", ".join("%s %d" % (k or "(empty)", v) for k, v in sorted(reasons.items())) or "none"
    return [line, "    " + toks + "  tokens unknown: " + shown(why)]


# ---- main ------------------------------------------------------------------------------------------

def main(argv):
    if len(argv) > 2:
        die("usage: loop-usefulness.py [<ref>]")
    ref = argv[1] if len(argv) == 2 else "HEAD"
    rc, out = git(("--version",))
    m = re.search(rb"(\d+)\.(\d+)", out) if rc == 0 else None
    if not m or (int(m.group(1)), int(m.group(2))) < (2, 36):
        die("git 2.36 or later is required")
    rc, out = git(("config", "--get-regexp", r"^(extensions\.partialclone|remote\..*\.(promisor|partialclonefilter))$"))
    if out.strip():
        die("partial clones are not supported (reading history could fetch objects)")
    rc, out = git(("rev-parse", "--verify", "--end-of-options", ref + "^{commit}"))
    if rc != 0 or not out.strip():
        die("the ref does not resolve to a commit: %s" % ref)
    sha = out.decode().strip()
    lm = load_parser(os.path.dirname(os.path.abspath(__file__)))
    nonces, prerule, unparsed = read_records(sha, lm)
    store, store_status, store_skipped = read_store()
    rc, sh = git(("rev-parse", "--is-shallow-repository"))

    blocks, counts, listing_counts = [], {}, {}
    for nonce, recs in nonces.items():
        listing, reason = classify(recs)
        listing_counts[listing] = listing_counts.get(listing, 0) + 1
        if listing == "skipped":
            ct, csha = newest(next(iter(recs["skip"].values())))
            blocks.append((ct, ["%s  skipped — no loop ran, no state  commit %s" % (nonce, csha[:12])]))
            continue
        if listing == "conflicting":
            occ = [o for kind in recs.values() for v in kind.values() for o in v]
            ct, csha = newest(occ)
            st = "not determinable"
            counts[st] = counts.get(st, 0) + 1
            blocks.append((ct, ["%s  %s: %s (%s)" % (nonce, st, reason, "conflicting or incomplete records"),
                                "  recommendation: " + RECOMMEND[st]]))
            continue
        curve_text = next(iter(recs["curve"]))
        kind, passes, bm = parse_counts(lm, curve_text)
        inc = sum(1 for a, b in zip(bm, bm[1:]) if a is not None and b is not None and b > a)
        unk = sum(1 for a, b in zip(bm, bm[1:]) if a is None or b is None)
        if listing == "closed":
            prov_text = next(iter(recs["prov"]))
            pdata = lm.parse_record(prov_text)[2]
            floor, cset = int(pdata["floor"]), pdata["set"]
            excess = max(0, len(bm) - floor)
            ct, csha = newest(recs["prov"][prov_text])
        else:
            floor, cset, excess = None, None, None
            ct, csha = newest(recs["curve"][curve_text])
        dist, dwhy = distance(csha)
        st, why = decide(dist, excess, inc, unk)
        counts[st] = counts.get(st, 0) + 1
        try:
            date = datetime.datetime.fromtimestamp(ct, datetime.timezone.utc).strftime("%Y-%m-%d")
        except (OverflowError, OSError, ValueError):
            date = "date unknown"
        lines = ["%s  %s  %s: %s" % (nonce, kind, st, why),
                 "  recommendation: " + RECOMMEND[st],
                 "  context: %s, commit %s %s, floor %s, stories %s; workflow-rule version unknown" % (
                     listing if listing == "closed" else "open or unclosed (%s)" % reason, csha[:12], date,
                     floor if floor is not None else "unknown", shown(cset) if cset is not None else "unknown"),
                 "  distance: %s (%s)" % (dist, shown(dwhy)),
                 "  material findings (reported, not confirmed, not deduplicated): per pass %s  occurrences %s" % (
                     ",".join("?" if v is None else str(v) for v in bm), total(bm, str)),
                 "  increases: %d  comparisons unknown: %d  (cause of an increase unknown)" % (inc, unk),
                 "  coverage (recorded only): passes %d against floor %s; final pass Blocker+Major %s; "
                 "final pass zero findings %s; reviewed scope unknown" % (
                     len(bm), floor if floor is not None else "unknown",
                     "?" if bm[-1] is None else bm[-1],
                     "?" if lm.parse_record(curve_text)[2]["f"].split(",")[-1] == "?"
                     else ("yes" if lm.parse_record(curve_text)[2]["f"].split(",")[-1] == "0" else "no"))]
        lines += effort_lines(store.get(nonce, {}), passes, store_status)
        blocks.append((ct, lines))
    blocks.sort(key=lambda b: -b[0])

    out = ["loop-usefulness — a warning light over recorded review cycles (reassess effort; not a usefulness verdict)",
           "ref %s (%s)%s" % (shown(ref), sha[:12], "  shallow: older records may be missing" if sh.strip() == b"true" else ""),
           "nonces: closed %d  open or unclosed %d  skipped %d  conflicting or incomplete %d;  pre-rule records %d  "
           "unparsed record lines %d" % (listing_counts.get("closed", 0), listing_counts.get("open", 0),
                                         listing_counts.get("skipped", 0), listing_counts.get("conflicting", 0),
                                         prerule, unparsed),
           "run-analytics store: %s; skipped store lines %d" % (store_status, store_skipped),
           "states: red %d  amber %d  no warning %d  not determinable %d" % tuple(
               counts.get(k, 0) for k in ("red", "amber", "no warning", "not determinable")),
           "", "== Cycles (newest first)"]
    if not blocks:
        out.append("none")
    for _ct, lines in blocks:
        out += lines + [""]
    out += ["== Thresholds (provisional, calibrated %s; spec §5)" % CALIBRATED]
    for d, ((ae, ai), (re_, ri)) in THRESHOLDS.items():
        out.append("%-10s amber: excess >= %d or increases >= %d   red: excess >= %d or increases >= %d" % (
            d, ae, ai, re_, ri))
    out.append("unknown distance: product thresholds; not determinable where machinery would warn and product would not")
    out += ["", CANNOT]
    sys.stdout.buffer.write(("\n".join(out) + "\n").encode("utf-8", "backslashreplace"))
    return 0


if __name__ == "__main__":
    if hasattr(sys, "set_int_max_str_digits"):
        sys.set_int_max_str_digits(0)
    sys.exit(main(sys.argv))
````

- [ ] **Step 4: Run the suite under both shells, reading each status**

Run: `sh scripts/loop-usefulness.test.sh > /tmp/lu-sh.log 2>&1; echo "sh=$?"; dash scripts/loop-usefulness.test.sh > /tmp/lu-dash.log 2>&1; echo "dash=$?"; tail -1 /tmp/lu-sh.log /tmp/lu-dash.log`
Expected: `sh=0`, `dash=0`, and `10 passed, 0 failed` in both (measured on the prototype on 2026-10-03).

- [ ] **Step 5: Lint the suite**

Run: `shellcheck --shell=sh --exclude=SC2015 scripts/loop-usefulness.test.sh; echo "lint=$?"`
Expected: `lint=0`.

No commit (Task 3 makes the single Gate-B snapshot).

---

### Task 2: Battery, CI and docs

**Files:** Modify `AGENTS.md`, `.github/workflows/ci.yml`, `README.md`.

- [ ] **Step 1: Find every place that counts the executables, reports or suites**

```sh
grep -rnE 'two Python reports|three Python reports|two untyped|five suites|six suites|two reports|three reports' --include='*.md' --include='*.yml' . | grep -vE 'source-files/|docs/superpowers/|\.context/|hardening-log|CHANGELOG'
```
Expected on 2026-10-03: `.github/workflows/ci.yml:40`, `AGENTS.md:69`, `AGENTS.md:263` and `README.md:163`. All four are edited below; any other hit is a stop.

The Boundaries paragraph says which directories load by convention, so AGENTS.md's Don'ts require a manifest read before it is edited. Run `cat plugins/dev-workflow/.claude-plugin/plugin.json` and confirm it declares no component keys. Then run the census:
`grep -rniE 'declare[sd]?|convention[- ]load' --include='*.md' . | grep -v source-files/`
Read every hit in the files this task edits, and confirm none of them becomes false. The edit only adds the third report.

- [ ] **Step 2: Apply the edits**

Save this as a temporary file outside the repository and run it from the repository root with `python3`. It writes nothing unless every replacement matches exactly once.

```python
# Applies the Task 2 documentation and CI edits. Every replacement must match exactly
# once, or the script stops before writing anything.
import sys
edits = {
 "AGENTS.md": [
  ("scripts/run-analytics.test.sh     # its regression suite — fixture home + repos, expected text\n",
   "scripts/run-analytics.test.sh     # its regression suite — fixture home + repos, expected text\n"
   "scripts/loop-usefulness.py        # warning light over recorded review cycles (vision step 2c, part 2)\n"
   "scripts/loop-usefulness.test.sh   # its regression suite — fixture repo + store, expected text\n"),
  ("`scripts/check-version-bump.{sh,test.sh}`), plus two Python reports with their suites:\n"
   "`scripts/ledger-metrics.{py,test.sh}` (read-only) and `scripts/run-analytics.{py,test.sh}`\n"
   "(writes only its own store under `.context/telemetry/`) — the hook ships in the plugin, the\n"
   "checkers and the reports do not;",
   "`scripts/check-version-bump.{sh,test.sh}`), plus three Python reports with their suites:\n"
   "`scripts/ledger-metrics.{py,test.sh}` and `scripts/loop-usefulness.{py,test.sh}` (read-only),\n"
   "and `scripts/run-analytics.{py,test.sh}` (writes only its own store under\n"
   "`.context/telemetry/`) — the hook ships in the plugin, the checkers and the reports do not;"),
  ("shellcheck --shell=sh --exclude=SC2015 scripts/run-analytics.test.sh && HOOK_SH=sh",
   "shellcheck --shell=sh --exclude=SC2015 scripts/run-analytics.test.sh && shellcheck --shell=sh --exclude=SC2015 scripts/loop-usefulness.test.sh && HOOK_SH=sh"),
  ("shellcheck --shell=sh --exclude=SC2015 scripts/run-analytics.test.sh` |",
   "shellcheck --shell=sh --exclude=SC2015 scripts/run-analytics.test.sh && shellcheck --shell=sh --exclude=SC2015 scripts/loop-usefulness.test.sh` |"),
  ("sh scripts/run-analytics.test.sh && claude plugin validate . --strict` |",
   "sh scripts/run-analytics.test.sh && sh scripts/loop-usefulness.test.sh && claude plugin validate . --strict` |"),
  ("| typecheck | n/a — no typed sources (shell, two untyped Python reports, markdown) |",
   "| typecheck | n/a — no typed sources (shell, three untyped Python reports, markdown) |"),
  ("`scripts/run-analytics.py` also needs git 2.36 or later\nand checks for it.\n",
   "`scripts/run-analytics.py` and `scripts/loop-usefulness.py`\nalso need git 2.36 or later and check for it.\n"),
 ],
 ".github/workflows/ci.yml": [
  ("      # The hook, the two checkers, the two Python reports and their five suites are\n",
   "      # The hook, the two checkers, the three Python reports and their six suites are\n"),
  ("            --shell=sh --exclude=SC2015 scripts/run-analytics.test.sh\n",
   "            --shell=sh --exclude=SC2015 scripts/run-analytics.test.sh\n"
   "          # The loop-usefulness suite (vision step 2c, part 2), linted the same way.\n"
   "          docker run --rm -v \"$PWD:/mnt\" -w /mnt koalaman/shellcheck:v0.11.0 \\\n"
   "            --shell=sh --exclude=SC2015 scripts/loop-usefulness.test.sh\n"),
  ("          sh scripts/run-analytics.test.sh\n\n",
   "          sh scripts/run-analytics.test.sh\n          sh scripts/loop-usefulness.test.sh\n\n"),
 ],
 "README.md": [
  ("both checkers' regression suites, the two reports' suites, and\n",
   "both checkers' regression suites, the three reports' suites, and\n"),
  ("keeps numbers and identifiers only, in `.context/telemetry/` of this clone, for 365 days.\n",
   "keeps numbers and identifiers only, in `.context/telemetry/` of this clone, for 365 days.\n\n"
   "`python3 -B scripts/loop-usefulness.py [<ref>]` gives every review cycle whose records are in the\n"
   "history read a warning light (a skipped cycle ran no loop and is listed without one):\n"
   "red or amber where its recorded passes or rising findings call for reassessing review effort,\n"
   "no warning where no threshold is reached, and not determinable where missing or conflicting\n"
   "data leaves the state open. It does not say whether a loop was worth its effort, and it writes\n"
   "nothing (`-B` keeps the interpreter from writing bytecode too).\n"),
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

Expected: `edited: AGENTS.md, .github/workflows/ci.yml, README.md`.

- [ ] **Step 3: Run the AGENTS.md quality row, verbatim**

`sh -c '<row>' > /tmp/lu-quality.log 2>&1; echo "quality=$?"`. Expected: `quality=0`, with `10 passed, 0 failed` from the new suite (measured on a copy on 2026-10-03).

No commit.

---

### Task 3: Evidence, Gate B, close

- [ ] **Step 1: Base check.** Run `git fetch origin; echo "fetch=$?"`, then `git merge-base --is-ancestor origin/main HEAD; echo "anc=$?"`. Anything but `fetch=0` and `anc=0` is a stop: ask Daniel.

- [ ] **Step 2: Stage and snapshot.** Run `git add scripts/loop-usefulness.py scripts/loop-usefulness.test.sh AGENTS.md .github/workflows/ci.yml README.md && git diff --cached --name-only`. Exactly those five paths must be listed. Then, as its own one-line tool call: `git commit -m 'WIP: loop usefulness candidate'`.

- [ ] **Step 3: Evidence run.**
  - Record `git rev-parse HEAD`, and check that `git status --porcelain --untracked-files=no` prints nothing.
  - Check `test "$(git rev-parse main)" = "$(git rev-parse origin/main)"`. A non-zero exit is a stop.
  - Run the quality row verbatim (exit 0), and `dash scripts/loop-usefulness.test.sh` (exit 0, `10 passed, 0 failed`).
  - Run the report over real history from the main checkout, without changing it: `python3 -B scripts/loop-usefulness.py main` from this worktree, which shares the repository. Expect `states: red 4  amber 1  no warning 21  not determinable 0`.
  - `git ls-tree 3345bf7 -- scripts/loop-usefulness.py` must print nothing.
  - Repeat the HEAD and status checks.

Evidence entry for the commit body:

```
Evidence — docs/superpowers/stories/2026-10-02-review-loop-usefulness-assessment-story.md
Battery: AGENTS.md quality row, exit 0 at <headSha>.
Check (counterfactual): at 3345bf7 no report exists (git ls-tree prints nothing).
Negative control in the suite: a copy that ignores increases turns the four-increase
fixture from red into no warning, and the suite catches it. Suite 10/10 under sh (in the
quality row) and under dash. Over main at 7cbbce4: red 4, amber 1, no warning 21, as
spec §5a states.
```

- [ ] **Step 4: Gate B.** Follow CLAUDE.md §5:
  - Draw a new nonce. The floor is 3 (story `standard`/`none`). No lens set applies: risk is not `high` and security is `none`.
  - Check `mcp__codex__health` first; it must report `gpt-6-astra`, and anything else is a stop.
  - Set `baseSha` to the parent of the WIP commit, as its full 40-character name. Resolve `headSha` to its full name immediately before each call.
  - Use one `reviewType: full` call per pass, with separate branch files. Each reviewer writes only its own file.
  - Each call carries the story path, the evidence entry verbatim, the seven rulings, and the standing lens, naming what this diff changes: the report and suite counts, the AGENTS.md rows and prerequisites, the CI steps and README.
  - After fixes: `git add`, then `git commit --amend -m 'WIP: loop usefulness candidate'` as its own one-line tool call, then the evidence run, then the re-review.

- [ ] **Step 5: Close and PR.** When the §5 closure ordering allows it:
  - Run the evidence again.
  - `git log --format='%h %s' origin/main..HEAD` must show the WIP commit over the plan's Gate-A closing commit, then `3345bf7`, `32609a0`, `5fcc072`, with nothing staged. Any other shape is a stop.
  - Run `git commit --amend -m "<real message>"`, with the evidence entry, the provenance line, the curve and the logical-pass prose, and no trailers.
  - Push, open a PR, and check that CI's log shows `10 passed, 0 failed`.

## Self-review (2026-10-03)

- **Spec coverage:**
  - §1 → `RECOMMEND` and the four states.
  - §2 → `git_env`, `load_parser`, `read_store`, `valid_line`, the partial-clone and ref checks.
  - §3 → `read_records`, `classify`, `parse_counts`, `effort_lines`.
  - §4 → `distance`, `newest`.
  - §5 → `THRESHOLDS`, `state_for`, `decide`.
  - §5a → evidence step (real history).
  - §6 → `main`'s report and `CANNOT`.
  - §7 → the suite (one fixture per listed case; the store cases are lines t1-t4 and the malformed lines).
- **Story criteria:**
  - 1 → per-cycle lines;
  - 2 → four states and recommendations;
  - 3 → spec §5a and the thresholds section;
  - 4 → `distance` (unknown → "classify by hand");
  - 5 → `prodzero` and `prodgrn1` give no warning;
  - 6 → `CANNOT`;
  - 7 → no-write snapshot test, no `__pycache__`.
- **Placeholders:** `<headSha>`, `<real message>` and `<row>` are filled in at run time.
