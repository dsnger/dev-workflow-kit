# Risk, security, and validation profiles — Design

**Date:** 2026-07-26 · **Story:**
`docs/superpowers/stories/2026-07-26-risk-security-validation-profiles-story.md`

Design altitude on purpose: this states WHAT each profile level changes, where the
values live, and how an upgrade is recorded. The exact wording of the lens paragraphs
and the template diffs are plan and implementation territory — prose review stops
converging on wording (nine plan passes in the last round re-proved it), and procedure
converges at Gate B.

## 1. Problem and goal

Review cost is the workflow's limiting factor, and every story pays the same price
regardless of what it risks (counted evidence in the story's §1: 51 Gate-A pass files
on one product project's 2 stories; 23 pass files and 160 findings in this repo's
just-closed round, 8 of them on prompt-text and docs alone). The gates have one
intensity and no vocabulary separating a payments migration from a copy tweak.

Goal: two human-confirmed axes per story — **risk** and **security relevance** — plus a
**validation mode derived from them**, steering *what the gates ask* and *what the
author must show*, without adding passes and without introducing any new way to skip a
gate.

## 2. Decisions, with what would reopen each

| # | Decision | Why | Reopens when |
|---|---|---|---|
| D1 | The two axes are proposed by the agent and **confirmed by the human** before the story is written. A human *correction* may set any value, up or down; only a **non-answer** ("proceed anyway", "I don't know") is floored at the proposal. The validation mode is **derived** rather than asked, and the human may override it within the bounds in §4 | A third question invites an answer inconsistent with the first two; an overridable derived value keeps the human final. There is deliberately no "unconfirmed" state — a header the design calls human-owned must not be able to hold an agent's unanswered guess, and a floor on non-answers must not become a veto on answers | — |
| D2 | Profiles apply to stories **entering intake after this ships**; no retrofit | Retrofitting settled artifacts is a metadata backfill that changes no decision | An in-flight story may **adopt** a profile voluntarily at any natural checkpoint via the mechanism in §6. Adoption allowed, retrofit not required |
| D3 | `trivial` does **not** relax Gate A's floor and does not skip Gate A | A spec misjudged as trivial skips design review entirely and everything downstream inherits it — strictly more dangerous than a diff misjudged as trivial, which the documented Gate-B skip already covers | Field evidence that trivial stories burn Gate-A passes. Trigger discipline as usual: evidence, then a story |
| D4 | The **story header is the single writable copy**; spec and plan cite the story path; the gate prompt reads the header fresh at each pass | A second copy is a sync surface, and stale-copy drift is this repo's most recurrent defect class (§5 documents an incident) | — |
| D5 | The two **axes** govern the questions the reviewer asks (each maps to its own lens set); the **validation mode** governs the evidence the author must produce | Orthogonal levers — reviewer questions vs. author obligations. Had the mode also steered the gates it would be a second name for the axes. Saying "risk governs the questions" would be literally false: security maps its own lens set independently | — |
| D6 | Profiles **add no new gate-off path** and change no pass floor. The one skip that exists — §5's "Skip ONLY trivial changes" at Gate B — stays Gate-B-only and gains no new reach; for a **profiled** story its eligibility is *narrowed* to effective level 0 and its reason becomes recorded, while an unprofiled story keeps today's judgement-based skip | The mandatory-gates promise is the product. A lever that could switch a gate off is not an economics lever, and a skip whose justification is unrecorded is not a decision. Narrowing is the safe direction; saying "unchanged scope" would invite a later edit restoring risk-only skipping | — |

Rejected, for the record: the mode as a **gate schedule** (full / reduced / minimal) —
it would let profiles switch gates off, the exact promise D6 protects; the mode as
**artifact depth** (full spec vs. design note vs. story-only) — "depth" is not checkable,
and prose review never converges on it; and a **spec-header echo** of the profile,
rejected under D4.

## 3. The two axes

Recorded in the story header, one line beside `Date` and `Size`:

```
**Risk:** trivial | standard | high · **Security:** none | standard | high · **Validation:** <mode>
```

