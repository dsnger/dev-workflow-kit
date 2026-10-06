# Compact planning, matching Gate A, task context and session handover — Story

**Date:** 2026-10-06 · **Size:** story
**Risk:** standard · **Security:** none · **Validation:** battery+check

## 1. Problem statement
Plans in projects using this kit have become implementation written twice. SFX's P5a plan
was 660,054 bytes, about 10,505 of its 11,295 lines fenced code, and its Gate-A cycle took
6 passes and about 5.5 hours, largely repairing code inside the plan (SFX
`.context/plan-form-pilot.md`). One cause is in the instructions agents load: superpowers'
`writing-plans` 6.4.1 requires code blocks for code steps and complete test code, and
nothing in this kit says what a plan is for instead. Gate A then reviews that code as plan
content. Agents also read more than a task needs and carry one session across many units of work:
the kit has rules for resuming an interrupted review cycle, but none for choosing context or
for a planned change of session at a completed unit. Ordering
group G3 in `todos.md` owns this work, but as four separately sequenced leaves.

## 2. Desired outcome
Projects using this kit plan, review and hand over work under rules that keep each artifact
to its own job, so that less effort goes into planning and context without weakening review.
Shipped as one bounded release (Daniel, 2026-10-06), and taken up by existing projects at
safe boundaries. Not part of it: a full reorganisation of the rule files, a new context or
orchestration tool, the living-feature-docs model, and the other open workflow repairs, which
keep their existing backlog owners.

