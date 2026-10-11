# Kit living docs — ARCHITECTURE, PRD, TECH-STACK — Design

**Date:** 2026-10-11
**Story:** `docs/superpowers/stories/2026-10-11-kit-living-docs-architecture-prd-tech-story.md` (read the profile there, fresh)

Part A of K7: the kit repository adopts its own three-file docs model. Part B (the `project-docs`
skill, the scaffolded templates, intake's "Features touched") is a separate unit and is out of
scope here.

## 1. Settled decisions this design implements

- Daniel, 2026-10-11 11:38–11:44: explicit living files `docs/PRD.md`, `docs/ARCHITECTURE.md`,
  `docs/TECH-STACK.md`; `AGENTS.md` = index + invariants + conventions + § Commands; one
  authoritative source per statement.
- Orchestrator dev-workflow-kit-d4, 2026-10-11 15:25, under Daniel's sprint instruction (story §3
  change record): the binding sentences of Boundaries and Dependency direction stay in `AGENTS.md`
  as a list; the pointer to `docs/ARCHITECTURE.md` is descriptive; no new rule sentence.
- `.claude/review-gates.md`, moratorium ("Until the vision's §7 step 3 is marked shipped, no new
  sentence stating a rule … is added to `CLAUDE.md`, `AGENTS.md` or this file"). It binds every
  edit below. A moved or reworded existing sentence is not a new one; each one is traced to its
  baseline sentence in the PR (§6).

## 2. `docs/ARCHITECTURE.md` (replaces `docs/architecture.md`)

A git rename, so history follows the file. Sections, in order:

1. **Purpose** — one paragraph: what the file holds and that the methodology lives in
   `docs/coding-workflow.md` (the current opening, kept).
2. **Layout** — the repository tree, the only copy outside dated records. Start from `AGENTS.md`'s
   tree (the more complete of the two today). Keep its selection rule and its framing sentence
   ("The tree below is the *meaningful* surface …"), which moves here. Add `docs/ARCHITECTURE.md`,
   `docs/PRD.md` and `docs/TECH-STACK.md`, and remove `architecture.md`. Every path the tree names
   exists at the PR head (checked against `git ls-files`).
3. **Components** — the descriptive inventory from `AGENTS.md` Boundaries: the executable
   artifacts (hook and its test, the two CI checkers and their suites, the six Python reports and
   their suites), and that everything else is text read by a model. From the existing manifest
   paragraph of `docs/architecture.md` it keeps the descriptive fact (the manifest declares no
   components) and the history (the 0.2.1 duplicate-hooks failure), re-checked against
   `plugins/dev-workflow/.claude-plugin/plugin.json` in this change (AGENTS.md Don't, "Never state
   what the manifest declares without reading it"). Its rule parts (convention loading; manifest
   keys only for files outside convention paths) are replaced by links to the binding list and to
   invariant 6.
4. **Boundaries and dependency direction** — descriptive text only. For every binding sentence it
   links `AGENTS.md` § Architecture, "Boundaries (binding)", and for `examples/` it links
   invariant 7. It repeats neither.
5. **The two design decisions** — "Why `/workflow-init`'s templates are inline" and "Why Gate B
   verifies content, not events", moved verbatim.

## 3. `AGENTS.md`

- **Header line** "Single source of truth for architecture and invariants." is reworded to name
  invariants and conventions here and the architecture in `docs/ARCHITECTURE.md`. This rewording
  is descriptive.
- **§ Architecture** keeps its heading, so the existing citations of `## Architecture` in story §4
  sections and in intake's grep still find a section. Its body becomes:
  - The descriptive pointer, verbatim from the decision: "`docs/ARCHITECTURE.md` holds the
    repository tree, the components, the scripts' inventory and the two design decisions."
    Two more descriptive lines of the same kind: `docs/PRD.md` holds the product's problem,
    success measures, non-goals and feature map, and `docs/TECH-STACK.md` holds the tools the
    repo runs on and where each version is pinned.
  - **Boundaries (binding)**: exactly seven items. Each item's text is a verbatim fragment of
    the baseline Boundaries or Dependency-direction paragraph, with case and characters unchanged
    and only line breaks free, so every subject, path and destination stays as it was:
    1. `skills/`, `commands/`, `agents/` and `hooks/hooks.json` are loaded by convention from
       their paths.
    2. `scripts/ledger-metrics.{py,test.sh}`, `scripts/loop-usefulness.{py,test.sh}`,
       `scripts/spec-delta.{py,test.sh}` and `scripts/live-effort.{py,test.sh}` (read-only)
    3. `scripts/run-analytics.{py,test.sh}` (writes only its own store under
       `.context/telemetry/`)
    4. `scripts/status-view.{py,test.sh}` (writes only its page, cache and lock under
       `.context/status/`)
    5. the hook ships in the plugin, the checkers and the reports do not
    6. The plugin depends on superpowers (skills it hands off to) and on a Codex MCP server
       exposing both `exec` and `review` (the gates key on those two tool names).
    7. Nothing may depend on this repo's internal layout — an installed plugin lives under a
       version-keyed cache path, which is an implementation detail.

    The `examples/` sentence is not listed: invariant 7 is already its single source.
- **Removed from `AGENTS.md`**: the tree, its framing sentence, and the descriptive part of
  Boundaries (the inventory list and "everything else is text read by a model"). All of it now
  lives in `docs/ARCHITECTURE.md`.
- **Don'ts, reworded only where they point at the old place:**
  - "Never rename or delete a doc section …": "the layout tree above" becomes the layout tree in
    `docs/ARCHITECTURE.md`. This is the trigger AC-9 keeps.
  - "Never state what the manifest declares …": `docs/architecture.md` becomes "the former
    `docs/architecture.md` (now `docs/ARCHITECTURE.md`)" in the history sentence. Where the sentence
    says "any of those three", the site meant is now `docs/ARCHITECTURE.md`. Its grep recipe is
    unchanged.
- **Everything else is unchanged**: invariants, other Don'ts, § Commands with its prerequisites
  paragraph.

## 4. `docs/PRD.md`

- **Head**, at most 50 lines, made of three parts:
  - **Problem**: why the kit exists, for its users (developers running Claude Code). It links
    `AGENTS.md` "What this project is" for what the product is, and does not restate it.
  - **Success measures**: a table with the columns measure, how it is read, and source. Each row
    names the source of its current value (a command, or a section of a file) instead of copying a
    number, so the PRD does not drift. Rows:
    - maturity stage, from vision §3;
    - review-loop pass curves, from the provenance/curve lines and `scripts/loop-usefulness.py`;
    - hardening escalation per class, from `scripts/ledger-metrics.py`;
    - instruction size against its budget, from check 4g;
    - scaffolded `CLAUDE.md` template size against its budget, from check 4e.

    No target is invented. A proposed measure without a recorded source stays in the table,
    marked open.
  - **Non-goals**: a link to vision §8, with no restatement.
- **Feature map**, a table with the columns feature, status, and authoritative doc. Six rows:
  - review gates → `.claude/review-gates.md`;
  - hardening ledger → `plugins/dev-workflow/skills/harden-finding/SKILL.md` and
    `docs/hardening-log.md`;
  - intake → `plugins/dev-workflow/skills/intake/SKILL.md`;
  - scaffolding → `plugins/dev-workflow/commands/workflow-init.md` and `…/claude-init.md`;
  - telemetry reports → vision §7 step 2 and `docs/ARCHITECTURE.md` § Components;
  - orchestrator/lane → status "planned", linking vision §7 step 3.

  Each link resolves at the PR head.

## 5. `docs/TECH-STACK.md`

A table with the columns tool, role, and where its version lives. No version string appears in the
file. Rows:
- POSIX `sh` and `dash` → `AGENTS.md` § Commands, prerequisites (addressed by name);
- shellcheck → `.github/workflows/ci.yml` (image) and the prerequisites paragraph (local);
- `python3` → prerequisites (minimum);
- git → prerequisites (minimum);
- the `claude` CLI → `ci.yml`;
- Node.js (runs the `claude` CLI in CI) → `ci.yml`, the `setup-node` step's `node-version`;
- the Codex MCP server → `.mcp.json`;
- CI runner and actions → `ci.yml`;
- `jq` → invariant 4 (optional).

Invariant 5 holds trivially: the file names no executable reference, so it introduces no floating
one.

## 6. Other live files

- `README.md`: the link at the "Repo layout" sentence points to `docs/ARCHITECTURE.md`.
- `todos.md`: the open row "Re-verify invariant 8's `${CLAUDE_PLUGIN_ROOT}` claim" names
  `docs/ARCHITECTURE.md`, since the claim now lives there.
- `CLAUDE.md`, last paragraph: "Project architecture, stack-specific patterns, and invariants live
  in @AGENTS.md (single source of truth …)" is reworded to say that invariants, patterns and
  § Commands live in `@AGENTS.md` and the architecture lives in `docs/ARCHITECTURE.md`.
  Descriptive, no new rule.
- **Not touched**: dated records (`docs/superpowers/**` including the vision, CHANGELOG entries,
  `.context/`, `source-files/`), `plugins/**`. The vision §1 diagram line "reads the Architektur
  (AGENTS.md)" is a record and stays.
- **The PR lists** every removed, moved or reworded `AGENTS.md`/`CLAUDE.md` sentence next to its
  destination or new wording (AC-9).

## 7. Evidence (mode battery+check)

A named verification, because the property is about documents, not code. Both runs are recorded.
There are two kinds of check.

**Change checks**, which fail on the baseline `d9fee8e` and pass at the PR head. These are the
counterfactual:

- **Tree uniqueness (AC-2)**: the tree's distinctive line `plugins/dev-workflow/` inside a fenced
  block is found in exactly one tracked file outside the dated records, and that file is
  `docs/ARCHITECTURE.md`. On the baseline it is found in two (`AGENTS.md`, `docs/architecture.md`).
- **No stale link (AC-7)**: a case-sensitive `git grep -n "docs/architecture\.md"` outside the
  dated records returns only the "former" mention in `AGENTS.md`. On the baseline it also returns
  `README.md`, `todos.md` and `AGENTS.md`'s live uses.
- **Descriptive text gone from `AGENTS.md` (AC-9)**: "The executable artifacts are" and
  "is the *meaningful* surface" are absent from `AGENTS.md` at the head. Both are present on the
  baseline.
- **No version string (AC-6)**: `docs/TECH-STACK.md` exists and contains no `[0-9]+\.[0-9]+`
  match. On the baseline the file is absent.
- **Binding list in place (AC-9)**: `AGENTS.md` has a "Boundaries (binding)" list whose items,
  with whitespace collapsed to single spaces, equal the seven expected fragments of §3 one to one
  and in order. A shortened, replaced, duplicated, dropped or added item fails it. On the baseline
  there is no such list.

**Preservation check**, which runs on the baseline only and is no counterfactual:

- **Expected fragments are baseline text (AC-9)**: each of the seven complete fragments listed in
  §3, with whitespace collapsed to single spaces, is a case-sensitive substring of the baseline
  `AGENTS.md` (`git show d9fee8e:AGENTS.md`) with whitespace collapsed the same way. Together with
  "Binding list in place", this shows that the head list carries exactly the baseline's binding
  text.

**Battery**: the full quality command green, check 4g included. It is not a change check.
`AGENTS.md` byte size is reported before (27,294) and after.

No CI check is added; a mechanical link checker waits for Part B's drift numbers (prompt K7).

## 8. Gates

Gate A on this spec and then on the plan, each with floor 3 (cited story at level 1) and cap 5.
Gate B on the diff, which touches `AGENTS.md` and `CLAUDE.md`, so it is not prose-exempt. No path
under `plugins/` changes, so no version bump is needed.
