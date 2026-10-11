# Replay — intake split (not adopted)

Named verification for story
`docs/superpowers/stories/2026-10-11-split-the-intake-skill-into-a-route-story.md` (AC-1 to AC-7),
per spec `docs/superpowers/specs/2026-10-11-intake-split-design.md` §4 (amended in `5c9139c`) and
plan `docs/superpowers/plans/2026-10-11-intake-split.md` Tasks 5 and 5b.

**Result: the split is not adopted.** The intake skill stays the 0.23.0 text. In both sets, after a
compaction the split never read its route file again (AC-6), with the conditional re-read sentence
(set 1) and with an unconditional one (set 2). Set 2 was the one bounded round Daniel decided on
2026-10-11 11:21; its bound made non-adoption automatic. Per case: `compare.md`.

## What is here

| Path | Content |
|---|---|
| `compare.md` | per case and replicate, both sets; verdicts; size table (AC-1); effort |
| `account.md` | the old→new account (AC-2): every part of the 0.23.0 file, its new place and status |
| `evidence/checks-output.txt` | the checks script's line per run, both sets |
| `evidence/h-traces.md` | the tool traces of the four H runs around the compaction |
| `candidate/` | the split as replayed in set 2 (`SKILL.md`, `capture-new-story.md`, `amend-approved-artifact.md`); not under a `skills/` path on purpose: evidence, not a loadable skill |
| `fixture/` | the pilot's fixture, unchanged; `AGENTS.md` stored as `agents-md.md` so the package stays prose |
| `prompts.md` | every prompt, A1–G1 from the pilot, H1–H3 and the `/compact` turn new |
| `runner.md` | `run.sh`, `suite.sh`, `reps.sh`, `checks.py` and the mutation script, as run |

## How it was run

- 2026-10-11, client `claude` 2.1.296, model `claude-opus-5-5`; flags as in `runner.md`
  (`--setting-sources project --strict-mcp-config --permission-mode bypassPermissions
  --max-budget-usd 4`, `stream-json`); one fresh fixture copy per run, outside any checkout.
- Variants, each extracted with `git archive`:

  | Variant | Tree | intake file sha256 |
  |---|---|---|
  | `baseline`, `baseline2` | `plugins/dev-workflow` at `fa5f275` (0.23.0) | `SKILL.md` `e629b1ba…7089` |
  | `split` (set 1) | WIP `344dfda` | `SKILL.md` `67fe107a…42ef`, `capture-new-story.md` `65a2ec7c…58cb`, `amend-approved-artifact.md` `c433d93d…1d6f` |
  | `split2` (set 2) | WIP `f811cd9` | `SKILL.md` `7748abf6…cae`, the two route files unchanged from set 1 |

  The set-1 `SKILL.md` and `capture-new-story.md` have the same bytes as the pilot's candidate2
  files (`b348b9c`); only `amend-approved-artifact.md` differs, by 0.23.0's amendment-route
  additions.
- Set 1: per variant A–G once, D and G r1–r3, H once (4 turns). Set 2: H on both, B r1–r3 on both.
  The installed run (AC-5) was not run (`compare.md`).
- Every run met the run-validity rule; none was repeated. **The as-run checker (`runner.md`,
  `checks.py`) is weaker than that rule**, and is kept as run: it tests the init path by substring
  (`/plugins/split` also matches `split2`), treats a `result` without `is_error` as valid, reports
  `valid=yes` for a run with no turn logs, and reads a failing `git` command as empty output (no
  change, no commit). A separate re-check after the runs, on all 52 turn logs, required the exact
  variant path, an explicit `is_error: false` and no exit file: 0 failures. Any reuse of the
  checker needs those four gaps closed first.
- Instruction sources beyond the variant: one run, baseline2/H turn 3, read intake text from the
  installed plugin cache (`~/.claude/plugins/cache/dev-workflow-kit/dev-workflow/0.13.1/` and
  `…/0.23.0/skills/intake/SKILL.md`); the 0.23.0 file there hashes to `e629b1ba…7089`, the
  baseline's own bytes, the 0.13.1 file to `a23aeb3d…f7bc`. The validity rule checks the plugin
  load, not what a run reads afterwards.

## Re-running

The scripts in `runner.md` are kept exactly as run and expect this layout in one scratch
directory outside any git checkout (so no parent `CLAUDE.md` loads):

