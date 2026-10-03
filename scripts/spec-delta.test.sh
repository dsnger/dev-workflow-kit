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
    put $PL/p4.md "# p4\\n\\n**Spec:** \`./$S/m.md\`, \`$S/q.md\` — two citations, one with a baseline, one spelled with ./\\n"
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
    nl=$(printf 'li\nne'); printf 'x\n' > "$S/$nl.md"  # a spec whose name contains a newline
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
artifacts 23: baseline commit not available — unknown 1, baseline missing — unknown 12, baseline path absent 1, changed 2, no change 5, renamed or deleted 2

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

== docs/superpowers/specs/li\x0ane.md
state: baseline missing — unknown

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
