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
| `/dev-workflow:process-pr-review` | command. Validates PR bot comments against the code and your invariants, replies to each, fixes regressions, tracks pre-existing issues, and names a bot on for the PR that left no review covering the current head (a green status check alone is no proof; a bot that is off is not named; a `once per PR` review and one from before a base update that left the PR diff unchanged cover it). |
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
  (`.gitattributes`, `.mcp.json`, `.claude/settings.json`, `.gitignore`) are merged. It writes
  `CLAUDE.md` (the discipline rules, with §5 as a pointer), `.claude/review-gates.md`
  (the gate rules), `docs/hardening-log.md`, `docs/hardening-taxonomy.md`,
  `docs/prompt-standards.md`, `docs/pr-review-bots.md`, `todos.md`,
  `.github/workflows/quality.yml` (with `TODO(stack)` blocks), the pinned `codex` and
  `context7` servers in `.mcp.json` (each added only when absent; an existing entry of
  that name is left as it is, so check it yourself), and `.context/codex-gate.on`, the
  marker that makes the hook speak in this project. Commit the marker.
- **Hook state in `.gitignore` (2.18).** It merges one block into `.gitignore`: the pattern
  `.context/codex-gate.*` ignores the hook's counters and markers, and five `!` lines keep the
  settings `on`, `off`, `floor`, `cap` and `tools` trackable. It asks when the project already
  ignores one of those five, reports a setting a rule such as `.context/` still ignores,
  and lists state files already tracked with the `git rm --cached` command to untrack them; the
  user runs it. Since 0.41.0 it then offers a second block, `/.context/*` with the same `!`
  lines, so session scratch (handovers, review files, logs) stays local and a `git add -A`
  cannot sweep it in. It recommends the block when `.context/` tracks nothing but those
  settings, lists the tracked paths and asks otherwise, and skips it when a rule already
  ignores all of `.context/`.
- **No attribution lines (2.19).** It merges `"attribution": {"commit": "", "pr": "",
  "sessionUrl": false}` into `.claude/settings.json`, which removes Claude Code's instruction to
  add a `Co-Authored-By` trailer to commits and attribution text to pull requests. Best effort: the
  model can still write the trailer from habit (an open Claude Code issue, seen on 2.1.296 and
  2.1.301), so the squash-body filter in `process-pr-review` is what keeps it off the main branch. It asks before replacing an
  `attribution` the project set itself. Not `includeCoAuthoredBy`, which Claude Code deprecated
  in 2.0.62; not `"attribution": false`, which clients before 2.1.281 reject together with the
  whole file. `process-pr-review` also strips that default trailer from the squash body.
