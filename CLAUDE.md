# dev-workflow-kit

**Tradeoff:** These guidelines bias toward caution over speed. For trivial tasks, use judgment.

## 1. Think Before Coding

**Don't assume. Don't hide confusion. Surface tradeoffs.**

Before implementing:
- State your assumptions explicitly. If uncertain, ask.
- If multiple interpretations exist, present them - don't pick silently.
- If a simpler approach exists, say so. Push back when warranted.
- If something is unclear, stop. Name what's confusing. Ask.

## 2. Simplicity First

**Minimum code that solves the problem. Nothing speculative.**

- No features beyond what was asked.
- No abstractions for single-use code.
- No "flexibility" or "configurability" that wasn't requested.
- No error handling for impossible scenarios.
- If you write 200 lines and it could be 50, rewrite it.

Ask yourself: "Would a senior engineer say this is overcomplicated?" If yes, simplify.

## 3. Surgical Changes

**Touch only what you must. Clean up only your own mess.**

When editing existing code:
- Don't "improve" adjacent code, comments, or formatting.
- Don't refactor things that aren't broken.
- Match existing style, even if you'd do it differently.
- If you notice unrelated dead code, mention it - don't delete it.

When your changes create orphans:
- Remove imports/variables/functions that YOUR changes made unused.
- Don't remove pre-existing dead code unless asked.

The test: Every changed line should trace directly to the user's request.

## 4. Goal-Driven Execution

**Define success criteria. Loop until verified.**

Transform tasks into verifiable goals:
- "Add validation" → "Write tests for invalid inputs, then make them pass"
- "Fix the bug" → "Write a test that reproduces it, then make it pass"
- "Refactor X" → "Ensure tests pass before and after"

For multi-step tasks, state a brief plan:
```
1. [Step] → verify: [check]
2. [Step] → verify: [check]
3. [Step] → verify: [check]
```

Strong success criteria let you loop independently. Weak criteria ("make it work") require constant clarification.

Ground progress claims: before reporting a step as done, audit the claim against a tool result from this session ("tests green" needs a test run to point to). Report unverified work as unverified — this keeps status reports factual on long runs.

The work loop includes the review gates: **spec ready → Gate A (spec) → plan ready → Gate A (plan) → execute → tests green → Gate B → commit** (see §5).

## 5. Cross-Model Review (Codex) — TWO MANDATORY GATES

Independent second opinion at two gates. Easiest steps to skip, so the discipline is
yours — a non-blocking hook (shipped by the `dev-workflow` plugin) reminds you at
each. Opt out per-workspace with `.context/codex-gate.off` (delete to re-enable); the
gates still apply.

**Both gates are a LOOP with a HARD FLOOR: min 3 passes per run (Blocker/Major
only), counted by the hook.** The hook counts passes but can't read findings or
tell the spec run from the plan run (it resets at `writing-plans`), so Gate A —
the spec run especially — is instruction-backed: a satisfied count is not a clean
review. Open a TodoWrite "Codex pass N" per pass; fix Blocker/Major after each. Your
final pass must be clean — if pass 3 still finds Blocker/Major, keep going until
clean or clearly stuck → then STOP and surface to the user. The only early exit
below 3 is a pass with **zero** findings; don't manufacture findings to pad. Codex is
advisory — validate before applying; dismissed finding → one-line why.

**Findings go to a FILE, not the response — both gates.** In the field, long finding
lists came back cut off on effectively every substantial Gate A pass, and a cut that
lands between findings is indistinguishable from a short list: silently dropped
findings, the dangerous direction. Claude Code both limits MCP tool output (25,000
tokens by default, `MAX_MCP_OUTPUT_TOKENS`) and persists over-threshold results to disk
behind a file reference; which one produced the field loss is not established, and the
protocol is correct either way, because the response stops carrying the findings at all.
Append to the gate prompt:

> Pass the reviewed repo root as `workingDirectory`. Write the FULL findings list to
> `.context/codex-reviews/<slot>.md` (create the directory if needed; the path is
> relative to that root — Codex resolves writes against its working directory, so
> without this a valid file can land in a different checkout). `<slot>` is
> `gate-a-spec-pass-<p>`, `gate-a-plan-pass-<p>`, or `gate-b-<spec|quality>-pass-<p>`.
>
> One finding per line in the format above; escape a literal pipe inside a field as
> `\|`. Every line before the terminator is exactly one finding line — no blank lines,
> headings, prose or wrapped continuations. End the file with a final line reading
> exactly `END OF FINDINGS (<n> total)`, `<n>` being the number of finding lines. A
> clean pass is the single body line `NO FINDINGS` with `END OF FINDINGS (0 total)`.
>
> Then reply with ONLY one line per branch — `<gate> | pass <p> | <n> findings | <path>`
> — or `INCOMPLETE | <cause> | <path>` if you could not write the file. An unwritten
> file behind a normal-looking reply is the one outcome the reader cannot diagnose.

**Gate B takes one file per branch** because `reviewType: full` runs the spec and
quality reviewers in parallel from one `additionalContext`. Aimed at a single path they
race, and the second writer leaves a correctly terminated, correctly counted file
holding half the findings — with every check still passing.

