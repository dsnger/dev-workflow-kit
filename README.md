# dev-workflow-kit

A Claude Code marketplace with one plugin, `dev-workflow`, that installs a spec-driven
workflow for building software with agents. It adds three mechanisms: two independent
cross-model review gates, a fingerprinted hardening ledger, and repo-enforced quality.

Full setup, step by step: [`docs/setup.md`](docs/setup.md). One feature through every
step: [`docs/getting-started.md`](docs/getting-started.md).

## What it does

- **Two independent review gates.** A *different model* than the author reviews the
  design before it becomes code (Gate A) and the diff before it lands (Gate B).
- **A fingerprinted hardening ledger.** A finding you run through `harden-finding` is
  mapped to a class and checked against `docs/hardening-log.md`, so a recurrence is a
  grep away — and it is hardened with a lint rule or a test, each landed hardening one
  row. A finding an existing required check already catches gets no row; one blocked by
  a prerequisite is logged `pending` and stays open; one that fits no rung stays a finding.
- **Repo-enforced quality.** One quality command runs in CI on every pull request and
  push to main; once branch protection requires that check, a failing run blocks an
  ordinary merge, subject to the bypass rules you configure.

Why each of these, and how to adapt them: [`docs/coding-workflow.md`](docs/coding-workflow.md).

| | |
|---|---|
| `dev-workflow:intake` | skill — a raw idea or voice transcript (German or English) becomes a reviewable story. Captures WHAT and WHY; refuses to invent the parts that aren't there. Also amends an approved story or spec with a change record that accounts for every earlier condition. |
| `dev-workflow:ticket` | skill — a bug or improvement that stays inside an approved commitment becomes a ticket file: evidence, the commitment it stays inside, and the brief a coding agent fixes from. `list` shows the ones waiting for triage, information or a start. A change to a commitment is handed to `intake`. |
| `dev-workflow:harden-finding` | skill — one review finding becomes a lint rule (rung 2) or a test (rung 4), recorded in the ledger, or `pending` when a prerequisite blocks it; rung 0 means an existing required check already fails on it and gets no row. |
| `dev-workflow:sparring` | skill — invoked by name only, in a chat you open for advice: investigates read-only, checks agent reports against the current files, and drafts bounded prompts for a coding agent to run elsewhere. It advises; it does not implement, commit, or run review gates. |
| `/dev-workflow:process-pr-review` | command — validates PR bot comments against the code and your invariants, replies to each, fixes regressions, tracks pre-existing issues, and names a bot that left no review on the current head (a green status check alone is no proof). |
| `dev-workflow:finding-triage` | agent — read-only, fresh context, judges whether one PR-bot claim is actually true of the code. Used by the PR processor; never counts as a review gate. |
| `/dev-workflow:workflow-init` | command — scaffolds the per-project files, then interviews you to write `AGENTS.md`. Re-run it after a kit update: it shows the diff per file, and for a `CLAUDE.md` §5 pointer or a `.claude/review-gates.md` from an older kit edition it recommends the current template. |
| `/dev-workflow:claude-init` | command — writes one `CLAUDE.md` of general working rules and nothing else: no review gates, no other files. An existing `CLAUDE.md` is never overwritten; you get a proposal instead. Creating the file needs an already-installed Python 3. |
| codex-gate hook | non-blocking reminders that count Gate A and Gate B passes, and at a commit attempt compare a fingerprint of the effective index plus the included worktree content, as of the hook's invocation — a deliberate superset of any one commit's payload, so the gate errs toward firing — with the one recorded when a Gate-B call was credited. A match says the content is unchanged since that credit, not that Codex read it. After a context compaction it reprints the rules-file pointer and the cycle state. Always exits 0. |

## Quickstart

Prerequisites: Claude Code 2.1.212 or newer, the Codex CLI authenticated with an OpenAI
account, and optionally `gh`. Details, checks and the optional companions (Context7,
Ponytail, codebase-memory) are in [`docs/setup.md`](docs/setup.md).

