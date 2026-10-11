# Runner (verbatim, as run)

Kept as text so the package stays documentation; nothing in CI runs it. Client: `claude` 2.1.296 (Claude Code); model `claude-opus-5-5`.

## run.sh

````sh
#!/bin/sh
# usage: run.sh <variant> <case> <turn> <prompt-file>
# Turn 1 creates a fresh fixture copy; later turns resume the session recorded by turn 1.
# Variant names: baseline*, split* (a suffix such as -r2 names a replicate).
# FIXTURE_DIR, if set, is used instead of a fresh copy (the installed run prepares its own).
set -eu
S=$(cd "$(dirname "$0")" && pwd)
V=$1; C=$2; T=$3; P=$(cd "$(dirname "$4")" && pwd)/$(basename "$4")
MODEL=${MODEL:-claude-opus-5-5}
D="$S/runs/$V/$C"
case "$V" in
  baseline*) PLUGARGS="--plugin-dir $S/plugins/baseline" ;;
  split2*) PLUGARGS="--plugin-dir $S/plugins/split2" ;;
  split*) PLUGARGS="--plugin-dir $S/plugins/split" ;;
  installed*) PLUGARGS="" ;;
  *) echo "unknown variant" >&2; exit 2 ;;
esac
if [ "$T" = 1 ]; then
  [ ! -e "$D" ] || { echo "exists: $D" >&2; exit 2; }
  mkdir -p "$D"
  if [ -n "${FIXTURE_DIR:-}" ]; then ln -s "$FIXTURE_DIR" "$D/fx"; else cp -R "$S/fixture-template" "$D/fx"; fi
  RES=""
else
  RES="--resume $(cat "$D/session")"
fi
cp "$P" "$D/turn$T.prompt"
cd "$D/fx"
# shellcheck disable=SC2086
claude -p "$(cat "$P")" $RES \
  $PLUGARGS --setting-sources project --strict-mcp-config \
  --model "$MODEL" --permission-mode bypassPermissions --max-budget-usd 4 \
  --output-format stream-json --verbose > "$D/turn$T.jsonl" 2> "$D/turn$T.stderr" || echo "exit $?" > "$D/turn$T.exit"
[ "$T" = 1 ] && jq -r 'select(.type=="system" and .subtype=="init") | .session_id' "$D/turn1.jsonl" | head -1 > "$D/session"
jq -c 'select(.type=="result") | {num_turns, total_cost_usd, duration_ms, is_error}' "$D/turn$T.jsonl"
````

## suite.sh

````sh
#!/bin/sh
# usage: suite.sh <variant>  -- the main cases A-G, one run each, in parallel (turns sequential)
S=$(cd "$(dirname "$0")" && pwd); V=$1; R="sh $S/run.sh $V"; P=$S/prompts
mkdir -p "$S/runs"
( $R A 1 $P/A1.txt && $R A 2 $P/A2.txt && $R A 3 $P/A3.txt ) > "$S/runs/$V.A.log" 2>&1 &
( $R B 1 $P/B1.txt ) > "$S/runs/$V.B.log" 2>&1 &
( $R C 1 $P/C1.txt ) > "$S/runs/$V.C.log" 2>&1 &
( $R D 1 $P/D1.txt ) > "$S/runs/$V.D.log" 2>&1 &
( $R E 1 $P/E1.txt && $R E 2 $P/E2.txt ) > "$S/runs/$V.E.log" 2>&1 &
( $R F 1 $P/F1.txt && $R F 2 $P/F2.txt ) > "$S/runs/$V.F.log" 2>&1 &
( $R G 1 $P/G1.txt ) > "$S/runs/$V.G.log" 2>&1 &
wait
````

## reps.sh

````sh
#!/bin/sh
# usage: reps.sh <variant>  -- replicates r2, r3 of D and G, and the H compaction case
S=$(cd "$(dirname "$0")" && pwd); V=$1; R="sh $S/run.sh"; P=$S/prompts
mkdir -p "$S/runs"
for r in r2 r3; do
  ( $R "$V-$r" D 1 $P/D1.txt ) > "$S/runs/$V-$r.D.log" 2>&1 &
  ( $R "$V-$r" G 1 $P/G1.txt ) > "$S/runs/$V-$r.G.log" 2>&1 &
done
( $R "$V" H 1 $P/H1.txt && $R "$V" H 2 $P/HC.txt && $R "$V" H 3 $P/H2.txt && $R "$V" H 4 $P/H3.txt ) > "$S/runs/$V.H.log" 2>&1 &
wait
````

## checks.py

