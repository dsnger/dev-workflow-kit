# `/dev-workflow:claude-init` — general working rules without the review workflow — Story

**Date:** 2026-09-17 · **Size:** story
**Risk:** standard · **Security:** standard · **Validation:** battery+check

**Profile log:**
- 2026-09-17 · adoption · proposed at intake as `standard` / `none` / `battery+check`; **confirmed by
  Daniel on 2026-09-17, exactly as proposed.** Gates read this header, which is the only writable
  copy. Derived floor **3** — max(risk `standard` = 1, security `none` = 0) = 1, and only 0 gives a
  floor of 1.
- 2026-09-25 · axis change · security `none` → `standard`, after PR #27's review found that the
  project name could break out of the create command's shell here-document (Greptile, thread
  4091660211). Complete header: `standard` / `standard` / `battery+check`; no prior override to void.
  Proposed by the coding agent and the sparring reviewer; **confirmed by Daniel on 2026-09-25 by
  releasing the repair brief that names this header.** Floor stays **3** — max(1, 1) = 1; the security
  lens set now applies.

## 1. Problem statement

**The kit ships exactly one way to get its discipline rules into a project, and it is the whole
workflow.** `/dev-workflow:workflow-init` scaffolds `CLAUDE.md`, `docs/hardening-log.md`,
`docs/hardening-taxonomy.md`, `docs/prompt-standards.md`, `docs/pr-review-bots.md`, `.gitattributes`,
`.mcp.json` and CI, then interviews the user through `AGENTS.md`. Its preflight requires the
superpowers plugin, a Codex MCP server exposing `exec` and `review`, and a project whose quality
battery can be named and verified.

**A project that wants only the working rules has no route.** The §1–§4 rules — think before coding,
simplicity, surgical changes, goal-driven execution — are useful on their own and carry none of that
machinery. Today the only ways to get them are to run the full initializer, which installs gates the
project has not agreed to, or to copy the text by hand, which is how a copy drifts.

**Taking §5 out is not a subtraction.** `workflow-init`'s §4 ends with the sentence *"The work loop
includes the review gates: **spec ready → Gate A (spec) → plan ready → Gate A (plan) → execute →
tests green → Gate B → commit** (see §5)."* Dropping §5 while keeping that sentence leaves a
`CLAUDE.md` pointing at a section that does not exist — the dangling-reference defect this repo has
shipped twice (`ci.yml` pointing at a deleted README section; `MANIFEST.md` listing a `CLAUDE.md`
that did not exist). The same holds for the closing pointer to `@AGENTS.md`, which `claude-init` does
not write, and for §6, which in this repo's own `CLAUDE.md` is a personal context canary and belongs
in no template at all.

**A second problem travels with it.** The §1 rules say "don't assume" but never say what to do with a
fact that is missing rather than ambiguous. A model that cannot find a fact fills it in, and nothing
in the current text names that as the failure it is. The revised **Don't guess** rule closes that,
and it is wanted in all three copies — the new template, `workflow-init`'s template, and this repo's
own `CLAUDE.md` — because a rule that reads differently in three places is three rules.

## 2. Desired outcome

**One new command, `/dev-workflow:claude-init`, whose only write to a target project is `CLAUDE.md`.**
It carries an inline template of the general rules — §1–§4 with the gate-chain sentence removed, no
§5, no §6, no pointer to files it does not create — plus the revised **Don't guess** rule under §1.

**It initializes a file, so it demands nothing an initializer does not need — with one named
exception.** No superpowers, no Codex MCP server, no `gh`, no package manager, and no git
repository. It does not invoke `workflow-init`, does not `git init`, does not install anything, does
not write a workflow marker, and does not commit. **The exception is creating the file**, which
needs an already-present Python 3 runtime, because that is the only route checked that refuses every
existing destination. See §5 item 4.

**It never destroys what it finds.** Missing → write, through an operation that refuses any
existing destination; where no such operation is available, stop without writing and say so.
Equivalent rules already present → report
unchanged and add nothing. Different or partly overlapping → show a focused proposed diff and ask,
then hand the result back — **the command does not write over an existing file** (§5 item 5).
Unrelated project content and existing mandatory rules are preserved either way. **Where the full
workflow is already installed, the command says so and leaves every gate exactly as it is** — it is
the lighter entry point, never a downgrade path.

