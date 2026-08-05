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

The header's existing first paragraph is **amended in one phrase** (§2.0), and §2.1 and §2.2
are added after it. All three are **identical in the repo ledger and in the inline template** —
they are the convention. The `Superseded rows:` block described by §2.2 is content, and exists
only where an entry exists (§4).

### 2.0 The amended phrase

The existing sentence reads `Never edit a row; resolve a pending row by appending…`. Left
absolute, it contradicts §2.1's in-place amend of an open-cycle row — two incompatible
instructions on one surface, which is prompt-standards item 7. One word changes:

> `Never edit a row;` → `Never edit a landed row;`

The rest of the sentence is untouched, and §2.1 supplies the definition.

### 2.1 The sanctioned move and its boundary

```markdown
A row records a hardening as of its date, and its narration may be found wrong or made stale
later. When a **landed** row's text no longer describes reality — falsified by a later change,
or wrong when it was written — append a `Superseded rows` entry rather than editing it.
*Landed* = appended by any cycle other than the one you have open: a row you appended in your
open cycle is amended in place until that cycle closes and is landed from then on; with no
cycle open every row is landed; a row another worktree appended in its own open cycle is landed
to you; and where you cannot establish that your open cycle appended a row, treat it as landed.
A *cycle* is the Gate-B cycle of `CLAUDE.md` §5 Mechanics, closing at the commit that replaces
its `WIP:` snapshot. Resolving a `pending` row always appends, in any cycle — that is a new
hardening, not a correction to a row's text. Supersession marks a row's **text**, never its
hardening: the row keeps its fingerprint, keeps matching the column-2 grep, and keeps counting.
A hardening later removed is out of scope.
```

Each clause closes a state class, which is why the paragraph is this long:

| Clause | The state it settles |
|---|---|
| `records a hardening as of its date` | what a row is a claim about |
| `may be found wrong or made stale later` | that a row's narration is not permanently true |
| `falsified by a later change, or wrong when it was written` | the two covered causes |
| `appended by any cycle other than the one you have open` | when append-only starts binding |
| `amended in place until that cycle closes… landed from then on` | the in-flight row, and its exit |
| `with no cycle open every row is landed` | the no-open-cycle state |
| `another worktree… is landed to you` | concurrent cycles, which own only their own rows |
| `where you cannot establish… treat it as landed` | unknown provenance, resolved conservatively |
| `A cycle is the Gate-B cycle… closing at the commit that replaces its WIP: snapshot` | cycle identity and its close event |
| `Resolving a pending row always appends, in any cycle` | the pending-row overlap |
| `marks a row's text, never its hardening` | what supersession does not undo |
| `keeps its fingerprint… keeps counting` | the effect on recurrence: none |
| `A hardening later removed is out of scope` | the uncovered case, named rather than implied |

**Why the boundary is authorship-by-cycle, and not a commit or a merge-base.** A Gate-B cycle
takes `WIP:` snapshot commits by construction, so a commit-based boundary would make every
mid-cycle snapshot final and force a supersession entry for a row nobody outside the cycle has
read. A merge-base boundary fails in the other direction: a row appended by an **earlier,
completed** cycle on a branch not yet merged is absent from the merge-base with `main` and
would wrongly read as amendable, which is the append-only breach the convention exists to
prevent. Authorship puts the boundary exactly where the record stops being the author's own.

**The base check is one-way, and uncertainty resolves to landed.** Presence in the ledger at
the open cycle's base commit proves a row is landed. Absence does *not* prove the converse — a
row can arrive from another cycle by merge after that base — so the rule is authorship, and the
base check only ever confirms landed. Interruption, handoff and context loss can all leave
authorship unestablished; the convention's answer is to treat the row as landed, which costs a
supersession entry nobody needed and never costs an edit to someone else's record. No checker
is proposed; this is recorded so a future reader knows which direction is decidable.

