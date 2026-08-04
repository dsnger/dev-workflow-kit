# Hardening round — the 0.8.0 cycle and PR #21 — Design

**Story:** `docs/superpowers/stories/2026-08-03-hardening-round-0-8-0-and-pr-21-story.md`
— the profile lives in that story's header and is read fresh at every pass. No value from it
is copied here.

**Scope:** F1–F6 and F8 of the enumeration in §1. F7 and the `harden-finding` change are split
out (§4, §8).

**How to read this document.** It states decisions and their reasons. It does not record how
those decisions were revised — that history lives in `.context/codex-reviews/gate-a-spec-pass-*-dispositions.md`,
one file per review pass. Keeping it there is deliberate: a correction narrative inside the spec
is itself a claim that can be wrong, and this one accumulated faster than the design changed.

## 1. The findings, enumerated

The story describes these in prose and does not number them. This table is the authoritative
enumeration for the round.

**C1–C5** are this spec's labels for the five unlabelled corrections in commit `23b842d`, in
the order that commit body lists them: **C1** the `dash` prerequisite undocumented in
`AGENTS.md`; **C2** the plan's "four script runs" for a block holding five; **C3** the spec's
`codex-gate.sh:361` citation, moved by the 0.8.0 rewrite; **C4** the story's unqualified
jq-parity criterion; **C5** the README's "a typo can't quietly unhook a gate".

| # | Finding | Evidence |
|---|---|---|
| F1 | Three statements the 0.8.0 diff falsified, found by a PR bot rather than by the standing Gate-B lens | C1–C3 of commit `23b842d` |
| F2 | Two unverified claims, plus a release-evidence claim of `dash` coverage the runner never produced | C4–C5 of commit `23b842d`; `docs/superpowers/plans/2026-08-01-gate-pass-result-classification.md`, the paragraph beginning "**The `dash` run needs `HOOK_SH=dash`**" |
| F3 | A dry run that defined `$EVIDENCE` itself, so it proved the `git` mechanics and never tested that the plan defines the variable | `docs/superpowers/plans/2026-08-01-gate-pass-result-classification-execution-notes.md`, "A check that supplies the thing under test is not a check" |
| F4 | A regression test that only ever ran under macOS `sh`, while the defect it guards ships on `dash` | `plugins/dev-workflow/CHANGELOG.md`, 0.8.0, "regression test never caught it because it only ever ran under macOS" |
| F5 | Eight read-only Gate-A passes missed what thirteen machine checks then found in one sweep | the execution notes, paragraph "**The 2026-08-02 sweep was the right response and was not sufficient.**" |
| F6 | Timed regression rows whose fixtures never reach the second quadratic path they are read as bounding | the plan, "the timed rows all use large single-record payloads and never reach (b)" |
| F7 | The ledger has no supersession convention — **split out, see §8** | `todos.md`, the parked row "**The hardening ledger has no supersession convention.**" |
| F8 | A negative bounds statement that named one uncovered axis and left another uncovered and unnoticed | the plan, "It bounds the **scan**, not memory" |

## 2. What this round is

Seven findings processed through `dev-workflow:harden-finding`, each disposed at a rung chosen
by reading what the prior rung *claimed to guard* rather than by counting occurrences. **Four
hardenings** land as text — three sentences in `CLAUDE.md` §5 and one clause appended to an
existing `AGENTS.md` Don't — **four ledger rows** record them, one taxonomy class is minted, and
four follow-on stories are written.

The round does not change `harden-finding` itself. Landing the guard-scope precheck in the
skill was this round's centrepiece until it became clear the precheck cannot work without
settling what a durable record holds, how a guard citation survives the ledger's format, and
what happens when a row appears mid-run — questions a rule paragraph cannot answer (§4).

## 3. Decision record

