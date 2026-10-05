# Replay package — controlled change (G1a)

The named verification for
`docs/superpowers/stories/2026-10-05-controlled-change-to-an-approved-story-story.md` AC-12:
`intake`'s amendment route, replayed on the two recorded 2c narrowings. Spec:
`docs/superpowers/specs/2026-10-05-controlled-change-design.md` §4.

## What is here

| Path | Content | Source |
|---|---|---|
| `partN/baseline.md` | the story as approved, before any amendment | commit in `partN/meta.txt` (part 1 `9fb981f`, part 2 `5fcc072`) |
| `partN/meta.txt` | story path, full baseline and after commit IDs, the baseline's sha256 | computed 2026-10-05 |
| `partN/after.md` | the story as its narrowing commit left it, change-record lines removed | `f9aae57` (part 1), `32609a0` (part 2) |
| `partN/decision.txt` | the narrowing commit's message, table lines removed, plus one attribution line | same commits |
| `partN/decision-evidence.md` | sanitized excerpt of the assessment the decision was taken on | see *Sanitization* |
| `partN/changed-paths.txt` | every path the narrowing commit touched (`git show --format= --name-only`) | same commits |
| `expected/partN-record.md` | the historical change records, verbatim — the comparator's answer key | the after-texts' removed lines |
| `out/partN-record.md` | the replay agent's change records | the run below |
| `compare.md` | row-by-row comparison with the historical records | the comparator |

The source commits are not on any branch; git may prune them. The package is what the
replay reads.

**Not copied: the rules.** The replay reads `plugins/dev-workflow/skills/intake/SKILL.md`,
`.claude/review-gates.md` and `AGENTS.md` from the commit named under *Run*, so the procedure
under test is pinned by its commit rather than duplicated here.

## Sanitization

The repository is public, and the two assessments are local, untracked advisory files. They
are excerpted, never copied whole. Kept verbatim: the recommendation, the conditions or
limits the decision adopted, and the stated price of the option. Removed, with the reason:

- **Part 1** (`20261002-132344-telemetry-t1-scope-triage-assessment.md`): the verified
  snapshot (local worktree paths, HEAD, untracked-file list, per-pass finding counts — local
  state, not decision content); the analysis of three spec-level Major findings and
  recommendation 4, which repairs them (spec repairs, not part of the story narrowing); the
  paragraph on whether one finding increase proves non-convergence (loop analysis, not a
  decision); the closing "limits of this assessment" note (process disclaimer).
- **Part 2** (`20261003-104113-loop-usefulness-warning-assessment.md`): the opening address;
  the verified state (local worktree path, HEADs); two framing paragraphs on the security
  profile and on reading local finding files (side analysis); the closing limits note. The
  evidence list is kept, as it names the spec contradiction the decision acted on.
- **Both** decision texts: the commit messages lose their fate-table lines (the answer
  key), and gain one attribution line that states only what the source states (part 1:
  the pass-4 narrowing was Daniel's, the pass-1 change names no decider; part 2: the story's
  own amendment paragraph names Daniel).

**Input overlap, not removed**, because it is the decision itself: part 1's commit message
says the credit balance was dropped, unattributed effort kept and attribution by provenance
only; both assessments recommend the narrowings the records encode; the after-texts carry the
new criteria wording. A replay reproduces the *record*, not the decision.

## Run

The recorded run (run 6, 2026-10-05) read three rules files with these sha256 values:
`intake-SKILL.md` f6652e89a6ede920f49c376db74f37a5400d4cac0b71dfdecce7ddfee7cb105a,
`review-gates.md` a827dfbf0400778762a08cfc4d49e752647cf5ac913bd292a1f84299b51f9c96,
`AGENTS.md` 80a41d9784d14b1bf114951ff41a810b2897fe6f1ef56729612fe273c1fe2354. They were read from a
WIP commit that was later amended away; the same bytes are `plugins/dev-workflow/skills/intake/SKILL.md`,
`.claude/review-gates.md` and `AGENTS.md` in the commit that adds this package. Its records are
`out/`, its comparison `compare.md`. To run it again:

1. Copy `part1/` and `part2/` into `in/` of an empty scratch directory outside any checkout,
   and extract the three rules files from the commit that adds this package (check them against the
   sha256 values above), or from a later commit named in the result, into `rules/`
   (`intake-SKILL.md`, `review-gates.md`, `AGENTS.md`).
2. Give a fresh agent this prompt, with the directory filled in:

   ```text
   You are a coding session following the `intake` skill's route "Amending an approved story or spec" (its text: <dir>/rules/intake-SKILL.md). Read only files under <dir>/in and <dir>/rules. For each of part1 and part2: in/partN/meta.txt names the story path and the approved baseline (commit and sha256); in/partN/baseline.md is that approved text; in/partN/after.md is the text after the change, without its change record; in/partN/decision.txt and in/partN/decision-evidence.md are the human decision and a sanitized excerpt of the assessment it was taken on; in/partN/changed-paths.txt lists every path the change touched. Run steps 1, 2, 4, 5, 6 and 7 of the route and write the change record it prescribes to <dir>/out/partN-record.md. Do not run step 3 or step 8: there is no repository. For step 9, list what stays blocked at the end of the record. Apply the rules in the rules directory even where the historical change predates them. Write nothing else. When done, reply with the two output paths and one line per part saying how many table rows you wrote.
   ```

3. Compare `out/` with `expected/` row by row, mapping historical `Narrowed` → `kept` plus a
   `moved` or `dropped` remainder, `Replaced` → `withdrawn` plus `added`, `Deferred` →
   `moved`, `Kept` → `kept`. Pass condition: AC-12.

Steps 1 and 2 exercise route steps 1, 2 and 4–7 only. Steps 3 and 8 need a live repository and
are not exercised here.
