# Gate-pass result classification — Design

**Date:** 2026-07-31
**Story:** `docs/superpowers/stories/2026-07-30-failed-codex-call-counts-as-a-pass-story.md`
— read its header for the current risk/security/validation profile; this spec deliberately
does not copy those values, so there is one writable copy.

**Evidence:** `.context/probe-payloads/` (untracked; `INDEX.md` records provenance and the
counter effect per shape). Five captured `PostToolUse` payloads, all real.

## 1. What this changes

The hook advances its pass counters — and, for Gate B, stores a content fingerprint — on
Codex calls that reviewed nothing, because nothing in the `PostToolUse` path inspects the
result before counting. This adds one classifier that reads the result and decides whether
the call earned a pass.

The problem statement, the measured counter movements and the four observed payload shapes
are in the story. This spec covers only the design.

## 2. Settled decisions

Four questions were answered by the human before design, and their reasons are recorded
here because a later reader will otherwise re-litigate them:

1. **Classification keys on the envelope, not the tool name.** A tool mapped via
   `.context/codex-gate.tools` is in scope.
2. **An unrecognized envelope fails OPEN** — it counts, as today, plus a once-per-workspace
   disclosure. Fail-closed would zero the counters permanently for every third-party
   server with no fix available to the user, which is the hook's own worst failure mode
   ("reviews run, counters stay 0, and the STOP fires on every commit forever — which
   trains the user to ignore the hook", `codex-gate.sh`). Fail-open-with-disclosure is
   strictly better than today everywhere and overclaims nowhere.
3. **A discarded pass reports the fact every time; the setup advice appears once per
   workspace.** Each discarded pass is new information, so suppressing the second one
   would hide a real loss. The advice is static configuration guidance, which is what the
   existing "say it once" precedent protects against. The short form still names the
   variable, because the marker outlives the session that saw the long form.
4. **Cancellation is not a false-✓ vector in any observed form.** See §8.

## 3. Classification

One function, one code path. `jq` presence does not change the outcome. It runs on
`PostToolUse` for the two gate tools (default names or the mapped ones) and returns exactly
one class.

**Input narrowing.** Strip everything up to `"tool_response"` before matching, so nothing
in `tool_input` can be read as a result. `input_field` already uses this defence, stripping
to `"tool_input":{` so a same-named top-level key cannot shadow the real one. The narrowing
matters more here than there: gate prompts routinely quote payload text, so an instruction
containing a marker literal is a realistic input, not a contrived one.

**The markers are read from the escaped bytes.** The Codex result arrives as a JSON string
*inside* the payload, so the literal characters `\"success\": true` / `\"success\": false`
appear directly in the stream. Nothing decodes the nested string. This is deliberate: a
separate open defect reports the `jq`-free parser breaking on an escaped quote, and
decoding here would walk into it for no gain — the value being read is a boolean.

**Positional, not "contains".** Classification reads the **first** occurrence of either
polarity after the envelope opening, not any occurrence anywhere. That is what lets a
successful review whose findings quote both literals still classify by its own envelope.

**Whitespace tolerance.** The matcher tolerates whitespace between key, colon and value.
Only the current serializer's two-space form has been observed; a formatting change should
not silently reclassify every result as unrecognized.

**Two anchors, provably disjoint.** The envelope anchor requires `"text":"{` at the start
of the content block; the backgrounding notice begins with prose. The two therefore cannot
both match. This is stated here rather than left to the implementation to arrange.

| Class | Recognized by | Counter | Fingerprint |
|---|---|---|---|
| `success` | first `success` marker after the envelope opening is `true` | bump | store |
| `failure` | first such marker is `false` | no | no |
| `backgrounded` | the notice anchor (§4) | no | no |
| `unrecognized` | none of the above | bump | store |

**A payload with no `tool_response` at all is `unrecognized`**, not an error. It cannot
occur in production — the field is present in all five captures — but it is what the test
suite sent before this change, and leaving the case unstated would make the classifier's
behaviour there an implementation accident rather than a decision.

**What the envelope anchor rests on.** `success` being the envelope's first key is observed
`mcp-codex-dev@1.0.1` behaviour — confirmed across all four envelope captures, and matching
the server's own return literal (`dist/tools/codex-exec.js` returns an object whose first
property is `success`, serialized with `JSON.stringify(result, null, 2)`, and insertion
order is preserved). **It is not a JSON guarantee.** Nothing stops a future version
reordering the keys. The degradation is benign by construction: a reordering stops matching
the anchor, so results become `unrecognized`, which is today's behaviour plus a visible
note — never a silent wrong verdict.

## 4. The backgrounding anchor, and its residual

The `backgrounded` class is recognized by the harness's own notice text, pinned to its
smallest stable fragment: `still running after`.

**The benign-degradation argument does NOT extend to this anchor.** Harness prose is not an
API. If the notice is reworded, the payload stops matching, falls to `unrecognized`, and —
on a machine where the environment variable is not set — is counted again. The story's
false ✓ returns there.

That residual is accepted rather than engineered away, for a stated reason: **the
environment variable is the primary defence, not the anchor.** With
`CLAUDE_CODE_MCP_AUTO_BACKGROUND_MS` set, the call never leaves the foreground, so the case
cannot arise at all. The anchor exists to make the unset-variable case visible and
uncounted, and a reworded notice degrades that safety net to at most one disclosure note.

Recorded plainly so nobody reads the anchor as a guarantee: **a reworded notice on a
machine without the variable set reintroduces an uncounted-pass-counted-as-a-pass.**

## 5. State effects

