# Review-loop economics (pass floor + severity semantics) — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development
> (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use
> checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make the mandatory Gate-A/Gate-B pass floor a function of the story profile, and decide
finding severity by whether something in the system takes a different decision.

**Architecture:** Two mirrored prose edits — `CLAUDE.md` §5 and the inline `CLAUDE.md` template in
`/workflow-init` — plus the user-facing sentences those edits falsify, plus packaging. No code
changes anywhere; **nothing under `plugins/dev-workflow/hooks/` is touched and no hook state file
is written.**

**Tech Stack:** Markdown prompts, POSIX shell for verification, `git` for the evidence records.

**Spec:** `docs/superpowers/specs/2026-08-28-review-loop-economics-design.md` (revision 36, closed
clean at Gate-A pass 34). **Read it alongside this plan** — every task argues from it.

**Story:** `docs/superpowers/stories/2026-08-28-review-loop-economics-pass-floor-story.md` —
`risk high · security none · battery+check+verification`. **Read the profile from that header, not
from here.**

---

## Global Constraints

Copied verbatim from the spec. Every task's requirements implicitly include these.

- **Prompt-only.** No file under `plugins/dev-workflow/hooks/` changes, and no hook state file is
  written — in particular not `.context/codex-gate.floor`.
- **The §5 heading must keep matching `^#{1,6}[[:space:]]+([0-9]+\.)?[[:space:]]*Cross-Model Review`.**
  `codex-gate.sh:94` greps `CLAUDE.md` for it to build the citation every reminder prints; renaming
  or renumbering the section degrades every message to a generic fallback.
- **`plugins/dev-workflow/commands/workflow-init.md` must keep exactly one `^Target model:` line.**
  `scripts/check-invariants.sh` fails on any other count. The template adds none — see Task 8.
- **Every rule this change adds lands in BOTH copies**, `CLAUDE.md` §5 and the template's §5,
  except where a difference is deliberate and stated.
- **§5's other closure rules are never restated**, only referred to. Three revisions of the spec
  were spent learning this: each summary of the triviality skip dropped a different condition.
- **Gate B for this branch's implementation commits:** §5's prose exemption needs *every* staged
  path to be explanatory documentation, and **a mixed commit forfeits it**. Tasks 1–6 and 8–9 stage
  prompt or non-`.md` paths and therefore **fire full Gate B**. Task 7 stages only `docs/**.md` and
  `README.md` and is **N/A** — provided it is committed alone, which its steps require.

---

## File Structure

| File | Responsibility in this change |
|---|---|
| `CLAUDE.md` §5 (65–589) | the live rules |
| `plugins/dev-workflow/commands/workflow-init.md` §5 (257–777, fenced 192–778) | the scaffolded mirror |
| `plugins/dev-workflow/commands/workflow-init.md` (outside the fence) | the item-1 n/a note |
| `README.md`, `docs/getting-started.md`, `docs/coding-workflow.md` | sentences this change falsifies |
| `plugins/dev-workflow/.claude-plugin/plugin.json`, `CHANGELOG.md` | packaging |
| `docs/superpowers/specs/2026-08-28-review-loop-economics-conditions.md` | the old-conditions dispositions (Task 0) |

**Line numbers in this plan were read on 2026-08-29 and drift as edits land.** Every task locates
its site by **quoted text**, not by number; the numbers are navigation aids only.

---

## Task 0: The conditions artifact, and its gate

**This task runs FIRST and nothing else proceeds until its review passes.** The AGENTS.md Don't —
"never replace a decision procedure without accounting for its old conditions" — is satisfied by
this artifact existing and being reviewed *before* any replacement text is written.

**Files:**
- Create: `docs/superpowers/specs/2026-08-28-review-loop-economics-conditions.md`

**Interfaces:**
- Consumes: the spec's §5.2 passage list (18 rows) and §5.1 site inventory.
- Produces: a dispositioned entry per passage that Tasks 1–5 must not contradict.

- [ ] **Step 1: Regenerate the site inventory rather than copying it**

```bash
grep -nE "min 3 passes|below 3|3-pass|3 passes|where the 3 come from|3-passes-per-gate" \
  CLAUDE.md plugins/dev-workflow/commands/workflow-init.md
```

Expected: **12 lines, six per copy.** If the count differs, the spec's inventory is stale and that
is a finding for the spec, not something to paper over here.

- [ ] **Step 2: Confirm the two digit-free sites the grep cannot find**

```bash
grep -n 'pass 1 carrying a Minor' CLAUDE.md plugins/dev-workflow/commands/workflow-init.md
```

Expected: exactly one hit per copy. **Fourteen sites in total.**

- [ ] **Step 3: Write one dispositioned entry per passage**

For each of the spec's eighteen passages, in a table with these columns: *passage* (quoted by its
bold lead-in), *what its existing prose requires* (enumerated, one requirement per line), and
*disposition* — **kept**, **moved** (say where), or **deliberately dropped** (say why). A
requirement neither kept nor explicitly dropped is a dropped condition and fails this task.

