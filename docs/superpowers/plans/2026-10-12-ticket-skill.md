# A `ticket` skill for bugs and improvements — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Story:** `docs/superpowers/stories/2026-10-11-a-ticket-skill-for-bugs-and-improvements-story.md` — read its profile fresh at each pass.

**Goal:** the plugin ships `/dev-workflow:ticket` as one skill file, and a replay of K1–K3 plus `list`
shows the skill followed, against an intake-only baseline.

**Architecture:** one new prompt file, a minor version bump with its CHANGELOG entry and three
inventory rows, and a docs-only replay package whose checks are committed before any run. The
baseline runs need no skill and run first. The candidate runs measure the skill at the Gate-B
`WIP:` snapshot, before the first Gate-B call, because `battery+check` evidence is produced before
Gate B is called (`.claude/review-gates.md`, "Two evidence gaps"): the replay is the check.

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
- The skill passes all 12 items of `docs/prompt-standards.md` (invariant 11); `Target model:` once,
  beside the sentence "This skill is a prompt artifact and follows the checklist in
  `docs/prompt-standards.md`." — check 4a selects files by the phrase `prompt artifact and follows`,
  so without it the skill is outside 4a.
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
`MANIFEST.md` line 10 describes the frozen extraction and stays. Check 4a scans only `.md` files
containing `prompt artifact and follows` (`scripts/check-invariants.sh` 4a); no checker lists skills
by name. Not read: the hook, other commands.

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
- [ ] **Step 1a: Assemble `fixture-template/`** in the scratchpad, outside any git checkout, as the
  precedent README's "Re-running" does: `agents-md.md` restored to `AGENTS.md`, `review-gates.md`
  moved to `.claude/`, the story and five tickets in place; `git init -b main`; one commit. The
  README records the assembly steps and that commit as the fixture base the checks compare
  against. Preflight: `AGENTS.md`, `.claude/review-gates.md`, the story and T-1…T-5 tracked, one
  commit, clean index and worktree. Any mismatch stops before a run.
- [ ] **Step 2:** Write `prompts.md`, `runner.md` (precedent run.sh, variants `baseline` →
  0.23.0 copy at `6b15993`, `candidate` → copy at the measured commit) and `checks.md`: the
  mechanical rows of the spec §3 table scripted per run, the reading rows listed per case.
- [ ] **Step 3: Dry check of the checker.** Build a throwaway fixture copy in the scratchpad, write
  one hand-made T-6 ticket and commit it; run checks.sh: expected PASS on the K1/K2 rows. Break it
  (second category value; a T-3 edit; a second file in the commit): expected FAIL naming each row.
  Run it on the untouched copy for K3/L: expected PASS; then on three copies with an untracked new
  ticket, an unstaged edit to T-2, and a new commit: expected FAIL on the K3/L row each time.
  Nothing from this dry check is kept.
- [ ] **Step 4:** Commit by name with `docs: K8 replay package — fixture, prompts, checks (before runs)`.
  Before committing confirm every staged path is `docs/**.md`, none named `AGENTS.md`/`CLAUDE.md`
  or under `.claude/`, `plugins/`, `skills/`, `commands/`; the README records this commit as the
  checks commit.
- [ ] **Step 5: Baseline runs.** 1 × K1, K2, K3 on the 0.23.0 copy via `/dev-workflow:intake`
  per spec §3 validity rule. Keep every run. Expected: no new ticket file in any run and T-1…T-5
  unchanged against the fixture base. The per-run evidence goes into the package with Task 3.

### Task 2: The skill, version, inventory — to the WIP snapshot

**Files:**
- Create: `plugins/dev-workflow/skills/ticket/SKILL.md`
- Modify: `plugins/dev-workflow/.claude-plugin/plugin.json` (version), `plugins/dev-workflow/CHANGELOG.md`,
  `README.md` (one table row), `docs/ARCHITECTURE.md:45`, `docs/PRD.md` (one feature-map row)

**Outcome:** the skill carries spec §2.1–2.8 in the sections §2.1 lists; battery green; a `WIP:`
commit ready for measurement.

**Decided already:** spec §2 entire, including the inline template (§2.4), the slug rule restated
in full, the severity meanings in one line, the hand-off texts, the `list` format and the stated
compaction limit (§2.1). Example domain: an invoice PDF service.

**Implementer's decision space:** wording and order inside each section within spec §2 and
prompt-standards; the Common mistakes list; CHANGELOG wording in the file's form.

- [ ] **Step 1:** Write the skill. Measure its size in characters (`LC_ALL=en_US.UTF-8 wc -m`);
  over 15,000 → note why it was not split, for the PR.
