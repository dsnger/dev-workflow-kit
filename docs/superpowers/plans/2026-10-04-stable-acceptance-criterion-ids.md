# Stable Acceptance-Criterion IDs Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Story:** `docs/superpowers/stories/2026-10-04-stable-acceptance-criterion-ids-story.md` — read the profile from its header at every gate call.

**Goal:** Number every acceptance criterion in the `dev-workflow:intake` story template as `AC-<n>`, under an italic rule line that travels with each story, state the identifier rules in the skill, and pin the template's spelling with a narrow check 4d in `scripts/check-invariants.sh`. Ship it as dev-workflow 0.15.0.

**Architecture:** There are two edit scripts, both prototyped and run against a copy on 2026-10-04.
- The first adds check 4d with its fixtures and regression cases. Run against the real repository, it fails on the unnumbered template; this is the red step and the counterfactual.
- The second changes the skill (template, rules, worked example, re-validation, common mistakes), the manifest version, the CHANGELOG, AGENTS.md invariant 11 and two docs. After it, the checker is green.

**Tech Stack:** Markdown prompts, POSIX `sh` (the checker and its suite, `awk`), Python 3 for the one-off edit scripts, `shellcheck` 0.11.0.

**Spec:** `docs/superpowers/specs/2026-10-04-stable-acceptance-criterion-ids-design.md` (Gate-A spec cycle `74w54vqst8`, closed in `4b6be6b`).

