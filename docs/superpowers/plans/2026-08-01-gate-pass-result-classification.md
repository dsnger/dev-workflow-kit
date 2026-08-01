# Gate-Pass Result Classification Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Stop the gate hook from counting Codex calls that delivered no review, by classifying the tool result before touching any pass state.

**Architecture:** One classifier runs in the `PostToolUse` branch for the two gate tools. It locates the result text block (structurally with `jq`, via an `awk` scanner without), produces one shared escaped representation, and returns one of five classes. Three classes write no gate-pass state; two behave exactly as today. Diagnostic markers are separate from pass state and are always best-effort.

**Tech Stack:** POSIX `sh`, POSIX `awk`, optional `jq`. No new dependencies.

**Spec:** `docs/superpowers/specs/2026-07-31-failed-codex-call-counts-as-a-pass-design.md`
**Story:** `docs/superpowers/stories/2026-07-30-failed-codex-call-counts-as-a-pass-story.md` — read its header for the live profile at each gate pass; never copy the values here.
**Gate-A closure:** `.context/codex-reviews/gate-a-spec-CLOSURE.md`

---

## Carried obligations — check off or explicitly re-disposition during this plan's Gate A

Nothing here may silently evaporate. Each item names the task that discharges it.

### A. Implementation contracts deferred from spec §11

- [ ] **A1** — The `jq`-free scanner as a state machine: quote state, backslash parity, value boundaries, the operational meaning of "depth 1". → Task 4
- [ ] **A2** — Recognition of duplicate depth-1 keys and of malformed JSON (the *classes* are settled in the spec; only recognition is deferred). → Task 4
- [ ] **A3** — Accepted raw encodings around every token, including the blank-byte grammar and its ordering against canonical-form validation. → Task 5
- [ ] **A4** — Full backgrounding-notice grammar: duration format, task-id boundary, quote representation, and the near-misses that must NOT match. → Task 7
- [ ] **A5** — Complete marker state table across both disclosure markers and `bgAdvice`, with coexistence precedence and every write/delete/retry failure. → Task 8
- [ ] **A6** — Composition against every existing emit branch (Gate A, Gate B, WIP, docs-only, unknown-tool) and events that would otherwise emit nothing. → Task 9
- [ ] **A7** — Separator and encoding rules for composed messages. → Task 9

### B. Shipped-doc scope from Gate-A pass 8 — SCOPE, NOT WORK

Determines which files the change touches. **None is edited before Task 10.**

- [ ] **B1** — The inline CLAUDE template in `commands/workflow-init.md`, and this repo's `CLAUDE.md` §5, both state the hook keys on tool name and never inspects results.
- [ ] **B2** — "Accurate counters" on opt-out appears in `README.md`, the `codex-gate.sh` reminder text, and `commands/workflow-init.md`.
- [ ] **B3** — Every mapping instruction in `commands/workflow-init.md` — including a preflight remedy that renames the server *away* from `codex` — plus the `README.md` knob row and the unknown-tool hook message.

### C. Accepted residuals — must survive unchanged, not be engineered away

- [ ] **C1** — Spec §4: a reworded backgrounding notice, on any runtime where auto-backgrounding is still effective, is counted again.
- [ ] **C2** — Spec §5.2: an `unrecognized` call whose disclosure is neither delivered nor persisted is counted silently.
- [ ] **C3** — Spec §5.1: counter mutation is unserialized and `.context/` is trusted. Both pre-existing, both filed in `todos.md`.

### Watch-item

**If this plan's Gate-A findings concentrate on A5–A7, STOP AND SURFACE rather than elaborating.** Those three grew by accretion across the spec's own passes. The named pressure valve is a *simpler composition semantics* — dropping compose-into-one-emit for a single deferred flush, or accepting a duplicated disclosure instead of tracking pending/shown separately. That trade changes what the design promises about delivery, so it is decided upstream by the human.

**A genuine `NO FINDINGS` exit is expected here.** If this loop also ends on judgement, stop and surface: two judgement exits in one cycle is a pattern.

---

## Global Constraints

- **The hook always exits 0.** Every path, including a classifier failure, an unwritable marker and a failed emit. Withholding a *count* must never become a non-zero *exit*.
- **POSIX `sh` only.** No bash-isms. `shellcheck --shell=sh` is in the battery. POSIX `awk` is permitted (already POSIX; no new dependency).
- **`jq` is optional.** With and without it, every unambiguous payload must reach the same class. Where they cannot, the payload is `unrecognized` — never a guess.
- **Loose in the firing direction.** On uncertainty, fire. A false ✓ is the dangerous direction.
- **Hook messages are prompts.** `docs/prompt-standards.md`, all 12 items, for every string added or changed.
- **Every plugin change requires a manifest version bump** (invariant 12) — Task 11.
- **Quality battery:** the `quality` row of `AGENTS.md` § Commands. Run it before every commit.
- **Never `git add -A`.** Stage the exact paths named in each task.

## File Structure

| File | Responsibility | Task |
|---|---|---|
| `plugins/dev-workflow/hooks/fixtures/*.json` | Sanitized captured payloads; the suite's only source of payload shapes | 1 |
| `plugins/dev-workflow/hooks/fixtures/README.md` | Provenance and the fact of sanitization | 1 |
| `plugins/dev-workflow/hooks/codex-gate.test.sh` | Helpers updated first, then coverage per task | 2, and every task after |
| `plugins/dev-workflow/hooks/codex-gate.sh` | `emit` status, locator, classifier, state effects, messages | 3–9 |
| `README.md`, `CLAUDE.md`, `commands/workflow-init.md` | The shipped statements this change falsifies | 10 |
| `plugins/dev-workflow/.claude-plugin/plugin.json`, `CHANGELOG.md` | Version bump and entry | 11 |

