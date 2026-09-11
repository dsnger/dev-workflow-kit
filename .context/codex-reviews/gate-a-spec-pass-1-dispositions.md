# Gate A — spec — pass 1 dispositions (salvage cycle)

15 findings (3 BLOCKER, 10 MAJOR, 2 MINOR). **14 applied; finding 12 dismissed with its
reason, human-confirmed.** That is the first dismissal in 319 findings across four cycles.

## Where this sits against the three stopped cycles

| Cycle | Blockers by pass | Findings pass 1 |
|---|---|---|
| Three-tier | 4 → 4 → 6, stopped | 37 |
| Two-tier + debt | 7 → 8 → 12, stopped | 30 |
| Stripped tier 3 | 4 → 14 → 15, stopped | 28 |
| **Salvage** | **3** | **15** |

Half the finding count of any predecessor, and — the part that matters — **the three blockers
converge on one fix, and that fix was available immediately.** No finding says the mechanism
cannot exist. The mechanism is a paragraph.

## The three blockers are one blocker

**1, 11 (and 5 supplies the fix).** The draft wrote the record form as covering *"a pass short
of the floor, an absent bot review, a check that could not be run"* while asserting it
authorized nothing. Pass 1 rejected that as a distinction without a difference: a normative
instruction shaped *"when a human decides to proceed past X, write this"*, a required commit
form, and §6 routing the stall through it **is** a route past the gate, whatever the
surrounding sentence claims. A compliant agent reads assent + three lines as sufficient to
continue after a STOP — the waiver §1 found unbuildable, re-entering through the prose. And
11 makes it mechanical rather than a matter of reading: with below-floor cases included,
`docs/getting-started.md` ("Gate A is not skippable at any level"),
`docs/coding-workflow.md` and `docs/sparring-briefing.md` ("do not treat a satisfied human as
a substitute for a clean pass") are all falsified, and §4's claim that they stay true is
simply wrong. Both quotes verified in the working tree.

**Finding 5 gives the fix, and it is the more embarrassing half:** the draft mis-stated its
own precedent. PR #14 was a merge past an **absent supplementary PR-bot review** on a change
that **had already passed Gate B**. Never a core-gate closure.

**Fix, applied as new §2.0:** the form is scoped to what the precedent actually covers —
*it applies only where §5's own gates are satisfied, and never to a gate, a floor, a pass
count, or a profile-derived evidence obligation.* The shipped paragraph carries that scope
itself, including the sentence "if you are reaching for this form to get past a gate, the
answer is no". This is not a softening; it is the difference between a record and a waiver,
and it makes §4's untouched-sites claim true rather than aspirational.

**2.** "A reader can see that a human chose" overclaims, while the same paragraph admits
nothing verifies the handle or the pause. The gate-proof Don't, applied to a record instead of
a mechanism. **Fix:** the shipped text now says the record is an **unverified assertion** and
that a reader learns only that *the commit claims* a human chose.

## Majors and minors — applied

**3** — §1's finding overclaimed impossibility with no defined properties. Rewritten: §1.1
names the four properties ("safe" = grounded, guarded, bounded, attributable), §1.3 maps each
failure mode to the design class it defeats and says *why* it is structural, and §1.5 states
plainly that this is repeated structural failure, **not** exhaustion of the design space — a
class resting on authority outside the repository is untouched by this evidence. Turning the
gate-proof calibration rule on a negative claim was the right call and the artifact is more
useful for it.

**4** — four accounting rows were not enough; the draft's wording created edges beside several
of §5's terminal actions while claiming everything was untouched. §2.3 now lists sixteen
clauses individually, including the floor, the clean-final-pass rule, the zero-finding exit,
the stuck STOP, recovery-and-STOP, INCOMPLETE discounting, the triviality skip, mode
obligations, the evidence-gap override, and work-gap-vs-setup-gap.

**6** — rider (b) contradicted §5's "companions never validate a pass". This *was* accounted
for in the rejected design (its row 29, "narrowed in one named scope") and the accounting was
lost in the rewrite. Restored, and both prompt copies must state the narrowing in the
companions clause itself.

**7** — a disappearing drift record discounts a pass with nothing rechecking credited passes.
Added: a pre-close audit before the final pass and again before the closing commit, with
numbering and STOP behaviour defined.

**8** — the drift grammar was a sketch. Now complete: position, multiplicity, line-list
ordering, token escaping, empty-token handling, Gate-B `full` per branch.

**9** — the carry chain described only Gate B's amend flow. Added §2.4: per-gate placement,
accumulation, the identical-collapse and differing-both-kept rules, both merge strategies, and
an explicit statement that **carry is instruction-backed** — nothing validates it.

**10** — verified mechanically and correct: the tier-2 story asserted at three live sites that
tier 3 exists, closes with no passes, and unblocks work, including an open question asking
whether tier 2 is worth building "once tier 3 exists". Amended with old-condition
dispositions; both stories added to §4's site list.

**13** — the `+check` lived only in a story comment, so a plan could implement the edits and
skip it. Promoted to a new §5 Validation: fixture, before/after, both prompt copies, and the
counterfactual, which is the observation PR #23 actually produced.

**14** — `§4` → `§5` xref. Applied, and then the section renumber moved the backlog to §6, so
the mechanical sweep caught the same class again on the rewritten text and fixed it to §6.
Second time the sweep has paid for itself this cycle.

**15** — the tracked-debt trigger presupposed a follow-up obligation the shipped form does not
create. Re-stated as an observable event: a human explicitly asks for follow-up and it is
later found not to have happened.

## Finding 12 — DISMISSED, human-confirmed 2026-08-14

**This is the first dismissed finding across all four cycles — 319 findings in.** Labelled a
dismissal rather than "held", because in protocol terms a finding not applied is dismissed and
owes its one-line why. Daniel's reasoning, recorded verbatim as the why:

> Finding 12 was written against the pre-§2.0 draft, where the form sat on a path past a gate
> and a forged handle would have covered unreviewed work; under the applied scope the record
> authorizes nothing and labels its handle unverified, so false attribution misstates who
> accepted a non-gate shortfall — **authorship metadata, not a trust boundary**. Axis values
> track the definition, not lens-set cheapness; **an axis that fires on any name field stops
> discriminating.**

Security stays `none`; mode stays `battery+check`; passes 2–3 run with no lens sets. The
profile log gains no entry, because no value moved.

### The finding as written, and the analysis it was dismissed against


Pass 1 argues security should return to `standard`: the form names *who decided* via a handle,
its admitted central gap is that the handle is unverified, and dropping the roles /
trust-boundaries lens on precisely the change whose risk is false attribution is
substantively inconsistent even though the syntax and derived mode are valid.

**Against it, and this is why it is closer than pass 1 assumed:** the finding was written
against the **pre-§2.0 draft**, where the record sat on the path past a gate — there, a forged
handle would have covered an unreviewed change. Under the applied scope it authorizes nothing,
satisfies no evidence obligation, and the shipped text labels itself unverified. A false
attribution now misstates who accepted a *non-gate* shortfall. That is a real but small thing.

**For it:** "touches no role" is not quite true of a form whose second field is a person's
identity, and lens sets are cheap.

Surfaced rather than decided, because §5 makes a profile change proposed, human-confirmed and
logged, and this would have reversed an axis set the same day. Answered above.

## Status

Not clean; floor not met (1 of 3). **14 of 15 applied, 1 dismissed with its reason.**
Proceeding to pass 2.
