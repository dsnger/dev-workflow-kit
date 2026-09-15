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
- **The target's fenced blocks are normative in their words, not in their line breaks.** The spec wraps for its own readability, and the installed wrapping need not match the spec's. **It must match between the two copies**, though: the byte-identical rule above and Task 14's parity diff both compare C against W, so "each copy keeps its own wrapping style" — as an earlier draft put it — licenses exactly the difference those checks then fail on. **Choose the wrapping once per installed block and use it in both.** What design §7 requires is narrower and is the rule here: **every fragment this plan counts must sit wholly within one line of the file it is grepped from**, and where installing a replacement would put a counted fragment across a wrap, that fragment's line is installed unwrapped. The fragment table below states, for every count, the line it must sit on. **Nothing in this plan claims the installed bytes equal the fenced block's bytes**, and no check asserts it.
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
| F11 | 8b, the Gate-A filter clause | `with severity and confidence — you filter to Blocker/Major downstream, Codex` | 562 |
| F12 | 9a, the revalidation trigger | `before the cycle-closing amend` | 727 |
| F13 | 9b, the severity-deciding fallback | `cannot name both, the finding is Minor or below: collect, never iterate.` | 789 |
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
| **replaced** (OLD half), **dropped**, **moved** (source) | **absent from the region's post-edit text** — the unchanged prefix, plus the replacement block, plus the unchanged suffix — not merely from the block | `worktree=0` — a fragment the edit does not reach survives whatever the block says |
| **carried** | **present, unchanged**, in the replacement block | `worktree=1` — the block is what preserves it, so a fragment absent from the block cannot be found afterwards |
| **kept** sharing a line with changed text | **outside** every replacement block's extent | `worktree=1` — it is not reproduced by any block; it survives because nothing replaces it |

**Applying the absent-from-its-replacement test to a carried row rejects every correct fragment**,
so a task either stops before installing or quietly drops its carried coverage. The table's cut
widened at pass 9 to hold these rows; this test did not widen with it.

**And for the disappearing classes, "absent from the replacement block" is the wrong subject.** Most
items replace only part of their live region, so what stands afterwards is **the unchanged prefix,
plus the block, plus the unchanged suffix** — and a fragment sitting in that prefix is absent from
the block, passes the test, and survives the install because the edit never reaches it. **Three
rows failed exactly that way**: F11 ended just before item 8b's first changed word, F12 just before
item 9a's, F13 just before item 9b's, so each would have returned `old/worktree=1` after a
**correct** installation and Task 8 could not have met its own required result.

**So compare against the post-edit region, not the block.** Build it — prefix, block, suffix — and
require the fragment to be gone from it. **The fragment does not have to lie wholly inside the
removed text**, which would be too strong and would reject rows like F7 that run from unchanged
wording into changed wording: overlapping the removal by one word is enough to make the whole
fragment unfindable afterwards, and that is what the count measures.

**All twelve §F rows whose items declare a live range were re-checked this way** at the commit that
records this. **F1, F2 and F3 were not**: their §F notes give no line range, so the region cannot be
built mechanically — **check those three by reading, before Task 8 installs.**

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

## The four procedures — and what happened to every condition they replace

**Why this section exists.** Tasks 0 and 15 accumulated guarded shell across ten review passes, and
by pass 21 thirty-nine of the previous fifty findings were in those two tasks, four of the last five
being repairs to guards the previous passes had added. **The reading is not that the guards were
unnecessary** — each closed a real execution gap, and pass 21's own findings are real gaps too. The
reading is that **one shell procedure was being asked to transact every re-entry automatically**,
and that is the thing being dropped. The obligations are not.

**What replaces it:** four short procedures — **preparation, close, failure, resume** — each saying
only *what is checked*, *how success is recognised*, and *what happens on deviation*. The executing
agent observes the actual state and derives the operation. **Concrete shell stays where it is
simple and already verified**; what goes is the branching that tried to handle every state in one
block.

### The accounting — every condition, kept / re-expressed / proposed for deletion

