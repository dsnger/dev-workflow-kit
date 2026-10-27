# Kit 0.46 lean gates: review loops that end, one source of green, fewer files — Story

**Date:** 2026-10-26 · **Size:** story · **Checkpoints:** spec
**Risk:** standard · **Security:** none · **Validation:** battery+check

## 1. Problem statement
The review loops cost more than they find. Measured over the cycle records of dev-workflow-kit, sfx-time-tracking-dashboard
and infinite-portfolio-canvas from 2026-09-09 to 2026-10-25 (`.context/sparring/20261026-1125-kit-lean-gates-analyse.md`):

1. **Passes 1 and 2 find about 80 % of all Blockers and Majors** outside the kit repo. The floor of 3 passes found
   something that would otherwise have been missed in 2 cycles only. The expensive part is the long tail: kit Gate A
   cycles of 10–65 passes, sfx Gate B cycles of 8–9.
2. **The kit repo itself is the exception:** its Gate B finds 28 % of Blockers and Majors in pass 4 or later. Its product
   is prose with no running artifact, so the diff review is its only check.
3. **Every pass re-reviews the whole diff,** and a fix often draws a new Blocker. The SFX Factory measured the same:
   90 review rounds over 41 PRs, 45 % of commits were review fixes, 11 of 49 follow-up rounds turned one fixed Blocker
   into a new one, and the same diff passed round 1 in the successor PR (`20261026-1120-factory-lessons-for-dev-workflow-kit.md` §1).
4. **Small stories pay the full spec ceremony** (Gate A at floor 3 on every spec), and the same checks run several times:
   the battery, then the gates again over what the battery already checks.
5. **"Green" without a real app run:** the Factory's browser tests passed while the page had never worked in a browser.
6. **Prose hardening does not hold:** in the kit's hardening ledger, prose fixes recurred 13 of 14 times, tests 10 of
   15, lint 2 of 4.
7. **The hook is the only guard on the default branch,** and it is advisory by design.
8. **Filing grows without limit:** every pass leaves a findings file and a dispositions file in `.context/codex-reviews/`.

## 2. Desired outcome
A review cycle ends as soon as it stops finding Blockers or Majors, and never runs past a hard cap. From pass 2 the
reviewer checks the fixes, not the whole diff again, and only a real defect class may newly block. Gate A runs on large
or risky specs only. The quality command is the one source of green, and the gates do not repeat it. UI acceptance
criteria are proven by a real app run. A recurring finding becomes a tool rule. Leftover pass files are archived. Each
behaviour change can be switched back per project, and this kit repo keeps a stricter Gate B because its product is
prose. Initialized projects get the same rules through `/workflow-init`.

