# Hardening-ledger supersession convention — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task, sequentially. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a supersession convention to `docs/hardening-log.md`'s header and to
`/workflow-init`'s inline ledger template, and use it once — to mark the 2026-07-20
`truncated-tool-output-read-as-complete` row, whose narration 0.8.0 falsified.

**Architecture:** Two convention blocks — spec §2.1's single paragraph, and §2.2's intro paragraph,
four-space indented format example, and closing paragraph — byte-identical across both surfaces
modulo hard-wrap position, appended after the ledger header's existing first paragraph. Corrections are appended
`Superseded rows` entries that mark rows; no row is ever edited. No standing tool reads the block.

**Tech Stack:** Markdown; POSIX `sh` (checks must also pass under `dash`); `git`; `shellcheck`;
the `claude` CLI for `plugin validate`.

**Spec:** `docs/superpowers/specs/2026-08-05-hardening-ledger-supersession-design.md`
**Story:** `docs/superpowers/stories/2026-08-04-hardening-ledger-supersession-story.md`
— read the profile fresh from that header at every gate; no value from it is copied here.

**This plan carries labels, properties and oracles. It does not carry the executable form.**
Each check has a stable label, the property it must establish, its falsifying observation, and the
distinctions a correct implementation must make. The shell is written at execution time by the
executor. **Gate B reviews the implementation diff — the two surfaces, the manifest, the changelog,
`todos.md` — and does *not* review the checks:** the harness and fixtures are scratch, never
committed, and so never enter a reviewable git range. Their only guards are the self-test of Task 2,
`shellcheck`, and the per-label counter-checks below — plus the reviewer reading the check source,
which Task 8 requires in `additionalContext`. That is a reviewer reading a paste, not a gate
comparing a diff; spec §8 records the residual and §6 states the same division.

**No counter-check may mutate a row or a complete entry in the real ledger.** §2.1 protects a row
the moment it exists, committed or not, and §2.2 protects a complete entry the same way — so a
mutate-then-restore against `docs/hardening-log.md` executes exactly the operation this change
exists to forbid, in the file it is being added to. Every such mutation runs against a **scratch
copy** of the ledger with the check pointed at the copy. Mutations to *prose* — a header paragraph,
an anchored clause of the convention — are not covered by either rule and may be done in place.

**Where this plan and spec §6 disagree, §6 governs — except on the four items spec §8 records as
held-not-fixed**, where the remedies below supplement or correct §6 and are authoritative. Those
four exist *because* §6 is wrong or incomplete there; a precedence rule without this carve-out would
instruct the executor to discard them.

## Global Constraints

- **Invariant 12 — a plugin change requires a version bump.** `plugins/dev-workflow/.claude-plugin/plugin.json` moves `0.8.1` → `0.8.2`, with a `plugins/dev-workflow/CHANGELOG.md` entry. `plugins/dev-workflow/commands/workflow-init.md` is under `plugins/`, so the rule binds.
- **Invariant 11 — prompt changes pass `docs/prompt-standards.md`, all twelve items**, on `plugins/dev-workflow/commands/workflow-init.md`. It is the only invariant-11 surface this change touches.
- **Invariant 9 — `/workflow-init` never overwrites silently.** Spec §4's verdict: **nothing is needed**. An existing scaffolded project re-running `/workflow-init` meets the changed header as "present and different", which already routes to show-the-diff-and-ask. The constraint is that the executor must not *break* that path — the template edit stays inside the existing fenced block and adds no write behaviour. Task 8 records the verdict as part of the prompt-conformance read.
- **Invariant 8 — `/workflow-init`'s templates stay inline.** The template edit happens inside the command body; never read a template from disk.
- **Invariant 5 — every version pinned exactly.** This change adds no dependency; do not introduce one.
- **`harden-finding` is out of scope.** §2.1 narrows nothing, so that skill's `never edit an existing row` sentence stays true. Do not edit it.
- **No `Co-Authored-By: Claude` or `Generated with` trailers** on any commit.
- **The entry's date is `$D`, the day the ledger change is made**, in `YYYY-MM-DD`. Only the *entry's* date is `$D`; the superseded row's date is `2026-07-20`, fixed, being a property of the row. The spec's §3.1 shows a different date and is not a literal to copy.
- **Every check reads an explicit base ref and never defaults it to `HEAD`.** `BASE` is captured in Task 1. Once the change is committed, an edited row would otherwise become its own baseline and the check would pass on the mutation it exists to catch.
- **Assert exit status, never printed output**, and treat any stderr shell error as failure. This governs every property and every fixture outcome. It does **not** govern the harness self-test of Task 2, whose whole job is to prove the harness can report a failure at all — that one asserts on its diagnostic output by necessity, and is the single carve-out.
- **Where §5 or §8's "prose-only / nothing consumes" wording disagrees with §2.2's "Format" paragraph, §2.2 governs.** The accurate claim is *no standing machine consumer*; the entry syntax **is** a standing authoring convention every future author honours. *(Closes spec §8 held-not-fixed item 2.)*
- **No standing check is added.** The harness is scratch and is never committed; `todos.md` parks the follow-up for wiring one. This is a statement about *checks* and does not touch the authoring convention above.
- **Mirror edits land in the same commit.** The two surfaces are byte-identical in the shared region; an edit to one that does not reach the other is the defect `C2a` exists to catch, and splitting them across commits makes the intermediate commit wrong on purpose.
- **Never `git add -A`, `git add .`, or any pathspec broader than the files a step names.** The working tree carries `docs/research/`, untracked and not ours, and the executor will create fixtures; either can be swept into a commit or an amend, which changes the Gate-B range and can publish an unrelated tree. **Before every commit and every amend, assert the staged set equals the intended paths** — `git diff --cached --name-only` compared against the step's file list, exit non-zero on any extra. Use deletion-aware explicit pathspecs so a removed fixture cannot force a broad add.
- **The harness lives outside the repository working tree** — the session scratchpad, not a directory under the repo. Nothing untracked that the executor creates should ever be inside a path `git status` reports.

