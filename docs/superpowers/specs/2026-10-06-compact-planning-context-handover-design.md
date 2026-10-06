# Compact planning, matching Gate A, task context and session handover — Design

**Date:** 2026-10-06
**Story:** `docs/superpowers/stories/2026-10-06-compact-planning-context-handover-story.md` (read its profile fresh)

This spec follows the contract it introduces: it fixes commitments and leaves wording and
local choices to the plan and the implementer.

## 1. Placement and what stays unchanged

The working contract (§2) goes into the **`CLAUDE.md` template** of `/workflow-init`
(`### 2.1`), as a new subsection of §4 *Goal-Driven Execution*, and into this repository's
own `CLAUDE.md` §4. The placement relies on a fact about the current client — it loads
`CLAUDE.md` at session start, so the contract is in context before `writing-plans` runs —
which AC-2 verifies in the actual planning workflow; the rule text itself does not depend on
it (AC-19). Rejected: a new skill (nothing guarantees it is loaded
while planning) and the gate rules alone (read before a gate, which is after planning).

The Gate-A review questions (§3) go into the gate rules: `.claude/review-gates.md` in this
repository and the `### 2.1a` template, in the "Gate A — Spec, then plan" bullet.

Unchanged (AC-5): the findings-file protocol, the derived floor, the closure ordering,
severity rules, reviewer independence, the profile and evidence rules, and every security
requirement. The change only frames the Gate-A review question, which the gate rules' own
membership test ("prompt wording that only frames the review question") places outside the
closure contract.

## 2. The working contract (`CLAUDE.md` §4 subsection)

It must state, compactly:

1. **Roles (AC-1).** Spec, plan and code decide what AC-1 lists; short algorithm sketches
   and bounded feasibility probes stay available where they resolve a named uncertainty.
2. **Precedence (AC-2).** Where an installed `writing-plans` asks for code blocks in code
   steps, complete test code, or repeating code instead of referring to an earlier step,
   this subsection governs (user instructions outrank skills).
3. **Local choices (AC-4).** Implementers decide locally within approved commitments. A
   change to an *approved commitment* about product behaviour, a shared contract, a security
   guarantee or scope follows the existing decision and amendment route; implementing the
   approved behaviour does not.
4. **Context (AC-18).** The reading list and the on-demand rule for history exactly as
   AC-18 states them — by kind of task, with the dependency-change and interface-change
   examples, and naming the relevant configuration, realistic data volumes and target
   environments — including that binding reading duties stay and that "reference" does not
   make binding conditions optional. A short **Sources and impact boundary** note goes in
   the existing plan, or, for a task without a plan, in its existing work record; no
   separate report document.
5. **Splitting (AC-8).** Before a large spec: check for independently reviewable outcomes
   with identifiable shared contracts; touching several features is a signal to examine,
   not a reason to split; size is a warning, with no fixed cap.
6. **Session change (AC-16).** The plan names its **handover boundary**: normally the
   completed story or an independently executable sub-plan; a closed gate cycle may be
   chosen as an earlier boundary; never inside a running cycle. At the boundary the agent
   writes the handover (verified state and next task, open obligations and unresolved
   decisions, artifact and evidence paths, cycle identity and status) and stops. The
   handover is a **current summary**: it carries every open obligation in full, including
   one still recorded only in an earlier state, and links earlier states (a commit, an
   archived note) instead of appending a full status report each time; the next
   unit starts in a fresh session. Without an existing, approved mechanism for changing
   session, the human starts it. Handover file: the project's existing mechanism if it has
   one, otherwise `.context/handover-<unit>.md`, one file per unit so parallel units do not
   overwrite each other. The interrupted-cycle resume rules in the gate rules stay as they
   are. No context percentage or token estimate.

7. **Model and client independence (AC-19).** The added text names no model, effort level,
   context size or loading mechanism. The client- and skill-specific facts this design relies
   on — when the client loads `CLAUDE.md`, and that `writing-plans` 6.4.1 asks for code in
   plans — are recorded with their checked version in `todos.md` § Tooling revalidation, the
   kit's existing place for re-verifiable tool assumptions, so a model, client or skill change
   re-checks them against existing tasks and evidence.

