# Gate B — spec branch — pass 13 dispositions

1 finding, Major. Accepted. The quality branch reported the same defect independently (as a Minor).

1  MAJOR the rewritten stage-8 rule overstates what the hook detects — ACCEPT, and it is the cycle's sharpest irony: the pass-12 fix for a gate-overclaim introduced a gate-overclaim. I wrote that agent definitions and hook messages categorically fire full Gate B; the hook's classifier is `(^|/)(CLAUDE|AGENTS)\.md$|(^|/)(\.claude|plugins|skills|commands)/`, so a bare `agents/foo.md` or `hooks/reminder.md` is classified docs-only and gets no gate.
   This is AGENTS.md's named most-persistent class — "never describe what a gate proves without checking what it actually compares" — and it regenerated inside a correction of itself, exactly as the invariant-file warns ("each correction introduced a subtler version of the same claim").
   Fixed by naming the literal matched set: `CLAUDE.md` and `AGENTS.md` themselves, plus `.claude/`, `plugins/`, `skills/`, `commands/` at any depth; agent definitions and hook messages are covered because they sit under a matched parent; a bare top-level `agents/` or `hooks/` matches nothing. Claim verified against the matcher in the hook rather than against §5's prose about it.
