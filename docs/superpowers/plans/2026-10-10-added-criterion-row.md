# Change-record field for an added criterion — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Story:** `docs/superpowers/stories/2026-10-10-change-record-row-for-an-added-story.md` — read its profile fresh at each pass.

**Goal:** intake's amendment route gets a defined field for a criterion added with no earlier
condition, check 4f pins it, and a 5×D + 3×B replay shows the changed skill followed.

**Architecture:** one prompt edit (template line, two step sentences, rules beside the closed
sets), the matching extension of check 4f and its suite, a minor version bump, then a docs-only
replay package measured against the Gate-B-closed skill revision.

**Tech Stack:** Markdown prompt, POSIX `sh` + `awk` (check 4f), `claude -p` replay runner.

**Spec:** `docs/superpowers/specs/2026-10-10-added-criterion-row-design.md` (Gate-A spec cycle
c1vdyomddrxa closed in cffb257).

## Global Constraints

- The template line, verbatim from spec §2.1:
  `- **Added without an earlier condition:** <AC-n: "requirement text", or in a spec: "the added condition, quoted"> → per the decision: "<quoted passage>"; or none.`
- Closed sets unchanged (spec §2.1, §6). No obligation of spec §2.3's table dropped.
- dev-workflow 0.22.0 → 0.23.0 with a CHANGELOG entry (invariant 12).
- Prompt text passes `docs/prompt-standards.md`, all 12 items (invariant 11).
- Never `git add -A` in this checkout: agent worktrees under `.claude/worktrees/` are not ignored.
- Branch `intake-skill-pilot` is read with `git show b348b9c:<path>` only; never merged or checked out here.
- Replay: model `claude-opus-5-5`, flags `--plugin-dir`, `--setting-sources project`, `--strict-mcp-config`, a fresh fixture copy per run.

## Review Focus

- A spec amendment adding a condition: the field must accept the quoted-condition form without a story ID (spec §2.1, §2.2) — read the step-6 sentence for it.
- A change adding nothing new: the field is `none`, and a replacement (`withdrawn; added AC-<n>`) does not also appear in the field.
- An added criterion with no quotable decision passage: it goes to *Unaccounted*, not into the field.
- 4f placement: the new line moved outside the fence is rejected, and a closed set moved inside is still rejected at its new index.
- A replay run whose record lists CSV both as a replacement and in the field: counts as a failure of "exactly one of the two shapes".

## Sources and impact boundary

Read: the story; the spec; `plugins/dev-workflow/skills/intake/SKILL.md` lines 330–430 (amendment
route, change record, closed sets); `scripts/check-invariants.sh` check 4f (lines 740–815);
`scripts/check-invariants.test.sh` `CR_LINES`, `cr_section` and the 4f cases (lines 85–100,
1085–1120); `.claude/review-gates.md` in full; the pilot package at b348b9c (`compare.md`,
`prompts.md`, `runner.md`, `evidence/checks.md`, `evidence/artifacts.md`, fixture).
Impact boundary: the intake skill, check 4f and its suite, the plugin manifest and CHANGELOG, one
new replay package. Grep before editing: "12 lines"/"12 template lines" appear only in check 4f's
comment and message and the suite's fixture comment (verified 2026-10-10); no other copy of the
template exists (`grep -rnF "Earlier condition"`). AGENTS.md invariant 11 names 4f's scope without
a count, so it stays as is. Not read: other skills, the hook.

## Handover boundary

The completed story: PR opened, CI and bots processed, squash-merged. A failed measurement that
leads to no reasoned correction is also a boundary (spec §3: decision to Daniel). Never inside a
running review cycle.

---

### Task 1: Field, steps, check 4f, version — through Gate B

**Files:**
- Modify: `plugins/dev-workflow/skills/intake/SKILL.md` (template fence after the table row;
  step 5 at line 345; step 6 at line 356; rules after the closed sets at line 405–410)
- Modify: `scripts/check-invariants.sh` (check 4f: `CR_REQ`, the `i <= 8` placement bound, the
  header comment, the failure message)
