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
step (`AC-7`) or write the wrong file. The route makes no new solution-design decision. For a
story, intake's WHAT/WHY boundary holds as before; for a spec, the record may state an
already-decided technical condition (an ordering, a contract, an algorithm), because recording it
is not designing it.

**intake's global instructions are scoped, and each old condition is accounted for.** Today
*Stop and ask* and *Common mistakes* read as rules for every intake run. The change scopes each item:

| Existing instruction | Fate under this change |
|---|---|
| One-round pause | kept for the new-story route; the amendment route's only question is step 1's uncovered decision |
| Grounding floor | kept for the new-story route; the amendment route's equivalent is step 2's stop when the baseline cannot be established |
| Dirty or unexpected index (story path only) | kept for the new-story route; moved → step 8 for a standalone amendment commit: pre-existing staged work stops it, the expected staged set is the changed artifact plus the dependent artifacts marked `updated in this change`, and staged content must equal the written files. Where a gate or an open cycle governs the commit, step 8 defers to its rules instead |
| No AGENTS.md | kept for both routes: a story's §4 needs it, and every amendment needs it for the Don't "Never replace a decision procedure without accounting for its old conditions" |
| No `superpowers:brainstorming` | kept for the new-story route only; the amendment route hands off to nothing |
| Common mistake "committing text the user hasn't approved" | kept for the new-story route; for amendments the covering decision of step 1 is the approval, and no draft-approval step is added (`AC-7`) |
| Common mistakes "HOW outside §4" and "empty §4" | kept for stories on both routes (story-template constraints); not applied to specs, whose sections are their own. Recording an already-decided technical change in a spec is recording, not designing |
| Other common mistakes (invariants from memory, padding, `git add -A`) | kept for both routes |

**Steps** (each states its reason in the skill text, per `docs/prompt-standards.md`):
1. **Establish the decision.** Name the explicit human decision that covers this change: who, when,
   and where it was given (a message, a review thread, a commit). If no explicit decision covers
   the whole change, ask the human the uncovered question before writing anything, then continue
   on the answer. No other approval step exists (`AC-7`).
2. **Fix the baseline.** Name the approved text the change is measured against: the commit at
   which it was last approved, or, for approved text that was never committed, the content hash
   recorded with the approval (for example the hash a Gate-A request pinned). Read the baseline.
   **If the approved text cannot be established** — no such commit, no recorded hash, or a hash
   that matches no available text — stop and name what is missing. Never substitute `HEAD` or the
   working copy for it.
3. **Reconcile the current text with the baseline.** Compare the artifact as it now stands (working
   tree and index) with the baseline. Changes made since then — another amendment, another
   session's edits — are listed in the record and accounted for like any other condition, or, if
   no decision covers them, put to the human under step 1. Unrelated edits are preserved, never
   overwritten. Concurrent AC-number claims stay under intake's rule 3. **The same applies to every
   file the route will write**, not only the changed artifact: each existing dependent artifact's
   current state (working tree and index) is captured here, an intervening edit to it is reconciled
   the same way, and a path the route will create must not yet exist.
4. **Enumerate the baseline's conditions** before assigning any fate: every acceptance criterion,
   every outcome or scope sentence that constrains the result, and every stated exclusion. A
   template cannot reveal an omitted condition; the enumeration can (`AC-3`). **For a spec
   amendment**, also read the governing stories named in the spec's `Story:` header, and map each
   changed spec condition to the story criteria it serves.
5. **Assign fates and AC operations** (§2), one row per condition or per contiguous group of
   criteria that share a fate. Then **reconcile**: every enumerated condition appears in a row. A
   condition with no settled fate goes to the record's *Unaccounted* field (§2), never into the
   table under a fate it does not have (`AC-3`).
6. **Apply intake's ID rules exactly as written** (*Acceptance-criterion IDs*, rules 1–5). The
   route adds no numbering or citation rule of its own (`AC-2`). Concretely: every affected
   criterion is cited in rule 4's form, which has two branches — `<story path> AC-<n>` for a story
   with identifiers, and the story path with the quoted criterion text for one without. A story
   amendment of any kind is an amendment under rule 5, so an older story adopts identifiers at it
   even when no criterion's wording changes. Criterion operations (rule 2) apply only to criteria
   the decision changes. A spec amendment edits a governing story only when the decision changes
   that story, and then the story is a dependent artifact.
7. **Fill the remaining fields** (§2): scope boundary, open questions, dependent artifacts,
   reviews already run.
