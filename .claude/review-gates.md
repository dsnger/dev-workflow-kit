# Cross-Model Review (Codex) — TWO MANDATORY GATES

Mode: `.claude/codex-gate.mode` holds `lean`, `strict` or `classic`; missing/unknown: `classic` (say so; fix it). A cycle keeps its pass-1 mode; a change names both in the closing body.
Gate A (`mcp__codex__exec`) reviews a spec in `classic` always, else only at risk `high` or security not `none`; a plan only at risk `high`. A spec carries `**Gate A:** runs | skipped — <profile line>`.
A spec is approved when its Gate A closes, or if skipped once committed (checkpoint `spec`: once the human approves); then it changes only by `intake`'s amendment route.
Gate B (`mcp__codex__review`) reviews every code diff once the quality command is green; only docs-only commits may skip it.
Docs-only: every staged path is explanatory Markdown under `docs/`, or `README.md`, `MANIFEST.md`, `todos.md`; `CLAUDE.md`, `AGENTS.md` and paths under `.claude/`, `plugins/`, `skills/` or `commands/` at any depth are prompts needing Gate B, as are mixed commits.

Before deciding Gate A or a small-change close, take one profile line, `risk standard|high; security none|standard|high; evidence <mode>`, from the cited story; with none, derive it as intake does and record why.
Evidence modes: `battery`, `battery+check`, or `battery+check+verification`, with `+abuse-path` for security `high`.
Map a free-text value to the nearest closed values, the stricter where two fit, and record mapping and quote.

## Gate-A prompt

Tool: `mcp__codex__exec` (reviews the TEXT you pass, not the git tree).
The prompt MUST open with
  *"Use the superpowers:brainstorming skill to review this spec,"* (say "plan" on the plan run), then ask Codex to check it against our settled decisions and surface **contradictions/inconsistencies, missing requirements, unhandled state/edge/error/empty/concurrent paths, and risks to the Key Invariants (@AGENTS.md) — plus anything else**.
