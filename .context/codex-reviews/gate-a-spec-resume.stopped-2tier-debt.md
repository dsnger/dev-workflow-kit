# Gate A — spec cycle — RESUME NOTE (cycle-stable)

Cycle: reviewer-availability fallback, **two-tier** design (tier 1 + tier 3 human exception).
Story: `docs/superpowers/stories/2026-08-13-reviewer-availability-fallback-story.md`
Spec:  `docs/superpowers/specs/2026-08-14-reviewer-availability-fallback-design.md`
Both committed at `6c3e175`. Working tree clean as of this note.

## State

**Pass 1 complete and validated** — 30 findings (7 BLOCKER, 21 MAJOR, 2 MINOR), none
dismissed. File: `gate-a-spec-pass-1.md`. Dispositions with every call recorded:
`gate-a-spec-pass-1-dispositions.md`.

**Floor NOT met.** Minimum three passes with a clean final pass. Two more passes minimum,
and the pass-1 fixes are not yet applied to the spec.

The previous three-tier cycle is archived under `.stopped-3tier` (passes 1–3 + dispositions
+ its resume note). Older cycles are under `.pre-2026-08-14`. Do not reuse those slots
without archiving first — this cycle already destroyed one predecessor's artifacts before
that was noticed.

## Next action: apply pass-1 fixes to the spec, then run pass 2

All 30 are accepted. Decisions already taken (do not re-litigate):

1. **F1 + F19** — tier 3 is prohibited once any pass returned unremediated Blocker/Major;
   completed passes are preserved and named in the marker; §5's "clearly stuck → STOP and
   surface" is never remediable by tier 3.
2. **F2** — §4 keeps its "no sentinel, no invariant amendment" conclusion but **drops the
   Gate-B STOP from the justification**, and states the unchanged hook supplies no waiver
   control. (The STOP may not fire: docs-only exemption, prior counts, and it reaches the
   agent not the human.)
3. **F3** — debt cancellation requires a **different** accountable handle from the waiver
   authorizer, plus stated risk acceptance.
4. **F4** — an open/unreconciled debt row **blocks a subsequent tier-3 waiver** in that
   repository.
5. **F5 (human-confirmed)** — §5 requires an interactive pause for an explicit human
   response immediately before closure, named as **the decision-question pattern this
   workflow already runs**, not a new invention. §13 states plainly that nothing verifies
   the pause happened or that the recorded handle answered. **Escalation path recorded:**
   signed commit / protected-branch approval, *trigger — the first tier-3 record whose
   authorization is disputed or unattributable.*
6. **F9 + F10 + F11 + F30** — canonical cycle-id format; debt-row grammar with stable key
   and status; multi-story markers carry a list of row keys; a resolvable story citation
   is a tier-3 precondition; repayment uses the **closure-time** profile, referenced by an
   immutable story-commit identity, never a copied value.
7. **F18** — rebuild §8 from §5 **in document order**, uniquely identifying each atomic
   condition. Named omissions to restore: stop-and-surface, do-not-manufacture-findings,
   validate-before-applying, `workingDirectory` binding, branch-file acceptance and resume
   deletion, hook result-envelope limits, no-story and malformed-profile branches,
   per-story aggregation, counterfactual evidence, human-confirmed profile changes,
   `baseSha`/WIP mechanics.

Majors 6, 7, 12–17, 20, 23–27, 29 and minors 8, 28 are each accepted with a stated fix in
the dispositions file — apply as written.

## Story is already fixed

Findings 21 and 22 are **done** and committed: tier 3 is stated as new (not an extension of
§2.13), §1 is reframed around closure rather than weaker review, and all five open questions
are individually marked settled or moved. Do not re-amend for those.

## Standing riders for every pass

Mechanical sweep before each read pass; unioned risk+security lens sets appended once with
abuse carrying both labels; severity enum `BLOCKER|MAJOR|MINOR|NIT`; findings to file with
the exact terminator; delete the target and confirm gone before each call; one recovery
attempt per pass; do not let the reviewer read `.context/codex-reviews/`.
