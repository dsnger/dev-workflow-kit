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
> security value, no validation mode and no pass count derived from any of them. Tasks 22 and 24
> read the mode from the header and produce what it names.

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
- **Every task is skip-if-applied, and the preflight is a decision while the assert is a test.**
  They answer different questions, so they are different commands and **reversing them is a real
  defect**: an assert used as a preflight exits nonzero on `0`, which aborts every task that has
  not run yet. **Preflight**, before the edit, where `0` is a valid answer meaning *apply*:

```sh
case "$(grep -cF -- "<ASSERT-STRING>" <FILE>)" in
  0) : ;;                                             # not applied — apply it
  1) echo "ALREADY APPLIED — skip this task"; exit 0 ;;
  *) echo "AMBIGUOUS — stop, do not retry"; exit 1 ;;  # duplicate or half-applied
esac
```

  **Assert**, after the edit, where anything but `1` is a failure. The `test ... -eq 1` block in
  each task below is that second command, and only that.
- **The assert string discriminates; it does not prove the block landed.** Before amending,
  **read the edited site** and confirm the complete NEW block stands exactly once and — except for
  Tasks 10 and 12 — no OLD text survives beside it. A sentinel counts `1` in a half-applied edit
  and in a file holding OLD and NEW together. **This step is a reading, not a command, and that is
  a limitation rather than a preference:** a multi-line pattern given to `grep -F` is read as
  several alternative patterns, so a whole-block `grep` would silently OR the lines and report a
  match on any one of them.
- **Tasks 10 and 12 re-emit their anchor inside their replacement**, so their OLD text survives
  by design and only the NEW block discriminates. Every other task's OLD text is gone after it
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
| 6 | same, satisfied message | `3/3 cycle`, and `3 on current fingerprint` read as a tally | **replaced with named placeholders** — the numerator is the calls the hook *counted*, the denominator its own threshold, and the third value a *consecutive streak* on the current fingerprint. None is the floor (Task 6) |
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
| 19 | §5 findings-slot rule, as Plan B leaves it | the bare names serve every cycle with no nonce | **kept, unchanged.** The extension this row originally described — a deterministic discriminator for a no-nonce cycle where bare-slot files already exist — was **dropped on 2026-09-02** with Tasks 19 and 20. The rule ships as Plan B leaves it; this cycle's own non-bare slots are a recorded plan-local exception, not a shipped production |
| 20 | the same rule in the scaffolded mirror | as row 19 | same disposition, second copy (Task 20) |
| 21 | spec §8 parse-check item | the evidence is a **parse** check over both grammars | **kept, and its mechanism corrected**: the coverage requirement — constructed valid and invalid strings, features recorded per grammar — is **unchanged**; the word `parse` is replaced by the comparison that exists, a `grep -E` match against each grammar's productions, with the cardinality rule named as the one case decided by counting instead. §5's own rule sends a fix that changes specified behaviour into the same commit (Task 21) |

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
`✓ Codex Gate B satisfied (<counted>/<threshold> cycle, <fresh> on current fingerprint)` — three different numbers: the calls the hook counted this cycle, the hook's own reminder threshold, and the **consecutive** counted calls on the current fingerprint since it last changed. The first is not the calls you made: the hook withholds the count for a recognized failure envelope, the backgrounding notice, and a result it can get no text from. The third is a streak, not a tally — the hook keeps the last fingerprint and that streak, so a pass on a changed fingerprint restarts it and an earlier matching pass separated by a different fingerprint is not counted. None of the three is the floor §5 obliges — the real commit replaces
```

- [ ] **Assert the new text is present.**

```bash
test "$(grep -cF -- "the calls the hook counted this cycle" docs/getting-started.md)" -eq 1 || { echo "ASSERT FAILED"; exit 1; }
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
- **Two commit-body records are pinned**, so that a program can parse them — P8's deferred
  measurement is the intended consumer, and **no parser for either form ships today**; the
  evidence for this release matched constructed strings against the grammars instead: a
  **provenance line**
  carrying the cycle field, the derived floor and the cited set that produced it, and a
  **per-pass curve** carrying Findings, Blockers and Majors per pass. One of each per cycle — a
  change running five cycles records five.
