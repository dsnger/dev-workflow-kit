# Kit 0.51: a stronger Codex review — Design

**Story:** `docs/superpowers/stories/2026-10-30-kit-051-codex-review-story.md` (risk standard, security standard,
battery+check, checkpoints none; AC-3 narrowed 2026-10-30). **Date:** 2026-10-30. **Plugin version:** 0.51.0.
**Gate A:** runs — risk standard; security standard; evidence battery+check (`strict`: security not `none`).

## 1. Intent
Gate B keeps its MCP tools, its hook-counted floor, its caps and its findings format. What changes is what Codex
brings to a pass: a kit-owned review method (a Codex skill in the project), targeted tests in a disposable copy,
an obligation to trace callers and dependents, and one high-effort risk pass for risky changes. Nothing is copied
from sfx-factory (D84).

## 2. Verified facts this design rests on
Observed on this machine on 2026-10-30 (Codex CLI 0.162.1, `mcp-codex-dev@1.0.1`).
- **F1 Skill discovery.** Codex CLI 0.162.1 run in a git repository lists skills from the repository's
  `.agents/skills/<name>/SKILL.md` and `.codex/skills/<name>/SKILL.md` as well as `$CODEX_HOME/skills` (probe:
  two throwaway skills in a scratch repo were listed by name without a tool call). Context7 `/openai/codex`
  indexes rust-v0.155.1 at the nearest, not 0.162.1, so the version's own material is used (the Context7
  fallback): `codex exec --help` of the installed 0.162.1 for the flags, and `codex-rs/core/config.schema.json`
  at tag `rust-v0.162.1` (commit `7a078f6`) for the configuration keys.
- **F2 How Gate B reaches Codex.** The server runs `codex exec - --json --sandbox <mode> -c
  approval_policy=on-request` with the call's `workingDirectory` as cwd and the server process's environment; the
  prompt is its `code-reviewer.md` / `spec-reviewer.md` template with `additionalContext` appended
  (`dist/tools/codex-review.js`). The sandbox defaults to `danger-full-access`; `CODEX_DEV_SANDBOX_MODE` in the
  server's environment sets it for both tools, and a `tools.<name>.sandbox` in a server config file overrides
  that (`dist/config/config.js`). Config is cached per project root for the server's lifetime, so a change takes
  effect at the next server start. A resumed call (`sessionId`) runs with
  `--dangerously-bypass-approvals-and-sandbox` (`dist/services/codex-executor.js`). No tool takes an effort.
- **F3 Offline.** Under `codex exec -s workspace-write`, `curl https://example.com` failed with "Could not resolve
  host"; writes are allowed in the workdir, `/tmp` and `$TMPDIR`. The schema (F1) defines
  `sandbox_workspace_write.network_access`, default `false`, so network in that mode follows the user's Codex
  config; Codex states the effective sandbox mode and network access to the model in its permissions
  instructions.
- **F4 Effort and output.** The schema (F1) defines `model_reasoning_effort` as a string the model advertises;
  `codex exec -c model_reasoning_effort="high"` ran at high effort (banner). `-o <file>` writes the last message
  to a file.
- **F5 Process groups.** Non-interactive `dash` ignores `set -m`: the child stays in the shell's process group
  (probe). `perl -e 'setpgrp(0,0); exec @ARGV'` starts the command as the leader of a new group under any shell;
  `/usr/bin/perl` is present on macOS, and macOS has no `setsid` command.

## 3. Trust model
The reviewer runs the project's own tests, which the quality command already runs on the same machine with the
developer's full rights, environment and network. The review adds no new trust in the code under test. Its
isolation goals (story AC-3 as narrowed): no secret from the environment reaches a test; the copy holds only the
repository's tracked files at the reviewed head (no `.env`, no untracked or ignored file); no network; a bounded
run; the copy removed afterwards; and a write to the reviewed checkout detected and failed (§5), not prevented.
**Not covered, stated in `docs/reference.md`:** a test can read any host file by absolute path, as the quality
command can, and a secret committed to the repository's tracked files is in the copy. These two are the axes
checked against; the list is not exhaustive.

## 4. The review skill (AC-1, AC-3, AC-4)
The skill is a directory in the project, `.agents/skills/gate-b-review/`, with `SKILL.md`, `scripts/run-tests.sh`
and `scripts/risk-pass.sh`; it travels with the repository and its kit version, and nothing is written under the
user's home (AC-2). `/workflow-init` scaffolds the three files (§7). Gate B's `additionalContext` names
`.agents/skills/gate-b-review/SKILL.md` and tells Codex to follow it, so a Codex version that does not discover
repository skills still reads it.

