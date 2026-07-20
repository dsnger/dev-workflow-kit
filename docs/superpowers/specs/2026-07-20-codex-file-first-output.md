# Spec — file-first output protocol for the Codex review gates

Date: 2026-07-20 · Source: field finding (manual, major) · Hardening rung: **P std**

## The finding

**Observed, in the field:** `mcp__codex__exec` responses arrive cut off on long finding
lists — on effectively every substantial Gate A pass in real project use. Field agents
already work around it ad hoc by having Codex write output to a file. An improvised
workaround per session means the failure mode is handled only when someone notices — and
a cut that lands between findings is indistinguishable from a complete list: silently
dropped findings, the dangerous direction.

**Documented, in current Claude Code docs** (https://code.claude.com/docs/en/mcp.md,
read 2026-07-20) — two separate mechanisms, neither of which the docs describe as
truncation:

- a **token limit**: a warning above 10,000 tokens, and output "limited to 25,000 tokens
  by default", raisable via `MAX_MCP_OUTPUT_TOKENS`. The docs state the limit; they do
  not state what happens to output past it.
- a **persist-to-disk threshold** (character-based, separate from the token limit):
  "results that exceed the default threshold are persisted to disk and replaced with a
  file reference in the conversation", unless the tool declares
  `_meta["anthropic/maxResultSizeChars"]` (hard ceiling 500,000 characters).

**Not established:** which mechanism produced the field loss, or on which Claude Code
version — and nothing here examines the MCP transport protocol itself, so the loss is
not attributed to it. Stating this rather than asserting "the transport truncates"
matters because the wrong attribution sends the next reader to harden the wrong layer.

**The hardening does not depend on the answer.** Keeping findings out of the response
entirely is correct whether an over-limit response is truncated in place, persisted to
disk behind a file reference, or dropped some third way: under this protocol each Codex
branch replies with one short line, so the response stays orders of magnitude below any
of these thresholds. "One short line" is the per-branch contract, not the shape of every
aggregate response — a Gate-B `reviewType: full` call returns the server's own merged
wrapper (its `Spec Compliance Review` / `Code Quality Review` headings and separator)
around the two branch lines, and the MCP layer serializes that into a JSON result. Still
bounded and small; just not literally one line, and the reader validates the two files
rather than parsing that wrapper.

## Decision

Both gate prompts move the findings **out of the MCP response and into a file**, with a
terminator the reader verifies.

### The protocol (appended to the Gate A and Gate B prompts)

> Write the FULL findings list to `.context/codex-reviews/<slot>.md` — create the
> directory if needed; the path is relative to the repo root. `<slot>` is:
>
> (Every gate call and every branch resume passes the reviewed repo root as
> `workingDirectory`, and the reader resolves the pre-call delete and the post-call read
> against that same absolute root. Codex resolves writes against its working directory,
> so without this a compliant model can write a perfectly valid file into a different
> checkout — the reader then sees a missing target and burns its one recovery attempt on
> a configuration mismatch no retry fixes.)
>
> | Gate | `<slot>` |
> |---|---|
> | Gate A, spec run | `gate-a-spec-pass-<n>` |
> | Gate A, plan run | `gate-a-plan-pass-<n>` |
> | Gate B | `gate-b-<your review type: spec\|quality>-pass-<n>` |
>
> Write one finding per line, exactly in the format given above
> (`SEVERITY | confidence | location | what is wrong | why it matters | suggested fix`):
> one line per finding, no wrapped continuations, no blank lines, no headings, no other
> prose. Six fields, so a literal pipe inside any field is escaped `\|` — the same
> convention `docs/hardening-log.md` uses — otherwise a field containing a pipe reads as
> a seventh field and a well-formed finding looks malformed. End the file with a final
> line reading exactly `END OF FINDINGS (<n> total)`, where `<n>` is the number of
> finding lines you wrote. For a clean pass the body is the single line `NO FINDINGS`
> and the terminator reads `END OF FINDINGS (0 total)`.
>
> Every line before the terminator is exactly one finding line — or, for a clean pass,
> the single line `NO FINDINGS`. No blank lines anywhere in the file.
>
> Then reply with ONLY one line — one line per Codex branch; a `full` Gate-B call wraps
> the two branch lines in the server's own merged-review formatting, which is expected —
> in one of these two forms:
>
> ```
> <gate> | pass <p> | <n> findings | <path>
> INCOMPLETE | <cause> | <path>
> ```
>
> where `<p>` is the same decimal pass number used in the slot name, and `<cause>`
> carries no literal pipe (escape one as `\|`):
>
> for example:
>
> ```
> gate-a-spec | pass 2 | 10 findings | .context/codex-reviews/gate-a-spec-pass-2.md
> INCOMPLETE | permission denied creating .context/codex-reviews/ | .context/codex-reviews/gate-b-spec-pass-1.md
> ```
>
> Do not repeat the findings in the reply. Use the `INCOMPLETE` form whenever the file
> was not written in full — an unwritten file behind a normal-looking reply is the one
> outcome the reader cannot diagnose.

