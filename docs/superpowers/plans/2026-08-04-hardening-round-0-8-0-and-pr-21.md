# Hardening round — the 0.8.0 cycle and PR #21 — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Land four hardenings from the 0.8.0 cycle and PR #21 as text, record them in four ledger rows, park what has no repair, and open four split stories — without changing any skill file.

**Architecture:** Three one-sentence additions to `CLAUDE.md` §5, each mirrored into the inline template in `plugins/dev-workflow/commands/workflow-init.md`; one clause appended to an existing `AGENTS.md` Don't; one new taxonomy class; four appended ledger rows; six `todos.md` row updates; four new story files. No executable code changes.

**Tech Stack:** Markdown prompts and POSIX shell checks. The quality battery in `AGENTS.md § Commands` is the test cycle — there is no unit test for prose.

**Spec:** `docs/superpowers/specs/2026-08-03-hardening-round-0-8-0-and-pr-21-design.md` (Gate A closed at nine passes, `b9111a2`).

**Story:** `docs/superpowers/stories/2026-08-03-hardening-round-0-8-0-and-pr-21-story.md` — read its profile header fresh at every Gate-B pass; no value from it is copied here.

## Deliverables checklist

Everything this round ships. A task is not done until its rows here are true.

- [ ] **Three §5 sentences** — Gate-B lens, Profiles counterfactual, Gate-A pass procedure (Task 1)
- [ ] **Three template mirrors** of those sentences in `workflow-init.md`, byte-identical, same headings (Task 1)
- [ ] **One `AGENTS.md` Don't amendment** — the 2026-07-19 gate-claims Don't (Task 2)
- [ ] **One taxonomy class** — `mechanical-check-skipped-before-review` (Task 3)
- [ ] **Four split stories**, unprofiled, each with a profile-confirmation first criterion and an inheritance inventory (Tasks 4–5)
- [ ] **Six `todos.md` updates** — one new parked row (C4/C5), evidence case 3 on the scope-blind row, Finding A and Finding B marked fired, the F7 row marked fired, the slot-collision row marked not-fired, and the env-var row's observation appended (Task 6)
- [ ] **Four ledger rows** — A, B, C, D (Task 7)
- [ ] **Version 0.8.1** in the manifest, and a `## 0.8.1` CHANGELOG entry (Task 8)
- [ ] **Validation evidence** — battery green, the named verification with its counterfactual, prompt conformance, mirror parity, cross-finding conflict check (Task 9)

## Global Constraints

Copied verbatim from the spec and `AGENTS.md`. Every task's requirements implicitly include this section.

- **Each §5 edit is one sentence at the exact existing site.** A finding needing a paragraph is a finding whose home is wrong (spec D5).
- **`CLAUDE.md` and `workflow-init.md` change in the same commit.** A sentence landing in one copy only is shipped-template drift.
- **No skill file is edited.** `plugins/dev-workflow/skills/**` is out of scope (spec D7). If a step seems to need a skill edit, stop and surface.
- **Version is `0.8.1`.** Required by invariant 12, since the round changes a path under `plugins/dev-workflow/`.
- **The ledger is append-only.** Never edit an existing row; resolve a `pending` row by appending a new one.
- **Escape a literal `|` inside a ledger field as `\|`.** This round avoids guard quotations containing pipes rather than relying on an unstated rule for the `ref` column.
- **The four stories are unprofiled** — no `**Risk:**`/`**Security:**`/`**Validation:**` line — and each carries the profile-confirmation criterion as its first acceptance criterion.
- **No `Co-Authored-By: Claude` or `Generated with` trailers** on any commit.
- **Quality command** (the battery, what CI runs), from `AGENTS.md § Commands`:

```
shellcheck --shell=sh plugins/dev-workflow/hooks/codex-gate.sh && shellcheck --shell=sh --exclude=SC2015 plugins/dev-workflow/hooks/codex-gate.test.sh && shellcheck --shell=sh scripts/check-invariants.sh && shellcheck --shell=sh --exclude=SC2015 scripts/check-invariants.test.sh && shellcheck --shell=sh scripts/check-version-bump.sh && shellcheck --shell=sh scripts/check-version-bump.test.sh && HOOK_SH=sh sh plugins/dev-workflow/hooks/codex-gate.test.sh && HOOK_SH=dash dash plugins/dev-workflow/hooks/codex-gate.test.sh && sh scripts/check-invariants.test.sh && sh scripts/check-invariants.sh && sh scripts/check-version-bump.test.sh && sh scripts/check-version-bump.sh main && claude plugin validate . --strict
```

- **`check-invariants.sh` scans the working tree, not the tracked set.** Move any untracked scratch directory aside before running the battery, or it can fail on text it merely quotes.

---

## File Structure

| File | Responsibility in this round |
|---|---|
| `CLAUDE.md` | three §5 sentences (Gate-B lens, Profiles counterfactual, Gate-A pass procedure) |
| `plugins/dev-workflow/commands/workflow-init.md` | the inline-template mirror of those three sentences |
| `AGENTS.md` | one clause appended to the 2026-07-19 Don't |
| `docs/hardening-taxonomy.md` | one new class |
| `docs/hardening-log.md` | four appended rows |
| `todos.md` | one new parked row, five existing rows updated |
| `docs/superpowers/stories/2026-08-04-harden-finding-guard-scope-precheck-story.md` | split story: the precheck |
| `docs/superpowers/stories/2026-08-04-hardening-ledger-supersession-story.md` | split story: F7 |
| `docs/superpowers/stories/2026-08-04-ledger-route-without-pull-requests-story.md` | split story: Finding A |
| `docs/superpowers/stories/2026-08-04-section-5-version-stamp-story.md` | split story: Finding B |
| `plugins/dev-workflow/.claude-plugin/plugin.json` | version 0.8.0 → 0.8.1 |
| `plugins/dev-workflow/CHANGELOG.md` | `## 0.8.1` entry |

---

### Task 1: The three §5 sentences and their template mirrors

**Files:**
- Modify: `CLAUDE.md` (three sites)
- Modify: `plugins/dev-workflow/commands/workflow-init.md` (the same three sites in the inline template)

**Interfaces:**
- Consumes: nothing.
- Produces: the three sentences that ledger rows A, C and D cite as their `ref` (Task 7). Their exact wording is fixed here; Task 7 quotes it.

**Anchors, verified at `b9111a2`:**

| Sentence | `CLAUDE.md` | `workflow-init.md` |
|---|---|---|
| Gate-B lens | line 247, paragraph opening `**Standing lens, every Gate-B call:` | line 441, same opening |
| Profiles counterfactual | line 342, the sentence beginning `satisfies it and the entry says which route was taken and why. Either route owes the` | line 532, same |
| Gate-A pass procedure | line 224, `Each pass: validate, revise, re-run.` | line 419, same |

