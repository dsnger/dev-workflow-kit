# Kit 0.40: five field cases from the hook count and the plan budget — Design

**No story:** the work comes from the orchestrator brief
`.context/sparring/20261022-021000-kit-040-prompt.md` (five field cases, 2026-10-20 to 2026-10-22);
there is no story file.
**Profile (derived, as intake does):** `risk high; security none; evidence battery+check` — risk `high`
because it changes the gate rules and the hook's Gate-A count (shared contracts every initialized
project follows); security `none` because no secret, permission or trust boundary is touched;
`battery+check` because checks 4i/4j measure the two rule copies and the hook suite pins the count.
**Date:** 2026-10-22 · **Version:** dev-workflow 0.40.0 (minor: a gate rule and the hook's count change).

## Decisions

Taken in this note (autonomous run, CLAUDE.md §4), each a choice, not a source fact. One Gate A covers
spec and plan: the plan is §7 of this note, as in 0.38.0.

| # | Case | Verdict | Reason |
|---|---|---|---|
| 1 | Gate A counts a re-fetch `exec` | **adopt** | The re-fetch carries a structured field the hook can read (`sessionId`), so the hook stops counting it; no text filter. |
| 2 | Closing commit: content not confirmed | **adapt** | The fingerprint stays as invariant 3 defines it; the rule names the commit form that lets the hook's existing docs-only path read the closing commit. |
| 3 | Chained subagent commit inside a cycle | **adapt** | The reference names refused forms but not that a subagent's note stays in the subagent; the rule puts cycle commits in the main session and the reference says why. |
| 4 | 197-line cutoff without a why | **adopt** | One clause in the rule; `docs/reference.md` already names the field case. |
| 5 | D16 budget vs final-head evidence | **adapt** | The 0.39 text lists "each run it expects", which includes final-head evidence only by reading; one clause says so and where it counts. |

## 1. Evidence

- **Case 1.** Canvas transcript `~/.claude/projects/-Users-daniel-DEVELOPMENT-APPS-infinite-portfolio-canvas/d2bb3e2e-d8b0-49c8-8d5f-c0d36366bf71.jsonl`,
  2026-10-21: six `mcp__codex__exec` calls. Five real passes (spec cycle `s4vorq3k` passes 1–2, plan
  passes 1–3) carry no `sessionId`; the one call that only re-fetched ("Your reply was truncated in
  transport. Write your complete findings, verbatim…", 09:31) carries `sessionId`. The hook counted it
  (board 2026-10-21 11:49: third field case; `todos.md` row "Gate A counts an `exec` call that only
  re-fetched truncated output"). The `exec` tool's schema (pinned server) has `instruction`,
  `sessionId` ("Resume an existing session by ID") and `workingDirectory`.
- **Case 2.** Canvas closing commits `bcf1b14` (cycle `s4nachl1`) and `04b55a0` (`s4bau2gb`) each change
  only `todos.md`. Their commands were `cd … && git add todos.md && git commit -q -F - <<'EOF' …` and a
  `cat > msg <<EOF` followed by a commit. `names_no_paths` (`codex-gate.sh`) offers the docs-only note
  only to a command that is exactly `git commit` plus listed options, so these fell through to the
  fingerprint check, which saw `todos.md` changed after the last review and reported "cannot confirm".
  Inference: a plain `git commit -F <file>` after a separate staging call would have taken the
  docs-only path (`-F <file>` is an accepted option; `todos.md` is in `is_docs_only`). The earlier
  empty closing commit (canvas #46) is **not reproduced here**: an empty commit with nothing changed
  computes the reviewed fingerprint again; its cause is unknown and stays open (§6).
- **Case 3.** Board 2026-10-21 (canvas S4 unit 2): hook saw 2 of 3 passes after a chained commit from
  a subagent; the brief names the cause as known. `docs/reference.md` § Hook messages names `cd`,
  `git -C`, chains and heredocs as refused WIP forms, but not subagents. The hook runs for a
  subagent's tool calls too and writes the same `.context/` state; its note goes to the session that
  made the call, so the main session never sees why its count dropped.
- **Case 4.** sfx-wp-plugin-skills PR #34, Codex Minor (checklist item 6, rule without its why). Field
  case: sfx-bricks-child PR #66, 197 production lines (0.38.0 spec §1).
- **Case 5.** Board 2026-10-21 22:13: canvas S4 unit 2 exceeded the 2-hour budget because the final-head
  evidence chain (`pnpm quality` ~85 min, WP chain ~110 min) came on top of a full gegenprobe (~105 min).

## 2. Case 1 — the hook does not count a resumed `exec`

- PostToolUse on the Gate-A tool: after classification, a `success` or `unrecognized` call whose
  `tool_input.sessionId` is a non-empty string is **not counted**; the hook adds one note saying so.
  A call without the field, or with an empty string, counts as today. `failure`, `no-result` and
  `backgrounded` keep their existing discard path. The cap check runs as today.
- Read with the existing `input_field`. With jq it reads `.tool_input.sessionId` exactly. The jq-free
  path takes the first key after the last `"tool_input":{`, so a structured `tool_response` could answer
  for the input; the new check therefore cuts the payload at the first literal `"tool_response"` before
  the jq-free read (an escaped `\"tool_response\"` inside a string does not match). Where a payload put
  `tool_response` before `tool_input`, the cut leaves no input, the call counts, and the hook behaves as
  in 0.39 (an overcount, never worse than today).
- **Build deviation (recorded at Gate B pass 1):** the jq-free read does not call `input_field`. It
  greps the text between the first `"tool_input"` and the first `"tool_response"` key for a
  `"sessionId"` key with a non-empty string value. Why: `input_field`'s jq-free path decodes with awk,
  and with a broken awk (section 39a, partial output) that decoding printed text, which read as a
  `sessionId` and dropped the count; the gate must stay fail-open there. With jq, `input_field` is used.
- **What it lets through / the direction.** A real pass that resumes a session is not counted, so the
  hook reports fewer passes than were run: the firing direction (invariant 2), never a false ✓. A
  third-party exec tool mapped via `.context/codex-gate.tools` whose input uses another field name for
  resumption is counted as today. Not checked, and the list is not exhaustive: whether a resumed call
  reviewed anything.
- **Rule text:** none added to `.claude/review-gates.md` (the cap leaves no room, and a re-fetch
  resumes the session naturally: the field case did it unprompted). `docs/reference.md` documents the
  behaviour and the consequence of resuming a real pass.
- **Note text** (target model Claude via Claude Code, prompt-standards items 1, 6, 10):
  context: `Claude via Claude Code — gate hook. <state>This mcp__codex__exec call carries a sessionId in its input, so it resumes a Codex session and is not counted as a Gate A pass.</state> <next>A call that fetches the rest of a truncated reply belongs to the pass it completes. If this call was a pass of its own, run it again without sessionId, because a pass reviews the artifact as it stands, not as an earlier session saw it.</next>`;
  user line: `ℹ Codex Gate A: resumed session not counted as a pass`.
  The tool name in the text is `$exec_tool`, as the other messages interpolate it.

## 3. Case 2 — the closing commit's form

- **Fingerprint unchanged.** Excluding `todos.md` or a cycle record from the fingerprint would change
  invariant 3 for every project and would let a `todos.md`-only edit after review commit with a ✓; the
  rules already call a `todos.md`-only commit docs-only, so a narrower fix exists.
- **Rule** (Gate-B section): the closing act's commit is made by staging first, then one plain
  `git commit -F .context/<msg>` call (the message file under `.context/`, which the fingerprint
  excludes, so writing it after the review changes nothing the hook compares), with `--allow-empty`
  when nothing is staged (a zero-finding cycle with
  no `todos.md` row still owes a commit carrying its record lines). Why, in the rule: that form is the
  one the hook's docs-only check reads. The rule promises the check, not its result: the note comes
  only when the staged list is non-empty and every path passes `is_docs_only`. A closing commit that
  stages more than docs, or nothing, reaches the full fingerprint check (the direction invariant 2
  wants); for an empty commit after an unchanged tree that check matches the reviewed fingerprint.
- **What it lets through:** nothing new — the docs-only path and its guards (`names_no_paths`,
  `is_docs_only`, prompt paths excluded) exist since 0.2.x and are unchanged.
- `docs/reference.md` § Hook messages, "Cannot confirm reviewed content": add the cause "a closing
  commit made with a chain or heredoc, which is not offered the docs-only note".

## 4. Case 3 — cycle commits from the main session

- **Rule** (same Gate-B sentence): each commit before the closing act is made in the main session,
  with the why "only it sees the hook's note".
- `docs/reference.md` § Hook messages, "Not counted as a WIP commit": one paragraph — the hook runs for
  subagents' calls and shares the cycle state; a subagent's commit resets the count where the hook
  does not recognise it, and the note stays in the subagent; implementer subagents leave their changes
  uncommitted and the main session makes the cycle's commits.
- **Hook message unchanged.** It reaches the subagent, which is the session that needs it there.

## 5. Case 4 and case 5

- Rule: `≤197 lines (the field fix it was set on) added+deleted`.
- Repo `CLAUDE.md` §4 and the `/workflow-init` CLAUDE.md template, Plan bullet: "…how often it runs;
  evidence run on the final head counts in the unit that runs it…". `docs/coding-workflow.md` gets the
  same clause.

## 6. Size, docs, open items

- **Rules bytes.** 9,997 before. Added: case 2/3 text and the case 4 clause. Moved to
  `docs/reference.md` § Optional companions (Context7 already lists the examples there): the examples
  "(not loaded, rate-limited, not indexed)" and "(docs, installed types, a probe with the pinned
  binary)", and the sentence "Nothing mechanical proves a lookup; the named line is the record."
  Dropped as duplicate: "and its record lines" (the closing-act paragraph requires them in the same
  commit). Measured on the drafted text after pass 2: 9,999 bytes (≤ 10,000; the build measures the implemented text again), both copies identical (4i, 4j). To fit,
  the draft also shortens wording without dropping a condition: "the main session (only it sees the
  hook's note) makes each commit", "which a subject ending in `(WIP)` is not", and the case 4 clause
  reads `(its field case)`, with the case itself named in `docs/reference.md`; the closing recipe
  reads `git commit -F .context/<msg>` (`--allow-empty` if none staged).
- **Conditions accounting** (AGENTS.md Don'ts, decision procedure): the Gate-B commit sentence keeps
  its conditions (plain subject; WIP recognition; `(WIP)` not one; non-WIP closing subject) and adds
  two; the record-lines condition moves to the closing-act paragraph, which already holds it; the
  Library APIs paragraph keeps every condition (lookup, version, note, fallback, no memory, data not
  authority) and moves only examples and the enforcement disclaimer.
- Docs: README if it describes the counting; `docs/reference.md`; `plugins/dev-workflow/CHANGELOG.md`;
  `docs/hardening-log.md` row for case 1 (rung 4, test); `todos.md`: close the 0.37.2 re-fetch row;
  add a row for the unreproduced empty-closing-commit case.
- **Open, not done here:** the canvas #46 empty closing commit (cause unknown); Gate B's
  `mcp__codex__review` also takes `sessionId`, but no field case of a resumed review exists.

## 7. Plan

Handover boundary: the merged PR. No run of 45 minutes or more (battery ~5 min; prompt eval once).
Sources and impact boundary: `codex-gate.sh` (exec branch, `input_field`, `names_no_paths`,
`is_docs_only`), `codex-gate.test.sh` (sections 29d, payload builders), `.claude/review-gates.md`,
`workflow-init.md` `### 2.1a` and CLAUDE.md template, repo `CLAUDE.md`, `docs/reference.md`,
`docs/coding-workflow.md`. No third-party library API is used (Context7 not applicable).

1. **Hook, case 1** (test first). Tests: an exec success with `"sessionId":"abc"` in `tool_input`
   leaves the Gate-A count unchanged and emits the exact note (jq and jq-free); with
   `"sessionId":""` it counts; without it counts (existing); a failure envelope with a `sessionId`
   still takes the discard note, not this one; an unrecognized envelope with a `sessionId` is not
   counted either; a `tool_response` containing an escaped `\"sessionId\"` in its text and no input
   field counts (jq-free). → verify: suite under `sh` and `dash`.
   Case 2 tests (pin the recipe the rule prescribes; behaviour unchanged): after a credited review, a
   staged `todos.md` with `git commit -F .context/msg` gets the docs-only note; the same staged list
   with a chained `git add todos.md && git commit -F .context/msg` gets "cannot confirm"; a staged
   `todos.md` plus `app.ts` with `-F .context/msg` gets the full check; `git commit --allow-empty -F
   .context/msg`, with `.context/msg` written after the review and nothing else changed, gets the ✓ line.
   Case 1 adds: a jq-free payload whose `tool_input` has no `sessionId` and whose structured
   `tool_response` carries `"sessionId":"x"` counts.
2. **Rules, cases 2–4**: edit both copies, measure bytes. → verify: checks 4i, 4j.
3. **CLAUDE.md, case 5**: repo and template. → verify: 4e, 4g.
4. **Docs** per §6. → verify: `check-doc-links.sh`.
5. **Version** 0.40.0, CHANGELOG; prompt eval once before the bump; battery. → verify: battery exit 0.
