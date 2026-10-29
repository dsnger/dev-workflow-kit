# Kit 0.50 proportional gates — Plan

**Spec:** `docs/superpowers/specs/2026-10-29-kit-050-proportional-gates-design.md` (Gate A closed, `11450c7`).
**Story:** `docs/superpowers/stories/2026-10-29-kit-050-proportional-gates-story.md` (risk high → this plan takes
Gate A). Execution: this session, task by task; no subagent writes.

## Tasks

**T1 — release-only classifier in `scripts/local-ci.sh` (spec §2, §4; AC-1, AC-2, AC-4, AC-5).**
- Outcome: `[--from <green>] [<commit>]` usage; Source / inherit-same-tree / inherit-records / light / full in
  that order; the lane contract in the header (normative, ships as 2.22); `quality` context in every lane.
- Reuse: the existing precondition, `refuse`, quality-row awk (the light row is the same parse with
  `| quality-light `), cleanup trap, post block (description varies by lane).
- New: one awk program over the spec §2 diff flags (rules D/C/V, structural entries, one-version rule); R files
  via `jq` per file outside awk; the Version sites line from the base commit's `AGENTS.md`.
- Tests (`scripts/local-ci.test.sh`, existing stubs for `gh`, `shellcheck`, `claude`, battery): every case in
  spec §6 for local-ci, each asserting the printed lane line and the posted description, and that the battery
  stub did or did not run. `gh` stub answers the combined-status read with a fixture JSON (success / failure /
  no quality / `total_count` 101 / read failure). A test that cannot fail is avoided by asserting the run marker.
- Decision space: helper names, awk layout, fixture builders.

**T2 — hook release-only branch (spec §3; AC-1, AC-2, AC-3).**
- Outcome: after the unchanged docs-only branch, the release note with status line
  `ℹ Codex Gate B N/A (release-only commit)`; refused on `--amend`, `-a`/`--all`, no `HEAD`; exit 0 always.
- Reuse: `names_no_paths`, `is_prompt_path`, the awk program from T1 (copy, D1) with the hook's docs list as D.
- Tests (`codex-gate.test.sh`, both `sh` and `dash`): **every classifier case of spec §6 that applies to a
  commit**, with the hook's expectation (D1 parity): release-only; version + dependency; docs only (docs-only
  note unchanged); docs + one code file (fires); nested version beside the release; nested-only column-zero
  manifest version; site line with a same-number tool pin; TOML site line; changelog under `commands/`,
  `agents/`, `.claude/`, `plugins/`; listed site under an instruction path; gitlink change; `diff.noprefix`, a
  textconv driver and `diff.ignoreSubmodules=all` configured → same results; no jq on PATH → fires. Hook-only:
  `--amend`, `-a`, no `HEAD`. Lane-only cases (base-only update, `--from`, binary image, light row) stay in T1.

**T3 — rules and green consumers (spec §5; AC-1, AC-7).**
- `.claude/review-gates.md` and `### 2.1a` byte-identical (4j), ≤10,000 bytes (4i): "docs-only and release-only
  commits may skip it" + one release-only sentence; trim words elsewhere, no rule dropped (list the trims in the
  closing body).
- The lane sentence in CLAUDE.md §4 "One source of green" and "Waiting on external work", the identical 2.1
  template text, `process-pr-review.md` Step 3 item 6 and its report shape; `docs/reference.md` (one line under
  The review gates, Release-only paragraph, Lanes paragraph, merge commit → `--from <final head>`).
- Check: 4g (CLAUDE.md + AGENTS.md ≤150,000 chars), 4e (template ≤20,000) still pass.

**T4 — scaffolding, version, docs (AC-10).**
- `### 2.22` = new `local-ci.sh` bytes (4m), and its introduction and report text: what each lane proves,
  pointing to the script header; the fresh-worktree dependency note applies to the light row too. `/workflow-init` Step 3 item 6: optional `quality-light` row (a
  command run in the session, like every row) and optional `**Version sites:**` line. This repo's `AGENTS.md`:
  the `quality-light` row (spec §4), Commands prose for it, Boundaries 4b updated (reads a commit status).
- Version 0.50.0: plugin.json, `### 2.23`, `.claude/dev-workflow-version` (4n); CHANGELOG 0.50.0; README line;
  `docs/ARCHITECTURE.md` only if a listed claim changes; `todos.md` 0.50 field-case row ticked.