| # | Decision | Why | Rejected alternative |
|---|---|---|---|
| D1 | The round **edits `CLAUDE.md` §5** and its shipped mirror | Three of the four hardening sites are in §5, fed by six of the seven findings. Relocating them to honour a scope preference optimizes the artifact instead of the defect | `AGENTS.md` only — the shipped lens could not be strengthened at all |
| D2 | The three parked §5 triggers are **read literally, each against its own text.** Finding A ("the next round that touches §5") and Finding B ("the next round that touches the §5 template") **fire**; the slot-collision row ("**Each Gate cycle destroys the previous cycle's review record.**", whose trigger names the §5 file protocol) **does not**, because this round never touches the file/slot protocol | They are opportunity triggers — "do this while you are already in §5" — not regression triggers. Narrowing them changes their kind, and for Finding A, whose subject is a route that does not exist yet, the narrowed form is close to unreachable | Narrowing them, which is `rewrite-drops-prior-condition` committed by a round that hardens it |
| D3 | Every trigger **this round fires** is recorded as fired and its story written as a round deliverable | A fired trigger nobody records evaporates | Taking on every trigger already fired in the backlog, which would make any round that touches §5 responsible for unrelated due work |
| D4 | F2's evidence half, F3, F4 and F6 all fingerprint **`verification-masks-failure`** and resolve at one site | Same failure: a check reports success because of how it was wired. The taxonomy prefers a reused near-miss over a precise class nobody greps | Minting two classes that then never recur |
| D5 | Each §5 edit is **one sentence at the exact existing site** | §5 is the repo's most load-bearing prompt, and a finding needing a paragraph is a finding whose home is wrong | Paragraph-sized insertions, which is how §5 accretes and how conditions get dropped |
| D6 | F2's claim half and F8 are repaired by **amending the existing 2026-07-19 `AGENTS.md` Don't**, not by adding a sibling | All three of their cases fall inside that Don't's operative instruction (§6.1), so the fitting response to a guard that did not hold is to strengthen it. A second Don't covering adjacent ground would leave two rules a reader must reconcile | A new Don't, which would record a fresh-scope hardening where a regression actually occurred |
| D7 | The `harden-finding` change is **split into its own story** and this round edits no skill file | The precheck cannot be stated without deciding what a durable record holds, how a guard citation survives the ledger format, and what happens on a mid-run collision. Those are design questions, and answering them inside a hardening round is how a round becomes a redesign | Designing it here |
| D8 | **One ledger row per landed hardening**, each carrying its motivating cases as worked examples | The ledger header says one row per hardening, and both aggregation precedents agree (2026-07-18 logged six claims as one row; 2026-07-27 logged ten instances as one row). A row per case would inflate the recurrence counts that drive escalation, in a round about escalation | One row per case |
| D9 | Version **0.8.1** | With the skill change split out, the round is `#16`'s shape — rules added to a shipped prompt and its template mirror — and `#16` took 0.7.0 → 0.7.1. The `#15` minor precedent applied to a skill's *procedure* changing, which this round does not do | 0.9.0, which follows a precedent this round does not match |

## 4. What the split story inherits

The `harden-finding` guard-scope precheck leaves this round. Its story carries these as opening
evidence, each stated as an observed failure and the question it leaves open. `dev-workflow:intake`
and `superpowers:brainstorming` divide capture from design; naming record structures, fields,
formats or state machines here would hand brainstorming a solution to ratify.

- **Observed:** a recurrence verdict was reached by reading one prior row's guard and stopping,
  when an older row's guard covered the case. **Open:** which prior rows a recurrence must be
  judged against before "outside" is a safe conclusion.
- **Observed:** a reader cannot tell whether a past rung choice followed from a guard reading or
  from an occurrence count, because nothing durable records the reading. **Open:** what a later
  reader needs in order to check a scope decision, and where it belongs.
- **Observed:** guards are frequently exact spellings containing regex alternation, and the
  ledger's stated escaping rule covers the `finding` column. **Open:** how a guard citation
  survives a Markdown table without changing what the columns mean.
- **Observed:** step 7 re-reads the ledger and then appends, so a row landing after that read is
  not seen at all, and a row seen at the read is treated as a duplicate without anyone
  consulting what it guards. **Open:** what should happen when a row appears mid-run, including
  when it is `pending` or its guard cannot be placed.
