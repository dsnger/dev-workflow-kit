# Set 1 — per-run evidence (skill at cb134cc, sha256 c6ca7ba2c0152e87ea210992d871036eb365d1d262ead4427affd8e68a6de396)

Per run: commit, files changed against the fixture commit `e2f55ca`, the story diff (which holds the change record), and the final result message. Run metrics are in `metrics.md`.

## D run 1

### Commits

````text
f586d4a docs(intake): amend export-job story — add CSV export (AC-5)
Changed requirement decided by Daniel in chat on 2026-10-10:
"add CSV to the export story". AC-1..AC-4 kept unchanged.

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>

````

### Files changed vs fixture

````text
 .../stories/2026-10-01-export-job-story.md           | 20 ++++++++++++++++++++
 1 file changed, 20 insertions(+)
````

### Story diff

````diff
diff --git a/docs/superpowers/stories/2026-10-01-export-job-story.md b/docs/superpowers/stories/2026-10-01-export-job-story.md
index 4250e32..2000201 100644
--- a/docs/superpowers/stories/2026-10-01-export-job-story.md
+++ b/docs/superpowers/stories/2026-10-01-export-job-story.md
@@ -15,6 +15,26 @@ _IDs are permanent once the story is committed: never renumber or reuse one; a n
 - [ ] **AC-2** When the export finishes, the customer is notified by e-mail and by an in-app notice.
 - [ ] **AC-3** The customer never receives a partial file; a failed export publishes nothing and shows the failure on the account page.
 - [ ] **AC-4** Export files are stored only in the EU bucket.
+- [ ] **AC-5** A customer can request an export of their account data as a CSV file, in addition to the XLSX file of AC-1.
+
+**Changed 2026-10-10 — changed requirement.** Decided by Daniel, in chat on 2026-10-10: "add CSV to the export story". Baseline: e2f55ca. Exports are offered as CSV as well as XLSX; XLSX stays.
+
+| Earlier condition | Fate | AC operation |
+|---|---|---|
+| AC-1: export as an XLSX file from the account page | kept | none |
+| AC-2: notification by e-mail and in-app notice on completion | kept | none |
+| AC-3: no partial file; a failed export publishes nothing and shows the failure | kept | none |
+| AC-4: export files stored only in the EU bucket | kept | none |
+| §2: "A customer can request an export of their account data and receives a complete file without contacting support." | kept | none |
+| §2: "Scheduled (recurring) exports are out of scope for this story." | kept | none |
+
+- **Added without an earlier condition:** AC-5: "A customer can request an export of their account data as a CSV file, in addition to the XLSX file of AC-1." → per the decision: "add CSV to the export story"
+- **Unaccounted:** none.
+- **Intervening changes:** none — the story is unchanged since e2f55ca.
+- **Scope boundary:** in: CSV as an additional export format; out: replacing or removing XLSX, scheduled (recurring) exports.
+- **Open questions:** none.
+- **Dependent artifacts:** none — no spec or plan cites this story.
+- **Reviews already run:** none on record for this story; checked `.claude/review-gates.md` (its only paragraph, "What counts as prose") and the repository history (single commit e2f55ca).
 
 ## 4. Affected AGENTS.md invariants
 - `## Key invariants` — "**A customer never receives a partial file.** A file is published to the customer only after the worker has written it completely; a failed job publishes nothing."
````

### Final result message

````text
I added CSV to the existing export story instead of starting a new one, and committed it as `f586d4a`. Daniel's decision was to change a story that's already approved (`docs/superpowers/stories/2026-10-01-export-job-story.md`), so I used intake's amendment route: no question round and no new file.

**What changed:**
- **New criterion AC-5:** "A customer can request an export of their account data as a CSV file, in addition to the XLSX file of AC-1."
- **A change record at the end of §3.** It names the decision (Daniel, in chat, 2026-10-10: "add CSV to the export story") and measures the change against `e2f55ca`, the commit where the story was approved.
- **Every earlier condition is kept as written:** AC-1 to AC-4, the outcome sentence, and "scheduled exports are out of scope".
- **Nothing is left unaccounted for**, no specs or plans depend on the story, and I found no earlier reviews of it.

**One wording choice to check:** "add" and your "also" read to me as CSV alongside XLSX, so AC-1 stays and XLSX is not replaced. I didn't repeat "from the account page" in AC-5, because the decision doesn't say where CSV is requested. If CSV should replace XLSX, or should be requested from the account page too, that's a new decision and needs another amendment.

**Commit:** The commit contains only the story file. The project's gate rules count `docs/**.md` changes as prose, so this commit needed no review gate.

**What's next:** Design work on the export story (brainstorming → spec → plan) can now include CSV. Nothing is blocked. I haven't started the next step; that's yours to kick off.
````

## D run 2

### Commits

