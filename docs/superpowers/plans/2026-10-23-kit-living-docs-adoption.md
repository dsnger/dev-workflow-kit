# Kit living-docs adoption — Implementation Plan

**Story:** `docs/superpowers/stories/2026-10-23-kit-living-docs-adoption-story.md` (risk standard → no plan Gate A)
**Spec:** `docs/superpowers/specs/2026-10-23-kit-living-docs-adoption-design.md` (Gate A cycle lda7k42q, closed ac6429a)
**Branch:** `kit/0.42-living-docs`, worktree `.claude/worktrees/kit-042`. Executed inline in this session.

## Long runs, handover boundary, actions outside the repository

No run of 45 minutes or more (battery about 5 min; prompt eval once, about 10 min, about $2). Handover
boundary: the merged PR. Outside the repository: none (the prompt eval's cost is pre-approved by the
orchestrator prompt).

## Sources and impact boundary

Read: the pilot report § Recommendation and AC-4 table; the pilot story; the SFX setup spec §2a–§4.5 (format
of the exercised elements, read only for shape, no vocabulary taken); `workflow-init.md` Rules, Step 2.1
(template, 4e), 2.1a, Step 3, Step 4, Report format; `scripts/check-doc-links.{sh,test.sh}`;
`scripts/check-invariants.sh` 4e/4i/4j (pattern for 4l) and its suite; CI `.github/workflows/ci.yml` link
steps; `AGENTS.md` § Commands; README, `docs/reference.md` `## workflow-init`. Impact ends at: the
`/workflow-init` command, the link checker and its callers (battery, CI, § Commands), check 4l, the docs that
describe `/workflow-init`'s files. No hook change, no skill change, no gate-rules change (spec D5, D6).
Library APIs: none (POSIX sh, awk, sed, git only).

## Tasks

1. **Link checker: fragments + skip arguments.** Outcome per spec §3.2. Tests first in
   `check-doc-links.test.sh` (cases listed in the spec), then the script; then update callers (battery
   rows in `AGENTS.md`, CI step) to pass `source-files/ docs/history/ docs/superpowers/replays/`; fix the
   broken fragments it reports in this repo. → verify: suite green, `sh scripts/check-doc-links.sh <skips>`
   prints `doc links: ok`, shellcheck clean.
2. **`/workflow-init` 2.20 rules file and 2.21 checker template; check 4l.** Write 2.20 per spec §3.1 (about
   5 kB, stack-neutral); 2.21 = the script fenced (```` ```` ````sh ````). Check 4l byte-compares the 2.21
   fence body with the script; suite gets pass + fail case. → verify: invariant suite and checks green.
3. **`CLAUDE.md` template, Step 2 switch, Step 3 map item, Step 4 checklist, report.** Per spec §3.3. →
   verify: check 4e passes; `grep` finds no "Project architecture, stack-specific patterns, and invariants
   live in @AGENTS.md".
4. **Pilot report row** (spec §3.4).
5. **Docs and records** (spec §3.5), version 0.42.0, CHANGELOG. → verify: doc-link check, version check.
6. **Battery, prompt eval, ponytail pre-review, Gate B, PR, process-pr-review, merge.**

## Implementer's decision space

Rules wording; slug implementation; fixture shapes; which docs paragraphs get the new text.
