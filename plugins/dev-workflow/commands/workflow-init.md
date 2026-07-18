---
description: Scaffold the per-project files of the cross-model review workflow, then walk the user through writing AGENTS.md
---

Scaffold this project's cross-model review workflow: write the per-project files
below, then interactively author `AGENTS.md`, then print the stack-specific
checklist that stays the user's job.

Target model: Claude via Claude Code. This command is a prompt artifact and follows
the checklist it scaffolds (`docs/prompt-standards.md`).

## Rules

1. **Idempotent.** Run it twice and the second run changes nothing it already wrote.
2. **Never overwrite without asking.** For each target: missing → write it. Present
   and byte-identical to the template → report `unchanged`, touch nothing. Present
   and different → show what differs (a short diff, not the whole file) and ask:
   overwrite / merge / skip. This matters because these files accumulate real
   project content after the first run — a silent overwrite destroys it.
3. **Additive files are merged, never rewritten.** `.gitattributes`, `.mcp.json`,
   `pnpm-workspace.yaml` and `package.json` belong to the project; add the missing
   line or key and leave everything else exactly as it was.
4. **Stack-specific content is marked, not guessed.** Where a template has a
   `# TODO(stack):` marker, leave the marker in and name it in the closing checklist.
   A plausible-looking command that was never run is worse than an honest TODO.
5. **Report what happened per file** — `written` / `unchanged` / `merged` /
   `skipped (user)` / `asked, overwrote`. No silent no-ops.

## Step 1 — Preflight: check every prerequisite, then say what's missing

This is the project's one setup entry point, so it carries the whole "is my setup
complete?" answer. Check each item below, **state the result for every one** (the
detect-and-state rule governs this step — a silent pass is indistinguishable from an
unrun check), and carry every failure into the closing checklist as a named blocker.

Check, in order:

1. **git repository** — `git rev-parse --show-toplevel`. If absent, stop and ask: the
   hook's `.context/` state directory and the `.gitattributes` union merge both
   assume one, so nothing below is meaningful without it.
2. **superpowers plugin** — look for `superpowers:brainstorming`, `superpowers:writing-plans`
   and `superpowers:executing-plans` in the skills available to you *right now*. This
   is a hard prerequisite, not a nicety: the workflow's whole middle
   (spec → plan → execute) *is* those skills. Without them `intake` hands off to a
   skill that does not exist, and the gate hook's Gate-A pass counter — which only
   resets on those skill events — silently never fires, so Gate A degrades to no
   enforcement at all while still *looking* enforced. If they are absent, report
   `MISSING` with the install commands:
   `claude plugin marketplace add obra/superpowers-marketplace` then
   `claude plugin install superpowers@superpowers-marketplace`.
3. **Codex MCP** — the gates call `mcp__codex__exec` (Gate A, reviews text) and
   `mcp__codex__review` (Gate B, reviews a diff). These three states have different
   causes and different fixes, so report the one that actually holds — a single
   "codex: failed" sends the user hunting in the wrong place:

   | State | How to detect | What to report |
   |---|---|---|
   | **1 · not configured** | no `codex` entry in `.mcp.json` (or no `.mcp.json`) | `MISSING — Step 2.8 writes the entry; re-run /workflow-init or add it by hand` |
   | **2 · configured, not loaded** | the entry exists, but `mcp__codex__exec` / `mcp__codex__review` are not among your available tools | `NOT LOADED — restart the session (a new .mcp.json needs a one-time project-server approval). If it stays unavailable after a restart, the Codex CLI is not installed or not authenticated — it needs an OpenAI account; see the mcp-codex-dev docs.` |
   | **3 · ok** | both tools are available to you | `ok (pinned mcp-codex-dev@<version>)` |

   Check the tool *names* specifically, not just that "a codex server exists": a
   different Codex MCP may connect under the same server name while exposing a
   different tool surface, and the gates + the hook's pass counters key on
   `exec`/`review` by name. A server that is reachable but exposes neither is state 2,
   not state 3.

   This is the most likely way a setup that *looks* complete still counts nothing, so
   name it rather than leaving the user to infer it. The gates need **a Codex MCP server
   that exposes `exec` and `review`** — Step 2.8 pins `mcp-codex-dev`, which does. The
   official `codex mcp-server` is a different server: it exposes one `codex` tool (plus
   `codex-reply`), which cannot be attributed to Gate A (reviews TEXT) or Gate B (reviews
   a DIFF), so reviews run through it are invisible to the counters. If that is what is
   connected, report it as its own state and give both fixes:

   ```
   codex MCP             WRONG SERVER — connected, but exposes mcp__codex__codex, not
                                        exec/review. The gates cannot count it. Either
                                        switch to the pinned mcp-codex-dev (Step 2.8),
                                        or map the names in .context/codex-gate.tools:
                                          execTool=mcp__codex__codex
                                          reviewTool=<the diff-reviewing tool>
   ```

   Prefer switching servers over mapping: a mapping can only be honest if the server
   really has two tools that split text-review from diff-review. Mapping both gates onto
   one general-purpose tool makes the counters move without either gate meaning what it
   claims — a false ✓, which is worse than the STOP it silences.

   With no Codex reachable, **both review gates are inoperative** — the single most
   important thing this command can tell the user. If the user chooses not to set it
   up now, switch to the degraded mode in Step 2.13 rather than scaffolding gates that
   cannot run.
