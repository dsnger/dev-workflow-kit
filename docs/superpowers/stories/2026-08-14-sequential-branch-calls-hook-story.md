# Sequential single-branch gate calls double-count the floor — Story

**Date:** 2026-08-14 · **Size:** story
**Risk:** high · **Security:** none · **Validation:** battery+check+verification

## 1. Problem statement

`CLAUDE.md` §5 prescribes one file per findings branch because `reviewType: full` runs the
spec and quality reviewers in parallel from one `additionalContext`. On PR #23's Gate-B
pass 1 both reviewers wrote **both** paths: the spec branch's seven findings were lost, and
**every acceptance condition still passed** — terminator present, count matching, nothing
but finding lines, both branch files present — because all four are *shape* checks and
provenance sits outside them.

The recorded fix candidate was to make **sequential single-branch calls** the documented
default (`reviewType: spec`, then `quality`), eliminating the concurrency rather than
detecting it. Evidence for it is real: sixteen consecutive single-branch calls across
passes 2–9 of that cycle, no recurrence.

**That fix cannot ship as a §5 prose edit, and the reason was found at Gate A.** The hook
increments its pass counter on **each** `mcp__codex__review` call. Two sequential calls are
two counted passes, so three logical passes become six counted ones, and the hook can
report the three-pass floor satisfied **before a pair's quality branch exists**. That is a
new mechanical false ✓ — and it lands in **tier-1 normal operation**, not in any degraded
mode.

So the current situation is a choice between two defects: keep `full` and keep a
demonstrated data-loss path, or adopt sequential calls and create a counting defect. The
prose default cannot resolve it because the counter is in the hook.

Found at Gate-A spec pass 3 of the reviewer-availability fallback cycle
(`.context/codex-reviews/gate-a-spec-pass-3.md`, blocker 4), which was stopped under §5's
stuck condition partly because of it.

## 2. Desired outcome

A Gate-B pass made of two sequential single-branch calls is **counted once**, so the floor
means what it says. Whichever way that is achieved, the observable result is:

- Sequential single-branch calls are safe to make the documented default, closing the
  `reviewType: full` two-writer data-loss path without opening a counting one.
- The hook credits a **completed branch pair**, not an individual call, or the two loops
  are separated in a way that is mechanically supported rather than described.
- A partially completed pair — spec branch done, quality branch not yet run or failed —
  never reads as a satisfied floor.
- The existing `full` behaviour keeps working for anyone who uses it, or is refused
  explicitly rather than silently miscounted.

## 3. Acceptance criteria

- [ ] A Gate-B cycle of three logical passes made as sequential single-branch calls causes
      the hook to report **three** passes, not six.
- [ ] A pass whose second branch has not completed does **not** count toward the floor, and
      the hook's message distinguishes that state from a satisfied one.
- [ ] `reviewType: full` continues to behave as it does today, or the hook/§5 refuses it
      with a named cause — no silent miscount either way.
- [ ] The regression suite covers the pair state machine: both branches succeed, first
      fails, second fails, branches interleaved with a commit, and a `full` call.
- [ ] The hook still exits 0 on every one of those paths, and remains POSIX `sh` with `jq`
      optional.
- [ ] `CLAUDE.md` §5 and `/workflow-init`'s inline mirror agree after the change.
- [ ] `docs/hardening-log.md`'s `unverified-enforcement-claim` row and the `todos.md` row
      that pointed at the parent story re-point here.

## 4. Affected AGENTS.md invariants

- `## Key invariants` → Hook, 1 — "**The hook always exits 0.** It is advisory; a reminder
  that can fail closed would make the workflow unusable whenever Codex is down or the
  environment is odd."
- `## Key invariants` → Hook, 2 — "**Loose in the firing direction.** On uncertainty, fire.
  A missed commit (false ✓) is the dangerous direction; a redundant warning is the accepted
  price." — the defect is squarely in the dangerous direction.
- `## Key invariants` → Hook, 3 — "**Gate-B validity is content-derived, never
  event-derived.**" — pair binding must not become an event-derived check.
- `## Key invariants` → Hook, 4 — "**POSIX `sh`, and `jq` is optional.** No bash-isms;
  correct behaviour via fallback parsing when `jq` is absent."
- `## Key invariants` → Packaging, 12 — "**A plugin change requires a version bump.**"
- `## Don'ts` — "**Never describe what a gate proves without checking what it actually
  compares.**"

## 5. Open questions

- Does the hook bind a pair by `sessionId`, by an explicit pair marker the caller writes, or
  by something content-derived? An event-derived binding would violate invariant 3's spirit
  even while fixing the count.
- Is `full` deprecated, refused, or left working? Deprecating it closes the original
  data-loss row; leaving it working keeps that row open.
- Does the fix change the *floor semantics* (three pairs) or the *counting* (three
  increments)? These are different changes with different failure modes.
- Gate A makes only `exec` calls and has no branches — is anything owed there, or is this
  strictly Gate B?

## 6. Suggested size

`story` — one coherent defect in one executable artifact, with a bounded state machine and
an existing regression suite to extend. It is genuinely hook work, which is why it could not
stay bundled with the prose change that surfaced it.