## 3. Acceptance criteria
_IDs are permanent once the story is committed: never renumber or reuse one; a new criterion takes the next number unused here and on the branch it merges into, and a collision stops for a human; a removed one stays, struck through and dated; a narrowed one keeps its ID with a dated note; cite as `<story path> AC-<n>`; full rules: dev-workflow:intake, "Acceptance-criterion IDs"._
- [ ] **AC-1** By default Gate B has no minimum pass count: a pass with no Blocker or Major closes the cycle, and the cycle stops at a hard cap of 3 passes. At the cap, a Blocker left open goes to the human as a §4 stop; every other open finding becomes a `todos.md` row.
- [ ] **AC-2** From Gate B pass 2, the reviewer receives the earlier findings list and the diff of the fixes, and marks each earlier Blocker and Major fixed or open. A new finding in pass 2 or later blocks only when it is a Security finding, a violated acceptance criterion, or a Blocker; any other new finding is collected, not repaired in the loop.
- [ ] **AC-3** A project can switch each behaviour change of this story back to its 0.45 behaviour, or to a stated stricter Gate B mode, by a per-project setting that the rules and `/workflow-init` name. This kit repo uses the stricter mode: Gate B continues while a pass finds a Blocker or Major, up to 5 passes.
- [ ] **AC-4** The rules state a threshold for "large or risky" work. A spec at or above it gets Gate A as one full pass plus one verify pass; a spec below it goes to the plan without Gate A, and the spec records which side it is on and why. A plan still gets Gate A only at risk `high`.
- [ ] **AC-5** The rules make the quality command the one source of green: it runs until green within a stated loop limit, a crashing or missing tool counts as red, and the Gate B prompts tell the reviewer not to re-check what the command checks.
- [ ] **AC-6** In a project with a UI, the rules require the plan to name a real app run (browser or end-to-end) with recorded evidence for each UI acceptance criterion, and state that a model review does not replace it.
- [ ] **AC-7** `harden-finding` hardens a recurring finding as lint or a test; it records prose hardening only together with a written reason why neither lint nor a test can decide the finding.
- [ ] **AC-8** The hook still always exits 0, and its pass-count reminders match the new defaults and the per-project setting; a hook test covers the new default and fails on 0.45.0. `/workflow-init` recommends branch protection on the default branch, and the kit sets none itself.
- [ ] **AC-9** At a cycle's close, its per-pass findings and dispositions files are archived out of `.context/codex-reviews/`, and each learning the cycle produces is recorded as one row (symptom, evidence, cause, change, location).
- [ ] **AC-10** The spec accounts for every condition of the current gate rules that this change replaces — kept, moved or dropped, each with its reason — per the AGENTS.md rule on replacing a decision procedure.
- [ ] **AC-11** `scripts/ledger-metrics.py`, `scripts/loop-usefulness.py` and every other reader of cycle records read records written before and after this change; each changed reader's suite has a case for the new form.
- [ ] **AC-12** Both gate rule copies stay byte-identical (check 4j) and within 10,000 bytes (check 4i); the `CLAUDE.md` template stays within check 4e's budget; every changed prompt passes `docs/prompt-standards.md`.
- [ ] **AC-13** The plugin version is 0.46.0, with a CHANGELOG entry and README/docs updates in the same PR, and the quality battery is green.

## 4. Affected AGENTS.md invariants
- `## Key invariants` › `### Hook` — "1. **The hook always exits 0.** It is advisory; a reminder that can fail closed would make the workflow unusable whenever Codex is down or the environment is odd."
- `## Key invariants` › `### Hook` — "2. **Loose in the firing direction.** On uncertainty, fire. A missed commit (false ✓) is the dangerous direction; a redundant warning is the accepted price."
- `## Key invariants` › `### Hook` — "4. **POSIX `sh`, and `jq` is optional.**"
- `## Key invariants` › `### Prompts and scaffolding` — "8. **`/workflow-init`'s templates stay inline** in the command body." and "Check 4e in `scripts/check-invariants.sh` fails when the `CLAUDE.md` template passes 20,000 characters"
- `## Key invariants` › `### Prompts and scaffolding` — "9. **`/workflow-init` never overwrites silently.**"
- `## Key invariants` › `### Prompts and scaffolding` — "10. **The base taxonomy stays stack-neutral.**"
- `## Key invariants` › `### Prompts and scaffolding` — "11. **Prompt changes pass `docs/prompt-standards.md`** — all 12 checklist items"
- `## Key invariants` › `### Packaging` — "12. **A plugin change requires a version bump.**"
- `## Don'ts` — "**Never replace a decision procedure without accounting for its old conditions.**"
- `## Don'ts` — "**Never describe what a gate proves without checking what it actually compares.**"
- `## Commands` — "**Check 4i caps the gate rules at 10,000 bytes**" and "**Check 4j** fails when those two texts are not byte-identical"

## 5. Open questions
- What exactly counts as "large or risky" for AC-4 — size, risk level, or both? (The brief leaves the threshold to the spec.)
- What loop limit does AC-5 state? (The Factory uses 5.)
- Where does a learning row of AC-9 live — the hardening log, `todos.md`, or the closing commit?

## 6. Suggested size
story — one coherent change to one rule set (the gates and what feeds them), one spec → plan → PR; items 4–7 are small additions to the same rules.