4. **`gh` CLI** — `command -v gh`. **Optional**: only `/dev-workflow:process-pr-review`
   needs it. Mark it optional so a missing `gh` doesn't read as a broken setup.
5. **AGENTS.md** — present or not. Absent is normal on a first run (Step 3 writes it);
   present means Step 3 reviews and extends it instead.
6. **Stack** — package manager (`pnpm-lock.yaml` / `package-lock.json` / `bun.lockb` /
   none), language, test runner, CI provider. This resolves the `TODO(stack)` markers.
   Detect, then *state what you detected* — do not silently assume.
7. **Existing targets** — note which files from Step 2 already exist, so Rule 2 (never
   overwrite without asking) applies before you write anything.

Print the result as a status block before you write a single file, so the user sees
what's missing while it is still cheap to fix:

```
Prerequisites:
  git repository        ok
  superpowers plugin    MISSING — claude plugin marketplace add obra/superpowers-marketplace
                                  claude plugin install superpowers@superpowers-marketplace
  codex MCP             configured, but tools not loaded — restart the session and approve the project server
  gh CLI                ok (optional — only /process-pr-review needs it)
  AGENTS.md             absent — Step 3 will write it
  stack                 pnpm · TypeScript · vitest · GitHub Actions
```

A missing prerequisite does **not** stop the scaffolding (the files are still worth
having, and a user often installs the missing piece right after). The exception is the
git check, which does stop. Everything else: scaffold, and name the blocker in the
closing checklist.

## Step 2 — Scaffold the files

Write each target from the template given below. `<YYYY-MM-DD>` is today's local
date; `<project>` is the repo's directory name unless the user says otherwise.

### 2.1 `CLAUDE.md` — the discipline rules

If a `CLAUDE.md` already exists with unrelated project content, do not overwrite it:
offer to **append** sections §1–§5 (renumbering only if the file already uses those
numbers) and say so in the report.

````markdown
# <project>

**Tradeoff:** These guidelines bias toward caution over speed. For trivial tasks, use judgment.

## 1. Think Before Coding

**Don't assume. Don't hide confusion. Surface tradeoffs.**

Before implementing:
- State your assumptions explicitly. If uncertain, ask.
- If multiple interpretations exist, present them - don't pick silently.
- If a simpler approach exists, say so. Push back when warranted.
- If something is unclear, stop. Name what's confusing. Ask.

## 2. Simplicity First

**Minimum code that solves the problem. Nothing speculative.**

- No features beyond what was asked.
- No abstractions for single-use code.
- No "flexibility" or "configurability" that wasn't requested.
- No error handling for impossible scenarios.
- If you write 200 lines and it could be 50, rewrite it.

Ask yourself: "Would a senior engineer say this is overcomplicated?" If yes, simplify.

## 3. Surgical Changes

**Touch only what you must. Clean up only your own mess.**

When editing existing code:
- Don't "improve" adjacent code, comments, or formatting.
- Don't refactor things that aren't broken.
- Match existing style, even if you'd do it differently.
- If you notice unrelated dead code, mention it - don't delete it.

When your changes create orphans:
- Remove imports/variables/functions that YOUR changes made unused.
- Don't remove pre-existing dead code unless asked.

The test: Every changed line should trace directly to the user's request.

## 4. Goal-Driven Execution

**Define success criteria. Loop until verified.**

Transform tasks into verifiable goals:
- "Add validation" → "Write tests for invalid inputs, then make them pass"
- "Fix the bug" → "Write a test that reproduces it, then make it pass"
- "Refactor X" → "Ensure tests pass before and after"

For multi-step tasks, state a brief plan:
```
1. [Step] → verify: [check]
2. [Step] → verify: [check]
3. [Step] → verify: [check]
```

Strong success criteria let you loop independently. Weak criteria ("make it work") require constant clarification.

Ground progress claims: before reporting a step as done, audit the claim against a tool result from this session ("tests green" needs a test run to point to). Report unverified work as unverified — this keeps status reports factual on long runs.

The work loop includes the review gates: **spec ready → Gate A (spec) → plan ready → Gate A (plan) → execute → tests green → Gate B → commit** (see §5).

## 5. Cross-Model Review (Codex) — TWO MANDATORY GATES

Independent second opinion at two gates. Easiest steps to skip, so the discipline is
yours — a non-blocking hook (shipped by the `dev-workflow` plugin) reminds you at
each. Opt out per-workspace with `.context/codex-gate.off` (delete to re-enable); the
gates still apply. The hook counts passes by TOOL NAME (`mcp__codex__exec` /
`mcp__codex__review`); if your Codex MCP server names them differently, map it in
`.context/codex-gate.tools` (`execTool=<name>` / `reviewTool=<name>`) — otherwise your
reviews are invisible to the counters and Gate B reports "not run" forever.

