# Reference

Everything that is true about the kit but not needed to get going. The step path is
[`setup.md`](setup.md); the per-situation lists are [`getting-started.md`](getting-started.md).

## Components

| | |
|---|---|
| `dev-workflow:intake` | skill. A raw idea or voice transcript (German or English) becomes a reviewable story. Captures WHAT and WHY; refuses to invent the parts that aren't there. Also amends an approved story or spec with a change record that accounts for every earlier condition. |
| `dev-workflow:ticket` | skill. A bug or improvement that stays inside an approved commitment becomes a ticket file: evidence, the commitment it stays inside, and the brief a coding agent fixes from. `list` shows the ones waiting for triage, information or a start. A change to a commitment is handed to `intake`. |
| `dev-workflow:harden-finding` | skill. Hardens one review finding with a lint rule (rung 2) or a test (rung 4) and logs it in the ledger. The rungs and the no-row cases are in the [skill file](../plugins/dev-workflow/skills/harden-finding/SKILL.md). |
| `dev-workflow:sparring` | skill, invoked by name only, in a chat you open for advice. Investigates read-only, checks agent reports against the current files, and drafts bounded prompts for a coding agent to run elsewhere. It advises; it does not implement, commit, or run review gates. |
| `/dev-workflow:process-pr-review` | command. Validates PR bot comments against the code and your invariants, replies to each, fixes regressions, tracks pre-existing issues, and names a bot that left no review on the current head (a green status check alone is no proof). |
| `dev-workflow:finding-triage` | agent. Read-only, fresh context, judges whether one PR-bot claim is actually true of the code. Used by the PR processor; never counts as a review gate. |
| `/dev-workflow:workflow-init` | command. Scaffolds the per-project files, then interviews you to write `AGENTS.md`. Re-run it after a kit update: it shows the diff per file, and for a `CLAUDE.md` §5 pointer or a `.claude/review-gates.md` from an older kit edition it recommends the current template. |
| `/dev-workflow:claude-init` | command. Writes one `CLAUDE.md` of general working rules and nothing else: no review gates, no other files. An existing `CLAUDE.md` is never overwritten; you get a proposal instead. Creating the file needs an already-installed Python 3. |
| codex-gate hook | non-blocking reminders that count Gate A and Gate B passes. At a commit attempt it compares a fingerprint of the effective index plus the included worktree content, as of the hook's invocation (a deliberate superset of any one commit's payload, so the gate errs toward firing) with the one recorded when a Gate-B call was credited. A match says the content is unchanged since that credit, not that Codex read it. After a context compaction it reprints the rules-file pointer and the cycle state. Always exits 0. |

## Prerequisites

- **A git repository.** `/workflow-init` stops without one (`git rev-parse --show-toplevel`
  must succeed in the project).
- **Claude Code 2.1.212 or newer.** The version is needed for
  `CLAUDE_CODE_MCP_AUTO_BACKGROUND_MS` (below).
- **Node with `npx`.** The `codex` and `context7` entries `/workflow-init` writes into
  `.mcp.json` launch their servers with `npx -y <pkg>@<version>`.
- **superpowers.** Not vendored. The workflow's middle is its skills; without it, `intake`
  hands off to nothing and Gate A never fires.
- **Codex.** See the next section.
- **`gh`.** Optional; only `/dev-workflow:process-pr-review` uses it.
- **Python 3.** Only `/dev-workflow:claude-init` needs it, to create the file.

`/workflow-init`'s preflight block reports the git repository, superpowers, Codex and `gh`
(as `ok`, `MISSING`, `NOT LOADED` or `absent`, each with its fix), so a wrong guess there
costs one re-run. It does not check the Claude Code version, Node or Python; check those
yourself (`claude --version`, `npx --version`, `python3 --version`).

### Codex

Codex is the reviewer behind both gates. It needs the Codex CLI, authenticated with an
OpenAI account: a real external dependency, not just the `.mcp.json` entry
`/workflow-init` writes for you. It also needs a Codex MCP server that exposes `exec` and
`review`. The gates key on those two tool names, and the pass counters additionally skip
routed calls whose result the hook reads as failed, backgrounded, or yielding no usable
text; a result it can read but not interpret still counts, and normally says so once. For
Gate B the counter also reads the request: a `spec` and a `quality` call on the same
40-character lowercase `baseSha` and `headSha` count as one pass, and a lone branch counts
as none.

