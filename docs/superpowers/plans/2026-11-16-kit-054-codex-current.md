# Kit 0.54: the risk pass runs on the current Codex CLI — Plan

**Spec:** `docs/superpowers/specs/2026-11-16-kit-054-codex-current-design.md` · **Story:**
`docs/superpowers/stories/2026-11-16-kit-054-codex-current-story.md` (level 2) · **Gate A:** runs (risk high)

Execution: in this session, task by task, without implementer subagents, a WIP commit after each task
(`git add <paths>`, then `git commit -m 'WIP: …'` as its own Bash call). Recorded as a deviation from CLAUDE.md's
subagent-driven default: the four tasks edit overlapping regions of one command file and the session already
holds the script; Gate B and the risk pass are the independent review. Every full battery run goes through
`sh scripts/local-ci.sh <head>` on a pushed head (the workflow is disabled: `ci-switch.sh` says `local`).

## Tasks

### T1 — `risk-pass.sh`: version rule and two run-time checks (spec §3; AC-1, AC-2, AC-3)
- Outcome: `.agents/skills/gate-b-review/scripts/risk-pass.sh` accepts `codex-cli <a>.<b>.<c>` at or above
  0.162.1, refuses older and unreadable lines with exit 6 and two different messages, fails an attempt whose
  event log yields no agent message or an empty last one, and fails one whose scratch directory does not hold
  exactly `events`, `prompt` and `stderr` (an entry missing, or any further entry, hidden ones included). Header
  and comments per spec §3.3, including the "what a later Codex could break" list.
- Order: suite first, in two red runs against the unchanged script. Red run 1, stub version still `0.162.1`:
  the run-time-check cases (no agent message, empty last message, added entry, hidden entry, removed `prompt`)
  reach Codex and wrongly exit 0. Red run 2: the stub's default becomes `0.169.0` and the version cases are
  added; the acceptance cases fail with exit 6, the refusal cases fail on the missing message wording. Note
  both results, then change the script.
- Reuse: `die`, `finish`, `wid`, `sread`, `create`, `place` as they are. The version line is read where it is
  read today (before the lock). The entries listing is taken right after the identity check and its failure
  reported after the timeout and exit-status checks, before the reply check (spec §3.2).
- Test situations (stub `codex` gains a switch file for "no agent message"; the stub's default version becomes
  `codex-cli 0.169.0`):
  - `0.169.0`, valid result → exit 0, evidence first line `CLI: codex-cli 0.169.0`.
  - `0.162.1`, `0.1000.0`, `1.0.0` → exit 0.
  - `0.162.0`, `0.99.9` → exit 6, stderr says older and names the line, no `risk` line in the state file, no
    lock directory left.
  - `0.170.0-alpha.1`, `codex 0.169.0`, `codex-cli 0.169`, `codex-cli 0.169.0.1`, an empty version line,
    `codex-cli 0.1234567.0`, `codex-cli 0.169.0 ` (trailing space), no `codex` on `PATH` → exit 6, stderr says
    cannot read, nothing written.
  - Codex exits 0, valid findings and evidence, no `agent_message` event → exit 1, `risk 1 failed 1 1`, no
    canonical file, stderr names the event log.
  - the same with a non-empty agent message followed by a last one whose `text` is empty → the same outcome.
  - the stub's `before` hook adds a file in the scratch directory, valid result → exit 1, `failed` line, no
    canonical file; the same for a hidden file (`.x`) and for a removed `prompt`.
  - existing case "the scratch directory replaced by a link" → additionally: the evidence file left beside the
    attempt exists, holds the stub's `TESTS:` and `CALLERS:` lines, and does not start with `CLI:`.
  - every existing case stays green; "another Codex CLI version: exit 6" is replaced by the rows above.
- Verify: `RISK_PASS_SH=sh sh scripts/gate-b-risk-pass.test.sh`, the same under `dash`, `shellcheck --shell=sh`
  on the script and `--exclude=SC2015` on the suite, all exit 0.
- Decision space: awk or `case` for parsing and comparing; message wording within spec §3.1; stub switch names.

