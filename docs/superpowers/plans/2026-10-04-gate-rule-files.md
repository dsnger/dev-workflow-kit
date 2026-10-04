# Gate Rules in Their Own Scaffolded File Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Story:** `docs/superpowers/stories/2026-10-04-gate-rule-storage-story.md` — read the profile from its header at every gate call.

**Goal:** `/workflow-init` scaffolds the gate rules into `.claude/review-gates.md` and leaves only a pointer under `CLAUDE.md` §5; existing projects migrate safely; a size check guards the template; a named verification shows agents read the file. Ships as dev-workflow 0.16.0.

**Architecture:** Four scripts, all prototyped and run against a copy on 2026-10-04.
- `gf-check-edit.py` moves check 4c to `### 2.1a` and adds check 4e with its cases. Against the real repository it turns the checker red; this is the red step and the counterfactual.
- `gf-edit.py` splits the template, adds the two-target rules and the migration, and updates the version, CHANGELOG and docs. After it the checker is green.
- `ac2-run.sh` and `ac2-check.py` are the AC-2 verification harness. They are not committed: they live in this plan, so a later reader can run them again.

**Tech Stack:** Markdown prompts, POSIX `sh` with `awk` (the checker and its suite), Python 3 (edit scripts, transcript checker), the `claude` CLI 2.1.289 (`-p`, stream-JSON), `shellcheck` 0.11.0.

**Spec:** `docs/superpowers/specs/2026-10-04-gate-rule-files-design.md` (Gate-A spec cycle `m45di86udd`, closed in `763b067`).

## Global Constraints

- Worktree `/Users/daniel/DEVELOPMENT/APPS/dwk-gate-files`, branch `gate-rule-files`. Paths are relative to it.
- The `## 5. Cross-Model Review (Codex) — TWO MANDATORY GATES` heading stays byte for byte, and the hook is not changed (spec §0).
- The rules text is unchanged except the four relocation edits (spec §2, AC-7).
- Both templates stay inline in the command body (invariant 8). Every changed prompt passes all 12 items of `docs/prompt-standards.md` (invariant 11). Version **0.16.0** (invariant 12).
- This repository's own `CLAUDE.md` and `.claude/review-gates.md` are not changed (spec §0).
- Unexpected repository state is a stop and a question to Daniel; no automated stash, rebase or reset.

## Rulings — where the plan settles what the spec left open

1. **Where things go in the command file.**
   - `### 2.1a` sits directly before `### 2.2`. The suffix keeps every later section number, and the references to them, unchanged.
   - The two-target rules and the migration are a bold-led block inside `### 2.1`, before the fence.
   - The pointer body is the canonical one the classifier compares against.
2. **The four relocation edits** (spec §2) are the ones `gf-edit.py` lists. Three mirror #38. The fourth corrects "the text a project's `CLAUDE.md` actually contains", which #38 left in this repository's copy. That copy is out of scope here, so it gets a `todos.md` row.
   - The command file shows all four in a before/after table (AC-7).
   - Task 2 checks that the moved text differs from the old §5 range by exactly these four lines.
3. **Check 4e** counts characters with `wc -m` under the first UTF-8 locale it can prove (`C.UTF-8`, then `en_US.UTF-8`; a two-byte character must count as 1). Without one it fails, with a named cause. A heading inside the fence is template text and does not end the section.
4. **Check 4e is not a prompt-conformance check.** AGENTS.md describes it under invariant 8, and the Commands row adds "template size". The checker header names it beside the four prompt-conformance checks for the mutation procedure. "Four prompt-conformance checks" in README and CI stays true.
5. **Mutation evidence:**
   - Deleting each marked block flips: 4a 20, 4b 22, 4c 20, 4d 22, 4e 6. No accept case moves.
   - All five were measured on the prototype on 2026-10-04. They are re-measured once in Task 1, because the shared fixtures change.
   - They are not re-run per review.
6. **AC-2 harness deviations from spec §5, and why.**
   - **Tools.** `--allowedTools` does not restrict tools in this environment: a probe with only `Bash(git status:*)` allowed still ran `wc`. So the runs use `--tools Read Grep Glob`, with no Bash. The task text states the staged change instead of letting the agent run `git status`.
   - **No inherited MCP servers.** The runs use `--strict-mcp-config --mcp-config '{"mcpServers":{}}'`, so a globally configured Codex server cannot be called. The checker requires each session's init event to show exactly `Glob`, `Grep` and `Read`, no MCP server, and the fixture as its working directory.
   - **Budget.** Each run is capped at `--max-budget-usd 4`. A pilot run with inherited MCP servers cost $1.39, and a trivial isolated run cost $0.04. 16 runs are accepted at roughly $5–22.
   - **Completeness.** The checker requires all 16 labels, each ending in a `success` result. A missing or budget-cut transcript is a FAIL, never a smaller sample.
   - **The no-rules control is judged twice.** The checker fails it unless the session is clean and the answer says the rules are missing. An answer naming a commit-procedure marker is flagged REVIEW, because "I will not make a WIP commit" names one too. A person reads every no-rules answer, and the evidence records that verdict.
   - **Every session, controls included,** must pass the shared check: exact tools, no MCP server, fixture cwd, and a `success` result.
   - **Read attribution is by exact path.** Only a `Read` of the fixture's own `.claude/review-gates.md`, after path resolution, counts.
   - **"Names a rule" is checked by keyword.** Each moment has phrases that occur in the rules file and not in the fixture's `CLAUDE.md` or `AGENTS.md`. The checker computes that set itself. This is a proxy, and the evidence entry says so. The full-read criterion is the real claim.
7. **Review records stay untracked.** As in earlier PRs, they are archived to the main checkout's `.context/` when the worktree is removed. The evidence run's clean check uses `git status --porcelain --untracked-files=no`.

## Prompt-standards self-check (invariant 11), for the changed prompts

| Item | How it is met |
|---|---|
| 1 Target model | the command's `Target model:` line is unchanged; both scaffolded files carry a reasoned n/a note outside their fences |
| 2 Success criteria | the migration names its success state (byte-equal read-back, §5 in pointer form, everything else unchanged) |
| 3 Stop conditions | each stop state in the table, the precondition stops and the "changed while asking" stop |
| 4 Output format with example | Rule 5's report states plus the table's exact report strings |
| 5 Structured sections | numbered steps, a decision table, the before/after table |
| 6 Rules carry their why | the two-target rule, the precondition (git holds the original), the read-back (a truncated move), "own text, not the template's" |
| 7 No contradictions | Step 2.13 now names the pointer; the pointer's missing-file stop matches the table's "no gate rules until now" note |
| 8 Token-lean | the pointer is four short paragraphs; the migration is in the command, which runs rarely, not in always-loaded text |
| 9 Positive instructions | each state says what to do; the "never" items carry their reason |
| 10 Diagnostic states name causes | every stop and failure string names its cause; "rules file unusable" names which of four |
| 11 Enforcement claims name their mechanism | 4e's header and AGENTS.md say what it measures and what it does not |
| 12 Calibrated emphasis | bold is used for state names and the one hard order (read both before writing either) |

## Review Focus

1. **An agent running the migration skips the read-back or the SHA-256 re-check.** Expected: no `CLAUDE.md` rewrite without both. Only prose enforces this. The Gate-B reviewer checks that the steps are unambiguous and ordered.
2. **The pointer classifier on a real degraded-mode project.** Expected: pointer form. The definition admits exactly Step 2.13's notice plus one blank line. Only prose applies it, so the reviewer checks that the two texts quoted in the command agree.
3. **A project whose §5 has no footer after it.** Expected: the diff says that everything after the heading moves. This is a prose rule; the reviewer reads it.
4. **4e on CI's Ubuntu (mawk, `C.UTF-8`).** Expected: the same count as on macOS. The PR's CI run is the check; the multibyte case would fail if a byte count slipped in.
5. **A model answering from memory rather than the file.** The full-read criterion carries the claim. The keyword proxy and the controls are reported as behaviour, not proof (spec §5).

---

## File map

| Path | Change | Task |
|---|---|---|
| `scripts/check-invariants.sh` | 4c anchors on `### 2.1a`; new check 4e; header names 4e | 1 |
| `scripts/check-invariants.test.sh` | shared fixtures with `### 2.1a` and a fenced `### 2.1`; 4c anchor cases; 9 new 4e cases; mutation block | 1 |
| `plugins/dev-workflow/commands/workflow-init.md` | `### 2.1` pointer, two-target rules and migration; new `### 2.1a`; Rule 5; Step 2.13 | 2 |
| `plugins/dev-workflow/.claude-plugin/plugin.json`, `plugins/dev-workflow/CHANGELOG.md` | `0.16.0` | 2 |
| `AGENTS.md` | invariant 8 sentence on the split and 4e; Commands row label | 2 |
| `MANIFEST.md`, `docs/getting-started.md`, `todos.md` | §2.1a note; leaving deletes the rules file too; two todo rows | 2 |

---

### Task 1: Checks 4c and 4e first (red)

- [ ] **Step 1: Apply the check edit script.** Save it as a temporary file outside the repository, and run it with `python3` from the repository root. It writes nothing unless every anchor matches exactly once.

`````python
# Moves check 4c's placement rule to `### 2.1a` and adds check 4e (the size budget of the
# scaffolded CLAUDE.md template) to scripts/check-invariants.sh, with fixtures and cases in
# scripts/check-invariants.test.sh. Every replacement must match exactly once, or the
# script stops before writing anything.
import sys

checker = "scripts/check-invariants.sh"
test = "scripts/check-invariants.test.sh"
c = open(checker).read()
t = open(test).read()

