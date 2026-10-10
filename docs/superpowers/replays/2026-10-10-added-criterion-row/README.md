# Replay — change-record field for an added criterion

Named verification for story
`docs/superpowers/stories/2026-10-10-change-record-row-for-an-added-story.md` (AC-5 to AC-8), per
spec `docs/superpowers/specs/2026-10-10-added-criterion-row-design.md` §3 and plan
`docs/superpowers/plans/2026-10-10-added-criterion-row.md` Task 2.

**Result:** set 1 (8 runs) failed one reading check in one run; Daniel ruled it a failure and chose a
one-sentence correction; set 2 (8 fresh runs on the corrected skill) passed every check in every
run. Details per run and per check: `compare.md`.

## What was measured

| | Set 1 | Set 2 |
|---|---|---|
| Skill revision | `cb134cc` | `53a88a4` |
| `plugins/dev-workflow/skills/intake/SKILL.md` sha256 | `c6ca7ba2c0152e87ea210992d871036eb365d1d262ead4427affd8e68a6de396` | `e629b1ba727f0ea22d9e422e4d5a272251c34a428c1f6524ecbda8a83a9e7089` |
| Runs | 5 × D1, 3 × B1 | 5 × D1, 3 × B1 |
| Result | 7 of 8 pass (D run 4 fails) | 8 of 8 pass |

- **Fixture:** `fixture/` — the strand-C pilot's fixture at b348b9c
  (`docs/superpowers/replays/2026-10-10-intake-skill-pilot/fixture/`), unchanged in content. Its
  `AGENTS.md` is stored here as `fixture/agents-md.md`, because a file named `AGENTS.md` is a prompt
  under `.claude/review-gates.md` "What counts as prose" and would take this package out of the
  docs-only exemption.
- **Prompts:** `prompts.md` (D1, B1, verbatim from the pilot).
- **Runner:** `runner.md` (`run.sh` as run, `checks.sh`, the invocation).
- **Model:** `claude-opus-5-5`; Claude Code 2.1.296; flags `--plugin-dir`,
  `--setting-sources project`, `--strict-mcp-config`, `--permission-mode bypassPermissions`,
  `--max-budget-usd 4`; one fresh fixture copy per run.
- **Plugin load:** each run's init record lists exactly one `dev-workflow` plugin, at the measured
  copy, version 0.23.0; the copy's sha256 was checked against the commit before each set. The
  stream does not carry the expanded skill text, so this is the load evidence.
- **Before-measurement:** the pilot's baseline runs on the 0.22.0 skill (unchanged since
  `860e56c`), cited, not re-run: case D produced an out-of-set row in 1 of 3 runs
  (`compare.md` row D of the pilot package).

## Re-running

In a directory outside any git checkout: build `fixture-template/` from `fixture/` with
`agents-md.md` renamed to `AGENTS.md` and `review-gates.md` moved to `.claude/`; `git init -b main`;
commit everything once (its id replaces `e2f55ca` in `checks.sh`). Put
`git archive <commit> plugins/dev-workflow` at `plugins/fix`, save the prompts as `prompts/D1.txt`
and `prompts/B1.txt`, then run the invocation in `runner.md` and `sh checks.sh runs`.

## Limit

Sixteen samples on two prompts and one fixture. They show the changed template can be followed in
these cases; they do not show a general absence of loss. Reading checks were made by the author of
the change.