### T2 — The route when the risk pass does not finish (spec §4; AC-4)
- Outcome: `.agents/skills/gate-b-review/SKILL.md` § Risk pass has one new bullet after *Run* with the route by
  exit status (0; 2; 4 split by message; 1, 3 and signals; 5 and 6; the four "always" rules), each rule with its
  reason, and line 8 reads "via the Codex CLI (0.162.1 or later)". `.claude/review-gates.md`'s Risk pass line
  carries the one changed clause of spec §4.
- Prerequisite: T1's messages exist, since the bullet quotes `held by a live attempt` and names exit 6's two
  cases.
- Test situations: `wc -c .claude/review-gates.md` ≤ 10000; the old clause's conditions all still readable in
  the line (spec §4's list); for the exit route in particular, prompt-standards items 3, 6, 9, 10 (stop
  conditions, reasons, positive wording where one exists, causes named per state).
- Prompt review (invariant 11), once after T3, for every changed prompt artifact — the skill (line 8, the route
  bullet), the gate rules clause, `workflow-init.md`'s `### 2.24` and `### 2.26` intros and closing checklist
  item, and `AGENTS.md`'s changed sentences: `docs/prompt-standards.md` read in full, each of its 12 items marked
  met or not applicable per artifact with one line of reason, the table carried in the PR body. Item 1: the
  target of each text is named (Claude via Claude Code for all but the skill's Codex-facing sections, which do
  not change), and the Claude prompting page current on 2026-11-16 is read once for what the new text relies on;
  when it cannot be fetched, the PR body says so and the standards' dated notes are the source.
- Decision space: wording; whether the route is one bullet with sub-items or a short list.

### T3 — Templates and texts (spec §5; AC-5)
- Outcome: `plugins/dev-workflow/commands/workflow-init.md` templates `### 2.1a`, `### 2.24`, `### 2.26` are
  byte-identical to T2's and T1's files; the `### 2.24` and `### 2.26` intros and the closing checklist item read
  as spec §5 (older → updating is the user's step; unreadable → the line seen and `command -v codex`; no install
  command). `README.md`, `AGENTS.md` (§ Commands prerequisites; invariant 5's fifth exception, "Five bounded
  exceptions"), `docs/reference.md` (exit 6, **Codex CLI version** paragraph with the unchecked list and the
  route, the discovery sentence) updated.
- Prerequisite: T1 and T2 final, so the copies are made once.
- Before editing `AGENTS.md`: the two repository-wide greps its Don'ts prescribe, with their stated exclusions
  (`declare[sd]?|convention[- ]load`; the totality-words recipe), run in full; the hits that touch the Codex CLI,
  `risk-pass.sh`, exit 6 or invariant 5's exceptions are read against the manifest and the script, and only
  claims this change makes false are edited. No section or anchor is renamed.
- Test situations: `sh scripts/check-invariants.sh` exit 0 (4g, 4i, 4j, 4o among them); `sh
  scripts/check-doc-links.sh source-files/ docs/history/ docs/superpowers/replays/` exit 0; `grep -rn '0\.162\.1'
  --include='*.sh' --include='*.md' .` outside `source-files/`, `.context/`, `docs/superpowers/` and `todos.md`
  returns only the minimum, observations ("seen on 0.162.1 and 0.169.0"), and CHANGELOG/reference history; `grep
  -rn 'npm install -g @openai/codex'` outside the same paths returns nothing.
- Decision space: prose wording.

### T4 — Release (spec §6; AC-6)
- Outcome: `plugins/dev-workflow/.claude-plugin/plugin.json`, the `### 2.23` template and
  `.claude/dev-workflow-version` read 0.54.0; `plugins/dev-workflow/CHANGELOG.md` has § 0.54.0 above § 0.53.0
  (what changed, why Minor, the 0.169.0 observations in one paragraph, what stays unchecked).
- Test situations: `sh scripts/check-invariants.sh` (4n) and `sh scripts/check-version-bump.sh origin/main` after
  `git fetch origin` and the WIP commit, exit 0; `claude plugin validate . --strict` exit 0.

