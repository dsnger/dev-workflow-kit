# Gate B — quality branch — pass 10 dispositions

4 findings, all Major. All accepted.

1  MAJOR Task 5's profiled-only branch contradicts itself across Steps 5-7 — ACCEPT, same defect the spec branch reported as its finding 4. Steps 5, 6 and 7 are now consistently branched: paths for every cited story, `Evidence:` entries created/quoted/preserved only for profiled ones, and an optional `Verification:` record for this unprofiled story that is never presented or handled as mode-derived evidence.
2  MAJOR `plugins/dev-workflow/commands/process-pr-review.md` still skips Gate B on fix size alone — ACCEPT, and it is the most consequential finding of the pass: a SHIPPED command, outside every file this change edited, that would let a one-line fix on a security-relevant profiled story bypass the narrowed skip contract entirely. The sweep for pre-existing invalidated sentences is what surfaced it; no parity or grep of my own edits would have. Rewritten to resolve the cited story profile first, permit a skip only at effective level 0 for a profiled story, keep the judgement call for an unprofiled one, and record the battery, the skip reason and any evidence entry.
3  MAJOR the getting-started Opting-out item — ACCEPT, same as spec-1; one fix.
4  MAJOR docs/coding-workflow.md still describes the Gate-B skip as judgement-only — ACCEPT. Third pre-existing site. Now carries the profiled effective-level-0 condition, the unprofiled branch, and the fact that a skip removes review but never evidence.

Class note: three of this pass's eight findings are sentences that were TRUE before this change and false after it, in files the change never touched. That is a distinct defect class from "fix one site, miss its sibling" — no parity check, resync or self-grep can catch it, only a reviewer asked to look for it.
