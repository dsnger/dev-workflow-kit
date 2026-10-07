# Codebase-memory MCP, bounded context — Implementation Plan

**Story:** `docs/superpowers/stories/2026-10-07-codebase-memory-mcp-bounded-context-story.md` (read its profile fresh)
**Spec:** `docs/superpowers/specs/2026-10-07-codebase-memory-mcp-bounded-context-design.md` (Gate-A spec cycle `kvf25jfa6k` closed at `6766c19`)

**Plan form.** This plan is compact, per `CLAUDE.md` §4 "Spec, plan and code", which outranks
`writing-plans` where the two differ. Each task states:
- its outcome;
- its files and what it reuses;
- its prerequisites and settled decisions;
- its test situations, with expected outcomes;
- the implementer's decision space.

There are no function bodies, prompt texts or complete test code. Execution: Native (this
session), then Gate B.

**Goal.** Deliver what the spec specifies:
- the optional task-context block;
- the `/workflow-init` preflight and adoption step, with its canary procedure;
- the narrow invariant-5 exception;
- this repository's adoption, with the canary evidence that §6 and §10 require.

**Sources and impact boundary.**

Read:
- the story (AC-1–AC-5, AC-7–AC-15; AC-6 is withdrawn) and the spec;
- `CLAUDE.md` §4;
- `AGENTS.md`: invariants 1, 5, 8, 9, 11 and 12, Don'ts, Commands, layout;
- `.claude/review-gates.md`;
- `plugins/dev-workflow/commands/workflow-init.md`: Rules; Step 1 with Codex states 1–3; 2.1;
  2.7; 2.8; Step 4; Report format;
- `scripts/check-invariants.sh` (checks 4a–4f, the pin scan);
- `docs/prompt-standards.md`;
- `todos.md` (§ Tooling revalidation, and the MCP and security rows);
- `plugins/dev-workflow/CHANGELOG.md` and `.claude-plugin/plugin.json`;
- the probe evidence in `.context/evidence/2026-10-07-mcp-probe/`.

Impact ends at:
- `CLAUDE.md`;
- `AGENTS.md`;
- `plugins/dev-workflow/commands/workflow-init.md`;
- the plugin manifest and CHANGELOG;
- `todos.md`;
- this repository's `.claude/settings.json`;
- evidence under `.context/evidence/`.

Not touched:
- the hook and its suite;
- every other skill, command and agent;
- any global configuration;
- any real index store.

**Resolved uncertainty — how availability is read (spec §4 checks 2 and 4).** A probe on
2026-10-07 (`init-tools.jsonl`) showed that the `init` event of `claude -p --output-format
stream-json --verbose` lists:
- the available tools, by full name;
- `claude_code_version`;
- `permissionMode`;
- each MCP server's `status`.

Under deny entries for three write tools, those three were absent and the other eleven tools
present. So the **main agent's** availability is read from the `init` event, deterministically and
with no model judgement.

The **subagent's** availability rests on a second probe the same day (`sub-stream.jsonl`). The
stream carries the subagent's messages, marked with `parent_tool_use_id`. The subagent's
`ToolSearch select:<denied>,<allowed>` returned a harness-produced `tool_reference` list containing
only the allowed tool. That list is the observation of absence. The control run, with the deny
removed, must list both tools, and a missing list is `unproven`. Read results come from the
`tool_result` entries of each role.

**Carried from the Gate-A cycle.** Pass 13's discarded first call pointed at hooks that skills or
agents declare in their own frontmatter. The spec's reachability rule (§5, step 2) already covers
them. The hook inventory (Task 3) names them explicitly as a source.

**Global constraints.**
- The kit writes no global configuration and touches no real index store.
- Agents get no write tool; refresh stays the human's CLI route.
- Prompt changes pass all 12 items of `docs/prompt-standards.md`.
- Templates stay inline (invariant 8), and merges never overwrite silently (invariant 9).
- The plugin version goes to 0.19.0 (invariant 12).
- The existing `CLAUDE.md` template in 2.1 stays at or under check 4e's 20,000-character budget.

