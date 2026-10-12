# Candidate set 2 — skill sha256 52b78e5bbfe1b0f3dd82e2214248d9f59d67788bef480a8803481c3bfe543d64

Per run: the mechanical check output (`checks.sh`), the run summary, the commit, the ticket
file written (if any) and the final output text, verbatim.

## candidate2/K1-r1

### Checks

```text
V PASS valid (candidate)
M2 PASS story/spec paths changed or untracked: 0
M1 PASS changed=[docs/superpowers/tickets/2026-10-12-T6-failed-export-job-publishes-a-partial.md] dirty=0
M3 PASS header-lines=1 category-fields=1 state-fields=1
M4 PASS story-line=1 story-lines-total=1
M5 PASS commits=1 paths=1
```

### Trace excerpts (validity)

```text
{"model":"claude-opus-5-5","claude_code_version":"2.1.296","dev_workflow":[{"name":"dev-workflow","path":"<workdir>/plugins/candidate2","source":"dev-workflow@inline","version":"0.24.0"}],"skills":["dev-workflow:intake","dev-workflow:ticket"]}
{"tool_calls":{"count":3,"first":["Bash","Bash","Bash"]}}
```

### Run

```text
{"num_turns":4,"total_cost_usd":0.2049512,"duration_ms":28463,"is_error":false}
a743d76 docs(ticket): T-6 failed-export-job-publishes-a-partial
```

### Ticket `docs/superpowers/tickets/2026-10-12-T6-failed-export-job-publishes-a-partial.md`

````markdown
# T-6 — Failed export job publishes a partial file

**Category:** regression · **State:** ready · **Severity:** blocker · **First seen:** 1.4.2 (1.4.1 did not do this, per the reporter)
**Story:** `docs/superpowers/stories/2026-10-01-export-job-story.md`
**Feature:** export job, docs/superpowers/stories/2026-10-01-export-job-story.md AC-3

## Commitment
"The customer never receives a partial file; a failed export publishes nothing and shows the failure on the account page." — docs/superpowers/stories/2026-10-01-export-job-story.md AC-3
"A customer never receives a partial file. A file is published to the customer only after the worker has written it completely; a failed job publishes nothing." — AGENTS.md § Key invariants › Exports, 1

## Observed
Job 8812 failed after writing 4100 of 9800 rows, yet its file was published and the download link in the customer's e-mail works — evidence: worker log on 1.4.2:
`2026-10-08T09:14:03Z worker job=8812 status=failed rows_written=4100/9800 published=true url=https://exports.example.eu/8812.xlsx`

## Expected
A failed job publishes nothing (no file at a customer-reachable URL, no download link sent) and the failure shows on the account page — source: docs/superpowers/stories/2026-10-01-export-job-story.md AC-3; AGENTS.md § Key invariants › Exports, 1

## Repro
1. On 1.4.2, queue an export job whose worker run fails part-way (job 8812: failed at 4100/9800 rows).
2. Read the worker log line for the job: `status=failed` together with `published=true`.
3. Open the URL from the log / the customer's e-mail: the partial XLSX downloads.

## Brief
- Fix scope: the worker's publish step in `worker/` — publishing (and the e-mail link it feeds) must happen only after the file is completely written and the job succeeded; find the 1.4.1 → 1.4.2 change that moved or decoupled it.
- Out of scope: retrying the failed job; storage region (AC-4); notification wording; cleanup of already-published partial files such as 8812.xlsx (an operational task, raise separately).
- Feedback loop: failing test at the nearest seam — first entry of the list, feasible: a worker test that makes a job fail after N of M rows; red before the fix: the job ends `status=failed` with `published=true` (a published URL / e-mail link exists).
- Read first: docs/superpowers/stories/2026-10-01-export-job-story.md (AC-2, AC-3); AGENTS.md § Key invariants › Exports, § Architecture (worker/, notify/); the 1.4.1..1.4.2 diff under worker/.

## Log
- 2026-10-12 · created · ready
````

### Final output

````text
I filed this as ticket T-6, a **regression** with severity **blocker**, and it's ready to fix. It's committed on its own as `a743d76`, at `docs/superpowers/tickets/2026-10-12-T6-failed-export-job-publishes-a-partial.md`.

- **What it breaks:** two existing rules that say the same thing. One is AC-3 in `docs/superpowers/stories/2026-10-01-export-job-story.md`: "The customer never receives a partial file; a failed export publishes nothing and shows the failure on the account page." The other is invariant 1 under Key invariants › Exports in `AGENTS.md`. Since this is a bug against an approved rule, it's a ticket and not intake.
- **Evidence:** the worker log line for job 8812 shows `status=failed rows_written=4100/9800 published=true`. It was first seen in 1.4.2; you report that 1.4.1 didn't do this.
- **Severity:** blocker, because it breaks an invariant.
- **Fix scope:** the publish step in `worker/`. Publishing, and the e-mail link that comes from it, must happen only after the job succeeds with a complete file. Start by looking at the 1.4.1 → 1.4.2 changes under `worker/`.
- **Out of scope:** retries, storage region and notice wording. Removing partial files that are already public, like `8812.xlsx`, is also out of scope. The customer's link still works, so that cleanup should probably be raised separately and soon.
- **Test to write first:** a worker test that makes a job fail after N of M rows. Before the fix it should fail, showing the job ending `failed` with `published=true`.

