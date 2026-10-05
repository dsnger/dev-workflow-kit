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
        # a closed-cycle call that ends after everything shown and resumes toolu_open1's Codex session,
        # whose log then runs later still: neither the call nor the shared log may set the freshness value
        use("toolu_late", at(3), "x"), result("toolu_late", at(3, 30), S[2], reply("aaaaaaaa", 2)),
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
        clog("open1", S[2], at(90, 1), [(at(90, 60), 1000, 800, 40, 4), (at(2, 40), 1500, 900, 60, 6)])
        clog("open2", S[3], at(80, 1), [])
        clog("multi", S[4], at(70, 1), [(at(70, 5), 7, 3, 1, 0)])
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
date -u +%s > "$work/t1"  # wall clock after the run: the upper bound for the elapsed checks
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
excluded, closed or contested (cycles / call-nonce pairs): confirmed 1 / 2  no story 1 / 1  conflicting 1 / 1

== Open cycles (no closing record found; calls counted once per nonce they name)
cycle ffffffff  calls 3  cycle elapsed <s>  summed call duration 160.0 s (? 0 of 3)
  tokens_in 7 (? 2 of 3)  tokens_cached 3 (? 2 of 3)  tokens_out 1 (? 2 of 3)  tokens_reasoning 0 (? 2 of 3)

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
t0 = datetime.datetime.fromisoformat(open(sys.argv[2]).read()).timestamp()
slack = int(open(sys.argv[3]).read()) - t0 + 2  # seconds between fixture time and the end of the run
t = lambda s: datetime.datetime.strptime(s, "%Y-%m-%dT%H:%M:%S.%fZ")
prod = t(re.search(r"^report produced (\S+)", out, re.M).group(1))
seen = re.search(r"^newest observed value (\S+)", out, re.M).group(1)
el = float(re.search(r"cycle ffffffff .*cycle elapsed ([0-9.]+) s", out).group(1))
pe = float(re.search(r"toolu_pending .*pending since invocation ([0-9.]+) s", out).group(1))
ok = seen == newest and prod > t(newest) and 90 * 60 <= el <= 90 * 60 + slack and 5 * 60 <= pe <= 5 * 60 + slack
print("ok" if ok else "bad: newest %s vs %s, elapsed %s, pending %s, slack %s" % (seen, newest, el, pe, slack))' \
    "$work/newest" "$work/t0" "$work/t1"
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
  tokens_in 57 (? 2 of 4)  tokens_cached 3 (? 2 of 4)  tokens_out 6 (? 2 of 4)  tokens_reasoning 1 (? 2 of 4)

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
