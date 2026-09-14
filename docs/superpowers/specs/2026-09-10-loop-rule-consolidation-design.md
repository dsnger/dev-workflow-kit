# §5 loop-rule consolidation: one closure ordering — Design

**Date:** 2026-09-10 · **Status:** DRAFT — in Gate A, not yet approved
**Story:** `docs/superpowers/stories/2026-08-29-loop-rule-consolidation-story.md`
**Profile:** read from that header at every pass, never from here — it is the only writable
copy, and a value copied here would be a remembered value.

Prompt-only, in two mirrored copies — `CLAUDE.md` §5 (**C** below) and the inline template in
`plugins/dev-workflow/commands/workflow-init.md` (**W** below) — **plus seven reminder strings in
`plugins/dev-workflow/hooks/codex-gate.sh` and their exact-match expectations in
`plugins/dev-workflow/hooks/codex-gate.test.sh` — three `expected_ctx` and three `expected_msg`** (target text §F items
10–13 and 15–17, authorised 2026-09-13). **No hook behaviour changes**, and the hook strings have no mirror,
so they carry no parity obligation. Condition ids `a1`…`j4` are defined in
`docs/superpowers/specs/2026-09-10-loop-rule-consolidation-condition-inventory.md` beside this
file: 135 conditions quoted from `7c0d475`, so a reader can check an accounting rather than
take it.

**Narrowed twice on 2026-09-10, and §9 lists what moved.** First the record-durability subject
went to a successor story. Then the bookkeeping went to the plan: this spec was 785 lines of
which the design was 173, and **58% of it sat in four bookkeeping sections** — quoted OLD and NEW
text, per-condition dispositions, the parity divergence list, the verification substrings, 456
lines between them — which took roughly half the
findings of every Gate-A pass while describing work the plan performs against real files. **It
is moved, not dropped.** The plan is the carrier and each section below names what it owes.

---

## 1. Intent

**What ships.** One closure ordering, stated once in each copy, that says which exit *closes* a
cycle and which merely *suspend* it, in what order a pass is read so the ranking is executable
rather than asserted, what any set of suspensions at once does, and which of the four standing
duties participate in that ordering versus gate it as preconditions. With it: the answer to what
a severity demotion does to the loop-health counts, and the standing sentences the ordering
falsifies or leaves ambiguous if they are not edited at their source. **§4 lists the sites row by
row and claims no total over them**, a count over spans that merge and split being bookkeeping the
plan re-derives against the files. **The falsified standing sentences are a different count**
and **only the target text's §F states it**, which is why no number for them appears here — a
second copy of that count is what went stale four times, because those are individually enumerated sentences rather than
spans.

**What does not:** the pass floor and severity semantics, which the parent shipped and this spec
reads as given, and everything §9 lists as moved or parked.

**Why the record split, since a reader of the ordering will look for the record.** Gate-A spec
pass 10 tripped the two-tell threshold and satisfied all three conditions of the clearly-stuck
reading. Nine of that pass's twenty findings belonged to **one subject this story never set out
to answer** — whether a record survives a session, a commit amend, a squash, a rollback or a
moved checkout — while the ordering's own five were small. Daniel split that subject out; §9
says what went and where.

---

## 2. Settled inputs

The story's §4 table is the design's starting point and is not restated here; decisions are cited
as **D1**…**D8** at the rules they settle, and no claim is made that each appears individually. **D9**, **D9b**, **D9c** and **D10** stay settled and move to the
successor with the material they govern (§9). Two implementation facts the parent cycle
established are read as given: a pass's cleanliness is a fact about what that pass found and is
**never rewritten** — an answer changes whether the *cycle* may close; and the findings files
establish the **inventory** of findings, not their resolutions.

What the table does not settle, this spec decides in the section that uses it: the evaluation
order and the file set each predicate reads; the duties' classification; which stop each of the
scope stop's two triggers raises and what each answer does; what a clearly-stuck or two-tell
answer produces; and the raw-severity rule for the health measures. **The block's ownership
boundary is stated once, in the target text's §A opening, and is deliberately not restated here** —
two copies of it are what let them drift, which is pass 20 finding 3. What this spec records is the
decision behind it: the block defines no trigger and no severity rule of its own, and every closure
precondition **that has a source of its own** keeps its one definition there, changed **at that
source** where it had to change to agree with the ordering.

