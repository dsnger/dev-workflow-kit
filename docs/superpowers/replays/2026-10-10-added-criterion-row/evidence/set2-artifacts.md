# Set 2 — per-run evidence (skill at 53a88a4, sha256 e629b1ba727f0ea22d9e422e4d5a272251c34a428c1f6524ecbda8a83a9e7089)

Per run: commits, files changed against the fixture commit `e2f55ca`, the story diff (which holds the change record), and the final result message. Run metrics are in `metrics.md`.

## D run 1

### Commits

````text
519f683 HEAD -> main docs(intake): amend export-job story — add CSV export (AC-5)
Changed requirement decided by Daniel in chat on 2026-10-10:
"add CSV to the export story".

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
index 4250e32..1903824 100644
--- a/docs/superpowers/stories/2026-10-01-export-job-story.md
+++ b/docs/superpowers/stories/2026-10-01-export-job-story.md
@@ -15,13 +15,33 @@ _IDs are permanent once the story is committed: never renumber or reuse one; a n
 - [ ] **AC-2** When the export finishes, the customer is notified by e-mail and by an in-app notice.
 - [ ] **AC-3** The customer never receives a partial file; a failed export publishes nothing and shows the failure on the account page.
 - [ ] **AC-4** Export files are stored only in the EU bucket.
+- [ ] **AC-5** A customer can request an export of their account data as a CSV file.
+
+**Changed 2026-10-10 — changed requirement.** Decided by Daniel, in chat on 2026-10-10. Baseline: e2f55ca. CSV is offered as an additional export format, alongside XLSX ("exports should also be offered as CSV").
+
+| Earlier condition | Fate | AC operation |
+|---|---|---|
+| §2: "A customer can request an export of their account data and receives a complete file without contacting support." | kept | none |
+| §2: "Scheduled (recurring) exports are out of scope for this story." | kept | none |
+| AC-1: XLSX export requested from the account page | kept | none |
+| AC-2: e-mail and in-app notice when the export finishes | kept | none |
+| AC-3: never a partial file; a failed export publishes nothing and shows the failure | kept | none |
+| AC-4: export files stored only in the EU bucket | kept | none |
+
+- **Added without an earlier condition:** AC-5: "A customer can request an export of their account data as a CSV file." → per the decision: "add CSV to the export story"
+- **Unaccounted:** none.
+- **Intervening changes:** none (working tree and index equal the baseline).
+- **Scope boundary:** in: CSV as an additional format for exports a customer requests; out: replacing XLSX; scheduled (recurring) exports (unchanged).
+- **Open questions:** Is the CSV export requested from the account page, as AC-1 says for XLSX? → §5.
+- **Dependent artifacts:** none (no spec or plan cites this story).
+- **Reviews already run:** the story at e2f55ca → there is no review record for it in the repository. No rule found (input: this story; checked `.claude/review-gates.md`, "What counts as prose", its only paragraph, which governs commits, not earlier cycles) → pending: Daniel needs to confirm that no review ran on the baseline. This blocks a gate on any spec built from this story until he confirms.
 
 ## 4. Affected AGENTS.md invariants
 - `## Key invariants` — "**A customer never receives a partial file.** A file is published to the customer only after the worker has written it completely; a failed job publishes nothing."
 - `## Key invariants` — "**Personal data stays in the EU region.** Export files are stored only in the EU bucket."
 
 ## 5. Open questions
-- None.
+- Is the CSV export (AC-5) requested from the account page, as AC-1 says for XLSX? (raised 2026-10-10)
 
 ## 6. Suggested size
 story — one coherent feature, one spec → plan → PR.
````

### Final result message

````text
I added CSV to the existing export story rather than creating a new one. Since your decision ("add CSV to the export story") changes a story that was already approved and committed, I amended it and committed the change as `519f683`. The changed file is `docs/superpowers/stories/2026-10-01-export-job-story.md`.

**What changed:**
- **New criterion AC-5:** "A customer can request an export of their account data as a CSV file." It's numbered AC-5 because AC-1 to AC-4 already exist.
- **Everything else stays as approved:** XLSX (AC-1), the notifications (AC-2), the rule against partial files (AC-3) and storing files only in the EU bucket (AC-4) are all unchanged. Scheduled exports are still out of scope. AC-3 and AC-4 are worded for any export, so they apply to CSV too.
- **A change record at the end of §3** lists every earlier condition and what happened to it, and links AC-5 to your quoted decision.
- **No review gate was needed,** because the commit changes only a doc file under `docs/`, which the project's gate rules exempt.

**Still open:**
- **Where CSV is requested from:** AC-1 says XLSX is requested from the account page, but your decision didn't say that for CSV, so I left it out of AC-5. The question is in §5. If the answer is yes, that's a small follow-up amendment.
- **Earlier reviews:** I found no record that the original story was reviewed, and the gate rules don't say what happens to earlier reviews. Can you confirm none ran? Until then, that's marked pending, and it would block a gate on any spec built from this story.