Directly beneath it, a **profile log** that does not exist until something changes: the
`**Profile log:**` label is written on the first event and never before, so a story with
an untouched profile carries no empty block. Each entry is one line naming the **event
kind** — axis change, mode override, or adoption — with the **axis identity** on an axis
change (`risk`, `security`, or both in one entry when both move), a **direction per named
axis** (both may move at once and in opposite directions, so a single shared direction
could not say which belonged to which), and always a **reason or trigger**: a finding reference when a finding caused the event, and plain
prose when one did not, because intake overrides, adoptions and voluntary changes have no
finding and must not have to invent one. Never the values themselves. A mode override chosen during intake
confirmation is the first `mode override` event and creates the log, so the same decision
is equally auditable whether it happens at confirmation or a day later. The header is the only value-bearing copy (D4), and git
history already holds what the previous values were; a log that restated them would be
the second writable copy this design refuses.

**Risk** answers *what breaks if this is wrong*, by observable criteria:

- `trivial` — no behavioural effect **in the artifact's own execution context**. For
  code, that is prose, comments, formatting, or a rename nothing resolves against. For a
  **prompt artifact the text is the behaviour**, so a wording change to a skill, command,
  agent definition, hook message or template is *not* trivial by default — a `trivial`
  claim on one is a human decision, recorded like any other.
- `standard` — a behaviour change that hits no named trigger. The default.
- `high` — the change affects a named trigger. Two named lists, because domain and
  consequence are different ways to be dangerous:
  - **domains** — auth, permissions, payments, migrations, data deletion, public APIs,
    personal data, supply chain;
  - **effects** — irreversibility (no rollback path), data loss or corruption, outage
    exposure (a critical path can stop serving).

  The effect list exists because a severe change need not sit in a named domain: a
  migration-free job that truncates a table irreversibly is `high` on effect alone. It
  stays a *named* list on purpose — replacing it with "use judgement about severity"
  would reopen the door the named triggers exist to close.

**Security relevance** answers *what an attacker could reach through this*:

- `none` — touches no asset, trust boundary, role, or external system. A real answer and
  the common one; it must not read as an admission of carelessness, or every story
  drifts upward.
- `standard` — touches one of those without changing what it permits.
- `high` — changes a trust boundary, an authorization decision, or the handling of
  secret or personal data.

**Triggers match surfaces, not words.** A doc that mentions auth is not `high`; a change
to an authorization decision is `high` even if the word never appears in the story. The
question is what behaviour, data, or surface the change affects.

**Where confirmation happens.** The profile proposal — all three values, one line of
reason each — rides **in intake's existing single question round**, alongside any
clarifying questions, and confirmation precedes the draft presentation. When nothing
needs clarifying, the proposal *is* the round. Intake gains no second pause.

