# Reviewer-availability fallback — closure record, and what ships — Design

**Story:** `docs/superpowers/stories/2026-08-13-reviewer-availability-fallback-story.md`
— the story header is the single writable copy of the profile. Every gate call carries that
path and reads the axes, the mode and the lens sets fresh from it; this document never
restates them as values.

**Status: the design question is closed with a negative answer.** Three design cycles across
nine Gate-A passes failed to produce a safe authorized zero-pass closure. §1 records the
finding and its evidence, because the finding *is* the result. §2 specifies the small thing
that survives — which, after Gate-A pass 1 of this cycle, is **narrower than the first draft
of this section made it**: see §2.0.

## 1. The finding

**No safe design for a sanctioned zero-pass gate closure was found, and each of the three
classes tried failed for a structural reason rather than an incidental one.**

### 1.1 What "safe" was required to mean

The claim is only as sharp as the properties it is measured against, so they are named. A
sanctioned zero-pass closure would have had to be:

1. **Grounded** — the condition that justifies it (the reviewer cannot run) is *established*,
   not asserted, and not producible on demand by whoever benefits.
2. **Guarded** — its preconditions are decidable in the situation it fires in, not only in
   situations where the gate was available anyway.
3. **Bounded** — it closes the one cycle it was granted for, and does not become a general
   route past review.
4. **Attributable** — the record identifies who decided, durably, in a way a later reader can
   weigh.

Properties 1 and 2 are where every cycle died. Property 4 was never achieved beyond an
unverified assertion, which §2.1 now says out loud rather than working around.

### 1.2 The evidence

| Cycle | Shape | Blockers by pass | Findings | Outcome |
|---|---|---|---|---|
| Three-tier | tier 1 / tier 2 same-family reviewer / tier 3 human | 4 → 4 → 6 | 116 | stopped |
| Two-tier + debt | tier 1 / tier 3, with a tracked re-review debt | 7 → 8 → 12 | 96 | stopped |
| Stripped | tier 1 / tier 3, no state at all | 4 → 14 → 15 | 91 | stopped |

**303 findings across nine passes. None was ever dismissed.** The per-pass artifacts sit in the
current worktree under `.context/codex-reviews/*.stopped-3tier.md`, `*.stopped-2tier-debt.md`
and `*.stopped-tier3-core.md` — the last including the rejected 1016-line design in full.
**Those are ephemeral**: `.context/` is git-ignored, so they do not survive a clone and slot
collisions have already destroyed some. Everything a later reader must be able to rely on is
therefore *in this section*, not behind those paths; the files are corroboration while they
last, not the record.

### 1.3 The three failure modes, mapped to the design class each defeated

**Unenforceable, or recursive — defeats compensating state that the repository itself
authors.** Every
control added to make the waiver safe landed as a prose assertion authored by the party being
waived, or as real state that itself needed the gate that was unavailable. Cycle 2 died of
this in its debt machinery; cycle 3 removed that machinery entirely and pass 3 landed the
identical pair on the core. **Structural, because** among the **repository-controlled**
mechanisms considered here, the gate is the only one available to protect the record of its
own waiver. Authority held outside the repository is expressly outside this conclusion (§1.5).

**The outage is manufacturable — defeats property 1 for any client-observed trigger.** Cycle 3
narrowed the evidence to canonical calls, removed `auth-failed` because withholding a
credential fakes an outage, then removed `status-page` as unreachable. Pass 3 showed the same
argument defeats what remained: deliberately exhaust the quota, point at a spent account,
block DNS. A local transport failure does not establish that the vendor answered. **Structural,
because** the approver may be the author, so the condition authorizing the waiver is
producible by whoever benefits from it.

**Unprotected local history cannot establish the preconditions in the case they exist for —
defeats property 2.** The
central precondition (no unresolved adverse findings) needs to know which passes happened.
Nothing durably records that: session memory is not evidence, `.context/` slot names collide,
the hook counter is explicitly not evidence, and at Gate A no prior commit body exists. So
`Passes completed: none` can never be *established* precisely when it is true, and accepting
"none observed" reopens the path where a lost adverse pass is laundered into a clean closure.
**Structural, because** proving a negative about review history requires *protected* history,
and history the repository authors returns to the first failure mode. Externally protected
history is a different class and was not tried (§1.5).

### 1.4 What the fixes did

The stripped cycle's artifact went 489 → 750 → 1016 lines across two rounds of remediation. A
prose amendment to §5 acquired a git algorithm — a dedicated index, `read-tree` from a fixed
parent, changed-path classification, a ref compare-and-swap, a three-way commit read-back,
squash-carry envelopes and an invalidation-record convention. Pass 3 found five defects
**inside that algorithm**, and one above it: none of that logic was exercised by any
validation, so the mode's evidence obligation was unmet for a risk path the fixes had created.

Meanwhile that design's own "What this does not do" section conceded throughout that nothing
verifies the human pause, that every record is a recorded assertion, and that an agent
departing from the procedure produces a conforming-looking commit. **The machinery was *intended* to protect the record against
accident — no comparison here establishes that it did, and pass 3 found five defects in it —
while the finding was that the record cannot be protected against intent.**

### 1.5 What this finding does and does not claim

