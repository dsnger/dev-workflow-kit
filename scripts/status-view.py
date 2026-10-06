#!/usr/bin/env python3
"""Generate one local HTML page about the work in this repository: current work, evidenced progress,
open points, effort, artifact growth and workflow version.

Spec: docs/superpowers/specs/2026-10-06-process-monitoring-status-view-design.md
Usage: python3 -B scripts/status-view.py [--base <commit>] [--watch <seconds>]

Writes only <checkout>/.context/status/ (the page, its cache, a lock). Reads git, the handover, Claude
Code transcripts, Codex session logs and ~/.claude/plugins/installed_plugins.json, and changes none of
them. No model call. The cache holds allowlisted facts only, never session text. Standard library
only; Python 3.8 or later; git 2.36 or later.

Collections run one after another, never overlapping: in watch mode the next starts the interval
after the previous one ended. A project-scoped record in installed_plugins.json applies only when a
path field in it equals this checkout root; no such record exists today. `main(argv, hooks)` takes a
hooks dict from Python only (scripts/status-view.test.sh): "fail" (section names that raise),
"between" (called after HEAD is read), "before_check" (called before the final HEAD check), "after_collection" (called between watch collections),
"iterations" (stop after n collections) and "sleep" (replaces time.sleep).
"""
import sys

sys.dont_write_bytecode = True  # before any other import: the report writes only its own directory
import datetime  # noqa: E402
import errno  # noqa: E402
import fcntl  # noqa: E402
import hashlib  # noqa: E402
import html  # noqa: E402
import importlib.util  # noqa: E402
import json  # noqa: E402
import os  # noqa: E402
import re  # noqa: E402
import stat  # noqa: E402
import time  # noqa: E402

HERE = os.path.dirname(os.path.abspath(__file__))


def load(name, filename):
    spec = importlib.util.spec_from_file_location(name, os.path.join(HERE, filename))
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    return mod


ra = load("run_analytics", "run-analytics.py")
lu = load("loop_usefulness", "loop-usefulness.py")
lm = ra.load_ledger_parser(HERE)

PLUGIN = "dev-workflow@dev-workflow-kit"
RULE_FILES = ("CLAUDE.md", "AGENTS.md", ".claude/review-gates.md")
MANIFEST = "plugins/dev-workflow/.claude-plugin/plugin.json"
WINDOW_HOURS = 24
SECTIONS = ("work", "progress", "open", "effort", "growth", "version")
TITLES = {"work": "Current work", "progress": "Evidenced progress", "open": "Open points",
          "effort": "Effort", "growth": "Artifact growth", "version": "Workflow version"}
RE_LOAD = re.compile(r"plugins/cache/dev-workflow-kit/dev-workflow/([0-9]+\.[0-9]+\.[0-9]+)/skills/([A-Za-z0-9._-]+)")
RE_OPEN_HEAD = re.compile(r"open|unresolved|blocker|wait", re.I)
REVIEW_TYPES = ("spec", "quality", "full")
GROUPS = (("stories", lambda p: p.startswith("docs/superpowers/stories/")),
          ("specs", lambda p: p.startswith("docs/superpowers/specs/")),
          ("plans", lambda p: p.startswith("docs/superpowers/plans/")),
          ("rule files", lambda p: p in ("CLAUDE.md", "AGENTS.md") or p.startswith(".claude/")),
          ("prompts", lambda p: p.startswith("plugins/") and p.endswith(".md")),
          ("tests", lambda p: p.endswith(".test.sh") or (p.startswith("plugins/") and "/fixtures/" in p)),
          ("code", lambda p: p.startswith("scripts/") or p.startswith("plugins/")),
          ("other", lambda p: True))
PHASES = ("story", "spec written", "spec reviewed", "plan written", "plan reviewed", "Gate B closed")
CYCLE_PHASE = {"Gate-A spec": "spec reviewed", "Gate-A plan": "plan reviewed", "Gate B": "Gate B closed"}


class Discarded(Exception):
    """HEAD or the branch moved while one collection ran."""


class Unclaimed(ValueError):
    """A Codex log whose first line names no valid session: it supplies nothing unless an earlier read of
    the same file did, in which case that read is kept and the source is stale."""


class Refused(Exception):
    """Nothing may be written: the cause is the message."""


def now_utc():
    return datetime.datetime.now(datetime.timezone.utc).replace(microsecond=0)


def fmt(dt):
    return dt.strftime("%Y-%m-%dT%H:%M:%SZ") if dt else "unknown"


def esc(text):
    return html.escape(str(text), quote=True)


def git(args, cwd):
    """Every report git call. None of them runs a filter, fsmonitor or other configured helper:
    `git status` and `git diff <tree>` are not used (spec §8); signatures are not checked."""
    return lu.git(("--literal-pathspecs", "-c", "log.showSignature=false", "-c", "core.fsmonitor=false") + tuple(args), cwd)


def read_regular(path):
    """The bytes of a regular file (a symlink to one is followed). Anything else — a FIFO, a device, a
    directory — raises without blocking, so a special file can neither hang nor flood a collection."""
    fd = os.open(path, os.O_RDONLY | os.O_NONBLOCK)
    try:
        if not stat.S_ISREG(os.fstat(fd).st_mode):
            raise OSError(errno.EINVAL, "not a regular file")
        with os.fdopen(os.dup(fd), "rb") as fh:
            return fh.read()
    finally:
        os.close(fd)


def git_text(args, cwd):
    rc, out = git(args, cwd)
    if rc != 0:
        raise RuntimeError("git %s failed" % args[0])
    return out.decode("utf-8", "replace")


# ---- output directory: every file opened relative to its fd, never through a symlink ---------------

def open_dir(name, parent_fd):
    for _ in range(2):
        try:
            return os.open(name, os.O_RDONLY | os.O_DIRECTORY | os.O_NOFOLLOW, dir_fd=parent_fd)
        except FileNotFoundError:
            try:
                os.mkdir(name, 0o755, dir_fd=parent_fd)
            except FileExistsError:
                pass
        except OSError as e:
            if e.errno in (errno.ELOOP, errno.ENOTDIR):
                raise Refused("%s is a symlink or not a directory" % name)
            raise Refused("%s cannot be opened" % name)
    raise Refused("%s cannot be created" % name)


def take_lock(dfd):
    try:
        fd = os.open(".lock", os.O_RDWR | os.O_CREAT | os.O_NOFOLLOW | os.O_NONBLOCK, 0o600, dir_fd=dfd)
    except OSError:
        raise Refused(".context/status/.lock is a symlink or cannot be opened")
    st = os.fstat(fd)
    if not stat.S_ISREG(st.st_mode) or st.st_nlink != 1:
        raise Refused(".context/status/.lock is not a regular file with a single link")
    try:
        fcntl.flock(fd, fcntl.LOCK_EX | fcntl.LOCK_NB)
    except OSError:
        raise Refused("another status-view run holds .context/status/.lock")
    return fd


def check_target(dfd, name):
    """A target may be absent or a regular file with one link; never a symlink."""
    try:
        st = os.lstat(name, dir_fd=dfd)
    except FileNotFoundError:
        return
    if not stat.S_ISREG(st.st_mode) or st.st_nlink != 1:
        raise Refused(".context/status/%s is a symlink or not a regular file" % name)


def write_atomic(dfd, name, data):
    check_target(dfd, name)
    tmp = ".tmp.%s.%s" % (name, os.urandom(6).hex())
    fd = os.open(tmp, os.O_WRONLY | os.O_CREAT | os.O_EXCL | os.O_NOFOLLOW, 0o600, dir_fd=dfd)
    with os.fdopen(fd, "wb") as fh:
        fh.write(data)
        fh.flush()
        os.fsync(fh.fileno())
    os.replace(tmp, name, src_dir_fd=dfd, dst_dir_fd=dfd)


def read_cache(dfd):
    check_target(dfd, "cache.json")
    try:
        fd = os.open("cache.json", os.O_RDONLY | os.O_NOFOLLOW, dir_fd=dfd)
    except FileNotFoundError:
        return None
    with os.fdopen(fd, "rb") as fh:
        try:
            c = json.loads(fh.read().decode("utf-8"))
        except (ValueError, UnicodeDecodeError):
            return None
    return c if isinstance(c, dict) and c.get("v") == 1 else None


# ---- repository facts ------------------------------------------------------------------------------

def resolve_baseline(cwd, base_arg):
    if base_arg is not None:
        rc, out = git(("rev-parse", "--verify", "--quiet", base_arg + "^{commit}"), cwd)
        if rc != 0:
            return None, "--base", "--base %s does not name a commit" % base_arg
        return out.decode().strip(), "--base", None
    rc, _ = git(("rev-parse", "--verify", "--quiet", "main^{commit}"), cwd)
    if rc != 0:
        return None, "merge-base with main", "no branch main in this repository"
    rc, out = git(("merge-base", "HEAD", "main"), cwd)
    if rc != 0 or not out.strip():
        shallow = git(("rev-parse", "--is-shallow-repository"), cwd)[1].strip() == b"true"
        return None, "merge-base with main", ("shallow clone: no merge-base found" if shallow
                                              else "HEAD and main share no history")
    return out.decode().strip(), "merge-base with main", None


def head_state(cwd):
    rc, out = git(("rev-parse", "--verify", "--quiet", "HEAD"), cwd)
    head = out.decode().strip() if rc == 0 else None
    rc, out = git(("symbolic-ref", "--short", "-q", "HEAD"), cwd)
    return head, (out.decode().strip() if rc == 0 else "(detached)")


