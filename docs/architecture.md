# Architecture of this repo

How the marketplace and plugin are laid out, and the two design decisions that are
non-obvious enough to be worth writing down. The workflow *methodology* is a separate
subject — that lives in [`coding-workflow.md`](coding-workflow.md).

## Layout

A selective view — the loaded surface plus the workflow's own project files. Repo
furniture (`.gitignore`, `.claude/`, generated state) is omitted on purpose.

```
README.md, MANIFEST.md, AGENTS.md, CLAUDE.md, todos.md
.gitattributes                    # union merge for the append-only ledger
.mcp.json                         # the Codex reviewer, pinned
.claude-plugin/marketplace.json
.github/workflows/ci.yml          # lint + hook tests + invariant checks + validate
scripts/check-invariants.sh       # invariants 5 and 6, mechanically (+ .test.sh)
scripts/check-version-bump.sh     # invariant 12, PR-only, mechanically (+ .test.sh)
plugins/dev-workflow/
  .claude-plugin/plugin.json
  CHANGELOG.md                    # every manifest version, newest first
  skills/{intake,harden-finding}/SKILL.md
  agents/finding-triage.md
  commands/{workflow-init,process-pr-review}.md
  hooks/{hooks.json,codex-gate.sh,codex-gate.test.sh}
  examples/                       # ships, but never scaffolded — one stack's answers
docs/{getting-started,coding-workflow,prompt-standards,architecture}.md
docs/{hardening-log,hardening-taxonomy,pr-review-bots}.md
docs/superpowers/{specs,plans,stories}/  # approved artifacts behind past changes
source-files/                     # the extraction seed this repo was built from
```

The plugin manifest declares no components at all: `skills/`, `commands/`, `agents/` and
`hooks/hooks.json` are each discovered by convention from their paths, so naming any of
them again would be two sources of truth for the same fact. For hooks it is worse than
redundant — a `hooks` manifest key alongside the convention-loaded file is a
duplicate-hooks error that stops the whole plugin from loading (hit and fixed in
0.2.1). Manifest keys are only for files outside the convention paths.

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
(the hook's own hard-floor comment, above `floor=3`, says the same). A false ✓ is the
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
  non-empty range to read. A commit whose message starts with `WIP` is treated as
  cycle-internal: no STOP, and the pass counters survive. Otherwise the documented
  workaround would destroy the cycle it exists to serve.
