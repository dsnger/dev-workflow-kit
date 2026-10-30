# Kit 0.51 a stronger Codex review — Plan

**Spec:** `docs/superpowers/specs/2026-10-30-kit-051-codex-review-design.md` (Gate A closed, `a7ea646`).
**Story:** `docs/superpowers/stories/2026-10-30-kit-051-codex-review-story.md` (risk standard → this plan takes no
Gate A; AC-3 narrowed 2026-10-30). Execution: this session, task by task; no subagent writes.

## Global constraints
- POSIX `sh`, `shellcheck --shell=sh` clean; suites run under `sh` and `dash`, no terminal (stdin `</dev/null`).
- Every value into a command is a quoted argument; SHAs `^[0-9a-f]{40}$`; nonce `^[a-z0-9]{8,16}$`.
- Codex CLI pin `codex-cli 0.162.1` (exact string `codex --version` prints); `mcp-codex-dev@1.0.1` unchanged.
- `.claude/review-gates.md` and its `### 2.1a` copy ≤ 10,000 bytes and byte-identical (checks 4i, 4j).
- Never `git worktree add`; nothing written under `$HOME` by an agent.
- Version 0.51.0 in the manifest, `### 2.23`, `.claude/dev-workflow-version`.

## Review focus
1. Repository path or `TMPDIR` with a space → scripts still work (suite case with a spaced temp dir).
2. `<headSha>` valid hex but not in the repository → `run-tests.sh` exits 2 before anything runs, copy removed.
3. A test that reads stdin → gets EOF, does not hang (stdin `</dev/null`; suite case).
4. Two `run-tests.sh` runs at once → the stale scan leaves the other's live copy (runner alive → never touched).
5. A test printing megabytes → stderr keeps the last 200 lines, the report line stays one line.

## Tasks

**T1 — `run-tests.sh` (spec §5; AC-3).**
- Files: `.agents/skills/gate-b-review/scripts/run-tests.sh`, suite `scripts/gate-b-run-tests.test.sh`.
- Interface: `run-tests.sh <repo> <headSha> <seconds> -- <command…>`; stdout one line
  `<command> | exit <n|timeout> | <s>s`; exits: the command's status, 2 bad arguments, 4 checkout changed,
  5 no supervisor. Copy dir `${TMPDIR:-/tmp}/gate-b-review.XXXXXX` holding `runner.pid`, `group.pid`.
- Reuse: `local-ci.sh`'s `mktemp -d` + trap cleanup pattern; perl `setpgrp` exec as in kit-050's scratch runner.
- Tests: every suite case of spec §5 plus review focus 1–5; the KILL-of-runner case starts the runner in the
  background, kills it with `KILL`, asserts the next run reports and keeps the copy, then removes it once the
  surviving child is killed; the no-perl case runs with a `PATH` lacking perl.
- Decision space: helper names, fingerprint hashing (`git hash-object --stdin` over the concatenated parts).

**T2 — `risk-pass.sh` (spec §6 Run; AC-5).**
- Files: `.agents/skills/gate-b-review/scripts/risk-pass.sh`, suite `scripts/gate-b-risk-pass.test.sh`.
- Interface: `risk-pass.sh <repo> <baseSha> <headSha> <nonce> <n> [<seconds>]`; exits 0/1/2/3/4/5/6 per spec;
  state file `.context/codex-reviews/gate-b-cycle-<nonce>.state` lines `base`, `risk <n> start|done|failed …`;
  attempt files `…-pass-<n>-attempt-<a>.{md,evidence.md,reply.md,events.jsonl}`; canonical `…-pass-<n>.md`.
- Consumes T1's supervisor and watchdog shape (copied, no shared library: each script ships alone).
- Tests: `codex` stubbed by a script on `PATH` that prints a version and writes a chosen findings file; every
  case of spec §6's suite list, plus: missing state file → exit 2 with "no cycle base"; grammar edge cases
  (`NO FINDINGS` with `(0 total)` valid; `NO FINDINGS` plus a finding invalid; NIT valid; count mismatch invalid).
- Decision space: prompt wording inside the script (states branch `risk`, range, findings path, skill path).

**T3 — `SKILL.md` (spec §4; AC-1, AC-3, AC-4).**
- File: `.agents/skills/gate-b-review/SKILL.md` with `name`/`description` front matter (F1 format) and the five
  numbered parts of spec §4; passes `docs/prompt-standards.md` (invariant 11), incl. its `Target model:` line.
- Check: a scratch `codex exec` in this repo lists `gate-b-review` among its skills (F1 evidence, recorded in the
  PR body); not a long run.