- [ ] **Step 4: Verify completeness mechanically**

```bash
sed -n '/^| # | Passage/,/^$/p' docs/superpowers/specs/2026-08-28-review-loop-economics-design.md \
  | grep -c '^| [0-9]'
grep -c '^| ' docs/superpowers/specs/2026-08-28-review-loop-economics-conditions.md
```

Expected: the artifact has an entry for every passage the spec lists. A missing row is the failure
this artifact exists to prevent.

- [ ] **Step 5: Commit**

```bash
git add docs/superpowers/specs/2026-08-28-review-loop-economics-conditions.md
git commit -m "docs(spec): the old-conditions dispositions for the review-loop-economics change"
```

- [ ] **Step 6: GATE — this artifact is reviewed inside the Gate-A plan cycle**

It is an input that cycle reviews alongside this plan, at the derived floor, with a clean pass as
its acceptance. **No replacement text is written while it is outstanding.** A finding against it
feeds back — regenerate against corrected text — rather than being absorbed.

---

## Task 1: The floor predicate

**Files:**
- Modify: `CLAUDE.md` — the paragraph opening `**Both gates are a LOOP with a HARD FLOOR:`
- Modify: `plugins/dev-workflow/commands/workflow-init.md` — the same paragraph in the template

**Interfaces:**
- Consumes: Task 0's dispositions for that passage.
- Produces: the phrase `max(risk, security)` in both copies, which Task 2's sites refer back to.

- [ ] **Step 1: Write the check, and watch it fail**

```bash
# Both copies must state the predicate, unanimity, and the three-cycle scope.
for f in CLAUDE.md plugins/dev-workflow/commands/workflow-init.md; do
  printf '%s: ' "$f"
  tr '\n' ' ' < "$f" | tr -s ' ' | grep -c 'max(risk, security)'
done
```

Expected now: `0` and `0`. **Run it before editing** — a check first seen passing has proved
nothing about the change.

- [ ] **Step 2: Replace the floor sentence in `CLAUDE.md`**

Current text opens: `**Both gates are a LOOP with a HARD FLOOR: min 3 passes per run (Blocker/Major`

Replace `min 3 passes per run` with the derived floor, keeping **every other requirement in that
paragraph verbatim** (the TodoWrite per pass, fix-after-each, the clean final pass, the
zero-findings early exit, Codex-is-advisory, the one-line dismissal reason):

```markdown
**Both gates are a LOOP with a HARD FLOOR: a minimum number of passes per run (Blocker/Major
only), derived from the story profile — `max(risk, security) == 0` gives **1**, and every
resolvable profile above that, or an artifact citing no story, gives **3**. A cited story whose
profile is present but unresolvable **stops and surfaces** under the rule below rather than
falling through to 3. A cycle citing several stories reaches 1 **only if the cited set is
non-empty and every member is profiled, resolvable and at level 0**; any other set gives 3.
**One derived value governs all three cycles** — the Gate-A spec cycle, the Gate-A plan cycle and
the Gate-B cycle — because they derive from the same cited-story set, not because they are one
cycle. The floor is counted by the hook,**
```

- [ ] **Step 3: Make the identical edit in the template**

Same paragraph inside the fenced block. **Byte-identical** to Step 2's replacement.

- [ ] **Step 4: Re-run the check**

Expected: `1` and `1`.

- [ ] **Step 5: Verify no other requirement in the paragraph was lost**