**The `Don't guess` rule reads identically in all three copies.**

## 3. Acceptance criteria

1. **`plugins/dev-workflow/commands/claude-init.md` exists**, carries its template inline per
   invariant 8, and is loaded by convention — **no `commands` key is added to the plugin manifest**
   (invariant 6).
2. **A new target project receives `CLAUDE.md` and nothing else**, where the exclusive-create
   operation of §5 item 4 is available. No ledger, no taxonomy, no `.mcp.json`, no CI, no
   `.context/` marker, no `AGENTS.md`. Where it is not available, the command writes nothing and
   reports the limitation — that is the criterion met, not waived.
3. **A repeated invocation adds no duplicate rule.** Second run on its own output reports unchanged
   and writes nothing.
4. **The minimal template contains no gate obligation and no dangling reference.** No §5, no §6, no
   gate-chain sentence, and no pointer to a file the command does not write.
5. **The `Don't guess` rule is byte-identical** in the new template, in `workflow-init`'s template,
   and in this repo's own `CLAUDE.md`.
6. **The command inventory and layout documentation name the new command** — `README.md`'s component
   table, `AGENTS.md`'s layout tree, `docs/architecture.md`'s tree — checked by the reference-grep
   `AGENTS.md` requires before editing layout documentation.
7. **The plugin version is bumped and `CHANGELOG.md` carries the entry** (invariant 12).
8. **The quality battery is green** and `docs/prompt-standards.md`'s twelve items are answered for
   the new command file.

## 4. Settled inputs — decided, paid for, and not to be reopened

- **D1. Inline template, no template engine and no cache-path discovery.** Invariant 8, and the
  assignment restates it. The cost is named rather than hidden: §1–§4 now exist in **three** copies
  and nothing mechanical compares them. That is accepted here, not solved.
- **D2. `claude-init` never touches the full workflow.** Where §5 and its gates are present, they
  stay. There is no remove, disable, or downgrade path, and none is to be proposed.
- **D3. No new synchronization mechanism.** A parity checker for the three copies is out of scope for
  this story. If drift becomes a real defect it earns its own ledger row and its own rung.
- **D4. The command writes exactly one file.** Not "one file plus a marker", not "one file plus a
  README note". One.
- **D5. `CLAUDE.md` in a target project is a general working-rules file, not a gate file.** The
  scaffolded §4 keeps its goal-driven-execution rules, including the ground-your-progress-claims
  sentence, and loses only the clause that routes into §5.

## 5. Settled by Daniel — no longer open

Items 1–3 were settled on 2026-09-17, items 4 and 5 on 2026-09-21.

1. **The profile is confirmed** as `standard` / `none` / `battery+check`, exactly as proposed, and is
   recorded in the profile log above (security raised to `standard` on 2026-09-25 — see that log). The reasoning it was accepted on: the command writes over a
   file a project may have authored by hand, so the failure mode is **content loss** rather than
   inconvenience, and `trivial` would read that write path as harmless — the lenient direction on the
   one axis that matters here.

   **Floor 3, read as §5 actually states it.** Three *valid* passes and a **clean final pass** — not
   three clean passes. The zero-finding early exit below the floor stands, as does every other duty:
   the Blocker/Major resolve rule, the clean-final-pass rule, the mandatory tells, and the stop
   conditions. Nothing here waives any of them.

