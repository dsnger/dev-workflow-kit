# Hook payload fixtures

Claude Code `PostToolUse` payloads, used by `codex-gate.test.sh` to drive the gate hook
with the result shapes it has to classify. Each fixture is one payload file plus a
sibling `<name>.response.json` holding that payload's `tool_response` array.

These are test inputs, not documentation. A row here that disagrees with the file is a
defect in this README.

## What each fixture exercises

| Fixture | Tool | Class | Origin |
|---|---|---|---|
| `shape0-success.json` | `mcp__codex__exec` | `success` | capture, sanitized |
| `shape0-success-review.json` | `mcp__codex__review` | `success` | capture, sanitized — synthetic repo, see below |
| `shape1-fast-fail.json` | `mcp__codex__exec` | `failure` (`CODEX_EXECUTION_FAILED`) | capture, sanitized |
| `shape2-executor-timeout.json` | `mcp__codex__exec` | `failure` (`CODEX_TIMEOUT`) | capture, sanitized |
| `shape3-backgrounding-notice.json` | `mcp__codex__exec` | `backgrounded` | capture, sanitized |
| `collision-success-quotes-both.json` | `mcp__codex__exec` | `success` | **synthetic**, edited from `shape0-success` |
| `collision-failure-quotes-true.json` | `mcp__codex__exec` | `failure` | **synthetic**, edited from `shape1-fast-fail` |

The two collision fixtures are synthetic **by necessity**: no real call produces a result
whose `summary` quotes both marker literals. They pin the direction that matters — a
success envelope quoting `"success": false` must stay `success`, and a failure envelope
quoting `"success": true` must stay `failure`. A first-match or last-match byte heuristic
fails on one of them.

## What was sanitized, and how

All five capture-derived payloads are real hook payloads — four `mcp__codex__exec` calls
made against this repository on 2026-07-30, and one `mcp__codex__review` call made against
a synthetic repository on 2026-08-02. They were edited **by hand**, never through `jq`:
passing a payload through `jq` reserializes `tool_response` and erases exactly the escape
and whitespace variants the classifier has to read, while a `jq -c '.tool_response'`
comparison would still call the result identical, because it compares semantics rather
than bytes. The review payload was sanitized by literal byte replacement with a count
assertion per substitution — the same thing, done mechanically.

Seven field values were replaced, and nothing else:

| Field | Replacement | Why |
|---|---|---|
| `session_id`, `prompt_id` | `00000000-0000-0000-0000-000000000000` | session identity |
| `transcript_path` | `/dev/null` | absolute path under `~` |
| `cwd`, `tool_input.workingDirectory` | `/tmp/fixture-repo` | machine layout; the second also carried a private scratchpad path |
| `tool_use_id` | `toolu_fixture` | session identity |
| `tool_input.instruction` | `probe: reply with ok` | prompt content across a trust boundary |

`permission_mode`, `effort`, `hook_event_name`, `tool_name` and `duration_ms` carry no
machine or prompt data and are exactly as captured. `tool_input` is **kept rather than
emptied**: this repo's own gate prompts quote payload text, so a realistic `tool_input` is
what makes the decoy assertions mean anything.

The review payload's `tool_input` carries three fields the `exec` captures do not.
`whatWasImplemented` and `additionalContext` are prompt content across the same trust
boundary as `instruction`, so they were replaced the same way (`probe: describe the
change`, `probe: report findings`). `baseSha`, `headSha` and `reviewType` are left as
captured — the two SHAs belong to a disposable synthetic repository and identify nothing.

Replacing `tool_input` values makes two fixtures causally inconsistent with their own
result — `shape1-fast-fail`'s original failure was caused by a nonexistent
`workingDirectory`, and `shape3`'s backgrounding by a long essay prompt. Nothing depends
on that consistency; the classifier reads `tool_response` and the routing fields only.

## What "byte-exact" covers, and what it does not

