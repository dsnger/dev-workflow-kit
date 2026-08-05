# A supersession convention for the hardening ledger — Design

**Story:** `docs/superpowers/stories/2026-08-04-hardening-ledger-supersession-story.md`
— the profile lives in that story's header and is read fresh at every pass. No value from it
is copied here.

**Scope:** the ledger header convention, its mirror in `/workflow-init`'s inline template, and
the one phrase in `harden-finding` that the convention falsifies. Nothing else.

**How to read this document.** It states decisions and their reasons. It does not record how
those decisions were revised — that history lives in
`.context/codex-reviews/gate-a-spec-pass-*-dispositions.md`, one file per review pass.

## 1. The gap

`docs/hardening-log.md`'s header carries two standing rules: never edit a row, and one row per
hardening. When a landed row's text stops describing reality, neither move is sanctioned —
editing breaks the first rule, and appending a row that records no hardening breaks the second.

The gap is live. The 2026-07-20 `truncated-tool-output-read-as-complete` row narrates the gate
hook counting every incomplete pass, which is pre-0.8.0 behaviour, and a reader who trusts it
is misled about how the hook counts today.

## 2. The convention

Two paragraphs are added to the ledger header, after the existing `Never edit a row…` sentence.

### 2.1 The sanctioned move and its boundary

```markdown
A row states what was true at its date. When a **landed** row's text no longer describes
reality — falsified by a later change, or wrong when written — append a `Superseded rows`
entry rather than editing it. *Landed* = present in this file at the merge-base with `main`;
a row authored in the cycle now open is not landed and is amended in place until that cycle
closes. Supersession marks a row's **text**, never its hardening: the row keeps its
fingerprint, keeps matching the column-2 grep, and keeps counting. A hardening later removed
is out of scope.
```

Each clause closes a state class, which is why the paragraph is this long:

| Clause | The state it settles |
|---|---|
| `A row states what was true at its date` | what a row is a claim about |
| `falsified by a later change, or wrong when written` | the two covered causes |
| `*Landed* = …merge-base with main` | when append-only starts binding |
| `a row authored in the cycle now open… amended in place` | the in-flight row |
| `marks a row's text, never its hardening` | what supersession does not undo |
| `keeps its fingerprint… keeps counting` | the effect on recurrence: none |
| `A hardening later removed is out of scope` | the uncovered case, named rather than implied |

**Why append-only binds at the merge-base and not at the first commit.** A Gate-B cycle takes
`WIP:` snapshot commits by construction (`CLAUDE.md` §5 Mechanics), so "committed" would make
every mid-cycle snapshot final and force a supersession entry for a row nobody outside the
cycle has ever read. The merge-base line puts the boundary where the record actually becomes
shared. It is also the one part of this convention a machine could decide — `git show
<merge-base>:docs/hardening-log.md` settles it. No checker is proposed; the decidability is
recorded so a future reader knows the option exists.

**Why supersession leaves recurrence alone.** A falsified row's *hardening* still stands — the
rule, test or lint it landed is untouched by the change that falsified its narration. Ejecting
it from the lineage would misreport the class's history to `harden-finding`'s recurrence step
and to any later reader of the ledger.

### 2.2 The block

```markdown
**Superseded rows** — omitted until the first entry, then one appended line per row:

`- <date> · supersedes <row date> <fingerprint> · what is now false · where the current answer is`

Locator is date + fingerprint; where that pair matches more than one row, add a
distinguishing fragment of the row's `finding`. Superseded twice → two entries, latest
wins. Nothing
mechanical reads this block: to every grep and skill scanning the table a superseded row is
unchanged, including one whose entry says its fingerprint is wrong — prose readers get the
correction, mechanical readers do not, and nothing checks the difference.
```

**Placement:** between the header prose and the `Columns:` paragraph, above the table.

- Rows append at the end of the file and this block sits at the top, so the two append points
  are maximally separated and `merge=union` cannot interleave an entry into the table.