The `CLAUDE.md` template must stay within check 4e's budget.

**Changed 2026-10-06 — changed requirement.** Decided by Daniel in the Claude Code session of
2026-10-06 (about 12:21): "Die Agentenanweisungen erklären, bei welchen Aufgaben welche
Quellen gelesen werden müssen." / "Keine festen Modellnamen, Effort-Stufen, Kontextgrößen
oder heutigen Ladeverfahren in den fachlichen Regeln verankern." / "Bei einem Wechsel von
Modell, Client oder wesentlichen Skills werden betroffene Annahmen gezielt anhand vorhandener
Aufgaben und Nachweise überprüft." Baseline: a1bc65d. The story's matching change (AC-15
replaced by AC-18; AC-19 added) is its dependent artifact. Item 7 is new, per the second and
third quoted passages; it replaces no earlier condition.

| Earlier condition | Fate | AC operation |
|---|---|---|
| §1 placement: "`CLAUDE.md` is loaded at session start, so the contract is in context before `writing-plans` runs" | kept, reworded as a fact about the current client that AC-2 verifies, per the decision: "Keine … heutigen Ladeverfahren in den fachlichen Regeln verankern." | none |
| §2 item 4, the context rule as AC-15 stated it | kept; moved → item 4 citing AC-18, which ties sources to the kind of task, per the decision: "Die Agentenanweisungen erklären, bei welchen Aufgaben welche Quellen gelesen werden müssen." | none |
| §2 items 1–3, 5, 6; §3 … §9 and the change record at the end of §7 | kept | none |

- **Unaccounted:** none.
- **Intervening changes:** none — the file is unchanged between a1bc65d and this change.
- **Scope boundary:** in: §1's placement sentence, §2 items 4 and 7. out: the documentation structure, which belongs to `docs/superpowers/stories/2026-10-06-living-feature-docs-pilot-story.md`; any change to model configuration or review validity.
- **Open questions:** none.
- **Dependent artifacts:** `docs/superpowers/stories/2026-10-06-compact-planning-context-handover-story.md` → updated in this change.
- **Reviews already run:** Gate-A spec cycle bkt90xphyk (closed in a1bc65d) → no rule found (same paragraphs checked as in the change record at the end of §7). Daniel's decision of about 12:17 for the previous amendment gave its reason — "Die Ergänzungen ändern verbindliche Pflichten … Der bisherige Spec-Abschluss deckt diese Fassung nicht ab." — and this amendment again changes binding obligations, so it runs a new Gate-A spec cycle on that reasoning, as his instruction to derive the necessary follow-up checks from the actual review status asks.

## 3. Gate A (AC-3)