def rep(s, old, new, where):
    n = s.count(old)
    if n != 1:
        sys.exit(f"STOP: {where}: expected exactly 1 match, found {n}: {old[:70]!r}")
    return s.replace(old, new)

# --- checker: header ---------------------------------------------------------------
c = rep(c, """# MUTATION RE-RUN PROCEDURE (manual; nothing automates it). The four prompt-conformance
# checks below are bracketed by `# --- BEGIN check 4a ---` / `# --- END check 4a ---`
# markers -- and likewise for 4b, 4c and 4d -- so a scratch copy can be neutered cleanly.""",
"""# MUTATION RE-RUN PROCEDURE (manual; nothing automates it). The four prompt-conformance
# checks below, and the size-budget check 4e, are bracketed by `# --- BEGIN check 4a ---` /
# `# --- END check 4a ---` markers -- and likewise for 4b, 4c, 4d and 4e -- so a scratch
# copy can be neutered cleanly.""", checker)
c = rep(c, "#   chk=4a   # then 4b, 4c, then 4d\n", "#   chk=4a   # then 4b, 4c, 4d, then 4e\n", checker)

# --- checker: 4c placement moves to ### 2.1a ------------------------------------------
c = rep(c, """# Only the template region reaches a user's project, so the command file gets a placement
# rule anchored on its `### 2.1` scaffold heading and terminated by the NEXT NUMBERED
# heading -- not the next `###`, because the template contains its own unnumbered
# `### Profiles` and `### Mechanics` subsections and would truncate the range.""",
"""# Only the template region reaches a user's project, so the command file gets a placement
# rule anchored on its `### 2.1a` heading -- the gate-rules template, which `/workflow-init`
# writes to `.claude/review-gates.md` -- and terminated by the NEXT NUMBERED heading -- not
# the next `###`, because the template contains its own unnumbered `### Profiles` and
# `### Mechanics` subsections and would truncate the range. The `### 2.1` CLAUDE.md
# template is outside the range on purpose: since 0.16.0 it holds only a pointer, and a
# severity line left there would ship in the wrong file.""", checker)
c = rep(c, "    /^### 2\\.1[[:space:]]/ { intpl = 1; heads += 1; next }\n",
           "    /^### 2\\.1a[[:space:]]/ { intpl = 1; heads += 1; next }\n", checker)
c = rep(c, """      fail "Prompt standards: $sev_file has $sev_heads '### 2.1' scaffold headings, so the closed severity set's placement cannot be checked." \\""",
"""      fail "Prompt standards: $sev_file has $sev_heads '### 2.1a' gate-rules template headings, so the closed severity set's placement cannot be checked." \\""", checker)
c = rep(c, """      fail "Prompt standards: $sev_file's '### 2.1' section is terminated by '$sev_term', not '2.2', so the closed severity set's placement cannot be checked." \\""",
"""      fail "Prompt standards: $sev_file's '### 2.1a' section is terminated by '$sev_term', not '2.2', so the closed severity set's placement cannot be checked." \\""", checker)
c = rep(c, """      fail "Prompt standards: $sev_file states the closed severity set outside the scaffolded CLAUDE.md template, so an initialized project would not receive it." \\
           "expected it inside the '### 2.1' section\"""",
"""      fail "Prompt standards: $sev_file states the closed severity set outside the scaffolded gate-rules template, so an initialized project would not receive it." \\
           "expected it inside the '### 2.1a' section\"""", checker)

# --- checker: check 4e ------------------------------------------------------------------
c = rep(c, """# --- END check 4d ---
""", """# --- END check 4d ---

# --- BEGIN check 4e ---
# Size budget for the scaffolded CLAUDE.md. Claude Code warns when a project's always-loaded
# instruction files pass a combined limit (150.0k characters when this was written; its docs
# do not state the number). The gate rules alone are about 122k characters, which is why
# `/workflow-init` scaffolds them into `.claude/review-gates.md` and leaves only a pointer in
# CLAUDE.md. This check keeps the CLAUDE.md template small enough that a project's own
# AGENTS.md and other instruction files still fit.
#
# It measures CHARACTERS, not bytes, because the limit counts characters: the body of the
# first ````markdown fence inside `### 2.1`, up to the next line that is exactly ````. The
# count runs under a UTF-8 locale, probed first; without one it fails, because a byte count
# would read every non-ASCII character as two or three.
#
# What it does NOT check: the gate-rules template (`### 2.1a`, read on demand, not always
# loaded); a project's own AGENTS.md or other instruction files, which `/workflow-init` does
# not write from a fixed template; this repository's own instruction files; and whether
# Claude Code's limit is still 150.0k.
TPL_FILE=plugins/dev-workflow/commands/workflow-init.md
TPL_BUDGET=20000

# Prints the fence body, then a last line `@@STATUS <anchors> <opened> <closed>`. Headings
# inside the fence are template text, not section boundaries. Returns 2 if awk itself failed.
tpl_size_scan() { # $1 = file
  awk '                                            # tpl-size-scan
    infence { if ($0 == "````") { infence = 0; closed += 1; done = 1 } else print; next }
    /^### 2\\.1[[:space:]]/ { heads += 1; in21 = 1; next }
    in21 && /^### / { in21 = 0; next }
    in21 && !done && $0 == "````markdown" { infence = 1; opened += 1; next }
    END { printf "@@STATUS %d %d %d\\n", heads + 0, opened + 0, closed + 0 }
  ' "$1" || return 2
}

if [ ! -f "$TPL_FILE" ]; then
  fail "CLAUDE.md template size: $TPL_FILE is missing, so the budget cannot be checked." \\
       "the scaffolded template lives there"
elif [ ! -r "$TPL_FILE" ]; then
  fail "CLAUDE.md template size: $TPL_FILE is unreadable, so the budget cannot be checked." \\
       "check permissions"
else
  tpl_out=$(tpl_size_scan "$TPL_FILE"); tpl_st=$?
  if [ "$tpl_st" -ne 0 ]; then
    fail "CLAUDE.md template size parser failed; results are not trustworthy." \\
         "awk exited $tpl_st on $TPL_FILE"
  else
    # Word splitting is the point: the status line is four space-separated fields.
    # shellcheck disable=SC2046
    set -- $(printf '%s\\n' "$tpl_out" | tail -n 1)
    if [ "$2" -ne 1 ]; then
      fail "CLAUDE.md template size: $TPL_FILE has $2 '### 2.1' headings, so the template cannot be located." \\
           "expected exactly one"
    elif [ "$3" -eq 0 ]; then
      fail "CLAUDE.md template size: no \\`\\`\\`\\`markdown fence inside '### 2.1' in $TPL_FILE." \\
           "the template must be fenced"
    elif [ "$4" -eq 0 ]; then
      fail "CLAUDE.md template size: the template fence in '### 2.1' is never closed." \\
           "expected a line that is exactly \\`\\`\\`\\`"
    else
      tpl_loc=''
      for l in C.UTF-8 en_US.UTF-8; do
        if [ "$(printf '\\303\\251' | LC_ALL=$l wc -m | tr -d ' ')" = 1 ]; then tpl_loc=$l; break; fi
      done
      if [ -z "$tpl_loc" ]; then
        fail "CLAUDE.md template size: no UTF-8 locale (C.UTF-8 or en_US.UTF-8), so characters cannot be counted." \\
             "a byte count would overstate every non-ASCII character"
      else
        tpl_chars=$(printf '%s\\n' "$tpl_out" | sed '$d' | LC_ALL=$tpl_loc wc -m | tr -d ' ')
        if [ "$tpl_chars" -gt "$TPL_BUDGET" ]; then
          fail "CLAUDE.md template size: the scaffolded CLAUDE.md is $tpl_chars characters, over the $TPL_BUDGET budget." \\
               "keep §5 a pointer; the rules belong in the '### 2.1a' template"
        fi
      fi
    fi
  fi
fi
# --- END check 4e ---
""", checker)

# --- test: fixtures ------------------------------------------------------------------------
t = rep(t, """      # 4c: the command file needs the line INSIDE a `### 2.1` scaffold section, because
      # only that region is written into an initialized project. A copy anywhere else in
      # the file satisfies the duplicate count and still ships nothing.
      printf '\\n### 2.1 CLAUDE-md\\n\\n%s\\n\\n### 2.2 next\\n' "$SEV_LINE"
""", """      # 4c: the command file needs the line INSIDE the `### 2.1a` gate-rules section,
      # because only that region is written into an initialized project's rules file. A
      # copy anywhere else satisfies the duplicate count and still ships nothing.
      # 4e: `### 2.1` needs a small fenced CLAUDE.md template, or every fixture fails the
      # size check on a missing fence before reaching its own assertion.
      printf '\\n'; tpl_sections "$TPL_OK" "$SEV_LINE"
""", test)
t = rep(t, """# The backticks are literal Markdown in the rule line, not command substitution.
# shellcheck disable=SC2016
AC_RULE_LINE=""", """# A valid `### 2.1` section: a heading and a small fenced CLAUDE.md template.
# shellcheck disable=SC2016  # literal Markdown fence, not command substitution
TPL_OK='### 2.1 CLAUDE-md

````markdown
# T
````'
# The three template sections of a command file: $1 is the whole `### 2.1` section, $2 goes
# inside `### 2.1a`, and $3, if given, after `### 2.2` (outside both templates).
tpl_sections() {
  printf '%s\\n\\n### 2.1a review-gates\\n\\n%s\\n\\n### 2.2 next\\n\\n%s\\n' "$1" "$2" "${3:-}"
}
# The backticks are literal Markdown in the rule line, not command substitution.
# shellcheck disable=SC2016
AC_RULE_LINE=""", test)
t = rep(t, """# $1 goes INSIDE the `### 2.1` section; $2, if given, after it (outside the template).
sev_tpl() {
  printf '# Prompt Standards\\n\\n## Checklist (each item must be verifiably true)\\n\\n'
  i=1; while [ "$i" -le 12 ]; do printf '%s. **item %s**\\n' "$i" "$i"; i=$((i + 1)); done
  printf '\\n## After\\n\\nReviewed against all 12 items.\\n\\n'
  printf '### 2.1 CLAUDE-md\\n\\n%s\\n\\n### 2.2 next\\n\\n%s\\n' "$1" "${2:-}"
}""", """# $1 goes INSIDE the `### 2.1a` section; $2, if given, after `### 2.2` (outside the
# template). $3, if given, replaces the valid `### 2.1` section.
sev_tpl() {
  printf '# Prompt Standards\\n\\n## Checklist (each item must be verifiably true)\\n\\n'
  i=1; while [ "$i" -le 12 ]; do printf '%s. **item %s**\\n' "$i" "$i"; i=$((i + 1)); done
  printf '\\n## After\\n\\nReviewed against all 12 items.\\n\\n'
  tpl_sections "${3:-$TPL_OK}" "$1" "${2:-}"
}""", test)

