# Gate A — spec — pass 8 dispositions (salvage cycle) — **TERMINATION ASSESSMENT**

17 findings (0 BLOCKER, 10 MAJOR, 7 MINOR). **None dismissed. None applied** — Daniel's
pre-set condition fired: *"if pass 8 still oscillates on fix-of-fix findings with the Ref
surface gone, stop for a termination assessment instead of a pass 9."*

## The data

| Pass | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 |
|---|---|---|---|---|---|---|---|---|
| Findings | 15 | 25 | 23 | 20 | 16 | 12 | 16 | 17 |
| Blockers | 3 | 2 | 5 | 4 | **0** | **0** | **0** | **0** |

144 findings this cycle; 447 across the story's four cycles and seventeen passes.

**Two things are true at once, and both matter.**

**Blockers are genuinely gone — four consecutive passes.** Nothing in passes 5–8 says the
mechanism is unsafe, unbuildable, or a gate waiver in disguise. That is a real difference from
the tier-3 cycle, which died on blockers that said exactly those things. The *shipped
behaviour* has been stable and sound since pass 5.

**The finding rate is flat at ~15/pass and has not converged for four passes.** Cutting the
drift record helped (20 → 16). Cutting `Ref:` did not: 16 → 17, and **six of the seventeen —
findings 2, 3, 4, 5, 6, 7 — are direct consequences of that cut**, including finding 2, which
correctly observes that "git identifies a record by its commit" is false under the design's own
rules: one commit may carry several records, and squash deliberately merges records from many
commits into one. So the justification for the cut was itself an overclaim.

## The diagnosis

**Where pass 8's findings actually live:**

| Area | Findings | Count |
|---|---|---|
| §2.4 record identity, carry, restoration | 2, 3, 4, 5, 6 | 5 |
| §3 rider (c)'s evidence-entry ordering algorithm | 7, 8, 16 | 3 |
| §5.3 the parity extract-and-diff procedure | 9, 10, 11 | 3 |
| §5.2 checker region detail | 13, 14 | 2 |
| §2.1 examples and placement | 1, 17 | 2 |
| §2.3 accounting | 12 | 1 |
| tier-2 story | 15 | 1 |

**Eleven of seventeen are in three sections — and those three sections specify procedures
nobody will mechanically execute.** §5.3 tells a person how to extract anchor-delimited
blocks from two files and normalize Markdown paragraphs before diffing; in practice a person
edits both copies and diffs them. §3's algorithm defines an ancestor relation over a squash
range to pick among evidence entries; §2.4 defines record identity, duplicate detection and
restoration matching. None of it is executed by any tool. All of it is prose specifying prose.

**What actually ships is about forty lines:** one exception paragraph, one placement
paragraph, one canonical severity line, one reader rule, one carry sentence, and one shell
assertion. The design is **654 lines**. The finding rate is the specification layer being
reviewed, not the change.

**Why both cuts behaved differently.** The drift record was a *requirement* — cutting it
removed obligations. `Ref:` was an *answer to a question the design had already asked*
("which record is this?"), so cutting it left the question standing and the answers dangling.
That is the general shape: this document keeps asking mechanical questions about an artifact
that is read by humans, and every answer generates its own findings.

## Options

**A — Cut the specification layer, keep the closure record and the shipped text.** §1 (which
has been stable for passes and is the story's actual deliverable), §2's shipped paragraphs
verbatim, §3's riders verbatim, §4's file list, §5's one assertion plus battery, §6's backlog.
Delete §5.3's procedure (→ "edit both copies, diff them, record that you did"), §2.4's
identity and carry algorithms (→ "copy the records across; nothing checks that you did"), and
§3's evidence-entry reduction (→ leave §5's existing carry rule alone). Roughly 654 → ~250
lines, and the eleven algorithm findings stop existing rather than being fixed. One confirming
pass.

**B — Keep passing.** Apply all 17, run pass 9. On four passes of evidence, expect ~15 more.

**C — Close on dispositions.** The pinned exit permits it. Several findings are real (1, 3,
12) and would ship into planning as known gaps.

**D — Ship only §1.** Drop the record form entirely; keep the closure record, which is the
finding the story was for. The riders (b) and (c) ship separately as the small prose changes
they always were.

## Status

Stopped for assessment, per instruction. Nothing applied from pass 8. Working tree holds the
post-pass-7 artifacts.