**Both gates are a LOOP with a HARD FLOOR: min 3 passes per run (Blocker/Major
only), counted by the hook.** The hook counts passes but can't read findings or
tell the spec run from the plan run (it resets at `writing-plans`), so Gate A —
the spec run especially — is instruction-backed: a satisfied count is not a clean
review. Open a TodoWrite "Codex pass N" per pass; fix Blocker/Major after each. Your
final pass must be clean — if pass 3 still finds Blocker/Major, keep going until
clean or clearly stuck → then STOP and surface to the user. The only early exit
below 3 is a pass with **zero** findings; don't manufacture findings to pad. Codex is
advisory — validate before applying; dismissed finding → one-line why.

- **Gate A — Spec, then plan (TWO runs, each its own 3-pass loop).** Run on the
  **spec** right after brainstorming (before `writing-plans`), then on the
  **plan** before `executing-plans`/`subagent-driven-development` — catching a
  spec flaw before it's baked into the plan. Tool: `mcp__codex__exec` (raw;
  reviews the TEXT you pass, not the git tree). Use ONE broad prompt, re-run it
  each pass over the revised artifact (don't narrow per-dimension; new findings
  surface because the artifact changes between passes). The prompt MUST open with
  *"Use the superpowers:brainstorming skill to review this spec,"* (say "plan" on
  the plan run), then ask Codex to check it against our settled decisions and
  surface **contradictions/inconsistencies, missing requirements, unhandled
  state/edge/error/empty/concurrent paths, and risks to the Key Invariants
  (@AGENTS.md) — plus anything else** (coverage floor, not a cage). Append the
  intent + artifact text + which invariants it touches. Ask for **every** finding
  with severity and confidence — you filter to Blocker/Major downstream, Codex
  never does, because a model told to report only high severity drops real
  findings silently. Ask for one line per finding and a literal `NO FINDINGS`
  when a pass is clean — the explicit clean signal is what lets you exit the loop:

  ```
  MAJOR | high | §3 "Retry policy" | retry count unbounded | a poisoned job loops forever | cap at 5, then dead-letter
  NO FINDINGS
  ```

  Each pass: validate, revise, re-run. (Large/high-risk artifact: optional focused
  per-dimension passes on top.)
- **Gate B — Code.** Tests green, before `git commit`. Tool: `mcp__codex__review`
  (args `instruction`, `whatWasImplemented`, `baseSha`; `reviewType: full` runs
  spec + quality in parallel). Skip ONLY trivial changes. Check against
  @AGENTS.md. Re-review after every fix — a fix changes the diff and the hook
  invalidates the prior pass, which is where the 3 come from. Same coverage rule
  as Gate A: put "report every finding with severity and confidence; say
  `NO FINDINGS` if clean" in `additionalContext`, with the same one-line format.

  **What counts as prose (the only Gate-B exemption).** Every staged path is
  explanatory documentation — `docs/**.md`, `README.md` → N/A. Those describe the
  product rather than being it, so they carry no gate at all. **Prompts are not
  prose:** skills, slash commands, agent instructions and anything under
  `.claude/` or `plugins/` are product even though they are `.md`, and so are
  `CLAUDE.md`/`AGENTS.md` — all fire full Gate B, as does any mixed commit or any
  non-`.md` file. The hook classifies paths the same way.

### Mechanics (reference)
- **Severity:** Blocker (wrong/unsafe/breaks invariant) · Major (design flaw →
  rework) → both must resolve. Minor · Nit → collect, never iterate.
- **Tool routing:** docs (spec/plan, incl. code snippets) → `mcp__codex__exec`;
  implemented diff → `mcp__codex__review`. Never `review` a doc — it reads the
  git range, not the text.
- **`baseSha`:** against main = merge-base with main (`headSha` = HEAD);
  pre-commit, `baseSha` = HEAD is an empty range (HEAD..HEAD) — make a WIP commit
  and set `baseSha` to its parent. **Name that commit `WIP: …`** — the hook treats a
  `wip`-prefixed commit message as cycle-internal, so it neither fires a Gate-B STOP
  nor resets your pass counters. A pre-review snapshot named anything else reads as a
  real commit and closes the cycle, discarding the passes you just accumulated.
  **Finishing the cycle:** after the final clean pass, close it with
  `git commit --amend -m "<real message>"` — that replaces the WIP commit, and the hook
  reads the amend as the real cycle-closing commit. If several WIP snapshots piled up,
  `git reset --soft <parent-of-first-WIP>` first, then commit once. Amend rather than a
  follow-up commit for two reasons: a `WIP: …` commit left in history defeats the naming
  convention it exists for, and a follow-up commit has nothing to commit when the review
  produced no fixes.
- **Timeout retry:** a codex call that dies at the MCP tool-call timeout is retried
  once before surfacing to the user — pass state persists in `.context/`, so an
  aborted call loses nothing.

---

**These guidelines are working if:** fewer unnecessary changes in diffs, fewer rewrites due to overcomplication, and clarifying questions come before implementation rather than after mistakes.