- [ ] **Step 2:** Run `sh scripts/check-invariants.sh`. Expected: PASS. Probe in a scratch clone
  of the worktree: `grep -rl 'prompt artifact and follows'` lists the new skill, and with its
  `Target model:` line removed 4a fails naming that file.
- [ ] **Step 3: Reading checks.** The skill against all 12 prompt-standards items, and against each
  Review Focus line; note results for the PR. Fix before Gate B.
- [ ] **Step 4:** Bump to 0.24.0, CHANGELOG entry, the three inventory rows.
- [ ] **Step 5:** Battery (AGENTS.md § Commands, quality row). Expected: exit 0.
- [ ] **Step 6:** `git commit -m 'WIP: ticket skill 0.24.0'` staging the six paths by name;
  `sh scripts/check-version-bump.sh main`. Expected: pass.

### Task 3: Candidate runs (the check), then Gate B

**Files:**
- Create in the package: `evidence/` (per run: the ticket file or output, commit subject and
  body, the trace excerpts a check relied on — invalid and failed runs included), `compare.md`
  (per run, per check, verdict linked to evidence; baseline vs candidate); update `README.md`
  (measured commit, skill sha256, run counts).

**Outcome:** 3 × K1, 3 × K2, 3 × K3, 1 × L on the `WIP:` snapshot, reported per spec §3; then Gate
B closed with that result as its evidence.

- [ ] **Step 1:** Copy `plugins/dev-workflow` at the `WIP:` commit (`git archive`); record its
  skill sha256. Confirm one run's init record lists exactly one `dev-workflow` at that copy, else
  stop. Durable source: the WIP commit is replaced at close, so the package keeps each measured
  set's skill text verbatim as `evidence/set<k>-skill.md` with its sha256; the measured plugin is
  `6b15993`'s `plugins/dev-workflow` plus that file and the 0.24.0 manifest, and the README says so.
- [ ] **Step 2:** Run the ten runs; re-run an invalid one once. A case still short is
  **incomplete**: fold the runs held so far, their validity causes, the quotas and the verdict
  "incomplete" into the package as step 5 does, link them from the handover, and stop.
- [ ] **Step 3:** checks.sh plus the reading checks on every valid run. Expected for adoption:
  every valid run passes every check of its case.
- [ ] **Step 4 (only on failure):** investigate and report in `compare.md`. A correction with a
  stated reason is made in place: stage the changed skill by name, `git commit --amend --no-edit`,
  so one `WIP:` commit stays the tip on the same parent and Gate B's `baseSha` (that parent) keeps
  covering the whole implementation; then battery and a fresh full candidate set on the amended
  snapshot. The failed set and its skill text stay in the package. A second failing set, or a cap,
  stops and goes to Daniel.
- [ ] **Step 5:** Fold the results into the `WIP:` commit: stage the package files by name, then
  `git commit --amend --no-edit`, so the snapshot stays the tip and Gate B reviews skill and
  evidence together. No separate commit: a non-`WIP` commit here would reset the hook's Gate-B
  state.
- [ ] **Step 6: Gate B** per `.claude/review-gates.md` — fresh nonce, floor 3 per the story at
  level 1, cap 5, two sequential single-branch calls per pass on the `WIP:` commit, story path
  carried, evidence entry quoted, dispositions files, standing lens, the Review Focus lines named.
  Evidence entry: the battery green; check 4a's probe; the named verification — the replay result
  per case on the measured skill sha256, with its counterfactual the Task 1 baseline (no ticket
  file produced on 0.23.0). **A Gate-B repair that changes `SKILL.md`** makes the entry stale: run
  a fresh complete candidate set on the repaired text, fold it into the package, revalidate the
  entry, then re-review; the earlier set stays. Close by `git commit --amend` with the real
  message, provenance line, curve, ledger check and evidence entry.

### Task 4: PR

- [ ] **Step 1:** Push, open the PR. Body: story, spec, plan, package paths; skill size; the
  prompt-standards result; run results per case; open obligations: the 20 owed hardenings of
  cycle ocgrixmmce (e4f3071) and any from this plan's cycles; the pass-3 Minors collected.
- [ ] **Step 2:** CI and bots per `docs/pr-review-bots.md`; `/dev-workflow:process-pr-review`.
- [ ] **Step 3: Measured-revision gate.** The PR head's skill sha256 must equal the README's
  latest measured set. A
  later skill change needs its own Gate-B cycle and a fresh full candidate set, or goes to Daniel.
- [ ] **Step 4:** Merge word from the orchestrator. Squash body carries every record of the
  branch: Gate-A spec and plan cycles' provenance, curves, ledger and owed lines; every Gate-B
  record; the evidence entry.
- [ ] **Step 5:** Update the handover and stop.
