# Command-retargeting commits bypass Gate B — Story

**Date:** 2026-07-19 · **Size:** story

## 1. Problem statement

`repo_root` is bound once when the hook starts, so a commit whose *command* selects a
different index, git directory or work tree commits content the hook never fingerprinted
— while Gate B reports satisfied. Verified: with an alternate index staging `SNEAKY` and
the worktree holding `v1`, `GIT_INDEX_FILE=alt git commit` committed `SNEAKY`.

Found during Gate A on the index-tree hash story
(`docs/superpowers/specs/2026-07-19-gate-b-index-tree-design.md`), where it was first
taken in as a two-line addition and then split out at §7 as a cohesive second feature.

## 2. Desired outcome

Commit commands the hook cannot positively read as a plain `git commit` are treated as
unverified — the gate fails closed rather than reporting satisfied. An ordinary commit is
unaffected.

The user learns that the hook *cannot verify* this commit, rather than that the code is
unreviewed: re-reviewing cannot make a retargeted command verifiable, so a message
prescribing another review would send someone into an unbounded loop.

## 3. Acceptance criteria

- [ ] An ordinary `git commit -m "…"` with no override still reaches satisfied — no
      regression in the common path.
- [ ] Each override spelling is not satisfied: `GIT_INDEX_FILE=`, `GIT_DIR=`,
      `GIT_WORK_TREE=`, `-C`, `--git-dir`, `--work-tree` — the last exercised via
      `commit -a`, which is what makes an alternate work tree affect committed bytes.
- [ ] All five bypasses documented during story 1 fail closed, each mutation-verified
      independently: backslash-newline, `-\C`, quoted `GIT_INDEX_"FILE"=`, `${x-}`
      expansion, brace expansion.
- [ ] A spelling *not* anticipated by the implementation also fails closed — the property
      that distinguishes this outcome from a blocklist, and the reason this is a story
      rather than a sixth patch.
- [ ] The `WIP:` exemption is preserved: a WIP commit stays cycle-internal even when it
      carries an override.
- [ ] The verdict precedes docs-only classification, which reads the default index and
      would otherwise wave through an alternate index staging code.
- [ ] The message states that the hook cannot establish the target, and does not
      prescribe re-reviewing.
- [ ] Quality battery green, including `shellcheck --shell=sh` and the hook suite under
      `sh`.

## 4. Affected AGENTS.md invariants

- `## What this project is` — "a fingerprinted hardening ledger where a recurring finding
  escalates one rung harder (prose → lint → type → test)". This governs the shape of the
  answer: five successive bypasses were each absorbed by adding one more token to a
  blocklist, which is the same rung repeated rather than the ladder working.
  *(The concrete precedent is `todos.md`'s "Escalation trigger for the invariant checker":
  "Adding one more regex arm per newly-discovered spelling is **not** the ladder working;
  it is the same rung applied repeatedly… the answer is a real YAML/shell parse logged as
  the next rung — not another patch." It lives in todos.md, not AGENTS.md, and is scoped
  to the invariant checker; it also excludes spellings "found during development", as
  these were. It is cited as precedent for the pattern, not as a rule that formally
  fired.)*
- `## Key invariants → Hook` — "**Loose in the firing direction.** On uncertainty, fire. A
  missed commit (false ✓) is the dangerous direction; a redundant warning is the accepted
  price." This is what prices failing closed on unreadable commands as acceptable.
- `## Key invariants → Hook` — "**Gate-B validity is content-derived, never
  event-derived.**" The defect is a ✓ standing for content that was never hashed.
- `## Key invariants → Hook` — "**The hook always exits 0.**"
- `## Key invariants → Hook` — "**POSIX `sh`, and `jq` is optional.**"
- `## Prompts and scaffolding` — "**Prompt changes pass `docs/prompt-standards.md`** — all
  12 checklist items, for any skill, command, agent definition, hook message, or
  scaffolded template." The new reminder text is a shipped prompt.

## 5. Open questions

- Where is the boundary of a command the hook can "positively read"? Env-prefixed
  commands, `-c key=value` flags, multi-line commands and `&&` chains are each a
  deliberate include or exclude, not something to inherit from whatever the earlier
  blocklist happened to cover.
- What is the UX cost of failing closed on legitimate exotic invocations? Invariant 2
  prices it as acceptable, but the frequency should be estimated rather than assumed — a
  gate that fires on commits people actually make will be worked around.
- Does this outcome subsume the parked compound-commands item (`printf x > f && git commit
  -am y`, where the hook hashes the pre-mutation tree)? If an `&&` chain is unreadable by
  definition, that row closes here; if not, it stays parked.

## 6. Suggested size

`story` — one coherent behaviour with one settled outcome, fits one spec → plan → PR.
Larger than the hash change it was split from, but not multiple subsystems.