```bash
for f in CLAUDE.md plugins/dev-workflow/commands/workflow-init.md; do
  printf '%s: ' "$f"
  tr '\n' ' ' < "$f" | tr -s ' ' | grep -c "don't manufacture findings to pad"
done
```

Expected: `1` and `1`. That clause is the tail of the same paragraph and its survival is the cheap
proxy for "the replacement did not swallow its neighbours."

- [ ] **Step 6: Commit**

```bash
git add CLAUDE.md plugins/dev-workflow/commands/workflow-init.md
git commit -m "feat(gates): derive the pass floor from the story profile"
```

**Gate B applies to this commit** — both paths are prompts.

---

## Task 2: The fourteen floor-wording sites

Every site states a rule that a variable floor falsifies. **The one that matters most spells no
digit**: `a Blocker/Major-free pass 1 carrying a Minor keeps looping` is correct at floor 3 and
**false at floor 1**, where pass 1 is *at* the floor and therefore closes.

**Files:** `CLAUDE.md` and the template, at the seven sites each.

**Interfaces:**
- Consumes: Task 1's `max(risk, security)` predicate.
- Produces: nothing later tasks depend on.

- [ ] **Step 1: Write the check, and watch it fail**

```bash
grep -cE "min 3 passes|below 3|3-pass|3 passes|where the 3 come from" \
  CLAUDE.md plugins/dev-workflow/commands/workflow-init.md
grep -c 'pass 1 carrying a Minor' CLAUDE.md plugins/dev-workflow/commands/workflow-init.md
```

Expected now: nonzero counts. After Task 2 both must be **0**, except the historical citation —
see Step 4.

- [ ] **Step 2: Apply the seven replacements in each copy**

| Quoted current text | Replacement |
|---|---|
| `below 3 is a pass with **zero** findings` | `below the floor is a pass with **zero** findings` |
| `a Blocker/Major-free pass 1 carrying a Minor keeps looping` | `a Blocker/Major-free pass **below the floor** carrying a Minor keeps looping` |
| `don't count it toward the 3-pass floor` | `don't count it toward the floor` |
| `each its own 3-pass loop` | `each its own loop at the derived floor` |
| `which is where the 3 come from` | `which is where the floor's lower bound comes from` |
| `The 3-pass floor, the Blocker/Major` | `The floor, the Blocker/Major` |
| `if pass 3 still finds Blocker/Major` | `if the pass at the floor still finds Blocker/Major` |

- [ ] **Step 3: Re-run the check**

Expected: `0` for both greps in both files.

- [ ] **Step 4: Confirm the historical citation was NOT changed**

```bash
grep -c "PR #23's Gate-B pass 3 returned all four findings" \
  CLAUDE.md plugins/dev-workflow/commands/workflow-init.md
```

Expected: `1` and `1`. That sentence cites an actual historical pass, not a rule, and **must keep
saying 3**. Changing it would falsify a record.

- [ ] **Step 5: Commit**

```bash
git add CLAUDE.md plugins/dev-workflow/commands/workflow-init.md
git commit -m "fix(gates): reword every rule that assumed a floor of three"
```

---

## Task 3: Severity semantics

**Files:** the `**Severity:**` line in Mechanics, both copies.

**Interfaces:**
- Consumes: nothing.
- Produces: the reachability test, which Task 6's parity walk checks.

- [ ] **Step 1: Write the check, and watch it fail**

```bash
for f in CLAUDE.md plugins/dev-workflow/commands/workflow-init.md; do
  printf '%s: ' "$f"
  tr '\n' ' ' < "$f" | tr -s ' ' | grep -c 'consumes this text'
done
```

Expected now: `0` and `0`.

- [ ] **Step 2: Extend the Severity line in `CLAUDE.md`**

Keep the four existing definitions verbatim and append the classifier:

```markdown
- **Severity:** Blocker (wrong/unsafe/breaks invariant) · Major (design flaw →
  rework) → both must resolve. Minor · Nit → collect, never iterate.
  **Which side of that line a finding falls on is decided by one test, not by what kind of file
  the text lives in:** name **what in the system consumes this text** — whatever *acts* on it —
  and the decision that act takes differently if the text is wrong. **Both are required**; if you
  cannot name both, the finding is **Minor or below**. The reader must consume the text in the
  system's *operation*, not in reviewing it — **the review pass raising the finding is not an
  in-system reader of the text it reviews**, or the test would demote nothing, though gates remain
  legitimate readers of rule text they will later apply. A human reader never satisfies it: that
  cost is already priced as non-gating by the prose exemption. The list of reader kinds is
  illustrative, not closed. **The test sets a ceiling and never chooses between Blocker and
  Major** — the definitions above still do that. Findings about narration, prose describing a
  mechanism, and test-instrument internals are the cases this usually catches, as worked examples
  rather than a second rule. **An instrument finding keeps its severity whenever it shows the
  instrument changes what a gate concludes about product behaviour, in either direction** — a
  false green, and equally a false red or a check blocking a valid change. **Rationale prose is
  Minor only when no rule's application depends on it**, not categorically: `docs/prompt-standards.md`
  requires that rules carry their why, so rationale a reader must consult to apply a rule passes
  the test. This removes arbitrariness, not judgement. **This is the finding-level analog of the
  path-level prose exemption** — one principle at two granularities, text that *describes* the
  product versus text that *is* the product. Coverage-first is unchanged: the reviewer reports
  every finding with severity and confidence; the filter is ours.
```

- [ ] **Step 3: Make the identical edit in the template**

- [ ] **Step 4: Re-run the check**

Expected: `1` and `1`.

- [ ] **Step 5: Verify the four definitions survived**

```bash
for f in CLAUDE.md plugins/dev-workflow/commands/workflow-init.md; do
  printf '%s: ' "$f"
  grep -c 'Blocker (wrong/unsafe/breaks invariant)' "$f"
done
```

Expected: `1` and `1`.

- [ ] **Step 6: Commit**

```bash
git add CLAUDE.md plugins/dev-workflow/commands/workflow-init.md
git commit -m "feat(gates): decide severity by consequence, not by artifact kind"
```

---

## Task 4: The two pinned records and the cycle nonce

**Files:** both copies — Mechanics' closing-commit area and the findings-slot paragraph.

**Interfaces:**
- Consumes: Task 1's derived floor (the provenance line reports it).
- Produces: `<CYCLE-FIELD>`, which Task 5's squash-carry rule names.

- [ ] **Step 1: Write the check, and watch it fail**

```bash
for f in CLAUDE.md plugins/dev-workflow/commands/workflow-init.md; do
  printf '%s: ' "$f"; grep -c 'cycle none (pre-rule)' "$f"
done
```

Expected now: `0` and `0`.

- [ ] **Step 2: Add both grammars and the nonce rules to `CLAUDE.md`**

Copy §2.3, §4 and §5 of the spec's grammars **verbatim** — they are already pinned there and
retyping is how a production drifts. Add the surrounding rules: every cycle records a provenance
line; the curve records Findings, Blockers and Majors per valid pass with the pass numbers it
covers; an unrecoverable count is `?`, excluded **per series** and not per pass; a skipped cycle
records a skip line in place of a curve; the nonce is 8–16 chars of `[a-z0-9]` from randomness,
appears in the provenance line, the curve, the cycle's findings slots and its advisory working
record, and a cycle that cannot recover a single candidate starts fresh.

- [ ] **Step 3: Widen the findings-slot grammar in both copies**

The three slot names gain an optional per-cycle infix — `gate-a-spec[-<cycle>]-pass-<p>` and its
two siblings — with the infix **required whenever more than one cycle could write that slot**, and
a target owned by another cycle **refused rather than overwritten**.

- [ ] **Step 4: Make the identical edits in the template**

- [ ] **Step 5: Re-run the check, and parse the grammars**

```bash
for f in CLAUDE.md plugins/dev-workflow/commands/workflow-init.md; do
  printf '%s: ' "$f"; grep -c 'cycle none (pre-rule)' "$f"
done
```

Expected: `1` and `1`.

Then hand-parse the spec's five provenance examples and its curve example against the productions
as written in the shipped copies. **A grammar nothing ever parsed is a format claim, not a
format.** Record which features each example exercised: quoted path, each unusable-knob cause,
gapped ranges, split-model pass, skipped cycle, `?` count, `<COUNTS>`/`<SPEC>` cardinality.

- [ ] **Step 6: Commit**

