# Gate A (spec) — dark-factory vision — pass 5 dispositions — CYCLE CLOSED
15 findings: 0 BLOCKER, 7 MAJOR, 7 MINOR, 1 NIT. Unprofiled run.

## Exit taken
The author's second exit: non-leaf-ownership Majors were present, so the gate
closes as a vision on his scope disposition rather than on a clean pass.

One correction to that exit's stated rationale, because the record should not
carry a false reason. It anticipated "a document generating non-leaf findings
faster than it sheds them". The data says the opposite: findings 52 -> 34 ->
32 -> 26 -> 15, Blockers 2 -> 1 -> 2 -> 2 -> 0. The loop converged. The gate
closes because leaf mechanics are out of scope, not because the loop failed.

## The three lines
1. TREND — p1 52/2/41 · p2 34/1/26 · p3 32/2/24 · p4 26/2/16 · p5 15/0/7.
2. CLUSTER — (a) §11's own entries lagging §7 after pass 4 extended two leaves;
   (b) ownership granularity — coarse step numbers where the document makes the
   leaf the unit; (c) two factual errors about tracked repo artifacts, both
   mine.
3. REQUIRE-WITHDRAW — none. Cleared in pass 4 and did not return.

## Tells
Findings rising: NO. Blocker failing to fall: NO — cleared this pass, 2 -> 0.
Instrument cluster: N/A. Prose-about cluster: partly, and by now expected — the
remaining findings are about the record rather than the design.
Require-withdraw: NO. Zero tells at close, down from two at pass 3.

## Fixed — one deliberate exception to "fix nothing further"
Two findings were factually false statements about tracked repository files
that I introduced in earlier passes. Closing while asserting them would have
published something untrue about the repo, which the exit rule did not
contemplate. Both corrections are narrow and neither changes what the author
decided.
- p5-2 (MAJOR) Decision 8 said the same-family tier-2 question was "closed with
  a negative answer". It is not. What closed with a negative answer was a safe
  *sanctioned zero-pass closure*. A same-family tier-2 reviewer is a different
  question and is still open as a tracked, unshipped story
  (docs/superpowers/stories/2026-08-14-tier-2-same-family-reviewer-story.md);
  the fallback design's own §7 routes to it — "a weaker review is still a
  review" — if its containment proves buildable. My pass-1 fix corrected a
  false claim that the kit ships tier-2 and overcorrected into declaring it
  dead. Decision 8's substance is untouched: another family, or none.
- p5-1 (MAJOR) "it is git-ignored so a clone never sees it" is true of this kit
  repo only. /workflow-init has target projects ignore /.context/codex-reviews/
  specifically, so in a scaffolded project the codex-gate.off marker is visible
  and committable. Narrowed to say which repo is which.

## Recorded, unresolved at close (13)
Appended to §11 as a dated "Unresolved at close" block, each with its leaf:
labeled examples have no owner [unowned]; the orchestrator product is wider
than step 3 [3]; "this closes the parallelism blind spot" overstates smoke
[5b/5c]; two §11 entries lag §7 after 4e and 6d were extended [4e, 6d];
"promotion evidence" names one owner for knobs belonging to three [4d, 6b, 6d];
four top-level questions still cite coarse steps [6b, 4a, 5a, 5c]; three known
wordings kept as they are [editorial].
