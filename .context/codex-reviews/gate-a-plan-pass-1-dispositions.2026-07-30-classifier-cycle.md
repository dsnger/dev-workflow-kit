# Gate A (plan) — pass 1 dispositions

Advisory companion to `gate-a-plan-pass-1.md` (7 BLOCKER, 29 MAJOR, 4 MINOR = 40). One line
per finding, in file order. **Six findings dissolved rather than being fixed**: the human
confirmed collapsing the spec's two-locator design to one, so the machinery that existed to
reconcile the two paths is deleted (spec §3.1 amended inline, 2026-08-01).

1. BLOCKER `jq -r … | head -n1` — DISSOLVED. The `jq` locator is deleted.
2. MAJOR span check unimplemented — DISSOLVED. `jq` reports no byte offsets, which is what made the check unbuildable and the second path pointless.
3. MAJOR duplicate-key divergence — DISSOLVED. One locator; a repeated depth-1 key exits 2 → `unrecognized`, tested.
4. MAJOR `jq` status masked / newline stripping — DISSOLVED with the path. The awk locator's status is read directly; command substitution's newline stripping is harmless because a JSON string cannot hold a raw newline (stated in Task 5 Step 3).
5. BLOCKER `locate_scan` mis-parses the real fixture — FIXED. Replaced by `locate.awk`, green 35/35 against the real captures under `sh` and `dash`; `locate_result` is now defined, not prose.
6. MAJOR malformed-JSON contract — PARTLY ACCEPTED. The scan validates exactly what it must walk to reach the block; trailing garbage and post-value balance are **not** checked, and A2 says so rather than claiming full validation. Routable-but-malformed → `unrecognized` (terminal default), which spec §3.3's unroutable-payload rule never covered.
7. MAJOR `RS="\0"` portability — FIXED. Records are accumulated and processed in `END`, with the separator restored; verified under two shells.
8. BLOCKER `case` glob admits a reordered envelope — FIXED. Brace stripped, whitespace consumed by a bounded loop, then a fixed prefix; `{"status":…,"success":false}` → `unrecognized`, tested both collision directions.
9. MAJOR `[[:space:]]*` is not zero-or-more — FIXED. Three explicit grammar points plus a token-end check (`truely` → `unrecognized`); compact, tab, CRLF and space-before-colon all tested.
10. BLOCKER anchor expects a literal quote — FIXED. Anchor is `MCP tool \"` in escaped form; the real `shape3` capture classifies `backgrounded`.
11. MAJOR A4 constraints unvalidated — PARTLY DISMISSED. Duration format, unit and task-id are **deliberately** outside the anchor (spec §4): narrowing to shapes observed once would widen C1, not close it. Implemented and tested: start anchor, segment before any `\n`, and all four named near-misses.
12. MAJOR unicode test supplies an ASCII space — FIXED. Literal ` ` in the table; the canonical-form ordering rule it tested is deleted with the second path (spec §3.3 amended).
13. MAJOR §7.3 matrix gaps — FIXED. The 35-row table from `verify.sh` is ported across Tasks 5–7, including every `no-result` shape, both collisions and the polarity encodings.
14. MAJOR the driver itself needs `jq` — FIXED. `payload`/`resp` are `printf`-only and `payload_from` retargets a fixture with `sed`; no classification test depends on `jq` existing.
15. MAJOR undefined helpers and state variables — FIXED. Task 2 defines all of them before first use. `HOOK_LOCATE`/`HOOK_CLASSIFY` are **deleted**: the five classes are externally distinguishable, so no debug entry point is added to the product.
16. MAJOR writer-failure test asserts nothing — FIXED. `run_closed` runs the hook with stdout closed and captures its status separately; the marker consequences are asserted where markers exist (Tasks 7–8).
17. MAJOR `note_discarded` used before defined — FIXED. Old Tasks 6 and 7 merged, so every committed state is functional.
18. MAJOR preservation coverage incomplete — FIXED. `seeded_preserves` runs five discarded shapes (incl. two `no-result` variants) × both gates × default and mapped names, byte-comparing all four state files.
19. MINOR review fixture unused — FIXED. Task 7 Step 2 asserts the success class and Gate-B state through `shape0-success-review.json`.
20. BLOCKER `note_unverified` never invoked — FIXED. Called from both gate branches; delivery, marker writes and pending live in `flush_notes`, which is the only place that knows whether anything was written.
21. MAJOR shown+pending unreachable behind the early return — FIXED. Coexistence is resolved at the **top** of `flush_notes`, before any decision; the row is tested.
22. MAJOR A5 incomplete, no reset cleanup — FIXED. Thirteen rows including the `bgAdvice` lifecycle and every write/delete failure; `reset_all` extended to all three markers (Task 2 Step 3).
23. MAJOR `out=$(rev)` cannot observe output — FIXED. `rev` (silent) and `revout` (capturing) split, named for what they do.
24. BLOCKER composition is one sentence — FIXED. `note`/`flush_notes` are real code across Tasks 4 and 8: buffer, single flush, status propagation, marker transitions, `Earlier:` prefix, and the removal of the early `exit 0` that would have skipped the flush.
25. MAJOR composition assertions pass on zero output — FIXED. `= 1`, never `-le 1`; the silent case asserts `0`; plus disclosure-first ordering, separator, pending cleared, and `jq -e` parse, across 13 scenarios.
26. MAJOR clause greps instead of goldens — FIXED. `field_of` plus per-branch exact-equality assertions on both output fields (Task 7 Step 3, Task 9 Step 5).
27. MAJOR B3 omits `codex-gate.sh` — FIXED. Added to Task 9's file list and its `git add`.
28. MAJOR spec §9 setup documentation missing — FIXED. Task 9 Step 6, a step of its own, with every settled clause enumerated.
29. MAJOR carried-scope contradiction — FIXED. The "none before Task 9" rule is narrowed rather than the edit moved: B2's hook-side occurrence is a comment on the function Task 3 rewrites, and the checklist says so.
30. MAJOR census greps match nothing — FIXED. Claim-oriented patterns, run 2026-08-01; the real hits are recorded as file:line in the B items.
31. BLOCKER version bump after the first plugin commit — FIXED. The bump is Task 1, before any other plugin file is committed, with the reason stated in the ordering rationale.
32. MAJOR `git stash` counterfactual is empty — FIXED. The pre-change hook is materialized with `git show` into a temp dir beside the new suite; the working tree is not touched.
33. MAJOR `jq` reserialization defeats byte-exactness — FIXED. Fixtures are hand-sanitized; verification compares the **located block** byte-for-byte and a human reads the `diff`. The bound of that claim is stated rather than overclaimed.
34. MAJOR fixtures leak machine and prompt data — FIXED. `tool_input.workingDirectory` and `.instruction` added to the sanitize table; every fixture is read end to end, not only the review one.
35. MAJOR named verification not reproducible — FIXED. Replaced with a procedure that never touches the installed plugin cache: captured payloads through the repo hook in a disposable repo, with exact expected readings. The one reading it cannot produce is named and sourced to the existing `foreground-env-*` captures.
36. MINOR argv-sized grep pattern — DISSOLVED with the `jq` path. Separately, `strip_ws` is bounded at 64 units and the blank test is one `sed` pass, so no shell loop scales with external input.
37. MINOR B and C items name no task — FIXED. All now do, including C4.
38. MINOR version target undecided — FIXED. `0.8.0`, minor, with the reason named where the checker cannot judge it.
39. MAJOR marker concurrency residual unrecorded — FIXED. Added as **C4** with both observable directions; the A5 table states it describes sequential behaviour only.
40. MAJOR locator tests grep fragments — FIXED. Every locator row asserts the resulting class through `class_of`, with an exact expectation; no fragment greps remain in that section.

---

**Housekeeping.** The prior (profiles) cycle's dispositions for slots 1 and 2 were archived to
`*-dispositions.2026-07-26-profiles-cycle.md` rather than overwritten — the slot names carry
no cycle component, which is the defect already filed in `todos.md`. Their findings files were
overwritten by this cycle before that was noticed.