````text
c1c3f49 docs(intake): amend export-job story — add CSV export (AC-5)
Changed requirement decided by Daniel in chat on 2026-10-10:
"add CSV to the export story".

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>

````

### Files changed vs fixture

````text
 .../stories/2026-10-01-export-job-story.md           | 20 +++++++++++++++++++-
 1 file changed, 19 insertions(+), 1 deletion(-)
````

### Story diff

````diff
diff --git a/docs/superpowers/stories/2026-10-01-export-job-story.md b/docs/superpowers/stories/2026-10-01-export-job-story.md
index 4250e32..0d9d94c 100644
--- a/docs/superpowers/stories/2026-10-01-export-job-story.md
+++ b/docs/superpowers/stories/2026-10-01-export-job-story.md
@@ -15,13 +15,31 @@ _IDs are permanent once the story is committed: never renumber or reuse one; a n
 - [ ] **AC-2** When the export finishes, the customer is notified by e-mail and by an in-app notice.
 - [ ] **AC-3** The customer never receives a partial file; a failed export publishes nothing and shows the failure on the account page.
 - [ ] **AC-4** Export files are stored only in the EU bucket.
+- [ ] **AC-5** A customer can also request an export of their account data as a CSV file.
+
+**Changed 2026-10-10 — changed requirement.** Decided by Daniel, in chat on 2026-10-10: "add CSV to the export story". Baseline: e2f55ca. Exports are offered as CSV in addition to XLSX ("exports should also be offered as CSV").
+
+| Earlier condition | Fate | AC operation |
+|---|---|---|
+| §2: "A customer can request an export of their account data and receives a complete file without contacting support." | kept | none |
+| §2: "Scheduled (recurring) exports are out of scope for this story." | kept | none |
+| AC-1: export as an XLSX file from the account page | kept | none |
+| AC-2 – AC-4: completion notice, no partial file, EU bucket only | kept | none |
+
+- **Added without an earlier condition:** AC-5: "A customer can also request an export of their account data as a CSV file." → per the decision: "add CSV to the export story"
+- **Unaccounted:** none.
+- **Intervening changes:** none.
+- **Scope boundary:** in: CSV as an additional export format; out: any change to the XLSX export, scheduled (recurring) exports.
+- **Open questions:** whether a CSV export of account data that spans several tables reaches the customer as one file or several → story §5.
+- **Dependent artifacts:** none.
+- **Reviews already run:** none. The repo has no spec, plan or gate record for this story.
 
 ## 4. Affected AGENTS.md invariants
 - `## Key invariants` — "**A customer never receives a partial file.** A file is published to the customer only after the worker has written it completely; a failed job publishes nothing."
 - `## Key invariants` — "**Personal data stays in the EU region.** Export files are stored only in the EU bucket."
 
 ## 5. Open questions
-- None.
+- When the account data spans several tables, does a CSV export (AC-5) reach the customer as one file or several? §2 promises "a complete file". (Added 2026-10-10.)
 
 ## 6. Suggested size
 story — one coherent feature, one spec → plan → PR.
````

### Final result message

````text
I didn't write a new story. Daniel's decision ("add CSV to the export story") changes the export story you already approved, so I amended that file instead: `docs/superpowers/stories/2026-10-01-export-job-story.md`. It's committed as `c1c3f49` and contains only that one file.

**What changed:**
- **New AC-5:** "A customer can also request an export of their account data as a CSV file." I based it only on Daniel's words "add CSV to the export story" plus your "also offered as CSV", so it doesn't say where the customer requests the CSV. AC-1 says "from the account page"; AC-5 doesn't yet.
- **Unchanged:** the outcome in §2, "scheduled exports are out of scope", and AC-1 to AC-4 all stay as written. XLSX is still offered, and the no-partial-file and EU-bucket-only rules (both from AGENTS.md) still apply to every export.
- **Change record:** at the end of §3, comparing against the approved version at `e2f55ca`. Nothing is left unaccounted for, nothing changed since that version, and no spec, plan or earlier review depends on the story.
- **New open question in §5:** if the account data spans several tables, does the customer get one CSV file or several? §2 promises "a complete file".

**What happens next:**
- The story can go on to design (spec and plan) with AC-5 included.
- Before then, someone needs to answer the one-file-or-several question.
- The next design step uses `superpowers:brainstorming`, which isn't available in this session. You'll need to install the superpowers plugin before running it with this story as input. I haven't started any next step.
````

## D run 3

### Commits

````text
d70f861 docs(intake): amend export-job story — add CSV export (AC-5)
Changed requirement decided by Daniel in chat, 2026-10-10:
"add CSV to the export story". CSV is offered in addition to XLSX.

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>

````

### Files changed vs fixture

````text
 .../stories/2026-10-01-export-job-story.md           | 20 ++++++++++++++++++++
 1 file changed, 20 insertions(+)
````

### Story diff

