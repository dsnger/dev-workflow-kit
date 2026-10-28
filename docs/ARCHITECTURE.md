# Architecture of this repo

How the marketplace and plugin are laid out, and the two design decisions that are
non-obvious enough to be worth writing down. The workflow *methodology* is a separate
subject — that lives in [`coding-workflow.md`](coding-workflow.md). The product's purpose and
feature map are in [`PRD.md`](PRD.md); the tools and their pins are in
[`TECH-STACK.md`](TECH-STACK.md).

## Layout

The tree below is the *meaningful* surface — the files a change is likely to touch or
break. Ordinary repo furniture (`.gitignore`, `.claude/settings.json`, generated state
under `.mcp/`) is deliberately absent, not overlooked.

```
README.md                         # what the kit is, the new-feature grid, quickstart, what to type when
MANIFEST.md                       # inventory of source-files/, the frozen extraction seed
AGENTS.md                         # invariants, binding boundaries, conventions, § Commands
CLAUDE.md                         # discipline rules + pointer to the review gates
.claude/review-gates.md           # the two review gates (CLAUDE.md §5, moved out for size)
.claude/codex-gate.mode           # the gate mode, one word (`strict` here; read by the rules and the hook)
todos.md                          # backlog; `pending` ledger rows point here by ref
.gitattributes                    # union merge for the append-only ledger
.mcp.json                         # the Codex reviewer, pinned (no Context7: no library dependencies)
.claude-plugin/marketplace.json
.github/workflows/ci.yml          # lint + hook tests + invariant checks + validate
scripts/check-invariants.sh       # invariants 5, 6 + prompt conformance (rung 2)
scripts/check-invariants.test.sh  # its regression suite — reject/accept pairs
scripts/check-version-bump.sh     # invariant 12, mechanically — PR-only (rung 2)
scripts/check-version-bump.test.sh # its regression suite — policy/operational/accept
scripts/check-doc-links.sh        # relative Markdown links and heading fragments resolve; = workflow-init 2.21 (check 4l)
scripts/check-doc-links.test.sh   # its regression suite — fixture git repos
scripts/ledger-metrics.py         # read-only report over the ledger + git (vision step 2b)
scripts/ledger-metrics.test.sh    # its regression suite — fixture repos, expected text
scripts/run-analytics.py          # gate-call effort from local logs (vision step 2c, part 1)
scripts/run-analytics.test.sh     # its regression suite — fixture home + repos, expected text
scripts/loop-usefulness.py        # warning light over recorded review cycles (vision step 2c, part 2)
scripts/loop-usefulness.test.sh   # its regression suite — fixture repo + store, expected text
scripts/spec-delta.py             # spec/plan change since a given baseline, for Gate B (vision step 2c, part 3)
scripts/spec-delta.test.sh        # its regression suite — fixture repo, expected text
scripts/live-effort.py            # effort of review cycles not yet closed (vision step 2c, part 4a)
scripts/live-effort.test.sh       # its regression suite — fixture home + repos, expected text
scripts/status-view.py            # generated HTML status view, one-shot or watch (process monitoring)
scripts/status-view.test.sh       # its regression suite — fixture home + repos, mutants
scripts/worktree-cleanup.sh       # worktree and branch report; --remove deletes merged, clean, idle ones
scripts/worktree-cleanup.test.sh  # its regression suite — fixture repos, stub gh and lsof
scripts/local-ci.sh               # runs the quality row on one commit in a temporary worktree, posts the quality status
scripts/local-ci.test.sh          # its regression suite — fixture repos, stub gh, shellcheck, claude, git
evals/<case>/{prompt.md,graders/*.md} # `claude plugin eval` suite, run by hand before a version bump; outside the plugin so it does not ship
plugins/dev-workflow/
  .claude-plugin/plugin.json      # metadata only — no component keys (invariant 6)
  CHANGELOG.md                    # every manifest version, newest first
  skills/{intake,harden-finding,sparring,ticket}/SKILL.md
  agents/finding-triage.md        # read-only PR-comment checker (convention-loaded)
  commands/{workflow-init,process-pr-review,claude-init}.md
  hooks/{hooks.json,codex-gate.sh,codex-gate.test.sh}
  hooks/fixtures/                 # captured PostToolUse payloads the suite replays
  examples/                       # ships, but never scaffolded — one stack's answers
docs/
  ARCHITECTURE.md                 # this file — layout, components, the two design decisions, rule history
  PRD.md                          # problem, success measures, non-goals, feature map
  TECH-STACK.md                   # tools the repo runs on, and where each version is pinned
  coding-workflow.md              # the methodology this plugin encodes
  setup.md                        # numbered Do / You see / If not steps, from zero
  getting-started.md              # what to type, situation by situation
  reference.md                    # every component, option, limit and knob; contributing
  images/process-*.svg            # process grids: setup, new project, new feature, ticket
  prompt-standards.md             # the 12-item checklist every prompt must pass
  hardening-log.md                # append-only findings ledger (union-merged)
  hardening-taxonomy.md           # this project's fingerprint classes
  pr-review-bots.md               # the Wait-for routing list + where each bot's findings appear
  history/                       # non-binding pre-shrink archives, strike-list and verification
  field-reports/                  # dated reports from consumer projects and pilots (evidence, not rules)
  superpowers/{specs,plans,stories}/ # the approved artifacts behind past changes
  superpowers/replays/            # committed replay packages behind a named verification
source-files/                     # the extraction seed this repo was built from
```

