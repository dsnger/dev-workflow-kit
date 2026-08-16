# Reviewer-availability salvage — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Ship the salvage from the closed reviewer-availability story — a human-exception
record form, a closed severity enum with a tolerant reader, and a squash-carry sentence — into
`CLAUDE.md` §5 and its `/workflow-init` mirror, with one mechanical assertion behind it.

**Architecture:** Four prose blocks, written identically into two files, plus one check in the
existing `scripts/check-invariants.sh`. No new file, no CI change, no new executable surface.

**Tech Stack:** Markdown prompts; POSIX `sh` + `awk` for the checker; `shellcheck` and the
existing regression suite.

**Spec:** `docs/superpowers/specs/2026-08-14-reviewer-availability-fallback-design.md` —
§4 is the path table, §2.1 and §3 carry the shipped text verbatim, §5.2 the assertion.
**Story:** `docs/superpowers/stories/2026-08-13-reviewer-availability-fallback-story.md` —
profile: risk `standard` · security `none` · `battery+check`. Read it fresh; never from here.

## Global Constraints

- **The two prompt copies are `CLAUDE.md` and `plugins/dev-workflow/commands/workflow-init.md`.**
  Every prose edit below goes into **both**, identically. The mirror lives inside the
  ````markdown fence at lines 192–629 and is flush-left; §5 is at `CLAUDE.md:65` and
  `workflow-init.md:257`.
- **Parity is a named verification, not a check.** After each prose task, diff the region you
  edited between the two copies and note the result in your working notes — **not** in a commit
  body, because Tasks 2–5 only amend a WIP commit whose message deliberately does not change.
  All parity results are written once, into the final closing amend. Nothing verifies any of
  this (spec §5.3).
- **Cite `CLAUDE.md` §5, never restate it.** The shipped text below is the whole change; do not
  paraphrase surrounding rules into it.
