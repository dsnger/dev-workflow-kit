# A supersession convention for the hardening ledger — Design

**Story:** `docs/superpowers/stories/2026-08-04-hardening-ledger-supersession-story.md`
— the profile lives in that story's header and is read fresh at every pass. No value from it
is copied here.

**Scope — behavioural.** The ledger header convention and its mirror in `/workflow-init`'s inline
template. No other *behaviour* changes. `harden-finding` is **not** in scope: §2.1 narrows
nothing, so that skill's `never edit an existing row` sentence stays true and is untouched.

That is not the same as the file list. §4's change surface is authoritative and is larger: it
carries the supporting artifacts this change obliges — a version bump and changelog entry
(invariant 12), the backlog row, two stories, and one prose site the change falsified. An
implementer follows §4, not this paragraph; an earlier draft ended this sentence with "Nothing
else", which read as permission to skip them.

**How to read this document.** It states decisions and their reasons. It does not record how
those decisions were revised — that history lives in
`.context/codex-reviews/gate-a-spec-pass-*-dispositions.md`, one file per review pass.

## 1. The gap

**This section describes the state *before* this design landed.** §2 onward is the current
rule; past tense here records what motivated it, not anything still true. The story does the
same, for the same reason.

`docs/hardening-log.md`'s header carried two standing rules: never edit a row, and one row per
hardening. When a row's text stopped describing reality, neither move was sanctioned —
editing broke the first rule, and appending a row that records no hardening broke the second.
Both rules still stand unchanged; what §2.2 adds is a third move.

The gap was live. The 2026-07-20 `truncated-tool-output-read-as-complete` row narrated the gate
hook counting every incomplete pass, which is pre-0.8.0 behaviour, and a reader who trusted it
was misled about how the hook counts today. That row is the one §3.1's entry supersedes.

## 2. The convention

The header's existing first paragraph is **untouched**. §2.1 and §2.2 are added after it, and
are **identical in the repo ledger and in the inline template** — they are the convention. The
`Superseded rows:` block described by §2.2 is content, and exists only where an entry exists
(§4).

### 2.1 The sanctioned move

```markdown
A row records a hardening claim as of its date, and its narration may be found wrong or made
stale later. When a row's text no longer describes reality — falsified by a later change, or
wrong when it was written — append a `Superseded rows` entry rather than editing it. One later
change is **excluded**: a hardening that is itself removed, for which this convention supplies no
move at all (see the end of this paragraph). This holds
for every row without exception: the existing `Never edit a row` rule is absolute, and correcting
a row is always an append. The rule is bound to rows, not to commits: once text exists as a row
it is never edited, committed or not. Drafting before a row exists — an editor buffer, a line not
yet written — is below the rule's resolution, and nothing checks one. Resolving a `pending` row also appends — that
is a new hardening, not a correction to a row's text. Supersession marks a row's **text** and
never alters mechanical behaviour, including when the entry records that the row's hardening
claim was itself false: the row keeps its fingerprint, keeps matching the column-2 grep, and
keeps counting. A hardening later removed is out of scope.
```

| Clause | The state it settles |
|---|---|
| `records a hardening claim as of its date` | what a row is a claim about — a *claim*, since the covered scope includes a hardening that never existed |
| `may be found wrong or made stale later` | that a row's narration is not permanently true |
| `falsified by a later change, or wrong when it was written` | the two covered causes |
| `This holds for every row without exception` | that there is no amendable class — the whole boundary question |
| `the existing Never edit a row rule is absolute` | that this convention adds to that rule rather than narrowing it |
| `The rule is bound to rows, not to commits` | the resolution floor: what the rule attaches to |
| `Drafting before a row exists… is below the rule's resolution` | the level the rule deliberately does not reach |
| `Resolving a pending row also appends` | the pending-row overlap |
| `marks a row's text and never alters mechanical behaviour` | what supersession does not undo |
| `including when the entry records that the row's hardening claim was itself false` | the phantom-hardening row, which is still not ejected |
| `keeps its fingerprint… keeps counting` | the effect on recurrence: none |
| `A hardening later removed is out of scope` | the uncovered case, named rather than implied |

**Why there is no amendable class.** Three boundaries were designed and deleted before this one:
authorship-by-cycle, reachability from `origin/main`, and content presence in the published
ledger. Each tried to name a set of rows a reader may still edit, and each failed the same way —
Gate-A passes 4 through 7 each found the *replacement* for the previous boundary unsound, three
times in the very sentence written to fix its predecessor: "the repository always answers"
became "confident *present* and confident *absent*", which was itself unsound because a
stale-but-readable ref returns a confident *absent* for a row already published. Every version
also needed its own old-conditions accounting, its own six-case self-test, its own concurrency
assumption and its own residual list, and each of those grew defects of its own.

The boundary is deleted rather than fixed again. There is no test to get wrong, no set to
enumerate, no verdict that can flip, and nothing to keep in step across two prompt surfaces. A
correction is always an append. The whole cost is stated below and is one entry.

**The resolution floor, and why it is bound to rows.** A rule that says "never edit a row"
invites the same debate one level down: *may I fix a typo before I commit?* Left unanswered, that
question rebuilds the amendable class from scratch — first as a buffer, then as a working tree,
then as a branch, and the boundary is back. The convention therefore states its own resolution.

It is bound to **rows**, not to commits. An earlier draft said the convention "governs committed
content", which read against "every row without exception" left a row *already appended but not
yet committed* matching both descriptions with no verdict — the amendable class reappearing
through the sentence written to prevent it. Attaching the rule to the row removes that state:
the moment text exists as a row it is protected, committed or not, and what sits below the rule
is only the drafting that precedes a row existing at all. That distinction needs no test, because
"is there a row here" is not a question anyone has to compute.

It is deliberately *not* a licence with conditions. Nothing distinguishes a buffer from a working
tree, because a rule that started distinguishing would be the boundary again.

**Entries take the same floor, stated rather than inferred.** §2.2's "never edited, never removed"
would otherwise leave the same gap one level over: an author with a mistyped locator in the working
tree asks the question the row floor already answers, and answering it by analogy is how the
amendable class comes back. So the floor is written into the shared prose — an entry is protected
once the line is a **complete** entry, committed or not — and §6's check 1d is built on that, not
on a convention that a mistyped entry may be quietly deleted before anyone sees it.

The boundary is completeness rather than existence, and that is load-bearing in both directions.
A line that does not yet carry the entry shape is still drafting, so an author can fix a half-typed
or malformed one — which is what makes 1d's recognition oracle actionable, since it *fails* on an
unparseable candidate and an author who could not repair it would be stuck. A **complete** entry is
protected the moment it exists, including one whose locator matches nothing: that is the case the
append-a-correction rule is for.

**What this costs: one entry, once.** Under the deleted boundaries, the 2026-08-04
`mechanical-check-skipped-before-review` row (row D) was a *correct* in-place amend. Under this
convention it is not: the correct move was an entry. That is the entire historical cost — one
row, one entry, in the whole ledger — and §3.2 records it rather than carving an exception for
it.

**Why the `pending` overlap resolves toward appending.** Resolving a `pending` row is a *new
hardening* — it earns its own row under the one-row-per-hardening rule — while an entry corrects
a row's *text*. The two never compete now that both are appends: a `pending` row's resolution
appends a row, and a correction to any row's wording appends an entry.

**Why supersession leaves recurrence alone.** For a row whose narration was made stale *later*,
the *hardening* still stands — the rule, test or lint it landed is untouched by the change that
falsified its narration — so ejecting it from the lineage would misreport the class's history to
`harden-finding`'s recurrence step and to any later reader of the ledger.

