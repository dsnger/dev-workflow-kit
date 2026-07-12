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
| `/dev-workflow:workflow-init` | command — scaffolds the per-project files, then interviews you to write `AGENTS.md`. |
| codex-gate hook | non-blocking reminders that count Gate A and Gate B passes, and verify a Gate-B review against the actual content of the working tree. Always exits 0. |

## Setup

**1. Install superpowers**, then this plugin:

```sh
claude plugin marketplace add obra/superpowers-marketplace
claude plugin install superpowers@superpowers-marketplace

claude plugin marketplace add dsnger/dev-workflow-kit
claude plugin install dev-workflow@dev-workflow-kit
```

**2. Prerequisites:**

- **superpowers** — not vendored. The workflow's middle *is* its skills; without it,
  `intake` hands off to nothing and Gate A never fires.
- **Codex** — the reviewer behind both gates. Needs the **Codex CLI, authenticated with
  an OpenAI account** — a real external dependency, not just the `.mcp.json` entry
  `/workflow-init` writes for you.
- **`gh`** — optional; only `/dev-workflow:process-pr-review` uses it.

**3. Run `/dev-workflow:workflow-init` in each project.** It verifies the rest and tells
you what's missing — git repo, superpowers, Codex (not configured / not loaded / ok),
`gh`, `AGENTS.md`, stack — before writing a single file.

## Daily use

**idea → `intake` → brainstorm → spec → Gate A → plan → Gate A → implement → quality
battery → Gate B → PR → `process-pr-review` → merge**, running every finding worth
keeping through `harden-finding`.

Two per-workspace knobs: `.context/codex-gate.floor` (positive integer; gates default to
3 passes each) and `.context/codex-gate.off` (silences reminders; state keeps tracking,
so re-enabling is accurate).

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

CI ([`.github/workflows/ci.yml`](.github/workflows/ci.yml)) runs the hook's test suite
and `claude plugin validate . --strict` on every PR and push to main. Run the tests
locally with `sh plugins/dev-workflow/hooks/codex-gate.test.sh`.

Everything else here is a **prompt**, and prompts have no typechecker — they are
reviewed against [`docs/prompt-standards.md`](docs/prompt-standards.md), this repo's own
standard and the same checklist it scaffolds into every project. A prompt-quality defect
here is a defect in the shipped product.

Repo layout and the two non-obvious design decisions:
[`docs/architecture.md`](docs/architecture.md).
