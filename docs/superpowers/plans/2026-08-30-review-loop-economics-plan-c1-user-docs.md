# Plan C1 — the user-facing floor description

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development
> (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use
> checkbox (`- [ ]`) syntax for tracking.

**Goal:** Correct every sentence in `README.md` and `docs/getting-started.md` that Plan A makes
false about **where the pass floor comes from**. Seven sentences, two files, one claim.

**Spec:** `docs/superpowers/specs/2026-08-28-review-loop-economics-design.md` (revision 36).
C1 implements the part of §7 that lands in the user-facing docs.

**Story:** `docs/superpowers/stories/2026-08-28-review-loop-economics-pass-floor-story.md`

> **Read the profile from that header at execution time.** This plan states no risk value, no
> security value, no validation mode and no pass count derived from any of them. The evidence
> the mode requires is produced by Plan C3, which runs the one Gate-B cycle.

---

## Why this plan is small

Plan C tried to carry this rollout, the packaging, the evidence and the Gate-B cycle in one
artifact. Its Gate-A cycle **ran seven passes and never converged** — Blocker/Major stayed
between 15 and 21, and the last pass was the worst. The record is
`.context/codex-reviews/gate-a-plan-planc-CLOSURE.md`. Daniel split it by statement site.

**C1 is the first of three.** C2 takes the packaging and the hook-message description; C3 takes
the evidence, the Gate-B cycle and the close.

### The one claim this plan owns

**"Three passes" is not the floor; the floor is derived from the cited story's profile, and the
`codex-gate.floor` knob moves the hook's reminder threshold rather than that floor.**

Seven sentences state it wrongly. They are the complete set in these two files, found by
grepping the **claim** — every place a number of passes, a floor, or the knob is described —
not by grepping a phrase.

### What this plan does not own, so that nothing falls between the three

| Not here | Where | Why not here |
|---|---|---|
| `docs/getting-started.md:58`, the satisfied-message example | **C2** | It describes what the hook's message *reports* — three numbers and their meanings. A different claim in the same file. |
| `docs/coding-workflow.md` — the axes sentence and the model-recording sentence | **unassigned** | Neither a C1 file nor packaging nor the close. **Flagged, not absorbed.** |
| The skipped-cycle duty sentence in five files, `getting-started.md` among them | **unassigned** | One claim across `process-pr-review.md`, `CLAUDE.md`, the scaffolded template and both explanatory summaries. Splitting it by file would recreate the defect it exists to fix. **Flagged, not absorbed.** |
| The parser claim, the slot rule, spec §8 | **C3** | Named in C3's site list, including the two shipped prompt copies Plan C's sweep missed. |

**The two unassigned rows are a real gap in the split and are named rather than quietly taken.**
Absorbing them here would make C1 a second Plan C.

---

## Global Constraints

- **These edits join the open cycle.** Every task amends the WIP commit with
  `-m "WIP: review-loop economics"`. `plugins/dev-workflow/hooks/codex-gate.sh:763` recognizes a
  WIP commit by grepping the Bash command string for `-m ... wip`; an amend without `-m` is not
  recognized and the hook resets, discarding the cycle's passes. **Never
  `git commit --amend --no-edit`.**
- **`git add` names paths explicitly, never `-u`.**
- **No ordinary commit until C3 closes the cycle.**
- **Line numbers are provenance, never instructions.**
- **Preflight and assert are different commands.** The preflight decides whether to apply and
  `0` is a valid answer meaning *apply*; the assert tests the result and anything but `1` fails.
  Each task carries both, instantiated with its own file and string — no template.
- **Neither file is touched by Plan A or Plan B**, so every anchor below was verified against
  the **current** tree, not a simulated one.

---

## Old-conditions accounting

For each sentence: what it asserted, and what replaces it.

| # | Sentence | What it asserted | Disposition |
|---|---|---|---|
| 1 | `README.md:130` knob row | the knob moves the 3-passes-per-gate floor | **false as of Plan A** — it moves the hook's reminder threshold and never bound an agent. Replaced, with the distinction stated |
| 2 | `getting-started.md:34` Gate-A loop | three passes minimum | **replaced** by the derived floor. "final pass clean" and the zero-finding early exit are **kept** |
| 3 | `getting-started.md:40` plan loop | the same 3-pass loop | **replaced**; the rest of the sentence kept |
| 4 | `getting-started.md:44` below-floor message | the hook reports that the Gate-A floor wasn't met | **false** — it reports its own threshold, which at a derived floor of 1 announces a shortfall the cycle does not owe. Replaced |
| 5 | `getting-started.md:53` Gate-B loop | three passes, final clean | **replaced** by the derived floor; "final clean" **kept** |
| 6 | `getting-started.md:84` axes sentence | the axes never subtract **and** the floor is unchanged at every level | first clause **kept** — true, and the point; second **deliberately dropped**, since this change is what makes the floor vary |
| 7 | `getting-started.md:86` second knob mention | the knob moves the 3-pass floor | **false**, same as row 1. Both sites corrected, because fixing one leaves the other teaching it |

**Rows 1 and 7 are one claim in two places, and rows 2, 3 and 5 are one claim in three.** That is
why they are in one plan: a fix to any one of them alone leaves the others contradicting it.

---

## Task 1: The knob row in `README.md`

**File:** `README.md`

**Site** — pasted `grep -n`:

```
README.md:130:| `codex-gate.floor` | a positive integer; moves the 3-passes-per-gate floor. |
```

> The knob never bound an agent. `$floor` appears in the hook's control flow, but that flow only
> selects which advisory message fires, and the hook exits 0 on every branch. This line was the
> clearest statement of the wrong model anywhere in the docs.

- [ ] **Preflight.**

```sh
case "$(grep -cF -- "moves the hook's reminder threshold. It does not change the floor" README.md)" in
  0) : ;;
  1) echo "ALREADY APPLIED — skip"; exit 0 ;;
  *) echo "AMBIGUOUS — stop"; exit 1 ;;
esac
```

- [ ] **Replace.** OLD:

```
| `codex-gate.floor` | a positive integer; moves the 3-passes-per-gate floor. |
```

NEW:

```
| `codex-gate.floor` | a positive integer; moves the hook's reminder threshold. It does not change the floor §5 obliges, which is derived from the cited story's profile. |
```

- [ ] **Assert.**

```bash
test "$(grep -cF -- "moves the hook's reminder threshold. It does not change the floor" README.md)" -eq 1 || { echo "ASSERT FAILED"; exit 1; }
test "$(grep -cF -- "moves the 3-passes-per-gate floor" README.md)" -eq 0 || { echo "OLD TEXT SURVIVES"; exit 1; }
```

- [ ] **Amend.**

```bash
git add README.md
git commit --amend -m "WIP: review-loop economics"
```

---

## Task 2: The Gate-A loop description

**File:** `docs/getting-started.md`

**Site** — pasted `grep -n`:

```
docs/getting-started.md:34:three passes minimum, final pass clean — the one early exit is a pass that comes
```

- [ ] **Preflight.**

```sh
case "$(grep -cF -- "the floor its profile derives, final pass clean" docs/getting-started.md)" in
  0) : ;;
  1) echo "ALREADY APPLIED — skip"; exit 0 ;;
  *) echo "AMBIGUOUS — stop"; exit 1 ;;
esac
```

- [ ] **Replace.** OLD:

```
three passes minimum, final pass clean — the one early exit is a pass that comes
back with zero findings.
```

NEW:

```
the floor its profile derives, final pass clean — the one early exit is a pass that
comes back with zero findings.
```

- [ ] **Assert.**

```bash
test "$(grep -cF -- "the floor its profile derives, final pass clean" docs/getting-started.md)" -eq 1 || { echo "ASSERT FAILED"; exit 1; }
test "$(grep -cF -- "three passes minimum" docs/getting-started.md)" -eq 0 || { echo "OLD TEXT SURVIVES"; exit 1; }
```

- [ ] **Amend.**

```bash
git add docs/getting-started.md
git commit --amend -m "WIP: review-loop economics"
```

---

## Task 3: The plan-loop sentence

**File:** `docs/getting-started.md`

**Site** — pasted `grep -n`:

```
docs/getting-started.md:40:task-by-task plan (each task starts with a failing test); the same 3-pass loop runs
```

- [ ] **Preflight.**

```sh
case "$(grep -cF -- "the same loop runs at the derived floor" docs/getting-started.md)" in
  0) : ;;
  1) echo "ALREADY APPLIED — skip"; exit 0 ;;
  *) echo "AMBIGUOUS — stop"; exit 1 ;;
esac
```

- [ ] **Replace.** OLD:

```
task-by-task plan (each task starts with a failing test); the same 3-pass loop runs
```

NEW:

```
task-by-task plan (each task starts with a failing test); the same loop runs at the derived floor
```

- [ ] **Assert.**

```bash
test "$(grep -cF -- "the same loop runs at the derived floor" docs/getting-started.md)" -eq 1 || { echo "ASSERT FAILED"; exit 1; }
test "$(grep -cF -- "the same 3-pass loop runs" docs/getting-started.md)" -eq 0 || { echo "OLD TEXT SURVIVES"; exit 1; }
```

- [ ] **Amend.**

```bash
git add docs/getting-started.md
git commit --amend -m "WIP: review-loop economics"
```

---

## Task 4: The below-floor hook message

**File:** `docs/getting-started.md`

**Site** — pasted `grep -n`:

```
docs/getting-started.md:44:progress claims backed by test runs. If the Gate-A floor wasn't met, the hook says
```

> The hook reports against its **own threshold**, not against what the cycle owes. At a derived
> floor of 1 it announces a shortfall the cycle does not have — the named residual of this
> change, and this sentence is where a reader would otherwise learn the opposite.

- [ ] **Preflight.**

```sh
case "$(grep -cF -- "If the hook's own threshold wasn't met, it says" docs/getting-started.md)" in
  0) : ;;
  1) echo "ALREADY APPLIED — skip"; exit 0 ;;
  *) echo "AMBIGUOUS — stop"; exit 1 ;;
esac
```

- [ ] **Replace.** OLD:

```
progress claims backed by test runs. If the Gate-A floor wasn't met, the hook says
```

NEW:

```
progress claims backed by test runs. If the hook's own threshold wasn't met, it says
```

- [ ] **Assert.**

```bash
test "$(grep -cF -- "If the hook's own threshold wasn't met, it says" docs/getting-started.md)" -eq 1 || { echo "ASSERT FAILED"; exit 1; }
test "$(grep -cF -- "If the Gate-A floor wasn't met, the hook says" docs/getting-started.md)" -eq 0 || { echo "OLD TEXT SURVIVES"; exit 1; }
```

- [ ] **Amend.**

```bash
git add docs/getting-started.md
git commit --amend -m "WIP: review-loop economics"
```

---

## Task 5: The Gate-B loop description

**File:** `docs/getting-started.md`

**Site** — pasted `grep -n`:

```
docs/getting-started.md:53:`mcp__codex__review` the same way: three passes, final clean. Verification is by
```

- [ ] **Preflight.**

```sh
case "$(grep -cF -- "the derived floor, final clean. Verification is by" docs/getting-started.md)" in
  0) : ;;
  1) echo "ALREADY APPLIED — skip"; exit 0 ;;
  *) echo "AMBIGUOUS — stop"; exit 1 ;;
esac
```

- [ ] **Replace.** OLD:

```
`mcp__codex__review` the same way: three passes, final clean. Verification is by
```

NEW:

```
`mcp__codex__review` the same way: the derived floor, final clean. Verification is by
```

- [ ] **Assert.**

```bash
test "$(grep -cF -- "the derived floor, final clean. Verification is by" docs/getting-started.md)" -eq 1 || { echo "ASSERT FAILED"; exit 1; }
test "$(grep -cF -- "the same way: three passes, final clean" docs/getting-started.md)" -eq 0 || { echo "OLD TEXT SURVIVES"; exit 1; }
```

- [ ] **Amend.**

```bash
git add docs/getting-started.md
git commit --amend -m "WIP: review-loop economics"
```

---

## Task 6: The axes sentence

**File:** `docs/getting-started.md`

**Site** — pasted `grep -n`:

```
docs/getting-started.md:84:is still owed and Gate A's floor is unchanged at every level. The caution bias is
```

> **Two claims were tangled in one sentence.** That the axes never subtract is true and stays.
> That the floor is unchanged at every level is exactly what this change makes false. Separated
> rather than reworded, so the surviving clause is visibly the one that survived.

- [ ] **Preflight.**

```sh
case "$(grep -cF -- "Gate A's floor derives from the profile exactly as Gate B's does" docs/getting-started.md)" in
  0) : ;;
  1) echo "ALREADY APPLIED — skip"; exit 0 ;;
  *) echo "AMBIGUOUS — stop"; exit 1 ;;
esac
```

- [ ] **Replace.** OLD:

```
is still owed and Gate A's floor is unchanged at every level. The caution bias is
```

NEW:

```
is still owed; Gate A's floor derives from the profile exactly as Gate B's does, and what the axes never subtract is the baseline questions. The caution bias is
```

- [ ] **Assert.**

```bash
test "$(grep -cF -- "Gate A's floor derives from the profile exactly as Gate B's does" docs/getting-started.md)" -eq 1 || { echo "ASSERT FAILED"; exit 1; }
test "$(grep -cF -- "Gate A's floor is unchanged at every level" docs/getting-started.md)" -eq 0 || { echo "OLD TEXT SURVIVES"; exit 1; }
```

- [ ] **Amend.**

```bash
git add docs/getting-started.md
git commit --amend -m "WIP: review-loop economics"
```

---

## Task 7: The second knob mention

**File:** `docs/getting-started.md`

**Site** — pasted `grep -n`:

```
docs/getting-started.md:86:positive integer) moves the 3-pass floor, and `touch .context/codex-gate.off`
```

> The same correction as Task 1, in the second place the docs describe the knob. **Both sites say
> the same wrong thing**, and this repo's own record is that a fix to one has never implied a fix
> to the other.

- [ ] **Preflight.**

```sh
case "$(grep -cF -- "moves the hook's reminder threshold, and" docs/getting-started.md)" in
  0) : ;;
  1) echo "ALREADY APPLIED — skip"; exit 0 ;;
  *) echo "AMBIGUOUS — stop"; exit 1 ;;
esac
```

- [ ] **Replace.** OLD:

```
positive integer) moves the 3-pass floor, and `touch .context/codex-gate.off`
```

NEW:

```
positive integer) moves the hook's reminder threshold, and `touch .context/codex-gate.off`
```

- [ ] **Assert.**

```bash
test "$(grep -cF -- "moves the hook's reminder threshold, and" docs/getting-started.md)" -eq 1 || { echo "ASSERT FAILED"; exit 1; }
test "$(grep -cF -- "moves the 3-pass floor" docs/getting-started.md)" -eq 0 || { echo "OLD TEXT SURVIVES"; exit 1; }
```

- [ ] **Amend.**

```bash
git add docs/getting-started.md
git commit --amend -m "WIP: review-loop economics"
```

---

## Task 8: Confirm the claim has no eighth site

**Runs last.** The seven tasks above were found by grepping the claim. This re-runs that grep
against the finished files, so the plan's completeness is a check rather than an assertion.

- [ ] **No stale floor language survives in either file.**

```bash
if grep -nEi '3-pass|three passes|3 passes|3-passes-per-gate' README.md docs/getting-started.md; then
  echo "A FLOOR CLAIM SURVIVES — read the hits printed above"; exit 1
fi
```

> **What this catches and what it does not.** It catches the wrong claim in the spellings this
> repo has actually used. It does **not** catch a sentence asserting a fixed floor without a
> number — *"the loop always runs the same number of times"* would pass. That residue is a
> reading, and it is named here rather than covered by implication.

- [ ] **The knob is described identically in both files.** Both say it moves the hook's
  reminder threshold; neither says it moves the floor.

```bash
test "$(grep -cF -- "moves the hook's reminder threshold" README.md)" -eq 1 || { echo "README KNOB LINE WRONG"; exit 1; }
test "$(grep -cF -- "moves the hook's reminder threshold" docs/getting-started.md)" -eq 1 || { echo "GETTING-STARTED KNOB LINE WRONG"; exit 1; }
```

- [ ] **Amend** if either check produced a fix; otherwise nothing to stage.

---

## Self-Review

**Scope.** Seven sentences, two files, one claim. Every anchor verified against the current
tree — neither file is touched by Plan A or Plan B, so no simulation was needed and none is
claimed.

**Every assert is two commands, not one:** the new text present exactly once, and the old text
gone. Plan C's Gate-A cycle spent a Major on the single-sided version of this, where a sentinel
counted `1` in a file that still carried the text it replaced.

**Task 8 is the completeness check, and it is deliberately weaker than the claim it checks.**
It greps the spellings this repo has used, and says so. A fixed-floor assertion phrased without
a number escapes it. That limit is stated rather than left for a reviewer to discover.

**What this plan does not do.** It ships no rule, touches no prompt, produces no evidence and
runs no Gate-B cycle. The evidence the story's mode requires is C3's, and one combined Gate-B
cycle covers A, B, C1, C2 and C3 together.

**Known limit.** Gate A reviews this plan, not the edits. What the edits do is Gate B's.
