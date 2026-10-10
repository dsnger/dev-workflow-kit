# A route from a fixed finding to the ledger, for projects that never open PRs — Story

**Date:** 2026-08-04 · **Size:** story
**Risk:** standard · **Security:** none · **Validation:** battery+check

**Profile log:**
- 2026-10-09 · adoption · in-flight story adopting a profile before design resumes, as AC-1 requires; confirmed by Daniel · gates now read this header

## 1. Problem statement

The only mandated ledger check lives in `/dev-workflow:process-pr-review` step 5, so a project
that never opens a pull request never reaches it. One project has 51 Gate-A pass files and
**zero** ledger rows: findings were raised, validated and fixed, and none was ever considered
for hardening.

2026-10-09: an empty ledger also occurs in a project that opens pull requests.
`sfx-bricks-api-builder` has 22 merges into `main` from 2026-10-02 on, and its session notes
record fixed Greptile findings, yet its `docs/hardening-log.md` had 0 rows when counted on 2026-10-06
(`todos.md`, Finding A row).

2026-10-10: in `sfx-time-tracking-dashboard` (counted at `577f18d`), 9 closed Gate-B cycles
repaired at least one Major, and `docs/hardening-log.md` still holds only its table header,
unchanged since the scaffold commit `f0c8fe8` (`todos.md`, Finding A row).

### Conditions inherited from the source row

From `todos.md`, "**Finding A — a route from a fixed finding to the ledger for projects that
never open PRs.**":

| Condition | Disposition |
|---|---|
| Scope must match `process-pr-review` step 5 **exactly** — check every accepted actionable fixed finding, but invoke `harden-finding` only when a class matches or a new one is clearly warranted | **kept** — every approximating draft got this wrong |
| Cannot rest on same-session memory: a compaction, interruption or handoff loses the fixed-finding set and nothing detects the loss | **kept** |
| A durable handoff needs real design — identity, deduplication, consumption semantics | **kept**, and it is why this is a story rather than a mid-round addition |
| It mints `mandatory-step-anchored-to-optional-path` when it lands; minting earlier leaves a class no row uses | **kept** — the class is minted by the change that uses it |
| Evidence: canvas has 51 Gate-A pass files and 0 ledger rows | **kept** as the motivating instance |
| Trigger, first alternative: the next round that touches §5 | **moved** — fired by the 2026-08-03 round, recorded here |
| Trigger, second alternative: a project reporting an empty ledger across cycles that fixed findings | **kept** — it did not fire, and it remains the condition that would raise this independently |

## 2. Desired outcome

A project that fixes review findings without opening a pull request still reaches the ledger
check, and a fixed finding that warrants hardening is not lost to a compaction, an interruption
or a handoff.

## 3. Acceptance criteria

_IDs are permanent once the story is committed: never renumber or reuse one; a new criterion takes the next number unused here and on the branch it merges into, and a collision stops for a human; a removed one stays, struck through and dated; a narrowed one keeps its ID with a dated note; cite as `<story path> AC-<n>`; full rules: dev-workflow:intake, "Acceptance-criterion IDs"._
- [x] **AC-1** Before design resumes on this story, whoever picks it up proposes both axes and the mode
      derived from them, pauses for Daniel's confirmation, and writes the confirmed profile into
      this header. Design continues only after that.
- [ ] **AC-2** ~~A project with no pull requests reaches a ledger check on the findings it fixed.~~ — withdrawn 2026-10-09: scope widened to every project, replaced by AC-5
- [ ] **AC-3** The route does not depend on same-session memory.
- [ ] **AC-4** The check's scope matches `process-pr-review` step 5 exactly — no wider, no narrower.
- [ ] **AC-5** A project that fixes review findings reaches a ledger check on them whether or not it
      opens pull requests.

2026-10-09: identifiers adopted under intake's "Acceptance-criterion IDs" rule 5, numbering the four
existing criteria in their order.

**Changed 2026-10-09 — changed requirement.** Decided by Daniel, in the coding session of 2026-10-09
(21:53 CEST), answering the proposal to widen the scope: "Ja, macht beides wie empfohlen." The
proposal read: "Umfang erweitern auf 'alle Projekte mit leerem Ledger, obwohl Findings behoben
wurden'", and the same answer confirmed the profile proposal (risk `standard`, security `none`,
validation `battery+check`). Baseline: `6405406`. Rationale: `todos.md`'s Finding A row records
on 2026-10-06 that `sfx-bricks-api-builder` opens pull requests (22 merges into `main` from 2026-10-02
on) and still has 0 ledger rows, so an empty ledger is not limited to projects without PRs. That
evidence is also the second trigger alternative in §1's table, which has fired since this story was
written.

