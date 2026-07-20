# Gate-B Index-Tree Hash Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make the Gate-B hook hash what a commit will actually carry — the index — so a
staged change with a reverted worktree can no longer report "Gate B satisfied".

**Architecture:** `tree_hash()` in `plugins/dev-workflow/hooks/codex-gate.sh` gains a
third component: a tree id written from the *effective* index, taken before `git add -A`
brings the throwaway index up to the worktree. The function is also restructured so its
component stream is buffered to a file and checksummed only when every producer
succeeded; on any failure it returns the literal `unavailable`, which the comparison sites
treat as never-equal. Consumers of the value (the stale branch, the empty-state branch,
the fresh-count comparison) are updated in step.

**Tech Stack:** POSIX `sh`, `git` plumbing (`write-tree`, `rev-parse`, `symbolic-ref`),
`shellcheck` 0.11.0, the repo's own `codex-gate.test.sh` harness (bare `pass`/`fail`
helpers, no framework).

**Spec:** `docs/superpowers/specs/2026-07-19-gate-b-index-tree-design.md` (Gate A clean,
pass 15).

## Global Constraints

- **POSIX `sh` only.** No bash-isms. CI invokes the hook with `sh`. (AGENTS.md invariant 4)
- **The hook always exits 0.** No change may introduce a non-zero exit. (invariant 1)
- **`shellcheck --shell=sh` with NO exclusions** for `codex-gate.sh`. The test file keeps
  its single `--exclude=SC2015`. A `[ $? -eq 0 ]` construct is SC2181 and will fail.
- **Loose in the firing direction.** On uncertainty, fire. A false ✓ is the forbidden
  direction; a redundant warning is the accepted price. (invariant 2)
- **Prompt changes pass `docs/prompt-standards.md`** — all 12 items. Every reminder string
  in this plan is a shipped prompt. (invariant 11)
- **A plugin change requires a version bump.** Any edit under `plugins/` must bump
  `plugins/dev-workflow/.claude-plugin/plugin.json` `version` in the same PR, with a
  `CHANGELOG.md` entry. (invariant 12) — Task 5.
- **No `Co-Authored-By: Claude` / `Generated with` trailers** on any commit.
- **Quality battery** (must be green before the final commit):
  `shellcheck --shell=sh plugins/dev-workflow/hooks/codex-gate.sh && shellcheck --shell=sh --exclude=SC2015 plugins/dev-workflow/hooks/codex-gate.test.sh && sh plugins/dev-workflow/hooks/codex-gate.test.sh`

---

### Task 1: Failure contract — buffered stream, `unavailable` marker, and its consumers

The marker and the guards that read it are one contract and ship together: a marker with
unguarded consumers would let two failing invocations compare equal, which is the exact
false-✓ this story exists to close.

**Files:**
- Modify: `plugins/dev-workflow/hooks/codex-gate.sh:194-234` (the whole `tree_hash()`)
- Modify: `plugins/dev-workflow/hooks/codex-gate.sh:318-324` (PostToolUse store path)
- Modify: `plugins/dev-workflow/hooks/codex-gate.sh:397` (the stale-branch condition)
- Test: `plugins/dev-workflow/hooks/codex-gate.test.sh` (append a new section)

**Interfaces:**
- Consumes: nothing from earlier tasks.
- Produces: `tree_hash()` prints either a checksum token (`[0-9a-f]+` or `cksum` digits) or
  the literal string `unavailable`, one line, always exit 0. Task 2 adds a component
  inside it; Task 3 rewrites the messages in the branches guarded here.

- [ ] **Step 1: Write the failing tests**

Append to `plugins/dev-workflow/hooks/codex-gate.test.sh`, before the final summary block:

```sh
# 24. Failure contract: an uncomputable hash must never satisfy, and repeated failures
#     must never match each other. Spec §3 "The nonce goes away".
#     Each fault spans BOTH the stored and the recomputed fingerprint — with the fault
#     applied only at commit time, a mismatch proves nothing about the handling.
stub_dir=$(mktemp -d)
reset_all
printf '1' > "$floorf"        # floor is checked LAST; without this a faulted run
                              # reports "below floor" and the test passes vacuously

# 24a. every checksum tool fails silently (exit 0, no output)
for t in shasum sha1sum cksum; do
  printf '#!/bin/sh\nexit 0\n' > "$stub_dir/$t"; chmod +x "$stub_dir/$t"
done
PATH="$stub_dir:$PATH" rev
out=$(PATH="$stub_dir:$PATH" commitpre)
printf '%s' "$out" | grep -q 'not satisfied' && pass "silent checksum -> not satisfied" || fail "silent checksum -> not satisfied"
# Absence is asserted by inverting the RESULT, not with `grep -v` — `grep -qv` means
# "some line lacks the pattern", which is a different question and was observed to
# return 1 regardless on the dev machine.
printf '%s' "$out" | grep -qF 'no mcp__codex__review has run' \
  && fail "silent checksum -> not the never-run branch" \
  || pass "silent checksum -> not the never-run branch"

# 24b. a checksum that PRINTS a plausible token and then fails
for t in shasum sha1sum cksum; do
  printf '#!/bin/sh\nprintf "deadbeef  -\\n"\nexit 1\n' > "$stub_dir/$t"; chmod +x "$stub_dir/$t"
done
reset_all; printf '1' > "$floorf"
PATH="$stub_dir:$PATH" rev
out=$(PATH="$stub_dir:$PATH" commitpre)
printf '%s' "$out" | grep -q 'not satisfied' && pass "checksum prints then fails -> not satisfied" || fail "checksum prints then fails -> not satisfied"
[ "$(cat "$fresh" 2>/dev/null || echo 0)" = 0 ] && pass "unhashable pass leaves freshCount 0" || fail "unhashable pass leaves freshCount 0"

# 24c. seed-copy failure (stub cp) must fire, not silently hash an empty index
printf '#!/bin/sh\nexit 1\n' > "$stub_dir/cp"; chmod +x "$stub_dir/cp"
rm -f "$stub_dir/shasum" "$stub_dir/sha1sum" "$stub_dir/cksum"
reset_all; printf '1' > "$floorf"
PATH="$stub_dir:$PATH" rev
printf '%s' "$(PATH="$stub_dir:$PATH" commitpre)" | grep -q 'not satisfied' \
  && pass "seed-copy failure -> not satisfied" || fail "seed-copy failure -> not satisfied"
rm -f "$stub_dir/cp"

# 24d. a selective git wrapper that fails ONLY `diff`
cat > "$stub_dir/git" <<'STUB'
#!/bin/sh
for a in "$@"; do case "$a" in diff) exit 1 ;; esac; done
exec "$REAL_GIT" "$@"
STUB
chmod +x "$stub_dir/git"
REAL_GIT=$(command -v git); export REAL_GIT
reset_all; printf '1' > "$floorf"
PATH="$stub_dir:$PATH" rev
printf '%s' "$(PATH="$stub_dir:$PATH" commitpre)" | grep -q 'not satisfied' \
  && pass "git diff failure -> not satisfied" || fail "git diff failure -> not satisfied"

# 24e. a selective git wrapper that fails ONLY `rev-parse --absolute-git-dir`
cat > "$stub_dir/git" <<'STUB'
#!/bin/sh
case "$*" in *"--absolute-git-dir"*) exit 1 ;; esac
exec "$REAL_GIT" "$@"
STUB
chmod +x "$stub_dir/git"
reset_all; printf '1' > "$floorf"
PATH="$stub_dir:$PATH" rev
printf '%s' "$(PATH="$stub_dir:$PATH" commitpre)" | grep -q 'not satisfied' \
  && pass "unresolvable git-dir -> not satisfied" || fail "unresolvable git-dir -> not satisfied"
rm -f "$stub_dir/git"
rm -f "$floorf"
reset_all; rev; rev; rev

# 25. Unborn repo: no commits and no .git/index must still hash and self-match, or the
#     first commit in a fresh repo STOPs forever. Spec §3 "But an absent index is not a
#     failed copy".
unborn=$(mktemp -d)
(
  cd "$unborn" || exit 1
  git init -q; git config user.email t@t; git config user.name t
  mkdir -p .context; : > .context/codex-gate.on
  printf '1' > .context/codex-gate.floor      # one pass is enough for this fixture
  printf 'x\n' > a.ts
  R='{"hook_event_name":"PostToolUse","tool_name":"mcp__codex__review","tool_input":{}}'
  printf '%s' "$R" | sh "$HOOK" >/dev/null
  h1=$(cat .context/codex-gate.gateB 2>/dev/null)
  printf '%s' "$R" | sh "$HOOK" >/dev/null
  h2=$(cat .context/codex-gate.gateB 2>/dev/null)
  [ -n "$h1" ] && [ "$h1" != unavailable ] && [ "$h1" = "$h2" ] || exit 1
  # ...and the FIRST commit must actually be able to reach satisfied. Hashing and
  # self-matching is not enough: a consumer-side regression could still STOP every
  # first commit forever, which is the failure this fixture exists to catch.
  out=$(printf '%s' '{"hook_event_name":"PreToolUse","tool_name":"Bash","tool_input":{"command":"git commit --allow-empty -m init"}}' | sh "$HOOK")
  printf '%s' "$out" | grep -q 'Gate B satisfied' || exit 1
) && pass "unborn repo hashes, self-matches, and can reach satisfied" \
  || fail "unborn repo hashes, self-matches, and can reach satisfied"
rm -rf "$unborn"
```

