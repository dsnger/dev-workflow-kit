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

**Three ways a fragment fails:** it wraps across a line break, so `grep -F` counts zero in a correct file; it is **preserved inside its own replacement**, so its old-wording-gone count can never reach zero; or it is not unique, so a count of 1 proves nothing about which occurrence changed.

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

**The fourteen §F prompt-copy items (Task 8), derived from each item's cited lines and checked the same three ways.** Pass 2 found these deferred to the executor as `<item OLD>` placeholders, which put fourteen meaning-changing checks outside Gate A's reach; they are concrete now. The NEW halves stay deferred, for the reason the paragraph below gives.

| Row | §F item | OLD fragment | C |
|---|---|---|---|
| F1 | 1, the `WIP:` naming warning | `nor resets your pass counters. A pre-review snapshot named anything else reads as a` | 825 |
| F2 | 2, the Gate-B coverage instruction | `` `NO FINDINGS` if clean" in `additionalContext`, with the same one-line format. `` | 598 |
| F3 | 3, the curve's Majors rationale | `**Majors are recorded as well as Findings and Blockers**, because the severity rule moves the` | 938 |
| F4 | 4, the human-exception scope sentence | `neither a human's assent nor this record` | 1015 |
| F5 | 5, the `Finishing the cycle` lead-in | `**Finishing the cycle:** after the final clean pass, close it with` | 827 |
| F6 | 6, the Gate-A broad-prompt instruction | `reviews the TEXT you pass, not the git tree). Use ONE broad prompt, re-run it` | 553 |
| F7 | 7, the human-exception destination | `**Which commit:** an ungated change records it in that commit; a Gate-A cycle in the spec or` | 988 |
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

**The table is the only authored copy of every fragment, and no task step below quotes one** — each names a row id. Pass 3 found the three rows pass 2 had repaired still wrong, because the steps repeated the fragments inline and only the table had been fixed; a plan stating a fragment twice has the second-copy defect it was written to avoid.

**Task 0 transcribes the rows into `.context/loop-rule-verify.sh` by hand, and a round-trip check validates the transcription against the real files.** An earlier revision generated that file by `awk`-parsing this table out of the plan. Pass 4 found the parser broken three ways at once — it also matched Task 7's NEW-source table and overwrote nine `_OLD` variables; its "skip the sentinel row" test dropped every fragment beginning with `**`; and its id grammar could not express the rows Tasks 3, 4 and 6 add. **A markdown parser is the wrong instrument for thirty-two lines**, and its failure mode is the dangerous one: a silently empty variable makes `grep -cF ""` match every line and every pair report a passing-looking count against nothing.

The transcription is safe because **nothing trusts it**. The check below counts each variable against the real files and rejects any that does not land exactly where its row says:

```bash
# .context/loop-rule-verify.sh — written by hand from the table, one line per row
BASE=$(cat .context/loop-rule-base)
test -n "$BASE" || { echo "BASE empty — Task 0 did not run"; exit 1; }
P2_OLD='scope the approved story or plan assigns to this cycle, plus repair obligations you already'
# … one line per row of the table above, P3 … P18 and F1 … F14 …
pair() {  # pair <OLD> <NEW> <file>
  test -n "$1" || { echo "pair: empty OLD — a variable is unset or mistyped"; return 1; }
  test -n "$2" || { echo "pair: empty NEW"; return 1; }
  printf '%s  old/worktree=%s old/parent=%s new/worktree=%s new/parent=%s\n' "$3" \
    "$(grep -cF "$1" "$3")" "$(git show "$BASE:$3" | grep -cF "$1")" \
    "$(grep -cF "$2" "$3")" "$(git show "$BASE:$3" | grep -cF "$2")"
}
```

**The two empty-string guards are the whole safety of the transcription.** Without them an unset variable counts every line in the file and reads as a healthy result.

- [ ] **Validate the transcription before any task uses it**

```bash
. .context/loop-rule-verify.sh
for id in P2 P3 P4 P5 P5w P6 P7 P8 P9 P10 P11 P12 P13 P14 P15 P16 P17 P18 \
          F1 F2 F3 F4 F5 F6 F7 F8 F9 F10 F11 F12 F13 F14; do
  eval "v=\$${id}_OLD"
  test -n "$v" || { echo "$id UNSET"; continue; }
  printf '%-4s C=%s W=%s\n' "$id" \
    "$(grep -cF "$v" CLAUDE.md)" \
    "$(grep -cF "$v" plugins/dev-workflow/commands/workflow-init.md)"
done
```

Expected: `C=1 W=1` for every row except **P5** (`C=1 W=0`) and **P5w** (`C=0 W=1`), the per-copy `e7` rows. **No `UNSET`, and no `0` where the row claims a hit.** A mismatch means the transcription is wrong — fix the file, not the table.

**Rows Tasks 3, 4 and 6 add go into both places**: a row in this table, and a line in the helper, before the pair that uses them. **Re-run the validation loop after adding any row** — the helper is written once and never regenerates itself.

**Every OLD row was checked three ways** — single-line in each copy it claims, unique there, and **absent from the target's fenced blocks compared with line breaks normalized**. The normalization matters: pass 4 found `F4`'s fragment preserved in its own replacement and invisible to a naive substring test, because the block wraps between `you` and `still`. Re-running the normalized check over all thirty-two rows found exactly that one and nothing else.

**Three ways a fragment fails:** it wraps across a line break, so `grep -F` counts zero in a correct file; it is preserved inside its own replacement, so its old-count can never reach zero; or it is not unique. **Each of the first three passes found rows failing a different one of the three.**

