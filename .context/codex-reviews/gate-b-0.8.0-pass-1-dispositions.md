# Gate-B pass 1 (0.8.0 cycle) — dispositions, spec + quality branches

Advisory companion. Not a findings file, not part of pass validation. Both branch files
validated: terminator present, counts matched (9 and 12), no extra lines, nothing else.

**Cycle-qualified filename on purpose.** The conventional slot name
`gate-b-spec-pass-1-dispositions.md` is already occupied by the 26 Jul cycle's record.
Slot names carry no cycle component, so writing there would have destroyed it — the same
collision §5 documents for findings files, reached through the companion instead.

**21 findings, 16 Blocker/Major. Cycle STOPPED and surfaced to Daniel rather than fixed**,
per his standing instruction for this task: stop rather than squeeze if Gate B opens a new
front. It did. Two findings are design-level and were verified independently here; two more
are defects in prompt text written during this same session.

## Verified independently before reporting

- **QUALITY-1 — CONFIRMED, and worse than "a performance concern".** The locator's
  character-at-a-time `RAWSTR` concatenation and record-at-a-time `s` accumulation are
  super-linear. Measured here, one hook invocation, valid under-ceiling payloads:
  10 KB → 0.2 s · 50 KB → 1.3 s · 150 KB → **10.9 s**. Size ×3 costs time ×8.4. The
  advertised backstop is 1 Mi *units*, roughly 7× the 150 KB case, so a perfectly legal
  result stalls the synchronous hook for minutes. Codex reported ~900 KB still running at
  30 s from its own probe; the curve measured here agrees. This is not exotic input — a
  full Gate-B review result is routinely tens to hundreds of KB. Neither bound bounds
  *time*, and the code comments only ever disclaimed bounding *memory*.
- **QUALITY-2 — CONFIRMED, and it falsifies evidence already committed.** Every general
  runner invokes the hook as `sh "$HOOK"` / `/bin/sh "$HOOK"` (lines 62, 77-79, 388, 625,
  825-827). On this machine `/bin/sh` is **bash 3.2.57 in sh-mode**, not dash. So
  `dash codex-gate.test.sh` runs the *harness* under dash while every hook invocation runs
  under bash. Only the ~7 explicit invariant-1 rows (1182-1186, 1720-1725) actually execute
  the hook with `dash`. The claim "435 green under sh and dash" — in the CHANGELOG, in the
  commit body evidence, and in the Task 5/6 execution-log notes — overstates what was
  tested for the other 428 rows. The dash-specific rows are real and did catch the
  invariant-1 defect; the generalization from them is what is false.

## Defects in text written this session

- **SPEC-7 — VALID.** The P9-30 reason clause added to four shipped prompts says a findings
  file left by a failed attempt "is well-formed and correctly terminated, so no later check
  can tell it apart". A *partial* write can be malformed and IS caught by the
  terminator/count checks. Only a stale, complete, valid-looking file evades provenance. A
  fix for an item-11 overclaim introduced a new item-11 overclaim — the four-round pattern
  AGENTS.md documents, reproduced inside the change that cites it.
- **QUALITY-12 — VALID.** The rewritten unknown-tool `additionalContext` tells Claude to
  install the pinned server and edit `.context/codex-gate.tools`. Spec §6 assigns
  operator-only remedies to `systemMessage`, and the hook's own header comment states that
  rule. The role split is documented and not implemented in the prompt written here.

## Standing-lens findings — the diff falsifies live statements elsewhere

- **QUALITY-8 — VALID.** §5's Mechanics timeout bullet still says an abort "may already
  have moved the hook's counter (the pinned server returns its own timeouts as ordinary
  results)". A recognized immediate-first timeout no longer moves it. The B1 rewrite fixed
  the "What this does not do" paragraph and never reached this one — same file, same
  section, different paragraph.
- **QUALITY-9 / QUALITY-10 — VALID.** `todos.md` still carries this defect as open work and
  describes the hook as inspecting only the tool name; its preflight item states a failure
  mode 0.8.0 falsifies and misstates the C1 residual.
- **QUALITY-11 — VALID.** `docs/superpowers/specs/2026-07-20-codex-file-first-output.md`
  still states the hook keys only on tool name and increments after failed reviews. Two
  approved specs now describe incompatible behaviour.

## Known Gate-A deferrals, now confirmed against the implementation

- **SPEC-1** = P9-6 — escaped `type` value compared as raw bytes, so `text` reads as
  `no-result`.
- **SPEC-2** = P9-12 — `flush_notes` runs on unroutable payloads. Codex adds a detail the
  Gate-A finding did not: on the jq-free path the unrouted event string is interpolated
  into JSON **unescaped**.
- **SPEC-8** = P9-2 + P9-4 — the plan's own contract text disagrees with the shipped
  whitespace sites and comma handling.
- **SPEC-3 / SPEC-4 / QUALITY-4** — the A5 marker matrix and A6 composition coverage are
  narrower than the plan requires; P9-9's skip is real and still printed by name.

## Needs Daniel, not a code fix

- **SPEC-9 / QUALITY-3 — the rollback hard stop.** Daniel chose "document, don't execute"
  today. Codex is right that the plan states a release-blocking condition, and right that
  the finding's own remedy allows "obtain and record an explicit amendment". That amendment
  currently exists only as evidence prose; to satisfy the finding it must be recorded as an
  amendment to the plan's Step 5, the way story criterion 10 was amended.

## Minor — collected, never iterated

SPEC-5, SPEC-6, QUALITY-5, QUALITY-6, QUALITY-7.
