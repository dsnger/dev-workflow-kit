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

- [ ] **Gate-B hash misses staged-vs-worktree divergence (false ✓, invariant 3).**
      Both hash components describe the worktree, but `git commit` commits the INDEX.
      Repro: `git add app.ts` with new content, then revert `app.ts` on disk to HEAD —
      the commit carries the staged content while the hash reads the tree as unchanged,
      so Gate B reports satisfied on unreviewed content. Pre-existing, not introduced by
      the write-tree change. Fix means hashing the index tree as a third component
      (`git rm --cached -r .context` on the temp index first, or the tracked adoption
      marker re-invalidates forever) — which also makes a bare `git add` invalidate a
      review, so the existing "add does not change the hash" test has to be re-decided.
      Own branch, own tests.
- [ ] **jq-free parser stops at an escaped JSON quote.** A payload containing
      `echo \"quoted\" && git commit -m x` decodes to nothing, so no reminder fires —
      wrong direction under invariant 2, and only on machines without `jq`. Needs
      escape-aware decoding or a conservative raw-payload scan, plus tests for escaped
      quotes and backslashes.
- [ ] **Compound commands hash the pre-mutation tree.** `printf changed > tracked.txt
      && git commit -am x` is one PreToolUse event: the hook hashes before the mutation
      runs, so the commit carries content the hash never saw. Consider treating any
      command segment preceding `git commit` as uncertain and firing.
- [ ] **No regression test for tree_hash's "tree unavailable" guard.** The guard emits
      a never-matching value when `mktemp`/`git add`/`write-tree` fails, so the gate
      reads unreviewed instead of collapsing to a constant. Testing it needs a portable
      way to make those fail on demand — `TMPDIR=/dev/null` is not one (BSD/macOS
      `mktemp` falls back to `/var/folders`, so the test would pass for the wrong
      reason). Consider a stub `git` earlier on `PATH`.
- [ ] **Temp-index writes land in the real object database.** `git add -A` against the
      throwaway index writes loose blobs/trees into the user's repo (verified: 3 → 5
      objects per review). Unreachable, so gc collects them, but a temporary
      `GIT_OBJECT_DIRECTORY` with the real store as an alternate would avoid the churn.

## Next

## Someday

## Tooling revalidation
- [ ] Re-check `docs/prompt-standards.md` against the current model-specific
      prompting pages on every model-generation change (new Claude model in Claude
      Code, new Codex model for the gates).
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
