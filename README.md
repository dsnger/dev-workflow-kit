# dev-workflow-kit

A Claude Code marketplace with one plugin, `dev-workflow`, that installs a
spec-driven workflow built around a single thesis: **quality should be a property of
the process, not of any single heroic review.**

Three things make that true, and they are what the plugin gives you:

1. **Two independent review gates.** A *different model* than the one that authored
   the work reviews the design before it becomes code (Gate A) and the diff before it
   lands (Gate B). A model tends to be blind to its own mistakes in the same way
   twice; a second, independent reviewer is not.
2. **A self-hardening ledger.** Every finding is logged with a fingerprint, so
   recurrence of a *class* becomes detectable. An escalation ladder decides the
   response — prose note → lint rule → type constraint → test — and a recurrence
   escalates one rung harder. Close the class, not the instance.
3. **Repo-enforced quality.** One quality command runs in CI on every change, so
   nothing red can merge. Enforcement that depends on remembering to run the checks
   is not enforcement.

The full methodology, tool-agnostic, is in [`docs/coding-workflow.md`](docs/coding-workflow.md).

## Prerequisites

**[Superpowers](https://github.com/obra/superpowers)** — a separate plugin, not
vendored here. The workflow's middle stages *are* superpowers skills
(`brainstorming` → `writing-plans` → `executing-plans`), and the gate hook counts its
Gate-A passes between them. Install it first; without it the intake skill hands off to
a skill that isn't there.

**Codex** — the reviewer behind both gates. Cross-model independence is the whole
mechanism, so the reviewer being a different model *family* than the author is the
feature, not a detail. Three parts, all required:

1. **The Codex CLI, installed and authenticated.** It needs an **OpenAI account** —
   this is a real external dependency with its own signup and cost, not just a config
   line, and it is the piece people most often miss.
2. **The `codex` MCP server** in `.mcp.json` — `/workflow-init` writes it, pinned.
3. **The right tool surface.** The gates call `mcp__codex__exec` (Gate A, reviews the
   spec/plan text) and `mcp__codex__review` (Gate B, reviews a git diff), and the hook
   counts passes by those exact tool names. Another Codex MCP can connect under the
   same server name while exposing different tools (e.g. `mcp__codex__codex`) — in
   which case the gates silently never fire. `/workflow-init` checks the names, not
   just that "a codex server exists".

Without Codex, both gates are inoperative. That is survivable — see
[degraded mode](#degraded-mode-no-codex) — but it is not the workflow.

**`gh`** — optional; only `/dev-workflow:process-pr-review` needs it.

## Quickstart

**1. Install superpowers** (the prerequisite above — do this first, so the next steps
can verify it):

```sh
claude plugin install superpowers@<marketplace>
```

**2. Install this plugin:**

```sh
claude plugin marketplace add dsnger/dev-workflow-kit   # or a local path to this repo
claude plugin install dev-workflow@dev-workflow-kit
```

**3. In each project that should use the workflow, run:**

```
/dev-workflow:workflow-init
```

It verifies the rest and tells you what's missing. There is no separate `doctor`
command on purpose — a second entry point would split the setup story. `workflow-init`
checks every prerequisite before it writes anything, and prints a status line for each:

```
Prerequisites:
  git repository        ok
  superpowers plugin    MISSING — claude plugin install superpowers@<marketplace>
  codex MCP             NOT LOADED — restart the session; if still absent, the Codex
                        CLI is not installed/authenticated (needs an OpenAI account)
  gh CLI                ok (optional — only /process-pr-review needs it)
  AGENTS.md             absent — Step 3 will write it
  stack                 pnpm · TypeScript · vitest · GitHub Actions
```

Codex gets three distinct verdicts, because they have three different fixes and a
single "codex: failed" would send you hunting in the wrong place: **not configured**
(no `.mcp.json` entry), **not loaded** (entry present, but the tools aren't in the
session — restart, or the CLI isn't installed/authenticated), or **ok**.

Only a missing git repo stops the run; everything else still scaffolds, and each gap is
carried into the closing checklist as a named blocker.

## What you get

| | |
|---|---|
| `dev-workflow:intake` | skill — a raw idea or voice transcript (German or English) becomes a reviewable story. Captures WHAT and WHY; refuses to invent the parts that aren't there. |
| `dev-workflow:harden-finding` | skill — one review finding becomes a lint rule, type constraint, test, or documented convention, at the right rung, recorded in the ledger. |
| `/dev-workflow:process-pr-review` | command — validates PR bot comments against the code and your invariants, replies to each, fixes regressions, tracks pre-existing issues. |
| `/dev-workflow:workflow-init` | command — scaffolds the per-project files, then interviews you to write `AGENTS.md`. |
| codex-gate hook | non-blocking reminders that count Gate A and Gate B passes, and that verify a Gate-B review against the actual content of the working tree. Always exits 0. |

The hook registers itself through the plugin's `plugins/dev-workflow/hooks/hooks.json`
— no `settings.json` edit needed in your project, and nothing to keep in sync when the
plugin updates.

**Gate B is verified by content, not by events.** At review time the hook stores a hash
of the working tree; at commit it recomputes and compares. So a file changed through
Bash — `sed -i`, `eslint --fix`, `git apply`, a codegen step — invalidates the review
exactly like an `Edit` does. An event-based check would miss all of those and leave a
false ✓ standing, which is the dangerous direction. An edit-then-undo correctly stays
valid, because what you're committing *is* what was reviewed.

**WIP commits are cycle-internal.** CLAUDE.md §5 tells you to make a throwaway commit
so `mcp__codex__review` has a non-empty range to read. Name it `WIP: …` and the hook
neither fires a STOP nor resets your pass counters — otherwise the documented
workaround would destroy the very cycle it exists to serve.

**Per-project floor.** The gates default to a minimum of 3 passes each. Override with a
positive integer in `.context/codex-gate.floor` (e.g. `echo 1 > .context/codex-gate.floor`
for a low-risk repo). Anything else — `0`, a negative, a word, an empty file — falls
back to 3, so a typo cannot silently switch the gate off.

**Per-workspace opt-out.** `touch .context/codex-gate.off` (delete to re-enable). Only
the reminders go quiet; the gates still apply, and the state machine keeps running
while off, so re-enabling is accurate rather than stale.

### Degraded mode (no Codex)

If you decline to set Codex up, `/workflow-init` will not scaffold a workflow that lies
about itself. It writes `.context/codex-gate.off`, marks §5 of the generated
`CLAUDE.md` as **INACTIVE — Codex not configured; the gates below do not run**, and puts
re-enabling at the *top* of the closing checklist.

The alternative — mandatory gate instructions that cannot run, plus a Gate-B STOP on
every commit forever — is noise that trains you to ignore the hook, and a hook people
ignore is worse than no hook.

There is deliberately **no same-model fallback reviewer**: a model reviewing its own
work reproduces its own blind spots and returns a clean review that means nothing, so
being explicitly gateless is honest where being implicitly self-reviewed is a false ✓ —
the exact failure this workflow exists to prevent.

## Per-project setup

`/workflow-init` is idempotent and never overwrites without asking. It writes:

| File | What it is |
|---|---|
| `CLAUDE.md` §1–5 | the discipline rules, including the two gates |
| `docs/hardening-log.md` | the ledger — **empty**, header only. The format ships; the history is yours |
| `docs/hardening-taxonomy.md` | your project's fingerprint classes (empty; the base classes ship in the skill) |
| `docs/prompt-standards.md` | the 10-criteria checklist every prompt artifact must pass |
| `docs/pr-review-bots.md` | which bots run here, and which actually post line findings |
| `todos.md` | skeleton, incl. the prompt-standards revalidation entry |
| `.gitattributes` | one line: union-merge for the ledger, so parallel branches never lose a row |
| `.mcp.json` | the Codex server, pinned |
| `.github/workflows/quality.yml` | CI, with the battery steps marked `TODO(stack)` |
| `pnpm-workspace.yaml` | `minimumReleaseAge: 1440`, if this is a pnpm project |

Then it **interviews you to write `AGENTS.md`** — the invariants file. That one can't
come from a template, which is the point: both gates and both bots check against it,
so a generic AGENTS.md would make "check this against our invariants" read as
satisfied when nothing was checked. It asks about auth, tenancy, data access,
validation, errors, and concurrency, writes only what you answer, and marks the rest
`TODO` rather than guessing.

## What deliberately stays per-project

Everything below is left to you **on purpose**. Each is a place where a plausible
default that was never verified is worse than an honest gap — a config line should
record a *verified necessity*, not a hypothesis.

- **The quality battery.** The plugin names the *roles* — strict typecheck, linter at
  zero warnings, dead-code detection, duplication check against a baseline, tests —
  and never the tools. Wire them into one command; put it in `AGENTS.md § Commands`,
  which is where `harden-finding` and `process-pr-review` resolve "the project's lint
  command" from.
- **Baselines.** A duplication or coverage baseline must be generated from *your*
  repo, in its own commit. Never bundle a re-baseline with feature work — a baseline
  that drifts inside a feature commit stops being a record of a decision.
- **Custom lint rules.** Two ship as **examples only**
  ([`plugins/dev-workflow/examples/eslint-rules/`](plugins/dev-workflow/examples/eslint-rules/)):
  they encode one stack's invariants and will not transfer. Read them for the shape —
  how an AGENTS.md invariant becomes a rule that fails the build — and write your own
  when `harden-finding` escalates a finding to rung 2.
- **The hardening taxonomy.** The skill ships ~27 stack-neutral base classes
  (`lookup-before-auth`, `unindexed-query`, `promise-unawaited`, …). Your domain
  classes — the ones naming your tables, your helpers, your framework — go in
  `docs/hardening-taxonomy.md`, which the skill reads alongside the base list. That
  split is what lets the plugin be shared without one project's vocabulary leaking
  into another's.
- **Branch protection.** Making the `quality` check *required* is a repo setting, not
  a file. Until you flip it, the gate is a convention; after, the platform enforces
  it. It is the highest-value item on the list.
- **The AGENTS.md invariants themselves.** See above.

## Quality of this repo — honestly

**This repo has no quality battery in the sense the workflow means it.** There is no
typecheck, no linter, and no dead-code check — which is a real gap in a repo whose
entire subject is repo-enforced quality, and it should be named rather than glossed
over. The reason is narrow rather than principled: almost everything here is a
*prompt*, and prompts have no typechecker.

What actually gates changes here, all of it running in CI
([`.github/workflows/ci.yml`](.github/workflows/ci.yml)) on every PR and push to main:

- **`plugins/dev-workflow/hooks/codex-gate.test.sh`** — 65 assertions over the hook's state machine: the
  content-hash Gate-B verification (including a file changed through Bash, a new
  untracked file, and an edit-then-undo), both pass counters, the fresh-vs-cycle pass
  distinction, the per-project floor override and its invalid-value fallbacks, the
  WIP-commit carve-out, the docs-only-commit downgrade, the opt-out marker, the
  no-`jq` fallback, and that a failed state write still exits 0. Run it locally:

  ```sh
  sh plugins/dev-workflow/hooks/codex-gate.test.sh
  ```

- **`claude plugin validate . --strict`** — manifest, skill/command frontmatter, and
  hooks.json schema. It needs no auth or API key, so it runs in CI unchanged.

- **Careful review.** The check that applies to the prompts is
  [`docs/prompt-standards.md`](docs/prompt-standards.md) — this repo's own standard,
  the same checklist it hands to every project it scaffolds. A prompt-quality defect
  found here is a defect in the shipped product, and hardening it means changing the
  plugin, which every downstream project inherits on update.

So: the hook is genuinely, mechanically tested and enforced; the prompts are gated by
discipline, and discipline is exactly what this workflow exists to stop relying on.
The honest next step is a markdown/frontmatter linter in the same CI job — that would
be the first mechanical check the prompts have ever had.

## Layout

```
.claude-plugin/marketplace.json
.github/workflows/ci.yml          # hook tests + plugin validate
plugins/dev-workflow/
  .claude-plugin/plugin.json
  skills/{intake,harden-finding}/SKILL.md
  commands/{workflow-init,process-pr-review}.md
  hooks/{hooks.json,codex-gate.sh,codex-gate.test.sh}
  examples/                       # read, don't install — one stack's answers
docs/{coding-workflow,prompt-standards}.md
source-files/                     # the extraction seed this repo was built from
```

`/workflow-init`'s templates live **inside the command file**, not in a `templates/`
directory. Claude Code does not expand `${CLAUDE_PLUGIN_ROOT}` inside command
markdown, and the installed-plugin cache path is a version-keyed implementation
detail — so a command that read its templates from disk would be one release away
from breaking. Inline means one source of truth and nothing to resolve.
