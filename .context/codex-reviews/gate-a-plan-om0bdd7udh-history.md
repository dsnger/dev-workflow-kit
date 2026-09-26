# Gate-A (plan) working record — cycle `om0bdd7udh`

Advisory, cycle-stable, per CLAUDE.md §5 optional companions. Retire at closure.
Nothing depends on it; the pass files and the repo are authoritative where this disagrees.

- **Kind:** Gate-A plan
- **Nonce:** om0bdd7udh (drawn 2026-09-14 from /dev/urandom, 10 chars, no collision among open cycles — the only other cycle in this work, `awsf1ec771`, closed at `ba15e83`)
- **Artifact:** `docs/superpowers/plans/2026-09-14-loop-rule-consolidation.md`
- **Branch:** loop-rule-consolidation
- **Story:** `docs/superpowers/stories/2026-08-29-loop-rule-consolidation-story.md` — profile read from its header at each pass (high / none / battery+check+verification at pass 1)
- **Derived floor:** 3 (risk high → level 2; security none → 0; max 2 ≠ 0 → 3)
- **Hook knob:** absent (no floor-knob file in `.context/`)

## Resume here

### PASS 56 — RUN, VALID, CLEAN (0 findings). Closure-eligible. NOT closed: the closing commit is not authorized.

Blob `79649d37e89ebd07b60e53d6be5f44a4ccb1cbb5`, HEAD `5fb3b94`, session
`01a0dc89-184b-7d10-86d4-d0d659130526`. The file is exactly `NO FINDINGS` / `END OF FINDINGS (0 total)`.
Floor 3; pass 56 is above it. **Next: Daniel decides the Gate-A closing act.** Per §5 as this cycle
started, that is committing the reviewed plan unchanged together with its provenance line and its
passes 1–56 curve. The curve still has to be assembled from the findings files.

### 2026-09-26 — revision 27 applied, pass 56 authorized (one pass only)

**Release.** Daniel released the sparring brief `.context/sparring/2026-09-26-loop-pass55-prompt.md`:
repair the two pass-55 Majors, verify, run exactly one pass 56, then stop.

**Revision 27** (blob `f34d032…` → `79649d37e89ebd07b60e53d6be5f44a4ccb1cbb5`, 3784 lines):
- a step-7 re-review route for a clean or zero-finding pass whose evidence changed, or which Failure
  charges; Close now requires that no re-review is owed;
- 7b points at that route;
- the no-repair branch's dirty check is an exact-path block admitting only this plan, this cycle's
  findings slots, their per-slot dispositions notes and the working record.

**Executed:** the new block under sh and dash, 5 cases, as expected; the 12 close cases still hold.
**Walkthrough only:** the re-review and Failure-charged routes. The pass-55 Minor stays collected.

### PASS 55 — RUN, VALID, UNCLEAN (0 Blockers, 2 Majors, 1 Minor). Cycle OPEN. No pass 56 authorized.

Blob `f34d032…`, session `01a0da21-a62f-7d83-bb43-d0a00cecad82`. Major 1: the no-repair branch's
"anything else dirty" stop catches the cycle's own uncommitted findings files. Major 2: step 7 has no
route for a clean pass that owes re-review because evidence changed. Both came from revision 26, both
are in-set and small. The Minor (Task 7 checklist) is collected. One tell. Details:
`gate-a-plan-om0bdd7udh-pass-55-dispositions.md`. Next move is Daniel's.

### 2026-09-25 late — option 1 decided, revision 26 applied, pass 55 authorized (one pass only)

**Decision.** Daniel sent the sparring assessment and brief `2026-09-25-194705-loop-pass54-*`. Both
the agent and the reviewer recommended **option 1**: this change's Gate-B cycle follows **§5 at
`$BASE`** (`CLAUDE.md:153`); the installed ordering does not steer it and stays the product under test.
Daniel's message was taken as the release.

**Revision 26** (blob `2d7eeff…` → `f34d03267b9a4387b8121b76b773c6eb7281d71a`, 3747 lines):
- step 7 routing rewritten to §5-at-`$BASE` routes, with an accounting table;
- Failure, Resume, Close and 7b relabelled as the plan's own procedures;
- the no-repair branch reconciled with the complete set (row 27);
- the step-4b block names repair files, including spec and version files;
- the working record is kept until the close has succeeded, and retired last.

**Pass-54 Majors:** 1 → option 1 applied; 2, 3, 4 → fixed. Minor and Nits stay collected.
**Executed:** close composition test, 12 cases under sh and dash; the step-4b block with a spec repair
and with a records-only change. Prechecks: 54 fences, sh -n 7 / dash -n 8, same classes.

### PASS 54 — RUN, VALID, UNCLEAN (0 Blockers, 4 Majors). Cycle OPEN. Stop: finding 1 is a contract question.

Blob `2d7eeff…`, session `01a0d9e6-2fca-73a3-b15f-a58682ac11a8`. 7 findings: 0 Blockers, 4 Majors,
1 Minor, 2 Nits. Majors 2–4 are in-set corrections of revision 25; Major 1 asks which rule set
governs this change's Gate-B cycle (§5 at `$BASE` versus the installed ordering, which disagree on
tells at a closing pass). Details: `gate-a-plan-om0bdd7udh-pass-54-dispositions.md`. Next move is
Daniel's.

### 2026-09-25 evening — D1 accepted, revision 25 applied, pass 54 authorized (one pass only)

**Decision.** Pass 53's mandatory stop (tells 1, 2, 3) was surfaced. Daniel released the sparring
brief `.context/sparring/2026-09-25-183846-loop-d1-prompt.md`, accepting **D1**: Gate-B findings
files are committed once, at the close, not per pass. The durability loss before the close is
accepted and stated in the plan (Close, *D1*). Proposal:
`.context/loop-rule-task15-simplification-proposal-2026-09-25.md`, with the reviewer's three
corrections: no `.context/loop-rule-*` exemption; staged findings files are pinned too; exact slot
paths instead of a glob, so a dispositions note is not taken as findings.

**Revision 25:** plan blob `769fbc6…` → `2d7eeff004758108222f9f921c78f72c4dacdd28` (3706 lines, 457
fewer). Step 7, Close, step 8, Resume, the index, the accounting rows and line 31 were changed; 4b's
failure route was changed too. Details are in `.context/gate-a-plan-pass-54-instruction.md`, section
"REVISION TWENTY-FIVE".

**Pass-53 findings → dispositions:** 1 → fixed (4b failure route); 2 → fixed (one sequence,
explicit no-repair branch); 3 → fixed (`$BASE` loaded in the block); 4 → dissolved (no records
commit, so `HEAD` stays the reviewed head). Minors and Nit stay collected.

**Executed:** step 8's blocks, extracted from the plan, run under sh+dash in disposable repos, 10
cases, all as expected (`scratchpad/close-compose-test.py`). Prechecks: 54 fences balanced, sh -n 7 /
dash -n 8, same classes. **Not executed:** the plan, and the reader re-check.

### PASS 53 — RUN, VALID, UNCLEAN. Cycle OPEN. Mandatory stop (tells 1, 2, 3). No repair, no pass 54.

Blob `769fbc61553fcc8b1d6069c3343282d78028e35c`, HEAD `5fb3b94`, session
`01a0d94e-ecfb-7390-8f8d-b299712092dc`. 7 findings: 2 Blockers, 2 Majors, 2 Minors, 1 Nit. Blocker 1
(4b failure route runs the candidate battery before the candidate exists) was **created by revision
24**; Blocker 2 and both Majors are pre-existing. Details and loop health:
`gate-a-plan-om0bdd7udh-pass-53-dispositions.md`. Next move is Daniel's.

### 2026-09-25 — Daniel decided pass 52's scope question: option B, bounded. Revision 24 made. Pass 53 authorized (one pass only).

**Decision.** Daniel released the sparring reviewer's bounded brief
(`.context/sparring/2026-09-25-154933-loop-pass52-decision-prompt.md`) after the coding agent first
proposed option A (bind via CI). The reviewer showed A wrong on three verified points:
`process-pr-review.md:183` requires the local battery AND CI; `CLAUDE.md:708` owes the battery before
Gate B; `ci.yml` checks out the PR merge result, not the branch head. **B: the battery runs on the
recorded candidate in a disposable clone.** The mandatory stop from pass 52's tells was surfaced to
Daniel and answered by this decision; it is not a waiver, and no gate duty changed.

**Revision 24** (plan blob `15a9b1c…` → `769fbc61553fcc8b1d6069c3343282d78028e35c`):
- Blocker 1: 4b's commit block resolves the commit once (`CAND`), checks `$CAND^{tree}`, writes `$CAND`
  to `.context/loop-rule-reviewed-head`; the separate capture block is deleted.
- Blocker 2: step 4's battery runs in a `--shared` clone detached at the recorded candidate; exit
  0/1/2; limits and old-condition accounting written after the block; step 7's "battery is bound"
  bullet and the line-31 constraint aligned.
- Evidence (scratchpad, disposable): Blocker 1 old shape recorded a different commit after an
  intervening commit, new shape recorded the checked id. Blocker 2 control passed (exit 0) on
  `5fb3b94`; defective candidate + worktree-only revert: old worktree shellcheck exit 0, new block exit 1.
  Plan-extracted battery block byte-equal to the tested block; both blocks `sh -n`/`dash -n` clean.
  Plan: 59 fences balanced, `sh -n` 8 / `dash -n` 9 failures — same classes as before.
- Minor and Nit from pass 52 stay collected.

**Scope of the release:** at most pass 53, then report and stop. No pass 54, no automatic repair, no
commit/push/rebase. Instruction: `.context/gate-a-plan-pass-53-instruction.md`.

### PASS 52 — RUN, VALID, UNCLEAN. Cycle stays OPEN. No repair authorized, none made.

Reviewed the repaired worktree plan: blob **`15a9b1c2ff4beb3c6dfa6ae21e00550210d4b969`**, `HEAD`
`5fb3b942f1907f5d6dd25b32d15b497f855e05f8`, branch `loop-rule-consolidation`, diff +675/−134 against
`HEAD`. **Identity checked before and after the call — the blob did not move.** Tool:
`mcp__codex__exec`, session `01a0b0ac-5d48-75d1-86b8-e196edda1f40`. The pass reviewed the
**twenty-second and twenty-third revisions**, which pass 51 had not seen.

**Result VALID** — terminator `END OF FINDINGS (4 total)` exact, 4 body lines, every line a finding
line, 6 fields each, no blanks, count matches. **4 findings: 2 Blockers, 0 Majors, 1 Minor, 1 Nit.**
Per-finding verdicts in `.context/codex-reviews/gate-a-plan-om0bdd7udh-pass-52-dispositions.md`;
**both Blockers confirmed against the plan text, the Nit confirmed by direct read, the Minor confirmed
in kind with its named sites unverified.**

**Floor 3**, read fresh from the story header at this pass: **Risk `high`** (level 2) · **Security
`none`** (0) · max 2 ≠ 0 → 3. One cited story, from the plan's `**Story:**` header. Floor long
satisfied; what is missing remains a **clean** pass.

**Method change, declared.** The instruction was delivered by pointing Codex at
`.context/gate-a-plan-pass-52-instruction.md` (1006 lines) instead of inlining 100 KB in the tool
argument — reproducing that verbatim into a parameter risks silent drift, the file on disk does not.
The findings-protocol contract was restated inline. **That Codex read the file in full is not
established**; the reply and the findings are consistent with it, which is evidence and not proof.

**The two Blockers, in one line each.** Step 4b's commit block pins `$ITREE` and checks
`HEAD^{tree}` against it in one fenced block (plan 2954–2967), then a **separate** block (2987–2993)
resolves `HEAD` **again** to write `.context/loop-rule-reviewed-head` — and the plan itself states at
line 3027 that each fenced block is its own shell invocation, so nothing binds the recorded candidate
to the commit that was checked. **That is the resolve-once class of passes 47–49, reintroduced by the
twenty-second revision's own new capture block.** And step 4's battery runs over the **mutable working
tree** while step 6 checks only that `HEAD` has not moved, so a dirty helper change can make the
battery green for bytes absent from the candidate.

**The second Blocker is the blocking decision and it is NOT the loop's to absorb.** The plan
**already discloses** that window in its own text (2977–2985) as "a limit rather than guarded".
Disclosure does not discharge a Blocker — this cycle settled that at the twentieth revision. But the
proposed fix is a **new mechanism** (a detached disposable checkout for the battery, or an
index+worktree equality re-check on both sides of it), and this cycle holds **two live rulings that
point opposite ways**: it declined new preconditions at pass 44 and at pass 49's finding 3, and it
ruled at revisions twenty and twenty-one that "a different checking mechanism is not by itself a new
requirement" — which is the ruling that put step 4c in the plan. **A new structural question stops
the loop and goes to Daniel** (§5: novelty wins over ancestry). Finding 1, by contrast, sits inside
the assigned fix set and is an ordinary repair once authorized.

**Loop health: at least two of five tells, so stop-and-surface is mandatory** — independently of the
instruction to stop. Findings 42–52: **3, 5, 9, 2, 1, 2, 3, 6, 4, 6, 4**; Blockers **2, 2, 2, 1, 1,
1, 3, 5, 2, 2, 2**; Majors **1, 2, 7, 1, 0, 1, 0, 1, 1, 2, 0**. (1) Finding count **falling**, 6 → 4
— not present. (2) Blocker count **flat at 2 for the third pass — failing to fall**. (3) **Instrument
cluster, total**: all four are the plan's own execution machinery; zero touch the §5 target text.
(4) A **partial prose cluster** — findings 3 and 4 are both prose promising what the command beside it
does not do; reported, not resolved, and it changes nothing. (5) **No require↔withdraw pair**.

**The "clearly stuck" exit is still NOT available.** No plateau at six or more — the Blocker curve
over the last six is 1, 3, 5, 2, 2, 2. **No affirmative coverage judgement is possible** — finding 1
is a defect the twenty-second revision itself created. Regeneration is present; that is one conjunct
of three, and one is not the exit.

**Mechanical prechecks on this blob, new this session and not comparable to earlier reported
baselines** (different extractor): **60 fenced blocks, all balanced, none unclosed**; `sh -n` fails on
**8**, `dash -n` on **9**, every one an intended `<…>` placeholder or `bash`-only process
substitution — **no new syntax regression**; every cited repo path resolves; `loop-rule-baseline-diff`
`.tmp`→`.txt` is an atomic rename, not an inconsistency.

**Nothing was committed and nothing was repaired.** `docs/superpowers/specs/2026-08-30-dark-factory-vision.md`,
`todos.md` and `docs/field-reports/2026-09-17-sfx-review-loop-economics.md` remain Daniel's edits in
flight — untouched.

**Next:** pass 53 is **not** authorized. The next step is Daniel's decision on finding 2's scope
question. `.context/gate-a-plan-prompt.md` now carries pass 52's history entry, the twenty-second and
twenty-third revision descriptions, the updated collected list and the identity-not-cleanliness
precondition; substitute `__SHA__`/`__P__` to build the next instruction file.

## HANDOFF — 2026-09-17, written for a session that has just lost its context

**State.** Plan anchor `1ba45be`; cycle `om0bdd7udh` **OPEN and UNCLEAN at pass 49**. The plan's
sixteenth revision repaired all three of pass 48's Blockers; **pass 49 found six more — 5 Blockers
and 1 Major — and none is repaired.** **Nothing is implemented yet** — `CLAUDE.md`,
`plugins/dev-workflow/commands/workflow-init.md` and the hook are untouched.

**Pass 49 ran full, on Daniel's reviewer's written authorization of 2026-09-17** (exactly one full
Gate-A plan pass, four areas prioritized, no part of the artifact excluded; no repair round, no
implementation, no pass 50). Reviewed revision: the plan at `1ba45be`, blob
`bc685751b971c6708fc7abf133d4e73e530ec9a5`, **identical at `1ba45be`, at `HEAD` `5fb3b94` and in the
worktree** — the intervening commit touches only this record. Repo read at `HEAD` `5fb3b94`. Result
**VALID** under the findings protocol: terminator `END OF FINDINGS (6 total)` exact, 6 body lines,
every line a finding line, 6 fields each, no blanks. File
`.context/codex-reviews/gate-a-plan-om0bdd7udh-pass-49.md` (untracked on disk, not committed).