## Components

The executable artifacts are the hook and its test, plus the three repo-local CI checkers and
their suites (`scripts/check-invariants.{sh,test.sh}`, `scripts/check-version-bump.{sh,test.sh}`
and `scripts/check-doc-links.{sh,test.sh}`),
plus six Python reports with their suites: `scripts/ledger-metrics.{py,test.sh}`,
`scripts/loop-usefulness.{py,test.sh}`, `scripts/spec-delta.{py,test.sh}`,
`scripts/live-effort.{py,test.sh}`, `scripts/run-analytics.{py,test.sh}` and
`scripts/status-view.{py,test.sh}`, plus one shell report with its suite,
`scripts/worktree-cleanup.{sh,test.sh}`, and one shell runner with its suite, `scripts/local-ci.{sh,test.sh}`
(the local path of the battery, posted to GitHub as the `quality` status). JSON and YAML files are configuration read by their tools
(Claude Code, the MCP client, CI). Everything else is text read by a model. What each report may
write, and which of these ship in the plugin, is binding and stated once, in
[`AGENTS.md` § Boundaries (binding)](../AGENTS.md#boundaries-binding).

The plugin manifest (`plugins/dev-workflow/.claude-plugin/plugin.json`) declares no components at
all; what is loaded by convention instead is binding item 1 in
[`AGENTS.md` § Boundaries (binding)](../AGENTS.md#boundaries-binding). Why a manifest key for
those components is not merely redundant: a `hooks` key alongside
the convention-loaded file was a duplicate-hooks error that stopped the whole plugin from loading
(hit and fixed in 0.2.1). The rule that follows from it is
[`AGENTS.md` invariant 6](../AGENTS.md#key-invariants).

## Boundaries and dependency direction

The plugin is the only thing that ships; the scripts above are this repository's own tooling
(the docs link checker reaches projects only as the text of `/workflow-init`'s 2.21 template),
and `examples/` ships as reference material without being loaded or scaffolded
([invariant 7](../AGENTS.md#key-invariants)). Outward, the plugin hands off to superpowers skills
and calls a Codex MCP server, and `/workflow-init` adds a pinned Context7 server to an initialized
project for its library-API rule; inward, nothing relies on where an installed copy lives. The
binding form of each of these statements is in
[`AGENTS.md` § Boundaries (binding)](../AGENTS.md#boundaries-binding).

## Why `/workflow-init`'s templates are inline

Every file `/workflow-init` scaffolds is written out inside the command's own markdown,
not read from a `templates/` directory.

This looks redundant, and isn't. Claude Code does not expand `${CLAUDE_PLUGIN_ROOT}`
inside command markdown bodies — verified, not assumed — and the variable is also
absent from the command's Bash environment. An installed plugin lives under a
version-keyed cache path (`~/.claude/plugins/cache/{marketplace}/{plugin}/{version}/`),
which is an implementation detail, not an API. So a command that read its templates
from disk would have to glob for its own installation directory, and would break the
first time that layout changed.

Inline means there is nothing to resolve and nothing to go stale. The cost is a long
command file; the benefit is that it cannot fail.

## Why Gate B verifies content, not events

The hook could invalidate a Gate-B review whenever an `Edit`/`Write` tool event fires.
It doesn't, because that is blind to a file changed through Bash — `sed -i`,
`eslint --fix`, `git apply`, a codegen step — which emits no such event and would leave
a stale "reviewed" marker standing.

Instead the hook stores a fingerprint of the index and the working tree at review time
and recomputes it at commit: `git diff HEAD` for tracked content, a tree id for the
effective index, and a tree id written from a throwaway index brought up to the
worktree so untracked files count by path, content and mode. (Asking git for the tree
rather than walking the files in shell is deliberate — a hand-rolled walk has to
re-derive symlink targets, git's path quoting and non-regular files, and got all three
wrong before this was reduced to `git write-tree`.) Any change to *included* content,
made by any tool and present when the hook runs, invalidates — `.context/` and
untracked ignored paths are excluded by design (a *tracked* file still counts even if it
matches `.gitignore`). An unstaged edit-then-undo still matches, because it restores
the fingerprint — which says the content is unchanged since the review, not that Codex
read it: the hook compares a fingerprint of disk while the reviewer reads a git range
(the hook's own hard-floor comment says the same). A false ✓ is the
dangerous direction,
so the check is tied to the effective index plus the included worktree content as of
the hook's invocation — a superset of any one commit's payload, chosen so the gate errs
toward firing — rather than to what the harness happened to notice. (A mutation after
that invocation, such as the compound `printf x > f && git commit -am y`, is still
unseen — a separate, parked defect, not this one.)

Two consequences worth knowing:

- The hook's own state lives in `.context/`, which is untracked and therefore part of
  `git status --porcelain`. It is excluded from the hash — otherwise the hash would
  change every time the hook wrote to it, and could never match itself.
- CLAUDE.md §5 tells you to make a throwaway commit so `mcp__codex__review` has a
  non-empty range to read. That commit is treated as cycle-internal — otherwise the
  documented workaround would destroy the cycle it exists to serve — when it is a one-line
  `git commit` with one WIP `-m` and only a few value-less flags beside it (CHANGELOG
  0.13.3): the pass counters survive if the commit that results starts with `WIP` and is
  attributable to that command by the rule the 0.13.3 CHANGELOG entry states, and a
  repository whose hooks or settings could rewrite the message gets the ordinary reminder
  beforehand. A plain `git commit --amend --no-edit` on a WIP commit also counts, under
  narrower conditions (CHANGELOG 0.13.2). The hook reads the command and the resulting
  commit, not the message alone; any other commit it detects resets. A commit spelled so
  that the hook does not detect it as a commit at all is outside both rules.

## Incidents behind the AGENTS.md rules

The stories that motivated some rules in [`AGENTS.md`](../AGENTS.md); the rules themselves,
with their one-clause reasons, stay there. Moved out of `AGENTS.md` to keep it small.

- **No attribution trailers.** `Co-Authored-By: Claude` / `Generated with` trailers were
  stripped from 15 commits once already.
- **`examples/` is in the version-bump scope** (invariants 7 and 12). Reading
  "shipped-but-not-scaffolded" as "not shipped" once made `examples/` look out of scope for
  the version-bump rule.
- **Reading the manifest before describing it.** Three sites said the manifest declares
  `hooks` when it declared nothing at all: the former `docs/architecture.md` (now
  `docs/ARCHITECTURE.md`) and `MANIFEST.md` shipped that claim, and `AGENTS.md`'s own layout
  tree (since moved here) was written with it before being corrected in the same PR. It is the
  same wrong belief that produced the 0.2.1 duplicate-hooks load failure.
- **Searching for the claim, not the phrase.** Fixing the index-tree story took four Gate-B
  rounds because each correction introduced a subtler version of the same claim: "the
  tree-hash proves what was reviewed", then "what is being committed is what was reviewed",
  then "what a commit would actually carry", then "everything a commit could carry". Every
  round searched for the previous phrase, so a synonym survived.
- **Accounting for a replaced procedure's conditions.** In the profiles cycle a rewrite lost
  an earlier condition ten times across `process-pr-review`, §5, the spec and a story
  criterion — once making an eligible profile *sufficient* for a Gate-B skip, which is the
  gate-off path that change existed to close.
- **Grepping before renaming a doc section.** `ci.yml` once pointed at a deleted README
  section; `MANIFEST.md` listed a `CLAUDE.md` that did not exist.
- **Bounding data spliced into shell source.** `claude-init`'s project name was not bounded,
  and one containing a line break could run the rest of the template as commands (PR #27).
- **The gate-rules size cap (check 4i).** The rules grew to 139 kB once and were cut to
  6.4 kB in #62.
