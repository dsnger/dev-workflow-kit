# Over-engineering check — Design

**Story:** `docs/superpowers/stories/2026-10-08-overengineering-check-story.md` — read its profile fresh at each pass.

**Date:** 2026-10-08 · **Decided with:** Daniel, brainstorming session 2026-10-08 (option 3; budget A; imports B; report location A)

## 1. Scope

This delivery answers the assignment with one inventory and one closed gap:

- **Inventory (story AC-1, AC-2, AC-3, AC-7, AC-8):** §3 and §4 below. Every candidate gap gets a fate.
- **Closed gap:** a size-regression check, `4g`, for this repository's own `CLAUDE.md` and `AGENTS.md` (§5). It is the only candidate examined that meets story AC-4: an observed instance plus a check that would fail without the change.
- **Report (story AC-9):** one short file, `docs/field-reports/2026-10-08-overengineering-check.md`, written after implementation (§6).

Out of scope: no change under `plugins/`, so no version bump (invariant 12) and nothing reaches initialized projects. No rule text is added to the gates, the skills or the templates. No general context scanner. No change to the review profile or to any gate. The arms-race and proportionality rows keep their stories and triggers unchanged.

What the delivery is: a guard against **this repository's** two instruction files growing past a fixed character budget again. What it is not: evidence of less complexity, less scope or less review effort. Story AC-9 already rules out a saving claim, and this design makes none.

## 2. Units, kept apart

| Quantity | Unit | Source |
|---|---|---|
| 4g's measurement | characters (`wc -m` under a UTF-8 locale), `CLAUDE.md` + `AGENTS.md` of this repo | §5 |
| Historical overrun at `b18e7db` | characters: `CLAUDE.md` 127,835 + `AGENTS.md` 23,411 = 151,246 (measured 2026-10-08 with `git show b18e7db:<file> \| LC_ALL=en_US.UTF-8 wc -m`); the vision's "151.2k" (`docs/superpowers/specs/2026-08-30-dark-factory-vision.md:586-587`) is the rounded form | |
| Current size at `a9743c4` | characters: `CLAUDE.md` 11,929 + `AGENTS.md` 26,523 = 38,452 | |
| `scripts/status-view.py` growth section | bytes and lines per file | `scripts/status-view.py`, `sec_growth` |
| canvas `AGENTS.md` | bytes: 126,332 (`docs/superpowers/stories/2026-10-06-living-feature-docs-pilot-story.md:11`) | |

A number in one unit is never compared with a budget in another.

## 3. What already counters over-engineering (story AC-1)

Enforcement: **I** instruction only · **R** judged by a reviewer · **M** a script fails the build. "Reaches projects": **scaffolded** = `/workflow-init` writes an equivalent copy into the project; **plugin skill** = the installed plugin supplies it, nothing is written into the project; **this repo** = applies here only.

| Phase | Existing rule | Where | Enf. | Reaches projects |
|---|---|---|---|---|
| spec writing | intake captures "WHAT and WHY, never HOW"; size calibration with `epic-needs-splitting` | `plugins/dev-workflow/skills/intake/SKILL.md:16`, `:194` | I | plugin skill |
| spec writing | the spec leaves internal implementation open | `CLAUDE.md:87` | I | scaffolded |
| spec writing | splitting by reviewable outcome; "File size is a warning signal" | `CLAUDE.md:108` | I | scaffolded |
| all phases | "If a simpler approach exists, say so." | `CLAUDE.md:12` | I | scaffolded |
| Gate A spec and plan | the reviewer asks whether commitments are "sufficiently decided and feasible", and reports missing code only where its absence "has a concrete consequence" | `.claude/review-gates.md:942`, `:945` | R | scaffolded |
| Gate A | "prefer smaller specs with named interfaces" (guidance, not a threshold) | `.claude/review-gates.md:661` | I | scaffolded |
| plan writing | the plan holds no function bodies or complete tests; "written and reviewed twice" | `CLAUDE.md:89`, `:91` | I | scaffolded |
| implementation | §2 Simplicity First: "No features beyond what was asked." | `CLAUDE.md:39`; template `plugins/dev-workflow/commands/workflow-init.md:415` | I | scaffolded |
| implementation | §3: "Every changed line should trace directly to the user's request." | `CLAUDE.md:61` | I | scaffolded |
| implementation (downstream) | dead-code and duplication checks named in the scaffolded CI battery, as a `TODO(stack)` | `plugins/dev-workflow/commands/workflow-init.md:2486-2487` | M once wired | scaffolded, as a TODO |
| Gate B | standing lens "which existing statements does this diff falsify?" | `.claude/review-gates.md:993` | R | scaffolded |
| Gate B | the pinned reviewer's own templates ask "Was anything over-engineered or unnecessarily added?" (spec branch) and "No scope creep?" (quality branch); `reviewType: full` runs both | `.mcp.json:6` pins `mcp-codex-dev@1.0.1`; its `templates/spec-reviewer.md:47-50`, `templates/code-reviewer.md:47` (outside this repo, in the installed package) | R | scaffolded (`/workflow-init` writes the same pin, `plugins/dev-workflow/commands/workflow-init.md:2392`) |
| review loop | Minor and Nit "buy no repair round"; scope stop: "size is not the test, novelty of the question is"; two tells make stop-and-surface mandatory | `.claude/review-gates.md:1184`, `:563`, `:637` | I | scaffolded |
| hardening | "not always the highest" rung; prefer existing rules over new dependencies | `plugins/dev-workflow/skills/harden-finding/SKILL.md:39`, `:86` | I | plugin skill |
| prompts | "Token-lean"; delete a claim at its fourth correction; test with instructions removed on a model upgrade | `docs/prompt-standards.md:56`, `:98`, `:127` | R | scaffolded |
| advice | "Prefer the smallest sufficient answer." | `plugins/dev-workflow/skills/sparring/SKILL.md:230` | I | plugin skill |
| size | 4e: 20,000-character budget for the scaffolded `CLAUDE.md` template; it does not check "this repository's own instruction files" | `scripts/check-invariants.sh:650-730`, `:666` | M | this repo (it guards the template) |
| effort | `loop-usefulness` warning light; "It does not say whether a loop was worth its effort" | `README.md:179` | report | this repo |

