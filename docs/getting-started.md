# Getting started — your first story, step by step

One small feature (a CSV export for invoices) through the whole workflow. Setup is
assumed — see the README if not.

Up front: you don't operate the workflow like a machine. You talk to Claude
normally; the skills and gates structure *how Claude works*, and the hook reminds
both of you when a gate isn't satisfied. Your job is the decision points —
answering questions, approving drafts, judging findings.

**1. Capture the idea.** Say "users want to export their invoices as CSV" (or paste
a voice transcript — German is fine). The `intake` skill turns it into a story:
problem, outcome, ≥3 checkable acceptance criteria, which `AGENTS.md` invariants it
touches. Too thin → it asks once and waits; it refuses to invent what you didn't
say. You approve the draft (the criteria are what "done" will mean), and it lands
as a committed file under `docs/superpowers/stories/`.

**2. Design.** Proceed with the story (intake names the exact next step).
`superpowers:brainstorming` explores approaches with you; the output is a **spec** —
settled decisions with rationale, not a wish list.

**3. Gate A on the spec.** Claude sends the spec text to Codex
(`mcp__codex__exec`) — a different model family, so it doesn't share Claude's blind
spots. Blocker/Major findings get fixed, the review reruns on the revised spec:
three passes minimum, final pass clean — the one early exit is a pass that comes
back with zero findings. Hook messages like `⚠ Codex Gate A below floor (1/3)` are
the counter, not an error. Your job: arbitrate disputed findings — Codex is
advisory, and a dismissed finding needs a one-line reason.

**4. Plan, and Gate A again.** `superpowers:writing-plans` turns the spec into a
task-by-task plan (each task starts with a failing test); the same 3-pass loop runs
on the plan. A flaw caught here never reaches code.

**5. Implement.** `superpowers:executing-plans` works through the plan, test-first,
progress claims backed by test runs. If the Gate-A floor wasn't met, the hook says
so right when execution starts.

**6. Quality battery.** The one command you wired at init (typecheck + lint + dead
code + duplication + tests) must be green locally. CI runs the same command, so
skipping locally only postpones the red.

**7. Gate B on the diff.** Claude makes a `WIP:`-prefixed commit (gives Codex a
range to read; the hook knows WIP doesn't end the cycle), then loops
`mcp__codex__review` the same way: three passes, final clean. Verification is by
**content** — any file change after the last review, even from a formatter, flips
it back to unsatisfied (staging counts too: the fingerprint covers the index, because
that is what a commit carries, as of the hook's invocation). On
`✓ Codex Gate B satisfied (3/3 cycle, 3 on current code)`, the real commit replaces
the WIP via `git commit --amend`.

**8. PR and bots.** Open the PR as usual; once the bots have commented, run
`/dev-workflow:process-pr-review`. Every comment is validated against code and
invariants — usually by a fresh-context `dev-workflow:finding-triage` subagent per claim,
so the agent that formed a belief is not the one grading it; on a PR that edits
instruction files the command checks them itself instead, and says so. Triage judges only
whether a claim is *true*; the command then decides separately whether fixing it belongs
in this PR. Each comment is answered on the thread, and, if accepted and actionable, fixed (substantial fixes go through Gate B
again). Nothing silently ignored, nothing blindly applied.

**9. Close the class, not the instance.** Any finding from steps 3, 7, or 8 that
could recur: run `harden-finding`. It becomes the strongest durable guard that
fits — lint rule, type constraint, test, or documented convention — plus one row in
`docs/hardening-log.md`. A recurring class escalates one rung harder, so the
workflow gets stricter exactly where your project actually fails.

## In practice

The rhythm: minutes of questions and approval (1–2), two review loops where you
mostly arbitrate (3–4), hands-off implementation (5–6), one more loop (7), PR
close-out (8–9). Trivial changes skip the ceremony — the caution bias is for
non-trivial work, judgment is allowed. Two knobs: `.context/codex-gate.floor` (any
positive integer) moves the 3-pass floor, and `touch .context/codex-gate.off`
silences the reminders in a scratch workspace (delete to re-enable; state keeps
tracking while off, so nothing goes stale).

The hook is installed once per machine but speaks only in projects you initialized —
everywhere else it stays quiet, so nothing above happens in a repo where you never ran
`/workflow-init`. If a project of yours goes unexpectedly silent, that's the first
thing to check: the gates need `.context/codex-gate.on` or §5 in its `CLAUDE.md`.

## Opting out

The workflow is opt-in per project, and leaving it has clean levels — pick the
smallest that matches your intent:

1. **Don't adopt:** never run `/workflow-init` in a project → the plugin does
   nothing there.
2. **One trivial change:** just commit — the hook warns, it never blocks, and §5
   explicitly leaves trivial changes to your judgment.
3. **Pause a project:** `touch .context/codex-gate.off` (delete to re-enable;
   state keeps tracking, so nothing goes stale).
4. **Leave for good:** remove §5 from the project's `CLAUDE.md` (and
   `.context/codex-gate.on`) — the project reads as not adopted again. The other
   scaffolds (ledger, CI, `AGENTS.md`) work fine without the gates.
5. **Machine-wide:** `claude plugin disable dev-workflow`.

One honest rule of thumb: if `.off` stays in a project for weeks, level 4 is the
truthful choice. A project officially without gates beats one that has them and
ignores them.