**Why the `pending` overlap resolves toward appending.** Resolving a `pending` row is a *new
hardening* — it earns its own row under the one-row-per-hardening rule — while amendment
corrects the *text* of a row still being authored. A cycle that appended a `pending` row and
then lands its prerequisite therefore appends the resolving row, exactly as before this change.
Amendment reaches that `pending` row's own wording, and nothing else.

**Why supersession leaves recurrence alone.** A falsified row's *hardening* still stands — the
rule, test or lint it landed is untouched by the change that falsified its narration. Ejecting
it from the lineage would misreport the class's history to `harden-finding`'s recurrence step
and to any later reader of the ledger.

### 2.2 The convention prose, and the block it describes

The prose below is shared by both surfaces. It carries **no** `Superseded rows:` label of its
own — that label belongs to the block, and appears only where entries do, so an empty
scaffolded ledger does not ship a label with nothing under it.

```markdown
**Correcting a landed row.** Corrections live in a `Superseded rows` block above the `Columns:`
paragraph — a `**Superseded rows:**` label carrying one appended line per supersession, present
only once at least one entry exists:

    - <date> · supersedes <row date> `<fingerprint>` · what is false · where the current answer is

Locator is date + fingerprint; where that pair matches more than one row, add a distinguishing
fragment of the row's `finding`, and where it still singles out no one row, resolve that before
writing the entry rather than filing an entry that points at two. Name the claim that does not
hold — saying whether it stopped holding or was never true — and cite where the current answer
lives; restating that answer here only makes the entry the next stale narration. Entries are
cumulative and themselves append-only: two clauses of one row falsified separately get two
entries and both stand. An entry is located by its own date plus the row it supersedes, under
the same fallback and the same stop; a correcting entry retires exactly the entries it names
and states what now holds, so nothing is restored implicitly. If a union merge leaves two
`Superseded rows:` labels, keep one and keep every entry under it. Nothing mechanical reads
this block — to every grep and skill scanning the table a superseded row is unchanged,
including one whose entry says its fingerprint is wrong; prose readers get the correction,
mechanical readers do not, and nothing checks the difference.
```

**Layout.** Amended first paragraph, then §2.1, then §2.2's prose, then the block, then the
existing `Columns:` paragraph, then the table.

- Rows append at the end of the file and the block sits at the top, so the two append points
  are maximally separated and `merge=union` cannot interleave an entry into the table.
- A reader meets it before the rows rather than below twenty-two rows that each run to roughly
  a thousand characters.
- It is a bold label, not a `##` heading, so the file keeps its single-heading structure and
  the table does not fall under a section named for something else. This matches the story
  template's `**Profile log:**`, including the omit-until-first-entry rule.

**Locator.** Date plus fingerprint is a **new, explicit locator choice**, not an inheritance:
the header's existing `ref` convention says "the prior row's date + anchor" and never defines
*anchor*, so treating it as precedent for *fingerprint* would be reading a decision procedure
more narrowly than its source says.

**The pair is not unique, today:** of the twenty-two current rows, `2026-07-18` + `docs-drift`
matches two — the manifest-declares-hooks row and the spec-not-updated-with-the-fix row. The
distinguishing-fragment fallback is therefore a live requirement, not a contingency, and
superseding either of those two rows needs one.

**Entry locators collide the same way**, and take the same rule: two entries against one row,
written the same day — which §2.2 explicitly permits, since one row can carry two
falsification-scoped entries — share date plus superseded row. That is why the fallback and the
stop apply to entry locators too; without them a correcting entry could not retire exactly one
of a same-day pair, which is what the precedence rule requires of it.

The fragment is free text and does not *guarantee* uniqueness, which is why an unresolvable
locator is a stop rather than a best effort. Requiring a fragment on every entry was rejected —
it is redundant on the twenty other pairs, and a uniform three-field locator would still not
guarantee more than this one does.

**Cumulative, not latest-wins.** Entries are falsification-scoped (§3.1), so one row can carry
two entries for two independently falsified clauses. A latest-wins rule would let a correction
to clause B silently retire a still-current correction to clause A. An entry retires an earlier
entry only by naming it.

