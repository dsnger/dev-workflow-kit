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

**Requires `AGENTS.md`** (the project's invariants file) — the Flow's invariant-tagging
step greps it, and story Section 4 quotes what it finds. If the
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
3. **Assess the profile** — derive a proposal for two axes and a validation mode, so
   the single question round below can carry it. Nothing is recorded yet:
   - **Risk** — `trivial` (no behavioural effect in the artifact's own execution
     context; for a **prompt artifact the text is the behaviour**, so a wording change
     to a skill, command, agent definition, hook message or template is not trivial by
     default) · `standard` (a behaviour change hitting no named trigger — the default)
     · `high` (the change affects a named **domain** trigger — auth, permissions,
     payments, migrations, data deletion, public APIs, personal data, supply chain — or
     a named **effect** trigger — irreversibility, data loss or corruption, outage
     exposure).
   - **Security relevance** — `none` (touches no asset, trust boundary, role or
     external system — a real answer and the common one) · `standard` (touches one
     without changing what it permits) · `high` (changes a trust boundary, an
     authorization decision, or the handling of secret or personal data).
   - **Validation mode**, *derived not asked*: effective level = `max(risk, security)`
     over `none|trivial → 0`, `standard → 1`, `high → 2` → `battery` /
     `battery+check` / `battery+check+verification`, plus `+abuse-path` when and only
     when security is `high`.

   Triggers match **surfaces, not words**: a doc that mentions auth is not `high`; a
   change to an authorization decision is `high` even if the word never appears.

   Carry all three into the next step's question round with one line of reason each.
4. **One question round, then pause** — ask at most one round, then **wait** for
   the user; a later turn resumes with their answers. Do not proceed on silence —
   this bounds the interaction without barrelling past an unanswered question.

   The round also carries the **profile proposal** from step 3 — alongside any
   clarifying questions, or as the whole round when nothing needs clarifying. Intake
   gains no second pause. The human confirms or corrects, and what a correction means
   depends on what it touches:
   - **An axis correction sets that axis freely, up or down — and the mode is
     recomputed** from the corrected axes. Never carry the proposed mode over beside a
     changed axis: `**Security:** high` next to `**Validation:** battery` is a header
     the gates classify as unresolvable and stop on.
   - **A mode correction is an override**, and it is bounded: it may raise or lower the
     derived mode, but it cannot drop `+abuse-path` while security is `high`. Record it
     as the first `mode override` entry in the profile log, with its direction and the
     human's reason. **Say in the proposal that an override needs a reason**, since the
     log entry cannot be written without one.

   **State the derivation in the proposal, so one answer settles the whole header.** The
   mode is a function of the axes, not an independent choice: show `max(risk, security)`
   and what each level yields, and the human's single answer then confirms the axes, any
   override, *and* the mode that derivation produces from them — including after a
   correction. That is why no second pause is needed and none is taken: nothing is left
   for the human to choose once the axes are settled.

   **An answer that cannot be recorded ends this intake attempt** — an override with no
   reason, an override dropping `+abuse-path` while security is `high`, a mode outside the
   enums. Say which rule the answer collides with and **stop without writing**; do not
   hold a pause open waiting for a repair, and do not invent the missing piece. This is
   the grounding floor's shape, and it is honest about what happens next: the human's
   corrected answer arrives at a **new intake run**, which opens its own single round with
   that answer already in hand. What is forbidden is a second round *inside* one run, not
   the human coming back.

   "Proceed anyway" or "I don't know" **is** an answer: it accepts the proposal as it
   stands, and the values are recorded as proposed and **never lower** — a redundant lens
   costs a paragraph, a missing one costs a review. There is no "unconfirmed" profile, so
   the story is not written until the profile is settled.
5. **Apply the grounding floor** — once answered (or the user says "proceed
   anyway" / "don't know"), **stop without writing** if the problem statement, the
   desired outcome, or at least three grounded checkable acceptance criteria still
   can't be derived from the input without padding; report what's missing, quoting
   the thin part. A fabricated story launders guesses into a reviewed-looking
   artifact — stopping with "too thin: needs X" is the honest outcome. Genuine
   detail gaps instead become Open questions.
6. **Tag invariants by grepping AGENTS.md** (not from memory — memory drifts;
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
7. **Assess size** — `chore` / `story` / `epic-needs-splitting` per the template's
   calibration, so sizing stays consistent across runs.
8. **Draft the story** from the template below (in your response — nothing on disk
   yet).
9. **Present and wait** — show the draft and wait. On requested edits, apply them,
   **re-validate the edited draft against every constraint** (six sections, the
   profile header line, no-HOW except §4, grounding floor, ≥3 checkable criteria), and
   re-present. Never commit unseen or edit-broken text; a user edit can accidentally
   introduce HOW or drop a section.
10. **On approval, write and commit** — write the **exact approved text** to the
    computed path (see *Writing the story file*), immediately before staging, then
    commit via the commit protocol. Writing only after approval means the staged
    bytes are, by construction, what the user saw.
11. **Hand off** — name the next step and stop. intake's job ends at capture.

## Story template

Write the file with exactly these six `##` sections, in order:

```markdown
# <Title> — Story

**Date:** YYYY-MM-DD · **Size:** chore | story | epic-needs-splitting
**Risk:** trivial | standard | high · **Security:** none | standard | high · **Validation:** <derived mode>

<!-- Profile log: omit this whole block until the first change. On the first one: -->
**Profile log:**
- YYYY-MM-DD · axis change · risk ↑ · Gate-B pass 2 finding on the migration path · adds the risk lens set

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

**Profile log.** A `**Profile log:**` label directly beneath the profile header, followed
by `-` entries — written **on the first change and never before**, so a story whose
profile never moves carries no empty block. One line per event: date · **event kind** ·
**direction** · **reason or trigger** (a finding reference when a finding caused it, plain
prose when none did) · what it changes downstream. The three kinds:

- `axis change` — names the **axis identity** (`risk`, `security`, or both in one entry
  when both move) and a **direction per named axis**, since both may move at once and in
  opposite directions:
  `- 2026-07-26 · axis change · risk ↑, security ↓ · pass-3 finding: the job truncates a table irreversibly, and the auth surface it appeared to touch is unreachable · adds the risk lens set, drops the security lens set`
- `mode override` — names its own **direction**, because a human may raise or lower the
  derived mode. A lowering removes an obligation, so its reason says which one and why:
  `- 2026-07-26 · mode override · ↓ · the risk-path verification duplicates the migration rehearsal already run in staging · drops the named verification, keeps the counterfactual check`

  Choosing a **named verification** because no automated test is possible is **not** an
  override: it is one of the two routes that satisfy `+check` at the same mode, and it
  still owes the counterfactual. Logging it as a lowering would record a mode the header
  never moved to.
- `adoption` — has no previous value, so **no direction**:
  `- 2026-07-26 · adoption · in-flight story adopting a profile at its plan checkpoint · gates now read this header`

The log never restates the values — the header is the single writable copy, and git
history already holds what the previous values were. A mode override chosen during intake
confirmation is the first `mode override` event and creates the log.

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
