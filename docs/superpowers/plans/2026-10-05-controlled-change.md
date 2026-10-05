# Controlled Change (G1a) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Story:** `docs/superpowers/stories/2026-10-05-controlled-change-to-an-approved-story-story.md` — read the profile from its header at every gate call.

**Goal:** `intake` gains an amendment route that writes a complete change record for an approved story or spec; `sparring` points at it; a rung-2 check pins the record's shape.

**Architecture:** Prompt text in two shipped skills, plus check `4f` in the repo-local `scripts/check-invariants.sh`. No new skill, no new file in the plugin.

**Tech Stack:** Markdown prompts, POSIX `sh` + `awk` (checker and its suite), shellcheck 0.11.0.

**Spec:** `docs/superpowers/specs/2026-10-05-controlled-change-design.md` (Gate-A spec cycle `lbveuxkbje`, closed in `832510b`).

## Global Constraints

- dev-workflow manifest `0.16.0` → `0.17.0`, with a `CHANGELOG.md` entry (invariant 12).
- Both skills pass all 12 items of `docs/prompt-standards.md` (invariant 11).
- The route adds no gate rule, approval level or exemption, and summarises no gate rule: it cites the source paragraph (spec §2, `AC-6`).
- ID handling is intake's rules 1–5, unchanged (`AC-2`).
- `sparring`'s *Authority* section is unchanged (`AC-8`).
- Out of scope: a separate skill, approval levels, dashboard work, 2c part-4b calibration (`AC-10`).
- `checker` stays POSIX `sh`; new shell passes `shellcheck --shell=sh` with the file's existing exclusions.

## Review Focus

1. **The new section drifts from the 4f literals.** A wording edit to a pinned line fails CI with a 4f diagnostic. Expected: the diagnostic names the line's number. Pinned by Task 1's per-line reject cases, which each assert `line <n> occurs 0 times`.
2. **The shared intake fixture lacks the new section.** Every existing suite case would fail on 4f first. Expected: the fixture carries a valid section, so each case still reaches its own assertion. Pinned by Task 1 Step 1 (`ac_skill` appends it) and the whole suite staying green.
3. **A pinned line sits outside the section** (for example in *Common mistakes*). Expected: rejected, because only the section is read. Pinned by Task 1's "outside the section" case.
4. **The route's text summarises a gate rule.** Expected: none; it cites paragraph titles. Checked by Task 2 Step 3's grep and by Gate B.
5. **The replay agent sees the expected answer.** Expected: the package withholds the fate tables. Checked by Task 4 Step 2's grep over the package.

---

### Task 1: Check 4f and its suite

**Files:**
- Modify: `scripts/check-invariants.sh` (header comment; new block after `# --- END check 4e ---`)
- Modify: `scripts/check-invariants.test.sh` (fixture helper `ac_skill`; new case block before the final summary; mutation record in the header comment)

**Interfaces:**
- Produces: the 12 required lines (below), which Task 2's skill text must contain verbatim inside `## Amending an approved story or spec`.

The 12 required lines (exact, one per line):

````text
**Changed YYYY-MM-DD — <reason class>.** Decided by <who>, <where>. Baseline: <commit or approved-content hash>. <Rationale.>
| Earlier condition | Fate | AC operation |
- **Unaccounted:** <condition> → blocks <named continuation> until settled; or none.
- **Intervening changes:** <change since the baseline> → <how accounted>; or none.
- **Scope boundary:** in: <…>; out: <…>.
- **Open questions:** <question> → <where recorded>; or none.
- **Dependent artifacts:** <path> → <status>; or none.
- **Reviews already run:** <input or cycle> → <consequence>, per <rule cited>; or "no rule found" (<input>, <paragraphs checked>) → <human decision, or pending: blocks <continuation>>.
- **Reason class**, exactly one: `changed requirement` · `gap found` · `change of direction`.
- **Fate**, one or more per condition: `kept` · `moved → <destination>` · `dropped — <reason>`.
- **AC operation**, per intake's ID rules: `none` · `reworded` · `narrowed` · `withdrawn` · `added AC-<n>`.
- **Dependent-artifact status**, exactly one: `updated in this change` · `open — permitted by <rule>` · `blocks <named continuation> until updated`.
````

- [ ] **Step 1: Shared fixture carries a valid section.** In `scripts/check-invariants.test.sh`, after the `AC_RULE_LINE=` assignment, add:

