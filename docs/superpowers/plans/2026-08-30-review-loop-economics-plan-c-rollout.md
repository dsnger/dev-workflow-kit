# Plan C — rollout: falsified sentences, packaging, evidence, and the close

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development
> (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use
> checkbox (`- [ ]`) syntax for tracking.

**Goal:** Correct every user-facing sentence Plans A and B falsify, ship the packaging, produce
the evidence the story's mode requires, run the one Gate-B cycle over the combined diff, and close
it.

**Spec:** `docs/superpowers/specs/2026-08-28-review-loop-economics-design.md` (revision 36).
Plan C implements §7 and §8.

**Story:** `docs/superpowers/stories/2026-08-28-review-loop-economics-pass-floor-story.md`

> **Read the profile from that header at execution time.** This plan states no risk value, no
> security value, no validation mode and no pass count derived from any of them. Task 19 reads the
> mode from the header and produces what it names.

---

## Plan C of three

| Plan | Ships | Status |
|---|---|---|
| A | the floor predicate and the severity test | Gate-A closed clean, pass 12 |
| B | the provenance line, the per-pass curve, the cycle nonce, slot naming | Gate-A closed clean, pass 7 |
| **C — this one** | rollout, packaging, evidence, and the single Gate-B cycle | this cycle |

**Plan C edits the tree Plans A and B leave behind** for `workflow-init.md`; the user-facing docs
it corrects are untouched by either. Every `grep -n` anchor below was taken against the
correct base for its file.

### The five obligations Plan C inherits

These came from a Gate-B section Plan A dropped when the topology became one cycle. **A finding
whose section moved is relocated, not repaired**, so they are discharged here or nowhere:

| From | What Plan C owes |
|---|---|
| pass-1 M8 | **single-branch Gate-B recovery** — delete only the failed branch, never both |
| pass-1 M9 | **record the floor knob's existence and bytes before the cycle, compare after** |
| pass-1 M10 | **never `git add -u`** — stage an explicitly inspected path set |
| pass-1 MINOR 12 | **build the closing body with `mktemp`**, not a fixed `/tmp` path |
| pass-1 B6 | **evidence revalidated after every fix and again before the closing amend** |

---

## Global Constraints

- **This Gate-B cycle runs under the rules in force at its start — the OLD ones.** Everything
  Plans A and B ship binds only **after** the closing commit. **Carry this sentence in the
  `additionalContext` of every Gate-B call**: a reviewer applying the new Minor-or-below ceiling
  to the change that introduces it would under-iterate on exactly the diff needing most iteration.
- **The floor for this cycle is 3** — the constant, because the old rules govern it. Not the
  derived value the diff introduces.
- **No file under `plugins/dev-workflow/hooks/` changes.** The floor knob
  `.context/codex-gate.floor` is never written or removed; Task 13 reads it, and reading is what
  the evidence requires.
- **Never `git commit --amend --no-edit` inside the cycle.**
  `plugins/dev-workflow/hooks/codex-gate.sh:763` recognizes a WIP commit by grepping the **Bash
  command string** for `-m ... wip`; an amend without `-m` is not recognized, and the hook resets,
  discarding the cycle's passes. Every amend restates `-m "WIP: review-loop economics"`.
- **No ordinary commit until the close.** The cycle Plan A opened is still open. Every task here
  amends it, including the ones touching only `docs/**.md` — the prose exemption decides whether a
  *commit* needs Gate B, and this content is going into a commit that already does.
- **`git add` names paths explicitly, never `-u`.** Staging whole-tree changes would fold an
  unrelated edit into the reviewed diff and close it under this story.
- **Line numbers are provenance, never instructions.**
- **Every assert is an equality test, never a count print**, and every task is
  **skip-if-applied**: run its assert first. `1` means the task already ran — skip it, do not
  re-apply. `0` means apply. **Any other count is a stop**, not a retry: a duplicate insertion or
  a half-applied edit, which re-running only compounds. This is what makes the plan safe to
  resume, and it is why the asserts test equality — a bare `grep -c` succeeds at any positive
  count, so it cannot tell one insertion from two.
- **Tasks 10 and 12 re-emit their anchor inside their replacement**, so their OLD text survives
  by design and only the NEW count discriminates. Every other task's OLD text is gone after it
  runs.

---

## Old-conditions accounting

§6's method, applied to a different class: these are **user-facing statements that Plans A and B
make false**. Most are not §5 rules; **rows 15 and 16 are** — the skipped-cycle duty sentence in §5
itself and in the scaffolded mirror — and they get the same accounting. For each, what it asserted
and what replaces it.

| # | Statement | What it asserted | Disposition |
|---|---|---|---|
| 1 | `README.md` knob row | the knob moves the pass floor | **false as of Plan A** — the knob moves the hook's reminder threshold and never bound an agent. Replaced, with the distinction stated (Task 1) |
| 2 | `getting-started.md` Gate-A loop | three passes minimum | **replaced** by the derived floor; "final pass clean" and the zero-finding early exit are **kept** (Task 2) |
| 3 | same, plan loop | the same 3-pass loop | **replaced**; the rest of the sentence kept (Task 3) |
| 4 | same, hook message | the Gate-A floor wasn't met | **false** — the hook reports its own threshold, which at a derived floor of 1 reports a shortfall the cycle does not owe. Replaced (Task 4) |
| 5 | same, Gate-B loop | three passes, final clean | **replaced** by the derived floor; "final clean" kept (Task 5) |
| 6 | same, satisfied message | `3/3 cycle` | **kept as an example, relabelled** — the literal is the hook's ratio, so `N/N` with N named as the threshold rather than the floor (Task 6) |
| 7 | same, axes sentence | the axes never subtract **and** the floor is unchanged at every level | first clause **kept** — it is true and is the point; second **deliberately dropped**, since this change is what makes the floor vary (Task 7) |
| 8 | same, second knob mention | the knob moves the 3-pass floor | **false**, same as row 1. Both sites corrected, because fixing one would leave the other teaching it (Task 8) |
| 9 | `coding-workflow.md` axes sentence | as row 7 | same disposition (Task 9) |
| 10 | `workflow-init.md` before the template fence | *(nothing — this is an insertion)* | **rewrites nothing**; the note is added outside the fence so it never scaffolds (Task 10) |
| 11 | `plugin.json` version | `0.10.0` | **replaced** by `0.11.0` (Task 11) |
| 12 | `CHANGELOG.md` | *(nothing — an append)* | **rewrites nothing**; a new newest-first entry (Task 12) |
| 13 | `coding-workflow.md` model destination | the model goes in the evidence entry or the dispositions file | **replaced** by the per-pass curve's model field — neither old destination is keyed to a pass. The health-probe procedure above it is **kept** untouched (Task 13) |
| 14 | `process-pr-review.md` skip duties | a skipped cycle owes the skip reason, the battery result, and one evidence entry per cited profiled story | **all three kept and extended**: the provenance line and, in place of a curve, the skip record are **added**, because Plan B makes them owed by every cycle, skipped or not (Task 14) |
| 15 | `CLAUDE.md` §5 skip duties | as row 14, in the governing copy | same disposition (Task 15) |
| 16 | scaffolded template skip duties | as row 14, in the mirror | same disposition (Task 16) |
| 17 | `getting-started.md` skip duties | as row 14, in an explanatory duty summary | same disposition (Task 17) |
| 18 | `coding-workflow.md` skip duties | as row 14, in the other explanatory duty summary | same disposition (Task 18) |

**Rows 10 and 12 are insertions and are listed so a reader can confirm that rather than assume
it.** Each re-emits its anchor verbatim inside its replacement.

**Rows 14-18 are one claim in five files.** The sweep that found three stopped at the prompt
copies; Gate-A pass 4 found the two documentation summaries, which enumerate the same duties and
omit the same two records.

---
## Task 1: The `codex-gate.floor` knob description

**File:** `README.md`

**Site** — pasted `grep -n`:

```
README.md:130:| `codex-gate.floor` | a positive integer; moves the 3-passes-per-gate floor. |
```

> The knob never bound an agent — `$floor` appears in the hook's control flow, but that flow only selects which advisory message fires, and the hook exits 0 on every branch. The old line said it moved the floor, which was the clearest statement of the wrong model anywhere in the docs.

- [ ] **Replace.** OLD:

```
| `codex-gate.floor` | a positive integer; moves the 3-passes-per-gate floor. |
```

NEW:

```
| `codex-gate.floor` | a positive integer; moves the hook's reminder threshold. It does not change the floor §5 obliges, which is derived from the cited story's profile. |
```

- [ ] **Assert the new text is present.**

```bash
test "$(grep -cF -- "moves the hook's reminder threshold. It does not change the floor" README.md)" -eq 1 || { echo "ASSERT FAILED"; exit 1; }
```

Before this task the count is `0`, so this exits nonzero if it is run early; after, `1`. Verified against a simulated tree carrying Plan A's and Plan B's edits.

- [ ] **Amend the WIP commit.**

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

- [ ] **Assert the new text is present.**

```bash
test "$(grep -cF -- "the floor its profile derives, final pass clean" docs/getting-started.md)" -eq 1 || { echo "ASSERT FAILED"; exit 1; }
```

Before this task the count is `0`, so this exits nonzero if it is run early; after, `1`. Verified against a simulated tree carrying Plan A's and Plan B's edits.

- [ ] **Amend the WIP commit.**

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

- [ ] **Replace.** OLD:

```
task-by-task plan (each task starts with a failing test); the same 3-pass loop runs
```

NEW:

```
task-by-task plan (each task starts with a failing test); the same loop runs at the derived floor
```

- [ ] **Assert the new text is present.**

```bash
test "$(grep -cF -- "the same loop runs at the derived floor" docs/getting-started.md)" -eq 1 || { echo "ASSERT FAILED"; exit 1; }
```

Before this task the count is `0`, so this exits nonzero if it is run early; after, `1`. Verified against a simulated tree carrying Plan A's and Plan B's edits.

- [ ] **Amend the WIP commit.**

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

> The hook reports against its own threshold, not against what the cycle owes. At a derived floor of 1 it will report a shortfall the cycle does not have — the named residual, and this sentence is where a reader would otherwise learn the opposite.

- [ ] **Replace.** OLD:

```
progress claims backed by test runs. If the Gate-A floor wasn't met, the hook says
```

NEW:

```
progress claims backed by test runs. If the hook's own threshold wasn't met, it says
```

- [ ] **Assert the new text is present.**

```bash
test "$(grep -cF -- "If the hook's own threshold wasn't met, it says" docs/getting-started.md)" -eq 1 || { echo "ASSERT FAILED"; exit 1; }
```

Before this task the count is `0`, so this exits nonzero if it is run early; after, `1`. Verified against a simulated tree carrying Plan A's and Plan B's edits.

- [ ] **Amend the WIP commit.**

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

- [ ] **Replace.** OLD:

```
`mcp__codex__review` the same way: three passes, final clean. Verification is by
```

NEW:

```
`mcp__codex__review` the same way: the derived floor, final clean. Verification is by
```

- [ ] **Assert the new text is present.**

```bash
test "$(grep -cF -- "the derived floor, final clean. Verification is by" docs/getting-started.md)" -eq 1 || { echo "ASSERT FAILED"; exit 1; }
```

Before this task the count is `0`, so this exits nonzero if it is run early; after, `1`. Verified against a simulated tree carrying Plan A's and Plan B's edits.

- [ ] **Amend the WIP commit.**

```bash
git add docs/getting-started.md
git commit --amend -m "WIP: review-loop economics"
```

---

## Task 6: The satisfied-message example

**File:** `docs/getting-started.md`

**Site** — pasted `grep -n`:

```
docs/getting-started.md:58:`✓ Codex Gate B satisfied (3/3 cycle, 3 on current fingerprint)`, the real commit replaces
```

> The literal `3/3` in the example is the hook's ratio. Writing `N/N` without saying which N it is would have replaced a wrong number with an ambiguous one.

- [ ] **Replace.** OLD:

```
`✓ Codex Gate B satisfied (3/3 cycle, 3 on current fingerprint)`, the real commit replaces
```

NEW:

```
`✓ Codex Gate B satisfied (<passes>/<threshold> cycle, <fresh> on current fingerprint)` — three different numbers: the calls this cycle made, the hook's reminder threshold, and how many ran against the current fingerprint. None of them is the floor §5 obliges — the real commit replaces
```

- [ ] **Assert the new text is present.**

```bash
test "$(grep -cF -- "three different numbers: the calls this cycle made" docs/getting-started.md)" -eq 1 || { echo "ASSERT FAILED"; exit 1; }
```

Before this task the count is `0`, so this exits nonzero if it is run early; after, `1`. Verified against a simulated tree carrying Plan A's and Plan B's edits.

- [ ] **Amend the WIP commit.**

```bash
git add docs/getting-started.md
git commit --amend -m "WIP: review-loop economics"
```

---

## Task 7: The axes-add-lenses sentence

**File:** `docs/getting-started.md`

**Site** — pasted `grep -n`:

```
docs/getting-started.md:84:is still owed and Gate A's floor is unchanged at every level. The caution bias is
```

> Two claims were tangled here: that the axes never subtract, which is true and stays, and that the floor is unchanged at every level, which this change makes false. Separated rather than reworded.

- [ ] **Replace.** OLD:

```
is still owed and Gate A's floor is unchanged at every level. The caution bias is
```

NEW:

```
is still owed; Gate A's floor derives from the profile exactly as Gate B's does, and what the axes never subtract is the baseline questions. The caution bias is
```

- [ ] **Assert the new text is present.**

```bash
test "$(grep -cF -- "Gate A's floor derives from the profile exactly as Gate B's does" docs/getting-started.md)" -eq 1 || { echo "ASSERT FAILED"; exit 1; }
```

Before this task the count is `0`, so this exits nonzero if it is run early; after, `1`. Verified against a simulated tree carrying Plan A's and Plan B's edits.

- [ ] **Amend the WIP commit.**

```bash
git add docs/getting-started.md
git commit --amend -m "WIP: review-loop economics"
```

---

## Task 8: The second knob mention

**File:** `docs/getting-started.md`

**Site** — pasted `grep -n`:

```
docs/getting-started.md:86:positive integer) moves the 3-pass floor, and `touch .context/codex-gate.off`
```

> The same correction as Task 1, in the second place the docs describe the knob. Both sites say the same wrong thing and a fix to one would have left the other teaching it.

- [ ] **Replace.** OLD:

```
positive integer) moves the 3-pass floor, and `touch .context/codex-gate.off`
```

NEW:

```
positive integer) moves the hook's reminder threshold, and `touch .context/codex-gate.off`
```

- [ ] **Assert the new text is present.**

```bash
test "$(grep -cF -- "moves the hook's reminder threshold, and" docs/getting-started.md)" -eq 1 || { echo "ASSERT FAILED"; exit 1; }
```

Before this task the count is `0`, so this exits nonzero if it is run early; after, `1`. Verified against a simulated tree carrying Plan A's and Plan B's edits.

- [ ] **Amend the WIP commit.**

```bash
git add docs/getting-started.md
git commit --amend -m "WIP: review-loop economics"
```

---

## Task 9: The coding-workflow axes sentence

**File:** `docs/coding-workflow.md`

**Site** — pasted `grep -n`:

```
docs/coding-workflow.md:79:gates for a risky or security-relevant change (they never subtract any: Gate A's floor and
```

- [ ] **Replace.** OLD:

```
gates for a risky or security-relevant change (they never subtract any: Gate A's floor and
the baseline questions are the same at every level), while the derived mode calibrates
```

NEW:

```
gates for a risky or security-relevant change (they never subtract a baseline question; the
floor itself derives from the profile, so it is not the same at every level), while the derived
mode calibrates
```

- [ ] **Assert the new text is present.**

```bash
test "$(grep -cF -- "floor itself derives from the profile, so it is not the same at every level" docs/coding-workflow.md)" -eq 1 || { echo "ASSERT FAILED"; exit 1; }
```

Before this task the count is `0`, so this exits nonzero if it is run early; after, `1`. Verified against a simulated tree carrying Plan A's and Plan B's edits.

- [ ] **Amend the WIP commit.**

```bash
git add docs/coding-workflow.md
git commit --amend -m "WIP: review-loop economics"
```

---

## Task 10: The item-1 n/a note, outside the fence

**File:** `plugins/dev-workflow/commands/workflow-init.md`

**Site** — pasted `grep -n`:

```
plugins/dev-workflow/commands/workflow-init.md:190:numbers) and say so in the report.
```

> **Outside the fence, deliberately.** Inside it the note would scaffold into every initialized project, where it is meaningless. And it is **not** written as a `Target model:` line: that would make this file's declaration count 2 and fail `scripts/check-invariants.sh`, which is the naive form of this fix.
> 
> The fence here opens with four backticks because the template it wraps contains three-backtick blocks of its own; the note goes above that opener.

- [ ] **Replace.** OLD:

`````
numbers) and say so in the report.

````markdown
`````

NEW:

`````
numbers) and say so in the report.

> **Prompt-standards item 1 for the scaffolded `CLAUDE.md`: n/a, and why.** The file this
> template writes is model-agnostic by design — its executing model is whatever the reader of
> that project runs — so a `Target model:` line inside it would be false in every repo it lands
> in. Recorded as a reasoned n/a rather than skipped: the item is answered. **This note sits
> outside the fence** so it never scaffolds, and is deliberately **not** a `Target model:` line,
> which would make this file's declaration count 2 and fail `scripts/check-invariants.sh`.

````markdown
`````

- [ ] **Assert the new text is present.**

```bash
test "$(grep -cF -- "Prompt-standards item 1 for the scaffolded" plugins/dev-workflow/commands/workflow-init.md)" -eq 1 || { echo "ASSERT FAILED"; exit 1; }
```

Before this task the count is `0`, so this exits nonzero if it is run early; after, `1`. Verified against a simulated tree carrying Plan A's and Plan B's edits.

- [ ] **Amend the WIP commit.**

```bash
git add plugins/dev-workflow/commands/workflow-init.md
git commit --amend -m "WIP: review-loop economics"
```

---

## Task 11: The manifest version bump

**File:** `plugins/dev-workflow/.claude-plugin/plugin.json`

**Site** — pasted `grep -n`:

```
plugins/dev-workflow/.claude-plugin/plugin.json:4:  "version": "0.10.0",
```

> Minor, not patch: shipped rules change and no documented interface breaks. Invariant 12 requires a bump for any change under `plugins/<name>/`, and Plans A and B both changed `workflow-init.md`.

- [ ] **Replace.** OLD:

```
  "version": "0.10.0",
```

NEW:

```
  "version": "0.11.0",
```

- [ ] **Assert the new text is present.**

```bash
test "$(grep -cF -- '"version": "0.11.0"' plugins/dev-workflow/.claude-plugin/plugin.json)" -eq 1 || { echo "ASSERT FAILED"; exit 1; }
```

The outer single quotes are what make the inner JSON quotes survive the shell — the same fix
pass 1 required. Before this task the count is `0`, so this exits nonzero if it is run early;
after, `1`. Verified against a simulated tree carrying Plan A's and Plan B's edits.

- [ ] **Amend the WIP commit.**

```bash
git add plugins/dev-workflow/.claude-plugin/plugin.json
git commit --amend -m "WIP: review-loop economics"
```

---

## Task 12: The CHANGELOG entry

**File:** `plugins/dev-workflow/CHANGELOG.md`

**Site** — pasted `grep -n`:

```
plugins/dev-workflow/CHANGELOG.md:25:## 0.10.0
```

> Newest first, matching the file's stated convention. **Nothing enforces this** — neither invariant 12 nor `check-version-bump.sh` mentions the changelog — so it is carried by the story's criterion and by this task.

- [ ] **Replace.** OLD:

```
## 0.10.0
```

NEW:

```
## 0.11.0

- **The mandatory pass floor is now a function of the cited story's profile**, not the constant 3.
  `max(risk, security) == 0` gives a floor of **1**; every resolvable profile above that, and an
  artifact citing no story, gives **3**. A cited story whose profile is present but unresolvable
  **stops and surfaces** rather than defaulting. Across a cited set the floor is 1 only if the set
  is non-empty and every member is profiled, resolvable and at level 0.
- **The hook's ratio is a reminder threshold and controls nothing.** It always did; the text now
  says so, and the `codex-gate.floor` knob is described as moving that threshold rather than the
  obligation. `README.md` and `docs/getting-started.md` carried the old description and are
  corrected.
- **Finding severity is decided by whether something in the system takes a different decision.**
  Name what consumes the text and the decision that changes if it is wrong; if you cannot name
  both, the finding is Minor or below. The review pass raising a finding is not an in-system
  reader of the text it reviews, gates remain readers of rule text they will later apply, and a
  human reader never satisfies the test. It sets a ceiling, never a floor, and never chooses
  between Blocker and Major.
- **Two commit-body records are pinned**, because a program parses them: a **provenance line**
  carrying the cycle field, the derived floor and the cited set that produced it, and a
  **per-pass curve** carrying Findings, Blockers and Majors per pass. One of each per cycle — a
  change running five cycles records five.
- **A cycle nonce** attributes those records. Eight to sixteen characters from `[a-z0-9]`, from a
  source of randomness, never derived from a name, timestamp or commit. It is
  collision-**resistant**, not collision-proof, and the shipped text says where that bound bites
  rather than implying a guarantee.
- **Findings slots take a per-cycle infix**, and the deletion step §5 already requires now deletes
  only paths carrying the cycle's own nonce. That rule exists because a bare slot was overwritten
  during this change's own development, destroying a previous cycle's findings file.
- **What this change does not settle** is how demotion bears on the loop-health measures — the
  per-pass counts, the clusters and the stop thresholds. That is the loop-rule consolidation
  story's, and both documents say so, so the obligation cannot fall between them.

## 0.10.0
```

- [ ] **Assert the new text is present.**

```bash
test "$(grep -cF -- "The mandatory pass floor is now a function of the cited story's profile" plugins/dev-workflow/CHANGELOG.md)" -eq 1 || { echo "ASSERT FAILED"; exit 1; }
```

Before this task the count is `0`, so this exits nonzero if it is run early; after, `1`. Verified against a simulated tree carrying Plan A's and Plan B's edits.

- [ ] **Amend the WIP commit.**

```bash
git add plugins/dev-workflow/CHANGELOG.md
git commit --amend -m "WIP: review-loop economics"
```

---

## Task 13: The model-recording instruction

**File:** `docs/coding-workflow.md`

**Site** — pasted `grep -n`:

```
docs/coding-workflow.md:279:the finding count in the pass record: the commit body's evidence entry, or the slot's
```

> Plan B pins a model field inside the per-pass curve. This sentence sent the value to the evidence entry or the dispositions file instead — **neither of which is keyed to a pass**, so a reader could not tell which pass a model belonged to. The health-probe procedure above it is untouched and is still how the value is established; only the destination changes.

- [ ] **Replace.** OLD:

```
the finding count in the pass record: the commit body's evidence entry, or the slot's
dispositions file. This is
bookkeeping, not enforcement: nothing checks it, and a wrong entry looks exactly like a right
```

NEW:

```
the finding count in **the cycle's per-pass curve**, which pins a field for it — not the
evidence entry and not the dispositions file, neither of which is keyed to a pass. The health
probe above is how the value is established; the curve is where it goes. This is
bookkeeping, not enforcement: nothing checks it, and a wrong entry looks exactly like a right
```

- [ ] **Assert the new text is present.**

```bash
test "$(grep -cF -- "the finding count in **the cycle's per-pass curve**" docs/coding-workflow.md)" -eq 1 || { echo "ASSERT FAILED"; exit 1; }
```

Before this task the count is `0`, so this exits nonzero if it is run early; after, `1`. Verified against a simulated tree carrying Plan A's and Plan B's edits.

- [ ] **Amend the WIP commit.**

```bash
git add docs/coding-workflow.md
git commit --amend -m "WIP: review-loop economics"
```

---

## Task 14: The skipped-cycle duties — 1 of 5, `process-pr-review`

**File:** `plugins/dev-workflow/commands/process-pr-review.md`

**Site** — pasted `grep -n`:

```
plugins/dev-workflow/commands/process-pr-review.md:159:   A skip removes the review and never the evidence. Every skipped cycle runs the battery
```

> **A contradiction between two shipped prompts, which invariant 11 forbids.** This command told a skipped cycle it owed the skip reason, the battery result and its evidence entries. Plan B makes the provenance line owed by **every** cycle, skipped or not, and requires a skip record in place of the curve. Left alone, an ordinary trivial-fix skip would close without records the other prompt says are mandatory.
> 
> **This claim lives in five files, and Tasks 14 through 18 are one repair.** I fixed this one and reported it fixed; the sweep found the second and third a pass later, and the fourth and fifth a Gate-A pass after that — each time by grepping for the claim rather than for the phrasing.
> 
> **The rule taken from it, and it is a rule about when rather than what: a fixed statement's other homes are found by grepping for the CLAIM at fix time, not by the next review pass.** Grepping for the phrasing finds the copy you already have; grepping for what the sentence asserts finds the others. `AGENTS.md` records the same failure in a different form, where four rounds each searched for the previous phrase and a synonym survived every time.

- [ ] **Replace.** OLD:

```
   A skip removes the review and never the evidence. Every skipped cycle runs the battery
   and records, in the commit body, **the skip reason and the battery result**. On top of
   that: one mode-derived evidence entry per cited **profiled** story, and none for an
   unprofiled one — which owes the reason and battery result and nothing further.
```

NEW:

```
   A skip removes the review and never the evidence. Every skipped cycle runs the battery
   and records, in the commit body, **the skip reason and the battery result** — and, like
   every other cycle, **its provenance line and, in place of a curve, its skip record**. On
   top of that: one mode-derived evidence entry per cited **profiled** story, and none for an
   unprofiled one — which owes the reason, the battery result, the provenance line and the
   skip record, and nothing further.
```

- [ ] **Assert the new text is present.**

```bash
test "$(grep -cF -- "its provenance line and, in place of a curve, its skip record" plugins/dev-workflow/commands/process-pr-review.md)" -eq 1 || { echo "ASSERT FAILED"; exit 1; }
```

Before this task the count is `0`, so this exits nonzero if it is run early; after, `1`. Verified against a simulated tree carrying Plan A's and Plan B's edits.

- [ ] **Amend the WIP commit.**

```bash
git add plugins/dev-workflow/commands/process-pr-review.md
git commit --amend -m "WIP: review-loop economics"
```

---

## Task 15: The skipped-cycle duties — 2 of 5, `CLAUDE.md` §5

**File:** `CLAUDE.md`

**Site** — pasted `grep -n`:

```
CLAUDE.md:677:the evidence**, and what is owed follows the profile: a skipped **profiled** story runs the
```

> The same claim as the previous task, in the governing copy. See that task's note for the sweep rule.

- [ ] **Replace.** OLD:

```
the evidence**, and what is owed follows the profile: a skipped **profiled** story runs the
battery and lands its evidence entry beside the reason; a skipped **unprofiled** story
records the reason and the battery result and nothing more, because it owes no mode-derived
entry and keeps exactly today's judgement-based skip.
```

NEW:

```
the evidence**, and what is owed follows the profile: a skipped **profiled** story runs the
battery and lands its evidence entry beside the reason; a skipped **unprofiled** story
records the reason and the battery result, because it owes no mode-derived entry and keeps
exactly today's judgement-based skip. **Neither is excused the records every cycle owes** —
the provenance line, and a skip record in place of the curve.
```

- [ ] **Assert the new text is present.**

```bash
test "$(grep -cF -- "Neither is excused the records every cycle owes" CLAUDE.md)" -eq 1 || { echo "ASSERT FAILED"; exit 1; }
```

Before this task the count is `0`, so this exits nonzero if it is run early; after, `1`. Verified against a simulated tree carrying Plan A's and Plan B's edits.

- [ ] **Amend the WIP commit.**

```bash
git add CLAUDE.md
git commit --amend -m "WIP: review-loop economics"
```

---

## Task 16: The skipped-cycle duties — 3 of 5, the scaffolded template

**File:** `plugins/dev-workflow/commands/workflow-init.md`

**Site** — pasted `grep -n`:

```
plugins/dev-workflow/commands/workflow-init.md:856:the evidence**, and what is owed follows the profile: a skipped **profiled** story runs the
```

> The same claim as Tasks 14 and 15, in the mirror. **The assert here counts 1 in this file and the previous task's counts 1 in `CLAUDE.md`** — the same pattern in two files, because the two copies carry the sentence independently and a fix to one has never implied a fix to the other.

- [ ] **Replace.** OLD:

```
the evidence**, and what is owed follows the profile: a skipped **profiled** story runs the
battery and lands its evidence entry beside the reason; a skipped **unprofiled** story
records the reason and the battery result and nothing more, because it owes no mode-derived
entry and keeps exactly today's judgement-based skip.
```

NEW:

```
the evidence**, and what is owed follows the profile: a skipped **profiled** story runs the
battery and lands its evidence entry beside the reason; a skipped **unprofiled** story
records the reason and the battery result, because it owes no mode-derived entry and keeps
exactly today's judgement-based skip. **Neither is excused the records every cycle owes** —
the provenance line, and a skip record in place of the curve.
```

- [ ] **Assert the new text is present.**

```bash
test "$(grep -cF -- "Neither is excused the records every cycle owes" plugins/dev-workflow/commands/workflow-init.md)" -eq 1 || { echo "ASSERT FAILED"; exit 1; }
```

Before this task the count is `0`, so this exits nonzero if it is run early; after, `1`. Verified against a simulated tree carrying Plan A's and Plan B's edits.

- [ ] **Amend the WIP commit.**

```bash
git add plugins/dev-workflow/commands/workflow-init.md
git commit --amend -m "WIP: review-loop economics"
```

---

## Task 17: The skipped-cycle duties — 4 of 5, `getting-started.md`

**File:** `docs/getting-started.md`

**Site** — pasted `grep -n`:

```
docs/getting-started.md:105:   still owes the battery, and records both the skip reason and its evidence entry in the
```

> **The same claim as Tasks 14-16, in an explanatory duty summary.** The three-file sweep stopped
> at the prompt copies. This page and the next task's enumerate the same duties and omit the same
> two records, and they are where a user actually reads what a skip owes — so the failure the
> three-file repair was for survives in the more likely place.

- [ ] **Replace.** OLD:

```
   still owes the battery, and records both the skip reason and its evidence entry in the
   commit body. Gate A is not
```

NEW:

```
   still owes the battery, and records the skip reason, the cycle's provenance line, a skip
   record in place of the curve, and one evidence entry per cited profiled story, in the
   commit body. Gate A is not
```

- [ ] **Assert the new text is present.**

```bash
test "$(grep -cF -- "records the skip reason, the cycle's provenance line, a skip" docs/getting-started.md)" -eq 1 || { echo "ASSERT FAILED"; exit 1; }
```

Before this task the count is `0`, so this exits nonzero if it is run early; after, `1`.

- [ ] **Amend the WIP commit.**

```bash
git add docs/getting-started.md
git commit --amend -m "WIP: review-loop economics"
```

---

## Task 18: The skipped-cycle duties — 5 of 5, `coding-workflow.md`

**File:** `docs/coding-workflow.md`

**Site** — pasted `grep -n`:

```
docs/coding-workflow.md:129:change on security-relevant surface is not eligible. A skip removes the review, never
```

> The same claim as Task 17, in the other explanatory summary. **Both are corrected in the same
> revision**, because fixing one would leave the other teaching it — the rule row 8 of the
> accounting states, applied a second time.

- [ ] **Replace.** OLD:

```
the evidence: the battery still runs, the reason is recorded in the commit body, and
so is one evidence entry per cited profiled story. **Explanatory**
```

NEW:

```
the evidence: the battery still runs, and the commit body carries the reason, the cycle's
provenance line, a skip record in place of the curve, and one evidence entry per cited
profiled story. **Explanatory**
```

- [ ] **Assert the new text is present.**

```bash
test "$(grep -cF -- "the commit body carries the reason, the cycle's" docs/coding-workflow.md)" -eq 1 || { echo "ASSERT FAILED"; exit 1; }
```

Before this task the count is `0`, so this exits nonzero if it is run early; after, `1`.

- [ ] **Amend the WIP commit.**

```bash
git add docs/coding-workflow.md
git commit --amend -m "WIP: review-loop economics"
```

---

## Task 19: The evidence pack

Spec §8 names seven obligations. **All seven are here** — they are what the author owes, not
checks the plan invented about itself. The mode is read from the story header at execution time.

`$base` below is the cycle base — the WIP commit's parent, recorded at cycle open per Task 20's
first fact. It exists before this task runs, because Plan A opened the WIP.

- [ ] **1 — Battery.** The full `AGENTS.md` § Commands chain, green, **including the version-bump
  checker with the recorded base as its argument** — it takes a base ref and **exits 2 with no
  argument**, so the bare invocation is not a run. Plans A and B deferred this step for a stated
  reason; it runs now because Task 11 landed the bump and the WIP exists.

- [ ] **2 — A check that fails without the change**, read against **both** revisions:

```bash
git show "$base":CLAUDE.md | grep -cF 'Blocker/Major-free pass 1 carrying a Minor'
grep -cF 'a Blocker/Major-free pass below the floor' CLAUDE.md
```

**Grep the discriminating text, not the common tail.** Pre-change says **pass 1** keeps looping —
wrong at floor 1, where pass 1 *is* the floor; post-change says **below the floor**. Record which
revision gave which answer.

- [ ] **3 — A named verification of the risk path.** **Runs after the provenance lines are drafted
  and before the close** — it verifies those lines, so it cannot precede them. Recompute each
  line's floor from the `Story:` header of the artifact that cycle reviewed. **The observation that
  would exist if the claim were false is a line whose floor the cited profiles do not license.**

- [ ] **4 — The conditional knob verification.** Take **one** observation of the path and derive
  everything from it, so bytes, digest and value class describe the same read:

  - **absent** — no path. Record not-applicable with that reason. **Do not create one**; a fixture
    supplying its own input proves nothing.
  - **present but not a readable regular file** — a directory, a device, an unreadable file, **or a
    symlink whose target does not resolve**. Record `unusable(unreadable)`. A broken symlink is
    *present and unusable*, never absent — the state the stripped machinery got wrong and the one
    this rule exists for.
  - **a readable regular file** — record bytes and digest, and classify the value as numeric or as
    one of the pinned unusable causes.

  Recorded before the first Gate-B call and compared after. **Existence is not the check.**

- [ ] **5 — Both pinned grammars exercised by the records this cycle actually writes.** The five
  provenance lines and five curves are **written from the grammars** — each field produced by
  reading its production, not by copying an example — and **checked by reading**: they go into the
  closing body, and the Gate-B reviewer receives it. Record which feature each of the ten records
  exercises, and **which productions this branch cannot demonstrate, with the reason** (the cycle
  identifier and the knob clause's non-absent form; see Task 20).

  **No parser is invented here.** A parse check needs a parser, this repo has none for either
  grammar, and *a check that cannot execute is not a check* — the standard revision 3 applied to
  the six it stripped, applied to this one. The programmatic consumer is P8's; until it ships, the
  grammars are enforced by a reader, and this obligation says so rather than implying otherwise.

- [ ] **6 — Parity across every changed rule**, in both copies. **One difference is expected and
  is the only one**: the successor-story pointer, which `CLAUDE.md` carries and the template must
  not.

- [ ] **7 — A fresh twelve-item `docs/prompt-standards.md` pass** over each changed prompt
  artifact invariant 11 names — the **resulting scaffolded template**, **`workflow-init.md`**, and
  **`process-pr-review.md`**. One status row per item per artifact. **Item 1 for the scaffolded
  template is `N/A`**; Task 10 ships the note saying why.

---

## Task 20: The Gate-B cycle and the close

**Run the cycle per `CLAUDE.md` §5.** The floor, the file-first findings protocol,
delete-before-call, what makes a pass valid, single-branch recovery, re-review after every fix, the
clean-final-pass rule and the closing amend are **§5's, and this plan does not restate them**.
Revision 4 did, and Gate-A pass 4 spent seventeen of its twenty-three findings reviewing that
restatement against the rules it was restating. **Three facts belong to this cycle and are not in
§5:**

1. **The base.** Record the WIP commit's parent at cycle open and pass it as `baseSha`, per §5's
   own `baseSha` rule. Plan A prints its base and does not persist it, and Plan A is closed and
   byte-frozen, so this cycle establishes it.

2. **The slots are `gate-b-<spec|quality>-rle-pass-<p>.md`**, never the bare names. This workspace
   already holds **61 files in the bare `gate-b-*-pass-*` family** from earlier cycles, and §5's
   delete-before-call step would destroy them — precisely the incident the slot rule exists to
   prevent, committed by the plan that ships it. Not a nonce either: this cycle is pre-rule and
   cannot mint one. **§8 names exactly this case** — *"its slot discriminator is short and
   deterministic, so it is not a nonce"* — and `rle` is that discriminator.

3. **The cycle runs under the OLD rules**, per the activation constraint: **floor 3**, the
   constant, not the derived value this diff introduces. Carry the old-rules sentence from Global
   Constraints in every call's `additionalContext`.

**Every call also carries** the union of the `Story:` headers of Plans A, B and C, and the current
evidence entry quoted verbatim.

**Before the first call**, confirm `git status --porcelain` is empty and read
`git diff --name-only "$base"..HEAD` against the three plans' declared surface. **This reads path
names, not content**: it catches a stray *file*, not a stray hunk inside a file the plans
legitimately touch.

### What the closing body carries

The evidence entry, and **one provenance line and one curve per cycle — five of each**: one Gate-A
spec cycle, three Gate-A plan cycles, one Gate-B cycle.

**The reconstruction marker sits beside the records, never inside them** — one adjacent line, of
the form *"Records for the Gate-A spec cycle and the three Gate-A plan cycles are reconstructed
from validated pass files; those cycles closed before the forms were active."* — leaving every
record string byte-conformant to its pinned grammar. **A marker inside a record would have to be a
grammar production, and neither grammar has one.** Revision 4 put it inside to survive the squash
carry; the carry copies the body's records, and an adjacent line in the same block travels with
them.

**One line records the superseded artifact:** `2026-08-29-review-loop-economics.md` is superseded
by Plans A, B and C and is not executable. **It is not edited.** Revision 4 shipped a task to mark
it; the spec places supersession remedies out of scope, and Gate-A pass 4 was right that the task
expanded the settled change without an approved decision. A line in the record is what a
closure record is for.

**Every cycle here is pre-rule**, so each carries `cycle none (pre-rule)`. **The branch demonstrates
every field of both forms except two** — the cycle identifier and the knob clause's non-absent form
— **recorded as undemonstrable here with their reasons**, not as gaps and not as satisfied. **Any
cycle that both starts under these rules and closes discharges the nonce demonstration.**

> **Why reconstruction does not contradict §8.** §8 says *"No reconstruction is needed and none is
> claimed"* and gives its grounds in the same breath — *"the Gate-A spec cycle has not closed …
> and the Gate-A plan cycle has not started"*. **That premise failed**: the spec cycle closed at
> pass 34 before the forms existed, and the one plan cycle became three. §8's sentence was a true
> prediction about a topology that changed, and what it protects — that no record silently claims
> to be contemporaneous — is preserved by the adjacent marker. **§8's "three closing bodies" is
> stale for the same reason**, exactly as the story criterion's "a run of all three holds three"
> is: the rule is one record per cycle, and five cycles ran.

---

## Self-Review

**Spec coverage.** §7 rollout — Tasks 1-18. §8 evidence — Task 19, all seven obligations. The
cycle and the close — Task 20.

**What revision 5 removed, and why it is not another over-strip.** Revision 3 stripped six checks
that could not fail and took two real actions with them; revision 4 restored those. **Revision 5
removes something different in kind: the plan's own restatement of a protocol `CLAUDE.md` §5
already owns.** Nothing is lost, because §5 is what an executor follows either way — the
restatement was a second, drifting copy of it, and Gate-A pass 4 reviewed the copy instead of the
rollout. The three facts §5 does *not* carry are stated in Task 20. The mechanics pass 4 found
broken inside the restatement — an unassigned `body`, a symlink-following redirect, a loose
`-\?wip` match, a missing `.context` — **go with it rather than being repaired**, because
repairing them would have kept the copy.

**Inherited obligations.** M9 at Task 19 item 4. M10 in Global Constraints. **M8 and B6 are §5's
own rules** — single-branch recovery, and evidence revalidated after every fix and before the
close — so Task 20 defers to §5 rather than restating them. **MINOR 12 is moot**: it asked for
`mktemp` over a fixed `/tmp` path, and the plan no longer scripts the close at all.

**Known limit.** Gate A reviews this plan, not the edits. What the edits do is Gate B's — Task 20,
reading the real combined diff of all three plans.
