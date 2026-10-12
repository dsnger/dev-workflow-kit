# Product requirements — dev-workflow-kit

What the kit is for, how its success is read, what it will not do, and which features it has.
What the product *is* is stated in
[`AGENTS.md` § What this project is](../AGENTS.md#what-this-project-is). The layout is in
[`ARCHITECTURE.md`](ARCHITECTURE.md), and the tools are in [`TECH-STACK.md`](TECH-STACK.md).

## Problem

Developers who build software with coding agents get output that no single model checks well:
a model reviewing its own design or diff shares its own blind spots, a finding fixed once comes
back in the next change, and each session starts the work differently. The longer aim is a repository
that turns approved stories into merged, reviewed software, with the human present where
judgement measurably matters
([vision §1](superpowers/specs/2026-08-30-dark-factory-vision.md#1-the-vision)).

## Success measures

No target is set here. Each row says where its current value is read, so this page never holds
a copy that can go stale.

| Measure | How it is read | Source |
|---|---|---|
| Maturity stage of the review loops | the stage table | [vision §3](superpowers/specs/2026-08-30-dark-factory-vision.md#3-maturity-ladder) |
| Review-loop pass curves per cycle | `python3 -B scripts/loop-usefulness.py` over the provenance and curve lines in commit bodies | `.claude/review-gates.md`, Closing act (the curve form) |
| Hardening escalation per finding class | `python3 scripts/ledger-metrics.py` | [`hardening-log.md`](hardening-log.md) |
| Instruction size against its budget | check 4g in `sh scripts/check-invariants.sh` | [`AGENTS.md` § Commands](../AGENTS.md#commands) |
| Scaffolded `CLAUDE.md` template size against its budget | check 4e in `sh scripts/check-invariants.sh` | `AGENTS.md` invariant 8 |

## Non-goals

[Vision §8](superpowers/specs/2026-08-30-dark-factory-vision.md#8-non-goals).

## Feature map

| Feature | Status | Authoritative doc |
|---|---|---|
| Review gates (Gate A on every spec and high-risk plans, Gate B on non-docs-only diffs) | shipped | [`.claude/review-gates.md`](../.claude/review-gates.md) |
| Hardening ledger | shipped | [`harden-finding` skill](../plugins/dev-workflow/skills/harden-finding/SKILL.md), [`hardening-log.md`](hardening-log.md) |
| Intake (story capture, amendment route) | shipped | [`intake` skill](../plugins/dev-workflow/skills/intake/SKILL.md) |
| Tickets (bugs and improvements inside approved commitments) | shipped | [`ticket` skill](../plugins/dev-workflow/skills/ticket/SKILL.md) |
| Scaffolding (`/workflow-init`, `/claude-init`) | shipped | [`workflow-init`](../plugins/dev-workflow/commands/workflow-init.md), [`claude-init`](../plugins/dev-workflow/commands/claude-init.md) |
| Telemetry reports | shipped in parts | [vision §7](superpowers/specs/2026-08-30-dark-factory-vision.md#7-build-path-each-leaf-is-one-story-numbered-entries-are-ordering-groups) step 2; [`ARCHITECTURE.md` § Components](ARCHITECTURE.md#components) |
| Orchestrator / lane | planned | [vision §7](superpowers/specs/2026-08-30-dark-factory-vision.md#7-build-path-each-leaf-is-one-story-numbered-entries-are-ordering-groups) step 3 |