````sh
# 4f: the 12 lines the amendment route's change-record template must carry, verbatim.
# shellcheck disable=SC2016  # literal Markdown backticks, not command substitution
CR_LINES='**Changed YYYY-MM-DD — <reason class>.** Decided by <who>, <where>. Baseline: <commit or approved-content hash>. <Rationale.>
| Earlier condition | Fate | AC operation |
- **Unaccounted:** <condition> → blocks <named continuation> until settled; or none.
- **Intervening changes:** <change since the baseline> → <how accounted>; or none.
- **Scope boundary:** in: <…>; out: <…>.
- **Open questions:** <question> → <where recorded>; or none.
- **Dependent artifacts:** <path> → <status>; or none.
- **Reviews already run:** <input or cycle> → <consequence>, per <rule cited>; or "no rule found" (<input>, <paragraphs checked>) → <human decision, or pending: blocks <continuation>>.
- **Reason class**, exactly one: `changed requirement` · `gap found` · `change of direction`.
- **Fate**, one or more per condition: `kept` · `moved → <destination>` · `dropped — <reason>`.
- **AC operation**, per intake'"'"'s ID rules: `none` · `reworded` · `narrowed` · `withdrawn` · `added AC-<n>`.
- **Dependent-artifact status**, exactly one: `updated in this change` · `open — permitted by <rule>` · `blocks <named continuation> until updated`.'
# cr_section [LINES]: the amendment section holding LINES (default: all 12).
cr_section() { printf '## Amending an approved story or spec\n\nprose\n\n%s\n\n## Stop and ask\n' "${1-$CR_LINES}"; }
````

  and change `ac_skill` so its file ends with the section — replace its `printf` line with:

````sh
  printf '# intake\n\n## Story template\n\n```markdown\n# T\n\n## 3. Acceptance criteria\n%s%s\n\n## 4. Affected AGENTS.md invariants\n- none\n```\n\n%s\n\n%s\n' \
    "$rule" "$region" "${2:-}" "$(cr_section)"
````

- [ ] **Step 2: Reject/accept cases.** Before the final `printf '\n---\n'`, add:

````sh
# --- Prompt conformance: check 4f, the amendment route's change-record template --------
#
# Each case writes an intake skill whose story template is valid (so 4d stays quiet) and
# whose amendment section varies. Rejects must carry the shared 4f diagnostic phrase.
CR='change-record template'
cr_case() { # $1 = name, $2 = 1|0 expect reject, $3 = text after the story template,
  #            $4 = optional diagnostic substring a reject must also carry
  rm -rf "$work/r"; mkdir -p "$work/r/scripts" "$work/r/.github/workflows" \
    "$work/r/plugins/p/.claude-plugin"
  cp "$CHECKER" "$work/r/scripts/"
  init_prompt_fixtures "$work/r"
  printf '%s\n' '{"name": "p", "version": "1.0.0"}' > "$work/r/plugins/p/.claude-plugin/plugin.json"
  printf '%s\n' "$PINNED" > "$work/r/.github/workflows/ci.yml"
  # shellcheck disable=SC2016  # literal Markdown fence, not command substitution
  printf '# intake\n\n## Story template\n\n```markdown\n# T\n\n## 3. Acceptance criteria\n%s\n%s\n\n## 4. Affected AGENTS.md invariants\n- none\n```\n\n%s\n' \
    "$AC_RULE_LINE" "$(ac_rows 3)" "$3" > "$work/r/plugins/dev-workflow/skills/intake/SKILL.md"
  out=$( cd "$work/r" && sh scripts/check-invariants.sh 2>&1 ); st=$?
  if [ "$2" -eq 1 ]; then
    if [ "$st" -eq 0 ]; then fail "$1 (exited 0)"
    elif ! printf '%s' "$out" | grep -qF "$CR" || ! printf '%s' "$out" | grep -qF -- "${4:-$CR}"; then
      fail "$1 (wrong diagnostic: $(printf '%s' "$out" | tr '\n' ' '))"
    else pass "$1"; fi
  else
    if [ "$st" -eq 0 ]; then pass "$1"
    else fail "$1 (exited $st: $(printf '%s' "$out" | tr '\n' ' '))"; fi
  fi
}
cr_case "4f: valid section accepted"                   0 "$(cr_section)"
cr_case "4f: section last in the file accepted"        0 "$(printf '## Amending an approved story or spec\n\n%s\n' "$CR_LINES")"
cr_case "4f: no amendment section rejected"            1 "## Stop and ask"
cr_case "4f: two amendment sections rejected"          1 "$(cr_section)
$(cr_section)"
cr_case "4f: a duplicated required line rejected"      1 "$(cr_section "$CR_LINES
$(printf '%s\n' "$CR_LINES" | sed -n 1p)")"
cr_case "4f: a required line outside the section rejected" 1 \
  "$(cr_section "$(printf '%s\n' "$CR_LINES" | sed 1d)")
$(printf '%s\n' "$CR_LINES" | sed -n 1p)"
# cr_i, not i: init_prompt_fixtures (called by cr_case) uses and leaves a global i.
cr_i=1
while [ "$cr_i" -le 12 ]; do
  cr_case "4f: required line $cr_i missing rejected" 1 \
    "$(cr_section "$(printf '%s\n' "$CR_LINES" | sed "${cr_i}d")")" "line $cr_i occurs 0 times"
  cr_case "4f: required line $cr_i altered rejected" 1 \
    "$(cr_section "$(printf '%s\n' "$CR_LINES" | sed "${cr_i}s/\$/ x/")")" "line $cr_i occurs 0 times"
  cr_i=$((cr_i + 1))
done
inject_case "4f change-record parser failure fires" awk '*cr-template-scan*' \
  'change-record template parser failed'
