# Ledger check at every review cycle's close — Design

**Story:** `docs/superpowers/stories/2026-08-04-ledger-route-without-pull-requests-story.md` — read its profile fresh at each pass.

**Date:** 2026-10-10 · **Decided with:** Daniel. Approach A (check at each Gate-A and Gate-B
cycle's close), D1 a (dispositions file mandatory for repaired findings) and D2 b (check and
record at close, harden later as its own change) on 2026-10-09; design part 1 ("Ok") and
part 2 ("Ok, Teil 2 passt, schreib die Spec.") on 2026-10-10. Part 2 as approved includes the
corrections from two external recommendations (Orca messages msg_1274b1debe8a and a relayed
follow-up), each validated against the sources named below.

## 1. Problem, as it stands on 2026-10-10

The only mandated ledger check is `process-pr-review` step 5
(`plugins/dev-workflow/commands/process-pr-review.md`, item 5). It runs on PR-bot findings only.
Findings that the two review gates raise and the author repairs reach no ledger check at all,
with or without pull requests. Story §1 records three projects where that left
`docs/hardening-log.md` empty: canvas (51 Gate-A pass files), `sfx-bricks-api-builder` (22
merges), `sfx-time-tracking-dashboard` (9 closed Gate-B cycles with a repaired Major; its P6c1
cycle `07hfgs3o7mye` alone recorded 59 findings over 9 passes on 2026-10-10).

The story's inherited conditions name what a durable route needs: identity, deduplication and
consumption semantics, no reliance on same-session memory (AC-3), and a scope exactly that of
step 5 (AC-4).

## 2. Answers to the story's open questions

- **What has to be true for a fixed finding to reach the ledger?** Every review cycle that
  repaired a finding performs the ledger check before its closing act completes, and the result
  sits in a record git keeps (§3.3). That holds whether or not the project opens pull requests
  (AC-5).
- **Did step 5 run in `sfx-bricks-api-builder`, and did any fixed finding qualify?** Not
  answered here and not needed for the design: the route below does not depend on it. It stays
  unknown, as `todos.md` records.

## 3. Design

### 3.1 Scope of the check (AC-4)

The check applies step 5's rule to gate findings: **every accepted, actionable finding the
cycle repaired** is checked against `docs/hardening-log.md` (fingerprint mapping and the
anchored column-2 grep, `harden-finding` Flow steps 2–3). Hardening is **owed** only when the
finding matches an existing class or a new class is clearly warranted. No severity filter:
step 5 has none, so a repaired Minor is checked like a Major. A finding the cycle dismissed or
did not repair is not checked, as in step 5.

### 3.2 The dispositions file becomes mandatory for repaired findings (D1 a)

Today `<slot>-dispositions.md` is an optional companion, "advisory and authoritative for
nothing" (`.claude/review-gates.md`, Optional companions; resume paragraph).

- **New duty:** for every pass with at least one repaired finding, the author writes
  `<slot>-dispositions.md` before the cycle's closing act, one line per finding of that slot.
  Each line starts with one verdict from a closed set: `fixed`, `not fixed`, or
  `same as <slot>:<n>`, then a reason.
- **Finding identity** is `<slot>:<n>`: the findings file's slot name plus the finding's line
  number in that file. A findings file is not edited after its pass, so the pair is stable
  within the checkout. It is a location, not a cross-checkout identity; §3.3 carries what
  survives.
- **Deduplication:** the same defect raised in several passes, or by both Gate-B branches, is
  marked `same as <slot>:<n>` pointing at its first occurrence, and is checked once.
- **Authority, bounded:** the file is authoritative **for the ledger check only**. Its role in
  holds, answers, resume and recovery is unchanged; the resume paragraph's "advisory and
  authoritative for nothing" is narrowed to name that one exception and nothing more.
- **Missing file at close:** the author writes it then, from the findings files and the diff —
  durable sources, not memory — before the closing act.

A zero-finding pass, and a pass whose findings were all not repaired, still needs no
companion.

### 3.3 The record: one ledger-check line in the closing commit (D2 b)

At close, the author performs the check (§3.1) and writes, in the commit body that already
carries the cycle's provenance line and curve:

```
cycle <nonce>; ledger check: fixed <N>, hardening owed <M>
cycle <nonce>; hardening owed <slot>:<n> — <class, or "new class <name>"> — <one-line defect description>
```

- `<N>` counts distinct repaired findings after deduplication; `<M>` how many of them owe
  hardening. One `hardening owed` line per owed finding.
- The defect description makes the line readable without the findings file, which may be
  untracked or absent in a later checkout.
- A cycle with no repaired finding writes `fixed 0, hardening owed 0`, so "checked, nothing
  owed" differs from "not checked".
- A **skipped** cycle (Gate-B triviality skip) runs no reviewer and so has no gate findings; it
  writes no ledger-check line. A repair made in it because of PR-bot findings stays with step 5;
  findings from any other source gain no new route (AC-4).
- The closure ordering, the branches and what the closing act is stay unchanged; the check
  changes no artifact content. For Gate A this keeps "no new revision of the artifact is made to
  close a Gate-A cycle".
- **Contract membership:** the line is a §5 cycle record carrying the cycle field, so it is a
  member of the "one contract" paragraph: it is added to the nonce paragraph's named set of
  records and to the squash-merge carry list.

### 3.4 Consumption: when an owed hardening is done

Hardening runs afterwards as its own change with its own gate (D2 b). That change writes one
line per owed finding it handles, in its commit body:

```
cycle <nonce>; hardening <slot>:<n>: rung <1|2|3|4|P>
cycle <nonce>; hardening <slot>:<n>: pending <ref>
cycle <nonce>; hardening <slot>:<n>: rung 0 — <the mandatory check that already catches it>
```

- `rung 1–4|P` (a ledger row exists) and `rung 0` (no row, by `harden-finding`'s own rule) end
  the obligation.
- `pending` does **not** end it: no hardening landed. The `pending` ledger row and its `ref`
  track it from then on, so it leaves the handover's open list but is not "done".
- **Open obligations** are the `hardening owed` lines with no matching outcome line in the
  history. Both kinds of line are squash-carried, so the query works on `main` after a merge and
  in any checkout (AC-3).
- The handover (CLAUDE.md §4) lists the open ones as open obligations. It reports them; the
  commit lines are the record.

`harden-finding` itself does not change: its sources already include `gate-a` and `gate-b`, and
its rungs, `pending` and rung-0 rules are used as they stand.

### 3.5 `process-pr-review` step 5

One sentence is added: a bot finding whose defect is already named in a ledger-check line of a
cycle on this branch is not checked again and is not counted as a new occurrence; the report
names the cycle line it matched. Matching is the author's judgment against the line's
description; there is no mechanical identity across bot and gate findings. Step 5 otherwise
stays as it is.

### 3.6 History

The rule applies to cycles that start under the version that ships it. No project owes a
retroactive check. AC-3 forbids session memory as the basis, not reconstruction from durable
sources: anyone may run `harden-finding` on an earlier finding at any time, as today, and this
change adds nothing for that case.

### 3.7 Adoption

Existing projects receive the change through `/workflow-init`'s template `### 2.1a`, which
shows the difference and asks (invariant 9). The new line and the dispositions duty are contract
members, so the "one contract" stop applies to a partial adoption. A cycle already running when
a project adopts finishes under the rules it started with (the existing "which version of these
rules governs a cycle" rule).

### 3.8 Files

- `.claude/review-gates.md` and its inline copy in `plugins/dev-workflow/commands/workflow-init.md`
  `### 2.1a`, kept identical in the changed passages (invariant 8): §3.2, §3.3, §3.4.
- `plugins/dev-workflow/commands/process-pr-review.md`, step 5: §3.5.
- `docs/hardening-taxonomy.md`: the class `mandatory-step-anchored-to-optional-path` (minted by
  the change that uses it, story §1 table; `harden-finding` Flow step 2 requires the taxonomy
  entry in the same change).
- `docs/hardening-log.md`: one row for Finding A under that class, rung P.
- `scripts/check-invariants.sh` and `scripts/check-invariants.test.sh`: §5.
- `plugins/dev-workflow/CHANGELOG.md` and `plugins/dev-workflow/.claude-plugin/plugin.json`:
  dev-workflow 0.22.0 (invariant 12).
- `docs/superpowers/replays/2026-10-10-ledger-check/`: §5.
- Any doc sentence claiming step 5 is the only ledger route: found by grep for the claim, not the
  phrase, and corrected in the same change.

## 4. Lenses (story profile: risk `standard`, security `none`)

Floor 3, level 1, no security lens set. Prompt changes pass `docs/prompt-standards.md`
(invariant 11) for the two copies of the rules and the `process-pr-review` sentence.

## 5. Acceptance mapping and evidence (`battery+check`)

| Criterion | Met by |
|---|---|
| AC-3 | §3.2 (file on disk), §3.3–3.4 (lines in git, squash-carried); replay part B |
| AC-4 | §3.1, §3.3 skip case, §3.5 |
| AC-5 | §3.3: the check sits in every gate cycle, which every project runs; no PR needed |

**Check that fails without the change:** a new check in `scripts/check-invariants.sh` fails
unless both rule copies contain the dispositions duty with its closed verdict set and the two
line formats of §3.3–3.4; a reject/accept pair in `scripts/check-invariants.test.sh` shows it
fails on the 0.21.0 text. **What it proves:** the text is present in both copies. It proves
nothing about whether an agent follows it.

**Named verification of the flow (a replay; no mode change).** An automated test of agent
behaviour is not possible here, so per `.claude/review-gates.md` ("A check need not be an
automated test") a named verification covers the behavioural claim. Package
`docs/superpowers/replays/2026-10-10-ledger-check/`, in the existing replay structure
(fixture, expected, out, compare):

- **Fixture:** a small project state with a Gate-B cycle ready to close: two passes, three
  repaired finding lines that are two distinct defects (one raised by both branches), one defect
  matching a class already in the fixture ledger; dispositions files present; no session context.
- **Part A, under the new rules:** a fresh agent session is told only to close the cycle.
  Expected: `fixed 2, hardening owed 1`, the duplicate counted once, the owed line names the
  matching class.
- **Part B, interruption:** a second fresh session gets only the fixture repository after the
  close and is told to find open hardening obligations. Expected: it finds the one owed line
  from git alone.
- **Counterfactual:** the same fixture under the 0.21.0 rules. Expected: no ledger-check line
  and no owed obligation recorded. If the 0.21.0 run also produces one, the claim is false.
- **Limit:** each part is one sample. It shows the rules can be followed from durable sources;
  it does not show they always will be.

## 6. Out of scope

- PR-bot findings: step 5 stays their route (§3.5).
- Manual findings from any other source: no new route (AC-4).
- Retroactive checks of past cycles (§3.6).
- Changing `harden-finding`.
- A mechanical identity across bot and gate findings, or across checkouts beyond the carried
  description.
- Any change to closure ordering, branches, floors or the closing acts.