**Next step:** the story is ready for `superpowers:brainstorming` with this file as input, which you'd start yourself. I haven't started it.
````

## D run 2

### Commits

````text
de6450b HEAD -> main docs(intake): amend export-job story — add CSV export (AC-5)
Changed requirement decided by Daniel in chat, 2026-10-10:
"add CSV to the export story". Baseline e2f55ca.

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>

````

### Files changed vs fixture

````text
 .../stories/2026-10-01-export-job-story.md          | 21 +++++++++++++++++++++
 1 file changed, 21 insertions(+)
````

### Story diff

````diff
diff --git a/docs/superpowers/stories/2026-10-01-export-job-story.md b/docs/superpowers/stories/2026-10-01-export-job-story.md
index 4250e32..4bf058a 100644
--- a/docs/superpowers/stories/2026-10-01-export-job-story.md
+++ b/docs/superpowers/stories/2026-10-01-export-job-story.md
@@ -15,6 +15,27 @@ _IDs are permanent once the story is committed: never renumber or reuse one; a n
 - [ ] **AC-2** When the export finishes, the customer is notified by e-mail and by an in-app notice.
 - [ ] **AC-3** The customer never receives a partial file; a failed export publishes nothing and shows the failure on the account page.
 - [ ] **AC-4** Export files are stored only in the EU bucket.
+- [ ] **AC-5** A customer can request an export of their account data as a CSV file.
+
+**Changed 2026-10-10 — changed requirement.** Decided by Daniel, in chat on 2026-10-10. Baseline: e2f55ca. CSV is offered as an export format in addition to XLSX.
+
+| Earlier condition | Fate | AC operation |
+|---|---|---|
+| §1: "Customers ask support to pull their account data by hand, which takes days." | kept | none |
+| §2: "A customer can request an export of their account data and receives a complete file without contacting support." | kept | none |
+| §2 exclusion: "Scheduled (recurring) exports are out of scope for this story." | kept | none |
+| AC-1: XLSX export requested from the account page | kept | none |
+| AC-2: e-mail and in-app notice when the export finishes | kept | none |
+| AC-3: no partial file; a failed export publishes nothing and shows the failure on the account page | kept | none |
+| AC-4: export files stored only in the EU bucket | kept | none |
+
+- **Added without an earlier condition:** AC-5: "A customer can request an export of their account data as a CSV file." → per the decision: "add CSV to the export story"
+- **Unaccounted:** where the customer requests the CSV export (AC-1 places the XLSX request on the account page; the decision does not say whether CSV is requested there too) → blocks the spec's design of the CSV entry point until settled.
+- **Intervening changes:** none.
+- **Scope boundary:** in: CSV as an additional export format; out: replacing XLSX, scheduled (recurring) exports.
+- **Open questions:** none beyond *Unaccounted*.
+- **Dependent artifacts:** none (no spec or plan cites this story yet).
+- **Reviews already run:** none — no spec, plan or gate record exists for this story (checked `docs/` and `.claude/review-gates.md`). This commit stages only `docs/**.md` → no gate, per `.claude/review-gates.md` "What counts as prose (the only Gate-B exemption)".
 
 ## 4. Affected AGENTS.md invariants
 - `## Key invariants` — "**A customer never receives a partial file.** A file is published to the customer only after the worker has written it completely; a failed job publishes nothing."
````

### Final result message

````text
I added CSV to the existing export story at `docs/superpowers/stories/2026-10-01-export-job-story.md` and committed it as `de6450b`.

There was already an approved export story, so this went through the amendment route rather than becoming a new story. That route asks no questions and doesn't propose a new profile, because you'd already made the decision in chat.

**What changed:**
- **New criterion AC-5:** "A customer can request an export of their account data as a CSV file." It's backed by your quote: "add CSV to the export story".
- **Everything else stays as approved:** AC-1 to AC-4, the problem statement, the outcome and the exclusion of scheduled exports. AC-2 to AC-4 are worded for any export, so the notices, the no-partial-file rule and EU-only storage apply to CSV too. The profile (standard risk, standard security, battery+check) and the size (story) are unchanged.
- **Change record:** added at the end of §3. It compares against commit `e2f55ca`, the story's only commit, which I assumed is when it was approved. It lists every earlier condition with "kept".

**One open point:** the record lists one thing your decision doesn't settle. AC-1 has customers request the XLSX file from the account page, but the decision doesn't say where they request a CSV. I didn't assume it's the same place. It blocks only the spec's design of how customers request a CSV, until you decide.

**Checks:** only the story file was staged, and the staged content matched what I wrote. The commit contains only `docs/**.md`, so the project's gate rules require no review. No spec or plan uses this story yet, so nothing else needed updating.

**Next:** tell me where customers request a CSV export, and that gets recorded. After that, the story is ready for `superpowers:brainstorming`.
````

## D run 3

### Commits

