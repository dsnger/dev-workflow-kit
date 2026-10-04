# dev-workflow-kit

**Tradeoff:** These guidelines bias toward caution over speed. For trivial tasks, use judgment.

## 1. Think Before Coding

**Don't assume. Don't hide confusion. Surface tradeoffs.**

Before implementing:
- State your assumptions explicitly. If uncertain, ask.
- If multiple interpretations exist, present them - don't pick silently.
- If a simpler approach exists, say so. Push back when warranted.
- If something is unclear, stop. Name what's confusing. Ask.

### Don't guess

Applies to factual claims in every answer, not only implementation. Confidence is not evidence.

**Leave gaps visible.** Do not invent missing or ambiguous facts. State what is unknown and why. In extraction
tasks, leave unsupported fields blank where the format permits; otherwise use the format's defined missing-value
handling.

**Separate evidence from inference.** Cite the relevant source for factual conclusions. Identify deductions and
assumptions as such, with their basis. For extraction tasks, label populated fields EXTRACTED or INFERRED and
explain each inference where the required output format permits. If neither annotations nor accompanying
explanations are permitted, preserve the required format. This does not permit inventing unsupported values.

**Keep decisions distinct from facts.** Make reasonable design and implementation choices within the authorized
scope, describing them as choices rather than source facts. Ask when missing information changes correctness or
scope.

**Verify before claiming.** Report a test or action as completed only when its result was observed. Preserve
required output formats; put explanations outside structured artifacts where permitted.

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

The work loop includes the review gates: **spec ready → Gate A (spec) → Gate-A closing act → plan ready → Gate A (plan) → Gate-A closing act → execute → tests green → Gate B → Gate-B closing act** (see §5, which states when each act may be performed and what it is).

## 5. Cross-Model Review (Codex) — TWO MANDATORY GATES

**The full rules live in `.claude/review-gates.md`. Read that file in full before any
work it governs: any Gate A or Gate B pass, resuming or closing a cycle, any commit,
preparing a merge, and deciding a change needs no gate.** Every reference to
§5 (its Mechanics, Profiles, closure ordering or gate prompt) means that file.

Why it is separate: inline, it pushed the instruction files past Claude Code's
150k-character limit. Why under `.claude/`: the gate hook treats that path as a prompt,
so editing the rules fires Gate B. Under `docs/` the edit would read as prose and get
no gate.

## 6. Context Canary

Begin every response to the user by addressing him as "Daniel."

**Why:** it is a context canary. These guidelines are only in force while this file is in
context, and nothing signals when it falls out. The address is a per-response marker: if
it disappears, CLAUDE.md is gone from context and the user knows to reload rather than
discovering it through work that quietly stopped following §1–§5.

**Scope: conversational responses only.** Never in file contents, commit messages, code,
or gate artifacts. §5's findings file admits no line that is not a finding line or the
terminator, and its reply is exactly one line per branch — a greeting there is a malformed
pass, so a canary that reached into artifacts would break the protocol it sits beside.

---

**These guidelines are working if:** fewer unnecessary changes in diffs, fewer rewrites due to overcomplication, and clarifying questions come before implementation rather than after mistakes.

---

Project architecture, stack-specific patterns, and invariants live in @AGENTS.md
(single source of truth — also read directly by Codex and the PR review bots). The
Cross-Model Review gates (§5) check against the invariants there.
