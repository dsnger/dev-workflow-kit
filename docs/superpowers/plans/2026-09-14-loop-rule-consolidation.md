# §5 loop-rule consolidation — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Install one closure ordering into both §5 copies, replace the twenty-three standing sentences it falsifies across those copies and the shipped hook, and ship the result as plugin 0.12.0.

**Architecture:** Every string this change installs is already written in final form in the target text. This plan does not restate any of it. Each task names the **site**, quotes the **anchor** it installs at, cites the **target-text section** whose fenced block is the bytes to install, and builds the **discriminating pair of counts** that shows the new wording present and the old wording gone. Copying the replacement text into this plan would create the second-copy defect the whole cycle fought; a citation into an approved artifact that travels with this plan is not a placeholder.

**Tech Stack:** Markdown prompt text, POSIX `sh` (the hook), `grep`/`diff` for verification, `shellcheck`, the `claude` CLI.

**Spec:** `docs/superpowers/specs/2026-09-10-loop-rule-consolidation-target-text.md` (the text, in final form) and `docs/superpowers/specs/2026-09-10-loop-rule-consolidation-design.md` (the decisions behind it). Both are approved: Gate-A cycle `awsf1ec771` closed at pass 65 with a zero-finding file, commit `ba15e83`.

**Story:** `docs/superpowers/stories/2026-08-29-loop-rule-consolidation-story.md` — read the profile from its header at every gate call; it is the only writable copy. Six acceptance criteria; §4 holds settled decisions D1–D8.

---

## Global Constraints

- **Both prompt copies take every NEW and REPLACED section byte-identical**, except §F's seven hook items, whose destination is the shipped hook and its test and which carry no parity obligation (target §"How to read a section", §F opening).
- **C** = `CLAUDE.md`. **W** = `plugins/dev-workflow/commands/workflow-init.md`. Every line number below is re-read at execution; the inventory's numbers cite `7c0d475` and have drifted.
- **Every hook replacement installs into a double-quoted POSIX-shell `note` argument** and therefore carries no backtick, no `$(`, no backslash and no double quote. `$policy`, `$floor`, `$passes`, `$passesA` and `$fresh` are the intended interpolations (target §F opening).
- **Install every replacement unwrapped** — as one line in the file — because a counted fragment must be single-line for `grep -F` to find it (design §7).
- **Invariant 5 (exact pinning)** and **invariant 12 (a plugin change requires a version bump)**: this change touches `plugins/`, so `plugins/dev-workflow/.claude-plugin/plugin.json` goes `0.11.0 → 0.12.0` with a CHANGELOG entry (design §8).
- **Invariant 11:** every prompt change passes all 12 items of `docs/prompt-standards.md`. Most at risk: item 6 (every constraint carries its reason in the same sentence) and item 8 (token-lean).
- **Invariant 4 / the hook:** no control flow, counter, fingerprint computation, routing or event handling changes. Only `note` strings and their expectations.
- **Gate-B cycle discipline:** snapshot commits are named `WIP: …`; the cycle closes by `git commit --amend`. A non-`WIP` commit mid-cycle resets the hook's counters.

---

## File Structure

| File | Responsibility in this change |
|---|---|
| `CLAUDE.md` | canonical §5 (and one §4 line). Receives §A–§E, §G, §H and §F's sixteen prompt-copy items. |
| `plugins/dev-workflow/commands/workflow-init.md` | the scaffolded mirror. Receives the same, byte-identical, minus the deliberate divergences the inventory records. |
| `plugins/dev-workflow/hooks/codex-gate.sh` | seven `note` strings, both channels each (§F items 10–13, 15–17). No behaviour change. |
| `plugins/dev-workflow/hooks/codex-gate.test.sh` | three `expected_ctx` and three `expected_msg` exact-match expectations, plus every other assertion, label or comment naming a replaced string. |
| `plugins/dev-workflow/.claude-plugin/plugin.json` | `version` `0.11.0 → 0.12.0`. |
| `plugins/dev-workflow/CHANGELOG.md` | the 0.12.0 entry, newest first. |
| this plan | the 135-condition disposition (below), the next-state table (Task 13), and the verification pairs each task builds. |

---

## The condition disposition — all 135, by passage

Story acceptance criterion 5 is satisfied here. Ids are `docs/superpowers/specs/2026-09-10-loop-rule-consolidation-condition-inventory.md`, snapshot at `7c0d475`. **Where the tree and the inventory disagree, the tree wins and the accounting is what needs correcting** — check each condition against the real file before marking it done.

### Passage (a) — the floor paragraphs → target §H (Task 7)

| Condition | Disposition |
|---|---|
| a1–a12, a14 | **kept**, untouched. The floor arithmetic, the hook-ratio rules and the two comparison points are outside this change. |
| a13 | **replaced** — scoped to its own paragraph. §H's `a13` block. |
| a15 | **carried** inside §H's `a16` block, which reproduces it so one contiguous string installs. |
| a16 | **replaced** — points at Mechanics · Severity instead of carrying an unscoped copy. §H's `a16` block. |
| a17, a18, a19 | **moved** — the floor paragraph stops stating the clean-final-pass rule and the early exit; both are stated once in §A. §H's `a17`–`a22` block. |
| a20 | **moved** to §A unchanged, beside the zero-finding rule it qualifies. |
| a21, a22 | **carried** unchanged, reproduced in §H's block for the same contiguity reason as a15. |

### Passage (b) — what a loop absorbs → target §B (Task 3)

§B states its own accounting and this table reproduces it: **Changed:** `b3`, `b7`, `b8`, `b11`, `b12`, `b13`, `b16`, `b17`, `b18`. **Added:** the closing-time change rule and decision 6's decline semantics, which no inventoried condition carried because none existed. **Carried:** `b1`, `b2`, `b4`, `b5`, `b6`, `b9`, `b10`, `b14`, `b15`.

**Verify against the file, not against this table:** §B is written out whole and is the only place this change states passage (b). Read the installed passage and confirm each carried condition is present and each changed one is gone.

### Passage (c) — recognizing clearly stuck → target §C (Task 4) and §H (Task 7)