- [ ] **Step 2: Run the tests to verify they fail**

Run: `sh plugins/dev-workflow/hooks/codex-gate.test.sh 2>&1 | grep -E '^FAIL'`
Expected: FAIL lines for `silent checksum -> not satisfied`, `checksum prints then fails
-> not satisfied`, `unhashable pass leaves freshCount 0`, `seed-copy failure -> not
satisfied`, `git diff failure -> not satisfied`, `unresolvable git-dir -> not satisfied`.
(`unborn repo hashes and self-matches` may already pass — the current code returns a
nonce-free empty-ish hash there. That is fine; it is a regression guard for Task 2.)

- [ ] **Step 3: Replace `tree_hash()` with the buffered form**

Replace `plugins/dev-workflow/hooks/codex-gate.sh:194-234` (the entire existing
`tree_hash() { … }`) with:

```sh
tree_hash() {
  ok=1
  # Same fallback order as before; no checksum tool at all is itself a failure.
  sum_cmd=$(command -v shasum || command -v sha1sum || command -v cksum) || ok=0
  # mktemp -d, not a predictable "$TMPDIR/name.$$": on a shared /tmp a predictable name
  # is a symlink target an attacker can plant.
  tmp_dir=$(mktemp -d 2>/dev/null) || { tmp_dir=''; ok=0; }
  if [ -n "$tmp_dir" ]; then
    tmp_index="$tmp_dir/index"
    # The component stream is BUFFERED and checksummed only on full success (below).
    # Printing a failure marker in-stream would checksum the marker together with the
    # partial output, so no consumer would ever see the literal `unavailable` and two
    # failing runs could produce equal hashes — the false-✓ direction.
    {
      # (0) tracked content. `git diff HEAD` is staging-independent, so it sees staged
      # and unstaged edits alike. An unborn branch is identified POSITIVELY: a bare
      # "--verify failed" also covers a corrupt or unreadable HEAD, and emitting the
      # constant `no-head` for those would self-match.
      if git -C "$repo_root" rev-parse --verify -q HEAD >/dev/null 2>&1; then
        git -C "$repo_root" diff HEAD -- . ':(exclude).context' 2>/dev/null || ok=0
      elif git -C "$repo_root" symbolic-ref -q HEAD >/dev/null 2>&1; then
        printf 'no-head\n'
      else
        ok=0
      fi

      # (1) WORKTREE tree, from a throwaway index. Task 2 adds the INDEX tree here.
      # git_dir must RESOLVE: unchecked, a failure yields "/index", which does not
      # exist, so the absent-index carve-out below would read it as "nothing staged"
      # and hand back the empty tree — a constant that matches itself.
      # The chain's status is consumed by `if` directly; a trailing `[ $? -eq 0 ]` is
      # SC2181 and the hook is linted with no exclusions.
      if git_dir=$(git -C "$repo_root" rev-parse --absolute-git-dir 2>/dev/null) &&
         [ -n "$git_dir" ] &&
         { [ ! -e "$git_dir/index" ] || cp "$git_dir/index" "$tmp_index" 2>/dev/null; } &&
         GIT_INDEX_FILE="$tmp_index" git -C "$repo_root" add -A \
           -- . ':(exclude).context' >/dev/null 2>&1 &&
         GIT_INDEX_FILE="$tmp_index" git -C "$repo_root" write-tree 2>/dev/null
      then :; else ok=0; fi
    } > "$tmp_dir/stream" 2>/dev/null || ok=0
  fi

  h=''
  if [ "$ok" -eq 1 ]; then
    # The checksum's OWN status must be seen: `cmd < file | awk` reports awk's status,
    # so a checksum failing after emitting a partial line would be stored as a real
    # fingerprint. Parse with a shell expansion — `${raw%% *}` has no exit status to mask.
    if raw=$("$sum_cmd" < "$tmp_dir/stream" 2>/dev/null); then
      h=${raw%% *}
    fi
  fi
  if [ -n "${tmp_dir:-}" ]; then rm -rf "$tmp_dir" 2>/dev/null; fi
  # A checksum that runs but emits nothing is a failure too, not an empty tree. The
  # marker is a CONSTANT, not a nonce: `date +%s`+`$$` can repeat under PID reuse inside
  # one second, and two colliding failures would compare equal and report satisfied.
  # Never-matching is enforced at the comparison sites instead.
  if [ -n "$h" ]; then printf '%s\n' "$h"; else printf 'unavailable\n'; fi
}
```

- [ ] **Step 4: Guard the fresh-count comparison**

Find the fresh-count comparison (currently line 324 — anchor on the text, not the
number, since Step 3 changed the length of `tree_hash()` above it). Replace:

```sh
        if [ "$h" = "$prev" ]; then bump_count "$fresh_file"; else { printf '%s' 1 > "$fresh_file"; } 2>/dev/null || true; fi
```

with:

```sh
        # An unhashable pass covers nothing, so it neither counts as "same tree as last
        # pass" nor starts a fresh streak at 1 — two `unavailable` values are not a match.
        if [ "$h" != unavailable ] && [ "$h" = "$prev" ]; then
          bump_count "$fresh_file"
        elif [ "$h" = unavailable ]; then
          { printf '%s' 0 > "$fresh_file"; } 2>/dev/null || true
        else
          { printf '%s' 1 > "$fresh_file"; } 2>/dev/null || true
        fi
```

- [ ] **Step 5: Guard the stale-branch comparison**

At `plugins/dev-workflow/hooks/codex-gate.sh:397`, replace:

```sh
            elif [ "$reviewed" != "$current" ]; then
```

with:

```sh
            # `unavailable` on EITHER side is never a match: an uncomputable fingerprint
            # must read as unverified, and two of them must not cancel out.
            elif [ "$current" = unavailable ] || [ "$reviewed" = unavailable ] ||
                 [ "$reviewed" != "$current" ]; then
```

- [ ] **Step 6: Run lint and the full suite**

Run: `shellcheck --shell=sh plugins/dev-workflow/hooks/codex-gate.sh && shellcheck --shell=sh --exclude=SC2015 plugins/dev-workflow/hooks/codex-gate.test.sh && sh plugins/dev-workflow/hooks/codex-gate.test.sh`
Expected: no shellcheck output; every test line `ok   - …`; final summary reports 0
failures. If SC2181 appears, the `[ $? -eq 0 ]` form crept back into Step 3.

- [ ] **Step 7: Commit**

```bash
git add plugins/dev-workflow/hooks/codex-gate.sh plugins/dev-workflow/hooks/codex-gate.test.sh
git commit -m 'fix(hook): make an uncomputable Gate-B fingerprint fail closed' \
  -m 'Replace the date+PID failure nonce with a constant `unavailable` marker and
enforce never-matching at the comparison sites, so two failing invocations
cannot compare equal and report satisfied. Buffer the component stream and
checksum it only on full success, so a partial stream is never hashed.'
# Single quotes, not double: a `backticked` word inside a double-quoted -m is
# command-substituted by the shell (verified — it runs the word and drops it).
```

---

### Task 2: The index-tree component