**Ordering rationale:** fixtures and helpers land before any behaviour change, so the suite is green on both sides of the classifier. `emit`'s status change lands before the markers that depend on it. Documentation lands after the behaviour it describes is real.

---

### Task 1: Fixture home

**Files:**
- Create: `plugins/dev-workflow/hooks/fixtures/{shape0-success,shape1-fast-fail,shape2-executor-timeout,shape3-backgrounding-notice}.json`
- Create: `plugins/dev-workflow/hooks/fixtures/README.md`
- Source (untracked, do not ship): `.context/probe-payloads/`

**Interfaces:**
- Produces: `$FIXTURES` resolution rule used by every later task — `FIXTURES="$(dirname "$0")/fixtures"`.

- [ ] **Step 1: Sanitize and copy the four existing captures**

`tool_response` must stay byte-exact; only machine-specific metadata is neutralized.

```sh
cd /Users/daniel/DEVELOPMENT/APPS/dev-workflow-kit
mkdir -p plugins/dev-workflow/hooks/fixtures
for pair in \
  "shape0-success.json:shape0-success.json" \
  "shape1-fast-fail-execution-failed.json:shape1-fast-fail.json" \
  "shape2-executor-timeout.json:shape2-executor-timeout.json" \
  "shape3-backgrounding-notice.json:shape3-backgrounding-notice.json"
do
  src=".context/probe-payloads/${pair%%:*}"
  dst="plugins/dev-workflow/hooks/fixtures/${pair##*:}"
  jq '.session_id="00000000-0000-0000-0000-000000000000"
      | .transcript_path="/dev/null"
      | .cwd="/tmp/fixture-repo"
      | .tool_use_id="toolu_fixture"
      | .prompt_id="00000000-0000-0000-0000-000000000000"' "$src" > "$dst"
done
```

- [ ] **Step 2: Verify `tool_response` survived byte-exact**

```sh
for pair in \
  "shape0-success.json:shape0-success.json" \
  "shape1-fast-fail-execution-failed.json:shape1-fast-fail.json" \
  "shape2-executor-timeout.json:shape2-executor-timeout.json" \
  "shape3-backgrounding-notice.json:shape3-backgrounding-notice.json"
do
  a=$(jq -c '.tool_response' ".context/probe-payloads/${pair%%:*}")
  b=$(jq -c '.tool_response' "plugins/dev-workflow/hooks/fixtures/${pair##*:}")
  [ "$a" = "$b" ] && echo "OK ${pair##*:}" || { echo "DRIFT ${pair##*:}"; exit 1; }
done
```

Expected: four `OK` lines. Any `DRIFT` means the sanitizer touched the object under test — stop and fix the filter.

- [ ] **Step 3: Capture the review-tool fixture against a disposable synthetic repo**

`tool_response` cannot be redacted afterwards, so it must never contain real work. Create a throwaway repo with invented content, run one `mcp__codex__review` against it, and capture the payload with the same hook-instrumentation method recorded in `.context/probe-payloads/INDEX.md`. Save as `shape0-success-review.json`, sanitized by the Step 1 filter.

**Then read the whole fixture end to end before staging it.** Confirm no real path, code excerpt or finding text appears. This is a manual gate; it has no automated check because the thing it guards against is content, not shape.

- [ ] **Step 4: Write the provenance README**

```markdown
# Hook test fixtures

Real `PostToolUse` payloads captured from the hook, used by `codex-gate.test.sh`.

**Sanitized, and how:** `session_id`, `transcript_path`, `cwd`, `tool_use_id` and
`prompt_id` are replaced with fixed placeholders. **`tool_response` is byte-exact** —
it is the object under test, so it is never rewritten.

`shape0-success-review.json` was captured against a disposable synthetic repository
with invented content, because a real review response embeds file paths, code and
findings that byte-exactness would preserve.

| File | Class it exercises |
|---|---|
| `shape0-success.json` | `success` (exec) |
| `shape0-success-review.json` | `success` (review) |
| `shape1-fast-fail.json` | `failure` — `CODEX_EXECUTION_FAILED` |
| `shape2-executor-timeout.json` | `failure` — `CODEX_TIMEOUT` |
| `shape3-backgrounding-notice.json` | `backgrounded` |
```

- [ ] **Step 5: Run the battery and commit**

```sh
sh plugins/dev-workflow/hooks/codex-gate.test.sh && sh scripts/check-invariants.sh
git add plugins/dev-workflow/hooks/fixtures
git commit -m "test(hooks): ship sanitized captured payloads as fixtures"
```

---

### Task 2: Existing helpers carry real results

Under this design a payload with no `tool_response` is `no-result` and stops counting. Every existing counting call site sends exactly that. They are updated **before** the classifier lands, so the suite is green on both sides.

**Files:**
- Modify: `plugins/dev-workflow/hooks/codex-gate.test.sh:33-38` (helpers), plus the direct payloads at lines ~225, ~365, ~369 and the mapped-tool payloads at ~465, ~481

**Interfaces:**
- Produces: `rev()`, `execp()`, `codextool()` all carrying a success envelope; `rev_noresult()` for the deliberately result-less case.

- [ ] **Step 1: Add the fixture path and envelope helpers**

```sh
FIXTURES="$(dirname "$0")/fixtures"
# The success envelope every "a gate call happened" helper now carries.
succ() { jq -c '.tool_response' "$FIXTURES/shape0-success.json"; }
payload() { # $1 = tool name, $2 = tool_response JSON
  printf '{"hook_event_name":"PostToolUse","tool_name":"%s","tool_input":{},"tool_response":%s}' "$1" "$2"
}
```

