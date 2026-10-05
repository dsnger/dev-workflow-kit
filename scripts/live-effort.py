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
