# Replay — the `ticket` skill

Named verification for story
`docs/superpowers/stories/2026-10-11-a-ticket-skill-for-bugs-and-improvements-story.md` (AC-7,
AC-11), per spec `docs/superpowers/specs/2026-10-11-ticket-skill-design.md` §3 and plan
`docs/superpowers/plans/2026-10-12-ticket-skill.md` Tasks 1 and 3.

**Result:** set 2 passed every check in every run (10 of 10), against a baseline in which no run
produced a ticket (three runs; 0.23.0 ships no ticket skill). Set 1 failed (K1 on an oracle defect in R1, K2 on the skill) and stays here as
the failure record; both causes and their answers are in `compare.md`. The fixture, `prompts.md`,
`runner.md` and `checks.md` were committed before the first run in `7ce0a03`; R1 was amended in
`9025003` (spec §3 change record), before set 2's first run.

| | Set 1 | Set 2 |
|---|---|---|
| `skills/ticket/SKILL.md` sha256 | `1bdaa56b85ea483743db9b97c72418000bd05a8242a78781d90b0c8ac9eae154` | `52b78e5bbfe1b0f3dd82e2214248d9f59d67788bef480a8803481c3bfe543d64` |
| Skill text | `evidence/set1-skill.md` | `evidence/set2-skill.md` |
| Measured snapshot | `WIP:` `6d6ac70` (replaced) | `WIP:` `35d4a72` (replaced at close) |
| Runs | 3 × K1, K2, K3; 1 × L | 3 × K1, K2, K3; 1 × L |
| Result | 4 of 10 pass all checks (K3, L) | 10 of 10 |
| Per run | `evidence/set1-runs.md` | `evidence/set2-runs.md` |

Baseline: `evidence/baseline-runs.md` (3 runs, all valid, no ticket file).

## What is measured

- **Cases:** K1 (bug with evidence), K2 (improvement inside a commitment), K3 (a "bug" that changes
  a commitment), L (`list`). Prompts: `prompts.md`.
- **Runs:** candidate 3 × K1, 3 × K2, 3 × K3, 1 × L on the skill at the Gate-B `WIP:` snapshot;
  baseline 1 × K1–K3 given to `/dev-workflow:intake` on 0.23.0 (`6b15993`), where no ticket skill
  exists — the counterfactual.
- **Checks and validity rule:** `checks.md`; the mechanical rows and the validity test are scripted
  in `runner.md` (`checks.sh`).
- **Model and flags:** `claude-opus-5-5`; Claude Code 2.1.296; `--plugin-dir`,
  `--setting-sources project`, `--strict-mcp-config`, `--permission-mode bypassPermissions`,
  `--max-budget-usd 4`; one fresh fixture copy per run, one turn.
- **Durable source of a measured plugin:** the `WIP:` commit is replaced when Gate B closes, so each
  candidate set keeps its skill text verbatim as `evidence/set<k>-skill.md` with its sha256. The
  measured plugin is `plugins/dev-workflow` at `6b15993` plus that file, the 0.24.0 manifest and
  the 0.24.0 CHANGELOG entry (the CHANGELOG is not loaded by a run).

## Fixture

`fixture/` holds the export-job fixture of `../2026-10-11-intake-split/fixture/` (unchanged:
`agents-md.md`, `review-gates.md`, the export story with AC-1…AC-4) plus five tickets in
`fixture/docs/superpowers/tickets/`:

| Ticket | State | Date |
|---|---|---|
| T-1 | wontfix | 2026-10-02 |
| T-2 | needs-info | 2026-10-03 |
| T-3 | ready | 2026-10-04 |
| T-4 | needs-info | 2026-10-03 (same date as T-2) |
| T-5 | ready | 2026-10-01 (older than T-3, higher number) |

A new capture is therefore T-6. No `todos.md`, no `docs/PRD.md`. `AGENTS.md` is stored as
`agents-md.md` because a file named `AGENTS.md` is a prompt under `.claude/review-gates.md` "What
counts as prose" and would take this package out of the docs-only exemption.

## Re-running

In a directory outside any git checkout:

1. Build `fixture-template/`: copy `fixture/docs`, `fixture/agents-md.md` as `AGENTS.md`,
   `fixture/review-gates.md` as `.claude/review-gates.md`; `git init -b main`; `git add -A`;
   commit once with `GIT_AUTHOR_DATE` and `GIT_COMMITTER_DATE` both `2026-10-05T12:00:00`,
   author and committer `fixture <fixture@example.invalid>`, message
   `fixture: export job with tickets T-1..T-5`. In the timezone of the runs (CEST) that commit is
   `c4f7a4fa3af901b82404c80c535723963a441b9a`, the fixture base `checks.sh` compares against;
   elsewhere use the id your commit gets.
2. Preflight: `AGENTS.md`, `.claude/review-gates.md`, the story and T-1…T-5 tracked; one commit;
   `git status --porcelain` empty. Any mismatch stops before a run.
3. Plugin copies: `mkdir -p plugins/<variant> && git -C <repo> archive <commit> plugins/dev-workflow
   | tar xf - --strip-components=2 -C plugins/<variant>` — `baseline` at `6b15993`, `candidate<k>`
   at the measured commit (or rebuilt from the durable source above).
4. Save the prompts of `prompts.md` as `prompts/K1.txt` … `L.txt` and `prompts/base-K1.txt` …
   `base-K3.txt`; extract `run.sh` and `checks.sh` from `runner.md`; run the invocation there.

## Limit

Ten candidate samples on four prompts and one fixture: they show the skill can be followed in these
cases, not that it always is. Reading checks are made by the author.