````python
#!/usr/bin/env python3
"""Mechanical checks per run. usage: checks.py <replay-dir> <variant> <case>
Prints one line of key=value pairs. Reading checks are made by the author in compare.md."""
import json, os, re, subprocess, sys, glob
S, V, C = sys.argv[1], sys.argv[2], sys.argv[3]
D = os.path.join(S, 'runs', V, C); FX = os.path.join(D, 'fx'); BASE = '80b9009'
STORY = 'docs/superpowers/stories/2026-10-01-export-job-story.md'
RULE = '_IDs are permanent once the story is committed: never renumber or reuse one; a new criterion takes the next number unused here and on the branch it merges into, and a collision stops for a human; a removed one stays, struck through and dated; a narrowed one keeps its ID with a dated note; cite as `<story path> AC-<n>`; full rules: dev-workflow:intake, "Acceptance-criterion IDs"._'
def git(*a):
    return subprocess.run(['git', '-C', FX] + list(a), capture_output=True, text=True).stdout
def events(t):
    out = []
    for l in open(os.path.join(D, 'turn%d.jsonl' % t), encoding='utf-8'):
        try: out.append(json.loads(l))
        except ValueError: pass
    return out
def valid(t):
    ev = events(t); why = []
    init = [e for e in ev if e.get('type') == 'system' and e.get('subtype') == 'init']
    if not init: why.append('no-init')
    else:
        i = init[-1]
        dw = [p for p in i.get('plugins', []) if p.get('name') == 'dev-workflow']
        if len(dw) != 1: why.append('dw-plugins=%d' % len(dw))
        else:
            path = dw[0].get('path', '')
            want = {'baseline': '/plugins/baseline', 'split': '/plugins/split', 'installed': '/.claude/plugins/cache/'}[re.match(r'[a-z]+', V).group(0)]
            if want not in path: why.append('path=' + path)
        if i.get('model') != 'claude-opus-5-5': why.append('model=%s' % i.get('model'))
    res = [e for e in ev if e.get('type') == 'result']
    if not res or res[-1].get('is_error'): why.append('result')
    if os.path.exists(os.path.join(D, 'turn%d.exit' % t)): why.append('exit')
    return why, ev
def tools(ev):
    for e in ev:
        if e.get('type') == 'assistant':
            for b in e.get('message', {}).get('content', []):
                if isinstance(b, dict) and b.get('type') == 'tool_use': yield b
turns = sorted(int(re.search(r'turn(\d+)\.jsonl', f).group(1)) for f in glob.glob(os.path.join(D, 'turn*.jsonl')))
out = {'run': '%s/%s' % (V, C)}; inv = []; per = {}
for t in turns:
    why, ev = valid(t)
    if why: inv.append('t%d:%s' % (t, ','.join(why)))
    tl = list(tools(ev))
    names = [b.get('name') for b in tl]
    reads = [b.get('input', {}).get('file_path', '') for b in tl if b.get('name') == 'Read']
    route = [r for r in reads if r.endswith('capture-new-story.md') or r.endswith('amend-approved-artifact.md')]
    first_route_read = next((k for k, b in enumerate(tl) if b.get('name') == 'Read' and b.get('input', {}).get('file_path', '') in route), None)
    first_write = next((k for k, b in enumerate(tl) if b.get('name') in ('Write', 'Edit') or (b.get('name') == 'Bash' and re.search(r'git (add|commit)', b.get('input', {}).get('command', '')))), None)
    compact = any(e.get('type') == 'system' and e.get('subtype') == 'compact_boundary' for e in ev)
    per[t] = dict(route_read=bool(route), route_read_before_write=(first_route_read is not None and (first_write is None or first_route_read < first_write)), wrote=first_write is not None, compact=compact, cost=round(sum(e.get('total_cost_usd', 0) for e in ev if e.get('type') == 'result'), 3))
