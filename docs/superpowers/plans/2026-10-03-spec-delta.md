# Spec-delta Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Story:** `docs/superpowers/stories/2026-10-03-spec-delta-for-gate-b-story.md` — read the profile from its header at every gate call.

**Goal:** Add `scripts/spec-delta.py`, a read-only report that shows a Gate-B reviewer, for every relevant spec and plan, the change from an explicitly given baseline to the candidate. It quotes the baseline commit's cycle records, names any ambiguity, and claims no review attribution. Add its POSIX-sh suite, and wire the suite into the battery, CI and the docs.

**Architecture:** One Python 3.8+ standard-library script, steps in order:
1. Refuse a partial clone, and resolve the head and base refs. A baseline ref that does not resolve only makes that artifact unknown.
2. Collect the relevant artifacts: changed plans and specs in the range, the specs cited on each contributing plan's header `**Spec:**` line, and every `--spec` and `--baseline` path.
3. For each artifact with a baseline: quote the baseline commit's cycle records (marked through `scripts/ledger-metrics.py`'s parser), name the ambiguities, and diff baseline against candidate under fixed git and diff settings.

It writes nothing. The suite builds one fixture repository and compares the whole report with expected text.

**Tech Stack:** Python 3.8+ (standard library), git 2.36+, POSIX `sh` for the suite, `shellcheck` 0.11.0.

**Spec:** `docs/superpowers/specs/2026-10-03-spec-delta-design.md` (Gate-A spec cycle `7mdof8i8pb`, closed in `7a36b80`).

## Global Constraints

- Worktree `/Users/daniel/DEVELOPMENT/APPS/dwk-spec-delta`, branch `spec-delta`. Paths are relative to it.
- Not shipped: no file under `plugins/` changes, and there is no version bump (spec §1).
- Writes nothing. Informs and obliges nothing; no gate rule, pass rule or record format changes (story, spec §1).
- P8 (`scripts/ledger-metrics.py`) is imported and never changed (epic criterion 8).
- The suite passes `shellcheck --shell=sh --exclude=SC2015`.
- Unexpected repository state is a stop and a question to Daniel; no automated stash, rebase or reset.

## Rulings — spec cycle Minors and implementation choices

The spec is closed and is not edited. Where the implementation settles something the spec left open, the ruling is stated here, and the Gate-B call names it.

1. **Plan diagnostics** ("plan not readable", "no spec header", and the `cites:` line) are shown in the plan's own block, whatever its comparison state (spec pass-4 Minor).
2. **The real Gate-B input** (spec §6) is generated with the full `baseSha` and `headSha` that the Gate-B call itself passes, and the call carries exactly that output (spec pass-4 Minor).
3. **Diffs also use `--text`**, so a `binary` attribute cannot reduce an artifact's diff to a summary (spec pass-4 Minor).
4. **Any repository-relative path** is accepted by `--spec` and `--baseline`. Only specs and plans have a matching kind, and a path that is not a file at the baseline is "baseline path absent" (spec pass-4 Minor).
5. **Wording.** Zero matches reads "no matching-kind record with a cycle nonce at the baseline". A pre-rule record is quoted and marked "pre-rule record, identifies no cycle", never as a match (spec pass-4 Minor).
6. **Control characters** in quoted records, paths and diff lines print as `\xNN`. A tab is kept (spec pass-4 Minor).
7. **A rename destination changed in the range is a relevant spec of its own.** It shows "baseline missing — unknown" unless a baseline is given for it. Its source path, with a baseline, shows the rename.
8. **Every git call runs at the repository root with `GIT_LITERAL_PATHSPECS=1`.** Every read the report depends on is checked. A failed read is exit 1, "history could not be read", and nothing is reported from a partial read. An absent tree entry is distinguished from an unreadable object, which is exit 1 (plan pass-1 Majors).
9. **Changed paths are the union of every commit in the range, with merges diffed against their first parent (`--diff-merges=first-parent`), and the net `<base>`..`<head>` diff.** So a file that only a merge resolution changes is found, even one a later merge restores (plan passes 1 and 2).
10. **Only a `Gate B` curve raises the squash ambiguity**, as spec §4 says; a `Gate B` skip record is quoted without it. A `remote.*.promisor` set to false is not a partial clone, and the baseline commit's changed-path census forces `log.showRoot=true`. A block lists the baseline and its checks before the state, then any diff (spec §5).
11. **Paths are normalized** (`./` removed, `posixpath.normpath`), the command-line ones and those cited in a plan header alike, and a path that leaves the repository is exit 1. A plan file that exists is read through a checked read, so a broken object is exit 1, not a silent fallback to the base (plan pass 2).
12. **Not demonstrated by the suite, stated rather than implied:** signature suppression needs signed fixture commits and a signing key, and `diff.mnemonicPrefix` and `core.quotePath` change nothing in a commit-to-commit diff of ASCII paths. The overrides stay, as harmless guards. Graft-file suppression, replace refs, colour, text conversion, external diff drivers and relative paths are each pinned by a test.

## Review Focus

