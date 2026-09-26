# Conditions inventory — §5 review-loop closure rules

**What this is.** The id definition behind the old-conditions accounting in
`docs/superpowers/specs/2026-09-10-loop-rule-consolidation-design.md` §5. That accounting marks
every condition `a1`…`j4` kept, moved, replaced or dropped; without this file the ids name
nothing a reader can audit, and an omitted condition is indistinguishable from an undefined id.
It is committed for that reason and for no other: it is a **snapshot**, not a live document.
Taken 2026-09-10 against the tree at `7c0d475` (main, plugin 0.11.0), before any edit of this
change landed. Line numbers therefore cite that tree and will drift; the spec's own line
citations are re-read at execution, and this file is not. A condition here is a claim about the
text as it stood at `7c0d475`, so where the two disagree the tree wins and the accounting is
what needs correcting.

Read-only inventory taken on branch `loop-rule-consolidation` at
the repository root. No repo file was modified.

Two copies of §5 exist and are compared throughout:

- **C** = `CLAUDE.md` (canonical, 1068 lines)
- **W** = `plugins/dev-workflow/commands/workflow-init.md`
  (scaffolded template, 1925 lines)

Parity method: the corresponding line ranges were extracted and `diff -u`'d, so
"identical" below means byte-identical over the stated range, not merely
similar-looking. Line-wrapping differences are reported because they are real
byte differences even where the words match; they are flagged as such.

Condition numbering is stable: the spec may cite `a1`, `c9`, `h17` etc. Every
condition is quoted with its operative phrase in backticks. Negations and
exceptions are numbered as conditions in their own right.

**Total conditions listed: 135** (a 22 · b 18 · c 20 · d 7 · e 11 · f 7 · g 4 ·
h 26 · i 16 · j 4).

---

## Passage (a) — the HARD FLOOR paragraph + "The derived floor is the pass count a cycle owes"

**Line ranges**

| File | Range | Notes |
|---|---|---|
| C | **72–136** | para 1 = 72–121 (`**Both gates are a LOOP with a HARD FLOOR…`), blank 122, para 2 = 123–136 (`**The derived floor is the pass count a cycle owes…`) |
| W | **279–343** | para 1 = 279–328, blank 329, para 2 = 330–343 |

**Scope note.** Per the task, the floor-derivation *arithmetic* in para 1
(C 74–86, 96–116 — the max(risk, security) mapping, the `Story:` header
authority, the entry grammar, the per-cycle-kind governing header) is **not**
enumerated here. It is normative and will still need its own inventory if the
successor touches it. The conditions below are the ones that state how the loop
**closes, exits, or is stopped**, plus the sentences in para 1 that decide
whether a pass counts as the cycle's *final* pass — those are closure rules
living inside the arithmetic paragraph and would otherwise be lost.

**Conditions**

- **a1** — `Both gates are a LOOP with a HARD FLOOR: a minimum number of passes per run` — the floor is a *minimum pass count per run*, not a target.
- **a2** — `(Blocker/Major only)` — the floor's pass-counting filter is Blocker/Major only.
- **a3** — `A change to a profile or to the set therefore binds every open and future cycle — a raise costs an affected open cycle a further pass under the current profile, as the profile-change rule below requires`.
- **a4** — `a cycle that has already closed stands, its close having been valid under the profile current when it closed, which is the cycle-level form of passes already run keeping their count` — a closed cycle is never reopened by a later profile/set change.
- **a5** — `Some states derive **no** value rather than a second one, and each stops rather than defaulting: governing headers that disagree; a cited profile that is present but unresolvable; and a `Story:` header that cannot be read.` — three named stop states.
- **a6** — `Where they name different sets the premise of a single value has failed: **stop and surface the disagreement** rather than deriving from either, exactly as an unresolvable profile stops rather than defaulting.`
- **a7** — `Before each pass the deriving agent compares every such set, and again before a clean pass is accepted as the cycle's final pass.` — two distinct comparison points, the second being a closure precondition.
- **a8** — `A header or profile that changed during that pass means the pass is not final — the same answer a change gets at every other read point.`
- **a9** — `The derived floor is the pass count a cycle owes`.
- **a10** — `the hook's ratio is a reminder threshold that controls nothing`.
- **a11** — `a satisfied count is not a clean review`.
- **a12** — `a below-threshold reminder is noted in the pass report and disregarded where the cycle's own closure rules are satisfied` — two duties: note it, *and* disregard it under that condition.
- **a13** — `This replaces the pass-count number and nothing else. Every other rule stated here about how a cycle closes stands as written, and none of them is restated — a summary is where their conditions would get dropped.` — a standing prohibition on restating/summarising the closure rules. **Directly relevant to the successor: a single consolidated ordering must not read as a restatement that drops conditions.**
- **a14** — `Nothing here writes the floor knob: it stays the user's, never written, never removed, never read for this derivation.`
- **a15** — `Open a TodoWrite "Codex pass N" per pass`.
- **a16** — `fix Blocker/Major after each`.
- **a17** — `Your final pass must be clean`.
- **a18** — `if the pass at the floor still finds Blocker/Major, keep going until clean or clearly stuck → then STOP and surface to the user`.
- **a19** — `The only early exit below the floor is a pass with **zero** findings`.
- **a20** — `don't manufacture findings to pad`.
- **a21** — `Codex is advisory — validate before applying`.
- **a22** — `dismissed finding → one-line why`.

