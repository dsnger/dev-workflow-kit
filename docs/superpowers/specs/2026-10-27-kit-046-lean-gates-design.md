# Kit 0.46 lean gates — Design

**Story:** `docs/superpowers/stories/2026-10-26-kit-046-lean-gates-story.md` (risk standard, security none,
battery+check, checkpoints spec). **Date:** 2026-10-27. **Plugin version:** 0.46.0.
**Gate A:** runs — this spec is reviewed under the installed 0.45 rules (floor 3, cap 5), since the new rules ship with it.

## 1. Intent

The review loops end as soon as they stop finding blocking findings, under a hard cap. From pass 2 the reviewer
checks the fixes instead of the whole artifact again. Gate A runs on risky specs only. The quality command is the one
source of green. UI acceptance criteria need a real app run. Prose hardening needs a reason. Pass files are archived
at a cycle's close. A project can switch all of this back to the 0.45 rules, and this repository runs a stricter
Gate B, because its product is prose and its Gate B finds 28 % of Blockers and Majors in pass 4 or later (story §1).

**Non-goals:** identity separation (GitHub App), runners, a status dashboard, a new record format, moving the
726 pass files this repository already tracks (a follow-up row, §9), making the hook block anything.

**Anti-goals:** closing a cycle over an open Security finding, a violated acceptance criterion or a Blocker because it
appeared late or at the cap; a mode a project cannot see or audit; a weaker battery; a hook that shows ✓ where the
project's rules still owe a pass.

## 2. Gate modes (story AC-1–AC-4, AC-8)

A project picks one mode, in the committed file `.claude/codex-gate.mode` holding one word. `.claude/` is committed
in initialized projects and outside every ignore block, so the file needs no ignore exception, and any change to it is
a prompt path that takes Gate B. **No file, or a file that holds no known word (empty, unreadable, a typo), means
`classic`**: a project initialized before 0.46 keeps the rules it has and the hook keeps reminding as 0.45 did. For a
present but unusable file the hook adds a note naming it, and the agent says so and fixes the file in its next commit.
`/workflow-init` writes `lean` into a missing file only when both surfaces that carry the new rules are current after
its run: the gate rules (`### 2.1a`) and CLAUDE.md §4 (`### 2.1`), each written or found identical. When either is
declined or differs and stays so, it writes no mode file, and reports that the project stays `classic` and why. A
present file is never overwritten silently (invariant 9). When a `lean` or `strict` file is present while either
surface is not current, it reports that state as it is — the mode in force and the surface that differs — and offers
two ways out: accept the surface, or set the file to `classic`; it changes neither without an answer. This repository
commits `strict`.

| | `lean` | `strict` | `classic` (the 0.45 rules) |
|---|---|---|---|
| Gate A on a spec | only at risk `high` or security not `none` | same as `lean` | every spec |
| Gate A on a plan | only at risk `high` | same | same |
| Gate A sequence | exactly two passes: pass 1 full, pass 2 verify (§3); floor 2, cap 2 | same as `lean` | floor 3, cap 5, full passes |
| Gate B floor | 1 | 1 | 3, with the zero-finding early close and the small-change close |
| Gate B cap | 3 | 5 | 5 |
| Gate B pass 2 and later | verify pass (§3) | full pass | full pass |
| What blocks | see "Blocking" below | see "Blocking" below | any Blocker or Major (0.45) |
| At the cap | §4 | §4 | the 0.45 cap answer (O14) |
| AC-5, AC-6, AC-7, AC-9 duties (§5) | apply | apply | do not apply |

**Blocking (`lean`, `strict`).** A finding is *blocking* when it is a Blocker or a Major, or when it is Security-class
or names a violated acceptance criterion (`AC-<n>`), whatever its severity. Every other finding is *collected*: never
repaired in the loop, never a reason for another pass, a `todos.md` row at the close (O9, O10).