**All six were validated against the plan text before being reported** — five read-only subagents,
one per Blocker, plus execution for the Major. Verdicts: findings 1, 2, 4 **confirmed**; findings 3
and 5 **partially confirmed**; finding 6 **confirmed by execution**. Details in the pass-49 rows
below.

**The one structural fact pass 49 establishes: the resolve-once sweep is not complete.** Five of the
six are the same defect class the sixteenth revision swept — a movable ref re-resolved as the
*identity* of an object whose properties were already checked — at five sites that sweep did not
reach. Two were simply missed (Preparation/Task 0 step 1; step 6's call issuance, which is prose
describing an MCP parameter and therefore **structurally invisible** to a shellcheck-verified sweep).
One was **explicitly excluded with a rationale that does not hold for it**: `1ba45be` wrote
"conditions 1, 5 and 6 read `HEAD` on purpose, to detect a move, and stay as they are" — true of 1
and 5, which each compare one read against one recorded baseline, but condition 6 has **no baseline
at all** and composes subject, parent, tree and body from four separate reads.

**Not yours to touch:** `docs/superpowers/specs/2026-08-30-dark-factory-vision.md`, `todos.md` and
`docs/field-reports/2026-09-17-sfx-review-loop-economics.md` are Daniel's own edits in flight. Leave
them dirty; do not commit, revert or review them.

**That decision is spent: Daniel chose "voll", pass 49 ran full, and its authorization is exhausted.**
No repair round, no pass 50, no implementation is authorized by it.

**The six open findings, with the validation verdict on each.** All must resolve before this cycle
can close — §5's Blocker/Major rule is not waived by the utility test.

1. **BLOCKER — Preparation and Task 0 step 1. CONFIRMED.** Preparation checks branch, ancestry and
   the three approved-input blobs through six separate live `HEAD` resolutions; Task 0 step 1 then
   writes `.context/loop-rule-base` from a **seventh**, independent one, so the recorded base is
   bound to no commit whose properties were checked. Each fenced block is its own shell invocation,
   so the two can be arbitrarily far apart. **Not in either of `1ba45be`'s lists** — neither repaired
   nor deliberately left; simply missed. No existing guard, no disclosure.
2. **BLOCKER — Task 15 step 6, call issuance. CONFIRMED.** Step 6 records the reviewed head to
   `.context/loop-rule-reviewed-head`, then the call's `headSha` is specified in **prose** as "the
   full 40-character object name `HEAD` resolves to at that moment" — never wired to the file just
   written. Close condition 1 later compares `HEAD` against the **file**, never against what was
   actually sent, and the review tool reports no reviewed revision, so the divergence is capturable
   nowhere. **CLAUDE.md's own `headSha` rule is satisfied**; the stronger demand comes from the
   plan's own logic (self-review item 28). **The sweep could not have caught this** — it is not shell.
3. **BLOCKER — Task 15 step 8b, Close condition 5. PARTIALLY CONFIRMED, and the weakest of the six.**
   Condition 5 already closes the **wide** window: anything committed between 8a and 8b fails the
   `HEAD == TIP` check, anything merely staged fails the clean-tree check. What remains is a
   **sub-second TOCTOU inside 8b's own script**, between its own checks and its own `reset --soft`,
   requiring a **second concurrent actor** on a normally sequential single-operator session. Git
   offers no expected-old-object guard on `reset`; `update-ref` appears nowhere in the plan. "Silently
   publish" is true of the script but **not** of the documentation: target text §I names this gap
   loudly as parked on Daniel's decision of 2026-09-13.
4. **BLOCKER — Task 15 step 8, Close condition 6 and cleanup. CONFIRMED.** After the closing commit
   lands, subject, parent, tree state and body are read through **four** independent live `HEAD`
   resolutions with **no captured commit id**; the parent check asserts only `HEAD^ == $BASE`, true of
   *any* commit parented by the base. Cleanup then deletes every recovery artifact. **Explicitly
   excluded by `1ba45be` on a rationale valid for conditions 1 and 5 and not for 6** — those compare
   one read against one recorded baseline; condition 6 has none and composes four properties.
5. **BLOCKER — the records-commit marker's recovery rule. PARTIALLY CONFIRMED, two halves.**
   *Confirmed:* the five checks `1ba45be` added (40-char id · resolves to a commit · `ba15e83` an
   ancestor · itself an ancestor of `HEAD` · both slot paths blobs **in that commit**) are satisfied
   **trivially by any earlier already-routed records commit** on a linear branch — nothing pins "the
   current pass", and no scan for a later competing records commit exists. Also confirmed: the generic
   "delete and rebuild from the `$BASE` blobs" rule is a **category mismatch** — this marker is not a
   function of `$BASE`'s content. *Blunted:* for the case the plan **does** name — valid marker, outcome
   not shown — there is a real executable precondition stop (report, no mutation, no call). The
   scenario nobody checks for is a stale-but-valid marker coexisting with a later unmarked records
   commit at `HEAD`.
6. **MAJOR — Task 7, the worked carried-fragment example. CONFIRMED BY EXECUTION.** The plan runs
   `grep -cF 'Codex is advisory — validate before applying; dismissed finding → one-line why'` and
   states "Expected: `1` each in the worktree, and `parent=1 worktree=1` in each copy". In **both**
   prompt copies the text wraps between `Codex is` and `advisory` (`CLAUDE.md:135-136`,
   `plugins/dev-workflow/commands/workflow-init.md:342-343`), so the literal count is **0**. A
   **correct** source text fails its own preservation check — a false red, which the severity
   procedure's symmetric instrument carve-out keeps at Major.

**The 80/20 claim is withdrawn as evidence.** Daniel's reviewer ruled it **unverified classification,
not a measurement**, and it **must not determine exclusions or severity**. What *is* counted, from the
pass files rather than from memory: passes 42–48 hold **exactly 25 findings — 12 Blockers, 12 Majors,
1 Minor** (`grep -cE '^(BLOCKER|MAJOR|MINOR|NIT) \|'` per file). The payer split is a judgement made
per finding under the utility test, and for **all six of pass 49's the payer is the one person
executing this plan at a terminal** — no user of the shipped plugin hits any of them. The closest to
a shipped consequence is finding 2: if it fires, *this change's own* edits to `CLAUDE.md`,
`workflow-init.md` and the hook could land without full Gate-B coverage. **The utility test waives no
floor, no mandatory tell and no closure condition**, so none of this makes the cycle closable.

**Of the plan's 54 shell blocks, four areas decide what is published** — **8a/8b** (the closing
commit), **steps 3–4** (version bump and battery, invariant 12), **step 6** (the Gate-B range), and
**Tasks 10/11** (the hook change and its invariant-4 review). Pass 49 was prioritized on these and
excluded nothing; five of its six findings landed inside them.

**Loop health at pass 49 — three of the five tells stand, so the stop is mandatory, not
discretionary.** Trend across passes 42–49: findings **3, 5, 9, 2, 1, 2, 3, 6**; Blockers **2, 2, 2,
1, 1, 1, 3, 5**; Majors **1, 2, 7, 1, 0, 1, 0, 1**. (1) Finding count **rising**, 3 → 6. (2) Blocker
count **failing to fall**, 3 → 5. (3) **Instrument cluster** for the twelfth pass — all six are the
plan's own execution machinery; **zero** touch the §5 target text the change installs, and zero are
prose about either. Not present: a prose cluster, and **no require↔withdraw pair** — the near-miss
worth naming is that `1ba45be` declared conditions 1/5/6 "stay as they are" and pass 49 demands 6
change, which is a pass challenging a stated **non-change**, not a demand for something an earlier
pass removed.

**The "clearly stuck" exit is NOT available, and all three conjuncts fail.** No plateau — the Blocker
curve is **rising**, not flat. No affirmative coverage judgement is possible: the sixteenth revision's
sweep was explicitly bounded, and pass 49 finding five more sites of the same class is **direct
evidence that coverage is insufficient**. And the findings are **newly discovered at previously
unswept sites**, not regenerated from the repairs — pass 49 re-raised **nothing** against the three
blocks `1ba45be` actually repaired.

**The severity procedure's unsettled question does not bite here, and this was checked rather than
assumed.** All six name an operational consumer (the executor acting on the plan) and a decision that
changes (which commit becomes base, reviewed head, or closing tip). The instrument carve-out is
symmetric, so findings 1/2/4 keep severity as **false greens** on a gate and finding 6 as a **false
red**. Nothing is demoted, so the per-pass counts and clusters above are unaffected by the open
question in `docs/superpowers/stories/2026-08-29-loop-rule-consolidation-story.md`'s sibling
consolidation work.

**Standing orders now in force** (also in the session memory):
- **Subagents, parallel, by default.** Fan out read-only inspection; keep writing serial — one writer.
- **Model per job**: haiku for mechanical scans, sonnet for ordinary judgement, opus only where a
  wrong call is expensive (the close, closure conditions, anything a gate depends on).
- **A stop goes through a gate, never into a menu for Daniel.** Take the report's own output, make it
  the gate question, put it to Codex, validate the answer, follow it. Only a decision the rules
  reserve for a human reaches him — and then as one decision with the gate's reasoning attached.
- **Codex is the sparring partner**: he proposes with evidence, I validate, I apply what holds and say
  what I rejected.
- **The utility test on every finding**: name the payoff — **bugfix, security-fix or performance** —
  and name **who pays** if it is left: a user of the shipped product, or the executor at a terminal.
  No nameable payoff → collect, never iterate. **It waives no floor, no mandatory tell and no closure
  condition** — `todos.md` "Review-loop usefulness" (Dark Factory vision §§4/7/11) is the formal
  version and activates no thresholds.

**WHERE THE SCOPE NOW STANDS — 2026-09-17, after Daniel's reviewer assessed pass 49.** The stop was
upheld; a blanket "repair all six, then pass 50" was **declined**. Two artifacts carry the result:

- `.context/codex-reviews/gate-a-plan-om0bdd7udh-pass-49-dispositions.md` — verdict + reason per
  finding, and the three corrections to my pass-49 status report.
- `.context/plan-drafts/pass-49-repair-draft.md` — the coherent draft for findings **1, 2, 4, 5**
  along the four axes (check subject · stored identity · consumer · recovery), finding **6** as a
  separate one-line fix, and finding **3** dispositioned rather than repaired. **Applied: nothing.**

**Three corrections to the pass-49 report, all validated before acceptance — do not re-adopt the
originals.** (1) "All six are paid for by the executor alone" is **wrong**: the standard is the
causal chain, and `workflow-init.md`, `codex-gate.sh` and `codex-gate.test.sh` ship inside the plugin
package, so findings 1, 2 and 4 can put unreviewed content into shipped files. (2) "No regeneration
from the repairs" is **too sweeping**: `1ba45be` has seven hunks across **four** regions, not three,
and the first is Resume's marker validation — the very thing finding 5 attacks, so finding 5 **is**
regeneration. The "clearly stuck" exit stays unavailable all the same: Blockers are rising and no
coverage judgement is possible. (3) The claim that the utility test was missing from the instruction
file is **false** — it is at line 572. The other half of that correction is right and is **my
defect**: the four priority areas appear **nowhere** in the instruction file, and my wrapper asserted
the prompt named them when it did not. **Pass 49 is therefore not a usable test of the sharpened
approach**, and any pass 50 must carry the four priorities in the prompt file itself.

**A SEVENTEENTH BOUNDED REVISION was made on 2026-09-17 and all six findings are repaired in the
worktree. Nothing is committed; the plan is dirty.** Daniel released the scope with "weiter" and
instructed that questions like finding 3's go **through a gate, not to him as a menu**.

- **Finding 1** — Preparation captures the starting revision **once**, runs branch, ancestry and the
  three approved-blob predicates against that captured object, and records it to a new file
  `.context/loop-rule-start`. Task 0 step 1 reads that file, **re-asserts `HEAD` still equals it
  immediately before the first mutation**, records it as the base and retires the start file. The new
  state file **ships with its recovery rule in the same change** — surviving start with no base is an
  interrupted first entry and a precondition stop, never rebuilt, never resumed from — because a
  state file introduced without one is precisely the defect pass 48 found in the revision before.
- **Finding 2** — the call's `headSha` is now **the exact content of `.context/loop-rule-reviewed-head`**,
  quoted as a literal, never a fresh resolution. The repair is prose because **there is no command to
  guard** — the value goes into an MCP argument — so the residual is stated: nothing mechanically
  compares the argument sent against the file, and Close condition 1 authenticates the file.
- **Finding 3** — settled **through a Codex gate**. Verdict **NOT OWED**: condition 5 scopes its claim
  to "when the closing invocation begins", nothing stated is violated, the wide window is already
  closed, and an atomic guard means replacing `reset --soft` with `update-ref` plus separate index
  handling — a different close mechanism, hence a new precondition, which this plan declines on the
  same ground as pass 44's three escalations. Implemented as a **disclosed residual on condition 5**,
  which names the unguarded span, says its width is unmeasured, and states that no later check would
  catch it because the content comparison is the parked tree-equality condition.
- **Finding 4** — condition 6 captures **one object** and addresses subject, parent and body to it;
  the tree check and the **cleanup are gated on a `HEAD = $CLOSED` re-assert**, so the cleanup gate is
  a command instead of the sentence "all four pass, and only then". The cleanup block is merged into
  condition 6's block; `1ba45be`'s claim that conditions 1, 5 and 6 alike "read `HEAD` on purpose" is
  corrected in the same change. **Say what this is, not more: the four predicates now describe ONE
  commit — it is not established that this commit is the one 8b created.** The plan discloses that
  limit in its own text, and a summary reading "captures the closing commit" would hide it.
- **Finding 5** — the marker must now be **the newest records commit reachable from `HEAD`**, which is
  what separates a stale-but-valid marker from the current pass; three outcomes are named separately
  (ordinary · stale marker · marker absent with a records commit present), and `$NEWEST` empty with
  status 0 is read as a real result. The marker is **carved out of the generic "rebuild from the
  `$BASE` blobs" rule by name** — it is not a function of `$BASE`'s content and cannot be rebuilt at
  all. **Simpler than the draft proposed**: no record format change, so step two's consumer is untouched.
- **Finding 6** — the fragment drops its leading `Codex is `, measured at 1/1 in both copies, and the
  plan now states that a fragment is line-local by construction and is verified **before** it is
  written down.

**Finding 5 was corrected a second time, on Daniel's reviewer's report, and the defect was
reproduced before it was repaired.** The first repair asked
`git rev-list -n 1 --grep='^WIP: pass [0-9][0-9]* records$' HEAD` — **unbounded**: it searched the
whole reachable history for a generic subject, so a records commit from **another cycle** could be
taken for this cycle's newest and make a **perfectly valid marker read as stale**. Reproduced in a
disposable repository. The shipped check is now bounded **twice**, and **both bounds are needed** —
measured, not assumed: `$BASE..HEAD` alone still lets a foreign commit inside the range win; it is
the **nonce-scoped slot pathspec** that makes the answer this cycle's.

**Verified by execution: 21 fixtures × `sh`/`dash`/`bash`, all green** — 10 for finding 1, 6 for
finding 4, 5 for finding 5 — blocks extracted verbatim, each finding carrying a control that
reproduces the old defect, including a foreign-cycle counter-case. `sh -n`/`dash -n` failures are
**6 and 7, identical to the pre-repair baseline**. **Three first-run fixture failures were all harness
bugs** (no `.gitignore` in the disposable repo; one miscalculated control assertion), recorded in the
dispositions file.

**Two corrections to my own verification, both found by running it rather than reading it.**
(1) **"Fenced blocks 55 → 54" was wrong.** My extractor only matched fences at column 0, so it never
saw the new **indented** marker block — which also means that block went unchecked in the first
round. With the corrected extractor the count is **55 before and 55 after** (one top-level block
merged away, one indented block added), and the new block parses under all three shells.
(2) **The fixture results are self-reported.** Daniel's reviewer has not executed them and says so;
they are evidence about the cases they cover and **no claim of completeness**.

**What is NOT established.** No sweep was run for a **seventh** site of the resolve-once class —
pass 49 found five after a sweep that believed itself complete, and nothing here rules out another.
The repairs are verified against fixtures, not reviewed. Resume's new marker branches and the
`loop-rule-start` recovery rule are **reader text, asserted as text and not executed**.

### TWENTY-THIRD BOUNDED REVISION — 2026-09-17. The rerun path reconciled.

The twenty-second revision fixed the first-pass order and **left the rerun contradicting itself**.
Two defects, both confirmed in the text before editing:

- My rerun bullet said *"no commit is made between the candidate head being written and the call"*,
  while **the very next bullet** still said *"Commit those records, resolve the new `HEAD`, and only
  then issue the candidate final pass."* Directly contradictory.
- The rerun put **step 4b's reader checks after the capture**, although their result is a record that
  must be committed.

**The reconciled sequence, now written as six numbered steps and identical on both paths:**
1 repair and produce every record that must be committed · 2 **commit them** (step 7 step three's
commit — the last before the call) · 3 **capture the candidate** into
`.context/loop-rule-reviewed-head` · 4 final verification that writes no committed record — the
battery, then **4c**; non-zero or unresolved returns to 1 · 5 write the evidence entry into the
gitignored `closing-msg` · 6 issue the call with the captured head and that entry verbatim.

**The recording duty kept its home rather than being deleted with the bullet.** The conflicting
bullet's two claims were split: its *recording* duty moved into step 1, and its *"only a clean
response against that exact `HEAD` closes the cycle"* rule is restated where the ordering now makes
it true. The complete-rerun list gained an explicit split — **record-producing work** (repair, 4b's
twelve items, every mechanical observation) versus **final verification** (battery, 4c) — which is
what orders the whole step.

**A second correction, and it was an overclaim of mine.** I had written that the battery reads the
candidate identity. **It does not.** Step 4 reads `.context/loop-rule-baseref` and runs shellcheck,
the hook suites, the invariant checkers and `claude plugin validate` **over the working tree of the
current repository**; it takes no candidate id. Both sites now say so, and state the real binding:
the battery describes the candidate only because it runs immediately after the capture with no commit
in between, and **nothing enforces that the worktree is unmodified across that window** — step 6
catches a moved `HEAD`, not a dirty tree. **A stated limit, not a guard**; no index or concurrency
policy was invented.

**Walked, both paths.** *First pass:* 1–3 → 4b (items + repairs + records, its commit) → capture
(`:2991`) → battery → 4c → entry → call. *Rerun with a repair to a shipped file:* step one's records
commit → step two routes → step three stages the repair **and** the plan, commits (block line 31),
then captures `NEXTHEAD` (line 71) → battery → 4c → entry → call. *Rerun with no repair:* step three
commits nothing, `NEXTHEAD` = the records commit step one validated, capture → battery → 4c → entry →
call. **Exactly two writers of `reviewed-head` exist** (`:2991`, `:3576`), and in both the commit
precedes the capture. **No instruction after the capture requires another commit before the call.**

**Validation limits.** The walk is a reading of the text; the shell blocks it names were re-run —
29 existing fixtures plus the 4c cases — all green under `sh`, `dash` and `bash`, with `sh -n`/`dash
-n` at **6 and 7, the baseline**. **No fixture exercises the six-step sequence end to end**; that
would need the whole of Task 15 executed, which is implementation. Fixture results remain
self-reported.

**Minor and Nit remain collected.** No findings are claimed resolved and the cycle is not clean.

### TWENTY-SECOND BOUNDED REVISION — 2026-09-17. One candidate flow for Task 15.

**My own proposal was wrong and the reviewer took it apart correctly.** I offered a choice between
binding 4c late (in 7b) and binding it early without a record. **Option A was self-defeating**, and
two citations settle it: step 6 hands the reviewer *"the evidence entry quoted verbatim"* (`:3202`)
and 7b says that if that entry changes at revalidation **the candidate is over** (`:3640`). A binding
4c result first appearing at 7b therefore changes the entry the final reviewer judged and forces the
very next round it was meant to prevent. My claim that the early option means "a failure only shows
at CI" was also **false**: a binding pre-Gate-B 4c stops before Gate B. And no new carrier was ever
needed — step 5 already writes the entry into `.context/loop-rule-closing-msg`, which is
**gitignored**, so no pre-pass commit touches it.

**What was implemented — the reviewer's sequence, unchanged:**

1. **Step 4b moved to before step 4.** It keeps its letter (six places cite "step 4b"; a rename would
   have to reach all of them) and the block carries a note that this file executes in **reading**
   order. It is the last step that may alter content.
2. **One candidate identity, created once, at the end of 4b** — written to
   `.context/loop-rule-reviewed-head`, the file that already means this. **No new state file, no new
   recovery rule, no new cleanup entry.**
3. **Battery and 4c run against that identity**, read from the file. Not verified → stop, no entry,
   no call.
4. **Step 5 writes the evidence entry including 4c's three ids, plugin diff and raw status**, into
   the existing closing-msg, uncommitted.
5. **Step 6 resolves nothing.** It reads the candidate head, refuses if `HEAD` has moved since, and
   passes that value as `headSha` with the entry verbatim.
6. **7b names how it preserves the entry** — the open design point. It reads the existing entry out
   of closing-msg and **carries item 4 across** while rebuilding items 1–3; a missing entry is a
   **stop**, not a rebuild, because the 4c result is read from a run and cannot be regenerated from
   the record sections. The existing re-review rule for a changed entry is untouched.
7. **Merge direction reversed** — check out the base, merge the candidate in, the order
   `refs/pull/N/merge` is built in. The intended checker is still pinned **from the candidate** by
   object id before anything merges.
8. **Step 7's rerun bullet now states the same sequence as the first pass**, and that **no commit is
   made between fixing the candidate head and issuing the call**.

**Verified by execution — 8 cases for 4c after the direction and identity changes, plus the 29
existing fixtures, all green under `sh`, `dash` and `bash`.** Added case: an unresolvable candidate
head read from the file → unresolved. `sh -n`/`dash -n` remain **6 and 7 — the baseline**. Step 6
contains **zero** fresh resolutions of `HEAD` into the reviewed-head file. **The direction change
moved no verdict in these fixtures** — none uses a merge driver — so it is adopted because it matches
how CI builds the object, not on fixture evidence.

**Not claimed:** that pass 51's findings are resolved, or that the cycle is clean. **The Minor
(unguarded plugin-diff pipeline) and the Nit (no `mktemp` cleanup) remain collected and unrepaired**,
as instructed — both still sit in the 4c block.

### PASS 51 — RUN, VALID, UNCLEAN. Cycle stays OPEN. No repair authorized, none made.

Reviewed the frozen candidate: plan blob **`974e223ed71d52b49c6b368695372ccb72e510f1`**, `HEAD`
`5fb3b942f1907f5d6dd25b32d15b497f855e05f8`, branch `loop-rule-consolidation`, diff +482/−64.
**Identity checked before and after the call — the blob did not move.** Tool: `mcp__codex__exec`;
the prompt opens with the required brainstorming line and names the four priorities plus the seven
4c-specific questions.

**Result VALID** — terminator exact, 6 body lines, every line a finding line, 6 fields each, no
blanks, count matches. **6 findings: 2 Blockers, 2 Majors, 1 Minor, 1 Nit.** Per-finding verdicts and
the split between reviewer claim and my own verification are in
`.context/codex-reviews/gate-a-plan-om0bdd7udh-pass-51-dispositions.md`; **all six confirmed**.

**Floor 3**, derived from `docs/superpowers/stories/2026-08-29-loop-rule-consolidation-story.md` read
fresh at this pass: **Risk `high`** (level 2) · **Security `none`** (0) · max 2 ≠ 0 → 3. One cited
story, profile resolves. Floor long satisfied; what is missing remains a **clean** pass.

**The two Blockers, in one line each.** Step 4b **commits after** the battery and 4c have run, and
the first-pass path runs no complete rerun before step 6 — so Gate B can review and close a head that
never got either check, and a 4b repair to a shipped prompt or hook is absent from 4c's merge result
entirely. And 4c's `HEADID` is an operator placeholder while step 6 independently resolves live
`HEAD`: **nothing ties them**, so 4c can certify one candidate while Gate B reviews another.

**Four of the six are in machinery I added in the last two revisions, and two of those are defect
classes this cycle had already swept.** Finding 5 is an unguarded pipeline whose status a following
`tr` consumes — the class of passes 43 and 44. Finding 6 is new state with no cleanup rule — the
class of pass 48. **Writing new code reintroduced both.** That is regeneration from the repairs, not
discovery in unswept ground, and the record says so rather than presenting it as fresh coverage.

**Loop health: three of five tells, so stop-and-surface is mandatory** — independently of the
instruction to stop. Findings 42–51: **3, 5, 9, 2, 1, 2, 3, 6, 4, 6**; Blockers **2, 2, 2, 1, 1, 1,
3, 5, 2, 2**; Majors **1, 2, 7, 1, 0, 1, 0, 1, 1, 2**. (1) Finding count **rising**, 4 → 6. (2)
Blocker count **flat at 2 — failing to fall**. (3) **Instrument cluster**, and this time
concentrated: five of six land on step 4c and its interface. Not present: a prose cluster; and **no
require↔withdraw pair** — finding 4 asks to reverse a merge direction I chose freely, which is a
correction rather than a reversal of something an earlier pass removed.

**The "clearly stuck" exit is still NOT available**, and this pass does not change that: the Blocker
curve is 3, 5, 2, 2 over the last four — no plateau at six or more passes — and **no affirmative
coverage judgement is possible**, since the last two revisions demonstrably added new unswept
machinery. Regeneration is now present, which it was not at pass 50; that is one conjunct of three,
and one is not the exit.

**Nothing here closes the cycle**, and a clean pass would not close it by itself either: closure
needs the clean pass **plus** every other duty §5 names.

### TWENTY-FIRST BOUNDED REVISION — 2026-09-17. Three corrections to step 4c itself.

All three were reported as static findings against the new procedure, and **all three validated**.

**1. The outcome separation did not hold.** `scripts/check-version-bump.sh` exits `1` from **both**
`fail()` (a policy violation, `rc=1`) and `die()` (an operational failure — unresolvable ref, failed
git call, unparseable manifest). Verified at lines 68 and 73. My 4c read every `1` as a version
violation. **Fixed without a parser and without touching the checker:** the output and the **raw**
status are preserved, non-zero is reported as **NOT VERIFIED with the cause undetermined**, and the
cause must be established from that output before anyone calls it a version violation. Both cases
stop progression, so nothing depends on guessing.

**2. The byte check ran before the merge — and its reference was wrong too.** Comparing before the
merge establishes nothing about the bytes that then execute. **But fixing only the ordering was not
enough, and the fixture caught it:** the comparison read the checker from the source repository's
**worktree**, which can already sit on the base side and carry the very edit the check exists to
catch — so it agreed with itself and the modified checker ran. It now pins
`git show "$HEADID:scripts/check-version-bump.sh"` **before** merging and compares the merge result
against that, **after** the merge. A green check that could not go red is not evidence; this one
now goes red.

**3. The integration contradicted the addition.** Step 7 still said checking the merge result was "a
scope question and not a change this plan makes" — now retracted **in place**, with the reason (a
different checking mechanism is not by itself a new requirement), and the only surviving occurrence
of that phrase is the quotation inside the retraction. The complete rerun now **names 4c
explicitly**, places it **last**, and says a non-zero or unresolved 4c stops progression.

**The recording cycle is closed by ordering, not by machinery.** 4c runs *after* the rerun's records
are committed and the new `HEAD` is resolved, **against that head** — the one the candidate pass is
issued against — and **its own result goes into the closing commit body**, not into a further
pre-pass commit. Any scheme that committed 4c's result before the pass would move the head 4c had
just certified and demand another run, forever.

**Validation — the block as extracted from the plan, eight cases, expected vs observed:**

| case | want | got |
|---|---|---|
| valid version bump | 0 | **0** |
| same version + plugin diff | 1 | **1**, policy cause present in the preserved output |
| operational failure **inside** the checker | 1 | **1**, **not** labelled a version violation |
| conflict-free merge changing the checker's bytes | 2 | **2**, refused **before** the checker ran |
| merge conflict | 2 | **2** |
| unresolvable pinned head | 2 | **2** |
| no recorded base ref | 2 | **2** |
| source fixture repository afterwards | unchanged | **branch unchanged, 0 staged, 0 dirty** |

The byte-change case **failed on the first run** — exit 0, checker executed — which is what exposed
the worktree-reference defect. It is recorded rather than quietly fixed.

**Remaining limitations.** Fixture results are self-reported; the reviewer has not reproduced them.
**No claim of complete error classification is made** — 4c distinguishes *verified* from *not
verified* from *unresolved*, and deliberately does **not** classify the cause of a non-zero checker
status. The other standing limits are unchanged: Resume's three marker outcomes and the
`loop-rule-start` recovery rule text remain reader instructions, and no sweep establishes the
resolve-once class is discharged everywhere.

### TWENTIETH BOUNDED REVISION — 2026-09-17. Step 4c: the merge-result version check.

Scope from Daniel's reviewer, and it is narrow: **add one bounded, isolated check of the version
requirement against the merge result of a pinned head and a pinned base, validate it with the
unchanged checker, dispose the pass-50 version finding on evidence, report, stop.** No CI change, no
version policy, no pass 51, no implementation.

**The reasoning error it corrects is mine.** I wrote that full closure "would be a scope decision,
not a repair". **That does not follow** — the same correction the reviewer made about the atomicity
case applies here: *a different checking mechanism is not automatically a new requirement*. An
accepted Blocker is not discharged by disclosing it, and `design.md` §7 — which requires the battery
green **at the Gate-B WIP commit** and promises nothing about a later merge commit — neither grants a
CI guarantee nor excuses the version duty. Verified at `design.md:215`.

**What was added: Task 15 step 4c.** It clones the work repo `--shared --no-checkout` into a
disposable directory, checks out the **pinned implementation head**, merges the **pinned base** step 4
already recorded, and runs the **unchanged** `scripts/check-version-bump.sh` against that merge
result. **The existing battery and the Gate-B review range are untouched.**

**Three outcomes, deliberately distinct** — and this separation is itself a repair: `0` the rule
holds · `1` the rule is **violated** on the merge result · `2` **UNRESOLVED**, the check could not be
carried out. A single non-zero code would have made a merge conflict indistinguishable from a
rejection, so an unresolved check could have been filed as a failure — or, worse, a passing run
inferred from "no rejection".

**Two traps the step closes by construction, both learned the hard way in this cycle.** The checker's
line 58 is `cd "$(dirname "$0")/.."`, so it is invoked **relatively from inside the clone** — an
absolute-path call silently runs it against its own source tree, which is exactly how my earlier
"could not be reproduced" was manufactured. And its bytes are compared against the source checker, so
a modified checker at the pinned head is UNRESOLVED rather than trusted.

**Verified by execution against the plan's own extracted block — 7 cases × the real checker:**

| case | expected | observed |
|---|---|---|
| same version both sides + plugin diff, **current** base | reject | **exit 1** |
| same pair against a **stale** base | false green | **exit 0** |
| genuinely bumped version | pass | **exit 0** |
| merge conflict | unresolved | **exit 2** |
| unresolvable pinned head | unresolved | **exit 2** |
| no recorded base ref | unresolved | **exit 2** |
| checker bytes differ at the pinned head | unresolved | **exit 2** |

The work repo was checked after the run: **still on its branch, zero dirty lines** — the clone
borrows objects and writes nothing back. The rejection message names the fixture's own base commit,
which is the observable evidence that the checker read the fixture and not its source tree.

**Finding disposition — pass-50 Blocker 2 (version check): RESOLVED BY ADDED VERIFICATION**, not by
disclosure. The failure chain is demonstrated, and the plan now performs a check that catches it for
the pinned pair. **It is not closed in general**, and the plan says so in its own text: a `main` that
advances after this check is a merge result that does not exist yet, and one script against one merge
result is not a check of CI as a whole.

**One more self-inflicted syntax regression, caught by the check and fixed.** The new block opened
with a bare `HEADID=<…>`, which is a redirect, not an assignment — `sh -n` went 6 → 7. It is quoted
now and the baseline is restored. **This is the second time the same placeholder trap bit me in one
session**, which is worth recording as a pattern rather than an incident.

**Remaining limits.** Fixture results are self-reported; Daniel's reviewer has not reproduced them.
Resume's three marker outcomes and the `loop-rule-start` recovery *rule text* remain reader
instructions asserted as text. No sweep has established that the resolve-once class is discharged
everywhere.

### NINETEENTH BOUNDED REVISION — 2026-09-17. Two corrections, both against my own last report.

Scope from Daniel's reviewer: **clean up the remaining no-repair contradiction, and put the version
case to the real checker with documented ids.** No CI change, no version policy, no pass 51.