````

- [ ] **Step 3: Run the suite; it fails.**

Run: `sh scripts/check-invariants.test.sh 2>&1 | tail -3`
Expected: `… FAILED`, with the `4f: … rejected` cases and `4f change-record parser failure fires` failing (`exited 0`), since no 4f exists yet.

- [ ] **Step 4: Implement 4f.** In `scripts/check-invariants.sh`, after `# --- END check 4e ---`, add:

````sh

# --- BEGIN check 4f ---
# The `intake` amendment route writes a change record for an approved story or spec (G1a).
# Its shape is pinned here: inside the one `## Amending an approved story or spec` section
# (up to the next `## ` heading), each of the 12 lines below occurs exactly once. They are
# the template's heading line, table header and six field lines, and the four closed sets
# (reason class, fate, AC operation, dependent-artifact status).
#
# What it does NOT catch: whether the procedure prose around them is right, whether any
# written record follows the template, or whether its values are true. It pins the
# template's spelling only.
# The backticks are literal Markdown, not command substitution.
# shellcheck disable=SC2016
CR_REQ='**Changed YYYY-MM-DD — <reason class>.** Decided by <who>, <where>. Baseline: <commit or approved-content hash>. <Rationale.>
| Earlier condition | Fate | AC operation |
- **Unaccounted:** <condition> → blocks <named continuation> until settled; or none.
- **Intervening changes:** <change since the baseline> → <how accounted>; or none.
- **Scope boundary:** in: <…>; out: <…>.
- **Open questions:** <question> → <where recorded>; or none.
- **Dependent artifacts:** <path> → <status>; or none.
- **Reviews already run:** <input or cycle> → <consequence>, per <rule cited>; or "no rule found" (<input>, <paragraphs checked>) → <human decision, or pending: blocks <continuation>>.
- **Reason class**, exactly one: `changed requirement` · `gap found` · `change of direction`.
- **Fate**, one or more per condition: `kept` · `moved → <destination>` · `dropped — <reason>`.
- **AC operation**, per intake'"'"'s ID rules: `none` · `reworded` · `narrowed` · `withdrawn` · `added AC-<n>`.
- **Dependent-artifact status**, exactly one: `updated in this change` · `open — permitted by <rule>` · `blocks <named continuation> until updated`.'

# Prints `ok`, or one line naming the first problem. Returns 2 if awk itself failed.
cr_template_scan() { # $1 = file
  CR_REQ="$CR_REQ" awk '                           # cr-template-scan
    BEGIN { n = split(ENVIRON["CR_REQ"], req, "\n"); for (i = 1; i <= n; i++) want[req[i]] = 0 }
    $0 == "## Amending an approved story or spec" { heads += 1; insec = 1; next }
    insec && /^## / { insec = 0; next }
    insec && ($0 in want) { want[$0] += 1 }
    END {
      if (heads == 0) { print "no `## Amending an approved story or spec` section"; exit }
      if (heads > 1) { print heads " `## Amending an approved story or spec` sections"; exit }
      for (i = 1; i <= n; i++) if (want[req[i]] != 1) {
        print "line " i " occurs " want[req[i]] " times in the section, need exactly 1: " req[i]; exit
      }
      print "ok"
    }
  ' "$1" || return 2
}

if [ ! -f "$AC_FILE" ]; then
  fail "Prompt standards: $AC_FILE is missing, so the change-record template cannot be checked." \
       "the intake skill is required"
elif [ ! -r "$AC_FILE" ]; then
  fail "Prompt standards: $AC_FILE is unreadable, so the change-record template cannot be checked." \
       "check permissions"
else
  cr_out=$(cr_template_scan "$AC_FILE"); cr_st=$?
  if [ "$cr_st" -ne 0 ]; then
    fail "Prompt standards: the change-record template parser failed; results are not trustworthy." \
         "awk exited $cr_st on $AC_FILE"
  elif [ "$cr_out" != ok ]; then
    fail "Prompt standards: the intake change-record template is malformed: $cr_out" \
         "the amendment section carries each of the 12 template lines exactly once"
  fi
fi
# --- END check 4f ---
````

  Note: `ENVIRON` with a multi-line value and `split(..., "\n")` are POSIX awk.

- [ ] **Step 5: Header comment.** In the header's mutation paragraph, replace `The four prompt-conformance
# checks below, and the size-budget check 4e, are bracketed` with `The prompt-conformance checks
# below (4a-4d and 4f), and the size-budget check 4e, are bracketed`, `and likewise for 4b, 4c, 4d and 4e`
with `and likewise for 4b, 4c, 4d, 4e and 4f`, and `chk=4a   # then 4b, 4c, 4d, then 4e` with
`chk=4a   # then 4b, 4c, 4d, 4e, then 4f`. In the scan-domain comment (one line reads `# so this domain stays a two-check domain even though the file now carries four`), replace `now carries four` with `now carries five` (4a–4d and 4f; 4e is a size check), and in the next lines `Incrementing the number here would claim a scope 4c and 4d do` with `Incrementing the number here would claim a scope 4c, 4d and 4f do`.

