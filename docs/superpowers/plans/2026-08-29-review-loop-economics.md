# Review-loop economics (pass floor + severity semantics) — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development
> (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use
> checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make the mandatory pass floor a function of the story profile, and decide finding
severity by whether something in the system takes a different decision.

**Architecture:** Two mirrored prose edits — `CLAUDE.md` §5 and the inline template in
`/workflow-init` — plus the user-facing sentences they falsify, plus packaging. **No code. Nothing
under `plugins/dev-workflow/hooks/` is touched and no hook state file is written.**

**Tech Stack:** Markdown prompts; POSIX shell for every check; `git` for the evidence records.

**Spec:** `docs/superpowers/specs/2026-08-28-review-loop-economics-design.md` (revision 36, Gate A
closed clean at pass 34). **Read it alongside this plan.**

**Story:** `docs/superpowers/stories/2026-08-28-review-loop-economics-pass-floor-story.md` —
`risk high · security none · battery+check+verification`. **Read the profile from that header.**

**This is a rewrite.** The first version drew 20 Blocker/Major at Gate-A pass 1 from four habits:
typed anchors that did not exist, references to spec contents that no longer existed, checks that
could not fail, and — worst — ordinary commits inside a Gate-B cycle, in a plan whose subject is
§5. Every one is structurally prevented below: **anchors are pasted from `grep -n`, the passage
list lives here because the spec no longer holds it, every check's failing output is recorded, and
the whole prompt change is one Gate-B cycle with one `WIP:` snapshot.**

---

## Global Constraints

Verbatim from the spec. Every task's requirements implicitly include these.

- **Prompt-only.** No file under `plugins/dev-workflow/hooks/` changes; no hook state file is
  written, in particular not `.context/codex-gate.floor`.
- **The §5 heading must keep matching `^#{1,6}[[:space:]]+([0-9]+\.)?[[:space:]]*Cross-Model Review`.**
  `codex-gate.sh:94` greps `CLAUDE.md` for it to build the citation every reminder prints.
- **`plugins/dev-workflow/commands/workflow-init.md` must keep exactly one `^Target model:` line.**
  `scripts/check-invariants.sh` fails on any other count. Verified now: **1**.
- **Every rule lands in BOTH copies**, except where a difference is deliberate and stated.
- **§5's other closure rules are never restated, only referred to.** Three spec revisions were
  spent on this: each summary of the triviality skip dropped a different condition.

### The commit protocol — read this before Task 1

**Tasks 1–5, 8 and 9 are ONE Gate-B cycle, not seven.** They edit the same two prompt files plus
packaging, and §5 gates the *cycle*, not each edit. So:

1. **Task 1 opens the cycle** with a commit whose message begins `WIP:`. Every later task in the
   cycle **amends that commit**, keeping the `WIP:` prefix and carrying the body forward.
2. **`mcp__codex__review` runs against that WIP commit**, `baseSha` = its parent.
3. **Re-review after every fix.** A fix changes the diff and invalidates the prior pass.
4. **The cycle closes with `git commit --amend -m "<real message>"`** — the first message without
   `WIP:` — carrying the evidence entry, the provenance line and the curve.

**An ordinary `git commit` inside the cycle reads to the hook as the cycle closing and resets the
counters.** The first version of this plan instructed exactly that, seven times.

**Task 7 is outside the cycle** and commits normally: every path it stages is `docs/**.md` or
`README.md`, so §5's prose exemption applies and Gate B is N/A — **but only if nothing else is
staged**, since a mixed commit forfeits it. **Task 0 is also outside** and is likewise N/A
(`docs/superpowers/**.md` only).

---

## File Structure

| File | Responsibility | Gate B |
|---|---|---|
| `CLAUDE.md` §5 | the live rules | full (in the cycle) |
| `plugins/dev-workflow/commands/workflow-init.md` §5 | the scaffolded mirror | full (in the cycle) |
| same file, outside the fence | the item-1 n/a note | full (in the cycle) |
| `plugins/dev-workflow/.claude-plugin/plugin.json`, `CHANGELOG.md` | packaging | full (in the cycle) |
| `README.md`, `docs/getting-started.md`, `docs/coding-workflow.md` | falsified sentences | **N/A**, committed alone |
| `docs/superpowers/specs/…-conditions.md` | old-conditions dispositions | **N/A** |

---

## Task 0: The conditions artifact

**Not a gate that needs its own output to start.** This artifact is written as part of this plan
revision and is **reviewed by the plan's own Gate-A passes alongside the plan**; its acceptance is
that cycle's clean pass. Nothing waits on a separate approval.

**Files:** Create `docs/superpowers/specs/2026-08-28-review-loop-economics-conditions.md`

### The nineteen passages — provenance stated

The spec no longer carries this list: revision 15 slimmed it out and put it here. It was recovered
mechanically, not from memory:

```bash
git show 46072fe:docs/superpowers/specs/2026-08-28-review-loop-economics-design.md \
  | grep -E '^\| [0-9]+ \| '
```

That revision claimed "Eighteen" and its table holds 18 rows — **claim and content agree**, so the
recovery is sound. **Reconciled against revision 36, it is nineteen**: revision 36's §2.2 requires
the pass report to state the derived floor, the axes read and their source stories, which rewrites
the `From pass 4 onward every pass report carries three lines` paragraph — present once in each
copy, and absent from the recovered list because it went to the successor story during the split
and came back when §2.2 was added.

| # | Passage (quoted by its bold lead-in) |
|---|---|
| 1 | `**Both gates are a LOOP with a HARD FLOOR` |
| 2 | the early-exit sentence — `below 3 is a pass with **zero** findings` |
| 3 | the incomplete-pass rule — `don't count it toward the 3-pass floor` |
| 4 | `Lenses are **different questions, not more passes.**` |
| 5 | `**The Gate-B triviality skip needs two independent conditions**` |
| 6 | `**A cycle citing several stories**` |
| 7 | `- **Gate A — Spec, then plan (TWO runs, each its own 3-pass loop).**` |
| 8 | `- **Gate B — Code.**` |
| 9 | `- **Severity:** Blocker (wrong/unsafe/breaks invariant)` |
| 10 | `**Changing a profile:**` |
| 11 | the findings-slot naming paragraph (`<slot>` is `gate-a-spec-pass-<p>`, …) |
| 12 | `**Before each call, delete every target file and confirm it is gone.**` |
| 13 | `**Recognizing "clearly stuck"` |
| 14 | `**Recording a human exception.**` |
| 15 | `**The evidence entry lives in the commit body**` |
| 16 | `**Optional companions, from field practice.**` |
| 17 | `**On squash-merge, copy every evidence entry` |
| 18 | the `baseSha` / WIP / closing-amend block |
| 19 | `**From pass 4 onward every pass report carries three lines.**` |

- [ ] **Step 1: Confirm all nineteen exist exactly once in both copies**

```bash
while IFS= read -r p; do
  a=$(grep -cF "$p" CLAUDE.md)
  b=$(grep -cF "$p" plugins/dev-workflow/commands/workflow-init.md)
  [ "$a" = 1 ] && [ "$b" = 1 ] || printf 'MISMATCH %s/%s: %s\n' "$a" "$b" "$p"
done <<'PATS'
**Both gates are a LOOP with a HARD FLOOR
below 3 is a pass with
don't count it toward the 3-pass floor
Lenses are **different questions, not more passes.**
The Gate-B triviality skip needs two independent conditions
A cycle citing several stories
Gate A — Spec, then plan (TWO runs, each its own 3-pass loop)
Gate B — Code.
**Severity:** Blocker (wrong/unsafe/breaks invariant)
Changing a profile:
gate-a-spec-pass-<p>
Before each call, delete every target file and confirm it is gone.
Recognizing "clearly stuck"
Recording a human exception.
The evidence entry lives in the commit body
Optional companions, from field practice.
On squash-merge, copy every evidence entry
**`baseSha`:** against main = merge-base with main
From pass 4 onward every pass report carries three lines
PATS
```

Expected: **no output.** Any MISMATCH means the list is stale and that is a finding, not something
to route around.

- [ ] **Step 2: Regenerate the floor-site inventory**

```bash
grep -nE "min 3 passes|below 3|3-pass|where the 3 come from|if pass 3 still" \
  CLAUDE.md plugins/dev-workflow/commands/workflow-init.md | wc -l
```

**Demonstrated now: 14** — seven per copy. That is the inventory, and it already includes the
digit-free `pass 1` site because the pattern `if pass 3 still` and the `carrying a Minor` sentence
both fall inside it. Confirm the digit-free one separately:

```bash
grep -n 'carrying a Minor keeps' CLAUDE.md plugins/dev-workflow/commands/workflow-init.md
```

**Demonstrated now:** `CLAUDE.md:126` and `workflow-init.md:322`.

- [ ] **Step 3: Write one dispositioned entry per passage**

Columns: *passage*, *what its existing prose requires* (one requirement per line, read from the
file, not recalled), *disposition* — **kept** / **moved** (say where) / **deliberately dropped**
(say why). A requirement neither kept nor explicitly dropped is a dropped condition and fails this
task.

- [ ] **Step 4: Verify entry count against the list**

```bash
grep -c '^| [0-9]* |' docs/superpowers/specs/2026-08-28-review-loop-economics-conditions.md
```

Expected: **19**.

- [ ] **Step 5: Commit — ordinary commit, Gate B N/A**

```bash
git add docs/superpowers/specs/2026-08-28-review-loop-economics-conditions.md
git diff --cached --name-only   # confirm ONLY this path
git commit -m "docs(spec): old-conditions dispositions for the review-loop economics change"
```

---

## Task 1: Open the Gate-B cycle, and derive the floor

**Files:** `CLAUDE.md:72`, `plugins/dev-workflow/commands/workflow-init.md:272`

**Interfaces:**
- Produces: `max(risk, security)` inside the floor paragraph, which Task 2's sites refer back to.

- [ ] **Step 1: Run the check and see it fail**

```bash
for f in CLAUDE.md plugins/dev-workflow/commands/workflow-init.md; do
  printf '%s: ' "$f"
  sed -n '/Both gates are a LOOP with a HARD FLOOR/,/^$/p' "$f" | grep -c 'max(risk, security)'
done
```

**Demonstrated failing output, 2026-08-29:**
```
CLAUDE.md: 0
plugins/dev-workflow/commands/workflow-init.md: 0
```

**The `sed` scoping is load-bearing.** An unscoped `grep -c 'max(risk, security)'` returns **1**
for both files today, because the Profiles section already contains the phrase — the check would
pass before the edit and prove nothing. That was a real finding against the first version of this
plan.

- [ ] **Step 2: Replace the floor clause in both copies**

Anchor, pasted from `grep -n` (identical in both files):
```
72:**Both gates are a LOOP with a HARD FLOOR: min 3 passes per run (Blocker/Major
272:**Both gates are a LOOP with a HARD FLOOR: min 3 passes per run (Blocker/Major
```

Replace `min 3 passes per run` with the derived floor, **keeping every other requirement in that
paragraph verbatim**:

```markdown
**Both gates are a LOOP with a HARD FLOOR: a minimum number of passes per run (Blocker/Major
only), derived from the story profile — `max(risk, security) == 0` gives **1**; every resolvable
profile above that, and an artifact citing no story, gives **3**. A cited story whose profile is
present but unresolvable **stops and surfaces** under the existing rule rather than falling
through to 3. A cycle citing several stories reaches 1 **only if the cited set is non-empty and
every member is profiled, resolvable and at level 0**; any other set gives 3. **One derived value
governs all three cycles** — the Gate-A spec cycle, the Gate-A plan cycle and the Gate-B cycle —
because they derive from the same cited-story set, not because they are one cycle.
```

- [ ] **Step 3: Add the pass-report and residual rules to both copies**

Closing the coverage gap the first version left. Append to the same paragraph:

```markdown
**Every pass report states the derived floor, the risk and security values read, and the cited
stories they were read from** — the number alone leaves a reader unable to check the derivation
while passes are still being spent. **The derived floor is the count a cycle owes; the hook's
ratio is a reminder threshold and controls nothing**, so where the cycle's own closure rules are
satisfied a below-threshold reminder is noted in the pass report and disregarded. This replaces
the pass-count number and nothing else; every other rule here about how a cycle closes stands as
written. **The floor is produced by the agent and nothing checks it** — not against the cited
profiles, not anywhere — so a stated floor the cited set does not license, an omitted higher-risk
story, a minted level-0 profile or an incomplete cited set are all routes to fewer passes, and
naming them is a disclosure rather than a guard. **The workspace knob is never written, never
removed and never read for this derivation**; it remains the hook's reminder threshold.
```

- [ ] **Step 4: Re-run the check**

Expected: `1` and `1`.

- [ ] **Step 5: Verify the paragraph's tail survived**

```bash
for f in CLAUDE.md plugins/dev-workflow/commands/workflow-init.md; do
  printf '%s: ' "$f"
  tr '\n' ' ' < "$f" | tr -s ' ' | grep -c "don't manufacture findings to pad"
done
```

Expected: `1` and `1`. **Demonstrated present now**, so this check catches a replacement that
swallowed its neighbours.

- [ ] **Step 6: OPEN THE CYCLE with a WIP commit**

```bash
git add CLAUDE.md plugins/dev-workflow/commands/workflow-init.md
git commit -m "WIP: review-loop economics — floor, severity, records"
```

**This message must begin `WIP:`.** Every later task in this cycle amends it. Do not run an
ordinary commit again until Task 9's close.

---

## Task 2: The fourteen floor-wording sites

**Interfaces:** consumes Task 1's predicate; produces nothing.

- [ ] **Step 1: Run the check and see it fail**

```bash
grep -cE "min 3 passes|below 3|3-pass|where the 3 come from|if pass 3 still" \
  CLAUDE.md plugins/dev-workflow/commands/workflow-init.md
```

**Demonstrated output, 2026-08-29:** `CLAUDE.md:7` and `workflow-init.md:7`. After this task both
must be **0**.

- [ ] **Step 2: Apply seven replacements per copy**

Anchors pasted from `grep -n`; **CLAUDE.md line : template line**.

| Anchor (verbatim, as the file holds it) | Lines | Replacement |
|---|---|---|
| `final pass must be clean — if pass 3 still finds Blocker/Major, keep going until` | 77 : 277 | `…— if the pass at the floor still finds Blocker/Major, keep going until` |
| `below 3 is a pass with **zero** findings; don't manufacture findings to pad. Codex is` | 79 : 279 | `below the floor is a pass with **zero** findings; …` |
| `the only exception, exactly as above; a Blocker/Major-free pass 1 carrying a Minor keeps` | 126 : 322 | `…; a Blocker/Major-free pass **below the floor** carrying a Minor keeps` |
| `act on the partial list, don't count it toward the 3-pass floor, and don't read "no` | 236 : 421 | `…don't count it toward the floor, and don't read "no` |
| `- **Gate A — Spec, then plan (TWO runs, each its own 3-pass loop).** Run on the` | 300 : 485 | `- **Gate A — Spec, then plan (TWO runs, each its own loop at the derived floor).** Run on the` |
| `  invalidates the prior pass, which is where the 3 come from.` | 335 : 519 | `  invalidates the prior pass, which is where the floor's lower bound comes from.` |
| `Lenses are **different questions, not more passes.** The 3-pass floor, the Blocker/Major` | 403 : 582 | `Lenses are **different questions, not more passes.** The floor, the Blocker/Major` |

**The `pass 1` sentence continues onto the next line** — `looping.` sits at 127/323. Match the
fragment above, not a reconstructed whole sentence. That mismatch broke the first version.

- [ ] **Step 3: Re-run the check**

Expected: `0` and `0`.

- [ ] **Step 4: Confirm the historical citation was NOT touched**

```bash
grep -c "PR #23's Gate-B pass 3 returned all four findings" \
  CLAUDE.md plugins/dev-workflow/commands/workflow-init.md
```

Expected `1` and `1`. **Demonstrated present now.** It cites an actual pass, not a rule, and must
keep saying 3 — changing it would falsify a record.

- [ ] **Step 5: Amend the WIP commit**

```bash
git add CLAUDE.md plugins/dev-workflow/commands/workflow-init.md
git commit --amend --no-edit
```

The message keeps its `WIP:` prefix. **No ordinary commit.**

---

## Task 3: Severity semantics

**Files:** `CLAUDE.md:495`, `plugins/dev-workflow/commands/workflow-init.md:674`

- [ ] **Step 1: Run the check and see it fail**

```bash
for f in CLAUDE.md plugins/dev-workflow/commands/workflow-init.md; do
  printf '%s: ' "$f"; tr '\n' ' ' < "$f" | tr -s ' ' | grep -c 'consumes this text'
done
```

**Demonstrated failing output, 2026-08-29:** `0` and `0`.

- [ ] **Step 2: Extend the Severity entry in both copies**

Anchor, pasted from `grep -nF`:
```
CLAUDE.md:495:- **Severity:** Blocker (wrong/unsafe/breaks invariant) · Major (design flaw →
plugins/dev-workflow/commands/workflow-init.md:674:- **Severity:** Blocker (wrong/unsafe/breaks invariant) · Major (design flaw →
```

Keep the four definitions verbatim; append the classifier from spec §3 — the reachability test
with both halves required, the reviewing-pass exclusion, the human-reader exclusion, the
illustrative reader list, the ceiling-not-floor rule, the symmetric instrument carve-out, the
qualified rationale case, the kinship sentence, and coverage-first.

- [ ] **Step 3: Re-run the check**

Expected: `1` and `1`.

- [ ] **Step 4: Verify the four definitions survived**

```bash
grep -cF '**Severity:** Blocker (wrong/unsafe/breaks invariant)' \
  CLAUDE.md plugins/dev-workflow/commands/workflow-init.md
```

Expected `1` and `1`.

- [ ] **Step 5: Amend the WIP commit**

```bash
git add CLAUDE.md plugins/dev-workflow/commands/workflow-init.md
git commit --amend --no-edit
```

---

## Task 4: The two pinned records and the cycle nonce

- [ ] **Step 1: Run the check and see it fail**

```bash
grep -c 'cycle none (pre-rule)' CLAUDE.md plugins/dev-workflow/commands/workflow-init.md
```

**Demonstrated failing output, 2026-08-29:** `0` and `0`.

- [ ] **Step 2: Copy both grammars from the spec**

**From spec §2.3 (provenance) and §4 (curve) only** — §5 of the spec is the nonce prose and holds
no grammar. Copy the fenced blocks **verbatim**; retyping is how a production drifts.

- [ ] **Step 3: Add the surrounding rules**

Every cycle records a provenance line. The curve records Findings, Blockers and Majors per valid
pass with the pass numbers covered; an unrecoverable count is `?`, excluded **per series** and not
per pass; a skipped cycle records a skip line in place of a curve.

**The nonce**, with the generation policy the spec delegates here: 8–16 chars of `[a-z0-9]` from a
source of randomness, never derived from a name, timestamp or commit. **On failure — randomness
unavailable, an invalid value, or a collision with an open cycle — retry at most three times, then
stop and surface. No deterministic fallback.** It appears in the provenance line, the curve, the
cycle's findings slots and its advisory working record. A cycle that cannot recover exactly one
candidate starts fresh.

- [ ] **Step 4: Widen the findings-slot grammar in both copies**

Anchor: the paragraph containing `gate-a-spec-pass-<p>`. The three names gain an optional per-cycle
infix, **required whenever more than one cycle could write that slot**, with a target owned by
another cycle **refused rather than overwritten**.

- [ ] **Step 5: Re-run the check, then parse the grammars**

```bash
grep -c 'cycle none (pre-rule)' CLAUDE.md plugins/dev-workflow/commands/workflow-init.md
```

Expected `1` and `1`.

Then **construct** instances and parse them against the productions **as they now read in the
shipped copies** — the spec carries no worked examples to reuse. Cover: a quoted path; each
`unusable(<CAUSE>)` value; a gapped `<SPEC>` like `1,2,4`; a split-model pass; a skipped cycle; a
`?` count; and one instance that must be **rejected** (`<COUNTS>` shorter than `<SPEC>`). Record
which feature each exercised. **A grammar nothing ever parsed is a format claim, not a format.**

- [ ] **Step 6: Amend the WIP commit**

```bash
git add CLAUDE.md plugins/dev-workflow/commands/workflow-init.md
git commit --amend --no-edit
```

---

## Task 5: The squash carry

**Files:** `CLAUDE.md:519`, `plugins/dev-workflow/commands/workflow-init.md:698`

- [ ] **Step 1: Run the check and see it fail**

```bash
for f in CLAUDE.md plugins/dev-workflow/commands/workflow-init.md; do
  printf '%s: ' "$f"; tr '\n' ' ' < "$f" | tr -s ' ' | grep -c 'the per-pass curves'
done
```

**Demonstrated failing output, 2026-08-29:** `0` and `0`.

- [ ] **Step 2: Extend the list — do not rewrite the sentence**

Anchor, pasted from `grep -nF` (the whole rule is one long line):
```
CLAUDE.md:519:  **On squash-merge, copy every evidence entry and every human-exception record in the squash range into the squash body — …**
plugins/dev-workflow/commands/workflow-init.md:698:  (identical)
```

Add **the provenance line, the per-pass curves, and a skipped cycle's skip record**. The successor
story adds the decline record to this same passage later; a rewrite there would drop what this
adds, which is why this is an extension.

- [ ] **Step 3: Re-run the check, and confirm the original two survived**

```bash
for f in CLAUDE.md plugins/dev-workflow/commands/workflow-init.md; do
  printf '%s: ' "$f"
  tr '\n' ' ' < "$f" | tr -s ' ' | grep -c 'every evidence entry and every human-exception record'
done
```

Expected `1` and `1` for both checks.

- [ ] **Step 4: Amend the WIP commit**

```bash
git add CLAUDE.md plugins/dev-workflow/commands/workflow-init.md
git commit --amend --no-edit
```

---

## Task 6: The item-1 note

**Runs before Task 7's conformance pass**, because that pass certifies this file and must see its
final state. The first version had them the other way round.

**Files:** `plugins/dev-workflow/commands/workflow-init.md`, **outside** the fenced block.

- [ ] **Step 1: Record the count that must not change**

```bash
grep -c '^Target model:' plugins/dev-workflow/commands/workflow-init.md
```

**Demonstrated now: 1.** It must still be 1 afterwards — `scripts/check-invariants.sh` fails on
any other count, and adding a second declaration is exactly what a naive fix would do.

- [ ] **Step 2: Add the note immediately before the fence**

The fence opens at `192:````markdown`. Place the note **before** that line:

```markdown
> **Prompt-standards item 1 for the scaffolded `CLAUDE.md`: n/a, and why.** The file this template
> writes is model-agnostic by design — its executing model is whatever the reader of that project
> runs — so a `Target model:` line inside it would be false in every repo it lands in. Recorded as
> a reasoned n/a rather than skipped: the item is answered. This note sits **outside the fence** so
> it never scaffolds, and is deliberately **not** a `Target model:` line, which would make this
> file's declaration count 2 and fail `scripts/check-invariants.sh`.
```

- [ ] **Step 3: Verify the count and the placement**

```bash
grep -c '^Target model:' plugins/dev-workflow/commands/workflow-init.md
awk 'NR>=185 && NR<=200' plugins/dev-workflow/commands/workflow-init.md
sh scripts/check-invariants.sh && echo INVARIANTS-OK
```

Expected: `1`; the note visible **before** the ```` ````markdown ```` line; checker exits 0.

- [ ] **Step 4: Amend the WIP commit**

```bash
git add plugins/dev-workflow/commands/workflow-init.md
git commit --amend --no-edit
```

---

## Task 7: Parity and the twelve-item conformance pass

No new text. This is the verification story criterion 7 and invariant 11 require.

- [ ] **Step 1: Walk every changed rule across both copies**

For each rule Tasks 1–5 added, extract it from both files and diff. Record each difference as
**deliberate-and-stated** or **defect**. The copies already diverge on ~192 lines overall, so a
whole-section diff proves nothing — walk the named rules.

- [ ] **Step 2: Run the twelve items against each changed prompt artifact**

The resulting scaffolded template, and `plugins/dev-workflow/commands/workflow-init.md` as the
outer command prompt. **Item 7 is read against the whole resulting artifact**, not the diff.
**Root `CLAUDE.md` is outside invariant 11's list and is not part of this pass.**

- [ ] **Step 3: Record item 1's n/a for the scaffolded template**, with the reason from Task 6.

- [ ] **Step 4: Append the results to the conditions artifact and commit — Gate B N/A**

```bash
git add docs/superpowers/specs/2026-08-28-review-loop-economics-conditions.md
git diff --cached --name-only   # confirm ONLY this path
git commit -m "docs(spec): parity walk and twelve-item conformance results"
```

**This is an ordinary commit and it is correct here** — the staged path is `docs/superpowers/**.md`
and the WIP cycle's counters are unaffected by a commit that touches none of its files. Amend the
WIP commit again in Task 8 before reviewing.

---

## Task 8: The falsified user-facing sentences — committed alone

- [ ] **Step 1: Run the check and see it fail**

```bash
grep -cE "3-passes-per-gate|three passes minimum|same 3-pass loop|Gate-A floor wasn't met|three passes, final clean|3/3 cycle|floor is unchanged at every level|moves the 3-pass floor|Gate A's floor and" \
  README.md docs/getting-started.md docs/coding-workflow.md
```

**Demonstrated output, 2026-08-29:** `README.md:1`, `docs/coding-workflow.md:1`,
`docs/getting-started.md:7` — **nine hits, matching the nine sites below.** The first version's
grep found only five and its site list said nine.

- [ ] **Step 2: Correct each site**

Anchors pasted from `grep -nF`:

| Anchor | Correction |
|---|---|
| `README.md:130:` `\| `codex-gate.floor` \| a positive integer; moves the 3-passes-per-gate floor. \|` | `… moves the **hook's reminder threshold**. It does not change the floor §5 obliges, which is derived from the story profile.` |
| `getting-started.md:34:three passes minimum, final pass clean — the one early exit is a pass that comes` | `the floor its profile derives, final pass clean — the one early exit is a pass that comes` |
| `:40:task-by-task plan (each task starts with a failing test); the same 3-pass loop runs` | `…; the same loop runs at the derived floor` |
| `:44:progress claims backed by test runs. If the Gate-A floor wasn't met, the hook says` | `… If the hook's own threshold wasn't met, it says` |
| `:53:` `` `mcp__codex__review` the same way: three passes, final clean. Verification is by`` | `… the same way: the derived floor, final clean. Verification is by` |
| `:58:` `` `✓ Codex Gate B satisfied (3/3 cycle, 3 on current fingerprint)`, the real commit replaces`` | `` `✓ Codex Gate B satisfied (N/N cycle, N on current fingerprint)` — N being the derived floor — the real commit replaces `` |
| `:84:is still owed and Gate A's floor is unchanged at every level. The caution bias is` | `is still owed; Gate A's floor is derived from the profile like Gate B's, and what the axes never subtract is the baseline questions. The caution bias is` |
| `:86:positive integer) moves the 3-pass floor, and `touch .context/codex-gate.off`` | `positive integer) moves the hook's reminder threshold, and …` |
| `coding-workflow.md:79:gates for a risky or security-relevant change (they never subtract any: Gate A's floor and` | `gates for a risky or security-relevant change (they never subtract a baseline question; the floor itself is derived from the profile, and` |

- [ ] **Step 3: Re-run the check**

Expected: zero hits in all three files.

- [ ] **Step 4: Commit alone — Gate B N/A**

```bash
git add README.md docs/getting-started.md docs/coding-workflow.md
git diff --cached --name-only   # MUST list exactly these three
git commit -m "docs: correct every sentence the derived floor falsifies"
```

**Verify the staged set before committing.** That verification is what earns the exemption; a
mixed commit forfeits it.

---

## Task 9: Packaging, then close the cycle

- [ ] **Step 1: Bump the manifest**

`plugins/dev-workflow/.claude-plugin/plugin.json`: `0.10.0` → `0.11.0`. Minor — shipped rules
change, no documented interface breaks.

- [ ] **Step 2: Add the CHANGELOG entry**, newest first. **Nothing enforces this** — neither
  invariant 12 nor the checker mentions the changelog — so the story's criterion carries it.

- [ ] **Step 3: Amend the WIP commit, THEN run the version check**

```bash
git add plugins/dev-workflow/.claude-plugin/plugin.json plugins/dev-workflow/CHANGELOG.md
git commit --amend --no-edit
sh scripts/check-version-bump.sh main && echo BUMP-OK
```

**Order matters and this is why:** `check-version-bump.sh` compares *committed* state against the
merge-base and ignores the worktree and index. Run before the amend it reports clean — correctly
and uselessly, as `AGENTS.md` says in as many words. The first version of this plan ran it first
and called that a failing check.

- [ ] **Step 4: Run the full battery**

The whole `AGENTS.md` § Commands chain, exit 0, with assertion counts recorded.

- [ ] **Step 5: Gate B — the review loop**

Against the WIP commit, `baseSha` = its parent. Floor 3 (this story is risk `high`). Re-review
after every fix; the final pass must be clean. Findings to
`.context/codex-reviews/gate-b-<spec|quality>-rle-pass-<p>.md`, targets deleted and confirmed gone
before each call.

- [ ] **Step 6: Close the cycle**

```bash
git commit --amend -m "$(cat <<'MSG'
feat(gates): derive the pass floor from the profile; decide severity by consequence

<body: the evidence entry naming the story path and each verification's
observation; the provenance line; the per-pass curve for this Gate-B cycle>
MSG
)"
```

**This is the first message without `WIP:`**, and the hook reads it as the cycle closing.

---

## Task 10: The evidence pack

Mode `battery+check+verification`. Produced during Task 9's cycle and **revalidated before every
re-review and before the closing amend**, against the content the close will carry.

- [ ] **Step 1: The battery** — the § Commands chain, green, counts recorded.

- [ ] **Step 2: The differential named verification — both revisions read**

One question about behaviour at a derived floor of 1, answered against **both** revisions:

> *At floor 1, does a Blocker/Major-free pass 1 carrying a Minor close, or keep looping?*

- **Pre-change** (`git show <base>:CLAUDE.md`, line 126): says it **keeps looping** — wrong, since
  pass 1 is at the floor.
- **Post-change**: says a pass **below the floor** keeps looping — correct.

Ask the same of `below 3` versus `below the floor` at line 79. **Record which revision was read for
each answer.** A verification consulting only the post-change text cannot fail and would report
success because of how it was wired.

- [ ] **Step 3: The risk-path verification**

Recompute each provenance line's floor from the cited stories' profile headers. The observation
that would exist if the claim were false is **a provenance line whose number the profiles do not
license**. Also confirm **no floor file is present at close where none was at start** — which
detects a persisting write and **cannot** detect a transient one.

- [ ] **Step 4: The knob verification, conditionally**

If `.context/codex-gate.floor` exists before the cycle, it is byte-identical after. **If none
exists, record not-applicable with that reason.** Do not create one — a fixture supplying its own
input proves nothing.

- [ ] **Step 5: The three closing bodies**

Each cycle's closing commit carries a provenance line and a curve in the pinned forms. **All three
use `cycle none (pre-rule)`** — every cycle on this branch began before these rules ship, so none
has a nonce and minting one would be late-created provenance. The branch demonstrates **every field
of both forms except two**: the cycle identifier, and the knob clause's non-absent form. Both are
recorded as **undemonstrable-here with their reasons**, not as gaps and not as satisfied. The
implementation commit records that **any cycle that both starts under these rules and closes**
discharges the nonce demonstration; duplicate discharge is harmless.

---

## Self-Review

**Spec coverage.** §2 predicate → Task 1. §2.1 knob, precedence, residual → Task 1 Step 3. §2.2
pass report → Task 1 Step 3. §2.3 provenance → Task 4. §2.4 mid-cycle → Task 1. §3 severity →
Task 3. §4 curve → Task 4. §5 nonce incl. retry policy → Task 4 Step 3. §6 accounting → Task 0.
§7 rollout, falsified sentences, packaging → Tasks 6, 8, 9. §8 evidence → Task 10. §9 scope →
Global Constraints. §10 risks → shipped by Task 1 Step 3.

**Placeholders.** None. Every anchor is pasted `grep -n` output; every replacement is written out;
every check has its demonstrated output recorded.

**Type consistency.** `<CYCLE-FIELD>`, `<NONCE>`, `<STORY-SET>`, `<KNOB>`, `<COUNTS>`, `<SPEC>`,
`<MODELS>` are defined in the spec, which travels with this plan, and are used identically in
Tasks 4 and 10.

**Gate-B classification, per path.** Tasks 1–6 and 9 stage prompts or plugin files → **one full
Gate-B cycle**, opened at Task 1 and closed at Task 9. Tasks 0, 7 and 8 stage only `docs/**.md` or
`README.md` → **N/A**, committed alone. The first version claimed Tasks 0 and 6 fired full Gate B;
they do not.

**Known limit.** Task 2's replacement wordings are proposals, not transcriptions — the spec pins
the rules, not the sentences — and this plan's Gate A is what reviews them.
