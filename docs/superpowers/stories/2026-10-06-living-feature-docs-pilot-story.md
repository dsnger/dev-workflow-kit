# Living feature docs, piloted on SFX — Story

**Date:** 2026-10-06 · **Size:** story
**Risk:** standard · **Security:** none · **Validation:** battery+check

## 1. Problem statement
A project built with this workflow has no living description of what its software is
today. Stories, specs and plans are dated change records: the current behaviour of a
feature is spread across every record that ever touched it, so an agent must read many
of them to learn the present state, or reads too few and misses something. What does
exist grows without bound instead: the canvas project's AGENTS.md was 126,332 bytes on
2026-10-06, and every agent reads it whole in every session. Breaks between features are
the hardest to see, because each agent works with one feature's context.

## 2. Desired outcome
Daniel decided a documentation model on 2026-10-06. Before any of it enters the kit, it is
recorded here and tried on one real story, so that the kit adopts only what a pilot
supports. Guiding principle: no Markdown file grows huge, because no task needs to read
more than its solution requires. The structure must be equally traceable for people and
selectively readable for agents, and it stays independent of particular models and their
current properties.

The model under trial:
- **Two trees.** *Structure* (living — what the software is): product level (vision,
  strategy, scope, architecture core) → capability → feature → child feature. *Work*
  (dated — what changes): initiative → story → spec → plan. A level is added only when
  size demands it.
- **Feature** = a functional specification: a capability triggered by a user, by time or
  by another system. A feature doc describes the current feature-specific behaviour —
  business flows, UI, business rules, linked user stories — plus its borders to neighbour
  features and links to the dated records, and references the authoritative shared
  contracts and architecture rules. Cross-cutting qualities such as security or speed
  belong to the architecture level; feature-specific guarantees and constraints remain
  explicit at the feature.
- **Change.** Every new story is first assigned to the features it touches, or names a
  new one. Each touched feature doc is checked in the same change as the code and updated
  wherever its description or references would otherwise become stale; the result of the
  check is noted, so that "checked, unchanged" is distinguishable from "not checked". A
  story touching many features signals that it should be split.
- **Splitting** is a content decision. Size may raise a soft alarm that puts the question
  up for decision; it never fails a check.
- **Integration.** A cross-feature flow is a short section in the capability or product
  doc, stating the features involved, the result that must hold and the behaviour on
  relevant interruptions; its critical promises get tests. Each contract part has one
  authoritative definition (shape as type or schema where technically sensible, meaning as
  short binding statements). Impact checks start at the map and continue along
  dependencies while an effect can propagate, ending with a stated reason at a provably
  unchanged contract. Changes to shared contracts, data or resources are checked for
  conflicts; the composed candidate is checked against the current target branch before
  it lands.
- **Removal** is itself a story: the feature doc is archived, a short stub stays at its
  old path, dated records stay where they are, and open work is explicitly ended,
  adapted or reassigned.
- **Context.** The agent assembles its own context under a binding selection rule: the
  story and the current work state (spec, plan); the touched feature docs and relevant
  flows; the shared contracts and affected users per the impact check; and the project
  rules that apply. What this rule selects is the *map-guided set* AC-4 measures against.
  The agent reads historical records only on demand, and notes in its plan which features
  and contracts are touched and where its investigation ended.
- **Responsibilities and findability.** Each kind of content has one home: where to find
  what → a short documentation signpost; system structure, components, boundaries and
  cross-cutting architecture → the architecture overview; technologies, their job, why
  they were chosen and their constraints → a tech-stack section (its own document when
  needed); project-specific coding conventions and pointers to technical checks →
  development guidelines; current business behaviour → the living feature docs; past
  decisions and changes → the existing stories, specs and plans. This assigns
  responsibilities, not a mandatory set of new files: suitable existing documents are kept,
  a separate file exists only where content is read or maintained independently, and there
  is no file per library and no empty template. Names are understandable and locations
  unambiguous; the signpost says briefly what belongs where and does not duplicate content.
  Every binding statement has exactly one authoritative source, linked from elsewhere;
  exact installed versions stay in manifests and lockfiles. Architecture knowledge people
  need is never kept only in agent-only configuration, and splitting or linking a file does
  not by itself show that its content is loaded when needed.

Why a pilot first: the pilot shows whether the model makes integration risks visible
earlier at an upkeep cost worth paying. "The model was usable but needed too much upkeep"
is an honest result.

