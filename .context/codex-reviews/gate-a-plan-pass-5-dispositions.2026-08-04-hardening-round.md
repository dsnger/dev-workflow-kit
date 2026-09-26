# Gate A — plan — pass 5 dispositions

9 findings, 5 Major, 4 Minor, no Blockers. Plan trend 19 → 11 → 19 → 11 → 9. All 9 accepted;
none dismissed; **none required a decision from Daniel** — no new class, no reversal of a settled
decision. That is the pinned exit, so the plan's Gate A closes here.

Both settled decisions the pass was asked to judge on their merits survived: the reviewer
reported no dropped check whose violation would reach the commit undetected, and no round-specific
content lost in the §5 citation.

## Fixed

- **1 (MAJOR)** — the plan appended evidence case 3 beneath the scope-blind row's own premise,
  which this round disproved: the row still said the workaround "lives in ledger prose, which
  agents do not read", while `harden-finding` step 3 does re-read the log. Task 6 Step 2 now
  corrects the premise to the decision-branch diagnosis **in the same change**, before appending.
  Leaving it would have been `docs-drift` created by the round that hardens it.
- **2 (MAJOR)** — the branch preflight's resumed path printed an ahead-*count* while the prose
  claimed the executor could confirm the range holds only this plan's commits. A count cannot
  establish that. It now prints the actual `main..feature` commit list with an explicit stop
  instruction.
- **6 (MAJOR)** — evidence creation had the classify-then-create race the story paths had already
  been fixed for. Same treatment: temporary file, `ln` into place, `trap` cleanup. This file is
  quoted verbatim into the commit body and the PR, so foreign content reaching it is worse than a
  stray story copy.
- **7 (MAJOR)** — the `<fill` guard's branch binding was an unanchored `grep -q 'Branch: …'`,
  which `OldBranch: harden-0-8-0-and-pr-21` would satisfy, and it never checked the actually
  checked-out branch before a history-mutating amend. Now `grep -qxF` whole-line matches for both
  `Branch` and `Story`, plus a `rev-parse --abbrev-ref HEAD` equality check inside the same block.
- **8 (MAJOR)** — the PR block re-read the evidence after Step 6's validation window with only a
  nonempty test. `.context/` is git-ignored and mutable, so a replacement, symlink or reintroduced
  placeholder between blocks would have reached the PR unvalidated. The full check set is repeated
  immediately before the body is read.
- **3 (MINOR)** — Task 1's first battery runs before the plugin edit is committed, so
  `check-version-bump.sh` compares a range containing neither the edit nor the bump: its result is
  **vacuous**, and the plan said "real check". Now states which invocation is the first meaningful
  invariant-12 observation.
- **4 (MINOR)** — Task 6's steps named a row but no position within it. Every parked row ends with
  an italic `*Trigger:*` sentence, so all status blocks now insert immediately before it, keeping
  the trigger last.
- **5 (MINOR, medium)** — the temp-file-plus-`ln` recipe specified no cleanup. A successful link
  leaves a second untracked story copy and a collision stop leaves scratch content — both are
  scanned by `check-invariants.sh`, which walks the working tree rather than the tracked set, and
  both break later clean-tree preconditions. `trap 'rm -f "$tmp"' EXIT`, set as soon as the name
  is allocated.
- **9 (MINOR, medium)** — nothing compared local `HEAD` to `origin/<branch>` before `gh pr create`,
  so a commit made between push and PR would open a PR whose remote head omits the reviewed close.
  Compared explicitly, with a stop on divergence.

## Sweep after fixing

22 blocks. All parse under `sh -n` and `dash -n`; no `${var:o:l}`, `[[ ]]`, `<(...)`, `declare` or
`local`; every block reading `EVIDENCE` defines it; no unanchored `Branch:` grep remains; the
stated verification totals (four executable checks plus one recorded reading) match what exists.

## Gate A closes for the plan

Five valid passes under the file-first protocol, every finding dispositioned in writing. The
final pass returned no Blocker and nothing requiring a decision. The plan is ready to execute.
