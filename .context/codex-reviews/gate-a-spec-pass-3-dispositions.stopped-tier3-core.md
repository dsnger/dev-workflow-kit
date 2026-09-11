# Gate A — spec — pass 3 dispositions (stripped design) — **CYCLE STOPPED**

34 findings (15 BLOCKER, 18 MAJOR, 1 MINOR). **None dismissed. None applied** — the cycle is
stopped under §5's stuck condition and surfaced to Daniel.

## The stuck test fires

| Cycle | Blockers by pass | Outcome |
|---|---|---|
| Three-tier | 4 → 4 → 6 | stopped |
| Two-tier with debt machinery | 7 → 8 → 12 | stopped |
| **Stripped** | **4 → 14 → 15** | **stopped** |

Artifact size across the same three passes: 489 → 750 → 1016 lines. Every round of fixes has
produced a larger crop of blockers **inside the fixes**. Pass 2's dispositions argued this was
explained by new surface and that none of its blockers said the mechanism could not exist.
Pass 3 falsifies the second half of that argument.

## Three findings say the mechanism cannot exist — the same shape that killed two cycles

Design §2 records what ended the debt machinery: every compensating control landed as
**unenforceable** (a prose assertion by the party being waived) or **recursive** (state that
itself needs the unavailable gate). Pass 3 lands that pair on tier 3's **core**, not its
bookkeeping.

**7 — both surviving outage sources are still locally manufacturable.** Pass 2 removed
`auth-failed` because withholding a credential fakes an outage. The identical argument
defeats what is left: exhaust the account's quota on purpose, point at an
already-exhausted account, or block DNS to produce two transport failures. A transport
failure does **not** establish that the vendor answered, which §3.2 line 191 claims it does.
A human author may self-approve (§3.3), so inducing either source yields a **sanctioned
zero-review closure on demand**. Codex's own suggested fix ends with "explicitly acknowledge
any abuse path that cannot be closed" — the remedies it names (independently obtained
provider evidence, a bound reviewer identity) do not exist in a prompt-only system.
**Unenforceable.**

**2 — the motivating case cannot satisfy its own central precondition.** Tier 3 exists for the
outage where *no pass could be taken*. Pass 2's fix requires the pass ledger to be
*establishable* and fails closed otherwise. But §3.1(2) itself states that session memory,
`.context/` slots and the hook counter are all non-authoritative, and at Gate A there is no
prior commit body — so in exactly the motivating scenario `Passes completed: none` can never
be established, and the waiver can never be granted. Loosening it to "absence observed"
reopens the lost-pass gate-off path the rule exists to close. **Recursive.**

**3 — the governing-story union has the same shape.** Pass 2 bound the profile to every story
path cited anywhere in the cycle, to stop a citation being dropped to shed a `high` profile.
Prompts are not durably recorded, so the union cannot be reconstructed; fail-closing makes
every resumed waiver unusable. **Recursive.**

## The rest are ordinary, and several are in machinery pass 2's fixes introduced

**The git algorithm is wrong in five places** — 4 (Gate B's parent is the WIP, so §3.5 writes a
*follow-up* commit, not the amend §5 Mechanics requires, and the diff digest then covers only
post-WIP changes: a Gate-B gate-off path), 5 (no atomic ref compare-and-swap; the `HEAD ==
parent` check and the commit are separate operations), 20 (squash copies a marker whose
parent, tree and message describe a commit that is then unreachable — the three-way read-back
cannot be applied to the carrier), 21 (the invalidation record reproduces `Reviewer-tier: 3`
verbatim, so §6's own discovery grep counts the invalidation as a **new apparent closure**),
23 (no rollback state defined between a failed read-back and the retry).

**27 is the one that reframes the whole thing.** The design's highest-risk logic is now
git-level — dedicated index, parent selection, ref replacement, amend, collapse, read-back,
squash carry — and §10 deliberately exercises **no git operation at all**. A model agreeing
with prose cannot surface a data-loss, race or wrong-parent defect, so
`battery+check+verification` is unsatisfied *for the risk path this design actually
introduces*. That risk path did not exist two passes ago: it was created by the fixes.

**Also real:** 6 (a Gate-A tree may carry unrelated specs, plans and stories that get neither
their own Gate-A decision nor Gate B — a second closure route inside the one being fixed), 10
(`attempt-failed` can never complete the ordered close under its own recovery budget), 11
(`authorizes` and `reason` are unbound after the answer), 12 (equality strips whitespace while
digests cover exact bytes — the mechanism proves less than the text claims), 13 (no cardinality
or ordering rules, so a crafted message can present different values to different parsers),
17 (continuation binds the artifact blob but not the governing rules, so an authorization
outlives the conditions it was granted under), 31 (the **fifth** inventory is still
incomplete), plus 8, 9, 14, 15, 16, 18, 19, 22, 24, 25, 26, 28, 29, 30, 32, 33, 34.

**1** is a clarity defect worth noting on its own: the design's History paragraph and the
story's profile comment both cite pass numbers from the *earlier stopped cycles*, which reads
as though results from the pass now running were already known.

## Why this is a stop and not a pass 4

§5's stuck condition is "clean or clearly stuck". Three signals together:

1. **Blockers rising across every pass of every cycle of this story**, now for the third time.
2. **The unenforceable/recursive pair has reached the core.** In the two prior cycles it lived
   in tier 2 and in the debt machinery — both were successfully cut out, and the cycle
   restarted smaller. Findings 2, 3 and 7 are not attached to a removable sub-feature; they
   are attached to *"a human may authorize a zero-pass closure"* itself.
3. **The fixes are generating the defects.** Two rounds of hardening turned a prose amendment
   to §5 into a git algorithm that now needs its own throwaway-repository test harness (27) —
   and §13 has said throughout that none of it constrains a non-compliant agent.

Nothing here is dismissed and no fix is refused. The question is whether to keep hardening a
mechanism whose own §2 argument now applies to its centre — and that is Daniel's call.

## Status

**STOPPED and surfaced.** Floor met by count (3 passes), final pass not clean. Pass-3 fixes
are recorded and unapplied. The spec and story are **uncommitted in the working tree** at the
post-pass-2 state (`df850ab` + pass-1 and pass-2 fixes).