Phases with nothing found: no Gate A prompt question asks about unneeded scope (Gate B's does, through the pinned reviewer's templates above); `AGENTS.md`, which Gate B checks against, has no simplicity invariant; nothing in this repository fails the build on growth of its own instruction files.

## 4. Candidate gaps and their fates (story AC-2, AC-3, AC-7)

`todos.md` line numbers in this spec are as of `c9fce5e`; later notes move them, so each row is also named. Each candidate is judged on story AC-4 (an observed instance it would have prevented or caught, plus a check that fails without it) and on cost or redundancy. A missing comparison group is not a criterion (story AC-9).

| Candidate | Observed instance | Check failing without it | Fate |
|---|---|---|---|
| Size-regression check for this repo's `CLAUDE.md` + `AGENTS.md` | `b18e7db`: 151,246 characters, over the 150,000 the client warned at (vision `:586-587`) | planned: 4g on the `b18e7db` contents (§5.4) | **closed here** |
| Method or alternatives statement at the existing loop halt | #50 Gate B (cycle 27xgcofe9f) does not carry it: the class was generalised in passes 5 and 6 (story §1, as corrected in `a9743c4`); canvas A5/T2a is a possible instance, not verified here | not determinable without a new search | routed: note at the arms-race row, its story unchanged |
| A Gate A question on unneeded scope (Gate B already asks it, §3) | none: #50's growth came from accepted security findings, #49's robustness came from the reviewer | — | not evidenced; recorded in the report only |
| Proportionality of review effort for instrument findings | fic2 (`docs/field-reports/2026-08-26-fic2-cycle-evidence.md`) as motivation; the proportionality row's own trigger (instrument findings measurably starving product findings, both counted) is not shown | — | routed: note at `todos.md` "EXPERIMENTAL — proportionality for findings whose subject is a test instrument" |
| No kit guidance or check keeps a project's own `AGENTS.md` within the always-loaded budget (4e measures only the `CLAUDE.md` template, `scripts/check-invariants.sh:664-667`) | canvas `AGENTS.md` at 126,332 bytes (`docs/superpowers/stories/2026-10-06-living-feature-docs-pilot-story.md:11`); no combined character count of canvas's instruction files is recorded | — | routed: the kit-side gap is G3c's, which already covers "widened to `AGENTS.md`: a short binding core, details loaded for the task at hand" (`todos.md:687-690`); dated note with this evidence; the living-feature-docs pilot may help later but commissions an SFX pilot, not a canvas cleanup (its AC-2, AC-9) |

**Outside the kit's backlog, not a kit gap:** trimming canvas's own `AGENTS.md`. It is that project's content; the kit changes an initialized project only through a run the project accepts (AGENTS.md invariant 9), so no `todos.md` row here owns it. Nothing in this delivery is claimed to cover it.

