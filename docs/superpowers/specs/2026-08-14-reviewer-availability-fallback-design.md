# Reviewer-availability fallback — a mid-flight human exception — Design

**Story:** `docs/superpowers/stories/2026-08-13-reviewer-availability-fallback-story.md`
— the story header is the single writable copy of the profile. Every gate call carries that
path and reads the axes, the mode and the lens sets fresh from it; this document never
restates them as values. The mode is owed **in full**: a scoped `mode override` recorded on
2026-08-14 was **withdrawn** (§11).

**History.** Three Gate-A passes on a three-tier design (37, 39, 40 findings) stopped under
§5's stuck condition; tier 2 and rider (a) split out to
`docs/superpowers/stories/2026-08-14-tier-2-same-family-reviewer-story.md` and
`docs/superpowers/stories/2026-08-14-sequential-branch-calls-hook-story.md`. Three further
passes on a two-tier design (30, 34, 32 findings) stopped again — blockers rising 7 → 8 → 12,
almost all of them in the re-review **debt machinery**, which this revision removes. **None
of the 212 findings across six passes has been dismissed.**

## 1. Problem

Both gates depend on one external reviewer. §5 requires a **minimum of three passes** per
gate with only the **final** pass clean, and permits an early exit below three only on a pass
returning zero findings. Out of quota, no pass can be taken at all, so no cycle closes and
all work stops. Observed: a five-day full process stall, 2026-08-05 to 2026-08-10.

`/workflow-init` §2.13 does not reach this: it fires at **init time** and scaffolds a
gateless project. A configured project that loses its reviewer mid-flight falls outside it.

**The gap: there is no authorized way to close a gate cycle when no reviewer can run.**

## 2. Why this design has no stateful controls

Recorded verbatim because it is the finding that shaped the design, and a later reader will
otherwise try to add the machinery back.

> Every compensating control added to make the waiver safe landed in one of two states:
> **unenforceable** — a prose assertion authored by the very party whose work is being
> waived — or **recursive** — real state that itself needs gating, and gating it needs the
> gate that is unavailable. That is not a run of fixable defects. It is what a gate waiver
> *is* in a prompt-only system: the thing being waived is the only mechanism available to
> protect the record of the waiver.

Concretely, a debt-tracking file was designed, reviewed and removed. Putting it in
`todos.md` left it Gate-B exempt, so a debt could be erased in a commit no reviewer saw.
Moving it to a non-`.md` path made it product-classified — which meant the **Gate-A closing
commit** now staged a product file and raised a **Gate-B** obligation, during an outage,
inside the waiver meant to escape one. Every debt-state transition had the same property.
A consecutive-waiver cap built on that state inherited it, and two permitted acceptances
could disable the feature permanently.

**So the obligation survives as a sentence, not a system.** The marker states that a
cross-model re-review is owed. Nothing tracks it, nothing enforces it, and §13 says so. A
line on `main` that every reader sees is worth more than a state machine that cannot be
protected by the mechanism it depends on.

## 3. Tier 3 — the mid-flight human exception

**A new exception, stated as one.** §2.13's init-time gateless path closes no active gate,
and a profile override changes evidence mode rather than authorizing a zero-pass closure.

### 3.1 Preconditions

**Common to both gates:**

1. **Tier 1 is unavailable** (§3.2).
2. **No unresolved adverse findings.** Prohibited if any pass in this cycle returned a
   Blocker or Major not remediated or individually human-dispositioned. Otherwise an outage
   arriving after a bad pass becomes a way to erase review evidence and land the defects the
   gate found.
3. **Not a remedy for a stuck review.** §5's "clearly stuck → STOP and surface" is
   unaffected; disputed or rising findings are not an availability problem.
4. **The merge strategy is squash or ordinary merge** (§6), revalidated before merge.

**Gate-specific evidence.** An earlier draft required the full profile-derived evidence set
at both gates, which made a Gate-A waiver **impossible** — implementation-derived evidence
cannot exist before implementation, and Gate A is the gate that blocks planning, which is
where the outage actually bit.

| Gate | What must be true |
|---|---|
| **A (spec / plan)** | The **mechanical sweep** is green — cited paths resolve, quoted passages match, stated counts agree, standalone fenced blocks parse — and the artifact's own self-checks pass. All available pre-implementation. |
| **B (diff)** | The **battery** is green, and every check the profile's mode already owes at Gate B, with a current evidence entry. |

