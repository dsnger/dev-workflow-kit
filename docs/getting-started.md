# Getting started: what to type, situation by situation

Setup is done ([`setup.md`](setup.md)). Type a skill or command as
`/dev-workflow:<name>`, or describe the situation and Claude invokes the fitting one. The
skills and gates shape how Claude works. Your job is the decision points: answering questions,
approving drafts, judging findings. Every message the hook prints is a reminder, never a
block. What the gates compare, and what each hook message means:
[`reference.md`](reference.md#the-review-gates).

## New feature

1. Type `/dev-workflow:intake <idea or pasted transcript>` (German is fine).
   You see a story draft: problem, outcome, at least three acceptance criteria numbered
   `AC-1`, `AC-2`, ..., the `AGENTS.md` invariants it touches, and a profile proposal.
   The profile is two levels, how risky and how security-relevant, plus the evidence
   you will owe before the diff review. If the idea is too thin, it asks once and waits.
   You answer: confirm or correct the two levels, then approve the draft. It lands as a
   committed file under `docs/superpowers/stories/`.
2. Say "proceed". `superpowers:brainstorming` writes the spec with you: settled
   decisions with reasons, not a wish list. For a third-party library, Claude looks the
   API up in Context7 for the version you pin and names the lookup; when Context7 is
   unavailable or that version is not indexed, the library's own material for that
   version stands in.
3. Gate A starts (Codex reads the spec text). You answer one line:
   `risk standard|high; security none|standard|high; evidence <mode>`. Free text is
   fine; Claude maps it to those values and quotes the mapping back.
   You see Codex findings in `.context/codex-reviews/gate-a-spec-<nonce>-pass-<n>.md`,
   one per line, severity `BLOCKER | MAJOR | MINOR | NIT`. Blockers and Majors get
   fixed and the review runs again. Minors and Nits are collected, not iterated.
   A review normally takes three rounds; a round with no findings may close earlier.
   Hook lines like `⚠ Codex Gate A below floor (1/3)` are the round counter, not an
   error. You answer: which disputed findings stand. A dismissed finding needs a
   one-line reason.
4. If you see `⚠ Codex Gate A: pass cap reached (5/5). STOP and ask the human`, the
   review hit its round limit. You answer `close`, or one of: delete the mechanism the
   findings keep returning to, cut scope, continue. Each of those three names how many
   more rounds it allows, at least one.
5. The review ends with one commit that records it (the closing act). Then
   `superpowers:writing-plans` writes the plan: outcomes, affected parts and test
   situations per step, code left to implementation. Gate A runs on the plan only when
   you confirmed risk `high`.
6. `superpowers:executing-plans` builds it, test first. Then your quality command from
   `AGENTS.md` must be green; the one exception, a load flake in an untouched test, is in
   the [reference](reference.md#the-review-gates). CI runs the same command later.
7. Gate B starts (Codex reads the diff). Claude commits `WIP: <subject>`, then runs two
   Codex calls per round, `spec` and `quality`, on the same base and head. Same round
   limit and stop as in steps 3 and 4. From round 2 on, Codex marks each earlier
   Blocker and Major `fixed`, `not fixed` or `no longer applies`. With the Ponytail
   plugin installed, `ponytail-review` runs once before the first round.
   When the hook's checks pass, a commit attempt shows a line like `✓ Codex Gate B hook
   checks passed (3/3 cycle, 1 on current fingerprint)`: what the hook counted, not
   permission to close. Other states print other lines
   ([reference](reference.md#the-review-gates)).
8. The closing commit gets a normal subject, the review record lines, and a `todos.md`
   row per finding that was accepted but not repaired. Open the PR and continue at
   "PR bot comments".

## Bug or small fix

For a change that stays inside an approved commitment. A change to the commitment
itself goes through `intake` instead.

1. Type `/dev-workflow:ticket <text or path to evidence>`.
   You see a ticket under `docs/superpowers/tickets/` with the commitment it stays
   inside, the evidence, and the brief a coding agent fixes from. A report nobody can
   decide yet lands as `needs-triage`.
2. Type `/dev-workflow:ticket list`.
   You see the `needs-triage`, `needs-info` and `ready` tickets. Only a `ready` ticket
   carries the hand-off for the fix.
3. Type `/dev-workflow:ticket T-<n> in-progress`. It re-checks that the ticket is
   ready and moves it, or sends it back to `needs-info` or `needs-triage`. It does not
   start the fix: ask Claude to implement the brief. Claude first makes the brief's
   feedback loop red, then fixes, then runs your quality command, then Gate B and the
   PR as in "New feature" steps 7 and 8. A fix whose paths are all explanatory Markdown
   under `docs/`, or `README.md`, `MANIFEST.md`, `todos.md`, skips Gate B; `CLAUDE.md`,
   `AGENTS.md` and anything under `.claude/`, `plugins/`, `skills/` or `commands/` are
   prompts and never do.
4. After the closing commit, type `/dev-workflow:ticket T-<n> done <fix commit>`.

## PR bot comments

1. Open the PR. Wait for the bots listed under "wait for" in `docs/pr-review-bots.md`.
2. Type `/dev-workflow:process-pr-review <pr-number>`.
   You see: CI checked first; each bot claim validated against the code, usually by a
   fresh-context `finding-triage` subagent (on a PR that edits instruction files Claude
   checks them itself and says so); a reply on every thread; accepted regressions fixed
   (substantial ones through Gate B again); valid but out-of-scope findings recorded in
   `todos.md`; and a bot named when it left no review on the current head.
3. You answer: every `escalate-to-user` verdict, and every accepted finding that
   contradicts a settled decision.
4. Merge when its close-out reports the PR ready. The condition is the Done section of
   the [command file](../plugins/dev-workflow/commands/process-pr-review.md).

## A finding that keeps coming back

1. Type `/dev-workflow:harden-finding` with the finding, its source (`gate-a`,
   `gate-b`, `bot` or `manual`) and its severity.
   You see: it greps `docs/hardening-log.md` for an earlier occurrence of the same
   class, proposes a lint rule (rung 2) or a test (rung 4), asks when both fit, applies
   it, verifies with your quality command, and logs one row. The cases where it writes
   no row are in the [skill file](../plugins/dev-workflow/skills/harden-finding/SKILL.md).
2. Run it once per `hardening owed` line of a closing commit, as its own change.

## Discuss an idea first

1. In a new chat, type `/dev-workflow:sparring <question>`.
   You see: a read-only investigation, options weighed, an agent's report checked
   against the files, and a bounded prompt for a coding agent.
2. Carry that prompt to the session that does the work. Sparring implements nothing
   and runs no gate.

## The rhythm

Minutes of questions and approval (New feature 1 and 2), a review loop where you mostly
arbitrate (3 to 5), hands-off implementation (6), one more loop (7 and 8), then the PR
close-out. Pausing or leaving the workflow: [`reference.md`](reference.md#opting-out).