**Gate B takes one file per reviewer branch** because `reviewType: full` runs the spec
and quality reviewers in parallel from one `additionalContext` (it returns
`specSessionId` and `qualitySessionId` separately). Pointed at a single shared path they
race, and the second writer leaves a correctly terminated, correctly counted file holding
only its own branch — half the findings gone, with every check still passing. With
`reviewType: spec` or `quality`, only that branch's file appears.

**Delete every target file before each call, and confirm it is gone.** A call that dies
part-way leaves the previous attempt's valid file in place, and a terminator cannot
distinguish a stale complete file from a fresh one — so an undeleted target would
reinstate exactly the silent failure the delete exists to close. If a target still
exists after the delete, stop and surface it; do not call Codex, because from that point
on a valid-looking file proves nothing about this pass. Name the cause when you surface
it — the four an agent can tell apart are: the path resolved against the wrong directory
(check it against the repo root you passed as `workingDirectory`), a permissions failure
on the file or on `.context/codex-reviews/`, a *directory* sitting at the target path,
and a file that reappears after deletion (another writer — see the one-pass-at-a-time
limitation). Each takes a different fix, and "delete failed" alone sends the reader
retrying the delete.

**One pass at a time.** The slot name has no invocation-unique component, so two
concurrent calls sharing a gate, review type and pass number would race for one path.
Passes are sequential by construction — you fix findings between them — so this is a
stated limitation, not a guarded one.

### The reader's obligation

The reader (Claude) accepts a pass only when **all** hold:

1. the file exists and is readable;
2. its last line is exactly `END OF FINDINGS (<n> total)`;
3. every line before the terminator is exactly one finding line in the format above, and
   there are exactly `<n>` of them — or, when `<n>` is `0`, the single body line
   `NO FINDINGS`. No blank lines, headings, prose, or wrapped continuations: a file may
   contain findings *and nothing else*, because "n valid lines somewhere in the file"
   would accept a truncated file padded with fragments;
4. for a `reviewType: full` Gate-B pass, **both** branch files satisfy 1–3.

Anything else — missing, unreadable, or empty file; wrong path; absent or malformed
terminator; count mismatch; extra lines; only one of two Gate-B branch files; an
`INCOMPLETE` reply — is an **INCOMPLETE pass**. An incomplete pass is not a review: do
not act on the partial list, do not count it toward the 3-pass floor, and do not read
"no Blocker/Major visible" as clean.

**Recovery: one attempt per pass, covering every cause together** — timeout, an
`INCOMPLETE` reply, and any failure of checks 1–4 draw on the same single budget, so a
timeout that is retried and then returns a bad file has spent it. This is the existing
§5 Mechanics timeout-retry rule, widened to the new failure modes rather than added
alongside it; two separate budgets would let a pass alternate between them indefinitely.

