# Risk, Security, and Validation Profiles — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Story:** `docs/superpowers/stories/2026-07-26-risk-security-validation-profiles-story.md`
**Spec:** `docs/superpowers/specs/2026-07-26-risk-security-validation-profiles-design.md` (Gate A clean at pass 8)

**Goal:** Add two human-confirmed profile axes and a derived validation mode to the story
header, and make the §5 gate prompts consume them, so review intensity scales with what a
story risks.

**Architecture:** Prompt-and-template changes only. The `intake` skill gains a proposal
step and two template lines; `CLAUDE.md` §5 gains a **Profiles** subsection plus one
Mechanics clause; `commands/workflow-init.md` carries the same two additions in its inline
§5 template (invariant 8 keeps them inline). `process-pr-review` requires **both** conditions for a
Gate-B skip — the change is behaviourally trivial *and* every cited story is eligible —
where before it turned on the fix's size alone. No new script, no new scaffolded file, and no hook change beyond the
one advisory reminder string covered by the waiver below.

**Tech Stack:** Markdown prompts. Verification is the repo battery (shellcheck, hook
tests, `check-invariants.sh`, `check-version-bump.sh`, `claude plugin validate`) plus
Gate B.

## Global Constraints

Copied verbatim from the spec and AGENTS.md. Every task's requirements implicitly include
this section.

- **Invariant 8** — `/workflow-init`'s templates stay **inline in the command body**.
  Never read a template from disk.
- **Invariant 9** — `/workflow-init` never overwrites silently.
- **Invariant 10** — the trigger lists, level criteria and lens sets stay **stack-neutral**.
- **Invariant 11** — every touched prompt passes all 12 items of `docs/prompt-standards.md`.
- **Invariant 12** — a plugin change requires a `plugins/dev-workflow/.claude-plugin/plugin.json`
  version bump (Task 5).
- **The docs-drift pair:** `CLAUDE.md` §5 and the inline §5 template in
  `plugins/dev-workflow/commands/workflow-init.md` **change in the same commit, always.**
  Task 2 owns both; splitting them across commits is a plan violation.
- **No profile VALUE is echoed** outside the story header — not in the spec, plan, profile
  log, or commit body. Those carry the story **path**.
- **No gate-off path is added.** The 3-pass floor, the Blocker/Major filter and the
  file-first findings protocol are untouched by every task here.
- **Downstream-neutral template text:** the `workflow-init` copy must not reference this
  repo's own files, incident counts, or `docs/` paths that `/workflow-init` never
  scaffolds.

**Scope-guard waiver, granted 2026-07-26 during Gate B pass 11.** The story's guard
excluded `plugins/dev-workflow/hooks/**`. One string in `hooks/codex-gate.sh` is changed
anyway: the below-floor reminder said "proceed only if this change is trivial", which the
narrowed skip rule makes false, and it says so at exactly the moment an author decides
whether to skip. The waiver holds because the edit runs *opposite* to what the guard
protects — it **removes** a rule statement from the hook and defers to the policy file, so
the hook reads no profile and gains no machinery; it ends up more profile-agnostic than
before. The replacement points at the policy without paraphrasing the rule, so no new sync
surface is created. Same-commit propagation applies: §5's skip rule changed, so its echo in
the hook changes with it, not in a follow-up. No test asserts that clause (the two hook
tests match only `below floor|floor NOT met`), and 0.7.0 already covers the plugin bump.

**Commit discipline for this plan:** Tasks 1–4 end with a `WIP:` commit — the hook treats a
`wip`-prefixed message as cycle-internal, so it neither fires a Gate-B STOP nor resets the
pass counters. Task 5 runs the battery, Gate B, and closes the whole cycle with one real
commit via `git reset --soft` + commit.

---

### Task 1: `intake` proposes the profile and the story template records it

**Files:**
- Modify: `plugins/dev-workflow/skills/intake/SKILL.md` — a **new Flow step 3** inserted
  before the existing "One question round, then pause" (line 45 region), the question-round
  step itself, the story template (lines 94–120), and the calibration block after it
  (lines 122–128)