Use the `mcp-codex-dev` server `/workflow-init` pins, which has both tools. The official
`codex mcp-server` is a different server exposing `codex` and `codex-reply`, neither of
which can be attributed to Gate A (reviews text) or Gate B (reviews a diff). With it
connected, no pass ever counts and Gate B reports "not run" forever (the hook says so,
once).

Both gates have Codex write its findings to a file under `.context/codex-reviews/` and
reply with a one-line summary, because a long finding list returned inline can come back
cut off, and a cut between findings looks exactly like a short list. Claude Code limits
MCP tool output to 25,000 tokens by default; `MAX_MCP_OUTPUT_TOKENS` raises that, which
is worth trying as a secondary mitigation but is not the fix. It moves the ceiling rather
than removing it, and it applies only to tools that don't declare their own text limit
via `anthropic/maxResultSizeChars`; whether `mcp-codex-dev` declares one is not
established here. The file protocol is what actually keeps findings out of the response.

After `/workflow-init`: restart the session so the project servers from `.mcp.json` are
approved and loaded, and confirm both `mcp__codex__exec` and `mcp__codex__review` are
available. Re-running `/dev-workflow:workflow-init` shows
`codex MCP ok (pinned mcp-codex-dev@<version>)` once they are. The `codex` entry in
`.mcp.json` plus the logged-in CLI are what connect the reviewer. The
`~/.codex/config.toml` block the command prints (home directory; it never writes there)
is optional: an example shape with `[mcp_servers.<name>]` and `<pkg>@<exact-version>`
placeholders that gives the Codex reviewer your own MCP servers. Adapt and merge it only
for a server the reviewer should reach, with real names and pinned commands.

## Background calls

`CLAUDE_CODE_MCP_AUTO_BACKGROUND_MS` is strongly recommended, and the primary defence
against a gate call being auto-backgrounded. Claude Code moves a long MCP call to the
background at a threshold (120 s by default) and fires `PostToolUse` at that moment,
carrying the harness's own notice instead of any Codex result; the eventual real
completion fires no second `PostToolUse`, so the hook never sees the review's outcome.

Requires Claude Code 2.1.212 or newer. Set it in the environment Claude Code is launched
from. It is read at process start, so exporting it inside a tool shell leaves the running
session unchanged and you must restart Claude Code. Use `0` to disable
auto-backgrounding, or a positive value that exceeds your longest expected gate call; a
positive value shorter than the call still backgrounds it.

```sh
export CLAUDE_CODE_MCP_AUTO_BACKGROUND_MS=0   # or e.g. 900000, exceeding your longest gate call
```

Without it, both outcomes are possible, and only one is safe. While the harness notice
keeps the wording the hook recognizes, the backgrounded pass is discarded. That is
correct, but re-running it is not simply a retry: the original call may still be running
and can still write into the findings slot afterwards, leaving a correctly terminated
file from the wrong run that no downstream check can detect. Stop that task by the id in
the tool result, or await it if the result carries none, and delete the findings slot
first. The hook's own backgrounding message carries that procedure; follow it there
rather than from memory. If that harness prose changes past the anchors the hook
matches, the notice goes unrecognized and the call is handled like any other result:
credited as a pass, or recorded as half of one for a single branch, where the request
and state checks allow it, with a disclosure that says this was done without inspection. That second outcome is why this setting is the defence rather than the hook:
the hook fails safe against today's wording, not against every future one.

`CLAUDE_CODE_AUTO_BACKGROUND_TIMEOUT_MS` appears in the 2.1.220 string table but was
never exercised here, so it is deliberately not documented. Naming the wrong one of two
similar variables is this project's own docs-drift class.

## workflow-init

What `/dev-workflow:workflow-init` does, in order:

- **Preflight.** It prints a status block before writing anything: git repository,
  superpowers, Codex (`not configured` / `NOT LOADED` with the cause / `ok`), `gh`,
  `AGENTS.md`, stack, existing targets, and the two optional companions (codebase-memory
  MCP, Ponytail). Only a missing git repository stops the preflight; choosing to set up
  Codex now (see "Without Codex" below) also ends the run so you can.
  For an `AGENTS.md` over 32768 bytes it warns and never trims: by default Codex loads at most
  that many bytes of `AGENTS.md` files in total into its instructions and cuts the rest with
  only a log warning; `project_doc_max_bytes` in the Codex config raises the budget. Source: Codex `codex-rs/config/defaults.toml` and
  `codex-rs/core/src/agents_md.rs` at tag `rust-v0.162.1`, and
  [the Codex AGENTS.md guide](https://developers.openai.com/codex/guides/agents-md)
  (checked 2026-10-19). The count covers the root file only; nested `AGENTS.md` files share
  the same budget.
- **Scaffolding.** Per file: missing, written; identical, `unchanged`; present and
  different, it shows the diff and asks overwrite / merge / skip; additive files
  (`.gitattributes`, `.mcp.json`, `.claude/settings.json`) are merged. It writes
  `CLAUDE.md` (the discipline rules, with §5 as a pointer), `.claude/review-gates.md`
  (the gate rules), `docs/hardening-log.md`, `docs/hardening-taxonomy.md`,
  `docs/prompt-standards.md`, `docs/pr-review-bots.md`, `todos.md`,
  `.github/workflows/quality.yml` (with `TODO(stack)` blocks), the pinned `codex` and
  `context7` servers in `.mcp.json` (each added only when absent; an existing entry of
  that name is left as it is, so check it yourself), and `.context/codex-gate.on`, the
  marker that makes the hook speak in this project. Commit the marker.
- **Secret deny rules (2.17).** It merges `permissions.deny` entries into
  `.claude/settings.json` that stop Claude Code from reading every name starting `.env` (`.env`,
  `.env.local`, `.envrc`; except `.env.example`), `*.pem`, `*.key`, `secrets.*` at any depth, `secrets*` under
  `./.context/`, the private keys `id_rsa`, `id_ecdsa` and `id_ed25519` at any depth, and
  everything under `~/.ssh/`. When entries are missing from an existing file it asks before
  adding them. Observed with Claude Code 2.1.302 in a fixture repository: the Read tool was
  refused for a sample file of every entry except `id_rsa`, which was not tried (a `~/.ssh/`
  path was refused even when absent), `cat .env` in Bash was refused, and `.env.example` was
  readable at any depth. **What they do not stop**, as observed in the same probes: `grep -r` over the directory, and a script that opens the
  file itself (`python3 -c 'open(".env")'`). They are Claude Code settings, so other clients
  (Codex) do not read them; and per the Claude Code permissions docs, `./` is relative to the
  session's working directory, so a session started elsewhere is not covered by the
  `.context/` entry. These
  rules lower the chance of an accidental read; they do not make a secret in the repository
  safe. Rules for a different name (`id_dsa`, `credentials.json`) are yours to add.
- **`AGENTS.md` interview.** It asks in batches of 2 to 4 questions (what the project
  is, architecture, key invariants, don'ts, `## Commands`), shows each section before
  moving on, writes `TODO — not yet decided` where you don't know yet, and writes the
  file only after you approve the whole text. A `## Commands` row is filled only with a
  command it ran in that session and saw exit 0.
- **Closing checklist.** It ends with the items it deliberately did not scaffold: the
  battery, baselines, custom lint rules, branch protection, Codex, superpowers, the
  prompt-standards date, and codebase-memory if found. It also prints the optional
  `~/.codex/config.toml` example block (see Codex above).

**Without Codex**, the preflight asks whether to set it up now; on yes it stops and lets
you. On "not now" `/workflow-init` degrades honestly instead of scaffolding gates that
can't run: it writes `.context/codex-gate.off` to silence the hook and marks CLAUDE.md §5
`INACTIVE` with the re-enable path. Set up Codex, then delete `.context/codex-gate.off`
before the first feature. There is deliberately no same-model fallback reviewer:
explicitly gateless beats implicitly self-reviewed
([why](coding-workflow.md#the-two-gates-and-why-independence-is-the-point)).

### What stays yours

Five things are left to you on purpose. A plausible default nobody verified is worse than
an honest gap ([reasoning](coding-workflow.md#adapting-it-to-another-project)):

- **Quality-battery tools.** The plugin names the roles (typecheck, lint, dead code,
  duplication, tests), never the tools. You wire them into one command. Add a tool only
  once you have run it and seen it catch something real.
- **Baselines.** Generated from your repo, in their own commit.
- **Custom lint rules.** Two ship as examples only
  ([`examples/eslint-rules/`](../plugins/dev-workflow/examples/eslint-rules/)); they
  encode one stack's invariants and won't transfer.
- **Branch protection.** A repo setting, not a file; worth doing once the battery runs.
- **`AGENTS.md`.** Your invariants. Both gates check against it, so a generic one makes
  "check against our invariants" read as satisfied when nothing was.

## CI and branch protection

The `quality` job runs the same command as your local battery, on a pull request or a
push to main, so its first green run is on your first PR. Make `quality` a required
check and turn on "Require branches to be up to date before merging": two PRs can each
be green alone and red together. Limit: GitHub makes you update the branch; the update's
CI run is what checks the combination.

## PR review bots

`docs/pr-review-bots.md` lists the bots you enabled and where each one posts (inline,
summary, both, or `inconsistent`), sorted into the three routing lists
`/process-pr-review` reads: wait for, process opportunistically, ignore. CodeRabbit
auto-reviews only PRs whose base is the default branch unless its configuration lists
the other base under `reviews.auto_review.base_branches`.

## Optional companions

Ponytail and codebase-memory are skipped when absent, and nothing fails. Context7 is
added by `/workflow-init` when its entry is missing; only its lookups have a fallback.

- **Context7** (MCP, library docs). `/workflow-init` writes it pinned into your
  `.mcp.json`. The gate rules require a Context7 lookup, for the version you pin, before
  a spec, plan or change that uses a third-party library API. Without third-party
  dependencies the rule does not apply, and when Context7 is unavailable, or your pinned
  version is not indexed, the library's own material for that version stands in (docs,
  installed type declarations, a probe with the pinned binary). It runs without an API
  key, rate-limited; `CONTEXT7_API_KEY` in your own environment raises the limit. Off:
  remove the `context7` entry; the fallback then applies to every lookup.
- **Ponytail** (`ponytail@ponytail`). A lazy-senior-developer mode. Worth it when you
  want the obvious cuts made before Codex reads a diff. With it installed,
  `/workflow-init` recommends a default mode (`lite` for a large or old codebase, `full`
  otherwise) and writes it as `PONYTAIL_DEFAULT_MODE` into `.claude/settings.json`; the
  gate rules then run `ponytail-review` once on the branch diff before Gate B pass 1,
  listed under "Ponytail pre-review" in the PR body. Not a gate, not a pass, no
  replacement for Codex. Off: uninstall the plugin. The gate rules key on its presence,
  and `PONYTAIL_DEFAULT_MODE` only sets the level Ponytail starts in.

  ```sh
  claude plugin marketplace add DietrichGebert/ponytail
  claude plugin install ponytail@ponytail
  ```
- **codebase-memory MCP.** A code graph for orientation and impact. The kit never
  installs, configures or registers it. When `/workflow-init` finds it loaded and you
  agree, it writes permission rules that deny the server's four write tools and allow its
  reads, adds a task-context block to `CLAUDE.md`, and checks the rules through a canary
  run against an isolated store. Indexing stays yours. Read the result it reports, and
  re-run the canary after any change to the client, the server binary, the permission
  mode, the rules, the start configuration or the account. When you may claim the
  protection, and what it never covers, is in
  [`/workflow-init` 2.14–2.15](../plugins/dev-workflow/commands/workflow-init.md) and the
  block it writes into your `CLAUDE.md`. Off: decline on the first run (nothing is
  written); parts already adopted are removed by hand.

## Updates

```sh
claude plugin marketplace update dev-workflow-kit
claude plugin update dev-workflow@dev-workflow-kit
```

The qualified form is a workaround: the bare name is documented but errors with
"Plugin 'dev-workflow' not found" (CLI 2.1.x). Updates arrive only when the plugin
version is bumped, and a running session keeps the old version until you restart it or
run `/reload-plugins`. The scaffolded files do not update themselves: re-run
`/dev-workflow:workflow-init` in each project and take the changed files from the diff;
for a `CLAUDE.md` §5 pointer or a `.claude/review-gates.md` from an older kit edition it
recommends the current template. A review cycle already running finishes under the rules
it started with.

## The review gates

The binding rules are `.claude/review-gates.md` in your project (CLAUDE.md §5). This
section explains what you see.

**Gate A** sends the text of every spec, and of a plan whose recorded risk is `high`,
to Codex `exec`. **Gate B** sends every non-docs-only diff to Codex `review` after the
battery passes. Docs-only means every staged path is explanatory Markdown under `docs/`,
or `README.md`, `MANIFEST.md`, `todos.md`; `CLAUDE.md`, `AGENTS.md` and anything under
`.claude/`, `plugins/`, `skills/` or `commands/` at any depth are prompts and take the
gate, as does a mixed commit. The hook's own docs-only note is a path heuristic and does
not establish that eligibility. The battery is always owed, with one exception: a timeout in a test the diff did
not touch that passes when run alone is recorded with that evidence, and the green
required CI check on the PR head then stands as the battery evidence. The rules have no
exemption for the commit that adds the scaffolded prompt files; setup step 7 runs Gate B
on it.

**Profile line.** Gate A takes `risk standard|high; security none|standard|high; evidence
<mode>` from the story, where you confirmed it at intake; with no story, Claude derives it
and records the reason. A free-text value is mapped to the nearest closed values, the
stricter where two fit, and the mapping is recorded with the quote. `intake`
proposes both axes and the derived evidence mode with a reason; any change to the mode is
an override that carries its own reason and is logged. The levels accumulate: `battery`
(green), `battery+check` (a check that fails without the change),
`battery+check+verification` (a named verification of the risk path on top of both), and
at security `high` `+abuse-path`: a named abuse scenario and evidence that the control
rejects or contains it.

**Passes.** The prompt asks Codex to report every finding with severity and confidence;
Claude filters to Blockers and Majors for repair and reads the rest. Findings land in
`.context/codex-reviews/gate-a-<spec|plan>-<nonce>-pass-<n>.md` (Gate A) one per line, severity
`BLOCKER | MAJOR | MINOR | NIT`. Minors and Nits are collected, never iterated. The floor
is three valid passes per cycle, a pass with zero findings may close early, and the cap
is the floor plus two, where a remaining Blocker or a cut to an approved commitment goes to
you and the agent decides the rest. From pass 2 on, each pass of
either gate lists the earlier passes' Blockers and Majors, each with its verdict and reason,
and Codex marks each `fixed | not fixed | no longer applies`, a `not fixed` counting as a
finding again unless you declined it or accepted it unrepaired and Codex brings no new
evidence. One cause at several places is reported once, as a class
listing every place. In Gate B the `spec` call
maps each acceptance criterion to the test asserting it, or `none`, and reports a test
that cannot fail. Codex is advisory: Claude arbitrates disputed findings, and a dismissed
finding needs a one-line reason.

**Cap stop.** `⚠ Codex Gate A: pass cap reached (5/5). STOP: a remaining Blocker, or a cut
to an approved commitment, goes to the human` (same for Gate B). Then you answer; otherwise Claude does and
records why. The answer is `close`, or one of delete the mechanism the findings keep
returning to / cut scope / continue, each naming how many further passes it allows (at
least one); the loop resumes on the artifact as your answer leaves it.
`.context/codex-gate.cap-extra` holds the total allowance beyond the base cap for the
cycle, so a second answer adds to the number already there.

**Closing act.** A clean pass at the floor, a zero-finding pass below it, or a cap answer
of `close` runs the closing act: one commit carrying the cycle's record lines, the
ledger-check records, and a `todos.md` row per finding dispositioned `accepted, not
repaired`, so no follow-up is lost. For Gate B that commit takes a non-WIP subject.
Planning starts after Gate A's closing act; Gate A on a plan (risk `high` only) ends with
its own.

**Gate B shape.** Claude makes a plain `git commit -m 'WIP: <subject>'`, a Bash call of its own (gives Codex a
range to read; the hook keeps the cycle open across a commit it recognises as WIP), then
loops `mcp__codex__review` as two calls per pass, `reviewType: spec` then `quality`, on
the same `baseSha` and `headSha`. Invalidation is by content: any change to included
content present when the hook runs, even from a formatter, makes the hook report that it
cannot confirm the reviewed content. What that proves is bounded, and the hook's own
source says so: the current fingerprint matches the one recorded on a credited pass,
which is not evidence that Codex read those bytes; `.context/` and untracked ignored
paths are excluded, and staging counts, because the fingerprint covers the index and
that is what a commit carries.

**The hook's messages.** `⚠ Codex Gate A below floor (1/3)` is the counter, not an
error. `✓ Codex Gate B hook checks passed (<counted>/<threshold> cycle, <fresh> on
current fingerprint)` carries three different numbers: the passes the hook credited this
cycle (one per `full` call or per `spec` + `quality` pair on the same `baseSha` and
`headSha`), the hook's own reminder threshold, and the consecutive credited passes on the
current fingerprint since it last changed. The first is not the calls you made: a single
branch counts only together with its partner, and the hook withholds credit for a
recognized failure envelope, the backgrounding notice, a result it can get no text from,
and a request it cannot read or pair. The third is a streak, not a tally: a pass on a
changed fingerprint restarts it, and an earlier matching pass separated by a different
fingerprint is not counted. None of the three is the floor §5 obliges, and the message
is what the hook checked, not permission to close. The hook counts passes and compares a
fingerprint; it never reads a findings file. Judge each pass from its findings file and
discount an incomplete one yourself, whatever the counter says. If the hook's own
threshold was not met when implementation starts, it says so right then.

## Hook messages

The hook's messages say what happened and what to do next. The possible causes behind five
of them live here.

**No readable result** (`⚠ Gate call returned no readable result`). Two causes produce
this shape, and the tool name cannot separate them: a hooks-API payload change, or a
third-party tool returning empty or non-text content. Such a tool reaches the gates through
a mapping in `.context/codex-gate.tools`, or as a server registered under the default name
`codex`, so an absent mapping does not rule it out. Check the mapping file, and check what
`claude mcp list` shows as the effective server and version, not what `.mcp.json` says:
scope precedence can make a different entry of the same name effective. These checks narrow
the cause; they do not prove it. With a mapping or a third-party server in play, unmap it,
or replace it with a server exposing `exec` and `review`. With the pinned server at its
pinned version, a payload-contract change is the remaining explanation: record your Claude
Code version and report it.

**Counted without inspection** (`ℹ A gate call was classified as countable without the hook
reading its result`). Causes with a check and a fix:
- a pinned-server envelope whose key order or formatting changed: compare the version in
  `.mcp.json` with the server actually serving the tools (`claude mcp list`); pinning it
  back fixes it;
- a reworded backgrounding notice: see [Background calls](#background-calls);
- a broken `awk` or `sed`, which classification requires. Check them by function, not by a
  version flag (`--version` is not POSIX, and BSD `sed` exits nonzero for it on a healthy
  macOS): `printf "x\n" | awk "{print}"` must print `x` and `printf "x\n" | sed s/x/y/` must
  print `y`, each exiting 0.

Causes with no user-side fix:
- a third-party tool whose envelope the hook cannot read. `.context/codex-gate.tools` names
  it only if it is mapped, and a third-party server registered as `codex` needs no mapping,
  so an absent mapping does not rule this out. Unmapping removes the gate; it does not fix
  the envelope;
- a payload the scan refused. Four families land here: past the 1 Mi-unit size bound, past
  the 200-frame nesting-depth cap, structure the scan could not walk, and an ambiguity such
  as a duplicated `tool_response`, `type` or `text` key. Measuring the payload against the
  first two bounds rules them in or out; the other two produce the same message and state
  and cannot be told apart, so record them as unresolved rather than guessing;
- a defect in the hook's parser: the same situation.

For either, keep the payload local and access-restricted. It can contain prompts, absolute
paths, review content, session identifiers and unrelated concurrent call data, so strip
those before showing it to anyone, and never attach it unsanitized to a report. The list is
not exhaustive: unrecognized is the terminal class, so any future unmatched shape lands
there too.

**Credit withheld** (`⚠ Codex Gate B: credit withheld`). The hook could not remove a state
path before counting. `.context/` may not be writable, the path may be a directory or
another non-file, or another writer may have recreated it.

**No recorded fingerprint** (`⚠ Codex Gate B: no recorded fingerprint`). No
`mcp__codex__review` has been credited (a single-branch call waiting for its partner, and a
call whose request was rejected, write no fingerprint by design); the last credit's
fingerprint could not be written or read back; or a non-WIP commit attempt cleared it while
the cycle stayed open. It also appears on a spec or plan commit whose command is more than
`git commit` and its options (a `$(cat <<'EOF' …)` message, a chained `git add`), because
only a plain command is offered the docs-only note. The fingerprint is Gate B's alone: Gate A
passes (`mcp__codex__exec`) are counted by call and never record one.

**Cannot confirm reviewed content** (`⚠ Codex Gate B: cannot confirm reviewed content`).
Usually the working tree or the index changed since the review. Other causes: you only
staged already-reviewed content (the bytes are fine, but the hook cannot tell staging from
editing); the hook was upgraded and the recorded fingerprint uses the older format (see the
CHANGELOG); or the fresh fingerprint could not be computed or stored. A fresh Gate-B pass is
the whole remedy for the staging and post-upgrade cases too. If a fresh pass leaves the
message unchanged, check the worktree and the index first: the fingerprint moves when either
does, staging included, and another hook can stage during the commit attempt. Where neither
changed, the fault is in the machinery, not the code: check that `.context/` and `TMPDIR`
are writable, that a checksum tool (`shasum`, `sha1sum` or `cksum`) runs, that `git status`
works, and that the disk is not full. A store that fails again leaves the hook unable to
confirm a fingerprint, and it may return either fingerprint-state message.

## Per-workspace knobs

The hook speaks only where `.context/codex-gate.on` or the `Cross-Model Review` §5 heading
in `CLAUDE.md` is present (`is_adopted` in
[`codex-gate.sh`](../plugins/dev-workflow/hooks/codex-gate.sh)). If a project of yours
goes unexpectedly silent, check those two first. To silence it for good, delete both; the
skills and commands stay callable by name.

All knobs are files under `.context/`:

| | |
|---|---|
| `codex-gate.floor` | a positive integer; moves the hook's reminder threshold. It does not change the floor the gate rules oblige, which is three valid passes (a zero-finding pass may close earlier). |
| `codex-gate.cap` | a positive integer of at most nine digits (anything else is ignored); the pass count at which the hook starts printing its pass-cap reminder ("STOP: a remaining Blocker, or a cut to an approved commitment, goes to the human") on every gate call and commit attempt. Default: the reminder threshold plus two. A reminder only: nothing is blocked, and whether your review policy has a pass-cap rule is that policy's business. |
| `codex-gate.cap-extra` | a positive integer of at most nine digits (anything else is ignored), written after the cap answer (yours or Claude's): the total allowance beyond the base cap for the current cycle, not an increment. A second answer of "two more" at a cap of 7 is written as `4`, not `2`. The commit that clears the pass counter clears it too. |
| `codex-gate.off` | silences the reminders; classification and state tracking keep running, so re-enabling lands on counters carrying the same semantics as gate-on, which is not the same as evidence that a review happened. |
| `codex-gate.tools` | `execTool=<name>` and/or `reviewTool=<name>`: counts a Codex server whose tools aren't named `exec`/`review`, and only worth it if that server really does separate text-review from diff-review; aiming both gates at one general-purpose tool moves the counters while neither gate means what it says. Each mapped name must itself lie in `mcp__codex__*`: the hook's `hooks.json` matcher is `^(Bash\|Skill\|mcp__codex__.*)$`, so an out-of-namespace name is either never delivered (the mapping looks applied and does nothing) or, for the reserved names `Bash`/`Skill`, hijacks a lifecycle event; the hook refuses both. Register the server as `codex` to place its tools there. Unparseable, out-of-namespace and reserved (`Bash`/`Skill`) lines are ignored, and the gate keeps its default `exec`/`review` name. A typo inside the namespace, `mcp__codex__exce`, is still honoured: the hook does not check that a mapped tool exists, so the gate now counts that name and nothing else. Whether it ever counts depends on whether a tool by that name is actually invoked; for a typo, normally never. |

## Opting out

The workflow is opt-in per project, and leaving it has clean levels. Pick the smallest
that matches your intent:

1. **Don't adopt.** Never run `/workflow-init` in a project, and keep
   `.context/codex-gate.on` and a `Cross-Model Review` §5 heading out of it. The hook
   stays silent there; the skills and commands remain callable by name.
2. **One docs-only change.** The hook warns, it never blocks, and a commit whose every
   staged path is explanatory Markdown under `docs/`, or `README.md`, `MANIFEST.md`,
   `todos.md`, skips Gate B. Any other diff takes it. Gate A is not skippable for a spec.
3. **Pause a project.** `touch .context/codex-gate.off` (delete to re-enable; the
   counters keep their semantics while off, which is not evidence that a review
   happened).
4. **Leave for good.** Remove §5 from the project's `CLAUDE.md`, delete
   `.claude/review-gates.md` and `.context/codex-gate.on`. The project reads as not
   adopted again. The other scaffolds (ledger, CI, `AGENTS.md`) work fine without the
   gates.
5. **Machine-wide.** `claude plugin disable dev-workflow`.

If `.off` stays in a project for weeks, level 4 is the truthful choice. A project
officially without gates beats one that has them and ignores them.

## Contributing

CI ([`.github/workflows/ci.yml`](../.github/workflows/ci.yml)) runs four checks on every
PR and push to main: `shellcheck --shell=sh` over the four shell executables and every
shell test file, the hook's test suite,
[`scripts/check-invariants.sh`](../scripts/check-invariants.sh) (invariants 5 and 6, plus
six prompt-conformance checks and three size budgets) plus both checkers' regression
suites, [`scripts/check-doc-links.sh`](../scripts/check-doc-links.sh) (relative Markdown
links resolve) and its suite, the six reports' suites, and
`claude plugin validate . --strict`.

A fifth check runs on pull requests only:
[`scripts/check-version-bump.sh`](../scripts/check-version-bump.sh) (invariant 12), which
needs a base branch to diff against. Its suite runs unconditionally with the others; the
checker itself does not. That is sufficient here because main accepts changes only
through a PR: a branch ruleset (`protect-main.`, active since 2026-07-19) requires a pull
request and a green `quality` check, and the version-bump step runs inside that `quality`
job, so there is no push path into main that skips it. Main is protected: a PR with a
green `quality` check is the only way in, admins included; the ruleset lists no bypass
actors. The single command that runs the whole battery locally is in
[`AGENTS.md`](../AGENTS.md) under "Commands".

Everything else here is a prompt, and prompts have no typechecker. They are reviewed
against [`prompt-standards.md`](prompt-standards.md), this repo's own standard and the
same checklist it scaffolds into every project. A prompt-quality defect here is a defect
in the shipped product. Repo layout and the two non-obvious design decisions:
[`ARCHITECTURE.md`](ARCHITECTURE.md).

### Reports

All of these are read-only unless stated.

- `python3 scripts/ledger-metrics.py` prints a report over the hardening ledger and the
  review-cycle records in commit bodies: which fingerprints recur, how rungs were
  followed, and each cycle's recorded curve beside the `fic2` baseline. It writes nothing.
- `python3 scripts/run-analytics.py` reads the Claude Code transcripts and Codex session
  logs on this machine and reports how many gate calls each review cycle and story took,
  how long they ran and how many tokens they used, including effort no closed cycle
  accounts for. It keeps numbers and identifiers only, in `.context/telemetry/` of this
  clone, for 365 days.
- `python3 -B scripts/loop-usefulness.py [<ref>]` gives every review cycle whose records
  are in the history read a warning light (a skipped cycle ran no loop and is listed
  without one): red or amber where its recorded passes or rising findings call for
  reassessing review effort, no warning where no threshold is reached, and not
  determinable where missing or conflicting data leaves the state open. It does not say
  whether a loop was worth its effort, and it writes nothing (`-B` keeps the interpreter
  from writing bytecode too).
- `python3 -B scripts/spec-delta.py --base <baseSha> --baseline <commit>:<spec> … [<head>]`
  shows a Gate-B reviewer how each relevant spec and plan changed since a baseline you
  name, usually the commit that closed its Gate-A cycle. It quotes that commit's cycle
  records and names any ambiguity. It does not claim the cycle reviewed exactly that
  file, and it informs without obliging anything. It writes nothing.
- `python3 -B scripts/live-effort.py` shows the effort of review cycles that have not
  closed yet: calls, time and tokens per open cycle, plus gate calls still waiting for
  their result, with unknown values counted rather than hidden. Re-run it to refresh. It
  counts calls, not review passes, sets no threshold, and changes no gate rule. It writes
  nothing, and it reads every transcript, so a run can take a minute or two.
- `python3 -B scripts/status-view.py [--base <commit>] [--watch <seconds>]` writes one
  HTML page, `.context/status/index.html`: current work, evidenced progress, open points,
  effort, artifact growth against a baseline (merge-base with `main` unless `--base`
  names one) and the installed, loaded and declared workflow versions. Each value names
  its source and age; what the sources cannot establish says `unknown`. `--watch`
  regenerates it at that interval until you stop it, and the page reloads itself. It
  writes only `.context/status/`, keeps a cache there so later runs re-read only changed
  logs, and makes no model call. The first run reads every transcript once. Daily use:
  - **Where.** Run it from the root of the checkout you want to see. Branch, uncommitted paths
    and handover come from that checkout; effort counts every worktree sharing its git directory.
  - **Start and open.** Start it in a terminal of its own with
    `python3 -B scripts/status-view.py --watch 30`, then open `.context/status/index.html` in a
    browser. It prints nothing while it runs. Later runs reuse the cache, so they are much faster
    than the first.
  - **Stop.** Press Ctrl-C in that terminal; it exits 0 and the page stays. A watcher started in
    the background with `&` ignores Ctrl-C's signal, so stop it with `kill <pid>`. A second run
    beside a watcher refuses: `another status-view run holds .context/status/.lock`.
  - **Current or stale.** The top line names the generation time and either `watch every N s` or
    `one-shot run`. A watch page reloads itself. When no refresh has arrived within three
    intervals, because the watcher stopped or keeps failing, it shows `stale: no successful
    refresh observed within three intervals`. A one-shot page never warns, so only its generation
    time tells you how old it is.