The never-true cases take the same answer for a different reason. Because the scope covers a claim
that was *never true*, an entry may record that the row's fingerprint is wrong, or that the row's
**hardening itself** never existed or was misclassified — and there the mechanical lineage is
**already** wrong: it reports a class or a rung that was never landed. Keeping such a row counting
preserves that misclassification; it does not protect accurate history, and this design accepts
that knowingly rather than claiming otherwise. The boundary is stated on mechanical behaviour
rather than on the hardening's truth — supersession changes text and changes nothing a tool reads,
in every case — because that is a rule a reader can apply without first adjudicating whether a past
hardening was real, and because the alternative reopens an edit path into the table. A lineage can
therefore escalate from a rung that was never landed; the consequence is owned by the reader being
redesigned in §5, not by this convention.

### 2.2 The convention prose, and the block it describes

The prose below is shared by both surfaces. It carries **no** `Superseded rows:` label of its
own — that label belongs to the block, and appears only where entries do, so an empty
scaffolded ledger does not ship a label with nothing under it.

```markdown
**Correcting a row.** Corrections live in a `Superseded rows` block above the `Columns:`
paragraph — a `**Superseded rows:**` label carrying one appended line per supersession, present
only once at least one entry exists:

    - <date> · supersedes <row date> `<fingerprint>` "<row fragment>" · what is false · where the current answer is

`<date>` is the day the entry is written, in `YYYY-MM-DD`. A row is located by date +
fingerprint. **An entry applies to every row its locator matches** — uniqueness is not a
requirement, and an entry that matches two rows says the same thing about both. To narrow the
match, add `"<row fragment>"`, a quoted fragment of that row's `finding` carrying no double quote,
in the position shown immediately after the fingerprint. **A fragment narrows the match set; it
singles out one row only where that row has one no sibling shares** — a sibling being another row
the same date and fingerprint match. Where it has none — an identical `finding`, one that is a
substring of a sibling's, or one whose every unique fragment carries a double quote — the entry
marks every matching row, its accurate siblings included, and no fragment prevents that. Omit it,
quotes included, when you mean every row the pair matches — including when the pair matches only
one. Name the claim that does
not hold — saying whether it stopped holding or was never true — and cite where the current
answer lives; restating that answer here only makes the entry the next stale narration. Neither
of those two fields may contain ` · `: that separator is what divides them, and free text carrying
it makes an entry parse two ways. A fragment is matched **literally and case-sensitively against
the row's `finding` as written in the file**, escapes and markup included — what you quote is what
is in the table, not what a renderer shows you. **An entry applies only to matching rows dated on or before the entry's own date** — supersession
marks the past, so a row dated later never comes under an entry written before it. **A row's date
is the day it is appended**, and the table is chronological: backdating a row is forbidden, which
is what makes the date bound mean what it says. Nothing can verify the append day itself, and
nothing checks that dates never decrease; the rule is stated and read. An entry
whose locator matches no such row is **inert**: it governs nothing and is not an error to repair
in place — append a new entry with a locator that matches, and leave the inert one standing as
history, like every other entry. **An
entry marks a row, and the last entry for a row is the one that governs** — where a row carries
more than one, later in the file wins and the earlier ones are history. **A later entry must
therefore describe the row as it now stands, not only the newly found fault**, or it retires a
still-accurate earlier entry from a reader's view. Entries are never edited, never removed, and
never reference one another — and they take the same floor as rows: once a line exists as a
complete entry it is protected, committed or not, while a line that is partial or does not yet
carry the shape above is still drafting and may be fixed. A mistyped locator in a complete entry
is corrected the same way everything else is, by appending. If a union merge
leaves two `Superseded rows:` labels, keep one and keep every entry under it. No standing tool reads
this block — to every grep and skill scanning the table a superseded row is unchanged,
including one whose entry says its fingerprint is wrong; prose readers get the correction,
mechanical readers do not, and nothing checks the difference.
```

**Layout.** The existing first paragraph — unchanged — then §2.1, then §2.2's prose, then the
block, then the existing `Columns:` paragraph, then the table.

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
matches two — the manifest-declares-hooks row and the spec-not-updated-with-the-fix row. Under
match semantics that is not a problem to solve: an entry with that locator and no fragment says
its thing about both rows, which is often exactly right. The fragment exists to narrow when it
is not.

**Why uniqueness is not required.** An earlier draft demanded a locator resolving to exactly one
row, and stopped the author when no fragment could achieve it. That rule could not survive its
own immutability guarantee: an entry unique when written is made ambiguous by a *later* row
sharing its date and fingerprint, and entries are never edited or removed, so there was no legal
repair — the convention would have contained a state it forbade fixing. A row can also have no
permitted distinguishing fragment at all — identical `finding`s are one way, and not the only one
(below) — so the stop could be unsatisfiable on the
day it was written. Match semantics has neither failure: an entry means what it matches, a later
row simply joins the set, and an author who wants one row narrows the locator.

The fragment is free text and guarantees nothing about uniqueness — under match semantics it does
not need to. It narrows the match set; it is not a resolution procedure, and it is drawn from
`finding`, so **a row can be singled out only when it has a permitted distinguishing fragment** —
a fragment of its own `finding`, containing no double quote, that no sibling matched by the same
date and fingerprint also contains. Where a row has none, an entry naming it marks every sibling
too, accurate ones included. Identical `finding`s are the obvious case and not the only one, and
the condition is **per row, not per pair**: a `finding` that is a substring of its sibling's has no
fragment the sibling does not also carry — every substring of `foo` is a substring of `foobar` —
while the sibling still has one; and a row whose every unique fragment carries a double quote is
barred by the no-double-quote rule — `foo"` against `foo`, where `"`, `o"`, `oo"` and `foo"` are
the only text the sibling lacks. Sharing a quote does not bar a row: `alpha"x` and `alpha"y`
separate on `x` and `y`. Short of that case there is no state the locator stops on:
many matches are valid and zero is inert. Requiring a
fragment on every entry was rejected — it is redundant on the twenty other pairs, and a uniform
three-field locator would still not guarantee more than this one does.

**Entries are row-markers, and the latest one for a row governs — positionally.** An earlier
draft made entries *falsification-scoped* and *cumulative*, so one row could carry two standing
entries for two independently falsified clauses, retired only by a third "correcting entry" that
named them. That machinery is **cut**. It needed a second line format, a locator that could
address an individual entry, a rule about which entries one correction may retire, and an escape
convention for quoting inside a locator — four mechanisms, none of which any tool reads, to serve
a case that has never occurred. Cutting it removes all four.

What replaces it is position: entries append, and where a row has more than one, the last in file
order is the current one. A reader needs no rule beyond "read down". The cost is real and named:
a later entry about clause B supersedes the reader's view of an earlier still-accurate entry
about clause A, so an author correcting one clause of a twice-falsified row should write an entry
that covers the row as it now stands, not only the new clause. That is a heavier ask on the
author than the cut design made, and it is the trade — author effort against four mechanisms and
their failure modes.

**Concurrency takes the same answer, and there is no assumption behind it.** Two branches can
each append an entry for one row; `merge=union` keeps both, and latest-in-file governs. No
single-writer assumption is needed **across independently committed branches** — nothing is ever
edited, so a merge has nothing to overwrite, which is the one concurrency property this design
gets for free by having no amend path at all. It says nothing about two writers in **one
worktree**: inserting an entry above `Columns:` is a read-modify-write on one file, so
simultaneous writers there can lose an entry before git's merge driver is ever involved. That
case is unsupported, not solved (§8). What remains is ordering: position after a union merge need not match either
branch's intent, so the governing entry may not be the one either author expected. §8 records
that, and its repair is the ordinary one — append another entry.

**A locator matching nothing is inert, and the match set is bounded backwards in time.** Match
semantics says an entry applies to what it matches; two cases it did not cover are matching
*nothing* — a mistyped fingerprint, a row that never existed — and matching something that did
not exist yet. Both are settled together.

*Inert.* Making a zero-match entry an error would need a repair, and the only repair under
immutability is an edit — the amendable class again. So it is inert: it governs nothing, and the
remedy is the move every other correction uses, append.