````text
d15bf3b HEAD -> main docs(intake): amend export story — add CSV export (AC-5)
Decided by Daniel in chat, 2026-10-10: "add CSV to the export story".

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
index 4250e32..2e28bc0 100644
--- a/docs/superpowers/stories/2026-10-01-export-job-story.md
+++ b/docs/superpowers/stories/2026-10-01-export-job-story.md
@@ -15,13 +15,31 @@ _IDs are permanent once the story is committed: never renumber or reuse one; a n
 - [ ] **AC-2** When the export finishes, the customer is notified by e-mail and by an in-app notice.
 - [ ] **AC-3** The customer never receives a partial file; a failed export publishes nothing and shows the failure on the account page.
 - [ ] **AC-4** Export files are stored only in the EU bucket.
+- [ ] **AC-5** A customer can request an export of their account data as a CSV file.
+
+**Changed 2026-10-10 — changed requirement.** Decided by Daniel, in chat on 2026-10-10. Baseline: e2f55ca. CSV is offered as an export format in addition to XLSX.
+
+| Earlier condition | Fate | AC operation |
+|---|---|---|
+| §2: "A customer can request an export of their account data and receives a complete file without contacting support." | kept | none |
+| §2: "Scheduled (recurring) exports are out of scope for this story." | kept | none |
+| AC-1: XLSX export from the account page | kept | none |
+| AC-2 – AC-4: notification, no partial file, EU bucket only (format-independent wording) | kept | none |
+
+- **Added without an earlier condition:** AC-5: "A customer can request an export of their account data as a CSV file." → per the decision: "add CSV to the export story"
+- **Unaccounted:** none.
+- **Intervening changes:** none.
+- **Scope boundary:** in: CSV as an additional export format; out: unchanged — scheduled (recurring) exports.
+- **Open questions:** whether CSV is requested from the account page like XLSX → recorded in §5.
+- **Dependent artifacts:** none.
+- **Reviews already run:** none (no review record for this story in the repository).
 
 ## 4. Affected AGENTS.md invariants
 - `## Key invariants` — "**A customer never receives a partial file.** A file is published to the customer only after the worker has written it completely; a failed job publishes nothing."
 - `## Key invariants` — "**Personal data stays in the EU region.** Export files are stored only in the EU bucket."
 
 ## 5. Open questions
-- None.
+- Is the CSV export requested from the account page, like the XLSX export (AC-1)? The 2026-10-10 decision does not say where.
 
 ## 6. Suggested size
 story — one coherent feature, one spec → plan → PR.
````

### Final result message

````text
I added CSV to the existing export story rather than starting a new one. There was already an approved export story, `docs/superpowers/stories/2026-10-01-export-job-story.md`, so this was an amendment. It's committed as `d15bf3b`.

**What changed in the story:**
- **New criterion AC-5:** "A customer can request an export of their account data as a CSV file." It's backed by your decision: "add CSV to the export story".
- **Everything else stays.** AC-1 (XLSX from the account page) is unchanged, so CSV is offered alongside XLSX. AC-2 to AC-4 (notification, never a partial file, EU bucket only) don't name a format, so they already cover CSV without any edit. The goal statement and "scheduled exports are out of scope" are also unchanged.
- **A change record** at the end of the criteria lists each earlier criterion and goal sentence and what happened to it, measured against commit `e2f55ca`.
- **One new open question:** should CSV be requested from the account page, like XLSX? Your decision doesn't say where, so I left the location out of AC-5 and listed the question under Open questions.

No review is owed on this commit, because it only touches a doc file under `docs/`. I didn't change the story's Risk and Security ratings (both still `standard`). If you think CSV warrants more security attention, for example spreadsheet formulas hidden in exported cell values, raise that rating before design starts.

**Unblocked:** designing the CSV export with this story as input. **Still open:** the account-page question, which brainstorming can settle with you. I haven't started the next step.
````

## D run 4

### Commits

````text
a8d627b HEAD -> main docs(story): add CSV export format to export-job story (AC-5)
Amendment decided by Daniel in chat on 2026-10-10: "add CSV to the
export story". AC-1..AC-4 kept unchanged; change record in §3.

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
index 4250e32..54adf78 100644
--- a/docs/superpowers/stories/2026-10-01-export-job-story.md
+++ b/docs/superpowers/stories/2026-10-01-export-job-story.md
@@ -15,13 +15,31 @@ _IDs are permanent once the story is committed: never renumber or reuse one; a n
 - [ ] **AC-2** When the export finishes, the customer is notified by e-mail and by an in-app notice.
 - [ ] **AC-3** The customer never receives a partial file; a failed export publishes nothing and shows the failure on the account page.
 - [ ] **AC-4** Export files are stored only in the EU bucket.