---

## File Structure

| File | Responsibility | Action |
|---|---|---|
| `docs/hardening-log.md` | this repo's ledger — the convention prose **and** the `Superseded rows:` block holding the one entry | Modify |
| `plugins/dev-workflow/commands/workflow-init.md` | the inline empty-ledger template at §2.2 of the command body — the same prose, **no block** | Modify |
| `plugins/dev-workflow/.claude-plugin/plugin.json` | `version` `0.8.1` → `0.8.2` | Modify |
| `plugins/dev-workflow/CHANGELOG.md` | one entry for `0.8.2`, newest first | Modify |
| `todos.md` | source row closed and rewritten in past tense; **two** new parked rows | Modify |
| `docs/superpowers/plans/2026-08-12-hardening-ledger-supersession.md` | this plan — untracked until Task 1 commits it | Add |
| scratch `checks/` | the one-time validation harness — fixtures, checks, runner. **Never committed** | Create |

**Outside this execution's scope**, though spec §4's change surface names them — they already carry
the required content, and no task touches them: `docs/coding-workflow.md`'s append-only sentence,
the historical-snapshot note on
`docs/superpowers/plans/2026-08-04-hardening-round-0-8-0-and-pr-21.md`, and the guard-scope story's
inherited open question covering phantom-hardening rows. Verify each reads as expected before
concluding the change surface is met; do not rewrite them.

---

## The checks — labels, properties, oracles

Eight labels. `C1a`–`C1d` and `C1f` are spec check 1, `C2a`–`C2b` check 2, `C3` check 3.
**Spec check 1e is not implemented** — it validates the ledger's pre-existing chronology, passes
before and after, and its falsifying observation requires a mutation of the table that this diff
cannot produce. (An unreadable ledger would fail it too; that is not evidence about the change
either.) Recorded in spec §8.

| Label | Property | Falsifying observation |
|---|---|---|
| `C1a` | The `Superseded rows` block carries an entry dated `$D` superseding `2026-07-20` with fingerprint `truncated-tool-output-read-as-complete`, and the table carries that row as a **complete** row | **fails on the clean pre-change tree** — the entry is absent |
| `C1b` | The superseded row's whole line is identical to the same line at `BASE` | passes pre-change; **fails only under mutation** — change one character of that row |
| `C1c` | The pre-existing first header paragraph is untouched in **both** surfaces, each against its own base | passes pre-change; **fails only under mutation** — change one word in either surface |
| `C1d` | The mandated entry is not inert — its locator matches at least one row dated on or before its own date | **fails on the clean pre-change tree** — there is no entry to match anything |
| `C1f` | A named read of the entry's content — four confirmations | not mechanical; nothing establishes that the prose says anything useful |
| `C2a` | Each of the thirty-five anchors occurs **exactly once** in each surface | **fails on the clean pre-change tree** — every anchor is absent |
| `C2b` | Both sentinels occur exactly once per surface, and the delimited regions compare equal | **fails on the clean pre-change tree** — the end sentinel exists in neither file |
| `C3` | Block position, cardinality and blank-line structure in the ledger; no label in the template | **fails on the clean pre-change tree** — no label, no entry, so the ordering cannot be established |

Five labels fail on the untouched tree and are the change's real counterfactual: `C1a`, `C1d`,
`C2a`, `C2b`, `C3`. `C1b` and `C1c` are protective — they assert something the change must *not*
do — so their counter-checks are mutations, not the baseline.

### Oracles the executor must satisfy

**`C1a`** — Assert the counts, never print them: a block that reports `0` and exits 0 reports its
own falsifying observation as success. Match the row **as a complete row**, not by a
date-and-fingerprint prefix: a truncated `| <date> | <fingerprint> |` line satisfies a prefix test,
so this label would read as satisfied while `C1d` fails.

**`C1b`** — Compare the full line against the line **taken from `BASE`**, never against a literal
copied into this plan; a literal drifts from the row it protects. This is story AC 2's every-byte
requirement, mechanised.

**`C1c`** — **Four inputs, not three.** Each current surface against **its own** base version, with
current parity asserted separately; one base paragraph used as the reference for both establishes
"untouched" only by leaning on the separate fact that the surfaces are byte-identical today. The
delimiters bounding the paragraph must be asserted present and unique in **every** input **before
any comparison is taken** — a checksum-style comparison returns a value for empty input, so a guard
on the checksum alone can never fire and two unreadable inputs compare equal.