| Earlier condition | Fate | AC operation |
|---|---|---|
| Header: "Unprofiled, deliberately …", with AC-1 carrying the profile debt | dropped — per the decision, which confirmed the profile proposal; the profile header and its adoption log entry replace it | none |
| §1 problem statement and the "Conditions inherited from the source row" table | kept; §1 gains one dated paragraph with the 2026-10-06 evidence | none |
| §2: "A project that fixes review findings without opening a pull request still reaches the ledger check" | kept: no-PR projects; widened to every project, per the decision: "alle Projekte mit leerem Ledger, obwohl Findings behoben wurden" | none |
| §2: "a fixed finding that warrants hardening is not lost to a compaction, an interruption or a handoff" | kept | none |
| AC-1: profile before design resumes | kept, and met by this change | none |
| AC-2: a project with no pull requests reaches a ledger check | kept in AC-5: no-PR projects; widened to every project, per the decision: "alle Projekte mit leerem Ledger, obwohl Findings behoben wurden" | withdrawn; added AC-5 |
| AC-3: no dependence on same-session memory | kept | none |
| AC-4: scope matches `process-pr-review` step 5 exactly | kept | none |
| §4: invariants 11 and 12 | kept | none |
| §5: open question limited to projects that never open a pull request | kept for no-PR projects; widened to every project per the decision; one question added from the 2026-10-06 evidence | none |
| §6: `story` | kept | none |

- **Unaccounted:** none.
- **Intervening changes:** none — the file at `HEAD` equals `6405406`.
- **Scope boundary:** in: every project that fixes review findings, with or without pull requests.
  out: unchanged from the baseline. The title and file path are kept so existing citations stay
  valid. They still say "projects that never open PRs".
- **Open questions:** whether `process-pr-review` step 5 ran in `sfx-bricks-api-builder`, and
  whether any of its fixed findings qualified for hardening → §5.
- **Dependent artifacts:** none. `todos.md`'s Finding A row names this story as the owner and already
  records the 2026-10-06 evidence. No spec or plan cites this story in a `Story:` header (checked
  under `docs/superpowers/specs/` and `docs/superpowers/plans/`).
- **Reviews already run:** none. No Gate-A or Gate-B cycle has had this story as a cited input
  (same check), so `.claude/review-gates.md` has nothing to decide here.

**Changed 2026-10-10 — gap found.** Decided by Daniel, in the coding session of 2026-10-10
(08:48 CEST), answering the proposal to record the SFX ledger count as evidence in this story:
"Ja, trag das ein." Baseline: `a54389e`. Rationale: §1 gains one dated evidence paragraph. No
condition changes.

| Earlier condition | Fate | AC operation |
|---|---|---|
| Every condition the 2026-10-09 record lists, as it stands after that record | kept | none |

- **Unaccounted:** none.
- **Intervening changes:** none — the file at `HEAD` equals `a54389e`.
- **Scope boundary:** unchanged.
- **Open questions:** none.
- **Dependent artifacts:** `todos.md` → updated in this change (Finding A row, 2026-10-10 evidence).
- **Reviews already run:** none (same check as the 2026-10-09 record).

## 4. Affected AGENTS.md invariants

- `## Key invariants` → `### Prompts and scaffolding` — "11. **Prompt changes pass
  `docs/prompt-standards.md`** — all 12 checklist items, for any skill, command, agent
  definition, hook message, or scaffolded template."
- `## Key invariants` → `### Packaging` — "12. **A plugin change requires a version bump.**"

## 5. Open questions

- What has to be true for a fixed finding to reach the ledger in a project that never opens a
  pull request? (2026-10-09: and in one that does, AC-5.)
- 2026-10-09: in `sfx-bricks-api-builder` (opens PRs, 0 ledger rows), did `process-pr-review`
  step 5 run, and did any of its fixed findings qualify for hardening? Unknown per `todos.md`.

## 6. Suggested size

`story` — one route, one spec → plan → PR.
