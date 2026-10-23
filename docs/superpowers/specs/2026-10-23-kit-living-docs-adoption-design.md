# Living docs adopted into the kit (pilot-tested elements) — Design

**Story:** `docs/superpowers/stories/2026-10-23-kit-living-docs-adoption-story.md` (cited as AC-<n>)
**Profile (from the story):** risk standard; security none; evidence battery+check
**Input:** `docs/field-reports/2026-10-23-living-docs-pilot-report.md` § Recommendation; the pilot story
`docs/superpowers/stories/2026-10-06-living-feature-docs-pilot-story.md`; `todos.md` § "From the living-docs
pilot report"; Daniel's decision D22 (2026-10-23 08:40).

## 1. Intent

Give every project `/workflow-init` sets up the documentation model the SFX pilot exercised, with the four
changes the pilot asked for, as one short rules file plus a kept link checker. Nothing the pilot did not
exercise enters the kit. The kit says what goes where and when a document is checked; it writes no empty
document and no project vocabulary.

## 2. Goals, non-goals

**Goals:** AC-1 … AC-11.

**Non-goals (AC-8)** — not exercised by the pilot, so no rule enacts them and the user docs say so:
naming a story's features at intake; map-guided context assembly for builders; cross-feature flow sections
and their tests; the impact check along dependencies with a stated end; the conflict check of shared
contracts and the composed-candidate check; removal of a feature; a splitting decision; capability or
child-feature levels. Also out: this repository adopting feature docs itself (it has no features in the
pilot's sense and already keeps `docs/PRD.md`, `docs/ARCHITECTURE.md`, `docs/TECH-STACK.md`); any change to
the gate rules (`.claude/review-gates.md` is at 9,995 of its 10,000 bytes); any skill change (§4 D6).

## 3. What changes

### 3.1 New scaffolded rules file `.claude/living-docs.md` (AC-1, AC-2, AC-3, AC-5)

A new `/workflow-init` template section `### 2.20 .claude/living-docs.md — the living-docs rules`, fenced
inline (invariant 8), written under the normal target rules (invariant 9; AC-6). It lives under `.claude/`
for the same reason as the gate rules: editing it fires Gate B, because it is a prompt. Its content, as
rules with their reasons, stack-neutral (AC-7):

1. **Homes.** One home per kind of content: the signpost `AGENTS.md` § Documentation map (one line per
   document: path, link, and when to read it; no content repeated); product scope and the **feature map**
   (columns `Feature | Behaviour | Status | Last changed | Doc | Last story/plan`, status `planned |
   partial | built`) in `docs/PRD.md`; system structure in `docs/ARCHITECTURE.md`; technologies, job,
   reasons and constraints in `docs/TECH-STACK.md` (no version numbers; manifests and lockfiles hold
   them); current behaviour of one feature in `docs/features/<name>.md` with fixed headings (purpose and
   triggers; current behaviour; planned; business rules incl. failure, empty, concurrent and recovery
   paths; surfaces; borders to neighbours; contracts used; records). A suitable existing document may
   stay where it is; the signpost names it. A document is created only when it gets content, never as an
   empty template; until then the signpost marks its home `not yet written`. A version that constrains
   behaviour and that no manifest or lockfile records (a system interpreter, an external service or
   protocol) may be stated as a constraint with its source.
2. **Authority and provenance.** The documents are descriptive: binding rules stay in `AGENTS.md` and the
   approved specs, and a restated rule links its source. On conflict the source wins; fix the document, or
   write `DISCREPANCY (<source> vs <source>)` when only a decision can resolve it. Each document names what
   it was last checked against: `as of <base commit> + <the change's story or pull request>`, never its own
   commit's hash, which does not exist yet and changes on a squash merge. Built behaviour is written as current; unbuilt commitments are labelled
   `planned`. A derived statement carries `INFERRED (source: …)`; a fact no source records is written
   `not recorded`.
3. **Same change.** A change that alters behaviour a document describes updates that document in the same
   change.
4. **Build record** (change 1 and 2). One line per document, `<path> | <status> — <what was checked>`,
   status exactly one of `changed`, `checked, unchanged`, or `absent` (a home the signpost marks
   `not yet written`). Example: `docs/features/billing.md | checked, unchanged — refund rules still match`.
   It must hold a line for: every feature doc whose current behaviour or `Planned` section the change
   affects, neighbours included, not only the docs the change edited; each top-level home the signpost
   names; and always `CLAUDE.md` and `AGENTS.md`, after checking that every sentence in them about where
   something lives agrees with the Documentation map (a moved document can falsify them without editing
   them). A missing line is a finding for whoever finds it. **How reviewers see it:** the record is written
   before the first Gate B pass and passed in every Gate B call's `whatWasImplemented`, where Gate B checks
   it as claims; it is copied into the pull request body for PR review, and into the unit's handover.
5. **Link check** (change 3). The repository keeps `scripts/check-doc-links.sh` (from `/workflow-init`,
   §3.2), in its quality command; it runs before the build record is closed. It resolves relative links and
   their heading fragments.
6. **Size soft alarm.** A living document past 10,000 bytes gets a line `size alarm: <path> <bytes>` in the
   build record. It puts splitting up for a decision and never fails a check; coverage is never cut to meet
   a size.
7. **Effort per piece** (change 4). Read these rules before any documentation work starts, so the start
   is stamped. Each piece of documentation work — setting up one document, the
   upkeep in one change — gets a line in the build record: start and end (`date` stamps), tokens when the
   harness reports them, each with how it was captured; `unknown` where it was not captured, never an
   estimate.
8. **Not covered** — the non-goals of §2, listed in one line, so nobody reads silence as a rule.

Target size: about 5 kB. It is not loaded every session; §3.3's pointer loads it when it applies.

### 3.2 The link checker, extended and scaffolded (AC-4)

- `scripts/check-doc-links.sh` gains: (a) **heading fragments** — for a link `path.md#frag` or `#frag`,
  the fragment must equal a GitHub-style slug of a heading in the target (outside code fences), or an
  `id="…"`/`name="…"` attribute there. Slug: lowercase, ASCII punctuation except `-` and `_` removed, the
  common Unicode punctuation the kit's own docs use (`—`, `–`, `§`, `·`, `…`, curly quotes) removed, each
  space a `-`; a repeated heading gets `-1`, `-2`, …. Fragments are checked only for `.md` targets. Known
  limit, written in the header: other Unicode punctuation and inline link text inside a heading are not
  slugged as GitHub does, so such a fragment can be reported broken (fail-closed; the fix is to link a
  plainer heading); two different headings that slug to the same text, or a generated `-1` that collides
  with a literal heading, are not disambiguated as GitHub does (documented as unsupported; such a link may
  be reported broken or accepted). (b) **skipped trees as arguments** — the trees this repo skips (`source-files/`,
  `docs/history/`, `docs/superpowers/replays/`) move from the script body to the command line, so the same
  bytes serve every project. Existing behaviour otherwise unchanged; its header lists what it still does
  not check.
- `scripts/check-doc-links.test.sh` gains cases: a good and a broken fragment in another file, a bare
  `#frag` in the same file, a duplicate heading `-1`, a heading with `—` and backticks, an `id=` anchor, a
  heading inside a code fence not counted, a non-`.md` target's fragment ignored, and a skip-prefix
  argument.
- The repo's battery, CI step and `AGENTS.md` § Commands rows pass the three skip prefixes.
- Broken fragments the extension finds in this repo's docs are fixed in this change.
- `/workflow-init` gets `### 2.21 scripts/check-doc-links.sh — the docs link check`: the script's exact
  bytes, fenced inline. A new **check 4l** in `scripts/check-invariants.sh` fails when that fenced body and
  `scripts/check-doc-links.sh` are not byte-identical (the 4j pattern), so the second copy cannot drift.
  It compares bytes only. Its suite gets a pass and a fail case.

### 3.3 `CLAUDE.md` template and `/workflow-init` steps (AC-3, AC-6)

- The template's closing sentence becomes: "Stack-specific patterns, invariants and § Commands live in
  @AGENTS.md (single source of truth — also read directly by Codex and the PR review bots); its
  § Documentation map says where the architecture and the other project documents live. The Cross-Model
  Review gates (§5) check against the invariants there." It no longer names `AGENTS.md` as the home of the
  architecture, and it holds for a project that keeps its architecture in `AGENTS.md` as well, because the
  signpost then says so.
- §4 gets one paragraph: **Living docs** — when `.claude/living-docs.md` exists, read it before any work
  on a project document, before changing behaviour one describes, and before Gate B; it holds the
  build-record rule. Why
  one line in §4: the rules load only where they apply, and the template stays well under check 4e.
- Step 3 (the `AGENTS.md` interview) gains a **Documentation map** item: always written, one line per
  document with when to read it; the architecture line names where it lives (`AGENTS.md` § Architecture
  or `docs/ARCHITECTURE.md`). With living docs taken, it also carries a line naming
  `.claude/living-docs.md` as the rule every change's build record follows, so Codex and the PR bots,
  which read `AGENTS.md`, learn the duty.
- **The switch: the rules file is the only activation signal.**
  - *`.claude/living-docs.md` absent*: ask once whether the project takes living docs (recommended yes),
    whatever else exists. Yes → write it; No → `skipped (user)`, and a later run asks again. A
    checker-only checkout (a disabled project, or one with its own checker) is therefore never enrolled
    without the question.
  - *present*: no question; it follows Rule 2 (identical → `unchanged`; different → diff and ask).
  - *the checker (2.21)*: only when living docs are taken (rules file present after the step above), and
    then under Rules 1–2 like any target; with living docs not taken it is left untouched.
  - *disabling*: `/workflow-init` never deletes either file; the user removes `.claude/living-docs.md`
    themselves and drops its line from the Documentation map; the `CLAUDE.md` paragraph is then inert.
  - *completeness*, judged on the result after every file decision, only when the rules file is present:
    the rules file is identical to the 2.20 template; `CLAUDE.md` holds the **Living docs** paragraph;
    `AGENTS.md` § Documentation map names `.claude/living-docs.md`; `scripts/check-doc-links.sh` is
    identical to the 2.21 template. Each part that fails is reported as
    `living docs: incomplete — <part>` (an older rules file kept; the pointer missing; reviewers not
    pointed to the rules; the checker not the kit's, fragment coverage not verified).
  Step 4's checklist item "add `sh scripts/check-doc-links.sh` to the quality command and CI" appears only
  when that file is present.
- An existing project re-running `/workflow-init` sees the changed `CLAUDE.md` as a difference, shown and
  asked (invariant 9); new files are written only when missing.

### 3.4 Pilot report correction (AC-10)

The AC-4 table row "P7 build | the orchestrator | unknown whether a go …" becomes: the go was given
2026-10-22 23:16 (orchestrator board `.context/sparring/orchestrator-board.md`, line "sfx P7 u2 go for
p7-demo"). The board is untracked; the citation names it as such.

### 3.5 Docs and records (AC-11)

README, `docs/reference.md` (the `/workflow-init` file list and the link checker), `docs/coding-workflow.md`
or `docs/getting-started.md` where they list scaffolded files, `docs/ARCHITECTURE.md` (script description;
no new repository files besides this story's records), `plugins/dev-workflow/CHANGELOG.md` 0.42.0, manifest
version 0.42.0, the pilot story's AC-9 note, `todos.md` rows "Adopt the living-docs model" and "template
still says @AGENTS.md" closed.

## 4. Decisions (made in this run, CLAUDE.md §4 "Autonomous run")

- **D1 Rules in a separate file under `.claude/`**, not inline in the `CLAUDE.md` template: keeps the
  always-loaded template small (check 4e), loads only where used, and fires Gate B on edits.
- **D2 Per-project switch by file presence**, asked once in Step 2; no conditional template text.
- **D3 The build record lives in the handover or PR body**, not a new file, matching the pilot (its record
  was in the P7 unit handover) and CLAUDE.md §4's handover.
- **D4 Reuse the existing checker**: extended in place, shipped to projects as an inline template, pinned
  to the repo copy by check 4l. Alternatives rejected: a project-written checker (the pilot's lost one) and
  a hand-kept second copy (drifts).
- **D5 No change to `.claude/review-gates.md`**: 5 bytes of budget left; "a missing line is a finding" is
  stated in the living-docs rules for every reviewer, without a gate-rule sentence.
- **D6 No skill changes**: the exercised elements act at build end, which the `CLAUDE.md` pointer and the
  rules file cover; the skill-level elements (intake naming features) are non-goals.
- **D7 Size alarm threshold 10,000 bytes**, as the pilot used ("past 10k is a split signal").
- **Builder check:** not dispatched; Gate A (Codex) is this spec's review.

## 5. Invariants touched

8 (inline templates: 2.20 and 2.21 are inline), 9 (idempotent: new targets follow Rules 1–5), 10
(stack-neutral wording), 11 (prompt standards for the new template and changed text), 12 (bump to 0.42.0),
the Don'ts on renaming doc sections (fragment fixes), on describing what a check proves (check 4l and the
link checker's header), and § Commands (the changed command rows are run before they are written).

## 6. Acceptance evidence

| AC | Evidence |
|---|---|
| AC-1, 2, 3, 5, 7, 8 | the 2.20 template text; Gate B spec slot maps each |
| AC-3 | template sentence; `grep` shows no "Project architecture … live in @AGENTS.md" left |
| AC-4 | link-check suite cases; check 4l and its suite cases; battery green |
| AC-6 | 2.20/2.21 under Rules 1–5; Step 2 question |
| AC-9 | checks 4e, 4i pass; battery green |
| AC-10 | report line |
| AC-11 | PR file list against §3.5; version bump check |

## 7. Left to the builder

Exact wording of the rules file and docs; test fixture shapes; the awk/sed form of the slug; which existing
links get fixed and how.
