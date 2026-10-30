# Kit 0.51 proof replay — answer key

Written and committed before any replay run (spec `docs/superpowers/specs/2026-10-30-kit-051-codex-review-design.md`
§8, plan T7). Each case is a dev-workflow-kit pull request whose head carried a closed Gate B cycle and where a
review bot (Greptile or CodeRabbit) then found a real defect that was accepted and fixed. The driver is
`replay.sh` beside this file; the results go to `report.md`.

## Cases (frozen; this order)

| # | PR | pre-fix head | base (merge-base, checked with `git merge-base`) | fix | files / lines in range | risk pass |
|---|---|---|---|---|---|---|
| 1 | #97 | 8f0cd823339df40977b512bd188d5ff12bf71a24 | a56ef4455c3c3381e5fdb05fd2e3c3afb25b82ca | 8a3baca | 28 / +969 −17 | forced (8 paths) |
| 2 | #49 | 00faea5e081f8aefd37609f4e21df0b6877fc896 | 62ebb90992ec5dda61349371cb47ee90e55efea2 | cb5068f | 10 / +3261 −60 | forced (5) |
| 3 | #41 | 97471fb7cdf9ec3d3f29d4a5c8ed7d9d6367a0ba | 70bb54e99df52626e1edc70e65746093b3d23de9 | ebf124b | 11 / +1878 −45 | forced (6) |
| 4 | #56 | 2230d90308615c5f8ba157a7ad359877b95bac8e | 860e56cf69a0cdd921e40f394ca4fbba62d9322e | 36b5857 | 61 / +2147 −65 | forced (19) |
| 5 | #43 | 9071b91c89bd6b44da3b0e9c3c877f12a574f9d1 | 62931c35d49234b41185180ec51a8093c233aa69 | f8f9d18 | 10 / +1573 −10 | forced (4) |
| 6 | #40 | 4972cb18c6bb42c058169eb566fa59a2c7ae87a2 | b18e7db386a20efe0e751111e241a6b88eceb9d6 | 2164624 | 15 / +1037 −23 | forced (7) |
| 7 | #99 | 14d5b3c1f9bfda4bec887c8ad3faad8e53390e01 | 2a5a4d06e35143f43c04db538a27d145cddd5cf5 | e109a49, 465bb36 | 47 / +1222 −219 | forced (13) |
| 8 | #95 | 770e7e56ec2bd68913ba19fbf6f0465855ca5659 | 405738de006e5295443cc938cc3992f6b1a5b04e | f61955a | 19 / +781 −57 | forced (9) |

"Risk pass": every range holds a forcing path of spec §6 (scripts, `*.sh`, `plugins/`, `.claude/`, …), so the
driver runs it in all eight; the count is the number of such paths.

## Scoring

- A key defect is **found** when a finding line of the case's `spec`, `quality` or risk findings file states its
  cause and its consequence, not merely the same file or line. The matching line is quoted in `report.md`.
- A case is **found** when at least one of its key defects is found; it counts once however many lines match.
  `report.md` also gives the per-defect count (found / key defects) for each case, so a case found through one
  minor documentation defect is visible as such.
- Target: at least 4 of cases 1–6 found; cases 7–8 are reported as well.
- **Contamination** (spec §8): a call whose `--json` event log shows a command reading outside the clone, a
  `gh` or network call, or a read of this replay directory or `report.md` makes the case contaminated; a
  missing or unreadable log makes it unverified. Such a case is excluded and rerun once; still so, it is
  reported as such and counts as not found. The driver's `audit.txt` lists candidate commands; each flag is
  judged by reading it.

## Key defects