Line numbers locate the paragraph; match on the quoted text, since a citation by line is the C3 defect this round hardens.

- [ ] **Step 1: Append the lens sentence in `CLAUDE.md`**

Find the paragraph opening `**Standing lens, every Gate-B call: "which existing statements does this diff falsify?"**`. Append to the end of that paragraph, after the sentence ending `plus two user-facing docs teaching a rule the same change had just narrowed.`:

```
  **Name what this diff changes the size, value or position of** — a list, a count, a
  version, an identifier, a cited line — and grep for where each is described elsewhere,
  because asked as an open question alone this lens missed three such statements in one
  cycle while being carried with unusual force.
```

Match the surrounding indentation (this paragraph is indented two spaces as a sub-bullet of the Gate-B item).

- [ ] **Step 2: Append the counterfactual sentence in `CLAUDE.md`**

Find the paragraph containing `Either route owes the **counterfactual**: the observation against the prior state.` Append after the sentence ending `A fabricated test satisfies nothing.`:

```
**Name the observation that would exist if the claim were false, and confirm the wiring could
have produced it** — a check that supplies its own input, runs where the defect cannot appear,
or uses a fixture that never reaches the branch it covers reports success because of how it was
wired, not because the thing it checks succeeded.
```

- [ ] **Step 3: Add the Gate-A sweep sentence in `CLAUDE.md`**

Find `Each pass: validate, revise, re-run. (Large/high-risk artifact: optional focused` and insert immediately after the sentence `Each pass: validate, revise, re-run.`, before the parenthetical:

```
Before each read pass, settle mechanically what the artifact asserts and a machine can decide
without side effects — cited paths, quoted passages, stated counts, the syntax of standalone
fenced blocks — inspecting quoted commands rather than running them, since a command quoted in
a spec may be destructive or an intentional failure.
```

- [ ] **Step 4: Mirror all three into `workflow-init.md`**

Apply Steps 1–3 verbatim at the three corresponding sites in the inline template (lines 441, 532, 419 area). The text must be byte-identical to what landed in `CLAUDE.md`; only surrounding indentation may differ if the template's own indentation differs.

- [ ] **Step 5: Verify mirror parity**

Run:

```bash
cd "$(git rev-parse --show-toplevel)"
for lit in \
  "Name what this diff changes the size, value or position of" \
  "Name the observation that would exist if the claim were false" \
  "Before each read pass, settle mechanically what the artifact asserts" ; do
  a=$(tr '\n' ' ' < CLAUDE.md | tr -s ' ' | grep -cF -- "$lit")
  b=$(tr '\n' ' ' < plugins/dev-workflow/commands/workflow-init.md | tr -s ' ' | grep -cF -- "$lit")
  printf '%-62s CLAUDE=%s TEMPLATE=%s\n' "${lit:0:60}" "$a" "$b"
done
```

Expected: every row `CLAUDE=1 TEMPLATE=1`. Whitespace is normalized because both files are hard-wrapped and an accurate quotation can span a line break.

- [ ] **Step 6: Verify the full sentences match, not just their openings**

Run:

```bash
cd "$(git rev-parse --show-toplevel)"
norm() { tr '\n' ' ' < "$1" | tr -s ' '; }
for pat in 'Name what this diff changes[^.]*\.' \
           'Name the observation that would exist[^.]*\.' \
           'Before each read pass[^.]*\.' ; do
  a=$(norm CLAUDE.md | grep -o "$pat")
  b=$(norm plugins/dev-workflow/commands/workflow-init.md | grep -o "$pat")
  if [ -n "$a" ] && [ "$a" = "$b" ]; then
    echo "IDENTICAL: ${a%% *}..."
  else
    echo "DIFFERS or EMPTY:"; printf 'CLAUDE: %s\nTEMPLATE: %s\n' "$a" "$b"
  fi
done
```

Expected: three `IDENTICAL:` lines. The `-n "$a"` guard matters — without it two empty extractions compare equal and report a match that proves nothing, which is the `verification-masks-failure` shape this round hardens.

No process substitution: `<(...)` is a bashism, and this repo's invariant 4 is POSIX `sh`. Every fenced block in this plan parses under `sh -n`.

- [ ] **Step 7: Run the battery**

Run the quality command from Global Constraints. Expected: exit 0.

- [ ] **Step 8: Commit**

```bash
git add CLAUDE.md plugins/dev-workflow/commands/workflow-init.md
git commit -m "WIP: three §5 sentences and their template mirrors"
```

Named `WIP:` deliberately — the hook treats a `wip`-prefixed message as cycle-internal, so it neither fires a Gate-B STOP nor resets the pass counters. Task 9 replaces it by amend.

---

### Task 2: The `AGENTS.md` Don't amendment

