# Live Effort Counters Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Story:** `docs/superpowers/stories/2026-10-05-live-effort-counters-story.md` — read the profile from its header at every gate call.

**Goal:** Add `scripts/live-effort.py`, a read-only terminal report of the effort of review cycles that have not closed, plus pending gate calls. It comes with its regression suite and is wired into the battery and the docs.

**Architecture:** The report loads `scripts/run-analytics.py` and calls its scanning, measuring and classifying functions. It never calls part 1's store or lock functions. All three new files were prototyped and run against a copy on 2026-10-05.

**Tech Stack:** Python 3.8+ (standard library), POSIX `sh` for the suite, git 2.36+, `shellcheck` 0.11.0.

**Spec:** `docs/superpowers/specs/2026-10-05-live-effort-counters-design.md` (Gate-A spec cycle `k811p9eoa8`, closed in `13e0a50`).

## Global Constraints

- Worktree `/Users/daniel/DEVELOPMENT/APPS/dwk-live-counters`, branch `live-counters`. Paths are relative to it.
- The report changes no gate rule, pass rule, hook, threshold, store or money figure (story AC-5). `scripts/run-analytics.py` is not edited.
- No plugin path changes, so there is no version bump (invariant 12 does not apply).
- Unexpected repository state is a stop and a question to Daniel; no automated stash, rebase or reset.

## Rulings — the spec cycle's collected Minors and implementation choices

1. **Several nonces in one reply** (spec pass 3, Minor 1). The report keeps part 1's rule: a call is counted once under each nonce it names. The open-cycles heading says so. The excluded line counts **call-nonce pairs**, and it is labelled that way.
2. **Calls part 1 rejects** (spec pass 3, Minor 2). The header carries part 1's malformed-call count. It also carries the "values that failed their checks" count, so a rejected call is visible as a number, not silently lost.
3. **The "no result after 6 h" group** is labelled `no valid end (no result after 6 h, or an unusable end time)`. `build_record` gives both cases the same record shape (no `ended`), and the label must not claim a cause the record does not carry.
4. **Runtime.** The report reads every transcript, as part 1 does; on this machine a run took about 100 s. Restricting the scan by file age would change which calls it can see. That is left for later and noted in the README.
5. **Clock and freshness.**
   - The reference time is taken **after** the sources are read (plan pass 1). A scan can take minutes, and a call that starts during it must not read as future clock skew. No test simulates a slow scan; the ordering is stated in the code.
   - The report reads the real clock, so the text comparison masks clock-dependent values (`<t>`, `<s>`). The `clock` case then checks them against the fixture: the newest observed value is exact, the report time is later, and the cycle's elapsed time and the pending call's time fall within a bound around their offsets.
6. **Mutation evidence.** Measured on the prototype, 2026-10-05, with the `mut.py` script in Task 4; not re-run per review. Each mutation fails the named cases:
   - attributing pending calls by request nonce: `report`, `clock`, `after completion`, `reconciliation`;
   - dropping the unattributed population: `report`, `after completion`;
   - matching Codex logs to pending calls by directory and start time (a real match, as spec §1 forbids): `report`;
   - hiding the skipped-source counts: `report`;
   - treating conflicting cycles as open: `report`, `after completion`;
   - removing the 24-hour cutoff: `report`, `after completion`;
   - printing the report time as the newest value: `clock`;
   - zeroing every elapsed value: `clock`.
7. **Transitions covered.**
   - Pending to completed, and pending to failed, are run: the `after completion` case adds results to the same calls.
   - Pending to "no result after 6 h" is shown only statically, by a call that is already eight hours old. Aging a call would need a controlled clock, which the report deliberately does not take as an option.
8. **Review records stay untracked** under `.context/codex-reviews/`. The clean check uses `git status --porcelain --untracked-files=no`.
9. **No pass numbers in unattributed lines.** Those lines use part 1's totals without its `passes` field, because they hold calls with no cycle, and a call is not a pass. Open-cycle lines carry none either.

## Review Focus

1. **A real repository with many transcripts:** the report must finish and print the same sections. Task 2 runs it once on this repository.
2. **A pending call in the current session:** while a gate call runs, re-running the report shows it as pending with time since invocation. The Gate-B evidence run observes this on a real call, if one is pending at that moment.
3. **Reconciliation on real data:** for an open cycle, the report's totals must equal run-analytics' `open:` line for the same nonce, with a fresh store. The suite checks this on a fixture.
4. **Unknown-heavy output:** totals must read `? (? n of n)`, never 0. The fixture's empty-log call covers this.
5. **No writes:** the suite compares checksums of the fixture HOME and repository before and after the run.

---

## File map

| Path | Change | Task |
|---|---|---|
| `scripts/live-effort.test.sh` | new suite | 1 |
| `scripts/live-effort.py` | new report | 2 |
| `AGENTS.md` | tree, boundaries, quality/lint/typecheck rows, requirements line | 3 |
| `.github/workflows/ci.yml` | shellcheck step and suite step; executables comment | 3 |
| `README.md` | report paragraph; "five reports' suites" | 3 |
| `docs/superpowers/stories/2026-10-02-telemetry-and-review-loop-usefulness-story.md`, `todos.md` | the dated part-4 split | 3 |

---

### Task 1: The suite first (red)

- [ ] **Step 1: Create `scripts/live-effort.test.sh`** with exactly this content:

`````sh
#!/bin/sh
# Regression suite for live-effort.py.
#
# Spec: docs/superpowers/specs/2026-10-05-live-effort-counters-design.md §5. Builds a fixture HOME
# (Claude Code transcripts, Codex session logs) and a fixture repository, runs the report, and compares
# it with expected text. The report reads the real clock, so clock-dependent values are masked in the
# text comparison and checked separately against bounds the fixture knows.
set -u

HERE="$(cd "$(dirname "$0")" && pwd)"
pass_n=0; fail_n=0
pass() { pass_n=$((pass_n + 1)); printf 'ok   - %s\n' "$1"; }
fail() { fail_n=$((fail_n + 1)); printf 'FAIL - %s\n' "$1"; }

work=$(mktemp -d) || work=''
if [ -z "$work" ] || [ ! -d "$work" ]; then
  printf 'FAIL - could not create a temporary directory; refusing to run\n' >&2
  exit 1
fi
trap 'chmod -R u+rwx "$work" 2>/dev/null; rm -rf "$work"' EXIT
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
commit() { tick=$((tick + 1)); printf '%b' "$1" > "$work/msg"; gitc add -A && gitc commit -q --allow-empty -F "$work/msg"; }

# A fixture repository: scripts/ holds the report and its two neighbours. History closes aaaaaaaa,
# closes bbbbbbbb with no story, and records cccccccc twice with different story sets (conflicting).
mkrepo() { # dir
  rm -rf "${work:?}/$1"; mkdir -p "$work/$1/scripts"
  cp "$HERE/live-effort.py" "$HERE/run-analytics.py" "$HERE/ledger-metrics.py" "$work/$1/scripts/"
  (
    cd "$work/$1" || exit 1
    gitc init -q --template= --object-format=sha1 .
    printf '.context/\n' > .gitignore
    commit 'base\n'
    commit 'closed\n\ncycle aaaaaaaa; floor 3 per {docs/superpowers/stories/s1-story.md (level 1)}; hook reminder threshold absent\n'
    commit 'no story\n\ncycle bbbbbbbb; floor 3 per none; hook reminder threshold absent\n'
    commit 'conflict 1\n\ncycle cccccccc; floor 3 per none; hook reminder threshold absent\n'
    commit 'conflict 2\n\ncycle cccccccc; floor 3 per {docs/superpowers/stories/s2-story.md (level 0)}; hook reminder threshold absent\n'
  )
}

# fixture.py: shared helpers; `build` writes the first state, `complete` adds two results.
cat > "$work/fixture.py" <<'FIXTURES'
import datetime, json, os, sys
work, step = sys.argv[1], sys.argv[2]
home = os.path.join(work, "home")
REPO, OTHER = os.path.join(work, "repo"), os.path.join(work, "other")
projects = os.path.join(home, ".claude", "projects", "-fixture")
codex = os.path.join(home, ".codex", "sessions", "2026", "10", "05")
S = {k: "0000000%d-0000-7000-8000-00000000000%d" % (k, k) for k in range(1, 10)}
ask = "review; write .context/codex-reviews/gate-a-spec-ffffffff-pass-3.md"
if step == "build":
    now = datetime.datetime.now(datetime.timezone.utc).replace(microsecond=0)
    with open(os.path.join(work, "t0"), "w") as fh:
        fh.write(now.isoformat())
else:
    now = datetime.datetime.fromisoformat(open(os.path.join(work, "t0")).read())


def ts(dt):
    return dt.strftime("%Y-%m-%dT%H:%M:%S.000Z")


def at(minutes_ago, seconds=0):
    return now - datetime.timedelta(minutes=minutes_ago) + datetime.timedelta(seconds=seconds)


def use(tid, t, text, wd=REPO):
    return {"type": "assistant", "timestamp": ts(t), "message": {"role": "assistant", "content": [
        {"type": "tool_use", "id": tid, "name": "mcp__codex__exec",
         "input": {"instruction": text, "workingDirectory": wd}}]}}


def result(tid, t, sid, summary, success=True):
    env = {"success": success, "sessionId": sid, "status": "completed",
           "output": {"summary": summary, "filesModified": [], "filesCreated": []}}
    return {"type": "user", "timestamp": ts(t), "message": {"role": "user", "content": [
        {"type": "tool_result", "tool_use_id": tid, "content": [{"type": "text", "text": json.dumps(env)}]}]}}


def reply(nonce, p):
    return "gate-a-spec | pass %d | 0 findings | .context/codex-reviews/gate-a-spec-%s-pass-%d.md" % (p, nonce, p)


def clog(name, sid, start, usages, cwd=REPO):
    lines = [{"timestamp": ts(start), "type": "session_meta",
              "payload": {"session_id": sid, "id": sid, "timestamp": ts(start), "cwd": cwd}}]
    for t, i, c, o, r in usages:
        lines.append({"timestamp": ts(t), "type": "event_msg", "payload": {"type": "token_count", "info": {
            "total_token_usage": {"input_tokens": i, "cached_input_tokens": c, "output_tokens": o,
                                  "reasoning_output_tokens": r}}}})
    os.makedirs(codex, exist_ok=True)
    with open(os.path.join(codex, "rollout-%s.jsonl" % name), "w") as fh:
        for o in lines:
            fh.write(json.dumps(o) + "\n")


def write(name, objs, mode="w", raw=()):
    os.makedirs(projects, exist_ok=True)
    with open(os.path.join(projects, name), mode) as fh:
        for l in raw:
            fh.write(l + "\n")
        for o in objs:
            fh.write(json.dumps(o) + "\n")


if step == "build":
    write("s.jsonl", [
        use("toolu_closed", at(100), "x"), result("toolu_closed", at(100, 20), S[1], reply("aaaaaaaa", 1)),
        use("toolu_open1", at(90), "x"), result("toolu_open1", at(90, 100), S[2], reply("ffffffff", 1)),
        use("toolu_open2", at(80), "x"), result("toolu_open2", at(80, 50), S[3], reply("ffffffff", 2)),
        use("toolu_multi", at(70), "x"),
        result("toolu_multi", at(70, 10), S[4], reply("ffffffff", 9) + "\n" + reply("bbbbbbbb", 1)),
        use("toolu_conf", at(65), "x"), result("toolu_conf", at(65, 10), S[8], reply("cccccccc", 1)),
        use("toolu_pending", at(5), ask),
        use("toolu_consult", at(4), "read .context/codex-reviews/gate-a-spec-ffffffff-pass-1.md and advise"),
        use("toolu_future", at(-30), ask),
        use("toolu_failed", at(60), "x"), result("toolu_failed", at(60, 30), S[5], "could not finish", success=False),
        use("toolu_old", at(30 * 60), "x"), result("toolu_old", at(30 * 60, 30), S[9], "could not finish", success=False),
        use("toolu_stale", at(8 * 60), ask),
        use("toolu_other", at(50), "x", wd=OTHER), result("toolu_other", at(50, 10), S[6], reply("99999999", 1)),
    ], raw=('{"tool_use": broken',))
    write("locked.jsonl", [use("toolu_hidden", at(3), ask)])
    if sys.argv[3] == "with-codex":
        clog("closed", S[1], at(100, 1), [(at(100, 10), 5, 0, 1, 0)])
        clog("open1", S[2], at(90, 1), [(at(90, 60), 1000, 800, 40, 4)])
        clog("open2", S[3], at(80, 1), [])
        clog("multi", S[4], at(70, 1), [(at(70, 5), 7, 0, 1, 0)])
        clog("failed", S[5], at(60, 1), [(at(60, 20), 3, 0, 1, 0)])
        # a log in the repository's directory that starts after the pending call: never matched to it
        clog("live", "0000000f-0000-7000-8000-00000000000f", at(4, 30), [(at(1), 9999, 0, 99, 9)])
    # what the report must print for freshness: the newest used source timestamp is toolu_consult's start
    with open(os.path.join(work, "newest"), "w") as fh:
        fh.write(at(4).strftime("%Y-%m-%dT%H:%M:%S.000000Z"))
else:  # complete: toolu_pending returns into ffffffff with a measured log; toolu_consult fails
    write("s.jsonl", [result("toolu_pending", at(2), S[7], reply("ffffffff", 3)),
                      result("toolu_consult", at(1), "0000000e-0000-7000-8000-00000000000e", "no", success=False)],
          mode="a")
    clog("pend", S[7], at(5, 1), [(at(3), 50, 0, 5, 1)])
FIXTURES

build() { # with-codex | no-codex
  mkrepo repo
  mkrepo other
  rm -rf "${work:?}/home"; mkdir -p "$work/home"
  python3 "$work/fixture.py" "$work" build "$1" || { printf 'FAIL - fixture builder failed\n'; exit 1; }
}

run() { (cd "$work/$1" && HOME="$work/home" python3 -B scripts/live-effort.py) 2>&1; }
mask() { # times that depend on the real clock; checked separately by `clock`
  sed -E 's/(report produced|newest observed value) [0-9T:.-]+Z/\1 <t>/; s/started [0-9T:.-]+Z/started <t>/g;
          s/(cycle elapsed|pending since invocation) [0-9]+\.[0-9] s/\1 <s>/g'
}
expect() { # name, actual (expected on stdin)
  printf '%s\n' "$2" > "$work/actual"; cat > "$work/expected"
  if diff "$work/expected" "$work/actual" > "$work/diff"; then pass "$1"; else fail "$1"; sed 's/^/    /' "$work/diff"; fi
}
snapshot() { (cd "$1" && find . -type f -exec cksum {} + 2>/dev/null | sort); }
locked=0

# ---- 1. the first state -----------------------------------------------------------------------------
build with-codex
# An unreadable transcript, counted under skipped sources. root reads a mode-000 file anyway, so there
# the file is removed instead and the expectation drops the count.
if [ "$(id -u)" -ne 0 ]; then chmod 000 "$work/home/.claude/projects/-fixture/locked.jsonl"; locked=1
else rm -f "$work/home/.claude/projects/-fixture/locked.jsonl"; fi
before_home=$(snapshot "$work/home"); before_repo=$(snapshot "$work/repo")
out=$(run repo); st=$?
[ "$st" -eq 0 ] && pass "main run exits 0" || fail "main run exit $st: $out"
[ "$before_home" = "$(snapshot "$work/home")" ] && pass "sources unchanged" || fail "sources changed"
[ "$before_repo" = "$(snapshot "$work/repo")" ] && pass "repository unchanged (no store, no bytecode)" || fail "repository changed"
[ ! -e "$work/repo/.context/telemetry" ] && pass "no .context/telemetry written" || fail "telemetry written"

skipped='skipped sources: malformed line 1, unreadable file 1'
[ "$locked" -eq 1 ] || skipped='skipped sources: malformed line 1'
expect "report" "$(printf '%s\n' "$out" | sed '/^== What this report cannot see/,$d' | mask)" <<EOF
live-effort — read-only report over review cycles that have not closed
report produced <t>
newest observed value <t>  (timestamps later than the report: 1, not used)
sources: transcripts found  codex logs found
$skipped
calls not shown (not in this clone) 1  malformed calls 0  values that failed their checks 0
history searched: git log --all
a gate call is not a review pass: this report counts calls and does not count or validate passes
excluded, closed or contested (cycles / call-nonce pairs): confirmed 1 / 1  no story 1 / 1  conflicting 1 / 1

== Open cycles (no closing record found; calls counted once per nonce they name)
cycle ffffffff  calls 3  cycle elapsed <s>  summed call duration 160.0 s (? 0 of 3)
  tokens_in 1007 (? 1 of 3)  tokens_cached 800 (? 1 of 3)  tokens_out 41 (? 1 of 3)  tokens_reasoning 4 (? 1 of 3)

== Unattributed calls (pending, or no cycle; started in the last 24 hours)
pending (no result observed yet) 3
  calls 3  duration_s ? (? 3 of 3)  tokens_in ? (? 3 of 3)  tokens_cached ? (? 3 of 3)  tokens_out ? (? 3 of 3)  tokens_reasoning ? (? 3 of 3)
  toolu_pending  exec  started <t>  pending since invocation <s>  tokens unknown (not attributable before the result)
  toolu_consult  exec  started <t>  pending since invocation <s>  tokens unknown (not attributable before the result)
  toolu_future  exec  started <t>  pending since invocation ? (clock skew)  tokens unknown (not attributable before the result)
completed 0
failed 1
  calls 1  duration_s 30.0 (? 0 of 1)  tokens_in 3 (? 0 of 1)  tokens_cached 0 (? 0 of 1)  tokens_out 1 (? 0 of 1)  tokens_reasoning 0 (? 0 of 1)
no valid end (no result after 6 h, or an unusable end time) 1
  calls 1  duration_s ? (? 1 of 1)  tokens_in ? (? 1 of 1)  tokens_cached ? (? 1 of 1)  tokens_out ? (? 1 of 1)  tokens_reasoning ? (? 1 of 1)
EOF

# The masked values, checked against what the fixture knows: the exact newest source timestamp, a
# report time after it, and elapsed times inside a bound around their fixture offsets.
clock() { # output
  printf '%s\n' "$1" | python3 -c '
import datetime, re, sys
out, newest = sys.stdin.read(), open(sys.argv[1]).read()
t = lambda s: datetime.datetime.strptime(s, "%Y-%m-%dT%H:%M:%S.%fZ")
prod = t(re.search(r"^report produced (\S+)", out, re.M).group(1))
seen = re.search(r"^newest observed value (\S+)", out, re.M).group(1)
el = float(re.search(r"cycle ffffffff .*cycle elapsed ([0-9.]+) s", out).group(1))
pe = float(re.search(r"toolu_pending .*pending since invocation ([0-9.]+) s", out).group(1))
ok = seen == newest and prod > t(newest) and 90 * 60 <= el <= 90 * 60 + 300 and 5 * 60 <= pe <= 5 * 60 + 300
print("ok" if ok else "bad: newest %s vs %s, elapsed %s, pending %s" % (seen, newest, el, pe))' "$work/newest"
}
c=$(clock "$out")
[ "$c" = ok ] && pass "clock: newest value exact, report time later, elapsed and pending within bounds" || fail "clock: $c"

printf '%s\n' "$out" | grep -q '^== What this report cannot see' && printf '%s\n' "$out" | grep -q 'orchestrating Claude session' \
  && pass "limits are printed" || fail "limits missing"

# ---- 2. completion: the pending call returns, the consultation fails -----------------------------
python3 "$work/fixture.py" "$work" complete || { printf 'FAIL - fixture completion failed\n'; exit 1; }
out=$(run repo)
expect "after completion: pending gone, counted once, failed moves" "$(printf '%s\n' "$out" | mask | sed -n '/^== Open cycles/,/^== What this report cannot see/p' | sed '$d')" <<'EOF'
== Open cycles (no closing record found; calls counted once per nonce they name)
cycle ffffffff  calls 4  cycle elapsed <s>  summed call duration 340.0 s (? 0 of 4)
  tokens_in 1057 (? 1 of 4)  tokens_cached 800 (? 1 of 4)  tokens_out 46 (? 1 of 4)  tokens_reasoning 5 (? 1 of 4)

== Unattributed calls (pending, or no cycle; started in the last 24 hours)
pending (no result observed yet) 1
  calls 1  duration_s ? (? 1 of 1)  tokens_in ? (? 1 of 1)  tokens_cached ? (? 1 of 1)  tokens_out ? (? 1 of 1)  tokens_reasoning ? (? 1 of 1)
  toolu_future  exec  started <t>  pending since invocation ? (clock skew)  tokens unknown (not attributable before the result)
completed 0
failed 2
  calls 2  duration_s 210.0 (? 0 of 2)  tokens_in 3 (? 1 of 2)  tokens_cached 0 (? 1 of 2)  tokens_out 1 (? 1 of 2)  tokens_reasoning 0 (? 1 of 2)
no valid end (no result after 6 h, or an unusable end time) 1
  calls 1  duration_s ? (? 1 of 1)  tokens_in ? (? 1 of 1)  tokens_cached ? (? 1 of 1)  tokens_out ? (? 1 of 1)  tokens_reasoning ? (? 1 of 1)
EOF

# ---- 3. reconciliation with run-analytics (fresh store, same sources) ---------------------------------
ra=$( (cd "$work/repo" && HOME="$work/home" python3 -B scripts/run-analytics.py) 2>&1 )
rm -rf "$work/repo/.context"
ra_t=$(printf '%s\n' "$ra" | grep '^  cycle ffffffff ' | sed -E 's/^  cycle ffffffff  calls ([0-9]+)  passes [^ ]+  duration_s (.*)$/\1 \2/')
le_t=$(printf '%s\n' "$out" | awk '/^cycle ffffffff /{d=$0; getline t
  n=d; sub(/^cycle ffffffff  calls /,"",n); sub(/ .*/,"",n)
  sub(/.*summed call duration /,"",d); sub(/ s \(/," (",d)
  print n " " d "  " substr(t,3)}')
[ -n "$ra_t" ] && [ "$ra_t" = "$le_t" ] && pass "reconciliation: calls, duration and tokens equal run-analytics' for the open cycle" \
  || fail "reconciliation: run-analytics '$ra_t' vs live '$le_t'"

# ---- 4. no Codex root, then no sources at all -------------------------------------------------------
build no-codex
out=$(run repo)
printf '%s\n' "$out" | grep -qx 'sources: transcripts found  codex logs not found' && pass "a missing Codex root reads 'not found'" \
  || fail "missing root not shown: $(printf '%s\n' "$out" | grep '^sources')"
rm -rf "${work:?}/home"; mkdir -p "$work/home"
out=$(run repo)
printf '%s\n' "$out" | grep -qx 'newest observed value none observed' && pass "no sources: newest value 'none observed'" \
  || fail "no sources: $(printf '%s\n' "$out" | grep '^newest')"

if [ "$fail_n" -eq 0 ]; then printf 'all passed (%s assertions)\n' "$pass_n"; else
  printf '%s passed, %s FAILED\n' "$pass_n" "$fail_n"; exit 1; fi
`````