**Executed 2026-10-04 (PR #40).** Gate B and PR review added suite cases after this plan was approved, so the committed `scripts/check-invariants.test.sh` differs from the copy embedded below. The counts below (24 cases, `172 assertions`, five SC2016 disables, 20 mutation flips) describe the suite as the plan approved it; after Gate B (4972cb1) and PR #40's review fix (2164624) the committed suite has 26 cases, 174 assertions and 22 flips, and this change adds six SC2016 disables (five in the suite, one in the checker; the suite also keeps its two older ones), and check 4d also requires the rule line above the criteria.

## Global Constraints

- Worktree `/Users/daniel/DEVELOPMENT/APPS/dwk-ac-ids`, branch `ac-ids`. Paths are relative to it.
- A shipped prompt changes, so the manifest goes to **0.15.0** (invariant 12), and the skill change passes all 12 items of `docs/prompt-standards.md` (invariant 11). See the self-check below.
- No gate rule, pass rule, record format or evidence-entry format changes (story AC-6).
- One identifier sequence, `AC-<n>`; there is no `SEC-<n>` (story, decided 2026-10-04).
- Unexpected repository state is a stop and a question to Daniel; no automated stash, rebase or reset.

## Rulings — spec cycle Minors and implementation choices

The spec is closed and is not edited. Where the implementation settles something the spec left open, the ruling is stated here, and the Gate-B call names it.

1. **Check 4d is one `awk` program**, marked `# ac-template-scan` so the existing `inject_case` seam can simulate its failure, as for 4a–4c. It prints `ok` or the first problem found.
   - The first fence after `## Story template` must be the template's ```` ```markdown ````, before the section's next `## ` heading. Any other first fence is a named failure; the search never skips ahead to a later fence.
   - Nothing after the template's closing fence is read, so a later example — even one containing `## Story template` — neither counts nor breaks the check (plan pass 1).
2. **The rule line is compared byte for byte.** The checker and the test fixture each hold their own copy. Changing the line therefore means changing three places — the skill, the checker and the fixture — and the checker fails loudly until they agree.
3. **Extra cases** beyond spec §3:
   - from the spec cycle's Minors: an empty criteria region, and a leading-zero identifier (`AC-01`);
   - from plan pass 1: an altered rule line, a duplicated next-section boundary, a non-markdown first fence followed by a template-shaped block, and (accepted) a later `## Story template` heading.
4. **Shellcheck SC2016** is disabled on five lines whose backticks are literal Markdown, each with its reason. No other code is excluded.
5. **Mutation evidence** for 4d is recorded in the suite's existing block: deleting the 4d block flips 20 cases (19 reject fixtures and the parser-failure case), and no accept case moves. This was measured on the prototype on 2026-10-04 and is not re-run per review (stated as such in the evidence entry).
6. **The rule prose carries its reasons** (prompt-standards item 6), including for the citation form and older stories. The italic line repeats the rules in short on purpose, because it travels into every story where the skill does not run (spec §2).
7. **Review records stay untracked.** `.context/codex-reviews/` is deliberately not ignored (see `.gitignore`), but its files are not committed here. They are archived to the main checkout's `.context/` when the worktree is removed, as in earlier PRs. The evidence run's clean check therefore uses `git status --porcelain --untracked-files=no`.

## Prompt-standards self-check (invariant 11), for the skill change

| Item | How the change meets it |
|---|---|
| 1 Target model | unchanged `Target model:` line; check 4a still passes |
| 2 Success criteria | the re-validation step now includes the `AC-1 … AC-k` order and the rule line |
| 3 Stop conditions | a collision between concurrent amendments stops for a human |
| 4 Output format with example | the template itself, and the worked example table |
| 5 Structured sections | the rules are a numbered block beside the template |
| 6 Rules carry their why | each rule states its reason (ruling 6) |
| 7 No contradictions | no gate or record rule changes; CLAUDE.md §5 untouched |
| 8 Token-lean | the italic line repeats the rules in short, on purpose (spec §2); step 9 names only what it checks |
| 9 Positive instructions | the rules say what to do ("takes the next unused number"); "never renumber" is the one hard prohibition, and it carries its why |
| 10 Diagnostic states name causes | not applicable: the skill reports no failure states here |
| 11 Enforcement claims name their mechanism | the CHANGELOG and AGENTS.md name check 4d and what it does not catch |
| 12 Calibrated emphasis | bold is used for terms only; no capitals |

## Review Focus

1. **The worked example and the rule prose are not machine-checked** (spec §3). The Gate-B reviewer reads them against the spec.
2. **This plan's own story has no italic rule line.** It was written by hand before the rule shipped, so rule 5 (older stories) governs it.
3. **The version bump** is checked by CI on the pull request (`scripts/check-version-bump.sh`), and locally after the WIP commit.

---

## File map

| Path | Change | Task |
|---|---|---|
| `scripts/check-invariants.sh` | check 4d; the mutation procedure names 4d | 1 |
| `scripts/check-invariants.test.sh` | fixture template, 24 cases (23 template cases and the parser-failure case), mutation evidence | 1 |
| `plugins/dev-workflow/skills/intake/SKILL.md` | template, rules, worked example, step 9, common mistakes | 2 |
| `plugins/dev-workflow/.claude-plugin/plugin.json` | `0.15.0` | 2 |
| `plugins/dev-workflow/CHANGELOG.md` | `0.15.0` entry | 2 |
| `AGENTS.md` | invariant 11: four narrow checks | 2 |
| `README.md`, `.github/workflows/ci.yml` | "four prompt-conformance checks" | 2 |
| `docs/getting-started.md`, `docs/coding-workflow.md` | criteria carry `AC-<n>` | 2 |

---

### Task 1: Check 4d first (red)

- [ ] **Step 1: Apply the check edit script**

Save this as a temporary file outside the repository and run it from the repository root with `python3`. It writes nothing unless every anchor matches exactly once.

```python
# Adds check 4d to scripts/check-invariants.sh and its fixtures and cases to
# scripts/check-invariants.test.sh. Every replacement must match exactly once, or the script
# stops before writing anything.
import sys

RULE = ('_IDs are permanent once the story is committed: never renumber or reuse one; a new criterion '
        'takes the next number unused here and on the branch it merges into, and a collision stops for '
        'a human; a removed one stays, struck through and dated; a narrowed one keeps its ID with a '
        'dated note; cite as `<story path> AC-<n>`; full rules: dev-workflow:intake, '
        '"Acceptance-criterion IDs"._')

CHECK = r'''
# --- BEGIN check 4d ---
# The `intake` story template numbers its criteria `AC-<n>` under one italic rule line, so
# every story it writes can be cited by identifier (P5 light). The check reads ONLY the
# template: the first ```markdown fence after the `## Story template` heading, and inside it
# the region from `## 3. Acceptance criteria` to `## 4. Affected AGENTS.md invariants`. The
# worked example and the rule prose live outside the fence and can neither satisfy nor
# break it. A moved or renamed boundary fails rather than widening the region.
#
# Every region line must be blank, exactly the rule line, or a criterion row
# `- [ ] **AC-<n>** <text>`; the rule line occurs once; there is at least one row; and the
# numbers read 1, 2, 3, ... in order. What it does NOT catch: whether the rule prose or the
# worked example says the right thing, whether any written story follows the rules, or
# whether a later amendment renumbered anything. It pins the template's spelling only.
# The backticks are literal Markdown in the rule line, not command substitution.
# shellcheck disable=SC2016
AC_RULE='__RULE__'
AC_FILE=plugins/dev-workflow/skills/intake/SKILL.md

# Prints `ok`, or one line naming the first problem found. Returns 2 if awk itself failed.
ac_template_scan() { # $1 = file
  awk -v rule="$AC_RULE" '                         # ac-template-scan
    function bad(msg) { if (problem == "") problem = msg }
    done { next }                                  # nothing after the template counts
    $0 == "## Story template" { heads += 1; want = 1; next }
    want && /^```/ { want = 0; if ($0 == "```markdown") { infence = 1; fences += 1 } else { wrongfence = $0; done = 1 }; next }
    want && /^## / { want = 0; done = 1; next }    # the section ended without a fence
    infence && $0 == "```" { infence = 0; closed = 1; done = 1; next }
    !infence { next }
    $0 == "## 3. Acceptance criteria" { h3 += 1; if (h4 == 0) region = 1; else bad("the criteria heading comes after the next section"); next }
    $0 == "## 4. Affected AGENTS.md invariants" { h4 += 1; if (h3 == 0) bad("the next section comes before the criteria heading"); region = 0; next }
    region {
      if ($0 ~ /^[ \t]*$/) next
      if ($0 == rule) { rules += 1; next }
      if ($0 ~ /^- \[ \] \*\*AC-[1-9][0-9]*\*\* ./) {
        n += 1
        num = $0; sub(/^- \[ \] \*\*AC-/, "", num); sub(/\*\*.*$/, "", num)
        if (num + 0 != n) bad("criterion " n " is numbered AC-" num ": " $0)
        next
      }
      bad("not a criterion row, blank or the rule line: " $0)
    }
    END {
      if (heads == 0) print "no `## Story template` heading"
      else if (heads > 1) print heads " `## Story template` headings"
      else if (wrongfence != "") print "the first fence after `## Story template` is not ```markdown: " wrongfence
      else if (fences == 0) print "no ```markdown fence inside the `## Story template` section"
      else if (!closed) print "the template fence is never closed"
      else if (h3 != 1) print h3 " `## 3. Acceptance criteria` headings in the template, need exactly 1"
      else if (h4 != 1) print h4 " `## 4. Affected AGENTS.md invariants` headings in the template, need exactly 1"
      else if (problem != "") print problem
      else if (rules != 1) print rules " italic ID rule lines in the criteria region, need exactly 1"
      else if (n == 0) print "no criterion rows in the template"
      else print "ok"
    }
  ' "$1" || return 2
}

if [ ! -f "$AC_FILE" ]; then
  fail "Prompt standards: $AC_FILE is missing, so the AC-<n> story template cannot be checked." \
       "the intake skill is required"
elif [ ! -r "$AC_FILE" ]; then
  fail "Prompt standards: $AC_FILE is unreadable, so the AC-<n> story template cannot be checked." \
       "check permissions"
else
  ac_out=$(ac_template_scan "$AC_FILE"); ac_st=$?
  if [ "$ac_st" -ne 0 ]; then
    fail "Prompt standards: the AC-<n> template parser failed; results are not trustworthy." \
         "awk exited $ac_st on $AC_FILE"
  elif [ "$ac_out" != ok ]; then
    fail "Prompt standards: the intake story template's AC-<n> criteria are malformed: $ac_out" \
         "every criterion row is '- [ ] **AC-<n>** <text>', numbered 1, 2, 3, ... under the one italic ID rule line"
  fi
fi
# --- END check 4d ---
'''.replace('__RULE__', RULE)

checker = "scripts/check-invariants.sh"
s = open(checker).read()
a = '# --- END check 4c ---\n'
if s.count(a) != 1:
    sys.exit("STOP: checker anchor")
s = s.replace(a, a + CHECK)
for old, new in (
    ("# MUTATION RE-RUN PROCEDURE (manual; nothing automates it). The three prompt-conformance\n"
     "# checks below are bracketed by `# --- BEGIN check 4a ---` / `# --- END check 4a ---`\n"
     "# markers -- and likewise for 4b and 4c -- so a scratch copy can be neutered cleanly.",
     "# MUTATION RE-RUN PROCEDURE (manual; nothing automates it). The four prompt-conformance\n"
     "# checks below are bracketed by `# --- BEGIN check 4a ---` / `# --- END check 4a ---`\n"
     "# markers -- and likewise for 4b, 4c and 4d -- so a scratch copy can be neutered cleanly."),
    ("#   chk=4a   # then 4b, then 4c", "#   chk=4a   # then 4b, 4c, then 4d"),
):
    if s.count(old) != 1:
        sys.exit("STOP: checker text %r" % old[:50])
    s = s.replace(old, new)
new_checker = s

test = "scripts/check-invariants.test.sh"
t = open(test).read()
# the shared initializer writes a valid intake template, so every other case stays isolated
a = '''  printf '# Fixture\\n\\n%s\\n' "$SEV_LINE" > "$1/CLAUDE.md"
}'''
b = '''  printf '# Fixture\\n\\n%s\\n' "$SEV_LINE" > "$1/CLAUDE.md"
  # 4d: a minimal valid intake story template, for the same isolation reason.
  mkdir -p "$1/plugins/dev-workflow/skills/intake"
  ac_skill "$(ac_rows 3)" > "$1/plugins/dev-workflow/skills/intake/SKILL.md"
}
# The backticks are literal Markdown in the rule line, not command substitution.
# shellcheck disable=SC2016
AC_RULE_LINE='__RULE__'
# ac_rows N: criterion rows AC-1..AC-N
ac_rows() { i=1; while [ "$i" -le "$1" ]; do printf -- '- [ ] **AC-%s** criterion %s\\n' "$i" "$i"; i=$((i + 1)); done; }
# ac_skill REGION [AFTER]: a skill file whose template's criteria region is REGION (the rule
# line is added unless REGION already starts with @NORULE@); AFTER goes outside the fence.
ac_skill() {
  region=$1
  case "$region" in @NORULE@*) region=${region#@NORULE@}; rule='' ;; *) rule="$AC_RULE_LINE
" ;; esac
  # shellcheck disable=SC2016  # literal Markdown fence, not command substitution
  printf '# intake\\n\\n## Story template\\n\\n```markdown\\n# T\\n\\n## 3. Acceptance criteria\\n%s%s\\n\\n## 4. Affected AGENTS.md invariants\\n- none\\n```\\n\\n%s\\n' \\
    "$rule" "$region" "${2:-}"
}'''.replace('__RULE__', RULE)
if t.count(a) != 1:
    sys.exit("STOP: test initializer anchor")
t = t.replace(a, b)

CASES = r'''
# --- Prompt conformance: check 4d, the AC-<n> story template ---------------------------
#
# Each case replaces the intake skill file and asserts the shared diagnostic. The accepting
# near-misses are the point: rows outside the fence or under `## 4.` must not count.
AC='AC-<n>'
ac_case() { # $1 = name, $2 = 1|0 expect reject, $3 = skill body, @GONE@ or @LOCK@
  rm -rf "$work/r"; mkdir -p "$work/r/scripts" "$work/r/.github/workflows" \
    "$work/r/plugins/p/.claude-plugin"
  cp "$CHECKER" "$work/r/scripts/"
  init_prompt_fixtures "$work/r"
  printf '%s\n' '{"name": "p", "version": "1.0.0"}' > "$work/r/plugins/p/.claude-plugin/plugin.json"
  printf '%s\n' "$PINNED" > "$work/r/.github/workflows/ci.yml"
  sk="$work/r/plugins/dev-workflow/skills/intake/SKILL.md"
  case "$3" in @GONE@) rm -f "$sk" ;; @LOCK@) chmod 000 "$sk" ;; *) printf '%s\n' "$3" > "$sk" ;; esac
  out=$( cd "$work/r" && sh scripts/check-invariants.sh 2>&1 ); st=$?
  chmod 644 "$sk" 2>/dev/null
  if [ "$2" -eq 1 ]; then
    if [ "$st" -eq 0 ]; then fail "$1 (exited 0)"
    elif ! printf '%s' "$out" | grep -qF "$AC"; then
      fail "$1 (wrong diagnostic: $(printf '%s' "$out" | tr '\n' ' '))"
    else pass "$1"; fi
  else
    if [ "$st" -eq 0 ]; then pass "$1"
    else fail "$1 (exited $st: $(printf '%s' "$out" | tr '\n' ' '))"; fi
  fi
}
ac_case "4d: valid template accepted"                          0 "$(ac_skill "$(ac_rows 3)")"
ac_case "4d: worked example outside the fence with other numbers accepted" 0 \
  "$(ac_skill "$(ac_rows 2)" '- [ ] **AC-4** an inserted criterion