**`C1d`** — Seven distinctions:
1. **Which entry is in scope.** *The mandated entry only*, proven added against `BASE`. Every other
   added entry is ignored; a check quantified over all of them is unsatisfiable against §2.2's own
   repair. *(Closes spec §8 held-not-fixed item 3.)*
2. **An entry from a line that is not one.** Candidates are the **non-blank** lines of the interval
   from the `**Superseded rows:**` label to the `Columns:` paragraph, both exclusive. The blank line
   separating the list from that paragraph is required by CommonMark — without it `Columns:` renders
   inside the list item — so blank lines are not candidates and every non-blank one is. A candidate
   that does not parse must **fail the check**, never be dropped from the candidate set.
   *(This bound does **not** by itself close spec §8 item 4 — it makes `C1d` ignore an entry-shaped
   line outside the interval, which is the opposite of detecting one. `C3`'s whole-file rule and
   Task 5's below-the-table counter-check are what supply the executable guard; this bound is the
   half that stops the format example being read as a candidate.)*
3. **Entry shape.** `- ` marker, `YYYY-MM-DD` date, the literal `· supersedes `, a row date, a
   backticked fingerprint, an **optional** quoted fragment, and two ` · `-separated prose fields,
   **both non-empty** and neither containing ` · `.
4. **Locator equality before eligibility.** Exact **row-date *and* fingerprint** equality is
   established first; the on-or-before bound is applied after. A checker comparing only the
   fingerprint passes every other fixture while reporting non-inert an entry that matches no row.
   *(Closes spec §8 held-not-fixed item 1.)*
5. **Calendar-valid dates**, not merely `YYYY-MM-DD`-shaped: `2026-02-30` parses, sorts, and is not
   a day anything was appended on. Applies to the entry date and to the locator's row date.
6. **Zero from at-least-one.** Zero is inert and must fail; one *or many* must pass. A checker
   demanding *exactly one* implements the guarantee §2.2 withdrew and would still pass this change.
7. **A row from a non-row, a delimiter from an escaped pipe, an empty field from a parse failure,
   and a read failure from a clean pass** — §6's four row-side oracles, verbatim in force. A pipe
   delimits a column only when the run of backslashes immediately before it is **even**; a row is
   complete only at exactly the expected delimiter count, so an overlong line is rejected too.

**`C2a`** — **Occurrences, not matching lines**: after a paragraph join, two copies of an anchor in
one paragraph sit on one line, and a line-counting test reports `1` while the exactly-once claim
measures nothing. Presence is tested against a **paragraph-joined** view, because both surfaces are
hard-wrapped at different columns and most anchors straddle a line break in at least one. **Anchors
are data, not code** — one begins with `-` and five contain backticks; pass them as literal patterns
and let no shell interpret them.

**`C2b`** — Presence first, then parity, **and both must hold**: two identically truncated regions
end at the sentinel and compare equal, so parity alone reports green on a change that reached
neither surface. Parity compares leading indentation and blank-line structure **exactly** — the
four-space prefix is the only thing distinguishing the format example from a live entry — so the
paragraph join must leave indented blocks alone.

**`C3`** — **Cardinality before ordering**, evaluated once, on this change, before any merge
involving it: each of the label, the `Columns:` paragraph and the entry resolves to exactly one
position, and two labels must fail rather than silently taking the first. **The full ordering, not
a prefix of it**: end sentinel `<` label `<` entry `<` `Columns:`, with every entry-shaped line
checked against the interval. **Blank-line structure is asserted, not assumed**: exactly one blank
line immediately above the entry list and exactly one immediately below it, since without the lower
one CommonMark renders `Columns:` inside the list item and every other check still passes. **A
desired zero must not be the failing status** — "no label in the template" expressed as a bare
search succeeds with a nonzero exit.

### The thirty-five anchors — data for `C2a`

Byte-identical to the spec's §6 list. One begins with `-`; five contain backticks.

```text
records a hardening claim as of its date
falsified by a later change, or wrong when it was written
append a `Superseded rows` entry rather than editing it
This holds for every row without exception
the existing `Never edit a row` rule is absolute
The rule is bound to rows, not to commits
is below the rule's resolution, and nothing checks one
Resolving a `pending` row also appends
never alters mechanical behaviour
including when the entry records that the row's hardening claim was itself false
the row keeps its fingerprint, keeps matching the column-2 grep, and keeps counting
A hardening later removed is out of scope
**Correcting a row.**
present only once at least one entry exists
block above the `Columns:`
one appended line per supersession
- <date> · supersedes <row date>
`<date>` is the day the entry is written, in `YYYY-MM-DD`
A row is located by date + fingerprint
An entry applies to every row its locator matches
applies only to matching rows dated on or before the entry's own date
A row's date is the day it is appended
the table is chronological: backdating a row is forbidden
matches no such row is **inert**
append a new entry with a locator that matches
Name the claim that does not hold
cite where the current answer lives
saying whether it stopped holding or was never true
restating that answer here only makes the entry the next stale narration
the last entry for a row is the one that governs
must therefore describe the row as it now stands
Entries are never edited, never removed, and never reference one another
keep one and keep every entry under it
singles out one row only where that row has one no sibling shares
once a line exists as a complete entry it is protected
```

### Fixture matrix — expected outcome per label