- **Observed:** widening the branch condition from "latest matching row is a real rung" to "a
  matching row exists at a real rung" makes it fire when the latest row is `pending`, bypassing
  the prerequisite rule. **Open:** how a guard scan and a prerequisite block compose.
- **Observed:** the old step-3 text required proposing one rung stronger on recurrence, and a
  replacement that chooses "the rung that fits the repair" does not carry it. **Open:** whether
  automatic escalation on recurrence is kept, narrowed, or deliberately dropped, with a stated
  reason either way.

**Evidence case 3 is recorded in this round** (§9). The parked scope-blind row earns it because
the round demonstrated the defect twice: the precheck had to be issued as a manual instruction,
and applying it by hand still produced a wrong verdict from reading a single guard.

## 5. The clause edits

Sites are cited by anchor rather than line number, because a moved line citation is F1's own C3.
Each §5 edit is one sentence and mirrors into `plugins/dev-workflow/commands/workflow-init.md`
in the same commit.

**Stated once, for all of them: each is an instruction, and nothing checks it mechanically.**
A whitespace-normalization rule for wrapped prose, a required sweep record, parser selection,
terminal states — those belong to an enforcement design, which is the split story's subject. A
sentence that grew a procedure to answer such a question would be the accretion D5 exists to
stop.

### 5.1 §5 Gate B standing lens — F1

Site: the `CLAUDE.md` §5 Gate B paragraph opening **"Standing lens, every Gate-B call:"**.
Appended:

> **Name what this diff changes the size, value or position of** — a list, a count, a version,
> an identifier, a cited line — and grep for where each is described elsewhere, because asked
> as an open question alone this lens missed three such statements in one cycle while being
> carried with unusual force.

**Diagnosis this rests on.** The lens was carried on the 0.8.0 cycle — the execution notes
record it under the heading "Standing lens, with unusual force" — and still missed C1–C3. The
three share one shape, a fact recorded elsewhere that the diff changed, and differ in which
axis moved: C1 a list's **membership**, C2 a **count**, C3 a **position**. The open question
asks for recall; enumerating needs a search.

**What this does not do.** It adds no mechanical component. Nothing runs the grep or validates
the answer.

### 5.2 §5 Profiles counterfactual — F2 (evidence half), F3, F4, F6

Site: the `CLAUDE.md` §5 Profiles paragraph containing the sentence `Either route owes the
**counterfactual**: the observation against the prior state.` Appended:

> **Name the observation that would exist if the claim were false, and confirm the wiring could
> have produced it** — a check that supplies its own input, runs where the defect cannot appear,
> or uses a fixture that never reaches the branch it covers reports success because of how it
> was wired, not because the thing it checks succeeded.

### 5.3 §5 Gate A pass procedure — F5

Site: the `CLAUDE.md` §5 Gate A bullet, after the sentence "Each pass: validate, revise,
re-run." Added:

> Before each read pass, settle mechanically what the artifact asserts and a machine can decide
> without side effects — cited paths, quoted passages, stated counts, the syntax of standalone
> fenced blocks — inspecting quoted commands rather than running them, since a command quoted
> in a spec may be destructive or an intentional failure.

### 5.4 The 2026-07-19 `AGENTS.md` Don't, amended — F2 (claim half), F8

Site: the Don't opening **"Never describe what a gate proves without checking what it actually
compares."** Its closing rule currently reads "for every sentence about a gate, name the exact
comparison the code performs, and delete any part of the sentence that outruns it." Appended to
that sentence:

> — and where the sentence says what the mechanism does *not* cover, name the axes it was
> checked against and state whether that list is exhaustive, because an enumeration read as
> complete guarantees the axes it omits.

**Why this sentence and not a looser one.** It has to reject its own motivating case. "It bounds
the **scan**, not memory" names two axes and gives each a coverage verdict, so any rule asking
only for the axes checked would approve it. What that sentence never does is declare its list
exhaustive or not — so the exhaustiveness statement is the operative requirement, and F8 fails
it.

**This does not ship downstream.** `AGENTS.md` is repo-local; `/workflow-init` scaffolds a
project's own.

