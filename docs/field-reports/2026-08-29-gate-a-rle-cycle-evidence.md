# Gate-A spec cycle `rle` — the record, preserved

The Gate-A spec cycle for
`docs/superpowers/specs/2026-08-28-review-loop-economics-design.md` ran **34 passes** and closed
clean. Its 34 validated findings files live under `.context/codex-reviews/`, which is gitignored,
so **this file is the durable record** — written before any slot reuse or `.context/` clear, the
same reason `2026-08-26-fic2-cycle-evidence.md` exists.

Every number below was extracted mechanically from those files
(`grep -cE '^(BLOCKER|MAJOR|MINOR|NIT) \|'` and `grep -c '^BLOCKER'` per pass), not recalled.

## The curve

```
Findings 27, 30, 54, 40, 33, 34, 32, 33, 28, 27, 38, 24, 32, 18, 13, 4, 6, 2, 7, 6, 9, 4, 2, 7, 5, 4, 6, 6, 3, 3, 1, 2, 1, 1
Blockers  5,  2,  0,  4,  0,  3,  9,  4,  2,  2,  2,  5,  9,  0,  0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 1, 1, 0, 0
Majors   19, 20, 43, 27, 30, 23, 20, 24, 20, 21, 28, 12, 19, 12,  9, 3, 3, 1, 4, 4, 3, 3, 2, 2, 3, 3, 5, 4, 2, 1, 0, 1, 1, 0
```

Blocker/Major never fell below 22 for the first eleven passes. **Two structural decisions moved
it, and nothing else did.**

| Pass | Event | Blocker/Major after |
|---|---|---|
| 1–11 | ordinary repair rounds | 22–43, never below 22 |
| 12 | **part 3 split to a successor story** | 17 |
| 13 | (split accounting errors) | 28 |
| 14 | **spec slimmed 604 → 332 lines, rules only** | 12 |
| 15–34 | ordinary repair rounds | 9, then 1–5 throughout |

**Three mandatory two-tell stops** fired, at passes 6, 11 and 13, each surfaced to the human, and
the second and third produced the two structural decisions above. A fourth stop at pass 7 was
discretionary — the tells were readable before the duty activates at pass 4.

## What the passes actually cost, by cause

Of roughly 380 findings, the recurring generators were:

1. **A restatement that must track a moving original.** Three sites in one cycle: the story's
   acceptance criteria (five Blocker occurrences), the spec's own condition-inventory table (four
   more), and — three revisions running — a summary of §5's triviality skip, where each attempt
   corrected the summary instead of deleting it and each new summary dropped a different condition.
   **The remedy is never a better summary.**
2. **A correction landing in one place and not the others.** The demotion-versus-comparison
   correction took four revisions to propagate across four artifacts; twice I wrote in a commit
   body that I had enumerated every site and had not.
3. **A repair generating the next defect.** Most Blockers from pass 10 onward traced to the
   immediately preceding revision's own fix.

## Findings worth keeping

- **A restructuring guard that asks "did a decision move?" misses the case where a rule survives
  in outline and loses its force.** Pass 9 found eight of those in one revision — including a
  severity test compressed to "if you can name neither", which inverts a rule requiring both.
- **Running a check is not reading its output.** Twice I ran a grep, wrote a sentence its own
  output contradicted, and cited the verification. A grep for the phrasing you expect is not a
  check either — my search for compression losses returned zero because the reviewer had phrased
  them differently.
- **An instrument that cannot measure its own subject.** The per-pass curve recorded Findings and
  Blockers while existing to show whether severity moves the Blocker/Major line.
- **Comparable is not measured.** Even with Majors recorded, no finding is ever classified under
  both rules, so no demotion figure is derivable — only a comparison of recorded mixes across
  cycles that reviewed different artifacts.
- **The loop's first wrong finding arrived at pass 13**, in roughly 380. It claimed a syntax break
  a prior revision had already replaced; dismissed with grep evidence. One bad finding in ~380 is
  the argument *for* validating before applying, not against it.

## Closing state

Pass 34 returned **zero Blocker/Major** and one MINOR, collected per §5's clean-final-pass rule:
§4's rationale claims the lost series differs across cycles, which nothing establishes. Recorded
here as the cycle's one outstanding Minor.

**Coverage statement.** The `/workflow-init` mirror's actual text was checked by hand against every
claim the spec makes about it, re-run against the final revision: the template block is fenced at
192–778 with §5 at 257–777; the describe-versus-be principle the severity kinship rests on **is
present** in the template (an earlier revision's claim that it was absent was withdrawn); the
hook's §5-heading regex still matches `CLAUDE.md`; and `workflow-init.md` retains exactly one
`Target model:` declaration, which the item-1 n/a decision preserves. **Known limit:** the two
copies diverge on ~192 lines overall, and only the rules this change touches were compared —
general reconciliation was out of scope throughout.