The Gate-A bullet's review question gains, per artifact: for a spec, whether its
commitments are coherent, sufficiently decided and feasible; for a plan, whether
implementation can proceed (decisions and dependencies, realistic steps, meaningful
verification, the boundary between local choices and questions needing a decision). It
states that a missing function body or complete test is not by itself a finding, that a
finding names a concrete consequence (the finding line's existing consequence field), and
that code a plan includes stays reviewable. The broad prompt, "every finding with severity
and confidence", and "coverage floor, not a cage" stay. The before/after diff of both gate
-rule copies must touch only this bullet's review question.

## 4. Copies and packaging (AC-9)

Changed in agreement: the two `CLAUDE.md` surfaces (§2), the two gate-rule surfaces (§3),
and `docs/coding-workflow.md` where it describes what a spec or plan contains. Every other
place that describes plan contents is found by grep and either updated or left with a
reason. Plugin `version` → 0.18.0 with a CHANGELOG entry; `docs/prompt-standards.md` all 12
items for the changed prompt text; the quality battery green.

## 5. Adoption (AC-10, AC-14, AC-17)

Re-running `/workflow-init` stays available — for a file that differs it shows a short
diff and offers overwrite / merge / skip — but a merge there is judged per file by whoever
runs it, with no statement of which parts this release changes. The adoption path is
therefore a focused insertion guide in the 0.18.0 CHANGELOG entry:
insert the §4 subsection, replace (not duplicate) any local rule covering the same ground,
update the Gate-A bullet wherever the project keeps its gate rules (`.claude/review-gates.md`
or an inline §5), at a completed work boundary; running cycles keep their rules.

Verification: the guide is applied once to scratch copies of SFX's current `CLAUDE.md` and
`.claude/review-gates.md`; the result carries the new rule once, keeps SFX's own conditions,
and contains no competing plan-form rule.

Prepared, not applied: one adoption file per project (SFX, canvas, `sfx-bricks-api-builder`)
in that project's `.context/`, built from its current local rules (canvas and
`sfx-bricks-api-builder` keep their gate rules inline in `CLAUDE.md` §5).
`sfx-bricks-api-builder` applies it at a boundary its responsible session confirms; its
oversized `docs/HANDOVER.md` is not rewritten by the adoption — moving it to a current
summary is that session's first handover under the new rule. SFX applies it at
the first suitable completed-work boundary after both P5b's closing act and the release; P5b
itself continues under its pilot instruction (`.context/plan-form-pilot.md`). Canvas applies
it at a boundary its responsible session confirms (`.context/HANDOVER.md`). In-flight
artifacts in either project are not edited. Each project's adoption record names the first
unfinished unit that runs under the released rules once the boundary is confirmed; until
then it says "pending", and the session applying the adoption fills it in. Completed units
are not redone.

## 6. Evidence (AC-12)

A public replay package under `docs/superpowers/replays/2026-10-06-compact-planning/`.

- **Task:** the PR #47 backlog item (the intake amendment route's *Dependent artifacts*
  field), with a fixed brief and the input files it needs.
- **Fixed before any run:** the rubric (from AC-1: per step outcome, components and reuse,
  prerequisites and settled decisions, test situations with expected outcomes including
  failures, decision space; plus whether implementation appears in full). Because this task
  changes a prompt, implementation in full includes complete replacement prompt or template
  text, not only function bodies and complete tests. Also fixed in advance, for the review
  check: which material decision is removed and which implementation gap that leaves.
- **Two runs, isolated:** the same task, inputs, model and `writing-plans` 6.4.1, loaded in
  both; no user-level instructions, memory or other project files; the only difference is
  the project `CLAUDE.md` (before vs after this change). One run each, one sample each; "no
  observed difference" is a valid result and runs are not repeated to obtain another.
- **Review check, not a gate cycle:** a Codex call with the new Gate-A plan question on (a)
  the new-run plan — no finding whose only complaint is missing implementation; other real
  findings are allowed — and (b) the same plan with the named decision removed, everything
  else unchanged (checked by diff) — a finding identifies that gap. The check is interpreted
  only if the new-run plan meets the rubric, leaves implementation out and contains the
  decision chosen for removal; otherwise it is not run on that sample.
- Results and limitations are reported as observations. Where the single sample cannot
  support a part of AC-12, the report says that part is unmet rather than counting it as
  shown.

## 7. Backlog (AC-13, AC-14)