- [ ] **Step 2: Rewrite the helpers to use it**

```sh
rev() { run "$(payload mcp__codex__review "$(succ)")" >/dev/null; }
execp() { run "$(payload mcp__codex__exec "$(succ)")" >/dev/null; }
codextool() { run "$(payload "$1" "$(succ)")"; }
rev_noresult() { run '{"hook_event_name":"PostToolUse","tool_name":"mcp__codex__review","tool_input":{}}'; }
```

`rev_noresult` exists so the `no-result` tests state their case rather than inheriting it.

- [ ] **Step 3: Replace every direct result-less gate payload**

Search and convert:

```sh
grep -n '"tool_name":"mcp__codex__\(exec\|review\)"' plugins/dev-workflow/hooks/codex-gate.test.sh
```

Every hit that represents *a gate call that should count* becomes `execp`/`rev`/`payload …`. The only hits left without `tool_response` are inside `rev_noresult`.

- [ ] **Step 4: Run the suite against the UNCHANGED hook**

Run: `sh plugins/dev-workflow/hooks/codex-gate.test.sh`
Expected: `all passed`. The hook ignores `tool_response` today, so adding it changes nothing — that is the point: this task is behaviour-neutral and provable.

- [ ] **Step 5: Commit**

```sh
git add plugins/dev-workflow/hooks/codex-gate.test.sh
git commit -m "test(hooks): drive gate calls with real result envelopes"
```

---

### Task 3: `emit` propagates writer status

Spec §6 defines marker-writing as conditional on "a complete hook JSON document was written". `emit` currently returns 0 unconditionally after its output command.

**Files:**
- Modify: `plugins/dev-workflow/hooks/codex-gate.sh` — `emit()`
- Test: `plugins/dev-workflow/hooks/codex-gate.test.sh`

**Interfaces:**
- Produces: `emit` returns `0` written, `1` suppressed by the off-switch, `2` write failed. Callers treat **only 0** as "shown".

- [ ] **Step 1: Write the failing test**

```sh
# Section: emit reports writer failure
reset_all
: > "$off_file_unused" 2>/dev/null || true
out=$(rev 2>/dev/null >&-; echo "rc=$?")   # stdout closed
printf '%s' "$out" | grep -q 'rc=0' && pass "hook still exits 0 with stdout closed" \
  || fail "hook still exits 0 with stdout closed"
```

- [ ] **Step 2: Run it to see it fail**

Run: `sh plugins/dev-workflow/hooks/codex-gate.test.sh 2>&1 | grep -i 'stdout closed'`
Expected: FAIL — nothing distinguishes a failed write yet.

- [ ] **Step 3: Make `emit` report its writer**

```sh
  [ -f "$off_file" ] && return 1
  if command -v jq >/dev/null 2>&1; then
    jq -cn --arg ev "$event" --arg ctx "$1" --arg msg "$2" \
      '{hookSpecificOutput:{hookEventName:$ev,additionalContext:$ctx},systemMessage:$msg}' || return 2
  else
    ctx=$(printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g')
    msg=$(printf '%s' "$2" | sed 's/\\/\\\\/g; s/"/\\"/g')
    printf '{"hookSpecificOutput":{"hookEventName":"%s","additionalContext":"%s"},"systemMessage":"%s"}\n' \
      "$event" "$ctx" "$msg" || return 2
  fi
  return 0
```

- [ ] **Step 4: Fix the stale comment in the same edit**

The `emit` header says state tracking "keeps running so re-enabling is accurate". Spec §5.2 retires that word. Replace with: *"State tracking keeps running while off, so re-enabling carries the same counting semantics as if the gate had been on — not a guarantee that every counted call was reviewed."* This is item **B2**'s hook-side occurrence; the other two sites are Task 10.

- [ ] **Step 5: Verify and commit**

Run the battery. Expected: `all passed`, `shellcheck` clean.

```sh
git add plugins/dev-workflow/hooks/codex-gate.sh plugins/dev-workflow/hooks/codex-gate.test.sh
git commit -m "fix(hooks): emit reports whether it actually wrote"
```

---

### Task 4: Locate the result block — discharges A1, A2

**Files:**
- Modify: `plugins/dev-workflow/hooks/codex-gate.sh` — new `locate_result()` above the `case "$event"` dispatch
- Test: `plugins/dev-workflow/hooks/codex-gate.test.sh`

**Interfaces:**
- Produces: `locate_result` prints the located block's text **in escaped form** on stdout and returns `0`; returns `1` for *unambiguously nothing there* (→ `no-result`); returns `2` for *cannot determine* (→ `unrecognized`). Consumed by Task 5.

**A1 — the scanner state machine, stated operationally.** The scanner walks the payload one character at a time holding three variables: `instr` (inside a JSON string), `esc` (the previous character was an unescaped backslash), and `depth` (object/brace nesting, counted only while `instr` is 0). **Backslash parity** falls out of `esc` toggling rather than counting: each backslash flips it, any other character clears it, and a quote closes the string only when `esc` is 0. **"Depth 1"** means: the key's opening quote occurs while `depth == 1`, i.e. directly inside the payload's single top-level object.

**A2 — recognition.** A second depth-1 `tool_response` key is *ambiguity*, returning 2. Malformed JSON is **not** classified: if the outer document cannot be walked to a balanced end, the scanner returns 2 and — per spec §3.3 — the hook has already failed to route the event at all, so nothing is emitted.

- [ ] **Step 1: Write the failing tests, one per contract case**

