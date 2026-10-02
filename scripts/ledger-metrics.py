#!/usr/bin/env python3
"""Read-only report over docs/hardening-log.md and the review-cycle records in git commit bodies.

Spec: docs/superpowers/specs/2026-10-01-passive-metrics-design.md
Usage: python3 scripts/ledger-metrics.py [<ref>]   (default HEAD)

Reads the ledger and the commit bodies at ONE resolved commit, never the working tree, and
prints a report on stdout. It writes no file, ref or config itself; git can still write when
the caller's environment tells it to (spec §2), which the report header states.
Standard library only; Python 3.8 or later.
"""
import os
import re
import subprocess
import sys

LEDGER = "docs/hardening-log.md"
ALLOWED_RUNGS = ("1 prose", "2 lint", "3 type", "4 test", "P std", "pending")
FIC2 = ("  findings 14,24,12,3,6,6,2 (? 0)  blockers 3,4,0,0,0,0,0 (? 0)"
        "  majors 5,13,6,2,5,?,? (? 2)")
CAVEATS = (
    "1. The curves are author-written and unchecked. Nothing compares them against the validated"
    " pass files, so they are self-reported and not measurement.",
    "2. The cycles reviewed different artifacts, so a difference is evidence about the population"
    " as much as about the rule.",
    "3. No demotion figure is derivable. That would need one finding classified under both rules,"
    " and nothing records that.",
)
CANNOT = """
== What this report cannot answer
- Unlogged recurrences: the ledger only knows recurrences someone hardened.
- Whether a guard held: row succession is not guard failure, and a missing later row is not success.
- Cycles with no record at all: before 0.11.0 the curve was a habit, not a rule. A cycle with no provenance line, curve or skip record is invisible; a malformed record shows up as unparsed only when its line still starts like a record ("cycle <token>;").
- Nonce attribution: records are grouped by nonce, which is collision-resistant, not collision-proof; two cycles that drew the same nonce read as one.
- Findings files: this script does not read .context/. It counts only what commit bodies say.
- Undecodable bytes: both sources are read as UTF-8 and an invalid byte becomes U+FFFD before anything is grouped, so two fingerprints or paths differing only in invalid bytes count as one. Control characters are shown as \\xNN, which can look like a literal backslash sequence.
- A shallow boundary that appears and disappears during the run: shallow state is checked before and after reading history, not during it.
- Whether a curve is true: see point 1 above.
- Cost and duration: that is vision step 2c's telemetry, out of scope here."""


def die(msg):
    sys.stderr.buffer.write(("ledger-metrics: %s\n" % msg).encode("utf-8", "backslashreplace"))
    sys.stderr.flush()
    sys.exit(1)