def records_in_range(cwd, base, head):
    """nonce -> {"curve"|"prov"|"skip": {text: [(ct, sha)]}}, read from base..head only, plus each
    record's parsed data."""
    rc, out = git(lm_log_args() + ("%s..%s" % (base, head),), cwd)
    if rc != 0:
        raise RuntimeError("history of the range could not be read")
    parts = out.decode("utf-8", "replace").split("\0")
    nonces, data = {}, {}
    for i in range(0, len(parts) - 1, 2):
        csha = parts[i].lstrip("\n")
        head_line, _, body = parts[i + 1].partition("\n")
        ct = int(head_line) if head_line.isdigit() else 0
        lines, j = body.split("\n"), 0
        while j < len(lines):
            line = lines[j]
            j += 1
            if not lm.CANDIDATE.match(line):
                continue
            parsed = lm.parse_record(line)
            if parsed is None or parsed[0] == "none (pre-rule)":
                continue
            field, typ, d = parsed
            text = line
            if typ == "skip":
                reason = []
                while j < len(lines) and lines[j] != "" and not lm.CANDIDATE.match(lines[j]):
                    reason.append(lines[j])
                    j += 1
                text = line + " | " + " ".join(reason)
            occ = nonces.setdefault(field, {}).setdefault(typ, {}).setdefault(text, [])
            if (ct, csha) not in occ:
                occ.append((ct, csha))
            data[(field, typ, text)] = d
    return nonces, data


def lm_log_args():
    return ("-c", "log.showSignature=false", "-c", "i18n.logOutputEncoding=UTF-8", "log",
            "--no-show-signature", "-z", "--format=%H%x00%ct%n%B")


def cycle_state(recs):
    state, reason = lu.classify(recs)
    if state == "open" and reason == "conflicting provenance lines":
        return "conflicting", reason
    if state == "open":
        return "open", "curve without provenance line"
    return state, reason


def cycles(cwd, base, head):
    """nonce -> {state, reason, kind, stories, sha, ct, passes}."""
    nonces, data = records_in_range(cwd, base, head)
    out = {}
    for n, recs in nonces.items():
        state, reason = cycle_state(recs)
        kind, stories, passes, occ = None, None, None, []
        for typ in ("curve", "prov", "skip"):
            for text, o in recs.get(typ, {}).items():
                occ += o
                d = data[(n, typ, text)]
                if typ == "curve":
                    kind = d["kind"]
                    passes = len(lm.expand(d["spec"], len(d["f"].split(","))) or [])
                elif typ == "skip":
                    kind = kind or d["kind"]
                elif typ == "prov" and d["entries"] is not None:
                    stories = sorted({p for p, _lv in d["entries"]} | set(stories or ()))
        ct, sha = max(occ)
        out[n] = {"state": state, "reason": reason, "kind": kind, "stories": stories or [],
                  "sha": sha, "ct": ct, "passes": passes}
    return out


RE_INDEX = re.compile(rb"(\d{6}) ([0-9a-f]+) (\d)\t([^\0]*)\0  ctime: (\d+):(\d+)\n  mtime: (\d+):(\d+)\n.*?size: (\d+)", re.S)


def worktree_state(ctx):
    """path -> "M" (changed), "D" (deleted), "A" (untracked), "?" (possibly changed: a file git would
    normalize or filter, whose raw bytes differ — not compared further, since that would run helpers).
    Built like `git status` without running it: index against HEAD by blob id, working tree against the
    index by size and mtime first, then by the hash of the raw bytes."""
    if "wt" in ctx:
        return ctx["wt"]
    root, out = ctx["root"], {}
    head_tree = {}
    for line in git_text(("ls-tree", "-r", "-z", "--full-tree", ctx["head"]), root).split("\0"):
        if line:
            meta, path = line.split("\t", 1)
            mode, _typ, sha = meta.split()
            head_tree[path] = (mode, sha)
    rc, raw = git(("ls-files", "-s", "-z", "--debug"), root)
    if rc != 0:
        raise RuntimeError("git ls-files failed")
    index = {}
    for m in RE_INDEX.finditer(raw):
        path = os.fsdecode(m.group(4))
        index[path] = (m.group(1).decode(), m.group(2).decode(), int(m.group(7)), int(m.group(8)), int(m.group(9)),
                       int(m.group(5)), int(m.group(6)))
    ctx["index_modes"] = {p: v[0] for p, v in index.items()}
    try:
        index_mtime = os.stat(os.path.join(root, git_text(("rev-parse", "--git-path", "index"), root).strip())).st_mtime_ns
    except OSError:
        index_mtime = 0  # no index file: every stat shortcut is refused
    maybe = []
    cfg = lambda k: git_text(("config", "--get", k), root).strip().lower() if git(("config", "--get", k), root)[0] == 0 else ""
    filemode = ctx["filemode"] = cfg("core.filemode") not in ("false", "no", "off", "0")
    ctx["symlinks"] = cfg("core.symlinks") not in ("false", "no", "off", "0")
    autocrlf = cfg("core.autocrlf") in ("true", "input", "yes", "on", "1")
    for path in set(head_tree) | set(index):
        if path.startswith(".context/"):
            continue
        h, i = head_tree.get(path), index.get(path)
        if i is None:
            out[path] = "D"  # removed from the index
            continue
        if h is None or h[1] != i[1] or h[0] != i[0]:
            out[path] = "M"  # staged, a staged mode change or a staged submodule commit included
        if i[0] == "160000" or (h and h[0] == "160000"):
            continue  # a submodule's own working tree is not looked into
        full = os.path.join(root, path)
        try:
            st = os.lstat(full)
        except FileNotFoundError:
            out[path] = "D"
            continue
        except OSError:
            out[path] = "?"
            continue
        if filemode and stat.S_ISREG(st.st_mode) and i[0] in ("100644", "100755") and \
                (i[0] == "100755") != bool(st.st_mode & 0o100):
            out[path] = "M"  # a mode-only change, as git reports it with core.filemode
            continue
        if st.st_size == i[4] and st.st_mtime_ns // 10**9 == i[2] and st.st_mtime_ns % 10**9 == i[3] \
                and st.st_ctime_ns == i[5] * 10**9 + i[6] and st.st_mtime_ns < index_mtime:
            continue  # unchanged by stat; a file as new as the index itself is hashed (git's racy-clean rule)
        try:
            data = os.readlink(full).encode() if stat.S_ISLNK(st.st_mode) else read_regular(full)
        except OSError:
            out[path] = "?"
            continue
        if hashlib.new(ctx["object_format"], b"blob %d\0" % len(data) + data).hexdigest() != i[1]:
            maybe.append(path)
    if maybe:
        rc, attrs = git(("check-attr", "-z", "text", "eol", "filter", "--") + tuple(maybe), root)
        f = attrs.decode("utf-8", "replace").split("\0") if rc == 0 else []
        special = {f[k] for k in range(0, len(f) - 2, 3) if f[k + 2] not in ("unspecified", "unset")}
        for path in maybe:
            out[path] = "?" if autocrlf or path in special or rc != 0 else out.get(path, "M") or "M"
    for p in git_text(("ls-files", "-z", "--others", "--exclude-standard"), root).split("\0"):
        if p and not p.startswith(".context/"):
            out[p] = "A"
    ctx["wt"] = out
    return out


def file_mode(full, ctx, path=None):
    """The git mode of a working-tree path: 120000 symlink, 100755 executable, 100644 regular. Without
    core.filemode the executable bit on disk is not trusted and the index's mode is taken, as git does."""
    st = os.lstat(full)
    if stat.S_ISLNK(st.st_mode):
        return "120000"
    indexed = ctx.get("index_modes", {}).get(path)
    if indexed == "120000" and not ctx.get("symlinks", True):
        return "120000"  # without core.symlinks git checks a symlink out as a file holding its target
    if not ctx.get("filemode", True) and indexed in ("100644", "100755"):
        return indexed  # only the executable bit is untrusted without core.filemode, never the type
    return "100755" if st.st_mode & 0o100 else "100644"


def modes_equal(a, b, ctx):
    return a == b


def changed_paths(ctx, base, head):
    """Path -> status letter for the working tree against base, untracked files included: `git diff-tree`
    (base..HEAD) plus worktree_state (HEAD..working tree). Neither runs a configured helper (spec §8).
    "?" (possibly changed) is kept as "?"."""
    out, cwd = {}, ctx["root"]
    rc, raw = git(("diff-tree", "-r", "--no-renames", "--name-status", "-z", base, head), cwd)
    if rc != 0:
        raise RuntimeError("git diff-tree against the baseline failed")
    f = raw.decode("utf-8", "replace").split("\0")
    for i in range(0, len(f) - 1, 2):
        out[f[i + 1]] = f[i][:1]
    for path, st in worktree_state(ctx).items():
        if st == "D":
            out[path] = "D" if out.get(path) != "A" else None
        elif st == "A" or out.get(path) == "A":
            out[path] = "A"
        elif st == "?":
            out[path] = "?" if out.get(path) is None else out[path]
        else:
            out[path] = "M"
    out = {p: s for p, s in out.items() if s and not p.startswith(".context/")}
    fmt_ = git_text(("rev-parse", "--show-object-format"), cwd).strip() or "sha1"
    for p in [p for p, st in out.items() if st in ("M", "A")]:  # an edit undone on disk is no net change
        rc, entry = git(("ls-tree", "-z", base, "--", p), cwd)
        meta = entry.decode("utf-8", "replace").split("\t", 1)[0].split()
        full = os.path.join(cwd, p)
        try:
            data = os.readlink(full).encode() if os.path.islink(full) else read_regular(full)
            mode = file_mode(full, ctx, p)
        except OSError:
            continue
        if rc == 0 and len(meta) == 3 and meta[2] == hashlib.new(fmt_, b"blob %d\0" % len(data) + data).hexdigest() \
                and modes_equal(meta[0], mode, ctx):
            del out[p]
    return out


