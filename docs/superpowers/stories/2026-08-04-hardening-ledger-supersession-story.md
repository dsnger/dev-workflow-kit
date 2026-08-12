# The hardening ledger has no supersession convention — Story

**Date:** 2026-08-04 · **Size:** story
**Risk:** standard · **Security:** none · **Validation:** battery+check

**Profile log:**
- 2026-08-05 · adoption · unprofiled split from a designed round, profiled at its design checkpoint under acceptance criterion 1 · gates now read this header

## 1. Problem statement

**As of this story's writing — the pre-change state this problem describes:**
`docs/hardening-log.md`'s header said never edit a row, and one row per hardening. When a row's
"what this does NOT do" narration was later falsified by a feature change, neither move was
sanctioned: editing broke the first rule, appending broke the second. (Past tense records that
this is the state *before* the change, not that the rule moved: the amendment notes below
narrowed it and then restored it, so "never edit a row" reads today exactly as it did here.)

This is live. The 2026-07-20 row describes pre-0.8.0 counting behaviour as current, and a reader
who trusts it is misled about how the gate hook counts today. That is the second falsified row,
which is the condition the parked backlog row named as its trigger.

### Conditions inherited from the source row

From `todos.md`, "**The hardening ledger has no supersession convention.**":

| Condition | Disposition |
|---|---|
| Never edit a row | **kept, literally and absolutely** — narrowed at pass 3, restored at pass 7; see both amendment notes below |
| One row per hardening | **kept** — any solution must preserve it |
| The 2026-07-20 row now describes pre-0.8.0 behaviour as current | **kept** as the motivating instance |
| The 2026-07-20 *spec* took a version-qualified supersession note and it worked | **kept** as prior art the design should evaluate first |
| Alternative: an explicit "rows are historical, read the newest row for current behaviour" header statement | **kept** as a candidate |
| Trigger: the next row falsified by a later change — this is the second | **moved** — fired, and recorded here |

**Amended 2026-08-05** from Gate-A spec pass 3, finding 1, and human-confirmed. Accounting per
the AGENTS.md Don't — **kept:** the committed record's protection, which is what every consumer
of the rule actually relied on. **Narrowed:** the textual rule, from "never edit a row" to
"never edit a landed row", making textual what #22's Gate B already accepted in practice (row D,
amend-during-authoring, reasoning recorded in its evidence). **Dropped:** nothing.

**Amended again 2026-08-10** from Gate-A spec pass 7, and human-confirmed — **this reverses the
2026-08-05 narrowing.** Accounting per the AGENTS.md Don't — **restored:** the original absolute
wording, "never edit a row", with no landed/unlanded distinction anywhere. **Dropped:** the
narrowing itself, and with it row D's status as a precedent — under the convention that row's
correct move was an entry, which costs one entry in the whole ledger's history. **Kept:** the
committed record's protection, unchanged throughout, and now stated without a boundary to
compute. §2 and acceptance criterion 3 carry the same change, and AC 3 now holds literally.

*Why the narrowing was reversed — recorded so it is not re-explored.* The narrowing required a
definition of *landed*, and three were designed and deleted in turn: authorship-by-cycle,
reachability from `origin/main`, and content presence in the published ledger. Gate-A passes 4
through 7 each found the **replacement** for the previous definition unsound, three times inside
the very sentence written to fix its predecessor — the last being pass 7's blocker, where a
stale-but-readable ref returns a confident "absent" for a row already published, licensing an
edit to it. Each definition also carried its own old-conditions accounting, six-case self-test,
concurrency assumption and residual list, each of which grew defects of its own. The detour is
**explored and deleted**, not merely unfinished: the design now has no amendable class, so there
is no definition to get wrong.

## 2. Desired outcome

A reader who opens any ledger row can tell which of its claims have been recorded as no longer
holding and where the current answer lives, and a row falsified by a later change can be marked
as such without breaking either standing rule, both of which hold in their original absolute
form: never edit a row, and one row per hardening. Acceptance criterion 4 carries the two limits
on that reading — completeness is not promised, and a row that cannot be told apart from a
sibling is marked together with it.

*(Amended 2026-08-10 from Gate-A spec pass 5, finding 11. Accounting per the AGENTS.md Don't —
**kept:** determination from the ledger alone, and both standing rules. **Narrowed:** "can tell
whether it still describes current behaviour" → "can tell which of its claims have been
recorded as no longer holding", matching AC 4. The absence of a supersession entry never proved
a row current — nothing validates completeness — so the outcome was promising what the design
deliberately does not deliver. **Dropped:** nothing. AC 4 was amended this way at pass 1; this
site was missed then and is brought into line now.)*

*(Amended again 2026-08-11 from Gate-A spec passes 18 and 19, and human-confirmed. Accounting per
the AGENTS.md Don't — **kept:** the outcome as pass 5 left it, unchanged in substance. **Moved:**
the two limits on what a reader can determine are stated once, in AC 4, and pointed at from here —
pass 5's lesson was that this site and AC 4 drift apart when each carries its own copy. **Dropped:**
nothing.)*

## 3. Acceptance criteria