**The claim:** for all five capture-derived fixtures, the **located `tool_response` text
block** is byte-identical to the same block in the source capture, **apart from the named
identifier redactions below**:

| Fixture | Redacted | Original → replacement |
|---|---|---|
| `shape0-success.json` | Codex `sessionId` | `019fb3d4-…-ae5471c4a38f` → `00000000-0000-7000-8000-000000000000` |
| `shape0-success-review.json` | `specSessionId`, `qualitySessionId` | `019fc1d4-5421-…` → `00000000-0000-7000-8000-000000000001`; `019fc1d4-540f-…` → `…0002` |
| `shape3-backgrounding-notice.json` | background task id, both occurrences | `k7nsz5q4v` → `fixture01` |

Every replacement is the same length as what it replaces and changes no structural byte,
so the escape and whitespace grammar is untouched. `shape1` and `shape2` carry an empty
`sessionId` and needed no redaction.

The check that establishes this compares the located block from the source capture —
after applying **exactly** those substitutions — against the located block from the
fixture, and fails if any other byte moved. It also fails if a declared substitution
matches nothing, so a row cannot quietly degrade into a plain equality check.

**What the claim does not cover:** the bytes of the payload *around* the located block.
The seven sanitized field values differ by design, and inter-element whitespace inside the
`tool_response` array outside the located text block is not pinned by this claim.

## The response slices

Each payload has a sibling `<name>.response.json` holding only that payload's
`tool_response` array. They exist so the test driver can build payloads with `printf` and
`cat` alone: a machine without `jq` must fail the *hook*, not the driver, and
`sed`-extracting a multi-line array at test time would be a second parser nobody reviews.

The cost is one duplicated representation per fixture. What pins it is a permanent
assertion in `codex-gate.test.sh` — one per fixture — requiring the payload and its slice
to **locate identical bytes**, with both locator statuses checked before the comparison.
That is a claim about the located text block, not about the whole array: two slices
differing only in inter-element whitespace would satisfy it.

The slices were cut as a byte substring of the payload, verified by reconstructing the
payload from head + slice + tail and requiring the result to equal the original. Nothing
was re-serialized.

## `shape0-success-review.json` — how the review capture was taken

The other six fixtures are `mcp__codex__exec` payloads. This one covers
`mcp__codex__review` in `reviewType: full`, the mode this project's Gate B uses, whose
envelope carries `specSessionId` and `qualitySessionId` alongside `success` and whose
result text is a whole review rather than a word.

A review result cannot be redacted after the fact — it quotes the code it read — so it was
produced against a **disposable synthetic repository** holding two invented functions and
nothing else, located at a neutral path so no scratch or session directory could appear in
the review text. The whole file was read end to end before it was staged: it references
`widget.js` and nothing else, and carries no path, no real code and no finding about real
code.

**The capture method, and how foreign payloads were kept out.** Like the four `exec`
fixtures, this came from a stdin dump inserted into the installed hook. That hook serves
every project on the machine, and two other Claude Code sessions were live at the time, so
an unconditional dump would have written their payloads too. The dump was therefore made
**conditional** on this call's own shape — a review tool name *and* the synthetic repo path
— and verified in both directions before the real call: a foreign `Bash` payload wrote
nothing, a matching payload was captured. Every file the probe produced was audited
afterwards and all were this probe's own review calls.

The installed hook was backed up first, with the backup's checksum status checked directly
rather than through a pipeline, and restored and byte-verified against that recorded hash
after every call. The probe workspace was deleted afterwards; the source capture is parked
outside the repository, at `.context/probe-payloads/`, alongside the four `exec` captures.

**What follows for the claim.** Nothing special: this fixture's `tool_response` is covered
by the byte-exactness claim above, exactly like the four `exec` captures, with its two
session ids listed in the same redaction table.

## Adding a fixture

Add the payload, cut its slice, add both to the table above with the class it exercises,
and add its payload-vs-slice assertion to `codex-gate.test.sh`. A fixture with no slice
assertion can drift from its slice with every classification test still green.
