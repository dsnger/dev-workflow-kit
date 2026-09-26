# Gate A — spec cycle — RESUME NOTE (cycle-stable)

Cycle: reviewer-availability fallback ladder.
Story: `docs/superpowers/stories/2026-08-13-reviewer-availability-fallback-story.md`
Spec:  `docs/superpowers/specs/2026-08-14-reviewer-availability-fallback-design.md`

## State at interruption (2026-08-14)

**STOPPED at pass 3 under CLAUDE.md §5's stuck condition. The floor is NOT met — no pass
was clean, so nothing here is approved and the spec must not proceed to `writing-plans`.**

Passes 1, 2, 3 all ran, all validated structurally (terminator, count, grammar, enum), all
returned Blocker/Major. 116 findings, **zero dismissed**. Findings and dispositions:
`gate-a-spec-pass-{1,2,3}.md` and `gate-a-spec-pass-{1,2,3}-dispositions.md`.

Blockers rose 4 → 4 → 6 while the spec grew 281 → 448 → 522 lines.

## Why it stopped, in one line each

- Rider (a) double-counts the hook's pass counter at **tier 1** — a hook change, not a §5
  prose edit.
- Debt repayment reviews contaminate the live cycle's counters and fingerprint.
- The tier-2 trust boundary is unachievable in-repo: repository `CLAUDE.md` loads into any
  custom agent and there is no per-agent switch.
- The workspace-global `.off` posture is an invariant-2 violation rather than a residual.

## Awaiting

A scope decision from Daniel. The recommendation on the table is to split: the ladder,
rider (a), and the tier-2 reviewer surface are at least three specs, and two need hook or
harness work the "prompt-only" decision excludes.

## Not yet done, if the cycle resumes as-is

The pass-2 revision **dropped** the packaging/backlog section: story AC 8's occurrence-3
append, the 0.8.2 → 0.9.0 bump, the CHANGELOG entry, and the parked rows are all missing
from the current spec and must come back regardless of how the scope decision lands.

## Repo state

Story committed (`e420420`), amended in the working tree for AC 6 — **uncommitted**.
Spec committed at its pass-0 text (`3c5712c`); the working tree holds the pass-2 revision —
**uncommitted**. Prior cycles' 44 `gate-a-spec-*` artifacts were preserved under a
`.pre-2026-08-14` suffix; pass 1 of this cycle destroyed the previous cycle's
`gate-a-spec-pass-1.md` and its dispositions before that preservation was put in place.
