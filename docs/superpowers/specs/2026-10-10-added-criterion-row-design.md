# Change-record field for a criterion added without an earlier condition — Design

**Story:** `docs/superpowers/stories/2026-10-10-change-record-row-for-an-added-story.md` — read its profile fresh at each pass.

**Date:** 2026-10-10 · **Decided with:** Daniel. Approach A (a separate template field, not a
table row with a new fate) on 2026-10-10, with his conditions: the field is limited explicitly to
criteria added with no earlier condition and named for that; every such criterion is recorded with
its ID, its requirement and the passage of the covering decision; `none` applies to that category
only; replacements stay in the table with their full mapping and decision. Measurement scope from
the intake round: 5 runs of case D, 3 runs of case B.

## 1. Problem, as it stands on 2026-10-10

The change record of the amendment route (`plugins/dev-workflow/skills/intake/SKILL.md`,
`### The change record`) has one table, `| Earlier condition | Fate | AC operation |`, six
required field lines and an optional evidence line. Step 5 gives every *earlier* condition a row. A criterion the decision adds with no
earlier condition behind it has no place: it is no earlier condition, and none of the fields names
it. Agents fill the gap with an invented row whose earlier-condition cell is `—` and whose fate is
outside the closed set, for example (strand-C pilot, `evidence/artifacts.md` line 345 on branch
`intake-skill-pilot`, b348b9c):

```
| — (new condition: CSV offered as an export format) | added per the decision: "add CSV to the export story" | added AC-5 |
```

Pilot case D: 1 of 3 runs on the shipped skill, 4 of 4 runs on the split candidate. The shipped
intake skill is unchanged between the pilot's baseline (`860e56c`) and `e98fa4c`
(`git diff --stat 860e56c e98fa4c -- plugins/dev-workflow/skills/intake/SKILL.md` is empty), so the
pilot's baseline runs are the before-measurement of this change.

## 2. Design

### 2.1 The new field

One line is added to the template, directly after the table and before *Unaccounted*:

```markdown
- **Added without an earlier condition:** <AC-n: "requirement text", or in a spec: "the added condition, quoted"> → per the decision: "<quoted passage>"; or none.
```

Rules, stated in the skill next to the closed sets:

- **Scope.** The field lists every criterion or condition the change adds that has **no** earlier
  condition behind it — nothing it replaces, narrows or takes over. In a story each entry carries
  the new identifier and the requirement text as written into §3; in a spec, which has no
  criterion identifiers of its own, it carries the added condition quoted as written into the
  changed section. Every entry carries the passage of the step-1 decision that covers it. Several
  entries are separated by `;`.
- **`none`** means the change adds no criterion of this category. It says nothing about
  replacements or other added criteria.
- **Replacements stay in the table.** A criterion that replaces an earlier one, or receives a
  moved condition, keeps its full mapping in that earlier condition's row (`moved → AC-<n>`,
  `withdrawn; added AC-<n>`) with the decision passage, exactly as today, and is not listed in the
  new field.
- **No placeholder rows.** A table row exists only for an earlier condition of the baseline; a row
  whose earlier-condition cell is empty, `—` or a new condition is not a valid record.
- **Same evidence rule as fates.** An added criterion with no passage of the decision to quote is
  not added: it goes to *Unaccounted* (step 5's rule, applied to additions).

The closed sets are unchanged. Values in the new field are free text (requirement, quotation) and an
identifier governed by *Acceptance-criterion IDs*; the field itself governs no closed set.

### 2.2 Route steps

- **Step 5** gains one sentence: after every earlier condition has its row, list each criterion the
  decision adds with no earlier condition in *Added without an earlier condition*, with its quoted
  covering passage; never as a table row.
- **Step 6** gains one sentence: in a story, each criterion in that field stands in §3 under
  rule 2 (the next unused identifier), with the same identifier and text as in the record; in a
  spec, the added condition stands in the changed section with the text the record quotes, and a
  story changes only under step 6's existing rule (when the decision changes that story, which is
  then a dependent artifact).

### 2.3 Accounting of earlier obligations (story AC-2)

Every obligation the route and its template carried at `e98fa4c`, and its fate in this change:

| Obligation at `e98fa4c` | Fate |
|---|---|
| Steps 1–9 as written (decision, baseline, current state, enumeration, fates, ID rules, remaining fields, write and commit, stop) | kept; steps 5 and 6 each gain one sentence (§2.2) |
| Template heading line (date, reason class, decider, baseline, rationale) | kept |
| Table header and one row per earlier condition | kept; now stated as rows for earlier conditions only |
| Fields *Unaccounted*, *Intervening changes*, *Scope boundary*, *Open questions*, *Dependent artifacts*, *Reviews already run*, *Evidence (optional)* | kept, unchanged |
| Closed sets: reason class, fate, AC operation, dependent-artifact status | kept, unchanged, still closed |
| `moved`/`dropped` fates quote the covering passage | kept |
| Narrowed-or-replaced test, replacement as `withdrawn` + `added AC-<n>` | kept; the new field explicitly excludes replacements |
| Example rows (one narrowing, one replacement) | kept |
| Placement of the record (story: end of §3; spec: end of the changed section) | kept |
| Check 4f pins template lines and closed sets | kept; extended to the new line (§2.4) |

Nothing is moved or dropped.

### 2.4 Check 4f

