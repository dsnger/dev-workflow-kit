# Spec review coverage — pass 3

Range: f3269ce4ee6f9155282f4f856f7c4cd212987074..030e8438a00294f8d2cc15820ccffe00070f12c9.

Hypotheses: release classification admits unrelated changes; inherited green bypasses a required run; new exceptions contradict existing consumers. Inspected the implementation and tests independently. Shell and Markdown sources were read directly (the AGENTS.md graph-discovery fallback covers those file types).

| AC | Test or evidence | Assessment |
|---|---|---|
| AC-1 | Hook rel_case release fixture at 691; local-ci case 25 at 428; gate rules line 6 | Implemented, with malformed-token finding |
| AC-2 | Both suites: dependency, code, different release pairs, nested version, instruction sites; local-ci lines 427–460 | Implemented, with malformed-token finding; no existing newline-token regression |
| AC-3 | Existing hook docs-only cases at 594–649; new docs/mixed cases at 701–703; original docs-only branch unchanged | Matches |
| AC-4 | local-ci cases 23–35, especially no light row at 463–464 and red light row at 465–468 | Matches except classifier finding; assertions distinguish run markers |
| AC-5 | local-ci cases 36–40 at 470–499: same tree, records, moving source ref, gitlink, changed base, invalid source | Matches; source SHA resolved once; inherited branches precede worktree creation |
| AC-6 | Status post helper uses context quality; test post arguments and inherited assertions; .github diff empty | Matches |
| AC-7 | docs/reference.md:317; README new workflow table entry | Manual text inspection; no dedicated test |
| AC-8 | Both classifier suites plus local-ci base-only update case 39 at 479–482 | Requested cases present; assertions can detect wrong lanes |
| AC-9 | none yet in this review; plan T5 explicitly schedules measurements/PR body after final-head green | Deferred by approved sequence, not a finding |
| AC-10 | Manifest, version record, template 2.23 all 0.50.0; CHANGELOG, README, reference updates | Invariant checks pass; release publication remains later workflow work |

Verification performed here: sh scripts/check-invariants.sh exited 0 (including size/copy/version checks 4i/4j/4m/4n). Scratch Git fixture invoked the actual release_only function extracted unchanged from each implementation with a staged manifest whose version changed from a JSON-escaped multiline 1.0.0 value to a multiline 1.0.1 value; both returned 0 (release-only). No source edits. The full battery was not repeated; supplied battery evidence is treated as supplied evidence, not a run performed by this reviewer.

Previous findings: pass-1 finding 1 fixed in process-pr-review.md:47, 233–246, 270–275, 339 and docs/reference.md:360, 816 (lane consumers preserve final-head and failure conditions). Finding 2 fixed at local-ci.test.sh:463–464 (only docs change from a fixture with no light row). Finding 3 fixed at local-ci.test.sh:439–441, 472–475 and hook suite different-pair/instruction-site cases (moving ref and classifier parity). Pass 2 had no findings. The pass-3 blank-site fix drops the entire whitespace-bearing entry and has rejecting fixtures in both suites.

No additional scope expansion identified. Gate-rule trims preserve the prior conditions; the removed repeated Tool line remains specified at the file start. Prompt changes retain explicit output, stopping, source and final-head requirements. Boundary 4b is preserved: reads/status post plus owned worktree cleanup, no fetch/push/prune or remote mutation beyond the authorized status.