**Tier 3 waives reviewer passes only, never evidence.**

### 3.2 Outage confirmation

Closed source enum, covering both branches:

| Source | Meaning |
|---|---|
| `attempt-failed` | A tier-1 call **and** its recovery attempt both failed this session |
| `quota-observed` | Quota exhaustion already observed this session |
| `auth-failed` | Authentication failure already observed this session |
| `status-page` | The vendor's own status page reports the service down |

`status-page` is never sufficient alone — a broad incident does not prove *this* account and
*this* call cannot complete — so it requires a direct probe at revalidation.

**Revalidation repeats the source's own observation** immediately before the closing commit,
per source: `attempt-failed` needs a fresh call **and** a fresh recovery attempt (one call is
not what that source means); the observed-failure sources need one fresh call; `status-page`
needs the probe. **If the fresh observation differs, the recorded `Cause` becomes the new
observation** — and if any of them now succeeds, the waiver is refused, because the reviewer
is available and a waiver would simply be a skipped review.

Evidence is recorded **sanitized**: enum value and timestamp only.

### 3.3 Roles, and what separation is available

| Role | Who |
|---|---|
| **Author** | Whoever produced the change, human or agent |
| **Implementer** | The agent session that ran the cycle |
| **Waiver approver** | The human who authorizes tier 3 |

The approver is a **human** and is never the implementer. **That is human-from-agent
separation, and it is the only separation this design provides.** A human author approving
the waiver on their own change is **accountable self-approval**, not independence, and the
design calls it that rather than dressing it as separation of duties — an earlier draft used
role names that implied an independence the solo case cannot deliver.

### 3.4 Authorization — a real pause

Before the closing commit the agent **stops, asks the human directly for an explicit
decision, and waits**. This is the **decision-question pattern this workflow already runs**
at every human checkpoint, not a new mechanism. The answer is recorded as §5.2's block.
**Nothing verifies that it happened** — §13.

### 3.5 The ordered close

Because a valid answer or observation can otherwise be replayed after the world moves:

1. Preconditions checked (§3.1).
2. The **prospective tree is fixed** — the exact content the closing commit will carry.
3. Outage revalidated (§3.2); evidence revalidated.
4. The human pause (§3.4).
5. The closing commit, **immediately**.

**Authorization binds to the tree fixed at step 2.** If the tree, the artifact, the evidence
entry or the merge strategy changes after that, or the commit fails or is materially delayed,
**every step is repeated** — authorization is consumed by one commit attempt and does not
survive it. Otherwise history could disclose a waiver for one target while landing different
bytes.

## 4. What the hook does — and what it does not

The hook is unchanged and **waiver-unaware**.

An earlier draft prescribed `.context/codex-gate.off`; it silences reminders for **unrelated**
commits, which is the missed-commit direction invariant 2 names as dangerous. With a
single-commit closure nothing needs silencing, so **invariant 2 is untouched and `.off` keeps
its meaning.**

A further earlier draft claimed the hook's Gate-B STOP was itself the compensating control.
It is not: a Gate-A closing commit is docs-only and exempt; Gate B can report satisfied from
previously counted calls; the output reaches the **agent**, not the human; and the hook
**always exits 0**, so it blocks nothing in any case. **The hook supplies no waiver control in
either direction.** Where this design says a reminder "fires", it means exactly that the
classifier selects that branch and the text is emitted — never that a review is forced.

**Precedence, narrowly.** For **one recorded cycle id, at one closing transition**, an
authorized waiver takes precedence over the hook's Gate-B or below-floor STOP and the agent
proceeds. This does **not** generalize: every other STOP, every later commit and every
resumed session treat the hook as authoritative.

## 5. Records

### 5.1 The tier-3 cycle marker

Mandatory in the cycle-closing commit body. **Both** this and §5.2 are required; §11
validates each independently.

