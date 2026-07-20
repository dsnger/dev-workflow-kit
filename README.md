# dev-workflow-kit

A Claude Code marketplace with one plugin, `dev-workflow`, that installs a spec-driven
workflow for building software with agents. It adds three mechanisms: two independent
cross-model review gates, a self-hardening findings ledger, and repo-enforced quality.

## What it does

- **Two independent review gates.** A *different model* than the author reviews the
  design before it becomes code (Gate A) and the diff before it lands (Gate B).
- **A self-hardening ledger.** Every finding is fingerprinted, so recurrence of a
  *class* is detectable — and a recurrence escalates the response one rung harder:
  prose note → lint rule → type constraint → test.
- **Repo-enforced quality.** One quality command runs in CI on every change, so nothing
  red can merge.

Why each of these, and how to adapt them: [`docs/coding-workflow.md`](docs/coding-workflow.md).

| | |
|---|---|
| `dev-workflow:intake` | skill — a raw idea or voice transcript (German or English) becomes a reviewable story. Captures WHAT and WHY; refuses to invent the parts that aren't there. |
| `dev-workflow:harden-finding` | skill — one review finding becomes a lint rule, type constraint, test, or documented convention, at the right rung, recorded in the ledger. |
| `/dev-workflow:process-pr-review` | command — validates PR bot comments against the code and your invariants, replies to each, fixes regressions, tracks pre-existing issues. |
| `dev-workflow:finding-triage` | agent — read-only, fresh context, judges whether one PR-bot claim is actually true of the code. Used by the PR processor; never counts as a review gate. |
| `/dev-workflow:workflow-init` | command — scaffolds the per-project files, then interviews you to write `AGENTS.md`. |
| codex-gate hook | non-blocking reminders that count Gate A and Gate B passes, and verify a Gate-B review against a fingerprint of the effective index plus the included worktree content, as of the hook's invocation — a deliberate superset of any one commit's payload, so the gate errs toward firing. Always exits 0. |

## Setup

**1. Install superpowers**, then this plugin:

```sh
claude plugin marketplace add obra/superpowers-marketplace
claude plugin install superpowers@superpowers-marketplace

claude plugin marketplace add dsnger/dev-workflow-kit
claude plugin install dev-workflow@dev-workflow-kit
```

To update later:

```sh
claude plugin marketplace update dev-workflow-kit
claude plugin update dev-workflow@dev-workflow-kit   # qualified form is a workaround: the bare
                                                     # name is documented but errors "Plugin
                                                     # 'dev-workflow' not found" (CLI 2.1.x)
```

Updates arrive only when the plugin version is bumped, and a running session keeps the
old version until you restart it or run `/reload-plugins`.

**2. Prerequisites:**

- **superpowers** — not vendored. The workflow's middle *is* its skills; without it,
  `intake` hands off to nothing and Gate A never fires.
- **Codex** — the reviewer behind both gates. Needs the **Codex CLI, authenticated with
  an OpenAI account** — a real external dependency, not just the `.mcp.json` entry
  `/workflow-init` writes for you. It also needs **a Codex MCP server that exposes
  `exec` and `review`** — the gates and their pass counters key on those two tool names.
  Use the `mcp-codex-dev` server `/workflow-init` pins, which has both. The official
  `codex mcp-server` is a *different* server exposing a single `codex` tool, which can't
  be attributed to Gate A (reviews text) or Gate B (reviews a diff): with it connected,
  no pass ever counts and Gate B reports "not run" forever (the hook says so, once).
- **`gh`** — optional; only `/dev-workflow:process-pr-review` uses it.

**3. Run `/dev-workflow:workflow-init` in each project.** It verifies the rest and tells
you what's missing — git repo, superpowers, Codex (not configured / not loaded / ok),
`gh`, `AGENTS.md`, stack — before writing a single file. Then follow
[`docs/getting-started.md`](docs/getting-started.md) for your first story.

## Daily use

**idea → `intake` → brainstorm → spec → Gate A → plan → Gate A → implement → quality
battery → Gate B → PR → `process-pr-review` → merge**, running every finding worth
keeping through `harden-finding`.

New to the workflow? [`docs/getting-started.md`](docs/getting-started.md) walks one
feature through every step — what you do, what happens, what you see.

The hook only speaks up in **initialized projects** — the ones where `/workflow-init`
has run (it writes `.context/codex-gate.on`, and its `CLAUDE.md` §5 counts too). The
plugin is installed once per machine; every other repo you open hears nothing from it.

Per-workspace knobs, all files under `.context/`:

| `codex-gate.floor` | a positive integer; moves the 3-passes-per-gate floor. |
| `codex-gate.off` | silences the reminders; state keeps tracking, so re-enabling is accurate. |
| `codex-gate.tools` | `execTool=<name>` and/or `reviewTool=<name>` — counts a Codex server whose tools aren't named `exec`/`review`, and only worth it if that server really does separate text-review from diff-review; aiming both gates at one general-purpose tool moves the counters while neither gate means what it says. Unparseable lines are ignored, so a typo can't quietly unhook a gate. |

**Without Codex**, `/workflow-init` degrades honestly instead of scaffolding gates that
can't run: it silences the hook and marks CLAUDE.md §5 `INACTIVE` with the re-enable
path. There is deliberately no same-model fallback reviewer — explicitly gateless beats
implicitly self-reviewed
([why](docs/coding-workflow.md#the-two-gates-and-why-independence-is-the-point)).

## What to expect

Five things stay yours on purpose — a plausible default nobody verified is worse than an
honest gap ([reasoning](docs/coding-workflow.md#adapting-it-to-another-project)):

- **Quality-battery tools** — the plugin names the roles (typecheck, lint, dead code,
  duplication, tests), never the tools. You wire them into one command.
- **Baselines** — generated from *your* repo, in their own commit.
- **Custom lint rules** — two ship as examples only
  ([`examples/eslint-rules/`](plugins/dev-workflow/examples/eslint-rules/)); they encode
  one stack's invariants and won't transfer.
- **Branch protection** — a repo setting, not a file; worth doing once the battery runs.
- **`AGENTS.md`** — your invariants. Both gates check against it, so a generic one makes
  "check against our invariants" read as satisfied when nothing was.

## Contributing

CI ([`.github/workflows/ci.yml`](.github/workflows/ci.yml)) runs four checks on every
PR and push to main: `shellcheck --shell=sh` over all three executables and their test
files, the hook's test suite,
[`scripts/check-invariants.sh`](scripts/check-invariants.sh) (invariants 5 and 6) plus
both checkers' regression suites, and `claude plugin validate . --strict`.

A fifth check runs **on pull requests only**:
[`scripts/check-version-bump.sh`](scripts/check-version-bump.sh) (invariant 12), which
needs a base branch to diff against. Its *suite* runs unconditionally with the others;
the checker itself does not, so a commit pushed straight to main is never version-bump
checked. The single command that runs the whole battery locally is in
[`AGENTS.md`](AGENTS.md) under "Commands".

Everything else here is a **prompt**, and prompts have no typechecker — they are
reviewed against [`docs/prompt-standards.md`](docs/prompt-standards.md), this repo's own
standard and the same checklist it scaffolds into every project. A prompt-quality defect
here is a defect in the shipped product.

Repo layout and the two non-obvious design decisions:
[`docs/architecture.md`](docs/architecture.md).
