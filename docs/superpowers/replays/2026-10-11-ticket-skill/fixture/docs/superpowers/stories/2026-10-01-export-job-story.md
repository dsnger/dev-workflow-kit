# Export job — Story

**Date:** 2026-10-01 · **Size:** story
**Risk:** standard · **Security:** standard · **Validation:** battery+check

## 1. Problem statement
Customers ask support to pull their account data by hand, which takes days.

## 2. Desired outcome
A customer can request an export of their account data and receives a complete file without contacting support. Scheduled (recurring) exports are out of scope for this story.

## 3. Acceptance criteria
_IDs are permanent once the story is committed: never renumber or reuse one; a new criterion takes the next number unused here and on the branch it merges into, and a collision stops for a human; a removed one stays, struck through and dated; a narrowed one keeps its ID with a dated note; cite as `<story path> AC-<n>`; full rules: dev-workflow:intake, "Acceptance-criterion IDs"._
- [ ] **AC-1** A customer can request an export of their account data as an XLSX file from the account page.
- [ ] **AC-2** When the export finishes, the customer is notified by e-mail and by an in-app notice.
- [ ] **AC-3** The customer never receives a partial file; a failed export publishes nothing and shows the failure on the account page.
- [ ] **AC-4** Export files are stored only in the EU bucket.

## 4. Affected AGENTS.md invariants
- `## Key invariants` — "**A customer never receives a partial file.** A file is published to the customer only after the worker has written it completely; a failed job publishes nothing."
- `## Key invariants` — "**Personal data stays in the EU region.** Export files are stored only in the EU bucket."

## 5. Open questions
- None.

## 6. Suggested size
story — one coherent feature, one spec → plan → PR.