def committed_paths(cwd, base, head):
    """Path -> newest commit in base..head that touched it."""
    out = {}
    text = git_text(("log", "--no-renames", "-z", "--format=%x01%H", "--name-only", "%s..%s" % (base, head)), cwd)
    sha = None
    for tok in text.replace("\n", "\0").split("\0"):
        if tok.startswith("\x01"):
            sha = tok[1:]
        elif tok and sha and tok not in out:
            out[tok] = sha
    return out


def commit_time(cwd, sha):
    rc, out = git(("show", "-s", "--format=%cI", sha), cwd)
    return out.decode().strip() if rc == 0 else "unknown"


def story_header(text):
    for line in text.split("\n"):
        if line.startswith("**Story:**"):
            return re.findall(r"`([^`]+)`", line)
    return []


def last_commit(cwd, path, head):
    rc, out = git(("log", "-1", "--format=%H %cI", head, "--", path), cwd)
    return out.decode().strip() if rc == 0 and out.strip() else None


def dirty(ctx, path):
    """"uncommitted", "possibly uncommitted" or None."""
    st = worktree_state(ctx).get(path)
    return None if st is None else "possibly uncommitted" if st == "?" else "uncommitted"


def revision(ctx, path, head):
    d = dirty(ctx, path)
    if d:
        return d
    cwd = ctx["root"]
    lc = last_commit(cwd, path, head)
    return lc.split()[0][:12] if lc else "not in git"


def read_text(root, rel):
    return read_regular(os.path.join(root, rel)).decode("utf-8", "replace")


def newest_handover(root):
    d = os.path.join(root, ".context")
    try:
        names = [n for n in os.listdir(d) if re.fullmatch(r"handover-[^/]+\.md", n)]
    except FileNotFoundError:
        return None
    best = None
    for n in names:
        try:
            st = os.lstat(os.path.join(d, n))
        except FileNotFoundError:
            continue  # removed between listing and lookup
        if stat.S_ISREG(st.st_mode) and (best is None or st.st_mtime > best[1]):
            best = (n, st.st_mtime)
    return best


def md_sections(text, level="## "):
    out, cur = [], None
    for line in text.split("\n"):
        if line.startswith(level):
            cur = [line[len(level):].strip(), []]
            out.append(cur)
        elif cur is not None:
            cur[1].append(line)
    return [(h, "\n".join(b).strip()) for h, b in out]


# ---- sessions and calls (incremental) --------------------------------------------------------------

def valid_path(v):
    return isinstance(v, str) and os.path.isabs(v) and len(v) < 4096 and not any(ord(c) < 0x20 for c in v)


def project_use(uid, use):
    ts, tool, inp, res = use
    rt = inp.get("reviewType")
    fact = {"ts": ts if ra.parse_ts(ts) else None, "tool": tool,
            "rt": rt if tool == "review" and rt in REVIEW_TYPES else None,
            "wd": inp.get("workingDirectory") if valid_path(inp.get("workingDirectory")) else None,
            "in_sids": ra.call_session_ids(inp), "res": None}
    if res is not None:
        env = ra.envelope(res)
        body = None
        r = {"ts": res[0] if ra.parse_ts(res[0]) else None, "success": None, "sids": [], "slots": []}
        if env is not None:
            r["success"] = env["success"] if isinstance(env.get("success"), bool) else None
            r["sids"] = ra.call_session_ids(env)
            body = env.get("review")
            if tool == "exec":
                out = env.get("output")
                body = out.get("summary") if isinstance(out, dict) else None
        r["slots"] = ra.slots_of(body)
        fact["res"] = r
    return fact


def read_transcript(path):
    """Allowlisted facts of one transcript. Raises on an unreadable file or a malformed complete
    line; a trailing line without its newline is not read yet."""
    data = read_regular(path)
    cut = data.rfind(b"\n")
    data = data[:cut + 1] if cut >= 0 else b""
    objs, loads, problems = [], [], {}
    sid, cwds, last = None, set(), None
    for raw in data.split(b"\n"):
        if not raw.strip():
            continue
        try:
            obj = json.loads(raw.decode("utf-8", "replace"))
        except (ValueError, RecursionError):
            raise ValueError("malformed line")
        if not isinstance(obj, dict):
            raise ValueError("malformed line")
        if b"tool_" in raw or b"codex" in raw:
            objs.append(obj)
        if b"Base directory for this skill: " in raw or b"invoked_skills" in raw:
            loads += load_events(obj)
        v = obj.get("sessionId")
        if sid is None and isinstance(v, str) and ra.RE_SESSION.fullmatch(v):
            sid = v
        if valid_path(obj.get("cwd")):
            cwds.add(obj["cwd"])
        t = ra.parse_ts(obj.get("timestamp"))
        if t and (last is None or t > last):
            last = t
    for obj in objs:  # run-analytics reads a non-object input as {}; here that is an unreadable event
        msg = obj.get("message")
        for it in (msg.get("content") if isinstance(msg, dict) and isinstance(msg.get("content"), list) else ()):
            if isinstance(it, dict) and it.get("type") == "tool_use" and it.get("name") in ra.GATE_TOOLS \
                    and not isinstance(it.get("input"), dict):
                problems["wrong shape"] = problems.get("wrong shape", 0) + 1
    uses = ra.uses_from_lines(objs, problems)
    if problems:
        raise ValueError("a gate-call event of an unrecognized shape")
    return {"sid": sid, "last": ra.iso(last) if last else None, "cwds": sorted(cwds), "loads": loads,
            "calls": {uid: project_use(uid, u) for uid, u in uses.items() if ra.RE_ID.fullmatch(uid)}}


def load_events(obj):
    """Skill loads the harness itself recorded: a meta user entry naming the skill's base directory, or
    an invoked_skills attachment. Paths anywhere else are mentions and do not count."""
    ts = obj.get("timestamp") if ra.parse_ts(obj.get("timestamp")) else None
    paths = []
    if obj.get("type") == "user" and obj.get("isMeta") is True:
        msg = obj.get("message")
        content = msg.get("content") if isinstance(msg, dict) else None
        texts = [content] if isinstance(content, str) else \
            [it.get("text") for it in content or () if isinstance(it, dict) and isinstance(it.get("text"), str)] \
            if isinstance(content, list) else []
        for t in texts:
            if t.startswith("Base directory for this skill: "):
                paths.append(t[len("Base directory for this skill: "):].split("\n", 1)[0])
    att = obj.get("attachment")
    if obj.get("type") == "attachment" and isinstance(att, dict) and att.get("type") == "invoked_skills":
        skills = att.get("skills")
        if not isinstance(skills, list) or not all(isinstance(sk, dict) and isinstance(sk.get("path"), str) for sk in skills):
            raise ValueError("invoked_skills attachment of an unrecognized shape")
        paths += [sk["path"] for sk in skills]
    out = []
    for p in paths:
        m = RE_LOAD.search(p)
        if m:
            out.append(["skill " + m.group(2), m.group(1), ts])
    return out


def project_codex(fact):
    usage = fact["usage"]
    if isinstance(usage, dict):
        usage = {k: usage[k] for k in ra.TOKEN_KEYS if ra.is_nonneg_int(usage.get(k))}
    else:
        usage = None
    models = sorted({m if isinstance(m, str) and ra.RE_MODEL.fullmatch(m) else None for m in fact["models"]},
                    key=lambda m: (m is None, m or ""))
    return {"meta_ts": ra.iso(fact["meta_ts"]) if fact["meta_ts"] else None,
            "last_ts": ra.iso(fact["last_ts"]) if fact["last_ts"] else None,
            "usage": usage, "models": models, "bad": bool(fact["bad"])}


def refresh_files(cache_files, root, pattern, reader, counters):
    """Re-read new and changed files; keep the previous facts of a file that could not be read;
    drop a file only when its own lookup says it no longer exists. Returns (files, complete)."""
    problems = {}
    listed = ra.walk_jsonl(root, pattern, problems)
    if any(k.startswith("missing root") for k in problems):
        counters["missing"] = True
    complete = not any(k.startswith("unenumerable") or k == "unreadable file" for k in problems)
    fails = counters.setdefault("failures", [])
    home = os.path.expanduser("~")
    short = lambda p: p.replace(home, "~", 1)
    if not complete:
        fails.append("%s: listing incomplete (%s)" % (short(root), ", ".join(sorted(k for k in problems if not k.startswith("missing")))))
    files = {}
    for path in listed:
        try:
            st = os.lstat(path)
        except FileNotFoundError:
            continue
        prev = cache_files.get(path)
        if prev and prev["size"] == st.st_size and prev["mtime"] == st.st_mtime_ns:
            files[path] = prev
            counters["cached"] += 1
            continue
        try:
            facts = reader(path)
        except Unclaimed as e:
            if prev:
                files[path] = prev
                complete = False
                fails.append("%s: %s" % (short(path), e))
            else:
                files[path] = {"size": st.st_size, "mtime": st.st_mtime_ns, "facts": {"sid": None, "facts": None}}
            continue
        except Exception as e:  # noqa: BLE001 — any failure reading one file keeps its previous facts
            complete = False
            fails.append("%s: %s" % (short(path), getattr(e, "strerror", None) or e))
            if prev:
                files[path] = prev
            continue
        files[path] = {"size": st.st_size, "mtime": st.st_mtime_ns, "facts": facts}
        counters["read"] += 1
    for path, prev in cache_files.items():
        if path in files:
            continue
        try:
            os.lstat(path)
            files[path] = prev  # still there, but the listing missed it
            complete = False
            fails.append("%s: missing from the listing" % short(path))
        except FileNotFoundError:
            pass
        except OSError as e:
            files[path] = prev
            complete = False
            fails.append("%s: %s" % (short(path), e.strerror or type(e).__name__))
    return files, complete


