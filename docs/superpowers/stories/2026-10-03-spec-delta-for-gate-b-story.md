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
**Narrowed 2026-10-03 (Daniel), after Gate-A spec pass 1.** The existing records do not name the
file a Gate-A cycle reviewed, so this part delivers an **explicit baseline comparison**, not a
discovered "reviewed revision". For every relevant spec and plan, the Gate-B reviewer sees the
change from a **given** baseline (a file at a named commit) to the candidate. The report checks the
baseline's Gate-A metadata and shows any ambiguity, and it claims no confirmed review attribution:
"compared with the given baseline; Gate-A metadata checked". A relevant spec without a baseline,
or whose original is gone after a squash, stays visibly unknown. The report informs and obliges
nothing: it changes no pass rule, closure condition or record format.

## 3. Acceptance criteria
- [ ] For each given baseline (`path@commit`), the report checks that the commit resolves, that
      the path exists there, and which Gate-A records of the matching kind the commit carries. It
      shows ambiguity (several cycles, several reviewed-kind files changed, or records suggesting a
      squash) and never states that the cycle reviewed exactly this file.
- [ ] The change from each baseline to the candidate is shown as a delta, with "no change" and
      "renamed or deleted" explicit.
- [ ] Every relevant spec appears in the report, including the specs cited by an unchanged
      contributing plan. A relevant spec without a given baseline is shown as "baseline missing —
      unknown", and never silently dropped or replaced by a later (for example squashed) text.
- [ ] The report's output is carried in a real Gate-B call's input (this story's own Gate B), and
      a fixture check shows that an edited and an unedited artifact produce "changed" and "no
      change".
- [ ] Producing the report changes no pass-validity rule, floor, closure condition or commit-body
      record format, and the report states what it cannot establish.

**Scope narrowed 2026-10-03 (Daniel, on the reviewer's assessment
`.context/sparring/20261003-160225-spec-delta-explicit-baseline-assessment.md`), after Gate-A spec
pass 1 showed that records do not attribute a cycle to a file.** What changed:

| Earlier criterion or promise | Fate |
|---|---|
| Outcome: the reviewer sees the revision the Gate-A cycle closed on | **Narrowed** to a comparison with an explicitly given baseline; review attribution is not claimed. |
| Criterion 1: closed revision determined from existing records | **Replaced**: the baseline is given; its Gate-A metadata is checked and ambiguity shown. |
| Criterion 2: delta, explicit no-change / renamed / not determinable | **Kept**, with "not determinable" now "baseline missing — unknown". |
| Criterion 3: each Gate-B call can carry it | **Kept and strengthened**: a real Gate-B call carries it (criterion 4). |
| Criterion 4: fixture check | **Kept**, plus the real Gate-B input. |
| Criterion 5: no rule or record change, stated limits | **Kept**. |
| Discovering closed revisions automatically | **Deferred**: it needs a record that names the reviewed file — a record-format and gate-rule change, outside this story. |

## 4. Affected AGENTS.md invariants
- `## Don'ts` — "**Never describe what a gate proves without checking what it actually compares.**"
- `### Packaging` — "5. **Every version pinned exactly.**"
- `### Packaging` — "12. **A plugin change requires a version bump.**" (binds only if anything
  ships in the plugin)

## 5. Open questions
- Is the delta delivered by a repo-local tool that the Gate-B prompt cites, or by a change to the
  shipped Gate-B instructions (prompt = product, a different review weight)?
- Do plans get the same treatment as specs? Both close on an exact text under Gate A.
- Does a non-empty delta oblige anything (for example a Gate-A re-review)? Decided 2026-10-03:
  inform only; an obligation would change gate rules and needs its own decision.

## 6. Suggested size
story — one mechanism over existing records plus its use in the Gate-B call; one spec → plan → PR.
G1a (todos.md, controlled change procedure) later produces the human decisions this delta records.