**Files:**
- Modify: `plugins/dev-workflow/hooks/codex-gate.sh` (`tree_hash()`, as rewritten in Task 1)
- Modify: `plugins/dev-workflow/hooks/codex-gate.test.sh:180-194` (test 3f)
- Test: `plugins/dev-workflow/hooks/codex-gate.test.sh` (new section)

**Interfaces:**
- Consumes: `tree_hash()` as Task 1 leaves it — the buffered form with a **single**
  `write-tree` (the worktree tree) and no `eff_index`. Verified: that form reproduces the
  current hook's hash byte-for-byte, so Task 1 changed the failure contract only.
- Produces: `tree_hash()` with three components. Step 4 adds `eff_index`, the forced
  `.context` removal, and the pre-`add -A` index `write-tree` — all load-bearing, none of
  them present after Task 1.

- [ ] **Step 1: Rewrite test 3f to assert the decision**

Replace `plugins/dev-workflow/hooks/codex-gate.test.sh:180-194` with:

```sh
# 3f. DECIDED at spec §2 (2026-07-19-gate-b-index-tree-design.md): staging
#     already-reviewed content DOES invalidate. The hash covers the index tree, and
#     `git add` changes it. The bytes that would be committed are unchanged, so this is
#     a false invalidation — accepted under invariant 2 ("loose in the firing
#     direction"), and the STOP message explains that staging alone can cause it.
#     This test previously asserted the OPPOSITE as though it were a principle; the
#     behaviour was never decided, it fell out of an implementation choice.
reset_all
printf 'reviewed change\n' >> app.ts
rev; rev; rev                       # 3 passes covering the modified (unstaged) tree
printf '%s' "$(commitpre)" | grep -q 'Gate B satisfied' && pass "setup: satisfied on unstaged change" || fail "setup: satisfied on unstaged change"
git add app.ts >/dev/null 2>&1      # staging only — no content change
printf '%s' "$(commitpre)" | grep -q 'not satisfied' \
  && pass "staging a reviewed tracked file -> NOT satisfied (spec §2 decision)" \
  || fail "staging a reviewed tracked file -> NOT satisfied (spec §2 decision)"
# The old trailing assertion ("untracked file on a staged tree -> not satisfied") is
# GONE on purpose: once staging alone invalidates, it passes regardless of the untracked
# file and tests nothing. Test 3c already covers untracked content.
git reset -q >/dev/null 2>&1; git checkout -- app.ts >/dev/null 2>&1
reset_all; rev; rev; rev
```

- [ ] **Step 2: Write the new failing tests**

Append to `plugins/dev-workflow/hooks/codex-gate.test.sh`:

```sh
# 26. THE DEFECT (spec §1): staged content diverging from the worktree.
#     NOTE: the revert is a direct byte write, NOT `git checkout -- app.ts` — checkout
#     restores the worktree FROM THE INDEX, which would install v2 on disk and destroy
#     the divergence, making this test pass against the unfixed hook.
reset_all
rev; rev; rev
printf '%s' "$(commitpre)" | grep -q 'Gate B satisfied' && pass "setup: satisfied on clean tree" || fail "setup: satisfied on clean tree"
printf 'v2\n' > app.ts; git add app.ts >/dev/null 2>&1   # index: v2
printf 'v1\n' > app.ts                                   # worktree: back to HEAD bytes
printf '%s' "$(commitpre)" | grep -q 'not satisfied' \
  && pass "staged-vs-worktree divergence -> NOT satisfied" \
  || fail "staged-vs-worktree divergence -> NOT satisfied"
git reset -q >/dev/null 2>&1; git checkout -- app.ts >/dev/null 2>&1

# 27. Ambient alternate index. Three shapes: a negative-only test would be satisfied by
#     an implementation that fires whenever GIT_INDEX_FILE is set — a permanent STOP.
alt_dir=$(mktemp -d)
# 27a. divergent: fingerprint recorded WITHOUT the alternate index, alternate enabled
#      only for the commit check.
reset_all; printf '1' > "$floorf"
rev
cp .git/index "$alt_dir/alt"
printf 'SNEAKY\n' > app.ts; GIT_INDEX_FILE="$alt_dir/alt" git add app.ts >/dev/null 2>&1
printf 'v1\n' > app.ts
printf '%s' "$(GIT_INDEX_FILE="$alt_dir/alt" commitpre)" | grep -q 'not satisfied' \
  && pass "ambient divergent alternate index -> NOT satisfied" \
  || fail "ambient divergent alternate index -> NOT satisfied"
# 27b. stable: same unchanged alternate index across review AND commit -> satisfied,
#      with each index file byte-identical to its OWN pre-hook snapshot.
cp .git/index "$alt_dir/default.before"; cp "$alt_dir/alt" "$alt_dir/alt.before"
reset_all; printf '1' > "$floorf"
# Subshell: a prefix assignment on a SHELL FUNCTION call (rev/commitpre are functions,
# not external commands) persists in the shell after the call returns — unlike the same
# prefix on an external command. Without containment, GIT_INDEX_FILE leaks out of
# section 27 and corrupts every later section's fixtures (notably section 28).
( GIT_INDEX_FILE="$alt_dir/alt" rev )
printf '%s' "$(GIT_INDEX_FILE="$alt_dir/alt" commitpre)" | grep -q 'Gate B satisfied' \
  && pass "ambient stable alternate index -> satisfied" \
  || fail "ambient stable alternate index -> satisfied"
cmp -s .git/index "$alt_dir/default.before" && pass "default index untouched" || fail "default index untouched"
cmp -s "$alt_dir/alt" "$alt_dir/alt.before" && pass "alternate index untouched" || fail "alternate index untouched"
# 27c. missing path: git treats a nonexistent GIT_INDEX_FILE as an EMPTY index, so the
#      hook must hash and self-match rather than returning `unavailable`.
reset_all; printf '1' > "$floorf"
( GIT_INDEX_FILE="$alt_dir/does-not-exist" rev )
h1=$(cat "$state" 2>/dev/null)
( GIT_INDEX_FILE="$alt_dir/does-not-exist" rev )
h2=$(cat "$state" 2>/dev/null)
{ [ -n "$h1" ] && [ "$h1" != unavailable ] && [ "$h1" = "$h2" ]; } \
  && pass "missing alternate index hashes and self-matches" \
  || fail "missing alternate index hashes and self-matches"
rm -rf "$alt_dir"; rm -f "$floorf"
git checkout -- app.ts >/dev/null 2>&1; git reset -q >/dev/null 2>&1
reset_all; rev; rev; rev

# 27d. Guard: confirm section 27's containment held. If a future edit reintroduces the
# leak (e.g. drops a subshell above), this fails loudly instead of section 28 quietly
# going vacuous against a stale, since-deleted GIT_INDEX_FILE path.
[ -z "${GIT_INDEX_FILE+x}" ] && pass "GIT_INDEX_FILE not leaked out of section 27" || fail "GIT_INDEX_FILE not leaked out of section 27"

# 27e. FINDING 1 — a RELATIVE ambient GIT_INDEX_FILE must resolve against the
#      repository TOP-LEVEL, exactly as git itself does — not against the hook's own
#      cwd. The shell-side `[ ! -e ]` test and `cp` are plain shell commands (unlike
#      every git call in the hook, which uses `-C "$repo_root"`), so an unnormalized
#      relative path resolves differently depending on where the hook happens to run
#      from. Run BOTH the review pass and the commit check from a SUBDIRECTORY with a
#      relative alt index that actually lives at the repo root: an unnormalized hook
#      can't find it either time, takes the same absent-index carve-out both times, and
#      the two constant empty-tree hashes MATCH — a false "satisfied" even though the
#      alt index stages content the worktree does not have.
#      The alt index file lives under `.context/` — excluded from the diff-HEAD and
#      worktree-tree components by their own `:(exclude).context` pathspec — so it is
#      never picked up as an untracked file by `add -A` itself; the only way it can
#      affect the hash is through eff_index resolution, which is exactly what this
#      test needs to isolate.
reset_all; printf '1' > "$floorf"
mkdir -p sub
cp .git/index "$work/.context/rel-idx"          # a copy of the CURRENT (matching) index
( cd sub && GIT_INDEX_FILE=.context/rel-idx rev )   # review, from a subdir, relative alt index
printf 'SNEAKY\n' > app.ts
GIT_INDEX_FILE="$work/.context/rel-idx" git add app.ts >/dev/null 2>&1   # stage into the ALT index only
printf 'v1\n' > app.ts                          # worktree stays at the reviewed bytes
out=$(cd sub && GIT_INDEX_FILE=.context/rel-idx commitpre)
printf '%s' "$out" | grep -q 'not satisfied' \
  && pass "relative ambient GIT_INDEX_FILE from a subdirectory -> NOT satisfied (Finding 1)" \
  || fail "relative ambient GIT_INDEX_FILE from a subdirectory -> NOT satisfied (Finding 1)"
rm -f "$work/.context/rel-idx"; rm -rf sub
git checkout -- app.ts >/dev/null 2>&1; git reset -q >/dev/null 2>&1
reset_all; rev; rev; rev

# 28. Tracked .context/ diverging THREE ways (index differs from both HEAD and worktree)
#     is exactly the state where `git rm --cached` refuses without -f, silently (stderr
#     is redirected). The hash must still be computable and self-match, and the user's
#     real index must be untouched — the forced removal runs on the throwaway index only.
git add -f .context >/dev/null 2>&1; git commit -qm "track .context" >/dev/null 2>&1
printf 'staged\n' > .context/codex-gate.on; git add .context/codex-gate.on >/dev/null 2>&1
printf 'worktree\n' > .context/codex-gate.on
cp .git/index "$work/index.before"
before_tree=$(git write-tree 2>/dev/null)
before_blob=$(git rev-parse :.context/codex-gate.on 2>/dev/null)
reset_all
rev; h1=$(cat "$state" 2>/dev/null)
rev; h2=$(cat "$state" 2>/dev/null)
{ [ -n "$h1" ] && [ "$h1" != unavailable ] && [ "$h1" = "$h2" ]; } \
  && pass "three-way .context divergence hashes and self-matches" \
  || fail "three-way .context divergence hashes and self-matches"
[ "$(git write-tree 2>/dev/null)" = "$before_tree" ] && pass "real index tree unchanged" || fail "real index tree unchanged"
[ "$(git rev-parse :.context/codex-gate.on 2>/dev/null)" = "$before_blob" ] && pass "staged .context blob unchanged" || fail "staged .context blob unchanged"
cmp -s .git/index "$work/index.before" && pass "real index bytes unchanged" || fail "real index bytes unchanged"
: > .context/codex-gate.on
git rm -rq --cached .context >/dev/null 2>&1; git commit -qm "untrack .context" >/dev/null 2>&1
reset_all; rev; rev; rev
```

