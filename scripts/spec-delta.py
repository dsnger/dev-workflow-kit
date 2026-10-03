#!/usr/bin/env python3
"""Spec-delta: compare each relevant spec and plan with an explicitly given baseline.

Spec: docs/superpowers/specs/2026-10-03-spec-delta-design.md
Usage: python3 -B scripts/spec-delta.py [--base <ref>] [--plan <path>]... [--spec <path>]...
                                         [--baseline <ref>:<path>]... [<head>]

Read-only. It checks each baseline commit's Gate-A records and shows them verbatim, names any
ambiguity, and claims no review attribution: no record names the file a Gate-A cycle reviewed.
It informs a Gate-B reviewer and obliges nothing. Standard library only; Python 3.8+; git 2.36+.
"""
import sys

sys.dont_write_bytecode = True  # before any other import: the report writes nothing, .pyc included

import importlib.util  # noqa: E402
import os  # noqa: E402
import posixpath  # noqa: E402
import re  # noqa: E402
import subprocess  # noqa: E402

GIT_SELECTORS = ("GIT_DIR", "GIT_WORK_TREE", "GIT_COMMON_DIR", "GIT_INDEX_FILE",
                 "GIT_OBJECT_DIRECTORY", "GIT_ALTERNATE_OBJECT_DIRECTORIES",
                 "GIT_CEILING_DIRECTORIES", "GIT_DISCOVERY_ACROSS_FILESYSTEM", "GIT_NAMESPACE")
NO_SIG = ("-c", "log.showSignature=false")
DIFF_CFG = ("-c", "diff.noprefix=false", "-c", "diff.mnemonicPrefix=false", "-c", "core.quotePath=true")
DIFF_FLAGS = ("--no-color", "--no-ext-diff", "--no-textconv", "--no-relative", "--text")
SPECS, PLANS = "docs/superpowers/specs/", "docs/superpowers/plans/"
RE_SPEC_PATH = re.compile(r"`((?:\./)?docs/superpowers/specs/[^`]+\.md)`")
HEADER = "compared with given baselines; Gate-A metadata checked; review attribution not established; " \
         "informs and obliges nothing"
CANNOT = """== What this report cannot establish
- Which file a Gate-A cycle reviewed: no record names it, so a baseline is the caller's claim.
- Whether a change was reviewed or intended, or whether a spec still matches the code.
- An original text lost to a squash merge: give the original closing commit, or the artifact stays unknown.
- Relevant artifacts outside the given and discovered set, and specs cited elsewhere than a plan's header line."""


def shown(text):
    return "".join("\\x%02x" % ord(c) if (ord(c) < 0x20 and c != "\t") or 0x7F <= ord(c) <= 0x9F else c
                   for c in str(text))


def die(msg):
    sys.stderr.buffer.write(("spec-delta: %s\n" % shown(msg)).encode("utf-8", "backslashreplace"))
    sys.stderr.flush()
    sys.exit(1)


ROOT = [None]  # the repository root, set in main; every git call runs there


