# Gate-A (spec) resume note — review-loop-economics

Cycle-stable, per CLAUDE.md §5's optional-companions rule. Written 2026-08-29 because the
session is about to be compacted. Advisory: nothing depends on it existing, and the repo state
plus the pass files are authoritative wherever this disagrees.

## Where things stand

- **Branch:** `review-loop-economics`. Working tree clean at `c513094`.
- **Spec:** `docs/superpowers/specs/2026-08-28-review-loop-economics-design.md`, **revision 11**
  (`c513094`), 648 lines.
- **Story:** `docs/superpowers/stories/2026-08-28-review-loop-economics-pass-floor-story.md`,
  **eleven** acceptance criteria. Profile `risk high · security none ·
  battery+check+verification` — **read it from the header, never from here**.
- **Slot discriminator: `rle`.** Never write a bare `gate-a-spec-pass-N` slot: doing so once
  destroyed a previous cycle's findings file in this very cycle.

## Gate-A spec loop — where the counter actually is

**Pass 10 has RUN and its findings are UNPROCESSED.** A hold arrived to pause after pass 9, but
the pass-10 call was already in flight and returned; the file is valid and on disk.

| Pass | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 |
|---|---|---|---|---|---|---|---|---|---|---|
| findings | 27 | 30 | 54 | 40 | 33 | 34 | 32 | 33 | 28 | **27** |
| Blockers | 5 | 2 | 0 | 4 | 0 | 3 | 9 | 4 | 2 | **2** |
| Blocker/Major | 24 | 22 | 43 | 31 | 30 | 26 | 29 | 28 | 22 | **23** |

Files: `.context/codex-reviews/gate-a-spec-rle-pass-{1..10}.md`, all validated (terminator exact,
counts matching, no non-finding lines). **These files are the durable record of this loop** and
are gitignored — do not clear `.context/` without extracting them.

**Floor is long met. NOT clean** — 23 Blocker/Major at pass 10. Zero tells at pass 9; pass 10's
tells are **not yet computed**.

## Next step, concretely

1. **Read `gate-a-spec-rle-pass-10.md`** — 2 Blocker, 21 Major, 2 Minor, 2 Nit — and work the
   Blocker/Major. Validate each finding against the tree before applying; Codex is advisory.
2. Compute and report the **three lines** (trend, cluster, require↔withdraw) — the duty is active
   from pass 4 onward, and **two tells make stop-and-surface mandatory, not discretionary**.
3. Revise, commit, then **pass 11**.

**Order of operations, learned the hard way — four occurrences:** *issue the gate call first, then
write the report.* Never write "running pass N" in a message unless the call is already in flight.
No turn ends on an announcement.

## The pass call

`mcp__codex__exec`, `workingDirectory` = repo root. Delete the target and confirm it gone first.
The instruction must **open with the `superpowers:brainstorming` directive**, carry the intent, the
settled decisions as INPUTS, the **risk-high lens set once** (threats, abuse, rollback, data loss,
idempotency, compatibility, observability), a mechanical-verification demand (line citations,
quotes against **both** §5 copies, stated counts against their own enumerations, re-run §6.1's
grep), coverage-first with `NO FINDINGS` as the clean signal, and the file protocol writing to
`.context/codex-reviews/gate-a-spec-rle-pass-<p>.md`. Reply is one line.

Earlier pass instructions are recoverable from this session's transcript; the shape above is what
matters.

## Standing rules for this cycle

- **Contract questions route to the sparring session `dev-workflow-kit-56`**, never to a dialogue.
  Daniel is reached only through it. Spec and plan approval are delegated to that session
  (Daniel, 2026-08-28); **§5's named human confirmations are not** — profile changes,
  STOP-and-surface closures, human exceptions, and any contract question the sparring session
  cannot ground in Daniel's recorded decisions.
- Record decisions as **"sparring session, under Daniel's 2026-08-28 delegation"** — never imply
  Daniel reviewed something he did not.
- **Owed at the final clean pass:** an explicit **coverage statement**, including the spec's
  claims about the `/workflow-init` mirror. Those were verified mechanically on 2026-08-29 —
  template fenced 192–778 with §5 at 257–777, the prose-exemption rationale confirmed **absent**
  from the template (that is §7's prerequisite, not a defect), all 21 §6.2 passages present
  exactly once in the template, rows 20 and 21's citations confirmed in both copies. **Re-verify
  before asserting**, since the spec has changed since.
- After Gate A closes: `superpowers:writing-plans`, then Gate A on the plan, then implementation.

## Open, and not to be lost

- **The conditions artifact** — `…-review-loop-economics-conditions.md` — is **not yet written**.
  It carries the row-by-row kept/moved/dropped dispositions for §6.2's twenty-one passages,
  produced **once against frozen final text** and gated by its own Gate-A review before any
  replacement text is written.
- **Prediction ledger and the four announce-then-idle occurrences** live in
  `docs/field-reports/2026-08-16-canvas-a1-a5-dispositions.md`. The §6.2-split prediction scored
  partly right; the "well below 20 Blocker/Major" prediction was **not met** at 22 and is recorded
  as not met.
- **The lesson worth keeping**, if any of this reaches the field record: a restructuring guard
  asking "did a decision move?" misses the case where **a rule survives in outline and loses its
  force** — pass 9 found eight of those. And a grep for the phrasing you expect is not a check.
