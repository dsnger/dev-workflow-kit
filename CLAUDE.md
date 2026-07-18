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
  invalidates the prior pass, which is where the 3 come from. Same coverage rule
  as Gate A: put "report every finding with severity and confidence; say
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
- **Timeout retry:** a codex call that dies at the MCP tool-call timeout is retried
  once before surfacing to the user — pass state persists in `.context/`, so an
  aborted call loses nothing.

---

**These guidelines are working if:** fewer unnecessary changes in diffs, fewer rewrites due to overcomplication, and clarifying questions come before implementation rather than after mistakes.

---

Project architecture, stack-specific patterns, and invariants live in @AGENTS.md
(single source of truth — also read directly by Codex and the PR review bots). The
Cross-Model Review gates (§5) check against the invariants there.
