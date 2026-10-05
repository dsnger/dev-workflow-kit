# Controlled change to an approved story or spec (G1a) — design

**Story:** `docs/superpowers/stories/2026-10-05-controlled-change-to-an-approved-story-story.md` — read the profile from its header at every gate call.

## §0 Scope

**What it is.** A bounded amendment procedure in the shipped `dev-workflow` plugin. `intake`
owns it, as a separate amendment route beside its new-story flow, and `sparring` points at it.
It produces one artifact, a **change record**, written into the changed story or spec. The
human still makes every decision; the record makes the decision complete and visible.

**Why intake owns it, not sparring** (`AC-8`). Writing the record changes a file, and sparring's
authority forbids that ("Do not implement, change files or git state, commit …",
`plugins/dev-workflow/skills/sparring/SKILL.md`, *Authority*). intake already owns the
acceptance-criterion ID rules the record must follow (`AC-2`). So the coding session writes the
record under intake's rules, and sparring drafts it in the conversation and hands it over.

**Out of scope** (`AC-10`): a separate skill; new approval levels; dashboard or live-view work; any
part of the 2c part-4b calibration; any new gate rule (`AC-6`). This repository's own docs are not
changed beyond the surfaces in §5.

## §1 The amendment route in `intake`

**Entry.** The frontmatter `description` and *When to use* stop excluding approved artifacts
without exception. They name a second use: amending an approved story or spec after a decision to
change it. The new-story exclusion stays for everything else: intake still does not design a
solution and does not start a new story for an approved one.

**Separate from the new-story flow.** A new section, *Amending an approved story or spec*, is its
own route. It does not run the new-story flow's question round, profile proposal, file naming,
story-only commit protocol or brainstorming hand-off. Each of those would either add an approval
step (`AC-7`) or write the wrong file. intake's WHAT/WHY boundary still holds: the record states
what changed and why, never how the solution is built.

**Steps** (each states its reason in the skill text, per `docs/prompt-standards.md`):
1. **Establish the decision.** Name the explicit human decision that covers this change: who, when,
   and where it was given (a message, a review thread, a commit). If no explicit decision covers
   the whole change, ask the human the uncovered question before writing anything, then continue
   on the answer. No other approval step exists (`AC-7`).
2. **Fix the baseline.** Name the artifact revision the change is measured against: the commit at
   which the changed text was last approved. Read the artifact at that revision.
3. **Enumerate the baseline's conditions** before assigning any fate: every acceptance criterion,
   every outcome or scope sentence that constrains the result, and every stated exclusion. A
   template cannot reveal an omitted condition; the enumeration can (`AC-3`).
4. **Assign fates and AC operations** (§2), one row per condition or per contiguous group of
   criteria that share a fate. Then **reconcile**: every enumerated condition appears in a row. A
   condition that has none is listed in the record as `unaccounted`, never left out (`AC-3`).
5. **Apply the AC operations** to the criteria list under intake's existing rules 1–5
   (*Acceptance-criterion IDs*): citation form, adoption for older stories, dated notes,
   withdrawals and the branch-aware next number with its collision stop. The route adds no
   numbering or citation rule of its own (`AC-2`).
6. **Fill the remaining fields** (§2): scope boundary, open questions, dependent artifacts,
   reviews already run.
7. **Write and commit.** Write the record and the edited text. Stage only the changed artifact and
   any dependent artifact this change updates. Check the staged set before committing. Commit with
   a message naming the change, the decider and the date.
8. **Stop.** Name what the change unblocks and what stays blocked (§2, dependent artifacts and
   reviews). Nothing resumes a gate, a plan or an implementation on its own (`AC-7`).

## §2 The change record

Placed in the changed artifact: in a story at the end of §3 (the criteria it accounts for), in a
spec at the end of the section it changes. Its shape:

```markdown
**Changed YYYY-MM-DD — <reason class>.** Decided by <who>, <where>. Baseline: <commit>. <Rationale.>

| Earlier condition | Fate | AC operation |
|---|---|---|
| <AC-n, or the quoted condition> | <fate, or several> | <operation> |

- **Scope boundary:** in: <…>; out: <…>.
- **Open questions:** <question> → <where recorded>; or none.
- **Dependent artifacts:** <path> → <status>; …
- **Reviews already run:** <cycle or gate> → <consequence, with the rule cited>; …
- **Evidence (optional):** <spec-delta report or other link>.
```

**Reason class**, exactly one (`AC-1`): `changed requirement` · `gap found` (by the implementation
or a review) · `change of direction`.

**Fate**, per condition, the AGENTS.md set (`AC-3`): `kept` · `moved → <destination>` ·
`dropped — <reason>`. A row may carry several fates when a narrowing keeps part of a condition and
moves or drops the rest; naming only the surviving part would hide what left the scope.
`deferred` is a move and names where it went.