*Bounded backwards.* Matching is evaluated on read, so without a bound a mistyped entry sitting in
history would **activate** the day someone appends a row carrying its locator, and silently govern
a row nobody wrote it for. The bound is the entry's own date: an entry applies only to rows dated
on or before it. No eligibility record is needed and nothing has to be stored — both dates are
already in the lines, and supersession marks the past by definition, so the bound is what the
convention meant all along rather than a guard bolted onto it.

**What the bound does not close.** Row dates are days, not instants, so a row appended *the same
day* as the entry, after it, still satisfies "on or before" and does come under that entry.
Backdating is forbidden — by instruction only, since nothing checks it — so that day is the whole
exposure: activation is bounded to the entry's own date rather than made impossible. Closing it would need a finer
timestamp in the row format, which §2.2 rejects as wire format. The residual is one day wide,
requires the same date *and* the same fingerprint, and is the only way an entry's match set can
grow after it is written.

**Cite, do not restate.** An entry says *which claim does not hold* and *where the answer now
lives*. It does not carry the new answer, because a copy of a mechanism is exactly the artifact
that goes stale next — which is how the row being superseded here got into this state.

**Both covered causes get accurate wording.** The scope covers a claim falsified later *and* a
claim that was never true, so the entry field is "what is false", and the entry says which of
the two it is. An instruction to name "what stopped being true" would have no accurate value
for the never-true case, and an author would either omit the field or misdescribe it.

**Format.** No **standing consumer** parses an entry — that is the decision, and stating it that
way matters, because §6's one-time checks do parse one. The line has a shape: the ` · ` separator,
the optional quoted fragment, two non-empty fields, a calendar-valid date. §6 relies on exactly
that shape, and forbidding ` · ` inside a field is a constraint the shared prose ships. What is
refused is a field a **tool reads on an ongoing basis**, because that is what would become wire
format every scaffolded ledger had to keep honouring; a **validation-only grammar** binds this
change's checks and nothing after them. An entry no tool ever reads is still a line with a format,
and pretending otherwise would misdescribe what §6 does. The reader that would consume an entry on
an ongoing basis does not exist yet and is being redesigned elsewhere (§5); designing its input
format now, before it exists, is what this refuses.

## 3. The two cases the convention must resolve

### 3.1 The 2026-07-20 row — the first entry

```
- 2026-08-05 · supersedes 2026-07-20 `truncated-tool-output-read-as-complete` · its `ref` states that an incomplete pass still increments the counter, including a failed review returning `{success: false}`; true when written, and it no longer holds for every pass · CLAUDE.md §5, the paragraph opening `` **What this does not do.** The hook counts on `PostToolUse` ``
```

The entry is a **row marker**: it marks the 2026-07-20 row, and its text names the claim that no
longer holds, says it *was* true when written rather than never true, and cites where the answer
now lives — without implying the rest of the row is stale. Being a marker rather than a
clause-scoped record is what makes latest-wins safe: should this row later be found wrong in a
second way, the next entry must describe the row's supersession state as a whole, because it
becomes the one that governs. Two properties are deliberate. It **does not
restate** 0.8.0's counting rules, per §2.2's cite-don't-restate clause. And its citation quotes
the source markdown **including the emphasis markers**, because `CLAUDE.md` §5 contains **two**
paragraphs titled "What this does not do" — the section reference alone does not resolve, and a
fragment stripped of its `**` is not byte-findable in the file it points at. (The two are
distinguishable on their punctuation alone, `do.` against `do:` at `CLAUDE.md:168` and `:390`,
but only once the fragment is quoted as source bytes rather than as rendered text.)

The citation is delimited with **double** backticks and one space inside each delimiter,
because the fragment itself contains a `` `PostToolUse` `` span. A single-backtick span cannot
carry backticks, and a backslash does not escape them — markdown has no escape inside a code
span, so the backslashes an earlier draft used would have been copied into the ledger as
literal bytes that are not in `CLAUDE.md`, breaking the byte-findability the emphasis markers
were added to secure.

The entry carries **no** `"<row fragment>"` because it is meant to apply to **every** row the pair
matches — which is what omitting the fragment says under match semantics. That the pair happens to
match exactly one row today is an observation, not the reason: another row carrying the same date
and fingerprint would join the set, and that is intended rather than a defect. Since rows carry
their append date and backdating is forbidden (§2.2), "another row" means one appended **the same
day** — a row appended later carries a later date and falls outside the entry's bound. The two
`2026-07-18` + `docs-drift` rows are where an entry meaning only one of them would carry a
fragment.

The `mcp-codex-dev@1.0.1` pin the same row cites is still what `.mcp.json` carries, and the
entry says nothing about it.

### 3.2 Row D — a precedent the convention supersedes

The 2026-08-04 `mechanical-check-skipped-before-review` row was amended in place while PR #22 was
still open, and #22's Gate B accepted that. Earlier drafts of this design read that as a rule to
generalise, and built a boundary to make it correct — the boundary §2.1 has now deleted.

Under this convention it is simply **not** correct: the row is a row, and the correct move was an
entry. The precedent is superseded rather than promoted. No exception is carved for it, and none
is needed — the ledger is not retro-corrected, so what this costs is one entry that was never
written, once, in the whole history. That is the price of having no amendable class, and it is
the entire price.

## 4. Change surface

