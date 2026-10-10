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
    # --no-replace-objects and an empty graft file, as in P8: read the history the commit names,
    # not `git replace` substitutes or legacy grafts.
    env = dict(git_env(), GIT_GRAFT_FILE=os.devnull)
    try:
        p = subprocess.run(("git", "--no-replace-objects") + tuple(args), cwd=cwd, env=env,
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
            if not lm.CANDIDATE.match(line) or lm.is_ledger_record(line):
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
