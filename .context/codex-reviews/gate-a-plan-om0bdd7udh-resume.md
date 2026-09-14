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
| 6 | — | — | — | — | not run | next, against the pass-5 repair commit |

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

**What five passes have actually been saying.** Findings 1, 3, 4, 9, 11, 13 and 16 of this pass, and
most of passes 2, 3 and 4, are one thing: **shell written in advance for text that does not exist
yet.** Helpers defined in one shell and called in another; loop bodies outside their loops; `sed`
ranges whose delimiters occur in their own data; `sed -n "/x/,/x/p"` for a single line, which runs to
the next match instead; variables no step sets; a generated helper whose empty variable makes
`grep -cF ""` match every line. **Every one was a defect in the apparatus and none in the change.**

**Design §7 already said not to do this:** the plan *builds each pair against the real files and runs
both directions there*. **There** — with the installed text open. I had been pre-writing it.

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
