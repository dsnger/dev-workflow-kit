# Gate B passes 2–4 — dispositions (reviewer: moonshotai/kimi-k3 via OpenRouter flip, effort max, all passes)

Pass 2 (spec 3 / quality 4, no Blocker/Major):
- MINOR switch-surface table listed 3 of 4 resolution layers — FIXED (coding-workflow.md table → four rows; sparring-briefing.md list extended), amended in c5c48da.
- MINOR spec §4 parenthetical decay warning — COLLECT (accurate today; re-verify on next edit of any listed file).
- NIT plan Step-7 4c=13 stale vs re-measured 19 — COLLECT (plan is frozen; its wrap-up records "13, then 16, then 19").
- NIT AC-9 parity confirmation — informational, no fix owed.
- Re-collected pass-1 NITs (checker comment field count, sev_case chmod, CHANGELOG bullet asymmetry) — remain COLLECT.

Pass 3 (spec 4 / quality 6, one MAJOR):
- MAJOR CHANGELOG 0.9.0 "three switch surfaces" falsified by the pass-2 four-surface fix — FIXED (count-free enumeration naming all four surfaces), amended in 2353409.
- MINOR plan fence range 192–629 (now 192–699), :325 (now :341), Step-7 4c=13, "three switch surfaces" phrasing — COLLECT (frozen planning artifact; wrap-up self-corrects the flip count; the plan records its writing-time state).
- Re-collected NITs as above.

Pass 4 (spec 3 / quality 4, no Blocker/Major — CLEAN FINAL PASS; first attempt timed out at the 2400s MCP limit, orphaned reviewers killed, this is the single Mechanics retry):
- MINOR no inbound link from README/getting-started to the reviewer-model-selection section — COLLECT (docs reachability; backlog candidate).
- MINOR resume path (`codex exec resume`) also carries --model, so a mid-outage model switch silently changes the reviewer on a resumed session — COLLECT (one-sentence docs addition; backlog candidate; verified by reviewer against dist/services/codex-executor.js:88).
- MINOR spec §4 parenthetical decay — COLLECT (repeat of pass 2).
- Re-collected: checker comment field count, sev_case chmod asymmetry, CHANGELOG bullet thinness — COLLECT.

## Bridge revert — 2026-08-16 ~14:00, on Daniel's decision

Reverted to the codex native subscription default (Daniel purchased codex credits).
Cost was the driver: OpenRouter frontier pricing at our pass sizes (~$76 for passes
2-4 including the timed-out pass-4 first attempt). Reverted: flip line
`model_provider = "openrouter"` removed from ~/.codex/config.toml;
`model_reasoning_effort` restored to "medium"; per-repo
`.mcp/mcp-codex-dev.config.json` (kimi-k3 pin) deleted. Kept: the fenced
`[model_providers.openrouter]` block — proven inert without the flip; it is the
standing outage bridge. auth.json sha256 953551b4… verified unchanged across the
whole bridge lifecycle. Effective at the next Claude Code session per the
startup-cache caveat (mcp-codex-dev resolves its model chain per project root at
server startup); backups ~/.codex/config.toml.bak-2026-08-16{,-pre-openrouter}
remain.
