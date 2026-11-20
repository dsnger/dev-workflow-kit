# Kit 0.55: the review loop asks Greptile once per PR — Plan

**Spec:** `docs/superpowers/specs/2026-11-20-kit-055-greptile-requested-design.md` (Gate A closed, cycle
g55reqspec1, passes 1–3). **Story:** `docs/superpowers/stories/2026-11-20-kit-055-greptile-requested-story.md`.
**Gate A (plan):** skipped — risk standard (`strict`: a plan only at risk `high`).
**Handover boundary:** the completed story (one unit).

## Steps
1. `plugins/dev-workflow/commands/process-pr-review.md`: Step 0 names the new qualifier; Step 2 gets the paragraph
   **Request a review once per PR** (spec §4, items 1–6, concurrency scope); the "only review this command starts"
   sentence gains the one request; Step 3 item 1 and Step 4's last read cover the requested bot. → verify: every
   spec §4 item maps to a sentence (checklist in the PR body); `docs/prompt-standards.md` 12 items.
2. `plugins/dev-workflow/commands/workflow-init.md` 2.5: the installed question, the fourth answer (recommended when
   installed), the template's qualifier, row wording, **Request when** default paragraph (spec §3), and the
   opportunistic-category note on the bounded wait. 2.23 → `0.55.0`. → verify: check 4n (version sites equal).
3. `docs/pr-review-bots.md` (this repo): Greptile on in the new mode (spec §6). → verify: read back the routing lists.
4. Docs: README row, `docs/setup.md` § 9, `docs/reference.md` § PR review bots, `docs/getting-started.md` PR bot
   step; CHANGELOG 0.55.0; manifest and `.claude/dev-workflow-version` 0.55.0. → verify: `grep -rn "asks no bot"`
   over live surfaces shows none left unqualified; check-doc-links green.
5. Quality command, Gate B (two calls per pass, strict floor 1 cap 5), the risk pass (due: the diff touches
   `plugins/` and `.claude/`, and the story's security is `standard`; `.agents/skills/gate-b-review/SKILL.md` §
   Risk pass), PR, `process-pr-review` from this branch's text, squash-merge, handover.

## Test situations
- PR #<this one>: touches prompt paths, not small → the loop requests Greptile once, waits ≤15 min, processes or
  records the timeout (a real run of the feature; evidence in the PR body line).
- A second `process-pr-review` run on the same PR → finds the request comment, requests nothing.
- Docs-only PR, `chore/kit-*` branch, draft: no request with the named reason (read-through of the prose; no harness
  exists for prompts).

## Long runs
- Quality battery, local: about 35 min (AGENTS.md § Commands), 1–2 runs; `scripts/local-ci.sh` posts it, time
  limit and cleanup are the script's own. Within the 2-hour unit limit.

## Actions outside the repository
- A GitHub comment `@greptileai` on this PR (a paid Greptile run) — authorized by Daniel's order.
- Whether Greptile's `autoReview` is `[]` on this repository is Daniel's setting; no auto review was seen on
  #105, #107–#110, so none is asked.

## Sources and impact boundary
Context7: `/websites/greptile` (hosted, current docs) and `/websites/github_en_rest` (API 2022-11-28), 2026-11-20,
as in spec §8. Touches: the two commands, this repo's bot file, five docs, CHANGELOG, two version records. Not
touched: the hook, the gate rules, scripts, other projects.