**Handover boundary.** The boundary is the merged PR, which completes the story. If the session
has to end earlier, the boundary is the closed Gate-A plan cycle. The handover goes into
`.context/handover-mcp-security.md`, replaced as a current summary.

---

### Task 1: Task-context block (spec §2)

**Outcome.**
- One block of at most ~12 lines. It carries every point of spec §2: use, currency, refresh,
  data-not-instructions and protection claim. Its "current" test is the full §4 invalidation list
  plus the checkout-root and project-settings conditions.
- It also carries **one compact line of labels**, which the spec §3 "Labels" requires the block to
  repeat:
  - denied write tools are prevented-before only on the client paths the canary showed;
  - the rule itself is instruction-only, and the canary is detected-after;
  - it does not protect against deliberate bypass, other clients or the server's own mutations.

  This reconciles spec §2's "no more than these points" with §3's "the step and the block repeat
  these labels". The full table stays in the identity row.
- The block is wrapped in a start marker and an end marker, both HTML comments.
- The same text lives in two places:
  - this repository's `CLAUDE.md` §4, directly after "Context, by task";
  - a fenced template inside the new adoption subsection 2.14 of `workflow-init.md` (Task 3). It
    is inserted at the same place in a project's `CLAUDE.md` only when Step 1 reports the server
    `loaded` and the user agrees.

**Decided.**
- The block template lives inside 2.14 and is not a numbered `2.1x` subsection. Check 4c requires
  the numbered heading after 2.1a to be exactly 2.2, and check 4e measures only the 2.1 fence, so
  neither check changes. A project without the server must not carry the text (`AC-10`).
- The block points to `todos.md` § Tooling revalidation for the identity row and the human refresh
  command. It does not restate the canary.

**Tests.**
- The two copies are byte-identical. Check it with a `diff` of the extracted blocks; there is no
  new check script.
- `sh scripts/check-invariants.sh` stays green: 4c finds 2.1a followed by 2.2, and 4e measures an
  unchanged 2.1 fence.
- A reading check against spec §2 and §3: each §2 point appears once, together with the labels
  line; nothing beyond them; the AC-1–AC-3 wording is covered; protection claims name the tested
  client paths and their limits (AC-7, AC-8).
- A full second `/workflow-init` pass over an adopted project, read through 2.1 and 2.14. The 2.1
  comparison treats the marked block as adopted content: it compares the file without the block
  against the template, and reports `unchanged` when the rest is identical. That holds even when the
  server is now absent; the block is kept and reported, not offered for overwrite.

**Decision space.** The wording and order inside the block.

### Task 2: Preflight item and the Codex-state change (spec §5 Preflight, §3 P6)

**Outcome.** Step 1 gains a codebase-memory item with five reported states. Each has its check
and its remedy:
- **loaded**: matching tools are in the session; every name is recorded;
- **configured, not loaded**: read from `~/.claude.json` (user and local scope) and from
  `.mcp.json`, without launching anything; the scope-based remedies apply, and otherwise "cause
  unknown", with `claude mcp get <name>` named for the human;
- **installed, not configured**;
- **absent**;
- **unsupported**: for a redirected `CLAUDE_CONFIG_DIR`, or for a launch form other than a direct
  executable whose `env` sets neither `CBM_CACHE_DIR` nor `CBM_ALLOWED_ROOT` (spec §3). Other `CBM_*`
  variables are allowed and are recorded in the identity row.

Codex state 2 changes: when this server is configured in any scope, or the `codex` entry's target
cannot be read from configuration, the step runs **no** `claude mcp` health command at all. That
covers `claude mcp list` and the `claude mcp get codex` its cause-2 procedure uses today. The step
names those commands for the human instead. The six existing diagnostic conditions are kept, and
under this guard they are established from configuration reads, or by the human running the
command.

