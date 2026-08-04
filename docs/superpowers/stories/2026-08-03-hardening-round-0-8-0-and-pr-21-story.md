# Hardening round — the 0.8.0 cycle and PR #21 — Story

**Date:** 2026-08-03 · **Size:** story
**Risk:** standard · **Security:** none · **Validation:** battery+check

**Amendment log:**
- 2026-08-04 · AC added (the P8 criterion) · the round's acceptance criteria covered the four
  stories designed up front and said nothing about a parked row whose trigger the round's own
  output crosses · both Gate-B pass 1 reviewers found that the four appended ledger rows take
  the ledger from 18 to 22, past P8's stated 20-row threshold, and D3 makes a trigger this round
  fires a round deliverable. Without the criterion the round could satisfy every stated
  criterion while omitting a deliverable D3 required, so the criterion was added rather than the
  omission argued away. Raised at Gate-B pass 1; the fifth story and the eighth `todos.md` row
  change landed in the same commit.
- 2026-08-03 · AC 1 amended · replaced "has exactly one recorded disposition" with the
  current wording · a finding whose halves fall in different fingerprint classes needs a
  disposition in each; F2's two halves are `unverified-enforcement-claim` and
  `verification-masks-failure`, and forcing one row would file one of them under a class it
  does not belong to. Raised at Gate-A spec pass 1.
- 2026-08-03 · AC 8 replaced · it read "Each of the three parked rows whose trigger names the
  §5 template (Finding A, Finding B, and the cycle-record-destruction row) states that the
  trigger reads a change to §5's substance, not any touch of it." · it now reads "Each of the
  three parked rows whose trigger names §5 is read literally against its own text, and the
  round records which fired and which did not, with the reason." · the old wording encoded a
  misreading of those rows as regression triggers. They are opportunity triggers — "do this
  while you are already in §5" — and narrowing them would be `rewrite-drops-prior-condition`
  committed by a round that hardens it. The round now honours them as written: Finding A and
  Finding B fire and their intakes are opened; the cycle-record row does not fire. Raised at
  Gate-A spec pass 1; the entry said "removed" until Gate-A spec pass 3 caught that the story
  carries a replacement.
- 2026-08-04 · AC 1 re-amended · the pass-1 amendment replaced "has exactly one recorded
  disposition" with "is dispositioned", which solved F2's split by deleting uniqueness for
  every finding · uniqueness is restored per class: exactly one disposition per finding, and
  for a finding whose halves fall in different fingerprint classes, exactly one per half.
  Raised at Gate-A spec pass 3.
- 2026-08-04 · AC 4 replaced · it required `harden-finding` to instruct the guard-scope
  precheck · the skill change is split into its own story, and the criterion now requires that
  story to exist carrying its named opening evidence · Gate-A spec pass 3 produced four
  findings independently demanding row metadata, a ledger format change and a collision state
  machine. That is the machinery exit AC 9 names, and it fired on evidence rather than on
  judgement.
- 2026-08-04 · AC 7 replaced · it named one intake and specified its "central design question"
  · three intakes are now required, and each criterion states problem, evidence and open
  question rather than a solution · `dev-workflow:intake` forbids HOW outside its invariant
  quotations, so the old wording asked for an artifact intake cannot conformantly produce.
  Raised at Gate-A spec pass 3.
- 2026-08-04 · AC 9 amended · it stated the machinery exit as a conditional · it now records
  that the condition fired, so the criterion is a completed action rather than a standing test.
- 2026-08-04 · §1 corrected · it said the check-supplies-its-own-input shape "has no home in
  the taxonomy" · `verification-masks-failure` already covers it; what the shape lacked was a
  recorded application, not a class. Raised at Gate-A spec pass 3.
- 2026-08-04 · §4 extended · invariant 12 added · the round changes paths under
  `plugins/dev-workflow/`, so the manifest version gates it. Raised at Gate-A spec pass 3.
- 2026-08-04 · §1 and AC 3 corrected · both said the two classes sit at "six-plus
  occurrences" · each lineage calls its 2026-07-27 row the fourth, so four is the prior count
  and this round makes five. An unchecked count in the premise of a round about count-blind
  escalation. Raised at Gate-A spec pass 4.
