# Hardening log

Append-only ledger of review findings hardened via the `dev-workflow:harden-finding`
skill. One row per hardening (rung 0 "already caught" is not logged). `fingerprint`
is a canonical class — from the base taxonomy in the `harden-finding` skill, or from
this project's `docs/hardening-taxonomy.md`; column 2 is the recurrence-grep target.
Never edit a row; resolve a `pending` row by appending a new row (same fingerprint,
`ref` naming the prior row's date + anchor).

Columns: `date` (YYYY-MM-DD), `fingerprint` (canonical class), `finding` (short,
escape `\|`, one line), `source` (gate-a|gate-b|bot|manual),
`severity` (blocker|major|minor|nit), `rung` (e.g. `2 lint`, `4 test`, `1 prose`,
`P std`, `pending`), `ref` (rule name / test path / AGENTS.md section / prior row).

| date | fingerprint | finding | source | severity | rung | ref |
|------|-------------|---------|--------|----------|------|-----|
| 2026-07-18 | prompt-diagnostic-cause-unnamed | workflow-init preflight reported "restart the session" for every not-loaded codex, hiding a same-named server winning on scope precedence, which a restart can never fix | manual | major | P std | docs/prompt-standards.md item 10 |
| 2026-07-18 | dependency-unpinned | floating action refs and ubuntu-latest in ci.yml and in the CI template workflow-init scaffolds | gate-b | major | 2 lint | scripts/check-invariants.sh + .test.sh — guards the tested line-oriented spellings of action refs (incl. quoted, docker tag/digest, multi-per-line), runner values incl. tested matrix forms, and npx `-y`/`--yes` forms; raises the floor but is not exhaustive parsing (e.g. `uses :` with a space, or a line-split value, still evades) |
| 2026-07-18 | docs-drift | three docs claimed the plugin manifest declares hooks; it declares none — the 0.2.1 duplicate-hooks load failure | gate-b | major | 1 prose | AGENTS.md Don'ts, "Never state what the manifest declares without reading it" (new rule + grep recipe; invariant 6 already existed and constrains the manifest, not claims about it) |