## 3. Acceptance criteria
_IDs are permanent once the story is committed: never renumber or reuse one; a new criterion takes the next number unused here and on the branch it merges into, and a collision stops for a human; a removed one stays, struck through and dated; a narrowed one keeps its ID with a dated note; cite as `<story path> AC-<n>`; full rules: dev-workflow:intake, "Acceptance-criterion IDs"._
- [ ] **AC-1** Before the pilot starts, a recorded human decision settles the conflict with the vision's decision 2 ("No second architecture document that could drift", `docs/superpowers/specs/2026-08-30-dark-factory-vision.md`), and names which place is authoritative for each kind of architecture statement.
- [ ] **AC-2** The pilot runs in the SFX dashboard on one real story whose change crosses at least one feature border. It starts only after P5b has closed, and the planning method in force after P5b stays unchanged during the pilot.
- [ ] **AC-3** The pilot initially documents the features its story touches and their direct neighbours. The impact investigation extends beyond them wherever an effect can propagate; additional documentation is limited to what that investigation requires. No full reorganisation of SFX is required, and the report states the map's coverage and known gaps.
- [ ] **AC-4** The report lists every source the agent had to load beyond the map-guided set and every human assist, each with when and why. A planned on-demand read of a historical record is listed but not counted as a gap.
- [ ] **AC-5** The report gives effort separately for setting up the docs, keeping them current within the change, and searching for context — each with its unit and how it was captured. A value that was not captured is reported as unknown, not estimated.
- [ ] **AC-6** The report counts omissions across the whole run — implementation, tests, Gate B and integration — as confirmed dependencies (a feature, contract, shared data or event) missing from the impact scope as the agent first noted it; later additions to that note are dated and do not erase an omission. It does not present zero omissions as proof of completeness.
- [ ] **AC-7** The report gives the length of the pilot's spec, plan and feature docs and of the context actually read, as observations rather than a pass bar. Where P5b figures exist they stand beside them as a reference, labelled as not comparable to a savings figure; missing P5b figures are reported as missing, not reconstructed.
- [ ] **AC-8** The report ends with exactly one recommendation — adopt, adapt (naming the changes) or reject — with its reasons. It distinguishes the model elements the pilot exercised from those it did not, and limits its conclusions to the exercised ones. A completed pilot may recommend against adoption.
- [ ] **AC-9** No file under `plugins/` changes in this story. Adoption into the kit is a separate, later story that takes the report as its input.
- [ ] **AC-10** The report is one authoritative file in this repo; SFX links to it and keeps no copy.
- [ ] **AC-11** The documents the pilot touches are reachable from a short signpost that says what belongs where and links to it without duplicating content. The signpost covers only what the pilot touches and the existing documents those point to; no other part of SFX is reorganised.
- [ ] **AC-12** The report records observed orientation problems — a wrong place searched, an unclear authoritative source, human help needed to find something — and uses them together with AC-5's effort figures to judge whether the split is worth its upkeep. No separate test process is set up for this.
- [ ] **AC-13** Before the pilot runs, it is checked and recorded how the client in use actually loads instructions (which files automatically, which only when read), and architecture knowledge people need is not kept only in agent-only configuration.

**Changed 2026-10-06 — gap found.** Decided by Daniel in the Claude Code session of 2026-10-06: the context-selection rule by his decision to record the discussed model ("A, erst festhalten, dann im SFX-Dashboard erproben", about 10:04), whose context decision named the rule's sources; the open question by his vision decision (answer "a", about 10:14); the goals/scope check by his answer "A" (about 10:36), which keeps the vision text unchanged. Baseline: 7ee641e. Two PR #47 bot findings, both confirmed true: AC-4 measures against a "map-guided set" the story never defined, and §5 still listed a decided question as open.

