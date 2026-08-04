# Hardening round — the 0.8.0 cycle and PR #21 — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Land four hardenings from the 0.8.0 cycle and PR #21 as text, record them in four ledger rows, park what has no repair, and open four split stories — without changing any skill file.

**Architecture:** Three one-sentence additions to `CLAUDE.md` §5, each mirrored into the inline template in `plugins/dev-workflow/commands/workflow-init.md`; one clause appended to an existing `AGENTS.md` Don't; one new taxonomy class; four appended ledger rows; seven `todos.md` row changes; four new story files. No executable code changes.

**Tech Stack:** Markdown prompts. The quality battery in `AGENTS.md § Commands` is the test cycle — there is no unit test for prose.

**Spec:** `docs/superpowers/specs/2026-08-03-hardening-round-0-8-0-and-pr-21-design.md` (`b9111a2`).

**Story:** `docs/superpowers/stories/2026-08-03-hardening-round-0-8-0-and-pr-21-story.md` — read its profile header fresh at every Gate-B pass.

## How verification works in this plan

Most steps end in a **must-be-true** line rather than a shell block. That is deliberate. The
artifacts here are prose, the battery already checks what a machine can check, and Gate B
reviews the diff that actually resulted — a bespoke verification script per step is a second
implementation that needs its own review, and in this plan's own history that scaffolding
produced more defects than it caught.

**Four executable checks** are kept, because each is load-bearing and simple enough to read at
a glance: the **branch preflight**, the **battery**, the **ledger precondition**, and the
**`<fill` guard**. Each is self-contained — it defines every variable it uses, because agentic
workers run each fenced block in a fresh shell — and each exits nonzero when it fails.

**One recorded reading** sits beside them: the §5.2 and §5.4 **self-tests**. Applying a prompt
sentence to a case is a judgement, not a computation, so there is no failing oracle to run —
the executor reads, decides, and records the verdict. Calling it a fifth executable check would
be an enforcement claim with no mechanism behind it, which is the class this round hardens.

**The closing procedure is not restated here.** `CLAUDE.md` §5 governs the WIP commit, the
squash, the Gate-B loop, the amend and the close — including its requirement that **every fix
is amended into the WIP commit before the next review call**, since `mcp__codex__review` reads
a git range and a staged-but-uncommitted fix is not in it. That step is named because a draft
of this plan restated the protocol and dropped exactly it; naming a step is not re-specifying
a procedure, and every restatement is a copy that can drift.

## Deliverables checklist

- [ ] **A feature branch**, created before any edit (Task 0)
- [ ] **Three §5 sentences** — Gate-B lens, Profiles counterfactual, Gate-A pass procedure (Task 1)
- [ ] **Three template mirrors** in `workflow-init.md` (Task 1)
- [ ] **Version 0.8.1** in the manifest, with the first plugin change (Task 1)
- [ ] **One `AGENTS.md` Don't amendment** (Task 2)
- [ ] **One taxonomy class** — `mechanical-check-skipped-before-review` (Task 3)
- [ ] **Four split stories**, unprofiled, six `##` sections each (Tasks 4–5)
- [ ] **Seven `todos.md` row changes** — one new, six updated (Task 6)
- [ ] **Four ledger rows** — A, B, C, D (Task 7)
- [ ] **A `## 0.8.1` CHANGELOG entry** (Task 8)
- [ ] **Validation evidence** in `.context/evidence-0.8.1.md`, folded into the closing commit (Task 9)

## Global Constraints

- **Each §5 edit is one sentence at the exact existing site** (spec D5).
- **`CLAUDE.md` and `workflow-init.md` change in the same commit**, and their inserted sentences must be **equivalent under whitespace normalization** — identical word sequences, with only wrapping and indentation differing. Byte identity is not the requirement.
- **No skill file is edited** (spec D7). If a step seems to need one, stop and surface.
- **POSIX `sh` only** (invariant 4). No `<(...)`, `[[ ]]`, arrays, `${var:offset:length}`, `local`. `sh -n` is a *parse* check: `${var:0:3}` passes it and fails at runtime under `dash`. Test new snippets with `dash -c`.
- **`grep -c` counts matching *lines* and exits 1 on zero.** Flattening a file with `tr '\n' ' '` and then counting makes every result 0 or 1, so it cannot detect duplicates. Count occurrences with `grep -o ... | grep -c .`.
- **Version is `0.8.1`**, committed in Task 1 with the first `plugins/` change.
- **The ledger is append-only.** Never edit an existing row. Escape a literal `|` as `\|`.
- **The four stories are unprofiled**, six `##` sections, profile-confirmation criterion first.
- **No `Co-Authored-By: Claude` or `Generated with` trailers.**
- **`git add` and `git commit` are always separate calls** — the gate hook derives its docs-only file list at `PreToolUse`, so a compound call presents an empty index and fires a spurious STOP.
- **Before every `git add`, confirm the index holds nothing unrelated**, and after staging confirm the staged set is exactly the task's paths.
- **Quality battery** (what CI runs), from `AGENTS.md § Commands`:

```
shellcheck --shell=sh plugins/dev-workflow/hooks/codex-gate.sh && shellcheck --shell=sh --exclude=SC2015 plugins/dev-workflow/hooks/codex-gate.test.sh && shellcheck --shell=sh scripts/check-invariants.sh && shellcheck --shell=sh --exclude=SC2015 scripts/check-invariants.test.sh && shellcheck --shell=sh scripts/check-version-bump.sh && shellcheck --shell=sh scripts/check-version-bump.test.sh && HOOK_SH=sh sh plugins/dev-workflow/hooks/codex-gate.test.sh && HOOK_SH=dash dash plugins/dev-workflow/hooks/codex-gate.test.sh && sh scripts/check-invariants.test.sh && sh scripts/check-invariants.sh && sh scripts/check-version-bump.test.sh && sh scripts/check-version-bump.sh main && claude plugin validate . --strict
```

- **`check-invariants.sh` scans the working tree, not the tracked set.** Move any untracked scratch directory aside first.
- **What the battery prints on success**, established by running it: `shellcheck` prints nothing; the hook suite prints `all passed` with **no** assertion total under each shell; `check-invariants.test.sh` and `check-version-bump.test.sh` print `all passed (N assertions)`; `check-invariants.sh` prints `invariant checks: ok`.

