# T-5 — Account page help text says CSV

**Category:** docs · **State:** ready · **Severity:** minor · **First seen:** 1.2.0
**Story:** `docs/superpowers/stories/2026-10-01-export-job-story.md`
**Feature:** export job, docs/superpowers/stories/2026-10-01-export-job-story.md AC-1

## Commitment
"A customer can request an export of their account data as an XLSX file from the account page." — docs/superpowers/stories/2026-10-01-export-job-story.md AC-1

## Observed
The help text under the export button reads "You will receive a CSV file" — evidence: screenshot path support/2026-10-01-help-text.png

## Expected
The help text names XLSX — source: docs/superpowers/stories/2026-10-01-export-job-story.md AC-1

## Repro
1. Open the account page and read the text under the export button.

## Brief
- Fix scope: the help text string.
- Out of scope: the export format.
- Feedback loop: failing test at the nearest seam — the account-page view test asserting the help text.
- Read first: the export story.

## Log
- 2026-10-01 · created · ready