## 6. The ledger rows

One row per landed hardening: four rows for four hardenings. Each row's `finding` carries its
motivating cases as worked examples, and for row C each case answers both halves of the §5.2
sentence.

| Row | Hardening | Class | Occ | Cases | `source` | `severity` | Rung |
|---|---|---|---|---|---|---|---|
| A | §5.1 lens strengthening | `docs-drift` | 5 | C1, C2, C3 | `bot` | `major` | `P std` |
| B | §5.4 Don't amendment | `unverified-enforcement-claim` | 5 | F8 | `gate-a` | `major` | `1 prose` |
| C | §5.2 counterfactual sentence | `verification-masks-failure` | 2 | `$EVIDENCE`, single-shell test, timed row, `dash` release evidence | `gate-b` | `major` | `P std` |
| D | §5.3 Gate-A sweep sentence | `mechanical-check-skipped-before-review` | new | the eight-pass/thirteen-check sweep | `manual` | `major` | `P std` |

Row D's class is minted in §6.5.

**C4 and C5 are dispositioned in `todos.md`, not in a ledger row**, because no hardening is
available for them. Both fall inside the 2026-07-19 Don't, whose operative instruction already
requires exactly what they failed to do — name the exact comparison the code performs, and
delete any part of the sentence that outruns it. The rule was correct and was not followed,
twice. That is a compliance recurrence, and a ledger row would have to name a repair that does
not exist: §5.4's clause governs sentences about what a mechanism does *not* cover, so it
strengthens F8's shape and reaches neither a positive parity claim nor a positive prevention
claim. The parked row records the signal instead, with its trigger: **a third compliance miss
against that Don't, or a feasible mechanical rung emerging from the split skill story.**

### 6.1 Precheck verdicts, recorded per case

**Row A is inside** the 2026-07-27 lens: it was carried and missed all three cases. The row
records a regression repaired at the same rung.

**F8, C4 and C5 are all inside the 2026-07-19 Don't.** Its operative instruction is *"for every
sentence about a gate, name the exact comparison the code performs, and delete any part of the
sentence that outruns it"* — scoped to **every sentence about a gate**, not to comparison claims
alone.

- **F8** — "It bounds the **scan**, not memory" is a sentence about the gate's scanner whose
  implication outran the length comparison the code performs. Its literal content is true; the
  defect is what the enumeration implies about the axis it omits. **The scope of a claim is part
  of the claim**, so an implied guarantee is still one the mechanism does not deliver.
- **C5** — the README claimed a typo cannot quietly unhook a gate, a claim about what the gate's
  matching prevents, made without checking what the parser compares.
- **C4** — the jq-parity criterion claimed unqualified parity between the routing paths,
  outrunning what `field()` compares for a malformed outer document.

**They divide on whether a repair exists.** F8's shape — an enumeration read as complete — is
one the Don't did not spell out, so amending it closes a real gap, and D6 follows: strengthen
that Don't rather than add a sibling. C4 and C5 needed nothing the Don't does not already say;
they are compliance misses, and §5.4's clause does not reach a positive claim. Row B therefore
carries F8 alone, and C4/C5 are parked (§6 above, §9).

**Row C is outside** every prior guard. The only prior `verification-masks-failure` row is
2026-07-20, whose `ref` states its own scope — "nothing checks new plans for the same shape".

**Row D** has no prior matching row.

### 6.2 `source`

Row A is `bot`: C1–C3 all came from the PR bot on #21.

Row B is `bot`: C4 and C5 from the PR bot, F8 from Gate A on the plan.

Row C's four cases split evenly: `$EVIDENCE` from Gate A on the plan (pass 9) and the
single-shell test from Gate A on the plan (recorded in
`.context/codex-reviews/gate-a-plan-pass-5-dispositions.md`); the timed row from Gate B
(`.context/codex-reviews/gate-b-quality-pass-3.md`) and the `dash` release-evidence claim from
Gate B pass 1. Two and two, so the tie-break applies: the **`dash` release-evidence case is what
triggered this hardening**, and it is Gate B. Row C is **`gate-b`**.