- [ ] **Step 2: It fails without the report.** Run `sh scripts/live-effort.test.sh; echo "rc=$?"`. Expected: `rc=1`, because `mkrepo` cannot copy the missing `live-effort.py` and every fixture run fails. `shellcheck --shell=sh --exclude=SC2015 scripts/live-effort.test.sh` exits 0.

---

### Task 2: The report (green)

- [ ] **Step 1: Create `scripts/live-effort.py`** with exactly this content (not executable, like the other reports):

`````python
#!/usr/bin/env python3
"""Show the effort of review cycles that have not closed, and of gate calls still pending.

Spec: docs/superpowers/specs/2026-10-05-live-effort-counters-design.md
Usage: python3 -B scripts/live-effort.py

Read-only: it writes nothing, takes no lock and leaves run-analytics' store alone. It measures with
run-analytics' own functions, so a completed call counts here exactly as run-analytics counts it when
both measure it fresh from the same sources. Standard library only; Python 3.8 or later; git 2.36 or
later.
"""
import datetime
import importlib.util
import os
import re
import sys

WINDOW_HOURS = 24  # look-back for effort with no cycle (spec §2)

LIMITS = """== What this report cannot see
- Calls from removed worktrees, other clones or other machines; transcripts deleted by Claude Code's cleanup.
- Calls made outside Claude Code, and calls through tool names mapped in .context/codex-gate.tools.
- Tokens of a shared (resumed) Codex session: left unknown, as run-analytics does.
- Whether a pending call is still running: "pending" means no result has been observed yet.
- A pending call's tokens and cycle: unknown until its result names its sessions and slots.
- Missing sub-agent logs: a token sum covers the Codex files found on this run and can be short with no unknown counted.
- The orchestrating Claude session's own tokens per gate call.
- Whether an open cycle is still running: it may be abandoned, or closed in history this clone lacks.
- Story attribution for open cycles, and cost in money.
- Expected differences from run-analytics: its store keeps what it measured first (later logs or a
  resume do not change it) and keeps calls whose sources were deleted; it covers every cycle class and
  all stored history; a call with no result after 6 h is stored there as unfinished."""


def load(name, filename):
    sys.dont_write_bytecode = True
    spec = importlib.util.spec_from_file_location(name, os.path.join(os.path.dirname(os.path.abspath(__file__)), filename))
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    return mod


ra = load("run_analytics", "run-analytics.py")


def die(msg):
    sys.stderr.buffer.write(("live-effort: %s\n" % ra.shown(msg)).encode("utf-8", "backslashreplace"))
    sys.stderr.flush()
    sys.exit(1)


def span(seconds):
    """A duration for display, or the clock-skew unknown when it would be negative."""
    if seconds is None:
        return "?"
    if seconds < 0:
        return "? (clock skew)"
    return "%.1f s" % seconds


def main(argv):
    if len(argv) > 1:
        die("takes no arguments")
    cwd = os.getcwd()
    rc, out = ra.git(("--version",), cwd)
    m = re.search(rb"(\d+)\.(\d+)", out) if rc == 0 else None
    if not m or (int(m.group(1)), int(m.group(2))) < (2, 36):
        die("git 2.36 or later is required")
    mine = ra.common_dir(cwd)
    if mine is None:
        die("not a git repository")

    problems, invalid = {}, [0]
    lm = ra.load_ledger_parser(os.path.dirname(os.path.abspath(__file__)))
    calls = ra.scan_transcripts(problems)
    sid_users = {}
    for c in calls.values():
        for v in ra.call_session_ids(ra.envelope(c["result"])) + ra.call_session_ids(c["input"]):
            sid_users.setdefault(v, set()).add(c["id"])
    sessions = ra.scan_codex(problems, set(sid_users))
    # The reference time is taken after the sources were read: a scan can take minutes, and a call
    # that started during it is not in the future.
    now = datetime.datetime.now(datetime.timezone.utc)

    records, pending = [], []
    not_here = malformed = 0
    member_cache = {}
    for c in calls.values():
        wd = c["input"].get("workingDirectory")
        if not isinstance(wd, str) or not os.path.isabs(wd) or not os.path.isdir(wd):
            not_here += 1
            continue
        if wd not in member_cache:
            member_cache[wd] = ra.common_dir(wd) == mine
        if not member_cache[wd]:
            not_here += 1
            continue
        rec = ra.build_record(c, sessions, sid_users, now, invalid)
        if rec is None:
            malformed += 1
        elif rec == "pending":
            pending.append((ra.parse_ts(c["started"]), c["tool"], c["id"]))
        else:
            records.append(rec)

    # Freshness: the newest source timestamp this report used, ignoring any later than now.
    seen, future = [], 0
    for t in [p[0] for p in pending] + [ra.parse_ts(r["started"]) for r in records] + \
             [ra.parse_ts(r["ended"]) for r in records if r["ended"]] + \
             [f["last_ts"] for r in records for s in r["session_ids"] for f in sessions.get(s, ()) if f["last_ts"]]:
        if t is None:
            continue
        if t > now:
            future += 1
        else:
            seen.append(t)

    provs, others = ra.cycles_from_history(cwd, lm)
    rc, out = ra.git(("rev-parse", "--is-shallow-repository"), cwd)
    shallow = out.strip() == b"true"
    open_cycles, excluded, unattr = {}, {"confirmed": {}, "no story": {}, "conflicting": {}}, []
    cutoff = now - datetime.timedelta(hours=WINDOW_HOURS)
    for r in records:
        nonces = ra.nonces_of(r) if r["slots"] else []
        if not nonces:
            if ra.parse_ts(r["started"]) >= cutoff:
                unattr.append(r)
            continue
        for n in nonces:  # run-analytics' rule: a call naming several nonces counts under each
            cls = ra.classify(n, provs, others)[0]
            (open_cycles if cls == "open" else excluded[cls]).setdefault(n, []).append(r)

    roots = (("transcripts", os.path.join(os.path.expanduser("~"), ".claude", "projects")),
             ("codex logs", os.path.join(os.path.expanduser("~"), ".codex", "sessions")))
    lines = ["live-effort — read-only report over review cycles that have not closed",
             "report produced %s" % ra.iso(now),
             "newest observed value %s%s" % (ra.iso(max(seen)) if seen else "none observed",
                                              "  (timestamps later than the report: %d, not used)" % future
                                              if future else ""),
             "sources: %s" % "  ".join("%s %s" % (n, "found" if os.path.isdir(p) else "not found") for n, p in roots),
             "skipped sources: %s" % (", ".join("%s %d" % (ra.shown(k), v) for k, v in sorted(problems.items()))
                                      or "none"),
             "calls not shown (not in this clone) %d  malformed calls %d  values that failed their checks %d" % (
                 not_here, malformed, invalid[0]),
             "history searched: git log --all%s" % ("  (shallow: closing commits may be missing)" if shallow else ""),
             "a gate call is not a review pass: this report counts calls and does not count or validate passes",
             "excluded, closed or contested (cycles / call-nonce pairs): %s" % "  ".join(
                 "%s %d / %d" % (k, len(v), sum(map(len, v.values()))) for k, v in excluded.items()),
             "", "== Open cycles (no closing record found; calls counted once per nonce they name)"]
    if not open_cycles:
        lines.append("none")
    for n in sorted(open_cycles):
        recs = open_cycles[n]
        first = min(ra.parse_ts(r["started"]) for r in recs)
        lines.append("cycle %s  calls %d  cycle elapsed %s  summed call duration %s" % (
            n, len(recs), span((now - first).total_seconds()),
            ra.total([r["duration_s"] for r in recs], lambda x: "%.1f s" % x)))
        lines.append("  " + "  ".join("%s %s" % (f, ra.total([r[f] for r in recs], str)) for f in ra.TOKEN_FIELDS))
    lines += ["", "== Unattributed calls (pending, or no cycle; started in the last %d hours)" % WINDOW_HOURS]
    lines.append("pending (no result observed yet) %d" % len(pending))
    if pending:
        lines.append("  calls %d  duration_s ? (? %d of %d)  %s" % (len(pending), len(pending), len(pending), "  ".join(
            "%s ? (? %d of %d)" % (f, len(pending), len(pending)) for f in ra.TOKEN_FIELDS)))
    for started, tool, cid in sorted(pending, key=lambda p: p[0]):
        lines.append("  %s  %s  started %s  pending since invocation %s  tokens unknown "
                     "(not attributable before the result)" % (ra.shown(cid), tool, ra.iso(started),
                                                              span((now - started).total_seconds())))
    for label, pick in (("completed", lambda r: r["ended"] and r["success"] is not False),
                        ("failed", lambda r: r["ended"] and r["success"] is False),
                        ("no valid end (no result after 6 h, or an unusable end time)", lambda r: not r["ended"])):
        group = [r for r in unattr if pick(r)]
        lines.append("%s %d" % (label, len(group)))
        if group:  # the same totals as a cycle, without pass numbers: a call is not a pass
            lines.append("  " + re.sub(r"  passes \S+", "", ra.group_line(group)))
    lines += ["", LIMITS]
    sys.stdout.buffer.write(("\n".join(lines) + "\n").encode("utf-8", "backslashreplace"))
    sys.stdout.flush()
    return 0


if __name__ == "__main__":
    if hasattr(sys, "set_int_max_str_digits"):
        sys.set_int_max_str_digits(0)
    try:
        sys.exit(main(sys.argv))
    except OSError as e:
        die("filesystem error: %s" % (e.strerror or type(e).__name__))
`````

