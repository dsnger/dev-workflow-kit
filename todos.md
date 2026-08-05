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
- [ ] **The hardening ledger has no supersession convention.** `docs/hardening-log.md`'s
      header says never edit a row, and one row per hardening — so when a row's "what this
      does NOT do" narration is later falsified by a feature change, there is no sanctioned
      move: editing breaks the first rule and appending breaks the second. The 2026-07-20
      row now describes pre-0.8.0 counting behaviour as current. The 2026-07-20 *spec* took
      a version-qualified supersession note and that worked; the ledger needs the same
      convention written into its header, or an explicit "rows are historical, read the
      newest row for current behaviour" statement.
      **TRIGGER FIRED (2026-08-04):** the 2026-07-20 row now teaches pre-0.8.0 counting
      behaviour as current — the second falsified row this trigger names. Story:
      `docs/superpowers/stories/2026-08-04-hardening-ledger-supersession-story.md`.
      *Trigger: the next row falsified by a
      later change — this is the second.*
- [ ] **Locator selects the `text` element by RAW BYTE comparison of `type`.** A
      Unicode-escaped spelling of `text` is legal JSON meaning `text` and is not selected;
      with no other element the class is `no-result` (fail-closed, so discarded rather than
      miscounted, but still a wrong verdict on a legal payload). Same for escaped spellings
      of the `type`/`text` keys. Characterized by a regression row and stated in spec §3.1;
      closing it means decoding the `type` value for equality while still returning the
      selected `text` in its original escaped bytes, since the matcher depends on those.
      *Trigger: a serializer observed emitting escaped key or type spellings.*

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
- [ ] **P5 light — stable AC-/SEC-IDs in the story and plan templates.** Identifiers
      that survive from story to plan to review, so an acceptance criterion can be cited
      instead of re-described. *Trigger: the first story that runs under profiles* — the
      IDs exist to label what profiles produce, so the numbering scheme should meet a real
      profiled story before it gets a template slot.

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
      *Trigger: after that story lands* (spec:
      `docs/superpowers/specs/2026-07-31-failed-codex-call-counts-as-a-pass-design.md`).

- [ ] **Upstream-report candidate: `claude plugin update <bare-name>`.** The CLI docs
      document the bare plugin name as a valid argument for `install`/`uninstall`/`update`
      alike, but `claude plugin update dev-workflow` errors "Plugin 'dev-workflow' not
      found" on CLI 2.1.x while `dev-workflow@dev-workflow-kit` works. README documents
      the qualified form as a workaround; file via `/feedback` so the behaviour and the
      docs stop disagreeing.

## Someday

- [ ] **P1 — `workflow-status` → `workflow-next`, staged.** Report where a story stands
      first; only once that read is reliably right does it get to recommend the next
      step. Staged deliberately: a "next" that is wrong is worse than no command at all,
      because it is followed. *Trigger: 3–5 real stories completed in a product project*
      — fewer than that and the state machine would be modelled on this repo's own
      atypical usage.
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
- [ ] **`/capture-finding` as an intake extension of `harden-finding`.** An extension,
      not a sibling command: a finding captured outside the ladder is how a ledger
      quietly acquires two formats. *Trigger: the first production finding* — one that
      arrives from real use rather than from a gate or a bot.

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
      2026-07-26 profiles cycle's 11 KB `gate-a-spec-pass-1.md`. `.context/` is git-ignored,
      so it is unrecoverable. §5 anticipates *concurrent* calls racing on one slot and says
      so; it does not cover *sequential cycles* reusing them. Note the dispositions and
      resume-note companions have the same property. Any fix has to keep the pre-call delete
      — that check is load-bearing — so it is about naming (a cycle component in the slot) or
      archiving, not about relaxing the protocol.
      **NOT FIRED (2026-08-04):** the 2026-08-03 hardening round edits §5 prose and its template
      mirror, and changes no part of the §5 **file protocol** this row's trigger names — not the
      slot names, not the pre-call delete, not the terminator or acceptance rules. Recorded so a
      later reader can check the reading rather than re-derive it.
      *Trigger: the next round touching the §5
      file protocol.*
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