**Cite, do not restate.** An entry says *which claim does not hold* and *where the answer now
lives*. It does not carry the new answer, because a copy of a mechanism is exactly the artifact
that goes stale next — which is how the row being superseded here got into this state.

**Both covered causes get accurate wording.** The scope covers a claim falsified later *and* a
claim that was never true, so the entry field is "what is false", and the entry says which of
the two it is. An instruction to name "what stopped being true" would have no accurate value
for the never-true case, and an author would either omit the field or misdescribe it.

**Format.** Prose only — no machine-readable fields. A supersession entry that a tool parses
becomes wire format in every scaffolded ledger, and the reader that would consume it does not
exist yet and is being redesigned elsewhere (§6).

## 3. The two cases the convention must resolve

### 3.1 The 2026-07-20 row — the first entry

```
- 2026-08-05 · supersedes 2026-07-20 `truncated-tool-output-read-as-complete` · its `ref` states that an incomplete pass still increments the counter, including a failed review returning `{success: false}`; true when written, and it no longer holds for every pass · CLAUDE.md §5, the paragraph opening `**What this does not do.** The hook counts on \`PostToolUse\``
```

The entry is falsification-scoped, not row-scoped: it names the claim that no longer holds,
says it *was* true when written rather than never true, and cites where the answer now lives —
without implying the rest of the row is stale. Two properties are deliberate. It **does not
restate** 0.8.0's counting rules, per §2.2's cite-don't-restate clause. And its citation quotes
the source markdown **including the emphasis markers**, because `CLAUDE.md` §5 contains **two**
paragraphs titled "What this does not do" — the section reference alone does not resolve, and a
fragment stripped of its `**` is not byte-findable in the file it points at.

The `mcp-codex-dev@1.0.1` pin the same row cites is still what `.mcp.json` carries, and the
entry says nothing about it.

### 3.2 Row D — resolved by the boundary, not by an entry

The 2026-08-04 `mechanical-check-skipped-before-review` row was amended during its own
authoring cycle in PR #22. Under §2.1 that was correct and leaves no record: the cycle that
appended it was the cycle then open. The precedent becomes the rule rather than an exception
to it.

## 4. Change surface

| File | Change |
|---|---|
| `docs/hardening-log.md` | §2.0's phrase, §2.1 and §2.2 prose, then the `Superseded rows:` block holding §3.1's entry |
| `plugins/dev-workflow/commands/workflow-init.md` | §2.0's phrase, §2.1 and §2.2 prose, into the inline ledger-header template — no block, since a scaffolded ledger has no entries |
| `plugins/dev-workflow/skills/harden-finding/SKILL.md` | §5 |
| `plugins/dev-workflow/.claude-plugin/plugin.json` | `0.8.1` → `0.8.2` |
| `plugins/dev-workflow/CHANGELOG.md` | one entry for `0.8.2` |
| `todos.md` | the source row resolved; the uncovered case parked with its trigger |
| `docs/superpowers/stories/2026-08-04-hardening-ledger-supersession-story.md` | already amended: acceptance criteria 3 and 4, the desired outcome, and the inherited-conditions table, each with kept/narrowed/dropped accounting — §2.0 changes a rule the story pinned, so the story is part of this change surface rather than a passive source |

**Parity, with sentinels a check can locate.** The shared region runs from the line
`# Hardening log` **inclusive** to the line ending `…and nothing checks the difference.`
**inclusive** — the last sentence of §2.2's prose. The region **includes** the four-space
indented format example, and **excludes** the `Superseded rows:` block, the `Columns:`
paragraph and the table. Inside that region the two files are byte-identical modulo hard-wrap
position. Both sentinels are unique in both files once the change lands; before it, the end
sentinel exists in neither, which §7's check 2 treats as a failure rather than as an empty
region.

**Invariant 9 needs nothing.** An existing scaffolded project re-running `/workflow-init` meets
the header as "present and different", which already routes to show-the-diff-and-ask.

**Version bump.** `0.8.2`, patch: the change adds a convention to a scaffolded template and
corrects one phrase in a skill. No component is added, removed, or renamed.

