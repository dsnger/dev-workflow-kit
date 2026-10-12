# A `ticket` skill for bugs and improvements — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Story:** `docs/superpowers/stories/2026-10-11-a-ticket-skill-for-bugs-and-improvements-story.md` — read its profile fresh at each pass.

**Goal:** the plugin ships `/dev-workflow:ticket` as one skill file, and a replay of K1–K3 plus `list`
shows the skill followed, against an intake-only baseline.

**Architecture:** one new prompt file, a minor version bump with its CHANGELOG entry and three
inventory rows, and a docs-only replay package whose checks are committed before any run. The
baseline runs need no skill and may run first; the candidate runs measure the Gate-B-closed skill.

**Tech Stack:** Markdown prompt; POSIX `sh` + `git` + `jq` for the runner and mechanical checks,
kept as text inside the package's `.md` files; `claude -p` replay runner.

**Spec:** `docs/superpowers/specs/2026-10-11-ticket-skill-design.md` (Gate-A spec cycle ocgrixmmce
closed in e4f3071).

## Global Constraints

- One file: `plugins/dev-workflow/skills/ticket/SKILL.md`, frontmatter `name: ticket`; no route
  files, no file it points to for its own steps (spec §2.1, story AC-1). Target ≤ 15,000
  characters; the PR states the size, and a reason if it is larger.
- Closed sets, verbatim: severity `blocker|major|minor|nit`; category
  `bug|regression|improvement|docs`; state `needs-triage|needs-info|ready|in-progress|done|wontfix`.
- Ticket path `docs/superpowers/tickets/<YYYY-MM-DD>-T<n>-<slug>.md`; commit subject
  `docs(ticket): T-<n> <slug>`.
- The ticket carries no profile; a `**Story:**` line in the parsed form or a `**No story:**` line
  (spec §2.3 step 6, story AC-12).
- intake, harden-finding, sparring, `/workflow-init`, `CLAUDE.md`, `AGENTS.md` and
  `.claude/review-gates.md` are not changed (story AC-9; sprint-mode moratorium).
- dev-workflow 0.23.0 → 0.24.0 with a CHANGELOG entry (invariant 12); no manifest key (invariant 6).
- The skill passes all 12 items of `docs/prompt-standards.md` (invariant 11); `Target model:` once.
- Never `git add -A`; stage by name. No `Co-Authored-By` trailers.
- Replay: model `claude-opus-5-5`, `--plugin-dir` a `git archive` copy of `plugins/dev-workflow`,
  `--setting-sources project`, `--strict-mcp-config`, `--permission-mode bypassPermissions`,
  `--max-budget-usd 4`, a fresh fixture copy per run.

## Review Focus

Inputs the replay does not exercise. Each is checked by reading the finished skill text (Task 2,
step 3) and named in the Gate-B call:

- An input naming two categories, or none that can be grounded: one question, nothing written.
- `T-<n>` where two files carry that number: stop, name both paths; `list` shows them under
  `needs repair`.
- The computed ticket path already exists at write time: stop and name it, never overwrite.
- The index already holds staged changes at commit time: stop before staging.
- `T-<n> ready` on a `needs-info` ticket whose answers still leave a readiness field `unknown`:
  the re-capture keeps it `needs-info`; a commitment change makes it `wontfix` with the intake
  hand-off.

## Sources and impact boundary

Read: the story and spec; `plugins/dev-workflow/skills/intake/SKILL.md` (Flow steps 10–11, slug
rule, commit protocol, amendment route heading); `docs/prompt-standards.md`;
`.claude/review-gates.md` in full; `scripts/check-invariants.sh` check 4a; the precedent replay
packages `docs/superpowers/replays/2026-10-10-added-criterion-row/` (runner.md with run.sh and
checks.sh as text) and `2026-10-11-intake-split/fixture/`; `README.md` skill table,
`docs/ARCHITECTURE.md` line 45, `docs/PRD.md` feature map.
Impact boundary: one new skill, plugin manifest and CHANGELOG, three inventory rows, one new
replay package. Grep done 2026-10-12: the skill inventory is stated in `README.md` (table),
`docs/ARCHITECTURE.md:45` (tree) and `docs/PRD.md` (feature map); no "three skills" count exists;
`MANIFEST.md` line 10 describes the frozen extraction and stays. Check 4a scans the new file by its
`Target model:` line; no checker lists skills by name. Not read: the hook, other commands.