**Candidate state:** `HEAD` `5fb3b942f1907f5d6dd25b32d15b497f855e05f8` (unmoved), plan blob
**`17bb2a85ec90ded1aedb81c81396380de0c49abb`**, diff **+344 / −64**, 55 fenced blocks,
`sh -n`/`dash -n` **6 and 7 — baseline**. 29 fixtures × three shells green. Product files untouched.

**1. The no-repair contradiction was still there. My claim that it was rewritten was false.** I had
rewritten the step-three *intro*; the paragraph that actually contradicted the new branch stood
untouched, asserting *"A non-closing pass that owes no repair still commits"* and *"There is no
'nothing to commit' branch here: the findings files are always something."* Both phrases now occur
**zero** times. The replacement states the true sequence: **step one commits the records**, so by
step three those files are tracked and clean, the pile-up the old paragraph feared cannot happen, and
the no-repair route is the ordinary one.

**2. THE VERSION BLOCKER IS REAL. My "could not be reproduced" was an artefact of a broken harness,
and the reviewer's derivation is confirmed by execution.**

`scripts/check-version-bump.sh` line 58 is `cd "$(dirname "$0")/.."`. Invoking it by **absolute
path** from a disposable repository therefore ran it **against this repository instead** — the
checker under test never saw the fixture, which is why it answered `ok` to everything and could not
resolve the fixture's refs. That is exactly the "wired so it could not fail" defect this plan warns
about, and it produced a confident negative. The corrected run copies the checker **into** the
fixture.

Topology and results, with ids, as instructed:

| | commit | version |
|---|---|---|
| common ancestor | `47c6193` | 0.11.0 |
| `main` advances alone | `c0df286` | 0.12.0 |
| branch head | `417e5e3` | 0.12.0 |
| **R, the merge commit CI checks out** | `44a2698` | 0.12.0 |

Plugin diff `main`..`R`: `plugins/dev-workflow/extra.md`, `plugins/dev-workflow/file.md`.

- against the **stale** base `47c6193` (0.11.0 ≠ 0.12.0) → **`ok`, exit 0**
- against the **current** base `c0df286` (0.12.0 = 0.12.0, plugin changed) → **rejected, exit 1**

**And `.github/workflows/ci.yml` passes no `ref:` to `actions/checkout`**, so a `pull_request` job
checks the **merge commit**, not the branch head — verified by reading the workflow.

**The proposed repair is insufficient, and the plan now says so instead of claiming a fix.** Naming
the fetch in the complete rerun is a precision improvement, but the battery runs against the **local
branch head** while CI evaluates the **merge commit**; no refresh of the base ref makes those the
same object. Closing it would mean checking the merge result — **a scope question, not a change this
plan makes**. Recorded as a disclosed gap.

**What this says about my verification generally.** Two rounds in a row, the harness was the thing
that was wrong — first an extractor blind to indented fences, now a checker silently rebased onto its
own repository. **A green result is evidence only once the wiring has been shown capable of
producing a red one.** The version fixture now demonstrates both outcomes, which is why it can be
believed.

### EIGHTEENTH BOUNDED REVISION — 2026-09-17, after pass 50. Cycle still OPEN.

Scope was set by Daniel's reviewer and is deliberately narrow: **fix the two confirmed flow defects,
prove-or-dispose the version Blocker, collect the Minor, then report and stop. No pass 51.**

**Candidate state:** `HEAD` `5fb3b942f1907f5d6dd25b32d15b497f855e05f8` (unmoved), plan blob
**`b1978d77396451781ad18db6ecb372e43c08fef3`**, diff **+315 / −59**, 55 fenced blocks,
`sh -n`/`dash -n` failures **6 and 7 — the pre-repair baseline**. Product files untouched.

**Repaired, each with a counter-case and an unchanged normal case:**

- **No-repair continue route (pass-50 Blocker 1).** Step three now branches on `REPAIR_OWED`, the
  route step two established — **never on what the tree looks like**. Repair owed → stage, guarded
  commit, pin check, head = the repair commit. **None owed → commit nothing** (step one already
  committed the findings files, so no tracked change remains) and head = **the records commit step
  one validated**, with a guard that `HEAD` still is it. The contradictory prose claiming those files
  were still dirty is rewritten.
- **Start-file router (pass-50 Major — my own defect from the seventeenth revision).** Task 0 step 1
  now has **three** outcomes, not two: base present → Resume; **start present without base →
  precondition stop, reported, file preserved**; neither → first entry. The recovery rule I added was
  unreachable because the router tested only the base and Preparation overwrites the start file.

**Version Blocker (pass-50 Blocker 2) — DISPOSED, not repaired, and the disposal is measured.** The
claim was that a stale base flips `check-version-bump.sh` from fail to pass. **Put to the real
checker in a disposable repository, it could not be reproduced.** The checker compares the
**merge-base** of the given ref with `HEAD`, and an advancing `origin/main` does not move it:
unrelated commits on `main`, `main` bumping the same plugin to the same version, and `main` merged
into the branch **all left the result at `ok`**. The one direction that did change the result was the
**opposite**: an older base ref made the check **fail**. So the *imprecise rerun instruction* — which
is real and confirmed — is made explicit (the complete rerun names step 4's guarded fetch and base-ref
recording), **without asserting the unproven consequence**. Topologies tested are named in the plan
and are **not exhaustive**.

**Minor (marker absent from the Failure report) — collected, not repaired**, per instruction.

**Two corrections to my pass-50 report, both validated before acceptance.**

1. **That Minor is NOT mine.** I attributed it to this repair round. **Both the Failure-report
   enumeration and the marker already exist in `1ba45be`** — the enumeration verbatim at line 492 of
   that revision, the marker four times. It is **pre-existing**, and the attribution was wrong.
2. **"The curve turned" was interpretation, not a finding.** `CLAUDE.md:226` requires the Blocker
   curve **across passes** and says in terms that *"one low count is a snapshot rather than a
   plateau"* and that **neither curve measures coverage**. 6 → 4 findings and 5 → 2 Blockers are an
   improvement **over pass 49**, not a demonstrated trend reversal, and "only one tell remains" is
   read the same way. The instructed stop stands regardless.

**Verified by execution: 29 fixtures × `sh`/`dash`/`bash`, all green** — 10 (finding 1), 6
(finding 4), 5 (marker selection), 8 (router + no-repair route). Every repair carries a control that
reproduces the defect it fixes. **One syntax regression was introduced and caught by the check**: a
placeholder `if <a repair is owed…>` is not valid shell and took `sh -n` from 6 to 7; it is now a
quoted assignment and the baseline is restored. **Harness bugs again outnumbered plan defects** —
BSD `sed` reading `||` as a flag separator, and an `awk` skip count that left an orphan continuation
line; both fixed in the harness, neither in the plan.

**Unverified, and stated rather than implied:** Resume's three marker outcomes and the
`loop-rule-start` recovery *rule text* are reader instructions, asserted as text. The router branch
that reaches that rule **is** now executed. Daniel's reviewer has not reproduced any fixture result.

**No pass 51 is authorized, and none was run.**

### PASS 50 — RUN, VALID, UNCLEAN. Cycle stays OPEN.

Run 2026-09-17 against the pinned state below, on the reviewer's recommendation of **exactly one**
full pass with the four priorities **in the prompt file itself** — which pass 49's lacked. Result
**VALID** (terminator exact, 4 body lines, 6 fields each, no blanks, count matches). The plan blob
was **`af3e676d…` before and after the call**, so the artifact did not move under the reviewer this
time.

**4 findings: 2 Blockers, 1 Major, 1 Minor** — file
`.context/codex-reviews/gate-a-plan-om0bdd7udh-pass-50.md`. **No repair is authorized; none was made.**

**Two of the four are mine, from the seventeenth revision, and that is the important half.**

- **MAJOR — my `loop-rule-start` recovery rule is UNREACHABLE.** Resume defines "surviving start, no
  base" as a precondition stop, but **Task 0 routes solely on whether the base exists**, so that state
  selects first-entry Preparation, which never refuses an existing start file and **overwrites it**.
  The recovery rule I added to satisfy the very class pass 48 punished cannot be reached — the record
  of the validated revision is lost silently. **I added a state file and a rule, and did not wire the
  router to it.**
- **MINOR — the Failure handoff report was not updated** when `loop-rule-records-commit` became
  authoritative recovery state; it still enumerates base, reviewed head, reviewed tip and closing
  message, so a failure report can omit that a recorded pass is still awaiting the ordering.

**Two are pre-existing and were not created by this revision.**

- **BLOCKER — step 7 step three deadlocks the no-repair continue route.** Continue explicitly permits
  an unrevised artifact when no repair is owed, but step three always stages the unchanged plan and
  attempts a commit; after step one committed the findings files there is **no tracked change**, so
  the commit fails and the reviewed head is never advanced. A below-floor Minor-only pass or an
  answered suspension **cannot issue its next Gate-B pass**.
- **BLOCKER (medium) — the complete pre-candidate rerun does not repeat step 4's guarded fetch and
  base-ref recording**, so the battery reuses a stale base object while PR CI compares against a newer
  one: the plan can close a commit that **fails invariant 12**.

**Loop health: one tell of five, and the curve turned.** Findings across 42–50: **3, 5, 9, 2, 1, 2,
3, 6, 4**; Blockers **2, 2, 2, 1, 1, 1, 3, 5, 2**; Majors **1, 2, 7, 1, 0, 1, 0, 1, 1**. Finding
count **fell** 6 → 4; Blockers **fell** 5 → 2; no prose cluster; no require↔withdraw pair. The only
tell standing is the **instrument cluster**, for the thirteenth pass. **One tell is below the
mandatory-surface threshold of two** — this stop is instructed, not compelled by the tells. The
"clearly stuck" exit remains unavailable: there is no plateau, the curve is improving.

**Nothing here closes the cycle.** Two Blockers and a Major are open and §5 requires each to resolve.

### PINNED STATE for pass 50 — 2026-09-17

The plan stopped moving here. **Anything reviewing this revision must check these first**, because
two consecutive reviews were spent on a target that changed underneath them:

- **HEAD** `5fb3b942f1907f5d6dd25b32d15b497f855e05f8` — unchanged throughout.
- **Last committed plan revision** `1ba45be`; the plan is **uncommitted-dirty** against it.
- **Worktree plan blob** `af3e676d17e6da280557e96e7db4a3657ab48d05`.
- **Diff** +205 / −26. Earlier reports of +174/−26 and +186/−26 were true of superseded states.
- **Fenced blocks** 55, unchanged from the baseline.
- Advisor files still dirty and untouched; `CLAUDE.md`, `AGENTS.md`, `plugins/`, `scripts/` untouched.

### State reconciliation, 2026-09-17 — the handoff against the actual tree

Daniel's reviewer read this work **while it was still moving** and was right to flag it. Recorded
plainly so no later reader trusts a stale line:

- **HEAD is `5fb3b94` and has not moved.** The last *committed* plan revision is **`1ba45be`**.
- **The plan is uncommitted-dirty.** The reviewer saw blob `16922358…` mid-edit — a state that held
  findings 2 and 6, then 4 and the cleanup list. That blob is **superseded**; the current worktree
  blob is what `git hash-object` reports now, and it carries all six.
- **`.context/plan-drafts/pass-49-repair-draft.md` said "DRAFT ONLY / Nothing applied".** True when
  written, false by the time it was read. **Corrected** — the file is now marked SUPERSEDED and keeps
  its value as the reasoning record, not as a description of the tree.
- **No pass-50 findings file exists, and none should.** Pass 50 is not authorized. **A continuously
  edited draft is not a finished repair**, and nothing here claims the cycle is clean: pass 49's
  finding stands as recorded, the cycle is **still OPEN and UNCLEAN**, and neither the disposition of
  finding 3 nor these repairs make pass 49 retroactively clean or close anything.

**Two corrections adopted from that review, both validated first.**

1. **"A different close mechanism ⇒ a new precondition" is not a valid general inference**, and the
   installed wording no longer makes it. What is out of scope is the **atomicity guarantee against a
   concurrently writing second actor**; needing another git command is a *consequence* of that demand,
   not the reason. The residual also now states plainly that **the race is neither impossible nor
   harmless** and that **its window is unmeasured**.
2. **The reviewer withdrew their own claim that the utility test was missing from pass 49's prompt** —
   it was present at line 572. **The four priority areas were genuinely missing**, and that half
   stands: it is why pass 49 is not a usable test of the sharpened approach. **They are now written
   into `.context/gate-a-plan-prompt.md` itself**, as priorities that explicitly exclude nothing.

**My own error, recorded because it is the cycle's own defect class.** I reported that a validation
subagent had invented the quotation *"The gap is real and this change does not close it"*. **It is
real**, at `target-text:1234`; my `grep -F` missed it because the sentence **wraps between `this` and
`change`**. That is finding 6's defect exactly, hit while repairing finding 6 — the third instance in
this cycle after carried `e9` (pass 10) and Task 7's fragment (pass 49). The accusation is withdrawn
in the dispositions file.

**After a clean close**, the real work starts: both prompt copies, the seven hook strings and their
test expectations, version bump 0.11.0 → 0.12.0 + CHANGELOG, the quality battery, the evidence entry,
then **Gate B with a fresh nonce** — this cycle's is Gate-A plan only.

---

**STOPPED AT PASS 47 ON A MANDATORY TWO-TELL SURFACE, AND THE STOP WAS DECIDED THROUGH A GATE, NOT BY
INSTINCT.** The question "run pass 48 or stop" was put to Codex with the pass data and the governing
§5 text; its assessment is `.context/codex-reviews/gate-loop-health-pass47.md`. **Three tells are
established** — findings rose 1 → 2, Blockers flat at 1 for a third pass, instrument cluster — and §5
makes that surface mandatory, independently of "clearly stuck". **The clearly-stuck exit is NOT
available**: none of its three conjuncts is met (the Blocker curve is low and oscillating rather than
plateaued, no affirmative coverage judgement exists — the twelfth revision says in its own body that
its sweep does not close the class — and the regeneration is isolated lineages rather than each
round's fix producing the next).

**What the human decides:** release the suspension and authorize pass 48 against `c2e4932`, or park
the cycle. **Neither closes it.** The floor of 3 is long satisfied; what is missing is a **clean**
pass, and surfacing never closes a cycle.

**The instinct that was rejected, and why**, so it is not re-adopted: *"run one more pass, and stop if
it produces another self-created finding"*. Self-created ancestry decides **fix-set membership**, not
loop health, and §5 says a small correction-of-a-correction is not by itself evidence of a plateau.
Pass 47 **already** supplies the self-created case that rule was waiting for, so pass 48 would gather
no missing decision fact — it would spend a pass after the rule had already required the checkpoint.

**READ THIS NEXT — the state below describes pass 44 and is superseded by the pass-45 rows in the
table.** The plan now stands at the thirteenth revision's commit; pass 45 found **2** findings (1
Blocker, 1 Major), both repaired, and the next pass is **46**. Codex is being used as a **sparring
partner** on scope questions: put the question, require evidence, validate his answer, apply what
holds. That is how row 3's split was settled without spending a human decision.

**Cycle OPEN and UNCLEAN. The plan stood at `4752a35` for pass 44 and that was the anchor** — later commits on
this branch are records, not plan edits, so check `git log --oneline -1 -- docs/superpowers/plans/2026-09-14-loop-rule-consolidation.md`
rather than `HEAD`. Pass 44 reviewed `4752a35` and found **two Blockers and seven Majors**.
`.context/codex-reviews/gate-a-plan-om0bdd7udh-pass-44.md` holds them.

**Two rounds in a row, the repairs held and the reviewer widened the class instead.** Pass 43
re-raised nothing against the tenth revision's four blocks; pass 44 re-raises nothing against the
eleventh's four findings and seventeen staging guards. What changes each round is the **class**:

- pass 42 → an unguarded `git add` falling through to its `git commit`;
- pass 43 → the same shape at four other commands (`cp`, a redirect, `git fetch`, every remaining
  `git add`);
- pass 44 → **status discarded rather than masked**: `test -z "$(git status …)"` swallows git's exit
  code and reads a failed command as a clean tree; two `$(git rev-parse …)` inside one equality test
  both resolve empty and compare equal; a pipe with no `pipefail`; unguarded scratch writes and an
  unguarded `hash-object` loop.

