# AGENTS.md — dev-workflow-kit

Single source of truth for architecture and invariants. Read directly by Codex at both
review gates and by the PR review bots. Discipline rules live in @CLAUDE.md.

## What this project is

A Claude Code marketplace shipping one plugin, `dev-workflow`, which installs a
spec-driven workflow for building software with coding agents. It adds three
mechanisms: two independent cross-model review gates (a different model reviews the
design at Gate A and the diff at Gate B), a fingerprinted hardening ledger where a
recurring finding escalates one rung harder (prose → lint → type → test), and one
repo-enforced quality command. Users are developers running Claude Code.

**The product is prompts.** Skills, slash commands, hook reminder messages and every
template `/workflow-init` scaffolds are the deliverable — plus one POSIX-shell hook.
There is no application code, so there is no typechecker to catch a defect; review and
`docs/prompt-standards.md` are the only gates a prompt passes through.

## Architecture

The tree below is the *meaningful* surface — the files a change is likely to touch or
break. Ordinary repo furniture (`.gitignore`, `.claude/settings.json`, generated state
under `.mcp/`) is deliberately absent, not overlooked.

```
README.md                         # what the kit is, setup, daily use, contributing
MANIFEST.md                       # what each shipped file is and where it comes from
AGENTS.md                         # this file — the invariants both gates check
CLAUDE.md                         # discipline rules + the two review gates
todos.md                          # backlog; `pending` ledger rows point here by ref
.gitattributes                    # union merge for the append-only ledger
.mcp.json                         # the Codex reviewer, pinned
.claude-plugin/marketplace.json
.github/workflows/ci.yml          # lint + hook tests + invariant checks + validate
scripts/check-invariants.sh       # invariants 5 and 6, mechanically (rung 2)
scripts/check-invariants.test.sh  # its regression suite — reject/accept pairs
plugins/dev-workflow/
  .claude-plugin/plugin.json      # metadata only — no component keys (invariant 6)
  skills/{intake,harden-finding}/SKILL.md
  commands/{workflow-init,process-pr-review}.md
  hooks/{hooks.json,codex-gate.sh,codex-gate.test.sh}
  examples/                       # read, don't install — one stack's answers
docs/
  architecture.md                 # layout + the two non-obvious design decisions
  coding-workflow.md              # the methodology this plugin encodes
  getting-started.md              # first story, end to end
  prompt-standards.md             # the 11-item checklist every prompt must pass
  hardening-log.md                # append-only findings ledger (union-merged)
  hardening-taxonomy.md           # this project's fingerprint classes
  pr-review-bots.md               # which bot posts line findings vs. summary only
source-files/                     # the extraction seed this repo was built from
```

**Boundaries.** `skills/`, `commands/` and `hooks/hooks.json` are loaded by convention
from their paths. The executable artifacts are the hook and its test, plus
`scripts/check-invariants.sh` and its test (the hook ships in the plugin; the checker
is repo-local CI); everything else is text
read by a model. `examples/` is reference material, outside the loaded surface.

**Dependency direction.** The plugin depends on superpowers (skills it hands off to)
and on a Codex MCP server exposing both `exec` and `review` (the gates key on those
two tool names). Nothing may depend on this repo's internal layout — an installed
plugin lives under a version-keyed cache path, which is an implementation detail.

## Key invariants

Non-negotiable regardless of what the ticket said. Each states its reason, so a future
reader can judge whether it still holds.

### Hook

1. **The hook always exits 0.** It is advisory; a reminder that can fail closed would
   make the workflow unusable whenever Codex is down or the environment is odd.
2. **Loose in the firing direction.** On uncertainty, fire. A missed commit (false ✓)
   is the dangerous direction; a redundant warning is the accepted price.
3. **Gate-B validity is content-derived, never event-derived.** Invalidation compares a
   hash of the working tree — `git diff HEAD` plus a tree id written from a throwaway
   index, so untracked paths, contents and file modes all count, minus `.context/`. An
   event-derived check misses a file changed through Bash (`sed -i`, `git apply`,
   codegen) and leaves a stale ✓ standing; so does a name-only view of untracked files,
   or any hand-rolled walk that re-derives what `git write-tree` already gets right
   (symlink targets, exotic path encodings, non-regular files).
4. **POSIX `sh`, and `jq` is optional.** No bash-isms; correct behaviour via fallback
   parsing when `jq` is absent. The hook runs on machines whose environment we do not
   control, and CI invokes it with `sh`. Enforced mechanically by the lint command
   below (`shellcheck --shell=sh`), not by review alone.

### Packaging