def read_codex_sid(path):
    problems = {}
    sid = ra.first_session_id(path, problems)
    if "unreadable file" in problems:
        raise OSError("unreadable")
    if problems or not (isinstance(sid, str) and ra.RE_SESSION.fullmatch(sid)):
        raise Unclaimed("session_meta line malformed or without a valid session id")
    return {"sid": sid, "facts": None}


def collect_effort(ctx):
    home = os.path.expanduser("~")
    cache = ctx["cache"]
    counters = {"read": 0, "cached": 0}
    tfiles, t_ok = refresh_files(cache.get("transcripts", {}), os.path.join(home, ".claude", "projects"),
                                 lambda n: n.endswith(".jsonl"), read_transcript, counters)
    calls = {}
    for path in sorted(tfiles):
        for uid, c in tfiles[path]["facts"]["calls"].items():
            prev = calls.get(uid)
            if prev is None or (prev["res"] is None and c["res"] is not None):
                calls[uid] = c
    sid_users = {}
    for uid, c in calls.items():
        for v in (c["res"]["sids"] if c["res"] else []) + c["in_sids"]:
            sid_users.setdefault(v, set()).add(uid)
    ccount = {"read": 0, "cached": 0, "full": 0}
    cfiles, c_ok = refresh_files(cache.get("codex", {}), os.path.join(home, ".codex", "sessions"),
                                 lambda n: n.startswith("rollout-") and n.endswith(".jsonl"), read_codex_sid, ccount)
    sessions = {}
    prev_codex = cache.get("codex", {})
    for path, entry in cfiles.items():
        f = entry["facts"]
        if f["sid"] not in sid_users:
            continue
        if f["facts"] is None:
            full, failed = None, False
            try:
                data = read_regular(path)
                data = data[:data.rfind(b"\n") + 1]  # a trailing partial line is deferred, not read
                if not data.strip():
                    raise LookupError("only a partial first line so far")
                objs = [json.loads(raw.decode("utf-8", "replace")) for raw in data.split(b"\n") if raw.strip()]
                if not objs or not all(isinstance(o, dict) for o in objs):
                    raise ValueError("no complete lines, or a line that is not an object")
                full = project_codex(ra.fact_from_lines(objs, {}, False))
                ccount["full"] += 1
            except LookupError:
                pass
            except (OSError, ValueError, RecursionError):
                failed = True
            if full is None:
                if failed:
                    c_ok = False
                    ccount.setdefault("failures", []).append("%s: complete lines could not be parsed" % path.replace(os.path.expanduser("~"), "~", 1))
                old = prev_codex.get(path)
                if not old or (old.get("facts") or {}).get("sid") != f["sid"] or not old["facts"].get("facts"):
                    continue
                entry = old  # keep the last good read with its own fingerprint, so the next run retries
                cfiles[path] = entry
            else:
                entry = dict(entry, facts=dict(f, facts=full))
                cfiles[path] = entry
        p = entry["facts"]["facts"]
        sessions.setdefault(f["sid"], []).append({
            "meta_ts": ra.parse_ts(p["meta_ts"]), "last_ts": ra.parse_ts(p["last_ts"]),
            "usage": p["usage"], "models": set(p["models"]), "bad": p["bad"]})
    ctx["new_cache"]["transcripts"] = tfiles
    ctx["new_cache"]["codex"] = cfiles

    member = {}

    def is_member(wd):
        if wd not in member:
            member[wd] = os.path.isdir(wd) and ra.common_dir(wd) == ctx["common"]
        return member[wd]

    now = ctx["now"]
    recs, pending = [], []
    for uid, c in calls.items():
        if not c["wd"] or not is_member(c["wd"]):
            continue
        started = ra.parse_ts(c["ts"])
        if started is None:
            continue
        if c["res"] is None:
            pending.append((started, c["tool"], uid))
            continue
        rec = {"tool_use_id": uid, "tool": c["tool"], "review_type": c["rt"], "started": ra.iso(started),
               "ended": None, "duration_s": None, "success": c["res"]["success"],
               "session_ids": c["res"]["sids"], "slots": c["res"]["slots"], "codex_files": 0, "models": [],
               "tokens_unknown": None}
        for f in ra.TOKEN_FIELDS:
            rec[f] = None
        ended = ra.parse_ts(c["res"]["ts"])
        if ended is not None and ended >= started:
            rec["ended"] = ra.iso(ended)
            rec["duration_s"] = (ended - started).total_seconds()
        inp = {"sessionId": c["in_sids"][0]} if c["in_sids"] else {}
        ra.measure_tokens(rec, {"input": inp}, sessions, sid_users, started, [0])
        recs.append(rec)

    sess = {}
    for path, entry in tfiles.items():
        f = entry["facts"]
        if f["sid"] and any(is_member(w) for w in f["cwds"]):
            s = sess.setdefault(f["sid"], {"last": None, "loads": []})
            if f["last"] and (s["last"] is None or f["last"] > s["last"]):
                s["last"] = f["last"]
            s["loads"] += f["loads"]
    ctx["sessions"] = sess
    ctx["pending"] = pending
    ctx["recs"] = recs
    footer = ("transcripts read %d, from cache %d; Codex logs: first line read %d, from cache %d; "
              "fully read %d" % (counters["read"], counters["cached"], ccount["read"], ccount["cached"], ccount["full"]))
    ctx["effort_incomplete"] = not (t_ok and c_ok)
    fails = counters.get("failures", []) + ccount.get("failures", [])
    ctx["effort_failures"] = "refresh at %s incomplete — %s%s" % (
        fmt(ctx["now"]), "; ".join(fails), "") if fails else None
    ctx["codex_sessions"] = sessions
    ctx["transcripts_missing"] = bool(counters.get("missing"))
    return t_ok and c_ok, footer


# ---- sections ---------------------------------------------------------------------------------------

def section(state, asof, body, note=None):
    return {"state": state, "asof": asof, "body": body, "note": note}


def ul(items):
    return "<ul>%s</ul>" % "".join("<li>%s</li>" % i for i in items) if items else ""


def sec_effort(ctx):
    complete, footer = collect_effort(ctx)
    base, head, cyc = ctx["base"], ctx["head"], ctx["cycles"]
    base_ct = ctx["base_ct"]
    now = ctx["now"]
    by_nonce, unattr = {}, []
    cutoff = now - datetime.timedelta(hours=WINDOW_HOURS)
    for r in ctx["recs"]:
        if base is None and ra.parse_ts(r["started"]) < cutoff:
            continue  # without a baseline only completed calls of the last 24 hours (spec §4)
        ns = ra.nonces_of(r) if r["slots"] else []
        if not ns:
            unattr.append(r)
        for n in ns:
            by_nonce.setdefault(n, []).append(r)
    rows, ctx["no_record"] = [], []
    if base is not None:
        for n in sorted(set(cyc) - set(by_nonce)):
            c = cyc[n]
            valid = "%d (self-reported in the closing curve)" % c["passes"] if c["state"] == "closed" and c["passes"] \
                else "validity unknown"
            rows.append(esc("cycle %s — %s %s · no gate call observed in the local logs (calls, time and tokens unknown) · "
                            "valid passes %s" % (n, c["kind"] or "cycle", c["state"], valid)))
    for n in sorted(by_nonce, key=lambda n: min(r["started"] for r in by_nonce[n])):
        rs = by_nonce[n]
        first = min(ra.parse_ts(r["started"]) for r in rs)
        if base is None:
            label = "closure and branch attribution unavailable: no baseline"
        elif n in cyc:
            c = cyc[n]
            label = "%s %s%s" % (c["kind"] or "cycle", c["state"], " (%s)" % c["reason"] if c["reason"] else "")
        elif first.timestamp() > base_ct:
            label = "no closing record observed in this range"
            ctx["no_record"].append((n, first))
        else:
            continue
        attempts = sorted({s for r in rs for s in r["slots"]
                           for m in [ra.RE_SLOT.fullmatch(s)] if (m.group(1) or m.group(3)) == n})
        valid = ("%d (self-reported in the closing curve)" % cyc[n]["passes"]
                 if base is not None and n in cyc and cyc[n]["state"] == "closed" and cyc[n]["passes"]
                 else "validity unknown")
        parts = ["cycle %s — %s" % (n, label), "gate calls %d" % len(rs), "call slots (attempts) %d" % len(attempts),
                 "valid passes %s" % valid,
                 "summed call duration %s" % ra.total([r["duration_s"] for r in rs], lambda x: "%.1f s" % x)]
        for f in ra.TOKEN_FIELDS:
            parts.append("%s %s" % (f, ra.total([r[f] for r in rs], str)))
        if base is None or n not in cyc or cyc[n]["state"] not in ("closed", "skipped"):
            parts.append("elapsed since first call %.0f s" % (now - first).total_seconds())
        rows.append(esc(" · ".join(parts)))
    recent = [r for r in unattr if base is None or ra.parse_ts(r["started"]).timestamp() > base_ct]
    if recent:
        rows.append(esc("calls without a cycle: " + ra.group_line(recent)))
    for started, tool, uid in sorted(ctx["pending"]):
        rows.append(esc("%s call %s: no result observed since %s" % (tool, uid[:16], fmt(started))))
    body = ul(rows) or "<p>No gate calls of this repository in scope.</p>"
    body += "<p>Scope: every worktree sharing this repository's git directory. Session run time: unknown (not recorded).</p>"
    body += "<p class=muted>%s</p>" % esc(footer)
    newest = [ra.parse_ts(r["ended"] or r["started"]) for r in ctx["recs"]] + [p[0] for p in ctx["pending"]] + \
        [f["last_ts"] for sid in {x for r in ctx["recs"] for x in r["session_ids"]} for f in ctx.get("codex_sessions", {}).get(sid, ())
         if f["last_ts"]]
    newest = [t for t in newest if t and t <= now]
    if ctx["transcripts_missing"]:
        return section("missing", "unknown", body, "no Claude Code transcript directory (~/.claude/projects)")
    return section("ok" if complete else "stale", fmt(max(newest)) if newest else "unknown", body,
                   None if complete else (ctx["effort_failures"] or "a source could not be read completely") +
                   "; the previous facts of those files are shown")


