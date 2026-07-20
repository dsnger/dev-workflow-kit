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

**The product is prompts.** Skills, slash commands, agent definitions, hook reminder
messages and every template `/workflow-init` scaffolds are the deliverable — plus one
POSIX-shell hook.
There is no application code, so there is no typechecker to catch a defect; review and
`docs/prompt-standards.md` are the only gates a prompt passes through.

## Architecture

The tree below is the *meaningful* surface — the files a change is likely to touch or
break. Ordinary repo furniture (`.gitignore`, `.claude/settings.json`, generated state
under `.mcp/`) is deliberately absent, not overlooked.

```
README.md                         # what the kit is, setup, daily use, contributing
MANIFEST.md                       # inventory of source-files/, the frozen extraction seed
AGENTS.md                         # this file — the invariants both gates check
CLAUDE.md                         # discipline rules + the two review gates
todos.md                          # backlog; `pending` ledger rows point here by ref
.gitattributes                    # union merge for the append-only ledger
.mcp.json                         # the Codex reviewer, pinned
.claude-plugin/marketplace.json
.github/workflows/ci.yml          # lint + hook tests + invariant checks + validate
scripts/check-invariants.sh       # invariants 5 and 6, mechanically (rung 2)
scripts/check-invariants.test.sh  # its regression suite — reject/accept pairs
scripts/check-version-bump.sh     # invariant 12, mechanically — PR-only (rung 2)
scripts/check-version-bump.test.sh # its regression suite — policy/operational/accept
plugins/dev-workflow/
  .claude-plugin/plugin.json      # metadata only — no component keys (invariant 6)
  CHANGELOG.md                    # every manifest version, newest first
  skills/{intake,harden-finding}/SKILL.md
  agents/finding-triage.md        # read-only PR-comment checker (convention-loaded)
  commands/{workflow-init,process-pr-review}.md
  hooks/{hooks.json,codex-gate.sh,codex-gate.test.sh}
  examples/                       # ships, but never scaffolded — one stack's answers
docs/
  architecture.md                 # layout + the two non-obvious design decisions
  coding-workflow.md              # the methodology this plugin encodes
  getting-started.md              # first story, end to end
  prompt-standards.md             # the 12-item checklist every prompt must pass
  hardening-log.md                # append-only findings ledger (union-merged)
  hardening-taxonomy.md           # this project's fingerprint classes
  pr-review-bots.md               # the Wait-for routing list + where each bot's findings appear
  superpowers/{specs,plans,stories}/ # the approved artifacts behind past changes
source-files/                     # the extraction seed this repo was built from
```

**Boundaries.** `skills/`, `commands/`, `agents/` and `hooks/hooks.json` are loaded by convention
from their paths. The executable artifacts are the hook and its test, plus the two
repo-local CI checkers and their tests (`scripts/check-invariants.{sh,test.sh}` and
`scripts/check-version-bump.{sh,test.sh}`) — the hook ships in the plugin, the checkers
do not; everything else is text read by a model. `examples/` is reference material,
outside the loaded surface: never scaffolded or copied into a user's project, though it
does ship inside the plugin package.

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
   fingerprint of the effective index plus the included worktree content, as of the
   hook's invocation — a deliberate superset of any one commit's payload, so the gate
   errs toward firing: `git diff HEAD` for tracked content, a tree id written from the
   **effective index** (`GIT_INDEX_FILE` when set, else the git-dir index), and a tree
   id written from a throwaway index brought up to the worktree — so untracked paths,
   contents and file modes all count, minus `.context/`.
   The index component exists because `git commit` commits the index: without it, staging
   a change and reverting the file on disk read as unchanged and reported satisfied. An
   event-derived check misses a file changed through Bash (`sed -i`, `git apply`,
   codegen) and leaves a stale ✓ standing; so does a name-only view of untracked files,
   or any hand-rolled walk that re-derives what `git write-tree` already gets right
   (symlink targets, exotic path encodings, non-regular files). When the fingerprint
   cannot be computed it is the literal `unavailable`, which never matches — including
   against itself.
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
   `commands/`, `agents/` and `hooks/hooks.json` load automatically; a manifest key for them is
   redundant at best and fatal for hooks (duplicate-hooks error → the plugin does not
   load at all; fixed in 0.2.1). Manifest keys only for files outside convention paths.
7. **`examples/` is read-only reference.** Never scaffolded or copied into a user's
   project, never presented as a default — it encodes one stack's answers and will not
   transfer. It *does* ship inside the plugin package (the cache copies the plugin
   directory wholesale), which is why invariant 12 covers it: shipped-but-not-scaffolded
   is not the same claim as not-shipped, and reading it as the latter once made
   `examples/` look out of scope for the version-bump rule.