- [ ] **AC-2** ~~withdrawn~~')"
ac_case "4d: rows under ## 4. inside the fence accepted"       0 \
  "$(ac_skill "$(ac_rows 3)" | sed 's/^- none$/- [ ] not a criterion/')"
ac_case "4d: missing skill rejected"                           1 "@GONE@"
if [ "$(id -u)" -ne 0 ]; then
  ac_case "4d: unreadable skill rejected"                      1 "@LOCK@"
fi
ac_case "4d: no Story template heading rejected"               1 "$(ac_skill "$(ac_rows 3)" | sed 's/^## Story template$/## Template/')"
# shellcheck disable=SC2016  # literal Markdown fence, not command substitution
ac_case "4d: no fence rejected"                                1 "$(ac_skill "$(ac_rows 3)" | sed 's/^```markdown$/```text/')"
ac_case "4d: unclosed fence rejected"                          1 "$(ac_skill "$(ac_rows 3)" | sed '/^```$/d')"
ac_case "4d: missing criteria heading rejected"                1 "$(ac_skill "$(ac_rows 3)" | sed 's/^## 3\. Acceptance criteria$/## 3. Criteria/')"
ac_case "4d: duplicated criteria heading rejected"             1 "$(ac_skill "$(ac_rows 3)" | sed 's/^# T$/## 3. Acceptance criteria/')"
ac_case "4d: missing next section rejected"                    1 "$(ac_skill "$(ac_rows 3)" | sed 's/^## 4\. Affected AGENTS\.md invariants$/## 4. Something else/')"
ac_case "4d: boundaries out of order rejected"                 1 "$(ac_skill "$(ac_rows 3)" | sed 's/^# T$/## 4. Affected AGENTS.md invariants/')"
ac_case "4d: a row without an identifier rejected"             1 "$(ac_skill "$(ac_rows 2)
- [ ] <… at least three.>")"
ac_case "4d: a bare list row rejected"                         1 "$(ac_skill "$(ac_rows 3)
- extra")"
ac_case "4d: out-of-order numbers rejected"                    1 "$(ac_skill '- [ ] **AC-1** one
- [ ] **AC-3** three
- [ ] **AC-2** two')"
ac_case "4d: a leading-zero identifier rejected"               1 "$(ac_skill '- [ ] **AC-01** one')"
ac_case "4d: missing rule line rejected"                       1 "$(ac_skill "@NORULE@$(ac_rows 3)")"
ac_case "4d: duplicated rule line rejected"                    1 "$(ac_skill "$(ac_rows 3)
$AC_RULE_LINE")"
ac_case "4d: an empty criteria region rejected"                1 "$(ac_skill '')"
ac_case "4d: an altered rule line rejected"                    1 "$(ac_skill "$(ac_rows 3)" | sed 's/never renumber or reuse one/renumber when needed/')"
ac_case "4d: duplicated next-section boundary rejected"        1 "$(ac_skill "$(ac_rows 3)" | sed 's/^- none$/## 4. Affected AGENTS.md invariants/')"
# shellcheck disable=SC2016  # literal Markdown fence, not command substitution
ac_case "4d: a non-markdown first fence is not skipped for a later one" 1 \
  "$(ac_skill "$(ac_rows 3)" | sed 's/^```markdown$/```text/')
