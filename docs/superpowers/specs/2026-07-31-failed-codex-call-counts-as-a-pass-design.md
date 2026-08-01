# Gate-pass result classification — Design

**Date:** 2026-07-31
**Story:** `docs/superpowers/stories/2026-07-30-failed-codex-call-counts-as-a-pass-story.md`
— read its header for the current risk/security/validation profile; this spec deliberately
does not copy those values, so there is one writable copy. (The story was amended twice during this
design's Gate A — §2 at pass 2 and again at pass 5, and the §3 criteria at pass 4. Each
amendment is recorded inline in the story with what it replaced.)

**Evidence:** captured `PostToolUse` payloads, currently in `.context/probe-payloads/`.
§7 moves them to a tracked, shipped home.

## 1. What this changes

The hook advances its pass counters — and, for Gate B, stores a content fingerprint — on
Codex calls that reviewed nothing, because nothing in the `PostToolUse` path inspects the
result before counting. This adds one classifier that reads the result and decides whether
the call earned a pass.

## 2. Settled decisions

Decided by the human; recorded with their reasons so a later reader does not re-litigate
them.

1. **Classification keys on the result envelope, not the tool name.** A tool mapped via
   `.context/codex-gate.tools` is in scope — **within the reachable namespace**. The hook is
   invoked by a `hooks.json` matcher of `^(Bash|Skill|mcp__codex__.*)$`, so a mapping naming
   a tool outside `mcp__codex__*` can never fire, and always could not. The matcher is left
   as it is: broadening it would start a hook process on every MCP tool call in every
   adopted workspace, which is a real cost for a case with a one-line remedy — register the
   third-party server under the server name `codex`, which places its tools in the reachable
   namespace. The boundary and that remedy are documented where the mapping is documented,
   and the mapped-tool tests use `codex`-namespaced names, which is the path that can
   actually fire.
2. **An unrecognized envelope FAILS OPEN** — it counts, plus a once-per-workspace
   disclosure. Fail-closed would zero the counters permanently for every third-party server
   with no fix available to the user, which is the hook's own worst failure mode ("reviews
   run, counters stay 0, and the STOP fires on every commit forever — which trains the user
   to ignore the hook", `codex-gate.sh`).
3. **An unreadable result FAILS CLOSED**, as a class distinct from `unrecognized`.
   Decision 2's rationale is third-party envelope *variance inside a result*: a result the
   hook can see but cannot interpret. A payload from which no result text can be obtained is
   a different thing — there is nothing to interpret — so fail-open's rationale does not
   reach it. Note the narrower premise this rests on: for the *pinned* server the shape is
   unproducible, but a mapped third-party tool may legitimately return empty or non-text
   content (§3.1). Fail-closed holds either way, because an unreadable result is not
   evidence of a review; only the diagnosis differs (§6).
4. **A discarded pass reports the fact on every occurrence; the setup advice appears once
   per workspace**, and the short form still names the variable, because the marker outlives
   the session that saw the long form.
5. **Cancellation is not a false-✓ vector in any observed form**; no recognizer is written
   for an unobserved shape (§8).

## 3. Classification

Runs on `PostToolUse` for the two gate tools (default names or mapped ones) and returns
exactly one of five classes.

### 3.1 Obtaining the result text

**Which block, settled here.** The classifier reads the **first array element of
`tool_response` whose `type` is `text`**, and its `text` value. Not element `[0]`: a mapped
tool may legitimately return an image or other block first, and indexing blindly would miss
the result or feed a non-text block to the matcher.

**Locating is where the two environments differ; matching is not.** Both paths produce the
**same representation** — the block's text in its **escaped** JSON encoding — and hand it to
one matcher (§3.2). There is no decoded-vs-escaped equivalence to maintain, no parity rule
over matching, and no second implementation of the classification contract.

