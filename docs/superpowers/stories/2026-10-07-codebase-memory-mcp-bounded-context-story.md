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
- [ ] **AC-6** ~~A missing or altered protection is detected through the real client path, not only by inspecting a file: a denied tool that is callable (including through a misspelled rule), and a missing path bound, shown by an out-of-checkout index call that is not refused. A refusal is counted as the protection working only when a control rules out a technical error — the same call against a target known to index successfully without the bound — because the server returns the same "worker crashed" response for a refusal and for a technical failure.~~ — withdrawn 2026-10-07: indexing is denied to agents in this delivery, so there is no path bound to check; replaced by AC-13 (change record below).
- [ ] **AC-7** The supported clients, roles and tool paths are named, and every path not technically protected (at least: Codex, a shell call to the server's CLI, the server process itself, self-removal of the rule in bypass mode) is stated as such, together with the server's indistinguishable refusal response; technical enforcement is claimed only for paths shown under AC-5/AC-6.
- [ ] **AC-8** Each control is labelled prevented-before, detected-after or instruction-only, with its protection target (accidental error vs deliberate bypass or manipulated input) and its limit.
- [ ] **AC-9** The server's identity is recorded with evidence — source, version, install and update behaviour, network reach, storage location — with vendor statements marked as such, and rechecked through the existing Tooling revalidation on relevant updates.
- [ ] **AC-10** A project without the server gets no additional rules, settings or required dependency.
- [ ] **AC-11** Existing projects can adopt the change through `/workflow-init` with a visible diff that preserves their own conditions; no global client settings, production access or real index is changed by the delivery or its tests, except through the one residual AC-14 accepts (narrowed 2026-10-07: managed settings a server delivers for the first time at a verification run's client start, accepted by Daniel for the tested environment type).
- [ ] **AC-12** The evidence reports observed false blocks of permitted work, stuck or aborted tasks, added instruction context and extra model or tool calls, each with its scope; no composite score.
- [ ] **AC-13** A missing or altered deny rule, including a misspelled tool name, is detected through the real client path, not only by inspecting a file. A denied tool counts as blocked only when, in the same run, permitted reads succeeded and an isolated control without that rule showed the tool available, so the rule is what makes the difference; a crash, a missing connection or an unfinished check never counts as a block.

- [ ] **AC-14** A verification run launches automatically only in the tested environment type and only after its pre-launch checks pass: known relevant start actions evaluated beforehand, suppressible hooks switched off, and the run's own tool calls, test data and every server path they reach isolated from real stores; any other unclear or unsafe start action means `unproven` without launching. The one accepted residual — managed settings a server delivers for the first time at that client start — is named with every result, together with the client and operating-system activity the run does not capture; after-the-fact signs of it make the result `unproven`, which neither prevents an effect that already happened nor proves that every start action was seen. A newly appearing managed setting, or a relevant change to the client, permissions, start configuration, server identity or affected account, invalidates earlier evidence until it is reassessed; widening this residual or any authority needs a new decision.

**Changed 2026-10-07 — gap found.** Decided by Daniel, relayed verbatim through the sparring session into this coding session on 2026-10-07 12:26 (decision D2, "AC-6 wie vorgeschlagen eingrenzen, aber die Unterscheidung zwischen wirksamer Sperre und technischem Fehler erhalten"). Baseline: e75f773. Gate-A spec pass 1 (cycle kvf25jfa6k) showed that `index_repository` cannot be bounded on 0.9.0 (destination `name`, cross-repo targets, `persistence`), so by AC-4's own condition agent indexing stays denied and AC-6's path-bound check has nothing to check.

| Earlier condition | Fate | AC operation |
|---|---|---|
| AC-6: detected through the real client path, not only by inspecting a file | moved → AC-13, per the decision: "AC-6 wie vorgeschlagen eingrenzen" (the proposal it confirms: "A missing or altered deny rule, including a misspelled tool name, is detected through the real client path") | withdrawn; added AC-13 |
| AC-6: a denied tool that is callable, including through a misspelled rule | moved → AC-13, per the decision: "AC-6 wie vorgeschlagen eingrenzen" (the proposal it confirms: "A missing or altered deny rule, including a misspelled tool name, is detected through the real client path") | withdrawn; added AC-13 |
| AC-6: a missing path bound, shown by an out-of-checkout index call that is not refused | dropped — per the decision: "Entferne die Pfadgrenzen-Prüfung mit Datum, Begründung "Indexieren in dieser Lieferung gesperrt"" | withdrawn |
| AC-6: a refusal counts only when a control rules out a technical error (same call against a target known to index without the bound) | moved → AC-13, as a control without the deny rule, per the decision: "Der isolierte Gegenvergleich muss belegen, dass die betreffende Regel den Unterschied macht; diese Anforderung darf nicht mit dem Pfadtest verschwinden" | added AC-13 |
| AC-6: rationale — the server returns the same "worker crashed" response for a refusal and a technical failure | moved → AC-13, per the decision: "Ein Absturz, eine fehlende Verbindung oder ein unvollständiger Test zählt weiterhin nicht als Sperrnachweis" | added AC-13 |

- **Unaccounted:** none.
- **Intervening changes:** none (story unchanged since e75f773).
- **Scope boundary:** in: detection of deny rules and its control; out: any path-bound check while indexing stays denied (the bounded refresh is a follow-up row).
- **Open questions:** none.
- **Dependent artifacts:** `docs/superpowers/specs/2026-10-07-codebase-memory-mcp-bounded-context-design.md` → open — permitted by `.claude/review-gates.md`, "Gate A's content condition, and its closing act" (the spec is committed by its Gate-A cycle's closing act, not here).
- **Reviews already run:** Gate-A spec cycle kvf25jfa6k, passes 1–2, read the old AC-6 → "no rule found" (input: a cited story's acceptance criteria; paragraphs checked: `.claude/review-gates.md` "Closure introduces no new kind of record" — "Where it changes a review input no source rule governs — a cited story's acceptance criteria or settled decisions, say — nothing here reaches it" — and "The cited set is re-read at each pass"); human decision: continue the open cycle; its next pass reads this amended story.


**Changed 2026-10-07 — gap found.** Decided by Daniel, relayed verbatim through the sparring session into this coding session on 2026-10-07 15:03 ("Die benannte Restlücke erstmals beim Clientstart eintreffender verwalteter Vorgaben wird für den nachgewiesenen unterstützten Umgebungstyp ausdrücklich akzeptiert."). Baseline: 52879bf. Gate-A spec passes 5–7 (cycle kvf25jfa6k) showed that a verification run through the real client starts whatever the environment starts, and that one start source — managed settings delivered by the server for the first time at that start — cannot be excluded before launching; the probe `startprobe/` showed hooks suppressible and a statusLine command inactive in headless runs on the tested installation.

| Earlier condition | Fate | AC operation |
|---|---|---|
| AC-11: existing projects adopt through `/workflow-init` with a visible diff preserving their own conditions | kept | none |
| AC-11: no global client settings or production access changed by the delivery or its tests | kept | none |
| AC-11: no real index changed by the delivery or its tests | kept, except the accepted residual; dropped — for that residual only, per the decision: "Die benannte Restlücke erstmals beim Clientstart eintreffender verwalteter Vorgaben wird für den nachgewiesenen unterstützten Umgebungstyp ausdrücklich akzeptiert." | narrowed |
| (new) launch conditions, isolation, unknown start actions, residual disclosure, invalidation | — per the decision: "Bekannte relevante Startaktionen bleiben vorab bewertet; unterdrückbare Hooks bleiben abgeschaltet; kontrollierte Testaufrufe, Testdaten und Serverpfade bleiben isoliert. Sonstige ungeklärte/unsichere Startaktionen bleiben ein Grund für unproven ohne Start." and "Neu auftauchende verwaltete Vorgaben oder relevante Änderungen an Client, Berechtigungen, Startkonfiguration, Serveridentität oder betroffenem Konto entwerten den bisherigen Nachweis" | added AC-14 |

- **Unaccounted:** none.
- **Intervening changes:** none (story unchanged since 52879bf).
- **Scope boundary:** in: verification runs in the tested environment type; out: any other machine or client, global configuration changes, production access, general gate exceptions, unknown start commands.
- **Open questions:** none.
- **Dependent artifacts:** `docs/superpowers/specs/2026-10-07-codebase-memory-mcp-bounded-context-design.md` → open — permitted by `.claude/review-gates.md`, "Gate A's content condition, and its closing act".
- **Reviews already run:** Gate-A spec cycle kvf25jfa6k, passes 1–7, read the earlier AC-11 → "no rule found" (input: a cited story's acceptance criteria; paragraphs checked: `.claude/review-gates.md` "Closure introduces no new kind of record" and "The cited set is re-read at each pass"); human decision: continue the open cycle; its next pass reads this amended story.

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