Every fixture has a stated expected result under **both** `sh` and `dash`. Fixtures are not all
negative: a checker that rejects valid adversarial content is as wrong as one that accepts invalid
content, and only the pairing distinguishes them.

**One baseline, one advertised mutation each.** Every fixture derives from a single **valid
post-change baseline** — the ledger as Task 4 Step 5 leaves it, with the mandated entry in place —
and differs from it in exactly the one dimension its row advertises. Without that rule a negative
fixture can take its expected failure from an unrelated locator or parse defect and still look like
evidence for the distinction it names.

| Fixture | What it is | Expected | Distinction it kills |
|---|---|---|---|
| `rows-escapes` | a valid row whose `finding` holds `\|`, the digits `001`, and a trailing `\\` | **PASS** `C1a`, `C1d` | a naive splitter that treats `\|` as a delimiter, or `001` as a number |
| `rows-truncated` | `\| <date> \| <fingerprint> \|` and nothing more | **FAIL** `C1a`, `C1d` | prefix matching instead of complete-row matching — `C1d`.7 |
| `rows-overlong` | eight delimited columns instead of seven | **FAIL** `C1a`, `C1d` | rejecting only short lines — `C1d`.7 |
| `rows-empty-finding` | a valid row whose `finding` is empty | **PASS** `C1d` for a fragmentless locator | conflating "empty field" with "parse failure" — `C1d`.7 |
| `ledger-unreadable` | a directory at the ledger path, or mode 000 | **FAIL** `C1a`, `C1b`, `C1c`, `C1d`, `C2a`, `C2b`, `C3` — named, not "every label that reads it" | an empty candidate set read as a clean pass — `C1d`.7 |
| `entry-good` | the mandated entry with a correct locator, **plus a second, inert entry** below it | **PASS** `C1d` | a checker still quantifying over every added entry — `C1d`.1, and spec §8 item 3 |
| `entry-wrong-fingerprint` | right row date, one character off in the fingerprint | **FAIL** `C1d` | — `C1d`.4 |
| `entry-wrong-rowdate` | **right fingerprint, wrong row date** | **FAIL** `C1d` | a fingerprint-only comparison — `C1d`.4, and spec §8 item 1 |
| `entry-before-row` | entry dated before the row it names | **FAIL** `C1d` | a missing on-or-before bound — `C1d`.4 (manifests as zero matches) |
| `entry-on-row-date` | entry dated **exactly** the row's date | **PASS** `C1d` | a strict-before bound — `C1d`.4 |
| `entry-bad-date-entry` | entry dated `2026-02-30` | **FAIL** `C1d` | lexical-only date validation — `C1d`.5 |
| `entry-bad-date-locator` | valid entry date; locator row date **and** a matching table row both dated `2026-02-30` | **FAIL** `C1d` | validating the entry date only — `C1d`.5 |
| `entry-empty-first-field` | valid locator, **what-is-false** field empty | **FAIL** `C1d` | validating one field and not the other — `C1d`.3 |
| `entry-empty-second-field` | valid locator, **citation** field empty | **FAIL** `C1d` | the same, from the other side — `C1d`.3 |
| `entry-separator-in-field` | a prose field containing ` · ` | **FAIL** `C1d` | an ambiguous split — `C1d`.3 |
| `entry-outside-block` | the **mandated entry moved** below the table, none left inside the block | **FAIL** `C1d`, `C3` | shape-only candidate selection — `C1d`.2. Constructed as a *move*, not an addition: an extra line below the table while the mandated entry stays put must **pass** `C1d` under `.1` and `.2`, and Task 5's counter-check covers that construction |
| `rows-two-matching` | **two** complete rows, both dated `2026-07-20` with fingerprint `truncated-tool-output-read-as-complete` — the *locator's* row date, not the entry's; the entry keeps `$D` | **PASS** `C1d` | a checker demanding *exactly one* — `C1d`.6. Two rows dated `$D` would match nothing and would test the wrong thing |

**Expected outcome on the untouched tree, per label** — stated here because "run it against the
pre-edit tree" is ambiguous where five labels are *supposed* to fail there and 0 means success:

| On `BASE`, unmodified | Labels |
|---|---|
| must **fail** — this is the change's counterfactual | `C1a`, `C1d`, `C2a`, `C2b`, `C3` |
| must **pass** — protective, exercised only by the counter-check mutations | `C1b`, `C1c` |

A label in the first row that passes on the untouched tree is a broken check, not a satisfied one.
A label in the second row that fails there means the harness or the base extraction is wrong, and
nothing below it is evidence.

---

### Task 1: Commit the closed Gate-A artifacts and this plan

**Files:**
- Modify: `docs/superpowers/specs/2026-08-05-hardening-ledger-supersession-design.md` (already edited)
- Modify: `docs/superpowers/stories/2026-08-04-hardening-ledger-supersession-story.md` (already edited)
- Add: `docs/superpowers/plans/2026-08-12-hardening-ledger-supersession.md` — this plan, untracked

**Interfaces:**
- Consumes: nothing.
- Produces: **`BASE`** — the commit these land on. Every check compares against it.

- [ ] **Step 1: Confirm the change set is prose-only, path by path**

