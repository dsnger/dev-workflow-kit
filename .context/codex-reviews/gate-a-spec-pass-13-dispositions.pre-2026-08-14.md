# Gate A — spec — pass 13 dispositions

Artifact: `docs/superpowers/specs/2026-08-05-hardening-ledger-supersession-design.md`
6 findings: **1 Blocker**, 4 Major, 1 Minor. All read as correct. **None applied.**

Reviewer: `mcp-codex-dev@1.0.1`, `codex-cli 0.144.5`, model `gpt-5.6-sol`.
This call left **no** stray artifact (pass 12's did); the only untracked path, `docs/research/`,
predates the session.

Passes 4 → 13: **11, 14, 16, 15, 9, 10, 5, 12, 8, 6.**

## The blocker — two settled instructions are in tension

The inert assertion scans **every** entry (`grep '^- … supersedes '`). The convention says an
inert entry is **never removed and never edited** — it stands as history. So the first time the
typo case actually fires:

- appending the corrected entry leaves the inert one in the scan → the check stays red, forever;
- editing or deleting the inert entry → violates the absolute rule the whole design exists for.

**There is no legal state in which validation is green again.** Confirmed against the text at
`:412` (the scan) and §2.2 (inert entries stand).

This is not a defect in either instruction on its own. "An inert entry stays as history" (the
zero-match settlement) and "the assertion stays gating over all entries" (the F5 settlement) are
individually sound and jointly unsatisfiable. **It needs Daniel.** Codex's suggestion — scope this
change's check to §3.1's mandated entry only, and turn the parked battery-wiring row into a
*design* task for enforcement compatible with immutable inert history — is one way; there are
others (e.g. gate only entries appended by the change under review).

## Reproduced / verified

| # | Claim | Result |
|---|---|---|
| 1 | no legal green state once an inert entry exists | **Confirmed** from the scan pattern and §2.2. |
| 6 | `[ -n "$B" ]` is ineffective | **Confirmed**: `printf '' \| cksum` → `4294967295 0`. Non-empty for empty input, so the guard never fires. |
| 3 | `BASE` silently defaults to `HEAD` | **Confirmed** at `:446` and `:458`. |

| # | Sev | Verdict | Note |
|---|---|---|---|
| 1 | **Blocker** | **Valid** | See above. Needs Daniel. |
| 2 | Major | **Valid** | The fragment is matched against the **whole table row**, not the `finding` column it is defined to locate. Codex reproduced it: a fragment taken from the row's `ref` (`mcp-codex-dev@1.0.1`) exits 0. My prototype only ever tested fragments that happened to live in `finding`. |
| 3 | Major | **Valid, confirmed** | `${BASE:-HEAD}` means that after this change is committed, an edited row becomes **its own baseline** — the pin passes on a committed mutation. The base-relative design was right; the default undoes it. |
| 4 | Major | **Valid** | The dates assertion checks **recorded string order**, not that a date is the row's actual append day. A row appended today but labelled `2026-08-05` after a `2026-08-04` tail passes. So "backdating is forbidden **and mechanically checked**" is an overclaim — mine, written in the same edit that added the check. |
| 5 | Major | **Valid** | Anchor 22 covers `A row's date is the day it is appended` but **not** `the table is chronological: backdating a row is forbidden`. Deleting that clause from both surfaces leaves all 32 anchors and parity green — sixth consecutive pass finding a hole in this inventory. |
| 6 | Minor | **Valid, confirmed** | The `cksum` fence cannot prove it read a real base paragraph. |

## Pattern worth naming

Findings 2, 3, 4 and 6 are all the **same shape**: a check that is right in design and wrong in
one mechanical detail, where the detail makes it pass when it should fail. That is a better class
of defect than passes 4–7 produced (where the *design* kept being unsound), but it is the class
that survives review longest, because the check looks correct and the fixture that would expose it
is the one nobody wrote.
