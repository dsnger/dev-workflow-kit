# Intake amendment route — falsified files count as dependent artifacts — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Sharpen the change record's *Dependent artifacts* field in the intake skill's amendment route so a file whose statements the change makes false (an open question now answered, a status now outdated) counts as a dependent artifact. Until now only a file whose requirements change counted.

**Architecture:** This is a prose-only change to one prompt artifact, `plugins/dev-workflow/skills/intake/SKILL.md`, section "The change record". Sentences elsewhere in the same route that define or limit what a dependent artifact is are adjusted only where they would otherwise contradict the new definition (see D1). Invariant 12 also requires a plugin version bump (see D2).

**Tech Stack:** Markdown prompt (target model: Claude via Claude Code). No executable code changes.

**Spec:** `TASK.md` together with `inputs/task-backlog-entry.md`. TASK.md says to treat both as the approved spec.

**Story:** none. No story file exists for this change. Per `.claude/review-gates.md:15-23` and `:1050-1051` (case 1), every gate cycle therefore runs unprofiled with a floor of 3 passes, and each pass must say it is unprofiled.

## Global Constraints

- AGENTS.md invariant 11: the changed prompt must pass all 12 items of `docs/prompt-standards.md`. Review is the gate, because no comprehensive mechanical checker exists.
- AGENTS.md invariant 12: a change under `plugins/dev-workflow/` must change that plugin manifest's `version` in the same PR.
- AGENTS.md invariant 11, fifth narrow check: `scripts/check-invariants.sh` pins "the `intake` amendment route's change-record template and its closed sets". Any edit to the fenced template (`SKILL.md:389-403`) or the closed sets (`:405-410`) must keep that check green.
- AGENTS.md Don'ts, "Never replace a decision procedure without accounting for its old conditions": the old definition is "a file whose requirements change", and it must survive as one case of the new definition, not be replaced by it. The paragraphs around any amended rule must be checked as well.
- AGENTS.md Don'ts, "Never describe what a gate proves…": the new definition must not overclaim. For example, it must not imply that the route finds every falsified sentence in the repo.
- CLAUDE.md §3: touch only the lines this change needs, and keep the existing style of the route (terse sentences, closed sets in backticks).
- `.claude/review-gates.md:1005-1014`: files under `plugins/` are prompts, not prose, so full Gate B applies.
- Do not edit `TASK.md`, `inputs/`, or `.claude/review-gates.md`.

## Decisions that must be settled before execution

These change correctness or scope (CLAUDE.md §1), so the human decides them. My recommendation for each is marked.

- **D1 — Step 6's limiting sentence.** `SKILL.md:361-363` reads: "A spec amendment edits a story only when the decision changes that story, which then is a dependent artifact." The incident in the backlog entry is exactly this case: a spec-level decision answered a question that the story's §5 still listed as open. The story's *requirements* did not change. Under the current sentence, the story does not count as changed, so the route may not edit it, yet the new definition says it is dependent. The options:
  - (a) Widen step 6 so a story the decision falsifies is also a dependent artifact. The story is then updated in this change, or recorded with one of the existing non-updated statuses. **Recommended.** Without this, the field and step 6 contradict each other.
  - (b) Leave step 6 alone. A falsified story is listed as dependent with status `blocks <continuation> until updated` and is never edited by the route. This is consistent but leaves the stale text standing, which is the defect the backlog entry describes.
  - (c) Treat (a) as out of scope and record it as a backlog item instead.
- **D2 — Version-bump target is missing from this checkout.** Invariant 12 requires bumping `plugins/dev-workflow/.claude-plugin/plugin.json`. Neither that file nor `plugins/dev-workflow/CHANGELOG.md`, `scripts/check-invariants.sh`, or `docs/prompt-standards.md` exists in this repository (the tree holds only `.claude/review-gates.md`, `AGENTS.md`, `CLAUDE.md`, `TASK.md`, `inputs/`, and the intake `SKILL.md`). Task 2 and the battery cannot run here as written. The human must decide one of the following:
  - (a) Run the plan in the full dev-workflow-kit repository. **Recommended.**
  - (b) Accept that Task 2 and the battery are recorded as not run in this fixture.
