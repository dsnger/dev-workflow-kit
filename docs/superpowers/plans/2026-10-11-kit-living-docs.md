# Kit living docs — Implementation Plan

> **For agentic workers:** execute task by task with superpowers:executing-plans (Native). Steps are prose by
> design (CLAUDE.md §4: the plan settles decisions; code and exact wording are written in implementation).

**Story:** `docs/superpowers/stories/2026-10-11-kit-living-docs-architecture-prd-tech-story.md` (read the profile there, fresh)
**Spec:** `docs/superpowers/specs/2026-10-11-kit-living-docs-design.md` (Gate-A spec cycle sbj29fyiw236, closed 840d968)

**Goal:** the kit repository follows its own docs model: `docs/ARCHITECTURE.md` holds the only
tree, `docs/PRD.md` and `docs/TECH-STACK.md` exist, and `AGENTS.md` keeps its invariants and its
binding boundary sentences while losing the copied descriptive text.

**Worktree / branch:** `/Users/daniel/DEVELOPMENT/APPS/dev-workflow-kit-project-docs`,
`project-docs-part-a`, base `d9fee8e`.

## Global constraints

- The moratorium (`.claude/review-gates.md`): no new sentence stating an obligation, prohibition
  or permission in `AGENTS.md` or `CLAUDE.md`. Moves and rewordings only, each one traced in the
  PR's mapping table.
- Nothing under `plugins/`, `docs/superpowers/` (except this plan), `source-files/` or any
  CHANGELOG changes.
- Invariant 5: no floating executable reference anywhere in the new files. Spec §5: no version
  string in `docs/TECH-STACK.md`.
- Never `git add -A`. The untracked `.claude/worktrees/` lives in the main checkout, not here, but
  each commit still stages named paths only.

## Review focus

- The case-only rename on a case-insensitive macOS filesystem. A half-done rename can look
  right locally and leave the wrong spelling tracked for a case-sensitive checkout. No CI step
  checks this path, so Task 1's index check is the only evidence.
- Markdown links to anchors (`AGENTS.md#…`, vision § links). A heading spelled differently from
  its link breaks silently. Task 5's link check covers every link in the three new files.
- A binding item reflowed with a changed character. Task 5's one-to-one check catches it.
- A reworded Don't that loses part of its condition (AGENTS.md Don't, "Never replace a decision
  procedure without accounting for its old conditions"). Task 2's mapping table lists every
  changed sentence with old and new text.
- Check 4g and the quality battery: they must stay green, especially check 4's pin scan over the
  new docs.

## Sources and impact boundary

**Read:** the story (with its §3 change record), the spec, `AGENTS.md`, `CLAUDE.md`,
`.claude/review-gates.md` (in full), `docs/architecture.md`, `README.md` around the layout link,
`todos.md` around line 930, `.github/workflows/ci.yml`, `.mcp.json`, vision §1, §3, §7 and §8,
`docs/hardening-log.md` (for column 2 classes), `MANIFEST.md`.

**Reference sweep:** `git grep -n "architecture\.md"` and `grep -rn "layout tree\|## Architecture\|Boundaries"`
over the repo. The live references to the moved material are `README.md:222`,
`AGENTS.md:64,243,289` and `todos.md:930`. Other live hits are unrelated uses of the words (for
example `plugins/dev-workflow/skills/sparring/SKILL.md`'s own "Boundaries" item, and `AGENTS.md`'s
section heading itself). The remaining hits are in dated records or `.context/`. Before editing `AGENTS.md` or the architecture
document, also run the census the manifest Don't prescribes,
`grep -rniE 'declare[sd]?|convention[- ]load' --include='*.md' . | grep -v source-files/`, and read
its live hits (`AGENTS.md`, `MANIFEST.md`, `docs/architecture.md`, `README.md`) against
`plugin.json`. A live hit that contradicts the manifest is a stop. The census widens the
reading, not the edit scope.

**Impact boundary:** the files listed in tasks 1 to 4. Not looked at, because nothing reads the
moved text mechanically: `scripts/` (check 4g reads only sizes; no script parses `AGENTS.md`'s
Architecture section, verified by grep). `.claude/review-gates.md` was read in full and is
unaffected: it cites `@AGENTS.md` as a whole, not the section. The `/workflow-init` template's `CLAUDE.md` sentence about `@AGENTS.md`
is in a plugin file and stays (Part B). In a scaffolded project it remains true.