# --- test: 4c cases follow the anchor ------------------------------------------------------
t = rep(t, """sev_case "4c: missing 2.1 anchor rejected"                1 "@KEEP@" "$(sev_tpl "$SEV_LINE" | sed 's/^### 2\\.1.*/## not an anchor/')"
sev_case "4c: duplicate 2.1 anchor rejected"              1 "@KEEP@" "$(sev_tpl "$SEV_LINE")
### 2.1 CLAUDE-md again
\"""", """sev_case "4c: missing 2.1a anchor rejected"               1 "@KEEP@" "$(sev_tpl "$SEV_LINE" | sed 's/^### 2\\.1a.*/## not an anchor/')"
sev_case "4c: duplicate 2.1a anchor rejected"             1 "@KEEP@" "$(sev_tpl "$SEV_LINE")
### 2.1a review-gates again
"
# The CLAUDE.md template (`### 2.1`) is outside the range: since 0.16.0 it is a pointer,
# and a severity line there would ship in CLAUDE.md, not in the rules file.
# shellcheck disable=SC2016  # literal Markdown fence, not command substitution
sev_case "4c: line in the CLAUDE.md template rejected"    1 "@KEEP@" "$(sev_tpl "nothing here" "" '### 2.1 CLAUDE-md

````markdown
# T
'"$SEV_LINE"'
````')\"""", test)
t = rep(t, """sev_case "4c: review-gates.md needs no 2.1 anchor\"""", """sev_case "4c: review-gates.md needs no 2.1a anchor\"""", test)

# --- test: 4e cases --------------------------------------------------------------------------
t = rep(t, """# --- Prompt conformance: check 4d, the AC-<n> story template""", """# --- Check 4e, the size budget of the scaffolded CLAUDE.md template ---------------------
#
# Each case replaces the `### 2.1` section of an otherwise valid command file. The budget is
# 20000 characters of fence body, each line counted with its newline; the multibyte case
# is the one that shows characters, not bytes, are counted.
TE='CLAUDE.md template size'
te_body() { # $1 = character, $2 = count; $2 copies of $1, no newline
  printf '%*s' "$2" '' | LC_ALL=C sed "s/ /$1/g"
}
te_section() { # $1 = fence body, one line; with its newline it counts length + 1
  # shellcheck disable=SC2016  # literal Markdown fence, not command substitution
  printf '### 2.1 CLAUDE-md\\n\\n````markdown\\n%s\\n````' "$1"
}
te_case() { # $1 = name, $2 = 1|0 expect reject, $3 = the whole `### 2.1` section, or @GONE@,
  #          $4 = optional diagnostic substring a reject must also carry
  rm -rf "$work/r"; mkdir -p "$work/r/scripts" "$work/r/.github/workflows" \\
    "$work/r/plugins/p/.claude-plugin"
  cp "$CHECKER" "$work/r/scripts/"
  init_prompt_fixtures "$work/r"
  printf '%s\\n' '{"name": "p", "version": "1.0.0"}' > "$work/r/plugins/p/.claude-plugin/plugin.json"
  printf '%s\\n' "$PINNED" > "$work/r/.github/workflows/ci.yml"
  cf="$work/r/plugins/dev-workflow/commands/workflow-init.md"
  case "$3" in @GONE@) rm -f "$cf" ;; *) sev_tpl "$SEV_LINE" "" "$3" > "$cf" ;; esac
  out=$( cd "$work/r" && sh scripts/check-invariants.sh 2>&1 ); st=$?
  if [ "$2" -eq 1 ]; then
    if [ "$st" -eq 0 ]; then fail "$1 (exited 0)"
    elif ! printf '%s' "$out" | grep -qF "$TE" || ! printf '%s' "$out" | grep -qF -- "${4:-$TE}"; then
      fail "$1 (wrong diagnostic: $(printf '%s' "$out" | tr '\\n' ' '))"
    else pass "$1"; fi
  else
    if [ "$st" -eq 0 ]; then pass "$1"
    else fail "$1 (exited $st: $(printf '%s' "$out" | tr '\\n' ' '))"; fi
  fi
}
te_case "4e: template at the budget accepted"              0 "$(te_section "$(te_body a 19999)")"
te_case "4e: template one over the budget rejected"        1 "$(te_section "$(te_body a 20000)")" \\
  'is 20001 characters, over the 20000 budget'
# 19999 two-byte characters plus a newline: 20000 characters, 39999 bytes.
te_case "4e: multibyte template counted in characters"     0 "$(te_section "$(te_body 'é' 19999)")"
te_case "4e: missing 2.1 anchor rejected"                  1 "$(te_section x | sed 's/^### 2\\.1 .*/## not an anchor/')" \\
  "has 0 '### 2.1' headings"
te_case "4e: missing fence rejected"                       1 '### 2.1 CLAUDE-md

no fence here' 'markdown fence inside'
# shellcheck disable=SC2016  # literal Markdown fence, not command substitution
te_case "4e: unclosed fence rejected"                      1 '### 2.1 CLAUDE-md

````markdown
# T' 'is never closed'
# A heading inside the fence is template text: it must not end the section or the fence.
# shellcheck disable=SC2016  # literal Markdown fence, not command substitution
te_case "4e: a heading inside the fence accepted"          0 '### 2.1 CLAUDE-md

````markdown
### Don'"'"'t guess
````'
te_case "4e: missing command file rejected"                1 "@GONE@"
inject_case "4e template size parser failure fires" awk '*tpl-size-scan*' \\
  'CLAUDE.md template size parser failed'

# --- Prompt conformance: check 4d, the AC-<n> story template""", test)

# --- test: mutation evidence, re-measured after the fixture change --------------------------
t = rep(t, """#   4c -> 19   every `4c:` reject fixture (18) and
#              `4c canonical-line parser failure fires`.""", """#   4c -> 20   every `4c:` reject fixture (19) and
#              `4c canonical-line parser failure fires` (re-measured 2026-10-04 after the
#              `### 2.1a` anchor and the CLAUDE.md-template case).""", test)
t = rep(t, """#              no-fence-before-the-next-section and rule-below-the-criteria cases were
#              added).
""", """#              no-fence-before-the-next-section and rule-below-the-criteria cases were
#              added).
#   4e -> 6    every `4e:` reject fixture (5) and `4e template size parser failure
#              fires`; no accept case moved (measured 2026-10-04). 4a, 4b and 4d were
#              re-measured the same day after the shared fixtures changed: 20, 22, 22.
""", test)

open(checker, "w").write(c)
open(test, "w").write(t)
print("edited:", checker, test)
`````

Expected: `edited: scripts/check-invariants.sh scripts/check-invariants.test.sh`.

- [ ] **Step 2: The suite is green and the real repository is red.**
  - Run `S=<scratch dir>; sh scripts/check-invariants.test.sh > $S/t.log 2>&1; echo "test=$?"; tail -1 $S/t.log; sh scripts/check-invariants.sh > $S/red.log 2>&1; echo "inv=$?"; cat $S/red.log`.
  - Expected: `test=0` and `all passed (184 assertions)`; `inv=1`, with exactly two failures:
    - `... has 0 '### 2.1a' gate-rules template headings ...` (4c);
    - `CLAUDE.md template size: the scaffolded CLAUDE.md is 126161 characters, over the 20000 budget.` (4e).

  The current template fails both. That is the counterfactual.

- [ ] **Step 3: Lint.** `shellcheck --shell=sh scripts/check-invariants.sh && shellcheck --shell=sh --exclude=SC2015 scripts/check-invariants.test.sh`. Expected: exit 0.

- [ ] **Step 4: Re-measure the mutation evidence.**
  - Use the header's procedure for each of 4a–4e, on a temporary copy, never with stash.
  - Expected flips: 20, 22, 20, 22, 6. No flipped case name contains "accepted", "ignored" or "needs no".
  - Any other count is a stop. The block records only measured numbers.

No commit.

---

### Task 2: The template split, the migration rules, version and docs (green)

- [ ] **Step 1: Apply the edit script.** Run it the same way as in Task 1.

`````python
# Splits /workflow-init's CLAUDE.md template: §5 becomes a pointer, the rules move to a new
# `### 2.1a` template for `.claude/review-gates.md`, with the migration rules for existing
# projects. Also the version, CHANGELOG and docs. Every replacement must match exactly once,
# or the script stops before writing anything.
import sys

CMD = "plugins/dev-workflow/commands/workflow-init.md"
HEAD = "## 5. Cross-Model Review (Codex) — TWO MANDATORY GATES"
FOOT = "**These guidelines are working if:**"

