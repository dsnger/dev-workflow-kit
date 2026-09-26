# §5 loop-rule consolidation — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Install one closure ordering into both §5 copies, replace the twenty-three standing sentences it falsifies across those copies and the shipped hook, and ship the result as plugin 0.12.0.

**Architecture:** Every string this change installs is already written in final form in the target text. This plan does not restate any of it. Each task names the **site**, quotes the **anchor** it installs at, cites the **target-text section** whose fenced block supplies the wording, and runs the **discriminating pair of counts** — the new wording present, the old wording gone — from the one verified fragment table below. Copying the replacement text into this plan would create the second-copy defect the whole cycle fought; a citation into an approved artifact that travels with this plan is not a placeholder.

**Tech Stack:** Markdown prompt text, POSIX `sh` (the hook), `grep`/`diff` for verification, `shellcheck`, the `claude` CLI.

**Spec:** `docs/superpowers/specs/2026-09-10-loop-rule-consolidation-target-text.md` (the text, in final form) and `docs/superpowers/specs/2026-09-10-loop-rule-consolidation-design.md` (the decisions behind it). Both are approved: Gate-A cycle `awsf1ec771` closed at pass 65 with a zero-finding file, commit `ba15e83`.

**Story:** `docs/superpowers/stories/2026-08-29-loop-rule-consolidation-story.md` — read the profile from its header at every gate call; it is the only writable copy. Six acceptance criteria; §4 holds settled decisions D1–D8.

**Related assessment (informational):** [OpenWolf context and memory assessment](../../openwolf-assessment.md)
records the advisor's evidence and trade-offs for a possible future evaluation requiring Daniel's separate authorization.
It adds no task, prerequisite or closure condition to this plan.

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
- **Every `git add` in this plan is guarded, and a guard is where most of them stop.** A failed staging otherwise falls through to the `git commit` on the next line, which **can still succeed on whatever the index already held** — this plan states in Task 15 step 7 that the index may carry foreign staged content, and Resume deliberately admits a live staged index — so the block reports a snapshot it did not take. **A content comparison after the commit is added only where a later step reads that commit rather than the worktree**, and that is one place: the step-4b commit block, which every Gate-B candidate uses, first pass and repairs alike, and whose commit bounds the range the next call reviews. The per-task snapshots have no such consumer — every check this plan runs afterwards reads the worktree or the step-4b candidate, and Gate B reads the accumulated `$BASE..HEAD` range rather than any one commit — so they are guarded and not pinned. **The closing commit is the other one**: Close condition 4 compares it against pins taken before staging.

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
| P19 | `a12`, kept, shares its line with `a13` (Task 0 preservation) | `where the cycle's own closure rules are satisfied.` | 148 | 355 |
| P20 | `a14`, kept, shares its line with `a13` (Task 0 preservation) | `Nothing here writes the floor knob: it stays the user's, never written, never` | 151 | 358 |
| P21 | `h6`, kept, shares its line with `h5` (Task 0 preservation) | `Several records` | 1009 | 1193 |
| P22 | `h18`, kept, shares its line with item 4's block (Task 0 preservation) | ``nothing that any mandatory rule in this file or in `AGENTS.md` requires.**`` | 1033 | 1217 |
| P23 | `b3`, replaced (Task 3 OLD) | `Blocker/Major resolve, Minor/Nit collect` | 608 | 815 |
| P24 | `b8`, replaced (Task 3 OLD) | `A finding is in-set when repairing it stays inside that scope` | 612 | 819 |
| P25 | `b11`, replaced (Task 3 OLD) | `like any other out-of-scope finding**, even when it opens no new question at all` | 616 | 823 |
| P26 | `b13`, replaced (Task 3 OLD) | `**new structural or contract question** stops the loop and goes to the user` | 619 | 826 |
| P27 | `b16`, replaced (Task 3 OLD) | `without anyone choosing it. Stopping this way is` | 626 | 833 |
| P28 | `b17`, replaced (Task 3 OLD) | `**not an exit from the gate**: the floor, the` | 626 | 833 |
| P29 | `b18`, replaced (Task 3 OLD) | `revised artifact once the question is answered` | 628 | 835 |
| P30 | `b1`, carried (Task 3 preservation) | `that corrects the correction you just made **and stays inside the assigned fix set** is` | 606 | 813 |
| P31 | `b2`, carried (Task 3 preservation) | `keep it here rather than handing it back` | 607 | 814 |
| P32 | `b4`, carried (Task 3 preservation) | `Ancestry decides where a finding belongs; it` | 609 | 816 |
| P33 | `b5`, carried (Task 3 preservation) | `it grants no Minor or Nit a repair round it would not` | 610 | 817 |
| P34 | `b6`, carried (Task 3 preservation) | `The assigned fix set is fixed before the pass you are answering` | 610 | 817 |
| P35 | `b9`, carried (Task 3 preservation) | `never merely because it arrived in the current pass` | 613 | 820 |
| P36 | `b10`, carried (Task 3 preservation) | `treat the finding as **outside**, which costs a question and never a silent` | 615 | 822 |
| P37 | `b14`, carried (Task 3 preservation) | `**size is not the test, novelty of the question is**` | 620 | 827 |
| P38 | `b15`, carried (Task 3 preservation) | `does not — provided that correction, too, stays inside the set` | 622 | 829 |
| P39 | `c1`, kept, passage (c) prefix (Task 4 preservation) | `**Blocker curve across passes**, not any single pass's total` | 664 | 868 |
| P40 | `c2`, kept, passage (c) prefix (Task 4 preservation) | `signals, the total says less than it looks like, and one low count is a snapshot rather` | 665 | 869 |
| P41 | `c3`, kept, passage (c) prefix (Task 4 preservation) | `**Neither curve measures coverage:** a low Blocker count can sit beside an` | 666 | 870 |
| P42 | `c4`, replaced (Task 4 OLD) | `one means keep going` | 668 | 872 |
| P43 | `c5`, carried (Task 4 preservation) | `visible across passes (six or more is where the field saw` | 668 | 872 |
| P44 | `c6`, carried (Task 4 preservation) | `coverage is sufficient**, stated` | 669 | 873 |
| P45 | `c7`, carried (Task 4 preservation) | `unreviewed area forbids this exit outright` | 670 | 874 |
| P46 | `c8`, replaced (Task 4 OLD) | `round's fix producing the next. That` | 672 | 876 |
| P47 | `c9`, moved to §A (Task 4 source absence) | `finish, and it is why **a clean completion takes precedence over this exit**` | 673 | 877 |
| P48 | `plateau rationale`, no id, stays (Task 4 preservation) | `That third condition is what makes a plateau rather than a` | 672 | 876 |
| P49 | `c10`, moved to §A (Task 4 source absence) | `Blocker/Major-free pass **at or above the floor** has satisfied the clean-final-pass rule —` | 674 | 878 |
| P50 | `c11`, moved to §A (Task 4 source absence) | `collect the Minors and Nits and close — and reporting` | 675 | 879 |
| P51 | `c12`, moved to §A (Task 4 source absence) | `**Below the floor nothing closes**` | 676 | 880 |
| P52 | `c13`, moved to §A (Task 4 source absence) | `the only exception, exactly as above;` | 677 | 881 |
| P53 | `e1`, kept, passage (e) (Task 5 preservation) | `Those three lines expose **five tells**` | 701 | 906 |
| P54 | `e2`, kept (Task 5 preservation) | `the finding count rising rather than falling` | 701 | 906 |
| P55 | `e3`, kept (Task 5 preservation) | `Blocker count failing to fall` | 702 | 907 |
| P56 | `e4`, kept (Task 5 preservation) | `findings clustering on the **instrument** rather than on` | 702 | 907 |
| P57 | `e5`, kept (Task 5 preservation) | `findings clustering on **prose about** either` | 703 | 908 |
| P58 | `e6`, kept (Task 5 preservation) | `either; and a require↔withdraw` | 703 | 908 |
| P59 | `e9`, carried (Task 5 preservation) | `hand the decision to the user, and the "clearly stuck"` | 705 | 910 |
| P60 | `e10`, kept, outside §D's block (Task 5 preservation) | `A loop can be worth stopping long before it plateaus.` | 706 | 911 |
| P61 | `e11`, kept, C only (Task 5 preservation) | `reporting obligation with a mandatory threshold and not another heuristic to weigh.` | 711 | — |
| P62 | `Severity resolve duty`, replaced (Task 6 OLD) | `rework) → both must resolve. Minor · Nit → collect, never iterate.` | 1226 | 1414 |
| P63 | `g2`, dropped (Task 6 absence) | `Until it is, a pass whose outcome would turn on that question reports the question and` | 1254 | 1442 |
| P64 | `g3`, dropped (Task 6 absence) | `the same answer any unresolved gate question gets` | 1255 | 1443 |
| P65 | `g4`, dropped, C only (Task 6 absence) | `That question is owned by the loop-rule consolidation work in` | 1256 | — |
| P66 | `c15`, carried (Task 7 preservation) | `**Surfacing does not close the cycle, and that is what makes this reachable.**` | 680 | 884 |
| P67 | `c16`, replaced (Task 7 OLD) | `*with the finding still open*` | 681 | 885 |
| P68 | `c17`, replaced (Task 7 OLD) | `the resolve rule is not waived` | 681 | 885 |
| P69 | `c19`, replaced (Task 7 OLD) | `the loop resumes on whatever the user decides` | 682 | 886 |
| P70 | `c20`, replaced (Task 7 OLD) | `with the rule that every Blocker and Major` | 683 | 887 |
| P71 | `a13, first sentence`, replaced; first sentence's own absence (Task 7) | `This replaces the pass-count number` | 148 | 355 |
| P72 | `a15`, carried (Task 7 preservation) | `Open a TodoWrite "Codex pass N" per pass;` | 152 | 359 |
| P73 | `a18`, moved to §A (Task 7 source absence) | `if the pass at the floor still finds Blocker/Major, keep going until` | 153 | 360 |
| P74 | `a19`, moved to §A (Task 7 source absence) | `The only early exit` | 154 | 361 |
| P75 | `a20`, moved to §A (Task 7 source absence) | `don't manufacture findings to pad` | 155 | 362 |
| P76 | `a21`, carried (Task 7 preservation) | `advisory — validate before applying` | 156 | 363 |
| P77 | `a22`, carried (Task 7 preservation) | `dismissed finding → one-line why` | 156 | 363 |
| P78 | `i4`, carried (Task 7 preservation) | `touches — at minimum` | 175 | 382 |
| P79 | `i5`, carried (Task 7 preservation) | `severity classified without the demotion` | 176 | 383 |
| P80 | `i6`, carried (Task 7 preservation) | `the provenance-line duty owed` | 176 | 383 |
| P81 | `i7`, carried (Task 7 preservation) | `owed, the curve` | 176 | 383 |
| P82 | `i8`, carried (Task 7 preservation) | `the nonce duties at their strictest` | 177 | 384 |
| P83 | `i1`, kept, passage (i) (Task 7 preservation) | `From the commit that ships them` | 173 | 380 |
| P84 | `i2`, kept (Task 7 preservation) | `finishes under the rules it started with.` | 174 | 381 |
| P85 | `i3`, kept, shares its sentence with the list (Task 7 preservation) | `established it takes the stricter reading of every part this change touches` | 175 | 382 |
| P86 | `i9`, kept (Task 7 preservation) | `the cycle is treated as post-rule, so it` | 177 | 384 |
| P87 | `i10`, kept (Task 7 preservation) | `the working record stays optional and a skipped cycle still writes no findings slots` | 180 | 387 |
| P88 | `i11`, kept (Task 7 preservation) | `` cannot recover a nonce it starts a new cycle rather than claiming `none (pre-rule)`, that reserved `` | 181 | 388 |
| P89 | `i12`, kept, discharged (Task 7 preservation) | `Each further rule this change ships adds its own strict` | 182 | 389 |
| P90 | `i13`, kept (Task 7 preservation) | `cycle a floor of 1 and skip passes on the strength of not knowing when it started` | 184 | 391 |
| P91 | `i14`, kept (Task 7 preservation) | `knob set above 3 is not lowered by this fallback` | 185 | 392 |
| P92 | `i15`, kept (Task 7 preservation) | `A revert is itself a shipping commit for` | 185 | 392 |
| P93 | `i16`, kept (Task 7 preservation) | `the old rules, and the activation rule wins wherever the start is determinable; the` | 186 | 393 |
| P94 | `a1`, carried inside item 8a (Task 8 preservation) | `**Both gates are a LOOP with a HARD FLOOR: a minimum number of passes per run` | 92 | 299 |
| P95 | `h3`, carried inside item 7 (Task 8 preservation) | `an ungated change records it in that commit` | 1499 | 1688 |
| P96 | `§F item 10`, hook only, the honesty claim (Task 10 OLD; `codex-gate.sh` line 967) | `this floor is the only thing keeping the spec review honest` | — | — |
| P97 | `§F item 10`, hook only, the tail (Task 10 OLD; `codex-gate.sh` line 967) | `Run more passes before executing` | — | — |
| P98 | `§F item 11`, hook only, the Gate-A clean definition (Task 10 OLD; line 973) | `Proceed only if your final pass was clean` | — | — |
| P99 | `§F item 12`, hook only, the Gate-B clean definition (Task 10 OLD; line 956) | `commit only if your final pass was clean — no new Blocker/Major.` | — | — |
| P100 | `§F item 13`, hook only, the WIP reminder (Task 10 OLD; line 908) | `then make the real commit when your final pass is clean` | — | — |
| P101 | `§F item 15`, hook only, the no-fingerprint reminder (Task 10 OLD; line 933) | `Run Gate B (mcp__codex__review) now; if this repeats` | — | — |
| P102 | `§F item 16`, hook only, the stale-fingerprint reminder (Task 10 OLD; line 945) | `one clean pass is the complete remedy for the staging and post-upgrade cases too` | — | — |
| P103 | `§F item 17`, hook only, the below-floor instruction (Task 10 OLD; line 947) | `or proceed only if $policy's skip rule applies to this change` | — | — |

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

### Where each operational condition is defined — one home each

**This index exists because the same condition was being stated three times**: as a Close condition,
again as a command in Task 15 step 8, and a third time as prose beside that command. Three statements
drift, and the review history is mostly that drift — a repair reaching one of the three and missing
two. **`docs/prompt-standards.md` item 8 is the rule: reference, do not duplicate.**

**Read this as a lookup, not as a procedure.** It carries no commands and no expected results; those
live in the home named. Where a task, a shell comment or an error string needs a condition, it
**cites the row** rather than restating it.

| Operational condition | Defined in | Discharged by |
|---|---|---|
| Branch, clean tree, no base file yet, `ba15e83` ancestral, approved inputs unchanged at `HEAD` | **Preparation** | Task 0 step 1, first-entry branch |
| Branch; base file shape, self-resolving commit, ancestral; approved inputs unchanged at `$BASE`; scratch-artifact validity; how far the implementation got | **Resume** | Task 0 step 1, re-entry branch |
| What a re-entry reads, and that no rule depends on the state fitting a named shape | **Resume** — its table is illustration, not a classification | accounting row 7; every state-reading rule |
| `HEAD` equals the reviewed head | **Close**, condition 1 | step 8, closing block |
| The dirty set is exactly this cycle's findings files | **Close**, condition 2 | step 8, closing block |
| The closing message is complete, and revalidated before it is consumed | **Close**, condition 3 | step 7b writes it; step 8's closing block checks and pins it |
| After the closing commit: subject, parent, clean tree, landed body, committed findings blobs | **Close**, condition 4 | step 8, postcondition block |
| One closing command with no `-m`, and why | **Close** | step 8, closing block |
| What happens on a failed closing operation or postcondition | **Failure** | every rejection after the reset in step 8 |
| What a successful close removes | **Close**, its success recognition | step 8's postcondition block |

**Straight-line commands stay where the work happens.** Task 15 step 8 keeps the shell that runs
these checks — it is verified and it is what an executor types — and each block names the condition
it discharges instead of re-explaining it. **What was removed is the third copy**: the prose that
repeated a condition in words beside the command that already ran it.

### The accounting — every condition, kept / re-expressed / proposed for deletion

