# `dev-workflow:sparring` Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Story:** `docs/superpowers/stories/2026-09-17-sparring-skill-story.md` — read the profile from its header at every gate call.

**Goal:** Ship the explicitly invoked advisory skill `dev-workflow:sparring`, correct the one document it falsifies, name it in the three inventories, and bump the plugin version.

**Architecture:** One new prompt file, loaded by convention from `skills/` (no manifest key). Its full text is fixed in the spec's §5 and is copied out of the spec mechanically, not retyped. Everything else is a small doc edit plus the version bump. No executable code changes.

**Tech Stack:** Markdown, POSIX `sh`/`awk`/`grep`, the repo's quality battery (`AGENTS.md` § Commands).

**Spec:** `docs/superpowers/specs/2026-09-17-sparring-skill-design.md` (Gate-A spec cycle `at71dccpoc`, closed). **This plan cites the spec's sections and does not restate their normative text** — the spec says so itself (its lines 6–8), because a second copy drifts.

## Global Constraints

- Work in the worktree `/Users/daniel/DEVELOPMENT/APPS/dwk-sparring`, branch `sparring-skill`. All paths below are relative to it.
- The skill text is **exactly** spec §5, the briefing text **exactly** spec §6. Copy them with the commands given; never edit them by hand. If a check fails on that text, stop and surface — a fix is a spec change, not a plan step.
- No manifest key for the skill (invariant 6). No edit to `plugins/dev-workflow/skills/intake/`, to any hook, to any command, or to `MANIFEST.md` (spec §1, §8).
- The version value is chosen **only** by the sequence in spec §2, inside Task 4. Nothing earlier writes it.
- **The integration base is `origin/main`, freshly fetched.** Local `main` is checked out in another worktree (`/Users/daniel/DEVELOPMENT/APPS/dev-workflow-kit`) and can lag; every base-sensitive check below names `origin/main` or first proves `main` equals it.
- **Run fact-establishing commands one at a time, and read each exit status.** A non-zero exit is a stop, reported with that command's own error text — except where a step names a non-zero exit as its expected result: a `grep -c` printing `0` where `0` is expected, a `grep` finding nothing where nothing is expected (both exit 1), and Task 1 Step 1's missing-file error (exit 2). Any other non-zero exit, or an expected one with different output, is a stop.
- **Unexpected repository state is a stop, not a recovery.** If the base moved, the history is not the expected shape, or staged content falls outside the File map, stop and ask Daniel. This plan deliberately contains no automatic stash, rebase-with-changes or reset: pass 2 of this plan's review showed each such recovery introducing new ways to lose work.
- No `Co-Authored-By` / `Generated with` trailers on any commit.
- `.context/codex-reviews/` holds this cycle's review artifacts and is **not ignored** by `.gitignore` — never stage, commit or delete anything there except as the §5 findings protocol says.

## A precondition of spec §2, observed resolved