- **A cycle nonce** attributes those records. Eight to sixteen characters from `[a-z0-9]`, from a
  source of randomness, never derived from a name, timestamp or commit. It is
  collision-**resistant**, not collision-proof, and the shipped text says where that bound bites
  rather than implying a guarantee.
- **Findings slots take a per-cycle infix**, and the deletion step §5 already requires deletes
  only paths carrying the cycle's own infix. A cycle that holds a **nonce** uses it; a cycle with
  **no** nonce keeps the **bare** names. A cycle deletes only its own paths, never a bare path
  belonging to somebody else and never another cycle's. That rule exists because a bare slot was
  overwritten during this change's own development, destroying a previous cycle's findings file.
  **What this release does not ship** is a rule for the remaining case — a nonce-less cycle where
  bare-slot files already exist. This release's own Gate-B cycle is that case, and it used a
  recorded plan-local naming exception rather than a shipped rule; a general production is
  deferred to the loop-rule consolidation story.
- **What this change does not settle** is how demotion bears on the loop-health measures — the
  per-pass counts, the clusters and the stop thresholds. That is the loop-rule consolidation
  story's, and both documents say so, so the obligation cannot fall between them.

## 0.10.0
```

- [ ] **Assert the new text is present.**

```bash
test "$(grep -cF -- "no parser for either form ships today" plugins/dev-workflow/CHANGELOG.md)" -eq 1 || { echo "ASSERT FAILED"; exit 1; }
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

## Task 19: DROPPED — the slot rule admits a deterministic discriminator — 1 of 2, `CLAUDE.md`

> **DROPPED by author decision, 2026-09-02. Do not execute this task or Task 20.** Shipping the
> discriminator would have put a slot production into both prompt copies that the approved spec's
> slot rules do not contain, leaving the source-of-truth section stale — Gate-A pass 7's first
> BLOCKER. The general production is deferred to the loop-rule consolidation successor story.
> **What replaces it for this cycle:** the `rle` slot names are a recorded plan-local naming
> exception under the old rules, approved by the author and recorded in the closing commit body
> and the field report. Task 23's second point cites Tasks 19 and 20 as admitting the name; read
> that citation as superseded by this exception. Task 21 is unaffected: it never touched the slot
> section, which is why dropping these two leaves nothing stale. §5

**File:** `CLAUDE.md`

**Site** — pasted `grep -n`, against the tree Plan B leaves behind:

```
CLAUDE.md:  > the nonce in every slot more than one cycle could write. The bare names are reserved for the
```

> **This is the contradiction Gate-A pass 6 found, and it was a real one.** Plan B's shipped rule
> sends a cycle with **no nonce** to the bare slot names. This cycle has no nonce — it is pre-rule
> and cannot mint one — so the shipped rule sends it to the bare names, **into the one workspace
> that already holds 61 bare-slot files**, where §5's delete-before-call step destroys them. Task
> 23 uses `gate-b-<spec|quality>-rle-pass-<p>`, which the shipped grammar admits nowhere: neither
> a bare name nor a nonce. **The plan and the prompt it ships cannot both be followed.**
>
> **Resolved one way, and this is the way:** the shipped rule gains the production. Spec §8
> already describes it — *"its slot discriminator is short and deterministic, so it is not a
> nonce"* — so this makes the prompt state what the approved spec already assumes, rather than
> inventing a rule. The alternative, bare names plus a hand-rolled preservation step, recreates
> the incident the rule exists to prevent and leaves the spec's sentence describing nothing.
>
> **It admits a discriminator; it promises nothing about collisions.** A deterministic value is
> not drawn, so two cycles that pick the same one collide by construction. The text says so.

- [ ] **Replace.** OLD — the complete sentence pair, so the replacement leaves no half-line:

```
> the nonce in every slot more than one cycle could write. The bare names are reserved for the
> legacy single-cycle case they already serve. **Distinct-nonce paths coexist by construction and
> are never in conflict** — a sibling cycle's slot is simply a different file.
```

NEW:

```
> the nonce in every slot more than one cycle could write. The bare names are reserved for the
> legacy single-cycle case they already serve — **with one exception, and it is the case that
> caused the incident**: a cycle with **no** nonce, writing into a workspace that already holds
> bare-slot files from earlier cycles, takes a **short, deterministic discriminator** in the
> nonce's position (`gate-b-<spec|quality>-<disc>-pass-<p>`, and likewise for the Gate-A forms).
> **It is not a nonce and claims none of a nonce's properties** — it is derived rather than drawn,
> so two cycles choosing the same discriminator compute the same paths and are indistinguishable,
> exactly as two cycles drawing the same nonce would be. It binds the deletion step the same way:
> such a cycle **deletes only paths carrying its own discriminator**, never a bare path and never
> another cycle's. **Distinct-nonce paths coexist by construction and are never in conflict** — a
> sibling cycle's slot is simply a different file, and so is a distinct-discriminator path.
```

- [ ] **Assert the new text is present.**

```bash
test "$(grep -cF -- "takes a **short, deterministic discriminator** in the" CLAUDE.md)" -eq 1 || { echo "ASSERT FAILED"; exit 1; }
```

Before this task the count is `0`, so this exits nonzero if it is run early; after, `1`.

- [ ] **Amend the WIP commit.**

```bash
git add CLAUDE.md
git commit --amend -m "WIP: review-loop economics"
```

---

## Task 20: DROPPED — the slot rule admits a deterministic discriminator — 2 of 2, the scaffolded template

> **DROPPED by author decision, 2026-09-02, together with Task 19. Do not execute it.** See the
> note under Task 19 for the reason and for what replaces it. Task 23's second point and this
> plan's Self-Review both still say these two tasks admit the `rle` name into the shipped rule;
> read both as superseded by the recorded plan-local naming exception.

**File:** `plugins/dev-workflow/commands/workflow-init.md`

**Site** — pasted `grep -n`, against the tree Plan B leaves behind:

```
plugins/dev-workflow/commands/workflow-init.md:  > the nonce in every slot more than one cycle could write. The bare names are reserved for the
```

> The same edit in the mirror. Plan B wrote this passage into both copies in one task; **Plan C
> corrects it in two**, because the assert counts `1` in each file separately and a fix to one
> has never implied a fix to the other. Invariant 11 forbids the two prompts disagreeing, and
> item 6 of the evidence pack is where that is demonstrated.

- [ ] **Replace.** Same OLD and NEW as Task 19, in this file.

- [ ] **Assert the new text is present.**

```bash
test "$(grep -cF -- "takes a **short, deterministic discriminator** in the" plugins/dev-workflow/commands/workflow-init.md)" -eq 1 || { echo "ASSERT FAILED"; exit 1; }
```

Before this task the count is `0`, so this exits nonzero if it is run early; after, `1`.

- [ ] **Amend the WIP commit.**

```bash
git add plugins/dev-workflow/commands/workflow-init.md
git commit --amend -m "WIP: review-loop economics"
```

---

## Task 21: The spec §8 wording correction

**File:** `docs/superpowers/specs/2026-08-28-review-loop-economics-design.md`

**Site** — pasted `grep -n`:

```
docs/superpowers/specs/2026-08-28-review-loop-economics-design.md:467:- **A parse check over both pinned grammars.** The branch's own instances cannot exercise them:
```

> **§5 sends this here rather than to a Gate-A reopening:** *"A fix that changes specified
> behaviour updates the spec in the same commit."* §8 asks for a **parse** check. No parser for
> either grammar exists in this repo, and none is built — a check that cannot execute is not a
> check. **The coverage requirement is untouched:** constructed strings, valid and invalid,
> features recorded per grammar. Only the named mechanism changes, and it changes to what exists.
>
> **A grep is not the whole of it, and revision 6 said it was.** That revision named cardinality
> as the single rule a match cannot decide. It is not the only one, and claiming so was the same
> overclaim in a smaller font. Every constraint a single regular match cannot decide is named in
> the replacement and checked by a separate comparison over the extracted fields.
>
> **This task carries a second replacement, in §1.** The same claim lives there in the present
> tense — *"a program parses them"* — about a program that does not exist. One claim, both sites,
> one pass.

- [ ] **Replace.** OLD:

```
- **A parse check over both pinned grammars.** The branch's own instances cannot exercise them:
  three lines cannot cover quoted paths, each unusable-knob cause, gapped pass ranges, split-model
  passes, a skipped cycle, or the cardinality rule that `<COUNTS>` matches `<SPEC>`. **The check
  reads a set of constructed strings — valid ones that must parse and invalid ones that must be
  rejected** — and records which grammar features each exercises. A grammar nothing ever parsed is
  a format claim, not a format.
```

NEW:

```
- **A grammar check over both pinned grammars.** The branch's own instances cannot exercise them:
  three lines cannot cover quoted paths, each unusable-knob cause, gapped pass ranges, split-model
  passes, a skipped cycle, or the cardinality rule that `<COUNTS>` matches `<SPEC>`. **The check
  matches a set of constructed strings against each grammar's own productions with `grep -E` —
  valid ones must match, invalid ones must not** — and records which grammar features each
  exercises. **It is a grep plus field comparisons, not a parser**: these forms are pinned as
  greppable field grammars and this repo ships no parser for either, so naming a parser would name
  a check nobody can run. **A match decides the lexical productions and nothing else.** Every
  constraint it cannot decide is checked by a comparison over the extracted fields: `<COUNTS>`
  having as many entries as `<SPEC>` enumerates; a `<PATH>` occurring more than once; `<SPEC>`
  ranges ascending and non-overlapping; a per-pass key present in one field and absent from its
  partner. **That list is what reading both grammars for non-regular constraints produced, and it
  is not proven complete** — a further one is checked the same way rather than folded into the
  match. A grammar nothing was ever matched against is a format claim, not a format.
```

- [ ] **Assert the new text is present.**

```bash
test "$(grep -cF -- "It is a grep plus field comparisons, not a parser" docs/superpowers/specs/2026-08-28-review-loop-economics-design.md)" -eq 1 || { echo "ASSERT FAILED"; exit 1; }
```

Before this task the count is `0`, so this exits nonzero if it is run early; after, `1`.

- [ ] **Replace, second site — §1, the same claim in the present tense.** OLD:

```
spec. Two things stay pinned as *required properties* because a shipped criterion reads them and a
program parses them: the provenance line (§2.3) and the per-pass curve (§4).
```

NEW:

```
spec. Two things stay pinned as *required properties* because a shipped criterion reads them and a
program is intended to parse them — P8's deferred measurement, which does not exist yet: the
provenance line (§2.3) and the per-pass curve (§4).
```

> **Left alone deliberately:** §2.3's *"P8 parses it"* and §2.4's *"the deferred P8 measurement
> parses it"* already name the consumer as deferred, and §2.4's *"a parser needs no special case"*
> is a property of the grammar rather than a claim that one exists.

- [ ] **Assert the second replacement.**

```bash
test "$(grep -cF -- "program is intended to parse them — P8's deferred measurement, which does not exist yet" docs/superpowers/specs/2026-08-28-review-loop-economics-design.md)" -eq 1 || { echo "ASSERT FAILED"; exit 1; }
```

Before this task the count is `0`, so this exits nonzero if it is run early; after, `1`.

- [ ] **Amend the WIP commit.**

```bash
git add docs/superpowers/specs/2026-08-28-review-loop-economics-design.md
git commit --amend -m "WIP: review-loop economics"
```

---

## Task 22: The evidence pack — everything that runs before the cycle

Spec §8 names seven obligations. **All seven are discharged, split by when they can run**: six
here, and the two halves that depend on the cycle's own output in Task 24. The mode is read from
the story header at execution time.

**The cycle base is `HEAD^`** — §5's own rule, that `baseSha` is the WIP commit's parent. Exactly
one WIP commit stands (Task 23 checks it), so no variable is recorded and no file holds it.

- [ ] **1 — Battery.** The full `AGENTS.md` § Commands chain, green, **with the version-bump
  checker given `HEAD^` as its base ref** — it takes one and **exits 2 with no argument**, so the
  bare invocation is not a run. Plans A and B deferred this step for a stated reason; it runs now
  because Task 11 landed the bump and the WIP exists.