\`\`\`markdown
## 3. Acceptance criteria
$AC_RULE_LINE
- [ ] **AC-1** later
## 4. Affected AGENTS.md invariants
\`\`\`"
ac_case "4d: a Story template heading after the template is ignored" 0 \
  "$(ac_skill "$(ac_rows 3)")

## Story template
an example section after the real one"

# The parser branch, through the same PATH seam the 4a-4c stage failures use. The 4d awk
# is identified by its `ac-template-scan` marker comment.
inject_case "4d AC-<n> template parser failure fires" awk '*ac-template-scan*' \
  'AC-<n> template parser failed'
'''
a = "\nprintf '\\n---\\n'\n"
if t.count(a) != 1:
    sys.exit("STOP: test end anchor")
t = t.replace(a, CASES + a)
old_ev = ("#              the second half of the check and the one a non-empty flip set alone does\n"
          "#              not establish.\n")
if t.count(old_ev) != 1:
    sys.exit("STOP: mutation evidence anchor")
t = t.replace(old_ev, old_ev +
    "#   4d -> 20   every `4d:` reject fixture (19) and `4d AC-<n> template parser failure\n"
    "#              fires`; no accept case moved (measured 2026-10-04 on the prototype).\n")
open(checker, "w").write(new_checker)
open(test, "w").write(t)
print("edited:", checker, test)
```

Expected: `edited: scripts/check-invariants.sh scripts/check-invariants.test.sh`.

- [ ] **Step 2: The suite is green, the real template is red**

Run: `sh scripts/check-invariants.test.sh > /tmp/ci-test.log 2>&1; echo "test=$?"; tail -1 /tmp/ci-test.log; sh scripts/check-invariants.sh > /tmp/ci-red.log 2>&1; echo "inv=$?"; grep -c 'AC-<n> criteria are malformed' /tmp/ci-red.log`
Expected: `test=0` with `all passed (172 assertions)`; `inv=1` and `1`. The unnumbered template fails 4d; this is the counterfactual.

No commit.

---

### Task 2: The skill, version, changelog and docs (green)

- [ ] **Step 1: Apply the edit script**

Save this as a temporary file outside the repository and run it from the repository root with `python3`.

```python
# Applies the P5-light edits to the intake skill, the manifest, the CHANGELOG and the docs.
# Every replacement must match exactly once, or the script stops before writing anything.
import sys