**Does claim:** three design classes — **repository-authored** compensating state,
**client-observed** outage triggers, and **unprotected local** history as a source of
preconditions — each failed for a reason inherent to a prompt-only product rather than to the
particular draft. The qualifiers are load-bearing: externally protected state is still
compensating state and can establish history, and nothing here was tested against it.

**Does not claim:**

- **Not a proof of impossibility.** Nine passes over three related designs establish repeated
  structural failure, not exhaustion of the design space. A class not tried here — notably one
  resting on authority *outside* the repository — is untouched by this evidence.
- **Not that a human exception is wrong.** Humans make them, correctly. §2 ships the form.
- **Not that no enforcement is possible anywhere.** Authority held outside the repository is
  the untried class. It is a **candidate, not a proof**: a signature establishes property 4
  only with a trusted signer identity *and* a role policy saying which identities may approve,
  since an ordinary signer can be the author. A platform **protected-branch approval** can
  establish property 4 more directly — an authenticated approver under an enforced,
  named branch policy — but establishes **nothing about property 1**, because an approval
  says nothing about whether the reviewer was available. Property 1 needs an availability
  attestation from a party that is not the author, which neither mechanism supplies. Parked in §6 with its trigger, and with those requirements named so the next
  attempt starts from them.
- **Not that the three cycles found every defect.** They found enough.

### 1.6 Two lessons about revising a spec, learned expensively here

Recorded because they cost eight passes of the salvage cycle to see, and neither is specific
to this feature.

**Cutting a requirement is not like cutting an answer.** Removing the drift record removed an
*obligation*, and the finding count fell (20 → 16). Removing the `Ref:` identifier removed an
*answer to a question the document had already asked* — "which record is this?" — and the count
rose (16 → 17), with six findings caused by the cut itself, because the question was still
standing and every dependent rule now dangled. **Delete the question, not just the answer.**

**A spec must not ask mechanical questions about artifacts only humans read.** Eleven of pass
8's seventeen findings were in three sections specifying procedures no tool executes: how to
anchor-extract and normalize Markdown before diffing two prompt copies, how to order evidence
entries across a squash range, how to establish a commit-body record's identity. Every answer
to such a question is prose about prose — unenforced, unexecuted, and reviewable forever. The
honest form is an instruction plus the admission that nothing checks it. *(Candidate for
`docs/prompt-standards.md` when the field-intake round runs.)*

## 2. What ships — the record form of a human exception

### 2.0 The scope correction, and why it is the load-bearing part of this section

The first draft of §2 wrote the form as covering *"a pass short of the floor, an absent bot
review, a check that could not be run"* while asserting that it authorized nothing. **Gate-A
pass 1 of this cycle rejected that as a distinction without a difference** (blockers 1 and 11):
a normative instruction shaped *"when a human decides to proceed past X, write this"*, plus a
required commit form, plus §6 routing the stall through it, is operationally a route past the
gate no matter what the surrounding sentence says. A compliant agent reads human assent plus
three lines as sufficient to continue after §5 says STOP — which is exactly the waiver §1
found unbuildable, re-entering through the prose.

**And the precedent it named turned out not to be one.** Pass 1 corrected the first draft by
pointing at PR #14 — a merge past an absent supplementary bot review on a change that had
already passed Gate B. Pass 5 corrected that in turn, and pass 6 corrected the correction:
#14 happened while CodeRabbit was under **Wait for**, where `docs/pr-review-bots.md` makes the
review required **unless** an explicit recorded human decision permits proceeding without it.
The two are alternatives, not a conjunction — #14 had no review and took the recorded-decision
branch. So #14 was a mandatory rule being consciously answered by the mechanism that rule
provides, which the boundary above puts out of reach: this form is not that decision. #14 is therefore history, not
derivation: it shows that humans make exceptions and that recording them is worth doing, and
nothing more. The form is justified on its own terms below.

**So the form is scoped by the optional-work boundary itself, and no further:**

> **It applies only to work that no applicable rule required.** Not a gate, a floor, a pass
> count or a profile-derived evidence obligation — and equally not anything required by
> `AGENTS.md`, a project doc, CI, a branch policy or the platform. The source of the
> obligation is irrelevant; that it *was* an obligation is decisive.

**Stated that way, not as "where the gates are satisfied"** — pass 2 found that phrasing
temporally impossible: §2.4 places a record in a Gate-A spec commit, at which point the later
Gate-A run and Gate B are not satisfied and cannot be. The boundary is not *when* the record
is written but *what it is about*: something nothing required. A Gate-A spec
commit may carry a record about an absent supplementary bot review; it may not carry one about
its own gate, before or after.

That is not a softening of the first draft — it is the difference between a record and a
waiver. It also makes §4's claim true: with core-gate cases excluded, `docs/getting-started.md`
("Gate A is not skippable at any level"), `docs/coding-workflow.md` ("mandatory… not optional") and
`docs/sparring-briefing.md` ("do not treat a satisfied human as a substitute for a clean pass") are
all still true as written, with nothing to amend.

### 2.1 The paragraph added to CLAUDE.md §5

One paragraph, in Mechanics, beside the evidence-entry rule:

> **Recording a human exception.** Where a human decides that something **no applicable rule
> required** was nonetheless worth skipping — an optional check this environment cannot run, a
> review someone asked for and then stood down, a courtesy step — that decision goes in the
> closing commit body:
>
> ```
> Human exception: <handle> · <date>
> Not done: <what was skipped, specifically>
> Accepted because: <one line>
> ```
>
> **Which commit:** an ungated change records it in that commit; a Gate-A cycle in the spec or
> plan commit; a Gate-B cycle in the WIP commit, restated by the closing amend. Several records
> accumulate; order means nothing.
>
> **A decision made after its commit closed** — during PR review, say — goes in whichever of
> these exists: the next commit on the branch, the squash body, or a follow-up commit after the
> merge. If none does — the branch is closed, unmerged, and heading for an ordinary or rebase
> merge — **add a commit for it.** An empty commit carrying only the record is a legitimate
> destination and does not reopen any gate: it changes no content, so it raises no review
> obligation. A record with nowhere to go would otherwise be a record that does not exist.
>
> Copy every record into the squash body alongside the evidence entry (Mechanics,
> squash-merge carry). **Nothing performs that carry and nothing checks afterwards that it
> happened** — it is on whoever prepares the merge. If two copies of one record disagree, that
> is a copying error: stop and fix it rather than picking one.
>
> **Scope, and it is narrow. This form supplies no permission.** It records a decision that
> was already the human's to make about something genuinely optional. It is **never** the answer to a
> below-floor pass, an unclean final pass, a `STOP and surface`, a Gate-A or Gate-B
> obligation, or a profile-derived evidence requirement — and more generally **it authorizes
> nothing that any mandatory rule in this file or in `AGENTS.md` requires.** Those have their
> own terminal actions and this paragraph changes none of them: on a STOP you still stop, and
> neither a human's assent nor this record lets an agent close or continue a cycle.
>
> **"Mandatory" is not limited to this file.** A rule in `AGENTS.md`, a project doc, CI, a
> branch policy or the platform is equally out of reach — under **Wait for**,
> `docs/pr-review-bots.md` requires a bot review unless an explicit recorded human decision
> permits proceeding without it, and this form is not that decision. If you are reaching for it to get past something mandatory, the answer
> is no — take the operational route or stop.
>
> **Nor is it for things that were simply never owed.** An absent review from a bot routed
> **opportunistically** blocks nothing and needs no exception and no record;
> `docs/pr-review-bots.md` says so deliberately, and writing one anyway would rebuild the
> per-quiet-bot ceremony that routing removed. Record a decision, not a non-event.
>
> **What the record is worth.** It is an **unverified assertion**, and reads as one: nothing
> checks that the handle belongs to whoever decided, that a human was asked, or that the
> reason is honest. A reader of history learns that *the commit claims* a human chose, what
> it says was skipped, and why — no more. It supports no claim of authorization or review,
> and satisfies no evidence obligation. It exists because an exception nobody wrote down is
> invisible, not because writing it down makes it sound.

### 2.2 What that paragraph is not

- **Not a gate waiver.** It does not clear the hook, satisfy a floor, or make an unreviewed
  change reviewed. §5's gates are unchanged in every particular.
- **Not a decision procedure.** It is retrospective bookkeeping about a decision already
  legitimately available; it adds no branch to any of §5's stop conditions.
- **Not a permission with preconditions.** It has a strict **applicability boundary** — §2.0,
  and that boundary is absolutely a condition on using the form. What it does not have is a
  set of conditions whose satisfaction would authorize bypassing an obligation, because
  §1.3 is the finding that no such set exists. Calling the boundary a non-condition, as an
  earlier draft did, weakened the one thing keeping this from being a waiver.
- **Not evidence.** It appears in no evidence entry and satisfies no mode.
- **Not attribution.** §2.1 says so in the shipped text, not only here.

### 2.3 Old-condition accounting — CLAUDE.md §5

The AGENTS.md Don't requires this, and pass-1 finding 4 established that four rows were not
enough: the first draft's wording created new control-flow edges beside several of §5's
terminal actions, and "everything untouched" concealed them. Every clause that draft could
have touched is therefore listed individually, with the §2.0 scope applied.