**Before each call, delete every target file and confirm it is gone.** A call that dies
part-way leaves the prior attempt's valid file behind, and no terminator can tell that
from a fresh one. If a target survives deletion, stop and name the cause — path resolved
against the wrong root, permissions, a *directory* at the target, or a file reappearing
(another writer) each need a different fix, and "delete failed" alone sends you retrying
the delete. Run one pass at a time: the slot name has no invocation-unique component, so
two concurrent calls on one slot race. Passes are sequential by construction, so that is
a stated limitation, not a guarded one.

**Accept a pass only when** the file exists and is readable; its last line is exactly
`END OF FINDINGS (<n> total)`; it contains exactly `<n>` finding lines *and nothing
else* (or the single line `NO FINDINGS` when `<n>` is 0 — "n valid lines somewhere in
the file" would accept a truncated file padded with fragments); and, for a `full` Gate-B
pass, both branch files satisfy all of that. Anything else — missing, unreadable or
empty file, wrong path, malformed terminator, count mismatch, extra lines, one branch
file, an `INCOMPLETE` reply — is an **INCOMPLETE pass**, which is not a review: don't
act on the partial list, don't count it toward the 3-pass floor, and don't read "no
Blocker/Major visible" as clean.

**Recovery: one attempt per pass**, shared across timeout, an `INCOMPLETE` reply and
failed validation — the Mechanics timeout-retry rule widened, not a second budget beside
it, since two budgets let a pass alternate between them indefinitely. The attempt is a
fresh re-run, deleting exactly what it will rewrite: both branch files for a full
re-run, only the failed branch for a single-branch resume — deleting both and recreating
one makes the both-files check fail by construction, spending the attempt on a path that
cannot succeed. Prefer a resume only when the reply shows the review ran and just the
write failed: pass the `sessionId` from the original tool result back, and for a Gate-B
branch pass its `reviewType` alongside (`spec` with `specSessionId`, `quality` with
`qualitySessionId`) — the tool defaults to `full`, and a resume that omits it can run the
other reviewer and write the wrong slot, which no check detects, because the file is
well-formed and merely from the wrong branch. Whether a resumed session re-executes the
write or just returns its prior summary is not established; if it returns the summary,
that was the attempt. Spent and still incomplete → STOP and surface, naming which check
failed.

**What this does not do.** The hook counts on `PostToolUse`, keyed on tool name, and
never sees the file. Claude Code fires `PostToolUse` after a *successful* call and routes
a failed one to `PostToolUseFailure`, which the plugin registers no handler for — but do
not infer from that which failures escape counting: the pinned `mcp-codex-dev` catches
its own errors, executor timeouts and aborts included, and returns them as a normal
result carrying `success: false` rather than throwing or setting `isError`
(`dist/tools/codex-review.js`). A failed review therefore looks like a successful tool
call and increments the counter. So does a call that returns and then fails validation.
The rule that follows is the simple one: **discount every incomplete pass regardless of
what the counter says** — a "satisfied" count can overstate the passes you actually hold,
and reasoning about which failure took which event path will get it wrong. Nothing checks the terminator mechanically; this is
instruction-backed by design, and a recurring truncation incident is the trigger to build
the checker, not a reason to build it now. Detection is conditional: it catches an absent
or malformed terminator, a count mismatch and a missing branch file *in the artifact you
actually read*; it does not catch a model that writes a wrong count with a matching
number of lines, nor a stale file if you skip the delete.

**Why `.context/codex-reviews/`:** with the current `tree_hash()`, changes confined to
`.context/` move none of its three fingerprint inputs, so review artifacts cannot
invalidate the review they document. Ignore `/.context/codex-reviews/` specifically —
not all of `.context/`, which would strip the committed `codex-gate.on` adoption marker.

- **Gate A — Spec, then plan (TWO runs, each its own 3-pass loop).** Run on the
  **spec** right after brainstorming (before `writing-plans`), then on the
  **plan** before `executing-plans`/`subagent-driven-development` — catching a
  spec flaw before it's baked into the plan. Tool: `mcp__codex__exec` (raw;
  reviews the TEXT you pass, not the git tree). Use ONE broad prompt, re-run it
  each pass over the revised artifact (don't narrow per-dimension; new findings
  surface because the artifact changes between passes). The prompt MUST open with
  *"Use the superpowers:brainstorming skill to review this spec,"* (say "plan" on
  the plan run), then ask Codex to check it against our settled decisions and
  surface **contradictions/inconsistencies, missing requirements, unhandled
  state/edge/error/empty/concurrent paths, and risks to the Key Invariants
  (@AGENTS.md) — plus anything else** (coverage floor, not a cage). Append the
  intent + artifact text + which invariants it touches. Ask for **every** finding
  with severity and confidence — you filter to Blocker/Major downstream, Codex
  never does, because a model told to report only high severity drops real
  findings silently (`docs/prompt-standards.md`, "coverage first, filter later").
  Ask for one line per finding and a literal `NO FINDINGS` when a pass is clean —
  the explicit clean signal is what lets you exit the loop:

  ```
  MAJOR | high | §3 "Retry policy" | retry count unbounded | a poisoned job loops forever | cap at 5, then dead-letter
  NO FINDINGS
  ```

  Each pass: validate, revise, re-run. (Large/high-risk artifact: optional focused
  per-dimension passes on top.)