## 5. The `harden-finding` phrase

`plugins/dev-workflow/skills/harden-finding/SKILL.md`, § Log format, currently ends:

> …`ref` naming the prior row's date + anchor); never edit an existing row.

Under §2.1 that sentence is wrong in the row-D direction: a run that appends a row and then
finds a mistake in it before the cycle closes would read "never edit an existing row" and
supersede a row that never landed. The replacement defers the *definition* to the header rather
than restating it, so the two cannot drift:

> …`ref` naming the prior row's date + anchor); never edit a landed row (see the ledger
> header).

**Old-conditions audit**, per the `AGENTS.md` Don't, covering the sentence and the paragraph
around it:

| Condition the current § Log format carries | Disposition |
|---|---|
| Append rather than edit, to resolve a `pending` row | **kept, and now explicit**: §2.1 states that resolving a `pending` row always appends, in any cycle, so open-cycle amendment never reaches it |
| The resolving row carries the same fingerprint | kept |
| `ref` names the prior row's date + anchor | kept |
| Existing rows are not editable | **kept for landed rows**, whose prohibition the sentence still states; only the *definition* of landed moves to the ledger header |
| Existing rows are not editable — for a row the open cycle appended | **deliberately dropped**, which is §2.1's boundary and row D's precedent |
| Append target is `docs/hardening-log.md` | kept |
| The header owns the columns, enums and escaping | kept |
| `fingerprint` is canonical | kept |
| `finding` is one line, with `\|` escaped | kept |
| `rung` is one of the short names | kept |
| `ref` is concrete | kept |

The prohibition is therefore stated on **two** surfaces — this sentence and the ledger header —
and the definition on one. That duplication is deliberate: a `harden-finding` run reads the
skill, and a sentence that named no prohibition at all would leave it with nothing.

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

### Check 1 — the correction is reachable from the ledger alone

Two halves, because the cardinality is decidable and the content is not. Both must hold.

- *Mechanical:* both commands must report `1`. They are given in a fenced block rather than
  inline because the first pattern contains backticks, which an inline code span cannot carry.

  ```sh
  grep -c '^- 2026-08-05 · supersedes 2026-07-20 `truncated-tool-output-read-as-complete` ' docs/hardening-log.md
  grep -cE '^\| 2026-07-20 \| truncated-tool-output-read-as-complete \|' docs/hardening-log.md
  ```

  The fingerprint is inside **both** patterns on purpose: matching the
  entry on its dates alone and the row on date-plus-fingerprint would leave an entry carrying a
  wrong or missing fingerprint passing both, which is exactly the state the pair is supposed to
  rule out.
- *Named read:* a reader confirms the entry names the claim that does not hold, and that its
  citation resolves to exactly one paragraph in `CLAUDE.md`. This half is a read, **not** a
  parse — nothing validates it, and the greps above would pass an entry whose prose said
  nothing useful. Stated rather than implied, because the greps alone are what a green
  `battery+check` would otherwise rest on.
- *The falsifying observation:* at the base of this cycle the first grep reports `0` and the
  header offers no sanctioned move for either case in §3 — the pre-change state, so the check
  fails without the change rather than being wired to pass.

### Check 2 — the convention actually reached both surfaces

The parity claim in §4 is what the both-surfaces decision rests on, and check 1 would pass with
the template untouched.

- *Operation:* locate §4's two sentinels in each file. **A sentinel that is missing, or that
  matches more than once, is a failure — never an empty region.** Extract the delimited region
  from each file and compare, normalizing hard-wrap joins within a paragraph only. Leading
  indentation and blank-line structure are preserved and compared exactly: the four-space prefix
  on the format example is the only thing distinguishing it from a live entry, and a
  normalization that flattened it would let one surface convert the example into entry-shaped
  content and still report equal.
- *Three states, each distinguished:* **pre-change**, the end sentinel is convention text and
  exists in neither file, so the check fails — it does not read two absent regions as equal, and
  that failure is the falsifying observation. **One surface edited**, the sentinel is present in
  one file and absent in the other: fails. **Both edited**, the regions compare equal: passes.

