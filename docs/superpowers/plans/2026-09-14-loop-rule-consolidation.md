# §5 loop-rule consolidation — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Install one closure ordering into both §5 copies, replace the twenty-three standing sentences it falsifies across those copies and the shipped hook, and ship the result as plugin 0.12.0.

**Architecture:** Every string this change installs is already written in final form in the target text. This plan does not restate any of it. Each task names the **site**, quotes the **anchor** it installs at, cites the **target-text section** whose fenced block supplies the wording, and runs the **discriminating pair of counts** — the new wording present, the old wording gone — from the one verified fragment table below. Copying the replacement text into this plan would create the second-copy defect the whole cycle fought; a citation into an approved artifact that travels with this plan is not a placeholder.

**Tech Stack:** Markdown prompt text, POSIX `sh` (the hook), `grep`/`diff` for verification, `shellcheck`, the `claude` CLI.

**Spec:** `docs/superpowers/specs/2026-09-10-loop-rule-consolidation-target-text.md` (the text, in final form) and `docs/superpowers/specs/2026-09-10-loop-rule-consolidation-design.md` (the decisions behind it). Both are approved: Gate-A cycle `awsf1ec771` closed at pass 65 with a zero-finding file, commit `ba15e83`.

**Story:** `docs/superpowers/stories/2026-08-29-loop-rule-consolidation-story.md` — read the profile from its header at every gate call; it is the only writable copy. Six acceptance criteria; §4 holds settled decisions D1–D8.

---

## Global Constraints

- **Both prompt copies take every NEW and REPLACED section byte-identical**, except §F's seven hook items, whose destination is the shipped hook and its test and which carry no parity obligation (target §"How to read a section", §F opening).
- **C** = `CLAUDE.md`. **W** = `plugins/dev-workflow/commands/workflow-init.md`. Every line number below is re-read at execution; the inventory's numbers cite `7c0d475` and have drifted.
- **Every hook replacement installs into a double-quoted POSIX-shell `note` argument** and therefore carries no backtick, no `$(`, no backslash and no double quote. `$policy`, `$floor`, `$passes`, `$passesA` and `$fresh` are the intended interpolations (target §F opening).
- **The target's fenced blocks are normative in their words, not in their line breaks.** The spec wraps for its own readability; each copy keeps its own wrapping style. What design §7 requires is narrower and is the rule here: **every fragment this plan counts must sit wholly within one line of the file it is grepped from**, and where installing a replacement would put a counted fragment across a wrap, that fragment's line is installed unwrapped. The fragment table below states, for every count, the line it must sit on. **Nothing in this plan claims the installed bytes equal the fenced block's bytes**, and no check asserts it.
- **Invariant 5 (exact pinning)** and **invariant 12 (a plugin change requires a version bump)**: this change touches `plugins/`, so `plugins/dev-workflow/.claude-plugin/plugin.json` goes `0.11.0 → 0.12.0` with a CHANGELOG entry (design §8).
- **Invariant 11:** every prompt change passes all 12 items of `docs/prompt-standards.md`. Most at risk: item 6 (every constraint carries its reason in the same sentence) and item 8 (token-lean).
- **Invariant 4 / the hook:** no control flow, counter, fingerprint computation, routing or event handling changes. Only `note` strings and their expectations.
- **Gate-B cycle discipline:** snapshot commits are named `WIP: …`, and a non-`WIP` commit mid-cycle resets the hook's counters. **This change closes with `git reset --soft "$BASE"` followed by one commit, not with `--amend`** — Mechanics prescribes the reset shape wherever several WIP snapshots piled up, and this plan makes one per task. Task 15 step 8 is the operation.

---

## Verification fragments — verified against the real files

**Every OLD fragment below was tested against all three conditions** — single-line, unique in each copy the row claims, and **absent from the target text's replacement blocks** — at `9f13a2c`. Each returned one hit in each copy its row names; **row P1 has no fragment**, and rows P5 and P5w are per-copy, so the claim is about the copies each row claims and not about both copies for every row. No task may invent a fragment; a task needing one not listed here adds it and runs the same three checks first.

**Three ways a fragment fails:** it wraps across a line break, so `grep -F` counts zero in a correct file; it stands in **the wrong relationship to its own replacement** for the result its class expects — an OLD half preserved inside the block can never reach zero, and a carried condition's fragment *absent* from the block can never be found after the install; or it is not unique, so a count of 1 proves nothing about which occurrence changed. **The third test is class-specific and the table below states it per class.**

**This table exists because both of the first two drafts got this wrong, in a different one of those three ways each time.** Pass 1 found nine fragments that wrapped or quoted text that does not exist. Pass 2 found three that were preserved inside their own replacements — the condition the checker used for pass 1 did not test, though this plan had stated it. The third condition is now checked **against the target text's fenced blocks**, not against the whole file: a fragment quoted in an item's rationale is not preserved by its replacement, and testing the whole file rejects usable fragments.

| # | Edit | OLD fragment (single-line, not preserved in its replacement) | C | W |
|---|---|---|---|---|
| P1 | §A1/A2/A3 | *(none — counterfactual ABSENT, presence only)* | — | — |
| P2 | `b7`, the fix-set definition | `scope the approved story or plan assigns to this cycle, plus repair obligations you already` | 201 | 408 |
| P3 | `b12`, immediate resumption | `the moment the user says whether the set now includes it` | 208 | 415 |
| P4 | `c14`, below-floor Minor | `a Blocker/Major-free pass below the floor` | 239 | 442 |
| P5 | `e7`, the threshold — **C** | `not discretionary** — you report` | 266 | — |
| P5w | `e7`, the threshold — **W** | `not discretionary** — report the` | — | 470 |
| P6 | `g1`/`g2`, the handed-over question | `is not settled here, and this change does not settle it` | 811 | 997 |
| P7 | §G, the one-contract paragraph | `These records are one contract` | 879 | 1063 |
| P8 | `c18`, no-clean-credit | `the resolve rule is not waived, no pass is credited as` | 243 | 446 |
| P9 | `a13`, the no-restating prohibition | `Every other rule stated here about how a cycle closes` | 129 | 336 |
| P10 | `a16`, the per-pass fix command | `fix Blocker/Major after each` | 132 | 339 |
| P11 | `a17`, the clean-final-pass rule | `final pass must be clean` | 133 | 340 |
| P12 | Gate-A clean signal | `when a pass is clean` | 565 | 757 |
| P13 | gate-prompt template clean sentence | `clean pass is the single body line` | 329 | 523 |
| P14 | Gate-A cadence | `Each pass: validate, revise, re-run` | 573 | 764 |
| P15 | lens unchanged-list | `The Blocker/Major filter, the file-first findings protocol` | 653 | 839 |
| P16 | strict-reading list | `and the nonce duties at their strictest — the cycle` | 157 | 364 |
| P17 | §F item 14, Named residual | `Hook text is out of scope here` | 139 | 346 |
| P18 | §F item 18, work-loop line | `execute → tests green → Gate B → commit` | 63 | 262 |

**The fourteen §F prompt-copy items (Task 8) — fifteen rows, because item 7 changes two clauses on two lines — derived from each item's cited lines and checked the same three ways.** Pass 2 found these deferred to the executor as `<item OLD>` placeholders, which put fourteen meaning-changing checks outside Gate A's reach; they are concrete now. The NEW halves stay deferred, for the reason the paragraph below gives.

| Row | §F item | OLD fragment | C |
|---|---|---|---|
| F1 | 1, the `WIP:` naming warning | `nor resets your pass counters. A pre-review snapshot named anything else reads as a` | 825 |
| F2 | 2, the Gate-B coverage instruction | `` `NO FINDINGS` if clean" in `additionalContext`, with the same one-line format. `` | 598 |
| F3 | 3, the curve's Majors rationale | `**Majors are recorded as well as Findings and Blockers**, because the severity rule moves the` | 938 |
| F4 | 4, the human-exception scope sentence | `neither a human's assent nor this record` | 1015 |
| F5 | 5, the `Finishing the cycle` lead-in | `**Finishing the cycle:** after the final clean pass, close it with` | 827 |
| F6 | 6, the Gate-A broad-prompt instruction | `reviews the TEXT you pass, not the git tree). Use ONE broad prompt, re-run it` | 553 |
| F7 | 7, the human-exception destination (`h4`) | `**Which commit:** an ungated change records it in that commit; a Gate-A cycle in the spec or` | 988 |
| F7b | 7, the Gate-B destination (`h5`) | `restated by the closing amend` | 989 |
| F8 | 8, the profile-change pass claim | ``snapshot by amend — a non-`WIP` commit reads to the hook as the cycle closing and would`` | 752 |
| F9 | 7a, the mid-run recovery sentence | `taken from the provenance line and the curve, which must agree. A Gate-A cycle mid-run has no` | 416 |
| F10 | 8a, the HARD FLOOR parenthetical | `(Blocker/Major only), derived from the cited story's profile.**` | 73 |
| F11 | 8b, the Gate-A filter clause | `intent + artifact text + which invariants it touches. Ask for **every** finding` | 561 |
| F12 | 9a, the revalidation trigger | `and the named evidence but not the mode value**, and is **revalidated before every Gate-B` | 726 |
| F13 | 9b, the severity-deciding fallback | `decision that act takes differently if the text is wrong. Both are required. If you` | 788 |
| F14 | 9, the revalidation remedy | `profile sits still. If revalidation changes the entry, the clean pass no longer covers what` | 728 |

**W line numbers are deliberately not carried for F1–F14.** Each fragment was verified unique in W as well as C, but the template's numbers drift with every earlier task and a stale number here would read as source drift. Locate each in W by the fragment.

**`e7` is the one edit needing a per-copy fragment**, because W drops the pronoun: C reads `you report the tells`, W reads `report the tells`. That is the recorded `e8` divergence, and it **does not survive this change** — see Task 5.

**The NEW fragment for every pair is taken from the installed line and checked the same way**, since the new wording does not exist until the task installs it. Each task's step says which sentence of its target block to take it from, and the step fails if the fragment it chooses is not single-line and unique in the installed file. **This is the one place the plan cannot pre-verify**, and it is disclosed rather than papered over.

**The table is the only authored copy of every fragment, and no task step below quotes one** — each names a row id. A plan stating a fragment twice has the second-copy defect it was written to avoid, which is what pass 3 found.

### The verification procedure, stated once and performed by the executor

**This plan does not pre-write the shell for each pair, and five Gate-A passes are the reason.** Design §7 assigns the plan to *build each pair against the real files and run both directions there* — **there**, where the installed text exists. Pre-writing commands for wording that does not exist yet produced, pass after pass, blocks that could not run: helpers defined in one shell and called in another, loop bodies outside their loops, `sed` ranges whose delimiters appeared in their own data, variables no step ever set. **Every one of those was a defect in the apparatus, never in the change.** What the plan owes is the *rule*, the *verified OLD fragments*, and the *expected result*; the executor writes the command in front of the files.

**For each meaning-changing edit, at the task that installs it:**

1. **Take the OLD fragment from its table row.** Confirm before editing that it counts **1** in each copy the row claims.
   **Where the row does not exist yet, derive it here — before the install, never after.** Several tasks below add rows: after the edit the old wording is gone from the worktree, so the three-condition check cannot be run against the file it is about, the pre-edit count of 1 cannot be observed at all, and the executor is left reconstructing a fragment from the parent tree or from prose. A fragment derived that way can no longer catch the thing this step exists to catch — that the file drifted, or that a partial re-run already applied the edit. **Derive, validate the three conditions, count 1, append the row, and only then install.**
2. **Install the block.**
3. **Choose a NEW fragment from the installed text** and check it the same three ways: **single-line** in the file, **unique** there, and **absent from the parent tree**.
4. **Count four values** — OLD and NEW, each in the worktree and in `$BASE` — and record them.

**A pair passes only on `old/worktree=0 old/parent=1 new/worktree=1 new/parent=0`.** All four matter: a copy carrying the new wording **and** the old one satisfies a one-sided presence check, which is the two-instructions-that-disagree failure the pair exists to catch.

**Guard every count against an empty pattern.** `grep -cF ""` matches every line, so a mistyped or unset fragment reports a healthy-looking number against nothing. **Check that each fragment is non-empty before counting with it** — this is the failure mode pass 4 found in a generated helper, and it is silent.

**An add-only edit owes presence alone**, because there is no old wording whose absence could be counted: `new/worktree=1 new/parent=0`, and no OLD half. **Which edits those are is decided against the real file** — an add-only edit is one whose site carries no wording the change removes. Design §7 declines to classify them and so does this plan; the executor does it with the file open.

### Checking a fragment — the three conditions, and how each has failed

| Condition | How it fails | Found at |
|---|---|---|
| **Single-line** in the file it is counted in | it wraps, so `grep -F` counts zero in a correct tree | pass 1, nine rows |
| **Unique** in that file | a count of 1 proves nothing about which occurrence changed | — |
| **The right relationship to its own replacement** — and that differs by class | a fragment required to disappear that survives, or one required to survive that is not there | pass 2, three rows; pass 17, the whole carried class |

**The third condition is class-specific, and reading it as one rule breaks the carried class.**
A fragment whose count must reach **zero** has to be **absent** from the replacement; a fragment
whose count must stay **one** has to be **present** in it, unchanged. Those are opposite tests:

| The row's class | Its fragment must be | Because its expected result is |
|---|---|---|
| **replaced** (OLD half), **dropped**, **moved** (source) | **absent** from the replacement block | `worktree=0` — a surviving fragment can never reach zero |
| **carried** | **present, unchanged**, in the replacement block | `worktree=1` — the block is what preserves it, so a fragment absent from the block cannot be found afterwards |
| **kept** sharing a line with changed text | **outside** every replacement block's extent | `worktree=1` — it is not reproduced by any block; it survives because nothing replaces it |

**Applying the absent-from-its-replacement test to a carried row rejects every correct fragment**,
so a task either stops before installing or quietly drops its carried coverage. The table's cut
widened at pass 9 to hold these rows; this test did not widen with it.

**The third check compares against the target's fenced blocks with line breaks normalized.** `F4` is one line in `CLAUDE.md` but the block wraps it between `you` and `still`; a substring test finds nothing and the row looks usable. Pass 4 found it, and re-running the normalized check over every row then in the table found that one and no other.

**That sweep predates row F7b**, which pass 6 added, and the snapshots the two tables cite predate it too. **Re-run all three checks over every row the tables now hold before Task 0 finishes**, and record the revision you ran them at — a row presented as covered by a sweep that could not have seen it is a claim about evidence that does not exist. *(No count is stated here on purpose: a number in this sentence goes stale the next time a task appends a row, which is the enumeration failure this plan keeps finding in itself.)*

### The OLD fragments

**Every row below was checked all three ways at `58b3660`.** A row Tasks 3, 4, 6 and 7 add is checked the same way and appended here, so this table stays the one place they live.

**No task pre-assigns a row id, and none refers to a row by a number this plan does not already
contain.** A task appending rows takes the **next free `P` id at the moment it appends**, and
names its own rows by the condition they observe — "the `c14` row", "the resolve-duty row" — not by
a number chosen in advance. **Tasks 3, 4, 6, 7 and 10 all append**, and how many each adds is
decided at execution against the real files, so any number written here ahead of time is a guess
that the task running before it invalidates. An earlier draft promised Task 4 the ids `P19` and
`P20` while Task 3 was told to continue the same series, which hands two different fragments one id
and leaves every later reference ambiguous.

**Task 10 appends too, and its rows are not optional.** Its eight OLD fragments come from the hook,
whose live wording exists in exactly one file and is gone after installation. A fragment derived,
used and never recorded leaves a partial rerun free to pick a different one, and leaves Task 15
unable to say which counterfactual produced the counts it publishes. **The table is the one place
every OLD fragment lives, whatever file it came from.**

**What the table holds, stated as one cut: fragments that exist *before* the edit.** That is the
OLD half of every pair, every **absence** check's fragment, and every **carried** or
line-sharing **kept** condition's preservation fragment — all of them checkable in advance, which
is what the table is for. **What it does not hold is anything that exists only after installation**
— the NEW half of a pair, and an add-only edit's presence fragment.

**Where those go, since they do not go here.** Each
task records its chosen NEW and presence fragments, with the four counts observed for each, under
`## Fragment evidence (per-task output)` at the end of this plan — **one subsection per task,
replaced idempotently on re-run by the same rule Tasks 13 and 14 use.** Task 15 step 5 assembles
the closing evidence entry from that section, so a fragment recorded anywhere else is a fragment
the closing commit cannot carry.

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

### What each disposition owes, stated once