out['valid'] = 'yes' if not inv else 'NO(' + ';'.join(inv) + ')'
out['turns'] = ' '.join('t%d[read=%d before=%d wrote=%d compact=%d $%s]' % (t, p['route_read'], p['route_read_before_write'], p['wrote'], p['compact'], p['cost']) for t, p in per.items())
changed = [l for l in git('diff', '--name-only', BASE, 'HEAD').split('\n') if l]
untracked = [l for l in git('status', '--porcelain').split('\n') if l]
commits = [l for l in git('log', '--format=%s', BASE + '..HEAD').split('\n') if l]
out['changed'] = ','.join(changed) or '-'; out['dirty'] = len(untracked); out['commits'] = len(commits)
out['msgs'] = ' | '.join(commits) or '-'
stories = [l for l in git('ls-files', 'docs/superpowers/stories').split('\n') if l]
out['stories'] = len(stories)
if C in ('B', 'D', 'H') and os.path.exists(os.path.join(FX, STORY)):
    s = open(os.path.join(FX, STORY), encoding='utf-8').read()
    hdr = re.search(r'^\*\*Changed [0-9-]+ — (changed requirement|gap found|change of direction)\.\*\*.*Baseline: ([^.]+)', s, re.M)
    out['hdr'] = 1 if hdr else 0
    out['baseline_named'] = 1 if hdr and re.search(r'80b9009|[0-9a-f]{7,40}', hdr.group(2)) else 0
    fields = ['Added without an earlier condition', 'Unaccounted', 'Intervening changes', 'Scope boundary', 'Open questions', 'Dependent artifacts', 'Reviews already run']
    out['fields'] = '%d/7' % sum(1 for k in fields if re.search(r'^- \*\*%s:\*\*' % re.escape(k), s, re.M))
    rows = [l for l in s.split('\n') if l.startswith('| ') and not l.startswith('|---') and 'Earlier condition' not in l]
    cells = [[c.strip() for c in r.split('|')[1:-1]] for r in rows]
    out['badfate'] = sum(1 for c in cells if len(c) < 3 or not re.match(r'(kept|moved →|dropped —)', c[1]))
    out['badop'] = sum(1 for c in cells if len(c) < 3 or not re.match(r'^(none|reworded|narrowed|withdrawn|added AC-[0-9]+)(; (withdrawn|added AC-[0-9]+))*$', c[2]))
    # earlier-condition cell must name a baseline condition: AC-1..AC-4 or a §2 condition
    def baseline_cell(e):
        m = re.match(r'\**(AC-(\d+))\b', e)
        if m: return 1 <= int(m.group(2)) <= 4
        return bool(re.match(r'\**§ ?2|.*(Desired outcome|Scheduled|recurring|receives a complete file|without contacting support)', e, re.I))
    out['badrow'] = sum(1 for c in cells if not c or not baseline_cell(c[0]))
    covered = set()
    for c in cells:
        ms = re.findall(r'AC-(\d+)', re.split(r'[:—(]', c[0])[0]) if c else []
        if ms: covered.update('AC-' + x for x in ms)
        elif c and re.search(r'§ ?2|outcome|scheduled|recurring', c[0], re.I): covered.add('S2:' + ('excl' if re.search(r'scheduled|recurring|exclu|out of scope', c[0], re.I) else 'outcome'))
    out['rows_cover'] = ','.join(sorted(covered))
    out['ids'] = ' '.join(re.findall(r'^- \[ \] \*\*AC-(\d+)\*\*', s, re.M))
    diff = git('diff', BASE, 'HEAD', '--', STORY)
    out['s2_changed'] = len(re.findall(r'^[-+]A customer can request an export of their account data and receives', diff, re.M))
    gone = re.findall(r'^-- \[ \] \*\*AC-(\d)\*\*', diff, re.M)
    out['acs_changed'] = ','.join(gone) or '-'
    ac5 = re.search(r'^- \[ \] \*\*AC-5\*\* (.*)$', s, re.M)
    out['ac5_in_field'] = 1 if ac5 and re.search(r'^- \*\*Added without an earlier condition:\*\*.*AC-5: "' + re.escape(ac5.group(1).strip()) + '"', s, re.M) else 0
    out['ac5_csv'] = 1 if ac5 and 'CSV' in ac5.group(1) else 0
    ac2 = re.search(r'^- \[ \] \*\*AC-2\*\* (.*)$', s, re.M)
    body2 = re.sub(r'~~.*?~~', '', ac2.group(1)).split('(narrowed')[0].lower() if ac2 else ''
    out['ac2_narrowed'] = 1 if ac2 and re.search(r'narrowed \d{4}-\d\d-\d\d', ac2.group(1)) and 'mail' not in body2 and 'in-app' in body2 else 0
    out['ac2_text'] = ac2.group(1)[:90] if ac2 else '-'
    out['record_before_s4'] = 'ok' if re.search(r'^\*\*Changed .*?^## 4\.', s, re.M | re.S) else 'NO'
    out['rule_line'] = 1 if RULE in s else 0