```
Reviewer-tier: 3 — human exception, gate waived
Gate: A-spec | A-plan | B · cycle: <YYYY-MM-DD>-<topic-slug>-<n>
Waived-target: <baseSha>..<headSha> | <path> @ <blob-sha>
Passes completed: none | <cycle-id>/<gate>/pass-<p>[, …]
Adverse findings: none | <pass-id>#<line> <remediated|disposed> — <handle>: <reason>
Merge-strategy: squash | merge
Authorized-by: <accountable handle> · <date>
Cause: <source enum> · revalidated <timestamp>
Cross-model re-review: OWED — untracked; this line is the only record
```

**`Waived-target`, never "reviewed"** — one word would otherwise overstate exactly what the
gate proved, which is the AGENTS.md gate-proof Don't.

**`<pass-id>` is `<cycle-id>/<gate>/pass-<p>`** — cycle-unique and durable in the commit body,
because the underlying findings files live in git-ignored `.context/` under reusable slot
names and cannot be cited durably.

**`Cross-model re-review: OWED — untracked`** is deliberate and literal. §2 explains why the
tracking system was removed; this line is what remains, and it is honest about being a
sentence rather than a mechanism.

### 5.2 The logged human decision

```
Human decision: <accountable handle> · <date> · cycle: <cycle-id> · authorizes: <what> · reason: <why>
```

The handle, date and cycle id **must match the marker** exactly (normalized), or the close
stops. **Sanitization applies to `reason`** as it does to `Cause`: no raw error payloads,
endpoints, customer details or security-finding text in a public commit body; sensitive
rationale is referenced, not quoted.

### 5.3 Idempotency

A resumed or retried close must not append a second marker or decision block. Both are keyed
by **cycle id + gate**: an identical repeat collapses to one; a **conflicting** repeat stops
the close. The same rule governs the multi-WIP collapse (§6).

## 6. Disclosure, and the carry chain

- **Gate A** → the **spec or plan commit body**; carried forward into the implementation
  cycle's closing body. If work stops before Gate B, that docs commit is already durable.
- **Gate B** → the **WIP commit body**.
- **The closing amend** replaces the WIP body wholesale **except** that disclosure content is
  restated explicitly. Nothing is preserved automatically.
- **The multi-WIP collapse**: every block collected, deduplicated by §5.3, validated before
  the replacement commit.
- **The squash body**: both blocks **and** every profiled story's evidence entry copied in.

`Gate-A docs commit → WIP → amend → squash → main`.

**Validated before the merge.** The prospective squash body is checked for both blocks and
every evidence entry, and **the merge is refused if any is missing**. Story AC 2 names the
*cycle-closing commit*; a later corrective commit cannot put blocks into a commit that already
landed, so it satisfies the criterion for no cycle. A corrective commit is **incident
recovery** — it reproduces the missing blocks verbatim so history is not silent, and the
incident is recorded as a disclosure failure, not as compliance.

**Rebase-merge and cherry-pick are refused before the waiver**, not discovered after it.

**Never in the findings file.**

## 7. Old-condition inventory — CLAUDE.md §5

Fourth attempt. **The previous three claimed exhaustiveness and were thematic compressions**
— each was a blocker. This one is derived clause by clause, and every disposition is judged
**by effect, not by the noun used**: calling an operation a waiver rather than a skip does not
preserve a condition about skipping. Rows a previous version got wrong are **[corrected]**.