- **Gate B — Code.** Tests green, before `git commit`. Tool: `mcp__codex__review`
  (args `instruction`, `whatWasImplemented`, `baseSha`; `reviewType: full` runs
  spec + quality in parallel). Skip ONLY trivial changes. Check against
  @AGENTS.md. Re-review after every fix — a fix changes the diff and the hook
  invalidates the prior pass, which is where the 3 come from.

  **A fix that changes specified behaviour updates the spec in the same commit.** If a
  Gate-B fix alters something the approved spec pins down — an ordering, a terminal
  state, a contract — the spec is stale the moment you commit, and the next reader
  trusts it. Update both, and let the re-review cover both. This is not hypothetical:
  a Gate-B fix here reordered a precedence rule and added a terminal state, the spec
  was left describing the old behaviour, and a PR bot found the disagreement after
  merge-readiness. Neither gate caught it *in that run*: Gate A had already passed the
  spec before the fix existed, and the Gate-B call was given only the diff. A reviewer
  handed both artifacts could catch it — which is why this is a rule about what you
  commit, not a claim about what the gates detect.

  Same coverage rule as Gate A: put "report every finding with severity and confidence; say
  `NO FINDINGS` if clean" in `additionalContext`, with the same one-line format.
  You filter to Blocker/Major, Codex never does.

  **What counts as prose (the only Gate-B exemption).** Every staged path is
  explanatory documentation — `docs/**.md`, `README.md`, `MANIFEST.md` → N/A.
  These describe the product rather than being it, so a wrong sentence costs a
  confused reader, not broken behaviour; that is why they carry no gate at all,
  not because some earlier gate covered them (Gate A runs on specs and plans,
  which a README edit doesn't have). **Prompts are not prose:** `CLAUDE.md` and
  `AGENTS.md` themselves, and anything under a `.claude/`, `plugins/`, `skills/` or
  `commands/` directory **at any depth** — skills, commands, agent definitions, hook
  reminder text, inline templates — are the product (@AGENTS.md, "What this project is"), so they
  fire full Gate B even though they are `.md`. So does any mixed commit, and any
  non-`.md` file. The hook classifies paths the same way, matching those directory
  names at any depth on purpose: root-level `skills/` and a monorepo's
  `packages/*/.claude/` are both real layouts, and missing one would be a false
  "N/A" — the dangerous direction. The price is that prose under a directory that
  merely shares the name (`docs/commands/reference.md`) fires too, which is the
  redundant reminder invariant 2 accepts by name.

### Mechanics (reference)
- **Severity:** Blocker (wrong/unsafe/breaks invariant) · Major (design flaw →
  rework) → both must resolve. Minor · Nit → collect, never iterate.
- **Tool routing:** docs (spec/plan, incl. code snippets) → `mcp__codex__exec`;
  implemented diff → `mcp__codex__review`. Never `review` a doc — it reads the
  git range, not the text.
- **`baseSha`:** against main = merge-base with main (`headSha` = HEAD);
  pre-commit, `baseSha` = HEAD is an empty range (HEAD..HEAD) — make a WIP commit
  and set `baseSha` to its parent. **Name that commit `WIP: …`** — the hook treats a
  `wip`-prefixed commit message as cycle-internal, so it neither fires a Gate-B STOP
  nor resets your pass counters. A pre-review snapshot named anything else reads as a
  real commit and closes the cycle, discarding the passes you just accumulated.
  **Finishing the cycle:** after the final clean pass, close it with
  `git commit --amend -m "<real message>"` — that replaces the WIP commit, and the hook
  reads the amend as the real cycle-closing commit. If several WIP snapshots piled up,
  `git reset --soft <parent-of-first-WIP>` first, then commit once. Amend rather than a
  follow-up commit for two reasons: a `WIP: …` commit left in history defeats the naming
  convention it exists for, and a follow-up commit has nothing to commit when the review
  produced no fixes.
- **Timeout / abort:** a codex call that dies at the MCP tool-call timeout is retried
  once before surfacing to the user, and that retry *is* the single shared recovery
  attempt above — not a second one. An abort is an incomplete pass, so treat it as one:
  it may already have moved the hook's counter (the pinned server returns its own
  timeouts as ordinary results), and it may have left a partial or stale target file, so
  delete the targets and confirm them gone before retrying, then validate the result like
  any other pass. Counter and workspace state persist in `.context/`; the *pass* does
  not.

---

**These guidelines are working if:** fewer unnecessary changes in diffs, fewer rewrites due to overcomplication, and clarifying questions come before implementation rather than after mistakes.

---

Project architecture, stack-specific patterns, and invariants live in @AGENTS.md
(single source of truth — also read directly by Codex and the PR review bots). The
Cross-Model Review gates (§5) check against the invariants there.
