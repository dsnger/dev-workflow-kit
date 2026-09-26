# Gate A — spec — pass 1 dispositions (two-tier cycle)

30 findings (7 BLOCKER, 21 MAJOR, 2 MINOR). None dismissed. Enum held a fourth time.
Prior three-tier cycle archived under `.stopped-3tier`.

## Shape

Total findings fell 40 → 30 and changed character: the stopped cycle's blockers said the
mechanism could not exist; these say a coherent mechanism has weak controls. That is a
reviewable design with holes, not an unbuildable one.

## Blockers — my calls

**1. Tier 3 after an adverse pass. ACCEPT, and it is the sharpest finding of the cycle.**
Nothing stops tier 3 being entered *after* a pass returned unresolved Blocker/Major, and the
marker then says "no qualifying passes" and carries none of those findings. A genuine outage
after a bad pass becomes a sanctioned way to erase review evidence and land the exact
defects the gate found. **Fix, taken:** tier 3 is prohibited once any pass in the cycle has
returned Blocker/Major that is not remediated or individually human-dispositioned in the
waiver record. Every completed pass is preserved and named in the marker.

**19 rides with it. ACCEPT.** §5's own "clearly stuck → STOP and surface" must be stated as
*never* remediable by tier 3, or the rule that stopped the previous design becomes a waiver
path. Ironic and correct.

**2. The STOP-as-control argument. ACCEPT — it is a rationalization and it is mine.**
§4 rests the whole no-sentinel case on a STOP that may not fire: a Gate-A closing commit is
docs-only and exempt, Gate B can read satisfied from previously counted calls, and the hook's
output goes to the **agent**, not to the authorizing human. **Fix, taken:** §4 keeps the "no
sentinel, no invariant amendment" conclusion — which stands on its own, since nothing needs
silencing — but drops the STOP from the justification entirely and states that the unchanged
hook supplies **no** waiver control.

**3. Debt closable by logged decision. ACCEPT.** "Not in the cycle that created it" is a
one-cycle delay, not a separation. **Fix, taken:** cancellation requires a **different**
accountable handle from the one that authorized the waiver, plus an explicit stated risk
acceptance. Separation of duties, not a cooling-off.

**4. "Checked" with no due event. ACCEPT.** **Fix, taken:** an open, unreconciled or
unreviewed debt row **blocks a subsequent tier-3 waiver in that repository**. That is a real
consequence using machinery that exists, and it stops waivers compounding silently.

**5. Human authority is forgeable text. ACCEPT.** GOES TO DANIEL — it decides what the
feature claims, not how it is worded.

**9. Cycle-id and debt-row schema undefined. ACCEPT.** **Fix, taken:** canonical cycle-id
format, debt-row grammar with a stable key and status field, and creation/update algorithms.
11, 10 and 30 fold in here — multi-story markers carry a list of row keys, an uncited
artifact makes a resolvable story citation a tier-3 precondition, and the repayment profile
is the one at closure, referenced by an immutable story-commit identity rather than a copied
value.

**18. The inventory is still thematic while claiming to be paragraph-by-paragraph. ACCEPT,
and it is an overclaim of exactly the class this repo regenerates.** I asserted the method
rather than performing it. **Fix, taken:** rebuild §8 from §5 in document order, uniquely
identifying each atomic condition, with the twelve-plus omissions named (stop-and-surface,
do-not-manufacture-findings, validate-before-applying, `workingDirectory` binding, branch-file
acceptance and resume deletion, hook result-envelope limits, no-story and malformed-profile
branches, per-story aggregation, counterfactual evidence, human-confirmed profile changes,
`baseSha`/WIP mechanics).

## Story defects — accepted, and my amendment was incomplete

**21. ACCEPT.** The story still says tier 3 "exists today for the init-time case" while the
spec says calling that existing practice would be false. The authoritative artifact and the
design disagree about whether this is an extension or a new waiver.

**22. ACCEPT, and it falsifies my own accounting.** The story's §1, §5 and §6 still frame the
problem as needing vocabulary for a *weaker review*, still carry five tier-2 open questions,
and still size the work around what a tier-2 pass means. My amendment claimed tier 2 moved
"in its entirety". It did not. Every one of those must be marked moved with its destination,
and §1/§6 restated around the zero-pass exception.

## Major — accepted without further comment

6 (role definitions: author / implementer / gate operator / waiver approver / debt accepter,
including the solo-user case), 7 (outage confirmation sources, sanitized, with a validity
window and revalidation before closure), 12 (Gate-A debt records artifact path + immutable
blob identity, since `baseSha` does not identify text passed to `exec`), 13 (original +
remediation range mapped to the tool's single-range interface), 14 (ordinary-merge identity
and base selection), 15 (corrective commit reproduces the canonical blocks, not just names
the loss), 16 (supported merge strategy becomes a tier-3 precondition, recorded), 17 (a
backward-compatible debt-servicing procedure that survives rollback), 20 (`docs/getting-
started.md` says Gate A is not skippable at any level — a missed product-claim site, plus
`coding-workflow.md`'s pipeline overview), 23 (both blocks mandatory, ordered and linked, each
validated independently), 24 (the counterfactual is tautological — rebuild it around a
load-bearing claim), 25 (adversarial negative cases: forged authorization, self-authorization,
stale outage evidence, secret-bearing reasons, unresolved findings, immediate write-off), 26
(`AGENTS.md` omitted from prompt-conformance scope though §9 changes it — invariant 11), 27
(I described the version bump as *already verified* by a checker that cannot run before the
commit exists: an unverified-enforcement claim), 29 (companion lifecycle for enum drift:
write order, grammar, retention, behaviour if it disappears).

## Minor — collected

8 (tie "sustained timeout" to the configured MCP timeout and the recovery attempt), 28
(appending occurrence 3 *does* edit the `todos.md` item — "never edited" belongs to the
hardening ledger, not here).

## Status

Not clean. One question goes to Daniel (finding 5) because it decides what tier 3 claims to
be; every other fix is taken and does not need him.