**T5 — measure, battery, Gate B, PR (AC-9).**
- Order: WIP commit; quality command locally (heavy, ask the orchestrator for a go); Gate B strict; closing
  commit; push; `sh scripts/local-ci.sh <final head>` (heavy, ask) and read its status → `H` resolved to a
  full SHA. **Then** the measurement on a local scratch branch from `H` (never pushed; `git branch`, no worktree), `gh`
  stubbed for both the status read and the post (labelled): **docs** = `H` + one docs line, run
  `local-ci.sh --from H`; **release** needs release files `H` lacks, so a setup commit `S` = `H` + root
  `VERSION` `0.1.0`, `package.json` `{"name": "fixture", "version": "0.1.0"}`, `CHANGELOG.md`, then
  `R` = `S` with both bumped to `0.1.1` and one CHANGELOG line, run `local-ci.sh --from S R` (the stub reports
  `S` green; labelled: `S` is a measurement scaffold, not a battery-verified head). Before each timed run, assert
  the lane from a dry classification (the printed lane line of a run with the battery stub). Record `H`, `S`,
  the fixture tree ids, durations, lane lines, and the hook notes when committing `docs` and `R`. Then the PR with the numbers;
  `/dev-workflow:process-pr-review`; squash-merge.
- Merge carry: `git fetch origin`; resolve the merge SHA from `gh pr view <n> --json mergeCommit`; check it is
  `origin/main`'s SHA; `sh scripts/local-ci.sh --from <H> <merge sha>` (same tree → seconds).

## Long runs
| Run | Proves | Estimate | Expected runs |
|---|---|---|---|
| quality command (local, before Gate B) | battery green on the WIP head | ~40 min | 1–2 |
| `sh scripts/local-ci.sh <final head>` | the posted `quality` status | ~40 min | 1 |
**The local quality run** goes through a scratch runner (scratchpad, not shipped): it splits the quality row
on ` && ` into its stages, runs each in its own process group with a 15-minute limit (`perl -e 'alarm…; exec'`,
since macOS has no `timeout`), kills that group on timeout or exit (trap), and runs every stage even after a red
one, then prints each stage's status and duration and exits red if any was. **The final-head `local-ci.sh` run**
is the product runner as approved (chained, signal handled after the running command returns): one Bash call
with a 60-minute limit; afterwards `git worktree list` confirms its worktree is gone and `pgrep -f local-ci`
that nothing is left. Total ≤ 2 h of long runs in this unit.

**Exception (dev-workflow-kit-26, 2026-10-29 21:54):** the final-head evidence is the product runner
`sh scripts/local-ci.sh <H>` as approved in 0.47–0.49 — no per-stage limit, first red stops it — because a
wrapper would change what posts the `quality` status; the bounded scratch run on the WIP head before it covers
per-stage limits and all-failures collection. Heavy runs: two in total (scratch run on WIP, product run on the
final head) plus at most one rerun after Gate B fixes; the orchestrator's go before each.

**Measurement scaffold (dev-workflow-kit-26, 21:54):** the release fixture's source `S` is a setup commit with
a stubbed green status, labelled as such in the PR; it changes how we measure, not the product.

## Handover boundary
The merged PR (one unit). `.context/handover-kit-050-proportional.md`.

## Sources and impact boundary
Read: spec §9's list; `workflow-init.md` Step 3; README/CHANGELOG heads. Library: GitHub REST combined status,
API 2026-03-10, Context7 `/websites/github_en_rest` (2026-10-29); `jq` 1.7.1 (system tool, by name, like `git`): Context7
`/websites/jqlang` (2026-10-29) indexes the 1.8 manual, not 1.7: fallback per CLAUDE.md §4, the official jq 1.7
manual (`https://jqlang.org/manual/v1.7/`, read at T1) for `del(path)`, `-e`, `-n` and `--slurpfile`, and the
installed `jq --help` of 1.7.1.
Out: ci.yml, sfx-factory, process-pr-review's patch-id rule (kept).

## Actions outside the repository
None needing the human: the posts go to this repository's commit statuses as in 0.49; heavy runs need the
orchestrator's go (asked at T5).