+- [ ] **AC-5** A customer can request an export of their account data as a CSV file, in addition to XLSX.
+
+**Changed 2026-10-10 — changed requirement.** Decided by Daniel, in chat on 2026-10-10. Baseline: e2f55ca. Exports are to be offered as CSV as well as XLSX.
+
+| Earlier condition | Fate | AC operation |
+|---|---|---|
+| §2: "A customer can request an export of their account data and receives a complete file without contacting support." | kept | none |
+| §2: "Scheduled (recurring) exports are out of scope for this story." | kept | none |
+| AC-1: XLSX export requested from the account page | kept | none |
+| AC-2 – AC-4: notification, no partial file, EU bucket only | kept (their wording is format-independent and already covers CSV files) | none |
+
+- **Added without an earlier condition:** AC-5: "A customer can request an export of their account data as a CSV file, in addition to XLSX." → per the decision: "add CSV to the export story"; per the request recording it: "exports should also be offered as CSV".
+- **Unaccounted:** none.
+- **Intervening changes:** none (working tree and index clean; no commits to the story since e2f55ca).
+- **Scope boundary:** in: CSV as an additional export format; out: scheduled (recurring) exports, unchanged.
+- **Open questions:** where the customer chooses CSV (the decision doesn't name a place; AC-1's "account page" was not carried over) → §5.
+- **Dependent artifacts:** none (no spec or plan cites this story yet).
+- **Reviews already run:** none recorded for this story (checked git history and `docs/`); the commit itself is docs-only → no gate, per `.claude/review-gates.md`, "What counts as prose (the only Gate-B exemption)".
 
 ## 4. Affected AGENTS.md invariants
 - `## Key invariants` — "**A customer never receives a partial file.** A file is published to the customer only after the worker has written it completely; a failed job publishes nothing."
 - `## Key invariants` — "**Personal data stays in the EU region.** Export files are stored only in the EU bucket."
 
 ## 5. Open questions
-- None.
+- Where does the customer choose CSV — on the account page like XLSX (AC-1), or somewhere else? (Added 2026-10-10 with AC-5.)
 
 ## 6. Suggested size
 story — one coherent feature, one spec → plan → PR.
````

### Final result message

````text
I added CSV to the existing export story rather than writing a new one, and committed the change as `a8d627b`. The story `docs/superpowers/stories/2026-10-01-export-job-story.md` was already approved, so Daniel's "add CSV to the export story" counts as a change to it.

**What changed**
- **New criterion, AC-5:** "A customer can request an export of their account data as a CSV file, in addition to XLSX." It's backed by Daniel's chat message from 2026-10-10.
- **Nothing else changed.** AC-1 (XLSX from the account page) and the "scheduled exports are out of scope" line stay as they were. AC-2 to AC-4 (notification, no partial file, EU bucket only) don't depend on the file format, so they already cover CSV.
- **Change record:** added at the end of §3. It's measured against the story as first committed (`e2f55ca`), and nothing is left without a decision.
- **New open question in §5:** where does the customer choose CSV? The decision doesn't say, so I didn't assume it's the account page like XLSX. It doesn't block anything, but whoever designs this should answer it.

No spec or plan points to this story yet, and there's no record of a review on it. The commit only touches docs, which the project's gate rules exempt from review.

The risk and security levels in the story header are unchanged; this amendment process doesn't revisit them. CSV adds some security concerns of its own, such as spreadsheet formula injection. If you think that should raise the security level, it would be a separate, logged change.

Next step: whenever design work on the export story starts, use the updated story as the input to `superpowers:brainstorming`. I haven't started it.
````

## D run 5

### Commits

````text
d72325d HEAD -> main docs(intake): amend export-job story — add CSV export (AC-5)
Changed requirement decided by Daniel in chat on 2026-10-10:
"add CSV to the export story".

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>

````

### Files changed vs fixture

````text
 docs/superpowers/stories/2026-10-01-export-job-story.md | 17 +++++++++++++++++
 1 file changed, 17 insertions(+)
````

### Story diff

````diff
diff --git a/docs/superpowers/stories/2026-10-01-export-job-story.md b/docs/superpowers/stories/2026-10-01-export-job-story.md
index 4250e32..58635eb 100644
--- a/docs/superpowers/stories/2026-10-01-export-job-story.md
+++ b/docs/superpowers/stories/2026-10-01-export-job-story.md
@@ -15,6 +15,23 @@ _IDs are permanent once the story is committed: never renumber or reuse one; a n
 - [ ] **AC-2** When the export finishes, the customer is notified by e-mail and by an in-app notice.
 - [ ] **AC-3** The customer never receives a partial file; a failed export publishes nothing and shows the failure on the account page.
 - [ ] **AC-4** Export files are stored only in the EU bucket.
