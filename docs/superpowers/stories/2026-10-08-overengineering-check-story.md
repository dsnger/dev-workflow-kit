# Over-engineering check — Story

**Date:** 2026-10-08 · **Size:** story
**Risk:** standard · **Security:** standard · **Validation:** battery+check

## 1. Problem statement
Daniel (2026-10-07 18:49, verbatim in `.context/intake-inputs/2026-10-07-overengineering-assignment.md`,
local to the main checkout) asks how the kit already prevents over-engineering when specs and plans are
written and reviewed and when code is implemented, and which gaps remain with evidence. Today nobody has
put the existing safeguards side by side, so nobody can say which gaps are real. The goal is less
unneeded scope, complexity and review effort, with functional and security requirements unchanged.

Field evidence from #50's Gate B (cycle 27xgcofe9f; findings 14,8,5,4,2,2,3,2,3,1,0; local records
under `.context/codex-reviews/gate-b-*27xgcofe9f*`). From pass 4 to pass 10 every Major hit the same
surface: how the canary procedure in `/workflow-init` isolates its environment. Each accepted repair
was followed by a further finding on the same surface:
- pass 4: `core.hooksPath=/dev/null` does not stop `core.fsmonitor`;
- pass 5: inherited `GIT_CONFIG_COUNT`/`GIT_CONFIG_KEY_0` still run that helper;
- pass 6: `GIT_DIR`, `GIT_WORK_TREE` and `GIT_INDEX_FILE` stay active;
- pass 7: Claude settings `env` reapplies `GIT_*` after the cleanup; linked-worktree settings;
- pass 8: the linked-worktree exclusion comes only after 2.14 has already acted;
- pass 9: direct 2.15 revalidation skips the early checks; the worktree check trusts an inherited `GIT_DIR`;
- pass 10: the checkout root is chosen under the inherited Git environment.

The dispositions of passes 7, 9 and 10 classify this cluster as an issue in the instrument (the
setup/canary procedure), not in the product rule or the deny rules. The canary is part of the shipped
security check, and every disposition line of passes 3–10 accepts its finding; none dismisses one. The
class was generalised early: pass 5 made any `GIT_*` in the server entry's environment unsupported, and
pass 6 unset every inherited `GIT_*`. Passes 7–10 concerned further sources of the environment and the
order and placement of the checks; pass 8's disposition reads "a defect of the pass-7 repair
(placement), not a new environment class". Pass 11 found nothing. Whether this series is the shape the
existing row "The arms-race remedy exists as an observation and not as a procedure" (`todos.md`)
describes is not established, and its avoidable share is not isolated.

## 2. Desired outcome
A short, evidence-backed answer to the assignment, plus one coherent first delivery. It closes the most
important evidenced gaps that fit one spec and gives every other evidenced gap to a named owner, so the
assignment is not shortened silently. Any new rule text, tool or process step comes only with shown
benefit. Checks run without a model call and work with any coding agent wherever that makes sense.
Every related item is handled by its existing owner.

## 3. Acceptance criteria
_IDs are permanent once the story is committed: never renumber or reuse one; a new criterion takes the next number unused here and on the branch it merges into, and a collision stops for a human; a removed one stays, struck through and dated; a narrowed one keeps its ID with a dated note; cite as `<story path> AC-<n>`; full rules: dev-workflow:intake, "Acceptance-criterion IDs"._
- [ ] **AC-1** For each of spec writing, spec review (Gate A), plan writing, plan review (Gate A) and
  implementation plus its review (Gate B), the delivery names the existing rules, gates and checks that
  already counter over-engineering, each with a repository citation.
- [ ] **AC-2** Every gap the delivery claims cites at least one concrete observed instance (a finding, a
  pass record, a diff or a field report). A suspected gap with no observed instance is listed as
  unevidenced and is not closed in this delivery.
- [ ] **AC-3** The delivery closes the most important evidenced gaps that fit one spec and states why
  these come first. Every other evidenced gap gets a fate in the delivery report: routed to the existing
  `todos.md` owner that covers it, with its evidence added there, or a new row only where no owner
  covers it. No evidenced gap is left without a fate.
- [ ] **AC-4** Each addition (rule text, tool or process step) names the observed instance it would have
  prevented or caught, and a check that fails without it. An addition without both is not made.
- [ ] **AC-5** Where a closed gap can be checked without a model call and independently of the coding
  agent, it is checked that way inside the existing quality battery. Where it is not, the delivery says
  why.