---

## Task 0: Preflight — branch, then conflict check

- [ ] **Step 1: Create the feature branch (KEPT CHECK)**

Nothing in this round may be committed on `main`. Invariant 12's checker runs on `pull_request` only, so work pushed straight to `main` bypasses the version-bump gate entirely.

```bash
cd "$(git rev-parse --show-toplevel)" || exit 1
want=harden-0-8-0-and-pr-21
default=main
dirty=$(git status --porcelain) || exit 1
[ -z "$dirty" ] || { printf 'tree or index not clean — stop:\n%s\n' "$dirty"; exit 1; }
branch=$(git rev-parse --abbrev-ref HEAD) || exit 1
if [ "$branch" = "$default" ]; then
  echo "on $default — creating $want"
  git checkout -b "$want" || exit 1
elif [ "$branch" = "$want" ]; then
  echo "already on $want — every commit ahead of $default:"
  git log --oneline "$default".."$want" || exit 1
  echo "STOP unless every subject above was created by this plan."
  echo "Any unrelated commit here would be folded into the squash and the PR."
else
  echo "on unexpected branch '$branch' — stop and surface"; exit 1
fi
now=$(git rev-parse --abbrev-ref HEAD) || exit 1
[ "$now" = "$want" ] || { echo "not on $want — stop"; exit 1; }
echo "branch OK: $now"
exit 0
```

Expected: `branch OK: harden-0-8-0-and-pr-21`, exit 0. **Every later push targets this branch**; no step pushes to `main`.

The clean-tree requirement comes first for a reason: a pre-existing edit in the working tree
would be swept into whichever task commits the same path, and neither the battery nor a Gate-B
reviewer reading the diff can tell that content apart from this round's. On a resumed run the
branch already exists, and the ahead-count is printed so the executor can confirm the range is
this plan's commits and nothing else before proceeding.

- [ ] **Step 2: Cross-finding conflict check**

The spec requires this before any edit. Four hardenings, four distinct sites:

| Hardening | Site |
|---|---|
| §5.1 lens sentence | `CLAUDE.md` §5 Gate-B paragraph opening `**Standing lens, every Gate-B call:` |
| §5.2 counterfactual sentence | `CLAUDE.md` §5 Profiles paragraph containing `Either route owes the` |
| §5.3 sweep sentence | `CLAUDE.md` §5 Gate-A bullet at `Each pass: validate, revise, re-run.` |
| §5.4 Don't clause | `AGENTS.md` Don't closing sentence `delete any part of the sentence that outruns it` |