- Modify: `scripts/check-invariants.test.sh` (`CR_LINES`, its comment, the placement cases'
  `sed -n` indices, the loop bound)
- Modify: `plugins/dev-workflow/.claude-plugin/plugin.json`, `plugins/dev-workflow/CHANGELOG.md`

**Outcome:** the skill carries the field and its rules as spec §2.1–2.2 state them; 4f pins 13
lines, 9 inside the fence; the battery is green; Gate B closed.

**Decided already:** the template line (Global Constraints); the new line is `CR_REQ`'s third
entry, between the table header and *Unaccounted*; the rule bullets of spec §2.1 go into the skill
next to the closed sets, prefaced so a reader cannot take them for a fifth closed set; the step 5
and step 6 sentences carry spec §2.2's content.

**Implementer's decision space:** exact wording of the two step sentences and the rule bullets,
within spec §2.1–2.2 and prompt-standards; CHANGELOG wording in the file's existing form.

- [ ] **Step 1: Suite first (red).** Update `CR_LINES` (13 lines, new one third) and the suite's
  indices and loop bound. Run `sh scripts/check-invariants.test.sh`.
  Expected: FAIL — `cr_case` runs the unchanged checker, so the missing/altered cases for the new
  line and the shifted placement diagnostics fail. That is the red stage; do not repair the tests.
- [ ] **Step 2: Checker (suite green) and counterfactual.** Update `CR_REQ`, the placement bound
  (`i <= 9`) and both placement comparisons in 4f. Run `sh scripts/check-invariants.test.sh`:
  expected PASS. Then run `sh scripts/check-invariants.sh` on the still-unmodified skill:
  expected FAIL naming "line 3 occurs 0 times" on the shipped 0.22.0 text. Record that output for
  the evidence entry.
- [ ] **Step 3: Skill edit.** Add the line, the rules and the two step sentences. Re-run
  `sh scripts/check-invariants.sh`. Expected: PASS.
