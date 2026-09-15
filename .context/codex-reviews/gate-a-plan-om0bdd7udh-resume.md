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

**Cycle OPEN and UNCLEAN. The plan stands at `1849164` and that is the anchor** — later commits on
this branch are records, not plan edits, so check `git log --oneline -1 -- docs/superpowers/plans/2026-09-14-loop-rule-consolidation.md`
rather than `HEAD`. Pass 34 reviewed `1849164` and found 1 Blocker, 1 Major, 3 Minors and 1 Nit,
**all validated, none repaired**. `.context/codex-reviews/gate-a-plan-om0bdd7udh-pass-34.md` holds them.

**Do not start a repair round on your own.** Daniel's assignment of 2026-09-15 ended with a
checkpoint that supersedes the standing autonomy: *"stop and report, whether clean or unclean. Do
not begin another repair/review round or implementation."* That checkpoint is spent — it covered one
revision and one pass, both done — so **the next move is Daniel's word, not an inference.**

### The four open findings, in the order they cost most

1. **BLOCKER — step 8a never checks Close condition 3.** It discharges 1, 2 and 4; the index claims
   8a and 8b both check the message. On a re-entry between 7b and 8a the record commit lands before
   the message is re-established, and 8b is the first to notice — the exact failure condition 3
   exists to prevent.
2. **MAJOR — the porcelain parser mangles two real pathname shapes.** `git status --porcelain -z |
   tr '\0' '\n' | sed 's/^.\{3\}//'` turns a rename into `p.txt` and a newline-bearing path into two
   fragments. **Verified by execution, not by reading.**
3. **MINOR — condition 6 says the landed body is "identical"** where the corrected oracle strips
   trailing blank lines. Introduced by the bounded revision itself.
4. **MINOR — step 8 is titled "two invocations" and has four fenced blocks**; **MINOR** — the
   Architecture paragraph still says every task runs a discriminating pair, which the disposition
   table replaced; **NIT** — `loop-rule-untouched.tmp` and `loop-rule-baseline-diff.tmp` are written
   and never removed by the cleanup.

### What the bounded revision did, so it is not undone by accident

Each closing condition had been stated **three times** — a Close condition, a command in Task 15
step 8, and prose beside that command. The third copy is gone. **`### Where each operational
condition is defined` is the index**: one home per condition, a lookup with no commands and no
expected results. Close defines the six closing conditions; step 8 keeps the shell with each block
naming the condition it discharges; Task 0 step 1 and accounting row 7 cite rather than re-describe.

**One correction, found by running it:** condition 6 compared bytes, and `git log --pretty=%B` adds
one trailing newline the source file has none of — **it rejected a correct close, so the plan had no
working success path.** Fixed and checked in four directions.

**Verified in a disposable repo:** the whole of step 8 end to end. **Unverified:** every reader check,
Failure and Resume — they need a real failure or a real interruption.

**The plan's shell needs `sh` or `bash`, never `zsh`** — `$FINAL` relies on word-splitting and the
body comparison uses process substitution.

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