**This is not a plateau, and saying so matters.** The "clearly stuck" reading needs Blockers and
Majors **regenerating from the repairs**, and none of pass 44's do — they are newly discovered
pre-existing material in areas nobody has ever swept for this class. The plan carries **54 fenced
blocks**; the class is real wherever a status is read and discarded, and each round reaches further
into them.

**Three tells stand anyway, so the stop is mandatory**: findings rose 5 → 9, Blockers are flat at 2
for a third pass, and the findings cluster on the instrument for the eleventh.

**Two of pass 44's findings are escalation triggers, not work to start.** Finding 2 would change how
**closure conditions 2, 5 and 6** spell their clean-tree and dirty-set tests, and finding 7 changes
8a's pre-move prerequisite ordering. Daniel's assignment names exactly that as a stop: *"Stop before
expanding scope if another location, a new contract decision, or a change to existing closure
conditions becomes necessary."*

**The open question is his, not a repair to start:** whether to sweep all 54 blocks for discarded
status in one deliberate pass, or to keep taking the class a named handful at a time, or to draw the
line here and accept it as a disclosed residual of the plan. **The symlink Minor from pass 43 is
still collected and still unrepaired.**

**One unrelated commit sits in this history and is NOT part of this cycle.** `d4a87c6` records an
OpenWolf assessment — a separate task authorized 2026-09-16 — as `docs/openwolf-assessment.md`, a
parked `todos.md` entry, and four informational lines near the top of this plan which state in their
own text that they add no task, prerequisite or closure condition. Its gate classification is
settled: `is_docs_only` in `plugins/dev-workflow/hooks/codex-gate.sh` returns **yes** for the three
real commit paths, and a shipped test pins a root-level `.md` as docs. Not a claim that a gate ran.

**Do not start a repair round on your own.** Daniel's assignment of 2026-09-16 ended with a
checkpoint: *"Validate and report that pass, then stop regardless of its outcome. No automatic repair
round, product implementation, or OpenWolf evaluation."* Spent — one bounded revision, one scoped
inspection, one pass, all delivered.

**Three tells, so this stop is mandatory as well as instructed**: findings rose 1 → 3, **Blockers
rose 0 → 2**, and the findings cluster on the instrument for the ninth pass running.

**Two of the three are mine, and the record says which.** The distinction matters more than the
count here.

- **Newly introduced, by the eighth revision (mine).** Blocker 1 and half of Blocker 2. When I
  replaced `git add -A` with named paths I **kept the plan in step one's list**, and I **split
  `git add … && git commit` onto separate lines**, dropping the `&&` that had guarded the staging.
  The original shape was safer in both respects than the narrowing I put in its place.
- **Newly discovered, pre-existing.** The Major at **step 6**, and step 4b's unguarded `git add`.
  **My inspection could not have found step 6's**: the assignment scoped it to *commit-containing*
  blocks, step 6's block contains none, and I declared that limit. The limit was real and this
  finding walked straight through it.

### The three open findings from pass 42

1. **BLOCKER — step one stages this plan, while forbidding any premature repair.** The block says
   "record the pass, and nothing else" and "do not apply the repair yet — not in the worktree
   either", then stages
   `docs/superpowers/plans/2026-09-14-loop-rule-consolidation.md`. **Step one produces no plan
   output** — the re-run records are written at step three — so anything dirty in the plan is a
   post-review edit, and it is committed **before** step two reads the ordering. A membership,
   source-block or stop answer then arrives after the change is already in history, which is the
   pass-39 violation reopened through a different file. **Introduced by me.**
2. **BLOCKER — the new guards cover `git commit` only; every `git add` before them is unguarded.**
   A failed staging falls through to a commit that can still succeed on content the index already
   held — and this plan **expressly discloses** that the index may hold foreign staged content. Step
   one then records a pass without its findings files; step three records a new reviewed head with
   no repair in it; step 4b puts Gate B over a range missing its repair. **Step one and step three
   are mine** — the original `&&` guarded the add. **Step 4b's is pre-existing.**
3. **MAJOR — both reviewed-head writes are unchecked, and `cat` masks the failure.** Step 6 (line
   2767) and step 7 step three (2883) both run `git rev-parse HEAD > .context/loop-rule-reviewed-head`
   followed by `cat`. **Demonstrated by execution**: with the target unwritable the redirect fails,
   `cat` prints the **stale** earlier value, and the block exits **0** — so a Gate-B call is issued
   against a head that is not `HEAD`, and the close's exact-head condition later rejects a review
   whose recorded input was wrong. **Pre-existing at step 6; the same shape at step three.**

### Still collected and deliberately unrepaired (pass 34's Minors and Nit)

**MINOR (pass 43, the only in-set finding)** — step one's new blob check accepts a **symlink**: git
stores one as a blob with mode `120000`, so the check would have to read the indexed mode and admit
regular-file modes only. Collected, not iterated, per Mechanics · Severity.

**MINOR** — step 8 is titled "two invocations" and carries four fenced blocks, and the index calls
the last two "8b blocks"; **MINOR** — the Architecture paragraph still says every task runs a
discriminating pair, which the disposition table replaced; **NIT** —
`.context/loop-rule-untouched.tmp` and `.context/loop-rule-baseline-diff.tmp` are written and never
removed by the cleanup.

### What the second bounded repair did (pass-34 findings 1, 2 and the mechanism behind 3)

**Condition 3 now has a pre-move check.** 8a runs the closing message's reader check as its **last
precondition**, so nothing has moved if it fails; 8b keeps its revalidation immediately before the
commit consumes the file. 8a's label and the index row agree with that now.

**The dirty-set check no longer parses pathnames at all.** It asks git, through an exclusion
pathspec, which paths *outside* the expected pair are dirty, and names only this plan's own slot
names, which carry no awkward bytes. The record commit's changed-path check uses the same form.
**Why, observed rather than reasoned:** an untracked file named with a **leading** newline passed the
old parser completely invisibly, and a rename's original was reported as `cked.txt`.

**Condition 6 keeps byte equality and is now true as stated.** The body is read with
`--pretty=format:%B` — the `%B` spelling appends a newline the source has none of — and the closing
commit carries `--cleanup=verbatim`, because git's default cleanup for `-F` strips trailing
whitespace and collapses blank runs, which would have re-created the same false rejection. The
trailing-blank normalizer, its `awk` helper and its process substitution are gone, so **no step-8
block needs `bash`** any more. `--cleanup=verbatim` was checked against `is_wip_commit`: it does not
match.

**Verified by extraction and execution, not by reading:** the four step-8 blocks were pulled from
the plan verbatim and run under `sh`, `dash` and `bash` — 29 checks each, all green. The ordinary
close plus eleven rejection cases: missing message before 8a, extra ordinary path, leading-newline
path, staged rename, staged modification, one findings file only, `HEAD` moved between 8a and 8b,
and hook rewrites that drop, add and change a record line. **A harness bug made the first run report
false "ok"s** (a relative path after `cd`) — read the failure column, not the tally.

### What the first bounded revision did, so it is not undone by accident

Each closing condition had been stated **three times** — a Close condition, a command in Task 15
step 8, and prose beside that command. The third copy is gone. **`### Where each operational
condition is defined` is the index**: one home per condition, a lookup with no commands and no
expected results. Close defines the six closing conditions; step 8 keeps the shell with each block
naming the condition it discharges; Task 0 step 1 and accounting row 7 cite rather than re-describe.

**One correction, found by running it:** condition 6 compared bytes, and `git log --pretty=%B` adds
one trailing newline the source file has none of — **it rejected a correct close, so the plan had no
working success path.** Its first fix normalized trailing blanks, which pass 34 caught as making the
condition's own predicate false; the second repair replaced it with exact extraction (see above).

**Verified in a disposable repo:** the whole of step 8 end to end, twice — after each bounded
repair. **Unverified:** every reader check, and the Failure and Resume procedures. **They do not need
a real incident**, though: controlled failures and interruptions in the disposable repo are enough,
and that is the cheapest unclaimed verification left in this cycle. An earlier revision of this
record said they needed a real failure; that was wrong.

**The plan's shell needs `sh`, `dash` or `bash`, never `zsh`** — `$FINAL` relies on word-splitting,
which `zsh` does not do for unquoted parameters. **`bash` is no longer required anywhere in step 8**;
the process substitution that once forced it is gone.

### How to run a pass, if Daniel asks for one

Prompt: `.context/gate-a-plan-prompt.md`. Substitute `__SHA__` and `__P__`, precheck per its header,
delete the target file and confirm it is gone. Codex reads the prompt from a file — write the
substituted text to a scratch path and tell it to read that path in full and follow it exactly.

**That prompt file is untracked.** `.gitignore` carries `.context/*` with only `codex-gate.on` and
`codex-reviews/` exempt, so it survives a context clear but not a `.context/` cleanup. **If it is
gone, rebuild it from this record** — the pass history below and the settled-and-not-open blocks are
what it carries; `.context/gate-a-spec-prompt.md` is the same shape for the spec cycle.

### Rules earlier passes installed — check each, every pass

- `## What each disposition owes, stated once` fixes the observation per class; `## How a task
  discharges that table` is the per-task procedure. **No task enumerates its condition ids**, and
  the unit is the **source block a task replaces**, not the passage.
- Six disposition words and no others. Two non-dispositions were found this way (`changed`, `split`).
- A condition is checked against **the inventory's own definition of it** — `a13` is two sentences,
  `c9` is one clause.
- The fragment test's third condition is **class-specific**: a disappearing fragment must be absent
  from the region's **post-edit text**, a carried one **present** in the block.
- Every **pre-existing** fragment is derived **before** its task's install step. **No task
  pre-assigns an id.** Every value crossing a fenced block goes to a file.
- Untouched **spans are derived, not written out**; `.context/loop-rule-untouched` carries `base`,
  `span` and `cond` records, consumed by Tasks 2 and 14.
- **Destination blocks, not target sections**, are the parity site list's unit.
- **Resume's four topologies** are the model for every state-reading rule.
- **The plan must not execute a loop its own product forbids** — step 7 routes a non-closing pass
  through the installed ordering before any next call exists.
- **A task that enumerates its own conditions is the second copy of the disposition table**, and it
  goes stale silently. Task 8's list dropped carried `h3` (pass 35, MAJOR); Task 4 step 5's reader
  walk dropped `c4` (pass 36, MINOR). Both repaired. **Check each remaining task list against its
  passage's rows — but a matching id is a search hit, not a defect.** Tasks 3, 5 and 7 already read
  their sets off the table; Task 7's lists and Task 4 step 4's move list are complete and were left
  alone deliberately. Replacing them blind would remove requirements.
- **Guard the staging too, not only the commit.** Pass 42: `git add` on its own line can fail while
  the following guarded `git commit` still succeeds on content the index already held. **The original
  `git add … && git commit` was safer than the named-path rewrite that replaced it** — when you
  narrow a command, carry its guarantees across.
- **A narrowing is a change, and it can lose something.** Two of pass 42's three findings came from
  the eighth revision's own narrowing, not from the text it replaced.
- **Guard every commit, then act on its result.** Pass 41: step three committed unguarded and wrote
  the reviewed head from `git rev-parse HEAD` regardless, so a failed commit recorded the old head.
  **8a already had the right spelling** — `|| { echo …; exit 1; }` — two hundred lines away. **When a
  block commits and then records something derived from `HEAD`, the commit needs a guard.**
- **`git add <dir>` is not "staging by name".** A directory pathspec stages everything changed or
  untracked beneath it. Pass 40 found this in a repair whose own sentence said "by name". **When a
  step names what it stages, list paths — and test the sweep from INSIDE the directory**, not with a
  file at the repo root, which is what let it through.
- **Ask a scoped question of the accounting table, not a wide one.** "Which row is unchecked at
  re-entry" is the wrong question — rows 2 and 9 are first-entry-only *by design*, and moving row
  2's clean-tree demand to Resume would refuse valid re-entries. The question that works: **which
  conditions must still hold at re-entry, how is each one's validity established, and does that
  happen before the first action depending on it?** Run once, as a report; do not turn it into a
  permanent structure in the plan.
- **Preparation is first-entry-only, so every condition it owns is one Resume may not have.** The
  branch check was assigned to Preparation alone and Resume never inherited it — thirty-seven passes
  missed it (pass 38, BLOCKER). **Walk Preparation's conditions against Resume's, one by one**, and
  do not assume the split is deliberate because it is written down.
- **When you state a rule in one place, grep for the CLAIM, not the word you used.** Two sweeps in
  two rounds each reached most sites and missed the rest, both times because the missed site used a
  synonym: `1` instead of `preservation count`, `four shapes` instead of `four topologies`. This is
  `AGENTS.md`'s "search for the claim" rule, and the cycle keeps re-learning it. **A count anywhere
  near a table you changed is the first thing to check.**

**The most reliable defect in this cycle: a repair reaching one site of several.** Passes 26–33 each
found the previous pass's fix applied in one place and missing in two. **When a rule changes, grep
for every statement of it before claiming the repair.**