````diff
diff --git a/docs/superpowers/stories/2026-10-01-export-job-story.md b/docs/superpowers/stories/2026-10-01-export-job-story.md
index 4250e32..cd3b646 100644
--- a/docs/superpowers/stories/2026-10-01-export-job-story.md
+++ b/docs/superpowers/stories/2026-10-01-export-job-story.md
@@ -15,6 +15,26 @@ _IDs are permanent once the story is committed: never renumber or reuse one; a n
 - [ ] **AC-2** When the export finishes, the customer is notified by e-mail and by an in-app notice.
 - [ ] **AC-3** The customer never receives a partial file; a failed export publishes nothing and shows the failure on the account page.
 - [ ] **AC-4** Export files are stored only in the EU bucket.
+- [ ] **AC-5** A customer can request an export of their account data as a CSV file.
+
+**Changed 2026-10-10 — changed requirement.** Decided by Daniel, in chat on 2026-10-10. Baseline: e2f55ca. CSV is offered in addition to XLSX, not instead of it.
+
+| Earlier condition | Fate | AC operation |
+|---|---|---|
+| AC-1: export as an XLSX file from the account page | kept | none |
+| AC-2: e-mail and in-app notice when the export finishes | kept | none |
+| AC-3: no partial file; a failed export publishes nothing and shows the failure | kept | none |
+| AC-4: export files stored only in the EU bucket | kept | none |
+| §2: "A customer can request an export of their account data and receives a complete file without contacting support." | kept | none |
+| §2: "Scheduled (recurring) exports are out of scope for this story." | kept | none |
+
+- **Added without an earlier condition:** AC-5: "A customer can request an export of their account data as a CSV file." → per the decision: "add CSV to the export story"; "exports should also be offered as CSV".
+- **Unaccounted:** none.
+- **Intervening changes:** none. The working copy equals the baseline.
+- **Scope boundary:** in: CSV as an additional export format; out: replacing or removing XLSX, and scheduled (recurring) exports, which remain out of scope.
+- **Open questions:** none.
+- **Dependent artifacts:** none. No spec or plan cites this story.
+- **Reviews already run:** none recorded. The repository history (one commit, e2f55ca) contains no gate record for this story, so no review cycle is affected.
 
 ## 4. Affected AGENTS.md invariants
 - `## Key invariants` — "**A customer never receives a partial file.** A file is published to the customer only after the worker has written it completely; a failed job publishes nothing."
````

### Final result message

````text
I added CSV to the existing export story instead of creating a new one, since Daniel's decision was "add CSV to the export story". It's committed as `d70f861`.

**What changed** in `docs/superpowers/stories/2026-10-01-export-job-story.md`:
- **New criterion:** **AC-5** "A customer can request an export of their account data as a CSV file." It adds to XLSX rather than replacing it, following your "also be offered as CSV".
- **Nothing else moved:** AC-1 to AC-4, the outcome sentence and the scheduled-exports exclusion all stay as they were. AC-3 (no partial file) and AC-4 (EU bucket only) are worded for any export file, so they cover CSV without changes.
- **Change record:** it sits at the end of §3 and lists every earlier condition with what happened to it. Nothing is left unaccounted for.
- **Wording I left out:** AC-5 doesn't say "from the account page", because the decision didn't say where CSV is requested. If CSV should be requested from the same place as XLSX, that needs a decision and another amendment.
- **Assumption:** I measured the change against `e2f55ca`, the only commit in the repo. I treated that as the approved version of the story, but its message is just "fixture", so it isn't a recorded approval. Tell me if a different version was the approved one.

**Review:** the commit only touches a `docs/**.md` file, so `.claude/review-gates.md` exempts it from Gate B. There are no spec, plan or recorded reviews that point at this story, so nothing else needed updating.

**What this unblocks:** the story, now with CSV in it, is ready for `superpowers:brainstorming`, or for the next step in your workflow if design has already started. Nothing is blocked, and I haven't started any of it.
````

## D run 4

### Commits

````text
cb1d7fa docs(intake): amend export-job story — add CSV export (AC-5)
Decided by Daniel in chat, 2026-10-10: "add CSV to the export story".

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>

````

### Files changed vs fixture

````text
 .../superpowers/stories/2026-10-01-export-job-story.md | 18 ++++++++++++++++++
 1 file changed, 18 insertions(+)
````

### Story diff

````diff
diff --git a/docs/superpowers/stories/2026-10-01-export-job-story.md b/docs/superpowers/stories/2026-10-01-export-job-story.md
index 4250e32..2f74204 100644
--- a/docs/superpowers/stories/2026-10-01-export-job-story.md
+++ b/docs/superpowers/stories/2026-10-01-export-job-story.md
@@ -15,6 +15,24 @@ _IDs are permanent once the story is committed: never renumber or reuse one; a n
 - [ ] **AC-2** When the export finishes, the customer is notified by e-mail and by an in-app notice.
 - [ ] **AC-3** The customer never receives a partial file; a failed export publishes nothing and shows the failure on the account page.
 - [ ] **AC-4** Export files are stored only in the EU bucket.
