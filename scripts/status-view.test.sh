#!/bin/sh
# Regression suite for scripts/status-view.py (spec: docs/superpowers/specs/2026-10-06-process-monitoring-status-view-design.md
# §9). Fixture repositories and a fixture HOME are built in a temporary directory; a Python driver
# runs the report through main(argv, hooks) and checks the page, the cache and the files around them.
# The last block runs selected cases against mutants of the script, each of which must fail.
# Usage: sh scripts/status-view.test.sh
set -u
here=$(cd "$(dirname "$0")" && pwd)
work=$(mktemp -d)
trap 'chmod -R u+rwx "$work" 2>/dev/null; rm -rf "$work"' EXIT INT TERM
for v in GIT_DIR GIT_WORK_TREE GIT_COMMON_DIR GIT_INDEX_FILE GIT_OBJECT_DIRECTORY GIT_ALTERNATE_OBJECT_DIRECTORIES \
         GIT_CEILING_DIRECTORIES GIT_DISCOVERY_ACROSS_FILESYSTEM GIT_NAMESPACE; do unset "$v"; done
GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_NOSYSTEM=1
export GIT_CONFIG_GLOBAL GIT_CONFIG_NOSYSTEM

passed=0
failed=0
pass() { printf 'PASS %s\n' "$1"; passed=$((passed + 1)); }
fail() { printf 'FAIL %s\n' "$1"; failed=$((failed + 1)); }

cat > "$work/driver.py" <<'PY'
import datetime, fcntl, hashlib, importlib.util, json, os, re, shutil, subprocess, sys

WORK, SCRIPT, ONLY = sys.argv[1], sys.argv[2], set(sys.argv[3:])
HOME = os.path.join(WORK, "home")
os.environ["HOME"] = HOME
NOW = datetime.datetime.now(datetime.timezone.utc).replace(microsecond=0)
T = lambda hours: (NOW - datetime.timedelta(hours=hours)).strftime("%Y-%m-%dT%H:%M:%S.000Z")
STORY = "docs/superpowers/stories/2026-01-01-s-story.md"
STORY2 = "docs/superpowers/stories/2026-01-02-t-story.md"
CS = "11111111-1111-1111-1111-111111111111"
CS2 = "22222222-2222-2222-2222-222222222222"
S1 = "aaaaaaaa-0000-0000-0000-000000000001"
S2 = "aaaaaaaa-0000-0000-0000-000000000002"
S3 = "aaaaaaaa-0000-0000-0000-000000000003"
tick = [1767225600]  # 2026-01-01


def git(repo, *args, date=True):
    env = dict(os.environ, GIT_AUTHOR_NAME="t", GIT_AUTHOR_EMAIL="t@t", GIT_COMMITTER_NAME="t",
               GIT_COMMITTER_EMAIL="t@t")
    if date:
        tick[0] += 60
        env["GIT_AUTHOR_DATE"] = env["GIT_COMMITTER_DATE"] = "@%d +0000" % tick[0]
    return subprocess.run(("git",) + args, cwd=repo, env=env, check=True, stdout=subprocess.PIPE,
                          stderr=subprocess.PIPE).stdout.decode().strip()


def put(repo, rel, text):
    p = os.path.join(repo, rel)
    os.makedirs(os.path.dirname(p), exist_ok=True)
    with open(p, "w") as fh:
        fh.write(text)


def commit(repo, msg, *paths):
    git(repo, "add", "-A", *paths) if paths else git(repo, "add", "-A")
    git(repo, "commit", "-q", "-m", msg)
    return git(repo, "rev-parse", "HEAD", date=False)


def mkrepo(name, main=True):
    repo = os.path.join(WORK, name)
    os.makedirs(os.path.join(repo, "scripts"))
    git(repo, "init", "-q", "-b", "main" if main else "trunk")
    for f in ("run-analytics.py", "ledger-metrics.py", "loop-usefulness.py"):
        shutil.copy(os.path.join(os.path.dirname(SCRIPT), f), os.path.join(repo, "scripts", f))
    shutil.copy(SCRIPT, os.path.join(repo, "scripts", "status-view.py"))
    put(repo, ".gitignore", ".context/*\n")
    put(repo, "README.md", "readme\n")
    put(repo, "CLAUDE.md", "rules\n")
    put(repo, "AGENTS.md", "agents\n")
    put(repo, "plugins/dev-workflow/.claude-plugin/plugin.json", '{"name": "dev-workflow", "version": "0.18.0"}\n')
    put(repo, "scripts/old.sh", "one\ntwo\nthree\n")
    put(repo, "scripts/gone.sh", "bye\n")
    put(repo, "scripts/keep.test.sh", "t\n")
    commit(repo, "initial")
    git(repo, "checkout", "-q", "-b", "feature")
    return repo


def line(obj):
    return json.dumps(obj) + "\n"


def use(uid, ts, repo, sid, tool="mcp__codex__exec", inp=None):
    i = {"workingDirectory": repo, "instruction": "MARKER_INPUT please"}
    i.update(inp or {})
    return line({"type": "assistant", "timestamp": ts, "sessionId": sid, "cwd": repo,
                 "message": {"content": [{"type": "tool_use", "id": uid, "name": tool, "input": i}]}})


def result(uid, ts, sid, summary, csid=CS):
    env = {"success": True, "sessionId": csid, "output": {"summary": summary, "other": "MARKER_RESULT"}}
    return line({"type": "user", "timestamp": ts, "sessionId": sid,
                 "message": {"content": [{"type": "tool_result", "tool_use_id": uid,
                                          "content": [{"type": "text", "text": json.dumps(env)}]}]}})


def skill(ts, sid, repo, version, name="intake"):
    return line({"type": "user", "isMeta": True, "timestamp": ts, "sessionId": sid, "cwd": repo,
                 "message": {"content": [{"type": "text", "text": "Base directory for this skill: /h/.claude/plugins/cache/"
                                          "dev-workflow-kit/dev-workflow/%s/skills/%s\n\nMARKER_TEXT body" % (version, name)}]}})


def mention(ts, sid, repo, version):
    return line({"type": "user", "timestamp": ts, "sessionId": sid, "cwd": repo,
                 "message": {"content": [{"type": "text", "text": "Base directory for this skill: /x/plugins/cache/dev-workflow-kit/dev-workflow/%s/skills/intake MARKER_TEXT" % version}]}})


def codex_log(name, csid, start, end, model="gpt-x"):
    d = os.path.join(HOME, ".codex", "sessions", "2026")
    os.makedirs(d, exist_ok=True)
    with open(os.path.join(d, "rollout-%s.jsonl" % name), "w") as fh:
        fh.write(line({"type": "session_meta", "timestamp": start, "payload": {"session_id": csid, "timestamp": start}}))
        fh.write(line({"type": "turn_context", "timestamp": start, "payload": {"model": model}}))
        fh.write(line({"type": "event_msg", "timestamp": end, "payload": {"type": "token_count", "info": {
            "total_token_usage": {"input_tokens": 100, "cached_input_tokens": 10, "output_tokens": 5,
                                  "reasoning_output_tokens": 1, "MARKER_NESTED": "MARKER_NESTED"}}}}))