- [ ] **Step 3: Run the tests to verify they fail**

> Capture the runner's exit status separately from the `FAIL` count. Piping straight
> into `grep -c` reports the *grep's* status, so a suite that dies part-way — or exits
> non-zero without printing `FAIL` — reads as `0` and looks green. Both numbers matter:
> `exit=0` **and** a count of `0`.

Run: `sh plugins/dev-workflow/hooks/codex-gate.test.sh 2>&1 | grep -E '^FAIL'`
Expected: FAIL for `staged-vs-worktree divergence -> NOT satisfied`, `staging a reviewed
tracked file -> NOT satisfied (spec §2 decision)`, and `ambient divergent alternate index
-> NOT satisfied`. Task 1 deliberately left the index component out, so these are a
genuine red — the hash still describes only the worktree.

- [ ] **Step 4: Add the index-tree component**

In `tree_hash()`, replace the producer chain written in Task 1 Step 3 with:

```sh
      # (1) INDEX tree and (2) WORKTREE tree, from one throwaway index.
      # The index tree is taken BEFORE `add -A` brings the temp index up to the
      # worktree, because `git commit` commits the index — that is the whole defect.
      # `eff_index`, not `$git_dir/index`: git honours GIT_INDEX_FILE, and a missing
      # alternate index is an EMPTY index to git, so the carve-out must follow the same
      # path git will.
      # A RELATIVE GIT_INDEX_FILE must then be normalized against $repo_root before the
      # `[ ! -e ]` test and `cp` below: those are plain shell commands, resolved against
      # the hook's OWN cwd — while every git call here uses `-C "$repo_root"`, and git
      # itself resolves a relative GIT_INDEX_FILE against the repository TOP-LEVEL, not
      # the caller's cwd. Left unnormalized, running the hook from a subdirectory with a
      # relative ambient GIT_INDEX_FILE makes the shell half look in the wrong place,
      # find nothing, and take the absent-index carve-out — hashing a CONSTANT empty tree
      # while the real index has content (a false "satisfied", not a false STOP).
      # $repo_root is already absolute (from `git rev-parse --show-toplevel`), so
      # prefixing it is enough; an already-absolute eff_index (incl. the $git_dir/index
      # default) is left as-is.
      # `rm -rfq --cached`: without -f git refuses to remove a path whose staged content
      # differs from both HEAD and the worktree — exactly the divergent state this story
      # is about — and does so silently, since stderr is redirected. It runs against the
      # THROWAWAY index; the user's real staging area is untouched.
      if git_dir=$(git -C "$repo_root" rev-parse --absolute-git-dir 2>/dev/null) &&
         [ -n "$git_dir" ] &&
         eff_index=${GIT_INDEX_FILE:-$git_dir/index} &&
         case "$eff_index" in
           /*) : ;;
           *) eff_index="$repo_root/$eff_index" ;;
         esac &&
         { [ ! -e "$eff_index" ] || cp "$eff_index" "$tmp_index" 2>/dev/null; } &&
         GIT_INDEX_FILE="$tmp_index" git -C "$repo_root" rm -rfq --cached \
           --ignore-unmatch -- .context >/dev/null 2>&1 &&
         GIT_INDEX_FILE="$tmp_index" git -C "$repo_root" write-tree 2>/dev/null &&
         GIT_INDEX_FILE="$tmp_index" git -C "$repo_root" add -A \
           -- . ':(exclude).context' >/dev/null 2>&1 &&
         GIT_INDEX_FILE="$tmp_index" git -C "$repo_root" write-tree 2>/dev/null
      then :; else ok=0; fi
```

**Post-report addendum (Finding 1, Gate-B code review):** the two halves of the
carve-out resolved relative paths differently — the shell test/`cp` against the hook's
own cwd, every `git` call against `-C "$repo_root"` — so a relative ambient
`GIT_INDEX_FILE` run from a subdirectory silently took the carve-out and hashed a
constant empty tree, a false "satisfied". Fixed by normalizing `eff_index` against
`$repo_root` with a `case` (already-absolute paths, including the `$git_dir/index`
default, pass through unchanged). Covered by test 27e below.

Run: `sh plugins/dev-workflow/hooks/codex-gate.test.sh > /tmp/suite.out 2>&1; echo "exit=$?"; grep -cE '^FAIL' /tmp/suite.out`
Expected: `0`

- [ ] **Step 5: Mutation-verify each guard**

Each mutation must turn a specific test red. Apply, run, revert.

1. Delete the first `write-tree` line (the index component) → test 26 must FAIL.
2. Change `-rfq` to `-rq` (drop the force) → test 28 must FAIL.
3. Change `eff_index=${GIT_INDEX_FILE:-$git_dir/index}` to `eff_index=$git_dir/index` →
   test 27a must FAIL.

Run after each: `sh plugins/dev-workflow/hooks/codex-gate.test.sh > /tmp/suite.out 2>&1; echo "exit=$?"; grep -cE '^FAIL' /tmp/suite.out`
Expected: at least 1 before reverting; 0 after reverting all three.

- [ ] **Step 6: Run the full battery**

Run: `shellcheck --shell=sh plugins/dev-workflow/hooks/codex-gate.sh && shellcheck --shell=sh --exclude=SC2015 plugins/dev-workflow/hooks/codex-gate.test.sh && sh plugins/dev-workflow/hooks/codex-gate.test.sh`
Expected: clean shellcheck, 0 failures.

- [ ] **Step 7: Commit**

```bash
git add plugins/dev-workflow/hooks/codex-gate.sh plugins/dev-workflow/hooks/codex-gate.test.sh
git commit -m "fix(hook): hash the index tree, not just the worktree

git commit commits the INDEX, but both hash components described the
worktree, so staging a change and reverting the file on disk reported Gate B
satisfied on unreviewed content. Add a tree id taken from the effective index
before the throwaway index is brought up to the worktree.

Staging already-reviewed content now invalidates a review — a false
invalidation, accepted under invariant 2. Test 3f asserted the opposite as a
principle and is rewritten to assert the decision."
```

