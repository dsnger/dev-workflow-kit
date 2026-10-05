# Run analytics, trace ID and retention (vision step 2c, part 1) — Story

**Date:** 2026-10-02 · **Size:** story
**Risk:** standard · **Security:** standard · **Validation:** battery+check

## 1. Problem statement
Part 1 of the epic `docs/superpowers/stories/2026-10-02-telemetry-and-review-loop-usefulness-story.md`.
The kit cannot say what a workflow step cost or how long it took. The raw facts already exist
outside the repository: Codex writes a session log per gate call (named by the session ID the gate
call returns, with token counts, timestamps, the model and the account's credit balance), and
Claude Code writes a transcript per session (with per-message token usage and timestamps). Nothing
joins those facts to the review cycles and stories they served, so a cycle's cost can only be
guessed. Nothing links a story's artifacts to one identifier either, and nothing says how long any
such data may be kept.

## 2. Desired outcome
A maintainer can ask, for any review cycle or story in this repository, how many gate calls it
took, how long they ran, how many tokens they used and how the credit balance moved, and get the
answer from a local record rather than from memory, together with what could not be measured.
The record holds numbers and identifiers only, and old records are removed by a stated rule.

## 3. Acceptance criteria
- [ ] For every Gate A and Gate B call whose Codex session log is present, a local record holds
      its duration, input, cached, output and reasoning tokens, model and credit-balance change.
      A value the log does not provide is recorded as unknown, never as zero.
- [ ] Each record is attributed to the review cycle (nonce) and story it served wherever that is
      determinable, and is marked unattributed where it is not; the report says how many records
      fall in each class.
- [ ] A trace ID identifies each story, and the same ID can be found in that story's stage
      artifacts (story, spec, plan, closing commit) for stories created after this lands.
- [ ] The record stores no prompt, response, file content or other session text — only numbers,
      timestamps, identifiers and model names. A check demonstrates this against a fixture that
      contains session text.
- [ ] The data lives per clone, outside git, and a stated retention rule (what is kept, for how
      long, how it is removed) is applied by the tool itself.
- [ ] Building or reading the record never blocks or changes any workflow step or gate; a source
      that cannot be read is reported as missing, not silently skipped.
- [ ] The credit-balance change is labelled as an account-wide figure, which other concurrent
      Codex use can contaminate, wherever it is reported.

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
