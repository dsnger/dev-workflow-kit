# Old → new account (AC-2) — historical, the split was not adopted

Every part of the 0.23.0 `plugins/dev-workflow/skills/intake/SKILL.md` (sha256 `e629b1ba…7089`)
and where the replayed split (`candidate/`, set 2) put it. Status words: **verbatim** (same lines
apart from indentation), **moved** (verbatim, other file), **reworded** (text changed; the change is
quoted). The table below is the pilot's mapping (`git show
b348b9c:docs/superpowers/replays/2026-10-10-intake-skill-pilot/proposal.md`, § (c)), copied
unchanged; its "Old location" line numbers refer to the skill at `860e56c`. The 0.23.0 file is the
same text up to line 355; the section after "The deltas" accounts for every difference, so the two
together cover the 0.23.0 file. Line coverage (`runner.md`, `coverage.py`) confirms it: the only
0.23.0 lines found in none of the three files are the 24 inside the rows marked reworded.

| # | Old location | What it carries | New location | Change |
|---|---|---|---|---|
| 1 | L1–4 frontmatter | name, description (trigger) | `SKILL.md` frontmatter | verbatim |
| 2 | L8–22 Overview | front door, story path, WHAT/WHY boundary, §4 exception | `SKILL.md` Overview | verbatim |
| 3 | L24–25 | Target model, prompt-standards claim | `SKILL.md` Overview | verbatim; each route file adds its own `Target model:` line (check 4a scans them) |
| 4 | L27–30 | requires AGENTS.md, offer `/dev-workflow:workflow-init` | `SKILL.md` Overview | "the Flow's" → "the capture route's"; rewrapped |
| 5 | L32–39 When to use | the three entry situations | `SKILL.md` *Choose the route first*, table rows | **reworded** (corrected here; the pilot table said "same wording"): the situations moved into the table's first column as "A raw idea or voice transcript arrives and needs to enter the workflow, before any brainstorming; or a backlog line needs to become a reviewable story before design starts" and "An approved story or spec must change after a human decided to change it — narrowed, redirected, or corrected for a gap found later". **Not carried over:** the clause "— so the entrance is consistent regardless of author" (the Overview's "This standardizes an entrance that otherwise varies by whoever writes the prompt" stays) and the pointer "Use the separate route *Amending an approved story or spec* below, not the Flow" (replaced by the table's route column) |
| 6 | L41–43 | not for design; not a new story for an item with an approved one; approved artifacts change only via amendment | `SKILL.md` paragraph under the route table | reworded: "An item that already has an approved story takes the amendment route, however the request is worded: an approved artifact changes only through the amendment route, never through a new story. Designing a solution is neither route" |
| 7 | L45–47 | Flow heading, "follow in order" | `capture-new-story.md` ## Flow | verbatim |
| 8 | L49–137 | steps 1–6: language, ambiguity, profile assessment (axes, triggers, derived mode), one question round + pause, axis vs mode correction, derivation statement, **unrecordable answer → stop without writing**, "proceed anyway" = accept, never lower; grounding floor; invariant grep | `capture-new-story.md` steps 1–6 | verbatim |
| 9 | L138–139 step 7 | size | `capture-new-story.md` step 7 | "per the template's calibration" → "per the size calibration in `SKILL.md`" |
| 10 | L140–141 step 8 | draft in the response, nothing on disk | `capture-new-story.md` step 8 | "from the template below" → "from the story template in `SKILL.md`" |
| 11 | L142–152 steps 9–11 | present and wait, re-validate every constraint, write only approved text, commit protocol, hand off and stop | `capture-new-story.md` steps 9–11 | verbatim |
| 12 | L154–190 | story template (fence, profile header, italic AC rule line, AC-1…3) | `SKILL.md` ## Story template | verbatim — check 4d reads it here unchanged |
| 13 | L192–195 | size calibration | `SKILL.md` | verbatim |
| 14 | L197–198 | criteria are outcomes, not steps | `SKILL.md` | verbatim |
| 15 | L200–203 | AC-ID purpose, italic line travels | `SKILL.md` | verbatim |
| 16 | L205–207 rule 1 | free before commit, fixed at commit | `SKILL.md` | "(steps 8–9)" → "(capture steps 8–9)", "(step 10)" → "(capture step 10)"; rewrapped |
| 17 | L208–235 rules 2–5 | never renumber/reuse, withdrawn/narrowed forms, concurrent amendments stop for a human, citation form, older stories adopt IDs | `SKILL.md` | verbatim |
| 18 | L237–245 | worked example table | `SKILL.md` | verbatim |
| 19 | L247–270 | profile log: when written, line shape, three event kinds, named verification is not an override, header is the single writable copy | `SKILL.md` | verbatim |
| 20 | L272–288 | story path, local date, deterministic slug, `-2`/`-3` suffix | `capture-new-story.md` ## Writing the story file | verbatim |
| 21 | L290–303 | commit protocol: staged-work stop, stage only the story, verify path and content, restore and stop on mismatch, commit message | `capture-new-story.md` | verbatim |
| 22 | L305–317 | amendment route purpose, runs none of the Flow's steps, no new design decision | `amend-approved-artifact.md` ## Amending an approved story or spec | verbatim (heading kept: check 4f anchor, sparring pointer) |
| 23 | L319–321 | who runs it (coding session writes; sparring drafts) | `amend-approved-artifact.md` | verbatim |
| 24 | L325–382 steps 1, 2, 4, 5, 7, 8, 9 | decision (only question, wait), baseline (stop if missing), enumerate, fate needs a quoted covering passage, *Unaccounted*, cite gate rules, write/commit deferring to gates, stop and resume nothing | `amend-approved-artifact.md` ### Steps | verbatim |
| 25 | L334–339 step 3 | capture current state, intervening changes | `amend-approved-artifact.md` step 3 | adds "(in `SKILL.md`)" after "rule 3"; rewrapped |
| 26 | L356–363 step 6 | apply AC-ID rules 1–5, `none` for unaccounted | `amend-approved-artifact.md` step 6 | adds "(in `SKILL.md`)" after "rules 1–5"; rewrapped |
| 27 | L384–429 | change-record template, closed sets, narrowed-vs-replaced test, example rows | `amend-approved-artifact.md` ### The change record | verbatim — check 4f must read this file (see risks) |
| 28 | L431–434 | Stop-and-ask intro | `capture-new-story.md` ## Stop and ask | reworded: "These stops belong to the Flow. The amendment route's stops are in its own steps; only **No AGENTS.md** applies to both routes." → "These stops belong to the Flow. The amendment route's stops are in its own steps (`amend-approved-artifact.md`); **No AGENTS.md** applies to both routes and is stated in `SKILL.md`." |
| 29 | L436–446 | one-round pause, grounding floor + report shape, dirty index | `capture-new-story.md` ## Stop and ask | verbatim |
| 30 | L447–449 | no AGENTS.md stop (both routes) | `SKILL.md` ## Stop: no AGENTS.md | verbatim, kept in the root so it binds before either route loads |
| 31 | L450–462 | no brainstorming: still write + commit, then stop, install text | `capture-new-story.md` ## Stop and ask | verbatim |
| 32 | L464–473 | hand-off: check availability, name next step, stop, do not invoke | `capture-new-story.md` ## Hand-off | verbatim |
| 33 | L475–486 | common mistakes | `SKILL.md` ## Common mistakes | verbatim, plus one new line (below) |
| N1 | — | route table; "choose before anything else" | `SKILL.md` *Choose the route first* | **new** |
| N2 | — | load rule: read the route file in full, on its own, with the Read tool, before the route's first step; re-read after compaction or resume; on a truncation marker read the missing part; if unreadable, stop and report path and error | `SKILL.md` | **new** — the evidence for its wording is `compare.md` (v1 vs candidate2) |
| N3 | — | "Running a route without having read its route file" | `SKILL.md` common mistakes | **new** |
| N4 | — | each route file: header naming `SKILL.md` for the shared parts, a one-line contents list | both route files | **new** |

## The deltas: 0.23.0's additions and set 2's correction

| 0.23.0 lines | What it carries | New location | Status |
|---|---|---|---|
| 356–359 | step 5: "Then list what the decision adds with no earlier condition behind it …" | `amend-approved-artifact.md` step 5 | moved |
| 360 | step 6 opening: "rules 1–5 exactly as written" | `amend-approved-artifact.md` step 6 | reworded: "rules 1–5 (in `SKILL.md`) exactly as written" (pilot row 26) |
| 367–371 | step 6 last sentence: "Each entry in *Added without an earlier condition* stands in the changed artifact …" | `amend-approved-artifact.md` step 6 | reworded: "in §3 under rule 2 (the next unused" → "in §3 under rule 2 (in `SKILL.md`; the next unused" |
| 404 | template field line "- **Added without an earlier condition:** …" | `amend-approved-artifact.md`, change-record template | moved (check 4f pins it) |
| 421–443 | "**Added without an earlier condition — the rules.**" with its five bullets and the example entry | `amend-approved-artifact.md`, after the closed sets | moved |
| pilot N2 (new text) | the load rule's re-read sentence | `SKILL.md`, "Choose the route first" | **set 1:** "This page stays loaded and the route file may not — if the route file is no longer in your context (after a compaction, or in a resumed session), read it again before your next step." **set 2:** "Read the route file again after every compaction, before your next step, whether or not it still seems to be in your context; in a resumed session, read it again if it is no longer in your context." |
| amendment-route header (pilot N4) | the contents line | `amend-approved-artifact.md` header | reworded: "(template, closed sets, the narrowed-or-replaced test, example rows)" → "(template, closed sets, the added-criterion rules and example, the narrowed-or-replaced test, example rows)" |

No row is dropped as a whole; row 5 lost one rationale clause, recorded above. The split was not
adopted, so that gap was recorded rather than repaired.
