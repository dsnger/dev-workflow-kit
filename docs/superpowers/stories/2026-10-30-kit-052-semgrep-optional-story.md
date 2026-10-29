# Kit 0.52: Semgrep OSS, optional per project — Story

**Date:** 2026-10-30 · **Size:** story · **Checkpoints:** none
**Risk:** high · **Security:** standard · **Validation:** battery+check+verification

## 1. Problem statement
With Codex Gate B as the only reviewer in kit projects (Daniel, 2026-10-29), every security check is a model
judgement; nothing deterministic in the quality command looks for known insecure patterns. Order:
`.context/sparring/20261029-1810-kit-051-codex-review-prompt.md`, item 5. Split from
`2026-10-30-kit-051-codex-review-story.md`. Risk is `high` because the change adds a tool that runs in every
project that turns it on (supply chain).

## 2. Desired outcome
A project can turn on Semgrep OSS as a deterministic step of its quality command. When on, the step is
reproducible and offline, a finding can be silenced only with a stated reason, and the set of accepted findings can
only shrink. Projects that do not turn it on are unchanged.

## 3. Acceptance criteria
_IDs are permanent once the story is committed: never renumber or reuse one; a new criterion takes the next number unused here and on the branch it merges into, and a collision stops for a human; a removed one stays, struck through and dated; a narrowed one keeps its ID with a dated note; cite as `<story path> AC-<n>`; full rules: dev-workflow:intake, "Acceptance-criterion IDs"._
- [ ] **AC-1** `/workflow-init` asks whether the project wants Semgrep, default no; a no changes nothing in the
  project.
- [ ] **AC-2** When on, the quality command runs Semgrep at an exactly pinned version with rules that are part of
  the project, without network access at run time.
- [ ] **AC-3** A suppression without a stated reason fails the step.
- [ ] **AC-4** A baseline of accepted findings exists; a new finding outside it fails the step, and the baseline
  can be changed only by removing entries.
- [ ] **AC-5** Version bump; CHANGELOG, README and docs updated; the quality command is green.

## 4. Affected AGENTS.md invariants
- `## Key invariants` / Packaging — "5. **Every version pinned exactly.**"
- `## Key invariants` / Prompts and scaffolding — "8. **`/workflow-init`'s templates stay inline** in the command body."
- `## Key invariants` / Prompts and scaffolding — "9. **`/workflow-init` never overwrites silently.**"
- `## Key invariants` / Prompts and scaffolding — "11. **Prompt changes pass `docs/prompt-standards.md`**"
- `## Key invariants` / Packaging — "12. **A plugin change requires a version bump.**"

## 5. Open questions
- None.

## 6. Suggested size
story — one optional step with its own contract; it starts after 0.51 merges (handover boundary).
