# Compact planning, Gate A, task context and handover — Implementation Plan

**Story:** `docs/superpowers/stories/2026-10-06-compact-planning-context-handover-story.md` (read its profile fresh)
**Spec:** `docs/superpowers/specs/2026-10-06-compact-planning-context-handover-design.md`

**Plan form.** Compact, per Daniel's instruction for this assignment, which outranks
`writing-plans` where they differ: each task states its outcome, files and reuse,
prerequisites and settled decisions, test situations with expected outcomes, and the
implementer's decision space. No replacement prompt text, function bodies or complete test
code. Execution: Native (this session).

**Sources and impact boundary.** Read: the story and spec; `CLAUDE.md`; `AGENTS.md`
(invariants 8, 9, 11, 12, Don'ts); `.claude/review-gates.md` (Gate-A bullet, membership
test, Optional companions); `plugins/dev-workflow/commands/workflow-init.md` (Rules, `### 2.1`,
the Gate-A bullet in `### 2.1a`); `docs/coding-workflow.md`, `docs/getting-started.md`;
`todos.md` (G3, Tooling revalidation, the follow-up rows); `docs/prompt-standards.md`;
the installed `writing-plans` 6.4.1; the three projects' `CLAUDE.md` §4/§5 and gate-rule
locations. Impact ends at: the kit's own instruction copies, its two docs, `todos.md`, the
plugin manifest and CHANGELOG, a new replay package, and untracked adoption files in three
projects' `.context/`. Not touched: hooks, scripts, other skills and commands, tracked files
in the three projects.

**Handover boundary.** The merged PR (completed story). If the session must end earlier,
the closed Gate-A plan cycle is the boundary; handover in `.context/handover-g3-first.md`.

## Global constraints

- Plugin version 0.18.0; CHANGELOG entry; invariant 12.
- `CLAUDE.md` template ≤ 20,000 characters (check 4e).
- `docs/prompt-standards.md`, all 12 items, for every changed prompt text (invariant 11).
- Gate rules: only the Gate-A bullet's review question changes (AC-5).
- No edit to another plugin's cache; no tracked-file edit in SFX, canvas or
  `sfx-bricks-api-builder`; running review cycles keep their rules.
- No model names, effort levels, context sizes or loading mechanisms in the added rules
  (AC-19). Client and skill facts are recorded as the current implementation, and a change
  re-checks only the assumptions it affects (Daniel, 12:37).

## Review focus