| Condition | Disposition |
|---|---|
| c1, c2, c3 | **kept** — the curve-reading sentences are untouched. |
| c4 | **replaced** — "a missing one means keep going" becomes "means only that *this* exit does not apply", the pass's actual next step being the ordering's. |
| c5, c6, c7 | **carried word for word** inside §C's block. |
| c8 | **changed** — gains the re-raised-dismissal clause. |
| c9 | **split.** The operative precedence clause moves into §A capitalized as a standalone sentence; the plateau rationale stays at this source. Not moved whole — §C says so explicitly. |
| c10, c11 | **moved** to §A, which states what a Blocker/Major-free pass at or above the floor does. |
| c12, c13 | **moved** to §A, beside a19. |
| c14 | **replaced, not moved.** The ordering splits the below-floor Minor case into suspend and continue; no copy of the live wording survives beside them. |
| c15, c16 | **replaced** — §H's `c18`-and-surfacing block. The hold is now over the cycle and the new hold. |
| c17 | **replaced** — the resolve rule now scopes to the assigned fix set and states what a validly dismissed recurrence owes. |
| c18 | **replaced** — the blanket no-clean-credit goes; a pass is credited on its own findings, and a scope-stop trigger is what withholds credit. |
| c19 | **replaced** — the one-answer resumption goes; what the answer does is the ordering's. |
| c20 | **carried**, with "Blocker and Major" narrowed to "**in-set** Blocker and Major". |

### Passage (d) — from pass 4 onward (Task 0 check only)

`d1`–`d7`: **all kept, untouched.** The unavailable-history block moved to the successor story with D10 and this change no longer edits this passage (design §5). **A diff touching C 255–261 or W 459–465 is a defect.**

### Passage (e) — the five tells → target §D (Task 5)

| Condition | Disposition |
|---|---|
| e1–e6 | **kept** — the five tells themselves are untouched. |
| e7 | **changed** — gains the read-after-clean-completion clause. The sentence is given entire in §D. |
| e8, e9, e10 | **carried** inside §D's block. |
| e11 | **kept** — the C-only rationale paragraph is untouched and stays C-only. |
| — | **added:** §D's pointer paragraph at the end of the passage. |

### Passage (f) — the two rules above do not compete (Task 0 check only)

`f1`–`f7`: **all kept, untouched.** "The two rules above" still names the absorb rule and the stuck reading; the block sits before both and adds no third rule between them (design §5). **A diff touching C 275–287 or W 473–483 is a defect, and so is inserting §A anywhere that would come between them.**

### Passage (g) — Mechanics · Severity → target §E (Task 6)

| Condition | Disposition |
|---|---|
| g1 | **replaced by the answer** — the demotion changes what a cycle must resolve, never what it observes. |
| g2 | **dropped** — the interim report-and-stop duty existed only until the question was settled, and it is settled. |
| g3 | **dropped with g2**, being that duty's justification. |
| g4 | **dropped (C only)** — the ownership sentence names the story this change discharges. **Removing it in C while leaving W's duty standing would desynchronise the copies in the opposite direction**, so g2/g3 must go from W in the same edit. This is the one deliberate story-path divergence and it disappears with this change. |

### Passage (h) — recording a human exception → target §F (Tasks 8, 9)

| Condition | Disposition |
|---|---|
| h1–h3, h5, h6, h8–h18, h20–h26 | **kept**, untouched. |
| h4 | **replaced** — §F item 7, the human-exception destination: a Gate-A cycle's record goes to the commit its closing act produces, not to "the spec or plan commit". |
| h7 | **kept.** |
| h19 | **replaced** — §F item 4, the scope sentence: "neither a human's **general** assent nor this record", plus the clause distinguishing the answers a suspension asks for from assent. |
| h13 | **kept.** Design §4 names this sentence as deliberately not edited: this change ships no record for the squash carry to carry. |

### Passage (i) — when these rules bind → target §H (Task 7)

`i1`, `i2`, `i3`, `i9`–`i11`, `i13`–`i16`: **kept**, untouched.
`i4`–`i8`: **kept**, and the dash-delimited list they sit in is **extended, not rewritten** — §H gives the whole list with the additions at the end.
`i12`: **discharged, and kept.** It is the extension point that licenses the addition; it stays because the next change needs it too.

### Passage (j) — the squash carry (Task 0 check only)

`j1`–`j4`: **all kept, untouched.** It was to name the answer record, which moved to the successor; this change ships no record for it (design §5). **A diff touching C 892 or W 1076 is a defect.**

---

## Task 0: Establish the baseline and the do-not-touch set

**Files:** none modified.

