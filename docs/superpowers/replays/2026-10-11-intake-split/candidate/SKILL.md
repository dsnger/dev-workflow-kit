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

**Requires `AGENTS.md`** (the project's invariants file) — the capture route's
invariant-tagging step greps it, and story Section 4 quotes what it finds. If the
repo has none, say so and offer `/dev-workflow:workflow-init`, which walks you
through writing one.

## Choose the route first

intake has two routes that share no steps, so choose one before doing anything else:

| The request | Route | Read in full before its first step |
|---|---|---|
| A raw idea or voice transcript arrives and needs to enter the workflow, before any brainstorming; or a backlog line needs to become a reviewable story before design starts | **Capture a new story** (the Flow) | `capture-new-story.md` |
| An approved story or spec must change after a human decided to change it — narrowed, redirected, or corrected for a gap found later | **Amend an approved story or spec** | `amend-approved-artifact.md` |

An item that already has an approved story takes the amendment route, however the request
is worded: an approved artifact changes only through the amendment route, never through a
new story. Designing a solution is neither route — that is `superpowers:brainstorming`.

**Load the route file before you act on the route.** Both files sit in this skill's base
directory, shown at the top of this skill. Read the chosen file in full before that route's
first step: the route's steps, stops, output formats and hand-off are there and not on this
page, so a route run from this page alone skips them. Read it on its own with the Read
tool, not inside a shell command that prints other output too: long shell output can be
cut in the middle, and a route file missing a middle section loses steps without looking
incomplete. If a read shows a truncation marker anyway, read the missing part before
acting. Read the route file again after every compaction, before your next step, whether or
not it still seems to be in your context; in a resumed session, read it again if it is no longer
in your context. If it cannot be
read, stop and report the path you tried and the error; do not run the route from memory,
because a route missing one of its stops still looks complete.

The story template, the acceptance-criterion ID rules and the profile log below belong to
both routes; each route file says where it uses them.

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

1. **Fixed at commit, free before.** While the draft is shown and edited (capture steps
   8–9), renumber freely, so the draft always reads `AC-1 … AC-k` in order. Identifiers
   become permanent when the approved story is committed (capture step 10).
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

## Stop: no AGENTS.md

This stop applies to both routes; every other stop is in its route file.

- **No AGENTS.md:** stop and offer `/dev-workflow:workflow-init` — Section 4 is
  ungroundable without it, and an amendment cannot check its accounting against the
  invariant it serves.

## Common mistakes

- Designing a solution (HOW) anywhere outside a story's Section 4.
- Running a route without having read its route file.
- Tagging invariants from memory instead of grepping AGENTS.md.
- Looping past one question round instead of pausing for the user.
- Padding to reach three acceptance criteria when the idea can't ground them.
- Renumbering the criteria of a committed story, or reusing a withdrawn identifier.
- Committing with `git add -A`, or, in the Flow, committing text the user hasn't approved.
- Leaving a story's Section 4 or the invariants empty instead of the explicit
  "No AGENTS.md invariants matched".
- In an amendment: giving an undecided condition a fate instead of listing it under
  *Unaccounted*, or summarising what a gate rule decides instead of citing it.
