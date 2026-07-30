# A failed Codex call counts as a gate pass — Story

**Date:** 2026-07-30 · **Size:** story
**Risk:** high · **Security:** standard · **Validation:** battery+check+verification

## 1. Problem statement

The gate hook advances its pass counters — and, for Gate B, stores a content fingerprint
— on Codex calls that reviewed nothing. Observed directly on 2026-07-30 in this repo:
`.context/codex-gate.passCountA` moved 3 → 4 on a call that ran 272 ms and never started
a review, and 3 → 5 across two further calls that returned failures. A satisfied count
therefore overstates the passes actually held, and for Gate B the stored fingerprint
describes content nobody read, so the satisfied message reports a fresh pass covering
exactly the content that was never reviewed. That is a false ✓ in the hook's recorded
state — the direction invariant 2 names as dangerous.

`mcp-codex-dev@1.0.1` catches its own failures and returns them as ordinary results
carrying `success: false`, so Claude Code classifies them as successful tool calls and
fires `PostToolUse`. Nothing in the hook's `PostToolUse` path inspects the result before
counting.

Three failure shapes were captured verbatim, and one remains unproduced:

1. **Fast fail** — the Codex result reports `success: false` with
   `error.code: CODEX_EXECUTION_FAILED`.
2. **Executor timeout** — the same envelope with `error.code: CODEX_TIMEOUT`.
3. **Auto-backgrounding at 120 s** — `PostToolUse` fires mid-flight, while Codex is still
   running, and the payload carries the harness's prose notice instead of any Codex
   result. The eventual real completion fires no second `PostToolUse`, so the call is
   counted at t=120 s and its true outcome never reaches the hook at all. This is not
   hypothetical: a real Gate-B `mcp__codex__review` pass on another project hit it during
   this session, at `duration_ms: 120002`.
4. **Abort during the first 120 s** — not produced; see Open questions.

In every shape the only failure signal is double-encoded inside the tool response text;
no `isError` field exists anywhere in the payload.

Shape 3 is preventable, and this was verified rather than assumed. With
`CLAUDE_CODE_MCP_AUTO_BACKGROUND_MS` set in the environment of the Claude Code process,
a call that runs past 120 s stays in the foreground and its `PostToolUse` payload carries
the real Codex result as parseable JSON. Measured on Claude Code 2.1.220 with two
end-to-end runs against a Codex server configured to time out at 135 s: `duration_ms`
135370 with the variable at `600000`, and 135431 with it at `0` — both past the 120 s
backgrounding point, both delivering `error.code: CODEX_TIMEOUT` as readable JSON. So `0`
disables auto-backgrounding rather than forcing it. The hook process does inherit the
variable: the same hook read `[600000]` and `[0]` on those two firings while reading
`<unset>` on firings from a session that did not set it.

**Why this is more than a local defect.** The hook is the shipped enforcement core: every
project that installs the plugin inherits its counting semantics, so a defect here
distributes a false ✓ to every consumer rather than to this repo alone, and the failing
effect — gate state reporting reviews that never happened — undermines the workflow's
central guarantee.

The 0.5.1 prompts already classify a timeout or abort as an incomplete pass and require
discounting it regardless of the counter. So the gap is not that no mitigation exists; it
is that the mitigation is instruction-backed and depends on the agent noticing the failed
result, while the hook's own recorded state is wrong either way and stays wrong for
whoever reads it later.

## 2. Desired outcome

A Codex call that did not deliver a review does not leave a pass behind. The hook's
recorded state — counters and the Gate-B fingerprint — reflects only calls whose result is
present and reports success. Where a call's outcome cannot reach the hook at all, the
operator learns that from the reminder, together with the setting that prevents it,
instead of receiving a silent ✓. The workflow stays usable on machines that lack that
setting: a discarded pass reads as an actionable setup gap, not as a failed review.

## 3. Acceptance criteria

- [ ] Given a `PostToolUse` payload for a Codex gate tool whose result reports failure, no
      pass counter advances and no Gate-B fingerprint is stored — checked against both
      payloads captured on 2026-07-30 (`CODEX_EXECUTION_FAILED`, `CODEX_TIMEOUT`).