**Files:**
- Modify: `AGENTS.md` (the 2026-07-19 Don't, closing sentence at line 218)

**Interfaces:**
- Consumes: nothing.
- Produces: the rule ledger row B cites as its `ref` (Task 7).

- [ ] **Step 1: Extend the Don't's closing sentence**

Find in `AGENTS.md § Don'ts`, inside `**Never describe what a gate proves without checking what it actually compares.**`, the closing sentence:

```
  underlying rule is the check itself: for every sentence about a gate, name the exact
  comparison the code performs, and delete any part of the sentence that outruns it.
```

Replace the trailing `outruns it.` so the sentence continues:

```
  underlying rule is the check itself: for every sentence about a gate, name the exact
  comparison the code performs, and delete any part of the sentence that outruns it — and
  where the sentence says what the mechanism does *not* cover, name the axes it was checked
  against and state whether that list is exhaustive, because an enumeration read as complete
  guarantees the axes it omits.
```

- [ ] **Step 2: Verify the amendment rejects its own motivating case**

This is the operative check. Read the amended sentence and apply it to `It bounds the **scan**, not memory`:

- Does that sentence name the axes it was checked against? Yes — scan and memory.
- Does it state whether that list is exhaustive? **No.**
- Therefore it fails the amended rule.

Expected: fails on the exhaustiveness requirement. If it passes, the wording is wrong — a rule asking only for the axes checked would approve the very sentence this amendment exists to reject. Stop and surface rather than proceeding.

- [ ] **Step 3: Confirm no other site restates this Don't**

Run:

```bash
cd "$(git rev-parse --show-toplevel)"
grep -rn "delete any part of the sentence that outruns it" --include='*.md' . | grep -v source-files/
```

Expected: only `AGENTS.md`. The Don't is repo-local and is not mirrored into the scaffolded template; if another site appears, stop and surface — a second copy would need the same amendment and this plan does not budget one.

- [ ] **Step 4: Run the battery**

Run the quality command. Expected: exit 0.

- [ ] **Step 5: Commit**

```bash
git add AGENTS.md
git commit -m "WIP: extend the gate-claims Don't to coverage enumerations"
```

---

### Task 3: The taxonomy class

**Files:**
- Modify: `docs/hardening-taxonomy.md` (append to `## Classes`, before the `**Promotion candidate.**` paragraph)

**Interfaces:**
- Consumes: nothing.
- Produces: the fingerprint string `mechanical-check-skipped-before-review`, used by ledger row D (Task 7).

- [ ] **Step 1: Add the class**

Insert as the last entry under `## Classes`, immediately before the `**Promotion candidate.**` paragraph:

```markdown
- `mechanical-check-skipped-before-review` — an artifact carrying machine-checkable assertions
  goes to an expensive read pass before anything parses it, so attention is spent on what a
  tool decides in seconds. Aliases: `sh -n` after the fact, the parser would have caught it,
  read pass before the sweep, manual review of machine-decidable claims.

  **Not `verification-masks-failure`.** There a check ran and could not fail; here the cheap
  check never ran at all. Grep this one when the sentence is "a parser would have found it
  immediately"; grep the other when it is "the check passed and proved nothing".
```

- [ ] **Step 2: Confirm the class is not being added to the skill**

Run:

```bash
cd "$(git rev-parse --show-toplevel)"
grep -c "mechanical-check-skipped-before-review" plugins/dev-workflow/skills/harden-finding/SKILL.md
```

Expected: `0`. Invariant 10 keeps project classes out of the shipped skill. The class is stack-neutral, and it lands in the project file anyway because the skill instructs minting there — the file's own `**Promotion candidate.**` note records the same of several existing classes.

- [ ] **Step 3: Run the battery**

Expected: exit 0.

- [ ] **Step 4: Commit**

```bash
git add docs/hardening-taxonomy.md
git commit -m "WIP: mint mechanical-check-skipped-before-review"
```

---

### Task 4: The `harden-finding` precheck split story

**Files:**
- Create: `docs/superpowers/stories/2026-08-04-harden-finding-guard-scope-precheck-story.md`

**Interfaces:**
- Consumes: nothing.
- Produces: the story path that `todos.md`'s scope-blind row points at (Task 6).

- [ ] **Step 1: Check the target path immediately before writing**

Run:

```bash
cd "$(git rev-parse --show-toplevel)"
p=docs/superpowers/stories/2026-08-04-harden-finding-guard-scope-precheck-story.md
[ -e "$p" ] && echo "EXISTS — compare content, do not overwrite" || echo "ABSENT — safe to create"
```

If it exists and its content is byte-identical to Step 2's text, reuse it and say so. If it exists and differs, **stop and surface** — do not overwrite (invariant 9's rule for scaffolded files).

- [ ] **Step 2: Write the story**

```markdown
# `harden-finding`'s recurrence rule is scope-blind — Story

**Date:** 2026-08-04 · **Size:** story

**Unprofiled, deliberately.** This story is a split from a designed round, not a raw idea, so
it did not pass through `dev-workflow:intake` — intake excludes items that have moved into
solution design. A profile is proposed and human-confirmed at intake time; writing one here
would be a confirmed-looking value nobody confirmed, which CLAUDE.md §5 classifies as an
unresolvable profile and stops on. Acceptance criterion 1 carries that debt instead.

## 1. Problem statement

`harden-finding`'s recurrence step tells you to re-read the ledger, and then decides from the
fingerprint and the latest matching row's rung. It never lets that row's **stated guard**
control the verdict. So a later in-class defect outside the guarded spelling is proposed for a
stronger rung than anything justifies — which the 2026-07-26 rows warn about by name, in ledger
prose the decision branch does not consult.

The 2026-08-03 hardening round applied the missing precheck by hand, on a standing instruction
from Daniel, and still reached a wrong verdict twice by reading one prior row's guard and
stopping. Landing the rule in the skill turned out to require decisions a rule paragraph cannot
carry, which is why it is here rather than in that round.

## 2. Desired outcome

A recurrence proposal states which prior rows it read, what each guards, and whether this
finding falls inside or outside — and a later reader can check that reasoning against the
ledger. Escalation follows from a guard that failed, never from a count.

## 3. Acceptance criteria

- [ ] Before design resumes on this story, whoever picks it up proposes both axes and the mode
      derived from them, pauses for Daniel's confirmation, and writes the confirmed profile into
      this header. Design continues only after that.
- [ ] A recurrence decision names every prior matching row it considered, not only the latest,
      and records what each guards.
- [ ] The record a decision leaves behind is sufficient for a later reader to reach the same
      inside/outside verdict without re-deriving it.
- [ ] The rule states what happens when a same-fingerprint row appears mid-run, including when
      that row is `pending` or its guard cannot be determined.
- [ ] Whether automatic escalation on recurrence is kept, narrowed, or dropped is settled
      explicitly, with a stated reason.
- [ ] The `AGENTS.md` Don't "Never replace a decision procedure without accounting for its old
      conditions" is satisfied for every condition the current step 3 and step 7 carry.

## 4. Affected AGENTS.md invariants

- `## Key invariants` → `### Prompts and scaffolding` — "11. **Prompt changes pass
  `docs/prompt-standards.md`** — all 12 checklist items, for any skill, command, agent
  definition, hook message, or scaffolded template."
- `## Key invariants` → `### Packaging` — "12. **A plugin change requires a version bump.**"
- `## Don'ts` — "**Never replace a decision procedure without accounting for its old
  conditions.** List what the previous prose required, then mark each one kept, moved, or
  deliberately dropped."

## 5. Open questions

Six, each paired with the failure that raised it:

- A verdict was reached by reading one prior row's guard and stopping, when an older row's guard
  covered the case. **Which prior rows must a recurrence be judged against before "outside" is
  safe?**
- A reader cannot tell whether a past rung choice followed from a guard reading or from a count,
  because nothing durable records the reading. **What does a later reader need, and where does
  it belong?**
- Guards are frequently exact spellings containing regex alternation, and the ledger's stated
  escaping rule covers the `finding` column. **How does a guard citation survive a Markdown
  table without changing what the columns mean?**
- Step 7 re-reads the ledger and then appends, so a row landing after that read is not seen, and
  a row seen at the read is treated as a duplicate without anyone consulting what it guards.
  **What should happen when a row appears mid-run?**
- Widening the branch condition from "latest matching row is a real rung" to "a matching row
  exists at a real rung" makes it fire when the latest row is `pending`, bypassing the
  prerequisite rule. **How do a guard scan and a prerequisite block compose?**
- The old step-3 text required proposing one rung stronger on recurrence, and a replacement
  choosing "the rung that fits the repair" does not carry it. **Is automatic escalation kept,
  narrowed, or deliberately dropped?**

