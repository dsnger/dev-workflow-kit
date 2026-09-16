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

**READ THIS FIRST — the state below describes pass 44 and is superseded by the pass-45 rows in the
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