## 3. Acceptance criteria
_IDs are permanent once the story is committed: never renumber or reuse one; a new criterion takes the next number unused here and on the branch it merges into, and a collision stops for a human; a removed one stays, struck through and dated; a narrowed one keeps its ID with a dated note; cite as `<story path> AC-<n>`; full rules: dev-workflow:intake, "Acceptance-criterion IDs"._
- [ ] **AC-1** The kit's instructions state what each artifact decides. A spec: intended behaviour and scope, boundaries and shared contracts, significant architecture and security decisions, acceptance criteria — leaving internal implementation open where those permit. A plan, per meaningful step: the outcome, affected components and existing implementation to reuse, prerequisites, order and decisions that must already be settled, concrete test situations with expected outcomes including relevant failures, and the implementer's remaining decision space. Code: function bodies, complete tests and routine local choices. Short algorithm sketches and bounded feasibility probes stay available where they resolve a named uncertainty.
- [ ] **AC-2** Where an installed `writing-plans` asks for code blocks in code steps or complete test code, an instruction surface this kit ships or scaffolds says that the kit's planning contract governs. That instruction is loaded in the actual planning workflow before plan generation, and the adoption path makes the same instruction available in existing projects. No other plugin's cache is edited.
- [ ] **AC-3** Gate A asks of a spec whether its commitments are coherent, sufficiently decided and feasible, and of a plan whether implementation can proceed: adequate decisions and dependencies, realistic steps, meaningful verification, a clear boundary between local choices and questions needing a decision. A missing function body or complete test is not by itself a finding; a finding names a concrete consequence; code a plan does include stays reviewable.
- [ ] **AC-4** Implementers may make local choices within approved commitments. A change to product behaviour, a shared contract, a security guarantee or approved scope follows the existing decision and amendment route.
- [ ] **AC-5** Review validity is unchanged: findings-file protocol, pass floor, closure ordering, severity rules, reviewer independence and security requirements say the same before and after. Only what Gate A asks of each artifact changes.
- [ ] **AC-6** ~~A context rule says what an agent reads for a task: applicable binding instructions; the current task and approved artifacts; relevant components, contracts and dependencies; further sources needed to resolve a material uncertainty. Historical records are loaded when needed to understand a decision, constraint or open obligation, and following one link does not require loading everything it links to. Binding reading duties stay until changed through their route, and calling a document "reference" does not make its binding conditions optional. Sources and the impact boundary are noted briefly in the existing plan or work record; no new mandatory report document. Living feature docs are not a prerequisite.~~ — withdrawn 2026-10-06: replaced by AC-15, which adds configuration, data volumes and target environments to the reading list.
- [ ] **AC-7** ~~At a completed unit of work, the instructions direct that the next unit starts in a fresh session, prepared by a short handover: verified state and next task, open obligations and unresolved decisions, authoritative artifact and evidence paths, review-cycle identity and status where relevant. They name which boundaries count as a completed unit, so that not every small step starts a session. The handover reuses an existing mechanism where one exists, discards no evidence, never silently restarts an interrupted gate, and leaves the existing interruption and resume rules in force. No context percentage or token estimate is required.~~ — withdrawn 2026-10-06: replaced by AC-16, which requires the handover to be a current summary that carries every open obligation and links history instead of accumulating it.
- [ ] **AC-8** Before a large spec is written, the instructions ask whether the epic holds independently reviewable outcomes with identifiable shared contracts. Touching several features is a signal to examine the scope, not by itself a reason to split. File size is a warning signal; no fixed size cap is introduced.
- [ ] **AC-9** Every copy of a changed rule agrees: this repository's own instruction files, the `/workflow-init` templates and `docs/coding-workflow.md`. The prompt standards pass, the plugin version is bumped with a CHANGELOG entry, and the invariant checks pass, including the `CLAUDE.md` template size check.
- [ ] **AC-10** An adoption path tells an existing project what to change, at which boundary, and how project-specific conditions are kept; nothing is overwritten silently.
- [ ] **AC-11** ~~For SFX and canvas, a focused adoption change is prepared from their current local rules, applied only at a completed work or review boundary, without editing in-flight artifacts, and reported as applied, prepared, or waiting for a named boundary. Running review cycles keep the rules they started with.~~ — withdrawn 2026-10-06: replaced by AC-17, which adds `sfx-bricks-api-builder` as a third project.
- [ ] **AC-12** A bounded comparison uses the same task and project inputs under the old and the new instructions, with isolated contexts and a recorded evaluation rubric derived from AC-1. The new output supplies the required planning decisions and test expectations without defaulting to full implementation. A focused review check also demonstrates AC-3: missing implementation bodies alone are not findings, while a deliberately omitted material decision or critical test expectation is identified. Results and limitations are reported as observations; no general saving is claimed.
- [ ] **AC-13** `todos.md` records the changed grouping of G3, with every earlier condition of the group accounted for as kept, moved or dropped. The remaining G3 work and the follow-up repairs keep explicit owners and order, and no entry is duplicated.
- [ ] **AC-14** P5b's actual state is recorded: it continues under its pilot instruction. SFX adopts the released rules at the first suitable completed-work boundary after both P5b's closing act and the release being available. The actual first unit under the released rules is named; work already completed is not repeated.
- [ ] **AC-15** A context rule says what an agent reads for a task: applicable binding instructions; the current task and approved artifacts; relevant components, contracts and dependencies; the relevant configuration, realistic data volumes and target environments; further sources needed to resolve a material uncertainty. Historical records are loaded when needed to understand a decision, constraint or open obligation, and following one link does not require loading everything it links to. Binding reading duties stay until changed through their route, and calling a document "reference" does not make its binding conditions optional. Sources and the impact boundary are noted briefly in the existing plan or work record; no new mandatory report document. Living feature docs are not a prerequisite.
- [ ] **AC-16** At a completed unit of work, the instructions direct that the next unit starts in a fresh session, prepared by a short handover: verified state and next task, open obligations and unresolved decisions, authoritative artifact and evidence paths, review-cycle identity and status where relevant. The handover is a current summary: it carries every open obligation in full, including any still recorded only in an earlier state, and links earlier states instead of growing by appended full status reports. The instructions name which boundaries count as a completed unit, so that not every small step starts a session. The handover reuses an existing mechanism where one exists, discards no evidence, never silently restarts an interrupted gate, and leaves the existing interruption and resume rules in force. No context percentage or token estimate is required.
- [ ] **AC-17** For SFX, canvas and `sfx-bricks-api-builder`, a focused adoption change is prepared from their current local rules, applied only at a confirmed completed work or review boundary, without editing in-flight artifacts, and reported as applied, prepared, or waiting for a named boundary. Running review cycles keep the rules they started with.

