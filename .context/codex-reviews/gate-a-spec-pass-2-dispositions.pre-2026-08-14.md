# Gate A — spec — pass 2 dispositions

Artifact: `docs/superpowers/specs/2026-08-05-hardening-ledger-supersession-design.md`
11 findings: 2 Blocker, 6 Major, 3 Minor. All eleven validated as correct; all eleven applied.

| # | Verdict | Reason |
|---|---|---|
| 1 | **Applied** | Correct, and the one pass 1 could not see because pass 1's spec said the existing paragraph was *kept*. `Never edit a row` left absolute contradicts §2.1's in-place amend, on the same surface — item 7. New §2.0 amends the phrase to `Never edit a landed row`. |
| 2 | **Applied** | Correct. §2.2's shared prose opened with `**Superseded rows.**`, which is also the block's label — so an empty scaffold shipped the label and the repo would carry two. Prose relabelled `**Correcting a landed row.**`; `**Superseded rows:**` now belongs to the block alone. |
| 3 | **Applied** | Correct, twice over. The decidability sentence said absence at the base proves landed — backwards. And presence/absence is not symmetric: a row can arrive from another cycle by merge after the base. Rewritten as a one-way test that only ever confirms landed. |
| 4 | **Applied** | Correct: "the cycle now open" was undefined. §2.1 now names cycle identity (the Gate-B cycle of §5 Mechanics), its close event (the commit replacing the `WIP:` snapshot), the no-open-cycle state (everything is landed), and concurrency (another worktree's open cycle is landed to you). |
| 5 | **Applied** | Correct and the sharpest finding of the pass: the entry restated 0.8.0's counting rules, which is the exact artifact shape that goes stale — and would have made the first entry the next thing needing supersession. Entry now names only what stopped holding and cites. Added as a standing clause in §2.2, not just fixed in place. |
| 6 | **Applied** | Correct gap introduced by pass 1's own fix. Entry-correction had no locator, shape or precedence. An entry is now located by its date plus the row it supersedes; a correcting entry retires exactly what it names and states what now holds, so nothing is restored implicitly. |
| 7 | **Applied** | Correct and subtle. Check 2 normalized whitespace, which would erase the four-space indent that is the only thing separating the format example from a live entry — the check could pass on a surface that had converted the example into entry-shaped content. Normalization now covers hard-wrap joins only; indentation compared exactly. |
| 8 | **Applied** | Correct: the greps establish cardinality, not content, so AC 4 could fail with green evidence. Check 1 split into a mechanical half and a named read, with §9 stating plainly that the content half is a human read nothing validates. |
| 9 | **Applied** | Correct — verified independently: `CLAUDE.md` has two paragraphs opening "What this does not do" (lines 168 and 390). The entry now carries a unique opening fragment. |
| 10 | **Applied** | Correct: "through the end of §2.2's prose paragraph" is not locatable in the target files, which carry no §2.2 marker. §4 now names two unique line sentinels, inclusive, and states that the indented example is inside the region. |
| 11 | **Applied** | Correct. The prohibition is *kept* — the replacement still states it — and only the *definition* of landed moves. The table said "moved", which obscured that the prohibition now sits on two surfaces. Corrected, and the duplication is named in §5 and again in §9. |
