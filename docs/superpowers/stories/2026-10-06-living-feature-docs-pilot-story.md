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
more than its solution requires.

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

## 4. Affected AGENTS.md invariants
- `## Don'ts` — "**Never rename or delete a doc section without grepping for references first.**"
- `## Don'ts` — "**Never describe what a gate proves without checking what it actually compares.**"
- `## Don'ts` — "**Never replace a decision procedure without accounting for its old conditions.**"

## 5. Open questions
- ~~How is the conflict with vision decision 2 resolved: is the rule amended (for example to "each architecture statement stands in exactly one place"), or is the model changed? Blocks the pilot start (AC-1).~~ Answered 2026-10-06 by Daniel's decision, recorded in the change record at the end of §2 of `docs/superpowers/specs/2026-08-30-dark-factory-vision.md`.
- Which SFX story is the pilot story? It must cross a feature border (AC-2). When choosing it, check whether it needs goals or scope moved out of AGENTS.md into product-level files; if so, settle the open goals/scope question in the vision's §2 change record before the work that depends on it, otherwise it waits for the later kit adoption.

## 6. Suggested size
story — one pilot on one SFX story with one report; the kit changes are deliberately left out (AC-9).