- [ ] Given a payload carrying no readable Codex result at all — the auto-backgrounding
      notice being the observed instance — no counter advances and no fingerprint is
      stored.
- [ ] In that case the reminder states that the pass was discarded because the call left
      the foreground, distinguishes this from a failed review, and names
      `CLAUDE_CODE_MCP_AUTO_BACKGROUND_MS` as the fix.
- [ ] A Codex call whose result reports success still counts exactly as it does today: the
      counter advances and, for Gate B, the fingerprint is stored.
- [ ] Behaviour on all of the above is identical whether or not `jq` is on `PATH`.
- [ ] The hook exits 0 on every path above, including when the result cannot be read.
- [ ] `CLAUDE_CODE_MCP_AUTO_BACKGROUND_MS` is documented where someone setting up the
      workflow will see it, stating that it requires Claude Code ≥ 2.1.212 and that `0`
      disables auto-backgrounding rather than forcing it.
- [ ] Regression tests cover shapes 1–3 and the success path, and the shape-1 and shape-2
      tests fail against the pre-change hook.
- [ ] The probe methodology is re-run against the changed hook and its counter readings
      recorded: shapes 1–2 from the captured payloads, shape 3 with the variable absent,
      shape 3 with it set, and one genuine pass that still counts.
- [ ] The plugin manifest version is bumped.

## 4. Affected AGENTS.md invariants

- `### Hook` — "**The hook always exits 0.** It is advisory; a reminder that can fail
  closed would make the workflow unusable whenever Codex is down or the environment is
  odd." Constrains the shape of "fail closed" here: withholding a *count* must not become
  a non-zero *exit*, and the reminder must stay usable when the environment is odd.
- `### Hook` — "**Loose in the firing direction.** On uncertainty, fire. A missed commit
  (false ✓) is the dangerous direction; a redundant warning is the accepted price."
  Aligned rather than in tension: declining to count an uncertain pass leaves the gate
  firing.
- `### Hook` — "**Gate-B validity is content-derived, never event-derived.** Invalidation
  compares a fingerprint of the effective index plus the included worktree content, as of
  the hook's invocation …" The fingerprint *store* is what must be suppressed; the
  comparison semantics are unchanged.
- `### Hook` — "**POSIX `sh`, and `jq` is optional.** No bash-isms; correct behaviour via
  fallback parsing when `jq` is absent." The failure signal is nested inside a JSON
  string, so both parsing paths must reach it.
- `## Architecture` (Dependency direction) — "and on a Codex MCP server exposing both
  `exec` and `review` (the gates key on those two tool names)."
- `### Prompts and scaffolding` — "**Prompt changes pass `docs/prompt-standards.md`** —
  all 12 checklist items, for any skill, command, agent definition, hook message, or
  scaffolded template." The new reminder text is a hook message.
- `### Packaging` — "**A plugin change requires a version bump.**"

## 5. Open questions

- Does an abort during the first 120 s fire `PostToolUse` at all, and if so with what
  payload? Unproduced: `TaskStop` after backgrounding yielded no further event, so it does
  not stand in for an interactive abort. If it fires nothing, aborts are not a false-✓
  source; if it fires something, its shape is unknown.
- The captured shapes are specific to `mcp-codex-dev@1.0.1`. A server mapped in via
  `.context/codex-gate.tools` may report failure differently — is such a payload in scope,
  or explicitly out?
- Should the absent-variable warning appear on every gate call, or once per workspace like
  the existing unknown-tool note?
- `CLAUDE_CODE_AUTO_BACKGROUND_TIMEOUT_MS` exists in the Claude Code 2.1.220 binary's
  environment-variable string table (2 occurrences, found by the same grep that located
  the variable above), but its behaviour was never exercised and it is presumed to govern
  a different surface. Treated as out of scope and deliberately kept out of the
  documentation criterion, since nothing observed says what it does. Naming the wrong one
  of the two in user-facing setup text would be this repo's docs-drift class.

## 6. Suggested size

`story` — one coherent defect with one mechanism, fitting a single spec → plan → PR; the
hook change, its tests and the setup documentation are parts of it, not separable stories.
