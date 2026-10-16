# Getting started — your first story, step by step

One small feature (a CSV export for invoices) through the whole workflow. Setup is
assumed — see [`setup.md`](setup.md) if not. A bug or small improvement inside an
approved commitment does not start here: `/dev-workflow:ticket <text or evidence>` writes
a ticket file with the brief, and the fix then joins at step 5.

Up front: you don't operate the workflow like a machine. You talk to Claude
normally; the skills and gates structure *how Claude works*, and the hook reminds
both of you what it has and has not seen of the gates. Your job is the decision points —
answering questions, approving drafts, judging findings.

**1. Capture the idea.** Say "users want to export their invoices as CSV" (or paste
a voice transcript — German is fine). The `intake` skill turns it into a story:
problem, outcome, ≥3 checkable acceptance criteria (numbered `AC-1`, `AC-2`, … so later
steps can cite them), which `AGENTS.md` invariants it
touches, and a **profile** — how risky this is (`trivial|standard|high`), how
security-relevant (`none|standard|high`), and the validation mode derived from the two.
It proposes both axes and the derived mode with a reason; you confirm or correct the
axes, and any change to the mode is an override that carries its own reason and is
logged. The derived mode decides what evidence you owe before Gate B, and the levels
**accumulate**: `battery` (green), `battery+check` (a check that fails without the
change), `battery+check+verification` (a named verification of the risk path on top of
both), and at security `high` `+abuse-path` — a named abuse scenario and evidence that
the control rejects or contains it. Too thin → it asks once and waits; it refuses to
invent what you didn't say. You approve the draft (the criteria are what "done" will
mean), and it lands as a committed file under `docs/superpowers/stories/`.

**2. Design.** Proceed with the story (intake names the exact next step).
`superpowers:brainstorming` explores approaches with you; the output is a **spec** —
settled decisions with rationale, not a wish list. Where the spec uses a third-party
library API, Claude looks that API up in Context7 for the version your manifest pins and
names the lookup; when Context7 is unavailable or that version is not indexed, the
library's own material for that version stands in, and a spec with neither is a Gate-A
finding.