Required before replacing a decision procedure (`AGENTS.md`, "Never replace a decision procedure
without accounting for its old conditions"). Pass 5 is why: a bulk edit that removed the
verification apparatus also removed Task 15's closing block, and nothing noticed until an
independent reader did.

| # | Condition | Disposition |
|---|---|---|
| 1 | Branch is `loop-rule-consolidation` | **kept**, and **split by entry, like row 4**: Preparation checks it at a first entry and **Resume checks it again**, first, before anything reads or writes cycle state. An earlier revision assigned it to Preparation alone, which is first-entry-only — and `.context/` is ignored, so the base file survives a checkout and another branch descended from `$BASE` passed every re-entry check (pass 38, Blocker) |
| 2 | Tree clean before the base is recorded | **kept**, same shell — preparation |
| 3 | `ba15e83` is an ancestor of the cycle's starting revision | **kept, and split by entry, like row 4**: Preparation checks it at `HEAD`, because a first entry has no recorded base; **Resume checks it at `$BASE`**, because that is the persisted starting revision Gate B diffs from and the close resets to. An earlier revision assigned it to Preparation alone, which is first-entry-only — so a base **below** `ba15e83` passed Resume wherever the three approved-input blobs happened to match, and in this repository `ba15e83^` carries all three identically (pass 45, Blocker) |
| 4 | The three approved inputs' blobs equal their `ba15e83` versions | **kept, and split by entry**: Preparation compares them **at `HEAD`**, because a first entry has no recorded base; **Resume compares them at `$BASE`**, because a Gate-B fix may legitimately have changed `HEAD`'s copy in a `WIP:` snapshot. An earlier table row claimed Preparation did the base comparison, which it never could |
| 5 | Never overwrite an existing base file | **kept** as an obligation; the shell branch becomes one line of the resume procedure |
| 6 | A pre-existing base is an ancestor of `HEAD` (`merge-base --is-ancestor`) | **kept**, same shell — resume |
| 7 | Only this run's `WIP:` commits lie between base and `HEAD` | **kept as an observation, dropped as a staleness test**, and **a second requirement is dropped here by decision**: Resume no longer has to fit the repository to a named shape before it may proceed. That demand was this plan's own — the approved §A re-establishes the conditions *against the repository as it now stands* — and it failed twice in two passes, once on a state no row described and once on a row describing one shape of several. Resume's table stays as **illustration, deliberately not exhaustive**, and no permission, base conclusion or recovery operation turns on it. **This drop is a requirement, not one of the forty-one conditions** — rows 20 and 40 are still the only *conditions* this table deletes, and row 40's count is about those. **Staleness is still decided by ancestry and provenance, never by a commit subject and never by an unfamiliar shape** |
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
| 22 | `headSha` resolved to the full object name at that moment, kept with each branch's result | **kept**, and **extended**: it is persisted, because the close needs it (pass 21); its consumer is Close condition 1 |
| 23 | A fresh nonce for the Gate-B cycle | **kept** — the rule, unchanged |
| 24 | Each fix is committed before the next review | **kept.** The pass-21 widening — every non-closing pass commits its findings, repair or not — is **DELIBERATELY DROPPED by Daniel's decision D1 of 2026-09-25**: findings files are committed once, at the close. Consequence stated at Close, *D1* |
| 25 | Every affected check re-runs after each fix, mechanical and reader | **kept** — the rule, unchanged |
| 26 | Re-run records are committed before the re-review | **kept** — the rule, unchanged |
| 27 | The complete set re-runs before the candidate final pass | **kept, and made explicit** (pass 54): before every call, since any call can be final. Records that come out unchanged are not recommitted; records that change enter a records-only candidate before final verification |
| 28 | Only a clean response against that exact `HEAD` closes | **kept**, and **made checkable**: the reviewed head is recorded, so "that exact `HEAD`" has a value to compare against (pass 21) |
| 29 | Closure-eligible = clean at or above the floor **or** zero-finding | **kept** — the rule, unchanged |
| 30 | The final pass's own findings files are the sole permitted post-review addition | **changed by D1**: this cycle's findings files, every pass's, are the sole permitted addition at the close |
| 31 | The closing message is rebuilt whole; exactly one provenance line and one curve | **kept** — the rule, unchanged |
| 32 | Every owed record is present before the close | **kept** — the rule, unchanged |
| 33 | The dirty set is exactly this cycle's findings files (changed by D1 from the final pair), read from every porcelain record | **kept** as the close procedure's check, and **corrected**: it asks git which paths outside the expected pair are dirty instead of splitting status output into pathnames, which dropped a newline-bearing path invisibly and mangled a rename's second field (pass 34) |
| 34 | The record commit's changed-path set equals those files | **dropped with its subject** (D1): there is no record commit. What it guarded — only findings files enter beside the reviewed tree — is Close condition 2 plus condition 4's blob check |
| 35 | The tree is clean after the record commit | **dropped with its subject** (D1): there is no record commit |
| 36 | `HEAD` equals the reviewed tip before the reset | **merged into Close condition 1** (D1): with no record commit the closing tip and the reviewed head are the same object, and condition 1 is read in the same block as the reset |
| 37 | The closing commit's subject is not a snapshot | **kept** as the close procedure's check |
| 38 | The tree is clean after the close | **kept** as the close procedure's check |
| 39 | 8a and 8b are separate invocations; no `-m` in the closing one | **kept in part** (D1): no `-m` in the closing command. The split is dropped, because no `WIP:` commit shares a command string with the close any more |
| 40 | Every rejection restores a tip by **mixed** reset, never `--hard` | **DELIBERATELY DROPPED**, by Daniel's decision, and the second of two deletions this table records. **It was never a requirement of the approved spec** — §A says *"re-establish every closure condition against the repository as it now stands"*, which reads the state rather than rewinding it, and a rejected commit at `HEAD` is a legitimate starting point for that reading. It was this plan's own implementation choice, and it had grown restore targets, phase selection, pre- and post-act captures and their own error handling, which four consecutive passes then found defects in. **What replaces it is a bounded handoff**: stop every further mutating action, report the failed step and the observed state, change nothing else. **The obligations §A does impose are unchanged** — surface the failure, re-establish every closure condition against the state as it stands, and take one of its three routes. **Not replaced by a generic backup mechanism**, which would be the same growth under another name |
| 41 | The scratch files are removed only after a successful close | **kept** as the close procedure's last step |

**This revision removed statements, not conditions — with one correction.** Every row below still
has exactly one home, named in the index above; what went is the **third copy**, the prose beside
Task 15 step 8's shell that repeated in words what the block already ran and the condition already
defined. Two rationales that existed only in that prose were moved into the conditions they belong
to: `reset --soft`'s index behaviour into the then condition 5, and why the dirty set can be exact into
condition 2. **The one correction is the landed-body check (then condition 6, now 4)**, which compared bytes where
`git log --pretty=%B` adds a trailing newline the source file has none of — it rejected a *correct*
close. **The predicate is unchanged and is now true as stated**: the body is extracted with
`--pretty=format:%B`, which emits the stored message alone, and the closing commit is made with
`--cleanup=verbatim`, so git stores the validated bytes rather than its own tidied copy. Verified in
a disposable repository, in both directions. An intermediate revision normalized trailing blank
lines on both sides instead; that made the check's own predicate false and is gone.

**Rows 34 and 35 left with their subject, and row 24's pass-21 widening was dropped, by Daniel's decision D1 of 2026-09-25** (Close, *D1*). **Before that, two conditions were dropped, 20 and 40, and each is named as a drop rather than lost.** Condition
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
requires no clean tree and mutates nothing — a handoff can leave `HEAD` at the
base with the whole implementation **staged**, and an unconditional clean-tree test would make that
state permanently unresumable through this plan's own success path.

**What is checked.** The branch; a clean tree; that `ba15e83` is an ancestor; that the three
approved inputs still hold their approved blobs at the revision the tasks are derived against; and
that **no base file exists yet** — if one does, this is a re-entry and Resume owns it.

**Every one of those predicates takes the same captured revision as its subject**, and Preparation
records it to `.context/loop-rule-start`. That file is the whole point: without it the checks here
and the base Task 0 step 1 records are statements about **different resolutions of a movable ref**,
and nothing binds the revision that was approved to the revision the work proceeds from.

```bash
# Resolve the starting revision ONCE and make it the subject of every predicate below.
# `HEAD` is a movable ref: checking the branch, the ancestry and the three approved
# blobs through separate live resolutions and then recording the base from yet another
# one binds the recorded base to NO commit whose properties were checked. Each fenced
# block is its own shell, so this value is written to a file for Task 0 step 1 rather
# than carried in a variable.
START=$(git rev-parse HEAD) \
  || { echo "cannot resolve the starting revision; stop"; exit 1; }
test "${#START}" -eq 40 || { echo "starting revision is not a full object name: $START"; exit 1; }
test "$(git rev-parse --verify "$START^{commit}")" = "$START" \
  || { echo "starting revision does not resolve to itself as a commit"; exit 1; }
# The symbolic check catches a detached HEAD, which prints `HEAD`; the ref check binds
# that branch to the captured object. Both, because neither implies the other.
test "$(git rev-parse --abbrev-ref HEAD)" = loop-rule-consolidation || { echo "wrong branch"; exit 1; }
test "$(git rev-parse --verify refs/heads/loop-rule-consolidation)" = "$START" \
  || { echo "the branch is not at the starting revision"; exit 1; }
# Two steps, because a FAILED `git status` prints nothing and `test -z ""` would read
# that as a clean tree. The predicate is unchanged; only its establishment is.
TREESTATE=$(git status --porcelain) \
  || { echo "reading the tree state FAILED — cleanliness is unestablished; stop"; exit 1; }
test -z "$TREESTATE" || { echo "tree not clean — if this is a re-entry, run Resume"; exit 1; }
test ! -e .context/loop-rule-base || { echo "a base is already recorded — this is a re-entry, run Resume"; exit 1; }
git merge-base --is-ancestor ba15e83 "$START" || { echo "ba15e83 not in this history"; exit 1; }
for f in target-text design condition-inventory; do
  p="docs/superpowers/specs/2026-09-10-loop-rule-consolidation-$f.md"
  # Resolve separately and check each status. `git rev-parse` without `--verify`
  # prints its UNRESOLVED argument and exits 128, so two failed lookups compare equal
  # exactly when the two revision expressions are equal — and either way the result
  # says nothing, because success must depend on both exit statuses. (Observed:
  # `git rev-parse HEAD:missing` prints `HEAD:missing`, status 128.)
  START_ID=$(git rev-parse "$START:$p") \
    || { echo "$p does not resolve at the starting revision — the comparison is unestablished; stop"; exit 1; }
  APPROVED_ID=$(git rev-parse "ba15e83:$p") \
    || { echo "$p does not resolve at ba15e83 — the comparison is unestablished; stop"; exit 1; }
  test "$START_ID" = "$APPROVED_ID" \
    || { echo "$p differs at the starting revision from its approved version"; exit 1; }
done
# Hand the checked revision to Task 0 step 1. Guarded, and no `cat` afterwards: a failed
# redirect with a following `cat` prints a STALE value and the block still exits 0.
printf '%s\n' "$START" > .context/loop-rule-start \
  || { echo "recording the starting revision FAILED — Task 0 step 1 has nothing to record"; exit 1; }
```

**How success is recognised.** Every line above exits 0. **No claim is made here about a recorded
base**, because on a first entry there is none — Task 0 step 1 records it immediately afterwards,
and validating it is Resume's job on every later entry.

**On deviation.** Stop. Each of these has a different fix and none of them is "retry": a wrong
branch is a checkout, a dirty tree is a decision about uncommitted work, a differing input blob is
an unapproved edit to a spec that the gates already closed.

### Close — after a closure-eligible pass

**Which rules govern this close.** This change's Gate-B cycle starts at the first `WIP:` commit and
ends at the closing commit, which is the commit that ships the new §5. `CLAUDE.md` "When these rules
bind" says a running cycle finishes under the rules it started with, so this cycle runs under **§5 as
it stands at `$BASE`** — read it with `git show "$BASE:CLAUDE.md"`, because the tasks rewrite the
working copy. That text owns the closing shape (`reset --soft` to the parent of the first `WIP:`, then
one commit), the provenance line, the curve and the evidence entry. What follows are this plan's own
conditions around that act. (The Gate-A plan cycle `om0bdd7udh` reviewing this plan is a different
cycle and keeps the rules it started under.)

**What is checked**, in this order, and these are the conditions rather than a script:

1. **`HEAD` equals `.context/loop-rule-reviewed-head`** — the head the candidate pass was issued
   against. **That is the reviewed head.** Nothing is committed between that call and this check,
   because findings files are not committed during the loop (*D1* below), so the reviewed head is
   still `HEAD` unless something reached the repository no pass has seen.
2. **Nothing is dirty except this cycle's Gate-B findings files.** The set is the **exact slot
   paths** `.context/codex-reviews/gate-b-spec-<nonce>-pass-<p>.md` and
   `gate-b-quality-<nonce>-pass-<p>.md` for every pass number `p` the cycle issued, built from the
   nonce and the pass numbers the cycle already holds — **never from a glob**, which would also take a
   dispositions note for a findings file. The final pass's pair must exist; any other missing slot
   must belong to a pass recorded as INCOMPLETE. **Advisory companions are not in the set.** A
   dispositions note still in the tree stops the close here — §5 lets it be deleted. **The cycle's
   working record, `.context/codex-reviews/gate-b-<nonce>-resume.md`, is the one exact path left out
   of the check**: it stays untracked through the close, because §5 makes it the recovery source
   while the cycle is open, and it is retired only after condition 4 has passed (pass 54, finding 4).
   No other path is exempt. **Staged or not makes no
   difference to a selected file**: every one is pinned, staged and committed. **Anything else dirty
   stops the close — tracked, staged or untracked, under `.context/` included.** Ignored scratch
   files do not appear in git's status at all, so no exemption is written for them. **Ask git which
   paths outside the set are dirty**, naming only the set, which are this plan's own slot names and
   carry no newline or rename field; a hand-rolled split of git's output can mangle a name or drop a
   dirty path, observed in a disposable repository. **The set can be exact because findings files
   are committed only here.**
3. **The closing message is complete** — rebuilt whole, exactly one provenance line, exactly one
   curve, every owed evidence entry, and either the applicable human-exception records or
   `Human exceptions: none`. It is checked **in the closing block, immediately before the commit
   consumes it**, and its bytes are pinned there as condition 4's oracle — the file is under
   `.context/`, which is ignored, so no tree check can see it change.
4. **After the closing commit**, five things, all read from one resolved commit `$CLOSED`: its
   **subject is not a snapshot**; its **parent is `$BASE`**; the **tree is clean** except the
   working record's one exact path; its **body is identical to the pinned validated bytes** — **not to the source file, which is the wrong
   oracle**: the same hooks that rewrite git's copy *after* `-F` has read it can rewrite that ignored
   file too; and **each selected findings file's committed blob equals the blob pinned immediately
   before staging**, with the final pass's pair re-read from `$CLOSED` against §5's *Accept a pass
   only when* and the clean-or-zero-finding reading it was judged on. **What the blob check
   compares, stated exactly:** bytes at pin time against bytes committed. It catches a change between
   the pin and the commit — a staging hook, a concurrent writer — and **nothing earlier**: a findings
   file edited between the pass's acceptance and the pin is pinned as edited and passes. **What the
   body check does not close**: a hook that also rewrites the pinned copy defeats it. **Any of the
   five failing is a Failure handoff.**

**How success is recognised.** A single commit at `HEAD` whose subject is the real message, whose
parent is `$BASE`, whose body is identical to the pinned bytes of the revalidated closing message,
which carries this cycle's findings files as pinned, with a clean tree behind it. **No tree
comparison** — target §I parks a Gate-B tree-equality condition on Daniel's decision of 2026-09-13.
Then, and only then, the scratch files and the working record are removed, and the tree is clean
without exception.

**One closing command, with no `-m`.** `codex-gate.sh`'s `is_wip_commit`
(`plugins/dev-workflow/hooks/codex-gate.sh:763`) tests the **whole command string** against
`-m[[:space:]]*['"]?[[:space:]]*wip`. The closing block makes no `WIP:` commit and its commit carries
`-F`, not `-m`, so the hook cannot read the close as cycle-internal. **That is why one invocation is
enough**; the earlier two-invocation split existed only because a `WIP:` record commit shared the
close.

**Which conditions are preconditions.** **1, 2 and 3 are preconditions** — checkable while nothing
has moved; on deviation stop, and no restoration is owed. **A failed `git add` inside the block is
not yet a move of `HEAD`, but the index may then hold part of the set** — stop and report it; do not
reset. **4 follows the move**; on deviation run `## The four procedures` · Failure.

**What this does NOT close, stated rather than left to be found.** The block reads `HEAD` and the tree
before `git reset --soft` a few lines later and claims nothing about the span between. A second writer
mutating the branch inside that span — another agent session, a background hook, an editor running
git — could put different content into the index after the checks, and **no later check would catch
it**: condition 4 compares subject, parent, cleanliness, body and the findings blobs, never the rest of
the content, and the content comparison that would have caught it is the Gate-B tree-equality
condition target §I **parks** (`docs/superpowers/specs/2026-09-10-loop-rule-consolidation-target-text.md`,
§I). **The width of that span is not measured**, and no claim of negligibility is made. **It is not
guarded**: what a fix would demand is an atomicity guarantee against a concurrently writing second
actor, which nothing in the approved text agrees to — **a scope question for the user, not a defect
in this disclosure.** Anything committed or staged **before** the block runs fails condition 1 or 2.

**A rejected commit left at `HEAD`, or a live soft-reset index, is a state this plan stops in and
reports** — it is not an error condition the procedure has to undo. Failure's resume rule
re-establishes the closure conditions **against the repository as it now stands**, so that state is a legitimate starting
point for the resume decision.

**D1 — findings files are not committed during the loop. Daniel's decision, 2026-09-25.** Each
pass's findings files are saved on disk under this cycle's nonce and committed **together, at the
close**. Until then they are **not Git-durable**: a parked cycle has no bounded duration, and a
`.context/` clear can remove them together with the working record. **Counts that survive elsewhere,
and a curve's `?`, do not establish what a lost file said or that its findings were resolved.** If it
happens, §5's existing rules apply unchanged — a pass whose file is gone before it was validated is
INCOMPLETE, and a finding whose resolution can no longer be shown is not resolved: **stop and
surface**. No backup, copy or recovery mechanism is added. **What D1 buys:** no commit lands between a
review and the reading of its result, so the reviewed head stays `HEAD` until a repair is committed.

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
- **which cycle values still exist** — the recovery base, the reviewed head, the findings list and
  its blob pin, the closing message, the working record — by listing them, not by assuming.

**What stopping does not do, said plainly.** It prevents *further* change; it is **no guarantee that
the failed operation itself destroyed nothing.** A hook that rejected after rewriting a staged file
has already done that, and this procedure cannot undo it or prove it did not happen. **Do not report
"nothing was lost".** Report what is there.

**How success is recognised.** The failure is surfaced with the four observations above, nothing
further has been changed, and the cycle is waiting on a person.

**Resuming is a decision about the actual state**, taken with that report in hand, and then these
rules apply. **They are this plan's own procedure, worded after target §A**; §5 at `$BASE` says nothing
about a failed closing act, so they add to it without contradicting it:

- **Every closure condition is re-established against the repository as it now stands.** Where they
  all still hold, **perform the act again**.
- **Where the attempt or its repair moved anything a condition is read from**, that condition has
  changed and **its own rule decides what it costs**, a further pass included, and the cycle is back
  in step 7 with that pass owed.
- **Where the failure cannot be repaired at all** — a signing key nobody has, a permission nobody
  can grant — **surface it and leave the cycle parked**: open, not running, spending no passes,
  restarted by an explicit later continue.

**A person's help replaces neither the review nor the evidence.** Whatever route resume takes, no
closing act happens until every prescribed condition is established again, and the evidence entry
and records the closing commit carries are the ones a pass actually validated.

### Resume — re-entering after an interruption

**Resume owns every entry after the first.** Preparation is first-entry-only and refuses when a base
file exists, so nothing here defers to it: the checks below are Resume's own, and **none of them
requires a clean tree** — a re-entry can legitimately arrive with the work staged, with it loose, or
with both, and an unconditional clean-tree test would refuse the very states Resume exists to
reconcile.

**Resume reads the repository; it does not classify it first.** Every check below runs against the
**actual** `HEAD`, index, worktree and surviving cycle records, and **none of them is gated on the
state matching a named shape.** Its wording follows target §A — *"re-establish every closure
condition against the repository as it now stands"* — as a plan procedure, not as a rule governing
this cycle; §5 at `$BASE` says nothing about re-entry. It asks for the conditions to be read, never
for the history to be catalogued. **The table below is illustration and is explicitly not
exhaustive**: no permission, no base-validity conclusion, no recovery operation and no continuation
route may depend on the state fitting a row, and **a state that fits none is an ordinary input to
Resume, not an error**.

**This is a requirement being dropped, and it is named rather than lost.** Earlier revisions said
the whole procedure reads *against the rows*, which made a complete classification of git histories
a precondition for resuming at all. **That was this plan's invention, never §A's**, and it failed
twice in two passes in the same way: pass 36 found a reachable state no row described, and pass 37
found the row added for it describing only one shape of the several that reach it. **What survives
unchanged is every governing duty** — the conditions, their object-id equality checks, the
precondition/handoff distinction, the scratch rules, the bounded handoff, and Failure's three routes.

| Illustration, not a classification | `HEAD` | `$BASE..HEAD` | Where the work is |
|---|---|---|---|
| **Normal, mid-implementation** | the last `WIP:` snapshot | this run's `WIP:` commits, and possibly a §A3 stray commit or amend | committed |
| **Close condition 1 rejected** — no reset has run | **not the reviewed head**. **The direction is not part of the test**: a further commit, an amend, a rebase and a move backwards all fail the same equality | whatever the actual history holds | wherever the actual content is — and **anything the mismatch introduced is present but unreviewed** |
| **The closing act rejected** | either `$BASE` itself, if the closing commit never landed, **or one commit parented by `$BASE`**, if it landed and a postcondition refused it | **empty**, or that one commit — the `WIP:` chain is gone either way, squashed by `reset --soft` | the **index**, or that one commit's tree |

**The closing-act illustration is the one worth reading before any rule below.** `reset --soft`
removes the `WIP:` chain from the ancestry, so after it there is no chain to find; an empty
`$BASE..HEAD` there means the work is staged, not absent. **In every state, this cycle's findings
files are uncommitted until the close (D1)** — they are part of what the four sources show.

**Condition 1 is an equality test and stays that way.** `test "$(git rev-parse HEAD)" = "$HEADREV"`
asks one question — is `HEAD` the object the cycle recorded — and **any answer of no stops the
closing sequence**, whatever git operation produced it. **Do not rewrite the recorded value to make
the test pass**: that file is what makes "the head the candidate pass was issued against" a fact
rather than a claim, and editing it turns an unreviewed tree into a closable one with nothing left to
notice. **A condition-1 rejection is a precondition stop**: nothing this plan did has moved, and no
handoff is in progress. A failure **after** `reset --soft` is a Failure handoff.

- [ ] **Validate the base — Resume's own checks, not Preparation's**

```bash
# The branch, FIRST and before anything reads or writes cycle state. `.context/` is
# ignored, so the base file survives a checkout: on another branch descended from
# $BASE every check below passes and the WIP commits, the soft reset and the closing
# commit all land on the wrong branch. A detached HEAD prints `HEAD` and is refused
# for the same reason.
test "$(git rev-parse --abbrev-ref HEAD)" = loop-rule-consolidation \
  || { echo "not on loop-rule-consolidation (on: $(git rev-parse --abbrev-ref HEAD)) — refusing to re-enter"; exit 1; }

test -e .context/loop-rule-base || { echo "no base file — this is a first entry, run Preparation"; exit 1; }
test -s .context/loop-rule-base || { echo "base file is EMPTY — inspect, delete deliberately, record why, re-record from the true starting commit"; exit 1; }
BASE=$(cat .context/loop-rule-base)
test "${#BASE}" -eq 40 || { echo "base is not a full 40-character object name"; exit 1; }
case "$BASE" in *[!0-9a-f]*) echo "base is not an object name: $BASE"; exit 1 ;; esac
test "$(git rev-parse --verify "$BASE^{commit}")" = "$BASE" || { echo "base does not resolve to itself as a commit"; exit 1; }
# Row 3 at `$BASE`, the way row 4 is already split by entry. Preparation checks this
# against `HEAD` and is first-entry-only, so nothing established it for a base that
# arrived with the ignored base file — and a commit BELOW `ba15e83` can carry the same
# three approved-input blobs and pass every other check here. Observed in this
# repository: `ba15e83^` has identical blobs for all three.
git merge-base --is-ancestor ba15e83 "$BASE" || { echo "ba15e83 is NOT an ancestor of the base"; exit 1; }
git merge-base --is-ancestor "$BASE" HEAD || { echo "base is NOT an ancestor of HEAD"; exit 1; }
for f in target-text design condition-inventory; do
  p="docs/superpowers/specs/2026-09-10-loop-rule-consolidation-$f.md"
  # Resolve separately, for the reason Preparation's copy gives: a failed lookup can
  # still print its unresolved argument, so equality alone does not establish success.
  BASE_ID=$(git rev-parse "$BASE:$p") \
    || { echo "$p does not resolve at \$BASE — the comparison is unestablished; stop"; exit 1; }
  APPROVED_ID=$(git rev-parse "ba15e83:$p") \
    || { echo "$p does not resolve at ba15e83 — the comparison is unestablished; stop"; exit 1; }
  test "$BASE_ID" = "$APPROVED_ID" \
    || { echo "$p differs at the base from its approved version"; exit 1; }
done
```

**The approved-input comparison is at `$BASE` here, and at `HEAD` in Preparation.** They are
different revisions on purpose: Task 15 step 7 permits a Gate-B fix to update the spec in a `WIP:`
snapshot, so on a re-entry `HEAD`'s copy may legitimately differ while the revision the tasks were
derived against does not.

**Replace a base only on affirmative evidence it belongs to another run** — it fails one of the
checks above. **Neither a commit subject nor an absence of cycle commits is evidence**: §A3's stray
non-`WIP` commit leaves the base valid, and after a `reset --soft` the range is empty by
construction, so both tests would condemn states this plan calls valid. **Nor is a `HEAD` mismatch, in any direction**:
base validity is **established by the checks above and never inferred** — from a mismatch, from a
shape, or from the state not resembling anything named here. Run them and read the answer. A
mismatch costs whatever Close condition 1 says it costs, which is not the base checks' question, and
where the base does fail one of them the rule is the one already stated: **affirmative evidence, then
replace — never because a re-entry looked unfamiliar.**

- [ ] **Validate the scratch artifacts**

Each by its `base` line **and** its completeness predicate:

- `.context/loop-rule-untouched` — every line parses as `base`, `span` or `cond`, and every kept
  condition in the five regions appears in exactly one `span` or one `cond`.
- `.context/loop-rule-baseline-diff.txt` — every line parses as `base`, a `site` record, or diff
  output belonging to the site above it, and **every inventoried site has a `site` record**.
- `.context/loop-rule-start` — **written by Preparation, consumed and removed by Task 0 step 1, and
  never present once a base exists.** It carries the revision Preparation's predicates were about.
  Its recovery rule ships with it, because a cycle state file introduced without one is the defect
  pass 48 found in the revision before this: **a surviving `loop-rule-start` with no
  `.context/loop-rule-base` is an interrupted first entry** — Preparation completed, Task 0 step 1
  did not. That is a **precondition stop**: report the recorded revision and where `HEAD` now is, and
  take no mutation. **Do not rebuild it and do not resume from it**, because the tree may have moved
  since Preparation checked it and nothing here re-establishes those predicates; re-running
  Preparation from a clean tree is the ordinary continuation, and it overwrites this file. **Both
  present is not a conflict** — it is Task 0 step 1 interrupted between its redirect and its `rm`, and
  the base is the authority; remove the start file and carry on. **Neither present** is an ordinary
  first entry.

**On failure the answer depends on why you are here.** Outside a handoff: delete and rebuild from
the `$BASE` blobs — never reuse, never repair in place, because a same-base partial file is the one
shape a `base` line alone cannot catch. **Inside a handoff, while a failed close waits on a person:
report the invalid artifact and change nothing.**

**This plan performs no cleanup after a failure — it does not claim the failed operation left
anything intact.** Enumerate which scratch values actually survive and validate each;
a value is trustworthy because it passed a check, never because cleanup was skipped.

- [ ] **Establish how far the implementation got — from the content, not from the log**

**Read all four sources, every time, and do not decide first which of them matters.** Which one
holds the work varies — after `reset --soft` it is the index and `$BASE..HEAD` is empty; after a failed
close part of it may be loose, and this cycle's findings files are always uncommitted until the close — and **routing on a guessed shape is how a source gets skipped**. So
read them all and reconcile against what they actually contain:

```bash
# $BASE is read HERE: each fenced block is its own shell, so an assignment in an
# earlier block is gone (pass 53, finding 3).
BASE=$(cat .context/loop-rule-base) \
  || { echo "cannot read the base — the reconciliation cannot start; stop"; exit 1; }
test -n "$BASE" || { echo "base empty — the reconciliation cannot start; stop"; exit 1; }
# Guarded one by one, because this step's rule is that all four ARE read: unguarded,
# a failed read is indistinguishable from a source that holds nothing, and the next
# command's success carries the block to an exit 0 on an incomplete view.
git log --oneline "$BASE"..HEAD \
  || { echo "reading the commit range FAILED — the reconciliation is incomplete; stop"; exit 1; }
git diff --cached "$BASE" \
  || { echo "reading the staged content FAILED — the reconciliation is incomplete; stop"; exit 1; }
git diff \
  || { echo "reading the unstaged content FAILED — the reconciliation is incomplete; stop"; exit 1; }
git status --porcelain --untracked-files=all \
  || { echo "reading the path listing FAILED — the reconciliation is incomplete; stop"; exit 1; }
```

A ticked checkbox is confirmed by the change being *present in that content*, wherever it lives.
`git status` names paths and says nothing about what is in them, and `--stat` counts lines. **The
delta that caused a failed close is precisely the one a path listing cannot describe** — a rewritten
staged file keeps its name — so reconcile against `HEAD`, the index and the worktree **contents**
together.

**A task whose checkbox is ticked but whose change is in none of them was not completed** — and one
whose change is present with the box unticked is completed. **Deciding from the commit log alone
reads a post-reset repository as an untouched cycle and invites every edit to be made twice.**

**Present is not reviewed, and a `HEAD` mismatch is where the two come apart.** Reconciling the task
list tells you what the repository *holds*; it says nothing about what a pass has *seen*. Whenever
`HEAD` is not the object id the cycle recorded, **something reached this repository that no pass
reviewed** — a further commit, an amended one, a rebased one, or a tree the history moved back to —
and a ticked checkbox does not make any of it reviewed. **Do not adopt it**: carrying it into a
close is the defect Close condition 1 exists to stop, and that condition's own rule decides the
cost — only a clean response issued against that exact `HEAD` closes the cycle. **Do not remove it**:
this plan restores nothing, and what you delete here is evidence a person has not yet chosen a Failure
route on. **And do not rewrite `.context/loop-rule-reviewed-head` to match**,
which would make the equality pass by discarding the only record of what was reviewed.

**Route by where the close stopped.** A **condition-1** mismatch is a precondition rejection:
nothing this plan did has moved, so it is a **plain stop** — report the mismatch and the state, no
handoff is in progress, and the scratch-artifact rule above takes its ordinary *delete and rebuild*
branch. A failure **after `reset --soft`** goes to `## The four procedures` · Failure and **is**
inside a handoff, so the scratch rule's *report and change nothing* branch applies. Either way Failure's
three routes decide what happens next. **A pass that was validated but not yet routed** is found like
any other state: its findings files sit uncommitted in the four sources, and routing it through step
7 is the ordinary continuation.

**How success is recognised.** The base passes Resume's own checks; the artifacts match it and are
complete, or are reported as invalid and left alone; and the plan's task list has been reconciled
against the content the four sources actually hold. **Fitting a named shape is not among them.**

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
| **carried** | a **preservation count** after installation, `parent=1 worktree=1` in each copy, from the condition's own text — the same two values the *kept* route above owes, and stated the same way here because an earlier wording said `1` and left which count ambiguous. **No untouched span covers a carried condition** — it sits inside a replacement block, which is the whole reason it is not recorded as kept. |
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

**Two files decide it, and there are three outcomes — not two.** The base file alone is not enough:
Preparation writes `.context/loop-rule-start` and Task 0 step 1 consumes it, so **a start file
surviving with no base is an interrupted first entry**, and Resume defines that state as a
precondition stop. Routing on the base alone sends it into Preparation, **which does not refuse an
existing start file and overwrites it** — destroying the only record of the revision the earlier
Preparation validated, and making that recovery rule unreachable. The route must test the file the
rule is about.

```bash
if [ -e .context/loop-rule-base ]; then
  echo "a base file exists — this is a RE-ENTRY: run Resume, not Preparation"
elif [ -e .context/loop-rule-start ]; then
  # Reachable exactly because it is tested BEFORE Preparation, which would overwrite it.
  echo "a start file exists with no base — Preparation completed and Task 0 step 1 did not."
  echo "This is a PRECONDITION STOP. Report, and take no mutation:"
  echo "  recorded starting revision: $(cat .context/loop-rule-start 2>/dev/null)"
  echo "  HEAD is now:                $(git rev-parse HEAD 2>/dev/null)"
  echo "Do NOT rebuild it and do NOT resume from it — the tree may have moved since those"
  echo "predicates were established. Re-running Preparation from a clean tree is the"
  echo "ordinary continuation, and it replaces this file."
  exit 1
else
  echo "no base and no start file — this is a FIRST ENTRY: run Preparation, then record the base below"
fi
```

**The route is decided by the path existing, not by it being non-empty.** An interruption between
the redirection and the write leaves an **empty** file, and an `-s` test would call that a first
entry while Preparation refuses because the path is there — a state neither route owns. **An empty
or malformed base file is Resume's**, which fails it on its shape checks and states what follows.

**First entry — run `## The four procedures` · Preparation**, then record the base here. **Never
overwrite one you did not just write:**

```bash
# The base is the revision PREPARATION CHECKED, never a fresh resolution of HEAD.
# Preparation ran the branch, ancestry and approved-blob predicates against this exact
# object and wrote it here; re-resolving `HEAD` would record a revision nothing checked.
test -e .context/loop-rule-start \
  || { echo "no starting revision recorded — Preparation did not complete; run it"; exit 1; }
BASE=$(cat .context/loop-rule-start) \
  || { echo "cannot read the starting revision; stop"; exit 1; }
# Not "non-empty": a symbolic value such as HEAD passes every check below and
# then RESOLVES DIFFERENTLY as WIP commits accrue, moving the reviewed range,
# the parent counts and the final reset with the branch.
case "$BASE" in [0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f]*) ;; *) echo "recorded base is not an object name: $BASE"; exit 1 ;; esac
test "${#BASE}" -eq 40 || { echo "recorded base is not a full 40-character object name"; exit 1; }
test "$(git rev-parse --verify "$BASE^{commit}")" = "$BASE" || { echo "recorded base does not resolve to itself as a commit"; exit 1; }
# The last moment before the first mutation. Preparation's checks are only about this
# repository if nothing has moved since; a move here is a stop, not something to record.
test "$(git rev-parse HEAD)" = "$BASE" \
  || { echo "HEAD moved between Preparation and recording the base — stop and report; do NOT record"; exit 1; }
printf '%s\n' "$BASE" > .context/loop-rule-base \
  || { echo "recording the base FAILED; stop"; exit 1; }
rm -f .context/loop-rule-start
```

**The re-assert narrows the window; it does not remove it**, and saying otherwise would be the
overclaim `AGENTS.md` names. A move landing between that test and the redirect is still recorded. What
the change buys is that the base is now the object Preparation's predicates were **about**, which it
previously was not at all.

**Re-entry — run `## The four procedures` · Resume.** It owns the existing base, the scratch
artifacts and how far the implementation got.

**Why the branch exists at all:** re-recording the base after a partial implementation would capture
the current WIP tip, and both Gate B's range and the final reset would then start *after* every edit
made so far — prompt and hook changes squashed into the closing commit without ever entering a
review range.

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

**Read both copies from the recorded `$BASE`, always — never from the worktree.** The worktree can
carry this plan's own edits, and folding those into the inherited-drift record leaves Task 14 unable
to tell introduced drift from inherited, which is the whole purpose of this baseline. **An earlier
revision selected the source by whether `$BASE..HEAD` was empty**, reading the worktree when it was.
That inference is unsound and this plan says so three times elsewhere: after a `reset --soft` the
range is empty **while the entire implementation sits staged in the index and present in the
worktree** — a state Resume names as valid — so the baseline would have recorded the *implemented*
copies as the original. **A commit range says which commits are reachable; it says nothing about
uncommitted content.** Resume already required the rebuild to read the `$BASE` blobs, so this is the
two sites agreeing rather than a new rule. **No entry-mode flag is needed either**: a first entry
recorded a clean `HEAD` as `$BASE`, so `$BASE` is the right source on every entry.

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
# Always the $BASE blobs. Never the worktree, and never a branch on the commit
# range: after a reset --soft that range is empty while the implementation is
# staged, so "empty range" would select the implemented copies as the original.
git show "$BASE:CLAUDE.md" > .context/loop-rule-c.src \
  || { echo "cannot read CLAUDE.md at $BASE"; exit 1; }
git show "$BASE:plugins/dev-workflow/commands/workflow-init.md" > .context/loop-rule-w.src \
  || { echo "cannot read workflow-init.md at $BASE"; exit 1; }
C_SRC=.context/loop-rule-c.src; W_SRC=.context/loop-rule-w.src
test -s "$C_SRC" && test -s "$W_SRC" || { echo "baseline source empty"; exit 1; }
# Renamed at the end. Every write to this artifact is guarded: an unguarded one lets
# the block build a partial baseline and still reach the rename.
printf 'base\t%s\n' "$BASE" > .context/loop-rule-baseline-diff.tmp \
  || { echo "cannot start the baseline artifact"; exit 1; }

# Tab-separated start and end anchors, written as LITERAL text — the escaping
# for sed happens later, on $se and $ee. Emitting '\*\*Severity:\*\*' here would
# store backslashes that occur in neither copy, and the literal-uniqueness
# check below would then fail at that site on a correct tree.
# Two fields per call so the tab is the format's, not the data's: the anchors
# contain colons, so a colon delimiter would split '**Severity:**' at the
# wrong one. Every entry spans two DIFFERENT anchors — the single-line
# squash-carry site is handled below, not in this loop.
: > .context/loop-rule-sites || { echo "cannot create the site list"; exit 1; }
while IFS= read -r s && IFS= read -r e; do
  printf '%s\t%s\n' "$s" "$e" >> .context/loop-rule-sites \
    || { echo "cannot append the site list"; exit 1; }
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
  printf 'site\t%s\t%s\n' "$s" "$e" >> .context/loop-rule-baseline-diff.tmp \
    || { echo "cannot record the site header for: $s"; exit 1; }
  printf '%s\n' "$d" >> .context/loop-rule-baseline-diff.tmp \
    || { echo "cannot record the site diff for: $s"; exit 1; }
done < .context/loop-rule-sites || exit 1

# The squash-carry sentence is ONE line and must not go through the loop.
# It owes the SAME checks the loop applies, and accounting row 19 promises them for
# every site: unguarded, a missing anchor in both copies yields two empty extractions
# that diff equal, and the site record certifies a line sed never found. Duplicate
# hits would pass the same way.
SQ='On squash-merge, copy every evidence entry'
for f in "$C_SRC" "$W_SRC"; do
  n=$(grep -cF "$SQ" "$f"); st=$?
  test $st -le 1 || { echo "grep failed (status $st) at the squash-carry site in $f"; exit 1; }
  test "$n" = 1 || { echo "squash-carry anchor is not unique in $f ($n hits)"; exit 1; }
done
ca=$(grep -F "$SQ" "$C_SRC") || { echo "cannot extract the squash-carry line from $C_SRC"; exit 1; }
cb=$(grep -F "$SQ" "$W_SRC") || { echo "cannot extract the squash-carry line from $W_SRC"; exit 1; }
test -n "$ca" && test -n "$cb" || { echo "empty extraction at the squash-carry site"; exit 1; }
d=$(diff <(printf '%s\n' "$ca") <(printf '%s\n' "$cb")); st=$?
test $st -le 1 || { echo "diff failed (status $st) at the squash-carry site"; exit 1; }
printf 'site\t%s\t%s\n' 'On squash-merge' 'On squash-merge' >> .context/loop-rule-baseline-diff.tmp \
  || { echo "cannot record the squash-carry site header"; exit 1; }
printf '%s\n' "$d" >> .context/loop-rule-baseline-diff.tmp \
  || { echo "cannot record the squash-carry site diff"; exit 1; }
# Guarded, because the `cat` below would otherwise display a PREVIOUS run's .txt as
# though this sweep had produced it.
mv .context/loop-rule-baseline-diff.tmp .context/loop-rule-baseline-diff.txt \
  || { echo "rename FAILED — the baseline was NOT updated; stop"; exit 1; }
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
git add docs/superpowers/plans/2026-09-14-loop-rule-consolidation.md \
  || { echo "staging FAILED — nothing is committed here; stop and fix the staging"; exit 1; }
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
# Extract first and require both non-empty. This step's success signal is NO output,
# and two anchors that match nothing also produce no output — so an unchecked pair
# reads a parity check that never ran as parity confirmed. Task 0 step 3 applies the
# same rule to its sites.
a=$(sed -n '/^\*\*How a cycle ends/,/^\*\*What a loop absorbs/p' CLAUDE.md)
b=$(sed -n '/^\*\*How a cycle ends/,/^\*\*What a loop absorbs/p' plugins/dev-workflow/commands/workflow-init.md)
test -n "$a" && test -n "$b" || { echo "empty extraction — the installed §A block was not found in both copies"; exit 1; }
diff <(printf '%s\n' "$a") <(printf '%s\n' "$b")
```

Expected: no output.

- [ ] **Step 6: Commit**

```bash
git add CLAUDE.md plugins/dev-workflow/commands/workflow-init.md \
        docs/superpowers/plans/2026-09-14-loop-rule-consolidation.md \
  || { echo "staging FAILED — nothing is committed here; stop and fix the staging"; exit 1; }
git commit -m "WIP: install the closure ordering into both §5 copies"
```

**The plan is staged here because this task writes its fragment evidence into the plan**, and the
rule is stated by behaviour rather than by a list of task numbers: **every task that appends a
fragment-table row or records an observation in `## Fragment evidence (per-task output)` stages
this plan in its own commit.** On the current shape that is every editing task, Tasks 1 and 3–11,
but the rule is the behaviour and a task that stops recording stops owing it.

**A task-number list here was wrong twice** — it named Tasks 3, 4, 6, 7 and 8 while Tasks 5, 9, 10
and 11 also record — and a stale list is the same defect as a stale count. **The cost of the
omission is concrete:** the evidence stays out of its own task's `WIP:` snapshot, so the reviewed
range does not hold it where the task claims, and if execution continues it is swept into a later
unrelated commit rather than the independently reviewable snapshot this plan promises. **Not a
clean-tree argument** — Resume requires no clean tree in any state it can meet; an earlier draft said re-entry needs one, which would have rejected the very states Resume
exists to reconcile.

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
        docs/superpowers/plans/2026-09-14-loop-rule-consolidation.md \
  || { echo "staging FAILED — nothing is committed here; stop and fix the staging"; exit 1; }
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
rationale still counts `parent=1 worktree=1` in each copy.

*(Build each pair per the verification procedure; record the four values.)*

Expected: for the three pairs, six pair instances reading
`old/worktree=0 old/parent=1 new/worktree=1 new/parent=0`; for the five absence checks,
`parent=1 worktree=0` in each copy. **Every OLD row was derived and validated at step 1**; this
step only runs them.

- [ ] **Step 5: Walk the conditions** — **every disposition row this task's block covers, read off
  the table the way step 4b already says to**, not off a list here. The list this step used to carry
  omitted `c4`, which has a pair at step 4 and was therefore counted and never read (pass 36); a
  closed list in a task is the second copy of the disposition table, and this is the second one it
  has cost this cycle. **This is a reader's confirmation on top of step 4's counts, not the
  observation for any of them** — each of these is counted there, and a walk that found what the
  counts missed would mean a fragment was wrong rather than that the walk was the check.

For orientation, and not as the set owed: `c1`–`c3` present unchanged; **`c4` carrying the narrowed
reading** — a missing condition now means only that *this* exit does not apply; `c5`–`c7` word for
word; `c8` carrying the re-raised-dismissal clause; `c9` moved out with the plateau rationale still
here; `c10`–`c14` gone from here.

- [ ] **Step 6: Commit**

```bash
git add CLAUDE.md plugins/dev-workflow/commands/workflow-init.md \
        docs/superpowers/plans/2026-09-14-loop-rule-consolidation.md \
  || { echo "staging FAILED — nothing is committed here; stop and fix the staging"; exit 1; }
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
- **`e9` is carried** — its count is `parent=1 worktree=1` in each copy after the install, from the single-line
  fragment step 1 appended rather than from the whole wrapped clause.
- **`e8` is aligned rather than untouched** — this task gives W the pronoun, so listing `e8` among
  the untouched conditions would contradict the task's own instruction.

- [ ] **Step 5: Commit**

```bash
git add CLAUDE.md plugins/dev-workflow/commands/workflow-init.md \
        docs/superpowers/plans/2026-09-14-loop-rule-consolidation.md \
  || { echo "staging FAILED — nothing is committed here; stop and fix the staging"; exit 1; }
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
# Same rule as the §A parity check: no output is this step's success signal, so two
# anchors that match nothing would read as byte-identical.
a=$(sed -n '/^- \*\*Severity:\*\*/,/^- \*\*Tool routing:/p' CLAUDE.md)
b=$(sed -n '/^- \*\*Severity:\*\*/,/^- \*\*Tool routing:/p' plugins/dev-workflow/commands/workflow-init.md)
test -n "$a" && test -n "$b" || { echo "empty extraction — the Severity passage was not found in both copies"; exit 1; }
diff <(printf '%s\n' "$a") <(printf '%s\n' "$b")
```

Expected: no output. This passage should now be byte-identical, `g4` having been removed and `g2`/`g3` having gone from both copies.

- [ ] **Step 6: Commit**

```bash
git add CLAUDE.md plugins/dev-workflow/commands/workflow-init.md \
        docs/superpowers/plans/2026-09-14-loop-rule-consolidation.md \
  || { echo "staging FAILED — nothing is committed here; stop and fix the staging"; exit 1; }
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
- **a preservation count** to `parent=1 worktree=1` in each copy for each of the nine carried
  conditions and each kept condition in passage (i), from the fragments step 1b appended — the
  result the disposition table owes, which an earlier wording gave here as `1` alone;
- **a presence check** — `new/worktree=1 new/parent=0` in each copy — for §G's semantic membership
  test and for every independent add-only clause in the strict-reading tail.

Choose each post-install fragment from the installed text, verify it the three ways before counting
it, and record all of them in this task's fragment evidence.

- [ ] **Step 4: Confirm every carried condition in this task's blocks survived**

They are reproduced inside blocks that install contiguously, so a mis-scoped replacement silently
drops them — and because they are carried rather than kept, **no untouched-range span covers
them**, which is exactly why the disposition records them as carried. **Each owes a count of its
own text in each copy, to `parent=1 worktree=1`** — the result the disposition table owes a
carried condition.

**The set is every condition the disposition table marks *carried* inside this task's ten blocks**,
and it is read from there rather than listed here. An earlier draft named three of them and left
the rest to P8 and P16, which observe the *changed* clauses around them and prove nothing about the
reproduced words: both copies could omit the surfacing premise, or any interior item of the
strict-reading run, and every pair, presence check and parity comparison would still pass.

**All nine fragments were derived and appended at step 1b**, from the live text before step 2
installed over it. Two of them, for orientation:

```bash
grep -cF 'advisory — validate before applying; dismissed finding → one-line why' CLAUDE.md
grep -cF 'Open a TodoWrite' CLAUDE.md
```

Expected: `1` each in the worktree, and `parent=1 worktree=1` in each copy for every one of the nine.

**A fragment is line-local by construction, and that is established by running its `grep -cF` before
it is written down, never after.** The first example above began as `Codex is advisory — validate
before applying; …` and counted **zero in both copies**: the sentence wraps between `Codex is` and
`advisory`, so the literal never occurs. A *correct* source text failed its own preservation check.
That is the second time in this cycle a hand-written fragment crossed a line break — carried `e9`'s
clause was the first, at pass 10 — so the rule is stated here rather than left to the next author's
care.

- [ ] **Step 5: Parity** for all ten sites, each extracted by its own bounded region rather than a fixed line window.

- [ ] **Step 6: Commit**

```bash
git add CLAUDE.md plugins/dev-workflow/commands/workflow-init.md \
        docs/superpowers/plans/2026-09-14-loop-rule-consolidation.md \
  || { echo "staging FAILED — nothing is committed here; stop and fix the staging"; exit 1; }
git commit -m "WIP: install the one-contract paragraph and the remaining prompt-copy replacements"
```

---

## Task 8: Replace §F's items 1–9 in both copies

**Files:**
- Modify: `CLAUDE.md`, `plugins/dev-workflow/commands/workflow-init.md`
- Modify: `docs/superpowers/plans/2026-09-14-loop-rule-consolidation.md` — the rows this task appends and its fragment evidence
**The bytes:** target §F items 1, 2, 3, 4, 5, 6, 7, 8, 7a, 8a, 8b, 9a, 9b and 9 — fourteen items, each with its own fenced replacement and its `C nnn` / `W nnn` citation. **Re-read every citation against the current file**: §F's own collected list records that items 4, 5 and 8 have line citations one off, and the numbers drifted further as this cycle edited the copies.

**Which conditions this task discharges is decided by `## How a task discharges that table`, run
against the disposition rows for the blocks these fourteen items replace — not by a list here.**
This line carried one: it named `h4`, `h5` and `h19` and silently omitted **carried `h3` and carried
`a1`**, and that is how `h3` reached pass 35 with no observation at all. An enumeration inside a
task is the second copy of the disposition table, which this plan forbids two sections up and has
now been bitten by from inside the section that forbids it. As orientation, not as the set owed:
item 7 carries both the `h4` and `h5` destinations, and item 4 the `h19` scope sentence.

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

**And derive the preservation fragment of every carried condition these blocks cover, here** — they
are pre-existing text, so the fragment-table cut puts them in the table before the install like
every other pre-existing fragment, under the next free `P` id. `## How a task discharges that
table` is what says which conditions those are. **Two of them are invisible without the block open,
and both have been missed:**

- **`a1`**, carried inside item 8a's block, which opens with it — `**Both gates are a LOOP with a
  HARD FLOOR: a minimum number of passes per run`. Row F10's pair observes `a2`, the parenthetical,
  not the opening it sits in.
- **`h3`**, carried inside item 7's block, which reproduces `an ungated change records it in that
  commit` verbatim because the item replaces the whole `**Which commit:**` sentence and only the
  Gate-A clause changes. **Neither F7 nor F7b can stand in for it:** both are OLD halves required to
  reach **zero**, F7 runs from `h3`'s own wording into the changed `h4` wording, and item 7's NEW
  text is not constrained to carry `h3` at all. So item 7 could drop that clause from both copies
  with all fifteen pairs, the parity diff and the battery still green — pass 35, and the fourth time
  in this cycle a carried or kept condition lost its only observation.

An earlier draft chose `a1`'s fragment at step 4, after item 8a had already replaced the block: at
that point a drifted or half-installed HARD FLOOR opening cannot be told from the intended carried
text, and no authored fragment exists for Task 15 to audit. **The same applies to `h3` and to every
other fragment on this list** — derive before installing, never after.

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

- [ ] **Step 4: Confirm the carried conditions survived, then count what was installed**

**Count every preservation fragment step 1 appended** — in each copy, to the result its class owes:
`parent=1 worktree=1`, per `## What each disposition owes, stated once`. **Both values matter.** The
worktree half is what proves the block preserved the condition; the parent half is what proves the
fragment was ever in the file it claims to observe, so a mistyped one reports `parent=0 worktree=0`
instead of a healthy-looking `1`. Record each as a `preservation` line in this task's fragment
evidence — which is what carries it into Task 15's re-run set and the closing evidence entry.

**No untouched-range span covers any of them**, which is why each owes its own count. Without these
counts a mis-scoped replacement passes every other check in this task: item 8a can drop the HARD
FLOOR sentence's opening, and item 7 can drop `an ungated change records it in that commit`, while
all fifteen pairs, the parity diff and the battery stay green.

Then total the fifteen `new/worktree` values step 3 printed, per copy.

Expected: `15` per copy — **fifteen independent changed clauses, from fourteen installed items**.
State the number you observed. **Do not carry a count from §F into a check** — §F states the count of falsified sentences and this task installs a subset of them; a count copied between the two is the stale-bookkeeping defect the design records at five passes running.

- [ ] **Step 5: Parity** for all fourteen sites.

- [ ] **Step 6: Commit**

```bash
git add CLAUDE.md plugins/dev-workflow/commands/workflow-init.md \
        docs/superpowers/plans/2026-09-14-loop-rule-consolidation.md \
  || { echo "staging FAILED — nothing is committed here; stop and fix the staging"; exit 1; }
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
        docs/superpowers/plans/2026-09-14-loop-rule-consolidation.md \
  || { echo "staging FAILED — nothing is committed here; stop and fix the staging"; exit 1; }
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
# The diff is captured before it is filtered. In a pipeline the status is the LAST
# element's, and `sed` succeeds on empty input, so a failed `git diff` would print an
# empty list of changed lines — indistinguishable from a hook nobody edited.
# `pipefail` is not available here: these blocks run under sh and dash too.
DIFFOUT=$(git diff -U0 "$BASE" -- plugins/dev-workflow/hooks/codex-gate.sh) \
  || { echo "git diff FAILED — the changed-line list is unestablished; stop"; exit 1; }
printf '%s\n' "$DIFFOUT"                         # READ EVERY REMOVED AND ADDED LINE
printf '%s\n' "$DIFFOUT" | grep -E '^@@' | sed -E 's/^@@ -([0-9]+).*/\1/'
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
        docs/superpowers/plans/2026-09-14-loop-rule-consolidation.md \
  || { echo "staging FAILED — nothing is committed here; stop and fix the staging"; exit 1; }
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
        docs/superpowers/plans/2026-09-14-loop-rule-consolidation.md \
  || { echo "staging FAILED — nothing is committed here; stop and fix the staging"; exit 1; }
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
git add docs/superpowers/plans/2026-09-14-loop-rule-consolidation.md \
  || { echo "staging FAILED — nothing is committed here; stop and fix the staging"; exit 1; }
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
git add docs/superpowers/plans/2026-09-14-loop-rule-consolidation.md \
  || { echo "staging FAILED — nothing is committed here; stop and fix the staging"; exit 1; }
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
git add docs/superpowers/plans/2026-09-14-loop-rule-consolidation.md \
  || { echo "staging FAILED — nothing is committed here; stop and fix the staging"; exit 1; }
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
  # Guarded: these two paths are REUSED on every iteration, so a failed write leaves
  # the previous site's text standing and the diff below classifies bytes this
  # iteration never extracted.
  printf '%s\n' "$a" > .context/loop-rule-a.txt \
    || { echo "cannot write the C-side extract for: $s"; exit 1; }
  printf '%s\n' "$b" > .context/loop-rule-b.txt \
    || { echo "cannot write the W-side extract for: $s"; exit 1; }
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
git add CLAUDE.md plugins/dev-workflow/commands/workflow-init.md docs/superpowers/plans/2026-09-14-loop-rule-consolidation.md \
  || { echo "staging FAILED — nothing is committed here; stop and fix the staging"; exit 1; }
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
git add plugins/dev-workflow/.claude-plugin/plugin.json plugins/dev-workflow/CHANGELOG.md \
  || { echo "staging FAILED — nothing is committed here; stop and fix the staging"; exit 1; }
git commit -m "WIP: bump dev-workflow to 0.12.0"
```

`scripts/check-version-bump.sh` compares **commits**, so the bump must be committed before the battery runs.

- [ ] **Step 4b: Apply all twelve `docs/prompt-standards.md` items to the installed text, and commit the result before Gate B**

**It keeps the letter `4b` and runs BEFORE step 4 — execute this file in reading order, not in
alphabetical order.** The name is unchanged because six places elsewhere cite "step 4b" and a rename
would have to reach every one of them. **The position is what changed, and it is the repair:** this
is the **last step that may alter content**, and until it has committed there is no candidate to
verify. It previously sat after the battery and after step 4c, so both of them certified a head that
4b's own commit then replaced — and a 4b repair to a shipped prompt or hook was absent from
everything that had already run.

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
outcome this step exists to prevent. **On any failure: repair the text, then re-run every
record-producing check the repair invalidated** — the affected pairs, presence, absence and
preservation counts, the parity and untouched checks over the blocks touched — and commit the repair
with the refreshed record in the block below. **The battery is not among them here**: it runs on the
committed candidate, which does not exist until that block has run, and step 4 runs it right after
(pass 53, finding 1).

**Record the subject set once, at the top of the output section**, and make each item's result
refer to it: the §A–§H blocks installed in C, the same in W, and **ten hook prompt bodies, not
seven** — the seven `additionalContext` bodies items 10–13, 15–17 replace, **plus the three
`systemMessage` bodies** items 12, 15 and 16 replace alongside them. Those three are short
operator-facing prompts and they ship; counting the messages rather than the bodies leaves them
outside invariant 11's only reader gate.

**Twelve `PASS` lines alone cannot be told from a review that skipped a copy or a channel** — the
subject list is what makes the twelve lines mean something.

**Commit the result before step 6 — and on a failure, commit the repaired files with it.** Gate B
reviews the range `$BASE..HEAD`; an edit left in the worktree is in neither that range nor the final
`reset --soft`, which stages only what the discarded commits contained. **An earlier revision staged
only this plan**, so a repair made under the failure branch above stayed in the worktree: Gate B
never saw it, and the close's exact-dirty-set check then refuses a dirty prompt copy, so the cycle
dead-ends. Staging it *after* the review instead breaks the reviewed-head condition — there is no
later moment that works.

**Stage the repaired artifacts by name, and only those.** `git add -A` would carry unrelated work in
the tree into a range a reviewer is about to read as this change. On the first pass the repairable set is
the installed text this step judges: the two prompt copies, the hook and its test. **A step-7 repair
through this block names its own set** — which can include the spec or target text, since a fix that
changes specified behaviour updates the spec in the same commit, and `plugin.json` and
`CHANGELOG.md` where 4c's repair owes them (pass 54, finding 3). **Only the files the repair actually
touched go in**, together with this plan's refreshed record — and the re-run records
must describe *that* commit, which is why the re-runs above come first.

**Staging and commit are both guarded, and the commit is checked against what it was given**, because
step 6 issues Gate B over the range this commit ends: a failed `git add` otherwise falls through to a
commit that can still succeed on content the index already held, and the review then runs over a range
missing its repair. The pin is **the whole index, unrelated paths included**, demanding no presence,
since a repair here may delete a file too.

```bash
# Stage this plan plus exactly the files the authorized repair touched, each named — never
# `-A`. First pass: from CLAUDE.md, plugins/dev-workflow/commands/workflow-init.md,
# plugins/dev-workflow/hooks/codex-gate.sh, plugins/dev-workflow/hooks/codex-gate.test.sh.
# A step-7 repair also names the spec or target text where the fix changes specified
# behaviour, and plugin.json / CHANGELOG.md where 4c's repair owes them.
# Step 7 runs this block with its own LITERAL message — "WIP: fix <finding>" or
# "WIP: refreshed records" — written into the command itself, never through a variable:
# the gate hook reads the command string for `-m … wip`.
git add docs/superpowers/plans/2026-09-14-loop-rule-consolidation.md <the repaired files, if any> \
  || { echo "staging FAILED — step 6 must not issue Gate B over this range"; exit 1; }
ITREE=$(git write-tree) \
  || { echo "cannot pin the staged index; do not proceed to step 6"; exit 1; }
git commit -m "WIP: plan records" \
  || { echo "commit FAILED — step 6 must not issue Gate B over this range"; exit 1; }
# Resolve the new commit ONCE, and use that one id for the tree check AND the candidate
# record. Every candidate commit — this first one and every repair — uses this block. Checking `HEAD^{tree}` and then
# resolving `HEAD` again in a later block let the recorded candidate differ from the
# commit whose tree was checked (pass 52, Blocker 1).
CAND=$(git rev-parse --verify "HEAD^{commit}") \
  || { echo "cannot resolve the new commit — do not proceed to step 6"; exit 1; }
test "$(git rev-parse "$CAND^{tree}")" = "$ITREE" \
  || { echo "the commit's tree is not the index that was pinned; do not proceed to step 6"; exit 1; }
# No `cat` after the redirect: a failed write with a following `cat` prints a stale value
# and the block still exits 0.
printf '%s\n' "$CAND" > .context/loop-rule-reviewed-head \
  || { echo "recording the candidate head FAILED — no verification and no call may run"; exit 1; }
```

**The same applies to every record this plan collects** — the sweep, the next-state table, the
divergence list.

**`check-invariants.sh` includes the prompt-conformance checks** — a `Target model:` line naming one recognized model, a prose checklist-count claim matching the checklist, and the finding-severity vocabulary as a closed set in both prompt copies. Those three are a floor, not coverage; invariant 11's other eleven items are judged by a reader.

**The commit block above also fixes the candidate, once — this is the only place a candidate
identity is created on the first pass.** It records the **same object id** whose tree it just
compared with the pinned index, in the same invocation; a separate block that resolved `HEAD` again
could record a different commit from the one checked (pass 52, Blocker 1). The consumers that take
an **object id** read it from this file and never resolve a ref again to obtain it: **step 4's
battery**, **step 4c**, **Gate B's `headSha`** and **Close condition 1** are four consumers of one
value rather than independent resolutions of a movable ref — the defect passes 47–49 kept finding
and pass 51 found again between 4c and step 6.

**The file is `.context/loop-rule-reviewed-head`, which already exists and already means this.** It
needs no new recovery rule, no new cleanup entry and no new state: Close condition 1 already reads
it, this same block rewrites it for every repaired candidate in step 7, and the close removes it.
**Writing it at 4b rather than at step 6** is what keeps one candidate from being verified as one
object and reviewed as another — step 6 used to resolve `HEAD` itself.

- [ ] **Step 4: Run the full quality battery**

**First fetch the base ref, because one step in the battery has a precondition the others do not.**
`check-version-bump.sh` compares *commits* against a base ref, so a stale base compares the bump
against a different commit than the pull request will, and the run is green about the wrong
comparison. **Fetch, then pass the fetched ref to the checker itself** — an earlier draft fetched
`origin/main` while the battery went on passing the local `main`, and recorded `origin/main` as
what supplied a comparison it had not supplied:

```bash
# Both guarded, and no `cat`. A failed fetch leaves whatever an earlier one wrote in
# `origin/main`, and `git rev-parse` resolves that stale ref happily — the block would
# exit 0 having recorded a base the pull request does not have. A failed write is the
# same shape: the `cat` after it printed the older recorded value.
git fetch origin main \
  || { echo "fetch FAILED — origin/main is whatever an earlier fetch left; do not run the battery"; exit 1; }
git rev-parse origin/main > .context/loop-rule-baseref \
  || { echo "recording the base ref FAILED — do not run the battery"; exit 1; }
```

**Pass that object name to `check-version-bump.sh`, not `origin/main`.** A remote-tracking ref is
mutable: another fetch between the record and the run makes the evidence name one commit while the
checker resolves another, and the claim that the recorded revision is the argument the check
received would be false. The object name is the argument.

**It goes to a file, not to a shell variable**, for the reason Task 0 gives about `$BASE`: each
fenced block below runs in its own shell invocation, so a `BASEREF=` assignment here is gone by the
time the battery runs and the checker would receive an empty argument. The battery reads it back.

```bash
HEADID=$(cat .context/loop-rule-reviewed-head) \
  || { echo "battery UNRESOLVED: no candidate head recorded — step 4b did not complete"; exit 2; }
test "${#HEADID}" -eq 40 || { echo "battery UNRESOLVED: candidate head is not a full object name"; exit 2; }
BASEREF=$(cat .context/loop-rule-baseref) \
  || { echo "battery UNRESOLVED: no recorded base ref — the fetch step did not run"; exit 2; }
test -n "$BASEREF" || { echo "battery UNRESOLVED: recorded base ref is empty"; exit 2; }

BT=$(mktemp -d) || { echo "battery UNRESOLVED: cannot create the disposable repository"; exit 2; }
# The same disposable-clone shape as step 4c: --shared borrows objects and writes nothing
# back, so the work repo, its index, its worktree and its branches are untouched.
git clone -q --shared --no-checkout . "$BT/r" || { echo "battery UNRESOLVED: clone failed"; exit 2; }
cd "$BT/r" || { echo "battery UNRESOLVED: cannot enter the clone"; exit 2; }
git checkout -q --detach "$HEADID" \
  || { echo "battery UNRESOLVED: the candidate does not resolve in the clone"; exit 2; }
test "$(git rev-parse HEAD)" = "$HEADID" \
  || { echo "battery UNRESOLVED: the clone is not at the candidate"; exit 2; }
ST=$(git status --porcelain) || { echo "battery UNRESOLVED: cannot read the clone's status"; exit 2; }
test -z "$ST" || { echo "battery UNRESOLVED: the fresh checkout is not clean"; exit 2; }

printf 'battery candidate=%s base=%s\n' "$HEADID" "$BASEREF"
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
claude plugin validate . --strict \
  || { echo "battery FAILED on candidate $HEADID"; exit 1; }
echo "battery PASSED on candidate $HEADID"
```

Expected: exit 0. **`$BASEREF`, not `main` and not `origin/main`** — AGENTS.md's battery row writes
`main` because a human running it locally usually has one; here the base is the fetched commit,
resolved once, so the recorded revision and the argument the successful check received are the same
value by construction.

**The battery runs on the candidate, not on the working tree** (pass 52, Blocker 2; scope decided by
Daniel on 2026-09-25 as option B). It reads the candidate id from `.context/loop-rule-reviewed-head`
and runs in a fresh disposable clone checked out at that id — the same `--shared` clone shape step 4c
already uses — so uncommitted changes in the work repository cannot supply its inputs. **Three
outcomes:** `0` passed on the named candidate; `1` failed on it; `2` unresolved — the check could not
be set up, which is **neither a pass nor a failure** and, like a failure, stops here. The first
printed line names the candidate and the base it ran against; that line belongs to the evidence.

**What this does not do.** A clone is not an immutable runtime: a test can still change files inside
its own clone while it runs. It checks the **candidate commit**, not the merge result CI builds —
that is step 4c's separate observation, with its own revision named — and a later CI run does not
replace it. The clone is left in a temporary directory and not cleaned up here.

**Old conditions, accounted.** Kept: the fetch-and-record of the base ref, the base passed as an
object id, the full battery in AGENTS.md order, exit 0 as the pass, and the rule that a failure stops
before step 5. Changed deliberately: the subject — from "the working tree as it stands when it runs"
to the recorded candidate — and the disclosed limit "nothing enforces that the worktree stays
unmodified", which no longer applies to the battery's inputs. Added: exit `2` for a setup failure,
matching step 4c.

- [ ] **Step 4c: Check the version requirement against the MERGE RESULT, not only the branch head**

**Why this exists, stated as the comparison each side actually performs.** Step 4 runs
`check-version-bump.sh` against the **local branch head**. `.github/workflows/ci.yml` passes no
`ref:` to `actions/checkout`, so a `pull_request` job evaluates the **merge commit** instead. Those
are different objects, and **refreshing the base ref does not make them the same one** — which is why
step 4's fetch is a precision fix and not the repair for this. Demonstrated with the unchanged
checker: a branch that bumps to a version `main` has meanwhile reached **on its own**, while carrying
further plugin changes, **passes against the stale base and is rejected against the current one**.

**This step does not change step 4's battery or the Gate-B review range.** It is an additional,
isolated observation; both existing checks keep their inputs and their meaning.

```bash
# The candidate identity comes from the file step 4b wrote — NEVER from a placeholder and
# never from a fresh resolution. This is the same value the battery ran against, the same
# value step 6 passes as `headSha`, and the same value Close condition 1 authenticates.
HEADID=$(cat .context/loop-rule-reviewed-head) \
  || { echo "4c UNRESOLVED: no candidate head recorded — step 4b did not complete"; exit 2; }
test "${#HEADID}" -eq 40 || { echo "4c UNRESOLVED: candidate head is not a full object name"; exit 2; }
BASEID=$(cat .context/loop-rule-baseref)   # the base object name step 4 already recorded
test -n "$BASEID" || { echo "4c: no recorded base ref — step 4 did not run"; exit 2; }

WT=$(mktemp -d) || { echo "4c UNRESOLVED: cannot create the disposable repository"; exit 2; }
# --shared borrows objects and writes nothing back: the work repo, its index and its
# branches are untouched by everything below.
git clone -q --shared --no-checkout . "$WT/r" || { echo "4c UNRESOLVED: clone failed"; exit 2; }
cd "$WT/r" || { echo "4c UNRESOLVED: cannot enter the clone"; exit 2; }

# Pin the INTENDED checker FROM THE CANDIDATE — the one step 4's battery ran with — before
# anything is merged. Read it by object id, not from a worktree: a worktree may sit on the
# base side and already carry the very edit this check exists to catch, in which case the
# comparison is against itself and always agrees.
git show "$HEADID:scripts/check-version-bump.sh" > "$WT/intended-checker" \
  || { echo "4c UNRESOLVED: cannot read the checker at the candidate head"; exit 2; }

# DIRECTION: check out the BASE and merge the CANDIDATE into it. That is the order
# `refs/pull/N/merge` is built in, and it is what `actions/checkout` hands a
# `pull_request` job. The reverse order produces the same tree for an ordinary merge but
# not necessarily under direction-sensitive behaviour — merge drivers and `.gitattributes`
# among them — so the cheap way to be about CI's object is to build it the way CI does.
git checkout -q --detach "$BASEID" 2>/dev/null \
  || { echo "4c UNRESOLVED: recorded base does not resolve here"; exit 2; }

# A conflict is an UNRESOLVED check, never a verdict. No merge strategy option, no manual
# resolution, no retry: resolving it here would invent a merge result nobody reviewed.
git -c user.email=v@v -c user.name=v merge --no-edit -m "4c merge result" "$HEADID" >/dev/null 2>&1 \
  || { git merge --abort >/dev/null 2>&1
       echo "4c UNRESOLVED: merging the candidate into the base conflicts — report and stop"; exit 2; }
R=$(git rev-parse HEAD) || { echo "4c UNRESOLVED: cannot resolve the merge result"; exit 2; }

# THE BYTE CHECK BELONGS HERE, AFTER THE MERGE — these are the bytes that will actually
# run. Comparing before the merge establishes nothing about them: the base side can carry
# a different checker, and a merge that takes it succeeds without conflict. The checker
# must also run INSIDE this clone: its line 58 is `cd "$(dirname "$0")/.."`, so an
# ABSOLUTE-PATH invocation from elsewhere silently runs it against its own source tree
# and answers about the wrong repository — which is how an earlier attempt at this check
# produced a confident wrong negative. The relative call below is what binds it here.
cmp -s scripts/check-version-bump.sh "$WT/intended-checker" \
  || { echo "4c UNRESOLVED: the checker in the MERGE RESULT differs from the one at the pinned head"; exit 2; }

# The record. Every id is a full object name; the diff and the status are observations.
printf '4c head=%s\n4c base=%s\n4c merge-result=%s\n' "$HEADID" "$BASEID" "$R"
printf '4c plugin diff base..R: %s\n' "$(git diff --name-only "$BASEID" "$R" -- plugins/ | tr '\n' ' ')"

# Preserve the output and the RAW status. `check-version-bump.sh` exits 1 from BOTH
# `fail()` (a policy violation) and `die()` (an operational failure such as an
# unresolvable ref or a git call that errored), so a bare 1 does not establish which
# happened. Nonzero is therefore recorded as NOT VERIFIED with its cause undetermined;
# a person reads the preserved output to establish it. No parser is built here, and the
# checker's interface is not touched.
out=$(sh scripts/check-version-bump.sh "$BASEID" 2>&1); st=$?
printf '%s\n' "$out"
printf '4c raw checker exit=%s\n' "$st"
if [ "$st" -eq 0 ]; then
  echo "4c VERIFIED: the version rule holds on the merge result"; exit 0
fi
echo "4c NOT VERIFIED: the checker exited $st — cause UNDETERMINED from the status alone."
echo "4c   exit 1 is BOTH a policy violation (fail) and an operational failure (die)."
echo "4c   Read the preserved output above to establish which, before calling it either."
exit 1
```

**Three outcomes, and what each one does and does not assert.** `0` — **verified**: the version rule
holds on this merge result. `1` — **not verified**: the checker exited nonzero, and **that is all the
status establishes**. `2` — **unresolved**: the check could not be carried out at all.

**Non-zero is never reported as "the version is wrong" on the strength of the exit code.**
`scripts/check-version-bump.sh` exits `1` from `fail()` for a policy violation **and** from `die()`
for an operational failure — an unresolvable ref, a git call that errored, an unparseable manifest.
The two are indistinguishable by status, so 4c preserves the **output** and the **raw status** and
requires the cause to be established from that output before anyone describes it as a version
violation. **Both cases stop progression**, so nothing depends on guessing. **Unresolved is neither a
pass nor a failure**, and a single non-zero code would have made a merge conflict indistinguishable
from a checker verdict.

**When it runs, and why it binds BEFORE Gate B.** 4c runs **after step 4b has fixed the candidate and
the battery has passed, and before step 5 writes the evidence entry** — on the first pass and on
every rerun, the same sequence. **A non-zero or unresolved 4c stops here**: no evidence entry is
written on it, and no Gate-B call is issued.

**It cannot bind at 7b instead, and that was a real error in an earlier proposal.** Step 6 must hand
the reviewer **the evidence entry quoted verbatim**, and 7b states that if revalidation changes that
entry **the candidate is over**. A binding 4c result appearing first at 7b would therefore change the
entry the final reviewer had judged and force another candidate — the exact round this step exists to
avoid.

**Where the result is carried, using a file that already exists.** Into
`.context/loop-rule-closing-msg`, which step 5 opens **before** Gate B and step 8 commits. **It is
gitignored, so writing it creates no commit** — which is what breaks the
record-commit/reverification cycle without any new state file, parser or recovery subsystem. 7b
rebuilds that message whole and **preserves this entry unchanged** unless revalidation genuinely
changes it, in which case the existing re-review rule applies untouched.

**What the evidence covers, as an identity.** One pinned pair: the **candidate head** in
`.context/loop-rule-reviewed-head` and the **base object name** in `.context/loop-rule-baseref`. The
record names both, plus the merge result. **Re-run 4c whenever either side of that pair changes** —
a repair commit through the step-4b block writes a new candidate head, a fetch may move the recorded base — and whenever the
checker or a plugin manifest changes. **No commit is made between 4c and the call it precedes**, so
nothing can move the head it just certified.

**The evidence boundary, stated rather than implied.** This verifies **the merge of one pinned pair
of commits**. It says nothing about a `main` that advances afterwards — that merge result does not
exist yet and cannot be checked here — and it is **not a check of CI as a whole**: it runs one script
against one merge result, while a CI run does more. `design.md` §7 requires the battery green at the
Gate-B WIP commit and **promises nothing about a later merge commit**; this step narrows that gap for
one pinned pair and does not close it.

**Verified by execution of this block as extracted from this plan, with the unchanged
`scripts/check-version-bump.sh` inside each fixture repository** — eight cases, expected against
observed:

| case | want | got |
|---|---|---|
| valid version bump | 0 verified | **0** |
| same version both sides + plugin diff | 1 not verified | **1**, and the policy cause is present in the preserved output |
| **operational failure inside the checker** (a plugin directory name outside its grammar → `die`) | 1 not verified | **1**, and **not** described as a version violation |
| **conflict-free merge that changes the checker's bytes** | 2 unresolved | **2**, refused **before** the checker ran |
| merge conflict | 2 unresolved | **2** |
| unresolvable pinned head | 2 unresolved | **2** |
| no recorded base ref | 2 unresolved | **2** |
| the source repository afterwards | unchanged | **branch unchanged, 0 staged, 0 dirty** |
| an unresolvable **candidate head** read from the file | 2 unresolved | **2** |

**Re-run after the direction change and the identity change**, with the candidate read from
`.context/loop-rule-reviewed-head` and the merge built base-first: all of the above still hold, and
the stale-base control still reproduces the false green. The direction change moved no verdict in
these fixtures — which is expected, since none of them uses a merge driver — so it is adopted
**because it matches how CI builds the object**, not because a fixture showed a difference.

**Two of those cases exist because earlier drafts of this step failed them.** The operational-failure
case is why non-zero is no longer read as a verdict. The byte-change case is why the comparison
happens **after** the merge and against the checker **at the pinned head** — an earlier draft compared
against the source repository's *worktree*, which can already sit on the base side and carry the very
edit the check exists to catch, so the comparison agreed with itself and the modified checker ran.
**A green result from a check that cannot go red is not evidence**, which is the rule this step is
built to respect.

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

**And the step-4c result, which is the one item read from this run rather than from a section.**
Record its three ids — candidate head, base, merge result — its plugin diff line and its raw checker
status. **It is written here because Gate B is handed this entry verbatim**: a merge-result check
whose result appears only after the review would change the entry the reviewer judged, and 7b says a
changed entry ends the candidate. **4c has already stopped the step if it was not verified**, so the
only status this entry can carry is a verified one.

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
# This step RESOLVES NOTHING. The candidate was fixed by step 4b and verified under that
# identity by the battery and step 4c; resolving `HEAD` again here is how the verified
# object and the reviewed object came apart.
HEADREV=$(cat .context/loop-rule-reviewed-head) \
  || { echo "no candidate head recorded — step 4b did not complete; no call may be issued"; exit 1; }
test "${#HEADREV}" -eq 40 || { echo "candidate head is not a full object name"; exit 1; }
# A move since the candidate was fixed is a STOP, never something to record over: the
# verification above describes $HEADREV and nothing else.
test "$(git rev-parse HEAD)" = "$HEADREV" \
  || { echo "HEAD has moved since the candidate was fixed — re-run 4b onward; no call may be issued"; exit 1; }
```

**The head is written by the step-4b commit block and read here.** A repair in step 7 runs that
same block — it is the only writer. It is what makes "a clean response against that
exact `HEAD`" a comparison rather than a claim: without it the close procedure has nothing to hold
`HEAD` up against, and a commit landing after the response is indistinguishable from the reviewed
state. **An earlier revision resolved `HEAD` here instead**, which gave the same candidate two
identities — the one 4c certified and the one Gate B reviewed — with nothing comparing them.

**`baseSha` is `$BASE`, never `HEAD^`.** This plan makes a WIP commit per task, so `HEAD^` is the
parent of the *last* one and the review range would hold the version bump alone — Gate B would
close having reviewed none of the prompt or hook changes. `$BASE` is the parent of the first WIP
and is the only value whose range contains the whole implementation.

`mcp__codex__review` with `reviewType: full`, `baseSha` = `$BASE`, `headSha` = **the exact content of `.context/loop-rule-reviewed-head`**, read at the moment the call is built and passed as a literal value — **never a fresh resolution of `HEAD`, and never the symbolic `HEAD`**. The file is the identity; the call quotes it, and the same value is kept with each branch's result. **If you cannot show that the value you passed and the file's content are the same string, the call has not been issued** and the reviewed head is unestablished. Carry the story path and the evidence entry quoted verbatim.

**Not guarded, and stated rather than implied.** Nothing mechanically compares the argument actually
sent to the reviewer against this file: the call is not shell, so there is no command to guard, and
`mcp__codex__review` reports no reviewed revision to read back. Close condition 1 therefore
authenticates **the file**, and the file is trustworthy only because the step above wrote it under a
guard and no other step touches it. A second resolution of `HEAD` here would break that chain
silently — Gate B would review one commit while the close authenticates another, and the content that
then closes includes this change's edits to `plugins/dev-workflow/commands/workflow-init.md` and
`codex-gate.sh`, **which ship inside the plugin package**. Write findings to `.context/codex-reviews/gate-b-<spec|quality>-<nonce>-pass-<p>.md` — **draw a fresh nonce for this cycle**; it is a different cycle from `awsf1ec771`.

**Standing lens, every call:** "which existing statements does this diff falsify?" and **name what this diff changes the size, value or position of** — a list, a count, a version, an identifier, a cited line — then grep for where each is described elsewhere.

- [ ] **Step 7: Loop until a pass is closure-eligible — clean at or above the derived floor, or zero-finding**

Floor derives from the story profile: risk `high` → 2, security `none` → 0, max 2 ≠ 0 → **floor 3**. Re-derive it at each pass from the header.

**Two routes reach the closing act, and this loop must admit both**: a **clean pass at or above the
floor**, or a **zero-finding logical pass** at any pass number — the early exit below the floor.
Both are subject to every other closure condition. **An earlier draft named only the first**, so a
first or second Gate-B pass whose two branch files both read `NO FINDINGS` would have been routed
into further passes — overriding §5's own early exit (§5 at `$BASE`: *"The only early exit below
the floor is a pass with **zero** findings"*), which Task 13's table also checks by name in the
installed text. A zero-finding pass is `NO FINDINGS` in **every** required
branch file; one branch clean and the other not is not it.

**Each pass is issued, validated and read as §5 at `$BASE` says** — *Accept a pass only when*,
*Recovery: one attempt per pass*, *Severity*, re-review after every fix, and the evidence entry
revalidated before every re-review and before the closing commit. **Nothing here restates those.**
What this plan adds is where its records go and how a pass is routed.

**Findings files are not committed during the loop (Close, *D1*).** They stay in
`.context/codex-reviews/` under this cycle's nonce and are committed once, all passes together, by
step 8. **No commit lands between a review and the reading of its result**, so the reviewed head
stays `HEAD` until a repair is committed.

**After every valid pass, route it by §5 at `$BASE` — the rules this cycle started under**
(`CLAUDE.md` "When these rules bind"; Daniel's decision of 2026-09-25, option 1). **The ordering this
change installs does not steer this cycle.** It is the product under review, and Task 13 and design
§7 test it; applying it here as well would give this cycle two rule sets that disagree (pass 54,
finding 1). The routes, each with its §5 source:

- **A new structural or contract question, or a correction outside the assigned fix set** → stop and
  surface to Daniel (§5, *What a loop absorbs, and what stops it*). Nothing is repaired and no call is
  issued until he answers; the loop resumes on the revised artifact.
- **From pass 4 on, two or more of the five tells** → stop and surface (§5: *"Any two present makes
  stop-and-surface mandatory"*). **This holds for an otherwise closure-eligible pass too.** The
  installed text's rule that tells never block a closing pass does not govern this cycle.
- **Clearly stuck**, all three of §5's conjuncts → stop and surface.
- **Blocker or Major findings inside the assigned fix set** → repair them (§5, *Severity*): the
  candidate sequence below, repair branch.
- **Clean at or above the floor, or zero findings, no stop owed, but a re-review is owed** — the
  evidence entry changed when 7b revalidated it (§5 at `$BASE`: the entry is revalidated before
  every re-review and before the closing commit, and a changed entry is not covered by the pass that
  judged the old one), or Failure's resume rule says a condition the failed attempt moved costs a
  pass → **the candidate sequence below**, making only the change that rule requires: a changed
  entry or refreshed records need no product change and take the no-repair branch; a moved closure
  input takes the repair its own rule names. Then battery, 4c, evidence, call — a new review. This
  pass does **not** close (pass 55, finding 2).
- **Clean at or above the floor, or zero findings, no stop owed and no re-review owed** → Close:
  step 7b, then step 8 (§5: the final pass must be clean; the zero-finding early exit).
- **Free of Blocker and Major but below the floor** → collect the Minors and Nits and continue
  without a product repair (§5: *"Minor · Nit → collect, never iterate"*, *"Below the floor nothing
  closes"*): the candidate sequence below, no-repair branch.
- **Daniel's answer to a stop** decides what follows. Where he stops the cycle it waits, open and
  spending no passes, until he says to continue; nothing closes it (§5: *"Surfacing does not close
  the cycle"*).

**What option 1 removed from this cycle's routing, accounted:**

| Rule the plan applied to this cycle from the installed ordering | Now |
|---|---|
| Source-block route (release rule, re-read) | **deliberately removed for this cycle**: §5 at `$BASE` has no source-block concept. It stays product text, tested by Task 13 |
| Collect every suspension answer and compose them | **replaced by §5's form**: each stop is surfaced and answered |
| No repair to a finding whose membership is unanswered | **kept by §5**: an out-of-set or new-question finding stops before any repair |
| Stop answer → park, restarted only by an explicit continue | **kept in substance by §5**: surfacing does not close the cycle; it waits for Daniel |
| Clean completion takes precedence over tells | **deliberately removed for this cycle**: §5 at `$BASE` stops on two tells. It stays product text, tested by Task 13 |
| Continue → next pass | **kept**: the candidate sequence below |

**Repair or continue → the candidate sequence.** It is the first pass's sequence — 4b's commit block, step 4,
step 4c, step 5, step 6 — with one branch, and the branch is on the **route's obligation**, never on
what the tree looks like:

1. **A repair is owed on the route** → apply it, re-run every record-producing check it invalidated
   (below), and commit the repair with the refreshed records **through the step-4b commit block**,
   message `WIP: fix <finding>`. That block resolves the new commit once and writes it to
   `.context/loop-rule-reviewed-head`. **No repair is owed** → no product file changes, but **the complete set
   still runs before the call** (below). Where its records come out **identical** to the committed
   ones — `git diff --quiet HEAD -- docs/superpowers/plans/2026-09-14-loop-rule-consolidation.md`
   succeeds — **commit nothing**; there is no empty commit. `HEAD` must then still equal
   `.context/loop-rule-reviewed-head`; if it does not, something reached the repository between the
   call and now — stop and report the concrete state, and never record over it (pass 53, finding 2).
   Where the refreshed records **differ**, commit this plan alone through the step-4b commit block,
   message `WIP: refreshed records` — a records-only candidate, and the only change this branch may
   commit. **Anything else dirty is not an authorized record change**: stop and report it
   (pass 54, finding 2). **"Else" is exact, not "everything but this plan"**: under D1 this cycle's
   findings files are uncommitted throughout the loop, and its working record must survive for
   recovery, so both are expected here and neither is committed (pass 55, finding 1). The check,
   run before the records decision:

   ```bash
   # NONCE and LASTP: this cycle's nonce and the pass just routed. Only this plan, this
   # cycle's findings slots, its per-slot dispositions notes (§5's `<slot>-dispositions.md`)
   # and its working record may be dirty. Exact paths, never a glob.
   NONCE=<this cycle's nonce>; LASTP=<the pass just routed>
   PLAN=docs/superpowers/plans/2026-09-14-loop-rule-consolidation.md
   set -- ":(exclude)$PLAN" ":(exclude).context/codex-reviews/gate-b-$NONCE-resume.md"
   p=1
   while [ "$p" -le "$LASTP" ]; do
     for b in spec quality; do
       set -- "$@" ":(exclude).context/codex-reviews/gate-b-$b-$NONCE-pass-$p.md" \
                   ":(exclude).context/codex-reviews/gate-b-$b-$NONCE-pass-$p-dispositions.md"
     done
     p=$((p + 1))
   done
   # Two steps: a FAILED status prints nothing and would read as clean.
   OUT=$(git status --porcelain -z --untracked-files=all -- . "$@") \
     || { echo "reading the dirty set FAILED — no call may be issued"; exit 1; }
   test -z "$OUT" \
     || { echo "a path outside this plan and this cycle's own records is dirty — stop and report"; git status --porcelain --untracked-files=all; exit 1; }
   ```

   **Dispositions notes are allowed here and not at the close**: they are advisory, may sit beside
   the findings during the loop, and step 8 asks for them to be removed first.
2. **Final verification on the candidate**: step 4's fetch and battery, then step 4c. Both read the
   candidate from `.context/loop-rule-reviewed-head`. A non-zero or unresolved result stops here.
3. **Revalidate and write the evidence entry** (step 5).
4. **Issue the call** (step 6).

**No commit is made between 1 and 4**, which keeps the verified object and the reviewed object the
same one. **If a repair was already applied before its route authorized it, stop and report the
concrete state** — this plan restores nothing, and §5 prescribes no rollback.

**A fix that changes specified behaviour updates the spec in the same commit.**

**The battery and the reader checks are not done when step 4 passed once.** A Gate-B fix can touch
the hook, its test, either prompt copy or the target text, and step 4's run and step 4b's
twelve-item review both describe the tree as it was *before* that fix.

- **After each fix, re-run every check whose subject it changed — mechanical and reader alike.**
  The hook or its test means the suite under both shells; a shell file means `shellcheck`; either
  prompt copy means `check-invariants.sh` **and** every observation over the text the fix touched —
  its pair, presence, absence and preservation counts — **and** the reader checks whose subject
  moved: Task 12's equivalence where `b11` or `b13` changed, Task 12b's sweep where the ordering or
  a hook message changed, Task 13's transitions and closure checks where §A changed, Task 14's
  parity and untouched checks wherever text moved at all. **Naming only the mechanical ones let a
  fix invalidate a reader record that then reached the closing commit unchanged.**
- **Persist every re-run record and commit it before the re-review**, through the step-4b block, so
  the reviewed range holds it.
- **Before every call, re-run the complete set, and "complete" means mechanical as well as
  reader.** Every call can be the final one, because a zero-finding pass closes at any pass number;
  on the first call Tasks 0–15 have just produced the set. The whole step-4 battery; step 4b's twelve items; every reader check above;
  **and every mechanical observation this plan built** — each discriminating pair, each add-only
  presence check, each moved and dropped absence, each carried and kept preservation count — re-run
  and re-recorded in `## Fragment evidence (per-task output)`. **An earlier draft named only the
  battery and the reader checks**, so the clean pass could close on a `HEAD` whose fragment evidence
  had never been re-established as a set, and the plan's design §7 claim would rest on counts taken
  from an older tree.

  **That set splits in two, and the split is what orders the candidate sequence above.** **Record-producing work**
  writes into this plan and therefore **must be committed**: the repair itself, step 4b's twelve-item
  result, every mechanical observation, and any other record a task owes. **Final verification**
  writes **no** committed record: step 4's battery, whose outcome is named in the evidence entry
  rather than in a plan section, and step 4c, whose result goes to `.context/loop-rule-closing-msg`.
  **All record-producing work is finished and committed first, through the step-4b block, which
  captures the candidate; only then does final verification run.** Reading it the other way is what left a rerun
  requiring a commit after the candidate had already been fixed.

  **"The whole step-4 battery" includes step 4's guarded `git fetch` and its recording of the base
  ref object id** — the battery is re-run end to end, not from the object id the first run happened
  to persist.

  **A stale base really can turn a rejection into a pass, and it was demonstrated with the real
  checker.** Topology, with the ids from the run: common ancestor `47c6193` carrying version
  `0.11.0`; `main` advancing on its own to `c0df286` at `0.12.0`; a branch that also reaches `0.12.0`
  **and carries further plugin changes**; and `R` = `44a2698`, the **merge commit**, which is what CI
  checks out — `.github/workflows/ci.yml` passes no `ref:` to `actions/checkout`, so a
  `pull_request` job checks the merge commit rather than the branch head. The plugin diff between
  `main` and `R` is `plugins/dev-workflow/extra.md` and `plugins/dev-workflow/file.md`. Results:

  - `check-version-bump.sh old-A` → merge-base `47c6193`, base version `0.11.0` ≠ `0.12.0` →
    **`ok`, exit 0**;
  - `check-version-bump.sh main` → merge-base `c0df286`, base version `0.12.0` = `0.12.0` with the
    plugin changed → **rejected, exit 1**.

  **An earlier attempt at this test concluded the opposite and was wrong.** The checker's line 58 is
  `cd "$(dirname "$0")/.."`, so invoking it by absolute path from a disposable repository silently
  ran it **against its own repository instead** — the checker under test never saw the fixture. That
  is the "wired so it could not fail" defect this plan warns about, and it produced a confident
  `could not be reproduced` that was an artefact of the harness. The run above copies the checker
  **into** the fixture repository.

  **Re-fetching does not by itself close this**, and naming the fetch here is precision rather than
  the repair: the battery runs against the **local branch head**, while CI evaluates the **merge
  commit**, and no amount of refreshing the base ref makes those the same object. **The repair is
  step 4c**, which checks the merge result of the pinned candidate head and the recorded base with
  the unchanged checker. An earlier draft of this paragraph said checking the merge result was "a
  scope question and not a change this plan makes" — **that is no longer true and was never a
  conclusion the evidence supported**: a different checking mechanism is not by itself a new
  requirement.

- **What "the battery is bound to the candidate" does and does not mean.** The battery block reads
  `.context/loop-rule-reviewed-head` and `.context/loop-rule-baseref`, and runs **shellcheck, the
  hook suites, the invariant checkers and `claude plugin validate` in a disposable clone checked out
  at that candidate id** (step 4). Its subject is the **committed candidate**, so a dirty work
  repository cannot supply its inputs. It does **not** make the clone immutable while tests run, and
  it does **not** check the merge result — step 4c does that, naming its own revision. Step 6 still
  asserts that `HEAD` has not moved, which is what keeps the reviewed object the captured one.
- **Only a clean response issued against the recorded head closes the cycle** (Close condition 1).
  This cycle's findings files are the sole permitted addition at the close (Close condition 2).

- [ ] **Step 7b: After the clean pass, complete `.context/loop-rule-closing-msg` — this is the
  action step 5 defers to, and step 8 has no other source for these records**

**Rebuild the file whole, do not append to it.** Step 5 opened it with a draft entry. **Appending on
re-entry writes a second provenance line and a second curve**, which breaks the one-of-each grammar
Mechanics pins, or leaves a stale curve standing beside the current one.

**After a failed closing act, inspect this file before trusting it, and rebuild it from the current
records.** The handoff changes nothing, but it **does not claim the failed operation left the file
as it was** — a hook can rewrite anything before failing — so "the failure preserves it" is not a
statement this plan can make.

**And a failed act does not by itself owe a further pass.** Failure's resume rule retries the act where every closure
condition still holds; a pass is owed only where the attempt or its repair moved something a
condition is read from, **and that condition's own rule is what decides.** An earlier draft required
a fresh final pass unconditionally here, which forces a review neither §5 nor Failure asks for. Write the complete message from the current records at every candidate close, then
assert **exactly one** provenance line and **exactly one** curve for this cycle before step 8.

The message carries, in this order:

1. the **provenance line**, in the form Mechanics pins — the Gate-B cycle's nonce, the derived
   floor, the cited set with each member's level, and the workspace knob;
2. the **per-pass curve** for this Gate-B cycle, `<CYCLE-FIELD>; Gate B (passes …): Findings …
   Blockers … Majors …`, which is why this cannot be written at step 5: the counts do not exist
   until the loop ends;
3. any **human-exception record**, and beside it the skip reason if a cycle was skipped;
4. the **revalidated evidence entry**, replacing step 5's draft if revalidation changed it — and
   **if it changed, this candidate is over.**

   **"Rebuild from the current records" does not say how this item survives a rebuild, and that
   gap is closed here.** Before writing anything, **read the existing entry out of
   `.context/loop-rule-closing-msg` and keep that text**; it is the entry the final reviewer was
   handed verbatim, and it carries the step-4c result, which is read from a run rather than from a
   section and so cannot be regenerated by re-reading the record sections. Items 1, 2 and 3 are
   rebuilt; **item 4 is carried across unless revalidation changes it.** Where the file is missing
   or holds no entry, that is **not** a rebuild case: the candidate cannot be closed on an entry
   nobody can produce — **stop and report**. Revalidation compares the carried text against the
   current records; **equal means carry it, different means the candidate is over** and the existing
   re-review rule below applies unchanged. The final reviewer judged the entry it was handed
   verbatim; a different entry in the closing commit is evidence no pass covered. **Take this pass
   through step 7 like any other non-closing pass** — route it, and repair only on a route that
   authorizes one; a stop binds here exactly as it does there, and **only a repair, continue or
   re-review route runs the candidate sequence and issues another call** — a changed entry takes the
   re-review route. An earlier draft sent this branch straight
   to a new call, which stepped over step 7's routing. **Revalidate before recording the candidate head and
   issuing the pass**, so that in the ordinary case this branch is never reached.

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

- [ ] **Step 8: Close the cycle — one closing block, then the postcondition block**

**`## The four procedures` · Close states the four conditions, what success looks like, and why one
closing command is enough.** Nothing here restates them. What follows is the shell that discharges
them, each part naming its condition; **the conditions are the obligation and this shell is one way
to run them** — where the observed state is not one it expects, read the state and pick the
operation, rather than extending the block.

**Before it runs:** remove this cycle's dispositions notes from `.context/codex-reviews/` — §5 lets
them be deleted — or condition 2 stops the close on them. **Keep the working record**: the close
retires it last, after condition 4 has passed.

**The closing block — conditions 1, 2 and 3, then the act.**

```bash
BASE=$(cat .context/loop-rule-base) \
  || { echo "cannot read the base — NOT closing"; exit 1; }
HEADREV=$(cat .context/loop-rule-reviewed-head) \
  || { echo "cannot read the reviewed head — NOT closing"; exit 1; }
test -n "$BASE" && test -n "$HEADREV" || { echo "base or reviewed head empty — NOT closing"; exit 1; }
# NONCE and LASTP are this cycle's nonce and the candidate pass number — the values the
# calls' slot paths were built from. INCOMPLETE lists the pass numbers recorded as
# INCOMPLETE (space-separated, or empty); only their slots may be missing.
NONCE=<this cycle's nonce>; LASTP=<the candidate pass number>
INCOMPLETE="<incomplete pass numbers, or empty>"
# The working record: the one exact path left out of condition 2, never staged.
WR=".context/codex-reviews/gate-b-$NONCE-resume.md"

# Condition 1.
test "$(git rev-parse HEAD)" = "$HEADREV" \
  || { echo "HEAD is not the head the candidate pass was issued against — NOT closing"; exit 1; }

# Condition 2, the set: the EXACT findings slots of passes 1..LASTP, never a glob, so a
# dispositions note or the working record is never taken for a findings file.
: > .context/loop-rule-final-paths || { echo "cannot write the findings list — NOT closing"; exit 1; }
p=1
while [ "$p" -le "$LASTP" ]; do
  for b in spec quality; do
    f=".context/codex-reviews/gate-b-$b-$NONCE-pass-$p.md"
    if [ -f "$f" ]; then
      printf '%s\n' "$f" >> .context/loop-rule-final-paths \
        || { echo "cannot write the findings list — NOT closing"; exit 1; }
    else
      case " $INCOMPLETE " in
        *" $p "*) test "$p" -ne "$LASTP" \
                     || { echo "the candidate pass cannot be INCOMPLETE — NOT closing"; exit 1; } ;;
        *) echo "missing findings file for a pass not recorded as INCOMPLETE: $f — NOT closing"; exit 1 ;;
      esac
    fi
  done
  p=$((p + 1))
done

# Condition 2, the check: anything dirty OUTSIDE that set stops the close — tracked,
# staged or untracked. Ignored scratch never appears in status, so nothing else is exempt.
# Two steps: a FAILED status prints nothing and would read as clean.
set --
while IFS= read -r f; do set -- "$@" ":(exclude)$f"; done < .context/loop-rule-final-paths
OUT=$(git status --porcelain -z --untracked-files=all -- . "$@" ":(exclude)$WR") \
  || { echo "reading the dirty set FAILED — NOT closing"; exit 1; }
test -z "$OUT" \
  || { echo "something outside this cycle's findings files is dirty — NOT closing"; git status --porcelain --untracked-files=all; exit 1; }

# Condition 3, immediately before the commit consumes it. Reader check on its records;
# the expected result is condition 3's. Then pin the validated bytes as condition 4's oracle.
test -s .context/loop-rule-closing-msg || { echo "closing message missing or empty — NOT closing"; exit 1; }
rm -f .context/loop-rule-validated-msg \
  || { echo "removing the previous message pin FAILED — NOT closing"; exit 1; }
cp .context/loop-rule-closing-msg .context/loop-rule-validated-msg \
  || { echo "pinning the validated closing message FAILED — NOT closing"; exit 1; }
test -f .context/loop-rule-validated-msg \
  || { echo "the message pin path is not a regular file — NOT closing"; exit 1; }

# Pin every selected findings file's bytes, staged or not: `git add` below stages exactly
# these worktree bytes, and condition 4 compares the commit with this pin.
while IFS= read -r f; do
  b=$(git hash-object -- "$f") || { echo "pinning $f FAILED — NOT closing" >&2; exit 1; }
  printf '%s\t%s\n' "$f" "$b"
done < .context/loop-rule-final-paths > .context/loop-rule-final-blobs \
  || { echo "writing the findings-blob pin FAILED — NOT closing"; exit 1; }

# The act. A failed add has not moved HEAD, but the index may hold part of the set.
while IFS= read -r f; do
  git add -- "$f" || { echo "staging $f FAILED — the index may hold part of the set; stop, do NOT reset" >&2; exit 1; }
done < .context/loop-rule-final-paths || exit 1
git reset --soft "$BASE" || { echo "reset --soft FAILED — run Failure; do NOT commit"; exit 1; }
# `--cleanup=verbatim` so the stored body is the validated bytes; `-F`, never `-m`, so
# `is_wip_commit` cannot read the close as cycle-internal.
git commit --cleanup=verbatim -F .context/loop-rule-closing-msg \
  || { echo "closing commit FAILED — run Failure"; exit 1; }
```

**The postcondition block — condition 4, in its own invocation, which is why it re-reads `$BASE`.**
Every fenced block here is a separate shell, so a variable assigned in the closing block is empty in
this one:

```bash
BASE=$(cat .context/loop-rule-base)
test -n "$BASE" || { echo "BASE empty or unreadable — cannot verify the close"; exit 1; }
NONCE=<this cycle's nonce>
WR=".context/codex-reviews/gate-b-$NONCE-resume.md"   # retired last, below
# Resolve the closing commit ONCE and make it the subject of every predicate below.
# Condition 4 is not one test but five — subject, parent, tree, body, findings blobs — and reading
# `HEAD` separately for each lets a move or an amend in between hand them DIFFERENT
# commits while all five still pass. Condition 1 may read `HEAD` live because it
# compares ONE read against ONE recorded baseline; condition 4 has no baseline
# and composes, which is why the same licence does not extend to it.
CLOSED=$(git rev-parse HEAD) \
  || { echo "cannot resolve the closing commit — run Failure"; exit 1; }
# Read under a guard: a failed `git log` yields an empty subject, which matches no
# pattern, so the WIP arm never fires and the check is satisfied by a command that
# failed. No `test -n` is added — a genuinely empty subject read successfully passes
# today, and requiring one would be a new condition rather than a repair to this one.
SUBJECT=$(git log -1 --pretty=%s "$CLOSED") \
  || { echo "reading the closing commit's subject FAILED — run Failure"; exit 1; }
case "$SUBJECT" in
  [Ww][Ii][Pp]:*) echo "closing commit still reads as a snapshot — run Failure"; exit 1 ;;
esac
test "$(git rev-parse "$CLOSED^")" = "$BASE" || { echo "closing commit's parent is not \$BASE — run Failure"; exit 1; }
TREESTATE=$(git status --porcelain -- . ":(exclude)$WR") \
  || { echo "reading the tree state after the close FAILED — run Failure"; exit 1; }
test -z "$TREESTATE" || { echo "tree dirty after the close — run Failure"; exit 1; }
# `--pretty=format:%B` emits the stored message alone; the `%B` spelling appends a
# trailing newline the source file has none of, which rejected a CORRECT close.
# The closing block's `--cleanup=verbatim` is the other half — without it git stores its own
# tidied copy. Both observed in a disposable repository, so this diff is the
# byte equality condition 4 states, not a normalized stand-in for it.
test -s .context/loop-rule-validated-msg || { echo "no pinned message — the closing block did not complete; run Failure"; exit 1; }
# Same shape as the closing block's pin: remove the previous extraction first, then guard this one.
# A failed redirect otherwise leaves an earlier body at the path and the `diff` below
# masks the failure — it can even pass, when the earlier body was the same validated
# message, so the close is accepted on bytes nobody read out of THIS commit.
rm -f .context/loop-rule-landed-msg
git log -1 --pretty=format:%B "$CLOSED" > .context/loop-rule-landed-msg \
  || { echo "extracting the committed body FAILED — run Failure; the comparison has no input"; exit 1; }
diff .context/loop-rule-validated-msg .context/loop-rule-landed-msg \
  || { echo "the committed body differs from the validated message — run Failure"; exit 1; }

# Condition 4, the findings blobs: every selected file, committed exactly as pinned just
# before staging. This compares pin-time bytes with committed bytes and nothing earlier.
while IFS="$(printf '\t')" read -r f b; do
  test "$(git rev-parse "$CLOSED:$f" 2>/dev/null)" = "$b" \
    || { echo "committed findings file differs from its pin, or is missing: $f — run Failure"; exit 1; }
done < .context/loop-rule-final-blobs \
  || { echo "reading the findings-blob pin FAILED — run Failure"; exit 1; }
# The final pass's pair, re-read from $CLOSED against §5's "Accept a pass only when" and
# the clean-or-zero-finding reading it was judged on: reader check, expected result
# condition 4's.

# The cleanup gate, as a COMMAND rather than a sentence. Everything above describes
# $CLOSED; the cleanup is about the repository as it stands now, so this is where the
# capture is re-asserted. A move between the close and this point must not be followed
# by deleting the recovery state, which is the only evidence of what was closed.
test "$(git rev-parse HEAD)" = "$CLOSED" \
  || { echo "HEAD moved during the close verification — run Failure; do NOT clean up"; exit 1; }

rm -f .context/loop-rule-base .context/loop-rule-reviewed-head \
      .context/loop-rule-baseref .context/loop-rule-closing-msg \
      .context/loop-rule-untouched .context/loop-rule-baseline-diff.txt \
      .context/loop-rule-sites .context/loop-rule-changed-sites \
      .context/loop-rule-c.src .context/loop-rule-w.src \
      .context/loop-rule-a.txt .context/loop-rule-b.txt .context/loop-rule-landed-msg \
      .context/loop-rule-validated-msg \
      .context/loop-rule-final-blobs .context/loop-rule-final-paths \
      .context/loop-rule-start
if ls .context/loop-rule-* >/dev/null 2>&1; then
  echo "cycle scratch survives the close:"; ls .context/loop-rule-*; exit 1
fi
# Retire the working record LAST — only now is the cycle's own commit its recovery source
# (§5) — and then require a clean tree with no exception.
rm -f "$WR" || { echo "retiring the working record FAILED — it survives; report it"; exit 1; }
TREESTATE=$(git status --porcelain) \
  || { echo "reading the tree state after retiring the working record FAILED"; exit 1; }
test -z "$TREESTATE" || { echo "tree not clean after the close's cleanup:"; git status --porcelain; exit 1; }
```

**What the capture buys, and what it does not.** All four predicates now describe **one object**,
which is the defect it repairs. It does **not** establish that the object is the commit the closing block created:
a substituted commit would still have to be parented at `$BASE` and carry the validated body
byte-for-byte, which is much narrower but is not nothing. The re-assert before the cleanup closes the
window inside this block; it says nothing about the window between the closing commit and this block's first
line.

**Run step 8's blocks under `sh`, `dash` or `bash`, not `zsh`.** The closing block builds its
exclusion list with `set --` inside a redirected `while` loop, which relies on POSIX shell
behaviour. **Nothing in step 8 needs `bash` specifically.**

**The cleanup Close's success recognition names is the tail of the condition-6 block above**, not a
block of its own. It used to be separate, gated only by the sentence *"all four pass, and only
then"* — a prose gate in a different shell, which asserts an ordering rather than checking one. It
now runs after the `HEAD = $CLOSED` re-assert, so the gate is a command.

**The `ls` is what makes the removal checked rather than asserted**, and the list is every
`loop-rule-*` name this plan writes. **The plan's own records are not among them** — they live in
this plan and in `.context/codex-reviews/`, both tracked, both already inside the closing commit.

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

**Subject.** The installed §A (`**How a cycle ends`) and the installed passage (b)
(`**What a loop absorbs`), read in C; W carries the same bytes over both (Task 1 and Task 3 parity:
§A no difference, §B's common span no difference), so the result is the same per copy.

**What the ordering attributes to the absorb paragraph (step 1), in full:**
1. Clean predicate: a clean pass carries **no scope-stop trigger** — "the two the absorb paragraph
   defines, read there and not redefined here, each already carrying the qualification **an answer
   given before that pass ran** puts on it."
2. Suspension branch: the scope stop is "raised by either trigger above — a **membership stop** by
   the first, a **question stop** by the second."
3. Continue branch: "which findings raise one is that passage's entire, **an already-declined finding
   raising no membership trigger and an already-answered question no question trigger**." (Repaired
   at Gate-B pass 1, cycle `t57gp3hwu1`, in both copies and in the target text: the earlier wording,
   "an already-declined finding and an already-answered question raising none", also read as "a
   declined finding raises no trigger at all", which `b11` rejects.)
4. Answers: "an out-of-set finding that opened one is a membership stop as well"; "**Decline is
   available only at a membership stop**".

**What the absorb paragraph states (step 2), in full:**
- `b11`: "A correction that leaves that set stops the loop like any other out-of-scope finding —
  except one this cycle has already declined, which is outside the set by that decision and
  **raises no membership trigger on that account**, its membership being the one question already
  answered — even when it opens no new question at all, and the membership answer ends that
  finding's membership hold; what the pass does next is the closure ordering's …"
- `b13`: "A finding that opens a **new structural or contract question** — new meaning not already
  answered in this cycle, so an answered question raised again stops nothing — stops the loop and
  goes to the user …", with "Novelty overrides ancestry and nothing else: where the finding is also
  out of set, both triggers hold and both answers are owed."

**Comparison (step 3).**
- **Block → source** (a condition the ordering attributes that the paragraph lacks): none. Items 1,
  2 and 4 match `b11`/`b13` term for term, and item 3 now scopes each exemption to its own trigger —
  exactly `b11`'s "raises no membership trigger on that account" and `b13`'s already-answered
  qualification. Before the repair, item 3 admitted the wider reading Gate-B pass 1 raised.
- **Source → block** (a condition the paragraph states that the ordering does not read): none.
  `b11`'s "even when it opens no new question at all" and `b13`'s "size is not the test" are
  trigger-internal and the ordering reads the triggers "there"; the both-triggers rule is item 4.

**Result: equivalent in both directions, per copy (C and W).** The copies were not changed.

---

## Next-state table (Task 13 output)

**Read against the installed §A in `CLAUDE.md`** (W is byte-identical over §A). Predicates per row:
**SB** a source block stands · **CL** the pass is clean (no in-set Blocker/Major at effective
severity, no scope-stop trigger) · **EL** eligible (clean at or above the floor, or zero findings) ·
**K** every closure condition of the cycle other than eligibility and the source block holds (the floor is read in EL, the source block in SB; a reread row gives K as it stands after the repair) · **SUS** which suspensions apply (M membership, Q
question, S clearly-stuck, T two-tell, — none). Next states: **CLOSED** (closing act performed and
completed) · **CONT** (continue branch: next pass on the current artifact, repaired only where a
repair is owed) · **SUSP** (suspended awaiting answers) · **PARKED** (open, not running, no passes,
restarted only by an explicit continue) · **BLOCKED** (source rule's stop; no pass runs). **Oracle:**
a row fails if its answer does not produce a distinct resumable or closed state — the same stop
returning with its reading unconsumed — or if it closes on anything but the stated route.

| # | Starting state (SB · CL · EL · K · SUS) | Answer / event | Next state (route in §A) | Oracle |
|---|---|---|---|---|
| 1 | no · yes · yes · yes · — | — | CLOSED — clean-completion branch; conditions established first, then the act | pass |
| 2 | no · yes · yes · **no** (a repair owed from an earlier pass) · — | — | CONT, repair first — "an eligible pass with an unmet closure condition lands here" | pass |
| 3 | no · yes · yes · no (repair owed) · T | continue | CONT, repair first — the reading is consumed; a new one needs a post-answer pass | pass |
| 4 | no · yes · yes · no (repair owed) · T | stop | PARKED — "stop parks the cycle" | pass |
| 5 | **yes**, on this read pass (unresolvable profile) · yes · yes · yes once repaired · — | source repaired | the pass is read again → CLOSED (clean, eligible, every condition holds) | pass |
| 6 | **yes**, on this read pass · yes · yes · no (a non-source repair also owed) · — | source repaired | the pass is read again → CONT, repair first | pass |
| 7 | no · yes · **no** (below floor, only a Minor, no trigger) · yes · — | — | CONT, unrevised allowed — "a below-floor clean pass lands here" | pass |
| 8 | no · yes · no (below floor) · yes · T | continue | CONT — the suspension branch takes a below-floor clean pass; its answer continues | pass |
| 9 | no · yes · no (below floor) · yes · T | stop | PARKED | pass |
| 10 | no · yes · yes (**zero findings**, below floor) · yes · — | — | CLOSED — zero-finding eligibility; no suspension can co-occur | pass |
| 11 | no · yes · yes (zero findings) · **no** (an earlier in-set Major undischarged) · — | — | CONT, repair first — the pass-2-clean/Major-open case §A states | pass |
| 12 | no · **no** (an out-of-set finding) · no · — · M | accept | CONT — the finding enters the set; the set change costs a further pass; repair owed only if it is a Blocker/Major | pass |
| 13 | no · no (out-of-set) · no · — · M | decline | CONT — hold discharged; the finding stays outside for the cycle; this pass stays unclean | pass |
| 14 | no · no (a new-question finding) · no · — · Q | the user's decision | CONT on the artifact revised per the decision; membership unchanged | pass |
| 15 | no · no (out-of-set and new question) · no · — · M+Q | only one of the two answers given | SUSP — "resumes only when every answer resumes it" | pass |
| 16 | no · no (out-of-set and new question) · no · — · M+Q | both answers given | CONT | pass |
| 17 | no · no (an in-set Major, repair owed) · no · — · T | continue | CONT, repair first | pass |
| 18 | no · no (in-set Major) · no · — · T | stop | PARKED | pass |
| 19 | no · no (regenerating in-set Majors) · no · — · S | continue | CONT — the surfaced findings' clearly-stuck holds are discharged by the answer; repair first | pass |
| 20 | no · no (regenerating in-set Majors) · no · — · S | stop | PARKED | pass |
| 21 | no · no · no · — · S+T | one answer, continue, carrying every reason | CONT, repair first — one question between the two health readings | pass |
| 22 | no · no · no · — · S+T | one answer, stop | PARKED | pass |
| 23 | PARKED, a membership answer outstanding | explicit continue | SUSP — "that continue … never skips an answer" | pass |
| 24 | PARKED, nothing outstanding | explicit continue | CONT | pass |
| 25 | **yes**, raised before any pass was read | source repaired | CONT — the next pass runs; there is no pass to read again | pass |
| 26 | **yes**, on a read pass · yes · yes · yes · — | source repaired | read again → CLOSED | pass |
| 27 | **yes**, on a read pass · yes · yes · no (repair owed) · — | source repaired | read again → CONT, repair first | pass |
| 28 | **yes**, on a read pass · yes · no (below floor) · yes · — | source repaired | read again → CONT | pass |
| 29 | **yes**, on a read pass · no (in-set Major) · no · — · — | source repaired | read again → CONT, repair first | pass |
| 30 | **yes**, on a read pass that also carried T · yes · yes · yes · T | T answered continue, then source repaired | CONT — the suspension's route runs first; its continue needs a post-answer pass, so the pass is not closed on | pass |
| 31 | **yes**, on a read pass that also carried T · yes · yes · yes · T | T answered stop | PARKED — no reread while the suspension's stop stands | pass |
| 32 | row 1, closing act fails, nothing a condition reads moved | repaired | the act is performed again → CLOSED | pass |
| 33 | row 1, closing act fails; the repair changed the assigned fix set | repaired | the set change costs a further pass (the absorb paragraph) → CONT | pass |
| 33b | row 1 (Gate A), closing act fails; the repair edited the artifact and restored it byte for byte, every condition holding again | repaired | Gate A's condition is current equality, so it holds; the act is performed again → CLOSED | pass |
| 34 | row 1, closing act fails and cannot be repaired | — | PARKED — "surface it and leave the cycle parked" | pass |
| 35 | no · yes · yes · yes · — — Gate-B `full`: spec branch `NO FINDINGS`, quality branch a Minor, no trigger | — | CLOSED — the logical pass is the concatenation, and it is clean | pass |
| 36 | no · no · no · — · — — Gate-B `full`: one branch `NO FINDINGS`, the other an in-set Major | — | CONT, repair first — one branch's clean file never makes a clean pass | pass |
| 37 | no · no · no · — · M — the same out-of-set complaint in both branch files | accept / accept | CONT — both lines in the set | pass |
| 38 | no · no · no · — · M — same | accept / decline | CONT — the accepted line in, the declined line out; the accepted repair obligation stands | pass |
| 39 | no · no · no · — · M — same | decline / accept | CONT — mirror of the row above | pass |
| 40 | no · no · no · — · M — same | decline / decline | CONT — both lines out for the cycle; the pass stays unclean | pass |
| 41 | no · no · no · — · M — same | one line answered, the other not | SUSP — each line owes its own explicit answer | pass |
| 42 | no · yes · yes · yes · — — a finding this cycle declined recurs, no new question, nothing else found | — | CLOSED — b11: it raises no membership trigger; it is outside the set, so not an in-set Blocker/Major | pass |
| 43 | no · no · no · — · Q — a finding this cycle declined recurs and opens a new question | the user's decision | CONT — b11's exception is the membership trigger only; the question trigger reaches it | pass |
| 44 | no · yes · yes · **no** (the assigned fix set changed after it was fixed for this pass and was changed back) · — | — | CONT — the change costs a further pass even though undone; equal endpoints do not discharge it | pass |

**45 rows, each with one next state; every row passes the oracle.** Revised at Gate-B pass 1 (cycle `t57gp3hwu1`): rows that combined alternative answers are split, the reread rows state every predicate, and three cases are added — a declined finding recurring without and with a new question, and a fix-set change undone before the act. Revised again at pass 2: K excludes eligibility (the floor is read in EL), and the failed-act row is split by which condition input the repair changed. Claim width, as the plan fixes it: the table covers
answer-state transitions **once the predicates producing them are established**; it does not show
how each predicate was derived, nor that these rows cover every reachable combination.

### Per-condition closure checks (step 4) — one per condition §A states for closure (13)

| Check | Condition, as §A states it | What is observed |
|---|---|---|
| `close-eligible` | the pass is eligible: clean at or above the derived floor, or zero findings | the pass's validated findings, its effective severities, the derived floor, the pass number |
| `close-floor` | the derived floor, a precondition, discharged by valid logical passes reaching it with the last clean, or by the zero-finding exit | count of valid logical passes; the last one's cleanliness |
| `close-resolve` | every in-set Blocker/Major discharged per finding (repair or validated dismissal), tracked across the cycle, never inferred from a later pass | the per-finding disposition record for every in-set Blocker/Major the cycle raised |
| `close-no-hold` | no hold standing — every surfaced finding's answers given | the answers recorded against every surfaced finding |
| `close-no-question` | every suspension question answered (composition), including a two-tell continue-or-stop | the suspension record of the cycle |
| `close-no-source-block` | no source block stands | each source rule's stop condition (profile resolvable, headers agree, `Story:` readable, counterfactual observable, …) |
| `close-header-during-pass` | a governing `**Story:**` header, or a cited story's profile header, changed **during** the final pass makes it not final — including a change restored before the pass ends | **Observation, not proof:** the named procedure `observe-header-changes` below, run over the pass's own interval — from building its review request to accepting its findings file(s), **not** to the act. It reports `change observed` (the pass is not final), `no change observed`, or `source unreadable` (treated like a change: not final). `no change observed` names what it read and what it cannot see: an edit made and undone without a commit, or by an actor outside the branch's ref moves, leaves no trace. |
| `close-cited-set-at-act` | the final clean pass runs against the **current** cited set | the set named by the governing `**Story:**` headers read at the act, against the set recorded in the final pass's request; unequal → not final. A header changed and restored **after** acceptance does not fail this row or the one above; a profile or fix-set change in that time is `close-profile-fixset`'s. |
| `close-profile-fixset` | a change to a cited story's profile or to the assigned fix set costs a further pass, in either direction and **even when undone**, from the moment the set is fixed for the final pass to the act | **Observation, not proof,** over that longer window, from every input the set definition reads: (a) profile headers — `observe-header-changes` on the cited stories; (b) the scope each governing story or plan assigns — every diff to those files in the window, read for a change to the scope they assign (other edits, such as appended verification records, are not scope changes); (c) membership answers — the cycle's recorded dispositions. Reports `change observed` (a further pass is owed), `no change observed`, or `source unreadable`. **Blind to** an approval given with no file change and no recorded answer, and to uncommitted edits. |
| `close-evidence-revalidated` | each owed evidence entry is revalidated before the commit the closing act produces; a changed entry owes a re-review on it, and the pass that follows closes only on the entry revalidated for it | the entry handed verbatim to the final pass against the entry revalidated at the act; equal, or else a further pass |
| `close-gate-content` | Gate A: the artifact equals the text in the final pass's review request; Gate B: no content condition | Gate A: byte comparison artifact ↔ request text; Gate B: none, stated |
| `close-order` | every condition established first, only then the act | the order of checks and act in the closing record |
| `close-act` | the gate's closing act performed and completed, carrying the records the cycle owes (provenance line, curve, human-exception records in the commit the act uses; Gate A: the reviewed text at the artifact path) | the closing commit and its body |


**What these checks are, stated once** (Daniel's decision, 2026-09-26): each row names **what is
observed and from which source**; where a row reports an observation it reports `change observed`,
`no change observed` or `source unreadable`, **never "held"** — silence in a source is not proof that
nothing changed. The checks are **defined and demonstrated in disposable repositories; none is
applied to a real closing act in this change**, because this change's own cycle closes under §5 as at
its base (option 1), not under the ordering it installs.

**`observe-header-changes`** — the named procedure the header rows use (POSIX `sh`; shellcheck clean):

```sh
# observe-header-changes <branch> <start-unix> <end-unix> <file>...
# Reports whether any governing header line changed on <branch> between two moments.
# Source 1: the branch's first-parent line between the heads it held at those moments,
#           merges read against their first parent.
# Source 2: every move of the branch ref in that window (its reflog), each old->new pair compared.
# Prints: "change observed (<source>)" or "no change observed" or "source unreadable".
obs() {
  br=$1; t0=$2; t1=$3; shift 3
  pat='^[-+]\*\*(Story|Risk|Security|Validation):\*\*'
  moves=$(git reflog show --date=unix --format='%H %gd' "$br" 2>/dev/null) || { echo "source unreadable (reflog)"; return; }
  # heads at t0 and t1: newest reflog entry at or before each moment
  h0=$(printf '%s\n' "$moves" | awk -v t="$t0" '{split($2,a,"[{}]"); if (a[2]<=t) {print $1; exit}}')
  h1=$(printf '%s\n' "$moves" | awk -v t="$t1" '{split($2,a,"[{}]"); if (a[2]<=t) {print $1; exit}}')
  [ -n "$h0" ] && [ -n "$h1" ] || { echo "source unreadable (no reflog entry for a moment)"; return; }
  if git log --first-parent --diff-merges=first-parent -p "$h0..$h1" -- "$@" | grep -Eq "$pat"; then
    echo "change observed (first-parent history)"; return; fi
  # every ref move inside (t0, t1], oldest first, as consecutive pairs
  prev=$h0
  for h in $(printf '%s\n' "$moves" | awk -v a="$t0" -v b="$t1" '{split($2,x,"[{}]"); if (x[2]>a && x[2]<=b) print NR, $1}' | sort -rn | cut -d' ' -f2); do
    if git diff "$prev" "$h" -- "$@" | grep -Eq "$pat"; then echo "change observed (reflog move)"; return; fi
    prev=$h
  done
  echo "no change observed"
}
```

**Demonstrated** (Gate-B pass-5 preparation; each case a fresh disposable repository, run under
`sh` and under `dash` with identical results):

```
a control, nothing changed                                  no change observed
b A->B->A in two commits                                    change observed (first-parent history)
c A->B->A carried only by merges into main                  change observed (first-parent history)
d side branch did A->B->A before; main's header never moved no change observed
e B committed, then amended away                            change observed (reflog move)
f main reset to an existing commit with B, then back        change observed (reflog move)
g A->B->A after the window ends (acceptance)                no change observed
h edited and restored, never committed                      no change observed   <- the stated blind spot
```

### Separate named checks (step 5)

| Check | What it establishes |
|---|---|
| `logical-pass-validated` | a logical pass was validated across **every** required branch file — both for a `full` Gate-B pass, each file separately against *Accept a pass only when* — before any finding-derived predicate read it |
| `conditions-held-at-act` | every closure condition above held at the moment the closing act was performed, re-established after any failed attempt against the repository as it then stood |

---

## Divergence list (Task 14 output)

**Sites compared, C against W** — one row per destination block, read off the target's markers
(§A three, §B one, §C one, §D two, §E two, §F sixteen prompt-copy items with 9a and 9 extracted as
one adjacent region, §G one, §H nine). Each region runs from the block's first installed line to its
last, both extracts non-empty, anchors unique in each copy.

| Site | Parity |
|---|---|
| §A1 | no difference |
| §A2 | no difference |
| §A3 | no difference |
| §B | differs — see below |
| §C | no difference |
| §D e7 | no difference |
| §D pointer | no difference |
| §E Severity | no difference |
| §E answer | no difference |
| §F 1 | no difference |
| §F 2 | no difference |
| §F 3 | no difference |
| §F 4 | no difference |
| §F 5 | no difference |
| §F 6 | no difference |
| §F 7 | no difference |
| §F 8 | no difference |
| §F 7a | no difference |
| §F 8a | no difference |
| §F 8b | differs — see below |
| §F 9a+9 | no difference |
| §F 9b | no difference |
| §F 14 | no difference |
| §F 18 | no difference |
| §G | no difference |
| §H c18 | no difference |
| §H a13 | no difference |
| §H a16 | no difference |
| §H a17–a22 | no difference |
| §H clean signal | no difference |
| §H template | no difference |
| §H cadence | differs — see below |
| §H lens | no difference |
| §H strict list | no difference |

**Every difference, classified (step 2):**

| Difference | Bucket | Reason |
|---|---|---|
| §B: C's field-mint parenthetical after the common span | deliberate, stays | inventory passage (b) difference 3; §B stops short of it by design |
| §F 8b: C's kept `` (`docs/prompt-standards.md`, "coverage first, filter later") `` after the block | deliberate, stays | pre-existing C-only citation of a repo-local doc the scaffolded template cannot assume; outside the block |
| §H cadence: the kept remainder of the block's last line wraps differently (`what` / `what the`) | inherited, stays | pre-existing wrap difference in untouched Gate-A text; same words |
| passage (e): C's `e11` rationale paragraph | deliberate, stays | inventory passage (e) difference 2 |
| passage (f): `f5`–`f7` evidence framing | deliberate, stays | inventory passage (f) |
| passage (d): the three-lines sentence wraps differently | inherited, stays | same words; passage (d) is untouched by design, and a diff touching it is a defect |
| `**Findings go to a FILE` opening (`In the field, long finding` / `Long finding lists come back`) | inherited, stays | outside every inventoried and changed site |
| C had no blank line between the Surfacing paragraph and `**Every pass report states`; W had one | **not deliberate — aligned in this task** | C now carries the blank line; the region `**Recognizing "clearly stuck"` … `**Every pass report states` is byte-identical |

**Not in the deliberate bucket:** `e8` (Task 5 gave W the pronoun; the passage-(e) extract now differs
only by `e11`) and `b3` (step 3: W reads `severity exactly as Mechanics · Severity says`, count 1;
Task 3's pair recorded it). `g4` is gone from C (Task 6), so passage (g) is byte-identical.

**Step 4, re-run after the alignment:** the same three block-adjacent differences and nothing else.

---

## Completeness sweep (Task 12b output)

**What was looked for:** any live sentence outside §A that still answers a question the installed
ordering now decides — closure, eligibility, cleanliness, the hold and what discharges it,
composition, the two scope triggers, the suspensions and their answers, the two gates' closing
acts, the duty classification, the source-block branch and its reread routes, the
repeated-dismissal exclusion, and the parked state (the list read off the installed §A, which is
the complete statement). **How:** a grep for closure vocabulary (`final pass`, `clean pass`, `keep
going`, `never iterate`, `resumes`, `close it`, `closes the cycle`, `run more`, `exit the loop`,
`only early exit`, `until clean`, `make the real commit`) over both copies outside §A, then each hit
and its paragraph read; plus reading the sections below whole.

Sections read, per copy (C; W by the same grep and by parity with C):

```
sweep CLAUDE.md §4 work-loop line — closing acts named, §5 cited (item 18 installed) → nothing further
sweep CLAUDE.md §5 HARD FLOOR paragraph — floor arithmetic, set comparison before a clean pass is final → a condition §A cites, not a competing rule
sweep CLAUDE.md §5 derived-floor paragraph — a13/a16/a17 pointers installed → nothing further
sweep CLAUDE.md §5 Named residual, gate-off surface, When these rules bind, Downstream → nothing that answers closure
sweep CLAUDE.md §5 absorb paragraph, clearly-stuck, surfacing, pass-report duties, five tells, two-rules → installed text; resumption points at §A
sweep CLAUDE.md §5 findings-file protocol, Accept a pass only when, Reader, Recovery, What this does not do → validity and recovery rules; "Spent and still incomplete → STOP and surface" is a source-rule stop §A's source-block branch reads
sweep CLAUDE.md Gate A / Gate B sections — broad prompt, clean signal, cadence, coverage instruction installed; "Re-review after every fix" and "A fix that changes specified behaviour updates the spec" are duties, not closure permissions → nothing further
sweep CLAUDE.md Profiles — "That further pass must itself be clean and every other closure duty must be satisfied … not a licence to close on the next one" and "the final clean pass runs against the current set" → conditions §A cites; consistent
sweep CLAUDE.md Mechanics · Severity, baseSha / Finishing the cycle, provenance line, curve, human exception, Timeout → installed text or record rules; no closure permission left
sweep codex-gate.sh eight gate reminders, both channels — seven replaced by §F; the docs-only notice (line 918) says Gate B does not apply to a docs-only commit and points at Gate A → states no closure permission; exclusion confirmed
```

**Found: nothing.** No live sentence in `CLAUDE.md`, `plugins/dev-workflow/commands/workflow-init.md`
or `plugins/dev-workflow/hooks/codex-gate.sh` was found still answering a question the ordering
decides, beyond the sites §F replaces. The sweep is a reader's judgement and nothing checks its
coverage.

---

## Prompt-standards result (Task 15 step 4b output)

**Subject set, read once and referred to by every line below:** (1) the §A–§H blocks as installed in
`CLAUDE.md`; (2) the same blocks as installed in `plugins/dev-workflow/commands/workflow-init.md`
(byte-identical to (1) except the classified divergences in the Task 14 list); (3) ten hook prompt
bodies in `plugins/dev-workflow/hooks/codex-gate.sh` — the seven `additionalContext` bodies items
10–13 and 15–17 replace (lines 908, 933, 945, 947, 956, 967, 973) and the three `systemMessage`
bodies items 12, 15 and 16 replace (`✓ Codex Gate B hook checks passed (…)`, `⚠ Codex Gate B: no
recorded fingerprint`, `⚠ Codex Gate B: cannot confirm reviewed content`). Checked against
`docs/prompt-standards.md` as it stands at this commit; a reader check, as the plan says.

1. **Target model named — PASS.** (2) sits under W's `Target model: Claude via Claude Code` line;
   (3) sits under the hook's `# Target model:` comments (lines 348, 862); (1) is this repository's
   own `CLAUDE.md`, read by Claude via Claude Code, and adds no second, conflicting model claim.
2. **Success criteria explicit — PASS.** §A states closure as a checkable conjunction — eligibility
   (clean at or above the floor, or zero findings) plus every closure condition plus a completed
   closing act — and each hook body names the observed state (`hook checks passed`, `no fingerprint
   is recorded`, `cannot confirm`).
3. **Stop conditions defined — PASS.** §A's source-block branch, the three suspensions, the parked
   state and the unrepairable-act route; §B's two scope triggers; the hook bodies defer every next
   step to the policy's closure ordering rather than issuing one.
4. **Output format with an example — PASS.** The changed text adds no new output format; the
   findings-file format and its example block (`MAJOR | high | …`, `NO FINDINGS`) are unchanged
   and the template's clean sentence still names the exact body line and terminator.
5. **Structured sections — PASS.** §A is three bolded-lead paragraphs placed as a unit before the
   absorb paragraph; each §B–§H replacement stays inside the section and paragraph it replaced.
6. **Rules carry their why — PASS.** Each constraint in §A carries its reason clause (e.g. the
   read-once rule, "so a pass that reached the act has already been classified"; zero-finding
   eligibility, "because a floor buys further looks at an artifact that keeps yielding findings");
   §E states "Two reasons for the split"; each hook body states why it defers ("this reminder
   decides none of it", "which restores no passes").
7. **No contradictions with CLAUDE.md / AGENTS.md — PASS.** Superseded sentences are replaced in
   the same change (§F, 23 sites), and Task 12b's completeness sweep found no remaining sentence
   answering what the ordering decides.
8. **Token-lean — PASS, with the observation stated.** §A1 is long; it restates no rule owned
   elsewhere — the scope triggers, fix set, severity rules and closure preconditions are cited
   ("read there and not redefined here"), and every replaced entry point now points at the
   ordering instead of carrying a copy. The hook bodies replace enumerations with a pointer.
9. **Positive instructions — PASS.** Instructions are phrased as what to do (answer, repair,
   continue, park, perform the act); the prohibitions that remain ("no pass is credited…",
   "nothing here turns one answer into another") draw a boundary that a positive restatement would
   lose, the exception the item names.
10. **Diagnostic states name their causes — PASS.** The no-fingerprint body lists its three causes
    (no review ran, the fingerprint could not be written or read back, a non-`WIP` commit attempt
    cleared it) with the check and fix for the storage cause; the stale-fingerprint body lists
    worktree/index change, staging only, upgraded format and failed compute/store, each with its
    remedy and the machinery checks.
11. **Enforcement claims name their mechanism — PASS.** §G says it is "not a checker" and bounds
    what a reader can detect; §A3 states "no rule in this section reaches it" for content the
    final review request did not select; the Gate-B hook body says what the hook checked and no
    more (`hook checks passed`), and the terse channel dropped `satisfied`.
12. **Calibrated emphasis — PASS.** The changed text adds no new MUST/CRITICAL; the one `MUST`
    kept in the stale-fingerprint body ("MUST re-review after every fix") is the pre-existing §5
    gate language the item names as a deliberate exception.

**Result: all twelve pass. No repair was made.**

---

## Fragment sweep (Task 0 output)

**Ran at:** base `d26de4b40655a18c44c5cb3a3d8fd362943c8495` — both prompt copies equal to the base;
only this plan's table had gained rows P19–P22. **Mechanical checks:** the count in each copy the
row claims (a `grep -F` hit is one line, so a count of 1 is single-line and unique), and absence from
every fenced block of the target text with whitespace normalized. **Post-edit-region check** — an
OLD row must overlap wording its item removes; a kept row (P19–P22) must lie outside every
replacement: done by reading each row's live line against its item's block. Every OLD row runs into
wording its block changes; P19–P22 sit wholly in kept text beside a replacement.

- `P1 no fragment (P1 by design)  *(none — counterfactual ABSENT, presence only)*` — 
- `P2   C=1 W=1 claims=CW single-line+unique=ok in-replacement-block=no` — `scope the approved story or plan assigns to this cycle, plus repair ob…`
- `P3   C=1 W=1 claims=CW single-line+unique=ok in-replacement-block=no` — `the moment the user says whether the set now includes it…`
- `P4   C=1 W=1 claims=CW single-line+unique=ok in-replacement-block=no` — `a Blocker/Major-free pass below the floor…`
- `P5   C=1 W=0 claims=C single-line+unique=ok in-replacement-block=no` — `not discretionary** — you report…`
- `P5w  C=0 W=1 claims=W single-line+unique=ok in-replacement-block=no` — `not discretionary** — report the…`
- `P6   C=1 W=1 claims=CW single-line+unique=ok in-replacement-block=no` — `is not settled here, and this change does not settle it…`
- `P7   C=1 W=1 claims=CW single-line+unique=ok in-replacement-block=no` — `These records are one contract…`
- `P8   C=1 W=1 claims=CW single-line+unique=ok in-replacement-block=no` — `the resolve rule is not waived, no pass is credited as…`
- `P9   C=1 W=1 claims=CW single-line+unique=ok in-replacement-block=no` — `Every other rule stated here about how a cycle closes…`
- `P10  C=1 W=1 claims=CW single-line+unique=ok in-replacement-block=no` — `fix Blocker/Major after each…`
- `P11  C=1 W=1 claims=CW single-line+unique=ok in-replacement-block=no` — `final pass must be clean…`
- `P12  C=1 W=1 claims=CW single-line+unique=ok in-replacement-block=no` — `when a pass is clean…`
- `P13  C=1 W=1 claims=CW single-line+unique=ok in-replacement-block=no` — `clean pass is the single body line…`
- `P14  C=1 W=1 claims=CW single-line+unique=ok in-replacement-block=no` — `Each pass: validate, revise, re-run…`
- `P15  C=1 W=1 claims=CW single-line+unique=ok in-replacement-block=no` — `The Blocker/Major filter, the file-first findings protocol…`
- `P16  C=1 W=1 claims=CW single-line+unique=ok in-replacement-block=no` — `and the nonce duties at their strictest — the cycle…`
- `P17  C=1 W=1 claims=CW single-line+unique=ok in-replacement-block=no` — `Hook text is out of scope here…`
- `P18  C=1 W=1 claims=CW single-line+unique=ok in-replacement-block=no` — `execute → tests green → Gate B → commit…`
- `P19  C=1 W=1 claims=CW single-line+unique=ok in-replacement-block=no` — `where the cycle's own closure rules are satisfied.…`
- `P20  C=1 W=1 claims=CW single-line+unique=ok in-replacement-block=no` — `Nothing here writes the floor knob: it stays the user's, never written…`
- `P21  C=1 W=1 claims=CW single-line+unique=ok in-replacement-block=no` — `Several records…`
- `P22  C=1 W=1 claims=CW single-line+unique=ok in-replacement-block=no` — `` nothing that any mandatory rule in this file or in `AGENTS.md` require… ``
- `F1   C=1 W=1 claims=CW single-line+unique=ok in-replacement-block=no` — `nor resets your pass counters. A pre-review snapshot named anything el…`
- `F2   C=1 W=1 claims=CW single-line+unique=ok in-replacement-block=no` — `` `NO FINDINGS` if clean" in `additionalContext`, with the same one-line… ``
- `F3   C=1 W=1 claims=CW single-line+unique=ok in-replacement-block=no` — `**Majors are recorded as well as Findings and Blockers**, because the…`
- `F4   C=1 W=1 claims=CW single-line+unique=ok in-replacement-block=no` — `neither a human's assent nor this record…`
- `F5   C=1 W=1 claims=CW single-line+unique=ok in-replacement-block=no` — `**Finishing the cycle:** after the final clean pass, close it with…`
- `F6   C=1 W=1 claims=CW single-line+unique=ok in-replacement-block=no` — `reviews the TEXT you pass, not the git tree). Use ONE broad prompt, re…`
- `F7   C=1 W=1 claims=CW single-line+unique=ok in-replacement-block=no` — `**Which commit:** an ungated change records it in that commit; a Gate-…`
- `F7b  C=1 W=1 claims=CW single-line+unique=ok in-replacement-block=no` — `restated by the closing amend…`
- `F8   C=1 W=1 claims=CW single-line+unique=ok in-replacement-block=no` — `` snapshot by amend — a non-`WIP` commit reads to the hook as the cycle… ``
- `F9   C=1 W=1 claims=CW single-line+unique=ok in-replacement-block=no` — `taken from the provenance line and the curve, which must agree. A Gate…`
- `F10  C=1 W=1 claims=CW single-line+unique=ok in-replacement-block=no` — `(Blocker/Major only), derived from the cited story's profile.**…`
- `F11  C=1 W=1 claims=CW single-line+unique=ok in-replacement-block=no` — `with severity and confidence — you filter to Blocker/Major downstream,…`
- `F12  C=1 W=1 claims=CW single-line+unique=ok in-replacement-block=no` — `before the cycle-closing amend…`
- `F13  C=1 W=1 claims=CW single-line+unique=ok in-replacement-block=no` — `cannot name both, the finding is Minor or below: collect, never iterat…`
- `F14  C=1 W=1 claims=CW single-line+unique=ok in-replacement-block=no` — `profile sits still. If revalidation changes the entry, the clean pass…`

**Reading result for F1, F2, F3** (no §F line range, so checked by reading): F1 runs from the kept
`nor resets your pass counters.` into `reads as a`, which item 1 rewrites to `reads to the hook as` —
gone after install. F2 lies inside the sentence item 2 replaces whole. F3 runs into `because the
severity rule moves the`, which item 3 rewrites — gone after install. All three usable.

**Rows added by Task 0:** P19 (`a12`), P20 (`a14`), P21 (`h6`), P22 (`h18`) — kept conditions that
share a line with changed text, recorded as `cond` rows in `.context/loop-rule-untouched`.

**Inherited drift found by step 3, beyond the inventory's expected divergences** — recorded here and
carried to Task 14; no edit of this change is aimed at it: (1) passage (d)'s three-lines sentence
wraps differently in C and W, same words; (2) C has no blank line between the Surfacing paragraph and
`**Every pass report states`, W has one; (3) the opening of the `**Findings go to a FILE` paragraph
differs (`In the field, long finding` in C, `Long finding lists come back` in W).

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

### Task 1

§A is add-only: row P1, no OLD half. Three presence fragments, one per paragraph, each a single line
and unique in each copy:

```
presence §A1 `How a cycle ends — one ordering, stated here and referenced everywhere else` worktree=1 parent=0 C
presence §A1 `How a cycle ends — one ordering, stated here and referenced everywhere else` worktree=1 parent=0 W
presence §A2 `**Gate A's content condition, and its closing act.** These are what Gate A adds to the conditions` worktree=1 parent=0 C
presence §A2 `**Gate A's content condition, and its closing act.** These are what Gate A adds to the conditions` worktree=1 parent=0 W
presence §A3 `**Gate B's content condition, and its closing act.** These are what Gate B adds to the conditions` worktree=1 parent=0 C
presence §A3 `**Gate B's content condition, and its closing act.** These are what Gate B adds to the conditions` worktree=1 parent=0 W
```

Parity: the `**How a cycle ends` … `**What a loop absorbs` region extracted from both copies, both
non-empty, `diff` empty. The blocks were installed with the target's own line breaks, identical in
both copies.

### Task 3

Passage (b) replaced whole by §B's common span, installed with the target's line breaks in both
copies; C keeps its field-mint parenthetical after the span. Step 1: P2 and P3 counted 1 in both
copies before the install. Step 1b appended P23–P38 (seven replaced OLD halves, nine carried
preservation fragments).

```
pair b3  `Blocker/Major resolve, Minor/Nit collect` (P23) `severity exactly as Mechanics · Severity says. Ancestry decides` 0 1 1 0 C
pair b3  (same) 0 1 1 0 W
pair b7  P2 `union of the scope every approved story or plan governing this change assigns to this cycle,` 0 1 1 0 C
pair b7  (same) 0 1 1 0 W
pair b8  P24 `A finding is in-set when repairing it stays inside **the assigned fix set as` 0 1 1 0 C
pair b8  (same) 0 1 1 0 W
pair b11 P25 `finding** — except one this cycle has already declined, which is outside the set by that` 0 1 1 0 C
pair b11 (same) 0 1 1 0 W
pair b12 P3 `which resumes only when every answer outstanding on that surface has been given.` 0 1 1 0 C
pair b12 (same) 0 1 1 0 W
pair b13 P26 `new meaning not already` 0 1 1 0 C
pair b13 (same) 0 1 1 0 W
pair b16 P27 `**Novelty overrides ancestry and nothing else:` 0 1 1 0 C
pair b16 (same) 0 1 1 0 W
pair b17 P28 `it is a **suspension**` 0 1 1 0 C
pair b17 (same) 0 1 1 0 W
pair b18 P29 `rule all stand, and what the answer does is stated there` 0 1 1 0 C
pair b18 (same) 0 1 1 0 W
presence closing-time set-change rule `**A change to this set costs the cycle at least one further pass.**` 1 0 C
presence closing-time set-change rule (same) 1 0 W
preservation b1  P30 1 1 C · 1 1 W
preservation b2  P31 1 1 C · 1 1 W
preservation b4  P32 1 1 C · 1 1 W
preservation b5  P33 1 1 C · 1 1 W
preservation b6  P34 1 1 C · 1 1 W
preservation b9  P35 1 1 C · 1 1 W
preservation b10 P36 1 1 C · 1 1 W
preservation b14 P37 1 1 C · 1 1 W
preservation b15 P38 1 1 C · 1 1 W
```

Pair columns are old/worktree old/parent new/worktree new/parent; preservation columns are parent
worktree. Parity (`**What a loop absorbs` … `**Recognizing "clearly stuck"`): the only difference is
C's field-mint parenthetical. Walk: the installed passage is §B's block verbatim; `b3` now reads
`Mechanics · Severity` in both copies, so W's old `the severity rule` is gone.

### Task 4

§C's block installed over `So this exit needs three things` … `keeps looping.` in both copies, with
the target's line breaks; the kept prefix (`c1`–`c3`) and the Surfacing paragraph (Task 7's) are
untouched. Step 1 re-confirmed P4 at 1 in both copies and appended P39–P52. The precedence clause
counts exactly 1 per copy, inside §A (C 529, W 736). Pair columns old/worktree old/parent
new/worktree new/parent; the others worktree parent. Every line holds for C and for W.

```
pair c4 P42 `a missing one means only that *this* exit does not apply` 0 1 1 0 C,W
pair c8 P46 `a recurrence failing them being an ordinary fresh finding` 0 1 1 0 C,W
pair c14 (suspend) P4 `floor the pass **suspends**, the clean pass having failed eligibility.` 0 1 1 0 C,W
presence c14 (continue, add-only) `A below-floor clean pass lands here on the same` 1 0 C,W
absence c9 P47 0 1 C,W · presence §A `**A clean completion takes precedence over this exit**` 1 0 C,W
absence c10 P49 0 1 C,W · presence §A `pass **at or above the floor** has satisfied the clean-final-pass rule — collect the Minors and` 1 0 C,W
absence c11 P50 0 1 C,W · presence §A `Nits and close — and reporting "will not converge" on a converged loop is a false report. Below the` 1 0 C,W
absence c12 P51 0 1 C,W · presence §A `**Eligibility is exactly this and nothing more: a clean pass at or above the derived floor, or a` 1 0 C,W
absence c13 P52 0 1 C,W · presence §A `zero-finding pass.** It is a property of the pass.` 1 0 C,W
preservation c1 P39 · c2 P40 · c3 P41 (kept prefix) 1 1 C,W
preservation c5 P43 · c6 P44 · c7 P45 (carried) 1 1 C,W
preservation plateau rationale P48 (stays, no id) 1 1 C,W
```

Parity over `**Recognizing "clearly stuck"` … `**Surfacing does not`: no difference.

### Task 5

§D's `e7` sentence installed over the live threshold sentence in both copies — W now carries C's
`you report the tells`, so the `e8` divergence is gone. §D's pointer paragraph added at the end of
passage (e): in C after the C-only `e11` paragraph, in W after `e10`, each followed by a blank line
before `**The two rules above`. Step 1 re-confirmed P5 (C) and P5w (W) at 1 and appended P53–P61.

```
pair e7 P5 `clean-completion branch of the closure ordering, which outranks it **by taking the pass to the` 0 1 1 0 C
pair e7 P5w (same NEW) 0 1 1 0 W
presence e8 alignment `you report the tells` 1 0 W
presence §D pointer `**What the answer does** is the closure ordering's, which is where this stop's place among the` 1 0 C,W
preservation e1 P53 · e2 P54 · e3 P55 · e4 P56 · e5 P57 · e6 P58 (kept) 1 1 C,W
preservation e9 P59 (carried) 1 1 C,W
preservation e10 P60 (kept, after the block) 1 1 C,W
preservation e11 P61 (kept, C only) 1 1 C · 0 0 W
```

Parity over `Those three lines expose` … `**The two rules above`: the only difference is C's `e11`
paragraph.

### Task 6

§E's two blocks installed in both copies: the Severity bullet's first sentence, and the answer
paragraph in place of `**How this demotion bears…` — in C together with the `g4` ownership
sentence. Step 1 observed C `g1/g2: 1  g4: 1`, W `g1/g2: 1  g4: 0`, and appended P62–P65.

```
pair Severity resolve duty P62 `must resolve, **for every finding in the assigned fix set as the absorb paragraph computes it**.` 0 1 1 0 C,W
pair g1 P6 `**The demotion changes what a cycle must resolve, never what it observes.**` 0 1 1 0 C,W
absence g2 P63 1 0 C,W
absence g3 P64 1 0 C,W
absence g4 P65 1 0 C · 0 0 W (W never carried it)
```

Absence columns are parent worktree. Step 4: the story path counts 0 in `CLAUDE.md`. Step 5: parity
over `- **Severity:**` … `- **Tool routing:` — no difference.

### Task 7

§G's block and §H's nine blocks installed in both copies, one site at a time; step 1 re-confirmed
P7–P16 at 1 in each copy (20 counts) and step 1b appended P66–P93. Blocks inside an indented list
take the host's two-space indent (§G, the Gate-A clean signal, the Gate-A cadence); the template
sentence takes the host's `> ` prefix. The lens paragraph is replaced whole, its first sentence
being restated by §H's block. The strict-reading block's first two lines are joined at
`owed, the curve duty owed,` so the carried `i7` fragment sits on one line (words unchanged).

```
pair §G P7 `**These rules and records are one contract, and a partial adoption breaks it.**` 0 1 1 0 C,W
pair c18 P8 `**A pass is credited clean or not on its own findings**` 0 1 1 0 C,W
pair a13 P9 `Every other rule stated **in this paragraph**` 0 1 1 0 C,W
pair a16 P10 `resolve Blocker/Major after each as` 0 1 1 0 C,W
pair a17–a22 pointer P11 `What a clean final pass and the zero-finding early exit mean for closing` 0 1 1 0 C,W
pair Gate-A clean signal P12 `and no scope-stop trigger** is clean too` 0 1 1 0 C,W
pair template clean sentence P13 `A **clean findings file** is the single body line` 0 1 1 0 C,W
pair Gate-A cadence P14 `revise **where a repair is required**` 0 1 1 0 C,W
pair lens unchanged-list P15 `**the lens sets** leave every other` 0 1 1 0 C,W
pair strict-reading list P16 `every suspension binding, since` 0 1 1 0 C,W
pair c16 P67 `the cycle and the new hold still open*` 0 1 1 0 C,W
pair c17 P68 `the resolve rule stands over the finding exactly as` 0 1 1 0 C,W
pair c19 P69 `its answers are given, and **what the answer does is the closure ordering's**.` 0 1 1 0 C,W
pair c20 P70 `exit in competition with the rule that every **in-set** Blocker and Major resolves, and then` 0 1 1 0 C,W
absence a13 first sentence P71 1 0 C,W
absence a17 P11 1 0 C,W · presence §A `discharged by the count of valid logical passes reaching it with the last of them` 1 0 C,W
absence a18 P73 1 0 C,W · presence §A `runs another pass on the **current** artifact, revised where the severity and scope rules require a` 1 0 C,W
absence a19 P74 1 0 C,W · presence §A `A pass with **zero** findings is clean` 1 0 C,W
absence a20 P75 1 0 C,W · presence §A `has already given what those looks were for; don't manufacture findings to` 1 0 C,W
presence §G membership test (add-only) `**Membership is decided by a test a reader can apply to the text in front of them, with` 1 0 C,W
presence strict tail 1 `starting rules that cannot be established cannot be read as having waived an open hold` 1 0 C,W
presence strict tail 2 `repeated-dismissal cleanliness exclusion unavailable` 1 0 C,W
presence strict tail 3 `the parked state binding after a closing act that cannot` 1 0 C,W
presence strict tail 4 `pass-cost rule this change ships owed rather than waived` 1 0 C,W
preservation carried c15 P66 · a15 P72 · a21 P76 · a22 P77 · i4 P78 · i5 P79 · i6 P80 · i7 P81 · i8 P82 1 1 C,W
preservation kept, passage (i) i1 P83 · i2 P84 · i3 P85 · i9 P86 · i10 P87 · i11 P88 · i12 P89 · i13 P90 · i14 P91 · i15 P92 · i16 P93 1 1 C,W
```

Pair columns old/worktree old/parent new/worktree new/parent; the rest parent worktree for absence
and preservation, worktree parent for presence. Parity per site (first installed line to last): §G,
c18/surfacing, a13+a16+a17, clean signal, template sentence, lens, strict list — no difference.
Cadence: the block is identical; the only difference is the kept remainder of its last line
(`settle mechanically what` in C, `what the` in W), an inherited wrap difference.

### Task 8

§F items 1–9, 7a, 8a, 8b, 9a, 9b installed in both copies. Step 1: every quoted live sentence located
by its fragment row; F1–F14 and F7b counted 1 in each copy before the install; P94 (`a1`) and P95
(`h3`) appended. Live sentences that wrap across lines, so a whole-sentence `grep -F` finds nothing:
all fourteen. Items 1, 4, 6, 7a, 8, 8b, 9a, 9 and 9b start mid-line and are joined to the kept text
before them; items 2, 3, 5, 7 and 8a start on their own line. W's item-2 sentence had no
`You filter to Blocker/Major, Codex never does.` line; the replacement covers both copies' forms.

Pair columns old/worktree old/parent new/worktree new/parent; every line holds for C and for W.

```
pair F1 0 1 1 0 C
pair F1 0 1 1 0 W
pair F2 0 1 1 0 C
pair F2 0 1 1 0 W
pair F3 0 1 1 0 C
pair F3 0 1 1 0 W
pair F4 0 1 1 0 C
pair F4 0 1 1 0 W
pair F5 0 1 1 0 C
pair F5 0 1 1 0 W
pair F6 0 1 1 0 C
pair F6 0 1 1 0 W
pair F7 0 1 1 0 C
pair F7 0 1 1 0 W
pair F7b 0 1 1 0 C
pair F7b 0 1 1 0 W
pair F8 0 1 1 0 C
pair F8 0 1 1 0 W
pair F9 0 1 1 0 C
pair F9 0 1 1 0 W
pair F10 0 1 1 0 C
pair F10 0 1 1 0 W
pair F11 0 1 1 0 C
pair F11 0 1 1 0 W
pair F12 0 1 1 0 C
pair F12 0 1 1 0 W
pair F13 0 1 1 0 C
pair F13 0 1 1 0 W
pair F14 0 1 1 0 C
pair F14 0 1 1 0 W
```

NEW fragments: F1 `reads to the hook as a real commit: the hook treats the` · F2 `` `NO FINDINGS` only when
the branch found none `` · F3 `because the three series are read` · F4 `**neither a human's general
assent nor this record**` · F5 `**when a Gate-B cycle's closing act is performed is the closure` · F6
`Use ONE broad prompt: **its review question stays the same every pass` · F7 `a Gate-A cycle in the
commit its` · F7b `restated by the commit its closing act` · F8 `the edit must end up **in the content
the next review reads**` · F9 `A Gate-A cycle has such a commit only once its own closing commit
exists` · F10 `passes per run (a clean final pass` · F11 `**you filter to Blocker/Major for what must be
repaired and read` · F12 `before the commit its closing act` · F13 `the finding is Minor or below:
collect; **its severity buys no` · F14 `the pass was read against an entry that no longer stands`.

```
preservation a1 P94 1 1 C,W
preservation h3 P95 1 1 C,W
```

New/worktree total: 15 in C, 15 in W — fifteen changed clauses from fourteen items. Parity per item,
first installed line to last: thirteen sites equal; item 8b's block is identical and its last line
differs only in C's kept parenthetical (`` (`docs/prompt-standards.md`, "coverage first, filter
later") ``), an inherited C-only divergence.

### Task 9

§F items 14 and 18 installed in both copies. Item 14's live sentence wraps after `here`; the block
replaces `Hook text is out of scope here by decision;`, and the kept clause after the semicolon
becomes its own sentence (`What makes that tolerable is the precedence rule above plus the hook
exiting 0 on every branch, …`). Item 18 replaces the whole one-line work-loop sentence.

```
pair item 14 P17 `it is not a blanket exemption for hook text**` 0 1 1 0 C,W
pair item 18 P18 `Gate B → Gate-B closing act**` 0 1 1 0 C,W
```

Step 4: the residual still stands — the paragraph's first sentence still says the hook's messages
state its own threshold as an obligation at a floor of 1, and the new sentence names that
overstatement as out of scope by decision. Parity: both sites equal.

### Task 10

Hazard probe: every §F block for items 10–13 and 15–17 (both channels for 12, 15, 16) printed
`clean`, read as data from the spec. `note "` hits: thirteen; the seven gate reminders are lines
908, 933, 945, 947, 956, 967, 973, and the docs-only notice (918) is untouched. Step 2b appended
P96–P103 from the live strings before the install. Step 4: seven zero-context hunks, one per
reminder line; every removed and added line read, and each is inside its `note` string — no
control flow, counter, fingerprint or routing change. `shellcheck --shell=sh` exit 0.

```
pair item 10 honesty claim P96 `Gate A has no content check in this hook; what the gate itself requires` 0 1 1 0 H
pair item 10 tail P97 `a further pass being one of its answers and not the only one` 0 1 1 0 H
pair item 11 P98 `Proceed only once this Gate-A cycle has closed under` 0 1 1 0 H
pair item 12 P99 `commit only if your final pass was clean and every other closure condition holds` 0 1 1 0 H
pair item 13 P100 `Use this commit as the review range; whether this cycle runs a review now` 0 1 1 0 H
pair item 15 P101 `Codex gate state: no fingerprint is recorded for this cycle` 0 1 1 0 H
pair item 16 P102 `A fresh Gate-B pass is the complete remedy for the staging and post-upgrade cases too` 0 1 1 0 H
pair item 17 P103 `skip rule decides only whether a cycle runs at all` 0 1 1 0 H
```

H = `plugins/dev-workflow/hooks/codex-gate.sh`. The suite is red between this commit and Task 11's,
as the plan states; the battery is not run here.

### Task 11

Swept `plugins/dev-workflow/hooks/codex-gate.test.sh` with the three step-1 locators. Mapping used,
so each assertion tests the same hook state as before: `grep -q 'not satisfied'` matched exactly the
two old STOP messages and now reads `grep -q 'Codex gate state:'`, which matches exactly the two new
ones (items 15, 16); `grep -q 'Gate B satisfied'` now reads `grep -q 'Gate B hook checks passed'`
(item 12's terse channel); positive and negative `grep -q 'STOP'` checks now read
`'Codex gate state:'`. The three `expected_ctx` and three `expected_msg` assignments take items 16,
12 and 15 whole, with `$policy` rendered as `this project's review policy` and the counters the
fixture sets. Labels and comments now name the observed hook state.

Suite: `HOOK_SH=sh sh …test.sh` exit 0 and `HOOK_SH=dash dash …test.sh` exit 0, both `all passed`.
`shellcheck --shell=sh --exclude=SC2015` exit 0. Step 5: `Gate B satisfied|Gate B not
satisfied|Gate A satisfied` counts 0. Remaining case-insensitive `satisfied` hits, disposed of: line
1352 and line 1536 are comments using the plain English verb about test rows, not a gate verdict;
line 1971 is the fixture for the hook's unknown-tool note (`… satisfied count as covering them`),
a message this change does not replace.

Sites examined and what each became:

```
sweep codex-gate.test.sh 173 `# 2. Below floor (1/3) -> NOT satisfied yet; reaching floor (3/3) -> satisfied` → `# 2. Below floor (1/3) -> below-floor reminder; reaching floor (3/3) -> hook checks passed`
sweep codex-gate.test.sh 179 `printf '%s' "$out" | grep -q 'Gate B satisfied' && pass "3/3 passes, unchanged tree -> satisfied" || fail "3/3` → `printf '%s' "$out" | grep -q 'Gate B hook checks passed' && pass "3/3 passes, unchanged tree -> hook checks pa`
sweep codex-gate.test.sh 184 `# intent "a change means Gate B is not satisfied" is asserted at the BEHAVIOR level.)` → `# intent "a change means the hook cannot confirm the reviewed content" is asserted at the BEHAVIOR level.)`
sweep codex-gate.test.sh 189 `printf '%s' "$out" | grep -q 'not satisfied' && pass "Edit-tool change -> not satisfied" || fail "Edit-tool ch` → `printf '%s' "$out" | grep -q 'Codex gate state:' && pass "Edit-tool change -> gate-state reminder" || fail "Ed`
sweep codex-gate.test.sh 197 `printf '%s' "$out" | grep -q 'Gate B satisfied' && pass "setup: satisfied before bash edit" || fail "setup: sa` → `printf '%s' "$out" | grep -q 'Gate B hook checks passed' && pass "setup: hook checks passed before bash edit" `
sweep codex-gate.test.sh 200 `printf '%s' "$out" | grep -q 'not satisfied' && pass "bash-modified file after review -> NOT satisfied (Findin` → `printf '%s' "$out" | grep -q 'Codex gate state:' && pass "bash-modified file after review -> gate-state remind`
sweep codex-gate.test.sh 206 `printf '%s' "$(commitpre)" | grep -q 'Gate B satisfied' && pass "setup: satisfied on clean tree" || fail "setu` → `printf '%s' "$(commitpre)" | grep -q 'Gate B hook checks passed' && pass "setup: hook checks passed on clean t`
sweep codex-gate.test.sh 209 `printf '%s' "$out" | grep -q 'not satisfied' && pass "untracked new file after review -> NOT satisfied" || fai` → `printf '%s' "$out" | grep -q 'Codex gate state:' && pass "untracked new file after review -> gate-state remind`
sweep codex-gate.test.sh 215 `printf '%s' "$(commitpre)" | grep -q 'Gate B satisfied' && pass "setup: satisfied with untracked file present"` → `printf '%s' "$(commitpre)" | grep -q 'Gate B hook checks passed' && pass "setup: hook checks passed with untra`
sweep codex-gate.test.sh 217 `printf '%s' "$(commitpre)" | grep -q 'not satisfied' && pass "edited untracked file -> NOT satisfied" || fail ` → `printf '%s' "$(commitpre)" | grep -q 'Codex gate state:' && pass "edited untracked file -> gate-state reminder`
sweep codex-gate.test.sh 223 `printf '%s' "$(commitpre)" | grep -q 'not satisfied' && pass "new untracked dir -> NOT satisfied" || fail "new` → `printf '%s' "$(commitpre)" | grep -q 'Codex gate state:' && pass "new untracked dir -> gate-state reminder" ||`
sweep codex-gate.test.sh 226 `printf '%s' "$(commitpre)" | grep -q 'not satisfied' && pass "edited file in untracked dir -> NOT satisfied" |` → `printf '%s' "$(commitpre)" | grep -q 'Codex gate state:' && pass "edited file in untracked dir -> gate-state r`
sweep codex-gate.test.sh 235 `printf '%s' "$(commitpre)" | grep -q 'not satisfied' && pass "new exotic-path untracked file -> NOT satisfied"` → `printf '%s' "$(commitpre)" | grep -q 'Codex gate state:' && pass "new exotic-path untracked file -> gate-state`
sweep codex-gate.test.sh 238 `printf '%s' "$(commitpre)" | grep -q 'not satisfied' && pass "edited exotic-path untracked file -> NOT satisfi` → `printf '%s' "$(commitpre)" | grep -q 'Codex gate state:' && pass "edited exotic-path untracked file -> gate-st`
sweep codex-gate.test.sh 247 `printf '%s' "$(commitpre)" | grep -q 'not satisfied' && pass "new untracked symlink -> NOT satisfied" || fail ` → `printf '%s' "$(commitpre)" | grep -q 'Codex gate state:' && pass "new untracked symlink -> gate-state reminder`
sweep codex-gate.test.sh 250 `printf '%s' "$(commitpre)" | grep -q 'not satisfied' && pass "retargeted untracked symlink -> NOT satisfied" |` → `printf '%s' "$(commitpre)" | grep -q 'Codex gate state:' && pass "retargeted untracked symlink -> gate-state r`
sweep codex-gate.test.sh 279 `# 3d. Reverting the tree back to the reviewed content -> satisfied again` → `# 3d. Reverting the tree back to the reviewed content -> hook checks pass again`
sweep codex-gate.test.sh 282 `printf '%s' "$out" | grep -q 'Gate B satisfied' && pass "revert to reviewed tree -> satisfied again" || fail "` → `printf '%s' "$out" | grep -q 'Gate B hook checks passed' && pass "revert to reviewed tree -> hook checks pass `
sweep codex-gate.test.sh 287 `printf '%s' "$out" | grep -q 'Gate B satisfied' && pass ".context/ churn does not invalidate the hash" || fail` → `printf '%s' "$out" | grep -q 'Gate B hook checks passed' && pass ".context/ churn does not invalidate the hash`
sweep codex-gate.test.sh 291 `# review it just recorded -> a permanent stale STOP. The adoption marker is meant to be` → `# review it just recorded -> a permanent stale-fingerprint reminder. The adoption marker is meant to be`
sweep codex-gate.test.sh 296 `printf '%s' "$(commitpre)" | grep -q 'Gate B satisfied' && pass "tracked .context/ state does not invalidate t` → `printf '%s' "$(commitpre)" | grep -q 'Gate B hook checks passed' && pass "tracked .context/ state does not inv`
sweep codex-gate.test.sh 298 `printf '%s' "$(commitpre)" | grep -q 'Gate B satisfied' && pass "tracked .context/ churn stays satisfied" || f` → `printf '%s' "$(commitpre)" | grep -q 'Gate B hook checks passed' && pass "tracked .context/ churn still passes`
sweep codex-gate.test.sh 312 `printf '%s' "$(commitpre)" | grep -q 'Gate B satisfied' && pass "setup: satisfied with sidefile.ts staged" || ` → `printf '%s' "$(commitpre)" | grep -q 'Gate B hook checks passed' && pass "setup: hook checks passed with sidef`
sweep codex-gate.test.sh 316 `printf '%s' "$out" | grep -q 'Gate B satisfied' \` → `printf '%s' "$out" | grep -q 'Gate B hook checks passed' \`
sweep codex-gate.test.sh 324 `printf '%s' "$(commitpre)" | grep -q 'not satisfied' && pass "tracked .context/: real code change still invali` → `printf '%s' "$(commitpre)" | grep -q 'Codex gate state:' && pass "tracked .context/: real code change still in`
sweep codex-gate.test.sh 333 `# direction"), and the STOP message explains that staging alone can cause it.` → `# direction"), and the stale-fingerprint message explains that staging alone can cause it.`
sweep codex-gate.test.sh 339 `printf '%s' "$(commitpre)" | grep -q 'Gate B satisfied' && pass "setup: satisfied on unstaged change" || fail ` → `printf '%s' "$(commitpre)" | grep -q 'Gate B hook checks passed' && pass "setup: hook checks passed on unstage`
sweep codex-gate.test.sh 341 `printf '%s' "$(commitpre)" | grep -q 'not satisfied' \` → `printf '%s' "$(commitpre)" | grep -q 'Codex gate state:' \`
sweep codex-gate.test.sh 341 `&& pass "staging a reviewed tracked file -> NOT satisfied (spec §2 decision)" \` → `&& pass "staging a reviewed tracked file -> gate-state reminder (spec §2 decision)" \`
sweep codex-gate.test.sh 341 `|| fail "staging a reviewed tracked file -> NOT satisfied (spec §2 decision)"` → `|| fail "staging a reviewed tracked file -> gate-state reminder (spec §2 decision)"`
sweep codex-gate.test.sh 341 `# The old trailing assertion ("untracked file on a staged tree -> not satisfied") is` → `# The old trailing assertion ("untracked file on a staged tree -> gate-state reminder") is`
sweep codex-gate.test.sh 350 `# 4. Gate A exec must NOT satisfy Gate B (separate state)` → `# 4. Gate A exec must NOT count toward Gate B (separate state)`
sweep codex-gate.test.sh 438 `printf '%s' "$out" | grep -q 'Gate B satisfied' && pass "re-enable sees same counting semantics as gate-on, no` → `printf '%s' "$out" | grep -q 'Gate B hook checks passed' && pass "re-enable sees same counting semantics as ga`
sweep codex-gate.test.sh 447 `reset_all # state ABSENT -> would normally STOP on a code commit` → `reset_all # state ABSENT -> would normally emit the no-fingerprint reminder on a code commit`
sweep codex-gate.test.sh 453 `printf '%s' "$out" | grep -q 'STOP' && fail "docs-only must not STOP" || pass "docs-only does not STOP"` → `printf '%s' "$out" | grep -q 'Codex gate state:' && fail "docs-only must not emit the gate-state reminder" || `
sweep codex-gate.test.sh 504 `printf '%s' "$out" | grep -q 'floor met' && pass "3/3 exec -> Gate A satisfied" || fail "3/3 exec -> Gate A sa` → `printf '%s' "$out" | grep -q 'floor met' && pass "3/3 exec -> Gate A floor met" || fail "3/3 exec -> Gate A fl`
sweep codex-gate.test.sh 504 `# FINDING 12: the Gate-A satisfied wording must NOT overstate — it counts calls only.` → `# FINDING 12: the Gate-A floor-met wording must NOT overstate — it counts calls only.`
sweep codex-gate.test.sh 504 `printf '%s' "$out" | grep -qE 'count only|COUNT ONLY' && pass "Gate A satisfied says 'count only' (Finding 12)` → `printf '%s' "$out" | grep -qE 'count only|COUNT ONLY' && pass "Gate A floor-met message says 'count only' (Fin`
sweep codex-gate.test.sh 523 `printf '%s' "$out" | grep -q '1/1' && pass "floor override 1 -> satisfied at 1 pass" || fail "floor override 1` → `printf '%s' "$out" | grep -q '1/1' && pass "floor override 1 -> hook checks pass at 1 pass" || fail "floor ove`
sweep codex-gate.test.sh 523 `printf '%s' "$out" | grep -q 'Gate B satisfied' && pass "floor override 1 -> reports satisfied" || fail "floor` → `printf '%s' "$out" | grep -q 'Gate B hook checks passed' && pass "floor override 1 -> reports hook checks pass`
sweep codex-gate.test.sh 540 `# 18. FINDING 9 — satisfied message distinguishes fresh passes from cycle passes` → `# 18. FINDING 9 — hook-checks-passed message distinguishes fresh passes from cycle passes`
sweep codex-gate.test.sh 556 `# 19. FINDING 11 — WIP commit is cycle-internal: gentle note, no STOP, no reset` → `# 19. FINDING 11 — WIP commit is cycle-internal: gentle note, no gate-state reminder, no reset`
sweep codex-gate.test.sh 561 `printf '%s' "$out" | grep -q 'STOP' && fail "WIP commit must not STOP" || pass "WIP commit does not STOP"` → `printf '%s' "$out" | grep -q 'Codex gate state:' && fail "WIP commit must not emit the gate-state reminder" ||`
sweep codex-gate.test.sh 633 `[ -z "$(commitpre)" ] && pass "non-adopted repo: unreviewed commit -> no STOP" || fail "non-adopted repo: unre` → `[ -z "$(commitpre)" ] && pass "non-adopted repo: unreviewed commit -> no reminder" || fail "non-adopted repo: `
sweep codex-gate.test.sh 652 `# one — otherwise a stale-tree STOP would masquerade as non-adoption.)` → `# one — otherwise a stale-fingerprint reminder would masquerade as non-adoption.)`
sweep codex-gate.test.sh 660 `printf '%s' "$(commitpre)" | grep -q 'Gate B satisfied' && pass ".on marker alone -> adopted" || fail ".on mar` → `printf '%s' "$(commitpre)" | grep -q 'Gate B hook checks passed' && pass ".on marker alone -> adopted" || fail`
sweep codex-gate.test.sh 665 `printf '%s' "$(commitpre)" | grep -q 'Gate B satisfied' && pass "CLAUDE.md gate heading -> adopted" || fail "C` → `printf '%s' "$(commitpre)" | grep -q 'Gate B hook checks passed' && pass "CLAUDE.md gate heading -> adopted" |`
sweep codex-gate.test.sh 713 `printf '%s' "$out" | grep -q 'STOP' && pass "marker-only: still STOPs" || fail "marker-only: still STOPs"` → `printf '%s' "$out" | grep -q 'Codex gate state:' && pass "marker-only: still emits the gate-state reminder" ||`
sweep codex-gate.test.sh 732 `# 24. Failure contract: an uncomputable hash must never satisfy, and repeated failures` → `# 24. Failure contract: an uncomputable hash must never pass the hook checks, and repeated failures`
sweep codex-gate.test.sh 753 `printf '%s' "$out" | grep -q 'not satisfied' && pass "silent checksum -> not satisfied" || fail "silent checks` → `printf '%s' "$out" | grep -q 'Codex gate state:' && pass "silent checksum -> gate-state reminder" || fail "sil`
sweep codex-gate.test.sh 768 `printf '%s' "$out" | grep -q 'not satisfied' && pass "checksum prints then fails -> not satisfied" || fail "ch` → `printf '%s' "$out" | grep -q 'Codex gate state:' && pass "checksum prints then fails -> gate-state reminder" |`
sweep codex-gate.test.sh 786 `printf '%s' "$(PATH="$stub_dir:$PATH" commitpre)" | grep -q 'not satisfied' \` → `printf '%s' "$(PATH="$stub_dir:$PATH" commitpre)" | grep -q 'Codex gate state:' \`
sweep codex-gate.test.sh 786 `&& pass "seed-copy failure -> not satisfied" || fail "seed-copy failure -> not satisfied"` → `&& pass "seed-copy failure -> gate-state reminder" || fail "seed-copy failure -> gate-state reminder"`
sweep codex-gate.test.sh 800 `printf '%s' "$(PATH="$stub_dir:$PATH" commitpre)" | grep -q 'not satisfied' \` → `printf '%s' "$(PATH="$stub_dir:$PATH" commitpre)" | grep -q 'Codex gate state:' \`
sweep codex-gate.test.sh 800 `&& pass "git diff failure -> not satisfied" || fail "git diff failure -> not satisfied"` → `&& pass "git diff failure -> gate-state reminder" || fail "git diff failure -> gate-state reminder"`
sweep codex-gate.test.sh 812 `printf '%s' "$(PATH="$stub_dir:$PATH" commitpre)" | grep -q 'not satisfied' \` → `printf '%s' "$(PATH="$stub_dir:$PATH" commitpre)" | grep -q 'Codex gate state:' \`
sweep codex-gate.test.sh 812 `&& pass "unresolvable git-dir -> not satisfied" || fail "unresolvable git-dir -> not satisfied"` → `&& pass "unresolvable git-dir -> gate-state reminder" || fail "unresolvable git-dir -> gate-state reminder"`
sweep codex-gate.test.sh 836 `# first commit in a fresh repo STOPs forever. Spec §3 "But an absent index is not a` → `# first commit in a fresh repo gets the gate-state reminder forever. Spec §3 "But an absent index is not a`
sweep codex-gate.test.sh 851 `# ...and the FIRST commit must actually be able to reach satisfied. Hashing and` → `# ...and the FIRST commit must actually be able to reach hook checks passed. Hashing and`
sweep codex-gate.test.sh 851 `# self-matching is not enough: a consumer-side regression could still STOP every` → `# self-matching is not enough: a consumer-side regression could still remind on every`
sweep codex-gate.test.sh 855 `printf '%s' "$out" | grep -q 'Gate B satisfied' || exit 1` → `printf '%s' "$out" | grep -q 'Gate B hook checks passed' || exit 1`
sweep codex-gate.test.sh 855 `) && pass "unborn repo hashes, self-matches, and can reach satisfied" \` → `) && pass "unborn repo hashes, self-matches, and can reach hook checks passed" \`
sweep codex-gate.test.sh 855 `|| fail "unborn repo hashes, self-matches, and can reach satisfied"` → `|| fail "unborn repo hashes, self-matches, and can reach hook checks passed"`
sweep codex-gate.test.sh 866 `printf '%s' "$(commitpre)" | grep -q 'Gate B satisfied' && pass "setup: satisfied on clean tree" || fail "setu` → `printf '%s' "$(commitpre)" | grep -q 'Gate B hook checks passed' && pass "setup: hook checks passed on clean t`
sweep codex-gate.test.sh 869 `printf '%s' "$(commitpre)" | grep -q 'not satisfied' \` → `printf '%s' "$(commitpre)" | grep -q 'Codex gate state:' \`
sweep codex-gate.test.sh 869 `&& pass "staged-vs-worktree divergence -> NOT satisfied" \` → `&& pass "staged-vs-worktree divergence -> gate-state reminder" \`
sweep codex-gate.test.sh 869 `|| fail "staged-vs-worktree divergence -> NOT satisfied"` → `|| fail "staged-vs-worktree divergence -> gate-state reminder"`
sweep codex-gate.test.sh 874 `# 27. Ambient alternate index. Three shapes: a negative-only test would be satisfied by` → `# 27. Ambient alternate index. Three shapes: a negative-only test would be passed by`
sweep codex-gate.test.sh 874 `# an implementation that fires whenever GIT_INDEX_FILE is set — a permanent STOP.` → `# an implementation that fires whenever GIT_INDEX_FILE is set — a permanent gate-state reminder.`
sweep codex-gate.test.sh 884 `printf '%s' "$(GIT_INDEX_FILE="$alt_dir/alt" commitpre)" | grep -q 'not satisfied' \` → `printf '%s' "$(GIT_INDEX_FILE="$alt_dir/alt" commitpre)" | grep -q 'Codex gate state:' \`
sweep codex-gate.test.sh 884 `&& pass "ambient divergent alternate index -> NOT satisfied" \` → `&& pass "ambient divergent alternate index -> gate-state reminder" \`
sweep codex-gate.test.sh 884 `|| fail "ambient divergent alternate index -> NOT satisfied"` → `|| fail "ambient divergent alternate index -> gate-state reminder"`
sweep codex-gate.test.sh 884 `# 27b. stable: same unchanged alternate index across review AND commit -> satisfied,` → `# 27b. stable: same unchanged alternate index across review AND commit -> hook checks passed,`
sweep codex-gate.test.sh 896 `printf '%s' "$(GIT_INDEX_FILE="$alt_dir/alt" commitpre)" | grep -q 'Gate B satisfied' \` → `printf '%s' "$(GIT_INDEX_FILE="$alt_dir/alt" commitpre)" | grep -q 'Gate B hook checks passed' \`
sweep codex-gate.test.sh 896 `&& pass "ambient stable alternate index -> satisfied" \` → `&& pass "ambient stable alternate index -> hook checks passed" \`
sweep codex-gate.test.sh 896 `|| fail "ambient stable alternate index -> satisfied"` → `|| fail "ambient stable alternate index -> hook checks passed"`
sweep codex-gate.test.sh 928 `# the two constant empty-tree hashes MATCH — a false "satisfied" even though the` → `# the two constant empty-tree hashes MATCH — a false "hook checks passed" even though the`
sweep codex-gate.test.sh 943 `printf '%s' "$out" | grep -q 'not satisfied' \` → `printf '%s' "$out" | grep -q 'Codex gate state:' \`
sweep codex-gate.test.sh 943 `&& pass "relative ambient GIT_INDEX_FILE from a subdirectory -> NOT satisfied (Finding 1)" \` → `&& pass "relative ambient GIT_INDEX_FILE from a subdirectory -> gate-state reminder (Finding 1)" \`
sweep codex-gate.test.sh 943 `|| fail "relative ambient GIT_INDEX_FILE from a subdirectory -> NOT satisfied (Finding 1)"` → `|| fail "relative ambient GIT_INDEX_FILE from a subdirectory -> gate-state reminder (Finding 1)"`
sweep codex-gate.test.sh 1006 `expected_ctx="STOP — Codex Gate B not satisfied: the hook cannot confirm that the content you are about to com` → `expected_ctx="Codex gate state: the hook cannot confirm that the content you are about to commit is the conten`
sweep codex-gate.test.sh 1006 `expected_msg="⚠ Codex Gate B not satisfied (cannot confirm review)"` → `expected_msg="⚠ Codex Gate B: cannot confirm reviewed content"`
sweep codex-gate.test.sh 1012 `# 29b. SATISFIED branch: 3/3 passes this cycle, all 3 fresh (unchanged tree). The hook` → `# 29b. HOOK-CHECKS-PASSED branch: 3/3 passes this cycle, all 3 fresh (unchanged tree). The hook`
sweep codex-gate.test.sh 1019 `expected_ctx="Codex Gate B: 3/3 pass(es) this cycle, of which 3 cover the CURRENT content fingerprint (unchang` → `expected_ctx="Codex Gate B: 3/3 pass(es) this cycle, of which 3 cover the CURRENT content fingerprint (unchang`
sweep codex-gate.test.sh 1019 `expected_msg="✓ Codex Gate B satisfied (3/3 cycle, 3 on current fingerprint)"` → `expected_msg="✓ Codex Gate B hook checks passed (3/3 cycle, 3 on current fingerprint)"`
sweep codex-gate.test.sh 1019 `[ "$ctx" = "$expected_ctx" ] && pass "satisfied additionalContext matches exactly" || fail "satisfied addition` → `[ "$ctx" = "$expected_ctx" ] && pass "hook-checks-passed additionalContext matches exactly" || fail "hook-chec`
sweep codex-gate.test.sh 1019 `[ "$msg" = "$expected_msg" ] && pass "satisfied systemMessage matches exactly" || fail "satisfied systemMessag` → `[ "$msg" = "$expected_msg" ] && pass "hook-checks-passed systemMessage matches exactly" || fail "hook-checks-p`
sweep codex-gate.test.sh 1029 `expected_ctx="STOP — Codex Gate B not satisfied: no fingerprint is recorded for this cycle — either no mcp__co` → `expected_ctx="Codex gate state: no fingerprint is recorded for this cycle. The hook cannot tell why — no mcp__`
sweep codex-gate.test.sh 1029 `expected_msg="⚠ Codex Gate B: no recorded review"` → `expected_msg="⚠ Codex Gate B: no recorded fingerprint"`
sweep codex-gate.test.sh 1176 `# 7/9 Gate B satisfied` → `# 7/9 Gate B hook checks passed`
sweep codex-gate.test.sh 1178 `one_doc "Gate B satisfied" "$(commitpre)"` → `one_doc "Gate B hook checks passed" "$(commitpre)"`
```

### Task 14

Step 4b, after the last text edit — every `span` and `cond` row of `.context/loop-rule-untouched`, parent against worktree, anchors resolved separately in each tree:

```
span	The derivation is max(risk, security)	clean review, and a below-threshold remi	CLAUDE.md	no difference
span	From pass 4 onward every pass report car	Those three lines expose	CLAUDE.md	no difference
span	The two rules above do not compete	Findings go to a FILE	CLAUDE.md	no difference
span	On squash-merge, copy every evidence ent	On squash-merge, copy every evidence ent	CLAUDE.md	no difference
span	Recording a human exception	Accepted because: <one line>	CLAUDE.md	no difference
span	accumulate; order means nothing.	obligation, or a profile-derived evidenc	CLAUDE.md	no difference
span	**"Mandatory" is not limited to this fil	because writing it down makes it sound	CLAUDE.md	no difference
preservation	a12	P19	parent=1 worktree=1	CLAUDE.md	ok
preservation	a14	P20	parent=1 worktree=1	CLAUDE.md	ok
preservation	h6	P21	parent=1 worktree=1	CLAUDE.md	ok
preservation	h18	P22	parent=1 worktree=1	CLAUDE.md	ok
span	The derivation is max(risk, security)	clean review, and a below-threshold remi	plugins/dev-workflow/commands/workflow-init.md	no difference
span	From pass 4 onward every pass report car	Those three lines expose	plugins/dev-workflow/commands/workflow-init.md	no difference
span	The two rules above do not compete	Findings go to a FILE	plugins/dev-workflow/commands/workflow-init.md	no difference
span	On squash-merge, copy every evidence ent	On squash-merge, copy every evidence ent	plugins/dev-workflow/commands/workflow-init.md	no difference
span	Recording a human exception	Accepted because: <one line>	plugins/dev-workflow/commands/workflow-init.md	no difference
span	accumulate; order means nothing.	obligation, or a profile-derived evidenc	plugins/dev-workflow/commands/workflow-init.md	no difference
span	**"Mandatory" is not limited to this fil	because writing it down makes it sound	plugins/dev-workflow/commands/workflow-init.md	no difference
preservation	a12	P19	parent=1 worktree=1	plugins/dev-workflow/commands/workflow-init.md	ok
preservation	a14	P20	parent=1 worktree=1	plugins/dev-workflow/commands/workflow-init.md	ok
preservation	h6	P21	parent=1 worktree=1	plugins/dev-workflow/commands/workflow-init.md	ok
preservation	h18	P22	parent=1 worktree=1	plugins/dev-workflow/commands/workflow-init.md	ok
```

Failures: 0.

### Re-run before Gate-B pass 2

Before Gate-B pass 2 (cycle `t57gp3hwu1`), after the pass-1 repairs (§A continue-branch gloss in C,
W and the target text; CHANGELOG Gate-A sentence; Task 12 and Task 13 records): every fragment-table
row P2–P103, F1–F14, F7b re-counted in the copies it claims, to its class's result (OLD, absence →
worktree 0 parent 1; preservation → 1 1), and every recorded NEW / presence fragment → worktree 1
parent 0: 320 observations, 0 failures. The 18 moved-condition §A presences: 0 failures. The 14
untouched spans and 8 `cond` rows: 0 failures. Parity over the 34 site regions: the same three
classified differences, nothing new. The prompt-standards items were re-read for the one changed §A
clause: all twelve still pass.

### Re-run before Gate-B pass 3

Before Gate-B pass 3: the pass-2 amendments touched only this plan's Task 13 section (K defined without eligibility, the failed-act row split, three closure checks where one stood). Re-run of every fragment-table row and every recorded NEW/presence fragment: 320 observations, 0 failures; untouched spans and cond rows: 0 failures; parity: the same three classified differences.

### Gate-B provenance and deviation (cycle t57gp3hwu1)

**Process deviation, recorded:** the pass-1 repair round (commit `0382219`) and the pass-2 records
refresh (`f56fd50`) were made without Daniel's go, which the session handoff required for repair
rounds. Daniel kept them as the starting point on 2026-09-26 (the reviewer's recommendation he
forwarded); this is not a retroactive authorization. Pass 4 is released as one bounded pass.

**Review provenance, from the original Codex session transcripts** (`~/.codex/sessions/2026/09/26/`,
the last write to each slot; times UTC):

```
pass 1  base d26de4b… head 8436f17…  spec session 01a0dccf-4b26  quality session 01a0dccf-4b27
  08:26:02 quality slot  written by 01a0dccf-fbcd (subagent of the quality session)   3 lines  — final
  08:26:39 spec slot     written by 01a0dccf-cbdf (subagent of the QUALITY session)   3 lines  — overwritten
  08:28:09 spec slot     written by 01a0dccf-4b26 (the spec session itself)          7 lines  — final
pass 2  base d26de4b… head 0382219…  08:42:06 quality 01a0dcdc-1eb4 4 lines · 08:42:09 spec 01a0dcdc-1ec7 6 lines — one write each
pass 3  base d26de4b… head f56fd50…  08:53:58 spec 01a0dce7-01a2 7 lines · 08:55:06 quality 01a0dce7-017e 6 lines — one write each
```

Pass 1's overwritten spec write carried three MAJOR findings — the §A decline gloss, the unsplit
next-state rows, the endpoint-only fix-set check — and the spec session's final seven-line file
carries all three as its first three lines, so no finding was lost; every final file is its own
branch's. Passes 1–3 each count toward the floor. Pass 4 runs the two branches as two sequential
calls with identical full base and head ids, each told its one slot.

### Re-run before Gate-B pass 4

Before Gate-B pass 4: close-cited-set corrected (every governing-header commit in the window, demonstrated on A -> B -> A), K defined without eligibility and the source block, Oracle cells added to rows 33 and 33b, provenance and deviation recorded. Re-run: 320 fragment observations, 0 failures; untouched spans and cond rows, 0 failures; parity, the same three classified differences.

### Re-run before Gate-B pass 5

Released by Daniel on 2026-09-26: the `--soft` repair, the observation-labelled checks, the design §7
note, one pass 5.

```
pair §F item 5 `--soft` — OLD `reset to the parent of the first and commit once instead`: 1 at 8e620db, 0 now, C and W;
  NEW `` `git reset --soft <parent-of-first-WIP>`, then commit once instead ``: 1 now, 0 at the base, C and W
parity of the Finishing-the-cycle block: no difference
```

The OLD half is counted against the previous candidate, not the base: the base carried a different
wording (`` `git reset --soft <parent-of-first-WIP>` first, then commit once ``) and never this one.
Reset behaviour observed in a disposable repository: two WIP commits, the second adding a new file;
`git reset <base>` leaves 0 paths staged and the commit fails; `git reset --soft <base>` keeps both
staged and one commit has parent = base and tree = the last WIP tree. Re-run of the whole record
set: 320 fragment observations, 0 failures; untouched spans and `cond` rows, 0 failures; parity,
the same three classified differences.
