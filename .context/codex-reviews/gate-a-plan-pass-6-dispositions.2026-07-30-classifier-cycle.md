# Gate A (plan) — pass 6 dispositions

Advisory companion to `gate-a-plan-pass-6.md` (5 BLOCKER, 30 MAJOR, 2 MINOR = 37).

**Pass 6 reversed the trend** (19 → 37; B+M 17 → 35) and triggered the cycle's **second
stop-and-surface**. The human's decision: **narrow what the plan promises**, with four
riders — every test keeps its label and its **oracle**; the tested drafts stay parked in
`.context/plan-drafts/` as implementation seeds; the findings that leave scope are
dispositioned **"moves to Gate B" by name**; and the genuine-`NO FINDINGS` expectation
applies to the narrowed artifact unchanged.

**The diagnosis, because it is the disposition for six findings at once.** Findings 1, 2 and
4 are the same shape — *"the plan describes what to write instead of writing it"*. Findings
3, 5 and 10 are defects **in the shell I added at pass 5** to close the same demand at pass
4; finding 5 is that the plan's own helper code failed this repo's ShellCheck policy. Each
fill-in created fresh reviewable surface. The plan was 1732 lines and converging on a
verbatim copy of a test suite Gate A cannot run or lint. It is now **531 lines** and states,
for every test, its label and what it must fail on. The shell is written test-first at
execution and reviewed at Gate B, where it exists as code.

## Moves to Gate B (six), recorded in the plan's own list

1 · 2 · 3 · 4 · 8 · 10 — the expected-message constants, the dual-emitter marker loop, the
raw-hook runner in the C2 rows, the `sed`/`awk` fault shims, the jq-free field comparison,
and the skip branches that must skip their dependents. Each is named in the plan's
**"Findings that move to Gate B"** section with what Gate B must confirm. Finding **5**
(ShellCheck on the plan's shell) **dissolves** — that shell is gone.

## Fixed in the narrowed plan

- **6** — `dash` was claimed and never run. `dash plugins/dev-workflow/hooks/codex-gate.test.sh` is now a named battery member from Task 4 on, with the alternative stated rather than the claim kept.
- **7** — the composition matrix's setup flushed the debt before the observed event. Now a stated sequencing requirement: keep the off-switch on through setup, remove it immediately before the observed event.
- **9** — the real review capture was checked only for count and fingerprint, which `success` and `unrecognized` share. The oracle now asserts the **class**.
- **11** — `restore_cache` ran twice and reported failure on every success. Rewritten as one idempotent cleanup, and the whole shared-cache route demoted to a conditional (see 13).
- **12** — `$L` was assumed to survive between checklist steps. Steps 3 and 7 are now explicitly one shell, one materialization, one cleanup.
- **13** — the capture procedure mutated the globally installed hook, recording every concurrent MCP payload on the machine. **Isolation is now mandatory**: an isolated profile or scratch install, and **stop and surface** if it cannot be established. The shared-cache route survives only as a conditional with its full guard list.
- **14** — the string closer stack made deep nesting quadratic in work an external server controls. **Fixed in code**: nesting past 200 refuses. Verified — a 300 000-deep input now returns rc=2 instead of grinding.
- **15** — the prose said duplicate `type`/`text` refuse "inside the selected element"; the code refuses in **any** element examined. Verified, and the prose now matches the code rather than the other way round.
- **16** — `CODEX_EXECUTION_FAILED` was described as "the call never started". The pinned server uses it generically, so the message now says it does **not** tell you whether the call started, and to check before assuming.
- **17** — the timeout remedy sat in the model's field. Raising an executor timeout is an operator action: moved to `systemMessage`, and `FAILURE_MSG` now carries it instead of claiming there is no operator action.
- **18** — the message had started calling the unreadable mapped tool user-fixable, **contradicting approved spec §6** ("no user-side fix"). That was my pass-5 fix to pass-5 finding 12, accepted without checking it against the spec. Reverted, with the reason: unmapping removes the gate, which is not a fix for the envelope.
- **19** — `awk --version` / `sed --version` are not POSIX and BSD `sed` exits nonzero for it. Verified on this machine. Replaced with functional probes.
- **20** — the ceiling and ambiguity causes promised a check and gave none. They now give one (capture the payload, run the hook against it) and are grouped under "no user-side fix" where they belong.
- **21** — the model-facing strings were flowing paragraphs with inline labels. Now compact tagged sections — `<state>`, `<consequence>`, `<next>`, `<stop>` — inside the single-line encoding A7 requires.
- **22** — `NORESULT_MSG` turned provenance into causality, which spec §6 says the tool name cannot establish. It now says the checks **narrow but do not prove**.
- **23** — the unknown-tool prompt lacked the target-model prefix the other four carry. Added, and its `systemMessage` gains the operator action (see 26).
- **24** — the scaffolded prose promised a once-per-workspace disclosure categorically, which C2 and C4 forbid. Now "attempted and normally once … can be lost or repeated".
- **25** — "Everything else counts" dropped the routing precondition. Now "every other **routed** gate call".
- **26** — "absent" narrowed `no-result`, which also covers null, empty, non-array, non-object, non-text and blank. Now "no usable text". Both this and 25 are added to the load-bearing precision list, which grew from four to six.
- **27** — the counterfactual checked only for `FAIL` lines, so a crash or truncated run read as green. Status **and** completion marker are now required on both runs.
- **28** — the named verification replayed old captures and said it was not a live session, silently weakening story criterion 10. Now: run the live probe in an isolated profile for both variable states, **or obtain and record a human amendment to the criterion before Gate B**.
- **29** — the replay rows asserted nothing about fixture-read status, `sed` status, routing or class, so a missing fixture would print the expected result. Every row is now guarded, with an explicit expected value and an exact row count.
- **30** — side-by-side cache bytes are not an operable rollback. The activation path must be recorded, verified, and the active hook's bytes confirmed — or the release stops.
- **31** — no commit command carried the evidence entry. It is now in the reviewed snapshot's body from the start, revalidated after every fix, and closed with the same validated entry.
- **32** — **verified**: `is_wip_commit` greps for `-m … wip`, so `--amend --no-edit` reads as a real cycle-closing commit and **resets the counters mid-cycle**. Every fix now amends with an explicit `-m "WIP: …"`.
- **33** — `reset --soft "$BASE"` folded every commit since the base, including concurrent ones. Now guarded by an ancestry check and two reads that must be verified before the reset.
- **34** — no task checked the index for pre-staged files. Now a global constraint: `git diff --cached --name-only` must contain nothing outside the task's list.
- **35** — the final `check-version-bump.sh` had no argument, and `main` on this checkout compares HEAD with itself. Now `"$BASE"`, after the squash, with the exact command recorded.
- **36** — "after pushing" named no route and could have meant pushing WIP history to `main`; and CI evidence from before the Gate-B fixes would not cover the final bytes. Both addressed.
- **37** — the counterfactual's trap did not exit on a signal and left the evidence files outside cleanup. Now a cleanup function whose handlers exit, covering both files.