**3. Gate A on the spec.** First you confirm one profile line — `risk standard|high;
security none|standard|high; evidence <mode>`; a free-text answer is mapped to the nearest
closed values, the stricter where two fit, and the mapping is recorded with your quote.
Then Claude sends the spec text to Codex (`mcp__codex__exec`) — a different model
family, so it doesn't share Claude's blind spots. Codex writes one finding per line to
`.context/codex-reviews/gate-a-spec-<nonce>-pass-<n>.md`, severity `BLOCKER | MAJOR |
MINOR | NIT`. Blocker/Major findings get fixed and the review reruns; Minors and Nits are
collected, never iterated. The floor is three valid passes, a pass with zero findings may
close earlier, and the cap is the floor plus two: there the hook prints `⚠ Codex Gate A:
pass cap reached (5/5). STOP and ask the human`, and you answer `close`, or one of
delete the mechanism the findings keep returning to / cut scope / continue — each naming
how many further passes it allows, at least one, and the loop resumes on the artifact
as the answer leaves it; `.context/codex-gate.cap-extra` holds the **total** allowance
beyond the base cap, so a second answer adds to the number already there. A clean pass at the
floor, or a cap answer of `close`, runs the **closing act** — one commit carrying the
cycle's record lines. Planning starts after that act. Hook messages like `⚠ Codex Gate A
below floor (1/3)` are the counter, not an error. Your job: arbitrate disputed findings —
Codex is advisory, and a dismissed finding needs a one-line reason.

**4. Plan.** `superpowers:writing-plans` turns the spec into a task-by-task plan —
outcomes, affected parts, settled decisions and test situations per step, with the code
left to implementation (`CLAUDE.md` §4). Gate A runs on the plan only when the confirmed
risk is `high`; then the same loop runs on it and ends with its own closing act before
execution starts.

**5. Implement.** `superpowers:executing-plans` works through the plan, test-first,
progress claims backed by test runs. If the hook's own threshold wasn't met, it says
so right when execution starts.

**6. Quality battery.** The one command you wired at init (typecheck + lint + dead
code + duplication + tests) must be green locally. CI runs the same command, so
skipping locally only postpones the red.

**7. Gate B on the diff.** With the Ponytail plugin installed, `ponytail-review` runs
once on the branch diff first, so Codex reads a diff with the obvious cuts made (not a
gate, not a pass; skipped without the plugin). Claude makes a plain
`git commit -m 'WIP: <subject>'` (gives Codex a range to read; the hook keeps the cycle
open across a commit it recognises as WIP), then loops `mcp__codex__review` as two calls
per pass, `reviewType: spec` then `quality`, on the same `baseSha` and `headSha`: floor
three, cap and stop as in step 3. From pass 2 on, each call lists the earlier passes'
Blockers and Majors and Codex marks each `fixed | not fixed | no longer applies`, a
`not fixed` counting as a finding again; the `spec` call maps each acceptance criterion
to the test asserting it, or `none`, and reports a test that cannot fail. Invalidation is by
**content** — any change to included content present when the hook runs, even from a
formatter, makes the hook report that it cannot confirm the reviewed content. What that proves is bounded, and the hook's own
source says so: the current fingerprint matches the one recorded on a credited pass, which
is not evidence that Codex read those bytes; `.context/` and untracked ignored paths are
excluded, and staging counts, because the fingerprint covers the index and that is what
a commit carries. The message
`✓ Codex Gate B hook checks passed (<counted>/<threshold> cycle, <fresh> on current fingerprint)` carries three different numbers: the passes the hook credited this cycle — one per `full` call or per `spec` + `quality` pair on the same `baseSha` and `headSha` — the hook's own reminder threshold, and the **consecutive** credited passes on the current fingerprint since it last changed. The first is not the calls you made: a single branch counts only together with its partner, and the hook withholds credit for a recognized failure envelope, the backgrounding notice, a result it can get no text from, and a request it cannot read or pair. The third is a streak, not a tally — the hook keeps the last fingerprint and that streak, so a pass on a changed fingerprint restarts it and an earlier matching pass separated by a different fingerprint is not counted. None of the three is the floor §5 obliges, and the message is what the hook checked, not
permission to close: a clean pass at the floor (or a zero-finding pass, or a cap answer
of `close`) runs the closing act — one final commit with a non-WIP subject carrying the
cycle lines, the ledger-check records, and a `todos.md` row per finding dispositioned
`accepted, not repaired`, so no follow-up is lost at the close.

**8. PR and bots.** Open the PR as usual; once the bots have commented, run
`/dev-workflow:process-pr-review`. Every comment is validated against code and
invariants — usually by a fresh-context `dev-workflow:finding-triage` subagent per claim,
so the agent that formed a belief is not the one grading it; on a PR that edits
instruction files the command checks them itself instead, and says so. Triage judges only
whether a claim is *true*; the command then decides separately whether fixing it belongs
in this PR. Each comment is answered on the thread, and, if accepted and actionable, fixed (substantial fixes go through Gate B
again). Nothing silently ignored, nothing blindly applied.

**9. Close the class, not the instance.** Any finding from steps 3, 7, or 8 that
could recur: run `harden-finding`. It becomes the guard that fits — a lint rule
(rung 2) or a test (rung 4) — plus one row in `docs/hardening-log.md`; the cases in
which it writes no row or leaves the obligation open are in the
[skill file](../plugins/dev-workflow/skills/harden-finding/SKILL.md). A gate cycle's
closing commit carries a `ledger check` line and one `hardening owed` line per finding
it owes ([Closing act](../.claude/review-gates.md#closing-act)); run the skill once per
owed line, as its own change. Step 8's bot findings go through `process-pr-review`'s
own ledger check.

## In practice

The rhythm: minutes of questions and approval (1–2), two review loops where you
mostly arbitrate (3–4), hands-off implementation (5–6), one more loop (7), PR
close-out (8–9). Only docs-only commits skip **Gate B** — every staged path explanatory
Markdown under `docs/`, or `README.md`, `MANIFEST.md`, `todos.md`; `CLAUDE.md`,
`AGENTS.md` and anything under `.claude/`, `plugins/`, `skills/` or `commands/` at any
depth are prompts and take the gate, as does a mixed commit; the hook's own
docs-only note is a path heuristic and does not establish that eligibility. The battery is always owed. The
knobs — `.context/codex-gate.floor` moves the hook's reminder threshold,
`touch .context/codex-gate.off` silences the reminders in a scratch workspace (delete to
re-enable; state keeps tracking while off), and the cap files — are listed in
[`setup.md`](setup.md#per-workspace-knobs).

The hook is installed once per machine and speaks only where `.context/codex-gate.on` or
the `Cross-Model Review` §5 heading in `CLAUDE.md` is present
([knobs](setup.md#per-workspace-knobs)). If a project of yours goes unexpectedly silent,
check those two first.

## Opting out

The workflow is opt-in per project, and leaving it has clean levels — pick the
smallest that matches your intent:

1. **Don't adopt:** never run `/workflow-init` in a project, and keep
   `.context/codex-gate.on` and a `Cross-Model Review` §5 heading out of it → the hook
   stays silent there; the skills and commands remain callable by name.
2. **One docs-only change:** the hook warns, it never blocks, and a commit whose every
   staged path is explanatory Markdown under `docs/`, or `README.md`, `MANIFEST.md`,
   `todos.md`, skips Gate B. Any other diff takes it. Gate A is not skippable for a spec.
3. **Pause a project:** `touch .context/codex-gate.off` (delete to re-enable; the
   counters keep their semantics while off, which is not evidence that a review
   happened).
4. **Leave for good:** remove §5 from the project's `CLAUDE.md`, delete
   `.claude/review-gates.md` and `.context/codex-gate.on` — the project reads as not
   adopted again. The other
   scaffolds (ledger, CI, `AGENTS.md`) work fine without the gates.
5. **Machine-wide:** `claude plugin disable dev-workflow`.

One honest rule of thumb: if `.off` stays in a project for weeks, level 4 is the
truthful choice. A project officially without gates beats one that has them and
ignores them.
