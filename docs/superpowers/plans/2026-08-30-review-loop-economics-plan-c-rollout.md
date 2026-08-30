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
`✓ Codex Gate B satisfied (N/N cycle, N on current fingerprint)` — N being the hook's threshold, not the derived floor — the real commit replaces
```

- [ ] **Assert the new text is present.**

```bash
grep -cF -- "N being the hook's threshold, not the derived floor" docs/getting-started.md
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
grep -cF -- ""version": "0.11.0"" plugins/dev-workflow/.claude-plugin/plugin.json
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

## Task 13: The evidence pack

**Read the validation mode from the story header now.** This task produces what that mode names
and nothing derived from a value written here.

- [ ] **Step 1: The battery, in full**

Every step, including the version-bump check — which **now runs and must pass**, because Task 11
has landed the bump and the WIP commit exists. Plans A and B deferred exactly this one step for
exactly that reason.

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
claude plugin validate . --strict && echo BATTERY-GREEN
```

`check-version-bump.sh` compares **commits**, so it is meaningless before the WIP exists and
meaningful now. Confirm `main` is current before trusting it.

- [ ] **Step 2: The differential check — both revisions read**

One question about behaviour at a derived floor of 1, answered against **both** revisions. A
check that consults only the post-change text cannot fail, which is what makes this differential
rather than decorative.

> *At a derived floor of 1, does a Blocker/Major-free pass 1 carrying a Minor close, or keep
> looping?*

```bash
base=$(cat .context/plan-a-base-sha)
git show "$base":CLAUDE.md | grep -n 'carrying a Minor keeps'
grep -n 'carrying a Minor keeps' CLAUDE.md
```

- **Pre-change** says a **pass 1** carrying a Minor keeps looping — **wrong at floor 1**, where
  pass 1 *is* the floor.
- **Post-change** says a pass **below the floor** keeps looping — correct.

**Record which revision produced which answer.** The observation that would exist if the claim
were false is a pre-change revision that already answers correctly; it does not.

- [ ] **Step 3: The named risk-path verification**

Recompute the floor this cycle owes from the cited story's profile header, and confirm each pass
report states it together with the axes read and the story they were read from. **The observation
that would exist if the claim were false is a pass report whose floor the cited profile does not
license.**

- [ ] **Step 4: The knob verification — bytes, not just existence**

*(Inherited obligation, pass-1 M9.)* Recorded **before** the cycle's first Gate-B call and
compared after:

```bash
# before
if [ -e .context/codex-gate.floor ]; then
  printf 'KNOB present, %s bytes, sha %s\n' \
    "$(wc -c < .context/codex-gate.floor | tr -d ' ')" \
    "$(shasum -a 256 .context/codex-gate.floor | cut -d' ' -f1)"
else
  echo "KNOB absent — record this, and expect it absent after"
