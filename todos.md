# Todos — dev-workflow-kit

Backlog of stories, follow-ups, and prerequisites referenced by
`docs/hardening-log.md` (`pending` rows point here by `ref`).

## Now

### Policy: the self-hosting milestone is closed (2026-07-18)

This repo now improves itself **reactively only**. A change starts because a finding
surfaced — through the gates, a PR bot, or real use — goes through
`dev-workflow:harden-finding`, and lands via the normal PR flow. There are no
proactive self-improvement sweeps: no auditing our own files looking for things to
harden, no pre-emptively broadening a checker, no tidying passes.

Everything parked below **stays parked** until its trigger condition fires or Daniel
explicitly pulls it. A parked item is not a to-do list to work down; several are
deliberately deferred trade-offs, and re-opening one without its trigger is the
anticipation-driven escalation the ladder exists to prevent.

Why this is written down: self-initialization is exactly the phase that generates
appetite for more self-work, and the ledger's own escalation rules assume changes are
driven by recurrence rather than by enthusiasm.

### Parked (trigger-gated)

- [ ] **OpenWolf: possible bounded context/memory evaluation.** The
      [assessment](docs/openwolf-assessment.md) records the evidence, alternatives,
      trade-offs and proposed evaluation criteria. Documentation authorized by
      Daniel on 2026-09-16; installation, pilot and integration remain undecided.
      *Trigger: Daniel explicitly authorizes a bounded evaluation. Completion of
      loop-rule-consolidation alone does not activate it.* Existing Finding A,
      record-durability and P8 scopes and triggers remain unchanged.
- [ ] **Locator: TWO quadratic paths — `skipval`'s container walk and the record accumulator.** `substr(s,i,1)` is
      O(len) per call in BWK awk, so a large VALID sibling container before `tool_response`
      is quadratic: 3.2 s at 200 KB, 11.5 s at 400 KB, in one synchronous hook invocation.
      Only the 1 Mi-unit ceiling stops it, and a payload just under the ceiling still costs
      tens of seconds — so the ceiling is load-bearing rather than a formality. Found at
      Gate B pass 2 on 0.8.0, after two other quadratics in the same scan were fixed. The
      candidate fixes are a jump-based walk (linear for realistic shapes, still quadratic
      for many-sibling-container payloads), a work budget scaled by payload length, or
      lowering the ceiling — all three are design calls, which is why this is a row and not
      a patch. **Second path, found at pass 3:** `s = s $0 "\n"` rebuilds the accumulated
      input once per input line, so a newline-rich (pretty-printed) payload is quadratic in
      line count independently of the container walk — 0.35 s at 4k lines, 2.69 s at 16k.
      Chunked accumulation reduces but does not remove it; the two paths share a fix only if
      the scan stops indexing the payload with `substr`. *Trigger: a report of a slow hook,
      or any change that raises the ceiling.*
- [ ] **A5 marker matrix and A6 composition coverage are narrower than the approved plan.**
      The marker-lifecycle rows run through one emitter pair rather than both, omit the
      mixed pending-disclosure/background-advice write-failure combinations, and P9-9's
      pending-delete-failure row is skipped by name because no operation-specific fault is
      available (one permission governs both operations on `.context/`, and a directory at
      the pending path is not seen as pending). A6 composition is exact-tested against a
      failure message, a silent Bash event and the fallback emitter, not against every
      emitting branch. Closing it needs a selective `rm` shim and per-branch composition
      goldens. *Trigger: a disclosure or advice bug that the current rows do not catch.*
- [x] **The hardening ledger had no supersession convention.** **DONE in 0.8.2.**
      `docs/hardening-log.md`'s header said never edit a row, and one row per hardening — so
      when a row's "what this does NOT do" narration was later falsified by a feature change,
      there was no sanctioned move: editing broke the first rule and appending broke the
      second. Both rules now stand unchanged, and the correction is a third move: a
      `Superseded rows` entry appended above the `Columns:` paragraph, marking the row by
      date + fingerprint and naming what is false and where the current answer lives. The
      convention is in the ledger header and in `/workflow-init`'s inline template, and the
      2026-07-20 row — which taught pre-0.8.0 counting behaviour as current — carries the
      first entry. Design:
      `docs/superpowers/specs/2026-08-05-hardening-ledger-supersession-design.md`.
      **TRIGGER FIRED (2026-08-04):** the 2026-07-20 row taught pre-0.8.0 counting
      behaviour as current — the second falsified row this trigger named. Story:
      `docs/superpowers/stories/2026-08-04-hardening-ledger-supersession-story.md`.
- [ ] **The supersession convention names a repair for a mistyped locator and for nothing else an
      entry can get wrong.** `docs/hardening-log.md`'s header forbids entries from referencing one
      another, requires the governing entry to describe its row as it now stands, and forbids
      restating the current answer — but the only repair it spells out is for a mistyped locator
      ("corrected the same way everything else is, by appending"). An entry that is malformed in any
      other way has no named move, and entries are protected "committed or not", so editing is out.
      **Found in use, not theorised:** this round appended three entries that referred to other
      entries, and Gate-B pass 6 caught them. The repair applied — append a later, self-contained
      governing entry and leave the malformed lines standing as history — is a *reading* of the
      locator rule generalized, and it leaves a reader who stops at the first matching entry looking
      at a forbidden cross-reference. Any fix must keep entries immutable, which is the constraint
      that makes this awkward in the first place.
      *Trigger: a third round appending a malformed entry, or the first reader observed acting on a
      superseded entry instead of the governing one.*
- [ ] **A hardening that is later *removed* has no sanctioned supersession move.** The convention
      in `docs/hardening-log.md`'s header covers a row whose narration was falsified later or was
      wrong when written, and names a removed hardening as explicitly out of scope. No instance
      exists. *Trigger: the first rung actually removed.*
- [ ] **Nothing standing validates a supersession entry, and no chronology check exists.** The
      checks in `docs/superpowers/specs/2026-08-05-hardening-ledger-supersession-design.md` §6 ran
      once, on the change that introduced the convention, and then stopped; §6's 1e was not
      implemented at all, since it validates the ledger's pre-existing chronology rather than that
      change. Wiring both into `AGENTS.md`'s quality battery is the follow-up — **with the rider
      that any standing check must be diff-scoped *and* must pass on §2.2's sanctioned repair**: a
      whole-block scan is unsatisfiable once an immutable inert entry exists, and a check demanding
      that no appended entry be inert fails on the very move the convention prescribes for a
      mistyped locator. *Trigger: the first inert entry found after this change lands.*