def git(*args):
    """Run a read-only git command; return (returncode, stdout bytes). Stderr is not shown,
    so the only error a caller sees is this script's own one-line message."""
    try:
        # --no-replace-objects and an empty graft file: read the objects and history the SHA
        # names, not `git replace` substitutes or legacy grafts. Both affect reading only.
        env = dict(os.environ, GIT_GRAFT_FILE=os.devnull)
        env.pop("GIT_SHALLOW_FILE", None)  # the repository's own shallow file, not an override
        p = subprocess.run(("git", "--no-replace-objects") + args, env=env,
                           stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    except OSError:
        die("git could not be run")
    return p.returncode, p.stdout


# ---- grammar (CLAUDE.md §5 Mechanics) ------------------------------------------------------

NONCE = r"[a-z0-9]{8,16}"
FIELD = r"(none \(pre-rule\)|" + NONCE + r")"
KIND = r"(Gate-A spec|Gate-A plan|Gate B)"
CANDIDATE = re.compile(r"^cycle (none \(pre-rule\)|[^ ;]*);")
BARE_PATH = re.compile(r"[A-Za-z0-9._/-]+")
BARE_MODEL = re.compile(r"[!#-'*\-./0-9<-~]+")  # printable ASCII minus space " ( ) + , : ;
COUNT = re.compile(r"0|[1-9][0-9]*|\?")


def is_control(c):
    """C0, DEL and the C1 range U+0080-U+009F."""
    o = ord(c)
    return o < 0x20 or 0x7F <= o <= 0x9F


def read_quoted(s, i):
    """s[i] == '"'. Return (decoded, next_index) or None. Escapes \\" and \\\\ only; any
    control character makes the value unrepresentable, so the record is malformed."""
    out, i = [], i + 1
    while i < len(s):
        c = s[i]
        if is_control(c):
            return None
        if c == "\\":
            if i + 1 < len(s) and s[i + 1] in "\"\\":
                out.append(s[i + 1])
                i += 2
                continue
            return None
        if c == '"':
            return ("".join(out), i + 1) if out else None
        out.append(c)
        i += 1
    return None


def parse_set(s, i):
    """Parse <STORY-SET> at s[i:]. Return (entries, next_index) or None. entries is None for
    `none`, else a list of (decoded_path, level) with level '0'..'2' or 'unprofiled'."""
    if s.startswith("none", i):
        return None, i + 4
    if not s.startswith("{", i):
        return None
    i += 1
    entries, seen = [], set()
    while True:
        if i < len(s) and s[i] == '"':
            q = read_quoted(s, i)
            if q is None:
                return None
            path, i = q
        else:
            m = BARE_PATH.match(s, i)
            if not m:
                return None
            path, i = m.group(0), m.end()
        m = re.compile(r" \((level ([012])|unprofiled)\)").match(s, i)
        if not m:
            return None
        level = m.group(2) if m.group(2) is not None else "unprofiled"
        i = m.end()
        if path in seen:  # compared decoded, so "a.md" and a.md are the same path
            return None
        seen.add(path)
        entries.append((path, level))
        if s.startswith(",", i):
            i += 1
            continue
        if s.startswith("}", i):
            return entries, i + 1
        return None


def parse_model(s, i):
    """One <model> at s[i:]; return next index or None."""
    if i < len(s) and s[i] == '"':
        q = read_quoted(s, i)
        return None if q is None else q[1]
    m = BARE_MODEL.match(s, i)
    return m.end() if m else None


def expand(spec, limit):
    """Expand "1-3,5" to [1, 2, 3, 5]. The total is checked against `limit` (the length of the
    supplied count series) BEFORE anything is allocated, so a huge range costs nothing. Python's
    integer-digit cap is lifted at start (see __main__); the ValueError guard is a last resort."""
    bounds, prev, total = [], 0, 0
    for part in spec.split(","):
        m = re.fullmatch(r"([1-9][0-9]*)(?:-([1-9][0-9]*))?", part)
        if not m:
            return None
        try:
            a = int(m.group(1))
            b = int(m.group(2)) if m.group(2) else a
        except ValueError:
            return None
        if a <= prev or b < a:
            return None
        total += b - a + 1
        if total > limit:
            return None
        bounds.append((a, b))
        prev = b
    if total != limit:
        return None
    return [p for a, b in bounds for p in range(a, b + 1)]


def parse_curve(rest):
    """rest is the text after '<field>; '. Return dict or None."""
    m = re.compile(KIND + r" \(passes ([0-9,-]+), ").match(rest)
    if not m:
        return None
    kind, spec, i = m.group(1), m.group(2), m.end()
    tail = re.compile(r"\): Findings ([^ ]+)\. Blockers ([^ ]+)\. Majors ([^ ]+)\.$").search(rest)
    if not tail:
        return None
    passes = expand(spec, len(tail.group(1).split(",")))
    if passes is None:
        return None
    if rest.startswith("pass ", i):  # per-pass models
        for k, p in enumerate(passes):
            if k:
                if not rest.startswith("; ", i):
                    return None
                i += 2
            m = re.compile(r"pass ([1-9][0-9]*) ").match(rest, i)
            if not m or m.group(1) != str(p):  # compared as text: no int() on untrusted digits
                return None
            i = m.end()
            while True:
                j = parse_model(rest, i)
                if j is None:
                    return None
                i = j
                if rest.startswith("+", i):
                    i += 1
                    continue
                break
    else:
        j = parse_model(rest, i)
        if j is None:
            return None
        i = j
    m = re.compile(r"\): Findings ([^ ]+)\. Blockers ([^ ]+)\. Majors ([^ ]+)\.$").match(rest, i)
    if not m:
        return None
    series = []
    for raw in m.groups():
        vals = raw.split(",")
        if len(vals) != len(passes) or not all(COUNT.fullmatch(v) for v in vals):
            return None
        series.append(raw)
    return {"kind": kind, "spec": spec, "f": series[0], "b": series[1], "m": series[2]}


def parse_record(line):
    """Return (field, type, data) for a valid record, or None for a malformed candidate."""
    m = re.compile(r"^cycle " + FIELD + r"; ").match(line)
    if not m:
        return None
    field, rest = m.group(1), line[m.end():]
    m = re.compile(r"floor ([1-9][0-9]*) per ").match(rest)
    if m:
        parsed = parse_set(rest, m.end())
        if parsed is None:
            return None
        entries, i = parsed
        if not re.compile(r"; hook reminder threshold (absent|unusable|[1-9][0-9]*)$").fullmatch(rest, i):
            return None
        return field, "prov", {"floor": m.group(1), "set": rest[m.end():i], "entries": entries}
    m = re.fullmatch(KIND + r": skipped \(see skip reason\)", rest)
    if m:
        return field, "skip", {"kind": m.group(1)}
    c = parse_curve(rest)
    if c:
        return field, "curve", c
    return None


# ---- sections ------------------------------------------------------------------------------

def shown(text):
    """Render a raw line for output: control characters become \\xNN, so a malformed record
    cannot move the cursor or break the report's line structure."""
    return "".join("\\x%02x" % ord(c) if is_control(c) else c for c in text)


def ledger_section(text):
    out = ["", "== Ledger: recurrence (rows matched exactly as harden-finding greps column 2)"]
    rowre = re.compile(r"^\| *[0-9-]{10} *\| *([^|]*?) *\|")
    rows, irregular = [], []
    for no, line in enumerate(text.split("\n"), 1):
        line = line[:-1] if line.endswith("\r") else line  # CRLF ledgers read like LF ones
        m = rowre.match(line)
        if not m:
            continue
        cells = re.split(r"(?<!\\)\|", line)
        closed = re.search(r"(?<!\\)\| *$", line) is not None  # an escaped final pipe does not close the row
        cells = cells[1:-1] if closed else cells[1:]
        fp = cells[1].strip(" ") if len(cells) > 1 else m.group(1)
        width_ok = len(cells) == 7
        rung = cells[5].strip(" ") if width_ok else None
        rows.append((no, fp, rung))
        if not width_ok:
            irregular.append("irregular width: line %d (%d cells)" % (no, len(cells)))
        if not re.fullmatch(r"[a-z0-9]+(-[a-z0-9]+)*", fp):
            irregular.append("irregular fingerprint: line %d" % no)
    if not rows:
        out.append("no rows")
        return out
    by_fp = {}
    for no, fp, rung in rows:
        by_fp.setdefault(fp, []).append((no, rung))
    order = sorted(by_fp, key=lambda f: (-len(by_fp[f]), f))
    for fp in order:
        n = len(by_fp[fp])
        out.append("%d  %s  lines %s  rungs %s" % (
            n, shown(fp), ",".join(str(no) for no, _ in by_fp[fp]),
            " > ".join("?" if r is None else shown(r) for _, r in by_fp[fp])))
    out.append("check one count: git --no-replace-objects show <commit>:docs/hardening-log.md | grep -cE"
               " '^\\| *[0-9-]{10} *\\| *<fingerprint> *\\|'")
    out.append("  (<commit> is the commit in the header; use a fingerprint from the list. No command"
               " fits an irregular fingerprint, because grep would read it as a pattern.)")
    out += ["", "== Ledger: rung holding"]
    last = {fp: max(no for no, _ in v) for fp, v in by_fp.items()}
    landed, followed, pending = {}, {}, 0
    for no, fp, rung in rows:
        if rung is None:
            continue
        if rung not in ALLOWED_RUNGS:
            irregular.append("irregular rung: line %d (rung '%s')" % (no, shown(rung)))
            continue
        if rung == "pending":
            pending += 1
            continue
        landed[rung] = landed.get(rung, 0) + 1
        if no < last[fp]:
            followed[rung] = followed.get(rung, 0) + 1
    for rung in sorted(landed):  # only ALLOWED_RUNGS reach here, so no escaping is needed
        f = followed.get(rung, 0)
        out.append("%s  landed %d  followed-by-same-fingerprint %d  last-of-fingerprint %d"
                   % (rung, landed[rung], f, landed[rung] - f))
    out.append("pending %d" % pending)
    out.append('"followed" means a later row with the same fingerprint exists - nothing more. It does not mean')
    out.append("the rung failed (a later row can be a different sub-shape, an out-of-scope guard, or a resolved")
    out.append('prerequisite), and "last" does not mean it held (an unhardened recurrence leaves no row).')
    out += ["", "== Ledger: irregular rows"]
    irregular.sort(key=lambda s: (int(re.search(r"line (\d+)", s).group(1)), s))
    out += irregular or ["none"]
    return out


def read_commits(raw):
    """Parse `git log -z --format='%H %ct%n%B'` output into (sha, ct, body_lines)."""
    commits = []
    for rec in raw.split("\0"):
        if not rec.strip("\n"):
            continue
        head, _, body = rec.lstrip("\n").partition("\n")
        m = re.fullmatch(r"([0-9a-f]{40}) ([0-9]+)", head)
        if not m:
            die("git log produced an unexpected record header")
        commits.append((m.group(1), int(m.group(2)), body.split("\n")))
    return commits


def git_sections(commits, absence):
    recs = {}      # key -> record dict (key: line text; pre-rule keys also carry the sha)
    unparsed = []  # (ct, sha, line)
    for sha, ct, lines in commits:
        seen_here = set()
        i = 0
        while i < len(lines):
            line = lines[i]
            pos = i
            i += 1
            if not CANDIDATE.match(line):
                continue
            parsed = parse_record(line)
            if parsed is None:
                unparsed.append((ct, sha, line))
                continue
            field, typ, data = parsed
            text = line
            if typ == "skip":  # the reason is the text right after the marker (CLAUDE.md §5)
                reason = []
                while i < len(lines) and lines[i] != "" and not CANDIDATE.match(lines[i]):
                    reason.append(lines[i])
                    i += 1
                data["reason"] = " ".join(reason)
                text = line + " | " + data["reason"]  # identity uses the excerpt as found
            # pre-rule records identify nothing, so every occurrence stays separate (commit + position)
            key = (text, sha, pos) if field == "none (pre-rule)" else (text, None, None)
            if key in seen_here:
                continue
            seen_here.add(key)
            r = recs.setdefault(key, {"field": field, "type": typ, "data": data, "text": text,
                                      "commits": []})
            r["commits"].append((ct, sha))
    for r in recs.values():
        r["commits"].sort()
        r["first"] = r["commits"][0]

    groups = {}
    for key, r in recs.items():
        gkey = ("pre", key) if r["field"] == "none (pre-rule)" else ("n", r["field"])
        groups.setdefault(gkey, []).append(r)

    out = []
    cycles, conflicts, prof, lic, f1 = [], [], [], [], []
    for gkey, rs in groups.items():
        first = min(r["first"] for r in rs)
        provs = [r for r in rs if r["type"] == "prov"]
        rest = [r for r in rs if r["type"] != "prov"]
        for p in provs:  # checkpoint evidence comes from every valid provenance line, conflicts included
            ents = p["data"]["entries"]
            licensed = bool(ents) and all(lv == "0" for _, lv in ents)
            sha = p["first"][1][:12]
            if licensed:
                lic.append((p["first"], "%s  recorded floor %s  commit %s" % (p["field"], p["data"]["floor"], sha)))
            if p["data"]["floor"] == "1":
                f1.append((p["first"], "%s  floor 1  set %s  commit %s" % (
                    p["field"], "licenses it" if licensed else "does not license it", sha)))
        if len(provs) > 1 or len(rest) > 1:
            for r in rs:  # groups sort by earliest record, then nonce; records inside by their own
                conflicts.append((first, rs[0]["field"], r["first"], "%s  %s" % (r["field"], shown(r["text"]))))
            continue
        p = provs[0] if provs else None
        c = rest[0] if rest else None
        fld = rs[0]["field"]
        floor = p["data"]["floor"] if p else "-"
        sset = p["data"]["set"] if p else "-"
        if c is None:
            line = "%s  no curve  floor %s  set %s" % (fld, floor, shown(sset))
        elif c["type"] == "skip":
            line = "%s  %s  skipped  floor %s  set %s  reason excerpt: %s  commit %s" % (
                fld, c["data"]["kind"], floor, shown(sset),
                shown(c["data"]["reason"]) or "no reason found", c["first"][1][:12])
        else:
            d = c["data"]
            line = "%s  %s  passes %s  floor %s  set %s  findings %s (? %d)  blockers %s (? %d)  majors %s (? %d)" % (
                fld, d["kind"], d["spec"], floor, shown(sset), d["f"], d["f"].split(",").count("?"),
                d["b"], d["b"].split(",").count("?"), d["m"], d["m"].split(",").count("?"))
        if gkey[0] == "pre":
            if not (c and c["type"] == "skip"):  # a skip line already names its commit
                line += "  commit %s" % rs[0]["first"][1][:12]
            line += "  [may duplicate another pre-rule record]"
        cycles.append((first, line))
        if p and c and c["type"] == "curve" and p["data"]["entries"] and \
                any(lv != "unprofiled" for _, lv in p["data"]["entries"]):
            prof.append((first, "  " + line))

    def emit(items, empty):
        items.sort(key=lambda t: t[:-1] + (t[-1],))
        if not items:
            out.append(empty)
        out.extend(t[-1] for t in items)

    emit(cycles, ("no joined cycles (every record is in a conflict below)" if conflicts else
                  "no cycle records") + absence)
    several = sorted((r["first"], shown(r["text"]), ",".join(s[:12] for _, s in r["commits"]))
                     for r in recs.values() if len(r["commits"]) > 1)
    out.extend("seen in several commits: %s -> %s" % (t, c) for _, t, c in several)
    out += ["", "== Git: conflicts (records sharing a nonce that disagree; not listed as cycles)"]
    emit(conflicts, "no conflicts" + absence)
    out += ["", "== Git: unparsed candidate lines"]
    emit([((ct, sha), "%s  %s" % (sha[:12], shown(line))) for ct, sha, line in unparsed],
         "no unparsed lines" + absence)
    out += ["", "== Comparison with the fic2 baseline (story criterion 5)",
            "profiled cycles (joined, with a curve, set has a (level N) entry):"]
    emit(prof, "  no profiled cycles with a curve" + absence)
    out.append("fic2 baseline (docs/field-reports/2026-08-26-fic2-cycle-evidence.md, passes 1-5; story §1, passes 6-7):")
    out.append(FIC2)
    out += list(CAVEATS)
    out += ["", "== First checkpoint: evidence (the reader decides)",
            "provenance lines whose set licenses floor 1:"]
    emit([(k, "  " + v) for k, v in lic], "  none" + absence)
    out.append("provenance lines recording floor 1:")
    emit([(k, "  " + v) for k, v in f1], "  none" + absence)
    return out


def is_shallow():
    rc, out = git("rev-parse", "--is-shallow-repository")
    if rc != 0:
        die("git rev-parse --is-shallow-repository failed")
    return out.decode().strip() == "true"


def main(argv):
    if len(argv) > 2:
        die("usage: ledger-metrics.py [<ref>]")
    ref = argv[1] if len(argv) == 2 else "HEAD"
    rc, _ = git("rev-parse", "--git-dir")
    if rc != 0:
        die("not a git repository")
    rc, out = git("rev-parse", "--verify", "--quiet", ref + "^{commit}")
    if rc != 0:
        die("ref does not resolve to a commit: %s" % shown(ref))
    sha = out.decode().strip()
    rc, out = git("ls-tree", "--full-tree", sha, "--", LEDGER)
    if rc != 0:
        die("git ls-tree failed at %s" % sha)
    entry = out.decode("utf-8", "replace").strip()
    if not entry:
        die("ledger absent at %s: %s" % (sha, LEDGER))
    if not re.match(r"^100(644|755) blob ", entry):
        die("ledger is not a regular file at %s: %s" % (sha, LEDGER))
    rc, out = git("cat-file", "blob", "%s:%s" % (sha, LEDGER))
    if rc != 0:
        die("ledger cannot be read at %s: %s" % (sha, LEDGER))
    ledger = out.decode("utf-8", "replace")
    shallow = is_shallow()
    # Bodies re-encoded to UTF-8 whatever i18n.logOutputEncoding says, so NUL framing holds;
    # no signature output, which would land in the same stream; `--` so a file named like the
    # SHA cannot make the argument ambiguous.
    rc, out = git("-c", "i18n.logOutputEncoding=UTF-8", "log", "--encoding=UTF-8", "--no-show-signature",
                  "-z", "--format=%H %ct%n%B", sha, "--")
    if rc != 0:
        die("git log failed at %s" % sha)
    commits = read_commits(out.decode("utf-8", "replace"))
    shallow = is_shallow() or shallow  # checked before and after the walk: either means truncated
    absence = " (history truncated: absence not established)" if shallow else ""

    lines = [
        "ledger-metrics — read-only report",
        "commit %s (from %s)" % (sha, shown(ref)),
        "ledger: %s at that commit; the working tree is not read" % LEDGER,
        "git writes: this script only runs read-only git commands; git may still write when your"
        " environment tells it to (e.g. GIT_TRACE to a file, partial-clone fetches)",
        "history: " + ("truncated (shallow clone): absence not established" if shallow else "complete"),
    ]
    lines += ledger_section(ledger)
    lines += ["", "== Git: review cycles (all commits reachable from %s)" % sha]
    lines += git_sections(commits, absence)
    # UTF-8 whatever the locale says, so a valid non-ASCII path can always be printed.
    out = "\n".join(lines) + "\n" + CANNOT + "\n"
    sys.stdout.buffer.write(out.encode("utf-8", "backslashreplace"))
    sys.stdout.flush()
    return 0


if __name__ == "__main__":
    # One integer limit on every Python: 3.11+ caps int() at 4300 digits by default, 3.8-3.10
    # do not, and the §5 grammar has no digit limit. Lift the cap where it exists.
    if hasattr(sys, "set_int_max_str_digits"):
        sys.set_int_max_str_digits(0)
    sys.exit(main(sys.argv))
