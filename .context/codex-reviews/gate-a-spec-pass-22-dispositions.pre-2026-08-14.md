# Gate A — spec — pass 22 dispositions

Artifact: `docs/superpowers/specs/2026-08-05-hardening-ledger-supersession-design.md`.
5 findings: 3 Major, 2 Minor. **No Blocker.** All five valid (finding 1 in part).
**All five applied.**

Reviewer: `mcp-codex-dev@1.0.1`, `codex-cli 0.144.5`, model `gpt-5.6-sol`. Pass file valid:
6 lines, 5 finding lines, terminator exact, no stray artifact.

Passes 4 → 22: **11, 14, 16, 15, 9, 10, 5, 12, 8, 6, 3, 4, 7, 6, 6, 5, 6, 7, 5.**

## The class changed, and that is the finding about the pass

**No mechanism defect. No unhandled path. No invariant risk.** Narrowing 1d removed the generator:
passes 20 and 21 spent thirteen findings on machinery added at 19–20, and with that machinery gone
this pass found none in its place. What it found instead is four claims-about-the-design that are
not exactly true, plus one scope reduction. Rider 4 came back with an **over**-coverage finding
rather than a missing distinction — the first time in the cycle it has run that direction.

## Verdicts

| # | Sev | Verdict | Applied as |
|---|---|---|---|
| 1 | Major | **Valid in part.** The evaluation point was unstated, so check 3's "exactly one position" read as a standing property, and a duplicate arriving by a later merge looked like a permanent failure with no repair. It over-reads in one respect: §6's checks run **once**, on this change, before any merge involving it, so no state can "permanently fail" them. The duplication premise is also weaker than stated — §8 records that identical label lines **coalesced** under the configured driver in a scratch reproduction. | Check 3's cardinality oracle now names its evaluation point and points at §2.2's keep-one-label repair and §8's no-standing-check record. |
| 2 | Major | **Valid, and introduced by pass 21's own fix.** §2.2 claimed "Prose only — no machine-readable fields" while §6 requires exact field splitting, calendar parsing and a `·`-delimited grammar — and pass 21's fix *shipped* a format constraint (` · ` forbidden inside a field) into every scaffolded ledger. The decision being made is about **standing consumers**, not about whether a line can be parsed. | §2.2's Format paragraph rewritten: no standing consumer parses an entry; §6's one-time checks parse a **validation-only grammar** that binds this change and nothing after it. What is refused is designing an input format for a reader that does not exist yet. |
| 3 | Major | **Valid.** 1d now concerns one fragmentless entry and treats one match and many alike, yet its oracle still demanded a general optional-fragment matcher with escape, markup and case fixtures — driving exactly the generalized parser §2.2 declines to justify. | The matching oracle narrowed to the two load-bearing distinctions: **zero from at-least-one** (the many fixture stays — it is what stops a checker implementing the withdrawn exactly-one rule) and the **on-or-before boundary**. Fragment-narrowed matching and the comparison domain are named as *not validated by this change* and recorded in §8. |
| 4 | Minor | **Valid — the AGENTS.md decision-procedure Don't, exactly.** Removing the alignment oracle at pass 21 removed with it the exact-prefix condition, which had also asserted that base entries survive unedited and in order. The §8 record covered the inert-successor coverage and not this. | 1d gained an explicit **old-condition accounting** naming all three dropped requirements, marking the prefix rule as the non-obvious one; §8 records that no check validates pre-existing entry immutability. |
| 5 | Minor | **Valid.** "For this change the state is unreachable — it appends exactly one entry" is circular: it is unreachable only if the implementation conforms, which is what a check exists to stop assuming. | Replaced with "outside the prescribed change, but a nonconforming implementation can produce it and every stated check will accept it", and the circularity named. |

## Sweep after applying

35 anchors, each exactly once in the convention prose, none a substring of another, no padding
asymmetry; six fence lines, balanced; both count claims read thirty-five; 1d declares seven oracles
and has seven.

## Termination assessment — the rule fires

Daniel's rule: *non-clean with only claim-sharpening → termination assessment, no pass 23 by
momentum.* Findings 1, 2, 4 and 5 are claim-sharpening by his definition — an evaluation point left
unstated, a design claim that outran what the design does, an unrecorded dropped condition, a
circular word. Finding 3 is not a defect at all; it **removes** required work. That is the trigger,
read honestly.

Trend by severity, not just count: **18** 4 Major · **19** 4 Major · **20** 6 Major · **21** 6 Major
· **22** 3 Major, and none of the three a mechanism defect. The 20–21 spike was self-inflicted and
is now removed at the root.

**Against closing immediately:** five fixes were applied after this pass, so the revision now on
disk has not been reviewed by anything. §5 requires the final pass to be clean. A single confirming
pass 23 is what the pinned exit's own condition asks for — not momentum, since the recommendation is
to close on it whether it comes back clean **or** dispositions-only, and to stop either way.