- **No `Co-Authored-By` / `Generated with` trailers** (AGENTS.md Don'ts).
- **Quality command** = the `AGENTS.md` § Commands battery row. Run it, not a subset.
- **One WIP commit for the whole cycle. No task ends with a real commit.** `CLAUDE.md` and
  everything under `plugins/` are product, so this is one full Gate-B cycle, and §5 Mechanics
  is explicit: Gate B runs *before* `git commit`, and a non-`WIP` commit reads to the hook as
  the cycle closing and discards the accumulated passes. So:
  - **Task 1 creates the snapshot, and it carries everything** — including the twice-amended
    spec, this plan, and `scripts/check-invariants.{sh,test.sh}`, which were built and run
    during Gate A so the plan could cite executed code. **`baseSha` = `c0a6ed2`.**
    An earlier draft committed those four separately, first: that commit then *became* the WIP
    parent, and a `baseSha..HEAD` range **excludes `baseSha` itself**, so Gate B would have
    excluded the very artifacts the separate commit existed to include. It was also a non-WIP
    commit of executable code with the battery red and no Gate-B loop, which §5 forbids twice
    over. One snapshot, one range, one close.
  - **Tasks 2–5 amend it:** `git commit --amend --no-edit`. The WIP message stays as-is; the
    real message is written once at the close.
  - **After Task 5:** run the battery and the counterfactual, then the Gate-B loop against
    `baseSha` = the WIP commit's parent, then close with
    `git commit --amend -m "<real message>"` carrying the validated evidence entry.
  - Per-task commit *messages* are given below as **what the closing message must cover**, not
    as commands to run. If you want per-task history, produce it only after the reviewed
    closing state exists.
- **The 0.9.0 manifest bump happens in Task 1, not Task 5.** Task 1's snapshot is the first
  commit carrying plugin changes, so the bump must be in it: otherwise every intermediate
  battery in Tasks 2–4 runs `scripts/check-version-bump.sh` against a committed, unbumped
  plugin diff and **fails on a branch** — passing only on `main`, where the range is empty and
  the run decides nothing. Task 5 still writes the CHANGELOG entry last, because that text
  describes work the earlier tasks produce; only the `version` field moves early.
- **The WIP parent is recomputed, never carried.** A shell variable does not survive between
  tool calls or a resumed session, so every consumer derives it itself, from the snapshot that
  is still `WIP`:
  ```bash
  WIP_PARENT=$(git rev-parse HEAD^) || exit 1
  git log -1 --format=%s | grep -q '^WIP:' || { echo "HEAD is not the WIP snapshot"; exit 1; }
  ```
  The guard matters, and its reason is narrower than it looks: an amend **preserves** the
  parent, so `HEAD^` does not move when the cycle closes. What changes is the **subject** — so
  the guard is what stops the procedure being run after the WIP state has ended, when `HEAD^`
  would be the parent of a *closed* commit and the range would mean something else. `scripts/check-version-bump.sh` compares commits, so it
  must be given that sha — run against `main` from `main`, the merge-base is HEAD, the range is
  empty, and it passes without deciding anything.

---

### Task 1: The closed severity enum, its tolerant reader, and check 4c

**Check 4c and its fixtures are already written and green in the working tree.** They were
built and run rather than specified, because four Gate-A passes on this plan showed that shell
embedded in a document gets reviewed by reading and gets it wrong — three of those four passes
had a blocker in the same thirty lines of `awk`, each introduced by the previous pass's fix.
The shell below is not a proposal; it is what is in the file, and the run output is what it
printed. **Your job is to verify it, not to write it.**

**Files:**
- Already modified (verify): `scripts/check-invariants.sh` — `BEGIN check 4c` … `END check 4c`
  after 4b's end marker; `scripts/check-invariants.test.sh` — `init_prompt_fixtures` extended,
  `sev_case`/`sev_put`/`sev_tpl` builders, **24 `sev_case` cases and one `inject_case`**
- To modify: `CLAUDE.md` — findings-protocol blockquote at `:97`, acceptance rule after `:150`
- To modify: `plugins/dev-workflow/commands/workflow-init.md` — the same two places in the mirror
- To modify: `scripts/check-invariants.sh` header inventory at `:24` and `:32`; **not** `:261`
- To modify: `scripts/check-invariants.test.sh` — the mutation-evidence block at `:325`
- To modify: `AGENTS.md` — invariant 11 at `:173`
- To modify: `plugins/dev-workflow/.claude-plugin/plugin.json` — `version` `0.8.2` → `0.9.0`

**Interfaces:**
- Consumes: nothing.
- Produces: `SEV_CANON` (checker) and `SEV_LINE` (suite) — the same literal. The WIP parent is
  **derived locally** by every consumer, never carried (see Global Constraints).

- [ ] **Step 1: Verify the check and its suite, as built**

```bash
shellcheck --shell=sh scripts/check-invariants.sh
shellcheck --shell=sh --exclude=SC2015 scripts/check-invariants.test.sh
sh   scripts/check-invariants.test.sh
dash scripts/check-invariants.test.sh
```

**Observed when written:** shellcheck clean on both; `all passed (148 assertions)` under `sh`
and under `dash` — 123 before, so 25 new. If your run differs, something moved and the rest of
this task is not safe to start.

**What 4c checks, as built** — two rules, priced separately in spec §5.2:

- **Duplicates, both files.** The canonical line must appear **exactly once per file**, as a
  whole line, after stripping a leading blockquote marker and indentation, compared for
  **equality** and **case-sensitively**. Nothing is stripped from the right.
- **Placement, the command file only.** That occurrence must sit inside the **`### 2.1`**
  scaffold section, terminated by the next **numbered** `### ` heading. Only that region is
  scaffolded into a user's project, so a copy in the command file's own prose ships nothing —
  and whole-file counting alone permitted exactly that, verified by running it. The terminator
  is *numbered* on purpose: the template carries its own `### Profiles` and `### Mechanics`
  subsections, and a next-`###` rule would truncate the range at them. A missing, renamed or
  duplicated `### 2.1` **fails loudly** rather than skipping the rule.

The repo's own `CLAUDE.md` gets no placement rule — the whole file is the artifact.

The 25 assertions cover presence, duplicates (including two copies on one line), equality
(blockquoted and indented accept; leading text, trailing text, trailing space, title-case and
paraphrase reject), placement (**the outside-the-template exploit as a reject case**, inside as
accept, after an unnumbered subsection as accept, missing and duplicate anchor as reject,
`CLAUDE.md` needing no anchor as accept), **terminator drift** (unnumbered terminator, a line
planted in the widened gap — the second verified exploit — and an absent terminator, all
reject), and fail-closed paths (missing file, unreadable file
— skipped as root, which satisfies `-r` on mode 000 — and parser failure through the suite's
`inject_case` PATH seam keyed on the `sev-canon-count` marker).

- [ ] **Step 2: Observe the counterfactual**

```bash
sh scripts/check-invariants.sh; echo "exit: $?"
```

**Observed:** exit 1, with exactly two diagnostics — `CLAUDE.md must state the closed severity
set exactly once; found 0.` and the same for the command file. Nothing else fired. **This is
the `+check` evidence**, and it is an observation rather than a claim: the check is in the
tree, the canonical line is not yet in either prompt copy, and the failure names only 4c.

Record this output. Once Step 3 lands, it cannot be reproduced without reverting the prose.

- [ ] **Step 3: Add the canonical line to both prompt copies**

In `CLAUDE.md`, inside the findings-protocol blockquote, make `:97–98` read:

```markdown
> One finding per line in the format above; escape a literal pipe inside a field as
> `\|`.
> Severity is one of exactly: BLOCKER | MAJOR | MINOR | NIT — no other token.
> Every line before the terminator is exactly one finding line — no blank lines,
```

It must be **its own line**: 4c compares whole lines. Make the identical edit in the mirror at
`plugins/dev-workflow/commands/workflow-init.md:295`.

- [ ] **Step 4: Add the tolerant reader rule to both copies**

**Copied byte-for-byte from spec §3.** An earlier draft reworded it — changing the opening
rule, collapsing the structural-failure inventory, importing prose from elsewhere. The product
is prompts, so reworded is *changed*. Extract from the spec and diff against what you paste.

Immediately after the "Accept a pass only when" paragraph (`CLAUDE.md:150`), and at the
matching place in the mirror:

```markdown
**Reader:** the severity field is taken by splitting the line on **unescaped** pipes and
trimming the ASCII whitespace the finding format puts either side of each separator; a field
that is empty or all whitespace is a **structural** failure, so the line is INCOMPLETE and is
never normalized. Otherwise the field is matched **case-insensitively** against the four tokens
first — `Minor`, `minor` and `MINOR` are all `MINOR`, because `CLAUDE.md` Mechanics
legitimately spells them in Title case and a model copying that spelling is doing as it was
told, not drifting. A field that matches no token case-insensitively, and is non-empty, is
read as `MAJOR`. Every **structural** failure stays INCOMPLETE — a malformed
line, a wrong field count, an empty severity field, a bad terminator, a count mismatch. Only
the severity token is tolerated, and only when everything else about the line is right.
```

- [ ] **Step 5: Run the full battery — 4c should now pass**

Run: the `AGENTS.md` § Commands quality command.

Before Step 3 the checker exits 1 on 4c (Step 2's counterfactual). After Steps 3–4 it exits 0.
**That transition is the evidence**, and it is the reason those steps come before the rest of
this task rather than after.

- [ ] **Step 6: Update `AGENTS.md` invariant 11 and the checker's own inventory**

Replace the **whole** three-sentence tail of invariant 11 — from `review is the gate.` through
`judged by a reader.` — so the replacement does not duplicate the sentences bracketing it:

```markdown
    review is the gate. Three narrow checks in `scripts/check-invariants.sh` cover one
    spelling each — a `Target model:` line naming exactly one recognized model in files
    claiming conformance, a prose checklist-count claim matching the checklist, and the
    finding-severity vocabulary stated as a closed set in both prompt copies — and they
    are a floor, not coverage. Every other item is judged by a reader.
```

Then the checker's own comments, and **not by changing every "two" to "three"**:

- `:24` — "The two prompt-conformance checks below" is a **count of checks** → three.
- `:32` — the mutation procedure. Parameterise it over all three markers, with the
  baseline-green and load-bearing guards, rather than adding a 4c-specific line; a
  marker-specific procedure is what went stale before.
- `:261` — "Scan domain for the two prompt-conformance checks below" describes what
  `PROMPT_EXCL` and the recursive Markdown scan govern, and that is **still 4a and 4b only**.
  4c reads two fixed paths directly. Say so explicitly. Incrementing it would put a fresh
  enforcement-scope overclaim into the change meant to calibrate one.

- [ ] **Step 7: Verify the mutation evidence — already measured and recorded**

The block at `scripts/check-invariants.test.sh` § *Prompt conformance: checks 4a, 4b and 4c*
carries a **RE-RUN TRIGGER** this work fired by name: a marked check added, fixtures added,
harness changed. **It has been re-run and the block rewritten.** Measured:

| Deleted block | Assertions flipped to FAIL |
|---|---|
| 4a | **20** — unchanged from the previous record |
| 4b | **22** — see below |
| 4c | **19** — its 18 reject fixtures plus `4c canonical-line parser failure fires` |

**No accept case moved in any of the three** — the second half of the check, and the one a
non-empty flip set alone does not establish.

**4b measured 21 on the first run against a recorded 22, and that was a real regression this
work introduced.** `checklist parser failure fires` greps the checker's output for the bare
`parser failed`; 4c's new diagnostic also ends in those words, so the fixture had stopped
testing 4b — deleting the 4b block left it green. The pattern is now `checklist parser failed`
and the count is 22 again. **This is the argument for building before planning:** four review
passes read that shell without finding it; one mutation run did.

Confirm the numbers if you change anything. If they differ, the record is wrong and must be
rewritten — nothing re-runs it for you.

- [ ] **Step 8: Bump the manifest, lint, and create the one WIP snapshot**

`plugins/dev-workflow/.claude-plugin/plugin.json`: `version` `0.8.2` → `0.9.0`. **Minor, not
patch** — §5's decision procedure gains a record form and a reader rule, which is new product
behaviour. It happens here, not in Task 5, because this snapshot is the first commit carrying
plugin changes and invariant 12 wants the bump in it.

Run the `AGENTS.md` § Commands quality command **again** — every Task 1 edit is now in place —
then:

```bash
shellcheck --shell=sh scripts/check-invariants.sh
shellcheck --shell=sh --exclude=SC2015 scripts/check-invariants.test.sh
git add CLAUDE.md plugins/dev-workflow/commands/workflow-init.md \
        scripts/check-invariants.sh scripts/check-invariants.test.sh AGENTS.md \
        plugins/dev-workflow/.claude-plugin/plugin.json
git commit -m "WIP: reviewer-availability salvage"
```

**This is the cycle's only commit until Gate B closes it.** Tasks 2–5 amend it. Closing-message
share for this task: rider (b) — the writer's vocabulary stated rather than exemplified in both
copies; the reader matching case-insensitively so a pass is never discarded over a token; check
4c asserting the statement is present exactly once per file, case-sensitively; the mutation
record re-measured, including the 4b isolation regression found and fixed; and the two edited
regions diffed and matched.

### Task 2: The human-exception record form

**Files:**
- Modify: `CLAUDE.md` — § Mechanics, immediately after the closing-message rule at `:413`
- Modify: `plugins/dev-workflow/commands/workflow-init.md` — same place, at `:603`

**Interfaces:**
- Consumes: nothing from Task 1.
- Produces: the `Human exception:` block form, quoted by Task 5's changelog entry.

- [ ] **Step 1: Add the paragraph to `CLAUDE.md`**

**Copied byte-for-byte from spec §2.1.** An earlier draft of this plan paraphrased it —
dropping the closed-and-unmerged condition on the no-destination case, the
does-not-reopen-any-gate sentence, and part of the mandatory-scope wording — while
claiming to be verbatim. Those are the limiting clauses; do not re-edit them here.
Verify by extracting the block from the spec and diffing against what you paste.

```markdown
> **Recording a human exception.** Where a human decides that something **no applicable rule
> required** was nonetheless worth skipping — an optional check this environment cannot run, a
> review someone asked for and then stood down, a courtesy step — that decision goes in the
> closing commit body:
>
> ```
> Human exception: <handle> · <date>
> Not done: <what was skipped, specifically>
> Accepted because: <one line>
> ```
>
> **Which commit:** an ungated change records it in that commit; a Gate-A cycle in the spec or
> plan commit; a Gate-B cycle in the WIP commit, restated by the closing amend. Several records
> accumulate; order means nothing.
>
> **A decision made after its commit closed** — during PR review, say — goes in whichever of
> these exists: the next commit on the branch, the squash body, or a follow-up commit after the
> merge. If none does — the branch is closed, unmerged, and heading for an ordinary or rebase
> merge — **add a commit for it.** An empty commit carrying only the record is a legitimate
> destination and does not reopen any gate: it changes no content, so it raises no review
> obligation. A record with nowhere to go would otherwise be a record that does not exist.
>
> Copy every record into the squash body alongside the evidence entry (Mechanics,
> squash-merge carry). **Nothing performs that carry and nothing checks afterwards that it
> happened** — it is on whoever prepares the merge. If two copies of one record disagree, that
> is a copying error: stop and fix it rather than picking one.
>
> **Scope, and it is narrow. This form supplies no permission.** It records a decision that
> was already the human's to make about something genuinely optional. It is **never** the answer to a
> below-floor pass, an unclean final pass, a `STOP and surface`, a Gate-A or Gate-B
> obligation, or a profile-derived evidence requirement — and more generally **it authorizes
> nothing that any mandatory rule in this file or in `AGENTS.md` requires.** Those have their
> own terminal actions and this paragraph changes none of them: on a STOP you still stop, and
> neither a human's assent nor this record lets an agent close or continue a cycle.
>
> **"Mandatory" is not limited to this file.** A rule in `AGENTS.md`, a project doc, CI, a
> branch policy or the platform is equally out of reach — under **Wait for**,
> `docs/pr-review-bots.md` requires a bot review unless an explicit recorded human decision
> permits proceeding without it, and this form is not that decision. If you are reaching for it to get past something mandatory, the answer
> is no — take the operational route or stop.
>
> **Nor is it for things that were simply never owed.** An absent review from a bot routed
> **opportunistically** blocks nothing and needs no exception and no record;
> `docs/pr-review-bots.md` says so deliberately, and writing one anyway would rebuild the
> per-quiet-bot ceremony that routing removed. Record a decision, not a non-event.
>
> **What the record is worth.** It is an **unverified assertion**, and reads as one: nothing
> checks that the handle belongs to whoever decided, that a human was asked, or that the
> reason is honest. A reader of history learns that *the commit claims* a human chose, what
> it says was skipped, and why — no more. It supports no claim of authorization or review,
> and satisfies no evidence obligation. It exists because an exception nobody wrote down is
> invisible, not because writing it down makes it sound.
```

It goes into `CLAUDE.md` § Mechanics immediately after the closing-message rule at
`:413`, as a list item at that section's indentation.

- [ ] **Step 2: Make the identical edit in the mirror**

Same text at `workflow-init.md:603`, flush-left inside the fence, matching the surrounding
list indentation of the template's Mechanics section.

- [ ] **Step 3: Verify parity**

Extract the block from both files and diff them. They must be identical apart from the
template's list indentation. Record the result — nothing checks it.

- [ ] **Step 4: Run the full battery**

Run: the `AGENTS.md` § Commands quality command.
Expected: green. What that establishes is only what those checks compare — shellcheck, the two
hook suites, the invariant checks including 4c's duplicate and placement counts, the version
check, and `claude plugin validate`. It establishes **nothing** about this paragraph, which no mechanical
check reads; that is the 12-item review's job (Task 5 Step 5) and Gate B's.

- [ ] **Step 5: Fold into the WIP snapshot**

```bash
git add CLAUDE.md plugins/dev-workflow/commands/workflow-init.md
git commit --amend --no-edit
```

What this task's share of the closing message must cover: the record form, for a decision about
work no applicable rule required; that it records a decision and authorizes none — never a
gate, a floor, a pass count, an evidence obligation, or any mandatory rule from anywhere; that
the record is an unverified assertion and the shipped text says so; and that the two edited
regions were diffed and matched. **Not** that it closes the story's remaining scope — rider
(c), the backlog, the release metadata and Gate B are all still ahead, and only the final
closing commit can say the cycle is done.

### Task 3: Rider (c) — the squash-merge carry sentence

**Files:**
- Modify: `CLAUDE.md` — § Mechanics, beside the closing-message rule at `:413`
- Modify: `plugins/dev-workflow/commands/workflow-init.md` — same place, at `:603`

**Interfaces:**
- Consumes: Task 2's record form (the sentence names it).
- Produces: nothing.

- [ ] **Step 1: Add the sentence to both copies**

**One line, copied byte-for-byte from spec §3** — the spec pins it as a single source
line, so wrapping it here would break the equality it is pinned for:

```markdown
> **On squash-merge, copy every evidence entry and every human-exception record in the squash range into the squash body — the squash commit is the only body the merge carries into `main`'s history, so anything left behind is unreachable from it.**
```

Place it immediately after the existing closing-message rule, before Task 2's paragraph, so the
evidence entry and the record are described in the order they are written.

- [ ] **Step 2: Verify parity, run the battery, fold into the WIP snapshot**

Diff the sentence between the two copies; run the `AGENTS.md` § Commands battery; then:

```bash
git add CLAUDE.md plugins/dev-workflow/commands/workflow-init.md
git commit --amend --no-edit
```

Closing-message share: `main`'s tip is the durable record, so a squash that drops the evidence
entry or a human-exception record drops it from `main`'s history; the sentence says which
artifacts and which range; nothing enforces it.

### Task 4: Backlog

**Files:**
- Modify: `todos.md` — the compound-commands row; `unverified-enforcement-claim` at `:90`;
  `prompt-vague-criteria` at `:103`; **six** new rows (Step 3's parked items) and **one amended**
  (the slot-collision row, which already exists — Step 4)

**`docs/hardening-log.md` is NOT in this task.** An earlier draft staged it with no row
specified, which is not executable. Spec §6 requires no ledger append: the ledger records
*findings that recurred and were hardened a rung*, and nothing here is one — 4c is a new check
for a new rule, not an escalation of a repeat finding. If Gate B disagrees, the row is written
then, against a named recurrence.

**Interfaces:** none.

- [ ] **Step 1: Edit the compound-commands row in place**

`todos.md` is edited in place — append-only-never-edit is `docs/hardening-log.md`'s rule, not
this file's. Add occurrence 3: `git add` and `git commit` in one Bash call, empty staged set at
`PreToolUse`, loose STOP; observed on PR #23's close. Same shape as occurrence 2 and, like it,
a **false positive**.

- [ ] **Step 2: Close one fingerprint, re-point another**

`prompt-vague-criteria` (`:103`) **closes** — rider (b) states the enum rather than exemplifying
it, which is what that row asked for. `unverified-enforcement-claim` (`:90`) **stays open**,
re-pointed at `docs/superpowers/stories/2026-08-14-sequential-branch-calls-hook-story.md`.

- [ ] **Step 3: Add all six parked rows from spec §6**

**Copy each row's full text from spec §6, not a summary.** An earlier draft of this plan
compressed them — the external-authority row lost its trusted-signer, role-policy and
independent-availability-attestation requirements and its "one untried direction, not the only
one that could work" calibration, which are the whole content of that row. Extract each bullet
from the spec and fit it to `todos.md`'s row format without dropping a clause. The six, by
their spec headings:

1. **Attribution for the shipped record form.** *Trigger: the first record whose authorship is
   disputed or unattributable.*
2. **External-authority zero-pass research.** *Trigger: a renewed need to close a gate cycle
   with no review — a second multi-day reviewer outage, or the operational bridges of the
   design's §7 proving unavailable.*
3. **Tracked re-review debt.** *Trigger: a human explicitly asks for follow-up review on a
   recorded exception and that follow-up is later found not to have happened.*
4. **A recording mechanism for severity normalization.** *Trigger: a pass is normalized and the
   drift goes unnoticed in review.*
5. **The hook's `is_docs_only` breadth** — it exempts any `.md` path outside a prompt directory,
   broader than §5's prose list. *Trigger: a root `.md` file acquiring gate-relevant state.*
6. **Tier-2 counting and containment**, pointing at
   `docs/superpowers/stories/2026-08-14-tier-2-same-family-reviewer-story.md`.

- [ ] **Step 4: Amend the slot-collision row — it already exists**

**Do not create one.** `todos.md` already carries this item, with its history (the
result-classification cycle's pass-1 call deleting the 2026-07-26 profiles cycle's
its pass-1 findings file), a *NOT FIRED (2026-08-04)* note, and the trigger *"the next round
touching the §5 file protocol."* An earlier draft of this plan said to create it, which would
have split one concern across two rows and discarded that history.

**Amend it in place, recording TRIGGER FIRED.** Spec §6 settles this: *trigger fired, row stays
open*. Do not re-open that as a judgement — an earlier draft of this plan did, with a
*NOT FIRED* rationale that was also wrong on its facts, since Task 1 adds the severity reader
rule **to the pass-acceptance area** of §5.

Record: this story's cycles destroyed a predecessor's findings file **and** its dispositions
before the surviving artifacts were archived by hand — a second observed occurrence, after the
2026-07-26 profiles cycle. The row stays open; the fix is still naming or archiving, never
relaxing the pre-call delete.

- [ ] **Step 5: Fold into the WIP snapshot**

```bash
git add todos.md
git commit --amend --no-edit
```

Closing-message share: the six new backlog rows with their triggers, the slot-collision row
amended with its second occurrence, `prompt-vague-criteria`
closed, `unverified-enforcement-claim` re-pointed at the sequential-branch-calls hook story, and
occurrence 3 on the compound-commands row.

### Task 5: Changelog, and the closing checks

The manifest bump landed in Task 1's snapshot (invariant 12 wants it in the first commit
carrying plugin changes). What is left here is the entry that describes everything, plus the
two obligations that can only run once the change is complete.

**Files:**
- Modify: `plugins/dev-workflow/CHANGELOG.md` — new entry at the top

**Interfaces:**
- Consumes: nothing. The WIP parent is **derived locally** in each step that needs it, with
  the guard shown there — never carried from Task 1.

- [ ] **Step 1: Write the changelog entry**

Newest first, no date — the file says versions are recorded, not release dates, and inventing
one would be fiction. Written from `git log` over `plugins/`, not from memory: read the WIP
snapshot's diff. Cover the closed severity enum and its case-insensitive reader, check 4c, the
human-exception record form, rider (c), and that the **zero-pass gate closure the story began
as was withdrawn**, with the finding recorded in the design's §1 and shipped as `c0a6ed2`.

- [ ] **Step 2: Fold into the WIP snapshot**

```bash
git add plugins/dev-workflow/CHANGELOG.md
git commit --amend --no-edit
```

- [ ] **Step 3: Verify the bump against a base that can decide**

```bash
# Self-contained: derive the parent here. A shell variable does not survive between tool
# calls or a resumed session, and the guard is what makes re-deriving safe -- it refuses
# to run once the cycle has closed and HEAD is no longer the WIP snapshot.
git log -1 --format=%s | grep -q '^WIP:' || { echo "HEAD is not the WIP snapshot"; exit 1; }
WIP_PARENT=$(git rev-parse HEAD^) || exit 1
git diff --quiet "$WIP_PARENT" HEAD -- plugins/ \
  && { echo "VOID: no plugin changes in range"; exit 1; }
sh scripts/check-version-bump.sh "$WIP_PARENT"
```

**Not `main`.** From `main` the merge-base is HEAD, the range is empty, and the checker passes
without comparing anything — the plan would be citing a run that decided nothing. The
non-empty-range guard is what turns that from a silent pass into a VOID.

- [ ] **Step 4: Run the full battery**

Run: the `AGENTS.md` § Commands quality command. Expected: green, on the complete change.

- [ ] **Step 5: The prompt-standards review — the obligation no check covers**

`AGENTS.md` invariant 11 requires all 12 items of `docs/prompt-standards.md` for every changed
prompt artifact, and says in terms that `scripts/check-invariants.sh` is a **floor, not
coverage**. A green battery therefore establishes nothing about the reader rule, the record
form or the carry sentence.

Go through all 12 items, in order, for **each** changed prompt copy — `CLAUDE.md` and
`plugins/dev-workflow/commands/workflow-init.md` — and record the result by name in the closing
commit body. This is a person reading a checklist. Nothing enforces it, and it is owed anyway.

Closing-message share: the 0.9.0 bump and its CHANGELOG entry; the version check's result
against `WIP_PARENT`; the battery; the counterfactual; the parity results from Tasks 1–3; and
the 12-item review, named per copy.

## Gate B

**One cycle, one WIP commit, closed once.** `CLAUDE.md` and everything under `plugins/` are
product, so no path here is prose-exempt and the triviality skip does not apply.

- **`baseSha`** = the WIP commit's parent. `reviewType: full`.
- **Carry, in `additionalContext`:** the story path
  `docs/superpowers/stories/2026-08-13-reviewer-availability-fallback-story.md` and the current
  evidence entry quoted verbatim. Read the profile from that header, not from this plan.
- **After every Gate-B fix, before re-reviewing:** stage the complete intended diff and
  `git commit --amend --no-edit` it into the still-`WIP` snapshot; re-run the battery and the
  counterfactual; re-run parity and the 12-item prompt review if prompt text changed; then
  re-review with the **unchanged** WIP parent as `baseSha`. Re-run the **complete self-contained block from Task 5 Step 3** — guard, derivation,
  non-empty-range check, checker — in **every** iteration and once immediately before the
  closing amend — a fix can change plugin content or lose the manifest bump, and the
  battery's own `main` argument is an empty range on this branch, so it would not notice. `mcp__codex__review` reads a git
  range, so a fix left in the worktree is invisible to it — the re-review would return a clean
  pass over stale content, which is the one failure mode a clean pass cannot be distinguished
  from. Revalidate the evidence entry each time; a fix changes the diff.
- **Close** with `git commit --amend -m "<real message>"` carrying the validated entry and the
  five tasks' message shares.

**Evidence owed — `battery+check`:**

- **Battery** — the `AGENTS.md` § Commands quality command, green on the complete change.
- **The check that fails without the change** — 4c. Counterfactual, isolated so the failure has
  exactly one cause:

  ```bash
  set -e
  TMP=$(mktemp -d); [ -n "$TMP" ] && [ -d "$TMP" ]
  trap 'rm -rf "$TMP"' EXIT HUP INT TERM
  git ls-files -z \
    | xargs -0 -I{} sh -c 'mkdir -p "$0/$(dirname "{}")" && cp "{}" "$0/{}"' "$TMP/repo"
  ( cd "$TMP/repo" && sh scripts/check-invariants.sh ) \
    || { echo "VOID: baseline not green"; exit 1; }
  git show df850ab:CLAUDE.md > "$TMP/repo/CLAUDE.md"
  git show df850ab:plugins/dev-workflow/commands/workflow-init.md \
    > "$TMP/repo/plugins/dev-workflow/commands/workflow-init.md"
  set +e
  out=$( cd "$TMP/repo" && sh scripts/check-invariants.sh 2>&1 ); st=$?
  [ "$st" -ne 0 ] || { echo "VOID: mutant still green"; exit 1; }
  sev=$(printf '%s\n' "$out" | grep -c 'closed severity set')
  all=$(printf '%s\n' "$out" | grep -cE '^(Invariant|Prompt standards)')
  [ "$sev" -gt 0 ]        || { echo "VOID: no 4c diagnostic"; exit 1; }
  [ "$sev" -eq "$all" ]   || { echo "VOID: $((all - sev)) other diagnostic(s) present"; exit 1; }
  echo "counterfactual OK — baseline 0, mutant $st, $sev 4c diagnostic(s) and nothing else"
  ```

  Required: baseline **exit 0**, mutant **exit 1** carrying the 4c diagnostic (`closed severity
  set`) **and no other diagnostic**. 4c ships inside the full checker, so a bare two-file tree
  would fail unrelated invariants and prove nothing — the isolation is what makes this evidence
  rather than an assertion.

- **The prompt-standards review** (Task 5 Step 5) is named in the entry too. It satisfies no
  part of `battery+check`; it is invariant 11's own obligation, and it is recorded so a reader
  can see it was done rather than assumed.

**What the evidence does not establish:** that a reader applies the reader rule, that the record
form is used correctly, or that the carry happens. Those are behaviour, and nothing here
observes them. Say so in the entry rather than letting a green battery imply otherwise.

**Lens sets:** none — risk `standard`, security `none`.

**The standing falsification lens still applies.** Name what this change alters the size, value
or position of, then grep for where each is described elsewhere: the checker's check count
(`scripts/check-invariants.sh:24`, `:261`; `AGENTS.md` invariant 11), the mutation evidence's
flip counts (`scripts/check-invariants.test.sh:325`), the manifest version, and the command file's
`### 2.1` scaffold heading — 4c's placement rule anchors on it and on the next **numbered**
`### `. Renaming or renumbering that heading fails the check loudly, which is intended; the
template's own unnumbered `### Profiles` and `### Mechanics` do not affect it.

## Self-review

**Spec §4 path table — all ten rows, individually.** Two are **already satisfied** by commit
`c0a6ed2` and belong to no task here: the parent story and the tier-2 story, both amended when
the closure landed. Verify that before starting rather than assuming it — `git show --stat
c0a6ed2`. The remaining eight map as: `CLAUDE.md` → Tasks 1–3 ·
`plugins/dev-workflow/commands/workflow-init.md` → Tasks 1–3 ·
`scripts/check-invariants.sh` → Task 1 · `scripts/check-invariants.test.sh` → Task 1 ·
`AGENTS.md` → Task 1 · `plugins/dev-workflow/.claude-plugin/plugin.json` → **Task 1** (the bump
moved there so the first plugin-carrying commit contains it) ·
`plugins/dev-workflow/CHANGELOG.md` → Task 5 · `todos.md` → Task 4. An earlier draft claimed
"all ten appear across Tasks 1–5", which was false and hid the line between landed closure work
and remaining salvage work.

**Other spec coverage.** §2.1 → Task 2 (byte-for-byte). §3 rider (b) → Task 1, rider (c) → Task
3 (byte-for-byte). §5.2 assertion and fixtures → Task 1. §5.3 parity → Global Constraints plus
each prose task's diff step. §6 → **all ten bullets**, mapped individually: the six parked rows and the slot-collision row
to Task 4 Steps 3–4; the `prompt-vague-criteria` / `unverified-enforcement-claim` bullet to Task
4 Step 2; the compound-commands bullet to Task 4 Step 1; and the version-and-CHANGELOG bullet
split across Task 1 (the bump) and Task 5 (the entry). An earlier draft said nine. §1 needs no task; it is the closure
record and shipped with `c0a6ed2`.

**Placeholders.** None. Every edit carries its exact text or exact shell, and the two verbatim
blocks were extracted from the spec programmatically rather than retyped — an earlier draft
paraphrased §2.1's limiting clauses while claiming to be verbatim.

**Type consistency, read off the built code rather than remembered.** The checker holds
`SEV_CANON`; the suite holds `SEV_LINE`; same literal. The function is
`severity_rule_scan <file>` — one argument — and it prints four space-separated fields:
whole-file count, in-template count, `### 2.1` anchor count, and the terminator's number or
`none`. The caller splits them with `set --` and branches on each: awk status, whole count,
anchor count, terminator identity, in-template count. The `inject_case` seam keys on the
`sev-canon-count` marker comment.

**Branch coverage.** Every branch has a fixture: missing file, unreadable file (skipped as
root), parser failure, wrong whole-file count, missing anchor, duplicate anchor, wrong
terminator, absent terminator, and line-outside-template. Nothing is reviewed-but-untested.

**One fixture deliberately dropped:** missing-template. Check 4b reads that path, so its
absence fails 4b first and the case could never be isolated to 4c. The missing-`CLAUDE.md`
case covers the same branch and *is* isolated.

**Mutation numbers are measured, never carried forward.** 4c read 13, then 16, then **19** as
fixtures were added; only the last was ever true of the suite that shipped. Each superseded
number was replaced by re-running.
