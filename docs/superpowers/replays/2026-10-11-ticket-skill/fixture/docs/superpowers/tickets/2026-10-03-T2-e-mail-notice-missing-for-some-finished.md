# T-2 — E-mail notice missing for some finished exports

**Category:** bug · **State:** needs-info · **Severity:** unknown — how many customers are affected is not known · **First seen:** unknown — no version reported
**Story:** `docs/superpowers/stories/2026-10-01-export-job-story.md`
**Feature:** export job, docs/superpowers/stories/2026-10-01-export-job-story.md AC-2

## Commitment
"When the export finishes, the customer is notified by e-mail and by an in-app notice." — docs/superpowers/stories/2026-10-01-export-job-story.md AC-2

## Observed
A customer says the in-app notice came but no e-mail — evidence: support ticket 4502 (no log line attached)

## Expected
Both notices for every finished export — source: docs/superpowers/stories/2026-10-01-export-job-story.md AC-2

## Repro
1. unknown — the reporter did not say which export

## Brief
- Fix scope: the e-mail notice for finished exports.
- Out of scope: the in-app notice.
- Feedback loop: replayed captured trace — no failing case is known yet, so no test can be written first.
- Read first: the export story, AGENTS.md § Architecture (notify/).

## Questions for the reporter
- Which export (job id or time) had no e-mail?
- Was the e-mail perhaps in the spam folder?

## Log
- 2026-10-03 · created · needs-info
