# Living-docs pilot report — SFX dashboard (setup + P7)

**Date:** 2026-10-23 · **Story:** `docs/superpowers/stories/2026-10-06-living-feature-docs-pilot-story.md`
(cited below as AC-<n>) · **Project:** SFX time-tracking dashboard (nitlogger), branch `v2`.

This is the one authoritative pilot report (AC-10). SFX is to link to it and keep no copy; that link is still
outstanding, a follow-up outside this repo.

## Sources

All SFX paths are relative to the SFX main checkout `/Users/daniel/DEVELOPMENT/APPS/sfx-time-tracking-dashboard`.
Files marked *untracked* exist only in that checkout's `.context/`; they are read here, not copied.

| Short name | Path | What it holds |
|---|---|---|
| setup spec | `docs/superpowers/specs/2026-10-16-living-docs-pilot-design.md` | the setup design, decisions D1–D6, §5 loading record |
| setup plan | `docs/superpowers/plans/2026-10-16-living-docs-pilot.md` | tasks T1–T7 |
| first-fill record | `.context/lanes/docs-pilot/docs-pilot.md` (untracked) | sizes, time, tokens, labels, orientation problems, loading |
| lane log | `.context/lanes/docs-pilot/log.md` (untracked) | timestamps of every lane stage and human stop |
| usage | `.context/lanes/docs-pilot/usage.txt` (untracked) | harness `subagent_tokens`, `duration_ms`, `tool_uses` per builder |
| P7 plan | `docs/superpowers/plans/2026-10-22-v2-p7-claude-code-reference-plugin.md` | the measured story's plan, Sources and impact boundary, Tasks 8–9 |
| P7 handover | `docs/handovers/p7.md` | merge record, § Living-docs measurement |
| P7 measurement | `.context/archive-lane-p7-build/p7-docs-measurement.md` (untracked) | Task 9 figures (a)–(c) |
| P7 unit handovers | `.context/archive-lane-p7-build/handover-p7-build{1,2}.md` (untracked) | build record, deviations |
| P7 Gate B passes | `.context/archive-lane-p7-build/codex-reviews/gate-b-*-p7gateb23-pass-*.md`, `…p7gbgrep62…`, `…p7gbrefuse62…` (untracked) | every Gate B finding |
| P5b note | `.context/plan-form-pilot.md` (untracked) | P5a/P5b plan-form figures |
| P5b read | this repo, `todos.md`, "2026-10-09 — P5b pilot read" | the kit's reading of the P5b note |

The setup merged as SFX PR #11 (`155618c`, 2026-10-16); the measured story P7 merged as PR #62 (`c5b328e`,
2026-10-23). Figures marked *measured here* were taken in this session with `git show <commit>:<path> | wc -c`
or `git log` in the SFX checkout.

## Pilot scope (AC-2, AC-3)

- **Story crossing a feature border (AC-2):** P7, the Claude Code reference plugin. It calls the MCP agent
  interface, drives the timer, reports runs and tokens and authenticates with an agent access (setup spec §3).
  P5b had closed on 2026-10-06 (`af2bdb9`, P5b note); the setup started 2026-10-16.
- **Planning method during the pilot (AC-2): not unchanged.** SFX adopted kit rule texts three times between the
  setup merge and the P7 merge: `e8d1e06` (dev-workflow 0.39.0, 2026-10-21), `d3f48cb` (0.40.0), `d369671`
  (0.41.0, 2026-10-22). 0.39.0 changed `CLAUDE.md` §4's plan section (handover boundary, long runs) and added
  "Autonomous run" (measured here: `git diff 155618c d369671 -- CLAUDE.md`). The P7 plan was written under
  those rules. AC-2's second condition therefore did not hold; the effect on the figures is unknown.