Spec §2 and story §5 item 2 say two other branches both claimed `0.12.0` in prose, and that this must be reconciled **before** a Gate-B candidate is prepared. **Observed 2026-09-30:** both branches have since merged — `claude-init-command` as `0.12.0` (PR #27), `loop-rule-consolidation` as `0.13.0` (PR #28) — and `main` is `85faa49` at `0.13.3`. So the conflict the spec describes no longer exists; Task 0 and Task 4 re-observe the base instead of trusting this paragraph. The spec's description of the conflict stays as it stands: it is dated and labelled as a measurement of 2026-09-18.

## Review Focus

The spec's behaviour is prompt text, and no harness drives a skill (spec §7, "What no check reaches"). These are the failure modes most likely to bite a user, each tied to where it is checked:

1. **The skill fires on its own in an implementation chat.** Expect: never, because `disable-model-invocation: true`. → Task 1, check row 1.
2. **A pasted agent report full of "commit"/"edit" words triggers the redirect.** Expect: it is read as advisory input. → Task 4 walkthrough scenario 4.
3. **The user asks to save a summary, and every later turn gets redirected.** Expect: the save is excluded from the redirect test. → Task 4 walkthrough scenario 11.
4. **A consumer project has no `docs/SPARRING-PARTNER.md`, and the skill demands setup.** Expect: one line noting it, then work. → Task 4 walkthrough scenario 3. (Task 1's row 4 checks only three spellings — `Daniel`, `/Users/`, `pass <digit>` — and is not evidence of neutrality beyond them.)
5. **Run in a bare repo or with a broken `HEAD`, the skill says "empty repository" and drops history.** Expect: reported as unresolved, history kept. → Task 4 walkthrough scenarios 9 and 10.

---

## File map

| Path | Change | Task |
|---|---|---|
| `docs/superpowers/plans/2026-09-30-sparring-skill.md` | This plan — committed unchanged when its Gate-A cycle closes | 0 |
| `plugins/dev-workflow/skills/sparring/SKILL.md` | Create — spec §5, verbatim | 1 |
| `docs/sparring-briefing.md` | Replace lines 104–109 (the last section) with spec §6 | 2 |
| `README.md` | Add one table row after line 22 (`harden-finding`) | 3 |
| `AGENTS.md` | Line 44: `skills/{intake,harden-finding}/SKILL.md` → add `sparring` | 3 |
| `docs/architecture.md` | Line 23: same edit | 3 |
| `plugins/dev-workflow/.claude-plugin/plugin.json` | `version` bump | 4 |
| `plugins/dev-workflow/CHANGELOG.md` | New top entry | 4 |

Tasks 1–3 leave changes uncommitted. Task 4 makes the single Gate-B `WIP:` snapshot, because spec §2 requires the bump to sit inside the reviewed candidate.

---

### Task 0: Close this plan's Gate-A cycle, then confirm the base

**Files:**
- Commit: `docs/superpowers/plans/2026-09-30-sparring-skill.md`

**Interfaces:**
- Consumes: the Gate-A plan cycle `vl584i4v7j` (CLAUDE.md §5), and the SHA-256 of the plan text sent with each pass's review request, recorded in `.context/codex-reviews/gate-a-plan-vl584i4v7j-resume.md`.
- Produces: a commit on `sparring-skill` whose plan file is byte-identical to the text the final pass reviewed; a base observation Tasks 1–4 rely on.

- [ ] **Step 1: Confirm the cycle may close**

Only when the §5 closure ordering allows it: an eligible pass — a clean pass at or above floor 3, **or a zero-finding pass at any pass number** — with every closure condition holding (every in-set Blocker/Major resolved, no hold standing). Then prove the content condition:

```sh
P=docs/superpowers/plans/2026-09-30-sparring-skill.md
shasum -a 256 "$P"
```

Expected: the hash equals the one recorded for the final pass's request. If it differs, the plan changed after that pass: do not close — run another pass.

- [ ] **Step 2: Commit the reviewed text unchanged, with the cycle records**

The plan is untracked, so this is §5's "`HEAD` does not carry the text" case: commit it unchanged. Stage only that path, then commit in its own tool call:

```sh
git add docs/superpowers/plans/2026-09-30-sparring-skill.md && git diff --cached --name-only
```

Expected: exactly `docs/superpowers/plans/2026-09-30-sparring-skill.md`. Then commit with a message whose body carries the provenance line and the curve in the §5 Mechanics forms, e.g.:

```
docs(plans): add the sparring-skill implementation plan

cycle vl584i4v7j; floor 3 per {docs/superpowers/stories/2026-09-17-sparring-skill-story.md (level 1)}; hook reminder threshold absent
cycle vl584i4v7j; Gate-A plan (passes 1-<p>, codex): Findings <…>. Blockers <…>. Majors <…>.
```

(`<p>` and the counts come from the validated findings files; the knob field reads `absent` only if `.context/codex-gate.floor` does not exist — the workspace knob file the hook names, absent on 2026-09-30 — otherwise its value or `unusable`, per §5 Mechanics.)

- [ ] **Step 3: Verify the commit carries exactly the reviewed text**

```sh
P=docs/superpowers/plans/2026-09-30-sparring-skill.md
git show HEAD:"$P" | shasum -a 256
```

Expected: the same hash as Step 1. Then delete the resume note (`.context/codex-reviews/gate-a-plan-vl584i4v7j-resume.md`) — a closed cycle's working record is retired.

- [ ] **Step 4: Confirm the integration base before any edit**

Run each line as its own command and check its exit status (Global Constraints):

```sh
git status --porcelain --untracked-files=no
git fetch origin
git rev-parse origin/main
git show origin/main:plugins/dev-workflow/.claude-plugin/plugin.json | grep '"version"'
git show origin/main:plugins/dev-workflow/CHANGELOG.md | grep -m1 '^## '
gh pr list --state open --limit 1000 --json number,title,files --jq '.[] | select(any(.files[]; .path | startswith("plugins/dev-workflow/"))) | "\(.number) \(.title)"'
git merge-base --is-ancestor origin/main HEAD
```

Expected on 2026-09-30: no output (no tracked changes); fetch exit 0; `85faa49…`; `"version": "0.13.3"`; `## 0.13.3`; **no PR lines**, exit 0; exit 0 (based on current). **What an empty PR result shows, and no more:** no open PR among the first 1000 lists a `plugins/dev-workflow/` path among its first 100 files (gh's page limits). With `gh pr list --state open --json number --jq length` printing `0` (as on 2026-09-30) that is complete; any other count means reading the listed PRs by hand before choosing. If the ancestry check exits 1, `origin/main` moved since the rebase of 2026-09-30: stop and ask Daniel (Global Constraints) — this plan runs no rebase itself. Any listed PR → stop and ask Daniel which lands first: that is the reconciliation spec §2 reserves for the maintainer.

---

### Task 1: Create the skill file

**Files:**
- Create: `plugins/dev-workflow/skills/sparring/SKILL.md`

**Interfaces:**
- Consumes: spec §5, the spec's only four-backtick fence pair.
- Produces: the skill file Tasks 3 and 4 refer to.

- [ ] **Step 1: Run the checks first and see them fail to run**

```sh
F=plugins/dev-workflow/skills/sparring/SKILL.md
grep -c '^disable-model-invocation: true$' "$F"
```

Expected: `grep: …/SKILL.md: No such file or directory`, exit 2. Per spec §7 this is a missing-file error, **not** a red assertion — note it as such.

- [ ] **Step 2: Copy the text out of the spec**

```sh
S=docs/superpowers/specs/2026-09-17-sparring-skill-design.md
F=plugins/dev-workflow/skills/sparring/SKILL.md
test "$(grep -c '^````$' "$S")" = 2 || { echo "STOP: spec no longer has exactly one four-backtick fence pair"; exit 1; }
mkdir -p plugins/dev-workflow/skills/sparring
awk '/^````$/{n++; next} n==1' "$S" > "$F"
head -1 "$F"; tail -1 "$F"; wc -l < "$F"
```

Expected: first line `---`, last line `Where you are handing back a prompt, follow it with the prompt block above.`, 249 lines (dry-run measured 2026-09-30; the fence count was 2 then).

- [ ] **Step 3: Run spec §7 rows 1–4 against the file**

```sh
F=plugins/dev-workflow/skills/sparring/SKILL.md
grep -c '^disable-model-invocation: true$' "$F"                       # row 1 → 1
grep -c '^Target model:' "$F"                                          # row 2 → 1
grep -rl 'prompt artifact and follows' --include='*.md' . | grep -F "$F"   # row 2 → prints the path
grep -cE 'all ([0-9]+|one|two|three|four|five|six|seven|eight|nine|ten|eleven|twelve)( checklist)? items' "$F"  # row 3 → 0
grep -cE 'Daniel|/Users/|pass [0-9]' "$F"                               # row 4 → 0
```

Expected, in order: `1`, `1`, the path, `0`, `0` (measured on the dry-run copy 2026-09-30). `grep -c` exits 1 on a count of 0; that exit is expected there. Row 4 checks those three spellings and nothing more; other project-specific names are the walkthrough's.

- [ ] **Step 4: Run the conformance and manifest checks**

```sh
sh scripts/check-invariants.test.sh && sh scripts/check-invariants.sh
```

Expected: exit 0. A non-zero exit is a stop. Then, as a separate command:

```sh
grep -c '"skills"' plugins/dev-workflow/.claude-plugin/plugin.json    # row 5 → 0
```

Expected: `0` (exit 1, by design). `check-invariants.sh` now scans the new file, because it carries `prompt artifact and follows` and is outside `PROMPT_EXCL`; its `Target model: Claude via Claude Code` names exactly one of `Claude|Codex|GPT`, which is what the checker accepts.

No commit (see File map).

---

### Task 2: Correct the briefing (the counterfactual)

**Files:**
- Modify: `docs/sparring-briefing.md:104-109`

**Interfaces:**
- Consumes: spec §6's replacement block (the three-backtick fence right after the line `**It is replaced by:**`).
- Produces: nothing later tasks read.

- [ ] **Step 1: Show the check is wired to go red, and find references to the old heading**

```sh
grep -c 'Not a plugin feature'  docs/sparring-briefing.md
grep -c 'trigger, not a reflex' docs/sparring-briefing.md
sed -n 104p docs/sparring-briefing.md; wc -l < docs/sparring-briefing.md
grep -rn 'What this document is not\|what-this-document-is-not' . | grep -vE 'source-files/|\.context/'
```

Expected: `1`, `1`, `## What this document is not`, `109`. The reference search, measured 2026-09-30, finds the heading itself, this plan, and two **historical quotations** (spec §6 line 436, story §6 line 146) — neither is a live link, and both describe the pre-change text on purpose. Any other hit is a live reference: stop and surface it. If line 104 is anything else or the file is not 109 lines, stop: the replacement assumes that section is lines 104–109, the end of the file.

- [ ] **Step 2: Replace the section**

```sh
S=docs/superpowers/specs/2026-09-17-sparring-skill-design.md
B=docs/sparring-briefing.md
T=$(mktemp) &&
  head -n 103 "$B" > "$T" &&
  awk '/^\*\*It is replaced by:\*\*$/{g=1; next} g&&/^```$/{if(f)exit; f=1; next} f' "$S" >> "$T" &&
  test "$(wc -l < "$T")" -eq 117 &&
  cat "$T" > "$B"
rm -f "$T"
tail -n 15 "$B"
```

Expected: exit 0 (103 kept lines + 14 new = 117; `mktemp` makes a new file outside the repository, so nothing existing is overwritten; any failure before the final `cat` leaves the briefing untouched — stop). The file now ends with the 14-line block starting `## What this document is, and what the plugin ships` and ending `scaffolds it.`

- [ ] **Step 3: Verify row 7 went from 1 to 0, and that only that section changed**

```sh
grep -c 'Not a plugin feature'  docs/sparring-briefing.md
grep -c 'trigger, not a reflex' docs/sparring-briefing.md
git diff -U0 -- docs/sparring-briefing.md | grep '^@@'
```

Expected: `0`, `0`, and exactly two hunk headers whose ranges are `@@ -104 +104 @@` and `@@ -106,4 +106,12 @@` (git appends trailing context text after each; compare the ranges) — the unchanged blank line 105 splits the replacement (measured on a dry-run copy 2026-09-30). Nothing before line 104 changes. Record both before and after grep outputs for the evidence entry (Task 4). Whole-change scope is checked once, in Task 4 Step 4.

No commit.

---

### Task 3: Name the skill in the three inventories

**Files:**
- Modify: `README.md:22` (insert a row after it)
- Modify: `AGENTS.md:44`
- Modify: `docs/architecture.md:23`

**Interfaces:**
- Consumes: the skill path from Task 1.
- Produces: nothing later tasks read.

- [ ] **Step 1: See the current lines, and run the manifest-claim sweep AGENTS.md requires before editing these files**

```sh
sed -n 22p README.md; sed -n 44p AGENTS.md; sed -n 23p docs/architecture.md
cat plugins/dev-workflow/.claude-plugin/plugin.json
grep -rniE 'declare[sd]?|convention[- ]load' --include='*.md' . | grep -v source-files/
```

Expected: the `dev-workflow:harden-finding` table row; `  skills/{intake,harden-finding}/SKILL.md`; the same with its original spacing. The manifest declares no components. Read the sweep's hits in `AGENTS.md`, `docs/architecture.md` and `README.md`: each must still be true once a third skill loads by convention (it will be, since nothing is declared). This edit adds no declaration claim; the sweep confirms it falsifies none.

- [ ] **Step 2: Edit**

In `AGENTS.md` and `docs/architecture.md`, change `skills/{intake,harden-finding}/SKILL.md` to `skills/{intake,harden-finding,sparring}/SKILL.md`, nothing else on the line.

In `README.md`, insert directly after line 22:

```markdown
| `dev-workflow:sparring` | skill — invoked by name only, in a chat you open for advice: investigates read-only, checks agent reports against the current files, and drafts bounded prompts for a coding agent to run elsewhere. It advises; it does not implement, commit, or run review gates. |
```

This row paraphrases the skill's own `description:`; it adds no claim the skill does not make.

- [ ] **Step 3: Standing-lens sweep — what else enumerates the skills?**

```sh
grep -rniE '(two|2|both) skills|skills/\{|intake,harden|intake and harden' \
  --include='*.md' --include='*.sh' --include='*.json' --include='*.yml' . \
  | grep -vE 'source-files/|docs/superpowers/|\.context/'
```

Expected: exactly the two edited tree lines (`AGENTS.md:44`, `docs/architecture.md:23`), now containing `sparring`. Measured before the change on 2026-09-30: those two lines and nothing else. Any other hit is a statement this diff may falsify — stop and surface it; fixing it can widen the File map, which is Daniel's call. This grep covers those spellings only; the Gate-B lens covers the rest.

No commit.

---

### Task 4: Version, battery, evidence, Gate B

**Files:**
- Modify: `plugins/dev-workflow/.claude-plugin/plugin.json` (`version`)
- Modify: `plugins/dev-workflow/CHANGELOG.md` (new top entry)

**Interfaces:**
- Consumes: everything from Tasks 1–3, uncommitted; Task 0 Step 4's base observation.
- Produces: the reviewed candidate and its closing commit.

- [ ] **Step 1: Spec §2 step 1 — re-inspect the integration base**

Run Task 0 Step 4's commands **except** its first line (`git status --porcelain …`), since Tasks 1–3 left tracked changes. Expected: the same observation as in Task 0.

If the ancestry check now exits 1, `origin/main` moved during Tasks 1–3: **stop and ask Daniel** (Global Constraints). Do not stash or rebase over uncommitted work.

- [ ] **Step 2: Spec §2 step 2 — choose the version**

A new user-facing skill is a feature, not a fix, so the choice is the next **minor** above the base version Step 1 observed (on 2026-09-30: `0.13.3` → `0.14.0`), matching how `claude-init` took `0.12.0`. Write the chosen value down before editing anything; it is a choice made from Step 1's observation, not a reservation.

- [ ] **Step 3: Bump and log**

Set `"version"` in `plugins/dev-workflow/.claude-plugin/plugin.json` to the chosen value. In `plugins/dev-workflow/CHANGELOG.md`, insert directly above the **first `## ` heading** (the newest entry Step 1 observed):

```markdown
## 0.14.0

- **New skill: `dev-workflow:sparring`.** An advisory session for a chat you open for that
  purpose: read-only investigation, checking an agent's report against the current files,
  and bounded prompts for a coding agent to run elsewhere. `disable-model-invocation: true`
  keeps the model from invoking it on its own; that setting restricts nothing once it runs,
  and the read-only posture is an instruction the session keeps, not a sandbox. It reads an
  optional `docs/SPARRING-PARTNER.md` and never scaffolds it. No manifest key — loaded by
  convention from `skills/`.
```

(Use the chosen value in the heading if Step 2 chose differently.)

- [ ] **Step 4: Spec §2 step 3 — the WIP snapshot, bump included**

Stage and check in one tool call:

```sh
git add plugins/dev-workflow/skills/sparring/SKILL.md docs/sparring-briefing.md README.md AGENTS.md docs/architecture.md plugins/dev-workflow/.claude-plugin/plugin.json plugins/dev-workflow/CHANGELOG.md && git diff --cached --name-only && git diff --name-only
```

Expected: the staged list is exactly those seven paths; the unstaged list is empty. `git status` will still show untracked `.context/codex-reviews/` files — those stay untracked.

Then, **as a separate tool call whose entire command is this one line** (the recommended form the hook recognises as a WIP commit; the full recognition conditions are in CLAUDE.md §5 Mechanics, and a multi-line or chained tool call does not meet them):

```sh
git commit -m 'WIP: sparring skill candidate'
```

- [ ] **Step 5: Spec §2 step 4 — the battery and the remaining §7 rows**

**An evidence run** — used here, before every re-review (Step 7) and before closing (Step 8) — is these steps in order, as separate commands, and stops at the first unexpected result:

1. `test "$(git rev-parse main)" = "$(git rev-parse origin/main)"` — the local base the battery reads is current. If it fails, local `main` is stale; it is checked out in `/Users/daniel/DEVELOPMENT/APPS/dev-workflow-kit`, so ask Daniel to run `git -C /Users/daniel/DEVELOPMENT/APPS/dev-workflow-kit pull --ff-only`. Never run the battery against a stale `main`.
2. `git rev-parse HEAD` (record it) and `git status --porcelain --untracked-files=no` (must print nothing) — the files about to be read are exactly that commit.
3. The **quality** row from `AGENTS.md` § Commands, verbatim — exit 0.
4. The row-7 counterfactual, both sides: `git show origin/main:docs/sparring-briefing.md | grep -c 'Not a plugin feature'` and the same for `'trigger, not a reflex'` (expect `1`, `1` — the pre-change base), then both greps on `docs/sparring-briefing.md` (expect `0`, `0`).
5. Step 2's two commands again — same `HEAD`, still no output.

Only results from a complete evidence run go into the evidence entry; Task 2's earlier grep outputs are working checks, not evidence.

Run an evidence run now (it covers row 9, which includes row 8 and row 10's `check-version-bump.sh main`, and row 7). Then:

```sh
git diff --stat origin/main -- plugins/dev-workflow/skills/intake/    # row 6 → empty
```

- [ ] **Step 6: Walkthrough and prompt-standards write-up**

Read the skill text against spec §7's walkthrough scenarios 1–11 and write one line per scenario naming the section of the skill that decides it. Scenario 12 ("only §2 governs version timing") is about the spec and this plan, not the skill: map it to spec §2 and to Task 4 Steps 1–3, and confirm it by reading every statement about when the version is chosen in the spec, the story and this plan — each must defer to spec §2 or be labelled historical. (`grep -n '0\.1[0-9]\.[0-9]'` on the skill returning nothing shows only that the skill names no version of that spelling.) Report all of it as **text inspection, never as executed behaviour**. Then answer all twelve `docs/prompt-standards.md` items for the new file, with reasoned `n/a` where one does not apply (item 9: the stated exception in spec §3). Keep both in `.context/sparring-walkthrough.md` (not shipped); they feed the Gate-B call.

- [ ] **Step 7: Spec §2 step 5 — Gate B**

Per CLAUDE.md §5: new cycle nonce; floor **3** (story profile: `standard`/`none`, max = 1). `baseSha` = parent of the WIP commit, `headSha` = the full 40-character `git rev-parse HEAD`. Run `spec` and `quality` as **two separate** `mcp__codex__review` calls with the same `baseSha`/`headSha`, each writing its own findings file. Every call carries: the story path; the evidence entry below, verbatim; the standing lens "which existing statements does this diff falsify?", naming what this diff changes — the skill list, the version, the briefing's closing section; and the §5 findings-file instructions.

Evidence entry (goes in the commit body):

```
Evidence — docs/superpowers/stories/2026-09-17-sparring-skill-story.md
Battery: AGENTS.md quality row, exit 0 at <headSha>.
Check (counterfactual, spec §7 row 7): grep -c 'Not a plugin feature' and
'trigger, not a reflex' in docs/sparring-briefing.md read 1 and 1 before the change,
0 and 0 after.
```

Before **every** re-review: an evidence run (Step 5) at the current `HEAD`, and update `<headSha>`. Fixes: `git add` the changed paths, then, as its own one-line tool call, `git commit --amend -m 'WIP: sparring skill candidate'`, then re-review.

- [ ] **Step 8: Spec §2 step 6 — close**

Only when the §5 closure ordering allows it. Then, in order:

1. **Revalidate before closing.** An evidence run (Step 5) at the current `HEAD`, and Step 1's base inspection again. If the base moved: stop and ask Daniel. If the evidence entry would change or the version must change: the candidate changes — repair, amend the WIP commit, and re-review. The pass that was about to close is not final. Do not close.
2. **Check the ancestry and the index.** `git log --format='%h %s' origin/main..HEAD` and `git diff --cached --name-only`. Expected: exactly three commits — the `WIP:` commit at the tip, the plan commit (Task 0), the spec commit — and an empty staged list. Then close with `git commit --amend -m "<real message>"`. **Any other shape** — a commit above the WIP, a second `WIP:` commit, anything staged — **stop and ask Daniel**; §5 Mechanics' `reset --soft` shape is not run from this plan.
3. The real message's body carries the evidence entry, the Gate-B provenance line and the Gate-B curve in the §5 Mechanics forms, and no trailers.
4. Push and open a PR; bots per `docs/pr-review-bots.md`.

---

## Self-review (2026-09-30)

- **Spec coverage:** §1 rows → Tasks 1, 2, 3, 4. §2 six steps → Task 4 Steps 1–8 (base first seen in Task 0 Step 4). §3/§4/§5 → Task 1 (verbatim copy). §6 → Task 2. §7 rows 1–5 → Task 1; 6, 8–10 → Task 4; 7 → Task 2; walkthrough and 12 items → Task 4 Step 6. §8 → Global Constraints.
- **Story ACs:** 1–9 are carried by the §5 text (Task 1) and the walkthrough; 10 → Task 1 Step 4 + Task 4 Step 6; 11 → Task 3; 12 → Task 4.
- **Placeholders:** `<p>`, the curve counts, `<headSha>` and `<real message>` are values produced at run time, named where they are produced.
