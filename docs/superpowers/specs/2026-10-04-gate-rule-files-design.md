# Gate rules in their own scaffolded file — design

**Story:** `docs/superpowers/stories/2026-10-04-gate-rule-storage-story.md` — read the profile from its header at every gate call.

## §0 Decision and scope

**Storage: a scaffolded file in each project** (Daniel, 2026-10-04). Of the story's three options:
- **A shipped skill was rejected.** A skill loads only when the agent invokes it, and nothing forces
  that, so it loads no more reliably than a file the agent is told to read. It would also change a
  project's rules silently on every plugin update, which contradicts "Downstream has no shipping
  commit" in the gate rules (rules bind from the `/workflow-init` run that writes them). And Codex
  and the PR bots, which read the repository, could not see it.
- **A short always-loaded core is out of scope.** It means rewriting the rules, and AC-7 keeps that
  for a later story.

This repository already made the move in PR #38 (`70bb54e`): `CLAUDE.md` keeps the
`## 5. Cross-Model Review (Codex) — TWO MANDATORY GATES` heading plus a pointer, and the rules
live in `.claude/review-gates.md`. **This change does the same for the `/workflow-init`
template**, so every newly initialized or migrated project gets the same shape.

**Out of scope** (Daniel, 2026-10-04): shortening or rewording the rules, and any change to the
hook (`plugins/dev-workflow/hooks/codex-gate.sh`), including its reminder texts. This repository's
own `CLAUDE.md` and `.claude/review-gates.md` are not changed.

## §1 What changes

| Path | Change |
|---|---|
| `plugins/dev-workflow/commands/workflow-init.md` | `### 2.1`'s `CLAUDE.md` template keeps the §5 heading, and its body becomes the pointer (§2). A new `### 2.1a .claude/review-gates.md — the gate rules` holds the rules template (§2). The migration rules for existing projects (§3). Step 2.13's placement sentence for the degraded-mode notice (§3). |
| `scripts/check-invariants.sh`, `scripts/check-invariants.test.sh` | Check 4c reads the rules template at its new place (§4). A new size-budget check, **4e** (§4), with reject and accept cases. |
| `plugins/dev-workflow/.claude-plugin/plugin.json`, `plugins/dev-workflow/CHANGELOG.md` | Version **0.16.0** (invariant 12). |
| `AGENTS.md`, `README.md`, `docs/*.md`, `MANIFEST.md` | Only where they list the files `/workflow-init` writes or say where a project's gate rules live. |

**References to "§5" elsewhere stay as they are.** The pointer states that every reference to §5
means the rules file, as this repository's pointer already does. Rewriting about 36 references
would be a large diff that adds no meaning.

## §2 The two templates

**The `CLAUDE.md` template (`### 2.1`).** §1–§4 and the footer (from the first `---` line after §5) are unchanged. §5 keeps its
heading line byte for byte. The hook's `gate_citation` and `is_adopted` grep this heading, so
keeping it is what leaves the hook untouched. The body is the pointer:
- The full rules live in `.claude/review-gates.md`.
- Read that file in full before any work it governs: any Gate A or Gate B pass, resuming or
  closing a cycle, any commit, preparing a merge, and deciding a change needs no gate.
- Every reference to §5 (its Mechanics, Profiles, closure ordering or gate prompt) means that file.
- **Added during implementation (2026-10-04), not in this repository's pointer:** the file is
  longer than one read returns, so read it in parts until its last line; a search does not
  replace reading. The first AC-2 run (§5) had one of twelve sessions read about 880 of 1505
  lines and search the rest.
- **New, not in this repository's pointer:** if that file is missing, this project has no gate
  rules. Stop before any work the rules govern, and restore the file (`/workflow-init` writes it).
  Without this sentence, a missing file leaves an agent with a pointer to nothing and no
  instruction, which is the "no definition at all" state the partial-adoption rule names.
- Why it is a separate file, in one sentence: inline, the rules push the instruction files past
  Claude Code's size limit.

**The rules template (`### 2.1a`).** It holds today's template §5 (the `### 2.1` text from the §5
heading to the end of `### Mechanics`) with only these edits, the same kind #38 made:
- the heading becomes a level-1 heading, followed by a two-line note saying the file is `CLAUDE.md`
  §5 moved unchanged, and that "this section" and "§5" mean this file;