- [ ] **AC-6** Functional and security requirements stay unchanged. Every changed or removed rule
  condition is accounted for as kept, moved or dropped, each with the decision that covers it. No
  security control is weakened. Removal is limited to text that concerns over-engineering; general rule
  consolidation stays with G3c.
- [ ] **AC-7** The #50 evidence in §1 is recorded in the existing arms-race row, which stays its owner.
  G3a, G3c and "Review-loop usefulness" each get no second backlog entry. The delivery names the owner
  for each related item.
- [ ] **AC-8** Each earlier recommendation the delivery relies on is checked against repository evidence
  and marked confirmed or rejected, with its reason.
- [ ] **AC-9** The delivery report states, briefly: what was already covered, which gaps were closed,
  how their effect can be shown (the measure, and where it will be read), the size of the always-loaded
  instruction text before and after, and the limits that remain. It claims no saving from this delivery
  alone.

**Changed 2026-10-08 — gap found.** Decided by Daniel in the Claude Code session of 2026-10-08, 12:59
("Option 3, weiter wie beschrieben"), adopting the 12:57 proposal, which stated: "Die Story braucht nur
die Tatsachenkorrektur in §1." Baseline: 0a61291. The dispositions of #50's Gate B (cycle 27xgcofe9f,
passes 5, 6 and 8) contradict §1's reading that pass 10 first rejected the whole class; §1 now states
what they record.

| Earlier condition | Fate | AC operation |
|---|---|---|
| §1 assignment and goal paragraph | kept | none |
| §1 "Each accepted repair was followed by a finding on the next variant" | kept: a further finding followed each accepted repair; dropped — "on the next variant", per the decision: "Die Story braucht nur die Tatsachenkorrektur in §1." | none |
| §1 pass list (passes 4–10) | kept | none |
| §1 instrument classification by the dispositions of passes 7, 9 and 10 | kept | none |
| §1 inference that pass 10 first rejected the whole class instead of one more variant, and that this is the arms-race row's shape | dropped — per the decision: "Die Story braucht nur die Tatsachenkorrektur in §1."; replaced by the recorded generalisation in passes 5 and 6 and the open question whether the series is that shape | none |
| §1 "Pass 11 found nothing"; avoidable or causal share not isolated | kept | none |
| §2 desired outcome | kept | none |
| AC-1 … AC-9 | kept | none |
| §4 invariants, §5 open questions, §6 size | kept | none |

- **Unaccounted:** none.
- **Intervening changes:** none (the story equals 0a61291 before this change).
- **Scope boundary:** in: the factual reading of the #50 Gate-B series in §1; out: every criterion, the outcome, the size, and the first delivery's content (Daniel's choice of option 3 is a design choice made in brainstorming, not a change to this story).
- **Open questions:** none.
- **Dependent artifacts:** `todos.md` row "Over-engineering check" (its "each repair spawning an adjacent case") → blocks this delivery's Gate-B cycle until updated.
- **Reviews already run:** none on this story; Gate A runs on specs and plans (`.claude/review-gates.md:925-928`), and no spec or plan cites this story yet.

## 4. Affected AGENTS.md invariants
- `## Key invariants` › `### Prompts and scaffolding` — "11. **Prompt changes pass `docs/prompt-standards.md`** — all 12 checklist items, for any skill, command, agent definition, hook message, or scaffolded template." … "**no comprehensive mechanical checker exists for them**: review is the gate."
- `## Key invariants` › `### Prompts and scaffolding` — "8. **`/workflow-init`'s templates stay inline** in the command body."
- `## Key invariants` › `### Packaging` — "12. **A plugin change requires a version bump.**"
- `## Don'ts` — "**Never replace a decision procedure without accounting for its old conditions.**"
- `## Don'ts` — "**Never describe what a gate proves without checking what it actually compares.**"

## 5. Open questions
- Which earlier recommendations does the assignment mean? The assignment itself contains none, and the
  reviewer's A/A/A choices date from 2026-10-08, after it. Until Daniel names a source, AC-8 covers only
  recommendations the delivery actually relies on, each with a concrete recorded source; no search for
  further ones.
- Settled 2026-10-08 (Daniel): no replay is required as acceptance beyond AC-4's per-addition
  counter-check and AC-9's named later measure.

## 6. Suggested size
story — one coherent first delivery within one spec; gaps outside it are routed to existing owners (AC-3), not split into an epic.