def sec_work(ctx):
    cwd, base, head = ctx["root"], ctx["base"], ctx["head"]
    rows = ["checkout root: %s" % esc(ctx["root"]), "branch: %s" % esc(ctx["branch"]),
            "HEAD: %s" % esc(head), "uncommitted paths: %s" % esc(ctx["dirty_count"])]
    if ctx["branch_changed"]:
        rows.append("<b class=warn>branch changed since monitor start (was %s); baseline still the one chosen at start</b>"
                    % esc(ctx["start_branch"]))
    cands, phases, unassoc, cand_dates = [], [], [], {}
    if base is None:
        rows.append("changed artifacts and phases: unavailable: no baseline (%s)" % esc(ctx["base_reason"]))
    else:
        changed = ctx["changed"]
        committed = ctx["committed"]
        stories = sorted(p for p in changed if p.startswith("docs/superpowers/stories/"))
        docs = sorted({p for p in list(changed) + list(committed)
                       if p.startswith(("docs/superpowers/specs/", "docs/superpowers/plans/"))})
        rows.append("stories, specs and plans this branch changes: %s" % (esc(", ".join(stories + docs)) or "none"))
        prov_stories = sorted({s for c in ctx["cycles"].values() for s in c["stories"]})
        cands = sorted(set(stories) | set(prov_stories))
        for st in cands:
            ev = []
            if st in committed:
                ev.append(("story", committed[st]))
            for p in docs:
                if p in ctx.get("doc_src", {}) and st in ctx["headers"].get(p, []):
                    ev.append(("spec written" if "/specs/" in p else "plan written", ctx["doc_src"][p]))
            for n, c in ctx["cycles"].items():
                if st in c["stories"] and c["state"] in ("closed", "skipped") and c["kind"] in CYCLE_PHASE:
                    ph = CYCLE_PHASE[c["kind"]]
                    ev.append((ph if c["state"] == "closed" else "%s skipped (reason in commit %s)" % (c["kind"], c["sha"][:12]),
                               c["sha"], ph))
            if ev:
                newest = max(((parse_iso(commit_time(cwd, e[1])), e[1]) for e in ev), key=lambda x: (x[0] is not None, x[0] or 0))
                if newest[0]:
                    cand_dates[st] = (newest[0], "%s (%s)" % (fmt(newest[0]), newest[1][:12]))
                best = max(ev, key=lambda e: PHASES.index(e[2] if len(e) > 2 else e[0]))
                phases.append("%s: last evidenced phase: <b>%s</b> (source %s); current activity unknown"
                              % (esc(st), esc(best[0]), esc(best[1][:12])))
            else:
                phases.append("%s: no evidenced phase; current activity unknown" % esc(st))
        for p in docs:
            if p in committed and not set(ctx["headers"].get(p, [])) & set(cands):
                unassoc.append("%s at %s, Story header: %s" % (esc(p), esc(committed[p][:12]),
                                                              esc(", ".join(ctx["headers"].get(p, [])) or "none")))
        for n, c in ctx["cycles"].items():
            if not set(c["stories"]) & set(cands) or c["state"] not in ("closed", "skipped"):
                unassoc.append("cycle %s %s (%s) at %s, stories: %s" % (
                    esc(n), esc(c["kind"] or "?"), esc(c["state"]), esc(c["sha"][:12]), esc(", ".join(c["stories"]) or "none named")))
    ho = handover(ctx, "work")
    task_desc = None
    if ho:
        for h, b in md_sections(ho[2]):
            if h.lower().startswith("next"):
                task_desc = (h, b)
                break
    for c in cands:  # the newest of every associated observation: phase evidence, any cycle, the working tree
        obs = [cand_dates[c]] if c in cand_dates else []
        for cy in ctx["cycles"].values():
            if c in cy["stories"]:
                t = datetime.datetime.fromtimestamp(cy["ct"], datetime.timezone.utc)
                obs.append((t, "%s (%s)" % (fmt(t), cy["sha"][:12])))
        if ctx["changed"].get(c) and dirty(ctx, c):
            try:
                t = datetime.datetime.fromtimestamp(os.lstat(os.path.join(cwd, c)).st_mtime, datetime.timezone.utc)
                obs.append((t, "%s (uncommitted)" % fmt(t)))
            except OSError:
                pass
        if obs:
            cand_dates[c] = max(obs, key=lambda o: o[0])
    dated = ["%s (last evidence %s)" % (c, cand_dates[c][1] if c in cand_dates else "none in this range") for c in cands]
    if len(cands) == 1:
        rows.append("inferred current story (only candidate): %s" % esc(dated[0]))
    else:
        rows.append("current task not established%s" % (" — candidates: " + esc("; ".join(dated)) if cands else ""))
    if task_desc:
        rows.append("handover %s, section “%s” (modified %s):<pre>%s</pre>"
                    % (esc(ho[0]), esc(task_desc[0]), esc(fmt(ho[1])), esc(task_desc[1])))
    obs = []
    for sha, subj, ct in ctx["wips"]:
        obs.append("Gate-B snapshot %s at %s; review state unknown" % (esc(sha[:12]), esc(ct)))
    for started, tool, uid in sorted(ctx.get("pending", [])):
        obs.append("%s call: no result observed since %s" % (esc(tool), esc(fmt(started))))
    for sid, s in sorted(ctx.get("sessions", {}).items(), key=lambda kv: kv[1]["last"] or "", reverse=True)[:3]:
        obs.append("session %s: last entry %s (session-wide — may include work in other repositories)"
                   % (esc(sid[:8]), esc(s["last"] or "unknown")))
    body = ul(rows) + ("<h3>Phases</h3>" + ul(phases) if phases else "") + \
        ("<h3>Unassociated evidence</h3>" + ul(unassoc) if unassoc else "") + \
        "<h3>Observations (not phases, not current activity)</h3>" + (ul(obs) or "<p>none</p>")
    return section("ok", ctx["last_commit_time"], body)


def sec_progress(ctx):
    rows = []
    if ctx["base"] is None:
        rows.append("closed cycles: unavailable: no baseline (%s)" % esc(ctx["base_reason"]))
    else:
        done = sorted((c for c in ctx["cycles"].values() if c["state"] in ("closed", "skipped")), key=lambda c: c["ct"])
        if done:
            c = done[-1]
            n = [k for k, v in ctx["cycles"].items() if v is c][0]
            rows.append("last %s cycle: %s %s at commit %s (stories: %s)" % (
                esc(c["state"]), esc(c["kind"] or "?"), esc(n), esc(c["sha"][:12]), esc(", ".join(c["stories"]) or "none named")))
        else:
            rows.append("no closed or skipped cycle recorded in this range")
        other = [(k, v) for k, v in ctx["cycles"].items() if v["state"] not in ("closed", "skipped")]
        for k, v in other:
            rows.append("cycle %s: %s (%s) — not closed" % (esc(k), esc(v["state"]), esc(v["reason"] or "")))
    rows.append("last commit: %s %s" % (esc(ctx["head"][:12]), esc(ctx["last_commit_time"])))
    return section("ok", ctx["last_commit_time"], ul(rows))


def observed(ctx, section, when):
    """Record the time of one observation a section shows (a datetime or an ISO string)."""
    if isinstance(when, str):
        when = ra.parse_ts(when) or parse_iso(when)
    if when:
        ctx.setdefault("obs", {}).setdefault(section, []).append(when)


def parse_iso(text):
    try:
        return datetime.datetime.fromisoformat(text).astimezone(datetime.timezone.utc)
    except (ValueError, TypeError):
        return None


def asof(ctx, section):
    times = ctx.get("obs", {}).get(section)
    return fmt(max(times)) if times else "unknown"


def source(ctx, section, key, fn):
    """One source's value. A failed read returns that source's last good value (or None) and records the
    failure for the section, which then shows stale; the section's other sources still refresh."""
    if key in ctx.setdefault("src_now", {}):
        value, err = ctx["src_now"][key]
    else:
        try:
            value, err = fn(), None
            ctx["state"].setdefault("src", {})[key] = value
        except Exception as e:  # noqa: BLE001 — any failure of one source keeps its last good value
            value, err = ctx["state"].setdefault("src", {}).get(key), "%s: %s (at %s)" % (key, e, fmt(ctx["now"]))
        ctx["src_now"][key] = (value, err)
    if err:
        ctx.setdefault("src_fail", {}).setdefault(section, []).append(err)
    return value


