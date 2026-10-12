# Cross-Model Review (Codex) — TWO MANDATORY GATES

Gate A reviews every spec with `mcp__codex__exec`; a plan gets Gate A only when its human-confirmed risk is `high`.
Gate B reviews every code diff with `mcp__codex__review` after tests pass; only docs-only commits may skip it.
Docs-only means every staged path is explanatory Markdown under `docs/`, or `README.md`, `MANIFEST.md`, or `todos.md`; `CLAUDE.md`, `AGENTS.md`, and paths under `.claude/`, `plugins/`, `skills/`, or `commands/` at any depth are prompts and require Gate B, as do mixed commits.

Before Gate A, obtain human confirmation of one profile line: `risk standard|high; security none|standard|high; evidence <mode>`.
Evidence modes: `battery`, `battery+check`, or `battery+check+verification`, with `+abuse-path` for security `high`.

## Gate-A prompt

Use the superpowers:brainstorming skill to review this spec.
Check the supplied intent and artifact against settled decisions and the touched AGENTS.md invariants; report contradictions, missing requirements, unhandled state/edge/error/empty/concurrent paths, feasibility risks, and any other finding.
For a high-risk plan, review whether decisions, dependencies, steps and verification permit implementation.
Report every finding with severity and confidence to this pass’s file using the findings format below.

## Gate-B prompt

Tool: `mcp__codex__review`. **Default call shape: two sequential single-branch calls per pass**, `reviewType: spec` then `reviewType: quality`, with the same `baseSha` and `headSha`, both resolved to full 40-character lowercase object names before the first call — the WIP-parent `baseSha` included; each call's `additionalContext` names only its own slot.
For the spec branch: compare the diff with the supplied approved spec and plan; report every finding with severity and confidence, using the findings format below.
For the quality branch: compare the diff with AGENTS.md and ask which existing statements the diff falsifies; report every finding with severity and confidence, using the findings format below.

> One finding per line, in the format
> `SEVERITY | confidence | location | problem | consequence | suggested fix`; escape a literal pipe inside a field as
> `\|`.
> Severity is one of exactly: BLOCKER | MAJOR | MINOR | NIT — no other token.
> Every line before the terminator is exactly one finding line — no blank lines,
> headings, prose or wrapped continuations. End the file with a final line reading
> exactly `END OF FINDINGS (<n> total)`, `<n>` being the number of finding lines.
> A **clean findings file** is the single body line `NO FINDINGS` with `END OF FINDINGS (0 total)`.

Choose a fresh cycle nonce of 8–16 lowercase letters or digits; write passes to `.context/codex-reviews/gate-<a|b>-<spec|plan|quality>-<nonce>-pass-<n>.md` (Gate A: spec or plan; Gate B: spec and quality).
For the provenance line, write a story set as `{docs/story.md (level 1)}` (standard = 1, high = 2), or `none` when no story is cited; use `<quoted>` for paths needing quotes.
  <quoted>    := a double-quoted string, non-empty, whose only escapes are \" and \\ ;

The floor is 3 valid passes; repair Blockers/Majors and rerun within the cap, but a pass with zero findings may close early.
Collect Minors and Nits; never iterate on them.
Stop before a further pass at cap = floor + 2, or at the count plus the extra passes last authorized by the human.
It asks the user to choose — delete the mechanism the
findings keep returning to, cut scope, or continue — and every answer names how many further
passes it allows, at least one, and resumes the loop on the artifact as the answer leaves it.

## Closing act

A cap answer may instead be `close`; then, as for a clean pass (no Blocker or Major, at the floor unless zero findings), run the closing act: make one final commit carrying the cycle lines and applicable ledger records below; check distinct fixed findings against the hardening ledger, owing only lint (rung 2) or test (rung 4), and leave findings that fit neither as findings without an owed line.
cycle <NONCE>; floor 3 per <story paths with levels, or none>; hook reminder threshold <absent|positive integer|unusable>
cycle <NONCE>; <Gate-A spec|Gate-A plan|Gate B> (passes <ascending valid pass numbers>, <model>): Findings <per-pass counts>. Blockers <per-pass counts>. Majors <per-pass counts>.
Every slot of a validated pass that holds a finding owes a dispositions file, written before the next pass runs; each of its lines is `<n> | <verdict> | <reason>`, and `<verdict>` is one of exactly: `fixed` | `accepted, not repaired` | `declined` — no other token.
  cycle <NONCE>; ledger check: fixed <N>, hardening owed <M>
  cycle <NONCE>; hardening owed <SLOT>:<n> — <SEVERITY> — <CLASS> — <TARGET> — <DESCRIPTION>
  cycle <NONCE>; hardening <SLOT>:<n>: rung <RUNG>
  cycle <NONCE>; hardening <SLOT>:<n>: pending <REF>
  cycle <NONCE>; hardening <SLOT>:<n>: rung 0 — <CHECK>
  A `<TARGET>` containing ` — ` or a double quote is written as a `<quoted>` string, as the provenance line defines it, and a reader splits the fields on ` — ` only outside quotes.

To resume, read the cycle nonce and latest pass file and continue there; an incomplete pass counts for nothing.

Classify a finding as MAJOR only for realistic inputs.
When a finding class regenerates across passes, shrink the mechanism — use a platform parser, narrow scope, or delete it — instead of another repair.
