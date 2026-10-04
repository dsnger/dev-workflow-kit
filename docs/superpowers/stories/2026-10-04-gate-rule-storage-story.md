# Gate-rule storage within the instruction-size limit — Story

**Date:** 2026-10-04 · **Size:** story
**Risk:** high · **Security:** none · **Validation:** battery+check+verification

## 1. Problem statement
Claude Code limits the instruction files it loads (CLAUDE.md, AGENTS.md and what they load) to
150.0k characters in total. This repository exceeded it on `main` at `b18e7db`, measured by Daniel
on 2026-10-04: "2 instruction files add up to 151.2k chars · CLAUDE.md (127.8k), AGENTS.md (23.4k)".
The cause is CLAUDE.md §5, the cross-model review gates, at about 123.5k of CLAUDE.md's 127.8k.

It is a plugin problem, not only this repository's. `/workflow-init` scaffolds §5 inline: the
`### 2.1` CLAUDE.md template in `plugins/dev-workflow/commands/workflow-init.md` is about 127.7k
characters (Daniel's measurement). So an initialized project starts near the limit before its own
AGENTS.md and rules, and most will exceed it on the first day. §5 grows with every field-minted
rule, so the problem gets worse.

A branch in this repository, `split-review-gates` (another session; PR #38, open on 2026-10-04),
moves §5 word for word to `.claude/review-gates.md` and leaves a pointer in CLAUDE.md, for this
repository only. The scaffolded template is unchanged, so downstream projects still get §5 inline.

## 2. Desired outcome
The gate rules reach an agent reliably at every moment they govern — a gate pass, resuming or
closing a cycle, a commit, preparing a merge, and deciding that a change needs no gate — while the
always-loaded instruction files of this repository and of every initialized project stay well
inside the size limit. There is exactly one definition of the rules in each project, the hook and
the checks still find them, and projects already initialized with an inline §5 get a migration path
that never overwrites silently.

## 3. Acceptance criteria
_IDs are permanent once the story is committed: never renumber or reuse one; a new criterion takes the next number unused here and on the branch it merges into, and a collision stops for a human; a removed one stays, struck through and dated; a narrowed one keeps its ID with a dated note; cite as `<story path> AC-<n>`; full rules: dev-workflow:intake, "Acceptance-criterion IDs"._
- [ ] **AC-1** A freshly initialized project's always-loaded instruction files, before any
      project-specific content, are below a stated size budget well under 150.0k characters, and a
      mechanical check fails when the scaffolded template exceeds it.
- [ ] **AC-2** At each moment the gate rules govern (a gate pass, resuming or closing a cycle, a
      commit, preparing a merge, a no-gate decision), an agent is directed to the full rules, and a
      verification shows that the direction is followed in practice.
- [ ] **AC-3** Each project holds exactly one definition of the gate rules. No storage state leaves
      a project with two definitions or none, including partially migrated ones (§5's
      partial-adoption contract).
- [ ] **AC-4** A project initialized with an inline §5 is offered a migration by `/workflow-init`
      that shows the difference and asks, and never overwrites silently (invariant 9).
- [ ] **AC-5** The hook's adoption and citation checks, its prompt-path classification, and check
      4c in `scripts/check-invariants.sh` follow the new location. An edit to the gate rules still
      fires full Gate B wherever they live.
- [ ] **AC-6** The hook keeps exiting 0 on every branch (invariant 1), and nothing depends on the
      plugin's cache path (invariant 8).
- [ ] **AC-7** The gate rules' content is unchanged by the move. Shrinking §5 is a separate later
      step under "Never replace a decision procedure without accounting for its old conditions".

## 4. Affected AGENTS.md invariants
- `### Hook` — "1. **The hook always exits 0.**"
- `### Hook` — "2. **Loose in the firing direction.**"
- `### Packaging` — "12. **A plugin change requires a version bump.**"
- `### Prompts and scaffolding` — "8. **`/workflow-init`'s templates stay inline** in the command body."
- `### Prompts and scaffolding` — "9. **`/workflow-init` never overwrites silently.**"
- `### Prompts and scaffolding` — "11. **Prompt changes pass `docs/prompt-standards.md`**"

## 5. Open questions
- Where do the rules live? Three options to compare:
  - a scaffolded file such as `.claude/review-gates.md`, copied per project (it can drift, and
    invariant 9's idempotency rules apply);
  - a skill shipped in the plugin (for example `dev-workflow:review-gates`), loaded when a gate
    runs: one versioned copy and no drift, if it loads reliably at every governing moment;
  - a split: a short always-loaded core in CLAUDE.md, with the detail on demand.
  Daniel leans towards the shipped skill, subject to proof that it loads reliably.
- Can the hook's reminders name what to load, within invariants 1 and 8 (`${CLAUDE_PLUGIN_ROOT}`
  does not expand in command markdown)?
- Do `gate_citation` and `is_adopted` keep grepping CLAUDE.md's `Cross-Model Review` heading, or
  move to the `.context/codex-gate.on` marker?
- What size budget does the check enforce (for example 20k for the scaffolded CLAUDE.md)?
- How does this relate to the `split-review-gates` branch (PR #38): merged first as this
  repository's interim fix, or superseded?

## 6. Suggested size
story — one storage change across the template, the hook's classification and checks, and a
migration path; one spec → plan → PR with a version bump. Shrinking §5 is a separate later story.
