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
merges), `sfx-time-tracking-dashboard` (9 closed Gate-B cycles with a repaired Major). Since
then, that project's P6c1 closing commit `fb2ba98` (branch `v2`, read 2026-10-10) records
Gate-B cycle `07hfgs3o7mye` with Findings 14,12,8,6,4,2,3,9,5 over 9 passes, 63 in all.

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

- **Input set:** the slots of the cycle's **validated** logical passes. An incomplete attempt
  is excluded, as the gate rules already require, and acquires no dispositions or ledger-check
  duty. The working record (below) lists each pass number as `valid` or `incomplete`; a pass
  whose status is unknown is reconstructed by revalidating its files, or surfaced, never silently
  dropped.
- **New duty, and when:** for every such slot with at least one finding, the author writes
  `<slot>-dispositions.md` **when the pass's findings are repaired or dismissed, before the next
  pass runs** (D1 a: "written
  during repairs"), not at close. A Gate-B `WIP:` amend replaces intermediate revisions, so a
  verdict deferred to close may have nothing left to be read from.
- **Line format:** one line per finding of that slot, `<n> | <verdict> | <reason>`, where `<n>` is
  the finding's line number in the findings file, and `<verdict>` is one of exactly `fixed`,
  `not fixed`, or `same as <slot>:<m>`. Complete means the set of `<n>` values is exactly the
  slot's finding line numbers, 1 to k, each once: a duplicate, missing or out-of-range number makes
  the file incomplete.
- **Finding identity** is `<slot>:<n>`. A findings file is not edited after its pass, so the
  pair is stable within the checkout. The slot carries the cycle's nonce, so the pair also names
  the cycle. It is a location, not a cross-checkout identity; §3.3 carries what survives.
- **Deduplication:** `same as <slot>:<m>` may point **only at a `fixed` line of a slot of the same
  cycle that reports the same occurrence**: the same defect at the same place, fixed by the same
  repair. The pair is then checked once. A defect repaired and later reintroduced is a new
  occurrence with its own verdict, and so is any case of doubt. A duplicate of a finding that was
  dismissed or declined is not a `same as` either: it carries its own verdict, since the gate
  rules let two branch lines with the same complaint get different membership answers.
- **Authority, bounded:** the file is authoritative **for the ledger check only**. Its role in
  holds, answers, resume and recovery is unchanged; the resume paragraph's "advisory and
  authoritative for nothing" is narrowed to name that one exception and nothing more.
- **Which slots owe a file:** every slot with at least one finding, so an absent file always
  means a lost file, never "nothing was repaired". A zero-finding slot owes none.
- **The working record becomes mandatory** from the cycle's first dispositions file: the
  cycle-stable `gate-a-spec-<nonce>-resume.md`, `gate-a-plan-<nonce>-resume.md` or
  `gate-b-<nonce>-resume.md` the rules already define, with their existing recovery semantics, so
  an interrupted cycle stays findable and adoptable. Where recovery still fails and a new cycle
  starts, the old cycle stays open and is a human's to resolve, as the nonce rules already say;
  that resolution includes the old cycle's ledger check over its dispositions, and until then the
  handover lists the open cycle as an open obligation. This is a limit, stated: nothing reaches an
  abandoned cycle's repairs automatically.
- **Missing or incomplete at close:** a verdict is reconstructed only where durable evidence
  shows it — the findings file plus a reviewed revision that shows the repair (the next pass's
  request text for Gate A, a commit for Gate B). Where it cannot be shown, the author asks the
  human for that finding's verdict and records the answer as its reason. Nothing is filled in
  from memory.

### 3.3 The record: one ledger-check line in the closing commit (D2 b)

At close, the author performs the check (§3.1) and writes, in the commit body that already
carries the cycle's provenance line and curve:

```
cycle <nonce>; ledger check: fixed <N>, hardening owed <M>
cycle <nonce>; hardening owed <slot>:<n> — <severity> — <class, or "new class <name>"> — <path or target> — <one-line defect description>
```

- `<N>` counts distinct repaired findings after deduplication; `<M>` how many of them owe
  hardening. One `hardening owed` line per owed finding.
- `<severity>` is the reader-normalized severity from the findings file (`blocker`, `major`,
  `minor`, `nit`), and the `harden-finding` source is `gate-a` or `gate-b`, read from the slot.
  `<path or target>` is the repository-relative file, or the named section or operation, the
  defect sat in. No field may contain the separator ` — ` or a line break: a description is
  reworded, and a path that contains either is written in double quotes (a path with a line
  break cannot be represented, and the author stops and surfaces it). Filled:
  `cycle k3v9q2mx7d; hardening owed gate-b-quality-k3v9q2mx7d-pass-2:4 — major — docs-drift — README.md — install section still names the removed --global flag`.
  With the description, that is the whole intake `harden-finding` Flow step 1 asks for, so a later
  session can start hardening from the line alone. The findings file may be untracked or absent
  in a later checkout.
- **An undetermined check blocks the closing act.** Where a findings file cannot be read, an
  owed dispositions file stays incomplete after §3.2's reconstruction and question,
  `docs/hardening-log.md` or `docs/hardening-taxonomy.md` is missing or unreadable, or the
  recurrence grep cannot run, the author stops and surfaces which one. A grep that runs and
  matches nothing is a successful check: no prior row, `harden-finding` Flow step 3's "new". The line is
  never written with a guessed or zero count; `fixed 0` means established, never unknown. A
  missing ledger in an initialized project is a setup gap (`/workflow-init`).
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
line per owed finding it handles, in the commit that completes it: the closing message of its
Gate-A or Gate-B cycle, or the commit of a change that owes no gate (a rung-0 record, say). An
outcome line counts only in a non-`WIP:` commit; one written into a `WIP:` snapshot is
provisional and ignored, and the closing amend carries it into the final message:

```
cycle <nonce>; hardening <slot>:<n>: rung <1|2|3|4|P>
cycle <nonce>; hardening <slot>:<n>: pending <ref>
cycle <nonce>; hardening <slot>:<n>: rung 0 — <the mandatory check that already catches it>
```

- **Key:** the leading cycle field and `<slot>:<n>` name the **original** cycle that owed the
  hardening, not the cycle of the hardening change. The line is that original cycle's record,
  transported in a later commit; the hardening change's own cycle writes its own provenance line
  and curve as usual.
- An obligation is **closed** once any outcome line for its key reads `rung 1–4|P` (a ledger row
  exists) or `rung 0` (no row, by `harden-finding`'s own rule). No ordering between outcome lines
  is needed: a `pending` line never closes an obligation and never reopens a closed one.
- `pending` alone does **not** close it: no hardening landed. The obligation stays open, blocked
  by the `pending` row's `ref`.
- **Open obligations** are the `hardening owed` lines with no closing outcome line. Both kinds of
  line are squash-carried, so after a merge the query reads `main`.
- **What the query covers:** the history of the refs it scans, which are the current branch and
  `main`. Obligations recorded only on another unmerged branch are outside it, and that is a
  stated limit, not a detected state. A shallow clone is detected (`git rev-parse
  --is-shallow-repository`) and the result is then reported as incomplete, never as "none open".
- The handover (CLAUDE.md §4) lists every open obligation, blocked ones included with their
  `ref`. It reports them; the commit lines are the record.

`harden-finding` itself does not change: its sources already include `gate-a` and `gate-b`, and
its rungs, `pending` and rung-0 rules are used as they stand.

### 3.5 `process-pr-review` step 5

One sentence is added: a bot finding that reports **the same occurrence** as a `hardening owed`
line written by a cycle **inside this pull request's own range** (merge-base to head) is not
checked again and is not counted as a new occurrence; the report names the line it matched.
Same occurrence means the same defect at the same place, still unrepaired or repaired by that
cycle; a defect reintroduced after the repair, or any doubt, takes the ordinary step-5 route.
Matching is the author's judgment against the line's description; there is no mechanical
identity across bot and gate findings.

Only owed lines are matched. A bot finding duplicating a gate finding that owed nothing is
checked again by step 5; that costs one repeated check and nothing else, because a finding with
no class has no ledger row a second check could miscount. Step 5 otherwise stays as it is.

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
| AC-3 | §3.2 (written at repair time, on disk), §3.3–3.4 (lines in git, squash-carried, reachable history); replay parts A and B |
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
  repaired finding lines that are two distinct defects (one raised by both branches); dispositions
  files present, as written at repair time; no session context. Defect X matches a class already
  in the fixture ledger. Defect Y is pinned as owing nothing: a one-off wording slip that matches
  no class, and the fixture's README states why no new class is warranted.
- **Part A, interruption before close:** a fresh agent session, with nothing from the session
  that made the repairs, is told only to close the cycle. Expected: `fixed 2, hardening owed 1`,
  the duplicate counted once, the owed line names X's class and severity.
- **Part B, fresh checkout after a squash:** a second fresh session gets a prepared fixture
  repository **without `.context/codex-reviews/`**, whose `main` holds one squash commit carrying
  three owed lines and their outcomes: one closed by `rung 2`, one with only `pending <ref>`, one
  with no outcome. It is told to find open hardening obligations and state the `harden-finding`
  intake for each. Expected: two open, the pending one marked blocked with its `ref`; each intake
  with finding text, place, source and severity, from git alone, no question back.
- **Counterfactual:** the same fixture under the 0.21.0 rules. Expected: no ledger-check line
  and no owed obligation recorded. If the 0.21.0 run also produces one, the claim is false.
- **Limit:** each part is one sample. It shows the rules can be followed from durable sources;
  it does not show they always will be. Not exercised: a Gate-A cycle, the recovery of an
  interrupted cycle through its working record, and the writing of outcome lines through a `WIP:`
  amend (part B starts from a prepared squash).

## 6. Out of scope

- PR-bot findings: step 5 stays their route (§3.5).
- Manual findings from any other source: no new route (AC-4).
- Retroactive checks of past cycles (§3.6).
- Changing `harden-finding`.
- A mechanical identity across bot and gate findings, or across checkouts beyond the carried
  description.
- Any change to closure ordering, branches, floors or the closing acts.
