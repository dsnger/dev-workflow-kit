# Gate A (spec) — dark-factory vision — pass 3 dispositions
32 findings: 2 BLOCKER, 22 MAJOR, 8 MINOR. Unprofiled run.

## STATUS: loop stopped and surfaced. Nothing fixed in this pass.
Two of CLAUDE.md §5's five tells are present, which makes stop-and-surface
mandatory rather than discretionary. The findings stay OPEN, no pass is
credited clean, the floor and the clean-final-pass rule still stand, and the
loop resumes on whatever the human decides. This is not an exit from the gate.

## The three lines (CLAUDE.md §5, pass-4-onward reporting, applied early)
1. TREND — pass 1: 52 findings, 2 Blocker, 41 Blocker+Major.
   pass 2: 34 findings, 1 Blocker, 26 Blocker+Major.
   pass 3: 32 findings, 2 Blocker, 24 Blocker+Major.
2. CLUSTER — three groups. (a) Ownership of the decomposition: 11 of the 24
   Blocker/Major say no §7 leaf owns something the document names elsewhere
   (Bewertungs-Loop runtime, the judge, the vet preflight, the dry-run
   implementation, reviewer-availability detection, the as-built view,
   given/when/then). Seven of those eleven are consequences of the five
   stations pass 2 added. (b) Claims checked against shipped kit behaviour:
   process-pr-review, pr-review-bots.md, the P8 story, the hardening ledger —
   genuinely new coverage, not regeneration. (c) Merge-queue edge states.
3. REQUIRE-WITHDRAW — one pair. Pass 2's blocker fix said "halt automatic
   merge or force every candidate through a human audit". That was
   implemented. Pass 3's blocker says the human-audit half is a
   human-authorized zero-pass closure, which the cited fallback record rejects
   and §1's own override rule forbids.

## The tells
PRESENT: the Blocker count failed to fall (2 -> 1 -> 2).
PRESENT: one require-withdraw pair.
NOT PRESENT: findings rising (52 -> 34 -> 32, falling but flattening);
clustering on a test instrument (no instrument in this artifact).
UNCLEAR: clustering on prose about the decomposition rather than the
decomposition itself — arguable, since ownership assignment IS this
document's product.

## The mechanism worth naming
The document grew 416 -> 442 -> 564 -> 680 lines across the three passes. Each
round's fix adds prose; added prose names mechanisms; named mechanisms need
owners; missing owners are the next round's findings. That is CLAUDE.md §5's
sizing guidance made visible — "prefer smaller specs with named interfaces and
let the plan carry the detail". Roughly half of pass 3 is that self-generated
surface; the other half is Codex reaching shipped files it had not checked
before, which is real coverage and argues against calling this a plateau.

## Open, nothing acted on
BLOCKER: p3-1 (reviewer outage vs a sanctioned zero-pass closure),
p3-11 (a clock loop graduating to fix permission bypasses classification and
Freigabe — decisions 4, 6, 7).
MAJOR: p3-2..p3-9, p3-12, p3-13, p3-15, p3-18, p3-20..p3-25, p3-28..p3-31.
MINOR: eight, uncollected.
