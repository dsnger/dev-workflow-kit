# Gate A — Plan A cycle — pass 5 dispositions

Advisory human note. Not a findings file; participates in no pass validation.

## Result

Artifact 895a94d (revision 5). VALID pass: terminator exact, 5 finding lines, 0 non-finding
lines. **0 BLOCKER · 4 MAJOR · 1 NIT = 4 Blocker/Major.**

Three Majors repaired in revision 6 (26e7885). **One routed as a contract question.**

## The three pass-report lines (owed from pass 4)

**1 — Trend.**

| pass | findings | Blockers | Majors | B+M |
|---|---|---|---|---|
| 1 | 21 | 7 | 10 | 17 |
| 2 | 16 | 6 | 8 | 14 |
| 3 | 16 | 6 | 7 | 13 |
| 4 | 7 | 0 | 3 | 3 |
| 5 | 5 | 0 | 4 | 4 |

Findings falling steadily. **Blockers at zero for two consecutive passes.** B+M ticked 3 → 4,
which is noise at this size and not a plateau: the four are a different set from pass 4's
three, and three of them are consequences of pass 4's repairs rather than survivals.

**2 — Cluster.** Product behaviour, entirely. **Zero instrument findings for the second pass
running.** Every finding concerns the prose that will ship into `CLAUDE.md` §5 and the
template. That is the strip working: passes 1-3 spent 92% of their Blocker/Major budget on
the plan's own checks; passes 4-5 spent none.

**3 — require↔withdraw.** **None.** Nothing in pass 5 demands what an earlier pass removed.
The closest candidate is not one: pass 4 required a precedence rule between demotion and the
tells, and pass 5 narrowed it — that is refinement of an accepted requirement, not a reversal.

**Tells present: none.** Findings falling, Blockers zero, clustering on product behaviour,
no require↔withdraw pair. This is a converging loop.

## Repaired — absorbed under §5's absorb rule

All three correct a pass-4 fix and stay inside the assigned fix set, so they belong in this
loop rather than being handed back.

- **M2** — the clean-completion precedence was broader than the collision it repaired. "A
  Blocker/Major-free pass at or above the floor closes" would have let the new rule bypass
  §5's untouched scope stops, which fire when a finding leaves the assigned fix set or opens
  a new structural question **at any severity**. Now limited explicitly to the two-tell stop,
  and it says outright that it overrides nothing else.
- **M3** — "demotion does not change what the tells observe" was wrong in one direction, and
  the reviewer found the direction. Demoting a Blocker to Minor **does** remove it from the
  Blocker curve; that is what demoting is for. Stated per tell now: total, clusters and
  require↔withdraw see every reported finding; the Blocker curve reads severity after the
  ceiling.
- **M4** — the partial-adoption trigger named three spellings and missed the ones a partial
  merge happens to leave. Three further sites carry a fixed-three claim — the Gate-A loop
  description, the pass-1 closure rule, the re-review rationale — and a merge can take some
  tasks and not others. The trigger is semantic now, not a list.

## Routed — a contract question, and it stops the loop

**M1.** Pass-4 M3 found that spec §2's promise is undefined across an ordinary profile edit
between cycles. Revision 5 answered by weakening it to a per-cycle derivation. Pass 5 shows
that contradicts the approved spec, which reads:

> **One derived value governs the Gate-A spec loop, the Gate-A plan loop and the Gate-B
> cycle.** Not because they are one cycle — §5 is explicit that they are **three separate
> cycles** — but because they derive from **the same cited-story set**.

Verified against revision 36 directly. The spec says one **value**; revision 5 shipped one
**derivation**. Those are different cross-cycle contracts, and the story's criterion tracks
the spec's wording.

**Why this stops the loop rather than being absorbed:** §5 — "When a finding is both — it
corrects the last correction *and* opens a new structural or contract question — the new
question wins and the loop stops." Absorbing it would settle a contract by drafting, which
is the failure mode that rule exists to prevent. Two answers are available and neither is an
agent's to pick: define the shared snapshot the spec promises, or revise the spec and the
story criterion to approve per-cycle derivation.

Task 1 now carries a note that its between-cycle sentence is awaiting that decision and must
not be executed until resolved.

## Collected, not iterated

**NIT** — the plan's stated test for the re-review sentence, "delete the hook and the
sentence is still true", is literally false of the sentence's trailing clause ("The hook
merely notices, at commit time"), which describes the hook and cannot outlive it. The
load-bearing half does survive the test. The task note now says which half the test applies
to. Collected under §5; a Nit never earns a repair round, and this one got a wording
adjustment only because the note was being rewritten anyway.

## M1 resolved as (C), current-header-governs — verified before encoding

Neither of the two options I routed. A third reading was returned and I was asked to verify
it textually before encoding it. **It verifies**, and the verification changed what I think
the original finding was.

**Quoted from revision 36 and from `CLAUDE.md`, checked one at a time:**

1. §2 — *"**One derived value governs the Gate-A spec loop, the Gate-A plan loop and the
   Gate-B cycle.** Not because they are one cycle — §5 is explicit that they are **three
   separate cycles** — but because they derive from **the same cited-story set**."*
   This argues from the **source**, never from time. "One value at any moment because one
   source" satisfies it; nothing in it freezes a number.
2. §2.4 — *"The floor derives from the **current** profile at each pass."* Directly supports
   current-header-governs and directly contradicts a snapshot.
3. §2.4 — *"**These are pass-count rules, so they apply while §5 says a gate is running** and
   are silent otherwise. What §5 says about when a gate runs — **including how a moving
   profile or cited set bears on that** — is §5's, unchanged and deliberately not summarised
   here."* The spec **delegates** the between-cycle case rather than leaving it open.
4. `CLAUDE.md:387-389` — *"The **story header is the single writable copy** … read the values
   fresh at each pass, **never a remembered or copied value**."* Option (A)'s snapshot
   violates this in those words. (C) satisfies it.

**No sentence contradicts (C).** Encoded in Task 1, plan-only, citing §2's sentence.

**What the verification changed.** Pass-4 M3's premise — that no rule handles a between-cycle
change — was **partly wrong**, and so was my acceptance of it. §2.4 quote 3 shows the spec
deliberately routed that question to §5, which answers it by reading fresh. I treated a
delegation as a gap and invented an answer, and the invented answer then contradicted §2.
The lesson is narrower than "verify findings": **a finding that says "no rule covers X" needs
the same check as a finding that says "rule Y is wrong" — that no rule covers it.**

**One correction to the routed reading:** it cited "§2.4/§4.2". **There is no §4.2.** §4 is
"The per-pass curve — required properties" and has no subsections. All the supporting text is
in §2.4. The substance is unaffected; the citation is not.

**Why (A) was wrong in a way worth keeping:** it fails invariant 2's firing direction. Under a
snapshot, a human-confirmed **raise** between cycles would leave in-flight work reviewed under
the weaker profile — the under-review direction, which is the one this repo treats as
dangerous. I recommended (A) and missed that.