- [ ] **Step 2: Green.**
  - Run `sh scripts/live-effort.test.sh; echo "rc=$?"`. Expected: `all passed (11 assertions)`, `rc=0`.
  - Run `dash scripts/live-effort.test.sh` too. Expected: `all passed (11 assertions)`.
- [ ] **Step 3: One real run** (Review Focus 1). Run `python3 -B scripts/live-effort.py > <scratch>/real.txt; echo "rc=$?"`. Expected:
  - `rc=0`;
  - the sections `== Open cycles`, `== Unattributed calls` and `== What this report cannot see`;
  - `git status --porcelain --untracked-files=no` still empty.

---

### Task 3: Battery, docs and the split record

- [ ] **Step 1: Apply the edit script**, saved outside the repository and run from the repository root:

`````python
# Wires scripts/live-effort.{py,test.sh} into the battery and the docs, and records the part-4 split.
# Every replacement must match exactly once, or the script stops before writing anything.
import sys

def rep(s, old, new, where):
    n = s.count(old)
    if n != 1:
        sys.exit(f"STOP: {where}: expected exactly 1 match, found {n}: {old[:70]!r}")
    return s.replace(old, new)

edits = {
 "AGENTS.md": [
  ("scripts/spec-delta.test.sh        # its regression suite — fixture repo, expected text\n",
   "scripts/spec-delta.test.sh        # its regression suite — fixture repo, expected text\n"
   "scripts/live-effort.py            # effort of review cycles not yet closed (vision step 2c, part 4a)\n"
   "scripts/live-effort.test.sh       # its regression suite — fixture home + repos, expected text\n"),
  ("""`scripts/check-version-bump.{sh,test.sh}`), plus four Python reports with their suites:
`scripts/ledger-metrics.{py,test.sh}`, `scripts/loop-usefulness.{py,test.sh}` and
`scripts/spec-delta.{py,test.sh}` (read-only),""",
   """`scripts/check-version-bump.{sh,test.sh}`), plus five Python reports with their suites:
`scripts/ledger-metrics.{py,test.sh}`, `scripts/loop-usefulness.{py,test.sh}`,
`scripts/spec-delta.{py,test.sh}` and `scripts/live-effort.{py,test.sh}` (read-only),"""),
  ("| typecheck | n/a — no typed sources (shell, four untyped Python reports, markdown) |",
   "| typecheck | n/a — no typed sources (shell, five untyped Python reports, markdown) |"),
  ("shellcheck --shell=sh --exclude=SC2015 scripts/spec-delta.test.sh && HOOK_SH=sh",
   "shellcheck --shell=sh --exclude=SC2015 scripts/spec-delta.test.sh && shellcheck --shell=sh --exclude=SC2015 scripts/live-effort.test.sh && HOOK_SH=sh"),
  ("sh scripts/spec-delta.test.sh && claude plugin validate . --strict",
   "sh scripts/spec-delta.test.sh && sh scripts/live-effort.test.sh && claude plugin validate . --strict"),
  ("shellcheck --shell=sh --exclude=SC2015 scripts/spec-delta.test.sh` |",
   "shellcheck --shell=sh --exclude=SC2015 scripts/spec-delta.test.sh && shellcheck --shell=sh --exclude=SC2015 scripts/live-effort.test.sh` |"),
  ("""system interpreter, not a pinned tool. `scripts/run-analytics.py`, `scripts/loop-usefulness.py` and
`scripts/spec-delta.py` also need git 2.36 or later and check for it.""",
   """system interpreter, not a pinned tool. `scripts/run-analytics.py`, `scripts/loop-usefulness.py`,
`scripts/spec-delta.py` and `scripts/live-effort.py` also need git 2.36 or later and check for it."""),
 ],
 ".github/workflows/ci.yml": [
  ("      # The hook, the two checkers, the four Python reports and their seven suites are",
   "      # The hook, the two checkers, the five Python reports and their eight suites are"),
  ("""          docker run --rm -v "$PWD:/mnt" -w /mnt koalaman/shellcheck:v0.11.0 \\
            --shell=sh --exclude=SC2015 scripts/spec-delta.test.sh
""", """          docker run --rm -v "$PWD:/mnt" -w /mnt koalaman/shellcheck:v0.11.0 \\
            --shell=sh --exclude=SC2015 scripts/spec-delta.test.sh
          # The live-effort suite (vision step 2c, part 4a), linted the same way.
          docker run --rm -v "$PWD:/mnt" -w /mnt koalaman/shellcheck:v0.11.0 \\
            --shell=sh --exclude=SC2015 scripts/live-effort.test.sh
"""),
  ("""          sh scripts/spec-delta.test.sh
""", """          sh scripts/spec-delta.test.sh
          sh scripts/live-effort.test.sh
"""),
 ],
 "README.md": [
  ("both checkers' regression suites, the four reports' suites, and",
   "both checkers' regression suites, the five reports' suites, and"),
  ("""ambiguity. It does not claim the cycle reviewed exactly that file, and it informs without
obliging anything. It writes nothing.
""", """ambiguity. It does not claim the cycle reviewed exactly that file, and it informs without
obliging anything. It writes nothing.

`python3 -B scripts/live-effort.py` shows the effort of review cycles that have not closed yet: calls,
time and tokens per open cycle, plus gate calls still waiting for their result, with unknown values
counted rather than hidden. Re-run it to refresh. It counts calls, not review passes, sets no
threshold, and changes no gate rule. It writes nothing, and it reads every transcript, so a run can
take a minute or two.
"""),
 ],
 "docs/superpowers/stories/2026-10-02-telemetry-and-review-loop-usefulness-story.md": [
  ("""(3) spec-delta capture; (4) live cost counters and the minimum-cost INCOMPLETE signal. Part 4
changes gate pass validity and needs its own profile, risk high.""",
   """(3) spec-delta capture; (4) live cost counters and the minimum-cost INCOMPLETE signal. Part 4
changes gate pass validity and needs its own profile, risk high.

**Part 4 split 2026-10-05 (Daniel).** Measurement first: part 4a, live effort counters
(`docs/superpowers/stories/2026-10-05-live-effort-counters-story.md`, risk standard), changes no
pass validity. Part 4b, the minimum-cost INCOMPLETE signal, comes later, on calibrated data; it keeps
the risk-high profile above and the central question in §5."""),
 ],
 "todos.md": [
  ("""      evidence of an incomplete one. Whether part 4 splits is Daniel's decision.""",
   """      evidence of an incomplete one. Whether part 4 splits is Daniel's decision.
      **2026-10-05 (Daniel): split.** Part 4a, live effort counters
      (`scripts/live-effort.py`), measures only. Part 4b, the minimum-cost INCOMPLETE signal, waits
      for calibration data and keeps its risk-high profile."""),
 ],
}
out = {}
for path, reps in edits.items():
    s = open(path).read()
    for old, new in reps:
        s = rep(s, old, new, path)
    out[path] = s