`git status --short`. Expected: the spec and the story modified, this plan untracked, and the
untracked `docs/research/`, which is not ours and stays untracked. All three of ours are under
`docs/**.md`, none under `.claude/`, `plugins/`, `skills/` or `commands/` at any depth, so **Gate B
is N/A by CLAUDE.md §5's prose exemption**. Read the paths to establish that; do not assume it.

- [ ] **Step 2: Re-run the spec sweep**

Assert, by exit status: 35 anchors, each exactly once in the spec's two `markdown` fenced blocks,
none a substring of another; fences balanced; both anchor-count claims reading "thirty-five".
Any failure stops the task.

- [ ] **Step 3: Commit all three**, staged by explicit pathspec, with the staged set asserted equal
to those three. The message describes what the artifacts now contain — the convention's design, the
governing story's criteria, and this plan — and records the Step-1 classification.

- [ ] **Step 4: Pin `BASE` to the resulting commit** and record the value in the task notes.

The hook may fire a Gate-B STOP on this commit; that is invariant 2's loose-in-the-firing-direction
behaviour, and the N/A classification was checked by hand in Step 1.

---

### Task 2: A harness that has been shown able to fail

**Files:** create the scratch harness — assertion helpers, a paragraph-join helper, a runner.

**Interfaces:**
- Consumes: `BASE`.
- Produces: the assertion vocabulary every check uses, and a paragraph-joined view in which blank
  lines are preserved, lines indented four or more spaces are emitted verbatim on their own line,
  and every other run of non-blank lines collapses to one line with single spaces.

- [ ] **Step 1: Write the harness.** Required properties:
  - Exit status is captured **before** any command substitution runs; a substitution resets `$?`.
  - No multi-line pattern is ever passed to `grep -F`. Fixed-string grep treats each line of the
    pattern as a **separate** pattern, so it never establishes the contiguous multi-line sequence
    you meant and can exit 0 on either component line alone — a false *positive*, not a clean
    absence.
  - Any `sed` or `awk` delimiter is chosen so no fixture's `\|` can collide with it.
  - **Anything on stderr fails the run**, per the global oracle.
  - Failure is counted, not merely printed; the runner's exit status is the failure count.

- [ ] **Step 2: Write a self-test containing a deliberate failing assertion.** It must show:
  `true` → 0 and `false` → 1 read correctly; a wrong assertion increments the failure count; **a
  command writing to stderr fails the run**; the paragraph join folds wrapped prose and leaves a
  four-space-indented line untouched; a literal `\|` and the digits `001` survive unchanged.

- [ ] **Step 3: Run the self-test under `sh` and under `dash`.** Both must exit 0 **and** both must
print the deliberate failure. If the deliberate failure does not appear, stop — nothing below is
evidence.

- [ ] **Step 4: `shellcheck --shell=sh` the harness.** Expected: exit 0.

- [ ] **Step 5: No commit.** The harness is scratch, so it is never inside Gate B's compared range.
Its review is: Steps 3 and 4 here, the per-label counter-checks, and the **Gate-B reviewer's read of
the source pasted into `additionalContext`** at Task 8 Step 5. "Outside the reviewed range" is the
true claim; "unreviewed" is not.

---

### Task 3: `C2a`, `C2b` — land the convention in both surfaces

**Files:**
- Modify: `docs/hardening-log.md` — insert after the existing first paragraph, before `Columns:`
- Modify: `plugins/dev-workflow/commands/workflow-init.md` — the same insert, inside the fenced
  template under `### 2.2 \`docs/hardening-log.md\` — the empty ledger`

**Interfaces:**
- Consumes: the harness, `BASE`, the anchor list.
- Produces: both surfaces carrying §2.1 and §2.2's prose, byte-identical modulo hard-wrap position.

- [ ] **Step 1: Implement `C2a` and `C2b`** to the oracles above.

- [ ] **Step 2: Run them against the pre-change tree and confirm they fail.** Expected: `C2a` fails
first, on the first anchor, in both surfaces; `C2b`'s end-sentinel assertions fail in both. If
either passes here, the check is wrong — stop.

- [ ] **Step 3: Land §2.1 and §2.2 in the ledger.** The text is the spec's two `markdown` fenced
blocks, **copied, not retyped**. Insert after the existing first paragraph — which is **not**
edited — and before the `Columns:` paragraph. Rewrap to the ledger's own column width; wrap position
is the only permitted difference between surfaces. The four-space indented format example stays a
single indented line.

- [ ] **Step 4: Land the identical text in the inline template**, in the identical position.
**No `Superseded rows:` block and no entry** — a scaffolded ledger has no entries, and the label
appears only where entries do.

- [ ] **Step 5: Re-run `C2a` and `C2b` under `sh` and `dash`.** All must pass under both.

- [ ] **Step 6: Run the matrix rows naming `C2a` or `C2b`** — `ledger-unreadable` — **under both
shells**, and confirm both labels fail on it. A label that yields an empty candidate set and exits 0
on an unreadable input has examined nothing and reported success.

- [ ] **Step 7: Counter-check both labels.**
  - `C2a`: delete one anchored clause from **both** surfaces, re-run, confirm `C2a` fails — this is
    the state parity alone cannot see — then restore and re-run.
  - `C2b`: change the region in **one** surface only, re-run, confirm the parity comparison fails,
    then restore and re-run. Without this, `C2b` can be a presence-only no-op and still pass every
    prescribed run.

