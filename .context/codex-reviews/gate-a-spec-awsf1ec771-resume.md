# Gate-A (spec) working record — cycle awsf1ec771

Advisory, cycle-stable, per CLAUDE.md §5 optional companions. Retire at closure.
Nothing depends on it; the pass files and the repo are authoritative where this disagrees.

- **Kind:** Gate-A spec
- **Nonce:** awsf1ec771 (drawn 2026-09-10 from /dev/urandom, 10 chars, no collision among open cycles)
- **Artifact:** `docs/superpowers/specs/2026-09-10-loop-rule-consolidation-design.md`
- **Branch:** loop-rule-consolidation
- **Story:** `docs/superpowers/stories/2026-08-29-loop-rule-consolidation-story.md` — profile read from its header at each pass (was high / none / battery+check+verification at pass 1)
- **Derived floor:** 3 (risk high → level 2; security none → 0; max 2 ≠ 0 → 3)
- **Hook knob:** absent (no `.context/codex-gate.floor`-style file observed)

## Passes

| Pass | Spec rev | Findings | Blockers | Majors | Valid | Notes |
|---|---|---|---|---|---|---|
| 1 | 510f6ce | 24 | 5 | 15 | yes | all B/M in-set; dispositions in `gate-a-spec-awsf1ec771-pass-1-dispositions.md` |
| 2 | 07c88a1 | 17 | 2 | 13 | yes | all in-set; #8's mandatory-record demand dismissed (existing no-identity rule answers it); session 01a08b0b-495e-7ee0-8641-631684a4db4e |
| 3 | 8d20b2e | 12 | 4 | 6 | yes | #5 re-raises the mandatory-record demand → dismissed a second time, residual disclosed instead; #11 collected; #12 severity corrected MINOR→MAJOR (instrument carve-out, false green); session 01a08b2f-8fce-7130-96c9-d70d94f48778 |

| 4 | 0a5205f | 18 | 1 | 10 | yes | **SCOPE STOP surfaced to Daniel** on finding 1 (mandatory record for accepted obligations — a new contract question, raised a 3rd time and rebutting the D10 dismissal correctly); other 17 held, unrepaired, pending the answer; session 01a08b6f-09b2-7c00-99c6-9bd230c32d18 |

| 5 | 4625679 | 17 | 0 | 15 | yes | zero Blockers; #16 collected; revision must SHRINK (3 concepts removed); session 01a08b9b-456e-7fa2-a50a-2c56ec4e08c8 |

| 6 | 726a5de | 16 | 4 | 9 | yes | 4 findings are one structural defect (clean candidacy defined on a post-hoc predicate); session 01a08bbe-93da-7951-b694-2bd4f5bff99a |

| 7 | de66e00 | 14 | 0 | 9 | yes | structural repair converged: Blockers 4→0, findings 16→14; session 01a08bdc-7f64-7980-87f6-768998056025 |

| 8 | 5aef816 | 12 | 1 | 7 | yes | 5 of 12 mechanical (assert, count, header, grammar); session 01a08bfb-3cd3-7ff3-99a2-c887a75d316d |

| 9 | 2feab0c | 14 | 2 | 10 | yes | **TWO-TELL STOP — mandatory, surfaced to Daniel.** All 14 held open; session 01a08c14-71b6-74f1-a835-8098e0f3c90a |

| 10 | 18c742f | 20 | 2 | 15 | yes | **SECOND TWO-TELL STOP + clearly-stuck all three conditions met.** Surfaced to Daniel with a split recommendation; all 20 held open; session 01a08c43-ad6f-75d2-92ce-9f7497be3f51 |

| 11 | c8f96b8 | 20 | 1 | 13 | yes | first pass on the narrowed 647-line spec; finding 14 names the cause — the block restates rules their own paragraphs still own; session 01a08c65-7a3e-7c80-8cd5-2565f1b61d45 |

| 12 | 11b0e47 | 21 | 1 | 13 | yes | **two mechanisms ended by Daniel's repeat criterion**, brought in mid-loop from another project; session 01a08c7f-c573-7df1-8b31-7704ec7be064 |

| 13 | 78e5f97 | 16 | 2 | 8 | yes | **the loop turned: B+M 14 → 10, Majors 13 → 8**; session 01a08c98-b6cd-7bc3-9556-8f1c87491031 |
| 14 | c06dd69 | 16→**10** | 2→**1** | 8→**5** | yes | spec byte-identical to 0168f88 (532 lines); **lowest B+M of the cycle, 6**; **SCOPE STOP surfaced on finding 6** (partial-adoption guard = a 21st edit, outside the twenty); session 01a08f70-6d1e-7cf1-baa3-6df3cc59bc32 |
| 15 | 17cf2e9 | 10→**12** | 1→**1** | 5→**7** | yes | **TWO-TELL STOP — mandatory, surfaced to Daniel.** B+M 6→8. **Six of twelve regenerate from pass 14's own repairs** (3, 4, 6, 7, 10, 11). All 12 held open; session 01a08fb2-6e8e-73d0-9d2b-8fb92d1571dd |
| 16 | 5d12884 | 12→**8** | 1→**1** | 7→**4** | yes | **B+M 8→5, lowest of the cycle.** One tell (Blockers flat). Five B/M applied; Minors 7 and Nit 8 collected. Findings 2 and 4 are the spec disagreeing with *standing* §5 text, not with itself; session 01a08fff-fadf-72f2-994d-618048bea473 |
| 17 | — | — | — | — | not run | next action |