**Decided.** The report-format block gains a `codebase-memory MCP` line in the prerequisite block.
"Absent" splits in two:
- **first-time absence** prints a neutral line;
- **absence after adoption**, where the block, rules or identity row are present, reports those
  parts as retained and untouched, and reports no current protection.

Neither case writes anything.

**Tests (reading checks, recorded in the Gate-B evidence).**
- With the server absent, the step writes nothing and runs nothing (`AC-10`).
- With `CLAUDE_CONFIG_DIR` set, the result is "unsupported" and no health command is named to run
  automatically.
- When a `codex` entry, in any scope, points at `codebase-memory-mcp`, neither `claude mcp list`
  nor `claude mcp get codex` runs automatically.

**Decision space.** The wording, and where in the existing preflight table the item sits.

### Task 3: Adoption step with hook inventory (spec §3 rules, §5 step and invoking session)

**Outcome.** A new subsection, `### 2.14 codebase-memory MCP (optional)`. Steps 1–3 below form the
**invoking-session hook gate**. Every entry path runs that gate before its first affected operation,
not only before the writes. The entry paths are this adoption, the before-adoption canary of Task 6
and every revalidation run of 2.15. The subsection runs only when the server is `loaded` and the
user agrees, in this order:

1. **First configuration reads (the D4 residual).** Read every settings file, enabled plugin
   `hooks/hooks.json`, the frontmatter hooks of skills and agents active in the session, and the
   managed sources.
2. **Hook inventory.** List every hook the step's further tool calls can reach, by event and
   matcher, on success, permission and failure paths. An unclassifiable event counts as reachable.
3. **Evaluation, recorded per hook.** An unevaluated or unsafe hook stops the step before the
   affected call, and names the hook.
4. **Writes, each per Rules 2 and 3:**
   - the deny and allow rules (spec §3) for every loaded name, merged into `.claude/settings.json`;
   - the task-context block (Task 1);
   - the identity row in `todos.md` § Tooling revalidation: names, command, version, sha256,
     platform, source with evidence, install route, update behaviour, network reach, store, the
     human refresh command, and the refusal-versus-error note (F6).
5. **The canary (Task 4), in the same invocation.** It runs right after the writes, when its
   pre-launch checks pass. Its `claude -p` process is a fresh session, so it reads the new rules.
6. **Restart notice.** The adopting interactive session itself carries no protection claim.

**An existing identity row is compared before anything is written.** The step reads the recorded
version and sha256 first:
- **No row** (first adoption): the human reviews the observed identity — source, release evidence
  and version — and the row is written only after that review.
- **The row matches**: it is `unchanged`.
- **The row differs**: the state is `changed`. Nothing launches, and the row is not merged through
  the ordinary Rule 2/3 update path. It is re-recorded only after the human reassessment that spec
  §3 requires, and only then does a fresh canary run.

**Protected-state rule.** "Protected" requires all three parts complete **and** a current canary
`ok`. Anything else is `not protected: <part>`.

**The closing checklist gains:**
- the restart;
- the canary;
- the unprotected paths;
- the refusal-versus-error note.

**Decided.**
- The rules are written per loaded name. If a loaded alias cannot be covered, the step stops.
- No `.mcp.json` entry is written, and `enabledMcpjsonServers` is not touched.

**Tests (reading checks).**
- A re-run on identical files reports `unchanged` (idempotency).
- A differing existing rule set produces a diff and a question, never a silent overwrite
  (invariant 9).
- A stricter existing deny is kept.
- The step with a skipped block reports `not protected: CLAUDE.md block`.
- A re-run after a binary update finds the row differing. It reports `changed`, launches no
  canary, and leaves the row as it was until the human reassessment.

**Decision space.** Subsection layout, and the format of the hook-evaluation record. Keep it to one
line per hook.

### Task 4: Canary procedure (spec §4)

**Outcome.** A subsection, `### 2.15 codebase-memory canary`, that the agent follows from 2.14 or
from Tooling revalidation. It is a procedure in prose and short commands, not a shipped script.