Row D is `manual`: the sweep-versus-passes comparison was drawn while closing the cycle, not
raised by a gate.

Where a row's cases differ, `source` takes the majority and the row states the mixed
provenance, following the 2026-07-18 precedent that records "Gate A as the majority and the
trigger". Where no value holds a majority, take the plurality; where the plurality is tied,
take the case that triggered the hardening.

`severity` is `major` for all four: each let a defect through a check believed to cover it.

### 6.3 Occurrence counting

**An occurrence is one ledger event — a defect reaching the ledger and being hardened — not a
distinct defect and not a physical row.** A row that resolves a `pending` predecessor hardens a
defect already counted, so it adds a row without adding an occurrence; and a row may aggregate
several defects under one hardening and count once, because the ladder escalates on how many
times a class has been hardened and come back, not on how many sentences were wrong.

By that unit `docs-drift` reaches 5 here (2026-07-18 twice, 2026-07-25 as `pending`, 2026-07-26
resolving it, 2026-07-27 as the fourth) and `unverified-enforcement-claim` reaches 5
(2026-07-18, 2026-07-19, 2026-07-25 as `pending`, 2026-07-26 resolving it, 2026-07-27 as the
fourth, which is the count that row states for itself).

### 6.4 Where the audit text goes

The precheck reading is acceptance-critical (story AC 2) and the structured format for it is
split out, so this round records it in the columns the ledger already has — no schema change.
Each of rows A–C appends, inside `ref`: the **controlling prior row** by date and fingerprint;
its **guard**, quoted or cited precisely enough to re-find; the **verdict per motivating case**
where they differ; and **why the chosen rung fits**, in one clause. Row D records that it has no
prior matching row, plus its rung rationale.

A literal `|` inside quoted guard text is escaped `\|`, as the ledger header requires for
`finding`. Extending that rule to `ref` formally is one of the split story's open questions
(§4), so this round avoids guard quotations containing pipes rather than relying on an unstated
rule.

**Concurrency, stated as the gap it is.** This round appends after step 7's re-read. A
same-fingerprint row visible at that read is surfaced and the round stops rather than guessing
whether the two hardenings share a scope. A row landing *after* the read is not detected — step
7 offers no observation point past it, and supplying one is the split story's subject. This
round runs single-writer and claims nothing stronger.

### 6.5 The minted class

`docs/hardening-taxonomy.md` gains:

> - `mechanical-check-skipped-before-review` — an artifact carrying machine-checkable assertions
>   goes to an expensive read pass before anything parses it, so attention is spent on what a
>   tool decides in seconds. Aliases: `sh -n` after the fact, the parser would have caught it,
>   read pass before the sweep, manual review of machine-decidable claims.

Its boundary against `verification-masks-failure`: there, a check ran and could not fail; here,
the cheap check never ran at all.

The class is stack-neutral rather than project vocabulary. It lands in the project file anyway,
because the skill instructs minting there and that file's closing note records the same of
several classes already in it, flagging them for promotion when the base taxonomy is next
revised. Moving it into the base list would be a skill edit, which D7 excludes.

## 7. Story amendments

The story carries an `**Amendment log:**` block beneath its profile header, one entry per
amendment. An entry that replaces text names the text it replaced; one that extends a section
names what was added. The story is the writable copy, and this section does not restate the
entries.

## 8. The four split stories

Four story files at `docs/superpowers/stories/YYYY-MM-DD-<topic>-story.md`. A note or a
commit-body summary does not satisfy this: the point is an artifact that outlives the session.

**They are written directly rather than produced by `dev-workflow:intake`, and each file says
so.** Intake excludes "items that already have an approved story/spec or have moved into
solution design", and all four are that: three carry cut-short design analysis from earlier
rounds, and the fourth (F7) is the ledger-format work this round declined to fold in and has
already scoped. Making an intake-produced artifact acceptance-critical would deadlock the round
against a skill that declines the input.

**Each file uses the story template's six sections and its `**Date:**`/`**Size:**` header line,
and deliberately omits the profile line** — that is the only departure, and each file names it.
A profile is proposed and human-confirmed at intake time; written now it would be a
confirmed-looking value nobody confirmed, which §5 classifies as unresolvable and stops on.