- [ ] **Step 8: Commit both surfaces together**, staged by explicit pathspec with the staged set
asserted equal to those two, message prefixed `WIP: ` (see Task 8 Step 3 for how the prefix is used).

---

### Task 4: `C1a`–`C1d`, `C1f` — land the block and the entry

**Files:**
- Modify: `docs/hardening-log.md` — the `Superseded rows:` block, between §2.2's last line and the
  `Columns:` paragraph
- Create: the fixtures in the matrix above

**Interfaces:**
- Consumes: the harness, `BASE`, both surfaces as Task 3 left them.
- Produces: the ledger's block holding exactly one entry.

- [ ] **Step 1: Build every fixture in the matrix**, each with its stated expected outcome.

- [ ] **Step 2: Implement `C1a`–`C1d`** to the seven `C1d` distinctions and the other oracles above.

- [ ] **Step 3: Run every matrix row whose expected column names `C1a`, `C1b`, `C1c` or `C1d`,
**under both `sh` and `dash`**, and compare by exit status.** Every one must match — the PASS rows
as well as the FAIL rows. Both shells, because the matrix states its outcomes for both and a
shell-specific parser defect otherwise survives behind a happy path that passes twice. Rows naming
`C3` are deferred to Task 5, where `C3` exists; running them here is not possible. `entry-wrong-rowdate` is
the row a fingerprint-only checker passes, `rows-escapes` the one a naive splitter rejects, and
`entry-good` the one a checker still quantifying over every added entry fails; if any disagrees with
its expected outcome, `C1d` does not decide its property and the run is not evidence.

- [ ] **Step 4: Run against the real ledger and confirm `C1a` and `C1d` fail** — the entry is absent.

- [ ] **Step 5: Land the block.** Between the last line of §2.2's prose — the line ending
`and nothing checks the difference.` — and the `Columns:` paragraph, with **one blank line on each
side of the list**; CommonMark requires the lower one or `Columns:` renders inside the list item.

```markdown
**Superseded rows:**

- $D · supersedes 2026-07-20 `truncated-tool-output-read-as-complete` · its `ref` states that an incomplete pass still increments the counter, including a failed review returning `{success: false}`; true when written, and it no longer holds for every pass · CLAUDE.md §5, the paragraph opening `` **What this does not do.** The hook counts on `PostToolUse` ``
```

The `**Superseded rows:**` label is §2.2's, not §3.1's. Substitute `$D` in the entry line;
everything else **in that line** is verbatim from the spec's §3.1 — including the **double**
backticks with one space inside each delimiter (the fragment contains a `` `PostToolUse` `` span, a
single-backtick span cannot carry backticks, and markdown has no escape inside a code span), and the
`**` emphasis markers inside the quoted fragment (`CLAUDE.md` §5 holds **two** paragraphs titled
"What this does not do"; a fragment stripped of its `**` is not byte-findable in the file it points
at).

- [ ] **Step 6: Re-run `C1a`–`C1d` under `sh` and `dash`.** All must pass under both.

- [ ] **Step 7: Counter-check the protective labels.**
  - `C1b`: **on a scratch copy of the ledger, never the real one** — a row is protected the moment
    it exists — change one character of the 2026-07-20 row, point `C1b` at the copy with `BASE`
    unchanged, confirm failure. The real `docs/hardening-log.md` is not touched at any point.
  - `C1c`: change one word of the first header paragraph in the **ledger**, confirm failure, restore;
    repeat independently in the **template**, confirm failure, restore. Then corrupt the **base
    version of the template** specifically — substitute a stand-in for that extraction in which a
    bounding delimiter is missing — and confirm the presence-and-uniqueness guard fires *before* any
    comparison, then restore. That input is the one a three-input implementation never reads: it
    passes both current-surface mutations and the ledger-base mutation, so mutating "one input"
    chosen at random does not distinguish it.
  - **Finish with a green run on the restored real surfaces**, `C1c` under both shells, immediately
    before Step 9. The last green result otherwise predates the mutations, so an incomplete restore
    would be committed under a verdict that never saw it.

- [ ] **Step 8: `C1f` — the named read.** A human confirms **four** things, one per requirement
§2.2 puts on entry text: the entry names the claim that does not hold; it says **which cause**
applies (here: it stopped holding — true when written); it **cites without restating**, pointing at
where the current answer lives rather than copying 0.8.0's counting rules into the marker; and its
citation resolves to **exactly one** paragraph in `CLAUDE.md`. Verify the last mechanically as an
aid, not a substitute. Record the outcome — it is the evidence half of the story's mode, and a green
mechanical run would otherwise rest on nothing.

- [ ] **Step 9: Commit**, `WIP: ` prefixed.

---

### Task 5: `C3` — the block is where §2.2 says, and only there

**Files:** none modified — a validation-only task.

**Interfaces:**
- Consumes: the harness, both surfaces as Task 4 left them.
- Produces: nothing.

- [ ] **Step 1: Implement `C3`** to its oracles above, blank-line structure included.

- [ ] **Step 2: Run under `sh` and `dash`.** All must pass under both.

