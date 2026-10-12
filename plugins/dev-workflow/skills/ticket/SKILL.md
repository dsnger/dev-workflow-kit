---
name: ticket
description: Use when a bug, regression, robustness fix or wording defect arrives that stays inside an approved commitment — it becomes a ticket file that records the evidence, the expected behaviour's source and the commitment, and serves as the brief a coding agent fixes it from. Also `list` for the open tickets and `T-<n> <state>` for a state change. A change that alters an approved commitment is handed to intake instead.
---

# ticket

## Overview

The entrance for work that stays inside what is already approved. A report goes in; a ticket file
comes out at `docs/superpowers/tickets/<YYYY-MM-DD>-T<n>-<slug>.md`, committed on its own. The
ticket is the plan for its fix: it quotes the commitment the fix stays inside, records the
evidence, and carries the brief. It opens no spec and no Gate-A cycle, because the commitment it
stays inside was already reviewed. A change to a commitment is not a ticket: it goes to
`dev-workflow:intake`.

**Done when** one ticket file is committed on its own and its hand-off or questions are printed —
or nothing is written and the intake hand-off is printed.

Target model: Claude via Claude Code.
This skill is a prompt artifact and follows the checklist in `docs/prompt-standards.md`.

**This skill is one file on purpose.** A route file behind a prose pointer is not re-read after
context compaction (finding F7, PR #60), so every step lives here. A single short invocation is less
exposed to compaction than a multi-turn route; that is a reason, not evidence.

## When to use

- A bug, a regression, a robustness gap or a wording defect is reported, and the expected behaviour
  is already written down in a story criterion, a spec section, an `AGENTS.md` invariant or a
  `docs/PRD.md` feature-map row.
- An improvement is requested that stays inside such a commitment.
- `list`: see what is open. `T-<n> <state>`: move a ticket.

Not for new behaviour or a changed commitment (that is `dev-workflow:intake`), and not for hardening
a review finding (that is `dev-workflow:harden-finding`, which keeps owning the finding).

## Invocation

| Form | Does |
|---|---|
| `/dev-workflow:ticket <text>` or `<path to evidence>` | captures a new ticket (Flow) |
| `/dev-workflow:ticket list` | prints the buckets (§ list) |
| `/dev-workflow:ticket T-<n>` | shows that ticket |
| `/dev-workflow:ticket T-<n> <state> [reason or commit]` | changes its state (§ State changes) |

Any other argument shape: stop and ask which form was meant, because guessing would write a file
nobody asked for. A change to a field other than the state is an ordinary edit of the file.

## Flow — a new ticket

Follow in order. Each step says why it exists.

1. **Read the input and the project.** Requires `AGENTS.md` (the invariants); if it is missing, stop
   and offer `/dev-workflow:workflow-init`, since step 2 cannot quote an invariant it cannot read.
   Read the stories, specs and `docs/PRD.md` feature-map rows the input plausibly touches.

2. **Commitment check.** Decide whether the requested change alters an approved commitment —
   behaviour, a contract, a security guarantee or scope — of a story criterion, a spec section, an
   invariant or a feature-map row. Three outcomes:
   - **Inside a commitment:** quote it and its source (path plus `AC-<n>`, `§` or row), continue.
     An improvement that sets no new limit and breaks no commitment stays inside the commitment of
     the feature it improves: quote that feature's criterion. A missing target is a `needs-info`
     question, not a reason to hand off.
   - **Alters a commitment, or none can be quoted:** write nothing, print the hand-off and stop.
     The human starts intake; this skill does not invoke it, as intake leaves its own hand-off to
     the human.
     - changed commitment of a story or spec:
       `/dev-workflow:intake Amend the approved <path>. Decision: <the human decision if the input names one; otherwise "none yet — intake will ask">. <captured text>`
     - new behaviour, or a change to a commitment only a `docs/PRD.md` row carries (intake's
       amendment route amends only a story or spec): `/dev-workflow:intake <captured text>`
   - **The texts cannot decide it:** write the ticket in state `needs-triage` with a filled
     `Decision needed:` line naming the two readings, and ask. No rule decides it, because a guess
     here is a commitment change made without anyone choosing it.

3. **Capture, evidence first.** Fill observed (with its evidence: a command and its output, a log
   line, a failing test, a screenshot path), expected (with its source), repro steps, affected
   feature, severity and first seen (version or commit). Severity is one of
   `blocker|major|minor|nit`: blocker = wrong, unsafe or breaks an invariant; major = a design flaw
   needing rework; minor and nit = below that. A field the input cannot support is written
   `unknown — <reason>`, severity included; take nothing from a similar case, because a filled
   field reads as a fact.

4. **Category and state.** Exactly one category, `bug|regression|improvement|docs`, and exactly one
   state, `needs-triage|needs-info|ready|in-progress|done|wontfix`. The **readiness fields** are
   observed with evidence, expected with its source, the commitment and the severity. A new ticket
   is `ready` when all four are filled, `needs-info` when any is `unknown` (it then lists a question
   for the reporter per unknown field), `needs-triage` when a decision is needed. Repro, feature and
   first seen may stay `unknown` in a `ready` ticket. For an `improvement`, the expected behaviour's
   source is the commitment it stays inside, with the request recorded beside it (who asked,
   where); write no target the input does not state. When no category can be grounded, or the input
   names two categories or two states, ask one question and wait before writing anything — a
   category cannot be left `unknown`.

5. **Brief.** Fix scope; out of scope; the feedback loop that goes red on exactly this defect, as the
   first feasible entry of this ordered list — failing test at the nearest seam, HTTP or CLI script
   with fixture, headless-browser script, replayed captured trace, throwaway harness, property or
   fuzz loop, bisection harness — with one clause on why earlier entries were not feasible and the
   observation that is red before the fix; files to read first (the commitment's story or spec, the
   `AGENTS.md` sections it touches, `docs/TECH-STACK.md` only for a dependency change).

6. **Review header.** A ticket carries no profile of its own: its story holds it. When a story
   stands behind the commitment (directly, or through a spec's `**Story:**` line), write a
   `**Story:**` line: ``**Story:** `docs/superpowers/stories/<file>.md` `` — one backticked path per
   entry, so the fix's Gate-B provenance line can name it. When none does, write the `**No story:**`
   line instead, never a `**Story:**` line holding prose, because the provenance line takes story
   paths, not prose.

7. **Number and path.** `T-<n>` is the highest `n` among `docs/superpowers/tickets/*-T<n>-*.md` in
   the working tree **and** on every local and remote-tracking branch, plus one; `T-1` when there
   are none. Scanning every branch covers the default branch without deciding which one it is:
   list the refs with `git for-each-ref --format='%(refname)' refs/heads refs/remotes`, then run
   `git ls-tree --name-only "$ref" docs/superpowers/tickets/` once per ref, the ref held in a
   quoted variable so no branch name becomes shell text. If the listing or any read fails, stop,
   write nothing and name the failure: a partial scan can hand out a number already taken. A number is never reused; `done` and `wontfix` keep theirs.
   - **Slug** from the title: lowercase; `ä`→`ae`, `ö`→`oe`, `ü`→`ue`, `ß`→`ss`, strip other
     diacritics; replace every non-`[a-z0-9]` run with one hyphen; trim hyphens; cap at 40
     characters at the last whole word (a single longer token is hard-truncated to 40, then
     re-trimmed); an empty result becomes `ticket`.
   - **Path** `docs/superpowers/tickets/<YYYY-MM-DD>-T<n>-<slug>.md`, the local project date.
     Create the folder on the first ticket.
   - **Never overwrite:** if the path exists when you are about to write, stop and name it, because
     it is another ticket's record.
   - The tickets folder is the backlog; no other file records the ticket.

8. **Commit.** If the index already holds staged changes (`git diff --cached --name-only` is
   non-empty), stop and ask, so no unrelated work rides along. Stage only the ticket file by name;
   confirm the staged set is exactly that path and `git show :<path> | diff - <path>` prints
   nothing; otherwise `git restore --staged <path>` and stop. Commit `docs(ticket): T-<n> <slug>`.
   The path is explanatory Markdown under `docs/`, docs-only under the gate rules' "Docs-only
   means…", so this commit owes no Gate B.

9. **Hand off and stop.** A `ready` ticket ends with the build hand-off (§ Hand-off). A
   `needs-info` or `needs-triage` ticket ends with its questions and the line
   `Not ready to build: answer the questions, then /dev-workflow:ticket T-<n> ready` — never with
   the build hand-off, because nobody should start a fix whose target is unknown.

## Ticket template

Write exactly these lines and sections; drop the lines marked "only".

```markdown
# T-<n> — <title>

**Category:** <one> · **State:** <one> · **Severity:** <one | unknown — reason> · **First seen:** <version/commit | unknown — reason>
**Story:** `<story path>`
**No story:** the commitment comes from <source>; the fix's Gate-B provenance line names `none`
**Feature:** <PRD feature-map row, story or spec section | unknown — reason>
**From finding:** <hardening-log row, or SLOT:n with "ledger row: none yet — harden-finding owns it">

## Commitment
"<quoted commitment>" — <source path + AC-n / § / row>
Decision needed: <reading A> / <reading B>

## Observed
<behaviour> — evidence: <command+output | log line | failing test | screenshot path>

## Expected
<behaviour> — source: <path + AC-n / § / row>; requested by: <who, where>

## Repro
1. …

## Brief
- Fix scope: …
- Out of scope: …
- Feedback loop: <entry> — <why earlier entries were not feasible>; red before the fix: <observation>
- Read first: …

## Questions for the reporter
- …

## Log
- <YYYY-MM-DD> · created · <state>
```

Exactly one of `**Story:**` / `**No story:**`. `**From finding:**` only for a ticket raised from a
review finding. `Decision needed:` only in `needs-triage`. `requested by:` only for an
`improvement`. `## Questions for the reporter` only in `needs-info` (and `needs-triage`, holding
the decision question).

**Example** (an invoice PDF service), head of a `ready` bug:

```markdown
# T-7 — Invoice PDF drops the VAT line for reverse-charge customers

**Category:** bug · **State:** ready · **Severity:** blocker · **First seen:** 2.3.0
**Story:** `docs/superpowers/stories/2026-05-02-invoice-pdf-story.md`
**Feature:** invoice PDF, docs/superpowers/stories/2026-05-02-invoice-pdf-story.md AC-4

## Commitment
"Every invoice PDF shows a VAT line, reading 'reverse charge' when no VAT is charged." — docs/superpowers/stories/2026-05-02-invoice-pdf-story.md AC-4
```

## State changes

`/dev-workflow:ticket T-<n> <new state> [reason]` rewrites the `**State:**` value and appends
`- <date> · <state> · <reason or commit>` to `## Log`; `wontfix` and `done` require the reason or
the fix commit. A `wontfix` ticket stays in the folder as the project's out-of-scope record, with
its reason.

**A move into `ready` or `in-progress`, from any state, is a re-capture:** run Flow steps 2–6 on the
ticket as it now stands, answers included, and rewrite it from the result — commitment, readiness
fields, Brief and review header alike. It enters the requested state only if that run would have
made it `ready`; otherwise it takes the state the run gives (`needs-info`, `needs-triage`), and on a
commitment change it becomes `wontfix` with the reason "handed to intake" and the step-2 hand-off is
printed. Why: answers can change the commitment, and a stale brief sends a fix the wrong way.

Every state change is committed as in Flow step 8. A lookup or state change on a `T-<n>` carried by
two files stops and names both paths for a human, who renumbers one and its references.

## list

Read the `**State:**` line of every file in `docs/superpowers/tickets/` and print, in this order:

```text
needs-triage
(none)

needs-info
T-2 · bug · unknown — impact not known · Missing e-mail · docs/superpowers/tickets/2026-06-03-T2-missing-e-mail.md

ready
T-5 · docs · minor · Old size in help text · docs/superpowers/tickets/2026-06-01-T5-old-size-in-help-text.md
```

Each bucket oldest first by the date in the file name, then by `n`; one line per ticket,
`T-<n> · <category> · <severity> · <title> · <path>`; an empty bucket prints `(none)`.
`in-progress`, `done` and `wontfix` are not shown. Add a fourth heading, `needs repair`, only when a
file has a defect, one line each with the path and which defect: the `**State:**` line is missing;
it appears twice; its value is outside the six states; or its `T-<n>` is carried by another file
too. Why: a malformed ticket must stay visible rather than drop out of every bucket. `list` is
read-only; the human repairs the file: one `**State:**` line with one of the six values, or a
renumbering for a shared `T-<n>` (§ State changes).

## Hand-off

For a `ready` ticket, end with the ticket path and this route:

1. `/dev-workflow:ticket T-<n> in-progress`.
2. Make the Brief's feedback loop red on this defect.
3. Fix; the loop goes green; run the project's quality command from `AGENTS.md`.
4. Gate B on the diff per the project's gate rules, the call carrying the ticket path and, when the
   ticket has a `**Story:**` line, that story path; otherwise the call says the ticket has no story
   and the provenance line names `none`.
5. The closing act per the gate rules; then `/dev-workflow:ticket T-<n> done <fix commit>`.

A fix whose staged paths are all docs-only under the gate rules' "Docs-only means…" (explanatory
Markdown under `docs/`, `README.md`, `MANIFEST.md`, `todos.md`) owes no Gate B — say so in those
words. A `docs` ticket whose fix touches a skill, command, template or anything under `plugins/` is
a prompt change and owes Gate B. A
ticket raised from a review finding keeps its ledger link; `harden-finding` owns the finding and
this skill logs no ledger row. This skill does not start the fix.

## Stop and ask

| Situation | Do |
|---|---|
| `AGENTS.md` missing | stop; offer `/dev-workflow:workflow-init` |
| argument shape unknown | ask which form was meant |
| no grounded category, or two categories or states | one question, write nothing |
| change alters a commitment, or none can be quoted | print the intake hand-off, write nothing |
| texts cannot decide the commitment question | `needs-triage` ticket with `Decision needed:` |
| computed path already exists | stop, name it |
| index already holds staged changes | stop and ask |
| staged set or content differs after staging | unstage the ticket, stop |
| `T-<n>` carried by two files (lookup or state change) | stop, name both paths |

## Common mistakes

- A "bug" asking for another file format, a new field or a different limit moves a commitment:
  print the intake hand-off.
- Stage the ticket by name, so unrelated work stays out of its commit.