def handover(ctx, section):
    """The newest handover as (name, modified, text), or None."""
    def read():
        ho = newest_handover(ctx["root"])
        return (ho[0], datetime.datetime.fromtimestamp(ho[1], datetime.timezone.utc),
                read_text(ctx["root"], ".context/" + ho[0])) if ho else None
    return source(ctx, section, "handover", read)


def sec_open(ctx):
    root, rows, readable = ctx["root"], [], False
    ho = handover(ctx, "open")
    if ho:
        readable = True
        observed(ctx, "open", ho[1])
        hits = [(h, b) for h, b in md_sections(ho[2]) if RE_OPEN_HEAD.search(h)]
        for h, b in hits:
            none = re.match(r"(- )?none\b", b.strip(), re.I)
            rows.append("handover %s (not in git, modified %s) — “%s”%s:<pre>%s</pre>" % (
                esc(ho[0]), esc(fmt(ho[1])), esc(h), " — source states none" if none else "", esc(b)))
    if ctx["base"] is not None:
        for p in sorted(ctx["changed"]):
            if not p.endswith(".md") or ctx["changed"][p] == "D":
                continue
            def read_artifact():
                rev = revision(ctx, p, ctx["head"])
                if rev.endswith("uncommitted"):
                    when = fmt(datetime.datetime.fromtimestamp(os.lstat(os.path.join(root, p)).st_mtime, datetime.timezone.utc))
                else:
                    lc = last_commit(root, p, ctx["head"])
                    when = lc.split()[1] if lc else None
                return read_text(root, p), rev, when  # a retained value keeps its own revision and time
            got = source(ctx, "open", "file " + p, read_artifact)
            if got is None:
                continue
            text, rev, when = got
            readable = True
            observed(ctx, "open", when)
            if p.startswith("docs/superpowers/stories/"):
                for h, b in md_sections(text):
                    if re.match(r"(\d+\.\s*)?open questions", h, re.I):
                        none = re.match(r"(- )?none\b", b.strip(), re.I)
                        rows.append("%s §5 (%s)%s:<pre>%s</pre>" % (esc(p), esc(rev), " — source states none" if none else "", esc(b)))
            for line in text.split("\n"):
                if re.match(r"\s*(?:[-*+]\s+)?\*\*Unaccounted:\*\*", line):
                    rows.append("%s (%s): %s" % (esc(p), esc(rev), esc(line.strip())))
        for n, c in ctx["cycles"].items():
            if c["state"] not in ("closed", "skipped"):
                readable = True
                observed(ctx, "open", datetime.datetime.fromtimestamp(c["ct"], datetime.timezone.utc))
                rows.append("cycle %s: %s (%s)" % (esc(n), esc(c["state"]), esc(c["reason"] or "")))
    for n, first in ctx.get("no_record", []):
        readable = True
        observed(ctx, "open", first)
        rows.append("cycle %s: no closing record observed in this range (first call %s; transcripts)" % (esc(n), esc(fmt(first))))
    if not readable and not rows:
        return section("ok", "unknown", "<p><b>unknown</b> — no source of open points could be read</p>")
    return section("ok", asof(ctx, "open"), ul(rows) or "<p>Sources read; none of them lists an open point.</p>")


def blob_lines(data):
    if b"\0" in data:
        return None
    return data.count(b"\n") + (1 if data and not data.endswith(b"\n") else 0)


def sec_growth(ctx):
    root, base = ctx["root"], ctx["base"]
    rows, totals, unk = [], {}, {}
    now_files = [p for p in git_text(("ls-files", "-z", "--cached", "--others", "--exclude-standard"), root).split("\0")
                 if p and not p.startswith(".context/")]
    cur, unknown, retained, measured_at = {}, set(), [], {}

    def measure(full):
        st = os.lstat(full)
        if stat.S_ISLNK(st.st_mode):
            data = os.readlink(full).encode()
        elif stat.S_ISREG(st.st_mode):
            data = read_regular(full)
        else:
            return "skip"
        return [len(data), blob_lines(data), hashlib.new(ctx["object_format"], b"blob %d\0" % len(data) + data).hexdigest(),
                fmt(ctx["now"]), file_mode(full, ctx, p)]
    for p in now_files:
        full = os.path.join(root, p)
        try:
            os.lstat(full)
        except FileNotFoundError:
            continue
        except OSError:
            pass  # exists or not cannot be told: measure() fails the same way, so it is listed as unknown
        m = source(ctx, "growth", "size " + p, lambda: measure(full))  # an unreadable file keeps its last size
        if m is None or m == "skip":
            unknown.add(p)  # exists but never measured, or not a file: size unknown, not deleted
        else:
            cur[p] = (m[0], m[1], m[2], m[4] if len(m) > 4 else None)
            if ctx["src_now"]["size " + p][1]:  # a retained measurement shows when it was taken
                retained.append(m[3])
                measured_at[p] = m[3]
    old = {}
    if base is not None:
        for line in git_text(("ls-tree", "-r", "-z", "--long", base), root).split("\0"):
            if not line:
                continue
            meta, path = line.split("\t", 1)
            parts = meta.split()
            if parts[1] != "blob" or path.startswith(".context/"):
                continue
            old[path] = [int(parts[3]), None, parts[2], parts[0]]
        for p in old:
            if p in cur and cur[p][2] == old[p][2]:
                old[p][1] = cur[p][1]  # same blob: same line count
        need = [p for p in old if p not in cur or cur[p][2] != old[p][2]]
        for p in need:
            rc, data = git(("cat-file", "blob", old[p][2]), root)
            if rc == 0:
                old[p][1] = blob_lines(data)
    for p in sorted(unknown):
        g = next(name for name, test in GROUPS if test(p))
        totals.setdefault(g, [0, 0, 0])
        unk[g] = unk.get(g, 0) + 1
        rows.append((g, p, "unreadable (size unknown)", None, None, None, None))
    for p in sorted((set(cur) | set(old)) - unknown):
        g = next(name for name, test in GROUPS if test(p))
        t = totals.setdefault(g, [0, 0, 0])
        c, o = cur.get(p), old.get(p)
        t[0] += c[0] if c else 0
        t[1] += o[0] if o else 0
        if base is None:
            rows.append((g, p, "current (no baseline)" + (" (size kept from %s; current read failed)" % measured_at[p]
                                                          if p in measured_at else ""), None, c[0], None, c[1]))
            continue
        if c and o and c[2] == o[2] and (c[3] is None or modes_equal(o[3], c[3], ctx)):
            if p in measured_at:
                rows.append((g, p, "unchanged (size kept from %s; current read failed)" % measured_at[p], o[0], c[0], o[1], c[1]))
            continue
        status = "added" if not o else "deleted" if not c else "modified"
        if status == "modified" and worktree_state(ctx).get(p) == "?":
            status = "possibly modified (normalized or filtered file; raw bytes not compared)"
            unk[g] = unk.get(g, 0) + 1
        else:
            t[2] += 1
        if p in measured_at:
            status += " (size kept from %s; current read failed)" % measured_at[p]
        rows.append((g, p, status, o[0] if o else 0, c[0] if c else 0,
                     o[1] if o else 0, c[1] if c else 0))
    head = ("<p>Branch comparison against <b>%s</b> (%s) — not the effort or growth of a single story. Checkout: %s</p>"
            % (esc(base or "unavailable"), esc(ctx["base_how"]), esc(root)))
    if base is None:
        head += "<p>Net change unavailable: no baseline (%s). Pass --base &lt;commit&gt;.</p>" % esc(ctx["base_reason"])
    trs = "".join("<tr><td>%s</td><td>%d</td><td>%s</td><td>%s</td></tr>" % (
        esc(g), totals[g][0], "unavailable" if base is None else "%+d" % (totals[g][0] - totals[g][1]),
        ("unavailable" if base is None else str(totals[g][2])) + (" (%d unreadable or possibly changed, not counted)" % unk[g] if unk.get(g) else ""))
        for g, _ in GROUPS if g in totals)
    body = head + "<table><tr><th>group</th><th>bytes now</th><th>net bytes</th><th>files changed</th></tr>%s</table>" % trs

    def ln(v):
        return "n/a" if v is None else str(v)

    def sizes(ob, cb):
        if cb is None:
            return "unknown"
        return "unavailable → %d" % cb if ob is None else "%d → %d (%+d)" % (ob, cb, cb - ob)
    if rows:
        body += "<table><tr><th>group</th><th>file</th><th>status</th><th>bytes before → now</th><th>lines before → now</th></tr>%s</table>" % "".join(
            "<tr><td>%s</td><td>%s</td><td>%s</td><td>%s</td><td>%s → %s</td></tr>" % (
                esc(g), esc(p), s, sizes(ob, cb), "unavailable" if ob is None else ln(ol), ln(cl))
            for g, p, s, ob, cb, ol, cl in rows)
    hg = source(ctx, "growth", "handover listing", lambda: handover_growth(ctx))
    body += hg if hg is not None else "<h3>Handovers</h3><p>unknown — the handover directory could not be read</p>"
    asof_text = fmt(ctx["now"]) + (" (retained sizes measured from %s)" % min(retained) if retained else "")
    return section("ok", asof_text, body)


