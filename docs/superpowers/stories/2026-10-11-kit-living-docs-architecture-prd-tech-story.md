# Kit living docs — ARCHITECTURE, PRD, TECH-STACK — Story

**Date:** 2026-10-11 · **Size:** story
**Risk:** standard · **Security:** none · **Validation:** battery+check

## 1. Problem statement
The kit's repository tree is written twice: once in `AGENTS.md` § Architecture and once in
`docs/architecture.md` § Layout. Plans that add a file have to edit both copies, and Gate B has
caught the two drifting apart more than once. Docs-drift is the repo's most frequent hardening
class. The kit also has no single page that says what the product is for, how success is
measured, and which features it has today. And there is no single page that says which tools
and versions it runs on: the pins are spread across CI, `.mcp.json` and the `AGENTS.md`
prerequisites paragraph.

Daniel decided a three-file docs model on 2026-10-11 (11:38–11:44): `docs/PRD.md`,
`docs/ARCHITECTURE.md`, `docs/TECH-STACK.md`, with `AGENTS.md` as the index plus invariants,
conventions and § Commands, and one authoritative source for every statement. This story applies
that model to the kit's own repository (K7 Part A). The `project-docs` skill and the scaffolded
templates are Part B, a separate unit.

## 2. Desired outcome
The kit repository follows its own docs model. Every statement about architecture, product and
tech stack lives in exactly one file. `AGENTS.md` points to those files instead of copying them,
and keeps everything else it says today. No plugin file changes.

## 3. Acceptance criteria
_IDs are permanent once the story is committed: never renumber or reuse one; a new criterion takes the next number unused here and on the branch it merges into, and a collision stops for a human; a removed one stays, struck through and dated; a narrowed one keeps its ID with a dated note; cite as `<story path> AC-<n>`; full rules: dev-workflow:intake, "Acceptance-criterion IDs"._
- [ ] **AC-1** `docs/ARCHITECTURE.md` exists and `docs/architecture.md` no longer does. `docs/ARCHITECTURE.md` carries the repository tree, the components, the two design decisions now in `docs/architecture.md`, the boundaries and the dependency direction.
- [ ] **AC-2** The repository tree appears in exactly one tracked file outside the dated records, and that file is `docs/ARCHITECTURE.md`.
- [ ] **AC-3** `AGENTS.md` no longer contains the tree, the Boundaries paragraph or the Dependency-direction paragraph. In their place it has a pointer to `docs/ARCHITECTURE.md` that says when to read it. Every other sentence of `AGENTS.md` (invariants, Don'ts, § Commands and the rest) is still present, apart from wording that referred to the tree's old place, and each such rewording is listed in the PR.
- [ ] **AC-4** `docs/PRD.md` exists with a head of at most one page (problem, success measures, non-goals) and a feature map with six rows: review gates, hardening ledger, intake, scaffolding (`/workflow-init`, `/claude-init`), telemetry reports, and orchestrator/lane (status: planned, vision step 3). Each row links the feature's doc, or the authoritative spec where no doc exists yet.
- [ ] **AC-5** Every success measure in `docs/PRD.md` names its source: the vision's §3 maturity ladder or a number already on record (pass curves, template sizes, ledger metrics). No new target is invented; a measure with no recorded source is marked open.
- [ ] **AC-6** `docs/TECH-STACK.md` lists sh/dash, shellcheck, python3, git, the claude CLI, the Codex MCP server and the CI images. Each entry points to the file where its version lives, and no version string is copied into `docs/TECH-STACK.md`.
- [ ] **AC-7** No live tracked file outside the dated records links to `docs/architecture.md`, verified by grep over the repository. A historical mention of the old file name inside an `AGENTS.md` Don't is a record, not a link: it stays, worded as "the former `docs/architecture.md`". Dated records (stories, specs, plans, replays, CHANGELOG entries, `.context/`) are unchanged.
- [ ] **AC-8** No path under `plugins/` changes, so no version bump is needed. The quality battery passes, check 4g included, and the PR reports the size of `AGENTS.md` before (27,294 bytes) and after.

## 4. Affected AGENTS.md invariants
- `## Architecture` — "The tree below is the *meaningful* surface — the files a change is likely to touch or break."
- `## Key invariants` › Packaging, 5 — "**Every version pinned exactly.** No floating `npx -y <pkg>`, `@latest`, or major-only action ref (`actions/checkout@v4`), anywhere — CI, `.mcp.json`, docs, …"
- `## Don'ts` — "**Never rename or delete a doc section without grepping for references first.** … The same applies to adding files: the layout tree above is part of the surface that drifts."
- `## Don'ts` — "**Never state what the manifest declares without reading it.** … Three sites said it declares `hooks` when it declares nothing at all: `docs/architecture.md` and `MANIFEST.md` shipped that claim, and this file's own layout tree was written with it …"
- `## Don'ts` — "**Never document a command that wasn't run.** An unverified command in § Commands silently breaks `harden-finding`, `process-pr-review` and the quality gate …"
- `## Commands` — "**Check 4g measures exactly two files.** It fails when this repository's `CLAUDE.md` plus `AGENTS.md` exceed 150,000 characters …"

## 5. Open questions
- None. Three questions were answered on 2026-10-11 by the orchestrator (dev-workflow-kit-d4), under Daniel's sprint instruction:
  - Boundaries and Dependency direction move to `docs/ARCHITECTURE.md`, and `AGENTS.md` keeps a one-line pointer.
  - Dated records stay untouched.
  - PRD success measures come from vision §3 and numbers already on record.

## 6. Suggested size
story — one docs restructure, one spec → plan → PR, no plugin change.