## Long runs (≥ 15 min, each needs the orchestrator's go)

One line to `dev-workflow-kit-73` before each, then wait for "go" (order's rule).

| Run | Proves | Estimate | Expected runs | Limits and cleanup |
|---|---|---|---|---|
| `sh scripts/local-ci.sh <head>` (full lane) | the quality row on the pushed head; posts `quality` | 35 min | 2 (the built head; the head after Gate B's repairs) | the script's own: one temporary worktree removed on any exit, the heavy lock released; it stops at the first failing command, so before it runs each suite this change touches is run alone (T1–T4 verify lines) |
| `sh .agents/skills/gate-b-review/scripts/risk-pass.sh <repo> <base> <head> <nonce> <n>` | the named verification: the changed script on Codex 0.169.0 (spec §7) | 20 min (limit 2400 s) | 1; a retry per spec §4 | its watchdog and EXIT trap stop Codex's process group and remove the scratch directory and the lock |

Which lane a head takes is `local-ci.sh`'s header contract, not this plan's wish: a head inherits
(`--from <green>`, seconds) only when its tree equals the green one (the squash-merge of an unchanged head) or
when every path changed since is under `.context/` or is `todos.md` (the closing commit, if it carries nothing
else); the light lane takes a change of Markdown outside instruction paths; **every repair that touches a
script, a suite, `AGENTS.md`, `.claude/`, `.agents/` or `plugins/` takes the full lane again**, and so does a
merge that carries upstream changes. Expected: one full run on the built head and one after Gate B's repairs,
plus one risk pass: 35 × 2 + 20 = 90 minutes, under the 2-hour unit limit. A third full run or a risk-pass
rerun would pass that limit inside the running Gate B cycle; the boundary then moves to that cycle's close, as
CLAUDE.md §4 says, and the handover records it. No single run is expected to take 45 minutes or more.

## Handover boundary

The completed story: PR merged, plugin updated, status line sent. Handover in
`.context/handover-kit-054.md` (the next unit, if any, continues in this checkout), with the `Deviations` list.

## Actions outside the repository

None needs Daniel. By this session, as the order says: push the branch; open the PR; `local-ci.sh` posts the
`quality` status; `/dev-workflow:process-pr-review`; squash-merge with an own body and no attribution lines; then
`claude plugin marketplace update dev-workflow-kit` and `claude plugin update dev-workflow@dev-workflow-kit`
(they write under the home directory); one line to `dev-workflow-kit-73`. The worktree stays.

## Before the PR

Gate B (strict: floor 1, cap 5) on the cycle diff from the plan's closing commit (the cycle base), state file
`.context/codex-reviews/gate-b-cycle-<nonce>.state` written before pass 1; the risk pass is due (script, gate
rules, skill). PR body: profile line, the 0.169.0 observations (spec §2), the risk pass's exit status, `CLI:`
line and `done` line, `run id: none` with the local run's SHA, exit status and duration, Deviations.

## Sources and impact boundary

Read: the order, the story and spec, `CLAUDE.md`, `AGENTS.md`, `.claude/review-gates.md`, `risk-pass.sh` and its
suite in full, `SKILL.md` § Risk pass, the `workflow-init.md`, `README.md` and `docs/reference.md` sites the grep
of spec §5 lists, `scripts/local-ci.sh`'s header (lanes and preconditions), `docs/prompt-standards.md`'s
checklist headings (read in full at the prompt review), the 0.52 plan for form. **Library:** Codex CLI
0.169.0; Context7 `/openai/codex` is indexed up to `rust-v0.165.0`, not for 0.169.0, so the CLI's own `--help`
output and the runs of spec §2 are the source. Impact: initialized projects receive the script, skill and gate
rules at their next `/workflow-init` refresh (five kit-053 refresh sessions wait for it). Not touched and not
read further: `run-tests.sh`, the hook, `ci.yml`, `local-ci.sh`'s body, the reports, `evals/`.
