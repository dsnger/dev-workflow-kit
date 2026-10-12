# Runner and mechanical checks (verbatim, as run)

Kept as text; nothing in CI runs them. `run.sh` follows the precedent runner
(`docs/superpowers/replays/2026-10-10-added-criterion-row/runner.md`) with one turn per run.
`checks.sh` holds the mechanical rows of spec §3's table (`M:`) and the run-validity rule; the
reading rows are in `checks.md`. Both were committed before the first run (the README names that
commit).

Layout of the working directory (in the session scratchpad, outside any git checkout):
`fixture-template/` (assembled per the README), `plugins/baseline/` (`plugins/dev-workflow` at
`6b15993`, 0.23.0), `plugins/candidate<k>/` (at the measured `WIP:` commit of set `k`),
`prompts/K1.txt`, `K2.txt`, `K3.txt`, `L.txt`, `prompts/base-K1.txt` … `base-K3.txt` (from
`prompts.md`), `runs/`.

## run.sh

````sh
#!/bin/sh
# usage: run.sh <variant> <case> <run> <prompt-file>
# variant: baseline | candidate<k>; one fresh fixture copy per run, one turn.
set -eu
S=$(cd "$(dirname "$0")" && pwd)
V=$1; C=$2; R=$3; P=$(cd "$(dirname "$4")" && pwd)/$(basename "$4")
MODEL=${MODEL:-claude-opus-5-5}
D="$S/runs/$V/$C-r$R"
[ -d "$S/plugins/$V" ] || { echo "no plugin copy: $V" >&2; exit 2; }
[ ! -e "$D" ] || { echo "exists: $D" >&2; exit 2; }
mkdir -p "$D"; cp -R "$S/fixture-template" "$D/fx"; cp "$P" "$D/prompt"
cd "$D/fx"
claude -p "$(cat "$P")" \
  --plugin-dir "$S/plugins/$V" --setting-sources project --strict-mcp-config \
  --model "$MODEL" --permission-mode bypassPermissions --max-budget-usd 4 \
  --output-format stream-json --verbose > "$D/run.jsonl" 2> "$D/run.stderr" || echo "exit $?" > "$D/run.exit"
jq -c 'select(.type=="result") | {num_turns, total_cost_usd, duration_ms, is_error}' "$D/run.jsonl"
````

## checks.sh

````sh
#!/bin/sh
# usage: checks.sh <run-dir> <case> <variant> <fixture-base-commit>
# Prints one line per check: "<id> PASS|FAIL <detail>". Exit status is not the verdict;
# a run passes its mechanical rows when no line reads FAIL.
D=$1; C=$2; V=$3; BASE=$4; FX=$D/fx; J=$D/run.jsonl
STORY=docs/superpowers/stories/2026-10-01-export-job-story.md
TK=docs/superpowers/tickets
out() { printf '%s %s %s\n' "$1" "$2" "$3"; }

# --- validity (spec §3 "Run validity") ---
kind=$(printf '%s' "$V" | sed 's/[0-9]*$//')
ndw=$(jq -s '[.[] | select(.type=="system" and .subtype=="init") | .plugins[]? | select(.name=="dev-workflow")] | length' "$J")
pth=$(jq -rs '[.[] | select(.type=="system" and .subtype=="init") | .plugins[]? | select(.name=="dev-workflow") | .path] | first // ""' "$J")
mdl=$(jq -rs '[.[] | select(.type=="system" and .subtype=="init") | .model] | first // ""' "$J")
ntool=$(jq -s '[.[] | select(.type=="assistant") | .message.content[]? | select(.type=="tool_use")] | length' "$J")
err=$(jq -rs '[.[] | select(.type=="result") | .is_error] | last // true' "$J")
why=""
[ "$ndw" = 1 ] || why="$why dw-plugins=$ndw"
case "$pth" in */plugins/$V) ;; *) why="$why path=$pth" ;; esac
[ "$mdl" = claude-opus-5-5 ] || why="$why model=$mdl"
if [ "$ntool" = 0 ] && { [ "$err" = true ] || [ -e "$D/run.exit" ]; }; then why="$why error-before-first-tool"; fi
if [ -z "$why" ]; then out V PASS "valid ($kind)"; else out V FAIL "invalid:$why"; fi