**The debt is carried as each story's first acceptance criterion**, not as a claim about a later
process: *"the story's profile — both axes and the derived mode — is proposed and confirmed by
Daniel before design begins."* Nothing else would pick it up: `intake` declines work already in
solution design, `brainstorming` does not assess profiles, and CLAUDE.md §5 proceeds when a
cited story is unprofiled. A sentence saying the profile is "owed at pickup" would name no owner
and no step, which is the unbacked-claim shape this round hardens; a criterion inside the
artifact is checkable by whoever picks it up.

**Each story inherits its source row's conditions, accounted for.** Three of the four replace a
parked `todos.md` row that carries settled analysis, and the `AGENTS.md` Don't "Never replace a
decision procedure without accounting for its old conditions" applies to that replacement as
much as to any rule: each story lists every condition its source row states and marks it kept,
moved, or deliberately dropped. A thinner brief that quietly discards a matured constraint is
the failure mode, and it is acceptance-critical, not advisory.

**Paths are fixed, and collisions stop the round.** Each story's path is named below. Missing →
write it; byte-identical → reuse it and say so; present and different → stop and surface rather
than overwrite, per invariant 9's rule for scaffolded files.

**The round is incomplete until all four exist.** If one cannot be grounded — no statable
problem, outcome, or three checkable criteria — that is a stop-and-surface: say which and why,
rather than padding a story into existence.

1. **The `harden-finding` guard-scope precheck** →
   `docs/superpowers/stories/2026-08-04-harden-finding-guard-scope-precheck-story.md`.
   Opening evidence: the six items in §4. No source row is replaced; the parked scope-blind row
   remains open and points here (§9).
2. **The ledger's supersession convention (F7)** →
   `docs/superpowers/stories/2026-08-04-hardening-ledger-supersession-story.md`. Trigger fired:
   the 2026-07-20 row now teaches pre-0.8.0 counting behaviour as current, the second falsified
   row its parked trigger names. Conditions to account for, from that row: the append-only rule,
   the one-row-per-hardening rule, and the version-qualified supersession note that already
   worked once in the 2026-07-20 spec. Open question: which artifacts a supersession rule has to
   reach before a reader can trust any row — this repo's ledger alone, or every ledger
   `/workflow-init` scaffolds.
3. **A route from a fixed finding to the ledger, for projects that never open PRs (Finding A)** →
   `docs/superpowers/stories/2026-08-04-ledger-route-without-pull-requests-story.md`. Trigger
   fired: "the next round that touches §5". Evidence: the only mandated ledger check lives in
   `process-pr-review` step 5, and one project has 51 Gate-A pass files and zero ledger rows.
   Conditions to account for: the scope must match that step exactly — every accepted actionable
   fixed finding checked, `harden-finding` invoked only when a class matches or a new one is
   clearly warranted — and it cannot rest on same-session memory. Open question: what has to be
   true for a fixed finding to reach the ledger without a pull request.
4. **A §5 version stamp (Finding B)** →
   `docs/superpowers/stories/2026-08-04-section-5-version-stamp-story.md`. Trigger fired: "the
   next round that touches the §5 template". Conditions to account for: the semantic §5 locator
   problem, per-state merge semantics under invariant 9, stamp cardinality (absent, duplicate,
   malformed), and that the binding must hold on every push path — the version-bump coupling is
   false, since invariant 12's checker is `pull_request`-only. Open question: how a scaffolded
   `CLAUDE.md` can tell its reader that it lags the installed plugin.

**Not fired:** the slot-collision row, whose trigger names the §5 **file protocol**. This round
changes no part of it — not the slot names, not the pre-call delete, not the terminator or
acceptance rules.

## 9. Other deliverables

- **`todos.md`, the scope-blind row** — records this round as its **third evidence case**, and
  points at the split story (§8 item 1) rather than being marked resolved, because the fix it
  sketched has not landed.
