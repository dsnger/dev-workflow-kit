# Gate A — spec — pass 2 dispositions (two-tier cycle)

34 findings (8 BLOCKER, 20 MAJOR, 6 MINOR). None dismissed. Enum held a fifth time.

## Trajectory

| Pass | B | M | m | Spec lines |
|---|---|---|---|---|
| 1 | 7 | 21 | 2 | 349 |
| 2 | 8 | 20 | 6 | 538 |

Blocker count is flat-to-up, but the **kind** changed: pass 1's blockers said the
compensating controls did not exist; pass 2's say the controls I added have specific,
namable holes. Four of the eight are outright errors of mine with obvious fixes. That is
movement, not the wall the three-tier cycle hit — where each pass found the mechanism more
impossible than the last.

## Blockers — mine, fixable, taken

**2. My §11 matrix contradicts my §13.** The matrix says self-authorization, same-approver
acceptance, a second waiver and stale confirmation are "refused"; §13 says nothing is
enforced and an agent can write a conforming block. Both are mine. **Fix:** the matrix
describes **observable manual behaviour** — "the procedure refuses" — never a mechanism, and
drops "no decision block is producible", which is false.

**3. My counterfactual is backwards.** Under the prior policy tier 3 does not exist, so a
compliant agent refuses *every* tier-3 closure and the advisory hook permits the commit both
before and after. Nothing makes the old state uniquely succeed. GOES TO DANIEL — §5 calls an
unobservable counterfactual a **blocking evidence gap** requiring a logged mode override, and
that is his call, not mine.

**8. Pinned SHAs are immutable but not durable.** Story-commit and Gate-A blob SHAs taken
from WIP or pre-squash history become unreachable after amend/squash and are collectable;
and if the profile changes in the closing amend, embedding that commit's own SHA in its own
row is self-referential. **Fix:** anchor identity in `main` and make the row carry a
self-contained snapshot of what it must repay, rather than a reference that can evaporate.

**9. The inventory is still thematic — second occurrence.** I rebuilt it to 60 numbered rows
in document order and it is *still* a compression: the named omissions include the hook's
spec/plan indistinguishability and reset timing, full companion and resume-note lifecycles,
fresh-rerun deletion scope, result-envelope residuals, exact Gate-A prompt inputs, the
Gate-B path classifier, and WIP/`baseSha` mechanics. **Fix:** derive from each operative
sentence and list item, not each theme. Noting for the record that I have now claimed
exhaustiveness twice and been wrong twice.

## Blockers — real holes, fixes taken

**4. Tier 3 must not waive the profile's evidence obligations.** Nothing currently requires
the battery, the check, the named verification, `+abuse-path`, or a revalidated evidence
entry before a waiver. **Fix:** tier 3 waives **reviewer passes only**; every mode-derived
obligation stays a precondition, with refusal cases for missing, stale or inadequate
evidence.

**5. `todos.md` becomes authoritative gate state while staying prose-exempt.** Debt rows can
be deleted, edited or falsely closed in a commit Gate B never sees — and my §8 row 43 marks
prose-vs-product classification "Kept, untouched" while doing exactly that. **Fix:** either
the debt record moves somewhere gate-classified, or the classifier disposition changes
honestly. Both are real options; taking the second and marking row 43 **narrowed**.

**6. Two handles can alternate indefinitely.** Approver waives, accepter cancels the debt,
next waiver is available again — unbounded zero-pass cycles with every rule followed.
**Fix:** a cumulative cap on consecutive waivers whose reset requires an actual completed
tier-1 repayment. The "different handle" rule alone creates this, and it was my fix for
pass-1 finding 3.

**7 rides with it. ACCEPT** — the `reconciled` state escapes a block phrased for "open or
unreconciled", and post-land reconciliation *creates* that state. Three states: open-
unreconciled, open-reconciled, closed; refuse tier 3 for anything but closed.

## Blocker 1 — goes to Daniel

Every compensating control is authored by the agent whose work is being waived. Daniel
decided this knowingly (procedure + disclosure; enforcement parked with a trigger), so a
bare re-raise would not reopen it. **Pass 2 brings new information that he was not given:**
blockers 5 and 6 show the *debt* — the control his decision leaned on — is itself
bypassable in two specific ways, by editing a prose-exempt file and by alternating handles.
The question is therefore no longer "is prose enforceable" but "does the compensating
control survive contact with the abuse path".

## Major — accepted, fixes taken without further comment

10 (`sparring-briefing`'s rule also forbids treating a satisfied human as a substitute for a
clean pass — that clause did **not** move with tier 2 and my accounting said it did), 11
(zero-finding early exit is overturned for tier 3, not kept), 12 ("skip ONLY trivial" is
narrowed by effect regardless of calling it a waiver), 13 (the uncited-artifact path *is*
changed and row 45 denies it), 14 (marker cannot represent completed-passes-with-dispositions
— add pass ids and per-finding dispositions), 15 (merge strategy is a precondition with no
field to record it), 16 (no source category exists for the fresh-attempt branch), 17 (solo
case makes the different-handle rule impossible or alias-satisfiable), 18 (concurrent
branches can collide on cycle id and each pass the debt check), 19 (two separate clean
reviews never review the integrated result), 20 (Gate-A repayment is undefined once findings
require revising the artifact), 21 (a corrective commit cannot make the *closing* commit
contain the blocks — AC 2 names that commit), 22 (no precedence rule for the hook's STOP
against an authorized waiver), 23 (the companion cannot be written before the hook counts —
PostToolUse fires first; reword to "before the reader credits the pass"), 24 (the row is not
self-contained as claimed), 25 (calling a waived range `reviewed` is the gate-proof Don't in
one word), 26 (more falsified sites: `getting-started` line 84, `coding-workflow` 27–29,
91–99, 108–109, 123–126, README daily-use), 28 (a status page does not prove *this* account
cannot call), 33 (the pinned story SHA is recorded and never consumed by the repayment).

## Minor — collected

27 (the `coding-workflow` 149 sentence is about the **quality** gate, not the review gate —
my site row is wrong and would weaken an unrelated guarantee; mark untouched), 29
(sanitization covers `Cause` but not the free-form reason field), 30 (the first waiver's debt
blocks the next, so tier 3 advances **one** cycle per outage — the story's "work continues"
oversells it), 31 (no equality rule binds the handle/date across the two blocks), 32 (the
enum-drift line and the per-finding dispositions grammar are undefined against each other),
34 (unstated whether an open debt blocks a normal tier-1 cycle or only tier-3 eligibility).

## Status

Not clean. Two go to Daniel — blocker 1 (new evidence against a settled decision) and
blocker 3 (a blocking evidence gap that only a logged mode override can resolve). Every
other fix is taken.
