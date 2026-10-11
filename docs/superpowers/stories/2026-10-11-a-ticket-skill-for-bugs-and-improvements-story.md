# A `ticket` skill for bugs and improvements — Story

**Date:** 2026-10-11 · **Size:** story
**Risk:** standard · **Security:** none · **Validation:** battery+check

## 1. Problem statement
The kit has one entrance for work: `intake`, which turns an idea into a story and sends it
through spec, plan and both Gate-A cycles. A bug, a regression, a robustness fix or a wording
defect that stays inside approved commitments has no entrance of its own. It either goes through
the full story path, which is too heavy for it, or it is fixed ad hoc without a record of the
evidence, the expected behaviour's source or the decision not to fix it.

Daniel decided on 2026-10-11 (11:43–11:44) that bugs and improvements get their own skill,
`ticket`, not another intake route (K8). Prior art read as data only: Matt Pocock `triage`
(one category role and one state role per issue, the issue as an agent brief, an out-of-scope
record) and `diagnosing-bugs` (an ordered list of feedback loops). Finding F7 (Step 2 replay,
PR #60) showed that a route file behind a prose pointer is not re-read after compaction, so
the orchestrator's addendum of 2026-10-11 12:55 requires the skill to be one file.

## 2. Desired outcome
A developer can hand a bug or an improvement to `/dev-workflow:ticket` and get a ticket file
that records the evidence, the expected behaviour's source and the approved commitment the fix
stays inside, and that serves as the brief a coding agent fixes it from. A change that alters
an approved commitment is not ticketed: it is handed to `intake`. The project keeps its tickets,
including the ones it decided not to fix, as files it can list.

## 3. Acceptance criteria
_IDs are permanent once the story is committed: never renumber or reuse one; a new criterion takes the next number unused here and on the branch it merges into, and a collision stops for a human; a removed one stays, struck through and dated; a narrowed one keeps its ID with a dated note; cite as `<story path> AC-<n>`; full rules: dev-workflow:intake, "Acceptance-criterion IDs"._
- [ ] **AC-1** The plugin ships the skill as exactly one file, `plugins/dev-workflow/skills/ticket/SKILL.md`, with no route files or other files it points to for its own steps. It is invoked as `/dev-workflow:ticket` with a description, a path to evidence, `list`, or a ticket id `T-<n>`. The PR reports its size in characters; if it passes 15,000 characters the PR says why it was not split.
- [ ] **AC-2** Before writing a ticket the skill decides whether the change alters an approved commitment (behaviour, contract, security guarantee, scope). A ticket quotes the commitment its fix stays inside and names that commitment's source. When the change alters a commitment, or no commitment can be quoted, the skill writes no ticket: it hands the captured text to `intake` — its Flow for new behaviour, its "Amending an approved story or spec" route for a changed commitment — and stops. When the texts cannot decide the question, the ticket records it in a "decision needed" field and asks; no new rule decides it.
- [ ] **AC-3** A ticket records: observed behaviour with its evidence (a command and its output, a log line, a failing test or a screenshot path), expected behaviour with its source (a spec section, a test, or a row of the project's `docs/PRD.md` feature map), repro steps, the affected feature, a severity from `blocker|major|minor|nit`, and first seen (version or commit). A field the input cannot support stays blank with the reason. No new severity vocabulary is introduced.
- [ ] **AC-4** Every ticket carries exactly one category (`bug|regression|improvement|docs`) and exactly one state (`needs-triage|needs-info|ready|in-progress|done|wontfix`). An input that would give two of either, or none, stops and asks. A `needs-info` ticket lists the questions for the reporter.
- [ ] **AC-5** ~~The ticket file is the brief a coding agent fixes from: fix scope, what stays out, the feedback loop that goes red on exactly this defect (chosen in a stated order from: failing test at the nearest seam, HTTP or CLI script with fixture, headless-browser script, replayed captured trace, throwaway harness, property or fuzz loop, bisection harness), the review profile (inherited from the touched feature's story where one is recorded, otherwise proposed by the profile rules), and the files to read. It carries no spec and opens no Gate-A cycle.~~ — withdrawn 2026-10-11: replaced by AC-12 (no profile of its own; the story is cited in a `**Story:**` line), see the change record below.
- [ ] **AC-6** Tickets are written to `docs/superpowers/tickets/<date>-T<n>-<slug>.md`. `T-<n>` is numbered per project and never reused. A `wontfix` ticket keeps its reason and stays in the folder as the project's out-of-scope record; no second file format exists for that. When the project has a `todos.md`, each new ticket gets a one-line pointer there; a project without one gets none.
- [ ] **AC-7** `/dev-workflow:ticket list` reads the tickets folder and shows three buckets, oldest first: `needs-triage`, `needs-info`, `ready`.
- [ ] **AC-8** The skill's hand-off to build names: a test that goes red before the fix and green after, Gate B on the diff under the ticket's profile, and the closing act per the project's gate rules. A ticket raised from a review finding links that finding's hardening-ledger row; `harden-finding` stays the owner of findings.
- [ ] **AC-9** Out of scope and absent from the diff: issue-tracker integration (a ticket is a file), any change to `intake` other than accepting the hand-off text, a new severity vocabulary, and a new rule sentence in `.claude/review-gates.md`, `CLAUDE.md` or `AGENTS.md`.
- [ ] **AC-10** The skill passes all 12 items of `docs/prompt-standards.md` (target model named once). The plugin version is bumped and `CHANGELOG.md` has an entry. The plugin manifest gains no key for the skill. The quality battery passes. Checks 4a and 4f are unchanged, or extended with their limit stated.
- [ ] **AC-11** A replay of three cases runs before merge: a bug with evidence, an improvement inside a commitment, and a reported "bug" that is a commitment change and must go to `intake`. The baseline is the same input given to `intake` without the skill. The per-case checks and a run-validity rule are written and committed before the first run. The results, pass or fail per case and check, are recorded in the PR.
- [ ] **AC-12** The ticket file is the brief a coding agent fixes from: fix scope, what stays out, the feedback loop that goes red on exactly this defect (chosen in a stated order from: failing test at the nearest seam, HTTP or CLI script with fixture, headless-browser script, replayed captured trace, throwaway harness, property or fuzz loop, bisection harness), the review profile, inherited from the touched feature's story where one is recorded, and the files to read. The profile is inherited by citing that story in a `**Story:**` line in the form `.claude/review-gates.md` parses, and the ticket carries no profile of its own; when no story stands behind the commitment, the ticket has no `**Story:**` line. It carries no spec and opens no Gate-A cycle.

**Changed 2026-10-11 — gap found.** Decided by the orchestrator dev-workflow-kit-d4 under Daniel's sprint instruction (Daniel informed, can object before the Gate-A spec cycle opens), in a cross-session message to this session on 2026-10-11 (17:25). Baseline: c27e238. Rationale: `.claude/review-gates.md` makes the story header "the single writable copy" of a profile; a profile proposed into a ticket would be a second copy no gate reads, and a ticket citing its story in a parsed `**Story:**` line lets Gate B take the profile fresh, as it does for a plan.

| Earlier condition | Fate | AC operation |
|---|---|---|
| AC-5: the brief's fix scope, out-of-scope, feedback-loop list, files to read, no spec and no Gate-A cycle | moved → AC-12, per the decision: "AC-12 = same text minus the proposal clause plus the Story-line rule" | withdrawn; added AC-12 |
| AC-5: "the review profile (inherited from the touched feature's story where one is recorded" | moved → AC-12, per the decision: "AC-12 = same text minus the proposal clause plus the Story-line rule" | withdrawn; added AC-12 |
| AC-5: "otherwise proposed by the profile rules" | dropped — per the decision: "AC-12 = same text minus the proposal clause"; "the story header stays the single writable copy of a profile" | withdrawn |
| AC-1 … AC-4, AC-6 … AC-11 | kept | none |
| §2: the ticket "serves as the brief a coding agent fixes it from"; a commitment change "is handed to `intake`"; tickets kept as listable files | kept | none |

- **Added without an earlier condition:** none. (AC-12's `**Story:**` line rule replaces AC-5's profile clause and is mapped in its rows; AC-5 is a replacement, not a narrowing, because the line is a requirement the old text did not have.)
- **Unaccounted:** none.
- **Intervening changes:** `docs/superpowers/specs/2026-10-11-ticket-skill-design.md`, untracked, written after the baseline against this story → committed with this change as a dependent artifact.
- **Scope boundary:** in: where a ticket's review profile comes from; out: any rule sentence in `.claude/review-gates.md`, `CLAUDE.md` or `AGENTS.md`; any change to how Gate B derives a floor.
- **Open questions:** none.
- **Dependent artifacts:** `docs/superpowers/specs/2026-10-11-ticket-skill-design.md` → updated in this change.
- **Reviews already run:** none. No Gate-A cycle has opened on this story's spec; the spec cycle reads the story as amended here (`.claude/review-gates.md`, "Recording is not amending": a changed acceptance criterion "still takes the amendment route … and its Gate-A cycle").

## 4. Affected AGENTS.md invariants
- `## Key invariants` › Prompts and scaffolding, 11 — "**Prompt changes pass `docs/prompt-standards.md`** — all 12 checklist items, for any skill, command, agent definition, hook message, or scaffolded template."
- `## Key invariants` › Prompts and scaffolding, 10 — "**The base taxonomy stays stack-neutral.** Project vocabulary — tables, auth helpers, framework APIs — goes only in that project's `docs/hardening-taxonomy.md`, never into the `harden-finding` skill."
- `## Key invariants` › Packaging, 12 — "**A plugin change requires a version bump.** A pull request that changes any path under a `plugins/<name>/` directory **that still exists at HEAD** … must also change that plugin manifest's `version`, or CI fails."
- `## Key invariants` › Packaging, 6 — "**The manifest never re-declares convention-loaded components.** `skills/`, `commands/`, `agents/` and `hooks/hooks.json` load automatically"
- `## Architecture` › Boundaries (binding), 1 — "`skills/`, `commands/`, `agents/` and `hooks/hooks.json` are loaded by convention from their paths."

## 5. Open questions
- None. (Resolved by the orchestrator dev-workflow-kit-d4, 2026-10-11: `list` shows plain `needs-info`, since a ticket file has no reporter channel; the `todos.md` pointer is written only where the project has one — AC-6.)

## 6. Suggested size
story — one new single-file skill with its replay, one spec → plan → PR.
