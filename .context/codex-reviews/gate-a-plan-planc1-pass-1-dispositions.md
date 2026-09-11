# Plan C1 — Gate-A pass 1 dispositions (14 findings: 0 B, 8 MAJOR, 3 MINOR, 3 NIT)

Opening: 8 B+M, against Daniel's prediction of <=6 and a route-back threshold of 12. Below the
threshold, so the loop continued. For comparison, Plan C opened at 16 B+M and Plan B at 9.

## MAJOR — six fixed in revision 2

- **Singular "the cited story's profile"** (lines 31-38, 121-125, 170-175, 371-375). VALID and
  verified against Plan A: the floor derives from the cited **set** — 1 only if every cited story
  is level 0, 3 if no story is cited or any is unprofiled, and an unresolvable profile **stops**.
  The singular phrasing is false on three of four states. Every occurrence now uses Plan A's own
  words, *the profile and the cited set*, and the plan states the four states once.
- **An eighth site was missed** (`docs/getting-started.md:35`, the `1/3` counter example). VALID
  and verified live. It teaches a fixed denominator and would have sat one line from Task 2's
  derived-floor sentence, contradicting it on the same screen. Now Task 3. Explicitly NOT C2's:
  C2 owns the *satisfied* message at line 58; this is a below-floor message, the same claim as
  Task 5.
- **Preflight checked only the new sentinel** (lines 64-68, 105-138, ...). VALID, and the resume
  hole was the real cost: an interruption between Replace and Amend left the edit stranded in the
  worktree while the task reported itself done. Every preflight is now a state machine over both
  texts, and the already-replaced branch checks whether the edit reached the WIP before skipping.
- **No amend verified HEAD is the WIP** (lines 54-62 and every amend step). VALID. Each amend now
  checks `git log -1 --pretty=%s` against the exact subject first.
- **Explicit paths do not scope content inside the file** (line 61 and every amend). VALID. Each
  amend step reads `git diff -- <path>` before staging, and the plan says why explicit paths are
  not a scope guard here.
- **Asserts counted substrings, not the replacement** (lines 127-132, ...). VALID, and the example
  was concrete: Task 7 could have dropped half its replacement and still gone green. Six of the
  eight replacements are whole lines and now use `grep -cxF` — exact whole-line equality. Tasks 2
  and 3 land mid-line, cannot use it, and each says so.

## MAJOR — two routed, not absorbed

- **`docs/coding-workflow.md` axes and model-recording sentences are unassigned.**
- **The skipped-cycle duty claim across five files is unassigned.**

Both are correct, and both are correct about the **close**, not about C1: the story requires every
falsified shipped sentence corrected in the same change, so C3 cannot close while these have no
owner. They were already named in C1's scope table as UNASSIGNED; pass 1 confirms that naming them
is not the same as solving them. **Routed to Daniel.** Absorbing them into C1 would rebuild Plan C,
which is the failure the split exists to prevent. C1's scope table now says explicitly that they
block C3's close rather than this plan.

## MINOR / NIT — fixed

- **Accounting row 6/7 was written from a summary, not the live sentence.** VALID and the sharper
  finding of the two Minors: the live sentence asserts profile-supplies-eligibility, battery-still-
  owed, and floor-unchanged. The row claimed a baseline-questions clause the original never made —
  and the draft replacement had *added* that clause. Row rewritten from the live text; the added
  clause is gone, so the replacement now changes exactly the one false clause.
- **Task 9 claimed the knob is described "identically" in both files.** It is not, and should not
  be — README names the source, getting-started does not. Reworded to the property actually meant.
- **No rollback checkpoint.** Now a Global Constraint: record the WIP SHA before Task 1.
- **NIT, assert contract wording** — the constraint said "anything but 1 fails" while every
  negative half wants 0. Stated correctly now.
- **NIT, hook-reset overclaim** — "discarding the cycle's passes" was too broad. The Bash commit
  branch resets **Gate-B** state, regardless of whether the commit succeeded, because it cannot
  observe exit status; Gate-A state is reset by skill events. Corrected.
- **NIT, Task 9 does not always amend.** Stated: Tasks 1-8 always amend, Task 9 only after a fix.

## Found while fixing, not from the pass

The generic knob regex written for Task 9 **errored on this machine's `grep`** ("exceeds
complexity limits", ugrep). A command that cannot run reports nothing and reads as a pass, so it
was replaced with fixed-string checks and the reason recorded in the plan. Both Task 9 greps were
then executed live against the current files and exit as intended.
