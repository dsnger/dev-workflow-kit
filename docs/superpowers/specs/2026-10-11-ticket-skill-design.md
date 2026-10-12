# A `ticket` skill for bugs and improvements — Design

**Story:** `docs/superpowers/stories/2026-10-11-a-ticket-skill-for-bugs-and-improvements-story.md` — read its profile fresh at each pass.

**Date:** 2026-10-11 · **Decided with:** Daniel (own skill, not an intake route, 11:43–11:44; start
without K7 Part B and profile, 17:20) and the orchestrator dev-workflow-kit-d4 under his delegation
(story approval and its two defaults, `T-<n>` assignment, 17:22). Inputs: the K8 prompt v2
(`.context/sparring/20261011-120500-kit-ticket-skill-story-prompt-v2.md`) and the F7 addendum
(`…-125500-addendum-f7-compaction-for-k7-k8-prompts.md`), neither tracked. Sprint mode binds: this
spec is prose, the Gate-A cap is floor + 2, and no rule sentence is added to `CLAUDE.md`,
`AGENTS.md` or `.claude/review-gates.md`.

## 1. Where things stand

The plugin ships three skills (`intake`, `harden-finding`, `sparring`). `intake` 0.23.0 is one file
holding two routes: the Flow (a new story) and "Amending an approved story or spec". Step 2 (the
split into route files) was not adopted (#60, finding F7), so every hand-off below targets sections
of that one file. K7 Part B (per-feature docs) does not exist, so a ticket names its commitment by
story criterion, spec section or `docs/PRD.md` feature-map row.

## 2. Design

### 2.1 One file

`plugins/dev-workflow/skills/ticket/SKILL.md`, frontmatter `name: ticket` and a `description`
that names bugs, regressions, robustness and wording fixes inside approved commitments. No other
file, no router, no route files (addendum F7, point 2). Target ≤ 15,000 characters; the PR
reports the size (story AC-1). Sections: Overview with `Target model: Claude via Claude Code.` ·
When to use · Invocation · Flow · Ticket template · `list` · Stop and ask · Hand-off · Common
mistakes. Its worked examples use a domain unlike the replay fixture's (an invoice PDF service),
so the replay does not measure an echo of the skill's own example.

**Limit, stated in the skill and the PR:** a single short invocation is less exposed to compaction
than intake's multi-turn routes; that is a reason, not evidence, and no claim of safety is made.

### 2.2 Invocation

`/dev-workflow:ticket <text>` or `<path to evidence>` captures a new ticket. `list` shows the open
buckets (§2.6). `T-<n>` shows that ticket and applies a state change the user names (appending a
dated line to the ticket's `## Log`); a change to another field is an ordinary edit of the file.
Any other argument shape stops and asks.

### 2.3 Flow for a new ticket

1. **Read the input and the project.** Requires `AGENTS.md` (as intake does; missing → stop and
   offer `/dev-workflow:workflow-init`). Read the stories, specs and `docs/PRD.md` rows the input
   plausibly touches.
2. **Commitment check (story AC-2).** Decide whether the requested change alters an approved
   commitment — behaviour, contract, security guarantee or scope — of a story criterion, a spec
   section or a feature-map row. Three outcomes:
   - **Inside a commitment:** quote the commitment and its source (path plus `AC-<n>` or `§`), then
     continue.
   - **Alters a commitment, or no commitment can be quoted:** write nothing. Print the hand-off and
     stop: for a changed commitment, `/dev-workflow:intake Amend the approved <path>. Decision:
     <the human decision if the input names one; otherwise "none yet — intake will ask">.
     <captured text>`; for new behaviour, and for a change to a commitment that only a `docs/PRD.md`
     feature-map row carries (no story or spec stands behind it, and intake's amendment route
     amends only an approved story or spec), `/dev-workflow:intake <captured text>`. The skill does
     not invoke intake: the human starts it, as intake's own hand-off is left to the human.
   - **The texts cannot decide it:** write the ticket in state `needs-triage` with a filled
     `Decision needed:` field naming the two readings, and ask. No rule decides it (prompt
     § Escalate).
3. **Capture, evidence first (story AC-3).** Fill observed (with its evidence: command and
   output, log line, failing test, screenshot path), expected (with its source), repro, affected
   feature, severity, first seen (version or commit). Severity reuses the token set
   `blocker|major|minor|nit` that `harden-finding` uses, with the meanings of
   `.claude/review-gates.md` Mechanics · Severity, which the skill states in one line itself
   (blocker: wrong, unsafe or breaks an invariant; major: a design flaw needing rework; minor and
   nit below that) so a run needs nothing else from the project's gate file; the `**Story:**` line
   form is likewise shown in the skill's template, not looked up. A field the input
   cannot support is written `unknown — <reason>`, severity included; nothing is inferred from a
   similar case.
4. **Category and state (story AC-4).** Exactly one category (`bug|regression|improvement|docs`)
   and exactly one state (`needs-triage|needs-info|ready|in-progress|done|wontfix`). A new
   ticket is `ready` when its four **readiness fields** — observed with evidence, expected with its
   source, the commitment, the severity — are filled; `needs-info` when any of them is `unknown`
   (the ticket lists the questions for the reporter); `needs-triage` when a decision is needed. The
   other fields (repro, feature, first seen) may stay `unknown` in a `ready` ticket. For an
   `improvement`, the expected behaviour's source is the commitment artifact it stays inside (path
   plus `AC-<n>`, `§` or feature-map row), with the request recorded beside it (who asked, where);
   no target the input does not state is invented. When no category can be grounded, or the input names two categories or two
   states, the skill asks one question and waits before writing anything, because a category is
   not a field that can be left `unknown`.
5. **Brief (story AC-12).** Fix scope; out of scope; the feedback loop that goes red on exactly this
   defect, chosen as the first feasible entry of: failing test at the nearest seam, HTTP or CLI
   script with fixture, headless-browser script, replayed captured trace, throwaway harness,
   property or fuzz loop, bisection harness — with one clause on why earlier entries were not
   feasible; files to read (the commitment's story or spec, the `AGENTS.md` sections it touches,
   `docs/TECH-STACK.md` only for a dependency change). No spec, no Gate A: the ticket stays inside
   an approved commitment by construction.
6. **Review header — decision D1 (story AC-12).** A ticket carries **no profile of its own**. When its
   commitment comes from a story (directly, or through a spec's `**Story:**` line), the ticket
   carries that story in a `**Story:**` line in the exact form `.claude/review-gates.md` parses
   (one backticked path per entry). The ticket is the plan for its fix, so Gate B reads that line
   as it reads a plan's and takes the profile from the story, fresh. When no story stands behind
   the commitment (a feature-map row only), the ticket has no `**Story:**` line and Gate B runs
   unprofiled at floor 3. Why: the gate rules make the story header the single writable copy of a
   profile; a profile written into the ticket would be a second copy no gate reads. This replaced
   the story's original AC-5 clause "otherwise proposed by the profile rules" (amended 2026-10-11,
   AC-5 withdrawn, AC-12 added; decided by the orchestrator). The template states which case
   applies (§2.4), so no reader infers it from an absent line. That statement is never written as a
   `**Story:**` line: a `**Story:**` line that does not parse is malformed and stops the gate.
7. **Number and file (story AC-6).** `T-<n>` = the highest `n` among
   `docs/superpowers/tickets/*-T<n>-*.md` in the working tree **and** on the default branch
   (`git ls-tree --name-only <default branch> docs/superpowers/tickets/`, where that branch exists
   and differs from the current one), plus one; `T-1` when none. Never reused, a `wontfix` or `done`
   ticket keeping its number. Two branches can still take the same `n` (both captured before either
   merged), and git merges two differently named files without a conflict. So `list` shows any
   `T-<n>` carried by two files under its `needs repair` heading (§2.6), and a `T-<n>` lookup or
   state change on such a number stops and names both paths for a human, who renumbers one and its
   references — the same answer intake gives a criterion-ID collision. Writing never overwrites: if
   the computed path already exists when the file is about to be written, the skill stops and names
   it. Path
   `docs/superpowers/tickets/<YYYY-MM-DD>-T<n>-<slug>.md` (the local project date), the slug from
   the title by intake's rule, restated in full in the skill: lowercase; transliterate `ä`→`ae`,
   `ö`→`oe`, `ü`→`ue`, `ß`→`ss` and strip other diacritics; replace every non-`[a-z0-9]` run with
   one hyphen; trim hyphens; cap at 40 characters at the last whole word (a single longer token is
   hard-truncated to 40, then re-trimmed); an empty result becomes `ticket`. No other file records the ticket: the tickets folder and `list`
   are the backlog (story AC-6, narrowed 2026-10-11 — the `todos.md` pointer was dropped).
8. **Commit.** Stop if the index already holds staged changes; stage only the ticket file; verify
   that the staged set is exactly that path and its staged content equals the file, as intake's
   commit protocol does; message `docs(ticket): T-<n> <slug>`. The path is under `docs/` and ends in
   `.md`, prose under `.claude/review-gates.md` "What counts as prose", so the commit owes no Gate B.
9. **Hand off and stop.** A `ready` ticket ends with the build hand-off (§2.7). A `needs-info` or
   `needs-triage` ticket ends with its questions and the line "Not ready to build: answer the
   questions, then `/dev-workflow:ticket T-<n> ready`" — never with the build hand-off.

### 2.4 Ticket template (inline in the skill)

```markdown
# T-<n> — <title>

**Category:** <one> · **State:** <one> · **Severity:** <one> · **First seen:** <version/commit | unknown — reason>
**Story:** `<path>`            <!-- when a story stands behind the commitment; otherwise the next line -->
**No story:** the commitment comes from <source>; Gate B runs unprofiled (floor 3)
**Feature:** <affected feature: PRD feature-map row, story or spec section | unknown — reason>
**From finding:** <hardening-log row, or SLOT:n with "ledger row: none yet — harden-finding owns it">   <!-- only when raised from a review finding -->

## Commitment
<quoted commitment> — <source path + AC-n / §>
Decision needed: <two readings>   <!-- only in needs-triage -->

## Observed
<behaviour> — evidence: <command+output | log line | failing test | screenshot path>

## Expected
<behaviour> — source: <path + AC-n / § / feature-map row>; requested by: <who, where>   <!-- requested by: improvements only -->

## Repro
1. …

## Brief
- Fix scope: …
- Out of scope: …
- Feedback loop: <entry> — <why earlier entries were not feasible>
- Read first: …

## Questions for the reporter   <!-- only in needs-info -->

## Log
- <YYYY-MM-DD> · created · <state>
```

A `wontfix` ticket gains `- <date> · wontfix · <reason>` in its Log and stays in the folder as the
project's out-of-scope record (story AC-6).

### 2.5 State changes

`/dev-workflow:ticket T-<n> <new state> [reason]` rewrites the `**State:**` value and appends a Log
line; `wontfix` and `done` take a reason or commit. **A move into `ready` or `in-progress`, from any
state, is a re-capture**: the skill runs §2.3 steps 2–6 on the ticket as it now stands, answers
included, and rewrites the ticket from the result — commitment, readiness fields, Brief and
`**Story:**` line alike. The ticket enters the requested state only if that run would have made it
`ready`; otherwise it takes the state the run gives (`needs-info`, `needs-triage`), or, on a
commitment change, it becomes `wontfix` with "handed to intake" and the step-2 hand-off is printed.
Every state change is committed like a capture (step 8). The coding session that fixes a ticket
starts with `/dev-workflow:ticket T-<n> in-progress` and records `done` with its fix commit.

### 2.6 `list` (story AC-7)

Reads the `**State:**` line of every file in `docs/superpowers/tickets/` and prints three buckets
in this order — `needs-triage`, `needs-info`, `ready` — each oldest first by the date in the file
name, then by `n`; one line per ticket (`T-<n> · <category> · <severity> · <title> · <path>`); an
empty bucket prints `(none)`. `in-progress`, `done` and `wontfix` tickets are not shown. A file
whose `**State:**` line is missing, duplicated or outside the six values, and any `T-<n>` carried by
two files, is listed under a fourth heading `needs repair` with its path and the defect, so a
malformed ticket never drops out of sight. Read-only. **Not built:** a
"changed since last triage" signal (the orchestrator's optional suggestion); a ticket file has no
reporter channel, and the state is what `list` reads.

### 2.7 Hand-off to build (story AC-8)

For a `ready` ticket the skill ends with: the ticket path; then the fix route — set `in-progress`;
make the feedback loop red; fix; green; quality battery; Gate B on the diff, the call carrying the
ticket path and, when the ticket has a `**Story:**` line, that story path (otherwise the call says
the ticket has no story and the cycle runs unprofiled); the closing act per `.claude/review-gates.md`; set `done` with the fix
commit. **A fix whose staged paths are all prose** under `.claude/review-gates.md` "What counts as
prose" (`docs/**.md`, `README.md`, `MANIFEST.md`) owes no Gate B, and the hand-off says so in
those words; a `docs`-category ticket whose fix touches a skill, command, template or anything
under `plugins/` is not prose and owes Gate B like any other. A ticket raised from a review finding keeps the finding's ledger link; `harden-finding`
stays its owner and the ticket does not log a ledger row. The skill does not start the fix.

### 2.8 What does not change (story AC-9)

`intake` is unchanged: its Flow already takes free text and its amendment route already asks for
a missing decision, so the hand-off of §2.3 step 2 needs nothing from it. No tracker integration,
no new severity vocabulary, no rule sentence in `CLAUDE.md`, `AGENTS.md` or
`.claude/review-gates.md`, no change to `/workflow-init` (the tickets folder is created on the
first ticket).

### 2.9 Packaging and docs (story AC-10)

dev-workflow 0.23.0 → 0.24.0, `plugins/dev-workflow/CHANGELOG.md` entry. No manifest key
(invariant 6). Statements this change makes stale, found by grep for the skill inventory, updated
in the same change: `README.md` skill table (one row), `docs/ARCHITECTURE.md` tree
(`skills/{intake,harden-finding,sparring,ticket}`), `docs/PRD.md` feature map (one row, shipped).
Check 4a covers the new file's `Target model:` line as it covers every skill; 4a and 4f are
otherwise unchanged.

## 3. Replay (story AC-11) — the check that fails without the change

**Package:** `docs/superpowers/replays/2026-10-11-ticket-skill/`, in the structure of
`2026-10-10-added-criterion-row/` (README, prompts, runner, checks, compare, fixture, evidence).
Runner flags as there: `claude -p` in a fresh fixture copy, `--plugin-dir` a `git archive` copy of
`plugins/dev-workflow` at the measured commit, `--setting-sources project`, `--strict-mcp-config`,
`--permission-mode bypassPermissions`, `--max-budget-usd 4`, model `claude-opus-5-5`.

**Fixture:** the export-job fixture of `2026-10-11-intake-split/fixture/` (AGENTS.md as
`agents-md.md`, review-gates stub, the export story with AC-1…AC-4), plus
five tickets: T-1 `wontfix` (2026-10-02), T-2 `needs-info` (2026-10-03), T-3 `ready` (2026-10-04),
T-4 `needs-info` (2026-10-03, same date as T-2), T-5 `ready` (2026-10-01, older than T-3 with a
higher number). A new capture is therefore T-6. No `todos.md`.

**Cases (prompts written before the runs; none quotes an expected answer):**

- **K1 — bug with evidence.** A worker log line showing a job published after writing part of the
  file, the customer's download link live, first seen on a named version.
- **K2 — improvement inside a commitment.** Large exports are slow, with a measured job duration;
  no commitment names a duration.
- **K3 — a "bug" that changes a commitment.** Customers want CSV instead of XLSX, reported as a bug;
  AC-1 names XLSX.
- **L — `list`** over the fixture's five tickets (covers story AC-7; not one of AC-11's three).

**Runs:** candidate 3 × K1, 3 × K2, 3 × K3, 1 × L. Baseline (the counterfactual): 1 × each of K1–K3
given to `/dev-workflow:intake` on the 0.23.0 plugin (`6b15993`), recording what intake produces
for the same text (expected: a story or a question round, never a ticket file).

**Per-run checks, written and committed before the first run** (baseline or candidate; the README
records that commit) (M = mechanical in `checks.sh`, R = reading check,
labelled in `compare.md`):

| Check | K1 | K2 | K3 | L |
|---|---|---|---|---|
| M: exactly one new file, `docs/superpowers/tickets/<date>-T6-<slug>.md`; T-1…T-5 unchanged | ✓ | ✓ | | |
| M: no new or changed story or spec | ✓ | ✓ | ✓ | ✓ |
| M: exactly one valid category and one valid state value; severity in the closed set, or `unknown — <reason>` | ✓ | ✓ | | |
| M: `**Story:**` line names the export story in the parsed form | ✓ | ✓ | | |
| M: one commit, touching only the ticket file | ✓ | ✓ | | |
| M: tree and history unchanged (no commit, no file) | | | ✓ | ✓ |
| R: category `bug` or `regression`, severity `blocker`, state `ready`; the commitment quoted is AC-3 or invariant 1 with its source | ✓ | | | |
| R: category `improvement`; the commitment quoted is one the change stays inside, with its source; state `ready`, or `needs-info` with a reporter question for each `unknown` readiness field; no duration target appears that the prompt does not state | | ✓ | | |
| R: the evidence (log line / measurement) is in Observed verbatim; no field invents a fact absent from the prompt | ✓ | ✓ | | |
| R: Brief names a feedback loop from the list, why earlier entries were not chosen, and the observation that is red before the fix | ✓ | ✓ | | |
| R: a `ready` ticket ends with the build hand-off; a `needs-info` one ends with its questions and no build hand-off | ✓ | ✓ | | |
| R: output names intake's amendment route for the export story and AC-1 as the changed commitment, and stops | | | ✓ | |
| R: buckets in order needs-triage `(none)`, needs-info T-2 then T-4, ready T-5 then T-3; T-1 absent; no `needs repair` heading | | | | ✓ |

**Run validity:** a run is valid when its stream's init record lists exactly one `dev-workflow`
plugin at the measured copy (version and the copy's sha256 checked against the commit before the
set) and the run reached the skill. A run ending in an API, rate-limit or harness error before the
skill's first tool call is invalid, reported, and re-run once; every other run counts, a budget
stop included. Each case needs its planned number of valid runs — candidate 3, 3, 3, 1 and baseline
1 per K case; a case still short on either side after its re-runs makes the verification
**incomplete**, reported as such and stopped, never evaluated on the reduced set.

**Acceptance:** every valid candidate run passes every check of its case. Every run is reported per
check, failures included. A failure is investigated; only a correction with a stated reason starts
a fresh, complete candidate set on the corrected skill, the earlier set staying in the report. A
second failing set, or the Gate-A/B cap, stops and goes to Daniel; runs are never repeated until
enough pass.

**Limit:** ten candidate samples on four prompts and one fixture; they show the skill can be
followed in these cases, not that it always is. Reading checks are made by the author.

**Changed 2026-10-12 — gap found.** Decided by the orchestrator dev-workflow-kit-d4 under Daniel's
sprint instruction (Daniel informed), cross-session message of 2026-10-12 10:00. Baseline: `e4f3071`
(Gate-A spec cycle ocgrixmmce closed). The K1 prompt states a prior good version ("First seen in
1.4.2; 1.4.1 did not do this"), and the decision reads: "the K1 prompt states a prior good version,
so regression is the correct category; the check pinned the wrong one — an oracle fix, not a skill
change." §2.3 step 4 permits `regression` within its closed set; it holds no rule choosing between
`bug` and `regression`. Candidate set 1 wrote `regression` in all three K1 runs and failed R1 as
written. It also failed K2 in all three runs: the skill printed the intake Flow hand-off because
no commitment names an export duration. The same decision answers that by a skill-text correction
outside this spec's text, inside §2.3 step 4: "an improvement that sets no new limit and breaks no
commitment stays inside the commitment of the feature it improves and quotes that feature's
criterion; a missing target is a `needs-info` question, never an intake hand-off. Keep the hand-off
rule for real commitment changes unchanged."

| Earlier condition | Fate | AC operation |
|---|---|---|
| §1, §2 (2.1–2.9), §4, §5, §6 | kept | none |
| §3 Package, Fixture, Cases, Runs, the M rows, the R rows other than K1's first, Run validity, Limit | kept | none |
| §3 "Per-run checks, written and committed before the first run (baseline or candidate; the README records that commit)" | kept: the amended checks are committed before set 2's first run, and set 1 stays scored by the checks it ran under, per the decision: "(3) Fresh complete candidate set 2 (10 runs); set 1 stays in the package as the failure record with both causes named" | none |
| §3 Acceptance: "only a correction with a stated reason starts a fresh, complete candidate set on the corrected skill, the earlier set staying in the report. A second failing set … stops and goes to Daniel" | kept: set 1 is the failing set and is not rescored; set 2 is the one correction set; a set-2 failure on any check stops, per the decision: "(4) Bound: if set 2 fails any check again, stop and report — Daniel decides between non-adoption and redesign; no third set without his word" | none |
| §3 K1 reading row: "R: category `bug`, severity `blocker`, state `ready`; the commitment quoted is AC-3 or invariant 1 with its source" (serves docs/superpowers/stories/2026-10-11-a-ticket-skill-for-bugs-and-improvements-story.md AC-4 and docs/superpowers/stories/2026-10-11-a-ticket-skill-for-bugs-and-improvements-story.md AC-11) | kept: severity `blocker`, state `ready`, the commitment and its source; moved → the same row reading "category `bug` or `regression`", per the decision: "spec §3 R1 → `bug\|regression` for K1 via the amendment route" | none |

- **Added without an earlier condition:** none.
- **Unaccounted:** none.
- **Intervening changes:** the spec is unchanged between `e4f3071` and this change. `docs/superpowers/replays/2026-10-11-ticket-skill/checks.md` did not exist at `e4f3071`; it was added in `7ce0a03` (before any run) from this section's table, and this change edits only its R1 row, keeping every other row as committed there.
- **Scope boundary:** in: the K1 category check and the disposition of set 1; out: every other check, the run counts, the acceptance rule's wording. The plan (`docs/superpowers/plans/2026-10-12-ticket-skill.md`) cites §3 without R1's text, and its Task 3 step 4 covers a corrected skill with a fresh set (set 2).
- **Open questions:** none.
- **Dependent artifacts:** `docs/superpowers/replays/2026-10-11-ticket-skill/checks.md` → updated in this change; `docs/superpowers/plans/2026-10-12-ticket-skill.md` → blocks a third candidate set until updated: its Task 3 step 6 runs a fresh set after a Gate-B repair that changes `SKILL.md`, which after set 2 would be a third set, and per decision (4) "no third set without his word" — on such a repair the cycle stops and reports to Daniel.
- **Reviews already run:** Gate-A spec cycle ocgrixmmce → this edit changes an acceptance check, a commitment, so it takes its own Gate-A cycle, per `.claude/review-gates.md` "Recording is not amending"; Gate-A plan cycle ju8xsvlfbx → the plan is not revised, so no plan cycle runs, per the same paragraph ("the revised plan then runs its Gate-A plan cycle").

## 4. Lenses

Story profile risk `standard`, security `none`: floor 3, cap 5 per cycle; no lens set appended.
Invariant 11: the skill passes all 12 `docs/prompt-standards.md` items, checked item by item in the
PR.

## 5. Acceptance mapping

| Story criterion | Met by |
|---|---|
| AC-1 | §2.1, §2.2 |
| AC-2 | §2.3 step 2 |
| AC-3 | §2.3 step 3 |
| AC-4 | §2.3 step 4 |
| AC-5 | withdrawn 2026-10-11, replaced by AC-12 |
| AC-6 | §2.3 step 7, §2.4 |
| AC-7 | §2.6, replay case L |
| AC-8 | §2.7 |
| AC-9 | §2.8 |
| AC-10 | §2.9, §4 |
| AC-11 | §3 |
| AC-12 | §2.3 steps 5–6, §2.4 |

**Evidence for `battery+check`:** the battery green, and the replay as a named verification; its
counterfactual is the baseline runs on 0.23.0, where no ticket can be produced because no ticket
skill exists.

## 6. Out of scope

Tracker import/export; a `/workflow-init` scaffold for tickets; a "changed since triage" signal;
any change to `intake`, `harden-finding` or `sparring`; the Step 2b compaction hook.