Backlog notes (story AC-7), each a dated note on an existing row and no new row: the arms-race row, the proportionality row, G3c, and the "Over-engineering check" row (whose "each repair spawning an adjacent case" is corrected to match story §1; the story's change record lists it as blocking this delivery's Gate-B cycle until updated). Related items keep their existing owners and get no second entry: plan form and spec/plan roles stay with G3a, shipped through `docs/superpowers/stories/2026-10-06-compact-planning-context-handover-story.md` (`todos.md:706-732`); effort metrics, thresholds and "was it worth it" stay with "Review-loop usefulness — metrics, scoring and calibrated thresholds" (`todos.md:1075` onward). The report names each owner.

## 5. Check 4g

### 5.1 Behaviour

- A new marked block, `# --- BEGIN check 4g ---` … `# --- END check 4g ---`, in `scripts/check-invariants.sh`, after 4f.
- It counts the characters of `CLAUDE.md` plus `AGENTS.md` at the repository root and fails when the sum exceeds **150,000**. The message names the sum and the budget.
- It fails closed: a missing or unreadable file, or no UTF-8 locale for counting characters, is a failure with its cause named, never a pass. A byte count is not a fallback.
- It reuses 4e's locale probe and `fail` reporting, so a failure reads like the others in that script.

### 5.2 The budget

150,000 characters is **this repository's budget**, chosen because the overrun at `b18e7db` was observed against it. 4e itself calls 150.0k the value Claude Code used "when this was written" and notes that its documentation does not state the number (`scripts/check-invariants.sh:651-653`). The check does not claim that any client's current limit is 150,000.

### 5.3 What it does not measure

Only those two files, at fixed paths. Outside the measurement: the user's own `~/.claude/CLAUDE.md`, memory files, text that plugins, skills and hooks inject, `.claude/review-gates.md` (read on demand, not always loaded), and any file `CLAUDE.md` might import later. Daniel decided against an import lock (2026-10-08): it would be a further architecture rule, and it would suggest a completeness the check does not have. The fixed boundary is documented instead, in the check's header comment and in `AGENTS.md`.

### 5.4 Verification (mode `battery+check`)

- **Battery:** the full quality command in `AGENTS.md` § Commands, green.
- **Tests** in `scripts/check-invariants.test.sh`, as reject/accept pairs: exactly at the budget is accepted; one character over is rejected with the budget message; a multi-byte character counts as one; a missing file is rejected.
- **Mutation:** with the 4g block deleted from a scratch copy, the suite goes red, following the procedure at `scripts/check-invariants.sh:24-56`; the flipped set is checked by a human, as that procedure requires.
- **Counter-check on the historical contents:** a scratch copy of the current tree with only `CLAUDE.md` and `AGENTS.md` replaced by their `b18e7db` contents. Expected: the script fails, and **4g's budget message, naming 151,246 characters, is the only failure**. Any other failure is reported and explained, never ignored. The same run on the unmodified tree passes. The result is claimed only once it has run.
- **Agent behaviour:** not applicable: 4g is a script that runs without a model. CI already runs `scripts/check-invariants.sh` (`.github/workflows/ci.yml:117`).
- **Later observation:** a future 4g failure, or the "rule files" group in `scripts/status-view.py` (bytes and lines), are observations. Neither proves a benefit.

### 5.5 Documentation

`AGENTS.md` names 4g where it lists the invariant checks (§ Commands, "invariant checks" row), with its boundary in one sentence. The Gate-B standing lens decides which other sentences about 4e or about instruction size this diff makes wrong.

## 6. Report

`docs/field-reports/2026-10-08-overengineering-check.md`, short, written after implementation. It states the results, the concrete evidence (the counter-check run and its output, the test and mutation results), the size of the two files before and after, and the limits. It links to §3 and §4 of this spec and to the `todos.md` rows instead of copying them. No other report format.

## 7. Earlier recommendations relied on (story AC-8)

| Recommendation | Source | Verdict |
|---|---|---|
| A/A/A at intake (one coherent first delivery; arms-race row stays owner; removal only of over-engineering text) | reviewer, confirmed by Daniel 2026-10-08 | confirmed: size rules in intake (`SKILL.md:194`); the arms-race row's story is bound to the guard-scope story (`todos.md:239-246`) |
| Close the instrument pattern with a "whole class" rule (option C) | Claude, 2026-10-08 | rejected: #50 does not carry it, and the rule can itself produce unbounded robustness |
| Option 3: inventory, routing and a size-regression check | Claude, revised after review; chosen by Daniel 12:59 | confirmed: meets story AC-4 (§4) |

## 8. Gates

Gate A on this spec, then on the plan; Gate B over the branch from its merge-base with `main`, which includes `781d9d4` (`todos.md`) and the story commits. The floor and the lens sets derive from the cited story's profile, read fresh at each pass. No triviality skip.