+- [ ] **AC-5** A customer can request an export of their account data as a CSV file from the account page.
+
+**Changed 2026-10-10 — changed requirement.** Decided by Daniel, in chat on 2026-10-10: "add CSV to the export story". Baseline: e2f55ca. CSV is offered in addition to XLSX; every existing condition stays, and AC-2–AC-4 already apply to any export file, CSV included.
+
+| Earlier condition | Fate | AC operation |
+|---|---|---|
+| AC-1: export as an XLSX file from the account page | kept | none |
+| AC-2–AC-4: notification, no partial file, EU bucket only | kept | none |
+| §2: "A customer can request an export of their account data and receives a complete file without contacting support." | kept | none |
+| §2: "Scheduled (recurring) exports are out of scope for this story." | kept | none |
+
+- **Added without an earlier condition:** AC-5: "A customer can request an export of their account data as a CSV file from the account page." → per the decision: "add CSV to the export story"
+- **Unaccounted:** none.
+- **Intervening changes:** none.
+- **Scope boundary:** in: CSV as an additional export format alongside XLSX; out: replacing XLSX, scheduled (recurring) exports.
+- **Open questions:** none.
+- **Dependent artifacts:** none.
+- **Reviews already run:** none — no spec, plan or gate record exists for this story (checked `docs/superpowers/` and git history), so `.claude/review-gates.md` has no review input to apply to.
 
 ## 4. Affected AGENTS.md invariants
 - `## Key invariants` — "**A customer never receives a partial file.** A file is published to the customer only after the worker has written it completely; a failed job publishes nothing."
````

### Final result message

````text
I amended the existing export story to add CSV instead of starting a new story. Your decision changes an approved story, so I used the amendment route. It's committed as `cb1d7fa`.

**What changed** in `docs/superpowers/stories/2026-10-01-export-job-story.md`:
- **New criterion AC-5:** "A customer can request an export of their account data as a CSV file from the account page." It cites your chat message as the decision.
- **Kept as they were:**
  - AC-1, so XLSX is still offered.
  - AC-2 to AC-4. They're already worded for any export, so notifications, "never a partial file" and "EU bucket only" now cover CSV files without any edit.
  - The desired outcome, and the exclusion of scheduled exports.
- **Change record** at the end of §3, measured against `e2f55ca`. Nothing is left without a decision behind it, and nothing else depends on this story yet.

The story only changed docs, so the project's gate rules required no review. I staged only that one file and checked it matched what I wrote.

**What this unblocks:** design and planning for the export story can go ahead with CSV in scope. Nothing is blocked. I haven't started anything further.

**One thing to decide:** this route doesn't re-check the story's risk or security level, and it stays at `standard`. CSV files can carry formula injection, where a cell starting with `=` runs as a formula when opened in a spreadsheet app. If you think that should raise the security level, it needs a profile change logged in the story by a separate decision. Otherwise, brainstorming should cover it when designing the export.
````

## D run 5

### Commits

````text
067438c docs(intake): amend export-job story — add CSV export (AC-5)
Decided by Daniel in chat, 2026-10-10: "add CSV to the export story".

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>

````

### Files changed vs fixture

````text
 .../stories/2026-10-01-export-job-story.md           | 20 ++++++++++++++++++++
 1 file changed, 20 insertions(+)
````

### Story diff

````diff
diff --git a/docs/superpowers/stories/2026-10-01-export-job-story.md b/docs/superpowers/stories/2026-10-01-export-job-story.md
index 4250e32..75a01bf 100644
--- a/docs/superpowers/stories/2026-10-01-export-job-story.md
+++ b/docs/superpowers/stories/2026-10-01-export-job-story.md
@@ -15,6 +15,26 @@ _IDs are permanent once the story is committed: never renumber or reuse one; a n
 - [ ] **AC-2** When the export finishes, the customer is notified by e-mail and by an in-app notice.
 - [ ] **AC-3** The customer never receives a partial file; a failed export publishes nothing and shows the failure on the account page.
 - [ ] **AC-4** Export files are stored only in the EU bucket.
