# Plan C — Gate-A pass 4 dispositions (23 findings)

Pass 4 triggered CLAUDE.md §5's mandatory stop-and-surface: four of the five tells present
(count rising 18/20/20/23; Blockers 5/4/2/4; 17 of 23 clustering on the instrument;
require<->withdraw pair on the superseded-artifact marker). Daniel ruled 2026-08-30, routed
through dev-workflow-kit-56. Revision 5 is f2cfbc7.

## The governing ruling
Reduce Tasks 18-21 to "run the Gate-B cycle per CLAUDE.md §5" plus exactly three plan-specific
facts: record the base commit at cycle open; the `rle` slot discriminator; the cycle runs under
the OLD rules per the activation constraint. §5 stays the only source; no protocol
re-specification in the plan.

## Per finding

FIXED BY DELETION OF THE RESTATEMENT (not repaired individually, per the ruling — they were
parts of the copy, and repairing them would have kept it):
- BLOCKER 1010-1057 — unassigned `body` across fenced blocks, empty mktemp file.
- MAJOR 884-892 — `.context` never created before the redirect.
- MAJOR 886-892 — redirect follows a symlink and truncates its target.
- MINOR 887-890 — `-\?wip` matches "wip" anywhere in a subject.
- MAJOR 1049-1060 — no recovery rule for a failed closing amend.
- MINOR 1049-1057 — post-amend check accepts any non-`WIP:` subject.
- MAJOR 991-994, 1000-1002 — branch/reviewed-commit persistence across a resume. §5's own
  single-branch recovery rule; the plan defers rather than restating.
- MAJOR 904-962, 981-982, 1020-1032 — evidence-entry construction and carry. §5 states the
  revalidation obligation (inherited B6); Task 19 produces the entry.
- BLOCKER 927-931, 978-982, 1008-1018 — risk-path verification ordering. Task 19 item 3 now
  states the ordering constraint without scheduling it against deleted task numbers.
- MAJOR 967-976 — `git diff --name-only` overclaimed. Kept as a check, reworded to the
  comparison it actually performs: path names, not content.
- MAJOR 60-68, 97-875, 879-900 — preflight ordering across the amend chain. §5's cycle
  procedure; the plan no longer sequences it.
- MAJOR 984-994 — no ownership guard before slot deletion. §5's delete-before-call step owns it.
- MAJOR 933-945 — knob snapshot procedure. Task 19 item 4 keeps the one-observation rule
  (inherited M9); the storage/digest procedure was instrument and is gone.
- MAJOR 1020-1026 — reconstruction sources under ignored `.context`. Task 20 states the
  sources; the inventory procedure was instrument.

RESOLVED BY THE MARKER MOVE:
- BLOCKER 1023-1032 — the in-record `— reconstructed ...` suffix cannot coexist with the pinned
  grammars. The marker moves BESIDE each record as its own adjacent line in the closing body.
  Grammars stay pure; the adjacent line rides the same squash carry, since the carry copies the
  body's records and the line sits in the same block.

RESOLVED BY DELETION OF AN UNEXECUTABLE OBLIGATION:
- BLOCKER 947-952, 1028-1032 — the parse obligation names no parser and none exists. Scoped to
  executable checks, consistent with the assert-new philosophy revision 3 applied to the six
  checks it stripped: the records are written FROM the pinned grammars and checked by reading
  (the Gate-B reviewer receives the closing body). Task 19 item 5 now also names the productions
  this branch cannot demonstrate, with reasons, rather than implying enforcement that does not
  exist. P8 ships the programmatic consumer.

RESOLVED IN THE SPEC'S FAVOUR:
- MAJOR 826-875 — Task 17 vs spec scope. Task 17 removed; supersession remedies are out of
  scope. The superseded single-plan artifact gets one line in the closure record. This is the
  withdraw half of the require<->withdraw pair with pass 3's MAJOR, which had required the
  marker.

ANSWERED, NOT REVISED:
- MAJOR 1020-1041 — "aggregate reconstruction is a contract change made by the loop". Answered
  by the standing (B)-transitional decision, grounded in spec §10's activation rule: the records
  contract binds cycles that start under the new rules, and all five cycles here are pre-rule.
  Cited here rather than revising the spec. If pass 5 contests it again as a contract change, it
  routes to Daniel as a spec question and is not absorbed a second time.

FIXED IN THE ROLLOUT (in scope — these are the deliverable, not the instrument):
- MAJOR 78-94, 1064-1067 — the skipped-cycle sweep was two files short.
  `docs/getting-started.md:105` and `docs/coding-workflow.md:129` enumerate the same duties and
  omit the provenance line and skip record. New Tasks 17 and 18; Tasks 14-16 renumbered "of 5";
  accounting rows 17 and 18 added.
- MAJOR 73-94, 631-875 — the old-conditions accounting stopped at Task 12. Extended through
  Task 18, and its intro no longer claims none of these passages are §5 rules: rows 15 and 16
  are.
- MINOR 16-18, 631-672, 904-962 — the header pointed at Task 13 for the mode; now Task 19.

FIXED ACROSS EVERY EDIT TASK (both are Majors, so both resolve — not carried):
- MAJOR 121-127, 862-868 — every `grep -cF` was labelled an assertion but succeeded at any
  positive count. All 18 asserts are now equality tests that exit nonzero on any other value.
  The two remaining bare `grep -c` invocations are deliberate: Task 19 item 2 is a
  counterfactual observation across two revisions, which must print rather than assert.
- MAJOR 477-506, 570-620, 840-868 — no done-state preflight, so a rerun could duplicate an
  insertion. One Global Constraint makes every task skip-if-applied: run its assert first, `1`
  means skip, `0` means apply, anything else is a stop rather than a retry. A second constraint
  names Tasks 10 and 12 as the two that re-emit their anchor by design, so only their NEW count
  discriminates. One rule rather than twenty state tables.

Every bash fence in the plan was checked with `sh -n`: 37 blocks, 0 syntax failures.

## Inherited obligations after revision 5
M9 at Task 19 item 4. M10 in Global Constraints. M8 and B6 are §5's own rules and are deferred
to, not restated. MINOR 12 is moot: it asked for `mktemp` over a fixed `/tmp` path, and the plan
no longer scripts the close.
