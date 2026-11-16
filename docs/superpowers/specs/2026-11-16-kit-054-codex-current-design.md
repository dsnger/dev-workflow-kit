# Kit 0.54: the risk pass runs on the current Codex CLI — Design

**Story:** `docs/superpowers/stories/2026-11-16-kit-054-codex-current-story.md` (level 2) ·
**Profile:** risk high; security standard; evidence battery+check+verification (from the story header) ·
**Gate A:** runs — risk high; security standard; evidence battery+check+verification

## 1. Scope

One PR, minor bump to 0.54.0. (A) `risk-pass.sh` replaces its exact Codex CLI pin with a minimum version and
gains two run-time checks; (B) the rules name what a session does when the risk pass does not finish; (C) every
text that names 0.162.1 as a requirement is corrected; (D) release. Non-goals: no change to `run-tests.sh`, to the
ordinary Gate A or Gate B calls (they go through the MCP server), to the Codex MCP server pin in `.mcp.json`, or
to the hook; no install, update or downgrade of the Codex CLI by the kit, by `/workflow-init` or by an agent.

**Fixed by Daniel (2026-11-16):** "Wir gehen auf keinen Fall zurück. Codex läuft global und da soll die neueste
Version laufen." The kit runs on the installed current CLI and keeps running when it updates.

**Library APIs.** Codex CLI 0.169.0 (`codex --version` on this Mac, 2026-11-16). Context7 `/openai/codex` is
indexed up to `rust-v0.165.0` and not for 0.169.0, and its 0.165.0 pages do not describe the `exec --json` event
shape, so the source is the CLI's own material for 0.169.0: `codex exec --help` (`--json`, `-s`, `-C`, `-c`),
`codex sandbox --help` (`-P`), `codex debug --help` (`prompt-input`), and the runs in §2.

## 2. What was observed on 0.169.0 (2026-11-16, macOS)

Each line is a run of this session; the PR body carries the same results.

- **Sandbox.** In a fixture repository outside `TMPDIR` and `/tmp`, with a `mktemp -d` scratch directory in its
  git directory, `codex sandbox -P :workspace -- sh -c …` was refused with `Operation not permitted` for: a file
  created in the scratch directory, a directory created in the git directory, and removing the scratch
  directory. The same in this linked worktree's git directory (`<main>/.git/worktrees/<name>`). Controls in
  the same sandbox succeeded: a file in the work tree and a `mktemp` file in `TMPDIR`. `codex exec -s
  workspace-write` printed `sandbox: workspace-write [workdir, /tmp, $TMPDIR]`.
- **Event log.** `codex exec --json -s workspace-write -c 'model_reasoning_effort="low"' -C <repo> -` exited 0;
  its log held `thread.started` (a `thread_id`, no model), `turn.started`, `item.completed` with item types
  `error` (two config deprecation notes) and `agent_message` (one, with `text`), and `turn.completed`. The
  script's own extraction returned the agent message. No event names a model, as on 0.162.1.
- **Effort key.** Without `--json`, the same call with `model_reasoning_effort="high"` printed
  `reasoning effort: high`. With `--json` nothing in the log or on stderr names the effort or the sandbox.
- **Skill discovery.** With a probe skill under `.agents/skills/`, `codex debug prompt-input` listed it by name
  and description, and a `codex exec` reply named it without reading a file.

## 3. (A) `risk-pass.sh`

### 3.1 Version rule

`CODEX_MIN='0.162.1'` replaces `CODEX_PIN`. The first line of `codex --version` is read as before, at the same
place (after the argument and state checks, before the lock; nothing is written before it).

- **Readable** means exactly `codex-cli <a>.<b>.<c>`: three runs of decimal digits, each of at most 6, nothing
  after them. Anything else is unreadable: no `codex` on `PATH`, an empty line, another product name, two or four
  parts, and a pre-release or build suffix (`0.170.0-alpha.1`).
- **Accepted** when `(a, b, c)` is at or above `(0, 162, 1)`, compared part by part as numbers (so `0.1000.0`
  and `1.0.0` are accepted, `0.162.0` and `0.99.9` are not). There is no upper bound.
- **Refused**, exit 6 as today, with one of two messages that name the version line seen: *older than the
  minimum* (`… is older than the minimum 'codex-cli 0.162.1'; updating the Codex CLI is the user's step`) or
  *unreadable* (`cannot read a Codex CLI version from '<line or not found>' (expected 'codex-cli <x>.<y>.<z>')`).
