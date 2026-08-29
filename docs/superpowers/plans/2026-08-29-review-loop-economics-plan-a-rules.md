# Plan A — the rules edits (floor predicate + severity semantics)

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development
> (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use
> checkbox (`- [ ]`) syntax for tracking.

**Goal:** Ship parts 1 and 2 of the review-loop-economics change into both prompt copies — the
pass floor becomes a function of the cited story's profile, and finding severity is decided by
whether something in the system takes a different decision.

**Architecture:** Two mirrored prose edits, site by site: `CLAUDE.md` §5 and the inline template in
`/workflow-init`. **No code.** No file under `plugins/dev-workflow/hooks/` changes.

**Tech Stack:** Markdown prompts; POSIX shell for every check; `git` for the records.

**Spec:** `docs/superpowers/specs/2026-08-28-review-loop-economics-design.md` (revision 36, Gate A
closed clean at pass 34). **Read it alongside this plan.** Plan A implements §2, §2.1, §2.2, §2.4,
§3, and §10 in part.

**Story:** `docs/superpowers/stories/2026-08-28-review-loop-economics-pass-floor-story.md`

> **Read the profile from that header at execution time. This plan states no risk value, no
> security value, no validation mode and no pass count derived from any of them.** §5 makes the
> story header the single writable copy; a value copied here goes stale the moment the profile
> moves, and a stale floor is this change's own central failure mode. Revision 1 of this plan
> promised exactly that and then wrote the story's risk value, its validation mode, and a pass
> count derived from them into its own prose — finding B1. They are not repeated here, not even
> to name the mistake: quoting a stale-able value to explain why values go stale reintroduces it.

---

## Why this is one of three plans

The single 748-line plan this replaces opened **31 Blocker/Major at Gate-A pass 1** (`5c00f8c`).
Twelve of those findings were one shape — the plan gestured at settled spec content instead of
shipping it — and the artifact was already too long while still needing to grow. Plan A revision 1
then opened **17** (`3b94dbf`), with Blockers falling 21 → 7.

| Plan | Ships | Spec sections |
|---|---|---|
| **A — this one** | the floor predicate and the severity test, site by site in both copies | §2, §2.1, §2.2, §2.4, §3, §10 (partial) |
| **B** | the provenance line, the per-pass curve, the cycle nonce, slot naming | §2.3, §4, §5, §6 |
| **C** | rollout: the falsified user-facing sentences, packaging, the evidence pack | §7, §8 |

**Three Gate-A cycles, ONE Gate-B cycle.** Each plan is reviewed as its own artifact — that is
where the finding curve actually moved — but the three ship **one diff**, so the diff is reviewed
once, after Plan C. §5's own architecture already works this way: Gate A is per-artifact and Gate B
is per-diff.

Revision 1 tried to give Plan A its own Gate-B cycle and two Blockers fell straight out of it: the
battery could not go green because the manifest bump is Plan C's (B4), and the findings slots
needed a discriminator whose grammar is Plan B's (B5). **Each plan's own cycle needed
infrastructure a later plan ships.** Splitting the review of one diff was never coherent.

**Execution order A → B → C. Plan B may not open before Plan A's Gate-A loop closes.**

### Where pass 1's findings went

Every finding from `.context/codex-reviews/gate-a-plan-rle-pass-1.md` (the 748-line plan) and
`.context/codex-reviews/gate-a-plan-plana-pass-1.md` (this plan, revision 1) is assigned to exactly
one plan, so nothing falls between three documents.

| From | Finding | Owner | Resolution |
|---|---|---|---|
| rle | B1 conditions artifact circular · B2 passage set unsound | **A** | the accounting is a *section of this plan*, derived from the edits this plan makes, reviewed by this plan's Gate-A cycle. No second artifact — see finding M2 below |
| rle | B3 pass-report unedited · B4 replacement range · B5 gate-off list · B6 §2.4 · B7 §10 · B8 sequence values | **A** | Tasks 1-5 |
| rle | B9-B13 records/nonce/slots · M6 nonce diagnostics | **B** | |
| rle | B17 · B19 · B21 · M8 · M10 · MINOR 11 | **C** | |
| rle | B14-B16, B18, B20 commit topology | **A**, restated in B and C | resolved below; one WIP, one loop after C |
| rle | M1 rows per copy · M2 profile values · M3 ellipses · M4 false rationale · M5 "unchanged" · M7 parity schema · M9 rerun safety | **A** | |
| plana | B1 profile values copied | **A** | header above; no derived pass count anywhere |
| plana | B2 eleventh passage missing | **A** | the accounting has **eleven** passages |
| plana | B3 line numbers shift under earlier tasks | **A** | **every executable step addresses by content, never by line number** |
| plana | B4 battery cannot go green · B5 illegal slot names | **A** | dissolved by the one-Gate-B-cycle topology |
| plana | B6 evidence not revalidated | **C** | the evidence pack belongs to the combined close |
| plana | B7 cycle runs under old rules | **A**, restated in B and C | Global Constraints below |
| plana | M1 pass-report passage differs · M3 preflight states · M4 baseline · M5 "profile alone" · M6 causal claim · M7 parity script · M8 recovery · M9 knob bytes · M10 `git add -u` | **A** | |
| plana | 4 MINOR | **A** | Task 6 Step 3 proof, `mktemp`, hook-state qualification, self-review claim |

---

## Global Constraints

Verbatim from the spec. Every task's requirements implicitly include these.

- **This Gate-B cycle runs under the rules in force at its start — the OLD ones.** The new
  severity semantics, the new floor rule and the new record forms bind only **after** the closing
  commit ships them. This is spec §10's activation rule applied to the change's own review: a
  reviewer applying the new Minor-or-below ceiling to the change that introduces it would
  under-iterate on exactly the diff that needs the most iteration. **Carry this sentence in the
  `additionalContext` of every Gate-B call** (finding plana-B7).
- **Prompt-only.** No file under `plugins/dev-workflow/hooks/` changes, and
  **`.context/codex-gate.floor` is never written, never removed and never read for the
  derivation.** Note what this does *not* claim: the Gate-B calls and commit events in this work
  will write pass counters, fingerprints and disclosure markers under `.context/` as they always
  do. Only the floor knob is untouched (finding plana-MINOR 13, which read revision 1's blanket
  "no hook state file is written" as false — it was).
- **The §5 heading must keep matching `^#{1,6}[[:space:]]+([0-9]+\.)?[[:space:]]*Cross-Model Review`.**
  `codex-gate.sh:94` greps `CLAUDE.md` for it to build every reminder's citation.
- **Every rule lands in BOTH copies**, except where a difference is deliberate and stated.
- **§5's other closure rules are never restated, only referred to.** Three spec revisions were
  spent on this: each summary of the triviality skip dropped a different condition.
- **Address by content, never by line number.** Line numbers appear below only as *provenance* —
  pasted `grep -n` output showing where a passage stood in the untouched tree. Every **executable**
  step locates its target by matching text, because Task 1 inserts two large blocks and shifts
  every line number after them. Revision 1 fixed the expected *values* for their point in the
  sequence and left the *addresses* at their untouched-tree positions (finding plana-B3).
- **Anchors are pasted `grep -n` output.** No editorial token ever appears inside a pasted block.

### The commit protocol

**One WIP commit, opened here, amended by Plans B and C, reviewed once after C, closed once.**

> **The `--no-edit` trap — this is why every amend below looks verbose.**
> `plugins/dev-workflow/hooks/codex-gate.sh:763` is
> `is_wip_commit() { printf '%s' "$1" | grep -Eiq -- "-m[[:space:]]*['\"]?[[:space:]]*wip"; }`
> It matches **the Bash command string**, not git state and not the commit message. So
> `git commit --amend --no-edit` carries no `-m`, is **not** recognized as a WIP commit, and at
> `:886` the hook resets — **discarding the cycle's accumulated passes.** Every amend below
> therefore restates `-m "WIP: ..."` in full. **Never `--no-edit` inside the cycle.**
>
> That the shipped rules do not warn about this is a real defect; it is on the backlog. **Do not
> fix the hook here.**

1. **No ordinary commit happens from Task 1 onward** until the combined cycle closes in Plan C.
   Plan A needs none: the accounting lives in this document, which is already committed.
2. **Task 1 opens the cycle**: `git commit -m "WIP: review-loop economics"`.
3. **Tasks 2-6 amend it**, each restating that exact message.
4. **Plans B and C amend the same commit.** Plan C adds the manifest bump, runs the single Gate-B
   loop, and closes with `git commit --amend -m "<real message>"`.

**The subject is `WIP: review-loop economics` — not plan-specific**, because all three plans amend
one commit.

---

## File Structure

| File | Responsibility | Gate B |
|---|---|---|
| this plan, § "Old-conditions accounting" | what the existing prose requires, per copy, dispositioned | N/A — reviewed by this plan's Gate-A cycle |
| `CLAUDE.md` §5 | the live rules | in the combined cycle, closed by Plan C |
| `plugins/dev-workflow/commands/workflow-init.md` §5 | the scaffolded mirror | in the combined cycle, closed by Plan C |

**There is no separate conditions artifact.** Revision 1 wrote the accounting here *and* copied it
to a second file *and* later mutated that copy with result tables — three records able to disagree,
where spec §6 asks for one (finding plana-M2). Task 6's results append to **this document**.

---

## Old-conditions accounting

**Derived from the edits this plan actually makes**, against §5 as it stands at HEAD — not imported
from an earlier spec revision. **Eleven passages.** Revision 1 listed ten and then edited an
eleventh in Task 3, which Task 7's out-of-inventory check would have rejected as a defect
(finding plana-B2).

**Rows are per copy where the copies differ.** Ten passages are byte-identical across both copies
over their whole block, so they carry one shared row each. **The pass-report passage is not** —
verified by `diff`, not by comparing its first line — so it carries two (finding plana-M1).

Provenance, pasted from `grep -n` — these are *addresses in the untouched tree*, not instructions:

```
CLAUDE.md:72:**Both gates are a LOOP with a HARD FLOOR: min 3 passes per run (Blocker/Major
CLAUDE.md:77:final pass must be clean — if pass 3 still finds Blocker/Major, keep going until
CLAUDE.md:79:below 3 is a pass with **zero** findings; don't manufacture findings to pad. Codex is
CLAUDE.md:126:the only exception, exactly as above; a Blocker/Major-free pass 1 carrying a Minor keeps
CLAUDE.md:133:**From pass 4 onward every pass report carries three lines.** The carrier is **your own
CLAUDE.md:236:act on the partial list, don't count it toward the 3-pass floor, and don't read "no
CLAUDE.md:300:- **Gate A — Spec, then plan (TWO runs, each its own 3-pass loop).** Run on the
CLAUDE.md:335:  invalidates the prior pass, which is where the 3 come from.
CLAUDE.md:403:Lenses are **different questions, not more passes.** The 3-pass floor, the Blocker/Major
CLAUDE.md:480:**Changing a profile:** the pass **proposes the complete resulting header** — both axes,
CLAUDE.md:495:- **Severity:** Blocker (wrong/unsafe/breaks invariant) · Major (design flaw →
```

```
plugins/dev-workflow/commands/workflow-init.md:272:**Both gates are a LOOP with a HARD FLOOR: min 3 passes per run (Blocker/Major
plugins/dev-workflow/commands/workflow-init.md:277:final pass must be clean — if pass 3 still finds Blocker/Major, keep going until
plugins/dev-workflow/commands/workflow-init.md:279:below 3 is a pass with **zero** findings; don't manufacture findings to pad. Codex is
plugins/dev-workflow/commands/workflow-init.md:322:the only exception, exactly as above; a Blocker/Major-free pass 1 carrying a Minor keeps
plugins/dev-workflow/commands/workflow-init.md:330:**From pass 4 onward every pass report carries three lines.** The carrier is **your own
plugins/dev-workflow/commands/workflow-init.md:421:act on the partial list, don't count it toward the 3-pass floor, and don't read "no
plugins/dev-workflow/commands/workflow-init.md:485:- **Gate A — Spec, then plan (TWO runs, each its own 3-pass loop).** Run on the
plugins/dev-workflow/commands/workflow-init.md:519:  invalidates the prior pass, which is where the 3 come from.
plugins/dev-workflow/commands/workflow-init.md:582:Lenses are **different questions, not more passes.** The 3-pass floor, the Blocker/Major
plugins/dev-workflow/commands/workflow-init.md:659:**Changing a profile:** the pass **proposes the complete resulting header** — both axes,
plugins/dev-workflow/commands/workflow-init.md:674:- **Severity:** Blocker (wrong/unsafe/breaks invariant) · Major (design flaw →
```

| # | Passage | Copy | What the existing prose requires | Disposition |
|---|---|---|---|---|
| 1 | floor paragraph | both | a. a hard floor of 3 passes per run · b. Blocker/Major only · c. the count is the hook's · d. a satisfied count is not a clean review · e. Gate A is instruction-backed · f. the hook resets at `writing-plans` · g. a TodoWrite per pass · h. fix Blocker/Major after each · i. Codex is advisory · j. validate before applying · k. dismissed finding → one-line why | a. **replaced** by the derived predicate (Task 1) · c. **moved** — the hook still counts, as its reminder threshold, not the obligation · b, d-k **kept verbatim** |
| 2 | `if pass 3 still` | both | the final pass must be clean; if the pass at 3 still finds Blocker/Major, keep going until clean or clearly stuck, then STOP and surface | **kept**, `pass 3` → `the pass at the floor` (Task 2) |
| 3 | `below 3` | both | the only early exit below the floor is a zero-finding pass; don't pad | **kept**, `below 3` → `below the floor` (Task 2) |
| 4 | pass-1 Minor sentence | both | inside the "clearly stuck" rule: below the floor nothing closes; a zero-finding pass is the only exception; a Blocker/Major-free pass 1 carrying a Minor keeps looping | **kept**, `pass 1` → `pass **below the floor**` (Task 2 Step 4). **This is the sentence that inverts at floor 1**, where pass 1 *is* the floor |
| 5a | pass-report paragraph | `CLAUDE.md` | a. from pass 4 onward, three lines · b. the carrier is your own status report · c. never the Codex reply · d. never the findings file · e. trend · f. cluster · g. require↔withdraw · **h. "you report the tells"** — second person, addressee named | a. **kept and extended** — the three lines still start at pass 4; §2.2's three fields are owed by **every** pass (Task 3) · b-h **kept verbatim, including the second person** |
| 5b | pass-report paragraph | template | a-g as above · **h′. "report the tells"** — imperative, no addressee · plus different line wrapping | same disposition; **the divergence is pre-existing and is left alone.** Task 3 inserts a new paragraph *before* this one and modifies neither copy, so neither the wording nor the wrapping difference is touched |
| 6 | incomplete-pass | both | an incomplete pass is not a review: don't act on the partial list, don't count it toward the floor, don't read "no Blocker/Major visible" as clean | **kept**, `the 3-pass floor` → `the floor` (Task 2) |
| 7 | Gate A loop | both | Gate A is two runs, each its own 3-pass loop; one broad prompt; re-run each pass over the revised artifact | **kept**, `3-pass loop` → `loop at the derived floor` (Task 2) |
| 8 | `where the 3 come from` | both | re-review after every fix, because a fix changes the diff and the hook invalidates the prior pass | **kept**, and its **rationale corrected** — see Task 2, finding rle-M4 and plana-M6 |
| 9 | Lenses | both | lenses are different questions, not more passes; the floor, the Blocker/Major filter, the file-first protocol and the clean-final-pass rule are unchanged | **kept**, reworded so "unchanged" no longer claims the floor is fixed (Task 2, finding rle-M5) |
| 10 | `Changing a profile:` | both | a. proposes the complete resulting header · b. the human confirms, both directions · c. an agent never moves it alone · d. correct the header, append one log line · e. any axis change voids every prior override · f. `+abuse-path` follows current security · g. passes under the lower profile keep counting · h. only the final clean pass must run under the current profile · i. fold mid-cycle edits into the WIP by amend | **all nine kept verbatim**; §2.4's rules are **appended after them**, never merged in (Task 4) |
| 11 | Severity | both | Blocker = wrong/unsafe/breaks invariant · Major = design flaw → rework · both must resolve · Minor and Nit → collect, never iterate | **all four kept verbatim**; the reachability test is **appended** as the procedure that sets a ceiling on them (Task 5) |

**Nothing in §5 outside these eleven passages is edited by Plan A.** Task 6 Step 3 proves it by
reading the diff, for both files.

---

## Task 1: Open the cycle, and replace the floor

**Files:** `CLAUDE.md`, `plugins/dev-workflow/commands/workflow-init.md` — floor paragraph.

**Interfaces:**
- Produces: `max(risk, security)` inside the floor paragraph, which Tasks 2 and 5 refer back to.

- [ ] **Step 1: Preflight — four states, four answers**

```bash
for f in CLAUDE.md plugins/dev-workflow/commands/workflow-init.md; do
  old=$(grep -cF 'HARD FLOOR: min 3 passes per run' "$f")
  new=$(grep -cF 'derived from the cited story' "$f")
  printf '%s old=%s new=%s\n' "$f" "$old" "$new"
done
```

| old / new | state | what to do |
|---|---|---|
| `1 / 0` | **not started** | proceed to Step 2 |
| `0 / 1` | **complete** | verify against Step 3's text, skip to Step 6 |
| `1 / 1` | **duplicate insert** | a rerun appended without removing; delete the inserted block and restart |
| `0 / 0` | **damaged** | neither text present — STOP, restore from `git show HEAD:<file>` |

**Asymmetry between the copies is its own state:** if the two files report different pairs,
execution was abandoned between them. Bring the lagging copy to the leading copy's state before
proceeding — never proceed with the mirrors disagreeing (finding plana-M3).

- [ ] **Step 2: Read the exact text being replaced, by content**

```bash
for f in CLAUDE.md plugins/dev-workflow/commands/workflow-init.md; do
  echo "--- $f ---"
  awk '/HARD FLOOR: min 3 passes per run/,/dismissed finding → one-line why/' "$f"
done
```

The old text, in both copies:

```
**Both gates are a LOOP with a HARD FLOOR: min 3 passes per run (Blocker/Major
only), counted by the hook.** The hook counts passes but can't read findings or
tell the spec run from the plan run (it resets at `writing-plans`), so Gate A —
the spec run especially — is instruction-backed: a satisfied count is not a clean
review. Open a TodoWrite "Codex pass N" per pass; fix Blocker/Major after each. Your
final pass must be clean — if pass 3 still finds Blocker/Major, keep going until
clean or clearly stuck → then STOP and surface to the user. The only early exit
below 3 is a pass with **zero** findings; don't manufacture findings to pad. Codex is
advisory — validate before applying; dismissed finding → one-line why.
```

**Task 1 replaces only the first two sentences** — through `a satisfied count is not a clean
review.` The rest of the paragraph stays on disk; Task 2 edits two of its lines in place.

- [ ] **Step 3: The replacement — complete text, no ellipsis**

Replace exactly:

```
**Both gates are a LOOP with a HARD FLOOR: min 3 passes per run (Blocker/Major
only), counted by the hook.** The hook counts passes but can't read findings or
tell the spec run from the plan run (it resets at `writing-plans`), so Gate A —
the spec run especially — is instruction-backed: a satisfied count is not a clean
review.
```

with:

```markdown
**Both gates are a LOOP with a HARD FLOOR: a minimum number of passes per run (Blocker/Major
only), derived from the cited story's profile.** `max(risk, security) == 0` gives a floor of
**1**; every resolvable profile above that, and an artifact citing **no** story, gives **3**. Two
levels, not three — `high` takes its rigor from lens sets and evidence mode, not from extra
passes. **A cited story whose profile is present but unresolvable stops and surfaces** under §5's
existing rule; it does not fall through to 3, because reading it as 3 would turn a stop condition
into a silent default. **Across a cited set the floor is 1 if and only if the set is non-empty and
every member is profiled, resolvable and at level 0** — all four conditions, since "every cited
story" is vacuously true of an empty set; no story cited, or any cited story unprofiled, gives 3.
**One derived value governs all three cycles** — the Gate-A spec loop, the Gate-A plan loop and the
Gate-B cycle. Not because they are one cycle (§5 is explicit that they are three) but because they
derive from the same cited-story set.

**The derived floor is the pass count a cycle owes, and the hook's ratio is a reminder threshold
that controls nothing.** The hook still counts passes, and it still can't read findings or tell the
spec run from the plan run (it resets at `writing-plans`), so Gate A — the spec run especially — is
instruction-backed: **a satisfied count is not a clean review, and a below-threshold reminder is
noted in the pass report and disregarded** where the cycle's own closure rules are satisfied. **This
replaces the pass-count number and nothing else.** Every other rule §5 states about how a cycle
closes stands as written, and none of them is restated here — a summary is where their conditions
would get dropped. **Nothing here writes `.context/codex-gate.floor`**: the knob stays the user's,
never written, never removed, never read for this derivation.
```

- [ ] **Step 4: Add the residual and the gate-off disclosure**

Immediately after the block above, in both copies. The list is explicitly **not** exhaustive
(finding rle-B5).

```markdown
**Named residual:** the hook's messages state its own threshold as an obligation, so at a floor of
1 they report a shortfall the cycle does not owe. Hook text is out of scope here by decision; what
makes that tolerable is the precedence rule above plus the hook exiting 0 on every branch, not the
reminder being harmless.

**The gate-off surface — routes known today, not a complete list**, since an enumeration read as
complete guarantees the routes it omits. **One route is created here**: a stated floor the cited
set does not license, which could not exist before there was a derived floor to state.
**Pre-existing and unchanged**: omitting a higher-risk cited story; minting or editing a profile to
level 0; presenting an incomplete cited set; falsifying evidence entries; silencing reminders; or
not running a pass and reporting that it ran. **A user-set floor is not the lever** — it moves what
the hook says, not what the cycle owes. **None of this is a guard**: the floor is produced by the
agent and nothing checks it against the cited profiles.
```

- [ ] **Step 5: Verify by content**

```bash
for f in CLAUDE.md plugins/dev-workflow/commands/workflow-init.md; do
  printf '%s ' "$f"
  printf 'predicate=%s ' "$(awk '/HARD FLOOR/,/^$/' "$f" | grep -c 'max(risk, security)')"
  printf 'residual=%s ' "$(grep -cF 'Named residual' "$f")"
  printf 'gateoff=%s ' "$(grep -cF 'routes known today, not a complete list' "$f")"
  printf 'tail=%s\n' "$(grep -cF "don't manufacture findings to pad" "$f")"
done
```

**Expected at this point in the sequence: `predicate=1 residual=1 gateoff=1 tail=1` for both.**

The `awk` scoping on `predicate` is load-bearing: an unscoped `grep -c 'max(risk, security)'`
returns 1 for both files **even before any edit**, because the Profiles section already contains
the phrase. Unscoped, the check would pass before the edit and prove nothing.

`tail=1` must hold **before and after** — it catches a replacement that swallowed its neighbours.

- [ ] **Step 6: OPEN THE CYCLE**

```bash
git add CLAUDE.md plugins/dev-workflow/commands/workflow-init.md
git diff --cached --name-only   # exactly these two paths
git commit -m "WIP: review-loop economics"
```

**Plans B and C amend this same commit with this same message.** No ordinary commit occurs from
here until Plan C closes the cycle.

---

## Task 2: The floor-wording sites

**Interfaces:** consumes Task 1's predicate; produces nothing.

- [ ] **Step 1: Preflight — the sequence-correct count**

```bash
grep -cE "min 3 passes|below 3|3-pass|where the 3 come from|if pass 3 still" \
  CLAUDE.md plugins/dev-workflow/commands/workflow-init.md
```

**Expected at this point in the sequence: `6` and `6` — not 7.** Seven is the count in an untouched
tree; **Task 1 has already removed the `min 3 passes` match.** Recording 7 here was finding rle-B8.

`0` and `0` means this task already ran — verify Steps 3-4 by content and skip to Step 6.

- [ ] **Step 2: This regex does not cover every site**

```bash
grep -c 'carrying a Minor keeps' CLAUDE.md plugins/dev-workflow/commands/workflow-init.md
```

**Expected: `1` and `1`.** This is accounting passage 4. It contains no digit `3`, so Step 1's
regex never matched it and **Step 1 reaching 0 does not cover it.** Step 4 asserts it separately.

- [ ] **Step 3: Six replacements per copy — complete text, no ellipses**

Located by content. Old text, then new text.

**a.** old: `final pass must be clean — if pass 3 still finds Blocker/Major, keep going until`
new: `final pass must be clean — if the pass at the floor still finds Blocker/Major, keep going until`

**b.** old: `below 3 is a pass with **zero** findings; don't manufacture findings to pad. Codex is`
new: `below the floor is a pass with **zero** findings; don't manufacture findings to pad. Codex is`

**c.** old: `act on the partial list, don't count it toward the 3-pass floor, and don't read "no`
new: `act on the partial list, don't count it toward the floor, and don't read "no`

**d.** old: `- **Gate A — Spec, then plan (TWO runs, each its own 3-pass loop).** Run on the`
new: `- **Gate A — Spec, then plan (TWO runs, each its own loop at the derived floor).** Run on the`

**e.** old: `  invalidates the prior pass, which is where the 3 come from.`
new:
```
  no longer covers the artifact — which is why a fix costs another pass. The floor itself
  comes from the profile, and the hook's fingerprint only decides when it reminds you.
```

> Two findings, one sentence. rle-M4: `which is where the 3 come from` is a **causal claim the new
> design makes false** — the lower bound now comes from the profile. plana-M6: revision 1's
> replacement, `the hook invalidates the prior pass — which is why a fix costs another pass`,
> **made the advisory hook the cause of the review obligation**, which is a subtler version of the
> same error. The obligation exists because **the prior review no longer covers the changed
> artifact**; the hook merely compares a fingerprint at commit and review events. This is the
> "each correction introduced a subtler version of the same claim" pattern `AGENTS.md` records —
> caught here at round one instead of round four.
>
> **The preceding text must be read before applying this**, because the replacement changes where
> the sentence's subject comes from:
> ```bash
> grep -B2 -F 'which is where the 3 come from' CLAUDE.md
> ```
> Apply the new text so the sentence reads grammatically from whatever precedes it.

**f.** old: `Lenses are **different questions, not more passes.** The 3-pass floor, the Blocker/Major`
new:
```
Lenses are **different questions, not more passes** — they change what a pass asks, never how many
passes a cycle owes, which the profile and the cited set decide together. The floor, the Blocker/Major
```

> rle-M5: the old sentence continues "… is unchanged", which in the change that makes the floor
> profile-dependent tells readers the opposite of what shipped. plana-M5: revision 1 wrote "which
> the profile alone decides" — **also wrong**, because cited-set emptiness, membership, unprofiled
> members and unresolvable members all bear on the result. "The profile and the cited set decide
> together" is what Task 1's predicate actually says.

- [ ] **Step 4: The pass-1 Minor sentence, asserted separately**

old: `the only exception, exactly as above; a Blocker/Major-free pass 1 carrying a Minor keeps`
new: `the only exception, exactly as above; a Blocker/Major-free pass **below the floor** carrying a Minor keeps`

- [ ] **Step 5: Verify**

```bash
grep -cE "min 3 passes|below 3|3-pass|where the 3 come from|if pass 3 still" \
  CLAUDE.md plugins/dev-workflow/commands/workflow-init.md
grep -cF 'a Blocker/Major-free pass **below the floor** carrying a Minor keeps' \
  CLAUDE.md plugins/dev-workflow/commands/workflow-init.md
grep -cF 'Blocker/Major-free pass 1 carrying a Minor' \
  CLAUDE.md plugins/dev-workflow/commands/workflow-init.md
grep -cF "PR #23's Gate-B pass 3 returned all four findings" \
  CLAUDE.md plugins/dev-workflow/commands/workflow-init.md
```

**Expected: `0`/`0`, then `1`/`1`, then `0`/`0`, then `1`/`1`.**

The last one must stay `1`: it cites an actual pass, not a rule, and changing it would falsify a
record.

- [ ] **Step 6: Amend the WIP commit**

```bash
git add CLAUDE.md plugins/dev-workflow/commands/workflow-init.md
git commit --amend -m "WIP: review-loop economics"
```

**Never `--no-edit`.** See the commit protocol.

---

## Task 3: The pass report (§2.2)

Finding rle-B3: revision 1 of the *748-line* plan added every-pass fields to the floor paragraph
while leaving the pass-report paragraph prescribing only the pass-4 three lines, so the shipped
prompt would have described the report shape in two places that disagreed.

- [ ] **Step 1: Preflight**

```bash
grep -cF 'the cited stories they were read from' \
  CLAUDE.md plugins/dev-workflow/commands/workflow-init.md
```

**Expected at this point in the sequence: `0` and `0`.** `1`/`1` means done.

- [ ] **Step 2: Insert BEFORE the pass-report paragraph, in both copies**

Locate by content — the paragraph beginning `**From pass 4 onward every pass report carries three
lines.**`. **Insert before it; modify nothing in it.**

```markdown
**Every pass report states three things about the floor**, from pass 1 onward: the **derived
floor**, the **risk and security values read**, and the **cited stories they were read from**. A
report giving the number alone leaves a reader unable to check the derivation while passes are
still being spent — which is the only time checking it is cheap. This is owed by every pass; the
three lines below are owed from pass 4 and are a different obligation.
```

> **The two copies of the following paragraph differ** — wrapping, and `you report the tells` in
> `CLAUDE.md` against `report the tells` in the template (accounting rows 5a/5b). **That divergence
> is pre-existing and stays.** This step inserts a new paragraph and touches neither copy of the
> old one, so it neither fixes nor worsens the difference. Do not "harmonize" them here: that would
> be an edit outside the accounted dispositions.

- [ ] **Step 3: Verify, including that the old paragraph is untouched**

```bash
grep -cF 'the cited stories they were read from' \
  CLAUDE.md plugins/dev-workflow/commands/workflow-init.md
grep -cF 'From pass 4 onward every pass report carries three lines' \
  CLAUDE.md plugins/dev-workflow/commands/workflow-init.md
grep -cF 'require↔withdraw pair' CLAUDE.md plugins/dev-workflow/commands/workflow-init.md
grep -cF 'you report the tells' CLAUDE.md
grep -cF 'report the tells' plugins/dev-workflow/commands/workflow-init.md
```

**Expected: `1`/`1`, `1`/`1`, `1`/`1`, then `1`, then `1`.** The last two assert the pre-existing
divergence is still exactly as it was.

- [ ] **Step 4: Amend the WIP commit**

```bash
git add CLAUDE.md plugins/dev-workflow/commands/workflow-init.md
git commit --amend -m "WIP: review-loop economics"
```

---

## Task 4: A profile or cited set that moves mid-cycle (§2.4)

Finding rle-B6. §2.4 composes three existing rules and adds no new one, but none of the composition
is currently written down, so a mid-cycle profile or set edit can silently reuse an old clean pass.

- [ ] **Step 1: Preflight, and capture the baseline the verification needs**

```bash
grep -cF 'Any profile change costs at least one further pass' \
  CLAUDE.md plugins/dev-workflow/commands/workflow-init.md

for f in CLAUDE.md plugins/dev-workflow/commands/workflow-init.md; do
  printf 'BASELINE %s: ' "$f"
  awk '/\*\*Changing a profile:\*\*/,/^$/' "$f" | grep -o \
    'proposes the complete resulting header\|human confirms it\|never moves it alone\|append one profile-log line\|voids every prior override\|follows the current security value\|keep counting\|final clean pass\|fold the edit into the active' \
  | sort | uniq -c | tr '\n' ' '; echo
done
```

**Expected: `0` and `0` for the first.** **Record the BASELINE lines verbatim** — Step 3 compares
against them.

> Finding plana-M4: revision 1 told the executor to compare against a baseline it never captured,
> and its post-edit check counted tokens across the **whole file**, where the appended text itself
> adds `keep counting` and `final clean pass` — so the count could rise while an old condition was
> dropped. This baseline is **scoped to the `Changing a profile:` paragraph** and captured **before**
> the append, and Step 3 re-scopes the same way.

- [ ] **Step 2: Append after the `Changing a profile:` paragraph, both copies**

Its nine conditions are accounting row 10 (a-i). **They are kept verbatim.** §2.4's rules are
**appended after them**, never merged into them — merging is how a rewrite drops a condition, which
`AGENTS.md` names as this repo's tenth recorded instance.

```markdown
**While a gate is running, the floor derives from the *current* profile at each pass.** Passes
already run keep counting; closing requires the floor **as currently derived**. These are
pass-count rules, so they apply while §5 says a gate is running and are silent otherwise — what §5
says about *when* a gate runs is §5's, unchanged and deliberately not summarised here.

**Any profile change costs at least one further pass**, in either direction and **whether or not
the floor number moves**, because the final clean pass must run under the current profile — so no
already-banked pass can be it. That further pass must itself be clean and every other closure duty
must be satisfied; it is one more pass, not a licence to close on the next one. **What a lowering
drops is whatever the changed values drop, not a fixed pair**: a mode-only override changes the
evidence obligations while leaving the axis-derived lens sets alone, and security `high` →
`standard` keeps the security lens set while changing what evidence is owed. **Every derived
obligation is recomputed from the current profile.**

**The cited set is re-read at each pass, and the final clean pass runs against the current set —
whenever its membership changes, not only when the floor number moves.** Adding a high-risk story
to a set already at floor 3 leaves the number alone while adding that story's lens set, its
evidence obligations and its review scope; a pass run before it joined did not cover them.
**Removing a story** recomputes obligations from the current set and so does remove *that story's*
lenses and evidence duty — but it **never discharges an accepted in-set Blocker or Major**: the
acceptance put that finding in the fix set, not the citation.
```

- [ ] **Step 3: Verify against the captured baseline**

```bash
grep -cF 'Any profile change costs at least one further pass' \
  CLAUDE.md plugins/dev-workflow/commands/workflow-init.md

for f in CLAUDE.md plugins/dev-workflow/commands/workflow-init.md; do
  printf 'AFTER %s: ' "$f"
  awk '/\*\*Changing a profile:\*\*/,/^\*\*While a gate is running/' "$f" | grep -o \
    'proposes the complete resulting header\|human confirms it\|never moves it alone\|append one profile-log line\|voids every prior override\|follows the current security value\|keep counting\|final clean pass\|fold the edit into the active' \
  | sort | uniq -c | tr '\n' ' '; echo
done
```

**Expected: `1`/`1`, then AFTER lines identical to Step 1's BASELINE lines.** The `awk` range now
stops at the inserted text, so it measures the original paragraph only — a token the append
introduced cannot mask a condition the edit dropped. **Any difference is a dropped condition, not
a formatting artefact.**

- [ ] **Step 4: Amend the WIP commit**

```bash
git add CLAUDE.md plugins/dev-workflow/commands/workflow-init.md
git commit --amend -m "WIP: review-loop economics"
```

---

## Task 5: Severity semantics (§3), and activation (§10, partial)

- [ ] **Step 1: Preflight**

```bash
grep -cF 'what in the system consumes this text' \
  CLAUDE.md plugins/dev-workflow/commands/workflow-init.md
grep -cF 'a cycle already running finishes' \
  CLAUDE.md plugins/dev-workflow/commands/workflow-init.md
```

**Expected at this point in the sequence: `0`/`0` and `0`/`0`.**

- [ ] **Step 2: Append the test after the four Severity definitions, both copies**

Locate by content — the `- **Severity:** Blocker (wrong/unsafe/breaks invariant)` bullet. The four
definitions stay verbatim. Append:

```markdown
  **Deciding severity — one procedure. The subject list is illustration, not a second rule.**
  Name **what in the system consumes this text** — whatever *acts* on it — and the decision that
  act takes differently if the text is wrong. **Both are required. If you cannot name both**, the
  finding is **Minor or below**: collect, never iterate.

  The exclusions are contract, not commentary. **The reader must consume the text in the system's
  *operation*, not in reviewing it** — the review pass raising the finding is not an in-system
  reader of the text it reviews; without this the test demotes nothing. **Gates remain legitimate
  readers** of rule text they will later apply. **A human reader never satisfies the test** — §5's
  prose exemption already prices that cost as non-gating. **The list of reader kinds is
  illustrative, not closed**, because this ships into projects whose readers we have never seen.
  **The test sets a ceiling, not a floor, and never chooses between Blocker and Major** — the four
  definitions above still decide that. **The instrument carve-out is symmetric**: an instrument
  finding keeps its severity whenever it shows the instrument changes what a gate concludes about
  product behaviour — a false green, and equally a false red or a check blocking a valid change.
  **Rationale prose is Minor only when no rule's application depends on it**, not categorically:
  `docs/prompt-standards.md` requires rules to carry their why, so rationale a reader must consult
  to apply a rule passes the test. **This removes arbitrariness, not judgement.** Coverage-first is
  unchanged — the reviewer reports every finding with severity and confidence; the filter is ours.

  This is the **finding-level analog of the path-level prose exemption**: one principle at two
  granularities — text that *describes* the product versus text that *is* the product.
```

- [ ] **Step 3: Append the activation block after Task 1's gate-off disclosure, both copies**

Finding rle-B7. **Plan A ships the two parts Plan A ships. Plan B extends this list** — §10 says
extending is safe and replacing is not, so the wording below is a list Plan B appends to rather
than a closed enumeration Plan B would have to rewrite.

```markdown
**When these rules bind.** From the commit that ships them, and **a cycle already running finishes
under the rules it started with**. **Where a cycle's starting rules cannot be established it takes
the stricter reading of every part this change touches** — at minimum floor 3, and severity
classified without the demotion; **each further rule this change ships adds its own strict reading
to this list.** Not a re-derivation, which could hand a level-0 cycle a floor of 1 and *skip*
passes on the strength of not knowing when it started. A user knob set above 3 is not lowered by
this fallback. **A revert is itself a shipping commit for the old rules**, and the activation rule
wins wherever the start is determinable; the fallback covers only where it is not.

**Downstream has no shipping commit.** Adoption binds from the `/workflow-init` run that *actually
writes* the text — which may write nothing, be declined, or be merged in part — so **these rules
bind only over the text a project's `CLAUDE.md` actually contains**, and a partial adoption can
persist undetected. A project taking the floor rule without the severity test gets a floor whose
`docs-only` question the severity test is what settles. What prompt text can do is done; what it
cannot is said.
```

> `at minimum` and `each further rule this change ships adds its own strict reading to this list`
> are what make this extensible: Plan B appends the provenance-line, curve and nonce duties without
> rewriting the sentence. Without them, a two-item list reads as closed and Plan B would have to
> replace it — which §10 says is the unsafe move.

- [ ] **Step 4: Verify**

```bash
grep -cF 'what in the system consumes this text' \
  CLAUDE.md plugins/dev-workflow/commands/workflow-init.md
grep -cF 'a cycle already running finishes' \
  CLAUDE.md plugins/dev-workflow/commands/workflow-init.md
grep -cF 'adds its own strict reading to this list' \
  CLAUDE.md plugins/dev-workflow/commands/workflow-init.md
grep -cF '- **Severity:** Blocker (wrong/unsafe/breaks invariant)' \
  CLAUDE.md plugins/dev-workflow/commands/workflow-init.md
```

**Expected: `1`/`1` four times.**

- [ ] **Step 5: Amend the WIP commit**

```bash
git add CLAUDE.md plugins/dev-workflow/commands/workflow-init.md
git commit --amend -m "WIP: review-loop economics"
```

---

## Task 6: Parity, conformance, and the diff proof

No new rules. This is the verification invariant 11 requires. Finding rle-M7 / plana-M7: the results
have a defined schema and an asserted row count, and the parity check compares **text**, not
occurrence counts.

- [ ] **Step 1: Preflight**

This task appends result tables to **this plan document**. If the tables already exist, this task
ran — verify their row counts against Steps 2-3 rather than appending again.

- [ ] **Step 2: Parity — compare the shipped text, not counts**

```bash
C=CLAUDE.md; T=plugins/dev-workflow/commands/workflow-init.md
tmp=$(mktemp -d) || exit 1
i=0; ok=0
while IFS='|' read -r start end; do
  i=$((i+1))
  awk "/$start/,/$end/" "$C" > "$tmp/c.$i"
  awk "/$start/,/$end/" "$T" > "$tmp/t.$i"
  if [ ! -s "$tmp/c.$i" ] || [ ! -s "$tmp/t.$i" ]; then
    printf 'EMPTY %s: %s — range matched nothing; the edit is missing or the anchor is wrong\n' "$i" "$start"
  elif diff -q "$tmp/c.$i" "$tmp/t.$i" >/dev/null; then
    printf 'PARITY %s: %s\n' "$i" "$start"; ok=$((ok+1))
  else
    printf 'DIFFERS %s: %s\n' "$i" "$start"
    diff "$tmp/c.$i" "$tmp/t.$i"
  fi
done <<'RANGES'
HARD FLOOR: a minimum number|derive from the same cited-story set
The derived floor is the pass count|never read for this derivation
Named residual|not the reminder being harmless
The gate-off surface|against the cited profiles
Every pass report states three things|a different obligation
While a gate is running|as currently derived
Any profile change costs at least|recomputed from the current profile
The cited set is re-read|not the citation
Deciding severity|collect, never iterate
The exclusions are contract|the filter is ours
finding-level analog|that is the product
When these rules bind|only where it is not
Downstream has no shipping commit|what it cannot is said
RANGES
```

**Expected: thirteen `PARITY` lines, numbered 1 to 13, no `DIFFERS`, and no `EMPTY`.** The loop
asserts it itself — append this immediately after the `RANGES` terminator:

```bash
rm -rf "$tmp"
[ "$i" = 13 ] && [ "$ok" = 13 ] && echo "PARITY-COMPLETE 13/13" \
  || { echo "PARITY-INCOMPLETE ranges=$i parity=$ok"; exit 1; }
```

**An `EMPTY` line is not a pass.** Revision 1's check could print `PARITY` for a range that matched
nothing in either copy — two absences comparing equal. `-s` catches that, and `ok` counts only
ranges that actually compared non-empty text.

> Revision 1's parity script compared **occurrence counts** of a marker phrase and printed `PARITY`
> whenever both were 1 — so two copies with the same marker and different surrounding text passed
> (finding plana-M7). This compares the extracted block text with `diff` and prints the difference
> when it finds one.

Record each row in a table in this document: *rule* · *status* from the closed set `IDENTICAL` |
`DELIBERATE-DIFFERENCE` | `DEFECT` · *reason, required for the latter two*. **Thirteen rows,
asserted.**

- [ ] **Step 3: The diff proof — both files, every hunk**

```bash
git diff HEAD~1 -- CLAUDE.md
git diff HEAD~1 -- plugins/dev-workflow/commands/workflow-init.md
git diff HEAD~1 --stat -- CLAUDE.md plugins/dev-workflow/commands/workflow-init.md
```

Read **both** diffs in full and confirm every hunk falls inside one of the eleven accounted
passages. **A hunk outside them is a finding.**

> Revision 1 printed a stat for both files but the changed-line count for only one, and never
> displayed the template's hunks it claimed the executor must verify (finding plana-MINOR 11). No
> expected line count is stated here on purpose: the correct check is a human reading two diffs
> against an eleven-row inventory, and a number would invite substituting the number for the read.

- [ ] **Step 4: The twelve-item conformance pass**

Artifacts: the **resulting scaffolded template**, and
`plugins/dev-workflow/commands/workflow-init.md` as the outer command prompt. One row per item per
artifact: *item* · *artifact* · **status** from `PASS` | `N/A` | `FAIL` · *reason, required for
`N/A` and `FAIL`*. **Twenty-four rows, asserted.** **Item 7 is read against the whole resulting
artifact**, not the diff.

**Root `CLAUDE.md` is outside invariant 11's list and is not part of this pass.**

> **Item 1 for the scaffolded template is `N/A`; Plan C ships the note that says why** — the file
> the template writes is model-agnostic by design, so a `Target model:` line inside it would be
> false in every repo it lands in.

- [ ] **Step 5: Invariant checks**

```bash
grep -c '^Target model:' plugins/dev-workflow/commands/workflow-init.md
sh scripts/check-invariants.sh && echo INVARIANTS-OK
```

**Expected: `1`, then `INVARIANTS-OK`.** The count must be 1 — `scripts/check-invariants.sh` fails
on any other, and a naive item-1 fix that adds a second declaration is exactly how that breaks.

- [ ] **Step 6: Fold the results into the WIP commit**

```bash
git add docs/superpowers/plans/2026-08-29-review-loop-economics-plan-a-rules.md
git commit --amend -m "WIP: review-loop economics"
```

**Not a separate commit.** An ordinary commit here — even staging only a `docs/**.md` path — resets
the cycle and strands the WIP, because the reset is keyed on the commit, not on the staged paths.

---

## Task 7: The battery, and the hand-off to Plan B

Plan A runs no Gate-B cycle. The single cycle covering all three plans opens here and is reviewed
and closed by Plan C.

- [ ] **Step 1: The battery, minus one step, for a stated reason**

```bash
shellcheck --shell=sh plugins/dev-workflow/hooks/codex-gate.sh && \
shellcheck --shell=sh --exclude=SC2015 plugins/dev-workflow/hooks/codex-gate.test.sh && \
shellcheck --shell=sh scripts/check-invariants.sh && \
shellcheck --shell=sh --exclude=SC2015 scripts/check-invariants.test.sh && \
shellcheck --shell=sh scripts/check-version-bump.sh && \
shellcheck --shell=sh scripts/check-version-bump.test.sh && \
HOOK_SH=sh sh plugins/dev-workflow/hooks/codex-gate.test.sh && \
HOOK_SH=dash dash plugins/dev-workflow/hooks/codex-gate.test.sh && \
sh scripts/check-invariants.test.sh && sh scripts/check-invariants.sh && \
sh scripts/check-version-bump.test.sh && \
claude plugin validate . --strict && echo "BATTERY-GREEN (version-bump deferred)"
```

> **`sh scripts/check-version-bump.sh main` is deliberately absent, and only that one step.**
> Plan A changes a path under `plugins/dev-workflow/` while the manifest bump is Plan C's, so the
> checker **would correctly fail here**. It is deferred to the combined close, where the bump
> exists. `AGENTS.md` already states this checker's precondition — it compares *commits*, and run
> mid-work it reports clean and uselessly.
>
> **This is a deferral of one step with a named reason, not licence to skip the rest.** Every other
> command above must pass before Plan B opens. `scripts/check-version-bump.test.sh` — the suite —
> still runs, because it does not depend on the working tree's bump state.

- [ ] **Step 2: Confirm the cycle is intact before handing off**

```bash
git log --oneline -1
git log -1 --pretty=%s | grep -q '^WIP: review-loop economics' && echo "CYCLE OPEN" || echo "CYCLE LOST — investigate"
git status --porcelain
```

**Expected: the WIP subject, `CYCLE OPEN`, and a clean worktree.** A lost cycle here means an
ordinary commit slipped in; find it before Plan B adds to the damage.

- [ ] **Step 3: Hand off**

Plan B opens against this WIP commit and amends it with the same message. Plan A's Gate-A loop must
have closed clean before Plan B's Gate-A loop opens.

---

## Self-Review

**Spec coverage.** §2 predicate, unanimity, unresolvable-stop, one-value-three-cycles → Task 1
Step 3. §2.1 precedence, knob, residual → Task 1 Steps 3-4. §2.2 pass report → Task 3. §2.4
mid-cycle → Task 4. §3 severity → Task 5 Step 2. §10 activation, revert, downstream adoption,
gate-off surface → Task 1 Step 4 and Task 5 Step 3, **partial by design and written to be
extended**: the record duties in §10's strict-fallback list are Plan B's to append. §2.3, §4, §5,
§6 → Plan B. §7, §8 → Plan C.

**Placeholders.** None.

**Sequence-correct expected values — the claim, and its two known limits.** Every check states an
expected value for its point in the sequence, and every executable step addresses by content rather
than by a line number an earlier task can shift. Two places state no numeric expectation on
purpose, rather than by omission: Task 6 Step 3 asks for a human read of two diffs against an
eleven-row inventory, where a number would invite substituting the number for the read; and Task 6
Step 1's preflight is a judgement about already-appended tables. Revision 1 made this claim
blanket and it was false in two places (finding plana-MINOR 14) — these are the two, named.

**Type consistency.** `max(risk, security)`, "derived floor", "reminder threshold", "cited set" and
"level 0" are used identically in Tasks 1, 2, 3, 4 and 5, and match the spec's spellings.

**Gate-B classification.** Plan A opens the single cycle at Task 1 Step 6 and runs no review. Every
commit from that point is an amend restating `-m "WIP: review-loop economics"`. Plan C closes.

**Rerun and interruption.** Every task opens with a preflight distinguishing not-started, complete,
duplicate and damaged, and **asymmetry between the two copies is its own state** with its own
answer — an execution abandoned between the two files leaves the mirrors disagreeing, and Task 1
Step 1 says to reconcile before proceeding rather than continuing (finding plana-M3).

**Known limit.** The replacement wordings are proposals, not transcriptions — the spec pins the
rules, not the sentences — and this plan's Gate A is what reviews them.
