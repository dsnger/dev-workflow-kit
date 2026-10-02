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
