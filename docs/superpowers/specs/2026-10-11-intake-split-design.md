# Intake skill split into a route choice and two route files — Design

**Story:** `docs/superpowers/stories/2026-10-11-split-the-intake-skill-into-a-route-story.md` — read its profile fresh at each pass.

**Date:** 2026-10-11 · **Decided with:** the orchestrator session `dev-workflow-kit-d4` under
Daniel's sprint instruction of 2026-10-11 (09:54): the three deferred intake Minors stay out; the
replay is the pilot's full after-check plus the two handover runs; the split is rebuilt on
0.23.0's text, not on the pilot candidate.

## 1. Starting point

- Shipped: `plugins/dev-workflow/skills/intake/SKILL.md`, dev-workflow 0.23.0, 32,932 bytes (32,627 characters),
  sha256 `e629b1ba727f0ea22d9e422e4d5a272251c34a428c1f6524ecbda8a83a9e7089` (the same bytes as
  Step 1's replay set 2, `docs/superpowers/replays/2026-10-10-added-criterion-row/README.md`).
- Pilot: branch `intake-skill-pilot` (`b348b9c`),
  `docs/superpowers/replays/2026-10-10-intake-skill-pilot/` — proposal, candidate files (built on
  the skill at `860e56c`), fixture, prompts A1–G1, runner, case table (`compare.md`).
- Between `860e56c` and 0.23.0 the skill changed only inside the amendment route: step 5's
  last sentence, step 6's last sentence, one template field line, and the section
  "Added without an earlier condition — the rules" with its example
  (`git diff 860e56c fa5f275 -- plugins/dev-workflow/skills/intake/SKILL.md`, 34 insertions,
  1 deletion). The pilot's risk 3 (no slot for an added criterion) is what 0.23.0 fixed.

## 2. Layout (AC-1, AC-2, AC-8)

```
plugins/dev-workflow/skills/intake/
  SKILL.md                    frontmatter, Overview, "Choose the route first" + load rule,
                              Story template, size calibration, AC-ID rules + worked example,
                              profile log, the shared stop (no AGENTS.md), Common mistakes
  capture-new-story.md        the Flow (steps 1–11), Writing the story file, commit protocol,
                              the Flow's stops, Hand-off
  amend-approved-artifact.md  "## Amending an approved story or spec" entire: steps 1–9,
                              The change record, closed sets, the added-criterion rules and
                              example, the narrowed-or-replaced test and example rows
```

- **Source text.** Each part is cut from the 0.23.0 `SKILL.md`, not from the pilot candidate.
  The pilot's mapping (`proposal.md` § (c), rows 1–33 and N1–N4) is reused as the cut list; its
  rows 24–27 cover the amendment route and take 0.23.0's text, including the four additions in §1.
- **New text**, and only this: the route table and its paragraph (pilot N1, row 6), the load
  rule (pilot N2, candidate2's wording, quoted in the pilot's `compare.md`), one Common-mistakes
  line (N3), and each route file's header naming `SKILL.md` for the shared parts plus its own
  `Target model:` line (N4). Pointer rewordings only where a sentence names a location that
  moved (pilot rows 4, 9, 10, 16, 25, 26, 28), plus one more: 0.23.0's step 6 says "rules 1–5"
  and "rule 2"; both gain "(in `SKILL.md`)". Step 6's phrase "the sentence before this one" is
  left as it is (story §5: the Minors stay out).
- **Unchanged:** the skill name and `description` frontmatter (byte for byte), the story path and
  template, the change-record template and closed sets, the heading
  `## Amending an approved story or spec` (check 4f anchors on it; `skills/sparring/SKILL.md`
  points at it by name). The sparring pointer stays valid: it names the section, not the file.
- **The old→new account (AC-2)** is a table in the replay package: every part of the 0.23.0 file
  with its new file and `verbatim`, `moved` or `reworded`, and the reworded text quoted. A
  line-coverage script (every non-blank line of the 0.23.0 file found in one of the three files)
  backs it; lines it cannot find must each be a row marked `reworded`.

## 3. Repository checks and docs (AC-9, AC-10)

- `scripts/check-invariants.sh` check 4f: `CR_FILE` → `plugins/dev-workflow/skills/intake/amend-approved-artifact.md`.
  Check 4d keeps `SKILL.md` (the story template stays there). Check 4a scans every `*.md` file
  that contains the phrase `prompt artifact and follows` (`grep -rl`, not a `SKILL.md` glob), so
  each route file's header carries that conformance sentence and one `Target model:` line, and 4a
  then reads both files with no change to the check.
- `scripts/check-invariants.test.sh`: its shared fixture writes the amendment section to the new
  file instead of `SKILL.md`; the 4f cases write their candidate template there. Same cases, same
  expected results; the suite's case count is unchanged.
- Docs that name the file layout: `AGENTS.md` layout tree and `docs/architecture.md` line
  `skills/{intake,harden-finding,sparring}/SKILL.md` gain the two route files. These are layout
  records, not rule sentences (`.claude/review-gates.md`, moratorium paragraph).
- `todos.md` names `plugins/dev-workflow/skills/intake/SKILL.md` for two sections that move to
  `amend-approved-artifact.md` ("The change record", in the row from PR #47; "Added without an
  earlier condition — the rules", in the row from the added-criterion change). Those two path
  names are updated and nothing else in either row changes; the deferred work stays deferred.
- No other sentence changes. The search behind that claim (`grep` for `skills/intake`,
  `intake/SKILL` and the section heading, 2026-10-11, outside `source-files/`, `.context/`,
  `docs/superpowers/` and `.claude/worktrees/`) found these sites besides the ones above, each
  naming the skill or the section and not the file: README.md, MANIFEST.md, sparring
  SKILL.md, CHANGELOG.md, `.claude/review-gates.md`, `scripts/status-view.test.sh`. The plan
  repeats the search on the implemented tree, because a site the search pattern misses is not
  covered by this list.
- Version 0.23.0 → **0.24.0** (new files and a new load step change how the skill runs);
  `CHANGELOG.md` entry; the battery green.

## 4. Replay (AC-3 to AC-7)

A new package, `docs/superpowers/replays/2026-10-11-intake-split/`, docs only (an `AGENTS.md`
fixture file is stored as `agents-md.md`, as Step 1 did, to keep the package prose).

- **Variants.** `baseline` = `plugins/dev-workflow` at `fa5f275` (0.23.0); `split` = the same tree
  at the commit under test. Both extracted with `git archive`; each copy's intake files hashed and
  the hashes recorded before the runs.
- **Fixture, prompts, flags:** the pilot's (`fixture/`, `prompts.md` A1–G1, `runner.md`
  invocation), unchanged; one fresh fixture copy per run; model `claude-opus-5-5`.
- **Runs (AC-3, AC-4):** per variant, A–G once each, D and G three times each (r1–r3) — 11 case
  runs per variant, a multi-turn case counting as one.
- **Run validity, before any comparison.** A turn counts only when its stream has an init record
  listing exactly one `dev-workflow` plugin at the variant's copy (or, for AC-5, the cache path)
  and the requested model, a final `result` record with `is_error` false, and no recorded non-zero
  exit. A turn failing any of these is **unavailable evidence**: the case run is repeated from
  turn 1, and it is never scored as a missed check. A case run still unavailable after one repeat
  stops the replay and is reported; it does not count as a pass for either variant.
- **Checks, per case.** The pilot's case table (`compare.md`) for A, C, E, F and G, with two
  changes for the amendment records:
  - **Shared record checks** (B, D, H): the record sits at the end of §3; the header names a reason
    class from the closed set and the baseline commit; all seven field lines are present; every
    fate and AC operation is from the closed sets; every baseline condition has a row (AC-1 to
    AC-4, the §2 outcome sentence, the §2 exclusion); **every row's earlier-condition cell names a
    baseline condition** — AC-1 to AC-4 or one of the two §2 conditions, quoted or named by section, nothing else; one changed file,
    no new story file; the commit message names the decider and the date; nothing is resumed.
    Step 1's `checks.sh` predicate for that cell (`badrow`) only tests for an `AC-<n>` or `§<n>`
    prefix and would accept an `AC-5` row, so the new package checks the cell against the
    baseline's identifiers (AC-1 to AC-4) and §2, and the rest is a reading check.
  - **Case outcomes**, against the fixture story `2026-10-01-export-job-story.md`. **B:** AC-2
    narrowed with a dated note (e-mail dropped, in-app notice kept); CSV is AC-5 and stands in
    *Added without an earlier condition*; AC-1, AC-3, AC-4 and §2 unchanged. **D:** CSV is AC-5 in
    that field; AC-1 to AC-4 and §2 unchanged — Step 1's expectations for D1. **H:** as B.
- **Regression** (AC-3): any check a baseline run meets that the split run of the same case and
  replicate misses — exactly the pilot's list (`proposal.md` § (e)). Where the baseline itself
  misses a check in a replicate, the split must not miss it more often across the replicates of
  that case. Case D (AC-4): every split replicate meets every check its baseline replicate meets.
- **Installed run (AC-5).** The split is installed through a marketplace into a plugin cache —
  not `--plugin-dir` — and case B runs once on it. Load evidence as Step 1: the init record lists
  exactly one `dev-workflow` plugin, at a cache path, version 0.24.0; the cache copy's intake files
  hash to the commit's; and the run's tool trace shows `amend-approved-artifact.md` read in full from
  that cache copy before the route's first step. The order is Daniel's (2026-10-11 10:01, relayed by the orchestrator):
  first an isolated configuration directory (`CLAUDE_CONFIG_DIR`); only if the login does not
  carry over there, a local marketplace registered temporarily in his real `~/.claude/plugins`,
  with the split installed project-scoped into the fixture. In either case his installed
  `dev-workflow@dev-workflow-kit` 0.23.0 and his user settings are not changed, and whatever the
  run registers is removed afterwards and the removal verified. Commands and the feasibility probe
  are the plan's.
- **Compaction run (AC-6), case H, three turns on the split, prompts written into the package.**
  H1: the B amendment request, saying that nobody has decided it yet (drop the e-mail
  notification, add CSV) — the route starts and asks for the decision. The prompt says so
  explicitly because a request with no decider named was taken as the decision in one pilot G
  run (baseline r3), and an H1 that writes leaves nothing to test after the compaction; such a
  run is a failed H run. Then a compaction of that session.
  H2: a decision covering only the e-mail part (who, when, where, quoted) — the route must ask the
  uncovered CSV question and wait, writing nothing. H3: a decision covering CSV — the route
  completes. Pass = the compaction record appears in the session stream before H2; in H2 the
  route file is read again before the route's next step, the CSV question is asked and nothing is
  written or committed; after H3 the record meets the shared record checks and B's outcomes. The
  same three turns run once on the baseline as a diagnostic: if the baseline fails too, the case
  is reported as possibly faulty, but AC-6 still needs the split to pass. How to force the
  compaction is the plan's, after a probe.
- **Size (AC-1):** characters of `SKILL.md` + each route file, per route, against the 0.23.0 file's 32,627 characters, written
  into the package.
- **Not adopted (AC-7).** If any of AC-3 to AC-6 fails, or the installed or compaction run cannot
  be produced at all, the skill change is not merged: the branch reverts the skill, check and
  version changes, and the PR carries only the replay package and a `todos.md` record of the
  result. A Gate-B fix that changes any intake file repeats the runs of the route it touches
  before the cycle closes.

## 5. Evidence for battery+check

The check that fails without the change: the AC-1 size measurement (under 0.23.0 a run of either route
reads all 32,627 characters) and check 4f reading `amend-approved-artifact.md` (absent at `fa5f275`). The named
verification is the replay; its counterfactual is the baseline variant run in the same session.

## 6. Out of scope

The three deferred Minors (`todos.md`, "From the added-criterion change"); any wording change
inside a route beyond §2's pointers; other skills; Codex or other clients (pilot risk 7).