```bash
git add CLAUDE.md plugins/dev-workflow/commands/workflow-init.md
git commit -m "feat(gates): pin the provenance line, the per-pass curve and the cycle nonce"
```

---

## Task 5: The squash carry

**Files:** the `On squash-merge, copy every evidence entry` paragraph, both copies.

**Interfaces:**
- Consumes: Task 4's record types.
- Produces: nothing later tasks depend on.

- [ ] **Step 1: Write the check, and watch it fail**

```bash
for f in CLAUDE.md plugins/dev-workflow/commands/workflow-init.md; do
  printf '%s: ' "$f"
  tr '\n' ' ' < "$f" | tr -s ' ' | grep -c 'provenance line, the per-pass curves'
done
```

Expected now: `0` and `0`.

- [ ] **Step 2: Extend the list in both copies**

Add **the provenance line, the per-pass curves, and a skipped cycle's skip record** to what a
squash must carry. **Extend the sentence — do not rewrite it.** The successor story adds the
decline record to this same passage later, and a rewrite there would drop what this adds.

- [ ] **Step 3: Re-run the check**

Expected: `1` and `1`.

- [ ] **Step 4: Verify the existing two survived**

```bash
for f in CLAUDE.md plugins/dev-workflow/commands/workflow-init.md; do
  printf '%s: ' "$f"
  tr '\n' ' ' < "$f" | tr -s ' ' | grep -c 'every evidence entry and every human-exception record'
done
```

Expected: `1` and `1`.

- [ ] **Step 5: Commit**

```bash
git add CLAUDE.md plugins/dev-workflow/commands/workflow-init.md
git commit -m "feat(gates): carry the provenance line, curves and skip records through a squash"
```

---

## Task 6: Parity, and the twelve-item conformance pass

No new text — this is the verification story criterion 7 and invariant 11 require.

- [ ] **Step 1: Walk every changed rule across both copies**

For each rule Tasks 1–5 added, extract it from both files and diff. Record every difference as
**deliberate-and-stated** or as a **defect**. The copies already diverge on ~192 lines overall, so
**a whole-section diff proves nothing** — walk the named rules.

- [ ] **Step 2: Run the twelve-item pass**

Against **each changed prompt artifact as a complete prompt**: the resulting scaffolded template
and `plugins/dev-workflow/commands/workflow-init.md`. Item 7 — no contradictions with
`CLAUDE.md`/`AGENTS.md` — is read against the whole resulting prompt, since a contradiction is a
relation between an edited passage and an unedited one. **Root `CLAUDE.md` is outside invariant
11's list and is not part of this pass.**

- [ ] **Step 3: Record item 1's n/a for the scaffolded template**

Satisfied-or-n/a-with-reason, per the story's conformance criterion. The reason: the scaffolded
file is model-agnostic by design, so a target-model line would be false in every repo it lands in.

- [ ] **Step 4: Commit the record**

```bash
git add docs/superpowers/specs/2026-08-28-review-loop-economics-conditions.md
git commit -m "docs(spec): record the parity walk and the twelve-item conformance pass"
```

---

## Task 7: The falsified user-facing sentences

**Commit these alone.** Every staged path here is `docs/**.md` or `README.md`, so §5's prose
exemption applies and Gate B is N/A — **but only if nothing else is staged.** A mixed commit
forfeits the exemption.

**Files:** `README.md`, `docs/getting-started.md`, `docs/coding-workflow.md`.

- [ ] **Step 1: Write the check, and watch it fail**

```bash
grep -nE 'three passes minimum|3-pass floor|3-passes-per-gate|floor is unchanged at every level|Gate A.s floor and' \
  README.md docs/getting-started.md docs/coding-workflow.md
```

Expected now: several hits. After this task: **zero**.

- [ ] **Step 2: Correct each sentence**

