# T-1 — Show a progress bar while an export runs

**Category:** improvement · **State:** wontfix · **Severity:** nit · **First seen:** unknown — a request, not a defect
**Story:** `docs/superpowers/stories/2026-10-01-export-job-story.md`
**Feature:** export job, docs/superpowers/stories/2026-10-01-export-job-story.md AC-2

## Commitment
"When the export finishes, the customer is notified by e-mail and by an in-app notice." — docs/superpowers/stories/2026-10-01-export-job-story.md AC-2

## Observed
The account page shows "Export queued" until the notice arrives — evidence: screenshot path support/2026-10-02-export-queued.png

## Expected
A progress bar while the export runs — source: docs/superpowers/stories/2026-10-01-export-job-story.md AC-2; requested by: a customer, support ticket 4471

## Repro
1. Request an export on the account page.
2. Watch the page until the e-mail arrives.

## Brief
- Fix scope: a progress indicator on the account page.
- Out of scope: notification changes.
- Feedback loop: failing test at the nearest seam — the account-page view test.
- Read first: the export story, AGENTS.md § Architecture.

## Log
- 2026-10-02 · created · ready
- 2026-10-02 · wontfix · the notices of AC-2 already tell the customer when the file is ready
