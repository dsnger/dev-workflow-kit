# Kit 0.45 field cases — design and plan

**Story:** `docs/superpowers/stories/2026-10-26-kit-045-field-cases-story.md` (AC-1 … AC-9).
**Profile:** risk standard; security standard; evidence battery+check — from the story header. Floor 3 (level 1).
**Release:** dev-workflow 0.45.0. One spec, one PR. §7 is the plan.

## 1. Intent

Four field cases, each with the smallest fix that makes the field symptom impossible or visible, and prose that
says exactly what each mechanism compares:

1. The hook counts a Gate A `exec` call as a pass even when no findings file came out of it (kit-044 `k044ga7q`:
   hook 5, valid passes 4).
2. codebase-memory's git watcher, on by default, made about 27 sessions re-index one repository at once.
3. A session waited about 15 hours on a CI run that never existed.
4. The two cycle-record reports cannot read curves written with `, ` separators and a model of several words.

Non-goals: Gate B's counting (no field case; its pass file is not always written by Codex); any change to the cycle
line format the rules prescribe; setting codebase-memory's configuration from the kit; a CI-polling tool.

## 2. Case 1 — Gate A counts only a call that left a complete findings file

**Evidence.** Kit-044 transcript (`~/.claude/projects/-Users-daniel-DEVELOPMENT-APPS-dev-workflow-kit--claude-worktrees-kit-044/3890e4d5-….jsonl`):
the first `mcp__codex__exec` call asked for the findings in the reply and named no file; the server's
`output.summary` came back cut after the first finding ("…"). The second call named
`.context/codex-reviews/gate-a-spec-k044ga7q-pass-1.md`, Codex wrote it, and it became pass 1. The hook's
`passCountA` read 5 against 4 pass files. Canvas S4 (2026-10-21) showed the same mismatch; the 0.40.0 `sessionId`
rule covered only the re-fetch shape.

**Rule (gate rules, Gate-A prompt).** Add one sentence: the prompt names the pass's target as
`Findings file: <path>`, Codex writes it, and a call that only replies is no pass. Both copies
(`.claude/review-gates.md`, `/workflow-init` `### 2.1a`) stay byte-identical and at most 10,000 bytes, so the
sentence's bytes are trimmed from elsewhere in the same file without dropping a condition (each trimmed sentence is
listed in the PR body with its fate: kept, moved or dropped).

**Hook.** After the existing classification and the existing resumed-session exception (jq only, unchanged), a
Gate A call is counted only when all of these hold:
- `tool_input.instruction` holds the label `Findings file: ` followed by a path matching
  `.context/codex-reviews/gate-a-(spec|plan)-<nonce>-pass-<n>.md` (nonce `[a-z0-9]{8,16}`, `n` without a leading
  zero), either relative or as the absolute path `<repository root>/.context/codex-reviews/<file name>` of this
  checkout; an absolute path into any other directory leaves the call uncounted ("findings file elsewhere"). Only labelled paths are targets: an earlier pass's path named
  as context, or an old cycle's path inside embedded artifact text, carries no label and is ignored. Two different
  labelled paths make the target unknown, and the call is not counted. A dispositions path never matches.
- The target, `<repository root>/.context/codex-reviews/<file name>`, is a regular file and not a symbolic link.
- Its structure passes three checks, and only these: its last line is `END OF FINDINGS (<t> total)`; for `t` = 0
  the only body line is `NO FINDINGS`; otherwise there are exactly `t` body lines and each starts with
  `BLOCKER | `, `MAJOR | `, `MINOR | ` or `NIT | `. The six fields of a finding line are not checked.