1. **This branch's own Gate B** is the real input check (story criterion 4). The call carries the report for this spec and plan, so a reviewer sees the report as it will be used.
2. **CI's Linux runner** runs the suite for the first time. It needs `git`, `python3` and POSIX utilities.
3. **A squash commit as baseline** is flagged by its `Gate B` record, never rejected. The report still compares, because the caller chose it.
4. **A large diff** is printed in full. No limit is set; the Gate-B prompt size is the caller's concern.

---

## File map

| Path | Change | Task |
|---|---|---|
| `scripts/spec-delta.test.sh` | Create | 1 |
| `scripts/spec-delta.py` | Create | 1 |
| `AGENTS.md` | Layout tree, Boundaries, quality, lint and typecheck rows, prerequisites | 2 |
| `.github/workflows/ci.yml` | Lint step, suite step, one comment | 2 |
| `README.md` | Contributing: the suites line and one paragraph | 2 |

---

### Task 1: The suite, then the script

**Files:** Create `scripts/spec-delta.test.sh`, `scripts/spec-delta.py`.

- [ ] **Step 1: Write the suite**

Create `scripts/spec-delta.test.sh` with exactly this content:

````sh
#!/bin/sh
# Regression suite for spec-delta.py.
#
# Spec: docs/superpowers/specs/2026-10-03-spec-delta-design.md §6. Builds a fixture repository whose
# commits carry Gate-A records and change specs and plans, runs the report with explicit baselines,
# and compares it with expected text.
set -u

HERE="$(cd "$(dirname "$0")" && pwd)"
SCRIPT="$HERE/spec-delta.py"
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
S=docs/superpowers/specs; PL=docs/superpowers/plans
# put FILE TEXT: write a file (creating its directory)
put() { mkdir -p "$(dirname "$1")"; printf '%b' "$2" > "$1"; }
# cm MESSAGE: commit everything with MESSAGE; prints nothing
cm() { tick=$((tick + 100)); printf '%b' "$1" > "$work/msg"; gitc add -A && gitc commit -q -F "$work/msg"; }
sha() { git rev-parse HEAD; }
prov() { printf "cycle %s; floor 3 per {docs/superpowers/stories/s-story.md (level 1)}; hook reminder threshold absent" "$1"; }
curve() { printf 'cycle %s; %s (passes 1-2, codex): Findings 2,0. Blockers 0,0. Majors 1,0.' "$1" "$2"; }

mkrepo() {
  rm -rf "${work:?}/repo"; mkdir -p "$work/repo/scripts"
  cp "$SCRIPT" "$LEDGER" "$work/repo/scripts/"
  (
    cd "$work/repo" || exit 1
    gitc init -q --template= --object-format=sha1 .
    printf '.context/\n' > .gitignore
    for f in a b c d e g h i j m n q r; do put $S/$f.md "# $f\\nline one\\n"; done
    put $PL/p4.md "# p4\\n\\n**Spec:** \`$S/m.md\`, \`$S/q.md\` — two citations, neither with a baseline\\n"
    put $PL/p1.md "# p1\\n\\n**Spec:** \`$S/a.md\`, \`$S/b.md\` — read the profile.\\n\\n## Task 1\\n\\n**Spec:** \`$S/task.md\`\\n"
    put $PL/p2.md "# p2\\n\\nno header line here\\n"
    put $PL/p3.md "# p3\\n\\n**Spec:** \`$S/f.md\`\\n"
    cm 'base\n'
    sha > "$work/c_base"
    put $S/a.md "# a\\nline one\\nreviewed text\\n"
    cm "close a\\n\\n$(prov aaaaaaaa)\\n$(curve aaaaaaaa 'Gate-A spec')\\n"
    sha > "$work/c_closeA"
    put $PL/p1.md "# p1\\n\\n**Spec:** \`$S/a.md\`, \`$S/b.md\` — read the profile.\\nreviewed plan\\n\\n## Task 1\\n\\n**Spec:** \`$S/task.md\`\\n"
    cm "close p1\\n\\n$(prov pppppppp)\\n$(curve pppppppp 'Gate-A plan')\\n"
    sha > "$work/c_closeP1"
    put $S/g.md "# g\\nline two\\n"; put $S/h.md "# h\\nline two\\n"
    cm "two cycles\\n\\n$(prov bbbbbbbb)\\n$(curve bbbbbbbb 'Gate-A spec')\\n$(curve cccccccc 'Gate-A spec')\\n$(curve dddddddd 'Gate-A plan')\\ncycle none (pre-rule); Gate-A spec (passes 1, codex): Findings 0. Blockers 0. Majors 0.\\ncycle zzzzzzzz; not a record\\n"
    sha > "$work/c_two"
    put $S/i.md "# i\\nsquashed\\n"
    cm "squash\\n\\n$(prov eeeeeeee)\\n$(curve eeeeeeee 'Gate-A spec')\\n$(curve ffffffff 'Gate B')\\n"
    sha > "$work/c_squash"
    put $S/n.md "# n\\nskipped close\\n"
    cm "skip close\\n\\n$(prov gggggggg)\\ncycle gggggggg; Gate-A spec: skipped (see skip reason)\\nSkip reason: trivial.\\n\\ncycle hhhhhhhh; Gate B: skipped (see skip reason)\\nSkip reason: trivial.\\n"
    sha > "$work/c_skip"
    sha > "$work/c_basepoint"
    # ---- the reviewed range ----
    put $S/a.md "# a\\nline one\\nreviewed text\\nedited after the close\\n"
    put $PL/p1.md "# p1\\n\\n**Spec:** \`$S/a.md\`, \`$S/b.md\` — read the profile.\\nreviewed plan\\nplan edited\\n\\n## Task 1\\n\\n**Spec:** \`$S/task.md\`\\n"
    gitc mv $S/c.md $S/c2.md
    git rm -q $S/d.md $PL/p3.md
    put $S/e.md "# e\\nline one\\nchanged, cited by no plan\\n"
    cm 'candidate\n'
    # a spec that only a merge resolution adds
    gitc checkout -q -b side
    put side.txt "side\\n"; cm 'side\n'
    gitc checkout -q main
    gitc merge -q --no-ff --no-commit side >/dev/null 2>&1
    put $S/o.md "# o\\nadded in the merge resolution\\n"
    tick=$((tick + 100)); gitc add -A && gitc commit -q -m 'merge side'
    # r.md is changed by one merge resolution and restored by another: only merge diffs show it
    gitc checkout -q -b side2 "$(cat "$work/c_basepoint")"; put side2.txt "s2\\n"; cm 'side2\n'
    gitc checkout -q -b side3 "$(cat "$work/c_basepoint")"; put side3.txt "s3\\n"; cm 'side3\n'
    gitc checkout -q main
    gitc merge -q --no-ff --no-commit side2 >/dev/null 2>&1
    put $S/r.md "# r\\nchanged in a merge\\n"; tick=$((tick + 100)); gitc add -A && gitc commit -q -m 'merge side2'
    gitc merge -q --no-ff --no-commit side3 >/dev/null 2>&1
    put $S/r.md "# r\\nline one\\n"; tick=$((tick + 100)); gitc add -A && gitc commit -q -m 'merge side3'
    sha > "$work/c_head"
  )
}

