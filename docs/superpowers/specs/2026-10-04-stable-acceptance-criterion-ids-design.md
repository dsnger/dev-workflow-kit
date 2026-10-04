# Stable acceptance-criterion IDs (P5 light) — design

**Story:** `docs/superpowers/stories/2026-10-04-stable-acceptance-criterion-ids-story.md` — read the profile from its header at every gate call.

## §1 What changes

| Path | Change |
|---|---|
| `plugins/dev-workflow/skills/intake/SKILL.md` | The story template numbers its criteria `AC-<n>`; a new "Acceptance-criterion IDs" rule block (§2); the flow's re-validation step and "Common mistakes" name the IDs. |
| `scripts/check-invariants.sh` | A new check **4d** (§3), bracketed like 4a–4c. |
| `scripts/check-invariants.test.sh` | Fixtures carry a valid intake template; reject/accept pairs for 4d. |
| `plugins/dev-workflow/.claude-plugin/plugin.json`, `plugins/dev-workflow/CHANGELOG.md` | Version **0.15.0** (invariant 12): a shipped prompt changes. |
| `AGENTS.md` (invariant 11's list of narrow checks), `docs/getting-started.md`, `docs/coding-workflow.md` | Say that criteria carry `AC-<n>` IDs and that a fourth narrow check exists, where those documents describe criteria or the checks. |

**Excluded** (story AC-6; "story" in this spec means the path in its header, so "story AC-6"
is the citation `<story path> AC-6`): no gate rule, pass rule, record format or evidence-entry format
changes. The kit ships no plan template — plans come from `superpowers` — so plans cite IDs by the
rule in §2, not through a template slot. The per-criterion evidence view (`todos.md` G1b) and vision
leaf 4e's safeguards are untouched. One sequence, `AC-<n>`, serves every criterion (story, decided
2026-10-04); there is no `SEC-<n>`.

## §2 The rules the intake skill states

The story template's §3 becomes:

```markdown
## 3. Acceptance criteria
_IDs are permanent once the story is committed: never renumber or reuse one; a new criterion takes the next number unused here and on the branch it merges into, and a collision stops for a human; a removed one stays, struck through and dated; a narrowed one keeps its ID with a dated note; cite as `<story path> AC-<n>`; full rules: dev-workflow:intake, "Acceptance-criterion IDs"._
- [ ] **AC-1** <Observable outcome or constraint, checkable true/false by a reviewer.>
- [ ] **AC-2** <…>
- [ ] **AC-3** <… at least three.>
```

The italic line is part of every story the skill writes. It carries the rule to where the
criteria are later edited, cited or amended — places the intake skill itself does not run (it ends
at capture, and its hand-off passes only the story path).

The new rule block, in the skill's prose beside the template, says:

1. **Fixed at commit, free before.** While the draft is shown and edited (flow steps 8–9),
   criteria are renumbered freely, so the draft always reads `AC-1 … AC-k` in order. Identifiers
   become permanent when the approved story is committed (flow step 10).
2. **After commit: never renumbered, never reused** — the one exception is a renumbering a human
   decides under rule 3. In any later amendment:
   - a **new** criterion takes the next unused number, wherever it is placed in the list;
   - a **removed** criterion keeps its line, struck through, with a dated reason, for example
     `- [ ] **AC-3** ~~<old text>~~ — withdrawn 2026-10-04: <reason>`;
   - a **narrowed or reworded** criterion keeps its identifier, with a dated note in the same
     line, for example `(narrowed 2026-10-04: <reason>)`.

   **Why:** a citation outlives the list it points into. A renumbered or reused identifier
   silently redirects every earlier citation to a different criterion.
3. **Concurrent amendments.** Before committing an amendment, take "next unused" over the story
   on its own branch **and** on the branch it will merge into. If two amendments still claim the
   same number when they meet, **stop and ask a human** which one gives way. That amendment's new
   criteria must then be renumbered, together with every citation already made to them. Nothing
   resolves this automatically, because an identifier committed on a branch may already be cited.