## Pass-16 three-line report

**Floor line:** derived floor **3**; risk **high**, security **none**; read fresh from
`docs/superpowers/stories/2026-08-29-loop-rule-consolidation-story.md`. One cited story, level 2.

- **Trend:** findings …, 16, 10, 12, **8**. Blockers …, 2, 1, 1, **1**. Majors …, 8, 5, 7, **4**.
  Blocker+Major 20, 15, 10, 11, 15, 13, 9, 8, 12, 17, 14, 14, 10, 6, 8, **5** — **the lowest of the
  cycle**, past the pass-14 low of 6.
- **Cluster (pass 16):** product 7 of 8; bookkeeping 1 (the 58% claim); **the instrument 0**, the
  first zero-instrument pass since pass 9.
- **require↔withdraw:** none. Finding 3 objects to the hold split made *for* pass 15's finding 11,
  which is a later pass questioning a repair — the mirror of the pair's shape, not the shape.

**Tells: one of five** — the Blocker count flat at 1. Findings fell hard, Majors fell, the cluster
is product. One is not two, so no mandatory stop. The clearly-stuck exit is not reachable either:
its first condition needs a plateau and the curve is at a cycle low.

**What changed in the loop's shape — and one claim here was withdrawn the same day.** Findings 2
and 4 disagree with **standing §5 text rather than with the spec itself**: the Mechanics `WIP:`
warning claiming a non-WIP commit "closes the cycle", and the Reader paragraph normalizing
severity tokens the (g) replacement assumed were raw.

**Withdrawn: that these were newly visible.** The `WIP:` warning was raised at **pass 15, finding
2**, which named both sites (C 751–753 and 825–826). The pass-15 revision changed the block's
prose and **did not add the §4 row**, so pass 16's finding 2 is a **regeneration from an
incomplete repair of mine**, not boundary work arriving. Pass 16's row 21 closes it, and records
that the sibling passage needs no edit because it already says "reads **to the hook** as the cycle
closing". Finding 4 is genuinely first-seen; finding 2 is not, and saying so in the pass report
was wrong.

**Also withdrawn: "the spec no longer contradicts itself".** Pass 16's own Blocker repair shipped
a contradiction — the duties paragraph kept the resolve duty as a precondition "on any pass being
clean" while the sentences after it made cleanliness pass-local. The two decide the case *pass 1
carries an open Major, pass 2 finds nothing* in opposite directions. Corrected before pass 17: the
duty is a precondition on **closure** only, and that case is now walked through the ordering in the
shipped text — pass 2 is clean, the cycle is eligible, and it still cannot close.

**The rollback is holding.** No finding asked for a restored enumeration, no finding hit a stated
total, and the one new source edit (item 21) cost no count update — which is what removing the
totals bought.

**What the falling curve does and does not show.** Every count here describes the revision the
pass **reviewed**, never the repair made after it. Pass 16's five Blocker/Majors do not assess
their own fix in `c792383`, and the contradiction that fix introduced is the proof: it was found
by reading, not by the curve. The number to watch next is not the level but **whether pass 17's
first Blocker comes out of this repair again or reaches something unreviewed** — three passes of a
flat Blocker count say less than one pass's answer to that.

**Minor 7 and Nit 8 are collected, not repaired as their own round.** Nit 8's number was correct
and its wording was not: 58% measures the four bookkeeping sections (456 of 785), not "the
remaining" after the design's 173. Fixed in the same clause while the surrounding sentence was
already open; no revision round was spent on it. Minor 7 — whether the two-branch concatenation
strips terminators and `NO FINDINGS` lines — stands open and is recorded here.

## Pass-15 three-line report — MANDATORY TWO-TELL STOP

**Floor line:** derived floor **3**; risk **high**, security **none**; read fresh at this pass from
`docs/superpowers/stories/2026-08-29-loop-rule-consolidation-story.md`. One cited story, profiled,
level 2.

- **Trend:** findings …, 21, 16, 10, **12**. Blockers …, 1, 2, 1, **1**. Majors …, 13, 8, 5, **7**.
  Blocker+Major 20, 15, 10, 11, 15, 13, 9, 8, 12, 17, 14, 14, 10, 6, **8** — the fall reversed.
- **Cluster (pass 15):** product 7 of 12 (1, 2, 3, 4, 5, 6, 11); the instrument 3 (§7's presence-only
  list and two oracle gaps); bookkeeping 2 (the 16/21 double-count, the D1/D6/D8 citation claim).
- **require↔withdraw:** none under the definition. Finding 11 objects to the health-only hold clause
  that pass 14 finding 9 **asked for**, which is a later pass questioning an earlier pass's
  addition — the mirror of the pair's shape, not the shape. Named rather than hidden.

