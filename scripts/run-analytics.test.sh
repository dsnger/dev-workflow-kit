#!/bin/sh
# Regression suite for run-analytics.py.
#
# Spec: docs/superpowers/specs/2026-10-02-run-analytics-design.md §7. Each case builds a fixture
# HOME (Claude Code transcripts, Codex session logs) and a fixture repository with fixed commit
# dates, runs the collector, and compares the store and the report with expected text.
set -u

HERE="$(cd "$(dirname "$0")" && pwd)"
SCRIPT="$HERE/run-analytics.py"
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
commit() { tick=$((tick + 1)); printf '%b' "$1" > "$work/msg"; gitc add -A && gitc commit -q --allow-empty -F "$work/msg"; }

# A fixture repository: scripts/ holds the tool and its parser; history holds cycle records.
mkrepo() { # dir
  rm -rf "${work:?}/$1"; mkdir -p "$work/$1/scripts"
  cp "$SCRIPT" "$LEDGER" "$work/$1/scripts/"
  (
    cd "$work/$1" || exit 1
    gitc init -q --template= --object-format=sha1 .
    printf '.context/\n' > .gitignore
    commit 'base\n'
    commit 'confirmed\n\ncycle aaaaaaaa; floor 3 per {docs/superpowers/stories/s1-story.md (level 1)}; hook reminder threshold absent\ncycle aaaaaaaa; Gate B (passes 1-2, codex): Findings 1,0. Blockers 0,0. Majors 0,0.\n'
    commit 'no story\n\ncycle bbbbbbbb; floor 3 per none; hook reminder threshold absent\n'
    commit 'conflict 1\n\ncycle cccccccc; floor 3 per none; hook reminder threshold absent\n'
    commit 'conflict 2\n\ncycle cccccccc; floor 3 per {docs/superpowers/stories/s2-story.md (level 0)}; hook reminder threshold absent\n'
    commit 'two kinds\n\ncycle dddddddd; floor 3 per none; hook reminder threshold absent\ncycle dddddddd; Gate-A spec (passes 1, codex): Findings 0. Blockers 0. Majors 0.\ncycle dddddddd; Gate B (passes 1, codex): Findings 0. Blockers 0. Majors 0.\n'
    commit 'open curve only\n\ncycle eeeeeeee; Gate B (passes 1, codex): Findings 2. Blockers 0. Majors 1.\n'
  )
}

# run DIR: the collector from DIR with the fixture HOME; stdout+stderr, status preserved.
raw() { (cd "$1" && HOME="$work/home" python3 "$work/repo/scripts/run-analytics.py" ${2+"$2"} ${3+"$3"}); }
run() { raw "$@" 2>&1; }
runs() { (cd "$1" && HOME="$work/home" python3 "$2" ${3+"$3"} ${4+"$4"}) 2>&1; }

same() { diff "$work/expected" "$work/actual" > "$work/diff"; }
expect() { # name, actual (expected on stdin)
  printf '%s\n' "$2" > "$work/actual"; cat > "$work/expected"
  if same; then pass "$1"; else fail "$1"; sed 's/^/    /' "$work/diff"; fi
}
snapshot() { (cd "$1" && ls -lAR . && find . -type f -exec cksum {} + | sort); }