- [ ] **2 — A check that fails without the change.** Four assertions, two per revision:

```bash
test "$(git show HEAD^:CLAUDE.md | grep -cF 'Blocker/Major-free pass 1 carrying a Minor')" -eq 1 || { echo "BASE LACKS THE OLD SENTENCE"; exit 1; }
test "$(git show HEAD^:CLAUDE.md | grep -cF 'a Blocker/Major-free pass below the floor')" -eq 0 || { echo "BASE ALREADY CARRIES THE NEW ONE"; exit 1; }
test "$(grep -cF 'Blocker/Major-free pass 1 carrying a Minor' CLAUDE.md)" -eq 0 || { echo "OLD SENTENCE SURVIVES"; exit 1; }
test "$(grep -cF 'a Blocker/Major-free pass below the floor' CLAUDE.md)" -eq 1 || { echo "NEW SENTENCE MISSING"; exit 1; }
```

**Grep the discriminating text, not the common tail.** Pre-change says **pass 1** keeps looping —
wrong at floor 1, where pass 1 *is* the floor; post-change says **below the floor**. **The
counterfactual is the third and fourth assertions**: without the change they fail, and the wiring
can produce that failure because the first two show the old text really is in the base. The
scaffolded mirror carries this rule too and is covered by item 6, which compares both copies.

- [ ] **4a — The knob observation, before the cycle.** Take **one** observation of
  `.context/codex-gate.floor` and derive everything from it, so bytes, digest and value class
  describe the same read:

  - **absent** — no path. Record not-applicable with that reason. **Do not create one**; a fixture
    supplying its own input proves nothing.
  - **present but not a readable regular file** — a directory, a device, an unreadable file, **or a
    symlink whose target does not resolve**. Record `unusable`. A broken symlink is
    *present and unusable*, never absent — the state the stripped machinery got wrong and the one
    this rule exists for. (The cause token this step originally recorded was withdrawn on
    2026-09-02; `unusable` no longer carries one.)
  - **a readable regular file** — record bytes and digest, and classify the value as numeric or as
    one of the pinned unusable causes.

  **Existence is not the check.** Task 24 repeats the observation and compares.

- [ ] **5 — A grammar check over both pinned grammars**, features assigned **per grammar**.
  Construct strings and match each against that grammar's own productions with `grep -E`: valid
  ones must match, invalid ones must not.

  **Provenance:** a quoted path; the `unusable` value; **a valid numeric knob value**;
  a cited-story-with-no-profile entry; `none` for no story cited; **a real `cycle <nonce>` field**.
  **Curve:** a gapped `<SPEC>` such as `1,2,4`; a split-model pass; a `?` count; a skipped cycle's
  skip record; **a `cycle <nonce>` field, the same nonce as the provenance instance**, so
  cross-record agreement is exercised too. **Each grammar gets at least one string that must fail
  to match** — for provenance, a malformed nonce.

  **The nonce and the numeric knob are in this list for a specific reason:** they are exactly the
  two fields the live cycle cannot produce (Task 24), so without them the close would record as
  covered two productions nothing ever exercised. What stays undemonstrable is narrower and is
  named there: that a *drawn* nonce attributes a *live* cycle. A constructed one exercises the
  form, not the attribution.

  **What a match cannot decide, checked by comparison instead** — each with one passing and one
  failing instance: `<COUNTS>` having as many entries as `<SPEC>` enumerates; a `<PATH>` occurring
  twice; `<SPEC>` ranges out of order or overlapping; a per-pass key present in one field and
  absent from its partner. **That list came from reading both grammars for constraints no single
  regular match decides, and it is not proven complete.** Both routes execute; neither is a
  parser, which is why Task 21 corrects §8's word for it — **and revision 6's claim that
  cardinality was the only such rule was itself an overclaim**, which is why this list is four
  items and carries its own limit.

  Record which feature each string exercises. **This is where the grammars get their coverage** —
  the cycle's own two records cannot, which is the reason §8 asked for constructed strings.

- [ ] **6 — Parity across every changed rule**, in both copies. **One difference is expected and
  is the only one**: the successor-story pointer, which `CLAUDE.md` carries and the template must
  not.

