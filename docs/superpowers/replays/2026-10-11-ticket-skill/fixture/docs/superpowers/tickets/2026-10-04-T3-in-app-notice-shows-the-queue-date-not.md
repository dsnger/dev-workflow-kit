# T-3 — In-app notice shows the queue date, not the finish date

**Category:** bug · **State:** ready · **Severity:** minor · **First seen:** 1.3.0
**Story:** `docs/superpowers/stories/2026-10-01-export-job-story.md`
**Feature:** export job, docs/superpowers/stories/2026-10-01-export-job-story.md AC-2

## Commitment
"When the export finishes, the customer is notified by e-mail and by an in-app notice." — docs/superpowers/stories/2026-10-01-export-job-story.md AC-2

## Observed
The notice reads "Export from 2026-10-03" for a job that finished on 2026-10-04 — evidence: log line `2026-10-04T00:12:09Z notify job=8120 kind=in-app date=2026-10-03`

## Expected
The notice names the date the export finished — source: docs/superpowers/stories/2026-10-01-export-job-story.md AC-2

## Repro
1. Queue an export shortly before midnight.
2. Read the in-app notice after it finishes the next day.

## Brief
- Fix scope: the date the in-app notice shows.
- Out of scope: the e-mail notice.
- Feedback loop: failing test at the nearest seam — a notify/ unit test with a job queued before midnight and finished after.
- Read first: the export story, AGENTS.md § Architecture (notify/).

## Log
- 2026-10-04 · created · ready
