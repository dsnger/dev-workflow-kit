---
name: gate-b-review
description: The kit's review method for a Gate B pass (spec, quality or risk branch) — what to check, how to trace callers, when and how to run targeted tests, and where to write findings and evidence. Use whenever a Gate B call names this skill.
---

# gate-b-review

Written for Codex (OpenAI) via Codex CLI 0.162.1, running a Gate B call of the dev-workflow kit; the kit checks
it against its `docs/prompt-standards.md` as part of `/workflow-init`'s template `### 2.24`.

## Context
You review one change, the git range `baseSha..headSha`, in one branch: `spec`, `quality` or `risk`. The call
names the range, the branch, the cited story and spec, the battery evidence for this head, and the findings-file
path. The project's `AGENTS.md` holds its invariants and § Commands; `.claude/review-gates.md` holds the findings
format. A pass is done when the findings file is complete and the evidence file is written: the gate counts
only the findings file, and the human reads the evidence to see what you checked.

## Task, in order
1. **Read the inputs.** The range (with `git diff baseSha..headSha` and `git show headSha:<path>`; the working
   tree may differ from the head), the cited story and spec, `AGENTS.md` (check against it), and the battery
   evidence the call names. Before reading the call's `whatWasImplemented`, form 2–4 hypotheses of what could be
   wrong from the acceptance criteria and the diff, then check that summary as claims, not context, so it cannot
   steer you.
2. **Check, by branch.** In every branch, ask: which existing statements does this diff falsify?
   - `spec`: map every acceptance criterion `AC-<n>` of the cited story to the code that realises it and the test
     that asserts it, or `none`; a test that cannot fail is a finding.
   - `quality`: the `AGENTS.md` invariants the diff touches; the failure, error, empty and concurrent paths of
     every changed function, script or rule; statements elsewhere in the repository that the diff makes false.
   - `risk`: only edge cases and failure paths, deeper than an ordinary pass — boundary and malformed inputs,
     each external call, file or process failing, interruption at every step, two runs at once.
3. **Trace callers and dependents.** For every changed symbol — function, variable, file path, heading or anchor,
   config key, template section — find its users in the head tree with `git grep -n -e '<symbol>' <headSha>`,
   and read each one that depends on the changed behaviour, because a change is only as correct as its callers'
   assumptions. When the project has the codebase-memory integration and you can establish that its index
   matches `headSha`, use the index; when you cannot, use direct search and name the refresh command recorded in
   `todos.md` § Tooling revalidation, or say that none is recorded. Without the integration, say nothing about
   it. Read the index only: indexing is the human's step (decision D79).
4. **Run targeted tests (optional, your choice).** Pick the test commands `AGENTS.md` § Commands names for the
   touched paths, or a test file named for a touched file, never the whole battery (the battery already ran).
   Run them only when your permissions instructions say the sandbox is `workspace-write` with network access
   restricted, because only then is the run offline; otherwise write each as not run with that reason. Run
   each one only through this skill's script, which makes a disposable copy with tracked files only, strips the
   environment, bounds the time and cleans up:
   `sh .agents/skills/gate-b-review/scripts/run-tests.sh "$PWD" <headSha> <seconds> -- <command> <args…>`
   Set `<seconds>` to at least twice the command's usual duration where `AGENTS.md`, the suite's header or the
   battery evidence states one, and to `1800` (the maximum) where nothing does, because a limit below the
   suite's own duration proves nothing (a suite of about 9 minutes once got 180 s). A timeout (`exit timeout`,
   exit 124) is a test that did not finish, not a failing test: write its `TESTS:` line with the limit you set.
   Its exit 4 (`checkout changed`) is a BLOCKER finding: a test wrote into the reviewed checkout. Its exit 5
   means no test ran (no supervisor); write that reason.
5. **Write the output.** Two files, then one reply line.

## Rules
- Report every finding with severity and confidence, because the main session filters, not you; write the
  clean file (`NO FINDINGS`) only when the branch found none.
- A failing targeted test is a finding, unless the battery evidence the call names already shows that failure
  and the gate mode is not `classic` (the gate rules suppress duplicates there); record its `TESTS:` line either
  way.
- Report one cause seen at several places once, as a class listing every place.
- Write only the two files the call names, because the gate compares the checkout before and after.

## Output format
The findings file, at the path the call names, in the format of `.claude/review-gates.md` (one finding per line,
then the terminator), for example:

```
MAJOR | high | scripts/x.sh:12 | an empty list exits 0 | a missing input reads as success | exit 1 when the list is empty
END OF FINDINGS (1 total)
```

The evidence file beside it, named like the findings file with `-evidence.md` in place of `.md`: one `TESTS:` line
per command, or one `TESTS: none — <reason>`, and one `CALLERS:` line per changed symbol:

```
TESTS: sh scripts/x.test.sh | exit 0 | 4s
CALLERS: run_case — scripts/x.test.sh:40, scripts/y.sh:7 (both read its exit status)
```

The reply: one line with the counts per severity and the evidence file's path.