fi
```

Re-run after the final pass and compare. **Existence alone is not the check**: a knob whose
contents changed while its path survived would pass an existence test. **If no knob exists,
record not-applicable with that reason and do not create one** — a fixture supplying its own
input proves nothing.

---

## Task 14: The Gate-B cycle

- [ ] **Step 1: Confirm the cycle is intact**

```bash
base=$(cat .context/plan-a-base-sha)
n=$(git rev-list --count "$base"..HEAD)
[ "$n" = 1 ] || { echo "STACKED: $n commits above base"; exit 1; }
git log -1 --pretty=%s | grep -q '^WIP: review-loop economics' || { echo "TIP IS NOT THE WIP"; exit 1; }
git status --porcelain
echo "CYCLE OK — single WIP on $base"
```

- [ ] **Step 2: Run the loop**

`mcp__codex__review` against the WIP commit, **`baseSha` = the recorded base**, never `HEAD~1`.
Floor **3** — the old rules govern this cycle.

**Every call carries:** the old-rules sentence from Global Constraints; **the union of the
`Story:` headers of Plans A, B and C**, which is the governing cited set for a Gate-B cycle; and
the current evidence entry quoted verbatim.

Findings to `.context/codex-reviews/gate-b-<spec|quality>-<nonce>-pass-<p>.md`. **Delete both
branch targets and confirm them gone before a full call.**

> **Recovery is one attempt per pass, and deleting is not symmetric.** *(Inherited obligation,
> pass-1 M8.)* For a **full re-run**, delete both branch files. For a **single-branch resume**,
> delete **only the failed branch** — deleting both and recreating one makes the both-files check
> fail by construction, spending the attempt on a path that cannot succeed. A resume passes the
> `sessionId` back **and** its `reviewType` alongside, since the tool defaults to `full` and a
> resume omitting it can run the other reviewer and write the wrong slot.

- [ ] **Step 3: After every accepted fix**

```bash
git add <the exact paths the fix touched>   # never -u
git status --porcelain
git commit --amend -m "WIP: review-loop economics"
```

**then revalidate the evidence entry, then re-review that new commit against the same base.**
*(Inherited obligation, pass-1 B6.)* A fix changes the diff, so a pass run before it does not
cover what is being committed — and evidence produced against the old diff no longer describes
the new one.

---

## Task 15: Close the cycle

- [ ] **Step 1: Revalidate the evidence one last time**

*(Inherited obligation, pass-1 B6, second half.)* Against the content the close will carry, not
against the content the last clean pass saw — if those differ, the pass did not cover the close.

- [ ] **Step 2: Build the closing body as a file, and check it**

*(Inherited obligation, pass-1 MINOR 12 — `mktemp`, not a fixed path, so a concurrent process
cannot overwrite the body between validation and use.)*

```bash
body=$(mktemp) || exit 1
cat > "$body" <<'MSG'
feat(gates): derive the pass floor from the story profile; decide severity by consequence
MSG
# then append, in the body: what the change does; the evidence entry naming the story path
# and each verification's observation; and for EACH of the five cycles its provenance line
# and its per-pass curve, in the forms Plan B pins.
grep -c '<' "$body"   # must be 0 — no angle-bracket placeholder may survive
cat "$body"
```

**Five cycles, so five provenance lines and five curves**: the Gate-A spec cycle, the three Gate-A
plan cycles, and this Gate-B cycle. All five carry `cycle none (pre-rule)` — every one of them
began before these rules ship, so none has a nonce, and minting one would be late-created
provenance.

**The branch therefore demonstrates every field of both pinned forms except two**: the cycle
identifier, and the knob clause's non-absent form. Both are recorded as **undemonstrable here with
their reasons** — not as gaps, and not as satisfied. **Any cycle that both starts under these
rules and closes discharges the nonce demonstration**; duplicate discharge is harmless and
explicitly allowed.

- [ ] **Step 3: Close**

```bash
git commit --amend -F "$body"
rm -f "$body"
git log -1 --pretty=%s   # must NOT start with WIP:
```

This is the first message without `WIP:`, and the hook reads it as the cycle closing.

---

## Self-Review

**Spec coverage.** §7 rollout — Tasks 1-12. §8 evidence — Task 13, with the mode read from the
story header at execution time. The combined Gate-B cycle and the close — Tasks 14 and 15. §2,
§2.1, §2.2, §2.4, §3 and §10 were Plan A's; §2.3, §4, §5 and §6 were Plan B's; both closed clean.

**Placeholders.** None. The one templated artifact — the closing body — is built as a file and
asserted placeholder-free before it is used.

**Inherited obligations.** All five are discharged at a named step: M8 at Task 14 Step 2, M9 at
Task 13 Step 4, M10 at Task 14 Step 3, MINOR 12 at Task 15 Step 2, B6 at Task 14 Step 3 and Task
15 Step 1.

**Known limit, the same one both closed plans ended on.** Gate A reviews this plan, not the edits.
Each task's single check establishes that its edit landed at its site and nothing more. What the
edits do to the shipped files is Gate B's — and in this plan Gate B is not a later stage but Task
14, reading the real combined diff of all three plans.
