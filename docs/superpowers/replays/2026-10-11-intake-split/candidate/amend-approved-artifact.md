# intake — amend an approved story or spec

Target model: Claude via Claude Code. This file is a prompt artifact and follows the
checklist in `docs/prompt-standards.md`. The `intake` skill (`SKILL.md` in this directory)
sends you here once it has chosen this route; the acceptance-criterion ID rules this route
applies are in `SKILL.md`, under *Acceptance-criterion IDs*.

Contents: when this route applies · Steps 1–9 · The change record (template, closed sets,
the added-criterion rules and example, the narrowed-or-replaced test, example rows).

## Amending an approved story or spec

A second route, separate from the Flow. Use it when an approved story or spec must change
after a human decided to change it. It writes one **change record** into the changed
artifact, so that no earlier condition disappears unnoticed: a dropped condition looks
exactly like text that was never there (AGENTS.md, "Never replace a decision procedure
without accounting for its old conditions").

It runs none of the Flow's steps — no question round, profile proposal, new file or
brainstorming hand-off — because the decision already exists and a second approval would
be a step nobody asked for. It makes no new solution-design decision: for a story the
WHAT/WHY boundary holds as in the Flow; for a spec the record may state a technical
condition that was already decided, because recording it is not designing it.

**Who runs it:** the session allowed to change files. An advisory `dev-workflow:sparring`
session drafts the record in the conversation and hands it over in its coding-agent
prompt; the coding session writes it here.

### Steps

1. **Establish the decision.** Name the explicit human decision that covers the change:
   who, when, where (a message, a review thread, a commit). If no decision covers the
   whole change, ask the uncovered question and wait, then continue on the answer. This
   is the route's only question, because the human already decided the rest.
2. **Fix the baseline**: the approved text the change is measured against — the commit at
   which it was last approved, or, for approved text never committed, the content hash
   recorded with the approval (for example the hash a Gate-A request pinned). If it cannot
   be established, stop and name what is missing: substituting `HEAD` or the working copy
   would measure the change against text nobody approved.
3. **Capture and reconcile the current state of every file the route will write** — the
   changed artifact and each dependent artifact (working tree and index); a path the
   route will create must not exist yet. List each edit made since the baseline in the
   record's *Intervening changes*, accounted for like any other condition; put any the
   decision does not cover to the human under step 1. Preserve unrelated edits. Concurrent
   identifier claims stay under *Acceptance-criterion IDs* rule 3 (in `SKILL.md`).
4. **Enumerate the baseline's conditions** before assigning any fate: every criterion,
   every outcome or scope sentence that constrains the result, every stated exclusion. The
   list is what reveals an omitted condition; a template cannot. For a spec, also read the
   stories its `Story:` header names and map each changed condition to the criteria it
   serves.
5. **Assign a fate and an AC operation** to every enumerated condition (one row per
   condition, or per run of criteria sharing a fate). Then check that every condition has
   a row. A condition nobody decided goes to *Unaccounted*, never into the table under a
   fate it does not have. **The changed text is not a decision**: that a later draft drops or
   rewrites a condition shows what changed, not that a human chose it. A fate needs the
   decision of step 1 (or an answer to its question) to cover that condition; reading a
   covering decision into nearby wording is the same as having none.
   **So every `moved` or `dropped` fate quotes the passage of the decision that covers it**,
   in the row; a fate with no passage to quote is not a fate but an *Unaccounted* entry. A
   passage that limits *how* something may be decided (what evidence counts, what may not be
   inferred) does not decide *whether* it changes.
   **Then list what the decision adds with no earlier condition behind it** in *Added without
   an earlier condition*, each entry with its quoted covering passage — never as a table row,
   because the table holds earlier conditions only and a row with no earlier condition has no
   fate to give.
6. **Apply *Acceptance-criterion IDs* rules 1–5 (in `SKILL.md`) exactly as written.** Cite each affected
   criterion in rule 4's form (with or without identifiers). Any amendment of an older
   story adopts identifiers under rule 5, even when no criterion's wording changes.
   Criterion operations apply only to criteria the decision changes. A criterion whose
   change is wholly or partly *Unaccounted* gets operation `none` and keeps its approved
   text until a decision covers it; the record names it under *Unaccounted*. A spec amendment
   edits a story only when the decision changes that story, which then is a dependent
   artifact. **Each entry in *Added without an earlier condition* stands in the changed
   artifact as the record names it**: in a story, in §3 under rule 2 (in `SKILL.md`; the next unused
   identifier), with the same identifier and text as in the record; in a spec, in the changed
   section, with the text the record quotes — and a story changes only under the sentence
   before this one.
7. **Fill the remaining fields.** For *Reviews already run*, cite, for each review input the
   change touches and each cycle it affects, the paragraph of the project's gate rules
   (`.claude/review-gates.md` where `/workflow-init` scaffolded them) that decides the
   consequence. Quote or cite; never summarise what a rule decides, because a summary
   drifts from its source. Write "no rule found" only after checking, naming the input
   and the paragraphs checked, and then the human's decision or that it is pending.
8. **Write and commit, deferring to the gate rules.** Immediately before writing, every
   file must still equal what step 3 captured; before staging, each must equal what you
   wrote. Any other difference returns to step 3. Then decide from the gate rules, not
   from this route, whether the complete changed set owes a gate (see the gate rules'
   paragraph on what counts as prose) or an open cycle governs the commit; if so, hand the
   commit to that gate and stop here. Otherwise commit on your own: stop if the index
   already holds staged work you did not stage; stage exactly the changed artifact and the
   dependent artifacts marked `updated in this change`; check that the staged paths are
   exactly those and each staged file equals what you wrote; commit with a message naming
   the change, the decider and the date.
9. **Stop.** Name what the change unblocks and what stays blocked (*Unaccounted*,
   dependent artifacts, reviews). Resume nothing on your own: the next gate, plan or
   implementation step is the human's or its own workflow's to start.

### The change record

Place it in the changed artifact: in a story at the end of §3, in a spec at the end of the
section it changes. Shape:

```markdown
**Changed YYYY-MM-DD — <reason class>.** Decided by <who>, <where>. Baseline: <commit or approved-content hash>. <Rationale.>

| Earlier condition | Fate | AC operation |
|---|---|---|
| <AC-n, or the quoted condition> | <fate, or several> | <operation> |

- **Added without an earlier condition:** <AC-n: "requirement text", or in a spec: "the added condition, quoted"> → per the decision: "<quoted passage>"; or none.
- **Unaccounted:** <condition> → blocks <named continuation> until settled; or none.
- **Intervening changes:** <change since the baseline> → <how accounted>; or none.
- **Scope boundary:** in: <…>; out: <…>.
- **Open questions:** <question> → <where recorded>; or none.
- **Dependent artifacts:** <path> → <status>; or none.
- **Reviews already run:** <input or cycle> → <consequence>, per <rule cited>; or "no rule found" (<input>, <paragraphs checked>) → <human decision, or pending: blocks <continuation>>.
- **Evidence (optional):** <link, for example a spec-delta report>.
```

The closed sets:

- **Reason class**, exactly one: `changed requirement` · `gap found` · `change of direction`.
- **Fate**, one or more per condition: `kept` · `moved → <destination>` · `dropped — <reason>`.
- **AC operation**, per intake's ID rules: `none` · `reworded` · `narrowed` · `withdrawn` · `added AC-<n>`.
- **Dependent-artifact status**, exactly one: `updated in this change` · `open — permitted by <rule>` · `blocks <named continuation> until updated`.

**Added without an earlier condition — the rules.** This field is not a closed set: its
entries are free text and identifiers, and it widens none of the sets above.

- It lists every criterion or condition the change adds that has **no** earlier condition
  behind it — nothing it replaces, narrows or takes over. In a story each entry carries the new
  identifier and the requirement text as written into §3; in a spec, which has no criterion
  identifiers of its own, the added condition quoted as written into the changed section. Every
  entry carries the passage of the step-1 decision that covers it. The requirement text holds
  only what that passage covers: a detail taken from another criterion or nearby wording — a
  place, a format, a limit — is not covered by it, so it stays out, or goes to *Unaccounted*
  when the human should decide it. Separate several entries with `;`.
- `none` means the change adds nothing of this kind. It says nothing about replacements.
- A **replacement** — a criterion that replaces an earlier one or receives a moved condition —
  keeps its full mapping and decision passage in that earlier condition's row
  (`moved → AC-<n>`, `withdrawn; added AC-<n>`) and is not listed here, so what it replaced
  and why stay in one row.
- A table row exists only for an earlier condition of the baseline. A row whose
  earlier-condition cell is empty, `—` or a new condition is not a valid record.
- An addition with no passage of the decision to quote is not added: it goes to
  *Unaccounted*, by the same rule step 5 applies to fates.

Example entry, a story amended with a criterion nothing earlier covered:
`- **Added without an earlier condition:** AC-7: "An admin can stop a running export." → per the decision: "admins need a way to stop a runaway export"`

A narrowing usually carries several fates in one row — the part kept and the part moved
or dropped — because naming only the surviving part hides what left the scope.

**Narrowed or replaced — the test.** A criterion is `narrowed` (or `reworded`) only when
everything the new text requires was already required by the old one: it keeps part and
adds nothing. As soon as the new text requires something the old did not — a new state, a
new obligation, a new reason to report — it is a **replacement**: `withdrawn` plus
`added AC-<n>`, so an old citation never silently gains a requirement it did not have.
`open` needs a cited rule that permits
leaving the artifact; where a rule demands the update in the same commit, `open` is not
available.

Example rows, one narrowing and one replacement:

```markdown
| AC-3: export runs nightly and on demand | kept: on demand; dropped — nightly, per the decision: "the scheduler is out of this release" | narrowed |
| AC-4: progress shown as a percentage | dropped — per the decision: "no reliable total exists; show steps instead"; moved → AC-6 (a step counter) | withdrawn; added AC-6 |
```