Drafted from the bot comments on each pre-fix head (`gh api repos/dsnger/dev-workflow-kit/pulls/<n>/comments`,
`original_commit_id` = the head) and kept only when the fix commit repaired it. INFERRED marks a consequence the
comment implies but does not state.
### Case #97
- K97.1 | greptile-apps[bot] comment 4366956535 | scripts/worktree-cleanup.sh:205 | cause: the default-branch guard applied only to standalone branch rows, not to worktree rows or `delete_branch` | consequence: with the main checkout on another branch, an idle linked worktree holding `main` is marked removable and `--remove` deletes the local default branch | fixed by 8a3baca
- K97.2 | greptile-apps[bot] comment 4366956540 | scripts/worktree-cleanup.sh:242 | cause: `git update-ref -d` follows symbolic refs | consequence: deleting a symbolic alias of `main` deletes `main` itself | fixed by 8a3baca
- K97.3 | greptile-apps[bot] comment 4366956543 | scripts/worktree-cleanup.sh:241 | cause: the last checkout check pipes `git worktree list` into `grep -q`, so a git failure reads as "no match" | consequence: an unreadable worktree list lets a branch be deleted, and the error is hidden | fixed by 8a3baca
- K97.4 | coderabbitai[bot] comment 4366964248 | CLAUDE.md:125 | cause: the preflight is placed "before the session's first Codex call", but the probe is itself a Codex call | consequence: the trigger point of the probe is self-referential and unclear (INFERRED: the probe could be read as a gate pass) | fixed by 8a3baca
- K97.5 | coderabbitai[bot] comment 4366964251 | CLAUDE.md:126 | cause: the "two-minute timeout" names no mechanism that enforces it | consequence: the probe can hang without a bound (INFERRED) | fixed by 8a3baca (now "as a Bash call with a two-minute timeout")
- K97.6 | coderabbitai[bot] comment 4366964254 | docs/superpowers/specs/2026-10-24-kit-044-field-cases-design.md:90 (code: scripts/worktree-cleanup.sh:153) | cause: `dirty_of()` runs `git status --porcelain` without an untracked-files mode | consequence: with `status.showUntrackedFiles=no`, a worktree with untracked files reads `dirty=no` and can be removed | fixed by 8a3baca
- K97.7 | coderabbitai[bot] comment 4366964256 | docs/superpowers/specs/2026-10-24-kit-044-field-cases-design.md:114 (code: scripts/worktree-cleanup.sh archive loop) | cause: `[ -d "$p/.context" ]` and `mkdir -p "$main/.context"` follow symlinks | consequence: the archive copy can read from or write to a location outside the worktree / main checkout | fixed by 8a3baca
- K97.8 | coderabbitai[bot] comment 4366964266 | scripts/worktree-cleanup.test.sh:15 | cause: the HUP/INT/TERM trap deletes `$work` but does not exit | consequence: after Ctrl-C the suite keeps running against a deleted directory and prints false FAIL lines | fixed by 8a3baca

Excluded: coderabbitai 4366964260 (duplicate of K97.1); issue comments 6383486941 (review-limit notice), 6383539873 (Greptile summary, no new findings).

### Case #49
- K49.1 | coderabbitai[bot] comment 4199618304 | scripts/status-view.py:1176 | cause: `os.lstat` in `handover_growth` (and `newest_handover`) is not guarded against a file removed after `os.listdir` | consequence: `FileNotFoundError` escapes, the handover section keeps a stale listing and the deleted file is not marked deleted | fixed by cb5068f
- K49.2 | greptile-apps[bot] comment 4199663279 | scripts/status-view.py:343 | cause: `worktree_state` skips the content check when size and mtime match the index | consequence: a same-length edit with a preserved or coarse timestamp shows a changed rule file as clean indefinitely | fixed by cb5068f
- K49.3 | greptile-apps[bot] comment 4199663287 | scripts/status-view.py:394 | cause: `changed_paths` and `sec_growth` compare contents only | consequence: a mode-only change (executable bit) disappears from the changed-artifact list and growth count | fixed by cb5068f
- K49.4 | greptile-apps[bot] comment 4199663293 | scripts/status-view.py:1073 | cause: `measure` returns `skip` for a special file, which then lands in neither `cur` nor `unknown` | consequence: a tracked file replaced by a FIFO (or a handover turned into a symlink) is reported deleted and its bytes subtracted | fixed by cb5068f
- K49.5 | greptile-apps[bot] comment 4199663308 | scripts/status-view.py:1426 | cause: `run_once` replaces saved sections and success time before the output writes succeed | consequence: after a failed write, the failure banner claims to show the previous page but renders the new, unpublished state | fixed by cb5068f
- K49.6 | greptile-apps[bot] comment 4199663320 | scripts/status-view.py:1232 | cause: `installed_source` accepts a sole applying record without validating `version` | consequence: a record like `{"scope": "user"}` shows `installed: None` as a successful source instead of unknown | fixed by cb5068f