2. **Version 0.12.0, and `claude-init` is planned as the first of the two changes to merge.** That is
   **release sequencing, not permission to merge.** `0.13.0` was explicitly rejected as a way to
   reserve `0.12.0` for an unfinished branch.

   **Verified at the time of recording:** `origin/main` and local `main` are both
   `7c0d475b9a4a1897e8b03dfa20ec058b9ce09ba6`, the manifest there is `0.11.0`, `CHANGELOG.md`'s newest
   entry is `0.11.0`, and there are **no open pull requests**. So `0.12.0` is free.

   **The integration base is rechecked before the version is finalized**, not taken from this note —
   `main` can move, and a version chosen against a stale base is the defect
   `scripts/check-version-bump.sh` is blind to ("two PRs branched from the same version each bumping
   to the same new one").

   **The `loop-rule-consolidation` branch is not edited by this change.** Its plan text pins `0.12.0`
   for itself; reconciling that is its own cycle's work, on its own branch, and is deliberately not
   started here.

3. **The `Don't guess` rule's extraction clause is made format-conditional** — Daniel's choice of
   2026-09-17, answering Gate-A spec pass 1's Major 3. The earlier wording made the
   EXTRACTED/INFERRED label **unconditional** while its sibling clauses were conditional, so a schema
   admitting an integer and no extra keys could satisfy neither. The sentence now reads, in both
   normative spec blocks and eventually in all three product copies:

   > For extraction tasks, label populated fields EXTRACTED or INFERRED and explain each inference
   > where the required output format permits. If neither annotations nor accompanying explanations
   > are permitted, preserve the required format. This does not permit inventing unsupported values.

   **The last sentence is the point of the change**: relaxing the labelling duty must not read as
   permission to fill a field in. **The three product copies are not written in this round** — the
   spec cycle is not closed, and implementation is not authorized.

4. **The create branch may require an already-present Python 3 runtime** — Daniel's choice of
   2026-09-21, answering the contradiction Gate-A spec pass 2's Majors 1 and 2 left behind. The
   create branch must refuse an existing destination of every kind. Two routes failed that test: the
   ordinary file-writing tool refuses nothing, and POSIX requires noclobber to refuse only a regular
   file or a symlink resolving to one. `os.open` with `O_WRONLY | O_CREAT | O_EXCL` meets it by
   specification, including a dangling symlink, which POSIX requires to fail *"regardless of the
   contents of the symbolic link"*.

   **The rejected alternative** was weakening the preservation guarantee so a lesser operation would
   do. It was rejected because a qualifying standard operation exists; accepting a runtime
   precondition is the smaller product decision than accepting content loss.

   **What is accepted with it**, stated so it is not discovered later: a project without that
   runtime gets **no** created file, and the command says so instead of writing one a weaker way.
   Nothing is installed and no fallback is offered. **This is not a D3 breach** — D3 is about a new
   *synchronization* mechanism, and this is neither a lock, a marker nor a subsystem; it is a
   precondition, which is why it was Daniel's to accept and not an agent's.

   **The guarantee stays narrow.** Exclusive creation of the directory entry is not an atomic write
   of the template's bytes and is no protection against a later edit. A write that fails part-way
   leaves a partial file and is reported as a failure, never as `written`.

5. **The command never writes over an existing `CLAUDE.md`. It proposes and stops** — Daniel's
   choice of 2026-09-21, answering Gate-A spec pass 3's Major. Where the rules differ or overlap,
   the command shows the focused diff, asks, and hands back the proposed result; the user applies
   it. Only the create branch writes.

   **Why.** The spec had claimed the merge write rejected a changed preimage. That claim was found
   unsupported: the operation publishes by replacing the file, and an atomic file replacement is not
   an atomic check-and-replace of content read earlier. The remaining option was an **operating
   assumption** that nobody else writes during the run — and an assumption cannot carry **D2**,
   which is absolute. Removing the write removes the conflict; qualifying it would not have.

   **Nothing in §2 above or in `AGENTS.md` invariant 9 required that write.** Both ask only for a
   focused diff and a question. *"Before merging"* was the spec's own addition, and it is what was
   dropped.

   **Two limits come with it, so that "we do not write" is not read as "anything goes".** The
   proposal itself must preserve unrelated content and existing mandatory rules and must never
   remove, disable, weaken or renumber a gate — D2 binds its content, not only the act of writing.
   And approval opens no write path: *proposal produced and approved* is never reported as a merge
   that was applied, and is never followed by a write through some other operation.

   **The cost, accepted:** on a project that already has a `CLAUDE.md`, the user does the merge by
   hand.

## 6. Suggested size

**Small.** One new command file, one rule added in three places, three inventory lines, one version
bump, one changelog entry. No executable code, no hook change, no change to any gate.