---

Project architecture, stack-specific patterns, and invariants live in @AGENTS.md
(single source of truth — also read directly by Codex and the PR review bots). The
Cross-Model Review gates (§5) check against the invariants there.
````

### 2.2 `docs/hardening-log.md` — the empty ledger

Write it **empty** (header only, no rows). The header defines the format; the rows
are this project's own history and start at zero.

````markdown
# Hardening log

Append-only ledger of review findings hardened via the `dev-workflow:harden-finding`
skill. One row per hardening (rung 0 "already caught" is not logged). `fingerprint`
is a canonical class — from the base taxonomy in the `harden-finding` skill, or from
this project's `docs/hardening-taxonomy.md`; column 2 is the recurrence-grep target.
Never edit a row; resolve a `pending` row by appending a new row (same fingerprint,
`ref` naming the prior row's date + anchor).

Columns: `date` (YYYY-MM-DD), `fingerprint` (canonical class), `finding` (short,
escape `\|`, one line), `source` (gate-a|gate-b|bot|manual),
`severity` (blocker|major|minor|nit), `rung` (e.g. `2 lint`, `4 test`, `1 prose`,
`P std`, `pending`), `ref` (rule name / test path / AGENTS.md section / prior row).

| date | fingerprint | finding | source | severity | rung | ref |
|------|-------------|---------|--------|----------|------|-----|
````

### 2.3 `docs/hardening-taxonomy.md` — this project's fingerprint classes

Also written **empty of classes**. The `harden-finding` skill ships the stack-neutral
base classes and reads this file for the project's own — so the shared plugin never
carries one project's domain vocabulary.

````markdown
# Hardening taxonomy — <project>

Project-specific fingerprint classes, extending the stack-neutral **base taxonomy**
in the `dev-workflow:harden-finding` skill. The skill reads both on every fingerprint
step; the base classes are not repeated here.

A class belongs here (not in the base list) when it names *this* project's entities,
frameworks, or invariants — e.g. a class about a specific table, a specific auth
helper, or a specific framework's API.

**Before minting:** grep the base list and this one for a near match. A slightly
imprecise class you reuse beats a precise class nobody greps for — recurrence
detection is the entire value, and it only works when the same defect maps to the
same string twice.

**Format:** kebab-case `domain-problem-class`, one line, with an alias hint naming
the synonyms a future reader might search for instead.

## Classes

<!-- Add classes as harden-finding mints them, e.g.:
- `orders-missing-idempotency-key` — a retryable order write accepted without an idempotency key
-->

_None yet — `dev-workflow:harden-finding` adds them as findings arrive._
````

### 2.4 `docs/prompt-standards.md` — the prompt checklist

The "Verified model-specific notes" block below carries a **read-date**, and the
notes under it are only as true as that date. Do not copy the date across: ask the
user whether they have re-read those pages for the models *they* run. If not, write
`read <YYYY-MM-DD> — NOT YET VERIFIED for this project's target models` and carry it
into the closing checklist. An inherited date presented as fresh is exactly the
failure this line exists to prevent.

````markdown
# Prompt Standards

Skills, gate prompts (CLAUDE.md §5), hook messages, slash commands, and spec/plan
templates are prompts. When authoring or changing one, it must pass the checklist
below — Gate A reviews skill specs against these criteria via AGENTS.md.

Living references (consult, don't copy — copies go stale):

- Anthropic prompting best practices: https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/claude-prompting-best-practices
- Model-specific pages (pick the target model's page): https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/overview
- OpenAI/Codex prompting guide — applies to the Codex gate prompts (Gate A/B
  run on an OpenAI model, not Claude): https://learn.chatgpt.com/docs/prompting
  (Codex-specific workflows are a section of that page.)

## Checklist (each item must be verifiably true)

1. **Target model named.** The prompt states which model executes it (Claude
   via Claude Code, or Codex via `mcp__codex__*`), and the author checked that
   model's current prompting page. Why: recommendations differ per model and
   change between generations.
2. **Success criteria explicit.** The prompt defines what "done" looks like in
   checkable terms (e.g. "typecheck exit 0", "story has ≥3 acceptance criteria"),
   never "make it good". Why: strong criteria let agents loop independently
   (CLAUDE.md §4).
3. **Stop conditions defined.** When to stop, escalate, or ask the user —
   especially for looping/agentic prompts. Why: prevents runaway loops and
   silent scope drift.
4. **Output format specified with an example.** Expected structure shown, not
   described. Why: examples constrain format better than prose.
5. **Structured sections.** Context → task → rules → output format, separated
   by headings or XML tags. Why: models parse delimited structure more
   reliably than flowing prose.
6. **Rules carry their why.** Each constraint states its reason in one clause.
   Why: models follow motivated rules better, and reviewers can judge whether
   the rule still applies.
7. **No contradictions with CLAUDE.md / AGENTS.md.** New prompt text must not
   conflict with existing instructions; if it supersedes one, update the old
   text in the same change. Why: contradictory instructions degrade
   compliance unpredictably.
8. **Token-lean.** No duplicated content from AGENTS.md/CLAUDE.md (reference
   instead), no boilerplate. Why: context budget is shared with the actual
   task.
9. **Positive instructions.** Say what to do, not what to avoid ("write
   flowing prose" instead of "don't use markdown"). Why: per Anthropic's best
   practices, positive framing steers current models more reliably. The
   CLAUDE.md §1–3 discipline rules are a deliberate exception: their subject *is*
   the prohibition ("no speculative abstractions", "don't refactor what isn't
   broken"), and restating a prohibition positively loses the boundary it draws —
   new prompts need a stated reason to do the same.
10. **Calibrated emphasis.** Reserve MUST/CRITICAL/ALL-CAPS for genuinely hard
    rules; default to plain wording ("Use X when …"). Why: current models follow
    instructions more literally and overtrigger on aggressive language
    (documented in the best-practices page). Existing heavy emphasis (e.g.
    CLAUDE.md §5 gate language) is a deliberate exception for discipline
    gates — new prompts need a stated reason to use it.

## Verified model-specific notes (read <YYYY-MM-DD> — re-verify per Revalidation)

Distilled from the model-specific pages; the linked pages are authoritative.

- **Less scaffolding on stronger models.** Skills/prompts written for prior
  models are often too prescriptive and degrade output quality on newer ones.
  On a model upgrade, test with instructions *removed* before adding more.
- **Review prompts: coverage first, filter later.** "Only report high-severity"
  makes current models silently drop real findings. The finding stage must ask for
  every issue with confidence + severity; ranking/filtering is a separate step.
  Gate B's Blocker/Major filter is downstream — the finding prompt itself must
  request full coverage.
- **Ground progress claims.** In long runs, instruct: audit each claim against
  a tool result before reporting; unverified work is reported as unverified.
  Belongs in executing/TDD prompts.
- **Fresh-context verifier subagents outperform self-critique** — independent
  confirmation of the cross-model gate design.
- **Never instruct "show your reasoning in the response".** Triggers a
  reasoning-extraction refusal on some current models; read structured thinking
  output instead.
- **Literal instruction following.** Current models don't generalize scope on
  their own — state it ("apply to every section, not just the first").

## Escalation

Recurring prompt-quality findings follow the same ladder as code findings
(CLAUDE.md): prose note → checklist item here → template change. Prompts are
artifacts; `harden-finding` treats them like code. Run the
`dev-workflow:harden-finding` skill to apply a rung and record it in
`docs/hardening-log.md`.

## Revalidation

On a model generation change (new Claude model in Claude Code, new Codex
model for the gates): re-check this doc against the then-current
model-specific pages, and update the read-date above. Tracked with the tooling
revalidation entry in `todos.md`.
````

### 2.5 `docs/pr-review-bots.md` — which bot actually finds things

The `/dev-workflow:process-pr-review` command reads this. Fill the table with the
user — ask which bots are enabled and, for each, **whether it posts line-by-line
review comments or only a summary**. Do not guess: the whole point of the file is
that a summary-only bot must never be waited on for line findings.

````markdown
# PR review bots — <project>

Which automated reviewers run on this repo, and what each one *actually produces*.
`/dev-workflow:process-pr-review` reads this file to decide **which bots to wait for**
(only those that post line-by-line findings) and which to treat as context only.

Getting this wrong is expensive in both directions: waiting on a bot that structurally
cannot post line comments hangs the loop, and reading a summary as a findings source
silently drops real findings.

| Bot | Enabled | Posts line-by-line findings | Notes (plan/tier limits, quirks) |
|---|---|---|---|
| <bot name> | yes/no | **yes** / no — summary only | <e.g. "Free plan: walkthrough only, never line comments"> |

**Wait for:** <the bots with "yes" in column 3 — process starts once each has posted, even with zero comments>
**Context only:** <the summary-only bots>

**Revisit when:** a bot's plan/tier changes (a Free→Pro upgrade can turn a
summary-only bot into a findings bot), or a bot is enabled/disabled.
````

### 2.6 `.gitattributes` — union merge for the ledger

**Merge, don't rewrite.** If the `docs/hardening-log.md` line is already present,
report `unchanged`. Otherwise append:

```gitattributes
# docs/hardening-log.md is an append-only ledger. Parallel worktrees may each
# append a row; a union merge keeps both lines instead of conflicting, so no
# hardening record is lost when branches merge.
docs/hardening-log.md merge=union
```

Do **not** add union merge for structured files (baselines, JSON, lockfiles) — a
union merge silently interleaves both sides into invalid state. Real changes to those
must conflict visibly so a human resolves them.

### 2.7 `todos.md` — skeleton

````markdown
# Todos — <project>

Backlog of stories, follow-ups, and prerequisites referenced by
`docs/hardening-log.md` (`pending` rows point here by `ref`).

## Now

## Next

## Someday

## Tooling revalidation
- [ ] Re-check `docs/prompt-standards.md` against the current model-specific
      prompting pages on every model-generation change (new Claude model in Claude
      Code, new Codex model for the gates).
````

### 2.8 `.mcp.json` — the Codex reviewer

**Merge, don't rewrite.** Add only the `codex` server if absent; leave any other
server untouched.

```json
{
  "mcpServers": {
    "codex": {
      "type": "stdio",
      "command": "npx",
      "args": ["-y", "mcp-codex-dev@1.0.1"],
      "env": {},
      "timeout": 2400000
    }
  }
}
```

Two properties are load-bearing, so state both to the user rather than letting them
look like arbitrary numbers:
- The version is **pinned**. An unpinned `npx -y <pkg>` executes latest-on-npm at
  launch, which bypasses any dependency-freshness policy. Pin it, and check the
  current version rather than trusting `1.0.1` to still be right.
- `timeout` is explicit. The default MCP tool-call timeout is very long, so a hung
  Codex call otherwise blocks until the user notices and aborts by hand.

### 2.9 Codex CLI config — a **manual** step, printed not written

Codex reads `~/.codex/config.toml` — the user's home directory, not this repo. Do not
write outside the project. Print this for the user to add, and list it in the closing
checklist:

```toml
# ~/.codex/config.toml — gives the Codex reviewer the same MCP servers you use.
# TODO(stack): one [mcp_servers.<name>] block per server Codex should reach
# (your database/backend MCP, docs MCP, …). Example shape:
[mcp_servers.<name>]
command = "npx"
# Pin the package exactly — a bare `<pkg>` resolves to whatever is newest at run
# time, so the reviewer's own toolchain would drift between runs. Bump deliberately.
args = ["<pkg>@<exact-version>", "mcp", "start"]
```

### 2.10 CI — the enforced gate

Write `.github/workflows/quality.yml` (or the equivalent for the detected CI
provider; if it isn't GitHub Actions, print the template and say you did not write
it). The **battery steps are stack-specific and stay marked** — a CI file that runs a
command the project doesn't have is worse than one that admits the gap.

````yaml
name: CI

on:
  pull_request:
  push:
    branches: [main]

concurrency:
  # PR events share a per-PR group so new pushes supersede stale runs; non-PR
  # events (push to main) get a unique per-run group so no pending main run is
  # ever replaced or canceled.
  group: ci-${{ github.event_name == 'pull_request' && github.event.pull_request.number || github.run_id }}
  cancel-in-progress: ${{ github.event_name == 'pull_request' }}

permissions:
  contents: read

jobs:
  quality:
    # Pin the runner to an OS release, not `ubuntu-latest`, and every action to a
    # commit SHA with a version comment: a major-only `@v4` moves under you, and a
    # moving CI dependency makes the run irreproducible. Resolve a tag to its SHA
    # with `gh api repos/<owner>/<repo>/commits/<tag> --jq .sha`. Bump deliberately.
    runs-on: ubuntu-24.04
    steps:
      - uses: actions/checkout@34e114876b0b11c390a56381ad16ebd13914f8d5 # v4.3.1

      # TODO(stack): toolchain setup for this project's language + package manager.
      # Install from a FROZEN LOCKFILE — a resolving install can silently pull new
      # code into CI and makes the run non-reproducible.
      # (Node/pnpm example — resolve these SHAs yourself before uncommenting:)
      # - uses: pnpm/action-setup@<sha>       # reads packageManager from package.json
      # - uses: actions/setup-node@49933ea5288caeca8642d1e84afbd3f7d6820020 # v4.4.0
      #   with:
      #     node-version-file: package.json   # reads engines.node
      #     cache: pnpm
      # - run: pnpm install --frozen-lockfile

      # TODO(stack): ONE quality command chaining the whole battery, so there is a
      # single thing CI runs and a single thing a human runs. It must be the same
      # command named in AGENTS.md § Commands. A typical battery:
      #   strict typecheck · linter at zero warnings · dead-code check ·
      #   duplication/health check against a baseline · tests across their environments
      # - run: <quality command>

      # TODO(stack): build, if the project has one.
      # - run: <build command>

      # Red until the battery above is actually wired. A workflow whose steps are
      # all commented-out TODOs passes while verifying nothing — and a green check
      # is exactly what someone reads as "the gate is working". Failing loudly is
      # the honest direction; delete this step once the TODO(stack) blocks are real
      # commands.
      - name: Refuse to be a green no-op
        run: |
          if grep -q 'TODO(stack)' .github/workflows/quality.yml; then
            echo "::error::quality.yml still has TODO(stack) markers — the battery is not wired."
            echo "This check fails on purpose: it verifies nothing yet, so it must not report green."
            echo "Wire the toolchain + quality command (see AGENTS.md § Commands), then delete this step."
            exit 1
          fi
````

After the workflow lands **and the battery actually runs green once**, the last mile
is a **repo setting**, not a file: make the `quality` check **required** in branch
protection. Order matters — requiring the check while it is still a no-op protects
nothing and buys false confidence. Until it is required the gate is a convention;
after, the platform enforces it. This is in the closing checklist.

### 2.11 Dependency-freshness policy

Only if the project uses pnpm — append to `pnpm-workspace.yaml` (merge; don't touch
existing keys):

```yaml
# Supply-chain policy: packages must be ≥24h old at install time (guards
# against fresh malicious releases). Applies to every machine/CI, not just
# a local pnpm config. Exceptions: add the package to minimumReleaseAgeExclude
# with a justification comment — never relax the global value ad hoc.
minimumReleaseAge: 1440
```

If the project does **not** use pnpm, do not fake it. Say so, and put the equivalent
in the closing checklist as an open item: this ecosystem's way to (a) pin tool
versions from one source of truth, (b) install from a frozen lockfile, and (c) delay
brand-new releases.

### 2.12 `.context/codex-gate.on` — the adoption marker

Write an empty `.context/codex-gate.on`. The gate hook is installed globally but the
workflow is adopted per project, so the hook stays **silent** in any repo that shows no
adoption — otherwise it would STOP commits in every unrelated project on the machine,
citing a `CLAUDE.md §5` that exists nowhere.

The hook accepts either signal: the §5 gate heading in `CLAUDE.md`, or this marker. §5
alone would do for a standard scaffold; write the marker anyway, because it is the one
that survives a project keeping its gate rules somewhere other than `CLAUDE.md`, and it
states the adoption instead of inferring it from a heading someone may reword.

**Commit it.** `CLAUDE.md` is committed, so a clone is adopted the moment it lands;
leaving the marker untracked would make adoption depend on who ran this command. (The
hook excludes `.context/` from its tree hash on both the tracked and untracked side, so
a committed marker does not disturb Gate B.)

Say in the report that this is what makes the hook speak in this project, and that
deleting it plus the §5 heading is the way to make it stop.

### 2.13 Degraded mode — only when Codex is unavailable

If the preflight found Codex in state 1 or 2, **ask** whether the user wants to set it
up now. If they do, stop and let them; the gates are most of the point. If they say
not now, do not scaffold a workflow that lies about itself — a project with mandatory
gate instructions that cannot run, plus a Gate-B STOP on every single commit forever,
is noise that trains the user to ignore the hook, and a hook people ignore is worse
than no hook. Instead, degrade explicitly:

1. Write `.context/codex-gate.off` so the hook stays silent (it keeps tracking state,
   so re-enabling later is accurate rather than stale).
2. Add one line at the very top of §5 in the scaffolded `CLAUDE.md`:

   ```markdown
   > **INACTIVE — Codex not configured; the gates below do not run.** Re-enable: set up
   > Codex (closing checklist item 5), then delete `.context/codex-gate.off`.
   ```

3. Make it the **top item** of the closing checklist, not a footnote.

**Do not offer a same-model fallback reviewer.** Cross-model independence is the whole
mechanism — a model reviewing its own work reproduces its own blind spots and returns a
clean review that means nothing, so being explicitly gateless is honest while being
implicitly self-reviewed is a false ✓, which is the exact failure this workflow exists
to prevent.

## Step 3 — Walk the user through `AGENTS.md`

`AGENTS.md` is the one file that **cannot** be scaffolded from a template: it is the
project's invariants, and both review gates plus the PR bots check against it. A
generic AGENTS.md is worse than none — it makes "check this against our invariants"
read as satisfied when nothing was actually checked.

So: **interview the user, write what they answer, and write nothing they didn't.**
Ask in small batches (2–4 questions), showing the section you'd write from their
answers before moving on. Where they don't know yet, write
`TODO — not yet decided` rather than a plausible guess, and carry it into the closing
checklist.

Cover, in this order:

1. **What the project is** — one paragraph: domain, users, what it does. Enough that
   a reviewer with no context can judge whether a change fits.
2. **Architecture** — the components, the boundaries between them, and the direction
   dependencies are allowed to point.
3. **Key invariants** — the heart of the file, and what Gate A/B check. These are the
   non-negotiables: every rule whose violation is a bug regardless of what the ticket
   said. Push for *specific and checkable*, not aspirational. Prompt them with the
   classes that most often belong here:
   - **Auth / authz:** what must every entry point do before touching data? Name the
     actual barrier function.
   - **Multi-tenancy:** what scopes a query — a workspace, an org, an account id?
   - **Data access:** required indexes, forbidden full scans, soft-delete semantics.
   - **Validation:** are inputs *and* outputs schema-validated at the boundary?
   - **Errors:** which error type is thrown, what may reach the client.
   - **Concurrency:** optimistic locking, idempotency keys, ordering guarantees.
   For each one they give: write the rule, and write *why* in one clause. A rule with
   its reason survives a reviewer asking "is this still true?"; a bare rule doesn't.
4. **Don'ts** — the forbidden patterns, including the dependency-freshness policy
   from §2.11 and anything the team has already been burned by.
5. **`## Commands`** — the concrete commands, because `harden-finding`,
   `process-pr-review` and the quality gate all resolve their generic "the project's
   lint/typecheck/test/quality command" against this section:

   ````markdown
   ## Commands

   | Role | Command |
   |---|---|
   | quality (the whole battery — what CI runs) | `<cmd>` |
   | typecheck | `<cmd>` |
   | lint | `<cmd>` |
   | test | `<cmd>` |
   | build | `<cmd>` |
   ````

   Only fill a row with a command you have **actually run in this session** and seen
   exit cleanly. An unverified command here silently breaks three other prompts. Run
   each one; if it fails or doesn't exist yet, write `TODO` and carry it to the
   checklist.

End Step 3 by showing the complete `AGENTS.md` and getting the user's explicit
approval before writing it — same rule as everywhere else: they see the bytes that
land.

## Step 4 — Print the closing checklist

Everything below is deliberately **not** scaffolded, because getting it wrong quietly
is worse than not having it. Print it as the last thing, tailored to what Step 1
detected and what Steps 2–3 left as TODO:

```
Remaining — stack-specific, yours to decide:

0. GATES INACTIVE — include this item FIRST, and only if degraded mode (2.13) was
   applied. Codex is not configured, so Gate A and Gate B do not run and the hook
   is silenced via .context/codex-gate.off. CLAUDE.md §5 is marked INACTIVE. This
   project currently has NO independent review gate — the cross-model check is the
   core of the workflow, so treat this as the top priority, not a nice-to-have.
   Re-enable: do item 5, then delete .context/codex-gate.off.

1. Quality battery — pick the tools behind each role and wire them into ONE
   command, then put that command in AGENTS.md § Commands and in the CI
   TODO(stack) block:
     · strict typecheck        · linter, zero warnings tolerated
     · dead-code detection     · duplication/health check
     · tests, across every environment they need
   Each tool: add it only when you have run it and seen it catch something real.
   A config line should record a verified necessity, not a hypothesis.

2. Fresh baselines — any tool that compares against a baseline (duplication,
   coverage) needs its FIRST baseline generated from this repo, in its own
   commit. Never bundle a re-baseline with feature work: a baseline that drifts
   inside a feature commit stops being a record of a decision.

3. Custom lint rules — the plugin ships two as EXAMPLES ONLY
   (examples/eslint-rules/: auth-before-db, returns-validator). They encode one
   stack's invariants and will not transfer. Read them for the shape — how an
   invariant from AGENTS.md becomes a mechanical rule — and write your own when
   harden-finding escalates a finding to rung 2.

4. Branch protection — make the CI `quality` check REQUIRED, but only AFTER the
   battery in item 1 is wired and has run green once. The scaffolded workflow
   fails on purpose while its TODO(stack) markers remain, so it cannot report a
   green check that verifies nothing. Requiring a no-op check protects nothing
   and buys false confidence; requiring a real one is the single highest-value
   item on this list.

5. Codex — the reviewer behind BOTH gates. Three parts, all required:
     · the Codex CLI, installed and authenticated (it needs an OpenAI account);
     · the codex MCP server in .mcp.json (Step 2.8 writes it, pinned), exposing
       mcp__codex__exec + mcp__codex__review — check the tool NAMES, since another
       Codex MCP can occupy the same server name with a different tool surface;
     · the ~/.codex/config.toml block printed above (home directory; not written
       by this command), giving Codex the MCP servers it should reach.
   Without all three, both gates are inoperative.

6. Superpowers — BLOCKER if the preflight reported it missing. The workflow's
   entire middle (spec -> plan -> execute) is superpowers:brainstorming /
   writing-plans / executing-plans. Without it, intake hands off to a skill that
   does not exist, and the hook's Gate-A counter never fires -- so Gate A looks
   enforced while enforcing nothing. It is an external prerequisite, not a
   dependency this plugin can vendor:
     claude plugin marketplace add obra/superpowers-marketplace
     claude plugin install superpowers@superpowers-marketplace
   (Omit this item entirely if the preflight found it.)

7. Prompt standards — set the "Verified model-specific notes (read …)" date in
   docs/prompt-standards.md by actually re-reading the model pages for the models
   you run. It is the one date in this kit that must not be inherited.
```

Then stop. Do not start using the workflow in the same turn — the user should read
what landed first.

## Report format

Close with the prerequisite block (Step 1) and the per-file table (Rule 5), then the
checklist — and nothing else:

```
Prerequisites:
  git repository        ok
  superpowers plugin    ok
  codex MCP             ok (pinned mcp-codex-dev@1.0.1)
  gh CLI                ok (optional)
  AGENTS.md             absent — written in Step 3
  stack                 pnpm · TypeScript · vitest · GitHub Actions

Scaffolded:
  CLAUDE.md                        written
  AGENTS.md                        written (3 TODOs — see checklist)
  docs/hardening-log.md            written (empty ledger)
  docs/hardening-taxonomy.md       written (no classes yet)
  docs/prompt-standards.md         written
  docs/pr-review-bots.md           written
  todos.md                         written
  .gitattributes                   merged (union-merge line added)
  .mcp.json                        merged (codex server added)
  .github/workflows/quality.yml    written (2 TODO(stack) blocks)
  pnpm-workspace.yaml              skipped (not a pnpm project — see checklist item 1)
```
