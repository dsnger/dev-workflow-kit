# Plan C1 — the user-facing floor description

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development
> (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use
> checkbox (`- [ ]`) syntax for tracking.

**Goal:** Correct every sentence in `README.md` and `docs/getting-started.md` that Plan A makes
false about **where the pass floor comes from**. Eight sentences, two files, one claim.

**Spec:** `docs/superpowers/specs/2026-08-28-review-loop-economics-design.md` (revision 36).
C1 implements the part of §7 that lands in these two user-facing docs.

**Story:** `docs/superpowers/stories/2026-08-28-review-loop-economics-pass-floor-story.md`

> **Read the profile from that header at execution time.** This plan states no risk value, no
> security value, no validation mode and no pass count derived from any of them. The evidence the
> mode requires is produced by Plan C3, which runs the one Gate-B cycle.

---

## Why this plan is small

Plan C tried to carry this rollout, the packaging, the evidence and the Gate-B cycle in one
artifact. Its Gate-A cycle **ran seven passes and never converged** — Blocker/Major stayed between
15 and 21, and the last pass was the worst. The record is
`.context/codex-reviews/gate-a-plan-planc-CLOSURE.md`. Daniel split it by statement site.

**C1 is the first of three.** C2 takes the packaging and the satisfied-message description; C3
takes the evidence, the Gate-B cycle and the close.

### The one claim this plan owns

**"Three passes" is not the floor. §5 derives the floor from the profile and the cited set, and
the `codex-gate.floor` knob moves the hook's reminder threshold rather than that floor.**

**The source is a set, not a story**, and the replacements say so in Plan A's own words. Plan A
derives one value from the current governing cited-story set: **1 only if every cited story is
level 0**; **3 if no story is cited or any cited story is unprofiled**; and a present-but-
unresolvable profile **stops** rather than defaulting. A phrase like *"the cited story's profile"*
is false on three of those four states, which is why it appears nowhere below.

Eight sentences state the claim wrongly. They are the complete set in these two files, found by
grepping the **claim** — every place a number of passes, a floor, a threshold or the knob is
described — not by grepping a phrase. Task 9 re-runs that grep against the finished files.

### What this plan does not own, so that nothing falls between the pieces

| Not here | Where | Why not here |
|---|---|---|
| `docs/getting-started.md:58`, the satisfied-message example | **C2** | It describes what the hook's message *reports* — three numbers, three meanings. A different claim in the same file. The below-floor examples at lines 35 and 44 are **not** that claim and are Tasks 3 and 5 here. |
| CHANGELOG entry, manifest bump, the item-1 n/a sentence | **C2** | Packaging. |
| The parser claim, the findings-slot rule, spec §8, the evidence pack, the Gate-B cycle, the close, the field report | **C3** | C3's site list must name the two shipped prompt copies carrying *"because the deferred metrics work parses it"* — the two sites Plan C's own claim sweep missed. |
| `docs/coding-workflow.md` — the axes sentence and the model-recording sentence | **UNASSIGNED** | Neither a C1 file, nor packaging, nor the close. |
| The skipped-cycle duty sentence in five files | **UNASSIGNED** | One claim across `process-pr-review.md`, `CLAUDE.md`, the scaffolded template and both explanatory summaries. |

**The two unassigned rows are a real gap in the split, and they block the combined close rather
than this plan.** The story requires every falsified shipped sentence corrected in the same
change, so C3 cannot close while they have no owner. They are named here, routed to Daniel, and
**not absorbed** — taking them would make C1 a second Plan C, which is the thing the split exists
to prevent.

---

## Global Constraints

- **These edits join the open cycle.** Every task amends the WIP commit with
  `-m "WIP: review-loop economics"`. `plugins/dev-workflow/hooks/codex-gate.sh:763` recognizes a
  WIP commit by grepping the Bash command string for `-m ... wip`. **An amend the hook does not
  recognize as WIP is treated as a Gate-B cycle boundary and the cycle's Gate-B state is reset —
  regardless of whether the commit itself succeeded**, since that branch cannot observe exit
  status. Gate-A state is reset by skill events, not here. **Never `git commit --amend --no-edit`.**
- **Every task checks that HEAD is the WIP before amending.** Started out of order, resumed in
  the wrong checkout, or run after the cycle closed, the first amend would rewrite an unrelated
  commit.
- **`git add` names paths explicitly, never `-u`** — and explicit paths are **not** a scope
  guard for content *inside* the named file. Each amend step reads the scoped diff first.
- **No ordinary commit until C3 closes the cycle.**
- **Line numbers are provenance, never instructions.**
- **Preflight and assert are different commands and every task carries both, instantiated.**
  The preflight is a state machine over the old and new texts where **`0` new means apply**; the
  assert runs after the edit, where the new text must appear **exactly once** and the old text
  **zero** times. Reversing them would abort every task that has not run yet.
- **Six of the eight replacements are whole lines and are asserted with `grep -cxF`** — exact
  whole-line equality, so a replacement that drops a clause fails. Tasks 2 and 3 land mid-line and
  are asserted by substring; each says so.
- **Record the WIP commit's SHA before Task 1.** Nothing here is destructive, but a half-executed
  C1 is undone by resetting the WIP to that SHA and re-running, and without the value written down
  an executor is left reconstructing it from the reflog.
- **Neither file is touched by Plan A or Plan B**, so every anchor below was verified against the
  **current** tree. No simulation, and none claimed.

---

## Old-conditions accounting

For each sentence: what it asserted, and what replaces it. Read from the **live** sentence, not
from its summary.

| # | Sentence | What it asserted | Disposition |
|---|---|---|---|
| 1 | `README.md:130` knob row | the knob moves the 3-passes-per-gate floor | **false as of Plan A** — it moves the hook's reminder threshold and never bound an agent. Replaced, with the source named as the profile and the cited set |
| 2 | `getting-started.md:34` Gate-A loop | three passes minimum | **replaced** by the derived floor. "final pass clean" and the zero-finding early exit are **kept** |
| 3 | `getting-started.md:35` counter example | `1/3` is "the counter" | **kept as an example, relabelled** — the literal is the hook's own ratio, so the sentence now says which number is whose. "not an error" is **kept** |
| 4 | `getting-started.md:40` plan loop | the same 3-pass loop | **replaced**; the rest of the sentence kept |
| 5 | `getting-started.md:44` below-floor message | the hook reports that the Gate-A floor wasn't met | **false** — it reports its own threshold, which at a derived floor of 1 announces a shortfall the cycle does not owe. Replaced |
| 6 | `getting-started.md:53` Gate-B loop | three passes, final clean | **replaced** by the derived floor; "final clean" **kept** |
| 7 | `getting-started.md:84` axes sentence | the profile supplies eligibility not the skip · the battery is still owed · Gate A's floor is unchanged at every level | first two **kept verbatim**; the third **deliberately dropped and replaced**, since this change is what makes the floor vary. **Nothing added** |
| 8 | `getting-started.md:86` second knob mention | the knob moves the 3-pass floor | **false**, same as row 1. Both sites corrected, because fixing one leaves the other teaching it |

**Rows 1 and 8 are one claim in two places; rows 2, 4 and 6 are one claim in three; rows 3 and 5
are one claim in two.** That is why they are in one plan: a fix to any one alone leaves the others
contradicting it.

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
>
> **The floor's source is a set, not a story.** Plan A derives one value from the current governing
> cited-story **set**: level 1 only if every cited story is level 0, and 3 if no story is cited or
> any cited story is unprofiled. The replacement uses Plan A's own words — *the profile and the
> cited set*.

- [ ] **Preflight — a state machine over both texts, where `0` new is the signal to apply.**

```sh
old=$(grep -cF -- 'moves the 3-passes-per-gate floor' README.md)
new=$(grep -cxF -- '| `codex-gate.floor` | a positive integer; moves the hook'\''s reminder threshold. It does not change the floor §5 obliges, which §5 derives from the profile and the cited set. |' README.md)
if [ "$old" -eq 1 ] && [ "$new" -eq 0 ]; then
  :                                     # not applied — apply it
elif [ "$old" -eq 0 ] && [ "$new" -eq 1 ]; then
  if [ -n "$(git diff -- README.md)" ] || [ -n "$(git diff --cached -- README.md)" ]; then
    echo "REPLACED BUT NOT YET IN THE WIP — run the amend step only, then skip"; exit 0
  fi
  echo "ALREADY APPLIED AND COMMITTED — skip"; exit 0
else
  echo "MIXED OR DUPLICATE STATE ($old old, $new new) — stop, do not retry"; exit 1
fi
```

- [ ] **Replace.** OLD:

```
| `codex-gate.floor` | a positive integer; moves the 3-passes-per-gate floor. |
```

NEW:

```
| `codex-gate.floor` | a positive integer; moves the hook's reminder threshold. It does not change the floor §5 obliges, which §5 derives from the profile and the cited set. |
```

- [ ] **Assert** — the complete new line, matched whole present exactly once, and the old text gone.

```bash
test "$(grep -cxF -- '| `codex-gate.floor` | a positive integer; moves the hook'\''s reminder threshold. It does not change the floor §5 obliges, which §5 derives from the profile and the cited set. |' README.md)" -eq 1 || { echo "NEW TEXT NOT PRESENT EXACTLY ONCE"; exit 1; }
test "$(grep -cF -- 'moves the 3-passes-per-gate floor' README.md)" -eq 0 || { echo "OLD TEXT SURVIVES"; exit 1; }
```

- [ ] **Amend** — after confirming HEAD is the WIP and the file carries nothing else.

```bash
git log -1 --pretty=%s | grep -qx 'WIP: review-loop economics' || { echo "HEAD IS NOT THE WIP — stop"; exit 1; }
git diff -- README.md
git add README.md
git commit --amend -m "WIP: review-loop economics"
```

**Read that `git diff` before staging.** Explicit paths keep other *files* out; they do nothing
about other *content in this file*, so a concurrent or pre-existing edit here would be absorbed
into the shared WIP and closed under this story.

---

## Task 2: The Gate-A loop description

**File:** `docs/getting-started.md`

**Site** — pasted `grep -n`:

```
docs/getting-started.md:34:three passes minimum, final pass clean — the one early exit is a pass that comes
```

> **The replacement lands mid-line**, because the old sentence ends part-way through line 35 and
> the next task owns the rest of it. Its assert is therefore a substring count, not the whole-line
> equality the other tasks use — stated here rather than left as an inconsistency to notice.

- [ ] **Preflight — a state machine over both texts, where `0` new is the signal to apply.**

```sh
old=$(grep -cF -- 'three passes minimum' docs/getting-started.md)
new=$(grep -cF -- 'the floor §5 derives, final pass clean' docs/getting-started.md)
if [ "$old" -eq 1 ] && [ "$new" -eq 0 ]; then
  :                                     # not applied — apply it
elif [ "$old" -eq 0 ] && [ "$new" -eq 1 ]; then
  if [ -n "$(git diff -- docs/getting-started.md)" ] || [ -n "$(git diff --cached -- docs/getting-started.md)" ]; then
    echo "REPLACED BUT NOT YET IN THE WIP — run the amend step only, then skip"; exit 0
  fi
  echo "ALREADY APPLIED AND COMMITTED — skip"; exit 0
else
  echo "MIXED OR DUPLICATE STATE ($old old, $new new) — stop, do not retry"; exit 1
fi
```

- [ ] **Replace.** OLD:

```
three passes minimum, final pass clean — the one early exit is a pass that comes
back with zero findings.
```

NEW:

```
the floor §5 derives, final pass clean — the one early exit is a pass that
comes back with zero findings.
```

- [ ] **Assert** — the new text (substring — this replacement lands mid-line) present exactly once, and the old text gone.

```bash
test "$(grep -cF -- 'the floor §5 derives, final pass clean' docs/getting-started.md)" -eq 1 || { echo "NEW TEXT NOT PRESENT EXACTLY ONCE"; exit 1; }
test "$(grep -cF -- 'three passes minimum' docs/getting-started.md)" -eq 0 || { echo "OLD TEXT SURVIVES"; exit 1; }
```

- [ ] **Amend** — after confirming HEAD is the WIP and the file carries nothing else.

```bash
git log -1 --pretty=%s | grep -qx 'WIP: review-loop economics' || { echo "HEAD IS NOT THE WIP — stop"; exit 1; }
git diff -- docs/getting-started.md
git add docs/getting-started.md
git commit --amend -m "WIP: review-loop economics"
```

**Read that `git diff` before staging.** Explicit paths keep other *files* out; they do nothing
about other *content in this file*, so a concurrent or pre-existing edit here would be absorbed
into the shared WIP and closed under this story.

---

## Task 3: The below-floor counter example

**File:** `docs/getting-started.md`

**Site** — pasted `grep -n`:

```
docs/getting-started.md:35:back with zero findings. Hook messages like `⚠ Codex Gate A below floor (1/3)` are
```

> **The eighth site, and it was missed by the first sweep.** This example prints a fixed `1/3` and
> calls it *the counter* without saying whose. The `3` is the hook's own threshold; after Task 2
> the sentence beside it says the floor is derived, and the two would contradict each other on the
> same screen.
>
> **Not C2's.** C2 owns the *satisfied* message at line 58, which reports three different numbers.
> This is a below-floor message and carries the same threshold-versus-floor claim as Task 4, so it
> belongs to C1's one claim.
>
> **Independent of Task 2** despite sharing line 35: Task 2's OLD ends at *"back with zero
> findings."* and this OLD begins at *"Hook messages"*. The two replacements touch disjoint text
> and may run in either order.

- [ ] **Preflight — a state machine over both texts, where `0` new is the signal to apply.**

```sh
old=$(grep -cF -- 'the counter, not an error' docs/getting-started.md)
new=$(grep -cF -- 'count the calls against the' docs/getting-started.md)
if [ "$old" -eq 1 ] && [ "$new" -eq 0 ]; then
  :                                     # not applied — apply it
elif [ "$old" -eq 0 ] && [ "$new" -eq 1 ]; then
  if [ -n "$(git diff -- docs/getting-started.md)" ] || [ -n "$(git diff --cached -- docs/getting-started.md)" ]; then
    echo "REPLACED BUT NOT YET IN THE WIP — run the amend step only, then skip"; exit 0
  fi
  echo "ALREADY APPLIED AND COMMITTED — skip"; exit 0
else
  echo "MIXED OR DUPLICATE STATE ($old old, $new new) — stop, do not retry"; exit 1
fi
```

- [ ] **Replace.** OLD:

```
Hook messages like `⚠ Codex Gate A below floor (1/3)` are
the counter, not an error.
```

NEW:

```
Hook messages like `⚠ Codex Gate A below floor (1/3)` count the calls against the
hook's own reminder threshold, not against the floor §5 obliges, and are not an error.
```

- [ ] **Assert** — the new text (substring — this replacement lands mid-line) present exactly once, and the old text gone.

```bash
test "$(grep -cF -- 'count the calls against the' docs/getting-started.md)" -eq 1 || { echo "NEW TEXT NOT PRESENT EXACTLY ONCE"; exit 1; }
test "$(grep -cF -- 'the counter, not an error' docs/getting-started.md)" -eq 0 || { echo "OLD TEXT SURVIVES"; exit 1; }
```

- [ ] **Amend** — after confirming HEAD is the WIP and the file carries nothing else.

```bash
git log -1 --pretty=%s | grep -qx 'WIP: review-loop economics' || { echo "HEAD IS NOT THE WIP — stop"; exit 1; }
git diff -- docs/getting-started.md
git add docs/getting-started.md
git commit --amend -m "WIP: review-loop economics"
```

**Read that `git diff` before staging.** Explicit paths keep other *files* out; they do nothing
about other *content in this file*, so a concurrent or pre-existing edit here would be absorbed
into the shared WIP and closed under this story.

---

## Task 4: The plan-loop sentence

**File:** `docs/getting-started.md`

**Site** — pasted `grep -n`:

```
docs/getting-started.md:40:task-by-task plan (each task starts with a failing test); the same 3-pass loop runs
```

- [ ] **Preflight — a state machine over both texts, where `0` new is the signal to apply.**

```sh
old=$(grep -cF -- 'the same 3-pass loop runs' docs/getting-started.md)
new=$(grep -cxF -- 'task-by-task plan (each task starts with a failing test); the same loop runs at the derived floor' docs/getting-started.md)
if [ "$old" -eq 1 ] && [ "$new" -eq 0 ]; then
  :                                     # not applied — apply it
elif [ "$old" -eq 0 ] && [ "$new" -eq 1 ]; then
  if [ -n "$(git diff -- docs/getting-started.md)" ] || [ -n "$(git diff --cached -- docs/getting-started.md)" ]; then
    echo "REPLACED BUT NOT YET IN THE WIP — run the amend step only, then skip"; exit 0
  fi
  echo "ALREADY APPLIED AND COMMITTED — skip"; exit 0
else
  echo "MIXED OR DUPLICATE STATE ($old old, $new new) — stop, do not retry"; exit 1
fi
```

- [ ] **Replace.** OLD:

```
task-by-task plan (each task starts with a failing test); the same 3-pass loop runs
```

NEW:

```
task-by-task plan (each task starts with a failing test); the same loop runs at the derived floor
```

- [ ] **Assert** — the complete new line, matched whole present exactly once, and the old text gone.

```bash
test "$(grep -cxF -- 'task-by-task plan (each task starts with a failing test); the same loop runs at the derived floor' docs/getting-started.md)" -eq 1 || { echo "NEW TEXT NOT PRESENT EXACTLY ONCE"; exit 1; }
test "$(grep -cF -- 'the same 3-pass loop runs' docs/getting-started.md)" -eq 0 || { echo "OLD TEXT SURVIVES"; exit 1; }
```

- [ ] **Amend** — after confirming HEAD is the WIP and the file carries nothing else.

```bash
git log -1 --pretty=%s | grep -qx 'WIP: review-loop economics' || { echo "HEAD IS NOT THE WIP — stop"; exit 1; }
git diff -- docs/getting-started.md
git add docs/getting-started.md
git commit --amend -m "WIP: review-loop economics"
```

**Read that `git diff` before staging.** Explicit paths keep other *files* out; they do nothing
about other *content in this file*, so a concurrent or pre-existing edit here would be absorbed
into the shared WIP and closed under this story.

---

## Task 5: The below-floor hook message

**File:** `docs/getting-started.md`

**Site** — pasted `grep -n`:

```
docs/getting-started.md:44:progress claims backed by test runs. If the Gate-A floor wasn't met, the hook says
```

> The hook reports against its **own threshold**, not against what the cycle owes. At a derived
> floor of 1 it announces a shortfall the cycle does not have — the named residual of this change,
> and this sentence is where a reader would otherwise learn the opposite.

- [ ] **Preflight — a state machine over both texts, where `0` new is the signal to apply.**

```sh
old=$(grep -cF -- 'If the Gate-A floor wasn'\''t met, the hook says' docs/getting-started.md)
new=$(grep -cxF -- 'progress claims backed by test runs. If the hook'\''s own threshold wasn'\''t met, it says' docs/getting-started.md)
if [ "$old" -eq 1 ] && [ "$new" -eq 0 ]; then
  :                                     # not applied — apply it
elif [ "$old" -eq 0 ] && [ "$new" -eq 1 ]; then
  if [ -n "$(git diff -- docs/getting-started.md)" ] || [ -n "$(git diff --cached -- docs/getting-started.md)" ]; then
    echo "REPLACED BUT NOT YET IN THE WIP — run the amend step only, then skip"; exit 0
  fi
  echo "ALREADY APPLIED AND COMMITTED — skip"; exit 0
else
  echo "MIXED OR DUPLICATE STATE ($old old, $new new) — stop, do not retry"; exit 1
fi
```

- [ ] **Replace.** OLD:

```
progress claims backed by test runs. If the Gate-A floor wasn't met, the hook says
```

NEW:

```
progress claims backed by test runs. If the hook's own threshold wasn't met, it says
```

- [ ] **Assert** — the complete new line, matched whole present exactly once, and the old text gone.

```bash
test "$(grep -cxF -- 'progress claims backed by test runs. If the hook'\''s own threshold wasn'\''t met, it says' docs/getting-started.md)" -eq 1 || { echo "NEW TEXT NOT PRESENT EXACTLY ONCE"; exit 1; }
test "$(grep -cF -- 'If the Gate-A floor wasn'\''t met, the hook says' docs/getting-started.md)" -eq 0 || { echo "OLD TEXT SURVIVES"; exit 1; }
```

- [ ] **Amend** — after confirming HEAD is the WIP and the file carries nothing else.

```bash
git log -1 --pretty=%s | grep -qx 'WIP: review-loop economics' || { echo "HEAD IS NOT THE WIP — stop"; exit 1; }
git diff -- docs/getting-started.md
git add docs/getting-started.md
git commit --amend -m "WIP: review-loop economics"
```

**Read that `git diff` before staging.** Explicit paths keep other *files* out; they do nothing
about other *content in this file*, so a concurrent or pre-existing edit here would be absorbed
into the shared WIP and closed under this story.

---

## Task 6: The Gate-B loop description

**File:** `docs/getting-started.md`

**Site** — pasted `grep -n`:

```
docs/getting-started.md:53:`mcp__codex__review` the same way: three passes, final clean. Verification is by
```

- [ ] **Preflight — a state machine over both texts, where `0` new is the signal to apply.**

```sh
old=$(grep -cF -- 'the same way: three passes, final clean' docs/getting-started.md)
new=$(grep -cxF -- '`mcp__codex__review` the same way: the derived floor, final clean. Verification is by' docs/getting-started.md)
if [ "$old" -eq 1 ] && [ "$new" -eq 0 ]; then
  :                                     # not applied — apply it
elif [ "$old" -eq 0 ] && [ "$new" -eq 1 ]; then
  if [ -n "$(git diff -- docs/getting-started.md)" ] || [ -n "$(git diff --cached -- docs/getting-started.md)" ]; then
    echo "REPLACED BUT NOT YET IN THE WIP — run the amend step only, then skip"; exit 0
  fi
  echo "ALREADY APPLIED AND COMMITTED — skip"; exit 0
else
  echo "MIXED OR DUPLICATE STATE ($old old, $new new) — stop, do not retry"; exit 1
fi
```

- [ ] **Replace.** OLD:

```
`mcp__codex__review` the same way: three passes, final clean. Verification is by
```

NEW:

```
`mcp__codex__review` the same way: the derived floor, final clean. Verification is by
```

- [ ] **Assert** — the complete new line, matched whole present exactly once, and the old text gone.

```bash
test "$(grep -cxF -- '`mcp__codex__review` the same way: the derived floor, final clean. Verification is by' docs/getting-started.md)" -eq 1 || { echo "NEW TEXT NOT PRESENT EXACTLY ONCE"; exit 1; }
test "$(grep -cF -- 'the same way: three passes, final clean' docs/getting-started.md)" -eq 0 || { echo "OLD TEXT SURVIVES"; exit 1; }
```

- [ ] **Amend** — after confirming HEAD is the WIP and the file carries nothing else.

```bash
git log -1 --pretty=%s | grep -qx 'WIP: review-loop economics' || { echo "HEAD IS NOT THE WIP — stop"; exit 1; }
git diff -- docs/getting-started.md
git add docs/getting-started.md
git commit --amend -m "WIP: review-loop economics"
```

**Read that `git diff` before staging.** Explicit paths keep other *files* out; they do nothing
about other *content in this file*, so a concurrent or pre-existing edit here would be absorbed
into the shared WIP and closed under this story.

---

## Task 7: The axes sentence

**File:** `docs/getting-started.md`

**Site** — pasted `grep -n`:

```
docs/getting-started.md:84:is still owed and Gate A's floor is unchanged at every level. The caution bias is
```

> **Three claims share this sentence and only one is false.** That the profile supplies
> eligibility rather than the skip: **kept**. That the battery is still owed: **kept**. That Gate
> A's floor is unchanged at every level: **this change makes it false**, and it is the only clause
> replaced. Nothing is added — an earlier draft introduced a clause about baseline questions that
> the old sentence never made, which the accounting would then have had to explain.

- [ ] **Preflight — a state machine over both texts, where `0` new is the signal to apply.**

```sh
old=$(grep -cF -- 'Gate A'\''s floor is unchanged at every level' docs/getting-started.md)
new=$(grep -cxF -- 'is still owed; Gate A'\''s floor derives from the profile and the cited set exactly as Gate B'\''s does. The caution bias is' docs/getting-started.md)
if [ "$old" -eq 1 ] && [ "$new" -eq 0 ]; then
  :                                     # not applied — apply it
elif [ "$old" -eq 0 ] && [ "$new" -eq 1 ]; then
  if [ -n "$(git diff -- docs/getting-started.md)" ] || [ -n "$(git diff --cached -- docs/getting-started.md)" ]; then
    echo "REPLACED BUT NOT YET IN THE WIP — run the amend step only, then skip"; exit 0
  fi
  echo "ALREADY APPLIED AND COMMITTED — skip"; exit 0
else
  echo "MIXED OR DUPLICATE STATE ($old old, $new new) — stop, do not retry"; exit 1
fi
```

- [ ] **Replace.** OLD:

```
is still owed and Gate A's floor is unchanged at every level. The caution bias is
```

NEW:

```
is still owed; Gate A's floor derives from the profile and the cited set exactly as Gate B's does. The caution bias is
```

- [ ] **Assert** — the complete new line, matched whole present exactly once, and the old text gone.

```bash
test "$(grep -cxF -- 'is still owed; Gate A'\''s floor derives from the profile and the cited set exactly as Gate B'\''s does. The caution bias is' docs/getting-started.md)" -eq 1 || { echo "NEW TEXT NOT PRESENT EXACTLY ONCE"; exit 1; }
test "$(grep -cF -- 'Gate A'\''s floor is unchanged at every level' docs/getting-started.md)" -eq 0 || { echo "OLD TEXT SURVIVES"; exit 1; }
```

- [ ] **Amend** — after confirming HEAD is the WIP and the file carries nothing else.

```bash
git log -1 --pretty=%s | grep -qx 'WIP: review-loop economics' || { echo "HEAD IS NOT THE WIP — stop"; exit 1; }
git diff -- docs/getting-started.md
git add docs/getting-started.md
git commit --amend -m "WIP: review-loop economics"
```

**Read that `git diff` before staging.** Explicit paths keep other *files* out; they do nothing
about other *content in this file*, so a concurrent or pre-existing edit here would be absorbed
into the shared WIP and closed under this story.

---

## Task 8: The second knob mention

**File:** `docs/getting-started.md`

**Site** — pasted `grep -n`:

```
docs/getting-started.md:86:positive integer) moves the 3-pass floor, and `touch .context/codex-gate.off`
```

> The same correction as Task 1, in the second place the docs describe the knob. **Both sites say
> the same wrong thing**, and this repo's own record is that a fix to one has never implied a fix
> to the other.

- [ ] **Preflight — a state machine over both texts, where `0` new is the signal to apply.**

```sh
old=$(grep -cF -- 'moves the 3-pass floor' docs/getting-started.md)
new=$(grep -cxF -- 'positive integer) moves the hook'\''s reminder threshold, and `touch .context/codex-gate.off`' docs/getting-started.md)
if [ "$old" -eq 1 ] && [ "$new" -eq 0 ]; then
  :                                     # not applied — apply it
elif [ "$old" -eq 0 ] && [ "$new" -eq 1 ]; then
  if [ -n "$(git diff -- docs/getting-started.md)" ] || [ -n "$(git diff --cached -- docs/getting-started.md)" ]; then
    echo "REPLACED BUT NOT YET IN THE WIP — run the amend step only, then skip"; exit 0
  fi
  echo "ALREADY APPLIED AND COMMITTED — skip"; exit 0
else
  echo "MIXED OR DUPLICATE STATE ($old old, $new new) — stop, do not retry"; exit 1
fi
```

- [ ] **Replace.** OLD:

```
positive integer) moves the 3-pass floor, and `touch .context/codex-gate.off`
```

NEW:

```
positive integer) moves the hook's reminder threshold, and `touch .context/codex-gate.off`
```

- [ ] **Assert** — the complete new line, matched whole present exactly once, and the old text gone.

```bash
test "$(grep -cxF -- 'positive integer) moves the hook'\''s reminder threshold, and `touch .context/codex-gate.off`' docs/getting-started.md)" -eq 1 || { echo "NEW TEXT NOT PRESENT EXACTLY ONCE"; exit 1; }
test "$(grep -cF -- 'moves the 3-pass floor' docs/getting-started.md)" -eq 0 || { echo "OLD TEXT SURVIVES"; exit 1; }
```

- [ ] **Amend** — after confirming HEAD is the WIP and the file carries nothing else.

```bash
git log -1 --pretty=%s | grep -qx 'WIP: review-loop economics' || { echo "HEAD IS NOT THE WIP — stop"; exit 1; }
git diff -- docs/getting-started.md
git add docs/getting-started.md
git commit --amend -m "WIP: review-loop economics"
```

**Read that `git diff` before staging.** Explicit paths keep other *files* out; they do nothing
about other *content in this file*, so a concurrent or pre-existing edit here would be absorbed
into the shared WIP and closed under this story.

---

## Task 9: Confirm the claim has no ninth site

**Runs last.** The eight tasks above were found by grepping the claim. This re-runs that grep
against the finished files, so completeness is a check rather than an assertion.

- [ ] **No stale floor language survives in either file.**

```bash
if grep -nEi '3-pass|three passes|3 passes|3-passes-per-gate|[0-9]/3' README.md docs/getting-started.md; then
  echo "A NUMERIC FLOOR CLAIM SURVIVES — read the hits printed above"; exit 1
fi
```

> **Exactly one hit is expected and is not C1's:** the satisfied-message example at
> `docs/getting-started.md:58`, which prints `3/3 cycle` and belongs to **C2**. If the grep reports
> only that line, C1's numeric sites are complete and C2 is still owed. **Any other hit is C1's.**
>
> **This sweep covers the numeric spellings only.** Tasks 5 and 7 correct sentences that state the
> claim with no number in them — *"If the Gate-A floor wasn't met"* and *"Gate A's floor is
> unchanged at every level"* — and those two are covered by their own tasks' old-text-gone asserts,
> not by this grep. Said here because a sweep that looks complete and is not is worse than one
> whose boundary is written down.

- [ ] **The knob's non-binding property holds at both sites**, which is a stronger check than the
  two rows being worded identically — they are not, and are not meant to be.

```bash
test "$(grep -cF -- "moves the hook's reminder threshold" README.md)" -eq 1 || { echo "README KNOB LINE WRONG"; exit 1; }
test "$(grep -cF -- "moves the hook's reminder threshold" docs/getting-started.md)" -eq 1 || { echo "GETTING-STARTED KNOB LINE WRONG"; exit 1; }
if grep -nF -e "moves the 3-pass floor" -e "moves the 3-passes-per-gate floor" README.md docs/getting-started.md; then
  echo "A KNOB-BINDS-THE-FLOOR CLAIM SURVIVES"; exit 1
fi
```

> **Fixed strings, not a general pattern, and deliberately.** A regex broad enough to catch any
> re-binding of the floor was written first and **errored on this machine's `grep`** —
> *"exceeds complexity limits"* — which is worse than a narrow check, because a command that
> cannot run reports nothing and looks like a pass. These three catch the two phrasings that
> existed and confirm the replacement landed in both files; a *newly invented* way of saying the
> knob moves the floor is caught by a reader, not by this.

- [ ] **If either check produced a fix**, amend as the tasks above do and re-run both checks.
  A clean Task 9 stages nothing and amends nothing — the only task here that does not.

> **What this catches and what it does not.** It catches every numeric spelling of the claim this
> repo has used, and the two knob phrasings that existed. It does **not** catch a fixed-floor
> assertion phrased without a number — *"the loop always runs the same number of times"* passes —
> nor a newly invented knob sentence. That residue is a reading, and it is named here rather than
> covered by implication.

---

## Self-Review

**Scope.** Eight sentences, two files, one claim. Every anchor verified against the current tree;
neither file is touched by Plan A or Plan B, so no simulation was needed and none is claimed.

**Six asserts are whole-line equality (`grep -cxF`).** A replacement that lands but drops a clause
fails them. Pass 1 caught the substring-sentinel version, where Task 7 could have omitted half its
replacement and still gone green. Tasks 2 and 3 land mid-line, cannot use whole-line equality, and
say so rather than looking like an oversight.

**Every preflight reads both texts.** One old and zero new means apply; zero old and one new means
already replaced — and then it checks whether the edit actually reached the WIP, because an
interruption between Replace and Amend otherwise leaves the change stranded in the worktree while
the task reports itself done. Every other state stops.

**What the accounting fixed.** Row 7 was written from a summary of the live sentence rather than
the sentence, and attributed a claim about baseline questions the original never made. It is now
read from the live text: three claims, two kept verbatim, one replaced, nothing added.

**Two rows in the scope table have no owner**, and that is stated as a gap in the split rather
than solved here. They block C3's close, not this plan. Absorbing them would rebuild Plan C.

**Known limit.** Gate A reviews this plan, not the edits. What the edits do is Gate B's — C3's.