for path, s in out.items():
    open(path, "w").write(s)
print("edited:", ", ".join(out))
`````

Expected: `edited: AGENTS.md, .github/workflows/ci.yml, README.md, docs/superpowers/stories/2026-10-02-telemetry-and-review-loop-usefulness-story.md, todos.md`.

- [ ] **Step 2: Statements this change falsifies.**
  - Run `grep -rnE "four (Python )?reports|seven suites|four untyped" --include='*.md' --include='*.yml' . | grep -vE 'docs/superpowers/|source-files/|\.context/'`. Expected: no hit.
  - Also read the AGENTS.md architecture tree, which must list both new files.
- [ ] **Step 3: The quality row, verbatim.** Run it in the background, with no timeout under 30 minutes: `sh -c '<row>' > <scratch>/q.log 2>&1; echo "quality=$?"`. Expected: `quality=0`, and `all passed (11 assertions)` for the new suite.

No commit before Task 4.

---

### Task 4: Evidence, Gate B, close

- [ ] **Step 1: Base check.** Run `git fetch origin; git merge-base --is-ancestor origin/main HEAD; echo "anc=$?"`. Expected: `anc=0`.
- [ ] **Step 2: Stage and snapshot.**
  - Stage the seven paths: the two new scripts and the five edited files.
  - Run `git diff --cached --name-only`; exactly those seven paths must be listed.
  - Then, as its own one-line tool call: `git commit -m 'WIP: live effort counters'`.
- [ ] **Step 3: Evidence run, at the WIP head**, re-run before every Gate-B call:
  - the quality row, exit 0;
  - the suite under dash, its own exit status;
  - **Counterfactual:** in a temporary copy of the candidate tree, without `scripts/live-effort.py`, the suite exits 1.
  - **Mutations:** in a temporary copy, apply each of ruling 6's eight mutations with the script below, one at a time, starting from the candidate file each time. Each must fail at least the cases ruling 6 names for it.
  - **Real run:** Task 2 Step 3 on the WIP head, with the clean check.
  - **Spec delta:** `python3 -B scripts/spec-delta.py --base "$B" --plan docs/superpowers/plans/2026-10-05-live-effort-counters.md --baseline 13e0a50:docs/superpowers/specs/2026-10-05-live-effort-counters-design.md --baseline <plan-close>:docs/superpowers/plans/2026-10-05-live-effort-counters.md "$H"`.

`mut.py` (save outside the repository; `python3 mut.py <copy>/scripts/live-effort.py <name>`):

`````python
import sys
p, k = sys.argv[1], sys.argv[2]
s = open(p).read()
M = {
 "nonce": ("""        elif rec == "pending":
            pending.append((ra.parse_ts(c["started"]), c["tool"], c["id"]))""",
           """        elif rec == "pending":
            ns = sorted(set(re.findall(r"gate-a-spec-([a-z0-9]{8,16})-pass", str(c["input"]))))
            if len(ns) == 1:
                r2 = ra.build_record(dict(c, result=(c["started"], "")), sessions, sid_users, now, invalid)
                r2["slots"] = ["gate-a-spec-%s-pass-1" % ns[0]]; records.append(r2)
            else:
                pending.append((ra.parse_ts(c["started"]), c["tool"], c["id"]))"""),
 "population": ("""            if ra.parse_ts(r["started"]) >= cutoff:
                unattr.append(r)""", """            pass"""),
 "logmatch": ("""        elif rec == "pending":
            pending.append((ra.parse_ts(c["started"]), c["tool"], c["id"]))""",
              """        elif rec == "pending":
            st0 = ra.parse_ts(c["started"])
            for d, _x, fs in os.walk(os.path.expanduser("~/.codex/sessions")):
                for f in fs:
                    ls = ra.read_lines(os.path.join(d, f), {})
                    meta = ls[0].get("payload", {}) if ls else {}
                    if os.path.realpath(meta.get("cwd", "")) == os.path.realpath(wd) and \\
                            (ra.parse_ts(meta.get("timestamp")) or st0) >= st0:
                        sid = meta.get("session_id")
                        sid_users.setdefault(sid, set()).add(c["id"])
                        records.append(ra.build_record(dict(c, result=(c["started"], json.dumps(
                            {"success": True, "sessionId": sid, "output": {"summary": ""}}))),
                            ra.scan_codex({}, {sid}), sid_users, now, invalid))
            pending.append((st0, c["tool"], c["id"]))"""),
 "problems": ("""(", ".join("%s %d" % (ra.shown(k), v) for k, v in sorted(problems.items()))
                                      or "none")""", """("none")"""),
 "conflicting": ("""(open_cycles if cls == "open" else excluded[cls])""", """(open_cycles if cls in ("open", "conflicting") else excluded[cls])"""),
 "cutoff": ("""            if ra.parse_ts(r["started"]) >= cutoff:""", """            if True:"""),
 "newest": ("""ra.iso(max(seen)) if seen else "none observed\"""", """ra.iso(now) if seen else "none observed\""""),
 "spans": ("""    return "%.1f s" % seconds""", """    return "0.0 s\""""),
}
old, new = M[k]
assert s.count(old) == 1, k
s = s.replace(old, new)
if k == "logmatch":
    s = s.replace("import re\n", "import re\nimport json\n", 1)
