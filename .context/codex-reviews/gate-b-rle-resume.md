# Gate-B cycle `rle` — resume note (cycle-stable, per CLAUDE.md §5)

Advisory human note. Not a findings file; participates in no pass validation.

**Artifact:** the combined A+B+C diff. **Base:** ab8ac98ef7eccf06d9d24a74f201b06016228dd5
(fixed at cycle open, never moved). **WIP tip at write time:** 203cf6b.
**Slots:** `gate-b-<spec|quality>-rle-pass-<p>.md` — a RECORDED plan-local naming exception
under the old rules, approved by Daniel 2026-09-02. Reason: this cycle is pre-rule and cannot
mint a nonce, and the bare family already holds 30 files that delete-before-call would destroy
(re-inventoried; the plan's "61" was stale, and the plan said to re-count rather than trust it).

## Pass ledger
| pass | findings | Blocker | Major | counted? |
|---|---|---|---|---|
| 1 | 16 (spec 14 + quality 2) | 4 | 5 | yes |
| 2 | 29 (spec 16 + quality 13) | 15 | 2 | **NO** — both files structurally valid, but the reply contradicted itself: each reviewer reported the other branch INCOMPLETE, mistaking its counterpart's legitimate file for a foreign write. Findings acted on; pass not credited |
| 3 | 25 (spec 16 + quality 9) | 6 | 9 | yes |

Counted passes: 2 of a floor of 3.

## STATUS AT PASS 3: stopped and surfaced.

### The three lines
1. TREND — findings 16 -> 29 -> 25; Blocker+Major 9 -> 17 -> 15; Blockers 4 -> 15 -> 6.
   Nothing has returned to its pass-1 level.
2. CLUSTER — two groups, and both are about corrections rather than about the original work.
   (a) **My own fixes**: the knob description, the profile-case partition, the model-cause
   enumeration, the Story-header syntax, the process-pr-review clarification. Each was
   introduced or rewritten by a previous pass and is wrong again in a subtler way.
   (b) **Upstream artifacts the shipped prompts now contradict**: the story, the spec at
   revision 36, Plan B and Plan C still assert what the prompts were corrected to stop
   asserting.
3. REQUIRE-WITHDRAW — no clean pair. Pass 3 refines what pass 2 demanded rather than
   withdrawing it.

### Tells
- Finding count failing to fall: **present** (16 -> 29 -> 25).
- Blocker count failing to fall: **present** (4 -> 15 -> 6).
- Instrument cluster: N/A, no test instrument.
- Prose-about cluster: **present** — a large share of pass 3 is about the plan, spec and story
  artifacts rather than the shipped prompts.
- Require-withdraw pair: absent.
Three tells. Two make stop-and-surface mandatory.

### A second, independent trigger
`docs/prompt-standards.md` item 11: **"when a claim about a mechanism needs a fourth
correction, delete the claim rather than refine it a fifth time."** The knob paragraph has now
been written three times and is wrong a third time; the model-cause enumeration twice. This is
the named remedy for exactly this shape, and it points at deletion, not a fourth refinement.

### The sharpest single defect
The `Story:` syntax I pinned in pass 2 accepts a bare or double-quoted path. **Every**
`Story:` header in this repository uses Markdown backticks, and several carry trailing prose
after the path. Under the rule now shipped, all of them are malformed — including the three
plans governing this very cycle. A rule that invalidates its own governing artifacts is not a
refinement problem.

## Open, nothing acted on at the stop
Spec: 5 Blocker, 2 Major. Quality: 1 Blocker, 7 Major. Files:
`.context/codex-reviews/gate-b-{spec,quality}-rle-pass-3.md`.

## Evidence state (valid, revalidated at pass 3)
Battery green after every round. Check-that-fails-without-the-change: the four pass-1-Minor
assertions. Named risk-path verification: DISCHARGED — union of the three plans' Story headers
is one story, Risk high / Security none, level 2, floor 3; the provenance line matches the
pinned grammar and its floor is licensed by that level.