5. **Every version pinned exactly.** No floating `npx -y <pkg>`, `@latest`, or
   major-only action ref (`actions/checkout@v4`), anywhere — CI, `.mcp.json`, docs,
   and the inline templates `/workflow-init` writes, since those propagate the pin
   policy into every initialized repo. A moving dependency makes a run irreproducible
   and bypasses any freshness policy. Bump deliberately.
   **Scope:** things that *execute* in a run — CI actions and runners, npm packages,
   Docker images, MCP servers. A `$schema` URL is editor metadata that no run reads, so
   it is outside the invariant (pinning one anyway is fine, not required).
   Three bounded exceptions, stated rather than silent: `source-files/` is a frozen
   extraction archive and is never edited (see MANIFEST.md); `runs-on` pins an Ubuntu
   *release* — GitHub still refreshes that image weekly, which only a container would
   fix, and this battery doesn't warrant one; and `claude plugin marketplace add
   <owner>/<repo>` takes no version or ref — the CLI offers no pinning syntax, so
   prerequisite plugins (superpowers, this kit) are addressed by name and revalidated
   on update, not pinned.
6. **The manifest never re-declares convention-loaded components.** `skills/`,
   `commands/` and `hooks/hooks.json` load automatically; a manifest key for them is
   redundant at best and fatal for hooks (duplicate-hooks error → the plugin does not
   load at all; fixed in 0.2.1). Manifest keys only for files outside convention paths.
7. **`examples/` is read-only reference.** Never installed, never copied by a command,
   never presented as a default — it encodes one stack's answers and will not transfer.

### Prompts and scaffolding

8. **`/workflow-init`'s templates stay inline** in the command body. Claude Code does
   not expand `${CLAUDE_PLUGIN_ROOT}` inside command markdown (verified), and the cache
   path is not an API — a command that read templates from disk would break the first
   time that layout changed.
9. **`/workflow-init` never overwrites silently.** Idempotent: missing → write;
   identical → report unchanged; present and different → show the diff and ask;
   additive files (`.gitattributes`, `.mcp.json`, …) → merge. Scaffolded project files
   accumulate real content, and a silent overwrite destroys it.
10. **The base taxonomy stays stack-neutral.** Project vocabulary — tables, auth
    helpers, framework APIs — goes only in that project's
    `docs/hardening-taxonomy.md`, never into the `harden-finding` skill. Otherwise one
    project leaks into every other.
11. **Prompt changes pass `docs/prompt-standards.md`** — all 11 checklist items, for
    any skill, command, hook message, or scaffolded template. The prompts are the
    product and nothing mechanical checks them.

## Don'ts

- **No `Co-Authored-By: Claude` / `Generated with` trailers** on commits. Stripped from
  15 commits once already; settings are configured to prevent recurrence.
- **Never `mcp__codex__review` a document.** It reads the git range, not the text you
  pass — a doc "reviewed" that way was not reviewed at all. Docs go to
  `mcp__codex__exec` (Gate A).
- **Never document a command that wasn't run.** An unverified command in § Commands
  silently breaks `harden-finding`, `process-pr-review` and the quality gate, which all
  resolve their generic command names against it.
- **Never state what the manifest declares without reading it.** Any sentence
  describing which components are declared vs. convention-loaded must be checked
  against `plugins/*/.claude-plugin/plugin.json` in the same change. Three sites said
  it declares `hooks` when it declares nothing at all: `docs/architecture.md` and
  `MANIFEST.md` shipped that claim, and this file's own layout tree was written with
  it before being corrected in the same PR. It is the same wrong belief that produced
  the 0.2.1 duplicate-hooks load failure, surviving in prose long after the code was
  fixed. `scripts/check-invariants.sh` pins the manifest itself; nothing mechanical
  can tell whether a sentence about it is true, so this rule is the only guard.
  Before editing any of those three, find every site that makes such a claim:
  `grep -rniE 'declare[sd]?|convention[- ]load' --include='*.md' . | grep -v source-files/`
  (A narrower pattern like `"manifest declares"` misses the ones phrased as "never
  declared in the manifest" or "loaded by convention" — which is most of them.)
- **Never rename or delete a doc section without grepping for references first.**
  `ci.yml` once pointed at a deleted README section; `MANIFEST.md` listed a `CLAUDE.md`
  that did not exist. Docs-drift is this plugin's own taxonomy class and this repo is
  its most frequent site. Before any rename or delete:
  `grep -rn "<old name/anchor>"` across the repo *and* the inline templates. The same
  applies to adding files: the layout tree above is part of the surface that drifts.
- **No dependency-freshness policy applies by ecosystem here** — this repo has no
  package manager and no runtime dependencies. Invariant 5 (exact pinning) is its
  equivalent, and it covers the tools CI installs.

## Commands

Every command below was run in this session and observed to exit 0.

| Role | Command |
|---|---|
| quality (the whole battery — what CI runs) | `shellcheck --shell=sh plugins/dev-workflow/hooks/codex-gate.sh && shellcheck --shell=sh --exclude=SC2015 plugins/dev-workflow/hooks/codex-gate.test.sh && shellcheck --shell=sh scripts/check-invariants.sh && shellcheck --shell=sh --exclude=SC2015 scripts/check-invariants.test.sh && sh plugins/dev-workflow/hooks/codex-gate.test.sh && sh scripts/check-invariants.test.sh && sh scripts/check-invariants.sh && claude plugin validate . --strict` |
| typecheck | n/a — no typed sources (shell + markdown) |
| lint | `shellcheck --shell=sh plugins/dev-workflow/hooks/codex-gate.sh && shellcheck --shell=sh --exclude=SC2015 plugins/dev-workflow/hooks/codex-gate.test.sh && shellcheck --shell=sh scripts/check-invariants.sh && shellcheck --shell=sh --exclude=SC2015 scripts/check-invariants.test.sh` |
| test | `sh plugins/dev-workflow/hooks/codex-gate.test.sh` |
| invariant checks (5 pinning, 6 manifest) | `sh scripts/check-invariants.test.sh && sh scripts/check-invariants.sh` |
| build | n/a — nothing is compiled or bundled |

**Prerequisites and pinning.** The quality command needs `shellcheck` (0.11.0 locally;
CI runs the pinned image `koalaman/shellcheck:v0.11.0`) and the `claude` CLI (CI pins
`@anthropic-ai/claude-code@2.1.207`). Bump both deliberately, per invariant 5.

**The `--exclude=SC2015` on the test file** is a single-code exclusion, not a blanket
disable: every other shellcheck rule still applies to that file. Its hits are all
`[ cond ] && pass "x" || fail "x"`, where `pass` is a bare `printf` whose only failure
mode is a broken stdout — which runs `fail` as well, producing a spurious FAIL rather
than a false pass. Revisit if `pass`/`fail` ever gain logic that can legitimately fail.

CI runs the parts as separate steps for readable failures; the chained form above
is the single command a human runs.
