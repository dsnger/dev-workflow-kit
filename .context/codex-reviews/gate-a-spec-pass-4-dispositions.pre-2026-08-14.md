# Gate A — spec — pass 4 dispositions

Artifact: `docs/superpowers/specs/2026-08-05-hardening-ledger-supersession-design.md`
11 findings: 7 Major, 2 Minor, 2 Nit. All eleven validated as correct against the files.
**None applied** — the pass is not clean, and the pinned exit sends anything new to Daniel.

Reviewer: `mcp-codex-dev@1.0.1`, `codex-cli 0.144.5`, model `gpt-5.6-sol`. Same server as
passes 1–3; the model was not recorded for those passes, so a change cannot be ruled out.

| # | Sev | Verdict | Reason |
|---|---|---|---|
| 1 | Nit | **Valid** | Confirmed against `docs/hardening-log.md:7`. Source reads ``resolve a `pending` row``; §2.0 quotes it inside a single-backtick span, so `pending`'s own backticks are dropped. Same class as pass 3's finding 8 — a locator that is semantically right and not byte-findable. |
| 2 | Minor | **Valid** | §3.1's citation writes `` \`PostToolUse\` `` inside a single-backtick span. Backslashes do not escape code-span delimiters in markdown, and those bytes are not in `CLAUDE.md`. The pass-3 fix added the `**` markers but left the span unterminated in the other direction. |
| 3 | Nit | **Valid** | `SKILL.md:157` requires a **short** one-line escaped `finding`; §5's table carries only "one line, with `\|` escaped". One old condition unaccounted, which is exactly what rider 3 exists to catch. |
| 4 | Major | **Valid** | `CLAUDE.md` §5 Mechanics defines when a Gate-B cycle *closes* and never when it *opens*. §2.1's "the one you have open" therefore has no defined start, and a row appended during implementation before the first `WIP:` snapshot classifies both ways. Codex's six self-test verdicts otherwise all come out as the spec says. |
| 5 | Major | **Valid** | Landed is observer-relative by design ("landed to you"). Cycle B may append a supersession against a row cycle A is still entitled to amend in place, so B's entry can be stale or its locator broken on arrival. Not a contradiction in the text — an unhandled concurrent path. |
| 6 | Major | **Valid, and the pass's most important finding** | §2.2 routes entry locators through "the same fallback" — a distinguishing fragment of *the row's* `finding`. Two same-day entries against one row share that row, so they share the fragment too. The fallback cannot separate the collision it was added for, which means pass 3's finding 4 was answered in words and not in mechanism. |
| 7 | Major | **Valid** | Only one line shape is defined, and it supersedes a *row*. Nothing says how a correcting entry names the entries it retires, distinguishes itself from a row correction, or cites its answer — while §2.2 requires that path to exist. |
| 8 | Major | **Valid** | "a correcting entry retires exactly the entries it names and states what now holds" contradicts the same paragraph's cite-don't-restate rule. Two incompatible instructions on one surface — prompt-standards item 7, the same defect §2.0 exists to remove. |
| 9 | Major | **Valid** | Check 2 compares the two regions **to each other**. Two identically wrong regions that both end at the sentinel pass. The check is titled "the convention actually reached both surfaces" and proves parity, not presence — the `AGENTS.md` "never describe what a gate proves" class, on a check written to close that class. |
| 10 | Major | **Valid** | Check 1 greps the entry anywhere in the file; check 2 excludes the block, `Columns:` and the table. So §2.2's layout decisions — exactly one label, positioned above `Columns:`, absent from the template — are validated by nothing. |
| 11 | Minor | **Valid** | Story §5 still poses template reach as an open question and §4 marks invariants 11 and 12 conditional on it, while the design settles it (§4 lists `workflow-init.md` and the version bump). The authoritative source presents settled scope as unresolved. |

## Decision needed from Daniel

Findings 4, 5, 6, 7 and 8 are convention-text changes, not editorial fixes: they change what
the shared prose says, which lands in every scaffolded ledger. 9 and 10 change what §7 claims
to validate. 11 edits the story again.