- **`todos.md`, the three §5-trigger rows** — Finding A and Finding B marked **fired**, each
  pointing at its story path from §8; the slot-collision row records that it did **not** fire,
  and why.
- **`todos.md`, the ledger-supersession row** — marked **fired** and pointed at §8 item 2's
  story path. Its conditions stay in the row; only its status changes. Left unmarked, the row
  reads as live work and a later session can open a second story for it.
- **`todos.md`, the `CLAUDE_CODE_MCP_AUTO_BACKGROUND_MS` row** — **stays open; an observation is
  appended.** With the variable set to `0`, Gate-A passes 2–6 of this cycle ran 458 s, 550 s,
  757 s, 663 s and 780 s, all staying in the foreground and returning ordinary `success: true`
  envelopes the hook could read; pass 1 was not timed. Start and end stamps are tabulated in
  `.context/codex-reviews/gate-a-spec-resume.md`. **No control run was made** with the variable
  unset, so this is a correlation under one setting, not a demonstration that the variable held
  those calls in the foreground; what it establishes is that calls well past 120 s can return as
  ordinary foreground results here. The row stays open because its deliverable is a
  `/workflow-init` preflight check, which is unbuilt.
- **`todos.md`, a new parked row for C4 and C5** — the 2026-07-19 Don't is correct and was not
  followed twice; no textual repair is available, because its operative instruction already
  requires what both cases omitted. *Trigger: a third compliance miss against that Don't, or a
  feasible mechanical rung emerging from the split skill story (§8 item 1).*
- **`docs/hardening-taxonomy.md`** — the §6.5 class.
- **`plugins/dev-workflow/.claude-plugin/plugin.json`** — `version` to `0.8.1`, required by
  invariant 12.
- **`plugins/dev-workflow/CHANGELOG.md`** — a `## 0.8.1` entry, newest first.

## 10. Validation evidence

The mode is read from the story header at each pass. As of this writing it derives
`battery+check`.

**battery** — the full quality command from `AGENTS.md § Commands`, green.

**check — a named verification, with its counterfactual.** Automation is not available: the
thing under test is whether a prompt sentence rejects a case, which is a reading.

**The four inputs, fixed here so the verification is reproducible.**

1. **`$EVIDENCE` dry run.** Claim: the plan defines `$EVIDENCE` before three commit commands
   read it. Wiring: a scratch-clone dry run that assigned `$EVIDENCE` itself before invoking the
   commands. Falsifying observation: the commands failing on an unset variable — which this
   wiring cannot produce, because it sets the variable the plan was supposed to set.
2. **Single-shell regression test.** Claim: the hook survives a directory at a marker path.
   Wiring: a regression test invoking the hook through macOS `sh`. Falsifying observation: a
   non-zero exit from the `:` special builtin, which appears under `dash` and not under macOS
   `sh`, so this wiring cannot produce it.
3. **Timed regression row.** Claim: the timed rows establish the scan's runtime across the
   payloads the ceiling admits. Wiring: timed fixtures built from large **single-record**
   payloads. Falsifying observation: a newline-rich payload *under* the ceiling costing far more
   than the measured shapes — the record accumulator is quadratic in line count, which no
   single-record fixture reaches. The ceiling keeps the work finite, so the falsifying
   observation is a runtime far outside the measured range, not an unbounded one.
4. **`dash` coverage in release evidence.** Claim: the suite ran under both shells. Wiring:
   `dash codex-gate.test.sh` without `HOOK_SH=dash`, which runs the harness under `dash` and the
   hook under `/bin/sh` — bash, on macOS. Falsifying observation: a hook-level `dash` failure,
   which this wiring cannot produce because the hook never ran under `dash`.

**The verification.** Apply §5.2's sentence, as worded, to all four. **Each must fail**, on its
second half. Separately, apply §5.4's appended clause to "It bounds the **scan**, not memory" —
**it must fail too**, on the exhaustiveness requirement. If any case passes the sentence written
to reject it, that sentence is miswired and the verification fails.