**AC operation**, separate from the fate, under intake's rules (`AC-2`): `none` · `reworded` ·
`narrowed` · `withdrawn` · `added AC-<n>`. A replacement is `withdrawn` plus `added AC-<n>`;
the old line stays struck through with its dated reason. "Kept, reworded" is fate `kept` with
operation `reworded`.

**Dependent artifacts** (`AC-5`), each with exactly one status: `updated in this change` ·
`open — permitted by <rule>` · `blocks <named continuation> until updated`. `open` requires a cited
rule that permits leaving it. Where a rule demands the update in the same commit, `open` is not
available; for example a Gate-B fix that changes specified behaviour updates the spec in that commit
(`.claude/review-gates.md`, Gate B, "A fix that changes specified behaviour updates the spec in the
same commit").

**Reviews already run** (`AC-6`): for each gate cycle the change touches, the consequence and the
rule that decides it. What the rules decide, as read on 2026-10-05:
- a change to a governing profile or to the cited set while a cycle is open costs that cycle a
  further pass (`.claude/review-gates.md`, "Any profile change costs at least one further pass";
  "The cited set is re-read at each pass");
- a cycle that has already closed stands (the opening floor paragraph: "a cycle that has already
  closed stands");
- a behavioural Gate-B fix and its spec update share a commit and one re-review (the Gate-B
  paragraph quoted above);
- a change to an artifact's content after its Gate-A cycle closed: the rules give no general
  "further pass" or "new cycle" answer. Gate A's content condition reads equality at closure only,
  and "Closure introduces no new kind of record" states that a change to a cited story's criteria
  "nothing here reaches". The record says so and names the human's decision (or that it is pending,
  which blocks the dependent continuation). It never writes a rule the gates do not have.

The skill text cites these rules by paragraph title, and does not copy them, so a later gate
change has one source.

**Evidence link** (story §5): optional. Where `scripts/spec-delta.py` produced a report for the
change, the record may cite it as evidence. The route does not run or require it.

## §3 The `sparring` pointer

One short paragraph in `sparring` (*Coding-agent prompts*): when the advice is to change an approved
story or spec, draft the change record in the conversation in intake's shape and put it into the
coding-agent prompt's scope; the coding session writes it under `dev-workflow:intake`'s amendment
route. It points at intake's section and does not restate it. The *Authority* section is
unchanged (`AC-8`).

## §4 Evidence (`battery+check`)

**Battery:** the AGENTS.md quality row, exit 0.

**Check, mechanical (rung 2), with its counterfactual.** A new check `4f` in
`scripts/check-invariants.sh` fails unless intake's skill text carries the change-record shape:
the heading line's fields, the three reason classes, the three fates, the AC-operation set, the
three dependent-artifact statuses and the reviews field. Reject/accept pairs in
`scripts/check-invariants.test.sh`. It fails against the prior skill text. It proves the template is
present, not that the procedure is followed; the replay below carries that.

**Named verification: replay on the two 2c narrowings** (`AC-9`). Inputs: the pre-narrowing story
texts, recovered from unreachable local commits (`9fb981f` for part 1, `5fcc072` for part 2), the
narrowing commits with their decision text (`f9aae57` for part 1, `32609a0` for part 2), and the
narrowed versions on `main`. All four are copied to `.context/g1a-replay/` in the main checkout,
since git may prune unreachable objects; the replay reads those copies. A fresh agent given only the new intake section and
those inputs produces a change record for each. Compare with the historical fate tables
(`docs/superpowers/stories/2026-10-02-run-analytics-trace-id-and-retention-story.md` and
`docs/superpowers/stories/2026-10-02-review-loop-usefulness-assessment-story.md`): every
historical row and fate must be reproduced (historical `Narrowed` → `kept` plus a `moved` or
`dropped` remainder; `Replaced` → `withdrawn` plus `added`; `Deferred` → `moved`), and the
dependent artifacts each narrowing changed must be named. Each difference is reported, not hidden.

## §5 Surfaces this change touches

- `plugins/dev-workflow/skills/intake/SKILL.md`: frontmatter `description`, *When to use*, the new
  section.
- `plugins/dev-workflow/skills/sparring/SKILL.md`: the pointer paragraph.
- `plugins/dev-workflow/.claude-plugin/plugin.json` 0.16.0 → 0.17.0 and `CHANGELOG.md` (invariant 12).
- `scripts/check-invariants.sh` and its test (check 4f).
- Statements the change makes false, found by the standing lens: AGENTS.md invariant 11 ("Four
  narrow checks"), the README row for `intake`, and any count of checks elsewhere.
- `todos.md`: G1a marked done with the PR.

Both skills pass all 12 items of `docs/prompt-standards.md` (invariant 11).