- [ ] **Step 4: Mutation probes** (via the suite's loop, which now covers line 3 and 13):
  - new line deleted → "line 3 occurs 0 times";
  - new line altered → same;
  - new line moved below the fence → "line 3 must be inside";
  - the Reason-class set moved into the fence → "line 10 must be outside".
  Expected: each rejected. Also run one probe against the real skill: a scratch copy with the new
  line deleted fails 4f.
- [ ] **Step 5: Version and prompt standards.** Bump to 0.23.0; add the CHANGELOG entry. Read the
  changed skill text against all 12 items of `docs/prompt-standards.md` and note the result.
- [ ] **Step 6: Battery.** Run the quality command from AGENTS.md § Commands.
  Expected: exit 0. (`check-version-bump.sh main` runs meaningfully only after the WIP commit.)
- [ ] **Step 7: Gate B.** `git commit -m 'WIP: added-criterion field + check 4f'` staging the five
  files by name; run `sh scripts/check-version-bump.sh main` (expected: pass); then Gate B per
  `.claude/review-gates.md` (fresh nonce, floor 3 per the story at level 1, two sequential
  single-branch calls per pass, evidence entry quoted, story path carried, dispositions files).
  Evidence entry: the 4f check of step 2 (fails on 0.22.0 text, passes on the change) and its
  suite cases; the behavioural claim is covered by Task 2's named verification, pending at this
  point. Close by `git commit --amend` with the real message, provenance line, curve, ledger
  check and evidence entry.

### Task 2: Replay measurement (named verification)

**Files:**
- Create: `docs/superpowers/replays/2026-10-10-added-criterion-row/` — `README.md`, `fixture/`
  (from b348b9c, with the fixture's `AGENTS.md` stored as `fixture/agents-md.md`: a file named
  `AGENTS.md` is a prompt, not prose, under `.claude/review-gates.md` "What counts as prose", and
  would take the package out of the docs-only exemption), `prompts.md` (D1, B1 verbatim),
  `runner.md` (scripts as run), `checks.md` (per-run check output), `evidence/artifacts.md`
  (per run: the story diff against the fixture, the change record, the commit subject and body,
  and the trace excerpts a check relied on — failed and aborted runs included), `compare.md`
  (per-run, per-check table linking each verdict to its evidence; before/after)

**Outcome:** 8 runs on the Gate-B-closed skill revision, each reported per spec §3's check table.

**Decided already:** spec §3 (runs, checks, acceptance, failure handling, limit). Runs are made in
the session scratchpad from a copy of `plugins/dev-workflow` at the Task-1 closing commit; only the
package's text files are committed. The README records fixture source, prompts, model, runner,
measured commit and the skill file's sha256. The before-measurement is the pilot's baseline
(cited, not re-run).

**Implementer's decision space:** the checks script's form (mechanical checks scripted, reading
checks done by reading each run's story diff and record and written down per run).

- [ ] **Step 0: Prepare the fixture** per the pilot README's "Re-running" (b348b9c): in the
  scratchpad, outside any git checkout, build `fixture-template/` from `fixture/` with
  `agents-md.md` restored to `AGENTS.md` and `review-gates.md` moved to `.claude/`; `git init -b
  main`; commit everything once. Verify: the story, `AGENTS.md` and `.claude/review-gates.md` are
  present, one commit exists, the index and worktree are clean. Any mismatch stops before a run:
  a setup defect must not consume the measurement set.
- [ ] **Step 1:** Assemble the runner from `runner.md` at b348b9c with one variant pointing at the
  copied plugin; confirm one run's stream shows the intake skill loaded from that copy (its base
  directory), else stop: the run would measure the installed plugin.
- [ ] **Step 2:** Run 5 × D1 and 3 × B1. Keep every run, including failed or aborted ones.
- [ ] **Step 3:** Apply every check of spec §3 to every run. Write `checks.md` and `compare.md`.
  Expected for adoption: 8 of 8 pass every check.
- [ ] **Step 4 (only on failure):** investigate the cause and report it in `compare.md`. A
  correction with a stated reason goes back through Task 1 (a new Gate-B cycle) and then a fresh
  full set of 8 runs; the failed set stays in the package. Without such a correction: stop, keep
  the 0.22.0 template (revert Task 1 before the PR or close it unmerged), hand the decision to
  Daniel.
- [ ] **Step 5:** Commit the package, staging its paths by name. Before committing, confirm every
  staged path is `docs/**.md` and none is named `AGENTS.md` or `CLAUDE.md` or sits under a
  `.claude/`, `plugins/`, `skills/` or `commands/` directory; only then is it Gate B N/A per
  `.claude/review-gates.md`, "What counts as prose". Otherwise it takes its own Gate-B cycle.

### Task 3: PR

- [ ] **Step 1:** Push the branch, open the PR. Body: story, spec, plan paths; the 8-run result;
  the four owed hardenings from cffb257 and any from Task 1's cycles as open obligations.
- [ ] **Step 2:** Wait for CI and the bots per `docs/pr-review-bots.md`; process comments with
  `/dev-workflow:process-pr-review`.
- [ ] **Step 2a: Measured-revision gate.** Before merging, the PR head's
  `plugins/dev-workflow/skills/intake/SKILL.md` sha256 must equal the one the package README
  records. A skill change after measurement — a bot fix, a merge resolution — needs its own
  Gate-B cycle and a fresh complete 5 D + 3 B set (earlier sets stay in the package); without that,
  stop adoption and surface the decision to Daniel.
- [ ] **Step 3:** Squash body carries every record of the branch: both Gate-A cycles' provenance
  lines, curves and ledger lines (spec cffb257, plan cycle), every Gate-B record, the evidence
  entry. Squash-merge when green and reviews are done.
- [ ] **Step 4:** Update the handover; the next unit (queued: software-factory prior-art prompt
  in `.context/sparring/20261010-195500-*`, then Step 2) starts in a fresh session.