- [ ] **Step 3: Run the matrix rows deferred from Task 4** — every row whose expected column names
`C3`, which is `entry-outside-block` and `ledger-unreadable` — **under both `sh` and `dash`**. Both
must fail `C3` under both.

- [ ] **Step 4: Counter-check, every mutation on a scratch copy of the ledger.** These move,
duplicate and remove **complete entries**, which §2.2 forbids in the real file even before a commit;
the real `docs/hardening-log.md` is not touched. Point `C3` at the copy for each, confirm failure,
then discard the copy:
  a second `**Superseded rows:**` label (cardinality); the block moved below the table (ordering);
  **a second entry-shaped line appended below the table while the valid block stays in place**
  (the interval oracle — moving the whole block does not test it, because a moved block still has
  every entry inside its own interval); the blank line **above** the list removed; the blank line
  **below** the list removed — this last one is the mutation every other label survives.

- [ ] **Step 5: No commit.** Record every deferred-matrix and counter-check outcome.

---

### Task 6: Version bump and changelog

**Files:**
- Modify: `plugins/dev-workflow/.claude-plugin/plugin.json:4` — `"version": "0.8.1"` → `"0.8.2"`
- Modify: `plugins/dev-workflow/CHANGELOG.md` — newest first, below the preamble

**Interfaces:**
- Consumes: nothing.
- Produces: `0.8.2` — named in the changelog entry and in the closing commit body (Task 8 Step 7).

- [ ] **Step 1: Bump the manifest.** Patch: the change adds a convention to a scaffolded template;
no component is added, removed or renamed. Add no manifest keys — invariant 6 stands.

- [ ] **Step 2: Write the changelog entry** in the file's existing format:

```markdown
## 0.8.2

- `workflow-init`: the scaffolded ledger header now carries a supersession convention —
  a row whose narration is later found wrong or made stale is corrected by appending a
  `Superseded rows` entry, never by editing the row. Both standing rules hold unchanged:
  never edit a row, one row per hardening.
```

- [ ] **Step 3: Verify** — `sh scripts/check-invariants.sh` and `claude plugin validate . --strict`,
both exit 0.

- [ ] **Step 4: Commit**, `WIP: ` prefixed.

---

### Task 7: `todos.md` — close the source row, park two

**Files:** Modify `todos.md`, at the row **The hardening ledger has no supersession convention.**

**Interfaces:** Consumes nothing; produces nothing.

- [ ] **Step 1: Close the source row.** `- [ ]` → `- [x]`, body rewritten in the past tense so it
no longer reads as an open gap, pointing at the spec. The fired-trigger record stays.

- [ ] **Step 2: Park the uncovered case:**

```markdown
- [ ] **A hardening that is later *removed* has no sanctioned supersession move.** The convention
      in `docs/hardening-log.md`'s header covers a row whose narration was falsified later or was
      wrong when written, and names a removed hardening as explicitly out of scope. No instance
      exists. *Trigger: the first rung actually removed.*
```

- [ ] **Step 3: Park the standing check:**

```markdown
- [ ] **Nothing standing validates a supersession entry, and no chronology check exists.** The
      checks in `docs/superpowers/specs/2026-08-05-hardening-ledger-supersession-design.md` §6 ran
      once, on the change that introduced the convention, and then stopped; §6's 1e was not
      implemented at all, since it validates the ledger's pre-existing chronology rather than that
      change. Wiring both into `AGENTS.md`'s quality battery is the follow-up — **with the rider
      that any standing check must be diff-scoped *and* must pass on §2.2's sanctioned repair**: a
      whole-block scan is unsatisfiable once an immutable inert entry exists, and a check demanding
      that no appended entry be inert fails on the very move the convention prescribes for a
      mistyped locator. *Trigger: the first inert entry found after this change lands.*
```

- [ ] **Step 4: Named read.** Confirm no present-tense claim that the ledger lacks a convention
survives, and both parked rows are present with their triggers.

- [ ] **Step 5: Commit**, `WIP: ` prefixed.

---

### Task 8: Conformance, battery, Gate B, close

**Files:** none modified unless a check fails.

**Interfaces:** Consumes everything above; produces one commit replacing every `WIP:` snapshot.

- [ ] **Step 1: Prompt conformance**, all twelve `docs/prompt-standards.md` items, on
`plugins/dev-workflow/commands/workflow-init.md`. Record each item's verdict, and alongside them the
**invariant-9 verdict**: the changed header reaches an existing scaffolded project as "present and
different", which routes to show-the-diff-and-ask, and the edit added no write behaviour.

- [ ] **Step 2: Run the quality battery** — the full chained command in `AGENTS.md` § Commands.
Expected: exit 0. `check-version-bump.sh main` compares *commits*, so it needs Task 6's snapshot
committed; run with the plugin edits still in the working tree it reports clean, correctly and
uselessly.

- [ ] **Step 3: Consolidate to exactly one `WIP:` commit.**

```
git reset --mixed $BASE
git add -- <the five paths below>
git diff --cached --name-only    # must equal exactly those five
git commit -m "WIP: supersession convention"
```

`BASE` — not "the parent of the first WIP". After the reset HEAD **is** `BASE`, so this step must
create the WIP commit before anything reviews or amends it.