- **Coverage (AC-3).** The feature map in `docs/PRD.md` has 17 rows at `ca1defb` (measured here). Seven feature
  docs were written at setup (four core, three neighbours; setup spec §3); P7 added the eighth,
  `docs/features/claude-code-plugin.md`. Nine rows say "no doc yet": dashboard and live updates, sign-in and
  sessions, own account, re-valuation, purge, company settings, users and invitations, rate rules and valuation,
  mail delivery. Known gaps: no glossary (the existing `CONTEXT.md` is the legacy one; first-fill record §6, T4);
  no cross-feature flow section in any document (measured here: no flow section in `docs/PRD.md` or
  `docs/ARCHITECTURE.md`); the timer row is `partial` (recovery orchestration is P8's). The impact investigation
  in P7 added no documentation beyond the plan's list. No other part of SFX was reorganised.

## AC-4 — sources beyond the map-guided set, and human assists

The map-guided set for P7: the story and spec §12 with the plan; the touched feature docs and flows; the shared
contracts and their users; the project rules.

**Plan stage** (P7 plan, "Sources and impact boundary", l.10–56). Read beyond the set:

| Source | When | Why | Counted |
|---|---|---|---|
| P0 hook-spike evidence (`docs/superpowers/research/2026-10-03-claude-code-hook-spike-evidence.md`) | plan, 2026-10-22 | the spec's evidence input | no — planned on-demand historical read |
| first-fill record (untracked) | plan | Task 9's measurement method | no — measurement, not task context |
| server and e2e test harnesses (`apps/server/src/http/testing/*`, `apps/server/scripts/with-postgres.sh`, `apps/web/e2e/{harness,seed,run-env}.ts`) | plan | reuse for the db and demo tests; no living doc covers the test setup | yes — 1 group, planned in the plan's list |
| Context7 lookups (Claude Code hooks/plugins, Vitest, Zod, Playwright) | plan, 2026-10-22 | the gate rules' Library APIs duty | no — required by rule |

Of the seven slice feature docs, the plan's read list names two: `mcp-agent-interface.md` (plan l.122) and
`agents-and-accesses.md` l.78 (plan l.18), plus the PRD feature map and the ARCHITECTURE component table.

**Build stage.** Unknown. Unit 1's builders did not list the files they opened. Their dispatch named a brief,
`constraints.md`, `decisions.md` and `spec-12.md` from the SDD workspace, and no living doc (P7 measurement (a)).
Unit 2's docs work ran in the main session, which also kept no list.

**Human assists.**

| When | Who | What | Why |
|---|---|---|---|
| 2026-10-16 15:43 | Daniel via the orchestrator | reviewed the INFERRED lines: 13 correct, 2 wrong, 1 wrong side claim; three fixes ordered | setup spec §4.4: Daniel reads the INFERRED lines before merge (lane log) |
| 2026-10-16 16:07 | Daniel via the orchestrator | decided the Mail row's `Last changed` date (option a) | one review fix had broken the PRD's own dating rule (lane log) |
| P7 | — | none recorded for finding anything | P7 handover |

Setup builders T1–T7 each recorded "No human help needed" (first-fill record §6).

**Human decisions and approvals** (not orientation help, listed so the inventory is complete as far as the
records go):

| When | Who | What | Why |
|---|---|---|---|
| 2026-10-16 12:17 | Daniel | intake answers: profile, scope option (b), goals/non-goals to `docs/PRD.md`, measurement file location | the lane stopped at intake for them (lane log) |
| 2026-10-16 14:45 | Daniel via the orchestrator | spec approved; `CLAUDE.md` sentence amendment | brainstorming's spec review stop (lane log) |
| 2026-10-22 | Daniel | D1: approved the foundation §12 amendment P7 builds on | P7 plan header |
| P7 build | the orchestrator | unknown whether a go for the heavy live-demo run was given: Unit 1's handover asks the next session to send the orchestrator the heavy-run line first (Next 2); no answer is recorded | P7 unit 1 handover |

Other human contact in P7 is not recorded; this inventory is complete only as far as the logs and handovers
are.

## AC-5 — effort

| Effort | Value | Unit | How it was captured |
|---|---|---|---|
| Setup, builders T1–T7 plus four repair builders | 1,405,944 tokens; 1,701,098 ms (28 min 21 s); 271 tool uses | harness `subagent_tokens`, `duration_ms`, `tool_uses` | `usage.txt`, summed here |
| of which first fill T1–T6 | 894,190 tokens; 1,252,934 ms (20 min 53 s) | as above | first-fill record §3 |
| of which review repairs (builders 8–11) | 395,299 tokens; 311,703 ms | as above | `usage.txt` |
| Setup, main session and orchestrator | unknown | — | not recorded |
| Setup, lane wall clock intake → merge | 11:42:04 → 16:41:04 (4 h 59 min), including about 2 h of waits for Daniel (12:17 answer; 13:15–14:45 spec review) | wall clock | lane log timestamps |
| Upkeep within P7 (Task 8) | 48 min wall clock (23:15:41–00:03:59), interleaved with the live demo and two demo fixes | wall clock | `date` stamps, P7 measurement (c) |
| Upkeep within P7, active time | unknown — the source's "about 20 min" is INFERRED from tool order, not captured | — | P7 measurement (c) |
| Upkeep within P7, tokens | unknown — the main session did the work | — | P7 measurement (c) |
| Upkeep in the 13 merges between setup and P7 that edited the docs | unknown (see AC-12) | — | `git log 155618c..d369671` on the living docs, measured here |
| Searching for context (setup and P7) | unknown — no stamp separates search from writing | — | — |

## AC-6 — omissions

**Baseline:** the P7 plan's "Sources and impact boundary" (l.10–56) at `006a11f` (PR #59, 2026-10-22 19:09),
the first note of impact scope. It is the only commit touching the plan file, so the note was never amended
(measured here: `git log -- <plan>`). No "Features touched" note was written at intake, although `docs/PRD.md`
"How this file is maintained" asks for one. At feature level the note covers, through the spec sections it
reads and the files it names: MCP agent interface (§11.3, `mcp.ts`, `MCP_INSTRUCTIONS`), timer (§7.1–7.4,
§7.8), runs and tokens (§8), agents and accesses (`agents-and-accesses.md` l.78, `issueToken`), and the new
plugin feature; time entries and master data only through the twelve MCP tools of §11.3 and
`routes/actors.ts`; interruption review only through the demo's "one interruption open for review" checks.

**Dependencies that surfaced later, classified by dependency, not by where the defect sat:**

| Dependency | Kind | Surfaced | In the first note? |
|---|---|---|---|
| auto-pause by the jobs worker (`apps/server/src/jobs/tasks.ts:215`) | timer behaviour (time-triggered) | Unit 1, deviation 17 | feature yes (§7.4); the worker file no |
| `UNAUTHENTICATED`/`FORBIDDEN` on `list_projects`/`list_services` | contract behaviour, master data via MCP | Gate B spec pass 2–3, quality pass 3 | yes (l.78, decision P6) |
| interval reconciliation after a person's switch (`STALE_STATE`) | contract behaviour, timer | Gate B pass 1 both slots | yes (`mcp-agent-interface.md` "Stale state", plan l.122) |
| retry deadlines (`RATE_LIMITED`, `RETRY_LATER`) at `SessionEnd` | contract behaviour, MCP | Gate B spec pass 1 | yes (decision P6) |
| hook budget against transcript size | client platform (Claude Code hooks) | Gate B spec pass 1 | yes (Context7 lookup, plan l.21–27) |

**Confirmed omissions in the checked evidence: 0.** One case is a partial one and is named so a reader can
judge it: the jobs worker. Its feature and the spec section binding it were in the note, the code path was
not; the timer doc named both paths (`docs/features/timer.md` l.16, l.42–44 at `d369671`), but the plan did not
read that doc. This report does not count it, because AC-6 counts a missing feature, contract, shared data or
event, and none of these was missing.

**Evidence checked:** the five rows above; the 19 findings of Gate B cycle `p7gateb23` (passes 1–3, both
slots); the cycles `p7gbgrep62` and `p7gbrefuse62` (0 findings each); the two Greptile claims; the one red CI
attempt (two `apps/web` settings tests in files the diff did not touch, green on rerun); the merge with `e2e`
green (P7 handover); the deviations lists of both unit handovers.

**Not checked — unknown:** the task reviews and fix rounds of Unit 1 (T2, T3, T5, including a HIGH security
finding) and Unit 2's whole-branch review and ponytail pre-review findings. Their full text was in the SDD
ledger `.superpowers/sdd/…/progress.md` of the p7-build worktree, which no longer exists; only the
handovers' summaries remain. Build-stage context is also unknown (AC-4).

Zero is therefore limited to the evidence listed and is not evidence that the scope was complete.

## AC-7 — lengths (observations, not a pass bar)

| Item | Bytes | Source |
|---|---|---|
| P7 spec: foundation spec §12 at the merge | 9,347 (whole foundation spec 164,527) | measured here at `c5b328e`; the SDD `spec-12.md` has the same 9,347 (P7 measurement (a)) |
| P7 plan | 39,529 | measured here at `c5b328e` |
| Feature docs P7 touched, at the merge: `claude-code-plugin.md` / `agents-and-accesses.md` / `mcp-agent-interface.md` | 8,274 / 11,442 / 9,530 | measured here |
| Top-level docs at the merge: `PRD.md` / `ARCHITECTURE.md` / `TECH-STACK.md` | 10,419 / 16,998 / 11,836 | measured here |
| First fill: seven feature docs / all ten new docs | 63,081 / 95,775 | first-fill record §1 |
| Context named in each builder's dispatch, Unit 1 (sizes of the named files; whether they were opened is unknown) | T1 28,403 · T2 28,358 · T3 30,663 · T4 28,352 · T5 31,394 · T6 30,465; sum 177,635; living docs 0 | P7 measurement (a) |
| Context actually read (named files opened, and files beyond them) | unknown | P7 measurement (a) |
| Configured auto-loaded files `CLAUDE.md` + `AGENTS.md` per session (from configuration, AC-13) | 27,271 at `0f0c3fe` (before) · 21,622 at setup head · 27,441 at `98ae857` (P7) | first-fill record §7; P7 measurement (a) |

**P5b reference — not comparable to a savings figure.** P5b's plan was 66,968 bytes at Gate-A close (P5a:
660,054; P5b note). P5b's spec length, feature-doc length (none existed) and context read were not recorded;
they are missing, not reconstructed.