Distinct anchors are necessary but not sufficient. **Also compare the four instructions pairwise for semantic conflict** — three of them amend one decision procedure (§5's gate protocol), so ask whether any pair asks a reviewer for contradictory or mutually weakening behaviour.

**Must be true:** no two hardenings pull one artifact in opposite directions, and no pair of instructions contradicts or weakens the other. Expected verdict: none — the lens asks what a diff changes elsewhere, the counterfactual asks whether a check could have failed, the sweep asks what a parser can settle, and the Don't governs coverage claims. If a conflict appears, **stop and surface** rather than choosing.

---

### Task 1: The three §5 sentences, their mirrors, and the version bump

**Files:** Modify `CLAUDE.md` (three sites), `plugins/dev-workflow/commands/workflow-init.md` (the same three sites in the inline template), `plugins/dev-workflow/.claude-plugin/plugin.json`.

**Produces:** the three sentences ledger rows A, C and D cite as their `ref` (Task 7).

**Anchors.** Line numbers locate the paragraph; **match on the quoted text** — a citation by line is the C3 defect this round hardens. In `CLAUDE.md`: ~247, ~342, ~224. In `workflow-init.md`: ~441, ~532, ~419.

- [ ] **Step 1: Append the lens sentence in `CLAUDE.md`**

At the end of the paragraph opening `**Standing lens, every Gate-B call: "which existing statements does this diff falsify?"**`, after the sentence ending `plus two user-facing docs teaching a rule the same change had just narrowed.`:

```
  **Name what this diff changes the size, value or position of** — a list, a count, a
  version, an identifier, a cited line — and grep for where each is described elsewhere,
  because asked as an open question alone this lens missed three such statements in one
  cycle while being carried with unusual force.
```

Match the surrounding two-space sub-bullet indentation.

- [ ] **Step 2: Append the counterfactual sentence in `CLAUDE.md`**

In the paragraph containing `Either route owes the **counterfactual**: the observation against the prior state.`, after the sentence ending `A fabricated test satisfies nothing.`:

```
**Name the observation that would exist if the claim were false, and confirm the wiring could
have produced it** — a check that supplies its own input, runs where the defect cannot appear,
or uses a fixture that never reaches the branch it covers reports success because of how it was
wired, not because the thing it checks succeeded.
```

- [ ] **Step 3: Add the Gate-A sweep sentence in `CLAUDE.md`**

Immediately after `Each pass: validate, revise, re-run.` and before the parenthetical `(Large/high-risk artifact: …`:

```
Before each read pass, settle mechanically what the artifact asserts and a machine can decide
without side effects — cited paths, quoted passages, stated counts, the syntax of standalone
fenced blocks — inspecting quoted commands rather than running them, since a command quoted in
a spec may be destructive or an intentional failure.
```

- [ ] **Step 4: Mirror all three into `workflow-init.md`**

Apply Steps 1–3 at the three corresponding sites in the inline template.

**Must be true:** each of the three sentences appears **exactly once** in `CLAUDE.md` and **exactly once** in `workflow-init.md`, with the same word sequence in both, under the corresponding heading in each. Wrapping and indentation may differ; wording may not. A sentence landing in one copy only is the shipped-template drift this repo treats as load-bearing, and it is visible in the diff Gate B reads.

- [ ] **Step 5: Bump the manifest**

Change `"version": "0.8.0",` to `"version": "0.8.1",` in `plugins/dev-workflow/.claude-plugin/plugin.json`. It lands here because `check-version-bump.sh` fails a pull request that changes a `plugins/` path without a bump.

**Must be true:** the manifest reads `0.8.1`.

**What the battery's version-bump component does and does not observe here.** `check-version-bump.sh` compares *commits*. Run at Step 6 — before this task commits — it sees a range containing neither the plugin edit nor the bump, so its result is **vacuous**, not evidence. The first meaningful observation is the next battery run, at Task 2 Step 3, once Step 7's commit exists. On `main` it would be vacuous always, since the merge-base is HEAD; that is one reason Task 0 moves off `main` first.

- [ ] **Step 6: Run the battery (KEPT CHECK)**

Run the quality command from Global Constraints. Expected: exit 0.

- [ ] **Step 7: Commit**

```bash
git add CLAUDE.md plugins/dev-workflow/commands/workflow-init.md plugins/dev-workflow/.claude-plugin/plugin.json
```

```bash
git commit -m "WIP: three §5 sentences, their template mirrors, and the 0.8.1 bump"
```

Two separate calls. `WIP:` is deliberate — the hook treats a `wip`-prefixed message as cycle-internal, so it neither fires a Gate-B STOP nor resets the pass counters.

---

### Task 2: The `AGENTS.md` Don't amendment

**Files:** Modify `AGENTS.md` (the 2026-07-19 Don't, closing sentence around line 218).

**Produces:** the rule ledger row B cites as its `ref`.

- [ ] **Step 1: Extend the closing sentence**

Inside `**Never describe what a gate proves without checking what it actually compares.**`, the closing sentence currently ends `and delete any part of the sentence that outruns it.` Extend it:

```
  underlying rule is the check itself: for every sentence about a gate, name the exact
  comparison the code performs, and delete any part of the sentence that outruns it — and
  where the sentence says what the mechanism does *not* cover, name the axes it was checked
  against and state whether that list is exhaustive, because an enumeration read as complete
  guarantees the axes it omits.
```

- [ ] **Step 2: Verify the amendment rejects its own motivating case (KEPT CHECK — read, not shell)**

Apply the amended sentence to `It bounds the **scan**, not memory`:

- Names the axes checked? Yes — scan and memory.
- States whether that list is exhaustive? **No.**
- Therefore it **fails** the amended rule. ✔

If it passes, the wording is wrong — a rule asking only for the axes checked would approve the very sentence this amendment exists to reject. **Stop and surface.**

**Must be true:** `AGENTS.md` holds exactly one operative copy of that closing rule. The spec and this plan quote the phrase; those are quotations, not copies, and need no amendment.

- [ ] **Step 3: Run the battery.** Expected: exit 0.

- [ ] **Step 4: Commit**

```bash
git add AGENTS.md
```

```bash
git commit -m "WIP: extend the gate-claims Don't to coverage enumerations"
```

---

### Task 3: The taxonomy class

**Files:** Modify `docs/hardening-taxonomy.md`.

**Produces:** the fingerprint `mechanical-check-skipped-before-review`, used by ledger row D.

- [ ] **Step 1: Add the class**

As the last entry under `## Classes`, immediately before the `**Promotion candidate.**` paragraph:

```markdown
- `mechanical-check-skipped-before-review` — an artifact carrying machine-checkable assertions
  goes to an expensive read pass before anything parses it, so attention is spent on what a
  tool decides in seconds. Aliases: `sh -n` after the fact, the parser would have caught it,
  read pass before the sweep, manual review of machine-decidable claims.

  **Not `verification-masks-failure`.** There a check ran and could not fail; here the cheap
  check never ran at all. Grep this one when the sentence is "a parser would have found it
  immediately"; grep the other when it is "the check passed and proved nothing".
```

**Must be true:** the class appears in `docs/hardening-taxonomy.md` and **nowhere in `plugins/dev-workflow/skills/harden-finding/SKILL.md`** — invariant 10 keeps project classes out of the shipped skill. The class is stack-neutral and lands in the project file anyway, because the skill instructs minting there and that file's own `**Promotion candidate.**` note records the same of several existing classes.

- [ ] **Step 2: Run the battery.** Expected: exit 0.

- [ ] **Step 3: Commit**

```bash
git add docs/hardening-taxonomy.md
```

```bash
git commit -m "WIP: mint mechanical-check-skipped-before-review"
```

---

### Task 4: The `harden-finding` precheck split story

**Files:** Create `docs/superpowers/stories/2026-08-04-harden-finding-guard-scope-precheck-story.md`.

**Before writing, classify the path.** A **symlink** at the target is an unconditional stop — never a reuse candidate, even if its target holds identical text, because `git add` would stage a link rather than the story bytes. A **directory** is a stop. An existing **regular file** with byte-identical content is a reuse; with different content it is a stop, per invariant 9. Only an absent path is written.

**Create it with an operation that fails if the path appeared meanwhile**, which the spec
requires: write the content to a temporary file in the same directory, `ln` it into place —
`ln` fails when the target exists — then remove the temporary name. A plain redirect would
truncate a file another session created between the classification and the write, and that
clobber is invisible in the final diff: nothing distinguishes "we wrote this" from "we
overwrote someone else's".

**Remove the temporary file on every exit path**, success and failure alike. A successful `ln`
leaves a second untracked copy of the story, and a collision stop leaves scratch content — both
are picked up by `check-invariants.sh`, which scans the working tree rather than the tracked
set, and both break the clean-tree preconditions later steps rely on. A `trap 'rm -f "$tmp"' EXIT`
set immediately after the temporary name is allocated covers both.

**Resume semantics.** If the file is already present and byte-identical, the deliverable is
done: **skip the commit rather than creating an empty one.** The closing squash folds whatever
commits exist; it does not require a fixed count.

- [ ] **Step 1: Write the story**

```markdown
# `harden-finding`'s recurrence rule is scope-blind — Story

**Date:** 2026-08-04 · **Size:** story

**Unprofiled, deliberately.** This story is a split from a designed round, not a raw idea, so
it did not pass through `dev-workflow:intake` — intake excludes items that have moved into
solution design. A profile is proposed and human-confirmed at intake time. Writing one here
would produce a header that **looks** confirmed and is not, and nothing would reveal that:
`CLAUDE.md` §5 stops on a profile that is malformed or internally inconsistent, not on one
whose values are well-formed but unconfirmed. That is why the debt is carried as acceptance
criterion 1 rather than by fabricating a header.

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

- `## Key invariants` → `### Prompts and scaffolding` — "10. **The base taxonomy stays
  stack-neutral.** Project vocabulary — tables, auth helpers, framework APIs — goes only in
  that project's `docs/hardening-taxonomy.md`, never into the `harden-finding` skill. Otherwise
  one project leaks into every other."
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

`story` — one skill file, one decision procedure, one spec → plan → PR. Above a chore because
the six questions above are real design; below an epic because they all concern one procedure
in one file.
```

**Must be true:** the file exists as a regular file at that exact path, carries no
`**Risk:**`/`**Security:**`/`**Validation:**` line, has exactly six `##` sections, and its
**first** acceptance criterion is the profile-confirmation one.

- [ ] **Step 2: Commit**

```bash
git add docs/superpowers/stories/2026-08-04-harden-finding-guard-scope-precheck-story.md
```

```bash
git commit -m "WIP: split story for the harden-finding guard-scope precheck"
```

---

### Task 5: The three trigger stories

**Files:** Create the three paths below.

Each replaces a parked `todos.md` row carrying settled analysis, so each holds an inheritance
inventory marking every condition of its source row **kept, moved, or deliberately dropped** —
`AGENTS.md`'s "Never replace a decision procedure without accounting for its old conditions"
applies to that replacement. The inventory is a `###` subsection of §1, so the story keeps
exactly six `##` sections.

**Classify each path immediately before writing it**, by Task 4's rule: symlink or directory →
stop; regular file with identical bytes → reuse and skip the commit; regular file with different
bytes → stop; absent → create with the same fail-if-it-appeared operation Task 4 describes. A
single classification of all three up front is stale by construction for the second and third.

- [ ] **Step 1: `docs/superpowers/stories/2026-08-04-hardening-ledger-supersession-story.md`**

```markdown
# The hardening ledger has no supersession convention — Story

**Date:** 2026-08-04 · **Size:** story

**Unprofiled, deliberately** — a split from a designed round, so it bypassed
`dev-workflow:intake`, which excludes work already in solution design. A profile written now
would look confirmed without being confirmed, and nothing would reveal that; acceptance
criterion 1 carries the debt instead.

## 1. Problem statement

`docs/hardening-log.md`'s header says never edit a row, and one row per hardening. When a row's
"what this does NOT do" narration is later falsified by a feature change, neither move is
sanctioned: editing breaks the first rule, appending breaks the second.

This is live. The 2026-07-20 row describes pre-0.8.0 counting behaviour as current, and a reader
who trusts it is misled about how the gate hook counts today. That is the second falsified row,
which is the condition the parked backlog row named as its trigger.

### Conditions inherited from the source row

From `todos.md`, "**The hardening ledger has no supersession convention.**":

| Condition | Disposition |
|---|---|
| Never edit a row | **kept** — any solution must preserve it |
| One row per hardening | **kept** — any solution must preserve it |
| The 2026-07-20 row now describes pre-0.8.0 behaviour as current | **kept** as the motivating instance |
| The 2026-07-20 *spec* took a version-qualified supersession note and it worked | **kept** as prior art the design should evaluate first |
| Alternative: an explicit "rows are historical, read the newest row for current behaviour" header statement | **kept** as a candidate |
| Trigger: the next row falsified by a later change — this is the second | **moved** — fired, and recorded here |

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

- `## Key invariants` → `### Prompts and scaffolding` — "8. **`/workflow-init`'s templates stay
  inline** in the command body."
- `## Key invariants` → `### Prompts and scaffolding` — "9. **`/workflow-init` never overwrites
  silently.** Idempotent: missing → write; identical → report unchanged; present and different →
  show the diff and ask; additive files (`.gitattributes`, `.mcp.json`, …) → merge."
- **Conditional, if the design reaches the scaffolded template** — "11. **Prompt changes pass
  `docs/prompt-standards.md`**" and "12. **A plugin change requires a version bump.**" Both bind
  only if the convention must reach `/workflow-init`'s inline ledger header, which is §5's open
  question.

## 5. Open questions

- Which artifacts must the convention reach before a reader can trust any row — this repo's
  ledger alone, or every ledger `/workflow-init` scaffolds? A repo-only fix ships a rule this
  kit's ledger obeys and every scaffolded one does not.

## 6. Suggested size

`story` — one file's header convention plus possibly one inline template, one spec → plan → PR.
```

- [ ] **Step 2: `docs/superpowers/stories/2026-08-04-ledger-route-without-pull-requests-story.md`**

```markdown
# A route from a fixed finding to the ledger, for projects that never open PRs — Story

**Date:** 2026-08-04 · **Size:** story

**Unprofiled, deliberately** — a split from a designed round, so it bypassed
`dev-workflow:intake`. A profile written now would look confirmed without being confirmed;
acceptance criterion 1 carries the debt instead.

## 1. Problem statement

The only mandated ledger check lives in `/dev-workflow:process-pr-review` step 5, so a project
that never opens a pull request never reaches it. One project has 51 Gate-A pass files and
**zero** ledger rows: findings were raised, validated and fixed, and none was ever considered
for hardening.

### Conditions inherited from the source row

From `todos.md`, "**Finding A — a route from a fixed finding to the ledger for projects that
never open PRs.**":

| Condition | Disposition |
|---|---|
| Scope must match `process-pr-review` step 5 **exactly** — check every accepted actionable fixed finding, but invoke `harden-finding` only when a class matches or a new one is clearly warranted | **kept** — every approximating draft got this wrong |
| Cannot rest on same-session memory: a compaction, interruption or handoff loses the fixed-finding set and nothing detects the loss | **kept** |
| A durable handoff needs real design — identity, deduplication, consumption semantics | **kept**, and it is why this is a story rather than a mid-round addition |
| It mints `mandatory-step-anchored-to-optional-path` when it lands; minting earlier leaves a class no row uses | **kept** — the class is minted by the change that uses it |
| Evidence: canvas has 51 Gate-A pass files and 0 ledger rows | **kept** as the motivating instance |
| Trigger, first alternative: the next round that touches §5 | **moved** — fired by the 2026-08-03 round, recorded here |
| Trigger, second alternative: a project reporting an empty ledger across cycles that fixed findings | **kept** — it did not fire, and it remains the condition that would raise this independently |

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

## 5. Open questions

- What has to be true for a fixed finding to reach the ledger in a project that never opens a
  pull request?

## 6. Suggested size

`story` — one route, one spec → plan → PR.
```

- [ ] **Step 3: `docs/superpowers/stories/2026-08-04-section-5-version-stamp-story.md`**

```markdown
# A §5 version stamp, so a scaffolded CLAUDE.md can tell it lags the plugin — Story

**Date:** 2026-08-04 · **Size:** story

**Unprofiled, deliberately** — a split from a designed round, so it bypassed
`dev-workflow:intake`. A profile written now would look confirmed without being confirmed;
acceptance criterion 1 carries the debt instead.

## 1. Problem statement

`/workflow-init` scaffolds `CLAUDE.md` §5 from an inline template. When the plugin's §5 changes,
every previously scaffolded copy silently lags, and nothing in the scaffolded file tells its
reader so. One known-stale instance exists and is being re-synced by hand.

### Conditions inherited from the source row

From `todos.md`, "**Finding B — a §5 version stamp, so a scaffolded CLAUDE.md can tell it lags
the installed plugin.**":

| Condition | Disposition |
|---|---|
| A semantic §5 locator is needed — `/workflow-init` may append the section renumbered, so "no §5 heading" can misread a valid section and append a duplicate | **kept** |
| Per-state merge semantics: invariant 9 forbids a silent overwrite, and "re-run init to sync" promises what the command cannot give | **kept** |
| Stamp cardinality: absent, duplicate, malformed | **kept** |
| The binding must be real on **every** push path; the version-bump coupling first proposed was false, since invariant 12's checker is `pull_request`-only | **kept** — the false coupling is recorded so it is not re-proposed |
| A stamp is a **wire format**: shipping a provisional one writes legacy into every scaffolded file | **kept** — it is why a provisional stamp is unacceptable |
| The one known-stale instance is being re-synced by hand, so this carries no schedule pressure | **kept** — the work is not urgent |
| Trigger: the next round that touches the §5 template | **moved** — fired by the 2026-08-03 round, recorded here |

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
- `## Key invariants` → `### Prompts and scaffolding` — "11. **Prompt changes pass
  `docs/prompt-standards.md`** — all 12 checklist items."
- `## Key invariants` → `### Packaging` — "12. **A plugin change requires a version bump.**"

## 5. Open questions

- How can a scaffolded `CLAUDE.md` tell its reader that it lags the installed plugin?

## 6. Suggested size

`story` — one stamp format and its detection, one spec → plan → PR. Not a chore: a wire format
shipped provisionally cannot be taken back.
```

**Must be true, for all three:** each exists as a regular file at its exact path, carries no
profile line, has exactly six `##` sections, has one `### Conditions inherited from the source
row` subsection, and has the profile-confirmation criterion first.

- [ ] **Step 4: Commit**

```bash
git add docs/superpowers/stories/2026-08-04-hardening-ledger-supersession-story.md docs/superpowers/stories/2026-08-04-ledger-route-without-pull-requests-story.md docs/superpowers/stories/2026-08-04-section-5-version-stamp-story.md
```

```bash
git commit -m "WIP: three split stories for the fired triggers"
```

---

### Task 6: `todos.md` — one new row, six existing rows

**Files:** Modify `todos.md`.

**Each mutation is idempotent, decided on the whole block.** Before applying one, check whether
its full text is already present: absent → apply; present and identical → skip and say so;
present but different, or present more than once → **stop and surface**. A marker substring
alone cannot tell an identical completed edit from a partial or independently edited one.

**Placement within each row is fixed, not left to judgement.** Every parked row ends with an
italic `*Trigger: …*` sentence. Steps 2–7 each insert their block **immediately before that
row's `*Trigger:*` sentence**, so the trigger stays last and a reader finds the status note
attached to the row's body rather than dangling after its trigger. Step 1 appends a whole new
row at the end of `### Parked (trigger-gated)`.

- [ ] **Step 1: Add the parked C4/C5 compliance row**

Under `### Parked (trigger-gated)`:

```markdown
- [ ] **The gate-claims Don't is correct and was not followed, twice.** PR #21's C4 (an
      unqualified jq-parity criterion that outran what `field()` compares for a malformed outer
      document) and C5 (a README claim that a typo cannot quietly unhook a gate) both fall
      inside the 2026-07-19 `AGENTS.md` Don't, whose operative instruction already requires
      exactly what they omitted — name the exact comparison the code performs, and delete any
      part of the sentence that outruns it. **No textual repair exists**, which is why these are
      parked rather than logged: a ledger row would have to name a hardening, and a rule needing
      no change means the failure was compliance, not wording. The 2026-08-04 amendment covers
      coverage enumerations (F8's shape) and reaches neither a positive parity claim nor a
      positive prevention claim. *Trigger: a third compliance miss against that Don't, or a
      feasible mechanical rung emerging from
      `docs/superpowers/stories/2026-08-04-harden-finding-guard-scope-precheck-story.md`.*
```

- [ ] **Step 2: Record evidence case 3 on the scope-blind row**

**First correct the row's premise, then append the evidence — both in this one change.** The row
currently says the scope-blind workaround "lives in ledger prose, which agents do not read — they
read the skill." That is false, and this round established it: `harden-finding` step 3 does say
to re-read the log. Appending evidence beneath a premise the same round disproved would leave the
backlog internally contradictory and point a future reader at the wrong diagnosis — `docs-drift`,
in the round that hardens it.

Replace that clause so the row reads that the skill's recurrence step *does* re-read the ledger,
and the defect is that its **decision branch** keys on the fingerprint and the latest row's rung
without letting that row's stated guard control the verdict.

Then, in the same row, before its `*Trigger:*` sentence:

```
      **Evidence case 3 (2026-08-04):** the 2026-08-03 hardening round ran the precheck as a
      standing manual instruction from Daniel — which is this row's own diagnosis, since a rule
      that exists only in chat is not one the skill carries — and still reached a wrong verdict
      twice by reading a single prior row's guard and stopping. Split to
      `docs/superpowers/stories/2026-08-04-harden-finding-guard-scope-precheck-story.md`; this
      row stays open because the fix it sketches has not landed.
```

- [ ] **Step 3: Mark Finding A's row fired**

```
      **TRIGGER FIRED (2026-08-04):** the 2026-08-03 hardening round edits §5. Story:
      `docs/superpowers/stories/2026-08-04-ledger-route-without-pull-requests-story.md`, which
      carries this row's conditions with each marked kept, moved or dropped.
```

- [ ] **Step 4: Mark Finding B's row fired**

```
      **TRIGGER FIRED (2026-08-04):** the 2026-08-03 hardening round edits the §5 inline
      template. Story:
      `docs/superpowers/stories/2026-08-04-section-5-version-stamp-story.md`, which carries this
      row's conditions with each marked kept, moved or dropped.
```

- [ ] **Step 5: Mark the ledger-supersession row fired**

```
      **TRIGGER FIRED (2026-08-04):** the 2026-07-20 row now teaches pre-0.8.0 counting
      behaviour as current — the second falsified row this trigger names. Story:
      `docs/superpowers/stories/2026-08-04-hardening-ledger-supersession-story.md`.
```

- [ ] **Step 6: Record that the slot-collision row did NOT fire**

In `**Each Gate cycle destroys the previous cycle's review record.**`:

```
      **NOT FIRED (2026-08-04):** the 2026-08-03 hardening round edits §5 prose and its template
      mirror, and changes no part of the §5 **file protocol** this row's trigger names — not the
      slot names, not the pre-call delete, not the terminator or acceptance rules. Recorded so a
      later reader can check the reading rather than re-derive it.
```

- [ ] **Step 7: Append the env-var observation, leaving the row open**

In `**`/workflow-init` preflight checks `CLAUDE_CODE_MCP_AUTO_BACKGROUND_MS`.**`:

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

**Must be true:** all seven changes are present, each exactly once; every
`docs/superpowers/stories/2026-08-04-*.md` path cited in `todos.md` exists as a regular file;
and there are exactly four such distinct paths. A `todos.md` pointing at a story that does not
exist is the docs-drift class this round hardens.

- [ ] **Step 8: Run the battery.** Expected: exit 0.

- [ ] **Step 9: Commit**

```bash
git add todos.md
```

```bash
git commit -m "WIP: park the compliance recurrence and record the fired triggers"
```

---

### Task 7: The four ledger rows

**Files:** Modify `docs/hardening-log.md`.

Append in order A, B, C, D at the end of the table. **Each row is one line** — the blocks below
are single lines this document wraps for display.

- [ ] **Step 1: Ledger precondition (KEPT CHECK)**

```bash
cd "$(git rev-parse --show-toplevel)" || exit 1
log=docs/hardening-log.md
[ -f "$log" ] || { echo "missing $log — stop"; exit 1; }
rc=0
set -- "docs-drift 5" "unverified-enforcement-claim 5" "verification-masks-failure 1" "mechanical-check-skipped-before-review 0"
for pair in "$@"; do
  fp=${pair% *}; want=${pair#* }
  got=$(grep -cE "^\| *[0-9-]{10} *\| *$fp *\|" "$log" || true)
  printf '%-42s got=%s want=%s\n' "$fp" "$got" "$want"
  if [ "$got" != "$want" ]; then
    rc=1
    grep -nE "^\| *[0-9-]{10} *\| *$fp *\|" "$log" | cut -c1-140
  fi
done
echo "ledger precondition exit=$rc"
exit "$rc"
```

Expected: four `got=N want=N` lines and `exit 0`.

**Any inequality stops the task, in either direction.** Higher means a row appeared since this
plan was written; lower means a row the premise depends on was removed or rewritten. **Stop and
surface, naming the rows the command printed.** Resolving a mid-run collision is the split
story's subject (Task 4), and inventing the procedure here would re-import what was split out.

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

**Must be true:** each appended row is a single line with exactly seven fields and no unescaped
`|`; and after appending, the fingerprint counts are `docs-drift 6`,
`unverified-enforcement-claim 6`, `verification-masks-failure 2`,
`mechanical-check-skipped-before-review 1`.

Note the concurrency limit the spec states and this plan does not exceed: **a row landing after
Step 1's read is not detected.** Step 1 is the only observation point, and supplying another is
the split story's subject.

- [ ] **Step 6: Run the battery.** Expected: exit 0. `check-invariants.sh` excludes
`docs/hardening-log.md` from checks 4a/4b — a ledger that quotes defects would otherwise
self-reject.

- [ ] **Step 7: Commit**

```bash
git add docs/hardening-log.md
```

```bash
git commit -m "WIP: four ledger rows for the 0.8.0 and PR #21 hardenings"
```

---

### Task 8: The CHANGELOG entry

**Files:** Modify `plugins/dev-workflow/CHANGELOG.md`. The manifest bump landed in Task 1.

- [ ] **Step 1: Add the entry**

Immediately above `## 0.8.0`:

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

**Must be true:** exactly one `## 0.8.1` heading, directly above `## 0.8.0`, and the manifest
still reads `0.8.1`.

- [ ] **Step 2: Run the battery.** Expected: exit 0.

- [ ] **Step 3: Commit**

```bash
git add plugins/dev-workflow/CHANGELOG.md
```

```bash
git commit -m "WIP: 0.8.1 changelog entry"
```

---

### Task 9: Validation evidence and the Gate-B cycle

**Files:** Create `.context/evidence-0.8.1.md` — git-ignored, so it never enters the diff; its
content is folded into the closing commit body.

- [ ] **Step 1: Create the evidence file**

If `.context/evidence-0.8.1.md` already exists, **do not overwrite it** — but do not trust it
either. Accept it only if it is a **regular file, not a symlink**, and its header names this
story and the branch `harden-0-8-0-and-pr-21`; anything else is a stale or foreign file, and
reusing it would feed the `<fill` guard content from another cycle. If it fails either test,
**stop and surface** rather than replacing it.

**If it is absent, create it the same way the story files are created** — temporary file in the
same directory, `ln` into place, `trap` to remove the temporary name — not with a redirect.
Classify-then-redirect has the same race here as it does for the stories, and this file ends up
quoted verbatim into the commit body and the PR, so foreign content reaching it is worse than a
stray story copy, not better. Create it with this structure:

```markdown
# Validation evidence — hardening round 0.8.1

Story: docs/superpowers/stories/2026-08-03-hardening-round-0-8-0-and-pr-21-story.md
Branch: harden-0-8-0-and-pr-21

## battery
exit status: <fill>
hook suite under sh:   <fill: expect "all passed", no assertion total>
hook suite under dash: <fill: expect "all passed", no assertion total>
invariants suite:      <fill: expect "all passed (N assertions)">
version-bump suite:    <fill: expect "all passed (N assertions)">
check-invariants.sh:   <fill: expect "invariant checks: ok">
claude plugin validate --strict: <fill>
derived hook-suite assertion count (the suite prints none) — capture the suite's own
exit status separately, and record a count only if that status is 0:
  HOOK_SH=sh sh plugins/dev-workflow/hooks/codex-gate.test.sh > out 2>&1; echo $?
  grep -c '^ok ' out
  -> status <fill>, count <fill>

## check (named verification), with its counterfactual
§5.2 applied to the four cases in spec §10 — each must FAIL on the wiring half:
  1. $EVIDENCE dry run       -> <fill: FAIL/PASS + one line why>
  2. single-shell regression -> <fill>
  3. timed regression row    -> <fill>
  4. dash release evidence   -> <fill>
§5.4 applied to "It bounds the scan, not memory" — must FAIL on exhaustiveness: <fill>
counterfactual: all four were reviewed during the 0.8.0 cycle under the §5 text as it
read before this change and each was accepted by at least one review looking for exactly
this; one (the single-shell test) reached the released artifact.

## prompt conformance
workflow-init.md (invariant 11 surface) — all 12 items: <fill>
CLAUDE.md, AGENTS.md (not on invariant 11's list) — items 6,7,8,9,11,12: <fill>
four split stories — in-spirit brief review: <fill>

## mirror parity
each §5 sentence appears once in CLAUDE.md and once in workflow-init.md: <fill>

## cross-finding conflict check
Task 0 Step 2 verdict: <fill>
```

- [ ] **Step 2: Run the battery (KEPT CHECK) and record it**

Run the quality command from Global Constraints. Record its exit status and each suite's
terminal line verbatim in the evidence file. **Do not write a number you did not read from
output.** The hook suite prints no total, so a count must be derived — and the derivation must
capture the suite's own exit status separately, because a pipeline into `grep -c` returns
grep's status and would record a partial count from a suite that died:

```bash
cd "$(git rev-parse --show-toplevel)" || exit 1
out=$(mktemp) || exit 1
HOOK_SH=sh sh plugins/dev-workflow/hooks/codex-gate.test.sh > "$out" 2>&1
status=$?
count=$(grep -c '^ok ' "$out" || true)
rm -f "$out"
echo "hook suite (sh): status=$status derived-ok-count=$count"
[ "$status" = "0" ] || { echo "suite failed — the count is not evidence"; exit 1; }
exit 0
```

`mktemp` rather than a fixed path: a literal `out` in the repo root would collide with a user's
file and leave an untracked artifact that the clean-tree precondition then trips over.

- [ ] **Step 3: Run the self-tests and record them (RECORDED READING, not an executable check)**

Apply §5.2's sentence, exactly as it now reads in `CLAUDE.md`, to the four cases in spec §10 —
each must **fail** on the second half. Apply §5.4's appended clause to `It bounds the **scan**,
not memory` — it must fail on exhaustiveness. Record all five verdicts with one line of reason
each.

There is no shell block here on purpose. Deciding whether a prompt sentence rejects a case is a
reading; a script asserting it would be asserting its own author's opinion.

If any case passes the sentence written to reject it, that sentence is miswired: **stop and
surface**, do not proceed to Gate B.

- [ ] **Step 4: Record prompt conformance and mirror parity**

`workflow-init.md` is the only changed file inside invariant 11's enumerated surface — all 12
items must pass, with an exception only where the checklist item itself authorizes one (items 9
and 12 do). `CLAUDE.md` and `AGENTS.md` are not on that list and carry no `Target model:` line;
review their edits against items 6, 7, 8, 9, 11 and 12. §5.4's clause continues an existing
prohibition, so cite item 9's own exemption rather than assuming it. Give each split story an
in-spirit brief review. Record all of it, plus the mirror-parity result.

- [ ] **Step 5: Close the cycle — `CLAUDE.md` §5 governs**

**The squash, the Gate-B loop, the amend and the close follow `CLAUDE.md` §5 and its Mechanics
section. This plan does not restate that protocol.** A draft did, and the restatement dropped a
step — which is why §5 is cited rather than paraphrased.

Two things this plan adds, neither of them a re-specification:

1. **The step the restatement dropped, named so it is not dropped again:** §5 requires that
   **every Gate-B fix is amended into the WIP commit before the next review call.**
   `mcp__codex__review` reads a **git range**; a fix that is only staged is not in that range,
   so the next pass would re-review the pre-fix commit and report clean on unreviewed content.
2. **What Gate B carries from this round:** `reviewType: full`; the story path
   `docs/superpowers/stories/2026-08-03-hardening-round-0-8-0-and-pr-21-story.md`; the evidence
   file's content verbatim in `additionalContext`; and the standing lens.

**Must be true at the close:** the working tree is clean, every reviewed fix is in the commit
being amended, and the closing message carries the evidence body.

- [ ] **Step 6: The `<fill` guard, immediately before the amend (KEPT CHECK)**

Run this in the **same block** as the amend, not as a separate step — evidence and repository
state can change between a guard in one fresh shell and an amend in another:

```bash
cd "$(git rev-parse --show-toplevel)" || exit 1
want=harden-0-8-0-and-pr-21
story=docs/superpowers/stories/2026-08-03-hardening-round-0-8-0-and-pr-21-story.md
b=$(git rev-parse --abbrev-ref HEAD) || exit 1
[ "$b" = "$want" ] || { echo "on '$b', expected '$want' — stop"; exit 1; }
EVIDENCE="$(git rev-parse --show-toplevel)/.context/evidence-0.8.1.md"
[ -f "$EVIDENCE" ] && [ ! -L "$EVIDENCE" ] || { echo "evidence missing or not a regular file — stop"; exit 1; }
[ -s "$EVIDENCE" ] || { echo "evidence empty — stop"; exit 1; }
grep -q '<fill' "$EVIDENCE"; g=$?
case "$g" in
  0) echo "evidence still holds <fill placeholders — stop"; exit 1 ;;
  1) : ;;
  *) echo "grep failed reading evidence (status $g) — stop"; exit 1 ;;
