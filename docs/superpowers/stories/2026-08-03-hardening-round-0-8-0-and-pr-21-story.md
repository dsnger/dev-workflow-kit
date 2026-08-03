# Hardening round — the 0.8.0 cycle and PR #21 — Story

**Date:** 2026-08-03 · **Size:** story
**Risk:** standard · **Security:** none · **Validation:** battery+check

**Profile rationale:** not an entry in the profile log — no value has moved, and the log's
three kinds (axis change, mode override, adoption) all record a change. Recorded here
because the delimitation is load-bearing: the classifier story that produced these findings
was `high`, this round is `standard`, and the line between them is executable enforcement
core vs. prompt discipline. Shipping downstream is true of both and must not by itself
raise risk — an axis that fires on every artifact this repo ships stops discriminating and
dies.

## 1. Problem statement

The 0.8.0 cycle and PR #21 produced findings that were fixed but never hardened. Commit
23b842d says so in its own body: "Not done in this cycle, and owed: harden-finding on
these five." Two ledger classes — `docs-drift` and `unverified-enforcement-claim` — now
sit at six-plus occurrences each, and the ledger's own escalation reflex reads a sixth
occurrence as "escalate a rung."

That reflex is the second problem. `harden-finding` compares fingerprints only; rungs
guard *scopes*. The 2026-07-26 rows warn by name that a later in-class defect **outside**
the guarded spelling will be proposed for a stronger rung than anything justifies, and the
workaround for it lives in ledger prose, which agents do not read — they read the skill.
Daniel has now had to issue that precheck as a manual instruction, which is the parked
row's own diagnosis demonstrating itself.

Two further conditions have come due: several lessons from the cycle (single-shell test
blindness, mechanical sweep before read-pass, fixture-per-branch perf oracles, incomplete
negative bounds statements) have no ledger record at all; and one defect shape — a check
that supplies the thing it tests — has no home in the taxonomy.

A third, the ledger's missing supersession convention, is **deliberately out of this
round's scope.** Its trigger has fired — the 2026-07-20 row teaches pre-0.8.0 counting
behaviour as current, and the parked row's trigger reads "the next falsified row — this is
the second." A fired trigger that nobody records evaporates, so this round's deliverables
include opening the intake for it as its own story rather than folding a ledger-format
change into a round about rungs.

## 2. Desired outcome

Every finding from the 0.8.0 cycle and PR #21 carries a recorded disposition: a ledger row
at a rung that fits, or a parked backlog row with a stated trigger. Escalation decisions
are made against what the prior rung *claimed to guard*, not against an occurrence count —
and that reading is something the skill instructs, so the next round does it without
Daniel saying so. The ledger-supersession work leaves this round as a story of its own,
with its trigger recorded rather than remembered. And the round leaves the repository
smaller than the findings would suggest, because items that turn out to need design are
parked rather than squeezed in.

## 3. Acceptance criteria

- [ ] Each of the seven findings in this round's scope has exactly one recorded disposition
      — a `docs/hardening-log.md` row at a named rung, or a `todos.md` row with a stated
      trigger. None is left without one.
- [ ] Every escalation decision in the round records which prior row's guard was read and
      whether the finding falls inside or outside it. Outside → the fitting rung, no
      escalation. Inside → recorded as a regression of that mechanism, repaired or strengthened.
- [ ] Neither six-plus-occurrence class escalates on count alone; each row states the guard
      it was measured against and why the chosen rung fits.
- [ ] `harden-finding` instructs the guard-scope precheck, with its two branches pointing the
      direction the parked row states — the known inverted-branches hazard is named in the
      Gate-A prompt for this round and the reviewer confirms the direction.
- [ ] The parked scope-blind row records this round as its third evidence case.
- [ ] The check-supplies-its-own-input defect lands as exactly one of: an extension of the
      existing counterfactual prose, or a new class in `docs/hardening-taxonomy.md` — with
      the choice justified against that file's "before minting, grep for a near match" rule.
- [ ] A story for the ledger-supersession convention exists on disk, produced by `intake`,
      carrying that work's fired trigger and its central design question: whether the
      convention must also reach `/workflow-init`'s inline ledger-header template, since a
      repo-only fix would ship a ledger rule this kit's own ledger obeys and every
      scaffolded one does not.
- [ ] Each of the three parked rows whose trigger names the §5 template (Finding A,
      Finding B, and the cycle-record-destruction row) states that the trigger reads a
      change to §5's substance, not any touch of it.
- [ ] If the `harden-finding` edit requires anything beyond a rule paragraph — row metadata,
      fingerprint-scope fields, ledger format changes — the round stops, records evidence
      case 3 only, and the skill change becomes its own story.
- [ ] If two findings pull the same artifact in opposite directions, the round stops and
      surfaces rather than choosing.
- [ ] Validation mode `battery+check` is satisfied: the full quality battery green, plus a
      check that fails without the change, with its counterfactual stated.

## 4. Affected AGENTS.md invariants

- `## Key invariants` → `### Prompts and scaffolding` — "10. **The base taxonomy stays
  stack-neutral.** Project vocabulary … goes only in that project's
  `docs/hardening-taxonomy.md`, never into the `harden-finding` skill."
- `## Key invariants` → `### Prompts and scaffolding` — "11. **Prompt changes pass
  `docs/prompt-standards.md`** — all 12 checklist items, for any skill, command, agent
  definition, hook message, or scaffolded template."
- `## Don'ts` — "**Never replace a decision procedure without accounting for its old
  conditions.** List what the previous prose required, then mark each one kept, moved, or
  deliberately dropped."
- `## Don'ts` — "**Never describe what a gate proves without checking what it actually
  compares.**"
- `## Don'ts` — "**Never rename or delete a doc section without grepping for references
  first.**"

## 5. Open questions

- None.

## 6. Suggested size

`story` — one coherent round with one spec → plan → PR, as #16 was. Seven findings is above
that precedent's three, and the parking discipline plus the stop-on-machinery rider are what
keep it from being an epic; if either fires, the split point is already named.