raw() { (cd "$work/repo" && HOME="$work/home" python3 -B scripts/spec-delta.py "$@"); }
run() { raw "$@" 2>&1; }
snapshot() { python3 - "$1" <<'SNAP'
import hashlib, os, sys
for d, dirs, files in sorted(os.walk(sys.argv[1])):
    for n in sorted(dirs + files):
        p = os.path.join(d, n); st = os.lstat(p)
        h = hashlib.sha256(open(p, "rb").read()).hexdigest() if os.path.isfile(p) and not os.path.islink(p) else "-"
        print(os.path.relpath(p, sys.argv[1]), oct(st.st_mode), st.st_size, st.st_mtime_ns, h)
SNAP
}
expect() { # name, actual (expected on stdin)
  printf '%s\n' "$2" > "$work/actual"; cat > "$work/expected"
  if diff "$work/expected" "$work/actual" > "$work/diff"; then pass "$1"; else fail "$1"; sed 's/^/    /' "$work/diff"; fi
}
bad() { # name, expected message, args... — exit 1, the reason on stderr, nothing on stdout
  name=$1; msg=$2; shift 2
  raw "$@" > "$work/bad.out" 2> "$work/bad.err"; s=$?
  e=$(cat "$work/bad.err")
  if [ "$s" -eq 1 ] && printf '%s' "$e" | grep -qF "spec-delta: $msg" && [ ! -s "$work/bad.out" ]; then pass "$name"
  else fail "$name (exit $s: $e; stdout $(wc -c < "$work/bad.out") bytes)"; fi
}
mask() { sed -E 's/[0-9a-f]{40}/SHA/g; s/index [0-9a-f]+\.\.[0-9a-f]+/index X..Y/; s/^baseline: [0-9a-f]{7,40} /baseline: REF /'; }

build() { rm -rf "${work:?}/home"; mkdir -p "$work/home"; mkrepo; }
# wargs CMD...: run CMD with the main run's arguments appended.
wargs() {
  "$@" --base "$(cat "$work/c_basepoint")" --plan $PL/p2.md --plan $PL/p3.md --plan $PL/p4.md \
    --plan $PL/ghost.md --spec $S/j.md --baseline "$(cat "$work/c_skip"):$S/n.md" \
    --baseline "$(cat "$work/c_base"):$S/q.md" \
    --baseline "$(cat "$work/c_closeA"):$S/a.md" --baseline "$(cat "$work/c_base"):$S/b.md" \
    --baseline "$(cat "$work/c_base"):$S/c.md" --baseline "$(cat "$work/c_base"):$S/d.md" \
    --baseline "$(cat "$work/c_two"):$S/g.md" --baseline "$(cat "$work/c_squash"):$S/i.md" \
    --baseline "deadbeef:$S/k.md" --baseline "$(cat "$work/c_base"):$S/zz.md" \
    --baseline "$(cat "$work/c_closeP1"):$PL/p1.md"
}

# ---- 1. the main report -----------------------------------------------------------------------------
build
before=$(snapshot "$work/repo"; snapshot "$work/home")
out=$(wargs run); st=$?
[ "$st" -eq 0 ] && pass "main run exits 0" || fail "main run exit $st"
[ "$(snapshot "$work/repo"; snapshot "$work/home")" = "$before" ] &&
  pass "the run writes nothing (repository and HOME, ignored files included)" || fail "the run wrote a file"
