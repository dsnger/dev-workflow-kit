# Gate A (plan) — pass 7 dispositions

Advisory companion to `gate-a-plan-pass-7.md` (4 BLOCKER, 18 MAJOR, 4 MINOR = 26). **All
accepted, none dismissed.** First pass on the narrowed plan (531 lines, was 1732).

Trend: 40 → 32 → 35 → 29 → 19 → 37 → **26**; B+M 36 → 28 → 27 → 24 → 17 → 35 → **22**.

**The narrowing worked as intended, and rider 1 earned its keep.** Six findings (3, 4, 6, 7,
10) are *dropped-coverage* findings — assertions earlier passes established that no oracle
still required. That is exactly what "every test keeps its label and its oracle" was for,
and it caught what the rewrite lost. No finding said "the harness shell is missing", which
was the scope risk.

**Four verified in-session before acting:**

- **`locate.awk` contained two ASCII apostrophes** (`caller's`, `machine's`) — in comments I
  added at pass 5 when narrowing the ceiling claim. The plan says to embed it in a
  **single-quoted** shell variable; either one would terminate the quote and leave the hook
  unparseable. Removed; the file is now apostrophe-free and the constraint is recorded in
  the drafts README as a trap.
- **`git commit -m … -F …` is rejected outright** — *"options '-m' and '-F' cannot be used
  together"*. The squash command could not have created the reviewed snapshot at all.
- **`printf x | sed s/x/y/` emits `y` with no newline**, so my own health probe fails its own
  "must print a line" requirement — it would report a healthy POSIX `sed` as broken.
- **The battery is four script runs, not three.** Miscounting is how
  `check-invariants.test.sh` or `check-version-bump.test.sh` gets dropped while the task
  still claims the full battery. The block is now written out verbatim.

## Dispositions

1. BLOCKER apostrophe in the embedded locator — ACCEPT, verified. Removed, plus a mechanical check after embedding (`sh -n`, `shellcheck`, one classification test) and the constraint recorded where a reconstruction would read it.
2. MAJOR `locate_result`'s contract vanished in the narrowing — ACCEPT. Restated: feed `$payload` unchanged to `LOCATE_AWK`, return `awk`'s status untouched, never consult `jq`, never collapse "anything else" — collapsing it is how a missing `awk` (127) becomes `no-result` instead of fail-open.
3. MAJOR the preceding-non-text duplicate was claimed verified and had no row — ACCEPT; my pass-6 disposition overstated again. Row added to `verify.sh` (green), plus its own oracle.
4. MAJOR block selection had no oracle — ACCEPT. An `element [0]` implementation passed every listed group while violating spec §3.1's settled rule. Oracle added.
5. MAJOR the three frozen walkable-invalid rows cannot route with `jq` — ACCEPT, and the contradiction was real: the plan required them ported *and* excluded jq-routing-dependent documents. They are now **locator-level contract tests, exempt by label**, which is the level their claim is about.
6. MAJOR the permanent slice test lost its home — ACCEPT. Task 1 deferred it to Task 5 and Task 5 had no such oracle. Added, one per fixture, requiring both locator statuses before comparing.
7. MAJOR the ported set is named by group, not by label — ACCEPT. The plan now requires enumerating every `verify.sh` label as ported or excluded-with-reason; a group heading cannot show that a case quietly stopped being required.
8. MAJOR thirteen scenarios named, fourteen sources listed — ACCEPT. Nine existing branches plus five new emissions. Counted explicitly, because an omitted branch is the dropped-output failure the oracle exists to catch.
9. MAJOR the Unicode row's wording recreates pass-5's wrong test — ACCEPT. It now says six-byte `"`, no raw quotes, and asserts the locator succeeded before the matcher's verdict.
10. MINOR the depth cap had no verifier row — ACCEPT. Added at 201 openers, plus an ordinary-nesting row so the cap cannot be tightened into refusing real payloads.
11. MAJOR retries omit CLAUDE.md §5's target-file cleanup — ACCEPT, and this is the sharpest finding of the pass: all four retry-capable messages allowed a re-run without deleting the target findings file and confirming it gone, which is how a died-part-way call's valid-looking artifact survives into the next pass. Added to each `<next>`, after the stop-or-await for the backgrounded pair — deleting a slot the original call can still write is the race those messages exist to prevent.
12. MINOR the `sed` probe prints no line — ACCEPT, verified. Both probes now use `printf 'x\n'` with the exact expected output and status.
13. MAJOR oversize and ambiguous are not distinguishable — ACCEPT. The message now says so, gives the one check that *is* available (measure against the ceiling), and treats the rest as unresolved rather than claiming a discriminator it lacks.
14. MAJOR the message told the operator to report a raw payload — ACCEPT, and Task 1 establishes exactly why: those payloads carry prompts, absolute paths, review content, session identifiers and unrelated concurrent call data. Now: keep it local and access-restricted, sanitize before showing anyone, never attach it unsanitized.
15. BLOCKER `-m` with `-F` — ACCEPT, verified. Two `-m` arguments: the first carries the `WIP:` subject `is_wip_commit` matches, the second the evidence body.
16. BLOCKER the CHANGELOG never reaches the snapshot — ACCEPT. `reset --soft` preserves the unstaged edit and the commit omits it, so invariant 12's release note would sit outside the reviewed range and the commit-based path audit could not see it. Staged explicitly before the reset, with a post-commit `show --stat` read.
17. MAJOR Step 6 ran the post-squash battery before Step 7 created the squash — ACCEPT. Resequenced: squash (6), battery (7), Gate B (8).
18. MAJOR no amend form carries subject and evidence together — ACCEPT. `-m` alone erases the body; `--no-edit` is not recognized as WIP and resets the counters. Only the two-`-m` form satisfies both, and it is now written out for the fix loop and the close.
19. BLOCKER the rollback drill leaves 0.7.1 active — ACCEPT, and the consequence is severe: every Gate-B pass would then run under the hook that counts failed calls, so the review's pass accounting is the accounting this change exists to fix. Either an isolated profile, or reactivate 0.8.0 and **byte-verify** before the first pass.
20. MAJOR the rollback hides what it costs — ACCEPT. Reverting restores the original false ✓ **and** the `dash` invariant-1 exit. Both recorded, with the narrow condition under which rollback is the right call.
21. MAJOR `$BASE` used before it is recorded, and not durable — ACCEPT. Moved to a new **Task 0**, recorded as a literal SHA in a durable note rather than a shell variable that lived in one terminal, and ancestor-validated before each use.
22. MAJOR the battery block is referenced and never written — ACCEPT, and it undercounted. Written out verbatim, with the count corrected and a note that the `AGENTS.md` row remains the source of truth.
23. MAJOR the four counterfactual labels are never named — ACCEPT. Named, with only the mechanical runner suffix left to execution, and with why those four: each fails for the change's own reason rather than a harness difference.
24. MAJOR the working tree is not clean at execution start — ACCEPT, and it is true right now: the spec amendment and this plan are unstaged. **Task 0** commits the approved Gate-A artifacts separately (prose, so Gate B is N/A) and stops on anything unaccounted, before `$BASE` is fixed.
25. MINOR the drafts README still says the bodies live in the plan — ACCEPT; it predated the narrowing by one pass. Rewritten: these files are now the **only** copy, with the reconstruction fallback stated.
26. MINOR the README's A2 contract is weaker than the code — ACCEPT. Duplicate refusal in **any** examined element and the depth cap both added, so a reconstruction guided by it cannot drop two settled conditions.