Ask also: of a spec, whether its commitments are coherent, sufficiently decided and feasible; of a plan, whether implementation can proceed — adequate decisions and dependencies, realistic steps, meaningful verification, a clear line between local choices and decisions still owed.
Report missing code or tests only where their absence has a concrete consequence, and name it; review code a plan includes like other content.
A spec or plan that uses a library API without a named Context7 lookup (or CLAUDE.md's fallback) for the pinned version is a finding.
Append the intent + artifact text + which invariants it touches.
Ask for **every** finding with severity and confidence — **you filter to blocking findings for repair and read every line**; Codex never filters: told to report only high severity, models drop real ones.

Both gates, from pass 2 on: list each slot's earlier blocking findings with their verdict and reason; Codex marks each `fixed | not fixed | no longer applies` with its location, in its reply outside the finding lines.
Each `not fixed` becomes a finding line, except a `declined` or `accepted, not repaired` one Codex can back with no new evidence, so none drops unchecked and none settled is re-argued.
Both gates: Codex reports one cause seen at several places once, as a class listing every place, after looking for each finding's siblings.

## Gate-B prompt

Tool: `mcp__codex__review`.

**Default call shape: two sequential single-branch calls per pass**, `reviewType: spec` then `quality`, one `baseSha` and `headSha`, both full 40-character lowercase SHAs resolved before the first call (a WIP-parent `baseSha` too); each call's `additionalContext` names only its own slot.

In an open cycle the main session (the committer gets the note) makes each commit before the closing act as a Bash call of only `git commit -m 'WIP: <subject>'`, plain subject; the hook keeps the pass count only across a commit it sees as WIP (a subject ending `(WIP)` is not). The closing commit takes a non-WIP subject: stage, then one plain `git commit -F .context/<msg>`, the form the docs-only check reads (empty: `--allow-empty`).

Check against @AGENTS.md.

Same coverage rule as Gate A: put "report every finding with severity and confidence; write `NO FINDINGS` only when the branch found none" in `additionalContext`, with the same one-line format.
Unless `classic`, it also names this head's battery evidence (local run, or pending PR CI under the timeout rule): no finding for failures that run shows; whether checks cover what they claim stays in scope.

**Standing lens, every Gate-B call: "which existing statements does this diff falsify?"**
Codex forms 2–4 hypotheses of what could be wrong from the ACs and the diff before reading `whatWasImplemented`, and checks that summary as claims, not context, so it cannot steer.
In the `spec` call, Codex maps each AC to the test asserting it, or `none`, the same way; a test that cannot fail is a finding.

> One finding per line: `SEVERITY | confidence | location | problem | consequence | suggested fix`; escape a literal pipe as `\|`.
> Severity is one of exactly: BLOCKER | MAJOR | MINOR | NIT — no other token.
> Every line before the terminator is one finding line — no blank lines, headings, prose or wrapped continuations.
> The last line reads exactly `END OF FINDINGS (<n> total)`, `<n>` the number of finding lines.
> A **clean findings file** is the single body line `NO FINDINGS` with `END OF FINDINGS (0 total)`.

Choose a fresh cycle nonce, 8–16 lowercase letters or digits; write passes to `.context/codex-reviews/gate-<a|b>-<spec|plan|quality>-<nonce>-pass-<n>.md` (Gate A: spec or plan, Codex writing the prompt's `Findings file: <path>`; a reply alone is no pass; Gate B: spec and quality), a pass's dispositions to `…-pass-<n>-dispositions.md`.
For the provenance line, write a story set as `{docs/story.md (level 1)}` (standard = 1, high = 2), or `none` without a cited story; use `<quoted>` for paths needing quotes.
  <quoted>    := a double-quoted string, non-empty, whose only escapes are \" and \\ ;

Floor/cap, valid passes: `lean` A 2/2, B 1/3; `strict` A 2/2, B 1/5; `classic` 3/5. Stop before a further pass at the cap, or at the count plus extra passes last authorized.
`lean`/`strict`: blocking is a Blocker, a Major, or a Security-class or violated-AC (`AC-<n>`) finding of any severity; repair, rerun. Gate A pass 2 and `lean` Gate B from pass 2 verify each earlier blocking finding and what its fix touched (no repair: full reread; Gate B `baseSha` is the head last reviewed, unknown: full), collecting a new ordinary Major. `strict` Gate B passes are full.
Close at the first pass at or above the floor with no open blocking finding. At the cap a cut to an approved commitment, or an open Blocker, Security-class or violated-AC finding, goes to the human; else close, each open finding a `todos.md` row.
`classic`: blocking is a Blocker or Major; a pass with zero findings may close early, and Gate B on a small change closes at its first pass with no Blocker or Major.
Small change: risk `standard`, security `none`; ≤197 lines added+deleted outside files only tests use (`git diff --numstat` from a base before the whole change; binary, unmeasured or no such base: not small); no prompt path, migration, shared contract or path an AGENTS.md invariant names; the closing commit and any PR body say `small change: <n> lines, <base>..<head>`.
`classic` cap: a Blocker or a cut to an approved commitment goes to the human; else choose and record why: delete the mechanism findings keep returning to, cut scope, or continue; each names N ≥ 1 more passes and resumes the loop on the artifact as left.
Collect other findings; never iterate on them; a closing pass's stay unrepaired (`classic`: a small change's), as a later fix is unreviewed.
A timeout in an untouched test that passes alone is recorded with its evidence (load, solo run); the PR head's required check is then the battery evidence, without a stop. A red check stops.

## Closing act

A `classic` cap answer may instead be `close`; then, as at any close, run the closing act: one final commit with the cycle lines, applicable ledger records below, and a `todos.md` row per finding dispositioned `accepted, not repaired`; check distinct fixed findings against the hardening ledger, owing only lint (rung 2) or test (rung 4); a finding fitting neither owes no line. Unless `classic`, first move the cycle's `.context/codex-reviews/*-<nonce>-*` files to `.context/archive/codex-reviews/<nonce>/` (if one exists: stop, compare); its learnings are the owed `harden-finding` rows.
cycle <NONCE>; floor <the gate's floor> per <story paths with levels, or none>; hook reminder threshold <absent|positive integer|unusable>
cycle <NONCE>; <Gate-A spec|Gate-A plan|Gate B> (passes <ascending valid pass numbers>, <model>): Findings <per-pass counts>. Blockers <per-pass counts>. Majors <per-pass counts>. Declined <per-pass counts>.
Every slot of a validated pass that holds a finding owes a dispositions file, written before the next pass runs; each of its lines is `<n> | <verdict> | <reason>`, and `<verdict>` is one of exactly: `fixed` | `accepted, not repaired` | `declined` — no other token.
  cycle <NONCE>; ledger check: fixed <N>, hardening owed <M>
  cycle <NONCE>; hardening owed <SLOT>:<n> — <SEVERITY> — <CLASS> — <TARGET> — <DESCRIPTION>
  cycle <NONCE>; hardening <SLOT>:<n>: rung <RUNG>
  cycle <NONCE>; hardening <SLOT>:<n>: pending <REF>
  cycle <NONCE>; hardening <SLOT>:<n>: rung 0 — <CHECK>
  A `<TARGET>` containing ` — ` or a double quote is written as a `<quoted>` string, as the provenance line defines it, and a reader splits the fields on ` — ` only outside quotes.

To resume, continue from the cycle nonce and latest pass file (also in the archive); an incomplete pass counts for nothing.

Classify MAJOR only for realistic inputs.
When a finding class regenerates across passes, shrink the mechanism (platform parser, narrower scope, deletion) instead of another repair.
