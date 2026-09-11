# Gate-A spec pass 13 — dispositions (cycle awsf1ec771)

Advisory companion, not a findings file. Findings: `gate-a-spec-awsf1ec771-pass-13.md`.

**This round is a cut first and a repair second.** Measured before deciding: the spec was 785
lines, of which §3's closure ordering — the design it exists to state — was **173, 22%**. The
bookkeeping about the change (§4 quoted OLD/NEW 83, §5 per-condition accounting 216, §6 parity
list 38, §7 verification substrings 119) was **456 lines, 58%**, and had been taking roughly half
the findings of every pass. Pass 12 had already run the experiment at small scale: moving the
verification substrings to the plan killed three Majors at once and regenerated nothing, because
a spec cannot build an exact check for text that does not yet exist. Daniel's decision: cut now.

All four are **moved to the plan, not dropped** — the plan performs them against real files,
which is the only place they can be checked. Story acceptance criterion 5 is satisfied by the
plan's per-condition disposition list; §5 keeps the ten-passage map so nothing falls out of view.

Result: **533 → 532 lines after trims, delta −253 from 785.** §3 unchanged in role and grown only
by the findings applied to it.

1  | fixed          | validated dismissal is a resolution route beside repair, discharging the duty for that finding without rewriting the pass that found it; a dismissal the reviewer keeps re-raising is regeneration and counts toward the clearly-stuck third condition, so the repeat false positive reaches a suspension instead of continuing forever
2  | fixed          | the contradiction gets a state: the decline remains binding, the contradiction is surfaced as information, the cycle continues; withdrawal is a fresh explicit decision by the same authority, not a reversal by these rules, so D7 keeps its no-exception reading
3  | fixed          | clean completion at or above the floor makes the cycle eligible to close; the closing amend Mechanics · Finishing the cycle describes is the closure itself, so nothing is closed before it and a profile, cited set or evidence entry changing in between still gates it
4  | fixed          | `b8` tests membership against the assigned fix set as `b7` computes it, replaced rather than kept — §4 item 11
5  | fixed          | `b3` becomes a pure pointer to Mechanics and stops restating the four severity actions, in both copies — §4 item 9. W's pointer target also aligns to C (§6)
6  | fixed          | §6's equivalence check names `b13`'s already-answered qualification alongside `b11`'s already-declined exception, compared in both directions
7  | fixed          | the false claim is deleted; the block itself now carries both in-session consequences — a line per branch file is a distinct finding, and an answer binds to the finding or question as the pass that raised it recorded them. Cross-session recognition is named as the successor's
8  | fixed          | the evidence entry's revalidation rule joins what closure reads and the one-authority table, cited and not restated, and joins the oracle's unmet-precondition list
9  | fixed          | continue permits an unrevised artifact only where no repair is owed, with its reason inline; the third branch carries the same qualification
10 | fixed          | §7's next-state table claim is narrowed to answer-state transitions once the predicates are established, with separate named checks for logical-pass completeness and each cited final-acceptance precondition. No fixture-per-predicate mechanism added
11 | fixed          | the one-or-two answer count is scoped to scope-stop answers; a shared health continue-or-stop answer is additional and not counted among them
12 | fixed          | §4 item 20 carries its reason in the shipped clause — unknown starting rules cannot waive an open hold — per prompt-standards item 6
13 | dissolved      | the count is recomputed against its own enumeration: twenty source edits, the block an addition beside them, twenty-one changes in all. §8's version-bump rationale moves with it
14 | dissolved      | §1 now reads five outside the inventoried passages and fifteen inside, eighteen replacements and two additions — verified against §4's twenty rows
15 | dissolved      | the OLD quotations left with the cut; §4 names each sentence and what changes about it, and the plan quotes it from the real file
16 | dissolved      | same as 15

## Checks run before commit

- **Precheck** `.context/spec-precheck.py`: exit 0. Fences balanced, 11 cited paths all exist, no
  ellipsis shorthand, no OLD fenced blocks left to verify.
- **Counts against enumerations:** inventory 135 ✓; §4 twenty rows, 18 replacements + 2 additions
  ✓; §3 "nine rules" against nine table rows ✓; §5 ten passage rows against the ten inventoried
  passages ✓; §4 items 6–20 all referenced by the passage map, 1–5 correctly outside it ✓.
- **One-authority probe:** the block cites nine rules and defines none; each has one definition in
  the shipped text, and the one exception — `c9`'s precedence sentence moving *into* the block —
  is stated as such, because precedence is evaluation order.
- **Transition walk**, the check pass 13's finding 2 exists for. Every state named, its input, its
  next state: clean at/above floor → eligible → amend → **closed**; clean below floor with no
  suspension → continue; not clean, no suspension → continue with repair where owed; membership
  stop → accept or decline → hold discharged → continue; question stop → decision → continue;
  both triggers → both answers → continue; clearly-stuck or two-tell → continue (reading consumed)
  or stop → **parked** → later continue → resumes; several suspensions → one stop answer parks the
  whole; contradiction to a decline → surfaced, cycle continues; re-raised validated dismissal →
  regeneration → clearly-stuck → continue or park; zero-finding pass → eligible → closed;
  precondition changed before the amend → not closed, fix and re-review → continue. **Close or
  park is reachable from every state; no state returns itself with its input consumed.**