**The four-value rule, stated once:** a pair passes only on `old/worktree=0 old/parent=1 new/worktree=1 new/parent=0`. All four matter — a copy carrying the new wording **and** the old one satisfies a one-sided presence check, which is the two-instructions-that-disagree failure the pair exists to catch.

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

### Passage (a) — the floor paragraphs → target §H (Task 7)

| Condition | Disposition |
|---|---|
| a1, a3–a12, a14 | **kept**, untouched. The floor arithmetic, the hook-ratio rules and the two comparison points are outside this change. |
| a2 | **replaced.** §F item 8a rewrites the HARD FLOOR parenthetical `(Blocker/Major only)` — Task 8, row F10. The filter itself survives in the ordering, which states what a pass counting toward the floor must be; what goes is the parenthetical's claim that Blocker/Major is the *whole* of it. **Marked replaced rather than kept**, because a condition whose text the change in fact rewrites, recorded as preserved, is the dropped-condition failure `AGENTS.md` names. |
| a13 | **replaced** — scoped to its own paragraph. §H's `a13` block. |
| a15 | **carried** inside §H's `a16` block, which reproduces it so one contiguous string installs. |
| a16 | **replaced** — points at Mechanics · Severity instead of carrying an unscoped copy. §H's `a16` block. |
| a17, a18, a19 | **moved** — the floor paragraph stops stating the clean-final-pass rule and the early exit; both are stated once in §A. §H's `a17`–`a22` block. |
| a20 | **moved** to §A unchanged, beside the zero-finding rule it qualifies. |
| a21, a22 | **carried** unchanged, reproduced in §H's block for the same contiguity reason as a15. |

### Passage (b) — what a loop absorbs → target §B (Task 3)

§B states its own accounting and this table reproduces it: **Changed:** `b3`, `b7`, `b8`, `b11`, `b12`, `b13`, `b16`, `b17`, `b18`. **Added:** the closing-time change rule and decision 6's decline semantics, which no inventoried condition carried because none existed. **Carried:** `b1`, `b2`, `b4`, `b5`, `b6`, `b9`, `b10`, `b14`, `b15`.

**Verify against the file, not against this table:** §B is written out whole and is the only place this change states passage (b). Read the installed passage and confirm each carried condition is present and each changed one is gone.

### Passage (c) — recognizing clearly stuck → target §C (Task 4) and §H (Task 7)

| Condition | Disposition |
|---|---|
| c1, c2, c3 | **kept** — the curve-reading sentences are untouched. |
| c4 | **replaced** — "a missing one means keep going" becomes "means only that *this* exit does not apply", the pass's actual next step being the ordering's. |
| c5, c6, c7 | **carried word for word** inside §C's block. |
| c8 | **changed** — gains the re-raised-dismissal clause. |
| c9 | **split.** The operative precedence clause moves into §A capitalized as a standalone sentence; the plateau rationale stays at this source. Not moved whole — §C says so explicitly. |
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
| e7 | **changed** — gains the read-after-clean-completion clause. The sentence is given entire in §D. |
| e8, e9, e10 | **carried** inside §D's block. |
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
| h1–h3, h6, h8–h18, h20–h26 | **kept**, untouched. |
| h5 | **replaced** — §F item 7 changes the Gate-B destination from "restated by the closing amend" to "restated by the commit its closing act produces", the amend no longer being the only closing shape. Row F7. |
| h4 | **replaced** — §F item 7, the human-exception destination: a Gate-A cycle's record goes to the commit its closing act produces, not to "the spec or plan commit". |
| h7 | **kept.** |
| h19 | **replaced** — §F item 4, the scope sentence: "neither a human's **general** assent nor this record", plus the clause distinguishing the answers a suspension asks for from assent. |
| h13 | **kept.** Design §4 names this sentence as deliberately not edited: this change ships no record for the squash carry to carry. |

### Passage (i) — when these rules bind → target §H (Task 7)

`i1`, `i2`, `i3`, `i9`–`i11`, `i13`–`i16`: **kept**, untouched.
`i4`–`i8`: **kept**, and the dash-delimited list they sit in is **extended, not rewritten** — §H gives the whole list with the additions at the end.
`i12`: **discharged, and kept.** It is the extension point that licenses the addition; it stays because the next change needs it too.

### Passage (j) — the squash carry (Task 0 check only)

`j1`–`j4`: **all kept, untouched.** It was to name the answer record, which moved to the successor; this change ships no record for it (design §5). **A diff touching C 892 or W 1076 is a defect.**

---

## Task 0: Establish the baseline and the do-not-touch set

**Files:** none modified.