build() { # fresh home + repo + worktree + transcripts/logs
  mkrepo repo
  rm -rf "${work:?}/wt"
  (cd "$work/repo" && gitc worktree add -q -b wt "$work/wt" >/dev/null 2>&1)
  mkrepo other
  rm -rf "${work:?}/home"; mkdir -p "$work/home"
  python3 - "$work" <<'FIXTURES' || { printf 'FAIL - fixture builder failed\n'; exit 1; }
import datetime, json, os, sys
work = sys.argv[1]
home = os.path.join(work, "home")
now = datetime.datetime.now(datetime.timezone.utc).replace(microsecond=0)
M = "SECRET-MARKER-7f3a"


def ts(dt):
    return dt.strftime("%Y-%m-%dT%H:%M:%S.000Z")


def at(minutes_ago, seconds=0):
    return now - datetime.timedelta(minutes=minutes_ago) + datetime.timedelta(seconds=seconds)


def use(tid, name, t, inp):
    return {"type": "assistant", "timestamp": ts(t), "message": {"role": "assistant", "content": [
        {"type": "tool_use", "id": tid, "name": name, "input": inp}]}}


def result(tid, t, text):
    return {"type": "user", "timestamp": ts(t), "message": {"role": "user", "content": [
        {"type": "tool_result", "tool_use_id": tid, "content": [{"type": "text", "text": text}]}]}}


def exec_env(sid, summary, success=True):
    return json.dumps({"success": success, "sessionId": sid, "status": "completed",
                       "output": {"summary": summary, "filesModified": [], "filesCreated": []}})


def review_env(review, **sids):
    d = {"success": True, "review": review}
    d.update(sids)
    return json.dumps(d)


REPO = os.path.join(work, "repo")
S = {k: "0000000%d-0000-7000-8000-00000000000%d" % (k, k) for k in range(1, 10)}
inst = lambda extra="": {"instruction": M + " review this; earlier: .context/codex-reviews/gate-a-spec-aaaaaaaa-pass-1.md " + extra,
                         "workingDirectory": REPO}
main = []
sub = []
# 1. exec gate call, two Codex files, two models; also cited earlier slot in its instruction
main += [use("toolu_exec1", "mcp__codex__exec", at(200), inst()),
         result("toolu_exec1", at(200, 100), exec_env(S[1], M + " notes\ngate-a-spec | pass 2 | 3 findings | .context/codex-reviews/gate-a-spec-aaaaaaaa-pass-2.md"))]
sub += [use("toolu_exec1", "mcp__codex__exec", at(200), inst())]  # same call in a second transcript, no result
# 2. full review: two reply lines, spec + quality sessions; quality session has no Codex file
full_inp = {"instruction": M, "whatWasImplemented": M, "baseSha": "x", "workingDirectory": REPO}
main += [use("toolu_full1", "mcp__codex__review", at(190), full_inp),
         result("toolu_full1", at(190, 200), review_env(
             M + "\ngate-b-spec | pass 1 | 0 findings | .context/codex-reviews/gate-b-spec-aaaaaaaa-pass-1.md\n"
                 "gate-b-quality | pass 1 | 1 findings | .context/codex-reviews/gate-b-quality-aaaaaaaa-pass-1.md",
             sessionId="", specSessionId=S[2], qualitySessionId=S[3]))]
# 3/4. no result: one old (interrupted, stored), one young (pending)
main += [use("toolu_old", "mcp__codex__exec", at(600), inst())]
main += [use("toolu_young", "mcp__codex__exec", at(30), inst())]
# 5. non-JSON result
main += [use("toolu_nonjson", "mcp__codex__exec", at(180), inst()), result("toolu_nonjson", at(180, 5), M + " not json")]
# 6. no slot (a failed call)
main += [use("toolu_noslot", "mcp__codex__exec", at(170), inst()),
         result("toolu_noslot", at(170, 50), exec_env(S[4], M + " I could not finish", success=False))]
# 7. health call: ignored
main += [use("toolu_health", "mcp__codex__health", at(160), {"workingDirectory": REPO})]
# 8. resume: r1 then r2 (input carries the session); nonce bbbbbbbb (cycle without a story)
sess2 = [use("toolu_r1", "mcp__codex__exec", at(150), inst()),
         result("toolu_r1", at(150, 60), exec_env(S[5], "gate-a-plan | pass 1 | 2 findings | .context/codex-reviews/gate-a-plan-bbbbbbbb-pass-1.md"))]
# a legacy bare slot: no nonce
main += [use("toolu_bare", "mcp__codex__exec", at(100), inst()),
         result("toolu_bare", at(100, 15), exec_env("0000000c-0000-7000-8000-00000000000c", "gate-a-spec | pass 4 | 0 findings | .context/codex-reviews/gate-a-spec-pass-4.md"))]
sub += [use("toolu_r2", "mcp__codex__exec", at(140), dict(inst(), sessionId=S[5])),
        result("toolu_r2", at(140, 60), exec_env(S[5], "gate-a-plan | pass 2 | 0 findings | .context/codex-reviews/gate-a-plan-bbbbbbbb-pass-2.md"))]
# 10. open cycle (fresh nonce), 16. curve-only nonce (open)
main += [use("toolu_open", "mcp__codex__review", at(130), dict(full_inp, reviewType="spec")),
         result("toolu_open", at(130, 40), review_env("gate-b-spec | pass 1 | 0 findings | .context/codex-reviews/gate-b-spec-ffffffff-pass-1.md", sessionId=S[6]))]
main += [use("toolu_curveonly", "mcp__codex__review", at(125), dict(full_inp, reviewType="quality")),
         result("toolu_curveonly", at(125, 40), review_env("INCOMPLETE | could not write | .context/codex-reviews/gate-b-quality-eeeeeeee-pass-1.md", sessionId=S[7]))]
# 15. conflicting nonces
main += [use("toolu_conf", "mcp__codex__exec", at(120), inst()),
         result("toolu_conf", at(120, 30), exec_env(S[8], "gate-a-spec | pass 1 | 0 findings | .context/codex-reviews/gate-a-spec-cccccccc-pass-1.md"))]
main += [use("toolu_kinds", "mcp__codex__exec", at(115), inst()),
         result("toolu_kinds", at(115, 30), exec_env(S[9], "gate-a-spec | pass 1 | 0 findings | .context/codex-reviews/gate-a-spec-dddddddd-pass-1.md"))]
# 12. removed directory (nonce in history) and 13. another repository: not stored
main += [use("toolu_removed", "mcp__codex__exec", at(110), dict(inst(), workingDirectory=os.path.join(work, "gone"))),
         result("toolu_removed", at(110, 30), exec_env("0000000a-0000-7000-8000-00000000000a", "gate-a-spec | pass 3 | 0 findings | .context/codex-reviews/gate-a-spec-aaaaaaaa-pass-3.md"))]
main += [use("toolu_other", "mcp__codex__exec", at(105), dict(inst(), workingDirectory=os.path.join(work, "other"))),
         result("toolu_other", at(105, 30), exec_env("0000000b-0000-7000-8000-00000000000b", "gate-a-spec | pass 1 | 0 findings | .context/codex-reviews/gate-a-spec-99999999-pass-1.md"))]

projects = os.path.join(home, ".claude", "projects", "-fixture")
os.makedirs(os.path.join(projects, "sess1", "subagents"), exist_ok=True)
with open(os.path.join(projects, "sess1.jsonl"), "w") as fh:
    fh.write("{not json " + M + "\n")
    fh.write(json.dumps([1, 2]) + "\n")
    fh.write('{"mcp__codex__exec": broken ' + M + "\n")
    fh.write(json.dumps(["mcp__codex__exec"]) + "\n")
    fh.write(json.dumps(dict(use("toolu_userside", "mcp__codex__exec", at(99), inst()), type="user")) + "\n")
    fh.write(json.dumps({"type": "assistant", "message": {"content": [{"type": "tool_use", "id": "x", "name": ["mcp__codex__exec"]}]}}) + "\n")
    fh.write(json.dumps({"type": "file-history-snapshot", "snapshot": M}) + "\n")
    for o in main:
        fh.write(json.dumps(o) + "\n")
with open(os.path.join(projects, "sess2.jsonl"), "w") as fh:
    for o in sess2:
        fh.write(json.dumps(o) + "\n")
with open(os.path.join(projects, "sess1", "subagents", "agent-1.jsonl"), "w") as fh:
    for o in sub:
        fh.write(json.dumps(o) + "\n")

codex = os.path.join(home, ".codex", "sessions", "2026", "10", "01")
os.makedirs(codex, exist_ok=True)


def clog(name, sid, meta_t, events, model="gpt-6-astra", extra_lines=()):
    lines = [{"timestamp": ts(meta_t), "type": "session_meta", "payload": {"session_id": sid, "id": name, "timestamp": ts(meta_t), "cwd": REPO, "instructions": M}}]
    lines.append({"timestamp": ts(meta_t), "type": "turn_context", "payload": {"model": model, "cwd": REPO}})
    lines.append({"timestamp": ts(meta_t), "type": "response_item", "payload": {"type": "message", "content": M}})
    for t, inp, cached, out, reas in events:
        lines.append({"timestamp": ts(t), "type": "event_msg", "payload": {"type": "token_count", "info": {"total_token_usage": {
            "input_tokens": inp, "cached_input_tokens": cached, "output_tokens": out, "reasoning_output_tokens": reas, "total_tokens": inp + out}}}})
    with open(os.path.join(codex, "rollout-2026-10-01T00-00-00-%s.jsonl" % name), "w") as fh:
        for o in lines:
            fh.write(json.dumps(o) + "\n")
        for l in extra_lines:
            fh.write(l + "\n")


clog("a1", S[1], at(200, 2), [(at(200, 30), 100, 50, 10, 5), (at(200, 90), 300, 200, 20, 6)])
clog("a2", S[1], at(200, 10), [(at(200, 80), 40, 0, 4, 1)], model="gpt-6-mini")
clog("b1", S[2], at(190, 2), [(at(190, 100), 500, 400, 50, 9)])
clog("c1", S[4], at(170, 2), [(at(170, 40), 70, 0, 7, 0)])
clog("d1", S[5], at(150, 2), [(at(150, 50), 1000, 900, 30, 3), (at(140, 50), 2500, 2300, 60, 6)])
clog("e1", S[6], at(130, 2), [(at(130, 30), 10, 0, 1, 0)], model="bad model!")
clog("f1", S[7], at(125, 2), [])
clog("g1", S[8], at(120, 2), [(at(120, 20), 20, 0, 2, 0)], extra_lines=("{broken",))
clog("i1", "0000000c-0000-7000-8000-00000000000c", at(100, 2), [(at(100, 10), 5, 0, 1, 0)])
clog("h1", S[9], at(115, 2), [(at(115, 20), 30, 0, 3, 0)])
FIXTURES
}

