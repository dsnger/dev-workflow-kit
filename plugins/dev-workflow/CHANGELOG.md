# Changelog — dev-workflow

Every version the plugin manifest has carried, newest first. Entries are written from
`git log` over `plugins/`, not from memory.

An entry covers the plugin-touching commits after the previous version's introducing
commit, up to and including the commit that introduced this one. There are no dates:
the manifest records versions, not release dates, and inventing them would be fiction.

**Bumping is checked**, as of 0.4.1: `scripts/check-version-bump.sh` fails a pull
request that changes a path inside an existing `plugins/<name>/` directory without
changing that plugin's manifest version. Before that it was a convention, and it was
missed twice.

It is a check, not a guarantee, and the difference is written down rather than glossed:
it verifies a bump is *present*, not that it is correct, and it says nothing about an
entire plugin directory being deleted, a file sitting directly under `plugins/`, a
plugin directory being renamed or repointed, or a commit pushed straight to main. A
newly added plugin needs no bump — there is no earlier version to differ from — but it
is not unchecked: a missing manifest, or one whose `version` cannot be read
unambiguously, still fails. Deleting only a plugin's *manifest* while the directory
keeps shipping fails too.
AGENTS.md invariant 12 carries the complete list.

## 0.7.0

- **`intake` proposes a risk and security-relevance profile per story** and derives a
  **validation mode** from the two (`max(risk, security)` → `battery` / `battery+check` /
  `battery+check+verification`, plus `+abuse-path` at security `high`). All three are
  human-confirmed inside intake's existing single question round — there is no
  "unconfirmed" state — and the story header is their single writable copy. A
  `**Profile log:**` records later changes without restating values.
- **§5 gains a Profiles subsection**: lens sets appended by level — risk `high` → threats,
  abuse, rollback, data loss, idempotency, compatibility, observability; security
  `standard` or `high` → assets, trust boundaries, roles, external systems, abuse paths
  (risk `standard` and `trivial` append nothing) — three defined answers for
  reading a profile, and the author's evidence obligations per mode. Lenses are different
  questions, not more passes: the 3-pass floor, the Blocker/Major filter and the
  file-first findings protocol are unchanged.
- **The Gate-B triviality skip narrows** for a profiled story to effective level 0, and
  removes the review but never the evidence. No new way to skip a gate is added.
- **§5 Mechanics: the cycle-closing amend carries one validated evidence entry per cited
  profiled story** (and none for an unprofiled one), so the final
  commit body is its durable record — an entry written only into the `WIP:` body is
  destroyed by the amend that closes the cycle.
- **Unprofiled stories are unaffected**, including today's judgement-based skip: a story
  with no profile line behaves exactly as it did before this release.
- **`process-pr-review` decides the skip from the story profile**, not from the fix's
  size alone, with explicit no-story, one-story and several-stories branches.
- **The hook's below-floor reminder stops restating the skip rule** and defers to the
  policy file instead — one string, no new hook behaviour. The hook still only counts
  passes and reads no profile; the edit removes a rule statement that the narrowed skip
  made false, rather than teaching the hook anything about profiles.

## 0.6.0

- **Optional companion files beside a gate findings file.** The §5 protocol knew only
  about the findings file, so dispositions and interrupted-cycle state lived in chat
  history and died with the session. The scaffolded template now describes two advisory
  companions: `<slot>-dispositions.md` (one line per finding: verdict + reason) and a
  cycle-stable resume note — `gate-a-spec-resume.md`, `gate-a-plan-resume.md`,
  `gate-b-resume.md`. Cycle-stable rather than pass-named, because a note keyed to the
  interrupted pass is exactly the file a resuming agent will not look for once the counter
  moves. Both are optional and non-validating: the findings file plus its terminator remain
  the only hard requirement, and nothing enforces the companions. Field practice from
  infinite-portfolio-canvas, which had invented 7 dispositions files and a Gate-A resume
  note per-session before the protocol knew about them.
- **The scaffolded prompt-standards template now covers ad-hoc task briefs.** A brief
  handed to the coding agent for one task is a prompt with the same failure modes, held to
  the checklist in spirit — success criteria, stop conditions, verified claims — while
  nobody reviews a brief against all 12 items, which is why those habits must live in how
  briefs are written. Deferred since 0.5.0 and deliberately **not** a verbatim copy of this
  repo's paragraph: that one links a file `/workflow-init` never scaffolds and asserts this
  repo's own incident count, so the template carries a downstream-neutral variant.

## 0.5.1

- **Gate findings go to a file, not the MCP response.** Long finding lists came back cut
  off on effectively every substantial Gate A pass in the field, and a cut landing
  between findings looks exactly like a short list — so dropped findings read as a clean
  review. Both gate prompts in the `/workflow-init` CLAUDE.md template now have Codex
  write the full list to `.context/codex-reviews/<slot>.md`, end it with
  `END OF FINDINGS (<n> total)`, and reply with one line. The reader accepts a pass only
  when the terminator is present, the count matches, the file holds nothing but finding
  lines, and — for a Gate-B `full` review — both branch files pass.
- **Gate B writes one file per reviewer branch.** `reviewType: full` runs the spec and
  quality reviewers in parallel from a single `additionalContext`. Aimed at one path they
  race, and the second writer leaves a correctly terminated, correctly counted file
  holding half the findings, with every check still passing.
