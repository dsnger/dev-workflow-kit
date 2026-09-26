# Gate A (spec) — closure record, result-classification cycle

## How it closed

EIGHT passes. MAJOR counts: 17, 13, 14, 4, 7, 7, 6, 6. Every pass was VALID (file present,
terminator exact, count matching, all body lines finding lines).

**Gate A closed on JUDGEMENT, not on a NO FINDINGS pass.** That is recorded plainly so nobody
later reads this cycle as having ended clean. The final pass returned 6 MAJOR; all six were
fixed, and none challenged the design core — the five classes, the fail-open/fail-closed
split, the state effects and the message structure have been stable since pass 6. Passes 7-8
returned peripheral findings: scope discoveries in shipped files, and encoding edges.

Human decision, after the trend was surfaced: accept with residuals, carry the obligations
into the plan, and expect the PLAN's Gate A to reach a genuine NO FINDINGS — its material is
implementation-grade and therefore decidable. **If the plan's Gate A also ends on judgement,
STOP and surface: two judgement exits in one cycle is a pattern, not a coincidence.**

## Carried obligations — a CHECKLIST for the top of the plan

Each item is checked off or explicitly re-dispositioned during the plan's own Gate A. None
evaporates between artifacts.

### A. Implementation contracts (spec §11)
- [ ] 1. The jq-free scanner as a state machine: quote state, backslash parity, value
       boundaries, operational meaning of "depth 1".
- [ ] 2. Duplicate depth-1 keys and malformed-JSON recognition (the CLASS is settled; only
       recognition is deferred).
- [ ] 3. Accepted raw encodings around every token, including the blank-byte grammar and its
       ordering against canonical-form validation.
- [ ] 4. Full notice grammar: duration format, task-id boundary, quote representation, and
       the near-misses that must NOT match.
- [ ] 5. Complete marker state table across both disclosure markers and bgAdvice, including
       coexistence precedence and every write/delete/retry failure.
- [ ] 6. Composition against every existing emit branch (Gate A, Gate B, WIP, docs-only,
       unknown-tool) and events that would otherwise emit nothing.
- [ ] 7. Separator and encoding rules for composed messages.

### B. Shipped-doc scope (pass 8) — SCOPE, NOT WORK
Which files the change touches. **None is edited before the plan says so.**
- [ ] Inline CLAUDE template in commands/workflow-init.md, and this repo's CLAUDE.md §5 —
       both say the hook keys on tool name and never inspects results.
- [ ] "Accurate counters" on opt-out: README.md, codex-gate.sh reminder text,
       commands/workflow-init.md.
- [ ] Every mapping instruction in commands/workflow-init.md — including the preflight
       remedy that renames the server AWAY from `codex` — plus the README knob row and the
       unknown-tool hook message.

### C. Accepted residuals — must survive into the plan unchanged
- [ ] §4: a reworded backgrounding notice on any runtime where auto-backgrounding is still
       effective (unset variable, Claude Code < 2.1.212, or a positive value shorter than the
       call) is counted again.
- [ ] §5.2: an `unrecognized` call whose disclosure is neither delivered nor persisted is
       counted silently.
- [ ] §5.1: counter mutation is unserialized, and `.context/` is trusted. Both pre-existing,
       both filed in todos.md with triggers.

## Story amendments made during this Gate A
§2 at passes 2 and 5; §3 criteria at passes 4 and 8. Each is recorded inline in the story
with what it replaced. §2 is now marked a SUMMARY deferring to the spec, so a future
amendment has one target.

## Watch-item for the plan's Gate A

**If findings concentrate on contracts 5-7 — the marker state table, composition against
every emit branch, and separator/encoding rules — STOP and surface rather than elaborating.**

Those three are the diagnostic-messaging machinery, and they are the part of this design that
grew by accretion: pending state was added at pass 2, the gate-on failure path at pass 4, and
one-emit composition at pass 3, each closing a real gap and each enlarging the surface the
next pass had to keep consistent. Findings clustering there would mean the composition
semantics are carrying more than they should, not that the spec needs finer prose.

**The named pressure valve is a SIMPLER composition semantics** — for instance, dropping the
compose-into-one-emit rule in favour of a single deferred-disclosure flush, or accepting a
duplicated disclosure instead of tracking pending/shown separately. That trade changes what
the design promises about message delivery, so **it is decided upstream by the human, not
absorbed into the plan.**

Recorded here rather than in the plan because the plan is what would be tempted to elaborate.