1. A project whose `CLAUDE.md` lacks the subsection keeps today's behaviour → adoption guide (T5, T6).
2. A handover boundary reached while a cycle is interrupted → resume rules win (T1 wording).
3. A task with no plan (review, investigation) → note goes in its work record (T1).
4. Two parallel units → separate handover files (T1).
5. A project with its own plan-form rule (SFX's pilot instruction) → adoption replaces, never duplicates (T6).

---

### T1 — Working contract in both `CLAUDE.md` surfaces

**Outcome:** one subsection under §4 carrying spec §2 items 1–7, identical in the template
(`workflow-init.md` `### 2.1`) and in this repo's `CLAUDE.md` §4.
**Files:** `plugins/dev-workflow/commands/workflow-init.md`, `CLAUDE.md`.
**Settled:** placement (spec §1); content (spec §2); the precedence sentence names
`writing-plans` without a version; the client fact goes to T4, not here.
**Decision space:** heading and wording; order of items; how compact the examples are.
**Test situations:**
- check 4e passes; record the template's character count before and after.
- The subsection extracted from both files is byte-identical (diff prints nothing).
- `grep -niE 'opus|sonnet|haiku|fable|gpt|token|effort level|context (size|window)|percent'`
  over the subsection finds nothing.
- Read-through against spec §2: each item present, including the interrupted-cycle, no-plan
  and parallel-unit cases (review focus 2–4).
- Failure: over budget → shorten, do not move rules out.

### T2 — Gate-A review question in both gate-rule copies

**Outcome:** spec §3 in the "Gate A — Spec, then plan" bullet of `.claude/review-gates.md`
and of the `### 2.1a` template.
**Files:** `.claude/review-gates.md`, `plugins/dev-workflow/commands/workflow-init.md`.
**Settled:** the broad prompt, every-finding coverage and "coverage floor, not a cage" stay.
**Decision space:** wording and where in the bullet.
**Test situations:**
- `git diff` of both files shows hunks only inside that bullet.
- The bullet text differs between the two copies only where it differed before (compare
  pre-change difference with post-change difference).
- `sh scripts/check-invariants.test.sh && sh scripts/check-invariants.sh` green.

### T3 — Docs that describe plan contents

**Outcome:** `docs/coding-workflow.md` (stage 4 "Planning", stage 6 "followed literally",
"mechanical") and `docs/getting-started.md` step 4 describe the new plan contract and local
decision space; any other plan-content description found by grep updated or left with a
reason.
**Files:** those two docs; others only if grep finds them.
**Test situations:** `grep -rniE 'followed literally|execution mechanical|code block'
docs/coding-workflow.md docs/getting-started.md README.md` shows no stale claim; the
AGENTS.md overclaim recipe adds no hit from changed lines.

### T4 — Backlog: revalidation line, G3 regrouping, P5b, follow-up order

**Outcome:** (a) `todos.md` § Tooling revalidation gains one line: the current client loads
`CLAUDE.md` at session start (checked with Claude Code 2.1.291) and `writing-plans` 6.4.1
asks for code in plans; on a model, client or skill change only the affected assumption is
re-checked (AC-19). (b) G3 states the new bundling with a fate per earlier condition, P5b's
state and the SFX boundary at G3a (AC-13, AC-14). (c) The follow-up order of spec §7.
**Files:** `todos.md`.
**Prerequisite:** enumerate G3's conditions from `git show main:todos.md` before editing.
**Test situations:** every enumerated condition has a fate row; `grep -c` of each follow-up
row's heading is 1 (no duplicates); the earlier evidence lines stay intact.

### T5 — Version, CHANGELOG and adoption guide

**Outcome:** manifest 0.18.0; CHANGELOG 0.18.0 entry stating what changed and an insertion
guide: where the subsection goes, which local rule it replaces, where the Gate-A question
goes (file or inline §5), apply at a completed boundary, running cycles keep their rules,
record the first unit under the new rules.
**Files:** `plugins/dev-workflow/.claude-plugin/plugin.json`, `plugins/dev-workflow/CHANGELOG.md`.
**Test situations:** `claude plugin validate . --strict`; after commit
`sh scripts/check-version-bump.sh main` passes.

### T6 — Adoption: verified once, prepared for three projects

**Outcome:** the guide applied to scratch copies of SFX's `CLAUDE.md` and
`.claude/review-gates.md` (scratchpad); then one prepared file per project,
`.context/adopt-dev-workflow-0.18.0.md` in SFX, canvas and `sfx-bricks-api-builder`, built
from each project's current text (canvas and bricks: Gate-A bullet inline in `CLAUDE.md` §5,
older "3-pass loop" wording kept), with status and "first unit: pending".
**Prerequisite:** T1, T2, T5.
**Settled:** nothing tracked in those repos is edited; SFX waits for P5b's close.
**Test situations:**
- Scratch result: the subsection appears once; diff against the original shows only the
  insertion and the Gate-A question; no competing plan-form rule (grep the copies for
  `full code|code blocks|function bod`).
- Each prepared file names its insertion points by heading, not line number.

### T7 — Evidence replay (AC-12)

**Outcome:** `docs/superpowers/replays/2026-10-06-compact-planning/` with README (setup,
isolation, limits), task brief and inputs (the PR #47 todo, the intake skill's amendment
section), rubric, removal spec, both outputs, both review results and `compare.md`.
**Prerequisite:** T1 (the new `CLAUDE.md`).
**Order, settled:** (1) commit rubric and removal spec before any run; (2) probe isolation:
a `claude -p` with `--plugin-dir` on superpowers 6.4.1, `--setting-sources project`,
`--strict-mcp-config`, in a fixture directory, must show `writing-plans` available and no
dev-workflow, memory or other plugin context; (3) one run per variant, fixtures identical
except `CLAUDE.md` (old = main's, new = T1's); (4) score with the rubric; (5) review check
via `mcp__codex__exec` only if the preconditions in spec §6 hold, the degraded plan verified
by diff.
**Decision space:** fixture layout, prompt wording (identical in both runs), how the probe
shows its context.
**Test situations:** "no observed difference" is recorded as such; a failed precondition
marks that part of AC-12 unmet; no run is repeated to obtain another result.

### T8 — Battery, Gate B, PR

**Outcome:** quality battery green; Gate B (spec and quality as two sequential calls on the
same base and head) closed; PR opened, bots processed, merged.
**Evidence entry (battery+check):** the named verification is T7's old-vs-new comparison;
its counterfactual is the old-instruction run.
