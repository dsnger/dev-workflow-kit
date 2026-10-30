# AGENTS.md — dev-workflow-kit

Single source of truth for invariants and conventions; the architecture lives in
`docs/ARCHITECTURE.md`. Read directly by Codex at both
review gates and by the PR review bots. Discipline rules live in @CLAUDE.md.

## What this project is

A Claude Code marketplace shipping one plugin, `dev-workflow`, which installs a
spec-driven workflow for building software with coding agents. It adds three
mechanisms: two independent cross-model review gates (a different model reviews the
design at Gate A and the diff at Gate B), a fingerprinted hardening ledger where a
recurring finding is hardened with lint or a test, and one
repo-enforced quality command. Users are developers running Claude Code.

**The product is prompts.** Skills, slash commands, agent definitions, hook reminder
messages and every template `/workflow-init` scaffolds are the deliverable — plus one
POSIX-shell hook.
There is no application code, so there is no typechecker to catch a defect; review and
`docs/prompt-standards.md` are the only gates a prompt passes through.

## Architecture

`docs/ARCHITECTURE.md` holds the repository tree, the components, the scripts' inventory, the
two design decisions and the incidents behind some rules below. `docs/PRD.md` holds the product's problem, success measures, non-goals and
feature map. `docs/TECH-STACK.md` holds the tools the repo runs on and where each version is
pinned.

### Boundaries (binding)

1. `skills/`, `commands/`, `agents/` and `hooks/hooks.json` are loaded by convention from
   their paths.
2. `scripts/ledger-metrics.{py,test.sh}`, `scripts/loop-usefulness.{py,test.sh}`,
   `scripts/spec-delta.{py,test.sh}` and `scripts/live-effort.{py,test.sh}` (read-only)
3. `scripts/run-analytics.{py,test.sh}` (writes only its own store under
   `.context/telemetry/`)
4. `scripts/status-view.{py,test.sh}` (writes only its page, cache and lock under
   `.context/status/`)
4a. `scripts/worktree-cleanup.{sh,test.sh}` (reads; in both modes creates and removes its lock
   directory under the git common dir; with `--remove` removes only the worktrees and local
   branches its report marks removable, and writes `<main>/.context/archive-worktree-*`; never a
   remote branch). Run by the orchestrator or the human, never by the session in a worktree.