RULE = ('_IDs are permanent once the story is committed: never renumber or reuse one; a new criterion '
        'takes the next number unused here and on the branch it merges into, and a collision stops for '
        'a human; a removed one stays, struck through and dated; a narrowed one keeps its ID with a '
        'dated note; cite as `<story path> AC-<n>`; full rules: dev-workflow:intake, '
        '"Acceptance-criterion IDs"._')

edits = {
 "plugins/dev-workflow/skills/intake/SKILL.md": [
  ("""## 3. Acceptance criteria
- [ ] <Observable outcome or constraint, checkable true/false by a reviewer.>
- [ ] <…>
- [ ] <… at least three.>
""",
   """## 3. Acceptance criteria
""" + RULE + """
- [ ] **AC-1** <Observable outcome or constraint, checkable true/false by a reviewer.>
- [ ] **AC-2** <…>
- [ ] **AC-3** <… at least three.>
"""),
  ("""**Acceptance criteria** describe observable outcomes or constraints, never
implementation steps (WHAT is true when done, not how it's built).
""",
   """**Acceptance criteria** describe observable outcomes or constraints, never
implementation steps (WHAT is true when done, not how it's built).

**Acceptance-criterion IDs.** Every criterion carries an identifier, `AC-<n>`, so that a
plan, a spec, a gate call or a commit can cite it and still mean the same criterion after
the list changes. The italic line under §3 travels with every story and carries these
rules in short, because later amendments happen where this skill does not run.

1. **Fixed at commit, free before.** While the draft is shown and edited (steps 8–9),
   renumber freely, so the draft always reads `AC-1 … AC-k` in order. Identifiers become
   permanent when the approved story is committed (step 10).
2. **After commit: never renumbered, never reused** — the one exception is a renumbering
   a human decides under rule 3. In any later amendment:
   - a **new** criterion takes the next unused number, wherever it is placed in the list;
   - a **removed** criterion keeps its line, struck through, with a dated reason:
     `- [ ] **AC-3** ~~<old text>~~ — withdrawn 2026-10-04: <reason>`;
   - a **narrowed or reworded** criterion keeps its identifier, with a dated note in the
     same line: `(narrowed 2026-10-04: <reason>)`.

   Why: a citation outlives the list it points into, and a renumbered or reused
   identifier silently redirects every earlier citation to a different criterion.
3. **Concurrent amendments.** Before committing an amendment, take "next unused" over the
   story on its own branch **and** on the branch it will merge into. If two amendments
   still claim the same number when they meet, stop and ask a human which one gives way.
   That amendment's new criteria are then renumbered together with every citation already
   made to them. Nothing resolves this automatically, because an identifier committed on a
   branch may already be cited.
4. **Citation form.** For a story with identifiers: `<story path> AC-<n>`, or `AC-<n>`
   inside the story itself. Plans, specs, gate calls, evidence entries and fate tables use
   it instead of a position ("criterion 4") or a paraphrase. For a story without
   identifiers: the story path and the criterion's text, quoted — never an identifier
   guessed from its position, because a position changes whenever the list does. This is a
   citation convention; no record format changes.
5. **Older stories.** A story that already carries `AC-<n>` identifiers keeps them, and
   rules 2–4 apply from now on. A story without identifiers is not rewritten: at its first
   later amendment it adopts them — its existing criteria are numbered in their current
   order, the italic rule line is added, and a dated line under §3 records the adoption.
   Rewriting it earlier would change what its existing citations point at, with nobody
   amending it to notice.

**Worked example.** A committed story has AC-1, AC-2 and AC-3. Three amendments follow:

| Amendment | §3 afterwards (identifiers only) |
|---|---|
| a criterion inserted between AC-1 and AC-2 | AC-1, **AC-4**, AC-2, AC-3 — the new one takes the next unused number, not its position |
| AC-2 withdrawn | AC-1, AC-4, ~~AC-2~~ withdrawn (dated), AC-3 — the line stays, the number is never reused |
| AC-3 narrowed | AC-1, AC-4, ~~AC-2~~, AC-3 (narrowed, dated) — same identifier, new text |

Every citation made before these amendments still points at the same criterion.
"""),
  ("""   **re-validate the edited draft against every constraint** (six sections, the
   profile header line, no-HOW except §4, grounding floor, ≥3 checkable criteria), and""",
   """   **re-validate the edited draft against every constraint** (six sections, the
   profile header line, no-HOW except §4, grounding floor, ≥3 checkable criteria, the
   criteria reading `AC-1 … AC-k` in order under the italic ID rule line), and"""),
  ("""- Padding to reach three acceptance criteria when the idea can't ground them.
""",
   """- Padding to reach three acceptance criteria when the idea can't ground them.
- Renumbering the criteria of a committed story, or reusing a withdrawn identifier.
"""),
 ],
 "plugins/dev-workflow/.claude-plugin/plugin.json": [
  ('"version": "0.14.0",', '"version": "0.15.0",'),
 ],
 "plugins/dev-workflow/CHANGELOG.md": [
  ("""## 0.14.0
""",
   """## 0.15.0

- **Stable acceptance-criterion IDs in the `intake` story template.** Every criterion is
  written `- [ ] **AC-<n>** …`, under an italic rule line that travels with each story:
  identifiers are fixed when the story is committed, never renumbered or reused, a new
  criterion takes the next unused number, and a collision between concurrent amendments
  stops for a human. The skill states the full rules, the citation form
  (`<story path> AC-<n>`), how an older story adopts identifiers, and a worked example. No
  gate rule, record format or evidence-entry format changes. `scripts/check-invariants.sh`
  gains check 4d, which pins the template's spelling only.

## 0.14.0
"""),
 ],
 "AGENTS.md": [
  ("""    review is the gate. Three narrow checks in `scripts/check-invariants.sh` cover one
    spelling each — a `Target model:` line naming exactly one recognized model in files
    claiming conformance, a prose checklist-count claim matching the checklist, and the
    finding-severity vocabulary stated as a closed set in both prompt copies (in the
    scaffolded template's own section, in the command file) — and they are a floor, not
    coverage. Every other item is judged by a reader.""",
   """    review is the gate. Four narrow checks in `scripts/check-invariants.sh` cover one
    spelling each — a `Target model:` line naming exactly one recognized model in files
    claiming conformance, a prose checklist-count claim matching the checklist, the
    finding-severity vocabulary stated as a closed set in both prompt copies (in the
    scaffolded template's own section, in the command file), and the `intake` story
    template's `AC-<n>` criterion rows under their rule line (not whether the rule prose or
    the worked example is right, whether any written story follows the rules, or whether an
    amendment renumbered anything) — and they are a floor, not coverage. Every other item is
    judged by a reader."""),
 ],
 "README.md": [
  ("(invariants 5 and 6, plus three prompt-conformance checks)", "(invariants 5 and 6, plus four prompt-conformance checks)"),
 ],
 ".github/workflows/ci.yml": [
  ("      # Invariants 5 and 6 plus three prompt-conformance checks, mechanically, and BOTH",
   "      # Invariants 5 and 6 plus four prompt-conformance checks, mechanically, and BOTH"),
 ],
 "docs/getting-started.md": [
  ("""problem, outcome, ≥3 checkable acceptance criteria, which `AGENTS.md` invariants it""",
   """problem, outcome, ≥3 checkable acceptance criteria (numbered `AC-1`, `AC-2`, … so later
steps can cite them), which `AGENTS.md` invariants it"""),
 ],
 "docs/coding-workflow.md": [
  ("""acceptance criteria, which core invariants the change touches, the open questions,""",
   """acceptance criteria (each with a permanent `AC-<n>` identifier), which core invariants
the change touches, the open questions,"""),
 ],
}
new = {}
for path, reps in edits.items():
    s = open(path).read()
    for old, rep in reps:
        n = s.count(old)
        if n != 1:
            sys.exit(f"STOP: {path}: expected exactly 1 match, found {n}: {old[:70]!r}")
        s = s.replace(old, rep)
    new[path] = s