| File | Change |
|---|---|
| `docs/hardening-log.md` | §2.1 and §2.2 prose appended after the existing first paragraph — which is **not** edited — then the `Superseded rows:` block holding §3.1's entry |
| `plugins/dev-workflow/commands/workflow-init.md` | §2.1 and §2.2 prose, into the inline ledger-header template — no block, since a scaffolded ledger has no entries |
| `plugins/dev-workflow/.claude-plugin/plugin.json` | `0.8.1` → `0.8.2` |
| `plugins/dev-workflow/CHANGELOG.md` | one entry for `0.8.2` |
| `todos.md` | the source row **The hardening ledger has no supersession convention** marked done and rewritten in the past tense, so it no longer reads as an open gap; **plus** a new parked row for the uncovered case — a hardening later *removed* — carrying its trigger, the first rung actually removed. **plus** a third row covering **both** unwired properties: §6's check-1d entry validation *and* the chronology check 1e, which §8 records as never implemented — wire both into `AGENTS.md`'s quality battery, triggered by the first inert entry found after this change lands — **with the rider that any standing check must be diff-scoped *and* must pass on §2.2's sanctioned repair**, for the reason §6 gives: a whole-block scan is unsatisfiable once an immutable inert entry exists, and a check demanding that no appended entry be inert fails on the very move the convention prescribes for a mistyped locator. A named read confirms all three: no present-tense claim that the ledger lacks a convention, and both parked rows present with their triggers |
| `docs/coding-workflow.md` | line 204's append-only sentence rewritten to state the rule **absolutely** — "strictly append-only: a **row** is never edited" — with the supersession move appended. It previously said "history is never rewritten"; an intermediate draft of this spec qualified it to *merged* history, which would have reinstated a pre-merge amendable class. No merged/unmerged qualifier appears in the landed wording. Found by the standing falsification lens, outside every path this change otherwise touches |
| `docs/superpowers/stories/2026-08-04-harden-finding-guard-scope-precheck-story.md` | its inherited open question widened from wrong-fingerprint to include phantom-hardening rows (that story's §5 Open questions) |
| `docs/superpowers/plans/2026-08-04-hardening-round-0-8-0-and-pr-21.md` | a header note marking it a historical snapshot — it carries the un-narrowed rule three times. Executed plans are records of what was done and are **not** rewritten to match later rules; the note is how the falsification sweep resolves them |
| `docs/superpowers/stories/2026-08-04-hardening-ledger-supersession-story.md` | **eight** amendments, one per prompting pass, each with explicit old-condition accounting; the disposition labels differ per amendment, which is expected. **Pass 1** — AC 4 (kept/moved/dropped). **Pass 3** — the append-only rule narrowed (kept/narrowed/dropped). **Pass 4** — §4's invariants 11 and 12 made unconditional and §5's open question resolved to both surfaces, with §6's size following. **Pass 5** — the desired outcome brought into line with AC 4, which still promised a reader could tell whether *any* row describes current behaviour. **Pass 7** — the absolute rule **restored** (restored/dropped/kept), reversing pass 3. **Pass 9** — AC 2 reworded, because "the row no longer reads as current behaviour" was satisfiable only by the edit the same criterion forbids. **Pass 18** — AC 4 narrowed a second time, to the corrections actually *recorded*, with the removed-hardening exclusion named; pass 5 had brought the desired outcome to that wording and left AC 4 behind, so this closes the pair. **Pass 19** — AC 4 again, naming the inseparable-sibling case, where a correction present against a sibling would otherwise read as belonging to an accurate row; §2 was moved to point at AC 4 rather than keep its own copy of the limits, which is pass 5's lesson applied. Attribution names the pass whose findings prompted each change. §1 is also in the past tense, which is framing rather than an amendment |

**Parity, with sentinels a check can locate.** The shared region runs from the line
`# Hardening log` **inclusive** to the line ending `and nothing checks the difference.`
**inclusive** — the last sentence of §2.2's prose. Both sentinels are quoted here as **literal
text**: a check greps for exactly those bytes, so neither code span may carry an editorial
ellipsis or any other stand-in. The region **includes** the four-space
indented format example, now a single line, and **excludes** the `Superseded rows:` block, the
`Columns:` paragraph and the table.
Inside that region the two files are **byte-identical, hard wraps included** — the text is
generated once and inserted into both, so the line breaks fall in the same places, and §6's check
2b compares the two regions raw. "Identical modulo wrap position" would be the weaker claim, and
weaker than what is checked: a rewrap of one surface alone fails 2b. Both sentinels are
unique in both files once the change lands; before it, the end sentinel exists in neither, which
§6's check 2 treats as a failure rather than as an empty region — and, since check 2 now asserts
presence per surface before parity, one that its anchor greps fail on first.

**Invariant 9 needs nothing.** An existing scaffolded project re-running `/workflow-init` meets
the header as "present and different", which already routes to show-the-diff-and-ask.

**Version bump.** `0.8.2`, patch: the change adds a convention to a scaffolded template.
No component is added, removed, or renamed. `harden-finding` is untouched (§2.1 narrows nothing,
so its `never edit an existing row` sentence stays true), which is why the plugin change is
confined to `workflow-init.md` — invariant 12 still binds, since that path is under `plugins/`.

## 5. What this design hands to another story

`docs/superpowers/stories/2026-08-04-harden-finding-guard-scope-precheck-story.md` owns the
redesign of how a recurrence decision reads the ledger. §2.2 leaves a correction with **no
standing machine consumer** — the syntax is a standing convention every future author must
honour, and §6 adds only a validation-only parser making no ongoing compatibility promise —
including a note that a row's fingerprint is wrong, and, since the
scope covers a claim that was never true, a note that the row's **hardening itself** never
existed or was misclassified. §2.1 keeps such a row counting on purpose, so a lineage can
escalate from a rung that was never landed. Both are one family — a row whose mechanical
identity is corrected only in prose — and that story's inherited open question was widened to
carry both. Whether the redesigned reader should consult the `Superseded rows` block, and
whether a prose-corrected class or a prose-retracted hardening changes the lineage it escalates
from, is recorded there. It arrives as a handoff, not as a failure: no instance has occurred.

## 6. Validation

**Mode:** whatever the story header carries, **read fresh at execution**. No value is copied here
— the opening of this document says none is, and a copied mode goes stale the moment a confirmed
profile change moves it. The story is `docs/superpowers/stories/2026-08-04-hardening-ledger-supersession-story.md`.

**Battery:** the full command in `AGENTS.md` § Commands.

**This section states properties, not commands.** Each *implemented* check below gives what must be
true, a falsifying observation, and the **oracle** — what a correct implementation must be able to
distinguish.

**The falsifying observations are of two kinds, and conflating them overstates what a green run
means.** `1a`, `1d`, `2a`, `2b` and `3` **fail on the untouched base**, so their green is evidence
this change did something. `1b` and `1c` are **protective**: they hold on the untouched base by
construction and fail only under a mutation that damages what they guard, so their green is
evidence nothing was broken, never evidence anything was done — a plan that read them as
counterfactuals would call a broken check satisfied. `1e` is **not implemented** and passes before
and after, contributing no observation at all; and `1f` is a named read rather than an executable
label, with nothing to confirm before the entry exists. The plan carries the same split as a table,
per label. The executable form is written at execution time, carried in the plan with
one label per check, and **supplied to the Gate-B reviewer alongside the real diff**, where a check
has something to be checked against. It is not committed, so it is not itself inside the reviewed
range — §8 records what that leaves uncovered. Earlier drafts carried the shell here; over six Gate-A passes that shell
produced the large majority of findings while §1–§3 and §5 drew none, and a spec is the wrong place
to review an implementation that has no diff to run against.

**The entry date is `$D`, the day the ledger change is actually made.** §2.2 defines an entry's
`<date>` as the day it is written, so no literal is pinned here. §3.1 shows `2026-08-05` because
that is when it was drafted; the implementer substitutes `$D` in the entry and in every dated
check. Only the *entry's* date is `$D` — the superseded row's date is `2026-07-20`, fixed, being a
property of the row.

**Every check reads an explicit base ref.** No check may default it to `HEAD`: once the change is
committed, an edited row or paragraph would become its own baseline and the check would pass on
the mutation it exists to catch.

### Check 1 — the correction is reachable from the ledger alone

**Six** properties, 1a through 1f. **Five of them must hold for this change** — 1a–1d and 1f, the
named read included. **1e is specified here but deliberately not implemented**, for the reason §8
records: it validates the ledger's *pre-existing* chronology rather than anything this change does,
so it passes before and after and would report a green that means nothing about the diff. It is
written out because a standing successor will need it, not because this change runs it — and no
chronology validation exists in the meantime.

**1a — the entry exists and names the right row.** The `Superseded rows` block carries an entry
dated `$D` superseding `2026-07-20` with fingerprint `truncated-tool-output-read-as-complete`, and
the table carries a row with that date and fingerprint.
*Falsifying observation:* before the change the entry is absent, and the header offers no
sanctioned move for either case in §3.
*Oracles:* the count of each must be **asserted, not printed** — a block that reports `0` and exits
0 reports its own falsifying observation as success. And the row must be matched **as a complete
row**, not by a date-and-fingerprint prefix: a truncated `| <date> | <fingerprint> |` line satisfies
a prefix test, so this property's own cardinality result would read as satisfied while 1d fails,
which misleads whoever is diagnosing which guarantee broke.

**1b — the superseded row is untouched, byte for byte.** Supersession corrects a row without
editing it, so the row's whole line must be identical to the same line at the base ref.
*Falsifying observation:* mutate any character of that row and this must fail.
*Oracle:* a full-line comparison against the line **taken from the base**, not against a literal
copied into the spec — a literal drifts from the row it protects. This is story AC 2's every-byte
requirement, mechanised.

**1c — the pre-existing first header paragraph is untouched, in both surfaces.** §4 says that
paragraph is not edited and that both surfaces carry it identically; both halves must be checked.
*Falsifying observation:* change one word of it in either surface and this must fail. Verified
today: both surfaces already carry it byte-identically.
*Oracles:*
- **Four inputs, not three.** Each current surface is compared against **its own** base version,
  and current parity between the two surfaces is asserted separately. Three inputs — one base
  paragraph as the reference for both — establishes "untouched" only by leaning on the separately
  stated fact that the two surfaces are byte-identical *today*: were the base template to carry any
  variation, editing it to match the ledger's bytes would pass a three-input comparison while that
  template's paragraph had in fact changed from its own base.
- **Guarded, and bounded before comparing.** The delimiters bounding the paragraph must be asserted
  **present and unique in every input before any comparison is taken** — a checksum-style
  comparison returns a value for empty input, so a guard on the checksum alone can never fire and
  two unreadable inputs compare equal.

**1d — the change's entry is not inert.** The entry §3.1 mandates, added by the change under
review, matches at least one table row dated on or before its own date — its fragment applied if
it carries one. Matching two rows is fine; the bound is *at least one*, never *exactly one*.

**One entry, and no claim about any other.** The property is deliberately about *the* mandated
entry rather than about every entry the change adds, because the quantified version is one §2.2
forbids satisfying. A mistyped locator is a complete entry the moment it exists, entries are never
removed, and §2.2's sanctioned repair is to append a corrected one and leave the inert line
standing — so any property of the form "no added entry is inert" fails on the convention's own
prescribed move. Nor can a check ask whether the corrected entry *repairs* the mistyped one: that
asks which row the author meant, which the ledger does not encode, and the identity that would
encode it is the wire format §2.2 refuses. The same reasoning puts pre-existing entries out of
scope: a whole-block scan is unsatisfiable the first time the typo case fires. What this leaves
uncovered is recorded in §8.

**Old-condition accounting for the narrowing.** The broader property carried three requirements.
*Dropped and recorded:* that no added entry is inert — unsatisfiable against §2.2's own repair
(§8). *Dropped and recorded:* that an inert added entry be followed by a non-inert one — the
repair relation is authorial intent the ledger does not encode (§8). *Dropped, and it is the one
that was not obvious:* the alignment rule requiring the base entry sequence to remain an **exact
prefix** also asserted that pre-existing entries were preserved, in order, unedited. Nothing checks
that now. It is dropped because this base carries no entries at all, so there is nothing to
preserve — but the guarantee does not return on its own for any later change, and no check
validates pre-existing entry immutability (§8).
*Falsifying observation:* mistype the mandated entry's fingerprint and this must fail; so must an
entry dated before the row it names. The typo-then-correct pair must **pass** — the mandated entry
is the corrected one, and that is the convention working, not a defect.
*Oracles* — **seven** things a correct implementation must distinguish, each of which a draft got wrong:
- **Which entry is in scope.** **The** entry §3.1 mandates, and no other — identified in current
  content by its own date, row date and fingerprint, and only *then* proven absent at the base ref.
  **The two steps are ordered.** Selecting whatever is new and treating that as the mandated entry
  inverts them, and lets an unrelated or mistyped earlier entry decide the verdict. Every other
  added entry is ignored, a second inert one included: quantifying over all of them is the
  unsatisfiable property the narrowing removed, since §2.2's sanctioned repair for a mistyped
  locator leaves an inert entry standing forever. For this change the base carries no block at all,
  so every entry present is one it added — which makes the two steps indistinguishable *here* and
  is exactly why the order has to be stated rather than inferred from this case.
- **An entry from a line that is not one.** Candidates are the **non-blank** lines of the interval
  from the `**Superseded rows:**` label to the `Columns:` paragraph, both exclusive. The single
  structural blank line separating the list from that paragraph is required by CommonMark — without
  it `Columns:` renders inside the list item — so blank lines are not candidates; every non-blank
  one is. A candidate is an entry when it carries the entry shape: the `- ` marker, a `YYYY-MM-DD`
  date, the literal `· supersedes `, a row date, a backticked fingerprint, an **optional** quoted
  fragment, and two remaining ` · `-separated prose fields, **both non-empty** and neither
  containing ` · ` — which §2.2 forbids precisely so the split is unambiguous. Both dates must be
  **calendar-valid**, not merely `YYYY-MM-DD`-shaped: `2026-02-30` parses lexically, orders
  lexically, and is not a day anything was appended on. A candidate that
  does not parse must **fail the check**, never be dropped from the candidate set — dropping it
  reports "every entry recognised is fine" while establishing nothing about the one that matters.
  This is the read-failure-from-a-clean-pass mistake on the entry half of the match, which the
  row-side oracles below never cover. The non-empty requirement is what stops a locator-valid line
  carrying no claim and no citation from counting as an entry at all — §2.2 obliges both fields,
  and a line satisfying only the locator is malformed rather than merely uninformative.
- **Matching, to the extent the mandated entry uses it.** The mandated entry is fragmentless, and
  the property treats one match and many alike, so two distinctions are load-bearing and the rest
  are not. **Zero from at-least-one:** zero is inert and must fail, one or many must pass — a
  checker demanding *exactly one* implements the guarantee §2.2 withdrew and would still pass this
  change, which is why the many case needs a fixture even though this entry does not produce it.
  **The on-or-before bound, at the boundary:** rows dated before, **on**, and after the entry's
  date. Fixtures: a ledger carrying **two** complete rows that the *mandated* locator matches —
  both dated `2026-07-20` with `truncated-tool-output-read-as-complete` — plus the three date
  positions. The real `2026-07-18` + `docs-drift` pair cannot serve here despite being the
  ledger's one genuinely non-unique pair: the mandated entry's locator does not match it, so a
  many-match fixture has to be constructed on the locator the entry actually carries.

  *Not validated by this change, deliberately.* Fragment-narrowed matching and the comparison
  domain §2.2 pins — literal, case-sensitive, against the raw `finding` as written, escapes and
  markup included — are convention semantics no entry here exercises. Requiring fixtures for them
  would drive a general matcher this change has no use for. §8 records that nothing validates them;
  the first entry that carries a fragment is what needs them.
- **A row from a non-row.** A candidate must be a complete seven-column row: **exactly** the
  expected number of unescaped delimiters, terminal delimiter included. Rejecting only short lines
  lets a longer malformed line supply a `finding`; rejecting neither lets a truncated
  `| <date> | <fingerprint> |` satisfy the gate.
- **A delimiter from an escaped pipe.** A pipe delimits a column only when the run of backslashes
  immediately before it is **even**. Testing for a single preceding backslash makes a `finding`
  ending in a literal `\\` swallow the next column. Fixtures must include a `finding` containing
  both `\|` and the digits `001` — the strings that broke two earlier extractions, and that earlier
  fixtures happened not to contain.
- **Parse failure from an empty field.** "This line is not a row" and "this row's `finding` is
  empty" must be separable results. Conflated, a fragmentless entry — which locates rows by date
  and fingerprint alone — is falsely reported inert because some unrelated row has an empty
  `finding`.
- **A read failure from a clean pass.** Every input must be guarded, current ledger as well as
  base. An unreadable working-tree ledger must fail, never yield an empty candidate set and exit 0
  having examined nothing.

**1e — recorded dates never decrease down the table.** Backdating a row would let it fall under an
entry written before it, which §2.2 forbids. **Not implemented — the whole of 1e is a specification
for a future standing check, and nothing below describes anything that runs today.**
*Falsifying observation:* a row dated earlier than the row above it would have to fail.
*Oracle, for whoever implements it:* it would check **recorded order, not append-day truth**. A row
appended today and labelled with a date after the current tail would pass. Nothing can verify the
append day; the prohibition is instruction-backed, and such a check would be a floor under it —
a floor that does not exist today. Dates must be **calendar-valid**, not merely
well-shaped — `2026-02-30` sorts correctly and is not a date — since a lexical-only comparison
would let an impossible value satisfy both this property and 1d's on-or-before bound. The
extraction must also distinguish "no dated rows found" from "ledger unreadable".

**1f — a named read.** A reader confirms **four** things about the entry, one per requirement §2.2
puts on entry text: that it names the claim that does not hold; that it says **which cause**
applies — the claim stopped holding, or was never true; that it **cites without restating**,
pointing at where the current answer lives rather than copying that answer into the marker; and
that its citation resolves to exactly one paragraph in `CLAUDE.md`. The middle two are why this
read is not optional: an entry that names no cause, or that restates the mechanism and so becomes
the next stale narration, satisfies every mechanical property above.
This half is a read, **not** a parse:
nothing validates it, and every mechanical property above would pass an entry whose prose said
nothing useful. Stated rather than implied, because the mechanical half is what a green
`battery+check` would otherwise rest on.

### Check 2 — the convention actually reached both surfaces

The parity claim in §4 is what the both-surfaces decision rests on, and check 1 would pass with the
template untouched.

**2a — presence, per surface, independently.** Each of the thirty-five anchors below must occur
**exactly once** in each of `docs/hardening-log.md` and
`plugins/dev-workflow/commands/workflow-init.md`.

**2b — parity.** §4's two sentinels must each occur exactly once per surface — a missing or
repeated sentinel is a failure, never an empty region — and the delimited regions must compare
equal.

**Presence first, then parity, and both must hold.** Comparing the two regions only to each other
establishes that they agree, not that either says anything: two identically truncated regions end
at the sentinel and compare equal, so parity alone reports green on a change that reached neither
surface, under a heading claiming it reached both.

*Falsifying observation:* before the change every anchor is absent and the end sentinel exists in
neither file, so 2a fails first.

*Oracles:*
- **Wrap-insensitive presence, byte-exact parity.** Both surfaces are hard-wrapped, and most
  anchors straddle a line break *within* a surface, so **presence** must be tested against a
  paragraph-joined view or a multi-word anchor is missed on a technicality. **Parity is the
  opposite**: the two regions are compared raw, byte for byte, line breaks included — they are
  generated once and inserted into both, so they do not wrap differently, and joining them before
  comparing would let a rewrap of one surface alone pass. The wrap-insensitivity belongs to 2a and
  must not leak into 2b. Parity must compare leading indentation and blank-line
  structure **exactly**: the four-space prefix is the only thing distinguishing the format example
  from a live entry, and a normalisation that flattened it would let one surface turn the example
  into entry-shaped content and still report equal. The join must therefore leave indented blocks
  alone.
- **Occurrences, not matching lines.** After a paragraph join, two copies of an anchor in one
  paragraph are on one line; a line-counting test reports `1` and the exactly-once claim measures
  nothing.
- **Anchors are data, not code.** One begins with `-` and five contain backticks; whatever runs them
  must pass them as literal patterns and must not let a shell interpret them. An unescaped backtick
  silently degraded an anchor to a prefix and still exited 0.

**Four states, each distinguished:** *pre-change* — every anchor absent, end sentinel in neither:
2a fails. *One surface edited* — anchors resolve in one file, not the other: 2a fails. *Both edited
but incompletely*, an **anchored** clause dropped from both: 2a fails, which is the state parity
alone could not see. *Both edited fully*: passes. Dropping an **unanchored** decision from both is
**not** distinguished by either property; §8 lists the ones known today and does not claim that
list is complete.

#### The anchors

Each is the distinguishing text of one decision §2 settles.

1. `records a hardening claim as of its date`
2. `falsified by a later change, or wrong when it was written`
3. ``append a `Superseded rows` entry rather than editing it``
4. `This holds for every row without exception`
5. ``the existing `Never edit a row` rule is absolute``
6. `The rule is bound to rows, not to commits`
7. `is below the rule's resolution, and nothing checks one`
8. ``Resolving a `pending` row also appends``
9. `never alters mechanical behaviour`
10. `including when the entry records that the row's hardening claim was itself false`
11. `the row keeps its fingerprint, keeps matching the column-2 grep, and keeps counting`
12. `A hardening later removed is out of scope`
13. `**Correcting a row.**`
14. `present only once at least one entry exists`
15. `` block above the `Columns:` ``
16. `one appended line per supersession`
17. `- <date> · supersedes <row date>`
18. `` `<date>` is the day the entry is written, in `YYYY-MM-DD` ``
19. `A row is located by date + fingerprint`
20. `An entry applies to every row its locator matches`
21. `applies only to matching rows dated on or before the entry's own date`
22. `A row's date is the day it is appended`
23. `the table is chronological: backdating a row is forbidden`
24. `matches no such row is **inert**`
25. `append a new entry with a locator that matches`
26. `Name the claim that does not hold`
27. `cite where the current answer lives`
28. `saying whether it stopped holding or was never true`
29. `restating that answer here only makes the entry the next stale narration`
30. `the last entry for a row is the one that governs`
31. `must therefore describe the row as it now stands`
32. `Entries are never edited, never removed, and never reference one another`
33. `keep one and keep every entry under it`
34. `singles out one row only where that row has one no sibling shares`
35. `once a line exists as a complete entry it is protected`
### Check 3 — the block is where §2.2 says, and only there

Checks 1 and 2 leave most of §2.2's layout decisions unvalidated — but not all, and the difference
matters. Check 1 confines its candidates to the label-to-`Columns:` interval and treats an absent,
duplicated or reversed interval as undecidable rather than empty, so the block's existence and its
position relative to `Columns:` are already established there. What check 1 does **not** establish
is the end sentinel as the block's lower bound, the absence of entry-shaped lines *outside* the
interval, the blank-line structure around the list, or the template's freedom from a label. Check
2's region deliberately *excludes* the block, the `Columns:` paragraph and the table, so it
establishes none of those either. **Check 3 is exactly that remainder** — not a second pass over
what check 1 already did.

**Property.** In the ledger, in this order: the convention's end sentinel, then exactly one
`**Superseded rows:**` label, then the change's entry, then the `Columns:` paragraph. Every
entry-shaped line in the file lies inside the label-to-`Columns:` interval. In the template the
label does not appear at all.

*Falsifying observation:* before the change there is no label and no entry, so the ordering cannot
be established.

*Oracles:*
- **Cardinality before ordering, evaluated on this change.** Each of the label, the `Columns:`
  paragraph and the entry must resolve to exactly one position; two labels — which a union merge
  can produce — must fail rather than silently taking the first. The evaluation point matters:
  this runs once, on this change, before any merge involving it. A duplicate arriving later is
  outside it — §8 records that no standing check looks again, and §2.2's repair for a duplicated
  label keeps one label and every entry under it.
- **The full ordering, not a prefix of it.** `label < entry < Columns:` alone permits the block
  above `# Hardening log`, or a second entry below the table. The end sentinel must be pinned as
  the lower bound and every entry-shaped line checked against the interval.
- **A desired zero must not be the failing status.** The template assertion is "no label here";
  expressed as a bare search, its success is a nonzero exit.
- *What it does not do:* it validates position and cardinality, not content, and it confirms only
  that the template carries no *label* — a template wrongly carrying a live entry without one is
  caught by nothing (§8).

**Prompt conformance:** `docs/prompt-standards.md`, all twelve items, on
`plugins/dev-workflow/commands/workflow-init.md` — the only invariant-11 surface this change
touches, now that `harden-finding` is out of the change surface.

## 7. Gate-A riders, verbatim in every pass prompt

1. **Sweep before reading.** Mechanically settle whatever this spec asserts that a machine can
   decide without side effects — cited paths, quoted passages **byte-for-byte including markdown
   emphasis markers**, stated counts, the non-uniqueness claim in §2.2, §4's parity sentinels
   (unique and locatable in both files; does the region contain what §4 says and exclude what it
   says?), §6's thirty-five anchors (does each occur exactly once per surface; is any a substring
   of another?), §3.1's citation, and the syntax and balance of standalone fenced and indented
   blocks. Both source files are hard-wrapped, so compare quoted markdown with whitespace
   normalised and report a wrap artifact as a wrap artifact. Report what the sweep found separately
   from what the read found.