## AC-12 — orientation problems, and is the split worth its upkeep?

**Setup** (first-fill record §6, 22 entries; categories are this report's grouping):
- *Wrong place searched* — 7: plan sources named contract route families or use-case files that do not
  exist; the code was in `routes/actors.ts`, `routes/entries.ts`, `app/handover.ts`, `master-data.ts`,
  `interruptions.ts`, `domain/review.ts`, `app/snapshot.ts` (T1, T2 ×2, T3 ×2, T4 brainstorm log, T2 todos-only
  follow-ups).
- *Unclear authoritative source* — 8: lock order (AGENTS.md vs foundation §5.8, T1); the recovery-pause
  trigger, found only in a P3a plan decision (T1); pg-boss rationale superseded (T4); no source on a v2 Docker
  image (T4); foundation §13 cited as a row source but it is the web-UI spec (T5); `Last changed` of combined
  rows (T5); sign-in and mail sentences sourced from AGENTS.md and plan goals, not confirmed in code (T5); a
  rule attributed to a plan outside the sources (T3).
- *Human help* — 0.
- The other 7: tooling (zsh `=====`, macOS `wc`, a grep pattern, no named link checker), the missing glossary,
  and two placement choices (T6).

**P7:**
- *Wrong place searched* — 1: the setup's `linkcheck.py` was not in the main checkout (it had lived in a
  scratchpad). Task 8 wrote a replacement that checks file targets only; heading fragments, which the setup's
  check covered (first-fill record §8), went unchecked (P7 unit 2 handover, deviation 7).