def handover_growth(ctx):
    d = os.path.join(ctx["root"], ".context")
    seen = json.loads(json.dumps(ctx["cache"].get("handovers", {})))  # a deep copy: nothing mutates the published cache
    rows, now = [], fmt(ctx["now"])
    try:
        names = sorted(n for n in os.listdir(d) if re.fullmatch(r"handover-[^/]+\.md", n))
    except FileNotFoundError:
        names = []
    present = set()
    for n in names:
        try:
            st = os.lstat(os.path.join(d, n))
        except FileNotFoundError:
            continue  # removed between listing and lookup: shown as deleted below
        if not stat.S_ISREG(st.st_mode):
            present.add(n)  # still there, but not measurable: kept, not deleted
            rows.append("%s: not a regular file; size unknown" % esc(n))
            continue
        present.add(n)
        try:
            data = read_regular(os.path.join(d, n))
        except OSError as e:
            ctx.setdefault("src_fail", {}).setdefault("growth", []).append(
                "handover %s: %s (at %s)" % (n, e.strerror or type(e).__name__, fmt(ctx["now"])))
            f = seen.get(n)
            rows.append("%s: unreadable now; last observed size %s bytes" % (esc(n), f.get("last_size", "unknown") if f else "unknown"))
            continue
        size, lines = len(data), blob_lines(data)
        first = seen.get(n)
        if not first:
            seen[n] = first = {"first_size": size, "first_lines": lines, "first_seen": now}
            change = "first observed now"
        else:
            change = "%+d bytes since first observed at %s — not the branch baseline" % (size - first["first_size"], first["first_seen"])
        first.update(last_size=size, deleted=False)
        rows.append("%s: %d bytes, %s lines, modified %s; %s" % (
            esc(n), size, lines, esc(fmt(datetime.datetime.fromtimestamp(st.st_mtime, datetime.timezone.utc))), esc(change)))
    for n, f in seen.items():
        if n not in present:
            f["deleted"] = True
            rows.append("%s: deleted (last observed size %d bytes; first observed %s)" % (esc(n), f.get("last_size", 0), esc(f["first_seen"])))
    ctx["new_cache"]["handovers"] = seen
    return "<h3>Handovers (not in git, no baseline)</h3>" + (ul(rows) or "<p>none</p>")


def installed_source(root):
    """Rows and the installed version from installed_plugins.json; raises RuntimeError when the file
    cannot be read or has an unrecognized shape."""
    rows, installed = [], None
    path = os.path.join(os.path.expanduser("~"), ".claude", "plugins", "installed_plugins.json")
    try:
        when = fmt(datetime.datetime.fromtimestamp(os.stat(path).st_mtime, datetime.timezone.utc))
        doc = json.loads(read_regular(path).decode("utf-8"))
    except FileNotFoundError:
        return ["<b>installed: unknown</b> (no installed_plugins.json)"], None, None
    except (OSError, UnicodeDecodeError) as e:
        raise RuntimeError("installed_plugins.json cannot be read (%s)" % type(e).__name__)
    except ValueError:
        raise RuntimeError("installed_plugins.json is not valid JSON")
    plugins = doc.get("plugins") if isinstance(doc, dict) else None
    if not isinstance(plugins, dict):
        raise RuntimeError("installed_plugins.json has an unrecognized shape")
    recs = plugins.get(PLUGIN, [])
    if not isinstance(recs, list):
        raise RuntimeError("installed_plugins.json has an unrecognized shape")
    applying = [r for r in recs if isinstance(r, dict) and (r.get("scope") == "user" or (
        r.get("scope") == "project" and root in [v for v in r.values() if isinstance(v, str)]))]
    for r in recs:
        if isinstance(r, dict):
            rows.append("installed record: scope %s, version %s, updated %s, commit %s" % tuple(
                esc(r.get(k, "?")) for k in ("scope", "version", "lastUpdated", "gitCommitSha")))
    if len(applying) == 1:
        installed = applying[0].get("version")
        if not isinstance(installed, str) or not installed.strip():
            raise RuntimeError("installed_plugins.json has no valid version string")
        rows.append("<b>installed: %s</b>" % esc(installed))
    elif applying:
        rows.append("<b>installed: ambiguous (%d applying records)</b>" % len(applying))
    else:
        rows.append("<b>installed: unknown</b> (%s)" % ("no applying record" if recs else "no dev-workflow entry"))
    return rows, installed, when


def sec_version(ctx):
    root, rows, warn = ctx["root"], [], []
    observed(ctx, "version", ctx["last_commit_time"])
    inst_rows, installed, inst_when = source(ctx, "version", "installed_plugins.json", lambda: installed_source(root)) or \
        (["<b>installed: unknown</b> (the file could not be read)"], None, None)
    observed(ctx, "version", inst_when)
    rows += inst_rows
    declared = None
    rc, out = git(("show", "%s:%s" % (ctx["head"], MANIFEST)), root)
    try:
        declared = json.loads(out.decode()).get("version") if rc == 0 else None
    except ValueError:
        pass
    rows.append("declared at HEAD: %s" % esc(declared or "unknown"))
    def read_wt():
        full = os.path.join(root, MANIFEST)
        try:
            when = fmt(datetime.datetime.fromtimestamp(os.stat(full).st_mtime, datetime.timezone.utc))
            doc = json.loads(read_text(root, MANIFEST))
        except FileNotFoundError:
            return "absent", None
        if not isinstance(doc, dict) or not isinstance(doc.get("version"), str):
            raise ValueError("no version string")
        return doc["version"], when
    wt, wt_when = source(ctx, "version", "working-tree manifest", read_wt) or (None, None)
    observed(ctx, "version", wt_when)
    if wt is not None and wt != declared:
        rows.append("<b class=warn>declared in the working tree: %s</b>%s" % (esc(wt), " (file modified %s)" % esc(wt_when) if wt_when else ""))
    if installed and declared and installed != declared:
        warn.append("installed %s differs from declared %s" % (installed, declared))
    sess = ctx.get("sessions", {})
    loaded = []
    ordered = sorted(sess.items(), key=lambda kv: kv[1]["last"] or "", reverse=True)
    for sid, s in ordered:
        if not s["loads"]:
            loaded.append("session %s, last entry %s (session-wide): loaded unknown — no qualifying load observed"
                          % (esc(sid[:8]), esc(s["last"] or "unknown")))
            continue
        versions = sorted({v for _c, v, _t in s["loads"]})
        comps = sorted({"%s %s (%s)" % (c, v, t or "time unknown") for c, v, t in s["loads"]})
        for _c, _v, t in s["loads"]:
            observed(ctx, "version", t)
        verdict = versions[0] if len(versions) == 1 else "conflicting (%s)" % ", ".join(versions)
        loaded.append("session %s, last entry %s (session-wide): loaded %s — %s" % (
            esc(sid[:8]), esc(s["last"] or "unknown"), esc(verdict), esc("; ".join(comps))))
        if installed and ordered.index((sid, s)) < 3 and versions != [installed]:
            warn.append("loaded %s in session %s differs from installed %s" % (", ".join(versions), sid[:8], installed))
    rows.append("loaded (skill loads only; commands and hooks: unknown):" + (ul(loaded) or " unknown — no session of this repository recorded a skill load"))
    for f in RULE_FILES:
        lc = last_commit(root, f, ctx["head"])
        d = dirty(ctx, f)
        observed(ctx, "version", lc.split()[1] if lc else None)
        rows.append("rule file %s: last commit %s%s" % (esc(f), esc(lc or "none"), " <b class=warn>— %s changes</b>" % esc(d) if d else ""))
        if d:
            warn.append("%s has %s changes" % (f, d))
    rows.append("The rule state on disk is not the state a running session loaded.")
    body = (("<p class=warn>%s</p>" % esc("; ".join(warn))) if warn else "") + ul(rows)
    return section("ok", asof(ctx, "version"), body)


# ---- collection and page ----------------------------------------------------------------------------