+- [ ] **AC-5** A customer can request an export of their account data as a CSV file.
+
+**Changed 2026-10-10 — changed requirement.** Decided by Daniel, in chat, 2026-10-10. Baseline: e2f55ca. Exports are to be offered as CSV in addition to XLSX.
+
+| Earlier condition | Fate | AC operation |
+|---|---|---|
+| AC-1 … AC-4 | kept | none |
+| §2: "A customer can request an export of their account data and receives a complete file without contacting support." | kept | none |
+| §2 exclusion: "Scheduled (recurring) exports are out of scope for this story." | kept | none |
+
+- **Added without an earlier condition:** AC-5: "A customer can request an export of their account data as a CSV file." → per the decision: "add CSV to the export story"
+- **Unaccounted:** none.
+- **Intervening changes:** none — working tree and index equal the baseline.
+- **Scope boundary:** in: CSV as an additional export format beside XLSX; out: replacing XLSX; scheduled (recurring) exports, still excluded.
+- **Open questions:** Is a CSV export requested from the account page, like XLSX in AC-1? The decision does not say, so AC-5 names no place → recorded here, for Daniel to answer before the spec fixes it.
+- **Dependent artifacts:** none.
+- **Reviews already run:** none on this story (history holds only e2f55ca); this amendment commit stages only `docs/superpowers/stories/2026-10-01-export-job-story.md` → Gate B N/A, per `.claude/review-gates.md`, "What counts as prose": "Every staged path is explanatory documentation — `docs/**.md`, `README.md`, `MANIFEST.md` → N/A."
 
 ## 4. Affected AGENTS.md invariants
 - `## Key invariants` — "**A customer never receives a partial file.** A file is published to the customer only after the worker has written it completely; a failed job publishes nothing."
````

### Final result message

````text
I added CSV to the existing export story rather than starting a new one. That story was already approved and committed, and your decision says to change it ("add CSV to the export story"). The change is committed as `d72325d`.

**What changed** in `docs/superpowers/stories/2026-10-01-export-job-story.md`:
- **New criterion AC-5:** "A customer can request an export of their account data as a CSV file."
- **Nothing else changed:**
  - AC-1 to AC-4 keep their wording, so XLSX stays.
  - The desired outcome and the exclusion of scheduled exports are kept.
  - The two quoted invariants (no partial files, EU bucket only) still apply as written, and they cover CSV exports too.
- **A change record at the end of §3** logs the decision (who, date, quote), the baseline commit `e2f55ca`, and what happened to each earlier condition. It also notes that no reviews have run on this story yet. The commit only touches docs, so the gate rules don't require a Gate B review.

**One open question, recorded in the change record:** should CSV be requested from the account page, like XLSX in AC-1? Your decision doesn't say, so AC-5 names no place. Please answer it before the spec settles it.

**Now unblocked:** a spec covering CSV can cite `docs/superpowers/stories/2026-10-01-export-job-story.md AC-5`. **Still blocked:** where CSV is requested, until you answer the question above. Nothing else has been started.
````

## B run 1

### Commits

````text
b3de86c HEAD -> main docs(intake): amend export-job story — drop e-mail notice, add CSV
AC-2 narrowed to the in-app notice; AC-5 added for CSV export.
Decided by Daniel, 2026-10-09, PR #12 review thread.

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
index 4250e32..e3c17dc 100644
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
+- [ ] **AC-5** A customer's account data export is also available as a CSV file, not only as XLSX.
+
+**Changed 2026-10-09 — changed requirement.** Decided by Daniel, review thread of PR #12, 2026-10-09: "Drop the e-mail notification from this release; keep the in-app notice. And the export must also be available as CSV, not only XLSX." Baseline: e2f55ca (the only commit containing the approved story). The release drops the e-mail channel and adds CSV beside XLSX.
+
+| Earlier condition | Fate | AC operation |
+|---|---|---|
+| AC-1: export of account data as an XLSX file from the account page | kept | none |
+| AC-2: on finish, customer notified by e-mail and by an in-app notice | kept: in-app notice, per the decision: "keep the in-app notice"; dropped — e-mail notification, per the decision: "Drop the e-mail notification from this release" | narrowed |
+| AC-3: never a partial file; a failed export publishes nothing and shows the failure on the account page | kept | none |
+| AC-4: export files stored only in the EU bucket | kept | none |
+| §2: "A customer can request an export of their account data and receives a complete file without contacting support." | kept | none |
+| §2 exclusion: "Scheduled (recurring) exports are out of scope for this story." | kept | none |
+
+- **Added without an earlier condition:** AC-5: "A customer's account data export is also available as a CSV file, not only as XLSX." → per the decision: "the export must also be available as CSV, not only XLSX"
+- **Unaccounted:** where a customer requests the CSV export — the decision does not say whether it is requested from the account page like AC-1's XLSX export, so AC-5 does not state a place → blocks the spec from fixing the CSV request surface until Daniel settles it.
+- **Intervening changes:** none (working tree and index equal e2f55ca).
+- **Scope boundary:** in: XLSX and CSV export, in-app notice on finish; out: e-mail notification (this release), scheduled (recurring) exports.
+- **Open questions:** where the CSV export is requested → recorded under *Unaccounted* above.
+- **Dependent artifacts:** none (no spec or plan cites this story in the repository).
+- **Reviews already run:** PR #12 review cycle, which reviewed against the baseline AC-2 (e-mail + in-app) and without AC-5 → "no rule found" (input: PR #12 review cycle; paragraphs checked: `.claude/review-gates.md` "What counts as prose (the only Gate-B exemption)", the file's only paragraph) → pending: blocks treating PR #12's earlier review results as evidence for AC-2 or AC-5 until a human decides.
 
 ## 4. Affected AGENTS.md invariants
 - `## Key invariants` — "**A customer never receives a partial file.** A file is published to the customer only after the worker has written it completely; a failed job publishes nothing."