12. **A plugin change requires a version bump.** A pull request that changes any path
    under a `plugins/<name>/` directory **that still exists at HEAD** — `examples/`
    included, and no exemptions among the paths inside such a directory — must also
    change that plugin manifest's `version`, or CI fails. (Deleting a whole plugin
    directory is the one shape outside the rule, since nothing of it ships afterwards;
    deleting only its manifest while the directory survives fails closed.) The checker is
    `scripts/check-version-bump.sh`, run **on pull requests only**, with
    `scripts/check-version-bump.test.sh` as its suite. An installed copy lives under a
    version-keyed cache path, so an un-bumped change never reaches it: the machine keeps
    running the old code with no signal that it is stale. This was a convention first,
    and it failed twice — a machine ran 0.1.0 while main was at 0.4.0, and the 0.4.0
    bump had to be asked for during review; main was still carrying two un-released
    plugin commits when the check was written.
    **What the check does not catch** — the same list the script header and the ledger
    row carry, because a partial list is an overclaim: it verifies that a bump is
    *present*, not that it is right. It does not check: semantic correctness (a patch
    where a minor was due passes); direction (any different string passes, including a
    decrease); anything outside a `pull_request` event (a direct push to main bypasses it
    entirely); deletion of an entire plugin directory; any change to which directory the
    marketplace entry
    points at (rename, copy, or `source` repoint); two PRs branched from the same version
    each bumping to the same new one; and whether the version was ever released or tagged.

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
11. **Prompt changes pass `docs/prompt-standards.md`** — all 12 checklist items, for
    any skill, command, agent definition, hook message, or scaffolded template. The prompts are the
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
  declared in the manifest" — which is most of them. Note `convention[- ]load` only
  matches that word order, i.e. "convention-loaded" / "convention loading"; a sentence
  reading "loaded by convention" is caught by the `declare[sd]?` arm only when it also
  contains a form of *declare*, so read the hits rather than trusting the count.)
- **Never describe what a gate proves without checking what it actually compares.**
  Prose that overstates a mechanism is this repo's most persistent defect, and it
  regenerates: fixing the index-tree story took four Gate-B rounds because *each
  correction introduced a subtler version of the same claim* — "the tree-hash proves
  what was reviewed", then "what is being committed is what was reviewed", then "what a
  commit would actually carry", then "everything a commit could carry". Every round
  searched for the previous **phrase**, so a synonym survived. Search for the **claim**:
  `grep -rniE '(everything|anything|all content|any change)[^.]{0,80}\b(commit|fingerprint|hash)\b|\b(commit|fingerprint|hash)\b[^.]{0,80}(everything|anything|all content|any change)' --include='*.md' --include='*.sh' . | grep -vE 'source-files/|docs/superpowers/'`
  (The `\b` boundaries matter: without them `commit` matches `committed` and the
  recipe reports its own false positives.) Two things this does NOT do, stated so
  nobody mistakes it for a guard: nothing runs it
  in CI — it is a recipe a human runs — and an overclaim phrased without those totality
  words escapes it entirely. It raises the floor; it does not close the class. The
  underlying rule is the check itself: for every sentence about a gate, name the exact
  comparison the code performs, and delete any part of the sentence that outruns it.
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
| quality (the whole battery — what CI runs) | `shellcheck --shell=sh plugins/dev-workflow/hooks/codex-gate.sh && shellcheck --shell=sh --exclude=SC2015 plugins/dev-workflow/hooks/codex-gate.test.sh && shellcheck --shell=sh scripts/check-invariants.sh && shellcheck --shell=sh --exclude=SC2015 scripts/check-invariants.test.sh && shellcheck --shell=sh scripts/check-version-bump.sh && shellcheck --shell=sh scripts/check-version-bump.test.sh && sh plugins/dev-workflow/hooks/codex-gate.test.sh && sh scripts/check-invariants.test.sh && sh scripts/check-invariants.sh && sh scripts/check-version-bump.test.sh && sh scripts/check-version-bump.sh main && claude plugin validate . --strict` |
| typecheck | n/a — no typed sources (shell + markdown) |
| lint | `shellcheck --shell=sh plugins/dev-workflow/hooks/codex-gate.sh && shellcheck --shell=sh --exclude=SC2015 plugins/dev-workflow/hooks/codex-gate.test.sh && shellcheck --shell=sh scripts/check-invariants.sh && shellcheck --shell=sh --exclude=SC2015 scripts/check-invariants.test.sh && shellcheck --shell=sh scripts/check-version-bump.sh && shellcheck --shell=sh scripts/check-version-bump.test.sh` |
| test | `sh plugins/dev-workflow/hooks/codex-gate.test.sh` |
| invariant checks (5 pinning, 6 manifest) | `sh scripts/check-invariants.test.sh && sh scripts/check-invariants.sh` |
| invariant check (12 version bump) | `sh scripts/check-version-bump.test.sh && sh scripts/check-version-bump.sh main` |
| build | n/a — nothing is compiled or bundled |

**Prerequisites and pinning.** The quality command needs `shellcheck` (0.11.0 locally;
CI runs the pinned image `koalaman/shellcheck:v0.11.0`) and the `claude` CLI (CI pins
`@anthropic-ai/claude-code@2.1.207`). Bump both deliberately, per invariant 5.

**The `--exclude=SC2015` on the test file** is a single-code exclusion, not a blanket
disable: every other shellcheck rule still applies to that file. Its hits are all
`[ cond ] && pass "x" || fail "x"`, where `pass` is a bare `printf` whose only failure
mode is a broken stdout — which runs `fail` as well, producing a spurious FAIL rather
than a false pass. Revisit if `pass`/`fail` ever gain logic that can legitimately fail.

**`check-version-bump.sh main` has a precondition**, unlike everything else in the
battery: it compares *commits*, so run it once the work is committed (the Gate-B WIP
commit is the natural point) and against a base ref that is current. Run mid-loop with
the plugin edits still in the working tree, it reports clean — correctly, and
uselessly. CI passes the PR's own base ref instead of `main`. It is in the quality row
because that row claims to be what CI runs, and as of invariant 12 that includes this.

CI runs the parts as separate steps for readable failures; the chained form above
is the single command a human runs. One difference is deliberate: CI's version-bump
step is `pull_request`-only, while the local battery always runs it (on `main`, where
the merge-base is HEAD, it passes trivially).