Otherwise the call is not counted, and the hook says so in one note naming the failed condition ("names no
findings file", "names two findings files", "findings file elsewhere", "findings file missing", "findings file
incomplete", "findings file unreadable"); next: a reply-only or cut-off call is an incomplete pass that counts for
nothing; repair the cause first, then re-run within the existing one-retry budget. The note links to a new
`docs/reference.md#hook-messages` entry with each cause, its check and its fix: no or two labels → write one
`Findings file: <relative path>` line; elsewhere → name this checkout's path; missing or incomplete → delete a
partial file and re-run with Codex writing it; a symbolic link → replace it with the file; unreadable → check that
`awk` runs (`printf 'x\n' | awk '{print}'`); a `\u`-escaped path without jq → write the path in plain ASCII or
install jq; a server whose exec tool has no `instruction` input → install the pinned server (2.8).

**Without jq.** `instruction` is read with `input_field`'s fallback. `instruction` is a required input of the exec
tool, so the fallback finds `tool_input`'s own key; a payload lacking it is a malformed call. A path character
written as a `\u` escape decodes to `?`, so that path does not match and the call is not counted (the safe side).
The resumed-session exception stays jq-only, so without jq a resumed call with a complete file still counts, as the
existing jq-free regression expects. When `awk` fails, the structure check cannot run and the call is not counted
("findings file unreadable"); the existing awk-fault cases that expect Gate A to count change accordingly.

**What this does not establish** (stated in the hook comment, the note and `docs/reference.md`): which run wrote the
file (a complete file left from an earlier call is credited again — the rules already require deleting the target
before a re-run); whether the finding lines are well formed beyond their severity prefix; whether the findings are
right; whether the file reviewed the right artifact. A server whose exec tool takes its prompt under another key
than `instruction` never counts; the note names that cause.

**Direction.** Every new condition can only lower the count, invariant 2's side (more reminders, the floor reached
later). The hook still exits 0 (invariant 1), stays POSIX `sh` (invariant 4; `grep -o` is already used by the
fallback reader).

**Prose to update** (AC-3): every statement that Gate A is "counted by call" / "counted as calls" or that the hook
reads nothing of a Gate A call — the below-floor note, the no-plan note (`codex-gate.sh` near line 1674), the
no-fingerprint note, the floor-met comment, the jq-free awk-fault comment ("Gate A does not read the request",
`codex-gate.test.sh` near line 2518), `docs/reference.md` (hook section and the Gate A paragraph), and their
exact-text test expectations. CHANGELOG entries of earlier releases describe their release and stay. Found with
`grep -rniE 'counted (as|by) call|reads no findings' --include='*.md' --include='*.sh' . | grep -vE 'source-files/|docs/superpowers/|docs/history/'`.

**Backlog** (AC-4): close `todos.md` "Gate A replies truncated in transport again" (0.40.0) with this release; the
0.37.2 row is already closed and gets a pointer to 0.45.0 as its follow-up.

## 3. Case 2 — codebase-memory watcher warning

**Facts from the installed binary** (`/Users/daniel/.local/bin/codebase-memory-mcp`, `--version` → 0.9.0, read
2026-10-26): `config` lists `auto_watch  default=true  Register background git watcher on session connect`;
`config get auto_watch` and `config set <key> <val>` exist. On this machine `config get auto_watch` → `false`
(Daniel set it on 2026-10-25). These are the vendor's own help text, not a reviewed behaviour.

**Change.**
- `/workflow-init` 2.14 gains a short **Watcher load** paragraph: on 0.9.0 `auto_watch` defaults to `true`, so
  each session's server registers its own git watcher; with many sessions open, one pull that renamed hundreds of
  files made about 27 instances re-index one repository at once (load 70 on 16 cores, 2026-10-25). Recommend to the
  user, in the step's report, `'<resolved path>' config set auto_watch false` and a deliberate refresh with the
  recorded human refresh command. The agent does not run either: the kit never configures this server, and
  `config` reads and writes the user's store.
- The identity-row template gains `Watcher: auto_watch <value the user reports, or unknown>; recommended false.`
- AGENTS.md invariant 5's fourth exception gains one sentence on the same risk, naming 2.14 as where the
  recommendation lives.