# ---- 1. counterfactual + negative controls ----------------------------------------------------------
build
if [ ! -e "$work/repo/scripts/run-analytics.missing" ] && ! (cd "$work/repo" && python3 scripts/run-analytics.missing >/dev/null 2>&1); then
  pass "prior state: an absent collector produces no report"
else fail "prior state"; fi

# ---- 2. the main run --------------------------------------------------------------------------------
build
before_home=$(snapshot "$work/home")
before_git=$(cd "$work/repo" && git status --porcelain && git for-each-ref && git rev-parse HEAD && cksum .git/index)
out=$(run "$work/repo"); st=$?
[ "$st" -eq 0 ] && pass "main run exits 0" || fail "main run exit $st: $out"
STORE="$work/repo/.context/telemetry/gate-calls.jsonl"
[ "$before_home" = "$(snapshot "$work/home")" ] && pass "sources are byte-identical after the run" || fail "sources changed"
[ "$before_git" = "$(cd "$work/repo" && git status --porcelain && git for-each-ref && git rev-parse HEAD && cksum .git/index)" ] &&
  pass "repository status, refs and index unchanged" || fail "repository changed"
[ ! -e "$work/repo/scripts/__pycache__" ] && pass "no __pycache__ written" || fail "__pycache__ written"
if grep -q 'SECRET-MARKER-7f3a' "$STORE" || printf '%s\n' "$out" | grep -q 'SECRET-MARKER-7f3a'; then
  fail "no-text: marker leaked into store or report"