**The counterfactual.** All four were reviewed during the 0.8.0 cycle under the §5 text as it
reads today, and each was accepted by at least one review looking for exactly this — the
`$EVIDENCE` case survived eight read passes. Of the four, one reached the released artifact: the
single-shell test, whose failure the 0.8.0 changelog records as why an invariant-1 violation
shipped. That test also predates the counterfactual text, which landed 2026-07-27 in `27d019b`,
so the current wording had no opportunity to prevent its authoring — only to catch it later,
which it did not.

**What is deliberately not claimed.** The old text is not re-applied as a pass/fail oracle. It
asks for "the observation against the prior state" and says nothing about wiring, so applying it
yields no determinate verdict on the question the four cases turn on — which is the gap §5.2
closes.

**Prompt conformance.** Invariant 11 requires all 12 items of `docs/prompt-standards.md` for
"any skill, command, agent definition, hook message, or scaffolded template". Of everything this
round changes, exactly one file is inside that surface:
`plugins/dev-workflow/commands/workflow-init.md`, both a command and the carrier of the
scaffolded §5 template. It gets a recorded 12-item review in which **all 12 must pass** — an
exception only where the checklist item itself authorizes one (items 9 and 12 do), recorded with
that item's stated reason.

`CLAUDE.md` and `AGENTS.md` are not on that list, and demanding all 12 of them is unsatisfiable
rather than strict: neither carries a `Target model:` line or an output-format example, because
neither is executed against a named model. Their edits are reviewed against the items that apply
to a rule statement — 6, 7, 8, 9, 11 and 12 — with the result recorded. §5.4's appended clause is
phrased as a continuation of an existing prohibition; item 9's own text exempts rules whose
subject is the prohibition, and that exemption is cited in the record rather than assumed.

The four split stories are agent inputs, and `docs/prompt-standards.md` holds briefs to the
checklist in spirit. Each gets a recorded in-spirit review — success criteria, stop conditions,
verified claims — without asserting the mandatory 12 apply.

**Mirror parity.** For each of the three §5 sentences, confirm the inserted text is identical in
`CLAUDE.md` and `workflow-init.md` and sits under the same heading in both. The battery does not
compare them, and a sentence landing in one copy only is the shipped-template drift this repo
treats as load-bearing.

**Cross-finding conflict check** (story AC 10). Before applying any edit, check whether two
findings pull one artifact in opposite directions; if so, stop and surface rather than choosing.
Current verdict: no conflict. The four hardenings touch four distinct sites — the Gate-B lens
paragraph, the Profiles counterfactual paragraph, the Gate-A pass bullet, and the 2026-07-19
Don't — and none rewrites text another needs.

## 11. Gate-A riders, verbatim in every pass prompt

1. **Sweep before reading.** Mechanically settle whatever this spec asserts that a machine can
   decide without side effects — cited paths, quoted passages, counts, durations, section
   numbering and internal cross-references. Inspect quoted commands rather than running them.
   Several source files are hard-wrapped, so compare code byte-for-byte and prose with
   whitespace normalized, and report a wrap artifact as a wrap artifact. Report what the sweep
   found separately from what the read found.
2. **Two self-tests.** Apply §5.2's sentence to the four cases in §10 — each must fail. Apply
   §5.4's appended clause to "It bounds the scan, not memory" — it must fail. Report both
   explicitly either way.
3. **Per-case precheck audit.** §6.1 records a verdict per motivating case against the prior
   rows it names. Check each verdict against the guard text it cites.

## 12. What this round does not do

- It adds no mechanical check. Every rung is `P std` or `1 prose`; a reader is the detection.
- It does not claim the strengthened lens catches the class. It sharpens one question and names
  a search; nothing runs the search.
- It changes no skill file. The guard-scope precheck, and every determinism question raised
  about it, belong to the split story (§4).
- It does not resolve the ledger's supersession gap, the no-PR ledger route, or the §5 version
  stamp. §8 writes the stories; until they land, the 2026-07-20 row still reads as current.
- It does not detect a same-fingerprint row landing after step 7's re-read (§6.4).
- §5.4's amendment reaches this repository only. Downstream projects inherit the three §5
  sentences, not the `AGENTS.md` Don't.