| Site | Current | Correction |
|---|---|---|
| `README.md:130` | "a positive integer; moves the 3-passes-per-gate floor" | "a positive integer; moves the **hook's reminder threshold**. It does not change the floor §5 obliges, which is derived from the story profile." |
| `getting-started.md:34` | "three passes minimum, final pass clean" | "the floor its profile derives, final pass clean" |
| `:40` | "the same 3-pass loop runs" | "the same loop runs at the derived floor" |
| `:44` | "If the Gate-A floor wasn't met, the hook says so" | "If the hook's own threshold wasn't met it says so — which at a derived floor of 1 can fire when nothing further is owed" |
| `:53` | "three passes, final clean" | "the derived floor, final clean" |
| `:58` | waits for `✓ … (3/3 …)` | show the ratio as the derived floor, not a literal 3/3 |
| `:84` | "Gate A's floor is unchanged at every level" | "Gate A's floor is derived from the profile like Gate B's; what the axes never subtract is the baseline questions" |
| `:86` | "moves the 3-pass floor" | "moves the hook's reminder threshold" |
| `coding-workflow.md:79-80` | "they never subtract any: Gate A's floor and the baseline questions are the same at every level" | "they never subtract any baseline question; the floor itself is derived from the profile" |

- [ ] **Step 3: Re-run the check**

Expected: zero hits.

- [ ] **Step 4: Commit, alone**

```bash
git add README.md docs/getting-started.md docs/coding-workflow.md
git diff --cached --name-only   # confirm ONLY these three
git commit -m "docs: correct every sentence the derived floor falsifies"
```

**Gate B: N/A** — every staged path is explanatory documentation. Verify the staged set before
committing; that verification is what earns the exemption.

---

## Task 8: The item-1 note beside the template

**Files:** `plugins/dev-workflow/commands/workflow-init.md`, **outside** the fenced template block.

- [ ] **Step 1: Write the check, and watch it fail**

```bash
grep -c '^Target model:' plugins/dev-workflow/commands/workflow-init.md
```

Expected: `1` — and it must **still be 1** after this task. `scripts/check-invariants.sh` fails on
any other count.

- [ ] **Step 2: Add the note immediately before the fence**

```markdown
> **Prompt-standards item 1 for the scaffolded `CLAUDE.md`: n/a, and why.** The file this template
> writes is model-agnostic by design — its executing model is whatever the reader of that project
> runs — so a `Target model:` line would be false in every repo it lands in. Recorded as a reasoned
> n/a rather than skipped. This note is deliberately outside the fence so it never scaffolds, and
> deliberately not a `Target model:` line, which would make this file's declaration count 2 and
> fail `scripts/check-invariants.sh`.
```

- [ ] **Step 3: Re-run the check**

```bash
grep -c '^Target model:' plugins/dev-workflow/commands/workflow-init.md
sh scripts/check-invariants.sh && echo INVARIANTS-OK
```

Expected: `1`, and the checker exits 0.

- [ ] **Step 4: Confirm the note is outside the fence**

```bash
awk 'NR>=186 && NR<=200' plugins/dev-workflow/commands/workflow-init.md
```

Expected: the note appears **before** the ```` ````markdown ```` line. Inside it, it would scaffold
into every user's `CLAUDE.md`.

- [ ] **Step 5: Commit**

```bash
git add plugins/dev-workflow/commands/workflow-init.md
git commit -m "docs(workflow-init): record item 1's n/a for the scaffolded CLAUDE.md"
```

---

## Task 9: Packaging

- [ ] **Step 1: Write the check, and watch it fail**

```bash
sh scripts/check-version-bump.sh main && echo BUMP-OK || echo BUMP-MISSING
```

Expected before the bump: the checker reports the plugin changed without a version change.
**Run it before bumping** — it is the only step here whose failure state is observable.

- [ ] **Step 2: Bump the manifest**

`plugins/dev-workflow/.claude-plugin/plugin.json`: `0.10.0` → `0.11.0`. Minor, because this
changes shipped rules without breaking a documented interface.

- [ ] **Step 3: Add the CHANGELOG entry**

Newest first, describing the floor derivation, the severity test, the two pinned records and the
nonce. **Nothing enforces this** — neither invariant 12 nor the checker mentions the changelog —
so the story's criterion is what carries it.

- [ ] **Step 4: Re-run the check and the full battery**

```bash
sh scripts/check-version-bump.sh main && echo BUMP-OK
```

Then the whole `AGENTS.md` § Commands chain, which must exit 0.

- [ ] **Step 5: Commit**

```bash
git add plugins/dev-workflow/.claude-plugin/plugin.json plugins/dev-workflow/CHANGELOG.md
git commit -m "chore(dev-workflow): 0.11.0 — profile-derived floor and consequence-keyed severity"
```