expect "report" "$(printf '%s\n' "$out" | mask)" <<'EOF'
spec-delta — compared with given baselines; Gate-A metadata checked; review attribution not established; informs and obliges nothing
head SHA  base SHA
artifacts 22: baseline commit not available — unknown 1, baseline missing — unknown 11, baseline path absent 1, changed 2, no change 5, renamed or deleted 2

== docs/superpowers/specs/a.md
baseline: SHA (SHA)
records in the baseline commit (verbatim):
  [record] cycle aaaaaaaa; floor 3 per {docs/superpowers/stories/s-story.md (level 1)}; hook reminder threshold absent
  [matching kind] cycle aaaaaaaa; Gate-A spec (passes 1-2, codex): Findings 2,0. Blockers 0,0. Majors 1,0.
ambiguity: none found
state: changed
diff:
diff --git a/docs/superpowers/specs/a.md b/docs/superpowers/specs/a.md
index X..Y 100644
--- a/docs/superpowers/specs/a.md
+++ b/docs/superpowers/specs/a.md
@@ -1,3 +1,4 @@
 # a
 line one
 reviewed text
+edited after the close

== docs/superpowers/specs/b.md
baseline: SHA (SHA)
records in the baseline commit: none
ambiguity: no matching-kind record with a cycle nonce at the baseline; the baseline commit changes 13 specs, so it does not settle which one a cycle reviewed
state: no change

== docs/superpowers/specs/c.md
baseline: SHA (SHA)
records in the baseline commit: none
ambiguity: no matching-kind record with a cycle nonce at the baseline; the baseline commit changes 13 specs, so it does not settle which one a cycle reviewed
renamed to docs/superpowers/specs/c2.md
state: renamed or deleted
diff:
diff --git a/docs/superpowers/specs/c.md b/docs/superpowers/specs/c2.md
similarity index 100%
rename from docs/superpowers/specs/c.md
rename to docs/superpowers/specs/c2.md

== docs/superpowers/specs/c2.md
state: baseline missing — unknown

== docs/superpowers/specs/d.md
baseline: SHA (SHA)
records in the baseline commit: none
ambiguity: no matching-kind record with a cycle nonce at the baseline; the baseline commit changes 13 specs, so it does not settle which one a cycle reviewed
deleted at the candidate
state: renamed or deleted
diff:
diff --git a/docs/superpowers/specs/d.md b/docs/superpowers/specs/d.md
deleted file mode 100644
index X..Y
--- a/docs/superpowers/specs/d.md
+++ /dev/null
@@ -1,2 +0,0 @@
-# d
-line one

== docs/superpowers/specs/e.md
state: baseline missing — unknown

== docs/superpowers/specs/f.md
state: baseline missing — unknown

== docs/superpowers/specs/g.md
baseline: SHA (SHA)
records in the baseline commit (verbatim):
  [record] cycle bbbbbbbb; floor 3 per {docs/superpowers/stories/s-story.md (level 1)}; hook reminder threshold absent
  [matching kind] cycle bbbbbbbb; Gate-A spec (passes 1-2, codex): Findings 2,0. Blockers 0,0. Majors 1,0.
  [matching kind] cycle cccccccc; Gate-A spec (passes 1-2, codex): Findings 2,0. Blockers 0,0. Majors 1,0.
  [record] cycle dddddddd; Gate-A plan (passes 1-2, codex): Findings 2,0. Blockers 0,0. Majors 1,0.
  [pre-rule record, identifies no cycle] cycle none (pre-rule); Gate-A spec (passes 1, codex): Findings 0. Blockers 0. Majors 0.
  [unparsed] cycle zzzzzzzz; not a record
ambiguity: matching-kind records name 2 cycles: bbbbbbbb, cccccccc; the baseline commit changes 2 specs, so it does not settle which one a cycle reviewed
state: no change

== docs/superpowers/specs/i.md
baseline: SHA (SHA)
records in the baseline commit (verbatim):
  [record] cycle eeeeeeee; floor 3 per {docs/superpowers/stories/s-story.md (level 1)}; hook reminder threshold absent
  [matching kind] cycle eeeeeeee; Gate-A spec (passes 1-2, codex): Findings 2,0. Blockers 0,0. Majors 1,0.
  [record] cycle ffffffff; Gate B (passes 1-2, codex): Findings 2,0. Blockers 0,0. Majors 1,0.
ambiguity: the baseline commit also carries a Gate B record: it may be a squash of a later state
state: no change

== docs/superpowers/specs/j.md
state: baseline missing — unknown

== docs/superpowers/specs/k.md
baseline: REF (does not resolve)
state: baseline commit not available — unknown

== docs/superpowers/specs/m.md
state: baseline missing — unknown

== docs/superpowers/specs/n.md
baseline: SHA (SHA)
records in the baseline commit (verbatim):
  [record] cycle gggggggg; floor 3 per {docs/superpowers/stories/s-story.md (level 1)}; hook reminder threshold absent
  [matching kind] cycle gggggggg; Gate-A spec: skipped (see skip reason)
  [record] cycle hhhhhhhh; Gate B: skipped (see skip reason)
ambiguity: none found
state: no change

== docs/superpowers/specs/o.md
state: baseline missing — unknown

