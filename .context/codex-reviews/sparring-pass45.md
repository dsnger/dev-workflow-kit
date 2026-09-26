## ANCESTRY REPAIR

Replace Resume's entire **Validate the base** shell block with this block. The added ancestry check is between resolving `$BASE` and accepting `$BASE` as an ancestor of `HEAD`; every existing message and the existing stop behavior remain unchanged. This is a Resume precondition check: it exits before Resume accepts the base and does not create a Failure handoff. If Resume was entered during an existing Failure handoff, that handoff remains in force and this block changes nothing.

```sh
# The branch, FIRST and before anything reads or writes cycle state. `.context/` is
# ignored, so the base file survives a checkout: on another branch descended from
# $BASE every check below passes and the WIP commits, the soft reset and the closing
# commit all land on the wrong branch. A detached HEAD prints `HEAD` and is refused
# for the same reason.
test "$(git rev-parse --abbrev-ref HEAD)" = loop-rule-consolidation \
  || { echo "not on loop-rule-consolidation (on: $(git rev-parse --abbrev-ref HEAD)) — refusing to re-enter"; exit 1; }

test -e .context/loop-rule-base || { echo "no base file — this is a first entry, run Preparation"; exit 1; }
test -s .context/loop-rule-base || { echo "base file is EMPTY — inspect, delete deliberately, record why, re-record from the true starting commit"; exit 1; }
BASE=$(cat .context/loop-rule-base)
test "${#BASE}" -eq 40 || { echo "base is not a full 40-character object name"; exit 1; }
case "$BASE" in *[!0-9a-f]*) echo "base is not an object name: $BASE"; exit 1 ;; esac
test "$(git rev-parse --verify "$BASE^{commit}")" = "$BASE" || { echo "base does not resolve to itself as a commit"; exit 1; }
git merge-base --is-ancestor ba15e83 "$BASE" || { echo "ba15e83 is NOT an ancestor of the base"; exit 1; }
git merge-base --is-ancestor "$BASE" HEAD || { echo "base is NOT an ancestor of HEAD"; exit 1; }
for f in target-text design condition-inventory; do
  p="docs/superpowers/specs/2026-09-10-loop-rule-consolidation-$f.md"
  # Resolve separately and check each status: `git rev-parse` can print its unresolved
  # argument even when it fails, and equal revision expressions can therefore make two
  # failed lookups compare equal.
  BASE_ID=$(git rev-parse "$BASE:$p") \
    || { echo "$p does not resolve at \$BASE — the comparison is unestablished; stop"; exit 1; }
  APPROVED_ID=$(git rev-parse "ba15e83:$p") \
    || { echo "$p does not resolve at ba15e83 — the comparison is unestablished; stop"; exit 1; }
  test "$BASE_ID" = "$APPROVED_ID" \
    || { echo "$p differs at the base from its approved version"; exit 1; }
done
```

Replace accounting row 3 with exactly:

```markdown
| 3 | `ba15e83` is an ancestor of the cycle's starting revision | **kept, and split by entry, like row 4**: Preparation checks it at `HEAD`, because a first entry has no recorded base; **Resume checks it at `$BASE`**, because that is the persisted starting revision Gate B diffs from and the close resets to. An earlier revision assigned it to Preparation alone, so a base older than `ba15e83` could pass Resume where the three approved-input blobs happened to match |
```

## TASK 10

This is a pre-existing gap. At `4752a35`, before the twelfth revision, the executor saw only the zero-context hunk headers produced by `grep` and `sed`, followed by the `note` locations; the complete removed and added lines were not printed or persisted by the fenced block. The prose told the executor to read them, but supplied no body to read after the block ran. I verified that with:

```sh
git show 4752a35:docs/superpowers/plans/2026-09-14-loop-rule-consolidation.md | nl -ba | sed -n '2120,2185p'
```

Use this minimal replacement block. It keeps the guarded read, prints the complete diff for the required inspection, then retains the hunk-start list as an aid:

```sh
BASE=$(cat .context/loop-rule-base)
test -n "$BASE" || { echo "BASE empty or unreadable — Task 0 did not run"; exit 1; }
# Capture before filtering so a failed read cannot become an empty hunk list.
DIFFOUT=$(git diff -U0 "$BASE" -- plugins/dev-workflow/hooks/codex-gate.sh) \
  || { echo "git diff FAILED — the changed-line list is unestablished; stop"; exit 1; }
printf '%s\n' "$DIFFOUT"                         # READ EVERY REMOVED AND ADDED LINE
printf '%s\n' "$DIFFOUT" | grep -E '^@@' | sed -E 's/^@@ -([0-9]+).*/\1/'
grep -n 'note "' plugins/dev-workflow/hooks/codex-gate.sh
```

## THE OVERSTATEMENT

At `docs/superpowers/plans/2026-09-14-loop-rule-consolidation.md:3057`–`3059` in `fc12f25`, the offending sentence is:

> The previous candidate's closing tip. Guarded: where the path cannot be removed the stale tip survives, and 8b's condition 5 would compare `HEAD` against a value this run never produced.

The last clause is false. A successful candidate close must run 8a before 8b, and 8a rewrites `.context/loop-rule-reviewed-tip` with the new record commit after all its preceding checks. The stale value left by this failed removal therefore cannot be the value condition 5 reads in a correctly followed closing sequence. The real risk is issuing the next review call with the old candidate's tip marker still present beside the new candidate's reviewed-head marker.

Replace the comment with:

```sh
# The previous candidate's closing tip. Guarded: without the guard, a failed removal
# leaves the stale tip beside the next candidate's reviewed head, so the next call is
# issued with two candidates' markers present.
rm -f .context/loop-rule-reviewed-tip \
  || { echo "removing the previous candidate's tip FAILED — it survives; no call may be issued"; exit 1; }
```

## CONFIRMATIONS

The `case $?` rewrite of 8a's per-file carry check is correct: status 0 means the file was not carried and must fail, status 1 is the required difference, and status 2 or above is a comparison failure that must not be accepted as a difference.

Both `>&2` uses inside the `for ... done > file` loops are correct: the loop's stdout is the blob-list artifact, so each failure diagnostic must bypass that redirection or it would be written into the artifact instead of shown to the executor.

## ANYTHING ELSE WRONG

The new explanations at `docs/superpowers/plans/2026-09-14-loop-rule-consolidation.md:354`–`355` and `:588`–`589` are factually wrong when they say two failed `git rev-parse` substitutions produce empty strings. In this repository's Git, a failed `git rev-parse "<rev>:<missing-path>"` writes the unresolved argument to stdout and exits 128. Two failures compare equal only when the two revision expressions are themselves equal, such as `HEAD = ba15e83` or `$BASE = ba15e83`; when the revisions differ, the emitted strings differ. The separate guarded assignments are still the right implementation because success must depend on both exit statuses.

Use these comments:

```sh
# Resolve separately and check each status: `git rev-parse` can print its unresolved
# argument even when it fails, and equal revision expressions can therefore make two
# failed lookups compare equal.
```

and in Resume:

```sh
# Resolve separately, for the reason Preparation's copy gives: a failed lookup can
# still print its unresolved argument, so equality alone does not establish success.
```