**A disposition is not a label; it names the observation that condition is owed.** Every task below
consults this table rather than restating it, and **a condition whose check does not match its
disposition is a defect in one of the two** — four consecutive passes found one, each time in a
different passage, because each task was inventing the rule for its own conditions.

| Disposition | The observation it owes |
|---|---|
| **kept** | inside an untouched span, **or**, where it shares a line with changed text, its own per-condition count: `parent=1 worktree=1` in each copy. Never both, and never neither. |
| **carried** | a **preservation count** after installation, `1` in each copy, from the condition's own text. **No untouched span covers a carried condition** — it sits inside a replacement block, which is the whole reason it is not recorded as kept. |
| **replaced** | a **discriminating pair**, `old/worktree=0 old/parent=1 new/worktree=1 new/parent=0`, **both halves from the same edit**. |
| **moved** | **two** observations: an **absence** at the source, `parent=1 worktree=0`, and a **condition-specific presence** at the destination, `worktree=1 parent=0`. A presence check on the destination *paragraph* is not the second half — it passes while any one moved predicate is missing from it. |
| **dropped** | an **absence check**, `parent=1 worktree=0`, **one per dropped condition**. Two dropped conditions sharing one fragment is one observation, and it goes absent when either half goes, leaving the other free to survive. |
| **add-only** | **presence alone**, `worktree=1 parent=0`. There is no old wording whose absence could be counted. |

**These six words are the only dispositions, and the tables below use no others.** A condition
described as "changed" would name no class, so the procedure would give it no observation and a
literal execution would skip it — §B alone accounts for nine conditions that were labelled that
way. A condition whose sentence is given entire and differs from the parent is **replaced**,
however small the difference and whether the edit adds a clause or rewrites the sentence.

**A reader walk is never any of these.** Tasks walk their conditions as a reader's confirmation on
top of the counts; a walk that found what the counts missed means a fragment was wrong, not that
the walk was the check.

### How a task discharges that table — the procedure, so no task enumerates ids

**No task below lists which of its conditions owe which check.** Five consecutive passes found a
condition missing its observation, and every one of them was in a task that had enumerated some of
its ids and not the rest. **An enumeration per task is a second copy of the disposition table**,
and it goes stale exactly the way every other enumeration in this cycle has.

**The unit is the source block a task replaces, not the passage it sits in.** A passage can be
edited by two tasks — passage (c) is split between Task 4's clearly-stuck block and Task 7's
`c18`-and-surfacing block, and passage (a) between Tasks 7 and 8 — so **a task walks the conditions
its own replaced blocks cover, and stops at their boundaries.** Walking the whole passage makes a
task append rows it cannot discharge after its own install, and makes two tasks append a row each
for the same condition, which is the fragment table's one-copy rule broken from a new direction.

**Each editing task runs this, against the disposition table's rows for its own blocks:**

- [ ] **Before installing** — walk every condition those blocks cover. **Where the fragment table
  already has a row for it, reuse that row and confirm its pre-edit count; append nothing.** The
  table is the one authored copy, and a walk that appends a second row for `b7`, `b12` or `c14`
  would run two observations of one edit and leave the ledger depending on whether the executor
  silently inferred an exclusion. **Otherwise** derive the
  **pre-existing** fragment its disposition owes: the **OLD** half for a *replaced* one, the
  **absence** fragment for a *moved* or *dropped* one, the **preservation** fragment for a
  *carried* one, and, for a *kept* one, a preservation fragment **only where no untouched span can
  hold it** — which is the case for every kept condition in a passage this task replaces whole, and
  for any that shares a line with changed text. Check each the three ways, confirm its expected
  pre-edit count, and append it to the fragment table under the next free `P` id.
- [ ] **After installing** — run each one **to the result its own class owes, which is not the same
  result for all of them**: a *replaced* row to the four-value pair, a *moved* or *dropped* row to
  `parent=1 worktree=0`, a *carried* or *kept* row to `parent=1 worktree=1`. **A step that says
  "run a pair for every row" cannot be satisfied on correct text**, because a carried fragment has
  to still be there. Choose the **post-install** halves — the **NEW** for each pair, the
  destination **presence** for each moved condition — from the installed text, verified the three
  ways before counting. Record those in this task's fragment evidence.
- [ ] **Then walk the conditions as a reader**, which confirms the counts and replaces none of them.

**Two consequences worth stating, because both have been got wrong.** A **kept** condition inside a
passage a task replaces whole is **not** protected by an untouched span — no span survives there —
so it owes a per-condition count like a carried one. And **every one of these fragments is
pre-existing**, so all of them are derived *before* the install, including the carried and kept
preservation fragments that an earlier draft chose afterwards.

### Passage (a) — the floor paragraphs → target §H (Task 7)

| Condition | Disposition |
|---|---|
| a3–a12, a14 | **kept**, untouched. The floor arithmetic, the hook-ratio rules and the two comparison points are outside this change. |
| a1 | **carried**, not kept. §F item 8a's fenced block opens with `**Both gates are a LOOP with a HARD FLOOR: a minimum number of passes per run` — `a1` itself — and reproduces it so one contiguous string installs. **Recorded as carried for the same reason as `a15`, `a21`, `a22`, `c15` and `i4`–`i8`**: a condition inside a replacement block is not untouched text, and calling it untouched would put it inside an untouched-range span that a correct implementation then fails. It owes a preservation check, not a span. |
| a2 | **replaced.** §F item 8a rewrites the HARD FLOOR parenthetical `(Blocker/Major only)` — Task 8, row F10. The filter itself survives in the ordering, which states what a pass counting toward the floor must be; what goes is the parenthetical's claim that Blocker/Major is the *whole* of it. **Marked replaced rather than kept**, because a condition whose text the change in fact rewrites, recorded as preserved, is the dropped-condition failure `AGENTS.md` names. |
| a13 | **replaced** — scoped to its own paragraph. §H's `a13` block. **The inventory defines `a13` as two sentences**, `This replaces the pass-count number and nothing else.` and `Every other rule stated here…`, and §H supplies **one** sentence for both. So the block replaces the whole condition, first sentence included, and **that first sentence owes an absence check of its own** — row P9's fragment sits in the second. §H's parenthetical line range is a locator, not the extent; installing over the second sentence alone leaves `This replaces the pass-count number` standing beside an ordering that changes more than a number, with every stated count still passing. |
| a15 | **carried** inside §H's `a16` block, which reproduces it so one contiguous string installs. |
| a16 | **replaced** — points at Mechanics · Severity instead of carrying an unscoped copy. §H's `a16` block. |
| a17, a18, a19 | **moved** — the floor paragraph stops stating the clean-final-pass rule and the early exit; both are stated once in §A. §H's `a17`–`a22` block. |
| a20 | **moved** to §A unchanged, beside the zero-finding rule it qualifies. |
| a21, a22 | **carried** unchanged, reproduced in §H's block for the same contiguity reason as a15. |

### Passage (b) — what a loop absorbs → target §B (Task 3)

§B states its own accounting and this table reproduces it: **Replaced:** `b3`, `b7`, `b8`, `b11`, `b12`, `b13`, `b16`, `b17`, `b18`. **Added:** the closing-time change rule, and that alone — no inventoried condition carried it because none existed. **Carried:** `b1`, `b2`, `b4`, `b5`, `b6`, `b9`, `b10`, `b14`, `b15`.

**Decision 6's decline semantics are not a §B addition.** `**Decline is available only at a membership stop**` is a §A sentence, and Task 1's presence checks cover it. An earlier draft listed it here as a second added rule, which would have sent Task 3 looking for a §B fragment that does not exist — and the only way to satisfy that check is to certify an unrelated decline clause.

**Verify against the file, not against this table:** §B is written out whole and is the only place this change states passage (b). Read the installed passage and confirm each carried condition is present and each changed one is gone.

### Passage (c) — recognizing clearly stuck → target §C (Task 4) and §H (Task 7)

| Condition | Disposition |
|---|---|
| c1, c2, c3 | **kept** — the curve-reading sentences are untouched. |
| c4 | **replaced** — "a missing one means keep going" becomes "means only that *this* exit does not apply", the pass's actual next step being the ordering's. |
| c5, c6, c7 | **carried word for word** inside §C's block. |
| c8 | **replaced** — gains the re-raised-dismissal clause. |
| c9 | **moved.** The inventory defines `c9` as the operative precedence clause alone — `**a clean completion takes precedence over this exit**` — and that clause moves into §A, capitalized as a standalone sentence. So it owes the moved pair: an absence here, a condition-specific presence in §A. **It was recorded as "split", which is not one of the six dispositions** and left the procedure with no result to run. |
| — | **the plateau rationale is not `c9`** and carries no id: it is unnumbered source text that **stays** at this site while `c9` leaves it. It owes a **preservation** observation under its own name, `parent=1 worktree=1`, and must not be recorded as part of `c9` — one condition cannot be required to vanish and to remain. |
| c10, c11 | **moved** to §A, which states what a Blocker/Major-free pass at or above the floor does. |
| c12, c13 | **moved** to §A, beside a19. |
| c14 | **replaced, not moved.** The ordering splits the below-floor Minor case into suspend and continue; no copy of the live wording survives beside them. |
| c15 | **carried.** §H's block reproduces `**Surfacing does not close the cycle, and that is what makes this reachable.**` verbatim; it is reproduced because the plan installs one contiguous string, not because it changes. |
| c16 | **replaced** — §H's block. The hold is now over the cycle and the new hold, not over the finding alone. |
| c17 | **replaced** — the resolve rule now scopes to the assigned fix set and states what a validly dismissed recurrence owes. |
| c18 | **replaced** — the blanket no-clean-credit goes; a pass is credited on its own findings, and a scope-stop trigger is what withholds credit. |
| c19 | **replaced** — the one-answer resumption goes; what the answer does is the ordering's. |
| c20 | **replaced.** The prohibition on the "stop instead of fixing" reading survives, but its scope narrows from "every Blocker and Major" to "every **in-set** Blocker and Major" — a meaning change, installed by §H's `c18`-and-surfacing block. **Marked replaced rather than carried**, because a narrowed condition recorded as preserved is exactly the dropped-condition failure AGENTS.md requires this accounting to expose. |

### Passage (d) — from pass 4 onward (Task 0 check only)

`d1`–`d7`: **all kept, untouched.** The unavailable-history block moved to the successor story with D10 and this change no longer edits this passage (design §5). **A diff touching C 255–261 or W 459–465 is a defect.**

### Passage (e) — the five tells → target §D (Task 5)

| Condition | Disposition |
|---|---|
| e1–e6 | **kept** — the five tells themselves are untouched. |
| e8 | **replaced.** The inventory records it as a parity divergence — C `you report`, W `report` — and §D's block supplies C's wording for **both** copies, so W's form goes. **Not carried**: the condition as inventoried names a difference this change removes. Task 5. |
| e7 | **replaced** — gains the read-after-clean-completion clause. The sentence is given entire in §D. |
| e9 | **carried** inside §D's block — `the "clearly stuck" reading above is not a precondition for it` closes the replacement sentence and is reproduced in it. Owes a preservation check, not a span. |
| e10 | **kept**, untouched, and **outside** the replacement. `A loop can be worth stopping long before it plateaus.` is the sentence *after* §D's block; an earlier draft listed it as carried, which would have put a kept condition inside a replacement it never enters and left the real boundary of the edit unstated. |
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
| h1, h2, h6, h8–h12, h14–h18, h20–h26 | **kept**, untouched. |
| h3 | **carried**, not kept. §F item 7's fenced block reproduces `an ungated change records it in that commit` verbatim — `h3` itself — because the item replaces the whole `**Which commit:**` sentence and only the Gate-A clause changes. A condition inside a replacement block is not untouched text, so it owes a **preservation count** and is covered by no span. Task 8 derives its fragment before installing item 7. |
| h5 | **replaced** — §F item 7 changes the Gate-B destination from "restated by the closing amend" to "restated by the commit its closing act produces", the amend no longer being the only closing shape. Row **F7b**, which is its own row because item 7 changes `h4` and `h5` on two different lines and one fragment cannot observe both. |
| h4 | **replaced** — §F item 7, the human-exception destination: a Gate-A cycle's record goes to the commit its closing act produces, not to "the spec or plan commit". |
| h7 | **kept.** |
| h19 | **replaced** — §F item 4, the scope sentence: "neither a human's **general** assent nor this record", plus the clause distinguishing the answers a suspension asks for from assent. |
| h13 | **kept**, and lifted out of the `h8`–`h18` run above so no id is disposed twice. Design §4 names this sentence as deliberately not edited: this change ships no record for the squash carry to carry. |

### Passage (i) — when these rules bind → target §H (Task 7)

`i1`, `i2`, `i3`, `i9`–`i11`, `i13`–`i16`: **kept**, untouched.
`i4`–`i8`: **carried**, not merely kept. §H reproduces the whole dash-delimited run as one contiguous string so the plan installs it in a single edit, and the five conditions come through unchanged inside it. **Recorded as carried rather than kept** for the same reason `a15`, `a21`, `a22` and `c15` are: a condition reproduced inside a replacement block is not untouched text, and calling it untouched would put it outside the untouched-range checks that are supposed to protect it.
`i12`: **discharged, and kept.** It is the extension point that licenses the addition; it stays because the next change needs it too.

### Passage (j) — the squash carry (Task 0 check only)

`j1`–`j4`: **all kept, untouched.** It was to name the answer record, which moved to the successor; this change ships no record for it (design §5). **A diff touching C 892 or W 1076 is a defect.**

---

## Task 0: Establish the baseline and the do-not-touch set

**Files:** none modified.

