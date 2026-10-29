# Kit 0.51: a stronger Codex review — Story

**Date:** 2026-10-30 · **Size:** story · **Checkpoints:** none
**Risk:** standard · **Security:** standard · **Validation:** battery+check

## 1. Problem statement
Greptile runs only on request and CodeRabbit is removed (Daniel, 2026-10-29), so Codex Gate B is the only reviewer
in every kit project. Gate B today sends a diff range and a findings format to the Codex MCP server's built-in
reviewer template: it brings no kit-specific review method, runs no tests, has no instruction to trace callers and
dependents of a change, and reviews a change to the project's own scripts or gate rules with the same effort as any
other diff. Bots found real defects on kit PRs after Gate B had closed. Daniel's requirement: the review stays
reliable "in every respect and in its knowledge of the whole codebase". Order:
`.context/sparring/20261029-1810-kit-051-codex-review-prompt.md` (items 1–4 and 6; item 5, Semgrep, is the story
`2026-10-30-kit-052-semgrep-optional-story.md`). D84 (Daniel, 2026-10-29 18:05): the kit builds its own review
skill; nothing is copied from sfx-factory.

## 2. Desired outcome
Every Gate B pass in a kit project reviews with a kit-owned method: it checks the change against the spec's
acceptance criteria and the project's invariants, follows failure paths and the callers and dependents of each
changed symbol, may run targeted tests of the touched code and reports their result, and a risky change gets one
deeper pass. The kit shows, on its own history, how many bot-caught defects the new review finds.

## 3. Acceptance criteria
_IDs are permanent once the story is committed: never renumber or reuse one; a new criterion takes the next number unused here and on the branch it merges into, and a collision stops for a human; a removed one stays, struck through and dated; a narrowed one keeps its ID with a dated note; cite as `<story path> AC-<n>`; full rules: dev-workflow:intake, "Acceptance-criterion IDs"._
- [ ] **AC-1** A kit review skill exists that Gate B tells Codex to use; it names what to check (the spec's
  acceptance criteria, the project's AGENTS.md invariants, failure paths, callers and dependents) and requires the
  findings format of `.claude/review-gates.md`. Where it lives and how Codex loads it is verified against the
  installed Codex CLI and MCP server, with the evidence recorded.
- [ ] **AC-2** Nothing is written under the user's home directory by an agent or silently by `/workflow-init`; any
  such step is offered by `/workflow-init` and listed as a human action. Every version the change introduces is
  pinned exactly (invariant 5).
- [ ] **AC-3** The reviewer may run targeted tests of the touched modules in a disposable copy of the repository,
  offline, without secrets, with a time limit, cleaned up on every exit, and without `git worktree add`; the result
  of each run (command, exit status, duration) or the concrete reason no test ran appears in the review's findings
  or reply.
- [ ] **AC-4** The reviewer traces callers and dependents of every changed symbol. Agents never index with
  codebase-memory (D79); a current index is used where one exists, otherwise direct search, and the human refresh
  command is reported.
- [ ] **AC-5** A change touching the project's own scripts, security-relevant code, rule or gate files, or
  migrations gets one extra Codex pass with high reasoning effort and an edge-case/failure-path prompt; the gate
  rules say how that pass counts within the 0.46 Gate B caps for `lean`, `strict` and `classic`.
- [ ] **AC-6** Proof before merging: the new review runs on at least 6 historical dev-workflow-kit PRs where a bot
  (Greptile or CodeRabbit) found a real issue the old Gate B missed (or on every such case, with the count, when
  fewer than 6 exist); the report gives found/not found per case (target at least 4/6), the duration and the
  Codex calls per review, and sits where a reader can set it beside sfx-factory's numbers.
- [ ] **AC-7** Version 0.51.0; CHANGELOG, README and docs updated; the quality command is green.

## 4. Affected AGENTS.md invariants
- `## Key invariants` / Packaging — "5. **Every version pinned exactly.**"
- `## Key invariants` / Packaging — "The fourth applies to **the optional codebase-memory MCP integration only**"
- `## Key invariants` / Prompts and scaffolding — "8. **`/workflow-init`'s templates stay inline** in the command body."
- `## Key invariants` / Prompts and scaffolding — "9. **`/workflow-init` never overwrites silently.**"
- `## Key invariants` / Prompts and scaffolding — "11. **Prompt changes pass `docs/prompt-standards.md`**"
- `## Key invariants` / Packaging — "12. **A plugin change requires a version bump.**"
- `## Architecture` / Boundaries — "6. The plugin depends on superpowers (skills it hands off to) and on a Codex MCP server
  exposing both `exec` and `review` (the gates key on those two tool names)."
- `## Don'ts` — "**Never describe what a gate proves without checking what it actually compares.**"

## 5. Open questions
- None.

## 6. Suggested size
story — one coherent change to how Gate B reviews; Semgrep (order item 5) is split into its own story because it is
an independent deterministic step with its own dependency and contract.