**Use `--mixed`, not `--soft`.** A soft reset leaves whatever accumulated since `BASE` staged, and
explicitly adding the intended paths afterwards does not *unstage* an extra one — the equality
assertion would then halt execution with no sanctioned route forward. `git reset --mixed $BASE`
moves HEAD and clears the index while leaving the worktree intact; stage from these five and no
others — `docs/hardening-log.md`, `plugins/dev-workflow/commands/workflow-init.md`,
`plugins/dev-workflow/.claude-plugin/plugin.json`, `plugins/dev-workflow/CHANGELOG.md`, `todos.md` —
then assert `git diff --cached --name-only` equals exactly that list. Task 8 modifies no files of
its own, so this is the list the global staging constraint compares against. The message prefix is
`WIP: `; what that prefix does is CLAUDE.md §5 Mechanics, cited.

- [ ] **Step 4: Compose and validate the evidence entry, before any Gate-B call** — §5 defines what
an entry is and when it is owed; this step supplies this change's values into that procedure. It is
**one entry**, not a list of strings that happen to share a commit body: the story path
`docs/superpowers/stories/2026-08-04-hardening-ledger-supersession-story.md` belongs **inside** it,
per §5, so the named evidence is bound to the story whose mode obliges it. The values: the battery
result; the **named check that fails without this change** — one of the five labels failing on the
untouched tree, `C1a` or `C1d` being the narrowest; and the **counterfactual**, the observation that
would exist if the claim were false, with confirmation that the wiring could have produced it. Hold
this as the current entry; later steps quote it whole.

- [ ] **Step 5: Gate B — follow CLAUDE.md §5 Mechanics as written.** It is cited, not restated. The
values this change resolves:
  - `baseSha` = `$BASE`; the range is `$BASE..HEAD`, HEAD being the Step-3 WIP commit.
  - `reviewType: full`. Target-file lifecycle and the recovery rules are §5's, cited not copied —
    including which files a resume deletes, which is **not** "both" and which §5 states exactly.
  - `additionalContext` carries the story path
    `docs/superpowers/stories/2026-08-04-hardening-ledger-supersession-story.md`, so the reviewer
    reads the profile itself; **this plan's path**, since it lands in the Task-1 commit and so sits
    *before* `$BASE`, outside the reviewed range; the Step-4 evidence entry quoted verbatim; **and
    the complete current source of the harness and every check, with the fixture definitions**. The
    checks are never committed, so this paste is the only review they get — the opening contract and
    spec §8 both say so, and omitting it would leave that claim false.
  - **The falsification lens, aimed:** name what this diff changes the size, value or position of —
    the version string, the ledger's line count and byte offsets, the anchor count, the template's
    fenced block — and grep for where each is described elsewhere. Check `docs/architecture.md`,
    `MANIFEST.md`, `README.md` and `docs/getting-started.md` by name.

- [ ] **Step 6: After every fix, amend it into the WIP commit before re-reviewing.** Stage the fixed
paths explicitly, assert the staged set equals them, then
`git commit --amend -m "WIP: supersession convention"` — the prefix stays until Step 7. Revalidate
the Step-4 evidence entry at each amend. §5's re-review rule governs; this step exists only because
`mcp__codex__review` reads the **committed** range, so a worktree-only fix is re-reviewed as the
stale diff.

- [ ] **Step 7: Close by amend, after the final clean pass.** `git commit --amend`, replacing the
WIP message with the real one. The body names `0.8.2` and carries the Step-4 evidence entry whole,
as the final clean pass validated it — the story path is inside that entry and is not listed
separately. §5 governs everything else about closing, revalidation included.

---

## Self-Review

**Spec coverage.** §2.1, §2.2 → Task 3. §3.1's entry → Task 4. §3.2 (row D) → no action by design;
the ledger is not retro-corrected. §4's change surface → Tasks 3, 4, 6, 7 for the two surfaces, the
manifest, the changelog and `todos.md`; **Task 1** for the governing story's amendments; and three
rows already carrying their content and named as outside this execution —
`docs/coding-workflow.md`, the 2026-08-04 plan's snapshot note, and the guard-scope story's
inherited open question. §5 → handed to another story. §6 check 1 → `C1a`–`C1d`, `C1f`, with **1e not
implemented and recorded in §8**; check 2 → `C2a`–`C2b`; check 3 → `C3`; prompt conformance →
Task 8. §7 → riders governing the spec's own review; no implementation task. §8's four
held-not-fixed items → traced: item 1 to `C1d`.4
and the `entry-wrong-rowdate` fixture; item 2 to the Global Constraint; item 3 to `C1d`.1 and
`entry-good`'s second inert entry; item 4 to **`C3` plus Task 5's below-the-table counter-check**,
with `C1d`.2's interval as the half that keeps the format example out of the candidate set — the
interval alone would not detect a stray entry, since ignoring one is not finding one. The precedence
paragraph makes all four authoritative over §6.

**Placeholder scan.** One deliberate blank: the evidence entry, which must be revalidated at the
moment of the amend rather than written now. `$D` and `BASE` are defined in Global Constraints and
Task 1.

**Label consistency.** `C1a`, `C1b`, `C1c`, `C1d`, `C1f`, `C2a`, `C2b`, `C3` — eight, defined once
in the check table and used under those spellings throughout. `C1e` appears only where its absence
is recorded. Fixture names in the matrix match those in Task 4's steps.
