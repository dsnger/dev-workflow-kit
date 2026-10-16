# Setup — from zero to the first merged feature

The full path, nothing assumed. Each step says what you type, what you should see, and how
to check it worked. The README has the short version; `getting-started.md` walks the first
feature through every step once this is done.

## 1. Prerequisites

Before installing anything:

- **A git repository** — `/workflow-init` stops without one (`git rev-parse
  --show-toplevel` must succeed in the project).
- **Claude Code** — the plugin is a Claude Code plugin. Step 3 below needs **2.1.212 or
  newer**.
- **Node with `npx`** — the `codex` and `context7` entries `/workflow-init` writes into
  `.mcp.json` launch their servers with `npx -y <pkg>@<version>`.
- **superpowers** — not vendored. The workflow's middle *is* its skills; without it,
  `intake` hands off to nothing and Gate A never fires. Install commands in step 2.
- **Codex** — the reviewer behind both gates. Needs the **Codex CLI, authenticated with
  an OpenAI account** — a real external dependency, not just the `.mcp.json` entry
  `/workflow-init` writes for you. It also needs **a Codex MCP server that exposes
  `exec` and `review`** — the gates key on those two tool names, and the pass counters
  additionally skip routed calls whose result the hook reads as failed, backgrounded, or
  yielding no usable text; a result it can read but not interpret still counts, and
  normally says so once. For Gate B the counter also reads the request: a `spec` and a
  `quality` call on the same 40-character lowercase `baseSha` and `headSha` count as one pass, and a
  lone branch counts as none.
  Use the `mcp-codex-dev` server `/workflow-init` pins, which has both. The official
  `codex mcp-server` is a *different* server exposing `codex` and `codex-reply`, neither
  of which can be attributed to Gate A (reviews text) or Gate B (reviews a diff): with it
  connected, no pass ever counts and Gate B reports "not run" forever (the hook says so,
  once).

  Both gates have Codex write its findings to a file under `.context/codex-reviews/` and
  reply with a one-line summary, because a long finding list returned inline can come
  back cut off — and a cut between findings looks exactly like a short list. Claude Code
  limits MCP tool output to 25,000 tokens by default; `MAX_MCP_OUTPUT_TOKENS` raises
  that, which is worth trying as a *secondary* mitigation but is not the fix. It moves
  the ceiling rather than removing it, and it applies only to tools that don't declare
  their own text limit via `anthropic/maxResultSizeChars` — whether `mcp-codex-dev`
  declares one is not established here. The file protocol is what actually keeps
  findings out of the response.
- **`gh`** — optional; only `/dev-workflow:process-pr-review` uses it.
- **Python 3** — only `/dev-workflow:claude-init` needs it, to create the file.

Check: step 4's preflight block reports the git repository, superpowers, Codex and `gh`
(as `ok`, `MISSING`, `NOT LOADED` or `absent`, each with its fix), so a wrong guess there
costs one re-run. It does not check the Claude Code version, Node or Python; check those
yourself (`claude --version`, `npx --version`, `python3 --version`).

## 2. Install superpowers, then this plugin

```sh
claude plugin marketplace add obra/superpowers-marketplace
claude plugin install superpowers@superpowers-marketplace

claude plugin marketplace add dsnger/dev-workflow-kit
claude plugin install dev-workflow@dev-workflow-kit
```

Check: in a fresh Claude Code session, `/dev-workflow:workflow-init` is offered as a
command. The hook is installed once per machine; step 4 adopts the workflow per project.

## 3. Set `CLAUDE_CODE_MCP_AUTO_BACKGROUND_MS`

Strongly recommended, and the primary defence against a gate call being
auto-backgrounded. Claude Code moves a long MCP call to the background at a threshold
(120 s by default) and fires `PostToolUse` *at that moment*, carrying the harness's own
notice instead of any Codex result; the eventual real completion fires no second
`PostToolUse`, so the hook never sees the review's outcome.

Requires **Claude Code 2.1.212 or newer**. Set it in the environment Claude Code is
**launched from** — it is read at process start, so exporting it inside a tool shell
leaves the running session unchanged and you must restart Claude Code. Use `0` to disable
auto-backgrounding, or a positive value that **exceeds** your longest expected gate call;
a positive value shorter than the call still backgrounds it.

```sh
export CLAUDE_CODE_MCP_AUTO_BACKGROUND_MS=0   # or e.g. 900000, exceeding your longest gate call
```

**Without it, both outcomes are possible, and only one is safe.** While the harness notice
keeps the wording the hook recognizes, the backgrounded pass is *discarded* — correct, but
**re-running it is not simply a retry**: the original call may still be running and can still
write into the findings slot afterwards, leaving a correctly terminated file from the wrong
run that no downstream check can detect. Stop that task by the id in the tool result — or
await it if the result carries none — and delete the findings slot first. The hook's own
backgrounding message carries that procedure; follow it there rather than from memory. If that harness prose ever changes, the hook can no longer recognize
the notice and the call is *counted* instead — credited as a pass, or recorded as half of one
for a single branch — with a disclosure that says this was done without inspection. That second outcome is why this setting is the defence rather
than the hook: the hook fails safe against today's wording, not against every future one.

