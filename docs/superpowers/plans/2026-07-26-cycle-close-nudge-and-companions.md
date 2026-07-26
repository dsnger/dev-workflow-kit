# Plan — PR 2: companion files, the deferred template sync, and the release

Layer 2 of the canvas field-findings round. PR 1 (merged, #13) took finding D — the two
mechanical checks. This PR takes **C** (optional companion files), the deferred downstream-neutral template
sync, **one** taxonomy class, **one** ledger row, **five** `todos.md` edits, the
`pr-review-bots.md` caveat, and the **0.5.1 → 0.6.0** release. **Finding A was cut after five Gate-A passes** (see below) and
becomes a story alongside B. **It edits `plugins/**`, so invariant 12 requires a version bump:
0.5.1 → 0.6.0.**

Finding B (a §5 version stamp) stays split out; this PR only records its story.

Each task is **Scope → Rule → Files → Verify.**

---

## Constraints PR 1 now imposes on this PR

Checks 4a and 4b are live on main and scan `plugins/dev-workflow/commands/workflow-init.md`,
which this PR edits. Measured before starting:

| | now | must stay |
|---|---|---|
| column-zero `Target model:` lines in `workflow-init.md` | 1 | exactly 1 |
| template checklist items | 12 | equal to the repo copy (12) |
| count claims in that file | 0 | any added must equal 12 |

The §5 template lives inside a fenced block in that file. A `Target model:` line added at
**column zero** inside that fence counts toward 4a's cardinality — the check has no fence
awareness, by documented design. So template text must not introduce one.

---

## Finding A — CUT from this PR, now a designed story

**A drew a Major on all five Gate-A passes and is removed rather than narrowed again.**
The final version said: note every accepted actionable finding fixed this cycle, close the
cycle, then run `harden-finding` once per finding, and it claimed that scope matched
`process-pr-review` step 5 exactly. It does not. Step 5 **checks** every accepted
actionable finding against the ledger but **invokes** the skill only "if one matches an
existing class, or a new class is clearly warranted" — so the reminder would have
instructed agents to harden one-offs the settled PR path deliberately declines, while
asserting parity it did not have.

That was the fifth consecutive pass concentrating fire on one paragraph, and the
accumulated findings say the same thing from five directions: a reminder that depends on
volatile same-session memory, covering a scope it keeps mis-stating, is not a solution to
"the only mandated ledger check lives on a path some projects never walk". A is a design —
identity, dedup, consumption semantics, and a scope rule that matches step 5 rather than
approximating it — and it joins B as a story (Task 5).

**This PR therefore ships the full remaining scope:** C, the downstream-neutral template
sync, one taxonomy class, one ledger row, five `todos.md` edits, the `pr-review-bots.md`
caveat, and the 0.6.0 release. Nothing here depends on A — the companions are
independently useful, and the sync and bump were always separate obligations.

---

## Task 1 — C: recommended companion files

**Scope.** The field evolved per-pass companions the §5 protocol does not know about, so
dispositions and resume context live only in chat history. Canvas: 7 `*-dispositions.md`,
3 `*-decisions.md`, 1 Gate-A resume note.

**Rule.** Extend the §5 file protocol with **optional** companions:
- `<slot>-dispositions.md` — one line per finding: verdict + reason.
- a resume note — **cycle-stable**, not pass-slot-named. A note bound to the interrupted
  pass number is exactly the file a resuming agent does not know to look for once the
  counter moves or an incomplete pass is discounted, which would reproduce finding C.
  **One name per independent cycle:** `gate-a-spec-resume.md`, `gate-a-plan-resume.md`,
  `gate-b-resume.md`. Gate A genuinely runs separate spec and plan loops, so those are two
  cycles. Gate B is **one** cycle and gets **one** note, even though `full` runs two
  reviewer branches: the findings files need one path per branch because *Codex's two
  reviewers* write them concurrently, but the resume note is written by the outer agent,
  sequentially. Splitting it per branch would create two records able to disagree about a
  single shared recovery budget and a validation rule that already spans both files.
- **Lifecycle, kept as light as the rest of C.** Whoever runs the cycle writes it when
  useful, replaces it as the cycle moves, and deletes it once the cycle closes. No
  mandated fields, no write-ahead requirement, and nothing depends on it existing.

**These stay OPTIONAL, and nothing in this PR depends on them.** They are advisory human
notes: no step requires one to exist, none participates in pass validation, and a cycle
that never writes one behaves exactly as it does today. An earlier draft made a resume
note load-bearing while still calling it optional; that dependency is gone along with the
feature that created it.

The text must state they are advisory human notes, are **never** the findings file,
**never** participate in pass validation, and may be deleted or rebuilt. The findings file
plus terminator stay the only hard requirement. A zero-finding pass needs no companion.

**Credit placement.** The field-practice credit (infinite-portfolio-canvas) goes in this
repo's `CLAUDE.md` and the CHANGELOG, **not** into the scaffolded template: downstream
readers do not need this repo's provenance to follow the rule, and inline template tokens
are governed by prompt-standards item 8.

**Files.** This repo's `CLAUDE.md` §5; the §5 template in `workflow-init.md`;
`plugins/dev-workflow/CHANGELOG.md` (the credit lives there, so the task that settles the
credit owns the file — otherwise an implementer satisfies every per-task Files list and
still drops it).

**Verify.** No sentence can be read as adding a validation requirement; the scaffolded
template contains no `infinite-portfolio-canvas` reference; the CHANGELOG entry does.

---

## Task 2 — The deferred template sync, downstream-neutral

**Scope.** PR #12 deferred adding the "ad-hoc task briefs are prompts too" paragraph to
the scaffolded template. This round is its named vehicle.

**Rule — NOT verbatim.** Gate B on PR 1 established the repo paragraph is not portable: it
links `docs/sparring-briefing.md`, which `/workflow-init` does not scaffold, and asserts
"two field incidents" in this repo's voice. Copying it verbatim would ship a broken link
and a foreign claim into every initialized project. Write a **downstream-neutral variant**
with **no unscaffolded path reference and no incident count**. Verify **semantic parity**,
not byte equality.

**Both halves of the principle must survive, or the variant becomes a false process
claim.** The repo paragraph says two things: an ad-hoc brief is a prompt and should carry
this checklist's habits (success criteria, stop conditions, verified claims), **and**
nobody reviews a brief against all 12 items — which is exactly why those habits have to
live in how briefs are written. Keeping only the first half would tell every initialized
project that each brief is formally reviewed, inventing a process no one runs.

**Files.** `plugins/dev-workflow/commands/workflow-init.md`.

**Verify.** The template paragraph contains no `sparring-briefing` reference and no
incident count; `sh scripts/check-invariants.sh` still exits 0 (the constraint table above).

---

## Task 3 — Taxonomy: mint one class

**Rule.** Add ONE class to `docs/hardening-taxonomy.md` (never the skill — invariant 10),
with alias hints:
*(`mandatory-step-anchored-to-optional-path` is NOT minted here. A is cut, so nothing in
this PR hardens it; the class is minted by the story that implements A, or the ledger
gains a class no row uses.)*
- `session-bound-context-not-durable` — reasoning that must outlive a session is left in
  chat history. Gate A rejected `truncated-tool-output-read-as-complete` for C: nothing is
  truncated there, and reusing it would corrupt that class's recurrence count.

**Verify.** Before adding the class, run `harden-finding`'s own minting precondition —
grep **both** lists (the skill's base taxonomy *and* `docs/hardening-taxonomy.md`) for the
closest match, aliases included — and record the near matches compared. "It does not
duplicate an existing class" is not checkable without naming that comparison, and a
near-duplicate fingerprint silently splits a recurrence group in two.
**Re-read immediately before writing.** `harden-finding` requires a fresh read of the
ledger right before appending, and the same applies to the taxonomy: another branch or
agent can add the class or the row between the initial grep and the write, producing a
duplicate class or a duplicate first-occurrence row in an append-only file. Re-grep both
taxonomy lists before minting and re-run the anchored column-2 grep immediately before the
append; if a match appeared meanwhile, reconcile with it instead of appending.

---

## Task 4 — Ledger: one appended row

| fingerprint | source | severity | rung | ref |
|---|---|---|---|---|
| `session-bound-context-not-durable` | manual | minor | P std | the optional-companion section, both copies |

**Rule.** The row must name its actual mechanism — a paragraph of prompt text — and state
plainly that **no checker or hook enforces compliance**. The companion convention can be
skipped entirely and nothing notices, so a bare `P std` row would read as though it made
session context durable rather than merely recommending durable notes; a row claiming more
than that is `unverified-enforcement-claim`, the class this repo resolved at rung 2 in #13.
The row also notes the blind spot inherited from PR 1: checks 4a/4b do not scan
`docs/hardening-log.md`, so nothing mechanical reads it at all.

**Verify.** Anchored column-2 grep; no row edited.

---

## Task 5 — todos.md: five edits

**Entry e resolves the row this PR discharges.** `todos.md` still carries PR #12's
unchecked deferral — add the ad-hoc-brief paragraph to the scaffolded template "when
`commands/workflow-init.md` is next touched", naming this round as its vehicle. Task 2
*is* that work, so the row must be **marked resolved in the same PR**, noting that the
scaffolded text is a downstream-neutral variant rather than the verbatim paragraph the row
anticipated. Leaving it unchecked would advertise finished work as pending and keep a
now-false "upcoming vehicle" pointing at a round that already happened.

**Placement, named — otherwise two implementers place these differently and one of them
creates active work.** Entries **a**, **c** and **d** are **new unchecked, trigger-gated
rows appended under the existing `## Tooling revalidation` heading**, matching the
trigger-gated form already used there (`*Trigger: …*`). Entry **b** does **not** add a
row: it **mutates the existing P2+P6 row in place**, adding the calibration point and
marking its trigger FIRED. Nothing goes under `## Now` — none of these is active work.

**Verify.** Five edits: three appended rows, the P2+P6 row mutated, and PR #12's
template-sync row marked resolved; `## Now` unchanged; and
before appending, grep `todos.md` for each story's subject so a parked concern is not
duplicated under a second phrasing.


a. **Finding-B story** — spec questions: a semantic §5 locator (init may append the
   section renumbered); per-state merge semantics (invariant 9 forbids silent overwrite,
   and "re-run init to sync" promises what the command cannot give); stamp cardinality; and
   a binding real on **every** push path, since the version-bump coupling proposed was
   false — invariant 12's checker is `pull_request`-only. A stamp is a **wire format**, so
   shipping a provisional one creates legacy on write. Record that canvas is being
   re-synced manually right after this round, so the story carries no false schedule
   pressure.
b. **Canvas calibration point** on the P2 row: 51 Gate-A pass files across 2 stories
   (spec 14 + plan 14 + replan 4 + amend 12 + a3-spec 7), trigger **FIRED**. Edit only —
   P2+P6 and P5-light are not implemented here.
c. **`harden-finding`'s recurrence rule is scope-blind.** Rungs guard scopes; the skill
   compares only fingerprints; a ledger-prose workaround is unenforceable because agents
   follow the skill, not the row. Sketched fix — before proposing escalation on a
   same-fingerprint recurrence, read the prior row's stated guard:
   - **outside** the guard → the prior mechanism never claimed this shape, so its rung did
     not fail. Select the fitting rung independently; **do not escalate**.
   - **inside** the guard → the mechanism was supposed to catch this and did not. That is a
     regression: diagnose and repair or strengthen *that* mechanism.
   **An earlier draft of this entry had those two branches inverted** — it said an
   out-of-guard occurrence should escalate, which is precisely the over-escalation the
   2026-07-26 ledger rows warn about, so the parked "fix" would have entrenched the bug it
   was filed against. Caught at Gate A. Trigger: the first human rejection of an
   over-escalation the rows predicted, or the next round touching the skill.
d. **Finding A — a route from a fixed finding to the ledger for projects that never open
   PRs.** Cut from this PR after drawing a Major on all five Gate-A passes; the accumulated
   findings ARE its opening evidence, so the story starts from a real spec rather than a
   blank page:
   - it cannot rest on same-session memory — a compaction, interruption or handoff loses
     the fixed-finding set and **nothing detects the loss** (pass 4, M4);
   - its scope must **match `process-pr-review` step 5 exactly**: check every accepted
     actionable fixed finding, but invoke `harden-finding` only when a class matches or a
     new one is clearly warranted. Every draft that approximated this got the parity claim
     wrong (pass 4 M5, pass 5 M1);
   - a durable handoff needs real design — identity, dedup, consumption semantics — which
     is why it was refused as a mid-round addition (pass 3, M4);
   - it mints `mandatory-step-anchored-to-optional-path` when it lands; minting it earlier
     would leave a class no ledger row uses.
   *Trigger: the next round that touches §5, or a project reporting an empty ledger across
   cycles that fixed findings.*

---

## Task 6 — `docs/pr-review-bots.md`: the CodeRabbit caveat

**Rule.** Record what both #12 and #13 showed: CodeRabbit's status check can pass while
the comment reads **"Review rate limited"**, so a green check does **not** prove the final
head was reviewed.

**This is not only a table note, and calling it one would leave a contradiction in the
document.** The file currently says non-pending status *is* proof the bot finished, which
the new evidence contradicts. The edit must separate two things that were conflated and
update **all three sites together** — the table row, the **Wait for** entry, and the
completion-signal paragraph:

- **"the check stopped pending"** — still the blocking signal, so CodeRabbit stays under
  *Wait for*. That is what you may block on.
- **"the final head was reviewed"** — a *separate* verification, and it must name the
  exact object or it just replaces one false proof with another. Issue comments carry no
  reviewed commit, and an inline comment's `commit_id` proves a comment, not a completed
  review. Use the **pull-request review** record, which does expose `commit_id`:
  ```sh
  head=$(gh pr view <n> --json headRefOid --jq .headRefOid)   # the LIVE head, not local HEAD
  gh api --paginate repos/<owner>/<repo>/pulls/<n>/reviews | jq -s "
    [ .[][]
      | select(.user.login==\"coderabbitai[bot]\")
      | select(.commit_id==\"$head\")
      | select((.body // \"\") | test(\"rate limit\"; \"i\") | not)
      | select(.state==\"COMMENTED\" or .state==\"APPROVED\" or .state==\"CHANGES_REQUESTED\")
    ] | length" | grep -qv '^0$'
  ```
  **The pagination is in the command above, not a note beside it.** Without `--paginate`
  the query reads only the first page, so on a long-lived PR the qualifying final-head
  review can sit on page two and be read as absent — sending a correctly-reviewed head
  down the retrigger/human-override path.

  **`gh api --slurp` cannot be used with `--jq`** — it is rejected outright ("the
  `--slurp` option is not supported with `--jq` or `--template`"), so an earlier draft's
  command failed with a usage error instead of returning a boolean. Pipe the paginated raw
  pages to `jq -s` instead; `--paginate` emits one array per page and `-s` wraps them,
  which is why the filter iterates `.[][]`. **Verified against #13:** `0` for the merged
  head `92de0d2`, `1` for `eed589c`, the commit actually reviewed. Documenting the unrun
  form violated this repo's own rule against documenting a command nobody ran — run it.
  That is a deterministic boolean: it exits non-zero when **no** qualifying record exists,
  so it can gate a merge instead of being eyeballed. `DISMISSED` is excluded — a dismissed
  review is not a review of that head. Several qualifying records are fine; one is enough.

  **What was actually measured, stated exactly, because the defensive filter is not the
  observation.** On #12 and #13 the rate-limit warning appeared in CodeRabbit's **issue
  comment**, while the **pull-request review record** was an earlier, completed review of
  an earlier commit. The failure those PRs demonstrate is therefore a *missing* review for
  the final head — which the `commit_id` comparison catches — **not** a rate-limited review
  record carrying a stale commit id. No such record has been observed. The body filter is
  retained as **bounded defensive filtering** in case one exists, and must not be described
  as validating the warning that was seen; claiming otherwise would be this repository's
  recurring habit of promoting a defensive check into an observation.

  **The match must be case-insensitive, and the reason is not the one first given.** Gate A
  flagged this filter as case-sensitive and claimed `Review rate limited` would escape it.
  Measured: it does **not** escape — the capital R is in `Review`, and `rate limited`
  matches that string fine. But `⚠️ Rate limited` **does** escape, because there the
  capital is in `Rate`. So the fix is right and its stated reason was wrong; the pattern is
  now `test("rate limit"; "i")`, matching either spelling and the shorter stem. And the head must come from the **live PR** immediately before
  merging; comparing against local `HEAD` or a stale checkout reproduces the false-proof
  class this task exists to close. A record whose body says the review was rate
  limited does not count.

  **Measured on #13, which is why this is a rule and not a worry.** Its only CodeRabbit
  review record carries `commit_id = eed589c`, while the merged head was `92de0d2` — the
  one-token awk fix pushed after that review. The check was green and the PR merged; the
  final head was never reviewed, and the command above shows it in one line. `#12` settled
  the same way.

When they disagree, the bounded path is: re-trigger once, and if it is still
rate-limited, **merge only on an explicit human decision**, recording that the head went
unreviewed. Never let a green check stand in for a review that did not happen — that is
`unverified-enforcement-claim` applied to a bot.

---

## Task 7 — Release

**Rule.** Bump `plugins/dev-workflow/.claude-plugin/plugin.json` 0.5.1 → **0.6.0** (minor:
the scaffolded §5 template gains behaviour). CHANGELOG entry naming C's
companions **and** the template synchronization — and **not** A, which this PR does not
ship; naming it would publish behaviour 0.6.0 deliberately does not contain — omitting either would under-report a
user-visible template change in the same release.

**Verify.** `sh scripts/check-version-bump.sh main` ok.

---

## Invariants touched

**2** (directional), **5**, **6**, **9** (constrains the deferred B story and any
`/workflow-init` edit), **10** (taxonomy stays project-local), **11** (every changed
prompt passes all 12 checklist items — `CLAUDE.md`, `workflow-init.md` and its inline
templates are prompts, and a self-review is required before Gate B), **12** (0.6.0).
**Hooks are not touched** — if any task pulls toward `codex-gate.sh`, stop and surface.

## Success criteria

1. **Prompt-standards self-review (invariant 11)** over every changed prompt — required
   here, unlike PR 1, because this PR edits prompts rather than shell.
2. The **exact** quality command from `AGENTS.md § Commands`, green — including the two
   checks merged in #13, which now police the file this PR edits.
3. `sh scripts/check-version-bump.sh main` green **after** the work is committed.
4. Gate B full: `plugins/**` and `CLAUDE.md` are the product, so no prose exemption applies.