````

### Final result message

````text
I amended the story and committed it as `b3de86c`. I measured the change against `e2f55ca`, the only commit that contains the approved story.

**What changed in §3** (`docs/superpowers/stories/2026-10-01-export-job-story.md`):
- **AC-2 narrowed:** when the export finishes, the customer now gets only the in-app notice. The e-mail notification is dropped from this release. The new text adds no requirement, so AC-2 keeps its number and has a dated note.
- **AC-5 added:** "A customer's account data export is also available as a CSV file, not only as XLSX." This is the next unused number. It's listed under *Added without an earlier condition*, with the quoted part of your decision that covers it.
- **Kept unchanged:** AC-1 (XLSX), AC-3 (no partial files), AC-4 (EU bucket only), the outcome sentence in §2, and the exclusion of scheduled exports.
- The change record at the end of §3 accounts for every earlier condition, and quotes the decision for each one it keeps or drops.

**Commit:** No review gate was needed, because the only changed file is under `docs/**.md`, which `.claude/review-gates.md` exempts ("What counts as prose"). Exactly that one file was committed.

**Still blocked:**
- **Where the CSV export is requested:** the decision doesn't say whether customers request CSV from the account page, as they do XLSX in AC-1. So AC-5 names no place, and I listed the question under *Unaccounted*. Daniel needs to decide it before the spec can say where CSV is requested.
- **The earlier review on PR #12:** it checked against the old AC-2 (e-mail plus in-app) and didn't cover AC-5. I found no gate rule saying what happens to that review, so it's recorded as pending a human decision. Until then, the old review results shouldn't count as evidence for AC-2 or AC-5.

No spec or plan in the repository cites this story, so no other files needed updating. I haven't started anything after this; the spec, plan or review steps are yours to kick off.
````

## B run 2

### Commits

````text
9474852 HEAD -> main docs(story): amend export-job story — drop e-mail notice, add CSV
AC-2 narrowed to the in-app notice; AC-5 added (CSV besides XLSX).
Decided by Daniel, 2026-10-09, in the review thread of PR #12.

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>

````

### Files changed vs fixture

````text
 .../stories/2026-10-01-export-job-story.md         | 24 ++++++++++++++++++++--
 1 file changed, 22 insertions(+), 2 deletions(-)
````

### Story diff

````diff
diff --git a/docs/superpowers/stories/2026-10-01-export-job-story.md b/docs/superpowers/stories/2026-10-01-export-job-story.md
index 4250e32..329cf5a 100644
--- a/docs/superpowers/stories/2026-10-01-export-job-story.md
+++ b/docs/superpowers/stories/2026-10-01-export-job-story.md
@@ -12,16 +12,36 @@ A customer can request an export of their account data and receives a complete f
 ## 3. Acceptance criteria
 _IDs are permanent once the story is committed: never renumber or reuse one; a new criterion takes the next number unused here and on the branch it merges into, and a collision stops for a human; a removed one stays, struck through and dated; a narrowed one keeps its ID with a dated note; cite as `<story path> AC-<n>`; full rules: dev-workflow:intake, "Acceptance-criterion IDs"._
 - [ ] **AC-1** A customer can request an export of their account data as an XLSX file from the account page.