| Finding | `lean` | `strict` |
|---|---|---|
| any blocking finding in pass 1 | repair, next pass | repair, next pass |
| an earlier blocking finding, re-checked in a later pass | carried forward and marked (§3); still open → blocks | same |
| a new finding in pass ≥ 2 that is a Blocker, Security-class or a violated AC | blocks | blocks |
| a new ordinary Major in pass ≥ 2 | collected | blocks |
| a Minor or Nit that is neither Security-class nor a violated AC | collected | collected |

**Closure.** A `lean` or `strict` cycle closes at the first pass at or above its floor with no open blocking finding.
A `classic` cycle closes as 0.45 did: at a pass with no Blocker or Major at or above floor 3, or earlier at a pass
with zero findings, or for a Gate-B small change (0.45 definition, kept for `classic`) at its first pass with no
Blocker or Major.

**Gate A, `lean` and `strict`.** Exactly two passes, as AC-4 states: pass 1 is a full review; the blocking findings
are repaired; pass 2 verifies the repairs and what they touch (§3), or, when pass 1 left nothing to repair, reads the
spec once more in full. Pass 2 is the cap: §4 applies to what is still open. `strict` changes Gate B only (D-5).

**Why the Gate A threshold is risk `high` or security not `none`:** Daniel's guidance (D55, 2026-10-27). The
measured cost sits in Gate A tails of 10–65 passes on standard-risk specs, and the gate-value ranking says to shorten
the spec gate first. Size is not part of the threshold: a large standard story is reviewed at Gate B on its diff,
which the battery backs. Every spec carries a header line `**Gate A:** runs | skipped — <profile line>`.

**When a spec is approved.** One definition, stated once in the gate rules: a spec is approved when its Gate A
closes; a spec with Gate A skipped is approved when it is committed with its `skipped` line, or, when the story's
checkpoints include `spec`, when the human approves the committed spec. Edits the human asks for at that checkpoint
come before approval and need no amendment. From approval on, a spec changes only through `intake`'s amendment route.
Every sentence that ties approval or amendment to "its Gate A closed" says "once approved" and points to that
definition: CLAUDE.md §4 (run order, checkpoints, brainstorming's design
approval) and its `### 2.1` template, `.claude/review-gates.md` line 5 and its `### 2.1a` template, `intake` (the
checkpoint list and the hand-off), and `/workflow-init` wherever it restates them. The checkpoint `spec` stops on the
committed spec when no Gate A runs.

**A mode is fixed per cycle.** The mode read at a cycle's pass 1 governs the whole cycle; a change to the file takes
effect at the next cycle. The closing commit's provenance line already records the floor (O16); a cycle whose mode
file changed while it ran names both modes in its closing commit's body.

**The hook.** It reads `.claude/codex-gate.mode` each run and sets its default floor and cap per gate from the table
(`lean`: A 2/2, B 1/3; `strict`: A 2/2, B 1/5; `classic`, no file or an unusable file: 3/5 for both). Because the
file can change while a cycle is open, the hook remembers the mode it read at each gate's first counted pass, in a
state file cleared together with that gate's pass counter, and while the counter lasts it uses the higher floor and
the lower cap of the remembered and the current mode, and says so when they differ: a change mid-cycle can make the
reminders stricter, never laxer (invariant 2). A resumed session keeps the state file, so it keeps the remembered
mode. A positive counter with no usable remembered mode — a cycle begun under 0.45, a failed state write — counts as
a remembered `classic`, so the reminders take the 0.45 numbers until that counter is cleared; the agent follows the
mode that applied at its cycle's pass 1, which for a cycle begun under 0.45 is `classic`. The existing `.context/codex-gate.floor`
and `codex-gate.cap` files still override the hook's numbers; they change its reminders only, never what the rules
owe, and the docs say so. The Gate A note at plan execution names the mode's spec threshold, so a skipped Gate A on a
standard spec reads as expected. The hook still exits 0 everywhere (invariant 1) and stays POSIX `sh` (invariant 4).
Its reminders match the mode only while no override file is set.

## 3. The verify pass (`lean` Gate B pass ≥ 2; `lean` and `strict` Gate A pass 2; story AC-2)

