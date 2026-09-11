# Gate A — plan cycle (rle) — pass 1 dispositions

Advisory human note. Not a findings file; participates in no pass validation.

## Count restart

This is **pass 1 of a restarted count**. The previous pass 1 ran against the plan
committed at 1470094 and returned 21 findings, 20 of them Blocker/Major; its file is
preserved at `gate-a-plan-rle-pass-1.superseded-pre-rewrite.md` rather than deleted,
because it holds the evidence that motivated the rewrite.

**Restart reason:** the artifact was rewritten, not repaired (5c00f8c). A carried count
would flatter the new artifact — passes spent reading a document that no longer exists
say nothing about the one that replaced it.

## Pass 1 result — VALID, and it routes back

- File: `gate-a-plan-rle-pass-1.md`, terminator `END OF FINDINGS (33 total)`, 33 finding
  lines, 0 non-finding lines. **Valid pass.**
- Severity mix: **21 BLOCKER · 10 MAJOR · 1 MINOR · 1 NIT** → **31 Blocker/Major**.
- Routed contract for this rewrite: converge in 2-3 passes at <= 8 B/M; **above ~12
  routes back before pass 2**. 31 is nearly triple that. **Routed, not iterated.**

This is not the "clearly stuck" exit — that needs a plateau across passes and this is
pass 1. It is the pre-agreed routing threshold firing on its first reading. The findings
stay open, no pass is credited as clean, and the loop resumes on whatever is decided.

## The prediction was wrong, and how

Predicted <= 8 B/M on the grounds that the four habits behind the predecessor's 20 were
structurally prevented. Three of the four recurred in new form:

- **"checks written to look like TDD"** -> B8. Task 2's recorded `7/7` is a real
  measurement of the tree *today*, but the plan runs it *after* Task 1 has already
  removed one of the seven matches. In sequence it is 6, not 7. The number was honest
  and the sequence was not, which is the same defect wearing a demonstrated output.
- **"a plan for a §5 change that does not follow §5"** -> B15, B16, B14. Fixed
  "nine ordinary commits" and introduced an amend the hook cannot recognize.
- **"anchors typed from memory"** -> NIT 12. One line of one anchor block is the
  editorial token `(identical)` rather than pasted output, so the blanket claim that
  every anchor is pasted is not literally true.

Only "references to spec contents that no longer exist" was actually prevented, and
B2 argues even the passage list is unsound in the other direction.

## Findings verified before routing

Two were checked against source rather than accepted on the reviewer's word.

- **B15 — CONFIRMED, and decisive.** `plugins/dev-workflow/hooks/codex-gate.sh:763`:
  `is_wip_commit() { printf '%s' "$1" | grep -Eiq -- "-m[[:space:]]*['\"]?[[:space:]]*wip"; }`
  It matches the **Bash command string**, not git state or the commit message. So
  `git commit --amend --no-edit` carries no `-m` and is NOT a WIP commit to the hook;
  at `:886` `is_commit "$cmd" && ! is_wip_commit "$cmd"` is then true and the cycle
  RESETS. Tasks 2-6 each run exactly that command. The plan's central structural fix
  destroys the cycle it was written to protect.
  Corroborated incidentally this session: a `cat` heredoc merely *containing* the text
  `WIP:` fired the hook's WIP notice, because the match is on the command string.
- **MAJOR 10 — CONFIRMED as stated.** `check-version-bump.sh` does compare committed
  state; the plan's ordering fix is right. The finding is that the plan never checks
  `main` is current, which `AGENTS.md` names as a precondition. Correct and additive.

## Disposition

All 31 Blocker/Major carried open to the routing decision. No fixes applied in this
pass: at this density the artifact is being re-decided, not repaired, and applying 31
repairs before that decision is how a rewrite becomes a patch pile.

The two Minor/Nit are collected, not iterated: MINOR 11 (CHANGELOG entry content
unspecified), NIT 12 (the `(identical)` anchor line).