- This repository's identity row (`todos.md` § Tooling revalidation) records `auto_watch false (set by Daniel
  2026-10-25; observed 2026-10-26)`.

## 4. Case 3 — waits on external work

CLAUDE.md §4 and the `/workflow-init` 2.1 template gain one paragraph, **Waiting on external work**, after
"Autonomous run":
- the clock starts at the trigger: the push, or the manual start of a job or deploy;
- before waiting, confirm the run exists for that trigger: its id seen and a status read. Queued, in progress or
  waiting for approval: wait. Already finished: read its result, no wait;
- when no run appears within 5 minutes of the trigger, when its status cannot be read, or when the wait passes its
  limit — twice the run's usual duration, or 60 minutes when that is unknown, counted from the trigger and never
  restarted — stop waiting and treat it as a failed check: find the cause (for a run that never appeared, often an
  invalid workflow file) and report the id or its absence, the last status and the time waited;
- why: the 15-hour wait of 2026-10-25.

`process-pr-review` Step 6's "after the run completes" gets "(with CLAUDE.md §4's wait limit)", the one place a
skill tells the agent to wait on CI. Check 4e (template ≤ 20,000 characters) must still pass.

## 5. Case 4 — curve lines as the field writes them

**Evidence.** `python3 -I` on `scripts/ledger-metrics.py`'s `parse_record`: the kit-044 line
`…(passes 1, 2, 3, 4, gpt-6-astra): Findings 14, 7, 3, 3. …` → `None`; the same without spaces → parsed. Field
lines in sfx-time-tracking-dashboard also carry `gpt-6-astra per $CODEX_HOME/config.toml`. The rules' line
(`(passes <ascending valid pass numbers>, <model>): Findings <per-pass counts>.`) never fixed the separator.

**Change** in `parse_curve` / `parse_model` (`scripts/ledger-metrics.py`; `loop-usefulness.py` and `spec-delta.py`
reuse `parse_record`):
- a pass list and each count series accept `,` or `, ` between items, normalized to `,` before `expand` and the
  count checks, so every later check is unchanged;
- a bare (unquoted) model may be several `BARE_MODEL` words separated by single spaces; quoted models are unchanged.
Nothing else in the grammar loosens: a malformed line still lands in "unparsed".

**Docs.** `docs/reference.md`'s entries for the two reports gain one sentence on the accepted forms.

## 6. Decisions (made in this autonomous run)

- D1. Case 1 counts on the file, not on the reply: the reply is cut by the server even for valid passes (every
  kit-044 summary carried "…"), so its text cannot tell a complete pass from a cut one.
- D2. The target is the labelled path (`Findings file: <path>`), not a path picked by position or number: from pass
  2 on, earlier passes' files are named as context, and embedded artifact text can name old cycles' files.
- D3. Gate B is left as it is (no field case; who writes its file varies).
- D4. Case 2 recommends and records; it does not read or set the server's configuration, keeping invariant 5's
  "never configures".
- D5. Case 3's numbers (5 minutes to appear; twice the usual duration, else 60 minutes) are defaults a project can
  change in its own CLAUDE.md.
- D6. Case 4 loosens the readers, not the rules: history already holds the spaced form, and the reports must read it.
- D7. Taken from the orchestrator's peer message under D49 as story AC-9 (change record in the story).
- D8. The optional README lines from `.context/archive-worktree-status-view-daily/0001-*.patch` are not carried:
  their content is already in `docs/reference.md` ("Daily use", lines 701–715), checked against
  `scripts/status-view.py` (lock message line 151, stale banner line 1438, header line 1444, Ctrl-C at 1542).

## 7. Plan

Handover boundary: the merged story. No run is expected to take 45 minutes or more; the full battery is measured
once before the build (§7.0). Actions outside the repository that need the human: none (`auto_watch` is already
`false` on this machine).

**Sources and impact boundary.** Read: the story; CLAUDE.md, AGENTS.md, `.claude/review-gates.md`; the hook's
Gate A branch, `input_field`, `exec_resumed`, the below-floor and no-fingerprint notes; the hook suite's payload
builders; `scripts/ledger-metrics.py` grammar and `parse_curve`; `loop-usefulness.py`'s `parse_counts`;
`/workflow-init` 2.1, 2.1a, 2.14; `process-pr-review` Steps 1, 2 and 6; `todos.md` rows named above; the kit-044
archive and transcript; the field repos' curve lines (read only). No third-party library API is used: the code is
POSIX shell and the Python standard library, so no Context7 lookup applies; the codebase-memory facts come from the
installed 0.9.0 binary's own help output. Impact: the hook's Gate A count (fewer calls credited), the gate rules
text, two reports' parsing, three prompt texts and their templates. Not touched: Gate B, the fingerprint, CI.

**7.0 Baseline.** Run the quality battery once on the branch head before code changes; record its duration. If it
takes 15 minutes or more, every later full run is announced to the orchestrator first.

**7.1 Hook (case 1).** Add the pass-file check to the Gate A branch; update every item of §2's prose inventory,
comments and exact-text expectations included; add the reference entry; change the suite's
`execp` and any other counted exec payload to name and create a complete pass file. New section, each case under
`sh` and `dash`, and the jq-free runner where named:
- instruction naming no findings file (the kit-044 shape) → not counted, note "names no findings file"; must fail
  on 0.44.0's hook;
- named file missing → not counted; file without terminator → not counted; count mismatch → not counted; a prose
  line in the body → not counted; symbolic link to a complete file → not counted;
- complete file with two findings → counted; `NO FINDINGS` file → counted;
- an unlabelled old cycle's complete file named beside the labelled current target, which is missing → not counted;
  two different labelled paths → not counted; a labelled absolute path to this checkout's file → counted; an
  absolute path into another directory, with a complete namesake here → not counted, note "findings file elsewhere";
- jq-free: complete file → counted; no findings file → not counted; a `\u`-escaped path → not counted; a resumed
  call with a complete file → counted (the existing jq-free regression, updated);
- with jq, a resumed call (`sessionId`) with a complete file → still not counted (0.40.0 rule kept);
- awk faults: Gate A no longer counts (update the existing cases).
Verify: hook suite green under `sh` and `dash`; the new "names no findings file" case fails against 0.44.0's hook.

**7.2 Rules (case 1).** Add the sentence to both copies; trim the same bytes elsewhere; list each trimmed sentence
with its fate. Verify: checks 4i and 4j.

**7.3 Reports (case 4).** Change `parse_curve`/`parse_model`; add one case per suite with the kit-044 line and one
with `gpt-6-astra per $CODEX_HOME/config.toml`, asserting a parsed curve in `ledger-metrics` and a determinable
listing in `loop-usefulness`. Verify: both suites green; both new cases fail on 0.44.0's script; a read-only run
of `loop-usefulness.py` in sfx-time-tracking-dashboard and infinite-portfolio-canvas shows fewer unparsed lines
than the orchestrator's 88 and 172 (numbers recorded in the PR body).

**7.4 Prompts (cases 2, 3).** 2.14 paragraph and row field; AGENTS.md sentence; CLAUDE.md and 2.1 paragraph;
`process-pr-review` clause; `todos.md` identity row. Each prompt change checked against `docs/prompt-standards.md`.
Verify: checks 4e and 4g (size); and, since no check compares CLAUDE.md with its template, the new paragraph is
taken from each with `grep -F '**Waiting on external work.**'` and the two lines compared with `diff`.

**7.5 Release.** Version 0.45.0 in the plugin manifest (and marketplace entry if it carries one), CHANGELOG,
`docs/reference.md`, README if it names a changed behaviour, `todos.md` rows (AC-4). Verify: full quality battery;
`check-version-bump.sh main` after the commit.

**7.6 Gate B, PR, review, merge.** Ponytail pre-review; Gate B (two branches per pass, floor 3); PR with the file
list checked against AC-8; `process-pr-review`; squash-merge with an own body; main CI green, with §4's wait rule.
