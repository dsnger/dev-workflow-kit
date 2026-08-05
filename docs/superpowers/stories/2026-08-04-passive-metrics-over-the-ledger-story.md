# Passive metrics, read-only over the ledger and git — Story

**Date:** 2026-08-04 · **Size:** story

**Unprofiled, deliberately** — a split from a designed round, so it bypassed
`dev-workflow:intake`, which excludes work already in solution design. A profile written now
would look confirmed without being confirmed; acceptance criterion 1 carries the debt instead.

## 1. Problem statement

The hardening ledger already contains the data to answer questions nobody can currently ask of
it — which fingerprints recur, how often a rung holds after it lands, which classes escalate on
count rather than on a guard that failed. Reading those answers today means a human scanning 22
rows by eye, which is how a recurrence count gets asserted from memory rather than from the
file.

The row was parked behind a sample-size threshold, and this round crossed it: appending four
rows took the ledger from 18 to 22, past the stated 20. The fifth story of this round also takes
the story count to 10, crossing the other arm of the same trigger. The threshold existed so the
sample would say something about the workflow rather than about the last week, and it now does.

### Conditions inherited from the source row

From `todos.md`, "**P8 — passive metrics, read-only over the ledger and git.**":

| Condition | Disposition |
|---|---|
| Analysis only — no new state file | **kept** — a metrics feature that writes state is a different, larger thing |
| No instrumentation | **kept** — the data already exists; collecting more is out of scope |
| Nothing written back | **kept** — the ledger stays append-only and human-authored |
| It answers questions the ledger already contains the data for — which fingerprints recur, how often a rung holds | **kept** as the scope statement |
| Trigger: 10 stories or 20 ledger rows, below which the sample says more about the last week than about the workflow | **moved** — the 20-row arm fired at 22 rows in the 2026-08-04 round, and the story arm reaches 10 with this story; recorded here |

## 2. Desired outcome

A reader can ask the ledger which fingerprints recur and how a rung has held, and get the answer
from the file rather than from recall — without the analysis writing anything back.

## 3. Acceptance criteria

- [ ] Before design resumes on this story, whoever picks it up proposes both axes and the mode
      derived from them, pauses for Daniel's confirmation, and writes the confirmed profile into
      this header. Design continues only after that.
- [ ] The analysis reads the ledger and git and writes nothing — no new state file, no
      instrumentation.
- [ ] A recurrence count it reports can be checked against the ledger by a reader who does not
      trust it.
- [ ] What the analysis cannot answer from the ledger alone is stated, rather than left for a
      reader to infer from what it does answer.

## 4. Affected AGENTS.md invariants

- `## Key invariants` → `### Prompts and scaffolding` — "11. **Prompt changes pass
  `docs/prompt-standards.md`** — all 12 checklist items, for any skill, command, agent
  definition, hook message, or scaffolded template." Binds if the analysis ships as a command
  or skill.
- `## Key invariants` → `### Packaging` — "12. **A plugin change requires a version bump.**"
  Binds on the same condition.
- `## Don'ts` — "**Never describe what a gate proves without checking what it actually
  compares.**" A metrics report is a claim about the ledger's contents, and a count stated
  without naming what was counted is the shape this repo logs most often.

## 5. Open questions

- Where does the analysis live — a command, a script, or a documented reading recipe? The row
  says analysis only, which rules out state but not a surface.
- What does it count, exactly? A fingerprint's recurrence count already drives escalation, and a
  second number derived differently would give two answers to one question.

## 6. Suggested size

`story` — one read-only analysis over two existing sources, one spec → plan → PR.