POINTER = """**The full rules live in `.claude/review-gates.md`. Read that file in full before any
work it governs: any Gate A or Gate B pass, resuming or closing a cycle, any commit,
preparing a merge, and deciding a change needs no gate.** Every reference to §5 (its
Mechanics, Profiles, closure ordering or gate prompt) means that file.

**If that file is missing, this project has no gate rules.** Stop before any work they
govern, and restore it: `/workflow-init` writes it.

Why it is separate: inline, the rules push the instruction files past Claude Code's size
limit.""".split("\n")

NOTE = """This is `CLAUDE.md` §5 in full, moved here unchanged except where the text named its own
location. Everything below that says "this section" or "§5" means this file.""".split("\n")

RELOCATIONS = [
    ("so these rules bind only over the text a project's `CLAUDE.md` actually contains, and a",
     "so these rules bind only over the text a project's `CLAUDE.md` and `.claude/review-gates.md` actually contain, and a"),
    ("first — `Minor`, `minor` and `MINOR` are all `MINOR`, because `CLAUDE.md` Mechanics",
     "first — `Minor`, `minor` and `MINOR` are all `MINOR`, because this file's Mechanics"),
    ("nothing that any mandatory rule in this file or in `AGENTS.md` requires.**",
     "nothing that any mandatory rule in this file, in `CLAUDE.md` or in `AGENTS.md` requires.**"),
    ("**\"Mandatory\" is not limited to this file.**",
     "**\"Mandatory\" is not limited to these files.**"),
]

def stop(msg):
    sys.exit("STOP: " + msg)

def rep(s, old, new, where):
    n = s.count(old)
    if n != 1:
        stop(f"{where}: expected exactly 1 match, found {n}: {old[:70]!r}")
    return s.replace(old, new)

# --- the split -------------------------------------------------------------------------------
lines = open(CMD).read().split("\n")
hs = [i for i, l in enumerate(lines) if l == HEAD]
if len(hs) != 1:
    stop(f"{CMD}: {len(hs)} §5 headings")
h = hs[0]
fs = [i for i in range(h + 1, len(lines) - 2)
      if lines[i] == "---" and lines[i + 1] == "" and lines[i + 2].startswith(FOOT)]
if not fs:
    stop(f"{CMD}: no scaffolded footer after §5")
f = fs[0]
body = lines[h + 1:f]
if any(l.startswith("````") for l in body):
    stop("§5 holds a four-backtick fence; it cannot be nested in the 2.1a fence")
while body and body[0] == "":
    body.pop(0)
while body and body[-1] == "":
    body.pop()
rules = "\n".join(["# Cross-Model Review (Codex) — TWO MANDATORY GATES", ""] + NOTE + [""] + body)
for old, new in RELOCATIONS:
    rules = rep(rules, old, new, "relocation")
lines[h + 1:f] = [""] + POINTER + [""]
s = "\n".join(lines)

SECTION_21A = """### 2.1a `.claude/review-gates.md` — the gate rules

The full text of §5, which the `CLAUDE.md` template above reduces to a pointer. Write it by
the Rules above, and decide it **together with** `CLAUDE.md` as "The two gate-rules
targets" (in 2.1) says. Why a separate file: inline, these rules are about 122k characters,
and Claude Code warns when a project's always-loaded instruction files pass its combined
limit (150.0k characters when this was written). This file is read when the pointer
sends the agent here, not at every session start. It lives under `.claude/`, so the gate
hook treats it as a prompt, and an edit to it fires full Gate B.

**What differs from the inline §5 it replaces**, so a reader can check that nothing else
did: the heading is level 1, the two-line note below it is new, and four sentences that
named the rules' own location now name this file:

| Before (inline in `CLAUDE.md`) | After (in this file) |
|---|---|
""" + "\n".join(f"| {o.replace('|', chr(92) + '|')} | {n.replace('|', chr(92) + '|')} |" for o, n in RELOCATIONS) + """

> **Prompt-standards item 1 for the scaffolded `.claude/review-gates.md`: n/a, and why** —
> the same reason as for the `CLAUDE.md` template above: its executing model is whatever
> the project runs. This note sits outside the fence so it never scaffolds.

````markdown
""" + rules + """
````

"""
s = rep(s, "### 2.2 `docs/hardening-log.md` — the empty ledger\n",
        SECTION_21A + "### 2.2 `docs/hardening-log.md` — the empty ledger\n", CMD)

# --- the two-target rules, in 2.1 ---------------------------------------------------------------
s = rep(s, """If a `CLAUDE.md` already exists with unrelated project content, do not overwrite it:
offer to **append** sections §1–§5 (renumbering only if the file already uses those
numbers) and say so in the report.
""", """If a `CLAUDE.md` already exists with unrelated project content, do not overwrite it:
offer to **append** sections §1–§5 (renumbering only if the file already uses those
numbers) and say so in the report.

**The two gate-rules targets.** This template's §5 is only a pointer; the rules are the
`### 2.1a` template, written to `.claude/review-gates.md`. **Read both targets before writing
either, and act on their combined state.** Why: a project initialized before 0.16.0 carries
the rules inline in §5, and writing the two files one by one could leave it with two
definitions of the rules, or none — and the rules themselves stop on either.

1. **Find §5 in an existing `CLAUDE.md`.** It starts at a line matching
   `^#{1,6}[[:space:]]+([0-9]+\\.)?[[:space:]]*Cross-Model Review` (the gate hook's own
   pattern). It ends before the first of: the next heading of the same or a higher level;
   the scaffolded footer — a line that is exactly `---`, one blank line, then a line
   beginning `**These guidelines are working if:**`; the end of the file. A `---` line on
   its own does not end it: a project may use one inside its rules, and ending there would
   strand the rest.
2. **Classify §5:**
   - **pointer form** — the body after the heading line is byte-identical to the pointer
     under §5 in the template above, optionally preceded by exactly the `INACTIVE` notice
     from 2.13 and one blank line;
   - **mixed** — the body contains "The full rules live in `.claude/review-gates.md`" but is
     not pointer form. An edited pointer and a pointer pasted above rules that are still
     inline look the same here, so neither is assumed;
   - **inline form** — the body does not contain that sentence and is not empty;
   - **empty** — the heading has no body; **absent** — no matching heading;
     **ambiguous** — more than one matching heading.

   Classify `.claude/review-gates.md` as **missing**, **usable** (a readable regular file
   with at least one non-blank line), or **unusable** — empty, all blank, unreadable, or not
   a regular file; name which.
3. **Act on the pair:**

   | `CLAUDE.md` | `.claude/review-gates.md` | Do | Report |
   |---|---|---|---|
   | missing | missing | write both templates | `written` ×2 |
   | missing | usable | write `CLAUDE.md`; the rules file by Rule 2 | per file |
   | §5 absent | missing or usable | offer the append above; the rules file by Rule 2 | per file |
   | pointer form | missing | write the rules file, and say the project had no gate rules until now | `written` + that note |
   | pointer form | usable | each file by Rule 2 | per file |
   | inline form | missing | offer the migration (step 4) | `migrated`, `skipped (user)` or a failure state |
   | inline form | usable | **stop**: two definitions — show both paths and offer the diff between them; the user chooses | `stopped: two definitions` |
   | mixed | any | **stop**: show §5's line range against the template pointer | `stopped: §5 neither pointer nor rules` |
   | empty | any | **stop**: §5 defines nothing | `stopped: §5 empty` |
   | ambiguous | any | **stop**: name each matching heading and its line | `stopped: ambiguous §5` |
   | any | unusable | **stop** | `stopped: rules file unusable (<cause>)` |

   A **stop** writes neither file. The rest of the run goes on with the other targets, and
   the closing report lists every stop with its cause.
4. **The migration** (inline form, no rules file):
   1. **Preconditions:** `CLAUDE.md` is tracked by git with no uncommitted changes, and
      `.claude/review-gates.md` does not exist. Otherwise stop with
      `stopped: commit CLAUDE.md first` (or the table's state) and write nothing. Why: git
      then holds the original, which is what makes step 5's rollback safe.
   2. **Show the change** and record two SHA-256 sums: the current `CLAUDE.md`, and the
      payload below.
      - In `CLAUDE.md`, exactly the §5 range is replaced by the template's pointer. If the
        body begins with exactly the `INACTIVE` notice from 2.13 and one blank line, that
        notice stays above the pointer and is not moved: it must stay always loaded.
      - The payload for `.claude/review-gates.md` is **the project's own §5 body**, minus
        such a notice — not
        this template's, because a project may have adapted its rules; moving them is not
        updating them — under the level-1 heading and the two-line note from 2.1a, with the
        four relocation edits from 2.1a applied wherever the exact "before" sentence is
        present.
      - List each relocation edit whose sentence was not found, and every remaining line of
        the payload that names `CLAUDE.md`. They stay as they are unless the user edits them
        before answering, so a self-reference no exact edit caught is decided by a person.
      - Where §5 ran to the end of the file, say so in words: everything after the heading
        moves.
   3. **Ask:** migrate / skip. Skip writes nothing; report `skipped (user)` and warn that
      the inline rules keep the project near or over the instruction-size limit.
   4. **On migrate:**
      - re-check the preconditions, and that `CLAUDE.md`'s SHA-256 still equals the one
        recorded. If not, someone edited it while you asked: stop with
        `stopped: CLAUDE.md changed while asking` and write nothing;
      - create `.claude/review-gates.md` only if it is still absent;
      - read it back in full; its SHA-256 must equal the payload's. A short, partial or
        different read-back is a failure — this is what stops a truncated move from
        removing the only copy of the rules;
      - only then write the new `CLAUDE.md`, read it back, and classify it: §5 must be
        pointer form, and every byte outside the §5 range must equal the original.
   5. **On any failure after the first write, roll back:**
      - restore `CLAUDE.md` from git (`git checkout -- CLAUDE.md`), which step 1 made equal
        to the original;
      - delete `.claude/review-gates.md` **only if** its content is still exactly the
        payload. A file that differs may be a short write of your own or another writer's
        file; you cannot tell which, so leave it, and the rollback is incomplete.

      Report `migration failed: <step> (<cause>), rolled back` only when `CLAUDE.md` is
      restored and the rules file is gone. Otherwise report
      `migration failed, rollback incomplete` with what each file now holds —
      §5's form, and whether the rules file exists — and the git command that restores
      `CLAUDE.md`. Retry nothing silently: two definitions or none is the state the rules
      stop on, so it must never be left without a report that names it.
   6. Bringing the moved rules up to this template's version is **not** part of the
      migration. A later run offers it by Rule 2's diff on `.claude/review-gates.md`, so the
      user sees content changes apart from the move.
""", CMD)

