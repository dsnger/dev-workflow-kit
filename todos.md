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

- [ ] **A failed Codex call counts as a pass — false ✓ in the firing direction.**
      Derived while writing the 0.5.1 file-first protocol (PR #9), from a Gate-B finding
      that corrected the opposite belief. The chain, each link checked against source
      rather than inferred: the pinned `mcp-codex-dev@1.0.1` **catches** its own
      exceptions — executor timeouts and aborts included — and *returns*
      `{success: false, …}` as an ordinary result, without throwing and without setting
      `isError` (`dist/tools/codex-review.js`, `codex-exec.js`). Claude Code therefore
      classifies it as a **successful** tool call, so `PostToolUse` fires rather than
      `PostToolUseFailure`. The hook's `PostToolUse` branch inspects nothing about the
      result: for `$review_tool` it computes `tree_hash`, **stores that fingerprint**,
      bumps the cycle counter unconditionally, and sets the fresh-streak counter to 0
      (fingerprint unavailable), 1 (fingerprint changed) or its prior value plus one
      (fingerprint unchanged) — the streak is not a second cumulative counter; for
      `$exec_tool` it bumps `countA` unconditionally.
      Consequence: three timed-out Gate-A calls satisfy the Gate-A floor, and one
      timed-out Gate-B call stores a current-content fingerprint for a review that read
      nothing — the satisfied message then reports a fresh pass covering exactly the
      content nobody reviewed. That is a false ✓ in the hook's recorded state, the
      direction invariant 2 calls dangerous.
      *What the shipped 0.5.1 prompts already do about it, stated so nobody over-scopes
      the fix:* they classify a timeout or abort as an incomplete pass, require every
      incomplete pass to be discounted **regardless of what the counter says**, and allow
      one recovery attempt. So the residual defect is not "no mitigation exists" — an
      earlier draft of this row claimed that and contradicted text shipped in the same
      PR — it is that the mitigation is instruction-backed and depends on the agent
      noticing and obeying the failed result, while the hook's own state is wrong either
      way and stays wrong for anyone reading it later.
      *Candidate fix, explicitly unverified:* skip the bump and the fingerprint store
      when the result reports failure. The `PostToolUse` payload is documented to carry
      `tool_response`, but **what it actually contains for an MCP tool on this server is
      not established** — the hook has no `tool_response` reader at all today
      (`input_field` parses only `.tool_input`), and the one place the hook reasons about
      `tool_response` records that Bash's shape carries no exit status, which is why the
      commit-reset deliberately ignores success. Verify the real payload for
      `mcp__codex__*` before writing any matcher; a matcher built on an assumed shape
      fails silently and in the same dangerous direction. Note also that failing closed
      here is the *safe* direction for once — not counting a real pass costs a re-run,
      while counting a dead one is the false ✓.
      *Trigger: this session's discovery — already fired.* Deliberately not fixed in
      PR #9, whose scope guard is prompts and templates only; this needs hook code and
      regression tests.
- [ ] **jq-free parser stops at an escaped JSON quote.** A payload containing
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
- [ ] **Temp-index writes land in the real object database.** `git add -A` against the
      throwaway index writes loose blobs/trees into the user's repo (verified: 3 → 5
      objects per review). Unreachable, so gc collects them, but a temporary
      `GIT_OBJECT_DIRECTORY` with the real store as an alternate would avoid the churn.

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
      variable keeps a >120 s gate call in the foreground so its result reaches the hook;
      without it a long call is counted at the auto-background threshold having reviewed
      nothing. The result-classification story documents it in `README.md` § Setup only,
      deliberately — a preflight check is a second surface and was kept out of that diff.
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
      holds). *Trigger: 10 stories or 20 ledger rows* — below that the sample says more
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
      schedule pressure.* *Trigger: the next round that touches the §5 template.*
- [ ] **`harden-finding`'s recurrence rule is scope-blind.** Rungs guard *scopes*; the
      skill compares only *fingerprints*; a ledger-prose workaround is unenforceable
      because agents follow the skill, not the row. Sketched fix — before proposing
      escalation on a same-fingerprint recurrence, read the prior row's stated guard:
      **outside** it the prior mechanism never claimed that shape, so its rung did not
      fail — pick the fitting rung, do **not** escalate; **inside** it, the mechanism was
      meant to catch this and did not, so that is a regression to repair or strengthen.
      (An earlier draft had those branches inverted, which would have entrenched the bug
      it was filed against; Gate A caught it.) *Trigger: the first human rejection of an
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
      leave a class no row uses. *Trigger: the next round that touches §5, or a project
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