**Every recorded profile is human-confirmed**, because intake does not write the story
until the human answers — the existing one-round pause, unchanged. "Proceed anyway" or
"I don't know" **is** an answer: it accepts the proposal as it stands, and the values are
recorded as proposed and **never lower**. That is invariant 2 ("loose in the firing
direction") applied to intake — a redundant lens costs a paragraph, a missing one costs a
review — and it needs no "unconfirmed" state, which would have let an agent's guess sit
in a header the design calls human-owned.

## 4. The derived validation mode

Effective level = `max(risk, security)` over `none|trivial → 0`, `standard → 1`,
`high → 2`. The effective level names the mode; security `high` adds one obligation on
top of whichever mode applies.

| effective | mode | the author must show, before Gate B |
|---|---|---|
| 0 | `battery` | the project's quality battery green |
| 1 | `battery+check` | battery + **a check that fails without the change** |
| 2 | `battery+check+verification` | battery + that check + a **named** verification of the risk path |
| security `high` | `+abuse-path` | added to the mode above |

The middle level is named `+check`, not `+test`, because the obligation is a check that
fails without the change and an automated test is only its most common form (below). A
mode named `+test` that a manual verification can satisfy would overclaim in its own
title.

**Field grammar.** `**Validation:**` carries exactly one mode name, followed by
`+abuse-path` **when and only when security is `high`**. Nothing else is a valid value,
and the suffix is not optional at that level — an obligation a header may omit is not an
obligation.

`max()` is deliberate at the corner: a change judged `trivial` sitting on
security-relevant surface still lands at the security level's evidence. Trivial is a
statement about blast radius, not about where the code lives.

**"A check that fails without the change" is not always a test**, and this repo is the
first case: its product is prompts, which no test can pin. Where an automated test is
possible it is the check. Where it is not, the obligation is met by a **named
verification** — and the entry says which route was taken and why. A fabricated test
never satisfies the mode; an honest "no automated check is possible here, verified by X"
does.

**Either route owes the counterfactual.** The obligation is not "the behaviour works"
but "this change is what makes it work", so the entry records the observation against
the **prior state**: the test failing before the change, the command's output on the
unchanged tree, the manual check performed on both. Evidence that only shows the end
state proves the feature, not the change.

**An unobservable counterfactual is a blocking evidence gap**, not a free pass. If the
prior state genuinely cannot be observed, the author stops and surfaces it; the human may
then lower the mode, which is an override — explicit, bounded by §4, and logged. What is
not available is claiming `battery+check` while showing no check that fails without the
change, because the mode's name would then describe evidence nobody produced.

**"Named" is the honest-claim rule made checkable.** A mode-satisfying entry names the
concrete check and its recorded result: a test path, a reproducible command with its
output, or a documented manual check with its outcome. The word "verified" without a
named artifact satisfies nothing.

**One durable evidence record: the commit body.** Gate B runs *before* the real commit,
so a PR body cannot hold the evidence the call itself must quote, and the `WIP:` body
cannot either — §5's cycle-closing `git commit --amend -m "<real message>"` replaces the
message wholesale. So §5's Mechanics gains **one clause**: the cycle-closing amend's
message **includes the evidence entry**, making the final commit body the authoritative
record. It is written before the call as the WIP body, it survives the close by being
re-stated in the real message, and it needs no PR — a PR shows commit messages anyway, so
no second home is specified. The Gate-B call quotes that entry rather than composing its
own version. No new file, no new story section.

That clause is in scope rather than adjacent: this story already edits §5 in both copies,
and an evidence obligation with no durable home would be an unverified-enforcement claim
built in by design.

**The entry carries the story citation and the named evidence — not the mode value.**
Restating the mode would put a profile value in a second writable place, which is what
D4 refuses; a reviewer handed a quoted mode would also assess the evidence against
whatever the entry claimed rather than what the header now says. Gate B derives the
obligations fresh from the cited header, the same way the lens sets are derived.

The entry is **revalidated before every Gate-B re-review and before the cycle-closing
amend** — not only when the profile moves, which is what made naming the mode look
necessary in the first place. A
Gate-B fix changes the diff, which can invalidate the check, its result, or both while
the profile sits still; §5 already re-reviews after every fix for exactly that reason.
Same shape as the floor rule in §6: the last review covers the current state, and so must
the evidence it reads.

**The close restates the entry the final pass saw.** If the pre-amend revalidation
changes the entry at all, the clean pass no longer covers what is being committed, and it
is invalidated: fix, re-review, and close on the entry that pass validated. Otherwise the
durable record and the review that blessed it would describe different work.

**Producing the evidence is a precondition of the Gate-B call.** If the mode's evidence
cannot be produced, the author stops and surfaces the reason, exactly as an incomplete
pass is surfaced; the call is not made against a weaker claim. Two named failure states,
because they need different responses: evidence that is *absent or inadequate* is a work
gap → produce it; a project whose `AGENTS.md` has **no verified quality command** cannot
satisfy even mode `battery` → that is a setup gap, and the response is to say what is
missing (`/workflow-init`'s battery step), not to review around it.

**Overriding the derived mode, within bounds.** The derivation is a recommendation, per
D1: the human may **raise** the mode freely. **Lowering** it requires the human to say so
explicitly — an agent never lowers it — and cannot drop `+abuse-path` while security is
`high`; that suffix is the one obligation the axes make non-negotiable, because a story
that reaches an abuse path is exactly the story whose evidence nobody should be able to
trade away quietly. The header then carries the **effective** mode, and the profile log
records it as a `mode override` event (direction, reason), so a lowered mode is a
decision a later reader can find and question.

**An axis change voids every prior override**, raised or lowered. When either axis moves
(§6) the mode is recomputed from the new values, any override lapses, and holding the
mode away from its new derivation requires the human to say so again, logged again,
before the next pass. The `+abuse-path` suffix follows the current security value by
grammar, so a security downgrade removes it rather than leaving an obligation nobody
reconfirmed — and an upgrade cannot leave yesterday's lowered mode standing, which would
have made the promised revalidation change nothing.

**A cycle covering several stories** aggregates along separate dimensions rather than
through one winning mode: the **battery runs once** for the cycle, **each cited story
satisfies its own mode and suffix** with its own named evidence entry, and the **lens
sets are unioned** across all cited stories. A single "max" would either under-serve the
high-security story or impose its obligations on unrelated ones.

**Level 2's two obligations are distinct.** `battery+check+verification` owes the
counterfactual check *and* a named verification of the risk path. One artifact may serve
both only if it actually demonstrates both — the failure on the prior state and the risk
path exercised; otherwise they are two entries. An author and a reviewer reaching
opposite readings of this is a Gate-B stop nobody needs.

**What `+abuse-path` minimally shows:** one **named** abuse scenario for the surface the
change touches, and evidence that the expected control rejects or contains it. Naming
the scenario without showing the control's response is half the obligation.

**Forward-compatible by design.** Today `named verification` and `+abuse-path` resolve to
whatever a project's battery and manual practice provide. When a project grows the
parked validation lane (agentic smoke, coded E2E), those become additional ways to
satisfy the *same* obligations — no renaming, no second axis. That lane is not designed
here.

## 5. What the profile changes at the gates

§5 gains one short **Profiles** subsection — the axes, the derivation, and the two lens
sets named — in both copies (this repo's `CLAUDE.md` and the inline template
`/workflow-init` writes). The gate-prompt rule gains one instruction: **read the cited
story's header fresh at each pass, and append the lens set(s) the current values call
for.**

- **risk `high`** → risk lens set: threats, abuse, rollback, data loss, idempotency,
  compatibility, observability.
- **security `standard` or `high`** → security lens set: assets, trust boundaries,
  roles, external systems, abuse paths.
- **both** → the union, appended **once**, each lens labelled with the axis that
  motivated it. Duplicated questions would spend exactly the budget this design exists
  to save. The one genuine overlap — risk's *abuse* and security's *abuse paths* — is a
  **single lens carrying both labels**, not two questions; leaving that undefined is how
  the two §5 copies would drift into asking it twice or dropping one axis's version.
- **risk `trivial`** → nothing appended. It supplies the recorded reason for §5's
  pre-existing Gate-B triviality skip; it creates no skip of its own.

**The skip keys on the effective level, never on risk alone.** §5's Gate-B triviality
skip becomes available only when `max(risk, security)` is 0 — risk `trivial` *and*
security `none`. A `trivial` risk call on security-relevant surface derives real evidence
obligations, `+abuse-path` among them at security `high`, and a skip keyed on risk alone
would let a single judgement call throw away the one obligation §4 says cannot be traded
away.

**A skip removes the review, never the evidence.** A skipped story is still mode
`battery` by derivation, so the battery still runs and its entry still lands in the commit
body before the commit. Otherwise the profile would quietly become an evidence-off path
while advertising that it is not a gate-off path — the same claim D6 refuses.

**In a cycle citing several stories, every cited story must be skip-eligible** for the
cycle to skip: each profiled one at effective level 0, each unprofiled one trivial by
today's judgement. One light story does not carry the others.

**How Gate B locates the story.** Gate B reviews a diff, not an artifact with a header,
so the story path is an **input to the call** — cited in the call's own context, and in
the commit body beside the evidence entry. That is a path, not a profile copy: the values
are still read from the story at each pass.

**When the profile cannot be read.** Three situations, deliberately separated, because
they need different answers:

1. **No story is cited** → run unprofiled, and say so in the pass: today's behaviour,
   announced rather than assumed. Artifacts that predate the citation rule are the common
   case, and stopping on them would halt in-flight work that D2 promises not to disturb.
2. The cited story exists and has **no profile line** → same: a pre-profile story gets
   today's behaviour.
3. A profile is **present but unresolvable** — unparseable line, a value outside the
   enums, two profile blocks, a citation that resolves to nothing → stop and surface the
   cause. Falling back to the lighter behaviour on a *malformed* profile would
   under-review exactly the stories most likely to have one.

**"Today's behaviour" means today's**, including the judgement-based Gate-B trivial skip
§5 already permits. Unprofiled stories get neither the lens sets nor the effective-level
skip rule, and they get no stricter than they are now — a rollout that quietly tightened
the gates for every in-flight story would break D2 and D6 at once.

Lenses are **different questions, not more identical passes**. The 3-pass floor, the
Blocker/Major filter, the file-first findings protocol and the clean-final-pass rule are
all unchanged, as is the coverage rule: Codex reports every finding with severity and
confidence, and the filtering stays downstream.

## 6. Changing a profile after intake

Any pass may reveal the profile was set too low. Then:

1. The pass **proposes the complete resulting header** — both axes, the recomputed mode,
   and any override the human wants to renew — and the **human confirms it**, in both
   directions. The header is human-owned per D1, and an agent that could raise an axis by
   itself would make that claim false; "raise now, confirm later" is just the
   `unconfirmed` state under another name. Confirming the whole header rather than the
   moved axis alone matters because the mode is *computed*: confirming only the axis would
   leave the one value the machine chose unconfirmed. Upgrades are rare and this workflow
   already has the human in the loop, so the cost is a question, not a stall.
2. On confirmation the header is **corrected**, and one line is **appended to the profile
   log**: date · event kind · axis identity (on an axis change) · direction · reason or
   trigger · what it changes downstream. The line does not restate values; the
   header carries those.
3. The record is written **before the next pass begins**. That, not the commit, is what
   closes the window in which a pass could run against a value nobody has written down.
4. **How it is committed depends on where the cycle is.** Outside an active Gate-B cycle
   — during Gate A, or between cycles — it is a docs-only commit at the next natural
   point. **Inside** an active Gate-B cycle it is folded into the active `WIP:` snapshot
   by amend, because a non-`WIP` commit reads to the hook as the cycle closing: it would
   discard the accumulated passes and move the reviewed range out from under `baseSha`.
   Either way the profile does not sit uncommitted on one machine's disk while the gates
   consume it.
5. The new profile takes effect at the next pass, because the prompt re-reads the header
   rather than reusing a value quoted earlier in the session.

**Adoption** by a story that never had a profile is the same mechanism — a header line
added plus one log entry naming the adoption and its reason — and it needs the same human
confirmation as an intake proposal, because an adopted profile nobody confirmed is a
guess wearing a header line.

**Upgrade × the 3-pass floor.** Passes already run under the lower profile **keep
counting** toward the floor — the floor is per cycle, and re-running them would be the
more-identical-passes this design exists to avoid — but the **final clean pass must run
under the current profile**. Net effect: an upgrade costs at minimum one additional
pass, never a restart of the cycle. It is the Gate-B rule "the last review must cover
the current state", applied to profiles.

**What enforces that is instruction, not machinery.** The fresh read is a prompt rule;
nothing checks which file the model actually read, whether the header changed during a
call, or whether the lens sets were appended. The detection that does exist is the
ordinary one — a reader comparing the pass against the story. Stating this is not a
caveat for its own sake: a design that claimed the fresh read *guarantees* the final
pass ran under the current profile would be this repo's most-logged defect class,
written into the spec that is supposed to prevent it.

## 7. Compatibility and scope

A story with **no profile line behaves exactly as today** (§5): standard intensity, no
lens sets appended, no effective-level eligibility rule — and today's judgement-based
Gate-B triviality skip still available to it, because "exactly as today" has to include
the parts that favour the author. It also owes **no mode-derived evidence and no
commit-body entry**: the validation modes of §4 apply to profiled stories only, and
imposing them on in-flight work would be the same tightening in a different place. That is what makes D2 free — nothing in flight breaks,
and adoption is a header line plus one log entry through §6 whenever a story wants it.

**How spec and plan cite the story.** Both carry a `**Story:**` header line with the
story's path, and the gate prompt resolves the profile through it. The surface that
states this rule is §5's Profiles subsection, because `superpowers:brainstorming` and
`superpowers:writing-plans` are upstream skills this repo depends on and does not edit
(AGENTS.md, dependency direction). A spec or plan that cites no story is case 1 of §5: the
pass runs unprofiled and **says so**, rather than either stopping or falling back
silently.

**Where security content lives** for security relevance `standard` or `high`: in the
spec's **decision record** and **risks** discussion, and in the project's **AGENTS.md
invariants** — the places that already exist. The security lens set is what *asks* about
assets, trust boundaries, roles, external systems and abuse paths; a spec that has not
covered them draws findings, which is a review outcome, not enforcement. No template
grows a standalone security section (non-goal, below).

**Surfaces touched:** `plugins/dev-workflow/skills/intake/SKILL.md` (proposal step,
header line, profile log in the story template), `CLAUDE.md` §5 and the inline §5
template in `plugins/dev-workflow/commands/workflow-init.md` (both in the same commit —
docs-drift class, and including §5's Mechanics clause on the cycle-closing amend),
`todos.md` — where **P2+P6 is split rather than closed**: the profile and lens work
closes, while P6's promised "security sections in the intake, spec and gate templates"
is recorded as *deliberately rejected*, with the reason, because closing the row whole
would claim scope that never shipped. P5 light's trigger is re-pointed at the first story
that runs under profiles. Plus CHANGELOG + plugin version bump (invariant 12), and a
**reference audit of the user-facing workflow docs** — `README.md`,
`docs/coding-workflow.md`, `docs/getting-started.md` at minimum — which teach intake,
the story artifact and the gates: each affected site is updated, or its continued
accuracy is recorded. Shipping profiled prompts beside docs that describe the unprofiled
workflow is the docs-drift class this spec keeps naming.

**Carried to the plan, not designed here:** the plan must include an explicit paired
check that the two §5 copies say the same thing after the edit — both files changing is
not evidence that they agree. The method is the plan's to choose; inventing one in prose
here is the altitude mistake this spec opens by naming.

**Non-goals:** no hook change (the hook counts passes and does not need to know
profiles); no new script; no new scaffolded file; no standalone security section in any
template. If field use later shows high-security content scattering incoherently across
specs, that recurrence is the trigger for a dedicated section. Stable AC-/SEC-IDs (P5
light) are deferred by the same reasoning that dated their trigger: profiles are what
the IDs would number.

## 8. Invariants this change touches

- **8** — the §5 template stays inline in the command body; the Profiles subsection is
  written there, not read from disk.
- **9** — `/workflow-init` stays idempotent; a template that changed means show-the-diff
  and ask, never a silent overwrite.
- **10** — the trigger list, the level criteria and the lens sets stay stack-neutral;
  project vocabulary belongs in that project's own files.
- **11** — every touched prompt passes all 12 items of `docs/prompt-standards.md`.
- **12** — the plugin change carries a version bump.
- **Don'ts** — no doc section renamed or deleted without grepping references first; no
  sentence claiming what a gate proves beyond what it actually compares. The profile
  changes the *questions* a gate asks and the *evidence* an author owes; it changes
  nothing about what either gate compares.