- 2026-08-04 · AC 7 amended · it required each story to say it "owes a profile at pickup" · it
  now requires each story to carry, as its first acceptance criterion, that its profile — both
  axes and the derived mode — is proposed and confirmed by Daniel before design resumes · the
  old wording named no owner and no step, and nothing would have picked the debt up: `intake`
  declines work already in solution design, `brainstorming` does not assess profiles, and
  CLAUDE.md §5 proceeds when a cited story is unprofiled. Raised at Gate-A spec pass 8.
- 2026-08-04 · §1 diagnosis corrected · it said the scope-blind workaround "lives in ledger
  prose, which agents do not read — they read the skill" · `harden-finding` step 3 does say to
  re-read the log, so the premise was false; the defect is that the decision branch keys on
  fingerprint and latest rung without letting the row's guard control the verdict. A round
  about unverified claims resting on one. Raised at Gate-A spec pass 7.
- 2026-08-04 · AC 4 and AC 7 re-amended · both required the four stories to be "produced by
  `intake`" · they now require the files written directly in the story template's shape and
  unprofiled · `intake` excludes items that have moved into solution design, which three of the
  four are, so making an intake-produced artifact acceptance-critical would deadlock the round
  against its own tooling. Unprofiled because a profile is proposed and human-confirmed at
  intake time; written now it would be a confirmed-looking value nobody confirmed. Raised at
  Gate-A spec pass 6.
- 2026-08-04 · AC 4, AC 9 and §2 rewritten · they named the split work as solution forms
  ("multi-row guard scan", "per-row audit record", "row metadata", "ledger format change",
  "collision state machine") · they now name the observed failures and the questions left open,
  because `intake` forbids HOW and a criterion demanding named machinery would make a
  conformant story fail acceptance. §2's "each row records that reading" also became "each row
  with a prior matching row", since the new-class row has none. Raised at Gate-A spec pass 5.

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
these five." Two ledger classes — `docs-drift` and `unverified-enforcement-claim` — each
stand at **four** prior occurrences, both lineages calling their 2026-07-27 row the fourth,
and this round makes each the fifth. The ledger's own escalation reflex reads a recurrence as
"escalate a rung" regardless of what the prior rung guarded.

That reflex is the second problem, and it sits in the decision rather than in the reading.
The skill's recurrence step does have you re-read the ledger. What it does not do is let the
row's stated guard control the verdict: the branch keys on a fingerprint match and the latest
row's rung, so a later in-class defect **outside** the guarded spelling is proposed for a
stronger rung than anything justifies — exactly what the 2026-07-26 rows warn about by name.
That warning lives in ledger prose the branch never consults. Daniel has now had to issue the
precheck as a manual instruction, which is the parked row's own diagnosis demonstrating itself.

Two further conditions have come due: several lessons from the cycle (single-shell test
blindness, mechanical sweep before read-pass, fixture-per-branch perf oracles, incomplete
negative bounds statements) have no ledger record at all; and one defect shape — a check
that supplies the thing it tests — has a taxonomy home in
`verification-masks-failure` but no recorded application of it, so the class reads as a
one-off rather than as the recurring shape it is.

A third, the ledger's missing supersession convention, is **deliberately out of this
round's scope.** Its trigger has fired — the 2026-07-20 row teaches pre-0.8.0 counting
behaviour as current, and the parked row's trigger reads "the next falsified row — this is
the second." A fired trigger that nobody records evaporates, so this round's deliverables
include opening the intake for it as its own story rather than folding a ledger-format
change into a round about rungs.

## 2. Desired outcome

Every finding from the 0.8.0 cycle and PR #21 carries a recorded disposition: a ledger row
at a rung that fits, or a parked backlog row with a stated trigger. Escalation decisions in
this round are made against what the prior rung *claimed to guard*, not against an occurrence
count, and each row with a prior matching row records that reading so a later reader can check
it. Making the skill
instruct that reading turned out to be a design rather than a paragraph, so it leaves as its
own story with its evidence named. The ledger-supersession work leaves the same way, and so
do the two §5 triggers this round fires. The round leaves the repository smaller than the
findings would suggest, because items that turn out to need design are split rather than
squeezed in.

## 3. Acceptance criteria