4b. `scripts/local-ci.{sh,test.sh}` (reads, including with `--from` one commit's statuses; creates and
   removes one temporary worktree under a `mktemp -d` directory, none in an inherited lane; posts one
   commit status to GitHub; never fetches, pushes, prunes,
   changes a ruleset, a workflow's state, a branch or a remote). Since 0.49 the same bytes ship as
   `/workflow-init`'s `### 2.22` template, which check 4m keeps identical.
4c. `.agents/skills/gate-b-review/scripts/run-tests.sh` and `scripts/gate-b-run-tests.test.sh` (reads the
   reviewed checkout; creates and removes one `mktemp -d` copy under `TMPDIR` made by `git clone --no-local`,
   never `git worktree add`; removes only earlier copies whose runner and process group are both gone) and
   `.agents/skills/gate-b-review/scripts/risk-pass.sh` and `scripts/gate-b-risk-pass.test.sh` (runs `codex
   exec`; writes only under `.context/codex-reviews/`: its attempt files, the canonical findings file, its lock
   and lines appended to the cycle state file). Run by the Gate B reviewer and the main session. Since 0.51
   they and the skill's `SKILL.md` ship as `/workflow-init`'s `### 2.24`–`### 2.26` templates, which check 4o
   keeps identical.
5. the hook ships in the plugin, the checkers and the reports do not (the docs link checker's
   text ships only as `/workflow-init`'s `### 2.21` template, which check 4l keeps
   byte-identical to `scripts/check-doc-links.sh`; `scripts/local-ci.sh` likewise as `### 2.22`,
   kept by check 4m)
6. The plugin depends on superpowers (skills it hands off to) and on a Codex MCP server
   exposing both `exec` and `review` (the gates key on those two tool names). Initialized
   projects that have third-party dependencies also depend on the Context7 MCP server, which
   `/workflow-init` writes pinned into their `.mcp.json`; the library-API rule in the gate
   rules needs it, and falls back to the library's own docs when it is unavailable.
7. Nothing may depend on this repo's internal layout — an installed plugin lives under a
   version-keyed cache path, which is an implementation detail.

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
   The index counts because `git commit` commits the index: without it, staging a change
   and reverting the file on disk read as satisfied. An event-derived check (it misses a
   file changed through Bash), a name-only view of untracked files, or a hand-rolled walk
   instead of `git write-tree` each leave a stale ✓ standing ([why](docs/ARCHITECTURE.md#why-gate-b-verifies-content-not-events)). When the fingerprint
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
   `scripts/check-invariants.sh` checks `uses:` refs, runners, `npx -y` and YAML
   `node-version:`; it does not check `npm install -g` or a `docker run` image, so review
   is the only guard there.
   Four bounded exceptions, stated rather than silent: `source-files/` is a frozen
   extraction archive and is never edited (see MANIFEST.md); `runs-on` pins an Ubuntu
   *release* — GitHub still refreshes that image weekly, which only a container would
   fix, and this battery doesn't warrant one; and `claude plugin marketplace add
   <owner>/<repo>` takes no version or ref — the CLI offers no pinning syntax, so
   prerequisite plugins (superpowers, this kit) and the optional companion Ponytail
   (`/workflow-init` Step 1 item 9) are addressed by name and revalidated on update, not
   pinned.
   The fourth applies to **the optional codebase-memory MCP integration only**
   (`/workflow-init` 2.14–2.15), and to no other user-installed MCP server
   (Daniel, 2026-10-07, decision D1 in
   `docs/superpowers/specs/2026-10-07-codebase-memory-mcp-bounded-context-design.md`).
   The kit only restricts that server: it never installs, configures or registers it.
   Its binary is therefore not pinned at launch on these paths: P1, ordinary sessions starting
   it from the user's own entry; P2, the canary session; P3, the canary's fixture indexing,
   against an isolated store; P4, a `claude mcp get` the user runs; P5, a refresh the user
   runs; P6, Codex-preflight health commands, left to the user whenever this server is
   configured. **What stands in for a pin:** its source, version and sha256 are recorded;
   before every kit-run launch (P2, P3) the binary is compared against that record; a
   mismatch invalidates the earlier evidence, and nothing launches until a human reassesses
   the binary and re-records it. This is detection after a change, not a pin: P1 runs whatever binary the user's entry names.
   P1 also carries a load risk: with the server's `auto_watch` on (the 0.9.0 default), every session's
   instance registers a git watcher, and one pull that renamed hundreds of files made about 27 instances
   re-index one repository at once (2026-10-25). `/workflow-init` 2.14 therefore recommends that the user
   turns it off and refreshes by hand (P5); the kit itself sets nothing.
6. **The manifest never re-declares convention-loaded components.** `skills/`,
   `commands/`, `agents/` and `hooks/hooks.json` load automatically; a manifest key for them is
   redundant at best and fatal for hooks (duplicate-hooks error → the plugin does not
   load at all; fixed in 0.2.1). Manifest keys only for files outside convention paths.
7. **`examples/` is read-only reference.** Never scaffolded or copied into a user's
   project, never presented as a default — it encodes one stack's answers and will not
   transfer. It *does* ship inside the plugin package (the cache copies the plugin
   directory wholesale), which is why invariant 12 covers it: shipped-but-not-scaffolded
   is not the same claim as not-shipped.
12. **A plugin change requires a version bump.** A pull request that changes any path
    under a `plugins/<name>/` directory **that still exists at HEAD** — `examples/`
    included, and no exemptions among the paths inside such a directory — must also
    change that plugin manifest's `version`, or CI fails. (Deleting a whole plugin
    directory is the one shape outside the rule, since nothing of it ships afterwards;
    deleting only its manifest while the directory survives fails closed.) The checker is
    `scripts/check-version-bump.sh`, run **on pull requests only**, with
    `scripts/check-version-bump.test.sh` as its suite. An installed copy lives under a
    version-keyed cache path, so an un-bumped change never reaches it: the machine keeps
    running the old code with no signal that it is stale. As a convention it failed twice
    (the script header tells how).
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
   time that layout changed. Inline does not mean always loaded: the scaffolded
   `CLAUDE.md` holds §5 as a pointer, and the rules go to `.claude/review-gates.md`
   (template `### 2.1a`), because inline they would put an initialized project past
   Claude Code's instruction-file limit. Check 4e in `scripts/check-invariants.sh` fails
   when the `CLAUDE.md` template passes 20,000 characters; it measures that template only.
9. **`/workflow-init` never overwrites silently.** Idempotent: missing → write;
   identical → report unchanged; present and different → show the diff and ask;
   additive files (`.gitattributes`, `.mcp.json`, …) → merge. Scaffolded project files
   accumulate real content, and a silent overwrite destroys it.
10. **The base taxonomy stays stack-neutral.** Project vocabulary — tables, auth
    helpers, framework APIs — goes only in that project's
    `docs/hardening-taxonomy.md`, never into the `harden-finding` skill. Otherwise one
    project leaks into every other.
11. **Prompt changes pass `docs/prompt-standards.md`** — all 12 checklist items, for
    any skill, command, agent definition, hook message, or scaffolded template. The
    prompts are the product, and **no comprehensive mechanical checker exists for them**:
    review is the gate. Seven narrow checks in `scripts/check-invariants.sh` pin one
    spelling each: 4a the `Target model:` line, 4b a checklist-count claim, 4c the
    finding-severity closed set, 4d the `intake` story template's `AC-<n>` rows, 4f the
    `intake` amendment route's change-record template and closed sets, 4h the seven
    ledger-check record lines, 4k the ten secret deny lines in `/workflow-init` `### 2.17`.
    None establishes that the prose around its lines is right or that an agent or a written
    story or record follows them (4d: nor the worked example or a later renumbering; 4k: nor
    that the rules work in Claude Code, the JSON is valid or an agent merges them correctly into a
    project); each check's header comment documents its mechanism and known limits, without
    claiming the list is exhaustive. They are a floor, not coverage. Every other item is judged by a reader.

## Don'ts

- **No `Co-Authored-By: Claude` / `Generated with` trailers** on commits. Settings are
  configured to prevent them ([history](docs/ARCHITECTURE.md#incidents-behind-the-agentsmd-rules)).
- **Never `mcp__codex__review` a document.** It reads the git range, not the text you
  pass — a doc "reviewed" that way was not reviewed at all. Docs go to
  `mcp__codex__exec` (Gate A).
- **Never document a command that wasn't run.** An unverified command in § Commands
  silently breaks `harden-finding`, `process-pr-review` and the quality gate, which all
  resolve their generic command names against it.
- **Never state what the manifest declares without reading it.** Any sentence
  describing which components are declared vs. convention-loaded must be checked
  against `plugins/*/.claude-plugin/plugin.json` in the same change: the wrong belief
  behind the 0.2.1 duplicate-hooks load failure survived in prose long after the code was
  fixed ([history](docs/ARCHITECTURE.md#incidents-behind-the-agentsmd-rules)).
  `scripts/check-invariants.sh` pins the manifest itself; nothing mechanical
  can tell whether a sentence about it is true, so this rule is the only guard.
  Before editing `docs/ARCHITECTURE.md`, `MANIFEST.md`, this file, or such a sentence anywhere
  else, find every site that makes such a claim:
  `grep -rniE 'declare[sd]?|convention[- ]load' --include='*.md' . | grep -v source-files/`
  (A narrower pattern like `"manifest declares"` misses the ones phrased as "never
  declared in the manifest" — which is most of them. Note `convention[- ]load` only
  matches that word order, i.e. "convention-loaded" / "convention loading"; a sentence
  reading "loaded by convention" is caught by the `declare[sd]?` arm only when it also
  contains a form of *declare*, so read the hits rather than trusting the count.)
- **Never describe what a gate proves without checking what it actually compares.**
  Prose that overstates a mechanism is this repo's most persistent defect, and it
  regenerates: each correction tends to introduce a subtler synonym of the same claim, so a
  search for the previous **phrase** lets the synonym survive
  ([history](docs/ARCHITECTURE.md#incidents-behind-the-agentsmd-rules)). Search for the **claim**:
  `grep -rniE '(everything|anything|all content|any change)[^.]{0,80}\b(commit|fingerprint|hash)\b|\b(commit|fingerprint|hash)\b[^.]{0,80}(everything|anything|all content|any change)' --include='*.md' --include='*.sh' . | grep -vE 'source-files/|docs/superpowers/'`
  (The `\b` boundaries matter: without them `commit` matches `committed` and the
  recipe reports its own false positives.) Two things this does NOT do, stated so
  nobody mistakes it for a guard: nothing runs it
  in CI — it is a recipe a human runs — and an overclaim phrased without those totality
  words escapes it entirely. It raises the floor; it does not close the class. The
  underlying rule is the check itself: for every sentence about a gate, name the exact
  comparison the code performs, and delete any part of the sentence that outruns it — and
  where the sentence says what the mechanism does *not* cover, name the axes it was checked
  against and state whether that list is exhaustive, because an enumeration read as complete
  guarantees the axes it omits.
- **Never replace a decision procedure without accounting for its old conditions.** List
  what the previous prose required, then mark each one kept, moved, or deliberately
  dropped. A rewrite reliably preserves the condition that motivated it and silently loses
  the others ([history](docs/ARCHITECTURE.md#incidents-behind-the-agentsmd-rules)). Amending one
  criterion also does not touch the prose that motivated it, so check the surrounding
  paragraphs of any rule you amend. No tool decides this: a dropped condition looks
  exactly like text that was never there.

- **Never rename or delete a doc section without grepping for references first.**
  Docs-drift is this plugin's own taxonomy class and this repo is its most frequent site
  ([history](docs/ARCHITECTURE.md#incidents-behind-the-agentsmd-rules)). Before any rename or delete:
  `grep -rn "<old name/anchor>"` across the repo *and* the inline templates. The same
  applies to adding files: the layout tree in `docs/ARCHITECTURE.md` is part of the surface that drifts.
- **Never splice data into shell source a prompt tells the agent to run without bounding it.**
  A value filled into a command or here-document — a directory name, a user's answer — is shell
  text once it is there, and a quoted here-document delimiter stops expansion but not a line that
  ends the document. State the rule the value must meet, the check, and what happens when it fails
  ([history](docs/ARCHITECTURE.md#incidents-behind-the-agentsmd-rules)). Nothing mechanical finds this; it is a reading check.
- **No dependency-freshness policy applies by ecosystem here** — this repo has no
  package manager and no runtime dependencies. Invariant 5 (exact pinning) is its
  equivalent, and it covers the tools CI installs.

## Commands

Every command below was run in this session and observed to exit 0.

| Role | Command |
|---|---|
| quality (the whole battery — what CI runs, and what `scripts/local-ci.sh` runs on the Mac when the Actions budget is used up or local is chosen) | `shellcheck --shell=sh plugins/dev-workflow/hooks/codex-gate.sh && shellcheck --shell=sh --exclude=SC2015 plugins/dev-workflow/hooks/codex-gate.test.sh && shellcheck --shell=sh scripts/check-invariants.sh && shellcheck --shell=sh --exclude=SC2015 scripts/check-invariants.test.sh && shellcheck --shell=sh scripts/check-version-bump.sh && shellcheck --shell=sh scripts/check-version-bump.test.sh && shellcheck --shell=sh --exclude=SC2015 scripts/ledger-metrics.test.sh && shellcheck --shell=sh --exclude=SC2015 scripts/run-analytics.test.sh && shellcheck --shell=sh --exclude=SC2015 scripts/loop-usefulness.test.sh && shellcheck --shell=sh --exclude=SC2015 scripts/spec-delta.test.sh && shellcheck --shell=sh --exclude=SC2015 scripts/live-effort.test.sh && shellcheck --shell=sh --exclude=SC2015 scripts/status-view.test.sh && shellcheck --shell=sh scripts/check-doc-links.sh && shellcheck --shell=sh --exclude=SC2015 scripts/check-doc-links.test.sh && shellcheck --shell=sh scripts/worktree-cleanup.sh && shellcheck --shell=sh --exclude=SC2015 scripts/worktree-cleanup.test.sh && shellcheck --shell=sh scripts/local-ci.sh && shellcheck --shell=sh --exclude=SC2015 scripts/local-ci.test.sh && shellcheck --shell=sh .agents/skills/gate-b-review/scripts/run-tests.sh && shellcheck --shell=sh .agents/skills/gate-b-review/scripts/risk-pass.sh && shellcheck --shell=sh --exclude=SC2015 scripts/gate-b-run-tests.test.sh && shellcheck --shell=sh --exclude=SC2015 scripts/gate-b-risk-pass.test.sh && HOOK_SH=sh sh plugins/dev-workflow/hooks/codex-gate.test.sh && HOOK_SH=dash dash plugins/dev-workflow/hooks/codex-gate.test.sh && sh scripts/check-invariants.test.sh && sh scripts/check-invariants.sh && sh scripts/check-version-bump.test.sh && sh scripts/check-version-bump.sh origin/main && sh scripts/ledger-metrics.test.sh && sh scripts/run-analytics.test.sh && sh scripts/loop-usefulness.test.sh && sh scripts/spec-delta.test.sh && sh scripts/live-effort.test.sh && sh scripts/status-view.test.sh && sh scripts/check-doc-links.test.sh && sh scripts/worktree-cleanup.test.sh && sh scripts/local-ci.test.sh && RUN_TESTS_SH=sh sh scripts/gate-b-run-tests.test.sh && RUN_TESTS_SH=dash dash scripts/gate-b-run-tests.test.sh && RISK_PASS_SH=sh sh scripts/gate-b-risk-pass.test.sh && RISK_PASS_SH=dash dash scripts/gate-b-risk-pass.test.sh && sh scripts/check-doc-links.sh source-files/ docs/history/ docs/superpowers/replays/ && claude plugin validate . --strict` |
| quality-light (the light lane `scripts/local-ci.sh` runs for a docs- or release-only change since 0.50: guards, version record, links, manifest; no suites) | `sh scripts/check-invariants.sh && sh scripts/check-version-bump.sh origin/main && sh scripts/check-doc-links.sh source-files/ docs/history/ docs/superpowers/replays/ && claude plugin validate . --strict` |
| typecheck | n/a — no typed sources (shell, six untyped Python reports, markdown) |
| lint | `shellcheck --shell=sh plugins/dev-workflow/hooks/codex-gate.sh && shellcheck --shell=sh --exclude=SC2015 plugins/dev-workflow/hooks/codex-gate.test.sh && shellcheck --shell=sh scripts/check-invariants.sh && shellcheck --shell=sh --exclude=SC2015 scripts/check-invariants.test.sh && shellcheck --shell=sh scripts/check-version-bump.sh && shellcheck --shell=sh scripts/check-version-bump.test.sh && shellcheck --shell=sh --exclude=SC2015 scripts/ledger-metrics.test.sh && shellcheck --shell=sh --exclude=SC2015 scripts/run-analytics.test.sh && shellcheck --shell=sh --exclude=SC2015 scripts/loop-usefulness.test.sh && shellcheck --shell=sh --exclude=SC2015 scripts/spec-delta.test.sh && shellcheck --shell=sh --exclude=SC2015 scripts/live-effort.test.sh && shellcheck --shell=sh --exclude=SC2015 scripts/status-view.test.sh && shellcheck --shell=sh scripts/check-doc-links.sh && shellcheck --shell=sh --exclude=SC2015 scripts/check-doc-links.test.sh && shellcheck --shell=sh scripts/worktree-cleanup.sh && shellcheck --shell=sh --exclude=SC2015 scripts/worktree-cleanup.test.sh && shellcheck --shell=sh scripts/local-ci.sh && shellcheck --shell=sh --exclude=SC2015 scripts/local-ci.test.sh && shellcheck --shell=sh .agents/skills/gate-b-review/scripts/run-tests.sh && shellcheck --shell=sh .agents/skills/gate-b-review/scripts/risk-pass.sh && shellcheck --shell=sh --exclude=SC2015 scripts/gate-b-run-tests.test.sh && shellcheck --shell=sh --exclude=SC2015 scripts/gate-b-risk-pass.test.sh` |
| test | `HOOK_SH=sh sh plugins/dev-workflow/hooks/codex-gate.test.sh && HOOK_SH=dash dash plugins/dev-workflow/hooks/codex-gate.test.sh` — two runs; `HOOK_SH` selects the shell the HOOK runs under, and without it a dash invocation only exercises the harness |
| invariant checks (5 pinning, 6 manifest, prompt conformance, template size, repo instruction size, gate rules size, gate rules copies identical, doc-link checker copies identical, local CI runner copies identical, kit version record, review skill copies identical) | `sh scripts/check-invariants.test.sh && sh scripts/check-invariants.sh` |
| docs link check (relative Markdown links and their heading fragments resolve) | `sh scripts/check-doc-links.test.sh && sh scripts/check-doc-links.sh source-files/ docs/history/ docs/superpowers/replays/` |
| invariant check (12 version bump) | `sh scripts/check-version-bump.test.sh && sh scripts/check-version-bump.sh origin/main` |
| worktree cleanup report (by hand, not CI; `--remove` deletes, see Boundaries 4a) | `sh scripts/worktree-cleanup.sh <repo>` |
| local CI (by hand, not CI: runs the quality row on one commit in a temporary worktree and posts the result as the `quality` commit status, see Boundaries 4b; the opt-in path beside the Actions job, used with the workflow disabled; needs a logged-in `gh`; about 35 minutes on this Mac in the full lane, seconds in the others, see its header) | `sh scripts/local-ci.sh [--from <green>] [<commit>]` |
| build | n/a — nothing is compiled or bundled |
| prompt eval (by hand before a version bump, not in CI; costs about $2 per run; exits 1 while any case fails; on 0.36.0 all 7 cases passed and it exited 0) | `d=$(mktemp -d) && cp -R plugins/dev-workflow "$d/" && cp -R evals "$d/dev-workflow/evals" && claude plugin eval "$d/dev-workflow" --runs 1 --allow-tools Bash --no-publish --trust-plugin` — `--eval-dir` only accepts a path inside the plugin, so the suite is copied into a temporary plugin copy |

**Prerequisites and pinning.** The quality command needs `shellcheck` (0.11.0 locally;
CI runs the pinned image `koalaman/shellcheck:v0.11.0`), the `claude` CLI (CI pins
`@anthropic-ai/claude-code@2.1.207`), and **`dash`** — the battery runs the hook suite
twice, once with the hook under `sh` and once under `dash`, because the hook has to be
correct under both and Ubuntu's `/bin/sh` IS dash. Bump the first two deliberately, per
invariant 5; `dash` is addressed by name because it is the system shell, not a pinned
tool. Without it the second run cannot start, and dropping that run is what let a
`dash`-only defect ship once already. The metrics report's suite also needs
**`python3`** 3.8 or later, addressed by name for the same reason as `dash`: it is the
system interpreter, not a pinned tool. `scripts/run-analytics.py`, `scripts/loop-usefulness.py`,
`scripts/spec-delta.py`, `scripts/live-effort.py` and `scripts/status-view.py` also need git 2.36 or later and check for it.
The review skill's two scripts and their suites (Boundaries 4c) need **`perl`**, addressed by name like `dash`: run-tests.sh exits 5 without it. `risk-pass.sh` refuses any Codex CLI but `codex-cli 0.162.1` (exit 6); its suite stubs `codex`. `scripts/worktree-cleanup.sh` uses `gh` and `lsof` when present, addressed by name like `git`: they are
system tools, not pinned packages, and invariant 5's scope does not include them. Without them its
squash-merge and session answers read `unknown`, which keeps the row; its suite stubs both. `scripts/local-ci.sh` requires `gh` logged in and
refuses to run with a shellcheck other than the version `ci.yml` pins (a commit without that pin skips
this check); the `claude` CLI it does not
check against the CI pin — it runs the installed one (2.1.312 on 2026-10-28, against the pinned
2.1.207) and records that version in the status description. Its suite stubs `gh`, `shellcheck`,
`claude` and the battery.

**The `--exclude=SC2015` on the test file** is a single-code exclusion, not a blanket
disable: every other shellcheck rule still applies to that file. Its hits are all
`[ cond ] && pass "x" || fail "x"`, where `pass` is a bare `printf` whose only failure
mode is a broken stdout — which runs `fail` as well, producing a spurious FAIL rather
than a false pass. Revisit if `pass`/`fail` ever gain logic that can legitimately fail.

**`check-version-bump.sh origin/main` has a precondition**, unlike everything else in the
battery: it compares *commits*, so run it once the work is committed (the Gate-B WIP
commit is the natural point) and after `git fetch origin`, so the base is current; with plugin
edits still uncommitted it reports clean, uselessly. The base is `origin/main`, not the local
`main`: that one moves only when pulled in the main checkout, and from a merge-base behind the
branch point the diff carries another commit's bump, which hides a missing one. CI passes the
PR's own base ref instead.
It is in the quality row because that row claims to be what CI runs.

CI runs the parts as separate steps for readable failures; the chained form above
is the single command a human runs. One difference is deliberate: CI's version-bump
step is `pull_request`-only, while the local battery always runs it (with HEAD at `origin/main`, where
the merge-base is HEAD, it passes trivially).

**Check 4i caps the gate rules at 10,000 bytes**, measured in two texts: `.claude/review-gates.md`
and the fenced `### 2.1a` template in `workflow-init.md`. Without a cap the rules regrow sentence by
sentence ([history](docs/ARCHITECTURE.md#incidents-behind-the-agentsmd-rules)). It measures size only.
**Check 4j** fails when those two texts are not byte-identical; it compares bytes only, not
whether either copy is right. **Check 4l** does the same for `scripts/check-doc-links.sh` and the
fenced `### 2.21` template in `workflow-init.md`; **check 4m** for `scripts/local-ci.sh` and `### 2.22`.
**Check 4o** does the same for the review skill's `SKILL.md`, `run-tests.sh` and `risk-pass.sh` under
`.agents/skills/gate-b-review/` and the fenced `### 2.24`–`### 2.26` templates.
**Check 4n** fails unless the dev-workflow manifest's `version`, the fenced `### 2.23` template and this
repository's `.claude/dev-workflow-version` are the same x.y.z; it compares strings, not whether the bump
was right.

**Check 4g measures exactly two files.** It fails when this repository's `CLAUDE.md` plus
`AGENTS.md` exceed 150,000 characters, a budget set for this repository after `main` went past
the 150.0k characters Claude Code warned at (`b18e7db`). It is not a statement of any client's
current limit, and everything else a session loads — the user's own instruction files, memory,
plugin, skill and hook text, `.claude/review-gates.md` — is outside the measurement.