```sh
# Section: locate_result
lr() { printf '%s' "$1" | sh "$HOOK_LOCATE"; }   # thin harness exposing locate_result

t='{"tool_input":{"instruction":"see \"tool_response\" docs"},"tool_response":[{"type":"text","text":"{\"success\": true}"}]}'
lr "$t" | grep -q '\\"success\\": true' && pass "ignores tool_response quoted in tool_input" \
  || fail "ignores tool_response quoted in tool_input"

t='{"tool_response":[{"type":"image","data":"x"},{"type":"text","text":"{\"success\": false}"}]}'
lr "$t" | grep -q '\\"success\\": false' && pass "skips a non-text block" || fail "skips a non-text block"

t='{"tool_response":[{"type":"text","text":"a"}],"tool_response":[{"type":"text","text":"b"}]}'
lr "$t"; [ $? -eq 2 ] && pass "duplicate depth-1 key is ambiguous" || fail "duplicate depth-1 key is ambiguous"

t='{"tool_response":[]}'
lr "$t"; [ $? -eq 1 ] && pass "empty array is nothing-there" || fail "empty array is nothing-there"

t='{"tool_response":{"type":"text","text":"x"}}'
lr "$t"; [ $? -eq 1 ] && pass "non-array container is nothing-there" || fail "non-array container is nothing-there"
```

- [ ] **Step 2: Run them to see them fail**

Run: `sh plugins/dev-workflow/hooks/codex-gate.test.sh 2>&1 | grep -c '^FAIL'`
Expected: 5 failures — `locate_result` does not exist.

- [ ] **Step 3: Implement the scanner**

```sh
# Locates the depth-1 "tool_response" value and returns the first text block's
# text in ESCAPED form. Exit 0 = located; 1 = unambiguously nothing there;
# 2 = cannot determine (ambiguous / malformed).
locate_scan() {
  printf '%s' "$payload" | awk '
    BEGIN { RS = "\0"; found = 0; dup = 0 }
    {
      s = $0; n = length(s); depth = 0; instr = 0; esc = 0; keyq = 0
      for (i = 1; i <= n; i++) {
        c = substr(s, i, 1)
        if (instr) {
          if (esc) { esc = 0 }
          else if (c == "\\") { esc = 1 }
          else if (c == "\"") { instr = 0; if (keyq) { key = buf; keyq = 0 } }
          else if (keyq) { buf = buf c }
          continue
        }
        if (c == "\"") { instr = 1; if (depth == 1) { keyq = 1; buf = "" } ; continue }
        if (c == "{" || c == "[") { depth++; continue }
        if (c == "}" || c == "]") { depth--; continue }
        if (c == ":" && depth == 1 && key == "tool_response") {
          if (found) { dup = 1; break }
          found = 1; vstart = i + 1
          key = ""
        }
      }
      if (dup) { exit 2 }
      if (!found) { exit 1 }
      print substr(s, vstart)
      exit 0
    }'
}
```

The printed remainder is handed to a small block-picker that walks the array for the first `"type":"text"` element and prints its raw `"text"` value — still escaped, because nothing decoded it.

- [ ] **Step 4: Implement the `jq` path with its span check**

```sh
locate_jq() {
  blk=$(printf '%s' "$payload" | jq -r '
    if (.tool_response | type) != "array" then empty
    else ( .tool_response[] | select((type == "object") and (.type == "text") and ((.text | type) == "string")) | .text )
    end' 2>/dev/null | head -n1) || return 2
  [ -n "$blk" ] || return 1
  enc=$(printf '%s' "$blk" | jq -Rs . | sed 's/^"//; s/"$//')
  # Spec §3.1: exactly one occurrence, and inside the located span.
  occ=$(printf '%s' "$payload" | grep -o -F "$enc" | wc -l | tr -d ' ')
  [ "$occ" = 1 ] || return 2
  printf '%s' "$enc"
}
```

- [ ] **Step 5: Run the tests to verify they pass, in BOTH parser environments**

```sh
sh plugins/dev-workflow/hooks/codex-gate.test.sh
PATH=/usr/bin:/bin sh -c 'command -v jq >/dev/null && echo "jq present"; sh plugins/dev-workflow/hooks/codex-gate.test.sh'
```

Expected: `all passed` in both. Follow the suite's existing `jq`-absent pattern (a stub `jq` earlier on `PATH` that fails) for the second run.

- [ ] **Step 6: Extraction parity assertion**

For every fixture, both locators must hand the matcher **byte-identical** input. Assert the input, not the final class — two locating bugs can cancel out in the class.

```sh
for f in "$FIXTURES"/*.json; do
  a=$(payload_from "$f" | with_jq locate_result)
  b=$(payload_from "$f" | without_jq locate_result)
  [ "$a" = "$b" ] && pass "extraction parity: $(basename "$f")" || fail "extraction parity: $(basename "$f")"
done
```

- [ ] **Step 7: Commit**

```sh
git add plugins/dev-workflow/hooks/codex-gate.sh plugins/dev-workflow/hooks/codex-gate.test.sh
git commit -m "feat(hooks): locate the result block in both parser environments"
```

---

### Task 5: Classify — discharges A3

**Files:**
- Modify: `plugins/dev-workflow/hooks/codex-gate.sh` — new `classify()`
- Test: `plugins/dev-workflow/hooks/codex-gate.test.sh`

**Interfaces:**
- Consumes: `locate_result` (Task 4).
- Produces: `classify` prints one of `success|failure|backgrounded|no-result|unrecognized`. Consumed by Task 6.

