# `harden-finding`'s recurrence rule is scope-blind — Story

**Date:** 2026-08-04 · **Size:** story

**Unprofiled, deliberately.** This story is a split from a designed round, not a raw idea, so
it did not pass through `dev-workflow:intake` — intake excludes items that have moved into
solution design. A profile is proposed and human-confirmed at intake time. Writing one here
would produce a header that **looks** confirmed and is not, and nothing would reveal that:
`CLAUDE.md` §5 stops on a profile that is malformed or internally inconsistent, not on one
whose values are well-formed but unconfirmed. That is why the debt is carried as acceptance
criterion 1 rather than by fabricating a header.

## 1. Problem statement

`harden-finding`'s recurrence step tells you to re-read the ledger, and then decides from the
fingerprint and the latest matching row's rung. It never lets that row's **stated guard**
control the verdict. So a later in-class defect outside the guarded spelling is proposed for a
stronger rung than anything justifies — which the 2026-07-26 rows warn about by name, in ledger
prose the decision branch does not consult.

The 2026-08-03 hardening round applied the missing precheck by hand, on a standing instruction
from Daniel, and still reached a wrong verdict twice by reading one prior row's guard and
stopping. Landing the rule in the skill turned out to require decisions a rule paragraph cannot
carry, which is why it is here rather than in that round.

## 2. Desired outcome

A recurrence proposal states which prior rows it read, what each guards, and whether this
finding falls inside or outside — and a later reader can check that reasoning against the
ledger. Escalation follows from a guard that failed, never from a count.

## 3. Acceptance criteria

- [ ] Before design resumes on this story, whoever picks it up proposes both axes and the mode
      derived from them, pauses for Daniel's confirmation, and writes the confirmed profile into
      this header. Design continues only after that.
- [ ] A recurrence decision names every prior matching row it considered, not only the latest,
      and records what each guards.
- [ ] The record a decision leaves behind is sufficient for a later reader to reach the same
      inside/outside verdict without re-deriving it.
- [ ] The rule states what happens when a same-fingerprint row appears mid-run, including when
      that row is `pending` or its guard cannot be determined.
- [ ] Whether automatic escalation on recurrence is kept, narrowed, or dropped is settled
      explicitly, with a stated reason.
- [ ] The `AGENTS.md` Don't "Never replace a decision procedure without accounting for its old
      conditions" is satisfied for every condition the current step 3 and step 7 carry.

## 4. Affected AGENTS.md invariants

- `## Key invariants` → `### Prompts and scaffolding` — "10. **The base taxonomy stays
  stack-neutral.** Project vocabulary — tables, auth helpers, framework APIs — goes only in
  that project's `docs/hardening-taxonomy.md`, never into the `harden-finding` skill. Otherwise
  one project leaks into every other."
- `## Key invariants` → `### Prompts and scaffolding` — "11. **Prompt changes pass
  `docs/prompt-standards.md`** — all 12 checklist items, for any skill, command, agent
  definition, hook message, or scaffolded template."
- `## Key invariants` → `### Packaging` — "12. **A plugin change requires a version bump.**"
- `## Don'ts` — "**Never replace a decision procedure without accounting for its old
  conditions.** List what the previous prose required, then mark each one kept, moved, or
  deliberately dropped."

## 5. Open questions

Six, each paired with the failure that raised it:

- A verdict was reached by reading one prior row's guard and stopping, when an older row's guard
  covered the case. **Which prior rows must a recurrence be judged against before "outside" is
  safe?**
- A reader cannot tell whether a past rung choice followed from a guard reading or from a count,
  because nothing durable records the reading. **What does a later reader need, and where does
  it belong?**
- Guards are frequently exact spellings containing regex alternation, and the ledger's stated
  escaping rule covers the `finding` column. **How does a guard citation survive a Markdown
  table without changing what the columns mean?**
- Step 7 re-reads the ledger and then appends, so a row landing after that read is not seen, and
  a row seen at the read is treated as a duplicate without anyone consulting what it guards.
  **What should happen when a row appears mid-run?**
- Widening the branch condition from "latest matching row is a real rung" to "a matching row
  exists at a real rung" makes it fire when the latest row is `pending`, bypassing the
  prerequisite rule. **How do a guard scan and a prerequisite block compose?**
- The old step-3 text required proposing one rung stronger on recurrence, and a replacement
  choosing "the rung that fits the repair" does not carry it. **Is automatic escalation kept,
  narrowed, or deliberately dropped?**

## 6. Suggested size

`story` — one skill file, one decision procedure, one spec → plan → PR. Above a chore because
the six questions above are real design; below an epic because they all concern one procedure
in one file.