- **Living docs (2.20, 2.21), asked.** When `.claude/living-docs.md` is absent it asks once
  whether the project takes living docs (recommended yes); the file's presence is the only
  switch, and a later run asks again after a no. Taken, it writes `.claude/living-docs.md` and
  `scripts/check-doc-links.sh`. The rules say where each kind of content lives (`AGENTS.md`
  § Documentation map as the signpost; `docs/PRD.md` with the feature map; `docs/ARCHITECTURE.md`;
  `docs/TECH-STACK.md`; one `docs/features/<name>.md` per feature), that these documents describe
  and link their binding sources, and that every change ends with a **build record**: one line
  `changed`, `checked, unchanged` or `absent` for every feature doc whose behaviour or `Planned`
  section the change affects (neighbours included), each top-level home, and always `CLAUDE.md`
  and `AGENTS.md`; a missing line is a finding. The record goes into Gate B's
  `whatWasImplemented`, the pull request body and the handover, with a size soft alarm past
  10,000 bytes (never a failure) and effort stamped per piece. The checker resolves relative links
  and their heading fragments, and skips links inside fenced code blocks and one-line code spans
  (code samples, not links; since 0.43.0). It asks which folders hold only dated or historical records
  and passes each as a skip prefix, since those cite paths as they were; a folder that also holds
  current specs, plans or feature docs is named by its dated subfolder instead (since 0.44.0:
  `docs/superpowers/` holds current specs, and skipping it hid their broken links in one project). Take it into the quality command. Nothing is written as an empty
  template, and nothing is deleted: to switch off, remove `.claude/living-docs.md` and its map
  line. It reports `living docs: incomplete — <part>` when the rules file, the `CLAUDE.md`
  paragraph, the map line or the checker differs from what the kit writes. **Not covered**, because
  the pilot that tested the rest did not exercise them
  ([report](field-reports/2026-10-23-living-docs-pilot-report.md#recommendation-ac-8)): naming a
  story's features at intake, map-guided builder context, cross-feature flows, the impact check
  along dependencies, conflict and composed-candidate checks, removing a feature, the splitting
  decision, capability levels.
- **Secret deny rules (2.17).** It merges `permissions.deny` entries into
  `.claude/settings.json` that stop Claude Code from reading every name starting `.env` (`.env`,
  `.env.local`, `.envrc`; except `.env.example`), `*.pem`, `*.key`, `secrets.*` at any depth, `secrets*` under
  `./.context/`, the private keys `id_rsa`, `id_ecdsa` and `id_ed25519` at any depth, and
  everything under `~/.ssh/`. When entries are missing from an existing file it asks before
  adding them. Observed with Claude Code 2.1.302 in a fixture repository: the Read tool was
  refused for a sample file of every entry except `id_rsa`, which was not tried (a `~/.ssh/`
  path was refused even when absent), `cat .env` in Bash was refused, and `.env.example` was
  readable at any depth. Upper-case names, observed with Claude Code 2.1.207 on macOS (a
  case-insensitive file system): the Read tool was refused for `.ENV`, `Secrets.json` and
  `CERT.PEM`, and `.ENV.EXAMPLE` stayed readable, so no extra entries were added. Not tried on a
  case-sensitive file system (Linux), where `.ENV` is a different file from `.env`. **What they do not stop**, as observed in the same probes: `grep -r` over the directory, and a script that opens the
  file itself (`python3 -c 'open(".env")'`). They are Claude Code settings, so other clients
  (Codex) do not read them; and per the Claude Code permissions docs, `./` is relative to the
  session's working directory, so a session started elsewhere is not covered by the
  `.context/` entry. These
  rules lower the chance of an accidental read; they do not make a secret in the repository
  safe. Rules for a different name (`id_dsa`, `credentials.json`) are yours to add.
- **`AGENTS.md` interview.** It asks in batches of 2 to 4 questions (what the project
  is, architecture, the documentation map, key invariants, don'ts, `## Commands`), shows each section before
  moving on, writes `TODO — not yet decided` where you don't know yet, and writes the
  file only after you approve the whole text. A `## Commands` row is filled only with a
  command it ran in that session and saw exit 0.
- **Closing checklist.** It ends with the items it deliberately did not scaffold: the
  battery, baselines, custom lint rules, branch protection, Codex, superpowers, the
  prompt-standards date, codebase-memory if found, living docs if taken, and the docs link check when its script is present. It also prints the optional
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
`/process-pr-review` reads: wait for, process opportunistically, ignore. A list entry may
say `only with label <name>` and `once per PR`; a bot that is off sits under ignore and is
not reported. Greptile is off in the kit by default. Turned on, it runs on request
(`autoReview: []`, set by you in Greptile; a comment `@greptileai` starts one review) or on a label
(`labels: ["greptile"]`, `autoReview: ["open"]`). Greptile's own default, `["open"]`, reviews each PR
once when it opens; per-push review comes only from adding `push` or `rebase`. With no bot on, or
none that ran, `/process-pr-review` says `PR bots: none ran on <sha>` and goes on. `/process-pr-review` asks no bot for a review, and a head that only
brings the base in (same `git patch-id --verbatim` of the PR diff) needs none. CodeRabbit
auto-reviews only PRs whose base is the default branch unless its configuration lists
the other base under `reviews.auto_review.base_branches`.

## Optional companions

Ponytail and codebase-memory are skipped when absent, and nothing fails. Context7 is
added by `/workflow-init` when its entry is missing; only its lookups have a fallback.

- **Context7** (MCP, library docs). `/workflow-init` writes it pinned into your
  `.mcp.json`. The gate rules require a Context7 lookup, for the version you pin, before
  a spec, plan or change that uses a third-party library API. Without third-party
  dependencies the rule does not apply, and when Context7 is unavailable (not loaded,
  rate-limited) or your pinned version is not indexed, the library's own material for that
  version stands in (docs, installed type declarations, a probe with the pinned binary).
  Nothing mechanical proves a lookup; the line naming library and version is the record. It runs without an API
  key, rate-limited; `CONTEXT7_API_KEY` in your own environment raises the limit. Off:
  remove the `context7` entry; the fallback then applies to every lookup.
- **Ponytail** (`ponytail@ponytail`). A lazy-senior-developer mode. Worth it when you
  want the obvious cuts made before Codex reads a diff. With it installed,
  `/workflow-init` recommends a default mode (`lite` for a large or old codebase, `full`
  otherwise) and writes it as `PONYTAIL_DEFAULT_MODE` into `.claude/settings.json`; the
  `CLAUDE.md` §4 rule then runs `ponytail-review` once on the branch diff before Gate B pass 1,
  listed under "Ponytail pre-review" in the PR body. Not a gate, not a pass, no
  replacement for Codex. Off: uninstall the plugin. That rule keys on its presence,
  and `PONYTAIL_DEFAULT_MODE` only sets the level Ponytail starts in.

  ```sh
  claude plugin marketplace add DietrichGebert/ponytail
  claude plugin install ponytail@ponytail
  ```
- **codebase-memory MCP.** A code graph for orientation and impact. The kit never
  installs, configures or registers it. When `/workflow-init` finds it loaded and you
  agree, it writes permission rules that deny the server's four write tools and allow its
  reads, adds a task-context block to `CLAUDE.md`, and checks the rules through a canary
  run against an isolated store. The block sits between `<!-- codebase-memory:start -->` and
  `<!-- codebase-memory:end -->`; a re-run leaves it out of the `CLAUDE.md` comparison, and a
  marker counts only alone on its own line, so one quoted inside a sentence is ordinary text. Indexing stays yours. Read the result it reports, and
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

**Gate effort scales with the change: a 1-line docs or release PR costs almost nothing** (since 0.50).
A docs-only commit skips Gate B, a release-only commit skips it too, and `scripts/local-ci.sh` runs a
light battery for both, or carries an earlier green verdict without a run (see the local path below).

### Gate modes

Since 0.46.0 a project picks how long its review loops run, in the committed one-word file
`.claude/codex-gate.mode`. `/workflow-init` writes `lean` once both gate-rules targets are current;
a project without the file, or with an unknown word in it, runs `classic`, the rules before 0.46.

| | `lean` | `strict` | `classic` |
|---|---|---|---|
| Gate A on a spec | risk `high` or security not `none` | same as `lean` | every spec |
| Gate A passes | exactly 2: full, then verify | same | floor 3, cap 5 |
| Gate B floor / cap | 1 / 3 | 1 / 5 | 3 / 5, zero-finding and small-change early closes |
| Gate B pass 2 on | verifies the fixes | full | full |
| At the cap | open Blocker, Security or violated-AC finding → you; the rest → `todos.md` | same | a Blocker → you; the agent decides the rest |

A **blocking** finding (`lean`, `strict`) is a Blocker, a Major, or a Security-class finding or
one naming a violated acceptance criterion, whatever its severity; the rest are collected. In a
`lean` verify pass Codex reads the fix diff (`baseSha` is the head the previous pass reviewed),
rechecks each earlier blocking finding, and a new ordinary Major is collected. A cycle keeps the
mode it began with. The duties added with the modes (one source of green, the UI app run, the
reason a prose hardening needs, archiving pass files) do not apply in `classic`. This repository
runs `strict`: its product is prose, and its Gate B found 28 % of Blockers and Majors in pass 4
or later. The design is `docs/superpowers/specs/2026-10-27-kit-046-lean-gates-design.md`.

**Gate A** sends the text of a spec (which ones: the mode decides, above), and of a plan whose
recorded risk is `high`, to Codex `exec`. **Gate B** sends every diff that is neither docs-only nor release-only (below) to Codex `review` after the
battery passes. Docs-only means every staged path is explanatory Markdown under `docs/`,
or `README.md`, `MANIFEST.md`, `todos.md`; `CLAUDE.md`, `AGENTS.md` and anything under
`.claude/`, `plugins/`, `skills/` or `commands/` at any depth are prompts and take the
gate, as does a mixed commit. The hook's own docs-only note is a path heuristic and does
not establish that eligibility.

**Release-only** (since 0.50) is decided by the hook, deterministically, on the staged diff of a plain
`git commit` (never `--amend` or `-a`): every file is a docs-only path, a `CHANGELOG*`, a
`package.json`/`composer.json` whose only change is its top-level `version` (compared with `jq`; no `jq`:
not release-only), or a `VERSION` file or a file on the project's `**Version sites:**` line in `AGENTS.md`
whose only change is one line holding just a version or `"version": "<version>"`; one old and one new
version across them. Instruction paths (`CLAUDE.md`, `AGENTS.md`, `.claude/`, `plugins/`, `skills/`,
`commands/`, `agents/`, `hooks/`) are never release-only, so this repository's own releases always take
Gate B. A commit that passes gets the note `release-only: version + changelog, no review`, quoted in the
PR body; anything else, or anything the check does not recognise, takes Gate B as before. The battery is always owed outside `scripts/local-ci.sh`'s light and inherited lanes (the local path, below), with two further exceptions. A timeout in a test the diff did
not touch that passes when run alone is recorded with that evidence, and the green
required check on the PR head then stands as the battery evidence. And when the battery passed
in full on a named commit and every path changed since then is docs-only, `process-pr-review`
reruns only the stages that read those paths; that full run plus the required check on the final
head is the battery evidence (since 0.41.0). The rules have no
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
Claude filters to blocking findings for repair (the gate mode defines them, above) and reads the rest. Findings land in
`.context/codex-reviews/gate-a-<spec|plan>-<nonce>-pass-<n>.md` (Gate A) one per line, severity
`BLOCKER | MAJOR | MINOR | NIT`. Claude's verdict on each finding goes beside it, in
`…-pass-<n>-dispositions.md`. Findings that are not blocking are collected, never iterated.
Floor and cap come from the gate mode (above). In `classic` the floor is three valid passes per
cycle, a pass with zero findings may close early, and the cap is the floor plus two (see
**Small changes in Gate B** below for the one exception), where a remaining Blocker or a cut to
an approved commitment goes to you and the agent decides the rest. From pass 2 on, each pass of
either gate lists the earlier passes' blocking findings, each with its verdict and reason,
and Codex marks each `fixed | not fixed | no longer applies`, a `not fixed` counting as a
finding again unless you declined it or accepted it unrepaired and Codex brings no new
evidence. One cause at several places is reported once, as a class
listing every place. In Gate B the `spec` call
maps each acceptance criterion to the test asserting it, or `none`, and reports a test
that cannot fail. Codex is advisory: Claude arbitrates disputed findings, and a dismissed
finding needs a one-line reason.

**Cap stop.** In `lean` and `strict`, an open Blocker, Security-class or violated-AC finding, or a cut to an
approved commitment, goes to you and you may allow more passes; otherwise the cycle closes with a `todos.md` row
per open finding. In `classic`: `⚠ Codex Gate A: pass cap reached (5/5). STOP: a remaining Blocker, or a cut
to an approved commitment, goes to the human` (same for Gate B). Then you answer; otherwise Claude does and
records why. The answer is `close`, or one of delete the mechanism the findings keep
returning to / cut scope / continue, each naming how many further passes it allows (at
least one); the loop resumes on the artifact as your answer leaves it.
`.context/codex-gate.cap-extra` holds the total allowance beyond the base cap for the
cycle, so a second answer adds to the number already there.

**Small changes in Gate B** (`classic` only since 0.46.0: in `lean` and `strict` every Gate B
closes at its first pass with no open blocking finding). Since 0.38.0 (decision D14, Daniel, 2026-10-20), Gate B on a
small change closes at its first pass with no Blocker or Major, instead of running to the
floor of three. Small means all of: the profile reads `risk standard` and `security none`
(taken from the cited story, or derived as `intake` does); at most 197 lines added plus deleted
outside files only tests use, counted with `git diff --numstat` from a commit before the whole
change (the merge-base with the default branch on a feature branch; on the default branch
itself, the parent of the change's first commit); and no prompt path (`CLAUDE.md`,
`AGENTS.md`, `.claude/`, `plugins/`, `skills/`, `commands/`), migration, shared contract or path
an `AGENTS.md` invariant names. A binary file, a failed count or a base that cannot be found
makes the change not small. 197 is the production diff of the field case D14 was decided on.
The closing pass's Minors and Nits are not repaired in the cycle, because a fix after the
last pass is code nobody reviewed; each is declined or goes to `todos.md`. The closing commit,
and the PR body when there is one, carry `small change: <n> lines, <base>..<head>`. Gate A has
no such exception. The agent decides and records; nothing checks it. A reviewer can re-run the
count on the recorded range, but the other conditions (which files only tests use, what is a
shared contract, the profile) are judgement. Not caught, and the list is not exhaustive: a small
diff with a large effect, and a pure rename, which counts as 0 lines (edits in a renamed file
still count). The design note is
`docs/superpowers/specs/2026-10-20-proportional-gate-b-design.md`.

**Closing act.** A pass that closes the cycle under its mode (above), or a `classic` cap answer
of `close`, runs the closing act. Outside `classic` it first moves the cycle's pass files to
`.context/archive/codex-reviews/<nonce>/`, overwriting nothing (a file already there: stop and compare); a resumed cycle looks there too. The
closing act is one commit carrying the cycle's record lines, the
ledger-check records, and a `todos.md` row per finding dispositioned `accepted, not
repaired`, so no follow-up is lost. For Gate B that commit takes a non-WIP subject. Since
0.40.0 the rules give its form: stage, then one plain `git commit -F .context/<msg>`
(`--allow-empty` when nothing is staged), so the hook's docs-only check can read a commit that
stages only `todos.md` (see [Hook messages](#hook-messages)). An empty commit stages nothing, so it
gets the ordinary Gate-B check instead, with the messages listed under Hook messages.
Planning starts once the spec is approved (after Gate A's closing act, or at its commit when the gate mode
skips Gate A; with checkpoint `spec`, at your approval); Gate A on a plan (risk `high` only) ends with its own closing act. A spec change after
approval goes through `intake`'s amendment route.

**Gate B shape.** Claude makes a plain `git commit -m 'WIP: <subject>'`, a Bash call of its own (gives Codex a
range to read; the hook keeps the cycle open across a commit it recognises as WIP; for one
it does not, see [Hook messages](#hook-messages)), then
loops `mcp__codex__review` as two calls per pass, `reviewType: spec` then `quality`, on
the same `baseSha` and `headSha`. Invalidation is by content: any change to included
content present when the hook runs, even from a formatter, makes the hook report that it
cannot confirm the reviewed content. What that proves is bounded, and the hook's own
source says so: the current fingerprint matches the one recorded on a credited pass,
which is not evidence that Codex read those bytes; `.context/` and untracked ignored
paths are excluded, and staging counts, because the fingerprint covers the index and
that is what a commit carries.

**When the counters reset.** After a Bash call whose text
looks like a commit, the hook compares HEAD and the length of HEAD's reflog with what it
recorded before the call. Both unchanged (a commit that failed, a heredoc or `printf` that only
names `git commit`): the counters stay. Either one changed: they reset, unless the call is a WIP
commit the hook recognises. They reset too when the hook cannot compare: no record from before
the call, an empty or unreadable reflog, or a call sent to the background (`run_in_background`).
A commit that a shell `&` sends off and that lands after the call returns is not seen, and
the counters stay.

**The hook's messages.** `⚠ Codex Gate A below floor (1/3): a zero-finding last pass may
close early` is the counter, not an error, and the same holds for Gate B, whose line reads
`⚠ Codex Gate B below floor (1/3): may close after a zero-finding pass, or a small change's pass
with no Blocker or Major`. The hook measures no size either. The hook counts
passes and never judges a pass's findings (for Gate A it checks only that the labelled findings
file is complete, see **Gate A call not counted** below), so the line appears whenever its floor check runs
below the threshold: Gate B's on a commit (a WIP or docs-only commit skips the check),
Gate A's when plan execution starts. That includes a cycle whose last pass had zero
findings and closed early, and a small change's Gate B that closed at its first pass with no
Blocker or Major, both of which the rules allow. The number after the slash is the hook's reminder
threshold, taken from the gate mode (see **Gate mode** below), which `codex-gate.floor` can move. Whether a
cycle closes is the closure ordering's (above), whatever the counter says. The docs-only
skip never lets an open cycle stop short. `✓ Codex Gate B hook checks passed (<counted>/<threshold> cycle, <fresh> on
current fingerprint)` carries three different numbers: the passes the hook credited this
cycle (one per `full` call or per `spec` + `quality` pair on the same `baseSha` and
`headSha`), the hook's own reminder threshold, and the consecutive credited passes on the
current fingerprint since it last changed. The first is not the calls you made: a single
branch counts only together with its partner, and the hook withholds credit for a
recognized failure envelope, the backgrounding notice, a result it can get no text from,
and a request it cannot read or pair. The third is a streak, not a tally: a pass on a
changed fingerprint restarts it, and an earlier matching pass separated by a different
fingerprint is not counted. None of the three is the floor §5 obliges, and the message
is what the hook checked, not permission to close. For Gate B the hook counts passes and
compares a fingerprint; it never reads a findings file. Judge each pass from its findings file and
discount an incomplete one yourself, whatever the counter says. If the hook's own
threshold was not met when implementation starts, it says so right then.

**Comparing the hook's count with your record.** The hook's count is the first number of the ✓
line. A WIP or docs-only commit prints no ✓ line, so a cycle closed with a docs-only closing commit
shows none; the current values are in `.context/codex-gate.passes` (Gate B; a commit that resets
the counters removes it) and `.context/codex-gate.passCountA` (Gate A; that commit moves it to
`codex-gate.passCountA.closed`). Read them before the closing commit and compare them with the pass count in the cycle line.
Since 0.43.0 every commit check that does not show the WIP note also prints the Gate-B count on a line of its
own while the cycle has one, docs-only closing commits included:
`ℹ Gate-B hook count before this commit: <n> (a commit that lands may clear it)`. Take the count from that
line: once a commit that resets the counters lands (see When the counters reset, above), the file
is gone, and a report written afterwards finds nothing to read
(field case, 2026-10-23: a report said "unverified" for that reason). A report that says
they differ names the cause: one of the hook's messages earlier in the cycle (a commit not counted as
WIP, a review branch whose `headSha` is not a full SHA, an unpaired branch, a resumed `exec`, a
withheld result), or `cause unknown`. Kit 0.40.1 reported "no" with no cause; its session had
compared hook state-file names, not passes.

### The Gate B review skill (since 0.51)

Every Gate B call names `.agents/skills/gate-b-review/SKILL.md` in its `additionalContext`, and Codex follows it.
Codex CLI 0.162.1 also discovers it by itself: it lists skills under a repository's `.agents/skills/` (checked on
2026-10-30). The skill lives in the project (`/workflow-init` 2.24–2.26), so nothing is written under your home
directory. The design is `docs/superpowers/specs/2026-10-30-kit-051-codex-review-design.md`.

**What it asks of Codex.** By branch: `spec` maps every acceptance criterion to the code and the test that
asserts it; `quality` checks the invariants the diff touches and the failure, error, empty and concurrent paths;
`risk` goes deeper on edge cases and failure paths only. In every branch, Codex traces the callers and
dependents of each changed symbol with `git grep` in the head tree. It uses a codebase-memory index only when it
can show the index matches the head, and never indexes. Besides the findings file it writes
`…-pass-<n>-evidence.md`: one `TESTS:` line per test command it ran, or the reason none ran, and one `CALLERS:`
line per changed symbol.

**Targeted tests.** Codex may run the test commands for the touched paths, never the whole battery, through
`scripts/run-tests.sh`, and only when its sandbox is `workspace-write` with network restricted. `/workflow-init`
2.8 sets that sandbox with `"CODEX_DEV_SANDBOX_MODE": "workspace-write"` in the `codex` server's `env`. The server
reads the setting when it starts, so it applies from the next session start. A server config file's
`tools.review.sandbox` overrides it, and a resumed call (`sessionId`) runs without a sandbox, so Codex then
reports the tests as not run. The script:
- makes a `git clone --no-local` copy at the head in `TMPDIR`: tracked files only, so no `.env` or other
  untracked or ignored file. It never runs `git worktree add`;
- runs the command with only `PATH`, `HOME`, `TMPDIR` and `LANG=C` set, stdin from `/dev/null`, as its own process
  group (through `perl`; without `perl` it runs nothing, exit 5). After the time limit (600 s by default) the group
  gets `TERM`, then `KILL`. The copy is removed on every exit;
- compares the reviewed checkout before and after: `HEAD`, the index, the diff against `HEAD`, every untracked,
  not-ignored file's content and mode, and everything under `.context/codex-reviews/` (so a test cannot forge a
  findings or state file). A difference exits 4, which Codex reports as a Blocker. This detects a write, it does
  not prevent it. Ignored files, the rest of `.context/` and `.git/` beyond `HEAD` and the index are outside the
  comparison. The copy has no remote.

**What it does not protect against.** Two limits, stated so nobody reads the list above as isolation. These are
the axes checked against, and the list is not exhaustive. First, a test can read any file on your machine by
absolute path, as your quality command can. Second, a secret committed to the repository's tracked files is in
the copy. The test is your project's own code, and the quality command already runs it with your full rights; the
review adds no new trust in it. A process that leaves the group on purpose (its own `setsid`) escapes the time
limit. If the runner itself is killed with `KILL`, the next run reports the copy it left and removes it once its
processes are gone.

**The risk pass.** One extra Codex pass at high reasoning effort, through `codex exec` (no MCP tool takes an
effort), run by `scripts/risk-pass.sh`.
- *When it is due.* The cycle's diff (`<cycle base>..<head>`) touches one of four categories, judged from the
  diff's content whatever the paths: (a) a script or tool the project runs (build, release, CI, hook, installer);
  (b) security-relevant code (authentication, authorization, secrets, validation at a trust boundary,
  sandboxing, cryptography); (c) a rule or gate file (instruction files, gate rules, review prompts, CI workflows);
  (d) a schema or data migration. Some paths always make it due: `scripts/*`, `bin/*`, `*.sh`, any `hooks/`
  directory, `.github/workflows/*`, `CLAUDE.md`, `AGENTS.md`, `.claude/*`, `.agents/*`, `.mcp.json`, any
  `plugins/`, `skills/`, `commands/` or `agents/` directory, a `migrations` or `migrate` path segment. Your own
  patterns go in backticks on an `AGENTS.md` `**Risk paths:**` line, and they only add. A story whose security
  is not `none` also makes it due. A story saying `none` does not exempt security code found in the diff.
- *Cycle base.* Before Gate B pass 1, Claude writes `.context/codex-reviews/gate-b-cycle-<nonce>.state` with the
  line `base <pass 1's baseSha>`. It is never rewritten in the cycle.
- *When it runs.* Once per cycle, after the ordinary passes leave no open blocking finding, and before closing.
  A later change keeps it valid when it only repairs the risk pass's own findings or touches no risk category,
  and the next `quality` pass verifies it. Any other later change in a risk category runs it again, as one more
  pass under the cap.
- *How it runs.* `sh .agents/skills/gate-b-review/scripts/risk-pass.sh <repo> <baseSha> <headSha> <nonce> <n>
  [<seconds>]`, as a background Bash call (default limit 2400 s). Each attempt writes its own files
  (`gate-b-risk-<nonce>-pass-<n>-attempt-<a>.md`, `-evidence.md`, `-reply.md`, `.events.jsonl`). Only the
  slot's lock holder copies a valid attempt to the canonical `gate-b-risk-<nonce>-pass-<n>.md` and appends
  `risk <n> done <a> <head> <sha256>` to the state file, so a late writer from an earlier attempt cannot replace
  the result. The script runs with your rights while Codex can write in the repository, so it never writes
  through a symlink: a symlinked `.context/codex-reviews/` or state file is refused, an existing attempt file is
  refused, and results are renamed into place. Exit 1: Codex failed or the file breaks the findings format (one retry); 2 bad arguments; 3
  timeout; 4 the slot is busy; 5 no `perl`; 6 a Codex CLI other than `codex-cli 0.162.1`.
- *Counting.* It is one pass toward the Gate B cap of every mode (`lean` 3, `strict` 5, `classic` 5), never toward
  the floor, which stays the hook-counted `spec`+`quality` pair. When it is due and no pass is left under the
  cap, the cycle goes to you, as an open Blocker at the cap does. The hook does not see the run.
- *Follow-up.* Each blocking risk finding goes into the next `quality` call as an earlier finding, where Codex
  marks it `fixed`, `not fixed` or `no longer applies`. The risk slot has its own dispositions file. At closing
  the canonical file's sha256 must match the slot's last `done` line, and the closing commit's cycle line adds
  `risk pass <n>: <count>`.

**Codex CLI version.** The risk pass is verified on Codex CLI 0.162.1 only, so `risk-pass.sh` refuses any other
version. Installing it is your step: `npm install -g @openai/codex@0.162.1`. `/workflow-init` lists it in its
closing checklist (item 5) and does not run it. Ordinary Gate A and Gate B calls go through the MCP server as
before.

## Hook messages

The hook's messages say what happened and what to do next. The possible causes behind eight
of them live here.

**Kit files older than the plugin** (`dev-workflow: the last /workflow-init run here recorded kit …;
the installed plugin is …`). At every session start (since 0.49) the hook compares the installed
plugin's version with `.claude/dev-workflow-version`, which `/workflow-init` writes on each run. A
missing, unreadable or different record prints this one line; a record newer than the plugin asks you
to update the plugin first. The record says which kit ran `/workflow-init` last, not that every file
was accepted. Nothing is said in a project that has not adopted the workflow, with the opt-out marker,
or when the plugin's own version cannot be read.

**Codex call failed** (`⚠ Codex call failed — not counted as a gate pass`). The Codex server
answered with `success: false`. When the error message is empty (seen 2026-10-23: three times,
session `abandoned`, nothing else), the hook tells the session to probe Codex directly from the
same session before its one retry: `codex exec --skip-git-repo-check "Reply with OK" </dev/null`,
and `echo $CODEX_HOME` (empty means the default home, `~/.codex`). An answer like "You've hit your
usage limit … try again at …" is missing access, one of the stops in `CLAUDE.md` §4: stop and tell
the human, naming that home. Why
the same session: a tool that starts sessions per account (Orca, for example) sets `CODEX_HOME` to
a per-account home, so a probe from another session can use another account and answer OK.
Since 0.44.0 every session also runs this probe once before its first gate call (scaffolded
`CLAUDE.md` §5), so a usage limit shows before the first gate instead of as empty failures.

**Not counted as a WIP commit** (`ℹ Not counted as a WIP commit: pass counters cleared if HEAD moves`).
The commit message starts with `WIP`, but the call is not the plain form, so if it moves this
repository's HEAD or its reflog, the hook clears the pass counters after it (see When the
counters reset, above). The reminder then adds: *This call is not
counted as a WIP commit, so the pass counters are cleared after it unless the hook sees HEAD
and its reflog unchanged. If they are cleared, the hook count is from then on lower than your
cycle passes; when you compare the two, name this call as the cause. A WIP commit is one git commit -m 'WIP: <subject>'
Bash call with a plain subject, run from the repository, and nothing else in the call but one
leading git add <paths> &&: a command chained before or after it (x && git commit ..., git
commit ...; y), a second line, cd, git -C or a heredoc is not, so stage in the call before;* then a
link here. Since 0.43.0 it names those shapes and the count consequence plainly, because two
field cycles (2026-10-23/24) each lost one pass to a commit chained in one Bash call, and found out
only when comparing at the end. Why those forms are refused: after the commit the hook checks the new HEAD of the
repository it runs in and ties it to this one call. A `cd` or `git -C` can commit in another
repository, and a chain, heredoc or shell metacharacter can change HEAD or the message in ways
that check cannot tie to the call, so these forms are never kept as WIP: one that moves this
repository's HEAD resets, the safe direction, and one that commits only in another repository
leaves the counters alone. One chain is kept since 0.41.0, because the field kept using it (canvas,
2026-10-22: three resets in one day): `git add <paths> && git commit -m 'WIP: <subject>'`, where
every `git add` word is made only of letters, digits and `._/@+=,:%~-` (no quote, space inside a
path, glob or `$`). `git add` writes no entry to HEAD's reflog, so the after-commit check still
proves HEAD is this call's one WIP commit; a failed `git add` skips the commit and the counters
stay. The rules still prescribe the plain form, and a chain in any other shape is refused as
before. A plain subject
holds no shell metacharacter or backslash: `-m 'WIP: fix a & b'` is refused for its `&`. The
one exception is `(` and `)` inside single quotes, where the shell reads them as text, in a
command with no double quote: `-m 'WIP: fix x (y)'` is the plain form, `-m "WIP: fix x (y)"` is not. The sentence appears
only where `git commit` stands as a command of its own; a commit hidden in quotes (`sh -c "git commit …"`) gets none. The match is
loose: a heredoc body line starting with `wip` also adds the sentence. The sentence does not
appear when the plain form itself is refused because the repository's hooks or settings could
rewrite the message; that commit gets the ordinary reminder only.

The hook also runs for a subagent's tool calls and keeps one cycle state per repository, so a
subagent's commit that it does not recognise as WIP (a `cd … &&` chain is the usual one) clears the
main session's counters, and the sentence above lands in the subagent's context, not the main
session's (canvas S4, 2026-10-21: the hook saw 2 of 3 passes). Since 0.40.0 the rules have the main
session make every commit inside an open cycle; implementer subagents leave their changes
uncommitted.

**Resumed session not counted** (`ℹ Codex Gate A: resumed session not counted as a pass`). The
`mcp__codex__exec` call carried a non-empty `sessionId` in its input, so it continued an earlier
Codex session and the hook did not count it (since 0.40.0). The usual case is fetching the rest of a
truncated reply, which belongs to the pass it completes. If the call was a review pass of its own,
run it again without `sessionId`: the count stays one short until you do, which the below-floor
reminder will show. The hook reads `sessionId` with `jq` only: without `jq` a resumed call counts like any
other, so a re-fetch there still shows as an extra pass when it names a complete findings file (since 0.45.0
every call needs one).

**Gate A call not counted** (`ℹ Codex Gate A: not counted — <cause>`). Since 0.45.0 the hook counts an
`mcp__codex__exec` call as a Gate A pass only when its `instruction` labels one findings file,
`Findings file: <path>`, and that file is complete: its last line is `END OF FINDINGS (<n> total)`, `<n>` body
lines each start with a severity (`BLOCKER | `, `MAJOR | `, `MINOR | `, `NIT | `), or the one body line is
`NO FINDINGS`. The field case: kit 0.44's Gate A `k044ga7q` asked for the findings in the reply, the server
cut the reply off, and the hook counted 5 calls for 4 passes. The check reads the file's structure only, not
the six fields of a finding line, not which run wrote the file, and not what it reviewed: a complete file left
from an earlier call is credited again, which is why the rules have you delete a partial target before a re-run.
Causes, each with its check and fix:
- `names no findings file` — the instruction has no `Findings file: <path>` line (a reply-only call). Add one,
  with a relative path, and have Codex write it.
- `names two findings files` — two different labelled paths. Label only this pass's file; name earlier
  passes' files without the label.
- `findings file elsewhere` — an absolute path outside this checkout's `.context/codex-reviews/`. Name this
  checkout's path, or a relative one.
- `findings file missing` — no regular file at the path, or a symbolic link. Check that Codex wrote it in this
  checkout; replace a link with the file.
- `findings file incomplete` — a cut-off or malformed file: no terminator, a count that differs from the body
  lines, or a body line without a severity. Delete it and re-run the pass with Codex writing it.
- `findings file unreadable` — `awk` failed. Check that `printf 'x\n' | awk '{print}'` prints `x`.

The path is a relative `.context/codex-reviews/…` path, or this checkout's absolute path without spaces; it
ends at whitespace, a backtick, `)`, `,`, `;` or a sentence's full stop, so `x.md.tmp` is not `x.md`. An
absolute path containing a space is not recognized (`names no findings file`): use the relative form.
Without `jq` the instruction is read by the hook's fallback reader: a path character written as a `\u` escape
becomes `?`, so that path does not match; write the path in plain ASCII, or install `jq`. A Codex server whose
exec tool takes its prompt under another key than `instruction` never counts: install the pinned server
(`/dev-workflow:workflow-init` 2.8). The retry budget stays one per pass: repair the cause first.

**Gate mode** (since 0.46.0). The hook reads the committed `.claude/codex-gate.mode` (`lean`, `strict` or
`classic`, edges trimmed) and takes each gate's floor and cap from it: `lean` Gate A 2/2, Gate B 1/3;
`strict` Gate A 2/2, Gate B 1/5; `classic`, no file or an unusable file 3/5 for both. Each floor reminder ends
with the mode its numbers come from (`· mode lean` in the short line, `Numbers from mode lean.` in the
context), and so does the pass-cap reminder. At a gate's first counted pass the hook records the mode in
`.context/codex-gate.modeA` or `codex-gate.modeB`, cleared with that gate's counter; while the counter is
positive it uses the higher floor and the lower cap of the recorded and the current mode, and says so:
`mode lean, cycle begun under classic: the higher floor and lower cap of the two`. A positive counter with no
record (a cycle begun under 0.45) counts as `classic`. When `codex-gate.floor` or `codex-gate.cap` is set the
reminder adds `overridden by a .context/ floor or cap file`: those files override the numbers of both gates,
as before 0.46.

The advice in three reminders follows the mode of the gate's cycle (the recorded one while its counter is
positive, else the current one); under `classic` they keep their 0.45 text. Under `lean` and `strict`:
the pass-cap reminder reads *STOP: an open Blocker, Security-class or violated-AC finding, or a cut to an
approved commitment, goes to the human; otherwise close the cycle, each open finding a todos.md row*, and
asks for passes the human allows in `.context/codex-gate.cap-extra`; the Gate B below-floor reminder
(`⚠ Codex Gate B below floor (p/f) · mode <word>`) drops the early-close advice; the Gate A below-floor
reminder (`⚠ Codex Gate A below floor (p/f): two passes when Gate A runs · mode <word>`) says a Gate A that
runs is exactly two passes, full then verify, and that a spec below the threshold needs none.

**Mode file unusable** (`⚠ .claude/codex-gate.mode is unusable: the file counts as classic`). The file is
present but empty, unreadable, a directory, or not exactly one of the three words. The file then counts as
`classic`; an open cycle keeps the mode it began with, so the numbers beside the note may combine both (the
higher floor and the lower cap). The hook says so beside each gate number it reports (gate calls, commit
attempts, plan execution), and asks the session to fix the file in its next commit.

**Gate A threshold** (`ℹ Codex Gate A, mode <word>: …`). At plan execution, beside the Gate A floor
reminder: under `lean` and `strict` a spec needs Gate A only at risk `high` or security not `none`, and a
plan only at risk `high`, so a standard-risk spec without a Gate A reads as expected; under `classic` every
spec needs one.

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
fingerprint could not be written or read back; or a non-WIP commit cleared it (see When the counters reset, above) while
the cycle stayed open. It also appears on a spec or plan commit whose command is more than
`git commit` and its options (a `$(cat <<'EOF' …)` message, a chained `git add`), because
only a plain command is offered the docs-only note. The fingerprint is Gate B's alone: Gate A
passes (`mcp__codex__exec`) are counted per call that left its labelled findings file complete, a resumed session
excepted where `jq` is installed, and never record one.

**Cannot confirm reviewed content** (`⚠ Codex Gate B: cannot confirm reviewed content`).
Usually the working tree or the index changed since the review. A closing commit that stages
`todos.md` and is made with a chain or a heredoc (`git add todos.md && git commit -F - <<'EOF'`)
lands here too: only a plain `git commit` is offered the docs-only note, so the hook compares the
fingerprint and sees `todos.md` changed after the last pass. The rules' form avoids it: stage in
one call, then `git commit -F .context/<msg>` (`--allow-empty` when nothing is staged), with the
message file under `.context/`, which the fingerprint excludes. Other causes: you only
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

The gate mode is the one setting outside `.context/`: `.claude/codex-gate.mode`, committed, holding
`lean`, `strict` or `classic` (see Gate mode under [Hook messages](#hook-messages)). All other knobs are files under `.context/`. Every other `codex-gate.*` file there is state the hook
writes; `/workflow-init` 2.18 ignores those and leaves these knobs trackable, except
`codex-gate.cap-extra`, which belongs to one cycle and is ignored too:

| | |
|---|---|
| `codex-gate.floor` | a positive integer; moves the hook's reminder threshold for both gates, over the gate mode's numbers. It does not change the floor the gate rules oblige (in `classic` three valid passes; a zero-finding pass may close earlier, and in Gate B so does a small change's pass with no Blocker or Major). |
| `codex-gate.cap` | a positive integer of at most nine digits (anything else is ignored); the pass count at which the hook starts printing its pass-cap reminder ("STOP: a remaining Blocker, or a cut to an approved commitment, goes to the human") on every gate call and commit attempt. Default: the gate mode's cap per gate, or, with `codex-gate.floor` set, that floor plus two. A reminder only: nothing is blocked, and whether your review policy has a pass-cap rule is that policy's business. |
| `codex-gate.cap-extra` | a positive integer of at most nine digits (anything else is ignored), written after the cap answer (yours; in `classic` also Claude's): the total allowance beyond the base cap for the current cycle, not an increment. A second answer of "two more" at a cap of 7 is written as `4`, not `2`. The commit that clears the pass counter clears it too. |
| `codex-gate.modeA`, `codex-gate.modeB` | state, not knobs: the gate mode the hook recorded at that gate's first counted pass, cleared with that gate's pass counter (see [Gate mode](#hook-messages)). |
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
   `todos.md`, skips Gate B. Any other diff takes it. Which specs need Gate A is the gate mode's
   decision ([Gate modes](#gate-modes)); a docs-only commit does not skip it.
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
PR and push to main: `shellcheck --shell=sh` over the six shell executables and every
shell test file, the hook's test suite,
[`scripts/check-invariants.sh`](../scripts/check-invariants.sh) (invariants 5 and 6, plus
six prompt-conformance checks and three size budgets) plus both checkers' regression
suites, [`scripts/check-doc-links.sh`](../scripts/check-doc-links.sh) (inline relative
Markdown links in tracked files resolve, and a fragment on a Markdown target names a heading
there; links inside code fences and one-line code spans, reference-style links and the other limits its header lists are not checked; `/workflow-init` 2.21 ships the same bytes to
projects, and check 4l keeps the two copies identical) and its suite, the six reports' suites, and
`claude plugin validate . --strict`.

A fifth check runs on pull requests only:
[`scripts/check-version-bump.sh`](../scripts/check-version-bump.sh) (invariant 12), which
needs a base branch to diff against. Its suite runs unconditionally with the others; the
checker itself does not. That is sufficient here because main accepts changes only
through a PR: a branch ruleset (`protect-main.`, active since 2026-07-19) requires a pull
request and a green `quality` check — from the job, or from `scripts/local-ci.sh`, any source since
2026-10-28 — and the version-bump check runs inside that job and inside the local battery (against
`origin/main`). The ruleset requires the green check and does not verify that either runner produced
it: a status posted by hand (see the local path below) runs no version-bump check. Main is protected: a PR with a
green `quality` check is the only way in, admins included; the ruleset lists no bypass
actors. The single command that runs the whole battery locally is in
[`AGENTS.md`](../AGENTS.md) under "Commands".

**The local path.** When the Actions budget is used up, or you choose local up front, the same
battery runs on the Mac: `gh workflow disable ci.yml` first, so no Actions check run competes with the
local result (GitHub counts a check run and a commit status of the same required name together, and
both must pass). Disabling stops new runs only: a run in progress finishes, and a `quality` check run
Actions already created on a commit (it reports on the PR head commit) stays there and must pass too,
so switch before you push the commit you will run locally. Then, per commit, `git fetch origin` and
`sh scripts/local-ci.sh [<commit>]` from the repository root (after a squash-merge: `git fetch origin`,
then `--from <the PR's final head> <merge sha>`). The script runs the quality row of
[`AGENTS.md`](../AGENTS.md) § Commands on that commit in a temporary worktree it removes afterwards
and posts the result as the `quality` commit status; `gh workflow enable ci.yml` switches back.
**Lanes** (since 0.50; the script's header is the contract): with `--from <a green head>`, a commit with
that head's tree (a squash-merge) or with only `.context/` and `todos.md` changed (a closing commit) gets
`inherited green from <head>` and nothing runs; a docs- or release-only change since the lane base
(`--from`, else the merge-base with `origin/main`) runs the `quality-light` row of `AGENTS.md` instead
(this repository: invariant checks, version bump, doc links, plugin validation; 29 s on this Mac); everything
else runs the full row. The context is `quality` in every lane, so the ruleset stays as it is.
Differences to the job: the local shellcheck binary (the script refuses a version other than the
`ci.yml` pin), the local `claude` CLI instead of the npm-pinned one (the script checks no version there;
it records the one it ran in the status description), and macOS's `/bin/sh` and awk
instead of ubuntu-24.04's. Two consequences: anyone with write access can post a `quality` status by
hand, so the author of each status is worth a look in the merge box; and the script runs that
commit's own scripts on the Mac, so run it only on commits you have read, never on a fork's head.

**The local path in a project** (since 0.49). `/workflow-init` 2.22 offers the same script, byte for
byte (check 4m), defaulting to yes when the default branch requires a `quality` check with no source
restriction. In a project without this repository's shellcheck pin the parity check is skipped and the
status description has no shellcheck part. The quality row runs in a fresh worktree, so a command that
needs installed dependencies installs them itself first. A required check restricted to one app's
source cannot be met by a status posted with `gh`; lifting that restriction, and any other ruleset,
protection or workflow change, is the human's. A branch that requires no check at all needs neither:
the quality command on the final head (or a `local-ci.sh` light or inherited lane on it) is the green, recorded in the PR body (`CLAUDE.md` §4, "Waiting
on external work").

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
  A curve's lists may separate their items with `,` or `, `, and a bare model may be several words
  (`gpt-6-astra per $CODEX_HOME/config.toml`), as field records write them (0.45.0); `loop-usefulness.py` and
  `spec-delta.py` read curves through the same parser.
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
- `sh scripts/worktree-cleanup.sh [--remove [--discard-ignored]] [--root <dir>]... [<repo>]`
  reports the linked worktrees and local branches of any repository (not only this one): merged
  (`ancestor`, or `pr#<n>` when a merged PR's head equals the tip, asked of `gh`), dirty, ignored
  files outside `.context/`, commits not on any remote, age, and a live session (a process whose
  working directory is inside, from `lsof`). Without `gh` or `lsof` those answers read `unknown`.
  Report mode changes nothing but a lock directory under the git common dir. `--remove` deletes
  only rows marked `removable`: inside `<main>/.claude/worktrees/`, `<main>/.worktrees/` or a
  `--root`, merged, clean, no session, no ignored files unless `--discard-ignored`. It first copies
  the worktree's `.context/` to `<main>/.context/archive-worktree-<name>`, rechecks, removes the
  worktree without `--force`, then deletes the branch only if it still points at the reported
  commit. Remote branches are never touched. Run `git fetch --prune` first.
  - **Who runs it.** The orchestrator or the human, after closing the sessions in those worktrees;
    never the session working in one of them. A session whose worktree is removed under it keeps
    running plugin hooks, which then write into a deleted path or fall back to the main checkout
    (field case 2026-10-22: a hook committed the main checkout's files after its worktree was gone).
  - **Keep the repository still during `--remove`.** Close the sessions in the worktrees it will
    remove, and let nothing else check out or move branches until it ends. Two moments stay open,
    each between two adjacent `git` calls: a process starting in a worktree, or a file written
    there, after the recheck and before the removal (the process loses its directory, the file is
    deleted); and a checkout of the branch in another worktree after the last checkout check and
    before the branch is deleted (that worktree is left on a branch with no ref; its commits are
    kept, since the tip is merged). A path with bytes outside printable ASCII or a backslash reads
    `session=unknown`, because `lsof` prints such names escaped. The script header lists its other
    limits.