Excluded: issue comments 6023856597 (review-limit notice), 6023998122 (Greptile summary, no new findings).

### Case #41
- K41.1 | greptile-apps[bot] comment 4179134424 | plugins/dev-workflow/commands/workflow-init.md:227 | cause: declining the §5 append to an existing CLAUDE.md still writes a missing `.claude/review-gates.md` under Rule 2 | consequence: the project gets a rules file that nothing points to | fixed by ebf124b
- K41.2 | greptile-apps[bot] comment 4179134428 | plugins/dev-workflow/commands/workflow-init.md:269 | cause: the payload checksum is recorded before the user may edit the payload | consequence: the read-back check rejects a correctly written edited file, or the integrity check becomes meaningless | fixed by ebf124b
- K41.3 | coderabbitai[bot] comment 4179134541 | docs/superpowers/plans/2026-10-04-gate-rule-files.md:692 | cause: the plan expects a template size of 4820, the final template is 5039 | consequence: a rerun of the plan disagrees with its stated expectation | fixed by ebf124b (dated execution note)
- K41.4 | coderabbitai[bot] comment 4179134544 | plugins/dev-workflow/commands/workflow-init.md:214 | cause: the mixed-form test requires the exact contiguous pointer sentence | consequence: a wrapped or reworded pointer is classified as inline rules and migrated into the rules file, leaving neither file with the rules | fixed by ebf124b
- K41.5 | coderabbitai[bot] comment 4179134550 | plugins/dev-workflow/commands/workflow-init.md:255 | cause: the migration preconditions do not check whether `.claude/` is git-ignored | consequence: the rules file passes read-back but never reaches a clone, which gets only the pointer | fixed by ebf124b
- K41.6 | coderabbitai[bot] comment 4179134552 | scripts/check-invariants.sh:677 | cause: check 4e measures the first four-backtick fence under `### 2.1` and then stops | consequence: a short example fence before the template lets an oversized CLAUDE.md template pass | fixed by ebf124b

Excluded: coderabbitai 4179134549 (duplicate of K41.1); issue comments 5983896589 (walkthrough), 5983926382 (Greptile summary, no findings).

### Case #56
- K56.1 | greptile-apps[bot] comment 4237847714 | scripts/ledger-metrics.py:231 | cause: `OWED_HEAD` and `OUTCOME` match the cycle nonce and the slot nonce independently | consequence: a line whose two fields name different cycles is silently skipped instead of reported malformed | fixed by 36b5857
- K56.2 | greptile-apps[bot] comment 4237847723 | docs/superpowers/replays/2026-10-10-ledger-check/build-fixture.sh:25 | cause: `rules` is checked before `cd "$target"` but used after it unresolved | consequence: a relative rules path fails at `cp`, leaving a partly built fixture | fixed by 36b5857
- K56.3 | greptile-apps[bot] comment 4237847726 | docs/superpowers/replays/2026-10-10-ledger-check/README.md:42 | cause: the replay depends on amended `WIP:` snapshots not reachable by their recorded SHAs | consequence: a fresh checkout cannot repeat the documented runs | fixed by 36b5857 (run 4 on reachable rules becomes the reference run)
- K56.4 | coderabbitai[bot] comment 4237865089 | .claude/review-gates.md:1479 | cause: ledger-check inputs select every `fixed` disposition, including a declined duplicate repaired through another finding | consequence: a declined finding can get its own ledger count and hardening obligation | fixed by 36b5857
- K56.5 | coderabbitai[bot] comment 4237865094 | docs/superpowers/replays/2026-10-10-ledger-check/build-fixture.sh:102 | cause: Part A's repaired `tool.sh` is an unconditional `echo ok` | consequence: it accepts `--global` and any argument, so the fixture's "repaired" state is false | fixed by 36b5857
- K56.6 | coderabbitai[bot] comment 4237865099 | docs/superpowers/replays/2026-10-10-ledger-check/prompt-a.txt:1 | cause: the prompt tells the agent the floor was met, while the fixture (no plan `Story:` header) has a floor of 3 and only two passes | consequence: the replay agent works from a false premise | fixed by 36b5857

Excluded: coderabbitai 4237865091 (duplicate of K56.2); issue comments 6098179339 (no actionable comments), 6098233426 (Greptile summary, no new findings).