That Mechanics bullet is rewritten in the same change, because its old wording ("an
aborted call loses nothing") contradicts all of this: an abort is an incomplete pass, it
may already have moved the counter, and it may have left a partial target file. What
persists in `.context/` is counter and workspace state — not the pass.

The recovery attempt is **a fresh re-run** of the call. Delete exactly what the re-run
will rewrite: a fresh `full` Gate-B re-run rewrites both branch files, so delete both; a
single-branch resume rewrites only that branch, so delete only that branch's invalid
file and **keep the sibling that already validated** — deleting both and recreating one
guarantees check 4 fails, spending the only attempt on a path that cannot succeed.

Resuming the session is worth preferring in one case only: the reply shows the review
itself ran and only the write failed. Then pass the `sessionId` from the original tool
result back to `mcp__codex__exec` / `mcp__codex__review`. For a `full` Gate-B pass the
two branches resume separately and **the branch's `reviewType` must be passed with its
session id** — `reviewType: spec` with `specSessionId`, `reviewType: quality` with
`qualitySessionId`. The tool defaults `reviewType` to `full`, so a resume that omits it
can run a different reviewer than the branch you meant to recover and write the wrong
slot, which check 4 cannot detect: the file would be well-formed, just from the wrong
reviewer.

State plainly what is not established: whether a resumed session re-executes the
file-writing instruction or merely returns its prior summary. If it returns the summary,
that is the spent attempt — which is why a fresh re-run is the default.
`mcp__codex__session_list` is a debugging aid for a human hunting a lost session, not
part of this path; it defaults to `status: active` while a session that returned
normally is already `completed`, and it offers no way to tell which of several completed
sessions was the one you want.

Attempt spent and still incomplete → STOP and surface to the user, naming which of
checks 1–4 failed.

### What this does NOT do (stated so nobody mistakes it for a guard)

- **The hook still counts an incomplete pass — specifically the incomplete passes this
  protocol is about.** Counters increment in the hook's `PostToolUse` branch
  (`codex-gate.sh:361`), keyed on tool name; the hook never sees the response, let alone
  the file. Claude Code fires `PostToolUse` after a tool call *succeeds* and routes a
  failed call to `PostToolUseFailure`, for which `hooks/hooks.json` registers no handler.
  **That does not mean failed reviews escape counting.** Verified in the pinned server's
  source (`mcp-codex-dev@1.0.1`, `dist/tools/codex-review.js` and `codex-exec.js`): it
  catches its own exceptions — executor timeouts and aborts among them — and *returns*
  `{success: false, …}` as a normal result, without throwing and without setting
  `isError`. Claude Code therefore sees a successful tool call, `PostToolUse` fires, and
  the counter moves. A call that returns and then fails validation increments too.

  So the rule is stated without reference to event routing: **discount every incomplete
  pass regardless of what the counter says.** A "satisfied" count can overstate the
  passes you actually hold; discounting is yours to apply — the same instruction-backed
  gap §5 already names for Gate A. An earlier revision of this spec claimed errors and
  timeouts "increment nothing", inferred from the documented event split without reading
  the server; Gate B caught it. The lesson is this repo's own Don't: a mechanism
  documented one layer up does not tell you what the layer beneath actually does.
- **Nothing checks the terminator mechanically.** No script, no hook, no CI step. The
  protocol is instruction-backed by design (scope guard on this hardening: prompts and
  templates only). Whether that suffices is measured by whether truncation incidents
  recur — a recurrence is the trigger to escalate a rung, not a reason to build the
  checker now.
- **Detection is conditional, not total.** Checks 1–4 catch an absent or malformed
  terminator, a count mismatch, and a missing branch file *in the artifact the reader
  actually reads*. They do not catch a model that writes a wrong count with a matching
  number of lines, and they do not catch a stale prior-attempt file if the pre-call
  delete is skipped. The observed failure — output cut off mid-list — is inside that
  coverage; model dishonesty is not.

### Why `.context/codex-reviews/`

With the current `tree_hash()` (0.5.0, `plugins/dev-workflow/hooks/codex-gate.sh`),
changes confined to `.context/` change none of its three fingerprint inputs — verified
in the source: `git diff HEAD -- . ':(exclude).context'`,
`git rm -rfq --cached … -- .context` before the index-tree `write-tree`, and
`git add -A -- . ':(exclude).context'` before the worktree-tree `write-tree`. So under
that version, writing review artifacts there does not move the Gate-B fingerprint. The
claim is about those three inputs at that version — nothing more.

Ignore `.context/codex-reviews/` specifically, **not** all of `.context/`:
`/workflow-init` writes `.context/codex-gate.on` as the adoption marker and says to
commit it, so a blanket ignore would strip adoption from fresh clones. The exact entry
is the root-anchored `/.context/codex-reviews/`.

`/workflow-init` writes no `.gitignore` today, and this change does not add that step —
scaffolding a new file is more than a prompt edit, and an unignored review directory
costs a noisy `git status`, nothing more. The template therefore *recommends* the entry
in prose. Should a later change scaffold it, invariant 9 applies: merge additively,
never overwrite. The hook's `.context/` exclusion above is independent of `.gitignore`
either way, which is why Gate-B validity does not depend on this paragraph.

## Secondary mitigation (not the fix)

README, Codex prerequisites: name `MAX_MCP_OUTPUT_TOKENS` and the 25,000-token default.
Raising it moves the ceiling; it does not remove it — and it moves it only for tools
that do not declare their own text limit. A tool setting
`_meta["anthropic/maxResultSizeChars"]` uses that value for text content regardless of
the environment variable (image output stays subject to it). Whether the pinned
`mcp-codex-dev@1.0.1` declares the annotation is **not established here**, so the README
must not promise the variable will help — it is a knob worth trying, and the file
protocol is the fix.

## Fingerprint

**Minted: `truncated-tool-output-read-as-complete`** — a tool result that arrived
incomplete is consumed as if whole, because nothing in it distinguishes the two.

Reusing `verification-masks-failure` was tried first and abandoned. It is the nearest
existing class, and the surface shapes rhyme — a signal read as a pass that cannot
distinguish success from failure. But the two differ in origin and in fix: there, an
author wrote a check that reported the wrong thing (a pipe returning grep's status), and
the fix is to make the check report the real status; here, the author's reasoning is
sound and the *delivery* silently drops data, so the fix is to make incompleteness
detectable. That difference is what the taxonomy's existing "not the same as" paragraphs
exist to record.

The deciding evidence was mechanical: forcing this into `verification-masks-failure`
makes it a recurrence on a `1 prose` row, and the skill's recurrence rule then demands
either a mechanical rung (out of scope here) or sharpened `AGENTS.md` wording with the
absence of a deterministic rung recorded. Rung P is neither. Three review passes each
rejected a different attempt to narrate that gap — the class was being bent to fit the
ladder rather than the defect.

As a new class, no recurrence rule applies and **rung P is simply the fitting rung**:
the defect is in prompt artifacts (the gate prompts and the scaffolded template), which
is what P is for. A mechanical rung would be stronger, and is deferred with a named
trigger rather than dismissed: deciding whether a tool response was complete needs a
checker, which this hardening's scope guard excludes — if incidents recur under this
protocol, that checker is the escalation.

Bookkeeping while in the taxonomy file: `verification-masks-failure` is used by the
2026-07-20 ledger row but was never defined there, and the new class's "not the same as"
paragraph points at it, so this change adds its definition too. (`false-negative-gate`,
used by the 2026-07-19 row, is undefined as well — noted, not fixed here.)

## Change list

| # | File | Change |
|---|---|---|
| 1 | `CLAUDE.md` §5 | protocol + reader obligation + does-NOT-do, in Gate A and Gate B |
| 2 | `plugins/dev-workflow/commands/workflow-init.md` (inline §5 template) | the same, phrased for a scaffolded project |
| 3 | `README.md` | `MAX_MCP_OUTPUT_TOKENS` as secondary mitigation |
| 4 | `docs/hardening-taxonomy.md` | define the minted `truncated-tool-output-read-as-complete` (aliases + the "not the same as" distinction), **and** the referenced-but-undefined `verification-masks-failure` |
| 5 | `docs/hardening-log.md` | one row |
| 6 | `plugins/dev-workflow/.claude-plugin/plugin.json` | 0.5.0 → 0.5.1 (invariant 12; the §5 template ships) |
| 7 | `plugins/dev-workflow/CHANGELOG.md` | 0.5.1 entry |

**The scope guard, stated precisely.** "Prompt/template changes only" bounds the
*mechanism*, not the bookkeeping: no executable machinery (no hook change, no new
script, no CI checker, no terminator-checking tool) and no newly scaffolded project
files. In scope alongside the two prompt sites (1, 2), each for its own reason rather
than one blanket one:

- **6, 7** (manifest version, changelog) — invariant 12 and release policy *require*
  these of any shipped-plugin change.
- **4, 5** (taxonomy, ledger) — required by the `harden-finding` flow being followed,
  which mints the class and appends the row in the same change.
- **3** (README) — neither: a design choice, the explicitly in-scope secondary
  mitigation.

Read literally as "only files that are prompts", the guard would forbid the version bump
invariant 12 mandates, which is not what it means.

## Invariants touched

- **11** (prompt changes pass `docs/prompt-standards.md`) — items 1–12 on the new text;
  items 3 (stop conditions), 4 (output format with an example), 10 (diagnostic states
  name their causes) and 11 (enforcement claims name their mechanism) are the ones this
  protocol most directly exercises.
- **12** (plugin change requires a version bump) — 0.5.1.
- **8** (`/workflow-init` templates stay inline) — the change is inside the inline body.
- **3** (Gate-B validity is content-derived) — relied upon, not modified; the
  `.context/` exclusion is what makes the file location safe.
