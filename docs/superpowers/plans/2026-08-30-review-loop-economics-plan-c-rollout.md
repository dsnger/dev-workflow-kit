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
> security value, no validation mode and no pass count derived from any of them. Task 13 reads the
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

---

## Old-conditions accounting

§6's method, applied to a different class: these passages are not §5 rules but **user-facing
statements that Plans A and B make false**. For each, what it asserted and what replaces it.

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

**Rows 10 and 12 are insertions and are listed so a reader can confirm that rather than assume
it.** Each re-emits its anchor verbatim inside its replacement.

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
grep -cF -- "moves the hook's reminder threshold. It does not change the floor" README.md
```

Before this task: `0`. After: `1`. Verified against a simulated tree carrying Plan A's and Plan B's edits.

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
grep -cF -- "the floor its profile derives, final pass clean" docs/getting-started.md
```

Before this task: `0`. After: `1`. Verified against a simulated tree carrying Plan A's and Plan B's edits.

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
grep -cF -- "the same loop runs at the derived floor" docs/getting-started.md
```

Before this task: `0`. After: `1`. Verified against a simulated tree carrying Plan A's and Plan B's edits.

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
grep -cF -- "If the hook's own threshold wasn't met, it says" docs/getting-started.md
```

Before this task: `0`. After: `1`. Verified against a simulated tree carrying Plan A's and Plan B's edits.

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
grep -cF -- "the derived floor, final clean. Verification is by" docs/getting-started.md
```

Before this task: `0`. After: `1`. Verified against a simulated tree carrying Plan A's and Plan B's edits.

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
grep -cF -- "three different numbers: the calls this cycle made" docs/getting-started.md
```

Before this task: `0`. After: `1`. Verified against a simulated tree carrying Plan A's and Plan B's edits.

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
grep -cF -- "Gate A's floor derives from the profile exactly as Gate B's does" docs/getting-started.md
```

Before this task: `0`. After: `1`. Verified against a simulated tree carrying Plan A's and Plan B's edits.

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
grep -cF -- "moves the hook's reminder threshold, and" docs/getting-started.md
```

Before this task: `0`. After: `1`. Verified against a simulated tree carrying Plan A's and Plan B's edits.

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
grep -cF -- "floor itself derives from the profile, so it is not the same at every level" docs/coding-workflow.md
```

Before this task: `0`. After: `1`. Verified against a simulated tree carrying Plan A's and Plan B's edits.

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
grep -cF -- "Prompt-standards item 1 for the scaffolded" plugins/dev-workflow/commands/workflow-init.md
```

Before this task: `0`. After: `1`. Verified against a simulated tree carrying Plan A's and Plan B's edits.

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
grep -cF -- '"version": "0.11.0"' plugins/dev-workflow/.claude-plugin/plugin.json
```

Before this task: `0`. After: `1`. Verified against a simulated tree carrying Plan A's and Plan B's edits.

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
grep -cF -- "The mandatory pass floor is now a function of the cited story's profile" plugins/dev-workflow/CHANGELOG.md
```

Before this task: `0`. After: `1`. Verified against a simulated tree carrying Plan A's and Plan B's edits.

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
grep -cF -- "the finding count in **the cycle's per-pass curve**" docs/coding-workflow.md
```

Before this task: `0`. After: `1`. Verified against a simulated tree carrying Plan A's and Plan B's edits.

- [ ] **Amend the WIP commit.**

```bash
git add docs/coding-workflow.md
git commit --amend -m "WIP: review-loop economics"
```

---

## Task 14: The skipped-cycle duties — 1 of 3, `process-pr-review`

**File:** `plugins/dev-workflow/commands/process-pr-review.md`

**Site** — pasted `grep -n`:

```
plugins/dev-workflow/commands/process-pr-review.md:159:   A skip removes the review and never the evidence. Every skipped cycle runs the battery
```

> **A contradiction between two shipped prompts, which invariant 11 forbids.** This command told a skipped cycle it owed the skip reason, the battery result and its evidence entries. Plan B makes the provenance line owed by **every** cycle, skipped or not, and requires a skip record in place of the curve. Left alone, an ordinary trivial-fix skip would close without records the other prompt says are mandatory.
> 
> **This claim lives in three files, and Tasks 14, 15 and 16 are one repair.** I fixed this one and reported it fixed; the sweep found the second and third a pass later.
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
grep -cF -- "its provenance line and, in place of a curve, its skip record" plugins/dev-workflow/commands/process-pr-review.md
```