| §5 clause | Disposition under §2 as scoped |
|---|---|
| Hard floor: min 3 passes **per run** — Gate A's spec and plan are separate runs, each with its own loop | **Kept, untouched** — §2.1 excludes below-floor closure by name |
| Final pass must be clean | **Kept, untouched** — same exclusion |
| Only early exit is a zero-finding pass | **Kept, untouched** — no second exit is added |
| "Clearly stuck → STOP and surface" | **Kept, untouched** — §2.1 states that a STOP still stops and that assent does not clear it |
| Recovery: one attempt per pass; spent and still incomplete → STOP | **Kept, untouched** — the record is not a substitute for the attempt or for the STOP |
| An INCOMPLETE pass is discounted, whatever the counter says | **Kept, untouched** |
| Gate-B triviality skip needs two independent conditions | **Kept, untouched** — the skip has its own reason field; §2.1 is a different record for a different case |
| The skip reason is recorded in the commit body | **Kept**, and now has a sibling form for the non-skip case |
| What the author owes by mode | **Kept, untouched** — §2.1 satisfies no mode and §2.2 says so |
| Unobservable counterfactual → blocking evidence gap, human may lower the mode by logged override | **Kept, untouched** — that path stays the override, not this record; §2.1 excludes evidence obligations by name |
| Work gap vs setup gap | **Kept, untouched** — an unrunnable *required* check is still a gap to fix or surface; §2.1 covers optional checks only |
| Profile changes are proposed, human-confirmed, logged | **Kept, untouched** |
| Evidence entry in the commit body, revalidated before close | **Kept, untouched** for the evidence entry. The exception record travels the same carry chain and has **no revalidation step at all** — not a weaker one. §2.4 records that as a deliberate cut, not an omission |
| "Dismissed finding → one-line why" | **Kept**, and §2.1 is the same instinct applied to a decision rather than a finding |
| "Accept a pass only when" — readable file, exact terminator, exactly `<n>` finding lines and nothing else | **Kept, untouched** — the acceptance grammar is unchanged. Normalization applies *after* acceptance, to an already-valid line; a structural failure is still INCOMPLETE and never reaches it |
| `.context/codex-gate.off` silences reminders; "the gates still apply" | **Kept, untouched** — the opt-out's meaning is unchanged, and §2.1 is not an opt-out |
| Gate A is two runs — spec then plan — each with its own loop | **Kept, untouched** |
| A profile present but unresolvable → stop and surface | **Kept, untouched.** §2.1's "on a STOP you still stop" is general and reaches this one; it is listed separately because a general assurance is what this repository's Don't rejects as accounting |
| Mechanics' severity semantics — Blocker (wrong/unsafe/breaks invariant) · Major (design flaw → rework) → both must resolve; Minor · Nit → collect, never iterate | **Kept, untouched.** Rider (b) changes how an *unrecognized* token is read, never what a recognized severity means or does. Its Title-case spelling is also kept: the reader matches case-insensitively (§3) precisely so this sentence stays legitimate input rather than becoming drift |
| "You filter to Blocker/Major, Codex never does" | **Kept, untouched** — normalization happens before the filter and feeds it a token; the filter itself is unchanged |
| The writer-facing finding-line format, one per line, escaped pipes | **Kept**; rider (b) adds the closed severity vocabulary the format previously showed only by example, and changes nothing else about the line |
| Companions are advisory; they never participate in pass validation | **Kept, untouched.** An earlier draft narrowed this for normalization-dependent passes; that narrowing is withdrawn with the drift record (§3), so no companion clause changes |
| Every file-protocol clause — pre-call deletion, slot naming, one pass at a time, recovery and single-branch resume, both-branch acceptance under `full`, the one-line reply | **Kept, untouched.** These were in scope only while the drift record needed an attempt-suffixed slot model; with it cut, none of them moves |
| Anything else is an INCOMPLETE pass, discounted | **Kept, untouched** |
| Recovery: one attempt per pass, shared; prefer a single-branch resume with `reviewType` + `sessionId` | **Kept, untouched.** An earlier draft had rider (b) specify retry filenames and pairing; that model went with the drift record (§3), so §5's existing recovery text is unmodified |
| `WIP:` naming; amend to close; `reset --soft` for several snapshots | **Kept, untouched**; §2.4 adds only what the exception record does inside that flow |
| The closing message carries the validated evidence entry | **Kept**; §2.1's record sits beside it in the same body, under the same carry instruction and the same absence of any check |

**There is no `every other clause` row.** An earlier draft ended this table with one, which is
the catch-all this repository's decision-procedure Don't rejects by name: it asserts
completeness while naming nothing, so a dropped condition is indistinguishable from a
deliberate one. The rows above are what was walked. Anything not here was not examined, and a
reader relying on this table should re-walk §5 — five successive versions of this accounting
across this story's cycles each claimed completeness and each was wrong.

### 2.4 What is not specified about the carry, and why

The placement and carry rules are **in §2.1's shipped paragraph and nowhere else**. Three
drafts of this section built more: a per-gate placement table, a stable `Ref:` identifier, a
supersession grammar, a four-state collision procedure, duplicate-detection and restoration
matching rules, and a deterministic ordering. All of it specified how a **person** should
handle a three-line note in a commit message, and none of it was executed by anything.

**It is cut, and the cut is the design decision.** What replaces it is one sentence in the
shipped text — *copy the records across; nothing checks that you did* — plus the admission
that a disagreeing duplicate is a copying error to fix rather than a case to adjudicate. A
reader who needs to tell two similar records apart does what they would do for anything else
in history: look at the commits.

**What this gives up, stated rather than hidden:** there is no machine-followable procedure for
deduplicating records, for naming which earlier record a correction corrects, or for resolving
two records that collide in every visible field. Those situations are rare, and a person
resolves them by reading. If they turn out not to be rare, §6's attribution row is where that
evidence goes.

## 3. Riders — these carried real discriminating checks all along