# --- Rule 5 report states, Step 2.13 placement ------------------------------------------------
s = rep(s, """5. **Report what happened per file** — `written` / `unchanged` / `merged` /
   `skipped (user)` / `asked, overwrote`. No silent no-ops.""",
"""5. **Report what happened per file** — `written` / `unchanged` / `merged` /
   `skipped (user)` / `asked, overwrote`, and for the two gate-rules targets also
   `migrated`, a `migration failed …` state or a `stopped: …` state (2.1). No silent
   no-ops.""", CMD)
s = rep(s, """  CLAUDE.md                        written
  AGENTS.md                        written (3 TODOs — see checklist)""", """  CLAUDE.md                        written
  .claude/review-gates.md          written
  AGENTS.md                        written (3 TODOs — see checklist)""", CMD)
s = rep(s, "2. Add one line at the very top of §5 in the scaffolded `CLAUDE.md`:\n",
        "2. Add one line at the very top of §5 in the scaffolded `CLAUDE.md`, above the pointer\n"
        "   (not in `.claude/review-gates.md`, which is read only on demand):\n", CMD)
open_cmd = s

# --- other files -----------------------------------------------------------------------------
edits = {
 "plugins/dev-workflow/.claude-plugin/plugin.json": [('"version": "0.15.0",', '"version": "0.16.0",')],
 "plugins/dev-workflow/CHANGELOG.md": [("""## 0.15.0
""", """## 0.16.0

- **The gate rules get their own scaffolded file.** `/workflow-init`'s `CLAUDE.md` template
  keeps the `## 5. Cross-Model Review` heading, which the hook greps, but its body is now a
  pointer; the rules (about 122k characters) are a new `### 2.1a` template written to
  `.claude/review-gates.md`. Inline, they put an initialized project near or over Claude
  Code's instruction-file limit. The rules are unchanged except four sentences that named
  their own location; the command lists them. The pointer adds one sentence this
  repository's pointer lacks: if the file is missing, the project has no gate rules, so
  stop and restore it.
- **Existing projects are migrated, never silently.** `/workflow-init` reads both targets
  first and classifies `CLAUDE.md` §5: pointer form, inline, mixed, empty, absent or
  ambiguous. An inline §5 with no rules file is offered a migration that moves the
  project's own text (not the template's). It needs a clean, tracked `CLAUDE.md`, re-checks
  it before writing, requires a byte-equal read-back of the new file, and rolls back from
  git on failure. Two definitions, a mixed or empty §5, or an unusable rules file stop and
  are reported. The degraded-mode `INACTIVE` notice stays at the top of §5 in `CLAUDE.md`.
- `scripts/check-invariants.sh`: check 4c's placement rule now anchors on `### 2.1a`, and
  a new check 4e fails when the scaffolded `CLAUDE.md` template passes 20,000 characters.

## 0.15.0
""")],
 "AGENTS.md": [("""8. **`/workflow-init`'s templates stay inline** in the command body. Claude Code does
   not expand `${CLAUDE_PLUGIN_ROOT}` inside command markdown (verified), and the cache
   path is not an API — a command that read templates from disk would break the first
   time that layout changed.""", """8. **`/workflow-init`'s templates stay inline** in the command body. Claude Code does
   not expand `${CLAUDE_PLUGIN_ROOT}` inside command markdown (verified), and the cache
   path is not an API — a command that read templates from disk would break the first
   time that layout changed. Inline does not mean always loaded: the scaffolded
   `CLAUDE.md` holds §5 as a pointer, and the rules go to `.claude/review-gates.md`
   (template `### 2.1a`), because inline they would put an initialized project past
   Claude Code's instruction-file limit. Check 4e in `scripts/check-invariants.sh` fails
   when the `CLAUDE.md` template passes 20,000 characters; it measures that template only."""),
  ("| invariant checks (5 pinning, 6 manifest, prompt conformance) |", "| invariant checks (5 pinning, 6 manifest, prompt conformance, template size) |")],
 "MANIFEST.md": [("""  inline in the command body, so nothing reads a template off disk. It covers **§1–§5**,
  and `/workflow-init` §2.1 scaffolds it by that name.""", """  inline in the command body, so nothing reads a template off disk. It covers **§1–§5**,
  and `/workflow-init` §2.1 scaffolds it by that name. Since 0.16.0 its §5 is a pointer:
  the rules are the §2.1a template, scaffolded as `.claude/review-gates.md`.""")],
 "docs/getting-started.md": [("""4. **Leave for good:** remove §5 from the project's `CLAUDE.md` (and
   `.context/codex-gate.on`) — the project reads as not adopted again.""", """4. **Leave for good:** remove §5 from the project's `CLAUDE.md`, delete
   `.claude/review-gates.md` and `.context/codex-gate.on` — the project reads as not
   adopted again.""")],
 "todos.md": [("""- [ ] **Gate-rule storage within the instruction-size limit.**""", """- [ ] **This repository's `.claude/review-gates.md` still says its rules bind over the text
      a project's `CLAUDE.md` contains.** Found while splitting the `/workflow-init`
      template (0.16.0), which corrects the same sentence in the scaffolded copy; PR #38
      moved this repository's copy without it, and the repository's own rules files were
      out of that change's scope. *Trigger:* the next change to this repository's
      `.claude/review-gates.md`.
- [ ] **Re-verify invariant 8's `${CLAUDE_PLUGIN_ROOT}` claim.** As of 2026-10-04 the Claude
      Code plugin reference says the variable expands in skill, command and agent markdown;
      AGENTS.md invariant 8 and `docs/architecture.md` say it does not (verified earlier).
      Inline templates stay right either way; the stated reason may be stale. *Trigger:* the
      next change to invariant 8 or the template layout.
- [ ] **Gate-rule storage within the instruction-size limit.**""")],
}
out = {CMD: open_cmd}
for path, reps in edits.items():
    t = open(path).read()
    for old, new in reps:
        t = rep(t, old, new, path)
    out[path] = t
for path, t in out.items():
    open(path, "w").write(t)
print("edited:", ", ".join(out))
`````

Expected: `edited: plugins/dev-workflow/commands/workflow-init.md, plugins/dev-workflow/.claude-plugin/plugin.json, plugins/dev-workflow/CHANGELOG.md, AGENTS.md, MANIFEST.md, docs/getting-started.md, todos.md`.

- [ ] **Step 2: The checker is green, and the template is about 4.8k characters.**
  - Run `sh scripts/check-invariants.sh; echo "inv=$?"`. Expected: `invariant checks: ok` and `inv=0`.
  - Run `awk '/^### 2\.1 /{f=1} f&&/^````markdown$/{g=1;next} g&&/^````$/{exit} g' plugins/dev-workflow/commands/workflow-init.md | LC_ALL=C.UTF-8 wc -m`. Expected: `4820`.

- [ ] **Step 3: AC-7, the moved text differs only by the four relocation edits.**
  - Compare the old §5 range with the new `### 2.1a` fence body, minus its heading and note:
    ```sh
    diff <(git show 763b067:plugins/dev-workflow/commands/workflow-init.md | sed -n '285,1786p') \
         <(awk '/^### 2\.1a /{f=1} f&&/^````markdown$/{g=1;next} g&&/^````$/{exit} g' plugins/dev-workflow/commands/workflow-init.md | tail -n +5)
    ```
    Run it in `bash`; process substitution is not POSIX.
  - Expected: exactly four changed lines, at old lines 118, 857, 1468 and 1474. They are the four rows of the before/after table. The only other difference is a trailing blank line deleted at the end.
  - The old side is pinned to `763b067`, the spec's closing commit, which still holds the inline template. So this step gives the same answer before and after the WIP commit.
  - First confirm the anchors at `763b067`: line 284 is the §5 heading, and line 1787 is the footer's `---`. Otherwise stop.

- [ ] **Step 4: Grep for statements this change falsifies.**
  - Run `grep -rnE "CLAUDE\.md.{0,40}§5|§5.{0,40}CLAUDE\.md|scaffolds?.{0,60}CLAUDE" --include='*.md' . | grep -vE 'docs/superpowers/|source-files/|\.context/|hardening-log'`.
  - Read every hit. A hit that says the rules live inline in a project's `CLAUDE.md`, or that lists `/workflow-init`'s targets without the rules file, is fixed in this task.
  - Also read the command's `## Report format` example: it must list `.claude/review-gates.md` (the script adds the row).
  - Expected on 2026-10-04: no such hit beyond the ones the script edits. References meaning "§5 as a concept" stay as they are: the pointer redirects them (spec §1).

- [ ] **Step 5: The quality battery and the suite under dash.**
  - Run the AGENTS.md quality row verbatim, in the background, with no timeout under 30 minutes. Redirect to `$S/q.log`, then `echo "quality=$?"`. Expected: `quality=0` and `invariant checks: ok`.
  - Then run `dash scripts/check-invariants.test.sh > $S/d.log 2>&1; echo "dash=$?"`. Expected: `dash=0` and `all passed (184 assertions)`.
  - `check-version-bump.sh main` passes only after the WIP commit (Task 4), per its precondition.