**Interfaces:**
- Produces: `$BASE` (the parent commit every later task's counterfactual half runs against), and a recorded list of the five untouched passage ranges.

- [ ] **Step 1: Confirm the approved artifacts and a clean tree**

```bash
git log --oneline -1        # expect ba15e83 or later on loop-rule-consolidation
git status --porcelain      # expect empty
BASE=$(git rev-parse HEAD)  # every counterfactual count runs against this
echo "$BASE"
```

- [ ] **Step 2: Re-read the five untouched ranges and record their current line numbers**

Passages (d), (f) and (j) are not edited by this change, and passage (a)'s arithmetic and passage (h)'s twenty-three kept conditions are mostly untouched. Record where they are now, because the inventory's numbers cite `7c0d475`:

```bash
grep -n 'From pass 4 onward every pass report carries three lines' CLAUDE.md plugins/dev-workflow/commands/workflow-init.md
grep -n 'The two rules above do not compete' CLAUDE.md plugins/dev-workflow/commands/workflow-init.md
grep -n 'On squash-merge, copy every evidence entry' CLAUDE.md plugins/dev-workflow/commands/workflow-init.md
```

Expected: two hits each, one per copy. Write the six line numbers into a scratch note — Task 14 diffs against them.

- [ ] **Step 3: Confirm the parity baseline of the inventoried ranges**

```bash
diff <(sed -n '65,290p' CLAUDE.md) <(sed -n '264,489p' plugins/dev-workflow/commands/workflow-init.md) | head -40
```

Expected: the deliberate divergences the inventory records (b3's cross-reference target, b's intensifier and field-mint parenthetical, e8's pronoun, e11, f5–f7's framing, g4). **Anything else is pre-existing drift — record it and raise it before editing**, because Task 14's parity diff cannot tell drift you introduced from drift you inherited.

- [ ] **Step 4: Commit nothing**

Task 0 produces a scratch note, not a commit.

---

## Task 1: Install the closure ordering (§A) into both copies

**Files:**
- Modify: `CLAUDE.md` — insert immediately before the line beginning `**What a loop absorbs, and what stops it`
- Modify: `plugins/dev-workflow/commands/workflow-init.md` — the same anchor
- Test: the counts in Step 4

**Interfaces:**
- Consumes: `$BASE` from Task 0.
- Produces: the installed block that every later task's pointers refer to. Later tasks cite it as "the closure ordering"; nothing depends on its line numbers.

**The bytes:** target text §A, the three fenced blocks under `### A1 — the ordering`, `### A2` and `### A3`, in that order, as three paragraphs. §A's opening sentence states the placement: "sitting immediately before **What a loop absorbs, and what stops it** in both copies."

**Counterfactual: ABSENT, and claimed as absent.** The parent carries none of the three paragraphs, so no old wording can be shown to disappear. **Presence alone is the check here**, and the evidence entry says so rather than implying a pair (design §7).

- [ ] **Step 1: Find the anchor in both copies**

```bash
grep -n '^\*\*What a loop absorbs, and what stops it' CLAUDE.md plugins/dev-workflow/commands/workflow-init.md
```

Expected: exactly one hit per file.

- [ ] **Step 2: Verify the block is absent before installing**

```bash
grep -cF 'How a cycle ends — one ordering, stated here and referenced everywhere else' CLAUDE.md plugins/dev-workflow/commands/workflow-init.md
```

Expected: `0` for both. If either is non-zero the block is already partly installed — stop and reconcile.

- [ ] **Step 3: Install §A1, §A2 and §A3 in both copies**

Insert the three blocks before the anchor line, blank-line separated, byte-identical in both files. **Do not reflow.** Install each paragraph unwrapped where the target text shows it unwrapped.

**Placement constraint from the disposition table:** §A must not land between passage (b) and passage (c), because `f1` ("the two rules above") names those two and would then name the wrong pair. Inserting *before* (b) satisfies this.

- [ ] **Step 4: Run the presence counts in both copies and both trees**

```bash
for f in CLAUDE.md plugins/dev-workflow/commands/workflow-init.md; do
  printf '%s worktree: ' "$f"
  grep -cF 'How a cycle ends — one ordering, stated here and referenced everywhere else' "$f"
  printf '%s parent:   ' "$f"
  git show "$BASE:$f" | grep -cF 'How a cycle ends — one ordering, stated here and referenced everywhere else'
done
```

Expected: worktree `1`, parent `0`, for both files. A parent count above zero means `$BASE` is wrong.

- [ ] **Step 5: Check parity of the installed block**

```bash
diff <(sed -n '/^\*\*How a cycle ends/,/^\*\*What a loop absorbs/p' CLAUDE.md) \
     <(sed -n '/^\*\*How a cycle ends/,/^\*\*What a loop absorbs/p' plugins/dev-workflow/commands/workflow-init.md)
```

Expected: no output.

- [ ] **Step 6: Commit**

```bash
git add CLAUDE.md plugins/dev-workflow/commands/workflow-init.md
git commit -m "WIP: install the closure ordering into both §5 copies"
```

Named `WIP:` because Task 15 runs Gate B over the whole change and amends once. A non-`WIP` commit here would reset the hook's Gate-B counters mid-cycle.

---

## Task 2: Verify the untouched passages are still untouched

**Files:** none modified.

**Interfaces:**
- Consumes: Task 0's recorded line numbers and `$BASE`.

This task exists because `f1` and the (d)/(j) dispositions are falsifiable only by a diff, and the cheapest moment to catch an accidental edit is immediately after the insertion that could have caused one.

- [ ] **Step 1: Diff each untouched passage against the parent**

```bash
for f in CLAUDE.md plugins/dev-workflow/commands/workflow-init.md; do
  for anchor in 'From pass 4 onward every pass report carries three lines' \
                'The two rules above do not compete' \
                'On squash-merge, copy every evidence entry'; do
    printf '%s | %s: ' "$f" "$anchor"
    diff <(git show "$BASE:$f" | grep -A12 -F "$anchor") <(grep -A12 -F "$anchor" "$f") >/dev/null \
      && echo unchanged || echo CHANGED
  done
done
```

Expected: `unchanged` six times. Any `CHANGED` is a defect — revert that hunk before continuing.

- [ ] **Step 2: Confirm `f1` still names the right pair**

Read the installed text around "The two rules above do not compete" and confirm the two rules immediately above it are still the absorb rule and the clearly-stuck reading, with §A before both rather than between them.

- [ ] **Step 3: No commit** — this task verifies, it does not change.

---

## Task 3: Replace passage (b) with §B in both copies

**Files:**
- Modify: `CLAUDE.md` — the passage beginning `**What a loop absorbs, and what stops it`
- Modify: `plugins/dev-workflow/commands/workflow-init.md` — the same

**The bytes:** target §B, which states it is "the only place this file states anything about" passage (b). **Preserve the two deliberate divergences** the inventory records and §B confirms: W says `the severity rule` where C says `Mechanics` (b3); and the field-mint parenthetical closes the paragraph in C and is absent from W. §B says it stops short of that parenthetical, which is left exactly as each copy has it.

- [ ] **Step 1: Record the old-wording fragments**

Two fragments that must reach zero, chosen because each is single-line in the file and is **not** preserved inside the replacement:

```bash
grep -cF 'plus repair obligations you already accepted in earlier passes' CLAUDE.md
grep -cF 'it resumes the moment the user says whether the set now includes it' CLAUDE.md
```

Expected before the edit: `1` each. Re-check both against W with the same command.

- [ ] **Step 2: Install §B's text over the passage in both copies**

Replace from `**What a loop absorbs, and what stops it` through the sentence §B ends at, keeping each copy's own closing parenthetical.

- [ ] **Step 3: Run the discriminating pair, both copies, both trees**

```bash
NEW='union of the scope every approved story or plan governing this change assigns to this cycle'
OLD='plus repair obligations you already accepted in earlier passes'
for f in CLAUDE.md plugins/dev-workflow/commands/workflow-init.md; do
  printf '%s new/worktree=%s new/parent=%s old/worktree=%s old/parent=%s\n' "$f" \
    "$(grep -cF "$NEW" "$f")" "$(git show "$BASE:$f" | grep -cF "$NEW")" \
    "$(grep -cF "$OLD" "$f")" "$(git show "$BASE:$f" | grep -cF "$OLD")"
done
```

Expected per file: `new/worktree=1 new/parent=0 old/worktree=0 old/parent=1`. **All four values matter** — a copy carrying both the new and the old wording satisfies a one-sided presence check and is exactly the two-instructions-that-disagree failure this pair exists to catch.

- [ ] **Step 4: Walk the carried conditions**

Read the installed passage and confirm `b1`, `b2`, `b4`, `b5`, `b6`, `b9`, `b10`, `b14`, `b15` are each present, and that `b3`, `b7`, `b8`, `b11`, `b12`, `b13`, `b16`, `b17`, `b18` read as §B states rather than as the parent did. Nine plus nine; the disposition table above is the checklist.

- [ ] **Step 5: Parity**

```bash
diff <(sed -n '/^\*\*What a loop absorbs/,/^\*\*Recognizing "clearly stuck"/p' CLAUDE.md) \
     <(sed -n '/^\*\*What a loop absorbs/,/^\*\*Recognizing "clearly stuck"/p' plugins/dev-workflow/commands/workflow-init.md)
```

Expected: only the three recorded divergences.

- [ ] **Step 6: Commit**

```bash
git add CLAUDE.md plugins/dev-workflow/commands/workflow-init.md
git commit -m "WIP: replace passage (b) with the absorb paragraph that owns the fix set"
```

---

## Task 4: Replace passage (c)'s third condition and its two following sentences with §C

**Files:**
- Modify: `CLAUDE.md` — the passage beginning `**Recognizing "clearly stuck"`
- Modify: `plugins/dev-workflow/commands/workflow-init.md` — the same

**The bytes:** target §C's fenced block, which gives the three-condition sentence entire so nothing begins mid-clause.

**The split, stated because getting it wrong is the failure §C names:** only the operative precedence clause — from "a clean completion takes precedence over this exit" to the end of that sentence — moves into §A, capitalized there. Its opening clause, the plateau rationale, **stays here**. The below-floor sentence (`c14`) **does not move; it is replaced**, and no copy of its live wording may survive beside the ordering's split.

- [ ] **Step 1: Record the old-wording fragments**

```bash
grep -cF 'a Blocker/Major-free pass below the floor' CLAUDE.md
grep -cF 'So this exit needs three things' CLAUDE.md
```

Expected: `1` each, in both copies.

- [ ] **Step 2: Install §C's block**

- [ ] **Step 3: Confirm the moved clause exists in §A and nowhere else**

```bash
grep -cF 'clean completion' CLAUDE.md
grep -n 'takes precedence over this exit' CLAUDE.md
```

The precedence clause must appear **once**, inside the ordering. A second occurrence in passage (c) means the sentence was moved whole instead of split.

- [ ] **Step 4: Run the discriminating pair, both copies, both trees**

Same four-value shape as Task 3, with `OLD='a Blocker/Major-free pass below the floor'` and `NEW` a single-line fragment of §C's re-raised-dismissal clause taken from the installed file.

Expected: `new/worktree=1 new/parent=0 old/worktree=0 old/parent=1`.

- [ ] **Step 5: Walk the conditions** — `c1`–`c3` present unchanged, `c5`–`c7` word for word, `c8` carrying the new clause, `c9` split, `c10`–`c14` gone from here.

- [ ] **Step 6: Commit**

```bash
git add CLAUDE.md plugins/dev-workflow/commands/workflow-init.md
git commit -m "WIP: widen the clearly-stuck third condition and split its precedence sentence"
```

---

## Task 5: Replace `e7` and add the pointer (§D) in both copies

**Files:**
- Modify: `CLAUDE.md` — the paragraph beginning `Those three lines expose`
- Modify: `plugins/dev-workflow/commands/workflow-init.md` — the same

**The bytes:** target §D's two fenced blocks — the `e7` sentence entire, and the pointer paragraph added at the end of the passage.

**Parity note:** W drops the pronoun (`report the tells`, not `you report the tells`). §D's block carries C's wording; **W keeps its own pronoun** unless the parity divergence list decides otherwise in Task 14. Record which you chose — this is one of the two divergences the inventory flags for passage (e), and the other (e11, the C-only rationale paragraph) is untouched.

- [ ] **Step 1: Record the old wording**

```bash
grep -cF 'Any two present makes stop-and-surface mandatory, not discretionary' CLAUDE.md
```

Expected `1` — but note this fragment **survives inside the replacement**, so it cannot be the old-wording half of the pair. Use instead:

```bash
grep -cF 'and the "clearly stuck" reading above is not a precondition for it' CLAUDE.md
```

and pair it against the installed sentence's new clause. **This is the trap design §7 records:** four spec revisions named a fragment preserved inside its own replacement, whose old-wording-gone count could never reach zero.

- [ ] **Step 2: Install §D's `e7` sentence and the pointer paragraph**

- [ ] **Step 3: Run the discriminating pair**, both copies, both trees, with `NEW='read **after** the clean-completion branch of the closure ordering'` and `OLD` from Step 1.

Expected: `new/worktree=1 new/parent=0 old/worktree=0 old/parent=1`.

- [ ] **Step 4: Confirm `e1`–`e6` and `e8`–`e11` are untouched**, and that e11 is still C-only.

- [ ] **Step 5: Commit**

```bash
git add CLAUDE.md plugins/dev-workflow/commands/workflow-init.md
git commit -m "WIP: read the two-tell threshold after the clean-completion branch"
```

---

## Task 6: Replace Mechanics · Severity's resolve duty and the handed-over question with §E

**Files:**
- Modify: `CLAUDE.md` — the `**Severity:**` bullet and the `How this demotion bears` paragraph
- Modify: `plugins/dev-workflow/commands/workflow-init.md` — the same

**The bytes:** target §E's two fenced blocks.

**This task removes the one deliberate story-path divergence.** `g4` — C's sentence naming `docs/superpowers/stories/2026-08-29-loop-rule-consolidation-story.md` as owning the question — goes, because this change is that work and the question is answered. `g2` and `g3`, the interim report-and-stop duty and its justification, go from **both** copies in the same edit. **Removing g4 from C without removing g2/g3 from W desynchronises the copies in the opposite direction**, which is the failure the inventory flags by name.

- [ ] **Step 1: Record the old wording in both copies**

```bash
for f in CLAUDE.md plugins/dev-workflow/commands/workflow-init.md; do
  printf '%s g1/g2: %s  g4: %s\n' "$f" \
    "$(grep -cF 'is not settled here, and this change does not settle it' "$f")" \
    "$(grep -cF '2026-08-29-loop-rule-consolidation-story.md' "$f")"
done
```

Expected: C `g1/g2: 1  g4: 1`; W `g1/g2: 1  g4: 0`.

- [ ] **Step 2: Install §E's resolve-duty bullet and its answer paragraph in both copies**

- [ ] **Step 3: Run the discriminating pair**, both copies, both trees, with `NEW='The demotion changes what a cycle must resolve, never what it observes'` and `OLD='is not settled here, and this change does not settle it'`.

Expected: `new/worktree=1 new/parent=0 old/worktree=0 old/parent=1` in both.

- [ ] **Step 4: Confirm g4 is gone from C**

```bash
grep -c '2026-08-29-loop-rule-consolidation-story.md' CLAUDE.md
```

Expected: `0`. The story path may still appear in `docs/` — this check is scoped to `CLAUDE.md`.

- [ ] **Step 5: Parity** — this passage should now be byte-identical, the one recorded divergence having been removed. Diff the two Severity bullets and expect no output.

- [ ] **Step 6: Commit**

```bash
git add CLAUDE.md plugins/dev-workflow/commands/workflow-init.md
git commit -m "WIP: answer the demotion question and scope the resolve duty to the fix set"
```

---

## Task 7: Install §G and §H's replacements in both copies

**Files:**
- Modify: `CLAUDE.md`, `plugins/dev-workflow/commands/workflow-init.md`

**The bytes:** target **§G**'s fenced block — the one-contract paragraph, whose membership is widened and which gains a semantic test a downstream reader can apply — and target **§H**'s blocks, in the order §H gives them: the `c18`-and-surfacing block; `a13`; `a16`; `a17`–`a22`; the Gate-A clean-signal sentence; the gate-prompt template's clean sentence; the Gate-A cadence; the lens paragraph's unchanged-list; and the unknown-start strict-reading list. **Passage (b) is deliberately not among them** — §B owns it.

**§G is not in the a–j inventory** and therefore carries no condition ids; design §4 lists it as its own site. **§G is an instruction to the agent, not a checker** — install it as written and do not add a mechanical guard beside it.

**`i12` is the licence for the strict-reading addition and stays in place.** The list is extended at the end, not rewritten; §H gives the whole dash-delimited list so one contiguous string installs.

- [ ] **Step 1: Locate all eight sites in both copies**

```bash
for f in CLAUDE.md plugins/dev-workflow/commands/workflow-init.md; do
  echo "== $f"
  grep -n 'These rules and records are one contract' "$f"
  grep -n 'Surfacing does not close the cycle' "$f"
  grep -n 'Every other rule stated here about how a cycle closes' "$f"
  grep -n 'Open a TodoWrite' "$f"
  grep -n 'Your final pass must be clean' "$f"
  grep -n 'literal `NO FINDINGS` when a pass is clean' "$f"
  grep -n 'A clean pass is the single body line' "$f"
  grep -n 'Each pass: validate, revise, re-run' "$f"
  grep -n 'Lenses are \*\*different questions, not more passes\*\*' "$f"
  grep -n 'at minimum floor 3, severity classified without the demotion' "$f"
done
```

Expected: one hit per pattern per file. A pattern with zero hits means the wording drifted since the inventory — find it before installing.

- [ ] **Step 2: Install §G and all eight §H blocks, one site at a time, verifying each before moving to the next**

- [ ] **Step 3: Run one discriminating pair per block**, both copies, both trees. Old-wording fragments, each single-line and none preserved inside its own replacement:

| Block | OLD fragment |
|---|---|
| §G one-contract | `These rules and records are one contract` |
| `c18`/surfacing | `no pass is credited as clean` |
| `a13` | `Every other rule stated here about how a cycle closes` |
| `a16` | `fix Blocker/Major after each` |
| `a17`–`a22` | `Your final pass must be clean` |
| Gate-A clean signal | `a literal \`NO FINDINGS\` when a pass is clean` |
| template clean sentence | `A clean pass is the single body line` |
| Gate-A cadence | `Each pass: validate, revise, re-run` |
| lens unchanged-list | `The Blocker/Major filter, the file-first findings protocol` |
| strict-reading list | `the nonce duties at their strictest, the cycle is treated as post-rule` |

Expected for each: `old/worktree=0 old/parent=1`, and the matching new fragment `1` / `0`.

**The strict-reading list is add-only at its tail but replaces the dash-delimited run**, so it owes a full pair rather than presence alone. **The gate-prompt template's clean sentence is add-only** if the site carries no wording the change removes — classify it against the real file, per design §7, and check by presence alone if so.

- [ ] **Step 4: Confirm `a21`, `a22`, `a15` survived** — they are carried inside blocks that install contiguously, so a mis-scoped replacement silently drops them.

```bash
grep -cF 'Codex is advisory — validate before applying; dismissed finding → one-line why' CLAUDE.md
grep -cF 'Open a TodoWrite' CLAUDE.md
```

Expected: `1` each.

- [ ] **Step 5: Parity** for all nine sites.

- [ ] **Step 6: Commit**

```bash
git add CLAUDE.md plugins/dev-workflow/commands/workflow-init.md
git commit -m "WIP: install the one-contract paragraph and the remaining prompt-copy replacements"
```

---

## Task 8: Replace §F's items 1–9 in both copies

**Files:**
- Modify: `CLAUDE.md`, `plugins/dev-workflow/commands/workflow-init.md`

**The bytes:** target §F items 1, 2, 3, 4, 5, 6, 7, 8, 7a, 8a, 8b, 9a, 9b and 9 — fourteen items, each with its own fenced replacement and its `C nnn` / `W nnn` citation. **Re-read every citation against the current file**: §F's own collected list records that items 4, 5 and 8 have line citations one off, and the numbers drifted further as this cycle edited the copies.

**`h4` and `h19` are the human-exception conditions these items discharge** — item 7 is the destination, item 4 the scope sentence.

- [ ] **Step 1: Re-derive every item's real location**

For each item, take the quoted live sentence from §F and find it, rather than trusting the cited line:

```bash
grep -n -F '<the live sentence §F quotes>' CLAUDE.md plugins/dev-workflow/commands/workflow-init.md
```

**Where a quoted sentence wraps across lines in the file, `grep -F` on the whole sentence returns nothing.** Search a single-line fragment of it instead and confirm by reading. Record which items wrap — Task 14's parity diff needs it.

- [ ] **Step 2: Install all fourteen replacements**

- [ ] **Step 3: Run one discriminating pair per item**, both copies, both trees, choosing each OLD fragment single-line and not preserved inside its replacement.

Expected per item: `new/worktree=1 new/parent=0 old/worktree=0 old/parent=1`.

- [ ] **Step 4: Count what was installed**

```bash
# fourteen prompt-copy items from this task, each present once per copy
```

State the number you observed. **Do not carry a count from §F into a check** — §F states the count of falsified sentences and this task installs a subset of them; a count copied between the two is the stale-bookkeeping defect the design records at five passes running.

- [ ] **Step 5: Parity** for all fourteen sites.

- [ ] **Step 6: Commit**

```bash
git add CLAUDE.md plugins/dev-workflow/commands/workflow-init.md
git commit -m "WIP: replace the fourteen falsified sentences in the two prompt copies"
```

---

## Task 9: Replace §F's items 14 and 18

**Files:**
- Modify: `CLAUDE.md` — the Named residual paragraph (§5), and the work-loop line (§4)
- Modify: `plugins/dev-workflow/commands/workflow-init.md` — the same two

**The bytes:** target §F item 14 (the Named residual's blanket exemption) and item 18 (the work-loop sequence).

**These two are separated from Task 8 because they were found last and because item 18 is the only edit outside §5.** A reviewer can reject this task while approving Task 8.

- [ ] **Step 1: Locate both sites**

```bash
grep -n 'Hook text is out of scope here' CLAUDE.md plugins/dev-workflow/commands/workflow-init.md
grep -n 'The work loop includes the review gates' CLAUDE.md plugins/dev-workflow/commands/workflow-init.md
```

Expected: one hit each per file. **Item 14's sentence wraps after "here"** — §F says so; grep a single-line fragment.

- [ ] **Step 2: Install both replacements**

- [ ] **Step 3: Discriminating pairs**

```bash
OLD1='Hook text is out of scope here'
NEW1='not a blanket exemption for hook text'
OLD2='execute → tests green → Gate B → commit'
NEW2='Gate A (spec) → Gate-A closing act'
```

Expected for each, in both copies: `new/worktree=1 new/parent=0 old/worktree=0 old/parent=1`.

- [ ] **Step 4: Confirm the residual the sentence was written for still stands**

The hook reporting its own threshold as an obligation at a floor of 1 is **not** repaired by this change. Read the replaced paragraph and confirm it still says so.

- [ ] **Step 5: Parity** for both sites.

- [ ] **Step 6: Commit**

```bash
git add CLAUDE.md plugins/dev-workflow/commands/workflow-init.md
git commit -m "WIP: correct the Named residual's blanket exemption and the work-loop sequence"
```

---

## Task 10: Replace the seven hook reminder strings

**Files:**
- Modify: `plugins/dev-workflow/hooks/codex-gate.sh`

**The bytes:** target §F items 10, 11, 12, 13, 15, 16 and 17. **Items 12, 15 and 16 give the complete resulting text for both channels**; items 10, 11, 13 and 17 give replacement sentences inside an otherwise unchanged message.

**Shell constraint, and it is not advisory:** every string installs into a double-quoted `note` argument. No backtick, no `$(`, no backslash, no double quote. A backtick reached §F once and would have executed `WIP` at install time, shipped the reminder with the word missing, and failed ShellCheck — while the fixture copied from it would have made the suite pass on the corruption.

- [ ] **Step 1: Verify the constraint before installing**

```bash
# For each of the seven §F blocks, confirm the text you are about to install is clean:
printf '%s' "<the block>" | grep -nE '`|\$\(|\\\\|"' && echo HAZARD || echo clean
```

Expected: `clean` seven times. A hit here stops the task.

- [ ] **Step 2: Locate the seven `note` calls**

```bash
grep -n 'note "' plugins/dev-workflow/hooks/codex-gate.sh
```

Expected: thirteen hits. Seven are the gate reminders this task edits; four take a pre-built variable (`$FAILURE_CTX`, `$NORESULT_CTX`, `$BG_SHORT_CTX`, `$BG_LONG_CTX`), one is the tool-state echo, and one is the **docs-only notice, which is deliberately untouched** — it states no closure permission.

- [ ] **Step 3: Install the seven replacements, one at a time**

- [ ] **Step 4: Confirm no behaviour changed**

```bash
git diff plugins/dev-workflow/hooks/codex-gate.sh | grep -E '^[-+]' | grep -vE '^[-+]\s*(note "|[A-Za-z ,.—;:()/$-]+")' | head
```

Expected: only the `---`/`+++` header lines. **Any changed line that is not inside a `note` string is out of scope** — no control flow, no counter, no fingerprint computation, no routing (invariant 4, design §8).

- [ ] **Step 5: Discriminating pairs, worktree and parent**

The hook has one copy and owes no parity check; **the hook suite's exact-match assertion is this edit's second observation** (design §7). Run the pair anyway:

```bash
for pair in 'this floor is the only thing keeping the spec review honest|instruction-backed' \
            'commit only if your final pass was clean — no new Blocker/Major|every other closure condition holds' \
            'then make the real commit when your final pass is clean|Use this commit as the review range' \
            'STOP — Codex Gate B not satisfied|Codex gate state:' ; do
  OLD=${pair%%|*}; NEW=${pair##*|}
  printf 'old/worktree=%s old/parent=%s new/worktree=%s new/parent=%s  %s\n' \
    "$(grep -cF "$OLD" plugins/dev-workflow/hooks/codex-gate.sh)" \
    "$(git show "$BASE:plugins/dev-workflow/hooks/codex-gate.sh" | grep -cF "$OLD")" \
    "$(grep -cF "$NEW" plugins/dev-workflow/hooks/codex-gate.sh)" \
    "$(git show "$BASE:plugins/dev-workflow/hooks/codex-gate.sh" | grep -cF "$NEW")" "$OLD"
done
```

Expected: `old/worktree=0`, `old/parent` ≥ 1, `new/worktree` ≥ 1, `new/parent=0` for each. The `STOP` pair covers two messages, so its counts are 2 rather than 1 — **state the number you observed rather than asserting it**.

- [ ] **Step 6: ShellCheck**

```bash
shellcheck --shell=sh plugins/dev-workflow/hooks/codex-gate.sh
```

Expected: exit 0, no output. The suite will fail at this point because the expectations still pin the old strings — that is Task 11.

- [ ] **Step 7: Commit**

```bash
git add plugins/dev-workflow/hooks/codex-gate.sh
git commit -m "WIP: replace the seven gate reminders the ordering falsifies"
```

---

## Task 11: Sweep `codex-gate.test.sh` for every assertion naming a replaced string

**Files:**
- Modify: `plugins/dev-workflow/hooks/codex-gate.test.sh`

**There is no list of these assertions and building one here would repeat a defect.** §F states the duty and deliberately states no count: it twice named one and was twice wrong — "the exact-match expectation" where there are three, and "the remaining are matched by loose patterns these repairs leave standing" where `Gate B satisfied` occurs 21 times and `STOP` 14. **Sweep the file; do not work from a number.**

- [ ] **Step 1: Find every site**

```bash
grep -n 'expected_ctx=\|expected_msg=' plugins/dev-workflow/hooks/codex-gate.test.sh
grep -n 'Gate B satisfied\|Gate B not satisfied\|STOP\|no recorded review\|cannot confirm review\|only thing keeping\|no new Blocker/Major' plugins/dev-workflow/hooks/codex-gate.test.sh
```

**Record the counts you observe.** They will not match the numbers above if the file has changed; the numbers above are evidence for why no list is kept, not a target.

- [ ] **Step 2: Update the three `expected_ctx` and three `expected_msg` assignments**

Each takes the complete resulting text of its message from §F items 12, 15 and 16, with `$policy` rendered as the suite renders it (`this project's review policy`) and the counters as the fixture sets them.

- [ ] **Step 3: Update every loose assertion, test label and comment that names a replaced string**

Each must test **the observed hook state** rather than a gate verdict — `hook checks passed`, `no recorded fingerprint`, `cannot confirm reviewed content` — matching what Task 10 installed. **A label left saying "satisfied" is a test vocabulary that still calls the gate satisfied**, which is the claim this change removes.

- [ ] **Step 4: Run the suite under both shells**

```bash
HOOK_SH=sh sh plugins/dev-workflow/hooks/codex-gate.test.sh && \
HOOK_SH=dash dash plugins/dev-workflow/hooks/codex-gate.test.sh
```

Expected: exit 0 from both. **`HOOK_SH` selects the shell the hook runs under; without it a `dash` invocation only exercises the harness.** Ubuntu's `/bin/sh` is dash, and dropping this second run is what let a dash-only defect ship once already.

- [ ] **Step 5: Confirm no verdict vocabulary survives**

```bash
grep -n 'Gate B satisfied\|Gate B not satisfied' plugins/dev-workflow/hooks/codex-gate.test.sh
```

Expected: no hits, or only hits you can justify one by one in the commit body.

- [ ] **Step 6: ShellCheck the test file**

```bash
shellcheck --shell=sh --exclude=SC2015 plugins/dev-workflow/hooks/codex-gate.test.sh
```

Expected: exit 0. **The `--exclude=SC2015` is a single-code exclusion**, not a blanket disable; every other rule still applies.

- [ ] **Step 7: Commit**

```bash
git add plugins/dev-workflow/hooks/codex-gate.test.sh
git commit -m "WIP: move every hook assertion that names a replaced reminder string"
```

---

## Task 12: The `b11`/`b13` equivalence check

**Files:** none modified (unless the check fails).

**Interfaces:**
- Consumes: the installed §A block and the installed passage (b).

Design §6 requires a second check **within each copy**: that `b11` and `b13` as edited say what the ordering cites them as saying, **comparing the complete predicates and not a shared phrase** — including `b11`'s already-declined exception and `b13`'s already-answered qualification, in both directions.

- [ ] **Step 1: Extract what the ordering cites**

Read §A's continue branch and its scope-trigger references, and write down, in full, the predicate it attributes to the absorb paragraph.

- [ ] **Step 2: Extract what the absorb paragraph states**

Read the installed passage (b) and write down, in full, the predicate it defines for each of `b11` and `b13`.

- [ ] **Step 3: Compare in both directions**

A condition **in the block and not in the source** ships two triggers that disagree. A condition **in the source and not in the block** means the block cites a rule it has not read. Both are failures.

- [ ] **Step 4: Repeat for the second copy**

The two copies are byte-identical over this material, so a divergence here is a parity failure and belongs to Task 14.

- [ ] **Step 5: Record the result** — it goes in the evidence entry verbatim. **No commit** unless the check failed and you repaired something.

---

## Task 13: The next-state table and the per-condition closure checks

**Files:**
- Modify: this plan (the table lives here; design §7)

**What the table claims, at exactly this width:** it covers **answer-state transitions once the predicates producing them are established**. It does **not** establish how each predicate was derived — a wrongly derived predicate produces a row that passes — nor whether the rows cover every reachable combination of the clean, scope and health predicates. **The evidence entry states the claim at this width and no wider**; closing either gap is the parked fixture-per-predicate question, which this change does not reopen.

**The oracle.** A row **fails** when its required answer does not produce a **distinct** resumable or closed state — the same stop returning with its reading unconsumed, that is, without an intervening validated pass run after the answer — or when it closes on anything other than the route the block states. **Read the closure conditions and the routes off the installed §A, not from this plan** — an embedded copy can pass while disagreeing with the text it checks.

- [ ] **Step 1: Enumerate the rows**

One row per (starting state, answer) pair the installed ordering admits. At minimum, and **this is a floor rather than the set**: a clean eligible pass with every condition met; a clean eligible pass with an unmet precondition; a clean pass below the floor; a zero-finding pass below the floor; a pass carrying a membership trigger, answered accept and answered decline; a pass carrying a new-question trigger, answered; a pass carrying both; a two-tell stop, answered; a clearly-stuck surface, answered; a source block raised before any pass was read; a source block raised on a pass already read; a closing act that does not complete and is repaired; a closing act that cannot be repaired; a `full` Gate-B pass with one branch clean and one not; the same complaint in both branch files under each of accept/accept, accept/decline, decline/accept and decline/decline.

- [ ] **Step 2: Walk each row against the installed §A and record the next state**

- [ ] **Step 3: Apply the oracle to each row** and mark pass or fail.

- [ ] **Step 4: Write one named check per closure condition the block states**

**Read the set off the block and write one check per condition.** **Fail this task where the block states a condition you have no check for** — an enumeration here is how design §7 came to name three conditions while the block stated more.

- [ ] **Step 5: Write the separate named checks the table does not cover**

Two, per design §7: that a logical pass was validated across every required branch file, and that every closure condition the block states held at the closing act.

- [ ] **Step 6: Commit**

```bash
git add docs/superpowers/plans/2026-09-14-loop-rule-consolidation.md
git commit -m "WIP: next-state table and per-condition closure checks"
```

---

## Task 14: The parity diff and the divergence list

**Files:** possibly `CLAUDE.md` and `plugins/dev-workflow/commands/workflow-init.md`.

Design §6: the two copies must agree on every rule this change ships. **The plan carries the divergence list** — which pre-existing wording differences are deliberate and stay, which are not and are aligned — **and performs the extraction and diff, passage by passage, against the real files.**

**One divergence is decided by the design and is not a judgement call:** W's `b3` pointer names "the severity rule" on the inventory's reasoning that W has no Mechanics section, **which is false** — so **W takes C's wording** (design §6, target §B).

- [ ] **Step 1: Extract and diff each changed passage**

```bash
for anchor in 'How a cycle ends' 'What a loop absorbs' 'Recognizing "clearly stuck"' \
              'Those three lines expose' '\*\*Severity:\*\*' 'Surfacing does not close' \
              'When these rules bind' 'Named residual' 'The work loop includes'; do
  echo "== $anchor"
  diff <(grep -A25 -E "$anchor" CLAUDE.md) \
       <(grep -A25 -E "$anchor" plugins/dev-workflow/commands/workflow-init.md)
done
```

- [ ] **Step 2: Classify every difference the diff reports**

Three buckets: **deliberate and stays** (the field-mint parenthetical, e11, f5–f7's evidence framing, e8's pronoun — each recorded in the inventory); **not deliberate, align it**; **introduced by this change, fix it**. Write the list into this plan.

- [ ] **Step 3: Apply W's `b3` alignment**

- [ ] **Step 4: Re-run the diff** and confirm only the deliberate divergences remain.

- [ ] **Step 5: Commit**

```bash
git add CLAUDE.md plugins/dev-workflow/commands/workflow-init.md docs/superpowers/plans/2026-09-14-loop-rule-consolidation.md
git commit -m "WIP: align the two copies and record the divergence list"
```

---

## Task 15: Version bump, CHANGELOG, battery, evidence, Gate B

**Files:**
- Modify: `plugins/dev-workflow/.claude-plugin/plugin.json`
- Modify: `plugins/dev-workflow/CHANGELOG.md`

**Mode:** read from the story header at execution. It was `battery+check+verification` at the time this plan was written; **read it fresh** — the header is the only writable copy and this plan carries the path, not the value.

- [ ] **Step 1: Bump the version**

```bash
grep -n '"version"' plugins/dev-workflow/.claude-plugin/plugin.json
```

`0.11.0 → 0.12.0` — a **minor** bump: the template gains a closure ordering, the edited sentences, and the seven hook reminder strings. The hook edits add no bump the template did not already require.

- [ ] **Step 2: Add the CHANGELOG entry**, newest first, naming the ordering, the falsified-sentence replacements and the hook reminder strings.

- [ ] **Step 3: Commit the bump into the WIP snapshot**

```bash
git add plugins/dev-workflow/.claude-plugin/plugin.json plugins/dev-workflow/CHANGELOG.md
git commit -m "WIP: bump dev-workflow to 0.12.0"
```

`scripts/check-version-bump.sh` compares **commits**, so the bump must be committed before the battery runs.

- [ ] **Step 4: Run the full quality battery**

```bash
shellcheck --shell=sh plugins/dev-workflow/hooks/codex-gate.sh && \
shellcheck --shell=sh --exclude=SC2015 plugins/dev-workflow/hooks/codex-gate.test.sh && \
shellcheck --shell=sh scripts/check-invariants.sh && \
shellcheck --shell=sh --exclude=SC2015 scripts/check-invariants.test.sh && \
shellcheck --shell=sh scripts/check-version-bump.sh && \
shellcheck --shell=sh scripts/check-version-bump.test.sh && \
HOOK_SH=sh sh plugins/dev-workflow/hooks/codex-gate.test.sh && \
HOOK_SH=dash dash plugins/dev-workflow/hooks/codex-gate.test.sh && \
sh scripts/check-invariants.test.sh && sh scripts/check-invariants.sh && \
sh scripts/check-version-bump.test.sh && sh scripts/check-version-bump.sh main && \
claude plugin validate . --strict
```

Expected: exit 0. **`check-invariants.sh` includes the prompt-conformance checks** — a `Target model:` line naming one recognized model, a prose checklist-count claim matching the checklist, and the finding-severity vocabulary as a closed set in both prompt copies. Those three are a floor, not coverage; invariant 11's other eleven items are judged by a reader.

- [ ] **Step 5: Write the evidence entry into the WIP commit body**

It names: the battery run; **every pair this plan built, with its counts in each copy and each tree, and every presence check beside them**; the §6 parity diff and the `b11`/`b13` equivalence result; and the next-state table's location plus its row count. **State the §A presence checks as presence, not as pairs** — its counterfactual is absent and is claimed as absent.

- [ ] **Step 6: Run Gate B**

```bash
git rev-parse HEAD          # the WIP commit
git rev-parse HEAD^         # baseSha
```

`mcp__codex__review` with `reviewType: full`, `baseSha` = the WIP commit's parent, `headSha` = the full 40-character object name `HEAD` resolves to **at that moment**, resolved once and kept with each branch's result. Carry the story path and the evidence entry quoted verbatim. Write findings to `.context/codex-reviews/gate-b-<spec|quality>-<nonce>-pass-<p>.md` — **draw a fresh nonce for this cycle**; it is a different cycle from `awsf1ec771`.

**Standing lens, every call:** "which existing statements does this diff falsify?" and **name what this diff changes the size, value or position of** — a list, a count, a version, an identifier, a cited line — then grep for where each is described elsewhere.

- [ ] **Step 7: Loop to a clean pass at or above the derived floor**

Floor derives from the story profile: risk `high` → 2, security `none` → 0, max 2 ≠ 0 → **floor 3**. Re-derive it at each pass from the header. Fix Blocker/Major after each pass; re-review after every fix. **Revalidate the evidence entry before every re-review and before the closing amend.**

**A fix that changes specified behaviour updates the spec in the same commit.**

- [ ] **Step 8: Close the cycle**

```bash
git reset --soft <parent-of-first-WIP>
git commit -m "<real message>"
```

The closing body carries: the validated evidence entry; the provenance line; the per-pass curve; and any human-exception record. **Amend rather than a follow-up commit** — a `WIP:` commit left in history defeats the convention, and a follow-up has nothing to commit when the review produced no fixes.

---

## Self-Review

**1. Spec coverage.** §A → Task 1. §B → Task 3. §C → Task 4. §D → Task 5. §E → Task 6. §F items 1–9 → Task 8; items 14, 18 → Task 9; items 10–13, 15–17 → Task 10 with its test sweep in Task 11. §G → Task 7, **added by this review**: the first draft gave the one-contract paragraph no task, though design §4 lists it as its own site and target §G carries its replacement. It is a prompt-copy replacement in both copies with the same shape as §H's blocks, owes the same discriminating pair with OLD `These rules and records are one contract`, and sits at C 879 / W 1063 as of this writing. §H → Task 7. §I ships nowhere and needs no task. Design §6 → Task 14. Design §7 → Tasks 13 and 15. Design §8 → Task 15's battery and the Global Constraints. Story AC 5 → the disposition tables. Story AC 4 → Task 13.

**2. Placeholder scan.** The replacement text is cited rather than copied, deliberately and for the reason the Architecture note gives. Every verification step carries a runnable command and an expected value. Task 13's row list is explicitly a floor rather than a closed set, and says so. Task 11 deliberately carries no count, and says why.

**3. Type consistency.** `$BASE` is set in Task 0 and used in Tasks 1–10. The four-value pair shape (`new/worktree`, `new/parent`, `old/worktree`, `old/parent`) is defined in Task 3 and referred to by name afterwards. Condition ids match the inventory throughout: a1–a22, b1–b18, c1–c20, d1–d7, e1–e11, f1–f7, g1–g4, h1–h26, i1–i16, j1–j4 — 135 total, every one dispositioned above.

**One correction applied from this review:** §G was missing a task; it is now installed by Task 7, which names nine sites rather than eight.

**One residual this plan does not close, stated rather than left to be found.** Nothing here establishes that the edit set is complete — it is the sites §F knows, and §F's own §I records that it cannot establish completeness either. Task 8's step 1 re-derives every citation against the real file, and Task 14's diff catches a copy that fell out of step; neither is a completeness check. The sweep for an affected site this text has not found is design §7's, owed by whoever executes, and a site found during execution is a finding against the spec rather than a gap in this plan.