## Handover boundary

The completed story: PR squash-merged after CI and bots. A failed measurement without a reasoned
correction is also a boundary (spec §3: decision to Daniel). Never inside a running review cycle.
K9 is queued after this unit and is not started here.

---

### Task 1: Replay package, checks first (docs-only)

**Files:**
- Create under `docs/superpowers/replays/2026-10-11-ticket-skill/`: `README.md`, `prompts.md`,
  `runner.md` (run.sh as text), `checks.md` (checks.sh as text, plus the reading-check list),
  `fixture/` — copied from `2026-10-11-intake-split/fixture/` (`agents-md.md`, `review-gates.md`,
  the export story) plus `fixture/docs/superpowers/tickets/` with T-1…T-5.

**Outcome:** everything spec §3 says must exist before the first run is committed, and the commit
is docs-only.

**Decided already:** spec §3 — fixture tickets (T-1 `wontfix` 2026-10-02, T-2 `needs-info`
2026-10-03, T-3 `ready` 2026-10-04, T-4 `needs-info` 2026-10-03, T-5 `ready` 2026-10-01), each in
the spec §2.4 template; cases K1, K2, K3, L; run counts; check table; validity rule; acceptance.
Scripts live as fenced text inside `.md` files, as in the precedent, so the package stays prose
under `.claude/review-gates.md` "What counts as prose".

**Implementer's decision space:** prompt wording (none quotes an expected answer; K1 carries a
worker log line and a version, K2 a measured duration, K3 "CSV instead of XLSX" called a bug);
the fixture tickets' titles and bodies (export-job domain, unlike the skill's invoice examples);
the checks script's form.

- [ ] **Step 1:** Write the fixture and the five tickets. Verify: filenames sort to the dates the
  spec gives; T-4 shares T-2's date; T-5 is the oldest.
- [ ] **Step 2:** Write `prompts.md`, `runner.md` (precedent run.sh, variants `baseline` →
  0.23.0 copy at `6b15993`, `candidate` → copy at the measured commit) and `checks.md`: the
  mechanical rows of the spec §3 table scripted per run, the reading rows listed per case.
- [ ] **Step 3: Dry check of the checker.** Build a throwaway fixture copy in the scratchpad, write
  one hand-made T-6 ticket and commit it; run checks.sh: expected PASS on the K1/K2 rows. Break it
  (second category value; a T-3 edit; a second file in the commit): expected FAIL naming each row.
  Run it on the untouched copy for K3/L: expected PASS. Nothing from this dry check is kept.
- [ ] **Step 4:** Commit by name with `docs: K8 replay package — fixture, prompts, checks (before runs)`.
  Before committing confirm every staged path is `docs/**.md`, none named `AGENTS.md`/`CLAUDE.md`
  or under `.claude/`, `plugins/`, `skills/`, `commands/`; the README records this commit as the
  checks commit.
- [ ] **Step 5: Baseline runs.** 1 × K1, K2, K3 on the 0.23.0 copy via `/dev-workflow:intake`
  per spec §3 validity rule. Keep every run. Expected: no ticket file in any run.

### Task 2: The skill, version, inventory — through Gate B

**Files:**
- Create: `plugins/dev-workflow/skills/ticket/SKILL.md`
- Modify: `plugins/dev-workflow/.claude-plugin/plugin.json` (version), `plugins/dev-workflow/CHANGELOG.md`,
  `README.md` (one table row), `docs/ARCHITECTURE.md:45`, `docs/PRD.md` (one feature-map row)

**Outcome:** the skill carries spec §2.1–2.8 in the sections §2.1 lists; battery green; Gate B
closed.

