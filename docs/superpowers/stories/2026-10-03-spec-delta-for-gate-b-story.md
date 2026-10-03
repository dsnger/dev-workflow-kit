# Spec-delta for the Gate-B reviewer (vision step 2c, part 3) — Story

**Date:** 2026-10-03 · **Size:** story
**Risk:** standard · **Security:** none · **Validation:** battery+check

## 1. Problem statement
Part 3 of the epic `docs/superpowers/stories/2026-10-02-telemetry-and-review-loop-usefulness-story.md`.
Gate A closes a spec on one exact text: its closing commit carries that text (CLAUDE.md §5, Gate
A's content condition). Afterwards the spec can still change — during planning, during execution,
or through a Gate-B fix that changes specified behaviour. Nothing shows the Gate-B reviewer what
changed in the spec since its review. CLAUDE.md §5 records what this costs: a Gate-B fix reordered
a precedence rule, the spec kept describing the old behaviour, and a PR bot found the disagreement
only after merge-readiness, because the Gate-B call was given only the diff.

## 2. Desired outcome
For every spec that a change's plans cite, the Gate-B reviewer sees the spec revision that its
Gate-A cycle closed on, and every change to it since then — or an explicit statement that there
was none, or that it cannot be determined. The delta informs the review. It does not change what a
pass is, what a cycle owes, or any record format.

## 3. Acceptance criteria
- [ ] For a spec with a closed Gate-A cycle, the revision it closed on is determined from the
      existing records (the commit carrying that cycle's provenance line), without a new record
      format.
- [ ] Every change to that spec between the closed revision and the Gate-B candidate is shown as
      a delta. "No change", "renamed or deleted" and "closed revision not determinable" (no
      closing commit, conflicting records) are shown explicitly and are never silently skipped.
- [ ] Each Gate-B call can carry that delta, or its explicit absence, for every spec the reviewed
      plans cite, beside the diff.
- [ ] A check demonstrates, on a fixture, that a spec edited after its Gate-A close produces a
      delta the Gate-B input contains, and that an unedited spec produces "no change".
- [ ] Producing the delta changes no pass-validity rule, floor, closure condition or commit-body
      record format, and states what it cannot establish (for example: whether the change was
      reviewed, or whether the spec still matches the code).

## 4. Affected AGENTS.md invariants
- `## Don'ts` — "**Never describe what a gate proves without checking what it actually compares.**"
- `### Packaging` — "5. **Every version pinned exactly.**"
- `### Packaging` — "12. **A plugin change requires a version bump.**" (binds only if anything
  ships in the plugin)

## 5. Open questions
- Is the delta delivered by a repo-local tool that the Gate-B prompt cites, or by a change to the
  shipped Gate-B instructions (prompt = product, a different review weight)?
- Do plans get the same treatment as specs? Both close on an exact text under Gate A.
- Does a non-empty delta oblige anything (for example a Gate-A re-review), or only inform? This
  story assumes "inform only"; an obligation would change gate rules and needs its own decision.

## 6. Suggested size
story — one mechanism over existing records plus its use in the Gate-B call; one spec → plan → PR.
G1a (todos.md, controlled change procedure) later produces the human decisions this delta records.