## 6. Suggested size

`story` — one skill file, one decision procedure, one spec → plan → PR. It is above a chore
because the six questions above are real design, and below an epic because they all concern one
procedure in one file.
```

- [ ] **Step 3: Confirm the story is unprofiled and carries the criterion**

Run:

```bash
cd "$(git rev-parse --show-toplevel)"
p=docs/superpowers/stories/2026-08-04-harden-finding-guard-scope-precheck-story.md
grep -c '^\*\*Risk:\*\*\|^\*\*Security:\*\*\|^\*\*Validation:\*\*' "$p"
tr '\n' ' ' < "$p" | tr -s ' ' | grep -c 'proposes both axes and the mode derived from them'
grep -c '^## ' "$p"
```

Expected: `0` profile lines, `1` profile criterion, `6` sections.

- [ ] **Step 4: Commit**

```bash
git add docs/superpowers/stories/2026-08-04-harden-finding-guard-scope-precheck-story.md
git commit -m "WIP: split story for the harden-finding guard-scope precheck"
```

---

### Task 5: The three trigger stories

**Files:**
- Create: `docs/superpowers/stories/2026-08-04-hardening-ledger-supersession-story.md`
- Create: `docs/superpowers/stories/2026-08-04-ledger-route-without-pull-requests-story.md`
- Create: `docs/superpowers/stories/2026-08-04-section-5-version-stamp-story.md`

**Interfaces:**
- Consumes: nothing.
- Produces: three story paths that `todos.md` rows point at (Task 6).

Each story replaces a parked `todos.md` row that carries settled analysis, so each carries an inheritance inventory marking every condition of its source row **kept, moved, or deliberately dropped**. A thinner brief that quietly discards a matured constraint is the failure mode, and `AGENTS.md`'s "Never replace a decision procedure without accounting for its old conditions" applies to that replacement.

- [ ] **Step 1: Check all three paths immediately before writing**

```bash
cd "$(git rev-parse --show-toplevel)"
for p in docs/superpowers/stories/2026-08-04-hardening-ledger-supersession-story.md \
         docs/superpowers/stories/2026-08-04-ledger-route-without-pull-requests-story.md \
         docs/superpowers/stories/2026-08-04-section-5-version-stamp-story.md ; do
  [ -e "$p" ] && echo "EXISTS $p" || echo "ABSENT $p"
done
```

Absent → create. Byte-identical → reuse and say so. Present and different → **stop and surface**.

- [ ] **Step 2: Write the ledger-supersession story**

Path: `docs/superpowers/stories/2026-08-04-hardening-ledger-supersession-story.md`

```markdown
# The hardening ledger has no supersession convention — Story

**Date:** 2026-08-04 · **Size:** story

**Unprofiled, deliberately** — a split from a designed round, so it bypassed
`dev-workflow:intake`, which excludes work already in solution design. Acceptance criterion 1
carries the profile debt.

## 1. Problem statement

`docs/hardening-log.md`'s header says never edit a row, and one row per hardening. When a row's
"what this does NOT do" narration is later falsified by a feature change, neither move is
sanctioned: editing breaks the first rule, appending breaks the second.

This is live. The 2026-07-20 row describes pre-0.8.0 counting behaviour as current, and a reader
who trusts it is misled about how the gate hook counts today. That is the second falsified row,
which is the condition the parked backlog row named as its trigger.

## 2. Desired outcome

A reader who opens any ledger row can tell whether it still describes current behaviour, and a
row falsified by a later change can be marked as such without breaking either standing rule.

## 3. Acceptance criteria

- [ ] Before design resumes on this story, whoever picks it up proposes both axes and the mode
      derived from them, pauses for Daniel's confirmation, and writes the confirmed profile into
      this header. Design continues only after that.
- [ ] The 2026-07-20 row no longer reads as current behaviour, and it was not edited.
- [ ] The append-only rule and the one-row-per-hardening rule both still hold after the change.
- [ ] A reader can determine, from the ledger alone, which row to trust for current behaviour.

## 4. Affected AGENTS.md invariants

- `## Key invariants` → `### Prompts and scaffolding` — "9. **`/workflow-init` never overwrites
  silently.** Idempotent: missing → write; identical → report unchanged; present and different →
  show the diff and ask; additive files (`.gitattributes`, `.mcp.json`, …) → merge."
- `## Key invariants` → `### Prompts and scaffolding` — "8. **`/workflow-init`'s templates stay
  inline** in the command body."

## 5. Inherited conditions

From the parked `todos.md` row "**The hardening ledger has no supersession convention.**":

| Condition | Disposition |
|---|---|
| Never edit a row | **kept** — any solution must preserve it |
| One row per hardening | **kept** — any solution must preserve it |
| The 2026-07-20 row now describes pre-0.8.0 behaviour as current | **kept** as the motivating instance |
| The 2026-07-20 *spec* took a version-qualified supersession note and it worked | **kept** as prior art the design should evaluate first |
| Alternative: an explicit "rows are historical, read the newest row for current behaviour" header statement | **kept** as a candidate |
| Trigger: the next row falsified by a later change — this is the second | **moved** — the trigger has fired and is recorded here |

## 6. Open questions

- Which artifacts must the convention reach before a reader can trust any row — this repo's
  ledger alone, or every ledger `/workflow-init` scaffolds? A repo-only fix ships a rule this
  kit's ledger obeys and every scaffolded one does not.

## 7. Suggested size

`story` — one file's header convention plus possibly one inline template, one spec → plan → PR.
```

- [ ] **Step 3: Write the no-PR ledger route story**

Path: `docs/superpowers/stories/2026-08-04-ledger-route-without-pull-requests-story.md`

```markdown
# A route from a fixed finding to the ledger, for projects that never open PRs — Story

**Date:** 2026-08-04 · **Size:** story

**Unprofiled, deliberately** — a split from a designed round, so it bypassed
`dev-workflow:intake`. Acceptance criterion 1 carries the profile debt.

## 1. Problem statement

The only mandated ledger check lives in `/dev-workflow:process-pr-review` step 5, so a project
that never opens a pull request never reaches it. One project has 51 Gate-A pass files and
**zero** ledger rows: findings were raised, validated and fixed, and none was ever considered
for hardening.

## 2. Desired outcome

A project that fixes review findings without opening a pull request still reaches the ledger
check, and a fixed finding that warrants hardening is not lost to a compaction, an interruption
or a handoff.

## 3. Acceptance criteria

- [ ] Before design resumes on this story, whoever picks it up proposes both axes and the mode
      derived from them, pauses for Daniel's confirmation, and writes the confirmed profile into
      this header. Design continues only after that.