Required before replacing a decision procedure (`AGENTS.md`, "Never replace a decision procedure
without accounting for its old conditions"). Pass 5 is why: a bulk edit that removed the
verification apparatus also removed Task 15's closing block, and nothing noticed until an
independent reader did.

| # | Condition | Disposition |
|---|---|---|
| 1 | Branch is `loop-rule-consolidation` | **kept**, same shell — preparation |
| 2 | Tree clean before the base is recorded | **kept**, same shell — preparation |
| 3 | `ba15e83` is an ancestor of `HEAD` | **kept**, same shell — preparation |
| 4 | The three approved inputs' blobs equal their `ba15e83` versions | **kept, and split by entry**: Preparation compares them **at `HEAD`**, because a first entry has no recorded base; **Resume compares them at `$BASE`**, because a Gate-B fix may legitimately have changed `HEAD`'s copy in a `WIP:` snapshot. An earlier table row claimed Preparation did the base comparison, which it never could |
| 5 | Never overwrite an existing base file | **kept** as an obligation; the shell branch becomes one line of the resume procedure |
| 6 | A pre-existing base is an ancestor of `HEAD` (`merge-base --is-ancestor`) | **kept**, same shell — resume |
| 7 | Only this run's `WIP:` commits lie between base and `HEAD` | **kept as an observation, dropped as a staleness test.** It is the *normal pre-close* topology. Three others are reachable and none makes the base stale: the handoff's rejected commit above the cycle's; `HEAD` at the base with the implementation in the index; and target §A3's accidental non-`WIP` commit or amend mid-cycle. **Staleness is decided by ancestry and by whether the history is this cycle's**, never by a commit subject |
| 8 | `$BASE` persisted to a file; every consumer guards it non-empty | **kept**, and **repaired**: three concrete blocks read it without the guard while this row claimed otherwise — the baseline extraction, Task 10's hook diff, and the first Gate-B call. The guard is in each of them now (pass 22) |
| 9 | The five regions are located by anchor, one hit per pattern per file | **kept**, same shell — preparation |
| 10 | Spans are **derived** from replacement extents, never hand-written | **kept** — the rule, unchanged |
| 11 | Every kept condition lands in exactly one `span` or one `cond` row | **kept** — the coverage assertion, unchanged |
| 12 | Anchors, never absolute line numbers; resolved separately per tree | **kept** — the rule, unchanged |
| 13 | A single-line site uses `grep`, never `sed -n "/x/,/x/p"` | **kept** — the rule, unchanged |
| 14 | Records are tab-separated `base` / `span` / `cond` shapes, `base` first | **kept**, and **extended**: the baseline artifact gains its own `site` shape (pass 21) |
| 15 | Artifacts written through a temp file, renamed after the last record | **kept**, and **repaired**: only the baseline artifact had the construction while this row claimed both did, so an interrupted map could sit at the path Tasks 2 and 14 read. The untouched map is built under a temp name and renamed after its coverage assertion (pass 22) |
| 16 | On re-entry: base line matches, shapes parse, coverage complete — else rebuild | **re-expressed** as the resume procedure, and **corrected**: the completeness predicate now exists for both artifacts rather than only the map (pass 21) |
| 17 | The baseline source is `$BASE` blobs once `WIP:` commits exist | **kept**, same shell |
| 18 | Both baseline sources readable | **kept**, same shell |
| 19 | The baseline covers every inventoried site and is read whole | **kept**, and **strengthened**: per-site literal-uniqueness, escaped anchors and non-empty extraction, as Task 14 already requires (pass 21) |
| 20 | Task 0 commits nothing | **proposed for deletion, and deleted.** It now commits one record — the fragment sweep (pass 21). A validation whose result is not committed cannot be told from one that never ran, and every other reader check in this plan already commits its record |
| 21 | `baseSha` is `$BASE`, never `HEAD^` | **kept** — the rule, unchanged |
| 22 | `headSha` resolved to the full object name at that moment, kept with each branch's result | **kept**, and **extended**: it is persisted, because 8a needs it (pass 21) |
| 23 | A fresh nonce for the Gate-B cycle | **kept** — the rule, unchanged |
| 24 | Each fix is committed before the next review | **kept**, and **widened**: every non-closing pass commits, repair or not (pass 21) |
| 25 | Every affected check re-runs after each fix, mechanical and reader | **kept** — the rule, unchanged |
| 26 | Re-run records are committed before the re-review | **kept** — the rule, unchanged |
| 27 | The complete set re-runs before the candidate final pass | **kept** — the rule, unchanged |
| 28 | Only a clean response against that exact `HEAD` closes | **kept**, and **made checkable**: the reviewed head is recorded, so "that exact `HEAD`" has a value to compare against (pass 21) |
| 29 | Closure-eligible = clean at or above the floor **or** zero-finding | **kept** — the rule, unchanged |
| 30 | The final pass's own findings files are the sole permitted post-review addition | **kept** — the rule, unchanged |
| 31 | The closing message is rebuilt whole; exactly one provenance line and one curve | **kept** — the rule, unchanged |
| 32 | Every owed record is present before the close | **kept** — the rule, unchanged |
| 33 | The dirty set is exactly the final pass's findings files, read from every porcelain record | **kept** as the close procedure's check |
| 34 | The record commit's changed-path set equals those files | **kept** as the close procedure's check |
| 35 | The tree is clean after the record commit | **kept** as the close procedure's check |
| 36 | `HEAD` equals the reviewed tip before the reset | **kept** as the close procedure's check, and **corrected**: the reviewed *head* and the closing *tip* are two values, not one (pass 21). With row 40 dropped the tip is **only** this precondition — nothing resets to it |
| 37 | The closing commit's subject is not a snapshot | **kept** as the close procedure's check |
| 38 | The tree is clean after the close | **kept** as the close procedure's check |
| 39 | 8a and 8b are separate invocations; no `-m` in the closing one | **kept**, and it is why the close procedure names two invocations |
| 40 | Every rejection restores a tip by **mixed** reset, never `--hard` | **DELIBERATELY DROPPED**, by Daniel's decision, and the second of two deletions this table records. **It was never a requirement of the approved spec** — §A says *"re-establish every closure condition against the repository as it now stands"*, which reads the state rather than rewinding it, and a rejected commit at `HEAD` is a legitimate starting point for that reading. It was this plan's own implementation choice, and it had grown restore targets, phase selection, pre- and post-act captures and their own error handling, which four consecutive passes then found defects in. **What replaces it is a bounded handoff**: stop every further mutating action, report the failed step and the observed state, change nothing else. **The obligations §A does impose are unchanged** — surface the failure, re-establish every closure condition against the state as it stands, and take one of its three routes. **Not replaced by a generic backup mechanism**, which would be the same growth under another name |
| 41 | The scratch files are removed only after a successful close | **kept** as the close procedure's last step |

**Two conditions are dropped, 20 and 40, and each is named as a drop rather than lost.** Condition
20 is replaced by a stronger obligation. **Condition 40 is dropped outright** — a guard this plan
introduced itself, which the approved spec never asked for, removed by an explicit decision after
it became the largest single source of findings in the cycle. **A guard the plan invented does not
have to survive on the strength of existing**; what it may not do is take a governing obligation
with it, and §A's three routes, the closure conditions and every evidence duty stand exactly as
before. Six conditions are corrected or extended against pass-21 findings, and
**three rows were themselves wrong when first written** — 8, 15 and 40 claimed "kept, same shell"
for obligations that were not in fact present everywhere. Pass 22 was aimed at exactly that question
and found them; they are repaired rather than re-worded, and the fact that an accounting table can
itself be wrong is why the check was worth running. The rest keep their force; what changes is that a person reads the state and picks the
operation, instead of one block trying to branch through every state in advance.

### The findings the dropped guard carried, reassessed one by one

**Removing a mechanism does not settle the findings raised against it**, so each is judged on
whether it described a duty that survives the removal or only a defect in the removed machinery.

| Finding | Was it about the guard? | Standing |
|---|---|---|
| **23-2** — the restore target was chosen by which tip file existed, rewinding past a second candidate's repair | yes, entirely | **moot.** Nothing restores. The tip survives as 8b's precondition value, and step 7 still clears it between candidates |
| **23-3** — the failure capture covered tracked content only, while the closure inputs are ignored paths | the capture, yes; **the duty, no** | **carried.** The report must name which cycle values still exist rather than assume them, and it says so by listing them |
| **24-2** — "an empty pair means nothing moved", and the checksums had no pre-act baseline | yes, entirely | **moot**, and the underlying error is answered differently: the procedure now refuses to claim anything was preserved at all |
| **24-3** — after a commit lands and then fails, both tracked patches are empty and nothing recorded the rejected `HEAD` | the capture, yes; **the duty, no** | **carried.** The report states whether a commit landed, with `git rev-parse HEAD` and the log, because that is the first thing the resume decision needs |
| **25-1** — `test -e && cksum` in a loop makes the block's status its last iteration | yes, entirely | **moot.** The loop is gone |
| **25-2** — the pre-act capture held no bytes, so a hook rewriting a staged file in place was undetectable | yes as stated; **the honesty duty survives** | **carried, and answered by admission rather than by machinery**: the procedure states plainly that stopping is no guarantee the failed operation destroyed nothing, and forbids reporting that nothing was lost |
| **25-3** — the captures wrote into the worktree they compared | yes, entirely | **moot.** There is nothing to compare |

**Everything else these passes found stands and is owed** — the close-condition ordering, `c1`–`c3`'s
missing observation, Task 0's `cond` fragments bypassing the table, Task 11's count and its sweep
shape, step 5's stale "appends", the evidence-entry revalidation branch, and the cleanup list. None
of them touched this guard.

### Preparation — before any task edits a file

**This procedure is for a FIRST entry, on a clean tree.** A re-entry runs **Resume** instead, which
requires no clean tree and mutates nothing — the handoff's valid topologies include `HEAD` at the
base with the whole implementation **staged**, and an unconditional clean-tree test would make that
state permanently unresumable through this plan's own success path.

**What is checked.** The branch; a clean tree; that `ba15e83` is an ancestor; that the three
approved inputs still hold their approved blobs at the revision the tasks are derived against; and
that **no base file exists yet** — if one does, this is a re-entry and Resume owns it.

```bash
test "$(git rev-parse --abbrev-ref HEAD)" = loop-rule-consolidation || { echo "wrong branch"; exit 1; }
test -z "$(git status --porcelain)" || { echo "tree not clean — if this is a re-entry, run Resume"; exit 1; }
test ! -e .context/loop-rule-base || { echo "a base is already recorded — this is a re-entry, run Resume"; exit 1; }
git merge-base --is-ancestor ba15e83 HEAD || { echo "ba15e83 not in this history"; exit 1; }
for f in target-text design condition-inventory; do
  p="docs/superpowers/specs/2026-09-10-loop-rule-consolidation-$f.md"
  test "$(git rev-parse "HEAD:$p")" = "$(git rev-parse "ba15e83:$p")" \
    || { echo "$p differs at HEAD from its approved version"; exit 1; }
done
```

**How success is recognised.** Every line above exits 0. **No claim is made here about a recorded
base**, because on a first entry there is none — Task 0 step 1 records it immediately afterwards,
and validating it is Resume's job on every later entry.

**On deviation.** Stop. Each of these has a different fix and none of them is "retry": a wrong
branch is a checkout, a dirty tree is a decision about uncommitted work, a differing input blob is
an unapproved edit to a spec that the gates already closed.

### Close — after a closure-eligible pass

**What is checked**, in this order, and these are the conditions rather than a script:

1. **`HEAD` equals the head the candidate pass was issued against** — the value recorded before that
   call, in `.context/loop-rule-reviewed-head`. **That is the reviewed head.** It is not the same
   value as the **closing tip** below, and conflating them is how an unreviewed commit reaches the
   close.
2. **The only thing dirty is the candidate pass's own findings files** — read from every porcelain
   record, not from two status codes. Nothing else may be uncommitted: every record this plan
   collects was committed before the pass was issued.
3. **The closing message is complete** — rebuilt whole, exactly one provenance line, exactly one
   curve, every owed evidence entry, and either the applicable human-exception records or
   `Human exceptions: none`. **This is checked here, before anything moves**, because an incomplete
   message discovered after the record commit leaves `HEAD` moved for a reason no restoration was
   owed for. **And it is re-read and revalidated at 8b, immediately before the commit consumes it**
   — 8a runs a commit in between, hooks can rewrite anything, and the file is under `.context/`,
   which is ignored, so no clean-tree check between the two invocations can see it change. A
   difference or a malformed record there is a Failure handoff, not a repair.
4. **Those files are committed** in their own invocation, and that commit satisfies **three things,
   not one**:
   - it **changes exactly those paths**, and its parent is the reviewed head;
   - **the committed blobs are the validated ones** — the object ids recorded before staging equal
     the ids at `HEAD` afterwards. A path check cannot see this: a hook rewriting a staged file in
     place leaves the pathname untouched, which the plan states elsewhere and must therefore guard
     here;
   - **the committed findings files still satisfy the findings-file structure and still make this
     the eligible logical pass they were judged as** — every line before the terminator a finding
     line, the terminator exact, the count matching, both branch files present, and the
     clean-or-zero-finding reading unchanged. Subject: the committed content. Base: the protocol in
     §5 and the eligibility this candidate was issued on. **Any difference at any of the three is a
     Failure handoff, not a repair.**

   Record the resulting commit as the **closing tip**, in
   `.context/loop-rule-reviewed-tip` — **a precondition value, not a restore target**: 8b refuses to
   reset unless `HEAD` is still exactly it, which is how a commit landing between the two
   invocations is caught. Nothing in this plan resets *to* it.
5. **The tree is clean**, and `HEAD` is still the closing tip, when the closing invocation begins.
6. **After the closing commit**: its subject is not a snapshot, and the tree is clean.

**How success is recognised.** A single commit at `HEAD` whose subject is the real message and whose
parent is `$BASE`. **No tree comparison** — target §I parks a Gate-B tree-equality condition on
Daniel's decision of 2026-09-13, and an earlier draft of this line added one anyway, which would
have made the executor either invent an out-of-scope closure check or declare success without
establishing its own stated predicate. Then, and only then, the scratch
files are removed.

**Two invocations, not one.** `codex-gate.sh`'s `is_wip_commit`
(`plugins/dev-workflow/hooks/codex-gate.sh:763`) tests the **whole command string** against
`-m[[:space:]]*['"]?[[:space:]]*wip`. The findings-file commit carries that pattern; the closing
commit must not share a command string with it, or the hook reads the close as cycle-internal and
carries this cycle's count and fingerprint into the next.

**Which of the six are preconditions and which are postconditions**, because they do not all come
before a move and an earlier draft said they did:

- **1, 2 and 3 are preconditions** — checkable while nothing has moved. **On deviation, stop; no
  restoration is owed**, because nothing was changed. **The message check is among them
  deliberately**: an earlier draft classified it as a precondition while listing it *after* the
  record commit, so a literal executor could find an incomplete message with `HEAD` already moved
  and then stop without restoring.
- **4, 5 and 6 straddle or follow a move** — 4 makes the record commit, 5 reads the state it left,
  6 reads the state after the closing commit. **On deviation, run `## The four procedures` ·
  Failure**, which stops, reports the state and hands over.

**A rejected commit left at `HEAD`, or a live soft-reset index, is a state this plan stops in and
reports** — it is not an error condition the procedure has to undo. §A re-establishes the closure
conditions **against the repository as it now stands**, so that state is a legitimate starting
point for the resume decision, and an earlier draft's claim that "a retry cannot start from it" was
wrong about the approved text.

### Failure — the closing act did not complete

**This procedure stops and hands over. It does not restore, retry or clean up.** That is a decision
about *this* plan, recorded in the accounting table as a deliberate drop, and the reason is that the
approved §A does not ask for automatic restoration: it says **"re-establish every closure condition
against the repository as it now stands"** — read the state, not rewind it. A one-off implementation
plan does not need to grow a general git-recovery mechanism to satisfy that.

**On a failed closing operation, or a failed postcondition after one: stop every further mutating
action.** No reset. No second `git commit`. No deletion of recovery inputs, scratch values or review
artifacts. **Whatever the repository holds is what the resume decision is made from**, and moving it
first is what destroys the evidence that decision needs.

**Then report, and report the state rather than a conclusion about it:**

- **which step failed**, and the concrete command failure — the exit status and the message, quoted;
- **whether a commit landed**: `git rev-parse HEAD`, `git log --oneline -3`, and where a `reset
  --soft` had already run, say so, because the index then holds the whole change;
- **what the tree holds**: `git status --porcelain --untracked-files=all`, `git diff --cached
  --stat`, `git diff --stat`;
- **which cycle values still exist** — the recovery base, the reviewed head, the reviewed tip, the
  closing message — by listing them, not by assuming.

**What stopping does not do, said plainly.** It prevents *further* change; it is **no guarantee that
the failed operation itself destroyed nothing.** A hook that rejected after rewriting a staged file
has already done that, and this procedure cannot undo it or prove it did not happen. **Do not report
"nothing was lost".** Report what is there.

**How success is recognised.** The failure is surfaced with the four observations above, nothing
further has been changed, and the cycle is waiting on a person.

**Resuming is a decision about the actual state**, taken with that report in hand, and then §A's
rules apply unchanged:

- **Every closure condition is re-established against the repository as it now stands.** Where they
  all still hold, **perform the act again**.
- **Where the attempt or its repair moved anything a condition is read from**, that condition has
  changed and **its own rule decides what it costs**, a further pass included, and the cycle is back
  in the ordering with that pass owed.
- **Where the failure cannot be repaired at all** — a signing key nobody has, a permission nobody
  can grant — **surface it and leave the cycle parked**: open, not running, spending no passes,
  restarted by an explicit later continue.

**A person's help replaces neither the review nor the evidence.** Whatever route resume takes, no
closing act happens until every prescribed condition is established again, and the evidence entry
and records the closing commit carries are the ones a pass actually validated.

### Resume — re-entering after an interruption

**Resume owns every entry after the first.** Preparation is first-entry-only and refuses when a base
file exists, so nothing here defers to it: the checks below are Resume's own, and **none of them
requires a clean tree** — three of the four valid topologies need not have one.

**Four topologies, named rather than numbered, and the whole procedure reads against all four.**

| Topology | `HEAD` | `$BASE..HEAD` | Where the work is |
|---|---|---|---|
| **Normal, mid-implementation** | the last `WIP:` snapshot | this run's `WIP:` commits, and possibly a §A3 stray commit or amend | committed |
| **8a rejected, no commit landed** | the last `WIP:` snapshot, unchanged | this run's `WIP:` commits | committed, **plus whatever the failed attempt left in the index or worktree** |
| **8a rejected after its commit landed** | a `WIP:` findings commit **above** the cycle's `WIP:` chain | those commits | committed, **plus any delta the post-commit clean-tree check found** |
| **8b rejected** | either `$BASE` itself, if the closing commit never landed, **or one commit parented by `$BASE`**, if it landed and a postcondition refused it | **empty**, or that one commit — the `WIP:` chain is gone either way, squashed by `reset --soft` | the **index**, or that one commit's tree |

**The 8b row is the one every rule has to be re-read against.** `reset --soft` removes the `WIP:`
chain from the ancestry, so after 8b there is no chain to find; an empty `$BASE..HEAD` there means
the work is staged, not absent. **And the two 8a rows differ from each other**: before its commit
the history is untouched and the delta is loose, after it the findings commit sits above the chain
— pass 31 split them because they need different content reconciliation.

- [ ] **Validate the base — Resume's own checks, not Preparation's**

```bash
test -s .context/loop-rule-base || { echo "no base recorded — this is a first entry, run Preparation"; exit 1; }
BASE=$(cat .context/loop-rule-base)
test "${#BASE}" -eq 40 || { echo "base is not a full 40-character object name"; exit 1; }
case "$BASE" in *[!0-9a-f]*) echo "base is not an object name: $BASE"; exit 1 ;; esac
test "$(git rev-parse --verify "$BASE^{commit}")" = "$BASE" || { echo "base does not resolve to itself as a commit"; exit 1; }
git merge-base --is-ancestor "$BASE" HEAD || { echo "base is NOT an ancestor of HEAD"; exit 1; }
for f in target-text design condition-inventory; do
  p="docs/superpowers/specs/2026-09-10-loop-rule-consolidation-$f.md"
  test "$(git rev-parse "$BASE:$p")" = "$(git rev-parse "ba15e83:$p")" \
    || { echo "$p differs at the base from its approved version"; exit 1; }
done
```

**The approved-input comparison is at `$BASE` here, and at `HEAD` in Preparation.** They are
different revisions on purpose: Task 15 step 7 permits a Gate-B fix to update the spec in a `WIP:`
snapshot, so on a re-entry `HEAD`'s copy may legitimately differ while the revision the tasks were
derived against does not.

**Replace a base only on affirmative evidence it belongs to another run** — it fails one of the
checks above. **Neither a commit subject nor an absence of cycle commits is evidence**: §A3's stray
non-`WIP` commit leaves the base valid, and the 8b topology has an empty range by construction, so
both tests would condemn states this plan calls valid.

- [ ] **Validate the scratch artifacts**

Each by its `base` line **and** its completeness predicate:

- `.context/loop-rule-untouched` — every line parses as `base`, `span` or `cond`, and every kept
  condition in the five regions appears in exactly one `span` or one `cond`.
- `.context/loop-rule-baseline-diff.txt` — every line parses as `base`, a `site` record, or diff
  output belonging to the site above it, and **every inventoried site has a `site` record**.

**On failure the answer depends on why you are here.** Outside a handoff: delete and rebuild from
the `$BASE` blobs — never reuse, never repair in place, because a same-base partial file is the one
shape a `base` line alone cannot catch. **Inside a handoff, while a failed close waits on a person:
report the invalid artifact and change nothing.** Rebuilding it would remove evidence before anyone
chose a §A route. **This plan performs no cleanup after a failure — it does not claim the failed
operation left anything intact.** Enumerate which scratch values actually survive and validate each;
a value is trustworthy because it passed a check, never because cleanup was skipped.

- [ ] **Establish how far the implementation got — against the topology, not against the log**

**Read the content, not only the commits.** In the normal and the two 8a topologies that is the
commits between `$BASE` and `HEAD`, **plus whatever the failed attempt left loose**. **In the 8b
topology it is `git diff --cached "$BASE"`** — the staged tree, plus the landed closing commit's
tree where one exists. A ticked checkbox is confirmed by the change
being *present in that content*, wherever the content lives.

```bash
git log --oneline "$BASE"..HEAD     # empty in the 8b topology; that is not an empty cycle
git diff --cached "$BASE"           # the staged content — the FULL diff, not --stat
git diff                            # the unstaged content
git status --porcelain --untracked-files=all
```

**Read all three, in every topology.** `git status` names paths and says nothing about what is in
them, and `--stat` counts lines. **The delta that caused an 8a handoff is precisely the one a
path listing cannot describe** — a rewritten staged file keeps its name — so reconcile against
`HEAD`, the index and the worktree **contents** together, whichever topology you are in.

**A task whose checkbox is ticked but whose change is in neither place was not completed** — and one
whose change is present with the box unticked is completed. **Deciding from the commit log alone
reads the 8b topology as an untouched cycle and invites every edit to be made twice.**

**How success is recognised.** The base passes Resume's own checks; the artifacts match it and are
complete, or are reported as invalid and left alone; and the plan's task list has been reconciled
against the content the topology actually holds.

**Steps that describe the tree at `$BASE` are validated on re-entry, not re-run against the
worktree.** After a text task the worktree carries this plan's own edits, and rebuilding the
baseline from it would fold introduced drift into the inherited-drift record — the one distinction
Task 14 depends on.

Story acceptance criterion 5 is satisfied here. Ids are `docs/superpowers/specs/2026-09-10-loop-rule-consolidation-condition-inventory.md`, snapshot at `7c0d475`. **Where the tree and the inventory disagree, the tree wins and the accounting is what needs correcting** — check each condition against the real file before marking it done.

### What each disposition owes, stated once

**A disposition is not a label; it names the observation that condition is owed.** Every task below
consults this table rather than restating it, and **a condition whose check does not match its
disposition is a defect in one of the two** — four consecutive passes found one, each time in a
different passage, because each task was inventing the rule for its own conditions.

| Disposition | The observation it owes |
|---|---|
| **kept** | **exactly one of three routes**, never two and never none: inside an untouched span; **or** its own per-condition count, `parent=1 worktree=1` in each copy, where it shares a line with changed text; **or** that same per-condition count where **no untouched span reaches its passage at all** — Task 0 maps five regions, and passages (b), (c), (e) and (i) are not among them, so every kept condition there takes this third route. |
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

**Files:**
- Modify: `docs/superpowers/plans/2026-09-14-loop-rule-consolidation.md` — the fragment sweep record (step 4)

**Interfaces:**
- Produces: `$BASE` (the parent commit every later task's counterfactual half runs against), and the five untouched passage ranges recorded as **anchor spans plus a per-condition fragment list** — never as absolute line numbers, for the reason step 2 gives.

- [ ] **Step 1: Decide which entry this is, then run that procedure**

**The base file decides it, and nothing else does:**

```bash
if [ -s .context/loop-rule-base ]; then
  echo "base recorded — this is a RE-ENTRY: run Resume, not Preparation"
else
  echo "no base — this is a FIRST ENTRY: run Preparation, then record the base below"
fi
```

**First entry.** `## The four procedures` · Preparation holds the checks and the shell: branch,
clean tree, no base file, `ba15e83` an ancestor, and the three approved inputs compared by blob **at
`HEAD`** — which is the revision the tasks are about to be derived against. Then record the base,
**and never overwrite one you did not just write**:

```bash
git rev-parse HEAD > .context/loop-rule-base
BASE=$(cat .context/loop-rule-base)
# Not "non-empty": a symbolic value such as HEAD passes every check below and
# then RESOLVES DIFFERENTLY as WIP commits accrue, moving the reviewed range,
# the parent counts and the final reset with the branch.
case "$BASE" in [0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f]*) ;; *) echo "recorded base is not an object name: $BASE"; exit 1 ;; esac
test "${#BASE}" -eq 40 || { echo "recorded base is not a full 40-character object name"; exit 1; }
test "$(git rev-parse --verify "$BASE^{commit}")" = "$BASE" || { echo "recorded base does not resolve to itself as a commit"; exit 1; }
```

**Re-entry.** `## The four procedures` · Resume validates the existing base, the scratch artifacts
and how far the implementation got — with its own checks, against all four topologies, and without
requiring a clean tree. **Do not run Preparation on a re-entry**: it refuses as soon as it sees the
base file, which is exactly what makes this branch reachable.

**Re-running Task 0 after a partial implementation must not re-record the base.** It would capture
the current WIP tip, and both Gate B's range and the final reset would then start *after* every edit
made so far — prompt and hook changes squashed into the closing commit without entering a review
range. The branch above is what prevents it: a recorded base sends this task to Resume, which
validates and never overwrites.

**Persist it to a file, not to a shell variable.** Each fenced block runs in its own shell
invocation, so a `BASE=` assignment here is gone by the next task and every parent-tree count would
run against an empty revision — which fails loudly in `git show` but quietly in a `grep -c`
pipeline. Every later task that counts anything reads it back and refuses an empty value:

```bash
BASE=$(cat .context/loop-rule-base)
test -n "$BASE" || { echo "BASE empty — Task 0 did not run"; exit 1; }
```

**The guard is not decoration.** With `$BASE` empty, `git show ":$f"` reads the *index* rather than
the recorded parent, and every parent count then describes the wrong tree without erroring.

**This commit is also `baseSha` for Gate B.** It is the parent of the first WIP snapshot, and the
only value that puts the whole implementation inside the reviewed range. `.context/` is ignored by
the hook's fingerprint, so the file itself moves nothing.

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

**`.context/loop-rule-untouched` holds a mandatory `base` header line plus two payload shapes — three
line forms in all, and every one parseable**, because Tasks 2
and 14 consume them without a human in between. A file whose second half has no schema is a file
its consumers skip, which is what the per-condition list exists to prevent:

```
base<TAB><the 40-character object name this map was built from>
span<TAB><start anchor><TAB><end anchor><TAB><file>
cond<TAB><condition id><TAB><P id><TAB><file><TAB><expected parent><TAB><expected worktree>
```

Tab-separated, one record per line, the leading keyword distinguishing them. **The `base` line is
first and there is exactly one**, so a re-entry can tell this run's map from an abandoned run's. A kept condition's
expected pair is `1<TAB>1`; the shape carries the values rather than assuming them, so a moved or
dropped condition recorded here later needs no new format. **Both consumers validate every `cond`
row**, not only the `span` rows.

**The fragment itself lives in the fragment table, and the map's row carries only its `P` id** —
that is the `<P id>` field above, and both consumers resolve the text by looking the row up there.
**The map never stores the fragment text**, because two copies of an authored fragment is the
second-copy defect this cycle spent most of its findings on. Append the row to the table first,
under the next free `P` id, then write the `cond` line citing it. The table is where every pre-existing fragment lives, and Task 0
step 4's committed sweep runs the three conditions over **table rows** — a fragment that exists only
in this ignored scratch file is outside that sweep, so a wrong one could certify a kept condition
and be reused after an interruption on the strength of parsing and coverage alone.

**Build the map under `.context/loop-rule-untouched.tmp` and rename it only after the coverage
assertion passes.** The baseline artifact is written that way and accounting row 15 claims both are;
an earlier draft wrote this one straight to its consumer path, so an interruption between the `base`
line and the last `cond` row left a same-base partial map at exactly the path Tasks 2 and 14 read.
**The rename is the last operation**, after every `span` and `cond` row is written and every kept
condition is assigned — which is the same completeness predicate the resume procedure re-checks.

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

**Read both copies from the source the re-entry rule selects, not from the worktree unconditionally.**
On a clean first run they are the same; once `$BASE..HEAD` is non-empty the worktree carries this
plan's own edits, and comparing them would fold introduced drift into the inherited-drift record —
after which Task 14 can no longer tell the two apart, which is the whole purpose of this baseline.

**Selection, the `base` line and every extraction are ONE shell block**, because each fenced block
is its own invocation: `C_SRC` set in one block and consumed in the next is empty by the time
`sed` and `grep` see it, and a process substitution reading an empty filename need not make `diff`
fail — so the step would append its headings over two empty extracts and certify a parity baseline
it never computed. **This is the same defect as `$BASE` and `$BASEREF`**, and those two are
persisted to files for exactly this reason; here one block is simpler than a third scratch file.
The `test -r` guard makes an unreadable source fatal rather than silent.

**The artifact has a schema, because the resume procedure validates it.** One `base` line, then one
`site<TAB><start><TAB><end>` record per inventoried site followed by that site's diff output —
**every site gets a record, including one that compared equal**, which is what makes a site missing
from the run distinguishable from a site that matched. Without it the resume procedure has a
completeness predicate for the map and none for this file, and a same-base partial baseline reads as
complete.

**And the loop is not piped to `tee`.** A failure inside a pipeline does not reliably stop the
script, so a partial temporary file could be promoted by the `mv`. Each site appends directly and
exits on failure; the rename is the last statement.

```bash
BASE=$(cat .context/loop-rule-base)
test -n "$BASE" || { echo "BASE empty or unreadable — Task 0 did not run"; exit 1; }
if [ -n "$(git log --oneline "$BASE"..HEAD)" ]; then
  git show "$BASE:CLAUDE.md" > .context/loop-rule-c.src
  git show "$BASE:plugins/dev-workflow/commands/workflow-init.md" > .context/loop-rule-w.src
  C_SRC=.context/loop-rule-c.src; W_SRC=.context/loop-rule-w.src
else
  C_SRC=CLAUDE.md; W_SRC=plugins/dev-workflow/commands/workflow-init.md
fi
test -r "$C_SRC" && test -r "$W_SRC" || { echo "baseline source unreadable"; exit 1; }
printf 'base\t%s\n' "$BASE" > .context/loop-rule-baseline-diff.tmp   # renamed at the end

# Tab-separated start and end anchors, written as LITERAL text — the escaping
# for sed happens later, on $se and $ee. Emitting '\*\*Severity:\*\*' here would
# store backslashes that occur in neither copy, and the literal-uniqueness
# check below would then fail at that site on a correct tree.
# Two fields per call so the tab is the format's, not the data's: the anchors
# contain colons, so a colon delimiter would split '**Severity:**' at the
# wrong one. Every entry spans two DIFFERENT anchors — the single-line
# squash-carry site is handled below, not in this loop.
: > .context/loop-rule-sites
while IFS= read -r s && IFS= read -r e; do
  printf '%s\t%s\n' "$s" "$e" >> .context/loop-rule-sites
done <<'SITES'
Both gates are a LOOP
Nothing here writes the floor knob
What a loop absorbs
Recognizing "clearly stuck"
Recognizing "clearly stuck"
Every pass report states
From pass 4 onward
Those three lines expose
Those three lines expose
The two rules above
The two rules above
Findings go to a FILE
**Severity:**
**Tool routing:
Recording a human exception
because writing it down makes it sound
When these rules bind
Downstream has no shipping commit
SITES
# Each site: the same checks Task 14 applies — literal uniqueness per copy, an
# ESCAPED anchor (a derived anchor carries ** and / and . and is a regex to sed),
# and a non-empty extract. Two empty extracts diff equal and would certify a
# site sed never found. Failures exit; the rename happens only at the end.
while IFS=$(printf '\t') read -r s e; do
  for f in "$C_SRC" "$W_SRC"; do
    test "$(grep -cF "$s" "$f")" = 1 || { echo "start anchor not unique in $f: $s"; exit 1; }
    test "$(grep -cF "$e" "$f")" = 1 || { echo "end anchor not unique in $f: $e"; exit 1; }
  done
  se=$(printf '%s' "$s" | sed 's/[][\.*^$\/]/\\&/g')
  ee=$(printf '%s' "$e" | sed 's/[][\.*^$\/]/\\&/g')
  a=$(sed -n "/$se/,/$ee/p" "$C_SRC"); b=$(sed -n "/$se/,/$ee/p" "$W_SRC")
  test -n "$a" && test -n "$b" || { echo "empty extraction for: $s"; exit 1; }
  # diff exits 0 (same) or 1 (differs) — both are RESULTS. Above 1 is a failure
  # to compare, and writing the site record before classifying would certify a
  # comparison that never completed.
  d=$(diff <(printf '%s\n' "$a") <(printf '%s\n' "$b")); st=$?
  test $st -le 1 || { echo "diff failed (status $st) at site: $s"; exit 1; }
  printf 'site\t%s\t%s\n' "$s" "$e" >> .context/loop-rule-baseline-diff.tmp
  printf '%s\n' "$d" >> .context/loop-rule-baseline-diff.tmp
done < .context/loop-rule-sites || exit 1

# The squash-carry sentence is ONE line and must not go through the loop.
d=$(diff <(grep -F 'On squash-merge, copy every evidence entry' "$C_SRC") \
         <(grep -F 'On squash-merge, copy every evidence entry' "$W_SRC")); st=$?
test $st -le 1 || { echo "diff failed (status $st) at the squash-carry site"; exit 1; }
printf 'site\t%s\t%s\n' 'On squash-merge' 'On squash-merge' >> .context/loop-rule-baseline-diff.tmp
printf '%s\n' "$d" >> .context/loop-rule-baseline-diff.tmp
mv .context/loop-rule-baseline-diff.tmp .context/loop-rule-baseline-diff.txt
cat .context/loop-rule-baseline-diff.txt      # READ IT WHOLE
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

- [ ] **Step 4: Re-check every fragment row, record the result, and commit it**

**This is the sweep the fragment-table section orders, and it had no home.** Run all three
conditions over every row the tables now hold — single-line, unique in the copies the row claims,
and the class-specific relationship to its own replacement — and **write the result under
`## Fragment sweep (Task 0 output)`** at the end of this plan: the revision it ran at, one line per
row, and the reading result for `F1`, `F2` and `F3`, whose §F notes give no line range so their
region cannot be built mechanically.

```bash
git add docs/superpowers/plans/2026-09-14-loop-rule-consolidation.md
git commit -m "WIP: fragment sweep at the recorded base"
```

**Task 0 used to commit nothing, and that is the one condition this change drops.** A validation
whose result is not committed cannot be told from one that never ran — the same rule Task 12b's
sweep and Task 15's prompt-standards result already follow — and every later task consumes these
rows on the strength of it. The commit is `WIP:` like every other snapshot in this cycle, so it is
inside Gate B's range and inside the final reset.

**The scratch files stay in `.context/` and stay ignored.** `.gitignore` carries `.context/*`, so
`loop-rule-base`, `loop-rule-untouched`, `loop-rule-baseline-diff.txt` and the `.src` copies are
working state, not deliverables; only the sweep record is committed.

---

## Task 1: Install the closure ordering (§A) into both copies

**Files:**
- Modify: `CLAUDE.md` — insert immediately before the line beginning `**What a loop absorbs, and what stops it`
- Modify: `plugins/dev-workflow/commands/workflow-init.md` — the same anchor
- Modify: `docs/superpowers/plans/2026-09-14-loop-rule-consolidation.md` — this task's fragment evidence
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
for f in CLAUDE.md plugins/dev-workflow/commands/workflow-init.md; do
  n=$(grep -cF 'How a cycle ends — one ordering, stated here and referenced everywhere else' "$f"); st=$?
  test $st -le 1 || { echo "grep failed (status $st) on $f"; exit 1; }
  test "$n" = 0 || { echo "$f already carries the block ($n hits) — stop and reconcile"; exit 1; }
done
```

Expected: zero hits in both, and the block above says so as a **predicate**. **A bare `grep -c`
would not**: it prints `0` and **exits 1** on no match, so the expected result would surface as a
failed shell step. The same shape is used at Task 6 step 4 and Task 11 step 5, which are the other
two places this plan asserts an absence.

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

**The plan is staged here because this task writes its fragment evidence into the plan**, and the
rule is stated by behaviour rather than by a list of task numbers: **every task that appends a
fragment-table row or records an observation in `## Fragment evidence (per-task output)` stages
this plan in its own commit.** On the current shape that is every editing task, Tasks 1 and 3–11,
but the rule is the behaviour and a task that stops recording stops owing it.

**A task-number list here was wrong twice** — it named Tasks 3, 4, 6, 7 and 8 while Tasks 5, 9, 10
and 11 also record — and a stale list is the same defect as a stale count. **The cost of the
omission is concrete:** the evidence stays dirty after the task commits, so Task 0's re-entry path,
which requires a clean tree, cannot be used after an interruption; and if execution continues, that
task's evidence is swept into a later unrelated commit rather than the independently reviewable
snapshot this plan promises.

Named `WIP:` because Task 15 runs Gate B over the whole change and closes it with **one
`git reset --soft "$BASE"` and a single commit**, per the Global Constraints and Task 15 step 8 —
not with an amend, which is the Mechanics shape for a cycle carrying one snapshot and this plan
makes one per task. A non-`WIP` commit here would reset the hook's Gate-B counters mid-cycle.

---

## Task 2: Verify the untouched passages are still untouched

**Files:** none modified — this task verifies and records nothing of its own; Task 14 step 4b re-runs both lists after the last text edit and records the results.

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
- Modify: `docs/superpowers/plans/2026-09-14-loop-rule-consolidation.md` — the rows this task appends and its fragment evidence
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
git add CLAUDE.md plugins/dev-workflow/commands/workflow-init.md \
        docs/superpowers/plans/2026-09-14-loop-rule-consolidation.md
git commit -m "WIP: replace passage (b) with the absorb paragraph that owns the fix set"
```

---

## Task 4: Replace passage (c)'s third condition and its two following sentences with §C

**Files:**
- Modify: `CLAUDE.md` — the passage beginning `**Recognizing "clearly stuck"`
- Modify: `plugins/dev-workflow/commands/workflow-init.md` — the same
- Modify: `docs/superpowers/plans/2026-09-14-loop-rule-consolidation.md` — the rows this task appends and its fragment evidence
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
`c18`-and-surfacing block and whose conditions Task 7 derives.

**Plus the passage's kept prefix, which belongs to no block and would otherwise belong to no task.**
`c1`–`c3` sit before this task's replacement, passage (c) is not one of Task 0's five untouched
regions, and Task 7's blocks start later — so the curve-reading premises fall between two boundaries
and end up with no observation at all. **The task that opens a passage carries that passage's kept
prefix**, and this is that task: derive one preservation fragment per condition and run it
`parent=1 worktree=1` in each copy. **Step 5's walk is not that observation** and says so. Without
these a mis-scoped edit can alter the curve or coverage sentences identically in both copies while
every pair, preservation count and parity check passes. Passage (c) is edited by two tasks;
walking the whole passage here makes this task append rows it cannot discharge after its own
install, and makes both tasks append a row for the same condition. Derive each from the live text
now and append it under the next free `P` id, referring to the rows afterwards by the condition
they observe, never by a number picked here: Task 3 appends first and how many rows it adds is
decided at execution.

**Two things about passage (c) that the class alone does not tell you:**

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

| Edit | OLD | NEW, from the installed destination text — §C here, §A where the row says so |
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

Every row step 1 appended that is not a pair — the carried conditions, the kept ones taking the
table's third route, and `c9`'s plateau rationale — each to the result its class owes. **None of
them is observed by a pair**, which is why they are a step of their own rather than left to the
walk. **Read the set off the disposition table's rows for this task's block**, not from a list.

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
git add CLAUDE.md plugins/dev-workflow/commands/workflow-init.md \
        docs/superpowers/plans/2026-09-14-loop-rule-consolidation.md
git commit -m "WIP: widen the clearly-stuck third condition and split its precedence sentence"
```

---

## Task 5: Replace `e7` and add the pointer (§D) in both copies

**Files:**
- Modify: `CLAUDE.md` — the paragraph beginning `Those three lines expose`
- Modify: `plugins/dev-workflow/commands/workflow-init.md` — the same
- Modify: `docs/superpowers/plans/2026-09-14-loop-rule-consolidation.md` — the rows this task appends and its fragment evidence
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
- **`e11` is C-only**, which is its recorded divergence, so its preservation count is expected in
  C and not in W. Every other kept condition in passage (e) takes the same route as any kept
  condition in a passage no span reaches — the disposition table's third route — and this task
  lists none of them by id.

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
git add CLAUDE.md plugins/dev-workflow/commands/workflow-init.md \
        docs/superpowers/plans/2026-09-14-loop-rule-consolidation.md
git commit -m "WIP: read the two-tell threshold after the clean-completion branch"
```

---

## Task 6: Replace Mechanics · Severity's resolve duty and the handed-over question with §E

**Files:**
- Modify: `CLAUDE.md` — the `**Severity:**` bullet and the `How this demotion bears` paragraph
- Modify: `plugins/dev-workflow/commands/workflow-init.md` — the same
- Modify: `docs/superpowers/plans/2026-09-14-loop-rule-consolidation.md` — the rows this task appends and its fragment evidence
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
n=$(grep -c '2026-08-29-loop-rule-consolidation-story.md' CLAUDE.md); st=$?
test $st -le 1 || { echo "grep failed (status $st)"; exit 1; }
test "$n" = 0 || { echo "g4 still present in CLAUDE.md ($n hits)"; exit 1; }
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
git add CLAUDE.md plugins/dev-workflow/commands/workflow-init.md \
        docs/superpowers/plans/2026-09-14-loop-rule-consolidation.md
git commit -m "WIP: answer the demotion question and scope the resolve duty to the fix set"
```

---

## Task 7: Install §G and §H's replacements in both copies

**Files:**
- Modify: `CLAUDE.md`, `plugins/dev-workflow/commands/workflow-init.md`
- Modify: `docs/superpowers/plans/2026-09-14-loop-rule-consolidation.md` — the rows this task appends and its fragment evidence
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

**Passage (i) is not one of Task 0's five regions**, so its kept conditions take the disposition
table's third route — a per-condition preservation count — and `i3` additionally shares its sentence
with the dash-delimited list this task replaces. Both facts follow from the table; neither needs an
id list here.

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

**Then run everything step 1b added, and that is four kinds, not one:**

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

**The set is every condition the disposition table marks *carried* inside this task's ten blocks**,
and it is read from there rather than listed here. An earlier draft named three of them and left
the rest to P8 and P16, which observe the *changed* clauses around them and prove nothing about the
reproduced words: both copies could omit the surfacing premise, or any interior item of the
strict-reading run, and every pair, presence check and parity comparison would still pass.

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
git add CLAUDE.md plugins/dev-workflow/commands/workflow-init.md \
        docs/superpowers/plans/2026-09-14-loop-rule-consolidation.md
git commit -m "WIP: install the one-contract paragraph and the remaining prompt-copy replacements"
```

---

## Task 8: Replace §F's items 1–9 in both copies

**Files:**
- Modify: `CLAUDE.md`, `plugins/dev-workflow/commands/workflow-init.md`
- Modify: `docs/superpowers/plans/2026-09-14-loop-rule-consolidation.md` — the rows this task appends and its fragment evidence
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
git add CLAUDE.md plugins/dev-workflow/commands/workflow-init.md \
        docs/superpowers/plans/2026-09-14-loop-rule-consolidation.md
git commit -m "WIP: replace the fourteen falsified sentences in the two prompt copies"
```

---

## Task 9: Replace §F's items 14 and 18

**Files:**
- Modify: `CLAUDE.md` — the Named residual paragraph (§5), and the work-loop line (§4)
- Modify: `plugins/dev-workflow/commands/workflow-init.md` — the same two
- Modify: `docs/superpowers/plans/2026-09-14-loop-rule-consolidation.md` — the rows this task appends and its fragment evidence
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
git add CLAUDE.md plugins/dev-workflow/commands/workflow-init.md \
        docs/superpowers/plans/2026-09-14-loop-rule-consolidation.md
git commit -m "WIP: correct the Named residual's blanket exemption and the work-loop sequence"
```

---

## Task 10: Replace the seven hook reminder strings

**Files:**
- Modify: `plugins/dev-workflow/hooks/codex-gate.sh`
- Modify: `docs/superpowers/plans/2026-09-14-loop-rule-consolidation.md` — the eight appended rows and this task's fragment evidence

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
test -n "$BASE" || { echo "BASE empty or unreadable — Task 0 did not run"; exit 1; }
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
git add plugins/dev-workflow/hooks/codex-gate.sh \
        docs/superpowers/plans/2026-09-14-loop-rule-consolidation.md
git commit -m "WIP: replace the seven gate reminders the ordering falsifies"
```

---

## Task 11: Sweep `codex-gate.test.sh` for every assertion naming a replaced string

**Files:**
- Modify: `plugins/dev-workflow/hooks/codex-gate.test.sh`
- Modify: `docs/superpowers/plans/2026-09-14-loop-rule-consolidation.md` — this task's fragment evidence

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

**Read what you observe; do not record a count.** The numbers above are evidence for why no list is kept, not a target — and §F states no count of these assertions **anywhere**, having twice named one and been wrong. This task stages the plan like every other recording task, so a count written into its evidence would be exactly the second numeric authority the approved design rejects: durable, and false the next time the file grows an assertion. **Record the sites examined and what each became**, which stays true however many there are.

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
n=$(grep -c 'Gate B satisfied\|Gate B not satisfied\|Gate A satisfied' plugins/dev-workflow/hooks/codex-gate.test.sh); st=$?
test $st -le 1 || { echo "grep failed (status $st)"; exit 1; }
test "$n" = 0 || { echo "gate-verdict vocabulary survives ($n hits)"; exit 1; }
grep -ni 'satisfied' plugins/dev-workflow/hooks/codex-gate.test.sh || true   # every hit disposed of in writing
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
git add plugins/dev-workflow/hooks/codex-gate.test.sh \
        docs/superpowers/plans/2026-09-14-loop-rule-consolidation.md
git commit -m "WIP: move every hook assertion that names a replaced reminder string"
```

---

## Task 12: The `b11`/`b13` equivalence check

**Files:**
- Modify: `docs/superpowers/plans/2026-09-14-loop-rule-consolidation.md` — the `b11`/`b13` equivalence result (step 5), and the copies only if the check fails.

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

**Files:**
- Modify: `docs/superpowers/plans/2026-09-14-loop-rule-consolidation.md` — the divergence list, the site results, and this task's fragment evidence
- Modify, where an alignment is needed: `CLAUDE.md`, `plugins/dev-workflow/commands/workflow-init.md`

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
  diff .context/loop-rule-a.txt .context/loop-rule-b.txt; st=$?
  test $st -le 1 || { echo "diff failed (status $st) at site: $s"; exit 1; }
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
- Modify: `docs/superpowers/plans/2026-09-14-loop-rule-consolidation.md` — the prompt-standards result and every re-run record

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
this change touches. **Read the installed §A–§H text in C, in W, and the ten hook prompt bodies —
seven `additionalContext` and three `systemMessage` — against
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
**human-exception record** belong beside it. **Step 7b rebuilds the complete message whole** —
provenance line, curve, any human-exception record or `Human exceptions: none`, and the revalidated
evidence entry — **and does not append to this draft.** This step opens the file, step 7b replaces
it, and step 8 commits it. **"Appends" was the earlier wording and it is the opposite of what 7b
requires**: on a second candidate close, appending writes a second provenance line and a second
curve, which the one-of-each grammar refuses.

It names: the battery run; **every pair this plan built, with its counts in each copy and each tree, every presence check beside them, and every absence check with its two counts**; the §6 parity diff and the `b11`/`b13` equivalence result; and the next-state table's location plus its row count.

**Each of those is read from the section that actually holds it**, and they are not one place:
`## Fragment evidence (per-task output)` for the pairs, presence and absence counts;
`## b11/b13 equivalence (Task 12 output)` for the equivalence result;
`## Divergence list (Task 14 output)` for the parity outcome;
`## Next-state table (Task 13 output)` for the table and its row count;
`## Completeness sweep (Task 12b output)` and `## Prompt-standards result (Task 15 step 4b output)`
for those two reader records. **An entry assembled from one section would silently drop whatever
the other five hold.**

**Every record shape belongs in the entry, not only pairs and presence.** A **dropped**
condition's absence and a **moved** condition's absence are what prove an obsolete instruction was
removed; a **carried** or span-less **kept** condition's preservation count is what proves
reproduced text survived. An entry listing only pairs and presence claims the verification set
while omitting both. **Read the set off the disposition table and the fragment evidence, not from
an enumeration here** — an id list in this step was already stale once, naming `a18`–`a20` after
`a17` had joined them.

**State the §A presence checks as presence, not as pairs** — its counterfactual is absent and is claimed as absent.

- [ ] **Step 6: Run Gate B**

```bash
BASE=$(cat .context/loop-rule-base)                     # the parent of the FIRST WIP, from Task 0
test -n "$BASE" || { echo "BASE empty or unreadable — Task 0 did not run"; exit 1; }
git rev-parse HEAD > .context/loop-rule-reviewed-head   # the head THIS call is issued against
cat .context/loop-rule-reviewed-head
```

**Every Gate-B call records the head it is issued against, this first one included**, and step 7
rewrites the file before each later call. It is what makes "a clean response against that exact
`HEAD`" a comparison rather than a claim: without it the close procedure has nothing to hold `HEAD`
up against, and a commit landing after the response is indistinguishable from the reviewed state.

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

**Every pass that does not close ends the same way, whether or not it produced a repair — and it
ends in two steps, in this order.** First record the pass. Then **run it through the ordering this
change installs, and only its continue result prepares another call.** The plan must not execute a
loop its own product forbids.

**Step one — record the pass. This commits; it does not authorize anything.**

```bash
# Before committing a fix, re-run what the fix could have broken.
git add -A && git commit -m "WIP: fix <finding>"        # or: "WIP: pass <n> records" where no repair was owed
```

**Step two — read the pass against the ordering, before any next call exists:**

- **A source block standing** → **wait** for the repair and the reread by the route §A gives. No
  further pass until that is done.
- **Any suspension open** — a membership stop, a new-question stop, a two-tell stop, a clearly-stuck
  surface — → **collect every answer and compose them.** Another pass only where the composition
  yields **continue**.
- **A stop answer** → **park**: open, not running, **spending no passes**, restarted only by an
  explicit later continue. **There is no "commit and carry on" from a stop**, and acceptance
  criterion 4 requires that parked state to be distinct. **Nothing below runs on this route.**
- **The clean-completion branch** → **Close**, not another pass.
- **Continue** → and only then:

```bash
rm -f .context/loop-rule-reviewed-tip                   # the previous candidate's closing tip
git rev-parse HEAD > .context/loop-rule-reviewed-head   # the head the NEXT call is issued against
cat .context/loop-rule-reviewed-head
```

**The reviewed-head file is written on the continue route alone**, because writing it is what makes
a next call possible: recording it before the ordering has spoken is how a pass gets issued over a
standing source block, an unanswered suspension or a parked cycle.

**A non-closing pass that owes no repair still commits.** A Minor-only clean pass below the floor,
or an answered suspension that changes no artifact, leaves its findings files tracked and dirty —
and the next pass's files pile up beside them, after which the close procedure's dirty-set check can
never equal one pass's two files and a route the installed ordering requires cannot close through
this plan. **There is no "nothing to commit" branch here**: the findings files are always something.

**The recorded head is what makes "a clean response against that exact `HEAD`" checkable.** Resolved
and written before the call, it is the value the close procedure compares against — without it,
a commit landing after the response is indistinguishable from the reviewed state.

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
- **One thing cannot exist before that pass: the pass's own findings files.** A `full` Gate-B pass
  writes **two** — the spec and quality branch files — and the close's dirty-set check requires both,
  so the **pair** is the sole permitted post-review addition, and step 8 asserts that it is the only
  one — every other
  path must already be in the reviewed `HEAD`. `.context/` moves none of the hook's fingerprint
  inputs, so the file changes nothing the review looked at; what would be wrong is a *second*
  delta riding along beside it.

- [ ] **Step 7b: After the clean pass, complete `.context/loop-rule-closing-msg` — this is the
  action step 5 defers to, and step 8 has no other source for these records**

**Rebuild the file whole, do not append to it.** Step 5 opened it with a draft entry. **Appending on
re-entry writes a second provenance line and a second curve**, which breaks the one-of-each grammar
Mechanics pins, or leaves a stale curve standing beside the current one.

**After a failed closing act, inspect this file before trusting it, and rebuild it from the current
records.** The handoff changes nothing, but it **does not claim the failed operation left the file
as it was** — a hook can rewrite anything before failing — so "the failure preserves it" is not a
statement this plan can make.

**And a failed act does not by itself owe a further pass.** §A retries the act where every closure
condition still holds; a pass is owed only where the attempt or its repair moved something a
condition is read from, **and that condition's own rule is what decides.** An earlier draft required
a fresh final pass unconditionally here, which forces a review §A does not ask for. Write the complete message from the current records at every candidate close, then
assert **exactly one** provenance line and **exactly one** curve for this cycle before step 8.

The message carries, in this order:

1. the **provenance line**, in the form Mechanics pins — the Gate-B cycle's nonce, the derived
   floor, the cited set with each member's level, and the workspace knob;
2. the **per-pass curve** for this Gate-B cycle, `<CYCLE-FIELD>; Gate B (passes …): Findings …
   Blockers … Majors …`, which is why this cannot be written at step 5: the counts do not exist
   until the loop ends;
3. any **human-exception record**, and beside it the skip reason if a cycle was skipped;
4. the **revalidated evidence entry**, replacing step 5's draft if revalidation changed it — and
   **if it changed, this candidate is over.** The final reviewer judged the entry it was handed
   verbatim; a different entry in the closing commit is evidence no pass covered. Commit the change,
   resolve and record the new head, and issue another candidate pass. **Revalidate before recording
   the candidate head and issuing the pass**, so that in the ordinary case this branch is never
   reached.

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

- [ ] **Step 8: Close the cycle — the close procedure, in two invocations**

**Run `## The four procedures` · Close.** It states the six checks, what success looks like, and why
the two invocations are separate. What follows is the shell that is simple and already verified;
**the checks are the obligation and the shell is one way to run them** — where the observed state is
not one this shell expects, read the state and pick the operation, rather than extending the block.

**8a — record the candidate pass's findings files.**

```bash
BASE=$(cat .context/loop-rule-base)
HEADREV=$(cat .context/loop-rule-reviewed-head)
test -n "$BASE" && test -n "$HEADREV" || { echo "BASE or reviewed head missing"; exit 1; }
test "$(git rev-parse HEAD)" = "$HEADREV" || { echo "HEAD is not the head the candidate pass was issued against"; exit 1; }

# Exactly this pass's two slot paths, from the values the call was built from.
NONCE=<this cycle's nonce>; P=<the candidate pass number>
FINAL=".context/codex-reviews/gate-b-spec-$NONCE-pass-$P.md .context/codex-reviews/gate-b-quality-$NONCE-pass-$P.md"
expected=$(printf '%s\n' $FINAL | sort)
actual=$(git status --porcelain -z | tr '\0' '\n' | sed -n 's/^.\{3\}//p' | sed '/^$/d' | sort)
test "$expected" = "$actual" || { echo "dirty set is not exactly this pass's findings files:"; git status --porcelain; exit 1; }

# Pin the validated content BEFORE staging: a hook can rewrite a staged file in
# place, leaving its pathname — and therefore the changed-path check — unchanged.
for f in $FINAL; do git hash-object "$f"; done > .context/loop-rule-final-blobs
# shellcheck disable=SC2086
git add $FINAL
# Any rejection below stops and goes through the Failure procedure, which reports
# the state and hands over. Nothing here resets, retries or deletes.
git commit -m "WIP: Gate-B findings files" || { echo "record commit FAILED — stop here and run Failure"; exit 1; }
test "$(git show --name-only --pretty=format: HEAD | sed '/^$/d' | sort)" = "$expected" \
  || { echo "record commit changed paths beyond this pass's findings files — stop here and run Failure"; exit 1; }
test "$(git rev-parse HEAD^)" = "$HEADREV" || { echo "record commit's parent is not the reviewed head — stop here and run Failure"; exit 1; }
# The committed blobs, not the paths: same names can hold different bytes.
for f in $FINAL; do git rev-parse "HEAD:$f"; done > .context/loop-rule-committed-blobs
diff .context/loop-rule-final-blobs .context/loop-rule-committed-blobs \
  || { echo "a findings file was rewritten between validation and commit — stop here and run Failure"; exit 1; }
# Then re-run the findings-file structural check on the committed content and
# re-establish this pass's eligibility, per close condition 4's third bullet.
# Expected: every line before the terminator is a finding line, the terminator
# is exact, the count matches, both branch files are present, and the pass reads
# clean-or-zero-finding exactly as it did when issued. Any difference: Failure.
test -z "$(git status --porcelain)" || { echo "tree not clean after the record commit — stop here and run Failure"; exit 1; }

git rev-parse HEAD > .context/loop-rule-reviewed-tip   # the closing tip: 8b's precondition, NOT a reset target
```

**The reviewed head and the closing tip are two values.** The first is what the pass read; the
second is that plus the findings files. **A single value cannot be both**, and treating it as one is
how a commit that landed after the response reaches the close — which is why `HEAD^` is compared
above rather than assumed.

**8b — reset and close. A separate invocation, carrying no `-m` option at all.**

```bash
BASE=$(cat .context/loop-rule-base); TIP=$(cat .context/loop-rule-reviewed-tip)
test -n "$BASE" && test -n "$TIP" || { echo "BASE or TIP missing — 8a did not complete"; exit 1; }
test "$(git rev-parse HEAD)" = "$TIP" || { echo "HEAD has moved since 8a — NOT resetting"; exit 1; }
# Close condition 5 is BOTH: the tip AND a clean tree, checked in THIS invocation.
# A staged edit made between 8a and 8b — a rewritten findings file included —
# survives reset --soft, lands in the closing commit, and leaves the tree clean
# afterwards, so every postcondition passes while unreviewed content ships.
test -z "$(git status --porcelain)" || { echo "tree not clean at 8b — NOT resetting; stop here and run Failure"; exit 1; }
git reset --soft "$BASE" || { echo "reset --soft FAILED — stop here and run Failure; do NOT commit"; exit 1; }
# Re-read the closing message here: it was validated before 8a, 8a ran a commit
# (hooks can rewrite anything), and .context is ignored, so no porcelain check
# between the two invocations can see it change.
test -s .context/loop-rule-closing-msg || { echo "closing message missing or empty — stop here and run Failure"; exit 1; }
# Revalidate its records — exactly one provenance line, exactly one curve for this
# cycle, every owed evidence entry, and the exception records or the plural marker.
git commit -F .context/loop-rule-closing-msg
```

**Then check the result. On a failed `git commit`, or on either check below failing, run
`## The four procedures` · Failure** — which stops every further mutating action, reports the failed
step and the observed state, and hands over. **It does not reset, re-commit or clean up**, and the
`rm -f` below is therefore unreachable on that path:

```bash
case "$(git log -1 --pretty=%s)" in
  [Ww][Ii][Pp]:*) echo "closing commit still reads as a snapshot — stop here and run Failure"; exit 1 ;;
esac
test "$(git rev-parse HEAD^)" = "$BASE" || { echo "closing commit's parent is not \$BASE — stop here and run Failure"; exit 1; }
test -z "$(git status --porcelain)" || { echo "tree dirty after the close — stop here and run Failure"; exit 1; }
# The COMMIT BODY, not the source file: prepare-commit-msg and commit-msg hooks
# rewrite git's copy after -F has read it, so the validated file proves nothing
# about what landed.
git log -1 --pretty=%B > .context/loop-rule-landed-msg
diff .context/loop-rule-closing-msg .context/loop-rule-landed-msg \
  || { echo "the committed body differs from the validated message — stop here and run Failure"; exit 1; }
```

**Both clean, and only then:**

```bash
rm -f .context/loop-rule-base .context/loop-rule-reviewed-tip .context/loop-rule-reviewed-head \
      .context/loop-rule-baseref .context/loop-rule-closing-msg \
      .context/loop-rule-untouched .context/loop-rule-baseline-diff.txt \
      .context/loop-rule-sites .context/loop-rule-changed-sites \
      .context/loop-rule-c.src .context/loop-rule-w.src \
      .context/loop-rule-a.txt .context/loop-rule-b.txt .context/loop-rule-landed-msg \
      .context/loop-rule-final-blobs .context/loop-rule-committed-blobs
if ls .context/loop-rule-* >/dev/null 2>&1; then
  echo "cycle scratch survives the close:"; ls .context/loop-rule-*; exit 1
fi
```

**Every `loop-rule-*` scratch file goes, and the `ls` is what makes "the scratch files are removed"
true rather than asserted.** An earlier draft deleted three of them and claimed the terminal state,
leaving a later run to inherit a closing message, a baseref and an untouched map — each of which
some check then has to detect or overwrite piecemeal. **This runs only on a successful close**; after a
failure **the plan performs no cleanup at all**. That is not a promise the files are unchanged — a
hook that failed may have rewritten any of them — so Resume enumerates what survives and validates
it rather than trusting it. **The plan's records
are not among these**: they live in the plan and in `.context/codex-reviews/`, both tracked, both
already in the closing commit.

**`reset --soft` moves `HEAD` and leaves the index exactly as it was** — it stages nothing and
unstages nothing, so the index still holds every `WIP:` commit's content, which is what makes the
single closing commit carry the whole change. **Anything *staged* and uncommitted at that moment is
in the index too and would land in the closing commit**; only *unstaged* work stays out. That is why
the close's precondition 5 requires a clean tree before 8b runs — **an earlier draft said the reset
"stages committed content only" and that unstaged-or-not, uncommitted content stays out, which is
wrong about the index and hides the path §I parks.** The prompt-standards result, the completeness
sweep, the next-state table, the divergence list, the equivalence result and the fragment evidence
all land in this plan, and `.context/codex-reviews/` is tracked. **Anything uncommitted and
*unstaged* when the reset runs stays in the worktree and out of the closing commit; anything
uncommitted and *staged* lands in it.** That asymmetry is what precondition 5's clean tree
prevents; and the plan records, had they been left uncommitted,
would never have been in a Gate-B range either. Step 7 commits them before the candidate pass is issued, which
is what lets 8a's dirty-set check be exact.

---

## Self-Review

**1. Spec coverage.** §A → Task 1. §B → Task 3. §C → Task 4. §D → Task 5. §E → Task 6. §F items 1–9 → Task 8; items 14, 18 → Task 9; items 10–13, 15–17 → Task 10 with its test sweep in Task 11. §G → Task 7, **added by this review**: the first draft gave the one-contract paragraph no task, though design §4 lists it as its own site and target §G carries its replacement. It is a prompt-copy replacement in both copies with the same shape as §H's blocks, owes a discriminating pair with row **P7**'s OLD `These records are one contract` — the live wording; `These rules and records are one contract` occurs nowhere — at C 879 / W 1063 as of this writing, **and a second, add-only presence check for the semantic membership test it gains**, which P7's pair does not observe. §H → Task 7. §I ships nowhere and needs no task. Design §6 → Task 14. Design §7 → Tasks 13 and 15. Design §8 → Task 15's battery and the Global Constraints. Story AC 5 → the disposition tables. Story AC 4 → Task 13.

**2. Placeholder scan.** The replacement text is cited rather than copied, deliberately and for the reason the Architecture note gives. Task 13's row list is explicitly a floor rather than a closed set, and says so. Task 11 deliberately carries no count, and says why.

**Which steps are mechanical and which are reader checks, stated rather than claimed uniformly.** Every OLD half has an exact expected result and a procedure that produces it, but **not every one is a pre-verified table row**: the rows the tables carry were checked against the real files in advance, while Tasks 3, 4, 6, 7 and 10 **derive their remaining pre-existing fragments at execution, before their install step**, against text this plan cannot quote without becoming a second copy of it. **Task 1 is not among them:** §A is add-only, row P1 records that it has no OLD half at all, and Task 1 derives presence fragments only — listing it would send an executor looking for a counterfactual that cannot exist. **The NEW halves are `<...>` until their task installs the text**, which the fragment table discloses and each step requires to be verified before counting. **And no per-task shell is pre-written at all** — the procedure is stated once and the executor writes the command in front of the files, so "a runnable command per step" is not what this plan claims. **Tasks 12, 13 and 14 step 2 are reader checks by design** — a predicate comparison, a next-state walk and a divergence classification are judgements, and giving them commands would be the false-precision this repo's invariants warn about. An earlier revision of this section claimed every verification step had a runnable command, which was not true of them.

**3. Type consistency.** `$BASE` is set in Task 0 and used in Tasks 1–10. The four-value pair shape is **`old/worktree`, `old/parent`, `new/worktree`, `new/parent`** — the order the verification procedure, every task's expected result and the evidence schema use, and the one this section had reversed. Condition ids match the inventory throughout: a1–a22, b1–b18, c1–c20, d1–d7, e1–e11, f1–f7, g1–g4, h1–h26, i1–i16, j1–j4 — 135 total, every one dispositioned above.

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

## Fragment sweep (Task 0 output)

*Empty until Task 0 runs. Task 0 replaces this entire section: the revision the sweep ran at, one
line per fragment-table row with its three results, and the reading result for `F1`, `F2` and `F3`.*

---

## Fragment evidence (per-task output)

*Empty until the tasks run. One subsection per task — `### Task 1`, `### Task 3`, … — replaced
idempotently on re-run, touching no other. **The pre-existing fragments live in the fragment table,
never here**; this section records what each observation actually returned, and it is what Task 15
step 5 reads to assemble the closing evidence entry.

**Six record shapes, because the classes do not return the same number of values.** Every
observation this plan makes is one of them, and a shape that fits only pairs is how a required
count gets run and then vanishes from both the plan and the closing evidence:*

```
pair         <condition> <fragment: OLD> <fragment: NEW> old/worktree old/parent new/worktree new/parent <copy>
presence     <what> <fragment> worktree parent <copy>          # add-only, and a moved condition's destination
absence      <condition> <fragment> parent worktree <copy>      # dropped, and a moved condition's source
preservation <condition> <fragment> parent worktree <copy>      # carried, and kept where no span holds it
span         <start anchor> <end anchor> <file> <result>        # an untouched range, parent vs worktree
sweep        <file> <line> <what it said> <what it became>      # one examined site of a reader-led sweep
```

*The **fifth shape is for ranges, not conditions**: an untouched span is two bounded extracts
compared against each other, so it has no fragment and no counts and the four condition shapes
cannot express it. Its `<result>` is `no difference` or the difference itself — recorded either
way, because a span that was never run and a span that compared equal are otherwise the same
record. Task 15 reads this shape alongside the other four.*

*The **sweep** shape is the one that carries no count: Task 11's sweep records **one line per site
examined** and what each became, because §F refuses a count of these assertions anywhere and a
number here would be the durable second authority it refuses. A complete sweep is distinguishable
from a partial one by the sites listed, not by a total. Task 15's closing entry reads this shape
with the other five.*

*A **moved** condition therefore contributes two lines — one `absence` at its source, one
`presence` at its destination — and both are required for it to count as observed. **Every one of
the six shapes goes into the closing evidence entry**; naming only pairs and presence leaves the
absences, preservations and span results run but unrecorded.*
