# Intake amendment route: falsified files count as dependent artifacts — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Sharpen the `Dependent artifacts` field of the intake amendment route's change record so that a file the change makes false (an open question now answered, a status now outdated) counts as a dependent artifact, not only a file whose requirements change.

**Architecture:** This is a prompt-only change to one skill file,
`plugins/dev-workflow/skills/intake/SKILL.md`: the field's template line, one new
definition paragraph under "The change record", the step-6 sentence that currently ties
"dependent" to a changed story, and one Common-mistakes clause. A patch version bump and a
CHANGELOG entry follow from invariant 12. No script, hook or template elsewhere changes,
unless the sweep in Task 1 finds a copy of the field or a mechanical check that pins it.

**Tech Stack:** Markdown prompt artifacts. POSIX-sh quality battery (shellcheck, dash,
`claude plugin validate`). Codex MCP for Gate B.

**Spec:** `TASK.md` together with `inputs/task-backlog-entry.md`. `TASK.md` says to treat
both as the approved spec. The plan cites no story, so there is no `Story:` header here, on
purpose: per `.claude/review-gates.md` (Profiles, case 1), an artifact that cites no story
runs unprofiled at floor 3 and must say so in each pass. See open question Q2.

## Open questions for Daniel (please answer before execution)

- **Q1 — Can a spec amendment edit a story that the change makes false?** Step 6 currently
  says: "A spec amendment edits a story only when the decision changes that story, which
  then is a dependent artifact." This plan reads "changes that story" as covering a
  statement in the story that the decision makes false. In the pilot case, that is the
  story's §5 still calling the decided question open. The story is then a dependent artifact
  and may be `updated in this change` (Task 1, Step 4 text). The alternative is narrower: a
  falsified story is dependent, but its only allowed statuses are `open — permitted by
  <rule>` or `blocks … until updated`, because an approved story changes only through its
  own amendment. **Recommendation: the reading this plan uses.** The backlog entry treats
  the stale §5 as the defect to prevent, and forbidding the fix would only turn the defect
  into a blocker.
- **Q2 — A separate story first?** The backlog entry says "needs its own story". `TASK.md`
  designates itself and the backlog entry as the approved spec. **This plan follows
  `TASK.md` and writes no story.** If you want one, run `dev-workflow:intake` on the backlog
  entry first and add its path as this plan's `**Story:**` header. A story would change the
  gate floor and the evidence obligations.
- **Q3 — Close out the ledger and the backlog?** The entry is "pending in
  `docs/hardening-log.md`" and comes from `todos.md`. Neither file exists in this fixture,
  and `TASK.md` does not mention them. **Default: out of scope.** If you want them in scope,
  Task 2 gains a step: append the resolution row via `dev-workflow:harden-finding` and
  remove the `todos.md` line.

## Global Constraints

- Execute in the full `dev-workflow-kit` checkout. This fixture directory contains only
  `AGENTS.md`, `CLAUDE.md`, `.claude/review-gates.md`, `TASK.md`, `inputs/` and the intake
  `SKILL.md`. `plugin.json`, `CHANGELOG.md`, `scripts/` and `docs/` are absent here.
