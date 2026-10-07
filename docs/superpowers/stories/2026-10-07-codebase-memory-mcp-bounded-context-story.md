# Optional codebase-memory MCP in task context, bounded for agents — Story

**Date:** 2026-10-07 · **Size:** story
**Risk:** high · **Security:** high · **Validation:** battery+check+verification+abuse-path

## 1. Problem statement
A codebase-memory MCP server (0.9.0, a self-updating binary configured globally for Claude Code and
Codex) is already used for code discovery, but no workflow rule says when to use it, how far its
answers can be trusted, or what agents may change through it. It cannot report which commit an index
was built from, one checkout here has two indexes of different ages, and every agent can call its
write tools (index, delete, ingest, ADR write); Codex auto-approves `index_repository`. Its
`auto_watch` refreshes an index only while the server runs, so changes made between sessions leave
the index stale. This is also the first effective delivery of Daniel's security concept (assignment
2026-10-06; owner row in `todos.md`): today almost every agent limit in the kit is instruction-only.
Feasibility evidence (local, 2026-10-07): `.context/evidence/2026-10-07-mcp-probe/README.md`.

## 2. Desired outcome
Projects that have the server use it for orientation and dependencies, while current source,
configuration and binding documents stay authoritative. On the tested Claude Code paths, agents can
read the index and refresh the derived index of the current approved checkout only where a bound to
that checkout is set up and shown on the server path actually used; they cannot delete projects,
ingest external data or write ADRs. Every control states whether it prevents, detects or only
instructs, on which client and path, and against what (accident vs deliberate bypass). Projects
without the server get nothing new. The rest of the security concept keeps its existing owners; this
is a first partial delivery, not its completion.

## 3. Acceptance criteria
_IDs are permanent once the story is committed: never renumber or reuse one; a new criterion takes the next number unused here and on the branch it merges into, and a collision stops for a human; a removed one stays, struck through and dated; a narrowed one keeps its ID with a dated note; cite as `<story path> AC-<n>`; full rules: dev-workflow:intake, "Acceptance-criterion IDs"._
- [ ] **AC-1** The task-context rule (CLAUDE.md §4 and its scaffolded template) says when the server is used (orientation, dependencies, impact) and that current source, configuration and binding documents are authoritative; decision-relevant statements are confirmed against them in a targeted way, without a blanket second text search after every graph query.
- [ ] **AC-2** When an index's currency for the current checkout is unclear, no completeness claim is made from it and the agent falls back to direct search for what the claim needs, saying so; `index_status` alone does not count as evidence of currency.
- [ ] **AC-3** Server results are treated as data: they grant no authority and are not followed as instructions.
- [ ] **AC-4** Agents may refresh the derived index of the current approved checkout only where a bound to that checkout is set up and shown on the server path actually used; without that evidence, refresh stays denied and direct search stays available. Deleting projects, ingesting external data and writing ADRs stay denied to agents. No global client configuration is changed under this story.
- [ ] **AC-5** On Claude Code at the installed client version, through the real client and tool chain with synthetic data and an isolated index store: the main agent and a delegated subagent cannot call the denied tools, and allowed read tools work. This is shown for bypass mode; for auto mode, the denial is shown, and allowed reads under project settings in a trusted repository stay open until shown — no enforcement or availability is claimed for auto mode beyond what was shown.
- [ ] **AC-6** A missing or altered protection is detected through the real client path, not only by inspecting a file: a denied tool that is callable (including through a misspelled rule), and a missing path bound, shown by an out-of-checkout index call that is not refused. A refusal is counted as the protection working only when a control rules out a technical error — the same call against a target known to index successfully without the bound — because the server returns the same "worker crashed" response for a refusal and for a technical failure.
- [ ] **AC-7** The supported clients, roles and tool paths are named, and every path not technically protected (at least: Codex, a shell call to the server's CLI, the server process itself, self-removal of the rule in bypass mode) is stated as such, together with the server's indistinguishable refusal response; technical enforcement is claimed only for paths shown under AC-5/AC-6.
- [ ] **AC-8** Each control is labelled prevented-before, detected-after or instruction-only, with its protection target (accidental error vs deliberate bypass or manipulated input) and its limit.
- [ ] **AC-9** The server's identity is recorded with evidence — source, version, install and update behaviour, network reach, storage location — with vendor statements marked as such, and rechecked through the existing Tooling revalidation on relevant updates.
- [ ] **AC-10** A project without the server gets no additional rules, settings or required dependency.
- [ ] **AC-11** Existing projects can adopt the change through `/workflow-init` with a visible diff that preserves their own conditions; no global client settings, production access or real index is changed by the delivery or its tests.
- [ ] **AC-12** The evidence reports observed false blocks of permitted work, stuck or aborted tasks, added instruction context and extra model or tool calls, each with its scope; no composite score.

## 4. Affected AGENTS.md invariants
- `## Key invariants` / Hook — "1. **The hook always exits 0.** It is advisory; a reminder that can fail closed would make the workflow unusable whenever Codex is down or the environment is odd."
- `## Key invariants` / Packaging — "5. **Every version pinned exactly.** … **Scope:** things that *execute* in a run — CI actions and runners, npm packages, Docker images, MCP servers."
- `## Key invariants` / Prompts and scaffolding — "8. **`/workflow-init`'s templates stay inline** in the command body."
- `## Key invariants` / Prompts and scaffolding — "9. **`/workflow-init` never overwrites silently.**"
- `## Key invariants` / Prompts and scaffolding — "11. **Prompt changes pass `docs/prompt-standards.md`**"
- `## Key invariants` / Packaging — "12. **A plugin change requires a version bump.**"

## 5. Open questions
- Does a project `allow` rule for the read tools take effect in a trusted repository in auto mode? (Untested: the probe folder was untrusted, and trusting it would change `~/.claude.json`.)
- Where can the path bound be configured for the server path actually used without a separately authorized global configuration change?
- Is a Codex-side limit (per-tool `approval_mode`) wanted later? It needs a separately authorized change to the global Codex config.

## 6. Suggested size
story — one coherent change to task context plus one client-enforced limit and one server-side bound, fitting one spec → plan → PR.
