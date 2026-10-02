# Run Analytics Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Story:** `docs/superpowers/stories/2026-10-02-run-analytics-trace-id-and-retention-story.md` — read the profile from its header at every gate call.

**Goal:** Add `scripts/run-analytics.py`, which collects gate-call effort (duration, tokens, models) from the Claude Code transcripts and Codex session logs on this machine into an immutable per-clone store, and reports it per closed cycle and story, with all other effort shown as unattributed. Add its POSIX-sh suite and wire the suite into the battery, CI and the docs.

**Architecture:** One Python 3.8+ standard-library script. It finds this clone through git (with repository-selecting variables removed), takes a lock on `<main worktree>/.context/telemetry/.lock`, and loads and validates the JSONL store. It then scans transcripts (only lines that can be gate calls are parsed), reads Codex logs only for the sessions it needs, and appends new immutable records. Retention runs, the store is rewritten atomically, and the report is built from the store. Story attribution reuses `scripts/ledger-metrics.py`'s record parser at report time. The suite builds a fixture HOME and fixture repositories, then asserts the store and the report line for line.

**Tech Stack:** Python 3.8+ (standard library), git 2.36+, POSIX `sh` for the suite, `shellcheck` 0.11.0.

**Spec:** `docs/superpowers/specs/2026-10-02-run-analytics-design.md` (Gate-A spec cycle `bd2vvqjtbn`, closed in `f9aae57`).

## Global Constraints

- Worktree `/Users/daniel/DEVELOPMENT/APPS/dwk-telemetry`, branch `telemetry`. Paths are relative to it.
- Not shipped: no file under `plugins/` changes, and there is no version bump (spec §1).
- The script writes only under `<main worktree>/.context/telemetry/`, and stores typed numbers and identifiers, never session text (spec §3, §4).
- Every git call runs without repository-selecting variables, in an explicit directory (spec §4).
- The suite passes `shellcheck --shell=sh --exclude=SC2015`, like the other suites.
- Unexpected repository state is a stop and a question to Daniel; no automated stash, rebase or reset.

## Rulings — spec cycle Minors and prototype findings

The spec is closed and is not edited. Where the implementation reads it narrowly or settles something it left open, the ruling is stated here, and the Gate-B call names it.