| # | §5 condition | Disposition |
|---|---|---|
| 1 | Two independent cross-model gates | **Narrowed** — tier 1 unchanged; tier 3 waives |
| 2 | Gates are advisory but mandatory | **Overturned for tier 3** |
| 3 | `.off` opt-out; "the gates still apply" | **[corrected] Narrowed** — the initial diagnostic meaning is kept and the file is untouched, but after an authorized waiver the gate does not apply to that one closure. A previous version marked this untouched |
| 4 | Hard floor: min 3 passes per gate | **Kept** at tier 1; **N/A** at tier 3 |
| 5 | Blocker/Major only drive the loop | **Kept** |
| 6 | Hook counts passes; cannot read findings | **Kept**; §4 adds it bears on tier 3 not at all |
| 7 | Hook cannot tell the spec run from the plan run; resets at `writing-plans` | **Kept, untouched** |
| 8 | Gate A is instruction-backed; a satisfied count is not a clean review | **Kept** |
| 9 | TodoWrite a task per pass | **Kept, untouched** |
| 10 | Fix Blocker/Major after each pass | **Kept** |
| 11 | Final pass must be clean | **Kept**; **N/A** at tier 3 |
| 12 | Stuck → STOP and surface | **Kept**, explicitly not waivable (§3.1(3)) |
| 13 | Only early exit is a zero-finding pass | **[corrected] Overturned for tier 3** |
| 14 | Don't manufacture findings to pad | **Kept, untouched** |
| 15 | Codex is advisory — validate before applying | **Kept, untouched** |
| 16 | Dismissed finding → one-line why | **Kept**; §5.1 requires handle and reason for a waiver-time disposition |
| 17 | Findings go to a FILE, not the response | **Kept, untouched** |
| 18 | Pass the repo root as `workingDirectory` | **Kept, untouched** |
| 19 | Slot naming; no invocation-unique component | **Kept**; the collision row stays open (§12) |
| 20 | One finding per line; escape literal pipes | **Kept**; rider (b) pins the severity token |
| 21 | No blank lines, headings, prose or continuations | **Kept**; rider (b) keeps structural failures INCOMPLETE |
| 22 | Exact terminator | **Kept, untouched** |
| 23 | `NO FINDINGS` for a clean pass | **Kept, untouched** |
| 24 | Reply is one line per branch, or `INCOMPLETE` | **Kept, untouched** |
| 25 | Gate B takes one file per branch under `full` | **Kept, untouched** — rider (a) moved out |
| 26 | Delete every target before each call; confirm gone | **Kept, untouched** |
| 27 | A surviving target → stop and name the cause | **Kept, untouched** |
| 28 | One pass at a time | **Kept** as a stated limitation |
| 29 | Companions are advisory; never validate a pass | **Narrowed in one named scope** — rider (b) (§10) |
| 30 | Resume note is cycle-stable, not pass-named | **Kept, untouched** |
| 31 | Acceptance: readable, exact terminator, exactly `<n>` lines, nothing else | **Kept, untouched** |
| 32 | Anything else is INCOMPLETE and discounted | **Kept, untouched** |
| 33 | Recovery: one attempt per pass, shared | **Kept**; a spent attempt is a tier-3 precondition |
| 34 | Recovery is a fresh re-run deleting exactly what it rewrites | **Kept, untouched** |
| 35 | Resume preferred only when the write failed; pass `sessionId` + `reviewType` | **Kept, untouched** |
| 36 | Spent and still incomplete → STOP and surface | **[corrected] Narrowed** — the diagnostic steps are kept, but tier 3 permits continuation after a spent attempt instead of terminal escalation. A previous version marked this untouched |
| 37 | Hook counting residuals are not evidence | **Kept, untouched**; §4 relies on it |
| 38 | Discount every incomplete pass whatever the counter says | **Kept, untouched** |
| 39 | Gate A is two runs, each its own loop | **Kept**; tier 3 available to each independently |
| 40 | Prompt opens with the brainstorming directive | **Kept, untouched** |
| 41 | One broad prompt, re-run each pass over the revised artifact | **Kept, untouched** |
| 42 | Append intent, artifact text, and which invariants it touches | **Kept, untouched** |
| 43 | Every finding with severity and confidence; you filter, Codex never does | **Kept, untouched** |
| 44 | Mechanical sweep before each read pass | **Kept**, and promoted to a Gate-A waiver precondition (§3.1) |
| 45 | Optional focused per-dimension passes on large artifacts | **Kept, untouched** |
| 46 | Gate B: tests green, before commit | **Kept**; the battery is a Gate-B waiver precondition |
| 47 | Gate B tool and args: `instruction`, `whatWasImplemented`, `baseSha`; `full` runs both | **Kept, untouched** |
| 48 | `baseSha` from a WIP commit; `WIP:` naming; amend to close; `reset --soft` for several | **Kept**, and §6 adds what the collapse must carry |
| 49 | Skip ONLY trivial changes | **[corrected] Narrowed** — by effect a non-trivial change can now close without review; the noun differs, the effect does not |
| 50 | Re-review after every fix | **[corrected] Narrowed for tier 3** — §3.1(2) permits closing after a remediation that no independent reviewer ever sees. The marker records the remediation and the `OWED` line covers it; a previous version marked this untouched |
| 51 | A fix changing specified behaviour updates the spec in the same commit | **Kept, untouched** |
| 52 | The standing falsification lens | **Kept, untouched** |
| 53 | Name what the diff changes the size, value or position of | **Kept, untouched** |
| 54 | Prose-vs-product classification | **Kept, untouched** — no file changes classification in this design |
| 55 | Risk lens set: threats, abuse, rollback, data loss, idempotency, compatibility, observability | **Kept, untouched** |
| 56 | Security lens set: assets, trust boundaries, roles, external systems, abuse paths | **Kept, untouched** |
| 57 | Both axes → union appended once, abuse carrying both labels | **Kept, untouched** |
| 58 | Lenses are different questions, not more passes | **Kept, untouched** |
| 59 | Profile: story header is the single writable copy | **Kept** — no value is copied anywhere |
| 60 | Three profile-reading cases | **Narrowed for tier 3** — an artifact citing no story runs unprofiled today; tier 3 needs no citation now that the debt is gone, so the unprofiled path is **restored** to §5's behaviour |
| 61 | Stop and surface on an unresolvable profile | **Kept, untouched** |
| 62 | Gate-B triviality skip needs two independent conditions | **Kept, untouched**; a waiver is not a skip and is recorded separately |
| 63 | The skip reason is recorded in the commit body | **Kept, untouched**; the waiver marker is a separate record |
| 64 | A skip removes the review, never the evidence | **Kept**, and tier 3 follows the same principle (§3.1) |
| 65 | A cycle citing several stories aggregates per story | **Kept, untouched** |
| 66 | What the author owes by mode | **Kept**, gate-appropriately (§3.1) |
| 67 | A named verification may substitute for an automated check | **Kept, untouched** |
| 68 | The counterfactual, and the wiring that could produce it | **Kept**, and applied to this change (§11) |
| 69 | An unobservable counterfactual is a blocking evidence gap | **Kept, untouched** — and **not** invoked here (§11) |
| 70 | A fabricated test satisfies nothing | **Kept, untouched** |
| 71 | Evidence entry in the commit body, revalidated before close | **Kept**; the marker joins it in every hop |
| 72 | Every Gate-B call carries each cited story path + evidence entry verbatim | **Kept, untouched** |
| 73 | Work gap vs setup gap | **Kept, untouched** |
| 74 | Profile changes are proposed, human-confirmed, logged | **Kept, untouched** |
| 75 | An axis change voids prior overrides | **Kept, untouched** |
| 76 | Passes under a lower profile still count; only the final clean pass must be current | **Kept, untouched** |
| 77 | Fold a mid-cycle profile edit into the WIP by amend | **Kept, untouched** |
| 78 | The closing message carries the validated evidence entry | **Kept**, and now the marker too |
| 79 | Timeout/abort handling; one retry is the shared attempt | **Kept**; feeds §3.1 |
| 80 | §5's stated non-enforcement residuals — nothing checks which file was read, whether the header moved mid-call, whether lens sets were appended | **Kept, untouched**, and §13 adds this design's own |
| 81 | **The gate itself is not optional** | **OVERTURNED for tier 3**, deliberately and by name |