-- [ ] **AC-2** When the export finishes, the customer is notified by e-mail and by an in-app notice.
+- [ ] **AC-2** When the export finishes, the customer is notified by an in-app notice. (narrowed 2026-10-10: e-mail notification dropped from this release, decided by Daniel, 2026-10-09, PR #12)
 - [ ] **AC-3** The customer never receives a partial file; a failed export publishes nothing and shows the failure on the account page.
 - [ ] **AC-4** Export files are stored only in the EU bucket.
+- [ ] **AC-5** The export is also available as CSV, not only XLSX.
+
+**Changed 2026-10-10 — changed requirement.** Decided by Daniel, 2026-10-09, in the review thread of PR #12: "Drop the e-mail notification from this release; keep the in-app notice. And the export must also be available as CSV, not only XLSX." Baseline: `e2f55ca` (the commit holding the approved story; no later commit touches it). E-mail notification leaves this release's scope; CSV joins XLSX as an export format.
+
+| Earlier condition | Fate | AC operation |
+|---|---|---|
+| AC-1: export of account data as an XLSX file from the account page | kept | none |
+| AC-2: notified by e-mail and by an in-app notice when the export finishes | kept: in-app notice, per the decision: "keep the in-app notice"; dropped — e-mail notification, out of this release, per the decision: "Drop the e-mail notification from this release" | narrowed |
+| AC-3: no partial file; a failed export publishes nothing and shows the failure on the account page | kept | none |
+| AC-4: export files stored only in the EU bucket | kept | none |
+| §2: "A customer can request an export of their account data and receives a complete file without contacting support." | kept | none |
+| §2: "Scheduled (recurring) exports are out of scope for this story." | kept | none |
+
+- **Added without an earlier condition:** AC-5: "The export is also available as CSV, not only XLSX." → per the decision: "the export must also be available as CSV, not only XLSX".
+- **Unaccounted:** none.
+- **Intervening changes:** none — the story is unchanged since `e2f55ca` in working tree and index.
+- **Scope boundary:** in: in-app notice on completion; XLSX and CSV export formats. out: e-mail notification (this release); scheduled exports (unchanged).
+- **Open questions:** whether a CSV export is requested from the account page like the XLSX export → recorded in §5.
+- **Dependent artifacts:** none in this repository (no spec or plan cites this story). PR #12 is not visible from this checkout; any spec or plan on it that cites AC-2 or the XLSX-only format is not checked here.
+- **Reviews already run:** the PR #12 review cycle in which the decision was made → "no rule found" (input: PR #12's review of work under this story; paragraphs checked: `.claude/review-gates.md` "What counts as prose", its only paragraph, which decides commit gating only) → pending: whether PR #12's review must re-run against the amended story is Daniel's decision; blocks resuming PR #12 until settled.
 
 ## 4. Affected AGENTS.md invariants
 - `## Key invariants` — "**A customer never receives a partial file.** A file is published to the customer only after the worker has written it completely; a failed job publishes nothing."
 - `## Key invariants` — "**Personal data stays in the EU region.** Export files are stored only in the EU bucket."
 
 ## 5. Open questions
-- None.
+- Is a CSV export requested from the account page, like the XLSX export (AC-1)? The decision of 2026-10-09 does not say where (added 2026-10-10, see the change record in §3).
 
 ## 6. Suggested size
 story — one coherent feature, one spec → plan → PR.
````

### Final result message

````text
I amended `docs/superpowers/stories/2026-10-01-export-job-story.md` and committed it as `9474852`. The change is measured against `e2f55ca`, the only commit that holds the approved story.

**What changed in §3**
- **AC-2 narrowed:** a finished export is now announced by the in-app notice only. The e-mail notification is out of this release, with a dated note on the same line.
- **AC-5 added:** "The export is also available as CSV, not only XLSX." This is your wording, with no extra detail added.
- **Unchanged:** AC-1 (XLSX from the account page), AC-3 (no partial file), AC-4 (EU bucket), and both scope sentences in §2.
- **Change record:** added at the end of §3. It accounts for every earlier condition and quotes the part of your decision behind each fate. Nothing was left undecided, and there were no edits since `e2f55ca`.

**Open question added to §5:** your decision doesn't say where a CSV export is requested, so AC-5 doesn't either. Should it come from the account page like the XLSX export? It doesn't block anything, but whoever designs the feature needs the answer.

**Gate:** the commit only touches a `docs/**.md` file. `.claude/review-gates.md` treats that as "prose", so no gate was owed and I committed it myself.

**What this unblocks:** work under the amended story can go ahead with AC-2 narrowed and AC-5 added.

**Still blocked:**
- **The PR #12 review:** I found no rule in `.claude/review-gates.md` that says whether that review has to re-run against the amended story. Its only paragraph covers which commits need a gate. That's your call, and the record lists it as pending, so PR #12 stays blocked until you decide.
- **Work on PR #12 itself:** this checkout has no remote, so I couldn't see that PR. Any spec or plan there that relies on e-mail notification or on XLSX being the only format still needs checking.

I haven't started anything else; the next step is yours.
````

## B run 3

### Commits

````text
8780747 HEAD -> main docs(intake): amend export-job story — drop e-mail notice, add CSV export
Decided by Daniel, 2026-10-09, in the review thread of PR #12.
AC-2 narrowed (in-app notice only); AC-5 added (CSV export).

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>

````

### Files changed vs fixture

````text
 .../stories/2026-10-01-export-job-story.md         | 25 ++++++++++++++++++++--
 1 file changed, 23 insertions(+), 2 deletions(-)
````

### Story diff

````diff
diff --git a/docs/superpowers/stories/2026-10-01-export-job-story.md b/docs/superpowers/stories/2026-10-01-export-job-story.md
index 4250e32..16d327e 100644
--- a/docs/superpowers/stories/2026-10-01-export-job-story.md
+++ b/docs/superpowers/stories/2026-10-01-export-job-story.md
@@ -12,16 +12,37 @@ A customer can request an export of their account data and receives a complete f
 ## 3. Acceptance criteria
 _IDs are permanent once the story is committed: never renumber or reuse one; a new criterion takes the next number unused here and on the branch it merges into, and a collision stops for a human; a removed one stays, struck through and dated; a narrowed one keeps its ID with a dated note; cite as `<story path> AC-<n>`; full rules: dev-workflow:intake, "Acceptance-criterion IDs"._
 - [ ] **AC-1** A customer can request an export of their account data as an XLSX file from the account page.
-- [ ] **AC-2** When the export finishes, the customer is notified by e-mail and by an in-app notice.
+- [ ] **AC-2** When the export finishes, the customer is notified by an in-app notice. (narrowed 2026-10-10: e-mail notification dropped from this release — Daniel, 2026-10-09, PR #12 review thread)
 - [ ] **AC-3** The customer never receives a partial file; a failed export publishes nothing and shows the failure on the account page.
 - [ ] **AC-4** Export files are stored only in the EU bucket.
+- [ ] **AC-5** The export is also available as a CSV file, not only as XLSX.
+
+**Changed 2026-10-10 — changed requirement.** Decided by Daniel, 2026-10-09, in the review thread of PR #12: "Drop the e-mail notification from this release; keep the in-app notice. And the export must also be available as CSV, not only XLSX." Baseline: e2f55ca. The e-mail channel leaves this release while the in-app notice stays, and CSV is added as a second export format beside XLSX.
+
+| Earlier condition | Fate | AC operation |
+|---|---|---|
+| §2: "A customer can request an export of their account data and receives a complete file without contacting support." | kept | none |
+| §2: "Scheduled (recurring) exports are out of scope for this story." | kept | none |
+| AC-1: export as an XLSX file from the account page | kept | none |
+| AC-2: notified by e-mail and by an in-app notice | kept: in-app notice, per the decision: "keep the in-app notice"; dropped — e-mail notification, per the decision: "Drop the e-mail notification from this release" | narrowed |
+| AC-3: no partial file; a failed export publishes nothing and shows the failure on the account page | kept | none |
+| AC-4: export files stored only in the EU bucket | kept | none |
+| §4: AGENTS.md invariants "A customer never receives a partial file" and "Personal data stays in the EU region" | kept | none |
+
+- **Added without an earlier condition:** AC-5: "The export is also available as a CSV file, not only as XLSX." → per the decision: "the export must also be available as CSV, not only XLSX".
+- **Unaccounted:** none.
+- **Intervening changes:** none — HEAD equals the baseline and the working tree and index were clean.
+- **Scope boundary:** in: in-app notice on completion; XLSX and CSV exports; out: e-mail notification (this release); scheduled (recurring) exports.
+- **Open questions:** where the customer requests the CSV export (the decision does not say whether it is the account page, as for XLSX in AC-1) → recorded in §5.
+- **Dependent artifacts:** none — no spec or plan citing this story exists in the repository.
+- **Reviews already run:** PR #12 review cycle (the reviews in whose thread this decision was made) → "no rule found" (input: the PR #12 review cycle against AC-2 narrowed and AC-5 added; paragraphs checked: `.claude/review-gates.md` "What counts as prose (the only Gate-B exemption)", the only paragraph in the file) → pending: blocks treating PR #12's existing reviews as covering AC-2 (narrowed) and AC-5 until a human decides.
 
 ## 4. Affected AGENTS.md invariants
 - `## Key invariants` — "**A customer never receives a partial file.** A file is published to the customer only after the worker has written it completely; a failed job publishes nothing."
 - `## Key invariants` — "**Personal data stays in the EU region.** Export files are stored only in the EU bucket."
 
 ## 5. Open questions
-- None.
+- Where does the customer request the CSV export (AC-5)? The 2026-10-09 decision does not say whether it is the account page, as for XLSX in AC-1. (added 2026-10-10)
 
 ## 6. Suggested size
 story — one coherent feature, one spec → plan → PR.
````

### Final result message

````text
I amended the story to match Daniel's 2026-10-09 decision from the PR #12 review thread and committed it as `8780747`. Nothing else was in the commit.

**What changed in `docs/superpowers/stories/2026-10-01-export-job-story.md`:**
- **AC-2 narrowed:** the customer now gets only an in-app notice when the export finishes. A dated note on the line records that e-mail was dropped.
- **AC-5 added:** "The export is also available as a CSV file, not only as XLSX." It has no earlier criterion behind it and is backed by the decision's own wording.
- **Unchanged:** AC-1 (XLSX from the account page), AC-3, AC-4, the outcome in §2, the exclusion of scheduled exports, and the two AGENTS.md invariants in §4.
- **Change record:** added at the end of §3. It measures against commit `e2f55ca`, has one row for every earlier condition, and lists nothing as unaccounted for.
- **New open question in §5:** where the customer requests the CSV export. The decision doesn't say whether it's the account page, like XLSX. I left that location out of AC-5 instead of guessing.

**No gate needed:** the only file in the commit is a `docs/**.md` story. Under `.claude/review-gates.md` that counts as prose, so no review gate applies.

**What this unblocks:** design and planning can now work from AC-2 (narrowed) and AC-5.

**Still open:**
- **PR #12's reviews:** `review-gates.md` has no rule on what this change means for reviews that already ran. It only contains the prose paragraph. Until you decide, those reviews shouldn't count as covering AC-2 or AC-5.
- **CSV request location:** the open question in §5 needs an answer.

I haven't started anything further. The next gate, plan or implementation step is yours to start.
````

