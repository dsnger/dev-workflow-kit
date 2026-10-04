# Stable acceptance-criterion IDs (P5 light) — Story

**Date:** 2026-10-04 · **Size:** story
**Risk:** standard · **Security:** none · **Validation:** battery+check

## 1. Problem statement
Acceptance criteria in a story are an unnumbered checkbox list. Plans, specs, gate calls, commit
evidence and fate tables refer to them by position ("criterion 4") or re-describe them. A position
breaks as soon as a criterion is added, removed or narrowed. The 2c stories show it: their fate
tables had to name criteria by number while the list beneath them was being rewritten. `todos.md`
records this as P5 light, and its trigger — a story that runs under profiles — has been met
(Daniel, 2026-10-04, on `.context/sparring/20261004-101100-pr37-merge-and-p5-assessment.md`).

## 2. Desired outcome
Every acceptance criterion a story is written with carries an identifier that stays the same for
the story's whole life. A plan, a spec, a gate call or a commit can cite a criterion by its
identifier, and the citation still points at the same criterion after the list changes. This is the
light version: identifiers only. The per-criterion evidence view (`todos.md` G1b) and vision leaf
4e's safeguards are not part of it.

## 3. Acceptance criteria
- [ ] **AC-1** The story template that `dev-workflow:intake` writes gives every acceptance
      criterion an identifier of the form `AC-<n>`, numbered from 1 in the order written.
- [ ] **AC-2** The intake instructions state that an identifier is never renumbered or reused: a
      new criterion takes the next unused number, a removed criterion keeps its line marked as
      withdrawn with a date, and a narrowed criterion keeps its identifier with a dated note.
- [ ] **AC-3** The intake instructions say where identifiers are cited: plans, specs, gate calls,
      evidence entries and fate tables cite `<story path> AC-<n>` rather than a position or a
      paraphrase.
- [ ] **AC-4** A story written before this change is not rewritten; the instructions say how a
      later amendment adopts identifiers for it.
- [ ] **AC-5** A check demonstrates the template and rules on a fixture or a worked example: an
      inserted, a removed and a narrowed criterion keep every other identifier unchanged.
- [ ] **AC-6** No gate rule, pass rule, record format or evidence-entry format changes, and nothing
      outside the intake skill and its documentation claims more than identifiers.

## 4. Affected AGENTS.md invariants
- `### Packaging` — "12. **A plugin change requires a version bump.**"
- `### Prompts and scaffolding` — "11. **Prompt changes pass `docs/prompt-standards.md`**"
- `### Packaging` — "5. **Every version pinned exactly.**"

## 5. Open questions
- ~~One sequence or a separate `SEC-<n>` one?~~ Decided 2026-10-04 (Daniel): one sequence,
  `AC-<n>`, for every criterion; a criterion's security origin shows in its text.
- Does `/workflow-init`'s scaffolded `CLAUDE.md` mention criteria anywhere that should cite
  identifiers, or is the intake skill the only site?

## 6. Suggested size
story — one shipped skill's template and rules, plus documentation; one spec → plan → PR, with a
version bump.
