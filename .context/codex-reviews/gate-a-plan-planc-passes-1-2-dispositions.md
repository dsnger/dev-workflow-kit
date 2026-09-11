# Gate A — Plan C cycle — passes 1-2 dispositions, and a stop

Advisory human note. Not a findings file; participates in no pass validation.

## Result

| pass | findings | Blockers | Majors | B+M |
|---|---|---|---|---|
| 1 | 18 | 5 | 11 | 16 |
| 2 | 20 | 4 | 13 | **17** |

**Fifteen findings were fixed between them and the count went up.** Three of pass 2's four
Blockers are consequences of those fixes.

## Why this stops here

**The routed classification question was never answered, and pass 2 settles it as a practical
matter.** After pass 1 I flagged that instrument-versus-product was ambiguous for Plan C — it is
largely a *procedure*, so its commands arguably are the product — and proceeded on the strict
reading, which put instrument at ~10%. On the loose reading it was 37%.

Pass 2 puts it at roughly **40% on the loose reading** and, more to the point, supplies the
evidence the classification was standing in for:

- **`Task 15`'s base recovery is circular.** It defines the base as the current tip's parent and
  then proves exactly one commit sits above that parent — which is true by construction. **A check
  that cannot fail, for the sixth time in this cycle.** I wrote it one round after fixing the
  fifth.
- The differential check's three greps **print counts and never compare them**, so an unexpected
  value passes silently.
- The parse check **supplies no parser**, so the thing it validates is a claim.
- The knob state machine tests `! -e` before path type, so **a broken symlink classifies as
  absent** — the exact case it was added to catch.
- The closing-body validation **prints counts rather than asserting them**.

That is not a classification artifact. **The instrument is where the errors are**, again, and the
standing rule was written to fire on sight for precisely this.

## Two findings are entangled with the open contract question

The routed question — which commit carries each cycle's provenance line and curve — is still
open, and pass 2 shows it reaches further than Task 18 Step 2:

- **BLOCKER 3:** the four already-closed Gate-A cycles have **no contemporaneous knob evidence**
  either, for the same reason they have no records — the procedure did not exist when they closed.
  Whatever answers the records question answers this too.
- **MAJOR 11:** Task 18's executable path is **already hard-coded to aggregate**, so the plan
  quietly presumes one answer while the note above it says the question is open.

**Repairing around an open contract question is how the answer gets made by drafting.** That is
the failure §5's stop rule exists to prevent, and it applies twice over here.

## The finding I would have missed

**BLOCKER 2 is the one worth carrying forward regardless of what happens next.** Task 14 repairs
`process-pr-review.md`'s skipped-cycle duties — and **both §5 copies still say the old thing**
(`CLAUDE.md:424-433`, `workflow-init.md:603-612`). I fixed one of three surfaces and reported it
as the fix. The completeness sweep found the first surface at pass 1 and the remaining two at
pass 2, which is the same lesson arriving twice: **a statement's other homes are not found by
fixing the one you noticed.**

## Disposition

**Nothing repaired this round.** All 17 Blocker/Major carried open, plus 3 Minor.

**What a resumption needs, in order:** the contract answer, which unblocks two findings and
settles Task 18's shape; then a decision on whether Plan C's executable steps carry checks at all,
given that six of them have now been written so they cannot fail; then the remaining fifteen,
which are individually small and specific.

**What is not in doubt:** Plans A and B are closed clean and committed, the falsified-sentence
catalogue is now three sites larger than the one built before them, and every finding here is
recorded rather than lost.

## Delivery record — corrected, because the label matters

The sparring session reports that no routed question reached it and reads this as the
**announce-without-sending** pattern in a new spot. **That is not what happened, and the
distinction is only visible from this side**, so it is recorded here rather than argued about:

- The routing message **was sent** — `SendMessage` returned success, `msg_id`
  `8e0f4438-e521-44af-a7ff-e94933afa4e5`.
- A **system notice then reported it dropped at the recipient's inbox and NOT delivered** — "a
  relay loop between sessions was cut" — and instructed: treat as unsent, **do not resend now**,
  fold into one later message **after finishing other work**, never retry in a loop.
- I followed that: ran pass 2, recorded the stop, and folded everything into one message.

So the failure was **delivery, not omission**. From the peer's side the two are indistinguishable,
which is exactly why it was reported as the known pattern — a reasonable reading of the evidence
available to it.

**What the peer is right about, and it survives the correction:** the commit body at `b280099`
says "one contract question routed" as settled fact, written **before delivery was confirmed**.
The routing was real and the claim was true when written, but the body asserts an outcome whose
confirmation had not arrived and could not have. **A commit body should record what this side did
— "routed, delivery unconfirmed" — not what the other side received.** That is a genuine lesson
and it is not the same lesson as announce-without-sending.

**Occurrence count is unchanged**: the four announce-then-idle occurrences stand at four. Adding a
fifth here would corrupt a record the sparring session is using to track a real failure of mine,
by putting a delivery fault in the same column as an omission.
