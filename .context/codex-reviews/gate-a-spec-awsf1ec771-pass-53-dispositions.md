# Pass 53 dispositions — cycle `awsf1ec771`

Advisory. One line per finding: verdict + reason. 21 findings: 4 MAJOR, 14 MINOR, 3 NIT.
Reviewed at `81fffd1`. Blocker count 0.

## Majors — all four accepted, three of them via a scope decision

1. **ACCEPTED, repaired.** §A1 "Nothing is assumed about what the attempt left behind" versus
   §A3's "a failed attempt adds no commit" and §F item 5's "no commit made". Verified by quoted
   content at lines 175, 438 and 728. Both assertions deleted; §A1's repository-state rule is now
   the single source, per the file's own cite-don't-restate rule.
19. **ACCEPTED, scope opened narrowly, repaired in §F.** The shipped string at
    `codex-gate.sh:967` — "Gate A has no content check behind it — this floor is the only thing
    keeping the spec review honest" — is falsified by §A2's content condition. Verified present
    verbatim. Now §F item 10.
20. **ACCEPTED, scope opened narrowly, repaired in §F.** The clean-pass definition "no new
    Blocker/Major" at `codex-gate.sh:973` and `:956` is an abbreviated second copy of a predicate
    §A1 now states in full. Verified present verbatim in both. Now §F items 11 and 12.
21. **SPLIT.** The clean-definition half is item 20's, handled above. The fingerprint half —
    "only the fresh pass(es) carry the same fingerprint as what you are committing" — is a
    **pre-existing** overclaim, parked with the Gate-B tree-equality material by Daniel's decision
    of 2026-09-13, and §I already records that the hook's fingerprint is not a substitute. Not
    repaired, deliberately. Recorded in §F item 12 as explicitly untouched.

## The scope decision behind 19, 20 and 21

The story and the design both put hook code out of scope. A reviewer opinion Daniel obtained
argued that prompt-standards item 7 (`docs/prompt-standards.md:53–55`, "if it supersedes one,
update the old text in the same change") reaches a hook reminder, a reminder being prompt text an
agent acts on, and that the blast radius was smaller than first estimated. Verified: three `note`
strings, one exact-match test expectation (`codex-gate.test.sh:1019`), no fixtures, and a version
bump already owed for the template. **Daniel authorised a narrow opening on 2026-09-13:** the
three strings and that one expectation are in scope; hook behaviour is not. Story §Out of scope
and design §§3, 6, 7 and the out-of-scope list now carry the carve-out.

Two claims of mine in presenting that decision were unbacked and are corrected in the record:
"half a day" and "fixtures must change". Neither survived checking.

## Minor and Nit — 17, collected, not iterated

Per Mechanics · Severity. Four are worth naming because a later pass will meet them again:

- **4 and 5** (the §F total): design §4 says "no total is claimed here or in the target text"
  while §F's heading claims one. The heading now reads seventeen, so the contradiction stands
  unchanged in substance. Collected.
- **14**: the target describes the non-`WIP` reset as counter state only, while
  `codex-gate.sh:886–888` also clears the reviewed fingerprint state. A factual narrowing, not a
  contradiction with the ordering. Collected.
- **17 and 18** (§F items 4 and 8 line citations): the stated start lines are one off against the
  quoted text. Mechanical, cheap, and the plan sweeps citations anyway. Collected.

The remaining twelve are second-copy observations — a rule stated in both §A1 and its owning
section. That is the mechanism the cycle has been converging on for twenty passes and each
instance is a judgement about which site should own the sentence, not a defect in the ordering.