---

### Task 3: Messages — stale, empty-state, and satisfied branches

**Files:**
- Modify: `plugins/dev-workflow/hooks/codex-gate.sh` — the three `emit` calls in the
  commit-check `case`. **Anchor on their text, not on line numbers:** Task 1 replaced
  `tree_hash()` with a longer function, so every line below it has shifted. Find them
  with `grep -n 'STOP — Codex Gate B not satisfied\|Codex Gate B: \$passes' plugins/dev-workflow/hooks/codex-gate.sh`.
- Modify: `plugins/dev-workflow/hooks/codex-gate.test.sh:63` (asserts the old wording)
- Test: `plugins/dev-workflow/hooks/codex-gate.test.sh` (new section)

**Interfaces:**
- Consumes: the branch conditions from Task 1 Step 5.
- Produces: nothing consumed by later tasks.

- [ ] **Step 1: Update the existing assertion that this change breaks**

At `plugins/dev-workflow/hooks/codex-gate.test.sh:63`, replace:

```sh
printf '%s' "$out" | grep -q 'tree has CHANGED' && pass "Edit-tool change -> reported as stale tree" || fail "Edit-tool change -> reported as stale tree"
```

with:

```sh
printf '%s' "$out" | grep -q 'cannot confirm' && pass "Edit-tool change -> reported as unconfirmed" || fail "Edit-tool change -> reported as unconfirmed"
```

- [ ] **Step 2: Write the failing message tests**

Append to `plugins/dev-workflow/hooks/codex-gate.test.sh`:

```sh
# 29. Message contracts (spec §4). These are shipped prompts — the product itself, not
#     incidental output — so each branch's COMPLETE additionalContext and systemMessage
#     is pinned as a golden fixture and compared EXACTLY, replacing per-clause greps: a
#     clause list only catches a regression someone thought to enumerate (inserting
#     "do not " before an asserted clause, or "Usually" -> "Always", stays green under
#     it); an exact comparison catches any wording change. $passes, $floor and $fresh
#     are pinned by the setup immediately before each assertion, so every fixture below
#     is deterministic.
json_field() { # $1 = json text, $2 = key -> prints the string value. No jq required —
                # same fallback idiom as the hook's own field(): safe here because none
                # of the three golden messages below contain a literal backslash or quote.
  printf '%s' "$1" | grep -o "\"$2\"[[:space:]]*:[[:space:]]*\"[^\"]*\"" | head -n1 | sed 's/^.*:[[:space:]]*"\(.*\)"$/\1/'
}

# 29a. STALE branch: 1 recorded pass this cycle, default floor 3, no CLAUDE.md (so the
#      generic policy phrase), a change made through the Edit tool.
# A `rev` baseline is required before the edit: without one, `reviewed` is empty and
# the edit below lands in the EMPTY-STATE branch, not the STALE branch this fixture
# describes (matches the existing pattern in section 3a).
reset_all; rev
printf 'edit\n' >> app.ts
run '{"hook_event_name":"PostToolUse","tool_name":"Edit","tool_input":{"file_path":"app.ts"}}' >/dev/null
out=$(commitpre)
ctx=$(json_field "$out" additionalContext)
msg=$(json_field "$out" systemMessage)
expected_ctx="STOP — Codex Gate B not satisfied: the hook cannot confirm that the content you are about to commit is the content mcp__codex__review last saw (1 recorded pass(es) this cycle). Usually that means the working tree or the index changed since the review. It can also mean you only staged already-reviewed content — the bytes are fine, but the hook cannot tell staging from editing; that this hook was upgraded and the recorded fingerprint uses the older format (see CHANGELOG); or that the fresh fingerprint could not be computed or could not be stored. Run Gate B (mcp__codex__review) now — one clean pass is the complete remedy for the staging and post-upgrade cases too. If a fresh pass leaves this unchanged with nothing edited in between, the fault is in the machinery rather than the code: check that .context/ is writable, that TMPDIR is writable, that a checksum tool (shasum, sha1sum or cksum) runs, that git status works, and that the disk is not full — then run one more pass to record a usable fingerprint. Per this project's review policy you MUST re-review after every fix."
expected_msg="⚠ Codex Gate B not satisfied (cannot confirm review)"
[ "$ctx" = "$expected_ctx" ] && pass "stale additionalContext matches exactly" || fail "stale additionalContext matches exactly"
[ "$msg" = "$expected_msg" ] && pass "stale systemMessage matches exactly" || fail "stale systemMessage matches exactly"
git checkout -- app.ts >/dev/null 2>&1

# 29b. SATISFIED branch: 3/3 passes this cycle, all 3 fresh (unchanged tree). The hook
#      fingerprints disk; mcp__codex__review reads a git range (spec §7) — the exact
#      fixture below is what pins that the message never claims Codex read the bytes.
reset_all; rev; rev; rev
out=$(commitpre)
ctx=$(json_field "$out" additionalContext)
msg=$(json_field "$out" systemMessage)
expected_ctx="Codex Gate B: 3/3 pass(es) this cycle, of which 3 cover the CURRENT content fingerprint (unchanged since that review). The floor counts the cycle; only the fresh pass(es) carry the same fingerprint as what you are committing. Per this project's review policy, commit only if your final pass was clean — no new Blocker/Major."
expected_msg="✓ Codex Gate B satisfied (3/3 cycle, 3 on current fingerprint)"
[ "$ctx" = "$expected_ctx" ] && pass "satisfied additionalContext matches exactly" || fail "satisfied additionalContext matches exactly"
[ "$msg" = "$expected_msg" ] && pass "satisfied systemMessage matches exactly" || fail "satisfied systemMessage matches exactly"

# 29c. EMPTY-STATE branch: no fingerprint recorded this cycle, default floor 3.
reset_all
out=$(commitpre)
ctx=$(json_field "$out" additionalContext)
msg=$(json_field "$out" systemMessage)
expected_ctx="STOP — Codex Gate B not satisfied: no fingerprint is recorded for this cycle — either no mcp__codex__review has run, or the last one's fingerprint could not be written or read back. Per this project's review policy you MUST reach a minimum of 3 passes per cycle. Run Gate B (mcp__codex__review) now; if this repeats, check that .context/ and the state file inside it are readable and writable, and if the file exists but is unreadable or empty, delete it and run a fresh pass."
expected_msg="⚠ Codex Gate B: no recorded review"
[ "$ctx" = "$expected_ctx" ] && pass "empty-state additionalContext matches exactly" || fail "empty-state additionalContext matches exactly"
[ "$msg" = "$expected_msg" ] && pass "empty-state systemMessage matches exactly" || fail "empty-state systemMessage matches exactly"
reset_all; rev; rev; rev

# 30. UNSTORABLE STATE (spec §5 test 11). Cause 5 lives OUTSIDE tree_hash: the store path
#     writes with `2>/dev/null || true` because the hook must always exit 0, so a pass can
#     hash perfectly and still leave the old fingerprint behind. Three shapes, because
#     they reach the branch by different routes.
#     Each shape depends on chmod actually DENYING access, which is false under an
#     effective root uid — a root-run CI job would take the success path and then fail the
#     assertion, reporting a product defect that is really a privilege artefact. Probe the
#     exact operation each shape needs, restore what the probe changed, and skip loudly.
probe_denies() {   # $1 = probe command; returns 0 when the operation was DENIED
  ( eval "$1" ) >/dev/null 2>&1 && return 1 || return 0
}
skip() { printf 'skip - %s\n' "$1"; }

# 30a. replacement fails: the state file itself is read-only
reset_all; rev
before=$(cat "$state")
chmod 0444 "$state" 2>/dev/null
if probe_denies "printf x >> \"$state\""; then
  printf 'later edit\n' >> app.ts
  rev                                   # hashes fine, but cannot replace the fingerprint
  [ "$(cat "$state")" = "$before" ] && pass "unwritable state file keeps the old fingerprint" || fail "unwritable state file keeps the old fingerprint"
  printf '%s' "$(commitpre)" | grep -q 'cannot confirm' \
    && pass "stale fingerprint after a failed store -> cannot confirm" \
    || fail "stale fingerprint after a failed store -> cannot confirm"
else
  skip "unwritable state file (chmod does not deny writes here — running as root?)"
fi
chmod 0644 "$state" 2>/dev/null
git checkout -- app.ts >/dev/null 2>&1

# 30b. first write fails: no prior state, and the directory refuses a new file
reset_all
chmod 0555 .context 2>/dev/null
if probe_denies "touch .context/probe-$$"; then
  rev                                   # cannot create the state file at all
  out=$(commitpre)
  printf '%s' "$out" | grep -qF 'no fingerprint is recorded' \
    && pass "unwritable .context -> empty-state branch" || fail "unwritable .context -> empty-state branch"
  printf '%s' "$out" | grep -qF 'could not be written or read back' \
    && pass "empty-state branch admits a failed first write" || fail "empty-state branch admits a failed first write"
else
  skip "unwritable .context directory (chmod does not deny creation here — running as root?)"
fi
chmod 0755 .context 2>/dev/null; rm -f ".context/probe-$$"

# 30c. read fails: the state file exists and is non-empty but cannot be read
reset_all; rev
chmod 0000 "$state" 2>/dev/null
if probe_denies "cat \"$state\""; then
  out=$(commitpre)
  printf '%s' "$out" | grep -qF 'no fingerprint is recorded' \
    && pass "unreadable state file -> empty-state branch" || fail "unreadable state file -> empty-state branch"
  # invariant 1: advisory hook, always exit 0, even when its own state is unreadable.
  # Checked with `if`, not `[ $? -eq 0 ]` — the latter is SC2181 and the test file
  # excludes only SC2015, so it would fail lint.
  if run '{"hook_event_name":"PreToolUse","tool_name":"Bash","tool_input":{"command":"git commit -m x"}}' >/dev/null 2>&1; then
    pass "unreadable state file -> hook still exits 0"
  else
    fail "unreadable state file -> hook still exits 0"
  fi
else
  skip "unreadable state file (chmod does not deny reads here — running as root?)"
fi
chmod 0644 "$state" 2>/dev/null
reset_all; rev; rev; rev
```

