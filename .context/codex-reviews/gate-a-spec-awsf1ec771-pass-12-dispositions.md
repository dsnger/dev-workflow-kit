# Gate-A spec pass 12 — dispositions (cycle awsf1ec771)

Advisory companion. Not a findings file; participates in no pass validation.

## Two mechanisms ended this round, and the criterion that ended them

Daniel brought a criterion mid-loop from a sibling project and endorsed it: **the second finding
of the same shape against the same mechanism ends that mechanism's rounds** — narrow the claim,
print the residual, move the work rather than running another round on it. (Its two companion
lines — a product Major always blocks, a harness Major blocks only where it makes a claim
vacuous — are already in `CLAUDE.md` Mechanics as the instrument carve-out. The third line has no
counterpart; captured as
`docs/superpowers/stories/2026-09-10-harness-finding-termination-story.md`.)

Both mechanisms below were on their **fourth** round of one shape.

**Mechanism 1 — §7's assert list. Moved to the plan.** Shape: "an assertion that does not detect
what it claims." Pass 8 found one and that revision's own audit three more; pass 11 found four,
three of them mis-cited line ranges; pass 12 found three (findings 10, 11, 16). The cause is
structural, not clerical: a spec cannot build an exact single-line substring check for text that
does not exist yet, so every round guesses and a wrong guess reads as a failed check rather than
a wrong one. §7 now states what a check must establish, names which edits owe a discriminating
pair and which are presence-only, hands fragment construction to the plan where the text exists,
and prints the residual — nothing verifies that the list of edits is complete or that the plan's
fragments discriminate.

**Mechanism 2 — the block restating what it cites. Made mechanical.** Shape: "the block carries a
predicate its own source paragraph still defines." Pass 11's finding 14 named it; pass 12 found
four more (5, 6, 7, 8). The principle is no longer asserted but checkable: **a cited rule
contributes zero predicate words to the block.** Verified by probe — the eight predicate phrases
that were in the block now count 0 in it, while the citations count 1–3.

## Findings

1  | fixed     | §9 no longer claims a rollback has a defined transition. A revert removes this change's own text, §4 item 6 included, so the stricter reading is itself part of what goes; stated as an admitted residual, and the successor's open question, which its §5 does carry.
2  | fixed     | All four source pointers (`b12`, `b17`–`b18`, the (c) replacement, the (e) pointer) now defer to the ordering for what an answer does. Four sites each carrying their own version is how they came to disagree with the block about a stop answer. `c19`'s accounting corrected to match its own NEW text.
3  | fixed     | `b17`–`b18` no longer says "the revised artifact"; it defers. §7 gains the row: a decline that leaves nothing to revise, next state a further pass on the unrevised artifact.
4  | fixed     | `a16` ("fix Blocker/Major after each") now points at Mechanics · Severity, which carries the assigned-fix-set scope §4 item 3 gives it. Marked **replaced**, out of the kept range, old condition enumerated. Pointer chosen over restating the scope, per the directive.
5  | fixed     | Block cites `b11` and `b13` and restates neither. The decline exception was already in `b11`; the answered-question qualification is added to `b13` at source as a new sixth (b) edit, with its own accounting.
6  | fixed     | The fix-set formula lives only in `b7`. The block says "the current assigned fix set as the absorb paragraph defines it" and computes nothing.
7  | fixed     | The effective/reviewer-written partition lives only in the (g) replacement, inside Mechanics · Severity. The block names which rule settles it and stops restating the split, in both places it had it.
8  | fixed     | `c9`'s precedence sentence **moved** into the block, word for word — precedence is evaluation order, which is the block's subject. The clearly-stuck paragraph keeps only its reading and points forward. Accounting changed from "kept verbatim and qualified" to **moved**. D3 is satisfied by a move, which does not touch the words; the block names the sentence as that paragraph's so its opening clause resolves.
9  | fixed     | "unless the user explicitly reverses that decision" deleted. D7 admits no exception; a contradicting later answer is a contradiction to surface, and permitting a reversal would let a finding be moved out of the set and back in to escape what it owes there.
10 | dissolved | The b11 OLD substring could never reach 0 because it survives inside its own replacement. Dissolves with Mechanism 1: no substring is named here any more.
11 | dissolved | The missing `b17`–`b18` pair. Dissolves with Mechanism 1; §7 now names `b17`–`b18` among the edits that owe a pair, and the plan builds it.
12 | fixed     | The profile-change row is split in two: the profile change while the hold awaits its answer, next state the hold standing and no pass run; then the answer in each direction, only a resuming one starting the further pass. A single row would have to run a pass through an unanswered hold to be filled in.
13 | fixed     | The partial-adoption guard is now an **owned residual of this change**, not assigned to the successor — whose scope is record durability and excludes the closure ordering by name, so the assignment named an owner that had not taken it. Same correction applied to §7's observability residual, which had the same defect.
14 | fixed     | `b7`'s NEW text carries its reasons inline: the union because a cycle no single artifact governs has no set at all under the singular reading, the subtraction because a decline is the user's answer that the finding stays out.
15 | fixed     | §2 recounts with the unit stated — one edit per contiguous replacement or addition at one site: **nineteen**, five outside the inventoried passages and fourteen inside, with §4 item 6 counted once, in §5(i).
16 | dissolved | The missing `c9` assertion. Dissolves with Mechanism 1 — and the underlying risk changed shape anyway, since `c9` is now **moved** rather than kept in place, so §7 lists the (c) replacement among the edits owing a pair.
17 | fixed     | Full repository-relative path, and a rule added to §8 covering all of them.
18 | fixed     | Same.
19 | fixed     | Same.
20 | fixed     | Same.
21 | fixed     | Same. Whole-file sweep run: every backticked path now resolves, and each was checked to exist.

## Notes

- The moved `c9` sentence wraps across two lines in the spec, so `grep -F` on the whole phrase
  counts 0. Verified by reading instead. That is the same false-red class Mechanism 1 documents,
  reproduced in this session's own checking.
- `scripts/check-version-bump.sh main` was written as a bare basename and is now full, found by
  the sweep rather than by a finding.