8. **Write and commit, deferring to the gate rules.** Two checkpoints, each against its own expected
   state: immediately before writing, every file the route will write must still equal the state step 3
   captured for it (a new path must still be absent); before staging, each must equal exactly what
   this step wrote. Only an unexpected difference returns to
   step 3; the route's own write is never read as an intervening change. Then decide, from the existing rules and not from this route, whether
   the complete changed set — the artifact and every dependent artifact updated with it — owes a
   gate (`.claude/review-gates.md`, "What counts as prose (the only Gate-B exemption)", and the
   rules of any open cycle). Where it owes one, or an open cycle's rules govern how it is committed,
   the commit goes through that gate and those rules, and the route stops at handing it over.
   Only otherwise is it a standalone commit, under the same index checks the new-story route uses:
   stop if the index already holds staged work this change did not stage; stage exactly the changed
   artifact and the dependent artifacts the record marks `updated in this change`; verify the staged
   path set and that each staged file's content equals the written file; commit with a message
   naming the change, the decider and the date.
9. **Stop.** Name what the change unblocks and what stays blocked (§2: unaccounted conditions,
   dependent artifacts, reviews). Nothing resumes a gate, a plan or an implementation on its own
   (`AC-7`).

## §2 The change record

Placed in the changed artifact: in a story at the end of §3 (the criteria it accounts for), in a
spec at the end of the section it changes. Its shape:

```markdown
**Changed YYYY-MM-DD — <reason class>.** Decided by <who>, <where>. Baseline: <commit or approved-content hash>. <Rationale.>

| Earlier condition | Fate | AC operation |
|---|---|---|
| <AC-n, or the quoted condition> | <fate, or several> | <operation> |

- **Unaccounted:** <condition> → blocks <named continuation> until settled; or none.
- **Intervening changes:** <change since the baseline> → <how accounted>; or none.
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
`deferred` is a move and names where it went. A condition with no settled fate is not given one:
it goes to **Unaccounted**, which blocks the named continuation until a decision settles it.

**AC operation**, separate from the fate, under intake's rules (`AC-2`): `none` · `reworded` ·
`narrowed` · `withdrawn` · `added AC-<n>`. A replacement is `withdrawn` plus `added AC-<n>`;
the old line stays struck through with its dated reason. "Kept, reworded" is fate `kept` with
operation `reworded`.

**Dependent artifacts** (`AC-5`), each with exactly one status: `updated in this change` ·
`open — permitted by <rule>` · `blocks <named continuation> until updated`. `open` requires a cited
rule that permits leaving it; where a rule demands the update in the same commit, `open` is not
available, and the record cites that rule.

**Reviews already run** (`AC-6`): for each review input the change touches and each cycle it
affects, open or closed, the record cites the existing source rule that decides the consequence,
by its paragraph title in `.claude/review-gates.md`. The inputs to check include, without this list
being exhaustive: the artifact's text, a governing profile, the cited set, the assigned fix set, a
cited story's criteria and settled decisions. **The spec deliberately does not summarise what those
rules decide**: each summary written during this design overstated a rule (Gate-A passes 1 and 2),
and AGENTS.md forbids describing a gate beyond what it compares. The record quotes or cites the
rule it relied on. Only where the author checked the sources for an input and found none that
decides it does the record say "no rule found", naming the input and the paragraphs checked, and
then the human's decision or that it is pending, which blocks the dependent continuation. It never
writes a rule the gates do not have.

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
the heading line's fields (date, reason class, decider, baseline), the three reason classes, the
three fates, the AC-operation set, the *Unaccounted* and *Intervening changes* fields, the three
dependent-artifact statuses and the reviews field, the template lines between the section's
first line that is exactly ```markdown and the next line that is exactly ```, and the closed sets
outside them (placement added 2026-10-05, PR #45 review). It does not parse Markdown: a template
nested inside another fence (four backticks, tildes, indented) can pass. A fence parser was tried
in PR #45 and withdrawn after each review pass found new edge cases; the limit is stated in the
checker and in `todos.md`. It is bracketed by `# --- BEGIN check 4f ---` /
`# --- END check 4f ---` markers like 4a–4e and joins the script header's mutation procedure, so
its own rejection cases are shown to depend on it: with the 4f block removed, its reject cases
pass, and only those flip. Reject/accept pairs in `scripts/check-invariants.test.sh`. It fails
against the prior skill text. It shows the template's lines are present in that layout, not that
the template renders as one or that the procedure is followed; the replay below carries the latter.