**Tells: two of five — the threshold. Stop-and-surface is mandatory, not discretionary.** The
finding count rose 10 → 12; the Blocker count failed to fall, 1 → 1. The cluster is product and
there is no pair, so it is exactly two.

**The clearly-stuck reading is also satisfied on all three conditions**, though it is not needed:
a plateau across fifteen passes (B+M never zero, never below 6); coverage affirmable after fifteen
readings; and Blocker/Major findings regenerating from the previous round's own repairs — **six of
twelve**, nameably: 3 and 4 are the citations pass 14's block edits lean on, 6 and 7 are item 22's
own mechanics, 10 is the item 16/21 overlap pass 14 created, 11 is the health-hold clause pass 14
finding 9 required.

**What the pass says about pass 14's repairs, measured.** Three of the four changes made to item 21
and 22 carry a defect: the coupled set §9 calls "exactly" items 1, 2, 3, 10–14 **omits** items 15,
16, 17, 19 and 21, which the block also depends on (finding 5); item 22 adds non-records to a
paragraph opening "These records are one contract" (finding 6); and items 16 and 21 replace
overlapping spans, double-counting under the spec's own counting unit (finding 10). The
enumeration in finding 5 was copied from the spec's earlier sentence rather than recomputed — the
exact defect `AGENTS.md` names as "a rewrite reliably preserves the condition that motivated it
and silently loses the others".

**One mechanism is on its fourth round, and it is the same one the repeat criterion was brought in
for.** Findings 1, 3 and 4 are one shape: **the block cites a rule whose source does not say what
the block claims it says.** Gate-A closure (1), which severity field `c8` reads (3), what
discharges the resolve duty (4). The same shape produced finding 14 at pass 11, four findings at
pass 12 and finding 1 at pass 14. Each round repaired the instance and left the mechanism.

**Finding 1 is a real design defect regardless of what is decided**, and it is the one that cannot
be deferred: the block declares the Gate-B closing amend to be "the closure itself", but a Gate-A
cycle closes with its spec or plan commit and has no amend path — so a clean Gate-A pass under this
ordering can neither close nor suspend, which is precisely the state AC 4 exists to forbid. This
cycle is itself a Gate-A cycle.

## Pass-14 three-line report — SCOPE STOP, and the loop is converging

**Floor line (owed every pass):** derived floor **3**; risk **high**, security **none**; read fresh
at this pass from `docs/superpowers/stories/2026-08-29-loop-rule-consolidation-story.md`. One cited
story, profiled and resolvable at level 2. Floor long met; what is owed is a clean final pass.

- **Trend:** findings …, 20, 21, 16, **10**. Blockers …, 1, 1, 2, **1**. Majors …, 13, 13, 8, **5**.
  Blocker+Major 20, 15, 10, 11, 15, 13, 9, 8, 12, 17, 14, 14, 10, **6** — **the lowest of the
  cycle**, and the second consecutive fall. Findings are also the lowest since pass 3.
- **Cluster (pass 14):** product 6 of 10 (findings 1, 2, 3, 6, 7, 9); the instrument 3 (§7's
  oracle and its residual, plus the (g) rationale's counting claim); bookkeeping 1 (the NIT's
  failed quotation check).
- **require↔withdraw:** none. Finding 2 demands *removing* the withdrawal path, which is a later
  pass objecting to an earlier pass's addition — the mirror of the pair's shape, not the shape.

**Tells: zero of five.** Findings falling hard, Blockers falling, cluster on product, no pair. The
clearly-stuck reading is not reachable either: its third condition needs Blocker/Major regenerating
across repair attempts, and this round's fixes reduced them.