### Case #43
- K43.1 | greptile-apps[bot] comment 4182648687 | scripts/live-effort.py:110 | cause: freshness ("newest observed value") is computed from all scanned calls, including calls of closed cycles | consequence: stale open-cycle data can appear fresh | fixed by f8f9d18
- K43.2 | greptile-apps[bot] comment 4182648695 | scripts/live-effort.test.sh:227 | cause: the assertion bounds elapsed time at five minutes after fixture creation | consequence: a slow CI runner fails the test although the report is correct | fixed by f8f9d18

Excluded: issue comments 5991957808 (no actionable comments), 5992004109 (Greptile summary, no new findings).

### Case #40
- K40.1 | greptile-apps[bot] comment 4177534952 | scripts/check-invariants.sh:601 | cause: check 4d counts the italic rule line without requiring it before the criterion rows | consequence: a template with the rule moved below the AC rows still passes | fixed by 2164624
- K40.2 | coderabbitai[bot] comment 4177582908 | plugins/dev-workflow/CHANGELOG.md:34 | cause: the CHANGELOG says check 4d "pins the template's spelling only" | consequence: it under-describes what 4d checks (boundaries, rule line, numbering) | fixed by 2164624

Excluded: coderabbitai 4177582905 (plan's 24/172 counts; not changed by 2164624, which only notes the closed plan still says 24/172 — declined); issue comments 5979831445 (review-limit notice), 5979853343 (Greptile summary, no findings).

### Case #99
- K99.1 | greptile-apps[bot] comment 4388200704 | plugins/dev-workflow/commands/workflow-init.md:609 | cause: a project can accept the new `.claude/review-gates.md` (which no longer carries the Ponytail and Library APIs duties) while declining the CLAUDE.md update that now carries them | consequence: both review duties silently disappear from the project | fixed by e109a49 and 465bb36
- K99.2 | greptile-apps[bot] comment 4388200717 | .claude/review-gates.md:66 | cause: the close moves the cycle's files to the archive before the closing commit, and the hook's `compact_lines` searches only `.context/codex-reviews/` | consequence: after a compaction in that window the hook reports no nonce, or an older cycle's nonce, beside the live pass counts | fixed by e109a49 (hook codex-gate.sh also searches the archive)
- K99.3 | coderabbitai[bot] comment 4388236010 | docs/getting-started.md:52 | cause: the cap-outcome instruction is stated unqualified and the classic variant only in a parenthesis | consequence: in `classic`, a Security-class or violated-AC Minor is wrongly sent to the human | fixed by e109a49
- K99.4 | coderabbitai[bot] comment 4388236012 | plugins/dev-workflow/CHANGELOG.md:35 | cause: the entry names only a `spec` as Gate A eligible | consequence: it omits plans at risk `high`, misstating the Gate A condition | fixed by e109a49
- K99.5 | coderabbitai[bot] comment 4388236021 | todos.md:2169 | cause: the trigger fires after five closed cycles in any project | consequence: the lean/strict comparison can start before each group has five cycles | fixed by e109a49

Excluded: issue comments 6440835271 (review-limit notice), 6440914108 (Greptile summary, no new findings).

### Case #95
- K95.1 | greptile-apps[bot] comment 4357611522 | scripts/check-doc-links.sh:74 | cause: the link fragment is compared with heading slugs without percent-decoding | consequence: a valid encoded link such as `#caf%C3%A9` is reported as a broken fragment and fails the quality command | fixed by f61955a
- K95.2 | coderabbitai[bot] comment 4357634898 | plugins/dev-workflow/commands/workflow-init.md:1726 | cause: declining living docs says "leave every other file alone" | consequence: conflicts with Step 3, so the normal setup (AGENTS.md) can be left incomplete | fixed by f61955a
- K95.3 | coderabbitai[bot] comment 4357634908 | plugins/dev-workflow/commands/workflow-init.md:1826 | cause: skip-prefix validation accepts `/docs/history/` and `./docs/history/` while the checker compares against `git ls-files` relative paths | consequence: the chosen archive tree is not skipped and the quality check still fails on it | fixed by f61955a

Excluded: issue comments 6360725933 (review-limit notice), 6360810338 (Greptile summary, no new findings).
