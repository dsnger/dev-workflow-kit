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

## 2. Why this design carries no stateful controls

**A cost-and-trust decision, not an impossibility claim.** Recorded because a later reader
will otherwise try to add the machinery back — and recorded *as a trade-off* because an
earlier draft of this section argued that stateful controls were structurally impossible,
which was a false dichotomy: it would have told that reader not to evaluate controls that
are in fact feasible.

**What was tried, and what it cost.** A debt-tracking file was designed, reviewed and
removed. In `todos.md` it was Gate-B exempt, so a debt could be erased in a commit no
reviewer saw. On a non-`.md` path it became product-classified — so the **Gate-A closing
commit** staged a product file and raised a **Gate-B** obligation, during an outage, inside
the waiver meant to escape one. Every debt-state transition had that shape. A
consecutive-waiver cap built on that state inherited it, and two permitted acceptances could
disable the feature permanently.

**Alternatives considered, and why each was rejected.** None is impossible. Each buys
tracking at a price this change declined to pay, and the price is stated so a future reader
can re-price it rather than re-derive the rejection.

| Alternative | Why rejected |
|---|---|
| **State transition inside the same authorized closure** — the waiver authorizes its own debt row inside the tree it already fixes (§3.5 step 2), so opening the debt needs no second gate | Feasible, and the narrowest option. Rejected because it covers only *opening*: closing the row later is an unwaived transition needing its own authority, so the machinery returns at repayment time instead of being avoided. It also puts a product-classified path into a Gate-A closing tree, which §3.5 now refuses outright |
| **CI append-only / marker check** — a workflow asserting debt rows are only appended, and that every tier-3 marker has a matching open row | Feasible and mechanical. Rejected on cost and blast radius: it is new executable surface in a repo whose only executables are the hook and two checkers; like invariant 12's checker it can only run on `pull_request`, so a direct push bypasses it; and it enforces bookkeeping, not review — the marker would be guaranteed to have a row, never that anyone re-reviewed |
| **Protected external record** — a tracking issue, or a protected branch carrying the approval and the debt | Feasible, and the only option offering authority the author cannot forge. Rejected because it moves the record off `main`, where §5's entire disclosure model lives, and creates a second system that can disagree with history; it also assumes a forge, an account model and branch permissions this kit does not require of a user |

**So the obligation survives as a sentence, not a system.** The marker states that a
cross-model re-review is owed. Nothing tracks it, nothing enforces it, and §13 says so.
What this buys instead is a record that is **discoverable in reachable `main` history** —
`git log --grep='Reviewer-tier: 3' <default-branch>`, and any commit-body view in a forge UI
— rather than ambient visibility every reader is exposed to. §12 parks the tracked version
with the trigger that would justify paying one of the prices above.

## 3. Tier 3 — the mid-flight human exception

**A new exception, stated as one.** §2.13's init-time gateless path closes no active gate,
and a profile override changes evidence mode rather than authorizing a zero-pass closure.

### 3.1 Preconditions

**Common to both gates:**

