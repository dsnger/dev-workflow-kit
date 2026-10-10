# Runner (verbatim, as run)

Kept as text; nothing in CI runs it. `run.sh` is the pilot's (`runner.md` at b348b9c) with one change: the first variant line reads `fix*) PLUG="$S/plugins/fix" ;;`, where `plugins/fix` holds the contents of `plugins/dev-workflow` at the measured commit (`git archive <commit> plugins/dev-workflow`, extracted with `--strip-components=2` into `plugins/fix`, or extracted and moved, as the runs did). `checks.sh` is new.

## run.sh

````sh
#!/bin/sh
# usage: run.sh <variant> <case> <turn> <prompt-file>
# Turn 1 creates a fresh fixture copy; later turns resume the session recorded by turn 1.
set -eu
S=$(cd "$(dirname "$0")" && pwd)
V=$1; C=$2; T=$3; P=$(cd "$(dirname "$4")" && pwd)/$(basename "$4")
MODEL=${MODEL:-claude-opus-5-5}
D="$S/runs/$V/$C"
case "$V" in
  fix*) PLUG="$S/plugins/fix" ;;
  candidate2*) PLUG="$S/plugins/candidate2" ;;
  candidate*) PLUG="$S/plugins/candidate" ;;
  *) echo "unknown variant" >&2; exit 2 ;;
esac
if [ "$T" = 1 ]; then
  [ ! -e "$D" ] || { echo "exists: $D" >&2; exit 2; }
  mkdir -p "$D"; cp -R "$S/fixture-template" "$D/fx"
  RES=""
else
  RES="--resume $(cat "$D/session")"
fi
cp "$P" "$D/turn$T.prompt"
cd "$D/fx"
# shellcheck disable=SC2086
claude -p "$(cat "$P")" $RES \
  --plugin-dir "$PLUG" --setting-sources project --strict-mcp-config \
  --model "$MODEL" --permission-mode bypassPermissions --max-budget-usd 4 \
  --output-format stream-json --verbose > "$D/turn$T.jsonl" 2> "$D/turn$T.stderr" || echo "exit $?" > "$D/turn$T.exit"
[ "$T" = 1 ] && jq -r 'select(.type=="system" and .subtype=="init") | .session_id' "$D/turn1.jsonl" | head -1 > "$D/session"
jq -c 'select(.type=="result") | {num_turns, total_cost_usd, duration_ms, is_error, usage: (.usage|{input_tokens,cache_creation_input_tokens,cache_read_input_tokens,output_tokens}), models: (.modelUsage|keys)}' "$D/turn$T.jsonl"
````

## checks.sh

````sh
#!/bin/sh
# usage: checks.sh <runs-dir>   mechanical checks per run; reading checks are in compare.md
RUNS=$1; S=docs/superpowers/stories/2026-10-01-export-job-story.md
for v in D:1 D:2 D:3 D:4 D:5 B:1 B:2 B:3; do
  c=${v%:*}; i=${v#*:}; fx=$RUNS/fix-r$i/$c/fx; f=$fx/$S
  n=$(git -C "$fx" diff --name-only e2f55ca HEAD | wc -l | tr -d ' ')
  st=$(git -C "$fx" ls-files docs/superpowers/stories | wc -l | tr -d ' ')
  hdr=$(grep -cE '^\*\*Changed [0-9-]+ — (changed requirement|gap found|change of direction)\.\*\*' "$f")
  fields=0
  for k in 'Added without an earlier condition' Unaccounted 'Intervening changes' 'Scope boundary' 'Open questions' 'Dependent artifacts' 'Reviews already run'; do
    grep -q "^- \*\*$k:\*\*" "$f" && fields=$((fields+1))
  done
  badfate=$(awk -F'|' '/^\| / && !/^\|---/ && !/Earlier condition/ { f=$3; gsub(/^ +| +$/,"",f); if (f !~ /^(kept|moved →|dropped —)/) print }' "$f" | wc -l | tr -d ' ')
  badop=$(awk -F'|' '/^\| / && !/^\|---/ && !/Earlier condition/ { o=$4; gsub(/^ +| +$/,"",o); if (o !~ /^(none|reworded|narrowed|withdrawn|added AC-[0-9]+)(; (withdrawn|added AC-[0-9]+))?$/) print }' "$f" | wc -l | tr -d ' ')
  badrow=$(awk -F'|' '/^\| / && !/^\|---/ && !/Earlier condition/ { e=$2; gsub(/^ +| +$/,"",e); if (e !~ /^(AC-[0-9]|§[1-6])/) print }' "$f" | wc -l | tr -d ' ')
  ids=$(grep -oE '^- \[ \] \*\*AC-[0-9]+\*\*' "$f" | grep -oE '[0-9]+' | tr '\n' ' ')
  s2=$(git -C "$fx" diff e2f55ca HEAD -- "$S" | grep -cE '^[-+]A customer can request an export of their account data and receives')
  acs=$(git -C "$fx" diff e2f55ca HEAD -- "$S" | grep -cE '^-- \[ \] \*\*AC-(1|3|4)\*\*')
  ac5=$(grep -E '^- \[ \] \*\*AC-5\*\*' "$f" | sed 's/^- \[ \] \*\*AC-5\*\* //')
  inrec=$(grep -F "AC-5: \"$ac5\"" "$f" | wc -l | tr -d ' ')
  rec=$(awk '/^\*\*Changed /{r=1} r && /^## 4\./{print "ok"; exit}' "$f")
  echo "$c$i files=$n stories=$st hdr=$hdr fields=$fields/7 badfate=$badfate badop=$badop badrow=$badrow ids=[$ids] s2-changed=$s2 AC1/3/4-changed=$acs AC5-in-field=$inrec record-before-s4=$rec"
done
````

## Invocation

````sh
# set 1 and set 2 alike, from the replay directory:
for i in 1 2 3 4 5; do sh run.sh fix-r$i D 1 prompts/D1.txt & done
for i in 1 2 3; do sh run.sh fix-r$i B 1 prompts/B1.txt & done
wait
````