**Changed 2026-10-06 — changed requirement.** Decided by Daniel in the Claude Code session of 2026-10-06 (about 11:55, two messages): "Präzisiere die Übergabe als aktuelle Zusammenfassung mit vollständig übernommenen offenen Verpflichtungen und Verweisen auf historische Belege. Ergänze bei der Kontextauswahl relevante Konfigurationen, Datenumfänge und Zielumgebungen. Nimm das Projekt als dritten Kandidaten für eine vorbereitete Übernahme an einer sicheren Arbeitsgrenze auf." and "Kein neues Konzept und keine zusätzliche Story; die übrigen Entscheidungen bleiben bestehen." Baseline: 860a8f2. Evidence from `sfx-bricks-api-builder` (counted from its files on 2026-10-06): `docs/HANDOVER.md` is 420,570 bytes, its current block lines 6–109, the rest superseded blocks some of which still hold open obligations; a 1.21 MB live response exceeded a 1 MiB ceiling after the data source changed; its current block still lists a check on a PHP-FPM or LiteSpeed host as owed (line 68), right above a 2026-10-03 acceptance run that recorded the criterion as seen on PHP-FPM (lines 71–73), with product-owner acceptance still open — one handover carrying an obligation whose status it no longer states clearly.

| Earlier condition | Fate | AC operation |
|---|---|---|
| §1, §2, §4, §6 | kept | none |
| AC-1 … AC-5, AC-8 … AC-10, AC-12 … AC-14 | kept | none |
| AC-6: the context rule | kept: every element of AC-6; moved → AC-15, which adds "the relevant configuration, realistic data volumes and target environments", per the decision: "Ergänze bei der Kontextauswahl relevante Konfigurationen, Datenumfänge und Zielumgebungen." | withdrawn; added AC-15 |
| AC-7: the session change and handover | kept: every element of AC-7; moved → AC-16, which adds the current-summary requirement, per the decision: "Präzisiere die Übergabe als aktuelle Zusammenfassung mit vollständig übernommenen offenen Verpflichtungen und Verweisen auf historische Belege." | withdrawn; added AC-16 |
| AC-11: adoption in SFX and canvas | kept: every element of AC-11; moved → AC-17, which adds `sfx-bricks-api-builder` and a *confirmed* boundary, per the decision: "Nimm das Projekt als dritten Kandidaten für eine vorbereitete Übernahme an einer sicheren Arbeitsgrenze auf." | withdrawn; added AC-17 |
| §5: the canvas boundary question | kept | none |

- **Unaccounted:** none.
- **Intervening changes:** none — the file is unchanged between 860a8f2 and this change.
- **Scope boundary:** in: AC-6, AC-7, AC-11 and their replacements; one §5 question for the new project. out: the order and scope of the follow-up repairs, which stay as they were; the review-continuation and empty-ledger findings, which go to their existing backlog rows as evidence.
- **Open questions:** `sfx-bricks-api-builder`'s adoption boundary → recorded in §5.
- **Dependent artifacts:** `docs/superpowers/specs/2026-10-06-compact-planning-context-handover-design.md` → updated in this change; `todos.md` → updated in this change.
- **Reviews already run:** none on this story — it ran no gate cycle, being docs-only under `.claude/review-gates.md`, "What counts as prose (the only Gate-B exemption)". The consequence for the spec's closed Gate-A cycle is recorded in the spec's change record.

## 4. Affected AGENTS.md invariants
- `### Prompts and scaffolding` — "8. **`/workflow-init`'s templates stay inline** in the command body."
- `### Prompts and scaffolding` — "9. **`/workflow-init` never overwrites silently.**"
- `### Prompts and scaffolding` — "11. **Prompt changes pass `docs/prompt-standards.md`**"
- `### Packaging` — "12. **A plugin change requires a version bump.**"
- `## Don'ts` — "**Never replace a decision procedure without accounting for its old conditions.**"
- `## Don'ts` — "**Never describe what a gate proves without checking what it actually compares.**"

## 5. Open questions
- Canvas: its `.context/HANDOVER.md` describes a handover state; the session responsible for canvas must confirm the actual boundary at which adoption can be applied (AC-17).
- `sfx-bricks-api-builder`: no review cycle is open in its files as of 2026-10-06, but two branches are unmerged and two stale worktrees exist; the session responsible for it must confirm the boundary (AC-17).

## 6. Suggested size
story — one coherent rule change across the kit's instruction surfaces in one PR; project adoption is prepared here and applied in each project at its own boundary.
