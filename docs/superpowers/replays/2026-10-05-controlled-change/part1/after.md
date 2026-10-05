# Run analytics, trace ID and retention (vision step 2c, part 1) — Story

**Date:** 2026-10-02 · **Size:** story
**Risk:** standard · **Security:** standard · **Validation:** battery+check

## 1. Problem statement
Part 1 of the epic `docs/superpowers/stories/2026-10-02-telemetry-and-review-loop-usefulness-story.md`.
The kit cannot say what a workflow step cost or how long it took. The raw facts already exist
outside the repository: Codex writes a session log per gate call (named by the session ID the gate
call returns, with token counts, timestamps and the model), and
Claude Code writes a transcript per session (with per-message token usage and timestamps). Nothing
joins those facts to the review cycles and stories they served, so a cycle's cost can only be
guessed. Nothing links a story's artifacts to one identifier either, and nothing says how long any
such data may be kept.

## 2. Desired outcome
A maintainer can ask how many Codex gate calls this clone ran, how long they ran and how many tokens
they used — including calls whose cycles never closed — and, for every review cycle that closed with
a provenance line, which story that effort belongs to. The answer comes from a local record rather
than from memory, together with what could not be measured. Story totals are **attributed effort**,
not a claim that every call of the story was captured.
The record holds numbers and identifiers only, and old records are removed by a stated rule.

## 3. Acceptance criteria
- [ ] For every Codex gate call found in a Claude Code transcript and shown to run in this clone, a
      local record holds its
      duration and, where its Codex session logs are present, its input, cached, output and
      reasoning tokens and its model. A value the logs do not provide is recorded as unknown,
      never as zero.
- [ ] A record's story is taken only from an unambiguous closing provenance line for its cycle's
      nonce. Every other record stays stored and reported as **unattributed effort**, with its
      reason (open cycle, conflicting records, no nonce) and its known and missing values; the
      report says how many records fall in each class.
- [ ] A trace ID identifies each story, and the same ID can be found in that story's stage
      artifacts (story, spec, plan, closing commit) for stories created after this lands.
- [ ] The record stores no prompt, response, file content or other session text — only numbers,
      timestamps, identifiers and model names. A check demonstrates this against a fixture that
      contains session text.
- [ ] The data lives per clone, outside git, and a stated retention rule (what is kept, for how
      long, how it is removed) is applied by the tool itself.
- [ ] Building or reading the record never blocks or changes any workflow step or gate; a source
      that cannot be read is reported as missing, not silently skipped.
- [ ] Money and credits are not reported. The report says that cost is not measured and why.


## 4. Affected AGENTS.md invariants
- `### Packaging` — "5. **Every version pinned exactly.**"
- `### Packaging` — "12. **A plugin change requires a version bump.**" (binds only if anything
  ships in the plugin; placement is repo-local by decision)
- `## Don'ts` — "**Never describe what a gate proves without checking what it actually
  compares.**"

## 5. Open questions
- Which part of the Claude Code transcript can be attributed to one gate call (the call's own
  timing), and which only to the whole session?
- How long should records be kept by default?

## 6. Suggested size
story — one repo-local, read-only collector over existing logs, its local store, the trace ID
convention and a retention rule; one spec → plan → PR. Decided by Daniel on 2026-10-02:
repo-local tool, data local per clone and outside git.