**A3 — the blank grammar and its ordering.** Blank is defined on the **escaped bytes**: the block is blank when it contains nothing but ASCII space and the two-byte sequences `\n`, `\t`, `\r`. A Unicode-escaped space is *not* blank by this rule and does not need to be — **canonical-form validation runs first** (Task 4, Step 4), so any encoding `jq` would normalize has already returned 2 and become `unrecognized` before the blank test is reached. That ordering is the contract, and Step 3 tests it directly.

- [ ] **Step 1: Write the failing tests**

```sh
c() { CLASSIFY_INPUT="$1" sh "$HOOK_CLASSIFY"; }

[ "$(c "$(cat "$FIXTURES/shape0-success.json")")" = success ] && pass "success fixture" || fail "success fixture"
[ "$(c "$(cat "$FIXTURES/shape1-fast-fail.json")")" = failure ] && pass "fast-fail fixture" || fail "fast-fail fixture"
[ "$(c "$(cat "$FIXTURES/shape2-executor-timeout.json")")" = failure ] && pass "timeout fixture" || fail "timeout fixture"
[ "$(c "$(cat "$FIXTURES/shape3-backgrounding-notice.json")")" = backgrounded ] && pass "notice fixture" || fail "notice fixture"

# blank grammar
[ "$(c "$(payload mcp__codex__exec '[{"type":"text","text":"  \n\t "}]')")" = no-result ] \
  && pass "blank text is no-result" || fail "blank text is no-result"
# ordering: unicode-escaped space fails canonical form FIRST
[ "$(c "$(payload mcp__codex__exec '[{"type":"text","text":" "}]')")" = unrecognized ] \
  && pass "unicode space is unrecognized, not blank" || fail "unicode space is unrecognized, not blank"
# reordered failure envelope counts as unrecognized, per the table
[ "$(c "$(payload mcp__codex__exec '[{"type":"text","text":"{\"status\": \"error\", \"success\": false}"}]')")" = unrecognized ] \
  && pass "reordered envelope is unrecognized" || fail "reordered envelope is unrecognized"
# collision: a success whose summary quotes both literals
[ "$(c "$(cat "$FIXTURES/collision-success-quotes-both.json")")" = success ] \
  && pass "collision fixture classifies by its own envelope" || fail "collision fixture classifies by its own envelope"
```

Create `collision-success-quotes-both.json` and `collision-failure-quotes-true.json` in `fixtures/` by editing a copy of `shape0-success.json` / `shape1-fast-fail.json` so the `summary` field contains both marker literals. These two are **synthetic by necessity** — no real call produces them — and the README says so.

- [ ] **Step 2: Run them to see them fail**

Expected: 8 failures — `classify` does not exist.

- [ ] **Step 3: Implement**

```sh
classify() {
  blk=$(locate_result); rc=$?
  [ "$rc" = 1 ] && { printf 'no-result'; return; }
  [ "$rc" = 2 ] && { printf 'unrecognized'; return; }
  case "$blk" in
    'MCP tool "'*'" is still running after '*) printf 'backgrounded'; return ;;
  esac
  # blank: only ASCII space and the escapes \n \t \r
  case "$(printf '%s' "$blk" | sed 's/\\[ntr]//g; s/ //g')" in
    '') printf 'no-result'; return ;;
  esac
  case "$blk" in
    '{'*'\"success\":'[[:space:]]*'true'*) printf 'success'; return ;;
    '{'*'\"success\":'[[:space:]]*'false'*) printf 'failure'; return ;;
  esac
  printf 'unrecognized'
}
```

The `{` prefix plus immediate key is what enforces "immediately-first"; a reordered envelope falls through.

- [ ] **Step 4: Run to verify they pass, both parser environments**

Expected: `all passed` in both.

- [ ] **Step 5: Commit**

```sh
git add plugins/dev-workflow/hooks/codex-gate.sh plugins/dev-workflow/hooks/codex-gate.test.sh plugins/dev-workflow/hooks/fixtures
git commit -m "feat(hooks): classify the gate result into five classes"
```

---

### Task 6: Wire classes to state effects

**Files:**
- Modify: `plugins/dev-workflow/hooks/codex-gate.sh:361-397` (the `PostToolUse` branches)
- Test: `plugins/dev-workflow/hooks/codex-gate.test.sh`

**Interfaces:**
- Consumes: `classify` (Task 5).

- [ ] **Step 1: Write the seeded-preservation tests, both gates**

Empty-state assertions would pass an implementation that clears earned state, so every case seeds first.

```sh
for cls in shape1-fast-fail shape2-executor-timeout shape3-backgrounding-notice; do
  reset_all; rev; rev            # earn two real Gate-B passes
  before_count=$(cat "$count"); before_fresh=$(cat "$fresh"); before_state=$(cat "$state")
  run "$(payload mcp__codex__review "$(jq -c '.tool_response' "$FIXTURES/$cls.json")")" >/dev/null
  [ "$(cat "$count")" = "$before_count" ] && pass "$cls preserves passCount" || fail "$cls preserves passCount"
  [ "$(cat "$fresh")" = "$before_fresh" ] && pass "$cls preserves freshCount" || fail "$cls preserves freshCount"
  [ "$(cat "$state")" = "$before_state" ] && pass "$cls preserves fingerprint" || fail "$cls preserves fingerprint"

  reset_all; execp; execp        # earn two real Gate-A passes
  beforeA=$(cat "$countA")
  run "$(payload mcp__codex__exec "$(jq -c '.tool_response' "$FIXTURES/$cls.json")")" >/dev/null
  [ "$(cat "$countA")" = "$beforeA" ] && pass "$cls preserves passCountA" || fail "$cls preserves passCountA"
done
```