- [ ] A project with no pull requests reaches a ledger check on the findings it fixed.
- [ ] The route does not depend on same-session memory.
- [ ] The check's scope matches `process-pr-review` step 5 exactly — no wider, no narrower.

## 4. Affected AGENTS.md invariants

- `## Key invariants` → `### Prompts and scaffolding` — "11. **Prompt changes pass
  `docs/prompt-standards.md`** — all 12 checklist items, for any skill, command, agent
  definition, hook message, or scaffolded template."
- `## Key invariants` → `### Packaging` — "12. **A plugin change requires a version bump.**"

## 5. Inherited conditions

From the parked `todos.md` row "**Finding A — a route from a fixed finding to the ledger for
projects that never open PRs.**":

| Condition | Disposition |
|---|---|
| Scope must match `process-pr-review` step 5 **exactly** — check every accepted actionable fixed finding, but invoke `harden-finding` only when a class matches or a new one is clearly warranted | **kept** — every approximating draft got this wrong |
| Cannot rest on same-session memory: a compaction, interruption or handoff loses the fixed-finding set and nothing detects the loss | **kept** |
| A durable handoff needs real design — identity, deduplication, consumption semantics | **kept**, and it is why this is a story rather than a mid-round addition |
| It mints `mandatory-step-anchored-to-optional-path` when it lands; minting earlier leaves a class no row uses | **kept** — the class is minted by the change that uses it, not before |
| Evidence: canvas has 51 Gate-A pass files and 0 ledger rows | **kept** as the motivating instance |
| Trigger: the next round that touches §5, or a project reporting an empty ledger across cycles | **moved** — fired by the 2026-08-03 round, recorded here |

## 6. Open questions

- What has to be true for a fixed finding to reach the ledger in a project that never opens a
  pull request?

## 7. Suggested size

`story` — one route, one spec → plan → PR.
```

- [ ] **Step 4: Write the §5 version stamp story**

Path: `docs/superpowers/stories/2026-08-04-section-5-version-stamp-story.md`

```markdown
# A §5 version stamp, so a scaffolded CLAUDE.md can tell it lags the plugin — Story

**Date:** 2026-08-04 · **Size:** story

**Unprofiled, deliberately** — a split from a designed round, so it bypassed
`dev-workflow:intake`. Acceptance criterion 1 carries the profile debt.

## 1. Problem statement

`/workflow-init` scaffolds CLAUDE.md §5 from an inline template. When the plugin's §5 changes,
every previously scaffolded copy silently lags, and nothing in the scaffolded file tells its
reader so. One known-stale instance exists and is being re-synced by hand.

## 2. Desired outcome

A reader of a scaffolded `CLAUDE.md` can tell whether its §5 matches the installed plugin's,
without comparing the two by hand.

## 3. Acceptance criteria

- [ ] Before design resumes on this story, whoever picks it up proposes both axes and the mode
      derived from them, pauses for Daniel's confirmation, and writes the confirmed profile into
      this header. Design continues only after that.
- [ ] A scaffolded `CLAUDE.md` whose §5 lags the installed plugin is detectable as such.
- [ ] Re-running `/workflow-init` on a stale file behaves per invariant 9 — it does not silently
      overwrite accumulated content.
- [ ] Whatever binding the design chooses holds on every push path, not only on pull requests.

## 4. Affected AGENTS.md invariants

- `## Key invariants` → `### Prompts and scaffolding` — "8. **`/workflow-init`'s templates stay
  inline** in the command body. Claude Code does not expand `${CLAUDE_PLUGIN_ROOT}` inside
  command markdown (verified), and the cache path is not an API."
- `## Key invariants` → `### Prompts and scaffolding` — "9. **`/workflow-init` never overwrites
  silently.**"
- `## Key invariants` → `### Packaging` — "12. **A plugin change requires a version bump.**"

## 5. Inherited conditions

From the parked `todos.md` row "**Finding B — a §5 version stamp, so a scaffolded CLAUDE.md can
tell it lags the installed plugin.**":

| Condition | Disposition |
|---|---|
| A semantic §5 locator is needed — `/workflow-init` may append the section renumbered, so "no §5 heading" can misread a valid section and append a duplicate | **kept** |
| Per-state merge semantics: invariant 9 forbids a silent overwrite, and "re-run init to sync" promises what the command cannot give | **kept** |
| Stamp cardinality: absent, duplicate, malformed | **kept** |
| The binding must be real on **every** push path; the version-bump coupling first proposed was false, since invariant 12's checker is `pull_request`-only | **kept** — the false coupling is recorded so it is not re-proposed |
| A stamp is a **wire format**: shipping a provisional one writes legacy into every scaffolded file | **kept** — it is why a provisional stamp is not acceptable |
| The one known-stale instance is being re-synced by hand, so this carries no schedule pressure | **kept** — the work is not urgent |
| Trigger: the next round that touches the §5 template | **moved** — fired by the 2026-08-03 round, recorded here |

## 6. Open questions

- How can a scaffolded `CLAUDE.md` tell its reader that it lags the installed plugin?

## 7. Suggested size

`story` — one stamp format and its detection, one spec → plan → PR. It is not a chore: a wire
format shipped provisionally cannot be taken back.
```

- [ ] **Step 5: Verify all three are unprofiled and carry their criterion and inventory**

```bash
cd "$(git rev-parse --show-toplevel)"
for p in docs/superpowers/stories/2026-08-04-hardening-ledger-supersession-story.md \
         docs/superpowers/stories/2026-08-04-ledger-route-without-pull-requests-story.md \
         docs/superpowers/stories/2026-08-04-section-5-version-stamp-story.md ; do
  prof=$(grep -c '^\*\*Risk:\*\*\|^\*\*Security:\*\*\|^\*\*Validation:\*\*' "$p")
  crit=$(tr '\n' ' ' < "$p" | tr -s ' ' | grep -c 'proposes both axes and the mode derived from them')
  inv=$(grep -c '^## 5. Inherited conditions' "$p")
  printf '%-70s profile=%s criterion=%s inventory=%s\n' "$(basename "$p")" "$prof" "$crit" "$inv"
done
```

Expected: every row `profile=0 criterion=1 inventory=1`.

- [ ] **Step 6: Commit**

```bash
git add docs/superpowers/stories/2026-08-04-hardening-ledger-supersession-story.md \
        docs/superpowers/stories/2026-08-04-ledger-route-without-pull-requests-story.md \
        docs/superpowers/stories/2026-08-04-section-5-version-stamp-story.md
git commit -m "WIP: three split stories for the fired triggers"
```

---

### Task 6: `todos.md` updates

**Files:**
- Modify: `todos.md` (one new row, five existing rows)

**Interfaces:**
- Consumes: the four story paths from Tasks 4–5.
- Produces: the parked C4/C5 row that ledger row B's `ref` cross-references (Task 7).

- [ ] **Step 1: Add the parked C4/C5 compliance row**

Add under `### Parked (trigger-gated)`:

```markdown
- [ ] **The gate-claims Don't is correct and was not followed, twice.** PR #21's C4 (an
      unqualified jq-parity criterion that outran what `field()` compares for a malformed outer
      document) and C5 (a README claim that a typo cannot quietly unhook a gate) both fall
      inside the 2026-07-19 `AGENTS.md` Don't, whose operative instruction already requires
      exactly what they omitted — name the exact comparison the code performs, and delete any
      part of the sentence that outruns it. **No textual repair exists**, which is why these are
      parked rather than logged: a ledger row would have to name a hardening, and the rule
      needing no change means the failure was compliance, not wording. The 2026-08-04 amendment
      covers coverage enumerations (F8's shape) and reaches neither a positive parity claim nor
      a positive prevention claim. *Trigger: a third compliance miss against that Don't, or a
      feasible mechanical rung emerging from
      `docs/superpowers/stories/2026-08-04-harden-finding-guard-scope-precheck-story.md`.*
```

- [ ] **Step 2: Record evidence case 3 on the scope-blind row**

In the row `**`harden-finding`'s recurrence rule is scope-blind.**`, append before its `*Trigger:*` sentence:

```
      **Evidence case 3 (2026-08-04):** the 2026-08-03 hardening round ran the precheck as a
      standing manual instruction from Daniel — which is this row's own diagnosis, since a rule
      that exists only in chat is not one the skill carries — and still reached a wrong verdict
      twice by reading a single prior row's guard and stopping. Split to
      `docs/superpowers/stories/2026-08-04-harden-finding-guard-scope-precheck-story.md`; this
      row stays open because the fix it sketches has not landed.
```

- [ ] **Step 3: Mark Finding A's row fired**

In the row `**Finding A — a route from a fixed finding to the ledger for projects that never open PRs.**`, append:

```
      **TRIGGER FIRED (2026-08-04):** the 2026-08-03 hardening round edits §5. Story:
      `docs/superpowers/stories/2026-08-04-ledger-route-without-pull-requests-story.md`, which
      carries this row's conditions with each marked kept, moved or dropped.
```

- [ ] **Step 4: Mark Finding B's row fired**

In the row `**Finding B — a §5 version stamp, so a scaffolded CLAUDE.md can tell it lags the installed plugin.**`, append:

```
      **TRIGGER FIRED (2026-08-04):** the 2026-08-03 hardening round edits the §5 inline
      template. Story:
      `docs/superpowers/stories/2026-08-04-section-5-version-stamp-story.md`, which carries this
      row's conditions with each marked kept, moved or dropped.
```

- [ ] **Step 5: Mark the ledger-supersession row fired**

In the row `**The hardening ledger has no supersession convention.**`, append:

```
      **TRIGGER FIRED (2026-08-04):** the 2026-07-20 row now teaches pre-0.8.0 counting
      behaviour as current — the second falsified row this trigger names. Story:
      `docs/superpowers/stories/2026-08-04-hardening-ledger-supersession-story.md`.
```

- [ ] **Step 6: Record that the slot-collision row did NOT fire**

In the row `**Each Gate cycle destroys the previous cycle's review record.**`, append:

```
      **NOT FIRED (2026-08-04):** the 2026-08-03 hardening round edits §5 prose and its template
      mirror, and changes no part of the §5 **file protocol** this row's trigger names — not the
      slot names, not the pre-call delete, not the terminator or acceptance rules. Recorded so a
      later reader can check the reading rather than re-derive it.
```

- [ ] **Step 7: Append the env-var observation, leaving the row open**

In the row `**`/workflow-init` preflight checks `CLAUDE_CODE_MCP_AUTO_BACKGROUND_MS`.**`, append:

```
      **OBSERVATION (2026-08-04), and the row stays open.** With the variable set to `0`, five
      Gate-A passes of the 2026-08-03 round ran 458 s, 550 s, 757 s, 663 s and 780 s; all five
      stayed in the foreground and returned ordinary `success: true` envelopes the hook could
      read. **No control run was made** with the variable unset, so this is a correlation
      observed under one setting, not a demonstration that the variable held those calls in the
      foreground. What it does establish is that calls well past 120 s can return as ordinary
      foreground results here. The row's deliverable — a `/workflow-init` preflight check — is
      unbuilt, so the row is not discharged by this.
```

- [ ] **Step 8: Verify every story path referenced exists**

```bash
cd "$(git rev-parse --show-toplevel)"
grep -o 'docs/superpowers/stories/2026-08-04-[a-z0-9-]*\.md' todos.md | sort -u | while read -r p; do
  [ -e "$p" ] && echo "OK   $p" || echo "MISS $p"
done
```

Expected: four `OK` lines, no `MISS`. A `todos.md` pointing at a story that does not exist is the docs-drift class this round hardens.

- [ ] **Step 9: Run the battery**

Expected: exit 0.

- [ ] **Step 10: Commit**

```bash
git add todos.md
git commit -m "WIP: park the compliance recurrence and record the fired triggers"
```

---

### Task 7: The four ledger rows

**Files:**
- Modify: `docs/hardening-log.md` (append four rows)

**Interfaces:**
- Consumes: the three §5 sentences (Task 1), the `AGENTS.md` amendment (Task 2), the taxonomy class (Task 3), the parked row (Task 6).
- Produces: nothing downstream.

Append in order A, B, C, D at the end of the table. Each row is one line — the newlines below are for readability in this plan only; **write each as a single line.**

- [ ] **Step 1: Re-read the log and check for a same-fingerprint row appearing meanwhile**

```bash
cd "$(git rev-parse --show-toplevel)"
for fp in docs-drift unverified-enforcement-claim verification-masks-failure mechanical-check-skipped-before-review; do
  printf '%-42s ' "$fp"
  grep -cE "^\| *[0-9-]{10} *\| *$fp *\|" docs/hardening-log.md
done
```

Expected: `docs-drift 5`, `unverified-enforcement-claim 5`, `verification-masks-failure 1`, `mechanical-check-skipped-before-review 0`. If any count is higher, a row appeared since this plan was written: **stop and surface**, naming the row. Do not append. Resolving a mid-run collision is the split story's subject (Task 4), and inventing the procedure here would re-import what was split out.

- [ ] **Step 2: Append row A**

