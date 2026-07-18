# Todos — dev-workflow-kit

Backlog of stories, follow-ups, and prerequisites referenced by
`docs/hardening-log.md` (`pending` rows point here by `ref`).

## Now
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