**Closing this plan's Gate-A cycle (before Task 1):** at the clean final pass, compare the
plan file's sha256 with the sha256 named in that pass's request. If `HEAD` already carries that
text at the plan path, amend `HEAD`'s message only, adding the provenance line, the curve and the
ledger-check lines. If the reviewed repairs are uncommitted, commit the plan file unchanged with
those records. Then check that `git show HEAD:<plan path>` has the reviewed sha256. Task 1 starts
only after that.

**Handover boundary:** the PR opened and green with bots processed. At that point, write the
handover in `.context/handover-mcp-security.md` (top entry) and STOP. Merge is Daniel's word via
the orchestrator.

---

### Task 1: `docs/ARCHITECTURE.md`

**Outcome:** the file exists at the new path with history attached, and holds spec §2's five
sections in order.

- [ ] Rename in two steps: `git mv docs/architecture.md docs/architecture.tmp.md`, then to
  `docs/ARCHITECTURE.md`. **Expected:** `git ls-files -- docs/ARCHITECTURE.md docs/architecture.md
  docs/architecture.tmp.md` prints exactly `docs/ARCHITECTURE.md`.
- [ ] **Layout:** replace the old tree with `AGENTS.md`'s tree plus its framing sentence. Change
  the `docs/` entries: drop `architecture.md`, and add `ARCHITECTURE.md`, `PRD.md` and
  `TECH-STACK.md` with one-line comments. Reword any row comment that only made sense inside
  `AGENTS.md` (the `AGENTS.md` row's "this file …") so that it names `AGENTS.md`'s role, and record
  it in the sentence map. The full path check runs in Task 3, after the two new files exist.
- [ ] **Components:** this section holds the inventory sentence from `AGENTS.md` Boundaries (hook
  and its test, two checkers and suites, six reports and suites, "everything else is text read by a
  model"). It also keeps the manifest fact "declares no components" and the 0.2.1 history, after
  reading `plugins/dev-workflow/.claude-plugin/plugin.json` in this session. The rule parts are
  replaced by links to `AGENTS.md#boundaries-binding` and to invariant 6. If `plugin.json`
  declares anything, stop: the spec's premise is false.
- [ ] **Boundaries and dependency direction:** a short descriptive paragraph, written fresh, with
  no binding sentence in it. It links `AGENTS.md#boundaries-binding` and names invariant 7 for
  `examples/`.
- [ ] **The two design decisions:** the existing sections, byte-for-byte. **Expected:**
  `git diff -M d9fee8e -- docs/architecture.md docs/ARCHITECTURE.md` shows no change inside them.

### Task 2: `AGENTS.md` and `CLAUDE.md`

**Outcome:** spec §3 and the `CLAUDE.md` bullet of spec §6 are applied. Every changed sentence is
recorded in a mapping table, saved as `.context/k7a-sentence-map.md`, which is later pasted into
the PR body.

- [ ] Header line 3 is reworded (descriptive), and the old and new text go into the map.
- [ ] `## Architecture` is kept as the heading. The body becomes the three descriptive pointer
  lines, then a `### Boundaries (binding)` heading (anchor `boundaries-binding`), then the seven
  items as a numbered list. Each item is copied from spec §3's list. Line breaks may differ, and
  nothing else may.
- [ ] Delete the tree, its framing sentence and the old Boundaries and Dependency-direction
  paragraphs. Each deleted sentence goes into the map with its destination: `docs/ARCHITECTURE.md`
  § Layout or § Components, binding item n, or invariant 7 (for the `examples/` sentence).
- [ ] Don'ts. In "Never rename or delete …", "the layout tree above" becomes "the layout tree in
  `docs/ARCHITECTURE.md`". In "Never state what the manifest declares …", `docs/architecture.md`
  becomes "the former `docs/architecture.md` (now `docs/ARCHITECTURE.md`)". Also fix the
  "this file's own layout tree" clause, which stays true as history, with a minimal "(then in
  `AGENTS.md`)" only if it would otherwise read as current. Each rewording goes into the map,
  with its full old and new sentence.
- [ ] `CLAUDE.md`, last paragraph: reworded per spec §6, descriptive only, and recorded in the
  map.
- [ ] **Expected:** `git diff d9fee8e -- AGENTS.md CLAUDE.md` touches only the lines the map lists.
  The map has one row per changed sentence. No row adds a sentence with *must, never, always, may,
  only* that the baseline did not carry in the same sense. This is a reading check, written into
  the map as a column "rule? baseline source".

### Task 3: `docs/PRD.md` and `docs/TECH-STACK.md`

**Outcome:** spec §4 and §5 are applied.

- [ ] **PRD head** (at most 50 lines before the feature map): Problem (links `AGENTS.md#what-this-project-is`);
  Success measures table with the five rows of spec §4, each with a "how it is read" cell (the
  command or file section) and a source cell; Non-goals (one link to vision §8). Any measure whose
  source the implementer cannot point to is written "open". No number is copied in. The limits that
  checks 4e and 4g enforce are read from those checks by name, not restated.
- [ ] **Feature map**: the six rows of spec §4, with status *shipped* (from vision §3 / §7 or the
  shipped files) and *planned* for orchestrator/lane.
- [ ] **TECH-STACK**: the nine rows of spec §5. **Expected:**
  `grep -E '[0-9]+\.[0-9]+' docs/TECH-STACK.md` prints nothing.
- [ ] **Tree path check**, now that all three docs exist: stage the three new files by name
  (`git add docs/ARCHITECTURE.md docs/PRD.md docs/TECH-STACK.md`). Then confirm that every path the
  `docs/ARCHITECTURE.md` tree names, with brace forms expanded, is in `git ls-files` or is a
  tracked directory prefix. A missing path is a stop, not an edit to hide it.

### Task 4: live references

**Outcome:** spec §6's README and todos bullets are applied.

- [ ] `README.md:222` link → `docs/ARCHITECTURE.md`.
- [ ] `todos.md:930`: the row names `docs/ARCHITECTURE.md`. The row's meaning is otherwise
  unchanged; this is a record edit, so no Gate A applies ("Recording is not amending").

### Task 5: evidence, battery, Gate B, PR

**Outcome:** spec §7's checks have run on both states. The battery is green, Gate B is closed, and
the PR is open.

- [ ] **Link check** over the three new files and the changed `AGENTS.md`/`README.md` lines. Every
  relative path resolves to a tracked file, and every `#anchor` matches a heading slug in its
  target (GitHub slug rule: lowercase, spaces → hyphens, punctuation dropped). Throwaway script in
  the scratchpad; record its output.
- [ ] **WIP commit**: stage the changed paths by name and run `git commit -m 'WIP: kit living docs'`.
  Everything below runs on this commit ("the head" = the WIP commit, read with `git show HEAD:` /
  `git grep … HEAD`), with the working tree clean of tracked changes.
- [ ] **Change checks** (spec §7), each run on `d9fee8e` and on the head, with both results
  recorded:
  - Tree uniqueness: fenced-block line `plugins/dev-workflow/` across tracked files, excluding
    `docs/superpowers/`, `source-files/` and CHANGELOGs.
  - No stale link. The baseline hits are the historical `AGENTS.md:243` mention plus the live
    `README.md` and `todos.md` hits (this wording replaces spec §7's "AGENTS.md's live uses", per
    Gate-A NIT pass-3:1). At the head, only the "former" mention remains.
  - Descriptive text gone from `AGENTS.md`.
  - No version string in `docs/TECH-STACK.md`.
  - Binding list in place: the seven items under `### Boundaries (binding)`, whitespace-collapsed,
    compared one to one with spec §3's list.
- [ ] **Preservation check** on the baseline: the seven fragments, whitespace-collapsed, are
  substrings of `git show d9fee8e:AGENTS.md`. (All seven were pre-checked true on 2026-10-11.)
- [ ] **Battery** on the committed state: the quality command from `AGENTS.md` § Commands
  (`check-version-bump.sh main` needs commits). Record `wc -c AGENTS.md` before (27,294) and after.
- [ ] **Evidence entry** for the story, now that the battery and the checks above have run. It
  names the verification route ("named verification: document properties"), each check with its
  two results, and the battery result. It is saved as `.context/k7a-evidence.md`, quoted in every
  Gate-B call, and written into the closing message. The WIP message is not amended for it: the
  closing message is the entry's durable home, and leaving the WIP commit as it is avoids
  depending on the narrower amend forms the hook recognises (`.claude/review-gates.md`,
  Mechanics · `baseSha`).
- [ ] **Gate B**: two sequential `mcp__codex__review` calls (`spec`, then `quality`) on full SHAs
  (`baseSha` = the WIP parent), with the story path and the evidence entry quoted. Floor 3, cap 5.
  The cycle runs to closure by the closure ordering. The closing act amends to the real message,
  carrying the evidence entry and the cycle records.
- [ ] **PR** against `main`: body = summary, the sentence map, the evidence entry, the cycle
  records of all three cycles (spec, plan, Gate B), and `AGENTS.md` before/after size. Process bot
  comments with `/dev-workflow:process-pr-review`. Then write the handover and STOP.