- **Bounded recovery.** An incomplete pass gets one attempt, shared with the existing
  timeout retry rather than added beside it, then STOP — two budgets let a pass alternate
  between them indefinitely. Delete exactly what the re-run rewrites; a resumed Gate-B
  branch must carry its `reviewType` alongside its session id, since the tool defaults to
  `full` and would otherwise run the other reviewer into the wrong slot.
- **What this does not do**, stated in the template rather than implied: nothing checks
  the terminator mechanically — the protocol is instruction-backed by design, and a
  recurrence is the trigger to build the checker. The hook counts on `PostToolUse`, so a
  call that returns and then fails validation still increments the counter you are
  discounting — and so does a *failed* review, because the pinned `mcp-codex-dev` returns
  its own errors and timeouts as ordinary results rather than throwing, which makes the
  tool call itself succeed. Discount every incomplete pass whatever the counter says.
- No hook, script, CI checker or other executable machinery changed. The behaviour of
  both gates *does* change — in this repo the prompts are the product — and that change
  is instruction-backed, living in prompts and templates only.

## 0.5.0

- **Gate-B fingerprint covers the index.** `git commit` commits the index, but both hash
  components described the worktree, so staging a change and then reverting the file on
  disk reported Gate B satisfied on content nobody reviewed. The fingerprint now includes
  a tree id from the effective index (`GIT_INDEX_FILE` when set, else the git-dir index).
- **Staging now invalidates a review.** `git add` of already-reviewed content changes the
  index tree, so the fingerprint changes. The committed bytes are unchanged, making this
  a false invalidation — accepted under the "loose in the firing direction" invariant, and
  the reminder explains that staging alone can cause it. One clean pass clears it.
- **Upgrading invalidates any in-flight review once.** The fingerprint's composition
  changed, so a fingerprint recorded by 0.4.x cannot match one computed by 0.5.0. The
  first Gate-B-applicable commit attempt after upgrading reports "cannot confirm" (a
  `WIP:` commit or a docs-only commit bypasses the comparison); a single review pass
  clears it. This is expected, not a bug.
- **An uncomputable fingerprint now fails closed.** The failure value is a constant that
  never matches — including against itself — replacing a `date`+PID nonce that could
  collide under PID reuse and report satisfied.
- **Reminder text no longer asserts causes it cannot know.** The stale reminder names the
  state ("cannot confirm") rather than claiming the tree changed, and describes the causes
  that can produce it; the satisfied reminder claims fingerprint equality rather than that
  Codex read the bytes. The message-contract tests in `codex-gate.test.sh` section 29 are
  what keep this true: they compare each branch's complete `additionalContext` and
  `systemMessage` against a golden fixture, so any reworded or reversed clause fails the
  suite rather than only the clauses someone thought to enumerate.

## 0.4.1

- **A plugin change now requires a version bump**, checked in CI on every pull request
  (`scripts/check-version-bump.sh` + its suite). This entry exists because the rule was
  broken before it was written: 0.4.0 shipped, and then two commits changed the plugin
  without a bump — see the two items below, released here for the first time.
- `commands/process-pr-review.md`, `commands/workflow-init.md`: the enforcement-claim
  checklist item, and the docs-drift escalation to rung P (`fe5e296`, merged as #5).
- `commands/process-pr-review.md`, `commands/workflow-init.md`: four PRs of observed
  Greptile behaviour recorded, plus an opportunistic bot category (`793e234`).

## 0.4.0

- `agents/finding-triage.md`: new read-only PR-comment checker, convention-loaded, that
  validates one reviewer claim against the code (`b952d95`, #4).
- `commands/process-pr-review.md`: delegates each claim to that agent after its
  instruction-path precheck.
- `skills/harden-finding/SKILL.md`: taxonomy and ladder refinements.
- `commands/workflow-init.md`: scaffolds the mechanized invariant checks; the Codex MCP
  preflight now names the cause it can actually diagnose (`bb672eb`, #2).
- `commands/workflow-init.md`: the scaffolded CI template pins `actions/checkout` and
  `actions/setup-node` to v7.0.0 SHAs (clearing the Node 20 deprecation), sets
  `persist-credentials: false`, and ships verified SHAs in its commented pnpm/node
  example instead of `<sha>` placeholders (`46366a0`, #3).

## 0.3.0

- `hooks/codex-gate.sh` and its suite, `commands/workflow-init.md`: the changes from
  self-initializing this repo with the workflow it ships (`e15d480`, #1) — the plugin's
  own gate applied to the plugin's own repo, which is where several of these findings
  came from.

## 0.2.1

- `.claude-plugin/plugin.json`: dropped the `hooks` key. `hooks/hooks.json` is loaded by
  convention, so declaring it too was a duplicate-hooks error and **the plugin did not
  load at all**. Now invariant 6 (`17b87fd`).

## 0.2.0

- `hooks/codex-gate.sh`: Gate-B validity is derived from working-tree **content**, not
  from events, so a file changed through Bash no longer leaves a stale ✓ standing.
- `hooks/codex-gate.sh`: counts Codex passes from any MCP server, or says why it cannot;
  stays out of projects that never adopted the workflow.
- `commands/workflow-init.md`: checks every prerequisite and reports what is missing;
  tri-state Codex preflight with an honest degraded mode.
- `.claude-plugin/plugin.json`: dropped the redundant `skills` and `commands` keys —
  both load by convention.
- `skills/intake/SKILL.md`: wording fixes.

## 0.1.0

Initial plugin (`a05976a`): the `intake` and `harden-finding` skills, the
`workflow-init` and `process-pr-review` commands, the `codex-gate` hook with its test
suite, and `examples/` as read-only reference material.