`SKILL.md` tells the reviewer, in order:
1. **Inputs.** The range `baseSha..headSha`, the branch (`spec`, `quality` or `risk`), the cited story and spec,
   the project's `AGENTS.md`, the battery evidence the call names, and the findings-file path.
2. **What to check.** `spec`: every acceptance criterion of the cited story mapped to the code and the test
   asserting it, or `none`. `quality`: the `AGENTS.md` invariants the diff touches; failure, error, empty and
   concurrent paths of every changed function or rule; statements elsewhere the diff makes false. `risk`: only
   edge cases and failure paths, deeper (§6).
3. **Callers and dependents.** For every changed symbol (function, variable, file path, heading or anchor, config
   key, template section), find its users in the head tree (`git grep -n -e <symbol> <headSha>`) and read each
   one that depends on the changed behaviour. codebase-memory: when the project has the integration and the
   reviewer can establish that the index matches `headSha`, it uses the index; when it cannot, it uses direct
   search and names the refresh command recorded in `todos.md` § Tooling revalidation, or says none is recorded;
   without the integration it says nothing about it. The reviewer never indexes (D79).
4. **Targeted tests.** Optional, chosen by the reviewer: the test commands `AGENTS.md` § Commands names for the
   touched paths, or a test file named for a touched file — never the whole battery. The reviewer runs them only
   when its permissions instructions say the sandbox is `workspace-write` with network access restricted;
   otherwise every test is reported as not run with that reason (this covers a resumed call, F2, a server started
   before the setting, and a user config that enables network). It runs them only through
   `scripts/run-tests.sh` (§5), and an exit of 4 (checkout changed) is a Blocker finding.
5. **Output.** The reviewer writes the findings file itself in the format of `.claude/review-gates.md`
   (unchanged), and beside it `…-pass-<n>-evidence.md` with one `TESTS:` line per command
   (`<command> | exit <n> | <seconds>s`) or `TESTS: none — <reason>`, and one `CALLERS:` line per changed symbol
   with the users checked. The reply is one line, as today, and names the evidence file (story AC-3). A failing
   targeted test is a finding, unless the battery evidence the call names already shows that failure (outside
   `classic` only, as the gate rules say); the `TESTS:` line is written either way.

## 5. `run-tests.sh`
POSIX `sh`, shellcheck-clean, with a test suite in this repository (`scripts/gate-b-run-tests.test.sh`, in the
quality command, run once under `sh` and once under `dash`, without a terminal). Usage:
`run-tests.sh <repo> <headSha> <seconds> -- <command…>`.
- **Validation:** `<repo>` must be a git work tree; `<headSha>` exactly 40 lowercase hex; `<seconds>` an integer
  1–1800 (default 600 when empty). Anything else: exit 2 with a message, nothing created. Every value is passed as
  a quoted argument, never spliced into shell source.
- **Supervisor:** the command and the watchdog each start as their own process group through
  `perl -e 'setpgrp(0,0); exec @ARGV'` (F5). No `perl`: exit 5, `no process supervisor`, nothing run.
- **Checkout fingerprint:** before the copy and after cleanup, the script hashes the reviewed checkout — `HEAD`;
  the effective index as `git ls-files -s` lists it (mode, blob id, stage, path; `GIT_INDEX_FILE` when set);
  `git diff HEAD --binary`; and every untracked, not-ignored path with its blob id and its type and executable
  bit (`[ -L ]`, `[ -x ]`), `.context/` excluded. A difference: exit 4, `checkout changed`. It detects, it does
  not prevent. Outside it, stated wherever the check is described: ignored files, `.context/`, file modes other
  than the executable bit of an untracked file, and anything under `.git/` other than `HEAD` and the index.
- **Copy:** `mktemp -d "${TMPDIR:-/tmp}/gate-b-review.XXXXXX"`; `git clone --quiet --no-local --no-checkout`, then
  `checkout --quiet --detach <headSha>`: tracked files only, a full object copy with no alternates back to the
  repository. Never `git worktree add`.
