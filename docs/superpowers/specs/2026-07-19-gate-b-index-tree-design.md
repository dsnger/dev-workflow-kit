# Gate-B hash: cover the index, not just the worktree — Spec

**Date:** 2026-07-19 · **Size:** story · **Story:**
`docs/superpowers/stories/2026-07-18-gate-b-hash-staged-worktree-divergence-story.md`

**Gate A cost before the split:** 13 passes, ~108 findings. Recorded as a calibration
point for the risk-profile work (todos.md, P2) — a spec pinning shell code and prompt text
converges far slower than one at design altitude, and half of that cost was a second
feature that should have been its own story (§7).

## 1. Problem

`tree_hash()` in `plugins/dev-workflow/hooks/codex-gate.sh` composes two components —
`git diff HEAD` and a tree id written from a throwaway index seeded from the real index
and then brought up to date with `git add -A`. Both describe the **worktree**. `git
commit` commits the **index**.

**Repro** (verified in a throwaway repo):

```sh
printf 'v2\n' > app.ts && git add app.ts     # index: v2
printf 'v1\n' > app.ts                       # worktree: back to HEAD's bytes
```

`git diff HEAD` is then empty and the worktree tree id is unchanged, so the hash matches
the reviewed one and Gate B reports satisfied — while the commit carries `v2`. This is
the false-✓ direction invariant 3 exists to close. Found by Codex at Gate B on PR #1,
deferred there because the fix carries a decision rather than a correction.

**Do not write the revert as `git checkout -- app.ts`.** That restores the worktree
*from the index*, so it would install `v2` on disk and leave index and worktree in
agreement — the divergence never happens, and a test built on it would pass against the
unfixed hook. Restore the bytes directly (as above) or use `git restore --source=HEAD
--worktree -- app.ts`; the `printf` form is preferred in tests, since it needs no
minimum git version.

## 2. Decision record — does a bare `git add` invalidate a review?

The fix forces an answer, and the answer was never actually made: today's behaviour
("staging does not invalidate") fell out of an implementation choice and is asserted by
test 3f as though it were a principle.

**Two candidate semantics were considered.**

- **A (chosen) — hash the index tree as a third component.** Content rule, no
  interpretation: whatever the index would commit is part of the hash. Consequence:
  staging already-reviewed content changes the index tree, so it invalidates the review
  even though the bytes that would be committed are unchanged.
- **B (rejected) — hash the worktree tree plus an *index class*** (`matches-HEAD` /
  `matches-worktree` / `other:<tree-id>`). Semantically ideal: "the commit carries
  exactly what was reviewed", and `review → git add → commit` stays satisfied.

**Chosen: A. Staging invalidates.** The false invalidation is an accepted price under
invariant 2 ("loose in the firing direction"), and B buys its precision with a rule the
next reader has to re-derive before touching invariant 3. This repo has already paid
twice for exactly that kind of cleverness (rename detection; the invariant-checker
regex). A boring content rule that is wrong only in the safe direction is the house
style.

**What A costs, stated plainly:** the sequence `review → git add <reviewed file> →
git commit` as three separate steps now produces a STOP, and the hook cannot distinguish
it from a real edit. §4 mitigates by making the message explain its own possible
falseness; §5 rewrites test 3f to assert this decision instead of contradicting it.

**What A does not claim.** The guarantee is about **the index as it stands when the hook
is invoked**. A mutation that happens after the PreToolUse event — the compound
`printf x > f && git commit -am y`, or any concurrent writer — is still unseen; that is
the separate Parked defect (§7). The story's "regardless of how the divergence arose" is
narrowed to this snapshot semantics accordingly.

## 3. Design — `tree_hash()` gains an index-tree component

The temp index is already a copy of the real index. Take a tree id from it **before**
`git add -A` brings it up to the worktree, and both tree components come out of one temp
directory and two `write-tree` calls.

**The function's shape has to change, not just its contents.** Today the producers feed
`{ … } | shasum` directly, so a failure marker printed among them would be *checksummed
along with the partial output* — the guards downstream would never see the literal
`unavailable`, and two repeated failures could again produce equal hashes. The component
stream is therefore buffered to a file in the temp directory that already exists, and the
checksum runs only once every producer has succeeded:

```sh
tree_hash() {
  ok=1
  # same fallback order as today; no tool at all is itself a failure
  sum_cmd=$(command -v shasum || command -v sha1sum || command -v cksum) || ok=0
  tmp_dir=$(mktemp -d 2>/dev/null) || { tmp_dir=''; ok=0; }
  if [ -n "$tmp_dir" ]; then
  tmp_index="$tmp_dir/index"
  {
    # (0) tracked content, with the unborn-repo case positively identified
    if git -C "$repo_root" rev-parse --verify -q HEAD >/dev/null 2>&1; then
      git -C "$repo_root" diff HEAD -- . ':(exclude).context' 2>/dev/null || ok=0
    elif git -C "$repo_root" symbolic-ref -q HEAD >/dev/null 2>&1; then
      printf 'no-head\n'          # unborn branch: legitimate, nothing to diff against
    else
      ok=0                        # detached/corrupt/unreadable HEAD is NOT unborn
    fi

    # (1) and (2), from one throwaway index. git_dir must RESOLVE: an unchecked failure
    # yields "/index", which does not exist, so the absent-index carve-out would read it
    # as "nothing staged" and hand back the empty tree — a constant, hole reopened.
    # The chain's status is consumed by `if` directly: a following `[ $? -eq 0 ]` is
    # SC2181, which the hook cannot carry (linted with no exclusions).
    if git_dir=$(git -C "$repo_root" rev-parse --absolute-git-dir 2>/dev/null) &&
       [ -n "$git_dir" ] &&
       eff_index=${GIT_INDEX_FILE:-$git_dir/index} &&
       case "$eff_index" in            # a RELATIVE GIT_INDEX_FILE must be normalized
         /*) : ;;                      # against $repo_root — see below
         *) eff_index="$repo_root/$eff_index" ;;
       esac &&
       { [ ! -e "$eff_index" ] || cp "$eff_index" "$tmp_index" 2>/dev/null; } &&
       GIT_INDEX_FILE=… git rm -rfq --cached --ignore-unmatch -- .context >/dev/null 2>&1 &&
       GIT_INDEX_FILE=… git write-tree              &&   # (1) INDEX tree
       GIT_INDEX_FILE=… git add -A -- . ':(exclude).context' >/dev/null 2>&1 &&
       GIT_INDEX_FILE=… git write-tree                    # (2) WORKTREE tree
    then :; else ok=0; fi
  } > "$tmp_dir/stream" 2>/dev/null || ok=0
  fi        # the whole group is skipped when tmp_dir could not be created —
            # otherwise the redirect would target "/stream"

  h=''
  if [ "$ok" -eq 1 ]; then
    # The checksum's OWN status must be seen. `cmd < file | awk` reports awk's status,
    # so a checksum that fails after emitting a partial line would be accepted and
    # stored as a repeatable fingerprint — two failures comparing equal, which is the
    # false-✓ direction again. Capture, check status, then parse with a shell expansion
    # rather than a second command: `${raw%% *}` has no exit status to mask, so the
    # parser cannot fail half-way the way a piped `awk` can.
    if raw=$("$sum_cmd" < "$tmp_dir/stream" 2>/dev/null); then
      h=${raw%% *}
    fi
  fi
  [ -n "${tmp_dir:-}" ] && rm -rf "$tmp_dir" 2>/dev/null   # after the checksum reads it
  # a checksum tool that runs but produces nothing is a failure too, not an empty tree
  if [ -n "$h" ]; then printf '%s\n' "$h"; else printf 'unavailable\n'; fi
}
```

`ok` and the `git_dir` locals live in one shell — the buffering removes the pipeline that
previously forced a subshell, and a redirect on a `{ … }` group does not create one, so
the `ok=0` assignments inside it survive. Every read is initialized first or `:-`
defaulted, so `set -u` holds.

**Write it as `if`/`else`, not `[ … ] && … || …`** — for readability, not for lint.
Checked rather than assumed (shellcheck 0.11.0, `--shell=sh`): SC2015 does *not* fire
when the branches are builtin `printf`, so the terse form would have passed. It fires on
the function-call form, which is why `--exclude=SC2015` exists for the *test* file. The
hook is linted with no exclusions, so a future edit that turns either branch into a
helper call would start failing — `if`/`else` is the shape that stays lintable.

**Unborn is identified positively — and the residue is safe.** A bare "`rev-parse
--verify HEAD` failed" is not evidence of an unborn repo; `symbolic-ref -q HEAD`
succeeding while `--verify` fails is much closer to the real signature: a branch is
pointed at, with no commit yet. It is not *exclusive*, though — a symbolic HEAD whose
target ref exists but is corrupt satisfies it too, and so would a wrapper that fails only
the verify call. Those states take the `no-head` path rather than failing closed.

That is safe, and the reason is worth stating because it is not obvious: component (0) is
a *diff against a baseline*, while components (1) and (2) are complete descriptions of
the index and the worktree. Losing the baseline never loses content coverage — anything
that would land in a commit is still hashed by (1) and (2). What (0) adds is
discrimination between two states that share a tree but differ against HEAD; with no
resolvable HEAD there is no such distinction to lose. A wholly unresolvable HEAD (not
even symbolic) still fails closed, since that indicates a repo the hook cannot read at
all.

**A silent checksum is a failure.** If the checksum program runs but emits nothing, the
old code published an empty string, which the commit check reads as `[ -z "$reviewed" ]`
— the "no review has run" branch, whose message asserts a cause that is not true here.
Non-empty output is now part of success.

**The nonce goes away.** Today an uncomputable hash appends
`tree-unavailable-$(date +%s)$$`, betting that no two invocations share a second and a
PID. PID reuse inside one second is rare, not impossible, and the bet is on the
false-✓ side: two failing invocations that collide would compare equal and report
satisfied. Since the sentinel exists precisely to *never* match, make that a fact rather
than a probability — a constant `unavailable`, with the comparison treating it as
never-equal on either side:

```sh
if [ "$current" = unavailable ] || [ "$reviewed" = unavailable ] ||
   [ "$reviewed" != "$current" ]; then   # the stale branch
