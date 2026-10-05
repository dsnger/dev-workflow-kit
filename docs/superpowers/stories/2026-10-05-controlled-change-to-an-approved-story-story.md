# Controlled Change to an Approved Story or Spec — Story

**Date:** 2026-10-05 · **Size:** story
**Risk:** standard · **Security:** none · **Validation:** battery+check

## 1. Problem statement
Narrowing or redirecting an approved story or spec after a gate finding or a review is done by
hand today. Both 2c narrowings were improvised, each with its own fate table: part 1 on 2026-10-02
(`docs/superpowers/stories/2026-10-02-run-analytics-trace-id-and-retention-story.md`) and part 2
on 2026-10-03 (`docs/superpowers/stories/2026-10-02-review-loop-usefulness-assessment-story.md`).
Nothing tells the author which reason class applies, which acceptance criteria are touched, which
earlier conditions survive, how the scope boundary moved, which other artifacts now disagree, or
what the change costs reviews already run. A condition dropped this way looks exactly like text
that was never there (AGENTS.md).

## 2. Desired outcome
The existing `sparring` and `intake` workflow carries a bounded procedure for changing an approved
story or spec. Every change it produces is dated, has a rationale, names its reason class, accounts
for every earlier condition, states the new scope boundary and the questions it leaves open, names
the artifacts it makes stale, and states what it costs the reviews already run by pointing at the
existing gate rules. The human keeps every decision, without a new routine approval step; the
procedure only makes the decision complete and visible. Each session keeps its role: sparring
prepares the change and the handoff, the coding session updates the development artifacts.

## 3. Acceptance criteria
_IDs are permanent once the story is committed: never renumber or reuse one; a new criterion takes the next number unused here and on the branch it merges into, and a collision stops for a human; a removed one stays, struck through and dated; a narrowed one keeps its ID with a dated note; cite as `<story path> AC-<n>`; full rules: dev-workflow:intake, "Acceptance-criterion IDs"._
- [ ] **AC-1** A change record is dated, carries its rationale, and names exactly one reason class:
      a changed requirement, a gap the implementation or a review discovered, or a change of
      direction.
- [ ] **AC-2** A change record cites every affected acceptance criterion in intake's existing
      citation form and states its new state under intake's existing ID rules; for a story
      without identifiers it follows intake's existing rules for older stories (identifiers adopted
      at the first amendment, citations by story path and quoted criterion text). It introduces no
      citation or numbering rule of its own.
- [ ] **AC-3** A change record lists every earlier condition of the changed text as kept, moved
      (with its destination) or deliberately dropped (with a reason); a condition left unmarked is
      visible as a gap rather than silently lost.
- [ ] **AC-4** A change record states the changed scope boundary (what moved in or out) and the
      open questions the change leaves, each with where it is recorded.
- [ ] **AC-5** A change record names the dependent artifacts the change makes stale (spec, plan,
      todos, vision or other stories). For each it says whether it is updated in the same change
      or recorded as open; recording it as open is allowed only where the existing rules permit
      it, and otherwise the dependent continuation stays blocked until the artifact is updated.
- [ ] **AC-6** A change record states the consequence for reviews already run by citing the
      existing `.claude/review-gates.md` rules that decide it (for example a further pass or a new
      cycle); it adds no gate rule, approval level or exemption of its own.
- [ ] **AC-7** No new routine approval step: an existing explicit human decision suffices as far as
      it covers the documented change; any new or undecided scope question is put to the human
      before implementation; and nothing resumes a gate, a plan or an implementation automatically
      after a change.
- [ ] **AC-8** The session roles stay as the skills define them: sparring prepares the change
      record and the handoff and changes no files, and the coding session updates the development
      artifacts.
- [ ] **AC-9** Replayed on the two recorded 2c narrowings, the procedure reproduces their fate
      tables (every row and its fate) and names the dependent artifacts each one changed; any row it
      cannot reproduce is reported as a difference, not hidden.
- [ ] **AC-10** Out of scope and absent from the change: a separate skill, new approval levels,
      dashboard or live-view work, and any part of the 2c part-4b calibration.

## 4. Affected AGENTS.md invariants
- `## Don'ts` — "**Never replace a decision procedure without accounting for its old conditions.**
  List what the previous prose required, then mark each one kept, moved, or deliberately dropped."
- `### Prompts and scaffolding` — "11. **Prompt changes pass `docs/prompt-standards.md`** — all 12
  checklist items, for any skill, command, agent definition, hook message, or scaffolded template."
- `### Packaging` — "12. **A plugin change requires a version bump.**"

## 5. Open questions
- 2c part 3 (`scripts/spec-delta.py`) records the mechanical change to a spec after its Gate-A
  cycle closed. Should the change record point at that report when one exists? (todos.md: G1a
  feeds part 3 and does not compete with it. Reviewer preference, 2026-10-05: an optional evidence
  link, with no new dependency. Settled in design.)

## 6. Suggested size
story — one procedure in two existing skills, fits one spec → plan → PR.