# --- tree and history against the fixture base ---
ncommit=$(git -C "$FX" rev-list --count "$BASE"..HEAD)
dirty=$(git -C "$FX" status --porcelain | wc -l | tr -d ' ')
changed=$(git -C "$FX" diff --name-only "$BASE" HEAD)
nchanged=$(printf '%s' "$changed" | grep -c . )
docs_changed=$( { printf '%s\n' "$changed"; git -C "$FX" status --porcelain | cut -c4-; } | grep -cE '^docs/superpowers/(stories|specs)/')

out M2 "$([ "$docs_changed" = 0 ] && echo PASS || echo FAIL)" "story/spec paths changed or untracked: $docs_changed"

case "$C" in
K1|K2)
  new=$(printf '%s\n' "$changed" | grep -E "^$TK/[0-9]{4}-[0-9]{2}-[0-9]{2}-T6-[a-z0-9]+(-[a-z0-9]+)*\.md$")
  old=$(printf '%s\n' "$changed" | grep -cE "^$TK/.*-T[1-5]-")
  ok=FAIL; [ "$nchanged" = 1 ] && [ -n "$new" ] && [ "$old" = 0 ] && [ "$dirty" = 0 ] && ok=PASS
  out M1 $ok "changed=[$(printf '%s' "$changed" | tr '\n' ' ')] dirty=$dirty"
  f=$FX/$new
  if [ -n "$new" ] && [ -f "$f" ]; then
    hdr=$(grep -cE '^\*\*Category:\*\* (bug|regression|improvement|docs) · \*\*State:\*\* (needs-triage|needs-info|ready|in-progress|done|wontfix) · \*\*Severity:\*\* (blocker|major|minor|nit|unknown — .+) · \*\*First seen:\*\* .+$' "$f")
    cat_n=$(grep -c '\*\*Category:\*\*' "$f"); st_n=$(grep -c '\*\*State:\*\*' "$f")
    ok=FAIL; [ "$hdr" = 1 ] && [ "$cat_n" = 1 ] && [ "$st_n" = 1 ] && ok=PASS
    out M3 $ok "header-lines=$hdr category-fields=$cat_n state-fields=$st_n"
    sl=$(grep -cxF "**Story:** \`$STORY\`" "$f"); sl_all=$(grep -c '^\*\*Story:\*\*' "$f")
    ok=FAIL; [ "$sl" = 1 ] && [ "$sl_all" = 1 ] && ok=PASS
    out M4 $ok "story-line=$sl story-lines-total=$sl_all"
  else
    out M3 FAIL "no new ticket file"; out M4 FAIL "no new ticket file"
  fi
  ok=FAIL; [ "$ncommit" = 1 ] && [ "$nchanged" = 1 ] && [ -n "$new" ] && ok=PASS
  out M5 $ok "commits=$ncommit paths=$nchanged"
  ;;
K3|L)
  ok=FAIL; [ "$ncommit" = 0 ] && [ "$dirty" = 0 ] && ok=PASS
  out M6 $ok "commits=$ncommit dirty=$dirty"
  ;;
esac
````

## Invocation

````sh
# from the working directory; BASE is the fixture-template commit the README records
for c in K1 K2 K3; do sh run.sh baseline $c 1 prompts/base-$c.txt; done
for c in K1 K2 K3; do for r in 1 2 3; do sh run.sh candidate1 $c $r prompts/$c.txt; done; done
sh run.sh candidate1 L 1 prompts/L.txt
for d in runs/*/*; do c=$(basename "$d" | sed 's/-r[0-9]*$//'); v=$(basename "$(dirname "$d")"); echo "== $v/$(basename "$d")"; sh checks.sh "$d" "$c" "$v" "$BASE"; done
````

Baseline runs are checked for validity and for M2 and M6-style "no ticket": a baseline K1/K2 run is
expected to fail M1 (no ticket file can be produced on 0.23.0), which is the counterfactual.