- [x] Before design resumes on this story, whoever picks it up proposes both axes and the mode
      derived from them, pauses for Daniel's confirmation, and writes the confirmed profile into
      this header. Design continues only after that.
- [ ] The ledger no longer presents the 2026-07-20 row as unqualified current behaviour — and
      every byte of the row itself is unchanged, the correction living in a marker above it.
      *(Amended 2026-08-10 from Gate-A spec pass 9, finding 10. Accounting per the AGENTS.md
      Don't — **kept:** both halves, that the row stops reading as current and that it was not
      edited. **Clarified:** which artifact changes — the ledger, not the row — because "the row
      no longer reads as X" is satisfiable only by editing the row, which the same criterion
      forbids. **Dropped:** nothing.)*
- [ ] The append-only rule and the one-row-per-hardening rule both still hold after the change,
      **literally and without amendment** — no row is edited, ever, and a correction is an append.
      *(Narrowed 2026-08-05 from Gate-A spec pass 3; **restored 2026-08-10** from pass 7, both
      human-confirmed. The criterion now reads as it originally did; the accounting for the
      narrowing and its reversal is in §1.)*
- [ ] A reader can determine, from the ledger alone, which of a row's claims have been **recorded**
      as no longer holding and where the current answer lives. Completeness is not promised:
      nothing validates that a falsified claim was ever recorded, and a hardening that is later
      *removed* has no sanctioned entry at all — the case the convention names as out of scope.
      Nor is per-row resolution promised: where a row cannot be told apart from a sibling, an entry
      marks every row it matches, accurate ones included, and the reader reads the correction
      against all of them.
      *(Amended 2026-08-05 from Gate-A spec pass 1, finding 4, and human-confirmed. Accounting
      per the AGENTS.md Don't — **kept:** determination from the ledger alone. **Moved:** current
      behaviour lives at the cited artifact, deliberately, per cite-don't-restate. **Dropped:**
      "a row to trust", because no ledger row ever provided current behaviour and the criterion
      demanded what the genre cannot supply.)*
      *(Amended again 2026-08-11 from Gate-A spec pass 18, finding 3, and human-confirmed.
      Accounting per the AGENTS.md Don't — **kept:** determination from the ledger alone, and the
      citation half. **Narrowed:** "which of a row's claims no longer hold" → "which have been
      recorded as no longer holding", which is what the design supplies and what §2's desired
      outcome has said since pass 5; this site was missed then. **Named:** the removed-hardening
      exclusion, which the design leaves unmarkable, so the criterion no longer promises a marker
      for it. **Dropped:** nothing.)*
      *(Amended again 2026-08-11 from Gate-A spec pass 19, finding 3, and human-confirmed.
      Accounting per the AGENTS.md Don't — **kept:** everything the pass-18 wording holds, all
      three clauses. **Named:** the inseparable-sibling case, where the criterion could otherwise
      be read as promising a *per-row* answer the locator cannot give — pass 18 closed a gap where
      a correction might be missing; this closes one where a correction present against a sibling
      is read as belonging to an accurate row, which is a wrong answer rather than an absent one.
      **Dropped:** nothing.)*

## 4. Affected AGENTS.md invariants

- `## Key invariants` → `### Prompts and scaffolding` — "8. **`/workflow-init`'s templates stay
  inline** in the command body."
- `## Key invariants` → `### Prompts and scaffolding` — "9. **`/workflow-init` never overwrites
  silently.** Idempotent: missing → write; identical → report unchanged; present and different →
  show the diff and ask; additive files (`.gitattributes`, `.mcp.json`, …) → merge."
- "11. **Prompt changes pass `docs/prompt-standards.md`**" and "12. **A plugin change requires a
  version bump.**" **Both bind unconditionally**, as of 2026-08-10. They were recorded as
  conditional on §5's open question; the design resolved that question toward reaching the
  template, so both now bind. *(Amended 2026-08-10 from Gate-A spec pass 4, finding 11.
  Accounting per the AGENTS.md Don't — **kept:** both invariants, and the reason each was
  listed. **Dropped:** the condition, because the thing it was conditional on is settled.
  **Dropped:** nothing else.)*

## 5. Open questions

- ~~Which artifacts must the convention reach before a reader can trust any row — this repo's
  ledger alone, or every ledger `/workflow-init` scaffolds? A repo-only fix ships a rule this
  kit's ledger obeys and every scaffolded one does not.~~
  **Resolved 2026-08-10: both surfaces.** The design carries the convention into
  `/workflow-init`'s inline ledger header as well as this repo's ledger, and rests the
  both-surfaces decision on a parity claim its §6 check 2 validates. Recorded rather than
  deleted, because §4's invariants and §6's size were both written against the unresolved form.
  *(Amended 2026-08-10 from Gate-A spec pass 4, finding 11.)*

## 6. Suggested size

`story` — one file's header convention **and** one inline template (resolved, §5), plus the
version bump and changelog entry those pull in, one spec → plan → PR.
*(Amended 2026-08-10 from Gate-A spec pass 4, finding 11 — "possibly one inline template" was
written before §5 was resolved.)*