- Two things carry the name `…-attempt-<a>-evidence.md`, as today. The reviewer writes the raw file (its `TESTS:`
  and `CALLERS:` lines). Once Codex has ended, the script completes it: `CLI: <the version line>`, `HEAD:`,
  `MODEL:`, `EXIT:`, then the reviewer's lines, for failed attempts too (AC-2). An attempt that ends before that
  step — a signal, a replaced scratch directory, a review directory that cannot be written — can leave the raw
  file. A reader tells them apart by the first line: only a completed file starts with `CLI:`. The attempt's
  `start` line in the state file is the trace of such an attempt; it names no CLI version.
- The two refusals have different remedies, and every text that names them keeps them apart: *older* is cured
  by updating the CLI; *unreadable* is not evidence of an old CLI (no `codex` on `PATH`, another program of that
  name, a pre-release build), so the text reports the line seen and `command -v codex` and leaves making
  `codex --version` print a release line to the user.

The minimum is the first version the script was verified on (0.51–0.53 cycles; archived evidence). Versions
between 0.162.1 and 0.169.0 are not verified one by one; §3.2's checks carry them, as they carry later ones.

### 3.2 The assumptions the pin guarded

Story AC-3 (as narrowed 2026-11-16) asks, per assumption, for a run-time check or for a showing on 0.169.0 that
is named as not checked at run time. Which one each gets:

| Assumption | Shown on 0.169.0 | Run-time check |
|---|---|---|
| The flags and the stdin prompt: `exec --json -s workspace-write -c … -C <repo> -` are accepted | §2, exit 0 | **Yes, existing:** Codex rejects an unknown flag or sandbox value and exits non-zero: exit 1 (test `codex failing`) |
| The reply is the last `agent_message` of the `--json` log | §2 | **Yes, new:** Codex exited 0 and the log yields no agent message, or an empty one: exit 1, `failed` line, nothing promoted; the message names the event format as the likely cause |
| Nothing the reviewer writes into the scratch directory reaches a result or redirects a write | — (a property of the script) | **Yes.** Kept from 0.53: exclusive no-follow creates, no-follow non-blocking reads of regular files, the directory's identity. **New:** once Codex's group is stopped and the identity is confirmed, the directory must hold exactly the three entries the script put there (`events`, `prompt`, `stderr`); anything else: exit 1, `failed` line, nothing promoted |
| The sandbox keeps the scratch directory out of the reviewer's reach (checkout outside `TMPDIR` and `/tmp`) | §2 | **No — shown only.** The row above is what the script relies on; this one is a second layer |
| `-c model_reasoning_effort="high"` sets the effort | §2 | **No — shown only.** Nothing in the `--json` output or on stderr names the effort |
| Codex discovers the review skill under `.agents/skills/` | §2 | **No — shown only, and not relied on:** the prompt names `.agents/skills/gate-b-review/SKILL.md` |

Whether the model then follows the skill's method is no assumption about the CLI and was never checked: it is an
instruction, on every version. An evidence file without a `TESTS:` or a `CALLERS:` line fails the attempt (since
0.53); that shows the evidence format was met, not that the method was followed, and no text of this change says
more.

The scratch entries are read right after the identity check, before the script writes anything there itself. Both
new failures are reported after the existing ones for timeout (exit 3) and Codex's own exit status, scratch
entries before the reply. The event log, reply and evidence files are still placed beside the attempt first, as
today, so a failed attempt can be read.

**What a later Codex could break without failing an attempt**, stated in the script's comments and in
`docs/reference.md` (the list names what was looked at — flags, event format, scratch writes, sandbox reach,
effort key, skill discovery — and is not claimed to be exhaustive): (1) a renamed config key: `-c
model_reasoning_effort="high"` would be ignored silently and the pass would run at the default effort; the
evidence's `CLI:` line is the trace; (2) a wider `workspace-write` that lets the reviewer write the scratch
directory: an attempt in which it writes nothing new there passes, and one in which it only rewrites `events` or
`stderr` in place passes too — both files are its own output, and the scratch row's checks still hold; (3) a Codex
that no longer lists skills: nothing fails and nothing needs to, since the prompt names the file; (4) a process that escaped the
killed group (the existing shortcut). The entries check detects a new entry in the scratch directory, not the
ability to write there. These are the limits the exact pin hid rather than closed: on 0.162.1 none of the "No"
rows was checked at run time either.

### 3.3 Header and comments

The header's exit list reads `6 a Codex CLI older than the minimum, or a version line it cannot read`. Comments
that say "Codex 0.162.1" as an observation gain "and 0.169.0, 2026-11-16"; none names a version as a requirement
except `CODEX_MIN`.

## 4. (B) The route when the risk pass does not finish

In the skill's § Risk pass, which the gate rules already point to for the run, one new bullet after *Run*:

- exit 0: the result. Exit 2: the call is wrong (arguments, state file); correct it and run again; no attempt
  was recorded.
- exit 4, by the script's message: `held by a live attempt` — an attempt is running in this slot; wait for that
  run to exit and read its result, start none. Any other exit-4 message (a takeover in progress, a lock without a
  runner record, a takeover that failed) may be a leftover of an interrupted run: run it once more after 60
  seconds; exit 4 again goes to the human with the message, which names the lock path. The session removes no
  lock itself, because it cannot tell a leftover from another session's attempt that is just starting.
- exit 1 or 3, or a signal status: run it once more with the same `<n>` (the script numbers the attempt).
- exit 5 or 6, or a second failure in the same slot: nothing more is run. This is CLAUDE.md's missing-access
  stop: report the status, the script's message and `codex --version` to the human; the cycle stays open.
- always: the cycle closes only on the slot's `done` line (unchanged); an ordinary pass does not stand in for
  the risk pass; the session does not install, update or downgrade the Codex CLI and does not edit the script to
  get past a refusal — the CLI is the user's machine, and a weakened check is no check.

In the gate rules (`.claude/review-gates.md` and template `### 2.1a`, check 4j), the Risk pass line changes one
clause: `a pass toward the cap, not the floor (none left: human)` becomes `a pass toward the cap only (none
left, or it cannot run: human)`. Old conditions of that line, all kept: due by content; state file before pass
1; run once nothing ordinary blocks; counts toward the cap and not the floor (reworded, same meaning, to stay
under check 4i's 10,000 bytes: the file is at 9,990); no pass left goes to the human; findings join the next
`quality` call; a later risky change reruns it; close needs the `done` hash; the cycle line. Added: it cannot
run goes to the human.

## 5. (C) Texts

Every site from `grep -rn '0\.162\.1' --include='*.sh' --include='*.md' .` outside `source-files/`, `.context/`,
`docs/superpowers/` and `todos.md`:

| Site | Change |
|---|---|
| `risk-pass.sh` and its `### 2.26` copy | §3 |
| `SKILL.md` line 8 and its `### 2.24` copy | "via the Codex CLI (0.162.1 or later)"; § Risk pass gains §4's bullet |
| `workflow-init.md` `### 2.24` intro | discovery "verified on 0.162.1 and 0.169.0" |
| `workflow-init.md` `### 2.26` intro | needs 0.162.1 or later; `codex --version` older: list *updating the Codex CLI* as the user's step in the closing checklist; not readable as `codex-cli <x>.<y>.<z>`: list the line seen and `command -v codex` there instead (§3.1); no install command, no version to install |
| `workflow-init.md` closing checklist item | same two cases, in the user's words |
| `README.md` row | "needs Codex CLI 0.162.1 or later" |
| `AGENTS.md` § Commands prerequisites | the new rule and exit 6's meaning |
| `AGENTS.md` invariant 5 | a fifth bounded exception, stated: the Codex CLI `risk-pass.sh` runs is the user's global install and is not pinned (Daniel, 2026-11-16); what stands in is a minimum version, the version line in the evidence file and the run-time checks §3.2 marks "Yes" — detection, not a pin, with §3.2's "No" rows named as unchecked; the kit never installs or updates it. "Four bounded exceptions" becomes "Five" |
| `docs/reference.md` | exit 6; the **Codex CLI version** paragraph (rule, what refuses, what is not covered per §3.2, the route per §4); the discovery sentence gains the 0.169.0 check |
| `plugins/dev-workflow/CHANGELOG.md` | § 0.54.0; earlier sections stay as history |

No text prints an `npm install` line for Codex: an unversioned one would break invariant 5's rule for docs and
templates, and a versioned one is what Daniel ruled out. Historical notes stay: `todos.md`, CHANGELOG § 0.51.0
and § 0.36.0, `docs/reference.md`'s `rust-v0.162.1` source note, specs, plans and replays.

## 6. (D) Release

`plugins/dev-workflow/.claude-plugin/plugin.json`, the `### 2.23` template and `.claude/dev-workflow-version`
read 0.54.0 (check 4n). Checks 4j and 4o keep the copies identical; 4i and 4g keep the sizes.

## 7. Tests and evidence (AC-1 … AC-6)

In `scripts/gate-b-risk-pass.test.sh`, each written first and seen to fail on the 0.53 script (the `+check`):

| Situation | Expected | AC |
|---|---|---|
| stub version `codex-cli 0.169.0`, valid result | exit 0; evidence line `CLI: codex-cli 0.169.0` | AC-1, AC-2 |
| `codex-cli 0.162.1` (the minimum), `codex-cli 0.1000.0`, `codex-cli 1.0.0` | exit 0 | AC-1 |
| `codex-cli 0.162.0`, `codex-cli 0.99.9` | exit 6, message says older, no `risk` line in the state file, no lock left | AC-1 |
| `codex-cli 0.170.0-alpha.1`, `codex 0.169.0`, `codex-cli 0.169`, an empty line, a 7-digit part | exit 6, message says cannot read, nothing written | AC-1 |
| Codex exits 0 with a valid findings and evidence file but no `agent_message` event | exit 1, `failed` line, no canonical file | AC-3 |
| the reviewer adds a file to the scratch directory (checkout in `TMPDIR`) and leaves a valid result | exit 1, `failed` line, no canonical file | AC-3 |
| the existing suite | unchanged and green; its one changed case is "another version: exit 6", replaced by the rows above | AC-6 |

AC-3 per assumption is §3.2's table: the "Yes" rows by the two new cases above and the existing ones (`codex
failing`; links, FIFOs and a replaced scratch directory), the "No" rows by §2's observations and by their being
named in the script's comments and `docs/reference.md`. AC-2: the first row asserts the completed file's first
line; the existing case "the scratch directory replaced by a link", whose stub leaves a raw evidence file, gains
the assertion that this file does not start with `CLI:` (§3.1). AC-4 and AC-5 are text: AC-5 is checked by the grep of
§5 returning only historical notes and the minimum; AC-4 by Gate B reading the skill bullet against §4. The
exit-4 route of §4 is prose for the session and changes no script behaviour; the suite's existing lock cases
(`taking over`, a runner it may not signal, a live runner, a dead owner taken over) already pin the messages it
reads.

**Named verification (`+verification`).** This cycle's own risk pass, due because the diff touches a script and
the gate rules, runs with the changed script on Codex 0.169.0. Its exit status, its evidence file's `CLI:` line
and its `done` line are quoted in the PR body. A refusal or failure there follows §4.

## 8. Approaches

1. **Minimum version plus run-time checks (chosen).** Runs on the current and later CLIs; an old CLI the kit never
   ran on is still refused; what the pin guarded is checked where the script can see it.
2. **A list of verified versions.** Stops at the next update, which Daniel ruled out.
3. **No version check, run-time checks only.** Simpler, but a CLI older than anything verified would run, and the
   message a user gets for a broken old CLI would be a confusing failure instead of "update".

## 9. Decisions

Made in this autonomous run (CLAUDE.md §4), each a choice, not a source fact:

- **D1** Profile: risk `high` (supply chain: a pin on an executed third-party tool becomes a minimum), security
  `standard` (the pin guarded sandbox assumptions; the sandbox's permissions do not change). Checkpoints `none`.
- **D2** Minimum 0.162.1, not 0.169.0: a project still on the old CLI keeps working, and the script was verified
  there.
- **D3** A pre-release version line is unreadable and refused: its number alone does not say whether it is at or
  past a release, and the conservative reading is refusal.
- **D4** No sandbox probe before the run (`codex sandbox … : > scratch`): it would have to pass in a checkout
  under `TMPDIR` or `/tmp`, where the write legitimately succeeds, so it could not fail closed; and it would tie
  the script to a subcommand whose help text names only macOS's seatbelt and which was never run on Linux here.
  The sandbox's reach is therefore shown (§2) and named as unchecked; the script relies on its own checks of
  what it reads and writes in the scratch directory, to which the entries check is added.
- **D5** A missing reply fails the attempt, although the gate counts only the findings file: where a check can
  be built cheaply it is built, and it fails closed.
- **D9** Story AC-2 and AC-3 are narrowed by a change record (story, 2026-11-16): AC-3 to the order's wording,
  "keep each one as a runtime check or show it still holds on 0.169.0" and "the skill discovery"; AC-2 to the
  evidence file the script completes. The story's first wording was this session's own, an hour old, stricter
  than its source and than the script, and no gate had closed on it.
- **D6** A risk pass that cannot run stops for the human and never closes the cycle another way: the alternative,
  an ordinary pass standing in, would cut a gate guarantee.
- **D7** The route lives in the skill, with one clause in the gate rules, because the gate rules have 10 bytes
  left under their cap and already send the session to the skill for the run.
- **D8** Invariant 5 gains a stated exception instead of staying silent about a tool that is no longer pinned.

## 10. Left to the implementer

How the version line is parsed and compared in POSIX `sh` (awk or `case`), the exact wording of messages and
prose within §3–§5, the names of the stub switches in the suite, and the CHANGELOG wording.