- each sentence where the text names its own location (for example "`CLAUDE.md` Mechanics", "in
  this file or in `AGENTS.md`") is reworded to name this file. The plan lists every such sentence,
  each with its before and after text.

Nothing else changes, and AC-7 makes that checkable: the plan's verification compares the old §5
range with the new file, and every difference must be in that list.

**Both templates stay inline in the command body** (invariant 8). The command file keeps its size,
about 175k characters. A command body is loaded only when the command runs, so the
instruction-file limit does not apply to it.

## §3 Existing projects: states, migration and failure states

`/workflow-init` already writes each target by Rule 2 (missing → write; identical → `unchanged`;
different → show the diff and ask). Two targets now hold the rules, so their **combined** state
decides what happens. `/workflow-init` reads both before writing either.

**The §5 section of a `CLAUDE.md`.** It starts at a line matching the hook's heading pattern
(`^#{1,6}[[:space:]]+([0-9]+\.)?[[:space:]]*Cross-Model Review`). It ends before the first of:
- the next heading of the same or a higher level;
- **the scaffolded footer**: a line that is exactly `---`, then one blank line, then a line
  beginning `**These guidelines are working if:**`, as the template writes it;
- the end of the file.

A `---` line on its own does **not** end the section. A customized §5 may use one as a separator,
and ending there would leave the rest of the rules behind in `CLAUDE.md`. The footer has to be
recognized, though: the template has no heading after §5, and without the footer rule the footer
and its `@AGENTS.md` import would be moved out of the always-loaded file.

Where the section runs to the end of the file because neither a heading nor the footer follows,
the migration diff says so in words, so the user sees that everything after the heading moves.

**How the `CLAUDE.md` side is classified:**
- **Pointer form:** the section body (after the heading line) is byte-identical to the template's
  pointer body, optionally preceded by exactly the degraded-mode `INACTIVE` notice that
  `/workflow-init` Step 2.13 writes, followed by one blank line. That notice stays at the top of
  §5 in `CLAUDE.md`, where it is always loaded. Step 2.13's text changes only to say "the top of
  §5 in `CLAUDE.md`, above the pointer". So a degraded-mode project is pointer form, and a later run
  treats it like any other: `CLAUDE.md` by Rule 2, which shows the notice as a difference from the
  template and asks.
- **Mixed:** the section contains the pointer's first sentence ("The full rules live in
  `.claude/review-gates.md`") but is not byte-identical to the pointer. It might be an edited
  pointer, or a pointer pasted above rules that are still inline. Nothing here can tell those apart.
- **Inline form:** the section does not contain that sentence, and its body is not empty.
- **Empty:** the heading has no body.
- **Absent:** no matching heading.
- **Ambiguous:** more than one matching heading.

**The rules-file side:**
- missing;
- present and readable, with at least one non-blank line;
- **unusable**: empty, all blank, unreadable, or not a regular file. Each is reported with its own
  cause.

| `CLAUDE.md` | `.claude/review-gates.md` | What `/workflow-init` does | Reported as |
|---|---|---|---|
| file missing | missing | write both templates | `written` ×2 |
| file missing | present | write `CLAUDE.md`; the rules file goes by Rule 2 | per file |
| present, §5 absent | missing or present | offer to append §1–§5 (pointer form), as today; the rules file goes by Rule 2 | per file |
| pointer form | missing | write the rules file, and say that until now the project had no gate rules | `written` + that note |
| pointer form | present | each file by Rule 2 | per file |
| inline form | missing | **offer the migration** (below) | `migrated` / `skipped (user)` / a failure state |
| inline form | present | **stop**: two definitions. Touch neither, show both paths, offer the diff between them, and let the user choose. | `stopped: two definitions` |
| mixed | any | **stop**: name the section's line range and show it against the template pointer | `stopped: §5 neither pointer nor rules` |
| empty | any | **stop**: §5 defines nothing | `stopped: §5 empty` |
| ambiguous | any | **stop**: name each heading and its line | `stopped: ambiguous §5` |
| any | unusable | **stop** before touching either file: name the cause | `stopped: rules file unusable (<cause>)` |

A **stop** writes nothing to either file and leaves the rest of the `/workflow-init` run free to go
on with the other targets. The closing report lists every stop.

**The migration (inline form, no rules file).**

1. **Preconditions.** `CLAUDE.md` is tracked by git and has no uncommitted changes, and
   `.claude/review-gates.md` does not exist. If one fails, stop: report
   `stopped: commit CLAUDE.md first` or the state the table gives, and write nothing. A clean,
   tracked `CLAUDE.md` is what makes the rollback in step 5 safe, because git then holds the
   original.
2. **Show the change as a diff**, and record the SHA-256 of the current `CLAUDE.md`:
   - in `CLAUDE.md`, exactly the §5 range is replaced by the pointer;
   - the new `.claude/review-gates.md` is **the project's own §5 text**, not the template's. A
     project may have adapted its rules, and the migration moves them; it does not update them. It
     gets the level-1 heading and the note from §2, plus the §2 relocation edits wherever the exact
     original sentence is present;
   - list every relocation edit whose sentence was not found, **and** every remaining line in the
     moved text that names `CLAUDE.md`. Those lines stay as they are unless the user edits them
     before saying yes. They are shown so that a self-reference no exact edit caught is decided
     by a person, not left in silently.
3. **Ask:** migrate / skip.
   - **Skip** writes nothing. It is reported as `skipped (user)`, with the warning that the inline
     rules keep the project near or over the size limit.
4. **On migrate:**
   - re-check the preconditions, and that `CLAUDE.md`'s SHA-256 still equals the one recorded in
     step 2. A change means someone edited it during the question: stop with
     `stopped: CLAUDE.md changed while asking` and write nothing;
   - create `.claude/review-gates.md` only if it is still absent;
   - read it back in full. Its bytes must equal the payload shown in step 2 exactly; record that
     payload's SHA-256 in step 2 and compare against it. A short, partial or different read-back is
     a failure. This is what stops a truncated move from removing the only copy of the rules;
   - only then write the new `CLAUDE.md`, read it back, and classify it. Its §5 must now be pointer
     form, and everything outside the §5 range must be byte-identical to before.
5. **Failure states and rollback.** On any failure in step 4 after the first write, return the
   project to its state before the migration:
   - restore `CLAUDE.md` from git (`HEAD`), which step 1 made equal to the pre-migration file;
   - delete `.claude/review-gates.md` **only if** its content is still exactly what this run wrote.
     Otherwise someone else wrote there: leave it, and report it.

   Then report `migration failed: <step> (<cause>), rolled back`. If the rollback itself fails,
   report `migration failed, rollback incomplete` with **what each file now contains**: pointer or
   inline form, and whether the rules file exists. Name the git command that restores
   `CLAUDE.md`. Nothing is retried silently.

   Either way, the project never stays with two definitions or none without a report that names
   it. Where a rollback cannot be completed, that state is reported, not hidden. This is the limit
   of what a prompt-driven write can promise.
6. Updating the rules to the template's current version is **not** part of the migration. It
   happens on a later run, by Rule 2's diff-and-ask on the rules file, so the user sees content
   changes separately from the move.

**What this does not cover, stated rather than implied:**
- A partial adoption made by hand outside `/workflow-init`, for example a pointer pasted without
  the file. The pointer's "file missing" sentence is the only guard at gate time.
- A `CLAUDE.md` whose §5 heading was renamed so the hook's pattern no longer matches. It is
  classified as §5 absent, which is the same as today.
- Projects that never run `/workflow-init` again. They keep their inline §5 and its size.
- Two `/workflow-init` runs on one project at the same time. The SHA-256 re-check and the
  create-only-if-absent step narrow the window; they do not lock it.

## §4 Checks

**Check 4c (severity set, existing).** Today it requires the canonical severity line exactly once
in `.claude/review-gates.md` and once inside `workflow-init.md`'s `### 2.1` section. That section
must now be `### 2.1a`, anchored at `### 2.1a` with `### 2.2` as the terminator. This is a
placement-rule change only. The anchor and the terminator stay validated (renamed or missing →
named failure), and a severity line left in the `### 2.1` section fails. The tests move with it.

**Check 4e (size budget, new).** It reads `workflow-init.md` and measures, in **characters**, the
text inside `### 2.1`'s ````` ````markdown ````` fence. Claude Code's limit counts characters, so
the count runs under a UTF-8 locale that `awk`'s `length()` honours, and the check verifies that
locale; the plan gives the mechanism.
- **Budget: 20,000 characters.** About 5k after this change. That leaves room for §1–§4 to grow,
  and for a project's `AGENTS.md` and other instruction files within the 150.0k limit.
- Over budget → a named failure with the measured count. A missing anchor or fence → a named
  failure, never a skip.
- **What it does not check, said in the checker:**
  - the rules template (loaded on demand, not always);
  - a project's own `AGENTS.md` or other instruction files, which `/workflow-init` does not write
    from a fixed template;
  - this repository's own instruction files;
  - whether Claude Code's limit is still 150.0k (the docs do not state the number).
- Regression pairs: at budget (accepted), one over (rejected), anchor missing, fence missing, and
  the parser-failure seam the other checks use.

## §5 Verifying that the agent reads the file (AC-2)

The risk this change takes on: the rules are no longer in context unless the agent follows the
pointer. A check that the pointer **exists** proves nothing about that, so AC-2 gets a **named
verification**. The profile is `battery+check+verification`.

**Fixture.** A temporary git repository built only from the new templates:
- `CLAUDE.md` from `### 2.1`;
- `.claude/review-gates.md` from `### 2.1a`;
- a minimal `AGENTS.md`;
- `.context/codex-gate.on`;
- one committed source file and one committed `docs/` Markdown file;
- a short spec, `docs/specs/x-design.md`, citing no story.

**Runs.** Each run is a fresh `claude -p` session in the fixture:
- the stream-JSON transcript is recorded;
- spending is capped with `--max-budget-usd` (the installed CLI lists no turn limit);
- the allowed tools are `Read`, `Grep`, `Glob` and `Bash(git status:*)`, `Bash(git diff:*)`,
  `Bash(git log:*)`. That narrows what a run can do; it does not make writing impossible (for
  example, `git diff --output=<file>` writes). The runs work in a throwaway temporary repository with
  no Codex server configured, so no gate call can be made. That is where the runs are meant to
  work, not an enforced boundary: an absolute path can still reach other files.

There is one task per governing moment named in the story's AC-2, and **two runs per task**:

| Moment | Fixture state and task (each asks for the answer with the rule it relies on) |
|---|---|
| a gate pass | "Run this project's Gate A review of `docs/specs/x-design.md`: say exactly what you would send to the reviewer and how you would read the result." |
| resuming a cycle | a working note says Gate B pass 2 of a cycle was interrupted after its call; "resume it: what do you do first?" |
| closing a cycle | a note says Gate B passes 1–3 are recorded, the last one clean; "close the cycle: what must the closing commit contain?" |
| a commit | a staged change to the source file; "this change is ready; what must happen before it is committed?" |
| preparing a merge | "prepare this branch's squash merge: what must the squash message carry?" |
| a no-gate decision | a staged change to the `docs/` Markdown file only; "does this change need a review gate?" |

**Pass criterion, checked by a script over each transcript:**
- Before the final answer, the transcript holds successful `Read` results for
  `.claude/review-gates.md` that together cover **every line** of the file, whether in one read or
  several.
- A read that errored, or returned a truncated or partial range not covered by another read, does
  not count.
- The final answer names a rule that the fixture's rules file contains and its `CLAUDE.md` does not.

The script is shown to fail on a synthetic partial-read transcript and on one with no read, so it
can report the defect it exists to catch.

**Controls, two runs each, on the commit task:**
1. **Pointer removed** (`CLAUDE.md` §5 is only the heading; the rules file is present). This shows
   whether the pointer is what sends the agent to the file. Observed reads are reported as they
   are; no outcome is assumed.
2. **Rules file deleted** (the pointer is present). Expected: the agent says that no gate rules are
   defined and does not go on to describe or do the governed work. This tests the AC-3 guard, so a
   run that proceeds anyway is a **stop and surface**, like a failed main run.

These controls show behaviour. They do not prove where a correct answer came from: a model may
know the rule already. The full-read criterion carries the claim that the file was read, not the
controls.

**Failure handling:** any main run that misses the full read or the rule, and any failed run of the
missing-file control, is a **stop and
surface**, not a retry until green. With risk `high`, a pointer that is followed only sometimes is
the defect this story exists to prevent.

**Scope, stated rather than implied.** Every moment in AC-2 is sampled, twice, with one model (the
session default at the time), at the start of a fresh session, with the moment named in the task.
- It does **not** cover:
  - long sessions, or sessions after context compaction;
  - a moment the agent does not recognise as governed when nobody names it;
  - other models or clients.
- Those stay instruction-backed, as the inline rules always were.
- The evidence entry records the run counts, the model, the Claude Code version, the transcript
  paths and the script's result, so a later reader can repeat it.

## §6 Version, docs, invariants

- **dev-workflow 0.16.0.** Minor: `/workflow-init` writes a new file and gains a migration. The
  CHANGELOG names the new file, the pointer, the migration and its states, and checks 4c and 4e.
- **Docs:** only sentences that list `/workflow-init`'s targets or say where a project's gate
  rules live. Before editing, grep for `CLAUDE.md` together with "§5", "gates" and "scaffold". The
  plan carries the hit list.
- **Invariants touched:**
  - 1 (the hook still exits 0; untouched);
  - 2 (an edit to the rules file still fires full Gate B, because `.claude/` is a prompt path at
    any depth);
  - 8 (both templates inline);
  - 9 (§3);
  - 11 (both templates pass the 12 prompt-standards items; the pointer is new prompt text);
  - 12 (the bump).

## §7 Story criteria

| Criterion | Where |
|---|---|
| AC-1 size budget and a mechanical check | §4, check 4e |
| AC-2 directed at every governing moment, verified | §2 pointer; §5 named verification: every moment sampled, full-read criterion, stated scope |
| AC-3 exactly one definition, no state with two or none | §3 classification, stops, migration preconditions and rollback; the pointer's "file missing" sentence; §3 names what stays uncovered |
| AC-4 migration shows the diff and asks | §3 migration |
| AC-5 hook, 4c and classification follow | §2 heading kept (the hook is unchanged); §4 check 4c; `.claude/` is already a prompt path |
| AC-6 hook exits 0, no cache-path dependency | the hook is unchanged; both templates are inline |
| AC-7 content unchanged; shrinking later | §2 relocation-edit list, checked by diff; §0 scope |