**1. Install superpowers, then this plugin:**

```sh
claude plugin marketplace add obra/superpowers-marketplace
claude plugin install superpowers@superpowers-marketplace

claude plugin marketplace add dsnger/dev-workflow-kit
claude plugin install dev-workflow@dev-workflow-kit
```

**2. Keep gate calls in the foreground.** Set this in the environment Claude Code is
launched from, then restart it ([why](docs/setup.md#3-set-claude_code_mcp_auto_background_ms)):

```sh
export CLAUDE_CODE_MCP_AUTO_BACKGROUND_MS=0   # or e.g. 900000, exceeding your longest gate call
```

**3. Run `/dev-workflow:workflow-init` in each project.** It prints what is missing — git
repo, superpowers, Codex (not configured / not loaded / ok), `gh`, `AGENTS.md`, stack,
the optional companions — before writing a file, scaffolds the per-project files with a
diff-and-ask for anything present, interviews you for `AGENTS.md`, and ends with a
checklist of what stays yours: the quality battery as one command, baselines, branch
protection, the Codex config block, the PR-bot routing list.

**4. Update later** with `claude plugin update dev-workflow@dev-workflow-kit`, restart
Claude Code, and re-run `/dev-workflow:workflow-init` in each project to take the changed
files ([details](docs/setup.md#9-update-the-plugin-later)).

**5. First feature:** "New feature" below.

## How to use

Type a skill or command as `/dev-workflow:<name>`; in an initialized project you can also
describe the situation and Claude invokes the fitting one. The full walk-through is
[`docs/getting-started.md`](docs/getting-started.md); the hook's per-workspace knobs are in
[`docs/setup.md`](docs/setup.md#per-workspace-knobs).

**New feature.**

1. `/dev-workflow:intake <idea or pasted transcript>` → a story with criteria `AC-1`, `AC-2`,
   … and a profile proposal; you confirm the axes, and it lands under
   `docs/superpowers/stories/`.
2. Say "proceed" → `superpowers:brainstorming` writes the spec with you.
3. **Gate A.** You confirm one profile line, `risk standard|high; security
   none|standard|high; evidence <mode>` (free text is mapped and quoted back). Findings
   land in `.context/codex-reviews/gate-a-spec-<nonce>-pass-<n>.md`, one per line, severity
   `BLOCKER | MAJOR | MINOR | NIT`; Blockers and Majors are repaired and the pass rerun,
   the rest collected. `⚠ Codex Gate A below floor (1/3)` is the counter, not an error.
   A clean pass at the floor runs the **closing act**: one commit carrying the cycle's
   record lines. Planning starts after it.
4. **Cap stop.** `⚠ Codex Gate A: pass cap reached (5/5). STOP and ask the human` → you
   answer `close`, or one of delete the mechanism the findings return to / cut scope /
   continue — each naming how many further passes it allows (at least one); the loop
   resumes on the artifact as your answer leaves it. `.context/codex-gate.cap-extra`
   holds the **total** allowance beyond the base cap for the cycle, so a second answer
   adds to the number already there.
5. Plan (`superpowers:writing-plans`; Gate A on it only at risk `high`, with its own
   closing act), implement (`superpowers:executing-plans`), run the battery from
   `AGENTS.md § Commands` green.
6. **Gate B.** `git commit -m 'WIP: <subject>'`, then a `spec` and a `quality` review on
   the same base and head per pass; the same floor, cap and stop as Gate A. On a commit
   attempt you see `✓ Codex Gate B hook checks passed (3/3 cycle, 1 on current fingerprint)`
   — what the hook checked, not permission to close.
7. The closing commit carries the cycle records and a `todos.md` row per finding accepted
   but not repaired. Open the PR → "PR bot comments".

**Bug or small improvement inside an approved commitment.**

1. `/dev-workflow:ticket <text or path to evidence>` → a ticket under
   `docs/superpowers/tickets/` with the commitment, evidence and brief; an undecidable
   report lands as `needs-triage`. A change to a commitment is handed to `intake` instead.
2. `/dev-workflow:ticket list` shows the `needs-triage`, `needs-info` and `ready` buckets
   (not the ones already in progress); only a `ready` ticket carries the build hand-off.
   `/dev-workflow:ticket T-<n> in-progress` starts one. Fix from the brief, then battery,
   Gate B and PR as above (docs-only commits skip Gate B); after the closing act,
   `/dev-workflow:ticket T-<n> done <fix commit>`.

**PR bot comments.**

1. Wait for the bots in the "wait for" list of `docs/pr-review-bots.md`.
2. `/dev-workflow:process-pr-review [<pr-number>]` → checks CI first, validates each claim
   (usually via a fresh-context `finding-triage` subagent), replies on every thread, fixes
   accepted regressions (substantial ones through Gate B again), and names a bot that left
   no review on the head. It reports done when every claim ends in a fix, a documented
   dismissal, a `todos.md` row or an escalation you have answered, every thread has a
   reply, fixes are committed, CI is green on the final head and the PR's merge state is
   clean — then merge.

**A finding that could recur.**

1. `/dev-workflow:harden-finding` with the finding, its source (`gate-a` / `gate-b` / `bot`
   / `manual`) and severity → it fingerprints the class, greps `docs/hardening-log.md` for
   a recurrence, proposes rung 2 (lint) or 4 (test) and asks when both fit, applies and
   verifies with the project's command, and appends one ledger row — or stops: rung 0
   (already caught, no row), `pending` (blocked by a prerequisite, row stays open), or
   a row for the same fingerprint that appeared meanwhile.
2. A closing commit's `hardening owed` line is closed by the rung line the landed
   hardening writes; a `pending` record leaves it open.

**Discussing an idea first.**

1. In a new chat: `/dev-workflow:sparring <question>` → read-only investigation, options
   weighed, an agent's report checked against the files, a bounded prompt drafted.
2. It implements nothing and runs no gate; carry its prompt to the session that does.

## What to expect

**From the gates.** Gate A sends the text of every spec, and of a plan whose confirmed
risk is `high`, to Codex `exec`. Gate B sends every non-docs-only diff to Codex `review`
after the battery passes. The prompt asks Codex to report every finding with severity and
confidence; Claude filters to Blockers and Majors for repair and reads the rest. The
floor is three valid passes per cycle, a pass with zero findings may close early, and the
cap is the floor plus two, where the agent stops and asks you. From pass 2 on, each Gate-B
call lists the earlier passes' Blockers and Majors and Codex marks each `fixed | not
fixed | no longer applies`; the `spec` call maps each acceptance criterion to the test
asserting it, or `none`. The hook counts passes and compares a fingerprint; it never
reads a findings file, so a pass whose file is incomplete is discounted whatever the
counter says.

Five things stay yours on purpose — a plausible default nobody verified is worse than an
honest gap ([reasoning](docs/coding-workflow.md#adapting-it-to-another-project)):

- **Quality-battery tools** — the plugin names the roles (typecheck, lint, dead code,
  duplication, tests), never the tools. You wire them into one command.
- **Baselines** — generated from *your* repo, in their own commit.
- **Custom lint rules** — two ship as examples only
  ([`examples/eslint-rules/`](plugins/dev-workflow/examples/eslint-rules/)); they encode
  one stack's invariants and won't transfer.
- **Branch protection** — a repo setting, not a file; worth doing once the battery runs.
- **`AGENTS.md`** — your invariants. Both gates check against it, so a generic one makes
  "check against our invariants" read as satisfied when nothing was.

## Contributing

CI ([`.github/workflows/ci.yml`](.github/workflows/ci.yml)) runs four checks on every
PR and push to main: `shellcheck --shell=sh` over the four shell executables and every
shell test file, the hook's test suite,
[`scripts/check-invariants.sh`](scripts/check-invariants.sh) (invariants 5 and 6, plus six prompt-conformance checks and three size budgets) plus
both checkers' regression suites, [`scripts/check-doc-links.sh`](scripts/check-doc-links.sh)
(relative Markdown links resolve) and its suite, the six reports' suites, and
`claude plugin validate . --strict`.

`python3 scripts/ledger-metrics.py` prints a read-only report over the hardening ledger
and the review-cycle records in commit bodies: which fingerprints recur, how rungs were
followed, and each cycle's recorded curve beside the `fic2` baseline. It writes nothing.

`python3 scripts/run-analytics.py` reads the Claude Code transcripts and Codex session logs
on this machine and reports how many gate calls each review cycle and story took, how long
they ran and how many tokens they used, including effort no closed cycle accounts for. It
keeps numbers and identifiers only, in `.context/telemetry/` of this clone, for 365 days.

`python3 -B scripts/loop-usefulness.py [<ref>]` gives every review cycle whose records are in the
history read a warning light (a skipped cycle ran no loop and is listed without one):
red or amber where its recorded passes or rising findings call for reassessing review effort,
no warning where no threshold is reached, and not determinable where missing or conflicting
data leaves the state open. It does not say whether a loop was worth its effort, and it writes
nothing (`-B` keeps the interpreter from writing bytecode too).

`python3 -B scripts/spec-delta.py --base <baseSha> --baseline <commit>:<spec> … [<head>]` shows a
Gate-B reviewer how each relevant spec and plan changed since a baseline you name, usually the
commit that closed its Gate-A cycle. It quotes that commit's cycle records and names any
ambiguity. It does not claim the cycle reviewed exactly that file, and it informs without
obliging anything. It writes nothing.

`python3 -B scripts/live-effort.py` shows the effort of review cycles that have not closed yet: calls,
time and tokens per open cycle, plus gate calls still waiting for their result, with unknown values
counted rather than hidden. Re-run it to refresh. It counts calls, not review passes, sets no
threshold, and changes no gate rule. It writes nothing, and it reads every transcript, so a run can
take a minute or two.

`python3 -B scripts/status-view.py [--base <commit>] [--watch <seconds>]` writes one HTML page,
`.context/status/index.html`: current work, evidenced progress, open points, effort, artifact growth
against a baseline (merge-base with `main` unless `--base` names one) and the installed, loaded and
declared workflow versions. Each value names its source and age; what the sources cannot establish
says `unknown`. `--watch` regenerates it at that interval until you stop it, and the page reloads
itself. It writes only `.context/status/`, keeps a cache there so later runs re-read only changed
logs, and makes no model call. The first run reads every transcript once.

A fifth check runs **on pull requests only**:
[`scripts/check-version-bump.sh`](scripts/check-version-bump.sh) (invariant 12), which
needs a base branch to diff against. Its *suite* runs unconditionally with the others;
the checker itself does not. That is sufficient here because main accepts changes only
through a PR: a branch ruleset (`protect-main.`, active since 2026-07-19) requires a
pull request and a green `quality` check, and the version-bump step runs inside that
`quality` job — so there is no push path into main that skips it. The single command
that runs the whole battery locally is in [`AGENTS.md`](AGENTS.md) under "Commands".

Main is protected: a PR with a green `quality` check is the only way in, admins
included — the ruleset lists no bypass actors.

Everything else here is a **prompt**, and prompts have no typechecker — they are
reviewed against [`docs/prompt-standards.md`](docs/prompt-standards.md), this repo's own
standard and the same checklist it scaffolds into every project. A prompt-quality defect
here is a defect in the shipped product.

Repo layout and the two non-obvious design decisions:
[`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md).