- *Unclear authoritative source* — 1, found by this report, not by P7: SFX `CLAUDE.md` says "Project
  architecture, stack-specific patterns, and invariants live in @AGENTS.md", while `AGENTS.md` § Documentation
  map sends architecture to `docs/ARCHITECTURE.md`. The setup had replaced that sentence (setup spec §4.5);
  the kit 0.39.0 adoption `e8d1e06` brought the old sentence back, and it stands at `ca1defb` (measured here).
  The kit's `/workflow-init` template still ships the old sentence (`plugins/dev-workflow/commands/workflow-init.md:567`),
  while this repo's own `CLAUDE.md` has the new one. P7's build record checks the three top-level docs and the
  feature docs; `CLAUDE.md` is not on that list.
- *Human help* — 0.

**Upkeep observed.** Setup: 28 min of builder time and 1.41 M builder tokens, plus unknown main-session effort.
Per change: P7's Task 8 took 48 min wall clock. Between setup and P7, 13 merges edited the living docs in the
same change as their work (S6a, S6b, S6c1, S6c2, S6d, S6e1, S6e2, T-1, T-7, T-8, P8a, P0, the §12 amendment;
measured here: `git log 155618c..d369671 -- docs/PRD.md docs/ARCHITECTURE.md docs/TECH-STACK.md docs/features`);
whether every merge that changed behaviour did so was not checked, and their effort is unknown. Gate B found 1 stale living-doc line in P7 (a NIT:
`docs/ARCHITECTURE.md` "Three workspace packages" while listing four).