## 8. Sites

Found by searching the **behaviour claim**, which is how the passages below were found after
earlier drafts listed one section of one file.

| Site | Change |
|---|---|
| `CLAUDE.md` §5 | Tier 3, the records, the carry chain, riders (b) and (c) |
| `/workflow-init` inline §5 mirror | The same edits — story AC 9, verified by extracted parity |
| `/workflow-init` §2.13 | Init-time scope stated; **gateless answer unchanged** |
| `docs/getting-started.md` ~106 | **"Gate A is not skippable at any level."** Directly falsified — highest priority |
| `docs/getting-started.md` ~84, ~34, ~53 | Floor and skippability stated unconditionally |
| `docs/coding-workflow.md` § *The two gates…* | "advisory but mandatory… not optional"; **heading not renamed** |
| `docs/coding-workflow.md` ~19, ~27–29, ~91–99, ~108–109, ~123–126 | Pipeline and stage-level independent-review claims |
| `docs/sparring-briefing.md` ~41–44 | **"Advisory, never exempt… do not treat a satisfied human as a substitute for a clean pass."** Tier 3 is exactly that, so this is **overturned here**, not moved to the tier-2 story as the story's first amendment wrongly said |
| `README.md` product summary and daily-use pipeline | The mandatory-gate claim gains the exception |
| `plugins/dev-workflow/.claude-plugin/plugin.json` | Its description carries the same claim |
| `.claude-plugin/marketplace.json` | Same claim in marketplace metadata |
| `AGENTS.md` § *What this project is* | Gains a clause admitting the waiver |