**Parity differences**

**None.** C 72–136 and W 279–343 are byte-identical.

---

## Passage (b) — "**What a loop absorbs, and what stops it**"

**Line ranges**

| File | Range |
|---|---|
| C | **195–223** |
| W | **402–426** |

**Conditions**

- **b1** — `A finding that corrects the correction you just made **and stays inside the assigned fix set** is **inside this loop's scope**` — two conjuncts; ancestry alone is not enough.
- **b2** — `keep it here rather than handing it back`.
- **b3** — `then act on it by its severity exactly as Mechanics already says — Blocker/Major resolve, Minor/Nit collect and never iterate` (W says `exactly as the severity rule already says` — see parity).
- **b4** — `Ancestry decides where a finding belongs; it never decides what you do with it`.
- **b5** — `it grants no Minor or Nit a repair round it would not otherwise get`.
- **b6** — `The assigned fix set is fixed before the pass you are answering`.
- **b7** — the set `is the scope the approved story or plan assigns to this cycle, plus repair obligations you already accepted in earlier passes` — two components.
- **b8** — `A finding is in-set when repairing it stays inside that scope`.
- **b9** — `never merely because it arrived in the current pass, which would put every new finding in the set by definition and leave the boundary deciding nothing`.
- **b10** — `Where membership is genuinely unclear treat the finding as **outside**, which costs a question and never a silent expansion.`
- **b11** — `A correction that leaves that set stops the loop like any other out-of-scope finding`, **`even when it opens no new question at all`** — the qualifier is load-bearing.
- **b12** — `it resumes the moment the user says whether the set now includes it`.
- **b13** — `A finding that opens a **new structural or contract question** stops the loop and goes to the user`.
- **b14** — `size is not the test, novelty of the question is`, so `a structural finding that is genuinely small still stops it`.
- **b15** — `a long correction still aimed at the last correction does not [stop the loop] — provided that correction, too, stays inside the set, which its ancestry never supplies on its own`.
- **b16** — `When a finding is both … **the new question wins and the loop stops**: novelty overrides correction ancestry`.
- **b17** — `Stopping this way is **not an exit from the gate**: the floor, the Blocker/Major filter and the clean-final-pass rule all stand`.
- **b18** — `the loop resumes on the revised artifact once the question is answered`.

**Parity differences** (three; C first, W second)