- [ ] **Step 2: Add the success-path discrimination test**

`success` and `unrecognized` have identical counter and fingerprint effects, so a counter assertion alone cannot tell them apart.

```sh
reset_all
rev
[ "$(cat "$count")" = 1 ] && pass "success counts" || fail "success counts"
[ ! -f "$unverified_file" ] && pass "success creates no disclosure marker" || fail "success creates no disclosure marker"
```

- [ ] **Step 3: Run to see them fail**

Expected: the preservation tests fail — every class still counts today.

- [ ] **Step 4: Implement**

```sh
      "$review_tool")
        cls=$(classify)
        case "$cls" in
          success|unrecognized) ;;                      # fall through to today's behaviour
          *) note_discarded "$cls"; exit 0 ;;           # no gate-pass state at all
        esac
        mkdir -p "$state_dir" 2>/dev/null
        # ... existing fingerprint/fresh/count logic unchanged ...
        ;;
      "$exec_tool")
        cls=$(classify)
        case "$cls" in
          success|unrecognized) mkdir -p "$state_dir" 2>/dev/null; bump_count "$countA_file" ;;
          *) note_discarded "$cls" ;;
        esac
        ;;
```

- [ ] **Step 5: Run to verify, both parser environments. Commit.**

```sh
git add plugins/dev-workflow/hooks/codex-gate.sh plugins/dev-workflow/hooks/codex-gate.test.sh
git commit -m "feat(hooks): discarded classes write no gate-pass state"
```

---

### Task 7: `failure`, `no-result` and `backgrounded` messages — discharges A4

**Files:**
- Modify: `plugins/dev-workflow/hooks/codex-gate.sh` — `note_discarded()`
- Test: `plugins/dev-workflow/hooks/codex-gate.test.sh`

**A4 — the notice grammar.** The anchor is exactly: the block begins `MCP tool "`, and the segment `" is still running after ` occurs before any newline. **Variable spans, explicitly outside the anchor:** the quoted tool name (`codex/exec`, `codex/review`, or any mapped name), the threshold digits and unit, and the task id. **Near-misses that must NOT match:** a block merely containing the phrase later in its text; a result whose summary quotes the whole notice; a block beginning `MCP tool "` with no `is still running after` segment.

- [ ] **Step 1: Write the failing message tests, including near-misses**

```sh
out=$(run "$(payload mcp__codex__review "$(jq -c '.tool_response' "$FIXTURES/shape1-fast-fail.json")")")
printf '%s' "$out" | grep -q 'not counted' && pass "failure says not counted" || fail "failure says not counted"

out=$(rev_noresult)
printf '%s' "$out" | grep -q 'no tool result' && pass "no-result names its cause" || fail "no-result names its cause"
printf '%s' "$out" | grep -q 'mapped tool' && pass "no-result names BOTH causes" || fail "no-result names BOTH causes"

# near-miss: notice text quoted inside a real envelope must NOT be backgrounded
nm='[{"type":"text","text":"{\"success\": false, \"summary\": \"MCP tool \\\"codex/exec\\\" is still running after 120s\"}"}]'
[ "$(c "$(payload mcp__codex__exec "$nm")")" = failure ] && pass "quoted notice is not backgrounded" || fail "quoted notice is not backgrounded"
```

- [ ] **Step 2: Run to see them fail. Step 3: Implement `note_discarded`.**

```sh
note_discarded() {
  case "$1" in
    failure)
      emit "This Codex call reported failure, so it was not counted as a gate pass and no review fingerprint was stored. An incomplete pass does not count toward the floor." \
           "⚠ Codex call failed — not counted as a gate pass" ;;
    no-result)
      emit "The payload carried no tool result, so this call was not counted as a gate pass. Two causes are possible and the tool name alone cannot tell them apart: a hooks-API payload contract change (check your Claude Code version and report it — the pinned server cannot produce this shape), or a mapped tool returning empty or non-text content. Check .context/codex-gate.tools for an active mapping and .mcp.json for the effective server." \
           "⚠ Gate call returned no readable result — not counted" ;;
    backgrounded) note_backgrounded ;;
  esac
}
```

- [ ] **Step 4: Implement `note_backgrounded` with the one-shot advice**

```sh
note_backgrounded() {
  if [ -f "$bg_advice_file" ]; then
    emit "Gate pass discarded — the call was backgrounded and its result never reached the hook. Not counted. See CLAUDE_CODE_MCP_AUTO_BACKGROUND_MS." \
         "⚠ Gate pass discarded (backgrounded) — not counted"
  else
    if emit "This gate pass was discarded, not counted: the call was moved to the background at the auto-background threshold (120 s by default), so its result never reached this hook. This is a setup gap, not a failed review." \
            "⚠ Gate pass discarded: set CLAUDE_CODE_MCP_AUTO_BACKGROUND_MS in the environment Claude Code is launched from, then restart it (it is read at process start, so exporting it inside a tool shell has no effect). 0 disables auto-backgrounding; a positive value must exceed your longest gate call. Requires Claude Code >= 2.1.212."; then
      mkdir -p "$state_dir" 2>/dev/null
      { : > "$bg_advice_file"; } 2>/dev/null || true
    fi
  fi
}
```

The marker is written **only** on `emit` returning 0 — suppressed or failed writes leave the one-shot unspent.

- [ ] **Step 5: Test the one-shot and its non-burning. Step 6: Commit.**