+- [ ] **AC-5** A customer can request an export of their account data as a CSV file, in addition to the XLSX file of AC-1.
+
+**Changed 2026-10-10 — changed requirement.** Decided by Daniel, in chat on 2026-10-10: "add CSV to the export story". Baseline: e2f55ca. Exports are to be offered as CSV as well as XLSX. "Add" extends the formats and does not replace XLSX, so every earlier condition is kept.
+
+| Earlier condition | Fate | AC operation |
+|---|---|---|
+| AC-1: export requestable as XLSX from the account page | kept | none |
+| AC-2: e-mail and in-app notice on completion | kept (already format-independent) | none |
+| AC-3: no partial file; failure publishes nothing and is shown | kept (already format-independent) | none |
+| AC-4: export files stored only in the EU bucket | kept (already format-independent) | none |
+| §2: "receives a complete file without contacting support" | kept | none |
+| §2 exclusion: "Scheduled (recurring) exports are out of scope for this story." | kept | none |
+
+- **Added without an earlier condition:** AC-5: "A customer can request an export of their account data as a CSV file, in addition to the XLSX file of AC-1." → per the decision: "add CSV to the export story"
+- **Unaccounted:** none.
+- **Intervening changes:** none — working tree and index matched e2f55ca when this record was written.
+- **Scope boundary:** in: CSV as a further export format; out: scheduled exports (unchanged), removal or replacement of XLSX.
+- **Open questions:** none.
+- **Dependent artifacts:** none — no spec or plan references this story yet.
+- **Reviews already run:** none recorded for this story (checked: the story file, git history `e2f55ca`); this commit is docs-only, so no gate is owed, per `.claude/review-gates.md` "What counts as prose (the only Gate-B exemption)".
 
 ## 4. Affected AGENTS.md invariants
 - `## Key invariants` — "**A customer never receives a partial file.** A file is published to the customer only after the worker has written it completely; a failed job publishes nothing."
````

### Final result message

````text
I added CSV to the existing export story and committed it as `067438c`. I didn't create a new story, because Daniel's decision ("add CSV to the export story") changes the one already approved: `docs/superpowers/stories/2026-10-01-export-job-story.md`.

**What changed:**
- **New criterion:** **AC-5** — "A customer can request an export of their account data as a CSV file, in addition to the XLSX file of AC-1."
- **Change record:** added at the end of §3. It is measured against the story as approved in commit `e2f55ca`.
- **Earlier conditions:** all six kept with their wording unchanged: AC-1 to AC-4, the "complete file" outcome, and the rule that scheduled exports are out of scope. I read "add" as keeping XLSX alongside CSV, not replacing it.
- **Rules and invariants:** AC-2 to AC-4 and the two project rules the story depends on (no partial files, files stored only in the EU) already apply to any file format. So CSV is covered without rewording anything.

**Checks:**
- Nothing was left without a decision, and there are no other changes since the original story.
- No spec or plan depends on this story yet.
- The commit only touches the story document, so the project's review rules don't require a review gate for it.
- Only the story file was staged, and the staged content matched what I wrote.

**What this unblocks:** the export story can now go into design with CSV in scope. Nothing is blocked. I haven't started design; that's for you to start.
````

## B run 1

### Commits

````text
7e1aed2 docs(story): amend export-job story — drop e-mail notice, add CSV
Decided by Daniel, 2026-10-09, PR #12 review thread. AC-2 narrowed
(in-app notice only), AC-5 added (CSV in addition to XLSX).

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>

````

### Files changed vs fixture

````text
 .../stories/2026-10-01-export-job-story.md          | 21 ++++++++++++++++++++-
 1 file changed, 20 insertions(+), 1 deletion(-)
````

### Story diff

````diff
diff --git a/docs/superpowers/stories/2026-10-01-export-job-story.md b/docs/superpowers/stories/2026-10-01-export-job-story.md
index 4250e32..0da153a 100644
--- a/docs/superpowers/stories/2026-10-01-export-job-story.md
+++ b/docs/superpowers/stories/2026-10-01-export-job-story.md
@@ -12,9 +12,28 @@ A customer can request an export of their account data and receives a complete f
 ## 3. Acceptance criteria
 _IDs are permanent once the story is committed: never renumber or reuse one; a new criterion takes the next number unused here and on the branch it merges into, and a collision stops for a human; a removed one stays, struck through and dated; a narrowed one keeps its ID with a dated note; cite as `<story path> AC-<n>`; full rules: dev-workflow:intake, "Acceptance-criterion IDs"._
 - [ ] **AC-1** A customer can request an export of their account data as an XLSX file from the account page.