Next steps:
1. `/dev-workflow:ticket T-6 in-progress`
2. Write that worker test and confirm it fails on this defect.
3. Fix it, check the test passes, then run `make check`.
4. Run Gate B on the diff. The call carries the ticket path and the story path `docs/superpowers/stories/2026-10-01-export-job-story.md`.
5. Do the closing step from the gate rules, then `/dev-workflow:ticket T-6 done <fix commit>`.
````

## candidate2/K1-r2

### Checks

```text
V PASS valid (candidate)
M2 PASS story/spec paths changed or untracked: 0
M1 PASS changed=[docs/superpowers/tickets/2026-10-12-T6-failed-export-publishes-a-partial-file.md] dirty=0
M3 PASS header-lines=1 category-fields=1 state-fields=1
M4 PASS story-line=1 story-lines-total=1
M5 PASS commits=1 paths=1
```

### Trace excerpts (validity)

```text
{"model":"claude-opus-5-5","claude_code_version":"2.1.296","dev_workflow":[{"name":"dev-workflow","path":"<workdir>/plugins/candidate2","source":"dev-workflow@inline","version":"0.24.0"}],"skills":["dev-workflow:intake","dev-workflow:ticket"]}
{"tool_calls":{"count":3,"first":["Bash","Bash","Bash"]}}
```

### Run

```text
{"num_turns":4,"total_cost_usd":0.21025500000000003,"duration_ms":28293,"is_error":false}
6f0eabe docs(ticket): T-6 failed-export-publishes-a-partial-file
```

### Ticket `docs/superpowers/tickets/2026-10-12-T6-failed-export-publishes-a-partial-file.md`

````markdown
# T-6 — Failed export publishes a partial file

**Category:** regression · **State:** ready · **Severity:** blocker · **First seen:** 1.4.2 (1.4.1 not affected, per reporter)
**Story:** `docs/superpowers/stories/2026-10-01-export-job-story.md`
**Feature:** export job, docs/superpowers/stories/2026-10-01-export-job-story.md AC-3

## Commitment
"The customer never receives a partial file; a failed export publishes nothing and shows the failure on the account page." — docs/superpowers/stories/2026-10-01-export-job-story.md AC-3
"A customer never receives a partial file. A file is published to the customer only after the worker has written it completely; a failed job publishes nothing." — AGENTS.md § Key invariants › Exports, 1

## Observed
A job that failed after writing 4100 of 9800 rows was published; the download link in the customer's e-mail works and serves the broken file — evidence: worker log on 1.4.2:
`2026-10-08T09:14:03Z worker job=8812 status=failed rows_written=4100/9800 published=true url=https://exports.example.eu/8812.xlsx`

## Expected
A failed job publishes nothing (no URL, no customer e-mail with a link) and the failure is shown on the account page — source: docs/superpowers/stories/2026-10-01-export-job-story.md AC-3; AGENTS.md § Key invariants › Exports, 1

## Repro
1. On 1.4.2, queue an export whose job fails part-way through writing (job 8812 failed at 4100/9800 rows; the failure cause is not in the report).
2. Observe the worker log line shows `status=failed … published=true` and the customer receives an e-mail with a working link.