| Earlier condition | Fate | AC operation |
|---|---|---|
| §2 model bullets other than Context, the guiding principle and "Why a pilot first" | kept | none |
| §2 Context: "assembles its own context under a binding selection rule" | kept, with the rule's sources written out as the context decision named them: "story + current work state (spec, plan); touched feature docs + relevant flows; shared contracts + affected users per the impact check; the project rules that apply"; what it selects is named the map-guided set | none |
| AC-1 … AC-10 | kept | none |
| §5: the vision decision 2 question, "Blocks the pilot start (AC-1)" | dropped — per the decision: "Jede verbindliche Architektur-Aussage hat genau eine maßgebliche Quelle" (recorded in the vision's change record); struck through with a pointer to that record | none |
| §5: which SFX story is the pilot story | kept, with a check added per Daniel's decision (about 10:36): "Bei Auswahl der Pilotstory prüfen, ob sie davon betroffen ist. Falls ja, die Frage vor der abhängigen Arbeit klären; andernfalls bei der späteren Kit-Übernahme." | none |
| §6 size | kept | none |

- **Unaccounted:** none.
- **Intervening changes:** none — the file is unchanged between 7ee641e and this change.
- **Scope boundary:** in: the §2 Context bullet and both §5 questions. out: every criterion's wording; choosing the pilot story; the vision text.
- **Open questions:** none added.
- **Dependent artifacts:** none.
- **Reviews already run:** none — this story ran no gate cycle, being docs-only under `.claude/review-gates.md`, "What counts as prose (the only Gate-B exemption)"; the PR #47 bot comments are this change's inputs.

**Changed 2026-10-06 — changed requirement.** Decided by Daniel in the Claude Code session of 2026-10-06 (about 12:21): "Die Dokumentationsstruktur muss für Menschen nachvollziehbar und für Agenten gezielt lesbar sein. Beide Anforderungen sind gleichwertig. Die Struktur bleibt unabhängig von konkreten Modellen und deren heutigen Eigenschaften." / "Ergänze dort die Zuständigkeiten, menschliche Auffindbarkeit und den Wegweiser." / "Erweitere den begrenzten Pilotumfang nicht zu einer vollständigen Projekt-Reorganisation." / "Halte im bestehenden Pilotbericht beobachtete Orientierungsprobleme fest: falscher Suchort, unklare maßgebliche Quelle oder notwendige menschliche Hilfe beim Auffinden." / "Nutze dieselben Beobachtungen, um zu beurteilen, ob die Aufteilung ihren Pflegeaufwand wert ist. Kein eigener Testprozess dafür." / "Prüfe bei der Einrichtung, wie der verwendete Client Anweisungen tatsächlich lädt. Menschenrelevantes Architekturwissen darf nicht ausschließlich in versteckten Agentenkonfigurationen stehen." Baseline: adf79f6. AC-11, AC-12 and AC-13 are new criteria per these passages; they replace no earlier condition.

| Earlier condition | Fate | AC operation |
|---|---|---|
| §2 guiding principle | kept; a sentence added on equal human and agent readability and model independence, per the decision's first passage | none |
| §2 model bullets | kept; a "Responsibilities and findability" bullet added, per the decision: "Ergänze dort die Zuständigkeiten, menschliche Auffindbarkeit und den Wegweiser." | none |
| AC-1 … AC-10 | kept (AC-3's pilot scope included, per the decision: "Erweitere den begrenzten Pilotumfang nicht zu einer vollständigen Projekt-Reorganisation.") | none |
| §1, §4, §5, §6 | kept | none |

- **Unaccounted:** none.
- **Intervening changes:** none — the file is unchanged between adf79f6 and this change.
- **Scope boundary:** in: §2's guiding principle and new bullet, AC-11 … AC-13. out: the open goals/scope placement and every other decision on product documents, architecture sources and their readers, which this does not decide in passing; the kit's context rule, which `docs/superpowers/stories/2026-10-06-compact-planning-context-handover-story.md` owns.
- **Open questions:** none added.
- **Dependent artifacts:** none.
- **Reviews already run:** none — docs-only story, no gate cycle (`.claude/review-gates.md`, "What counts as prose (the only Gate-B exemption)").

## 4. Affected AGENTS.md invariants
- `## Don'ts` — "**Never rename or delete a doc section without grepping for references first.**"
- `## Don'ts` — "**Never describe what a gate proves without checking what it actually compares.**"
- `## Don'ts` — "**Never replace a decision procedure without accounting for its old conditions.**"

## 5. Open questions
- ~~How is the conflict with vision decision 2 resolved: is the rule amended (for example to "each architecture statement stands in exactly one place"), or is the model changed? Blocks the pilot start (AC-1).~~ Answered 2026-10-06 by Daniel's decision, recorded in the change record at the end of §2 of `docs/superpowers/specs/2026-08-30-dark-factory-vision.md`.
- Which SFX story is the pilot story? It must cross a feature border (AC-2). When choosing it, check whether it needs goals or scope moved out of AGENTS.md into product-level files; if so, settle the open goals/scope question in the vision's §2 change record before the work that depends on it, otherwise it waits for the later kit adoption.

## 6. Suggested size
story — one pilot on one SFX story with one report; the kit changes are deliberately left out (AC-9).