The 0.45 rule stays: from pass 2, each slot's earlier Blocker and Major findings are listed with their verdict and
reason, and Codex marks each `fixed | not fixed | no longer applies`. In `lean` and `strict` the list holds every
earlier *blocking* finding (§2), so a Security-class or violated-AC Minor is carried forward and checked too. A
verify pass adds:

- **Gate B range:** `baseSha` is the `headSha` the previous pass reviewed, so Codex reads the fix diff, with the
  earlier findings list in `additionalContext`. Both calls (`spec`, `quality`) keep one range, as today. When that
  head cannot be established (a resumed session, rewritten history), the pass is a full pass over the whole change
  instead: the stricter direction, so no record of reviewed heads is needed.
- **Gate A:** the prompt carries the earlier findings list and the changed sections, and asks Codex to check the
  fixes and what they touch.
- **What blocks:** the "Blocking" table in §2.

## 4. At the cap (`lean`, `strict`; story AC-1)

At the cap no further pass runs. Three cases, in this order:

1. A cut to an approved commitment is needed → the human (§4 stop, unchanged).
2. A Blocker, a Security-class finding or a violated acceptance criterion is still open, whatever its severity →
   the human (§4 stop). The human may allow more passes through `.context/codex-gate.cap-extra`, as today.
3. Otherwise the open findings — ordinary Majors still open, and every collected finding — become `todos.md` rows,
   and the cycle closes. An ordinary Major is deferred here, not escalated.

The agent no longer grants itself further passes (O14): the long tail is the measured cost. "When a finding class
regenerates, shrink the mechanism" stays as a rule for the passes before the cap.

## 5. Other items (not in `classic`)

- **Quality command (AC-5).** CLAUDE.md §4 and its template: the quality command in `AGENTS.md § Commands` is the one
  source of green. Run it, fix, rerun, at most 5 rounds. A crashing, missing or timed-out tool counts as red, and so
  does a run that cannot start — except the existing rule for a timeout in an untouched test, which keeps its
  preconditions (the load recorded, the test passing alone) and its outcome (the PR head's required CI check is the
  battery evidence; a red CI stops). Still red after 5 rounds is a §4 stop, added to the stop list: a red battery
  cannot merge. The Gate B prompt names the battery evidence for this head (the local run, or the pending PR CI under
  the timeout rule) and tells Codex not to report failures that run would show (lint diagnostics, type errors, failing
  tests). Codex still reviews whether the checks cover what they claim: missing cases, excluded paths, weak
  assertions, claims about what a check proves, and the AC-to-test mapping, where a test that cannot fail stays a
  finding.
- **UI app run (AC-6).** CLAUDE.md §4 Plan paragraph and template: in a project with a UI, the plan names, for each UI
  acceptance criterion, a run of the real app (a browser or end-to-end run against the running app) and where its
  evidence is recorded; a model review does not replace it.
- **Prose hardening (AC-7).** `harden-finding` step 4: when neither lint nor a test can decide the finding, the rung
  is `1 prose`, and the row's `ref` says why neither can; a prose row without that reason is not written. The ladder
  table gets no new row; the closing act still owes only lint or test.
- **Branch protection (AC-8).** `/workflow-init` 2.10 already asks to make the `quality` check required; it adds that
  the default branch should be protected (no direct push, a pull request required). The kit sets nothing itself; the
  hook stays advisory. This is a setup recommendation, not a run rule, so it applies in every mode.