4. **Citation form.** For a story that carries identifiers: `<story path> AC-<n>`, or `AC-<n>`
   inside the story itself. Plans, specs, gate calls, evidence entries and fate tables use it
   instead of a position ("criterion 4") or a paraphrase. For a story without identifiers: the
   story path and the criterion's text, quoted — **never** an identifier guessed from its position.
   This is a citation convention; no existing record grammar changes.
5. **Older stories.** A story that already carries `AC-<n>` identifiers keeps them, and rules 2–4
   apply from now on. A story without identifiers is not rewritten. At its first later amendment
   it adopts them: its existing criteria are numbered in their current order, the italic rule line
   is added, and a dated line under §3 records the adoption.

A **worked example** in the skill shows one committed story through three amendments: a criterion
inserted between AC-1 and AC-2 (it becomes AC-4), AC-2 withdrawn, and AC-3 narrowed. Every other
identifier stays unchanged.

The flow's re-validation step (step 9) adds "criteria read `AC-1 … AC-k` in order, and the italic
ID rule line is present" to its constraint list. "Common mistakes" adds "renumbering criteria of a
committed story".

## §3 Check 4d

`scripts/check-invariants.sh` gains **check 4d**, bracketed `# --- BEGIN check 4d ---` /
`# --- END check 4d ---` so the existing mutation re-run procedure covers it. It reads the
**required** file `plugins/dev-workflow/skills/intake/SKILL.md`. A missing or unreadable file is a
named failure, never a skip, as in 4c.

**Where it looks: the story template only.**
1. The template is the first fenced block (a line that is exactly ```` ```markdown ````, up to the
   next line that is exactly ```` ``` ````) after the skill's `## Story template` heading.
2. A missing heading, a missing fence or an unclosed fence is a named failure.
3. Inside that fence, the region runs from the line `## 3. Acceptance criteria` to the line
   `## 4. Affected AGENTS.md invariants`. Each must occur exactly once in the fence, in that
   order, or the check fails.

So neither the worked example nor any other text outside the template can satisfy or break the
check, and a moved or renamed boundary fails instead of widening the region.

**What every line of the region must be,** or the check fails, naming the line:
- blank;
- exactly the italic rule line of §2;
- a criterion row matching `^- \[ \] \*\*AC-[1-9][0-9]*\*\* .+`.

The rule line must occur exactly once. There must be at least one criterion row, and the numbers
must read `1, 2, 3, …` in order.

**Status.** The extraction runs in one `awk` program whose exit status is checked, as in 4c. An awk
that cannot run is a named failure, distinct from a template that fails the rules.

**What it does not catch,** stated in the checker and in AGENTS.md invariant 11:
- whether the rule block or the worked example says the right thing;
- whether any written story follows the rules;
- whether a later amendment renumbered anything.
It pins the template's spelling only.

**Regression pairs** in `scripts/check-invariants.test.sh`. The shared fixture initializer writes
a minimal valid skill file, so every other case stays isolated.

Reject:
- a missing file and an unreadable file;
- no `## Story template` heading, no fence, and an unclosed fence;
- a missing, duplicated or out-of-order region boundary;
- a row without an identifier, and a bare `- ` row;
- out-of-order numbers;
- a missing rule line, and a duplicated one;
- an awk failure, simulated by a stubbed `awk` on `PATH`.

Accept:
- a valid template;
- a worked example outside the fence that uses other numbers;
- unrelated rows under `## 4.` inside the fence.

## §4 Version and changelog

`plugin.json` goes from `0.14.0` to **`0.15.0`**: a minor bump, because a shipped skill's output
format gains an element. The CHANGELOG entry is written from `git log` over `plugins/` (its own
rule) and names the template change, the rules and check 4d.

## §5 Story criteria

| Criterion | Where |
|---|---|
| AC-1 template numbers criteria | §2 |
| AC-2 never renumbered or reused; withdrawn and narrowed forms | §2 rules 1–3 and the italic rule line |
| AC-3 citation form | §2 rule 4 and the italic rule line |
| AC-4 older stories | §2 rule 5 |
| AC-5 a check on the template and a worked example | §3, §2 |
| AC-6 no gate or record change; IDs only | §1 |
