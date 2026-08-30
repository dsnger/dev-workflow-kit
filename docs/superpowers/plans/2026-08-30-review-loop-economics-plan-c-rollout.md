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
> security value, no validation mode and no pass count derived from any of them. Tasks 20 and 22
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
| 19 | spec §8 parse-check item | the evidence is a **parse** check over both grammars | **kept, and its mechanism corrected**: the coverage requirement — constructed valid and invalid strings, features recorded per grammar — is **unchanged**; the word `parse` is replaced by the comparison that exists, a `grep -E` match against each grammar's productions, with the cardinality rule named as the one case decided by counting instead. §5's own rule sends a fix that changes specified behaviour into the same commit (Task 19) |

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
`✓ Codex Gate B satisfied (<counted>/<threshold> cycle, <fresh> on current fingerprint)` — three different numbers: the calls the hook counted this cycle, the hook's own reminder threshold, and how many of those counted calls carry a stored fingerprint equal to the current one. The first is not the calls you made: the hook withholds the count for a recognized failure envelope, the backgrounding notice, and a result it can get no text from. None of the three is the floor §5 obliges — the real commit replaces
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
- **Two commit-body records are pinned**, because a program parses them: a **provenance line**
  carrying the cycle field, the derived floor and the cited set that produced it, and a
  **per-pass curve** carrying Findings, Blockers and Majors per pass. One of each per cycle — a
  change running five cycles records five.
- **A cycle nonce** attributes those records. Eight to sixteen characters from `[a-z0-9]`, from a
  source of randomness, never derived from a name, timestamp or commit. It is
  collision-**resistant**, not collision-proof, and the shipped text says where that bound bites
  rather than implying a guarantee.
- **Findings slots take a per-cycle infix for a cycle holding a nonce**, and for such a cycle the
  deletion step §5 already requires now deletes only paths carrying that cycle's own nonce. **The
  bare names stay valid** and stay reserved for the legacy single-cycle case — a pre-rule or
  no-nonce cycle keeps the bare form, and this release's own Gate-B cycle is one. That rule exists
  because a bare slot was overwritten during this change's own development, destroying a previous
  cycle's findings file.
- **What this change does not settle** is how demotion bears on the loop-health measures — the
  per-pass counts, the clusters and the stop thresholds. That is the loop-rule consolidation
  story's, and both documents say so, so the obligation cannot fall between them.

## 0.10.0
```

- [ ] **Assert the new text is present.**

```bash
test "$(grep -cF -- "The bare names stay valid" plugins/dev-workflow/CHANGELOG.md)" -eq 1 || { echo "ASSERT FAILED"; exit 1; }
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

## Task 19: The spec §8 wording correction

**File:** `docs/superpowers/specs/2026-08-28-review-loop-economics-design.md`

**Site** — pasted `grep -n`:

```
docs/superpowers/specs/2026-08-28-review-loop-economics-design.md:467:- **A parse check over both pinned grammars.** The branch's own instances cannot exercise them:
```

> **§5 sends this here rather than to a Gate-A reopening:** *"A fix that changes specified
> behaviour updates the spec in the same commit."* §8 asks for a **parse** check. No parser for
> either grammar exists in this repo, and none is built — a check that cannot execute is not a
> check. What the pinned forms actually support is a **grep**, because they are field grammars
> with delimiters, and a grep decides the same question for them. **The coverage requirement is
> untouched:** constructed strings, valid and invalid, features recorded per grammar. Only the
> named mechanism changes, and it changes to one that exists.

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
  exercises. **It is a grep, not a parser**: these forms are pinned as greppable field grammars
  and this repo ships no parser for either, so naming a parser would name a check nobody can run.
  The one production a single match cannot decide is the cardinality rule, which is a count and is
  checked by counting the entries on each side. A grammar nothing was ever matched against is a
  format claim, not a format.