2. **Self-test the append-only claim and the floor — seven cases.** §2.1 removes the amendable
   class rather than defining one, so the question is not "which rows may be edited" but "does
   anything still imply that some may be". Walk: a row appended one minute ago and not committed; a
   row appended and committed on your own branch; a row on `main`; a `pending` row you now resolve;
   a row whose fingerprint you believe is wrong; row D (§3.2); and a half-typed line in your editor
   that is not yet a row. Report a verdict for each, and flag **any** place in the spec, the shared
   convention prose, the story or `harden-finding` that still offers, implies or presupposes an
   in-place edit.
3. **Match-semantics and inert-entry consequences.** Locator uniqueness was withdrawn: an entry
   applies to every row it matches dated on or before its own date, and one matching nothing is
   inert and stands as history. Walk what the withdrawn guarantee held up — §6 check 1's
   properties, §3.1's fragmentless entry, the `2026-07-18` + `docs-drift` pair, and AC 4's "where
   the current answer lives" when one entry matches two rows. Report anything still resting on a
   guarantee that no longer exists, or assuming an entry always governs something.
4. **Oracle coverage.** §6 states properties, falsifying observations and oracles; it deliberately
   carries **no executable commands** — those are written at execution time, labelled in the plan,
   and reviewed by Gate B against the real diff. Judge §6 on whether each property is *decidable*,
   whether its falsifying observation would really fail before the change, and whether its oracles
   name every distinction an implementation has to make. Report a property whose oracle is missing
   a distinction; do **not** report the absence of shell.

