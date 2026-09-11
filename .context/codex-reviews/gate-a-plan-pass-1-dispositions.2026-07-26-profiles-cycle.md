# Gate A — plan — pass 1 dispositions

12 findings, 3 Blockers. All accepted.

1  BLOCKER closing commit body echoes risk/security/mode — ACCEPT. My own Global Constraint, violated in the plan's own example. The entry carries the story PATH and the named evidence, nothing else.
2  BLOCKER new Flow step 6 asks inside step 3's round, which has already closed — ACCEPT. Unimplementable as written. The profile assessment moves BEFORE the question round: read -> detect ambiguity -> assess profile -> one round carrying clarifications AND the proposal -> pause. Whole flow renumbered to 11 steps.
3  BLOCKER battery runs before the version bump is committed, and `check-version-bump.sh main` compares COMMITS — ACCEPT. It would fail on a tree whose plugin edits are committed with no bump. The WIP snapshot now includes the manifest and CHANGELOG, and the battery runs at that snapshot's SHA.
4  MAJOR Gate-B call omits the evidence entry it is required to quote — ACCEPT. The entry is written into the WIP body before the first pass, and every pass's context quotes that exact entry.
5  MAJOR no handling for a header whose Validation contradicts the axes — ACCEPT, and it is genuinely new: the spec's case 3 covers a value outside the enums, not an in-enum value inconsistent with `max(risk, security)` or a `+abuse-path` suffix disagreeing with security. Added to the plan's §5 text AND to the spec in the same change, so the two do not disagree.
6  MAJOR profile-log block has no shown placement — ACCEPT. A conditional example goes inside the story-template code block directly beneath the header, marked absent until the first event (prompt standard 4: show the output format).
7  MAJOR mode-override events have no direction in the log grammar — ACCEPT. Direction applies to mode overrides too; one example line per event kind now ships in the template guidance.
8  MAJOR the agreement diff covers only the Profiles subsection, not the Mechanics sentence — ACCEPT, and it is the sharper half: the paired edit was half-verified while claiming to be checked. A second diff covers the Finishing-the-cycle bullet.
9  MAJOR battery command drops `claude plugin validate . --strict` — ACCEPT. AGENTS.md's quality row includes it and the plan claimed plugin validation ran. "Never document a command that wasn't run."
10 MAJOR evidence says "run at <sha>" for a battery run on an uncommitted tree — ACCEPT. Same fix as 3: snapshot first, run at that SHA, re-run after every fix, quote the SHA actually reviewed.
11 MAJOR Task 4's replacement text starts mid-sentence, so literal execution corrupts the paragraph — ACCEPT. Anchor widened to the full sentence beginning "The `intake` skill".
12 MINOR audit verdicts live only in WIP messages that the soft reset discards — ACCEPT. They move into the final commit body (no profile values), where a reviewer can still tell "read and accurate" from "never checked".