1. **Tier 1 is unavailable** (§3.2).
2. **No unresolved adverse findings — and the pass ledger must be *establishable*, not
   merely empty.** For every pass this cycle took, its findings file and dispositions must be
   present, readable, valid under §5's acceptance rule, and every Blocker or Major in them
   remediated or individually human-dispositioned.
   **There is no authoritative enumeration of passes, and the design does not pretend
   otherwise.** §5 records no durable pass id at the moment a pass happens; `.context/` slot
   names carry no invocation-unique component and collide (this cycle has already destroyed a
   predecessor's artifacts that way, §12); and the hook counter is explicitly not evidence.
   So the ledger is authoritative **only where it is durable** — the `<pass-id>`s accumulated
   in the WIP commit body at Gate B, and any recorded in a prior commit body at Gate A.
   **Everything else fails closed.** The waiver is **refused** whenever the ledger cannot be
   established: a resumed session with no durable record, a slot file whose provenance cannot
   be tied to this cycle, a gap in the pass sequence, two artifacts disagreeing, or any
   uncertainty about whether a call was made at all. `Passes completed: none` may be written
   **only when the absence is established** — never when it is merely what the session can
   see. Read the other way, an outage arriving after a bad pass, or after a *lost* one, is a
   way to erase review evidence and land the defects the gate found.
3. **Not a remedy for a stuck review.** §5's "clearly stuck → STOP and surface" is
   unaffected; disputed or rising findings are not an availability problem.
4. **Every governing story's profile resolves freshly**, by §5's three-case rule, read from
   the story header at waiver time. Stated as a common precondition because a zero-pass
   closure otherwise never forces resolution, and a malformed profile would be bypassed
   precisely on the path with no reviewer.
   **The set is the union, not the current citation.** It is every story path this cycle has
   cited anywhere — the artifact now, any prior pass's prompt, any prior commit body in the
   cycle — because validating only what the artifact cites *at waiver time* makes deleting a
   citation a one-line way to shed a `high`-risk mode, its lens sets and its evidence
   obligations while still obeying the written rule. A path that appears earlier in the cycle
   and is absent now is an **unresolvable profile** — stop and surface — never `unprofiled`,
   unless the removal is itself explained and human-confirmed as a profile change under §5.
   Only a cycle in which **no** story was ever cited runs unprofiled, and the marker says so.
5. **The waiver checklist is answered** — see below. This is the compensating evidence, and
   an unanswered item is a failed precondition.
6. **The merge strategy is squash or ordinary merge** (§6), revalidated before merge.

**The waiver checklist.** Tier 1 buys questions being asked by someone other than the
author. Tier 3 cannot buy the independence back, so it obliges the **named human approver**
(§3.3) to ask the questions in writing instead. Five parts, each answered item by item —
answered, not asserted green:

- the **unioned lens sets** the governing stories' profiles require (§5), applied and
  answered, with risk's *abuse* and security's *abuse paths* as one question carrying both
  labels;
- an **invariant-by-invariant** pass over `AGENTS.md` § Key invariants, marking each touched
  and checked, or untouched;
- all **12 items of `docs/prompt-standards.md`** for every changed prompt artifact;
- **the standing falsification lens** — *which existing statements does this change falsify?*
  — together with its companion: **name what this change alters the size, value or position
  of**, and **grep for where each is described elsewhere**, recording the search performed
  and its hits. At tier 1 these ride on the Gate-B prompt; a zero-pass closure has no prompt,
  so without this they would be silently dropped on the one path with no independent reader,
  and this repo's most persistent defect class is exactly the statement a change made wrong
  in a file it never touched;
- the artifact's own stated self-checks, where it states any.

**Every answer is `answered` or the precondition fails.** There is no
"answered-with-exception" and no free-text escape: a single unbounded exception field would
be a route around the only compensating evidence a zero-pass closure has.

**The answers are a durable record (§5.5), not a summary word.** They enter the request
digest and travel the whole carry chain. An earlier draft compressed the whole checklist into
four words in the marker, which meant the item-by-item review existed only in the session
that performed it and evaporated at the first amend — leaving a claim that a review happened
and nothing a later reader could weigh.

**Gate-specific evidence** sits on top of the checklist. An earlier draft required the full
profile-derived evidence set at both gates, which made a Gate-A waiver **impossible** —
implementation-derived evidence cannot exist before implementation, and Gate A is the gate
that blocks planning, which is where the outage actually bit.

| Gate | What must be true |
|---|---|
| **A (spec / plan)** | The **mechanical sweep** is green — cited paths resolve, quoted passages match, stated counts agree, standalone fenced blocks parse. **This is syntax hygiene, not evidence:** it establishes that the artifact refers to real things and parses, and says nothing about contradictions, unsafe decisions, prompt-standard conformance or invariant risk. Those are the checklist's job, and the distinction is stated because an earlier draft offered the sweep as the compensating evidence itself. |
| **B (diff)** | The **battery** is green, and **every cited profiled story independently satisfies its own mode and suffix** with its own current evidence entry: the battery runs once for the cycle, each profiled story's entry is named separately, a cited **unprofiled** story owes no entry, and every entry is revalidated at §3.5 step 3 and carried into the closing body (§6). Singular "the profile's mode" is not what §5 requires of a multi-story cycle, and a marker satisfying one story's checks while citing three would look valid. |

**Tier 3 waives reviewer passes only, never evidence.**

### 3.2 Outage confirmation

**Only a canonical gate call is evidence of unavailability.** A canonical call is the call
§5 already specifies for that gate: the correct tool (`mcp__codex__exec` at Gate A,
`mcp__codex__review` at Gate B), the reviewed repo root as `workingDirectory`, the **current**
artifact text or commit range, every cited story path and — at Gate B — each cited profiled
story's current evidence entry verbatim, plus the prompt's required opening and the
appended lens sets.

**A failure of the request is not proof that the reviewer cannot run.** A malformed request,
the wrong tool, a wrong working directory, a stale artifact or range, a missing required
argument, a findings-file write failure, a count-mismatch or terminator failure, an
`INCOMPLETE` reply — each says *this call* was defective. Those are the manufacturable
failures: without this rule, unavailability can be produced on demand by sending a bad
request, and a reviewer perfectly able to review is waived. Such a result is **not** an
enum source; it is a defective call to be corrected and re-sent, and it consumes no
recovery attempt. The marker records **which canonical call class failed** — `exec`,
`review-spec`, `review-quality` — beside the source (§5.1 `Cause`).

**Closed source enum — two values.** An earlier draft had four; two were removed because
they could be produced locally, which is the whole abuse path this section exists to close.

| Source | Meaning | Canonical calls it requires |
|---|---|---|
| `quota-observed` | Quota exhaustion returned to a canonical call | one |
| `attempt-failed` | A canonical call **and** its recovery attempt both returned a transport- or service-level failure | two |

**What was removed, and why it is not a gap:**

- **`auth-failed`** — an authentication failure is **locally manufacturable**: withhold,
  revoke or corrupt a credential and the request stays perfectly canonical while the
  reviewer "cannot run". It is therefore **never an outage**. A local authentication failure
  is a **configuration error to be repaired**, and a vendor-side credential revocation is
  indistinguishable from it at the client, so both take the same answer: fix the
  configuration, then call. If the account is genuinely gone, that is a setup gap under §5's
  work-gap-vs-setup-gap rule, surfaced to the human — not a waiver.
- **`status-page`** — it was already never sufficient alone, and revalidation always ends in
  a canonical probe whose *own* result is what gets recorded. So it could never be the
  recorded `Cause`, and a value the enum cannot reach is not an enum value. A status page
  remains useful as **corroboration** a human may cite in the decision `reason`; it
  authorizes nothing.

Both surviving sources require a canonical call that the vendor answered, so neither can be
produced without disabling the account itself — and disabling the account is the case above.

**Revalidation repeats the source's own observation** immediately before the closing commit:
`quota-observed` needs one fresh canonical call; `attempt-failed` needs a fresh canonical
call **and** a fresh recovery attempt, because one call is not what that source means.

**When the fresh observation differs, this table decides. No other reading is permitted, and
no enum value is inferred:**

| Fresh result | Recorded `Cause` | Calls consumed | Outcome |
|---|---|---|---|
| Any canonical call **succeeds** | — | the fresh call | **Waiver refused** — the reviewer is available, and a waiver would simply be a skipped review |
| Quota exhaustion | `quota-observed` | the fresh call | Proceed |
| Transport/service failure, recovery attempt also spent and failed | `attempt-failed` | fresh call **and** recovery | Proceed |
| Transport/service failure, recovery **not yet spent** | — | the fresh call | Spend the recovery attempt, then re-enter this table with its result |
| **Authentication failure** | — | the fresh call | **Repair the configuration**, then re-enter this table. Never a waiver; if it cannot be repaired, surface it as a setup gap |
| A **defective call** (above) | — | none | Correct and re-send; not an observation of unavailability |
| Anything else — an unrecognized error shape, a result yielding no usable text, a clock or environment failure that makes the observation untimestampable | — | — | **STOP and surface**, naming the observed result verbatim. The close does not proceed and no waiver is taken |

The recorded `Cause` is always the **revalidated** observation, never the original one. The
recovery row is the only transition that spends the shared one-attempt-per-pass budget of
§5; every other row consumes at most the one fresh call, which is not a recovery.

Evidence is recorded **sanitized**: enum value, canonical call class and timestamp only,
under §5.4's grammar. No error payloads, endpoints or account identifiers.

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
at every human checkpoint, not a new mechanism.

**What is presented is the complete prospective record, not a summary**: the expected parent
commit, the fixed tree id, the full §5.1 marker with every field filled **except** the two
the answer itself creates, the full checklist record (§5.5), every carried evidence entry,
and the revalidated `Cause`. Binding approval to the tree alone would leave the marker, the
cause, the dispositions and the merge strategy free to change afterwards while the content
binding still looked valid — those fields live in the commit *message*, which no tree
contains.

**Two digests, because one is circular.** The decision block's own timestamp and reason are
*created by* the answer. A single digest containing them would have to be shown before they
exist: fill them in afterwards and the authorized bytes change; pre-fill them and the record
states a predicted decision time and a predicted rationale rather than the decision that
happened. So:

- The **request digest** (§5.4) covers the expected parent, the tree id, the marker without
  its `Authorized-by` and `Authorization-digest` lines, the checklist record and every
  evidence entry. It is computed at §3.5 step 3 and is what the human is shown.
- The **attestation** is the human's answer: they return **the request digest** together with
  their handle, the decision timestamp, what they authorize and why. §5.2's block records
  exactly that, and the marker's `Authorization-digest` carries the request digest verbatim,
  which is what ties the answer to the bytes without either preceding the other.

Nothing downstream re-derives the human's fields; everything downstream re-derives the
request digest and compares it. **Nothing verifies that the pause happened** — §13.

### 3.5 The ordered close

Because a valid answer or observation can otherwise be replayed after the world moves:

1. **Preconditions checked** (§3.1).
2. **The expected parent is fixed.** `<parent>` is the current branch tip. It enters the
   request digest, and steps 6 and 7 check it — an isolated index alone leaves `HEAD` free to
   move, and a commit that acquires an unauthorized parent while carrying the authorized tree
   **undoes concurrent work** and still passes a tree-only comparison.
3. **The prospective tree is fixed.**
   - A **dedicated index** is created — `GIT_INDEX_FILE` at a path used by nothing else for
     this cycle — and **initialized from `<parent>` with `git read-tree`**. A fresh index file
     starts *empty*, so staging into one without this step writes a tree that **deletes every
     tracked path not restaged**: a data-loss path, not a formality.
   - The intended changes are applied to that index, and `git write-tree` records the
     **tree id**. Nothing else writes that index before step 6.
   - **At Gate A the change must be positively determined docs/artifact-only.** The test is
     the **diff of `<parent>`'s tree against the prospective tree**, not an enumeration of the
     tree itself — a tree contains the whole repository, so "every path qualifies" would
     refuse every real commit. Every **changed** path is classified, across **additions,
     deletions, renames (both sides), modifications, mode changes and type changes**, and
     each must be the named artifact or prose `CLAUDE.md` exempts (`docs/**.md`, `README.md`,
     `MANIFEST.md`). **Any prompt, script, code or otherwise product-classified path on
     either side refuses the Gate-A waiver outright**, and no separately authorized Gate-B
     waiver may ride inside a Gate-A closing commit. Otherwise a staged product change closes
     under an A-spec or A-plan marker with §4's precedence excusing the Gate-B STOP it would
     raise — a second gate-off path, in the direction invariants 2 and 3 exist to protect.
4. **Outage revalidated** (§3.2); **evidence revalidated** (§3.1), including every cited
   profiled story's entry; then the **request digest** is computed (§5.4) over `<parent>`, the
   tree id, the marker without its two answer-created lines, the checklist record and every
   carried evidence entry.
5. **The human pause** (§3.4), on that request digest. The answer returns the digest plus the
   decision fields.
6. **The final probe and the age check**, after the answer. The close **restarts at step 1**
   if: the step-4 revalidation is more than **15 minutes** old by UTC clock; the clock is
   unreadable; the probe's result differs from the recorded `Cause`; the request digest no
   longer matches a recomputation; or **`HEAD` is no longer `<parent>`**. The probe repeats
   the source's own observation (§3.2) — one canonical call for `quota-observed`, a call
   **and** a recovery attempt for `attempt-failed` — and the recovery it spends is the same
   single per-pass attempt §5 already budgets, never a second one; if that attempt is already
   spent and `attempt-failed` cannot be re-established, the close **stops and surfaces**.
   The pause is unbounded and the reviewer can recover inside it, which is why the probe sits
   on the far side of the answer.
7. **The closing commit, immediately**, written from the dedicated index of step 3 onto
   `<parent>`.
8. **Read back what actually landed** — parent, tree and message — and compare all three:
   the commit's parent must be `<parent>`, its tree the authorized tree id, and the
   normalized record bytes of its message (§5.4) must equal what the request digest covered,
   with the two answer-created lines matching the attestation. **Any mismatch, or anything
   that cannot be read back, is an incident** (§6): the commit is not a valid tier-3 closure.
   Checking the tree alone was the earlier draft's error — everything authorization binds
   lives in the *message*, which no tree contains, so an edited, truncated, duplicated or
   hook-rewritten body would have passed.

**Authorization binds to the request digest of step 4 plus the attestation of step 5.** If
`<parent>`, the tree, the artifact, any evidence entry, the checklist record, the merge
strategy or any marker field changes after that, or the commit fails, **every step is
repeated** — authorization is consumed by one commit attempt and does not survive it.
Otherwise history could disclose a waiver for one target while landing different bytes.

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

**Precedence, narrowly.** For **one recorded cycle id and gate, at one closing transition**,
an authorized waiver takes precedence over the hook's Gate-B or below-floor STOP and the
agent proceeds. This does **not** generalize: at every other STOP, every later commit and
every resumed session, the compliant-agent procedure is to obey the reminder as before.
"Authoritative" is the wrong word for text emitted by something that always exits 0; what
the reminders have is standing in the procedure, not enforcement.

**Gate-A continuation, across reminders that fire later than the authorization.** Both Gate-A
reminders arrive after the commit that consumed the corresponding authorization: the spec
waiver closes at the spec commit but the below-floor reminder is emitted at `writing-plans`,
and the plan waiver closes at the plan commit while its reminder is emitted at
`executing-plans` (the hook resets its Gate-A count at `writing-plans` in between). Without a
rule at **both** points, a correctly waived artifact can never advance — the agent either
stalls on a STOP it cannot clear or silently extends a spent authorization — and the original
stall this design exists to fix would survive at the spec stage, which is where it bit.

**The rule is state-free and re-derived, never remembered.** Before proceeding past the
reminder, the agent reads history for the commit that introduced the artifact it is about to
work from, and continues **only if** all of these hold:

| At | Artifact | Required in that commit's body |
|---|---|---|
| `writing-plans` | the spec about to be planned from | a valid §5.1 marker with `Gate: A-spec` |
| `executing-plans` | the plan about to be executed | a valid §5.1 marker with `Gate: A-plan` |

plus, in both cases: a §5.2 decision block matching it under §5.3, and a `Waived-target`
naming that artifact — **at a blob sha equal to the artifact's content right now**. The
current blob is resolved at the moment of the check and compared; a `Waived-target` that
merely names the right *path* is not enough. Otherwise the artifact can be edited after its
waived commit and the stale authorization still clears the reminder, which is a gate-off path
for bytes no one waived. Any later edit needs a new Gate-A cycle for that artifact.

Anything else — no marker, the wrong gate's marker, a marker for a different artifact or
cycle id, a blob that no longer matches, an unparseable block, a body that cannot be read —
is **no authorization**, and the reminder stands. A resumed session performs the same
re-derivation and reaches the same answer, because nothing is carried in session state.

**This clears that reminder whenever it is derived for that unchanged artifact**, which is
not the same as clearing it once: the derivation is deliberately state-free, so a resumed or
repeated invocation re-derives and re-clears. Nothing records prior clearance, and claiming
one-time consumption would describe a mechanism that is not there. Changing the artifact is
what ends it. The Gate-B floor for the implementation that follows is untouched, and needs
its own tier-1 passes or its own tier-3 waiver.

## 5. Records

### 5.1 The tier-3 cycle marker

Mandatory in the cycle-closing commit body. **Both** this and §5.2 are required; §10
validates each independently.

```
Reviewer-tier: 3 — human exception, gate waived
Gate: A-spec | A-plan | B · cycle: <cycle-id>
Waived-target: <path> @ <blob-sha> | diff <diff-digest>
Authorized-parent: <parent-sha>
Authorized-tree: <tree-sha>
Profiles: none-cited | <story-path> <profiled|unprofiled>[, …]
Passes completed: none | <pass-id>[, …]
Adverse findings: none | <pass-id>#<line> <remediated|disposed> — <handle>: <reason>
Waiver-checklist: <handle> · <checklist-digest> · <k>/<k> answered
Merge-strategy: squash | merge
Authorization-digest: <request-digest>
Authorized-by: <accountable handle> · <timestamp>
Cause: <source enum> · <canonical call class> · revalidated <timestamp>
Cross-model re-review: OWED — untracked; this line is the only record
```

**`Waived-target` never names a sha the commit itself will change.** At Gate A it is the
artifact path and its blob sha, which the commit lands and does not alter afterwards. At Gate
B it is `diff <diff-digest>` — the digest (§5.4) of the `<parent-sha>` → `<tree-sha>` diff.
An earlier draft wrote `<baseSha>..<headSha>`, which cannot work at Gate B: the closure is an
**amend**, so the `headSha` named in the body is destroyed by the very commit that carries
it, leaving a durable marker pointing at an object that may be unreachable. Parent, tree and
diff digest all survive the amend and identify the same bytes.

**`Authorized-parent` and `Authorized-tree`** are what §3.5 step 8 reads back. Both are
present because either alone can be satisfied while the other is wrong.

**`Profiles:` lists every governing story path** (§3.1(4) — the union across the cycle, not
the current citation) with its **status only**, never its mode: §5 makes the story header the
single writable copy and keeps mode values out of commit bodies, so what the marker records
is *which stories governed and which of them owed evidence*, and a reader re-resolves the
rest. A mixed cycle carrying both kinds is ordinary and must remain reconstructible, which a
bare `unprofiled` could not express. `none-cited` is the genuinely story-less case.

**`Waiver-checklist:`** carries the approver's handle, the digest of the §5.5 record, and the
answered count over the total — never a per-part summary word, which would be a claim about a
record instead of a handle on it.

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
Human decision: <accountable handle> · <timestamp> · gate: A-spec | A-plan | B · cycle: <cycle-id> · authorizes: <what> · reason: <why>
```

The handle, timestamp, **gate** and cycle id **must match the marker** exactly under §5.4's
normalization, or the close stops. The `gate:` field is explicit rather than inferred: §5.3
keys both records by cycle id **and** gate, and an A-spec, an A-plan and a B decision sharing
one cycle id are otherwise indistinguishable — the collapse would merge the wrong
authorization or reject the right one.

**Sanitization applies to `reason`** as it does to `Cause`: no raw error payloads, endpoints,
customer details or security-finding text in a public commit body; sensitive rationale is
referenced, not quoted.

### 5.3 Idempotency

A resumed or retried close must not append a second marker or decision block. Both are keyed
by **cycle id + gate**, present in both records: an identical repeat — byte-equal after §5.4
normalization — collapses to one; a repeat differing in **any** field is a **conflict** and
stops the close. The same rule governs the multi-WIP collapse (§6).

### 5.4 Field grammar

The blocks are a line-oriented protocol carrying human-supplied text, so the grammar is
stated rather than assumed: an unescaped newline or separator in a reason would otherwise
inject or spoof a field, and two agents "normalizing" differently would disagree about
whether two records match.

- **Encoding**: UTF-8. Each block is a contiguous run of lines with no blank line inside it.
- **`<handle>`**: `[A-Za-z0-9._-]{1,64}`. An identifier that resolves to an accountable
  person in the project's own terms; nothing verifies that it does (§13).
- **`<timestamp>`**: ISO-8601 UTC to seconds — `YYYY-MM-DDThh:mm:ssZ`. No local times and no
  bare dates, so no two readers can order or compare two records differently.
- **`<cycle-id>`**: `<YYYY-MM-DD>-<topic-slug>-<n>`, slug `[a-z0-9-]{1,48}`, `<n>` a positive
  integer.
- **`<pass-id>`**: `<cycle-id>/<gate>/pass-<p>`.
- **Free text** — `reason`, `authorizes`, a disposition's `<reason>`, a checklist answer:
  one line, at most **200 bytes after escaping**. Text that cannot fit the bound is
  **referenced, not truncated** — truncation silently changes what was approved — and text
  that cannot be escaped stops the close.
- **Escaping**, applied in this order: `\` → `\\`, newline or carriage return → `\n`,
  `·` (U+00B7) → `\·`, `|` → `\|`. **Unescaping applies the exact reverse order**, so a
  literal `\` before an escapable character cannot be misread as an escape it never was.
- **Parsing, parity-aware.** A separator counts as a separator **only when preceded by an
  even number (including zero) of consecutive backslashes** — otherwise `\\ · ` and `\ · `
  split identically and the record is ambiguous. A line splits on its first unescaped `: `;
  a value splits on unescaped ` · `; a `<key>: <value>` pair inside a value splits on its
  first unescaped `: `. **Unescape only after every split**, never before.
- **Lists** — `Profiles:`, `Passes completed:`, `Adverse findings:` — are `, `-separated,
  parity-aware in the same way, and their elements are **ordered**: story paths, pass ids and
  findings each sort ascending by byte sequence before the record is written, because
  otherwise two byte-different renderings of the same set would hash differently and §5.3
  would call an identical repeat a conflict.
- **Paths** in `Profiles:` and `Waived-target:` are repo-relative, `/`-separated, with no
  `.` or `..` component and no leading `/`.
- **Normalization, for the §5.1/§5.2 and §5.3 equality checks**: compare the **unescaped byte
  sequences** with leading and trailing ASCII spaces stripped. Nothing else — no case
  folding, no Unicode normalization, no whitespace collapsing inside a value. A permissive
  comparison is what lets two different handles or two different cycles match.
- **Accept/reject vectors are owed with the implementation**, not with this design: at least
  one case per escape, one odd-backslash case per separator, one over-length free-text case,
  one reordered-list case, and one case per marker field. A grammar with no vectors is a
  grammar two implementers will read differently.

**Digests.** All three — the **request digest**, the **checklist digest** and the
**diff digest** — are `sha256`, hex, lowercase, and computed over a **length-delimited**
serialization: each component is emitted as its decimal byte length, a `:`, then its exact
unescaped bytes, concatenated in the fixed order the defining section lists. Length framing
is not decoration — plain concatenation lets two different records hash identically by moving
a byte across a boundary, which is precisely the substitution the digest exists to detect.
The digest string appears in the record; the serialized input does not.

### 5.5 The waiver checklist record

The checklist (§3.1) is the only compensating evidence a zero-pass closure has, so it is a
**record**, not a claim that a record existed. It goes in the same commit body, below the
marker:

```
Waiver-checklist-record: <checklist-digest>
  <part>/<item> | answered | <answer>
  …
```

- **One line per item**, in a fixed order: the lens questions in the order §5 lists them
  (risk first, then security, with the dual-labelled abuse question once), then the invariants
  in `AGENTS.md` order, then `docs/prompt-standards.md` items 1–12 per changed prompt
  artifact, then the falsification lens and its size/value/position companion, then each
  stated self-check.
- `<answer>` is §5.4 free text — one line, 200 bytes, escaped. **The bound is the point:** an
  answer that does not fit is *referenced* (a path, a pass id, a query), which keeps the
  record bounded without letting an unanswerable item pass as answered.
- **`answered` is the only permitted verdict.** An item with any other verdict, or with no
  line, fails the precondition (§3.1(5)) — there is no exception class, because one
  free-text exception field would be a route around the whole checklist.
- The **`<checklist-digest>`** is §5.4's `sha256` over the item lines in order, and it is what
  the marker's `Waiver-checklist:` field and the request digest both carry.

**It travels the whole carry chain** (§6) exactly like the two blocks: restated on amend,
collected on a multi-WIP collapse, copied into the squash body, and validated before the
merge. Without that it would exist only in the session that produced it and vanish at the
first amend — leaving `Waiver-checklist: answered` as an assertion about a document nobody
can read.

## 6. Disclosure, and the carry chain

- **Gate A** → the **spec or plan commit body**; carried forward into the implementation
  cycle's closing body. If work stops before Gate B, that docs commit is already durable.
- **Gate B** → the **WIP commit body**.
- **The closing amend** replaces the WIP body wholesale **except** that disclosure content is
  restated explicitly. Nothing is preserved automatically.
- **The multi-WIP collapse**: every block collected, deduplicated by §5.3, validated before
  the replacement commit.
- **The squash body**: both blocks **and** every profiled story's evidence entry copied in.

**Two strategies are permitted, and they have different durable records.** The chain above
is the squash chain — `Gate-A docs commit → WIP → amend → squash → main` — where the squash
body is the only thing reachable from `main`. Under **ordinary merge** every branch commit
stays reachable, so the durable record is the **branch commit that already carries the
blocks**, and the merge commit carries nothing:

| | Squash | Ordinary merge |
|---|---|---|
| Durable record | the squash commit body | the Gate-A docs commit, or the amended Gate-B closing commit, reachable from `main` via the merge's second parent |
| Validated before the merge | the prospective squash body carries both blocks and every profiled story's evidence entry | every waived cycle's block pair and evidence entries are present in a reachable branch commit, and the branch head is the authorized one |
| Several waived cycles on one branch | collapsed per §5.3 into one body | left as separate commits, one block pair each — **no collapse**, because each already has its own durable commit |
| Merge-commit body | n/a | **no requirement, and no restatement.** A restated block that drifts creates two records on `main` that can disagree, with nothing to arbitrate |
| A block missing, found before the merge | merge refused | merge refused |
| A block missing, found after the merge | incident recovery (below) | incident recovery (below) |

**What immutability binds, and what it does not.** §3.5's "authorization is consumed by one
commit attempt" binds **that commit** — its parent, its tree, its message. It does **not**
freeze the branch. It cannot: a Gate-A waiver is followed by a plan commit and then the whole
implementation, so a rule voiding the authorization whenever the branch head moves would make
Gate A's waiver unusable under either strategy, and re-running the close at the final head is
impossible anyway, since that head contains the product paths §3.5 step 3 refuses. So:

- **Gate A** binds its own commit and its artifact blob. Later commits on the branch are
  expected and change nothing. What must still hold at merge time is that the waived commit is
  reachable and the artifact blob is unchanged (§4's continuation check is the same test).
- **Gate B** binds the final branch head, because the Gate-B closure *is* the head. A head
  that moves after authorization voids it, and the merge is refused until the close restarts.

Under either strategy the record is found the same way —
`git log --grep='Reviewer-tier: 3' <default-branch>` — which is why §2 names that query
rather than claiming ambient visibility.

**Validated before the merge**, per the rows above, and **the merge is refused if any block,
checklist record or evidence entry is missing**. Story AC 2 names the *cycle-closing commit*;
a later corrective commit cannot put blocks into a commit that already landed, so it satisfies
the criterion for no cycle.

**Incident recovery, and why a revert is not enough.** A commit that fails §3.5 step 8, or a
closure discovered after the fact to be missing its records, leaves a **valid-looking marker
in reachable history**: reverting the content does not remove the commit, and
`git log --grep='Reviewer-tier: 3'` keeps finding a closure this design calls invalid. So:

- **Before the branch is published**, repair history — amend or reset — so the invalid marker
  never becomes reachable from `main`. This is the preferred path and the usual one.
- **Once published**, history is not rewritten. A **`Reviewer-tier-3-invalidated:`** record is
  committed instead, naming the invalid commit sha, the check that failed, and the handle and
  timestamp of whoever recorded it. It reproduces the missing or corrected blocks verbatim so
  history is not silent.
- **The discovery query is therefore two-step, and the design says so rather than pretending
  the grep is sufficient**: collect the tier-3 markers, then collect the invalidation records
  and subtract the shas they name. A marker whose commit appears in an invalidation record is
  not a closure. This is a convention read by a human, enforced by nothing.

Either way the incident is recorded as a **disclosure failure, not as compliance**.

**Rebase-merge and cherry-pick are refused before the waiver**, not discovered after it.

**Never in the findings file.**

## 7. Old-condition inventory — CLAUDE.md §5

Fifth attempt. **The previous four each claimed exhaustiveness and each was wrong** — three
were thematic compressions, and the fourth, which claimed a clause-by-clause derivation, still
omitted six conditions (rows 82–87 below).

**So this version claims a derivation, not a property.** It was produced by walking every
normative sentence of `CLAUDE.md` §5 in order — including the Profiles and Mechanics
subsections — and emitting a row per sentence that constrains behaviour, splitting a sentence
whose clauses have different effects. That is a procedure a reader can repeat and check. It is
**not** a guarantee of completeness: nothing mechanical derives these rows, §5 changes, and
four predecessors were confident and incomplete. If you are relying on this table, re-walk §5.

Every disposition is judged **by effect, not by the noun used**: calling an operation a waiver
rather than a skip does not preserve a condition about skipping. Rows a previous version got
wrong are **[corrected]**; rows a previous version **omitted entirely** are **[added]**.

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
| 33 | Recovery: one attempt per pass, shared | **[corrected] Narrowed** — the shared one-attempt budget is kept and is never doubled, but the precondition it feeds is **per source** (§3.2): `attempt-failed` consumes call **plus** recovery, `quota-observed` needs one canonical call, and a defective call consumes nothing. §3.5 step 6's post-answer probe spends the *same* attempt, not a second one. A previous version stated a spent recovery as a blanket tier-3 precondition |
| 34 | Recovery is a fresh re-run deleting exactly what it rewrites | **Kept, untouched** |
| 35 | Resume preferred only when the write failed; pass `sessionId` + `reviewType` | **Kept, untouched** |
| 36 | Spent and still incomplete → STOP and surface | **[corrected] Narrowed** — the diagnostic steps are kept, but tier 3 permits continuation after a spent attempt instead of terminal escalation. A previous version marked this untouched |
| 37 | Hook counting residuals are not evidence | **Kept, untouched**; §4 relies on it |
| 38 | Discount every incomplete pass whatever the counter says | **Kept, untouched** |
| 39 | Gate A is two runs, each its own loop | **[corrected] Kept at tier 1; narrowed at tier 3** — the two independent cycles remain and tier 3 is available to each, but either may close with **zero passes** and therefore without entering its loop at all. A previous version marked this kept outright, which is the effect-level change hidden under an untouched noun |
| 40 | Prompt opens with the brainstorming directive | **Kept, untouched** |
| 41 | One broad prompt, re-run each pass over the revised artifact | **Kept, untouched** |
| 42 | Append intent, artifact text, and which invariants it touches | **Kept, untouched** |
| 43 | Every finding with severity and confidence; you filter, Codex never does | **Kept, untouched** |
| 44 | Mechanical sweep before each read pass | **Kept**, and promoted to a Gate-A waiver precondition (§3.1) — explicitly as **syntax hygiene**, never as the compensating evidence |
| 45 | Optional focused per-dimension passes on large artifacts | **Kept, untouched** |
| 46 | Gate B: tests green, before commit | **Kept**; the battery is a Gate-B waiver precondition |
| 47 | Gate B tool and args: `instruction`, `whatWasImplemented`, `baseSha`; `full` runs both | **Kept, untouched** |
| 48 | `baseSha` from a WIP commit; `WIP:` naming; amend to close; `reset --soft` for several | **Kept**, and §6 adds what the collapse must carry |
| 49 | Skip ONLY trivial changes | **[corrected] Narrowed** — by effect a non-trivial change can now close without review; the noun differs, the effect does not |
| 50 | Re-review after every fix | **[corrected] Narrowed for tier 3** — §3.1(2) permits closing after a remediation that no independent reviewer ever sees. The marker records the remediation and the `OWED` line covers it; a previous version marked this untouched |
| 51 | A fix changing specified behaviour updates the spec in the same commit | **Kept, untouched** |
| 52 | The standing falsification lens — which existing statements does this diff falsify? | **[corrected] Narrowed** — kept at tier 1, where it rides on the Gate-B prompt. A zero-pass closure has no prompt, so it is asked by the human in §3.1's checklist instead; a previous version marked it untouched while tier 3 dropped it entirely on the one path with no independent reader |
| 53 | Name what the diff changes the size, value or position of, and grep for where each is described elsewhere | **[corrected] Narrowed** — same as row 52, and the checklist record (§5.5) must carry the search performed and its hits, not just the answer |
| 54 | Prose-vs-product classification | **Kept, untouched** — no file changes classification in this design |
| 55 | Risk lens set: threats, abuse, rollback, data loss, idempotency, compatibility, observability | **[corrected] Narrowed** — kept at tier 1; at tier 3 there is no reviewer prompt to append them to, so they are asked by the named human in §3.1's waiver checklist instead. Answered by a different actor, in a different artifact — not untouched |
| 56 | Security lens set: assets, trust boundaries, roles, external systems, abuse paths | **[corrected] Narrowed** — same as row 55, and §13 records that the answers are self-audit rather than independent review |
| 57 | Both axes → union appended once, abuse carrying both labels | **[corrected] Narrowed** — the union-once rule and the single dual-labelled abuse question are kept, but at tier 3 they govern the checklist, since there is no prompt to append to |
| 58 | Lenses are different questions, not more passes | **Kept** — the checklist asks the same questions and adds no passes; at tier 3 there are none to add |
| 59 | Profile: story header is the single writable copy | **Kept** — no value is copied anywhere |
| 60 | Three profile-reading cases | **[corrected] Narrowed for tier 3** — the three cases are kept, but §3.1(4) changes what they are read against: the **union of story paths across the cycle**, not the artifact's citation at waiver time. Only a cycle that never cited a story is `none-cited`; a path that appears earlier and is gone at the waiver is **unresolvable**, not unprofiled. A previous version said tier 3 "needs no citation", which made dropping one a way to shed a `high`-risk profile |
| 61 | Stop and surface on an unresolvable profile | **Kept**, and **strengthened**: §3.1(4) makes fresh resolution of every cited story a tier-3 precondition at **both** gates. A previous version left it kept-untouched while the zero-pass path never forced resolution at all, so a malformed high-risk profile was bypassable precisely where no reviewer looked |
| 62 | Gate-B triviality skip needs two independent conditions | **[corrected] Narrowed** — the two-condition rule is kept **within tier 1**, but at the level of the decision procedure tier 3 opens a second route by which a non-trivial change closes without review, with its own preconditions (§3.1) and its own disclosure (§5.1). Marking it untouched because "a waiver is not a skip" is exactly the noun-based accounting row 49 rejects |
| 63 | The skip reason is recorded in the commit body | **Kept, untouched**; the waiver marker is a separate record |
| 64 | A skip removes the review, never the evidence | **Kept**, and tier 3 follows the same principle (§3.1) |
| 65 | A cycle citing several stories aggregates per story | **Kept**, and applied at the waiver: §3.1's Gate-B row requires per-story satisfaction, one battery, unioned lenses, one entry per profiled story |
| 66 | What the author owes by mode | **Kept**, gate-appropriately (§3.1) |
| 67 | A named verification may substitute for an automated check | **Kept, untouched** |
| 68 | The counterfactual, and the wiring that could produce it | **Kept**, and applied to this change (§10) |
| 69 | An unobservable counterfactual is a blocking evidence gap | **Kept, untouched** — and **not** invoked here: §10 specifies the probe that makes the counterfactual observable, and §11 records the withdrawn override that assumed it was not |
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
| 82 | **[added]** Gate A runs on the spec right after brainstorming (before `writing-plans`) and on the plan before `executing-plans`/`subagent-driven-development` | **Kept** — the placement is unchanged; §4 adds the continuation rule at both of those transitions because that is where the reminders arrive |
| 83 | **[added]** The pre-pass mechanical sweep settles only what a machine can decide **without side effects**, and does **not** run commands quoted in the artifact — a quoted command may be destructive or an intentional failure | **Kept, untouched**, and load-bearing at tier 3: §3.1 promotes the sweep to a precondition, so its no-side-effects limit now guards a path with no reviewer. Omitted by the fourth inventory |
| 84 | **[added]** Gate B checks the diff against `AGENTS.md` explicitly | **[corrected] Narrowed** — at tier 3 no reviewer performs it, so the invariant-by-invariant part of §3.1's checklist carries it. Omitted by the fourth inventory, which marked the invariants only as lens content |
| 85 | **[added]** Companions may be deleted or rebuilt; the findings file plus terminator is the only hard requirement | **Kept** — and rider (b) (§9) is the one named scope where a companion's **absence** discounts a pass, already recorded at row 29 |
| 86 | **[added]** The only early exit below the floor is a pass with **zero** findings; don't manufacture findings to pad | **Kept** as a distinct clause at tier 1, and **N/A** at tier 3, which is not an early exit but a closure with no pass at all. Rows 13 and 14 covered the padding half and the exit half separately; neither stated the clause itself |
| 87 | **[added]** If revalidation changes the evidence entry, the clean pass no longer covers what is being committed — fix, re-review, close on the entry that pass validated | **[corrected] Narrowed for tier 3** — there is no clean pass to invalidate, so the analogue is §3.5: a changed entry after step 4 voids the authorization and the close restarts. Omitted by the fourth inventory |

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
| `docs/coding-workflow.md` ~253–268 § *What is essential — keep it* / *Minimal viable adoption* | Names "the two independent review gates" as load-bearing and "one independent code-review gate" as a day-one minimum. Tier 3 makes both waivable, so the passage gains the exception rather than continuing to teach an unconditional invariant. Missed by earlier drafts, which stopped at the stage-level passages |
| `docs/pr-review-bots.md` ~141 | "**Every head reaching a PR has already passed Gate B**" — the premise under which an absent opportunistic-bot review blocks nothing. A tier-3-waived head falsifies it, so the premise is **narrowed** and the routing states how a waived Gate B is treated: the PR bots become the *only* automated review of that head, which is a reason to read them, not a reason to promote them to **Wait for** |
| `docs/sparring-briefing.md` ~41–44 | **"Advisory, never exempt… do not treat a satisfied human as a substitute for a clean pass."** Tier 3 is exactly that, so this is **overturned here**, not moved to the tier-2 story as the story's first amendment wrongly said |
| `README.md` product summary and daily-use pipeline | The mandatory-gate claim gains the exception |
| `plugins/dev-workflow/.claude-plugin/plugin.json` | Its description carries the same claim |
| `.claude-plugin/marketplace.json` — the **top-level `description`**, not the plugin entry | "Cross-model review workflow: **independent Gate A/B review**, …". The plugin entry at line 14 lists components and makes no such claim; an earlier draft cited the wrong field, and this pass's mechanical sweep caught it |
| `AGENTS.md` § *What this project is* | Gains a clause admitting the waiver |

**`docs/coding-workflow.md` ~149 is NOT changed** — its "makes the gate mandatory" is the
repo-enforced **quality** gate, not the review gate. An earlier draft listed it, which would
have weakened an unrelated guarantee.

**Two new files are added, and both need tree entries.** §10.1's structural oracle is an
executable check — `scripts/check-waiver-prose.sh` — with a regression suite beside it,
`scripts/check-waiver-prose.test.sh`, matching the convention the two existing repo-local
checkers already follow. Both go in `AGENTS.md`'s architecture tree and in its § Commands
battery row, because that row claims to be what CI runs. This is stated explicitly because an
earlier draft of this design added a file and omitted the tree, and a later one asserted "no
new file is added" — which §10.1 falsified the moment the oracle became mechanical. The
alternative was to keep the check judgement-based, which is what pass 2 rejected.

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

**Check that fails without the change — two halves, one mechanical and one observational.**
An earlier draft claimed the counterfactual was unobservable and took a scoped mode override;
**both the claim and the override are withdrawn**. A later draft replaced them with "a
prompt-harness scenario", which named no runner, no fixture and no oracle — the same
unverified-evidence claim in a new place. A third specified scenarios but still rested the
whole result on a probabilistic model's agreement with itself.

**So the check is split, and each half is claimed at exactly its own strength.**

### 10.1 The structural oracle — mechanical, deterministic, the load-bearing half

A shell check over the two frozen texts, run by the same battery that runs everything else.
It decides only questions a parser decides, and it is the half that can **fail closed**:

| Assertion | On `OLD` | On `NEW` |
|---|---|---|
| §5 contains a closure path whose preconditions are an enumerated list | absent | present, and the enumeration has exactly the items §3.1 names |
| The severity enum is stated as a closed set of tokens, not shown by example | absent | present, all four tokens |
| Every marker field §5.1 defines appears in the template §5 ships | n/a | all present, none extra |
| The `/workflow-init` inline mirror and §5 agree on all of the above | trivially | byte-identical after the documented extraction |

**Failing without the change is structural, not interpretive**: run against `OLD`, rows 1–3
fail. This half needs no model, reruns identically forever, and is what the evidence entry
leads with.

### 10.2 The prompt-differential probe — observational, and claimed as such

The oracle establishes that the prose *says* the thing. It cannot establish that a reader
*acts* on it, which is the risk this change actually carries. The probe addresses that, and
its claim is bounded accordingly.

**Frozen inputs**, by blob sha, never paraphrased: `OLD` = `git show <baseSha>:CLAUDE.md`,
`NEW` = `git show <headSha>:CLAUDE.md`.

**Driver, pinned** — invariant 5 applies to anything that executes in a run, and a probe is a
run. The evidence entry names the exact CLI package at an exact version, an exact model id
(never an alias), temperature 0, a fixed seed where the runtime accepts one, a fixed timeout,
and a sanitized environment: an empty scratch directory, no project files, no `CLAUDE.md` on
any parent path, no MCP servers, no tools. The prompt is assembled from the frozen blob plus a
scenario file byte-for-byte, with a documented delimiter, and both are stored with the run
output. Anything unpinned makes two implementers' probes incomparable while both record the
expected verdicts.

**Scenarios.** Each supplies the §5 text, a **fully sequenced transcript** reaching one exact
decision point, and one question demanding a first-line verdict token.

| # | Transcript reaches | Question | `OLD` | `NEW` |
|---|---|---|---|---|
| **S1** | The end of §3.5 step 6: mid Gate-A-spec cycle; pass 1 complete, 3 findings, all remediated, ledger establishable; **one** canonical `mcp__codex__exec` call returned quota exhaustion (so `quota-observed`, one call — not a recovery); profile resolves; checklist answered, all items; parent fixed; dedicated index read-tree'd and written; changed paths docs-only; request digest computed; human returned the digest and authorized; post-answer probe repeated quota exhaustion 4 minutes later; squash | *"Under the procedure above and nothing else, may the closing commit be made now? Answer `CLOSE` or `REFUSE` on the first line, then quote the clause you relied on."* | `REFUSE` | `CLOSE` |
| **S1-neg-1…13** | S1 with **exactly one** thing wrong: unremediated Major · stuck review · unresolvable profile · story path dropped since cycle start · unestablishable ledger · an unanswered checklist item · rebase-merge · a product path among the changed paths · post-answer probe **succeeds** · revalidation 40 minutes stale · `HEAD` moved off the fixed parent · index not initialized from the parent · digest recomputes differently | same | `REFUSE` | `REFUSE`, **quoting that clause** |
| **S2** | A findings file with four findings at severity `IMPORTANT`, correct count and terminator, **and** a dispositions file present but carrying **no** enum-drift record | *"Is this pass acceptable? Answer `ACCEPT` or `INCOMPLETE` on the first line, then quote the clause."* | `ACCEPT` | `INCOMPLETE` |

**S1's call budget matches §3.2**: one canonical call, `quota-observed`. An earlier version
spent a recovery attempt there, which the new procedure only permits for `attempt-failed` —
so the frozen positive case violated the procedure it was meant to confirm, and `NEW` could
have returned `REFUSE` for the right reason and the wrong finding.

**S2's `OLD` verdict is the weak one, and is stated as weak.** Old §5 says findings come "one
per line in the format above", whose example severity is `MAJOR`; a careful reader could call
`IMPORTANT` structurally invalid *before* the change. So S2 is **corroborating, not
load-bearing** — 10.1's row 2 carries the rider (b) claim mechanically, and S2 is reported
with its ambiguity named rather than counted as a clean differential.

**The thirteen negative variants are what make the probe non-vacuous.** S1 alone passes on any
prose that merely permits closure; each negative fails if the corresponding clause is stated
loosely, so the probe can fail for a reason other than "the text changed".

**Repeatability.** Every scenario runs **three times per input** in independent sessions, and
**all three must agree**. A split verdict is a **failure**, not a retry: it is evidence the
prose does not determine the answer. The remedy is to fix the prose.

**Failure semantics.** Any oracle assertion failing, or any S1 / S1-neg scenario missing its
verdict → the check fails → `battery+check+verification` is unmet → **Gate B is not called**.
No majority rule, no rerun budget, no partial credit. S2 is reported, not gating.

**What each half establishes — calibrated to the comparison actually performed.**

- **10.1 establishes** that the shipped text contains the named structures and that the two
  copies agree. That is a string comparison, and the claim is exactly that large.
- **10.2 establishes** that **one pinned model, under frozen inputs, emitted these verdicts in
  three of three runs**. It does **not** establish that the procedure's semantics compel the
  verdict, that a different model would agree, or that a *compliant* reader must conclude the
  same — a model is not a proof of meaning, and three agreeing samples from one distribution
  are not three witnesses. Read as evidence it is real; read as proof of semantics it would be
  the overclaim §13 and the gate-proof Don't both forbid.
- **Neither half establishes enforcement.** A non-compliant agent is prevented from nothing
  (§13). No git operation, hook or script is exercised, because this change contains none.

**The counterfactual, and the wiring that could produce it.** If the claim were false — if the
old procedure already authorized a zero-pass closure — 10.1's rows 1–3 would pass on `OLD` and
S1 would return `CLOSE` on `OLD`. The wiring can produce those observations: `OLD` is the real
prior blob supplied whole and unedited, the oracle's assertions are evaluated against it by
the same code path, and the verdict token is read from the model's own first line rather than
supplied by the probe.

**The result is recorded in the evidence entry**: both blob shas, the pinned CLI version and
model id, the run count, the oracle result, and the per-scenario verdicts.

**Named verification.** The matrix describes **observable behaviour of the procedure followed
correctly**. It does **not** claim enforcement: §13 states an agent departing from the
procedure can produce a conforming-looking commit, and no row should be read as a mechanism.

| Case | Observed outcome when the procedure is followed |
|---|---|
| Gate-A spec waiver | marker **and** decision block in the spec commit body; identifiable from history alone |
| Gate-B waiver | both blocks survive WIP → amend → squash; readable from `main` alone |
| Decision block absent | non-conforming; each block validated independently |
| Handle / timestamp / gate / cycle mismatch across blocks | close stops (§5.2) |
| Repeated or resumed close | identical blocks collapse; conflicting blocks stop the close |
| Multi-WIP collapse | all blocks collected and validated |
| Prospective squash body missing a block, the checklist record or an evidence entry | **merge refused** before it lands (§6) |
| Waiver after an unremediated Major | procedure refuses (§3.1(2)) |
| A checklist item unanswered | procedure refuses; there is no exception verdict (§3.1(5), §5.5) |
| Waiver during a stuck review | procedure refuses (§3.1(3)) |
| Gate-A waiver, sweep red | procedure refuses (§3.1) |
| Gate-B waiver, battery red | procedure refuses (§3.1) |
| Tree, entry, checklist record or marker field changes after authorization | authorization void; all steps repeated (§3.5) |
| Committed parent, tree **or message bytes** differ from what was authorized | **incident** — not a valid closure (§3.5 step 8); repaired before publication, or invalidated by record after (§6) |
| A **changed path** at Gate A is a prompt, script or code path — added, deleted, renamed, mode- or type-changed | Gate-A waiver refused outright (§3.5 step 3) |
| Reviewer recovers **during** the human pause | the post-answer probe catches it; waiver refused (§3.5 step 6) |
| Revalidation older than 15 minutes, or `HEAD` no longer the fixed parent | close restarts at step 1 (§3.5 step 6) |
| Dedicated index not initialized from the parent | the written tree deletes unstaged tracked paths — the data-loss path §3.5 step 3 exists to prevent |
| A prior pass's findings file missing or truncated | counted as unresolved adverse evidence; waiver refused (§3.1(2)) |
| A governing story's profile unresolvable, **or a story path dropped since cycle start** | stop and surface — not a waiver, and never `unprofiled` (§3.1(4)) |
| Pass ledger not establishable — resumed session, colliding slot, sequence gap | waiver refused; `Passes completed: none` may not be written (§3.1(2)) |
| A defective call — wrong tool, stale range, failed findings write | not an outage observation; corrected and re-sent, no recovery consumed (§3.2) |
| Fresh failure matching no enum row | STOP and surface; no waiver (§3.2) |
| A-plan marker present at `executing-plans`, plan blob unchanged | that reminder is cleared, whenever derived, for that plan (§4) |
| A-spec marker present at `writing-plans`, spec blob unchanged | that reminder is cleared, whenever derived, for that spec (§4) |
| Waived artifact edited after its waived commit | blob mismatch; no authorization, the reminder stands (§4) |
| A-spec marker found where an A-plan marker is required | no authorization; the reminder stands (§4) |
| `attempt-failed` revalidated with one call only | insufficient; the source needs call **and** recovery (§3.2) |
| Authentication failure at any point | configuration error to repair — never a waiver (§3.2) |
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
  happened, or the third waiver in one repository — whichever comes first.* §2's table prices
  the three alternatives that were considered and rejected, so whoever takes this row starts
  by re-pricing one of them rather than rediscovering the option space.
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
- **`AGENTS.md` § Commands and § Architecture both change** — `scripts/check-waiver-prose.sh`
  and its suite join the battery row, the lint row (`shellcheck --shell=sh`) and the tree
  (§8). The battery row is the one CI mirrors, so a check added to one and not the other is
  the drift invariant 11's prose-conformance checks cannot see.
- Version **0.8.2 → 0.9.0** with a `plugins/dev-workflow/CHANGELOG.md` entry — invariant 12. **This will be
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
- **The waiver checklist is self-audit.** §3.1 makes the profile's lens sets, the invariants
  and the 12 prompt standards get *asked* at tier 3, by a named human, in writing. It does
  not make them get asked by someone independent of the work — that is precisely what tier 1
  buys and tier 3 cannot. A checklist answered honestly is worth having; a checklist answered
  to clear a gate is worth nothing, and nothing distinguishes them from history.
- **Every "procedure refuses" row in §10 is behaviour of a compliant agent**, never a
  mechanism preventing a non-compliant one.
- **The hook forces nothing.** It emits a reminder and exits 0.
- **Nothing detects availability's return** outside the pre-close revalidation.
- **`main`'s history can be rewritten.** A force-push can remove a marker.
- **Rollback is not one operation, because the prompts ship to three places.** Reverting this
  repository removes the procedure *here* and leaves existing markers standing as records of
  what happened — that part is simple, and no state file exists to migrate. The other two are
  not:
  - **Installed plugin copies** live under a version-keyed cache path, so a revert on `main`
    reaches no machine until each user updates. Until then a machine keeps running the tier-3
    procedure with no signal that it was withdrawn — the same staleness invariant 12 exists
    for. Rollback therefore means a **version bump that removes the feature**, announced in
    `plugins/dev-workflow/CHANGELOG.md`, not a revert commit.
  - **Scaffolded downstream copies.** `/workflow-init` writes an inline §5 into each
    initialized repository, and those copies are the user's file, edited thereafter. Nothing
    detects them and nothing migrates them: a revert here leaves tier 3 documented and live
    in every project already initialized, with no matching upstream documentation. The honest
    answer is that downstream removal is **manual and unprompted** — the CHANGELOG entry is
    the only notification, and this is a cost of invariant 8's inline-template design, not a
    defect introduced here.
  - **In-flight authorizations** are unaffected either way: authorization is consumed by one
    commit attempt (§3.5) and nothing survives a session, so there is no authorized-but-unspent
    state for a rollback to strand.