== docs/superpowers/specs/q.md
baseline: SHA (SHA)
records in the baseline commit: none
ambiguity: no matching-kind record with a cycle nonce at the baseline; the baseline commit changes 13 specs, so it does not settle which one a cycle reviewed
state: no change

== docs/superpowers/specs/r.md
state: baseline missing — unknown

== docs/superpowers/specs/zz.md
baseline: SHA (SHA)
records in the baseline commit: none
ambiguity: no matching-kind record with a cycle nonce at the baseline; the baseline commit changes 13 specs, so it does not settle which one a cycle reviewed
the path is not a file at the baseline commit
state: baseline path absent

== docs/superpowers/plans/ghost.md
plan not readable at the candidate or the base; its specs are unknown
state: baseline missing — unknown

== docs/superpowers/plans/p1.md
cites: docs/superpowers/specs/a.md, docs/superpowers/specs/b.md
baseline: SHA (SHA)
records in the baseline commit (verbatim):
  [record] cycle pppppppp; floor 3 per {docs/superpowers/stories/s-story.md (level 1)}; hook reminder threshold absent
  [matching kind] cycle pppppppp; Gate-A plan (passes 1-2, codex): Findings 2,0. Blockers 0,0. Majors 1,0.
ambiguity: none found
state: changed
diff:
diff --git a/docs/superpowers/plans/p1.md b/docs/superpowers/plans/p1.md
index X..Y 100644
--- a/docs/superpowers/plans/p1.md
+++ b/docs/superpowers/plans/p1.md
@@ -2,6 +2,7 @@
 
 **Spec:** `docs/superpowers/specs/a.md`, `docs/superpowers/specs/b.md` — read the profile.
 reviewed plan
+plan edited
 
 ## Task 1
 

== docs/superpowers/plans/p2.md
no spec header (no header **Spec:** line naming a spec path)
state: baseline missing — unknown

== docs/superpowers/plans/p3.md
cites: docs/superpowers/specs/f.md
state: baseline missing — unknown

== docs/superpowers/plans/p4.md
cites: docs/superpowers/specs/m.md, docs/superpowers/specs/q.md
state: baseline missing — unknown

== What this report cannot establish
- Which file a Gate-A cycle reviewed: no record names it, so a baseline is the caller's claim.
- Whether a change was reviewed or intended, or whether a spec still matches the code.
- An original text lost to a squash merge: give the original closing commit, or the artifact stays unknown.
- Relevant artifacts outside the given and discovered set, and specs cited elsewhere than a plan's header line.
EOF

# ---- 2. diff configuration does not change the report ----------------------------------------------
(cd "$work/repo" && git config diff.noprefix true && git config diff.relative true && git config diff.external false &&
  git config core.quotePath false && git config color.ui always && git config diff.mnemonicPrefix true &&
  git config diff.upper.textconv 'tr a-z A-Z' && mkdir -p .git/info && printf '*.md diff=upper\n' > .git/info/attributes &&
  git config log.showSignature true)
cfg=$(wargs run)
[ "$cfg" = "$out" ] && pass "user diff configuration leaves the report unchanged" || fail "diff configuration changed the report"

# ---- 3. failures ------------------------------------------------------------------------------------
build
bad "unresolvable head" "the ref does not resolve to a commit" nosuchref
bad "unresolvable base" "the ref does not resolve to a commit" --base nosuchref
bad "conflicting baselines" "conflicting baselines for $S/a.md" --baseline "HEAD:$S/a.md" --baseline "HEAD~1:$S/a.md"
(cd "$work/repo" && git config extensions.partialClone origin)
bad "partial clone refused" "partial clones are not supported"

# ---- 3b. explicit head, hostile environment, shallow history, missing parser, old git ------------
build
old=$(run --baseline "$(cat "$work/c_closeA"):$S/a.md" "$(cat "$work/c_closeP1")")
printf '%s\n' "$old" | grep -q "^head $(cat "$work/c_closeP1")$" &&
  printf '%s\n' "$old" | grep -q '^state: no change$' &&
  pass "an explicit older head is compared, not HEAD" || fail "explicit head ignored"
plain=$(wargs run)
(
  cd "$work/repo" || exit 1
  c=$(cat "$work/c_closeA")
  git cat-file commit "$c" | sed 's/^cycle aaaaaaaa; Gate-A spec/cycle aaaaaaaa; Gate-A plan/' > "$work/fake"
  git replace "$c" "$(git hash-object -t commit -w "$work/fake")"
)
mkdir -p "$work/other" && (cd "$work/other" && gitc init -q .)
printf '%s\n' "$(cat "$work/c_closeA")" > "$work/grafts"  # would make c_closeA a root commit
hostile_run() { (cd "$work/repo/scripts" && GIT_DIR="$work/other/.git" GIT_TRACE="$work/trace" \
  GIT_TRACE2_EVENT="$work/trace2" GIT_GRAFT_FILE="$work/grafts" HOME="$work/home" python3 -B spec-delta.py "$@") 2>&1; }
hostile=$(wargs hostile_run)
[ "$hostile" = "$plain" ] && [ ! -e "$work/trace" ] && [ ! -e "$work/trace2" ] &&
  pass "from a subdirectory, with GIT_DIR, GIT_TRACE, a graft file and a replace ref: the same report, no trace written" ||
  fail "the environment changed the report or wrote a trace"
