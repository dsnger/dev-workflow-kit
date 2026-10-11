# Intake skill split — Plan

**Story:** `docs/superpowers/stories/2026-10-11-split-the-intake-skill-into-a-route-story.md` — read its profile fresh at each pass.

**Spec:** `docs/superpowers/specs/2026-10-11-intake-split-design.md` (Gate-A spec cycle `9bh80tgzjisk`, closed in `a832bfa`).

**Handover boundary:** the PR is open with CI green and whatever opportunistic bot findings have
posted processed (`docs/pr-review-bots.md`: the Wait-for list is empty, so an absent bot reply
blocks nothing); then write the handover and stop. Merge is relayed by the orchestrator (`dev-workflow-kit-d4`).

## Sources and impact boundary

Read for this plan: the story and spec above; `plugins/dev-workflow/skills/intake/SKILL.md` at
`fa5f275`; the pilot package on `b348b9c` (`proposal.md`, `compare.md`, `prompts.md`, `runner.md`,
fixture); Step 1's package `docs/superpowers/replays/2026-10-10-added-criterion-row/` (`README.md`,
`runner.md` `checks.sh`); `scripts/check-invariants.sh` checks 4a, 4d, 4f and the 4d/4f fixture in
`scripts/check-invariants.test.sh`; `.claude/review-gates.md` in full; `AGENTS.md`.
Changed: the three intake files, check 4f's path, the 4d/4f test fixture, `AGENTS.md` layout tree,
`docs/architecture.md` layout line, two path names in `todos.md`, plugin manifest version,
`CHANGELOG.md`, a new replay package. Not changed: any other skill, command, hook, the
`/workflow-init` templates, `.claude/review-gates.md`, `CLAUDE.md`.

## Probes already run (2026-10-11, scratchpad, outside any checkout)

- **Compaction in print mode works.** `claude -p "/compact" --resume <session>` on a resumed
  session emits `system/status compacting`, `compact_result: success` and a
  `system/compact_boundary` record (`trigger: manual`) in `stream-json`. That record is AC-6's
  evidence that a compaction happened.
- **An isolated `CLAUDE_CONFIG_DIR` has no login.** `claude -p` with a fresh config directory
  returns `is_error: true`, "Not logged in · Please run /login". So AC-5 takes Daniel's
  authorised fallback (spec §4): a temporary local marketplace in his real `~/.claude/plugins`,
  project-scoped install into the fixture.

## Task 1 — Build the three files from 0.23.0's text