(`CLAUDE_CODE_AUTO_BACKGROUND_TIMEOUT_MS` appears in the 2.1.220 string table but was
never exercised here, so it is deliberately not documented — naming the wrong one of two
similar variables is this project's own docs-drift class.)

## 4. Run `/dev-workflow:workflow-init` in the project

In a session opened at the project root, type `/dev-workflow:workflow-init`. What
happens, in order:

- **Preflight.** It prints a status block before writing anything: git repository,
  superpowers, Codex (`not configured` / `NOT LOADED` with the cause / `ok`), `gh`,
  `AGENTS.md`, stack, existing targets, and the two optional companions (codebase-memory
  MCP, Ponytail). Only a missing git repository stops the preflight; choosing to set up
  Codex now (see "Without Codex" below) also ends the run so you can.
- **Scaffolding.** Per file: missing → written; identical → `unchanged`; present and
  different → it shows the diff and asks overwrite / merge / skip; additive files
  (`.gitattributes`, `.mcp.json`, `.claude/settings.json`) are merged. It writes
  `CLAUDE.md` (the discipline rules, with §5 as a pointer), `.claude/review-gates.md`
  (the gate rules), `docs/hardening-log.md`, `docs/hardening-taxonomy.md`,
  `docs/prompt-standards.md`, `docs/pr-review-bots.md`, `todos.md`,
  `.github/workflows/quality.yml` (with `TODO(stack)` blocks), the pinned `codex` and
  `context7` servers in `.mcp.json` (each added only when absent — an existing entry of
  that name is left as it is, so check it yourself), and `.context/codex-gate.on` — the
  marker that makes the hook speak in this project. Commit the marker.
- **`AGENTS.md` interview.** It asks in batches of 2–4 questions — what the project is,
  architecture, key invariants, don'ts, `## Commands` — shows each section before moving
  on, writes `TODO — not yet decided` where you don't know yet, and writes the file only
  after you approve the whole text. A `## Commands` row is filled only with a command it
  ran in that session and saw exit 0.
- **Closing checklist.** It ends with the items it deliberately did not scaffold: the
  battery, baselines, custom lint rules, branch protection, Codex, superpowers, the
  prompt-standards date, and codebase-memory if found. It also prints a
  `~/.codex/config.toml` block for you to add by hand (home directory, never written).

Check: the report lists every file as `written`, `unchanged`, `merged` or `skipped`, and
`.context/codex-gate.on` exists. Then, before any feature work: add the printed
`~/.codex/config.toml` block; restart the session so the project servers from
`.mcp.json` are approved and loaded; and confirm both `mcp__codex__exec` and
`mcp__codex__review` are available — re-running `/dev-workflow:workflow-init` shows
`codex MCP ok (pinned mcp-codex-dev@<version>)` once they are.

**Without Codex**, the preflight asks whether to set it up now; on yes it stops and lets
you. On "not now" `/workflow-init` degrades honestly instead of scaffolding gates that
can't run: it writes `.context/codex-gate.off` to silence the hook and marks CLAUDE.md §5
`INACTIVE` with the re-enable path — set up Codex, then delete `.context/codex-gate.off`
before the first feature. There is deliberately no same-model fallback reviewer —
explicitly gateless beats implicitly self-reviewed
([why](coding-workflow.md#the-two-gates-and-why-independence-is-the-point)).

## 5. Wire the quality battery into one command

Pick the tools behind each role (typecheck, lint, dead code, duplication, tests) — add a
tool only once you have run it and seen it catch something real — chain them into one
command, run it green locally, then put it in `AGENTS.md § Commands` (`quality` row) and
in the `TODO(stack)` block of `.github/workflows/quality.yml`, and delete the workflow's
"Refuse to be a green no-op" step, which greps for `TODO(stack)` and fails while any
remains (its own text included). Baselines (duplication, coverage) go in their own
commit. Check: the command exits 0 locally; the `quality` job runs on a pull request or
a push to main, so its first green run is on the PR you open in step 6.

## 6. CI and branch protection

Push, open a pull request, and watch the `quality` job run the same command. Then, in
the repository settings, make `quality` a required check and turn on "Require branches to
be up to date before merging" — two PRs can each be green alone and red together. Limit:
GitHub makes you update the branch; the update's CI run is what checks the combination.
Check: a PR shows `quality` as required.

## 7. PR review bots

Fill `docs/pr-review-bots.md` with the bots you enabled and where each one posts (inline,
summary, both, or `inconsistent`), and sort them into the three routing lists
`/process-pr-review` reads: wait for, process opportunistically, ignore. CodeRabbit
auto-reviews only PRs whose base is the default branch unless its configuration lists the
other base under `reviews.auto_review.base_branches`.

## 8. Optional companions

Each one is skipped when absent, and nothing fails:

- **Context7** (MCP, library docs) — `/workflow-init` writes it pinned into your
  `.mcp.json`. The gate rules require a Context7 lookup, for the version you pin, before a
  spec, plan or change that uses a third-party library API; without third-party
  dependencies the rule does not apply, and when Context7 is unavailable, or your pinned
  version is not indexed, the library's own material for that version stands in (docs,
  installed type declarations, a probe with the pinned binary). It runs without an API
  key, rate-limited; `CONTEXT7_API_KEY` in your own environment raises the limit. Off:
  remove the `context7` entry; the fallback then applies to every lookup.
- **Ponytail** (`ponytail@ponytail`) — a lazy-senior-developer mode. Worth it when you
  want the obvious cuts made before Codex reads a diff. With it installed,
  `/workflow-init` recommends a default mode (`lite` for a large or old codebase, `full`
  otherwise) and writes it as `PONYTAIL_DEFAULT_MODE` into `.claude/settings.json`; the
  gate rules then run `ponytail-review` once on the branch diff before Gate B pass 1,
  listed under "Ponytail pre-review" in the PR body. Not a gate, not a pass, no
  replacement for Codex. Off: uninstall the plugin — the gate rules key on its presence,
  and `PONYTAIL_DEFAULT_MODE` only sets the level Ponytail starts in.

  ```sh
  claude plugin marketplace add DietrichGebert/ponytail
  claude plugin install ponytail@ponytail
  ```
- **codebase-memory MCP** — a code graph for orientation and impact. The kit never
  installs, configures or registers it. When `/workflow-init` finds it loaded and you
  agree, it writes permission rules that deny the server's four write tools and allow its
  reads, adds a task-context block to `CLAUDE.md`, and checks the rules through a canary
  run against an isolated store. Indexing stays yours. Read the result it reports, and
  re-run the canary after any change to the client, the server binary, the permission
  mode, the rules, the start configuration or the account; when you may claim the
  protection, and what it never covers, is in
  [`/workflow-init` 2.14–2.15](../plugins/dev-workflow/commands/workflow-init.md) and the
  block it writes into your `CLAUDE.md`. Off: decline on the first run (nothing is
  written); parts already adopted are removed by hand.

## 9. Update the plugin later

```sh
claude plugin marketplace update dev-workflow-kit
claude plugin update dev-workflow@dev-workflow-kit   # qualified form is a workaround: the bare
                                                     # name is documented but errors "Plugin
                                                     # 'dev-workflow' not found" (CLI 2.1.x)
```

Updates arrive only when the plugin version is bumped, and a running session keeps the
old version until you restart it or run `/reload-plugins`. The scaffolded files do not
update themselves: re-run `/dev-workflow:workflow-init` in each project and take the
changed files from the diff; for a `CLAUDE.md` §5 pointer or a `.claude/review-gates.md`
from an older kit edition it recommends the current template. A review cycle already
running finishes under the rules it started with.

## 10. First feature

Follow "How to use" in the README for the short form, or
[`getting-started.md`](getting-started.md) for one feature through every step — what you
do, what happens, what you see.

## Per-workspace knobs

The hook speaks only where `.context/codex-gate.on` or the `Cross-Model Review` §5 heading
in `CLAUDE.md` is present (`is_adopted` in
[`codex-gate.sh`](../plugins/dev-workflow/hooks/codex-gate.sh)). To silence it for good,
delete both; the skills and commands stay callable by name.

All knobs are files under `.context/`:

| | |
|---|---|
| `codex-gate.floor` | a positive integer; moves the hook's reminder threshold. It does not change the floor the gate rules oblige, which is three valid passes (a zero-finding pass may close earlier). |
| `codex-gate.cap` | a positive integer; the pass count at which the hook starts printing its pass-cap reminder ("STOP and ask the human") on every gate call and commit attempt. Default: the reminder threshold plus two. A reminder only: nothing is blocked, and whether your review policy has a pass-cap rule is that policy's business. |
| `codex-gate.cap-extra` | a positive integer, written by hand after the human answers that reminder: the **total** allowance beyond the base cap for the current cycle, not an increment — a second answer of "two more" at a cap of 7 is written as `4`, not `2`. The commit that clears the pass counter clears it too. |
| `codex-gate.off` | silences the reminders; classification and state tracking keep running, so re-enabling lands on counters carrying the same semantics as gate-on — which is not the same as evidence that a review happened. |
| `codex-gate.tools` | `execTool=<name>` and/or `reviewTool=<name>` — counts a Codex server whose tools aren't named `exec`/`review`, and only worth it if that server really does separate text-review from diff-review; aiming both gates at one general-purpose tool moves the counters while neither gate means what it says. Each mapped name must itself lie in `mcp__codex__*`: the hook's `hooks.json` matcher is `^(Bash\|Skill\|mcp__codex__.*)$`, so an out-of-namespace name is either never delivered (the mapping looks applied and does nothing) or, for the reserved names `Bash`/`Skill`, hijacks a lifecycle event; the hook refuses both — register the server as `codex` to place its tools there. Unparseable, out-of-namespace and reserved (`Bash`/`Skill`) lines are ignored, and the gate keeps its default `exec`/`review` name. A typo **inside** the namespace — `mcp__codex__exce` — is still honoured: the hook does not check that a mapped tool exists, so the gate now counts that name and nothing else. Whether it ever counts depends on whether a tool by that name is actually invoked; for a typo, normally never. |