**(b) Canonical syntax, and a tolerant reader.** **Canonical:** severity is
`BLOCKER | MAJOR | MINOR | NIT`, uppercase, stated in §5 and in `/workflow-init`'s template as
a closed set of permitted tokens for what the prompt demands of the writer — not shown by
example. **Reader:** the severity field is taken by splitting the line on **unescaped** pipes and
trimming the ASCII whitespace the finding format puts either side of each separator; a field
that is empty or all whitespace is a **structural** failure, so the line is INCOMPLETE and is
never normalized. Otherwise the field is matched **case-insensitively** against the four tokens
first — `Minor`, `minor` and `MINOR` are all `MINOR`, because `CLAUDE.md` Mechanics
legitimately spells them in Title case and a model copying that spelling is doing as it was
told, not drifting. A field that matches no token case-insensitively, and is non-empty, is
read as `MAJOR`. Every **structural** failure stays INCOMPLETE — a malformed
line, a wrong field count, an empty severity field, a bad terminator, a count mismatch. Only
the severity token is tolerated, and only when everything else about the line is right.

Motivating incident: PR #23's Gate-B pass 3 returned all four findings at `IMPORTANT`.
Discarding that pass over a token would have thrown away four real findings.

**The drift record is cut, and this is the interesting part of the rider.** Three drafts
required that pass's dispositions file to carry an `Enum drift:` line, with the pass invalid
without it. Gate-A pass 4 falsified its premise: **the normalization was never silent.** The findings
file carries the original token verbatim on the finding line, so the reader who validates and
filters the pass sees the drift **at the moment the decision is made** — which is when it
matters and who it matters to.

**The stronger claim is not available, and pass 5 was right to reject it.** An earlier version
of this paragraph said the findings file is a *permanent* record that "may not be deleted".
False: §5 imposes no retention after validation, `.context/` is git-ignored, and §6's own row
records that slot collisions have already destroyed a predecessor's findings in this
repository. So the honest form is the narrower one — **visible to the reader at decision
time, not durable afterwards** — and the decision to cut is taken on that basis: the companion
bought durability the rest of the system does not provide anyway, at the cost below.

What that clause cost before it was cut, all of it now moot: a token-identity rule with a
whitespace case contradicting its own example; a six-field parse `CLAUDE.md` §5 never defines;
a bijection check, because verifying that cited lines resolve does not verify that every
drifted line was cited; a freshness rule; a two-artifact audit with a discount path; a
logical-pass / attempt / credited-count identity model to survive single-branch recovery;
edits to **four shipped hook reminder strings and their test assertions**, which instruct a
retry to delete the very slot the rider wanted preserved; and an append-only supersession row
in `docs/hardening-log.md` against a ledger row stating that dispositions never participate in
pass validation.

**So §5's "companions are advisory; neither participates in pass validation" stays untouched.**
Nothing in this change narrows it — §2.3 carries that clause as an explicit kept-untouched row
rather than omitting it, since three drafts did narrow it and a reader needs to see it walked
back. A recording
mechanism is parked in §6 with its trigger.

**(c) Squash-merge carry.** The shipped sentence, byte-for-byte:

> **On squash-merge, copy every evidence entry and every human-exception record in the squash range into the squash body — the squash commit is the only body the merge carries into `main`'s history, so anything left behind is unreachable from it.**

**And nothing more.** Earlier drafts specified which entry wins when a story has several in
range, defined an ancestor relation over the range to decide "latest", and made incomparable
entries stop the squash. That was a selection algorithm for a human copying text between commit
messages, and it generated findings in three consecutive passes. §5's existing rule already
governs evidence entries — each is revalidated before its close, and the closing message
carries the validated one — so this rider's only job is to say that squash does not exempt you
from carrying them. It says that.

## 4. Sites

Small, because **nothing that claims the gates are mandatory becomes false** once §2.0's scope
holds.

| Path | Change |
|---|---|
| `CLAUDE.md` §5 Mechanics | §2.1's paragraph in full — it carries its own placement and carry sentences; rider (b)'s closed enum and reader rule; rider (c)'s carry sentence |
| `plugins/dev-workflow/commands/workflow-init.md` | The same edits to the inline §5 mirror — story AC 9, verified per §5.3 |
| `scripts/check-invariants.sh` | §5.2's closed-enum assertion, **plus** the script's own stale inventory: its header says "the two prompt-conformance checks" and its marked mutation procedure covers only 4a/4b. Both go to three, with `BEGIN/END check 4c` markers matching the existing convention |
| `scripts/check-invariants.test.sh` | **First**, `init_prompt_fixtures` — it creates no `CLAUDE.md` at all and gives `plugins/dev-workflow/commands/workflow-init.md` no template section, so adding 4c without extending it turns **every existing fixture repo** red on an unrelated baseline failure. It must build a valid bounded §5 region in both files. **Then** 4c's own reject/accept cases, and the recorded flipped-set mutation result the header's procedure requires |
| `plugins/dev-workflow/.claude-plugin/plugin.json` | **`version` 0.8.2 → 0.9.0** — invariant 12. Its `description` is untouched; the *file* is not |
| `plugins/dev-workflow/CHANGELOG.md` | The 0.9.0 entry |
| `todos.md` | Compound-commands row, occurrence 3; the `unverified-enforcement-claim` re-point; `prompt-vague-criteria` closed (§6) |
| `AGENTS.md` invariant 11 | Its count of the narrow checks in `scripts/check-invariants.sh` and their guarded-spelling inventory — currently "two narrow checks… a `Target model:` line… and a prose checklist-count claim". §5.2 makes it three. The invariant's calibration ("a floor, not coverage") is kept verbatim |
| `docs/superpowers/stories/2026-08-14-tier-2-same-family-reviewer-story.md` | Its live text assumed tier 3 ships. Amended with old-condition dispositions |
| `docs/superpowers/stories/2026-08-13-reviewer-availability-fallback-story.md` | Closure banner, reversed criteria, profile log |