**T4 — scaffolding and checks (spec §7; AC-1, AC-2).**
- `workflow-init.md`: `### 2.24 SKILL.md`, `### 2.25 run-tests.sh`, `### 2.26 risk-pass.sh` — one fence each, so
  `fence_body` is reused unchanged (Deviation from spec §7's "2.24 with three fences", recorded in the handover);
  each under rule 9. `### 2.8`: merge `"CODEX_DEV_SANDBOX_MODE": "workspace-write"` into the codex `env`, the
  next-session note, the `tools.review.sandbox` note. Step 4 closing checklist: the Codex CLI 0.162.1 human step.
- `scripts/check-invariants.sh`: check **4o**, three `cmp`s like 4m; header lists updated; suite cases in
  `check-invariants.test.sh` (identical accepted; each of three differing rejected; missing fence rejected).
- This repository: `.mcp.json` gets the env key; the three files present (they are T1–T3's files).

**T5 — gate rules and docs (spec §6–§7, §9; AC-5, AC-7).**
- `.claude/review-gates.md` + `### 2.1a`: Gate-B prompt names the skill; risk pass short form (trigger
  categories, when, cap counting, follow-up, cycle line `risk pass <n>: <count>`, cycle-base state file) within
  10,000 bytes; for every line tightened, an old-conditions table in the PR body (kept/moved/dropped).
- `docs/reference.md` long form incl. the trust model's uncovered axes and the checkout fingerprint's exclusions;
  `docs/ARCHITECTURE.md` tree + scripts inventory; `AGENTS.md` § Commands (shellcheck of both scripts, both suites
  under `sh` and `dash` in quality and lint rows, run once here before writing them) and Boundaries 4c;
  README; CHANGELOG 0.51.0; version in the three places.
- Commit: `WIP: kit 0.51 codex review build` (one WIP commit for T1–T5 is fine).

**T6 — bounded local quality (unit 1 end).** Scratch runner as in kit-050 (stages split on ` && `, 15-minute
limit each, all failures collected); fix and rerun, at most 5 rounds. Then the closing commit of unit 1 and the
handover.

**T7 — proof replay (unit 2; spec §8; AC-6).** Driver and report under
`docs/superpowers/replays/2026-10-30-kit-051/` (`replay.sh`, `answer-key.md` written and committed before any
run, `report.md`). Cases #97 #49 #41 #56 #43 #40 #99 #95 at the heads and bases recorded in the answer key; two
cases at a time. Report: found/not found per case with the quoted line, contamination verdicts, calls and wall
time per case, model and CLI version, totals, comparison note for sfx-factory. Below 4/6 → stop for Daniel.

**T8 — Gate B, PR, merge (unit 3).** Fresh session so the sandbox env key is live. Gate B `strict` with the
risk pass (this change triggers categories a and c); `sh scripts/local-ci.sh <final head>`; PR with proof
numbers, F1 evidence, old-conditions table, Ponytail pre-review if installed; `/dev-workflow:process-pr-review`;
squash-merge; handover with design choices and proof numbers (D84 comparison).

## Long runs
| Run | Proves | Estimate | Expected runs |
|---|---|---|---|
| T6 bounded quality (scratch runner) | battery green on the WIP head | ~40 min | 1–2 |
| T7 proof replay | AC-6 found/not found | ~3 h (8 cases × ~3 calls × ~10 min, two in parallel ≈ 2 h wall) | 1 (+ reruns of contaminated cases) |
| T8 Gate B with risk pass | the gate | ~1 h | 1 |
| T8 `sh scripts/local-ci.sh <final head>` | posted `quality` status | ~40 min | 1 |
Each replay call runs under `risk-pass.sh`'s or the driver's watchdog (20-minute limit per call, process group
killed on timeout or exit, every case run even after a failed one, all failures in the report). The final-head
`local-ci.sh` run is the product runner as approved (kit-050 exception). The go for each comes from
dev-workflow-kit-26 (Daniel, 2026-10-30).

## Handover boundaries
Unit 1: T1–T6, `.context/handover-kit-051-build.md`. Unit 2: T7 alone (over 2 h), `.context/handover-kit-051-proof.md`.
Unit 3: T8, `.context/handover-kit-051.md`. Same checkout for all three.

## Sources and impact boundary
Read: the spec and story; `.claude/review-gates.md`; `workflow-init.md` 2.1a, 2.8, 2.21–2.23, Step 4;
`scripts/check-invariants.sh` 4l–4n and its suite; `scripts/local-ci.sh` (trap, mktemp); kit-050 plan (runner).
Library: Codex CLI 0.162.1 — Context7 `/openai/codex` indexes rust-v0.155.1 at the nearest, so the version's own
material is used: `codex exec --help` (installed 0.162.1) for `-s`, `-c`, `-C`, `-o`, `--json`;
`codex-rs/core/config.schema.json` at `rust-v0.162.1` (`7a078f6`) for `model_reasoning_effort` and
`sandbox_workspace_write.network_access`. `mcp-codex-dev@1.0.1` dist files as cited in spec F2. perl `setpgrp`:
`perldoc -f setpgrp` of the system perl.
Out: the hook, ci.yml, sfx-factory (D84), Semgrep (kit 0.52).

## Actions outside the repository
None needing the human now: Codex CLI 0.162.1 is already installed here (`codex --version`, 2026-10-30). The
fresh sessions for units 2 and 3 are started by the orchestrator. Long runs: go from dev-workflow-kit-26.