- [ ] **Step 3: Run the tests to verify they fail**

Run: `sh plugins/dev-workflow/hooks/codex-gate.test.sh 2>&1 | grep -E '^FAIL'`
Expected: FAIL for all six section-29 exact-match assertions (`stale additionalContext
matches exactly`, `stale systemMessage matches exactly`, `satisfied additionalContext
matches exactly`, `satisfied systemMessage matches exactly`, `empty-state
additionalContext matches exactly`, `empty-state systemMessage matches exactly`), plus
section 30's `cannot confirm` / `no fingerprint is recorded` / `could not be written or
read back` assertions. Any `skip -` lines are acceptable only if you are running as
root; on a normal account all three shapes must execute.

- [ ] **Step 4: Rewrite the three messages**

Replace the empty-state `emit` call — the one under `if [ -z "$reviewed" ]; then`, whose
text begins "no mcp__codex__review has run this cycle" — together with the comment above
it, which asserts a cause that may be false:

```sh
              # `-z "$reviewed"` no longer means only "no pass this cycle": a pass whose
              # state write failed, or a state file that cannot be read back, leaves it
              # empty too. The message names the absent FINGERPRINT, not an absent review.
              emit "STOP — Codex Gate B not satisfied: no fingerprint is recorded for this cycle — either no mcp__codex__review has run, or the last one's fingerprint could not be written or read back. Per $policy you MUST reach a minimum of $floor passes per cycle. Run Gate B (mcp__codex__review) now; if this repeats, check that .context/ and the state file inside it are readable and writable, and if the file exists but is unreadable or empty, delete it and run a fresh pass." "⚠ Codex Gate B: no recorded review"
```

Replace the stale `emit` call — the one whose text begins "the working tree has CHANGED
 since the last mcp__codex__review" — with:

```sh
              # Content check, not event check: this fires for a change made through ANY
              # tool — Edit/Write, or a Bash `sed -i` / `eslint --fix` / `git apply`.
              # It names the STATE, never a cause: five states reach here and the hook
              # cannot tell them apart (spec §4). Do not "improve" this into asserting
              # that the tree changed — under a repeated computation failure nothing
              # changed, and under a failed state write the content may be exactly what
              # was reviewed.
              emit "STOP — Codex Gate B not satisfied: the hook cannot confirm that the content you are about to commit is the content mcp__codex__review last saw ($passes recorded pass(es) this cycle). Usually that means the working tree or the index changed since the review. It can also mean you only staged already-reviewed content — the bytes are fine, but the hook cannot tell staging from editing; that this hook was upgraded and the recorded fingerprint uses the older format (see CHANGELOG); or that the fresh fingerprint could not be computed or could not be stored. Run Gate B (mcp__codex__review) now — one clean pass is the complete remedy for the staging and post-upgrade cases too. If a fresh pass leaves this unchanged with nothing edited in between, the fault is in the machinery rather than the code: check that .context/ is writable, that TMPDIR is writable, that a checksum tool (shasum, sha1sum or cksum) runs, that git status works, and that the disk is not full — then run one more pass to record a usable fingerprint. Per $policy you MUST re-review after every fix." "⚠ Codex Gate B not satisfied (cannot confirm review)"
```

Replace the satisfied `emit` call — the one whose text begins "Codex Gate B: $passes/$floor
pass(es) this cycle" — with:

```sh
              # Distinguish the two counts (Finding 9): the cycle total includes passes
              # made BEFORE later edits, which no longer cover the code being committed.
              # FINGERPRINT EQUALITY IS ALL THIS PROVES. The hook compares a hash of
              # disk; mcp__codex__review reads a git range — so a match does NOT
              # establish that Codex read these bytes (spec §7, and the review-range row
              # in todos.md). The stronger phrasing was here and was removed; do not
              # restore it as a clarity improvement.
              emit "Codex Gate B: $passes/$floor pass(es) this cycle, of which $fresh cover the CURRENT content fingerprint (unchanged since that review). The floor counts the cycle; only the fresh pass(es) carry the same fingerprint as what you are committing. Per $policy, commit only if your final pass was clean — no new Blocker/Major." "✓ Codex Gate B satisfied ($passes/$floor cycle, $fresh on current fingerprint)"
```

- [ ] **Step 5: Run the tests to verify they pass**

Run: `sh plugins/dev-workflow/hooks/codex-gate.test.sh > /tmp/suite.out 2>&1; echo "exit=$?"; grep -cE '^FAIL' /tmp/suite.out`
Expected: `0`

- [ ] **Step 6: Check the prompts against the standards**

Read `docs/prompt-standards.md` and verify all 12 items against the three new strings —
in particular item 10 (identical-symptom causes each get a distinguishing check and a fix)
and item 12 (all-caps reserved for hard rules: `STOP` and `MUST` qualify, `INDEX` does
not and must not reappear).

- [ ] **Step 7: Commit**

```bash
git add plugins/dev-workflow/hooks/codex-gate.sh plugins/dev-workflow/hooks/codex-gate.test.sh
git commit -m "fix(hook): stop the Gate-B messages asserting causes they cannot know