if C == 'A':
    new = [l for l in changed if l.startswith('docs/superpowers/stories/') and l != STORY]
    out['new_story'] = ','.join(new) or '-'
    if new:
        s = open(os.path.join(FX, new[0]), encoding='utf-8').read()
        out['sections'] = len(re.findall(r'^## [1-6]\. ', s, re.M)); out['rule_line'] = 1 if RULE in s else 0
        ids = [int(x) for x in re.findall(r'^- \[ \] \*\*AC-(\d+)\*\*', s, re.M)]
        out['ids_in_order'] = 1 if ids and ids == list(range(1, len(ids) + 1)) and len(ids) >= 3 else 0
        out['profile_hdr'] = 1 if re.search(r'^\*\*Risk:\*\* \w+ · \*\*Security:\*\* \w+ · \*\*Validation:\*\* ', s, re.M) else 0
print(' '.join('%s=%s' % (k, v) for k, v in out.items()))
````

## mutation re-measure (mut.sh, run from the worktree on the set-1 tree)

````sh
#!/bin/sh
# usage (from repo root): sh mut.sh <chk>  -> prints chk, flipped count, accept cases moved
chk=$1; TMP=$(mktemp -d) || exit 1; [ -n "$TMP" ] && [ -d "$TMP" ] || exit 1
trap 'rm -rf "$TMP"' EXIT
mkdir -p "$TMP/repo"; tar cf - --exclude=.git --exclude=.context . | (cd "$TMP/repo" && tar xf -)
sed "/BEGIN check $chk/,/END check $chk/d" scripts/check-invariants.sh > "$TMP/repo/scripts/check-invariants.sh"
sh scripts/check-invariants.test.sh > "$TMP/before" 2>&1; base=$?
( cd "$TMP/repo" && sh scripts/check-invariants.test.sh ) > "$TMP/after" 2>&1; mut=$?
grep '^FAIL' "$TMP/after" | sed 's/ (.*//' > "$TMP/flips"
echo "$chk base=$base mut=$mut flipped=$(wc -l < "$TMP/flips" | tr -d ' ') accepts=$(grep -ciE 'accept' "$TMP/flips")"
````

## coverage.py (AC-2 line coverage)

````python
#!/usr/bin/env python3
"""usage: coverage.py <0.23.0 SKILL.md> <split dir>
Prints every non-blank line of the 0.23.0 file (whitespace-trimmed) that occurs in none of the
split's three files, with its line number. Line-based: a rewrapped sentence counts as missing."""
import sys
old, d = sys.argv[1], sys.argv[2]
new = ''.join(open(d + '/' + f, encoding='utf-8').read() for f in ('SKILL.md', 'capture-new-story.md', 'amend-approved-artifact.md'))
have = set(l.strip() for l in new.splitlines())
miss = [(i, l.strip()) for i, l in enumerate(open(old, encoding='utf-8').read().splitlines(), 1) if l.strip() and l.strip() not in have]
print('missing', len(miss))
for i, l in miss: print(i, l)
````

Output on the set-2 tree (`git show fa5f275:plugins/dev-workflow/skills/intake/SKILL.md` against `candidate/`):

````text
missing 24
27 **Requires `AGENTS.md`** (the project's invariants file) — the Flow's invariant-tagging
28 step greps it, and story Section 4 quotes what it finds. If the
32 ## When to use
34 - A raw idea or voice transcript arrives and needs to enter the workflow, before
35 any brainstorming — so the entrance is consistent regardless of author.
36 - A backlog line needs to become a reviewable story before design starts.
37 - An approved story or spec must change after a human decided to change it — narrowed,
38 redirected, or corrected for a gap found later. Use the separate route *Amending an
39 approved story or spec* below, not the Flow.
41 Not for designing a solution (that's `superpowers:brainstorming`), and not for starting a
42 new story for an item that already has an approved one; an approved artifact changes
43 only through the amendment route.
138 7. **Assess size** — `chore` / `story` / `epic-needs-splitting` per the template's
139 calibration, so sizing stays consistent across runs.
140 8. **Draft the story** from the template below (in your response — nothing on disk
141 yet).
205 1. **Fixed at commit, free before.** While the draft is shown and edited (steps 8–9),
206 renumber freely, so the draft always reads `AC-1 … AC-k` in order. Identifiers become
207 permanent when the approved story is committed (step 10).
339 identifier claims stay under *Acceptance-criterion IDs* rule 3.
360 6. **Apply *Acceptance-criterion IDs* rules 1–5 exactly as written.** Cite each affected
368 artifact as the record names it**: in a story, in §3 under rule 2 (the next unused
466 These stops belong to the Flow. The amendment route's stops are in its own steps; only
467 **No AGENTS.md** applies to both routes.
````