**No new file, and that is a deliberate reversal.** Draft two added a parity checker and its
suite; §5.1 records why that was withdrawn. Adding one is what would have pulled
`.github/workflows/ci.yml`, `AGENTS.md`'s Boundaries inventory and its exact checker-count
claims, the architecture tree, and the battery and lint rows into scope — a chain draft two
listed only half of. **That inventory churn is what withdrawing the checker avoids**, and
`.github/workflows/ci.yml` needs no edit because `scripts/check-invariants.sh` is already in
the invariant-check step.

**`AGENTS.md` is not unchanged, though**, and an earlier draft said it was: invariant 11 states
that the checker carries "two narrow checks" and enumerates them, and §5.2 makes it three. That
one narrow count update is required; the tree, Boundaries and command rows are not.

An earlier draft listed only the first two paths while requiring the rest in its backlog
section, and called the plugin manifest "checked and unchanged" against a required version
bump — an invariant-12 failure written into the design.

**Checked for truth and unchanged, each verified rather than assumed:** `docs/getting-started.md`,
`docs/coding-workflow.md`, `docs/sparring-briefing.md`, `README.md`,
`.claude-plugin/marketplace.json`, `docs/pr-review-bots.md`. Every one was on the rejected
design's site list **because tier 3 falsified it**; with tier 3 withdrawn and §2.0's scope
excluding everything mandatory, each is true as written. *Unchanged in content* — distinct
from the row above, where the manifest's content claim is fine and its version is not.
(Verified as of the design's close, 2026-08-14. The salvage's shipping commit later edited
three of these — reviewer-model-selection docs in `docs/coding-workflow.md` and
`docs/sparring-briefing.md`, task scope outside this design's site list, and a stale
check-count correction in `README.md` — without touching the claims verified here.)

## 5. Validation — what the profile's mode owes

The story's mode is read fresh from its header (`battery+check` at the time of writing). Named
here rather than left in a story comment because a plan can otherwise implement the prompt
edits and skip the discriminating check (pass-1 finding 13).

### 5.1 Two wrong answers first, because the second is more instructive than the first

**Draft one** said the battery "already covers the two prompt copies' parity via
`scripts/check-invariants.sh`". False, and the defect class `AGENTS.md` names first.

**Draft two** replaced it with a proposed new checker (`scripts/check-prompt-parity.sh`, never
written) extracting §5 from both copies and diffing them. Pass 3 killed it, correctly, on four counts: **the two §5 bodies
already differ materially** in hook-tool mapping, incident prose, citations and prose
exemptions, so a whole-section diff cannot pass without unrelated synchronization absent from
§4; stripping "leading template indentation" is lossy in Markdown, where indentation changes
list nesting and can make prose a code block; the fixture list required the source-extractor to
also parse runtime `Enum drift:` records, which it is not; and the counterfactual "run it at
`df850ab`" would have failed on those pre-existing differences rather than on the thing under
test. A new checker also drags `.github/workflows/ci.yml`, `AGENTS.md`'s Boundaries inventory,
its checker-count claims, the tree and two command rows behind it — churn pass 3 found
half-missing from §4.

**And draft two's justification was itself an overclaim.** "No parity or mirror comparison
exists anywhere in this repository" is false: `scripts/check-invariants.sh` check 4b compares the
checklist item count in `docs/prompt-standards.md` against the copy in
`plugins/dev-workflow/commands/workflow-init.md`. Writing a categorical "anywhere" into the
section repairing an enforcement overclaim is the recursion this repo keeps producing.

**The true statement is narrow:** no *textual* check compares `CLAUDE.md` §5 with its inline
mirror. Check 4b compares an item **count** between a different pair of files.

### 5.2 The check that fails without the change

**One assertion, added to `scripts/check-invariants.sh`** — no new file, no CI wiring, no tree
or Boundaries or command-row churn:

> **The canonical line**, byte-for-byte, is:
>
> `Severity is one of exactly: BLOCKER | MAJOR | MINOR | NIT — no other token.`
>
> **Duplicates, both files:** it must appear **exactly once per file** — as a whole line,
> after stripping a leading blockquote marker and indentation, compared for **equality** and
> **case-sensitively**. Zero, two or more, a line that merely *contains* it, a title-case
> copy, a trailing space, an unreadable or missing file: all fail.
>
> **Placement, the command file only:** that one occurrence must sit inside the
> **`### 2.1` scaffold section**, terminated by the next **numbered** `### ` heading. Only
> that region is written into an initialized project, so a copy in the command file's own
> prose ships nothing. A missing or renamed anchor, or a duplicated one, **fails loudly**
> rather than skipping the rule — the safe direction. The repo's own `CLAUDE.md` gets no
> placement rule: the whole file is the artifact.

**Amended twice, and the second amendment repairs the first.**

**First (Gate-A pass 4 of the plan cycle):** this was a **bounded section-5 region** in both
files. That bounding needed fence nesting and template anchoring, and the parser was wrong in
three of the plan's four review passes — the last returning a multiple-end-boundary error on
the real command file, so the check could never have passed. It was replaced by a whole-file
count, described then as *"the same guarantee, stricter"*.

