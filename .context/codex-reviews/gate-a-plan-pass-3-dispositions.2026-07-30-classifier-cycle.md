# Gate A (plan) — pass 3 dispositions

Advisory companion to `gate-a-plan-pass-3.md` (5 BLOCKER, 22 MAJOR, 8 MINOR = 35). One line
per finding, in file order.

**The cycle stopped and surfaced after this pass** (B+M 36 → 28 → 27, not converging), and
the human decided the one blocking question: **narrow the locator's claim rather than grow
the parser**, with three riders — state that walk integrity rests on string-boundary
tracking alone; freeze the three counterexamples as fixtures asserting today's behaviour;
and treat a fourth claim-vs-code finding on this same spot as the stuck signal. Findings 2,
3, 4 and 5 are dispositioned under that decision. Everything else is ordinary work, all
accepted.

1. BLOCKER locator rows cannot route through the hook — ACCEPT, and it was worse than stated: bare `{"tool_response":…}` fragments carry no `hook_event_name` at all. Task 5 Step 2 now requires every ported row to be a routable payload, and names the **two groups that stay in the drafts** — deliberately unroutable documents, and documents whose routability depends on `jq` — with the reason, so they are excluded rather than silently dropped.
2. MAJOR `skipval` is not a recursive parser; `readstr` accepts invalid escapes — ACCEPT as fact, **claim narrowed rather than code grown** (human decision). Verified in-session: `[1,]`, `{"a" 1}` and `"\q"` in a sibling value each return the block with status 0. A2 now says what actually carries safety — string-boundary tracking, which cannot be redirected by malformation *outside* a string — and the three examples are frozen as fixtures asserting exactly that behaviour, so the claim-code correspondence is pinned mechanically instead of argued a fourth time.
3. MAJOR escaped key spellings bypass duplicate detection — ACCEPT as fact, scope stated. A2 records it as the one case where the scan differs from a real parser's duplicate handling, and why it is out of scope: the payload's producer is Claude Code, whose serializer emits valid JSON, so a document carrying both spellings is synthetic. The pass-2 "never a wrong verdict" rationale is **withdrawn** as stated and replaced with the producer argument, which is the true one.
4. MINOR `text` is not recognized as `type: text` — ACCEPT, contract stated explicitly: `type` is compared as raw bytes, so an exotic-but-conforming tool takes the fail-closed `no-result` path. Decoding `\uXXXX` would put a unicode decoder in a hook whose safety argument is that it decodes nothing.
5. MAJOR the ceiling does not bound memory — ACCEPT, my overclaim. `payload=$(cat)` has already stored the whole input before `awk` starts. The plan and the `awk` comment now both say the ceiling caps the **scan** and nothing else, and name what bounding the input would require.
6. MAJOR the encoder-failure test is vacuous without `sed` — ACCEPT, good catch: `field()` needs `sed` to route at all, so the hook never reached `emit`. Replaced with a shim that fails only the escaper's own script and passes everything else through, plus a `skip -` guard.
7. BLOCKER `run_scenario` / `expected_ctx` / `expected_msg` are prose — ACCEPT. All three are now complete POSIX shell in Task 2 Steps 6–7, including per-scenario setup, cleanup for the two scenarios that dirty the worktree, and the A7 composition rule applied once rather than restated per assertion.
8. MAJOR both provenance checks fail open — ACCEPT. Both now `exit 1`. Step 7's claim is also narrowed to what it compares: the **located block**, not the whole array.
9. MAJOR `seeded_preserves` never runs jq-free — ACCEPT. Parameterized over `run` and `nojq_run`, both gates, default and mapped names, all five discarded shapes.
10. MAJOR the missing-`awk` test asserts only disclosure — ACCEPT. It now asserts the **count and a usable fingerprint** for Gate B and `passCountA` for Gate A, across three fault shapes: absent, nonzero exit, and partial output then failure.
11. MAJOR A5 rows still unpinned — ACCEPT. Added: pending retention under suppression and under a failed flush, shown-write failure while flushing an existing pending, failed pending delete plus its cleanup on the next event, and `bgAdvice` write failure after a successful emit.
12. MAJOR the C2 test does not produce the residual — ACCEPT, and `chmod 500 .context` observed neither half. Replaced with surgical injection: pass-state writable, emit suppressed, only the pending path unwritable — then assert counted, no shown marker, no pending marker.
13. MINOR C2 is overstated in the A5 table — ACCEPT. Split into its own row, with the other marker failures listed and their different outcomes named.
14. MINOR "writes nothing at all" contradicts `bgAdvice` — ACCEPT. Relabelled to **gate-pass** state, with the diagnostic-marker effects asserted separately as their own family.
15. MAJOR the composed document is never tested jq-free — ACCEPT, and the plan explicitly claimed that path is stressed hardest by exactly this. One real two-message branch now runs through `nojq_run` with whole-field goldens and an independent `jq -e` parse afterwards.
16. MAJOR the field split is inverted — ACCEPT, the most consequential prompt finding: operator checks and remedies sat in the model's field while the operator got "see the note". Every operator-performable action moved to `systemMessage`; `additionalContext` keeps the gate consequence and what Claude does next.
17. MAJOR items 1, 3, 5 unmet — ACCEPT. Target model named once for all ten strings (item 1), a uniform *state → consequence → next → stop* structure (item 5), and a bounded stop tied to §5's one-attempt recovery budget on every retry-capable state (item 3).
18. MAJOR `FAILURE_CTX` names no causes — ACCEPT. It now names the error codes, what each means, the matching remedy, and where the retry budget ends.
19. MAJOR `.mcp.json` is not authoritative for the effective server — ACCEPT. The message now says to check with `claude mcp list` and why (scope precedence), and gives the two causes separate, complete remedies.
20. MAJOR `UNVERIFIED_CTX` omits known causes — ACCEPT. Oversize refusal, missing/failing `awk` and locator refusal added; the backgrounding remedy is **inlined** rather than pointing at a message a reworded notice never produces.
21. MAJOR the short form drops the variable name — ACCEPT. Settled decision 4 requires it precisely because `bgAdvice` outlives the session that saw the long form.
22. MAJOR the backgrounded call can still write its findings slot — ACCEPT, and this is the finding I would have missed: the hook's new diagnosis would otherwise *create* a race against §5's own file protocol, where a late writer leaves a correctly terminated file from the wrong run. Both backgrounding messages now tell Claude to stop or await the task id before re-running.
23. MINOR "has counted" precedes the best-effort write — ACCEPT. Reworded to "classified as countable and attempted to record it", which is prompt-standards item 11 applied to our own message.
24. MAJOR Task 6's prompts are not literal — ACCEPT. The B1 sentences, the two narrower phrasings, and the unknown-tool message's inserted paragraph are all written out.
25. MAJOR the census misses three sites — ACCEPT, verified: `workflow-init.md:250`, `README.md:59`, `AGENTS.md:70`. The grep now carries three alternations and the plan lists all five hits with a disposition each, including one marked *read and decide* rather than pre-judged.
26. MINOR the AGENTS.md declaration census is skipped — ACCEPT. Both greps plus a same-change read of `plugin.json` are now in Task 6 Step 5.
27. BLOCKER the counterfactual deletes its own evidence — ACCEPT. `$EVID` lives outside the temp directory, a trap does the cleanup, and the assertions run before it.
28. MAJOR the base-blob guard continues on failure — ACCEPT. Every guard exits nonzero; an empty blob is checked too.
29. BLOCKER Task 7's own edit is outside the reviewed range — ACCEPT. The CHANGELOG edit is staged in a named `WIP:` snapshot before Gate B, so the review covers it and the counters are not reset.
30. BLOCKER merge-base resolves to HEAD on this checkout — ACCEPT, verified: the work is on `main`, so `git merge-base main HEAD` is HEAD and Gate B would have received an **empty range**. `baseSha` is now the recorded pre-Task-1 SHA, passed literally, with the branch case as a check rather than a substitute.
31. MINOR the per-commit battery claim is false — ACCEPT. The block is written out once and later tasks require *that exact block, run and green*; the claim that it is copied everywhere is removed.
32. MAJOR the capture mutates the globally installed hook — ACCEPT. Backup, hash before, trap on EXIT/INT/TERM/HUP, restore, hash after and a hard stop on mismatch; plus deleting payloads dumped for unrelated calls, and a preference for an isolated install where one exists.
33. MINOR no rollback — ACCEPT. Task 7 Step 5, with the point that `codex-gate.off` is **not** a rollback (it suppresses messages while classification keeps discarding), the version-keyed cache path is, and the diagnostic markers survive it.
34. MAJOR the load-bearing code lives in ignored scratch — ACCEPT. Both bodies are embedded in Task 5 Steps 5–6. `.context/plan-drafts/` remains where the test corpus lives and where a change is re-verified; Step 2 says the two copies are kept in step by hand.
35. MINOR "six pairs" — ACCEPT, there are five (ten strings). Corrected, with the derived composed and `Earlier:`-prefixed forms named as derived rather than missing.
