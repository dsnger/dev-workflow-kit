# Sequential single-branch Gate-B calls, counted as one pass — Design

**Story:** `docs/superpowers/stories/2026-08-14-sequential-branch-calls-hook-story.md` — read its profile fresh at each pass.

**Date:** 2026-10-09 · **Decided with:** Daniel (story amendment, AC-7 narrowed, 2026-10-09); the design choices in §3 are the author's, made under Daniel's instruction for this unit ("ask me only for triage decisions and blockers") and open to Gate A.

## 1. Problem, as it stands on 2026-10-09

`reviewType: full` runs the spec and quality reviewers in parallel. Nothing binds a reviewer to
its own findings slot, so both can write both paths, and the surviving files pass every shape
check (story §1, PR #23). It recurred in SFX P4c and in this repository's PR #45 cycles
(`todos.md`, G3d). The fix the story records — two sequential single-branch calls,
`reviewType: spec` then `reviewType: quality` — removes the second writer. It cannot ship as
prose alone, because the hook (`plugins/dev-workflow/hooks/codex-gate.sh`, PostToolUse branch for
`$review_tool`) bumps `codex-gate.passCount` once per successful call. A pair would count twice,
and the hook would print its ✓ after one and a half logical passes.

What changed since the story was written, and how this spec reads the story because of it:

- §5 now lives in `.claude/review-gates.md` (0.16.0). `CLAUDE.md` says every "§5" means that
  file, so AC-6's "`CLAUDE.md` §5" reads as `.claude/review-gates.md`, and its "inline mirror"
  as `/workflow-init`'s template `### 2.1a`.
- The floor a cycle owes is now derived by the agent from the cited stories; the hook's number is
  "a reminder threshold that controls nothing" (`.claude/review-gates.md`, "The derived floor is
  the pass count a cycle owes"). So AC-2's "count toward the floor" reads as **the hook's count
  toward its reminder threshold**. The defect is unchanged in kind: a hook ✓ over half a pass is
  a false ✓ in the reminder, the direction AGENTS.md invariant 2 calls dangerous.

## 2. Answers to the story's open questions

1. **Binding.** A pair is bound by the request's `baseSha` and `headSha` — both must be present,
   each a full 40-character lowercase hex object name, and exactly equal across the two calls.
   This is the rule §5 already states for summing two branches (Mechanics, the paragraph on
   branches of one logical pass: the kept `baseSha` and `headSha` must be exactly equal); the
   hook now applies the same rule instead of a second one. The tool's own `headSha` defaults to
   the symbolic `HEAD`, which is why an absent `headSha` is unusable rather than defaulted.
   Commit ids are content-addressed, so the binding is not an event binding in invariant 3's sense; invariant 3 itself (the fingerprint check) is unchanged.
   `sessionId` is rejected as the key: the two sequential calls have different sessions by
   construction. A caller-written marker is rejected: it is one more thing to forget, and §5
   already demands the two SHAs.
2. **`full`.** Left working, counted exactly as today: one call, one pass. §5 stops recommending
   it and says why. Refusing it would break every downstream project still on an older template
   for a defect that only loses findings in the files the agent reads — which the agent can be
   told about, while a refused call cannot be told anything.
3. **Floor semantics or counting?** Counting. A logical pass is unchanged; the hook now counts a
   completed pair as one increment instead of two. That makes its count agree with logical passes
   **only where every call it saw produced a valid findings file**: the hook still never reads the
   file (§5, "What this does not do"), so a call that returns success over an invalid file is
   counted, and a fresh re-run of one branch is indistinguishable from the first branch of the next
   pass and can shift later pairing. §5's rule — discount every incomplete pass whatever the counter
   says — stands unchanged and is what covers this.
4. **Gate A.** Nothing is owed. `mcp__codex__exec` has no branches; its counter is untouched.

## 3. Design

### 3.1 State

One new file, `.context/codex-gate.pendingBranch`, holding a single line
`<branch> <baseSha> <headSha>`, where `<branch>` is `spec` or `quality`. It is a gate-pass state
file like the pass count. Absent means "no branch waiting".

**The Gate-B counters change unit, so they change name.** `codex-gate.passCount` and
`codex-gate.freshCount` counted calls; the new hook counts passes into `codex-gate.passes` and
`codex-gate.freshPasses` and never reads the old names. A cycle that spans the upgrade therefore
starts the new count at zero — an under-count, the safe direction — instead of inheriting calls
counted one by one. The new hook **retires the old names** wherever it would otherwise touch Gate-B
state: on a review call that classification lets through (never on `failure`, `no-result` or
`backgrounded`, which still touch nothing), at the commit check, and at every reset. Retirement
is governed by the rule below, so a rollback cannot find legacy counts beside a fingerprint the
new hook wrote.

**No credit over stale state.** A credit — any run of today's counting block — happens only after
every stale file it depends on is confirmed gone: the legacy counter names, and for a `full` call
the superseded pending file. "Confirmed gone" means the path no longer exists after the removal
attempt. Where one survives, the call credits nothing, writes no fingerprint, and notes which path
could not be removed and that `.context/` writability is the thing to check. Removal and file
writes can fail independently (an unwritable directory still lets existing files be
overwritten), which is why the test is the path's absence and not the success of the write.

**Consumption is exclusive.** A call that may complete a pair first **claims** the pending file by
renaming it to a name unique to this hook process (`mv` inside `.context/`, which is one
`rename(2)` — atomic, so at most one process can claim a given pending file). Only the claimant
reads it; a call whose rename fails sees no pending branch. A claimed record that matches credits
the pair; one that does not is discarded and this call becomes the new pending branch. The claim
file is then removed best-effort; a leftover claim file is never read again. So a pending branch
can credit at most one pair, even when removal fails or two hook processes race — a failed rename
credits nothing, which is the safe direction.

### 3.2 PostToolUse on the review tool

Classification is unchanged and still comes first: `failure`, `no-result` and `backgrounded`
touch no state, the pending file included. For `success` and `unrecognized`, read `reviewType`,
`baseSha` and `headSha` **from the `tool_input` object only** — never from `tool_response`, whose
review text can quote any of those names. On the `jq` path that is `.tool_input`. On the `jq`-free
path a small scanner walks the payload, tracking string and escape state and brace depth, finds the
top-level `"tool_input"` key, and reads only the **direct** string members of that object up to its
matching closing brace. Property order and sibling fields do not matter, because the boundary is
the object's own closing brace. If the scanner does not reach that brace, or finds no top-level
`tool_input`, the read is uncertain. A field that is not a direct member of a fully scanned
`tool_input` is absent. **Absent and unreadable are different**: a `reviewType` key
present in `tool_input` whose value cannot be extracted, or a `jq` that fails, is uncertain, and an
uncertain read counts nothing and says so. Only a confirmed-absent `reviewType` takes the `full`
row, because the tool defaults to `full`.

| `reviewType` | What the hook does |
|---|---|
| confirmed absent, or `full` | Retire any pending file first, since a whole pass supersedes a half one (the claim of §3.1, then removal of the claim file; under "No credit over stale state" a pending file that cannot be retired blocks the credit). Then today's block unchanged — fingerprint, fresh count, pass count +1. |
| `spec` or `quality`, SHAs unusable (absent, or not 40 lowercase hex) | Count nothing, change no pending state, and note that the branch cannot be paired and why. |
| `spec` or `quality`, the claimed record holds the **other** branch with identical `baseSha` and `headSha` | The pair is complete: run today's block once. |
| `spec` or `quality`, anything else (nothing claimed, the same branch again, or different SHAs) | Count nothing; write this call as the pending branch, replacing what was there. Read it back: if it reads back as written, note that one branch is recorded and the other is awaited on the same `baseSha`/`headSha`; otherwise note only that recording **could not be confirmed** — the write may have failed, the file may be unreadable, or another hook process may already have claimed it — so the pass may not be counted, and name `.context/` writability and concurrent review calls as the things to check. |
| any other value | Count nothing, change no pending state, note the unrecognized value. |

The last row is the loose-firing direction: a value the hook does not know is not credited.

Order inside a pair does not matter. A retry of the failed branch (§5's single-branch recovery)
pairs with the waiting one, because a failed call wrote nothing.

### 3.3 Commits

A non-`WIP` commit already removes the fingerprint and the Gate-B counters; it now also removes
the pending file (and, per §3.1, the old counter names). A WIP commit keeps it, but a branch issued after a WIP commit carries the new
`headSha`, so it does not pair with a branch issued before — the pair is rejected rather than
merged across two revisions, as §5 already requires.

### 3.4 Commit-time reminder

When the pending file exists at a Gate-B commit check (the branch that today prints the floor or
✓ message), the hook adds a note saying that pending-branch state is present, so a single-branch
call may have run whose partner was never credited, and that state is not counted. Existence is
the test, not a parse — the note claims neither that the record is usable nor that its partner can
still complete it, so an unreadable or empty file is reported without being mistaken for a usable
half, and the conservative direction is kept. It is added beside whichever message that branch
prints, so a ✓ earned by earlier complete pairs can no longer be read as covering the half pass
(AC-2).

### 3.5 Rule text, both copies

In `.claude/review-gates.md` and `/workflow-init`'s template `### 2.1a`:

- Gate B's tool line: the default call shape is two sequential single-branch calls, `spec` then
  `quality`, each with the same `baseSha` and `headSha`, **both resolved to full 40-character
  lowercase object names before the first call** — the WIP-parent `baseSha` included. `full` stays
  accepted and is counted as one pass, but its two reviewers can write each other's slots and the
  result passes every shape check, so it is not the default.
- **Each single-branch call names only its own slot** in its `additionalContext`, and the
  delete-before-call rule deletes only that call's own target. Deleting both before the second
  call would destroy the completed partner's file. The same holds for a single-branch recovery,
  which §5 already scopes to "only the failed branch".
- "Gate B takes one file per branch": keep, and say the race is `full`'s.
- "What a pass is read from" and "Accept a pass only when": a Gate-B pass has two branch files
  whichever call shape produced them, not only under `full`.
- "the curve counts logical passes; the hook counts calls": the hook now counts a `full` call or
  a matched pair as one pass; other shapes (a half pair, a single-branch call with unusable SHAs)
  are not counted.
- The template's "The hook counts passes by TOOL NAME … and by RESULT ENVELOPE" gains the pairing
  rule.
- The `baseSha` Mechanics bullet says both endpoints are passed as full 40-character names, so it
  agrees with the branch-agreement paragraph.
- Any further sentence this falsifies, found by the Gate-B standing lens and by grepping
  `reviewType`, `full`, `in parallel` and `counts calls` across both copies, the README, `docs/`
  and the CHANGELOG.

### 3.6 Packaging and backlog

- `plugin.json` 0.20.0 → 0.21.0 and a CHANGELOG entry (invariant 12).
- `todos.md`: the "`reviewType: full` races" row closes, naming this story; the G3 follow-up line
  moves to the next item.
- No `docs/hardening-log.md` row (story AC-7 as amended).

## 4. Risk lenses (story profile: risk `high`)

- **Threats / abuse.** The pending file sits under `.context/`; anyone who can write it can
  already write the pass count. No new trust boundary.
- **Data loss.** The change removes the data-loss path by moving the default off `full`. It does
  not detect a `full` race after the fact; that stays a disclosed residual of `full`.
- **Idempotency.** A repeated branch replaces the pending one; a complete pair consumes it by claim; so no
  sequence of single-branch calls credits more than one pass per completed pair.
- **Concurrency.** Two hook processes over one pending file: the atomic claim (§3.1) means at most
  one credits it. Interleavings can still drop a pair — both calls find nothing to claim and each
  writes itself as pending — which under-counts, the safe direction. **Not covered, and not new:** a
  review hook running at the same time as a non-`WIP` commit's reset can write counters after the
  reset — today's hook has the same window for every pass, and a claim adds one more instance of it
  (a claimed pair credited after the reset). §5's sequential-passes rule is what keeps it rare; no
  lock is added.
- **Compatibility.** Projects calling `full` see no change. A project on an older template that
  makes single-branch calls without 40-hex SHAs stops being credited for them and is told why —
  the safe direction. An old hook ignores the new file.
- **Upgrade.** The renamed counters (§3.1) mean a cycle spanning the upgrade starts the new count
  at zero: an under-count, never an inherited per-call count.
- **Rollback and re-upgrade.** A rollback restores per-call counting while the rule text says to
  make two calls — the old defect, back with the old hook. The old hook never touches the new
  files, so after a rollback they can hold a stale pass count or pending branch that a later
  re-upgrade would read, and the fingerprint file `codex-gate.gateB` is shared by both. The
  CHANGELOG entry gives the procedure: after rolling back, delete every Gate-B state file —
  `.context/codex-gate.gateB`, `.context/codex-gate.passes`, `.context/codex-gate.freshPasses`,
  `.context/codex-gate.pendingBranch`, `.context/codex-gate.passCount` and
  `.context/codex-gate.freshCount` — so the old hook starts its cycle from nothing. What is left unguarded is a
  rollback or re-upgrade with that step skipped.
- **Observability.** Every non-counting path writes a note naming why.

## 5. Acceptance mapping and evidence

| Story criterion | How it is met |
|---|---|
| AC-1 | Suite: three spec→quality pairs give a pass count of 3 and a satisfied message at threshold 3. |
| AC-2 | Suite: one complete pair then a lone spec branch — count 1, the commit check prints the pending note; and three pairs plus a lone branch print the ✓ **with** the pending note. |
| AC-3 | Suite: a `full` call and a call with no `reviewType` each count one, as today. |
| AC-4 | Suite cases: both succeed; first fails (`success: false` envelope) then pair completes on retry; second fails; a WIP commit between branches (no pair, with `jq`); a non-`WIP` commit between branches (pending removed); `full`; plus unusable SHAs, unknown `reviewType`, quality-before-spec, a pending file that cannot be claimed (no credit), a pending write that does not read back (the could-not-confirm note), SHA names present only in `tool_response` (no credit, both parse paths), on the `jq`-free path `tool_response` before `tool_input` (pairs normally — order does not matter) and a sibling field after `tool_input` carrying a missing SHA (no credit), an unclosed `tool_input` (uncertain, no credit), a legacy counter or superseded pending file that cannot be removed (no credit, note names the path), an old-name `passCount` of 3 at upgrade (ignored), and a reset removing old and new counter names. |
| AC-5 | Every new case asserts exit 0; the suite runs under `sh` and `dash`; the jq-absent path is exercised for the pairing cases. |
| AC-6 | Both copies edited in the same commit; Gate B reads both. |
| AC-7 | The `todos.md` row is already re-pointed (2026-08-16); it closes in this change. |

**Evidence mode `battery+check+verification`:**
- *Check:* the AC-1 suite case, which fails against the 0.20.0 hook (it counts 6).
- *Named verification of the risk path* — "pair-counting replay": a scripted run of the hook from
  this branch and the hook from `205efd3`, each from a fresh `.context/`, over the same real git
  repository and the same payload sequence, under `sh` and `dash`, with and without `jq`,
  recording the pass count (`passCount` for the old hook, `passes` for the new) and the
  commit-time message at named checkpoints:
  - **C1, after three uninterrupted pairs** — the counterfactual: `205efd3` reports 6 and its ✓;
    the new hook reports 3. Same expectation with and without `jq`.
  - **C2, a lone spec branch then a commit check** — the new hook prints its count with the pending
    note; `205efd3` prints a ✓ with no mention of the half pass.
  - **C3, a `WIP:` commit between a spec and a quality branch** — expectations differ by `jq`, as
    the existing WIP rules already do (suite case `m7`): with `jq` the counters survive the WIP
    commit and the quality branch, carrying the new `headSha`, does not pair; without `jq` the hook
    cannot attribute the commit and resets, the pending file included.
  The wiring could produce the false observation because both hooks read the identical payloads
  in the same repository from the same starting state.
- *Concurrency check:* two hook processes completing against one pending file — by a test that
  claims it from two processes — credit at most one pass.

## 6. Out of scope

- Detecting a `full` race after the fact (provenance inside findings files).
- The PR #26 "both branches misread each other" prompt line (`todos.md`, "From PR #26"); it
  concerns `full` only and stays where it is.
- A general lock around hook state; only pending-branch consumption is made exclusive (§3.1).