- **Less filing (AC-9).** *Archive:* in the closing act, move the cycle's files (`.context/codex-reviews/*-<nonce>-*`)
  to `.context/archive/codex-reviews/<nonce>/` before staging the closing commit, so in a project that tracks them the
  move is part of that commit. A file already at the destination is never overwritten: stop and compare. The resume
  rule looks in both places, so a close interrupted after the move but before the commit resumes from the archive.
  In this repository `.gitignore` gains `!.context/archive/`, so archived files stay tracked as today.
  *Learning rows:* a learning is a fixed finding the closing act's ledger check owes a hardening for; its row is the
  `harden-finding` row, no second one (Daniel's guidance, D55: the hardening log). The row's `finding` names the
  symptom and the cause, its `ref` names the change, the location and the evidence: the cycle nonce for a row a
gate cycle produced, or the source it came from (a PR comment, a manual note) for a bot or manual hardening. The
  `Columns:` paragraph of `docs/hardening-log.md`, its `### 2.2` scaffold and `harden-finding` step 7 say so. A fixed
  finding that owes no hardening, and a collected one, get no hardening row; collected ones are `todos.md` rows.

## 6. Old conditions accounted for (story AC-10)

From `.claude/review-gates.md` (0.45) and CLAUDE.md §4. "Kept for `classic`" means the condition survives verbatim
under `classic`.

| # | Old condition | Fate |
|---|---|---|
| O1 | Gate A reviews every spec | kept for `classic`; `lean`/`strict` use the threshold (§2) |
| O2 | A plan gets Gate A only at risk `high` | kept |
| O3 | Before Gate A or a small-change close, take the profile line | kept, reworded: before deciding whether Gate A runs, or a `classic` small-change close |
| O4 | From pass 2, earlier Blockers/Majors listed with verdicts, Codex marks each | kept; extended by the verify pass (§3) |
| O5 | A `not fixed` becomes a finding line unless declined/accepted with no new evidence | kept |
| O6 | Floor 3 valid passes | kept for `classic`; `lean`/`strict`: Gate B floor 1, Gate A exactly two passes |
| O7 | A zero-finding pass may close early | kept for `classic`; in `lean`/`strict` Gate B's floor 1 closes there anyway; Gate A has no early close |
| O8 | Gate B small change closes at its first pass with no Blocker/Major; its definition and commit line | kept for `classic`; `lean`/`strict` close every change that way |
| O9 | Collect Minors and Nits; never iterate on them | kept for `classic`; in `lean`/`strict` kept except for a Security-class or violated-AC Minor or Nit, which is blocking (§2) |
| O10 | A small change's closing-pass Minors stay unrepaired (a later fix is unreviewed) | kept; in `lean`/`strict` generalised to every closing pass of either gate, since a Gate B close may be at pass 1 |
| O11 | Timeout in an untouched test (load recorded, passes alone): PR CI is the battery evidence; a red CI stops | kept, and named as the exception to "a timeout is red" (§5) |
| O12 | Cap = floor + 2, or the count plus extra passes last authorised | kept for `classic`; `lean`/`strict` caps per gate (§2); extra passes only by the human |
| O13 | At the cap a Blocker or a cut to an approved commitment goes to the human | kept, widened in `lean`/`strict` to an open Security-class or violated-AC finding (§4); an ordinary Major is deferred to `todos.md` |
| O14 | Otherwise the agent chooses: delete the mechanism, cut scope, continue N passes, or close | kept for `classic`; `lean`/`strict` close with `todos.md` rows (§4) — the long tail is the measured cost (story §1); "shrink the mechanism" stays before the cap |
| O15 | Closing act "as for a clean pass (no Blocker or Major, at the floor unless zero findings or a Gate-B small change)" | reworded to "at the mode's closure (§2)" |
| O16 | Cycle line `floor 3 per …` | kept, with the mode's Gate floor in place of `3`; no new field. Readers parse any floor (`ledger-metrics.py` `floor ([1-9][0-9]*) per `; `loop-usefulness.py` reads it as an integer). `ledger-metrics.py`'s two "licenses floor 1" evidence lines describe the pre-0.46 level rule; their labels say so, and that a floor-1 record may also come from a 0.46 `lean` or `strict` mode, which the record does not show |
| O17 | Hardening owed only at lint or test | kept |
| O18 | CLAUDE.md §4 run order "spec → Gate A → plan"; checkpoint `spec` "once its Gate A closes"; design approval = closed Gate A; amendment "after its Gate A closed" | reworded per §2 "A spec without Gate A", at every listed site |
| O19 | Resume "from the cycle nonce and latest pass file" | kept; the lookup includes the archive (§5) |

## 7. Surfaces

`.claude/review-gates.md` and the `### 2.1a` template (byte-identical, ≤ 10,000 bytes: checks 4i, 4j); CLAUDE.md §4
and the `### 2.1` template (check 4e); `/workflow-init` 2.1a (mode file), 2.2, 2.10; `skills/intake`;
`skills/harden-finding`; `hooks/codex-gate.sh` and its test; `scripts/ledger-metrics.py` labels and suite;
`.claude/codex-gate.mode` and `.gitignore` here; `docs/hardening-log.md` Columns; README, `docs/reference.md` (hook
messages and settings), `docs/coding-workflow.md`, `docs/getting-started.md`, `docs/ARCHITECTURE.md` (its `floor=3`
sentence), CHANGELOG, `todos.md`; version 0.46.0. Every prompt change passes `docs/prompt-standards.md`.

**Byte budget.** The gate rules are at 9,993 of 10,000 bytes, and `classic` keeps the 0.45 text it needs; the rules
cannot point elsewhere, since templates stay inline (invariant 8) and an initialized project has no copy of this
repository's docs. Decision D-11: the 0.45 small-change and cap-answer sentences stay in the rules, prefixed
`classic:`; the mode table goes in as short lines; the bytes come from tightening sentences elsewhere in the same file. If the plan's measurement shows it cannot fit, that is a
Blocker for the plan, not a reason to drop a `classic` condition.

## 8. Acceptance evidence

- Hook suite: no mode file (3/5 both gates), `lean` (A 2/2, B 1/3), `strict` (B cap 5), `classic`, an unknown word
  (classic numbers plus the note), a floor file overriding a mode, a mode changed from `classic` to `lean` mid-cycle
  (the classic floor stays), and the Gate A plan-execution note naming the threshold. The `lean` case fails on
  0.45.0 (AC-8).
- `/workflow-init`: the mode file is written only when both rule surfaces are current; declined either → no file, and
  the report says `classic` (a reading check of the command text, since no harness runs it).
- Readers: a `floor 1 per …` line from a standard-risk cycle through `ledger-metrics.py` (parsed; the evidence labels
  name the pre-0.46 rule and the possible 0.46 mode origin) and `loop-usefulness.py` (parsed), next to an existing
  historical floor-1 record (AC-11).
- Checks 4e, 4i, 4j green; the full battery green under `sh` and `dash` (AC-12, AC-13).

## 9. Decisions

- D-1 The mode lives in a committed one-word file `.claude/codex-gate.mode` read by the hook: the hook already reads
  one-word settings files, `.claude/` needs no ignore exception (so no `.gitignore` migration), and a prose line in
  CLAUDE.md would need new parsing.
- D-2 Gate A threshold = risk `high` or security not `none`; no size criterion (Daniel's guidance, D55).
- D-3 Loop limit 5 for the quality command; still red is a §4 stop (limit: Daniel's guidance, D55).
- D-4 Learning rows are the hardening-log rows `harden-finding` already writes (destination: Daniel's guidance, D55).
- D-5 `strict` changes Gate B's loop only: the kit's measured exception is Gate B's late finds; its Gate A tails are
  the cost this story cuts.
- D-6 AC-3 is met by one switch, `classic`, that restores every 0.45 run rule this story changes. AC-3 reads "switch
  each behaviour change … back … by a per-project setting": one setting that covers each change, which `classic` is.
  The brief says the same ("each per-project switchable where it changes behaviour"). Separate switches per item
  would allow combinations nobody reviewed (the verify pass presumes floor 1; the cap rule presumes the verify pass).
  The existing floor and cap files still tune the reminders.
- D-7 Pass 2+ keeps both Gate B calls with the fix-diff range rather than one `full` call: the known-working shape.
- D-8 Existing tracked pass files are not moved in this change; a `todos.md` row records it.
- D-9 The builder check of `superpowers:brainstorming` is replaced by this spec's Gate A (CLAUDE.md §4: the design
  approval is the closed Gate A).
- D-10 No file means `classic`, so an update alone never lowers a project's reminders below the rules it still has.
- D-11 Byte budget as stated in §7.
