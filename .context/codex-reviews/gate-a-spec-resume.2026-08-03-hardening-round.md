# Gate A — spec cycle — resume note

**Cycle:** hardening round over the 0.8.0 cycle and PR #21.
**Spec:** `docs/superpowers/specs/2026-08-03-hardening-round-0-8-0-and-pr-21-design.md`
**Story:** `docs/superpowers/stories/2026-08-03-hardening-round-0-8-0-and-pr-21-story.md`

## State

Three valid passes run and accepted (file-first protocol satisfied each time: terminator
exact, counts matched, no non-finding body lines). The 3-pass floor is **met**; the
final-pass-clean requirement is **not**.

| Pass | Findings | Major | File |
|---|---|---|---|
| 1 | 19 | 12 | `gate-a-spec-pass-1.md` + dispositions |
| 2 | 15 | 11 | `gate-a-spec-pass-2.md` + dispositions |
| 3 | 19 | 14 | `gate-a-spec-pass-3.md` + dispositions |
| 4 | 12 | 5 | `gate-a-spec-pass-4.md` + dispositions |
| 5 | 9 | 4 | `gate-a-spec-pass-5.md` + dispositions |
| 6 | 10 | 4 | `gate-a-spec-pass-6.md` + dispositions |

**Paused at pass 3**, not through exhaustion: two named story exits tripped (machinery in the
skill edit; §5 insertions that were paragraphs rather than clauses), both pre-declared by
Daniel as exits rather than judgement calls. He chose to re-scope and resume: the
`harden-finding` change was split into its own story, the §5 additions were cut back to one
sentence each, and the loop continued from pass 4 on the revised artifact.

Every finding of passes 1–6 was accepted; none was dismissed. Seven reopened human-confirmed
decisions and were taken back to Daniel rather than applied unilaterally.

## Prior cycle's artifacts

The 0.8.0 classifier cycle's spec-slot files were **archived, not destroyed**, before this
cycle's first call: 17 files renamed to `*.2026-07-30-classifier-cycle.md`. The parked row
"Each Gate cycle destroys the previous cycle's review record" documents that loss; it did not
recur here.

## Resuming

Awaiting Daniel's decision on the split. Whatever the shape:

- Pass 3's findings **4, 7, 8, 12, 14, 17, 19** and minors **2, 3, 15, 16** stand regardless
  of how the work is divided — they are defects in the current spec and story text, not
  artifacts of scope.
- Finding **12** is the one to carry first: the Row B precheck verdict is wrong (C5 is inside
  the 2026-07-19 Don't), which is the single-row error pass 2 identified, committed inside the
  spec that fixes it.
- Any resumed cycle restarts pass numbering at 1 against the revised artifact. The three
  passes recorded here do not carry over — they reviewed a spec that no longer exists in that
  form.

## Environment observation, for the `CLAUDE_CODE_MCP_AUTO_BACKGROUND_MS` todos row

`CLAUDE_CODE_MCP_AUTO_BACKGROUND_MS=0` for the whole session. Wall clock taken from `date`
stamps immediately before and after each call:

| Pass | Start | End | Duration | Returned |
|---|---|---|---|---|
| 1 | not stamped | not stamped | **not timed** | foreground, `success: true` |
| 2 | 20:07:53 | 20:15:31 | **458 s** | foreground, `success: true` |
| 3 | 20:20:27 | 20:29:37 | **550 s** | foreground, `success: true` |
| 4 | 08:12:55 | 08:25:32 | **757 s** | foreground, `success: true` |
| 5 | 08:32:40 | 08:43:43 | **663 s** | foreground, `success: true` |
| 6 | 08:46:56 | 08:59:56 | **780 s** | foreground, `success: true` |

Five timed calls, all far past 120 s, none auto-backgrounded, each returning an ordinary
envelope the hook could read.

**No control run was made** with the variable unset, so this is a correlation observed under
one setting, not a demonstration that the variable is what held the calls in the foreground.

**Correction, recorded because it is the round's own subject matter:** the spec cited this note
for four durations including "671 s". This note recorded only passes 2 and 3 at the time, and
663 s is the correct figure for pass 5 — 671 was arithmetic error. Caught at Gate-A spec
pass 6, in evidence attached to a rule about unsupported coverage claims.