```

- [ ] **Assert the new text is present.**

```bash
test "$(grep -cF -- "It is a grep, not a parser" docs/superpowers/specs/2026-08-28-review-loop-economics-design.md)" -eq 1 || { echo "ASSERT FAILED"; exit 1; }
```

Before this task the count is `0`, so this exits nonzero if it is run early; after, `1`.

- [ ] **Amend the WIP commit.**

```bash
git add docs/superpowers/specs/2026-08-28-review-loop-economics-design.md
git commit --amend -m "WIP: review-loop economics"
```

---

## Task 20: The evidence pack — everything that runs before the cycle

Spec §8 names seven obligations. **All seven are discharged, split by when they can run**: six
here, and the two halves that depend on the cycle's own output in Task 22. The mode is read from
the story header at execution time.

**The cycle base is `HEAD^`** — §5's own rule, that `baseSha` is the WIP commit's parent. Exactly
one WIP commit stands (Task 21 checks it), so no variable is recorded and no file holds it.

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
    symlink whose target does not resolve**. Record `unusable(unreadable)`. A broken symlink is
    *present and unusable*, never absent — the state the stripped machinery got wrong and the one
    this rule exists for.
  - **a readable regular file** — record bytes and digest, and classify the value as numeric or as
    one of the pinned unusable causes.

  **Existence is not the check.** Task 22 repeats the observation and compares.

- [ ] **5 — A grammar check over both pinned grammars**, features assigned **per grammar**.
  Construct strings and match each against that grammar's own productions with `grep -E`: valid
  ones must match, invalid ones must not.

  **Provenance:** a quoted path; each `unusable(<CAUSE>)` value; a cited-story-with-no-profile
  entry; `none` for no story cited. **Curve:** a gapped `<SPEC>` such as `1,2,4`; a split-model
  pass; a `?` count; a skipped cycle's skip record. **Each grammar gets at least one string that
  must fail to match** — for provenance, a repeated `<PATH>`.

  **The cardinality rule is the exception, and it is named rather than glossed:** `<COUNTS>` having
  as many entries as `<SPEC>` enumerates is a count, not a match, and no single regex decides it.
  Check it by counting the entries on each side and comparing, with one passing and one failing
  instance. Both routes execute; neither is a parser, which is why Task 19 corrects §8's word for
  it.

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

## Task 21: The Gate-B cycle

**Run the cycle per `CLAUDE.md` §5.** The floor, the file-first findings protocol,
delete-before-call, what makes a pass valid, single-branch recovery, re-review after every fix, the
clean-final-pass rule and the closing amend are **§5's, and this plan does not restate them**.
Revision 4 restated them, and Gate-A pass 4 spent seventeen of twenty-three findings reviewing the
restatement against the rules it was restating. **Three facts belong to this cycle and are not in
§5:**

1. **The base is `HEAD^`.** §5's own rule: `baseSha` is the WIP commit's parent. Confirm first
   that exactly one WIP commit stands and that it is not a merge —

```bash
git rev-parse --verify HEAD^2 >/dev/null 2>&1 && { echo "WIP IS A MERGE — stop"; exit 1; }
git log -1 --pretty=%s | grep -q '^WIP: review-loop economics' || { echo "TIP IS NOT THE WIP"; exit 1; }
git log -1 --pretty=%s HEAD^ | grep -q '^WIP:' && { echo "PARENT IS ALSO A WIP — stacked, collapse first"; exit 1; }
```

   The third asks about a **different** commit, which is why it can fail. A stacked WIP would
   silently leave the earlier snapshot out of the only review.

2. **The slots are `gate-b-<spec|quality>-rle-pass-<p>.md`**, never the bare names. This workspace
   already holds **61 files in the bare `gate-b-*-pass-*` family** — observed when this plan was
   written, so **re-inventory before the first deletion rather than trusting the number**; the
   slot choice is right either way. §5's delete-before-call step would destroy whatever is there,
   which is precisely the incident the slot rule exists to prevent, committed by the plan that
   ships it. Not a nonce either: this cycle is pre-rule and cannot mint one, and **Plan B reserves
   the bare names for exactly the legacy no-nonce case** — which is why the discriminator, not the
   bare name, is what keeps this cycle off the old files. **§8 names this case** — *"its slot
   discriminator is short and deterministic, so it is not a nonce"* — and `rle` is that
   discriminator.

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

## Task 22: The closing body, and the close

**Runs after the final clean pass and before the amend.** The two evidence halves that need the
cycle's own output land here, then the body is composed from them.

- [ ] **3 — A named verification of the risk path.** This cycle emits **one** provenance line.
  Recompute its floor from the `Story:` header of the artifact this cycle reviewed. **The
  observation that would exist if the claim were false is a line whose floor the cited profile
  does not license.**

- [ ] **4b — The knob observation, after the cycle.** Repeat Task 20 item 4a's single observation
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
**recorded as undemonstrable here with their reasons**, not as gaps and not as satisfied. Task 20
item 5's constructed strings are what cover the rest, which is why that obligation exists. **Any
cycle that both starts under these rules and closes discharges the nonce demonstration.**

- [ ] **Close**, per §5's Mechanics: `git commit --amend -m` with the real message replacing the
  WIP one, carrying the four items above. **Not `--no-edit`** — see Global Constraints. If the
  amend fails, **the cycle is invalid, not retryable**: the hook resets Gate-B state on any
  non-WIP commit command whether or not git succeeded. Repair while `HEAD` is still the WIP, run
  the floor again, revalidate the evidence, then close.

---

## Self-Review

**Spec coverage.** §7 rollout — Tasks 1-18. **§8 evidence — Tasks 20 and 22**, all seven
obligations, split at the only line that could split them: whether the obligation needs the
cycle's own output. §8's own wording — Task 19. The cycle and the close — Tasks 21 and 22.

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

**Inherited obligations.** M9 at Task 20 item 4a and Task 22 item 4b. M10 in Global Constraints.
**M8 and B6 are §5's own rules** — single-branch recovery, and evidence revalidated after every
fix and before the close — so Task 21 defers rather than restating. **MINOR 12 is moot**: it asked
for `mktemp` over a fixed `/tmp` path, and the body is now four items carried by §5's own amend.

**Known limit.** Gate A reviews this plan, not the edits. What the edits do is Gate B's — Task 21,
reading the real combined diff of all three plans.