`todos.md` G3: G3a, G3b and the task-context part of G3c are delivered together by this
story (Daniel's assignment of 2026-10-06 changes the "one story per leaf, in this order"
arrangement); the rest of G3c (rule consolidation) and G3d keep their leaves. Every earlier
condition of the G3 entry is accounted for as kept, moved or dropped, quoting the decision.
P5b's state and the SFX adoption boundary are recorded at G3a. The follow-up repairs keep
their existing owners and this order: reviewer-output collisions (the "`reviewType: full`
races" row), durable learning from findings (Finding A), repeated findings about the checking
method (the arms-race remedy row), the rest of G3c/G3d, the PR #47 intake correction. No new
entries for them. Two `sfx-bricks-api-builder` observations are added as evidence to existing
rows, not as entries: review passes continuing after a clean branch pass goes to the
"Review-loop usefulness" row, with the counter-example that one cycle's clean pass 7 was
followed by a pass 8 that found a real Major; and an empty ledger despite merged PRs with
fixed bot findings goes to Finding A, as evidence that the ledger stays empty there too;
whether `process-pr-review` step 5 ran, and whether any finding qualified for hardening, is
unknown. The measurements are cited as recorded; no new mandatory artifact follows.

**Changed 2026-10-06 — changed requirement.** Decided by Daniel in the Claude Code session of
2026-10-06 (about 11:55): "Präzisiere die Übergabe als aktuelle Zusammenfassung mit
vollständig übernommenen offenen Verpflichtungen und Verweisen auf historische Belege.
Ergänze bei der Kontextauswahl relevante Konfigurationen, Datenumfänge und Zielumgebungen.
Nimm das Projekt als dritten Kandidaten für eine vorbereitete Übernahme an einer sicheren
Arbeitsgrenze auf. Ordne die Befunde zu unnötiger Review-Fortsetzung und leerem Ledger trotz
PRs ihren bestehenden Backlog-Aufgaben zu." Baseline: 545bb0a. The story's matching change
(AC-6, AC-7, AC-11 replaced by AC-15, AC-16, AC-17) is its dependent artifact.

| Earlier condition | Fate | AC operation |
|---|---|---|
| §1, §3, §4, §6, §8, §9 | kept | none |
| §2 items 1–3 and 5 | kept | none |
| §2 item 4, the context rule as AC-6 stated it | kept; moved → item 4 citing AC-15, which adds configuration, realistic data volumes and target environments, per the decision: "Ergänze bei der Kontextauswahl relevante Konfigurationen, Datenumfänge und Zielumgebungen." | none |
| §2 item 6, session change and handover | kept; the handover is now a current summary carrying every open obligation and linking earlier states, per the decision: "Präzisiere die Übergabe als aktuelle Zusammenfassung mit vollständig übernommenen offenen Verpflichtungen und Verweisen auf historische Belege." | none |
| §5, adoption for SFX and canvas | kept; `sfx-bricks-api-builder` added as a third project, per the decision: "Nimm das Projekt als dritten Kandidaten für eine vorbereitete Übernahme an einer sicheren Arbeitsgrenze auf." | none |
| §7, backlog regrouping and follow-up order | kept; two observations added as evidence to existing rows, per the decision: "Ordne die Befunde … ihren bestehenden Backlog-Aufgaben zu." | none |

- **Unaccounted:** none.
- **Intervening changes:** none — the file is unchanged between 545bb0a and this change.
- **Scope boundary:** in: §2 items 4 and 6, §5's project list, §7's evidence sentence. out: every other design decision; the order and scope of the follow-up repairs.
- **Open questions:** none added here; the new project's boundary is recorded in the story's §5.
- **Dependent artifacts:** `docs/superpowers/stories/2026-10-06-compact-planning-context-handover-story.md` → updated in this change; `todos.md` → updated in this change.
- **Reviews already run:** Gate-A spec cycle 1zetzfju6f (closed in 545bb0a) → "no rule found" (input: this spec amended after that cycle closed; paragraphs checked in `.claude/review-gates.md`: the opening floor paragraph, "Gate A's content condition, and its closing act", the "Gate A — Spec, then plan" bullet, and "What counts as prose (the only Gate-B exemption)") → Daniel decided (same session, about 12:17): "A. Starte einen neuen Gate-A-Spec-Zyklus nach den geltenden Profil- und Abschlussregeln." The new cycle reviews the new obligations and their consistency with the rest of the design; the existing decisions stay its basis.

## 8. Out of scope

A full reorganisation of the rule files; a new context, handover or orchestration tool; the
living-feature-docs model; the follow-up repairs in §7; any change to `/workflow-init`'s
merge behaviour.

## 9. Known limits

Loading a rule does not guarantee an agent follows it; §6 tests one sample, not compliance in
general. Compact plans move decisions into implementation only where the plan leaves them as
local choices; the Gate-A plan question on that boundary and an unchanged Gate B are the
guards. No saving is claimed beyond what a comparison supports.