**On §8's list of unanchored decisions:** it is deliberately **partial** and makes no completeness
claim — that claim was deleted after being wrong at seven consecutive passes. Report a *wrong*
statement in it; do not report its incompleteness.

## 8. What this does not do

- **It adds no *standing* mechanical check.** §6's three checks run once, on this change, and
  then stop; nothing runs on a future supersession. Nothing validates that a superseded row has
  an entry, that an entry's locator matches any row at all beyond check 1's one-time assertion, or that a later entry describes
  the row's supersession state as a whole rather than only its newest fault. For every entry
  after §3.1's, a reader
  is the whole detection. Check 3 constrains where the block sits and check 2's presence property
  constrains which clauses are present — neither looks at an entry's content, and both are
  one-time.
- **A row can be corrected in prose while its mechanical identity stays wrong.** §2.1 keeps a
  superseded row counting even when the entry records that its fingerprint was wrong, or that
  the hardening it claims never existed at all. A lineage can therefore escalate from a rung
  that was never landed, and the class history the ledger reports mechanically stays wrong. This
  is deliberate, but what it preserves in these two cases is a **known misclassification, not
  accurate history**: the reason is that the alternative reopens an edit path into the table and
  that the rule must stay applicable without adjudicating whether a past hardening was real. The
  consequence is handed to the guard-scope story (§5), whose inherited open question now covers
  both cases.