- **With `jq`:** locate structurally, then **re-encode to the escaped form**. The selector
  must implement the structural contract rather than assume it: gate on `tool_response`
  being an **array**, skip elements that are not objects, take the first whose `type` is
  exactly `text`, and require its `text` to be a **string** — a bare
  `.tool_response[]? | select(.type=="text") | .text` does none of these (`[]?` iterates an
  object's *values*, `select` errors on a non-object element, and `.text` goes untyped).
- **Without `jq`:** an escape-aware scan locates the same block; what it yields is already
  the escaped form.

**Byte-position heuristics are unsafe in both directions**, so neither is used: a greedy
strip anchors on the *last* `tool_response` match, which a result quoting the key can
hijack; a first-match strip anchors on the *earliest*, which `tool_input` can hijack, and
this repo's own gate prompts quote payload text.

**The matcher always consumes the payload's own bytes.** After locating, the `jq` path
re-encodes the block and finds that byte sequence in the payload; **the matcher then reads the
payload at that position**, never the string `jq` produced. Two conditions must hold or the
payload is **`unrecognized`**: the re-encoded block must occur **exactly once** in the
payload, and the occurrence must lie **within the located `tool_response` span**.

Both conditions are load-bearing. "Appears somewhere" is not enough: a canonical copy sitting
in `tool_input` would satisfy it for a response that is *not* canonical, and a non-canonical
escape appearing after an otherwise-canonical marker would leave the two environments
disagreeing about the same bytes. Requiring a unique in-span occurrence, and feeding the
matcher the original bytes, makes both environments read the same input or refuse together —
so the divergence is *removed* rather than documented.

**Mislocation is safe by construction.** If the block cannot be resolved unambiguously — the
key appears more than once and depth cannot be established, or the canonical-form check above
fails — the payload is **`unrecognized`**, which counts and discloses. Locator uncertainty
never produces a *wrong verdict*; it produces a counted pass whose disclosure is **attempted
and normally persisted**. Where both the emit and the pending write fail (§5.2) that count is
silent, so "never silent" would be false: the verdict is never wrong, the disclosure is
best-effort.

**The class definitions are normative in the §3.3 table and stated nowhere else**, so an
edit cannot desynchronize them. What §3.1 contributes is the input those definitions consume:
the located block, or a determination that none can be had. The one boundary worth naming
here, because it is a property of *locating* rather than of any class: an unambiguous
determination that there is nothing usable is a different outcome from not being able to
determine anything, and §3.3 routes them to different classes — fail-closed and fail-open
respectively.

**Why fail-closed is right here, at the precision the evidence supports.** For the pinned
server these shapes are unproducible, so each indicates a payload-contract change. That
premise does **not** generalize: a mapped third-party tool may legitimately return empty
content, an image block, or another non-text shape. Fail-closed holds either way — an
unreadable result is not evidence of a review — but the *diagnosis* must not assume the
harness is at fault (§6).

### 3.2 Reading the marker

**One matcher, one representation.** On the escaped text produced by §3.1, the marker reads
`\"success\": true` or `\"success\": false`.

**Immediately-first, not merely first.** It must be the envelope's first property,
immediately after the encoded object opening, allowing encoded JSON whitespace. "First
occurrence anywhere after the opening" would still match under key reordering, contradicting
the benign-degradation claim below; requiring immediate-first position is what makes
reordering degrade to `unrecognized` rather than to a wrong verdict.

**Whitespace tolerance** between key, colon and value. Only the current serializer's
two-space form has been observed; a formatting change should not silently reclassify.

**Neither path parses the result text as nested JSON.** `jq` decodes it as a string value
and re-encodes it; the scan never decodes at all. What neither does is run a JSON parser
*into* the result string, which is what the open escaped-quote defect makes unsafe.

### 3.3 The five classes

**This table is the single normative definition of the five classes.** Every other section
refers to it rather than restating it.

| Class | Recognized by | Counter | Fingerprint |
|---|---|---|---|
| `success` | located block's immediate-first property is `success: true` | bump | store |
| `failure` | located block's immediate-first property is `success: false` | no | no |
| `backgrounded` | the notice anchor (§4), at start of the located block | no | no |
| `no-result` | an **unambiguous** determination that no located block yields a non-blank string: `tool_response` absent, `null`, empty array, non-array container, non-object elements, no `text`-type element, `text` not a string, or blank text | no | no |
| `unrecognized` | everything else — a located block matching no anchor, **and every case where locating itself is uncertain**: ambiguous boundary, repeated depth-1 `tool_response` key, or a failed uniqueness/in-span check (§3.1) | bump | store |

Stating `no-result` by its complement is deliberate: a hooks-API shape nobody anticipated
lands in the **fail-closed** class, which is the direction that matters, since `unrecognized`
counts.

**"Blank" is defined on the shared representation, not semantically**, or the two environments
could disagree on a state-changing boundary. The located block is blank when its **escaped
bytes** contain nothing but ASCII space and the two-byte escapes `\n`, `\t`, `\r`. A
Unicode-escaped space (`\u0020`) is *not* blank by this rule, and does not need to be: such a
block fails the canonical-form check first. **Order is fixed** — canonical-form validation
(§3.1) runs *before* the blank test, so every encoding `jq` would normalize has already been
routed to `unrecognized` and never reaches this comparison. §11 item 3 carries the full
encoding table.

**Malformed outer JSON is not a class at all, and pass 6 got this wrong.** The hook derives
`hook_event_name` and `tool_name` from the same document; if it is malformed, the hook cannot
establish that this was a gate call, so it can neither classify it nor address a message to
it. Assigning it `no-result` would demand an every-occurrence gate diagnosis on an invocation
that might have been a `Bash` PreToolUse. A payload the hook cannot **route** therefore
touches no state and emits nothing, exiting 0 — the pre-existing behaviour for anything it
cannot parse, and unchanged here.

**One outcome is settled here**, because it is a classification rather than scanner mechanics:
a **repeated depth-1 `tool_response` key** is **`unrecognized`** (the locator is genuinely
ambiguous). The plan defines only how the scanner *recognizes* that state, not what it means.

**Precedence, total and explicit:** `no-result` → `backgrounded` → envelope polarity →
`unrecognized`. Every payload reaches exactly one class, because `unrecognized` is the
terminal default and `no-result` is decided structurally before any text matching.

**What the envelope anchor rests on.** `success` being the envelope's first key is observed
`mcp-codex-dev@1.0.1` behaviour, verified two ways: every captured envelope shows it, and
every tool-level return in the pinned server leads with `success` — `codex-exec.js` (success
and catch returns) and `codex-review.js` at three sites (catch, `full`-mode, single
reviewer) — each serialized with `JSON.stringify(result, null, 2)`, which preserves
insertion order. **It is not a JSON guarantee.** A future reordering stops matching, so
results become `unrecognized`: today's behaviour plus a visible note, never a silent wrong
verdict.

## 4. The backgrounding anchor, and its residual

**The exact pattern**, anchored at the **start of the result text**: the text begins with
`MCP tool "`, and the segment `" is still running after ` follows before any newline. The
variable parts are therefore explicit — the quoted tool name (`codex/exec`, `codex/review`,
or any mapped name), the threshold value, and the task id are all outside the matched
anchor, so the anchor covers both gate tools and any configured threshold. A bare fragment
such as `still running after` is *not* the anchor: it can legitimately occur inside a
result's own summary — a review discussing this mechanism would contain it — and would let
one payload satisfy two anchors.

**Precedence, stated defensively:** `backgrounded` is tested before the envelope polarity,
and only at start-of-text. A genuine notice never begins with an encoded envelope opening
and a genuine envelope never begins with the notice prose, so the two are disjoint by
construction — and the ordering keeps the outcome defined even if a future payload violates
that.

**The benign-degradation argument does NOT extend to this anchor.** Harness prose is not an
API. If the notice is reworded, the payload stops matching, falls to `unrecognized`, and — on
any runtime where auto-backgrounding is still **effective** — is counted again. That is
broader than "the variable is unset": it also covers a Claude Code older than 2.1.212, which
does not read the variable at all, and a *positive* value shorter than the call, which
backgrounds anyway. The story's false ✓ returns there.

That residual is accepted because **the environment variable is the primary defence, not the
anchor**: configured correctly the call never leaves the foreground, so the case cannot
arise. The anchor is a safety net for the misconfigured case.

Recorded plainly: **a reworded notice, on any runtime where auto-backgrounding still takes
effect, reintroduces an uncounted pass being counted.**

## 5. State effects

### 5.1 Gate-pass state

State effects are a **column of the §3.3 table**, which is normative. This section explains
what those column values do; it does not restate which class gets which.

- Classes the table marks bump/store — today's behaviour, unchanged and in full.
- Classes the table marks no/no — **no gate-pass state is written or modified.**
  Every pre-existing pass-state file keeps its exact prior contents: `passCount`,
  `freshCount`, `passCountA`, and the fingerprint. A discarded call is a non-event; it is
  not reset, because resetting would destroy a legitimately earned pass.

**Concurrency contract, stated rather than changed.** Counter mutation stays
read-modify-write and unserialized, and the fingerprint, fresh-count and pass-count writes
stay independent. Concurrent `PostToolUse` events can therefore lose an increment or expose
a mixed snapshot. This **predates this change** and applies to every counter; the change
adds files with the same property, not new exposure, so fixing it here would be an
inconsistent partial repair. Filed in `todos.md` with a trigger.

**Trust contract, likewise stated.** The hook creates and truncates files inside a
repository-controlled `.context/`, following symlinks, and does not defend against a hostile
workspace — true today of every state file it writes. Filed in `todos.md` with a trigger.

### 5.2 Diagnostic state

Distinct from gate-pass state, and the only state a discarded call may write. Three paths:

| Path | Meaning |
|---|---|
| `.context/codex-gate.bgAdvice` | the long backgrounding advice has been shown |
| `.context/codex-gate.unverified` | the unrecognized-envelope disclosure has been shown |
| `.context/codex-gate.unverifiedPending` | a disclosure is owed but was suppressed |

A discarded call may create `.context/` and a marker on a best-effort basis — otherwise the
first-ever discarded call in a fresh workspace could never record that its advice was shown,
and the long advice would repeat forever. It must never create, clear or rewrite a
**pass-state** file. Marker writes stay best-effort so a failure cannot break invariant 1.

**Lifecycle.** Markers are workspace-scoped and are *not* cleared by a commit reset, which
closes a Gate-B cycle rather than changing what the tool surface is capable of. `reset_all()`
in the suite clears them, or one-shot tests become order-dependent.

**State transitions for the disclosure:**

| Current | Event | Result |
|---|---|---|
| absent | `unrecognized`, gate on, emit succeeds | `unverified` written |
| absent | `unrecognized`, gate on, **emit fails** | `unverifiedPending` written (best-effort) |
| absent | `unrecognized`, gate off (emit suppressed) | `unverifiedPending` written |
| pending | any unsuppressed hook event | disclosure emitted, then `unverified` written and pending cleared |
| pending | emit fails, or `unverified` write fails | pending **retained** |
| shown | `unrecognized` again | nothing emitted, nothing written |

**Pending is cleared only after the shown-marker write succeeds.** A duplicated disclosure
is strictly better than a lost one, so the failure direction repeats rather than drops. If
both writes fail persistently the disclosure repeats every time — noisy, and the safe
direction.

**One residual is NOT covered by that, and is accepted explicitly — in both directions.**
It applies whenever the disclosure is not delivered *and* the pending write also fails:
either the gate was off and suppressed the emit, or the gate was on and the emit failed. The
gate-on path added above narrows the window but does not close it, so the claim is that the
emit-failure fix gives the disclosure a durable home when the write succeeds — not that it
removes the residual. Concretely: if an `unrecognized` call arrives, its disclosure is not
delivered for either reason, and the *pending* write itself fails, the pass has
already been counted and nothing durable records that a disclosure is owed. Re-enabling then
yields exactly the undisclosed satisfied count that pending exists to prevent. Two policies
were available: withhold the count until pending persistence succeeds, or accept the loss.
**The count is not withheld**, because doing so would make an unwritable `.context/` silently
stop counting legitimate passes — the permanent-zero-counter failure decision 2 exists to
avoid, arriving by a different route. So this is an accepted residual, not a covered case:
**an unrecognized call while off, whose pending write fails, is counted and never
disclosed.** It requires a write failure in a directory the hook otherwise depends on, which
is why it is accepted rather than engineered around.

**Pending is not only about the off-switch.** A failed emit while the gate is *on* leaves the
same debt: the call is counted and the disclosure was never delivered. Without a pending
write there, an unrelated later event has nothing to flush, and the workspace can reach a
satisfied count made of uninspected calls with the once-per-workspace disclosure never shown
— which is decision 2's guarantee broken through a path the gate-off reasoning never
covered. So a failed emit takes the same best-effort pending write as suppression does.

**Why pending exists.** While the gate is off, an `unrecognized` call still counts, but its
disclosure cannot be shown. Writing the shown-marker anyway would consume the one-shot for a
message nobody saw; writing nothing would let a workspace re-enable into a satisfied count
composed entirely of uninspected calls with no disclosure ever shown.

**Classification runs even when the gate is opted out** — `.context/codex-gate.off`
suppresses messages, never state tracking, so re-enabling lands on counters carrying the same
semantics as if the gate had been on throughout. Not "accurate" in the sense of counting only
earned reviews: an `unrecognized` call counts while off exactly as it does while on, so a
re-enabled workspace can hold an uninspected counted pass. Pending state exists to disclose
those (subject to §5.2's residual); the counters themselves are never evidence that a review
happened.

## 6. Messages

**Delivery is best-effort, and the categorical wording below is scoped to that.** "Once per
workspace", "every occurrence" and "nothing is dropped" describe the sequential, no-failure
case. They are not guarantees: a suppressed gate, a failed stdout, a failed marker write, the
accepted residual in §5.2, and concurrent check-emit-write sequences each permit a message to
be lost or repeated. The accepted directions are stated where each arises — duplication is
preferred to loss throughout. What *is* unconditional is narrower than "an unearned pass is
never counted", and stating it correctly matters because this paragraph exists to calibrate
expectations: a call classified `failure`, `backgrounded` or `no-result` is **never** counted,
message or no message. A genuinely unearned call that classifies `unrecognized` **is** counted
— decision 2 working as intended, and the accepted false-pass residual rather than an
exception to it.

**One emit per hook invocation.** `emit` writes a single hook JSON document, so two messages
cannot be two emits. When an invocation owes both a pending disclosure and a per-occurrence
message, they are **composed into one emit** — disclosure first, then the per-occurrence
message — with both `additionalContext` bodies joined and both `systemMessage` bodies
joined. Nothing is dropped and nothing is deferred; a deferred message would collide again
on the next event.

**Field split.** `additionalContext` (model-facing) carries the consequence for the gate.
`systemMessage` (user-visible) carries any operator action, because the operator is who can
perform it.

- **`failure`, every occurrence.** Not counted, no fingerprint stored; an incomplete pass
  does not count toward the floor. Every time, because each is a distinct uncounted pass —
  the agent can see the error, but not that the counter did not move.
- **`backgrounded`, first time per workspace.** Discarded, not counted: the call was moved
  to the background **at the auto-background threshold (120 s by default)**, so its result
  never reached the hook. A setup gap, not a failed review. The `systemMessage` names the
  operator action: set `CLAUDE_CODE_MCP_AUTO_BACKGROUND_MS` **in the environment Claude Code
  is launched from, then restart it** — the variable is read at process start, so exporting
  it inside a tool shell cannot affect the running parent. States that `0` disables
  auto-backgrounding, and that a *positive* value must exceed the longest expected gate call,
  since a positive value shorter than the call still backgrounds. Requires Claude Code
  ≥ 2.1.212.
- **`backgrounded`, subsequently.** Short form: discarded, not counted, result never reached
  the hook — plus the variable name as a pointer.
- **`no-result`, every occurrence.** No tool result was obtainable, so the pass was not
  counted. It names **two** causes rather than assuming the harness is at fault: a hooks-API
  payload contract change (check the Claude Code version and report it — for the pinned
  server this shape is unreachable), **or** a mapped third-party tool returning empty or
  non-text content, which is legitimate for that tool and simply unreadable as a gate result.
  **The tool name alone cannot tell them apart**, and the message must not pretend
  otherwise: decision 1's own remedy is registering a third-party server *as* `codex`, which
  makes the names identical. The checks it gives instead are `.context/codex-gate.tools` for
  an active mapping, and the effective MCP registration and pinned server version in
  `.mcp.json`. Where provenance stays unknown the message says so and offers both remedies
  rather than asserting one.
- **`unrecognized`, once per workspace.** Enumerates its causes, each with what can be done
  about it:
  - a pinned-server envelope whose key order or formatting changed — check the server
    version against `.mcp.json`; fixable by pinning back;
  - **a reworded harness backgrounding notice** (§4) — the call was backgrounded and the
    anchor no longer matches, so the remedy is the same
    `CLAUDE_CODE_MCP_AUTO_BACKGROUND_MS` guidance the `backgrounded` message carries;
  - a mapped third-party tool whose envelope this hook cannot read — **no user-side fix**;
  - an ambiguous or non-canonically-encoded payload (§3.1) — this resolves the same way in
    both environments, so installing `jq` does **not** change it;
  - a hook parser defect — **no operator fix**; the check is to run the hook against the
    captured payload and report the mismatch.

  Two causes lack an operator fix, and the message says so rather than claiming a single one
  does. **The list is not claimed to be exhaustive** — `unrecognized` is the terminal default
  class, so any future unmatched shape lands here too; the message says these passes are
  counted without inspection and may include calls that failed or reviewed nothing.

  Including the reworded-notice cause matters because §4 accepts that residual: without it,
  the one case where the hook silently counts a backgrounded call would also be the case
  where it withholds the setting that prevents recurrence.

The threshold is always described as a default, never a constant.

**Prompt conformance.** These are hook messages, so invariant 11 applies in full: every
final string — long, short, pending, and per-occurrence — is reviewed against **all 12**
items of `docs/prompt-standards.md`, not item 10 alone. The suite pins both output fields
with exact golden assertions, following the existing `matches exactly` tests, because a
clause grep cannot catch a negation or semantic drift.

**Marker mechanics.** A marker is written only if `emit` succeeded, where **success means a
complete hook JSON document was written to stdout** — not merely that the function was
called. Otherwise a note suppressed or truncated would burn its one-shot.

**This requires changing `emit` itself**, which today returns 0 unconditionally after its
output command: it must propagate the status of the write. Without that change the
definition above is unimplementable and the pass-2 fix it came from would be prose only. A
closed or failing stdout must therefore leave the marker unwritten and any pending state
retained — while the hook still exits 0, since invariant 1 is about the hook's exit status,
not about whether a message reached anyone.

## 7. Testing

### 7.1 Fixtures

Fixtures move to `plugins/dev-workflow/hooks/fixtures/`, tracked and shipped, resolved
relative to the test script's own directory so the suite works from the repo and from an
installed plugin copy alike. Invariant 12 covers plugin paths, so a fixture change requires a
version bump like any other.

**They are sanitized captures, and a `README` in that directory says so.** Machine-specific
metadata irrelevant to classification — `transcript_path`, session identifiers, `cwd` — is
neutralized. The `tool_response` block is kept **byte-exact**, because that is the object
under test. The README records each fixture's provenance and the fact of sanitization, so
"captured" stays an honest word.

The set covers **both gate tools**: every envelope captured so far is from `exec`, while the
classifier also governs `review` and Gate-B fingerprint storage, so real `review` envelopes
are captured for it. **A review response embeds review content** — file paths, code excerpts,
findings — and `tool_response` must stay byte-exact, so sanitization cannot clean it after the
fact. The review fixture is therefore captured **against a disposable synthetic repository
with controlled, non-sensitive content**, and the whole fixture is read end to end before it
ships. Capturing one from real work and scrubbing it afterwards is the shape to avoid:
byte-exactness and redaction are mutually exclusive. The source-level verification in §3.3 is corroboration, not a
substitute.

### 7.2 Sequencing

Existing helpers send payloads with no `tool_response` — `rev()`, `codextool()` and several
direct `exec` payloads. Under this design those become `no-result` and stop counting, so
**every existing counting call site is updated to carry a real success envelope before the
classifier lands**, not `rev()` alone. The suite is green on both sides of the edit. A
deliberately result-less helper is added for the `no-result` tests, so that case is stated
rather than inherited.

### 7.3 Coverage

- `success` counts and stores — **and asserts no disclosure marker was created**. Without
  that, the test cannot distinguish `success` from `unrecognized`, whose counter and
  fingerprint effects are identical, and would pass against a malformed envelope classified
  by fallback.
- `failure` (`CODEX_EXECUTION_FAILED`, `CODEX_TIMEOUT`), `backgrounded`, and `no-result`
  each neither count nor store.
- **`no-result` shape coverage**: absent field, `null`, empty array, non-array container,
  non-object elements, array without a `text`-type block, non-string `text`, and empty or
  whitespace-only `text`, in both parser environments.
- **Block selection**: a response whose first element is a non-text block followed by a real
  text block must classify from the text block, in both parser environments — the case that
  distinguishes "first `text`-type element" from "element `[0]`".
- **Writer-failure coverage**: with stdout closed or failing, in both parser modes, the hook
  exits 0, writes no shown-marker, retains any existing pending state, and **creates pending
  when none existed** (the gate-on failed-emit transition). Marker-write failure alone is not
  sufficient coverage — it leaves the `emit`-status path untested.
- **Seeded-state preservation, both gates**: for each discarded class, seed a legitimate
  `passCount`, `freshCount`, `passCountA` and fingerprint, then assert all are byte-identical
  afterwards — including **Gate-A `passCountA` for discarded `exec` calls**, and for mapped
  exec names. Empty-state assertions alone would pass an implementation that clears earned
  state.
- `unrecognized` counts, stores, discloses once; the pending path is asserted across an
  off→on transition, including retention when the shown-write fails.
- **Composition**: an invocation owing both a pending disclosure and a per-occurrence message
  emits exactly one valid hook JSON document containing both.
- **Mapped tools**: captured success and failure envelopes through mapped `exec` and `review`
  names, asserting the same classes and state effects as the defaults. Without this an
  implementation keying on default names only would satisfy the suite while violating
  decision 1.
- **Boundary and collision fixtures**: a `tool_input` containing `"tool_response"` before the
  real field; a result quoting `"tool_response"` after it; duplicate outer keys; a successful
  review quoting both marker literals (must classify `success`); a failed review quoting
  `\"success\": true` (must classify `failure`). The failure-direction cases matter most —
  that is where a mistake produces the false ✓.
- **Extraction parity, asserted on the matcher's input.** Every fixture runs through both
  locating paths, and the escaped block handed to the matcher must be **byte-identical**
  between them. Asserting only the final class would let two locating bugs cancel out and
  report a pass; asserting the input catches a locating divergence where it lives. The
  single matcher then needs no parity assertions of its own — there is only one of it.
- The former divergence cases (ambiguous boundary, Unicode-escaped marker,
  non-canonical encoding) now assert **`unrecognized` in BOTH environments** — the
  canonical-form check makes the `jq` path reach the raw scan's verdict. A test asserting a
  precise class with `jq` would pin the very divergence §3.1 removes.
- Golden assertions on both output fields for every message.
- The hook exits 0 on every path, including an unreadable result and a marker-write failure.

### 7.4 Validation evidence

- **The `+check` counterfactual:** the `failure`-class tests must be verified failing against
  the pre-change hook before the change lands — an observation to record, not an assertion to
  make.
- **The named verification**, required by the story's profile: a post-change rerun of the
  probe methodology, recording the counter and fingerprint reading for each of both failure
  envelopes, `backgrounded` with the variable absent, `backgrounded` prevented with the
  variable set, and one genuine pass that still counts. The evidence entry lands in the
  commit body per CLAUDE.md §5.

## 8. Cancellation (story open question 1)

Four attempts failed to produce a mid-flight abort. Established:

- **Esc** rejected the call **before dispatch**, twice: no `PostToolUse` fired, and Codex
  never started — verified by the absence of any new session under `~/.codex/sessions` in
  the window and no tracking directory in the probe repo.
- **`TaskStop` after backgrounding** fired no event, twice; the counter had already moved at
  the backgrounding point.

So **no cancellation path that could be produced fires a hook event.** The residual: an Esc
landing *after* dispatch was never produced in four attempts, which is weak evidence the
harness may not expose that window. No recognizer is written for it — a matcher built
against an unobserved shape fails silently and in the dangerous direction. Should it exist,
it lands in `unrecognized` and counts as today, so there is no regression.

## 9. Documentation and packaging

- `README.md` `## Setup` documents the variable: its name, Claude Code ≥ 2.1.212, that it
  must be set in the environment Claude Code is launched from (restarting an already-running
  session), that `0` disables auto-backgrounding, that a positive value must exceed the
  longest expected gate call, and what goes wrong without it.
- `CLAUDE_CODE_AUTO_BACKGROUND_TIMEOUT_MS` is **not** documented: it exists in the 2.1.220
  binary's environment string table but its behaviour was never exercised, and naming the
  wrong one of the two in setup text is this repo's docs-drift class.
**The shipped surface this change falsifies is larger than the hook**, and is enumerated
rather than gestured at, because a sentence left behind teaches the old mechanism. Three
groups:

- **Statements that the hook never inspects results.** The inline CLAUDE template scaffolded
  by `/workflow-init`, and this repo's own `CLAUDE.md` §5, describe the gate as keying on tool
  name alone and treat a pinned-server failure as counting. Both are edited to describe result
  classification — while **keeping** the instruction to discount artifact-validation failures,
  which classification does not cover and which stays instruction-backed.
- **Statements that opt-out leaves "accurate" counters.** `README.md`, the reminder text in
  `codex-gate.sh`, and `commands/workflow-init.md` each say this; all three take §5.2's
  contract instead — same semantics as gate-on, never evidence a review happened.
- **Every mapping instruction, not one example.** `commands/workflow-init.md` carries several
  independent ones, including a preflight remedy that renames the server *away* from `codex`,
  producing exactly the unreachable `mcp__<other>__*` configuration decision 1 describes; it
  is removed unless it also re-registers the effective server as `codex`. With it: the
  `codex-gate.tools` row in `README.md` and the unknown-tool message in `codex-gate.sh`. Each
  states the namespace boundary and the register-as-`codex` remedy.

Invariant 8 keeps `/workflow-init`'s templates inline, so all its occurrences are edited in
place. The hook message and the scaffolded CLAUDE text are prompts, so both carry golden
assertions (§6).
- The `/workflow-init` preflight is out of scope; a follow-up entry is filed in `todos.md`.
- Plugin manifest version bump (invariant 12) and a `CHANGELOG.md` entry.

## 10. What this does not do

Stated at the precision the mechanism supports:

- It suppresses exactly the classes the §3.3 table marks non-counting, and nothing more. It
  does not establish that a counted call reviewed anything: a call the table classifies
  `success` whose findings file is missing or malformed still counts, and remains an incomplete pass under the instruction-backed rule in
  CLAUDE.md §5.
- **Third-party envelopes are trusted for counting when they match the polarity grammar.**
  A mapped tool whose result begins with `success: true` is classified `success`, counted,
  and produces **no disclosure** — there is no provenance check and no verification that the
  tool reviewed anything. Only envelopes that match *no* anchor count with disclosure. This
  is the trust the design places in decision 1, stated rather than implied.
- It does not survive a reworded backgrounding notice; §4 defines that residual and the
  runtimes it covers, and is the only place that does.
- It does not classify a post-dispatch cancellation, which was never produced (§8).
- It does not serialize counter mutation, nor defend against a hostile `.context/` (§5.1) —
  both pre-existing, both filed.
- Gate-B validity stays content-derived; nothing here changes what the fingerprint compares.

## 11. Implementation contracts deferred to the plan

Raised as MAJOR at Gate-A pass 3 and **dispositioned, not resolved**: each is a real
requirement whose natural form is executable shell plus a test, not prose. They are listed
here because the plan must carry them explicitly at its top — a deferred obligation that
lives only in a review artifact is one nobody inherits. The plan's own Gate A pins each
against real code.

1. **The `jq`-free scanner as a state machine.** Quote state, consecutive-backslash parity,
   value boundaries, and what "depth 1" means operationally. §3.1 states the *contract*
   (structural with `jq`; conservative and non-guessing without); the plan states the
   machine.
2. **Duplicate and malformed key cases.** Which candidate wins when a depth-1 key repeats,
   and what happens on malformed JSON. §3.1 sends ambiguity to `unrecognized`; the plan
   defines what counts as ambiguous. **Which block is selected is NOT deferred** — §3.1
   settles it as the first array element whose `type` is `text`, and the plan defines only
   how the `jq`-free scanner locates that already-settled block.
3. **Accepted raw encodings for JSON whitespace.** Captured inner newlines are the two bytes
   `\n`, which POSIX `[[:space:]]` does not match. Every accepted encoding around each prefix
   token is enumerated in the plan, with compact, tab and CRLF fixtures.
4. **The full notice grammar.** §4 fixes the anchor; the plan fixes the variable spans —
   duration format, task-id boundary, quote representation — and the near-miss cases that
   must *not* match.
5. **The complete marker state table.** §5.2 covers the disclosure lifecycle; the plan
   extends it to the Cartesian states across both disclosure markers and `bgAdvice`,
   including coexistence precedence and every write, delete and retry failure.
6. **Composition against every existing emit branch.** §6 defines composition for a pending
   disclosure plus a per-occurrence message; the plan covers the Gate-A, Gate-B, WIP,
   docs-only and unknown-tool branches, and events that would otherwise emit nothing.
7. **Separator and encoding rules for composed messages.** Exact control-character-safe
   separators, wording that distinguishes the prior event from the current one, and the
   `jq`-free escaping required to keep the combined document valid.