**Interfaces:**
- Produces: `$BASE` (the parent commit every later task's counterfactual half runs against), and the five untouched passage ranges recorded as **anchor spans plus a per-condition fragment list** — never as absolute line numbers, for the reason step 2 gives.

- [ ] **Step 1: Confirm the approved artifacts and a clean tree**

```bash
test "$(git rev-parse --abbrev-ref HEAD)" = loop-rule-consolidation || { echo "wrong branch"; exit 1; }
test -z "$(git status --porcelain)" || { echo "tree not clean"; exit 1; }
git merge-base --is-ancestor ba15e83 HEAD || { echo "approved target text (ba15e83) is not in this history"; exit 1; }
# The three inputs must still be the versions that were approved, not merely present.
for f in target-text design condition-inventory; do
  p="docs/superpowers/specs/2026-09-10-loop-rule-consolidation-$f.md"
  test "$(git rev-parse "HEAD:$p")" = "$(git rev-parse "ba15e83:$p")" \
    || { echo "$p differs from its approved version at ba15e83"; exit 1; }
done
if [ -s .context/loop-rule-base ]; then
  echo "base already recorded: $(cat .context/loop-rule-base) — NOT overwriting"
else
  git rev-parse HEAD > .context/loop-rule-base
fi
cat .context/loop-rule-base
```

**Every line above fails the script; none of them prints for a human to notice.** An earlier draft
printed `git rev-parse --abbrev-ref HEAD` and `git status --porcelain` under comments saying what
to expect, which asserts nothing: a wrong-branch or dirty checkout would be recorded as `$BASE` and
every install and the final soft reset would run from the wrong starting tree.

**The inputs are compared by blob, not merely found.** `ba15e83` being an ancestor says the
approved commit is in this history; it does not say the three files still hold what was approved,
and a later unapproved edit to the target text would supply different installation instructions to
every task. **`ba15e83` appears once, as the approval commit**, and the loop compares each input's
object id against its version there.

**What this cannot establish, stated rather than implied:** that *this plan revision* is the one
Gate A closed on. A plan cannot name its own closing commit, and any sha written here would be from
before that commit exists. **The Gate-A findings files in `.context/codex-reviews/` are the record
of which revision was reviewed**; a reader checks the plan against them, and nothing mechanical
here does it.

**Never overwrite an existing base, and never trust one you did not just write.** Re-running Task 0
after a partial implementation would record the current WIP tip, and both Gate B's range and the
final `reset --soft` would then start after every edit made so far — prompt and hook changes would be
squashed into the closing commit without ever entering a review range.

**A pre-existing value is not accepted on being non-empty.** It is valid only if it is an ancestor of
`HEAD` **and** every commit between it and `HEAD` is a `WIP:` commit of this execution. **Both
halves are checked, and the ancestry one first:**

```bash
B=$(cat .context/loop-rule-base)
git merge-base --is-ancestor "$B" HEAD || { echo "recorded base is NOT an ancestor of HEAD — stale or from another branch"; exit 1; }
git log --oneline "$B"..HEAD
```

**`git log "$B"..HEAD` does not test ancestry**, and reading it as if it did is how a base from an
abandoned branch passes: the range then lists what `HEAD` has and `$B` does not, which can be only
`WIP:` commits while `$B` sits on a branch of its own. `git reset --soft` onto it at Task 15 step 8
would move `HEAD` to that unrelated commit and drop every real commit since the fork. `merge-base
--is-ancestor` is the test the sentence above actually names.

Expected: the ancestry check exits 0, and the log shows nothing, or only `WIP:` commits of this run. **Anything else means the file is stale** —
left by an abandoned run, or by one whose work was already squashed. Delete it deliberately, record
why, and re-record from the true starting commit. **Task 15 step 8 removes the file after the
closing commit**, so a stale one is an abandoned run rather than a normal state.

**Persist it to a file, not to a shell variable.** Each task runs in its own shell invocation, so a
`BASE=` assignment in Task 0 is gone by Task 1 and every parent-tree count would run against an
empty revision — which fails loudly in `git show` but quietly in a `grep -c` pipeline. Every later
task that counts anything begins by reading it back and refusing an empty value:

```bash
BASE=$(cat .context/loop-rule-base)
test -n "$BASE" || { echo "BASE empty — Task 0 did not run"; exit 1; }
```

**The guard is not decoration.** With `$BASE` empty, `git show ":$f"` reads the *index* rather than
the recorded parent, and every parent count then describes the wrong tree without erroring.

**This commit is also `baseSha` for Gate B.** It is the parent of the first WIP snapshot, and it is
the only value that puts the whole implementation inside the reviewed range. `.context/` is ignored
by the hook's fingerprint, so the file itself moves nothing.

**On re-entry, steps 2 and 3 are not re-run — they are validated.** Step 1 admits a recorded base
followed only by this run's `WIP:` commits, which means text tasks may already have run. **Steps 2
and 3 describe the tree as it was at `$BASE`**: after a text task, the OLD extents they map are
gone and the aligned divergences no longer match the baseline expectation, so re-deriving them from
the worktree either overwrites the evidence with a map of the partly edited tree or fails on
differences this plan itself installed.

**Each artifact carries the base it was built from, as its first line:**

```
base<TAB><the 40-character object name>
```

Written by the step that creates it, and it is what "keyed to `$BASE`" means — without it there is
no comparison to make and a stale map from an abandoned run is indistinguishable from this one's.

**So:** if `.context/loop-rule-untouched` and `.context/loop-rule-baseline-diff.txt` already exist,
**read their `base` line and require it to equal `.context/loop-rule-base`**; on a match keep them
and re-derive neither, on a mismatch or a missing line delete them and rebuild. If they are absent
while `$BASE` has `WIP:` commits after it, **derive both from the `$BASE` blobs** —
`git show "$BASE:<path>"` — not from the worktree. On a clean first run the two sources are the
same thing, which is why this is stated once here rather than in each step.

- [ ] **Step 2: Re-read the five untouched ranges and record their current anchors**

Passages (d), (f) and (j) are not edited by this change, and passage (a)'s arithmetic and passage (h)'s kept conditions are untouched. **No count of them is stated here.** One was, and it was wrong twice — first omitting `h5`, which item 7 replaces alongside `h4`, then counting `h3` as kept where item 7's block reproduces it and it is carried. **The disposition table above is the one place the classes live**; a number repeated here is a second copy of it that goes stale the next time a condition moves class, which has now happened three times. Record where the regions are now, because the inventory's numbers cite `7c0d475`:

**Five ranges, each with a start and an end anchor** — the three whole passages, plus the floor
arithmetic and the kept human-exception conditions, which later verification consumes and which the
first draft omitted:

```bash
for f in CLAUDE.md plugins/dev-workflow/commands/workflow-init.md; do
  echo "== $f"
  grep -n 'From pass 4 onward every pass report carries three lines' "$f"   # (d) start
  grep -n 'Those three lines expose' "$f"                                    # (d) end
  grep -n 'The two rules above do not compete' "$f"                          # (f) start
  grep -n 'Findings go to a FILE' "$f"                                       # (f) end
  grep -n 'On squash-merge, copy every evidence entry' "$f"                  # (j) single line
  grep -n 'Both gates are a LOOP with a HARD FLOOR' "$f"                     # (a) region marker — NOT a span start, see below
  grep -n 'Nothing here writes the floor knob' "$f"                          # (a) arithmetic end
  grep -n 'Recording a human exception' "$f"                                 # (h) start
  grep -n 'because writing it down makes it sound' "$f"                      # (h) end
done
```

Expected: one hit per pattern per file. Write the **anchor strings**, not line numbers, into
`.context/loop-rule-untouched` — **Task 2 and Task 14's final check both read them.**

**Anchors, never absolute line numbers.** Task 1 inserts a large block, so every recorded number
after the insertion point addresses different text in the parent than in the worktree, and a
comparison using them reports CHANGED on identical content. Each check resolves its own start and
end anchor in each tree at comparison time.

**Two ranges must be split around the conditions this change replaces**, or a correct
implementation fails its own check — and each split must leave **every kept condition inside some
span**, which the first draft's version did not:

**This plan states the derivation and not the spans**, because writing them out by hand has now
been wrong twice — once enclosing row F7b's line in the human-exception region, once opening on
`a1`'s line and ending on the line `a13` and `a14` share. Neither is visible without the file open,
and each makes a **correct** implementation fail its own check. **Derive them, with the files
open:**

1. Resolve each of the five regions' start and end anchors.
2. **Collect the full line extent of every replacement whose live extent intersects that region —
   not the line its fragment sits on.** A fragment is one line; the block it belongs to usually
   spans several, and every line a replacement occupies is changed whether or not a fragment sits
   on it. Resolve each replacement's **first and last** live line, take the whole run, and merge
   overlapping runs.
   **No example list is given here, and that is deliberate.** One was written three times and was
   wrong all three — naming a block that sits outside the region, omitting one inside it, and
   naming a fragment's line for a block's extent. Which replacements intersect a region is decided
   by resolving both against the file, and any list written in advance is a fourth guess. Walk the
   target's replacement blocks, resolve each one's extent, and keep the ones that overlap.
3. **The spans are the gaps between those runs.** A region with no replacement in it is one span;
   a region with *n* runs is at most *n+1*. A span of zero lines is dropped, not recorded.
   **An anchor line is not exempt**: where a region's start or end anchor shares its line with
   changed text — and `a13`'s tail sits on the same line as the floor region's end anchor — the
   span begins or ends past it, and the kept condition on that line goes to the per-condition list.
4. **Then assign every kept condition in that region to exactly one span, or to the per-condition
   list.** A kept condition in neither is the failure this step exists to prevent; one in both is
   an accounting error.

**Expect the per-condition list to be non-empty, and do not treat its members as a list to
memorise.** `a1` and `a2` sit inside item 8a's block; `a13` ends on the line `a14` begins; `h5`
shares its line with `h6`; `h4` and `h5` are adjacent. Each is a reason a whole-line span cannot do
this alone, which is why the derivation replaces the enumeration rather than correcting it again.

**`.context/loop-rule-untouched` holds two record shapes, and both are parseable**, because Tasks 2
and 14 consume them without a human in between. A file whose second half has no schema is a file
its consumers skip, which is what the per-condition list exists to prevent:

```
base<TAB><the 40-character object name this map was built from>
span<TAB><start anchor><TAB><end anchor><TAB><file>
cond<TAB><condition id><TAB><fragment><TAB><file><TAB><expected parent><TAB><expected worktree>
```

Tab-separated, one record per line, the leading keyword distinguishing them. **The `base` line is
first and there is exactly one**, so a re-entry can tell this run's map from an abandoned run's. A kept condition's
expected pair is `1<TAB>1`; the shape carries the values rather than assuming them, so a moved or
dropped condition recorded here later needs no new format. **Both consumers validate every `cond`
row**, not only the `span` rows.

**Record the spans as one `span<TAB>start<TAB>end<TAB>file` line each in `.context/loop-rule-untouched`**, the
anchors being literal strings. Tab-separated because the anchors contain colons — a `:` delimiter
splits `**Severity:**:**Tool routing:` at the wrong colon and yields an empty end anchor.

**A line-span check cannot isolate every kept condition, and two of them prove it.** `a14` begins on
the same `CLAUDE.md` line as text `a13` changes, and `h6` shares a line with a changed neighbour; no
whole-line span contains one without the other. **For any kept condition that shares a line with a
changed one, check it by its own fragment instead** — count the condition's text before and after,
expecting `1` both times — and record which conditions are checked that way. **The span list is
therefore spans plus a short per-condition list**, and the two together must cover every kept
condition.

**A single-line site cannot be expressed as `sed -n "/x/,/x/p"`.** `sed` does not test the end
address on the line that matched the start, so the range runs to the next match or to end of file.
**Give a single-line site a `grep -n` check rather than a `sed` range** — the squash-carry sentence
(`j1`–`j4`) is the one site of this shape.

- [ ] **Step 3: Confirm the parity baseline of the inventoried ranges**

**Diff every inventoried and changed site, not one early window, and read the whole output.**
The first draft compared C 65–290 with W 264–489 and piped it through `head -40`. That window holds
none of passages (g), (h) or (j) — so `g4`, which sits at C 815 / W 997, could not appear in a diff
whose expected list named it — and the truncation hid about fifty of the roughly ninety lines the
comparison actually emits.

```bash
# Tab-separated start and end anchors: the anchors contain colons, so a
# colon delimiter splits '**Severity:**' at the wrong place and yields an
# empty end. Every entry here spans two DIFFERENT anchors — the single-line
# squash-carry site is handled below, not in this loop.
printf '%b\n' \
 'Both gates are a LOOP\tNothing here writes the floor knob' \
 'What a loop absorbs\tRecognizing "clearly stuck"' \
 'Recognizing "clearly stuck"\tEvery pass report states' \
 'From pass 4 onward\tThose three lines expose' \
 'Those three lines expose\tThe two rules above' \
 'The two rules above\tFindings go to a FILE' \
 '\*\*Severity:\*\*\t\*\*Tool routing:' \
 'Recording a human exception\tbecause writing it down makes it sound' \
 'When these rules bind\tDownstream has no shipping commit' \
 > .context/loop-rule-sites
while IFS=$(printf '\t') read -r s e; do
  echo "== $s"
  diff <(sed -n "/$s/,/$e/p" CLAUDE.md) \
       <(sed -n "/$s/,/$e/p" plugins/dev-workflow/commands/workflow-init.md)
done < .context/loop-rule-sites | tee .context/loop-rule-baseline-diff.txt

# The squash-carry sentence is ONE line and must not go through the loop.
echo "== On squash-merge" | tee -a .context/loop-rule-baseline-diff.txt
diff <(grep -F 'On squash-merge, copy every evidence entry' CLAUDE.md) \
     <(grep -F 'On squash-merge, copy every evidence entry' plugins/dev-workflow/commands/workflow-init.md) \
  | tee -a .context/loop-rule-baseline-diff.txt
```

**The squash-carry site is extracted with `grep`, not as a range**, for the reason step 2 already
gives: `sed` does not test the end address on the line that matched the start, so
`sed -n "/x/,/x/p"` on a site occurring once runs **to end of file**. An earlier draft put it in
the loop with its own anchor at both ends and a comment claiming `sed` returns that one line — the
diff would then have carried the whole unequal tail of both files and no correct implementation
could have produced the expected divergence list.

Expected: the deliberate divergences the inventory records — `b3`'s cross-reference target, passage
(b)'s intensifier and field-mint parenthetical, `e8`'s pronoun, `e11`, `f5`–`f7`'s framing, and
`g4`. **Read every line of the output; do not truncate it.** Anything else is pre-existing drift —
record it in the file and raise it before editing, because Task 14's parity diff cannot tell drift
you introduced from drift you inherited.

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

- [ ] **Step 4: Run a presence count per paragraph, in both copies and both trees**

**Three counts, not one.** A single count on §A1's opening lets §A2 or §A3 be omitted from both
copies while every count and the parity diff still pass — the paragraphs are installed together and
nothing else observes them.

*(Count each fragment in both copies and both trees, per the verification procedure; expect worktree 1, parent 0.)*

Expected: `worktree=1 parent=0` for all six. **Record the three chosen fragments with their counts
in this task's evidence**, each with the check that verified it single-line and unique — **not in
the fragment table**, which holds OLD fragments only. §A has no OLD half at all: row P1 says so,
and these three exist only once this task installs them.

- [ ] **Step 5: Check parity of the installed block**

```bash
diff <(sed -n '/^\*\*How a cycle ends/,/^\*\*What a loop absorbs/p' CLAUDE.md) \
     <(sed -n '/^\*\*How a cycle ends/,/^\*\*What a loop absorbs/p' plugins/dev-workflow/commands/workflow-init.md)
```

Expected: no output.

- [ ] **Step 6: Commit**

```bash
git add CLAUDE.md plugins/dev-workflow/commands/workflow-init.md \
        docs/superpowers/plans/2026-09-14-loop-rule-consolidation.md
git commit -m "WIP: install the closure ordering into both §5 copies"
```

**The plan is staged here because this task writes its fragment evidence into the plan.** Every
task that records a fragment — an appended OLD row, or a chosen NEW fragment with its counts —
stages the plan with its own edit; otherwise the reviewed fragment evidence stays dirty and is
swept into a later, unrelated commit, and the task commits are not the independently reviewable
units this plan claims they are. The same applies to Tasks 3, 4, 6, 7 and 8.

Named `WIP:` because Task 15 runs Gate B over the whole change and closes it with **one
`git reset --soft "$BASE"` and a single commit**, per the Global Constraints and Task 15 step 8 —
not with an amend, which is the Mechanics shape for a cycle carrying one snapshot and this plan
makes one per task. A non-`WIP` commit here would reset the hook's Gate-B counters mid-cycle.

---

## Task 2: Verify the untouched passages are still untouched

**Files:** none modified.

**Interfaces:**
- Consumes: Task 0's recorded anchor spans and per-condition fragment list, and `$BASE`.

This task exists because `f1` and the (d)/(j) dispositions are falsifiable only by a diff, and the cheapest moment to catch an accidental edit is immediately after the insertion that could have caused one.

- [ ] **Step 1: Diff each untouched passage against the parent**

Read `.context/loop-rule-untouched`, and for each recorded span **resolve its start and end anchors
separately in each tree** — Task 1 inserts a large block, so a line number taken from one tree
addresses different text in the other. For each span, extract it from `$BASE:<file>` and from the
worktree file and diff the two.

Expected: no output for every recorded span. Any difference is a defect — revert that hunk before
continuing.

**Then run Task 0's per-condition list, which is the other half of the same artifact.** Task 0
records spans **plus** a per-condition fragment for every kept condition no span could hold, and
the two together are what covers the kept set — a step reading only the spans leaves exactly the
conditions that needed individual attention unchecked, which is the shape of the defect the list
exists for. For each entry count the condition's own text in the parent and in the worktree,
expecting `1` both times. **Task 14 step 4b runs both lists again after the last text edit**;
this run catches what Task 1's insertion could have broken, at the cheapest moment.

- [ ] **Step 2: Confirm `f1` still names the right pair**

Read the installed text around "The two rules above do not compete" and confirm the two rules immediately above it are still the absorb rule and the clearly-stuck reading, with §A before both rather than between them.

- [ ] **Step 3: No commit** — this task verifies, it does not change.

---

## Task 3: Replace passage (b) with §B in both copies

**Files:**
- Modify: `CLAUDE.md` — the passage beginning `**What a loop absorbs, and what stops it`
- Modify: `plugins/dev-workflow/commands/workflow-init.md` — the same

**The bytes:** target §B, which states it is "the only place this file states anything about" passage (b).

**`b3` is aligned here, not in Task 14.** Design §6 decides it explicitly: W's pointer names "the
severity rule" on the inventory's reasoning that W has no Mechanics section, **which is false**, so
**W takes C's wording**. Installing W's old wording here and repairing it two tasks later would have
this task knowingly install text contrary to the approved target, and would make Task 14 repair a
defect this task introduced.

**One divergence is preserved:** the field-mint parenthetical closes the paragraph in C and is
absent from W. §B says it stops short of that parenthetical, which is left exactly as each copy has
it.

- [ ] **Step 1: Confirm the two OLD fragments still count 1**

Rows **P2** (`b7`, the fix-set definition) and **P3** (`b12`, immediate resumption) of the fragment
table. Both are verified single-line and unique; re-confirm before editing, since earlier tasks
have touched these files:

*(Count each named OLD fragment in the copies its row claims, per the verification procedure; expect 1 in each.)*

Expected: `P2=1 P3=1` for **both** files — the first draft ran these against C only while claiming a result for both.

**The first draft of this plan named `plus repair obligations you already accepted in earlier
passes` here, which wraps across C 201–202 and W 408–409 and counts zero in a correct file.**

- [ ] **Step 1b: Run the pre-install half of the disposition procedure over passage (b)**

**Two pairs do not cover §B.** §B replaces the passage whole, so **every** condition in it owes an
observation — the changed ones a pair, the nine carried ones a preservation count, the added rule a
presence check — and **no untouched span protects anything here**, because none survives a
whole-passage replacement. Derive every pre-existing fragment now, per
`## How a task discharges that table`.

**A manual condition walk is not the discriminating observation design §7 assigns here**, and §B's
nine carried conditions are the easiest ones to lose to it: a mis-scoped replacement drops carried
wording from both copies while every pair, the presence check and the parity diff pass.

- [ ] **Step 2: Install §B's text over the passage in both copies**

Replace from `**What a loop absorbs, and what stops it` through the sentence §B ends at, keeping each copy's own closing parenthetical.

- [ ] **Step 3: Run two discriminating pairs, both copies, both trees**

`b7` and `b12` are separate meaning changes and each owes its own pair; one pair covering both
would let the surviving instruction pass behind the repaired one.

*(Build the pair per the verification procedure; record the four values.)*

**`P3_NEW` is the §B resumption sentence's fragment**, chosen after installing and verified the
three ways before this step counts with it.

Expected for all four: `old/worktree=0 old/parent=1 new/worktree=1 new/parent=0`.

**Run a pair for every *replaced* row step 1b derived** — and only those. §B's carried rows are in
that set too and they owe `parent=1 worktree=1`, not a pair; step 4 runs them. A blanket "a pair
for every row" cannot be satisfied by a correct §B installation, because carried wording has to
still be there.

Plus a **presence check** for §B's one added rule — the closing-time set-change rule — which
replaces no wording and so owes `new/worktree=1 new/parent=0` and no OLD half, per the add-only
rule. Choose each NEW fragment from the installed text and verify it the three ways before counting
it.

- [ ] **Step 4: Run the post-install half, then walk the passage**

Every row step 1b appended, to the result its class owes; then read the installed passage and
confirm each condition reads as §B states rather than as the parent did. **The disposition table is
the checklist and the walk is the reader's confirmation on top of the counts.**

- [ ] **Step 5: Parity**

```bash
diff <(sed -n '/^\*\*What a loop absorbs/,/^\*\*Recognizing "clearly stuck"/p' CLAUDE.md) \
     <(sed -n '/^\*\*What a loop absorbs/,/^\*\*Recognizing "clearly stuck"/p' plugins/dev-workflow/commands/workflow-init.md)
```

Expected: **only C's field-mint parenthetical.** Task 3 installs §B's common span, which aligns
`b3`, the intensifier and the closing rationale — so expecting "three recorded divergences" would
make a correct implementation look like a failure and would let stale W wording that §B removes pass
as inherited drift. **Any difference other than the parenthetical is a failure of this task.**

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

*(Count each named OLD fragment in the copies its row claims, per the verification procedure; expect 1 in each.)*

Expected: `P4=1` for both files.

**`So this exit needs three things` is not usable and is not a row:** it occurs once in each copy but
is **preserved in target §C's fenced replacement**, so its old-count could never reach zero. Derive
`c4`'s OLD from the part of the sentence the replacement removes.

**Run the pre-install half of the disposition procedure over the block this task replaces** — the
clearly-stuck block, **ending before the Surfacing paragraph**, which is Task 7's
`c18`-and-surfacing block and whose conditions Task 7 derives. Passage (c) is edited by two tasks;
walking the whole passage here makes this task append rows it cannot discharge after its own
install, and makes both tasks append a row for the same condition. Derive each from the live text
now and append it under the next free `P` id, referring to the rows afterwards by the condition
they observe, never by a number picked here: Task 3 appends first and how many rows it adds is
decided at execution.

**Two things about passage (c) that the class alone does not tell you:**

- **`c1`–`c3` are kept and no untouched span reaches them.** Task 0's five regions do not include
  passage (c), and §C replaces text inside it, so the curve-reading premises owe **per-condition
  preservation counts** — `parent=1 worktree=1` in each copy — like a carried condition. Without
  them an accidental edit to the curve or coverage sentences survives every mechanical check here.
- **`c9` and the plateau rationale are two subjects, not one condition with two halves.** `c9` is
  the precedence clause and is **moved** — absence here, condition-specific presence in §A. The
  plateau rationale carries no inventory id, **stays**, and owes a **preservation count** recorded
  under its own name. One row cannot observe both, because one must vanish and the other must not.
  The rationale's sentence wraps in both copies, so its fragment has to be chosen single-line
  **before** step 2 rather than picked out of the installed text afterwards.

- [ ] **Step 2: Install §C's block**

- [ ] **Step 3: Confirm the moved clause exists in §A and nowhere else**

```bash
grep -cF 'takes precedence over this exit' CLAUDE.md
grep -n 'takes precedence over this exit' CLAUDE.md
```

Expected: **exactly `1`**, and the hit inside the installed ordering. A second occurrence in
passage (c) means the sentence was moved whole instead of split.

**The once-only assertion is on the precedence clause, not on `clean completion`.** An earlier
draft counted the bare phrase with no stated expectation; target §A1 uses it four times, so a
correct install produces a multi-hit count with nothing to compare it against — a check whose
result a reader can only shrug at.

- [ ] **Step 4: Run the discriminating pair, both copies, both trees**

**Three pairs, one per edit, and each pair's two halves come from the same edit.** An earlier draft
ran a single pair taking its OLD from `c14` and its NEW from `c8` — two different changes — so
either could land while the other survived and it still reported a pass, and `c4` had no
observation at all. **A later draft reintroduced exactly that pair** by naming row P4, whose OLD is
`c14`, and then taking its NEW from §C's re-raised-dismissal clause, which is `c8`.

| Edit | OLD | NEW, taken from the installed §C block |
|---|---|---|
| `c4`, the widened third condition | the `c4` row (step 1) | the clause §C puts in place of "a missing one means keep going" |
| `c8`, the re-raised dismissal | the `c8` row (step 1) | `a recurrence failing them being an ordinary fresh finding` — **install that clause's line unwrapped** so the fragment sits wholly on one line |
| `c14`, the below-floor Minor — **suspend** | row **P4** | the ordering's **suspension** outcome for a below-floor pass |
| `c14`, the below-floor Minor — **continue** | *(none — add-only)* | the ordering's **continuation** outcome where no suspension applies — presence alone, `worktree=1 parent=0` |

Each NEW is confirmed single-line and unique in the installed file before it is counted.

**`c14` is replaced by two noncontiguous outcomes and owes two observations.** The old sentence
stated one unconditional continuation; the ordering splits it into a **suspension** where one
applies and a **continuation** where none does, and they do not sit together. One NEW fragment
observes one of them, so the other can be omitted while the pair, the three §A paragraph samples
and the parity diff all pass. P4's absence pairs with the suspension clause; the continuation
clause is add-only at its destination and owes presence.

**Plus both halves of every move — `c10`, `c11`, `c12`, `c13`, and `c9`'s moved clause.** A move
removes wording here and adds it in §A, so it owes an **absence** at this source, `parent=1
worktree=0`, **and a condition-specific presence in the installed §A**, `worktree=1 parent=0`.
**Task 1's three paragraph-level presence fragments are not that second half** — they pass while
any one moved predicate is missing from §A, so a predicate could vanish here and never arrive
there with every check green. Derive one §A fragment per moved condition and record it with the
absence.

**A reader walk is neither half** — without the counts an old closure instruction can survive in
passage (c) beside its §A replacement, and every pair and parity diff still passes. This is the
two-instructions-that-disagree failure, and `c10`–`c13` are four chances at it.

- [ ] **Step 4b: Run every remaining row step 1 appended**

The carried `c5`–`c7`, the kept `c1`–`c3`, and `c9`'s plateau rationale — each to the result its
class owes. **None of them is observed by a pair**, which is why they are listed as a step rather
than left to the walk.

**The source sentence is split; `c9` is not.** `c9` is the precedence clause alone and is **moved**,
while the plateau rationale beside it carries no inventory id, **stays**, and is observed under its
own name. Calling `c9` "split" names a seventh disposition and invites an executor to attach the
staying rationale to a condition required to vanish. So: the moved precedence clause is absent here
(`parent=1 worktree=0`) and present in §A, while the plateau rationale stays — confirm the
rationale still counts `1` in each copy.

*(Build each pair per the verification procedure; record the four values.)*

Expected: for the three pairs, six pair instances reading
`old/worktree=0 old/parent=1 new/worktree=1 new/parent=0`; for the five absence checks,
`parent=1 worktree=0` in each copy. **Every OLD row was derived and validated at step 1**; this
step only runs them.

- [ ] **Step 5: Walk the conditions** — `c1`–`c3` present unchanged, `c5`–`c7` word for word, `c8` carrying the new clause, `c9` moved out and the plateau rationale still here, `c10`–`c14` gone from here. **This is a reader's confirmation on top of step 4's counts, not the observation for any of them** — `c9`–`c14` are each counted there, and a walk that found what the counts missed would mean a fragment was wrong rather than that the walk was the check.

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

**`e8` does not survive this change.** §D supplies the complete replacement sentence, which reads
`you report the tells`, and the Global Constraints make every replaced section byte-identical across
the copies. **Install §D's sentence as written in both copies** — W gains the pronoun — and remove
`e8` from the surviving-divergence list Task 14 carries. Keeping W's old pronoun would mean
knowingly installing text the approved target does not say, and would leave Task 14 classifying as
deliberate a divergence this task chose to create.

**`e11`, the C-only rationale paragraph, is untouched and stays C-only.**

- [ ] **Step 1: Confirm the per-copy OLD fragments**

`Any two present makes stop-and-surface mandatory, not discretionary` **survives inside the
replacement**, so it can never be the old half — that is the trap design §7 records from four spec
revisions. Rows **P5** (C) and **P5w** (W) instead, and they differ because W drops the pronoun:

*(Count each named OLD fragment in the copies its row claims, per the verification procedure; expect 1 in each.)*

Expected: `1` each.

**Two earlier drafts got this row wrong in two different ways**, which is why the step names ids and
not text. The first fragment wrapped across C 267–268 and W 471–472; the second was **preserved in
target §D's replacement** and could never reach zero. `P5_OLD` and `P5w_OLD` take the clause §D
actually removes.

**Then run the pre-install half of the disposition procedure over passage (e)**, which P5 and P5w
do not cover:

- **`e9` is carried** and its sentence **wraps** in both copies — C 267–268, W 471–472 — so a
  literal count of the whole clause returns zero in a *correct* source file. Choose a single-line
  fragment of it now, verify uniqueness, and append it; choosing one from the installed text
  afterwards is the pre-edit rule broken in the one place the wrap makes it tempting.
- **`e1`–`e6`, `e10` and `e11` are kept, and no untouched span reaches them.** Passage (e) is not
  one of Task 0's five regions and §D edits inside it, so each owes a **per-condition preservation
  count**, `parent=1 worktree=1` — **`e11` in C only**, which is its recorded divergence. Without
  them §D's edit can alter or drop a tell, the long-before-plateau sentence or the C-only
  rationale while the `e7` pair and the pointer check both pass.

- [ ] **Step 2: Install §D's `e7` sentence and the pointer paragraph**

- [ ] **Step 3: Run the discriminating pair, and a presence check for the pointer**

The `e7` replacement and §D's added pointer paragraph are two separate observations. **The pointer
is add-only** — it replaces no wording — so it is checked by presence alone, and without that check
it can be omitted from both copies while the `e7` pair, the condition walk and the parity diff all
pass.

**`e7` and `e8` are two dispositions but they cannot have two OLD halves, and saying why is the
point.** §D supplies **one** sentence for both copies, so in W there is no state where the
read-after clause arrives and the pronoun does not: the two changes install or fail together, and
any fragment that vanishes for one vanishes for the other. **A second OLD row would be a
counterfactual that cannot fail independently** — the thing this plan rejects everywhere else.

**So the discrimination lives in the NEW halves, and there are three of them:**

| Observation | Copy | Shape | Fragment |
|---|---|---|---|
| `e7` pair | C | pair, OLD = **P5** | NEW from the **read-after-clean-completion clause** |
| `e7` pair | W | pair, OLD = **P5w** | NEW from the same clause |
| `e8` alignment | W only | **presence**, `worktree=1 parent=0` | the installed `you report the tells` |

**Two pair instances and one presence check, not two pairs and a spare.** An earlier draft gave
both pairs a NEW taken from `you report the tells`, which observes the pronoun and says nothing
about `e7`: those words are already in C, and there they become "new" only because the line
reflows. A later draft asked `e8` for its own OLD, which P5w already is. **`e8`'s presence check is
what shows W received C's form rather than some third wording**, and without it the alignment rests
on Task 14's parity judgement instead of on a count.

*(Build the pair per the verification procedure; record the four values.)*

Expected: both pairs `old/worktree=0 old/parent=1 new/worktree=1 new/parent=0`; both pointer checks
`worktree=1 parent=0`.

- [ ] **Step 4: Walk the conditions by their three different dispositions**

They are not one class and the check differs per class:

Run every row step 1 appended, to the result its class owes, then read the passage. Three things
the class alone does not tell you:

- **`e10` is kept and belongs with `e1`–`e6`, not with `e9`** — it is the sentence *after* §D's
  block, so a check treating it as carried would look for it inside text it never enters.
- **`e9` is carried** — its count is `1` in each copy after the install, from the single-line
  fragment step 1 appended rather than from the whole wrapped clause.
- **`e8` is aligned rather than untouched** — this task gives W the pronoun, so listing `e8` among
  the untouched conditions would contradict the task's own instruction.

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

- [ ] **Step 1: Record the old wording in both copies, and derive the resolve-duty OLD**

§E replaces **two** blocks and **drops three conditions**. The handed-over-question OLD is row P6;
four fragments have no row yet. **Derive all four here, before Step 2 installs over them**, check
each the three ways, confirm each counts 1 in the copies its row claims, and append each to the
fragment table:

- the **resolve-duty OLD**, from the live `**Severity:**` bullet;
- **`g2`'s own absence fragment**, from the interim report-and-stop duty;
- **`g3`'s own absence fragment**, from that duty's justification;
- **`g4`'s absence fragment (C only)**, from the sentence naming the story path.

**One fragment per dropped condition, not one for `g2` and `g3` together.** A combined fragment
goes absent as soon as *either* half is removed, which leaves the other obsolete instruction free
to survive behind a passing check — and the whole point of these three is that an obsolete stop
duty must not outlive the answer that settles it. **`g4` owes a recorded absence check too**, not
only step 4's path grep: Task 15's evidence entry names every absence check with its two counts,
and a bare `grep -c` on the current tree supplies neither the parent count nor an auditable row.

**Not "before Step 3":** Step 2 is the install, so a fragment derived after it is taken from text
the edit has already removed.

```bash
for f in CLAUDE.md plugins/dev-workflow/commands/workflow-init.md; do
  printf '%s g1/g2: %s  g4: %s\n' "$f" \
    "$(grep -cF 'is not settled here, and this change does not settle it' "$f")" \
    "$(grep -cF '2026-08-29-loop-rule-consolidation-story.md' "$f")"
done
```

Expected: C `g1/g2: 1  g4: 1`; W `g1/g2: 1  g4: 0`.

- [ ] **Step 2: Install §E's resolve-duty bullet and its answer paragraph in both copies**

- [ ] **Step 3: Run two discriminating pairs, both copies, both trees**

**§E has two fenced replacements and each owes its own pair.** With only the handed-over-question
pair, the old unscoped resolve duty can survive, or the new repair-versus-dismissal distinction be
omitted, while everything Task 6 checks passes.

*(Build the pair per the verification procedure; record the four values.)*

**Five observations here, not two.** `P6` observes `g1`'s replacement and the resolve-duty row
observes the bullet, but **`g2`, `g3` and `g4` are dropped rather than replaced** — the interim
report-and-stop duty, its rationale and the ownership sentence go, and nothing in §E takes their
place. A dropped condition owes an **absence check**, not a pair: count its text before and after,
expecting `1` then `0`. Without it the duty can survive beside the answer that makes it obsolete,
which is the two-instructions-that-disagree failure in its purest form. **All four fragments were
derived and validated at Step 1**; this step only runs them.

Expected: for the two pairs, four pair instances reading
`old/worktree=0 old/parent=1 new/worktree=1 new/parent=0`; for `g2`'s and `g3`'s absence checks,
`worktree=0 parent=1` in **each** copy; for `g4`'s, `worktree=0 parent=1` in **C only** — W never
carried it, which is the divergence this task removes.

- [ ] **Step 4: Confirm g4 is gone from C**

```bash
grep -c '2026-08-29-loop-rule-consolidation-story.md' CLAUDE.md
```

Expected: `0`. The story path may still appear in `docs/` — this check is scoped to `CLAUDE.md`.

- [ ] **Step 5: Parity over both §E blocks**

**The bullet and the answer paragraph are two installs and the diff must cover both** — scoping the
check to the Severity bullet alone lets the long answer paragraph differ between the copies while
the pair and the stated parity check pass.

```bash
diff <(sed -n '/^- \*\*Severity:\*\*/,/^- \*\*Tool routing:/p' CLAUDE.md) \
     <(sed -n '/^- \*\*Severity:\*\*/,/^- \*\*Tool routing:/p' plugins/dev-workflow/commands/workflow-init.md)
```

Expected: no output. This passage should now be byte-identical, `g4` having been removed and `g2`/`g3` having gone from both copies.

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

- [ ] **Step 1: Locate all ten sites in both copies**

**Ten sites: one §G block and nine §H blocks.** Every locator below is a fragment-table row, so each
is verified single-line and unique. The first draft used five locators that count zero in a correct
file — `These rules and records are one contract` (the live text says `These records are one
contract`), `Your final pass must be clean` (wraps C 132–133), ``a literal `NO FINDINGS` when a pass
is clean`` (one line in C, wraps in W), `A clean pass is the single body line` (the line break falls
after `A`), and `at minimum floor 3, severity classified without the demotion` (wraps C 155–156).

*(Count each named OLD fragment in the copies its row claims, per the verification procedure; expect 1 in each.)*

Expected: `1` twenty times. **Any `0` means the wording drifted since this table was verified at
`5871d0a`** — re-derive that fragment and update the table before installing anything.

- [ ] **Step 1b: Derive the rows the ten locators do not cover, still before installing**

**Run the pre-install half of the disposition procedure over this task's ten blocks** — every
condition *they* touch or reproduce, by its class, derived from the **live** text now and appended
to the fragment table. **Their boundaries are the bound**: passage (c) is shared with Task 4, which
owns the clearly-stuck block and stops before the Surfacing paragraph this task's `c18` block
begins at, and passage (a) is shared with Task 8, which owns item 8a's block. **Step 2 installs over all of it**, so a derivation
afterwards has no live wording left to check against — and that includes the **preservation
fragments for the nine carried conditions** `a15`, `a21`, `a22`, `c15` and `i4`–`i8`, which an
earlier draft chose from the installed text at step 4.

**`a13` is two sentences and row P9 sits in the second.** §H replaces the whole condition with one
sentence, so the first — `This replaces the pass-count number and nothing else.` — owes an
**absence** fragment of its own, `parent=1 worktree=0` in both copies. Derive it here, from the
live text, and install over the whole condition rather than over the sentence P9 names.

**Passage (i)'s kept conditions need attention the class alone does not flag.** `i1`–`i3` and
`i9`–`i16` are kept, no untouched span reaches them — passage (i) is not one of Task 0's five
regions — and `i3` shares its sentence with the dash-delimited list this task replaces. Each owes a
per-condition preservation count, `parent=1 worktree=1`.

**One pair per block is a sample, not coverage.** The blocks below each change more than one thing
and are named with what they owe; the rest are covered by one pair each. **No count is stated** —
the arithmetic here was wrong three times, most recently by omitting the `a13` block the paragraph
above had just added to the list. Take the set from the bullets, not from a number:

- **The `c18`-and-surfacing block** changes `c16`, `c17`, `c19` and `c20` besides the `c18` clause
  row P8 observes — **one OLD row per condition**, four in total.
- **The `a17`–`a22` block moves four conditions — `a17` included.** P11 pairs the old
  clean-final-pass rule with §H's *pointer*, which is a different sentence from the predicate that
  moved; so **all four of `a17`, `a18`, `a19`, `a20` owe the moved pair**: an *absence* at this
  source, `parent=1 worktree=0`, **and a condition-specific presence in the installed §A**,
  `worktree=1 parent=0`. Task 1's three paragraph-level fragments are not that second half.
  **Observe §H's pointer separately** — P11's NEW is about the pointer arriving, not about the
  predicate leaving. Without all of this the old loop-until-clean, zero-finding and no-padding
  instructions can survive beside the ordering that replaces them while every pair and every
  carried-condition count still passes.
- **§G changes two things, not one**: its membership is widened *and* it gains a semantic
  membership test a downstream reader can apply, and target §G's own closing note names the test
  as the point of the replacement. P7 observes the widened clause; **the test owes a second
  observation**. It is **add-only** — the parent paragraph carries no membership test for it to
  replace — so it owes presence alone, not a pair.
- **The strict-reading list** replaces the dash-delimited run, which P16 observes as one pair for
  the whole run's boundary. Its **tail additions have no predecessor**: each added clause is
  add-only and owes **presence alone**, `new/worktree=1 new/parent=0`, with no OLD half. **Do not
  derive an OLD row per tail addition** — there is no removed wording for one to count, so the
  executor would have to pair the clause with unrelated text and the observation would prove
  nothing about the clause. One presence check per independent added clause.

**Every block not named above changes one thing and one pair covers it.**

**One classification note, decided against the real file rather than asserted.** The gate-prompt
template's clean sentence **replaces** `A clean pass is the single body line …`, which is why P13
has an OLD at all; it is not add-only.

- [ ] **Step 2: Install the §G block and all nine §H blocks — ten sites — one at a time, verifying each before moving to the next**

- [ ] **Step 3: Run one discriminating pair per block**, both copies, both trees, one per row P7–P16.

`NEW` for each is taken from the installed block; **check each chosen fragment is single-line and
unique in the installed file before counting it**, and record it with its four counts in this
task's evidence — **not in the fragment table**, which holds OLD fragments only, for the reason
stated below the table. The suggested source sentence per block:

| Row | Block | NEW taken from |
|---|---|---|
| P7 | §G one-contract | the widened-membership clause of §G's block |
| P8 | `c18`/surfacing | `A pass is credited clean or not on its own findings` |
| P9 | `a13` | `Every other rule stated **in this paragraph**` |
| P10 | `a16` | `resolve Blocker/Major after each as` |
| P11 | `a17`–`a22` | `What a clean final pass and the zero-finding early exit mean for closing` |
| P12 | Gate-A clean signal | `and no scope-stop trigger** is clean too` |
| P13 | template clean sentence | `A **clean findings file** is the single body line` |
| P14 | Gate-A cadence | `revise **where a repair is required**` |
| P15 | lens unchanged-list | `**the lens sets** leave every other` |
| P16 | strict-reading list | `every suspension binding, since` |

*(Build the pair per the verification procedure; record the four values.)*

**`<ID>_NEW` is set by the executor after installing that block and verifying the chosen fragment
the same three ways** before it is counted with. A NEW fragment is not added to the table: the table
holds OLD fragments, which exist before the edit and can be checked in advance.

Expected for all twenty: `old/worktree=0 old/parent=1 new/worktree=1 new/parent=0`.

**Then run everything step 1b added, and that is three kinds, not one:**

- **a pair** for each of the `c18`-and-surfacing block's four further conditions — `c16`, `c17`,
  `c19`, `c20`;
- **an absence at this source plus a condition-specific presence in §A** for each of the four
  moved conditions `a17`, `a18`, `a19` and `a20` — `parent=1 worktree=0` here, `worktree=1
  parent=0` there. **An earlier draft derived these rows at step 1b and then never ran them**, so
  the old clean-final-pass, loop-until-clean, zero-finding and no-padding instructions could each
  survive at their source with nothing observing it;
- **a preservation count** of `1` in each copy for each of the nine carried conditions and each
  kept condition in passage (i), from the fragments step 1b appended;
- **a presence check** — `new/worktree=1 new/parent=0` in each copy — for §G's semantic membership
  test and for every independent add-only clause in the strict-reading tail.

Choose each post-install fragment from the installed text, verify it the three ways before counting
it, and record all of them in this task's fragment evidence.

- [ ] **Step 4: Confirm every carried condition in this task's blocks survived**

They are reproduced inside blocks that install contiguously, so a mis-scoped replacement silently
drops them — and because they are carried rather than kept, **no untouched-range span covers
them**, which is exactly why the disposition records them as carried. **Each owes a count of its
own text in each copy, expecting `1`.**

The set is **`a15`, `a21`, `a22`, `c15`, and each of `i4`–`i8`** — nine conditions, not three. An
earlier draft checked three and left the rest to P8 and P16, which observe the *changed* clauses
around them and prove nothing about the reproduced words: both copies could omit the surfacing
premise, or any interior item of the strict-reading run, and every pair, presence check and parity
comparison would still pass.

**All nine fragments were derived and appended at step 1b**, from the live text before step 2
installed over it. Two of them, for orientation:

```bash
grep -cF 'Codex is advisory — validate before applying; dismissed finding → one-line why' CLAUDE.md
grep -cF 'Open a TodoWrite' CLAUDE.md
```

Expected: `1` each, and `1` in each copy for every one of the nine.

- [ ] **Step 5: Parity** for all ten sites, each extracted by its own bounded region rather than a fixed line window.

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

**`h4`, `h5` and `h19` are the human-exception conditions these items discharge** — item 7 is both destinations, `h4`'s and `h5`'s, item 4 the scope sentence.

- [ ] **Step 1: Re-derive every item's real location**

For each item, take the quoted live sentence from §F and find it, rather than trusting the cited line:

```bash
grep -n -F '<the live sentence §F quotes>' CLAUDE.md plugins/dev-workflow/commands/workflow-init.md
```

**Where a quoted sentence wraps across lines in the file, `grep -F` on the whole sentence returns nothing.** Search a single-line fragment of it instead and confirm by reading. Record which items wrap — Task 14's parity diff needs it.

**Then confirm all fifteen of this task's fragment rows still count `1` in each copy** — `F1`–`F14`
plus `F7b`. **Here, not at step 3:** step 2 installs over every one of them, and after that the
pre-edit count of 1 can no longer be observed at all. A row that no longer counts 1 has drifted
since the table was verified — repair the row against the live line and update the table before
installing anything.

**And derive `a1`'s preservation fragment here too.** `a1` is **carried** inside item 8a's block,
which reproduces it — so it is pre-existing text and the fragment-table cut puts it in the table,
before the install, like every other pre-existing fragment. An earlier draft chose it at step 4,
after item 8a had already replaced the block: at that point a drifted or half-installed HARD FLOOR
opening cannot be told from the intended carried text, and no authored fragment exists for Task 15
to audit.

- [ ] **Step 2: Install all fourteen replacements**

- [ ] **Step 3: Run the fifteen pairs the table already holds**

**Do not rebuild these rows.** The fragment table carries them already — `F1`–`F14` **plus `F7b`**
— each derived from its item's cited line and checked the three ways, and step 1 re-confirmed each
against the live file. Rebuilding them either duplicates authored rows or quietly re-derives one
differently, and the second-copy defect is what that produces. **Consume the rows; do not author
new ones here.**

**Fifteen rows for fourteen items, because item 7 changes two clauses on two different lines** —
`h4`'s Gate-A destination at row F7 and `h5`'s Gate-B destination at row F7b. One fragment cannot
observe both, and running fourteen pairs would let `restated by the closing amend` survive while
every stated count still passed.

*(Build the pair per the verification procedure; record the four values.)*

Expected for all thirty pair instances — fifteen rows in each of the two copies:
`old/worktree=0 old/parent=1 new/worktree=1 new/parent=0`.

- [ ] **Step 4: Confirm `a1` survived, then count what was installed**

**`a1` is carried inside item 8a's block**, which opens with it — `**Both gates are a LOOP with a
HARD FLOOR: a minimum number of passes per run` — and reproduces it so one contiguous string
installs. Carried, not kept: **no untouched-range span covers it**, and row F10's pair observes
`a2`, the parenthetical, not the opening it sits in. **Count the fragment step 1 appended**, in
each copy, expecting `1`. Without it a mis-scoped item-8a replacement can drop the sentence's
opening and every other check in this task still passes.

Then total the fifteen `new/worktree` values step 3 printed, per copy.

Expected: `15` per copy — **fifteen independent changed clauses, from fourteen installed items**.
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

- [ ] **Step 3: Run both discriminating pairs**

Rows **P17** and **P18**. Assigning the variables is not running the check — the first draft stopped
at the assignment.

*(Build the pair per the verification procedure; record the four values.)*

Expected for all four: `old/worktree=0 old/parent=1 new/worktree=1 new/parent=0`.

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

- [ ] **Step 1: Verify the constraint before installing, reading each block as inert data**

**The probe must never put the candidate text inside double quotes.** A backtick or `$(` there is
executed by the probe itself, `$policy` expands away, and the check then certifies a string that is
not the one to be installed — the probe would run the hazard it exists to detect.

Read the blocks straight from the spec file instead, and test the literal characters:

```python
# python3 - <<'EOF'   (single-quoted heredoc: the shell expands nothing)
import re, pathlib
spec = pathlib.Path("docs/superpowers/specs/2026-09-10-loop-rule-consolidation-target-text.md").read_text()
sec  = spec[spec.index("## F."):spec.index("## G.")]
for i, block in enumerate(re.findall(r"```\n(.*?)\n```", sec, re.S), 1):
    bad = [c for c in ("`", "$(", "\\", '"') if c in block]
    print(i, "HAZARD" if bad else "clean", bad, block[:60])
# EOF
```

Expected: every block destined for the hook prints `clean`. **Blocks for the prompt copies may
legitimately contain backticks and quotes** — they are markdown, not shell arguments — so read the
block index against §F's item numbers rather than requiring all of them clean.

- [ ] **Step 2: Locate the seven `note` calls**

```bash
grep -n 'note "' plugins/dev-workflow/hooks/codex-gate.sh
```

Expected: thirteen hits. Seven are the gate reminders this task edits; four take a pre-built variable (`$FAILURE_CTX`, `$NORESULT_CTX`, `$BG_SHORT_CTX`, `$BG_LONG_CTX`), one is the tool-state echo, and one is the **docs-only notice, which is deliberately untouched** — it states no closure permission.

- [ ] **Step 2b: Derive the eight OLD fragments, before installing over them**

Step 5 runs eight pairs. **Their OLD halves come from the live `note` strings, so they are derived
here** — after step 3 the old wording is gone from the only file that carries it, and a fragment
reconstructed from the parent tree can no longer catch a drifted string or a half-applied re-run.
For each, take a single-line fragment from the located `note` call, confirm it counts **1** in
`codex-gate.sh`, and confirm it is **not preserved inside its own §F replacement**. **Then append
all eight to the fragment table** under the next free `P` ids, naming each by the item it observes.
The hook's live wording exists in one file and is gone after step 3; a fragment used and never
recorded cannot be re-derived and cannot be audited.

**Three of the eight need a second look while the file is open.** Item 11's removed text is the
**clean definition** at the end of the Gate-A satisfied message, not `floor met by COUNT ONLY`,
which the change leaves standing — an OLD half taken from unchanged text can never reach zero.
Item 10 removes **two separate sentences** of the Gate-A below-floor reminder — the honesty claim
and the tail `Run more passes before executing` — so it owes **two** fragments and two pairs.
Item 17 removes the skip-rule offer and `run more` as **one** clause, so one fragment covers it;
take that fragment from the skip-rule half, since `run more` alone also appears in item 10's tail.

**Take items 15's and 16's fragments from each message's own body, never from the `STOP` opening
they share.** A fragment from the shared opening counts 2 and cannot tell the two messages apart,
so a stale second message passes behind a repaired first one. The two messages differ throughout —
item 15 is the no-fingerprint reminder, item 16 the stale-fingerprint one — and each has wording
unique to it.

- [ ] **Step 3: Install the seven replacements, one at a time**

- [ ] **Step 4: Confirm no behaviour changed, by line number rather than by shape**

**A content filter cannot do this.** A pattern admitting "letters and allowed punctuation" admits
`else`, `fi` and `return` — a control-flow edit would pass the check it exists to fail. Compare the
**changed line numbers** against the seven `note` calls instead:

```bash
BASE=$(cat .context/loop-rule-base)
git diff -U0 "$BASE" -- plugins/dev-workflow/hooks/codex-gate.sh \
  | grep -E '^@@' | sed -E 's/^@@ -([0-9]+).*/\1/'
grep -n 'note "' plugins/dev-workflow/hooks/codex-gate.sh
```

**A hunk's start is not enough.** A changed `else`, `fi` or `return` adjacent to an edited `note`
line lands in the same zero-context hunk and inherits its permitted start. **Read every removed and
added line of every hunk** and confirm each one is inside one of the seven gate-reminder `note`
strings this task edits. A changed line anywhere else is a behaviour change and is out of scope —
no control flow, no counter, no fingerprint computation, no routing (invariant 4, design §8).

Read the diff yourself rather than filtering it. A pattern over line *shape* is what failed here the
first time — it admitted exactly the shell keywords it existed to catch.

- [ ] **Step 5: Discriminating pairs, worktree and parent**

The hook has one copy and owes no parity check; **the hook suite's exact-match assertion is this
edit's second observation** (design §7). Run a pair anyway, against
`plugins/dev-workflow/hooks/codex-gate.sh`, using the fragments step 2b derived — **seven items and
eight observations, because item 10 removes two things, so eight pairs.**

**Exact counts per pair, and every one of them is 1.** Each pair names one message, so a count of
2 anywhere means the fragment is not unique to the message it claims — a duplicated installation,
or a fragment taken from text two messages share. **An earlier draft grouped items 15 and 16 into
one pair reading `2`**, which cannot tell the two messages apart: a stale second message passes
behind a repaired first one, and the grouped `2` also removes the exactness from the row that was
supposed to carry it. Step 2b takes each fragment from its own message's body instead.

| Pair | old/worktree | old/parent | new/worktree | new/parent |
|---|---|---|---|---|
| item 10, the honesty claim | 0 | 1 | 1 | 0 |
| item 10, the `Run more passes before executing` tail | 0 | 1 | 1 | 0 |
| item 11, the Gate-A clean definition | 0 | 1 | 1 | 0 |
| item 12, the Gate-B clean definition | 0 | 1 | 1 | 0 |
| item 13, the WIP reminder | 0 | 1 | 1 | 0 |
| item 15, the no-fingerprint reminder | 0 | 1 | 1 | 0 |
| item 16, the stale-fingerprint reminder | 0 | 1 | 1 | 0 |
| item 17, the below-floor instruction | 0 | 1 | 1 | 0 |

- [ ] **Step 6: ShellCheck**

```bash
shellcheck --shell=sh plugins/dev-workflow/hooks/codex-gate.sh
```

Expected: exit 0, no output.

**The suite fails here, and that is a known red state between two commits.** Task 10 changes the
hook strings and Task 11 moves the expectations that pin them; a reviewer cannot accept Task 10 and
reject Task 11 without leaving the repo unable to pass its own battery. **They are therefore one
reviewable unit with two commits**, and neither is offered for independent acceptance — the plan's
task-independence claim does not extend to this pair, and saying so is cheaper than pretending to a
boundary that is not there. **Do not run the battery between them**; Task 11 step 4 is the first
point where green is expected.

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
grep -n 'Gate B satisfied\|Gate B not satisfied\|Gate A satisfied\|Gate A floor\|STOP\|no recorded review\|cannot confirm review\|only thing keeping\|no new Blocker/Major\|count only\|COUNT ONLY' plugins/dev-workflow/hooks/codex-gate.test.sh
grep -ni 'satisfied' plugins/dev-workflow/hooks/codex-gate.test.sh
```

**`Gate A` as well as `Gate B`.** An earlier draft searched only the Gate-B phrases while step 3
requires every label naming a gate verdict to move; the Gate-A assertions and labels around lines
504–506 would have been missed by the locator and then demanded by the rule.

**The third grep is the one that keeps the suite green, and it is case-insensitive on purpose.**
Most assertions in this file do not quote the qualified phrase at all: they grep the hook's output
for the bare verdict word — `grep -q 'not satisfied'` — and label the case `-> NOT satisfied` in
upper case. §F items 15 and 16 remove that word from both messages in favour of `cannot confirm`
and `Codex gate state:`, so **every one of those assertions goes red the moment Task 10 lands**,
and the repo cannot pass its own quality battery. A locator matching only `Gate B not satisfied`
sees three of them. **Read and update every hit of the bare word by the hook state the message now
reports**, exactly as step 3 requires — and do not turn the observed hit count into a target, for
the reason this task's opening gives.

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
grep -c 'Gate B satisfied\|Gate B not satisfied\|Gate A satisfied' plugins/dev-workflow/hooks/codex-gate.test.sh
grep -ni 'satisfied' plugins/dev-workflow/hooks/codex-gate.test.sh
```

Expected: **`0` from the first**, and **every remaining hit of the second disposed of in writing** —
the bare case-insensitive sweep is repeated here because it is the one step 1 used to find the
sites, and a closing check narrower than the locator cannot confirm the sweep it closes. A label
wrapped onto a continuation line, or one naming the verdict without the gate, survives all three
qualified phrases while the suite passes.

**Not "no hits you cannot justify"** — step 3 requires every label and comment to move
to observed hook state, and a justify-in-the-commit-body escape hatch is how the old gate-verdict
vocabulary survives a sweep. Where a test still needs that case, name it by what the hook observed.

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

- [ ] **Step 5: Write the result into this plan, then commit it**

**Write both predicates in full, as you extracted them, and the result in both directions**, under
`## b11/b13 equivalence (Task 12 output)` at the end of this plan — created if absent, replaced
whole if present, by the same idempotent rule Tasks 13 and 14 use.

**"Record the result — it goes in the evidence entry" named no file and modified none.** Task 15
step 5 assembles the closing entry from this plan's recorded outputs; a comparison whose subject
and reasoning were written down nowhere cannot be read back, cannot be re-checked after a Gate-B
fix changes either predicate, and reaches the closing commit as an assertion that the check
happened.

```bash
git add docs/superpowers/plans/2026-09-14-loop-rule-consolidation.md
git commit -m "WIP: record the b11/b13 equivalence result"
```

---

## Task 12b: The completeness sweep design §3 and target §I assign to the plan

**Files:** possibly `CLAUDE.md`, `plugins/dev-workflow/commands/workflow-init.md`, `plugins/dev-workflow/hooks/codex-gate.sh`; and this plan, which records what was examined.

**This task exists because nothing else performs the sweep.** Design §7 leaves "the sweep for any
affected site this text has not found" to the plan, and target §I records that **nothing in the spec
establishes the edit set is complete** — it is the sites known when §F stopped growing. Without a
task, every other task can finish while a standing instruction the ordering falsifies is still live,
which is exactly the completeness failure the design hands to the plan. **The plan's own residual
paragraph says the sweep is "owed by whoever executes", which names a duty and discharges nothing.**

**It is a reader-led sweep, not a mechanical guard.** No pattern decides whether a sentence the
ordering falsifies is still live; §G says so about its own subject, and inventing a checker here
would be the false precision this repo's invariants warn about. What is mechanical is the **record**:
what was read, and what was found.

- [ ] **Step 1: Read the installed ordering once more, and list what it now decides**

Closure, eligibility, cleanliness, the hold and what discharges it, composition, the two scope
triggers, the suspensions and their answers, the two gates' closing acts, **the duty
classification**, **the source-block branch and its two reread routes**, **the repeated-dismissal
cleanliness exclusion**, and **the parked state after a closing act that cannot be repaired**.

**Read the list off the installed §A rather than from here.** This enumeration is a floor and an
earlier draft's was short by four — a closed list in a plan is the bookkeeping that goes stale, and
the block itself is the only complete statement. For each item: "does any other sentence in these
three files still answer this?"

- [ ] **Step 2: Read every section of both prompt copies that gives an instruction about a pass, a finding, a gate or a commit**

Not a grep. §5 entire, §4's work-loop line, the Gate-A and Gate-B sections, the profiles section, and
Mechanics. **Record each section as read under `## Completeness sweep (Task 12b output)` in this
plan**, with a line saying what you were looking for and what you found. A `.context/` scratch file
is fine while you work, but it is ignored and cannot be committed — the plan section is the record.

- [ ] **Step 3: Read both channels of all eight hook gate reminders**

Seven are replaced by §F. **The eighth, the docs-only notice, is read too** — it is excluded because
it states no closure permission, and that exclusion is a claim this sweep is the place to confirm.

- [ ] **Step 4: Classify anything found**

A site the ordering falsifies that §F does not replace is **a finding against the approved spec, not
a gap in this plan**. Surface it: the spec's §F is the only enumeration of these sentences, and
adding one here would be the second copy that cycle spent sixty-five passes removing. **Where the
find is real, the spec's Gate-A cycle reopens for it.**

- [ ] **Step 5: Record the result either way**

`## Completeness sweep (Task 12b output)` states what was read and what was found, **including
"nothing"**. A sweep whose negative result is unrecorded cannot be told from a sweep that never
ran — and one recorded only in `.context/` is unrecorded as far as the commit is concerned.

- [ ] **Step 6: Commit**

```bash
git add docs/superpowers/plans/2026-09-14-loop-rule-consolidation.md
git commit -m "WIP: record the completeness sweep"
```

**The record goes in the plan, not in `.context/`.** `.gitignore` carries `.context/*` with only
`codex-gate.on` and `codex-reviews/` exempt, so `git add .context/loop-rule-sweep.md` is refused and
the task could not make its own commit. Write the sweep record under
`## Completeness sweep (Task 12b output)` at the end of this plan, replaced idempotently by the same
rule Tasks 13 and 14 use. The scratch files Task 0 writes stay in `.context/` and stay ignored —
they are working state, not a deliverable.

---

## Task 13: The next-state table and the per-condition closure checks

**Files:**
- Modify: this plan (the table lives here; design §7)

**What the table claims, at exactly this width:** it covers **answer-state transitions once the predicates producing them are established**. It does **not** establish how each predicate was derived — a wrongly derived predicate produces a row that passes — nor whether the rows cover every reachable combination of the clean, scope and health predicates. **The evidence entry states the claim at this width and no wider**; closing either gap is the parked fixture-per-predicate question, which this change does not reopen.

**The oracle.** A row **fails** when its required answer does not produce a **distinct** resumable or closed state — the same stop returning with its reading unconsumed, that is, without an intervening validated pass run after the answer — or when it closes on anything other than the route the block states. **Read the closure conditions and the routes off the installed §A, not from this plan** — an embedded copy can pass while disagreeing with the text it checks.

**Where it goes:** this plan, under the heading `## Next-state table (Task 13 output)` at the end of
the document. **Task 13 replaces that whole section idempotently** — re-running it must not append a
second table. If the heading is absent, create it; if present, replace everything under it up to the
next `## `.

- [ ] **Step 1: Enumerate the rows**

**Every row states the value of every predicate its route depends on, and is split until the
installed ordering yields exactly one next state.** A scenario naming only some of them is not a
row: "a clean eligible pass with an unmet precondition" can take the source-block route, a
suspension, or the continue branch depending on predicates it never states, and "a clean pass below
the floor" can suspend or continue on the same grounds. **A row with more than one admissible route
tests nothing** — the executor either picks one arbitrarily or invents the missing assumption, and
the oracle then passes on an answer the ordering never gave. Split the family until each member is
determinate, and say in the row which predicate values made it so.

The list below is **scenario families, not rows** — one row per (starting state, answer) pair the
installed ordering admits, after splitting. At minimum, and **this is a floor rather than the set**: a clean eligible pass with every condition met; a clean eligible pass with an unmet precondition; a clean pass below the floor; a zero-finding pass below the floor; a pass carrying a membership trigger, answered accept and answered decline; a pass carrying a new-question trigger, answered; a pass carrying both; a two-tell stop, answered; a clearly-stuck surface, answered; a source block raised before any pass was read; a source block raised on a pass already read; a closing act that does not complete and is repaired; a closing act that cannot be repaired; a `full` Gate-B pass with one branch clean and one not; the same complaint in both branch files under each of accept/accept, accept/decline, decline/accept and decline/decline.

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

- [ ] **Step 1: Extract and diff every changed site, from the target text's own markers**

**Nine fixed 25-line windows are not the site list.** They omit §G, both gate-prompt instructions,
the human-exception edits, the WIP and finishing-cycle text, the evidence-revalidation trigger and
the curve rationale — every one of which this change ships, and any of which could differ between
the copies while a nine-window diff passes.

**Drive the list from the artifact, and the unit is a destination site, not a target section.**
One row per **fenced block whose destination is a prompt copy** — so §H contributes **nine** rows,
one per live site it replaces, not one row for the section. Its nine blocks land at nine
noncontiguous places in each copy and no single start/end region spans them; a section-level row
would either be unbuildable or would sample one of the nine and leave the other eight out of the
final parity diff.

**Count the blocks, not the sections, everywhere** — including where a section's blocks happen to
be adjacent. **§A contributes three** (A1, A2, A3), **§D two**, **§E two** (the Severity bullet and
the demotion answer), **§H nine**; §B, §C and §G one each; every §F item whose destination is a
prompt copy, one. An earlier draft applied the block rule to §H and then gave §A and §E one row
each anyway, which is the section-level grouping the rule replaces, surviving in the two places it
looked harmless.

For each, extract a **bounded** region — from its first line to the first line of the next passage,
not a fixed count — and diff the two copies:

```bash
# .context/loop-rule-changed-sites is written by this step: one
# start<TAB>end line per destination site — per fenced block the target
# marks NEW or REPLACED, and per §F item whose destination is a prompt
# copy. Build it by reading those markers off the target text, then:
while IFS=$(printf '\t') read -r s e; do
  echo "== $s"
  for f in CLAUDE.md plugins/dev-workflow/commands/workflow-init.md; do
    # Anchors are DERIVED from the target text, so they carry ** and / and .
    # Unescaped they are a basic regular expression, not a literal.
    test "$(grep -cF "$s" "$f")" = 1 || { echo "start anchor not unique in $f"; exit 1; }
    test "$(grep -cF "$e" "$f")" = 1 || { echo "end anchor not unique in $f"; exit 1; }
  done
  se=$(printf '%s' "$s" | sed 's/[][\.*^$\/]/\\&/g')
  ee=$(printf '%s' "$e" | sed 's/[][\.*^$\/]/\\&/g')
  a=$(sed -n "/$se/,/$ee/p" CLAUDE.md)
  b=$(sed -n "/$se/,/$ee/p" plugins/dev-workflow/commands/workflow-init.md)
  test -n "$a" && test -n "$b" || { echo "empty extraction for '$s' — region not found"; exit 1; }
  printf '%s\n' "$a" > .context/loop-rule-a.txt
  printf '%s\n' "$b" > .context/loop-rule-b.txt
  diff .context/loop-rule-a.txt .context/loop-rule-b.txt
done < .context/loop-rule-changed-sites
```

**Three assertions, and each one has already been the failure mode somewhere in this cycle.**
A derived anchor containing `**`, `/` or `.` is a **regular expression** to `sed`, not a literal,
so it can error or match the wrong line; a non-unique anchor selects a region that is not the one
named; and **two empty extractions diff equal**, which certifies parity for a block neither `sed`
ever found. Without the empty test that failure is silent and looks like success.

**The list is a step output, not an assumed input.** An earlier draft gave one generic command with
undefined `$start` and `$end` and no step producing them, so the task could record a divergence list
without having diffed anything.

**Fail this step where a site named by §§A–H has no region in your list** — that is the same
completeness failure as Task 13's per-condition checks, and it is caught the same way: by reading
the set off the artifact rather than from a list kept here. **Read it block by block**, which is
what makes §H's nine sites visible; reading it section by section is what hid eight of them.

**Where it goes:** this plan, under the heading `## Divergence list (Task 14 output)` at the end of
the document, replaced idempotently on re-run by the same rule Task 13 uses.

**It carries the site list as well as the differences — one line per destination block examined,
with its parity result, "no difference" included.** The derived list lives in `.context/`, which is
ignored, so nothing durable would otherwise say *which* blocks were compared. **A site missing from
the list and a site that compared equal produce the same record** if only differences are written
down, and Task 15's block-by-block parity claim would then rest on a record that cannot
distinguish them — the same failure Task 12b's "including nothing" rule exists for. Continue to
derive the set from the target's markers; copy the identifiers and results here.

- [ ] **Step 2: Classify every difference the diff reports**

Three buckets: **deliberate and stays** (the field-mint parenthetical, `e11`, `f5`–`f7`'s evidence
framing — each recorded in the inventory); **not deliberate, align it**; **introduced by this
change, fix it**. Write the list into this plan.

**`e8` is not in the first bucket.** Task 5 installs §D's complete sentence in both copies, which
gives W the pronoun; classifying that divergence as deliberate here would let the two shipped copies
disagree on a sentence the approved target states once. **`b3` is not in it either** — Task 3
aligns it, and this task verifies the alignment rather than performing it.

- [ ] **Step 3: Verify W's `b3` alignment, which Task 3 performed**

Task 3 installs §B's common span, which aligns `b3`. **This step confirms it rather than repeating
it** — an earlier draft told this task to apply the alignment, which is either impossible or
redundant after a correct Task 3, and contradicted the paragraph above that assigns the alignment to
Task 3.

- [ ] **Step 4: Re-run the diff** and confirm only the deliberate divergences remain.

- [ ] **Step 4b: Diff all five untouched ranges against the parent, after every text edit**

Task 2 ran this after Task 1 only, and Task 14's parity diff compares C against W rather than either
against the parent. **A later task can alter an untouched condition identically in both copies and
every other check still passes** — the parity diff sees no difference and no pair covers text no
task claims to change.

For each span in `.context/loop-rule-untouched`, resolve its start and end anchors **separately in
the parent and in the worktree**, extract the two slices, and diff them.

**Not a `sed` range with the same anchor at both ends.** `sed` does not test the end address on the
line that matched the start, so a single-line site runs to the next match or to end of file — which
is why the squash-carry sentence is checked with `grep -n` instead. And not line numbers carried
from Task 0: Task 1's insertion shifts everything after it in one tree and not the other.

**Plus every `cond` row in that file** — count the recorded fragment in the parent and in the
worktree and compare against the two expected values the row carries. **Read the set off the file,
not from a list here**: which kept conditions needed one is decided at Task 0 against the real
lines, and an enumeration in this step would be a second copy of it.

**Record every one of these results — the `cond` rows and the span diffs both — in this task's
`### Task 14` fragment-evidence subsection, and commit it in step 5.** Task 15 step 5 says every
preservation is read from that section, and nothing was writing them there: a span-less kept
condition would then have no durable evidence in the reviewed `HEAD` at all, and **a zero-finding
first Gate-B pass closes before step 7's re-record rule ever runs**, so the omission would ship. A
span diff's result is `no difference` and belongs beside the counts, for the same reason Task 12b
records "nothing".

**Anchors, resolved separately in each tree** — Task 1 inserts a large block, so a line number taken
from either tree addresses different text in the other, and an earlier draft's numeric `sed`
addresses would have reported CHANGED on identical content. Expected: no output for every recorded
span. **This is the last check before Gate B** and it is the only one that
would catch an identical accidental edit in both copies.

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

**First fetch the base ref, because one step in the battery has a precondition the others do not.**
`check-version-bump.sh` compares *commits* against a base ref, so a stale base compares the bump
against a different commit than the pull request will, and the run is green about the wrong
comparison. **Fetch, then pass the fetched ref to the checker itself** — an earlier draft fetched
`origin/main` while the battery went on passing the local `main`, and recorded `origin/main` as
what supplied a comparison it had not supplied:

```bash
git fetch origin main
git rev-parse origin/main > .context/loop-rule-baseref   # resolve ONCE; record this object name
cat .context/loop-rule-baseref
```

**Pass that object name to `check-version-bump.sh`, not `origin/main`.** A remote-tracking ref is
mutable: another fetch between the record and the run makes the evidence name one commit while the
checker resolves another, and the claim that the recorded revision is the argument the check
received would be false. The object name is the argument.

**It goes to a file, not to a shell variable**, for the reason Task 0 gives about `$BASE`: each
fenced block below runs in its own shell invocation, so a `BASEREF=` assignment here is gone by the
time the battery runs and the checker would receive an empty argument. The battery reads it back.

```bash
BASEREF=$(cat .context/loop-rule-baseref)
test -n "$BASEREF" || { echo "BASEREF empty — the fetch step did not run"; exit 1; }
shellcheck --shell=sh plugins/dev-workflow/hooks/codex-gate.sh && \
shellcheck --shell=sh --exclude=SC2015 plugins/dev-workflow/hooks/codex-gate.test.sh && \
shellcheck --shell=sh scripts/check-invariants.sh && \
shellcheck --shell=sh --exclude=SC2015 scripts/check-invariants.test.sh && \
shellcheck --shell=sh scripts/check-version-bump.sh && \
shellcheck --shell=sh scripts/check-version-bump.test.sh && \
HOOK_SH=sh sh plugins/dev-workflow/hooks/codex-gate.test.sh && \
HOOK_SH=dash dash plugins/dev-workflow/hooks/codex-gate.test.sh && \
sh scripts/check-invariants.test.sh && sh scripts/check-invariants.sh && \
sh scripts/check-version-bump.test.sh && sh scripts/check-version-bump.sh "$BASEREF" && \
claude plugin validate . --strict
```

Expected: exit 0. **`$BASEREF`, not `main` and not `origin/main`** — AGENTS.md's battery row writes
`main` because a human running it locally usually has one; here the base is the fetched commit,
resolved once, so the recorded revision and the argument the successful check received are the same
value by construction.

- [ ] **Step 4b: Apply all twelve `docs/prompt-standards.md` items to the installed text, and commit the result before Gate B**

**Nothing mechanical does this and no other task claims it.** The battery's three narrow checks are
a floor — one `Target model:` spelling, one prose count claim, one severity vocabulary — and
invariant 11 requires all twelve items of every skill, command, hook message and scaffolded template
this change touches. **Read the installed §A–§H text in C, in W, and the seven hook strings, against
each of the twelve items, and record the result per item in this plan.** Items 6 (every constraint
carries its reason in the same sentence) and 8 (token-lean) are the ones design §8 names as most at
risk.

**A reader check, deliberately** — no pattern decides whether a constraint carries its reason.

**Expected result: all twelve pass. A failure stops this step.** Invariant 11 is not "record the
score"; recording a failure and continuing ships a prompt change that violates it, which is the one
outcome this step exists to prevent. **On any failure: repair the text, then re-run every check the
repair invalidated** — the affected pairs, presence, absence and preservation counts, the parity
and untouched checks over the blocks touched, and the whole step-4 battery — and only then commit
the refreshed record. A repair made after the battery, with the battery not re-run, is the same
defect as a Gate-B fix with no re-run.

**Record the subject set once, at the top of the output section**, and make each item's result
refer to it: the §A–§H blocks installed in C, the same in W, and **ten hook prompt bodies, not
seven** — the seven `additionalContext` bodies items 10–13, 15–17 replace, **plus the three
`systemMessage` bodies** items 12, 15 and 16 replace alongside them. Those three are short
operator-facing prompts and they ship; counting the messages rather than the bodies leaves them
outside invariant 11's only reader gate.

**Twelve `PASS` lines alone cannot be told from a review that skipped a copy or a channel** — the
subject list is what makes the twelve lines mean something.

**Commit the result before step 6.** Gate B reviews the range `$BASE..HEAD`; an edit to this plan
left in the worktree is in neither that range nor the final `reset --soft`, which stages only what
the discarded commits contained. The same applies to every record this plan collects — the sweep, the
next-state table, the divergence list:

```bash
git add docs/superpowers/plans/2026-09-14-loop-rule-consolidation.md
git commit -m "WIP: plan records"
```

**`check-invariants.sh` includes the prompt-conformance checks** — a `Target model:` line naming one recognized model, a prose checklist-count claim matching the checklist, and the finding-severity vocabulary as a closed set in both prompt copies. Those three are a floor, not coverage; invariant 11's other eleven items are judged by a reader.

- [ ] **Step 5: Write the evidence entry into `.context/loop-rule-closing-msg`**

**Not into a WIP commit body.** Step 8 squashes with `git reset --soft`, which keeps the tree and
discards every WIP message; evidence written only there would be destroyed by the close. Restate it
in the WIP body too if a mid-cycle reader would want it, but the file is the copy that survives.

**The file is completed at step 7b, not here.** The evidence entry can be drafted now, but the
**per-pass curve is not known until the Gate-B loop ends**, and the **provenance line** and any
**human-exception record** belong beside it. **Step 7b appends all three and revalidates the
entry** — this step opens the file, step 7b closes it, and step 8 commits it.

It names: the battery run; **every pair this plan built, with its counts in each copy and each tree, every presence check beside them, and every absence check with its two counts**; the §6 parity diff and the `b11`/`b13` equivalence result; and the next-state table's location plus its row count.

**Each of those is read from the section that actually holds it**, and they are not one place:
`## Fragment evidence (per-task output)` for the pairs, presence and absence counts;
`## b11/b13 equivalence (Task 12 output)` for the equivalence result;
`## Divergence list (Task 14 output)` for the parity outcome;
`## Next-state table (Task 13 output)` for the table and its row count;
`## Completeness sweep (Task 12b output)` and `## Prompt-standards result (Task 15 step 4b output)`
for those two reader records. **An entry assembled from one section would silently drop whatever
the other five hold.**

**All four record shapes belong in the entry, not only pairs and presence.** A **dropped**
condition's absence and a **moved** condition's absence are what prove an obsolete instruction was
removed; a **carried** or span-less **kept** condition's preservation count is what proves
reproduced text survived. An entry listing only pairs and presence claims the verification set
while omitting both. **Read the set off the disposition table and the fragment evidence, not from
an enumeration here** — an id list in this step was already stale once, naming `a18`–`a20` after
`a17` had joined them.

**State the §A presence checks as presence, not as pairs** — its counterfactual is absent and is claimed as absent.

- [ ] **Step 6: Run Gate B**

```bash
BASE=$(cat .context/loop-rule-base)   # the parent of the FIRST WIP, from Task 0
git rev-parse HEAD                    # the current WIP tip
```

**`baseSha` is `$BASE`, never `HEAD^`.** This plan makes a WIP commit per task, so `HEAD^` is the
parent of the *last* one and the review range would hold the version bump alone — Gate B would
close having reviewed none of the prompt or hook changes. `$BASE` is the parent of the first WIP
and is the only value whose range contains the whole implementation.

`mcp__codex__review` with `reviewType: full`, `baseSha` = `$BASE`, `headSha` = the full 40-character object name `HEAD` resolves to **at that moment**, resolved once and kept with each branch's result. Carry the story path and the evidence entry quoted verbatim. Write findings to `.context/codex-reviews/gate-b-<spec|quality>-<nonce>-pass-<p>.md` — **draw a fresh nonce for this cycle**; it is a different cycle from `awsf1ec771`.

**Standing lens, every call:** "which existing statements does this diff falsify?" and **name what this diff changes the size, value or position of** — a list, a count, a version, an identifier, a cited line — then grep for where each is described elsewhere.

- [ ] **Step 7: Loop until a pass is closure-eligible — clean at or above the derived floor, or zero-finding**

Floor derives from the story profile: risk `high` → 2, security `none` → 0, max 2 ≠ 0 → **floor 3**. Re-derive it at each pass from the header.

**Two routes reach the closing act, and this loop must admit both**: a **clean pass at or above the
floor**, or a **zero-finding logical pass** at any pass number — the early exit below the floor.
Both are subject to every other closure condition. **An earlier draft named only the first**, so a
first or second Gate-B pass whose two branch files both read `NO FINDINGS` would have been routed
into further passes — the implementation procedure overriding the very rule §A installs, and the
one case Task 13's table checks by name. A zero-finding pass is `NO FINDINGS` in **every** required
branch file; one branch clean and the other not is not it.

**Each fix is committed before the next review is issued**, or the re-review targets the unchanged
WIP tip while the repair sits in the worktree — and the final squash then publishes a fix no pass
reviewed:

**Before committing each fix, re-run what the fix could have broken**, then:

```bash
git add -A && git commit -m "WIP: fix <finding>"
git rev-parse HEAD          # resolve headSha fresh for the next call
```

Re-review after every fix. **Revalidate the evidence entry before every re-review and before the
closing commit.**

**A fix that changes specified behaviour updates the spec in the same commit.**

**The battery and the reader checks are not done when step 4 passed once.** A Gate-B fix can touch
the hook, its test, either prompt copy or the target text, and step 4's run and step 4b's
twelve-item review both describe the tree as it was *before* that fix. Without re-running them the
plan reaches its closing commit on a tree that never passed its own quality battery — a repo unable
to pass CI, or an invariant-11 violation, published by a cycle that closed clean.

- **After each fix, re-run every check whose subject it changed — mechanical and reader alike.**
  The hook or its test means the suite under both shells; a shell file means `shellcheck`; either
  prompt copy means `check-invariants.sh` **and** every observation over the text the fix touched —
  its pair, presence, absence and preservation counts — **and** the reader checks whose subject
  moved: Task 12's equivalence where `b11` or `b13` changed, Task 12b's sweep where the ordering or
  a hook message changed, Task 13's transitions and closure checks where §A changed, Task 14's
  parity and untouched checks wherever text moved at all. **Naming only the mechanical ones let a
  fix invalidate a reader record that then reached the closing commit unchanged.**
- **Persist every re-run record and commit it before the re-review**, so the reviewed range holds
  it. A refreshed record left in the worktree is in neither the Gate-B range nor `reset --soft`.
- **Before the candidate final pass, re-run the complete set, and "complete" means mechanical as
  well as reader.** The whole step-4 battery against the current `HEAD`; step 4b's twelve items;
  every reader check above; **and every mechanical observation this plan built** — each
  discriminating pair, each add-only presence check, each moved and dropped absence, each carried
  and kept preservation count — re-run and re-recorded in `## Fragment evidence (per-task output)`.
  **An earlier draft named only the battery and the reader checks**, so the clean pass could close
  on a `HEAD` whose fragment evidence had never been re-established as a set, and the plan's
  design §7 claim would rest on counts taken from an older tree.
- **Commit those records, resolve the new `HEAD`, and only then issue the candidate final pass.**
  **Only a clean response issued against that exact `HEAD` closes the cycle.** A pass that was
  clean against an earlier tree, plus records committed afterwards, closes on a tree no pass
  reviewed — which is the same defect as reviewing the wrong range, arrived at from the other end.
- **One thing cannot exist before that pass: the pass's own findings file.** It is therefore the
  **sole permitted post-review addition**, and step 8 asserts that it is the only one — every other
  path must already be in the reviewed `HEAD`. `.context/` moves none of the hook's fingerprint
  inputs, so the file changes nothing the review looked at; what would be wrong is a *second*
  delta riding along beside it.

- [ ] **Step 7b: After the clean pass, complete `.context/loop-rule-closing-msg` — this is the
  action step 5 defers to, and step 8 has no other source for these records**

**Rebuild the file whole, do not append to it.** Step 5 opened it with a draft entry, and a failed
closing act preserves it while requiring a fresh final pass whose curve and evidence supersede the
previous candidate's. **Appending on re-entry writes a second provenance line and a second curve**,
which breaks the one-of-each grammar Mechanics pins, or leaves a stale curve standing beside the
current one. Write the complete message from the current records at every candidate close, then
assert **exactly one** provenance line and **exactly one** curve for this cycle before step 8.

The message carries, in this order:

1. the **provenance line**, in the form Mechanics pins — the Gate-B cycle's nonce, the derived
   floor, the cited set with each member's level, and the workspace knob;
2. the **per-pass curve** for this Gate-B cycle, `<CYCLE-FIELD>; Gate B (passes …): Findings …
   Blockers … Majors …`, which is why this cannot be written at step 5: the counts do not exist
   until the loop ends;
3. any **human-exception record**, and beside it the skip reason if a cycle was skipped;
4. the **revalidated evidence entry**, replacing step 5's draft if revalidation changed it.

**Items 1, 2 and 4 are owed unconditionally; item 3 is owed only where such a record exists.**
Confirm the file carries the three, and either the applicable exception records or **the literal
line `Human exceptions: none`**, which is what satisfies this check for an ordinary cycle. Without
that line an executor reading "all four" must either invent a record or ignore the oracle, and a
valid close stops on a record nobody owed.

**Plural, and deliberately not `Human exception:`.** That singular prefix opens the fixed
three-line record Mechanics pins, and a line carrying it without its handle, date, `Not done:` and
`Accepted because:` is a **malformed record**, not an absence marker — every ordinary close would
write one, and a later reader could not tell it from an exception record that lost its body.

**A missing one is not recoverable after step 8** — `git commit -F` publishes whatever the file
holds, `reset --soft` has already discarded every WIP body, and a closing commit without its
provenance line or curve has not validly closed the cycle.

- [ ] **Step 8: Close the cycle**

**Build the closing message in a file first.** `git reset --soft` discards every WIP commit *body*,
so an evidence entry written only into a WIP message is destroyed at exactly the moment the cycle
closes — which is what step 5 would otherwise have done.

**8a — record the final pass's findings files. Its own shell invocation, and that is not
cosmetic.** `codex-gate.sh`'s `is_wip_commit` (`plugins/dev-workflow/hooks/codex-gate.sh:763`) tests the **whole command
string** it is given against `-m[[:space:]]*['"]?[[:space:]]*wip`, case-insensitively: **`-m`
immediately followed by optional whitespace, an optional quote, and `wip`.** A single block carrying
this `-m "WIP: …"` and the closing `git commit -F` matches, and is classified cycle-internal in its
entirety — the hook would then carry this cycle's Gate-B count and fingerprint into the next one, a
real closing commit read as a snapshot. **So run 8a and 8b as separate Bash calls.**

**8b re-establishes that `HEAD` is still the tip 8a recorded, and stops without moving it if not.**
The split into two invocations is what makes this necessary: time passes between them, and a commit
landing in that window leaves the worktree clean, so every other check in 8b passes while
`reset --soft` stages and squashes that commit into the closing body — defeating the rule that 8a's
findings commit is the only commit admitted between the reviewed tip and the closing act.
**Stopping before the reset is the recoverable direction**; stopping after it is not.

**What 8b must avoid is that pattern, not the letters.** `--mixed` contains `-m` and matches
nothing, because `i` follows; a path containing `wip` matches nothing, because no `-m` precedes it.
Saying "no `-m` and no `wip` in 8b" would outrun the check the hook performs and make a correct
block look non-compliant. 8b carries no `-m` option at all, which is the property that matters.

```bash
BASE=$(cat .context/loop-rule-base)
test -n "$BASE" || { echo "BASE empty — Task 0 did not run"; exit 1; }
# NONCE and P are this cycle's nonce and its final pass number — the same two the
# final call's slot paths were built from. Set them to the values you used.
NONCE=<this cycle's nonce>; P=<the final pass number>
FINAL=".context/codex-reviews/gate-b-spec-$NONCE-pass-$P.md .context/codex-reviews/gate-b-quality-$NONCE-pass-$P.md"
expected=$(printf '%s\n' $FINAL | sort)
# EVERY porcelain record, whatever its status letters — staged modifications,
# deletions, renames and conflicts included. A filter that reads only '??' and
# 'A  ' declares the set exact while a staged tracked change sits beside it, and
# `git commit` then commits the whole index.
actual=$(git status --porcelain -z | tr '\0' '\n' | sed -n 's/^.\{3\}//p' | sed '/^$/d' | sort)

head_paths=$(git show --name-only --pretty=format: HEAD | sed '/^$/d' | sort)
if [ -z "$actual" ] && [ "$head_paths" = "$expected" ]; then
  echo "final findings files already recorded by a previous attempt — continue at 8b"
elif [ "$expected" = "$actual" ]; then
  PRE=$(git rev-parse HEAD)          # the reviewed tip, before the record commit
  # shellcheck disable=SC2086
  git add $FINAL
  git commit -m "WIP: Gate-B findings files" || { echo "record commit FAILED"; exit 1; }
  test "$(git show --name-only --pretty=format: HEAD | sed '/^$/d' | sort)" = "$expected" || {
    echo "record commit changed paths beyond the final findings files — restoring the reviewed tip"
    git reset --mixed "$PRE"
    git status --porcelain
    echo "HEAD and index restored. Inspect the paths listed above, re-establish every closure"
    echo "condition, obtain a fresh clean response, then retry 8a."
    exit 1; }
else
  echo "dirty set is not exactly the final pass's findings files:"; git status --porcelain; exit 1
fi
test -z "$(git status --porcelain)" || {
  echo "tree not clean after the record commit — restoring the reviewed tip"
  test -n "${PRE:-}" && git reset --mixed "$PRE"
  git status --porcelain
  echo "Inspect the paths above, re-establish every closure condition, obtain a fresh clean"
  echo "response, then retry 8a."
  exit 1; }
git rev-parse HEAD > .context/loop-rule-reviewed-tip
```

**The first branch is the retry path, and it compares `HEAD`'s exact changed-path set.** A closing
commit that fails leaves the findings files already committed, so on a second run the dirty set is
empty — and an unconditional record commit, or an exact-dirty-set guard with no such branch,
refuses the very state the recovery produces.

**The dirty set is built from every porcelain record, not from two status codes.** An earlier draft
read only `?? ` and `A  ` entries, so a **staged tracked modification** sitting beside the two
findings files was invisible: the set compared equal, `git commit` committed the whole index and
swept the change in, the following clean-tree test passed, and 8b published content the reviewed
`HEAD` never carried. **And the record commit's own changed-path set is checked afterwards**,
because the guard describes the working tree while the commit is what actually lands.

**Both post-commit checks restore the pre-record tip when they fail**, like every other rejection in
step 8: the changed-path test **and** the clean-tree test after it. A bare exit at either would
leave a rejected WIP commit at `HEAD` carrying an unreviewed path, or an extra dirty path beside it
— and the retry branch would then refuse the state, since neither the dirty set nor the changed-path
set is `$FINAL`, so the prescribed procedure could not resume while the side effect stayed
committed. `${PRE:-}` is guarded because the retry branch reaches the clean-tree test without
setting it.

**"`HEAD` touched some `gate-b-` file" is not that test, and would be unsafe.** Step 7 commits
earlier passes' findings files, so `HEAD` can carry one while the *final* pass's two are missing
entirely — from a mistyped `NONCE`, a wrong `P`, or a pass whose files were never written. The
branch would then skip the record commit and let 8b close without the artifacts the closing commit
exists to carry. **Requiring `HEAD`'s changed paths to equal `$FINAL` exactly** admits only the
commit 8a itself would have made.

**8b — reset and close. A separate invocation, carrying no `-m` option at all.**

```bash
BASE=$(cat .context/loop-rule-base); TIP=$(cat .context/loop-rule-reviewed-tip)
test -n "$BASE" && test -n "$TIP" || { echo "BASE or TIP missing — 8a did not complete"; exit 1; }
# 8a and 8b are separate invocations on purpose, so time passes between them and a
# commit can land without leaving the worktree dirty. Nothing below would notice.
test "$(git rev-parse HEAD)" = "$TIP" || {
  echo "HEAD has moved since 8a — it is $(git rev-parse HEAD), the reviewed tip is $TIP"
  echo "NOT resetting. Whatever landed is unreviewed; re-establish the closure evidence first."
  exit 1; }
git reset --soft "$BASE"
git commit -F .context/loop-rule-closing-msg || {
  echo "closing act FAILED — restoring the reviewed tip without discarding its side effects"
  git reset --mixed "$TIP"
  git status --porcelain
  echo "HEAD and index restored to the reviewed tip. Any files listed above were left by the"
  echo "failed attempt — inspect them, then re-establish every closure condition before retrying 8a."
  exit 1; }

bad=""
case "$(git log -1 --pretty=%s)" in
  [Ww][Ii][Pp]:*) bad="closing commit reads as a snapshot" ;;
esac
test -z "$(git status --porcelain)" || bad="${bad:+$bad; }worktree dirty after the closing act"
if [ -n "$bad" ]; then
  echo "closing act REJECTED: $bad — restoring the reviewed tip without discarding side effects"
  git reset --mixed "$TIP"
  git status --porcelain
  echo "HEAD and index restored. Re-establish every closure condition, obtain a fresh clean"
  echo "response against the new HEAD, then retry 8a."
  exit 1
fi

rm -f .context/loop-rule-base .context/loop-rule-reviewed-tip
```

**Both post-commit checks restore the tip as well, and an earlier draft left them as bare exits.**
A closing act that *commits successfully* and then fails its subject or clean-tree check left
`HEAD` at the rejected commit with no way back — and 8a could not be re-entered from there either,
since that commit's changed-path set is the whole squash rather than `$FINAL`. The cycle was then
unable to close through the plan and unable to return to its reviewed state, which is exactly the
incomplete-closing-act transition target §A requires to be recoverable.

**`--mixed`, never `--hard`.** A closing act can fail *after* a commit hook has modified or staged
tracked content, and `reset --hard` would delete exactly that — the delta the failure produced.
Target §A1 requires the executor to inspect what an incomplete closing act left and to re-establish
the closure conditions against it; a recovery that discards the evidence first makes that
impossible and retries against a repository state the target says must be evaluated.
`--mixed` puts `HEAD` and the index back at the reviewed tip and leaves the working tree alone, so
`git status` above *is* the attempt's delta.

**Both scratch files are removed only after a successful close**, so a later run cannot inherit
either, and the retry path above still has them.

**Every check in that block fails the script; none of them is a comment.** An earlier draft
suppressed the record commit with `|| true` and left the status and log lines as things to look at,
so a failed record commit, a dirty tree or a closing message still reading `WIP:` all proceeded
through the soft reset and deleted the recovery base — producing, silently, the exact state the
plan elsewhere calls an invalid close.

**`|| true` is replaced by branching on what the state actually is, before committing anything.**
"Nothing to commit" and "the commit failed" are different outcomes and only the first is fine. 8a
decides between them with two predicates it can name: the **status-derived dirty set** — every
`git status --porcelain -z` record with its three-character status prefix removed, sorted — and
**`HEAD`'s changed-path set**. An empty dirty set with `HEAD` equal to
`$FINAL` is the harmless retry; the dirty set equal to `$FINAL` is the first run; anything else
stops. **A `git diff --cached --quiet` test is not among them** — an earlier draft's prose claimed
it after the block had stopped using it, which is the overclaim `AGENTS.md` names by requiring
prose to state the exact comparison performed.

**The base file is removed only in the success branch.** `git commit` can fail on a hook, a signing
key or an unset identity, and at that point the reset has already happened: the WIP commits are
gone, the whole change is a staged tree, and `.context/loop-rule-base` is the only record of where
the cycle started. Deleting it unconditionally destroys the one value a rerun needs, in the single
state where it is needed.

**`$BASE` is the recorded revision, not a placeholder to substitute by hand**, and the file is
removed afterwards so a later run cannot inherit a stale one.

**`reset --soft` stages committed content only.** The prompt-standards result (step 4b), the
completeness sweep, the next-state table, the divergence list, the equivalence result and the
fragment evidence all land in this plan, and `.context/codex-reviews/` is tracked; **anything still
uncommitted when the reset runs is left in the worktree and is not in the closing commit** — and,
for the plan records, was never in a Gate-B range either.

**Which is why step 7 commits them *before* the candidate final pass, and this step only adds the
findings file that pass produced.** The guard above is what keeps that distinction real: if any
other path is still dirty here, a record was written after the review rather than before it, and
the closing tree would differ from the one the clean pass read.

**`$BASE` is the recorded revision, not a placeholder to substitute by hand** — Task 0 persisted it
for this, and a mistaken substitution squashes the wrong range.

The closing body carries: the validated evidence entry; the provenance line; the per-pass curve; and any human-exception record. **One commit rather than a follow-up** — a `WIP:` commit left in history defeats the convention, and a follow-up has nothing to commit when the review produced no fixes.

---

## Self-Review

**1. Spec coverage.** §A → Task 1. §B → Task 3. §C → Task 4. §D → Task 5. §E → Task 6. §F items 1–9 → Task 8; items 14, 18 → Task 9; items 10–13, 15–17 → Task 10 with its test sweep in Task 11. §G → Task 7, **added by this review**: the first draft gave the one-contract paragraph no task, though design §4 lists it as its own site and target §G carries its replacement. It is a prompt-copy replacement in both copies with the same shape as §H's blocks, owes a discriminating pair with row **P7**'s OLD `These records are one contract` — the live wording; `These rules and records are one contract` occurs nowhere — at C 879 / W 1063 as of this writing, **and a second, add-only presence check for the semantic membership test it gains**, which P7's pair does not observe. §H → Task 7. §I ships nowhere and needs no task. Design §6 → Task 14. Design §7 → Tasks 13 and 15. Design §8 → Task 15's battery and the Global Constraints. Story AC 5 → the disposition tables. Story AC 4 → Task 13.

**2. Placeholder scan.** The replacement text is cited rather than copied, deliberately and for the reason the Architecture note gives. Task 13's row list is explicitly a floor rather than a closed set, and says so. Task 11 deliberately carries no count, and says why.

**Which steps are mechanical and which are reader checks, stated rather than claimed uniformly.** Every OLD half has an exact expected result and a procedure that produces it, but **not every one is a pre-verified table row**: the rows the tables carry were checked against the real files in advance, while Tasks 3, 4, 6, 7 and 10 **derive their remaining pre-existing fragments at execution, before their install step**, against text this plan cannot quote without becoming a second copy of it. **Task 1 is not among them:** §A is add-only, row P1 records that it has no OLD half at all, and Task 1 derives presence fragments only — listing it would send an executor looking for a counterfactual that cannot exist. **The NEW halves are `<...>` until their task installs the text**, which the fragment table discloses and each step requires to be verified before counting. **And no per-task shell is pre-written at all** — the procedure is stated once and the executor writes the command in front of the files, so "a runnable command per step" is not what this plan claims. **Tasks 12, 13 and 14 step 2 are reader checks by design** — a predicate comparison, a next-state walk and a divergence classification are judgements, and giving them commands would be the false-precision this repo's invariants warn about. An earlier revision of this section claimed every verification step had a runnable command, which was not true of them.

**3. Type consistency.** `$BASE` is set in Task 0 and used in Tasks 1–10. The four-value pair shape (`new/worktree`, `new/parent`, `old/worktree`, `old/parent`) is defined in Task 3 and referred to by name afterwards. Condition ids match the inventory throughout: a1–a22, b1–b18, c1–c20, d1–d7, e1–e11, f1–f7, g1–g4, h1–h26, i1–i16, j1–j4 — 135 total, every one dispositioned above.

**One correction applied from this review:** §G was missing a task; it is now installed by Task 7, which names **ten** sites — one §G block and nine §H blocks.

**One residual this plan does not close, stated rather than left to be found.** Nothing here establishes that the edit set is complete — it is the sites §F knows, and §F's own §I records that it cannot establish completeness either. Task 8's step 1 re-derives every citation against the real file and Task 14's diff catches a copy that fell out of step; neither is a completeness check. **Task 12b performs the sweep and records what it read**, and a site it finds is a finding against the spec rather than a gap in this plan. **What stays open is that the sweep is a reader's judgement and nothing checks its coverage** — the record says what was examined, not that the examination was complete.

---

## b11/b13 equivalence (Task 12 output)

*Empty until Task 12 runs. Task 12 replaces this entire section, carrying both predicates in full
as extracted and the result in both directions, per copy.*

---

## Next-state table (Task 13 output)

*Empty until Task 13 runs. Task 13 replaces this entire section.*

---

## Divergence list (Task 14 output)

*Empty until Task 14 runs. Task 14 replaces this entire section.*

---

## Completeness sweep (Task 12b output)

*Empty until Task 12b runs. Task 12b replaces this entire section.*

---

## Prompt-standards result (Task 15 step 4b output)

*Empty until Task 15 runs. It replaces this entire section, one line per checklist item.*

---

## Fragment evidence (per-task output)

*Empty until the tasks run. One subsection per task — `### Task 1`, `### Task 3`, … — replaced
idempotently on re-run, touching no other. **The pre-existing fragments live in the fragment table,
never here**; this section records what each observation actually returned, and it is what Task 15
step 5 reads to assemble the closing evidence entry.*

***Five record shapes, because the classes do not return the same number of values.** Every
observation this plan makes is one of them, and a shape that fits only pairs is how a required
count gets run and then vanishes from both the plan and the closing evidence:*

```
pair         <condition> <fragment: OLD> <fragment: NEW> old/worktree old/parent new/worktree new/parent <copy>
presence     <what> <fragment> worktree parent <copy>          # add-only, and a moved condition's destination
absence      <condition> <fragment> parent worktree <copy>      # dropped, and a moved condition's source
preservation <condition> <fragment> parent worktree <copy>      # carried, and kept where no span holds it
span         <start anchor> <end anchor> <file> <result>        # an untouched range, parent vs worktree
```

*The **fifth shape is for ranges, not conditions**: an untouched span is two bounded extracts
compared against each other, so it has no fragment and no counts and the four condition shapes
cannot express it. Its `<result>` is `no difference` or the difference itself — recorded either
way, because a span that was never run and a span that compared equal are otherwise the same
record. Task 15 reads this shape alongside the other four.*

*A **moved** condition therefore contributes two lines — one `absence` at its source, one
`presence` at its destination — and both are required for it to count as observed. **Every one of
the five shapes goes into the closing evidence entry**; naming only pairs and presence leaves the
absences, preservations and span results run but unrecorded.*