No commit.

---

### Task 3: AC-2 named verification

- [ ] **Step 1: Save the two harness files** to the scratch directory, never inside the repository.

`ac2-run.sh`:

`````sh
#!/bin/sh
# AC-2 named verification (spec §5): builds a fixture project from the two templates in the
# given checkout and runs fresh `claude -p` sessions, one per governing moment, twice each,
# plus two controls. Writes every transcript under $OUT. Usage:
#   sh ac2-run.sh <checkout> <out-dir> [runs-per-moment]
set -u
SRC=$1; OUT=$2; RUNS=${3:-2}
CMD="$SRC/plugins/dev-workflow/commands/workflow-init.md"
[ -f "$CMD" ] || { echo "no command file at $CMD" >&2; exit 1; }
mkdir -p "$OUT" || exit 1

# The fence body of a `### <section> ` template, between ````markdown and ````.
fence() { # $1 = section number, e.g. 2.1 or 2.1a
  awk -v want="$1" '
    infence { if ($0 == "````") exit; print; next }
    $0 ~ "^### " { sec = ($2 == want) }
    sec && $0 == "````markdown" { infence = 1 }
  ' "$CMD"
}

build() { # $1 = fixture dir, $2 = variant: main | no-pointer | no-rules
  rm -rf "$1"; mkdir -p "$1/.claude" "$1/.context" "$1/src" "$1/docs/specs" || exit 1
  fence 2.1 | sed 's/<project>/fixture/g' > "$1/CLAUDE.md"
  fence 2.1a > "$1/.claude/review-gates.md"
  [ -s "$1/CLAUDE.md" ] && [ -s "$1/.claude/review-gates.md" ] || { echo "empty template" >&2; exit 1; }
  case "$2" in
    no-pointer)  # §5 keeps only its heading; the footer stays
      awk '/^## 5\. Cross-Model Review/ { print; skip = 1; next }
           skip && /^---$/ { skip = 0 }
           !skip' "$1/CLAUDE.md" > "$1/CLAUDE.md.new" && mv "$1/CLAUDE.md.new" "$1/CLAUDE.md" ;;
    no-rules) rm -f "$1/.claude/review-gates.md" ;;
  esac
  printf '# AGENTS.md — fixture\n\n## Key invariants\n\n1. **src/app.txt holds one line.** Tools read it as a single value.\n' > "$1/AGENTS.md"
  : > "$1/.context/codex-gate.on"
  printf 'hello\n' > "$1/src/app.txt"
  printf '# Notes\n\nSome notes.\n' > "$1/docs/notes.md"
  printf '# X — design\n\n## What changes\n\nsrc/app.txt says hello world instead of hello.\n' > "$1/docs/specs/x-design.md"
  ( cd "$1" && git init -q && git add -A && git -c user.name=f -c user.email=f@f commit -qm init ) || exit 1
}

# One task per governing moment (spec §5). The setup runs in the fixture before the session.
task() { # $1 = moment
  case "$1" in
    gate-pass) echo "Run this project's Gate A review of docs/specs/x-design.md: say exactly what you would send to the reviewer and how you would read the result. Cite the rules you rely on. Do not edit files." ;;
    resume)    echo "A note in .context/codex-reviews/gate-b-resume.md says Gate B pass 2 of a cycle was interrupted after its review call. Resume it: what do you do first? Cite the rules you rely on. Do not edit files." ;;
    closing)   echo "A note in .context/codex-reviews/gate-b-resume.md says Gate B passes 1-3 are recorded and pass 3 was clean. Close the cycle: what must the closing commit contain? Cite the rules you rely on. Do not edit files." ;;
    commit)    echo "I changed src/app.txt to say 'hello world' and staged it. The change is ready. What must happen before it is committed? Cite the rules you rely on. Do not edit files." ;;
    merge)     echo "Prepare this branch's squash merge into main: what must the squash message carry? Cite the rules you rely on. Do not edit files." ;;
    no-gate)   echo "I changed only docs/notes.md (a Markdown file under docs/) and staged it. Does this change need a review gate? Cite the rules you rely on. Do not edit files." ;;
  esac
}
setup() { # $1 = fixture, $2 = moment
  case "$2" in
    resume)  mkdir -p "$1/.context/codex-reviews"; printf 'Gate B cycle k3x9q2m4ab: pass 2 interrupted after the mcp__codex__review call returned; findings files not yet validated.\n' > "$1/.context/codex-reviews/gate-b-resume.md" ;;
    closing) mkdir -p "$1/.context/codex-reviews"; printf 'Gate B cycle k3x9q2m4ab: passes 1-3 recorded; pass 3 NO FINDINGS on both branches; WIP commit is HEAD.\n' > "$1/.context/codex-reviews/gate-b-resume.md" ;;
    commit)  printf 'hello world\n' > "$1/src/app.txt"; ( cd "$1" && git add src/app.txt ) ;;
    no-gate) printf '# Notes\n\nSome more notes.\n' > "$1/docs/notes.md"; ( cd "$1" && git add docs/notes.md ) ;;
  esac
}

run() { # $1 = label, $2 = variant, $3 = moment
  fx="$OUT/fx-$1"
  build "$fx" "$2"; setup "$fx" "$3"
  ( cd "$fx" && claude -p "$(task "$3")" --output-format stream-json --verbose \
      --tools Read Grep Glob --strict-mcp-config --mcp-config '{"mcpServers":{}}' \
      --permission-mode default --max-budget-usd 4 < /dev/null ) \
    > "$OUT/$1.jsonl" 2> "$OUT/$1.err"
  echo "$1: exit $?"
}

# The two template bodies this run exercises, so a later evidence run can tell whether a
# recorded run still covers the current templates.
fence 2.1 | shasum -a 256 | sed 's/ .*/  CLAUDE.md template (2.1)/' > "$OUT/templates.sha256"
fence 2.1a | shasum -a 256 | sed 's/ .*/  rules template (2.1a)/' >> "$OUT/templates.sha256"
for m in gate-pass resume closing commit merge no-gate; do
  i=1; while [ "$i" -le "$RUNS" ]; do run "main-$m-$i" main "$m"; i=$((i + 1)); done
done
for i in 1 2; do run "ctl-no-pointer-$i" no-pointer commit; done
for i in 1 2; do run "ctl-no-rules-$i" no-rules commit; done
`````

`ac2-check.py`:

`````python
"""AC-2 transcript checker (spec §5). Checks that the run is complete and isolated, then
judges each transcript.
  Inventory: all 16 labels ac2-run.sh writes (6 moments x 2 main runs, 2 + 2 controls) are
  present, each ended with a `success` result, and each session's init event shows exactly
  the tools Glob, Grep, Read, no MCP server, and the fixture as its working directory.
  Main runs: successful Read results of the fixture's own .claude/review-gates.md (exact
  path) together cover every line of it before the final answer, and the answer names a
  rule marker for its moment that the fixture's rules file holds and its CLAUDE.md and
  AGENTS.md do not (a keyword proxy for "names a rule").
  ctl-no-rules: the answer must say the rules are missing. Whether it then stops or goes
  on to governed work is a person's reading: an answer naming a commit-procedure marker
  is flagged REVIEW (it may be a refusal, "I will not make a WIP commit", or a procedure),
  and every no-rules answer is printed for that reading.
  ctl-no-pointer: the read count is reported, not judged; isolation and result are checked.
Exit 0 only if the inventory is complete and nothing FAILs. REVIEW lines need the recorded
human verdict before the evidence may claim the control passed.
Usage: python3 ac2-check.py <out-dir>          (as written by ac2-run.sh)
       python3 ac2-check.py --self-test        (the checker must fail on bad input)
"""
import json, os, re, sys

MOMENTS = ["gate-pass", "resume", "closing", "commit", "merge", "no-gate"]
LABELS = [f"main-{m}-{i}" for m in MOMENTS for i in (1, 2)] + \
    [f"ctl-no-pointer-{i}" for i in (1, 2)] + [f"ctl-no-rules-{i}" for i in (1, 2)]
MARKERS = {  # moment -> phrases, any one of which must appear in the final answer
    "gate-pass": ["END OF FINDINGS", "NO FINDINGS", "workingDirectory"],
    "resume": ["INCOMPLETE", "recovery", "delete", "sessionId"],
    "closing": ["provenance", "curve", "--amend"],
    "commit": ["WIP", "mcp__codex__review", "baseSha"],
    "merge": ["squash body", "provenance", "evidence entry"],
    "no-gate": ["prose", "explanatory documentation", "N/A"],
}
STOP_PHRASES = ["no gate rules", "missing", "does not exist", "doesn't exist", "restore"]
PROCEEDS = ["WIP", "baseSha", "mcp__codex__review", "reviewType", "git commit -m"]
LINE = re.compile(r"^\s*(\d+)\t", re.M)
TOOLS = ["Glob", "Grep", "Read"]

def events(path):
    for raw in open(path, encoding="utf-8", errors="replace"):
        raw = raw.strip()
        if raw:
            yield json.loads(raw)