for path, s in new.items():
    open(path, "w").write(s)
print("edited:", ", ".join(new))
```

Expected: `edited: plugins/dev-workflow/skills/intake/SKILL.md, plugins/dev-workflow/.claude-plugin/plugin.json, plugins/dev-workflow/CHANGELOG.md, AGENTS.md, README.md, .github/workflows/ci.yml, docs/getting-started.md, docs/coding-workflow.md`.

- [ ] **Step 2: Find every other place that counts the narrow checks or describes criteria**

```sh
grep -rnE 'Three narrow checks|three narrow checks|three prompt-conformance' --include='*.md' --include='*.sh' --include='*.yml' . | grep -vE 'source-files/|docs/superpowers/|\.context/|hardening-log'
```
Expected on 2026-10-04: no hit. The edit script already changed the four counting sites: AGENTS.md, README.md, the CI comment, and the checker's mutation-procedure comment (Task 1). Any hit is a stop.

- [ ] **Step 3: Run the AGENTS.md quality row, verbatim, and the suite under dash**

`sh -c '<row>' > /tmp/p5-quality.log 2>&1; echo "quality=$?"`. Then `dash scripts/check-invariants.test.sh > /tmp/p5-dash.log 2>&1; echo "dash=$?"; tail -1 /tmp/p5-dash.log`.
Expected: `quality=0` with `invariant checks: ok` and `all passed (172 assertions)`; `dash=0` and `all passed (172 assertions)` (both measured on a copy on 2026-10-04).

No commit.

---

### Task 3: Evidence, Gate B, close

- [ ] **Step 1: Base check.** Run `git fetch origin; echo "fetch=$?"` and `git merge-base --is-ancestor origin/main HEAD; echo "anc=$?"`. Anything but `fetch=0` and `anc=0` is a stop.

- [ ] **Step 2: Stage and snapshot.** Run `git add scripts/check-invariants.sh scripts/check-invariants.test.sh plugins/dev-workflow/skills/intake/SKILL.md plugins/dev-workflow/.claude-plugin/plugin.json plugins/dev-workflow/CHANGELOG.md AGENTS.md README.md .github/workflows/ci.yml docs/getting-started.md docs/coding-workflow.md && git diff --cached --name-only`. Exactly those ten paths must be listed. Then, as its own one-line tool call: `git commit -m 'WIP: stable AC ids'`.

- [ ] **Step 3: Evidence run.**
  - Record `H=$(git rev-parse HEAD)` and `B=$(git rev-parse HEAD^)`, and check that the status is clean.
  - Check that `main` equals `origin/main`.
  - Run the quality row verbatim (exit 0; its `check-version-bump.sh main` sees the 0.15.0 bump), and the suite under dash with its own exit status (`dash=0`, 172 assertions).
  - **Counterfactual, re-run at every evidence run:** in a temporary copy of the candidate tree with `git show 4b6be6b:plugins/dev-workflow/skills/intake/SKILL.md` put back as the skill, `sh scripts/check-invariants.sh` exits 1 with "AC-<n> criteria are malformed".
  - Generate the spec-delta input: `python3 -B scripts/spec-delta.py --base "$B" --plan docs/superpowers/plans/2026-10-04-stable-acceptance-criterion-ids.md --baseline 4b6be6b:docs/superpowers/specs/2026-10-04-stable-acceptance-criterion-ids-design.md --baseline <plan-close>:docs/superpowers/plans/2026-10-04-stable-acceptance-criterion-ids.md "$H" > /tmp/p5-input.txt`.

Evidence entry for the commit body:

```
Evidence — docs/superpowers/stories/2026-10-04-stable-acceptance-criterion-ids-story.md
Battery: AGENTS.md quality row, exit 0 at <headSha>.
Check (counterfactual): the candidate's check 4d fails on the unnumbered template from
4b6be6b ("AC-<n> criteria are malformed") and passes on the changed one, re-run at <headSha>.
Suite 172/172 under sh and dash at <headSha>. Mutation evidence, measured once on the
prototype (2026-10-04), not re-run: deleting the 4d block flips its 20 cases and no accept case.
```

- [ ] **Step 4: Gate B.** Follow CLAUDE.md §5:
  - Draw a new nonce, and derive the floor and lens sets from the story header at the call.
  - Check `mcp__codex__health` first.
  - Use one `reviewType: full` call per pass, with separate branch files.
  - Each call carries:
    - the story path and the evidence entry;
    - the seven rulings and the prompt-standards self-check;
    - the spec-delta report from `/tmp/p5-input.txt`, regenerated whenever `headSha` changes;
    - the standing lens (the narrow-check count, the plugin version, the CHANGELOG and two docs).
  - After fixes: amend the WIP, rerun the evidence, regenerate the input, and re-review.

- [ ] **Step 5: Close and PR.** When the §5 closure ordering allows it:
  - Run the evidence again.
  - `git log --format='%h %s' origin/main..HEAD` must show the WIP commit over the plan's Gate-A closing commit, then `4b6be6b`, `973da1d`, with nothing staged.
  - Run `git commit --amend -m "<real message>"`, with the evidence entry, the provenance line, the curve and the logical-pass prose, and no trailers.
  - Push and open a PR. CI must pass, including the version-bump check.

## Self-review (2026-10-04)

- **Spec coverage:**
  - §1 → the file map.
  - §2 → Task 2's skill edits (template, rules 1–5, worked example, step 9, common mistakes).
  - §3 → Task 1 (check 4d, required file, fence, region, line classes, status, regression pairs).
  - §4 → the version and CHANGELOG edits.
- **Story criteria:**
  - story AC-1 → the template;
  - story AC-2 → rules 1–3 and the rule line;
  - story AC-3 → rule 4;
  - story AC-4 → rule 5;
  - story AC-5 → check 4d plus the worked example;
  - story AC-6 → no gate or record change, and the CHANGELOG states the scope.
  ("story AC-n" means `docs/superpowers/stories/2026-10-04-stable-acceptance-criterion-ids-story.md AC-n`.)
- **Placeholders:** `<headSha>`, `<plan-close>`, `<real message>` and `<row>` are filled in at run time.