- **D3 — Story requirement (informational).** The backlog entry says this change "needs its own story". TASK.md overrides that by naming TASK.md and the backlog entry as the approved spec. The plan follows TASK.md. The only consequence is that the gates run unprofiled, as noted under **Story** above.

## Sources and impact boundary

**Read:**
- `TASK.md` and `inputs/task-backlog-entry.md`.
- `plugins/dev-workflow/skills/intake/SKILL.md`: lines 1-60 (overview, when to use) and 300-486 (the whole amendment route, the change record, stop and ask, common mistakes).
- `AGENTS.md`, in full.
- `CLAUDE.md`.
- `.claude/review-gates.md`: lines 1-60 (floor derivation), 995-1075 (prose exemption, profiles).

**Not read:** the rest of `review-gates.md`. The executor must read it in full before any gate pass or commit (CLAUDE.md §5). The files missing from this checkout (D2) were also not read.

**Impact:** only the intake skill's amendment route. Other places in the route that use the term *dependent artifact* are step 3 (`:334-339`), step 6 (`:361-363`), step 8 (`:376-377`), step 9 (`:380-381`), the template (`:400`) and the status closed set (`:410`). Each must still read correctly under the new definition. No other skill, command or template in this checkout uses the term (`grep -n -i dependent` in `SKILL.md` shows only these lines). In the full repo, re-run `grep -rn -i "dependent artifact" --include='*.md' . | grep -v source-files/` before editing. A scaffolded or duplicated copy of the change record would have to change too.

**Handover boundary:** this plan is one unit. After the Gate-B closing act, write `.context/handover-intake-dependent-artifacts.md` and stop.

## Review Focus

