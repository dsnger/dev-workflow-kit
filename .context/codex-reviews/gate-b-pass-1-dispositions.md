# Gate B pass 1 — dispositions (reviewer: moonshotai/kimi-k3 via OpenRouter flip, effort max)

Spec branch (3):
1. MINOR README.md:160 two→three count — FIX (same defect as quality MAJOR #1).
2. MINOR spec §4 "checked for truth and unchanged" falsified by this commit's edits to docs/coding-workflow.md, docs/sparring-briefing.md (and now README.md) — FIX: temporal scoping note; false sentence shipped by this commit, repo overclaim rule applies.
3. NIT plan lacks a task for the two docs files — COLLECT: plan is a historical artifact; the docs work is task scope recorded in the closing message instead.

Quality branch (7):
1. MAJOR README.md:160 stale count — FIX to "three".
2. MAJOR ci.yml:84 stale count in step comment — FIX to "three".
3. MINOR coding-workflow.md:247 schema enumeration factually wrong vs mcp-codex-dev@1.0.1 — FIX: name the absent key (no provider key) instead of enumerating present ones; false sentence introduced by this diff.
4. MINOR checker terminator pins "2.2", renumbering breaks 4c repo-wide — COLLECT: reviewer itself says deliberate fail-loud, documented at :549-553, no change required.
5. MINOR sev_case chmod 644 restores CLAUDE.md only; @LOCK@ currently CLAUDE.md-only — COLLECT: latent, dead code today; backlog candidate.
6. NIT checker comment "three space-separated integers" (four fields, one string) — COLLECT.
7. NIT CHANGELOG exception-form bullet asymmetric with severity bullet — COLLECT.
