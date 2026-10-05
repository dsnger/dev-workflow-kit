---
name: intake
description: Use at the very start of the workflow, when a raw idea, voice transcript (German or English), or backlog line needs capturing before superpowers:brainstorming — or later, when an approved story or spec must change after a decision to change it, to write a change record that accounts for every earlier condition. Not for designing the solution.
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
- An approved story or spec must change after a human decided to change it — narrowed,
  redirected, or corrected for a gap found later. Use the separate route *Amending an
  approved story or spec* below, not the Flow.

Not for designing a solution (that's `superpowers:brainstorming`), and not for starting a
new story for an item that already has an approved one; an approved artifact changes
only through the amendment route.

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
   profile header line, no-HOW except §4, grounding floor, ≥3 checkable criteria, the
   criteria reading `AC-1 … AC-k` in order under the italic ID rule line), and
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
_IDs are permanent once the story is committed: never renumber or reuse one; a new criterion takes the next number unused here and on the branch it merges into, and a collision stops for a human; a removed one stays, struck through and dated; a narrowed one keeps its ID with a dated note; cite as `<story path> AC-<n>`; full rules: dev-workflow:intake, "Acceptance-criterion IDs"._
- [ ] **AC-1** <Observable outcome or constraint, checkable true/false by a reviewer.>
- [ ] **AC-2** <…>
- [ ] **AC-3** <… at least three.>

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

**Acceptance-criterion IDs.** Every criterion carries an identifier, `AC-<n>`, so that a
plan, a spec, a gate call or a commit can cite it and still mean the same criterion after
the list changes. The italic line under §3 travels with every story and carries these
rules in short, because later amendments happen where this skill does not run.

1. **Fixed at commit, free before.** While the draft is shown and edited (steps 8–9),
   renumber freely, so the draft always reads `AC-1 … AC-k` in order. Identifiers become
   permanent when the approved story is committed (step 10).
2. **After commit: never renumbered, never reused** — the one exception is a renumbering
   a human decides under rule 3. In any later amendment:
   - a **new** criterion takes the next unused number, wherever it is placed in the list;
   - a **removed** criterion keeps its line, struck through, with a dated reason:
     `- [ ] **AC-3** ~~<old text>~~ — withdrawn 2026-10-04: <reason>`;
   - a **narrowed or reworded** criterion keeps its identifier, with a dated note in the
     same line: `(narrowed 2026-10-04: <reason>)`.

   Why: a citation outlives the list it points into, and a renumbered or reused
   identifier silently redirects every earlier citation to a different criterion.
3. **Concurrent amendments.** Before committing an amendment, take "next unused" over the
   story on its own branch **and** on the branch it will merge into. If two amendments
   still claim the same number when they meet, stop and ask a human which one gives way.
   That amendment's new criteria are then renumbered together with every citation already
   made to them. Nothing resolves this automatically, because an identifier committed on a
   branch may already be cited.
4. **Citation form.** For a story with identifiers: `<story path> AC-<n>`, or `AC-<n>`
   inside the story itself. Plans, specs, gate calls, evidence entries and fate tables use
   it instead of a position ("criterion 4") or a paraphrase. For a story without
   identifiers: the story path and the criterion's text, quoted — never an identifier
   guessed from its position, because a position changes whenever the list does. This is a
   citation convention; no record format changes.
5. **Older stories.** A story that already carries `AC-<n>` identifiers keeps them, and
   rules 2–4 apply from now on. A story without identifiers is not rewritten: at its first
   later amendment it adopts them — its existing criteria are numbered in their current
   order, the italic rule line is added, and a dated line under §3 records the adoption.
   Rewriting it earlier would change what its existing citations point at, with nobody
   amending it to notice.

**Worked example.** A committed story has AC-1, AC-2 and AC-3. Three amendments follow:

| Amendment | §3 afterwards (identifiers only) |
|---|---|
| a criterion inserted between AC-1 and AC-2 | AC-1, **AC-4**, AC-2, AC-3 — the new one takes the next unused number, not its position |
| AC-2 withdrawn | AC-1, AC-4, ~~AC-2~~ withdrawn (dated), AC-3 — the line stays, the number is never reused |
| AC-3 narrowed | AC-1, AC-4, ~~AC-2~~, AC-3 (narrowed, dated) — same identifier, new text |