**Second (Gate-A pass 5):** that description was **wrong, and the error is the gate-proof class
this repository names first.** Whole-file counting is stronger on duplicates and **weaker on
placement**: the canonical line can sit in the command file's own prose, outside the template
`/workflow-init` scaffolds, and the count is still 1. **Verified by running it** — appending
the line to the command prose left the checker green while an initialized project would have
received nothing.

**So the contract is now priced exactly, one clause per guarantee.** Duplicates are fatal
file-wide in **both** files. Placement is enforced in the **command file** through the heading
range, because only the template region reaches users. The heading anchor is not the fence
parser returning: it terminates on the next **numbered** heading — the template carries its own
unnumbered `### Profiles` and `### Mechanics` subsections, which a next-`###` rule would
truncate on — and its state is one flag: set at the anchor, cleared at the first
numbered heading after it. **That terminator is itself checked** — it must be `2.2`. Without
that, renaming `### 2.2` to something unnumbered widens the range to `### 2.3` and a line
planted in the gap counts as inside the template. Verified: the battery stayed green. An
anchor rule that survives its own boundary drifting is worth nothing.

**Its own failure mode is stated rather than assumed:** a missing, renamed or duplicated
`### 2.1` heading fails the check loudly. An anchor-based rule that skipped when its anchor
moved would be worth nothing, and that is the direction this had to get right.

**Fixtures** — in `scripts/check-invariants.test.sh`, and **written, run and green**: 148
assertions under both `sh` and `dash`, 123 before this change. The initializer came first:
`init_prompt_fixtures` built no `CLAUDE.md` and gave the command file no scaffold section, so
adding the assertion without extending it would have turned **every existing fixture repo** red
on a baseline unrelated to its own assertion.

The 25 cases, by what each discriminates:

| Group | Cases |
|---|---|
| **Presence** | both copies stating it (accept) · absent from `CLAUDE.md` · absent from the command file · absent from both |
| **Duplicates** | twice in one file · two copies on one physical line |
| **Equality** | blockquoted (accept) · indented (accept) · leading text · trailing text · trailing space · title-case copy · paraphrase |
| **Placement** | outside the scaffolded template (**the exploit whole-file counting alone permitted**) · inside it (accept) · after an unnumbered subsection (accept — a next-`###` terminator would wrongly reject this) · missing `### 2.1` anchor · duplicate anchor · `CLAUDE.md` needing no anchor (accept) |
| **Terminator** | unnumbered terminator · **a line planted in the widened gap** (the second verified exploit) · absent terminator |
| **Fail-closed** | missing file · unreadable file (skipped as root, which satisfies `-r` on mode 000) · parser failure, through the suite's `inject_case` PATH seam keyed on the `sev-canon-count` marker |

**Mutation evidence, re-measured after every fixture change** (`4a` 20 · `4b` 22 · `4c` **19**
— 18 reject fixtures plus the parser case; no accept case moved in any of the three). 4c
measured 13 before the placement cases and 16 before the terminator ones; both were superseded
by re-running, never by extrapolation. The re-run found a real regression this work
introduced: `checklist parser failure fires` greps the checker output for the bare
`parser failed`, which 4c's diagnostic also ends in, so that fixture had stopped testing 4b —
deleting the 4b block left it green, and the count came back 21 against a recorded 22. Pattern
tightened to `checklist parser failed`; count restored. **Four review passes read that shell
without finding it; one mutation run did.**

**Rider (b)'s behavioural half is a named verification, not a test** — and its evidence is
already in hand: PR #23's Gate-B pass 3 returned four findings at `IMPORTANT` and they were
accepted and filtered by interpretation. That is an observation of the prior state, not a
hypothesis about it. **The after-state is unobserved**, and §8 says so rather than the design
implying a symmetric result.

### 5.3 Parity — an instruction, and what it is worth

§5's two copies are not byte-identical today and this change does not make them so. So AC 9's
"agree after the change" means what a person actually does: **edit both copies, diff the
regions you edited, and record in the commit body that you did and that they matched.**

**Nothing checks this.** There is no mechanical parity check for `CLAUDE.md` §5 and its inline
mirror, this design does not add one, and §4 does not claim one. §5.2's assertion covers
exactly one line of the two copies — the severity enum — and nothing else.

Three drafts specified more: an enumerated block table with sentence anchors, an occurrence
count per block, and a paragraph-structured normalization to compare across differing line
wrapping. It was a procedure for a human diffing two Markdown files, it was wrong twice about
the repository (a claimed indentation that does not exist, anchors that did not resolve), and
it produced findings in three consecutive passes. Anyone wanting a real parity checker must
first decide what the two copies are *supposed* to share, since they legitimately differ today
— §6 parks that.

**Battery** — the `AGENTS.md` quality command, green, including check-invariants with the new
assertion and its regression cases.

**Prompt conformance** — all 12 items of `docs/prompt-standards.md` for both changed prompt
copies.

## 6. Backlog — the triggers stay parked

- **Attribution for the shipped record form** — the handle in a human-exception record is
  unverified, and §2.1 says so. *Trigger: the first record whose authorship is disputed or
  unattributable.* This is hardening for what ships and needs no availability attestation.