- A reader meets it before the rows rather than below twenty-two rows that each run to roughly
  a thousand characters.
- It is a bold label, not a `##` heading, so the file keeps its single-heading structure and
  the table does not fall under a section named for something else. This matches the story
  template's `**Profile log:**`, including the omit-until-first-entry rule.

**Locator.** Date plus fingerprint is the locator the header's existing `ref` convention
already uses ("the prior row's date + anchor"). **The pair is not unique, today:** of the
twenty-two current rows, `2026-07-18` + `docs-drift` matches two — the manifest-declares-hooks
row and the spec-not-updated-with-the-fix row. The distinguishing-fragment fallback is
therefore a live requirement, not a contingency, and superseding either of those two rows
needs one.

The fragment is free text and does not *guarantee* uniqueness; it is a reader's disambiguator.
Requiring one on every entry was rejected — it is redundant on the twenty other pairs, and a
uniform three-field locator would still not guarantee more than this one does.

**Format.** Prose only — no machine-readable fields. A supersession entry that a tool parses
becomes wire format in every scaffolded ledger, and the reader that would consume it does not
exist yet and is being redesigned elsewhere (§6).

## 3. The two cases the convention must resolve

### 3.1 The 2026-07-20 row — the first entry

```
- 2026-08-05 · supersedes 2026-07-20 `truncated-tool-output-read-as-complete` · its `ref` states that an incomplete pass still increments the counter, including a failed review returning `{success: false}` — true when written, and as of 0.8.0 the hook withholds the count for three recognized shapes, that envelope among them, while every other shape still counts · CLAUDE.md §5, "What this does not do"
```

The entry is falsification-scoped, not row-scoped: it names the sentence that stopped being
true and says what replaced it, and it does not imply the rest of the row is stale. The
`mcp-codex-dev@1.0.1` pin the same row cites is still what `.mcp.json` carries, and the entry
says nothing about it.

### 3.2 Row D — resolved by the boundary, not by an entry

The 2026-08-04 `mechanical-check-skipped-before-review` row was amended during its own
authoring cycle in PR #22. Under §2.1 that was correct and leaves no record: the row was not
landed. The precedent becomes the rule rather than an exception to it.

## 4. Change surface

| File | Change |
|---|---|
| `docs/hardening-log.md` | §2.1 and §2.2 header paragraphs, the block, and §3.1's entry |
| `plugins/dev-workflow/commands/workflow-init.md` | §2.1 and §2.2 mirrored into the inline ledger-header template — prose only, no block, no entry |
| `plugins/dev-workflow/skills/harden-finding/SKILL.md` | §5 |
| `plugins/dev-workflow/.claude-plugin/plugin.json` | `0.8.1` → `0.8.2` |
| `plugins/dev-workflow/CHANGELOG.md` | one entry for `0.8.2` |
| `todos.md` | the source row resolved; the uncovered case parked with its trigger |

**Parity, stated so a check knows what it compares:** the *header prose paragraphs* are
byte-identical between `docs/hardening-log.md` and the inline template, modulo hard-wrap
position. The `Superseded rows` block and the table rows are project content and exist only in
the repo copy — the same asymmetry the two files already carry, since the template ships an
empty table.

**Invariant 9 needs nothing.** An existing scaffolded project re-running `/workflow-init` meets
the header as "present and different", which already routes to show-the-diff-and-ask.

**Version bump.** `0.8.2`, patch: the change adds a convention to a scaffolded template and
corrects one phrase in a skill. No component is added, removed, or renamed.

## 5. The `harden-finding` phrase

`plugins/dev-workflow/skills/harden-finding/SKILL.md`, § Log format, currently ends:

> …`ref` naming the prior row's date + anchor); never edit an existing row.

Under §2.1 that sentence is wrong in the row-D direction: a run that appends a row and then
finds a mistake in it before the cycle closes would read "never edit an existing row" and
supersede a row that never landed. The replacement defers to the header rather than restating
it, so the two cannot drift:

> …`ref` naming the prior row's date + anchor); never edit a landed row (see the ledger
> header).

Nothing else in the skill changes. Its recurrence step (step 3) is untouched by design —
supersession is invisible to it, per §2.1.

## 6. What this design hands to another story

`docs/superpowers/stories/2026-08-04-harden-finding-guard-scope-precheck-story.md` owns the
redesign of how a recurrence decision reads the ledger. §2.2 leaves a prose-only correction
that nothing consumes, including a note that a row's fingerprint is wrong. Whether the
redesigned reader should consult the `Superseded rows` block, and whether a prose-corrected
class changes the lineage it escalates from, is recorded there as an inherited open question.
It arrives as a handoff, not as a failure: no instance has occurred.

## 7. Validation

**Mode:** `battery+check`, from the story header.

**Battery:** the full command in `AGENTS.md` § Commands.

**The check — a named verification, with its counterfactual.** No harness reads ledger prose,
so the `+check` obligation is met by a named verification rather than an automated test.

- *Claim:* a reader of the 2026-07-20 row can reach the correction from the ledger alone.
- *Verification:* `grep -n 'supersedes 2026-07-20' docs/hardening-log.md` returns §3.1's entry,
  and its locator (`2026-07-20` + `truncated-tool-output-read-as-complete`) resolves to exactly
  one row in the table.
- *The falsifying observation:* at the merge-base with `main`, that grep returns nothing and
  the header offers no sanctioned move for either case in §3. That is the pre-change state, so
  the check fails without the change rather than being wired to pass.

**Prompt conformance:** `docs/prompt-standards.md`, all twelve items, on
`plugins/dev-workflow/commands/workflow-init.md` and
`plugins/dev-workflow/skills/harden-finding/SKILL.md` — both invariant-11 surfaces.

## 8. Gate-A riders, verbatim in every pass prompt

1. **Sweep before reading.** Mechanically settle whatever this spec asserts that a machine can
   decide without side effects — cited paths, quoted passages, line numbers, stated counts, the
   uniqueness claim in §2.2, the parity claim in §4, and the syntax of standalone fenced blocks.
   Both source files are hard-wrapped, so compare quoted markdown with whitespace normalized and
   report a wrap artifact as a wrap artifact. Inspect quoted commands rather than running them.
   Report what the sweep found separately from what the read found.
2. **Self-test.** Apply §2.1's convention to both cases in §3 — case 3.1 must route to an entry
   and case 3.2 must route to an in-place amend. Report both explicitly either way.
3. **Old-conditions audit.** §5 replaces a decision procedure's phrase. List every condition the
   current sentence carries and mark each kept, moved, or deliberately dropped
   (`AGENTS.md` Don'ts).

## 9. What this does not do

- **It adds no mechanical check.** Nothing validates that a superseded row has an entry, that an
  entry's locator resolves, or that a row was landed when superseded. A reader is the detection.
- **A superseded row is unchanged to every tool.** The column-2 recurrence grep, any count over
  the table, and `harden-finding`'s escalation all see the row exactly as before — including one
  whose entry says its fingerprint is wrong.
- **The convention does not reach the reader that would consume it.** §6 hands that to the
  guard-scope story; until it lands, the correction is prose a human reads.
- **It does not cover a hardening that is later removed.** Named as out of scope in §2.1 and
  parked in `todos.md` with its trigger — the first rung actually removed. No instance exists.
- **A generic anchored grep over the block would also match the format example** in §2.2's
  fenced line, in both the repo header and the template. POSIX grep has no fence awareness —
  the same limitation `scripts/check-invariants.sh`'s check 4a already records. §7's
  verification greps the specific locator instead, and this is stated for whoever later builds
  a reader.
- **It changes nothing about how the gate hook counts.** §3.1 records that 0.8.0 already
  changed it; this design only marks the row that still describes the old behaviour.