else pass "no-text: marker appears in neither store nor report"; fi
mode=$(python3 -c 'import os,stat,sys; print(oct(stat.S_IMODE(os.stat(sys.argv[1]).st_mode)), oct(stat.S_IMODE(os.stat(sys.argv[2]).st_mode)))' "$work/repo/.context/telemetry" "$STORE")
[ "$mode" = "0o700 0o600" ] && pass "store directory 0700, store 0600" || fail "modes $mode"

expect "store records" "$(python3 -c 'import json,sys
for l in open(sys.argv[1]):
    r=json.loads(l); print(r["tool_use_id"], r["tool"], r["review_type"], r["duration_s"], r["success"], ",".join(r["slots"]) or "-", r["codex_files"], ",".join(r["models"]) or "-", r["tokens_in"], r["tokens_out"], r["tokens_unknown"])' "$STORE")" <<'EOF'
toolu_old exec None None None - 0 - None None no_session
toolu_exec1 exec None 100.0 True gate-a-spec-aaaaaaaa-pass-2 2 gpt-6-astra,gpt-6-mini 340 24 None
toolu_full1 review None 200.0 True gate-b-spec-aaaaaaaa-pass-1,gate-b-quality-aaaaaaaa-pass-1 0 gpt-6-astra None None no_logs
toolu_nonjson exec None 5.0 None - 0 - None None no_session
toolu_noslot exec None 50.0 False - 1 gpt-6-astra 70 7 None
toolu_r1 exec None 60.0 True gate-a-plan-bbbbbbbb-pass-1 0 - None None shared
toolu_r2 exec None 60.0 True gate-a-plan-bbbbbbbb-pass-2 0 - None None shared
toolu_open review spec 40.0 True gate-b-spec-ffffffff-pass-1 1 - 10 1 None
toolu_curveonly review quality 40.0 True gate-b-quality-eeeeeeee-pass-1 0 gpt-6-astra None None log_unusable
toolu_conf exec None 30.0 True gate-a-spec-cccccccc-pass-1 0 gpt-6-astra None None log_unusable
toolu_kinds exec None 30.0 True gate-a-spec-dddddddd-pass-1 1 gpt-6-astra 30 3 None
toolu_bare exec None 15.0 True gate-a-spec-pass-4 1 gpt-6-astra 5 1 None
EOF

