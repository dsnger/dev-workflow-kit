# Gate A — spec — pass 3 dispositions — CYCLE STOPPED

40 findings (6 BLOCKER, 31 MAJOR, 3 MINOR). Enum held a third time.

## Trajectory

| Pass | Blocker | Major | Spec lines |
|---|---|---|---|
| 1 | 4 | 28 | 281 |
| 2 | 4 | 33 | 448 |
| 3 | 6 | 31 | 522 |

116 findings across three passes, **none dismissed**. Blockers rising while the artifact
grows. This is accretion, not convergence, and §5's stop condition applies.

## The four findings that stop the cycle

**Pass-3 B4 — rider (a) is incompatible with "no hook change", and it breaks TIER 1.**
Splitting one Gate-B pass into sequential `spec` then `quality` calls means the unchanged
hook increments its pass counter on **each** call. Three logical passes become six counted
ones, and the hook can report the floor satisfied before a pair's second branch exists.
This is a new mechanical false ✓ in **normal cross-model operation** — nothing to do with
degraded mode. Rider (a) was bundled here as a §5 prose edit; it is not one. It is a hook
change, or it is not shippable.

**Pass-3 B6 — debt repayment contaminates live gate state.** A later tier-1 repayment
review calls the same `exec`/`review` tools, so it increments the *current* cycle's
counters, and a Gate-B repayment stores a fingerprint of the *current* workspace rather
than the historical range it reviewed. The compensating control corrupts the control it
compensates for.

**Pass-3 B2 — the tier-2 trust boundary is not achievable in-repo.** Restates pass-2 B3 and
closes the door on the fix Daniel and I chose: a custom agent definition does **not** stop
the repository's `CLAUDE.md` hierarchy loading as instructions, and Claude Code offers no
per-agent switch to omit it. So the prompt product under review can address its own
reviewer before that reviewer treats anything as data. An agent definition improved the tool
allowlist; it did not create the boundary. Fixing it needs a sanitized external checkout or
an independently controlled harness — neither of which is a prompt-only change.

**Pass-3 B3 — the `.off` posture is the invariant-2 violation, not a residual.** A
workspace-global sentinel authorized for one cycle silences reminders for unrelated commits
in that workspace. That is the missed-commit direction invariant 2 names as dangerous.
Naming it in §16 does not make it compliant.

## Two more accepted, both mine

**B1** — tier 3 is a no-pass closure, so "the gate itself is not optional" is not KEPT as my
§11 inventory claims; it is **overturned**. Tier 3 is a gate waiver and the inventory
mislabels it.

**M20 / M33** — my pass-2 revision **dropped the packaging and backlog section entirely**.
Occurrence 3 (story AC 8), the 0.8.2 → 0.9.0 bump, the CHANGELOG entry and the parked rows
all vanished while I was fixing other findings. A regression introduced by the fix round,
caught by the review — which is the loop working, and also the sign that the artifact is
past the size one revision pass can hold.

## The remaining 25 MAJOR

All accepted, none dismissed. They cluster: schema completeness (24, 25, 35, 38), `.off`
state handling and races (21, 22, 29, 30), slot naming and atomicity (23, 39), debt
lifecycle (7, 9, 27, 28, 31), provenance and authorship (13, 40), downstream contradiction
(17), prompt-standards conformance (18, 19), Gate-B range validation (15), agent identity
(16), inventory completeness (10, 11, 12), squash ownership (26), AC 9 template parity (34),
validation coverage (32), and Bash-as-capability (14).

Not itemized further, because they are downstream of a scope decision that has to come
first.

## Recommendation

Stop the cycle and re-scope. The evidence is that this is an epic wearing a story's header:
at minimum the ladder, rider (a), and the tier-2 reviewer surface are three separable
specs, and two of the three need hook or harness work that the settled "prompt-only"
decision excludes. The story's §6 split rule anticipated one split; pass 3 says there are
more.

No further pass should run until that decision is made. Passes 1-3 stand as a record; none
of them was clean, so the floor is not met and nothing here is approved.