1. **Transcript prefilter.** Only lines containing the bytes `codex` or `tool_` are parsed, which makes a full run take about a minute instead of three on this machine's 1680 transcripts. The counted malformed and wrong-shape lines are therefore those among the candidate lines. A broken line that cannot be a gate call is neither parsed nor counted. A line where those bytes appear only as JSON `\u` escapes of ASCII letters is skipped without a count. Claude Code writes JSON that never escapes ASCII letters, so this is accepted as a stated limit.
2. **A call's tokens need a log for every one of its sessions.** If any session ID of the call has no Codex file, the tokens are unknown (`no_logs`). The spec's "no file is found" is read per session, so a full review with one branch's log missing never reports half its tokens as the whole.
3. **`review_type` when the call gave none** stays `null` (the spec's table), although the MCP tool's own default is `full`.
4. **Header wording.** The "no Codex logs" count is dropped. The `tokens unknown` breakdown (`no_session`, `no_logs`, `log_unusable`, `shared`) carries the same information without overlap, and the reason is stored per record as `tokens_unknown`.
5. **Classes.** A cycle whose single provenance line names the story set `none` is reported as "no story", the spec's "cycle without a story". Class counts are printed with the spec's definition.
6. **Models of a shared session** are not recorded (empty list), like its tokens, because they would include other calls' turns.
7. **The store directory's parent `.context/`**, if absent, is created with mode 0755 like an ordinary checkout directory. Only `telemetry/` gets 0700.
8. **Which transcript events count.** A gate `tool_use` counts only inside an `assistant` event, and a `tool_result` only inside a `user` event. A gate-named `tool_use` anywhere else is counted under "wrong shape". Within one transcript the first use of an ID counts. It is paired with the first result for it that comes later **in the file**, whatever that result's timestamp says. `build_record` then checks the timestamp: a missing or backwards one is stored as `null` and counted. A `tool_use` with a non-string name or id, and a `tool_result` without a string `tool_use_id` or outside a `user` event, are counted as "wrong shape". So is a Codex file whose first line is not a `session_meta` with a string `session_id`, and a Codex line that is not an object. Usage comes only from `event_msg` `token_count` events.
9. **Record timestamps keep microseconds** (`…T12:00:00.123456Z`), so a stored `duration_s` is exactly the difference of the stored endpoints, and the store check verifies it. `+00:00` is accepted as well as `Z`.
10. **Each token value is checked on its own** (spec §3, "any other value that fails its check is stored as `null`"). A component that fails in any file is `null` and counted, the others are still summed, and `tokens_unknown` is then `log_unusable`. `codex_files` counts the files summed when at least one component is known, and is 0 otherwise. Models are recorded whenever the call's sessions are not shared, including when a session has no log or the token values are unusable. Session IDs come only from values matching the session pattern; any other present value is counted. A resume is recognized from such a valid ID in the call's input.

## Review Focus

1. **The real logs on this machine.** The prototype ran over the main checkout on 2026-10-02: about a minute, 195 records, no skipped sources, no wrong-shape counts. The plan does not repeat that run, because it would create the real store, which is not the plan's to make or remove. Daniel runs it after the merge.
2. **Codex app model changes.** The suite never calls Codex; Gate B does, and checks the model first (Task 3).
3. **A held lock from a crashed run.** `flock` locks are released when the process ends, so a crash cannot leave a stale lock. The suite's held-lock case uses a live holder.
4. **CI's Linux runner:** `fcntl`, `O_NOFOLLOW` and `mkfifo` are POSIX. CI is the first Linux run, so read its log (Task 3).
5. **Clock skew between transcripts and Codex logs.** Both are written by this machine in UTC, and the sharing rule compares them. The fixture uses one clock, and the plan does not claim more.

---

## File map

| Path | Change | Task |
|---|---|---|
| `scripts/run-analytics.test.sh` | Create | 1 |
| `scripts/run-analytics.py` | Create | 1 |
| `AGENTS.md` | Layout tree, Boundaries, § Commands quality + lint rows, prerequisites | 2 |
| `.github/workflows/ci.yml` | Lint step, suite step, one comment | 2 |
| `README.md` | Contributing: suites line + one paragraph | 2 |

---

### Task 1: The suite, then the script

**Files:** Create `scripts/run-analytics.test.sh`, `scripts/run-analytics.py`.

- [ ] **Step 1: Write the suite**

Create `scripts/run-analytics.test.sh` with exactly this content:

````sh
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
````

- [ ] **Step 2: Run it before the script exists**

Run: `sh scripts/run-analytics.test.sh > /tmp/ra-red.log 2>&1; echo "exit=$?"; tail -1 /tmp/ra-red.log`
Expected: `exit=1`, failures reported. The suite's fixture repositories copy `scripts/run-analytics.py`, which does not exist yet.

- [ ] **Step 3: Write the script**

Create `scripts/run-analytics.py` with exactly this content:

````python
#!/usr/bin/env python3
"""Collect gate-call records from Claude Code transcripts and Codex session logs, keep them in a
per-clone store, and report effort per cycle and story.

Spec: docs/superpowers/specs/2026-10-02-run-analytics-design.md
Usage: python3 scripts/run-analytics.py [--keep-days N]

Read-only toward every source. Writes only <main worktree>/.context/telemetry/. Stores typed numbers
and identifiers, never session text. Standard library only; Python 3.8 or later; git 2.36 or later.
"""
import datetime
import errno
import fcntl
import importlib.util
import json
import math
import os
import re
import stat
import subprocess
import sys

KEEP_DAYS_DEFAULT = 365
PENDING_HOURS = 6
TMP_PREFIX = ".gate-calls.tmp."
STORE = "gate-calls.jsonl"
GATE_TOOLS = {"mcp__codex__exec": "exec", "mcp__codex__review": "review"}
SESSION_KEYS = ("sessionId", "specSessionId", "qualitySessionId")
GIT_SELECTORS = ("GIT_DIR", "GIT_WORK_TREE", "GIT_COMMON_DIR", "GIT_INDEX_FILE",
                 "GIT_OBJECT_DIRECTORY", "GIT_ALTERNATE_OBJECT_DIRECTORIES",
                 "GIT_CEILING_DIRECTORIES", "GIT_DISCOVERY_ACROSS_FILESYSTEM", "GIT_NAMESPACE")

RE_ID = re.compile(r"[A-Za-z0-9_-]{1,64}")
RE_SESSION = re.compile(r"[0-9a-f-]{36}")
RE_MODEL = re.compile(r"[A-Za-z0-9._:+-]{1,64}")
RE_SLOT = re.compile(r"gate-a-(?:spec|plan)(?:-([a-z0-9]{8,16}))?-pass-([1-9][0-9]*)"
                     r"|gate-b-(?:spec|quality)(?:-([a-z0-9]{8,16}))?-pass-([1-9][0-9]*)")
RE_REPLY = re.compile(r"^(?:gate-a-spec|gate-a-plan|gate-b-spec|gate-b-quality) \| pass [1-9][0-9]* \| "
                      r"[0-9]+ findings \| (\S+)$|^INCOMPLETE \| [^|]* \| (\S+)$")
RE_SLOT_PATH = re.compile(r"(?:^|/)\.context/codex-reviews/([^/\s]+)\.md$")
RE_TS = re.compile(r"(\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2})(?:\.(\d{1,6}))?(?:Z|\+00:00)")
UNKNOWN_REASONS = ("no_session", "no_logs", "log_unusable", "shared")
TOKEN_FIELDS = ("tokens_in", "tokens_cached", "tokens_out", "tokens_reasoning")
TOKEN_KEYS = ("input_tokens", "cached_input_tokens", "output_tokens", "reasoning_output_tokens")
RECORD_KEYS = {"tool_use_id", "tool", "review_type", "started", "ended", "duration_s", "success",
               "session_ids", "slots", "codex_files", "models", "tokens_unknown", *TOKEN_FIELDS}

CANNOT = """== What this report cannot answer
- Calls whose transcript was deleted by Claude Code's cleanup before they were collected.
- Cost in money or credits: the logs carry no per-call cost, and the account balance does not move inside a session's logs.
- Tokens of calls that share a Codex session (a resume): they are left unknown rather than split.
- Whether a token sum is complete: it covers the Codex files present when the call was stored; a sub-agent log that was missing or still being written then is not in it.
- Calls from removed worktrees or other clones of this repository: membership needs the working directory to exist in this clone.
- Stories of open, abandoned or conflicting cycles: their effort is reported as unattributed and not guessed onto a story.
- Values that were unknown when a record was written stay unknown, because records never change.
- Undecodable bytes in transcript and log text become U+FFFD before that text is read, and control characters print as \\xNN.
- The orchestrating session's own tokens per gate call: the transcript records usage per message, not per tool call.
- Calls made outside Claude Code, for example Codex run directly.
- Renamed or reused story paths: the trace ID is the story path."""


def shown(text):
    return "".join("\\x%02x" % ord(c) if ord(c) < 0x20 or 0x7F <= ord(c) <= 0x9F else c for c in str(text))


def die(msg):
    sys.stderr.buffer.write(("run-analytics: %s\n" % shown(msg)).encode("utf-8", "backslashreplace"))
    sys.stderr.flush()
    sys.exit(1)


def git_env():
    """The environment for every git call: no repository selectors and no trace sinks."""
    env = {k: v for k, v in os.environ.items() if not k.startswith("GIT_TRACE")}
    for k in GIT_SELECTORS:
        env.pop(k, None)
    env.update(GIT_TRACE2="0", GIT_TRACE2_EVENT="0", GIT_TRACE2_PERF="0")  # overrides trace2.* config
    return env


def git(args, cwd):
    try:
        p = subprocess.run(("git",) + tuple(args), cwd=cwd, env=git_env(),
                           stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    except OSError:
        return 127, b""
    return p.returncode, p.stdout


def common_dir(cwd):
    rc, out = git(("rev-parse", "--path-format=absolute", "--git-common-dir"), cwd)
    if rc != 0 or not out.endswith(b"\n"):
        return None
    return os.path.realpath(os.fsdecode(out[:-1]))


def parse_ts(value):
    """ISO-8601 UTC timestamp (Z or +00:00) -> aware datetime, or None."""
    m = RE_TS.fullmatch(value) if isinstance(value, str) else None
    if not m:
        return None
    try:
        dt = datetime.datetime.strptime(m.group(1), "%Y-%m-%dT%H:%M:%S")
    except ValueError:
        return None
    return dt.replace(microsecond=int((m.group(2) or "0").ljust(6, "0")), tzinfo=datetime.timezone.utc)


def iso(dt):
    return dt.strftime("%Y-%m-%dT%H:%M:%S.%fZ")


def is_nonneg_int(v):
    return isinstance(v, int) and not isinstance(v, bool) and v >= 0


def bump(problems, kind):
    problems[kind] = problems.get(kind, 0) + 1


# ---- sources ---------------------------------------------------------------------------------------

def walk_jsonl(root, pattern, problems):
    """Every regular matching file under root, sorted; unenumerable directories counted."""
    if not os.path.isdir(root):
        bump(problems, "missing root " + root.replace(os.path.expanduser("~"), "~", 1))
        return []
    found = []
    for d, _dirs, files in os.walk(root, onerror=lambda _e: bump(problems, "unenumerable directory")):
        for name in files:
            if pattern(name):
                p = os.path.join(d, name)
                try:
                    if stat.S_ISREG(os.lstat(p).st_mode):
                        found.append(p)
                    else:
                        bump(problems, "not a regular file")
                except OSError:
                    bump(problems, "unreadable file")
    return sorted(found)


def read_lines(path, problems, keep=None):
    """Parse a JSONL file. With `keep`, a line is parsed only if it contains one of those byte strings
    (plan ruling 1); other lines are neither parsed nor counted."""
    try:
        with open(path, "rb") as fh:
            data = fh.read()
    except OSError:
        bump(problems, "unreadable file")
        return []
    out = []
    for raw in data.split(b"\n"):
        if not raw.strip() or (keep and not any(k in raw for k in keep)):
            continue
        try:
            out.append(json.loads(raw.decode("utf-8", "replace")))
        except (ValueError, RecursionError):
            bump(problems, "malformed line")
    return out


def result_text(content):
    if isinstance(content, str):
        return content
    if isinstance(content, list) and content and isinstance(content[0], dict):
        t = content[0].get("text")
        return t if isinstance(t, str) else None
    return None


def envelope(res):
    text = result_text(res[1]) if res else None
    if text is None:
        return None
    try:
        env = json.loads(text)
    except (ValueError, RecursionError):
        return None
    return env if isinstance(env, dict) else None


def scan_transcripts(problems):
    """tool_use_id -> call. Within a transcript the first use of an ID counts, paired with the first
    result for it that comes later in the file (ruling 8); across transcripts the first occurrence that
    has a result supplies the values."""
    root = os.path.join(os.path.expanduser("~"), ".claude", "projects")
    calls = {}
    for path in walk_jsonl(root, lambda n: n.endswith(".jsonl"), problems):
        uses = {}
        for obj in read_lines(path, problems, keep=(b"codex", b"tool_")):
            msg = obj.get("message") if isinstance(obj, dict) else None
            content = msg.get("content") if isinstance(msg, dict) else None
            if not isinstance(content, list):
                if not isinstance(obj, dict):
                    bump(problems, "wrong shape")
                continue
            role = obj.get("type")
            for it in content:
                kind = it.get("type") if isinstance(it, dict) else None
                if kind == "tool_use":
                    name = it.get("name")
                    if not isinstance(name, str) or not isinstance(it.get("id"), str):
                        bump(problems, "wrong shape")
                    elif name in GATE_TOOLS:
                        if role != "assistant":
                            bump(problems, "wrong shape")
                        elif it["id"] not in uses:
                            inp = it.get("input") if isinstance(it.get("input"), dict) else {}
                            uses[it["id"]] = [obj.get("timestamp"), GATE_TOOLS[name], inp, None]
                elif kind == "tool_result":
                    uid = it.get("tool_use_id")
                    if not isinstance(uid, str) or role != "user":
                        bump(problems, "wrong shape")
                    elif uid in uses and uses[uid][3] is None:
                        uses[uid][3] = (obj.get("timestamp"), it.get("content"))
        for uid, (ts, tool, inp, res) in uses.items():
            prev = calls.get(uid)
            if prev is None or (prev["result"] is None and res is not None):
                calls[uid] = {"id": uid, "started": ts, "tool": tool, "input": inp, "result": res}
    return calls


def first_session_id(path, problems):
    try:
        with open(path, "rb") as fh:
            obj = json.loads(fh.readline().decode("utf-8", "replace"))
    except OSError:
        bump(problems, "unreadable file")
        return None
    except (ValueError, RecursionError):
        bump(problems, "malformed line")
        return None
    payload = obj.get("payload") if isinstance(obj, dict) and obj.get("type") == "session_meta" else None
    sid = payload.get("session_id") if isinstance(payload, dict) else None
    if not isinstance(sid, str):
        bump(problems, "wrong shape")
        return None
    return sid


def scan_codex(problems, wanted):
    """session_id -> list of file facts, for the wanted sessions only (each file's first line names its
    session; only matching files are read in full)."""
    root = os.path.join(os.path.expanduser("~"), ".codex", "sessions")
    sessions = {}
    for path in walk_jsonl(root, lambda n: n.startswith("rollout-") and n.endswith(".jsonl"), problems):
        sid = first_session_id(path, problems)
        if sid not in wanted:
            continue
        before = dict(problems)
        lines = read_lines(path, problems)
        fact = {"meta_ts": None, "last_ts": None, "usage": None, "models": set(),
                "bad": problems != before or not lines}
        if lines and isinstance(lines[0], dict):
            meta = lines[0].get("payload") if isinstance(lines[0].get("payload"), dict) else {}
            fact["meta_ts"] = parse_ts(meta.get("timestamp") or lines[0].get("timestamp"))
        for obj in lines:
            if not isinstance(obj, dict):
                bump(problems, "wrong shape")
                fact["bad"] = True
                continue
            t = parse_ts(obj.get("timestamp"))
            if t and (fact["last_ts"] is None or t > fact["last_ts"]):
                fact["last_ts"] = t
            payload = obj.get("payload") if isinstance(obj.get("payload"), dict) else {}
            if obj.get("type") == "event_msg" and payload.get("type") == "token_count":
                info = payload.get("info")
                u = info.get("total_token_usage") if isinstance(info, dict) else None
                fact["usage"] = u if isinstance(u, dict) else None  # the last event wins, usable or not
            if obj.get("type") == "turn_context" and "model" in payload:
                fact["models"].add(payload["model"] if isinstance(payload["model"], str) else None)
        sessions.setdefault(sid, []).append(fact)
    return sessions


# ---- building records ------------------------------------------------------------------------------

def slots_of(text):
    slots = []
    if not isinstance(text, str):
        return slots
    for line in text.split("\n"):
        m = RE_REPLY.match(line.strip())
        if not m:
            continue
        pm = RE_SLOT_PATH.search(m.group(1) or m.group(2))
        if pm and RE_SLOT.fullmatch(pm.group(1)) and pm.group(1) not in slots:
            slots.append(pm.group(1))
    return slots


def call_session_ids(d, invalid=None):
    """The distinct valid session IDs in d; a present value that is not one is counted."""
    out = []
    for k in SESSION_KEYS:
        v = d.get(k) if isinstance(d, dict) else None
        if v is None or v == "":
            continue
        if isinstance(v, str) and RE_SESSION.fullmatch(v):
            if v not in out:
                out.append(v)
        elif invalid is not None:
            invalid[0] += 1
    return out


def build_record(call, sessions, sid_users, now, invalid):
    """Return a record dict, 'pending', or None (malformed)."""
    if not RE_ID.fullmatch(call["id"]):
        return None
    started = parse_ts(call["started"])
    if started is None:
        return None
    rec = {"tool_use_id": call["id"], "tool": call["tool"], "review_type": None, "started": iso(started),
           "ended": None, "duration_s": None, "success": None, "session_ids": [], "slots": [],
           "codex_files": 0, "models": [], "tokens_unknown": None}
    for f in TOKEN_FIELDS:
        rec[f] = None
    rt = call["input"].get("reviewType")
    if call["tool"] == "review" and rt is not None:
        if rt in ("spec", "quality", "full"):
            rec["review_type"] = rt
        else:
            invalid[0] += 1
    res = call["result"]
    if res is None and now - started <= datetime.timedelta(hours=PENDING_HOURS):
        return "pending"
    if res is not None:
        ended = parse_ts(res[0])
        if ended is not None and ended >= started:
            rec["ended"] = iso(ended)
            rec["duration_s"] = (ended - started).total_seconds()
        else:
            invalid[0] += 1
        env = envelope(res)
        if env is not None:
            if isinstance(env.get("success"), bool):
                rec["success"] = env["success"]
            elif env.get("success") is not None:
                invalid[0] += 1
            rec["session_ids"] = call_session_ids(env, invalid)
            body = env.get("review")
            if call["tool"] == "exec":
                out = env.get("output")
                body = out.get("summary") if isinstance(out, dict) else None
            rec["slots"] = slots_of(body)
    measure_tokens(rec, call, sessions, sid_users, started, invalid)
    return rec


def measure_tokens(rec, call, sessions, sid_users, started, invalid):
    resumed = bool(call_session_ids(call["input"], invalid))
    if not rec["session_ids"]:
        rec["tokens_unknown"] = "no_session"
        return
    files = [f for s in rec["session_ids"] for f in sessions.get(s, ())]
    ended = parse_ts(rec["ended"]) if rec["ended"] else None
    shared = (resumed
              or any(f["meta_ts"] and f["meta_ts"] < started for f in files)
              or any(ended and f["last_ts"] and f["last_ts"] > ended for f in files)
              or any(len(sid_users.get(s, ())) > 1 for s in rec["session_ids"]))
    if shared:
        rec["tokens_unknown"] = "shared"  # tokens and models both cover other calls (ruling 6)
        return
    for m in sorted({m for f in files for m in f["models"]}, key=str):
        if isinstance(m, str) and RE_MODEL.fullmatch(m):
            rec["models"].append(m)
        else:
            invalid[0] += 1
    if any(not sessions.get(s) for s in rec["session_ids"]):
        rec["tokens_unknown"] = "no_logs"  # every session of the call needs at least one log (ruling 2)
        return
    if any(f["bad"] or f["usage"] is None for f in files):
        rec["tokens_unknown"] = "log_unusable"
        return
    for field, key in zip(TOKEN_FIELDS, TOKEN_KEYS):  # each value on its own (spec §3)
        vals = [f["usage"].get(key) for f in files]
        if all(is_nonneg_int(v) for v in vals):
            rec[field] = sum(vals)
        else:
            invalid[0] += 1
    rec["codex_files"] = len(files) if any(rec[f] is not None for f in TOKEN_FIELDS) else 0
    if any(rec[f] is None for f in TOKEN_FIELDS):
        rec["tokens_unknown"] = "log_unusable"


def valid_record(r):
    """The store's type check (spec §3), including consistency between fields."""
    if not isinstance(r, dict) or set(r) != RECORD_KEYS:
        return False
    started = parse_ts(r["started"])
    ended = parse_ts(r["ended"])
    d = r["duration_s"]
    known = [r[f] is not None for f in TOKEN_FIELDS]
    return bool(
        isinstance(r["tool_use_id"], str) and RE_ID.fullmatch(r["tool_use_id"])
        and r["tool"] in ("exec", "review") and r["review_type"] in ("spec", "quality", "full", None)
        and started is not None
        and ((r["ended"] is None and d is None)
             or (ended is not None and ended >= started and type(d) is float and math.isfinite(d)
                 and d == (ended - started).total_seconds()))
        and (r["success"] is None or isinstance(r["success"], bool))
        and isinstance(r["session_ids"], list)
        and all(isinstance(s, str) and RE_SESSION.fullmatch(s) for s in r["session_ids"])
        and isinstance(r["slots"], list) and all(isinstance(s, str) and RE_SLOT.fullmatch(s) for s in r["slots"])
        and is_nonneg_int(r["codex_files"])
        and isinstance(r["models"], list) and all(isinstance(m, str) and RE_MODEL.fullmatch(m) for m in r["models"])
        and r["tokens_unknown"] in UNKNOWN_REASONS + (None,)
        and all(r[f] is None or is_nonneg_int(r[f]) for f in TOKEN_FIELDS)
        and (r["tokens_unknown"] == "no_session") == (not r["session_ids"])
        and (r["tokens_unknown"] != "shared" or not r["models"])
        and ((all(known) and r["tokens_unknown"] is None and r["codex_files"] > 0)
             or (any(known) and not all(known) and r["tokens_unknown"] == "log_unusable"
                 and r["codex_files"] > 0)
             or (not any(known) and r["tokens_unknown"] is not None and r["codex_files"] == 0)))


# ---- store: every path is opened relative to a directory fd and never through a symlink ------------

def open_dir(name, parent_fd, mode, what):
    flags = os.O_RDONLY | os.O_DIRECTORY | os.O_NOFOLLOW
    for _ in range(2):
        try:
            return os.open(name, flags, dir_fd=parent_fd)
        except FileNotFoundError:
            try:
                os.mkdir(name, mode, dir_fd=parent_fd)
            except FileExistsError:
                pass  # another run created it meanwhile
        except OSError as e:
            if e.errno in (errno.ELOOP, errno.ENOTDIR):
                die("%s is a symlink or not a directory" % what)
            die("%s cannot be opened" % what)
    die("%s cannot be created" % what)


def take_lock(tel_fd):
    try:
        if stat.S_ISLNK(os.lstat(".lock", dir_fd=tel_fd).st_mode):
            die("the lock is a symlink")
    except FileNotFoundError:
        pass
    try:
        fd = os.open(".lock", os.O_RDWR | os.O_CREAT | os.O_NOFOLLOW | os.O_NONBLOCK, 0o600, dir_fd=tel_fd)
    except OSError:
        die("the lock cannot be opened")
    st = os.fstat(fd)
    if not stat.S_ISREG(st.st_mode) or st.st_nlink != 1:
        die("the lock is not a regular file with a single link")
    os.fchmod(fd, 0o600)
    try:
        fcntl.flock(fd, fcntl.LOCK_EX | fcntl.LOCK_NB)
    except OSError:
        die("another run holds the lock")
    return fd


def load_store(tel_fd):
    try:
        st = os.lstat(STORE, dir_fd=tel_fd)
    except FileNotFoundError:
        return {}
    if stat.S_ISLNK(st.st_mode):
        die("the store is a symlink")
    if not stat.S_ISREG(st.st_mode):
        die("the store is not a regular file")
    try:
        fd = os.open(STORE, os.O_RDONLY | os.O_NOFOLLOW | os.O_NONBLOCK, dir_fd=tel_fd)
        if not stat.S_ISREG(os.fstat(fd).st_mode):
            os.close(fd)
            die("the store is not a regular file")
        with os.fdopen(fd, "rb") as fh:
            lines = fh.read().decode("utf-8").split("\n")
    except (OSError, UnicodeDecodeError):
        die("the store cannot be read")
    if lines and lines[-1] == "":
        lines.pop()
    records = {}
    for no, line in enumerate(lines, 1):
        try:
            r = json.loads(line)
        except (ValueError, RecursionError):
            die("the store is invalid at line %d" % no)
        if not valid_record(r):
            die("the store is invalid at line %d" % no)
        if r["tool_use_id"] in records:
            die("the store repeats a record at line %d" % no)
        records[r["tool_use_id"]] = r
    return records


def write_store(tel_fd, records):
    name = TMP_PREFIX + os.urandom(8).hex()
    try:
        fd = os.open(name, os.O_WRONLY | os.O_CREAT | os.O_EXCL | os.O_NOFOLLOW, 0o600, dir_fd=tel_fd)
        with os.fdopen(fd, "w", encoding="utf-8") as fh:
            for r in sorted(records.values(), key=lambda r: (r["started"], r["tool_use_id"])):
                fh.write(json.dumps(r, sort_keys=True, separators=(",", ":")) + "\n")
            fh.flush()
            os.fsync(fh.fileno())
        os.replace(name, STORE, src_dir_fd=tel_fd, dst_dir_fd=tel_fd)
    except OSError:
        die("the store cannot be written")


# ---- attribution -----------------------------------------------------------------------------------

def load_ledger_parser(here):
    sys.dont_write_bytecode = True
    spec = importlib.util.spec_from_file_location("ledger_metrics", os.path.join(here, "ledger-metrics.py"))
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    return mod


def cycles_from_history(cwd, lm):
    rc, out = git(("-c", "log.showSignature=false", "-c", "i18n.logOutputEncoding=UTF-8", "log", "--all",
                   "--no-show-signature", "-z", "--format=%H %ct%n%B"), cwd)
    if rc != 0:
        die("git log failed")
    provs, others = {}, {}
    for rec in out.decode("utf-8", "replace").split("\0"):
        for line in rec.split("\n"):
            if not lm.CANDIDATE.match(line):
                continue
            parsed = lm.parse_record(line)
            if parsed is None or parsed[0] == "none (pre-rule)":
                continue
            field, typ, data = parsed
            if typ == "prov":
                provs.setdefault(field, {})[line] = data
            else:
                others.setdefault(field, set()).add(line)
    return provs, others


def classify(nonce, provs, others):
    p = provs.get(nonce, {})
    if len(p) > 1 or len(others.get(nonce, ())) > 1:
        return "conflicting", None
    if len(p) == 1:
        data = next(iter(p.values()))
        if data["entries"] is None:
            return "no story", None
        return "confirmed", tuple(path for path, _lv in data["entries"])
    return "open", None


# ---- report ----------------------------------------------------------------------------------------

def total(values, fmt):
    known = [v for v in values if v is not None]
    return "%s (? %d of %d)" % (fmt(sum(known)) if known else "?", len(values) - len(known), len(values))


def ranges(nums):
    out, i = [], 0
    while i < len(nums):
        j = i
        while j + 1 < len(nums) and nums[j + 1] == nums[j] + 1:
            j += 1
        out.append(str(nums[i]) if i == j else "%d-%d" % (nums[i], nums[j]))
        i = j + 1
    return ",".join(out)


def group_line(recs, nonce=None):
    """One summary line; with a nonce, only that cycle's slots give pass numbers."""
    passes = sorted({int(m.group(2) or m.group(4)) for r in recs for s in r["slots"]
                     for m in [RE_SLOT.fullmatch(s)] if nonce is None or (m.group(1) or m.group(3)) == nonce})
    parts = ["calls %d" % len(recs), "passes %s" % (ranges(passes) or "-"),
             "duration_s %s" % total([r["duration_s"] for r in recs], lambda x: "%.1f" % x)]
    for f in TOKEN_FIELDS:
        parts.append("%s %s" % (f, total([r[f] for r in recs], str)))
    return "  ".join(parts)


def nonces_of(r):
    return sorted({m.group(1) or m.group(3) for s in r["slots"] for m in [RE_SLOT.fullmatch(s)]
                   if m.group(1) or m.group(3)})


def main(argv):
    keep = KEEP_DAYS_DEFAULT
    args = argv[1:]
    if args:
        if len(args) != 2 or args[0] != "--keep-days" or not re.fullmatch(r"[1-9][0-9]{0,4}", args[1]) \
                or int(args[1]) > 36500:
            die("--keep-days must be an integer from 1 to 36500")
        keep = int(args[1])
    cwd = os.getcwd()
    rc, out = git(("--version",), cwd)
    m = re.search(rb"(\d+)\.(\d+)", out) if rc == 0 else None
    if not m or (int(m.group(1)), int(m.group(2))) < (2, 36):
        die("git 2.36 or later is required")
    mine = common_dir(cwd)
    if mine is None:
        die("not a git repository")
    rc, out = git(("worktree", "list", "--porcelain", "-z"), cwd)
    if rc != 0:
        die("git worktree list failed")
    main_wt, bare = None, False
    for f in out.split(b"\0"):
        if f.startswith(b"worktree ") and main_wt is None:
            main_wt = os.fsdecode(f[len(b"worktree "):])
        elif f == b"bare" and main_wt is not None:
            bare = True
        elif f == b"" and main_wt is not None:
            break
    if main_wt is None or bare or not os.path.isdir(main_wt):
        die("main worktree unavailable")

    now = datetime.datetime.now(datetime.timezone.utc).replace(microsecond=0)
    problems, invalid = {}, [0]
    lm = load_ledger_parser(os.path.dirname(os.path.abspath(__file__)))

    main_fd = os.open(main_wt, os.O_RDONLY | os.O_DIRECTORY)
    ctx_fd = open_dir(".context", main_fd, 0o755, ".context")
    tel_fd = open_dir("telemetry", ctx_fd, 0o700, ".context/telemetry")
    os.fchmod(tel_fd, 0o700)
    lock_fd = take_lock(tel_fd)
    for name in os.listdir(tel_fd):
        if name.startswith(TMP_PREFIX):
            try:
                os.unlink(name, dir_fd=tel_fd)
            except OSError:
                pass
    records = load_store(tel_fd)

    calls = scan_transcripts(problems)
    sid_users = {}
    for c in calls.values():
        for v in call_session_ids(envelope(c["result"])) + call_session_ids(c["input"]):
            sid_users.setdefault(v, set()).add(c["id"])
    sessions = scan_codex(problems, set(sid_users))

    added = pending = not_here = malformed = 0
    member_cache = {}
    for c in calls.values():
        wd = c["input"].get("workingDirectory")
        if not isinstance(wd, str) or not os.path.isabs(wd) or not os.path.isdir(wd):
            not_here += 1
            continue
        if wd not in member_cache:
            member_cache[wd] = common_dir(wd) == mine
        if not member_cache[wd]:
            not_here += 1
            continue
        if c["id"] in records:
            continue
        rec = build_record(c, sessions, sid_users, now, invalid)
        if rec is None:
            malformed += 1
        elif rec == "pending":
            pending += 1
        else:
            records[c["id"]] = rec
            added += 1

    cutoff = now - datetime.timedelta(days=keep)
    expired = [k for k, r in records.items() if parse_ts(r["started"]).replace(microsecond=0) < cutoff]
    for k in expired:
        del records[k]
    write_store(tel_fd, records)
    os.close(lock_fd)

    provs, others = cycles_from_history(cwd, lm)
    rc, out = git(("rev-parse", "--is-shallow-repository"), cwd)
    shallow = out.strip() == b"true"
    recs = list(records.values())
    by_class = {"confirmed": {}, "no story": {}, "open": {}, "conflicting": {}}
    no_nonce, no_slot, stories = [], [], {}
    for r in recs:
        if not r["slots"]:
            no_slot.append(r)
            continue
        nonces = nonces_of(r)
        if not nonces:
            no_nonce.append(r)
            continue
        for n in nonces:
            cls, story_set = classify(n, provs, others)
            by_class[cls].setdefault(n, []).append(r)
            for sp in story_set or ():
                stories.setdefault(sp, set()).add(n)

    lines = ["run-analytics — read-only report over gate calls",
             "store: .context/telemetry/gate-calls.jsonl (in the main worktree)",
             "records stored %d  added this run %d  deleted by retention (%d days) %d" % (
                 len(recs), added, keep, len(expired)),
             "pending calls %d  calls not stored (not in this clone) %d  malformed calls %d  "
             "values that failed their checks this run %d" % (pending, not_here, malformed, invalid[0]),
             "stored records: no result or no valid end %d  tokens unknown %d (%s)" % (
                 sum(r["ended"] is None for r in recs), sum(any(r[f] is None for f in TOKEN_FIELDS) for r in recs),
                 ", ".join("%s %d" % (k, sum(r["tokens_unknown"] == k for r in recs)) for k in UNKNOWN_REASONS)),
             "skipped sources: %s" % (", ".join("%s %d" % (shown(k), v) for k, v in sorted(problems.items()))
                                      or "none"),
             "history searched: git log --all%s" % ("  (shallow: closing commits may be missing)" if shallow else ""),
             "class counts are (record, nonce) pairs plus one per record without a nonce:",
             "  confirmed %d  no story %d  open %d  conflicting %d  no nonce %d  no slot %d" % (
                 sum(map(len, by_class["confirmed"].values())), sum(map(len, by_class["no story"].values())),
                 sum(map(len, by_class["open"].values())), sum(map(len, by_class["conflicting"].values())),
                 len(no_nonce), len(no_slot)),
             "pass numbers count what calls wrote; they are not gate verdicts",
             "", "== Attributed effort, per story (closed cycles only; not the story's full cost; "
                 "stories sharing a cycle overlap)"]
    if not stories:
        lines.append("none")
    for sp in sorted(stories):
        ns = sorted(stories[sp])
        lines.append(shown(sp))
        lines.append("  total  " + group_line([r for n in ns for r in by_class["confirmed"][n]]))
        for n in ns:
            lines.append("  cycle %s  %s" % (n, group_line(by_class["confirmed"][n], n)))
    lines += ["", "== Unattributed effort"]
    for title, groups in (("cycles without a story", by_class["no story"]), ("open", by_class["open"]),
                          ("conflicting", by_class["conflicting"])):
        lines.append(title + ":")
        if not groups:
            lines.append("  none")
        for n in sorted(groups):
            lines.append("  cycle %s  %s" % (n, group_line(groups[n], n)))
    for title, group in (("no nonce", no_nonce), ("no slot", no_slot)):
        lines.append(title + ":")
        lines.append("  " + group_line(group) if group else "  none")
    lines += ["", CANNOT]
    sys.stdout.buffer.write(("\n".join(lines) + "\n").encode("utf-8", "backslashreplace"))
    sys.stdout.flush()
    return 0


if __name__ == "__main__":
    if hasattr(sys, "set_int_max_str_digits"):
        sys.set_int_max_str_digits(0)  # one integer limit on every Python; the slot grammar has none
    try:
        sys.exit(main(sys.argv))
    except OSError as e:
        die("filesystem error: %s" % (e.strerror or type(e).__name__))
````

- [ ] **Step 4: Run the suite under both shells, reading each status**

Run: `sh scripts/run-analytics.test.sh > /tmp/ra-sh.log 2>&1; echo "sh=$?"; dash scripts/run-analytics.test.sh > /tmp/ra-dash.log 2>&1; echo "dash=$?"; tail -1 /tmp/ra-sh.log /tmp/ra-dash.log`
Expected: `sh=0`, `dash=0`, `31 passed, 0 failed` in both (measured on the prototype 2026-10-02).

- [ ] **Step 5: Lint the suite**

Run: `shellcheck --shell=sh --exclude=SC2015 scripts/run-analytics.test.sh; echo "lint=$?"`
Expected: `lint=0`.

No commit (Task 3 makes the single Gate-B snapshot).

---

### Task 2: Battery, CI and docs

**Files:** Modify `AGENTS.md`, `.github/workflows/ci.yml`, `README.md`.

- [ ] **Step 1: Find every place that enumerates the executables, reports or suites**

```sh
grep -rnE 'two Python reports|Python metrics report|untyped Python|four suites|five suites|metrics report.s suite|two reports' --include='*.md' --include='*.yml' . | grep -vE 'source-files/|docs/superpowers/|\.context/|hardening-log|CHANGELOG'
```
Expected (2026-10-02), five hits:
- `AGENTS.md:260`, the typecheck row ("one untyped Python report"), is edited below.
- `.github/workflows/ci.yml:40` and `README.md:163` count the reports or suites; both are edited below.
- `.github/workflows/ci.yml:73` and `AGENTS.md:274` describe the ledger-metrics suite only, and stay
  true. The `AGENTS.md` prerequisites line gains a sentence about `run-analytics.py` below.

Any other hit is a stop.

The Boundaries paragraph says which directories load by convention. AGENTS.md's Don'ts therefore require a manifest read before editing it. Run `cat plugins/dev-workflow/.claude-plugin/plugin.json` and confirm it declares no component keys. Then run the census from AGENTS.md's Don'ts:
`grep -rniE 'declare[sd]?|convention[- ]load' --include='*.md' . | grep -v source-files/`
Read every hit in the files this task edits, and confirm none of them becomes false. The edit below adds no claim about declarations; it only adds the second report.

- [ ] **Step 2: Apply the edits**

Save this as a temporary file outside the repository and run it from the repository root with `python3`. It writes nothing unless every replacement matches exactly once.

```python
# Applies the Task 2 documentation and CI edits. Every replacement must match exactly
# once, or the script stops before writing anything.
import sys
edits = {
 "AGENTS.md": [
  ("scripts/ledger-metrics.test.sh    # its regression suite — fixture repos, expected text\n",
   "scripts/ledger-metrics.test.sh    # its regression suite — fixture repos, expected text\n"
   "scripts/run-analytics.py          # gate-call effort from local logs (vision step 2c, part 1)\n"
   "scripts/run-analytics.test.sh     # its regression suite — fixture home + repos, expected text\n"),
  ("`scripts/check-version-bump.{sh,test.sh}`), plus the read-only Python report\n"
   "`scripts/ledger-metrics.py` and its suite `scripts/ledger-metrics.test.sh` — the hook ships\n"
   "in the plugin, the checkers and the report do not;",
   "`scripts/check-version-bump.{sh,test.sh}`), plus two Python reports with their suites:\n"
   "`scripts/ledger-metrics.{py,test.sh}` (read-only) and `scripts/run-analytics.{py,test.sh}`\n"
   "(writes only its own store under `.context/telemetry/`) — the hook ships in the plugin, the\n"
   "checkers and the reports do not;"),
  ("shellcheck --shell=sh --exclude=SC2015 scripts/ledger-metrics.test.sh && HOOK_SH=sh",
   "shellcheck --shell=sh --exclude=SC2015 scripts/ledger-metrics.test.sh && shellcheck --shell=sh --exclude=SC2015 scripts/run-analytics.test.sh && HOOK_SH=sh"),
  ("shellcheck --shell=sh --exclude=SC2015 scripts/ledger-metrics.test.sh` |",
   "shellcheck --shell=sh --exclude=SC2015 scripts/ledger-metrics.test.sh && shellcheck --shell=sh --exclude=SC2015 scripts/run-analytics.test.sh` |"),
  ("sh scripts/ledger-metrics.test.sh && claude plugin validate . --strict` |",
   "sh scripts/ledger-metrics.test.sh && sh scripts/run-analytics.test.sh && claude plugin validate . --strict` |"),
  ("| typecheck | n/a — no typed sources (shell, one untyped Python report, markdown) |",
   "| typecheck | n/a — no typed sources (shell, two untyped Python reports, markdown) |"),
  ("system interpreter, not a pinned tool.\n",
   "system interpreter, not a pinned tool. `scripts/run-analytics.py` also needs git 2.36 or later\n"
   "and checks for it.\n"),
 ],
 ".github/workflows/ci.yml": [
  ("      # The hook, the two checkers, the Python metrics report and their four suites are\n",
   "      # The hook, the two checkers, the two Python reports and their five suites are\n"),
  ("            --shell=sh --exclude=SC2015 scripts/ledger-metrics.test.sh\n",
   "            --shell=sh --exclude=SC2015 scripts/ledger-metrics.test.sh\n"
   "          # The run-analytics suite (vision step 2c, part 1), linted the same way.\n"
   "          docker run --rm -v \"$PWD:/mnt\" -w /mnt koalaman/shellcheck:v0.11.0 \\\n"
   "            --shell=sh --exclude=SC2015 scripts/run-analytics.test.sh\n"),
  ("          sh scripts/ledger-metrics.test.sh\n\n",
   "          sh scripts/ledger-metrics.test.sh\n          sh scripts/run-analytics.test.sh\n\n"),
 ],
 "README.md": [
  ("both checkers' regression suites, the metrics report's suite, and\n`claude plugin validate . --strict`.\n",
   "both checkers' regression suites, the two reports' suites, and\n`claude plugin validate . --strict`.\n"),
  ("followed, and each cycle's recorded curve beside the `fic2` baseline. It writes nothing.\n",
   "followed, and each cycle's recorded curve beside the `fic2` baseline. It writes nothing.\n\n"
   "`python3 scripts/run-analytics.py` reads the Claude Code transcripts and Codex session logs\n"
   "on this machine and reports how many gate calls each review cycle and story took, how long\n"
   "they ran and how many tokens they used, including effort no closed cycle accounts for. It\n"
   "keeps numbers and identifiers only, in `.context/telemetry/` of this clone, for 365 days.\n"),
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

`sh -c '<row>' > /tmp/ra-quality.log 2>&1; echo "quality=$?"`. Expected: `quality=0`, with `31 passed, 0 failed` from the new suite (measured on a copy 2026-10-02).

No commit.

---

### Task 3: Evidence, Gate B, close

- [ ] **Step 1: Base check.** `git fetch origin; echo "fetch=$?"`, then `git merge-base --is-ancestor origin/main HEAD; echo "anc=$?"`. Anything but `fetch=0` and `anc=0` is a stop: ask Daniel.

- [ ] **Step 2: Stage and snapshot.** `git add scripts/run-analytics.py scripts/run-analytics.test.sh AGENTS.md .github/workflows/ci.yml README.md && git diff --cached --name-only` — exactly those five paths. Then, as its own one-line tool call: `git commit -m 'WIP: run analytics candidate'`.

- [ ] **Step 3: Evidence run.** Record `git rev-parse HEAD`, and check `git status --porcelain --untracked-files=no` prints nothing. Check `test "$(git rev-parse main)" = "$(git rev-parse origin/main)"`; non-zero is a stop. Run the quality row verbatim (exit 0) and `dash scripts/run-analytics.test.sh` (exit 0, `31 passed, 0 failed`). `git ls-tree f9aae57 -- scripts/run-analytics.py` must print nothing. Then repeat the HEAD and status checks.

Evidence entry for the commit body:

```
Evidence — docs/superpowers/stories/2026-10-02-run-analytics-trace-id-and-retention-story.md
Battery: AGENTS.md quality row, exit 0 at <headSha>.
Check (counterfactual): at f9aae57 no collector exists (git ls-tree prints nothing).
Negative controls in the suite: a copy that stores reply text fails the no-text check;
a copy without the membership test stores another repository's call. Suite 31/31 under
sh (in the quality row) and under dash.
```

- [ ] **Step 4: Gate B.** CLAUDE.md §5: new nonce; floor 3 (story `standard`/`standard`). Security lens set: assets, trust boundaries, roles, external systems, abuse paths. Check `mcp__codex__health` → `gpt-6-astra` first; anything else is a stop. `baseSha` = parent of the WIP commit, as its full 40-character name. Resolve `headSha` to its full 40-character name immediately before each call. Keep the `baseSha`/`headSha` pair with each branch's result, and sum the two branches into one logical pass only if both pairs are exactly equal. Otherwise the earlier branch is incomplete (CLAUDE.md §5 Mechanics). Run two calls, `spec` then `quality`. Each carries the story path, the evidence entry verbatim, the ten rulings, and the standing lens, naming what changes: the executable and suite counts, the CI step, the AGENTS.md rows and prerequisites, and README. Fixes: `git add`, then `git commit --amend -m 'WIP: run analytics candidate'` as its own one-line tool call, then an evidence run, then re-review.

- [ ] **Step 5: Close and PR.** When the §5 closure ordering allows it: evidence run again; `git log --format='%h %s' origin/main..HEAD` shows the WIP commit over the plan's Gate-A closing commit (which carries this plan), then `f9aae57`, `9fb981f`, `a120f9a`, with nothing staged — any other shape is a stop. Then `git commit --amend -m "<real message>"` with the evidence entry, the provenance line, the curve and the logical-pass prose, and no trailers. Push, open a PR, and read CI's log for `31 passed, 0 failed`.

## Self-review (2026-10-02)

- **Spec coverage:** §2–§3 → `scan_transcripts`, `scan_codex`, `build_record`, `measure_tokens`. §4 → `common_dir`, the worktree parsing, `open_dir`, `take_lock`, `load_store`, retention and `write_store`. §5 → `cycles_from_history`, `classify`. §6 → `main`'s report. §7 → the suite. §8 → `CANNOT`.
- **Story ACs (as narrowed):**
  - 1 → the store fields, with unknown as `null` and printed `?`;
  - 2 → `classify` and the class counts;
  - 3 → trace ID = story path (spec §5; nothing to build);
  - 4 → the no-text check and its negative control;
  - 5 → the store under `.context/`, plus retention;
  - 6 → skipped sources counted, exit 0;
  - 7 → `CANNOT`'s money line.
- **Placeholders:** `<headSha>`, `<real message>` and `<row>` are filled in at run time.