Before this task: `0`. After: `1`. Verified against a simulated tree carrying Plan A's and Plan B's edits.

- [ ] **Amend the WIP commit.**

```bash
git add plugins/dev-workflow/commands/process-pr-review.md
git commit --amend -m "WIP: review-loop economics"
```

---

## Task 15: The skipped-cycle duties — 2 of 3, `CLAUDE.md` §5

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
grep -cF -- "Neither is excused the records every cycle owes" CLAUDE.md
```

Before this task: `0`. After: `1`. Verified against a simulated tree carrying Plan A's and Plan B's edits.

- [ ] **Amend the WIP commit.**

```bash
git add CLAUDE.md
git commit --amend -m "WIP: review-loop economics"
```

---

## Task 16: The skipped-cycle duties — 3 of 3, the scaffolded template

**File:** `plugins/dev-workflow/commands/workflow-init.md`

**Site** — pasted `grep -n`:

```
plugins/dev-workflow/commands/workflow-init.md:856:the evidence**, and what is owed follows the profile: a skipped **profiled** story runs the
```

> The same claim as the previous two, in the mirror. **The assert here counts 1 in this file and the previous task's counts 1 in `CLAUDE.md`** — the same pattern in two files, because the two copies carry the sentence independently and a fix to one has never implied a fix to the other.

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
grep -cF -- "Neither is excused the records every cycle owes" plugins/dev-workflow/commands/workflow-init.md
```

Before this task: `0`. After: `1`. Verified against a simulated tree carrying Plan A's and Plan B's edits.

- [ ] **Amend the WIP commit.**

```bash
git add plugins/dev-workflow/commands/workflow-init.md
git commit --amend -m "WIP: review-loop economics"
```

---

## Task 17: Mark the superseded single-plan artifact

**File:** `docs/superpowers/plans/2026-08-29-review-loop-economics.md`

**Site** — pasted `grep -n`:

```
docs/superpowers/plans/2026-08-29-review-loop-economics.md:1:# Review-loop economics (pass floor + severity semantics) — Implementation Plan
```

> A 34 KB implementation plan for this same change is still in `docs/superpowers/plans/`, describing a topology, a task numbering and a commit protocol that all contradict the three plans that replaced it. **An executor finding it would follow it.**
> 
> **Marked, not deleted.** The field record cites its curve — 31 Blocker/Major at pass 1 — and it is the clearest specimen this cycle produced of a plan describing itself into failure. Deleting evidence to tidy a directory is how a record stops being able to explain a decision.

- [ ] **Replace.** OLD:

```
# Review-loop economics (pass floor + severity semantics) — Implementation Plan
```

NEW:

```
# Review-loop economics (pass floor + severity semantics) — Implementation Plan

> **SUPERSEDED, and kept as evidence rather than as instruction.** This single-plan version opened
> **31 Blocker/Major at Gate-A pass 1** and was replaced by three plans:
> `2026-08-29-review-loop-economics-plan-a-rules.md`,
> `2026-08-30-review-loop-economics-plan-b-records.md` and
> `2026-08-30-review-loop-economics-plan-c-rollout.md`.
> **Do not execute anything below.** Its topology, its task numbering and its commit protocol all
> disagree with the plans that replaced it. It is retained because the field record cites its
> curve, and because the three findings that killed it are the clearest specimen this cycle
> produced of a plan describing itself into failure.
```

- [ ] **Assert the new text is present.**

```bash
grep -cF -- "SUPERSEDED, and kept as evidence rather than as instruction" docs/superpowers/plans/2026-08-29-review-loop-economics.md
```

Before this task: `0`. After: `1`. Verified against a simulated tree carrying Plan A's and Plan B's edits.

- [ ] **Amend the WIP commit.**

```bash
git add docs/superpowers/plans/2026-08-29-review-loop-economics.md
git commit --amend -m "WIP: review-loop economics"
```

---

## Task 18: Record the cycle base

**Plan A prints its base SHA and does not persist it**, and Plan A is closed and byte-frozen, so
Plan C establishes it.

- [ ] **Record it, and assert the one thing that is not circular**

```bash
git rev-parse --verify HEAD^2 >/dev/null 2>&1 && { echo "WIP IS A MERGE — stop"; exit 1; }
git log -1 --pretty=%s | grep -q '^WIP: review-loop economics' || { echo "TIP IS NOT THE WIP"; exit 1; }
git log -1 --pretty=%s HEAD^ | grep -qi -- '-\?wip' && { echo "PARENT IS ALSO A WIP — stacked, collapse first"; exit 1; }
git rev-parse HEAD^ > .context/plan-a-base-sha
cat .context/plan-a-base-sha
```