**Prompt conformance:** `docs/prompt-standards.md`, all twelve items, on
`plugins/dev-workflow/commands/workflow-init.md` and
`plugins/dev-workflow/skills/harden-finding/SKILL.md` — both invariant-11 surfaces.

## 8. Gate-A riders, verbatim in every pass prompt

1. **Sweep before reading.** Mechanically settle whatever this spec asserts that a machine can
   decide without side effects — cited paths, quoted passages **byte-for-byte including
   markdown emphasis markers**, line numbers, stated counts, the non-uniqueness claim in §2.2,
   §4's parity sentinels (unique and locatable in both files, and does the region contain what
   §4 says?), §3.1's citation, the §5 disposition table against the current skill text, and the
   syntax and balance of standalone fenced and indented blocks. Both source files are
   hard-wrapped, so compare quoted markdown with whitespace normalized and report a wrap
   artifact as a wrap artifact. Inspect quoted commands rather than running them, but do check
   by reading that §7's greps would match what the spec says they match — including what they
   would *fail* to rule out. Report what the sweep found separately from what the read found.
2. **Self-test, six cases.** Apply §2.1 to: case §3.1; case §3.2; a row appended by an earlier
   completed cycle on a branch not yet merged; a row appended by the open cycle after a `WIP:`
   snapshot; a `pending` row the open cycle appended and now wants to resolve; and a row whose
   authoring cycle cannot be established. Report all six verdicts explicitly, including where
   they come out as the spec says.
3. **Old-conditions audit.** §5 carries a disposition table for the decision-procedure phrase it
   replaces. Check it against the current skill text — every condition present, every
   disposition right (`AGENTS.md` Don'ts).

## 9. What this does not do

- **It adds no mechanical check.** Nothing validates that a superseded row has an entry, that an
  entry's locator resolves, or that a row was landed when superseded. A reader is the detection.
- **A superseded row is unchanged to every tool.** The column-2 recurrence grep, any count over
  the table, and `harden-finding`'s escalation all see the row exactly as before — including one
  whose entry says its fingerprint is wrong.
- **Check 1's content half is a human read.** The greps establish that an entry exists carrying
  the expected fingerprint and that its locator selects one row; nothing establishes that the
  entry says anything true or useful.
- **The landed test is decidable in one direction only**, and the convention closes the other by
  defaulting to landed. That default is a bias, not a determination: a row the open cycle really
  did append can be treated as landed and get an entry it did not need. That cost was chosen
  over the alternative, which is editing a record someone else has read.
- **The convention does not reach the reader that would consume it.** §6 hands that to the
  guard-scope story; until it lands, the correction is prose a human reads.
- **It does not cover a hardening that is later removed.** Named as out of scope in §2.1 and
  parked in `todos.md` with its trigger — the first rung actually removed. No instance exists.
- **The union-merge repair rule is a manual instruction.** `merge=union` will duplicate a
  `Superseded rows:` label when two branches each create the block, and nothing detects or
  repairs that; §2.2 tells a human what to do when they see it.
- **The prohibition on editing a landed row is duplicated across two prompt surfaces** — the
  ledger header and `harden-finding`'s § Log format (§5). Only the definition is single-sourced.
  Nothing keeps the two prohibitions in step.
- **The format example is not an entry, and nothing enforces that distinction beyond its
  shape.** It is a four-space indented code block using `<date>` and `<row date>` placeholders,
  so no line-anchored grep for a dated entry reaches it. That is the whole guard: POSIX grep has
  no code-block awareness — the limitation recorded in `docs/hardening-log.md`'s 2026-07-26
  `unverified-enforcement-claim` row, not in `scripts/check-invariants.sh` itself, which carries
  no such comment — so an example later rewritten flush-left with a real date would become
  indistinguishable from an entry to any reader built over this block.
- **It changes nothing about how the gate hook counts.** §3.1 records that 0.8.0 already
  changed it; this design only marks the row that still describes the old behaviour.