**Named verification: replay on the two 2c narrowings** (`AC-12`; it replaced `AC-11`, which had replaced `AC-9`, on 2026-10-05).

*Replay package* — a committed, sanitized package in
`docs/superpowers/replays/2026-10-05-controlled-change/`, so that anyone with the repository can
inspect the inputs and re-run the replay (the source commits are unreachable and may be pruned;
the replay reads only the package). The repository is public, so local advisory files are never
copied wholesale; the package README lists every removal and its reason:
- the baselines: part 1 at `9fb981f`, part 2 at `5fcc072` (the story text before any amendment);
- the after-texts: each story as its narrowing commit left it (`f9aae57` for part 1, `32609a0` for
  part 2), **with the change-record blocks removed** (the amendment paragraphs and fate tables);
- the decision evidence: each narrowing commit's message, with any fate table removed, and a
  sanitized excerpt of the assessment the decision was taken on (the parts that carry the
  decision kept verbatim; local paths, snapshots and side analysis removed);
- each narrowing commit's unabridged changed-path list (`git show --format= --name-only`; the
  `--stat` view abbreviates long paths), so dependent artifacts can be named;
- the rule context, read from the implementation's head commit (named in the evidence entry and the
  package README), not copied into the package: the new
  intake skill text, which is the procedure under test and carries the ID rules, plus
  `.claude/review-gates.md` and `AGENTS.md`. The historical cycles ran under older text (neither
  baseline commit has `.claude/review-gates.md` or the ID rules), so the replay applies today's
  rules retrospectively, and a difference caused by a rule that did not exist then is labelled as
  such, apart from procedure failures.
The expected answers (both historical change records, verbatim) sit in the package's `expected/`
directory, which the replay agent does not receive; only the comparator reads it. The replay's
records and the comparison are committed beside them. When an input changes, the replay is run
again on the changed package. Any leakage that cannot be avoided —
for example a narrowed criterion whose wording reveals its fate — is recorded as a limit of the
verification.

*Part 1 holds two changes in one commit*: an amendment after Gate-A pass 1 (credit balance dropped,
criterion 1 re-keyed on the transcript) and the narrowing after pass 4. No committed text sits
between them. The replay therefore treats part 1 as one change from `9fb981f` to `f9aae57`, and the
expected answer is the union of both historical records. A difference that comes only from this
boundary is labelled as such, apart from procedure failures.

*Boundary.* The replay exercises the **record-generating subset** of the route: steps 1, 2, 4, 5, 6
and 7, from the package alone, in an isolated scratch directory outside any checkout. Steps 3
(reconciling against a live working tree) and 8 (writing and committing) need repository state the
historical cases no longer have, so they are **not** exercised, and the verification claims nothing
about them; step 9 is reduced to naming what stays blocked. The agent writes only its change
records, to the scratch directory.

*Run*: a fresh agent, given the package and told to follow intake's amendment route within that
boundary, produces one change record per part. *Compare* with the expected answers (historical `Narrowed` → `kept` plus a `moved` or
`dropped` remainder; `Replaced` → `withdrawn` plus `added`; `Deferred` → `moved`; "Kept, reworded"
→ `kept` with `reworded`). **Pass condition** (`AC-12`, which replaced `AC-11` on 2026-10-05):
as the story states it, including its dated narrowing. In short: the record is checked
condition by condition against the route; the deviations found (a fate or operation without a
quoted covering decision, an omitted baseline condition, a wrong dependent-artifact status) are
named with their locations, and the list is not claimed exhaustive; and the comparison states whether
the run complied, including whether every baseline condition received a fate or was listed as
Unaccounted (an omission is a deviation to name, not a reason to hide the run); and the
comparison checks that the dependent artifacts each change touched are named (part 1:
`docs/superpowers/specs/2026-10-02-run-analytics-design.md`, written in the same commit; part 2:
`docs/superpowers/stories/2026-10-02-telemetry-and-review-loop-usefulness-story.md` and `todos.md`);
and every row that differs from the historical table is reported with its cause — a rule the
history predates, a change the historical table did not account for, or decision evidence missing
from the input. A non-compliant run is reported as such, never as a pass of the procedure.

**Changed 2026-10-05 — change of direction.** Decided by Daniel, 2026-10-05, in this session. Baseline: 832510b. The pass condition required every historical row to be reproduced; Gate B pass 2 (cycle xby91gy4in) showed the historical tables are not a correct oracle under today's rules. Full record: the story, end of §3 (AC-9 withdrawn, AC-11 added).

