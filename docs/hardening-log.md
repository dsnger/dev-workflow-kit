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
| 2026-07-18 | unverified-enforcement-claim | six citable claims across one spec, its plan and its diff that something was enforced/caught/guaranteed where no mechanism did it — each caught by a gate, none by the author, one written into the same document that records the pattern | gate-a | major | P std | docs/prompt-standards.md item 11 (+ the same item in the workflow-init inline template). Mixed provenance: four from Gate A on the spec, one from Gate A on the plan, one from Gate B on the pre-merge diff; `source` records Gate A as the majority and the trigger |
| 2026-07-18 | docs-drift | a Gate-B fix reordered a precedence rule and added a terminal state in process-pr-review; the approved spec was never updated and disagreed until a PR bot found it | bot | major | P std | CLAUDE.md §5 Gate B, "a fix that changes specified behaviour updates the spec in the same commit" (+ the workflow-init inline template). Escalated from the 2026-07-18 `1 prose` row, whose AGENTS.md rule was scoped to manifest claims and could not reach spec-vs-implementation drift |