**The pass-13 note held.** Pass 13 predicted the reviewer was "running out of internal problems and
working the boundary". Pass 14 confirms it: findings 1, 4, 7 and 10 are the spec's edges meeting
standing text (`c8`, §7's own oracle, `b7`/`b8`, a §5 sentence that wraps across four lines), not
the spec contradicting itself.

**SCOPE STOP on finding 6, surfaced rather than absorbed.** The finding asks that the existing
semantic partial-adoption stop be extended to cover the closure block and its twenty coupled
edits. It is **true of the artifact** — §9 says so itself: "That is an admitted unsafe state, not a
guarded one, and it is this change's own." So a validated dismissal is unavailable; a dismissal
says a finding is false, and this one is not. And the repair is a **twenty-first edit** to a
paragraph the story never set out to change, which leaves the assigned fix set. Under the absorb
rule that stops the loop and goes to the user. The question is a genuine either/or: **ship the
admitted residual, or spend one more source edit on a guard.**

**SCOPE STOP ANSWERED 2026-09-10 by Daniel: B — accept, bounded.** In his words, to be carried
into the text: *"eine begrenzte Erweiterung der vorhandenen Konsistenzregel auf die neue
Abschlusslogik und ihre abhängigen Änderungen … beschreibe die Wirkung korrekt als Anweisung an
den Agenten. Daraus soll weder ein neues Prüfsystem noch eine zusätzliche Record-Durability-Lösung
entstehen."* Shipped as **§4 item 22**. Four corrections he made to the recommendation that
preceded it, recorded because each was right and each had been argued the other way here:
documented is not accepted, since the user project runs the copied `CLAUDE.md` and not this spec;
the existing rule is an **instruction**, not a guard, and calling it one was the overclaim
`AGENTS.md` names; "remove restatement" never meant "refuse every expansion", and the
compatibility of the rules this change introduces belongs to this change; and B carries **no extra
pass**, because one Blocker and five Majors oblige a further pass regardless.

**The other nine are in-set and repairable**, and one is worth naming because it is a settled
decision being contradicted: finding 2 shows the block invented a **withdrawal** path for a
decline, which **D7** does not admit. Removing it restores the settled input rather than deciding
anything new.

**A precheck gap, recorded not fixed.** The precheck reported "OLD blocks checked: 0" and finding
10 is exactly what an OLD-block check would have caught — a §4 quotation occurring in neither
copy. It is a mechanical check the reviewer spent judgement on. Candidate for the precheck; not a
new rule, and not this cycle's to build.

## Pass-13 three-line report

- **Trend:** findings …, 20, 21, **16**. Blockers …, 1, 1, **2**. Majors …, 13, 13, **8**.
  Blocker+Major 20, 15, 10, 11, 15, 13, 9, 8, 12, 17, 14, 14, **10** — flat for three passes, then
  the first real fall since pass 8.
- **Cluster (pass 13):** product 11 of 16; the instrument 1 (§7's table inputs); bookkeeping 4
  (two wrong counts, two partial OLD quotations).
- **require↔withdraw:** none.

**Tells: one of five** — the Blocker count 1 → 2. Findings falling, Majors falling hard.

**What the repeat criterion actually bought, measured rather than asserted.** Mechanism 1, the §7
substring asserts: **3 Majors at pass 12, 0 at pass 13.** Dead, because the work moved to the plan
rather than being repaired a fifth time. Mechanism 2, the block restating what it cites: **4 → 2**,
and both survivors are a narrower shape — a *source* paragraph restating (`b3`), and a citation
that omits a source — not the block restating. Half-ended.

**What it did not buy, and the criterion is not built to.** Pass 13's finding 2 is the pass-12
revision's own fix regenerating: a contradiction surface was introduced with no next state. That is
the no-progress defect class, and only the transition walk catches it — which is why the pass-13
revision brief adds one as a standing check.

**A second signal, worth more than the count.** Pass 13's findings are mostly the spec's edges
meeting **standing** text — Mechanics "Finishing the cycle", the evidence-entry revalidation rule,
`b8`, `b3` — rather than the spec contradicting itself. The reviewer is running out of internal
problems and working the boundary, which is the shape a converging loop takes.

## Pass-12 three-line report

- **Trend:** findings …, 20, 20, **21**. Blockers …, 2, 1, **1**. Majors …, 15, 13, **13**.
  Blocker+Major 20, 15, 10, 11, 15, 13, 9, 8, 12, 17, 14, **14**. Flat for three passes.
- **Cluster (pass 12), split by Daniel's criterion rather than the old three buckets:**
  **product 10** (1 Blocker, 9 Major — the shipped rules); **harness 6** (4 Major on §7's assert
  list, all of them false-green class, so they keep their severity under the existing instrument
  carve-out); **bookkeeping 5** (all NIT, path citations).
- **require↔withdraw:** none this pass.

**Tells: zero of five** by the stated definitions. The loop is not tripping its own thresholds, and
that is exactly the gap Daniel named: a flat curve with no tell is invisible to the rules.

**The criterion Daniel brought, and what it ended.** Three lines from a sibling project: a product
Major always blocks; a harness Major blocks only where it makes a claim vacuous; **the second
finding of the same shape against the same mechanism ends that mechanism's rounds** — narrow the
claim, print the residual, move the work. The kit already carries the first two in the Mechanics
severity carve-out. The third has no counterpart, and two mechanisms here were on their fourth
round of one shape:
- **§7's assert list** — "an assertion that does not detect what it claims", at passes 8, 8-audit,
  11 and 12. Cause is structural: a spec cannot build an exact substring check for text that does
  not exist yet. **Moved to the plan**, where the substrings exist; §7 now states what must be
  verified and names which passages owe a pair, and prints the residual.
- **The block restating what it cites** — passes 11 and 12, four findings. **Made mechanical**: a
  cited rule contributes zero predicate words to the block, which is checkable by reading.

**The criterion is NOT a shipped rule and this record must not read as if it were.** It was applied
here as a judgement call by the agent running the cycle, on Daniel's endorsement, in the same way
any triage call is made. Nothing in `CLAUDE.md` obliged it and nothing checked it. Captured for the
kit as `docs/superpowers/stories/2026-09-10-harness-finding-termination-story.md` — intake only,
profile proposed and unconfirmed, so the criterion is a candidate rule that has been used once.

That intake found the gap more precisely than the summary above: the existing severity ceiling
sends a non-vacuous harness Major to "Minor or below: collect, never iterate", and **"collect"
names no destination** — no ticket, no tripwire, no trace outside that pass's report. It also found
a partial counterpart nobody had named: `harden-finding` and the ledger escalate a *recurring* fix
after a finding closes, which is not a move a running loop can make.

## Pass-11 three-line report

- **Trend:** findings 24, 17, 12, 18, 17, 16, 14, 12, 14, 20, **20**. Blockers 5, 2, 4, 1, 0, 4, 0, 1, 2, 2, **1**.
  Majors 15, 13, 6, 10, 15, 9, 9, 7, 10, 15, **13**. Blocker+Major 20, 15, 10, 11, 15, 13, 9, 8, 12, 17, **14**.
- **Cluster (pass 11):** product behaviour 14 of 20; the test instrument 6 (§7's oracle and rows,
  and three wrong line-range claims in the mechanical checks). Instrument at 30% is the highest
  it has been and worth watching, though product is still the cluster.
- **require↔withdraw:** one pair. Finding 4 demands the hold apply to **every** surfaced finding,
  which is what the passes 6–7 revisions removed when they narrowed it to scope stops. The story's
  own third duty says every surfaced finding, so the pair resolves back to the story.

**Tells: one of five.** The finding count is flat rather than rising, Blockers fell, the cluster is
product. **The split helped**: Blocker+Major 17 → 14 and Blockers 2 → 1 across a change that also
cut 320 lines.

**A convergent move is nameable again, and it is finding 14's.** The block restates triggers,
duties, preconditions and the severity answer that their own paragraphs still define, so each copy
holds two authorities and findings 3, 4 and 6 are that drift already happening. The repair inverts
it: the block owns the evaluation order and closure only, and cites every other rule where it
already lives. That is what the story's desired outcome asked for and what the pass-6 repair —
the one that worked — looked like.

## Pass-10 three-line report — MANDATORY STOP, AND THE STUCK EXIT IS NOW READABLE

- **Trend:** findings 24, 17, 12, 18, 17, 16, 14, 12, 14, **20**. Blockers 5, 2, 4, 1, 0, 4, 0, 1, 2, **2**.
  Majors 15, 13, 6, 10, 15, 9, 9, 7, 10, **15**. Blocker+Major 20, 15, 10, 11, 15, 13, 9, 8, 12, **17**.
- **Cluster (pass 10):** product behaviour 15 of 20; the test instrument 2 (§9's oracle and its
  row set); prose about it 3. Within product: **four on the record transport** (2, 4, 5, 6),
  **three on the Q6 root check** (9, 10, 11), two on rollback and the discriminator (1, 15),
  five on the ordering (3, 13, 18, 19, 20), one on sameness (7).
- **require↔withdraw:** present. Pass 10 finding 7 demands byte-exact field equality for the
  sameness test, which is what the pass-2 revision removed in favour of reading it on meaning.

**Tells: two of five, unambiguously — the threshold.** Finding count rising 14 → 20; Blocker count
failing to fall, 2 → 2. Stop-and-surface is mandatory.

**And this time the clearly-stuck reading is satisfied on all three conditions**, which it was not
at pass 7: a plateau across ten passes (Blocker+Major never below 8, never zero); coverage
affirmable after ten readings of every section; and Blocker/Major findings regenerating from the
previous round's own repairs — findings 2, 4, 5 and 6 are the pass-9 slim-down's, and 9, 10 and 11
are the third rework of a root check that pass 4 introduced.

**Two-tell stop ANSWERED 2026-09-10 by Daniel: SPLIT.** The record and its transport, the
unavailable-history report, the checkout-root condition, the rollback reading and the
discriminator dissolution move to `docs/superpowers/stories/2026-09-10-record-durability-story.md`
(profile proposed, unconfirmed — Daniel decides before it is executable). The parent story's §2
records the split and its criterion 7 moved with them, so it carries six criteria again
(commit 6cbc174). Twelve of pass 10's twenty findings are **deferred, not fixed**: 1, 2, 4, 5, 6,
7, 8, 9, 10, 11, 14, 15. Eight survive the narrowing and are fixed: 3, 12, 13, 16, 17, 18, 19, 20.

**The cycle continues under this nonce.** The artifact was revised, as it has been at every pass;
the floor of 3 is long met; what is still owed is a clean final pass against the current artifact,
which is now the narrowed one. The pass counter continues at 11.

**Why no convergent move is claimed this time.** At pass 6 one was nameable and it worked; at
pass 9 one was nameable and it did not — the slim-down cut ninety lines and the next pass was the
worst since pass 1 on Majors. What still regenerates is not one defect but one *subject*: the
durability of records and history across sessions, which the record transport, Q6, the root check
and the rollback paragraph all belong to. The ordering itself has converged — its five remaining
findings are small.

## Pass-9 three-line report — MANDATORY STOP

- **Trend:** findings 24, 17, 12, 18, 17, 16, 14, 12, **14**. Blockers 5, 2, 4, 1, 0, 4, 0, 1, **2**.
  Majors 15, 13, 6, 10, 15, 9, 9, 7, **10**. Blocker+Major 20, 15, 10, 11, 15, 13, 9, 8, **12**.
- **Cluster (pass 9):** product behaviour 13 of 14 — and within it, **five on the answer-record
  transport** (1, 2, 5, 6, 10) and six on the ordering; prose about it 1; the instrument 0.
- **require↔withdraw:** **one pair, and this one fits the definition.** Pass 6 asked whether a
  pending membership question is frozen at surface time or re-evaluated; re-evaluation was chosen
  and the frozen reading removed. Pass 9 finding 3 demands the frozen pass-time fix set back.

**Tells: three of five present — the threshold is two, so stop-and-surface is mandatory and not
discretionary.** Finding count rising (12 → 14); Blocker count failing to fall (1 → 2); a
require↔withdraw pair. The clearly-stuck reading is **also** satisfied for the first time — a
plateau across nine passes, coverage affirmable, and Blocker/Major findings regenerating from
the previous round's own repairs — but it is not needed: the two-tell threshold stands alone.

**Two-tell stop ANSWERED 2026-09-10 by Daniel: continue, with the answer record slimmed back to
his pass-4 choice.** Deleted: the snapshot rule and its marker, the kind/artifact header fields,
the authoritative-latest-body rule, the newest-first branch search and the recovery-passage
rewrite, the malformed-snapshot stop, the durable-validity proof, and the re-surface-before-next-
pass duty. Kept: the two labels, one form, the nonce, written before the next pass, restated in
the closing body, squash carry, the sameness test, the cycle binding. In their place one residual
paragraph: the record is legible to a human reading history and buys no automatic recovery —
which is what the story's criterion 7 asks it to state. Findings 1, 2, 5 and 6 dissolve; finding 3
reverses the pass-6 choice back to the frozen pass-time fix set, as D4 and `b6` require.

**Diagnosis carried to the user rather than acted on.** The closure ordering, which is what the
story asked for, has converged: its findings are narrow and its Blockers came and went. The
**answer-record transport has not.** It began as one commit-body line and has accreted an
identity line, a full-snapshot rule, an authoritative-body rule, a newest-first branch search, a
malformed-snapshot stop and a durable-validity proof — and each round's repair of it produces the
next round's findings. Five of pass 9's fourteen sit there, including both Blockers.

## Pass-8 three-line report

- **Trend:** findings 24, 17, 12, 18, 17, 16, 14, 12. Blockers 5, 2, 4, 1, 0, 4, 0, 1.
  Majors 15, 13, 6, 10, 15, 9, 9, 7. **Blocker+Major: 20, 15, 10, 11, 15, 13, 9, 8.**
- **Cluster (pass 8):** product behaviour 9 of 12; the test instrument 2 (a false assert and a
  false count in §9); prose about it 1 (stale header metadata).
- **require↔withdraw:** none. Findings 4, 6 and 7 each extend a pass-7 requirement that was
  applied incompletely; none demands something an earlier pass removed.

**Tells: one of five** — the Blocker count 0 → 1, counted conservatively as failing to fall even
though the four-pass shape is 0, 4, 0, 1. Findings falling, Majors falling, cluster on product.

**Note for the plan phase, not acted on mid-loop:** most of the spec's growth from 462 to 940
lines is §4's full OLD/NEW quoting of small source edits. By the story's own sizing guidance that
is plan detail. Moving it mid-loop is the restructure that produced pass 6's Blockers, so it is
recorded here for the plan to take deliberately.

## Pass-7 three-line report

- **Trend:** findings 24, 17, 12, 18, 17, 16, 14. Blockers 5, 2, 4, 1, 0, 4, **0**. Majors 15, 13, 6, 10, 15, 9, **9**.
- **Cluster (pass 7):** product behaviour 13 of 14; prose about it 1 (a false count in the spec's
  own claim); the test instrument 0.
- **require↔withdraw:** **one pair, counted.** Pass 6 offered two fixes for the partial-adoption
  guard, a central membership list or a marker on every mergeable hunk; the central list was
  taken and the markers dropped. Pass 7 demands the markers. The removal was mine at pass 6's
  invitation rather than pass 6's own, which is one step removed from the definition — counted
  as present anyway, because the conservative reading is the honest one.

**Tells: one of five.** Findings falling, Blockers back to zero, cluster on product behaviour.

**The clearly-stuck exit is no longer reachable and the pass-6 note is superseded.** Its third
condition required Blocker/Major findings regenerating across repair attempts; the pass-6 repair
took Blockers to zero and the count fell, so the regeneration condition fails. Two of three are
gone, not two of three present. The pass-7 revision aims at a clean pass 8.

- **Trend:** findings 24, 17, 12, 18, 17, 16. Blockers 5, 2, 4, 1, 0, **4**. Majors 15, 13, 6, 10, 15, 9.
- **Cluster (pass 6):** product behaviour 15 of 16; prose about it 1 (the §10 conformance claim);
  the test instrument 0.
- **require↔withdraw:** none under the definition. Two near-misses, named: pass 3 required the D3
  sentence preserved in full and pass 6 says that preservation now contradicts the ordering; pass
  5 required the fourth duty over its original domain and pass 6 says the placement it produced is
  circular. Both are a later pass objecting to an earlier pass's *addition*, which is the mirror of
  the pair's shape rather than the shape itself.

**Tells: one of five** — the Blocker count failing to fall (0 → 4). Findings still falling; the
cluster is product behaviour; no pair. One is not two.

**The clearly-stuck reading, examined rather than assumed.** Two of its three conditions are now
present: a plateau is visible (12–18 findings, 10–20 Blocker+Major, for five passes, and six is
where the field saw one), and Blocker/Major findings are demonstrably regenerating — six of pass
6's sixteen trace to pass 5's own repairs, with the lineage nameable. The third, an **affirmative
judgement that coverage is sufficient**, is available. **The exit is nonetheless declined, and the
reason is the rule's own:** reporting "will not converge" is a false report where the convergent
move can be named, and it can be — four of the six regenerated findings are one defect, clean
candidacy resting on a predicate produced by a later branch, and pass 6 states its repair. One
more round is spent on that repair rather than on the exit. If the round after it regenerates
again, the third condition stops being affirmable in good faith and this exit is taken.

## Pass-5 three-line report

- **Trend:** findings 24, 17, 12, 18, 17. Blockers 5, 2, 4, 1, **0**. Majors 15, 13, 6, 10, 15.
- **Cluster (pass 5):** product behaviour 14 of 17; prose about it 3 (the a13 accounting, the
  rollback claim, the scope-provenance sentence); the test instrument 0.
- **require↔withdraw:** none under the definition. One near-miss named rather than hidden: pass 4
  required a wrong-root **stop**, pass 5 says that stop contradicts D10 and offers removing it as
  one of two fixes. That is a later pass questioning an earlier pass's addition, which is the
  mirror of the pair's shape, not the shape itself.

**Tells: zero of five.** Not stuck either — the clearly-stuck exit needs all three of a plateau,
an affirmative coverage judgement and regenerating Blocker/Major findings. The third is plainly
present (pass 4's fixes produced six of pass 5's findings), the first is approaching, and the
second cannot be affirmed: each pass still reaches material the previous ones had not read. Two
of three is not the exit.

**Majors rose 10 → 15 while Blockers fell to 0.** Read as density, not regression: six of the
seventeen are first review of the `Accepted:` record authorised between passes, and most of the
rest say one thing — the record was carrying jobs it did not need. The pass-5 revision removes
three concepts rather than patching them.

## Pass-4 three-line report (duty active from pass 4)

- **Trend:** findings 24, 17, 12, 18 — **rising at pass 4**. Blockers 5, 2, 4, 1. Majors 15, 13, 6, 10.
- **Cluster (pass 4):** product behaviour 12 of 18 (the shipped ordering, decline block, Q6 text,
  severity paragraph); prose about them 6 (the spec's own accounting, inventory ids, parity
  rationale, rollback and dissolution claims, the §10 conformance claim); the test instrument 0.
- **require↔withdraw:** none. Findings 2 and 3 report an *incompletely applied* pass-3 decision,
  not a reversal of one; finding 1 is a demand repeated after dismissal, which is not a withdrawal.

**Tells: one of five** — the finding count rising. Blockers are at their lowest; the dominant
cluster is product behaviour, not the instrument or prose about it; no pair. One tell is not two,
so no mandatory tell-stop. **The loop was stopped by the scope stop on finding 1 instead.**

**Scope stop ANSWERED 2026-09-10 by Daniel: accepted.** The finding enters the fix set and the
change ships a second record label, `Accepted:`, sharing the decline record's form, transport,
nonce and carry rules. Authorised scope growth beyond the story's §2, recorded here and in the
pass-4 dispositions file. This Gate-A cycle runs under the pre-change rules, so it writes no
accept record of its own — the rules it started with have none.

Tells after pass 3 (duty starts at pass 4; tracked early): findings 24→17→12 falling;
**Blockers 5→2→4 — failing to fall, one tell present**; clusters are product-behaviour (the
shipped rules), not instrument or prose-about; no require↔withdraw pair (pass 3 narrows pass 2's
decline-suppression demand rather than withdrawing it; the mandatory-record demand is a repeat
after dismissal, not a withdrawal). One tell is not two — no mandatory stop.

## Prompt

**`.context/gate-a-spec-prompt.md`** — durable copy, substitute `__SHA__` and `__P__`. It carries
the pre-call checklist and the three "deliberately not here" blocks that have to stay in it, or the
reviewer re-raises deferred material. The scratchpad copy is gone with its session.

## STATE AT HANDOFF — 2026-09-10 evening

- **HEAD `0168f88`** on `loop-rule-consolidation`, tree clean. Spec **532 lines** (was 785).
- **Pass 13's findings are all dispositioned and applied**; dispositions in
  `gate-a-spec-awsf1ec771-pass-13-dispositions.md`. Findings 15, 16, 13, 14 dissolved with the cut;
  4, 5, 12 became rows in the new §4 table; 6 became one line in §6; 10 was absorbed by §7's
  narrowing; the rest fixed in §3.
- **The next action is Gate-A spec pass 14** against `0168f88`. Nothing else is pending.
- **The cut, measured:** the design is now **192 of 532 lines, 36%**, against 173 of 785, 22%.
  §5 accounting 216 → 33, §7 verification 119 → 67, §4 quoting 83 → 54, §6 parity 38 → 18. The
  bookkeeping did not vanish; the plan carries it, beside the edits, where it is checkable against
  real files.
- **Transition walk done and clean** — every state the spec names reaches close or park, and no
  state returns itself with its input consumed. That was pass 13 finding 2's defect class.

## Next — resume procedure, in order

1. `git -C /Users/daniel/DEVELOPMENT/APPS/dev-workflow-kit log --oneline -5` and `git status --short`. Branch is `loop-rule-consolidation`, tree must be clean.
2. Read this file's Passes table and the newest three-line report for where the loop stands.
3. `python3 .context/spec-precheck.py docs/superpowers/specs/2026-09-10-loop-rule-consolidation-design.md` — exit 0, and eyeball its COUNT list against the spec's enumerations.
4. `rm -f .context/codex-reviews/gate-a-spec-awsf1ec771-pass-<N>.md`, confirm gone.
5. Fill `__SHA__` (current HEAD, short) and `__P__` into `.context/gate-a-spec-prompt.md`, call `mcp__codex__exec` with `workingDirectory` = repo root.
6. Validate the file: last line exactly `END OF FINDINGS (<n> total)`, exactly `<n>` finding lines, nothing else. Anything else is an INCOMPLETE pass — do not count it, do not act on the partial list.
7. Disposition every finding, then have a fork revise. Report the three lines to Daniel (trend, cluster, require↔withdraw) — the duty is active from pass 4 and every pass owes it, plus the floor line (floor 3, risk high, security none, read from the story header).
8. Append a row and a report section here before running the next pass.

## Standing practices adopted mid-cycle — NONE of these is a shipped rule

Each was applied as a judgement call on Daniel's endorsement. `CLAUDE.md` obliges none of them and
nothing checks them. They are candidates captured in
`docs/superpowers/stories/2026-09-10-harness-finding-termination-story.md`.

1. **Repeat criterion.** The second finding of the same shape against the same mechanism ends that
   mechanism's rounds: narrow the claim, print the residual, move the work. Measured: it took the
   §7 substring-assert mechanism from 3 Majors to 0 in one pass.
2. **Pass ceiling.** A cycle grinding past floor + 3 without a clean pass owes a stop-and-surface.
3. **Size limit.** A design spec whose bookkeeping outweighs its design gets cut before the next
   pass, not diagnosed after it.
4. **Precheck before every pass** — step 3 above. §5 already requires this and it was dropped after
   pass 1; roughly a quarter of later findings were things it decides in seconds.
5. **Transition walk before every commit.** List every state the spec names with its input and next
   state; confirm close or park is reachable from each. Pass 13's finding 2 was the previous
   revision's own fix creating a dead end, and only this walk catches that class.

## Daniel's decisions this cycle, in order

| When | Decision |
|---|---|
| before pass 1 | Profile confirmed `high / none / battery+check+verification`; slot discriminator dissolved rather than shipped. |
| pass 4 scope stop | Accept the finding: ship an `Accepted:` record label beside the decline record, sharing form, transport, nonce and carry rules. |
| pass 9 two-tell stop | Continue, but slim the record back to that pass-4 choice; delete the snapshot, identity, search, authoritative-body and durable-validity machinery. |
| pass 10 two-tell stop | **Split.** Record durability moves to `docs/superpowers/stories/2026-09-10-record-durability-story.md`; this story keeps the ordering, the duty classification and the severity/health answer. |
| mid-loop, from another project | Anchor the repeat criterion in the kit; captured as the harness-finding-termination story. |
| after pass 13 | **Cut the spec to the design**; the plan carries the bookkeeping. Precheck runs before every pass. |
| pass 14 scope stop | **B — accept, bounded.** Extend the existing coherence *instruction* to the closure block and its coupled edits (§4 item 22). No checker, no new mechanism, no record-durability work. |

## For the execution phase, not needed yet

When the diff actually edits `CLAUDE.md` §5, the Gate-B cycle runs under rules the diff is changing.
Copy §5 to `.context/rules-<nonce>.md` at cycle start and read the cycle's own rules from there.
That makes "a cycle already running finishes under the rules it started with" a fact rather than an
intention. One command; not needed while only the spec is being written.

## Where everything lives

| What | Path |
|---|---|
| spec under review | `docs/superpowers/specs/2026-09-10-loop-rule-consolidation-design.md` |
| condition inventory (135 ids, committed) | `docs/superpowers/specs/2026-09-10-loop-rule-consolidation-condition-inventory.md` |
| this story | `docs/superpowers/stories/2026-08-29-loop-rule-consolidation-story.md` |
| successor, profile unconfirmed | `docs/superpowers/stories/2026-09-10-record-durability-story.md` |
| loop-termination story, profile unconfirmed | `docs/superpowers/stories/2026-09-10-harness-finding-termination-story.md` |
| pass files and dispositions | `.context/codex-reviews/gate-a-spec-awsf1ec771-pass-*.md` |
| precheck | `.context/spec-precheck.py` |
| pass prompt | `.context/gate-a-spec-prompt.md` |

**Two stories await a profile confirmation from Daniel** and are not executable until he gives it.