1. **The PR #47 shape:** a spec amendment answers a question that a cited story's §5 lists as open, and the story's requirements do not change. Expected result: the story appears under *Dependent artifacts* with one status from the closed set. Owned by Task 1, scenario S1.
2. **An outdated status line:** for example, a story header or status sentence still says "pending" for something the decision just settled. Expected result: the file counts as dependent. Task 1, scenario S2.
3. **A file that merely mentions the changed topic but states nothing the change makes false.** Expected result: it is not dependent. This prevents the field from growing to "every file that mentions it". Task 1, scenario S3.
4. **The old case:** a file whose requirements change must still count as dependent. This is the condition the rewrite must not drop. Task 1, scenario S4.
5. **Overclaim:** the definition says what the writer must check (the files the decision's subject is stated in, which the writer knows of or finds by search). It must not promise that every false statement in the repo is found. Task 1, scenario S5 (reading check).

---

### Task 1: Sharpen the *Dependent artifacts* definition in the amendment route

**Files:**
- Modify: `plugins/dev-workflow/skills/intake/SKILL.md`, section "### The change record" (`:384-429`). Add step 6 (`:361-363`) only if D1 = (a).

**Interfaces:**
- Consumes: nothing from other tasks.
- Produces: a definition of "dependent artifact" that Task 2's CHANGELOG line summarises. The Dependent-artifact status closed set (`:410`) stays exactly as it is: the three values are unchanged in count and spelling.

**Settled by this plan:**
- A dependent artifact is a file other than the changed artifact that the change either (i) changes the requirements of (the old condition, which is kept), or (ii) makes a statement false in. Examples of (ii): an open question the decision answers, a status or "pending" marker it settles, a description of the old condition.
- Each dependent artifact still takes exactly one status from the existing closed set.
- The field's `none` answer stays available, but only when no file meets either case.

**Implementer's decision space:**
- The exact wording.
- Where the definition sits. Recommended: one short paragraph directly after the closed sets (`:405-410`), so the fenced template line `:400` stays byte-identical and the mechanical check 5 is untouched. Editing the template placeholder instead is allowed only if check 5 is run and stays green.
- Whether a third example is worth its length.

**Old conditions to account for** (the Don'ts rule on replacing a decision procedure). Record each as kept, moved or dropped in the commit body:
- step 6: "edits a story only when the decision changes that story". Kept under D1 (b) or (c); amended under D1 (a).
- step 3: every dependent artifact is captured and reconciled before writing. Kept: it now covers falsified files too.
- step 8: only artifacts marked `updated in this change` are staged. Kept.
- `:420-422`: `open` needs a cited rule. Kept.

- [ ] **Step 1: Write the reading-check scenarios before editing.** Put them in the PR description draft, not in the repo. Then check that the current text fails S1 and S2:
  - S1 (PR #47): a spec decision answers a question that a story's §5 lists as open, and the story's requirements are unchanged. Current text: the story is not dependent, so the field says `none`. **Expected after the change:** listed, with a status.
  - S2: a status line in another doc says "pending" for the decided item. Expected: listed.
  - S3: a doc mentions the topic and states nothing the decision makes false. Expected: not listed.
  - S4: a story whose criterion the spec change alters. Expected: listed (unchanged behaviour).
  - S5: the definition does not claim the route finds every false statement anywhere.
- [ ] **Step 2: Confirm the failure.** Read `:361-363` and `:400-410` against S1 and S2. Expected: nothing in the current text makes the story in S1 dependent. Note the quoted lines as evidence.
- [ ] **Step 3: Edit** the change-record section, and step 6 only if D1 = (a), within the decision space above.
- [ ] **Step 4: Re-run S1-S5 against the edited text.** Each must give the expected result. Also re-read steps 3, 8 and 9 and `:420-422` to confirm none of them now contradicts the definition.
- [ ] **Step 5: Run the prompt checks.** Walk all 12 items of `docs/prompt-standards.md` and record pass or fail for each. Run `sh scripts/check-invariants.test.sh && sh scripts/check-invariants.sh`. Expected: exit 0. If D2 = (b), record both as **not run, file absent**.
- [ ] **Step 6: Run the overclaim recipe** from AGENTS.md Don'ts over the edited file and read every hit:
  `grep -niE '(every|all|any)[^.]{0,80}\b(false|falsif|dependent)' plugins/dev-workflow/skills/intake/SKILL.md`
- [ ] **Step 7: Leave the work uncommitted.** It is committed together with Task 2 at the Gate-B WIP commit, because the version-bump check compares commits.

### Task 2: Version bump and changelog (invariant 12)

Blocked until D2 is settled.

**Files:**
- Modify: `plugins/dev-workflow/.claude-plugin/plugin.json`, the `version` field only.
- Modify: `plugins/dev-workflow/CHANGELOG.md`, a new entry at the top.

**Interfaces:**
- Consumes: Task 1's definition, for the changelog line.
- Produces: the new version string.

**Settled:** bump the patch number. This is a clarification of an existing field, with no new field, status or step. If D1 = (a) widens step 6's behaviour, the implementer may choose minor instead and should say why in the commit body.

- [ ] **Step 1:** Read `plugin.json` and the newest CHANGELOG entry to get the current version and the entry style.
- [ ] **Step 2:** Bump the `version`, then add one CHANGELOG entry in the existing style that describes the sharpened definition and, if applicable, step 6.
- [ ] **Step 3: Commit** the WIP for Gate B, staging exactly the touched paths (no `git add -A`, no Co-Authored-By or Generated-with trailers, per AGENTS.md):
  `git add plugins/dev-workflow/skills/intake/SKILL.md plugins/dev-workflow/.claude-plugin/plugin.json plugins/dev-workflow/CHANGELOG.md`
  Commit message: `fix(intake): count falsified files as dependent artifacts`.
- [ ] **Step 4: Run the full quality battery** (the AGENTS.md § Commands "quality" row), including `sh scripts/check-version-bump.sh main` now that the work is committed. Expected: exit 0. Report any step that could not run as not run.

### Gate B

- [ ] Read `.claude/review-gates.md` in full, then run Gate B on the diff. The cycle is unprofiled with a floor of 3 and no story cited, and each pass says so. Then perform the Gate-B closing act as that file defines it.
- [ ] Write the handover (see **Handover boundary**) and stop.