**The behaviour decisions of this change are recorded here and stated nowhere here.** Each rule's
words live in the target text; this section says **that** a decision was made, **who** made it,
**when**, and **what question it answered**. A second telling of the rule itself is what drifted at
§F and at the edit map, and it is not rebuilt.

| # | Decided | Question it answered | Stated in |
|---|---|---|---|
| 1 | 2026-09-12, Daniel | how a closure condition belonging to one gate can be stated cycle-generally without leaving the other gate unable to evaluate it (pass 26's Blocker) | target §A1, §A2, §A3 |
| 2 | 2026-09-12, Daniel | what a change to the assigned fix set does at closing time, no rule having existed anywhere (pass 26 finding 3) | target §B |
| 3 | 2026-09-13, Daniel | whether a reviewer repeating a claim the author has validly refuted can hold a cycle unclean indefinitely (pass 27's Blocker) | target §A1, with §C, §H and §H's unknown-start list for its reach |
| 4 | 2026-09-13, agent in scope | whether an eligible pass that cannot close may still reach a suspension, §D's two-tell stop being mandatory (pass 29 finding 1) | target §A1, §D |
| 5 | 2026-09-13, agent in scope | what a closing act that does not complete leaves behind, and what a failure nobody can repair produces (pass 30 finding 4, narrowed at pass 31, terminal state at pass 37) | target §A1 |
| 6 | 2026-09-14, Daniel | what an accept on one `full` Gate-B branch file and a decline on the other do to the assigned fix set, the two lines being distinct findings (pass 59 finding 7) | target §B, at the fix-set definition |

**Two were reached by narrowing rather than by adding**, recorded because the first attempt at each
was wider than its defect: decision 5 first claimed every condition stayed established and added a
branch, both withdrawn at pass 31; and the Gate-B tree-equality condition that decision 1 exposed
was cut from this delivery entirely on 2026-09-13.

**What that cut costs, stated rather than implied.** Content staged before the final review, or
staged by a hook during the commit, reaches the closing commit through neither review branch.
**This delivery does not close that gap**; the target text's §I records it as a later task. Gate B's
existing review, re-review and evidence duties are unchanged and are not a substitute, and the gate
hook is not one either — its fingerprint is advisory and compares its own inputs across its own
invocations. Faster convergence was the reason for the cut and was not guaranteed by it.

**One further gap is named and not closed** (§I carries it): a Gate-A closing act is written from
the effective index, so a staged edit to a review input **no source rule governs** is published by
the closing commit unchecked. Neither gate answers this after the cut, and the text states the
residual rather than inventing a rule.

---
## 3. Where the text is

**The §5 text this change ships is written out in full, as it will read, in
`docs/superpowers/specs/2026-09-10-loop-rule-consolidation-target-text.md`.** That file is the
artifact; this one is the decisions behind it.

**Why the split, and it is the pass-17 answer.** Until pass 17 this spec carried the ordering
block, a twenty-two row edit table, the source sentences and the rationales as **four parallel
descriptions of one change**, which had to agree with one another simultaneously — so a repair to
any one of them fell out of step with the other three, and a pass found the gap. Seventeen Gate-A
passes, a Blocker count flat at 1 for four of them, and three findings in pass 17 alone from one
mechanism: a standing sentence the block falsifies that the edit table did not name.

**What was wrong with the diagnosis that produced this, said because it was carried with force.**
The claim was that a spec *cannot* determine which sentences a change touches. That is too broad:
the standing text is on disk and greppable. What a spec cannot do is keep four descriptions of a
*future* text in agreement while all four are being revised. Writing the future text once removes
three of them, and the remaining enumeration question — whether every affected site was found —
is a sweep against real files, which §7 assigns to the plan and §I of the target text states as
an open residual rather than a closed claim.

**What this spec still owns**, and none of it is in the target text: the settled inputs it reads
(§2), the passage map (§5), parity (§6), verification (§7), the invariants touched (§8), and what
moved or is parked (§9).

**This is not a Gate-A close.** §5's clearly-stuck exit says surfacing closes nothing, credits no
pass as clean and leaves the findings open. Gate A stays open and re-aims at the target text with
pass 17's findings as its basis; the rules are not activated; Gate B reviews the implementation
diff later, and neither file is that diff.

---

## 4. The edits, by site

**No sentence is quoted here and no replacement is written here** — the target text carries every
one, in final form, grouped by passage. This table exists so the passage map in §5 has something
to point at and so a reader can see the shape of the change without reading the whole target text.

| Passage or site | What changes |
|---|---|
| the closure ordering | **new**, and it is section A of the target text |
| (a) the floor paragraphs | §H |
| (b) what a loop absorbs | §B |
| (c) recognizing clearly stuck | §C |
| (e) the five tells | §D |
| Mechanics · Severity | the resolve duty is scoped and gains its discharge rule; the handed-over question is replaced by its answer |
| every standing sentence this change falsifies | **enumerated once, in the target text's §F**, with its replacement text and its reason. **No row for any of them appears here** — a second enumeration beside §F went stale at five passes running, and the plan reads the list, the count and the replacements off §F |
| Mechanics, the one-contract paragraph | membership widened, with a semantic test a downstream reader can apply |
| (i) when these rules bind | §H |
| the Gate-A section and the gate-prompt template | the two senses of *clean* are separated; the cadence makes revision conditional; the broad-prompt instruction stops assuming the artifact is revised between passes, keeping its breadth demand |
| the profiles section, the lens paragraph | its unchanged-list is scoped to the lens sets |

**Two sentences are deliberately not edited**, named so nobody looks for them: the "Copy every
record into the squash body" sentence inside the human-exception block, and the "records every
cycle owes" list. This change ships no record.

**No total is claimed, here or in the target text.** A count over spans that merge and split
disagrees with its own table at the next revision, which is what pass 15 found. The plan counts
what it writes.

---

## 5. The passage map, and who carries the accounting

**The plan carries the kept / moved / replaced / dropped disposition for every one of the 135
conditions in the committed inventory**, per passage, **beside the edit it belongs to** — which
is the only place it can be checked against the file being changed. **Story acceptance criterion
5 is satisfied by that list, not by this section**, and nothing here is dropped by being absent
here. This table says what happens to each inventoried passage, so the map stays complete at ten.

| Passage | This change | Target text |
|---|---|---|
| (a) the floor paragraphs | edited — closure sentences trimmed to a pointer, the no-restating prohibition scoped, the per-pass fix command pointed at Mechanics | §H |
| (b) what a loop absorbs | edited — it owns both scope triggers and the assigned fix set. **What it now says is stated in the target text's §B and nowhere here**; the decisions behind the two additions are recorded in §2 as decision 2 (a set change costs a further pass, Daniel 2026-09-12) and at pass 27 finding 2 (an accept enters the set whatever its severity) | §B |
| (c) recognizing clearly stuck | edited — keeps its three-condition reading, stops carrying evaluation order; **its precedence sentence is split**, the operative clause moving into the block unchanged and capitalized there while the plateau rationale stays at this source (pass 26 finding 9, pass 27 finding 6); the third condition is widened here to admit a re-raised validated dismissal, and its reason is restated because the deadlock it named is now answered by the clean predicate | §C |
| (d) from pass 4 onward | **no longer edited.** The unavailable-history block moved to the successor with **D10** | — |
| (e) the five tells | edited — the threshold is read after clean completion, and a pointer says what its answer does | §D |
| (f) the two rules above do not compete | **unchanged.** "The two rules above" still names the absorb rule and the stuck reading; the block sits before both and adds no third rule between them | — |
| (g) Mechanics · Severity, the handed-over question | edited — the unsettled statement and its interim report-and-stop duty are replaced by the answer, in both copies, removing the one deliberate story-path divergence | §E |
| (h) recording a human exception | **edited; §F states which sentences change and how, and is the only place that does** | §F |
| (i) when these rules bind | edited — the strict-reading list is added to, not rewritten | §H |
| (j) the squash carry | **no longer edited.** It was to name the answer record, which moved; this change ships no record for it to carry | — |

**Three reversals are recorded here as history and not as rules**, because each was made in an
earlier revision of this spec and each contradicted something settled: membership was briefly
re-read when the answer arrived; the hold was briefly narrowed to scope stops; and `c18` was
briefly kept rather than replaced. **What each of those rules now says is in the target text's §A
and nowhere here** — an earlier version of this paragraph restated the current hold, cleanliness,
floor and suspension behaviour while presenting itself as accounting, which is two authorities for
one branch.

---

## 6. Parity

The two copies must agree on every rule this change ships: the block, the (g) replacement and
every edit in §4 are byte-identical in C and W. **The plan carries the divergence list** — which
pre-existing wording differences are deliberate and stay, which are not and are aligned — and
**performs the extraction and diff**, passage by passage, against the real files. One divergence
is decided here because it is a correctness call rather than a wording one: W's `b3` pointer
names "the severity rule" on the inventory's reasoning that W has no Mechanics section, which is
false, so W takes C's wording (`b3`, target text §B).

The same extraction runs a second check within each copy: that `b11` and `b13` as edited say what
the block cites them as saying, **comparing the complete predicates and not a shared phrase** —
including `b11`'s already-declined exception and `b13`'s already-answered qualification, in both
directions. A condition in the block and not in the source ships two triggers that disagree; one
in the source and not in the block means the block cites a rule it has not read.

---
## 7. Verification

**The mode is read from the story's header at execution**, never from here — the same rule this
spec's header states. What follows is what each level of that mode obliges.

**Battery.** The quality command in `AGENTS.md` § Commands runs once, green, at the Gate-B WIP
commit (`scripts/check-version-bump.sh main` needs the committed bump, §8).

**The check — what it must establish, and where it is built.** Every edit that changes a standing
meaning owes a **discriminating pair of counts**: one showing the new wording present, one
showing the old wording gone. Each half runs in **both copies** — and, for the seven hook
reminder strings of §F items 10–13 and 15–17, in the hook's **single** copy, which has no mirror and owes
no parity check; the hook suite's exact-match assertion is that edit's second observation — and
against **both** the working
tree and the parent tree, so every assertion is observed passing where the change exists and
failing where it does not. A one-sided presence check is not enough: a copy carrying the new
wording **and** the old one satisfies it, which is the two-instructions-that-disagree failure §4
exists to prevent. **An edit that only adds, replacing no wording, is checked by presence alone**, because there is
no old text whose absence could be counted; **which edits those are the plan classifies against the
real files**, an add-only edit being one whose site carries no wording the change removes. Neither
this section nor §4 classifies them: a list of item numbers here is the bookkeeping that has to be
re-derived whenever a span merges. **The plan builds each pair
against the real files and runs both directions there**, under two constraints: a counted
fragment must be **single-line in the file it is grepped from**, since one spanning a line break
makes `grep -F` count zero and read as a failure; and the new wording must therefore be
**installed unwrapped**.

**Why no fragment is named here, stated as a residual rather than repaired again.** Four
consecutive revisions of this spec listed them, and each list held at least one fragment that
could not do what it claimed: one preserved inside its own replacement, so its
old-wording-gone count could never reach zero; three quoted across their line wraps, so they
counted zero in a correct tree; one meaning-changing passage with no pair at all. The cause is
structural — an exact check for text that does not yet exist can only be guessed, and a wrong
guess reads as a failed check rather than a wrong one. **Nothing verifies that §4's list is
complete or that the plan's fragments discriminate.** The enumeration moved to where the text
exists; the completeness claim did not, because nothing supports it.

**The counterfactual splits, and stating it as one understates what is owed.** For the **ordering
and the two gate-closure paragraphs beside it** it is **ABSENT and is claimed as absent**: the
parent carries none of the three, so no old wording of them can be shown to disappear and presence
alone is the check. For **every replacement**
the parent carries the old wording and the change removes it, so each owes the
old-wording-gone half of its pair. **The obligation reaches every passage the target text marks
REPLACED, and no list of them is kept here** — a second enumeration beside the markers is the
bookkeeping that goes stale, which it did: the list this sentence used to carry omitted §G while
§G was marked REPLACED. **The plan reads the markers off the target text**, where the concrete
replacements live. **§F states the falsified standing sentences and their count**, and the plan reads
both off §F rather than from here; the count has moved at five passes and a copy of it here would
be stale again by the next. Nothing is
claimed as "contradictory" — the second of the two defects Gate B found in the `fic2` instrument.

**The named verification of the risk path** (story AC 4) is a **next-state table**, written in the
plan and quoted by the closing commit body. **Its claim is narrow and stated as such: it covers
answer-state transitions once the predicates producing them are established**, which is the first
`fic2` defect — a state's inputs must include every input the rule reads — answered by
restricting the claim rather than by widening the table. So the plan writes **separate named
checks** for what the table therefore does not establish: that a logical pass was validated
across every required branch file, and that **every closure condition the block states held at the
closing act**. That set is **not enumerated here** — an enumeration is how this section came to
name three of them while the block states more, which is pass 20 finding 4. **The plan reads the
set off the block and writes one check per condition**, and fails where the block states a
condition the plan has no check for. **No fixture per predicate is built**; that question is parked
in the story's §2 and is not reopened.

**That list is not exhaustive, and reading it as exhaustive is how the evidence entry would
overclaim.** Two further things the table does not establish, named because they are the ones a
reader would otherwise assume it covers: **how each predicate was derived** — the table takes a
row's predicates as given and checks the transition out of them, so a wrongly derived predicate
produces a row that passes; and **whether the enumerated rows cover every reachable combination**
of the clean, scope and health predicates — nothing enumerates that space, so a missing
combination is invisible rather than failing. Both stay unestablished here: closing either is the
parked fixture-per-predicate question, which this change does not reopen. **The evidence entry
states the table's claim at this width**, not wider.

**The oracle.** A row **fails** when its required answer does not produce a **distinct** resumable
or closed state — **the same stop returning with its reading unconsumed, that is, without an
intervening validated pass run after the answer** — or when it closes on anything other than the
route the block states. **The closure conditions are read from the block and not re-enumerated
here**: a re-enumeration is a second definition that drifts, and pass 15 found this list already
missing two of them. **Which route a row must enter closure by, and which conditions must hold when, are read from the
target text's §A and are not re-enumerated here** — an embedded copy can pass while disagreeing
with the text it is meant to check, which is how this list came to name three conditions while the
block stated more. Naming only the distinct-state half would pass
the exact no-progress defect AC 4 cites from the parent cycle. **What a health answer consumes, and when a later suspension of the same reading is new data
rather than a failed transition, are stated in the target text's §A and are read from there** — an
earlier wording of this section embedded that rule and an earlier one still contradicted it, which
is two authorities for one transition.

**Evidence entry**, in the closing commit body, names: the battery run; every pair the plan built
with its counts in each copy and each tree, and every presence check beside them; the §6 parity
diff and the `b11`/`b13` equivalence result; and the next-state table's location plus its row
count. **When it is revalidated is stated once, in the target text's §F**, and is not repeated here.

**One observability residual, stated because the lens set asks for it and nothing here answers
it.** A closing commit body records that a cycle closed and what its curve was; it records
**nothing about which exit the cycle took** — whether a scope stop, a clearly-stuck surface or
two tells ever suspended it, what was asked, or how it was answered. A reader of history cannot
audit that every suspension was answered before the cycle closed. Neither the evidence entry nor
the curve supplies this, and saying otherwise would be the overclaim `AGENTS.md` calls this
repo's most persistent defect. The transport that could carry it left with the record (§9), and
**no story has taken it** — naming one that has not is the same defect in a smaller place. An
**admitted gap of this change**: unowned, unguarded, open to whoever picks it up.

---
## 8. AGENTS.md invariants touched

- **Invariant 11 — `docs/prompt-standards.md`, all 12 items.** Most at risk: item 6, every
  constraint in the shipped block carrying its reason in the same sentence — **including the
  three exempted until pass 6**, which now carry theirs inline in the target text's §A: that no
  other pass outcome makes a cycle eligible to close, that a zero-finding pass is clean whatever
  the floor, and that decline is available only at a membership stop. The exemption was wrong twice over: item 6
  admits no "settled elsewhere" clause, and a scaffolded copy cannot reach the story the reasons
  were said to live in. The unknown-start clause carries its reason inline for the same reason.
  Then **item 8 (token-lean), which an earlier revision claimed on the wrong ground** — it said
  the block replaces closure sentences rather than adding beside them, while the block was in
  fact restating triggers, duties, preconditions and the severity answer that their own
  paragraphs still defined, which is two authorities per copy. The claim now rests on what the
  block does: **it owns the evaluation of a pass and what follows from it, as the target text's §A
  opening states that boundary** — not restated here, one statement of it being the point — and
  **cites** every other rule where that rule is defined, so each has one definition in the shipped
  text; **§4's site table is the check**. Then item 3 (the stop
  answer produces a named state, **parked**, with its own restart transition).
- **Don't: "Never replace a decision procedure without accounting for its old conditions."**
  Satisfied by the plan's per-condition disposition list against the committed inventory (§5),
  with this spec's passage map keeping the ten-passage set complete.
- **Don't: "Never rename or delete a doc section without grepping for references first."** The
  (g) sentence names the story path; the grep finds it at `CLAUDE.md:815` (the site itself)
  and in three artifacts of the parent cycle
  (`docs/superpowers/plans/2026-08-29-review-loop-economics-plan-a-rules.md:878`,
  `docs/superpowers/specs/2026-08-28-review-loop-economics-design.md:33`,
  `docs/superpowers/stories/2026-08-28-review-loop-economics-pass-floor-story.md:78`). All cite
  the story file, which continues to exist; none cites the sentence. Nothing breaks.
- **Invariant 12 — a plugin change requires a version bump.**
  `plugins/dev-workflow/commands/workflow-init.md` is under `plugins/`, so
  `plugins/dev-workflow/.claude-plugin/plugin.json` goes `0.11.0 → 0.12.0` with a
  `plugins/dev-workflow/CHANGELOG.md` entry: a minor bump, the template gaining a closure
  ordering, the edited or extended sentences §4 lists, and the seven hook reminder strings of
  §F items 10–13 and 15–17. The hook edits add no bump the template did not already require.
- **Invariant 4 / the hook.** `plugins/dev-workflow/hooks/codex-gate.sh` is edited in exactly
  seven `note` **strings** (§F items 10–13 and 15–17) and nowhere else: no control flow, no counter, no
  fingerprint computation, no routing, so the POSIX-`sh` and optional-`jq` obligations are not
  reached. `plugins/dev-workflow/hooks/codex-gate.test.sh` changes in all three of its
  `expected_ctx` exact-match expectations and all three `expected_msg` beside them — the Gate-B
  satisfied, stale-fingerprint and no-fingerprint messages, §F items 12, 16 and 15 — each replaced
  with the complete resulting text, **plus every other assertion, label or comment in that file
  that tests or names a replaced string, which the plan finds by sweeping rather than from a list
  here**. The §5 heading the hook greps (`Cross-Model Review`)
  does not move.

**Every path in this spec is written repository-relative and in full** — no ellipsis shorthand
and no bare basename. An abbreviated citation fails the path-existence check a review pass runs
mechanically, and five of them did.

---
## 9. Moved, out of scope, and parked

**Moved to `docs/superpowers/stories/2026-09-10-record-durability-story.md`** on Daniel's
decision of 2026-09-10, with the evidence in §1:

- the `Accepted:`/`Declined:` answer record, its form, transport, attribution, recording point
  and squash carry (**D9**), the sameness test by which a later pass recognises the same
  finding (**D9b**), and the unverified-assertion reading (**D9c**);
- the pass-4 report's unavailable-history block (**D10**) and the checkout-root condition that
  report grew;
- the rollback reading — **what an open cycle owes when a revert removes the rules it started
  under**. This change does not answer it and no longer claims to. An earlier revision said the
  activation paragraph already supplies the transition; that is wrong in a specific way. A revert
  of this change removes the ordering, the source edits **and the unknown-start list's suspension-binding
  extension together**, so the stricter reading such a cycle would fall back to is itself part of
  what the revert takes away, and it no longer mentions the suspensions that cycle is holding.
  What remains is the pre-change §5 — the loose ordering this story exists to replace — read by a
  cycle that started under a different one. **Whether that is enough is unanswered here and
  nothing is shipped for it**, since no record identifies the rule revision a cycle started
  under. An admitted residual, and the successor's question;
- the slot-discriminator dissolution deferred here by Plan C's Tasks 19 and 20;
- **the partial-adoption guard as it applied to the record.** It was built as a "closure-record
  contract" naming the record, with a marker on every mergeable hunk, and it leaves with the
  record it was named for.

**Moved to the plan** — the implementation artifact, not a story: the per-condition disposition
list for all 135 inventoried conditions (§5); the OLD and NEW text of every §4 edit with its
line ranges (§4); the parity divergence list and the extraction-and-diff (§6); and every
verification fragment with its counts (§7). Each is work this change still owes; none of it is
work a spec can do correctly, because all four are checked against files the plan edits.

**Partial adoption — answered by the one-contract paragraph (target text §G), and what that answer is worth.**
The set is mutually dependent, and **the membership rule is stated once, in the target text's §G,
and is deliberately not restated here** — a second telling of it is a second definition, which is
pass 21 finding 5. §G reads what a live rule **states** rather than what changing it would do, and
it reaches a wider set than the paragraph did before: previously only the nonce, the slots, the
provenance line, the curve, the carry rule and the unknown-start semantics. **An earlier revision
of this section named the members as a list of item numbers and the list was wrong**, and a later
one defined membership here by the edits the block cites or depends on — a test decidable only
against this repository's own spec. Both are why the
rule is stated and **the plan derives the membership against the real files**, where dependence is
decidable and the numbering does not exist.

**Stated as what it is.** That paragraph is **an instruction to the agent**, and **what it obliges
is stated in §G and not repeated here** — §G widens whom that sentence is about. It is not a guard and not a mechanical check, and this change builds neither —
**nothing detects a partial adoption**, and the stop happens only where an agent reads the
sentence and acts on it.

**What it therefore does not buy, said rather than implied.** A project that adopts the block
without adopting that paragraph is not reached at all, which is the partial-adoption case applied to the
rule against partial adoption; the existing paragraph has the same property and the widening neither
worsens nor repairs it. Nor does it detect a *silent* half-merge in a project that did adopt it —
it obliges a stop once someone notices, which is a different thing from noticing. **What it
removes is the narrower state this spec previously admitted**: that the coherence rule did not
name this material at all, so an agent reading the sentence and willing to act on it had nothing
to act on. Two earlier revisions got this wrong in opposite directions — one claimed the existing
rule already caught the block, and one assigned the guard to the successor story, whose scope is
record durability and **excludes the closure ordering by name**. Both named a mechanism that did
not exist; §G names a sentence that does, and claims only what that sentence does.

**Out of scope and parked**, unchanged:

- The pass-counter anomaly (`fic2` record).
- The CodeRabbit plan-metadata contradiction (`fic2` record).
- The fixture-per-predicate question (`fic2` record; story §2).
- Hook **behaviour** under `plugins/dev-workflow/hooks/` — control flow, counters, fingerprint
  computation, routing, event handling. The seven contradictory reminder strings and the three
  exact-match test expectations are in scope instead (§F items 10–13 and 15–17, story §Out of scope), and
  the Gate-B fingerprint overclaim in the same message stays parked here.
- `todos.md`: both-branches-misread-each-other; self-consuming-deletion (prompt-standards item
  11); the three bot findings in resolved plans.