---

## Task 10: The evidence pack

The mode is `battery+check+verification`. This task produces what the closing commit body cites.

- [ ] **Step 1: The battery**

The full `AGENTS.md` § Commands chain, green, with the assertion counts recorded.

- [ ] **Step 2: The differential named verification — both revisions read**

No automated test is possible for prose, so this takes §5's other permitted route. **Pose one
question about behaviour under a derived floor of 1** and answer it against both revisions:

> *At floor 1, does a Blocker/Major-free pass 1 carrying a Minor close or keep looping?*

- Against the **pre-change** text (`git show <base>:CLAUDE.md`): the sentence says it **keeps
  looping** — wrong, since pass 1 is at the floor.
- Against the **post-change** text: it says a pass **below the floor** keeps looping — correct.

Ask the same question of `below 3` versus `below the floor`. **Record which revision was read for
each answer.** A verification that consults only the post-change text cannot fail and would report
success because of how it was wired — that is the failure mode this step exists to avoid, and
naming it is part of the entry.

- [ ] **Step 3: The risk-path verification**

The risk is that **the floor is derived by the agent and nothing mechanical checks it**. Recompute
each provenance line's floor from the cited stories' profile headers. The observation that would
exist if the claim were false is **a provenance line whose number the profiles do not license**.
Also confirm **no floor file is present at close where none was present at start** — which detects
a persisting write and **cannot** detect a transient one.

- [ ] **Step 4: The user-knob verification, conditionally**

If a `.context/codex-gate.floor` exists before a cycle, it is byte-identical after. **If none
exists, record not-applicable with that reason.** Do not create one — a fixture supplying its own
input proves nothing.

- [ ] **Step 5: Write the evidence entry**

Naming the story path and each verification's observation. It is **revalidated before every Gate-B
re-review and before the closing amend**, against the content the close will carry rather than a
commit that does not exist yet.

---

## Task 11: The three closing bodies

Two story criteria require this branch to demonstrate the pinned forms.

- [ ] **Step 1: Write the check**

```bash
git log --format='%b' -3 | grep -cE '^cycle (none \(pre-rule\)|[a-z0-9]{8,16});'
```

- [ ] **Step 2: Write each cycle's closing body**

The Gate-A spec cycle, the Gate-A plan cycle and the Gate-B cycle each carry a provenance line and
a curve, in the pinned forms. **All three use `cycle none (pre-rule)`**: every cycle on this branch
began before these rules ship, so none has a nonce and minting one would be late-created
provenance. The branch demonstrates **every field of both forms except two** — the cycle
identifier, and the knob clause's non-absent form, which needs a workspace that has a knob. Both
are recorded as **undemonstrable-here with their reasons**, not as gaps and not as satisfied.

- [ ] **Step 3: Record the nonce obligation**

The implementation commit records that **any cycle that both starts under these rules and closes**
discharges the nonce demonstration; duplicate discharge is harmless and allowed.

- [ ] **Step 4: Re-run the check**

Expected: three matching lines.

---

## Self-Review

**Spec coverage.** §2 floor predicate → Task 1. §2.1 knob and precedence → Task 1. §2.2 pass report
→ Task 1. §2.3 provenance → Task 4. §2.4 mid-cycle → Task 1. §3 severity → Task 3. §4 curve →
Task 4. §5 nonce → Task 4. §6 accounting → Task 0. §7 rollout, falsified sentences, packaging →
Tasks 7, 8, 9. §8 evidence → Task 10. §9 scope → the Global Constraints. §10 risks → carried into
the shipped text by Tasks 1 and 4.

**Placeholders.** None: every replacement is quoted, every check is runnable, no step says "handle
appropriately".

**Type consistency.** `<CYCLE-FIELD>`, `<NONCE>`, `<STORY-SET>`, `<KNOB>`, `<COUNTS>`, `<SPEC>`,
`<MODELS>` are used identically in Tasks 4 and 11 and are defined in the spec, which travels with
this plan.

**One known gap, stated rather than hidden.** Task 2's replacement wordings are proposals, not
transcriptions — the spec pins the *rules*, not the sentences. The Gate-A plan cycle reviews them,
which is exactly what that cycle is for.