```sh
reset_all; run "$(payload mcp__codex__exec "$(jq -c '.tool_response' "$FIXTURES/shape3-backgrounding-notice.json")")" >/dev/null
: > "$off_file"
out=$(run "$(payload mcp__codex__exec "$(jq -c '.tool_response' "$FIXTURES/shape3-backgrounding-notice.json")")")
[ -z "$out" ] && pass "off suppresses the short form" || fail "off suppresses the short form"
```

```sh
git add plugins/dev-workflow/hooks/codex-gate.sh plugins/dev-workflow/hooks/codex-gate.test.sh
git commit -m "feat(hooks): report discarded passes with cause and fix"
```

---

### Task 8: The `unrecognized` disclosure and pending state — discharges A5

**Files:**
- Modify: `plugins/dev-workflow/hooks/codex-gate.sh`
- Test: `plugins/dev-workflow/hooks/codex-gate.test.sh`

**A5 — the complete marker table.** Three files: `codex-gate.bgAdvice`, `codex-gate.unverified` (shown), `codex-gate.unverifiedPending` (owed). They are independent; `bgAdvice` has no interaction with the other two, which is why its lifecycle is a single row rather than a matrix.

| `unverified` | `unverifiedPending` | Event | Result |
|---|---|---|---|
| absent | absent | `unrecognized`, emit returns 0 | write `unverified` |
| absent | absent | `unrecognized`, emit returns 1 (off) | write `unverifiedPending` |
| absent | absent | `unrecognized`, emit returns 2 (write failed) | write `unverifiedPending` |
| absent | present | any unsuppressed event | emit disclosure; on 0 → write `unverified`, delete pending; else retain pending |
| absent | present | `unverified` write fails after successful emit | **retain pending** (duplicate beats loss) |
| present | absent | `unrecognized` again | nothing emitted, nothing written |
| present | present | any | treat as shown; delete pending. Reachable only if a delete failed earlier |
| any | any | marker write fails | proceed, exit 0 — **C2 applies** |

- [ ] **Step 1: Write the state-transition tests, one per row**

```sh
reset_all
run "$(payload mcp__codex__review "$(unrec)")" >/dev/null
[ -f "$unverified_file" ] && pass "gate-on unrecognized writes shown" || fail "gate-on unrecognized writes shown"

reset_all; : > "$off_file"
run "$(payload mcp__codex__review "$(unrec)")" >/dev/null
[ -f "$pending_file" ] && pass "gate-off unrecognized writes pending" || fail "gate-off unrecognized writes pending"
[ "$(cat "$count")" = 1 ] && pass "unrecognized still counts while off" || fail "unrecognized still counts while off"

rm -f "$off_file"; out=$(rev)
printf '%s' "$out" | grep -q 'cannot verify' && pass "pending flushes on re-enable" || fail "pending flushes on re-enable"
[ ! -f "$pending_file" ] && pass "flush clears pending" || fail "flush clears pending"
```

- [ ] **Step 2: Run to see them fail. Step 3: Implement.**

```sh
note_unverified() {
  [ -f "$unverified_file" ] && return 0
  if emit "$UNVERIFIED_CTX" "$UNVERIFIED_MSG"; then
    mkdir -p "$state_dir" 2>/dev/null
    if { : > "$unverified_file"; } 2>/dev/null; then
      rm -f "$pending_file" 2>/dev/null
    fi                                  # else: pending retained on purpose
  else
    mkdir -p "$state_dir" 2>/dev/null
    { : > "$pending_file"; } 2>/dev/null || true
  fi
}
```

`$UNVERIFIED_CTX` enumerates the causes with their remedies, per spec §6 — a changed pinned-server envelope (check the version in `.mcp.json`), a reworded backgrounding notice (the `CLAUDE_CODE_MCP_AUTO_BACKGROUND_MS` guidance), a mapped third-party envelope (**no user-side fix**), and a hook parser defect (**no operator fix**) — and states that the list is not exhaustive because `unrecognized` is the terminal class.

- [ ] **Step 4: Verify, both parser environments. Commit.**

```sh
git add plugins/dev-workflow/hooks/codex-gate.sh plugins/dev-workflow/hooks/codex-gate.test.sh
git commit -m "feat(hooks): disclose uninspected passes once per workspace"
```

---

### Task 9: Composition — discharges A6, A7

**Files:**
- Modify: `plugins/dev-workflow/hooks/codex-gate.sh`
- Test: `plugins/dev-workflow/hooks/codex-gate.test.sh`

**A6 — every emit branch.** A pending disclosure can coincide with: the Gate-B STOP/stale/satisfied reminders, the Gate-A floor reminder, the WIP note, the docs-only note, the unknown-tool note, a `failure`/`no-result`/`backgrounded` note, **and events that emit nothing at all**. The last is why the flush is a wrapper rather than a call inside each branch.

**A7 — separator and encoding.** The two bodies join with `" — "` (space, em dash, space) in `additionalContext` and `" "` in `systemMessage`. **No newline**, because the `jq`-free emitter escapes only backslash and quote, and a literal newline would produce an invalid JSON document. The disclosure is prefixed `Earlier: ` so a prior-event disclosure cannot read as a statement about the current call.

- [ ] **Step 1: Write the collision test for a silent event**

```sh
reset_all; : > "$off_file"
run "$(payload mcp__codex__review "$(unrec)")" >/dev/null    # owes a disclosure
rm -f "$off_file"
out=$(run '{"hook_event_name":"PostToolUse","tool_name":"Edit","tool_input":{"file_path":"a.ts"}}')
printf '%s' "$out" | grep -q 'Earlier:' && pass "silent event still flushes pending" || fail "silent event still flushes pending"
printf '%s' "$out" | jq -e . >/dev/null 2>&1 && pass "flushed output is one valid JSON document" || fail "flushed output is one valid JSON document"
```