- **Run:** the command runs in the copy under `env -i` with only `PATH`, `HOME` and `TMPDIR` (both inside the
  copy's directory) and `LANG=C`. After `<seconds>` the group gets `TERM`, 5 s later `KILL`; the script waits for
  the group to be empty. On normal exit the watchdog group is killed and reaped.
- **Cleanup:** a `trap` on EXIT, INT, TERM and HUP kills both groups if alive and removes the directory. Limits,
  stated: a process that leaves the group (its own `setsid`) is outside the bound; `KILL` of the runner cannot be
  trapped. For that, each copy holds `runner.pid` and `group.pid`; every run first scans `gate-b-review.*`
  copies: runner and group both gone → removed; runner gone but group alive → left in place and reported as a
  stale copy with a live group (the script never kills a group it cannot prove it owns and never deletes beneath
  a live writer).
- **Report:** one line on stdout, `<command> | exit <n> | <seconds>s` (`exit timeout` after a kill); the
  command's own output goes to stderr, bounded to its last 200 lines.
- **Suite cases:** a pass; a fail; a timeout whose command spawns a child that ignores `TERM`; the environment
  stripped (a sentinel variable absent); an untracked sentinel file in the repository absent from the copy; a
  test that writes the reviewed checkout by absolute path → exit 4; a test that stages changed content and
  restores the working file → exit 4; a test that sets the executable bit of an untracked file → exit 4; the copy and both groups gone after success,
  failure, timeout and `INT`; the runner killed with `KILL` while a child survives → the next run reports, and
  does not remove, that copy, and removes it once the group is gone; no `perl` on `PATH` → exit 5; each
  validation rejection.

## 6. The risk pass (AC-5)
**Cycle base.** Before Gate B pass 1 the main session writes `.context/codex-reviews/gate-b-cycle-<nonce>.state`
with the line `base <40-hex>` (pass 1's `baseSha`); it is never rewritten in the cycle, and a resumed cycle reads
it. Risk runs append their own lines (below).
**Trigger.** The pass is due when the cycle's diff `<cycle base>..<head>` touches one of four categories, judged
by the main session from the diff's content, whatever the paths: (a) a script or tool the project runs (build,
release, CI, hook, installer, any language); (b) security-relevant code — authentication, authorization, secrets,
validation at a trust boundary, sandboxing or isolation, cryptography; (c) a rule or gate file — instruction
files, gate rules, review prompts, CI workflows; (d) a schema or data migration. Path patterns are aids that
force the trigger, never exemptions: `scripts/*`, `bin/*`, `*.sh`, any `hooks/` directory, `.github/workflows/*`,
`CLAUDE.md`, `AGENTS.md`, `.claude/*`, `.agents/*`, `.mcp.json`, any `plugins/`, `skills/`, `commands/` or
`agents/` directory, a `migrations` or `migrate` path segment, and the backticked shell `case` patterns on an
`AGENTS.md` `**Risk paths:**` line, which only add. A cited story with security not `none` also forces it; a
story citing `none` does not exempt category (b) found in the diff. The decision and its category go in the
cycle line at close (`risk: <a|b|c|d|none>`).
**When.** Once per cycle, after the ordinary passes leave no open blocking finding, on `<cycle base>..<head>`,
before the closing act. A change after it invalidates it only when it touches a risk category beyond the repairs
named in the risk pass's own dispositions; then the slot runs again, as a further pass under the cap. A run
started before the trigger held stays valid only if the trigger is re-judged on the final diff before close.
**Run** through `scripts/risk-pass.sh <repo> <baseSha> <headSha> <nonce> <n> <seconds>`. It validates the SHAs
(40-hex), the nonce (8–16 `[a-z0-9]`), `<n>` (a positive integer) and `<seconds>` (default 2400); refuses with
exit 6 unless `codex --version` prints exactly `codex-cli 0.162.1` (the pin, in the script, bumped deliberately);
takes the slot lock `mkdir .context/codex-reviews/gate-b-risk-<nonce>-pass-<n>.lock` holding `runner.pid` and
`group.pid` (a held lock with a live runner or group: exit 4, busy, nothing touched; a lock whose runner and group
are both gone is taken over); chooses the attempt number `<a>` (one more than the state file's last `start` for that slot) and appends
`risk <n> start <a> <headSha> <epoch>`; runs `codex exec --json -s workspace-write -c
model_reasoning_effort="high" -C <repo> -o <reply file>` under the §5 supervisor and watchdog with a fixed prompt
naming the skill's `risk` branch, the range and this attempt's own files — findings
`.context/codex-reviews/gate-b-risk-<nonce>-pass-<n>-attempt-<a>.md`, evidence and reply beside it, the `--json`
event log to `…-attempt-<a>.events.jsonl` (written outside the checkout during the run and placed there after it,
unit 3 fix); and records `codex --version`, the head and the model the event log names, else the top-level `model`
of `$CODEX_HOME/config.toml` (unit 3 fix; `unknown` when neither names one) in the evidence file. The attempt's findings file is valid when Codex exited
0, every body line is a finding line of the gate rules' grammar (severity from the closed set) or the single clean
line `NO FINDINGS`, and the terminator reads `END OF FINDINGS (<k> total)` with `<k>` the number of finding lines
(0 for the clean file). Only then, still holding the lock, the script copies it to the slot's canonical file
`.context/codex-reviews/gate-b-risk-<nonce>-pass-<n>.md` and appends `risk <n> done <a> <headSha> <sha256 of the
canonical file>`; any other outcome appends `risk <n> failed <a> <exit>`. It releases the lock on every exit.
Only the lock holder writes the canonical file, so a late writer from an earlier attempt can write only its own
attempt file; the closing act accepts the canonical file only when its sha256 matches the slot's last `done`
line and the change from that line's head to the head being closed keeps the result valid under **When** (only
repairs named in the risk dispositions or content outside the risk categories, each verified by a later
`quality` pass); otherwise the slot runs again under the cap.
Exit 1: Codex failed or the file is invalid — one retry, as for any failed pass; 2: bad arguments; 3: timeout;
4: busy; 5: no supervisor; 6: wrong Codex CLI. The main session runs it as a background Bash call and waits for
its exit. Its suite (`scripts/gate-b-risk-pass.test.sh`, `codex` stubbed) covers: valid, clean and malformed
findings files; a stale file from an earlier attempt; a late writer from an earlier attempt that writes its
attempt file before and after the current result is promoted (the canonical file and its `done` line unchanged);
a risk finding repaired on a later head and verified by the next `quality` pass (accepted at
close); a later head that adds risk-category content outside the risk dispositions (rejected: the slot runs
again); a busy lock; an interrupted run resumed; the version refusal; each validation rejection.
**Counting:** the risk pass is one pass toward the Gate B cap of every mode (`lean` 3, `strict` 5, `classic` 5),
never toward the floor, which stays the hook-counted `spec`+`quality` pair. When the trigger holds and no pass
remains under the cap, the cycle cannot close: that goes to the human, as an open Blocker at the cap does.
**Follow-up:** each blocking risk finding is listed, with its verdict, in the next `quality` call as an earlier
finding of that slot, which marks it `fixed | not fixed | no longer applies`; `not fixed` stays blocking. The risk
slot has its own dispositions file. The hook does not see the run (a Bash call), so the closing commit's cycle
line counts it: `Findings <spec,quality counts>; risk pass <n>: <count>`.

## 7. Scaffolding, gate rules and this repository (AC-1, AC-2)
- `/workflow-init` gains `### 2.24` with three fenced templates (`SKILL.md`, `run-tests.sh`, `risk-pass.sh`,
  inline per invariant 8), each under rule 9 (missing → write; identical → unchanged; different → diff and ask).
- `### 2.8` adds `"CODEX_DEV_SANDBOX_MODE": "workspace-write"` to the `codex` server's `env` — a merge into an
  existing entry that adds only that key and leaves every other key; a different value already there is shown
  and asked about. Gate A then runs `workspace-write` too: it writes only its findings file in the workdir. The
  report tells the user the setting applies from the next session start (F2), and that a server config file's
  `tools.review.sandbox` overrides it.
- **Codex CLI pin.** The new paths (targeted tests through the skill, the risk pass) are verified on Codex CLI
  0.162.1 and `risk-pass.sh` refuses any other version (§6). Installing that version is the user's action under
  their home: `/workflow-init` offers it as a listed human step with the install command the Codex project
  documents for 0.162.1, never runs it, and the plan lists it as a human action. Ordinary Gate A and Gate B calls
  go through the MCP server as today.
- Nothing is written or printed as a step under the home directory except that offered human step.
- This repository adopts all of it. New check **4o** in `scripts/check-invariants.sh` fails unless each of the
  three files is byte-identical to its `### 2.24` fence (as 4j, 4l, 4m do).
- `.claude/review-gates.md` and its `### 2.1a` copy name the skill in the Gate-B prompt and carry §6's trigger,
  timing, counting and follow-up in short form, inside check 4i's 10,000 bytes by tightening existing lines, each
  removed word accounted for (AGENTS.md "Never replace a decision procedure…"); `docs/reference.md` carries the
  long form.

## 8. Proof (AC-6)
**Cases, frozen before any run** (from the PR history; each: a bot comment accepted and fixed after the head
carried a closed Gate B cycle): #97, #49, #41, #56, #43, #40, #99, #95 — eight, in that order; the answer key (bot
comment, fix commit, defect statement) is written to the report first.
**Driver** (`docs/superpowers/replays/2026-10-30-kit-051/replay.sh`, not shipped): per case, a `--no-local` clone
at the pre-fix head with every ref, the remote and the reflog removed and unreachable objects pruned, so later
history is absent; the new skill copied in untracked; the `spec` and `quality` prompts rendered from
`mcp-codex-dev@1.0.1`'s templates with the kit's `additionalContext`, run as `codex exec -s workspace-write
--json`; the risk pass through `risk-pass.sh` when §6 triggers. Range: the PR's merge-base..pre-fix head.
Recorded per case: Codex calls, wall time per call, model and CLI version, findings files, the `--json` event log.
**Scoring:** **found** means a finding line states the bot's defect — its cause and its consequence — not merely
the same file or line; the matching line is quoted beside the key. A case counts once however many lines match.
**Contamination:** every reviewer call of a case — `spec`, `quality` and each risk-pass attempt — keeps its
`--json` event log, and the logs are audited together. A case is contaminated when a log shows a command reading
outside the clone, a `gh` or network call, or a read of the replay directory or report; it is unverified when a
log is missing or unreadable. A contaminated or unverified case is excluded from the numerator and rerun once;
still so, it is reported as such and counts as not found.
**Target:** at least 4 of the first 6 cases, with 7–8 reported as well. Below target: the report and the decision
whether to merge go to Daniel (it is a question about the order's commitment), not decided by this session.
**Residual exposure:** the reviewer can read host files outside the clone; the prompt forbids it, contamination
detection covers what the event log shows, and the report says so.
Expected wall time is over 15 minutes; the go comes from the orchestrator dev-workflow-kit-26 (Daniel,
2026-10-30).

## 9. Release (AC-7)
0.51.0 in the manifest, `### 2.23` and `.claude/dev-workflow-version` (check 4n); CHANGELOG; README;
`docs/reference.md` (Gate B: the skill, the trust model and its limits, the risk pass, the sandbox setting, the
Codex CLI pin); `docs/ARCHITECTURE.md` tree and scripts inventory (`.agents/`, the two new suites); `AGENTS.md` §
Commands (the new suites in the quality and lint rows) and a Boundaries entry for the two scripts.

## 10. Decisions
- **D1** Skill in the repository (`.agents/skills/`), not `$CODEX_HOME/skills`: F1 shows Codex loads it there, so
  AC-2 needs no home step. The path is also named in the call.
- **D2** Keep the server's review templates; the method lives in the skill.
- **D3** Sandbox by `CODEX_DEV_SANDBOX_MODE` in `.mcp.json`, not a server config file: it adds one key to a file
  `/workflow-init` already merges, and shadows no per-tool settings (F2). The reviewer's own check (§4.4) is
  what gates tests, so a setting that did not take effect fails safe.
- **D4** Risk pass by `codex exec` through a script, because no MCP tool takes an effort (F2); counted toward the
  cap by the rules, not by the hook.
- **D5** Disposable copy by `git clone --no-local`, not a worktree: Daniel's "never `git worktree add`", no
  registry entry to leak, no alternates back to the repository.
- **D6** No dependency install in the copy: offline makes it unreliable; the reason is reported.
- **D7** Semgrep (order item 5) is its own story, `2026-10-30-kit-052-semgrep-optional-story.md`, after this
  unit's handover boundary.
- **D8** Shell for the two scripts, with suites, rather than prose snippets: the time limit, cleanup and
  validation are behaviour a reader cannot check in prose (Gate A pass 1, findings 5, 10, 18).
- **D9** Secrets: env-only removal plus a tracked-files-only copy, not filesystem isolation (Daniel, 2026-10-30;
  story AC-3 narrowed).
- **D10** Process groups through `perl setpgrp`, failing closed without it: `set -m` does not work in `dash` (F5),
  and macOS has no `setsid`.
- **D11** The risk pass runs late (after the ordinary passes settle), so it reviews the final risky content
  once; a later risky change outside its own repairs costs a further pass under the cap.
- **D13** Risk-pass results per attempt, promoted to the canonical file only under the slot lock and bound to
  head and hash in the state file: a lock and a modification time do not show which attempt wrote a file.
- **D12** Codex CLI pinned by refusal in `risk-pass.sh` and a human install step, the way `local-ci.sh` refuses a
  shellcheck other than the pinned one.

## 11. Non-goals
No change to the hook, the findings format, the floors or caps, Gate A's method, or the PR-bot flow. No
vendoring from sfx-factory. No home-directory writes by an agent. No indexing. No protection against a test
reading host files by absolute path, nor against secrets committed to tracked files (§3, story AC-3).
