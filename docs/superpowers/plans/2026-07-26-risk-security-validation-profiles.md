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
§5 template (invariant 8 keeps them inline). No hook change, no new script, no new
scaffolded file.

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

**Commit discipline for this plan:** Tasks 1–4 end with a `WIP:` commit — the hook treats a
`wip`-prefixed message as cycle-internal, so it neither fires a Gate-B STOP nor resets the
pass counters. Task 5 runs the battery, Gate B, and closes the whole cycle with one real
commit via `git reset --soft` + commit.

---

### Task 1: `intake` proposes the profile and the story template records it

**Files:**
- Modify: `plugins/dev-workflow/skills/intake/SKILL.md` — Flow step 6 (line 75), the story
  template (lines 94–120), and the calibration block after it (lines 122–128)
- Test: none — prompt artifact, no test harness exists (AGENTS.md: "there is no
  application code, so there is no typechecker to catch a defect"). Verification is
  Task 5's battery + Gate B.

**Interfaces:**
- Produces: the header line `**Risk:** … · **Security:** … · **Validation:** …` and the
  `**Profile log:**` block that Task 2's §5 text reads. The field names and the enum
  spellings defined here are quoted verbatim by Task 2 — change one, change both.

- [ ] **Step 1: Insert the profile proposal as Flow step 6**

Renumber the existing steps 6–10 to 7–11. Insert as the new step 6, immediately after the
"Tag invariants by grepping AGENTS.md" step:

```markdown
6. **Propose the profile, and let the human settle it** — two axes and a derived
   validation mode, all three confirmed before the story is written:
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

   Propose all three with one line of reason each **inside the single question round**
   of step 3 — alongside any clarifying questions, or as the whole round when nothing
   needs clarifying. Intake gains no second pause. The human confirms or corrects; a
   correction may set any value, up or down. "Proceed anyway" or "I don't know" **is**
   an answer: it accepts the proposal as it stands, and the values are recorded as
   proposed and **never lower** — a redundant lens costs a paragraph, a missing one
   costs a review. There is no "unconfirmed" profile.
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
```

- [ ] **Step 3: Document the profile log after the size calibration block**

Insert after the "**Acceptance criteria** describe observable outcomes…" paragraph
(line 128):

```markdown
**Profile log.** A `**Profile log:**` label followed by `-` entries, written **on the
first change and never before** — a story whose profile never moves carries no empty
block. One line per event: date · **event kind** (`axis change` | `mode override` |
`adoption`) · **axis identity** on an axis change (`risk`, `security`, or both in one
entry when both move) · **direction per named axis** (both may move at once and in
opposite directions) · **reason or trigger** (a finding reference when a finding caused
it, plain prose when none did) · what it changes downstream.

The log never restates the values — the header is the single writable copy, and git
history already holds what the previous values were. A mode override chosen during
intake confirmation is the first `mode override` event and creates the log.
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

**The axes steer the questions; the mode steers the evidence.** They are separate levers:
one aims the reviewer, the other obliges the author.

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
3. A profile is **present but unresolvable** (unparseable line, a value outside the enums,
   two profile blocks, a citation resolving to nothing) → **stop and surface the cause**.
   Falling back to the lighter behaviour on a malformed profile would under-review exactly
   the stories most likely to have one.

**The Gate-B triviality skip keys on the effective level, never on risk alone.** For a
profiled story it is available only when `max(risk, security)` is 0 — risk `trivial` *and*
security `none` — and the reason goes in the story's profile log. **A skip removes the
review, never the evidence:** the battery still runs and its entry still lands in the
commit body. In a cycle citing several stories, **every** cited story must be
skip-eligible. An **unprofiled** story keeps exactly today's judgement-based skip and owes
no mode-derived evidence.

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
  **The closing message carries the evidence entry** for a profiled story — the amend
  replaces the WIP message wholesale, so an entry written only into the WIP body is
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

- [ ] **Step 5: Verify the two copies agree**

Run:

```bash
diff <(sed -n '/^### Profiles — how much review this story gets$/,/^### Mechanics (reference)$/p' CLAUDE.md) \
     <(sed -n '/^### Profiles — how much review this story gets$/,/^### Mechanics (reference)$/p' plugins/dev-workflow/commands/workflow-init.md)
```

Expected: no output. Any output is drift — reconcile before committing. Both files
changing is not evidence that they agree; this diff is.

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
      lens sets appended to the §5 gate prompts, and the Gate-B triviality skip narrowed
      to effective level 0. Spec:
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

In `docs/getting-started.md`, the sentence beginning "The `intake` skill turns it into a
story: problem, outcome, ≥3 checkable acceptance criteria, which `AGENTS.md` invariants it
touches." — replace with:

```markdown
a voice transcript — German is fine). The `intake` skill turns it into a story:
problem, outcome, ≥3 checkable acceptance criteria, which `AGENTS.md` invariants it
touches, and a **profile** — how risky this is (`trivial|standard|high`), how
security-relevant (`none|standard|high`), and the validation mode derived from the two.
It proposes all three with a reason; you confirm or correct them, and that profile is
what decides which extra questions the review gates ask.
```

- [ ] **Step 2: Audit the remaining four files and record the verdict**

For each of `README.md`, `docs/coding-workflow.md`, `docs/architecture.md`, `MANIFEST.md`:
read the passages describing intake, the story artifact, or the gates, and either update
them or record in the commit message why the existing text stays accurate. Shipping
profiled prompts beside docs teaching the unprofiled workflow is the docs-drift class.

Run: `grep -rn "story\b" README.md docs/coding-workflow.md docs/architecture.md MANIFEST.md | grep -viE "stories/|story file"`
Expected: a short list to read; most will be accurate as-is because they describe the
workflow shape rather than the story's fields.

- [ ] **Step 3: Commit**

```bash
git add docs/getting-started.md README.md docs/coding-workflow.md docs/architecture.md MANIFEST.md
git commit -m "WIP: docs audit for profiles