dot=$(run --baseline "$(cat "$work/c_closeA"):./$S/a.md")
printf '%s\n' "$dot" | grep -q "^== $S/a.md$" && printf '%s\n' "$dot" | grep -q '^state: changed$' &&
  pass "a ./ path is normalized" || fail "a ./ path was not normalized"
rm -rf "${work:?}/shallow"; git clone -q --depth 1 "file://$work/repo" "$work/shallow" 2>/dev/null
sh_out=$( (cd "$work/shallow" && HOME="$work/home" python3 -B scripts/spec-delta.py --spec $S/a.md) 2>&1)
printf '%s\n' "$sh_out" | grep -q 'shallow: a baseline commit may be missing' &&
  pass "a shallow clone is noted in the header" || fail "shallow clone not noted"
mkdir -p "$work/repo/tools" && cp "$work/repo/scripts/spec-delta.py" "$work/repo/tools/"
(cd "$work/repo" && HOME="$work/home" python3 -B tools/spec-delta.py) > "$work/bad.out" 2> "$work/bad.err"; s=$?
[ "$s" -eq 1 ] && grep -qF 'spec-delta: the record parser scripts/ledger-metrics.py cannot be loaded' "$work/bad.err" &&
  [ ! -s "$work/bad.out" ] && pass "a missing parser is exit 1" || fail "missing parser (exit $s)"
rm -rf "${work:?}/repo/tools"
mkdir -p "$work/shim" && printf '#!/bin/sh\nprintf "git version 2.30.0\\n"\n' > "$work/shim/git" && chmod +x "$work/shim/git"
(cd "$work/repo" && PATH="$work/shim:$PATH" HOME="$work/home" python3 -B scripts/spec-delta.py) > "$work/bad.out" 2> "$work/bad.err"; s=$?
[ "$s" -eq 1 ] && grep -qF 'spec-delta: git 2.36 or later is required' "$work/bad.err" && [ ! -s "$work/bad.out" ] &&
  pass "git older than 2.36 is exit 1" || fail "old git (exit $s)"
build
c=$(cat "$work/c_skip")  # a commit inside the reviewed range
rm -f "$work/repo/.git/objects/$(printf '%s' "$c" | cut -c1-2)/$(printf '%s' "$c" | cut -c3-)"
bad "history that cannot be read" "history could not be read" --base "$(cat "$work/c_two")" --spec $S/a.md \
  --baseline "$(cat "$work/c_two"):$S/g.md"

# ---- 4. negative control ----------------------------------------------------------------------------
build
python3 - "$work/repo/scripts/spec-delta.py" "$work/repo/scripts/allspec.py" <<'PY'
import sys
s = open(sys.argv[1]).read()
i, j = s.index("def header_specs(text):"), s.index("def read_plan(")
mutant = ('def header_specs(text):  # mutant: every **Spec:** line, header or not\n'
          '    found = [p for line in text.split("\\n") if line.startswith("**Spec:**")\n'
          '             for p in RE_SPEC_PATH.findall(line)]\n'
          '    return list(dict.fromkeys(found)) or None\n\n\n')
open(sys.argv[2], "w").write(s[:i] + mutant + s[j:])
PY
mutrun() { (cd "$work/repo" && HOME="$work/home" python3 -B scripts/allspec.py "$@") 2>&1; }
mut=$(wargs mutrun)
printf '%s\n' "$mut" | grep -q "^== $S/task.md$" && ! printf '%s\n' "$out" | grep -q "^== $S/task.md$" &&
  pass "negative control: reading every **Spec:** line picks up a task-level reference, and the suite catches it" ||
  fail "negative control not caught"

printf '\n%d passed, %d failed\n' "$pass_n" "$fail_n"
[ "$fail_n" -eq 0 ]
````

- [ ] **Step 2: Run it before the script exists**

Run: `sh scripts/spec-delta.test.sh > /tmp/sd-red.log 2>&1; echo "exit=$?"; tail -1 /tmp/sd-red.log`
Expected: `exit=1`.

- [ ] **Step 3: Write the script**

Create `scripts/spec-delta.py` with exactly this content:

````python
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
RE_SPEC_PATH = re.compile(r"`(docs/superpowers/specs/[^`]+\.md)`")
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
    changed = [p for p in out.decode("utf-8", "replace").split("\0") if p]
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
    parts = ns.decode("utf-8", "replace").split("\0")
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
        changed = list(dict.fromkeys(p for p in (out + b"\0" + net).decode("utf-8", "replace")
                                     .replace("\n", "\0").split("\0") if p))
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
````

- [ ] **Step 4: Run the suite under both shells, reading each status**

Run: `sh scripts/spec-delta.test.sh > /tmp/sd-sh.log 2>&1; echo "sh=$?"; dash scripts/spec-delta.test.sh > /tmp/sd-dash.log 2>&1; echo "dash=$?"; tail -1 /tmp/sd-sh.log /tmp/sd-dash.log`
Expected: `sh=0`, `dash=0`, and `16 passed, 0 failed` in both (measured on the prototype on 2026-10-03).