**Interfaces:**
- Produces: `$BASE` (the parent commit every later task's counterfactual half runs against), and a recorded list of the five untouched passage ranges.

- [ ] **Step 1: Confirm the approved artifacts and a clean tree**

```bash
git log --oneline -1        # expect 6ace06f or later on loop-rule-consolidation
git status --porcelain      # expect empty
if [ -s .context/loop-rule-base ]; then
  echo "base already recorded: $(cat .context/loop-rule-base) — NOT overwriting"
else
  git rev-parse HEAD > .context/loop-rule-base
fi
cat .context/loop-rule-base
```

**Never overwrite an existing base.** Re-running Task 0 after a partial implementation would record
the current WIP tip, and both Gate B's range and the final `reset --soft` would then start after
every edit made so far — prompt and hook changes would be squashed into the closing commit without
ever entering a review range. **If the recorded base is wrong, delete the file deliberately and say
why**; do not let a re-run decide it.

**Persist it to a file, not to a shell variable.** Each task runs in its own shell invocation, so a
`BASE=` assignment in Task 0 is gone by Task 1 and every parent-tree count would run against an
empty revision — which fails loudly in `git show` but quietly in a `grep -c` pipeline. Every later
task begins with:

```bash
. .context/loop-rule-verify.sh
```

**Task 0 also writes `.context/loop-rule-verify.sh`**, whose generator is given in the fragment-table
section. It sets `$BASE` and defines `pair()`, so both arrive together and neither can be used
without the other.

**This commit is also `baseSha` for Gate B.** It is the parent of the first WIP snapshot, and it is
the only value that puts the whole implementation inside the reviewed range. `.context/` is ignored
by the hook's fingerprint, so the file itself moves nothing.

- [ ] **Step 2: Re-read the five untouched ranges and record their current line numbers**

Passages (d), (f) and (j) are not edited by this change, and passage (a)'s arithmetic and passage (h)'s **twenty-four** kept conditions are untouched — twenty-six inventoried, less `h4` and `h19`, which Task 8 replaces. Record where they are now, because the inventory's numbers cite `7c0d475`:

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
  grep -n 'Both gates are a LOOP with a HARD FLOOR' "$f"                     # (a) arithmetic start
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

- **The floor arithmetic is three spans**, because `a2` sits at its head and `a13` in its middle:
  from `Both gates are a LOOP with a HARD FLOOR` to the line before row F10's fragment; from the
  line after F10's to the line before row P9's; and from the line after P9's to `Nothing here writes
  the floor knob`. **The middle span is the one the first draft dropped**, and it holds `a3`–`a12`.
- **The human exception is three spans**, around rows F7 (`h4`) and F4 (`h19`): from `Recording a
  human exception` to before F7's line; between F7's and F4's; and from after F4's to `because
  writing it down makes it sound`. All twenty-four kept conditions lie inside them.

**Record the spans as one `start<TAB>end<TAB>file` line each in `.context/loop-rule-untouched`**, the
anchors being literal strings. Tab-separated because the anchors contain colons — the first draft
used `:` as the delimiter, and `**Severity:**:**Tool routing:` splits at the wrong colon and yields
an empty end anchor.

- [ ] **Step 3: Confirm the parity baseline of the inventoried ranges**

**Diff every inventoried and changed site, not one early window, and read the whole output.**
The first draft compared C 65–290 with W 264–489 and piped it through `head -40`. That window holds
none of passages (g), (h) or (j) — so `g4`, which sits at C 815 / W 997, could not appear in a diff
whose expected list named it — and the truncation hid about fifty of the roughly ninety lines the
comparison actually emits.

```bash
# Tab-separated start and end anchors: the anchors contain colons, so a
# colon delimiter splits '**Severity:**' at the wrong place and yields an
# empty end. A single-line site is given the same anchor twice and sed
# returns that one line.
printf '%b\n' \
 'Both gates are a LOOP\tNothing here writes the floor knob' \
 'What a loop absorbs\tRecognizing "clearly stuck"' \
 'Recognizing "clearly stuck"\tEvery pass report states' \
 'From pass 4 onward\tThose three lines expose' \
 'Those three lines expose\tThe two rules above' \
 'The two rules above\tFindings go to a FILE' \
 '\*\*Severity:\*\*\t\*\*Tool routing:' \
 'Recording a human exception\tbecause writing it down makes it sound' \
 'On squash-merge\tOn squash-merge' \
 'When these rules bind\tDownstream has no shipping commit' \
 > .context/loop-rule-sites
while IFS=$(printf '\t') read -r s e; do
  echo "== $s"
  diff <(sed -n "/$s/,/$e/p" CLAUDE.md) \
       <(sed -n "/$s/,/$e/p" plugins/dev-workflow/commands/workflow-init.md)
done < .context/loop-rule-sites | tee .context/loop-rule-baseline-diff.txt
```

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

```bash
. .context/loop-rule-verify.sh
for f in CLAUDE.md plugins/dev-workflow/commands/workflow-init.md; do
  for frag in 'How a cycle ends — one ordering' \
              '<a single-line fragment unique to §A2, taken from the installed file>' \
              '<a single-line fragment unique to §A3, taken from the installed file>'; do
    printf '%s | worktree=%s parent=%s | %s\n' "$f" \
      "$(grep -cF "$frag" "$f")" "$(git show "$BASE:$f" | grep -cF "$frag")" "$frag"
  done
done
```

Expected: `worktree=1 parent=0` for all six. **Add the two §A2/§A3 fragments to the fragment table
once chosen**, with the check that verified each is single-line and unique — they are the two rows
that cannot be pre-verified because the text does not exist until this task installs it.

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

**The plan is staged here because this task adds the §A2 and §A3 rows to the fragment table.** Every
task that adds a row stages the plan with its own edit; otherwise the reviewed fragment evidence
stays dirty and is swept into a later, unrelated commit, and the task commits are not the
independently reviewable units this plan claims they are. The same applies to Tasks 3, 4, 6, 7 and
8, each of which derives rows.

Named `WIP:` because Task 15 runs Gate B over the whole change and amends once. A non-`WIP` commit here would reset the hook's Gate-B counters mid-cycle.

---

## Task 2: Verify the untouched passages are still untouched

**Files:** none modified.

**Interfaces:**
- Consumes: Task 0's recorded line numbers and `$BASE`.

This task exists because `f1` and the (d)/(j) dispositions are falsifiable only by a diff, and the cheapest moment to catch an accidental edit is immediately after the insertion that could have caused one.

- [ ] **Step 1: Diff each untouched passage against the parent**

```bash
. .context/loop-rule-verify.sh
# read the five recorded ranges rather than hard-coding three of them
for f in CLAUDE.md plugins/dev-workflow/commands/workflow-init.md; do
  for anchor in 'From pass 4 onward every pass report carries three lines' \
                'The two rules above do not compete' \
                'On squash-merge, copy every evidence entry'; do
    printf '%s | %s: ' "$f" "$anchor"
    diff <(git show "$BASE:$f" | grep -A12 -F "$anchor") <(grep -A12 -F "$anchor" "$f") >/dev/null \
      && echo unchanged || echo CHANGED
  done
done
```

Expected: `unchanged` six times. Any `CHANGED` is a defect — revert that hunk before continuing.

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

```bash
. .context/loop-rule-verify.sh
for f in CLAUDE.md plugins/dev-workflow/commands/workflow-init.md; do
  printf '%s P2=%s P3=%s\n' "$f" "$(grep -cF "$P2_OLD" "$f")" "$(grep -cF "$P3_OLD" "$f")"
done
```

Expected: `P2=1 P3=1` for **both** files — the first draft ran these against C only while claiming a result for both.

**The first draft of this plan named `plus repair obligations you already accepted in earlier
passes` here, which wraps across C 201–202 and W 408–409 and counts zero in a correct file.**

- [ ] **Step 2: Install §B's text over the passage in both copies**

Replace from `**What a loop absorbs, and what stops it` through the sentence §B ends at, keeping each copy's own closing parenthetical.

- [ ] **Step 3: Run two discriminating pairs, both copies, both trees**

`b7` and `b12` are separate meaning changes and each owes its own pair; one pair covering both
would let the surviving instruction pass behind the repaired one.

```bash
. .context/loop-rule-verify.sh
for f in CLAUDE.md plugins/dev-workflow/commands/workflow-init.md; do
  pair "$P2_OLD" 'union of the scope every approved story or plan governing this change assigns to this cycle' "$f"
  pair "$P3_OLD" "$P3_NEW" "$f"
done
```

**`P3_NEW` is the §B resumption sentence's fragment**, chosen after installing, verified the three
ways, and added to the helper before this step runs.

Expected for all four: `old/worktree=0 old/parent=1 new/worktree=1 new/parent=0`.

**Two pairs do not cover §B.** Target §B separately changes `b3`, `b8`, `b11`, `b13`, `b16`,
`b17`–`b18` and **adds** the closing-time set-change rule and decision 6's decline semantics. Each
independent replacement owes its own pair, and each add-only rule owes a presence check — a manual
condition walk is a reader's judgement, not the discriminating observation design §7 assigns here.
**Derive an OLD row for each changed condition and a NEW fragment for each added rule, add them to
the fragment table, and run the checks before Step 4.**

- [ ] **Step 4: Walk the carried conditions**

Read the installed passage and confirm `b1`, `b2`, `b4`, `b5`, `b6`, `b9`, `b10`, `b14`, `b15` are each present, and that `b3`, `b7`, `b8`, `b11`, `b12`, `b13`, `b16`, `b17`, `b18` read as §B states rather than as the parent did. Nine plus nine; the disposition table above is the checklist.

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

```bash
. .context/loop-rule-verify.sh
for f in CLAUDE.md plugins/dev-workflow/commands/workflow-init.md; do
  printf '%s P4=%s\n' "$f" "$(grep -cF "$P4_OLD" "$f")"
done
```

Expected: `P4=1` for both files.

**`So this exit needs three things` is not usable and is not a row:** it occurs once in each copy but
is **preserved in target §C's fenced replacement**, so its old-count could never reach zero. Derive
`c4`'s OLD from the part of the sentence the replacement removes.

- [ ] **Step 2: Install §C's block**

- [ ] **Step 3: Confirm the moved clause exists in §A and nowhere else**

```bash
grep -cF 'clean completion' CLAUDE.md
grep -n 'takes precedence over this exit' CLAUDE.md
```

The precedence clause must appear **once**, inside the ordering. A second occurrence in passage (c) means the sentence was moved whole instead of split.

- [ ] **Step 4: Run the discriminating pair, both copies, both trees**

Row **P4**. `NEW` is the single-line fragment `a recurrence failing them being an ordinary fresh
finding`, from §C's re-raised-dismissal clause — **install that clause's line unwrapped** so the
fragment sits wholly on one line, and confirm it is unique before counting.

**Three pairs, one per edit.** An earlier draft ran a single pair taking its OLD from `c14` and its
NEW from `c8` — two different changes — so either could land while the other survived and it still
reported a pass, and `c4` had no observation at all.

```bash
. .context/loop-rule-verify.sh
for f in CLAUDE.md plugins/dev-workflow/commands/workflow-init.md; do
  pair "$P19_OLD"  '<§C c4 NEW — derive, verify, add as a row>'  "$f"   # c4 replaced
  pair "$P20_OLD"  'a recurrence failing them being an ordinary fresh finding' "$f"   # c8 widened
  pair "$P4_OLD"   '<§C c14 routing NEW — derive, verify, add as a row>' "$f"   # c14 removed
done
```

Expected for all six: `old/worktree=0 old/parent=1 new/worktree=1 new/parent=0`.

**`P19_OLD` and `P20_OLD` do not exist yet.** Derive each from the live passage, check it the three
ways, **add a row to the fragment table and a line to `.context/loop-rule-verify.sh`**, then re-run
the validation loop. Ids continue the `P` series; a row id is whatever the table and the helper agree
on, so keep them plain.

- [ ] **Step 5: Walk the conditions** — `c1`–`c3` present unchanged, `c5`–`c7` word for word, `c8` carrying the new clause, `c9` split, `c10`–`c14` gone from here.

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

```bash
. .context/loop-rule-verify.sh
printf 'P5  C=%s\n' "$(grep -cF "$P5_OLD"  CLAUDE.md)"
printf 'P5w W=%s\n' "$(grep -cF "$P5w_OLD" plugins/dev-workflow/commands/workflow-init.md)"
```

Expected: `1` each.

**Two earlier drafts got this row wrong in two different ways**, which is why the step names ids and
not text. The first fragment wrapped across C 267–268 and W 471–472; the second was **preserved in
target §D's replacement** and could never reach zero. `P5_OLD` and `P5w_OLD` take the clause §D
actually removes.

- [ ] **Step 2: Install §D's `e7` sentence and the pointer paragraph**

- [ ] **Step 3: Run the discriminating pair, and a presence check for the pointer**

The `e7` replacement and §D's added pointer paragraph are two separate observations. **The pointer
is add-only** — it replaces no wording — so it is checked by presence alone, and without that check
it can be omitted from both copies while the `e7` pair, the condition walk and the parity diff all
pass.

```bash
. .context/loop-rule-verify.sh
NEW='read **after** the clean-completion branch of the closure ordering'
PTR='where this stop'"'"'s place among the suspensions'
pair "$P5_OLD"  "$NEW" CLAUDE.md
pair "$P5w_OLD" "$NEW" plugins/dev-workflow/commands/workflow-init.md
for f in CLAUDE.md plugins/dev-workflow/commands/workflow-init.md; do
  printf 'pointer %s worktree=%s parent=%s\n' "$f" \
    "$(grep -cF "$PTR" "$f")" "$(git show "$BASE:$f" | grep -cF "$PTR")"
done
```

Expected: both pairs `old/worktree=0 old/parent=1 new/worktree=1 new/parent=0`; both pointer checks
`worktree=1 parent=0`.

- [ ] **Step 4: Confirm `e1`–`e6` and `e9`–`e11` are untouched**, that `e11` is still C-only, and
that **`e8` is aligned rather than untouched** — this task gives W the pronoun, so listing `e8`
among the untouched conditions would contradict the task's own instruction.

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

§E replaces **two** blocks. The handed-over-question OLD is row P6; the resolve-duty bullet has no
row yet. Derive one from the live `**Severity:**` bullet, check it the three ways, and add it to the
fragment table before Step 3.

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

```bash
. .context/loop-rule-verify.sh
for f in CLAUDE.md plugins/dev-workflow/commands/workflow-init.md; do
  pair "$P6_OLD"  'The demotion changes what a cycle must resolve, never what it observes' "$f"
  pair "$P6r_OLD" 'for every finding in the assigned fix set as the absorb paragraph computes it' "$f"
done
```

**`P6r_OLD` is the resolve-duty row step 1 derives.** Add it to the table **and** to
`.context/loop-rule-verify.sh`, then re-run the validation loop before this step.

Expected for all four: `old/worktree=0 old/parent=1 new/worktree=1 new/parent=0`.

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

```bash
. .context/loop-rule-verify.sh
for f in CLAUDE.md plugins/dev-workflow/commands/workflow-init.md; do
  echo "== $f"
  for id in P7 P8 P9 P10 P11 P12 P13 P14 P15 P16; do
    eval "o=\$${id}_OLD"
    printf '%-4s %s\n' "$id" "$(grep -cF "$o" "$f")"
  done
done
```

Expected: `1` twenty times. **Any `0` means the wording drifted since this table was verified at
`5871d0a`** — re-derive that fragment and update the table before installing anything.

- [ ] **Step 2: Install the §G block and all nine §H blocks — ten sites — one at a time, verifying each before moving to the next**

- [ ] **Step 3: Run one discriminating pair per block**, both copies, both trees, one per row P7–P16.

`NEW` for each is taken from the installed block; **check each chosen fragment is single-line and
unique in the installed file before counting it**, and add it to the fragment table. The suggested
source sentence per block:

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

```bash
. .context/loop-rule-verify.sh
for f in CLAUDE.md plugins/dev-workflow/commands/workflow-init.md; do
  for id in P7 P8 P9 P10 P11 P12 P13 P14 P15 P16; do
    eval "o=\$${id}_OLD"; eval "n=\$${id}_NEW"
    pair "$o" "$n" "$f"
  done
done
```

**`<ID>_NEW` is set by the executor after installing that block and verifying the chosen fragment
the same three ways** — append the assignment to `.context/loop-rule-verify.sh` and re-run the
validation loop before the pairs.

Expected for all twenty: `old/worktree=0 old/parent=1 new/worktree=1 new/parent=0`.

**One pair per block is a sample, not coverage, and two blocks need more.** The `c18`-and-surfacing
block changes `c16`, `c17`, `c19` and `c20` besides the `c18` clause row P8 observes; the
strict-reading list adds several items where P16 observes the first. **Derive one OLD row per
independent meaning change in those two blocks**, add each to the table and the helper, and run a
pair for each — the other eight blocks change one thing each and one pair covers them.

**Two classification notes, decided against the real files rather than asserted.** The
strict-reading list **replaces the dash-delimited run** even though its addition is at the tail, so
it owes a full pair. The gate-prompt template's clean sentence **replaces** `A clean pass is the
single body line …`, which is why P13 has an OLD at all; it is not add-only.

- [ ] **Step 4: Confirm `a21`, `a22`, `a15` survived** — they are carried inside blocks that install contiguously, so a mis-scoped replacement silently drops them.

```bash
grep -cF 'Codex is advisory — validate before applying; dismissed finding → one-line why' CLAUDE.md
grep -cF 'Open a TodoWrite' CLAUDE.md
```

Expected: `1` each.

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

**`h4` and `h19` are the human-exception conditions these items discharge** — item 7 is the destination, item 4 the scope sentence.

- [ ] **Step 1: Re-derive every item's real location**

For each item, take the quoted live sentence from §F and find it, rather than trusting the cited line:

```bash
grep -n -F '<the live sentence §F quotes>' CLAUDE.md plugins/dev-workflow/commands/workflow-init.md
```

**Where a quoted sentence wraps across lines in the file, `grep -F` on the whole sentence returns nothing.** Search a single-line fragment of it instead and confirm by reading. Record which items wrap — Task 14's parity diff needs it.

- [ ] **Step 2: Install all fourteen replacements**

- [ ] **Step 3: Build this task's fourteen fragment rows, then run fourteen pairs**

**Do not choose fragments at run time.** Step 1 located each item's live sentence; for each, pick a
single-line OLD fragment from the located line, run it through the fragment check, and **append the
row to the plan's fragment table with the line numbers the check reported**. Only then run the
pairs. A fragment chosen and used in the same breath is how the first draft shipped five that count
zero.

For each item, the OLD fragment must satisfy all three: single-line in both copies (or one fragment
per copy where the wrapping differs, as `e7` needed); unique in each; and **not preserved inside its
own replacement** — compare it against the §F block before accepting it.

```bash
. .context/loop-rule-verify.sh
for f in CLAUDE.md plugins/dev-workflow/commands/workflow-init.md; do
  for id in F1 F2 F3 F4 F5 F6 F7 F8 F9 F10 F11 F12 F13 F14; do
    eval "o=\$${id}_OLD"; eval "n=\$${id}_NEW"
    pair "$o" "$n" "$f"
  done
done
```

Expected for all twenty-eight: `old/worktree=0 old/parent=1 new/worktree=1 new/parent=0`.

- [ ] **Step 4: Count what was installed**

```bash
# Each of step 3's fourteen pairs printed new/worktree; total them per copy.
. .context/loop-rule-verify.sh
for f in CLAUDE.md plugins/dev-workflow/commands/workflow-init.md; do
  n=0
  for new in '<F1 NEW>' '<F2 NEW>' '<F3 NEW>' '<F4 NEW>' '<F5 NEW>' '<F6 NEW>' '<F7 NEW>' \
             '<F8 NEW>' '<F9 NEW>' '<F10 NEW>' '<F11 NEW>' '<F12 NEW>' '<F13 NEW>' '<F14 NEW>'; do
    n=$(( n + $(grep -cF "$new" "$f") ))
  done
  echo "$f installed=$n"
done
```

Expected: `installed=14` per copy. State the number you observed. **Do not carry a count from §F into a check** — §F states the count of falsified sentences and this task installs a subset of them; a count copied between the two is the stale-bookkeeping defect the design records at five passes running.

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

```bash
. .context/loop-rule-verify.sh
for f in CLAUDE.md plugins/dev-workflow/commands/workflow-init.md; do
  pair "$P17_OLD" 'not a blanket exemption for hook text' "$f"
  pair "$P18_OLD" 'Gate A (spec) → Gate-A closing act'    "$f"
done
```

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

The hook has one copy and owes no parity check; **the hook suite's exact-match assertion is this edit's second observation** (design §7). Run the pair anyway:

```bash
. .context/loop-rule-verify.sh
H=plugins/dev-workflow/hooks/codex-gate.sh
# Tab-separated OLD<TAB>NEW: the fragments contain no tab, and | appears
# inside shell text. Six entries, all in the loop — an earlier draft left
# two of them as bare quoted strings after it, which a shell tries to run.
printf '%b\n' \
 'this floor is the only thing keeping the spec review honest\tinstruction-backed' \
 'floor met by COUNT ONLY\tProceed only once this Gate-A cycle has closed' \
 'commit only if your final pass was clean — no new Blocker/Major\tevery other closure condition holds' \
 'then make the real commit when your final pass is clean\tUse this commit as the review range' \
 'or proceed only if $policy\tskip rule decides only whether a cycle runs at all' \
 'STOP — Codex Gate B not satisfied\tCodex gate state:' \
 > .context/loop-rule-hookpairs
while IFS=$(printf '\t') read -r OLD NEW; do
  pair "$OLD" "$NEW" "$H"
done < .context/loop-rule-hookpairs
```

**Exact counts per pair, not a floor.** Five of these replace one message each and must read
exactly `old/parent=1 new/worktree=1`; only the grouped `STOP` pair, which covers items 15 and 16,
reads `2`. Weakening all six to `≥ 1` because one of them is 2 lets a duplicated installation or a
non-unique fragment pass for the five that should be exact:

| Pair | old/worktree | old/parent | new/worktree | new/parent |
|---|---|---|---|---|
| item 10, the honesty claim | 0 | 1 | 1 | 0 |
| item 11, the Gate-A clean definition | 0 | 1 | 1 | 0 |
| item 12, the Gate-B clean definition | 0 | 1 | 1 | 0 |
| item 13, the WIP reminder | 0 | 1 | 1 | 0 |
| item 17, the below-floor instruction | 0 | 1 | 1 | 0 |
| items 15+16, the two `STOP` openings | 0 | **2** | **2** | 0 |

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
grep -n 'Gate B satisfied\|Gate B not satisfied\|STOP\|no recorded review\|cannot confirm review\|only thing keeping\|no new Blocker/Major' plugins/dev-workflow/hooks/codex-gate.test.sh
```

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
grep -c 'Gate B satisfied\|Gate B not satisfied' plugins/dev-workflow/hooks/codex-gate.test.sh
```

Expected: **`0`. Not "no hits you cannot justify"** — step 3 requires every label and comment to move
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

- [ ] **Step 5: Record the result** — it goes in the evidence entry verbatim. **No commit** unless the check failed and you repaired something.

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
Mechanics. **Record each section as read in `.context/loop-rule-sweep.md`**, with a line saying what
you were looking for and what you found.

- [ ] **Step 3: Read both channels of all eight hook gate reminders**

Seven are replaced by §F. **The eighth, the docs-only notice, is read too** — it is excluded because
it states no closure permission, and that exclusion is a claim this sweep is the place to confirm.

- [ ] **Step 4: Classify anything found**

A site the ordering falsifies that §F does not replace is **a finding against the approved spec, not
a gap in this plan**. Surface it: the spec's §F is the only enumeration of these sentences, and
adding one here would be the second copy that cycle spent sixty-five passes removing. **Where the
find is real, the spec's Gate-A cycle reopens for it.**

- [ ] **Step 5: Record the result either way**

`.context/loop-rule-sweep.md` states what was read and what was found, **including "nothing"**. A
sweep whose negative result is unrecorded cannot be told from a sweep that never ran.

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

One row per (starting state, answer) pair the installed ordering admits. At minimum, and **this is a floor rather than the set**: a clean eligible pass with every condition met; a clean eligible pass with an unmet precondition; a clean pass below the floor; a zero-finding pass below the floor; a pass carrying a membership trigger, answered accept and answered decline; a pass carrying a new-question trigger, answered; a pass carrying both; a two-tell stop, answered; a clearly-stuck surface, answered; a source block raised before any pass was read; a source block raised on a pass already read; a closing act that does not complete and is repaired; a closing act that cannot be repaired; a `full` Gate-B pass with one branch clean and one not; the same complaint in both branch files under each of accept/accept, accept/decline, decline/accept and decline/decline.

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

**Drive the list from the artifact:** every section the target text marks NEW or REPLACED, and every
item in §F whose destination is a prompt copy. For each, extract a **bounded** region — from its
first line to the first line of the next passage, not a fixed count — and diff the two copies:

```bash
# .context/loop-rule-changed-sites is written by this step: one
# start<TAB>end line per section the target marks NEW or REPLACED and per
# §F item whose destination is a prompt copy. Build it by reading those
# markers off the target text, then:
while IFS=$(printf '\t') read -r s e; do
  echo "== $s"
  diff <(sed -n "/$s/,/$e/p" CLAUDE.md) \
       <(sed -n "/$s/,/$e/p" plugins/dev-workflow/commands/workflow-init.md)
done < .context/loop-rule-changed-sites
```

**The list is a step output, not an assumed input.** An earlier draft gave one generic command with
undefined `$start` and `$end` and no step producing them, so the task could record a divergence list
without having diffed anything.

**Fail this step where a site named by §§A–H has no region in your list** — that is the same
completeness failure as Task 13's per-condition checks, and it is caught the same way: by reading
the set off the artifact rather than from a list kept here.

**Where it goes:** this plan, under the heading `## Divergence list (Task 14 output)` at the end of
the document, replaced idempotently on re-run by the same rule Task 13 uses.

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

```bash
BASE=$(cat .context/loop-rule-base)
while IFS=$(printf '\t') read -r s e f; do
  echo "== $f :: $s"
  diff <(git show "$BASE:$f" | sed -n "/$s/,/$e/p") <(sed -n "/$s/,/$e/p" "$f")
done < .context/loop-rule-untouched
```

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
claude plugin validate . --strict
```

Expected: exit 0.

- [ ] **Step 4b: Apply all twelve `docs/prompt-standards.md` items to the installed text**

**Nothing mechanical does this and no other task claims it.** The battery's three narrow checks are
a floor — one `Target model:` spelling, one prose count claim, one severity vocabulary — and
invariant 11 requires all twelve items of every skill, command, hook message and scaffolded template
this change touches. **Read the installed §A–§H text in C, in W, and the seven hook strings, against
each of the twelve items, and record the result per item in this plan.** Items 6 (every constraint
carries its reason in the same sentence) and 8 (token-lean) are the ones design §8 names as most at
risk.

**A reader check, deliberately** — no pattern decides whether a constraint carries its reason.

**`check-invariants.sh` includes the prompt-conformance checks** — a `Target model:` line naming one recognized model, a prose checklist-count claim matching the checklist, and the finding-severity vocabulary as a closed set in both prompt copies. Those three are a floor, not coverage; invariant 11's other eleven items are judged by a reader.

- [ ] **Step 5: Write the evidence entry into `.context/loop-rule-closing-msg`**

**Not into a WIP commit body.** Step 8 squashes with `git reset --soft`, which keeps the tree and
discards every WIP message; evidence written only there would be destroyed by the close. Restate it
in the WIP body too if a mid-cycle reader would want it, but the file is the copy that survives.

**The file is completed after step 7, not here.** The evidence entry can be drafted now, but the
**per-pass curve is not known until the Gate-B loop ends**, and the **provenance line** and any
**human-exception record** belong beside it. Step 7's last action is to append all three — this step
opens the file, step 7 closes it, and step 8 commits it.

It names: the battery run; **every pair this plan built, with its counts in each copy and each tree, and every presence check beside them**; the §6 parity diff and the `b11`/`b13` equivalence result; and the next-state table's location plus its row count. **State the §A presence checks as presence, not as pairs** — its counterfactual is absent and is claimed as absent.

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

- [ ] **Step 7: Loop to a clean pass at or above the derived floor**

Floor derives from the story profile: risk `high` → 2, security `none` → 0, max 2 ≠ 0 → **floor 3**. Re-derive it at each pass from the header.

**Each fix is committed before the next review is issued**, or the re-review targets the unchanged
WIP tip while the repair sits in the worktree — and the final squash then publishes a fix no pass
reviewed:

```bash
git add -A && git commit -m "WIP: fix <finding>"
git rev-parse HEAD          # resolve headSha fresh for the next call
```

Re-review after every fix. **Revalidate the evidence entry before every re-review and before the
closing commit.**

**A fix that changes specified behaviour updates the spec in the same commit.**

- [ ] **Step 8: Close the cycle**

**Build the closing message in a file first.** `git reset --soft` discards every WIP commit *body*,
so an evidence entry written only into a WIP message is destroyed at exactly the moment the cycle
closes — which is what step 5 would otherwise have done.

```bash
. .context/loop-rule-verify.sh
# Everything that must be IN the squashed commit has to be committed before the
# reset: reset --soft stages only what the discarded commits already contained.
git add docs/superpowers/plans/2026-09-14-loop-rule-consolidation.md \
        .context/codex-reviews/
git status --porcelain    # expect empty after this
git commit -m "WIP: plan records and Gate-B findings files" || true
# .context/loop-rule-closing-msg holds the revalidated evidence entry, the provenance
# line, the per-pass curve and any human-exception record, completed at step 7.
git reset --soft "$BASE"
git commit -F .context/loop-rule-closing-msg
```

**`reset --soft` stages committed content only.** The prompt-standards result (step 4b), the
completeness sweep, the next-state table and the divergence list all land in this plan, and
`.context/codex-reviews/` is tracked; **anything still uncommitted when the reset runs is left in the
worktree and is not in the closing commit** — and, for the plan records, was never in a Gate-B range
either. Commit them first, then reset.

**`$BASE` is the recorded revision, not a placeholder to substitute by hand** — Task 0 persisted it
for this, and a mistaken substitution squashes the wrong range.

The closing body carries: the validated evidence entry; the provenance line; the per-pass curve; and any human-exception record. **One commit rather than a follow-up** — a `WIP:` commit left in history defeats the convention, and a follow-up has nothing to commit when the review produced no fixes.

---

## Self-Review

**1. Spec coverage.** §A → Task 1. §B → Task 3. §C → Task 4. §D → Task 5. §E → Task 6. §F items 1–9 → Task 8; items 14, 18 → Task 9; items 10–13, 15–17 → Task 10 with its test sweep in Task 11. §G → Task 7, **added by this review**: the first draft gave the one-contract paragraph no task, though design §4 lists it as its own site and target §G carries its replacement. It is a prompt-copy replacement in both copies with the same shape as §H's blocks, owes the same discriminating pair with row **P7**'s OLD `These records are one contract` — the live wording; `These rules and records are one contract` occurs nowhere — at C 879 / W 1063 as of this writing. §H → Task 7. §I ships nowhere and needs no task. Design §6 → Task 14. Design §7 → Tasks 13 and 15. Design §8 → Task 15's battery and the Global Constraints. Story AC 5 → the disposition tables. Story AC 4 → Task 13.

**2. Placeholder scan.** The replacement text is cited rather than copied, deliberately and for the reason the Architecture note gives. Task 13's row list is explicitly a floor rather than a closed set, and says so. Task 11 deliberately carries no count, and says why.

**Which steps are mechanical and which are reader checks, stated rather than claimed uniformly.** Every OLD half of every pair is a concrete fragment with a runnable command and an exact expected result. **The NEW halves are `<...>` until their task installs the text**, which the fragment table discloses and each step requires to be verified before counting. **Tasks 12, 13 and 14 step 2 are reader checks by design** — a predicate comparison, a next-state walk and a divergence classification are judgements, and giving them commands would be the false-precision this repo's invariants warn about. An earlier revision of this section claimed every verification step had a runnable command, which was not true of them.

**3. Type consistency.** `$BASE` is set in Task 0 and used in Tasks 1–10. The four-value pair shape (`new/worktree`, `new/parent`, `old/worktree`, `old/parent`) is defined in Task 3 and referred to by name afterwards. Condition ids match the inventory throughout: a1–a22, b1–b18, c1–c20, d1–d7, e1–e11, f1–f7, g1–g4, h1–h26, i1–i16, j1–j4 — 135 total, every one dispositioned above.

**One correction applied from this review:** §G was missing a task; it is now installed by Task 7, which names **ten** sites — one §G block and nine §H blocks.

**One residual this plan does not close, stated rather than left to be found.** Nothing here establishes that the edit set is complete — it is the sites §F knows, and §F's own §I records that it cannot establish completeness either. Task 8's step 1 re-derives every citation against the real file and Task 14's diff catches a copy that fell out of step; neither is a completeness check. **Task 12b performs the sweep and records what it read**, and a site it finds is a finding against the spec rather than a gap in this plan. **What stays open is that the sweep is a reader's judgement and nothing checks its coverage** — the record says what was examined, not that the examination was complete.

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