Today the review branch creates the state directory, computes the fingerprint, updates the
fresh-streak counter, writes the fingerprint and bumps the pass count; the exec branch
bumps the Gate-A count.

- `success` and `unrecognized` — unchanged from today, in full.
- `failure` and `backgrounded` — **skip all of it**, including the directory creation. A
  discarded call is a non-event: prior state stays exactly as the last real pass left it.
  It is not reset, because resetting would destroy a legitimately earned pass.

**Classification runs even when the gate is opted out.** `.context/codex-gate.off`
suppresses messages, never state tracking — existing design, so that re-enabling lands on
accurate counters. Skipping classification while off would let a workspace accumulate
uninspected passes and then re-enable into the very false ✓ this change closes.

## 6. Messages

Wording is illustrative; the constraint is that each carries cause, effect and — where one
exists — the fix (`docs/prompt-standards.md`).

- **`failure`, every occurrence.** The call reported failure, so it was not counted and no
  fingerprint was stored; an incomplete pass does not count toward the floor. Every time,
  because each is a distinct uncounted pass. The agent can already see the error; what it
  cannot see is that the counter did not move.
- **`backgrounded`, first time per workspace.** The pass was discarded, not counted: the
  call was moved to the background **at the auto-background threshold (120 s by default)**,
  so its result never reached the hook. This is a setup gap, not a failed review. Names
  `CLAUDE_CODE_MCP_AUTO_BACKGROUND_MS`, that it needs Claude Code ≥ 2.1.212, and that `0`
  disables auto-backgrounding rather than forcing it.
- **`backgrounded`, subsequently.** Short form: discarded, not counted, result never
  reached the hook — and the variable name as a pointer.
- **`unrecognized`, once per workspace.** This tool returns a result the hook cannot
  verify, so its passes are counted without inspection and may include calls that failed or
  reviewed nothing. **No fix instruction**: for a third-party server there is none we can
  name, and inventing one would overclaim.

The threshold is described as a default, never as a constant — it is configurable, so
stating it as fixed would be a claim the code does not make.

**Marker mechanics** follow the unknown-tool precedent: two new marker files, each written
**only if `emit` succeeded**, so a note suppressed by the off-switch does not burn its
one-shot. The suite already asserts this for the existing note; both new markers get the
same coverage.

## 7. Testing

**Sequencing.** The test helper `rev()` currently sends a payload with no `tool_response`
at all, so every existing assertion drives the hook with a result-less payload. It is
updated to carry a real success envelope **before** the classifier lands, so the suite is
green on both sides of the edit and those tests exercise the `success` path rather than
passing by fallback. A test that deliberately wants a result-less payload must say so
explicitly.

**Coverage**, driven from the captured fixtures rather than hand-written JSON:

- `success` counts and stores.
- `failure` — both `CODEX_EXECUTION_FAILED` and `CODEX_TIMEOUT` — neither counts nor stores.
- `backgrounded` neither counts nor stores, emits the fact, emits the advice once, and does
  not burn its marker when suppressed.
- `unrecognized` counts, stores, and discloses once.
- **Both collision fixtures:** a successful review whose summary quotes both marker
  literals must classify `success`; a failed review whose summary quotes `\"success\":
  true` must classify `failure`. The second matters more — that is the direction where a
  mistake produces the false ✓ this story exists to close.
- `jq`-absent parity for every class, following the suite's existing `jq`-absent pattern.
- The hook exits 0 on every path, including an unreadable result.

**The `+check` evidence:** the shape-1 and shape-2 tests must be verified failing against
the pre-change hook before the change lands. That is the counterfactual the validation mode
requires, and it is an observation to record, not an assertion to make.

## 8. Cancellation (story open question 1)

Four attempts failed to produce a mid-flight abort, and what they did establish:

- **Esc** rejected the tool call **before dispatch**, twice. No `PostToolUse` fired, and
  Codex never started — verified by the absence of any new session under `~/.codex/sessions`
  in the window and no tracking directory in the probe repo.
- **`TaskStop` after backgrounding** fired no event, twice. The counter had already moved
  at the backgrounding point.

So **no cancellation path that could be produced fires a hook event**, and cancellation is
not a false-✓ vector in any observed form. The residual, stated precisely: an Esc landing
*after* dispatch was never produced in four attempts, which is weak evidence the harness may
not expose that window. No recognizer is written for it — a matcher built against a shape
nobody has seen fails silently and in the dangerous direction. Should it exist, it lands in
`unrecognized` and counts as today, so there is no regression either way.

## 9. Documentation and packaging

- `README.md` `## Setup` documents the variable: its name, Claude Code ≥ 2.1.212, that `0`
  disables auto-backgrounding rather than forcing it, and what goes wrong without it.
- `CLAUDE_CODE_AUTO_BACKGROUND_TIMEOUT_MS` is **not** documented. It exists in the 2.1.220
  binary's environment string table but its behaviour was never exercised; naming the wrong
  one of the two in setup text is this repo's docs-drift class.
- The `/workflow-init` preflight is **out of scope** for this story; a follow-up entry is
  filed in `todos.md`.
- Plugin manifest version bump (invariant 12) and a `CHANGELOG.md` entry.

## 10. What this does not do

- It does not make a counted pass mean Codex read the reviewed bytes. Gate-B validity stays
  content-derived; this change only stops calls that returned no review from counting.
- It does not verify third-party envelopes. Those count uninspected, with disclosure.
- It does not survive a reworded backgrounding notice on a machine without the variable set
  (§4).
- It does not classify a post-dispatch cancellation, which was never produced (§8).