The stale branch is reached by five distinct states, so it names the state
(cannot confirm) rather than claiming the tree changed. The empty-state branch
admits a fingerprint that failed to write or read. The satisfied branch drops
'actually reviewed what you are committing' for fingerprint equality: the hook
hashes disk, the reviewer reads a git range."
```

---

### Task 4: Documentation — every site that describes the old behaviour

Found by grep, not memory. Docs-drift is this project's most frequent finding class and
this repo is its most frequent site.

**Files:**
- Modify: `AGENTS.md` (invariant 3, ~line 85)
- Modify: `plugins/dev-workflow/hooks/codex-gate.sh:6-11` (header) and `:105`
- Modify: `plugins/dev-workflow/hooks/codex-gate.sh:150-193` (the hash comment block)
- Modify: `plugins/dev-workflow/hooks/codex-gate.test.sh:126` (the NOTE)
- Modify: `README.md:26`
- Modify: `docs/architecture.md:64-72`
- Modify: `docs/getting-started.md:46`
- Modify: `plugins/dev-workflow/commands/workflow-init.md:778`
- Modify: `docs/superpowers/stories/2026-07-18-gate-b-hash-staged-worktree-divergence-story.md`

**Interfaces:**
- Consumes: the implemented behaviour from Tasks 1–3.
- Produces: nothing consumed by later tasks.

- [ ] **Step 1: Re-run the grep that found these, to catch anything added since**

Run:
```bash
EXCL='source-files/|docs/superpowers/|\.mcp/|\.remember/'
grep -rniE "working tree|worktree" --include='*.md' . | grep -vE "$EXCL" | grep -iE "hash|tree id|invalidat|staging|staged"
grep -rn "tree-hash proves\|actually reviewed\|staging alone" --include='*.md' --include='*.sh' . | grep -vE "$EXCL"
```
These two greps are a **safety net for sites added since this plan was written**, not a
rediscovery of the full list. They do not return every site in this task, and they return
one that belongs elsewhere:

- Expect `docs/architecture.md` and `docs/getting-started.md` from the first grep, and
  `plugins/dev-workflow/hooks/codex-gate.sh` (line 105) from the second.
- Expect a `todos.md` hit. It is **Task 6-owned** — the parked row being removed there —
  and must not be edited here.
- `README.md:26`, `plugins/dev-workflow/commands/workflow-init.md:778`, the hook header
  (6-11), the hash comment block (150-193) and the test NOTE (126) do **not** match these
  patterns. They are known sites, listed above, and are edited in Steps 3-4 by name.

The exclusions matter: `docs/superpowers/` holds this plan and the approved spec, which
describe the change and must NOT be rewritten to match it; `.mcp/` and `.remember/` are
generated state. The story file under `docs/superpowers/stories/` is edited in Step 5 by
name.

Any hit outside the exclusions that is neither listed above nor the known todos.md row is
a site added since this plan was written — add it to this task before proceeding.

- [ ] **Step 2: Amend AGENTS.md invariant 3**

Replace the invariant-3 body so it names all three components:

```markdown
3. **Gate-B validity is content-derived, never event-derived.** Invalidation compares a
   fingerprint of everything a commit could carry: `git diff HEAD` for tracked content,
   a tree id written from the **effective index** (`GIT_INDEX_FILE` when set, else the
   git-dir index), and a tree id written from a throwaway index brought up to the
   worktree — so untracked paths, contents and file modes all count, minus `.context/`.
   The index component exists because `git commit` commits the index: without it, staging
   a change and reverting the file on disk read as unchanged and reported satisfied. An
   event-derived check misses a file changed through Bash (`sed -i`, `git apply`,
   codegen) and leaves a stale ✓ standing; so does a name-only view of untracked files,
   or any hand-rolled walk that re-derives what `git write-tree` already gets right
   (symlink targets, exotic path encodings, non-regular files). When the fingerprint
   cannot be computed it is the literal `unavailable`, which never matches — including
   against itself.
```

- [ ] **Step 3: Fix the hook's own prose**

`codex-gate.sh:6-11` — replace "a hash of the working tree" with "a fingerprint of the
index and the working tree", and "compares what is actually on disk" with "compares what
a commit would actually carry".

`codex-gate.sh:105` — replace "(unlike Gate B, where the tree-hash proves what was
reviewed)" with "(unlike Gate B, which at least compares a content fingerprint — though
that proves the content is unchanged since the review, not that Codex read it)".

`codex-gate.sh:150-193` — the block above `tree_hash()`. Delete the `KNOWN GAP` paragraph
entirely (it is now fixed). Replace the "Tracked CONTENT comes from `git diff HEAD` …
does not change the hash" paragraph with:

```sh
# Tracked CONTENT comes from `git diff HEAD`, which is staging-independent. The INDEX
# tree is hashed separately, so `git add` of an already-reviewed file DOES invalidate:
# decided at docs/superpowers/specs/2026-07-19-gate-b-index-tree-design.md §2. The
# committed bytes are unchanged in that case, so it is a false invalidation — accepted
# under invariant 2, and the STOP message says staging alone can cause it.
#
# The seed copy is correctness-critical, not just a speed optimisation: `write-tree` on
# an empty index SUCCEEDS with the well-known empty tree, so a silently-failed copy would
# make the index component a constant that matches itself.
```

`codex-gate.test.sh:126` — the NOTE claiming the guard has no regression test. Narrow it:

```sh
# NOTE: sections 24-25 cover the "could not be computed" guard for checksum, seed-copy,
# git-dir and diff failures. Still uncovered: a `git add`/`write-tree` failure inside the
# throwaway index (see the tree-unavailable row in todos.md, which stays parked).
```

- [ ] **Step 4: Fix the user-facing docs**

`README.md:26` — replace "verify a Gate-B review against the actual content of the working
tree" with "verify a Gate-B review against a fingerprint of the index and working tree —
what a commit would actually carry".

`docs/architecture.md:64-72` — name three components instead of two, and replace "the
check is tied to what is actually on disk" with "the check is tied to what a commit would
carry — the index as well as the worktree". Keep the edit-then-undo sentence but scope it:
an unstaged edit-then-undo still matches.

`docs/getting-started.md:46` — replace "(staging alone doesn't; `git add` changes no
content)" with "(staging counts too: the fingerprint covers the index, because that is
what a commit carries)".

`plugins/dev-workflow/commands/workflow-init.md:778` — replace "on both the tracked and
untracked side" with "from all three of its fingerprint components".

- [ ] **Step 5: Settle the story's open questions**

In `docs/superpowers/stories/2026-07-18-gate-b-hash-staged-worktree-divergence-story.md`:

§2 — narrow "regardless of how the divergence arose" to "as of the hook's invocation:
a compound `git add X && git commit` stages after the PreToolUse fingerprint and remains
the separate Parked defect."

§5 — replace all three open questions with their settled answers: staging invalidates
(spec §2); one content rule covers every commit shape, but only as of hook invocation, so
`git add X && git commit` stays parked; invariant 3's wording did need amending (Step 2).

- [ ] **Step 6: Verify no site was missed**

Run: `grep -rn "tree-hash proves\|actually reviewed what you are committing\|staging alone doesn't" --include='*.md' --include='*.sh' . | grep -v source-files/ | grep -v docs/superpowers/`
Expected: no output.

Run the battery again (docs edits can break the hook if a comment was mangled):
`shellcheck --shell=sh plugins/dev-workflow/hooks/codex-gate.sh && sh plugins/dev-workflow/hooks/codex-gate.test.sh`
Expected: clean, 0 failures.

- [ ] **Step 7: Commit**

```bash
git add AGENTS.md README.md docs/architecture.md docs/getting-started.md docs/superpowers/stories plugins/dev-workflow/hooks plugins/dev-workflow/commands/workflow-init.md
git commit -m "docs: describe the fingerprint as index + worktree, not worktree alone

Amend invariant 3 to name all three components and why the index one exists.
Correct every site that described the hash as worktree-only or claimed the
tree-hash proves what was reviewed, and settle the story's open questions."
```

---

### Task 5: Version bump and CHANGELOG

Invariant 12: a PR touching `plugins/` must bump that manifest's version, or CI fails.

**Files:**
- Modify: `plugins/dev-workflow/.claude-plugin/plugin.json` (`version`)
- Modify: `plugins/dev-workflow/CHANGELOG.md`

**Interfaces:**
- Consumes: the completed changes from Tasks 1–4.
- Produces: nothing.

- [ ] **Step 1: Bump the manifest**

In `plugins/dev-workflow/.claude-plugin/plugin.json`, change `"version": "0.4.1"` to
`"version": "0.5.0"` — minor, not patch: the hook's fingerprint composition changes and a
previously-satisfied workflow (review → stage → commit) now stops.

- [ ] **Step 2: Add the CHANGELOG entry**

Insert directly below the intro paragraphs in `plugins/dev-workflow/CHANGELOG.md`:

```markdown
## 0.5.0

- **Gate-B fingerprint covers the index.** `git commit` commits the index, but both hash
  components described the worktree, so staging a change and then reverting the file on
  disk reported Gate B satisfied on content nobody reviewed. The fingerprint now includes
  a tree id from the effective index (`GIT_INDEX_FILE` when set, else the git-dir index).