**`docs/coding-workflow.md` ~149 is NOT changed** — its "makes the gate mandatory" is the
repo-enforced **quality** gate, not the review gate. An earlier draft listed it, which would
have weakened an unrelated guarantee.

**No new file is added**, so `AGENTS.md`'s architecture tree needs no new entry — a
consequence of removing the debt store, and stated because an earlier draft did add one and
omitted the tree.

**Not changed:** the four same-model prohibition sites. They forbid a same-model *reviewer*;
a human exception is not a model reviewing its own work.

## 9. Riders

**(b) Canonical syntax, and a tolerant reader.** **Canonical:** severity is
`BLOCKER | MAJOR | MINOR | NIT`, uppercase. **Reader:** normalization applies **only** to an
otherwise-valid six-field line whose severity field is non-empty and unrecognized; it maps to
`MAJOR`. Every **structural** failure stays INCOMPLETE.

The pass is valid only if that pass's dispositions file records the drift:

- **Grammar**, a distinct ordered record type alongside the file's existing
  one-verdict-per-finding contract: `Enum drift: <token> → MAJOR · lines <n>[, <n>…]`, citing
  the finding lines normalized.
- **Timing:** the record must exist **before the reader credits the pass** — not before the
  hook counts it, since `PostToolUse` fires before the agent can read the returned file.
- **Retention:** until the cycle closes. **If it disappears**, the pass it qualified is
  **discounted** — §5's existing answer for an unverifiable pass.

Motivating incident: PR #23's Gate-B pass 3 returned all four findings at `IMPORTANT`.

**(c) Squash-merge carry** — §6, covering both markers and evidence entries.

## 10. Validation evidence

**Battery** — the `AGENTS.md` quality command, green.

**Prompt conformance** — all 12 items of `docs/prompt-standards.md` for every changed prompt
artifact: `CLAUDE.md` §5, the `/workflow-init` mirror, §2.13, and **`AGENTS.md`**, which §8
changes and which `CLAUDE.md` classifies as product. The reviewer and result are named.

**Check that fails without the change — two of them, and no evidence gap.** An earlier draft
claimed the counterfactual was unobservable and took a scoped mode override for it. **Both
the claim and the override are withdrawn.**

1. **Rider (b):** a findings file whose four findings carry severity `IMPORTANT`, with no
   dispositions record. **Before**: accepted, filter applied by interpretation. **After**:
   INCOMPLETE.
2. **Tier 3, by prompt-harness scenario:** drive a cycle in which the reviewer is
   unavailable. **Before**: a compliant agent refuses to close, because no authorized closure
   exists. **After**: it closes **only** when every §3.1 precondition holds, and refuses when
   any one is removed. The prior-state refusal is the observation that would exist if the
   claim were false, and the wiring produces it because the old procedure has no closure path
   at all.

**Named verification.** The matrix describes **observable behaviour of the procedure followed
correctly**. It does **not** claim enforcement: §13 states an agent departing from the
procedure can produce a conforming-looking commit, and no row should be read as a mechanism.

| Case | Observed outcome when the procedure is followed |
|---|---|
| Gate-A spec waiver | marker **and** decision block in the spec commit body; identifiable from history alone |
| Gate-B waiver | both blocks survive WIP → amend → squash; readable from `main` alone |
| Decision block absent | non-conforming; each block validated independently |
| Handle/date/cycle mismatch across blocks | close stops |
| Repeated or resumed close | identical blocks collapse; conflicting blocks stop the close |
| Multi-WIP collapse | all blocks collected and validated |
| Prospective squash body missing a block | **merge refused** before it lands |
| Waiver after an unremediated Major | procedure refuses (§3.1(2)) |
| Waiver during a stuck review | procedure refuses (§3.1(3)) |
| Gate-A waiver, sweep red | procedure refuses (§3.1) |
| Gate-B waiver, battery red | procedure refuses (§3.1) |
| Tree changes after authorization | authorization void; all steps repeated (§3.5) |
| `attempt-failed` revalidated with one call only | insufficient; the source needs call **and** recovery (§3.2) |
| Revalidation succeeds | waiver refused — the reviewer is available |
| Rebase-merge selected | refused **before** the waiver |
| Hook at the closing commit | emits its reminder and **exits 0**; it forces nothing |
| Enum drift with / without the companion record | valid / INCOMPLETE |
| Companion deleted before close | the pass it qualified is discounted |
| Structurally broken finding line | INCOMPLETE, never normalized |