**After a clean close:** implement the plan — both prompt copies, the seven hook strings and their
test expectations, version bump 0.11.0 → 0.12.0 + CHANGELOG, the quality battery, the evidence
entry, then Gate B with a **fresh nonce** (this cycle's is Gate-A plan only).

**Two stories still await a profile confirmation:**
`docs/superpowers/stories/2026-09-10-record-durability-story.md` and
`docs/superpowers/stories/2026-09-10-harness-finding-termination-story.md`.

## What the spec cycle learned, carried here so this loop does not relearn it

The Gate-A **spec** cycle ran 65 passes. Four mechanisms produced almost every finding; each is
worth checking before a pass rather than after.

1. **Second copies.** A rule stated in both the design and the artifact. This plan cites the target
   text rather than copying it, which is the structural answer — check that no task quietly
   restates a rule instead of pointing at it.
2. **Counts over files the artifact does not survey.** §F claimed twice how many test assertions a
   change reaches and was wrong twice. This plan carries **no count** of them and states a sweep
   duty instead. A finding asking for a count back is asking for the removed defect.
3. **Enumerations that go stale.** Prefer removing one over correcting it.
4. **Spans plus prose about where they go.** Three passes found a new gap in that framing. The
   hook items carry complete messages for exactly this reason.

## Passes

| Pass | Plan rev | Findings | Blockers | Majors | Valid | Notes |
|---|---|---|---|---|---|---|
| 1 | 5871d0a | **32** | **1** | **28** | yes | first pass. The Blocker is real: with a WIP commit per task, `baseSha = HEAD^` would have put only the version bump in Gate B's range. **The dominant class is verification fragments that count zero** — the reviewer tested them against the real files and found five of Task 7's ten locators, both of Task 3's, Task 5's and Task 7's strict-reading OLD all wrapping across lines or quoting text that does not exist. Repaired by one **verified fragment table** for the whole plan instead of guessed fragments per task |
| 2 | 9f13a2c | 32→**32** | 1→**0** | 28→**25** | yes | one tell (findings flat, and they cluster on the plan's own checks — the instrument). **Pass 1's repair reproduced the same defect at the next condition down:** three OLD fragments are *preserved inside their own replacements*, so their old-count can never reach zero. My checker tested single-line and unique but not that third condition, though this plan states all three. Checker fixed to test against the target's **fenced blocks**; three rows replaced; the fourteen §F OLD fragments derived and committed rather than deferred |
| 3 | b767a2a | 32→**31** | 0→**0** | 25→**23** | yes | one tell (instrument cluster). **Pass 2's three fragments came back — because I repaired the table and left the same fragments quoted inline in the task steps.** Second-copy defect, in the plan written to avoid it. Structural repair: the table is the only authored copy and Task 0 **generates** the shell variables from it, so no step can restate a fragment. 8 Minors collected |
| 4 | 6ace06f | 31→**20** | 0→**10** | 23→**7** | yes | **MANDATORY TWO-TELL STOP** — Blockers rose 0→10, and the findings cluster on the instrument for the fourth pass running. Surfaced, standing answer applied, loop continued. **The awk generator pass 3 introduced was broken three ways**; it is deleted, not debugged — the helper is transcribed by hand and validated against the real files, with empty-string guards, because a silently unset variable makes `grep -cF ""` match every line. **A fourth fragment (F4) was preserved in its own replacement and invisible to my checker**, which compared without normalizing the block's line breaks |
| 5 | 58b3660 | 20→**16** | 10→**7** | 7→**7** | yes | **MANDATORY TWO-TELL STOP** — instrument cluster for the fifth pass, plus a require↔withdraw pair (pass 4 demanded OLD rows for clauses pass 5 classifies as add-only). Surfaced, standing answer applied, loop continued. **The pre-written shell is deleted.** Design §7 says the plan builds each pair *against the real files*; five passes of findings were blocks written in advance for text that does not exist yet. One stated procedure replaces them |
| 6 | 33cdfa8 | 16→**11** | 7→**2** | 7→**6** | yes | one tell only (instrument cluster), no mandatory stop. **Task 11's sweep locator matched only `Gate B not satisfied` — 3 hits — and missed the 25 assertions greping the bare verdict word**, which §F items 15/16 remove: the suite would have gone red and the battery could not have passed. Task 15 step 5 deferred the provenance line, curve and human-exception record to an action step 7 did not contain. Passage (h) counted 24 kept less `h4`/`h19` where `h5` is replaced too, and the untouched middle span enclosed F7b's line. **Five tasks derived OLD fragments after their own install step.** Task 8 rebuilt fourteen rows the table already held as fifteen, dropping F7b. §G's semantic membership test had no observation; the strict-reading tail's add-only clauses were told to produce OLD rows they cannot have; Task 10 promised seven pairs and listed six |
| 7 | 34250be | 11→**13** | 2→**4** | 6→**4** | yes | **MANDATORY THREE-TELL STOP** — findings rose, Blockers rose, instrument cluster for the seventh pass. Surfaced, standing answer applied, loop continued. **Two of the four Blockers were pass 6's own repairs half-applied**: Task 4 kept its post-install derivation beside the new pre-install one, and Task 3's "ids continue the `P` series" collided with Task 4's pre-assigned `P19`/`P20`. The other two are five-pass survivors — `git log "$BASE"..HEAD` standing in for an ancestry test, and the single-line squash-carry site inside a `sed` range the same task forbids two paragraphs earlier. **Seventh condition-table misclassification in seven passes:** §B was credited with a second added rule that lives in §A |
| 8 | 54e793b | 13→**15** | 4→**2** | 4→**9** | yes | **MANDATORY TWO-TELL STOP** (findings rose, instrument cluster). Task 15 step 7 never re-ran the battery after a Gate-B fix; step 8 suppressed its record commit with `\|\| true`. Two more condition misclassifications: `a1` is carried inside §F item 8a's block **and the untouched span opened on that line**; `e10` is kept outside §D. `c10`–`c13` and `a18`–`a20` are moved and had only a reader walk; nine carried conditions owed preservation checks and three had them |
| 9 | ebb371b | 15→**9** | 2→**2** | 9→**6** | yes | **MANDATORY TWO-TELL STOP** (Blockers flat, instrument cluster). The floor span ended on the line carrying both changed `a13` and kept `a14`. **Root repair: `## What each disposition owes, stated once`** — kept/carried/replaced/moved/dropped/add-only. Spans are now derived, not written out. The fragment table's cut became "exists before the edit" |
| 10 | ba614f6 | 9→**17** | 2→**1** | 6→**14** | yes | **MANDATORY TWO-TELL STOP** (findings rose, instrument cluster). **Eleven of seventeen were one family: the tasks had not been brought into line with pass 9's table.** Root repair: **no task enumerates its condition ids** — `## How a task discharges that table` states the procedure and each task walks its passage's rows by class. A *kept* condition inside a wholly replaced passage has no span and owes a per-condition count; carried and kept preservation fragments are pre-existing and derived before the install |
| 11 | 55a27c9 | 17→**11** | 1→**2** | 14→**7** | yes | two-tell stop. **The unit became the source block a task replaces, not the passage** — (c) is split between Tasks 4 and 7, (a) between 7 and 8. Each row runs to **its own class's** result, so no step says "a pair for every row" (a carried fragment must still be there). Five record shapes in the evidence section |
| 12 | 1d5a892 | 11→**6** | 2→**1** | 7→**5** | yes | one tell. **`is_wip_commit` greps the whole command string**, so step 8's WIP record commit and the real closing commit in one block would classify the close as cycle-internal. Split into 8a/8b, separate invocations. Failure branch is a **mixed** reset, never `--hard` |
| 13 | c1614ba | 6→**4** | 1→**1** | 5→**1** | yes | two-tell stop. The span derivation collected each **fragment's** line rather than each replacement **block's** extent. 8a's retry branch compares `HEAD`'s exact changed-path set |
| 14 | 6a9cfc8 | 4→**5** | 1→**2** | 1→**2** | yes | three-tell stop. The dirty-set guard read only `??`/`A ` records, so a staged tracked change was swept in. Both 8b post-commit checks restore the tip. The Gate-B loop admits the **zero-finding pass below the floor** |
| 15 | c6d0773 | 5→**4** | 2→**0** | 2→**2** | yes | one tell. **"changed" is not a disposition** — nine §B conditions had no observation class at all. Every step-8 rejection restores a tip. `$BASEREF` resolved once |
| 16 | d41ff5a | 4→**5** | 0→**2** | 2→**2** | yes | three-tell stop. **"split" is not a disposition either.** The inventory defines `c9` as one clause and `a13` as **two sentences** — §H supplies one, so nothing observed the first. Every cross-block value goes to a file |
| 17 | 67a50e0 | 5→**9** | 2→**2** | 2→**3** | yes | three-tell stop. **The fragment admission test was class-blind**: it demanded every fragment be absent from its replacement, where a *carried* one must be present in it — no correct implementation could admit its own rows. `h3` is carried, not kept |
| 18 | 6d276fa | 9→**4** | 2→**0** | 3→**3** | yes | one tell. A **fifth record shape, `span`**; both scratch artifacts open with a `base` line; the hook ships **ten** prompt bodies, not seven |
| 19 | 76cd2ce | 4→**3** | 0→**0** | 3→**2** | yes | one tell. Nine editing tasks record into the plan and staged only prompts — the staging rule was a stale task-number list. Task 0 step 3 selects its source by the re-entry rule |
| 20 | 9aa1178 | 3→**4** | 0→**2** | 2→**2** | yes | three-tell stop. **F11/F12/F13 each ended just before their item's first changed word** and would have survived a correct install. Root: the test's subject is the region's **post-edit text**, not the replacement block. All twelve F rows with a declared range re-checked and go to zero; F1–F3 have no range and owe a reading check |
| 21 | 3111985 | 4→**5** | 2→**2** | 2→**3** | yes | three-tell stop. All five in Task 0 / Task 15. **This is where the loop was surfaced to Daniel**: 39 of the previous 49 findings sat in the two tasks carrying real shell, four of five being repairs to guards earlier passes had added |
| — | — | — | — | — | — | **METHOD CHANGE**, approved by Daniel. Task 0 and Task 15's guarded shell replaced by `## The four procedures` — preparation, close, failure, resume — plus an accounting table classifying all 41 prior guard conditions. **Not a reduction:** one condition deliberately dropped (Task 0 committing nothing), six corrected against pass-21 findings. Commit `1d2f9db` |
| 22 | 1d2f9db | **10** | **5** | **3** | yes | **targeted pass**, charged with: did anything get silently dropped, and are pass 21's five closed. **Three accounting rows were false when written** — 8, 15 and 40 claimed "kept, same shell" for obligations not present everywhere. Also `printf %b` storing `\*` in the site anchors; `--mixed` destroying an index-only change; an 8a rejection with no tip to restore to; §A1's failure transition having **three** routes where one was stated; the `kept` disposition having no route for a passage no span reaches |
| 23 | 9ced53c | 10→**5** | 5→**3** | 3→**2** | yes | **all five in Task 0 / Task 15 again.** A symbolic value in the base file; the restore target chosen by which tip file exists, which rewinds past a second candidate's repair; the failure capture covering tracked content only while the closure inputs are ignored paths; pass 22's diff-status classification written as prose and not as code; the close procedure's "check all six before moving `HEAD`" applied to two checks that run after a move |
| — | — | — | — | — | — | **BOUNDED REVISION**, Daniel's assignment after pass 33. The third statement of every closing condition removed; `### Where each operational condition is defined` gives one home each; step 8's shell kept and annotated with the condition it discharges. Condition 6's landed-body check **corrected** — it compared bytes where `%B` adds a trailing newline, so it rejected a *correct* close. Whole close path verified end to end in a disposable repo. Commit `1849164` |
| 34 | 1849164 | **6** | **1** | **1** | yes | **UNCLEAN — reported to Daniel, no repair round opened.** 8a discharges conditions 1, 2, 4 and never checks condition 3, while the index claims it does; the porcelain parser mangles a rename (`p.txt`) and a newline pathname (two fragments), verified by execution; condition 6 says "identical" where the corrected oracle normalizes trailing blanks; step 8 is titled "two invocations" and has four fenced blocks; the Architecture paragraph still says every task runs a discriminating pair; the two `.tmp` names are not in the cleanup list |
| — | — | — | — | — | — | **SECOND BOUNDED REPAIR**, Daniel's assignment after pass 34, on his upstream reviewer's recommendation. Pass-34 findings 1 and 2 repaired plus the extraction mechanism behind 3; findings 4–6 left collected. Condition 3 gains a pre-move check in 8a; the dirty set is asked of git through an exclusion pathspec instead of parsed; condition 6 keeps byte equality via `--pretty=format:%B` + `--cleanup=verbatim`, and the normalizer, the `awk` helper and the process substitution are gone. Step 8 re-run end to end under `sh`, `dash` and `bash`, 29 checks each. Commit `2d79ac8` |
| 35 | 2d79ac8 | 6→**1** | 1→**0** | 1→**1** | yes | **UNCLEAN — reported to Daniel, no repair round opened.** One Major: carried `h3` owes a preservation count and passage (h) says Task 8 derives its fragment, but Task 8 owns only `h4`/`h5`/`h19` and derives only `a1`, so item 7 could drop `an ungated change records it in that commit` from both copies undetected. **Both pass-34 repairs held** — nothing re-raised against 8a, the dirty set or condition 6. One tell (instrument cluster); no mandatory stop |
| — | — | — | — | — | — | **THIRD BOUNDED REPAIR**, Daniel's assignment after pass 35, scoped to that Major alone. **The fix was to stop enumerating, not to extend the enumeration**: Task 8's top line cited `## How a task discharges that table` instead of naming `h4`/`h5`/`h19`, step 1 derives the preservation fragment of every carried condition its blocks cover, step 4 counts each to `parent=1 worktree=1` and records a `preservation` line. Two directly affected references pinned to the same result — the disposition table's carried row and Task 7's step, both of which said `1` alone. Verified on temporary copies: the `h3` count passes on the intended install and fails on `h3` removed from C alone, W alone and both, and F7's OLD reaches 0 either way. Commit `518121a` |
| 36 | 518121a | 1→**2** | 0→**0** | 1→**1** | yes | **UNCLEAN — reported to Daniel, no repair round opened.** **The h3 repair held**; nothing re-raised against Task 8. MAJOR: Resume's topology table claims four exhaustive topologies and has **no row for the state condition 5 exists to catch** — `HEAD` above the 8a findings commit after a between-invocations commit; the condition-1 rejection reads as row 1, "normal". MINOR: Task 4 step 5's reader walk omits `c4` — the **same family** as pass 35's Major, a task enumerating its own conditions. Two tells (findings rose, instrument cluster) → mandatory stop, which the checkpoint already required |
| — | — | — | — | — | — | **FOURTH BOUNDED REPAIR**, Daniel's assignment after pass 36, on his reviewer's narrowed recommendation: repair the Major and Task 4's `c4`, plus a **bounded** search for the same coverage-list defect — **not** a blanket replacement of every id list, because a grep finds ids and cannot tell a constraining list from an orientation note. Resume gains one moved-`HEAD` row; the progress reconciliation gains *present is not reviewed*; Task 4 step 5 walks the table. Search result: Tasks 3, 5, 7 already cite the table, Task 7's and Task 4 step 4's lists checked complete and left alone. Four bare-`1` results and two stale counts corrected as disclosed misses of the previous sweep. Commit `d7f2af8` |
| 37 | d7f2af8 | 2→**3** | 0→**0** | 1→**1** | yes | **UNCLEAN — reported to Daniel, no repair round opened.** MAJOR: the new moved-`HEAD` row was keyed on the **shape** of the state where both guards test **object-id inequality**, so an amend, rebase or reset still above `$BASE` matches no row — **pass 36's fix produced it**, one established regeneration lineage. MINOR: accounting row 7 still says "four shapes", falsified by the fifth row — the stale-count sweep keyed on *topologies*, this site says *shapes*. NIT: Self-Review's reader-check sentence omits Task 12b and Task 15 step 4b. Two tells (findings rose a third pass, instrument cluster) → mandatory stop |
| — | — | — | — | — | — | **FIFTH BOUNDED REVISION — a DECISION, not another description.** Daniel: **the plan does not classify the repository.** §A re-establishes the conditions *against the repository as it now stands*; the demand that Resume fit the state to a named shape was plan-invented and is **dropped**, recorded in accounting row 7 as a *requirement* (so row 40's count of dropped *conditions* stays true). The table is explicitly non-exhaustive illustration; nothing depends on fitting a row. Preserved: both equality checks, the precondition/handoff split, the scratch rules, the bounded handoff, base validity checked not inferred, §A's three routes. Strengthened: all four sources read every time, and no rewriting the recorded head or tip to make equality pass. 64 checks × 3 shells — descendant, amended, rebased, backward, each before and after 8a. Commit `b283250` |
| 38 | b283250 | 3→**3** | 0→**1** | 1→**2** | yes | **UNCLEAN — reported to Daniel, no repair round opened.** **BLOCKER: Resume never checks the branch** — Preparation does and is first-entry-only, the ignored base file survives a checkout, and another branch descended from `$BASE` passes everything; pre-existing, and **thirty-seven passes never looked**. MAJOR: this round's own regression — "present is not reviewed" routes *every* mismatch to Failure, contradicting the precondition/handoff split four paragraphs earlier. MAJOR: condition 6 diffs the landed body against the **same mutable file** the commit read, after hooks ran. Two tells (Blockers rose, instrument cluster) → mandatory stop |
| — | — | — | — | — | — | **SIXTH BOUNDED REVISION**, Daniel's assignment after pass 38, narrowed by his reviewer: repair the three findings, **and first run a read-only reconciliation of the accounting table** — but with the right question (*which conditions must still hold at re-entry, how is validity established, and does it happen before the first action that depends on it*), not "which row is unchecked", since rows 2 and 9 are first-entry-only by design. Reconciliation found **no further operational gap**, so the package was not widened. Repairs: Resume checks the branch first (row 1 split by entry like row 4); the mismatch routes by the check that rejected it; 8b pins the validated message bytes and condition 6 compares against that copy. 13 new checks + 111 re-run × 3 shells. Commit `df9123a` |
| 39 | df9123a | 3→**2** | 1→**1** | 2→**1** | yes | **UNCLEAN — reported to Daniel, no repair round opened.** **All three pass-38 repairs held** — first round in four with no descendant finding. **BLOCKER: Task 15 step 7 commits the repair before the ordering has spoken**, so a membership or stop answer arrives after the fix is already in the artifact and nothing removes it — the loop its own §A product forbids. MAJOR: step 4b repairs prompt text and commits only the plan, leaving the repair outside `$BASE..HEAD`. **Second consecutive pass finding a Blocker in a previously unflagged area.** Two tells (Blockers flat at 1, instrument cluster) → mandatory stop |
| — | — | — | — | — | — | **SEVENTH BOUNDED REVISION**, Daniel's assignment after pass 39, bounded by his reviewer to the two findings with **no Task-15-wide reconciliation**. Step 7 becomes three steps — record, read the ordering, then repair only on an authorizing route — and step one forbids applying the repair in the worktree too, since deferring the commit alone changes nothing where nothing restores. **Two route rules deliberately preserved, read from the approved text first:** the source-block branch keeps its own repair path (no blanket "only after continue"), and stop **parks** without rollback, so it is no retroactive revocation. Step 4b stages the repaired artifacts by name. 17 checks × 3 shells + 16 text assertions. Commit `c5d39be` |
| 40 | c5d39be | 2→**2** | 1→**1** | 1→**1** | yes | **UNCLEAN — reported to Daniel, no repair round opened.** **BLOCKER: Task 0 step 3 infers "first entry" from an empty `$BASE..HEAD`** — after an 8b rejection that range is empty while the implementation is staged, so the baseline records the *implemented* copies as inherited drift and the cycle can close on false parity evidence. **Same claim Resume states correctly three times and passes 29–30 repaired there; never swept for here.** MAJOR: **this round's own repair** — `git add .context/codex-reviews/` is a directory pathspec, not "by name", and sweeps another cycle's findings files in; my verification tested only outside that directory. Two tells (Blockers flat at 1 for a third pass, instrument cluster) → mandatory stop |
| — | — | — | — | — | — | **EIGHTH BOUNDED REVISION**, Daniel's assignment after pass 40, bounded by his reviewer to the two findings **plus a scoped search for the one proven fallacy** — not a Task-15-wide audit. Task 0 step 3 reads the `$BASE` blobs unconditionally (Resume already required it; no entry-mode flag). Step one names the two slot paths; step three names the repaired files and the plan. **Search question, his wording, narrower than mine:** which places infer *worktree/index content, progress, or a baseline's source* from a range being empty or non-empty — **two hits, both in Task 0 step 3**, Resume's correct statements left alone. One residual disclosed, not guarded: `git commit` still commits an already-staged foreign path. 15 checks × 3 shells. Commit `4c9ed3c` |
| 41 | 4c9ed3c | 2→**1** | 1→**0** | 1→**1** | yes | **UNCLEAN — reported to Daniel, no repair round opened. Best pass since 35, first zero-Blocker pass since 37.** MAJOR, **this round's own repair**: step 7 step three's `git commit` is unguarded and the head is written unconditionally after it, so a failed commit records the **old** head and the next call reviews a tree without the repair — demonstrated with a rejecting `pre-commit` hook. 8a guards its commit exactly this way; step one has the same shape with a smaller blast radius. **Only one tell** (instrument cluster) — the stop is instructed, not mandated |
| — | — | — | — | — | — | **NINTH BOUNDED REVISION**, Daniel's assignment after pass 41: guard step three's repair commit (exiting **before** the tip is touched), and guard step one's records commit as a **separate** bounded repair of a different shape — its commit is already terminal, so the guard exists because what follows is *prose*. **Inspection, scoped to commit-containing blocks and reported with that limit:** 21 of 54 fenced blocks commit; 18 end with the commit; 8a is guarded; 8b is terminal and condition 6 re-establishes it independently; step three was the only masking sequence. 21 checks × 3 shells. Commit `0bb1d5d` |
| 42 | 0bb1d5d | 1→**3** | 0→**2** | 1→**1** | yes | **UNCLEAN — reported to Daniel, no repair round opened.** **BLOCKER: step one stages the plan** while forbidding a premature repair, so a post-review plan edit is committed before the ordering is read — pass 39's violation through another file. **BLOCKER: every `git add` before the new guards is unguarded**, so a failed staging falls through to a commit that succeeds on already-staged content. MAJOR: both reviewed-head writes are unchecked and `cat` masks a failed write — **demonstrated**, the block exits 0 on a stale value. **Two are mine** (the narrowing dropped the original `&&` and kept the plan in the list); **step 6's Major and step 4b's add are pre-existing**, and step 6 lay outside my inspection's declared limit. Three tells → mandatory stop |
| — | — | — | — | — | — | **TENTH BOUNDED REVISION**, Daniel's assignment after pass 42, narrowed by his reviewer to the three findings and the four blocks they name — **no plan-wide search**. Step one drops the plan from its staging list and requires it unchanged first (HEAD↔index, then index↔worktree), since `git commit` commits the index. Every `git add` guarded; each commit checked against a `git write-tree` pin. **Step one additionally requires both slot paths to be blobs in the pin** — `git add` stages a *removal* as readily as a change, so a tracked findings file deleted before staging is staged as gone and pin and commit then agree without it; an existence test alone would also accept a directory at the path. Steps three and 4b take no presence check: an authorized repair may delete a file. Both reviewed-head writes guarded, both `cat`s gone. 20 checks × 3 shells in a disposable repo, all green; **three failures in the first run were all harness bugs** and are recorded as such. Commit `8361f0a` |
| 43 | 8361f0a | 3→**5** | 2→**2** | 1→**2** | yes | **UNCLEAN — reported to Daniel, no repair round opened.** **All three pass-42 repairs held; nothing was re-raised against the four repaired blocks.** Every Blocker and Major is the **same class at another location**: 8b's unguarded `cp` of the validated message, condition 6's unguarded `git log … > file` masked by the following `diff`, step 4's unguarded `git fetch`, and every remaining unguarded `git add` across Tasks 0–14 and 8a — **that last one is the plan-wide sweep the assignment excluded**. The only in-set finding is a MINOR: the new blob check accepts a **symlink** (blob, mode `120000`), so the indexed mode would have to be checked too. Three tells → mandatory stop |
| — | — | — | — | — | — | **ELEVENTH BOUNDED REVISION**, Daniel's assignment after pass 43, scoped to its four Blocker/Major findings; the Minor stays collected. 8b removes any earlier pin **before** writing this one and copies under a guard, so a failed refresh leaves condition 6 **no** oracle rather than a stale one; 8b's commit stays terminal, condition 6 re-establishing it independently. Condition 6's extraction takes the same shape. Step 4 guards the fetch **and** the recording — `git rev-parse origin/main` resolves the stale ref happily after a failed fetch — and its `cat` is gone. **Seventeen staging locations guarded, enumerated not described.** A new Global Constraint states the rule: **guards everywhere, content comparison only where a consumer reads that commit** — three places have one, the per-task snapshots have none, and 8a needed no addition because condition 4 already pins its blobs. 18 checks × 3 shells, all green. **Two harness errors recorded**: a writable file in a read-only directory is *not* a failed write, and 8b resets before it pins. Commit `4752a35` |
| 44 | 4752a35 | 5→**9** | 2→**2** | 2→**7** | yes | **UNCLEAN — reported to Daniel, no repair round opened.** **Nothing re-raised against the eleventh revision.** The class widened again — from *masked* status to **discarded** status: `test -z "$(git status …)"` swallows git's exit code and reads a failed command as a clean tree (Preparation and closure conditions 2, 5, 6 — BLOCKER); two `$(git rev-parse …)` in one equality test both resolve empty and compare equal (Preparation and Resume approved-input checks); an unchecked `grep` substitution pair that compares two empty extractions as equal (Task 0 step 3 — BLOCKER); a pipe with no `pipefail` (Task 10 step 4); unguarded scratch writes and a rename masked by `cat` (Task 0 step 3, Task 14 step 1); an unguarded `hash-object` pin loop (8a condition 4); a `git log` inside a `case` substitution (condition 6's subject check). **Not a plateau** — none regenerates from a repair. **Two are escalation triggers**: finding 2 changes how closure conditions spell their tests, finding 7 changes 8a's pre-move ordering. Three tells → mandatory stop |
| — | — | — | — | — | — | **TWELFTH BOUNDED REVISION**, Daniel's assignment after pass 44: all nine findings **plus one bounded sweep** of every executable block for the same mechanism — explicitly **not** a claim that the class is closed. All 54 blocks inspected (four parallel read-only passes plus a mechanical scan). Repaired: six discarded-substitution-status sites, each now a guarded assignment then the same test against the captured value; both two-substitution equality tests; Resume's four-source reconciliation; Task 10's pipeline; 8a's two loops (per iteration **and** on the redirect, messages to stderr because the compound's stdout is the artifact); 8a's inverted-polarity carry check, now a `case` on the status; and the unguarded writes, appends and renames in Task 0 step 3, Task 14 step 1, step 7 step three and 8a. **Justified non-changes:** sixteen terminal `git commit`s (the plan's own rule), `grep`/`diff` exit 1 as legitimate results, `$(cat …)` closed by `test -n`, the cleanup's `ls` glob. 14 fixtures × `sh`/`bash`, 13 × `dash`, all green, using a **stub `git` failing one named subcommand at a time**. Commit `fc12f25` |
| 45 | fc12f25 | 9→**2** | 2→**1** | 7→**1** | yes | **Best pass since 41.** Nothing re-raised against the twelfth revision. **BLOCKER: Resume never establishes that `ba15e83` is an ancestor of `$BASE`** — row 3 was Preparation-only, and **`ba15e83^` carries all three approved-input blobs identically** (verified directly), so a base below the approved closure passed every Resume check. **MAJOR: Task 10 step 4 never shows the diff body** the prose requires the executor to read — **pre-existing**, confirmed against `4752a35` |
| — | — | — | — | — | — | **THIRTEENTH BOUNDED REVISION**, both pass-45 findings, after putting the scope question to Codex as a sparring partner and validating his answer. **Splitting accounting row 3 by entry is a repair, not a new condition** — row 4 is already split the same way for the same reason, so no human decision was owed. Resume gains `merge-base --is-ancestor ba15e83 "$BASE"`; Task 10 prints the captured diff before filtering it. **Two of my own claims were wrong and are corrected**: the tip-removal comment (8a rewrites the tip before 8b, so a stale tip is not what condition 5 reads — the real risk is two candidates' markers standing together), and the rev-parse rationale — **without `--verify` a failed `git rev-parse <rev>:<path>` prints its ARGUMENT, not nothing**, so two failures compare equal only where the revisions do. Observed, not reasoned. 16 fixtures × `sh`/`bash`, 15 × `dash`, all green |
| 46 | f9bd330 | 2→**1** | 1→**1** | 1→**0** | yes | **BLOCKER: step one commits the pass records without binding them to what was validated, and step two then read the WORKTREE copies** — so a hook rewriting only the worktree leaves every step-one check satisfied while the file a reader opens no longer holds what the pass was accepted on. It points at the limit the twelfth revision **disclosed in its own prose**, which is why it was not created by the pass-45 repair |
| — | — | — | — | — | — | **FOURTEENTH BOUNDED REVISION.** **The scope question was put to two independent readings and they DISAGREED** — both quoting the same §A sentence (`target-text.md:85-89`). A subagent read it as "validate once, before the predicate reads" → new obligation; Codex read it as an **input invariant** on what the predicate actually reads → repair, and ran fixtures showing the worktree-rewrite hole is real. **Codex's reading was taken**, because the subagent's supporting claim — that findings files are gitignored so nothing finding-derived is committed — is **false in this repo**: `.gitignore` exempts `.context/codex-reviews/` and this cycle commits its findings files. **Repair taken:** step two reads `git show "HEAD:$SPEC"` / `HEAD:$QUAL`. **Declined with reason:** re-running the structural and eligibility checks on committed content — that is Close condition 4's *closing*-commit duty and the approved text does not place it on a record commit. **Residual named, not repaired:** nothing establishes that the committed bytes are the ones *pass acceptance* validated; an edit between acceptance and staging is pinned as staged. Closing that needs the accepted blob ids carried out of the acceptance step in a file, a duty **no approved text carries**. Demonstrated under `sh`: with a worktree-only rewriting hook, step one exits 0, `HEAD` holds the validated line and the worktree holds `REWRITTEN IN WORKTREE ONLY` |
| 47 | 221819c | 1→**2** | 1→**1** | 0→**1** | yes | **One finding descends from the revision immediately before it, the other does not — an earlier row here claimed both did and was wrong.** `git log -S'rm -f .context/loop-rule-validated-msg'` names `4752a35` as the commit that introduced the Major's line, and `221819c` does not touch it at all. Both demonstrated. **BLOCKER — my own overclaim**: step two read `git show "HEAD:<slot>"` and the prose called the source immutable. That is true of the **commit object** and false of **`HEAD`**, a movable ref — any commit, amend, reset, rebase or checkout in between redirects both reads, and a move *between* the two reads can take the branch files from different commits. **MAJOR**: 8b's unguarded `rm -f` let a **directory** at the pin path reach the closing commit — `rm -f` fails on a directory, `cp source dir` then succeeds by writing beneath it. Observed under all three shells: the old shape printed `REACHED THE COMMIT` with the path still a directory |
| — | — | — | — | — | — | **FIFTEENTH BOUNDED REVISION.** Step one persists the record commit's object id to `.context/loop-rule-records-commit` (added to the cleanup list); **step two reads both slots from that exact object**, and a moved `HEAD` is a reason to **stop and report**, never to re-resolve. 8b's removal is guarded — **that is the line that closes the demonstrated case**, and the prose credits it rather than the `test -f` after it, which **no demonstrated path reaches**. Commit `c2e4932` |
| 48 | c2e4932 | 2→**3** | 1→**3** | 1→**0** | yes | **All three Blockers are ONE defect**: the plan resolved `HEAD` a second time as the identity of a commit whose properties it had already checked. Step 7 step one (tree checked on one commit, id persisted from another); **8a — the one with a shipped payer**: a moved commit could become the closing tip having satisfied **none** of condition 4's checks, and `reset --soft` folds it into the closing commit, publishing content no pass reviewed; and the `.context/loop-rule-records-commit` marker added one revision earlier with **no Resume rule**, which this plan requires of every state file |
| — | — | — | — | — | — | **SIXTEENTH BOUNDED REVISION.** **Swept rather than patched per site** — repairing one of several sites is this cycle's most reliable defect. Each site now resolves the commit **once**, immediately after it lands, and uses that object id for every check and every record; 8a's whole condition-4 chain runs against it and writes it as the tip. **A third site the reviewer did not report** was found and fixed: step 7 step three checked the repair commit's tree and then re-resolved `HEAD` for the reviewed head. **Checked and deliberately unchanged:** step 4b resolves `HEAD` once and persists no identity, so a move makes its comparison fail rather than pass; conditions 1, 5 and 6 read `HEAD` on purpose, to detect a move. Resume now validates the marker and reports a recorded pass as **unrouted** unless the reconciliation shows step two's outcome — a precondition stop, no mutation, no call. Commit `1ba45be` |
| 49 | 1ba45be | 3→**6** | 3→**5** | 0→**1** | yes | **UNCLEAN — reported, no repair round opened; the reviewer's authorization covered exactly this one pass.** Nothing re-raised against the three blocks the sixteenth revision repaired. **Five of six are that same defect class at sites the sweep did not reach**, which is what makes this discovery rather than regeneration. **BLOCKER** Preparation resolves `HEAD` six times and Task 0 step 1 writes the base from a seventh — missed by the sweep, in neither of its lists. **BLOCKER** step 6 records the reviewed head, then specifies the call's `headSha` in prose as a fresh resolution never wired to that file; **not shell, so a shellcheck-verified sweep could not see it**. **BLOCKER** condition 6 composes subject, parent, tree and body from four live `HEAD` reads with no captured id, then cleanup erases the recovery state — **explicitly excluded by the sweep on a rationale that holds for conditions 1 and 5 and not for 6**. **BLOCKER, partial** 8b's `reset --soft` has no atomic expected-old-object guard, but condition 5 already closes the wide window; the residual is sub-second and needs a concurrent actor, and the gap is disclosed as parked. **BLOCKER, partial** the records-commit marker's new checks are satisfied trivially by any earlier already-routed records commit, and the rebuild rule cannot reconstruct it; the named case does have a real precondition stop. **MAJOR, demonstrated** Task 7's worked fragment spans the line break between `Codex is` and `advisory` in both copies, so its `grep -cF` returns 0 where the plan expects `parent=1 worktree=1` — a correct source fails its own check. Three tells stand (findings 3→6, Blockers 3→5, instrument cluster) → mandatory stop |
| 26 | 05ec1b2 | **5** | **1** | 2 | yes | first pass on the revised plan. Resume audited progress by `WIP:` commits and called any non-`WIP` commit a stale base — the handoff leaves two other shapes, one of them `HEAD` **at** the base with everything in the index |
| 27 | f69db7d | 5→**6** | 1→**3** | 2→**1** | yes | the close required the commit's **tree to equal the tip's**, which target §I **parks**; `reset --soft` leaves the index untouched, so the prose beside it was wrong about git; Resume still inferred staleness from a commit subject where §A3 names that state as reachable |
| 28 | f2e5dda | 6→**6** | 3→**2** | 1→**2** | yes | pass 27's stale-base fix reached one site of three; its reset paragraph stated the index behaviour correctly and repeated the false claim four lines later; nothing checked the closing commit's **parent**; the message was validated in the file, where `commit-msg` hooks rewrite git's copy after `-F` reads it |
| 29 | 58c49db | 6→**9** | 2→**5** | 2→**2** | yes | **mandatory stop.** Resume declared the post-reset topology valid and then validated the base through Preparation, which requires a clean tree — that state could never pass; its stale-base predicate included "history has no cycle commits", **necessarily true** of that same state |
| 30 | f99607b | 9→**7** | 5→**4** | 2→**3** | yes | five were pass 29's fix applied inconsistently **inside Resume itself**, so Resume was rewritten whole; three absence checks used bare `grep -c`, which **exits 1** on the no-match result they expect |
| 31 | 2b82702 | 7→**5** | 4→**2** | 3→**2** | yes | step 7 committed a non-closing pass and issued the next review **without routing it through the ordering this change installs**; 8a checked the findings files' paths and never their content |
| 32 | 1e1638f | 5→**4** | 2→**2** | 2→**1** | yes | pass 31's ordering bullets sat **after** the block that already recorded the next head; 8b checked the tip but not the clean tree; pass 31's blob guard lived only in the example shell, not among the governing conditions |
| 33 | e429008 | 4→**7** | 2→**3** | 1→**3** | yes | pass 32 split the post-close checks into their own fence where **`$BASE` is empty**, so a *correct* closing commit failed the parent check every time — the plan had no successful close path; an empty base file satisfied neither entry route |
| — | — | — | — | — | — | **STOP.** Eight passes since the handoff decision, no clean close. Reporting to Daniel; the decision authorized a review before implementation, not this many |
| 24 | b8b433d | 5→**8** | 3→**2** | 2→**5** | yes | close listed "message complete" *after* the record commit while calling it a precondition; the route said "an empty pair means nothing moved" three paragraphs after the same procedure said the opposite, and the checksums had no pre-act baseline; **after a commit lands and then fails a postcondition both tracked patches are empty** and nothing recorded the rejected `HEAD`; Task 0's `cond` fragments lived only in the ignored map, outside step 4's sweep; step 5 still said 7b "appends"; Task 11 recorded a count §F refuses |
| 25 | 892301e | 8→**5** | 2→**2** | 5→**2** | yes | `test -e && cksum` in a loop makes the block's status its *last* iteration, so the pre-act capture returned 1 before 8a and a correct candidate could not enter the close; the captures wrote into the worktree they compared; the pre-act capture held no **bytes**, so a hook rewriting a staged findings file in place was undetectable; **kept `c1`–`c3` lost their observation again** — pass 10 fixed it with a per-task note, pass 22 deleted that note with the other id lists, and no task's walk reaches them; Task 11's sweep record had no shape |
| — | — | — | — | — | — | **CHECKPOINT.** Daniel's allowance of two passes (24, 25) is spent. Pass 25's five repairs are **applied and not yet reviewed**. Next action is his call, not another pass |

## Pass-1 report

**Trend:** first pass, 32 findings, 1 Blocker, 28 Majors. **Cluster:** verification mechanics —
roughly half the findings are fragments that count zero against the real files. **Require↔withdraw:**
none.

**What the reviewer did that made this pass worth its cost:** it ran every `grep` pattern the plan
contained against `CLAUDE.md` and the template. Nine of them return zero in a correct tree — five
wrap across a line break, one quotes `These rules and records are one contract` where the live text
says `These records are one contract`, one quotes an em-dash as a comma, and one names a fragment
preserved inside its own replacement. **This is the exact defect design §7 records from four
consecutive spec revisions**, reproduced by me on the first try despite the design warning about it
by name.

**The repair is structural rather than nine corrections.** The plan now carries **one fragment
table**, every row verified with a checker script against both copies and reporting the line it sits
on, and every task cites a row rather than inventing a pattern. The three ways a fragment fails —
wrapped, preserved inside its replacement, not unique — are stated there once. The one thing the
table cannot pre-verify is the NEW half, which does not exist until a task installs it; that is
disclosed in the table rather than hidden, and each task's step fails if its chosen fragment is not
single-line and unique in the installed file.

**Two findings were the plan installing text contrary to the approved target** — Task 3 preserving
W's `b3` divergence that design §6 decides against, and Task 5 keeping W's missing pronoun. Both now
install what the target says, and Task 14 verifies rather than repairs.

**The three Minors were repaired rather than collected**, and the reason is that each was folded
into an edit a Major already required: the site count contradicting its own enumeration (8/9/10 in
one task), `c20` recorded as carried while the change narrows its scope — the dropped-condition
failure `AGENTS.md` names — and the two plan-mutating tasks having no stable region to replace. None
cost a pass of its own.


## Pass-2 report

**Trend:** findings 32, **32**; Blockers 1, **0**; Majors 28, **25**. **Cluster:** the plan's own
verification apparatus — fragments, pair commands, range checks. That is the **instrument**, so this
is one tell; the finding count is flat rather than rising, which is not. **Require↔withdraw:** none.

**The finding worth the whole pass.** Pass 1's repair introduced one verified fragment table. Pass 2
found three of its rows **preserved inside their own replacements** — `e7` in both copies and the
strict-reading list — so each would have returned `old/worktree=1` after a correct edit and no task
could have reached its required result. **This plan states all three failure modes in its own
fragment-table section**, and the checker I wrote tested only two of them.

**The repair is the checker, not the three rows.** It now tests condition 3 against the target
text's **fenced blocks** rather than the whole file — the narrower test matters, because a fragment
quoted in an item's rationale is not preserved by its replacement, and the broad test rejected a
usable row (P17) that the reviewer correctly left alone. Re-running it over every existing row found
exactly the three the reviewer named and nothing else.

**The second-largest class was commands that cannot run:** `pair()` defined once in a section while
the plan says each task runs in its own shell; three steps that state an expected four-value result
and contain no command that produces one; `$BASE` used without being reloaded, where an empty value
makes `git show` read the index rather than the parent and every count describe the wrong tree.
Task 0 now writes `.context/loop-rule-pair.sh`, every counting block sources it, and the source line
is followed by a guard that fails loudly on an empty `$BASE`.

**Three findings were the plan's checks being un-runnable in a way that would have passed anyway** —
the untouched-range diffs used absolute line numbers recorded *before* Task 1's insertion, and two of
the five ranges contained conditions this change deliberately replaces, so a correct implementation
would have failed its own check. Ranges are anchors now, and the two contaminated ones are split
around the sites they must exclude.

**One duty had no task at all.** Design §7 and target §I assign the plan a completeness sweep for
affected sites the spec has not found; the plan named it in a residual and gave it to "whoever
executes", which discharges nothing. It is **Task 12b** now — a reader-led sweep with a written
record, and explicitly not a mechanical guard.

**And the closing commit would have destroyed its own evidence:** step 5 wrote the evidence entry
into a WIP body, step 8 squashed with `git reset --soft`, which keeps the tree and discards every WIP
message. The entry goes to a file now.


## Pass-3 report

**Trend:** findings 32, 32, **31**; Blockers 1, 0, **0**; Majors 28, 25, **23**. **Cluster:** the
plan's own verification apparatus, for the third pass running — the **instrument**, so one tell.
**Require↔withdraw:** none.

**The finding that names the mechanism.** Pass 2 found three fragments preserved inside their own
replacements. I repaired the three **table rows**. Pass 3 found the same three, because every task
step also quoted its fragment **inline** — so the plan held two copies of each fragment and I had
fixed one. That is the second-copy defect, in the document written to avoid it, at the third
attempt.

**The repair is that fragments now exist once.** The table is the only authored copy, and Task 0
**generates** `.context/loop-rule-verify.sh` from it by reading the rows out of the plan; every
command block sources that file and refers to `$P5_OLD`, `$F10_OLD` and so on. **No task step
contains a fragment any more**, so the failure cannot recur in this shape. The generator's known
limit — fragments containing backticks or single quotes — is stated with the two rows it affects,
and a round-trip check runs before any task uses it.

**Nine findings were shell that cannot run**: blocks assigning `BASE` but never sourcing the helper
that defines `pair()`; two checks written as bare quoted strings after a loop rather than as loop
entries; `$start`, `$end` and `$f` used as `sed` addresses with no step producing them; a
colon-delimited site list whose own anchors contain colons, so `**Severity:**` splits at the wrong
one. The site and range lists are tab-separated files now, written by the step that needs them.

**Three were accounting.** `c15` was marked replaced while §H reproduces it verbatim — carried, and
corrected. The floor-arithmetic split dropped `a3`–`a12` between its two spans, so most of the floor
had no untouched check at all; it is three spans now. And the human-exception split named no anchors.

**Two were duties with no home.** No task applies the twelve `prompt-standards.md` items to the
installed text — the battery's three checks are a floor, not coverage — so Task 15 gains step 4b.
And Task 12b's sweep record was to be committed into `.context/`, which `.gitignore` refuses; it
goes into the plan.

**One boundary claim was false and is now stated plainly:** Tasks 10 and 11 cannot be accepted and
rejected independently, because Task 10 leaves the hook suite red until Task 11 moves the
expectations. They are one reviewable unit with two commits, and the plan says so rather than
claiming a boundary that is not there.

**Eight Minors collected**, per Mechanics · Severity: locator commands run against C while claiming
a result for both copies; three parity steps with no command; commit steps not staging the plan; the
baseline expected-divergence list omitting the recorded blank-line and wrap differences.


## Pass-4 report — MANDATORY TWO-TELL STOP

**Trend:** findings 32, 32, 31, **20**; Blockers 1, 0, 0, **10**; Majors 28, 25, 23, **7**.
**Cluster:** the plan's verification apparatus, fourth pass running — the **instrument**.
**Require↔withdraw:** none.

**Two tells: the Blocker count rose from zero to ten, and the instrument cluster persists.** The
stop is mandatory, not discretionary. Surfaced to Daniel; his standing answer of 2026-09-13 applies
and the loop continued on it.

**The tells are reading something real, and it is my repair strategy rather than the plan.** Pass 3's
fix for "fragments stated twice" was a generator: Task 0 would `awk`-parse this plan's own markdown
table into shell variables. Pass 4 found it broken three ways at once — it also matched Task 7's
NEW-source table and overwrote nine `_OLD` variables; its sentinel test dropped every fragment
beginning with `**`; and its id grammar could not express the rows Tasks 3, 4 and 6 add. **Its
failure mode is the dangerous one**: an unset variable makes `grep -cF ""` match every line, so every
pair reports a healthy-looking count against nothing.

**The generator is deleted rather than debugged.** A markdown parser is the wrong instrument for
thirty-two lines. The helper is **transcribed by hand** and **validated against the real files** —
the validation is what makes the transcription safe, and `pair()` now refuses an empty OLD or NEW,
which is the guard that would have caught the generator's failure had it existed.

**A fourth fragment was preserved inside its own replacement**, and my checker could not see it:
`F4`'s text is one line in `CLAUDE.md` but the target's fenced block wraps it between `you` and
`still`, so a substring test found nothing. **Re-running the check with line breaks normalized found
exactly that one row and no other.** Three passes, three different ways for a fragment to be wrong,
and each time the checker learned the condition after the reviewer found it.

**Four blockers were shell that cannot run** — two pair blocks still carrying the old
`BASE=$(cat …)` prefix without sourcing the helper that defines `pair`, and two hook checks written
as bare quoted strings after a loop rather than inside it. **Two more were state**: re-running Task 0
would have overwritten the recorded base with the current WIP tip, putting every earlier edit outside
Gate B's range and outside the final reset; and the plan records written after the last WIP commit
were never staged, so `reset --soft` would have left them in the worktree and out of the closing
commit.

**Two were accounting**, the fourth and fifth in four passes: `h5`, whose Gate-B destination §F item 7
changes, was marked kept; and one pair per §F block is a sample rather than coverage where a block
changes four conditions.

**What I would tell a reader of this record:** the product text has been stable since pass 1. Every
finding in four passes has been about the apparatus that checks it, and each of my repairs to that
apparatus has introduced a new defect in it. That is the signal the two tells are carrying, and the
answer taken here is to make the apparatus smaller — no parser, no generated state, hand-written
lines whose only guarantee is a check against the real files.


## Pass-5 report — MANDATORY TWO-TELL STOP, and the over-specification named

**Trend:** findings 32, 32, 31, 20, **16**; Blockers 1, 0, 0, 10, **7**; Majors 28, 25, 23, 7, **7**.
**Cluster:** the verification apparatus, fifth pass running. **Require↔withdraw:** pass 4 finding 16
told me to derive an OLD row per addition in the strict-reading block; pass 5 finding 10 says those
clauses are add-only and have no old wording to remove. **Two tells, mandatory stop**, surfaced, loop
continued on the standing answer.

**What most of five passes have been saying.** Findings 1, 3, 4, 9, 11, 13 and 16 of this pass, and
much of passes 2, 3 and 4, are one thing: **shell written in advance for text that does not exist
yet.** Helpers defined in one shell and called in another; loop bodies outside their loops; `sed`
ranges whose delimiters occur in their own data; `sed -n "/x/,/x/p"` for a single line, which runs to
the next match instead; variables no step sets; a generated helper whose empty variable makes
`grep -cF ""` match every line. **Those were defects in the apparatus.** **It would be wrong to say none of the five passes found a
defect in the change itself** — pass 1 found a `baseSha` that would have put only the version bump in
Gate B's range, and two tasks installing text contrary to the approved target. Both would have
produced wrong behaviour, and neither is an apparatus problem. The apparatus class is the *majority*
of the findings, not all of them.

**Design §7 requires the checks to run against the real files** — the plan *builds each pair against
the real files and runs both directions there*. **It does not forbid pre-written shell.** Writing the
commands at execution instead is a defensible way to meet that requirement and it removes a class of
error this cycle kept producing; it is not a method the design had already prescribed, and claiming
so would be reading a preference back into the text.

**So the pre-written blocks are gone**, replaced by one procedure stated once: take the OLD from its
row, install, choose a NEW from the installed text, check it the three ways, count four values,
expect `0/1/1/0`. Plus the two rules that were only ever implicit — **guard every count against an
empty pattern**, and **an add-only edit owes presence alone**, which is the withdraw half of this
pass's tell made into a rule.

**Four findings were the condition table, which is now five for five.** `e8` was marked carried while
§D removes W's form of it; `i4`–`i8` were marked kept while §H reproduces them inside a replacement
block; `h5` needed its own row because §F item 7 changes two conditions; and `g2`/`g3` are **dropped**
rather than replaced, which owes an absence check and had none. **A dropped condition with no check
is the failure `AGENTS.md` names, and it took five passes to find the last of them.**

**Two were genuine state bugs.** `.context/loop-rule-base` was accepted on being non-empty, so an
abandoned run's value would silently put every edit outside Gate B's range; it is now validated as an
ancestor of `HEAD` with only this run's `WIP:` commits between, and removed at close. And the
prompt-standards result was written into the plan after the last WIP commit, where neither Gate B's
range nor `reset --soft` would reach it.


## Pass-5 follow-up — the method change, traced through its dependencies

An independent reviewer Daniel obtained found the pass-5 repair **incomplete, and partly damaging**.
Verified and corrected at the commit below; none of it was a new requirement.

**My bulk edit destroyed four blocks it should not have touched.** The script that stripped
pre-written pair commands matched on the helper's filename as well, so it deleted **Task 2's
untouched-range diff**, **Task 8's installed-count step**, **Task 10's hook-pair list** and — worst —
**Task 15's git closing block**, leaving "Build the pair … record the four values" where
`git reset --soft` and `git commit -F` had been. A fragment count does not close a cycle. All four are
restored.

**Three references to the deleted helper survived**: Task 0 still claimed to write
`.context/loop-rule-verify.sh`, and Tasks 4 and 7 still told the executor to add lines to it and
re-run a validation loop that no longer exists. Removed.

**One shell pattern pass 5 had rejected was still standing** in Task 14 step 4b — the `sed` range
whose behaviour with identical start and end anchors pass 5 named. Replaced with the anchor-resolved
form plus the per-condition checks for `a14` and `h6`.

**Two claims in the pass-5 report were too broad and are corrected above.** Not every finding in five
passes was an apparatus defect — pass 1 found a `baseSha` that would have reviewed only the version
bump, and two tasks installing text contrary to the approved target, both of which would have
produced wrong behaviour. And design §7 requires checks against the real files; it does not forbid
pre-written shell. The new method is a defensible implementation of that requirement, not one the
design had already prescribed.

**The honest status is narrower than "cause understood and removed":** the verification strategy is
simplified, and **whether it is consistently applied and effective is still being reviewed.** The
change also moves responsibility for working check commands to execution time, which removes some
error sources and proves nothing about the checks being right.