1. **Fixture repository.** Build `fixture-template/` from `fixture/`: copy `docs/`, rename
   `agents-md.md` to `AGENTS.md`, move `review-gates.md` to `.claude/review-gates.md`; then
   `git init -b main`, `git add -A` and commit once. The as-run start commit was `80b9009`; a
   rebuilt fixture gets a different id, so replace `BASE = '80b9009'` in `checks.py` with it.
2. **Plugin copies.** `mkdir -p plugins/baseline && git -C <repo> archive fa5f275
   plugins/dev-workflow | tar xf - --strip-components=2 -C plugins/baseline`, and the same into
   `plugins/split` from `344dfda` and `plugins/split2` from `f811cd9` — those WIP commits are not
   on `main` and may be gone; without them, copy `candidate/` over `skills/intake/` of a
   `fa5f275` copy for `split2`, and for `split` also put back the set-1 load-rule sentence quoted
   in `account.md` (the only difference). Raise `plugin.json` to `0.24.0` in both if the version
   matters to the run. Compare the intake hashes with the table above.
3. **Prompts.** Save each block of `prompts.md` as `prompts/<name>.txt` (A1 … H3, and `HC.txt`
   for the `/compact` turn).
4. **Run.** `sh suite.sh baseline`, `sh suite.sh split`, `sh reps.sh baseline`, `sh reps.sh
   split`; set 2 as in `compare.md` (`run.sh split2 …`, `run.sh baseline2 …`). Then `python3
   checks.py <dir> <variant> <case>` per run. Close the checker gaps listed above before relying
   on its `valid=yes`.

## AC-2: the old→new account

The full table is `account.md`. The cut followed the pilot's mapping (`git show
b348b9c:docs/superpowers/replays/2026-10-10-intake-skill-pilot/proposal.md`, § (c), rows 1–33,
N1–N4), with 0.23.0's four amendment-route additions placed in `amend-approved-artifact.md`
(spec §1); `candidate/` holds the new text. Line coverage on the set-2 tree (script and its full
output in `runner.md`): every non-blank line of the 0.23.0 file occurs in one of
the three files except 24, all inside rows the mapping marks reworded or rewrapped — rows 4 (lines
27–28), 5 (32–39), 6 (41–43), 9–10 (138–141), 16 (205–207), 25 (339), 26 (360, 368: "(in
`SKILL.md`)" added) and 28 (466–467). No row is dropped as a whole, but row 5 lost one rationale
clause (`account.md`); the pilot's table had called that row "same wording". Set 2 differs from set 1 in exactly
one sentence of `SKILL.md`'s load rule.

## Repository checks on the split (before the revert)

- Battery green on WIP `344dfda`, including `check-version-bump.sh main`.
- Check 4f read `amend-approved-artifact.md`; the counterfactual — that file removed from a scratch
  copy — exits 1 with "…amend-approved-artifact.md is missing, so the change-record template cannot
  be checked."
- Mutation re-measure (checker header procedure, `runner.md`), with the suite's fixture writing the
  route file: 4a 20, 4b 22, 4c 20, 4d 22, 4e 9, 4f 34, 4g 11, 4h 28 flipped cases, no accept case —
  the counts the suite's comment records.
- Prompt-standards review (plan Task 2b): **not completed** item by item before the replay settled
  non-adoption. What was checked: each route file carries one `Target model:` line and the
  conformance sentence (item 1, check 4a green); the load rule states its why (item 6) and its stop
  when the file cannot be read (item 3). Item 11 is where the split fails in practice: the load rule
  promises a re-read that nothing enforces, and the replay shows it does not happen after a
  compaction.

All of that is history: the branch reverted the skill, the checker, its suite, the layout lines,
the version and the CHANGELOG to `fa5f275`.

## Limits

n = 1 per case and variant apart from the replicates; model output is not deterministic. Reading
checks were made by the author of the change. One fixture, one model, one client version. The H
result is about print-mode `/compact`; an automatic compaction in an interactive session was not
tested.

## Follow-up candidate

Recorded in `todos.md` as "Step 2b candidate: split + compaction re-injection hook". Measured: after
a compaction the split agent did not read its route file again, under either sentence. Not measured:
what it still held of the route, or why it skipped the read. Hypothesis to test: re-injecting the
route mechanically closes the gap — for example a `SessionStart` hook on the `compact` matcher printing the active route file, named by
a state file written when a route starts. Evidence: the two failing H traces in
`evidence/h-traces.md`.
