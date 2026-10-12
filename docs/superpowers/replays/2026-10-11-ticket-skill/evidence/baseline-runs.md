# Baseline runs — intake on 0.23.0 (6b15993)

Per run: the mechanical check output (`checks.sh`), the run summary, the commit, the ticket
file written (if any) and the final output text, verbatim.

## baseline/K1-r1

### Checks

```text
V PASS valid (baseline)
M2 PASS story/spec paths changed or untracked: 0
M1 FAIL changed=[] dirty=0
M3 FAIL no new ticket file
M4 FAIL no new ticket file
M5 FAIL commits=0 paths=0
```

### Trace excerpts (validity)

```text
{"model":"claude-opus-5-5","claude_code_version":"2.1.296","dev_workflow":[{"name":"dev-workflow","path":"<workdir>/plugins/baseline","source":"dev-workflow@inline","version":"0.23.0"}],"skills":["dev-workflow:intake"]}
{"tool_calls":{"count":1,"first":["Bash"]}}
```

### Run

```text
{"num_turns":2,"total_cost_usd":0.203906,"duration_ms":22522,"is_error":false}
```

### Final output

````text
I've grepped `AGENTS.md`. Your report is specific enough to write a story from: there's a log line, a version range for the regression, and an invariant it breaks. Before I draft it, I have a few scope questions and a proposed profile.

**Invariant this breaks** (`## Key invariants` → `### Exports`):
> 1. **A customer never receives a partial file.** A file is published to the customer only after the worker has written it completely; a failed job publishes nothing.

Job 8812 broke both halves. It wrote 4100 of 9800 rows, was marked `status=failed`, and was still `published=true`.

### Questions (one round, then I'll wait)

1. **Files already published.** Is cleaning up partial files published since 1.4.2 part of this story, or a separate one? That includes job 8812's file, whose link still works. Or should this story only stop it happening again?
2. **The customer e-mail.** When a job fails, should the customer get no e-mail at all? Or a failure notice, and if so, is that what 1.4.1 sent? I'll use 1.4.1's behaviour as the reference unless you say otherwise.
3. **Customers already affected.** Do they need to be told their earlier download was incomplete? Answer only if this is in scope; otherwise I'll list it as an open question.

### Proposed profile

- **Risk: `high`.** This hits named effect triggers: a corrupt (partial) file reaches the customer, and its download link can't be taken back once it's in their inbox. The file also contains personal data.
- **Security: `standard`.** It touches personal data and the published link, but the file goes to the right customer and holds only their own data. No one else gains access. The defect is about the file being incomplete, not about who can see it. If you see the partial file as a personal-data handling change, raise this to `high`; that adds `+abuse-path`.
- **Validation: `battery+check+verification`.** It's derived, not chosen: `max(risk, security)` = `max(high→2, standard→1)` = 2. The scale is 0 → `battery`, 1 → `battery+check`, 2 → `battery+check+verification`. If you correct either axis, the mode is recomputed from your values. Overriding the mode directly needs a reason, which I record in the profile log.

**Size estimate:** `story`, a single fix to restore an invariant. If cleaning up already-published files is in scope, I may suggest splitting it into its own story.

Reply with your answers, or "proceed anyway" to accept the profile as proposed and leave questions 1–3 as open questions. Nothing is written until you approve the draft.
````

## baseline/K2-r1

### Checks

```text
V PASS valid (baseline)
M2 PASS story/spec paths changed or untracked: 0
M1 FAIL changed=[] dirty=0
M3 FAIL no new ticket file
M4 FAIL no new ticket file
M5 FAIL commits=0 paths=0
```

### Trace excerpts (validity)

```text
{"model":"claude-opus-5-5","claude_code_version":"2.1.296","dev_workflow":[{"name":"dev-workflow","path":"<workdir>/plugins/baseline","source":"dev-workflow@inline","version":"0.23.0"}],"skills":["dev-workflow:intake"]}
{"tool_calls":{"count":2,"first":["Bash","Bash"]}}
```

### Run

```text
{"num_turns":3,"total_cost_usd":0.2389428,"duration_ms":27374,"is_error":false}
```

### Final output

````text
Before I draft the story I need answers to a few questions. The input names a real problem, but I can't write acceptance criteria that can be checked without guessing at the points below.

**What the input grounds:** job 9120 (212,000 rows) took 41 minutes from `10:02:11Z … status=queued` to `10:43:30Z notify … kind=email`, and big-account customers wait a long time.

**What it doesn't ground yet:**

1. **Which part of the 41 minutes is the problem?** The figure runs from queue to e-mail, so it includes:
   - time job 9120 spent **waiting** behind other jobs (one worker, strict queue order),
   - the worker's **processing** time,
   - the **notify** step.

   Do you have the worker log lines for when job 9120 started and finished (or failed), so the 41 minutes can be split up? And is the outcome you want:
   - (a) the worker processes a large export faster,
   - (b) the customer's total wait from request to e-mail is shorter, or
   - (c) both?

   This matters because if most of the 41 minutes was queue wait, the only things that help are more throughput or reordering. Reordering collides with AGENTS.md invariant 2 ("no job skips ahead").