- **External-authority zero-pass research** — signed commit or protected-branch approval, as
  the one untried class. *Trigger: a renewed need to close a gate cycle with no review —
  a second multi-day reviewer outage, or the operational bridges of §7 proving unavailable.*
  Kept separate from the row above because they are different problems: one hardens
  attribution on an optional-work note, the other reopens a rejected design. §1.5 is why external authority is **one untried direction worth
  reconsidering** rather than the only one that could work — the design space was never
  exhausted. Whoever takes it inherits the named requirements: a trusted signer identity, a
  role policy saying who may approve, and an availability attestation from someone other than
  the author.
- **Tracked re-review debt.** *Trigger: a human explicitly asks for follow-up review on a
  recorded exception and that follow-up is later found not to have happened.* Stated as an
  observable event because the shipped form creates no follow-up obligation, so "never
  happened" would otherwise never become true (pass-1 finding 15).
- **A recording mechanism for severity normalization.** Rider (b) normalizes an unrecognized
  token to `MAJOR` and records nothing; §3 explains why the drift record was cut — the findings
  file carries the original token verbatim, so the drift is **visible to the reader at the
  moment the pass is validated**, and the companion duplicated that at the cost of an identity
  model, an audit, four hook-message edits and a ledger supersession. No permanence is claimed
  for either: `.context/` is git-ignored and slot collisions have destroyed findings here. *Trigger: a pass is normalized and the drift goes unnoticed in review.* Whoever
  takes it starts from the cost §3 records — an identity model, an audit, four hook-message
  edits and a ledger supersession — rather than rediscovering it. (Per-pass dispositions exist
  under `.context/codex-reviews/` while this worktree lasts, but §3 is the durable statement;
  see §1.2 on why those paths are not citable.)
- **The hook's `is_docs_only` exempts any `.md` path outside a prompt directory**, broader than
  §5's prose list. *Trigger: a root `.md` file acquiring gate-relevant state.*
- **Gate-cycle slot collision — trigger fired, row stays open.** This story's cycles destroyed
  a predecessor's findings file and dispositions before the surviving artifacts were archived
  by hand. §1.3's third failure mode is downstream of the same weakness.
- **Tier-2 counting and containment**, pointing at the tier-2 story (§4).
- `todos.md`: **occurrence 3** on the compound-commands row (story AC 8) — `git add` and
  `git commit` in one Bash call, empty staged set at `PreToolUse`, loose STOP; observed on PR
  #23's close. Same shape as occurrence 2 and, like it, a **false positive**. The existing item
  is **edited in place**; append-only-never-edit is `docs/hardening-log.md`'s rule.
- `prompt-vague-criteria` closes. `unverified-enforcement-claim` **stays open**, re-pointed at
  the hook story.
- Version **0.8.2 → 0.9.0** with a `plugins/dev-workflow/CHANGELOG.md` entry — invariant 12.
  **Verified** by `scripts/check-version-bump.sh` against the PR's base *after* the WIP commit
  carries both the plugin edits and the manifest bump; run before then it reports clean,
  uselessly.

## 7. Where the stall problem goes

The five-day quota stall (2026-08-05 to 2026-08-10) is **not solved by this change**, and
saying so is part of closing the story honestly. §2.0's scope means the exception form does
not reach it either — that was the first draft's error. It routes two ways:

- **Operational bridges** — a second API key, or an alternate vendor. This is the answer that
  restores review rather than removing it, and it needs no design permission.
- **The tier-2 story**, if its same-family containment proves buildable — a weaker review is
  still a review, which is categorically different from none.

If neither is available, the honest answer is that work on gated changes stops until the
reviewer returns. That is a real cost, and §1 is the record of three attempts to avoid paying
it.

## 8. What this does not do

- **Nothing enforces the exception record.** No hook fires on it, nothing validates it,
  nothing checks the handle. It is a convention read by a human, and §2.1 says so in the
  shipped text.
- **Nothing detects an unrecorded exception.** A human proceeding silently is exactly as
  invisible after this change as before it.
- **The gates remain waivable in practice by anyone willing to ignore them**, as they were
  before — §5's mechanisms were always advisory. §1 establishes that no *sanctioned* path was
  found; it does not establish that the unsanctioned one closed.
- **The record could still be misread as permission** by a reader who takes the form and skips
  the scope. §2.1 puts the scope in the shipped paragraph for that reason, but prose cannot
  prevent selective reading.
- **Rollback is forward, not a revert to a green tree.** The prompt edits and §5.2's
  closed-enum assertion are coupled in one direction: reverting the prompt lines while the
  assertion stands makes the invariant check fail. So a rollback removes **both** — the two
  prompt copies' edits, the assertion, its regression cases, **`AGENTS.md` invariant 11's count
  back to two, and the checker's own inventory comments and mutation procedure with it** —
  plus a `plugins/dev-workflow/CHANGELOG.md` entry
  and a **forward** version bump, never a decrease. `docs/hardening-log.md` is append-only, so
  anything landed there is superseded rather than deleted. Installed copies live under
  version-keyed cache paths and downstream `/workflow-init` copies are the user's own files,
  so both follow the CHANGELOG rather than the revert — the standing cost of invariant 8's
  inline templates, not something this change introduces.
