# Gate A — Plan B cycle — CLOSED CLEAN at pass 7

Advisory human note. Not a findings file; participates in no pass validation.

## Closure

**Artifact:** `docs/superpowers/plans/2026-08-30-review-loop-economics-plan-b-records.md`
at commit `f132c57` (revision 8).

**Pass 7: CLEAN.** Validated structurally: exactly two lines, line 1 exactly `NO FINDINGS`,
line 2 exactly `END OF FINDINGS (0 total)`.

**Floor satisfied.** Story read fresh at close: risk `high`, security `none`. Under the rules in
force — the constant 3, since this cycle runs under the OLD rules by its own activation
constraint — the floor is 3. Seven passes run, final pass clean. **The cycle closes.**

## Curve, and the comparison with Plan A

| pass | findings | Blockers | Majors | B+M |
|---|---|---|---|---|
| 1 | 11 | 2 | 7 | 9 |
| 2 | 3 | 0 | 3 | 3 |
| 3 | 6 | 0 | 4 | 4 |
| 4 | 10 | 0 | 7 | 7 |
| 5 | 9 | 0 | 5 | 5 |
| 6 | 7 | 0 | 6 | 6 |
| **7** | **0** | **0** | **0** | **0** |

**Seven passes against Plan A's twelve, for comparable content in a leaner artifact.** The whole
saving came at the start: Plan A opened at 17 B+M and spent three passes shedding a
self-description layer; Plan B was written without one and opened at 9.

**Instrument and prose-about never reached a third of any pass** — 18%, 0, 17%, 20%, 22%, 14%.
The immediate-routeback condition never fired. Every pass was product churn on a genuinely
intricate mechanism, which is what the converged shape was supposed to leave room for.

## Coverage statement

**Reviewed across the seven passes:** both pinned grammars character-for-character against spec
§2.3 and §4 in every pass after the first; the nonce properties of §5 one at a time; the curve
and provenance properties of §4 and §2.3 one at a time; §6's accounting method applied to Plan
B's own passages; the §10 extension; **spec §9's exclusion list item by item**; the sequencing —
Plan A's fourteen edits then Plan B's six against the result, each OLD matching exactly once when
its task runs; all six assert-new patterns before and after in both copies; and the downstream
template for dependencies on this repo's layout.

**Not covered, by construction:** Plan C, which does not exist. Its five inherited obligations
are named in Plan A and carried forward.

**What this closure does not claim.** Gate A reviewed the plan, not the edits. Each task's single
check establishes that its edit landed at its site and nothing more. Correctness of what lands is
Gate B's, reading the real diff. *(Same boundary Plan A closed on, and the right sentence to carry
into every remaining closure.)*

## Three results worth keeping

**1 — A review finding that did not survive checking.** Pass 4 said the nonce property
contradicted the approved spec and story. Both already said what was shipped; what they also did,
and the plan had collapsed, was **separate the requirement from what a check can establish**.
That sharpened the absorb/route line: **a finding is absorbable when a fix implementing the
approved sentence exists** — and the spec's own §5-requirement/§8-checkability structure
demonstrated the shape of that fix. Plan A's pass-5 M1 routed because no such fix existed. Third
round on one axis is a signal to look for the route, not a rule that forces it.

**2 — A rule that described a situation which cannot arise.** Pass 5 asked for an observable
procedure for the slot refusal; the pass-5 fix gave one that was unreachable — resolving your own
path never yields a different nonce, and scanning the family would flag legitimate siblings.
Pass 6 caught the same defect in new words. The fix was to bind the rule to **the deletion step**
§5 already requires, which is where the damage actually happens and where the check is a question
about a path the step itself computed. **The incident that motivated the rule — a nonce-holding
cycle computing a legacy bare path and deleting another cycle's file — is exactly the case the
reachable version covers, and the unreachable version did not.**

**3 — A transcription that ate the thing it was transcribing.** Embedding the provenance grammar
through a string step interpreted `\"` as `"` and `\\` as `\`, silently rewriting **the
production that specifies which escapes are legal**. Both grammars are now inserted from the
spec's own block at build time and never re-keyed, and every later pass re-verified them
character-for-character.

## Tooling built during the cycle

The generator refuses to build unless **every assert pattern occurs exactly once in its task's
NEW text and zero times in its OLD**. It caught Task 1's pattern drifting three times as the slot
rule was rewritten — each time the plan's own check would have failed at execution.

**Its first falsification test did not fire**, because the sabotage truncated a word and the
truncation was still a prefix of the real text: a test that could not fail. Re-tested with a
genuinely absent pattern and with one that also appears in the OLD text; it fires on both, naming
the pattern and both counts. **§8's wiring rule, practised on my own tooling.**

## Residue

**None open.** All findings from passes 1-6 are resolved, or routed and answered, or collected as
Minor/Nit per §5. Pass 7 found nothing.

**Carried to the final-round story batch:** the criterion's worked example gains
"one per cycle; a change running N cycles holds N (e.g. five for this three-plan change)", so the
confirmed reading survives to the next reader rather than living only in gitignored notes.