- [ ] **7 — A fresh twelve-item `docs/prompt-standards.md` pass** over each changed prompt
  artifact invariant 11 names — the **resulting scaffolded template**, **`workflow-init.md`**, and
  **`process-pr-review.md`**. One status row per item per artifact. **Item 1 for the scaffolded
  template is `N/A`**; Task 10 ships the note saying why.

---

## Task 23: The Gate-B cycle

**Run the cycle per `CLAUDE.md` §5.** The floor, the file-first findings protocol,
delete-before-call, what makes a pass valid, single-branch recovery, re-review after every fix, the
clean-final-pass rule and the closing amend are **§5's, and this plan does not restate them**.
Revision 4 restated them, and Gate-A pass 4 spent seventeen of twenty-three findings reviewing the
restatement against the rules it was restating. **Three facts belong to this cycle and are not in
§5:**

1. **The base is `HEAD^`.** §5's own rule: `baseSha` is the WIP commit's parent. Confirm first
   that exactly one WIP commit stands and that it is not a merge —

```bash
if ! git rev-parse --verify HEAD^ >/dev/null 2>&1; then echo "NO PARENT — no cycle base"; exit 1; fi
if git rev-parse --verify HEAD^2 >/dev/null 2>&1; then echo "WIP IS A MERGE — stop"; exit 1; fi
if ! git log -1 --pretty=%s | grep -q '^WIP: review-loop economics'; then echo "TIP IS NOT THE WIP"; exit 1; fi
if git log -1 --pretty=%s HEAD^ | grep -q '^WIP:'; then echo "PARENT IS ALSO A WIP — stacked, collapse first"; exit 1; fi
echo "BASE OK: $(git rev-parse HEAD^)"
```

**Every guard is an `if`, and the block ends on a command that succeeds.** Written as
`<test> && { …; exit 1; }`, the last guard returns the failing grep's status **1 in the desired
state** — the parent correctly not being a WIP — so the block reports failure exactly when it
should report success, and under `set -e` the first negative guard aborts before the others run.

   The third asks about a **different** commit, which is why it can fail. A stacked WIP would
   silently leave the earlier snapshot out of the only review.

2. **The slots are `gate-b-<spec|quality>-rle-pass-<p>.md`**, and since Tasks 19 and 20 were
   dropped, `rle` is admitted by **no shipped rule at all**: it is a **recorded plan-local naming
   exception** under the old rules, approved by the author on 2026-09-02 and recorded in the
   closing commit body and the field report. That is the whole of its authority. **§8 states the same thing** — *"its slot discriminator is short and
   deterministic, so it is not a nonce"*.

   The reason it is needed here: this cycle is pre-rule and **cannot mint a nonce**, so the
   shipped rule would send it to the bare names — into a workspace that already holds **61 files
   in the bare `gate-b-*-pass-*` family**, where §5's delete-before-call step would destroy them.
   That is precisely the incident the slot rule exists to prevent, about to be committed by the
   plan that ships it. **Re-inventory before the first deletion rather than trusting the count**:
   61 was observed when this plan was written, and the discriminator is right at any number.

   **`rle` is not collision-resistant and claims nothing of the sort.** It is derived from the
   change's name, so a second concurrent Plan-C executor computes the same paths. Before the
   first deletion, confirm no live writer owns them; **stop rather than delete a target whose
   owner you cannot establish.**

3. **The cycle runs under the OLD rules**, per the activation constraint: **floor 3**, the
   constant, not the derived value this diff introduces. Carry the old-rules sentence from Global
   Constraints in every call's `additionalContext`.

**Every call also carries** the union of the `Story:` headers of Plans A, B and C, and the current
evidence entry quoted verbatim.

**Before the first call**, confirm `git status --porcelain` is empty and read
`git diff --name-only HEAD^..HEAD` against the three plans' declared surface. **This reads path
names, not content** — it catches a stray *file*, not a stray hunk inside a file the plans
legitimately touch. **Read the full `git diff HEAD^..HEAD` too**, against each task's own OLD-to-NEW
text above; that is the check that covers hunks, and it is a reading because the plan's OLD and NEW
blocks are what it compares against.

---