**Decided already:** spec §2 entire, including the inline template (§2.4), the slug rule restated
in full, the severity meanings in one line, the hand-off texts, the `list` format and the stated
compaction limit (§2.1). Example domain: an invoice PDF service.

**Implementer's decision space:** wording and order inside each section within spec §2 and
prompt-standards; the Common mistakes list; CHANGELOG wording in the file's form.

- [ ] **Step 1:** Write the skill. Measure its size (`wc -c`); over 15,000 → note why it was not
  split, for the PR.
- [ ] **Step 2:** Run `sh scripts/check-invariants.sh`. Expected: PASS, 4a counting one
  `Target model:` line in the new file. Probe: a scratch copy with the line removed fails 4a.
- [ ] **Step 3: Reading checks.** The skill against all 12 prompt-standards items, and against each
  Review Focus line; note results for the PR. Fix before Gate B.
- [ ] **Step 4:** Bump to 0.24.0, CHANGELOG entry, the three inventory rows.
- [ ] **Step 5:** Battery (AGENTS.md § Commands, quality row). Expected: exit 0.
- [ ] **Step 6: Gate B.** `git commit -m 'WIP: ticket skill 0.24.0'` staging the six paths by
  name; `sh scripts/check-version-bump.sh main` (expected pass); Gate B per
  `.claude/review-gates.md` — fresh nonce, floor 3 per the story at level 1, cap 5, two sequential
  single-branch calls per pass, story path carried, evidence entry quoted, dispositions files,
  standing lens. Evidence entry: battery green and check 4a's probe; the behavioural claim is the
  named verification of Task 3, pending here, its counterfactual the Task 1 baseline. Close by
  `git commit --amend` with the real message, provenance line, curve, ledger check and evidence
  entry.

### Task 3: Candidate runs and results

**Files:**
- Create in the package: `evidence/` (per run: the ticket file or output, commit subject and
  body, the trace excerpts a check relied on — invalid and failed runs included), `compare.md`
  (per run, per check, verdict linked to evidence; baseline vs candidate); update `README.md`
  (measured commit, skill sha256, run counts).

**Outcome:** 3 × K1, 3 × K2, 3 × K3, 1 × L on the Task 2 closing commit, reported per spec §3.

- [ ] **Step 1:** Copy `plugins/dev-workflow` at the Task 2 closing commit; record its skill
  sha256. Confirm one run's init record lists exactly one `dev-workflow` at that copy, else stop.
- [ ] **Step 2:** Run the ten runs; re-run an invalid one once; a case still short is
  **incomplete** — report and stop.
- [ ] **Step 3:** checks.sh plus the reading checks on every valid run. Expected for adoption:
  every valid run passes every check of its case.
- [ ] **Step 4 (only on failure):** investigate and report in `compare.md`. A correction with a
  stated reason goes back through Task 2 (new Gate-B cycle) and a fresh full candidate set; the
  failed set stays. A second failing set, or a cap, stops and goes to Daniel.
- [ ] **Step 5:** Commit the results by name, with the docs-only path check of Task 1 step 4.

### Task 4: PR

- [ ] **Step 1:** Push, open the PR. Body: story, spec, plan, package paths; skill size; the
  prompt-standards result; run results per case; open obligations: the 20 owed hardenings of
  cycle ocgrixmmce (e4f3071) and any from this plan's cycles; the pass-3 Minors collected.
- [ ] **Step 2:** CI and bots per `docs/pr-review-bots.md`; `/dev-workflow:process-pr-review`.
- [ ] **Step 3: Measured-revision gate.** The PR head's skill sha256 must equal the README's. A
  later skill change needs its own Gate-B cycle and a fresh full candidate set, or goes to Daniel.
- [ ] **Step 4:** Merge word from the orchestrator. Squash body carries every record of the
  branch: Gate-A spec and plan cycles' provenance, curves, ledger and owed lines; every Gate-B
  record; the evidence entry.
- [ ] **Step 5:** Update the handover and stop.