expect "report" "$out" <<'EOF'
run-analytics — read-only report over gate calls
store: .context/telemetry/gate-calls.jsonl (in the main worktree)
records stored 12  added this run 12  deleted by retention (365 days) 0
pending calls 1  calls not stored (not in this clone) 2  malformed calls 0  values that failed their checks this run 1
stored records: no result or no valid end 1  tokens unknown 7 (no_session 2, no_logs 1, log_unusable 2, shared 2)
skipped sources: malformed line 2, wrong shape 3
history searched: git log --all
class counts are (record, nonce) pairs plus one per record without a nonce:
  confirmed 2  no story 2  open 2  conflicting 2  no nonce 1  no slot 3
pass numbers count what calls wrote; they are not gate verdicts

== Attributed effort, per story (closed cycles only; not the story's full cost; stories sharing a cycle overlap)
docs/superpowers/stories/s1-story.md
  total  calls 2  passes 1-2  duration_s 300.0 (? 0 of 2)  tokens_in 340 (? 1 of 2)  tokens_cached 200 (? 1 of 2)  tokens_out 24 (? 1 of 2)  tokens_reasoning 7 (? 1 of 2)
  cycle aaaaaaaa  calls 2  passes 1-2  duration_s 300.0 (? 0 of 2)  tokens_in 340 (? 1 of 2)  tokens_cached 200 (? 1 of 2)  tokens_out 24 (? 1 of 2)  tokens_reasoning 7 (? 1 of 2)

== Unattributed effort
cycles without a story:
  cycle bbbbbbbb  calls 2  passes 1-2  duration_s 120.0 (? 0 of 2)  tokens_in ? (? 2 of 2)  tokens_cached ? (? 2 of 2)  tokens_out ? (? 2 of 2)  tokens_reasoning ? (? 2 of 2)
open:
  cycle eeeeeeee  calls 1  passes 1  duration_s 40.0 (? 0 of 1)  tokens_in ? (? 1 of 1)  tokens_cached ? (? 1 of 1)  tokens_out ? (? 1 of 1)  tokens_reasoning ? (? 1 of 1)
  cycle ffffffff  calls 1  passes 1  duration_s 40.0 (? 0 of 1)  tokens_in 10 (? 0 of 1)  tokens_cached 0 (? 0 of 1)  tokens_out 1 (? 0 of 1)  tokens_reasoning 0 (? 0 of 1)
conflicting:
  cycle cccccccc  calls 1  passes 1  duration_s 30.0 (? 0 of 1)  tokens_in ? (? 1 of 1)  tokens_cached ? (? 1 of 1)  tokens_out ? (? 1 of 1)  tokens_reasoning ? (? 1 of 1)
  cycle dddddddd  calls 1  passes 1  duration_s 30.0 (? 0 of 1)  tokens_in 30 (? 0 of 1)  tokens_cached 0 (? 0 of 1)  tokens_out 3 (? 0 of 1)  tokens_reasoning 0 (? 0 of 1)
no nonce:
  calls 1  passes 4  duration_s 15.0 (? 0 of 1)  tokens_in 5 (? 0 of 1)  tokens_cached 0 (? 0 of 1)  tokens_out 1 (? 0 of 1)  tokens_reasoning 0 (? 0 of 1)
no slot:
  calls 3  passes -  duration_s 55.0 (? 1 of 3)  tokens_in 70 (? 2 of 3)  tokens_cached 0 (? 2 of 3)  tokens_out 7 (? 2 of 3)  tokens_reasoning 0 (? 2 of 3)

== What this report cannot answer
- Calls whose transcript was deleted by Claude Code's cleanup before they were collected.
- Cost in money or credits: the logs carry no per-call cost, and the account balance does not move inside a session's logs.
- Tokens of calls that share a Codex session (a resume): they are left unknown rather than split.
- Whether a token sum is complete: it covers the Codex files present when the call was stored; a sub-agent log that was missing or still being written then is not in it.
- Calls from removed worktrees or other clones of this repository: membership needs the working directory to exist in this clone.
- Stories of open, abandoned or conflicting cycles: their effort is reported as unattributed and not guessed onto a story.
- Values that were unknown when a record was written stay unknown, because records never change.
- Undecodable bytes in transcript and log text become U+FFFD before that text is read, and control characters print as \xNN.
- The orchestrating session's own tokens per gate call: the transcript records usage per message, not per tool call.
- Calls made outside Claude Code, for example Codex run directly.
- Renamed or reused story paths: the trace ID is the story path.
EOF

# ---- 3. second run, deleted sources, retention ------------------------------------------------------
cp "$STORE" "$work/store1"
out2=$(run "$work/repo"); st=$?
[ "$st" -eq 0 ] && cmp -s "$STORE" "$work/store1" && printf '%s\n' "$out2" | grep -q '^records stored [0-9]*  added this run 0 ' &&
  pass "second run adds nothing and leaves the store unchanged" || fail "second run changed the store"
rm -rf "$work/home/.claude"
out3=$(run "$work/repo"); st=$?
[ "$st" -eq 0 ] && cmp -s "$STORE" "$work/store1" &&
  [ "$(printf '%s\n' "$out3" | sed -n '/^== Attributed effort/,$p')" = "$(printf '%s\n' "$out" | sed -n '/^== Attributed effort/,$p')" ] &&
  printf '%s\n' "$out3" | grep -q 'missing root ~/.claude/projects 1' &&
  pass "deleted transcripts: records and report sections unchanged, missing root reported" || fail "deleted transcripts"
age() { python3 -c 'import datetime,json,sys
p=sys.argv[1]; rs=[json.loads(l) for l in open(p)]
now=datetime.datetime.now(datetime.timezone.utc)
for i,d in ((0,int(sys.argv[2])),(1,int(sys.argv[3]))):
    s=now-datetime.timedelta(days=d); rs[i]["started"]=s.strftime("%Y-%m-%dT%H:%M:%S.%fZ")
    if rs[i]["ended"]:
        e=s+datetime.timedelta(seconds=rs[i]["duration_s"]); rs[i]["ended"]=e.strftime("%Y-%m-%dT%H:%M:%S.%fZ")
        rs[i]["duration_s"]=(e-s).total_seconds()
open(p,"w").write("".join(json.dumps(r,sort_keys=True,separators=(",",":"))+"\n" for r in rs))' "$STORE" "$1" "$2"; }
age 400 30
n_before=$(wc -l < "$STORE")
out4=$(run "$work/repo"); st=$?
[ "$st" -eq 0 ] && [ "$(wc -l < "$STORE")" -eq $((n_before - 1)) ] && printf '%s\n' "$out4" | grep -q 'deleted by retention (365 days) 1' &&
  pass "retention: default deletes a 400-day-old record and keeps a 30-day-old one" || fail "retention default ($n_before -> $(wc -l < "$STORE"))"
age 20 10
n_before=$(wc -l < "$STORE")
out5=$(run "$work/repo" --keep-days 15); st=$?
[ "$st" -eq 0 ] && [ "$(wc -l < "$STORE")" -eq $((n_before - 1)) ] && printf '%s\n' "$out5" | grep -q 'deleted by retention (15 days) 1' &&
  pass "retention: --keep-days 15 deletes a 20-day-old record and keeps a 10-day-old one" || fail "retention override ($n_before -> $(wc -l < "$STORE"))"

# ---- 3b. a resume stays "shared" when either call's transcript is gone --------------------------------
shared_of() { python3 -c 'import json,sys
for l in open(sys.argv[1]):
    r=json.loads(l)
    if r["tool_use_id"]==sys.argv[2]: print(r["tokens_unknown"])' "$STORE" "$1"; }
build; rm "$work/home/.claude/projects/-fixture/sess1/subagents/agent-1.jsonl"; run "$work/repo" >/dev/null
[ "$(shared_of toolu_r1)" = shared ] && pass "resumed call is shared without the resuming call's transcript" || fail "r1 without r2: $(shared_of toolu_r1)"
build; rm "$work/home/.claude/projects/-fixture/sess2.jsonl"; run "$work/repo" >/dev/null
[ "$(shared_of toolu_r2)" = shared ] && pass "resuming call is shared without the resumed call's transcript" || fail "r2 without r1: $(shared_of toolu_r2)"

# ---- 4. exit-1 causes -------------------------------------------------------------------------------
bad() { # name, expected message, command...
  name=$1; msg=$2; shift 2
  e=$("$@" 2>&1 >/dev/null); s=$?
  if [ "$s" -eq 1 ] && printf '%s' "$e" | grep -qF "run-analytics: $msg"; then pass "$name"; else fail "$name (exit $s: $e)"; fi
}
build; run "$work/repo" >/dev/null
bad "invalid --keep-days" "--keep-days must be" raw "$work/repo" --keep-days 0
printf 'not json\n' >> "$STORE"
bad "invalid store line" "the store is invalid at line" raw "$work/repo"
build; run "$work/repo" >/dev/null
python3 -c 'import json,sys
p=sys.argv[1]; rs=[json.loads(l) for l in open(p)]
rs[1]["duration_s"]=rs[1]["duration_s"]+7
open(p,"w").write("".join(json.dumps(r,sort_keys=True,separators=(",",":"))+"\n" for r in rs))' "$STORE"
bad "schema-violating store record" "the store is invalid at line 2" raw "$work/repo"
build; run "$work/repo" >/dev/null; head -1 "$STORE" > "$work/dup"; cat "$work/dup" >> "$STORE"
bad "duplicate record" "the store repeats a record" raw "$work/repo"
build; run "$work/repo" >/dev/null; mv "$STORE" "$work/realstore"; ln -s "$work/realstore" "$STORE"
bad "symlinked store" "the store is a symlink" raw "$work/repo"
build; mkdir -p "$work/repo/.context/telemetry"; chmod 700 "$work/repo/.context/telemetry"; ln -s "$work/x" "$work/repo/.context/telemetry/.lock"
bad "symlinked lock" "the lock is a symlink" raw "$work/repo"
build; mkdir -p "$work/repo/.context/telemetry"; mkfifo "$work/repo/.context/telemetry/.lock"
bad "FIFO lock" "the lock is not a regular file" raw "$work/repo"
build; mkdir -p "$work/repo/.context/telemetry"; : > "$work/outside"; chmod 644 "$work/outside"; ln "$work/outside" "$work/repo/.context/telemetry/.lock"
bad "hard-linked lock" "the lock is not a regular file" raw "$work/repo"
[ "$(python3 -c 'import os,stat,sys; print(oct(stat.S_IMODE(os.stat(sys.argv[1]).st_mode)))' "$work/outside")" = 0o644 ] &&
  pass "hard-linked lock: the outside file keeps its mode" || fail "hard-linked lock changed the outside file"
build; mkdir -p "$work/repo/.context/telemetry"
python3 -c 'import fcntl,os,sys,time
fd=os.open(sys.argv[1],os.O_RDWR|os.O_CREAT,0o600); fcntl.flock(fd,fcntl.LOCK_EX); open(sys.argv[2],"w").close(); time.sleep(30)' \
  "$work/repo/.context/telemetry/.lock" "$work/locked" &
holder=$!
i=0; while [ ! -e "$work/locked" ] && [ $i -lt 100 ]; do i=$((i + 1)); sleep 0.1; done
bad "held lock" "another run holds the lock" raw "$work/repo"
kill "$holder" 2>/dev/null; wait "$holder" 2>/dev/null
mkdir -p "$work/norepo"
rawin() { (cd "$1" && HOME="$work/home" python3 "$2"); }
bad "not a git repository" "not a git repository" rawin "$work/norepo" "$work/repo/scripts/run-analytics.py"

# ---- 5. worktree, inherited GIT_DIR, empty home -----------------------------------------------------
build
run "$work/wt" >/dev/null; st=$?
[ "$st" -eq 0 ] && [ -s "$STORE" ] && [ ! -e "$work/wt/.context/telemetry" ] &&
  pass "a run from the linked worktree writes the main worktree's store" || fail "worktree run ($st)"
build
outg=$( (cd "$work/repo" && GIT_DIR="$work/other/.git" HOME="$work/home" python3 scripts/run-analytics.py) 2>&1 ); st=$?
build
outn=$(run "$work/repo")
[ "$st" -eq 0 ] && [ "$(printf '%s\n' "$outg" | sed 1,3d)" = "$(printf '%s\n' "$outn" | sed 1,3d)" ] &&
  pass "an inherited GIT_DIR does not change the result" || fail "inherited GIT_DIR changed the result"
build; rm -rf "${work:?}/home"; mkdir -p "$work/home"
oute=$(run "$work/repo"); st=$?
[ "$st" -eq 0 ] && printf '%s\n' "$oute" | grep -q '^records stored 0  added this run 0 ' &&
  printf '%s\n' "$oute" | grep -q 'missing root ~/.claude/projects 1' &&
  pass "empty home: zero report, exit 0" || fail "empty home ($st)"

# ---- 6. negative controls ---------------------------------------------------------------------------
build
sed 's/rec\["slots"\] = slots_of(body)/rec["slots"] = slots_of(body); rec["models"] = [str(body)]/' "$work/repo/scripts/run-analytics.py" > "$work/repo/scripts/leaky.py"
cmp -s "$work/repo/scripts/run-analytics.py" "$work/repo/scripts/leaky.py" && fail "negative control: leak mutation did not apply"
runs "$work/repo" "$work/repo/scripts/leaky.py" >/dev/null 2>&1
if grep -q 'SECRET-MARKER-7f3a' "$STORE" 2>/dev/null || ! [ -s "$STORE" ]; then
  pass "negative control: a copy that stores reply text is caught (store rejected or marker found)"
else fail "negative control: leak not caught"; fi
build
sed 's/            member_cache\[wd\] = common_dir(wd) == mine/            member_cache[wd] = True/' "$work/repo/scripts/run-analytics.py" > "$work/repo/scripts/nomember.py"
cmp -s "$work/repo/scripts/run-analytics.py" "$work/repo/scripts/nomember.py" && fail "negative control: membership mutation did not apply"
runs "$work/repo" "$work/repo/scripts/nomember.py" >/dev/null 2>&1
grep -q '"tool_use_id":"toolu_other"' "$STORE" &&
  pass "negative control: dropping the membership test stores the other repository's call" ||
  fail "negative control: membership mutation not caught"

printf '\n%d passed, %d failed\n' "$pass_n" "$fail_n"
[ "$fail_n" -eq 0 ]
