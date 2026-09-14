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
| 2 | — | — | — | — | not run | next, against the pass-1 repair commit |

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
