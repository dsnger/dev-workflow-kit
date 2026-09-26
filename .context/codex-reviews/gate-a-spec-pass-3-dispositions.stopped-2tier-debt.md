# Gate A — spec — pass 3 dispositions (two-tier cycle) — CYCLE STOPPED

32 findings (12 BLOCKER, 19 MAJOR, 1 MINOR). None dismissed. Enum held a sixth time.

## Trajectory

| Pass | B | M | m | Spec lines |
|---|---|---|---|---|
| 1 | 7 | 21 | 2 | 349 |
| 2 | 8 | 20 | 6 | 538 |
| 3 | **12** | 19 | 1 | 610 |

Blockers rising while the artifact grows. Same shape as the three-tier cycle, and §5's stuck
condition applies again.

## The finding that settles it

**Blocker 2 — the debt-location fix creates a recursion, and it is the fix approved last
round.** Moving the debt record to a non-`.md` path so that erasing it costs a review means
the Gate-A closing commit now stages a product-classified file. That commit is therefore no
longer docs-only, so it raises a **Gate-B** obligation — during an outage, inside the very
waiver meant to escape one. Blocker 10 completes the circle: **every** debt-state transition
edits that file, so `accepted-no-review` cannot be committed during the outage without
ignoring Gate B, and marking a Gate-B debt `repaid` after a final pass changes the
fingerprint that pass covered. Codex's conclusion is the right one: *the settled "no hook
change" constraint is not compatible with the current record location.*

## The pattern, stated plainly

Every compensating control added to make the waiver safe has landed in one of two states:

1. **Unenforceable** — a prose assertion the waived party authors (blockers 15, 16; §13
   already concedes it), or
2. **Recursive** — real state that itself needs gating, and gating it needs the gate that is
   unavailable (blockers 2, 10).

That is not a sequence of fixable defects. It is what a gate waiver *is* in a prompt-only
system: the thing being waived is the only mechanism available to protect the record of the
waiver.

## The two fixes from last round both fail

**Blocker 13 — the scoped `mode override` is not a valid §5 profile change.** §5's grammar
permits a whole effective mode in the header and requires the header to carry the override;
there is no per-portion override semantics. I invented a fourth profile mechanism, and
Daniel confirmed it on my description. A gate reader must now either still demand `+check`
or classify the header/log combination as semantically inconsistent — which §5 says is a
STOP.

**Blocker 14 — and the gap it was taken for is not real.** A prompt-harness scenario does
discriminate: drive an unavailable reviewer and assert *prior refusal* versus *new
conditional closure*, with negative cases per precondition. So the override was taken on a
false premise as well as in an invalid form. Both must be withdrawn.

## Blockers — accepted, all of them

1 (Gate-A waivers are impossible under §3.1(6): implementation-derived evidence cannot exist
before implementation, and Gate A is the gate that blocks planning — where the outage
actually bit), 2, 4 (a waiver commit can delete prior debt rows in the same index; the
current-state scan then sees no cap history), 5 (the cap has no authoritative home,
derivation, multi-story semantics or parse-failure behaviour), 6 (two `accepted-no-review`
closures leave the cap at two with nothing repayable — tier 3 permanently disabled by a
permitted sequence), 7 (§5.3's equality rule and condition 2's different-handle rule are
mutually unsatisfiable), 8 (`Waived-range` SHAs are unreachable after amend/squash — the
durability argument covered only the Gate-A blob), 9 (no debt state machine), 10, 11
(ordinary `git revert` of the waiver commit erases the row and cap history), 13, 24 (the
inventory omits operative conditions for the **third** time — lens sets, "lenses are
questions not passes", Gate-B tool/range parameters, skip-reason rules, lower-profile
carryover, the non-enforcement residuals).

## Majors — accepted

3, 12, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 25, 26, 27, 29, 30, 31, 32. Notable: 25, 26
and 30 are three more **noun-based dispositions** in the inventory of exactly the kind the
`[corrected]` rows were added to warn against — "Re-review after every fix" and "`.off`; the
gates still apply" marked kept while their terminal effect changes, and "fires full Gate B"
claiming a mechanism when the hook only emits a reminder and always exits 0. 27 is a story
defect: AC 3 still asserts `sparring-briefing.md` moved entirely, which the spec itself now
contradicts.

## Minor

28 — the story misstates §5's floor as "three clean passes per gate".

## Recommendation

Stop and simplify, rather than stop and split. **The entire blocker cluster except 1, 13 and
24 is debt machinery** — the state file, the cap, reconciliation, rollback, concurrency,
recursion. That machinery exists to make the waiver *compensated*, yet §13 already concedes
nothing forces anyone to service it. It is elaborate, recursive, unenforceable state whose
delivered value is a row someone may ignore.

Removing it leaves a coherent, small feature: preconditions, a human pause, and a marker in
the commit body carried to `main`. No state file, no cap, no reconciliation, no rollback
problem, no recursion, and no invented profile grammar — the `+check` gap disappears with
blocker 14's harness scenario, so the override is withdrawn rather than repaired.
