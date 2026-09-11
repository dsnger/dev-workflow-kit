# Gate A (spec) — dark-factory vision — pass 4 dispositions
26 findings: 2 BLOCKER, 14 MAJOR, 9 MINOR, 1 NIT. Unprofiled run.

## STATUS: gate NOT closed.
The author's closing condition was "if the pass returns ONLY leaf-ownership
findings, record them in §11 and close; a NEW Blocker/Major that is not
leaf-ownership stops the loop". Pass 4 returned two non-leaf-ownership
Blockers and seven non-leaf-ownership Majors, so the condition is not met and
the close decision goes back to the author. Everything fixable was fixed; no
pass is credited clean.

## The three lines
1. TREND — p1: 52 findings, 2 Blocker, 41 Blocker+Major.
   p2: 34 / 1 / 26.  p3: 32 / 2 / 24.  p4: 26 / 2 / 16.
2. CLUSTER — three groups. (a) Leaf ownership, 7 of 16 Blocker+Major: a station
   §1 draws that no §7 leaf owns. (b) The overclaim class AGENTS.md forbids by
   name, 5 findings: rollup-branch equivalence, release tags solving whole-wave
   main, "enforcement" for the interim write path, "no stage is skipped", and
   "an audit finding is by definition something both gates let through".
   (c) Two Blockers that are implementation errors of the pass-3 ruling, not
   new questions.
3. REQUIRE-WITHDRAW — none this pass. The pass-3 pair did not recur: pass 4
   corrects WHERE the pass-3 ruling was applied, never asks to withdraw it.

## Tells
Findings rising: NO (52 -> 34 -> 32 -> 26).
Blocker count failing to fall: YES (2 -> 1 -> 2 -> 2) — still present.
Instrument cluster: N/A, no test instrument in this artifact.
Prose-about cluster: arguable; the overclaim findings are about the product's
own claims, which is this document's substance rather than commentary on it.
Require-withdraw pair: NO — cleared this pass.
One tell, down from two, so §5's mandatory two-tell stop no longer fires. The
stop here is the author's own closing condition, not that rule.

## Fixed — the two Blockers, both my own errors implementing the pass-3 ruling
- p4-1 The ruling ("work waits") was written as "the candidate waits in the
  merge queue", but Gate B runs at Verify, before PR, Sample-Gate and the
  queue, and a Gate-A outage precedes any candidate. The wait now happens
  where the outage happens. The ruling is unchanged; only its placement was
  wrong.
- p4-2 I called `.context/codex-gate.off` a declared project-level gateless
  state. Shipped CLAUDE.md says it suppresses the hook reminder per workspace
  and "the gates still apply", and .gitignore excludes it so a clone never
  sees it. The declaration is the tracked INACTIVE notice /workflow-init
  writes into the project's CLAUDE.md. Corrected, and neither file is said to
  authorize anything.

## Fixed — seven non-leaf-ownership Majors
p4-3 one producer of the architecture verdict (Intake asks, Bewertungs-Loop
answers, edge drawn) · p4-4 the Spec-Loop no longer intakes a second time after
classification already did · p4-6 the orchestrator named as a model node the
cross-cutting contracts cover · p4-7 story stages are serial; only work inside
a stage fans out · p4-21 the rollup replacement named as weaker instead of
equivalent · p4-22 release tags give boundaries, not a whole-wave main ·
p4-23 the interim path is authorized-write tooling and merge-time detection,
with its bypass window stated, not "enforcement".

## Fixed — nine Minors and the Nit
p4-8 §7 heading names the leaf as the unit [SEE CORRECTION BELOW] · p4-16 6d owns the downgrade
triggers the entry called unowned · p4-17 the §11 opening no longer states a
false count · p4-19 the dashboard builds on 2c, not read-only P8 · p4-20 a
mini-wave bypasses no station, but the triviality skip still exists ·
p4-24 an audit finding is not by definition past both gates · p4-25 decision 8
no longer says "every mandatory touchpoint" one sentence before listing four
that carry no knob · p4-26 step 5's title admits 5b is not a clock loop.

## Recorded in §11, per the author's scope decision (7 leaf-ownership items)
Leaf definitions extended: 4c gained the Bewertungs-Loop runtime (p4-5);
4e gained given/when/then normalization and the per-AC test report (p4-15);
the ledger entry routes gate findings to 2a rather than 4b, which is
pre-production and never sees a review loop (p4-18).
New "Stations drawn in §1 that no leaf yet owns" block, six entries with a
candidate owner each: the vet preflight, the judge/watchdog, the working
orchestrator dry-run, the as-built view (p4-9, p4-10, p4-11, p4-14), plus
punchlist generation and model strength per role (p4-12, p4-13).

## CORRECTION, written at close (pass 5)
This file's "Fixed — nine Minors and the Nit" section OVERSTATED what landed.
The second pass-4 edit script aborted on a non-matching string BEFORE its
write, so seven edits it had reported as applied were never written to disk:
p4-8 (§7 heading), p4-16 (downgrade owner), p4-17 (§11 opening count),
p4-19 (dashboard P8 attribution), p4-20 (mini-wave "no stage is skipped"),
p4-25 (decision 8's "every mandatory touchpoint"), p4-26 (step 5's title).
Pass 5 re-reported all seven, which is how the miss surfaced. They were applied
at close. The pass-4 REPORT was wrong; the pass-4 findings file was not.