- [ ] **Step 5: Lint the suite**

Run: `shellcheck --shell=sh --exclude=SC2015 scripts/spec-delta.test.sh; echo "lint=$?"`. Expected: `lint=0`.

No commit.

---

### Task 2: Battery, CI and docs

**Files:** Modify `AGENTS.md`, `.github/workflows/ci.yml`, `README.md`.

- [ ] **Step 1: Find every place that counts the reports or suites**

```sh
grep -rnE 'three Python reports|four Python reports|three untyped|six suites|seven suites|three reports|four reports' --include='*.md' --include='*.yml' . | grep -vE 'source-files/|docs/superpowers/|\.context/|hardening-log|CHANGELOG'
```
Expected on 2026-10-03: `.github/workflows/ci.yml:40`, `AGENTS.md:71`, `AGENTS.md:265` and `README.md:163`. All four are edited below; any other hit is a stop.

Then run `cat plugins/dev-workflow/.claude-plugin/plugin.json`, and confirm it declares no component keys. Run the census `grep -rniE 'declare[sd]?|convention[- ]load' --include='*.md' . | grep -v source-files/`. Read the hits in the edited files and confirm none becomes false; the edit only adds the fourth report.

- [ ] **Step 2: Apply the edits**

Save this as a temporary file outside the repository and run it from the repository root with `python3`. It writes nothing unless every replacement matches exactly once.

