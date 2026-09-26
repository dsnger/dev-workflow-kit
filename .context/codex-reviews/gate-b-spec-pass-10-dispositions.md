# Gate B — spec branch — pass 10 dispositions

4 findings, all Major. All accepted.

1  MAJOR the getting-started "One trivial change: just commit" opt-out still keys the skip on triviality alone — ACCEPT. Second pre-existing sentence invalidated by this change, twenty lines below the one fixed at pass 9; the summary was corrected while the opt-out list underneath it kept teaching the old rule. Qualified the same way: profiled stories skip Gate B only at effective level 0 and still owe the battery and the recorded reason; unprofiled stories keep the judgement call; Gate A is skippable at no level.
2  MAJOR the plan's quoted Mechanics snippet is still singular — ACCEPT. Synced from the shipped clause, along with the CHANGELOG sentence that repeated it.
3  MAJOR the plan's parity check searches for an anchor the fix deleted — ACCEPT, and the finding proved itself: running the documented command produced `EMPTY CAPTURE: M_REPO` rather than the claimed agreement. That is the guard from pass-2 doing its job on the plan's own instructions — without it the check would have diffed two empty captures and reported success. Anchors updated to the current wording, and the check now returns BOTH HALVES AGREE.
4  MAJOR Gate-B Steps 6 and 7 still demand the evidence entry unconditionally — ACCEPT; the quality branch reported the same. Both steps now scope entries to cited PROFILED stories: every cited story contributes its path, only profiled ones an entry, and this cycle's unprofiled story contributes neither.
