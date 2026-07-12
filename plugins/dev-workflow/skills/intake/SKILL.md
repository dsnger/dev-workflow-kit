---
name: intake
description: Use at the very start of the workflow, when a raw idea, voice transcript (German or English), or backlog line needs capturing before superpowers:brainstorming. Use before design begins — not after an approved story or spec exists, and not to design the solution.
---

# intake

## Overview

The front door of the spec-driven workflow. A raw idea or voice transcript goes
in; a reviewable **story artifact** comes out at
`docs/superpowers/stories/YYYY-MM-DD-<topic>-story.md` and feeds
`superpowers:brainstorming` as its input document. This standardizes an entrance
that otherwise varies by whoever writes the prompt.

intake captures **WHAT and WHY, never HOW** — designing the solution is
brainstorming's job. That boundary governs every story section **except
Section 4** (Affected AGENTS.md invariants), which quotes *existing* project
invariants verbatim as constraints the future solution must respect. Naming a
guardrail the solution has to honor is not designing it — so "auth via the
project's `requireAuth` barrier" belongs in Section 4, while "add a `requireAuth`
call to the new handler" is a HOW leak anywhere else.

Target model: Claude via Claude Code. This skill is a prompt artifact and follows
the checklist in `docs/prompt-standards.md`.

**Requires `AGENTS.md`** (the project's invariants file) — Section 5 greps it. If the
repo has none, say so and offer `/dev-workflow:workflow-init`, which walks you
through writing one.

## When to use

- A raw idea or voice transcript arrives and needs to enter the workflow, before
  any brainstorming — so the entrance is consistent regardless of author.
- A backlog line needs to become a reviewable story before design starts.

Not for designing a solution (that's `superpowers:brainstorming`), and not for
items that already have an approved story/spec or have moved into solution design.

## Flow

Follow in order. Each step names why it exists.

1. **Read the input** — the idea or transcript (German or English). The story you
   write is in English (the codebase and AGENTS.md language), preserving domain
   terms the user used verbatim where meaning matters — so downstream grep and
   consistency hold even for German input.
2. **Detect ambiguity** — if any of the six story sections can't be filled from
   the input without guessing (most often vague acceptance criteria or an unclear
   outcome), ask targeted questions first — surface gaps rather than filling them
   silently (CLAUDE.md §1).
3. **One question round, then pause** — ask at most one round, then **wait** for
   the user; a later turn resumes with their answers. Do not proceed on silence —
   this bounds the interaction without barrelling past an unanswered question.
4. **Apply the grounding floor** — once answered (or the user says "proceed
   anyway" / "don't know"), **stop without writing** if the problem statement, the
   desired outcome, or at least three grounded checkable acceptance criteria still
   can't be derived from the input without padding; report what's missing, quoting
   the thin part. A fabricated story launders guesses into a reviewed-looking
   artifact — stopping with "too thin: needs X" is the honest outcome. Genuine
   detail gaps instead become Open questions.
5. **Tag invariants by grepping AGENTS.md** (not from memory — memory drifts;
   AGENTS.md is the single source of truth):
   - extract the idea's domain terms **in English** (translate German first —
     `Einladung`→invitation, `Rechnung`→invoice — and add synonyms and the verb's
     noun form), because a literal German-noun grep would miss every invariant;
   - `grep -inF -- "<term>" AGENTS.md` for each (fixed-string, so multi-word terms
     and regex metacharacters match literally);
   - also skim the `## Section`(s) the change plausibly touches (e.g. anything
     permission-related → the roles/ACL section), since a concept can live under a
     heading no single noun matches;
   - cite each real match's `## Section` heading and quote the specific bullet
     line(s); if nothing matches, record "No AGENTS.md invariants matched" — an
     explicit negative, not a silently empty section.
6. **Assess size** — `chore` / `story` / `epic-needs-splitting` per the template's
   calibration, so sizing stays consistent across runs.
7. **Draft the story** from the template below (in your response — nothing on disk
   yet).
8. **Present and wait** — show the draft and wait. On requested edits, apply them,
   **re-validate the edited draft against every constraint** (six sections,
   no-HOW except §4, grounding floor, ≥3 checkable criteria), and re-present. Never
   commit unseen or edit-broken text; a user edit can accidentally introduce HOW or
   drop a section.
9. **On approval, write and commit** — write the **exact approved text** to the
   computed path (see *Writing the story file*), immediately before staging, then
   commit via the commit protocol. Writing only after approval means the staged
   bytes are, by construction, what the user saw.
10. **Hand off** — name the next step and stop. intake's job ends at capture.

## Story template

Write the file with exactly these six `##` sections, in order:

```markdown
# <Title> — Story

**Date:** YYYY-MM-DD · **Size:** chore | story | epic-needs-splitting

## 1. Problem statement
<What's wrong or missing today, in the user's terms.>

## 2. Desired outcome
<The WHAT and WHY of the change — an observable result, no solution design.>

## 3. Acceptance criteria
- [ ] <Observable outcome or constraint, checkable true/false by a reviewer.>
- [ ] <…>
- [ ] <… at least three.>

## 4. Affected AGENTS.md invariants
- `## <Section>` — "<quoted bullet line the change would touch>"
<or, if none: "No AGENTS.md invariants matched">

## 5. Open questions
- <Unresolved requirement question — not a design choice.>
<or, if none remain: "- None.">

## 6. Suggested size
<chore | story | epic-needs-splitting> — <one-line justification>
```

**Size calibration:** `chore` = one obvious change, no new decisions (a rename, a
copy tweak); `story` = a single coherent feature, fits one spec → plan → PR;
`epic-needs-splitting` = multiple independent subsystems or more than one spec's
worth — name the suggested split.

**Acceptance criteria** describe observable outcomes or constraints, never
implementation steps (WHAT is true when done, not how it's built).

## Writing the story file

**Path:** `docs/superpowers/stories/YYYY-MM-DD-<topic>-story.md`, where
`YYYY-MM-DD` is the local project date (use the same source for the hand-off text,
so they never disagree). Create the `docs/superpowers/stories/` directory if it
doesn't exist yet.

**Slug (`<topic>`, deterministic):** lowercase → transliterate umlauts/accents
(`ä`→`ae`, `ö`→`oe`, `ü`→`ue`, `ß`→`ss`, strip other diacritics) → replace every
non-`[a-z0-9]` run with a single hyphen → trim leading/trailing hyphens → cap at
40 chars, trimming to the last whole word (if a single token already exceeds 40,
hard-truncate it to 40, then re-trim). Empty result → `story`. This keeps German
and free-form input from producing broken filenames.

**Preserve existing files:** if the target path exists, append `-2`, `-3`, …
until free, recomputing immediately before writing, so two same-day same-topic
ideas don't clobber each other.

**Commit protocol** (keeps the commit genuinely docs-only, so Codex Gate B is
legitimately N/A per CLAUDE.md §5):

1. Run `git status`; if the index **already has staged changes**
   (`git diff --cached --name-only` is non-empty before you stage), stop and ask —
   don't build a commit on top of unrelated staged work.
2. Stage **only** the story file (`git add <path>`), never `git add -A`, so no
   unrelated working-tree change gets swept in.
3. Verify the staged set is exactly that one story path
   (`git diff --cached --name-only`) **and** its staged content matches the
   approved draft — `git show :<path> | diff - <path>` prints nothing. On any
   other path or a non-empty diff, `git restore --staged <path>` and stop,
   leaving the index as you found it.
4. Commit with `docs(intake): add <topic> story`.

## Stop and ask

- **One-round pause:** after asking clarifying questions, wait for the user rather
  than proceeding on silence.
- **Grounding floor:** stop without writing when the problem, the outcome, or ≥3
  checkable criteria can't be grounded — report what's missing instead of inventing
  or padding. Report shape:

  > Too thin to capture as a story yet. I can ground the problem ("<quote>"), but
  > the desired outcome and acceptance criteria aren't in the input. Tell me: what
  > should be true when this is done? Then I'll write the story.
- **Dirty or unexpected index:** stop if the index already had staged changes, or
  if any path other than the story file (or a content mismatch) appears at commit.
- **No AGENTS.md:** stop and offer `/dev-workflow:workflow-init` — Section 4 is
  ungroundable without it.
- **No `superpowers:brainstorming`:** the hand-off target is missing. Still write and
  commit the story (it is valuable on its own, and the user is one install away), then
  **stop and say the next step cannot run**, rather than pointing at a skill that does
  not exist:

  > Story written: `docs/superpowers/stories/<file>`.
  >
  > The next step, `superpowers:brainstorming`, is not available — the superpowers
  > plugin is a prerequisite of this workflow and is not installed. Install it, then
  > run brainstorming with this story as its input document:
  >
  > `claude plugin marketplace add obra/superpowers-marketplace`
  > `claude plugin install superpowers@superpowers-marketplace`

## Hand-off

Check that `superpowers:brainstorming` is actually available to you before naming it
(see *Stop and ask*). If it is, end by naming the next step, and stop:

> Next: `superpowers:brainstorming` with `docs/superpowers/stories/<file>` as the
> input document.

Do not invoke brainstorming yourself, and do not start designing a solution —
intake captures WHAT and WHY; brainstorming decides HOW.

## Common mistakes

- Designing a solution (HOW) anywhere outside Section 4.
- Tagging invariants from memory instead of grepping AGENTS.md.
- Looping past one question round instead of pausing for the user.
- Padding to reach three acceptance criteria when the idea can't ground them.
- Committing with `git add -A`, or committing text the user hasn't approved.
- Leaving Section 4 or the invariants empty instead of the explicit "No AGENTS.md
  invariants matched".