```python
# Applies the Task 2 documentation and CI edits. Every replacement must match exactly
# once, or the script stops before writing anything.
import sys
edits = {
 "AGENTS.md": [
  ("scripts/loop-usefulness.test.sh   # its regression suite — fixture repo + store, expected text\n",
   "scripts/loop-usefulness.test.sh   # its regression suite — fixture repo + store, expected text\n"
   "scripts/spec-delta.py             # spec/plan change since a given baseline, for Gate B (vision step 2c, part 3)\n"
   "scripts/spec-delta.test.sh        # its regression suite — fixture repo, expected text\n"),
  ("`scripts/check-version-bump.{sh,test.sh}`), plus three Python reports with their suites:\n"
   "`scripts/ledger-metrics.{py,test.sh}` and `scripts/loop-usefulness.{py,test.sh}` (read-only),\n",
   "`scripts/check-version-bump.{sh,test.sh}`), plus four Python reports with their suites:\n"
   "`scripts/ledger-metrics.{py,test.sh}`, `scripts/loop-usefulness.{py,test.sh}` and\n"
   "`scripts/spec-delta.{py,test.sh}` (read-only),\n"),
  ("shellcheck --shell=sh --exclude=SC2015 scripts/loop-usefulness.test.sh && HOOK_SH=sh",
   "shellcheck --shell=sh --exclude=SC2015 scripts/loop-usefulness.test.sh && shellcheck --shell=sh --exclude=SC2015 scripts/spec-delta.test.sh && HOOK_SH=sh"),
  ("shellcheck --shell=sh --exclude=SC2015 scripts/loop-usefulness.test.sh` |",
   "shellcheck --shell=sh --exclude=SC2015 scripts/loop-usefulness.test.sh && shellcheck --shell=sh --exclude=SC2015 scripts/spec-delta.test.sh` |"),
  ("sh scripts/loop-usefulness.test.sh && claude plugin validate . --strict` |",
   "sh scripts/loop-usefulness.test.sh && sh scripts/spec-delta.test.sh && claude plugin validate . --strict` |"),
  ("| typecheck | n/a — no typed sources (shell, three untyped Python reports, markdown) |",
   "| typecheck | n/a — no typed sources (shell, four untyped Python reports, markdown) |"),
  ("`scripts/run-analytics.py` and `scripts/loop-usefulness.py`\nalso need git 2.36 or later and check for it.\n",
   "`scripts/run-analytics.py`, `scripts/loop-usefulness.py` and\n`scripts/spec-delta.py` also need git 2.36 or later and check for it.\n"),
 ],
 ".github/workflows/ci.yml": [
  ("      # The hook, the two checkers, the three Python reports and their six suites are\n",
   "      # The hook, the two checkers, the four Python reports and their seven suites are\n"),
  ("            --shell=sh --exclude=SC2015 scripts/loop-usefulness.test.sh\n",
   "            --shell=sh --exclude=SC2015 scripts/loop-usefulness.test.sh\n"
   "          # The spec-delta suite (vision step 2c, part 3), linted the same way.\n"
   "          docker run --rm -v \"$PWD:/mnt\" -w /mnt koalaman/shellcheck:v0.11.0 \\\n"
   "            --shell=sh --exclude=SC2015 scripts/spec-delta.test.sh\n"),
  ("          sh scripts/loop-usefulness.test.sh\n\n",
   "          sh scripts/loop-usefulness.test.sh\n          sh scripts/spec-delta.test.sh\n\n"),
 ],
 "README.md": [
  ("both checkers' regression suites, the three reports' suites, and\n",
   "both checkers' regression suites, the four reports' suites, and\n"),
  ("nothing (`-B` keeps the interpreter from writing bytecode too).\n",
   "nothing (`-B` keeps the interpreter from writing bytecode too).\n\n"
   "`python3 -B scripts/spec-delta.py --base <baseSha> --baseline <commit>:<spec> … [<head>]` shows a\n"
   "Gate-B reviewer how each relevant spec and plan changed since a baseline you name, usually the\n"
   "commit that closed its Gate-A cycle. It quotes that commit's cycle records and names any\n"
   "ambiguity. It does not claim the cycle reviewed exactly that file, and it informs without\n"
   "obliging anything. It writes nothing.\n"),
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

`sh -c '<row>' > /tmp/sd-quality.log 2>&1; echo "quality=$?"`. Expected: `quality=0`, with `16 passed, 0 failed` from the new suite (measured on a copy on 2026-10-03).

No commit.

---

### Task 3: Evidence, Gate B with the report as input, close

- [ ] **Step 1: Base check.** Run `git fetch origin; echo "fetch=$?"` and `git merge-base --is-ancestor origin/main HEAD; echo "anc=$?"`. Anything but `fetch=0` and `anc=0` is a stop: ask Daniel.

- [ ] **Step 2: Stage and snapshot.** Run `git add scripts/spec-delta.py scripts/spec-delta.test.sh AGENTS.md .github/workflows/ci.yml README.md && git diff --cached --name-only`. Exactly those five paths must be listed. Then, as its own one-line tool call: `git commit -m 'WIP: spec delta candidate'`.

- [ ] **Step 3: Evidence run.**
  - Record `H=$(git rev-parse HEAD)` and `B=$(git rev-parse HEAD^)`, and check that `git status --porcelain --untracked-files=no` prints nothing.
  - Check `test "$(git rev-parse main)" = "$(git rev-parse origin/main)"`.
  - Run the quality row verbatim (exit 0), and `dash scripts/spec-delta.test.sh` (exit 0, `16 passed, 0 failed`).
  - `git ls-tree 7a36b80 -- scripts/spec-delta.py` must print nothing.
  - **Generate the real Gate-B input:**
    `python3 -B scripts/spec-delta.py --base "$B" --plan docs/superpowers/plans/2026-10-03-spec-delta.md --baseline 7a36b80:docs/superpowers/specs/2026-10-03-spec-delta-design.md --baseline <plan-close>:docs/superpowers/plans/2026-10-03-spec-delta.md "$H" > /tmp/sd-input.txt; echo "exit=$?"`
    Here `<plan-close>` is this plan's Gate-A closing commit. Expect exit 0, and "no change" for both artifacts.
  - Repeat the HEAD and status checks.

Evidence entry for the commit body:

```
Evidence — docs/superpowers/stories/2026-10-03-spec-delta-for-gate-b-story.md
Battery: AGENTS.md quality row, exit 0 at <headSha>.
Check (counterfactual): at 7a36b80 no report exists (git ls-tree prints nothing).
Negative control in the suite: a copy that reads every **Spec:** line picks up a task-level
reference, and the suite catches it. Suite 16/16 under sh (in the quality row) and under dash.
Real Gate-B input: <the exact invocation>, at <headSha> over <baseSha>; header and state lines:
<lines>. The Gate-B calls carried this output in additionalContext.
```

- [ ] **Step 4: Gate B.** Follow CLAUDE.md §5:
  - Draw a new nonce. Derive the floor and the lens sets from the story header at the call. On 2026-10-03 that was `standard`/`none`, giving floor 3 and no lens set.
  - Check `mcp__codex__health` first; it must report `gpt-6-astra`.
  - Use one `reviewType: full` call per pass, against the full `baseSha`/`headSha` above, with separate branch files.
  - **Each call's `additionalContext` carries `/tmp/sd-input.txt` verbatim**, regenerated whenever `headSha` changes.
  - Each call also carries the story path, the evidence entry, the twelve rulings, and the standing lens (report and suite counts, the AGENTS.md rows and prerequisites, the CI steps, README).
  - Fixes: amend the WIP, rerun the evidence, regenerate the input, re-review.

- [ ] **Step 5: Close and PR.** When the §5 closure ordering allows it:
  - Run the evidence again.
  - `git log --format='%h %s' origin/main..HEAD` must show the WIP commit over the plan's Gate-A closing commit, then `7a36b80`, `47db446`, `37350ca`, with nothing staged. Any other shape is a stop.
  - Run `git commit --amend -m "<real message>"`, with the evidence entry, the provenance line, the curve and the logical-pass prose, and no trailers.
  - Push, open a PR, and check that CI's log shows `16 passed, 0 failed`.

## Self-review (2026-10-03)

- **Spec coverage:**
  - §2 → `parse_args`, `resolve`.
  - §3 → `main`'s relevant set, `header_specs`, `read_plan`.
  - §4 → `baseline_block` and the git hygiene in `git`.
  - §5 → `main`'s report and `CANNOT`.
  - §6 → the suite and Task 3's real input.
- **Story criteria:**
  - 1 → the quoted records and the ambiguity line;
  - 2 → the states;
  - 3 → the union, `--plan`, `--spec`, and "baseline missing";
  - 4 → Task 3's Gate-B input and the fixture;
  - 5 → `HEADER` and `CANNOT`, and the no-write test.
- **Placeholders:** `<headSha>`, `<baseSha>`, `<plan-close>`, `<lines>`, `<real message>` and `<row>` are filled in at run time.