- [ ] **Step 6: Suite passes (with Task 2's intake text still absent the real-repo run fails — expected until Task 2).**

Run: `sh scripts/check-invariants.test.sh 2>&1 | tail -1`
Expected: `all passed (<N> assertions)`.

Run: `shellcheck --shell=sh scripts/check-invariants.sh && shellcheck --shell=sh --exclude=SC2015 scripts/check-invariants.test.sh; echo sc=$?`
Expected: `sc=0`.

No commit until Task 5.

### Task 2: The intake amendment route and the sparring pointer

**Files:**
- Modify: `plugins/dev-workflow/skills/intake/SKILL.md` (frontmatter `description`; *When to use*; new section before `## Stop and ask`; *Stop and ask* intro and *No AGENTS.md* bullet; *Common mistakes*)
- Modify: `plugins/dev-workflow/skills/sparring/SKILL.md` (*Coding-agent prompts*)

**Interfaces:**
- Consumes: the 12 lines from Task 1, verbatim.

- [ ] **Step 1: Frontmatter and *When to use*.** Replace the `description:` line with:

````text
description: Use at the very start of the workflow, when a raw idea, voice transcript (German or English), or backlog line needs capturing before superpowers:brainstorming — or later, when an approved story or spec must change after a decision to change it, to write a change record that accounts for every earlier condition. Not for designing the solution.
````

  In *When to use*, add a third bullet and replace the closing paragraph:

````text
- An approved story or spec must change after a human decided to change it — narrowed,
  redirected, or corrected for a gap found later. Use the separate route *Amending an
  approved story or spec* below, not the Flow.

Not for designing a solution (that's `superpowers:brainstorming`), and not for starting a
new story for an item that already has an approved one; an approved artifact changes
only through the amendment route.
````

- [ ] **Step 2: The new section.** Insert before `## Stop and ask`:

`````markdown
## Amending an approved story or spec

A second route, separate from the Flow. Use it when an approved story or spec must change
after a human decided to change it. It writes one **change record** into the changed
artifact, so that no earlier condition disappears unnoticed: a dropped condition looks
exactly like text that was never there (AGENTS.md, "Never replace a decision procedure
without accounting for its old conditions").

It runs none of the Flow's steps — no question round, profile proposal, new file or
brainstorming hand-off — because the decision already exists and a second approval would
be a step nobody asked for. It makes no new solution-design decision: for a story the
WHAT/WHY boundary holds as in the Flow; for a spec the record may state a technical
condition that was already decided, because recording it is not designing it.

**Who runs it:** the session allowed to change files. An advisory `dev-workflow:sparring`
session drafts the record in the conversation and hands it over in its coding-agent
prompt; the coding session writes it here.

### Steps

1. **Establish the decision.** Name the explicit human decision that covers the change:
   who, when, where (a message, a review thread, a commit). If no decision covers the
   whole change, ask the uncovered question and wait, then continue on the answer. This
   is the route's only question, because the human already decided the rest.
2. **Fix the baseline**: the approved text the change is measured against — the commit at
   which it was last approved, or, for approved text never committed, the content hash
   recorded with the approval (for example the hash a Gate-A request pinned). If it cannot
   be established, stop and name what is missing: substituting `HEAD` or the working copy
   would measure the change against text nobody approved.
3. **Capture and reconcile the current state of every file the route will write** — the
   changed artifact and each dependent artifact (working tree and index); a path the
   route will create must not exist yet. List each edit made since the baseline in the
   record's *Intervening changes*, accounted for like any other condition; put any the
   decision does not cover to the human under step 1. Preserve unrelated edits. Concurrent
   identifier claims stay under *Acceptance-criterion IDs* rule 3.
4. **Enumerate the baseline's conditions** before assigning any fate: every criterion,
   every outcome or scope sentence that constrains the result, every stated exclusion. The
   list is what reveals an omitted condition; a template cannot. For a spec, also read the
   stories its `Story:` header names and map each changed condition to the criteria it
   serves.
5. **Assign a fate and an AC operation** to every enumerated condition (one row per
   condition, or per run of criteria sharing a fate). Then check that every condition has
   a row. A condition nobody decided goes to *Unaccounted*, never into the table under a
   fate it does not have.
6. **Apply *Acceptance-criterion IDs* rules 1–5 exactly as written.** Cite each affected
   criterion in rule 4's form (with or without identifiers). Any amendment of an older
   story adopts identifiers under rule 5, even when no criterion's wording changes.
   Criterion operations apply only to criteria the decision changes. A spec amendment
   edits a story only when the decision changes that story, which then is a dependent
   artifact.
7. **Fill the remaining fields.** For *Reviews already run*, cite, for each review input the
   change touches and each cycle it affects, the paragraph of the project's gate rules
   (`.claude/review-gates.md` where `/workflow-init` scaffolded them) that decides the
   consequence. Quote or cite; never summarise what a rule decides, because a summary
   drifts from its source. Write "no rule found" only after checking, naming the input
   and the paragraphs checked, and then the human's decision or that it is pending.
8. **Write and commit, deferring to the gate rules.** Immediately before writing, every
   file must still equal what step 3 captured; before staging, each must equal what you
   wrote. Any other difference returns to step 3. Then decide from the gate rules, not
   from this route, whether the complete changed set owes a gate (see the gate rules'
   paragraph on what counts as prose) or an open cycle governs the commit; if so, hand the
   commit to that gate and stop here. Otherwise commit on your own: stop if the index
   already holds staged work you did not stage; stage exactly the changed artifact and the
   dependent artifacts marked `updated in this change`; check that the staged paths are
   exactly those and each staged file equals what you wrote; commit with a message naming
   the change, the decider and the date.
9. **Stop.** Name what the change unblocks and what stays blocked (*Unaccounted*,
   dependent artifacts, reviews). Resume nothing on your own: the next gate, plan or
   implementation step is the human's or its own workflow's to start.

### The change record

Place it in the changed artifact: in a story at the end of §3, in a spec at the end of the
section it changes. Shape:

```markdown
**Changed YYYY-MM-DD — <reason class>.** Decided by <who>, <where>. Baseline: <commit or approved-content hash>. <Rationale.>

| Earlier condition | Fate | AC operation |
|---|---|---|
| <AC-n, or the quoted condition> | <fate, or several> | <operation> |

- **Unaccounted:** <condition> → blocks <named continuation> until settled; or none.
- **Intervening changes:** <change since the baseline> → <how accounted>; or none.
- **Scope boundary:** in: <…>; out: <…>.
- **Open questions:** <question> → <where recorded>; or none.
- **Dependent artifacts:** <path> → <status>; or none.
- **Reviews already run:** <input or cycle> → <consequence>, per <rule cited>; or "no rule found" (<input>, <paragraphs checked>) → <human decision, or pending: blocks <continuation>>.
- **Evidence (optional):** <link, for example a spec-delta report>.
```

The closed sets:

- **Reason class**, exactly one: `changed requirement` · `gap found` · `change of direction`.
- **Fate**, one or more per condition: `kept` · `moved → <destination>` · `dropped — <reason>`.
- **AC operation**, per intake's ID rules: `none` · `reworded` · `narrowed` · `withdrawn` · `added AC-<n>`.
- **Dependent-artifact status**, exactly one: `updated in this change` · `open — permitted by <rule>` · `blocks <named continuation> until updated`.

A narrowing usually carries several fates in one row — the part kept and the part moved
or dropped — because naming only the surviving part hides what left the scope. A
replacement is `withdrawn` plus `added AC-<n>`. `open` needs a cited rule that permits
leaving the artifact; where a rule demands the update in the same commit, `open` is not
available.

Example rows, one narrowing and one replacement:

```markdown
| AC-3: export runs nightly and on demand | kept: on demand; dropped — nightly: the scheduler is out of this release | narrowed |
| AC-4: progress shown as a percentage | dropped — no reliable total exists; moved → AC-6 (a step counter) | withdrawn; added AC-6 |
```
`````

- [ ] **Step 3: Check the section cites and does not summarise.**

Run: `sed -n '/^## Amending an approved story or spec/,/^## Stop and ask/p' plugins/dev-workflow/skills/intake/SKILL.md | grep -niE 'costs? (a|one|at least) (further )?pass|new cycle is (owed|required)|closed cycle stands'; echo "hits=$?"`
Expected: `hits=1` (no line states a gate consequence).

- [ ] **Step 4: Scope the global sections.** In `## Stop and ask`, insert after the heading:

````text
These stops belong to the Flow. The amendment route's stops are in its own steps; only
**No AGENTS.md** applies to both routes.
````

  Replace the *No AGENTS.md* bullet with:

````text
- **No AGENTS.md:** stop and offer `/dev-workflow:workflow-init` — Section 4 is
  ungroundable without it, and an amendment cannot check its accounting against the
  invariant it serves.
````

  In `## Common mistakes`, replace `- Designing a solution (HOW) anywhere outside Section 4.` with
  `- Designing a solution (HOW) anywhere outside a story's Section 4.`, replace
  `- Committing with \`git add -A\`, or committing text the user hasn't approved.` with
  `- Committing with \`git add -A\`, or, in the Flow, committing text the user hasn't approved.`, replace `- Leaving Section 4 or the invariants empty instead of the explicit "No AGENTS.md
  invariants matched".` with `- Leaving a story's Section 4 or the invariants empty instead of the explicit
  "No AGENTS.md invariants matched".`, and append:

````text
- In an amendment: giving an undecided condition a fate instead of listing it under
  *Unaccounted*, or summarising what a gate rule decides instead of citing it.
````

- [ ] **Step 5: The sparring pointer.** In `plugins/dev-workflow/skills/sparring/SKILL.md`, after the paragraph ending `and git state.` in *Coding-agent prompts*, add:

````text
**When the advice is to change an approved story or spec**, draft the change record in the
conversation, in the shape `dev-workflow:intake` gives under *Amending an approved story
or spec*, and put it in the prompt's scope: the coding session writes it through that
route. Point at intake's section rather than restating its steps, so the two cannot drift.
````

- [ ] **Step 6: Real-repo check passes.**

Run: `sh scripts/check-invariants.sh`
Expected: `invariant checks: ok`.

### Task 3: Version, changelog, falsified statements, mutation record

**Files:** `plugins/dev-workflow/.claude-plugin/plugin.json`, `plugins/dev-workflow/CHANGELOG.md`, `AGENTS.md`, `README.md`, `todos.md`, `scripts/check-invariants.test.sh` (header record)

- [ ] **Step 1: Version.** `"version": "0.16.0"` → `"version": "0.17.0"`.
- [ ] **Step 2: Changelog.** Insert above `## 0.16.0`:

````markdown
## 0.17.0

- **`intake` gains an amendment route** for an approved story or spec, separate from the
  new-story Flow. It writes one change record into the changed artifact: the decision
  and its source, the baseline, a fate for every earlier condition (`kept`, `moved`,
  `dropped`) with the criterion operation under the existing ID rules, unaccounted
  conditions, intervening edits, the scope boundary, open questions, dependent artifacts
  and the consequence for reviews already run, cited from the gate rules and never
  summarised. It adds no approval step and resumes nothing on its own. *Stop and ask* and
  *Common mistakes* now say which route each item belongs to.
- **`sparring` points at it**: an advisory session drafts the change record and hands it
  over in its coding-agent prompt; it still writes no files.
````

- [ ] **Step 3: AGENTS.md invariant 11.** Replace `Four narrow checks` with `Five narrow checks`, and replace
  `amendment renumbered anything) — and they are a floor` with
  `amendment renumbered anything), and the \`intake\` amendment route's change-record template
    and its closed sets (not whether the procedure prose is right or any written record
    follows them) — and they are a floor`.
- [ ] **Step 4: README.** In the `dev-workflow:intake` row, append before ` |`: ` Also amends an approved story or spec with a change record that accounts for every earlier condition.`
- [ ] **Step 5: todos.md.** In G1a's entry, replace `*Status:* ready for intake; activated only when Daniel
        selects it.` with `*Status:* selected 2026-10-05 (Daniel); shipped in dev-workflow 0.17.0.`
  And replace `      - G1a's refinement procedure belongs to the sparring role.` with
  `      - G1a's refinement procedure is drafted by the sparring role and written by the coding
        session through intake's amendment route.`
- [ ] **Step 6: Statements this change falsifies.**

Run: `grep -rnE "four narrow|Four narrow|carries four|four prompt-conformance|4a-4e|4a–4e|0\.16\.0|refinement procedure belongs" --include='*.md' --include='*.sh' --include='*.yml' --include='*.json' . | grep -vE 'docs/superpowers/|source-files/|\.context/|CHANGELOG.md'`
Expected: no hit (each one found is updated, or listed with its reason in the Gate-B call). Also read the checker's scan-domain paragraph whole, since its count wraps across lines.

- [ ] **Step 7: Mutation record for 4f** (and the other checks, since the shared fixture changed). Run the header's procedure from the worktree root once per check, `chk` in `4a 4b 4c 4d 4e 4f`. For each, compare the flipped set with that check's reject cases and confirm no accept case moved. Record in the test file's header block, after the `4e -> 7` entry:

````text
#   4f -> <n>  every `4f:` reject fixture (<n-1>) and `4f change-record parser failure
#              fires`; no accept case moved (measured 2026-10-05). 4a-4e re-measured the
#              same day after the shared intake fixture gained the amendment section:
#              <a>, <b>, <c>, <d>, <e>.
````

  with the measured numbers. A changed number for 4a–4e is explained in the record, not hidden.

### Task 4: Named verification — the replay

**Order:** run this task after Task 5 Steps 1–4, so the WIP snapshot exists and the replay
exercises the candidate's own intake text; Task 5 Step 5 (Gate B) follows it. After any amend
that changes `plugins/dev-workflow/skills/intake/SKILL.md`, re-run this task on the new head.

**Inputs, preserved 2026-10-05** in
`/Users/daniel/DEVELOPMENT/APPS/dev-workflow-kit/.context/g1a-replay/inputs/` (git may prune the
unreachable source commits; the replay reads only these copies): per part N, `partN-baseline.md`,
`partN-after-full.md`, `partN-message-full.txt`, `partN-changed-paths.txt` (unabridged,
`--name-only`), `partN-decision-assessment.md` (the assessment each decision was taken on:
`20261002-132344-telemetry-t1-scope-triage-assessment.md`,
`20261003-104113-loop-usefulness-warning-assessment.md`) and `partN-meta.txt` (story path, full
baseline and after commit IDs, the baseline's sha256).

- [ ] **Step 1: Assemble the package, failing fast.**

````sh
set -eu
I=/Users/daniel/DEVELOPMENT/APPS/dev-workflow-kit/.context/g1a-replay/inputs
W=/Users/daniel/DEVELOPMENT/APPS/dwk-controlled-change
R=$(mktemp -d); [ -n "$R" ] && [ -d "$R" ] || { echo "no scratch dir" >&2; exit 1; }
H=$(git -C "$W" rev-parse HEAD)
git -C "$W" log -1 --format=%s "$H" | grep -q '^WIP' || { echo "HEAD is not the WIP snapshot" >&2; exit 1; }
mkdir -p "$R/in/part1" "$R/in/part2" "$R/rules" "$R/out" "$R/expected"
for n in 1 2; do
  for f in baseline.md after-full.md message-full.txt changed-paths.txt decision-assessment.md meta.txt; do
    [ -s "$I/part$n-$f" ] || { echo "missing input part$n-$f" >&2; exit 1; }
  done
  [ "$(shasum -a 256 "$I/part$n-baseline.md" | cut -d' ' -f1)" = "$(sed -n 's/^baseline sha256: //p' "$I/part$n-meta.txt")" ] \
    || { echo "part$n baseline does not match its recorded hash" >&2; exit 1; }
  cp "$I/part$n-baseline.md" "$R/in/part$n/baseline.md"
  cp "$I/part$n-meta.txt" "$R/in/part$n/meta.txt"
  cp "$I/part$n-changed-paths.txt" "$R/in/part$n/changed-paths.txt"
  cp "$I/part$n-decision-assessment.md" "$R/in/part$n/decision-assessment.md"
  cp "$I/part$n-after-full.md" "$R/expected/part$n-after-full.md"
  cp "$I/part$n-message-full.txt" "$R/expected/part$n-message-full.txt"
done
for m in plugins/dev-workflow/skills/intake/SKILL.md:intake-SKILL.md .claude/review-gates.md:review-gates.md AGENTS.md:AGENTS.md; do
  f=${m%%:*}; t=${m#*:}
  git -C "$W" show "$H:$f" > "$R/rules/$t" && [ -s "$R/rules/$t" ] \
    || { echo "could not extract $f at $H" >&2; exit 1; }
done
for t in intake-SKILL.md review-gates.md AGENTS.md; do [ -s "$R/rules/$t" ] || { echo "missing rules/$t" >&2; exit 1; }; done
echo "R=$R H=$H"
````

- [ ] **Step 2: Withhold the answers.** For each part, write `in/partN/after.md` = `expected/partN-after-full.md` with the change-record blocks removed, and keep the removed blocks verbatim in `expected/partN-record.md`. The blocks: part 1 — the paragraphs starting `**Criteria amended 2026-10-02` and `**Scope narrowed 2026-10-02` through the end of the fate table; part 2 — the single line `**Narrowed 2026-10-03 (Daniel): this part delivers a warning light, not a usefulness assessment.**` (the outcome prose that follows it on the next lines stays), and the paragraph starting `**Scope narrowed 2026-10-03` through the end of its fate table. Then verify that `diff` of `after.md` against `after-full.md` shows only those deleted lines. Write `in/partN/decision.txt` = `expected/partN-message-full.txt` with every line starting `|` removed, plus one line: `Decision by Daniel, <date>, on the assessment in decision-assessment.md.`

Run: `grep -rnE '^\| *(Earlier criterion|Criterion|Criteria|Desired outcome|Outcome|Whether a loop)|\*\*(Narrowed|Replaced|Kept|Deferred)' "$R/in" "$R/rules"; echo "leak=$?"` (the baselines legitimately contain the old criteria; what must not appear is a historical fate row or fate verdict)
Expected: `leak=1`. This is a bounded scan for fate rows and fate verdicts, not the leakage check by itself. Then **read** every file under `$R/in` against the withheld blocks (both of part 1's — the pass-1 amendment and the pass-4 narrowing — and both of part 2's). The decision evidence necessarily says what changes (for example part 1's commit message says the credit balance was dropped): that is the decision the route starts from, not the record it must produce, and it stays. Record in `compare.md`, and in the evidence entry, every place where the input already states a fate the agent must produce — whether or not the grep found it — so the replay's independence is not overstated.

- [ ] **Step 3: Run a fresh agent** (Agent tool, general-purpose, sonnet), prompt (with `$R` expanded):

````text
You are a coding session following the `intake` skill's route "Amending an approved story or spec" (its text: $R/rules/intake-SKILL.md). Read only files under $R/in and $R/rules. For each of part1 and part2: in/partN/meta.txt names the story path and the approved baseline (commit and sha256); in/partN/baseline.md is that approved text; in/partN/after.md is the text after the change, without its change record; in/partN/decision.txt and in/partN/decision-assessment.md are the human decision and what it was taken on; in/partN/changed-paths.txt lists every path the change touched. Run steps 1, 2, 4, 5, 6 and 7 of the route and write the change record it prescribes to $R/out/partN-record.md. Do not run step 3 or step 8: there is no repository. For step 9, list what stays blocked at the end of the record. Apply the rules in $R/rules even where the historical change predates them. Write nothing else.
````

- [ ] **Step 4: Compare.** For each part, map every row of `expected/partN-record.md` to the agent's rows: historical `Narrowed` → `kept` plus a `moved` or `dropped` remainder; `Replaced` → `withdrawn` plus `added`; `Deferred` → `moved`; "Kept, reworded" → `kept` with `reworded`; `Kept` → `kept`. Part 1's expected answer is the union of its pass-1 amendment (credit balance dropped; criterion 1 re-keyed on the transcript) and its pass-4 table. Dependent artifacts must include, for part 1, `docs/superpowers/specs/2026-10-02-run-analytics-design.md`; for part 2, `docs/superpowers/stories/2026-10-02-telemetry-and-review-loop-usefulness-story.md` and `todos.md`. Write `$R/compare.md`: per historical row, reproduced, or differs with its reason (procedure, part-1 boundary, or retrospective rule). Then copy the whole of `$R` to `/Users/daniel/DEVELOPMENT/APPS/dev-workflow-kit/.context/g1a-replay/run-<H>/`.

  Pass condition (story `AC-11`, changed 2026-10-05 by Daniel after Gate B pass 2): every baseline condition receives a fate or is listed as Unaccounted, every listed dependent artifact is named, and every row that differs from the historical table is reported with its cause (a rule the history predates, a change the historical table did not account for, or decision evidence missing from the input), none of them a procedure failure.

### Task 5: Evidence, Gate B, close

- [ ] **Step 1: Quality row** verbatim from `AGENTS.md § Commands`, in the background: `sh -c '<row>' > <scratch>/q.log 2>&1; echo "quality=$?"`. Expected: `quality=0`.
- [ ] **Step 2: Counterfactual.** In a temporary copy of the candidate tree, restore `plugins/dev-workflow/skills/intake/SKILL.md` from `origin/main`; run `sh scripts/check-invariants.sh`. Expected: exit 1 with `change-record template` in the output.
- [ ] **Step 3: Stage and snapshot.** Stage the changed paths (two skills, manifest, changelog, `AGENTS.md`, `README.md`, `todos.md`, checker, suite, this plan's checkboxes if ticked). Run `git diff --cached --name-only`. Then, as its own one-line tool call: `git commit -m 'WIP: controlled change candidate'`.
- [ ] **Step 4: Version check:** `sh scripts/check-version-bump.sh main` → ok.
- [ ] **Step 4b: Run Task 4** on this WIP head.
- [ ] **Step 5: Gate B** per `.claude/review-gates.md`: nonce; floor 3 (story level 1); `mcp__codex__health` first; one `reviewType: full` call per pass, each branch to its own slot. Each call carries the story path, the evidence entry, the spec-delta report and the standing lens (named: the check count in AGENTS.md invariant 11, the checker header's lists, the README intake row, the version string). After fixes: amend the WIP, re-run Steps 1–2, the affected mutation records and, if intake changed, Task 4; re-review.

Evidence entry:

```
Evidence — docs/superpowers/stories/2026-10-05-controlled-change-to-an-approved-story-story.md
Battery: AGENTS.md quality row, exit 0 at <headSha>.
Check (counterfactual): with intake's skill text from origin/main, check-invariants exits 1 ("change-record
template"); 4f's mutation flips exactly its <n> reject cases, no accept case.
Named verification (replay, AC-11): <reproduced rows>/<historical rows> per part, dependent artifacts named
<yes/no>; differences: <list or none>; input overlap: <where the input already states a fate>
(/Users/daniel/DEVELOPMENT/APPS/dev-workflow-kit/.context/g1a-replay/run-<head>/compare.md).
```

- [ ] **Step 6: Close, PR, merge** when the closure ordering allows: amend with the real message, evidence, provenance line and curve; push; open the PR listing every cycle (spec `lbveuxkbje` in `832510b`, plan cycle, Gate B cycle); `/dev-workflow:process-pr-review`; squash-merge when green with every record in the body; then run-analytics, archive the untracked `.context/codex-reviews/` files, remove the worktree.

## Self-review (2026-10-05)

- **Spec coverage:** §0 → Global Constraints; §1 entry → Task 2 Step 1; separate route and scoping table → Task 2 Steps 2 and 4; steps 1–9 → Task 2 Step 2; §2 shape, closed sets, reviews field → Task 2 Step 2 and Task 1's lines; §3 → Task 2 Step 5; §4 check → Task 1, Task 3 Step 7, Task 5 Step 2; replay → Task 4; §5 surfaces → Tasks 2–3.
- **Story criteria:** AC-1, AC-2, AC-3 → step 1/6/4–5 and the closed sets; AC-4 → scope and open-questions fields; AC-5 → dependent statuses and step 8; AC-6 → step 7 and Task 2 Step 3; AC-7 → steps 1 and 9; AC-8 → Task 2 Step 5 and the "Who runs it" paragraph; AC-9 (withdrawn 2026-10-05) and AC-11 → Task 4; AC-10 → Global Constraints.
- **Type consistency:** the 12 lines appear identically in Task 1 Steps 1 and 4 and Task 2 Step 2 (`CR_LINES`, `CR_REQ`, the section text); `intake'"'"'s` in the shell strings is the quoting of `intake's`.