def collect(state, hooks):
    root = state["root"]
    head, branch = head_state(root)
    if head is None:
        raise RuntimeError("HEAD does not name a commit")
    if hooks.get("between"):
        hooks["between"]()
    ctx = {"root": root, "head": head, "branch": branch, "now": now_utc(), "common": state["common"],
           "base": state["base"], "base_how": state["base_how"], "base_reason": state["base_reason"],
           "start_branch": state["start_branch"], "branch_changed": branch != state["start_branch"],
           "cache": state["cache"], "new_cache": {"v": 1}, "state": state}
    ctx["object_format"] = git_text(("rev-parse", "--show-object-format"), root).strip() or "sha1"
    ctx["base_ct"] = int(git_text(("show", "-s", "--format=%ct", ctx["base"]), root).strip()) if ctx["base"] else 0
    ctx["last_commit_time"] = git_text(("show", "-s", "--format=%cI", head), root).strip()
    wt = worktree_state(ctx)
    ctx["dirty_count"] = "%d%s" % (len(wt), " (%d possibly: normalized or filtered files, not compared)" % list(wt.values()).count("?")
                                   if "?" in wt.values() else "")
    if ctx["base"]:
        ctx["cycles"] = cycles(root, ctx["base"], head)
        ctx["changed"] = changed_paths(ctx, ctx["base"], head)
        ctx["committed"] = committed_paths(root, ctx["base"], head)
        ctx["headers"] = {}
        ctx["doc_src"] = {}
        for p in set(ctx["changed"]) | set(ctx["committed"]):
            if p.startswith(("docs/superpowers/specs/", "docs/superpowers/plans/")):
                shas = git_text(("log", "--format=%H", "%s..%s" % (ctx["base"], head), "--", p), root).split()
                for sha in shas:  # newest first: the last committed version of the artifact in the range
                    rc, out = git(("show", "%s:%s" % (sha, p)), root)
                    if rc == 0:
                        ctx["headers"][p] = story_header(out.decode("utf-8", "replace"))
                        ctx["doc_src"][p] = sha
                        break
        ctx["wips"] = [tuple(l.split("\x01")) for l in git_text(
            ("log", "--format=%H\x01%s\x01%cI", "%s..%s" % (ctx["base"], head)), root).split("\n")
            if l and re.match(r"wip", l.split("\x01")[1], re.I)]
    else:
        ctx["cycles"], ctx["changed"], ctx["committed"], ctx["headers"], ctx["wips"] = {}, {}, {}, {}, []
    out = {}
    fail = hooks.get("fail", ())
    for name in ("effort", "work", "progress", "open", "growth", "version"):
        try:
            if name in fail:
                raise RuntimeError("forced failure (test hook)")
            out[name] = globals()["sec_" + name](ctx)
            if ctx.get("src_fail", {}).get(name):
                out[name] = dict(out[name], state="stale", note="last good value kept for: " + "; ".join(ctx["src_fail"][name]))
            if name == "effort":
                state["effort_data"] = {k: ctx[k] for k in ("sessions", "pending", "recs", "no_record")}
        except Discarded:
            raise
        except Exception as e:  # one source failing keeps the others; its previous value goes stale
            prev = state["sections"].get(name)
            note = "refresh failed at %s: %s" % (fmt(ctx["now"]), e)
            out[name] = dict(prev, state="stale", note=note) if prev else section("error", "unknown", "", note)
            if name == "effort":  # dependents keep the last good effort data, marked stale below
                ctx.update(state.get("effort_data", {}))
                ctx["effort_incomplete"] = True
    if ctx.get("effort_incomplete"):
        for name in ("work", "open", "version"):
            if out[name]["state"] == "ok":
                out[name] = dict(out[name], state="stale",
                                 note="session observations kept from earlier reads: " + (ctx.get("effort_failures") or
                                                                                          "effort collection failed"))
    if hooks.get("before_check"):
        hooks["before_check"]()
    if name_moved(root, head, branch):
        raise Discarded()
    ctx["now"] = now_utc()  # publication time: after collection, not before it
    for k in ("transcripts", "codex", "handovers"):
        ctx["new_cache"].setdefault(k, state["cache"].get(k, {}))
    return ctx, out


def name_moved(root, head, branch):
    return head_state(root) != (head, branch)


def render(ctx, sections, state, banner=None):
    watch = state["watch"]
    gen = ctx["now"] if ctx else state.get("published") or now_utc()
    meta = '<meta http-equiv="refresh" content="%d">' % watch if watch else ""
    script = ""
    if watch:
        script = """<script>(function(){var g=%d,i=%d;function c(){if(Date.now()-g>3*i*1000){var b=document.getElementById('age');
b.style.display='block';}}c();setInterval(c,5000);})();</script>""" % (int(gen.timestamp() * 1000), watch)
    parts = ["<!doctype html><html lang=en><head><meta charset=utf-8>%s<title>Status view</title><style>"
             "body{font:14px/1.45 system-ui,sans-serif;margin:16px;max-width:1100px;color:#1d1d1f;background:#fff}"
             "section{border:1px solid #ccc;border-radius:6px;padding:8px 12px;margin:12px 0}"
             ".ok{color:#1a7f37}.stale,.warn{color:#9a6700}.error,.missing{color:#cf222e}.muted{color:#666}"
             "pre{white-space:pre-wrap;background:#f6f8fa;padding:6px}table{border-collapse:collapse}"
             "td,th{border:1px solid #ddd;padding:2px 6px;text-align:left}#age{display:none}"
             "@media (prefers-color-scheme: dark){body{background:#111;color:#ddd}pre{background:#222}}"
             "</style></head><body>" % meta, "<h1>Status view</h1>"]
    if watch:
        parts.append("<p id=age class=warn><b>stale: no successful refresh observed within three intervals</b> "
                     "(last success %s; last failure %s)</p>" % (esc(state.get("last_success") or "none"),
                                                                 esc(state.get("last_failure") or "none")))
    if banner:
        parts.append("<p class=error><b>%s</b></p>" % esc(banner))
    parts.append("<p>generated %s · %s · baseline %s (%s)</p>" % (
        esc(fmt(gen)), "watch every %d s" % watch if watch else "one-shot run", esc(state["base"] or "unavailable"),
        esc(state["base_how"])))
    for name in SECTIONS:
        s = sections.get(name) or section("missing", "unknown", "")
        parts.append("<section><h2>%s <span class=%s>[%s]</span></h2><p class=muted>as of %s%s</p>%s</section>" % (
            TITLES[name], s["state"], s["state"], esc(s["asof"]), (" — " + esc(s["note"])) if s.get("note") else "", s["body"]))
    parts.append("<p class=muted>No completion figure and no composite score are computed.</p>%s</body></html>" % script)
    return "".join(parts).encode("utf-8")


def run_once(state, dfd, hooks):
    for _ in range(3):
        try:
            ctx, sections = collect(state, hooks)
            break
        except Discarded:
            continue
    else:
        raise RuntimeError("HEAD kept moving during collection")
    candidate = dict(state, last_success=fmt(ctx["now"]), published=ctx["now"])
    write_atomic(dfd, "index.html", render(ctx, sections, candidate))  # the page first: a cache without its page is never left
    write_atomic(dfd, "cache.json", json.dumps(ctx["new_cache"], sort_keys=True).encode())
    state.update(sections=sections, cache=ctx["new_cache"], last_success=candidate["last_success"],
                 published=ctx["now"])  # the published state changes only once the page is replaced


def main(argv, hooks=None):
    hooks = hooks or {}
    args, base_arg, watch = argv[1:], None, 0
    while args:
        if args[0] == "--base" and len(args) > 1:
            base_arg, args = args[1], args[2:]
        elif args[0] == "--watch" and len(args) > 1 and re.fullmatch(r"[0-9]{1,6}", args[1]) and int(args[1]) >= 5:
            watch, args = int(args[1]), args[2:]
        else:
            return fail("usage: status-view.py [--base <commit>] [--watch <seconds, at least 5>]")
    os.environ["GIT_OPTIONAL_LOCKS"] = "0"  # no git command of the report may take an optional lock or refresh the index
    root = os.getcwd()
    rc, out = git(("--version",), root)
    m = re.search(rb"(\d+)\.(\d+)", out) if rc == 0 else None
    if not m or (int(m.group(1)), int(m.group(2))) < (2, 36):
        return fail("git 2.36 or later is required")
    rc, out = git(("rev-parse", "--show-toplevel"), root)
    if rc != 0:
        return fail("not inside a git checkout")
    root = os.fsdecode(out.rstrip(b"\n"))
    rc, out = git(("config", "--get-regexp", r"^(extensions\.partialclone|remote\..*\.(promisor|partialclonefilter))$"), root)
    if rc not in (0, 1):  # 1 means no such key
        return fail("the repository configuration cannot be read")
    for line in out.decode("utf-8", "replace").splitlines():
        key, _, value = line.partition(" ")
        if not key.endswith(".promisor") or value.strip().lower() not in ("false", "no", "off", "0"):
            return fail("partial clones are not supported (reading history could fetch objects)")
    try:
        rfd = os.open(root, os.O_RDONLY | os.O_DIRECTORY)
        dfd = open_dir("status", open_dir(".context", rfd))
        for name in ("index.html", "cache.json", ".lock"):
            check_target(dfd, name)
        lock = take_lock(dfd)
        for name in ("index.html", "cache.json"):
            check_target(dfd, name)
        cache = read_cache(dfd) or {"v": 1}
    except Refused as e:
        return fail(str(e))
    base, how, reason = resolve_baseline(root, base_arg)
    state = {"root": root, "common": ra.common_dir(root), "base": base, "base_how": how, "base_reason": reason,
             "start_branch": head_state(root)[1], "cache": cache, "sections": {}, "watch": watch}
    try:
        return watch_loop(state, dfd, hooks, watch)
    finally:
        os.close(lock)


def watch_loop(state, dfd, hooks, watch):
    n = 0
    sleep = hooks.get("sleep", time.sleep)
    try:
        while True:
            n += 1
            try:
                run_once(state, dfd, hooks)
            except Refused as e:
                return fail(str(e))
            except Exception as e:  # the whole collection failed: keep the previous page, add a banner
                state["last_failure"] = fmt(now_utc())
                if not watch:
                    return fail("no page written: %s" % e)
                banner = "refresh failed at %s: %s" % (state["last_failure"], e)
                if state["sections"]:
                    banner += " — the page below is the previous one"
                write_atomic(dfd, "index.html", render(None, state["sections"], state, banner))
            if not watch or (hooks.get("iterations") and n >= hooks["iterations"]):
                break
            if hooks.get("after_collection"):
                hooks["after_collection"]()
            sleep(watch)
    except KeyboardInterrupt:
        pass
    return 0


def fail(msg):
    sys.stderr.buffer.write(("status-view: %s\n" % ra.shown(msg)).encode("utf-8", "backslashreplace"))
    sys.stderr.flush()
    return 1


if __name__ == "__main__":
    if hasattr(sys, "set_int_max_str_digits"):
        sys.set_int_max_str_digits(0)
    sys.exit(main(sys.argv))