- [ ] Each of the seven findings in this round's scope carries exactly one disposition — a
      `docs/hardening-log.md` row at a named rung, or a `todos.md` row with a stated trigger.
      A finding whose halves fall in different fingerprint classes carries exactly one per
      half, and the round names which halves those are. None is left without one, and none
      carries two dispositions in the same class.
- [ ] Every escalation decision in the round records which prior row's guard was read and
      whether the finding falls inside or outside it. Outside → the fitting rung, no
      escalation. Inside → recorded as a regression of that mechanism, repaired or strengthened.
- [ ] Neither recurring class escalates on count alone; each row states the guard it was
      measured against and why the chosen rung fits.
- [ ] A story for the `harden-finding` guard-scope precheck exists on disk, written directly in
      the story template's shape and unprofiled, carrying as opening evidence the failures this
      round observed — a verdict
      reached by reading one prior row and stopping, a rung choice no later reader can check,
      a guard citation the ledger's escaping rule does not cover, a same-fingerprint row
      treated as a duplicate without reading what it guards, a branch condition that bypasses
      an unresolved prerequisite, and an escalation instruction recorded as moved while
      nothing carried it — each with the question it leaves open and none with a solution, since
      the design is brainstorming's to do. Like the other three, it carries as its first
      acceptance criterion that its profile is proposed and confirmed by Daniel before design
      resumes.
- [ ] The parked scope-blind row records this round as its third evidence case.
- [ ] The check-supplies-its-own-input defect lands as exactly one of: an extension of the
      existing counterfactual prose, or a new class in `docs/hardening-taxonomy.md` — with
      the choice justified against that file's "before minting, grep for a near match" rule.
- [ ] Three stories exist on disk, each written directly in the story template's shape and
      unprofiled, each carrying the trigger that fired and the evidence it fired on — the
      ledger-supersession convention, the no-PR route from a fixed finding to the ledger, and
      the §5 version stamp. Each states its problem and its open question, and each says it is
      a split from a designed round, and each carries as its first acceptance criterion that its
      profile — both axes and the derived mode — is proposed and confirmed by Daniel before
      design resumes.
- [ ] Each of the three parked rows whose trigger names §5 is read literally against its own
      text, and the round records which fired and which did not, with the reason.
- [ ] **Added at Gate-B pass 1.** Any parked row whose trigger this round's own output crosses is
      read the same way, marked fired, and given its story as a round deliverable — which at
      minimum covers P8, whose "10 stories or 20 ledger rows" threshold the four appended rows
      cross (18 → 22). A fifth story exists on disk on the same terms as the other four —
      written directly in the story template's shape, unprofiled, carrying its source row's
      conditions marked kept, moved or dropped, and carrying the profile-confirmation criterion
      first — and `todos.md` carries the eighth row change that marks P8 fired.
- [ ] **Fired at Gate-A spec pass 3.** Making the precheck work turned out to require decisions
      about what a durable record holds, how a guard citation survives the ledger's format, and
      what happens when a row appears mid-run — more than the rule paragraph this criterion
      budgeted. The round therefore records evidence case 3, carries no edit to
      `harden-finding`, and the skill change became its own story.
- [ ] If two findings pull the same artifact in opposite directions, the round stops and
      surfaces rather than choosing.
- [ ] Validation mode `battery+check` is satisfied: the full quality battery green, plus a
      check that fails without the change, with its counterfactual stated.

## 4. Affected AGENTS.md invariants

- `## Key invariants` → `### Prompts and scaffolding` — "10. **The base taxonomy stays
  stack-neutral.** Project vocabulary — tables, auth helpers, framework APIs — goes only in
  that project's `docs/hardening-taxonomy.md`, never into the `harden-finding` skill. Otherwise
  one project leaks into every other."
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
- `## Key invariants` → `### Packaging` — "12. **A plugin change requires a version bump.** A
  pull request that changes any path under a `plugins/<name>/` directory **that still exists
  at HEAD** — `examples/` included, and no exemptions among the paths inside such a directory
  — must also change that plugin manifest's `version`, or CI fails."

## 5. Open questions

- None.

## 6. Suggested size

`story` — one coherent round with one spec → plan → PR, as #16 was. Seven findings is above
that precedent's three, and the parking discipline plus the stop-on-machinery rider are what
keep it from being an epic; if either fires, the split point is already named.
