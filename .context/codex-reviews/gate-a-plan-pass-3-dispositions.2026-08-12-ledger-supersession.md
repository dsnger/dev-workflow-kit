# Gate A — plan — pass 3 dispositions

Artifact: `docs/superpowers/plans/2026-08-12-hardening-ledger-supersession.md`
(three findings landed in the spec instead — see below).
9 findings: **4 Blocker**, 2 Major, 3 Minor. All nine valid. **All nine applied.**

Reviewer: `mcp-codex-dev@1.0.1`, `codex-cli 0.144.5`, model `gpt-5.6-sol`. Pass file valid:
10 lines, 9 finding lines, terminator exact.

Plan passes: **18, 11, 9.** Blockers: **2, 1, 4.** The count falls while the severity does not — the
three-pass floor is met and the pass is not clean, so the loop continues.

## The four Blockers

**1 — the plan claimed a spec §8 record that did not exist, and contradicted §6.** Pass 1's
finding 6 offered two exits; the plan half of one was applied and the spec half was not. §6 said the
executable form is *"reviewed by Gate B against the real diff"*, the plan said the opposite, and the
plan's own precedence rule makes §6 govern outside the four held items — so the plan was
self-defeating. Applied in the spec: §6 now says the executable form is **supplied to the Gate-B
reviewer alongside the diff** and is not itself inside the reviewed range, and §8 gains the residual
in full — the checks are never fingerprinted, the `battery+check` evidence is produced by
unfingerprinted code, and a later reader cannot recover which version of a check produced a result.

**2 and 3 — the validation procedure executed the operation the convention forbids, in the file the
convention is being added to.** `C1b`'s counter-check changed a character of the real 2026-07-20
row; `C3`'s moved the real block, and appended and removed a complete entry. §2.1 protects a row the
moment it exists, committed or not, and §2.2 protects a complete entry the same way — neither waits
for a commit. Applied as a plan-wide rule with a stated boundary: **no counter-check may mutate a
row or a complete entry in the real ledger**; every such mutation runs against a scratch copy with
the check pointed at it. Mutations to *prose* — a header paragraph, an anchored clause — are covered
by neither rule and stay in place, which is why `C1c` and `C2a` are unaffected.

**4 — the consolidation reopened the pass-2 staging blocker.** `git reset --soft $BASE` leaves
whatever accumulated since `BASE` staged, which is not the same as the intended set, and Task 8
declares no modified files, so the mandated exact-set assertion had nothing to compare against.
Applied: the five tracked paths are named in the step — `docs/hardening-log.md`,
`plugins/dev-workflow/commands/workflow-init.md`,
`plugins/dev-workflow/.claude-plugin/plugin.json`, `plugins/dev-workflow/CHANGELOG.md`, `todos.md` —
re-staged explicitly after the reset, with the cached set asserted equal to that list.

## The two Majors

**`ledger-unreadable` was routed nowhere.** Its expected cell said "every label that reads it, `C3`
included", so Task 4's `C1a`/`C1d` run excluded it and Task 5 checked only `C3` — leaving the
read-failure oracle unexercised for six labels. Now the cell names all seven, Task 3 gained a step
running it for `C2a`/`C2b`, Task 4's run widened to `C1a`–`C1d`, and Task 5 keeps `C3`.

**The matrix declared outcomes "under both `sh` and `dash`" and no step required both.** A
shell-specific parser defect would have survived behind a happy path that passes twice. All three
matrix-running steps now require both shells.

## The three Minors

The `grep -F` rationale was **factually wrong in the direction that matters**: fixed-string grep
treats each line of a multi-line pattern as a separate pattern, so it never establishes the
contiguous sequence and can exit 0 on a component line — a false *positive*, not the "clean absence"
the plan claimed, which would have had the executor self-test the wrong failure mode. The anchor
data claim said **two** anchors begin with `-`; exactly one does, and five contain backticks — the
error was in the spec's §6 oracle as well and both are corrected. `C1e`'s rationale carried a
totality claim ("can only be made to fail by mutating the table by hand") when an unreadable ledger
fails it too; narrowed to the spec's own wording.

## Sweep after applying

Step numbering contiguous in all eight tasks (Task 3's insertion renumbered to eight steps); the
false "two begin with `-`" claim gone from both artifacts; the §8 harness residual present; the
scratch-copy rule stated globally and at both counter-check sites; 35 anchors byte-identical; 12
fence lines, balanced.