- [ ] **`reviewType: full` races two writers onto both findings slots, and per-branch files do
      not stop it.** §5 prescribes one file per branch *because* `full` runs the spec and quality
      reviewers in parallel from one `additionalContext` — but nothing binds a reviewer to its own
      slot. On PR #23's Gate-B pass 1 both reviewers wrote **both** paths: the reply carried four
      protocol lines instead of two, spec reported `7 / 5` and quality `9 / 9`, and the disk held
      `9 / 9`. The face that makes it dangerous: **every acceptance condition still passed** —
      terminator present, count matching, nothing-but-finding-lines, both branch files present —
      because all four are *shape* checks and provenance is outside them. The spec branch's seven
      findings were gone and no check could say so. Fix candidate: make **sequential
      single-branch calls** (`reviewType: spec`, then `quality`) the documented default in §5 and
      in `/workflow-init`'s template — eliminating the concurrency rather than detecting it.
      Evidence: sixteen consecutive single-branch calls across passes 2–9 of that cycle, no
      recurrence. Fingerprint `unverified-enforcement-claim`, rung `P std` — the fitting rung, not
      an escalation: the guard-scope precheck against the 2026-08-04 row (whose guard is *"the
      exhaustiveness statement"*, for a sentence naming what a mechanism does not cover) puts this
      shape outside it, so the count alone does not escalate.
      *Trigger: **re-pointed 2026-08-16** at
      `docs/superpowers/stories/2026-08-14-sequential-branch-calls-hook-story.md`. The
      reviewer-availability story closed without shipping the sequential-calls rider — it is a
      hook change, not a §5 prose edit, and the unchanged hook counts each call as a pass.*
- [ ] **§5 gives the finding-line severity by example only, never as a closed set.** The gate
      prompt shows `MAJOR | high | …` and tells the reader to filter to Blocker/Major, but never
      states the four permitted tokens, and the acceptance rule validates shape — terminator,
      count, one-finding-per-line — not the severity's value space. On PR #23's Gate-B pass 3 the
      quality branch returned all four findings at severity `IMPORTANT`; the file was otherwise
      well-formed, so it passed every check and the Blocker/Major filter had to be applied by
      interpretation. Fix candidate: pin the enum in §5's finding-line spec and in
      `/workflow-init`'s template. Fingerprint `prompt-vague-criteria`, rung `P std`, no prior row.
      **CLOSED 2026-08-16** — §5 and the template now state the enum as a closed set, and
      `scripts/check-invariants.sh` check 4c asserts it is present exactly once in each copy
      (and, in the command file, inside the scaffolded template's own section). The reader
      normalizes an out-of-enum token to `MAJOR` rather than discarding the pass, which is
      what PR #23's four `IMPORTANT` findings needed.
- [ ] **The supersession story's AC 1 restates `CLAUDE.md` §5's profile-change procedure instead
      of referencing it.** Raised by CodeRabbit on PR #23 and accepted as accurate: the criterion
      spells out propose-axes → pause for confirmation → write the header, and does so *lossily* —
      it omits §5's renewed override, the profile-log line, and the rule that an axis change voids
      every prior override. Left unfixed there on the same ground as the plan divergences: the
      criterion is **satisfied and checked off**, so rewriting it edits a closed record of what was
      agreed at intake rather than changing any future behaviour. The story's own convention is to
      amend with explicit old-condition accounting, which is a human call.
      *Trigger: the next amendment to that story for any other reason — fold it in with accounting
      rather than opening the file for this alone.*
- [ ] **Locator selects the `text` element by RAW BYTE comparison of `type`.** A
      Unicode-escaped spelling of `text` is legal JSON meaning `text` and is not selected;
      with no other element the class is `no-result` (fail-closed, so discarded rather than
      miscounted, but still a wrong verdict on a legal payload). Same for escaped spellings
      of the `type`/`text` keys. Characterized by a regression row and stated in spec §3.1;
      closing it means decoding the `type` value for equality while still returning the
      selected `text` in its original escaped bytes, since the matcher depends on those.
      *Trigger: a serializer observed emitting escaped key or type spellings.*
- [ ] **Two consumer Gate-B cycles closed with no usable fingerprint persisted, while counting
      and cycle-recognition worked.** Field-reported from `infinite-portfolio-canvas` (~60+ Gate-B
      cycles, kit 0.8.0 since mid-run); evidence is that repo's `todos.md` § Tooling
      revalidation, which carries four dated measurements, and
      `docs/field-reports/2026-08-16-canvas-a1-a5-field-report.md` item 1. Two shapes, both
      measured with `CLAUDE_CODE_MCP_AUTO_BACKGROUND_MS="0"` **already set** — so this is not
      the backgrounding cause that entry started with, and it does **not** collapse into the
      preflight-check row in § Next.
      **(a) 2026-08-11, cycle `5a4bf38`, 24 counted passes.** `.context/codex-gate.gateB` held
      the literal `unavailable` and `codex-gate.freshCount` a `0` at session start. **Read the
      hook before repeating the consumer's inference here:** a stale `unavailable` is **not**
      sticky — every counted pass recomputes `tree_hash()` and overwrites the state file
      unconditionally (`codex-gate.sh`, the counted-pass branch), setting the fresh streak to 1
      on a computable hash and to 0 only when the hash is uncomputable *at that moment*. So the
      observation does not show a cycle poisoned by its starting state. **What it does show is
      narrower than "the hash was uncomputable at every pass":** the persisted value was
      `unavailable` at the observed endpoints, and the write itself is best-effort — the state
      file is written under `2>/dev/null || true`, so a later computable hash that failed to
      persist is indistinguishable from one never computed. Uncomputable hashes and a failing
      write are both live candidates, and the row picks neither.
      Conditions were the cleanest
      available — pass 13 Blocker/Major-free on both branches, both branches on byte-identical
      content, nothing edited between the last pass and the `--amend`, the closing tree equal
      to the reviewed WIP tree (`b2757ff`), and the hook's own diagnostic checklist green
      point by point (`.context/` and `TMPDIR` writable, `shasum` present, `git status` runs,
      49 GiB free). Both state files were gone after the amend, so the hook read the amend
      correctly as cycle-closing. Recognition and counting work; what the reported states do not
      separate is computation from persistence.
      **(b) 2026-08-16, cycle `f09286b`, counter at 21.** The count alone says nothing about the
      fingerprint — the hook increments it independently of whether a hash was computed or
      persisted — so read this as an observation and not as proof that storage worked. That STOP
      was correct (a comment correction sat
      between pass 13 and the reset — real drift). Unexplained is the close: after a fresh pass
      14, clean on both branches, the `--amend` reported "no fingerprint is recorded for this
      cycle", which is the `reviewed`-empty branch — the state file absent, not stale. The
      consumer's own narrowing is the ordering "WIP commit → pass → `--amend`", where the
      closing amend no longer sees the fingerprint of the pass immediately before it.
      **What this round did not establish, which is most of the mechanism:** whether the hash was
      computable at any given pass of (a), whether a computed hash failed to persist, and why (b)'s
      close found no fingerprint. The observations are the persisted values at the endpoints, the
      counts, and the messages — nothing between them. Per-pass computation, per-pass persistence
      and the stored `reviewed` value at each STOP are all unknown.
      Reading the hook at the site that computes the hash and returns `unavailable` is the
      consumer's own named next step and was not done here. One lead worth carrying: (b)'s STOP arrived at
      a `git reset --soft` call, which reaches the reset path only if `is_commit` matched that
      command string — so the loose-grep row below is a candidate contributor to (b), and the
      two should be read together rather than separately.
      *Trigger: a second consumer reporting an unhealable fingerprint, or the next change to
      the fingerprint code path.* A hook change either way, which is why this is a row.
- [ ] **A mere mention of "commit" beside a `git` command closes the cycle and resets the pass
      counter.** `is_commit()` greps the raw command string for
      `(^|[^[:alnum:]])git[[:space:]].*commit` (`plugins/dev-workflow/hooks/codex-gate.sh:756`),
      and on a non-WIP match the counters are reset. So a diagnostic `echo` is not merely the
      "redundant warning" invariant 2 accepts as the price of firing loose — it destroys the
      floor silently. **Measured in the field** (canvas, 2026-08-04):
      `git status --porcelain; echo "--- last commit body ---"; git log …` in one Bash call
      dropped the counter from **5 to 0**, and the real closing commit then reported "1
      recorded pass". The consumer's memory note `gate-b-echo-resets-pass-counter` names why
      this is the dangerous direction: "the loss looks exactly like passes that never ran".
      **Second shape, same call-string looseness, already tracked above:** `git add … && git
      commit …` chained in one Bash call defeats the docs-only exemption, with two controlled
      data points isolating the variable — `29da026` (separate `git add`) → "N/A (docs-only)",
      `c2fa18e` (chained) → STOP. That is the timing class the compound-commands row tracks,
      and these are cross-consumer instances of it from a second repo, predating that row's
      occurrences 3 and 4. That row's occurrence count is deliberately left unedited here, so
      this field item carries exactly one disposition; whoever escalates it should count these.
      **Third shape rejected as unverified:** the report's heredoc-fires-a-false-STOP claim
      resolves, at its cited evidence, to §5's own *warning* about heredocs restated in the
      consumer's `CLAUDE.md` and `todos.md`. No measured instance exists.
      *Trigger: a second reported counter loss, or any change to `is_commit`.* The fix is a
      parse rather than another pattern, so it is a hook change.
- [ ] **The arms-race remedy exists as an observation and not as a procedure.** When a series
      of passes stops converging because each correction enables the next finding of the same
      shape, the remedy the field found is to change what is being checked rather than to patch
      once more: scope the reviewer to changed regions, change the instrument's layer, or
      relocate the residual to the layer that already catches it — and **STOP with a named
      state** rather than run the next round. Verified at three sites in
      `infinite-portfolio-canvas`: its `docs/hardening-taxonomy.md` corollary ("when a tool
      enters an arms race with its reviewer, it is checking at the wrong level"),
      `.context/a5-t2a-resume.md` (four consecutive passes each finding one more spelling the
      claim text seemed to cover; changing the instrument's FORM — printing the patterns,
      stating the cause as line- and grammar-local — took findings from **nine to zero**, and
      the residual became a named ticket with its own budget whose trigger is a *relapse*), and
      `.context/gate-b-a5-t2a-dispositionen.md` (six of six findings on the checker's grammar,
      none on product behaviour). Before this round the kit stated the same idea in one place only,
      and locally — the invariant-checker escalation row below ("adding one more regex arm per
      newly-discovered spelling is *not* the ladder working"); as of this round the story named
      below and the amended guard-scope story also state it, so the count is a before-picture and
      not a current inventory.
      **Parked as a story, not written as prose, because it lands on a decision branch that is
      already under design:** as a procedure it changes which rung `harden-finding` picks when
      passes stop converging, and that branch is the subject of the guard-scope-precheck story.
      Story: `docs/superpowers/stories/2026-08-17-arms-race-remedy-as-procedure-story.md`,
      which **inherits from and is inherited by**
      `docs/superpowers/stories/2026-08-04-harden-finding-guard-scope-precheck-story.md` —
      recorded in both directions on purpose: one decision branch, one design, and whichever is
      picked up first must read the other rather than re-deriving it.
      *Trigger: either story being picked up, or a third arms-race series observed.*
- [ ] **A handback says nothing about how much context produced it.** When a gate loop stops and
      surfaces — §5's `clearly stuck → STOP and surface`, or the new scope stop beside it — the
      human decides whether to continue in the same session or start fresh, and one input that
      could inform it is absent: how much context the surfacing agent had left. How much that
      input actually decides is unestablished, and the evidence below shows only that operators
      asked for it repeatedly, not that it changed an outcome. The field adopted
      it as a standing field, carried as a documented instruction and nothing stronger — nothing
      verifies that an agent supplies the figure, that a reader demands it, or that a self-reported
      percentage is accurate: the consumer's
      `docs/handoff-cowork.md` carries `Kontext-% (einfordern, falls fehlend)` at line 10 and
      `Kontext-% in Übergaben einfordern` at line 72 — demand it, and demand it again when a
      handback arrives without it. **This row exists because the round first rejected the item on
      a search that missed that file** (it searched the consumer's `.context/`, `todos.md` and
      `CLAUDE.md`, where the only percentages are pixel-coverage measurements), and Gate-B pass 1
      caught the rejection. Two things are unsettled, which is why this is a row and not a
      sentence in §5: whether a self-reported context figure is reliable enough to steer a
      decision, and whether it belongs in §5's stop text, in the handoff-shaped artifacts, or
      both. Adding it to §5 mid-cycle would also have put a third rule into a paragraph already
      under review.
      *Trigger: the next §5 edit touching the stop-and-surface text, or a session continued past
      a handback and lost to compaction where the figure would have said to start fresh.*
- [ ] **EXPERIMENTAL — proportionality for findings whose subject is a test instrument.**
      Proposed rule: a finding about the instrument rather than about product behaviour gets one
      repair round, then is collected — unless it demonstrates a false-green on product
      behaviour, which keeps it iterating. Explicitly **not field-proven**; the report marks it
      as a proposal, and its motivation is that late cycles spent a growing share of passes on
      meta-instruments. Cross-project corroboration for the *motivation only*, from this repo's
      own history: PR #23's closing commit records that "of 27 Blocker/Major findings, 16 were
      in the never-committed scratch harness, 10 in the design spec's narration, 1 in the plan"
      (`7bbdb14`) — 16 of 27 on the instrument. What is unproven is the *remedy*: capping repair
      rounds by the finding's subject weakens the Blocker/Major rule that makes the loop
      trustworthy, and the false-green carve-out is the whole difficulty rather than a footnote.
      *Trigger: a cycle where instrument findings measurably starve product findings of passes,
      with both counted.*
- [ ] **EXPERIMENTAL — pre-split heuristic for oversized tranches.** Proposed rule: a tranche
      exceeding a size signal (the report suggests >N new runners or steps) is split by subject
      at PLAN time. **Its factual premise is rejected as unverified, not merely caveated:** the
      report states that every large tranche in the field split anyway and always through an
      expensive stop-decide-re-record round-trip, and it cites no tranche records, sizes or
      measurements — none were found, and the round did not adopt the frequency or the cost claim.
      What is parked is the *proposal only*. The threshold is then the entire remaining question:
      a number chosen without measurement would split tranches that did not need it, and this
      repo has no measurement of its own to set one.
      *Trigger: three tranches in one project splitting mid-execution, with their sizes
      recorded* — that is the sample a threshold could be read from.

- [x] **A failed Codex call counts as a pass — false ✓ in the firing direction.**
      **DONE in 0.8.0.** The hook now reads the result before counting. Five classes
      (spec §3.3): `success` and `unrecognized` count and store a fingerprint; `failure`
      (the envelope's immediately-first property is `success: false`), `backgrounded`
      (the harness notice anchor at the start of the located block) and `no-result` (an
      unambiguous determination that no located block yields a non-blank string) do
      neither. The candidate fix recorded here was right about the direction and wrong
      about the unknown: `tool_response`'s real shape for `mcp__codex__*` was established
      by capturing live payloads, which now ship as fixtures.
      **What remains, and it is the accepted residual, not a leftover of this row:**
      locating-uncertainty is fail-OPEN — an unwalkable structure, a repeated depth-1
      `tool_response`, or a payload past the scan bounds counts, with a
      once-per-workspace disclosure that the count was made without inspection. And the
      counter is still not evidence: classification cannot see whether the findings file
      was written, so an incomplete pass is discounted whatever the counter says.
      C1–C4 in `plugins/dev-workflow/CHANGELOG.md` carry the full residual list.
- [ ] **jq-free parser stops at an escaped JSON quote.** *(Candidate path, recorded
      2026-08-01: the result-classification story builds a POSIX awk locator with proper
      string-state and backslash-parity handling. Once that exists and is proven against the
      captured fixtures, this row's fix can likely reuse it rather than inventing a second
      escape-aware scanner. The scopes stay separate — that story does not touch
      `input_field` — but whoever takes this row should look there first.)* A payload containing
      `echo \"quoted\" && git commit -m x` decodes to nothing, so no reminder fires —
      wrong direction under invariant 2, and only on machines without `jq`. Needs
      escape-aware decoding or a conservative raw-payload scan, plus tests for escaped
      quotes and backslashes.
- [ ] **Compound commands hash the pre-mutation tree.** `printf changed > tracked.txt
      && git commit -am x` is one PreToolUse event: the hook hashes before the mutation
      runs, so the commit carries content the hash never saw. Consider treating any
      command segment preceding `git commit` as uncertain and firing.
      **Occurrence 2 (2026-07-30): same event-timing class, second consumer —
      `is_docs_only` rather than `tree_hash`.** Commit 1950739 staged exactly one
      `docs/**.md` path, so Gate B was N/A per CLAUDE.md §5's prose exemption, yet the
      hook emitted the Gate-B STOP. Cause, read from the source rather than inferred:
      the docs-only branch derives its file list as
      `files=$(git -C "$repo_root" diff --cached --name-only)` at PreToolUse, the commit
      was issued as a single Bash call whose `git add` had not run yet, so that list was
      empty — and `is_docs_only` opens with `[ -n "$1" ] || return 1`, which the branch's
      own comment states as intent ("Only when the file list is POSITIVELY confirmed
      docs-only; an empty list falls through to fire"). So the timing gap now has two
      consumers, and this one is a **false positive** — it fires when it need not, the
      safe direction under invariant 2 — where the `tree_hash` consumer above is the
      dangerous direction. Counts toward this row's eventual trigger; not fixed now, and
      note that any fix must keep the empty-list fallthrough firing rather than trade a
      redundant warning for a missed one.
      **Occurrence 3 (2026-08-14): same shape as occurrence 2, same consumer.** `git add`
      and `git commit` issued in one Bash call on PR #23's close; the staged set was empty
      at `PreToolUse`, `is_docs_only` fell through, and the Gate-B STOP fired on a
      docs-only commit. Like occurrence 2 a **false positive** — the safe direction.
      **Occurrence 4 (2026-08-16): same shape again, on PR #24's review pass.** `git add` and
      `git commit` in one Bash call; the staged set was empty at `PreToolUse`, `is_docs_only`
      fell through, and the Gate-B STOP fired on a docs-only commit. A **false positive** like
      2 and 3. Counted here even though it was observed rather than suffered, because the
      trigger is recurrence of the shape and an occurrence noticed by the person who caused it
      is still the shape recurring; excluding it would tune the count to who was watching.
      Four occurrences of the timing gap now, three of them benign; the dangerous `tree_hash`
      consumer above is still the one that decides this row's priority.
- [ ] **Hook repository context can differ from the operation's target worktree.** A **distinct
      cause from the timing row above**, and that row's occurrence count is deliberately left
      unchanged: timing is "the staged set was empty because `git add` had not run yet",
      this is "the staged set was read in the wrong repository". **Reported observation
      (2026-09-21):** a docs-only commit of two `docs/**.md` paths in the linked worktree
      `dwk-claude-init` received the Gate-B STOP **although `git add` had run in a separate
      Bash call**, which is the control the timing row's `29da026` data point relies on. The
      index readings behind that account are reported, not re-reproduced here.
      **Verified mechanism, read from the source:** the hook derives its root from **its own
      Git process context** — `repo_root=$(git rev-parse --show-toplevel)`
      (`plugins/dev-workflow/hooks/codex-gate.sh:42`) — and uses that root both for the state
      paths (`state_dir="$repo_root/.context"`, `:43`, holding `codex-gate.gateB`,
      `.passCount`, `.freshCount`, `.passCountA`) and for the staged-file inspection
      (`files=$(git -C "$repo_root" diff --cached --name-only)`, `:914`). **Do not state this
      as "it always uses the original session worktree"** — what is established is that the
      root comes from the hook's own context, which need not be the operation's target.
      **Two consequences derived from the code and NOT reproduced.** First, a **false
      docs-only exemption**: where the foreign root's staged list is non-empty and passes
      `is_docs_only` — which also requires clearing its `is_prompt_path` exclusions, so
      arbitrary Markdown is not enough — the hook can report "Gate B N/A" while the actual
      commit carries product files. That is the dangerous direction, so **invariant 2 is not a
      blanket answer for this row**, even though the observed instance was a benign false
      alarm. Second, a **foreign state reset**: the non-WIP commit branch runs
      `rm -f "$state_file" "$count_file" "$fresh_file"` (`:886-888`) under the same
      `$repo_root`, so it can clear another worktree's Gate-B fingerprint and counters.
      **Operational precaution, not a repair:** starting a session directly in the intended
      worktree keeps the two contexts aligned; a `cd` **inside** a Bash call does not, because
      the hook runs before that command. **Implementation deliberately undecided** — the
      payload's cwd, the hook process's cwd and an operation's explicit target must not be
      assumed equivalent, and picking one is the design question, not a detail. **Trigger:**
      Daniel explicitly selects a bounded reproduction-and-design task. That task should
      separate the reported false alarm, the possible false exemption and the possible foreign
      reset, and establish each before a repair is proposed. This entry starts none of them.
- [ ] **No regression test for a `git add`/`write-tree` failure inside the throwaway
      index.** Derived from the code, not recalled: sections 24a-24e stub FIVE failure shapes —
      every checksum tool failing silently, a checksum printing a token then failing, the
      seed `cp`, `git diff HEAD`, and `rev-parse --absolute-git-dir`. SEVEN have no
      targeted test: `mktemp -d`; the non-symbolic unresolvable-HEAD branch (the
      `else ok=0` arm); the throwaway-index `git rm -rfq --cached`; the first
      `write-tree` (index tree); `git add -A`; the second `write-tree` (worktree tree);
      and failure of the redirect that creates the buffered stream. The two `write-tree`
      calls are distinct sites needing distinct tests — one covers the index component,
      the other the worktree component. Each needs a portable way to fail exactly one
      call without disturbing the rest; a selective `git` wrapper earlier on `PATH` (as
      24d/24e already use) is the seam for the git ones. This row was written three
      times from memory and understated the gap every time — re-derive from the code
      before trusting it.
- [ ] **Gate-B fingerprints disk; the reviewer reads history.** A review pass records a
      fingerprint of the index and worktree, but `mcp__codex__review` reads a **git
      range** — so content that is staged and never committed can be fingerprinted as
      reviewed without Codex having read it, and three such passes reach ✓. Raised at
      Gate A pass 8 of the index-tree story and deliberately deferred there: closing it
      means refusing to satisfy Gate B unless the index and worktree correspond to the
      reviewed range, i.e. mandating a WIP commit for every review. That redefines the
      gate rather than fixing a hash, so it needs its own story and its own decision.
      CLAUDE.md §5's WIP-commit flow is the current mitigation.
- [ ] **`check-invariants.sh` scans untracked scratch directories, so local scratch can
      fail it.** It greps the working tree recursively, not the tracked set, so a
      gitignored scratch file that merely *quotes* a violating pattern trips it. Hit for
      real: the SDD scratch under `.superpowers/` held pasted test output in which the
      word `npx` sat next to a `--yes` flag inside one of the checker's OWN test
      descriptions, and the checker then reported an unpinned-npx violation against a
      repo containing no such call. (This row deliberately does not quote that string
      verbatim — doing so put the pattern into a tracked file and made the checker fail
      on this very commit, which is the bug demonstrating itself.) A false positive, so
      it is the safe direction — but it is confusing, and it makes "the battery is
      green" depend on what else happens to be on disk. Surfaced by real use during the
      index-tree story, not by a gate. Fix would be to scan tracked files (or honour
      `.gitignore`), with a reject/accept fixture for a violating pattern inside an
      ignored path.
      **Occurrence 2 (candidate note, not a fix): recurring operator friction.** Closing
      that same story, the battery had to be run with `.superpowers/sdd/` moved aside
      *again* — by hand, remembered rather than prompted. So this is not only a
      confusing one-off red: it is a step a human must know about and repeat, on a
      command AGENTS.md presents as "what CI runs". Two occurrences of the same class
      now; counts toward whatever trigger this row is eventually escalated on.
- [ ] **Gate-pass counters are read-modify-write, with no serialization.** `bump_count`
      reads, increments and writes; two `PostToolUse` events arriving concurrently can lose
      an increment, and the fresh-count, fingerprint and pass-count writes are independent,
      so a reader can observe a mixed snapshot. This **predates** the result-classification
      change and applies to every counter — that change adds files with the same property,
      not new exposure, which is why it was documented as a stated contract there rather
      than fixed asymmetrically. Raised as MAJOR at Gate-A pass 2 of that design under the
      risk lens. *Trigger: the first observed lost increment, or when batch/orchestrator
      work makes concurrent gate calls real* — the parked story for that is where
      concurrency stops being hypothetical. Until then: known, stated, unexploited.
- [ ] **The hook trusts `.context/` and does not reject non-regular state targets.** A
      globally installed hook creates and truncates files inside a repository-controlled
      directory, following symlinks; a hostile workspace could point a state file or marker
      at another user-writable path. **Pre-existing** for every state file the hook already
      writes — the result-classification change adds markers with identical properties, so
      fixing only the new ones would be inconsistent, and fixing all of them was out of that
      story's scope. Raised as MAJOR (medium confidence) at Gate-A pass 2 under the security
      lens. Any fix must keep invariant 1 (always exit 0) on the rejection path.
      *Trigger: the first security-`high` story touching the hook, or a real report of a
      hostile-workspace scenario.*
- [ ] **Temp-index writes land in the real object database.** `git add -A` against the
      throwaway index writes loose blobs/trees into the user's repo (verified: 3 → 5
      objects per review). Unreachable, so gc collects them, but a temporary
      `GIT_OBJECT_DIRECTORY` with the real store as an alternate would avoid the churn.
- [ ] **The gate-claims Don't is correct and was not followed, twice.** PR #21's C4 (an
      unqualified jq-parity criterion that outran what `field()` compares for a malformed outer
      document) and C5 (a README claim that a typo cannot quietly unhook a gate) both fall
      inside the 2026-07-19 `AGENTS.md` Don't, whose operative instruction already requires
      exactly what they omitted — name the exact comparison the code performs, and delete any
      part of the sentence that outruns it. **No textual repair exists**, which is why these are
      parked rather than logged: a ledger row would have to name a hardening, and a rule needing
      no change means the failure was compliance, not wording. The 2026-08-04 amendment covers
      coverage enumerations (F8's shape) and reaches neither a positive parity claim nor a
      positive prevention claim. *Trigger: a third compliance miss against that Don't, or a
      feasible mechanical rung emerging from
      `docs/superpowers/stories/2026-08-04-harden-finding-guard-scope-precheck-story.md`.*

## Next

Roadmap items below are **kit-side only** and carry the same trigger discipline as
Parked: each names the condition that starts it, and none starts early. Product-side
work — wiring a security battery, a validation lane, coded E2E — is deliberately absent.
That belongs in each product project's own `todos.md` once `/workflow-init` has run
there, not here: this repo ships the workflow, it does not hold another project's
backlog.

- [ ] **Ordering group G1 — workflow guidance, controlled requirement changes, visible
      acceptance evidence.** Recorded 2026-10-03 (Daniel), from the advisory comparison
      with `AlexPEClub/ai-coding-starter-kit` at `21a97bb5`
      (`.context/sparring/20261003-124930-ai-coding-starter-kit-process-assessment.md`,
      local and untracked). It is an ordering group of three leaves, each its own story at
      intake, and **none of them is activated by this entry**. Every leaf must also serve the
      Dark Factory's monitoring promise: what it produces is something the human can see in
      the computed live view (vision §4, "The live status is a computed view too"), which
      renders it. No leaf adds a status store, a second roadmap, a new QA gate, a routine
      approval checkpoint or an agent fleet, and none changes a gate obligation.
      Stack-neutral: nothing from upstream's stack, severity vocabulary or synchronized
      PRD/index statuses is adopted.
      - **G1a — controlled change to an existing story or spec. First candidate.**
        *Problem:* narrowing or redirecting an approved story after a gate finding is ad
        hoc today. Both 2c narrowings (part 1 on 2026-10-02, part 2 on 2026-10-03) were
        handled by hand, each with its own fate table: part 1's in
        `docs/superpowers/stories/2026-10-02-run-analytics-trace-id-and-retention-story.md`,
        and part 2's in `docs/superpowers/stories/2026-10-02-review-loop-usefulness-assessment-story.md`
        (PR #35, on `main` once it merges). *Outcome:* a bounded refinement
        procedure in the existing `sparring` and `intake` workflow. It classifies the reason
        (a changed requirement, a gap the implementation discovered, or a change of
        direction). It then names the affected criteria, the conditions kept, moved or
        deliberately dropped (AGENTS.md, "Never replace a decision procedure without
        accounting for its old conditions"), the changed scope, the open questions, the
        dependent artifacts and the consequence for reviews already run. Every decision is
        dated, with its rationale. *Excluded:* a separate skill (a later design decision,
        inspired by upstream `refine`); any automatic "spec updated, continue"; closing
        adjacent gaps as a side task. *Owner and dependencies:* the plugin's `sparring` and
        `intake` skills, so implementing it is a prompt change (full Gate B, version bump).
        **2c part 3 (spec-delta capture,
        `docs/superpowers/stories/2026-10-02-telemetry-and-review-loop-usefulness-story.md`)
        owns the mechanical record of a spec change after its Gate-A cycle closed;** G1a owns
        the human decision procedure that produces such a change, and feeds part 3 rather
        than competing with it. *Status:* ready for intake; activated only when Daniel
        selects it. *Acceptance checks:* replayed on the two recorded 2c narrowings, the
        procedure reproduces their fate tables and names their dependent artifacts; a change
        after a closed gate states which further pass or cycle it owes, as §5 already
        decides.
      - **G1b — acceptance evidence per criterion.** Attached to **P5 light** (stable AC IDs,
        below) and to vision §7 leaf **4e** (AC IDs, given/when/then normalization, per-AC
        test report), which stay the owners. 4e's order and safeguards are unchanged.
        *Adds:* a compact presentation per criterion: `AC-ID → test evidence, test result,
        tested revision → review status, reviewed revision`. Each result is one of passed,
        failed or not assessed, and review and test keep their own revisions (vision §4: no
        older result may read as verification of the current work). It reuses the
        existing commit-body evidence entries and review artifacts before any new report.
        It is shown in the live view as a per-story panel. *Excluded:* a QA stage, an E2E
        test per criterion, "production-ready" claims, and upstream's severity scheme.
        *Status:* proposed; it follows P5 light's trigger and 4e's place in the build path.
      - **G1c — workflow navigation.** Attached to **P1** (`workflow-status` →
        `workflow-next`, Someday), whose staged rollout and trigger are unchanged.
        *Adds:* a fixed output shape for the status read: current story and revision, the
        last completed stage **evidenced** by its closing records (not by a section being
        present), the current blocker (an open stop, hold or decision), and source links.
        Once the status is reliably right, the next permitted action follows. The console
        command and the live view render the **same** computed read: the dashboard's
        per-story view is G1c's output, so the human can follow every story without asking.
        *Excluded:* a separately maintained help workflow, and any stored status.
        *Status:* proposed; P1's trigger (3–5 real stories completed in a product project)
        still governs it.
        **2026-10-05:** the vision's decision inbox (§4) adds the fields an attention entry
        shows: the decision or action, reason, recommendation and consequences, story,
        revision, evidence links and freshness. Archiving changes visibility, never status.
      *Secondary design inputs, not leaves:* path-scoped project rules with referenced
      checklists, and project-level goal and non-goal discovery, are considered when the
      owning areas (rule loading, the vision's AGENTS.md goals and the pool) are designed.
      *Trigger for the group:* Daniel selects G1a for intake. G1b and G1c keep their
      owners' triggers.

- [ ] **Ordering group G2 — one workflow core for Claude Code and Codex, with session
      roles.** Recorded 2026-10-03 (Daniel). It draws on two advisory inputs, local and
      untracked: `.context/sparring/20261003-132000-client-neutral-workflow-assessment.md`
      and `.context/sparring/20261003-133609-session-role-entry-assessment.md`. This is an
      architecture direction, not an approved specification. **Nothing is implemented, and
      no leaf is activated.**
      *Intent:* Daniel opens separate sessions in one project, in either supported client,
      and chooses each session's role:
      - **coding agent:** implements in its assigned scope and requests independent Gate A
        and B reviews;
      - **sparring partner:** investigates, verifies and drafts handoffs, does not implement,
        and may write explicitly authorized advisory documents;
      - **reviewer:** takes a bounded assignment against identified artifacts or revisions and
        returns findings without repairing the candidate.
      The two initial directions are Claude Code implementing with a configured Codex
      reviewer (today's route), and Codex implementing with a configured Claude reviewer.
      Gate A and Gate B reviewers are configurable, with reusable confirmed defaults. The
      different-model-family requirement stays: a different model name or gateway alone does
      not establish independence, and the parked same-family fallback stays parked.
      *Architecture direction:*
      - **A shared core:** stages, profiles, gate contracts, findings, hardening and closure
        rules each keep one authoritative source. Invariant 8's inline templates and the
        `Target model:` lines of executable prompts stay.
      - **Thin client integrations,** each verified per client: installation, discovery,
        entry points, configuration and lifecycle events. Credentials and loaded versions
        stay separately observable.
      - **A reviewer integration** that normalizes the assignment and the result while keeping
        the exact reviewed input and the observed execution identity. A missing, failed,
        truncated or unattributable result is never a successful independent review.
      - **Session-local roles over shared project defaults.** Choosing sparring in one
        terminal never switches another. A transition that needs independent context opens a
        fresh session, so relabeling an implementation conversation is not a review.
      The first delivery uses two human-facing sessions (coding and sparring), with the coding
      agent starting a fresh reviewer per gate; a third reviewer terminal is not required.
      One writer and a read-only adviser may share a checkout, with advice tied to its
      observed revision. Several implementers need separate assigned workspaces and change
      ownership, because a shared plugin installation coordinates no writes.
      *Leaves, in dependency order, each its own story with its own profile at intake:*
      - **G2a — inventory and contracts.** List every place the kit assumes Claude Code or
        the Codex reviewer: skills, `CLAUDE.md`, hook events, the `mcp__codex__.*` matcher in
        `hooks/hooks.json`, the `mcp__codex__exec` and `mcp__codex__review` names in
        `codex-gate.sh`, and AGENTS.md's dependency-direction statement. Define the client contract and the reviewer
        assignment/result contract, mapping each existing condition as kept, moved or
        changed. Output: a spec. *First candidate of this group.*
      - **G2b — the Codex-implements, Claude-reviews route,** proven on one small real change
        while the existing route stays valid. *Open technical questions:* how Claude is
        invoked as an external reviewer, how it is isolated, and what replaces the hook's
        lifecycle events in Codex.
      - **G2c — session role entry:** role choice, role persistence across resume, and
        reviewer configuration. Each session shows its role, project or worktree, known model
        and kit version, and a coding session also shows its reviewer assignments. It builds
        on the shipped `sparring` skill (advisory and explicitly invoked; its limits are
        prompt instructions, not a demonstrated sandbox).
      - **G2d — installation, update and end-to-end support verification** for both clients,
        showing installed and loaded versions separately.
      *Proposed acceptance checks, to be refined at intake:*
      - both directions complete story → spec → plan → implementation → quality →
        independent review → closure on a small real change;
      - today's route demonstrably still works;
      - two sessions in one project keep independent roles, and sparring does not implement;
      - a configuration or identity mismatch, or an unknown model family, is surfaced, and an
        unavailable independent reviewer cannot produce a successful gate;
      - every finding is tied to its exact assignment and candidate;
      - lifecycle, resume and version behavior are checked per client;
      - role limits are labelled as prompt instructions or as enforced restrictions.
      *Relation to G1 and the Dark Factory:*
      - G1a's refinement procedure belongs to the sparring role.
      - G1c's status read shows the session's role and its next permitted action.
      - G1b, P5 light and vision leaf 4e keep AC evidence.
      - In the vision, these roles are what the orchestrator (step 3) assigns. The computed
        live view (vision §4) is where the human sees which session holds which role,
        reviewer assignment and revision.
      No status store and no roadmap copy is added; no gate obligation changes.
      **2026-10-05:** story identity, execution attempt and agent session stay separate.
      The vision's four restart cases (§11, *durable story, exchangeable sessions*) are
      acceptance input for G2c's role persistence across resume, beside 4a and 5a.
      *Excluded:* support promised for every model or client, autonomous role switching, new
      routine approval checkpoints, and any change to shipped files, hooks, CI or
      configuration before a leaf is designed.
      *Trigger:* Daniel selects G2a for intake. Until then the active 2c work (parts 3 and 4)
      keeps priority; how G1a and G2a rank against it is Daniel's call.

- [ ] **`git commit --amend --no-edit` silently resets a Gate-B cycle, and nothing warns.**
      `plugins/dev-workflow/hooks/codex-gate.sh:763` is
      `is_wip_commit() { printf '%s' "$1" | grep -Eiq -- "-m[[:space:]]*['\"]?[[:space:]]*wip"; }`
      — it matches the **Bash command string**, not git state and not the commit message.
      So an amend written the natural way carries no `-m`, is not recognized as a WIP
      commit, and at `:886` `is_commit "$cmd" && ! is_wip_commit "$cmd"` is true: the hook
      resets and the accumulated Gate-B passes are discarded. §5 tells everyone to snapshot
      with `WIP: …` and close with `--amend -m "<real message>"` but never says the
      recognition is a grep over what you type, so following §5 as written and amending
      with `--no-edit` mid-cycle destroys the cycle with no signal.
      **Loose in both directions**, which is the same root cause: a `cat` heredoc merely
      *containing* the text `WIP:` fires the WIP notice, and one containing `git commit`
      fires a Gate-B STOP. Both observed in the 2026-08-29 session. That direction is
      harmless per invariant 2; the reset direction is not.
      Found while writing the review-loop-economics plans, whose whole commit protocol had
      to be built around it — see
      `docs/superpowers/plans/2026-08-29-review-loop-economics-plan-a-rules.md`
      § "The `--no-edit` trap" and `.context/codex-reviews/gate-a-plan-rle-pass-1.md` B15.
      **Not fixed there**: those plans are prompt-only by their own constraint, and the fix
      touches hook code. Two candidate rungs, and the choice is the point — prose (§5 warns
      about `--no-edit` explicitly, cheap, does not stop the next person who forgets) or a
      real fix in the hook (recognize an amend that preserves a `WIP:` subject, which means
      reading git state rather than the command string). Prefer the latter if the class
      recurs; log it through `harden-finding` when it does.
      *Trigger: the next change that touches the hook, or a second observed cycle reset.*
      **Reset direction fixed in 0.13.2** for the plain form only: `is_wip_commit` also
      accepts a one-line `git commit` whose only arguments are `--amend`, `--no-edit` (both
      required), `--no-verify`, `-a`, `--all`, `-q` or `--quiet`, with no quote, `#`,
      backslash or shell metacharacter, when `HEAD`'s subject starts with `wip`, no custom
      `core.commentChar`/`core.commentString` is set, no `core.hooksPath` is set at all, and
      the default hooks directory holds nothing but `*.sample` files (stricter than Git's
      own rule: a message hook could rewrite the message, and an earlier hook could install
      one mid-commit; the check sees the directory only when the hook runs). An
      allow-list, because four Gate-B passes found a new bypass in every deny-list. Still
      open, deliberately, all in the safe direction: any other spelling of a WIP amend
      (global `git -c`, `cd … &&`, `-F`/`-C` with a WIP message) still resets, and a heredoc
      merely containing `WIP:` or `git commit` still fires. **Fixed in 0.13.3:** the
      `-m "wip…"` path used to trust the typed message; now the reminder is decided before
      the commit (a repository that could rewrite the message gets the Gate-B reminder) and
      the reset after it (counters stay only for a WIP result attributable to the command,
      by the rule in the 0.13.3 CHANGELOG entry), for an allow-listed one-line
      `git commit` only. The §5 Mechanics text and both docs now describe that.
      Still open, in the safe direction: a chained or redirected WIP commit resets.

- [x] **P2 — risk/security profiles, and the derived validation mode.** Shipped: two
      human-confirmed axes in the story header, a mode derived as `max(risk, security)`,
      lens sets appended to the §5 gate prompts, and the Gate-B triviality skip narrowed
      to effective level 0. Spec:
      `docs/superpowers/specs/2026-07-26-risk-security-validation-profiles-design.md`.
- [ ] **P6 — standalone security sections in the intake, spec and gate templates:
      DELIBERATELY REJECTED, not shipped.** The profile *is* the heading: a standalone
      section would be a second surface to keep in sync with it (the docs-drift class),
      and it invites boilerplate-filling on stories where nobody knows what to write.
      Security content lives in the spec's decision record and risks discussion and in
      `AGENTS.md` invariants; the security lens set is what asks about assets, trust
      boundaries, roles, external systems and abuse paths. *Reopens when:* field use shows
      high-security content scattering incoherently across specs — that recurrence is the
      trigger, not a fresh opinion.
- [x] **P5 light — stable AC-/SEC-IDs in the story and plan templates.** **Shipped in
      0.15.0 (PR #40, 2026-10-04).** Was in progress on 2026-10-04: `docs/superpowers/stories/2026-10-04-stable-acceptance-criterion-ids-story.md`
      (one `AC-<n>` sequence, no `SEC-<n>`; the kit ships no plan template, so plans cite the IDs). Identifiers
      that survive from story to plan to review, so an acceptance criterion can be cited
      instead of re-described. *Trigger: the first story that runs under profiles* — the
      IDs exist to label what profiles produce, so the numbering scheme should meet a real
      profiled story before it gets a template slot.
      **2026-10-03:** ordering group G1 (above) adds G1b, an `AC-ID → evidence → result →
      revision` view, on top of these IDs. The trigger above is unchanged.
      **2026-10-03 (Daniel, on `.context/sparring/20261003-152014-post-pr35-p5-next-step-assessment.md`):
      trigger met — profiled stories have run (the 2c parts). Ready for intake, scope the IDs
      only: G1b and vision leaf 4e are not activated by it. It is not started in parallel with
      2c part 3; after part 3 it is ranked against part 4.**

- [ ] **This repository's `.claude/review-gates.md` still says its rules bind over the text
      a project's `CLAUDE.md` contains.** Found while splitting the `/workflow-init`
      template (0.16.0), which corrects the same sentence in the scaffolded copy; PR #38
      moved this repository's copy without it, and the repository's own rules files were
      out of that change's scope. *Trigger:* the next change to this repository's
      `.claude/review-gates.md`.
- [ ] **Re-verify invariant 8's `${CLAUDE_PLUGIN_ROOT}` claim.** As of 2026-10-04 the Claude
      Code plugin reference says the variable expands in skill, command and agent markdown;
      AGENTS.md invariant 8 and `docs/architecture.md` say it does not (verified earlier).
      Inline templates stay right either way; the stated reason may be stale. *Trigger:* the
      next change to invariant 8 or the template layout.
- [x] **Gate-rule storage within the instruction-size limit.** **Shipped in 0.16.0 (PR #41,
      2026-10-04):** a scaffolded `.claude/review-gates.md` (Daniel chose the file over a
      skill), check 4e and the migration. Shrinking §5 stays open (below). The rest of this
      entry is the state when it was recorded: Claude Code limits the
      always-loaded instruction files to 150.0k characters; this repository measured 151.2k
      on `main` at `b18e7db`, almost all of it CLAUDE.md §5, and `/workflow-init` scaffolded
      §5 inline into every project. Story:
      `docs/superpowers/stories/2026-10-04-gate-rule-storage-story.md` — profile risk `high`,
      security `none` (Daniel, 2026-10-04). **Ranked (Daniel, 2026-10-04): right after P5
      light, before 2c part 4** (vision §7, interposed leaf). Open then, all since decided
      by PR #41: file vs. shipped skill
      vs. short core (Daniel leans to the skill, once reliable loading is shown), how the
      hook names what to load, heading grep vs. `.context/codex-gate.on`, the size budget,
      and how PR #38 (`split-review-gates`, this repository only) relates. Shrinking §5 is
      a separate, later, high-risk step. *Trigger:* P5 light merged.

- [ ] **`/workflow-init` preflight checks `CLAUDE_CODE_MCP_AUTO_BACKGROUND_MS`.** The
      variable keeps a >120 s gate call in the foreground so its result reaches the hook.
      **The failure mode this row originally described was fixed in 0.8.0** — a
      backgrounded call carrying the recognized harness notice is now discarded, not
      counted. What the variable still buys is the residual the CHANGELOG names as C1:
      the notice is recognized *in the wording it currently uses*, so if that harness
      prose ever changes the call is counted fail-open instead, with a disclosure. The
      variable prevents the situation; the hook only recognizes today's spelling of it.
      The result-classification story documents it in `README.md` § Setup only,
      deliberately — a preflight check is a second surface and was kept out of that diff.
      **OBSERVATION (2026-08-04), and the row stays open.** With the variable set to `0`, five
      Gate-A passes of the 2026-08-03 round ran 458 s, 550 s, 757 s, 663 s and 780 s; all five
      stayed in the foreground and returned ordinary `success: true` envelopes the hook could
      read. **No control run was made** with the variable unset, so this is a correlation
      observed under one setting, not a demonstration that the variable held those calls in the
      foreground. What it does establish is that calls well past 120 s can return as ordinary
      foreground results here. The row's deliverable — a `/workflow-init` preflight check — is
      unbuilt, so the row is not discharged by this.
      **SECOND INDEPENDENT FIELD EVIDENCE (2026-08-17) — the row is ripe.** A second consumer,
      `infinite-portfolio-canvas`, discovered the variable by measurement rather than from
      `README.md`: six real `mcp__codex__review` passes (57 findings, pass 6 clean on the
      quality branch) were each auto-backgrounded past 120 s, none reached the hook, and the
      closing commit drew a STOP against a structurally zero counter. Setting the variable to
      `0` in `~/.claude/settings.json`'s `env` block fixed counting on the following cycles (5
      counted passes, then 24). **What the variable buys, separated, because this row previously
      blurred them:** it keeps a long *successful* call in the foreground so its result reaches
      the hook and is counted at all — the 0 → 5 → 24 progression is that effect — **and**
      separately it removes dependence on C1's residual, the hook recognizing today's wording of
      the harness notice. Both are real; neither is the other.
      **What this evidence does not show:** a documentation gap. `README.md` § Setup step 2b
      already documents the variable, its version requirement, that it is read at process start,
      the launch-environment caveat, both usable values and both outcomes — so the honest reading
      is that the shipped documentation did not reach an operator who then spent four dated
      measurement rounds rediscovering it, which is an argument for the **preflight check** this
      row's deliverable already is, not for more prose. No control run with the variable unset was
      made in that repo either.
      Evidence: `docs/field-reports/2026-08-16-canvas-a1-a5-field-report.md` item 4 and that
      repo's `todos.md` § Tooling revalidation.
      *Trigger: after that story lands* (spec:
      `docs/superpowers/specs/2026-07-31-failed-codex-call-counts-as-a-pass-design.md`).

- [ ] **Upstream-report candidate: `claude plugin update <bare-name>`.** The CLI docs
      document the bare plugin name as a valid argument for `install`/`uninstall`/`update`
      alike, but `claude plugin update dev-workflow` errors "Plugin 'dev-workflow' not
      found" on CLI 2.1.x while `dev-workflow@dev-workflow-kit` works. README documents
      the qualified form as a workaround; file via `/feedback` so the behaviour and the
      docs stop disagreeing.

- [ ] **Upstream-report candidate: `mcp-codex-dev` error envelopes swallow the reason.** A
      failed gate call returns `success: false` with no `error.code`, so neither the operator
      nor the hook can tell an exhausted quota from a server defect; the cause is findable only
      in `~/.codex/sessions/<Y>/<M>/<D>/rollout-*.jsonl` under `rate_limits`. Three confirmed
      instances, all from `infinite-portfolio-canvas`'s memory note
      `codex-empty-envelope-means-credits` (2026-08-15/16), verified there this round:
      (1) an empty `success: false` envelope with no code while `mcp__codex__health` still
      reported `ok: true` — the rollout log carried `credits.balance: "0"`,
      `has_credits: false`, `codex_error_info: "usage_limit_exceeded"`; it read as a server
      defect, and an A5/T2b Gate-B cycle was abandoned after nine passes with the cause open;
      (2) the OpenRouter route, the same wall in another shape — `success: false` carrying
      progress prose in the `review` field, `unexpected status 402 Payment Required:
      Insufficient credits`, `codex_error_info: "other"`;
      (3) a `success: true` envelope carrying only progress prose and no answer line, i.e. an
      incomplete pass wearing a success envelope.
      **The upstream ask is the report's own and is not widened here:** carry the credit or quota
      reason in the envelope — `NO_CREDITS` and friends — which covers instances (1) and (2).
      **Instance (3) is recorded as a limitation of that ask, not as a second proposal**, because
      the report asked for a failure reason on a `success: false` envelope and a `success: true`
      one is a different shape that a credit code cannot reach; the report also says to add
      nothing beyond its list. What the evidence supports about (3) is only what was seen: one
      degeneration emitted `task_complete` with no error and produced no file, and one silent
      death emitted no `task_complete` at all — so `task_complete` alone did not separate a
      finished pass from an abandoned one in those cases. Whether any combination of artifact,
      answer line and log growth is necessary or sufficient was not established, and this row
      does not claim it.
      Kit-side relevance: the hook's `failure` class can see *that* a gate call failed and never
      *why*, which is the same "no error code surfaced (unclassified)" shape this repo met in
      0.8.x use. **Deliberately not fixed here** — both are fields in the server's envelope; file
      them against `mcp-codex-dev`, which is Daniel's own server, not this repo's scope.

## Someday

- [ ] **P1 — `workflow-status` → `workflow-next`, staged.** Report where a story stands
      first; only once that read is reliably right does it get to recommend the next
      step. Staged deliberately: a "next" that is wrong is worse than no command at all,
      because it is followed. *Trigger: 3–5 real stories completed in a product project*
      — fewer than that and the state machine would be modelled on this repo's own
      atypical usage.
      **2026-10-03:** ordering group G1 (in Next) records G1c, the status read's output
      shape, which the live view renders. The staging and the trigger above are unchanged.
- [ ] **Generated status HTML — task, progress and KPI views.** Direction agreed
      with Daniel on 2026-09-17: keep Markdown as the authored source and generate
      HTML views, with source links, revision and freshness visible. Define item
      identity and explicit status; parked, rejected and completed work must not
      be reduced to a raw checkbox completion percentage. A labelled static
      snapshot may precede live telemetry. Owner/scope is the dashboard leaf to
      be defined in `docs/superpowers/specs/2026-08-30-dark-factory-vision.md`
      §§4/11; this does not activate P1 or decide the future pool's storage.
      *Trigger: Daniel explicitly selects the dashboard story for design.*
      Recording this direction does not authorize implementation.
      **SFX field input (2026-09-17):** expose installed/observed-loaded workflow
      versions and local rule revision; bind status and evidence to their own
      revisions instead of treating an older handover as current verification.
      **2026-10-05:** the vision adds two content requirements (§4): human-attention
      metrics, measured by 2c, and the decision-oriented inbox. It also proposes an owner
      (§11): a static snapshot after 2c part 4, then the live view after 5a. The trigger
      above is unchanged.
- [ ] **Review-loop usefulness — metrics, scoring and calibrated thresholds.**
      Requirement recorded with Daniel on 2026-09-17; owned by vision step 2c,
      presented in the dashboard. Define confirmed distinct finding yield,
      recurrence/repair effects, effort and coverage evidence; start with
      separate indicators and an explained traffic light. Before implementation,
      specify data sources, deduplication, comparison windows, missing-data
      handling, thresholds and any composite weights, and evaluate them against
      recorded cycles. **Priority principle agreed 2026-09-17:** the more indirect
      the evidenced product impact, the earlier further review effort must be
      reassessed. Define lower warning/escalation thresholds for repeated plan
      instrument work with unsubstantiated marginal benefit, not lower severity
      by file type. Track instrument time/rounds, evidenced benefit and observable
      delay to product work. Include §4's calibration cases; preserve the severity
      of defects that invalidate product verification. This does not activate the
      experimental one-round cap parked above.
      **SFX field input (2026-09-17):** separate finding origin, consequence and
      effort; record optional Minor/Nit repair scope and attribution confidence.
      Instrument classification follows actual effects on product files/state.
      Counts independently recounted; causal attribution and test outcomes remain
      reported. Evidence and calibration limits:
      `docs/field-reports/2026-09-17-sfx-review-loop-economics.md`.
      Unknown evidence must remain visible. Recommendations
      may support continuing, changing method or stopping to surface; they do
      not waive floors, mandatory tells or closure conditions. P8 remains passive
      and supplies only the evidence it has. Details and unresolved decisions:
      `docs/superpowers/specs/2026-08-30-dark-factory-vision.md` §§4/7/11.
      *Trigger: step 2c is explicitly picked up for design.* No thresholds are
      activated by this entry; automatic actions require separate authorization.
      **2026-10-03 (PR #35 review):** `scripts/run-analytics.py` reads commit history for
      attribution without `--no-replace-objects` or an empty graft file, so a `git replace` ref
      or a legacy graft can change which provenance lines it reads. `scripts/ledger-metrics.py`
      and `scripts/loop-usefulness.py` already guard against this. Fix it when run-analytics is
      next touched. Pre-existing, small, and outside PR #35's diff.
      **2026-10-03 (PR #35 review, Daniel):** `scripts/loop-usefulness.py` counts any
      non-test `plugins/*/hooks/*.sh` as product (spec §4), even one `hooks.json` does not
      register. Today the only hook script, `codex-gate.sh`, is registered, so no result
      changes. Read the registrations from `hooks.json` when a second hook script appears.
      **2026-10-03:** 2c part 2 delivers only a warning light (reassess effort; no
      green, no usefulness verdict). Confirmed distinct yield, repair origin,
      reviewed coverage and "was it worth it" remain open in this row.
      **2026-10-05 (recommendation, vision §7):** in part 4, keep live effort measurement
      apart from any change to pass validity. A short or cheap review is not, on its own,
      evidence of an incomplete one. Whether part 4 splits is Daniel's decision.
      **2026-10-05 (Daniel): split.** Part 4a, live effort counters
      (`scripts/live-effort.py`), measures only. Part 4b, the minimum-cost INCOMPLETE signal, waits
      for calibration data and keeps its risk-high profile.
- [ ] **P7 — `workflow-doctor`, extracted from the `/workflow-init` preflight.** Not a
      second implementation of the same checks: the point is a **single shared check
      source** that both the initializer and the doctor call, or the two drift and the
      doctor starts blessing setups init would reject. *Trigger: the next setup incident,
      or before the second project init* — whichever comes first; the second init is
      where a divergence would first cost someone real time.
- [ ] **P8 — passive metrics, read-only over the ledger and git.** Analysis only: no new
      state file, no instrumentation, nothing written back. It answers questions the
      ledger already contains the data for (which fingerprints recur, how often a rung
      holds).
      **TRIGGER FIRED (2026-08-04):** the 2026-08-03 hardening round appended four ledger rows,
      taking the ledger from 18 to 22 and crossing the 20-row arm; its fifth story takes the
      story count to 10, crossing the other arm as well. Story:
      `docs/superpowers/stories/2026-08-04-passive-metrics-over-the-ledger-story.md`, which
      carries this row's conditions with each marked kept, moved or dropped.
      *Trigger: 10 stories or 20 ledger rows* — below that the sample says more
      about the last week than about the workflow.
- [x] **`/capture-finding` as an intake extension of `harden-finding`.** **CLOSED 2026-08-17 —
      folded into the Finding A story, which is now the single owner of the finding-to-ledger
      route.** The trigger fired exactly as written: the canvas A1–A5 field report
      (`docs/field-reports/2026-08-16-canvas-a1-a5-field-report.md`) is a production finding set
      arriving from real use rather than from a gate or a bot. It fired **and answered itself
      negatively**: eleven items were routed by hand through `dev-workflow:intake`, `todos.md`
      rows, one upstream note and one reasoned rejection, and capture was never the part that
      hurt. What did hurt is durability and reach — a fixed finding surviving a compaction or a
      handoff, and a project that never opens PRs never reaching `process-pr-review` step 5 —
      and both of those already belong to Finding A. A second command on that route is how the
      ledger acquires two formats, which is this row's own stated reason for existing as an
      extension; the honest conclusion is that the extension point is Finding A's design, not a
      command of its own.

## Tooling revalidation
- [ ] Re-check `docs/prompt-standards.md` against the current model-specific
      prompting pages on every model-generation change (new Claude model in Claude
      Code, new Codex model for the gates). Include `docs/sparring-briefing.md` in
      that pass — it is a prompt artifact for the upstream advisor chat, and a
      model change on either side of it (sparring model or coding agent) can shift
      what its conventions should say. Concretely pending: the switch of the
      coding agent to the new Opus generation fires this row.
- [x] **Ad-hoc-brief paragraph synced into the scaffolded template.** Done in the
      canvas-findings round's PR 2, the vehicle this row named. Not the verbatim repo
      paragraph, which turned out to be unportable: it links `docs/sparring-briefing.md`
      (never scaffolded) and asserts this repo's own incident count. The template carries
      a downstream-neutral variant preserving both halves of the principle — briefs carry
      the checklist's habits, and nobody reviews a brief against all 12 items.
- [x] **Prompt-standards conformance checker — resolved the two `pending` ledger rows
      (2026-07-25).** Landed as checks 4a and 4b in `scripts/check-invariants.sh`, with
      fixtures in its regression suite, in the canvas-findings round's **PR 1**. (No
      fixture count is quoted here on purpose: an earlier draft said "42", the Gate-B
      fixes took it past that, and a hard-coded total at a doc site describing this
      checker is the very drift class the checker exists for.) Both `pending`
      rows were resolved by appending rung-2 rows dated 2026-07-26, never edited. Each
      new row states the exact spelling its check guards and what stays
      instruction-backed. Two things turned out differently than this entry assumed:
      word forms had to be in scope, because the motivating `docs-drift` occurrence
      spelled its count as a **word** rather than a digit, and a digit-only check would
      have missed it entirely. (The exact phrase is deliberately not quoted here: check
      4b reads a live count claim in any scanned `*.md`, and it caught this very entry
      when it was first written. The ledger may quote it because the ledger is excluded;
      editable prose should reword instead.) And the
      ledger itself had to be **excluded** from both checks, because a ledger that
      quotes defects self-rejects the checks that detect them.
- [ ] **Each Gate cycle destroys the previous cycle's review record.** Slot names
      (`gate-a-spec-pass-<p>`, `gate-b-<branch>-pass-<p>`) carry no cycle-unique component,
      and §5 mandates deleting every target file before each call — correctly, since a
      surviving prior file is indistinguishable from a fresh one. The consequence is that a
      second cycle in the same repo silently erases the first cycle's findings artifacts.
      **Observed, not theorised:** the result-classification cycle's pass-1 call deleted the
      2026-07-26 profiles cycle's 11 KB `gate-a-spec-pass-1.md`. `.context/` was git-ignored,
      so that file is unrecoverable. **Partly mitigated 2026-09-10:** `.context/codex-reviews/`
      is tracked in this repo, so a slot overwritten after a commit is now recoverable from git
      — the destroy-before-delete window between two commits is not, and target projects still
      ignore the path, so the row stands. §5 anticipates *concurrent* calls racing on one slot and says
      so; it does not cover *sequential cycles* reusing them. Note the dispositions and
      resume-note companions have the same property. Any fix has to keep the pre-call delete
      — that check is load-bearing — so it is about naming (a cycle component in the slot) or
      archiving, not about relaxing the protocol.
      **NOT FIRED (2026-08-04):** the 2026-08-03 hardening round edits §5 prose and its template
      mirror, and changes no part of the §5 **file protocol** this row's trigger names — not the
      slot names, not the pre-call delete, not the terminator or acceptance rules. Recorded so a
      later reader can check the reading rather than re-derive it.
      **SECOND OCCURRENCE, TRIGGER FIRED (2026-08-16).** The reviewer-availability story's
      cycles destroyed a predecessor's findings file **and** its dispositions before the
      surviving 44 artifacts were archived by hand. That is the second observed destruction,
      after the 2026-07-26 profiles cycle. **The row stays open** — the fix is still naming (a
      cycle component in the slot) or archiving, never relaxing the pre-call delete, which is
      load-bearing.
      *Trigger: FIRED. Was: the next round touching the §5 file protocol.*

- [ ] **Attribution for the human-exception record form.** The `<handle>` in a
      `Human exception:` record is unverified, and §5 says so in the shipped text: nothing
      checks that it belongs to whoever decided, that a human was asked, or that the reason is
      honest. Hardening for what ships; needs no availability attestation.
      *Trigger: the first record whose authorship is disputed or unattributable.*
- [ ] **External-authority zero-pass research.** A signed commit or a protected-branch
      approval is the one design class the reviewer-availability cycles never tried, and its
      requirements are already named: a **trusted signer identity** *and* a **role policy**
      saying which identities may approve — an ordinary signer can be the author — plus an
      **availability attestation from a party that is not the author**, which neither mechanism
      supplies on its own. It is one untried direction worth reconsidering, **not** the only one
      that could work; the design space was never exhausted
      (`docs/superpowers/specs/2026-08-14-reviewer-availability-fallback-design.md` §1.5).
      *Trigger: a renewed need to close a gate cycle with no review — a second multi-day
      reviewer outage, or the operational bridges of that design's §7 proving unavailable.*
- [ ] **Tracked re-review debt.** The human-exception form records a decision and creates no
      follow-up obligation, so "the re-review never happened" is not an observable event today.
      Stated as one deliberately.
      *Trigger: a human explicitly asks for follow-up review on a recorded exception and that
      follow-up is later found not to have happened.*
- [ ] **A recording mechanism for severity normalization.** Rider (b) normalizes an
      unrecognized severity token to `MAJOR` and records nothing. The drift is visible to the
      reader at the moment the pass is validated — the findings file carries the original token
      on the finding line — but nothing is durable *in a target project*: `.context/` is
      git-ignored there and slot collisions have destroyed findings here (row above). In this
      repo `.context/codex-reviews/` is tracked from 2026-09-10, which makes the original token
      recoverable here and nowhere else. A companion record was designed and
      **cut**, at a measured cost: it needed a token-identity rule, a bijection audit, a
      logical-pass/attempt/credited-count identity model, edits to four shipped hook reminder
      strings, and a `docs/hardening-log.md` supersession row.
      *Trigger: a pass is normalized and the drift goes unnoticed in review.*
- [ ] **The hook's `is_docs_only` exempts any `.md` path outside a prompt directory**, which is
      broader than §5's prose list (`docs/**.md`, `README.md`, `MANIFEST.md`). Found while
      siting a removed debt store.
      *Trigger: a root `.md` file acquiring gate-relevant state.*
- [ ] **Tier-2 counting and containment.** A same-family reviewer whose passes are worth
      counting, per `docs/superpowers/stories/2026-08-14-tier-2-same-family-reviewer-story.md`.
      The unchanged hook counts each call as a pass, so counting is part of the problem, not a
      detail of it.
      *Trigger: the tier-2 story being picked up, or a second multi-day reviewer outage.*
- [ ] **Finding B — a §5 version stamp, so a scaffolded CLAUDE.md can tell it lags the
      installed plugin.** Split out of the canvas-findings round after two Gate-A passes
      showed it is a design, not a sentence. Spec questions: a semantic §5 locator
      (`/workflow-init` may append the section renumbered, so "no §5 heading" can misread
      a valid section and append a duplicate); per-state merge semantics (invariant 9
      forbids a silent overwrite, and "re-run init to sync" promises what the command
      cannot give); stamp cardinality (absent, duplicate, malformed); and a binding real
      on **every** push path — the version-bump coupling first proposed was false, since
      invariant 12's checker is `pull_request`-only. A stamp is a **wire format**:
      shipping a provisional one writes legacy into every scaffolded file. *The one
      known-stale instance (canvas) is being re-synced by hand, so this carries no
      schedule pressure.*
      **TRIGGER FIRED (2026-08-04):** the 2026-08-03 hardening round edits the §5 inline
      template. Story:
      `docs/superpowers/stories/2026-08-04-section-5-version-stamp-story.md`, which carries this
      row's conditions with each marked kept, moved or dropped.
      *Trigger: the next round that touches the §5 template.*
- [ ] **`harden-finding`'s recurrence rule is scope-blind.** Rungs guard *scopes*; the
      skill's recurrence step *does* re-read the ledger, and the defect is that its
      **decision branch** keys on the fingerprint and the latest matching row's rung
      without letting that row's stated guard control the verdict. Sketched fix — before proposing
      escalation on a same-fingerprint recurrence, read the prior row's stated guard:
      **outside** it the prior mechanism never claimed that shape, so its rung did not
      fail — pick the fitting rung, do **not** escalate; **inside** it, the mechanism was
      meant to catch this and did not, so that is a regression to repair or strengthen.
      (An earlier draft had those branches inverted, which would have entrenched the bug
      it was filed against; Gate A caught it.)
      **Evidence case 3 (2026-08-04):** the 2026-08-03 hardening round ran the precheck as a
      standing manual instruction from Daniel — which is this row's own diagnosis, since a rule
      that exists only in chat is not one the skill carries — and still reached a wrong verdict
      twice by reading a single prior row's guard and stopping. Split to
      `docs/superpowers/stories/2026-08-04-harden-finding-guard-scope-precheck-story.md`; this
      row stays open because the fix it sketches has not landed.
      *Trigger: the first human rejection of an
      over-escalation the 2026-07-26 rows predicted, or the next round touching the skill.*
- [ ] **Finding A — a route from a fixed finding to the ledger for projects that never
      open PRs.** The only mandated ledger check lives in `process-pr-review` step 5, so a
      no-PR project never reaches it: canvas has 51 Gate-A pass files and **0** ledger
      rows. Cut from the canvas-findings round after drawing a Major on all five Gate-A
      passes; those findings are the story's opening evidence rather than a blank page:
      it cannot rest on same-session memory, because a compaction, interruption or handoff
      loses the fixed-finding set and **nothing detects the loss**; its scope must match
      `process-pr-review` step 5 *exactly* — check every accepted actionable fixed
      finding, but invoke `harden-finding` only when a class matches or a new one is
      clearly warranted, which every approximating draft got wrong; and a durable handoff
      needs real design (identity, dedup, consumption semantics), which is why it was
      refused as a mid-round addition. It mints
      `mandatory-step-anchored-to-optional-path` when it lands — minting it earlier would
      leave a class no row uses.
      **TRIGGER FIRED (2026-08-04):** the 2026-08-03 hardening round edits §5. Story:
      `docs/superpowers/stories/2026-08-04-ledger-route-without-pull-requests-story.md`, which
      carries this row's conditions with each marked kept, moved or dropped.
      **INHERITED 2026-08-17: this story is now the single owner of the finding-to-ledger
      route.** The `/capture-finding` row in § Someday closed into it after its own trigger
      fired and answered negatively — manual capture of eleven field findings worked, so the gap
      is durability across a compaction or handoff and reach into no-PR projects, both of which
      are already this story's scope. What it inherits is one constraint, not new scope: whatever
      route it designs is the **only** one, because a second capture entry point is how the
      ledger acquires two formats.
      *Trigger: the next round that touches §5, or a project
      reporting an empty ledger across cycles that fixed findings.*
- [ ] **Escalation trigger for the invariant checker — read this before patching it.**
      The checker asserts only the spellings its fixtures cover. Adding one more regex
      arm per newly-discovered spelling is *not* the ladder working; it is the same
      rung applied repeatedly. **If a fifth unhandled spelling turns up in the wild,
      that is the recurrence**, and the answer is a real YAML/shell parse logged as the
      next rung — not another patch. Anticipating that today would be escalating
      without recurrence, which the ladder exists to prevent. Count so far: the
      spellings found during development were fixed as part of building the rung and
      do not count toward the five.
- [ ] **Invariant checker does not see Docker images outside a `docker://` action ref.**
      `FROM alpine:latest` in a Dockerfile and `docker run alpine` in a script are
      executable dependencies that invariant 5 covers, but every Docker rule is
      downstream of the action-ref scan, so neither is looked at. Raised by CodeRabbit on
      PR #2. Deferred rather than fixed there because it is a new surface (Dockerfiles,
      shell `docker run`), not a gap in a spelling the checker already claims — and
      the ledger ref is worded to claim only the latter. Needs its own reject/accept
      fixtures. Part of that story: `ci.yml`'s `koalaman/shellcheck:v0.11.0` is
      tag-pinned by luck, not by the gate — a tag can be repointed, so digest-pinning
      it belongs to whoever takes the Docker surface on.

## From PR #26 — backlog only, nothing implemented here

- **Both-branches-misread-each-other.** `mcp__codex__review` with `reviewType: full` runs two
  reviewers in parallel from one call. §5's file protocol keeps them from racing on a single
  path, but never tells either that the other exists — so on PR #26's Gate-B pass 2 each read
  its counterpart's legitimate findings file as a foreign write and reported the other branch
  `INCOMPLETE`. Both files were structurally valid; the pass was discounted anyway, because an
  `INCOMPLETE` reply is an incomplete pass by rule. One line of `additionalContext` fixed it
  and it did not recur across three further passes. **Backlog:** ship that line as standing
  prompt text in §5's Gate-B section and the scaffolded template, so it is not rediscovered per
  cycle. Record: `docs/field-reports/2026-08-30-gate-a-rle-plan-cycles.md`.

- **The self-consuming deletion — `prompt-standards.md` item 11 amendment.** Item 11 says to
  delete a claim about a mechanism after a fourth correction rather than refine it a fifth
  time. It does not say what happens to the *rationale* for the deletion — and on PR #26 that
  rationale was itself a description of the mechanism (the tested NUL counter-example), so it
  fell to the same rule. There is no version of that paragraph that survives its own rule. The
  explanation was moved to a field report, where describing the hook is the point rather than
  a claim the product makes. **Backlog:** amend item 11 to say the deletion takes its rationale
  with it, and name the field report as the rationale's home.

- **Valid findings from PR #26 recorded as out of scope** (per `process-pr-review` item 2 —
  pre-existing and larger than the code this PR touches, so terminal there, not hardened):
  - `docs/superpowers/plans/2026-08-29-review-loop-economics.md` is the **superseded**
    single-plan artifact. CodeRabbit found two real defects in it — an impossible cycle
    classification across Tasks 1–9, and `git commit --amend --no-edit` in Tasks 2–5, which
    the hook does not recognize as a WIP amend and which therefore resets the cycle. Both are
    true. The file is recorded as history and is not executed; marking superseded artifacts in
    place is a convention gap this repo already owns and defers.
  - `docs/superpowers/plans/2026-08-30-review-loop-economics-plan-c1-user-docs.md` — commands
    whose output is tested do not check status, so a failed `git diff` with empty output can
    select "ALREADY APPLIED AND COMMITTED". True, and C1 was dissolved into the rollout on
    2026-09-01 without being executed. Fix it if C1 is ever revived.

## From PR #38 — backlog only, nothing implemented here

- **Valid findings from PR #38 recorded as out of scope** (per `process-pr-review` item 2 —
  pre-existing §5 text, only moved by #38; each holds in both copies, `.claude/review-gates.md`
  and the `/workflow-init` template, so a fix in one copy alone would make them disagree):
  - **Gate-B story-set comparison contradicts the union rule** (CodeRabbit). §5 defines the
    Gate-B governing header as the *union* of the contributing plans' `Story:` headers, then
    requires every expected artifact's set to be equal and stops on any difference. Two plans
    citing different stories therefore always stop. Decide whether the comparison should
    apply to the union only, then fix both copies.
  - **The finding-format example mixes both file shapes** (CodeRabbit). The Gate-A paragraph's
    code block shows a `MAJOR` line followed by `NO FINDINGS`, while a valid file carries
    `NO FINDINGS` only as its sole body line. Show the two shapes as separate examples.