1. **Cross-reference target.**
   C: `then act on it by its severity exactly as **Mechanics** already says — Blocker/Major resolve, Minor/Nit collect and never iterate.`
   W: `then act on it by its severity exactly as **the severity rule** already says — Blocker/Major resolve, Minor/Nit collect and never iterate.`
   (Deliberate: the scaffolded template does not name this repo's `### Mechanics (reference)` heading.)
2. **Intensifier dropped.**
   C: `because absorbing on ancestry is **exactly** how a contract decision gets made without anyone choosing it.`
   W: `because absorbing on ancestry is how a contract decision gets made without anyone choosing it.`
3. **Closing rationale reworded, and the field-mint parenthetical exists in C only.**
   C: `the loop resumes on the revised artifact once the question is answered — **what the stop prevents is a loop committing you to a design you never chose, which is a different failure from an unfinished review.** (Field-minted in `infinite-portfolio-canvas` and carried here because the alternative was observed there: handing back a three-line repair-of-a-repair wastes a session, and absorbing a contract question spends a decision that was not the loop's to make.)`
   W: `the loop resumes on the revised artifact once the question is answered. **What it prevents is a loop committing you to a design nobody chose — a different failure from an unfinished review.**` — **the whole `(Field-minted in infinite-portfolio-canvas …)` sentence is absent from W.**

---

## Passage (c) — "**Recognizing \"clearly stuck\"**" incl. "**Surfacing does not close the cycle**"

**Line ranges**

| File | Range |
|---|---|
| C | **225–246** (stuck-reading 225–241; `**Surfacing does not close the cycle…` 242–246) |
| W | **428–449** (stuck-reading 428–444; surfacing 445–449) |

**Conditions**

- **c1** — `Read the **Blocker curve across passes**, not any single pass's total`.
- **c2** — `it is the better of the two signals, the total says less than it looks like, and one low count is a snapshot rather than a plateau`.
- **c3** — `**Neither curve measures coverage:** a low Blocker count can sit beside an entirely unreviewed subsystem.`
- **c4** — `this exit needs three things **together**, and a missing one means keep going`.
- **c5** — condition 1: `a plateau visible across passes (six or more is where the field saw one)`.
- **c6** — condition 2: `an **affirmative judgement that coverage is sufficient**, stated` — it must be *stated*, not merely held.
- **c7** — `a known materially unreviewed area forbids this exit outright, and disclosing it does not license it`.
- **c8** — condition 3: `**Blocker or Major findings that keep regenerating across genuine repair attempts**, each round's fix producing the next`.
- **c9** — `**a clean completion takes precedence over this exit**`.
- **c10** — `a Blocker/Major-free pass **at or above the floor** has satisfied the clean-final-pass rule — collect the Minors and Nits and close`.
- **c11** — `reporting "will not converge" on a converged loop is a false report`.
- **c12** — `**Below the floor nothing closes**`.
- **c13** — `a zero-finding pass remains the only exception, exactly as above` (cross-references **a19**).
- **c14** — `a Blocker/Major-free pass below the floor carrying a Minor keeps looping`.
- **c15** — `**Surfacing does not close the cycle, and that is what makes this reachable.**`
- **c16** — `You surface *with the finding still open*`.
- **c17** — `the resolve rule is not waived`.
- **c18** — `no pass is credited as clean`.
- **c19** — `the loop resumes on whatever the user decides`.
- **c20** — `Reading it as "stop instead of fixing" would put the exit in competition with the rule that every Blocker and Major resolves, and then nothing could satisfy both.` — an explicit prohibition on the "stop instead of fixing" reading.

**Parity differences**

**None in the passage text** — C 225–246 and W 428–449 are byte-identical.

**One structural difference immediately after the passage:**
C has **no blank line** between C:246 (`…nothing could satisfy both.`) and C:247
(`**Every pass report states three things about the floor**…`) — the two run
together as one markdown paragraph. W has a **blank line at W:450**, so in the
template the surfacing block and the floor-reporting duty are separate
paragraphs. (Confirmed by blank-line map: C blanks at 254/262/269/274; W blanks
at 450/458/466/484.)

---

## Passage (d) — "**From pass 4 onward every pass report carries three lines.**"

**Line ranges**

| File | Range |
|---|---|
| C | **255–261** |
| W | **459–465** |

**Conditions**

- **d1** — `From pass 4 onward every pass report carries three lines.`
- **d2** — `The carrier is **your own status report to the user**`.
- **d3** — `never the Codex reply, which stays exactly one line per branch`.
- **d4** — `never the findings file, which admits no line that is not a finding or the terminator`.
- **d5** — line (1): `the **trend** — findings and Blocker counts across the passes so far`.
- **d6** — line (2): `where this pass's findings **cluster** — product behaviour, the test instrument, or prose about either`.
- **d7** — line (3): `any **require↔withdraw pair** against earlier passes, meaning a pass demanding what an earlier pass had removed`.

**Parity differences**

**Wording: none.** The two copies differ only in where lines wrap
(C `…across the passes` / `so far;` vs W `…across the passes so` / `far;`, and
likewise at `the test instrument, / or prose` and `meaning a / pass demanding`).
Same words, same order.

---

## Passage (e) — "Those three lines expose **five tells**"

**Line ranges**

| File | Range |
|---|---|
| C | **263–268**, plus the C-only rationale paragraph at **270–273** |
| W | **467–472** (no rationale paragraph) |

**Conditions**

- **e1** — `Those three lines expose **five tells**`.
- **e2** — tell 1: `the finding count rising rather than falling`.
- **e3** — tell 2: `the Blocker count failing to fall`.
- **e4** — tell 3: `findings clustering on the **instrument** rather than on product behaviour`.
- **e5** — tell 4: `findings clustering on **prose about** either`.
- **e6** — tell 5: `a require↔withdraw pair`.
- **e7** — `**Any two present makes stop-and-surface mandatory, not discretionary**`.
- **e8** — `you report the tells and hand the decision to the user` (W: `report the tells…`).
- **e9** — `the "clearly stuck" reading above is not a precondition for it`.
- **e10** — `A loop can be worth stopping long before it plateaus.`
- **e11** — (**C only**, 270–273) `That is why this is a reporting obligation with a mandatory threshold and not another heuristic to weigh.` — with its stated provenance `Recorded rationale, from the maintainer rather than from a measurement of this repo: in the Bricks consumer all five signals were measurable by **day two** of a week-long loop, and the cost was never detection — it was the absence of a duty to say so.`

**Parity differences** (two)

1. **Pronoun dropped.**
   C: `— **you report** the tells and hand the decision to the user`
   W: `— **report** the tells and hand the decision to the user`
2. **Whole paragraph exists in C only** (C 270–273):
   `Recorded rationale, from the maintainer rather than from a measurement of this repo: in the Bricks consumer all five signals were measurable by **day two** of a week-long loop, and the cost was never detection — it was the absence of a duty to say so. That is why this is a reporting obligation with a mandatory threshold and not another heuristic to weigh.`
   W has no counterpart, and **no blank line** between W:472 and W:473 — in the
   template the five-tells paragraph and passage (f) are one continuous block.

---

## Passage (f) — "**The two rules above do not compete**"

**Line ranges**

| File | Range |
|---|---|
| C | **275–287** |
| W | **473–483** |

**Conditions**

- **f1** — `**The two rules above do not compete**, and neither overrides the other`.
- **f2** — `the absorb rule decides whether *a finding* is inside this loop's scope`.
- **f3** — `this reading decides whether *the loop* can still converge`.
- **f4** — `A small correction-of-a-correction that stays inside the assigned fix set is absorbed and is not by itself evidence of a plateau.`
- **f5** — `the late Blockers were semantic contradictions rather than wording, which is why a low count is a signal to read and not a clearance`.
- **f6** — `Hence the sizing guidance: prefer **smaller specs with named interfaces** and let the plan carry the detail — **guidance, not a threshold**, because where the plateau starts is unmeasured.`
- **f7** — (**C only**) `That a round regenerates roughly half the findings it closes is a **hypothesis** in that record rather than a measurement; one lineage was established (the last pass's Blocker came from the previous pass's fix).` — an evidential qualifier that constrains how the curve may be cited.

**Parity differences** (three)

1. **Evidence framing.**
   C: `The field measurement behind it, quoted at the precision its own record keeps: nineteen Gate-A passes…`
   W: `Measured once, at the precision the record keeps: nineteen Gate-A passes…`
2. **The hypothesis qualifier is C-only.** C: `That a round regenerates roughly half the findings it closes is a **hypothesis** in that record rather than a measurement; one lineage was established (the last pass's Blocker came from the previous pass's fix).` — absent from W entirely.
3. **Punctuation/clause boundary around the late-Blockers claim.**
   C: `Blockers from 11 to 0–1 from pass 7 on **— and** the late Blockers were semantic contradictions rather than wording**,** which is why a low count is a signal to read and not a clearance.`
   W: `Blockers from 11 to 0–1 from pass 7 on**,** and the late Blockers were semantic contradictions rather than wording **—** which is why a low count is a signal to read and not a clearance.`

---

## Passage (g) — Mechanics · Severity bullet · "**How this demotion bears on the loop-health measures**"

**Line ranges**

| File | Range |
|---|---|
| C | **810–815** |
| W | **996–999** |

**Conditions**

- **g1** — `How this demotion bears on the loop-health measures — the per-pass counts, the finding clusters and the stop thresholds — is not settled here, and this change does not settle it.` — three named unsettled surfaces.
- **g2** — `Until it is, a pass whose outcome would turn on that question reports the question and stops rather than deciding it` — two duties: report, and stop.
- **g3** — `the same answer any unresolved gate question gets`.
- **g4** — (**C only**) `That question is owned by the loop-rule consolidation work in `docs/superpowers/stories/2026-08-29-loop-rule-consolidation-story.md`.`

**Parity differences** (one — the expected deliberate one)

C 814–815 carry the ownership sentence naming
`docs/superpowers/stories/2026-08-29-loop-rule-consolidation-story.md`; W ends
at `— the same answer any unresolved gate question gets.` and names no story
path. This is the known deliberate difference; **g4 is the condition the
successor discharges**, so removing it in C without removing the corresponding
duty in W would desynchronise the two copies in the opposite direction.

---

## Passage (h) — Mechanics · "**Recording a human exception.**"

**Line ranges**

| File | Range |
|---|---|
| C | **977–1033** |
| W | **1161–1217** |

**Conditions**

- **h1** — trigger: `Where a human decides that something **no applicable rule required** was nonetheless worth skipping — an optional check this environment cannot run, a review someone asked for and then stood down, a courtesy step — that decision goes in the closing commit body`.
- **h2** — the fixed three-line form: `Human exception: <handle> · <date>` / `Not done: <what was skipped, specifically>` / `Accepted because: <one line>`.
- **h3** — destination: `an ungated change records it in that commit`.
- **h4** — destination: `a Gate-A cycle in the spec or plan commit`.
- **h5** — destination: `a Gate-B cycle in the WIP commit, restated by the closing amend`.
- **h6** — `Several records accumulate; order means nothing.`
- **h7** — late decision: `**A decision made after its commit closed** — during PR review, say — goes in whichever of these exists: the next commit on the branch, the squash body, or a follow-up commit after the merge.`
- **h8** — `If none does — the branch is closed, unmerged, and heading for an ordinary or rebase merge — **add a commit for it.**`
- **h9** — `An empty commit carrying only the record is a legitimate destination: it changes no content, so it raises no review obligation.`
- **h10** — `**Do not expect silence from the gate hook, and do not read a reminder as a gate reopening.**`
- **h11** — `It is advisory, so it never blocks the commit attempt.`
- **h12** — `What is exempt is the **empty diff**, which `git show --stat` confirms — never a reminder that merely looks the same on a commit carrying content.`
- **h13** — `Copy every record into the squash body alongside the evidence entry (Mechanics, squash-merge carry).` — links to **j1**.
- **h14** — `**Nothing performs that carry and nothing checks afterwards that it happened** — it is on whoever prepares the merge.`
- **h15** — `If two copies of one record disagree, that is a copying error: stop and fix it rather than picking one.`
- **h16** — `**Scope, and it is narrow. This form supplies no permission.** It records a decision that was already the human's to make about something genuinely optional.`
- **h17** — `It is **never** the answer to a below-floor pass, an unclean final pass, a `STOP and surface`, a Gate-A or Gate-B obligation, or a profile-derived evidence requirement` — five named non-uses. **The successor's new "decline" record type reuses this transport and must be checked against each of the five.**
- **h18** — `**it authorizes nothing that any mandatory rule in this file or in `AGENTS.md` requires.**`
- **h19** — `Those have their own terminal actions and this paragraph changes none of them: on a STOP you still stop, and neither a human's assent nor this record lets an agent close or continue a cycle.`
- **h20** — `**"Mandatory" is not limited to this file.** A rule in `AGENTS.md`, a project doc, CI, a branch policy or the platform is equally out of reach`.
- **h21** — `under **Wait for**, `docs/pr-review-bots.md` requires a bot review unless an explicit recorded human decision permits proceeding without it, and this form is not that decision`.
- **h22** — `If you are reaching for it to get past something mandatory, the answer is no — take the operational route or stop.`
- **h23** — `**Nor is it for things that were simply never owed.** An absent review from a bot routed **opportunistically** blocks nothing and needs no exception and no record`.
- **h24** — `Record a decision, not a non-event.`
- **h25** — `**What the record is worth.** It is an **unverified assertion**, and reads as one: nothing checks that the handle belongs to whoever decided, that a human was asked, or that the reason is honest.`
- **h26** — `It supports no claim of authorization or review, and satisfies no evidence obligation. It exists because an exception nobody wrote down is invisible, not because writing it down makes it sound.`

**Parity differences**

**None.** C 977–1033 and W 1161–1217 are byte-identical.

---

## Passage (i) — "**When these rules bind.**" (unknown-start fallback)

**Line ranges**

| File | Range |
|---|---|
| C | **153–167** |
| W | **360–374** |

**Conditions**

- **i1** — `From the commit that ships them`.
- **i2** — `a cycle already running finishes under the rules it started with`.
- **i3** — `Where a cycle's starting rules cannot be established it takes the stricter reading of every part this change touches`.
- **i4** — the strict-reading list, item 1: `at minimum floor 3`.
- **i5** — item 2: `severity classified without the demotion`.
- **i6** — item 3: `the provenance-line duty owed`.
- **i7** — item 4: `the curve duty owed`.
- **i8** — item 5: `the nonce duties at their strictest`.
- **i9** — `the cycle is treated as post-rule, so it owes a nonce, owes its provenance line and its curve or skip record, and uses that nonce in every cycle record it does write`.
- **i10** — `which changes what a record is named, never whether one is owed, so the working record stays optional and a skipped cycle still writes no findings slots`.
- **i11** — `Where it cannot recover a nonce it starts a new cycle rather than claiming `none (pre-rule)`, that reserved field being unavailable to a cycle whose start cannot be established`.
- **i12** — `**Each further rule this change ships adds its own strict reading to this list.**` — **this is the extension point the successor uses; the list at i4–i8 is open by construction.**
- **i13** — `Not a re-derivation, which could hand a level-0 cycle a floor of 1 and skip passes on the strength of not knowing when it started.`
- **i14** — `A user knob set above 3 is not lowered by this fallback.`
- **i15** — `A revert is itself a shipping commit for the old rules`.
- **i16** — `the activation rule wins wherever the start is determinable; the fallback covers only where it is not`.

**Parity differences**

**None.** C 153–167 and W 360–374 are byte-identical.

---

## Passage (j) — Mechanics · the squash-merge carry sentence

**Line ranges**

| File | Range |
|---|---|
| C | **892** (single line) |
| W | **1076** (single line) |

**Conditions**

- **j1** — `On squash-merge, copy every evidence entry, every human-exception record, the provenance lines, the curves and any skipped cycle's skip record … in the squash range into the squash body` — five enumerated record kinds, scoped to *the squash range*.
- **j2** — `TOGETHER WITH THE SKIP REASON IT POINTS AT` (capitalised in source).
- **j3** — `a skip record carried without its reason is a pointer into a body the squash has made unreachable`.
- **j4** — `the squash commit is the only body the merge carries into `main`'s history, so anything left behind is unreachable from it`.

**Parity differences**

**None.** C:892 and W:1076 are byte-identical.

---

## Other sites

Every other place in either file that states which exit closes or suspends a
cycle, or that ranks one rule over another. Grepped for: `clean completion`,
`outranks`, `takes precedence`, `close the cycle`, `closes a cycle`,
`cycle-closing`, `suspend`, `stop and surface` / `STOP and surface` /
`stop-and-surface`, plus `closure`, `final clean pass`, `early exit`,
`toward the floor`, `at or above the floor`, `exit the loop`, `licence to close`.
(`outranks` and `suspend` occur **nowhere** in either file.) Hits already inside
passages (a)–(j) are omitted.

### Closure / stop statements

| # | C | W | Sentence |
|---|---|---|---|
| o1 | **63** | **262** | `The work loop includes the review gates: **spec ready → Gate A (spec) → plan ready → Gate A (plan) → execute → tests green → Gate B → commit** (see §5).` — the only place stating the gate *sequence* as an ordering. |
| o2 | **181–185** | **388–392** | `Everything else likewise keeps its own footing and is **not** required to derive from the floor: **the other closure and stop predicates** — assigned-fix-set membership, a new structural question, an accepted Blocker or Major, the tell thresholds; **independent reporting and diagnostic ordinals**, such as a duty owed from a given pass onward; and **the hook's reminder threshold together with any descriptive or historical pass number**…` — **names four closure/stop predicates as a set and asserts they are independent of the floor. The successor's single ordering must not collapse them into the floor.** |
| o3 | **189–192** | **396–399** | `A merge can produce any of them: the Gate-A loop description, **the pass-1 closure rule** and the re-review rationale each carry a fixed-three claim… In any such state nothing here resolves which rule governs: **stop, and have a human complete or revert the adoption, before running a gate under it.**` |
| o4 | **566** | **757** | `Ask for one line per finding and a literal `NO FINDINGS` when a pass is clean — **the explicit clean signal is what lets you exit the loop**` (Gate-A bullet). |
| o5 | **573** | **764** | `Each pass: validate, revise, re-run.` (Gate-A bullet — the loop's per-pass cadence.) |
| o6 | **583–584** | **774–775** | `Re-review after every fix — a fix changes the artifact, so the prior review no longer covers it. The hook merely notices, at commit time.` (Gate-B bullet.) |
| o7 | **484–486** | **676–678** | `Anything else … — is an **INCOMPLETE pass**, which is not a review: **don't act on the partial list, don't count it toward the floor, and don't read "no Blocker/Major visible" as clean.**` |
| o8 | **514–515** | **706–707** | `Spent and still incomplete → **STOP and surface**, naming which check failed.` (recovery budget.) |
| o9 | **410–411** | **604–605** | `a working record left by a closed cycle is not one either, which is why that record is **retired at closure** rather than left to be found later.` |
| o10 | **654–655** | **840–841** | `The Blocker/Major filter, the file-first findings protocol and the clean-final-pass rule are unchanged. The floor is not among them: it is no longer a fixed number but derives from the profile and the cited set.` |
| o11 | **664–670** | **850–856** | `The cited path **does not yield a readable story file** → **stop and surface which of these it was**…` (profile-reading case 3.) |
| o12 | **717–719** | **903–905** | `An **unobservable counterfactual is a blocking evidence gap**, not a free pass — **stop and surface**; the human may then lower the mode as a logged override.` |
| o13 | **727–730** | **913–916** | `…**revalidated before every Gate-B re-review and before the cycle-closing amend** … If revalidation changes the entry, **the clean pass no longer covers what is being committed: fix, re-review, close on the entry that pass validated.**` |
| o14 | **749–752** | **935–938** | `Passes already run under the lower profile **keep counting** toward the floor; only the **final clean pass** must run under the current profile. Inside an active Gate-B cycle, fold the edit into the active `WIP:` snapshot by amend — **a non-`WIP` commit reads to the hook as the cycle closing and would discard the accumulated passes.**` |
| o15 | **755–758** | **941–944** | `**While a gate is running, the floor derives from the current profile at each pass.** Passes already run keep counting; **closing requires the floor as currently derived.**` |
| o16 | **760–764** | **946–950** | `**Any profile change costs at least one further pass** … because the final clean pass must run under the current profile — so no already-banked pass can be it. **That further pass must itself be clean and every other closure duty must be satisfied; it is one more pass, not a licence to close on the next one.**` |
| o17 | **769–773** | **955–959** | `**The cited set is re-read at each pass, and the final clean pass runs against the current set** — whenever its membership changes, not only when the floor number moves… but **it never discharges an accepted in-set Blocker or Major: the acceptance put that finding in the fix set, not the citation.**` |
| o18 | **692–698** | **878–884** | `The **skip reason is recorded in the commit body** … **A skip removes the review, never the evidence** … **Neither is excused the records every cycle owes** — the provenance line, and a skip record in place of the curve.` (Gate-B triviality skip — the fourth way a cycle ends without passes.) |
| o19 | **783–784** | **969–970** | `**Severity:** Blocker (wrong/unsafe/breaks invariant) · Major (design flaw → rework) → **both must resolve**. Minor · Nit → **collect, never iterate**.` — the standing duty **b3**, **c17** and **c20** point at. |
| o20 | **788–789** | **974–975** | `If you cannot name both, the finding is Minor or below: collect, never iterate.` (severity demotion — the rule whose loop-health effect **g1** leaves unsettled.) |
| o21 | **825–826** | **1009–1010** | `A pre-review snapshot named anything else reads as a real commit and **closes the cycle, discarding the passes you just accumulated.**` |
| o22 | **827–829** | **1011–1013** | `**Finishing the cycle:** after the final clean pass, close it with `git commit --amend -m "<real message>"` — that replaces the WIP commit, and **the hook reads the amend as the real cycle-closing commit.**` |
| o23 | **885–890** | **1069–1074** | `**A project whose text carries some of them and not others, or carries all of them in versions that disagree, stops and has a human complete, revert or reconcile the adoption before running a gate under it**` (records-contract partial-adoption stop). |
| o24 | **174–178, 191–192** | **381–385, 398–399** | `**A partial adoption can leave a project's floor undefined or self-contradictory.** … **exactly one definition of the floor must be present, and every statement that defines or constrains the floor, or makes closing depend on it, must resolve to that one definition.**` — **the coherence requirement the successor's single ordering must itself satisfy.** |
| o25 | **178–180** | **385–387** | `**The unknown-start fallback is not a second definition**: it is explicitly conditional on a cycle's starting rules being undeterminable and governs only that state, so it coexists with the predicate rather than competing with it.` |
| o26 | **1011** (in h) | **1195** (in h) | `It is **never** the answer to a below-floor pass, an unclean final pass, a `STOP and surface`…` — listed here too because it is the only cross-reference from Mechanics back to the loop's four exits. |

### "Takes precedence" / ranking statements

Only **two** ranking claims exist across both files, and both are inside the
passages above:

- **C:235 / W:438** — `a clean completion takes precedence over this exit` (= **c9**).
- **C:275 / W:473** — `**The two rules above do not compete**, and neither overrides the other` (= **f1**).

`outranks` appears nowhere in either file. The phrase `takes precedence` also
appears once as a back-reference at **C:140 / W:347** — `what makes that
tolerable is **the precedence rule above** plus the hook exiting 0 on every
branch, not the reminder being harmless` (the "Named residual" paragraph,
C 138–141 / W 345–348, pointing at **a12**). That paragraph is byte-identical
between the copies.

### Adjacent duty not inside (a)–(j), flagged because the successor will sit next to it

**C 247–253 / W 451–457** — `**Every pass report states three things about the
floor**, from pass 1 onward: the derived floor, the risk and security values
read, and the cited stories they were read from. … This is owed by every pass;
the three lines below are owed from pass 4 and are a different obligation.`
Byte-identical between the copies. It is a *reporting* duty, not a closure
predicate, but it is the paragraph that separates (c) from (d) in W and is fused
onto the end of (c) in C (see the (c) parity note), so any re-paragraphing of
(c) or (d) touches it.

---

## Whole-file parity summary for the inventoried ranges

| Passage | Byte-identical? | Difference kind |
|---|---|---|
| (a) | yes | — |
| (b) | no | cross-reference target; intensifier; closing rationale reworded + C-only field-mint parenthetical |
| (c) | yes | (paragraph break *after* the passage differs) |
| (d) | words identical | line-wrapping only |
| (e) | no | `you report` → `report`; C-only "Recorded rationale" paragraph; no blank line before (f) in W |
| (f) | no | evidence framing reworded; C-only hypothesis qualifier; punctuation of the late-Blockers clause |
| (g) | no | C-only story-path ownership sentence (expected deliberate difference) |
| (h) | yes | — |
| (i) | yes | — |
| (j) | yes | — |
