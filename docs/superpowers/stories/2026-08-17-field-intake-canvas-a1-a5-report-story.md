# Field-intake round: the canvas A1–A5 field report — Story

**Date:** 2026-08-17 · **Size:** story
**Risk:** standard · **Security:** none · **Validation:** battery+check

## 1. Problem statement

The kit's heaviest consumer — the infinite-portfolio-canvas repo — ran tickets A1–A5
under this kit (~60+ Gate-B cycles, ~150 Gate-A/B passes, v0.8.0 since mid-run) and
relayed a verbatim field report: eleven numbered items across measured defects, policy
candidates and explicitly experimental proposals, plus one validation result. None of it
is in the kit's backlog today, and the report itself is a local file outside git history,
so nothing in the repo can cite it.

This is the input the kit's own policy depends on: `todos.md` § Now says this repo
improves itself "reactively only. A change starts because a finding surfaced — through
the gates, a PR bot, or real use". Real use has now surfaced eleven, and there is no
recorded landing place for any of them. Separately, the parked `/capture-finding` row's
trigger — "the first production finding — one that arrives from real use rather than
from a gate or a bot" — has fired via this very report and is undisposed.

## 2. Desired outcome

Every item in the report reaches exactly one recorded disposition in this repo, each
grounded in evidence someone can re-read, and the report is citable from those records.
A disposition may be a rejection: the report's own terms make "verify at the cited
evidence, adopt nothing unverifiable, reject with a one-line reason" the standard, and a
reasoned rejection is as complete an outcome as an adoption. The round leaves the
consumer repo untouched, and leaves no item in the ambiguous state of having been read
but not answered.

## 3. Acceptance criteria

- [ ] The report is committed at `docs/field-reports/2026-08-16-canvas-a1-a5-field-report.md`
      with every machine-local absolute path replaced by the repo's name — `grep -c '/Users/'`
      on the committed file returns 0 — and the surrounding local-drafts exclusion still
      holds for any other file in that directory.
- [ ] Each of the eleven numbered items carries **exactly one** disposition recorded in
      the repo: a `todos.md` row with a named trigger, a `docs/hardening-log.md` row
      appended via `dev-workflow:harden-finding`, a parked story, an upstream-candidate
      note, or a one-line reasoned rejection. No item carries two; none carries none.
- [ ] Every adopted claim names the evidence it was verified against. Any claim whose
      cited evidence could not be reached or did not support it is recorded as rejected
      for that reason, not adopted with a caveat.
- [ ] Item 3 is recorded as an upstream candidate against `mcp-codex-dev` carrying its
      three confirmed evidence instances, and no fix for it lands in this repo.
- [ ] Part 3's result (zero bytes moved across five surgery tranches under the untouched
      core rules) appears as one line in the round's closure record and changes no
      shipped file.
- [ ] The parked `/capture-finding` row carries a disposition — built, or re-parked with
      the fired trigger and the evidence recorded against it — and that decision was put
      to Daniel before it was written.
- [ ] Every ledger row this round appends states the guard-scope precheck's outcome
      against the prior same-fingerprint row, quoting the guard it examined.
- [ ] The consumer repo `infinite-portfolio-canvas` has no file created, modified or
      deleted by this round.

## 4. Affected AGENTS.md invariants

- `### Prompts and scaffolding` — "11. **Prompt changes pass `docs/prompt-standards.md`** —
  all 12 checklist items, for any skill, command, agent definition, hook message, or
  scaffolded template."
- `### Prompts and scaffolding` — "10. **The base taxonomy stays stack-neutral.** Project
  vocabulary — tables, auth helpers, framework APIs — goes only in that project's
  `docs/hardening-taxonomy.md`, never into the `harden-finding` skill. Otherwise one
  project leaks into every other." (The rulings being codified were minted in one
  consumer's vocabulary.)
- `### Packaging` — "12. **A plugin change requires a version bump.** A pull request that
  changes any path under a `plugins/<name>/` directory *that still exists at HEAD* … must
  also change that plugin manifest's `version`, or CI fails."
- `## Don'ts` — "**Never replace a decision procedure without accounting for its old
  conditions.** List what the previous prose required, then mark each one kept, moved, or
  deliberately dropped."
- `## Don'ts` — "**Never rename or delete a doc section without grepping for references
  first.**"

## 5. Open questions

- `/capture-finding`: build now, or re-park with the fired trigger recorded? Its
  deliverable is an extension of `harden-finding` (plugin scope, bump, full Gate B), so
  the answer changes this round's size. To be put to Daniel with the evidence in hand,
  not decided inside the round.
- Per item, for items 5, 6 and 8: does the codification land as prompt text in this
  round, or does it pull toward real design and become a parked story? The rule is
  settled; which side each item falls on is a finding of the verification step.

## 6. Suggested size

`story` — one coherent triage round with one input artifact and one output shape per
item; anything inside it that needs design gets parked as its own story rather than
growing this one.