<one line per file: updated, or why its text stays accurate>"
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
  skip narrowed to effective level 0 for profiled stories, and the author's evidence
  obligations per mode. The 3-pass floor and the findings protocol are unchanged, and no
  new way to skip a gate is added.
- §5's Mechanics: the cycle-closing amend carries the evidence entry, so the final commit
  body is its durable record.
- Unprofiled stories behave exactly as before, including today's judgement-based skip.
```

- [ ] **Step 3: Run the full battery**

Run (the AGENTS.md quality row, verbatim):

```bash
shellcheck --shell=sh plugins/dev-workflow/hooks/codex-gate.sh && shellcheck --shell=sh --exclude=SC2015 plugins/dev-workflow/hooks/codex-gate.test.sh && shellcheck --shell=sh scripts/check-invariants.sh && shellcheck --shell=sh --exclude=SC2015 scripts/check-invariants.test.sh && shellcheck --shell=sh scripts/check-version-bump.sh && shellcheck --shell=sh scripts/check-version-bump.test.sh && sh plugins/dev-workflow/hooks/codex-gate.test.sh && sh scripts/check-invariants.test.sh && sh scripts/check-invariants.sh && sh scripts/check-version-bump.test.sh && sh scripts/check-version-bump.sh main
```

Expected: exit 0. `check-invariants.sh` scans the working tree, so move any untracked
scratch aside first if it trips (known, logged in `todos.md`).

- [ ] **Step 4: Snapshot for Gate B**

```bash
git add -A && git commit -m "WIP: profiles — snapshot for Gate B"
git log --oneline -6
```

Note the SHA of the commit **before** Task 1's first WIP commit — that is `baseSha`.

- [ ] **Step 5: Gate B, minimum 3 passes, file protocol**

For each pass `p`: delete `.context/codex-reviews/gate-b-spec-pass-<p>.md` **and**
`gate-b-quality-pass-<p>.md`, confirm both are gone, then call `mcp__codex__review` with
`reviewType: full`, `baseSha` from Step 4, and an `additionalContext` that carries: the
spec path, the story path, "report every finding with severity and confidence; say `NO
FINDINGS` if clean", the one-line finding format, and the file-first output protocol with
**one path per branch**. Validate each file (terminator, exact count, no extra lines,
both branches present) before acting on it. Fix Blocker/Major, re-review, repeat until a
clean pass. Write `<slot>-dispositions.md` per pass.

This story's own profile, applied to itself: risk `standard` (prompt artifacts, no named
domain or effect trigger), security `none`, so mode `battery` — the battery in Step 3 is
the evidence, and its entry goes in the closing commit body per Step 6.

- [ ] **Step 6: Close the cycle with one real commit**

```bash
git reset --soft <sha-before-first-WIP>
git commit -F - <<'EOF'
feat(intake,§5): risk, security, and validation profiles

Two human-confirmed axes in the story header and a validation mode derived
from them; §5 appends lens sets per axis and narrows the Gate-B triviality
skip to effective level 0. Unprofiled stories are unaffected.

Validation: mode `battery` (risk standard, security none).
Evidence: full battery green — shellcheck, hook tests, check-invariants,
check-version-bump, claude plugin validate — run at <sha>, exit 0.
EOF
```

- [ ] **Step 7: Open the PR**

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