def transcript(name, text, project="-fixture"):
    d = os.path.join(HOME, ".claude", "projects", project)
    os.makedirs(d, exist_ok=True)
    with open(os.path.join(d, name), "w") as fh:
        fh.write(text)
    return os.path.join(d, name)


def installed(*records):
    d = os.path.join(HOME, ".claude", "plugins")
    os.makedirs(d, exist_ok=True)
    with open(os.path.join(d, "installed_plugins.json"), "w") as fh:
        json.dump({"version": 2, "plugins": {"dev-workflow@dev-workflow-kit": list(records)}}, fh)


def rec(version, scope="user"):
    return {"scope": scope, "version": version, "lastUpdated": "2026-01-01T00:00:00Z", "gitCommitSha": "abc",
            "installPath": "/x", "installedAt": "2026-01-01T00:00:00Z"}


def load():
    spec = importlib.util.spec_from_file_location("sv_%d" % len(sys.modules), SCRIPT)
    m = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(m)
    return m


SV = load()


def run(repo, *args, hooks=None):
    old = os.getcwd()
    os.chdir(repo)
    try:
        rc = SV.main(["status-view.py"] + list(args), hooks or {})
    finally:
        os.chdir(old)
    return rc


def page(repo):
    with open(os.path.join(repo, ".context", "status", "index.html")) as fh:
        return fh.read()


def text(repo):
    import html
    t = re.sub(r"<script.*?</script>|<style.*?</style>", "", page(repo), flags=re.S)
    return html.unescape(re.sub(r"<[^>]+>", " ", t))