def git(args):
    env = {k: v for k, v in os.environ.items() if not k.startswith("GIT_TRACE")}
    for k in GIT_SELECTORS + ("GIT_SHALLOW_FILE",):
        env.pop(k, None)
    env.update(GIT_TRACE2="0", GIT_TRACE2_EVENT="0", GIT_TRACE2_PERF="0", GIT_GRAFT_FILE=os.devnull,
               GIT_LITERAL_PATHSPECS="1")
    try:
        p = subprocess.run(("git", "--no-replace-objects") + NO_SIG + tuple(args), env=env, cwd=ROOT[0],
                           stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    except OSError:
        return 127, b""
    return p.returncode, p.stdout


def must(args):
    """A git read that has to succeed; any failure is exit 1, so nothing is reported from a partial read."""
    rc, out = git(args)
    if rc != 0:
        die("history could not be read")
    return out


def resolve(ref):
    rc, out = git(("rev-parse", "--verify", "--end-of-options", ref + "^{commit}"))
    return out.decode().strip() if rc == 0 and out.strip() else None


def blob(commit, path):
    """The blob id of path at commit, or None if no file entry is there; an unreadable object is exit 1."""
    entry = must(("ls-tree", "-z", commit, "--", path)).split(b"\0")[0]
    meta, _, name = entry.partition(b"\t")
    fields = meta.split()
    if len(fields) != 3 or fields[1] != b"blob" or os.fsdecode(name) != path:
        return None
    oid = fields[2].decode()
    must(("cat-file", "-e", oid))
    return oid


def kind_of(path):
    return "Gate-A spec" if path.startswith(SPECS) else "Gate-A plan" if path.startswith(PLANS) else None


def load_parser(here):
    spec = importlib.util.spec_from_file_location("ledger_metrics", os.path.join(here, "ledger-metrics.py"))
    try:
        mod = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(mod)
    except (OSError, SyntaxError, AttributeError):
        die("the record parser scripts/ledger-metrics.py cannot be loaded")
    return mod


def parse_args(argv):
    opts = {"base": None, "plan": [], "spec": [], "baseline": {}, "head": "HEAD"}
    rest, i = [], 0
    while i < len(argv):
        a = argv[i]
        if a in ("--base", "--plan", "--spec", "--baseline"):
            if i + 1 >= len(argv):
                die("%s needs a value" % a)
            v = argv[i + 1]
            i += 2
            if a == "--base":
                opts["base"] = v
            elif a == "--baseline":
                ref, sep, path = v.partition(":")
                if not sep or not ref or not path:
                    die("--baseline needs <ref>:<path>")
                path = norm(path)
                if opts["baseline"].get(path, ref) != ref:
                    die("conflicting baselines for %s" % path)
                opts["baseline"][path] = ref
            else:
                opts[a[2:]].append(norm(v))
        else:
            rest.append(a)
            i += 1
    if len(rest) > 1:
        die("usage: spec-delta.py [--base <ref>] [--plan <path>]... [--spec <path>]... "
            "[--baseline <ref>:<path>]... [<head>]")
    if rest:
        opts["head"] = rest[0]
    return opts


def header_specs(text):
    """Spec paths on a plan's header **Spec:** line, or None when there is no such line."""
    for line in text.split("\n"):
        if line.startswith("## "):
            return None
        if line.startswith("**Spec:**"):
            return list(dict.fromkeys(RE_SPEC_PATH.findall(line)))
    return None


def read_plan(path, head, base):
    for c in (head, base):
        if c and blob(c, path):
            return must(("cat-file", "blob", blob(c, path))).decode("utf-8", "replace")
    return None


def norm(path):
    """A repository-relative path in canonical form; one that leaves the repository is exit 1."""
    p = posixpath.normpath(path)
    if p.startswith("/") or p == ".." or p.startswith("../") or p == ".":
        die("path outside the repository: %s" % path)
    return p


def baseline_block(path, ref, head, lm):
    """Lines for one artifact with a baseline; returns (state, lines)."""
    commit = resolve(ref)
    if commit is None:
        return "baseline commit not available — unknown", ["baseline: %s (does not resolve)" % shown(ref)]
    lines = ["baseline: %s (%s)" % (shown(ref), commit)]
    body = must(("log", "-1", "--format=%B", commit))
    kind = kind_of(path)
    fields, gate_b = set(), False
    records = []
    for line in body.decode("utf-8", "replace").split("\n"):
        if not lm.CANDIDATE.match(line):
            continue
        parsed = lm.parse_record(line)
        mark = "unparsed"
        if parsed is not None:
            field, typ, data = parsed
            mark = "record"
            if typ == "curve" and data.get("kind") == "Gate B":
                gate_b = True
            if field == "none (pre-rule)":
                mark = "pre-rule record, identifies no cycle"
            elif typ in ("curve", "skip") and kind and data.get("kind") == kind:
                mark = "matching kind"
                fields.add(field)
        records.append("  [%s] %s" % (mark, shown(line)))
    lines.append("records in the baseline commit (verbatim):" if records else "records in the baseline commit: none")
    lines += records
    out = must(("-c", "log.showRoot=true", "show", "--first-parent", "--no-renames", "--name-only", "--format=",
                "-z", commit))
    changed = [os.fsdecode(p) for p in out.split(b"\0") if p]  # path bytes kept, as in main
    same_kind = [p for p in changed if kind and kind_of(p) == kind]
    amb = []
    if not fields:
        amb.append("no matching-kind record with a cycle nonce at the baseline")
    if len(fields) > 1:
        amb.append("matching-kind records name %d cycles: %s" % (len(fields), ", ".join(sorted(fields))))
    if len(same_kind) > 1:
        amb.append("the baseline commit changes %d %s, so it does not settle which one a cycle reviewed" % (
            len(same_kind), "specs" if kind == "Gate-A spec" else "plans"))
    if gate_b:
        amb.append("the baseline commit also carries a Gate B record: it may be a squash of a later state")
    lines.append("ambiguity: " + ("; ".join(amb) if amb else "none found"))
    old = blob(commit, path)
    if old is None:
        return "baseline path absent", lines + ["the path is not a file at the baseline commit"]
    new = blob(head, path)
    if new == old:
        return "no change", lines
    if new is not None:
        d = must(DIFF_CFG + ("diff",) + DIFF_FLAGS + (commit, head, "--", path))
        return "changed", lines + ["diff:"] + [shown(x) for x in d.decode("utf-8", "replace").rstrip("\n").split("\n")]
    ns = must(("diff", "--find-renames", "--name-status", "-z", commit, head))
    parts = [os.fsdecode(x) for x in ns.split(b"\0")]
    target, i = None, 0
    while i < len(parts) - 1:
        st = parts[i]
        if st.startswith("R"):
            if parts[i + 1] == path:
                target = parts[i + 2]
            i += 3
        elif st.startswith("C"):
            i += 3
        else:
            i += 2
    args = (commit, head, "--", path, target) if target else (commit, head, "--", path)
    d = must(DIFF_CFG + ("diff", "--find-renames") + DIFF_FLAGS + args)
    lines.append("renamed to %s" % shown(target) if target else "deleted at the candidate")
    return "renamed or deleted", lines + ["diff:"] + [shown(x) for x in d.decode("utf-8", "replace").rstrip("\n").split("\n")]


def main(argv):
    o = parse_args(argv[1:])
    rc, out = git(("--version",))
    m = re.search(rb"(\d+)\.(\d+)", out) if rc == 0 else None
    if not m or (int(m.group(1)), int(m.group(2))) < (2, 36):
        die("git 2.36 or later is required")
    rc, top = git(("rev-parse", "--show-toplevel"))
    if rc != 0 or not top.strip():
        die("not inside a git working tree")
    ROOT[0] = os.fsdecode(top.rstrip(b"\n"))
    rc, out = git(("config", "--get-regexp", r"^(extensions\.partialclone|remote\..*\.(promisor|partialclonefilter))$"))
    if rc not in (0, 1):  # 1 means no such key
        die("the repository configuration cannot be read")
    for line in out.decode("utf-8", "replace").splitlines():
        key, _, value = line.partition(" ")
        if not key.endswith(".promisor") or value.strip().lower() not in ("false", "no", "off", "0"):
            die("partial clones are not supported (reading history could fetch objects)")
    head = resolve(o["head"])
    if head is None:
        die("the ref does not resolve to a commit: %s" % o["head"])
    base = None
    if o["base"] is not None:
        base = resolve(o["base"])
        if base is None:
            die("the ref does not resolve to a commit: %s" % o["base"])
    lm = load_parser(os.path.dirname(os.path.abspath(__file__)))

    changed = []
    if base:
        out = must(("log", "--format=", "--name-only", "--no-renames", "--diff-merges=first-parent", "-z",
                    "%s..%s" % (base, head)))
        net = must(("diff", "--name-only", "--no-renames", "-z", base, head))  # includes merge-only edits
        # os.fsdecode keeps a non-UTF-8 name's bytes, so it can be looked up again; shown() escapes it on output
        changed = list(dict.fromkeys(os.fsdecode(p) for p in (out + b"\0" + net).split(b"\0") if p))
    plans = list(dict.fromkeys(o["plan"] + [p for p in changed if p.startswith(PLANS) and p.endswith(".md")]))
    relevant = dict.fromkeys(plans)
    relevant.update(dict.fromkeys(p for p in changed if p.startswith(SPECS) and p.endswith(".md")))
    notes = {}
    for p in plans:
        text = read_plan(p, head, base)
        if text is None:
            notes[p] = "plan not readable at the candidate or the base; its specs are unknown"
            continue
        cited = header_specs(text)
        if not cited:
            notes[p] = "no spec header (no header **Spec:** line naming a spec path)"
            continue
        cited = list(dict.fromkeys(norm(c) for c in cited))
        notes[p] = "cites: " + shown(", ".join(cited))
        relevant.update(dict.fromkeys(cited))
    relevant.update(dict.fromkeys(o["spec"]))
    relevant.update(dict.fromkeys(o["baseline"]))

    order = sorted(relevant, key=lambda p: (0 if p.startswith(SPECS) else 1 if p.startswith(PLANS) else 2, p))
    blocks, counts = [], {}
    for p in order:
        if p in o["baseline"]:
            st, lines = baseline_block(p, o["baseline"][p], head, lm)
        else:
            st, lines = "baseline missing — unknown", []
        counts[st] = counts.get(st, 0) + 1
        if "diff:" in lines:
            k = lines.index("diff:")
            lines = lines[:k] + ["state: " + st] + lines[k:]
        else:
            lines = lines + ["state: " + st]
        blocks.append(["== %s" % shown(p)] + ([notes[p]] if p in notes else []) + lines)

    sh = must(("rev-parse", "--is-shallow-repository"))
    out = ["spec-delta — " + HEADER,
           "head %s%s%s" % (head, "  base %s" % base if base else "",
                            "  shallow: a baseline commit may be missing" if sh.strip() == b"true" else ""),
           "artifacts %d: %s" % (len(order), ", ".join("%s %d" % (k, v) for k, v in sorted(counts.items())) or "none"),
           ""]
    for b in blocks:
        out += b + [""]
    out.append(CANNOT)
    sys.stdout.buffer.write(("\n".join(out) + "\n").encode("utf-8", "backslashreplace"))
    return 0


if __name__ == "__main__":
    if hasattr(sys, "set_int_max_str_digits"):
        sys.set_int_max_str_digits(0)
    sys.exit(main(sys.argv))