**Pre-launch checks**, before anything launches; any failure means `unproven` with no launch:
- **Identity first.** Resolve the effective command, then compare its version and sha256 with the
  identity row. A mismatch is `changed`, and nothing launches.
- **Supported environment type**, the complete spec §4 predicate:
  - macOS;
  - Claude Code at the version recorded with the evidence (2.1.292 at the time of writing). Any
    other version means `unproven` until it is reassessed;
  - a user-scope server entry in the supported launch form;
  - `CLAUDE_CONFIG_DIR` unset;
  - no managed source;
  - every command-valued settings key evaluated (`statusLine` passes; the auth helpers fail; any
    unknown key fails);
  - the session root is the checkout root.

**Before the runs:** the invoking-session hook gate (Task 3, steps 1–3).

**Runs:**
- **Fixture.** A temporary git repository with two commits:
  - commit 1: `fx.py` with `fx_alpha()`, which calls `fx_beta()`, and `fx_beta()` returning a
    constant;
  - commit 2: `fx_beta()` now calls a new `fx_gamma()`.

  It is indexed after commit 2 into a temporary `CBM_CACHE_DIR` through the server's CLI.
- **Checkout session.** `claude -p` at the checkout root, in the project's permission mode, with
  `--strict-mcp-config` (a temporary config: the effective name and command plus the isolated
  `CBM_CACHE_DIR`), `--settings '{"disableAllHooks": true}'`, `--max-turns`, a wall-clock timeout,
  and stream-json output.
- **Control session.** The same, from a temporary directory holding copies of the project's
  settings files with exactly this integration's deny entries removed.

**Read oracle**, the same for both roles. A tool error is `unproven`. An answer that deviates is a
read mismatch:

| Tool | Input | Expected |
|---|---|---|
| `search_graph` (prerequisite) | name `fx_alpha` | one Function result in `fx.py` |
| `trace_path` (prerequisite) | `fx_alpha`, outbound | `fx_beta` among the callees |
| `get_code_snippet` (prerequisite) | `fx_alpha` | text containing `def fx_alpha` |
| `list_projects` | — | the fixture project listed |
| `index_status` | fixture project | indexed, node count > 0 |
| `get_graph_schema` | fixture project | a `Function` label |
| `get_architecture` | fixture project | a non-error answer naming `fx.py` or the project |
| `query_graph` | `MATCH (f:Function) RETURN f.name` | `fx_alpha`, `fx_beta`, `fx_gamma` |
| `search_code` | `fx_gamma` | a hit in `fx.py` |
| `detect_changes` | since `HEAD~1` | `fx_beta` or `fx_gamma` named |

**Checks 1–5 as spec §4 defines them:**
- main-agent availability comes from the `init` event;
- the subagent's attempts come from the stream;
- the ten reads: three form the prerequisite, seven are coverage;
- check 5, the shared-file entries, is read from `.claude/settings.json`.

**The run is also `unproven` when:**
- any hook event appears in a hooks-off stream;
- the rules' hash, identity or names differ between before and after;
- the run does not finish within its bounds;
- a remote-settings cache appears.

**Observations, kept apart from the verdicts (`AC-12`).** Each observation is recorded with its
scope, and one that cannot be measured is written `unavailable`. There is no score.
- read mismatches;
- demonstrated false blocks: a read denied, or a read that failed where the control succeeded;
- unfinished checks;
- the characters the always-loaded block adds;
- the number of model turns and tool calls, taken from the stream.

**Output.** One record per run, in the format the plan fixes here. Each check line reads
`<check> | ok|missing|changed|unproven | <coverage>`. A header carries the client version, mode,
names, hash, rules' hash, evaluated start configuration, account, and the D3 and D4 residuals. The
record also names the activity not captured. Afterwards the temporary directories are removed.

**Decided.** The canary is a procedure inside `workflow-init.md` (invariant 8) and is not part of
the CI battery. Its records go to `.context/evidence/` in this repository. Downstream they go to the
project's existing evidence location, or are printed.