> Revision 2 defined the base as `HEAD^` and then proved one commit sat above it — true by
> construction, a check that could not fail. Revision 3 deleted the proof **and the need with it**.
> The need is real: a **stacked** WIP would silently exclude the earlier snapshot from the review.
> **What is checkable without circularity is whether the parent is itself a WIP commit** — that
> asks something about a different commit, which is why it can fail.

`.context/` is gitignored, so this never enters the reviewed diff.

---

## Task 19: The evidence pack

Spec §8 names seven obligations. **All seven are here** — they are what the author owes, not
checks the plan invented about itself. The mode is read from the story header at execution time.

- [ ] **1 — Battery.** The full `AGENTS.md` § Commands chain, green, **including
  `sh scripts/check-version-bump.sh "$(cat .context/plan-a-base-sha)"`** — the checker takes a base
  ref argument and **exits 2 with no argument**, so the bare invocation is not a run. Plans A and B
  deferred this step for a stated reason; it runs now because Task 11 landed the bump and the WIP
  exists.

- [ ] **2 — A check that fails without the change**, read against **both** revisions:

```bash
base=$(cat .context/plan-a-base-sha)
git show "$base":CLAUDE.md | grep -cF 'Blocker/Major-free pass 1 carrying a Minor'
grep -cF 'a Blocker/Major-free pass below the floor' CLAUDE.md
```

**Grep the discriminating text, not the common tail.** Pre-change says **pass 1** keeps looping —
wrong at floor 1, where pass 1 *is* the floor; post-change says **below the floor**. Record which
revision gave which answer.

- [ ] **3 — A named verification of the risk path.** **Runs after Task 21 Step 2 drafts the
  provenance lines and before Step 3 closes** — it verifies those lines, so it cannot precede them.
  Recompute each line's floor from the `Story:` header of the artifact that cycle reviewed. **The
  observation that would exist if the claim were false is a line whose floor the cited profiles do
  not license.**

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

- [ ] **5 — A parse check over both pinned grammars**, with the features **assigned per grammar**
  rather than to both. **Provenance:** a quoted path; each `unusable(<CAUSE>)` value; a
  cited-story-with-no-profile entry; `none` for no story cited. **Curve:** a gapped `<SPEC>` such
  as `1,2,4`; a split-model pass; a `?` count; a skipped cycle's skip record. **Each grammar gets
  at least one instance that must be rejected** — for the curve, `<COUNTS>` shorter than `<SPEC>`
  enumerates; for provenance, a repeated `<PATH>`. Record which feature each exercises.

- [ ] **6 — Parity across every changed rule**, in both copies. **One difference is expected and
  is the only one**: the successor-story pointer, which `CLAUDE.md` carries and the template must
  not.

- [ ] **7 — A fresh twelve-item `docs/prompt-standards.md` pass** over each changed prompt
  artifact invariant 11 names — the **resulting scaffolded template**, **`workflow-init.md`**, and
  **`process-pr-review.md`**. One status row per item per artifact. **Item 1 for the scaffolded
  template is `N/A`**; Task 10 ships the note saying why.

---

## Task 20: The Gate-B cycle

- [ ] **Before the first call: prove the working tree holds only this change**

```bash
git status --porcelain          # must be empty
base=$(cat .context/plan-a-base-sha)
git diff --name-only "$base"..HEAD    # read it: every path must belong to Plans A, B or C
```

Explicit `git add` paths keep *new* strays out; they say nothing about content **already staged or
already inside the WIP** from an earlier step. This reads what the reviewer will actually see.

- [ ] **Run the loop.** `mcp__codex__review` against the WIP commit, **`baseSha` = the recorded
  base**. **Floor 3** — the old rules govern this cycle.

**Every call carries:** the old-rules sentence from Global Constraints; **the union of the
`Story:` headers of Plans A, B and C**; and the current evidence entry quoted verbatim.

**Findings go to `gate-b-<spec|quality>-rle-pass-<p>.md`.** Not the bare names: **this workspace
already contains 61 files in the bare `gate-b-*-pass-*` family from earlier cycles**, and the
delete-before-call step would destroy them — which is precisely the incident the slot rule exists
to prevent, committed by the plan that ships the rule. Not a nonce either: this cycle is pre-rule
and cannot mint one. **§8 names exactly this case** — *"its slot discriminator is short and
deterministic, so it is not a nonce"* — and `rle` is that discriminator.