- Test: none — prompt artifact, no test harness exists (AGENTS.md: "there is no
  application code, so there is no typechecker to catch a defect"). Verification is
  Task 5's battery + Gate B.

**Interfaces:**
- Produces: the header line `**Risk:** … · **Security:** … · **Validation:** …` and the
  `**Profile log:**` block that Task 2's §5 text reads. The field names and the enum
  spellings defined here are quoted verbatim by Task 2 — change one, change both.

- [ ] **Step 1: Insert the profile assessment as a new Flow step 3, BEFORE the question round**

Ordering is the whole point: the proposal must exist before the single question round
opens, or it cannot ride in it. Insert the block below as the **new step 3**, immediately
after "**Detect ambiguity**" and immediately before "**One question round, then pause**",
then renumber the existing steps 3–10 to 4–11.

```markdown
3. **Assess the profile** — derive a proposal for two axes and a validation mode, so the
   single question round below can carry it. Nothing is recorded yet:
   - **Risk** — `trivial` (no behavioural effect in the artifact's own execution
     context; for a **prompt artifact the text is the behaviour**, so a wording change
     to a skill, command, agent definition, hook message or template is not trivial by
     default) · `standard` (a behaviour change hitting no named trigger — the default)
     · `high` (the change affects a named **domain** trigger — auth, permissions,
     payments, migrations, data deletion, public APIs, personal data, supply chain — or
     a named **effect** trigger — irreversibility, data loss or corruption, outage
     exposure).
   - **Security relevance** — `none` (touches no asset, trust boundary, role or
     external system — a real answer and the common one) · `standard` (touches one
     without changing what it permits) · `high` (changes a trust boundary, an
     authorization decision, or the handling of secret or personal data).
   - **Validation mode**, *derived not asked*: effective level = `max(risk, security)`
     over `none|trivial → 0`, `standard → 1`, `high → 2` → `battery` /
     `battery+check` / `battery+check+verification`, plus `+abuse-path` when and only
     when security is `high`.

   Triggers match **surfaces, not words**: a doc that mentions auth is not `high`; a
   change to an authorization decision is `high` even if the word never appears.

   Carry all three into the next step's question round with one line of reason each.
```

Then extend the question-round step (now step 4) so it asks them. Its current text reads
"**One question round, then pause** — ask at most one round, then **wait** for the user";
append to that step:

```markdown
   The round also carries the **profile proposal** from step 3 — alongside any
   clarifying questions, or as the whole round when nothing needs clarifying. Intake
   gains no second pause. The human confirms or corrects, and what a correction means
   depends on what it touches:
   - **An axis correction sets that axis freely, up or down — and the mode is
     recomputed** from the corrected axes. Never carry the proposed mode over beside a
     changed axis: `**Security:** high` next to `**Validation:** battery` is a header
     the gates classify as unresolvable and stop on.
   - **A mode correction is an override**, and it is bounded: it may raise or lower the
     derived mode, but it cannot drop `+abuse-path` while security is `high`. Record it
     as the first `mode override` entry in the profile log, with its direction and the
     human's reason. **Say in the proposal that an override needs a reason**, since the
     log entry cannot be written without one.

   **State the derivation in the proposal, so one answer settles the whole header.** The
   mode is a function of the axes, not an independent choice: show `max(risk, security)`
   and what each level yields, and the human's single answer then confirms the axes, any
   override, *and* the mode that derivation produces from them — including after a
   correction. That is why no second pause is needed and none is taken: nothing is left
   for the human to choose once the axes are settled.

   **An answer that cannot be recorded ends this intake attempt** — an override with no
   reason, an override dropping `+abuse-path` while security is `high`, a mode outside the
   enums. Say which rule the answer collides with and **stop without writing**; do not
   hold a pause open waiting for a repair, and do not invent the missing piece. This is
   the grounding floor's shape, and it is honest about what happens next: the human's
   corrected answer arrives at a **new intake run**, which opens its own single round with
   that answer already in hand. What is forbidden is a second round *inside* one run, not
   the human coming back.

   "Proceed anyway" or "I don't know" **is** an answer: it accepts the proposal as it
   stands, and the values are recorded as proposed and **never lower** — a redundant lens
   costs a paragraph, a missing one costs a review. There is no "unconfirmed" profile, so
   the story is not written until the profile is settled.
```

- [ ] **Step 2: Add the header line and profile log to the story template**

Replace the template's date line (line 97):

```markdown
**Date:** YYYY-MM-DD · **Size:** chore | story | epic-needs-splitting
```

with:

```markdown
**Date:** YYYY-MM-DD · **Size:** chore | story | epic-needs-splitting
**Risk:** trivial | standard | high · **Security:** none | standard | high · **Validation:** <derived mode>

<!-- Profile log: omit this whole block until the first change. On the first one: -->
**Profile log:**
- YYYY-MM-DD · axis change · risk ↑ · Gate-B pass 2 finding on the migration path · adds the risk lens set
```

- [ ] **Step 3: Document the profile log after the size calibration block**

The code block above shows *where* it goes. Insert this after the "**Acceptance
criteria** describe observable outcomes…" paragraph (line 128) to say *what* each field
means:

```markdown
**Profile log.** A `**Profile log:**` label directly beneath the profile header, followed
by `-` entries — written **on the first change and never before**, so a story whose
profile never moves carries no empty block. One line per event: date · **event kind** ·
**direction** · **reason or trigger** (a finding reference when a finding caused it, plain
prose when none did) · what it changes downstream. The three kinds:

- `axis change` — names the **axis identity** (`risk`, `security`, or both in one entry
  when both move) and a **direction per named axis**, since both may move at once and in
  opposite directions:
  `- 2026-07-26 · axis change · risk ↑, security ↓ · pass-3 finding: no auth surface after all · swaps the risk lens set for none`
- `mode override` — names its own **direction**, because a human may raise or lower the
  derived mode. A lowering removes an obligation, so its reason says which one and why:
  `- 2026-07-26 · mode override · ↓ · the risk-path verification duplicates the migration rehearsal already run in staging · drops the named verification, keeps the counterfactual check`

  Choosing a **named verification** because no automated test is possible is **not** an
  override: it is one of the two routes that satisfy `+check` at the same mode, and it
  still owes the counterfactual. Logging it as a lowering would record a mode the header
  never moved to. *(Corrected during Gate B pass 2 — the original example illustrated the
  opposite of the rule.)*
- `adoption` — has no previous value, so **no direction**:
  `- 2026-07-26 · adoption · in-flight story adopting a profile at its plan checkpoint · gates now read this header`

The log never restates the values — the header is the single writable copy, and git
history already holds what the previous values were. A mode override chosen during intake
confirmation is the first `mode override` event and creates the log.
```

- [ ] **Step 4: Update the six-sections wording**

The template's intro (line 92) reads "Write the file with exactly these six `##`
sections, in order:". The profile lines are header, not a `##` section, so this sentence
stays true and **must not change**. Confirm by reading it; do not edit.

Also update the step that re-validates an edited draft (was step 8, now step 9) — its
parenthetical currently reads `(six sections, no-HOW except §4, grounding floor, ≥3
checkable criteria)`. Replace with:

```markdown
   **re-validate the edited draft against every constraint** (six sections, the profile
   header line, no-HOW except §4, grounding floor, ≥3 checkable criteria), and re-present.
```

- [ ] **Step 5: Verify no other numbered cross-reference broke**

Run: `grep -n "step [0-9]\|steps [0-9]" plugins/dev-workflow/skills/intake/SKILL.md`
Expected: every referenced number matches the renumbered flow. Fix any that point at the
old numbering.

- [ ] **Step 6: Commit**

```bash
git add plugins/dev-workflow/skills/intake/SKILL.md
git commit -m "WIP: intake proposes risk/security profile and records it in the story header"
```

---

### Task 2: §5 gains the Profiles subsection and the Mechanics clause — BOTH copies, one commit

**Files:**
- Modify: `CLAUDE.md` — insert the Profiles subsection before `### Mechanics (reference)`
  (line 254); amend the "Finishing the cycle" bullet (lines 266–269)
- Modify: `plugins/dev-workflow/commands/workflow-init.md` — the same two edits in the
  inline §5 template, before `### Mechanics (reference)` (line 429) and in its
  "Finishing the cycle" bullet (lines 441–444)
- Test: none (prompt artifact); Task 5 verifies

**Interfaces:**
- Consumes: Task 1's header field names and enum spellings, quoted verbatim below.
- Produces: the gate-prompt rules every later gate run follows.

**This task is one commit covering both files.** A commit touching only one of them is the
docs-drift class this repo logs most often.

- [ ] **Step 1: Write the Profiles subsection into `CLAUDE.md`**

Insert immediately **before** the line `### Mechanics (reference)`:

```markdown
### Profiles — how much review this story gets

A story may carry a profile in its header: `**Risk:**` (`trivial|standard|high`),
`**Security:**` (`none|standard|high`), and a `**Validation:**` mode derived from them
(`battery` / `battery+check` / `battery+check+verification`, plus `+abuse-path` when and
only when security is `high`). The **story header is the single writable copy** — specs,
plans, commit bodies and this file's prompts carry the story **path** and read the values
fresh at each pass, never a remembered or copied value.

**The axes steer the questions; the mode steers the evidence.** Separate levers: one aims
the reviewer, the other obliges the author.

**Lens sets, appended to the gate prompt:**
- **risk `high`** → threats, abuse, rollback, data loss, idempotency, compatibility,
  observability.
- **security `standard` or `high`** → assets, trust boundaries, roles, external systems,
  abuse paths.
- **both** → the union appended **once**, each lens labelled with the axis that motivated
  it; risk's *abuse* and security's *abuse paths* are **one lens carrying both labels**,
  not two questions.

Lenses are **different questions, not more passes.** The 3-pass floor, the Blocker/Major
filter, the file-first findings protocol and the clean-final-pass rule are unchanged.

**Reading the profile — three cases, three answers:**
1. The artifact **cites no story** → run unprofiled and **say so** in the pass. Artifacts
   predating this rule are the common case; stopping on them would halt in-flight work.
2. The cited story has **no profile line** → same: today's behaviour.
3. A profile is **present but unresolvable** → **stop and surface the cause**. That covers
   the syntactic failures — unparseable line, a value outside the enums, two profile
   blocks, a citation resolving to nothing — **and the semantic ones**: a `**Validation:**`
   value disagreeing with `max(risk, security)`, or `+abuse-path` present without security
   `high` or absent with it. Only the **latest `mode override`** in the log, moving in a
   direction compatible with the current value, can explain such a mismatch — and if the
   log also contains an `axis change`, only when that override was recorded **after** the
   latest one, since an axis change voids every prior override. A log with no `axis
   change` at all is the ordinary intake-time override, and its entry resolves the
   mismatch on its own. A well-formed value can still be the wrong value, and a stale mode steers
   weaker evidence while looking entirely valid; recomputing it is a profile change like
   any other — proposed, human-confirmed, logged. Falling back to the lighter behaviour on
   a malformed profile would under-review exactly the stories most likely to have one.

**The Gate-B triviality skip needs two independent conditions**, and an eligible profile
never makes a behaviour-changing diff skippable: the change itself is **behaviourally
trivial** (the pre-existing judgement, unchanged by profiles), **and** for a profiled story
`max(risk, security)` is 0 — risk `trivial` *and* security `none`, never risk alone. The
**skip reason is recorded in the commit body** — not in the profile log, which records
profile *changes*, and a skip changes no profile value. **A skip removes the review, never
the evidence**, and what is owed follows the profile: a skipped **profiled** story runs the
battery and lands its evidence entry beside the reason; a skipped **unprofiled** story
records the reason and the battery result and nothing more, because it owes no mode-derived
entry and keeps exactly today's judgement-based skip.

**A cycle citing several stories** aggregates along separate dimensions, never through one
winning mode: the **battery runs once** for the cycle; **each cited _profiled_ story
satisfies its own mode and suffix**, with its own named evidence entry, while a cited
**unprofiled** story has no mode and owes no entry; the **lens sets are unioned** across
all cited stories; and the cycle is skip-eligible only if **every** cited story is. A
single "max" would either under-serve the strictest story or impose its obligations on
unrelated ones.

**What the author owes before Gate B**, by mode: `battery` = the quality battery green ·
`battery+check` = battery + **a check that fails without the change** ·
`battery+check+verification` = battery + that check + a **named** verification of the risk
path · `+abuse-path` = one **named** abuse scenario plus evidence that the expected control
rejects or contains it. Level 2's two obligations are distinct; one artifact serves both
only if it demonstrates both.

A check need not be an automated test — where none is possible, a **named verification**
satisfies it and the entry says which route was taken and why. Either route owes the
**counterfactual**: the observation against the prior state. An **unobservable
counterfactual is a blocking evidence gap**, not a free pass — stop and surface; the human
may then lower the mode as a logged override. A fabricated test satisfies nothing.

**The evidence entry lives in the commit body** (see Mechanics), carries the **story path
and the named evidence but not the mode value**, and is **revalidated before every Gate-B
re-review and before the cycle-closing amend** — a fix changes the diff even when the
profile sits still. If revalidation changes the entry, the clean pass no longer covers what
is being committed: fix, re-review, close on the entry that pass validated.

**Every Gate-B call and re-review carries the path of every cited story**, so the reviewer
reads each profile itself, **plus the current evidence entry, quoted verbatim, for each
cited *profiled* story** — an unprofiled one owes no mode-derived evidence, so it
contributes a path and nothing else. One profiled story means one pair; a cycle citing
several carries all of them, because the reviewer cannot union lenses it cannot see or
judge evidence it was never given. A reviewer handed neither can only review the diff —
the lenses and the evidence obligations would exist and never be consumed.

**Two evidence gaps, two different answers.** Evidence that is *absent or inadequate* for
the mode is a **work gap**: produce it, then call. A project whose `AGENTS.md` names **no
verified quality command** cannot satisfy even `battery` — a **setup gap**: say what is
missing (`/workflow-init`'s battery step) rather than reviewing around it. Neither is a
reason to call Gate B against a weaker claim.

**Changing a profile:** the pass **proposes the complete resulting header** — both axes,
the recomputed mode, any renewed override — and the **human confirms it**, in both
directions; an agent never moves it alone. On confirmation, correct the header and append
one profile-log line. Any axis change **voids every prior override**, raised or lowered,
and `+abuse-path` follows the current security value. Passes already run under the lower
profile **keep counting** toward the floor; only the **final clean pass** must run under
the current profile. Inside an active Gate-B cycle, fold the edit into the active `WIP:`
snapshot by amend — a non-`WIP` commit reads to the hook as the cycle closing and would
discard the accumulated passes.

**What this does not do:** nothing checks which file a model actually read, whether the
header changed mid-call, or whether the lens sets were appended. This is instruction-backed
like the rest of §5; the detection is a reader comparing the pass against the story.
```

- [ ] **Step 2: Amend the "Finishing the cycle" bullet in `CLAUDE.md`**

Find (line 266–267):

```markdown
  **Finishing the cycle:** after the final clean pass, close it with
  `git commit --amend -m "<real message>"` — that replaces the WIP commit, and the hook
```

Insert a sentence at the end of that bullet's paragraph, after "…produced no fixes.":

```markdown
  **The closing message carries the validated evidence entry for every cited profiled
  story** — one each, and none for a cited unprofiled story, which owes no entry. The
  amend replaces the WIP message wholesale, so an entry written only into the WIP body is
  destroyed exactly when the cycle closes. The final commit body is the durable record;
  a PR shows commit messages, so there is no second home to keep in sync.
```

- [ ] **Step 3: Write the same Profiles subsection into the inline template**

In `plugins/dev-workflow/commands/workflow-init.md`, insert the **same text as Step 1**
before its `### Mechanics (reference)` line. It contains no repo-specific paths, counts or
file references, so it transfers verbatim — confirm that by re-reading it before pasting;
if any sentence names this repo, neutralize it in **both** copies rather than letting them
diverge.

- [ ] **Step 4: Add the same Mechanics sentence to the inline template**

Apply Step 2's inserted sentence to the template's "Finishing the cycle" bullet (line
441–444), verbatim.

- [ ] **Step 5: Verify the two copies agree — BOTH halves of the paired edit**

Capture all four extractions, assert each is non-empty, then diff the pairs. The guard is
not optional bookkeeping: a missing anchor on **both** sides produces two empty captures
that diff clean, so an unguarded check passes while verifying nothing.

```bash
P_REPO=$(sed -n '/^### Profiles — how much review this story gets$/,/^### Mechanics (reference)$/p' CLAUDE.md)
P_TMPL=$(sed -n '/^### Profiles — how much review this story gets$/,/^### Mechanics (reference)$/p' plugins/dev-workflow/commands/workflow-init.md)
M_REPO=$(sed -n '/\*\*The closing message carries the validated evidence entry/,/second home to keep in sync\./p' CLAUDE.md)
M_TMPL=$(sed -n '/\*\*The closing message carries the validated evidence entry/,/second home to keep in sync\./p' plugins/dev-workflow/commands/workflow-init.md)

for v in P_REPO P_TMPL M_REPO M_TMPL; do
  eval "[ -n \"\$$v\" ]" || { echo "EMPTY CAPTURE: $v — anchor missing"; exit 1; }
done
diff <(printf '%s\n' "$P_REPO") <(printf '%s\n' "$P_TMPL") && diff <(printf '%s\n' "$M_REPO") <(printf '%s\n' "$M_TMPL") && echo "BOTH HALVES AGREE"
```

Expected: `BOTH HALVES AGREE`, no diff output, no `EMPTY CAPTURE`. Any diff output is
drift — reconcile before committing. Both files changing is not evidence that they agree;
this check is.

- [ ] **Step 6: Commit both files together**

```bash
git add CLAUDE.md plugins/dev-workflow/commands/workflow-init.md
git commit -m "WIP: profiles subsection and evidence clause in both §5 copies"
```

---

### Task 3: Backlog — split P2+P6, re-point P5 light

**Files:**
- Modify: `todos.md` — the `## Next` section, the P2+P6 row (lines 134–141) and the P5
  light row (lines 142–146)

**Interfaces:**
- Consumes: nothing. Produces: nothing consumed by later tasks.

- [ ] **Step 1: Replace the P2+P6 row with a split record**

Replace the whole `- [ ] **P2 + P6 — risk/security profiles…**` row (lines 134–141) with:

```markdown
- [x] **P2 — risk/security profiles, and the derived validation mode.** Shipped: two
      human-confirmed axes in the story header, a mode derived as `max(risk, security)`,
      lens sets appended to the §5 gate prompts, and the Gate-B skip narrowed to need both a
      behaviourally trivial change and effective level 0. Spec:
      `docs/superpowers/specs/2026-07-26-risk-security-validation-profiles-design.md`.
- [ ] **P6 — standalone security sections in the intake, spec and gate templates:
      DELIBERATELY REJECTED, not shipped.** The profile *is* the heading: a standalone
      section would be a second surface to keep in sync with it (the docs-drift class),
      and it invites boilerplate-filling on stories where nobody knows what to write.
      Security content lives in the spec's decision record and risks discussion and in
      `AGENTS.md` invariants; the security lens set is what asks about assets, trust
      boundaries, roles, external systems and abuse paths. *Reopens when:* field use shows
      high-security content scattering incoherently across specs — that recurrence is the
      trigger, not a fresh opinion.
```

- [ ] **Step 2: Re-point the P5-light trigger**

In the P5 light row, replace `*Trigger: rides with P2*` and the sentence following it with:

```markdown
      *Trigger: the first story that runs under profiles* — the IDs exist to label what
      profiles produce, so the numbering scheme should meet a real profiled story before
      it gets a template slot.
```

- [ ] **Step 3: Verify no dangling reference to the old row**

Run: `grep -n "P2 + P6\|rides with P2\|P2+P6" todos.md docs/*.md README.md`
Expected: no hits outside this plan and the spec's own prose. Fix any that remain.

- [ ] **Step 4: Commit**

```bash
git add todos.md
git commit -m "WIP: split P2+P6 in the backlog, re-point P5 light"
```

---

### Task 4: Documentation audit — the docs that teach the workflow

**Files:**
- Modify: `docs/getting-started.md` — step 1, the intake paragraph (lines 11–17)
- Read and decide: `README.md` (the skill table row at line 21, the flow line at 83),
  `docs/coding-workflow.md`, `docs/architecture.md`, `MANIFEST.md`

**Interfaces:**
- Consumes: Task 1's header shape (quoted below). Produces: nothing.

- [ ] **Step 1: Update the getting-started intake paragraph**

In `docs/getting-started.md`, replace exactly this text — which begins mid-line at "The
`intake` skill" on line 12 and ends with "touches." on line 14:

```markdown
The `intake` skill turns it into a story:
problem, outcome, ≥3 checkable acceptance criteria, which `AGENTS.md` invariants it
touches.
```

with:

```markdown
The `intake` skill turns it into a story:
problem, outcome, ≥3 checkable acceptance criteria, which `AGENTS.md` invariants it
touches, and a **profile** — how risky this is (`trivial|standard|high`), how
security-relevant (`none|standard|high`), and the validation mode derived from the two.
It proposes all three with a reason; you confirm or correct them. The two axes decide
which extra questions the review gates ask; the derived mode decides what evidence you
owe before Gate B — a green battery, a check that fails without the change, or a named
verification on top.
```

The preceding sentence ("Say "users want to export their invoices as CSV" (or paste a
voice transcript — German is fine).") is **not** part of the replacement — starting the
new text mid-sentence would duplicate or corrupt it.

- [ ] **Step 2: Audit the remaining four files and record the verdict**

For each of `README.md`, `docs/coding-workflow.md`, `docs/architecture.md`, `MANIFEST.md`:
read the passages describing intake, the story artifact, or the gates, and either update
them or record in the commit message why the existing text stays accurate. Shipping
profiled prompts beside docs teaching the unprofiled workflow is the docs-drift class.

Run: `grep -rn "story\b" README.md docs/coding-workflow.md docs/architecture.md MANIFEST.md | grep -viE "stories/|story file"`
Expected: a short list to read; most will be accurate as-is because they describe the
workflow shape rather than the story's fields.

**Record each verdict in the plan itself**, as a line under this step — updated, or the
reason its text stays accurate.

**Verdicts (recorded during execution):**
- `docs/getting-started.md` — **updated**: step 1 now names the profile and both halves
  (axes → lenses, mode → evidence).
- `docs/coding-workflow.md` — **updated**: the intake paragraph names the profile, and
  says axes *add* lenses while Gate A's floor is unchanged.
- `README.md` — **unchanged, accurate**: its intake row is a one-line capability summary,
  not a field list, and its flow line (`idea → intake → brainstorm → …`) is unaffected —
  profiles change what each stage asks, not the stages.
- `docs/architecture.md` — **unchanged, accurate**: it describes file layout and the two
  non-obvious design decisions; no story-field claims appear in it.
- `MANIFEST.md` — **unchanged, accurate**: an inventory of the frozen `source-files/`
  extraction seed, which this change does not touch.

The WIP commit message is not the place: Task 5's soft reset discards every WIP message,
and a verdict that vanishes cannot tell a later reader "read and accurate" from "never
checked". These lines are carried into the final commit body in Task 5 Step 6.

- [ ] **Step 3: Commit**

```bash
git add docs/getting-started.md README.md docs/coding-workflow.md docs/architecture.md MANIFEST.md
git commit -m "WIP: docs audit for profiles"
```

---

### Task 5: Version bump, battery, Gate B, close the cycle

**Files:**
- Modify: `plugins/dev-workflow/.claude-plugin/plugin.json` — `"version": "0.6.0"` → `"0.7.0"`
- Modify: `plugins/dev-workflow/CHANGELOG.md` — new top entry

**Interfaces:**
- Consumes: every prior task's committed WIP state.

- [ ] **Step 1: Bump the manifest version**

`"version": "0.6.0"` → `"version": "0.7.0"`. Minor, not patch: this adds a capability to
the intake skill and the §5 rules.

- [ ] **Step 2: Add the CHANGELOG entry**

Insert as the newest entry, matching the file's existing style (no dates):

```markdown
## 0.7.0

- `intake` proposes a **risk** and **security relevance** profile per story and derives a
  **validation mode** from the two; all three are human-confirmed and recorded in the story
  header, which is their single writable copy.
- §5 gains a **Profiles** subsection: lens sets appended per axis, the Gate-B triviality
  skip narrowed for profiled stories to need both a behaviourally trivial change and
  effective level 0, and the author's evidence
  obligations per mode. The 3-pass floor and the findings protocol are unchanged, and no
  new way to skip a gate is added.
- §5's Mechanics: the cycle-closing amend carries one validated evidence entry per cited
  profiled story (and none for an unprofiled one), so the final commit
  body is its durable record.
- Unprofiled stories behave exactly as before, including today's judgement-based skip.
```

- [ ] **Step 3: Snapshot FIRST — the version bump must be committed before the battery runs**

`check-version-bump.sh` compares **commits**, not the working tree. HEAD already carries
Tasks 1–2's plugin edits, so running the battery with the bump still uncommitted fails the
check for a bump that exists on disk. Snapshot first, then measure:

```bash
git status --short                      # confirm nothing unrelated is dirty
git add plugins/dev-workflow/skills/intake/SKILL.md \
        plugins/dev-workflow/commands/workflow-init.md \
        plugins/dev-workflow/commands/process-pr-review.md \
        plugins/dev-workflow/.claude-plugin/plugin.json \
        plugins/dev-workflow/CHANGELOG.md \
        plugins/dev-workflow/hooks/codex-gate.sh \
        CLAUDE.md todos.md docs/getting-started.md docs/coding-workflow.md
git commit -m "WIP: profiles — snapshot for Gate B (0.7.0)"
git log --oneline -8
```

Record two SHAs from that listing: `SNAPSHOT` (the commit just made — the state the
battery measures and Gate B reviews) and `BASE` (the commit **before** Task 1's first WIP
commit — Gate B's `baseSha`).

- [ ] **Step 4: Run the full battery at `SNAPSHOT`**

Run (the AGENTS.md quality row, verbatim and complete — the trailing
`claude plugin validate` included, since the closing evidence will claim it ran):

```bash
shellcheck --shell=sh plugins/dev-workflow/hooks/codex-gate.sh && shellcheck --shell=sh --exclude=SC2015 plugins/dev-workflow/hooks/codex-gate.test.sh && shellcheck --shell=sh scripts/check-invariants.sh && shellcheck --shell=sh --exclude=SC2015 scripts/check-invariants.test.sh && shellcheck --shell=sh scripts/check-version-bump.sh && shellcheck --shell=sh scripts/check-version-bump.test.sh && sh plugins/dev-workflow/hooks/codex-gate.test.sh && sh scripts/check-invariants.test.sh && sh scripts/check-invariants.sh && sh scripts/check-version-bump.test.sh && sh scripts/check-version-bump.sh main && claude plugin validate . --strict
```

Expected: exit 0. `check-invariants.sh` scans the working tree, so move any untracked
scratch aside first if it trips (known, logged in `todos.md`). Every later fix invalidates
this result and requires a re-run — Step 6 says when.

- [ ] **Step 5: Write the evidence entry into the WIP body, before the first Gate-B call**

**This step applies to cited *profiled* stories only.** For each of them the spec makes the
evidence a **precondition** of the call and requires the call to quote the prepared entry
rather than compose its own. A cited **unprofiled** story — including this cycle's own
story, which predates the feature — owes no mode-derived entry: pass its path and stop
there, unless it is first adopted through §6's confirmed profile-change procedure.
Manufacturing an entry for it would impose exactly the obligation the compatibility
guarantee removes.

Where an entry is owed, amend the snapshot so its body carries it — story **path** and
named evidence, and **no profile values**:

```bash
git commit --amend -m "WIP: profiles — snapshot for Gate B (0.7.0)

Story: docs/superpowers/stories/2026-07-26-risk-security-validation-profiles-story.md
Evidence: full battery green on the tree this commit records — shellcheck (6 files),
hook tests, check-invariants + suite, check-version-bump + suite,
claude plugin validate --strict; exit 0."
```

**The entry names no SHA, deliberately.** A commit body cannot name its own hash: every
amend produces a new one, so "green at `<sha>`" is stale the instant it is written. The
tested state *is* the tree the commit records, which stays true only because Step 6 forces
a re-run before every re-review and before the close. Amending keeps the message
`WIP:`-prefixed, so the cycle stays open and no counter resets.

- [ ] **Step 6: Gate B, minimum 3 passes, file protocol**

For each pass `p`: delete `.context/codex-reviews/gate-b-spec-pass-<p>.md` **and**
`gate-b-quality-pass-<p>.md`, confirm both are gone, then call `mcp__codex__review` with
`reviewType: full`, `baseSha: <BASE>`, and an `additionalContext` that carries: the spec
path; **the path of every cited story**; **for each cited _profiled_ story, its exact
evidence entry from Step 5 quoted verbatim** — an unprofiled story contributes its path
only, and this cycle's story is unprofiled, so no entry is quoted for it; "report every
finding with severity and confidence; say `NO FINDINGS` if clean"; the one-line finding
format; and the file-first output protocol with **one path per branch**. Validate
each file (terminator, exact count, no extra lines, both branches present) before acting
on it. Fix Blocker/Major, re-review, repeat until a clean pass, writing
`<slot>-dispositions.md` per pass.

**After every accepted fix, in this order** — the order is the point, because an
uncommitted fix sits outside `baseSha..HEAD`, where Gate B would return clean on the
pre-fix diff while the closing commit carried unreviewed changes:

```bash
git add <the paths you just edited, named one by one — never -A>
git diff --cached --name-only         # confirm the staged set is exactly those paths
git diff --cached                     # and that its CONTENT is only your fix
git commit --amend --no-edit          # folds the fix into the active WIP snapshot, body intact
<re-run Step 4's battery>             # the tree changed, so the previous result is void
<re-review: next pass p+1>            # reviews the committed range, fixes included
```

`--amend --no-edit` preserves the evidence body; if a fix changes what the evidence claims,
rewrite the body with `--amend` and a full message instead of `--no-edit`.

**Name the paths from what you edited, not from a computed delta.** You made the fix, so
you know its files; `git status` cannot tell your edit from pre-existing dirt on a path
that was already modified, and a recipe that claims otherwise is wrong exactly when the
worktree is dirty — the case it would exist for. The two `--cached` lines verify the staged
set rather than deriving it.

**If a path you are about to stage was already dirty before this cycle**, whole-path
`git add` folds someone else's work into the reviewed range and the name-only check still
passes, because the path is one you meant to stage. Then: stage the fix's hunks only and
read `git diff --cached` before committing, or stop and ask. Whole-path staging is safe
only for a path that was clean when the cycle began.

**This story's own profile:** read it fresh from the story header at
`docs/superpowers/stories/2026-07-26-risk-security-validation-profiles-story.md` — the plan
does not restate profile values, for the same reason nothing else does. That story predates
this feature and carries no profile line, so it is case 2 of §5: today's behaviour, no lens
sets, no mode-derived evidence. Running it profiled would mean adopting a profile through
§6's procedure first, human confirmation included.

- [ ] **Step 7: Close the cycle with one real commit**

The closing message must carry **the same evidence entry the final clean pass validated,
one per cited profiled story** (§5 Mechanics) — none for an unprofiled story, which is
this cycle's case — plus the docs-audit verdicts from Task 4, and **no profile values**,
since the story header is their single writable copy:

```bash
git reset --soft <BASE>
git commit -F - <<'EOF'
feat(intake,§5): risk, security, and validation profiles

Two human-confirmed axes in the story header and a validation mode derived
from them; §5 appends lens sets per axis and narrows the Gate-B skip, which now needs
both a behaviourally trivial change and effective level 0. Unprofiled stories are unaffected.

Story: docs/superpowers/stories/2026-07-26-risk-security-validation-profiles-story.md
Verification: full battery green on the tree this commit records — shellcheck (6 files),
hook tests, check-invariants + suite, check-version-bump + suite,
claude plugin validate --strict; exit 0.

Docs audit: <one line per file from Task 4 Step 2 — updated, or why it stays accurate>
EOF
```

**Why `Verification:` and not `Evidence:` here.** The cited story is unprofiled, so no
mode-derived evidence entry is owed and labelling this one would claim an obligation that
does not exist. Recording what was run stays worth doing — it is ordinary honest practice,
not a profile requirement. A cycle citing profiled stories writes one `Evidence:` entry per
profiled story instead, each validated by the final clean pass.

The claim must be **re-verified immediately before this commit**, not inherited from the
last time it was run: the soft reset changes nothing about the tree, but any fix since the
last battery run would make the sentence false.

- [ ] **Step 8: Open the PR**

```bash
git push -u origin risk-security-validation-profiles
gh pr create --title "Risk, security, and validation profiles" --body "<summary + the Gate-A/Gate-B pass counts>"
```

---

## Self-Review

**Spec coverage:** §3 axes → Task 1 Step 1; §3 header + log → Task 1 Steps 2–3; §4 modes,
counterfactual, evidence record, overrides, multi-story → Task 2 Step 1 and Step 2; §5 lens
sets, three read cases, skip rules → Task 2 Step 1; §6 change procedure, floor interaction,
mid-cycle amend → Task 2 Step 1; §7 surfaces → Tasks 3 (todos split), 4 (docs audit), 5
(version + CHANGELOG); §7's paired-copy check → Task 2 Step 5; §8 invariants → Global
Constraints + Task 5 Step 3.

**Placeholder scan:** the only `<…>` placeholders left are values that cannot be known
before execution — the base SHA in Task 5, the per-file audit verdicts in Task 4's commit
message, and the PR body. Each names exactly what to substitute.

**Type consistency:** the field names `**Risk:**`, `**Security:**`, `**Validation:**`, the
mode names `battery` / `battery+check` / `battery+check+verification` / `+abuse-path`, the
event kinds `axis change` / `mode override` / `adoption`, and the level mapping
`none|trivial → 0`, `standard → 1`, `high → 2` are spelled identically in Task 1, Task 2,
Task 4 and Task 5's CHANGELOG.