Every citation made before these amendments still points at the same criterion.

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

## Amending an approved story or spec

A second route, separate from the Flow. Use it when an approved story or spec must change
after a human decided to change it. It writes one **change record** into the changed
artifact, so that no earlier condition disappears unnoticed: a dropped condition looks
exactly like text that was never there (AGENTS.md, "Never replace a decision procedure
without accounting for its old conditions").

It runs none of the Flow's steps — no question round, profile proposal, new file or
brainstorming hand-off — because the decision already exists and a second approval would
be a step nobody asked for. It makes no new solution-design decision: for a story the
WHAT/WHY boundary holds as in the Flow; for a spec the record may state a technical
condition that was already decided, because recording it is not designing it.

**Who runs it:** the session allowed to change files. An advisory `dev-workflow:sparring`
session drafts the record in the conversation and hands it over in its coding-agent
prompt; the coding session writes it here.

### Steps

1. **Establish the decision.** Name the explicit human decision that covers the change:
   who, when, where (a message, a review thread, a commit). If no decision covers the
   whole change, ask the uncovered question and wait, then continue on the answer. This
   is the route's only question, because the human already decided the rest.
2. **Fix the baseline**: the approved text the change is measured against — the commit at
   which it was last approved, or, for approved text never committed, the content hash
   recorded with the approval (for example the hash a Gate-A request pinned). If it cannot
   be established, stop and name what is missing: substituting `HEAD` or the working copy
   would measure the change against text nobody approved.
3. **Capture and reconcile the current state of every file the route will write** — the
   changed artifact and each dependent artifact (working tree and index); a path the
   route will create must not exist yet. List each edit made since the baseline in the
   record's *Intervening changes*, accounted for like any other condition; put any the
   decision does not cover to the human under step 1. Preserve unrelated edits. Concurrent
   identifier claims stay under *Acceptance-criterion IDs* rule 3.
4. **Enumerate the baseline's conditions** before assigning any fate: every criterion,
   every outcome or scope sentence that constrains the result, every stated exclusion. The
   list is what reveals an omitted condition; a template cannot. For a spec, also read the
   stories its `Story:` header names and map each changed condition to the criteria it
   serves.
5. **Assign a fate and an AC operation** to every enumerated condition (one row per
   condition, or per run of criteria sharing a fate). Then check that every condition has
   a row. A condition nobody decided goes to *Unaccounted*, never into the table under a
   fate it does not have. **The changed text is not a decision**: that a later draft drops or
   rewrites a condition shows what changed, not that a human chose it. A fate needs the
   decision of step 1 (or an answer to its question) to cover that condition; reading a
   covering decision into nearby wording is the same as having none.
   **So every `moved` or `dropped` fate quotes the passage of the decision that covers it**,
   in the row; a fate with no passage to quote is not a fate but an *Unaccounted* entry. A
   passage that limits *how* something may be decided (what evidence counts, what may not be
   inferred) does not decide *whether* it changes.
6. **Apply *Acceptance-criterion IDs* rules 1–5 exactly as written.** Cite each affected
   criterion in rule 4's form (with or without identifiers). Any amendment of an older
   story adopts identifiers under rule 5, even when no criterion's wording changes.
   Criterion operations apply only to criteria the decision changes. A criterion whose
   change is wholly or partly *Unaccounted* gets operation `none` and keeps its approved
   text until a decision covers it; the record names it under *Unaccounted*. A spec amendment
   edits a story only when the decision changes that story, which then is a dependent
   artifact.
7. **Fill the remaining fields.** For *Reviews already run*, cite, for each review input the
   change touches and each cycle it affects, the paragraph of the project's gate rules
   (`.claude/review-gates.md` where `/workflow-init` scaffolded them) that decides the
   consequence. Quote or cite; never summarise what a rule decides, because a summary
   drifts from its source. Write "no rule found" only after checking, naming the input
   and the paragraphs checked, and then the human's decision or that it is pending.
8. **Write and commit, deferring to the gate rules.** Immediately before writing, every
   file must still equal what step 3 captured; before staging, each must equal what you
   wrote. Any other difference returns to step 3. Then decide from the gate rules, not
   from this route, whether the complete changed set owes a gate (see the gate rules'
   paragraph on what counts as prose) or an open cycle governs the commit; if so, hand the
   commit to that gate and stop here. Otherwise commit on your own: stop if the index
   already holds staged work you did not stage; stage exactly the changed artifact and the
   dependent artifacts marked `updated in this change`; check that the staged paths are
   exactly those and each staged file equals what you wrote; commit with a message naming
   the change, the decider and the date.
9. **Stop.** Name what the change unblocks and what stays blocked (*Unaccounted*,
   dependent artifacts, reviews). Resume nothing on your own: the next gate, plan or
   implementation step is the human's or its own workflow's to start.

### The change record

Place it in the changed artifact: in a story at the end of §3, in a spec at the end of the
section it changes. Shape:

```markdown
**Changed YYYY-MM-DD — <reason class>.** Decided by <who>, <where>. Baseline: <commit or approved-content hash>. <Rationale.>

| Earlier condition | Fate | AC operation |
|---|---|---|
| <AC-n, or the quoted condition> | <fate, or several> | <operation> |

- **Unaccounted:** <condition> → blocks <named continuation> until settled; or none.
- **Intervening changes:** <change since the baseline> → <how accounted>; or none.
- **Scope boundary:** in: <…>; out: <…>.
- **Open questions:** <question> → <where recorded>; or none.
- **Dependent artifacts:** <path> → <status>; or none.
- **Reviews already run:** <input or cycle> → <consequence>, per <rule cited>; or "no rule found" (<input>, <paragraphs checked>) → <human decision, or pending: blocks <continuation>>.
- **Evidence (optional):** <link, for example a spec-delta report>.
```

The closed sets:

- **Reason class**, exactly one: `changed requirement` · `gap found` · `change of direction`.
- **Fate**, one or more per condition: `kept` · `moved → <destination>` · `dropped — <reason>`.
- **AC operation**, per intake's ID rules: `none` · `reworded` · `narrowed` · `withdrawn` · `added AC-<n>`.
- **Dependent-artifact status**, exactly one: `updated in this change` · `open — permitted by <rule>` · `blocks <named continuation> until updated`.

A narrowing usually carries several fates in one row — the part kept and the part moved
or dropped — because naming only the surviving part hides what left the scope.

**Narrowed or replaced — the test.** A criterion is `narrowed` (or `reworded`) only when
everything the new text requires was already required by the old one: it keeps part and
adds nothing. As soon as the new text requires something the old did not — a new state, a
new obligation, a new reason to report — it is a **replacement**: `withdrawn` plus
`added AC-<n>`, so an old citation never silently gains a requirement it did not have.
`open` needs a cited rule that permits
leaving the artifact; where a rule demands the update in the same commit, `open` is not
available.

Example rows, one narrowing and one replacement:

```markdown
| AC-3: export runs nightly and on demand | kept: on demand; dropped — nightly, per the decision: "the scheduler is out of this release" | narrowed |
| AC-4: progress shown as a percentage | dropped — per the decision: "no reliable total exists; show steps instead"; moved → AC-6 (a step counter) | withdrawn; added AC-6 |
```

## Stop and ask

These stops belong to the Flow. The amendment route's stops are in its own steps; only
**No AGENTS.md** applies to both routes.

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
  ungroundable without it, and an amendment cannot check its accounting against the
  invariant it serves.
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

- Designing a solution (HOW) anywhere outside a story's Section 4.
- Tagging invariants from memory instead of grepping AGENTS.md.
- Looping past one question round instead of pausing for the user.
- Padding to reach three acceptance criteria when the idea can't ground them.
- Renumbering the criteria of a committed story, or reusing a withdrawn identifier.
- Committing with `git add -A`, or, in the Flow, committing text the user hasn't approved.
- Leaving a story's Section 4 or the invariants empty instead of the explicit
  "No AGENTS.md invariants matched".
- In an amendment: giving an undecided condition a fate instead of listing it under
  *Unaccounted*, or summarising what a gate rule decides instead of citing it.