- **What check 2's anchor list does not cover — a partial list, and it is not exhaustive.** The
  rule is exact: an anchor is the distinguishing text of one decision, so **a decision with no
  anchor is not detected if it is deleted identically from both surfaces**. What is *not* exact is
  any enumeration of which decisions those are. Known unanchored today: the no-double-quote
  condition on a fragment — the narrowing it qualifies now carries anchor 34 — and §2.2's calibration
  that append-day truth is unverifiable and that nothing checks the weaker non-decreasing-dates
  property either. **Others almost certainly exist and are not listed here.** The layout rationale, the
  prose-only decision and §2's reasoning generally sit outside the shared region and were never in
  scope. Nothing anchors the prose *between* anchors on either surface.

  **Why there is no completeness claim.** There was one, and it was wrong at seven consecutive
  review passes — each time naming a decision that turned out to be anchorable, or omitting one
  that was not. Stating the rule and a partial list is what is actually true; a claim of
  completeness kept regenerating the same defect, which is `prompt-standards` item 11's fourth
  correction rule reached for the seventh time. Deriving the list mechanically was considered and
  rejected: it would add a checker to protect a claim this design does not need to make.
- **Concurrent entries for one row resolve by file position, which a union merge does not fix.**
  `merge=union` keeps both sides' entries and latest-in-file governs, so after a merge the
  governing entry may not be the one either author intended. Nothing detects it. The repair is the
  ordinary one — append another entry — because nothing is ever edited. Having no amend path
  removes the lost-update case **between independently committed branches**; it does not remove
  the same-worktree one §2.2 names, where two writers doing read-modify-write on the file can lose
  an entry before git is involved at all. That case is unsupported.
- **Latest-wins loses a still-accurate earlier entry from view.** A row falsified twice in
  different clauses carries two entries and only the last governs. §2.2 asks the author of the
  second to describe the row as it now stands rather than only the new clause; nothing enforces
  that, and an author who writes a narrow second entry leaves the first one's still-true content
  below the line a reader stops at.
- **A live entry in the scaffolded template is not detected.** Check 3 tests for a
  stray `**Superseded rows:**` *label*; a template carrying an entry-shaped line without one
  passes it, and check 1's named read never opens the template. No check covers it.
- **A row with no permitted distinguishing fragment cannot be told apart from its siblings, and an
  entry marks all of them.** The locator is date + fingerprint, narrowed only by a quoted fragment
  of `finding` carrying no double quote. A row can be singled out only when it has such a fragment
  that no sibling sharing its date and fingerprint also contains; where it has none, an entry
  naming it names every one of them — its accurate siblings included. Identical `finding`s are the
  obvious case; the condition is broader and holds **per row, not per pair** — a `finding` that is
  a substring of its sibling's has no fragment the sibling lacks while the sibling still has one,
  and a row whose every unique fragment carries a double quote (`foo"` against `foo`) is barred by
  the no-double-quote rule, while two rows merely *containing* a quote (`alpha"x`, `alpha"y`)
  separate normally. If only one such row's narration were false, the convention could not
  mark it alone, which cuts against what the design is for. **No instance exists**: checked against
  the twenty-two current rows, the one repeating date-and-fingerprint pair (`2026-07-18` +
  `docs-drift`) leaves both its rows separable, and the case is hypothetical. A discriminator was
  considered and rejected — an ordinal or a second column fragment would add wire format to the one
  thing §2.2 deliberately leaves with **no standing machine consumer**, to serve a case that has
  never occurred.
  **Reopen trigger:** the first real case whose truth diverges — a row with no permitted
  distinguishing fragment against a sibling, where one narration is falsified and the other still
  holds. Until then this is a recorded limitation, not an open question.
- **The checks themselves are reviewed only as pasted context, never as files in a gate's range,
  and never fingerprinted.** Gate B does read them — this change's Gate-B cycle raised sixteen
  findings against them, which is the paste working — but it reads a paste rather than comparing a
  diff, so nothing ties what was reviewed to what was run. They are written
  at execution time and are not committed — nothing standing runs them, so committing them would
  add a file the repository carries and never executes. The consequence is that the only executable
  artifact in this change sits outside the Gate-B range: the reviewer sees the check source only
  because the plan requires it in `additionalContext`, which is a reviewer reading a paste, not a
  gate comparing a diff. Their other guards are a self-test that must be shown able to fail,
  `shellcheck`, and a counter-check per label. The evidence a `battery+check` mode rests on is
  therefore produced by unfingerprinted code, and a later reader cannot recover which version of a
  check produced a recorded result.