**Outcome:** `SKILL.md`, `capture-new-story.md`, `amend-approved-artifact.md` under
`plugins/dev-workflow/skills/intake/`, cut from the 0.23.0 file by the pilot's mapping (spec §2).
**Reuse:** the pilot candidate files as the template for new text only (route table, load rule
in candidate2's wording, N3 line, route-file headers); every other line is taken from 0.23.0.
**Decided:** the route-file headers carry `Target model: Claude via Claude Code.` and the sentence
"This file is a prompt artifact and follows the checklist in `docs/prompt-standards.md`." (check
4a's phrase). **Implementer's choice:** line wrapping of the new text.
**Test situations:**
- frontmatter of the new `SKILL.md` is byte-equal to 0.23.0's (`name`, `description`);
- line coverage (a small script, kept in the package): every non-blank 0.23.0 line occurs in one
  of the three files; each line not found maps to a `reworded` row of the old→new table (spec §2);
  a deliberately deleted line in a scratch copy makes the script report it;
- the amendment file contains exactly one `## Amending an approved story or spec` heading and
  0.23.0's change-record block unchanged;
- AC-1 size: `SKILL.md` + each route file < 32,627 characters, both routes.

## Task 2 — Checks follow the text

**Outcome:** check 4f reads `amend-approved-artifact.md`; the 4d/4f shared fixture in
`check-invariants.test.sh` writes the amendment section to that file; 4a needs no change.
**Test situations:** `sh scripts/check-invariants.test.sh` green with an unchanged case count
(count before and after recorded); `sh scripts/check-invariants.sh` green on the tree; the same
check on a scratch copy with `amend-approved-artifact.md` removed fails 4f ("missing") — the
counterfactual for spec §5; on a scratch copy at `fa5f275` with the new `CR_FILE` it fails too.

## Task 2b — Prompt-standards review

Read the three assembled files against all 12 items of `docs/prompt-standards.md` (invariant 11),
item by item, and record the result (met, or the limit) in the replay package's `README.md`. The
mechanical checks cover one spelling each and are not that review.

## Task 3 — Records and version

**Outcome:** `AGENTS.md` layout tree and `docs/architecture.md` line list the two route files;
`todos.md` two path names (spec §3) point at `amend-approved-artifact.md`; manifest `0.24.0`;
`CHANGELOG.md` entry naming the split, the load rule and that behaviour is otherwise unchanged
(pending the replay). **Test situation:** the spec §3 search repeated on the implemented tree
lists no site that names a moved part's old file; the `declare[sd]?|convention[- ]load` grep
from AGENTS.md shows no new claim about the manifest.

## Task 4 — Snapshot under test

Battery green (the AGENTS.md quality row; `check-version-bump.sh main` once committed), then
`git commit -m 'WIP: intake split'`. The replay's `split` variant is that commit's tree; every
later change to an intake file re-snapshots and re-runs the runs of the route it touches.

## Task 5 — Replay package `docs/superpowers/replays/2026-10-11-intake-split/`

**Prerequisite:** Task 4's WIP commit. **Reuse:** the pilot's fixture (stored with
`agents-md.md`), prompts A1–G1 verbatim, `run.sh`/`suite.sh` shape; Step 1's `checks.sh`.
**New, decided here:**
- H prompts (written to `prompts.md`): **H1** `/dev-workflow:intake Amend the approved story
  docs/superpowers/stories/2026-10-01-export-job-story.md: drop the e-mail notification and add
  CSV as an export format. Nobody has decided this yet.` **H2** `Decision on the e-mail part:
  Daniel, 2026-10-09, in the review thread of PR #12: "Drop the e-mail notification from this
  release; keep the in-app notice." Nothing has been decided about CSV yet.` **H3** `Decision on
  CSV: Daniel, 2026-10-09, in the same thread: "And the export must also be available as CSV, not
  only XLSX."` Between H1 and H2 a `/compact` turn on the same session.
- Runner: variants `baseline` (`git archive fa5f275 plugins/dev-workflow`) and `split` (WIP
  commit); intake file hashes recorded per copy; the run-validity rule of spec §4 applied by a
  script before scoring (init plugin path and version, model, `result.is_error` false, no exit
  file); an unavailable run repeated once from turn 1.
- Checks script: Step 1's predicates plus the earlier-condition cell tested against AC-1..AC-4
  and §2 (spec §4); per-case outcomes for B, D, H; reading checks recorded per run in
  `compare.md` by the author.
- Installed run (AC-5), fallback procedure. **Owned resources only:** the run touches nothing it
  did not create, and never restores a whole file.
  - **Name:** `isr-<8 random [a-z0-9]>` (run-specific, never `dev-workflow-kit`, which would
    collide with Daniel's real registration). Before anything is registered, check that the name
    appears in neither `~/.claude/plugins/known_marketplaces.json` nor
    `installed_plugins.json` and that no `~/.claude/plugins/cache/<name>` or
    `~/.claude/plugins/marketplaces/<name>` exists; otherwise draw again.
  - **Before:** copy those two JSON files and `~/.claude/settings.json` to the scratchpad as a
    read-only reference and hash them; write a recovery note in the scratchpad naming the
    marketplace, its directory and the fixture path, so an interrupted run can be cleaned up by
    whoever resumes.
  - **Run:** a scratch marketplace directory with a `marketplace.json` named `<name>` pointing at
    a copy of the WIP plugin tree; `claude plugin marketplace add <dir>`; in a fresh fixture
    `claude plugin install dev-workflow@<name> --scope project`; B1 with `--setting-sources project`
    and without `--plugin-dir`.
  - **Cleanup, always** — after success, after invalid load evidence, after a failed add or
    install, and on resuming an interrupted run from the recovery note, before any stop is
    reported: `claude plugin uninstall dev-workflow@<name> --scope project` (if installed),
    `claude plugin marketplace remove <name>` (if registered), then delete the cache and
    marketplace directories named `<name>` if they remain.
  - **Verify:** `known_marketplaces.json` has no key `<name>`; `installed_plugins.json` has no
    key `dev-workflow@<name>` under `plugins` (its keys are `<plugin>@<marketplace>`); no cache or
    marketplace directory named `<name>` remains; the `dev-workflow@dev-workflow-kit` entry of
    `installed_plugins.json` and every other marketplace entry of `known_marketplaces.json` equal
    to the reference; `~/.claude/settings.json` hash equal. A difference in anything the run did
    not own is **not** reverted: it may be a concurrent legitimate change, so it is reported to the
    orchestrator with the observed delta and the run stops.
  - **What remains if cleanup itself fails:** stop, report the exact remaining resources and the
    recovery note's path; nothing else is touched.
- `README.md` (method, hashes, limits), `compare.md` (per case and replicate, verdicts for
  AC-3..AC-6), the old→new account and line-coverage output (AC-2), the size table (AC-1),
  effort (cost, turns) from the `result` records.
**Cost:** 25 case runs = 37 ordinary `claude -p` invocations plus 2 `/compact` invocations, each
capped at `--max-budget-usd 4` by the runner (no replay-wide cap); a repeated run adds its
invocations. Estimate from the pilot's per-run cost: $8–10; that is an estimate, not a bound.
**Decision space:** parallelism and script structure. **Stops:** a validity failure that persists;
an installed run whose init record does not show the project-scoped plugin at the cache path
(report, do not improvise another install route); a pass/fail verdict the case table does not decide (report to the orchestrator, do not decide).

## Task 6 — Verdict

All of AC-3..AC-6 pass → continue. Non-adoption (AC-7, spec §4) follows when any of them fails
**or** the installed or compaction run cannot be produced (its evidence stays classified
"unavailable", not "failed"). A persistent validity stop in A–G is reported to the orchestrator
first, who decides between a further repeat and non-adoption. Non-adoption: revert the skill,
check, test, layout, version and CHANGELOG changes **and the two `todos.md` path names**; keep
the replay package; add a `todos.md` record of the result; check that the remaining diff against
`main` is only `docs/` and `todos.md` content (story, spec, plan, package, record); report to the
orchestrator. Whether that remaining diff owes Gate B is the gate rules' (`.claude/review-gates.md`,
"What counts as prose"), decided on the staged paths, not here.

## Task 7 — Gate B

**Before the first call:** stage the complete intended result — the replay package and any
non-adoption revert — and fold it into the WIP snapshot with
`git commit --amend -m 'WIP: intake split'`; check that `git diff --name-only <base>..HEAD`
contains the package; on non-adoption also check that `git diff --quiet fa5f275 HEAD --
plugins scripts AGENTS.md docs/architecture.md` succeeds (the implementation paths equal the
baseline, so the range no longer lists them) and that the `todos.md` result record is present;
run the battery on that state; when
only evidence files changed since Task 4, confirm the intake files' hashes still equal the
replayed ones. Then resolve `baseSha` and `headSha`.

Evidence entry (story path). **Adoption:** named evidence = the replay package, the 4f
counterfactual, the size table. **Non-adoption:** named verification = the implementation paths
equal `fa5f275` (the `git diff --quiet` above) and the replay result recorded in the package and
`todos.md`; counterfactual = the same `git diff --quiet` against the pre-rollback WIP commit,
which fails; the split's size and 4f measurements stay in the package as history and are not
offered as evidence for the final change. Two sequential single-branch calls per pass (`spec`, then `quality`), full
40-character SHAs, floor 3, cap 5, records per `.claude/review-gates.md` Mechanics. A fix that
touches an intake file re-runs that route's replay cases (Task 4 rule) before the cycle closes.

## Task 8 — PR and handover

Push, open the PR, wait for CI, process whatever the opportunistic bots have posted with
`dev-workflow:process-pr-review` (`docs/pr-review-bots.md`; nothing is waited for), write `.context/handover-intake-split.md` (and the top entry in
`.context/handover-mcp-security.md`), report, stop.