def fmt_mtime(path):
    return datetime.datetime.fromtimestamp(os.stat(path).st_mtime, datetime.timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")


def section_of(t, title):
    m = re.search(re.escape(title) + r"(.*?)(?=Current work|Evidenced progress|Open points|Effort|Artifact growth|Workflow version|No completion figure)", t, re.S)
    return m.group(1) if m else ""


results = []


def check(name, cond, why=""):
    if ONLY and name.split(":")[0] not in ONLY:
        return
    results.append((name, bool(cond), why))


def wanted(*names):
    return not ONLY or any(n in ONLY for n in names)


def rmhome():
    shutil.rmtree(HOME, ignore_errors=True)
    os.makedirs(HOME)


# ---- repository A: the rich case ---------------------------------------------------------------------
rmhome()
installed(rec("0.17.0"))
A = mkrepo("A")
put(A, STORY, "# S\n\n## 5. Open questions\n- Which colour? <script>alert(1)</script>\n")
commit(A, "story")
put(A, "docs/superpowers/specs/2026-01-01-s-design.md", "# S design\n\n**Story:** `%s`\n\nbody\n- **Unaccounted:** the colour → blocks the plan\n" % STORY)
commit(A, "spec")
commit_body = ("spec closed\n\ncycle abcdefgh12; floor 3 per {%s (level 1)}; hook reminder threshold absent\n"
               "cycle abcdefgh12; Gate-A spec (passes 1-2, gpt-x): Findings 3,0. Blockers 0,0. Majors 1,0.\n" % STORY)
git(A, "commit", "-q", "--allow-empty", "-m", commit_body)
put(A, "docs/superpowers/plans/2026-01-01-s.md", "# S plan\n\n**Story:** `%s`\n" % STORY)
commit(A, "plan")
git(A, "commit", "-q", "--allow-empty", "-m", "WIP: snapshot")
git(A, "commit", "-q", "--allow-empty", "-m",
    "other\n\ncycle cccccccc12; Gate-A plan (passes 1, gpt-x): Findings 1. Blockers 0. Majors 0.\n")
git(A, "commit", "-q", "--allow-empty", "-m",
    "conf\n\ncycle dddddddd12; floor 3 per {%s (level 1)}; hook reminder threshold absent\n"
    "cycle dddddddd12; floor 1 per {%s (level 0)}; hook reminder threshold absent\n"
    "cycle dddddddd12; Gate-A plan (passes 1, gpt-x): Findings 0. Blockers 0. Majors 0.\n" % (STORY, STORY))
git(A, "commit", "-q", "--allow-empty", "-m",
    "skip\n\ncycle eeeeeeee12; floor 1 per {%s (level 0)}; hook reminder threshold absent\n"
    "cycle eeeeeeee12; Gate B: skipped (see skip reason)\nSkip reason: docs only.\n" % STORY2)
put(A, STORY2, "# T\n\n## 5. Open questions\n- None.\n\n**Unaccounted:** the plain-paragraph marker\n")
put(A, "scripts/old.sh", "one\n")
os.remove(os.path.join(A, "scripts/gone.sh"))
put(A, "scripts/new.py", "print(1)\n")
put(A, "scripts/new.test.sh", "x\n")
commit(A, "growth")
put(A, "scripts/untracked.txt", "u\n")
put(A, "README.md", "readme changed\n")
put(A, ".context/handover-a.md", "# H\n\n## Next task\nImplement S, see %s\n\n## Unresolved decisions\n- None.\n" % STORY)
tA = transcript("a.jsonl",
                use("toolu_A1", T(2), A, S1) + result("toolu_A1", T(1.9), S1, "gate-a-spec | pass 1 | 3 findings | .context/codex-reviews/gate-a-spec-abcdefgh12-pass-1.md")
                + use("toolu_A2", T(7), A, S1) + skill(T(1.5), S1, A, "0.18.0") + mention(T(1.4), S1, A, "0.9.0")
                + use("toolu_A3", T(1.2), A, S1) + result("toolu_A3", T(1.1), S1, "INCOMPLETE | write failed | .context/codex-reviews/gate-a-spec-zzzzzzzz11-pass-1.md", CS2))
codex_log("a", CS, T(2), T(1.95), model='"MARKER_MODEL quoted"')
transcript("b.jsonl", skill(T(3), S2, A, "0.16.0") + skill(T(2.5), S2, A, "0.17.0", "harden-finding"))
transcript("other.jsonl", skill(T(0.5), S3, "/somewhere/else", "0.1.0"), "-other")

before_home = {}
for d, _, fs in os.walk(HOME):
    for f in fs:
        p = os.path.join(d, f)
        before_home[p] = hashlib.sha1(open(p, "rb").read()).hexdigest()


def repo_snapshot(repo):
    out = {}
    for d, dirs, fs in os.walk(repo):
        if os.path.relpath(d, repo).startswith((".context" + os.sep + "status", ".git")) or \
                os.path.relpath(d, repo) in (".git", os.path.join(".context", "status")):
            dirs[:] = []
            continue
        for f in fs:
            p = os.path.join(d, f)
            out[p] = hashlib.sha1(open(p, "rb").read()).hexdigest()
    return out


os.utime(os.path.join(A, "AGENTS.md"), None)  # stat-dirty, content unchanged: git status would refresh the index
snapA = repo_snapshot(A)
index_before = open(os.path.join(A, ".git", "index"), "rb").read()
rc = run(A)
index_after = open(os.path.join(A, ".git", "index"), "rb").read()
tA_page = text(A)
check("run:A one-shot exit 0", rc == 0, rc)
work_s = section_of(tA_page, "Current work")
check("c1:phase plan written, activity unknown", "last evidenced phase:  plan written" in work_s and "current activity unknown" in work_s, work_s[:400])
check("c2:WIP is an observation", "Gate-B snapshot" in work_s and "review state unknown" in work_s and "Gate B closed" not in work_s)
check("c2:pending call is an observation", "no result observed since" in tA_page)
prog = section_of(tA_page, "Evidenced progress")
check("c3:conflicting provenance shown as conflicting", "dddddddd12: conflicting (conflicting provenance lines)" in prog, prog[:600])
check("c3:curve without provenance shown as open", "cccccccc12: open (curve without provenance line)" in prog)
check("c3:skip labelled skipped, never closed", "Gate B skipped (reason in commit" in work_s and "Gate B closed" not in tA_page)
check("c4:several candidates -> not established", "current task not established" in work_s and STORY2 in work_s)
check("c4:handover next-task body shown", "Implement S, see" in work_s)
check("c4:unassociated evidence apart", "Unassociated evidence" in work_s and "cccccccc12" in work_s)
op = section_of(tA_page, "Open points")
check("c5:handover none -> source states none", "Unresolved decisions” — source states none" in op, op[:500])
check("c5:story open question shown", "Which colour?" in op and "Unaccounted:" in op)
check("c5:plain-paragraph Unaccounted marker shown", "the plain-paragraph marker" in op)
check("c2b:escaped", "&lt;script&gt;alert(1)" in page(A) and "<script>alert(1)" not in page(A))
gr = section_of(tA_page, "Artifact growth")
for f, st in (("scripts/old.sh", "modified"), ("scripts/gone.sh", "deleted"), ("scripts/new.py", "added"),
              ("scripts/untracked.txt", "added"), ("README.md", "modified")):
    check("c6:%s %s" % (f, st), re.search(re.escape(f) + r"\s+" + st, gr), gr[-900:])
check("c6:shrink shown", re.search(r"scripts/old.sh\s+modified\s+14 → 4 \(-10\)", gr))
check("c6:tests apart from code", re.search(r"tests\s+scripts/new.test.sh", gr) and re.search(r"code\s+scripts/new.py", gr))
check("c6:checkout named, branch comparison", "Checkout: " + os.path.realpath(A) in gr and "not the effort or growth of a single story" in gr)
check("c6:handover first observed", "handover-a.md" in gr and "first observed now" in gr)
ef = section_of(tA_page, "Effort")
check("c11:incomplete reply is an attempt, not a valid pass", re.search(r"zzzzzzzz11 — no closing record observed in this range · gate calls 1 · call slots \(attempts\) 1 · valid passes validity unknown", ef), ef[:800])
check("c9:pending older than 6 h shown", "toolu_A2" in ef)
ve = section_of(tA_page, "Workflow version")
check("c13:mention does not count", "0.9.0" not in ve and "0.1.0" not in ve, ve)
check("c13:two versions in one session -> conflicting", "conflicting (0.16.0, 0.17.0)" in ve)
check("c17:installed, declared, loaded separate; mismatch marked",
      "installed: 0.17.0" in ve and "declared at HEAD: 0.18.0" in ve and "installed 0.17.0 differs from declared 0.18.0" in ve)
check("c16:no percentage, no score", not re.search(r"\d\s*%", tA_page) and "score" not in tA_page.replace("No completion figure and no composite score", ""))
cache = open(os.path.join(A, ".context", "status", "cache.json")).read()
check("c12:no marker in page or cache", "MARKER" not in page(A) and "MARKER" not in cache,
      [m for m in ("MARKER_INPUT", "MARKER_RESULT", "MARKER_TEXT", "MARKER_NESTED", "MARKER_MODEL") if m in page(A) + cache])
check("c18:nothing outside .context/status changed", repo_snapshot(A) == snapA and all(
    hashlib.sha1(open(p, "rb").read()).hexdigest() == h for p, h in before_home.items()))
check("c18:git index not rewritten", index_before == index_after)
check("c4b:effort lists in-range cycles without observed calls", re.search(r"cccccccc12 — Gate-A plan open · no gate call observed", ef), ef[:900])
check("c5b:open points list a cycle without closing record from the logs", "zzzzzzzz11: no closing record observed in this range" in op)
check("c1b:one-shot page has no reload and no age check", "http-equiv" not in page(A) and 'id=age' not in page(A))

# rule file uncommitted
put(A, "CLAUDE.md", "rules changed\n")
run(A)
ve = section_of(text(A), "Workflow version")
check("c17:uncommitted rule file marked", "CLAUDE.md: last commit" in ve and "uncommitted changes" in ve)

# incremental (case 9)
if wanted("c9", "c10"):
    run(A)
    check("c9:unchanged files not read again", "transcripts read 0, from cache 3" in text(A), section_of(text(A), "Effort")[-300:])
    with open(tA, "a") as fh:
        fh.write(result("toolu_A2", T(0.5), S1, "gate-a-spec | pass 2 | 0 findings | .context/codex-reviews/gate-a-spec-abcdefgh12-pass-2.md"))
    run(A)
    ef = section_of(text(A), "Effort")
    check("c9:grown transcript, late result shown", "toolu_A2" not in ef and "abcdefgh12 — Gate-A spec closed · gate calls 2" in ef, ef[:700])
    check("c9:only the changed file was read", "transcripts read 1, from cache 2" in ef)
    t4 = transcript("c.jsonl", use("toolu_A4", T(0.4), A, S1) + result("toolu_A4", T(0.3), S1, "gate-a-plan | pass 1 | 0 findings | .context/codex-reviews/gate-a-plan-ffffffff12-pass-1.md", "33333333-3333-3333-3333-333333333333"))
    run(A)
    ef = section_of(text(A), "Effort")
    check("c9:no Codex log yet -> tokens unknown", re.search(r"ffffffff12.*?tokens_in \? \(\? 1 of 1\)", ef), ef)
    codex_log("c", "33333333-3333-3333-3333-333333333333", T(0.4), T(0.35))
    run(A)
    ef = section_of(text(A), "Effort")
    check("c9:late Codex log fills tokens", re.search(r"ffffffff12.*?tokens_in 100 \(\? 0 of 1\)", ef), ef)
    transcript("d.jsonl", use("toolu_A5", T(0.2), A, S1, inp={"sessionId": "33333333-3333-3333-3333-333333333333"}))
    run(A)
    ef = section_of(text(A), "Effort")
    check("c9:resume elsewhere makes tokens unknown", re.search(r"ffffffff12.*?tokens_in \? \(\? 1 of 1\)", ef), ef)
    os.remove(t4)
    run(A)
    check("c9:deleted file drops out", "ffffffff12" not in text(A))
    # case 10: incomplete reads keep previous facts, stale
    tb = os.path.join(HOME, ".claude", "projects", "-fixture", "b.jsonl")
    with open(tb, "a") as fh:
        fh.write("{not json\n")
    run(A)
    t = text(A)
    check("c10:malformed line -> stale, previous facts kept", "Effort  [stale]" in t and "conflicting (0.16.0, 0.17.0)" in t, section_of(t, "Effort")[:200])
    check("p6:incomplete read names the file, cause and time", re.search(r"refresh at \S+ incomplete — ~/\.claude/projects/-fixture/b\.jsonl: malformed line", t), section_of(t, "Effort")[:300])
    with open(tb, "w") as fh:
        fh.write(skill(T(3), S2, A, "0.16.0") + '{"partial": ')
    run(A)
    check("c10:trailing partial line is not an error", "Effort  [ok]" in text(A))
    os.chmod(tb, 0)
    with open(tA, "a"):
        pass
    os.utime(tb, None)
    run(A)
    check("c10:unreadable file -> stale", "Effort  [stale]" in text(A))
    os.chmod(tb, 0o644)
    sub = os.path.join(HOME, ".claude", "projects", "-fixture")
    os.chmod(sub, 0o300)
    run(A)
    t = text(A)
    check("c10:failed listing -> stale, cached facts kept", "Effort  [stale]" in t and "abcdefgh12" in t)
    os.chmod(sub, 0o755)

# Codex log incomplete reads keep previous facts; a free-text session id never reaches the cache
if wanted("c10", "c12"):
    run(A)
    ef0 = section_of(text(A), "Effort")
    cl = os.path.join(HOME, ".codex", "sessions", "2026", "rollout-a.jsonl")
    with open(cl, "a") as fh:
        fh.write("{broken\n")
    run(A)
    run(A)  # the same malformed log on a second, unchanged refresh stays stale
    t = text(A)
    row = lambda e: (re.search(r"cycle abcdefgh12 — [^\n]*?tokens_reasoning [^·\n]*", e) or re.search("$", "")).group(0)
    check("c10:malformed Codex line keeps the measured facts, stale", "Effort  [stale]" in t and row(ef0) and row(ef0) == row(section_of(t, "Effort")), (row(ef0), row(section_of(t, "Effort"))))
    codex_log("a", CS, T(2), T(1.95), model='"MARKER_MODEL quoted"')
    run(A)
    ef0 = section_of(text(A), "Effort")
    good = open(cl).read()
    with open(cl, "w") as fh:
        fh.write("{corrupt first line\n" + good.split("\n", 1)[1])
    run(A)
    t = text(A)
    check("c10:corrupted session_meta keeps the measured facts, stale", "Effort  [stale]" in t and row(ef0) == row(section_of(t, "Effort")), (row(ef0), row(section_of(t, "Effort"))))
    with open(cl, "w") as fh:
        fh.write(good)
    d = os.path.join(HOME, ".codex", "sessions", "2026")
    with open(os.path.join(d, "rollout-free.jsonl"), "w") as fh:
        fh.write(line({"type": "session_meta", "payload": {"session_id": "MARKER_SID free text"}}))
    run(A)
    check("c12:free-text Codex session id not cached", "MARKER" not in open(os.path.join(A, ".context", "status", "cache.json")).read())
    # one unreadable source: only its sections go stale, the page is still published
    ho = os.path.join(A, ".context", "handover-a.md")
    rc = run(A, "--watch", "5", hooks={"iterations": 2, "sleep": lambda s: None, "after_collection": lambda: os.chmod(ho, 0)})
    t = text(A)
    check("c10:unreadable handover stales only its sections", rc == 0 and "Open points  [stale]" in t and "Current work  [stale]" in t and "Evidenced progress  [ok]" in t, t[:400])
    os.chmod(ho, 0o644)
    pj = os.path.join(HOME, ".claude", "plugins", "installed_plugins.json")
    keep = open(pj).read()

    def spoil():
        with open(pj, "w") as fh:
            fh.write("{not json")
    run(A, "--watch", "5", hooks={"iterations": 2, "sleep": lambda s: None, "after_collection": spoil})
    t = text(A)
    check("c10:malformed installed_plugins keeps the previous value, stale", "Workflow version  [stale]" in t and "installed: 0.17.0" in t and "declared at HEAD" in t, section_of(t, "Workflow version")[:300])
    asof_bad = re.search(r"Workflow version  \[\w+\]\s+as of (\S+)", t).group(1)
    check("p5:retained installed value keeps its own time", asof_bad != fmt_mtime(pj), (asof_bad, fmt_mtime(pj)))
    with open(pj, "w") as fh:
        json.dump({"version": 2, "plugins": {}}, fh)
    run(A)
    ve = section_of(text(A), "Workflow version")
    check("c14:no dev-workflow entry -> installed unknown, other sources shown", "installed: unknown  (no dev-workflow entry)" in ve and "declared at HEAD: 0.18.0" in ve, ve[:300])
    # a broken transcript in the second watch collection: dependents keep their evidence, stale
    tb2 = transcript("z.jsonl", line({"type": "user", "timestamp": T(0.1)}))

    def spoil_t():
        with open(tb2, "w") as fh:
            fh.write(line({"type": "attachment", "timestamp": T(0.1), "attachment": {"type": "invoked_skills", "skills": 7}}) + "{bad\n")
    run(A, "--watch", "5", hooks={"iterations": 2, "sleep": lambda s: None, "after_collection": spoil_t})
    t = text(A)
    check("c10:transcript failure stales open points too, evidence kept", "Open points  [stale]" in t and "zzzzzzzz11: no closing record" in t and "Current work  [stale]" in t, section_of(t, "Open points")[:300])
    os.remove(tb2)
    with open(pj, "w") as fh:
        fh.write(keep)

# handover growth across runs (case 6)
if wanted("c6"):
    put(A, ".context/handover-a.md", "# H\n\n## Next task\nmore text here\n")
    run(A)
    check("c6:handover change since first observed", "since first observed at" in section_of(text(A), "Artifact growth"))
    os.remove(os.path.join(A, ".context/handover-a.md"))
    run(A)
    check("c6:handover deleted stays listed", "handover-a.md: deleted" in text(A))

# installed ambiguous (case 14)
if wanted("c14"):
    installed(rec("0.17.0"), rec("0.18.0"))
    run(A)
    check("c14:several applying records -> ambiguous", "installed: ambiguous (2 applying records)" in text(A))
    installed(rec("0.18.0"))

# lock (case 15)
if wanted("c15"):
    before = page(A)
    fd = os.open(os.path.join(A, ".context", "status", ".lock"), os.O_RDWR)
    fcntl.flock(fd, fcntl.LOCK_EX)
    rc = run(A)
    os.close(fd)
    check("c15:second invocation refused, nothing written", rc == 1 and page(A) == before)

# forced failures in watch mode (spec §2)
if wanted("w1", "w2"):
    hooks_w = {"iterations": 2, "sleep": lambda s: None, "fail": set()}
    hooks_w["after_collection"] = lambda: hooks_w.update(fail={"open"})
    run(A, "--watch", "5", hooks=hooks_w)
    t = text(A)
    check("w1:one failed source stale with original as-of, others ok", "Open points  [stale]" in t and "refresh failed at" in t and "Effort  [ok]" in t, t[:600])
    check("w1:watch page reloads and has the age check", 'http-equiv="refresh" content="5"' in page(A) and "id=age" in page(A))
    hooks_w = {"iterations": 2, "sleep": lambda s: None}

    def boom():
        if hooks_w.get("armed"):
            raise RuntimeError("forced whole failure")
    hooks_w["between"] = boom
    hooks_w["after_collection"] = lambda: hooks_w.update(armed=True)
    run(A, "--watch", "5", hooks=hooks_w)
    t = text(A)
    check("w2:whole failure keeps previous page with a banner", "forced whole failure" in t and "the page below is the previous one" in t and "Current work" in t)
    check("w2:age notice names the last failure", re.search(r"last failure \d{4}-", t))

# HEAD moving during a collection (spec §2)
if wanted("h1"):
    moved = [0]

    def move():
        if moved[0] == 0:
            moved[0] = 1
            git(A, "commit", "-q", "--allow-empty", "-m", "moved")
    run(A, hooks={"between": move})
    head = git(A, "rev-parse", "HEAD", date=False)
    check("h1:moved collection discarded, next one pinned", "HEAD: " + head in text(A))
    # a checkout that leaves and returns during one collection: every read uses the pinned commit
    put(A, "plugins/dev-workflow/.claude-plugin/plugin.json", '{"name": "dev-workflow", "version": "0.19.0"}\n')
    other = commit(A, "bump on a side commit")
    git(A, "reset", "-q", "--hard", head)
    run(A, hooks={"between": lambda: git(A, "checkout", "-q", "--detach", other),
                  "before_check": lambda: git(A, "checkout", "-q", "feature")})
    ve = section_of(text(A), "Workflow version")
    check("h1:transient checkout change reads the pinned commit", "declared at HEAD: 0.18.0" in ve and "declared at HEAD: 0.19.0" not in ve, ve[:300])
    before = page(A)
    rc = run(A, hooks={"between": lambda: git(A, "commit", "-q", "--allow-empty", "-m", "again")})
    check("h1:always moving -> nothing published", rc == 1 and page(A) == before)

# watch keeps the baseline; branch change marked (case 8)
if wanted("c8"):
    base0 = git(A, "merge-base", "HEAD", "main", date=False)

    def advance():
        git(A, "checkout", "-q", "main")
        git(A, "commit", "-q", "--allow-empty", "-m", "main moves")
        git(A, "checkout", "-q", "-b", "other")
    run(A, "--watch", "5", hooks={"iterations": 2, "sleep": lambda s: None, "after_collection": advance})
    t = text(A)
    check("c8:baseline held while main moves", "baseline " + base0 in t)
    check("c8:branch change marked", "branch changed since monitor start (was feature)" in t)

# symlinks (Task 2)
if wanted("s1"):
    outside = os.path.join(WORK, "outside")
    os.makedirs(outside, exist_ok=True)
    B = mkrepo("B")
    os.makedirs(os.path.join(B, ".context"))
    os.symlink(outside, os.path.join(B, ".context", "status"))
    rc = run(B)
    check("s1:symlinked status directory refused", rc == 1 and os.listdir(outside) == [])
    C = mkrepo("C")
    os.makedirs(os.path.join(C, ".context", "status"))
    target = os.path.join(outside, "victim.json")
    with open(target, "w") as fh:
        fh.write("keep")
    os.symlink(target, os.path.join(C, ".context", "status", "cache.json"))
    rc = run(C)
    check("s1:symlinked cache refused, target unchanged", rc == 1 and open(target).read() == "keep")
    for name, kind in (("index.html", "page"), (".lock", "lock")):
        F = mkrepo("F" + kind)
        os.makedirs(os.path.join(F, ".context", "status"))
        os.symlink(target, os.path.join(F, ".context", "status", name))
        rc = run(F)
        check("s1:symlinked %s refused, target unchanged" % kind, rc == 1 and open(target).read() == "keep")
        if kind == "page":
            check("s1:no lock created on refusal", not os.path.lexists(os.path.join(F, ".context", "status", ".lock")))

# one candidate, and no baseline (cases 4, 5, 7)
if wanted("c4", "c5", "c7"):
    rmhome()
    D = mkrepo("D")
    put(D, STORY, "# S\n")
    commit(D, "story")
    run(D)
    check("c4:one candidate -> inferred", "inferred current story (only candidate" in section_of(text(D), "Current work"))
    E = mkrepo("E", main=False)
    transcript("e.jsonl", use("toolu_E1", T(30), E, S1) + use("toolu_E2", T(2), E, S1)
               + result("toolu_E2", T(1.9), S1, "gate-a-spec | pass 1 | 0 findings | .context/codex-reviews/gate-a-spec-gggggggg12-pass-1.md")
               + use("toolu_E3", T(30), E, S1)
               + result("toolu_E3", T(29.9), S1, "gate-a-spec | pass 2 | 0 findings | .context/codex-reviews/gate-a-spec-gggggggg12-pass-2.md"))
    rc = run(E)
    t = text(E)
    check("c7:no baseline -> reason shown", rc == 0 and "no branch main in this repository" in t)
    check("c7:current sizes stay, net change unavailable", "Net change unavailable" in t and re.search(r"code\s+\d+\s+unavailable", t))
    check("c7:recent call and old call without result stay visible", "gggggggg12 — closure and branch attribution unavailable: no baseline · gate calls 1 " in t and "toolu_E1" in t, section_of(t, "Effort")[:400])
    check("c7:current per-file sizes without a baseline", re.search(r"scripts/old.sh\s+current \(no baseline\)\s+unavailable → 14", t))
    check("c5:no source -> unknown", "unknown  — no source of open points could be read" in section_of(t, "Open points"))
    first = git(E, "rev-list", "--max-parents=0", "HEAD", date=False)
    put(E, "scripts/old.sh", "x\n")
    run(E, "--base", first)
    check("c7:--base fills the comparison", re.search(r"scripts/old.sh\s+modified", text(E)))

# pass-3 cases: Codex reads, per-source retention, attachment shapes
if wanted("p3"):
    rmhome()
    installed(rec("0.18.0"))
    R = mkrepo("R")
    put(R, STORY, "# S\n\n## 5. Open questions\n- first\n")
    commit(R, "story")
    put(R, ".context/handover-r.md", "# H\n\n## Open obligations\n- old blocker\n")
    cr = os.path.join(HOME, ".codex", "sessions", "2026", "rollout-r.jsonl")
    tr = transcript("r.jsonl", use("toolu_R1", T(2), R, S1) + result("toolu_R1", T(1.9), S1, "gate-a-spec | pass 1 | 0 findings | .context/codex-reviews/gate-a-spec-rrrrrrrr12-pass-1.md")
                    + line({"type": "attachment", "timestamp": T(1.8), "sessionId": S1, "cwd": R, "attachment": {"type": "invoked_skills", "skills": [{"name": "intake", "path": "/h/.claude/plugins/cache/dev-workflow-kit/dev-workflow/0.16.0/skills/intake"}]}}))
    codex_log("r", CS, T(2), T(1.95))
    rowr = lambda t: (re.search(r"cycle rrrrrrrr12 — [^\n]*?tokens_in [^·\n]*", section_of(t, "Effort")) or re.search("$", "")).group(0)
    steps = []

    def step():
        steps.pop(0)()
    hooks = {"iterations": 2, "sleep": lambda s: None, "after_collection": step}
    good = open(cr).read()

    def wrong_shape():
        with open(cr, "w") as fh:
            fh.write(line({"type": "session_meta", "payload": {"session_id": 7}}) + good.split("\n", 1)[1])
    steps.append(wrong_shape)
    run(R, "--watch", "5", hooks=hooks)
    t = text(R)
    check("p3:wrong-shape session_meta keeps the measured facts, stale", "Effort  [stale]" in t and "tokens_in 100" in rowr(t), rowr(t))
    with open(cr, "w") as fh:
        fh.write(good)

    def complete_then_partial():
        with open(cr, "a") as fh:
            fh.write(line({"type": "event_msg", "timestamp": T(1.95), "payload": {"type": "token_count", "info": {"total_token_usage": {
                "input_tokens": 250, "cached_input_tokens": 10, "output_tokens": 5, "reasoning_output_tokens": 1}}}}) + '{"partial": ')
    steps.append(complete_then_partial)
    run(R, "--watch", "5", hooks=hooks)
    t = text(R)
    check("p3:complete lines before a partial tail are read, not stale", "Effort  [ok]" in t and "tokens_in 250" in rowr(t), rowr(t))

    def malformed_then_partial():
        with open(cr, "a") as fh:
            fh.write('\n{broken\n{"partial": ')
    steps.append(malformed_then_partial)
    run(R, "--watch", "5", hooks=hooks)
    t = text(R)
    check("p3:malformed complete line before a partial tail -> stale, facts kept", "Effort  [stale]" in t and "tokens_in 250" in rowr(t), rowr(t))
    with open(cr, "w") as fh:
        fh.write(good)
    ho = os.path.join(R, ".context", "handover-r.md")

    def handover_gone_story_new():
        os.chmod(ho, 0)
        put(R, STORY, "# S\n\n## 5. Open questions\n- first\n- NEW blocker\n")
    steps.append(handover_gone_story_new)
    run(R, "--watch", "5", hooks=hooks)
    op = section_of(text(R), "Open points")
    check("p3:unreadable handover keeps its old points; readable story updates", "Open points  [stale]" in text(R) and "old blocker" in op and "NEW blocker" in op, op[:400])
    os.chmod(ho, 0o644)
    put(R, "plugins/dev-workflow/.claude-plugin/plugin.json", '{"name": "dev-workflow", "version": "0.19.0"}\n')

    def corrupt_manifest():
        put(R, "plugins/dev-workflow/.claude-plugin/plugin.json", "{not json")
    steps.append(corrupt_manifest)
    run(R, "--watch", "5", hooks=hooks)
    t = text(R)
    check("p3:corrupt working-tree manifest keeps its last value, stale", "Workflow version  [stale]" in t and "declared in the working tree: 0.19.0" in t, section_of(t, "Workflow version")[:300])
    put(R, "plugins/dev-workflow/.claude-plugin/plugin.json", '{"name": "dev-workflow", "version": "0.18.0"}\n')
    ok_tr = open(tr).read()

    def bad_attachment():
        with open(tr, "w") as fh:
            fh.write(ok_tr.replace('"skills": [{"name": "intake", "path": "/h/.claude/plugins/cache/dev-workflow-kit/dev-workflow/0.16.0/skills/intake"}]', '"skills": 7'))
    steps.append(bad_attachment)
    run(R, "--watch", "5", hooks=hooks)
    t = text(R)
    check("p3:invalid invoked_skills keeps the previous load, stale", "loaded 0.16.0" in t and "Workflow version  [stale]" in t, section_of(t, "Workflow version")[:400])

    def bad_input():
        with open(tr, "w") as fh:
            fh.write(ok_tr.replace('"input": {"workingDirectory": "%s", "instruction": "MARKER_INPUT please"}' % R, '"input": 7'))
    steps.append(bad_input)
    with open(tr, "w") as fh:
        fh.write(ok_tr)
    run(R, "--watch", "5", hooks=hooks)
    t = text(R)
    check("p8:non-object gate-call input keeps the call, stale", "Effort  [stale]" in t and "rrrrrrrr12" in section_of(t, "Effort"), section_of(t, "Effort")[:300])

    def bad_tool_id():
        with open(tr, "w") as fh:
            fh.write(ok_tr.replace('"id": "toolu_R1"', '"id": 7'))
    steps.append(bad_tool_id)
    with open(tr, "w") as fh:
        fh.write(ok_tr)
    run(R, "--watch", "5", hooks=hooks)
    t = text(R)
    check("p7:malformed gate-call event keeps the call, stale", "Effort  [stale]" in t and "rrrrrrrr12" in section_of(t, "Effort"), section_of(t, "Effort")[:300])
    check("p3:recent session mismatch warned", "loaded 0.16.0 in session" in t)
    with open(tr, "w") as fh:
        fh.write(ok_tr)
    run(R)
    check("p3:footer counts first-line and full Codex reads apart", re.search(r"Codex logs: first line read \d+, from cache \d+; fully read \d+", text(R)))
    # a plan committed then deleted on disk keeps its phase evidence; a restored deletion is no candidate
    put(R, "docs/superpowers/plans/2026-01-01-s.md", "# P\n\n**Story:** `%s`\n" % STORY)
    commit(R, "plan")
    os.remove(os.path.join(R, "docs/superpowers/plans/2026-01-01-s.md"))
    run(R)
    check("p3:plan deleted on disk keeps plan written", "last evidenced phase:  plan written" in section_of(text(R), "Current work"))
    git(R, "rm", "-qf", "docs/superpowers/plans/2026-01-01-s.md")
    git(R, "commit", "-q", "-m", "drop plan")
    run(R)
    w = section_of(text(R), "Current work")
    check("p4:committed plan deletion keeps plan written", "last evidenced phase:  plan written" in w, w[:500])
    check("p4:candidate carries its own evidence date and commit", re.search(r"inferred current story \(only candidate\): \S+ \(last evidence \d{4}-\S+ \([0-9a-f]{12}\)\)", w), w[:400])
    op_asof = re.search(r"Open points  \[\w+\]\s+as of (\S+)", text(R)).group(1)
    check("p4:open points as-of is a source time, not the collection time", op_asof != re.search(r"generated (\S+)", text(R)).group(1), op_asof)
    # one unreadable file keeps its last size; readable growth still updates
    gr_hooks = {"iterations": 2, "sleep": lambda s: None}

    def lock_one():
        os.chmod(os.path.join(R, "scripts", "old.sh"), 0)
        put(R, "scripts/new-code.py", "x = 1\n")
    gr_hooks["after_collection"] = lock_one
    run(R, "--watch", "5", hooks=gr_hooks)
    gr = section_of(text(R), "Artifact growth")
    check("p4:unreadable file keeps its size, new readable file shown", "Artifact growth  [stale]" in text(R) and "scripts/new-code.py" in gr, gr[-500:])
    os.chmod(os.path.join(R, "scripts", "old.sh"), 0o644)
    # a configured fsmonitor helper is never invoked
    marker = os.path.join(WORK, "fsmonitor-ran")
    helper = os.path.join(WORK, "fsmon.sh")
    with open(helper, "w") as fh:
        fh.write("#!/bin/sh\ntouch '%s'\n" % marker)
    os.chmod(helper, 0o755)
    git(R, "config", "core.fsmonitor", helper)
    run(R)
    check("p4:fsmonitor helper not invoked", not os.path.exists(marker))
    git(R, "config", "--unset", "core.fsmonitor")
    # a configured clean filter is never run
    put(R, ".gitattributes", "README.md filter=probe\n")
    commit(R, "attributes")
    git(R, "config", "filter.probe.clean", "sh -c 'touch %s; cat'" % marker)
    put(R, "README.md", "README\n")  # same length as "readme\n": status must look at content
    os.utime(os.path.join(R, "README.md"), (1, 1))
    run(R)
    check("p5:clean filter helper not invoked", not os.path.exists(marker))
    git(R, "config", "--unset", "filter.probe.clean")
    # a driver configured while the monitor runs is neutralized too
    put(R, "README.md", "readme\n")
    os.utime(os.path.join(R, "README.md"), (1, 1))

    def add_driver():
        git(R, "config", "filter.probe.clean", "sh -c 'touch %s; cat'" % marker)
        put(R, "README.md", "ReadMe\n")
        os.utime(os.path.join(R, "README.md"), (2, 2))
    run(R, "--watch", "5", hooks={"iterations": 2, "sleep": lambda s: None, "after_collection": add_driver})
    check("p6:driver added during watch not invoked", not os.path.exists(marker))

    def add_driver_mid():
        git(R, "config", "filter.probe2.clean", "sh -c 'touch %s; cat'" % marker)
        put(R, ".gitattributes", "README.md filter=probe2\n")
        put(R, "README.md", "rEADME\n")
        os.utime(os.path.join(R, "README.md"), (4, 4))
    run(R, hooks={"between": add_driver_mid})
    check("p7:driver added during a collection not invoked", not os.path.exists(marker))
    git(R, "config", "--unset", "filter.probe2.clean")
    put(R, ".gitattributes", "README.md filter=probe\n")
    git(R, "config", "--unset", "filter.probe.clean")
    if os.path.exists(marker):
        os.remove(marker)  # each helper check starts without a marker
    # a submodule's own driver is never run
    SUB = mkrepo("SUB")
    put(SUB, ".gitattributes", "README.md filter=subprobe\n")
    commit(SUB, "attrs")
    subprocess.run(["git", "-c", "protocol.file.allow=always", "submodule", "add", "-q", SUB, "sub"], cwd=R, check=True,
                   stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    commit(R, "add submodule")
    git(os.path.join(R, "sub"), "config", "filter.subprobe.clean", "sh -c 'touch %s; cat'" % marker)
    put(R, "sub/README.md", "README\n")
    os.utime(os.path.join(R, "sub", "README.md"), (3, 3))
    run(R)
    check("p6:submodule driver not invoked", not os.path.exists(marker))
    git(os.path.join(R, "sub"), "commit", "-q", "--allow-empty", "-m", "sub moves")
    git(R, "add", "sub")
    run(R)
    w = section_of(text(R), "Current work")
    check("p8:staged submodule commit counts as uncommitted", not re.search(r"uncommitted paths: 0\b", w), w[:300])
    git(R, "commit", "-q", "-m", "sub pointer")
    # an untracked symlink to a FIFO neither blocks nor counts as content
    import signal
    os.mkfifo(os.path.join(R, "pipe"))
    os.symlink("pipe", os.path.join(R, "pipe-link"))
    signal.alarm(60)
    rc = run(R)
    signal.alarm(0)
    check("p7:symlink to FIFO does not block the collection", rc == 0)
    os.remove(os.path.join(R, "pipe-link"))
    os.remove(os.path.join(R, "pipe"))
    # a file git normalizes is reported as possibly changed, not as changed
    put(R, ".gitattributes", "*.txt text=auto\n")
    with open(os.path.join(R, "crlf.txt"), "wb") as fh:
        fh.write(b"a\r\nb\r\n")
    commit(R, "crlf")
    os.utime(os.path.join(R, "crlf.txt"), (5, 5))
    run(R)
    check("p7:normalized file is possibly changed, not changed", "possibly: normalized or filtered" in section_of(text(R), "Current work"), section_of(text(R), "Current work")[:400])
    head_now = git(R, "rev-parse", "HEAD", date=False)
    run(R, "--base", head_now)
    gr = section_of(text(R), "Artifact growth")
    check("p8:growth labels a normalized file possibly modified", "crlf.txt  possibly modified" in gr and "crlf.txt  modified" not in gr, gr[-400:])
    # a mode-only change and a staged submodule commit are uncommitted changes
    os.chmod(os.path.join(R, "CLAUDE.md"), 0o755)
    run(R)
    ve = section_of(text(R), "Workflow version")
    check("p8:mode-only change marks the rule file", "CLAUDE.md: last commit" in ve and "uncommitted changes" in ve, ve[-400:])
    os.chmod(os.path.join(R, "CLAUDE.md"), 0o644)
    git(R, "config", "core.autocrlf", "true")
    with open(os.path.join(R, "plain.txt"), "wb") as fh:
        fh.write(b"x\r\n")
    git(R, "-c", "core.autocrlf=false", "add", "plain.txt")
    git(R, "-c", "core.autocrlf=false", "commit", "-q", "-m", "plain")
    os.utime(os.path.join(R, "plain.txt"), (6, 6))
    with open(os.path.join(R, "plain.txt"), "wb") as fh:
        fh.write(b"x\n\r")
    run(R)
    check("p8:core.autocrlf makes a differing file possibly changed", "possibly: normalized or filtered" in section_of(text(R), "Current work"))
    git(R, "config", "--unset", "core.autocrlf")
    os.remove(os.path.join(R, "plain.txt"))
    git(R, "checkout", "-q", "--", "plain.txt")
    # a file behind an inaccessible directory is unknown, not deleted
    os.chmod(os.path.join(R, "scripts"), 0)
    run(R)
    gr = section_of(text(R), "Artifact growth")
    os.chmod(os.path.join(R, "scripts"), 0o755)
    check("p6:file behind inaccessible directory is unknown, not deleted", "unreadable (size unknown)" in gr and not re.search(r"scripts/\S+\s+deleted", gr), gr[-500:])
    # a failed handover listing keeps its rows; readable growth still updates; retained sizes are dated
    run(R)

    def lock_dir():
        os.chmod(os.path.join(R, ".context"), 0o300)
        put(R, "scripts/newer.py", "y = 2\n")
    run(R, "--watch", "5", hooks={"iterations": 2, "sleep": lambda s: None, "after_collection": lock_dir})
    os.chmod(os.path.join(R, ".context"), 0o755)
    gr = section_of(text(R), "Artifact growth")
    check("p6:handover listing failure keeps new code growth", "scripts/newer.py" in gr and "Artifact growth  [stale]" in text(R), gr[-500:])

    def lock_file():
        os.chmod(os.path.join(R, "scripts", "newer.py"), 0)
    run(R, "--watch", "5", hooks={"iterations": 2, "sleep": lambda s: None, "after_collection": lock_file})
    os.chmod(os.path.join(R, "scripts", "newer.py"), 0o644)
    check("p6:retained sizes carry their measurement time", "retained sizes measured from" in text(R))
    # a later provenance-only cycle dates the candidate
    git(R, "commit", "-q", "--allow-empty", "-m", "prov\n\ncycle qqqqqqqq12; floor 3 per {%s (level 1)}; hook reminder threshold absent\n" % STORY)
    run(R)
    prov_sha = git(R, "rev-parse", "--short=12", "HEAD", date=False)
    check("p6:newer provenance dates the candidate", "(%s))" % prov_sha in section_of(text(R), "Current work"), section_of(text(R), "Current work")[:300])
    # a file unreadable on its first measurement is unknown, not deleted
    S5 = mkrepo("S5")
    os.chmod(os.path.join(S5, "scripts", "keep.test.sh"), 0)
    run(S5)
    gr = section_of(text(S5), "Artifact growth")
    check("p5:first-read unreadable file is unknown, not deleted", "scripts/keep.test.sh  unreadable (size unknown)" in gr and "deleted" not in gr, gr[-400:])
    os.chmod(os.path.join(S5, "scripts", "keep.test.sh"), 0o644)
    # a story only in the working tree carries its modification time
    put(S5, STORY, "# S\n")
    os.utime(os.path.join(S5, STORY), (1767312000, 1767312000))  # 2026-01-02T00:00:00Z
    run(S5)
    check("p5:uncommitted candidate dated by its mtime", "last evidence 2026-01-02T00:00:00Z (uncommitted)" in section_of(text(S5), "Current work"))

# signed history with log.showSignature=true
if wanted("p3"):
    SG = mkrepo("SG")
    key = os.path.join(WORK, "sigkey")
    subprocess.run(["ssh-keygen", "-q", "-t", "ed25519", "-N", "", "-f", key], check=True)
    git(SG, "config", "gpg.format", "ssh")
    git(SG, "config", "user.signingkey", key + ".pub")
    git(SG, "config", "log.showSignature", "true")
    git(SG, "checkout", "-q", "main")
    git(SG, "commit", "-q", "-S", "--allow-empty", "-m", "signed base")
    git(SG, "checkout", "-q", "-B", "feature")
    put(SG, STORY, "# S\n")
    git(SG, "add", "-A")
    git(SG, "commit", "-q", "-S", "-m", "signed story")
    rc = run(SG)
    check("p3:signed history with showSignature still renders", rc == 0 and "inferred current story" in text(SG))

# a partial clone is refused before any object is read
if wanted("g1"):
    P = mkrepo("P")
    git(P, "config", "extensions.partialclone", "origin")
    rc = run(P)
    check("g1:partial clone refused, nothing written", rc == 1 and not os.path.exists(os.path.join(P, ".context", "status", "index.html")))

# an edit committed on the branch and undone on disk is no net change, so no candidate
if wanted("c4"):
    H = mkrepo("H")
    git(H, "checkout", "-q", "main")
    put(H, STORY, "# S\n")
    commit(H, "story on main")
    git(H, "checkout", "-q", "-B", "feature")
    put(H, STORY, "# S edited\n")
    commit(H, "edit")
    put(H, STORY, "# S\n")
    run(H)
    git(H, "rm", "-qf", STORY)
    git(H, "commit", "-q", "-m", "delete story")
    put(H, STORY, "# S\n")
    run(H)
    check("c4:undone edit and restored deletion are not candidates", "current task not established" in section_of(text(H), "Current work") and STORY not in section_of(text(H), "Current work"))

# SHA-256 repositories: an unchanged file is not reported as modified
if wanted("c6"):
    G = os.path.join(WORK, "G")
    os.makedirs(os.path.join(G, "scripts"))
    git(G, "init", "-q", "--object-format=sha256", "-b", "main")
    put(G, "README.md", "same\n")
    commit(G, "initial")
    git(G, "checkout", "-q", "-b", "feature")
    put(G, "new.txt", "n\n")
    run(G)
    gr = section_of(text(G), "Artifact growth")
    check("c6:sha256 repo: unchanged file not modified", "README.md" not in gr and "new.txt" in gr, gr[-400:])

for name, ok, why in results:
    print(("PASS " if ok else "FAIL ") + name + ("" if ok else "  -- " + str(why)[:600].replace("\n", " ")))
PY

python3 -B "$work/driver.py" "$work/run" "$here/status-view.py" > "$work/out.txt" 2>&1
status=$?
while IFS= read -r l; do
  case "$l" in
    "PASS "*) pass "${l#PASS }" ;;
    "FAIL "*) fail "${l#FAIL }" ;;
    *) printf '%s\n' "$l" ;;
  esac