```

This is less machinery than the nonce, not more: one deterministic token, no clock, no
PID, and a failure that cannot be mistaken for a fingerprint. A stored `unavailable`
(the review pass itself could not hash) likewise never satisfies.

**One more consumer needs the guard.** The PostToolUse store path decides the *fresh*
pass count with `[ "$h" = "$prev" ]`. Two consecutive unhashable passes would compare
equal there and bump the fresh count — reporting that N passes cover the current tree
when none of them could see it. The satisfied branch is unreachable in that state anyway,
so the damage is confined to a number in a message, but the number is wrong and it is one
condition to prevent: require `[ "$h" != unavailable ]` before treating a repeat as
fresh, and zero the fresh count on an unhashable pass rather than starting it at 1 — a
pass that could not see the tree covers nothing. Every other consumer is a string
comparison that the two guards above already cover.

**Ordering and framing.** The two tree ids are consecutive lines in the buffered stream,
distinguished by position. The contract is all-or-nothing: any producer failing — HEAD
discrimination, git-dir resolution, the seed copy, `.context` removal, the diff, `add`,
either `write-tree`, or the checksum itself — clears `ok`, and a cleared `ok` means the
stream is never checksummed at all. So a short or partial stream can never become
something that looks like a fingerprint.

**The seed copy is inside the `&&` chain, and that is load-bearing.** Today a failed
`cp` means a cold index — slower, equally correct. Under this design a cold index is
*empty*, and `git write-tree` on an empty index **succeeds** with the well-known empty
tree `4b825dc…` (verified). Component (1) would then be a constant that matches itself
at review and at commit, silently reopening the hole. A failed copy must therefore fire,
not fall through.

**But an absent index is not a failed copy.** `git init` creates no `.git/index` at all
— it appears on the first `git add` (verified). Treating that as a copy failure would
make every hash in an unborn repo a fresh sentinel, so an initial `git commit
--allow-empty` could never be satisfied: a permanent STOP in exactly the repo state
where someone is setting the workflow up. When the index file does not exist, a cold
empty temp index is the *correct* answer, not a degraded one — no index means nothing
staged, and the empty tree is what a commit would carry. Hence the
`{ [ ! -e "$eff_index" ] || cp … ; }` guard: skip the copy when there is nothing to copy,
require it to succeed when there is.

**Keyed to `$eff_index`, not `$git_dir/index`** — the distinction is load-bearing once
the effective index can be an ambient `GIT_INDEX_FILE`. Git treats a `GIT_INDEX_FILE`
pointing at a *nonexistent* path as an empty index (verified: `write-tree` returns the
empty tree with rc 0), so the carve-out must follow the same path git will. Keyed to the
default index instead, the hook would demand a copy of a missing alternate index and
return `unavailable` forever in a situation git itself considers ordinary.

**The index to hash is the *effective* one.** `git commit` honours `GIT_INDEX_FILE`, so a
commit can carry a tree that neither HEAD nor the worktree ever held — verified: with an
alternate index staging `SNEAKY` and the worktree back at `v1`, the commit carried
`SNEAKY`. When `GIT_INDEX_FILE` is exported in the session the hook inherits the same
environment as the command it gates, so seeding from `${GIT_INDEX_FILE:-$git_dir/index}`
closes it in one line. The hook's own `GIT_INDEX_FILE=…` overrides are local to each `git`
call and unaffected.

A *command-local* override (`GIT_INDEX_FILE=alt git commit`) is invisible to the hook's
environment and is **not** handled here — that is story 2 (§7).

**A relative `GIT_INDEX_FILE` must be normalized against `$repo_root`.** Added at Gate B
on Task 2 (commit `92a23f0`), after this spec was approved — recorded here because
CLAUDE.md §5 requires a fix that changes specified behaviour to update the spec in the
same commit, and leaving it out is the docs-drift class this project already records
against itself. The `[ ! -e ]` test and the `cp` are plain shell commands resolved
against the HOOK's cwd, while every git call uses `-C "$repo_root"` and git resolves a
relative `GIT_INDEX_FILE` against the repository TOP-LEVEL (verified: from a
subdirectory, an index existing only at the top level resolves, and one existing only in
that subdirectory yields the empty tree). Without the normalization, the hook run from a
subdirectory takes the absent-index carve-out, the index component becomes the constant
empty tree, and the staged-vs-worktree false-PASS this story closes silently returns.
Test 27e covers it.

**`git rm` needs `-f`.** Without it, git refuses to remove a path whose staged content
differs from both HEAD and the worktree — exactly the divergent state this story is
about — and, with stderr redirected, does so silently (verified: `rc=1`, message
suppressed). The removal runs against the throwaway index only; the real staging area is
untouched (verified). `--ignore-unmatch` makes it a no-op when `.context/` is untracked.
Without the removal, a project that commits its adoption marker (the normal case) would
carry `.context/` into the index tree, where the hook's own state writes could
invalidate the review it just recorded.

**`git diff HEAD` failure is no longer silent.** A dropped component is a false-✓ risk in
its own right: the remaining components can self-match while tracked content goes
unhashed. Its status now feeds the same sentinel. The one legitimate failure — a repo
with no commits, where `HEAD` does not resolve — is discriminated up front and emits the
constant `no-head` token instead. Nothing is lost there: with no HEAD, components (1)
and (2) already describe all content, and emitting a nonce would STOP every commit in a
repo that has not made its first one.

Nothing else about the *hashing* changes: component ordering, the
`shasum`/`sha1sum`/`cksum` fallback order, and the exit-0 guarantee are untouched. Edits
outside `tree_hash()` are in scope where this section names them — the two comparison
guards, the fresh-count guard, and §4's message branches.

## 4. The STOP message must explain its own false-fire

The stale branch — the one reached when the stored and current fingerprints disagree, now
including the two `unavailable` guards from §3 rather than the bare `[ "$reviewed" !=
"$current" ]` it used to be — fires whenever they differ. That is **all** it knows. Five
distinct states reach this branch, and the message may assert none of them as *the* cause
(prompt-standards item 10):

1. content really changed since the review — the intended case;
2. already-reviewed content was merely staged (§2's accepted false fire);
3. the hash could not be computed (marker) — unwritable `TMPDIR`, a git failure;
4. the stored fingerprint predates this hook version, whose composition changed from
   two components to three;
5. **the fresh pass's fingerprint was never stored.** The PostToolUse path writes state
   with `{ printf … > "$state_file"; } 2>/dev/null || true` — deliberately silent, since
   the hook must always exit 0. If `.context/` is unwritable, a review that hashed
   perfectly leaves the old value behind, and the retry is stale forever. This one was
   missed until Gate A pass 5; it is invisible from inside `tree_hash`, which is why the
   message has to name it.

**The message states what the hook knows, which is one thing: it could not confirm that
the pending commit was reviewed.** Not that content changed — in the repeated-failure
path both values are the `unavailable` marker, so nothing "changed" and no fingerprint
"differs". Not that the recorded passes fail to cover the commit — under cause 5 a pass
may have reviewed exactly this content and only failed to record it. Every earlier draft
of this section asserted one of those, and each was false on at least one of the five
states. The exact `additionalContext` (product prompt text, so pinned rather than
paraphrased):

> STOP — Codex Gate B not satisfied: the hook cannot confirm that the content you are
> about to commit is the content mcp__codex__review last saw ($passes recorded pass(es)
> this cycle). Usually that means the working tree or the index changed since the review.
> It can also mean you only staged already-reviewed content — the bytes are fine, but the
> hook cannot tell staging from editing; that this hook was upgraded and the recorded
> fingerprint uses the older format (see CHANGELOG); or that the fresh fingerprint could
> not be computed or could not be stored. Run Gate B (mcp__codex__review) now — one clean
> pass is the complete remedy for the staging and post-upgrade cases too. If a fresh pass
> leaves this unchanged with nothing edited in between, the fault is in the machinery
> rather than the code: check that `.context/` is writable, that TMPDIR is writable, that
> a checksum tool (`shasum`, `sha1sum` or `cksum`) runs, that `git status` works, and
> that the disk is not full — then run one more pass to record a usable fingerprint. Per
> $policy you MUST re-review after every fix.

- `systemMessage`: `⚠ Codex Gate B not satisfied (cannot confirm review)`. Not "stale":
  when both values are `unavailable`, nothing became stale — confirmation was never
  established in the first place.

**The staging case gets no shortcut.** An earlier draft offered "commit via the WIP/amend
flow" as a way out without another pass. It is not one: the WIP commit moves HEAD, which
moves component (0), and the store path deliberately leaves the old fingerprint in place,
so the amend is still unconfirmed. The honest remedy for every cause here is one clean
pass, so the message says only that. (The WIP/amend flow remains what CLAUDE.md §5
prescribes for producing a reviewable `baseSha` — a different problem.)

**Why "a fresh pass leaves this unchanged" and not "retry immediately".** A mismatch of
*any* cause survives a bare retry — the stored fingerprint is only replaced by a review
pass. So "does it repeat?" separates nothing.

**Why it says "the fault is in the machinery" and stops there.** The two-invocation test
narrows; it does not name. A single transient failure during the fresh pass stores
`unavailable`, and a healthy retry then compares a good hash against it — still stale, in
a repo that is now fine. That is why the remedy ends with *run one more pass* rather than
declaring a permanent environment fault: the transient case needs exactly one more pass,
and the persistent case needs the checks first and then a pass anyway. One instruction
serves both.

**Why a bounded check-list and not a failure taxonomy.** Many distinct operations can set
the marker — temp dir, git-dir resolution, index copy, `.context` removal, the diff,
`add`, either `write-tree`, the checksum, HEAD discrimination — plus the state write,
which is outside `tree_hash` entirely. Reporting which one moved would mean carrying a
reason code out of a function whose whole contract is "one value that never collides",
and putting a multi-branch troubleshooting tree in a hook reminder. The five checks named
cover the things that actually differ between environments, including the two the earlier
drafts missed (`.context/` writability, checksum availability). Anything past them is a
bug report, not a user remedy. Stated here because "enumerate every cause" is otherwise
the obvious reading of prompt-standards item 10, and this is a deliberate departure.

**The *satisfied* branch overclaims too, and this change is what proves it.** It currently
tells the model that the fresh passes "actually reviewed what you are committing" and that
the tree is "unchanged since that review". §7 establishes why that is false: the hook
compares a fingerprint of *disk*, while `mcp__codex__review` reads a *git range*, so a
fingerprint match does not establish that Codex read those bytes. Leaving it while
correcting every neighbouring claim would ship the one sentence this spec's own analysis
disproves.

It becomes fingerprint-only: the passes cover the *same content fingerprint* as the one
being committed — with the code comment citing §7 for why the stronger phrasing was
dropped, so the next reader does not "restore" it as a clarity improvement. The narrower
claim is still the useful one: it is exactly what the hash can support.

**The "no review has run" branch needs the same treatment.** `[ -z "$reviewed" ]` no
longer means only "no pass this cycle": a first pass whose state write failed leaves it
empty, and so does a state file that exists but cannot be *read* (`cat` failing on
permissions, or holding nothing). All three must be covered, and all three parts of that
branch — not just the model-facing text:

- `additionalContext`: *no fingerprint is recorded for this cycle — either no
  mcp__codex__review has run, or the last one's fingerprint could not be written or read
  back. Check that `.context/` and the state file inside it are readable and writable; if
  the file exists but is unreadable or empty, delete it and run a fresh pass.*
- `systemMessage`: `⚠ Codex Gate B: no recorded review` — not "not run", which asserts
  the very cause that may be false.
- the adjacent code comment, which currently reads "nothing has been reviewed this
  cycle". A shipped comment stating the wrong reason outlives the prompt that was fixed
  around it; it must describe an absent *fingerprint*, not an absent review.

One message per branch, and no new branches: telling the causes apart would mean
reporting which component moved, which is more machinery than the ambiguity is worth.

**Upgrade note.** Adding a third component changes every stored fingerprint's meaning, so
the first commit attempt after upgrading invalidates any in-flight review once. One pass
clears it; the CHANGELOG entry must say so, or it reads as a bug.

## 5. Tests (`plugins/dev-workflow/hooks/codex-gate.test.sh`)

1. **New — the divergence repro.** Review a tree; edit and `git add` new content; restore
   the worktree bytes to HEAD's (per §1, *not* `git checkout --`); assert **not
   satisfied**. Mutation-verified: with the index component removed, this test fails.
2. **Rewritten — 3f.** Now asserts *staging a reviewed tracked file invalidates*, with a
   comment naming this spec and §2's decision. The current comment asserts the opposite
   as a principle; leaving it is the silent contradiction AC-3 exists to prevent.

   Its trailing "untracked file on a staged tree → not satisfied" assertion must be
   re-based or dropped, not just carried along: once staging alone invalidates, that
   assertion passes no matter what the untracked file does, so it would sit in the suite
   looking like coverage while testing nothing. Either re-review to a clean state on the
   staged tree first, then add the untracked file — or delete it, since test 3c already
   covers untracked content.
3. **New — self-match.** A tree with staged content produces a hash that matches itself
   across two hook invocations with no intervening change (no STOP-forever on a state the
   hash can compute).
4. **New — seed-copy failure fires.** A stub `cp` earlier on `PATH` that exits non-zero
   makes the gate read **not satisfied**. This is the regression guard for §3's
   load-bearing claim: a future `|| true` on that line silently restores the false-✓
   defect, and nothing else would catch it. `PATH` interposition is portable POSIX and
   needs no new test harness.

   It must also assert the fresh count is **0** after a failed pass, and still 0 after a
   repeated one — the §3 store-path guard is new specified behaviour, and without an
   assertion an implementation can keep writing 1 while every verdict test stays green.

   **The fault must be active for BOTH fingerprints** — the one the review pass stores
   *and* the one the commit check computes — with no state change in between. Enabling it
   only at commit time proves nothing: the fingerprints would differ anyway, so the test
   would pass even against a broken `cp … || true`. With the fault spanning both and the
   handling broken, both sides compute the same empty-tree-based hash and the gate reports
   *satisfied* — which is exactly what the test must catch. That sequencing is what makes
   the mutation verification real, and it doubles as the "repeated failure never
   satisfies" case that retires the old nonce (§3).
5. **New — unborn repo.** In a repo with no commits and no `.git/index`, the hash
   self-matches across invocations and an initial `git commit --allow-empty` can reach
   satisfied. Guards the §3 absent-index carve-out: without it, the `cp`-must-succeed
   rule silently STOPs every first commit.
6. **New — `git diff HEAD` failure fires.** A selective `git` wrapper earlier on `PATH`
   that delegates every subcommand except `diff` (which it fails) must leave the gate
   **not satisfied** — under the same both-fingerprints sequencing as test 4, and for the
   same reason. Without this, the newly specified `diff_rc` handling can be dropped or
   regressed with the whole suite green.
7. **New — `.context/` in three-way divergence.** A *tracked* `.context/` file whose index
   bytes differ from both HEAD and the worktree — the state that makes `git rm --cached`
   refuse without `-f` (verified) — must still hash and self-match; mutation-verified by
   dropping `-f`.

   **It must also assert the user's real index is untouched:** capture the real index's
   tree id, the staged `.context` blob, *and the index file's raw bytes* before the hook
   runs, and require all three identical after. The semantic checks alone can pass while
   extension/stat-cache bytes shift, which is weaker than AC-4's no-modification claim —
   test 12 already byte-compares, so this matches it. The new `-f` makes this a data-loss path — a future edit that drops
   `GIT_INDEX_FILE` from that one command would force-unstage the user's real `.context`
   entries, and a self-match-only test stays green while it happens.
8. **New — unresolvable git-dir fires.** A selective `git` wrapper that fails only
   `rev-parse --absolute-git-dir`, active across both fingerprints, must leave the gate
   **not satisfied**. AC-4 names this path; without a test the pass-3 regression can
   return through an incomplete implementation with the plan looking complete.
9. **New — checksum failure fires.** A stub checksum program that exits 0 but prints
   nothing must yield `unavailable`, not an empty fingerprint — i.e. the commit check
   must reach the stale branch, *not* the "no review has run" branch whose message would
   assert a false cause. Same both-fingerprints sequencing as tests 4, 6 and 8: with the
   stub active only at commit time, a mismatch against the earlier valid hash proves
   nothing about whether the empty-output handling exists.

   **A second stub covers the other half:** one that prints a plausible token and *then*
   exits non-zero. That is the case the masked-status defect allowed — output looks fine,
   status is ignored, and two such invocations self-match into a false ✓. Empty-output
   and failing-with-output are different mutations; a test for one does not catch the
   other.
10. **New — message text.** Assert every clause AC-5 promises: the cannot-confirm label,
    the staging explanation, the compute-or-store failure mention, both remedies (fresh
    pass — no WIP/amend shortcut), the post-upgrade case, and the fresh-pass
    discriminator with all five of its checks (`.context/` writable, TMPDIR writable,
    checksum tool runs, `git status` works, disk not full). Not "repeat immediately" — that
    wording was the pass-3 defect and a test asserting it would re-enshrine it. AC-5 is
    product behaviour (invariant 11), so an unasserted clause regresses with the suite
    green.
10b. **New — satisfied-branch wording.** The satisfied message must not claim the passes
    reviewed the content, only that they cover the same fingerprint. Assert the absence of
    the old "actually reviewed what you are committing" phrasing as well as the presence of
    the new one — a message test that only checks for new text stays green if both survive.
11. **New — unstorable state.** Three shapes, because they reach the branch by different
    routes:
    - *Replacement fails.* Make the **state file itself** read-only (not just its parent
      — a redirect can still truncate an existing writable file inside a non-writable
      directory, so `chmod` on the directory would test something else or nothing).
      Change the tree, run a pass, prove the stored bytes are unchanged, then assert the
      commit check does not claim the recorded passes cover the commit.
    - *First write fails*, with no prior state: assert the empty-state branch admits an
      unwritten-or-unreadable fingerprint rather than flatly "no review has run".
    - *Read fails*: an existing, non-empty state file that cannot be read. It reaches the
      empty-state branch by a different route than an unwritten one, so the routing can
      regress independently while the message text still matches. Assert the message and
      that the hook still exits 0 (invariant 1).

    Cause 5 lives outside `tree_hash`, so no other test reaches it.

    **These three depend on `chmod` actually denying access, which is false under an
    effective root uid** — a root-run CI job would silently exercise the success path and
    then fail on the assertion, reporting a product defect that is really a privilege
    artefact. Probe the *exact* operation each fixture depends on — replacing an existing
    file, creating a file in a directory, and reading a file are three different denials,
    and a platform can grant one while refusing another — restore whatever the probe
    changed, and skip with a printed reason when the fault cannot be induced. A skipped
    test that says why beats a red one that lies.
12. **New — ambient alternate index.** Three shapes, because a negative-only test would
    be satisfied by an implementation that simply fires whenever `GIT_INDEX_FILE` is set —
    a permanent STOP, not a fix:
    - *Divergent:* record the review fingerprint **without** the alternate index, then
      enable a divergent ambient `GIT_INDEX_FILE` for the commit check only → **not
      satisfied** (verified as a real false-✓ today). The sequencing has to be pinned: if
      the same alternate index spanned both, the next shape would require *satisfied*, and
      the two would specify contradictory implementations. Mutation-verify against seeding
      `$git_dir/index`.
    - *Stable:* review and commit under the **same unchanged** alternate index →
      **satisfied**, with the alternate index and the default index each byte-identical to
      *its own* snapshot taken before the hook ran (not to each other — they legitimately
      differ). This is the assertion that stops "always fire" from passing.
    - *Missing path:* `GIT_INDEX_FILE` pointing at a nonexistent path is an empty index to
      git (verified), so the hook must hash and **self-match** there rather than returning
      `unavailable`, with both index files untouched. This is the guard against keying the
      absent-index carve-out to the default index.

    Command-local overrides and retargeted-repo commands are story 2 (§7); no test here
    covers them, and none should — a test for a guard this story does not ship would fail
    or, worse, pass vacuously.

13. **Preserved.** `.context/` churn — tracked and untracked — still does not invalidate
    (existing 3e / 3e-bis, now also exercising the index component).

14. **Existing assertions that this change breaks.** Two must be updated in the same
    commit or the suite fails on a correct implementation:
    - **line 63** asserts the literal `tree has CHANGED`, which the new message does not
      contain. Re-point it at the new label.
    - **line 126's NOTE** says tree_hash's "could not be computed" guard has no
      regression test. Tests 4, 6, 8 and 9 give it several. Narrow it to what stays
      uncovered — the `git add`/`write-tree` failure seam — rather than deleting it: the
      todos.md row it points at is the *tree-unavailable test* row, which stays parked.
      That row needs the same narrowing, so the two keep agreeing.

**Every failure test must reach the floor.** The hook checks empty state, then stale,
then the floor — the floor is *last*. That is exactly why the fixture must meet it: the
mutation these tests exist to catch makes two failing hashes match, which skips the stale
branch and falls through to the floor. With one pass the result is "below floor" — not
satisfied, but for the wrong reason, so the test would stay green against the mutation. Use the existing `.context/codex-gate.floor`
override (set it to 1) or run three faulted passes, then assert.

Not covered, deliberately: post-invocation mutation (§7). Tests 4 and 6 establish a
`PATH`-interposition seam that the Parked "no regression test for tree_hash's *tree
unavailable* guard" item also wants — that item nonetheless **stays parked**; building
the seam here for paths this story introduces is not licence to spend its budget.

## 6. Docs and invariants

Every site that describes the hash as worktree-only, found by grep rather than memory —
docs-drift is this repo's own most frequent finding class:

- **`AGENTS.md:86`, invariant 3** — "compares a hash of the working tree" names the
  referent this story proves wrong. Amend to state all three components (diff vs HEAD,
  index tree, worktree tree) and why the index one exists: the commit takes the index.
- **Hook header, lines 6–11** — "a hash of the working tree", "compares what is actually
  on disk".
- **The satisfied branch's message** (~line 407) — "actually reviewed what you are
  committing" / "unchanged since that review". Same false claim as line 105, in the
  message users and the model see most often. Narrow to fingerprint equality, with a
  comment citing §7.
- **Hook line 105** — "unlike Gate B, where the tree-hash proves what was reviewed". §7
  establishes that this is false: the hash proves equality with a recorded *disk*
  fingerprint, not that Codex read those bytes (it reads a git range). Correcting the
  surrounding hash comments while leaving this one would ship a claim the same change
  disproves. Narrow it to what the hash actually proves.
- **Hook comment block, ~150–193** — delete the `KNOWN GAP` paragraph, correct the
  "`git add` … does not change the hash" paragraph to state §2's decision, and note that
  the seed copy is now correctness-critical.
- **`README.md:26`** — "verify a Gate-B review against the actual content of the working
  tree".
- **`docs/architecture.md:64–72`** — names the two components, and asserts the check is
  "tied to what is actually on disk". (Its "an edit-then-undo correctly stays valid"
  sentence remains true — an unstaged edit-then-undo still matches — but re-read it in
  context once the surrounding text changes.)
- **`plugins/dev-workflow/commands/workflow-init.md:777`** — a *shipped prompt*, not
  prose: the scaffolded explanation says `.context/` is excluded "on both the tracked and
  untracked side". With a third component that sentence is incomplete. (Missed by the
  first grep, which paired *worktree* with hash words; found at Gate A pass 2.)
- **The story itself** (`docs/superpowers/stories/2026-07-18-…-story.md`) — its §2 still
  promises detection "regardless of how the divergence arose", which §2 of this spec
  narrows to snapshot semantics, and **all three** of its §5 open questions are now
  settled: the bare-`git add` question (§2 here), whether the answer should depend on
  commit shape (no — one content rule covers every shape, but only as of the **hook's
  invocation**: `git commit` and `git commit -a` are fully covered, while
  `git add X && git commit` is a compound command whose staging runs *after* the
  PreToolUse fingerprint and therefore stays the separate Parked defect — §2, §7), and
  whether invariant 3's wording needs amending (yes — §6 here). Replace each with its answer, or the story contradicts the spec built from it.
  (Missed by the §6 grep twice: the story is the one doc that describes the behaviour
  without using the word *hash*.)
- **`docs/getting-started.md:46`** — "(staging alone doesn't; `git add` changes no
  content)" is the plainest statement of the behaviour Option A reverses, in the one
  document a new user reads end to end. Rewrite the parenthetical.
- **`todos.md`** — remove the Parked row this closes, and add one for the review-range
  gap surfaced at Gate A pass 8 (below). The other four Parked hook items
  stay parked.
- **Version bump + CHANGELOG** — invariant 12: the hook is under `plugins/`, so the
  manifest version bumps in the same PR with a `CHANGELOG.md` entry.
- **Hardening ledger** — a row for this finding, per `dev-workflow:harden-finding`.

## 7. Out of scope

The other Parked hook items — jq-free escaped-quote parsing, compound commands hashing
the pre-mutation tree, the `tree-unavailable` guard's missing test, temp-index object
churn. The compound-command item is adjacent (it also concerns what a commit carries)
but is a separate defect with a separate fix.

**Raised at Gate A pass 8 and deliberately not taken: the review-range gap.** Codex
argued that a review pass blesses the *fingerprint* of the index and worktree, while
`mcp__codex__review` reads a **git range** — so content that is staged but never
committed can be fingerprinted as reviewed without Codex having read it, and three such
passes reach ✓.

That is true, and it is not this story. It is a property of how Gate B has always worked:
the hook records what is on disk, the reviewer reads history, and CLAUDE.md §5's
WIP-commit flow exists precisely to make the range contain the work. Closing it would
mean refusing to satisfy Gate B unless the index and worktree correspond to the reviewed
range — effectively mandating a WIP commit for every review, which redefines the gate
rather than fixing a hash. This story is about the fingerprint disagreeing with *the
commit*; that one is about the fingerprint disagreeing with *the reviewer*. Different
defect, different decision, its own story: **a new `todos.md` Parked row** (§6), not a
silent expansion of this one.

**Non-goal: the command-retargeting guard — split into its own story.** A commit whose
*command* selects a different index, git dir or work tree (`GIT_INDEX_FILE=`, `GIT_DIR=`,
`GIT_WORK_TREE=`, `-C`, `--git-dir`, `--work-tree`) is a real false-✓ path — verified,
`GIT_INDEX_FILE=alt git commit` committed content the worktree never held — but it is not
this story's defect and is not fixed here. Story 2 owns it:
`docs/superpowers/stories/2026-07-19-command-retargeting-guard-story.md`.

Why it moved out: it began as a two-line addition at Gate A pass 7 and grew into a
cohesive second feature — its own STOP branch and message, a placement rule relative to
`is_docs_only` and the WIP exemption, and an eight-shape test matrix. Five successive
bypasses (backslash-newline, `-\C`, quoted `GIT_INDEX_"FILE"=`, `${x-}` expansion, brace
expansion) each drew one more token into a blocklist, which is the pattern AGENTS.md's
escalation trigger names as the same rung applied repeatedly rather than the ladder
working. Story 2 starts from default-deny instead, decided rather than discovered.

Only the *ambient* case stays here, because it is a property of which index to hash rather
than of parsing a command: one `${GIT_INDEX_FILE:-…}` in `tree_hash()` (§3).

## 8. Acceptance criteria

- [ ] **AC-1** Staging new content, then restoring the worktree bytes to HEAD's → **not
      satisfied** at commit time.
- [ ] **AC-2** That scenario has a regression test, mutation-verified: reverting the fix
      makes it fail.
- [ ] **AC-3** The bare-`git add` question is answered in writing (§2) and test 3f is
      rewritten to assert that answer, with a comment naming the decision.
- [ ] **AC-4** Every state whose hash **can** be computed *and whose git configuration is
      deterministic* matches itself across
      invocations with no intervening change (no STOP-forever) — including an unborn repo
      with no `.git/index`, and a tracked `.context/` file diverging three ways. Every
      state whose hash **cannot** be computed fails closed: reads unreviewed, never
      satisfied — including seed-copy failure, `git diff HEAD` failure, and unresolvable
      git-dir, each with the fault spanning both fingerprints so that repeated failure
      never self-matches. Both directions are exercised by tests, and the hook must not
      leave the user's real index or staging area modified in any of them.
- [ ] **AC-5** The stale STOP message claims only what the hook knows — that it cannot
      confirm the pending commit was reviewed — names the staging and compute/store cases
      without asserting any as *the* cause, and carries the fresh-pass discriminator with
      its five environment checks (§4). The empty-state branch likewise admits an
      unstored fingerprint, and the **satisfied** branch claims fingerprint equality
      rather than that Codex reviewed the content (§7). Each clause asserted by a test,
      including all five checks.
- [ ] **AC-6** Invariant 3's wording covers the index component, and every doc site
      listed in §6 is updated in the same change.
- [ ] **AC-7** Quality battery green, including `shellcheck --shell=sh` and the hook
      suite under `sh`.
- [ ] **AC-8** Plugin manifest `version` bumped with a matching `CHANGELOG.md` entry
      (invariant 12), and that entry states the one-time post-upgrade invalidation (§4).
- [ ] **AC-10** Story 2 exists on disk at the path §7 names before this story closes.
      Removing the Parked row while its split-off half has only a dangling reference would
      lose the follow-up work entirely — the row is the current owner, so the replacement
      owner has to exist first.
- [ ] **AC-9** The Parked `todos.md` row this closes is removed, and a hardening-ledger
      row is appended.
