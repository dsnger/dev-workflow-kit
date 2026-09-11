# Gate A — spec cycle — RESUME NOTE (cycle-stable)

Cycle: reviewer-availability fallback, **stripped** design — tier 1 + tier 3 human exception,
no debt machinery.
Story: `docs/superpowers/stories/2026-08-13-reviewer-availability-fallback-story.md`
Spec:  `docs/superpowers/specs/2026-08-14-reviewer-availability-fallback-design.md`
Base commit `df850ab`; **pass-1 fixes are now applied in the working tree, uncommitted.**

## State

**Pass 1 complete and validated** — 28 findings (4 BLOCKER, 20 MAJOR, 4 MINOR), none
dismissed. `gate-a-spec-pass-1.md` + `-dispositions.md`.

**All 28 pass-1 fixes applied** (2026-08-14). Spec 489 → 750 lines. What changed:

- §2 recast as a **cost/trust trade-off** with a three-row alternatives table (F1); "every
  reader sees" → discoverable via `git log --grep` (F26).
- §3.1 rebuilt: complete-pass-ledger fail-closed rule (F10), fresh profile resolution as a
  common precondition (F18), a **waiver checklist** carrying the lens sets, invariants and
  the 12 prompt standards (F2, F17), Gate-B per-story modes/entries (F28); the mechanical
  sweep relabelled **syntax hygiene, not evidence**.
- §3.2 rebuilt: **canonical gate call** definition + defective-call exclusion (F3), and a
  full fresh-observation → enum transition table with a STOP row (F4).
- §3.4/§3.5: complete prospective record presented; **authorization digest** over tree *and*
  message (F8); dedicated index + **committed-tree comparison** as step 7 (F7); positively
  determined docs-only Gate-A tree (F6); **15-minute max age + post-answer probe** (F5).
- §4: **Gate-A continuation rule** at `executing-plans`, state-free and re-derived (F9);
  "authoritative" removed (F27).
- §5: `Authorized-tree`, `Profiles` (paths only), `Waiver-checklist` fields; `gate:` added to
  the decision block (F11); **new §5.4 field grammar** — handles, ISO-8601 UTC, escaping,
  200-byte bound, byte-level normalization (F12); §11 → §10 xref (F24).
- §6: **ordinary-merge chain and validation matrix** beside the squash chain (F13).
- §7: rows 33, 39, 44, 55–58, 61, 62, 65 corrected (F15–F19).
- §8: `docs/pr-review-bots.md` ~141 and `coding-workflow.md` ~253–268 added (F20, F21);
  marketplace.json row **re-pointed at the top-level `description`** (F22 — see below).
- §10: the **prompt-differential probe** specified concretely (F23) — driver, frozen
  `OLD`/`NEW` blob shas, S1 + 8 negative variants + S2, 3 runs all-must-agree, hard failure
  semantics, no new repo file. **The watch item is resolved; no whole-mode override needed.**
- §13: rollback split three ways — this repo, version-keyed caches, scaffolded copies (F25);
  new residual naming the checklist as self-audit.
- Story: §2 "re-review debt" → "untracked re-review obligation"; §5 "profile scales the
  repayment" overturned (F14), both with fourth-amendment accounting.

**One deviation from the recorded dispositions, deliberate:** F22 said drop the
`marketplace.json` row because the file does not carry the two-gates claim. The mechanical
sweep found that inspected the *plugin entry* (line 14); the **top-level `description`**
(line 4) does read "independent Gate A/B review". Took F22's stated alternative — re-point
the row — rather than dropping it.

**Pass 2 complete and validated** — 29 findings (14 BLOCKER, 13 MAJOR, 2 MINOR), none
dismissed, **all applied**. Spec 750 → 1016 lines. Enum shrank to two sources; §3.5 became an
eight-step close with expected-parent binding, `read-tree` init, changed-path classification
and a three-way read-back; §4 gained a second continuation point; §5.4 gained parity-aware
escaping and sha256 digests; §5.5 the checklist record; §6 an incident-invalidation
convention; §7 rows 82–87; §10 split into a mechanical oracle and a pinned-model probe.

**Pass 3 complete and validated** — 34 findings (15 BLOCKER, 18 MAJOR, 1 MINOR), none
dismissed, **none applied**.

## ⛔ CYCLE STOPPED 2026-08-14 — §5 stuck condition, surfaced to Daniel

Blockers by pass: **4 → 14 → 15**, artifact 489 → 750 → 1016 lines. Three pass-3 blockers are
the **unenforceable/recursive** pair that ended both prior cycles, now landing on tier 3's
core rather than on a removable sub-feature:

- **7** — both surviving outage sources are still locally manufacturable (exhaust the quota,
  point at a spent account, block DNS); a self-approving human author therefore has a
  sanctioned zero-review closure on demand. Codex's own fix says to acknowledge the abuse path
  that cannot be closed.
- **2** — in the motivating outage, `Passes completed: none` can never be *established*, so
  the waiver can never be granted in the case it exists for; loosening it reopens the
  lost-pass gate-off path.
- **3** — the governing-story union cannot be reconstructed, because prompts are not durable.

Plus **27**: two rounds of fixes turned a prose amendment into a git algorithm whose
highest-risk logic §10 exercises not at all, so the mode's evidence is unsatisfied for a risk
path the fixes themselves created.

**Do not run pass 4 without a decision from Daniel.** Full triage in
`gate-a-spec-pass-3-dispositions.md`.

Two earlier cycles are archived and must not be overwritten: `.stopped-3tier` (three-tier
design, passes 1–3) and `.stopped-2tier-debt` (two-tier with debt machinery, passes 1–3).
Older cycles are under `.pre-2026-08-14`. **Archive before reusing any slot** — this story has
already destroyed one predecessor's artifacts through slot collision.

## Why this cycle looked different, and then did not

After pass 1 this read: blockers three-tier 4 → 4 → 6 (stopped); two-tier+debt 7 → 8 → 12
(stopped); stripped **4** — *"and none of the four says the mechanism cannot exist."* That
held through pass 2 and **failed at pass 3**, where findings 2, 3 and 7 put the
unenforceable/recursive pair on tier 3's core. The earlier optimism is kept here rather than
deleted, because it was the reasoning that justified spending passes 2 and 3, and a future
reader deciding whether to restart should see what it was based on.

## Standing riders for every pass

Mechanical sweep before each read pass (it has now caught a wrong finding total, a stale
cross-reference, a wrong `marketplace.json` field and a bare `CHANGELOG.md` path); unioned
risk+security lens sets appended once, abuse carrying both labels; severity enum
`BLOCKER|MAJOR|MINOR|NIT`; findings to file with the exact terminator; delete the target and
confirm gone before each call; one recovery attempt per pass; the reviewer must not read
`.context/codex-reviews/`.