## Brief
- Fix scope: the worker's publish step — publish (and trigger the finished notification) only after the file is completely written and the job succeeded; a failed job publishes nothing. Find what changed in this path between 1.4.1 and 1.4.2.
- Out of scope: the cause of job 8812's failure itself; queue ordering (T-4); e-mail notice delivery (T-2); unpublishing or contacting the customer about the already-published 8812.xlsx (an operational follow-up, not this fix).
- Feedback loop: failing test at the nearest seam — a worker test that injects a write failure after N of M rows and asserts the job ends `failed`, nothing is published (no URL, no object in the export bucket's published location) and no "finished" notice/e-mail is sent; red before the fix: the job is `failed` yet `published=true` with a URL.
- Read first: docs/superpowers/stories/2026-10-01-export-job-story.md (AC-2, AC-3); AGENTS.md § Key invariants › Exports, § Architecture (`worker/`, `notify/`); the 1.4.1→1.4.2 diff of `worker/`.

## Log
- 2026-10-12 · created · ready
````

### Final output

````text
I filed ticket T-6 as a **ready regression with severity blocker**, and committed it on its own as `6f0eabe`. It's at `docs/superpowers/tickets/2026-10-12-T6-failed-export-publishes-a-partial-file.md`.

- **What it breaks:** two existing rules. One is AC-3 in `docs/superpowers/stories/2026-10-01-export-job-story.md`: "a failed export publishes nothing". The other is the first export rule in `AGENTS.md` (§ Key invariants): a customer never receives a partial file. So this doesn't change any rule, and it doesn't need to go through intake.
- **Evidence:** your worker log line for job 8812 (`status=failed rows_written=4100/9800 published=true`). It was first seen in 1.4.2; 1.4.1 was fine.
- **How to catch it:** a worker test that makes a job fail part-way through writing. It should check that the job ends `failed`, nothing is published, and no "finished" e-mail or notice is sent. Before the fix, the test fails because the job comes out `failed` but `published=true` with a URL.
- **Where to look first:** what changed in `worker/` between 1.4.1 and 1.4.2.
- **Not covered by this ticket:** the customer still has a working link to the broken `8812.xlsx`. Taking that file down or contacting the customer has to be done separately; the ticket lists it as out of scope.

**Next steps:**
1. `/dev-workflow:ticket T-6 in-progress`
2. Write the worker test above and confirm it fails on the current code.
3. Fix the code until the test passes, then run `make check`.
4. Run Gate B on the diff. Pass it the ticket path and the story `docs/superpowers/stories/2026-10-01-export-job-story.md`.
5. Do the closing step the gate rules require, then `/dev-workflow:ticket T-6 done <fix commit>`.
````

## candidate2/K1-r3

### Checks

```text
V PASS valid (candidate)
M2 PASS story/spec paths changed or untracked: 0
M1 PASS changed=[docs/superpowers/tickets/2026-10-12-T6-failed-export-job-publishes-a-partial.md] dirty=0
M3 PASS header-lines=1 category-fields=1 state-fields=1
M4 PASS story-line=1 story-lines-total=1
M5 PASS commits=1 paths=1
```

### Trace excerpts (validity)

```text
{"model":"claude-opus-5-5","claude_code_version":"2.1.296","dev_workflow":[{"name":"dev-workflow","path":"<workdir>/plugins/candidate2","source":"dev-workflow@inline","version":"0.24.0"}],"skills":["dev-workflow:intake","dev-workflow:ticket"]}
{"tool_calls":{"count":3,"first":["Bash","Bash","Bash"]}}
```

### Run

```text
{"num_turns":4,"total_cost_usd":0.2066596,"duration_ms":28463,"is_error":false}
5771186 docs(ticket): T-6 failed-export-job-publishes-a-partial
```

### Ticket `docs/superpowers/tickets/2026-10-12-T6-failed-export-job-publishes-a-partial.md`

````markdown
# T-6 — Failed export job publishes a partial file

**Category:** regression · **State:** ready · **Severity:** blocker · **First seen:** 1.4.2 (1.4.1 not affected, per reporter)
**Story:** `docs/superpowers/stories/2026-10-01-export-job-story.md`
**Feature:** export job, docs/superpowers/stories/2026-10-01-export-job-story.md AC-3

## Commitment
"The customer never receives a partial file; a failed export publishes nothing and shows the failure on the account page." — docs/superpowers/stories/2026-10-01-export-job-story.md AC-3
"A customer never receives a partial file. A file is published to the customer only after the worker has written it completely; a failed job publishes nothing." — AGENTS.md § Key invariants › Exports, 1

## Observed
Job 8812 failed after writing 4100 of 9800 rows, yet its file was published and the download link in the customer's e-mail works — evidence: worker log on 1.4.2:
`2026-10-08T09:14:03Z worker job=8812 status=failed rows_written=4100/9800 published=true url=https://exports.example.eu/8812.xlsx`

## Expected
A job that ends `status=failed` publishes nothing (no URL, no download link, no "finished" e-mail) and the failure shows on the account page — source: docs/superpowers/stories/2026-10-01-export-job-story.md AC-3; AGENTS.md § Key invariants › Exports, 1

## Repro
1. On 1.4.2, queue an export whose worker job fails part-way through writing rows (how job 8812 failed is unknown — the log line gives no failure cause).
2. Check the worker log for `published=true` on the failed job, and the customer's e-mail for a working link.

## Brief
- Fix scope: the worker's publish step — publish only after the file is completely written and the job succeeded; a failed job publishes nothing and no "finished" e-mail goes out. Find the 1.4.1 → 1.4.2 change that made publishing happen on failure.
- Out of scope: the cause of job 8812's failure; e-mail and notice wording; storage region (the URL is the EU host, AC-4 is not in question); revoking the already-sent link for job 8812 (an operational step, not this fix).
- Feedback loop: failing test at the nearest seam — a worker test that makes a job fail after writing part of its rows and asserts nothing is published and no e-mail is sent; red before the fix: the job is marked failed and still published (`published=true`, URL set). Earliest entry is feasible; if the publish logic is hard to isolate, a bisection harness between 1.4.1 and 1.4.2 locates the change.
- Read first: docs/superpowers/stories/2026-10-01-export-job-story.md (AC-2, AC-3); AGENTS.md § Key invariants › Exports, § Architecture (worker/, notify/).

## Log
- 2026-10-12 · created · ready
````

### Final output

````text
I created ticket **T-6** and committed it on its own (`5771186`):
`docs/superpowers/tickets/2026-10-12-T6-failed-export-job-publishes-a-partial.md`

- **Category / state / severity:** regression · ready · blocker. It's a blocker because it breaks an invariant: a customer got a partial file.
- **First seen:** 1.4.2, according to your report; 1.4.1 was not affected.
- **What it's held to:** acceptance criterion 3 of `docs/superpowers/stories/2026-10-01-export-job-story.md` and invariant 1 in `AGENTS.md` (Exports). Both say a failed export publishes nothing. The fix brings the code back in line with those rules without changing them, so this is a ticket rather than an intake item.
- **Evidence:** the worker log line for job 8812 (`status=failed rows_written=4100/9800 published=true`).
- **How to check the fix:** a worker test that makes a job fail partway through and checks that nothing is published and no e-mail goes out. Before the fix it should fail, because the failed job still gets published. If the publish logic is hard to test on its own, comparing 1.4.1 against 1.4.2 step by step can find the change that caused it.
- **Not covered by this ticket:** why job 8812 failed, and turning off the link the customer already has. Someone should probably handle that link separately, since it currently works.

**Next steps:**
1. `/dev-workflow:ticket T-6 in-progress`
2. Get the worker test failing on this defect.
3. Fix it, confirm the test passes, then run `make check`.
4. Run Gate B on the diff. Pass it the ticket path and the story path `docs/superpowers/stories/2026-10-01-export-job-story.md`.
5. Do the closing step from the gate rules, then `/dev-workflow:ticket T-6 done <fix commit>`.

The fix will change worker code, so it isn't prose-only and needs Gate B.
````

## candidate2/K2-r1

### Checks

```text
V PASS valid (candidate)
M2 PASS story/spec paths changed or untracked: 0
M1 PASS changed=[docs/superpowers/tickets/2026-10-12-T6-large-exports-take-41-minutes-from-queue.md] dirty=0
M3 PASS header-lines=1 category-fields=1 state-fields=1
M4 PASS story-line=1 story-lines-total=1
M5 PASS commits=1 paths=1
```

### Trace excerpts (validity)

```text
{"model":"claude-opus-5-5","claude_code_version":"2.1.296","dev_workflow":[{"name":"dev-workflow","path":"<workdir>/plugins/candidate2","source":"dev-workflow@inline","version":"0.24.0"}],"skills":["dev-workflow:intake","dev-workflow:ticket"]}
{"tool_calls":{"count":3,"first":["Bash","Bash","Bash"]}}
```

### Run

```text
{"num_turns":4,"total_cost_usd":0.23509239999999998,"duration_ms":41466,"is_error":false}
09d947e docs(ticket): T-6 large-exports-take-41-minutes-from-queue
```

### Ticket `docs/superpowers/tickets/2026-10-12-T6-large-exports-take-41-minutes-from-queue.md`

````markdown
# T-6 — Large exports take 41 minutes from queue to e-mail

**Category:** improvement · **State:** needs-info · **Severity:** unknown — the 41 minutes are not split into queue wait and processing, so whether this is a worker design flaw is not known · **First seen:** unknown — the report names no version or commit
**Story:** `docs/superpowers/stories/2026-10-01-export-job-story.md`
**Feature:** export job, docs/superpowers/stories/2026-10-01-export-job-story.md AC-1

## Commitment
"A customer can request an export of their account data as an XLSX file from the account page." — docs/superpowers/stories/2026-10-01-export-job-story.md AC-1

## Observed
Job 9120 (212,000 rows) took 41 min 19 s from queued to the e-mail notice — evidence: worker log `2026-10-09T10:02:11Z worker job=9120 status=queued` and `2026-10-09T10:43:30Z notify job=9120 kind=email`. The span includes any time the job waited behind earlier jobs in the single ordered queue; no start or file-written line was quoted.

## Expected
Large exports finish faster — source: docs/superpowers/stories/2026-10-01-export-job-story.md AC-1; requested by: reporter of this ticket (customers with big accounts wait a long time). Target: unknown — the request states none.

## Repro
1. Queue an export for an account with about 212,000 rows.
2. Compare the worker's `status=queued` line with the `notify … kind=email` line for that job.

## Brief
- Fix scope: speed up the processing of a single large export inside the worker (row fetch, XLSX writing, publish, notify), only once the questions below show processing — not queue wait — dominates.
- Out of scope: any change that runs jobs out of queue order or in parallel workers, prioritises big or small jobs (AGENTS.md Key invariants 2 and the single-worker architecture); publishing a file before it is fully written or streaming partial output (AGENTS.md Key invariants 1, story AC-3); storing files or temp files outside the EU bucket (AGENTS.md Key invariants 4, story AC-4); a new file format. Any of these alters a commitment and goes to `/dev-workflow:intake`.
- Feedback loop: failing test at the nearest seam — a worker test running one export over a 212,000-row fixture and asserting the processing time is under the target; nothing earlier in the list exists, and it is the first entry. Red before the fix: processing time above the target. Not runnable until a target is set (question 1).
- Read first: docs/superpowers/stories/2026-10-01-export-job-story.md (AC-1, AC-3, AC-4); AGENTS.md `## Architecture` and `## Key invariants` (Exports 1–2, Permissions and data 4).

## Questions for the reporter
- Expected: what duration is acceptable, and for what size (e.g. "212,000 rows written within N minutes of the job starting"), and is it measured from queued or from start of processing?
- Severity: of the 41 minutes for job 9120, how much was queue wait behind earlier jobs and how much was the worker processing it? Worker log lines for job 9120's start and file-written events would answer this.

## Log
- 2026-10-12 · created · needs-info
````

### Final output

````text
I created ticket T-6 and committed it on its own as `09d947e`. It's marked **needs-info**, so it isn't ready for anyone to start a fix yet.

`docs/superpowers/tickets/2026-10-12-T6-large-exports-take-41-minutes-from-queue.md`

- **Category:** improvement. Severity and the first version it appeared in are both unknown.
- **Commitment:** this stays inside the export story's first acceptance criterion, AC-1 ("A customer can request an export of their account data as an XLSX file…"). Making exports faster changes no promise, as long as the fix stays inside the limits below.
- **Limits on the fix:** it must not run jobs out of order, add parallel workers, let big or small jobs jump the queue, publish a half-written file, or store anything outside the EU bucket. Any of those would change a project rule, so it would go to `/dev-workflow:intake` instead.
- **Why it's not ready:** the report gives no target speed, so there's no clear point at which the fix is done. Also, the 41 minutes run from "queued" to "e-mail sent". That includes any time job 9120 spent waiting behind other jobs, since one worker handles the queue in order. So the slowness might not be in the export itself.

## Questions for the reporter
1. **Target:** how long is acceptable, and for how many rows? Should it be measured from when the job is queued or from when the worker starts it?
2. **Where the time went:** of the 41 minutes for job 9120, how much was waiting in the queue and how much was the worker processing it? The worker log lines for when job 9120 started and when its file was written would answer this.

Not ready to build: answer the questions, then `/dev-workflow:ticket T-6 ready`
````

## candidate2/K2-r2

### Checks

```text
V PASS valid (candidate)
M2 PASS story/spec paths changed or untracked: 0
M1 PASS changed=[docs/superpowers/tickets/2026-10-12-T6-large-exports-are-slow.md] dirty=0
M3 PASS header-lines=1 category-fields=1 state-fields=1
M4 PASS story-line=1 story-lines-total=1
M5 PASS commits=1 paths=1
```

### Trace excerpts (validity)

```text
{"model":"claude-opus-5-5","claude_code_version":"2.1.296","dev_workflow":[{"name":"dev-workflow","path":"<workdir>/plugins/candidate2","source":"dev-workflow@inline","version":"0.24.0"}],"skills":["dev-workflow:intake","dev-workflow:ticket"]}
{"tool_calls":{"count":5,"first":["Bash","Bash","Bash","Write","Bash"]}}
```

### Run

```text
{"num_turns":6,"total_cost_usd":0.2783534,"duration_ms":49362,"is_error":false}
3173924 docs(ticket): T-6 large-exports-are-slow
```

### Ticket `docs/superpowers/tickets/2026-10-12-T6-large-exports-are-slow.md`

````markdown
# T-6 — Large exports are slow

**Category:** improvement · **State:** needs-info · **Severity:** unknown — the 41 minutes are not split into queue wait and worker processing, so neither the impact nor whether rework is needed is known · **First seen:** unknown — no version or commit reported
**Story:** `docs/superpowers/stories/2026-10-01-export-job-story.md`
**Feature:** export job, docs/superpowers/stories/2026-10-01-export-job-story.md AC-1

## Commitment
"A customer can request an export of their account data as an XLSX file from the account page." — docs/superpowers/stories/2026-10-01-export-job-story.md AC-1

## Observed
Job 9120 (212,000 rows) took 41 min 19 s from queued to the e-mail notice — evidence: worker log lines `2026-10-09T10:02:11Z worker job=9120 status=queued` and `2026-10-09T10:43:30Z notify job=9120 kind=email`. The interval starts at `queued`, so it includes any time the job waited behind earlier jobs in the single ordered queue; how much of it the worker spent on job 9120 itself is not in the evidence.

## Expected
Large exports finish faster, still as a complete XLSX file per AC-1 — source: docs/superpowers/stories/2026-10-01-export-job-story.md AC-1; requested by: the reporter of this ticket, in the ticket text ("customers with big accounts wait a long time")

## Repro
1. Queue an export for an account with about 212,000 rows.
2. Read the worker log from `status=queued` to `notify ... kind=email` for that job.

## Brief
- Fix scope: the time the worker needs to produce and publish a large export, once the questions below locate where the time goes.
- Out of scope: running jobs in parallel or letting large jobs skip ahead (AGENTS.md invariant 2, strictly ordered queue, single worker); publishing or streaming a file before it is written completely (AGENTS.md invariant 1, story AC-3); storing files outside the EU bucket (AGENTS.md invariant 4, story AC-4); notification changes (AC-2).
- Feedback loop: failing test at the nearest seam — a worker test that exports a 212,000-row fixture and asserts its duration against the target; feasible as the first entry, but it cannot be written until a target exists; red before the fix: the measured worker duration above the target (target unknown — see Questions).
- Read first: docs/superpowers/stories/2026-10-01-export-job-story.md (AC-1, AC-3, AC-4), AGENTS.md § Key invariants (Exports 1–2, invariant 4) and § Architecture (worker/).

## Questions for the reporter
- Of the 41 minutes, how long did job 9120 wait in the queue, and how long did the worker run it? (e.g. the log lines for its start and for the file being written)
- What duration would be acceptable for an export of this size — a target the feedback loop can test against?
- How many customers have exports this large, or how often does it come up? (sets the severity)

## Log
- 2026-10-12 · created · needs-info
````

### Final output

````text
I created ticket T-6 as `needs-info` and committed it on its own as `3173924`: `docs/superpowers/tickets/2026-10-12-T6-large-exports-are-slow.md`. It isn't ready to build yet because there is no target to measure a fix against.

**Commitment check.** Making exports faster changes no approved promise and sets no new limit, so this stays a ticket. It falls under the export feature: "A customer can request an export of their account data as an XLSX file from the account page" (`docs/superpowers/stories/2026-10-01-export-job-story.md` AC-1). It doesn't need to go to intake.

**What the evidence doesn't show.** The 41 min 19 s is measured from `status=queued` to the e-mail. There is one worker and the queue runs strictly in order (AGENTS.md invariant 2), so part of that time may have been job 9120 waiting behind earlier jobs. The log doesn't show how much. Until we know where the time went, the severity and the scope of the fix are unknown.

**Guardrails in the brief.** Three common ways to speed this up would break the project's rules, so the brief marks them out of scope:
- running jobs in parallel or letting big jobs jump the queue (invariant 2);
- streaming or publishing a file before it is fully written (invariant 1, AC-3);
- storing files anywhere other than the EU bucket (invariant 4, AC-4).

**Questions for the reporter**
- Of the 41 minutes, how long did job 9120 wait in the queue, and how long did the worker take to run it? The log lines for when the job started and when the file was written would answer this.
- What duration is acceptable for an export this size? The test that checks the fix needs this as its target.
- How many customers have exports this large, or how often does this come up? This sets the severity.

Not ready to build: answer the questions, then /dev-workflow:ticket T-6 ready
````

## candidate2/K2-r3

### Checks

```text
V PASS valid (candidate)
M2 PASS story/spec paths changed or untracked: 0
M1 PASS changed=[docs/superpowers/tickets/2026-10-12-T6-large-exports-take-41-minutes-from-queue.md] dirty=0
M3 PASS header-lines=1 category-fields=1 state-fields=1
M4 PASS story-line=1 story-lines-total=1
M5 PASS commits=1 paths=1
```

### Trace excerpts (validity)

```text
{"model":"claude-opus-5-5","claude_code_version":"2.1.296","dev_workflow":[{"name":"dev-workflow","path":"<workdir>/plugins/candidate2","source":"dev-workflow@inline","version":"0.24.0"}],"skills":["dev-workflow:intake","dev-workflow:ticket"]}
{"tool_calls":{"count":5,"first":["Bash","Bash","Bash","Write","Bash"]}}
```

### Run

```text
{"num_turns":6,"total_cost_usd":0.28472840000000005,"duration_ms":49520,"is_error":false}
232fcfb docs(ticket): T-6 large-exports-take-41-minutes-from-queue
```

### Ticket `docs/superpowers/tickets/2026-10-12-T6-large-exports-take-41-minutes-from-queue.md`

````markdown
# T-6 — Large exports take 41 minutes from queue to e-mail

**Category:** improvement · **State:** needs-info · **Severity:** unknown — the report gives no impact beyond "a long time", and it is not known whether the time is spent waiting in the queue or processing · **First seen:** unknown — the report names no version or commit
**Story:** `docs/superpowers/stories/2026-10-01-export-job-story.md`
**Feature:** export job, docs/superpowers/stories/2026-10-01-export-job-story.md AC-1

## Commitment
"A customer can request an export of their account data as an XLSX file from the account page." — docs/superpowers/stories/2026-10-01-export-job-story.md AC-1

## Observed
Job 9120 (212,000 rows) took 41 min 19 s from being queued to the e-mail notice — evidence: worker log lines `2026-10-09T10:02:11Z worker job=9120 status=queued` and `2026-10-09T10:43:30Z notify job=9120 kind=email`. The log lines given do not show when the worker started or finished the job, so queue wait and processing time cannot be separated.

## Expected
Large exports reach the customer faster — source: docs/superpowers/stories/2026-10-01-export-job-story.md AC-1; requested by: the reporter of this ticket (input to `/dev-workflow:ticket`, 2026-10-12). Target: unknown — the request states none.

## Repro
1. Queue an export for an account with about 212,000 rows from the account page.
2. Read the worker log from `status=queued` to `notify ... kind=email` for that job.

## Brief
- Fix scope: shorten the time a large export spends in `worker/` (or the step the questions below locate) while one worker still runs one job at a time in queue order, publishes only a completely written file, and stores it only in the EU bucket.
- Out of scope: more workers or parallel jobs, letting large or small jobs skip ahead (AGENTS.md § Key invariants › Exports 2), publishing or streaming a file before it is complete (Exports 1, AC-3), changing the file format (AC-1), a progress indicator (T-1, wontfix), notification changes (AC-2).
- Feedback loop: throwaway harness — times the worker on a 212,000-row fixture account and logs queue wait, processing and notify separately; a failing test at the nearest seam, an HTTP/CLI script or a headless-browser script cannot go red without a target duration, and no captured trace beyond the two log lines exists; red before the fix: the harness's processing time is above the target the reporter names.
- Read first: docs/superpowers/stories/2026-10-01-export-job-story.md (AC-1, AC-3, AC-4), AGENTS.md § Architecture (worker/, notify/) and § Key invariants › Exports 1–2, › Permissions and data 4.

## Questions for the reporter
- Target: how fast should a 212,000-row export be, from queue to e-mail (or from processing start to e-mail)?
- Severity: how many customers or accounts are affected, and has any of them complained or been harmed beyond waiting?
- Where did the 41 minutes go: please attach the worker log lines for job 9120 between `status=queued` and the e-mail (job start, file written, publish), and say how many jobs were ahead of it in the queue.
- First seen: since which version or commit are large exports this slow, or have they always been?

## Log
- 2026-10-12 · created · needs-info
````

### Final output

````text
I created ticket T-6 and committed it on its own (`232fcfb`). It isn't ready to build yet: it's in `needs-info` because the report gives no target time and no severity.

**File:** `docs/superpowers/tickets/2026-10-12-T6-large-exports-take-41-minutes-from-queue.md`

- **Category:** improvement. It sets no new limit, so it stays inside the export feature's commitment: story AC-1, "A customer can request an export of their account data as an XLSX file from the account page."
- **Observed:** job 9120 (212,000 rows) took 41 min 19 s from being queued to the e-mail, based on the two worker log lines. Those lines can't show how much of that time was spent waiting in the queue and how much was processing.
- **Brief:** the fix must keep one worker running jobs in strict queue order. It must publish only a completely written file and store files only in the EU bucket. Adding workers, letting jobs skip ahead, streaming part of a file and adding a progress bar (T-1, already closed as won't-fix) are all out of scope.
- **Feedback loop:** a throwaway harness that times a 212,000-row test account and reports queue wait, processing and notification separately. A failing test isn't possible until there is a target time to test against.

**Questions for the reporter**
1. **Target:** how fast should a 212,000-row export be, either from queue to e-mail or from the start of processing to e-mail?
2. **Severity:** how many customers or accounts are affected, and has anyone complained or been harmed beyond waiting?
3. **Where the time went:** please send the worker log lines for job 9120 between `status=queued` and the e-mail (job start, file written, publish), and say how many jobs were ahead of it in the queue.
4. **First seen:** since which version or commit have large exports been this slow, or were they always this slow?

Not ready to build: answer the questions, then /dev-workflow:ticket T-6 ready
````

## candidate2/K3-r1

### Checks

```text
V PASS valid (candidate)
M2 PASS story/spec paths changed or untracked: 0
M6 PASS commits=0 dirty=0
```

### Trace excerpts (validity)

```text
{"model":"claude-opus-5-5","claude_code_version":"2.1.296","dev_workflow":[{"name":"dev-workflow","path":"<workdir>/plugins/candidate2","source":"dev-workflow@inline","version":"0.24.0"}],"skills":["dev-workflow:intake","dev-workflow:ticket"]}
{"tool_calls":{"count":1,"first":["Bash"]}}
```

### Run

```text
{"num_turns":2,"total_cost_usd":0.1328008,"duration_ms":9485,"is_error":false}
```

### Final output

````text
I didn't write a ticket. This request changes an approved commitment, so it needs to go through intake instead of the ticket flow.

**Why:** The approved export story says the export is XLSX. In `docs/superpowers/stories/2026-10-01-export-job-story.md`, AC-1 reads:

> "A customer can request an export of their account data as an XLSX file from the account page."

So an XLSX file is the agreed behaviour, not a bug. Switching to CSV changes what the story promises, and that is a decision for intake to record, not something to fix under a ticket. The existing ticket T-5 points the same way: it treats the CSV help text as the defect and lists the export format as out of scope.

**Next step** (you start it; I haven't run it):

```
/dev-workflow:intake Amend the approved docs/superpowers/stories/2026-10-01-export-job-story.md. Decision: none yet — intake will ask. Bug: the export comes out as XLSX, but our customers want CSV. Please fix the export so it produces a CSV file instead.
```

If the format moves to CSV, T-5 (the help text saying CSV) will need another look, because what it expects would change.
````

## candidate2/K3-r2

### Checks

```text
V PASS valid (candidate)
M2 PASS story/spec paths changed or untracked: 0
M6 PASS commits=0 dirty=0
```

### Trace excerpts (validity)

```text
{"model":"claude-opus-5-5","claude_code_version":"2.1.296","dev_workflow":[{"name":"dev-workflow","path":"<workdir>/plugins/candidate2","source":"dev-workflow@inline","version":"0.24.0"}],"skills":["dev-workflow:intake","dev-workflow:ticket"]}
{"tool_calls":{"count":2,"first":["Bash","Bash"]}}
```

### Run

```text
{"num_turns":3,"total_cost_usd":0.15016780000000002,"duration_ms":12662,"is_error":false}
```

### Final output

````text
I didn't write a ticket. This isn't a bug: XLSX output is the approved behaviour, so switching to CSV means changing the commitment.

**Why:** the approved story requires XLSX:

> "**AC-1** A customer can request an export of their account data as an XLSX file from the account page." — `docs/superpowers/stories/2026-10-01-export-job-story.md` AC-1

The export does what AC-1 says. Making it produce CSV changes the story's agreed behaviour, and a ticket can only cover fixes that stay inside an approved commitment. The existing ticket T-5 (`docs/superpowers/tickets/2026-10-01-T5-account-page-help-text-says-csv.md`) points the same way: it treats a help text that says "CSV" as the defect and XLSX as the correct format.

**Next step:** the change has to go through intake as an amendment to the story. Run this yourself:

```
/dev-workflow:intake Amend the approved docs/superpowers/stories/2026-10-01-export-job-story.md. Decision: none yet — intake will ask. Bug: the export comes out as XLSX, but our customers want CSV. Please fix the export so it produces a CSV file instead.
```

If the amendment goes through, T-5 will be out of date: it currently tells someone to change the help text to say XLSX. Review it during the same intake, and mark it `wontfix` or rewrite it.
````

## candidate2/K3-r3

### Checks

```text
V PASS valid (candidate)
M2 PASS story/spec paths changed or untracked: 0
M6 PASS commits=0 dirty=0
```

### Trace excerpts (validity)

```text
{"model":"claude-opus-5-5","claude_code_version":"2.1.296","dev_workflow":[{"name":"dev-workflow","path":"<workdir>/plugins/candidate2","source":"dev-workflow@inline","version":"0.24.0"}],"skills":["dev-workflow:intake","dev-workflow:ticket"]}
{"tool_calls":{"count":2,"first":["Bash","Bash"]}}
```

### Run

```text
{"num_turns":3,"total_cost_usd":0.1475222,"duration_ms":18444,"is_error":false}
```

### Final output

````text
I didn't write a ticket, because this isn't a bug. XLSX is the format the export story commits to:

> "A customer can request an export of their account data as an XLSX file from the account page." — `docs/superpowers/stories/2026-10-01-export-job-story.md` AC-1

So the export works as approved. Making it produce CSV changes that commitment, and a change like that goes to intake rather than a ticket.

One thing to know first: ticket **T-5** (`docs/superpowers/tickets/2026-10-01-T5-account-page-help-text-says-csv.md`, state `ready`) asks for the opposite. It wants the account-page help text changed from "CSV" to "XLSX" to match AC-1. If intake approves the switch to CSV, T-5 should be closed as `wontfix`, or rewritten to match the new criterion, before anyone builds it.

To start the change, run:

```
/dev-workflow:intake Amend the approved docs/superpowers/stories/2026-10-01-export-job-story.md. Decision: none yet — intake will ask. Bug: the export comes out as XLSX, but our customers want CSV. Please fix the export so it produces a CSV file instead.
```

The report says customers want CSV, but nobody has actually decided to amend AC-1 yet. That's why the decision says "none yet" and intake will ask for one.
````

## candidate2/L-r1

### Checks

```text
V PASS valid (candidate)
M2 PASS story/spec paths changed or untracked: 0
M6 PASS commits=0 dirty=0
```

### Trace excerpts (validity)

```text
{"model":"claude-opus-5-5","claude_code_version":"2.1.296","dev_workflow":[{"name":"dev-workflow","path":"<workdir>/plugins/candidate2","source":"dev-workflow@inline","version":"0.24.0"}],"skills":["dev-workflow:intake","dev-workflow:ticket"]}
{"tool_calls":{"count":1,"first":["Bash"]}}
```

### Run

```text
{"num_turns":2,"total_cost_usd":0.1286398,"duration_ms":9190,"is_error":false}
```

### Final output

````text
```text
needs-triage
(none)

needs-info
T-2 · bug · unknown — how many customers are affected is not known · E-mail notice missing for some finished exports · docs/superpowers/tickets/2026-10-03-T2-e-mail-notice-missing-for-some-finished.md
T-4 · regression · unknown — no job order was captured · Queue order looks wrong after the 1.4.0 deploy · docs/superpowers/tickets/2026-10-03-T4-queue-order-looks-wrong-after-the-1-4-0.md

ready
T-5 · docs · minor · Account page help text says CSV · docs/superpowers/tickets/2026-10-01-T5-account-page-help-text-says-csv.md
T-3 · bug · minor · In-app notice shows the queue date, not the finish date · docs/superpowers/tickets/2026-10-04-T3-in-app-notice-shows-the-queue-date-not.md
```

T-1 is `wontfix`, so it isn't listed. No ticket file has a defect, so there is no `needs repair` section.
````