- [ ] **Step 2: Run to see it fail. Step 3: Implement the single-emit wrapper.**

Route every emit through one function that prepends a pending disclosure when one is owed, and — for an invocation that would otherwise emit nothing — flushes it alone before the hook exits.

- [ ] **Step 4: Assert exactly one JSON document per invocation across every branch**

```sh
for scenario in gateb_stop gatea_floor wip docsonly unknowntool failure noresult backgrounded silent; do
  out=$(run_scenario "$scenario")
  [ "$(printf '%s' "$out" | grep -c '^{')" -le 1 ] && pass "$scenario emits at most one document" || fail "$scenario emits at most one document"
done
```

- [ ] **Step 5: Commit**

```sh
git add plugins/dev-workflow/hooks/codex-gate.sh plugins/dev-workflow/hooks/codex-gate.test.sh
git commit -m "feat(hooks): compose an owed disclosure into a single emit"
```

---

### Task 10: The shipped statements this change falsifies — discharges B1, B2, B3

**Files:**
- Modify: `CLAUDE.md` §5; `README.md`; `plugins/dev-workflow/commands/workflow-init.md`

**This task is where B becomes work.** Nothing in it is edited before this point.

- [ ] **Step 1: Find every occurrence rather than trusting the list**

```sh
grep -rn "keys on tool name\|never inspects\|accurate" --include='*.md' . | grep -v 'source-files/\|docs/superpowers/'
grep -rn "execTool\|codex-gate.tools" --include='*.md' . | grep -v 'source-files/\|docs/superpowers/'
```

The pass-8 list is a floor, not a census — invariant: the greps decide.

- [ ] **Step 2: B1 — describe classification, keep the artifact-validation instruction**

In `CLAUDE.md` §5 and the inline CLAUDE template: replace "the hook counts on tool name and never inspects the result" with what the classifier does. **Keep** the rule that an incomplete pass is discounted regardless of the counter — classification does not cover a `success` call whose findings file is missing, and that remains instruction-backed.

- [ ] **Step 3: B2 — retire "accurate"**

Three sites take spec §5.2's contract: opt-out preserves the same counting semantics as gate-on, and the counters are never evidence a review happened.

- [ ] **Step 4: B3 — every mapping instruction**

Each states that a mapped name must lie in `mcp__codex__*` and that the remedy is registering the server as `codex`. **Remove the preflight remedy that renames the server away from `codex`** unless it also re-registers the effective server there — as written it produces exactly the unreachable configuration.

- [ ] **Step 5: Golden assertions for the two prompts**

The unknown-tool hook message and the scaffolded CLAUDE text are prompts. Pin both with exact-match assertions, following the suite's existing `matches exactly` tests.

- [ ] **Step 6: All 12 prompt-standards items**

Review every string added or changed in Tasks 7–10 against `docs/prompt-standards.md` — all 12, not item 10 alone.

- [ ] **Step 7: Battery and commit**

```sh
git add CLAUDE.md README.md plugins/dev-workflow/commands/workflow-init.md plugins/dev-workflow/hooks/codex-gate.test.sh
git commit -m "docs: describe result classification where the old mechanism was taught"
```

---

### Task 11: Version, changelog, and the named verification

**Files:**
- Modify: `plugins/dev-workflow/.claude-plugin/plugin.json`, `plugins/dev-workflow/CHANGELOG.md`

- [ ] **Step 1: Bump the manifest version** (invariant 12 — a plugin change without one fails CI).

- [ ] **Step 2: CHANGELOG entry**, newest first, naming the behaviour change and the three accepted residuals **C1–C3** by name.

- [ ] **Step 3: The `+check` counterfactual**

Run the `failure`-class tests against the **pre-change** hook and record that they fail:

```sh
git stash
sh plugins/dev-workflow/hooks/codex-gate.test.sh 2>&1 | grep -E 'FAIL.*(fast-fail|timeout|preserves)'
git stash pop
```

This is an observation to record, not an assertion to make.

- [ ] **Step 4: The named verification** (the story's profile requires it)

Re-run the probe methodology against the changed hook, recording the counter and fingerprint reading for each: both failure envelopes; `backgrounded` with the variable absent; `backgrounded` prevented with the variable set; one genuine pass that still counts. Method is in `.context/probe-payloads/INDEX.md`.

- [ ] **Step 5: Full battery, then Gate B**

Run the `quality` row of `AGENTS.md` § Commands. Then CLAUDE.md §5 Gate B: WIP commit, `mcp__codex__review` against its parent, minimum three passes, findings to file, clean final pass, evidence entry in the closing commit body.

---

## Self-Review

**Spec coverage:** §3.1 → Task 4; §3.2–3.3 → Task 5; §4 → Task 7 (A4) and C1; §5.1 → Task 6; §5.2 → Task 8 (A5); §6 → Tasks 7–9; §7.1 → Task 1; §7.2 → Task 2; §7.3 → Tasks 4–9; §7.4 → Task 11; §9 → Tasks 10–11; §11 → A1–A7 as mapped.

**Placeholders:** none. Every code step carries runnable content. Task 10's steps are edits to prose whose exact target text is found by the greps in its Step 1 rather than quoted here, because quoting it would create a fourth copy of the sentences this change exists to correct.

**Type consistency:** `locate_result` (0/1/2) is consumed only by `classify`; `classify`'s five strings are consumed only by the Task 6 branches; `emit`'s 0/1/2 is consumed by `note_backgrounded` and `note_unverified`. `$FIXTURES`, `payload()`, `succ()` are defined in Tasks 1–2 and used unchanged afterwards.
