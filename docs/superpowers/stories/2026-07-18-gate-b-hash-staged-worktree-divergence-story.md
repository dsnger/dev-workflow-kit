# Gate-B hash misses staged-vs-worktree divergence — Story

**Date:** 2026-07-18 · **Size:** story

## 1. Problem statement

Gate B can report "satisfied" for content nobody reviewed. Both components of the
working-tree hash describe the **worktree**, but `git commit` commits the **index**.
When the two diverge, the gate reads one and the commit carries the other.

Repro: `git add app.ts` with new content, then revert `app.ts` on disk back to HEAD.
The commit carries the staged content; the hash sees a worktree identical to the
reviewed one and reports satisfied. Found by Codex at Gate B on PR #1 and deliberately
deferred there, because the fix contains a decision rather than just a correction.

## 2. Desired outcome

A commit whose staged content differs from what was reviewed is never reported as
Gate-B satisfied, regardless of how the divergence arose. Alongside that, the project
has an explicit, recorded answer to the question the fix forces: whether merely staging
already-reviewed content should invalidate a review. Today that behaviour is asserted
by a passing test but was never actually decided — it fell out of an implementation
choice.

## 3. Acceptance criteria

- [ ] Staging new content and then reverting the worktree file to HEAD results in "not
      satisfied" at commit time.
- [ ] A regression test covers that scenario and is mutation-verified: reverting the
      fix makes it fail.
- [ ] The bare-`git add` question is answered in writing with its reason, and the
      existing test asserting that staging does not change the hash is either kept or
      replaced *by* that decision — not left to contradict it silently.
- [ ] No tree state produces a hash that can never match itself (which would STOP every
      commit forever); false-STOP and false-✓ directions are both exercised by tests.
- [ ] The quality battery stays green, including `shellcheck --shell=sh` and the hook
      suite under `sh`.

## 4. Affected AGENTS.md invariants

- `## Key invariants → Hook` — "**Gate-B validity is content-derived, never
  event-derived.** Invalidation compares a hash of the working tree — `git diff HEAD`
  plus a tree id written from a throwaway index…" *(The invariant's own wording says
  "working tree" — this story may require amending that line, since the defect is
  precisely that the working tree is the wrong referent.)*
- `## Key invariants → Hook` — "**Loose in the firing direction.** On uncertainty,
  fire. A missed commit (false ✓) is the dangerous direction; a redundant warning is
  the accepted price."
- `## Key invariants → Hook` — "**The hook always exits 0.**"
- `## Key invariants → Hook` — "**POSIX `sh`, and `jq` is optional.**"

## 5. Open questions

- Should staging already-reviewed content (a bare `git add` that changes nothing about
  the bytes) invalidate the review? Invariant 2 argues yes; day-to-day usability argues
  no, since `review → stage → commit` is normal and a STOP there is noise on every
  commit.
- Should the answer depend on the commit's shape — `git commit` (index only) vs
  `git commit -a` vs `git add X && git commit` — or should one rule cover all three?
- Does invariant 3's wording need amending, given "working tree" is the referent that
  turned out to be wrong?

## 6. Suggested size

`story` — one coherent change to one function plus its tests, but it carries a real
design decision, so it needs a spec through Gate A rather than a drive-by fix.
