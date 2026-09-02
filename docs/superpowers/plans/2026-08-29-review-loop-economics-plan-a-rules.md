# Plan A — the rules edits (floor predicate + severity semantics)

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development
> (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use
> checkbox (`- [ ]`) syntax for tracking.

**Goal:** Ship parts 1 and 2 of the review-loop-economics change into both prompt copies — the
pass floor becomes a function of the cited story's profile, and finding severity is decided by
whether something in the system takes a different decision.

**Spec:** `docs/superpowers/specs/2026-08-28-review-loop-economics-design.md` (revision 36).
Plan A implements §2, §2.1, §2.2, §2.4, §3, and §10 in part.

**Story:** `docs/superpowers/stories/2026-08-28-review-loop-economics-pass-floor-story.md`

> **Read the profile from that header at execution time.** This plan states no risk value, no
> security value, no validation mode and no pass count derived from any of them.

---

## Plan A of three

| Plan | Ships | Spec sections |
|---|---|---|
| **A — this one** | the floor predicate and the severity test | §2, §2.1, §2.2, §2.4, §3, §10 (partial) |
| **B** | the provenance line, the per-pass curve, the cycle nonce, slot naming | §2.3, §4, §5, §6 |
| **C** | rollout: falsified sentences, packaging, the evidence pack, the review loop | §7, §8 |

**One Gate-B cycle** over the combined A+B+C diff, run and closed by Plan C. The Gate-A
cycles behind it are one per artifact: the spec's, and one per plan — five in the end, since
Plan C was split and C1 got its own before being dissolved. Their record is
`docs/field-reports/2026-08-30-gate-a-rle-plan-cycles.md`.
**Execution order A → B → C; Plan B may not open before Plan A's Gate-A loop closes.**

**Plan C inherits these obligations**, which lived in a Gate-B section Plan A no longer has. A
finding whose section moved is relocated, not repaired:

| Finding | What Plan C owes |
|---|---|
| pass-1 M8 | single-branch Gate-B recovery: delete only the failed branch, never both |
| pass-1 M9 | record the floor knob's existence and bytes before the cycle, compare after |
| pass-1 M10 | never `git add -u`; stage an explicitly inspected path set |
| pass-1 MINOR 12 | build the closing body with `mktemp`, not a fixed `/tmp` path |
| pass-1 B6 | evidence revalidated after every fix and again before the closing amend |

---

## Global Constraints

- **This Gate-B cycle runs under the rules in force at its start — the OLD ones.** The new
  severity semantics, floor rule and record forms bind only **after** the closing commit ships
  them. **Carry this sentence in the `additionalContext` of every Gate-B call**: a reviewer
  applying the new Minor-or-below ceiling to the change that introduces it would under-iterate
  on exactly the diff needing most iteration.
- **Prompt-only.** No file under `plugins/dev-workflow/hooks/` changes, and the floor knob
  `.context/codex-gate.floor` is never written, never removed, never read for the derivation.
  This is not a claim that nothing under `.context/` is written — Gate-B calls and commit events
  write counters, fingerprints and markers there as always.
- **The §5 heading must keep matching `^#{1,6}[[:space:]]+([0-9]+\.)?[[:space:]]*Cross-Model Review`.**
  `codex-gate.sh:94` greps `CLAUDE.md` for it to build every reminder's citation.
- **Every edit lands in both copies except Task 14**, which is `CLAUDE.md`-only and says why.
  Where the two copies already differ, the difference is pre-existing, named in the accounting,
  and left as it is.
- **§5's other closure rules are never restated, only referred to.**
- **Line numbers are provenance, never instructions.** Each task pastes its `grep -n` anchor as
  it stood in the untouched tree; the edit is located by its OLD text.

### The commit protocol

**One WIP commit, opened at Task 1, amended by every later task and by Plans B and C, reviewed
once after Plan C, closed once.**

> **Never `git commit --amend --no-edit` inside the cycle.**
> `plugins/dev-workflow/hooks/codex-gate.sh:763` recognizes a WIP commit by grepping the **Bash
> command string** for `-m ... wip`; an amend without `-m` is not recognized, and the hook resets,
> discarding the cycle's passes. Every amend restates `-m "WIP: review-loop economics"`.

**The cycle records its base SHA once, at cycle open, and uses it for every diff and every
Gate-B call** — not `HEAD~1`, which moves if a snapshot is ever stacked. Task 1 prints it.

---

## Old-conditions accounting

Derived from the edits this plan makes, against §5 at HEAD. **Eleven passages, thirteen rows.**
Two passages diverge between the copies and get a row each; both divergences were found by
`diff` over the passage's full extent.

| # | Passage | Copy | What the existing prose requires | Disposition |
|---|---|---|---|---|
| 1 | floor paragraph | both | a. a hard floor of 3 passes per run · b. Blocker/Major only · c. the count is the hook's · d. the hook cannot read findings · e. the hook cannot tell the spec run from the plan run · f. it resets at `writing-plans` · g. therefore Gate A is instruction-backed · h. a satisfied count is not a clean review · i. a TodoWrite per pass · j. fix Blocker/Major after each · k. Codex is advisory · l. validate before applying · m. dismissed finding → one-line why | a. **replaced** by the derived predicate (Task 1) · c. **moved** — the hook still counts, as its reminder threshold, not the obligation · **d–h kept in substance and rewritten in wording** in the second paragraph, since the replacement re-emits them around the new precedence — not kept verbatim, and the earlier claim that they were is corrected here · b **kept verbatim inside the replacement** · i–m **kept verbatim outside the replaced range** |
| 2 | `if pass 3 still` | both | the final pass must be clean; if the pass at 3 still finds Blocker/Major, keep going until clean or clearly stuck, then STOP and surface | **kept**, `pass 3` → `the pass at the floor` (Task 3) |
| 3 | `below 3` | both | the only early exit below the floor is a zero-finding pass; don't pad | **kept**, `below 3` → `below the floor` (Task 4) |
| 4 | pass-1 Minor sentence | both | below the floor nothing closes; a zero-finding pass is the only exception; a Blocker/Major-free pass 1 carrying a Minor keeps looping | **kept**, `pass 1` → `pass below the floor` (Task 9). The sentence that inverts at floor 1 |
| 5a | pass-report paragraph | `CLAUDE.md` | a. from pass 4 onward, three lines · b. carrier is your own status report · c. never the Codex reply · d. never the findings file · e. trend · f. cluster · g. require↔withdraw · h. the five tells · i. any-two makes stop-and-surface mandatory · j. "clearly stuck" is not a precondition · **k. "you report the tells" — second person** | **untouched.** Task 10 inserts a new paragraph before it and modifies nothing in it |
| 5b | pass-report paragraph | template | a–j as above · **k′. "report the tells" — imperative** · plus different wrapping | **untouched**, same reason. The divergence is pre-existing |
| 6 | incomplete-pass | both | an incomplete pass is not a review: don't act on the partial list, don't count it toward the floor, don't read "no Blocker/Major visible" as clean | **kept**, `the 3-pass floor` → `the floor` (Task 5) |
| 7a | Gate A loop | `CLAUDE.md` | a. two runs, each its own 3-pass loop · b. one broad prompt, re-run each pass · c. don't narrow per-dimension · d. the required opening phrase · e. coverage floor not a cage · f. every finding with severity and confidence · **g. the citation `` (`docs/prompt-standards.md`, "coverage first, filter later") `` ** · h. one line per finding · i. literal `NO FINDINGS` · j. settle mechanically before each read pass | **a kept**, `3-pass loop` → `loop at the derived floor` (Task 6); **b–j untouched, g included** |
| 7b | Gate A loop | template | a–f, h–j as above · **g′. the citation is ABSENT** · plus different wrapping | same edit to `a`; the missing citation is pre-existing and left alone |
| 8 | `where the 3 come from` | both | a. re-review after every fix · b. because a fix changes the diff · **c. and the hook invalidates the prior pass — which is where the 3 come from** | **a kept.** **b and c are DELIBERATELY DROPPED and replaced** (Task 7): the new design makes c false — the floor comes from the profile, not from invalidation — and b's framing put the hook in the causal position. What replaces them: a fix changes the artifact, so the prior review no longer covers it; the hook merely notices, at commit time. Recorded as a drop rather than as a keep, which the earlier row got wrong |
| 9 | Lenses | both | a. lenses are different questions, not more passes · b. the 3-pass floor is unchanged · c. the Blocker/Major filter is unchanged · d. the file-first protocol is unchanged · e. the clean-final-pass rule is unchanged | a **kept and sharpened** · **b deliberately dropped and replaced by its negation** — the floor is what this change makes variable · c, d, e **kept verbatim** (Task 8) |
| 10 | `Changing a profile:` | both | a. proposes the complete resulting header · b. human confirms, both directions · c. an agent never moves it alone · d. correct the header, append one log line · e. any axis change voids every prior override · f. `+abuse-path` follows current security · g. passes under the lower profile keep counting · h. only the final clean pass must run under the current profile · i. fold mid-cycle edits into the WIP by amend | **all nine kept verbatim**; §2.4's rules appended after them, never merged in (Task 11) |
| 11 | Severity | both | Blocker = wrong/unsafe/breaks invariant · Major = design flaw → rework · both must resolve · Minor and Nit → collect, never iterate | **all four kept verbatim**; the reachability test appended, and nothing else. Task 12 ships spec §3 alone — no consequence for the per-pass counts, the clusters or the stop thresholds, and no precedence against any loop rule, all of which §9 excludes. One sentence says the interaction is not settled here and gives the unresolved-state action; **`CLAUDE.md` alone adds the owner's path** (Task 14) |

**Nothing in §5 outside these eleven passages is edited.** Gate B, reviewing the combined diff,
is what confirms that against this table.

**Two rows added during the Gate-B cycle**, because two decision procedures were rewritten by
its findings and this table is where old conditions are accounted for:

| # | Passage | Copy | What the pre-fix prose required | Disposition |
|---|---|---|---|---|
| 12 | profile-reading cases | both | a. cites no story → unprofiled · b. no profile line → unprofiled · c. present but unresolvable → stop, covering unparseable lines, values outside the enums, two profile blocks, a citation resolving to nothing, and the semantic mismatches | a and b **kept verbatim**. c **split**: the failure-to-obtain-the-file half — including "a citation resolving to nothing" — becomes its own case 3 with four named sub-causes and a decidable order of tests, because an agent that never read the file can answer neither a nor b; the remaining syntactic and semantic failures stay as case 4, **unchanged in substance**. Nothing dropped |
| 13 | `headSha` / branch agreement | both | a. both branches must have reviewed the same commit · b. take it from the head commit each call reports · c. capture it with the branch's result, not later · d. require exact equality before summing · e. record the full 40-character name | **b deliberately dropped**: the reviewer tool reports no head commit, so the condition was unsatisfiable as written. **a narrowed to what the mechanism supports** — both branches are *issued against* the same commit, stated with the explicit note that this is not evidence either reviewed it. c, d, e **kept**, now applied to the value passed rather than a value read back |

---
## Task 1: The floor predicate

**Spec:** §2, §2.1

**Site** — pasted `grep -n`:

```
CLAUDE.md:72:**Both gates are a LOOP with a HARD FLOOR: min 3 passes per run (Blocker/Major
plugins/dev-workflow/commands/workflow-init.md:272:**Both gates are a LOOP with a HARD FLOOR: min 3 passes per run (Blocker/Major
```

> The text on disk ends **mid-line**: ` Open a TodoWrite "Codex pass N" per pass;` continues the same line after `review.` Match exactly this and no more; what follows stays.
> 
> **The between-cycle rule implements spec §2's one-value sentence, verified against revision 36 before it was written.** §2 says the value is one *"because they derive from **the same cited-story set**"* — a claim about the **source**, not about freezing a number in time. So the value is a function of that set's **current** confirmed profiles, read fresh wherever §5 already requires reading them: one source, therefore exactly one value at any moment.
> 
> **A snapshot taken once at the first cycle's open was considered and rejected.** It would be "a remembered or copied value", which §5's Profiles section forbids in those words — *"the story header is the single writable copy … read the values fresh at each pass, never a remembered or copied value"* — and it points the wrong way on invariant 2: a human-confirmed **raise** between cycles would then leave work still in flight reviewed under the weaker profile, which is the under-review direction.
> 
> **§2.4 does not merely permit this; it routes the question here.** Its pass-count rules *"apply while §5 says a gate is running and are silent otherwise"*, and it states that *"what §5 says about when a gate runs — including how a moving profile or cited set bears on that — is §5's, unchanged and deliberately not summarised here."* The between-cycle case was never a spec gap. §2.4 does not *supply* the answer — it is silent outside a running gate and says so — it **delegates** the question, and §5's read-fresh rule is what answers it.

- [ ] **Replace, in both copies.** OLD:

```
**Both gates are a LOOP with a HARD FLOOR: min 3 passes per run (Blocker/Major
only), counted by the hook.** The hook counts passes but can't read findings or
tell the spec run from the plan run (it resets at `writing-plans`), so Gate A —
the spec run especially — is instruction-backed: a satisfied count is not a clean
review.
```

NEW:

```
**Both gates are a LOOP with a HARD FLOOR: a minimum number of passes per run
(Blocker/Major only), derived from the cited story's profile.**
The derivation is max(risk, security): a value of 0 gives a floor of 1; every
resolvable profile above that, and an artifact citing no story, gives 3. Two levels,
not three — `high` takes its rigor from lens sets and evidence mode, not from extra
passes. A cited story whose profile is present but unresolvable stops and surfaces
under the existing rule; it does not fall through to 3, because reading it as 3 would
turn a stop condition into a silent default. Across a cited set the floor is 1 if and
only if the set is non-empty and every member is profiled, resolvable and at level 0
— all four conditions, since "every cited story" is vacuously true of an empty set;
no story cited, or any cited story unprofiled, gives 3. One derived value governs all
three cycles: the Gate-A spec loop, the Gate-A plan loop and the Gate-B cycle. Not
because they are one cycle — they are three — but because they derive from the same
cited-story set. That value is a function of the current confirmed profiles of that set,
read fresh wherever this section already requires them to be read, so wherever a value can be
derived at all there is exactly one, because there is one source. Some states derive **no** value
rather than a second one, and each stops rather than defaulting: governing headers that
disagree; a cited profile that is present but unresolvable; and a `Story:` header that cannot
be read. A change to a profile or to the set
therefore binds every open and future cycle — a raise costs an affected open cycle a
further pass under the current profile, as the profile-change rule below requires — while a
cycle that has already closed
stands, its close having been valid under the profile current when it closed, which is the
cycle-level form of passes already run keeping their count. **The set has one authority:
the artifact's `Story:` header, which carries the path of every cited story.** Nothing else
is a citation. A story path appearing anywhere else in an artifact's body — including a
sentence placing a story *outside* this change's scope — **contributes nothing to the cited
set and nothing to the floor derivation**, which is the only claim made about it; it may still
be a perfectly good cross-reference for any other purpose. And **an agent
deriving the set reads that header and does not grep the body for story paths**, because a
grep finds mentions and cannot tell a citation from a disclaimer. **Each cycle's governing header is the
header of the artifact it reviews**: the spec's for the Gate-A spec loop, the plan's for the
Gate-A plan loop, and — since a Gate-B cycle reviews a diff and has no header of its own —
**the union of the `Story:` headers of every plan contributing to that diff, which the Gate-B
call must carry in full**, as this section already requires of every cited path. **Every expected artifact contributes a set — a spec, and every plan contributing to the
reviewed diff — and an expected artifact whose `Story:` header is absent contributes the empty
set rather than dropping out of the comparison.** **One path per entry**: a header citing several
stories carries several entries, one path each. Exact duplicate paths are one member; entries
naming different stories are different members; and a header that cannot be read as a list of
paths that way is malformed and stops, reporting that as the cause rather than as a
disagreement. **Before each pass the deriving agent
compares every such set, and again before a clean pass is accepted as the cycle's final pass.**
A header or profile that changed during that pass means the pass is not final — the same
answer a change gets at every other read point. Where they name different sets the premise of a single value has
failed: **stop and surface the disagreement** rather than deriving from either, exactly as an
unresolvable profile stops rather than defaulting.

**The derived floor is the pass count a cycle owes, and the hook's ratio is a reminder
threshold that controls nothing.** The hook still counts passes, and it still can't read
findings or tell the spec run from the plan run (it resets at `writing-plans`), so
Gate A — the spec run especially — is instruction-backed: a satisfied count is not a
clean review, and a below-threshold reminder is noted in the pass report and disregarded
where the cycle's own closure rules are satisfied. This replaces the pass-count number
and nothing else. Every other rule stated here about how a cycle closes stands as
written, and none of them is restated — a summary is where their conditions would get
dropped. Nothing here writes the floor knob: it stays the user's, never written, never
removed, never read for this derivation.
```

- [ ] **Assert the new text is present.**

```bash
grep -cF -- "derived from the cited story's profile" \
  CLAUDE.md plugins/dev-workflow/commands/workflow-init.md
```

Before this task: `0` and `0`. After: `1` and `1`. Verified executable against a simulated post-edit tree — the pattern lies on one line, contains no `**`, and is passed after `--` so a leading `-` cannot be read as an option.

- [ ] **Open the cycle.**

```bash
git add CLAUDE.md plugins/dev-workflow/commands/workflow-init.md
git commit -m "WIP: review-loop economics"
git rev-parse HEAD~1   # the cycle's base — Plan C uses this for every diff and Gate-B call
```

---

## Task 2: The residual and the gate-off surface

**Spec:** §2.1, §10

**Site** — pasted `grep -n`:

```
CLAUDE.md:80:advisory — validate before applying; dismissed finding → one-line why.
plugins/dev-workflow/commands/workflow-init.md:280:advisory — validate before applying; dismissed finding → one-line why.
```

> Match the floor paragraph's final line including its trailing newline, and re-emit it followed by the two new blocks. The gate-off list is explicitly **not** exhaustive.

- [ ] **Replace, in both copies.** OLD:

```
advisory — validate before applying; dismissed finding → one-line why.
```

NEW:

```
advisory — validate before applying; dismissed finding → one-line why.

**Named residual:** the hook's messages state its own threshold as an obligation, so at a
floor of 1 they report a shortfall the cycle does not owe. Hook text is out of scope here
by decision; what makes that tolerable is the precedence rule above plus the hook exiting
0 on every branch, not the reminder being harmless.

**The gate-off surface — routes known today, not a complete list**, since an enumeration
read as complete guarantees the routes it omits. One route is created here: a stated floor
the cited set does not license, which could not exist before there was a derived floor to
state. Pre-existing and unchanged: omitting a higher-risk cited story; minting or editing a
profile to level 0; presenting an incomplete cited set; falsifying evidence entries;
silencing reminders; or not running a pass and reporting that it ran. A user-set floor is
not the lever — it moves what the hook says, not what the cycle owes.
None of this is a guard: the floor is produced by the agent and nothing checks it against
the cited profiles.
```

- [ ] **Assert the new text is present.**

```bash
grep -cF -- "routes known today, not a complete list" \
  CLAUDE.md plugins/dev-workflow/commands/workflow-init.md
```

Before this task: `0` and `0`. After: `1` and `1`. Verified executable against a simulated post-edit tree — the pattern lies on one line, contains no `**`, and is passed after `--` so a leading `-` cannot be read as an option.

- [ ] **Amend the WIP commit.**

```bash
git add CLAUDE.md plugins/dev-workflow/commands/workflow-init.md
git commit --amend -m "WIP: review-loop economics"
```

---

## Task 3: `pass 3` at the clean-final-pass rule

**Spec:** §2

**Site** — pasted `grep -n`:

```
CLAUDE.md:77:final pass must be clean — if pass 3 still finds Blocker/Major, keep going until
plugins/dev-workflow/commands/workflow-init.md:277:final pass must be clean — if pass 3 still finds Blocker/Major, keep going until
```

- [ ] **Replace, in both copies.** OLD:

```
final pass must be clean — if pass 3 still finds Blocker/Major, keep going until
```

NEW:

```
final pass must be clean — if the pass at the floor still finds Blocker/Major, keep going until
```

- [ ] **Assert the new text is present.**

```bash
grep -cF -- "if the pass at the floor still finds" \
  CLAUDE.md plugins/dev-workflow/commands/workflow-init.md
```

Before this task: `0` and `0`. After: `1` and `1`. Verified executable against a simulated post-edit tree — the pattern lies on one line, contains no `**`, and is passed after `--` so a leading `-` cannot be read as an option.

- [ ] **Amend the WIP commit.**

```bash
git add CLAUDE.md plugins/dev-workflow/commands/workflow-init.md
git commit --amend -m "WIP: review-loop economics"
```

---

## Task 4: `below 3` at the early-exit rule

**Spec:** §2

**Site** — pasted `grep -n`:

```
CLAUDE.md:79:below 3 is a pass with **zero** findings; don't manufacture findings to pad. Codex is
plugins/dev-workflow/commands/workflow-init.md:279:below 3 is a pass with **zero** findings; don't manufacture findings to pad. Codex is
```

- [ ] **Replace, in both copies.** OLD:

```
below 3 is a pass with **zero** findings; don't manufacture findings to pad. Codex is
```

NEW:

```
below the floor is a pass with **zero** findings; don't manufacture findings to pad. Codex is
```

- [ ] **Assert the new text is present.**

```bash
grep -cF -- "below the floor is a pass with" \
  CLAUDE.md plugins/dev-workflow/commands/workflow-init.md
```

Before this task: `0` and `0`. After: `1` and `1`. Verified executable against a simulated post-edit tree — the pattern lies on one line, contains no `**`, and is passed after `--` so a leading `-` cannot be read as an option.

- [ ] **Amend the WIP commit.**

```bash
git add CLAUDE.md plugins/dev-workflow/commands/workflow-init.md
git commit --amend -m "WIP: review-loop economics"
```

---

## Task 5: `3-pass floor` in the incomplete-pass rule

**Spec:** §2

**Site** — pasted `grep -n`:

```
CLAUDE.md:236:act on the partial list, don't count it toward the 3-pass floor, and don't read "no
plugins/dev-workflow/commands/workflow-init.md:421:act on the partial list, don't count it toward the 3-pass floor, and don't read "no
```

- [ ] **Replace, in both copies.** OLD:

```
act on the partial list, don't count it toward the 3-pass floor, and don't read "no
```

NEW:

```
act on the partial list, don't count it toward the floor, and don't read "no
```

- [ ] **Assert the new text is present.**

```bash
grep -cF -- "count it toward the floor" \
  CLAUDE.md plugins/dev-workflow/commands/workflow-init.md
```

Before this task: `0` and `0`. After: `1` and `1`. Verified executable against a simulated post-edit tree — the pattern lies on one line, contains no `**`, and is passed after `--` so a leading `-` cannot be read as an option.

- [ ] **Amend the WIP commit.**

```bash
git add CLAUDE.md plugins/dev-workflow/commands/workflow-init.md
git commit --amend -m "WIP: review-loop economics"
```

---

## Task 6: `3-pass loop` in the Gate-A description

**Spec:** §2

**Site** — pasted `grep -n`:

```
CLAUDE.md:300:- **Gate A — Spec, then plan (TWO runs, each its own 3-pass loop).** Run on the
plugins/dev-workflow/commands/workflow-init.md:485:- **Gate A — Spec, then plan (TWO runs, each its own 3-pass loop).** Run on the
```

- [ ] **Replace, in both copies.** OLD:

```
- **Gate A — Spec, then plan (TWO runs, each its own 3-pass loop).** Run on the
```

NEW:

```
- **Gate A — Spec, then plan (TWO runs, each its own loop at the derived floor).** Run on the
```

- [ ] **Assert the new text is present.**

```bash
grep -cF -- "each its own loop at the derived floor" \
  CLAUDE.md plugins/dev-workflow/commands/workflow-init.md
```

Before this task: `0` and `0`. After: `1` and `1`. Verified executable against a simulated post-edit tree — the pattern lies on one line, contains no `**`, and is passed after `--` so a leading `-` cannot be read as an option.

- [ ] **Amend the WIP commit.**

```bash
git add CLAUDE.md plugins/dev-workflow/commands/workflow-init.md
git commit --amend -m "WIP: review-loop economics"
```

---

## Task 7: The re-review rationale

**Spec:** §2

**Site** — pasted `grep -n`:

```
CLAUDE.md:334:  @AGENTS.md. Re-review after every fix — a fix changes the diff and the hook
plugins/dev-workflow/commands/workflow-init.md:518:  @AGENTS.md. Re-review after every fix — a fix changes the diff and the hook
```

> **Third attempt at one sentence, and both lines are replaced.** The original, `which is where the 3 come from`, was a causal claim the new design makes false. Revision 1 made the hook the *cause* of the obligation. Revision 2 replaced only the second line, leaving `a fix changes the diff and the hook` in front of it, so the sentence read "the hook no longer covers the artifact".
> 
> The claim eliminated is *the hook causes the re-review obligation*. The load-bearing half — `a fix changes the artifact, so the prior review no longer covers it` — stands without the hook; the trailing clause describes what the hook does and is true only while it exists, which is a description, not the cause.

- [ ] **Replace, in both copies.** OLD:

```
  @AGENTS.md. Re-review after every fix — a fix changes the diff and the hook
  invalidates the prior pass, which is where the 3 come from.
```

NEW:

```
  @AGENTS.md. Re-review after every fix — a fix changes the artifact, so the prior
  review no longer covers it. The hook merely notices, at commit time.
```

- [ ] **Assert the new text is present.**

```bash
grep -cF -- "review no longer covers it. The hook merely notices" \
  CLAUDE.md plugins/dev-workflow/commands/workflow-init.md
```

Before this task: `0` and `0`. After: `1` and `1`. Verified executable against a simulated post-edit tree — the pattern lies on one line, contains no `**`, and is passed after `--` so a leading `-` cannot be read as an option.

- [ ] **Amend the WIP commit.**

```bash
git add CLAUDE.md plugins/dev-workflow/commands/workflow-init.md
git commit --amend -m "WIP: review-loop economics"
```

---

## Task 8: The Lenses rule

**Spec:** §2

**Site** — pasted `grep -n`:

```
CLAUDE.md:403:Lenses are **different questions, not more passes.** The 3-pass floor, the Blocker/Major
plugins/dev-workflow/commands/workflow-init.md:582:Lenses are **different questions, not more passes.** The 3-pass floor, the Blocker/Major
```

> **Both lines, for the same reason as the previous task.** The old tail says the floor "is unchanged". Revision 3 replaced the first half and left that tail, so the shipped sentence still told a reader the floor was unchanged in the change that makes it profile-dependent. The claim eliminated is *the floor is unchanged*.

- [ ] **Replace, in both copies.** OLD:

```
Lenses are **different questions, not more passes.** The 3-pass floor, the Blocker/Major
filter, the file-first findings protocol and the clean-final-pass rule are unchanged.
```

NEW:

```
Lenses are **different questions, not more passes** — they change what a pass asks, never
how many a cycle owes. The Blocker/Major filter, the file-first findings protocol and the
clean-final-pass rule are unchanged. The floor is not among them: it is no longer a fixed
number but derives from the profile and the cited set.
```

- [ ] **Assert the new text is present.**

```bash
grep -cF -- "derives from the profile and the cited set" \
  CLAUDE.md plugins/dev-workflow/commands/workflow-init.md
```

Before this task: `0` and `0`. After: `1` and `1`. Verified executable against a simulated post-edit tree — the pattern lies on one line, contains no `**`, and is passed after `--` so a leading `-` cannot be read as an option.

- [ ] **Amend the WIP commit.**

```bash
git add CLAUDE.md plugins/dev-workflow/commands/workflow-init.md
git commit --amend -m "WIP: review-loop economics"
```

---

## Task 9: The pass-1 Minor sentence

**Spec:** §2

**Site** — pasted `grep -n`:

```
CLAUDE.md:126:the only exception, exactly as above; a Blocker/Major-free pass 1 carrying a Minor keeps
plugins/dev-workflow/commands/workflow-init.md:322:the only exception, exactly as above; a Blocker/Major-free pass 1 carrying a Minor keeps
```

> **The sentence that inverts at a floor of 1**, where pass 1 *is* the floor. It contains no digit `3`, so no regex over the other sites reaches it.

- [ ] **Replace, in both copies.** OLD:

```
the only exception, exactly as above; a Blocker/Major-free pass 1 carrying a Minor keeps
```

NEW:

```
the only exception, exactly as above; a Blocker/Major-free pass below the floor
carrying a Minor keeps
```

- [ ] **Assert the new text is present.**

```bash
grep -cF -- "a Blocker/Major-free pass below the floor" \
  CLAUDE.md plugins/dev-workflow/commands/workflow-init.md
```

Before this task: `0` and `0`. After: `1` and `1`. Verified executable against a simulated post-edit tree — the pattern lies on one line, contains no `**`, and is passed after `--` so a leading `-` cannot be read as an option.

- [ ] **Amend the WIP commit.**

```bash
git add CLAUDE.md plugins/dev-workflow/commands/workflow-init.md
git commit --amend -m "WIP: review-loop economics"
```

---

## Task 10: The pass report

**Spec:** §2.2

**Site** — no `grep -n` line, deliberately: this task's target does not exist in the untouched tree. It is the text an earlier task inserts, so it is located by its OLD text below and by nothing else.

> Inserted **before** the existing paragraph, which is not modified — including the `you report the tells` / `report the tells` divergence between the copies, which is pre-existing (accounting rows 5a/5b). Do not harmonize it.

- [ ] **Replace, in both copies.** OLD:

```
**From pass 4 onward every pass report carries three lines.**
```

NEW:

```
**Every pass report states three things about the floor**, from pass 1 onward: the
derived floor, the risk and security values read, and the cited stories they were read
from. A report giving the number alone leaves a reader unable to check the derivation
while passes are still being spent — which is the only time checking it is cheap. Where
no story is cited, or a cited story is unprofiled, the report says so in place of axis
values; a multi-story set names each story and its values. This is owed by every pass;
the three lines below are owed from pass 4 and are a different obligation.

**From pass 4 onward every pass report carries three lines.**
```

- [ ] **Assert the new text is present.**

```bash
grep -cF -- "the cited stories they were read" \
  CLAUDE.md plugins/dev-workflow/commands/workflow-init.md
```

Before this task: `0` and `0`. After: `1` and `1`. Verified executable against a simulated post-edit tree — the pattern lies on one line, contains no `**`, and is passed after `--` so a leading `-` cannot be read as an option.

- [ ] **Amend the WIP commit.**

```bash
git add CLAUDE.md plugins/dev-workflow/commands/workflow-init.md
git commit --amend -m "WIP: review-loop economics"
```

---

## Task 11: A profile or cited set that moves mid-cycle

**Spec:** §2.4

**Site** — pasted `grep -n`:

```
CLAUDE.md:488:discard the accumulated passes.
plugins/dev-workflow/commands/workflow-init.md:667:discard the accumulated passes.
```

> The nine conditions of the `Changing a profile:` paragraph are kept verbatim; §2.4's rules are **appended after them**, never merged in.

- [ ] **Replace, in both copies.** OLD:

```
discard the accumulated passes.

**What this does not do:**
```

NEW:

```
discard the accumulated passes.

**While a gate is running, the floor derives from the current profile at each pass.**
Passes already run keep counting; closing requires the floor as currently derived. These
are pass-count rules, so they apply while a gate is running and are silent otherwise —
what governs when a gate runs is unchanged and deliberately not summarised here.

**Any profile change costs at least one further pass**, in either direction and whether or
not the floor number moves, because the final clean pass must run under the current
profile — so no already-banked pass can be it. That further pass must itself be clean and
every other closure duty must be satisfied; it is one more pass, not a licence to close on
the next one. What a lowering drops is whatever the changed values drop, not a fixed pair:
a mode-only override changes the evidence obligations while leaving the axis-derived lens
sets alone, and security `high` → `standard` keeps the security lens set while changing
what evidence is owed. Every derived obligation is recomputed from the current profile.

**The cited set is re-read at each pass, and the final clean pass runs against the current
set** — whenever its membership changes, not only when the floor number moves. Adding a
high-risk story to a set already at floor 3 leaves the number alone while adding that
story's lens set, its evidence obligations and its review scope; a pass run before it
joined did not cover them. Removing a story recomputes obligations from the current set
and so does remove that story's lenses and evidence duty — but it never discharges an
accepted in-set Blocker or Major: the acceptance put that finding in the fix set, not the
citation.

**What this does not do:**
```

- [ ] **Assert the new text is present.**

```bash
grep -cF -- "Any profile change costs at least one further pass" \
  CLAUDE.md plugins/dev-workflow/commands/workflow-init.md
```

Before this task: `0` and `0`. After: `1` and `1`. Verified executable against a simulated post-edit tree — the pattern lies on one line, contains no `**`, and is passed after `--` so a leading `-` cannot be read as an option.

- [ ] **Amend the WIP commit.**

```bash
git add CLAUDE.md plugins/dev-workflow/commands/workflow-init.md
git commit --amend -m "WIP: review-loop economics"
```

---

## Task 12: Severity semantics

**Spec:** §3

**Site** — pasted `grep -n`:

```
CLAUDE.md:496:  rework) → both must resolve. Minor · Nit → collect, never iterate.
plugins/dev-workflow/commands/workflow-init.md:675:  rework) → both must resolve. Minor · Nit → collect, never iterate.
```

> The four severity definitions stay verbatim; the reachability test is appended as the procedure that sets a **ceiling** on them.
> 
> **Task 12 ships spec §3 and nothing else** — the procedure, the exclusions, the symmetric instrument carve-out, the rationale rule, coverage-first and the kinship sentence. It chooses no precedence against any loop rule and states no consequence for the per-pass counts, the clusters or the stop thresholds. Earlier revisions did, three times, each time reaching past spec §9's exclusion of "the §5 loop-rule consolidation and everything its successor story owns", and each removal found another layer underneath. What remains is one sentence saying the interaction is **not settled here** — a scope disclaimer in §9's own pattern, not a rule.
> 
> **This is the plan's one deliberate divergence between the copies, and it is stated because the constraint above requires that.** `CLAUDE.md` adds a second sentence naming the successor story's path; the scaffolded template does **not**. The template writes a `CLAUDE.md` into somebody else's repository, where `docs/superpowers/stories/…` does not exist and is never scaffolded. What forbids it is the **architecture dependency boundary** — nothing may depend on this repo's internal layout — together with **prompt-standards item 11**, which the scaffolded template must satisfy on its own. (Not invariant 7, which governs `examples/` as read-only reference and says nothing about story paths in templates.) A shipped scaffold citing a path only this checkout has would make every initialized project carry an unresolvable authority for part of its own gate semantics. Both copies carry the disclaimer; only this repo's copy carries the pointer, and the successor story carries the reciprocal so the handoff is named on both sides regardless.

- [ ] **Replace, in both copies.** OLD:

```
  rework) → both must resolve. Minor · Nit → collect, never iterate.
```

NEW:

```
  rework) → both must resolve. Minor · Nit → collect, never iterate.

  **Deciding severity — one procedure. The subject list is illustration, not a second
  rule.** Name what in the system consumes this text — whatever *acts* on it — and the
  decision that act takes differently if the text is wrong. Both are required. If you
  cannot name both, the finding is Minor or below: collect, never iterate.

  The exclusions are contract, not commentary. The reader must consume the text in the
  system's *operation*, not in reviewing it — the review pass raising the finding is not
  an in-system reader of the text it reviews; without this the test demotes nothing.
  Gates remain legitimate readers of rule text they will later apply. A human reader never
  satisfies the test — the prose exemption already prices that cost as non-gating. The
  list of reader kinds is illustrative, not closed, because this ships into projects whose
  readers we have never seen. The test sets a ceiling, not a floor, and never chooses
  between Blocker and Major — the four definitions above still decide that. The instrument
  carve-out is symmetric: an instrument finding keeps its severity whenever it shows the
  instrument changes what a gate concludes about product behaviour — a false green, and
  equally a false red or a check blocking a valid change. Rationale prose is Minor only
  when no rule's application depends on it, not categorically: `docs/prompt-standards.md`
  requires rules to carry their why, so rationale a reader must consult to apply a rule
  passes the test. This removes arbitrariness, not judgement. Coverage-first is unchanged
  — the reviewer reports every finding with severity and confidence; the filter is ours.

  This is the finding-level analog of the path-level prose exemption: one principle at two
  granularities — text that *describes* the product versus text that *is* the product.

  **How this demotion bears on the loop-health measures — the per-pass counts, the finding
  clusters and the stop thresholds — is not settled here, and this change does not settle it.
  Until it is, a pass whose outcome would turn on that question reports the question and
  stops rather than deciding it** — the same answer any unresolved gate question gets.
```

- [ ] **Assert the new text is present.**

```bash
grep -cF -- "what in the system consumes this text" \
  CLAUDE.md plugins/dev-workflow/commands/workflow-init.md
```

Before this task: `0` and `0`. After: `1` and `1`. Verified executable against a simulated post-edit tree — the pattern lies on one line, contains no `**`, and is passed after `--` so a leading `-` cannot be read as an option.

- [ ] **Amend the WIP commit.**

```bash
git add CLAUDE.md plugins/dev-workflow/commands/workflow-init.md
git commit --amend -m "WIP: review-loop economics"
```

---

## Task 13: Activation

**Spec:** §10

**Site** — no `grep -n` line, deliberately: this task's target does not exist in the untouched tree. It is the text an earlier task inserts, so it is located by its OLD text below and by nothing else.

> **Plan B extends this list rather than rewriting it** — §10 says extending is safe and replacing is not.
> 
> The partial-adoption trigger is **semantic, not a list of spellings**. Naming `pass 3`, `below 3` and `3-pass floor` missed the ones a partial merge happens to leave: the Gate-A loop description, the pass-1 closure rule and the re-review rationale each carry a fixed-three claim, and a merge can take some tasks and not others.

- [ ] **Replace, in both copies.** OLD:

```
None of this is a guard: the floor is produced by the agent and nothing checks it against
the cited profiles.
```

NEW:

```
None of this is a guard: the floor is produced by the agent and nothing checks it against
the cited profiles.

**When these rules bind.** From the commit that ships them, and a cycle already running
finishes under the rules it started with. Where a cycle's starting rules cannot be
established it takes the stricter reading of every part this change touches — at minimum
floor 3, and severity classified without the demotion; each further rule this change ships
adds its own strict reading to this list. Not a re-derivation, which could hand a level-0
cycle a floor of 1 and skip passes on the strength of not knowing when it started. A user
knob set above 3 is not lowered by this fallback. A revert is itself a shipping commit for
the old rules, and the activation rule wins wherever the start is determinable; the
fallback covers only where it is not.

**Downstream has no shipping commit.** Adoption binds from the `/workflow-init` run that
actually writes the text — which may write nothing, be declined, or be merged in part —
so these rules bind only over the text a project's `CLAUDE.md` actually contains, and a
partial adoption can persist undetected. A project taking the floor rule without the
severity test gets a floor whose docs-only question the severity test is what settles.
**A partial adoption can leave a project's floor undefined or self-contradictory.** The rule
is a coherence requirement, stated semantically rather than as a list of spellings, and it
runs in **both** directions: **exactly one definition of the floor must be present, and every
statement that defines or constrains the floor, or makes closing depend on it, must resolve to
that one definition.** **The unknown-start fallback is not a second definition**: it is
explicitly conditional on a cycle's starting rules being undeterminable and governs only that
state, so it coexists with the predicate rather than competing with it. Everything else
likewise keeps its own footing and is **not** required to derive from the floor: **the other closure and stop predicates** — assigned-fix-set membership, a new
structural question, an accepted Blocker or Major, the tell thresholds; **independent reporting
and diagnostic ordinals**, such as a duty owed from a given pass onward; and **the hook's
reminder threshold together with any descriptive or historical pass number**, which say what a
tool reports or what once happened rather than what a cycle owes. Four states break it, and the list is **not exhaustive**: a fixed-number or
specific-pass obligation surviving beside the derived predicate; a claim or dependency on a
derived floor with no predicate to define it; **no definition at all**; and **two definitions
at once**. A
merge can produce any of them: the Gate-A loop description, the pass-1 closure rule and the
re-review rationale each carry a fixed-three claim and can be taken or left independently of
the predicate itself. In any such state nothing here resolves which rule governs: **stop, and
have a human complete or revert the adoption, before running a gate under it.** What prompt text can do about downstream
adoption is limited, and that limit is what this paragraph states.
```

- [ ] **Assert the new text is present.**

```bash
grep -cF -- "a cycle already running" \
  CLAUDE.md plugins/dev-workflow/commands/workflow-init.md
```

Before this task: `0` and `0`. After: `1` and `1`. Verified executable against a simulated post-edit tree — the pattern lies on one line, contains no `**`, and is passed after `--` so a leading `-` cannot be read as an option.

- [ ] **Amend the WIP commit.**

```bash
git add CLAUDE.md plugins/dev-workflow/commands/workflow-init.md
git commit --amend -m "WIP: review-loop economics"
```

---

## Task 14: The successor pointer — `CLAUDE.md` only

**Spec:** §9 deferral

**Site** — no `grep -n` line, deliberately: this task's target does not exist in the untouched tree. It is the text an earlier task inserts, so it is located by its OLD text below and by nothing else.

> **This task edits one copy and not the other, and that is the whole point.** The previous task's disclaimer ships to both. This pointer names a path that exists only in this repository, so it must **not** reach the scaffolded template — that template writes a `CLAUDE.md` into somebody else's project, and a shipped rule citing a path only this checkout has would leave every initialized project holding an unresolvable authority for part of its own gate semantics.
> 
> The handoff is still named on both sides regardless of which copy a reader holds: the successor story carries the reciprocal obligation in its own §4.

- [ ] **Replace, in `CLAUDE.md` only.** OLD:

```
  stops rather than deciding it** — the same answer any unresolved gate question gets.
```

NEW:

```
  stops rather than deciding it** — the same answer any unresolved gate question gets.
  That question is owned by the loop-rule consolidation work in
  `docs/superpowers/stories/2026-08-29-loop-rule-consolidation-story.md`.
```

- [ ] **Assert the new text is present in `CLAUDE.md`, and absent from the template.**

```bash
grep -cF -- "owned by the loop-rule consolidation work" \
  CLAUDE.md plugins/dev-workflow/commands/workflow-init.md
```

Before this task: `0` and `0`. After: **`1` and `0`** — the divergence is the point, and the second number is as load-bearing as the first.

- [ ] **Amend the WIP commit.**

```bash
git add CLAUDE.md
git commit --amend -m "WIP: review-loop economics"
```

---

## Task 15: The battery, and the hand-off to Plan B

Plan A runs no Gate-B cycle. The single cycle covering all three plans opened at Task 1 and is
reviewed and closed by Plan C.

- [ ] **Run the battery, minus one step, for a stated reason**

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

> **`sh scripts/check-version-bump.sh main` is deliberately absent, and only that one step.** Plan
> A changes a path under `plugins/dev-workflow/` while the manifest bump is Plan C's, so the
> checker **would correctly fail here**. `AGENTS.md` states its precondition: it compares
> *commits*, and run mid-work it reports clean and uselessly. **This is a deferral of one step
> with a named reason, not licence to skip the rest** — `scripts/check-version-bump.test.sh`, the
> suite, still runs, because it does not depend on the working tree's bump state.

- [ ] **Hand off to Plan B**

Plan B amends the same WIP commit with the same message and uses the base SHA Task 1 printed.
Plan A's Gate-A loop must have closed first.

---

## Self-Review

**Spec coverage.** §2 → Tasks 1–9. §2.1 → Tasks 1–2. §2.2 → Task 10. §2.4 → Task 11. §3 → Task
12. §10 activation, revert, downstream adoption, gate-off surface → Tasks 2 and 13, partial by
design and written to be extended by Plan B. The §9 deferral → Tasks 12 and 14. §2.3, §4, §5,
§6 → Plan B. §7, §8 → Plan C, with the five relocated obligations named above.

**Placeholders.** None.

**Type consistency.** `max(risk, security)`, "derived floor", "reminder threshold", "cited set"
and "level 0" are used identically throughout and match the spec's spellings.

**Known limit.** The replacement wordings are proposals, not transcriptions — the spec pins the
rules, not the sentences. Gate B, reading the real edits, is what checks what they do to the
shipped files; this plan's own check per task establishes only that each edit landed at its
site.