## Task 24: The closing body, and the close

**Runs after the final clean pass and before the amend.** The two evidence halves that need the
cycle's own output land here, then the body is composed from them.

- [ ] **3 — A named verification of the risk path.** This cycle emits **one** provenance line.
  Recompute its floor from the **union of the `Story:` headers of every plan contributing to the
  reviewed diff** — Gate B reviews a diff and has no header of its own, which is what the shipped
  rule says. (For this cycle all three plans cite one story, so the union is one path.) **The
  observation that would exist if the claim were false is a line whose floor the cited profile
  does not license.**

- [ ] **4b — The knob observation, after the cycle.** Repeat Task 22 item 4a's single observation
  and assert equality with the before-state: same path type, same bytes, same digest, or the same
  recorded absence. **The knob is never written or removed by this plan**; this is what makes that
  a demonstrated claim rather than an assurance.

- [ ] **Revalidate the evidence entry** against the content the close will carry — §5 requires it
  after every fix and again before the closing amend, and a fix changes the diff even when the
  profile sits still.

### What the closing body carries — and this is the complete list

1. **The evidence entry**, one per cited **profiled** story, per §5. The story governing this
   cycle is profiled, so there is one.
2. **This Gate-B cycle's provenance line.**
3. **This Gate-B cycle's per-pass curve.**
4. **Decline records**, if the cycle produced any.
5. **The `rle` naming exception**, which Task 23 requires be recorded here — a plan-local
   exception under the old rules, approved by the author 2026-09-02, with no shipped rule
   behind it.
6. **The standing decision record** for this cycle: the pass-2 discount, the dropped Tasks 19
   and 20, the withdrawn knob-cause and model-cause vocabulary with its accepted capability
   cost, and the closing disposition.

**Nothing else, and the exclusions are the point.** No records for the four Gate-A cycles, no
reconstruction, no reconstruction marker, no adjacent prose explaining one, and no line about the
superseded single-plan artifact. **Those four cycles closed before these rules bound anything, and
their record is `docs/field-reports/2026-08-30-gate-a-rle-plan-cycles.md`** — committed prose, which
git carries without a carry rule. Revision 4 put them in the body with a marker inside each record,
which broke the pinned grammar; revision 5 moved the marker beside the records, where the
squash-carry rule — which enumerates provenance lines, curves and skip records — does not reach it.
**The destination was the error, not the marker's position.**

**The cycle field is `cycle none (pre-rule)`.** Plan B reserves that value for a cycle that began
before the rules shipped, and this one did. **The branch therefore demonstrates every field of both
forms except two** — a real nonce, and the knob clause's non-absent form if the knob is absent —
**recorded as undemonstrable here with their reasons**, not as gaps and not as satisfied. Task 22
item 5's constructed strings are what cover the rest, which is why that obligation exists. **Any
cycle that both starts under these rules and closes discharges the nonce demonstration.**

- [ ] **Close**, per §5's Mechanics: `git commit --amend -m` with the real message replacing the
  WIP one, carrying the four items above. **Not `--no-edit`** — see Global Constraints. If the
  amend fails, **the cycle is invalid, not retryable**: the hook resets Gate-B state on any
  non-WIP commit command whether or not git succeeded. Repair while `HEAD` is still the WIP, run
  the floor again, revalidate the evidence, then close.

---

## Task 25: Complete the field report

**File:** `docs/field-reports/2026-08-30-gate-a-rle-plan-cycles.md`

**Runs after Task 24's closing amend**, as an **ordinary docs commit** — the first ordinary commit
this plan makes, and it is allowed because the cycle is closed. `docs/field-reports/**.md` is
explanatory prose, so Gate B is N/A.

> **Why this task exists at all.** That file is the destination chosen for the four pre-rule
> Gate-A cycles' records, precisely so the observability those records carry survives outside the
> commit body. It currently says Plan C's cycle is **open at five passes** and promises the
> closing figures in a later revision. **Nothing scheduled that revision.** An artifact chosen for
> observability and then left knowingly incomplete is worse than no artifact, because a reader
> takes its silence for the end of the story.

- [ ] **Extract Plan C's final curve mechanically**, the way that file's own numbers were taken:

```bash
n=1
while [ -f ".context/codex-reviews/gate-a-plan-planc-pass-$n.md" ]; do
  f=$(grep -cE '^(BLOCKER|MAJOR|MINOR|NIT) \|' ".context/codex-reviews/gate-a-plan-planc-pass-$n.md")
  b=$(grep -c '^BLOCKER' ".context/codex-reviews/gate-a-plan-planc-pass-$n.md")
  m=$(grep -c '^MAJOR' ".context/codex-reviews/gate-a-plan-planc-pass-$n.md")
  printf 'pass %d: %s findings, %s B, %s M\n' "$n" "$f" "$b" "$m"
  n=$((n+1))
done
```

- [ ] **Replace the provisional passage** — the one saying the cycle is open at five passes and
  promising later figures — with the closed cycle's full three-row block, in the same format the
  Plan A and Plan B blocks use.

- [ ] **Assert the provisional wording is gone and the closed record is present.**

```bash
test "$(grep -cF -- "Open at 5 passes when this file was written" docs/field-reports/2026-08-30-gate-a-rle-plan-cycles.md)" -eq 0 || { echo "PROVISIONAL WORDING SURVIVES"; exit 1; }
```

- [ ] **Commit it alone**, ordinary message, no `WIP:` prefix — the cycle is already closed and
  this content was never part of the reviewed diff.

---

## Self-Review

**Spec coverage.** §7 rollout — Tasks 1-18. The shipped slot rule — Tasks 19 and 20. §8's own
wording — Task 21. **§8 evidence — Tasks 22 and 24**, all seven obligations, split at the only
line that could split them: whether the obligation needs the cycle's own output. The cycle and the
close — Tasks 23 and 24. The durable record — Task 25.

**Revision 7's method was a claim sweep, not per-finding repair**, because pass 6 showed the
disease. Three of its findings were one claim corrected in one place and left standing in another
— all mine, all inside revision 6. Six claims were enumerated, every statement site grepped, and
every occurrence fixed in one pass: `AGENTS.md`'s own recipe, *search for the claim, not the
phrase*, used as the method rather than as a warning about it. The claim-to-site map is in the
commit body.

**One of those claims changed what the plan ships**, and it was not a wording fix. The slot rule
was to gain a production (Tasks 19 and 20) — **that was dropped on 2026-09-02**, and the plan's
own slot form is now a recorded plan-local exception instead of a shipped rule. And **§8's
mechanism names four constraints a grep cannot decide instead of one**, because revision 6's
correction of an overclaim was itself an overclaim.

**The dependency cycle is gone.** Revision 5 put the whole evidence pack before the cycle while
three of its seven items needed the cycle's output, so no task could truthfully complete. Items 3
and 4b now sit after the final clean pass, where their inputs exist.

**Reconstruction is gone, and the reason is worth keeping.** Three Gate-A passes contested it on
three different grounds — wrong destination, a marker that broke the grammar from inside, a marker
the squash-carry rule does not reach from outside. Two revisions answered the second and third and
left the first standing. **The destination was the error.** Pre-rule history is committed prose in
`docs/field-reports/`; the commit body carries only what this cycle natively produced.

**`$base` is gone too.** §5 already says `baseSha` is the WIP commit's parent, so `HEAD^` is the
value, deterministic from git — no recorded variable, no file under `.context/`, and none of the
failure paths a recorded one brought with it.

**What is still not mechanical**, said once rather than implied: the whole-block confirmation,
the parity comparison and the twelve-item pass are **readings, not commands**, and are named as
readings wherever they appear. Nothing checks a reading. That is a limit of this plan.

**Inherited obligations.** M9 at Task 22 item 4a and Task 24 item 4b. M10 in Global Constraints.
**M8 and B6 are §5's own rules** — single-branch recovery, and evidence revalidated after every
fix and before the close — so Task 23 defers rather than restating. **MINOR 12 is moot**: it asked
for `mktemp` over a fixed `/tmp` path, and the body is now four items carried by §5's own amend.

**Known limit.** Gate A reviews this plan, not the edits. What the edits do is Gate B's — Task 23,
reading the real combined diff of all three plans.
