# intake — capture a new story (the Flow)

Target model: Claude via Claude Code. This file is a prompt artifact and follows the
checklist in `docs/prompt-standards.md`. The `intake` skill (`SKILL.md` in this directory)
sends you here once it has chosen this route; the story template, the size calibration,
the acceptance-criterion ID rules and the profile log this route uses are in `SKILL.md`.

Contents: Flow (steps 1–11) · Writing the story file · Stop and ask · Hand-off.

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
7. **Assess size** — `chore` / `story` / `epic-needs-splitting` per the size
   calibration in `SKILL.md`, so sizing stays consistent across runs.
8. **Draft the story** from the story template in `SKILL.md` (in your response —
   nothing on disk yet).
9. **Present and wait** — show the draft and wait. On requested edits, apply them,
   **re-validate the edited draft against every constraint** (six sections, the
   profile header line, no-HOW except §4, grounding floor, ≥3 checkable criteria, the
   criteria reading `AC-1 … AC-k` in order under the italic ID rule line), and
   re-present. Never commit unseen or edit-broken text; a user edit can accidentally
   introduce HOW or drop a section.
10. **On approval, write and commit** — write the **exact approved text** to the
    computed path (see *Writing the story file*), immediately before staging, then
    commit via the commit protocol. Writing only after approval means the staged
    bytes are, by construction, what the user saw.
11. **Hand off** — name the next step and stop. intake's job ends at capture.

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

These stops belong to the Flow. The amendment route's stops are in its own steps
(`amend-approved-artifact.md`); **No AGENTS.md** applies to both routes and is stated in
`SKILL.md`.

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