- **Staging now invalidates a review.** `git add` of already-reviewed content changes the
  index tree, so the fingerprint changes. The committed bytes are unchanged, making this
  a false invalidation — accepted under the "loose in the firing direction" invariant, and
  the reminder explains that staging alone can cause it. One clean pass clears it.
- **Upgrading invalidates any in-flight review once.** The fingerprint's composition
  changed, so a fingerprint recorded by 0.4.x cannot match one computed by 0.5.0. The
  first commit attempt after upgrading reports "cannot confirm"; a single review pass
  clears it. This is expected, not a bug.
- **An uncomputable fingerprint now fails closed.** The failure value is a constant that
  never matches — including against itself — replacing a `date`+PID nonce that could
  collide under PID reuse and report satisfied.
- **Reminder text no longer asserts causes it cannot know.** The stale reminder names the
  state ("cannot confirm") rather than claiming the tree changed, and describes the causes
  that can produce it; the satisfied reminder claims fingerprint equality rather than that
  Codex read the bytes. The clauses are pinned by the message-contract tests in
  `codex-gate.test.sh` section 29 — that suite is what keeps this true, and it asserts the
  clauses listed there, not an exhaustive enumeration of states.
```

- [ ] **Step 3: Run the version-bump checker's own regression suite**

Run: `sh scripts/check-version-bump.test.sh`
Expected: exits 0. Nothing is staged or stashed here — the checker compares *commits*,
so it cannot see an uncommitted bump, and `git add -A`/`git stash` would sweep in
unrelated working-tree changes.

The checker itself runs in Step 5, **after** the bump is committed, against the branch's
real base ref. Run against `main` with the bump still uncommitted it reports clean —
correctly, and uselessly.

- [ ] **Step 4: Run the full quality battery**

Run:
```bash
shellcheck --shell=sh plugins/dev-workflow/hooks/codex-gate.sh && \
shellcheck --shell=sh --exclude=SC2015 plugins/dev-workflow/hooks/codex-gate.test.sh && \
shellcheck --shell=sh scripts/check-invariants.sh && \
shellcheck --shell=sh --exclude=SC2015 scripts/check-invariants.test.sh && \
shellcheck --shell=sh scripts/check-version-bump.sh && \
shellcheck --shell=sh scripts/check-version-bump.test.sh && \
sh plugins/dev-workflow/hooks/codex-gate.test.sh && \
sh scripts/check-invariants.test.sh && sh scripts/check-invariants.sh && \
sh scripts/check-version-bump.test.sh && \
claude plugin validate . --strict
```
Expected: every command exits 0; `claude plugin validate` reports the plugin valid.

- [ ] **Step 5: Commit, then run the version-bump checker against the real base**

```bash
git add plugins/dev-workflow/.claude-plugin/plugin.json plugins/dev-workflow/CHANGELOG.md
git commit -m 'chore(plugin): release 0.5.0'
```

Then, with the work committed:

Run: `sh scripts/check-version-bump.sh "$(git merge-base HEAD main)"`
Expected: exits 0, reporting the bump as present. This is the one battery member with a
precondition — it compares commits, so it is meaningless before the commit exists, and
`main` is the right base only while this branch is based on current `main`. CI passes the
PR's own base ref instead.

---

### Task 6: Ledger and backlog

**Files:**
- Modify: `todos.md` (remove the closed Parked row; add the review-range row)
- Modify: `docs/hardening-log.md` (append one row)

**Interfaces:**
- Consumes: everything above.
- Produces: nothing.

- [ ] **Step 1: Remove the closed row and add the new one**

In `todos.md` under `### Parked (trigger-gated)`, delete the entire
"**Gate-B hash misses staged-vs-worktree divergence (false ✓, invariant 3).**" bullet.
The other four Parked rows stay untouched.

Narrow the tree-unavailable row to match the test NOTE from Task 4 Step 3: sections 24–25
now cover checksum, seed-copy, git-dir and diff failures, so what remains parked is the
`git add`/`write-tree` failure seam inside the throwaway index.

Add, in the same Parked list:

```markdown
- [ ] **Gate-B fingerprints disk; the reviewer reads history.** A review pass records a
      fingerprint of the index and worktree, but `mcp__codex__review` reads a **git
      range** — so content that is staged and never committed can be fingerprinted as
      reviewed without Codex having read it, and three such passes reach ✓. Raised at
      Gate A pass 8 of the index-tree story and deliberately deferred there: closing it
      means refusing to satisfy Gate B unless the index and worktree correspond to the
      reviewed range, i.e. mandating a WIP commit for every review. That redefines the
      gate rather than fixing a hash, so it needs its own story and its own decision.
      CLAUDE.md §5's WIP-commit flow is the current mitigation.
```

- [ ] **Step 2: Append the ledger row**

Append this row verbatim to the table at the end of `docs/hardening-log.md` (columns
already verified against the existing rows: `date | fingerprint | finding | source |
severity | rung | ref`):

```markdown
| 2026-07-19 | false-negative-gate | both Gate-B hash components described the worktree while `git commit` commits the index, so staging a change and reverting the file on disk reported satisfied on unreviewed content | gate-b | blocker | 4 test | plugins/dev-workflow/hooks/codex-gate.test.sh sections 24-30 + AGENTS.md invariant 3 (amended to name all three components). What the tests DO cover: the index component exists and moves on divergence, the failure marker never self-matches, and the ambient-alternate-index and three-way-`.context` states. What they do NOT: every divergence shape (they pin the mechanism, not exhaustive enumeration); mutation after the PreToolUse event, which is the parked compound-command row; command-local retargeting (`GIT_INDEX_FILE=`/`-C`/`--git-dir`), split to the 2026-07-19 command-retargeting-guard story; and a `git add`/`write-tree` failure inside the throwaway index, which stays parked |
```

- [ ] **Step 3: Verify the backlog reference still resolves**

Run: `grep -n "staged-vs-worktree" todos.md docs/hardening-log.md docs/superpowers/ -r`
Expected: no `pending` ledger row still points at the deleted todos.md bullet. Any hit in
`docs/superpowers/` is a spec/story reference and is fine.

- [ ] **Step 4: Commit**

```bash
git add todos.md docs/hardening-log.md
git commit -m 'docs(ledger): close the staged-vs-worktree row, park the review-range gap'
```

- [ ] **Step 5: Run the complete quality battery on the finished branch**

Task 5's battery ran before these ledger and backlog edits existed, so it did not cover
the final commit. `check-invariants.sh` reads markdown too — an unpinned example in a new
todos.md line would fail it — so the battery is re-run here, in the exact form AGENTS.md
calls canonical, with every commit in place:

```bash
shellcheck --shell=sh plugins/dev-workflow/hooks/codex-gate.sh && \
shellcheck --shell=sh --exclude=SC2015 plugins/dev-workflow/hooks/codex-gate.test.sh && \
shellcheck --shell=sh scripts/check-invariants.sh && \
shellcheck --shell=sh --exclude=SC2015 scripts/check-invariants.test.sh && \
shellcheck --shell=sh scripts/check-version-bump.sh && \
shellcheck --shell=sh scripts/check-version-bump.test.sh && \
sh plugins/dev-workflow/hooks/codex-gate.test.sh && \
sh scripts/check-invariants.test.sh && sh scripts/check-invariants.sh && \
sh scripts/check-version-bump.test.sh && \
sh scripts/check-version-bump.sh "$(git merge-base HEAD main)" && \
claude plugin validate . --strict
```
Expected: every command exits 0. If anything fails, fix it and amend the relevant commit —
the branch must not be opened as a PR with a red battery.

---

## Verification checklist (before opening the PR)

- [ ] Complete quality battery green on the FINAL commit (Task 6 Step 5) — not just
      Task 5 Step 4, which ran before the ledger and backlog edits existed.
- [ ] All three mutations from Task 2 Step 5 turn a test red, and reverting them turns it
      green again.
- [ ] `git log --format='%(trailers)' origin/main..HEAD` prints nothing (no `Co-Authored-By`).
- [ ] Story 2 exists at `docs/superpowers/stories/2026-07-19-command-retargeting-guard-story.md`
      (AC-10 — it does; committed as `a0151ce`).
- [ ] Gate B (`mcp__codex__review`) on the full diff, per CLAUDE.md §5: three passes
      minimum, final pass clean, re-reviewed after every fix.