- Invariant 11: the changed prompt passes all 12 items of `docs/prompt-standards.md`.
- Invariant 12: the PR changes `plugins/dev-workflow/.claude-plugin/plugin.json` `version`.
- Invariant 10: no project vocabulary goes into the skill. Examples stay generic.
- `source-files/` is never edited.
- Commits carry **no** `Co-Authored-By: Claude` or `Generated with` trailer (AGENTS.md
  Don'ts). This takes precedence over the harness's attribution reminder.
- Stage by explicit path, never `git add -A`.
- Gate B is mandatory: every path is under `plugins/`, so it is not prose
  (`.claude/review-gates.md`, "What counts as prose"). Read `.claude/review-gates.md` in
  full before the Gate B pass and before any commit (CLAUDE.md §5).
- The chosen wording is a design decision made in this plan, not text quoted from the spec.

## Review Focus

Ranked by how likely each is to bite someone writing a change record. All five are pinned
by the scenario check in Task 1 (assertions A–E):

1. **The pilot case.** The decision answers a question that a story's §5 lists as open, and
   none of the story's criteria change. The story must appear under *Dependent artifacts*,
   not `none`. (A)
2. **An outdated status.** A plan whose header says it is blocked on the now-taken decision
   must appear under *Dependent artifacts*. (B)
3. **Over-inclusion.** A file that only mentions the topic and states nothing the change
   makes false must **not** be listed. The sharpening must not turn the field into "every
   file that mentions the topic". (C)
4. **Status from the closed set.** Each listed file carries exactly one of the three closed
   statuses, and nothing made up such as "needs update". (D)
5. **The changed artifact itself** is not listed as its own dependent. (E)

---

### Task 1: Sharpen the field in the intake skill

**Files:**
- Modify: `plugins/dev-workflow/skills/intake/SKILL.md`. The sites are line 400 (field),
  lines 405–410 (closed sets, a new paragraph goes after them), lines 361–363 (step 6, last
  sentence) and lines 485–486 (last Common-mistakes bullet).
- Test: a scenario check run by a fresh subagent. It writes nothing in the repo. Scratch
  files go under `"$TMPDIR/intake-dep-check/"`.

**Interfaces:**
- Consumes: nothing.
- Produces: the paragraph heading `**Dependent artifacts — the test.**`. Task 1 Step 4
  cites it by that name from step 6, so keep the exact string.

- [ ] **Step 1: Sweep for every other statement of the field, and for a mechanical pin on it**

Run in the full checkout:

```bash
grep -rniE 'dependent[- ]artifact' --include='*.md' --include='*.sh' . | grep -vE 'source-files/|docs/superpowers/'
grep -n -iE 'dependent|change record|closed set' scripts/check-invariants.sh scripts/check-invariants.test.sh
```

Expected: hits only in `plugins/dev-workflow/skills/intake/SKILL.md`. Also check whether
`check-invariants.sh` pins the change-record template; AGENTS.md invariant 11 says one of
its checks covers "the `intake` amendment route's change-record template and its closed
sets". What to do with the results:
- A copy of the field elsewhere (for example `skills/sparring/SKILL.md`, which drafts
  records): apply the same edits there in this task and add the file to Step 7's
  `git add`.
- A check that matches the exact line `- **Dependent artifacts:** <path> → <status>; or
  none.`: update the check's expected string to the Step 4 line and add the
  reject/accept pair to `scripts/check-invariants.test.sh` in the existing style.
- Anything not covered by those two cases: stop and ask Daniel.

- [ ] **Step 2: Write the scenario fixture (the failing test)**

Create `"$TMPDIR/intake-dep-check/scenario.md"` with exactly:

```markdown
You are writing the change record for an amendment under the intake skill's amendment route.
Use only the skill text given below. Output ONLY the record's `- **Dependent artifacts:** …` line.

Changed artifact: docs/superpowers/specs/2026-09-30-export-spec.md (a spec).
Decision: Daniel, PR #12 review thread, 2026-10-01: "Exports stay CSV only; XLSX is out."
The spec's export-format section is rewritten accordingly.

Other files in the repository:
1. docs/superpowers/stories/2026-09-20-export-story.md — the spec's `Story:` header cites it.
   §3: AC-1 an export button on the report page; AC-2 the CSV carries the columns shown;
   AC-3 the file is named after the report. None of these change.
   §5 Open questions: "- Should XLSX be offered as well? Decide before the spec is approved."
2. docs/superpowers/plans/2026-09-25-export-plan.md — header line:
   "Status: blocked until the XLSX question is decided."
3. README.md — "Reports can be exported from the report page."
```

Then the assertions in `"$TMPDIR/intake-dep-check/expected.md"`:

```markdown
A. The story path is listed.
B. The plan path is listed.
C. README.md is not listed.
D. Every listed path carries exactly one of: `updated in this change` · `open — permitted by <rule>` · `blocks <named continuation> until updated`.
E. The spec path itself is not listed.
```

- [ ] **Step 3: Run the scenario against the current text and record the baseline**

Dispatch a fresh general-purpose subagent with the contents of `scenario.md`, followed by
lines 305–430 of the **unchanged** `SKILL.md` (`sed -n '305,430p'
plugins/dev-workflow/skills/intake/SKILL.md`). Do not include `expected.md`. Score the
returned line against A–E.

Expected: A or B fails, most likely as `none` or with only the plan listed. Record the
observed line verbatim. If the current text already passes A–E, the scenario cannot tell
the old text from the new. Stop and report that to Daniel instead of continuing, because
the change would have no check that fails without it.

- [ ] **Step 4: Apply the four edits**

(a) Replace line 400:

```markdown
- **Dependent artifacts:** <path> → <status>; or none.
```

with:

```markdown
- **Dependent artifacts:** <path> → <status>, for each file whose requirements the change alters or in which it makes a statement false; or none.
```

(b) Insert after the closed-sets list (after the `- **Dependent-artifact status**, …` line,
before `A narrowing usually carries several fates …`), with one blank line on each side:

```markdown
**Dependent artifacts — the test.** A file is dependent when the change alters what it
requires **or makes any statement in it false**: an open question the decision answers, a
status the change outdates, a sentence describing the condition as it stood. Unchanged
requirements do not make a file independent. Before writing `none`, read each file that
cites the changed artifact or states the decided question, and list every one this change
falsifies. A file that only mentions the subject and still says nothing false is not
dependent. The changed artifact itself is never its own dependent.
```

(c) In step 6, replace:

```markdown
   text until a decision covers it; the record names it under *Unaccounted*. A spec amendment
   edits a story only when the decision changes that story, which then is a dependent
   artifact.
```

with (per Q1):

```markdown
   text until a decision covers it; the record names it under *Unaccounted*. A spec amendment
   edits a story only when the decision changes that story — its requirements, or a
   statement in it the decision makes false — which then is a dependent artifact
   (*Dependent artifacts — the test*).
```

(d) Replace the last Common-mistakes bullet:

```markdown
- In an amendment: giving an undecided condition a fate instead of listing it under
  *Unaccounted*, or summarising what a gate rule decides instead of citing it.
```

with:

```markdown
- In an amendment: giving an undecided condition a fate instead of listing it under
  *Unaccounted*, summarising what a gate rule decides instead of citing it, or writing
  *Dependent artifacts: none* because no other file's requirements changed while one still
  states what the change made false.
```

- [ ] **Step 5: Re-run the scenario against the new text**

Use the same dispatch as Step 3, with a fresh subagent each time, but take the lines from
the **edited** file. The section grew by about 9 lines, so pass `sed -n '305,440p'`. Run it
twice, because one sampled answer is weak evidence.

Expected: both runs pass A–E. If either fails, revise the Step 4(b) paragraph and re-run.
Do not tune `scenario.md` to the wording.

- [ ] **Step 6: Prompt-standards and falsification read**

Walk the edited sections through all 12 items of `docs/prompt-standards.md` and note any
item that fails, then fix it. Then grep for what this diff moves or changes. The field
line's wording changes, and line numbers after line 400 shift:

```bash
grep -rnE 'SKILL\.md:(3[6-9][0-9]|4[0-9][0-9])|intake.*line [0-9]' --include='*.md' --include='*.sh' . | grep -vE 'source-files/|docs/superpowers/'
```

Expected: no line-number citations into the shifted range. Update any you find.

- [ ] **Step 7: Run the invariant checks**

Run: `sh scripts/check-invariants.test.sh && sh scripts/check-invariants.sh`
Expected: exit 0. Do not commit yet. The commit happens in Task 2, after Gate B.

### Task 2: Version bump, battery, Gate B, commit

**Files:**
- Modify: `plugins/dev-workflow/.claude-plugin/plugin.json` (`version` only)
- Modify: `plugins/dev-workflow/CHANGELOG.md` (new top entry)

**Interfaces:**
- Consumes: Task 1's edited `SKILL.md`, plus any copies or check updates from Task 1 Step 1.
- Produces: one commit on a feature branch, which is the input to the PR.

- [ ] **Step 1: Branch**

```bash
git switch -c intake-dependent-artifacts-falsified
```

- [ ] **Step 2: Bump the version**

Read the current value with `jq -r .version plugins/dev-workflow/.claude-plugin/plugin.json`
and increment the **patch** component. This is a choice: the change sharpens one field's
definition and adds no field, status or step. If `CHANGELOG.md`'s recent entries show a
different convention for prompt-wording changes, follow it and say so in the commit body.
Edit only the `"version"` value.

- [ ] **Step 3: Add the CHANGELOG entry**

At the top, in the format of the existing entries (copy the heading and date style of the
newest one), with `<new version>` set to the Step 2 value:

```markdown
## <new version> — 2026-10-06

- `intake` amendment route: a file the change makes false — an open question now answered,
  a status now outdated — now counts as a *Dependent artifact*, not only a file whose
  requirements change. New paragraph "Dependent artifacts — the test" under "The change
  record"; step 6 and Common mistakes aligned.
```

- [ ] **Step 4: Run the quality battery, excluding the version-bump check, which needs a commit**

Run the AGENTS.md § Commands **quality** row in full.
Expected: exit 0, except that `sh scripts/check-version-bump.sh main` reports clean before
the commit. That is expected (AGENTS.md: "Run mid-loop with the plugin edits still in the
working tree, it reports clean — correctly, and uselessly").

- [ ] **Step 5: WIP commit, then the version-bump check**

```bash
git add plugins/dev-workflow/skills/intake/SKILL.md plugins/dev-workflow/.claude-plugin/plugin.json plugins/dev-workflow/CHANGELOG.md
git diff --cached --name-only
git commit -m "WIP: intake dependent artifacts include falsified files"
sh scripts/check-version-bump.test.sh && sh scripts/check-version-bump.sh main
```

Add any extra files from Task 1 Step 1 to the `git add`. Expected: the staged list is
exactly those paths, and the version-bump check exits 0.

- [ ] **Step 6: Gate B**

Read `.claude/review-gates.md` in full first, and follow it rather than this summary. The
facts specific to this change:
- `mcp__codex__review` with `reviewType: full` and `baseSha` = `git merge-base main HEAD`.
- No cited story: run unprofiled, say so in each pass, floor 3.
- The coverage line goes in `additionalContext`.
- The standing lens: "which existing statements does this diff falsify?" The values this
  diff changes are the field line's wording, the plugin version, and the line positions
  after `SKILL.md:400`.
- Hand the reviewer `TASK.md` and `inputs/task-backlog-entry.md` as the spec, plus Q1's
  answer.

Fold every fix into the WIP commit by amend, then re-run the battery and re-review.

- [ ] **Step 7: Closing commit**

Once the cycle closes as the gate rules define it, reword the WIP commit:

```bash
git commit --amend -m "fix(intake): count files a change falsifies as dependent artifacts

A change record listed 'Dependent artifacts: none' because no other file's
requirements changed, while the cited story's §5 still called the decided
question open. The field now covers files the change makes false.
Spec: TASK.md, inputs/task-backlog-entry.md. Bumps dev-workflow to <new version>."
```

Replace `<new version>` with the Step 2 value. Add the provenance and evidence lines that
`.claude/review-gates.md` requires for this cycle. Add no attribution trailer. Expected:
`git log -1` shows the message, and `git status --short` lists nothing staged or modified
under `plugins/` or `scripts/`.

## Self-review notes

- Spec coverage: the field is sharpened (Task 1 Step 4a/4b). "An open question now
  answered" and "a status now outdated" both appear in the 4b paragraph and are pinned by
  assertions A and B. Invariant 11 is covered in Task 1 Step 6, and invariant 12 in Task 2
  Steps 2 and 5.
- The `<new version>` and `<rule>` tokens are filled at execution from a named source
  (Step 2, or the existing closed-set syntax). They are not open design.
