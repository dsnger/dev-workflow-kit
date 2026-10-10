# Replay: ledger check at cycle close (2026-10-10)

The named verification for `docs/superpowers/stories/2026-08-04-ledger-route-without-pull-requests-story.md`
AC-3 and AC-5, as spec `docs/superpowers/specs/2026-10-10-ledger-check-at-cycle-close-design.md`
§5 defines it. Check 4h shows the rule text is present; this package shows, once, that a fresh
session can follow it from durable sources, and that the old rules do not produce the records.

## What is here

| Path | Content |
|---|---|
| `build-fixture.sh` | builds one fixture repository, part `a` or `b`, from a given copy of the rules |
| `prompt-a.txt`, `prompt-b.txt` | the prompts, verbatim; part A's is identical for both rule versions |
| `expected/` | the expected observations, written before any run |
| `out/` | each session's final answer, the commit it wrote (part A), and the run metadata |
| `compare.md` | each observation against its expectation, and the limits |

## The fixtures

**Part A — interruption before close.** A Gate-B cycle `r3pl4yfx01` ready to close. Pass 1
found a stale `--global` flag in `README.md` twice (once per branch) and the typo "mesage";
both were repaired; pass 2 is clean. The dispositions files and the working record are present,
as written at repair time. The session gets nothing from the session that made the repairs.
The fixture's story is profiled risk `trivial`, security `none`, and a plan cites it in its
`Story:` header (from run 4), so the floor is 1 and pass 2 may close the cycle. The repaired
`tool.sh` accepts no argument (from run 4).

**Why Y owes nothing.** The typo is a one-off spelling slip. No base or fixture class covers
it, and one misspelling does not make a class "clearly warranted": no mechanical check would
prevent the next one, and no prose rule would be read where it happens.

**Part B — fresh checkout after a squash.** `main` holds one squash commit carrying three owed
lines and their outcomes: one closed by `rung 2`, one with only `pending <ref>`, one with none.
One owed target is a quoted path containing the separator. `.context/codex-reviews/` does not
exist.

## How the runs were made

- **Run 4 is the reference run.** Its new rules are `.claude/review-gates.md` with sha256
  `292dc6b3d32e6fcac5970de5468d30e294b160c04b2c132c93dd2777b14bc193`: the text as repaired after
  the PR #56 bot review. Compare that hash with the file in the commit that adds this package;
  equal hashes mean the shipped text is the tested text. Its counterfactual is `main` at
  `860e56cf69a0cdd921e40f394ca4fbba62d9322e`, which stays reachable. Runs 1-3 are kept as
  history: their new rules came from `WIP:` snapshots that later amends replaced, so their bytes
  are not recoverable from the repository, only their hashes below.
- Rules: `.claude/review-gates.md` copied by the builder from a full commit ID. The new rules,
  runs 1 and 2: the WIP snapshot `506477aef03cc433b04d567234f7f9aca4830361` (sha256
  `7791bfcb7a92e37703006e7a35d03b146fed8a50584c51d433a5f0dd9758ce5a`); run 3, after the Gate-B
  pass-1 repairs changed the rule text: `3d3812ffc5c771b4b941fbf8d934502ccf3bb1af` (sha256
  `f3947544c7df18d509d52cbbfef2902f94cc9ca0afd7ae9dc11b9fe39bfc1228`). The counterfactual from
  `main` at `860e56cf69a0cdd921e40f394ca4fbba62d9322e` (dev-workflow 0.21.0, sha256
  `ad09e8b382d0f6e964092ded42f3704d3dca931958ddaa8dbb285e81baa721f2`). The fixture's own
  `CLAUDE.md` points at that file and nothing else.
- Each run: `claude -p "<prompt>"` started in the fixture root, with `--plugin-dir` on the
  `plugins/dev-workflow` directory of the same commit as the rules, `--setting-sources project`,
  `--strict-mcp-config`, `--permission-mode acceptEdits`, `--output-format json`. The fixture's
  project settings allow `git`, `ls`, `cat`, `grep` and `sh -n`, but the client ignored them in
  an untrusted directory, so part A was run a second time with the same five allowed through
  `--allowedTools` (`compare.md`, "Run 1"). Not a subagent of the
  implementing session, which would have loaded this repository's `CLAUDE.md` and its new rules.
- What still loads: user-level instructions and memory outside project settings, if the client
  reads them under `--setting-sources project`. Recorded as a limit, not ruled out.

## Limits

- Each part is one sample. It shows the rules can be followed from durable sources; it does not
  show they always will be.
- Not exercised: a Gate-A cycle; the recovery of an interrupted cycle through its working
  record; writing outcome lines through a `WIP:` amend (part B starts from a prepared squash);
  `process-pr-review` step 5's skip.
- The fixture is small and its defects are obvious. A real cycle's classification is harder.
