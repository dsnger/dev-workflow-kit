# Gate A — spec — pass 6 dispositions

Artifact: `docs/superpowers/specs/2026-08-05-hardening-ledger-supersession-design.md`
16 findings: 11 Major, 4 Minor, 1 Nit. All sixteen read as correct. **None applied** — the pass
is not clean, and the pinned exit sends anything new to Daniel.

Reviewer: `mcp-codex-dev@1.0.1`, `codex-cli 0.144.5`, model `gpt-5.6-sol`. Same as passes 4–5.
(Recorded here, not in the findings file: CLAUDE.md §5 admits no non-finding line there.)

## Trajectory — worth reading before the table

Passes 4, 5, 6 returned **11, 14, 16** findings. Every pass has been valid; every pass has been
applied in full; every pass has found more than the last. That is not the shape of a converging
review, and it is the fact Daniel needs most from this pass.

The three failure modes are stable across all three passes:
1. **A fix executes in wording, not mechanism** (pass 3's entry locator → pass 4's §7 rewrite →
   pass 5's shell → pass 6's finding 2, where assertion 1 became runnable and assertion 2 did
   not).
2. **A fix overclaims what it validates** (findings 3, 12 here; 4, 6, 10 in pass 5).
3. **A fix falsifies a statement elsewhere that nobody re-reads** (findings 4, 5, 10 here).

Four of pass 6's Majors (**7, 8, 9**, and part of **6**) land on the old-conditions accounting
table **written in pass 6 to satisfy the `AGENTS.md` Don't about old-conditions accounting**.
That is the sharpest signal in the cycle: the mechanism this project uses to prevent silent
condition-dropping was itself applied wrongly, in the very edit that introduced it.

## Verified mechanically, not taken on the reviewer's word

| # | Claim | Result |
|---|---|---|
| 1 | §2.0's quote elides source bytes behind `…` | **Confirmed.** `docs/hardening-log.md:7` reads `by appending a new row (same fingerprint,`. The `…` hides real text, not a wrap. |
| 2 | check 2's assertion 2 has no runnable command | **Confirmed.** Assertion 1 is executable shell; assertion 2 is prose from "Locate §4's two sentinels" onward. |
| 4 | §8's stored riders are stale | **Confirmed.** Rider 3 (line 544) still audits `§5` only, while pass 6 was run with a rider requiring both §5 and §2.1. Rider 1 still carries the anchor-coverage premise §7 now disclaims. |
| 5 | stale claims survive outside the change surface | **Confirmed.** `docs/superpowers/plans/2026-08-04-hardening-round-0-8-0-and-pr-21.md` lines 64, 474, 483 carry "Never edit an existing row", "Never edit a row \| **kept** — any solution must preserve it", and the pre-amendment desired outcome. |

| # | Sev | Verdict | Reason |
|---|---|---|---|
| 1 | Nit | **Valid, confirmed** | Third consecutive pass finding a defect in this one quoted phrase. |
| 2 | Major | **Valid, confirmed** | The both-surfaces decision — the thing the whole two-surface scope rests on — has no reproducible check. Failure mode 1, again. |
| 3 | Major | **Valid** | The four-state claim still says a clause dropped from both surfaces makes an anchor report `0`. Deleting "once it merges it is landed, and stays landed", the date+fingerprint locator rule, the uniqueness stops, or the removed-hardening exclusion leaves all fourteen anchors intact — and §9's omission list names none of them. The narrowing was applied to one sentence and not to the two that depend on it. |
| 4 | Major | **Valid, confirmed** | §8 is titled "verbatim in every pass prompt" and is now behind the riders actually used. A later pass reading it would be steered back to a rejected coverage claim. |
| 5 | Minor | **Valid, confirmed** | Story §1 was pass 5 finding 7, applied only to §2; the plan file is a fourth site nobody swept. |
| 6 | Major | **Valid** | All six verdicts correct. But cases 3, a closed-cycle form of 4, and an own-row form of 6 all flip relative to the cycle rule, and §2.1's accounting names only the earlier-finished-branch flip. |
| 7 | Major | **Valid, and the most serious** | The table states the old condition as "a row you have not yet published", which the cycle rule never carried — it tested same-open-cycle ownership — then marks the materially broader not-yet-reachable rule **kept**. An old condition restated in the new rule's vocabulary cannot detect what the new rule widened. |
| 8 | Major | **Valid** | The table credits the old procedure with a cycle opening and a definite permanent exit. Pass 4 established it had no opening (pass 4 *added* one); pass 5 established the close was undefined for trivial, abandoned and interleaved work. The accounting invents guarantees, then calls the replacement a strengthening against them. |
| 9 | Major | **Valid** | §9 says the cycle rule carried the same single-writer assumption. It did not: the "landed to you" clause is exactly what stopped a second worktree amending the author's row. Reachability authorizes any holder to amend any unmerged row — a broader lost-update path, described as pre-existing. |
| 10 | Major | **Valid, confirmed** | The Scope line still says "Nothing else" while §4 now requires `docs/coding-workflow.md`, two story files, `todos.md`, the manifest and the changelog. |
| 11 | Major | **Valid** | "Contained in a commit reachable from `origin/main`" never says how a reader maps a ledger *row* to a *commit*. `git merge-base --is-ancestor` needs a commit argument the spec never supplies, and blame can return an amendment commit, several commits, or none for an uncommitted row. The decidability claim rests on a step that does not exist. |
| 12 | Major | **Valid** | "The repository always answers", "decidable in both directions" and "the one way the test misreads" are the `AGENTS.md` overclaim class. A missing or renamed `origin/main`, shallow history, rewritten remote history and command failure are all distinct from a stale ref, and several yield false *un*reachability — the breach direction. |
| 13 | Major | **Valid** | Two branches appending same-scope supersessions, or competing correcting entries retiring one predecessor with different cited answers, merge cleanly under `merge=union` into a state where neither retires the other and AC 4 cannot be satisfied. |
| 14 | Minor | **Valid** | Both fragment slots are shown as mandatory in the grammar and described as conditional in the prose; no escape rule for an embedded double quote. |
| 15 | Minor | **Valid** | `<date>` semantics undefined — discovery, writing, or landing date — while date is half of every locator. §3.1's entry says 2026-08-05 and the change is landing later. |
| 16 | Minor | **Valid** | "Cannot share" their "what is false" text is false; two entries can be worded identically. The next paragraph already concedes free text guarantees nothing. |

## What this needs from Daniel

Not a fix list. The question is whether to keep applying passes on this artifact, or to cut its
scope. Findings 7, 8, 9 and 11 say the reachability replacement is not yet sound: its accounting
misdescribes what it replaced, and its central test has an undefined step. Findings 2, 3 and 4
say the validation section is still ahead of its own mechanism.