esac
grep -qxF "Branch: $want" "$EVIDENCE" || { echo "evidence Branch line is not this cycle's — stop"; exit 1; }
grep -qxF "Story: $story" "$EVIDENCE" || { echo "evidence Story line is not this round's — stop"; exit 1; }
[ -z "$(git status --porcelain)" ] || { echo "tree not clean — stop"; exit 1; }
body=$(cat "$EVIDENCE") || { echo "cannot read evidence — stop"; exit 1; }
[ -n "$body" ] || { echo "evidence body empty — stop"; exit 1; }
git commit --amend -m "Harden four classes from the 0.8.0 cycle and PR #21" -m "$body"
```

Four things are deliberate. The `case` distinguishes grep's three outcomes — a read error
returns neither 0 nor 1 and must stop rather than fall through to success. The `Branch` and
`Story` checks use `grep -qxF`, matching the **whole line literally**: an unanchored substring
search would accept `OldBranch: harden-0-8-0-and-pr-21` from another cycle's file. The
**checked-out branch is verified here**, not only at push time, because this block mutates
history and doing that on an unexpected branch is not recoverable by a later check. And
`EVIDENCE` is defined in this block because a fresh shell carries nothing from the previous one,
`cat ""` fails, and `git commit --amend` would still succeed with an empty body — silently
dropping the evidence from the durable record.

- [ ] **Step 7: Push and open the PR**

Both blocks require the exact feature branch by name. A `!= main` test is not enough: a resumed
run on some other branch would pass it and push the wrong thing.

```bash
cd "$(git rev-parse --show-toplevel)" || exit 1
want=harden-0-8-0-and-pr-21
b=$(git rev-parse --abbrev-ref HEAD) || exit 1
[ "$b" = "$want" ] || { echo "on '$b', expected '$want' — stop"; exit 1; }
git push -u origin "$want"
```

```bash
cd "$(git rev-parse --show-toplevel)" || exit 1
want=harden-0-8-0-and-pr-21
story=docs/superpowers/stories/2026-08-03-hardening-round-0-8-0-and-pr-21-story.md
b=$(git rev-parse --abbrev-ref HEAD) || exit 1
[ "$b" = "$want" ] || { echo "on '$b', expected '$want' — stop"; exit 1; }
local_head=$(git rev-parse HEAD) || exit 1
remote_head=$(git rev-parse "origin/$want") || { echo "no pushed branch — stop"; exit 1; }
[ "$local_head" = "$remote_head" ] || { echo "local HEAD and origin/$want diverge — push again, then retry"; exit 1; }
EVIDENCE="$(git rev-parse --show-toplevel)/.context/evidence-0.8.1.md"
[ -f "$EVIDENCE" ] && [ ! -L "$EVIDENCE" ] || { echo "evidence missing or not a regular file — stop"; exit 1; }
grep -q '<fill' "$EVIDENCE"; g=$?
case "$g" in
  0) echo "evidence holds <fill placeholders — stop"; exit 1 ;;
  1) : ;;
  *) echo "grep failed reading evidence (status $g) — stop"; exit 1 ;;