`CR_REQ` in `scripts/check-invariants.sh` gains the new line as its third entry; the scan then
pins 13 lines, the first nine inside the template fence, the four closed sets outside it. The
`CR_LINES` fixture in `scripts/check-invariants.test.sh` follows line for line; the
missing/altered loop runs over 13 lines, and the placement cases follow the new indices. The
comments and the failure message that say "12" are updated. What 4f does not catch stays as stated
in its header: it pins spelling, not whether any record follows it.

### 2.5 Version

dev-workflow 0.22.0 → 0.23.0 (a behaviour change of a shipped prompt), with a CHANGELOG entry.

## 3. Measurement (story AC-5 to AC-8)

**Package:** `docs/superpowers/replays/2026-10-10-added-criterion-row/`, in the strand-C replay
structure. Taken from `intake-skill-pilot` (b348b9c), named with their source paths: the fixture
(`fixture/`), prompts `D1` and `B1` (`prompts.md`), and `run.sh` (`runner.md`), with one variant
whose `--plugin-dir` is a copy of this branch's `plugins/dev-workflow` at the measured commit.
Flags unchanged: `claude -p` in a fresh fixture copy, `--plugin-dir`, `--setting-sources project`,
`--strict-mcp-config`, model `claude-opus-5-5`. The README records fixture, prompts, model, runner
and the measured skill revision (commit and the skill file's sha256).

**Runs:** 5 × D1 and 3 × B1, all on one unchanged skill revision.

**Per-run checks** (mechanical where a pattern decides it, otherwise a reading check, labelled as
such in the comparison):

| Check | D | B |
|---|---|---|
| Amendment route taken: the existing story changed, no new story file | ✓ | ✓ |
| Every baseline condition (AC-1…AC-4, the §2 outcome, the §2 exclusion) has a row | ✓ | ✓ |
| Every table row names a baseline condition; no `—`/empty/new-condition row | ✓ | ✓ |
| Baseline commit named; docs-only commit naming decider and date; nothing resumed | ✓ | ✓ |
| All four closed sets hold: exactly one valid reason class in the header; every fate and AC-operation cell uses only permitted values; exactly one valid status per dependent-artifact entry (or `none`) | ✓ | ✓ |
| Every `moved` or `dropped` fate quotes a passage of the prompt's decision that covers it (reading check) | ✓ | ✓ |
| The §2 outcome ("receives a complete file without contacting support") and the §2 exclusion (scheduled exports out of scope) still stand in the story with their obligations intact (compared with the fixture) | ✓ | ✓ |
| The change record sits at the end of the story's §3 | ✓ | ✓ |
| The record's header line and all seven field lines present (incl. the new one, `none` only where the CSV criterion took the replacement shape) | ✓ | ✓ |
| The CSV requirement is recorded, in exactly one of the two valid shapes: as a criterion with no earlier condition, in *Added without an earlier condition* with ID, requirement text and a quoted passage of the prompt's decision; or as a replacement of AC-1 (which names XLSX), in AC-1's row with `withdrawn; added AC-<n>` and the quoted passage. Never absent, never a placeholder row (reading check: the passage covers it) | ✓ | ✓ |
| §3 holds the CSV criterion with the next unused ID (AC-5) and the same text as the record | ✓ | ✓ |
| AC-1 … AC-4 still present with their IDs; each changed only as the decision covers | ✓ | ✓ |
| The remaining pilot check for case B (`compare.md` row B): AC-2 narrowed with a dated note | — | ✓ |

**Acceptance:** all 8 runs pass every check. Every run is reported with its result per check,
failures included. A failed run is investigated; only a correction with a stated reason starts a
fresh, complete set of 8 runs on the corrected revision, and the earlier set stays in the report.
Without such a correction the change is not adopted, the shipped template stays, and the decision
goes to Daniel. Runs are never repeated until enough pass.

**Limit:** 8 samples on two prompts and one fixture. They show the changed template can be followed
for these cases; they do not show a general absence of loss.

## 4. Lenses (story profile: risk `standard`, security `none`)

Floor and level per `.claude/review-gates.md` for `standard`/`none`; no security lens set. Prompt
changes pass `docs/prompt-standards.md` (invariant 11) for the changed skill text.

## 5. Acceptance mapping and evidence (`battery+check`)

| Criterion | Met by |
|---|---|
| AC-1 | §2.1 (defined field, closed sets unchanged) |
| AC-2 | §2.3 |
| AC-3 | §2.1 scope and evidence rules, §2.2 step 6 |
| AC-4 | §2.4 |
| AC-5, AC-6, AC-7, AC-8 | §3 |
| AC-9 | §6 |

**Check that fails without the change:** check 4f with the 13-line `CR_REQ` fails on the
`e98fa4c` skill text (line 3 occurs 0 times); a test case in `scripts/check-invariants.test.sh`
shows it. **What it proves:** the line is present and placed. It proves nothing about agent
behaviour; §3 covers that as a named verification, with the pilot's baseline runs as the
counterfactual (1 of 3 D runs with an out-of-set row on the same text).

## 6. Out of scope

- Splitting the intake skill into route files (strand C, step 2): judged separately.
- Merging `intake-skill-pilot`; it is only a source of fixtures.
- Any new fate, AC operation or other closed-set value.
- The sparring skill: it holds no copy of the template (`grep -rnF "Earlier condition"` finds the
  intake skill, check 4f, its fixture and two historical replay records only).
- Rewriting earlier change records written under 0.22.0.
