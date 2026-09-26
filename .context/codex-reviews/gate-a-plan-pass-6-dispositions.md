# Gate A — plan — pass 6 dispositions — **not clean; surfaced per the pinned exit**

9 findings (1 BLOCKER, 5 MAJOR, 3 MINOR). **None dismissed. None applied.**

The pinned exit was *clean or dispositions-only closes and opens execution; anything else comes
here.* These are real fixes, not dispositions, so it comes here.

## Trend

| Pass | 1 | 2 | 3 | 4 | 5 | 6 |
|---|---|---|---|---|---|---|
| Findings | 18 | 20 | 17 | 15 | 9 | **9** |
| Blockers | 1 | 0 | 1 | 1 | 1 | **1** |

Flat at 9. But the **composition** changed, and that is the useful signal.

## The code has one defect. The document has the rest.

**One finding is about the checker, and it is real — confirmed by running it.**

**F3 — the placement rule fails open when its terminator moves.** The scan finds the unique
`### 2.1` anchor but never validates the numbered heading that ends the range. Rename `### 2.2`
to something unnumbered and `intpl` stays true until `### 2.3`, so a canonical line sitting in
the *2.2* section counts as inside the template and the checker exits 0. **Verified:** renaming
that heading and planting the line in the resulting gap left the battery green. This is exactly
the anchor-drift class the amendment promised would fail loudly, and the second amendment's own
"holds no state across lines" (F9) is a false description of an `awk` that carries `intpl`
between lines.

**One is a measured number I let go stale.** F4: deleting the 4c block now flips **16**, not
the recorded 13 — 15 reject fixtures plus the parser case. I measured 13, then added six
placement fixtures (three of them rejects) and never re-measured. That is documenting an
unverified result, the Don't this repository names, in the block whose entire purpose is to
carry measured evidence.

**Two are Task 0, which I invented at pass 5 and got wrong twice over.**

- **F1 (blocker):** Task 0 commits the spec, plan and scripts immediately before the WIP
  snapshot — so that commit becomes the WIP parent, and a range `baseSha..HEAD` **excludes
  baseSha itself**. Gate B would exclude the very artifacts Task 0 exists to include.
- **F2:** it is a **non-WIP commit of executable code** with the battery deliberately red and
  no Gate-B loop. §5 requires tests green and Gate B before a non-prose commit, and the hook
  reads a non-WIP commit as a cycle close.

**The correct fix for pass 5's finding was one line, not a task:** put the spec, plan and both
scripts **into the WIP snapshot**, with `baseSha` = `c0a6ed2`. Task 0 should not exist.

**The remaining four are documentation drift** — the self-review still describes the
pre-amendment checker (`severity_rule_count(file, mode)`, the `NOSTART`/`MULTIEND` sentinels,
the `sev-region-parser` marker, `CANON`), the file inventory says 15 `sev_case` cases where the
tree has 21, Task 4 Step 4 reopens a settled backlog decision with a rationale that is also
wrong (Task 1 *does* touch the acceptance rules), and Task 0's commit command omits the body it
requires.

## What this says

The **checker converged**: built, run, 145 assertions under `sh` and `dash`, one defect left,
and that defect was found by executing it rather than reading it — as were the two before it.

The **plan document has not**, because it narrates code that keeps changing, and every change
leaves stale sentences behind. Six passes have not fixed that, and a seventh describing a
seventh version of the checker is not obviously different from the sixth.

## Status

Surfaced, not closed. Nothing applied from pass 6. The plan, the twice-amended spec, and the
built checker and suite are all uncommitted in the working tree; `c0a6ed2` is the only commit.
The battery is red by design — 4c fires because the canonical line is not yet in either prompt
copy.