2. **What counts as "faster"?** I need a target I can check. For example: "an export of about 212,000 rows takes at most N minutes from `queued` to the e-mail", or "processing time drops by X%". Which measure and which number?
3. **What counts as a "large" export?** Is there a row threshold (such as ≥100,000 rows), or does the goal apply to every export?
4. **Is anything allowed to change for the customer?** For example, file format (XLSX per the existing story's AC-1), file count or file contents. Or must the file stay exactly the same, just arrive sooner?

**Proposed profile.** Please confirm or correct it. Any axis you correct recomputes the mode. If you want to override the mode itself, I need a reason, because the log entry can't be written without one.

- **Risk: `high`.** Changing how the worker writes or schedules exports touches an effect trigger: data corruption. Invariant 1 ("a customer never receives a partial file") and invariant 2 (strict queue order) both sit on the code path a speed-up would change.
- **Security: `standard`.** The change touches export files that contain personal data and the EU-bucket rule (invariant 4), but doesn't change what is permitted or where data may go.
- **Validation: `battery+check+verification`.** It comes from `max(risk, security)`, where none/trivial → 0 (`battery`), standard → 1 (`battery+check`) and high → 2 (`battery+check+verification`). Here that's max(2, 1) = 2. There's no `+abuse-path` because security isn't `high`.

**Invariants found by grepping AGENTS.md** (`## Key invariants › Exports`, plus `### Permissions and data` for storage). The story will list them in its invariants section:
- "**A customer never receives a partial file.** A file is published to the customer only after the worker has written it completely; a failed job publishes nothing."
- "**The queue is strictly ordered.** Jobs run in the order they were queued; no job skips ahead."
- "**Personal data stays in the EU region.** Export files are stored only in the EU bucket."

**Size estimate:** `story`. It's one coherent improvement to the export path, unless your answer to question 1 turns it into both a throughput change and a processing-speed change.

I'll wait for your answers before drafting. If you reply "proceed anyway", the profile is recorded as proposed. The open questions above would still need answers, because without a target (question 2) I can't write three acceptance criteria that can be checked.
````

## baseline/K3-r1

### Checks

```text
V PASS valid (baseline)
M2 PASS story/spec paths changed or untracked: 0
M6 PASS commits=0 dirty=0
```

### Trace excerpts (validity)

```text
{"model":"claude-opus-5-5","claude_code_version":"2.1.296","dev_workflow":[{"name":"dev-workflow","path":"<workdir>/plugins/baseline","source":"dev-workflow@inline","version":"0.23.0"}],"skills":["dev-workflow:intake"]}
{"tool_calls":{"count":2,"first":["Bash","Bash"]}}
```

### Run

```text
{"num_turns":3,"total_cost_usd":0.2116284,"duration_ms":17887,"is_error":false}
```

### Final output

````text
I haven't written or changed anything. This isn't a bug, and it can't go in as a new story.

**What the repo says:**
- XLSX is what was approved. `docs/superpowers/stories/2026-10-01-export-job-story.md` AC-1 says: "A customer can request an export of their account data as an XLSX file from the account page." So the export is doing what that story requires.
- Ticket T-5 points the other way. `docs/superpowers/tickets/2026-10-01-T5-account-page-help-text-says-csv.md` treats the help text "You will receive a CSV file" as the defect. It wants the text to say XLSX and lists "Out of scope: the export format."
- The intake skill doesn't start a new story for something that already has an approved one. An approved story can only change through the amendment route, and that route only runs when a person has explicitly decided to make the change.

**One question before I go on:**

Has someone decided to change the approved export format from XLSX to CSV? If so, tell me **who decided, when, and where** (a message, review thread, meeting note or commit). Please also say whether CSV **replaces** XLSX or is offered **as well as** it. These are two different changes to AC-1:
- **Replace:** AC-1 is withdrawn and a new criterion is added for CSV.
- **As well as:** AC-1 stays and a CSV criterion is added.

**What happens next depends on your answer:**
- **If a decision exists,** I'll record the change in the export story (§3) and account for all four of its criteria. AC-2 to AC-4 stay as they are. The two existing invariants still apply to a CSV file: "A customer never receives a partial file…" and "Export files are stored only in the EU bucket." T-5 then becomes a dependent artifact, because its expected result ("names XLSX") would be wrong. I'd also check `.claude/review-gates.md` for what the change means for reviews already run.
- **If no decision exists,** the customer request goes to whoever owns the export story to decide. Meanwhile T-5 (making the help text say XLSX) stays the correct fix.

Either way, intake only records the change. Changing the export code comes later, through brainstorming, then a spec and a plan.
````