-- [ ] **AC-2** When the export finishes, the customer is notified by e-mail and by an in-app notice.
+- [ ] **AC-2** When the export finishes, the customer is notified by an in-app notice. (narrowed 2026-10-09: e-mail notification dropped from this release, per Daniel in the PR #12 review thread)
 - [ ] **AC-3** The customer never receives a partial file; a failed export publishes nothing and shows the failure on the account page.
 - [ ] **AC-4** Export files are stored only in the EU bucket.
+- [ ] **AC-5** The export of account data is also available as a CSV file, not only as XLSX.
+
+**Changed 2026-10-09 — changed requirement.** Decided by Daniel, review thread of PR #12. Baseline: `e2f55ca`. The e-mail notification leaves this release while the in-app notice stays, and CSV joins XLSX as an export format.
+
+| Earlier condition | Fate | AC operation |
+|---|---|---|
+| AC-1: customer can request an export as an XLSX file from the account page | kept | none |
+| AC-2: customer notified by e-mail and by an in-app notice when the export finishes | kept: in-app notice, per the decision: "keep the in-app notice"; dropped — e-mail notification, per the decision: "Drop the e-mail notification from this release" | narrowed |
+| AC-3, AC-4: no partial file / failure shown; files only in the EU bucket | kept | none |
+| §2: "A customer can request an export of their account data and receives a complete file without contacting support." | kept | none |
+| §2 exclusion: "Scheduled (recurring) exports are out of scope for this story." | kept | none |
+
+- **Added without an earlier condition:** AC-5: "The export of account data is also available as a CSV file, not only as XLSX." → per the decision: "the export must also be available as CSV, not only XLSX"
+- **Unaccounted:** none.
+- **Intervening changes:** none — the working copy and index equal the baseline.
+- **Scope boundary:** in: in-app notice on completion; XLSX and CSV export formats. out: e-mail notification (this release); scheduled exports (unchanged).
+- **Open questions:** none.
+- **Dependent artifacts:** none — no spec or plan in this repository cites this story; PR #12's branch is not available locally and was not checked.
+- **Reviews already run:** story approval at `e2f55ca` and the PR #12 review → "no rule found" (inputs: the approved story and the PR #12 review; paragraphs checked: `.claude/review-gates.md` "What counts as prose", the only paragraph present) → pending: whether the story approval or the PR #12 review must re-run blocks continuing the PR #12 work against this story until a human decides.
 
 ## 4. Affected AGENTS.md invariants
 - `## Key invariants` — "**A customer never receives a partial file.** A file is published to the customer only after the worker has written it completely; a failed job publishes nothing."
````

### Final result message

````text
I amended the story and committed it as `7e1aed2`. Only the story file was staged, and the staged copy matched what I wrote.

**What changed in §3** (measured against `e2f55ca`, the commit where the story was approved; nothing had changed since):
- **AC-2 narrowed:** it now asks only for the in-app notice. A dated note on the line explains why. This counts as narrowing, not a replacement, because the in-app notice was already required.
- **AC-5 added:** "The export of account data is also available as a CSV file, not only as XLSX." It is listed under *Added without an earlier condition* with a quote from your decision. AC-1 (XLSX) stays as it was: the decision adds CSV but doesn't change the XLSX requirement.
- **Unchanged:** AC-1, AC-3 and AC-4 are kept, along with the outcome sentence in §2 and the exclusion of scheduled exports. AC-3 and AC-4 are written for export files in general, so they also cover CSV.
- The change record sits at the end of §3. It has no *Unaccounted* entries and no open questions.

**Not checked:**
- **PR #12's branch:** this repo has no remote and only `main`, so I couldn't look at it. If that branch already uses AC-5 or cites this story, the identifier collision rule applies and someone has to decide which side renumbers.
- **Dependent artifacts:** nothing on `main` cites this story, so no spec or plan was updated.

**Still blocked:** whether the story approval or the PR #12 review must run again. The only gate rule in `.claude/review-gates.md` ("What counts as prose") doesn't cover that, so the record marks it "no rule found" and pending. Continuing PR #12 against this story should wait until you decide. The commit itself only touches docs, so it doesn't need Gate B.

I haven't started anything after this; the next step is yours.
````

## B run 2

### Commits

````text
6db8dd0 docs(intake): amend export-job story — drop e-mail notice, add CSV export
Decided by Daniel, 2026-10-09, PR #12 review thread. AC-2 narrowed, AC-5 added.

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>

````

### Files changed vs fixture

````text
 .../stories/2026-10-01-export-job-story.md         | 22 +++++++++++++++++++++-
 1 file changed, 21 insertions(+), 1 deletion(-)
````

### Story diff

````diff
diff --git a/docs/superpowers/stories/2026-10-01-export-job-story.md b/docs/superpowers/stories/2026-10-01-export-job-story.md
index 4250e32..0d0acfe 100644
--- a/docs/superpowers/stories/2026-10-01-export-job-story.md
+++ b/docs/superpowers/stories/2026-10-01-export-job-story.md
@@ -12,9 +12,29 @@ A customer can request an export of their account data and receives a complete f
 ## 3. Acceptance criteria
 _IDs are permanent once the story is committed: never renumber or reuse one; a new criterion takes the next number unused here and on the branch it merges into, and a collision stops for a human; a removed one stays, struck through and dated; a narrowed one keeps its ID with a dated note; cite as `<story path> AC-<n>`; full rules: dev-workflow:intake, "Acceptance-criterion IDs"._
 - [ ] **AC-1** A customer can request an export of their account data as an XLSX file from the account page.
-- [ ] **AC-2** When the export finishes, the customer is notified by e-mail and by an in-app notice.
+- [ ] **AC-2** When the export finishes, the customer is notified by an in-app notice. (narrowed 2026-10-10: e-mail notification dropped from this release — Daniel, PR #12 review thread, 2026-10-09)
 - [ ] **AC-3** The customer never receives a partial file; a failed export publishes nothing and shows the failure on the account page.
 - [ ] **AC-4** Export files are stored only in the EU bucket.
+- [ ] **AC-5** A customer can also request the export of their account data as a CSV file.
+
+**Changed 2026-10-10 — changed requirement.** Decided by Daniel, 2026-10-09, in the review thread of PR #12: "Drop the e-mail notification from this release; keep the in-app notice. And the export must also be available as CSV, not only XLSX." Baseline: e2f55ca (`docs/superpowers/stories/2026-10-01-export-job-story.md` blob 4250e32). The release ships without the e-mail notice and offers CSV alongside XLSX.
+
+| Earlier condition | Fate | AC operation |
+|---|---|---|
+| AC-1: export as an XLSX file from the account page | kept | none |
+| AC-2: notified by e-mail and by an in-app notice | kept: in-app notice, per the decision: "keep the in-app notice"; dropped — e-mail notification, per the decision: "Drop the e-mail notification from this release" | narrowed |
+| AC-3: no partial file; a failed export publishes nothing and shows the failure on the account page | kept | none |
+| AC-4: export files stored only in the EU bucket | kept | none |
+| §2: "A customer can request an export of their account data and receives a complete file without contacting support." | kept | none |
+| §2: "Scheduled (recurring) exports are out of scope for this story." | kept | none |
+
+- **Added without an earlier condition:** AC-5: "A customer can also request the export of their account data as a CSV file." → per the decision: "the export must also be available as CSV, not only XLSX".
+- **Unaccounted:** none.
+- **Intervening changes:** none — the working tree and index equalled the baseline blob before this change.
+- **Scope boundary:** in: in-app notice on completion; export as XLSX and as CSV. out: e-mail notification (this release); scheduled exports (unchanged).
+- **Open questions:** none.
+- **Dependent artifacts:** none — no spec or plan in the repository cites this story.
+- **Reviews already run:** PR #12 review → "no rule found" (input: PR #12 review of this story's work; paragraphs checked: `.claude/review-gates.md` "What counts as prose", the only paragraph in the file) → pending: whether PR #12 or any earlier gate on this story must re-run against the amended criteria blocks continuing PR #12 until Daniel decides.
 
 ## 4. Affected AGENTS.md invariants
 - `## Key invariants` — "**A customer never receives a partial file.** A file is published to the customer only after the worker has written it completely; a failed job publishes nothing."
````

### Final result message

````text
I amended the story and committed it as `6db8dd0` on a new branch, `docs/amend-export-job-story`. I made the branch because we were on `main`. The commit holds only the story file.

**What changed in `docs/superpowers/stories/2026-10-01-export-job-story.md`:**
- **AC-2** is narrowed: on completion the customer gets the in-app notice only. A dated note on that line says the e-mail notification was dropped from this release.
- **AC-5** is new: "A customer can also request the export of their account data as a CSV file."
- **AC-1, AC-3, AC-4** and both §2 sentences (the outcome and "scheduled exports are out of scope") are unchanged. AC-1 still requires XLSX, and AC-4's "export files only in the EU bucket" also covers the CSV files.
- A change record sits at the end of §3. It compares against the story as committed in `e2f55ca` and quotes your decision for each changed criterion. No criterion is left without a decision, and there were no edits since that commit.

**Gate:** none is needed. Every changed file is under `docs/**.md`, which `.claude/review-gates.md` exempts as prose.

**What this unblocks:** spec or plan work against the amended criteria. Nothing else in the repo cites this story, so no other file needed updating.

**Decision needed:** `.claude/review-gates.md` has no rule on whether PR #12, or any earlier review of this story, must run again now that the criteria changed. I recorded this as pending in the change record, so continuing PR #12 waits on your answer.

I haven't started any next step, and the branch isn't pushed.
````

## B run 3

### Commits

````text
f2504de docs(intake): amend export-job story — drop e-mail notice, add CSV
Decided by Daniel, 2026-10-09, PR #12 review thread. AC-2 narrowed to the
in-app notice; AC-5 added for CSV export alongside XLSX.

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>

````

### Files changed vs fixture

````text
 .../stories/2026-10-01-export-job-story.md         | 22 +++++++++++++++++++++-
 1 file changed, 21 insertions(+), 1 deletion(-)
````

### Story diff

````diff
diff --git a/docs/superpowers/stories/2026-10-01-export-job-story.md b/docs/superpowers/stories/2026-10-01-export-job-story.md
index 4250e32..941db83 100644
--- a/docs/superpowers/stories/2026-10-01-export-job-story.md
+++ b/docs/superpowers/stories/2026-10-01-export-job-story.md
@@ -12,9 +12,29 @@ A customer can request an export of their account data and receives a complete f
 ## 3. Acceptance criteria
 _IDs are permanent once the story is committed: never renumber or reuse one; a new criterion takes the next number unused here and on the branch it merges into, and a collision stops for a human; a removed one stays, struck through and dated; a narrowed one keeps its ID with a dated note; cite as `<story path> AC-<n>`; full rules: dev-workflow:intake, "Acceptance-criterion IDs"._
 - [ ] **AC-1** A customer can request an export of their account data as an XLSX file from the account page.
-- [ ] **AC-2** When the export finishes, the customer is notified by e-mail and by an in-app notice.
+- [ ] **AC-2** When the export finishes, the customer is notified by an in-app notice. (narrowed 2026-10-09: e-mail notification dropped from this release, per Daniel in the PR #12 review thread)
 - [ ] **AC-3** The customer never receives a partial file; a failed export publishes nothing and shows the failure on the account page.
 - [ ] **AC-4** Export files are stored only in the EU bucket.
+- [ ] **AC-5** A customer can also request the export of their account data as a CSV file, in addition to the XLSX file of AC-1.
+
+**Changed 2026-10-09 — changed requirement.** Decided by Daniel, review thread of PR #12, 2026-10-09: "Drop the e-mail notification from this release; keep the in-app notice. And the export must also be available as CSV, not only XLSX." Baseline: e2f55ca (the only commit containing this story; it was committed approved). The e-mail notification leaves this release, and CSV joins XLSX as an export format.
+
+| Earlier condition | Fate | AC operation |
+|---|---|---|
+| AC-1: export as an XLSX file from the account page | kept | none |
+| AC-2: notified by e-mail and by an in-app notice | kept: in-app notice, per the decision: "keep the in-app notice"; dropped — e-mail notification, per the decision: "Drop the e-mail notification from this release" | narrowed |
+| AC-3: never a partial file; a failed export publishes nothing and shows the failure | kept | none |
+| AC-4: export files stored only in the EU bucket | kept | none |
+| §2: "A customer can request an export of their account data and receives a complete file without contacting support." | kept | none |
+| §2 exclusion: "Scheduled (recurring) exports are out of scope for this story." | kept | none |
+
+- **Added without an earlier condition:** AC-5: "A customer can also request the export of their account data as a CSV file, in addition to the XLSX file of AC-1." → per the decision: "the export must also be available as CSV, not only XLSX".
+- **Unaccounted:** none.
+- **Intervening changes:** none — working tree and index matched the baseline.
+- **Scope boundary:** in: XLSX and CSV export; in-app notice on completion. out: e-mail notification (this release); scheduled (recurring) exports (unchanged).
+- **Open questions:** none.
+- **Dependent artifacts:** none in this repository. PR #12 (spec, plan or code citing AC-1 or AC-2) is not reachable from this checkout — no remote, no branch — so its status is not assessed here.
+- **Reviews already run:** PR #12 review cycle, which took this story as input → "no rule found" (PR #12 review cycle; checked `.claude/review-gates.md` "What counts as prose", the only paragraph present) → pending: blocks continuing PR #12 against the amended AC-2 and new AC-5 until Daniel decides whether its review reruns.
 
 ## 4. Affected AGENTS.md invariants
 - `## Key invariants` — "**A customer never receives a partial file.** A file is published to the customer only after the worker has written it completely; a failed job publishes nothing."
````

### Final result message

````text
I amended the story and committed it on `main` as `f2504de`. The commit contains only `docs/superpowers/stories/2026-10-01-export-job-story.md`.

**What changed in §3:**
- **AC-2 narrowed.** The customer is now notified only by the in-app notice. The line has a dated note saying the e-mail notification was dropped from this release.
- **AC-5 added.** A customer can also request the export as a CSV file, alongside the XLSX file in AC-1. AC-5 is new and doesn't replace anything, so AC-1 stays as written.
- **Kept as they were:** AC-1, AC-3, AC-4, the desired-outcome sentence in §2, and its exclusion of scheduled exports.
- **Change record.** It's at the end of §3 and quotes your decision for each fate. The baseline is `e2f55ca`, the only commit that contains the story. Nothing in the story is left unaccounted, and there were no edits since the baseline.

**No review gate:** the commit only touches a doc under `docs/`, which `.claude/review-gates.md` (lines 3–4) exempts.

**What this unblocks:** design and implementation can work from AC-1 to AC-5, with the e-mail notification out of scope for this release.

**Still blocked, and both need you:**
- **PR #12's existing review.** It used this story as input. The gate-rules file has no paragraph on whether a review reruns after its input story changes. The record marks this as pending your decision before PR #12 continues against the new AC-2 and AC-5.
- **PR #12 itself.** This checkout has no remote and no branch for it, so I couldn't check whether a spec, plan or code there cites AC-1 or AC-2. The record says so rather than giving it a status.

I didn't resume any review, plan or implementation step.
````