- **An extra inert entry appended alongside the mandated one is invisible to check 1d, and caught
  once by check 3.** Check 1d asks about **the** entry §3.1 mandates, not about every entry the
  change adds, so a second entry whose locator matches no row rides past *1d* unexamined. Check 3's
  cardinality oracle is what does see it: it requires the entry to resolve to exactly one position,
  so a second entry-shaped line fails that check — on this change, once, before any merge involving
  it, and never again afterwards. Two reasons for 1d's silence, and only the first is about
  this change. Quantifying over every added entry is unsatisfiable by construction: §2.2's
  sanctioned repair for a mistyped locator is to append a corrected entry and leave the inert one
  standing, so the property would fail on the convention's own prescribed move. And the repair
  relation itself is uncheckable in general — whether a later entry corrects an earlier one is a
  question about which row the author *meant*, which the ledger does not encode and which no
  mechanical test can recover; the identity that would encode it is the wire format §2.2 refuses.
  The state is **outside the prescribed change**, which appends exactly one entry — but a
  nonconforming implementation can produce it, and every stated check *other than* check 3's
  cardinality oracle will accept it. Calling that
  unreachable would be circular: it is unreachable only if the implementation does what it was
  told, which is the thing a check exists to stop assuming. Three further things nothing here
  validates, named rather than left to inference: **fragment-narrowed matching** and the
  **comparison domain** §2.2 pins, since no entry in this change carries a fragment; and
  **pre-existing entry immutability** — the narrowing that removed 1d's alignment rule removed with
  it the only assertion that base entries survive unedited and in order. This base carries no
  entries, so there is nothing to preserve today; the guarantee does not return by itself for a
  later change.
- **Two states absolutism makes unrepairable, and one of them a check can strand.** Nothing is
  ever edited or removed, so a mistake that reaches the file stays in it. An **inert entry** is
  the benign case: §2.2 sanctions leaving it and appending a correction, and §6 check 1d is worded
  to pass on exactly that. A **backdated row** is not: no append can restore non-decreasing dates,
  so check 1e — and any standing successor to it — would fail on that ledger from then on, with no
  sanctioned repair. The prohibition on backdating is therefore load-bearing rather than advisory,
  and it is instruction-backed only. This change appends no row, so it cannot enter that state;
  the twenty-two current rows were checked and their dates do not decrease. **Check 1e is therefore
  not implemented.** It validates the ledger's pre-existing chronology rather than anything this
  change does — it passes before and after, and its falsifying observation requires mutating the
  table by hand. Running it would report a green that means nothing about the diff. No chronology
  validation exists as a result, one-time or standing; the parked `todos.md` row that covers wiring
  a standing check covers this too.
- **A superseded row is unchanged to every tool.** The column-2 recurrence grep, any count over
  the table, and `harden-finding`'s escalation all see the row exactly as before — including one
  whose entry says its fingerprint is wrong.
- **Check 1's content half is a human read.** The greps establish that an entry exists carrying
  the expected fingerprint and that its locator matches the row it names; nothing establishes that the
  entry says anything true or useful.
- **The convention does not reach the reader that would consume it.** §5 hands that to the
  guard-scope story; until it lands, the correction is prose a human reads.
- **It does not cover a hardening that is later removed.** Named as out of scope in §2.1 and
  parked in `todos.md` with its trigger — the first rung actually removed. No instance exists.
- **`merge=union` duplicates rather than overwrites — sometimes — and nothing repairs it.** When
  two branches each create the block, union *may* leave two `**Superseded rows:**` labels; §2.2's
  wording is conditional for that reason. Check 3's cardinality property rejects a duplicate label, but once only, during this change; **no standing check** looks again, and the merge that produces one will normally happen long after. Reproduced on a scratch repo
  with the configured driver, the identical label lines **coalesced** and both distinct entries
  were kept — one label, not two. An earlier draft here asserted duplication categorically, which
  overstated what the merge mechanism guarantees in the direction that matters least: the repair
  instruction has to exist for the case where it does happen, not because it always does. The same mechanic applies to the table: union
  keeps both sides' lines, so two branches appending rows can leave duplicates. That is a
  pre-existing property of the ledger's merge driver, not something this change introduces —
  named here because an earlier draft described the failure as one writer "overwriting" another,
  which union never does.
- **The format example is not an entry. For this change two checks guard the distinction;
  beyond it, only shape does.** It is a four-space indented code block using `<date>` and
  `<row date>` placeholders, so no line-anchored grep for a dated entry reaches it. On this
  change, location guards it as well: check 1d confines its candidates to the
  label-to-`Columns:` interval, and check 3 rejects entry-shaped lines anywhere outside that
  interval. Both run once, on this change. **No standing check looks again**, so for every
  later reader shape is the whole guard — and shape is a weak one: POSIX grep has
  no code-block awareness — the limitation recorded in `docs/hardening-log.md`'s 2026-07-26
  `unverified-enforcement-claim` row, not in `scripts/check-invariants.sh` itself, which carries
  no such comment — so an example later rewritten flush-left with a real date would become
  indistinguishable from an entry to any reader built over this block.
- **Four things found at the closing review and held rather than repaired — since acted on, as
  recorded under each.** Gate A closed on pass 23 by a decision taken before it ran, so these were
  recorded here rather than repaired — the alternative was another unreviewed revision, which is
  the state the closing pass existed to end. Each was actionable by whoever wrote the plan and the
  executable checks, and Gate B is where all four were: the first and third by the checks
  themselves, the fourth by correcting the residual above, and the second by correcting both
  sites it names. None is still held. Gate B compares the
  **implementation range only**. Neither the plan nor the scratch check source is inside it — the
  plan lands earlier, as prose, under §5's exemption, and the checks are never committed at all;
  both reach the reviewer as context, which is a reader given a document rather than a gate
  comparing a diff. That is the division §6 states and the residual above records.
  - **1d's matching oracle does not name row-date equality.** It names zero-from-at-least-one and
    the on-or-before bound. A checker that compared only the fingerprint would still pass the
    mandated entry, the two-row fixture and all three date positions — and would report an entry
    non-inert whose locator matches no row, which is the property 1d exists to decide. The
    executable check must validate **exact row-date and fingerprint equality before applying the
    eligibility bound**, with a fixture whose only defect is a wrong locator row date. *Done:* the
    check compares both fields before the bound; `entry-wrong-rowdate` and
    `entry-wrong-fingerprint` are those fixtures, and each is run with its own mutated locator so
    that identification succeeds and the comparison is what rejects it. Deleting the comparison
    flips both to passing — checked, at Gate-B pass 4, because until then both fixtures were
    rejected earlier, at identification, and would have passed this item while proving nothing.
  - **Two sites carried the pre-narrowing "prose-only" claim — corrected at Gate-B pass 4, no
    longer held.** §5 said the correction is prose-only and that nothing consumes it, and this
    section's discriminator-rejected bullet said §2.2 keeps the entry deliberately prose-only.
    Both now read as below. The accurate claim, after §2.2's Format paragraph
    was narrowed, is **no standing machine consumer** — the syntax *is* a standing convention that
    every future author must honour, and what §6 adds is a validation-only parser creating no
    ongoing compatibility promise. Where those two sites and §2.2 disagree, §2.2 governs.
  - **1d's scope oracle read as plural — the check was corrected at Gate-B pass 3, the oracle's own
    wording only at pass 6.** "The mandated entry, and only entries this change adds" can be read as
    quantifying over every added entry, which is the unsatisfiable property the narrowing removed.
    The intended selection: identify the §3.1-mandated entry in current content, prove it was added
    relative to the base, and **ignore every other added entry**. *Done, twice over:* the check
    selects by entry date, row date and fingerprint, requires exactly one such candidate, and only
    then asserts it is absent at the base — the two steps in that order; and §6's oracle now states
    that order rather than the plural. Recorded as two steps because the first fix left the second
    undone for three passes, with this item marked done in between.
  - **The format-example guard was understated as "shape alone" — corrected at Gate-B pass 3,
    no longer held.** For this change, 1d confines candidates to the label-to-`Columns:` interval
    and check 3 rejects entry-shaped lines outside it, so location guards it too — once. The
    claim was right about **standing** enforcement and wrong about this change's validation; the
    residual bullet above now says both. The future risk it names is unchanged: a reader or check
    that scans dated lines without respecting the interval.
- **It changes nothing about how the gate hook counts.** §3.1 records that 0.8.0 already
  changed it; this design only marks the row that still describes the old behaviour.
