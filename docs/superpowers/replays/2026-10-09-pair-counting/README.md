# Pair-counting replay (2026-10-09)

The named verification of the risk path for
`docs/superpowers/stories/2026-08-14-sequential-branch-calls-hook-story.md` (evidence mode
`battery+check+verification`; spec `docs/superpowers/specs/2026-10-09-sequential-branch-calls-hook-design.md` §5).

**What it shows.** The hook from this branch and the hook from `205efd3` (dev-workflow 0.20.0)
read the same payloads, in the same throwaway repository, from the same empty `.context/`,
under `sh` and `dash`, with `jq` and with a `jq`-free PATH. On a host without `jq` the `jq`
mode is skipped with a skip line, so such a run cannot show the `jq`-specific C3 behaviour:

- **C1, three uninterrupted spec→quality pairs.** Old hook: 6 and a satisfied line (the
  counterfactual — the false ✓ the story describes). New hook: 3.
- **C2, then a lone spec branch and a commit check.** Old hook: a satisfied line with no mention
  of the half pass. New hook: the count of complete passes plus the pending-branch note.
- **C3, a `WIP:` commit between a spec and a quality branch.** With `jq` the new hook keeps the
  pending half over the WIP commit and the quality branch, carrying the new `headSha`, does not
  pair; without `jq` the hook cannot attribute the commit and resets, the pending file included.
  The old hook's count is printed for information only.

**What it does not show.** The payloads are synthetic: hand-built `tool_input`s with a minimal
success envelope. No real single-branch payload from Claude Code was replayed.

**Run:** from the repository root, `sh docs/superpowers/replays/2026-10-09-pair-counting/replay.sh`.
It exits 1 if any `ok`/`FAIL` line fails.

**Observed output** (2026-10-09, macOS, this branch):

```
C1  old  sh    jq    ok   count=6 commit check: [Codex Gate B: 6/3 pass(es) this cycle] (counterfactual)
C2  old  sh    jq    ok   count=7 [Codex Gate B: 7/3 pass(es) this cycle] pending-note=0 (counterfactual)
C3  old  sh    jq    info old hook observed: count=2 (counts calls; no pairing)
C1  new  sh    jq    ok   count=3 commit check: [Codex Gate B: 3/3 pass(es) this cycle]
C2  new  sh    jq    ok   count=3 [Codex Gate B: 3/3 pass(es) this cycle] pending-note=1
C3  new  sh    jq    ok   pending kept over WIP=yes, count after quality on new head=0
C1  old  sh    nojq  ok   count=6 commit check: [Codex Gate B: 6/3 pass(es) this cycle] (counterfactual)
C2  old  sh    nojq  ok   count=7 [Codex Gate B: 7/3 pass(es) this cycle] pending-note=0 (counterfactual)
C3  old  sh    nojq  info old hook observed: count=1 (counts calls; no pairing)
C1  new  sh    nojq  ok   count=3 commit check: [Codex Gate B: 3/3 pass(es) this cycle]
C2  new  sh    nojq  ok   count=3 [Codex Gate B: 3/3 pass(es) this cycle] pending-note=1
C3  new  sh    nojq  ok   jq-free WIP reset, pending kept=no, count=0
C1  old  dash  jq    ok   count=6 commit check: [Codex Gate B: 6/3 pass(es) this cycle] (counterfactual)
C2  old  dash  jq    ok   count=7 [Codex Gate B: 7/3 pass(es) this cycle] pending-note=0 (counterfactual)
C3  old  dash  jq    info old hook observed: count=2 (counts calls; no pairing)
C1  new  dash  jq    ok   count=3 commit check: [Codex Gate B: 3/3 pass(es) this cycle]
C2  new  dash  jq    ok   count=3 [Codex Gate B: 3/3 pass(es) this cycle] pending-note=1
C3  new  dash  jq    ok   pending kept over WIP=yes, count after quality on new head=0
C1  old  dash  nojq  ok   count=6 commit check: [Codex Gate B: 6/3 pass(es) this cycle] (counterfactual)
C2  old  dash  nojq  ok   count=7 [Codex Gate B: 7/3 pass(es) this cycle] pending-note=0 (counterfactual)
C3  old  dash  nojq  info old hook observed: count=1 (counts calls; no pairing)
C1  new  dash  nojq  ok   count=3 commit check: [Codex Gate B: 3/3 pass(es) this cycle]
C2  new  dash  nojq  ok   count=3 [Codex Gate B: 3/3 pass(es) this cycle] pending-note=1
C3  new  dash  nojq  ok   jq-free WIP reset, pending kept=no, count=0
```