open(p, "w").write(s)
`````

Evidence entry:

```
Evidence — docs/superpowers/stories/2026-10-05-live-effort-counters-story.md
Battery: AGENTS.md quality row, exit 0 at <headSha>; live-effort suite 11/11 under sh and dash.
Check (counterfactual): without scripts/live-effort.py the suite exits 1; each of the eight mutations
in the plan's ruling 6 fails its named cases (re-run at <headSha>). Real run on this repository:
exit 0, three sections, tree clean.
```

- [ ] **Step 4: Gate B.** Follow `.claude/review-gates.md`:
  - Draw a nonce; the floor is 3 (story level 1).
  - Check `mcp__codex__health` first.
  - Use one `reviewType: full` call per pass. Each branch writes only its own slot.
  - Each call carries the story path, the evidence entry, the rulings, the spec-delta report and the standing lens: the report and suite counts, the CI comment and the README statement.
  - After fixes: amend the WIP, re-run the evidence, re-review.
- [ ] **Step 5: Close, PR, merge.** When the closure ordering allows it:
  - amend with the real message, the evidence entry, provenance, curve and logical-pass prose;
  - push and open a PR that lists every cycle record;
  - run `/dev-workflow:process-pr-review`;
  - squash-merge when CI is green and every claim is answered, carrying every record into the squash body (Daniel, 2026-10-04);
  - then run run-analytics, archive `.context/`, and remove the worktree.

## Self-review (2026-10-05)

- **Spec coverage:**
  - §0 → the Global Constraints and Task 3's split record.
  - §1 → `live-effort.py`'s pending handling (no cycle, no tokens, membership rule).
  - §2 → the report's header, populations, open-cycle block, unattributed section, skew handling and limits.
  - §3 → reuse through `ra.*` and the reconciliation case.
  - §4 → no options; `-B`; git version check.
  - §5 → the suite.
  - §6 → nothing outside the file map.
- **Story criteria:**
  - AC-1 → the pending lines and the open-cycle block.
  - AC-2 → the three named times and the "not a review pass" line.
  - AC-3 → the two timestamps and the `X (? n of m)` totals.
  - AC-4 → the reconciliation case.
  - AC-5 → the Global Constraints.
  - AC-6 → the limits block and the source lines.
- **Spec §5 cases not run by name:**
  - "completion" and "pending to failed" are the `after completion` case;
  - "pending to expired" is static (ruling 7);
  - the read-only case checks HOME and the repository by checksum;
  - "another clone" is the not-shown count in the report text;
  - "sources" is the skipped-sources line (malformed and unreadable) plus the two root cases.