## 11. Withdrawn

Recorded because both were confirmed decisions, and a reader of the history will otherwise
find them and assume they hold.

- **The scoped `mode override`** on the story's profile log. §5's grammar permits a whole
  effective mode in the header and requires the header to carry an override; there is no
  per-portion override, so recording one invented a mechanism the profile system does not
  have. `battery+check+verification` is owed **in full**, and §10 supplies the `+check`.
- **The debt record's move to a Gate-B-classified path.** Moot — the debt machinery is gone
  (§2) — and it was also recursive.

## 12. Packaging and backlog

- `todos.md`: **occurrence 3** added to the compound-commands row (story AC 8) — `git add`
  and `git commit` in one Bash call, empty staged set at `PreToolUse`, loose STOP; observed on
  PR #23's close. Same shape as occurrence 2 and, like it, a **false positive**. The existing
  item is **edited in place**; append-only-never-edit is `docs/hardening-log.md`'s rule.
- `prompt-vague-criteria` closes. `unverified-enforcement-claim` **stays open**, re-pointed at
  the hook story.
- **New parked row: tracked re-review debt.** The obligation currently lives only as the
  marker's `OWED` line. *Trigger: a tier-3 waiver whose re-review is found never to have
  happened, or the third waiver in one repository — whichever comes first.* §2 records why a
  stateful design was removed, so whoever takes this row starts from that constraint rather
  than rediscovering it.
- **New parked row: enforced waiver authority** — signed commit or protected-branch approval.
  *Trigger: the first tier-3 record whose authorization is disputed or unattributable.*
- **New parked row:** the hook's `is_docs_only` exempts **any** `.md` path outside a prompt
  directory, broader than §5's prose list (`docs/**.md`, `README.md`, `MANIFEST.md`). Found
  while siting the removed debt store. *Trigger: a root `.md` file acquiring gate-relevant
  state.*
- **Gate-cycle slot collision — trigger fired, row stays open.** This cycle's first pass
  deleted its predecessor's findings file and dispositions before the surviving 44 artifacts
  were archived by hand.
- **New parked row:** tier-2 counting and containment, pointing at the tier-2 story.
- Version **0.8.2 → 0.9.0** with a `CHANGELOG.md` entry — invariant 12. **This will be
  verified** by `scripts/check-version-bump.sh` against the PR's base *after* the WIP commit
  contains both the plugin edits and the manifest bump; run before then it reports clean,
  uselessly.

## 13. What this does not do

Residuals known at design time. The list is **not** exhaustive.

- **Tier 3 waives the gate.** A change closed this way has had **no** independent review.
- **The re-review obligation is a sentence.** Nothing tracks it, nothing schedules it, nothing
  fails if it never happens. §2 explains why that is the honest form rather than a defect, and
  §12 parks the tracked version with its trigger.
- **The authorization pause is procedure, not enforcement.** Nothing verifies that it happened
  or that the handle belongs to whoever answered. Every block in §5 is a **recorded
  assertion**; an agent that skips the pause and writes the blocks produces a
  conforming-looking commit.
- **The only separation is human-from-agent.** A human author approving their own change is
  accountable self-approval, and nothing checks even that.
- **Every "procedure refuses" row in §10 is behaviour of a compliant agent**, never a
  mechanism preventing a non-compliant one.
- **The hook forces nothing.** It emits a reminder and exits 0.
- **Nothing detects availability's return** outside the pre-close revalidation.
- **`main`'s history can be rewritten.** A force-push can remove a marker.
- **Rollback** leaves markers in place as records of what happened; reverting the prompts
  removes the procedure but not the disclosure, and since no state file exists there is
  nothing further to migrate.