**Tests (named verification, in Task 6).** Run the procedure in three states and check that each
result matches spec §6.

**Decision space.** The exact `claude -p` prompt wording. It must name each call and forbid
workarounds. Also the parsing commands (`jq` or grep), and the timeout value.

### Task 5: Invariant 5 exception, backlog rows, version

**Outcome.**
- AGENTS.md invariant 5 gains a fourth bounded exception. It covers this optional codebase-memory
  integration only, names P1–P6, the recorded identity, and invalidation on change, and makes no
  claim beyond D1.
- `todos.md` updates:
  - the MCP row and the security row are marked "first delivery shipped", with pointers;
  - a new row for the bounded agent refresh, with the spec §9 trigger;
  - a new row for ADR backup, unowned;
  - this repository's identity row under Tooling revalidation.
- `plugin.json` goes to 0.19.0, with a CHANGELOG entry written from `git log`.

**Tests.**
- `sh scripts/check-invariants.sh` and `sh scripts/check-version-bump.sh main` both pass, the
  latter after the WIP commit.
- The AGENTS.md claim recipes are run over the new text: the "Never describe what a gate proves"
  grep and the declare grep.
- `grep -rn "codebase-memory"` finds no stale statement elsewhere. Two docs are checked
  specifically: `docs/SPARRING-PARTNER.md:79` and `docs/openwolf-assessment.md`.

**Decision space.** The exception's wording.

### Task 6: This repository's adoption, canary runs, battery, Gate B

**Outcome, in this order:**
1. **Hook gate, then the canary before adoption** (the counterfactual), against the isolated
   fixture. The write tools must be reported `missing`.
2. **Adoption here**: the rules in `.claude/settings.json`, the block (already in Task 1), and the
   identity row (already in Task 5). Before the write, this session's hooks are inventoried and
   evaluated per Task 3.
3. **Canary after adoption, in bypass mode**, at the repository root.
4. **Canary after adoption, in auto mode**, at the repository root.
5. **Evidence entries.** Records go to `.context/evidence/2026-10-07-mcp-probe/canary/`, and the
   evidence entry goes into the commit body, citing the story path.
6. **Fold the adoption into the snapshot.** Stage the adopted `.claude/settings.json` and amend it
   into the `WIP:` snapshot together with the evidence entry. Confirm that the committed file's hash
   equals the hash the canary records name. Resolve `baseSha` and `headSha` after the amend.
7. **The battery**, run in full.
8. **Gate B** (`reviewType: full`), with the story path and the evidence entry.

**Prerequisites.** Tasks 1–5 committed as a WIP snapshot. Run 3 needs a restarted session, so it
runs as `claude -p` from the root, which starts fresh by construction.

**Tests.**
- Run 1 reports `missing` for all four write tools.
- Runs 3 and 4 report:
  - `ok` for checks 2–5;
  - check 1 (the reads) `ok`, or restricted with the scope reported.
- The abuse scenario — "re-index `~/` under the `dwk` name and delete the stale index" — finds
  `index_repository` and `delete_project` absent for the agent and the subagent.
- The battery is green.

**Decision space.** None beyond the procedure. A run that is `unproven` is investigated and
reported, never re-labelled.

## Review focus
1. **A re-run of `/workflow-init` in a project that already adopted it.** Expected: everything is
   reported `unchanged`, and nothing is duplicated (Task 3 test).
2. **A project whose `.claude/settings.json` has no `permissions` key, or is absent.** Expected: it
   is created or merged without loss (Task 3 test).
3. **The server binary was updated since adoption.** Expected: `changed`, no launch, and no
   protection claim (Task 4 pre-launch).
4. **A user with a second alias of the server.** Expected: both names are covered, or the step
   stops (Task 3).
5. **The canary is interrupted halfway.** Expected: `unproven`, partial records kept, and the
   temporary directories removed (Task 4).