```
| 2026-08-04 | docs-drift | fifth occurrence: three statements the 0.8.0 diff falsified — AGENTS.md's prerequisites list omitting `dash` while the battery invokes it twice, a plan's "four script runs" for a block holding five, and a spec citing a hook line the same rewrite had moved — all found by a PR bot, none by the standing Gate-B lens | bot | major | P std | CLAUDE.md §5 Gate-B lens + the same block in the workflow-init inline template: the lens now asks what the diff changes the size, value or position of, and to grep for where each is described elsewhere. PRIOR ROW: 2026-07-27 docs-drift (P std), guard "which existing statements does this diff falsify?" — this finding is INSIDE that guard, so it is a regression repaired at the same rung, not an escalation: the lens was carried on the 0.8.0 cycle (the execution notes record it under "Standing lens, with unusual force") and missed all three. WHAT CHANGED AND WHY THE OLD FORM MISSED IT: the open question asks for recall; all three cases are a fact recorded elsewhere that the diff changed — a list's membership, a count, a position — and enumerating those needs a search. STILL INSTRUCTION-BACKED: nothing runs the grep or validates the answer, so this raises the floor and does not close the class |
```

- [ ] **Step 3: Append row B**

```
| 2026-08-04 | unverified-enforcement-claim | fifth occurrence: "It bounds the **scan**, not memory" named one uncovered axis and left the reader to infer the others were covered — the bound was a size bound, the work was quadratic in size, and the runtime it was read as bounding held only for the shapes that had been measured | gate-a | major | 1 prose | AGENTS.md Don't "Never describe what a gate proves without checking what it actually compares", closing rule extended: where a sentence says what a mechanism does NOT cover, name the axes it was checked against and state whether that list is exhaustive. PRIOR ROW: 2026-07-19 (1 prose), the same Don't, whose operative instruction covers "every sentence about a gate" — INSIDE it, so this is a regression, and the amendment closes a gap the comparison-focused wording left open. GUARD, exactly: the exhaustiveness statement. The motivating sentence names two axes and gives each a verdict, so a rule asking only for the axes checked would approve it; declaring the list exhaustive or not is what it never does. NOT LOGGED HERE: PR #21's C4 and C5 fall inside the same Don't but need nothing it does not already say, so no repair exists to name — they are parked in todos.md as a compliance recurrence with their own trigger. STILL INSTRUCTION-BACKED: no checker reads a coverage claim |
```

- [ ] **Step 4: Append row C**

```
| 2026-08-04 | verification-masks-failure | second occurrence, four cases in one cycle: a dry run that defined `$EVIDENCE` itself, proving the git mechanics and never that the plan defines the variable; a regression test that only ever ran under macOS `sh` while the defect it guards appears under `dash`; timed rows whose single-record fixtures never reach the record accumulator's quadratic path; and release evidence claiming `dash` coverage from a run that executed the harness under `dash` and the hook under `/bin/sh` | gate-b | major | P std | CLAUDE.md §5 Profiles counterfactual + the same block in the workflow-init inline template: name the observation that would exist if the claim were false, and confirm the wiring could have produced it. GUARD, exactly: the second half — a check that supplies its own input, runs where the defect cannot appear, or uses a fixture that never reaches the branch it covers. Each of the four cases fails on it. PRIOR ROW: 2026-07-20 (1 prose), whose ref states its own scope — "nothing checks new plans for the same shape" — so all four are OUTSIDE it and this is the fitting rung rather than an escalation on the count. RUNG P NOT 1: the artifact is a prompt; the rung follows the artifact, not the count. SOURCE: two gate-a cases and two gate-b, so the tie-break applies — the triggering case is the `dash` release evidence, which is gate-b. STILL INSTRUCTION-BACKED: nothing tests whether a check could have failed |
```

- [ ] **Step 5: Append row D**

```
| 2026-08-04 | mechanical-check-skipped-before-review | NEW CLASS, minted this change: eight read-only Gate-A passes over one plan missed eight defects that thirteen machine checks then found in a single sweep, including a rollback that would have byte-verified against the wrong hook | manual | major | P std | CLAUDE.md §5 Gate-A pass procedure + the same block in the workflow-init inline template: before each read pass, settle mechanically what the artifact asserts and a machine can decide without side effects — cited paths, quoted passages, stated counts, the syntax of standalone fenced blocks — inspecting quoted commands rather than running them, since a command quoted in a spec may be destructive or an intentional failure. Class added to docs/hardening-taxonomy.md in this same change, with its boundary against verification-masks-failure stated: there a check ran and could not fail; here the cheap check never ran at all. NO PRIOR ROW — this is the first occurrence. STILL INSTRUCTION-BACKED: nothing runs the sweep, records that it ran, or checks what it settled |
```

- [ ] **Step 6: Verify the rows are well-formed**

```bash
cd "$(git rev-parse --show-toplevel)"
echo "--- new rows are single lines with 7 fields ---"
tail -4 docs/hardening-log.md | awk -F'|' '{print NR": fields="NF-2}'
echo "--- fingerprint counts after append ---"
for fp in docs-drift unverified-enforcement-claim verification-masks-failure mechanical-check-skipped-before-review; do
  printf '%-42s ' "$fp"; grep -cE "^\| *[0-9-]{10} *\| *$fp *\|" docs/hardening-log.md
done
echo "--- no unescaped pipes inside fields (each row must have exactly 8 pipes) ---"
tail -4 docs/hardening-log.md | awk '{n=gsub(/\|/,"|"); print NR": pipes="n}'
```

Expected: `fields=7` for each of the four; counts `6 / 6 / 2 / 1`; `pipes=8` for each row.

- [ ] **Step 7: Run the battery**

Expected: exit 0. Note `check-invariants.sh` excludes `docs/hardening-log.md` from checks 4a/4b — a ledger that quotes defects would otherwise self-reject.

- [ ] **Step 8: Commit**

```bash
git add docs/hardening-log.md
git commit -m "WIP: four ledger rows for the 0.8.0 and PR #21 hardenings"
```

---

### Task 8: Version bump and CHANGELOG

**Files:**
- Modify: `plugins/dev-workflow/.claude-plugin/plugin.json:4`
- Modify: `plugins/dev-workflow/CHANGELOG.md` (new `## 0.8.1` section, directly under the intro, above `## 0.8.0`)

**Interfaces:**
- Consumes: everything above (the CHANGELOG describes it).
- Produces: nothing downstream.

- [ ] **Step 1: Bump the manifest**

In `plugins/dev-workflow/.claude-plugin/plugin.json`, change `"version": "0.8.0",` to `"version": "0.8.1",`.

- [ ] **Step 2: Add the CHANGELOG entry**

Insert immediately above `## 0.8.0`:

```markdown
## 0.8.1

- **Three sentences added to the §5 gate protocol, and to the template `/workflow-init`
  scaffolds.** The Gate-B standing lens now asks what a diff changes the size, value or position
  of, and to grep for where each is described elsewhere — asked as an open question alone it
  missed three such statements in one cycle while being carried with unusual force. The Profiles
  counterfactual now asks for both halves: name the observation that would exist if the claim
  were false, and confirm the wiring could have produced it. The Gate-A pass procedure now asks
  for a mechanical sweep before each read pass, inspecting quoted commands rather than running
  them, since a command quoted in a spec may be destructive.
- **None of the three is a check.** Nothing runs the grep, tests whether a check could have
  failed, or records that a sweep happened. They sharpen questions a reader asks; the ledger
  rows say so rather than implying otherwise.
- **No skill changed.** The `harden-finding` guard-scope precheck — the change this round set out
  to make — turned out to need decisions about durable records, ledger format and mid-run
  collisions that a rule paragraph cannot carry. It is split to its own story.
```

- [ ] **Step 3: Verify the bump is detected**

```bash
cd "$(git rev-parse --show-toplevel)"
grep -n '"version"' plugins/dev-workflow/.claude-plugin/plugin.json
grep -n '^## 0\.8\.1' plugins/dev-workflow/CHANGELOG.md
```

Expected: version `0.8.1`, and one `## 0.8.1` heading.

- [ ] **Step 4: Run the battery**

Expected: exit 0. `check-version-bump.sh main` compares commits, so run it once this task is committed — on `main` the merge-base is HEAD and it passes trivially; CI runs it against the PR's base.

- [ ] **Step 5: Commit**

```bash
git add plugins/dev-workflow/.claude-plugin/plugin.json plugins/dev-workflow/CHANGELOG.md
git commit -m "WIP: bump to 0.8.1 with its changelog entry"
```

---

### Task 9: Validation evidence and the Gate-B cycle

**Files:**
- No new files. This task produces the evidence entry that the cycle-closing commit body carries.

**Interfaces:**
- Consumes: every prior task.
- Produces: the final commit.

- [ ] **Step 1: Squash the WIP commits into one snapshot**

```bash
cd "$(git rev-parse --show-toplevel)"
FIRST_WIP=$(git log --format='%H %s' | awk '/WIP: three §5 sentences/{print $1}')
git reset --soft "$FIRST_WIP"^
git commit -m "WIP: hardening round — the 0.8.0 cycle and PR #21"
git log --oneline -3
```

`git commit` and `git add` must be **separate** calls throughout: the hook derives its docs-only file list at `PreToolUse`, so a compound `git add && git commit` presents an empty index and fires a spurious Gate-B STOP.

- [ ] **Step 2: Run the full battery and capture the real numbers**

Run the quality command from Global Constraints. Record the actual counts it prints — shellcheck files, hook suite assertions under both `sh` and `dash`, invariant assertions, version-bump assertions, `claude plugin validate` result. Do not write a number you did not read from output.

- [ ] **Step 3: Run the named verification**

Apply §5.2's sentence, exactly as it now reads in `CLAUDE.md`, to the four cases in spec §10. Each must **fail** on the second half. Then apply §5.4's appended clause to `It bounds the **scan**, not memory` — it must fail on the exhaustiveness requirement.

Record the result per case. If any case passes the sentence written to reject it, that sentence is miswired: **stop and surface**, do not proceed to Gate B.

- [ ] **Step 4: Run the prompt-conformance reviews**

`plugins/dev-workflow/commands/workflow-init.md` is the only changed file inside invariant 11's enumerated surface. Review it against all 12 items of `docs/prompt-standards.md`; all 12 must pass, with an exception only where the checklist item itself authorizes one (items 9 and 12 do), recorded with that item's stated reason.

`CLAUDE.md` and `AGENTS.md` are not on that list — neither carries a `Target model:` line, because neither is executed against a named model. Review their edits against items 6, 7, 8, 9, 11 and 12 and record the result. §5.4's clause is a continuation of an existing prohibition; item 9's own text exempts rules whose subject is the prohibition, so cite that exemption rather than assuming it.

Give each of the four split stories a recorded in-spirit brief review — success criteria, stop conditions, verified claims — without asserting the mandatory 12 apply.

- [ ] **Step 5: Run the cross-finding conflict check**

Confirm no two findings pull one artifact in opposite directions. Expected verdict: none — the four hardenings touch four distinct sites (the Gate-B lens paragraph, the Profiles counterfactual paragraph, the Gate-A pass bullet, and the 2026-07-19 Don't), and none rewrites text another needs. If a conflict appears, **stop and surface** rather than choosing.

- [ ] **Step 6: Run Gate B**

Per CLAUDE.md §5. Tool: `mcp__codex__review`, `reviewType: full`, `baseSha` = the parent of the WIP commit. Delete both branch files first and confirm they are gone. Carry the story path and the evidence entry verbatim in `additionalContext`, plus the standing lens.

Minimum three passes, final pass clean. Re-review after every fix — a fix changes the diff. Every pass writes to `.context/codex-reviews/gate-b-<spec|quality>-pass-<p>.md` and is validated before it is read: terminator exact, count matching, nothing but finding lines, both branch files present.

- [ ] **Step 7: Close the cycle by amend**

```bash
cd "$(git rev-parse --show-toplevel)"
git commit --amend -F /path/to/final-message.txt
git log --oneline -1
```

The closing message carries the validated evidence entry — battery result, the check and its counterfactual — and the story path. The amend replaces the WIP message wholesale, so an entry written only into the WIP body is destroyed exactly when the cycle closes.

- [ ] **Step 8: Open the PR**

```bash
git push -u origin HEAD
gh pr create --title "Harden four classes from the 0.8.0 cycle and PR #21" --body-file /path/to/pr-body.md
```

Then run `/dev-workflow:process-pr-review` once the bots report.

---

## Self-Review

**Spec coverage.** §5.1 → Task 1 Step 1. §5.2 → Task 1 Step 2. §5.3 → Task 1 Step 3. §5.4 → Task 2. §6 rows A–D → Task 7. §6.4 collision behaviour → Task 7 Step 1. §6.5 class → Task 3. §8 four stories → Tasks 4–5, with paths and the pre-write check. §9 deliverables → Task 6 (todos), Task 8 (version, CHANGELOG), Task 3 (taxonomy). §10 validation → Task 9. Decision D7 (no skill file) → Global Constraints and Task 3 Step 2.

**Placeholder scan.** No `TBD`, no "add appropriate handling", no "similar to Task N". Every ledger row, story and CHANGELOG entry is written out in full.

**Type consistency.** The fingerprint string `mechanical-check-skipped-before-review` is identical in Task 3 (minting), Task 7 Steps 1, 5 and 6 (rows and verification). The four story paths are identical in Tasks 4, 5, 6 and their verification steps. The three §5 sentence openings used in Task 1's parity checks match the sentences inserted in Steps 1–3 verbatim.

**One gap found and closed during review:** Task 7's collision check originally ran after appending. It now runs first — appending and then discovering a collision would mean editing the ledger, which the append-only rule forbids.