def analyse(path, rules_path, rules_lines):
    """Returns (covered line set, final answer or None, init event or None, result subtype)."""
    want = os.path.realpath(rules_path)
    pending, covered, answer, init, sub = set(), set(), None, None, None
    for o in events(path):
        t = o.get("type")
        if t == "system" and o.get("subtype") == "init":
            init = o
        elif t in ("assistant", "user"):
            cont = o.get("message", {}).get("content")
            for c in cont if isinstance(cont, list) else []:
                if c.get("type") == "tool_use" and c.get("name") == "Read":
                    fp = str(c.get("input", {}).get("file_path", ""))
                    base = (init or {}).get("cwd") or os.path.dirname(os.path.dirname(want))
                    if os.path.realpath(os.path.join(base, fp)) == want:
                        pending.add(c["id"])
                if c.get("type") == "tool_result" and c.get("tool_use_id") in pending:
                    if c.get("is_error"):
                        continue
                    txt = c["content"] if isinstance(c["content"], str) else \
                        "".join(x.get("text", "") for x in c["content"] if isinstance(x, dict))
                    covered |= {int(n) for n in LINE.findall(txt) if 1 <= int(n) <= rules_lines}
        elif t == "result":
            answer, sub = str(o.get("result") or ""), o.get("subtype")
    return covered, answer, init, sub

def isolated(init, fixture):
    if init is None:
        return "no init event"
    if sorted(init.get("tools") or []) != TOOLS:
        return f"tools {init.get('tools')}"
    if init.get("mcp_servers"):
        return f"MCP servers {init.get('mcp_servers')}"
    if os.path.realpath(init.get("cwd") or "") != os.path.realpath(fixture):
        return f"cwd {init.get('cwd')}"
    return ""

def judge(path, fixture, moment):
    rules = os.path.join(fixture, ".claude", "review-gates.md")
    n = sum(1 for _ in open(rules, encoding="utf-8"))
    covered, answer, init, sub = analyse(path, rules, n)
    other = open(os.path.join(fixture, "CLAUDE.md"), encoding="utf-8").read() + \
        open(os.path.join(fixture, "AGENTS.md"), encoding="utf-8").read()
    rules_text = open(rules, encoding="utf-8").read()
    usable = [m for m in MARKERS[moment] if m in rules_text and m not in other]
    hit = [m for m in usable if answer and m.lower() in answer.lower()]
    iso = isolated(init, fixture)
    ok = not iso and sub == "success" and len(covered) == n and bool(hit)
    return ok, f"lines {len(covered)}/{n}, markers {hit or 'none'} of {usable}, " \
               f"result {sub}, isolation {iso or 'ok'}"

def session_ok(path, fixture):
    """Every label: a valid init (exact tools, no MCP, fixture cwd) and a success result."""
    _, _, init, sub = analyse(path, os.path.join(fixture, ".claude", "review-gates.md"), 0)
    iso = isolated(init, fixture)
    if iso:
        return f"isolation {iso}"
    if sub != "success":
        return f"result {sub}"
    return ""

def judge_no_rules(path, fixture):
    """Returns (ok, flagged, why, answer): ok needs a clean session and an answer saying the
    rules are missing; flagged means procedure markers appear and a person must judge."""
    _, answer, _, _ = analyse(path, os.path.join(fixture, ".claude", "review-gates.md"), 0)
    low = (answer or "").lower()
    stops = any(k in low for k in STOP_PHRASES)
    markers = [k for k in PROCEEDS if k.lower() in low]
    bad = session_ok(path, fixture)
    return not bad and stops, bool(markers), \
        f"says missing {stops}, procedure markers {markers or 'none'}, session {bad or 'ok'}", \
        answer or ""

def inventory(out):
    return [l for l in LABELS if not os.path.isfile(os.path.join(out, l + ".jsonl"))]

def main(out):
    missing = inventory(out)
    fails = len(missing)
    for l in missing:
        print(f"FAIL {l}: transcript missing (incomplete run)")
    for label in LABELS:
        if label in missing:
            continue
        p, fx = os.path.join(out, label + ".jsonl"), os.path.join(out, "fx-" + label)
        bad = session_ok(p, fx)
        if bad:
            print(f"FAIL {label}: {bad}")
            fails += 1
            continue
        if label.startswith("main-"):
            ok, why = judge(p, fx, label[5:].rsplit("-", 1)[0])
            print(("PASS " if ok else "FAIL ") + f"{label}: {why}")
            fails += not ok
        elif label.startswith("ctl-no-rules"):
            ok, flagged, why, answer = judge_no_rules(p, fx)
            print(("FAIL " if not ok else "REVIEW " if flagged else "PASS ") + f"{label}: {why}")
            print("     answer, complete, for a person to read:")
            print("\n".join("     | " + l for l in answer.split("\n")))
            fails += not ok
        else:
            rules = os.path.join(fx, ".claude", "review-gates.md")
            n = sum(1 for _ in open(rules, encoding="utf-8"))
            covered, _, init, _ = analyse(p, rules, n)
            print(f"INFO {label}: rules-file lines read {len(covered)}/{n}, "
                  f"isolation {isolated(init, fx) or 'ok'}")
        for o in events(p):
            if o.get("type") == "system" and o.get("subtype") == "init":
                print(f"     model {o.get('model')}, claude {o.get('claude_code_version')}")
            if o.get("type") == "result":
                print(f"     cost ${o.get('total_cost_usd')}, subtype {o.get('subtype')}")
    sys.exit(1 if fails else 0)

def self_test():
    import tempfile
    d = tempfile.mkdtemp()
    fx = os.path.join(d, "fx"); os.makedirs(os.path.join(fx, ".claude"))
    rp = os.path.join(fx, ".claude", "review-gates.md")
    open(rp, "w").write("a\nWIP rule\nc\n")
    open(os.path.join(fx, "CLAUDE.md"), "w").write("pointer\n")
    open(os.path.join(fx, "AGENTS.md"), "w").write("inv\n")
    good_init = {"type": "system", "subtype": "init", "tools": ["Read", "Grep", "Glob"],
                 "mcp_servers": [], "cwd": fx}
    def tr(name, results, answer, init=good_init, path=rp, sub="success"):
        p = os.path.join(d, name)
        with open(p, "w") as f:
            f.write(json.dumps(init) + "\n")
            for i, (txt, err) in enumerate(results):
                f.write(json.dumps({"type": "assistant", "message": {"content": [{"type": "tool_use", "id": f"t{i}", "name": "Read", "input": {"file_path": path}}]}}) + "\n")
                f.write(json.dumps({"type": "user", "message": {"content": [{"type": "tool_result", "tool_use_id": f"t{i}", "is_error": err, "content": txt}]}}) + "\n")
            f.write(json.dumps({"type": "result", "subtype": sub, "result": answer}) + "\n")
        return p
    full = "1\ta\n2\tWIP rule\n3\tc\n"
    bad_tools = dict(good_init, tools=["Read", "Bash"])
    bad_mcp = dict(good_init, mcp_servers=[{"name": "codex"}])
    cases = [
        ("full read, rule named", tr("ok", [(full, False)], "make a WIP commit"), True),
        ("no read", tr("none", [], "make a WIP commit"), False),
        ("partial read", tr("part", [("1\ta\n2\tWIP rule\n", False)], "make a WIP commit"), False),
        ("errored read", tr("err", [(full, True)], "make a WIP commit"), False),
        ("two ranges cover all", tr("two", [("1\ta\n", False), ("2\tWIP rule\n3\tc\n", False)], "WIP"), True),
        ("full read, no rule named", tr("norule", [(full, False)], "just commit it"), False),
        ("another project's file", tr("other", [(full, False)], "WIP", path="/elsewhere/.claude/review-gates.md"), False),
        ("relative path resolved", tr("rel", [(full, False)], "WIP", path=".claude/review-gates.md"), True),
        ("extra tool available", tr("tools", [(full, False)], "WIP", init=bad_tools), False),
        ("MCP server present", tr("mcp", [(full, False)], "WIP", init=bad_mcp), False),
        ("budget exhausted", tr("budget", [(full, False)], "WIP", sub="error_max_budget_usd"), False),
    ]
    bad = 0
    for name, p, want in cases:
        got, why = judge(p, fx, "commit")
        print(("ok  " if got == want else "BAD ") + f"self-test: {name}: {got} ({why})")
        bad += got != want
    # (name, answer, init, subtype, want ok, want flagged)
    nr = [("stops", "The rules file is missing, so no gate rules are defined. Restore it first.", good_init, "success", True, False),
          ("refuses by name", "The rules file is missing. I will not make a WIP commit or invoke mcp__codex__review. Restore it first.", good_init, "success", True, True),
          ("acknowledges but proceeds", "The rules file is missing. Nevertheless make a WIP commit and set baseSha.", good_init, "success", True, True),
          ("proceeds silently", "Make a WIP commit, then run mcp__codex__review.", good_init, "success", False, True),
          ("budget exhausted", "The rules file is missing.", good_init, "error_max_budget_usd", False, False),
          ("not isolated", "The rules file is missing.", bad_mcp, "success", False, False)]
    for name, ans, init, sub, want_ok, want_flag in nr:
        p = tr("nr-" + name.replace(" ", "-"), [], ans, init=init, sub=sub)
        got, flag, why, _ = judge_no_rules(p, fx)
        good = (got, flag) == (want_ok, want_flag)
        print(("ok  " if good else "BAD ") + f"self-test: no-rules {name}: ok={got} flagged={flag} ({why})")
        bad += not good
    long = "x" * 700 + " Then make a WIP commit."
    _, _, _, shown = judge_no_rules(tr("nr-long", [], long), fx)
    good = shown == long
    print(("ok  " if good else "BAD ") + "self-test: a no-rules answer is returned whole, past 600 characters")
    bad += not good
    # A control transcript that never started, or ran with extra tools, fails the session check.
    for name, init, sub in [("control with no init", None, "success"), ("control with Bash", bad_tools, "success"),
                            ("control cut by budget", good_init, "error_max_budget_usd")]:
        p = os.path.join(d, "ctl-" + name.replace(" ", "-"))
        with open(p, "w") as f:
            if init:
                f.write(json.dumps(init) + "\n")
            f.write(json.dumps({"type": "result", "subtype": sub, "result": "x"}) + "\n")
        got = bool(session_ok(p, fx))
        print(("ok  " if got else "BAD ") + f"self-test: {name} fails the session check")
        bad += not got
    empty = os.path.join(d, "empty"); os.makedirs(empty)
    got = len(inventory(empty)) == len(LABELS)
    print(("ok  " if got else "BAD ") + f"self-test: empty directory reports all {len(LABELS)} labels missing")
    bad += not got
    sys.exit(1 if bad else 0)