**Delete both branch targets before a full call. For a single-branch resume, delete only the
failed branch**, and **capture the reviewed commit the surviving branch ran against** before
resuming — the two branches form one logical pass only if both reviewed the same commit, and the
surviving branch's value is unrecoverable once the resume overwrites its result.

- [ ] **After every accepted fix:** stage the exact paths the fix touched — **never `-u`** — amend
  with `-m "WIP: review-loop economics"`, **revalidate the evidence entry**, then re-review that
  new commit against the same base.

- [ ] **Before accepting a pass as final:** assert `HEAD` is the commit that pass reviewed. A pass
  is clean about a commit, not about a branch, and an amend between the pass and the close would
  leave the clean pass describing something else.

---

## Task 21: Close the cycle

- [ ] **Step 1: Revalidate the evidence** against the content the close will carry.

- [ ] **Step 2: Assemble the closing body**

```bash
body=$(mktemp) || exit 1
```

*(Revision 3 stripped the block that assigned `body` and left Step 3 expanding it — the strip
removed an **action**, not theater. The lesson is the one this pass was asked to check for:
deleting a check deletes whatever else was in the block.)*

It carries the evidence entry, and **one provenance line and one curve per cycle — five of each**:
one Gate-A spec cycle, three Gate-A plan cycles, one Gate-B cycle.

**One is native and four are reconstructed, and each record says which in its own text** — a
trailing ` — reconstructed from validated pass files (pre-rule cycle): <files>` on the four, and
nothing on the native one. **The marker travels with the record**, because the squash carry copies
records individually and a marker held in surrounding prose would not survive.

**Validate the assembled body before amending** — this is an obligation, not a check the plan
invented: **exactly five provenance lines and five curves**; each parses against its pinned
grammar; each curve's `<COUNTS>` has exactly as many entries as its `<SPEC>` enumerates; every
cycle field agrees between a cycle's line and its curve; four carry the reconstruction marker and
one does not; and no `<`-placeholder survives.

> **Why reconstruction does not contradict §8.** §8 says *"No reconstruction is needed and none is
> claimed"* and gives its grounds in the same breath — *"the Gate-A spec cycle has not closed …
> and the Gate-A plan cycle has not started"*. **That premise failed**: the spec cycle closed at
> pass 34 before the forms existed, and the one plan cycle became three. §8's sentence was a true
> prediction about a topology that changed. What it protects — that no record silently claims to be
> contemporaneous — is preserved by the marker, which is the stronger reading. **§8's "three
> closing bodies" is stale for the same reason**, exactly as the story criterion's "a run of all
> three holds three" is: the rule is one record per cycle, and five cycles ran.

**Every cycle here is pre-rule**, so each carries `cycle none (pre-rule)`. **The branch
demonstrates every field of both forms except two** — the cycle identifier and the knob clause's
non-absent form — **recorded as undemonstrable here with their reasons**, not as gaps and not as
satisfied. **Any cycle that both starts under these rules and closes discharges the nonce
demonstration.**

- [ ] **Step 3: Close, and fail loudly if it does not**

```bash
if git commit --amend -F "$body"; then
  git log -1 --pretty=%s | grep -q '^WIP:' && { echo "STILL WIP — not closed"; exit 1; }
  echo "CLOSED: $(git log -1 --pretty=%s)"; rm -f "$body"
else
  echo "AMEND FAILED — body preserved at $body"; exit 1
fi
```

The body is deleted **only after a successful amend**.

---

## Self-Review

**Spec coverage.** §7 rollout — Tasks 1-17. §8 evidence — Task 19, all seven obligations. The
cycle and the close — Tasks 18, 20, 21.

**What was stripped, and what came back.** Revision 3 removed six checks that could not fail. Two
of those removals took something real with them, and pass 3 found both: the base check had a
circular *proof* but a genuine *need* (a stacked WIP), now met by asking about a different commit;
and the closing-body block held `body=$(mktemp)` as well as its validation. **Deleting a check
deletes whatever else was in the block** — recorded, because it is the cost of the cure.

**Inherited obligations.** M8 and M10 at Task 20; M9 at Task 19 item 4; MINOR 12 and B6 at Task 21.

**Known limit.** Gate A reviews this plan, not the edits. What the edits do is Gate B's — here,
Task 20, reading the real combined diff of all three plans.
