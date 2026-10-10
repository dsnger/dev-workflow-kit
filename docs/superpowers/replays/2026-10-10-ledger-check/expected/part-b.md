# Part B, new rules, fresh checkout after a squash — expected

`.context/codex-reviews/` does not exist. From git alone:

- **Closed:** `gate-b-spec-aaaa1111bb-pass-1:1` (outcome `rung 2`). Not listed as open.
- **Open, blocked:** `gate-b-quality-aaaa1111bb-pass-1:2` — outcome `pending
  todos.md#validation-lint-prerequisite`; intake: "an unknown flag is accepted silently instead
  of rejected", source `gate-b`, severity `major`, `tool.sh`, class `missing-input-validation`.
- **Open:** `gate-b-quality-aaaa1111bb-pass-2:1` — no outcome; intake: "a failing step's exit
  code is dropped by a pipeline", source `gate-b`, severity `minor`, target
  `scripts/run — all.sh` (quoted, contains the separator), class `new class exit-code-swallowed`.

No question back to the human. Observation that would exist if the claim were false: the
rung-2 obligation listed as open, the pending one listed as closed or omitted, a field missing
from an intake, or the quoted target split at its separator.
