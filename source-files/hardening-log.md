# Hardening log

Append-only ledger of review findings hardened via the `harden-finding` skill.
One row per hardening (rung 0 "already caught" is not logged). `fingerprint` is a
canonical class defined in the `harden-finding` skill; column 2 is the
recurrence-grep target. Never edit a row; resolve a `pending` row by appending
a new row (same fingerprint, `ref` naming the prior row's date + anchor).

Columns: `date` (YYYY-MM-DD), `fingerprint` (canonical class), `finding` (short,
escape `\|`, one line), `source` (gate-a|gate-b|bot|manual),
`severity` (blocker|major|minor|nit), `rung` (e.g. `2 lint`, `4 test`, `1 prose`,
`P std`, `pending`), `ref` (rule name / test path / AGENTS.md section / prior row).

**This file is a FORMAT REFERENCE ONLY.** It carries no real project history: the
single row below is a synthetic example with placeholder values, kept so the column
layout and the enums stay demonstrable. A real ledger's rows are that project's own
security-relevant findings — including still-open ones — so they never travel with
the format.

| date | fingerprint | finding | source | severity | rung | ref |
|------|-------------|---------|--------|----------|------|-----|
| YYYY-MM-DD | example-fingerprint-class | one-line description of the finding, `\|` escaped | gate-b | major | 4 test | path/to/pinning.test.ts |
