# Pass 49 dispositions — cycle `om0bdd7udh`

> **APPLIED 2026-09-17 — the seventeenth bounded revision. All six are repaired in the worktree;
> nothing is committed.** Finding 3 was settled **through a Codex gate**, not by handing Daniel a
> menu: the gate returned **NOT OWED — record as a disclosed residual**, its citation of condition
> 5's wording was verified against the file, and it was implemented that way. Verification: **16
> fixtures × `sh`/`dash`/`bash`, all green**, with the blocks extracted verbatim from the plan and a
> control per finding reproducing the old defect. `sh -n`/`dash -n` failures are **6 and 7,
> identical to the pre-repair baseline** — no new syntax failure. Fenced blocks 55 → 54, the one
> removal being the cleanup block merged into condition 6.
>
> **Three fixtures failed on the first run and all three were harness bugs, recorded rather than
> quietly fixed:** the disposable repo had no `.gitignore`, so `.context/` counted as a dirty tree
> (two failures); and a control asserted a pass-count that was simply miscalculated. The plan was
> not touched for any of them.
>
> **RETRACTED — the error was mine, and it is finding 6's own defect class.** An earlier version of
> this block said a subagent had supplied the quotation *"The gap is real and this change does not
> close it"* and that the string occurred in no file here. **The string is real**, at
> `docs/superpowers/specs/2026-09-10-loop-rule-consolidation-target-text.md:1234`, inside the bullet
> beginning at 1231. My `grep -F` for it returned nothing **because the sentence wraps between `this`
> and `change`** — a literal search for a string that spans a line break, which is precisely the
> defect finding 6 repairs and which this cycle has now hit three times (carried `e9` at pass 10,
> Task 7's fragment at pass 49, and this). The subagent was right; the accusation was wrong and is
> withdrawn. **The lesson is the one finding 6 installs**: a literal count over multi-line prose
> proves nothing until the wrap is ruled out.

Advisory companion per CLAUDE.md §5 "Optional companions". One line per finding: verdict + reason.
Not the findings file; participates in no pass validation. Verdicts recorded 2026-09-17 after
validation against the plan text (five read-only subagents) and, where marked, by execution.

1. BLOCKER — Preparation / Task 0 step 1 base binding | ACCEPTED, into the fix set | Confirmed: six live `HEAD` resolutions establish the predicates, a seventh writes `.context/loop-rule-base`. Not in either of `1ba45be`'s lists — missed, not excluded. No guard, no disclosure.
2. BLOCKER — step 6 / step 7 call issuance `headSha` | ACCEPTED, into the fix set | Confirmed: the reviewed head is recorded to a file, then the call's `headSha` is specified in prose as a fresh resolution never tied to it. CLAUDE.md's own rule is satisfied; the plan's self-review item 28 is what demands more. Not shell, so the sweep could not have reached it.
3. BLOCKER — 8b `reset --soft`, no atomic expected-old-object guard | DISPUTED, NOT accepted into the fix set; Daniel's decision required | Condition 5 says "when the closing invocation begins" and the plan does exactly that, so no stated requirement is violated; the wide window is already closed; the residual needs a concurrent writer that nothing establishes exists; and the proposed guard replaces `reset --soft` with a different close mechanism, which is a new precondition rather than a repair. Full disposition in the repair draft.
4. BLOCKER — Close condition 6 and cleanup | ACCEPTED, into the fix set | Confirmed: subject, parent, tree and body read through four independent live `HEAD` resolutions with no captured id; the parent test admits any commit parented at `$BASE`; cleanup then erases the recovery state behind a prose-only gate. Excluded by `1ba45be` on a rationale that holds for conditions 1 and 5 and not for 6.
5. BLOCKER — records-commit marker recovery | ACCEPTED, into the fix set | Confirmed in both halves: the five added checks are satisfied trivially by any earlier already-routed records commit, and the generic "rebuild from the `$BASE` blobs" rule is a category error for an artifact that is not a function of `$BASE`'s content. Blunted only for the one case the plan names, which does carry a real precondition stop.
6. MAJOR — Task 7's worked carried fragment | ACCEPTED, separate small fix | Confirmed BY EXECUTION: the fragment spans the line break between `Codex is` and `advisory` in both copies, so `grep -cF` returns 0 where the plan expects `parent=1 worktree=1`. Dropping the leading `Codex is ` gives 1/1 in both copies, verified. The plan's second example, `Open a TodoWrite`, is 1/1 and is fine.

## Corrections to the pass-49 status report, all three validated before acceptance

- ACCEPTED — "all six are paid for by the executor alone" was wrong. The standard is the causal chain, not the first affected party. `plugins/dev-workflow/commands/workflow-init.md`, `codex-gate.sh` and `codex-gate.test.sh` all ship inside the plugin package, so findings 1, 2 and 4 — and 3 if it ever fires, and 6 by way of an executor "repairing" correct text — can put content into shipped files that no review covered.
- ACCEPTED — "no regeneration from the repairs" was too sweeping. `1ba45be` carries SEVEN hunks across FOUR regions, not three; the first (`@@ -628`) is Resume's marker validation, which is exactly what finding 5 attacks. Finding 5 IS regeneration. The "clearly stuck" exit remains unavailable: the plateau conjunct fails (Blockers rising 3 → 5) and no affirmative coverage judgement is possible.
- PARTLY REJECTED — the claim that the utility check was absent from the instruction file is false: it is present at line 572, "a finding is acted on when it names a bugfix, a security fix or a performance gain, and names who pays". The other half is right and is my defect: the four priority areas appear nowhere in that file, and the wrapper instruction asserted "the prompt names four priority areas" when it named none. The conclusion stands on that half alone — pass 49 is not a usable test of the sharpened approach.