| Earlier condition | Fate | AC operation |
|---|---|---|
| "every historical row and fate must be reproduced" | dropped — see the story's record | none (cites the story's AC-9 withdrawal) |
| dependent artifacts named; each difference reported | kept, now with a cause per difference | none |
| the battery; check 4f with its counterfactual and mutation record | kept | none |
| the replay package: preserved inputs, withheld answers, today's rules applied retrospectively, part 1's two changes as one | kept | none |
| recording every input that already states a fate, in compare.md and the evidence entry | kept | none |
| the replay boundary: steps 1, 2, 4–7 only; steps 3 and 8 not exercised | kept | none |
| §0–§3 and §5 | kept | none |

- **Unaccounted:** none. **Intervening changes:** none since 832510b. **Scope boundary:** unchanged. **Open questions:** none.
- **Dependent artifacts:** the story → updated in this change; the plan → updated in this change; `todos.md` (G1a's acceptance checks) → updated in this change.
- **Reviews already run:** as in the story's record.

**Changed 2026-10-05 — changed requirement.** Decided by Daniel, 2026-10-05, in this session, on Greptile's PR #45 review ("replay evidence is checkout-local"). Baseline: c9be2fe. The replay inputs were local copies in one checkout, so no other reviewer could inspect or re-run the verification. They become a committed, sanitized package; private advisory files are excerpted, not copied, and every removal is listed. The same record carries the check-4f placement repair from the same review: it is a defect in this change's own check, fixed under the PR review rules and not a separate decision.

| Earlier condition | Fate | AC operation |
|---|---|---|
| package in `.context/g1a-replay/` of the main checkout (serves `docs/superpowers/stories/2026-10-05-controlled-change-to-an-approved-story-story.md` AC-11) | dropped — not inspectable outside one checkout; moved → `docs/superpowers/replays/2026-10-05-controlled-change/` | none |
| decision evidence: the full assessment each decision was taken on (AC-11) | kept: the decision-bearing parts, verbatim; dropped — local paths, snapshots, side analysis, the spec-level repair advice (public repository) | none |
| rule context copied into the package (AC-11) | moved → read from the named head commit | none |
| expected answers withheld from the replay agent (AC-11) | kept (`expected/`, not given to the agent) | none |
| every other §4 condition, and §0–§3, §5 | kept | none |
| check 4f: the required lines present once in the section (the `battery+check` evidence for the story's profile; no criterion changes) | kept; added: template lines inside the template fence, closed sets outside it (Greptile, PR #45: lines elsewhere in the section passed) | none |

- **Unaccounted:** none. **Intervening changes:** none since c9be2fe. **Scope boundary:** unchanged. **Open questions:** none.
- **Dependent artifacts:** the plan (Task 4) → updated in this change; `AGENTS.md` (architecture tree) → updated in this change.
- **Reviews already run:** the closed Gate-A spec cycle lbveuxkbje and plan cycle p3780ujtg3, whose reviewed spec §4 and plan Task 4 this changes → no rule found (input: the spec's and plan's verification text after their Gate-A cycles closed; paragraphs checked: "Gate A's content condition, and its closing act", "Closure introduces no new kind of record"); human decision: Daniel 2026-10-05, as for Gate B below. The closed Gate-B cycle xby91gy4in → no rule found (input: the spec's verification text after that cycle closed; paragraphs checked: "Gate B's content condition, and its closing act", "Closure introduces no new kind of record"); human decision: Daniel 2026-10-05, the change and the 4f placement fix go through a new Gate-B cycle; the replay is re-run on the package, since its decision evidence changed.

## §5 Surfaces this change touches

- `plugins/dev-workflow/skills/intake/SKILL.md`: frontmatter `description`, *When to use*, the new
  section, and the route scoping of *Stop and ask* and *Common mistakes* (§1's table).
- `plugins/dev-workflow/skills/sparring/SKILL.md`: the pointer paragraph.
- `plugins/dev-workflow/.claude-plugin/plugin.json` 0.16.0 → 0.17.0 and `CHANGELOG.md` (invariant 12).
- `scripts/check-invariants.sh` and its test (check 4f).
- Statements the change makes false, found by the standing lens: AGENTS.md invariant 11 ("Four
  narrow checks"), the README row for `intake`, and any count of checks elsewhere.
- `todos.md`: G1a marked done with the PR.

Both skills pass all 12 items of `docs/prompt-standards.md` (invariant 11).