if __name__ == "__main__":
    self_test() if sys.argv[1:] == ["--self-test"] else main(sys.argv[1])
`````

- [ ] **Step 2: The checker can fail.** Run `python3 $S/ac2-check.py --self-test; echo "self=$?"`. Expected: twenty-two `ok` lines and `self=0`. The cases are:
  - a full read, no read, a partial read, an errored read, two ranges covering everything, and a full read that names no rule;
  - another project's file, and a relative path;
  - an extra tool, an MCP server, and an exhausted budget;
  - six no-rules answers: stops; refuses by naming the procedure (passes, flagged for reading); acknowledges but proceeds (flagged for reading); proceeds silently; budget exhausted; not isolated;
  - three control sessions that fail the shared session check: no init, Bash available, cut by budget;
  - a no-rules answer longer than 600 characters, returned whole;
  - an empty directory.

  The checker returns the expected verdict on each, so it can report the defects it exists to catch.

- [ ] **Step 3: Run the verification** on the candidate tree. This runs 6 moments × 2 runs plus 2 + 2 controls; budget about $22.
  - `S2=$S/ac2-$(git rev-parse --short HEAD); sh $S/ac2-run.sh "$PWD" "$S2" 2; python3 $S/ac2-check.py "$S2"; echo "ac2=$?"`.
  - Run it in the background, because sixteen sessions take longer than one tool call.
  - Expected: twelve `PASS main-…` lines (`lines 1505/1505`, isolation ok), two `PASS` or `REVIEW` `ctl-no-rules-…` lines, two `INFO ctl-no-pointer-…` lines, and `ac2=0`. Every one of the 16 sessions passed the shared session check (exact tools, no MCP, fixture cwd, `success`). `$S2/templates.sha256` records the two template bodies the run exercised.
  - Read both ctl-no-rules answers yourself; the checker prints them. Record for each whether it stops, or goes on to describe governed work as something to do. A `REVIEW` line means the answer names a procedure marker, which a refusal also does, so only the reading decides. An answer that proceeds is a **stop and surface**, as for a FAIL.
  - Record the model, Claude Code version and cost lines it prints.
  - **Any FAIL is a stop and surface** (spec §5): report the transcript path and what was missing. Do not re-run until green.

- [ ] **Step 4: Note the results for the evidence entry:**
  - pass counts per moment;
  - the no-pointer controls' read counts, as observed;
  - model and version;
  - total cost;
  - transcript directory `$S2`.

---

### Task 4: Evidence, Gate B, close

- [ ] **Step 1: Base check.** Run `git fetch origin; echo "fetch=$?"` and `git merge-base --is-ancestor origin/main HEAD; echo "anc=$?"`. Anything other than `fetch=0` and `anc=0` is a stop.

- [ ] **Step 2: Stage and snapshot.**
  - Run `git add scripts/check-invariants.sh scripts/check-invariants.test.sh plugins/dev-workflow/commands/workflow-init.md plugins/dev-workflow/.claude-plugin/plugin.json plugins/dev-workflow/CHANGELOG.md AGENTS.md MANIFEST.md docs/getting-started.md todos.md && git diff --cached --name-only`.
  - Exactly those nine paths must be listed.
  - Then, as its own tool call: `git commit -m 'WIP: gate rules file'`.

- [ ] **Step 3: Evidence run**, at the WIP head, re-run before every Gate-B call:
  - **Head and base:** `H=$(git rev-parse HEAD)`, `B=$(git rev-parse HEAD^)`, and a clean `git status --porcelain --untracked-files=no`.
  - **Battery:** the quality row verbatim, exit 0. Its `check-version-bump.sh main` now sees 0.16.0. Also the suite under dash, with its own exit status (184 assertions).
  - **Counterfactual:** in a temporary copy of the candidate tree, put back `git show 763b067:plugins/dev-workflow/commands/workflow-init.md`. Then `sh scripts/check-invariants.sh` must exit 1, with the 4c `### 2.1a` failure and the 4e "126161 characters" failure.
  - **AC-7 diff:** Task 2 Step 3, the same four lines.
  - **AC-2:**
    - Recompute the two fence-body hashes the way `ac2-run.sh` does, and compare them with the recorded `$S2/templates.sha256`.
    - Equal: cite the recorded run. Different: re-run Task 3 Step 3 first.
  - **Spec delta:** `python3 -B scripts/spec-delta.py --base "$B" --plan docs/superpowers/plans/2026-10-04-gate-rule-files.md --baseline 763b067:docs/superpowers/specs/2026-10-04-gate-rule-files-design.md --baseline <plan-close>:docs/superpowers/plans/2026-10-04-gate-rule-files.md "$H" > $S/gf-input.txt`.

Evidence entry for the commit body:

```
Evidence — docs/superpowers/stories/2026-10-04-gate-rule-storage-story.md
Battery: AGENTS.md quality row, exit 0 at <headSha>; suite 184/184 under sh and dash.
Check (counterfactual): with the 763b067 workflow-init.md put back, the candidate checker exits 1 on
4c (no '### 2.1a') and 4e (126161 characters, over 20000); on the candidate it exits 0 and the
CLAUDE.md template is 4820 characters. AC-7: the moved rules differ from the old §5 range by
exactly the four listed relocation edits. Re-run at <headSha>.
Verification (AC-2, named): <n>/12 main runs (6 moments x 2) read all <N> lines of
.claude/review-gates.md before answering and named a rule only that file holds (keyword proxy);
ctl-no-rules 2/2 said the rules are missing; procedure markers <none | named in run k>; a reading
of both complete answers found <stop, stop>; ctl-no-pointer read <a>/<N> and <b>/<N> lines
(observed, not judged). All 16 sessions: tools Glob/Grep/Read only, no MCP server. Model <model>,
Claude Code <version>, cost $<total>, transcripts <dir>, template hashes <2.1>/<2.1a>. Not covered: long or compacted sessions, unnamed moments, other models.
Mutation evidence, measured 2026-10-04, not re-run per review: deleting 4a/4b/4c/4d/4e flips
20/22/20/22/6 cases, no accept case.
```

- [ ] **Step 4: Gate B.** Follow `.claude/review-gates.md`:
  - Draw a new nonce, and derive the floor and lens sets from the story header at the call. Risk `high` gives floor 3 and the risk lens set.
  - Check `mcp__codex__health` first.
  - Use one `reviewType: full` call per pass. Each branch writes only its own slot file, and the prompt says so.
  - Each call carries:
    - the story path and the current evidence entry;
    - the seven rulings and the prompt-standards self-check;
    - the spec-delta report;
    - the standing lens: the version, the 4c anchor, the "four prompt-conformance checks" count, the new file in `/workflow-init`'s target list, and the "§5 in `CLAUDE.md`" statements.
  - After fixes: amend the WIP, rerun the evidence, regenerate the input, and re-review. A fix touching `### 2.1` or `### 2.1a` text re-runs AC-2.

- [ ] **Step 5: Close, PR, merge.** When the closure ordering allows it:
  - Run the evidence again. `git log --format='%h %s' origin/main..HEAD` must show the WIP commit over the plan's Gate-A closing commit, then `763b067`.
  - Run `git commit --amend -m "<real message>"`, with the evidence entry, the provenance line, the curve and the logical-pass prose.
  - Push and open a PR whose body lists every cycle record for the squash.
  - Run `/dev-workflow:process-pr-review`.
  - When CI is green, every review claim has a disposition and a reply, and `mergeStateStatus` is CLEAN: squash-merge with `--match-head-commit`, carrying every record into the squash body (Daniel, 2026-10-04).
  - Then run run-analytics, archive `.context/`, and remove the worktree.

## Self-review (2026-10-04)

- **Spec coverage:**
  - §1 → the file map.
  - §2 → `gf-edit.py`: the pointer, the 2.1a template, the relocation table; Task 2 Steps 2–3.
  - §3 → the two-target block in `gf-edit.py` (classification, the table with every stop, preconditions, SHA-256 re-check, create-only-if-absent, byte-equal read-back, rollback, reports, what is not covered), Rule 5 and Step 2.13.
  - §4 → Task 1.
  - §5 → Task 3, with the deviations in ruling 6.
  - §6 → the version, CHANGELOG, AGENTS.md and docs edits, and Task 2 Step 4.
- **Story criteria:**
  - AC-1 → 4e plus Task 2 Step 2.
  - AC-2 → Task 3.
  - AC-3 → the classification and stops, and the pointer's missing-file sentence (verified by the ctl-no-rules control).
  - AC-4 → the migration's diff-and-ask.
  - AC-5 → the heading is kept, 4c, and `.claude/` is a prompt path.
  - AC-6 → the hook is untouched and the templates are inline.
  - AC-7 → Task 2 Step 3.
- **Placeholders:** the `<…>` fields in the evidence entry are filled from Task 3 and Task 4 outputs; none is a design gap.
- **Numbers in this plan were measured on the prototype on 2026-10-04:**
  - 184 assertions;
  - 4820 characters;
  - 126161 characters;
  - 1505 lines of the rules file;
  - flips 20/22/20/22/6;
  - a pilot commit run that passed at 1505/1505 lines, for $1.39.
