# Gate A — plan — pass 4 dispositions

11 findings, 1 Blocker, 10 Major. Plan trend 19 → 11 → 19 → 11. All accepted; none dismissed.
One went to Daniel because it required a structural decision.

## The Blocker

**1 (BLOCKER)** — Task 9 told the executor to *stage* each Gate-B fix and never to amend it into
the WIP commit. `mcp__codex__review` reads a **git range**, so a staged-but-uncommitted fix is
not in it: every post-fix pass would have re-reviewed the pre-fix commit and reported clean on
unreviewed content. The staged index also makes the clean-tree precondition before the amend
unsatisfiable, so any Gate-B finding either deadlocks or closes on content nobody reviewed.

This is the parked "Gate-B fingerprints disk; the reviewer reads history" row, reproduced inside
the fix loop.

## The structural decision (Daniel's call)

Eight of the eleven findings sat in the git/Gate-B/PR procedure; the hardening content has been
stable for four passes. The cause: `CLAUDE.md` §5 already specifies that protocol
authoritatively, and Task 9 **restated** it — each restatement a fresh chance to drift, which is
what `prompt-standards` item 11 warns about by name. The Blocker is a restatement that dropped
§5's amend step.

**Decision: cite §5, do not restate it.** Task 9 now keeps only what is specific to this round —
the evidence template, the four self-test cases, the prompt-conformance scope — and points at §5
for the squash, Gate-B loop, amend and close. One clause names the dropped step explicitly
("§5 governs, including its amend-every-fix-into-the-WIP-before-re-review requirement"), because
naming a step is not re-specifying a procedure, and that step proved droppable.

That deletion resolves findings 1, 2, 7 and most of 8 by construction.

## Fixed directly

- **10 (MAJOR)** — the plan claimed "five executable checks, each self-contained and exiting
  nonzero on failure". The self-tests are prose readings with no block and no exit status, so
  the claim was false and the rider's execution report impossible. Now stated honestly: **four
  executable checks plus one recorded reading**, with the reason — applying a prompt sentence to
  a case is a judgement, and a script asserting it would assert its author's opinion. An
  enforcement claim with no mechanism, inside the round that hardens that class.
- **3 (MAJOR)** — the branch preflight validated only the name. It now requires a clean tree and
  index first, and on a resumed run prints the ahead-count so the executor can confirm the range
  is this plan's commits. A pre-existing edit would otherwise be swept into whichever task
  commits the same path, indistinguishable in the diff from this round's work.
- **4 (MAJOR)** — the cut dropped the spec's requirement that an absent story path be created by
  an operation that fails if the path appeared meanwhile. Restored as a must-be-true naming the
  mechanism (write to a temp file, `ln` into place), with the reason: a truncating redirect's
  clobber is invisible in the final diff.
- **5 (MAJOR, medium)** — byte-identical reuse was a success state, yet each task still committed
  unconditionally and the squash expected a fixed count. Resume semantics stated: identical means
  skip the commit, and the squash folds whatever commits exist.
- **6 (MAJOR)** — the hook-count derivation redirected to a literal `out` in the repo root, which
  would collide with a user file and leave an untracked artifact for the clean-tree guard to trip
  over. Now `mktemp`, with the suite's own exit status captured before counting.
- **8 (MAJOR)** — push accepted any non-`main` branch and the PR block had no refusal at all.
  Both now require the exact branch name; a `!= main` test passes on any wrong branch.
- **9 (MAJOR)** — `--body "$(cat "$EVIDENCE")"` swallows a `cat` failure, so a read error would
  have opened the PR with an empty body. Read into a variable with an explicit stop.
- **11 (MAJOR, medium)** — resumed evidence was reused on path existence alone. Now requires a
  regular non-symlink file whose header names this story and this branch; a stale file from
  another cycle would otherwise pass the `<fill` guard and be copied into the commit and PR.
- **7 (MAJOR)** — the guard and the amend were separate fresh-shell blocks, so state could change
  between them. Folded into one block.

## Sweep after fixing

22 blocks (from 24, and 38 before the cut). All parse under `sh -n` and `dash -n`; no bash-isms;
every block reading `EVIDENCE` defines it; no fixed-path temporary files; the "five checks"
claim is gone and the stated total matches what exists.