**Drift found after the merge** (by this report's review, Gate A pass 2; checked here at `c5b328e`), counted
apart from the Gate B figure: three slice docs still list as `planned` what P7 built and
`docs/features/claude-code-plugin.md` l.35–53 describes as current — `docs/features/timer.md` l.84–90 (Claude
Code controller mapping), `docs/features/runs-and-tokens.md` l.61–63 (controller token reporting,
"provisional until P0"), `docs/features/master-data.md` l.47–50 (`.nitlogger.json` suggestions). None of the
three is in P7's build record (P7 unit 2 handover, "Build record"): it lists the docs P7 changed and
`TECH-STACK.md`, so these three were neither changed nor recorded as checked. The record did keep "not
checked" visible as an absence; it did not prevent the drift, because nothing required a line for every
slice doc whose behaviour the story changes.

**Judgement.** In the 14 merges observed (13 plus P7) the docs were edited in the same change, yet P7 left
three slice docs stale. The measured
upkeep is P7's 48 min wall clock, which includes demo waiting and has no active-time figure; there is no
comparison or tolerance to call it high or low, and the rest is unknown. The benefit could not be
shown where the model expects it: at the build stage no living doc was handed to a builder, and context read
is unknown. At the plan stage the feature docs supplied exact rule references (plan l.18, l.122). Most setup
orientation problems came from dated plans and specs pointing at the wrong place — the problem the living docs
are meant to remove — but whether they removed it in P7 is not measured. So the split is not shown to be
worth its upkeep, and not shown to be not worth it.

## AC-13 — instruction loading

Recorded before P7 ran, in setup spec §5 and first-fill record §7: Claude Code loads `CLAUDE.md`, and
`AGENTS.md` through its `@AGENTS.md` import; Codex and the PR bots read `AGENTS.md`; files under `docs/` are read
only when an agent follows a pointer. This was read from configuration, not observed at runtime. Architecture
knowledge people need lives in `docs/ARCHITECTURE.md`. Since `e8d1e06` the `CLAUDE.md` sentence above points
people and agents to `AGENTS.md` for architecture instead (AC-12).

## AC-1 — note on the decision's placement

The recorded decision (vision §2 change record, `docs/superpowers/specs/2026-08-30-dark-factory-vision.md`
l.241) says `AGENTS.md` holds the architecture core and the slim feature map. SFX placed the map in
`docs/PRD.md` and the architecture core in `docs/ARCHITECTURE.md`, with `AGENTS.md` as the index (setup spec
D1, D2). The pilot therefore tested that placement, not the decision's.

## Recommendation (AC-8)

**Adapt.**

**Exercised** in the pilot: the structure documents (`docs/PRD.md` with the feature map, `docs/ARCHITECTURE.md`,
`docs/TECH-STACK.md`, feature docs) with descriptive authority and provenance labels (setup spec §2a); the
signpost (`AGENTS.md` § Documentation map, AC-11); the build record `changed | checked, unchanged` at the end
of a change; the size soft alarm (two docs past 10 k reported, none split); docs updated in the same change.

**Not exercised**, so this report draws no conclusion about them: assigning a story to its features at intake;
map-guided context assembly by the builders; cross-feature flow sections and their tests; the impact check along
dependencies with a stated end; the conflict check of shared contracts and the composed-candidate check;
removal; a splitting decision; capability or child-feature levels.

**Changes the adoption story should make** to the exercised elements:
1. The build record has one line for every feature doc whose described behaviour or `Planned` section the
   change affects, the neighbours included, not only for the docs the change edited; a missing line is a
   finding. P7 left three such docs stale (AC-12).
2. The build record also covers the instruction files that carry the signpost's authority claims (`CLAUDE.md`),
   and the kit template's architecture sentence matches the signpost. The 0.39.0 adoption put the old sentence
   back unnoticed (AC-12).
3. The build record's link check is kept with the docs, not in a scratchpad, and checks heading fragments too.
   P7 could not find the setup's checker and lost fragment coverage (AC-12).
4. Effort for setup and for upkeep is stamped per piece, so AC-5's unknowns can be captured.

**Not a conclusion of this pilot, but needed to test the rest:** a further measurement run would need the
story's features named before planning, so that AC-6 has a feature-level baseline instead of one reconstructed
afterwards as here; each builder's dispatch naming its map-guided set and the builder listing the files it
opens, so that context read can be measured (AC-4, AC-7); and the full task-review and whole-branch-review
records kept until the report is written, so that AC-6 can cover the whole run. They are requirements for
measuring, not results of it.

**Reasons.** The documents were edited in the same change in the 14 merges observed, and Gate B found one stale
line in P7. That argues against rejecting the exercised elements. Three slice docs left stale by P7 argue that
the build record, as exercised, is not enough on its own. But the benefit the model promises — reading
less and seeing integration risks earlier — was not measured, the upkeep effort is mostly unknown, and AC-2's
fixed planning method did not hold. That argues against adopting them unchanged.