esac
grep -qxF "Branch: $want" "$EVIDENCE" || { echo "evidence Branch line wrong — stop"; exit 1; }
grep -qxF "Story: $story" "$EVIDENCE" || { echo "evidence Story line wrong — stop"; exit 1; }
body=$(cat "$EVIDENCE") || { echo "cannot read evidence — stop"; exit 1; }
[ -n "$body" ] || { echo "evidence body empty — stop"; exit 1; }
gh pr create --base main --head "$want" \
  --title "Harden four classes from the 0.8.0 cycle and PR #21" \
  --body "$body"
```

**The evidence checks are repeated here rather than inherited from Step 6.** That validation
happened in a different shell at an earlier moment, and `.context/` is git-ignored and mutable —
a replacement, a symlink, or a reintroduced `<fill` between the two blocks would otherwise reach
the PR unvalidated even though the commit body was sound. The body is read into a variable with
an explicit stop, because `--body "$(cat …)"` swallows a `cat` failure and would open the PR
empty. And local `HEAD` is compared to `origin/$want`, so a commit made between push and PR
cannot open a PR whose remote head omits the reviewed close.

Invariant 12's checker is `pull_request`-only, so work that reaches `main` without a PR never
meets it.

Then run `/dev-workflow:process-pr-review` once the bots report.

---

## Self-Review

**Spec coverage.** §5.1–§5.4 → Tasks 1–2. §6 rows A–D → Task 7. §6.4's concurrency limit →
Task 7, stated as the spec states it. §6.5 class → Task 3. §8 four stories → Tasks 4–5. §9
deliverables → Task 6, Task 1 Step 5, Task 8, Task 3. §10 validation → Task 9. §10 conflict
check → Task 0 Step 2, before any edit. D7 (no skill file) → Global Constraints, Task 3.

**Placeholder scan.** No `TBD`, no "similar to Task N". Every ledger row, story, CHANGELOG entry
and the evidence template is written out in full.

**Type consistency.** `mechanical-check-skipped-before-review` matches across Tasks 3 and 7. The
four story paths match across Tasks 4, 5, 6. `EVIDENCE` is defined in every block that reads it.

**Verification surface.** **Four** executable checks — branch preflight, battery, ledger
precondition, `<fill` guard — each self-contained and each exiting nonzero on failure. Plus
**one recorded reading**, the §5.2/§5.4 self-tests, which have no executable oracle because
applying a prompt sentence to a case is a judgement. Everything else is a must-be-true the
executor satisfies however it likes, and Gate B reviews the diff that resulted.

**What this plan does not specify.** The squash, the Gate-B loop, the amend and the close are
`CLAUDE.md` §5's, cited rather than restated. The one step named explicitly — amend every fix
into the WIP commit before re-reviewing — is named because a draft's restatement dropped it,
and `mcp__codex__review` reads a git range in which a staged-only fix does not appear.
