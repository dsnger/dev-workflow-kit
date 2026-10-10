# Change-Record Row for an Added Criterion — Story

**Date:** 2026-10-10 · **Size:** story
**Risk:** standard · **Security:** none · **Validation:** battery+check

## 1. Problem statement
The change-record template in the amendment route of `plugins/dev-workflow/skills/intake/SKILL.md`
has a row form for every earlier condition, but none for a criterion a change adds without any
earlier condition behind it. Agents then invent a row such as
`| — (new condition: CSV offered as an export format) | added per the decision: "add CSV to the export story" | added AC-5 |`,
whose fate lies outside the closed set. Strand-C pilot evidence (branch `intake-skill-pilot`,
commit b348b9c, `docs/superpowers/replays/2026-10-10-intake-skill-pilot/compare.md` lines 15 and 27,
case D): the shipped skill produced such a row in 1 of 3 runs, the split candidate in 4 of 4.

## 2. Desired outcome
A change that adds a criterion with no earlier condition is recorded completely and inside the
closed sets: the new requirement stands in the changed artifact and is visible in the record,
covered by the decision that added it, with its new identifier, while every earlier condition and
identifier is accounted for as before. No obligation the route and its template carried before is
lost. The fix is checked by re-measuring two pilot cases with the existing replay structure; that
measurement shows those cases, not a general absence of loss. The fix is judged on its own, apart
from the planned split of the skill.

## 3. Acceptance criteria
_IDs are permanent once the story is committed: never renumber or reuse one; a new criterion takes the next number unused here and on the branch it merges into, and a collision stops for a human; a removed one stays, struck through and dated; a narrowed one keeps its ID with a dated note; cite as `<story path> AC-<n>`; full rules: dev-workflow:intake, "Acceptance-criterion IDs"._
- [ ] **AC-1** The amendment route defines explicitly how a criterion added with no earlier
      condition is represented in the change record. Fields governed by a closed set use only that
      set's permitted values; requirement text, decision evidence and identifiers follow their own
      rules. No existing closed set is widened unless the spec names and justifies it.
- [ ] **AC-2** Every obligation the amendment route and its change-record template carried at
      `e98fa4c` is still carried: an accounting lists each one as kept, moved (with its new place)
      or deliberately dropped, and none is dropped.
- [ ] **AC-3** A record cannot meet the format by leaving the new requirement out: the route
      requires an added criterion to stand in the changed artifact under the ID rules and to appear
      in the record with its identifier and the passage of the decision that covers it.
- [ ] **AC-4** Check 4f in `scripts/check-invariants.sh` pins the changed template and closed sets,
      and its fixture `CR_LINES` in `scripts/check-invariants.test.sh` is updated with it; the suite
      shows that removing or altering the new part is rejected and the shipped template is accepted.
- [ ] **AC-5** Case D of the strand-C replay (same flags: `claude -p` in the fixture folder,
      `--plugin-dir`, `--setting-sources project`, `--strict-mcp-config`) is run 5 times. A run
      passes only if it takes the amendment route; uses only permitted values in every
      closed-set field; places the added criterion in the story's §3 with the next unused
      identifier and records it with its covering decision; and keeps every baseline condition and
      identifier.
- [ ] **AC-6** Case B of the strand-C replay is run 3 times with the same flags. A run passes only
      if it meets every check the pilot applied to case B and the obligation of AC-3 for the
      criterion it adds.
- [ ] **AC-7** The change is accepted only if all 5 case-D runs and all 3 case-B runs, made on one
      unchanged final skill revision, pass. The comparison records the fixture, prompts, model,
      runner and skill revision measured.
- [ ] **AC-8** Every run is reported, failures included, with its result per check, and earlier
      results stay visible. A failed run is investigated; only a correction with a stated reason
      starts a fresh complete measurement set. Without such a correction the shipped template is
      kept and the decision goes to Daniel; runs are never repeated until enough pass.
- [ ] **AC-9** The split of the intake skill into route files is absent from this change and is
      judged separately; branch `intake-skill-pilot` is used as the source of fixtures and is not
      merged.

## 4. Affected AGENTS.md invariants
- `## Key invariants` (Prompts and scaffolding) — "11. **Prompt changes pass `docs/prompt-standards.md`** — all 12 checklist items, for any skill, command, agent definition, hook message, or scaffolded template."
- `## Key invariants` (Prompts and scaffolding) — "… and the `intake` amendment route's change-record template and its closed sets (not whether the procedure prose is right or any written record follows them) …"
- `## Key invariants` (Packaging) — "12. **A plugin change requires a version bump.** A pull request that changes any path under a `plugins/<name>/` directory **that still exists at HEAD** … must also change that plugin manifest's `version`, or CI fails."
- `## Don'ts` — "**Never replace a decision procedure without accounting for its old conditions.** List what the previous prose required, then mark each one kept, moved, or deliberately dropped."

## 5. Open questions
- None.

## 6. Suggested size
story — one template gap with its check and a bounded re-measurement; fits one spec → plan → PR.