done < "$work/out.txt"
[ "$status" -eq 0 ] && pass "driver exited 0" || fail "driver exited $status"

# Negative controls: each mutant removes one behaviour (one literal replacement); the named case must
# then fail.
mutant() {  # $1 name, $2 text to replace, $3 replacement, $4 case to run
  mkdir -p "$work/m-$1"
  cp "$here/run-analytics.py" "$here/ledger-metrics.py" "$here/loop-usefulness.py" "$work/m-$1/"
  python3 -B - "$here/status-view.py" "$work/m-$1/status-view.py" "$2" "$3" <<'PY'
import sys
s = open(sys.argv[1]).read()
assert s.count(sys.argv[3]) == 1, "mutant target not found exactly once"
open(sys.argv[2], "w").write(s.replace(sys.argv[3], sys.argv[4]))
PY
  rm -rf "$work/run"
  if python3 -B "$work/driver.py" "$work/run" "$work/m-$1/status-view.py" "$4" 2>&1 | grep -q '^FAIL '; then
    pass "mutant $1 caught by $4"
  else
    fail "mutant $1 NOT caught by $4"
  fi
}
mutant none-for-unknown '<p><b>unknown</b> — no source of open points could be read</p>' '<p>none</p>' c5
mutant first-record-only 'applying = [r for r in recs if' 'applying = [r for r in recs[:1] if' c14
mutant reread-everything 'if prev and prev["size"] == st.st_size and prev["mtime"] == st.st_mtime_ns:' 'if False:' c9
mutant keep-raw-model 'm if isinstance(m, str) and ra.RE_MODEL.fullmatch(m) else None' 'm' c12
mutant mentions-count 'if obj.get("type") == "user" and obj.get("isMeta") is True:' 'if obj.get("type") == "user":' c13

printf '%d passed, %d failed\n' "$passed" "$failed"
[ "$failed" -eq 0 ]
