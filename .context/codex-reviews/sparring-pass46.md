# Sparring recommendation — Gate-A plan pass 46

## 1. PREMISE CHECK

**Observed.** The asserted requirement exists, almost verbatim. Target §A says:

> “Every finding-derived predicate reads the validated findings file **or files** of the logical pass as **the concatenation of their finding lines after each file has been validated separately**.”

That is `docs/superpowers/specs/2026-09-10-loop-rule-consolidation-target-text.md:85-89`. The same paragraph says closure also reads every closure condition the cycle has (`...target-text.md:91-93`). Target §A separately says Gate B has no gate-specific content condition (`...target-text.md:68-70`), but that does not remove A1's gate-general validated-file read rule.

`CLAUDE.md` defines what that validation means. A pass is accepted only when each required file is readable, has the exact terminator, contains exactly the declared number of finding lines and nothing else, and, for full Gate B, both branch files pass those checks (`CLAUDE.md:478-486`). It then defines structural failure and severity parsing, including wrong field count, empty severity, malformed lines, bad terminator, and count mismatch (`CLAUDE.md:488-497`).

**Conclusion.** The reviewer did **not** construct the premise. Every predicate derived from the findings must read files that were separately validated. What the two texts do **not** require is the reviewer's entire proposed mechanism: they do not say every intermediate record commit must duplicate Close condition 4's post-commit structural and eligibility procedure. They state the input invariant; the plan may establish it by binding the later read to the already validated blobs.

## 2. SCOPE VERDICT

**Recommendation: treat the core finding as a repair to an existing condition. Do not adopt the reviewer's full prescribed remedy.**

**Observed.** The plan itself admits the gap. It says the current `git write-tree` pin is “not the content the pass acceptance validated,” that a rewrite before staging is pinned and passes, and that step one has no structural re-run (`docs/superpowers/plans/2026-09-14-loop-rule-consolidation.md:2949-2953`). Step two then makes finding-derived decisions: source-block repair, suspension and membership handling, park, close, or continue (`...loop-rule-consolidation.md:3006-3023`). The current shell only proves that the commit tree equals the index written after staging (`...loop-rule-consolidation.md:2963-2999`). It does not prove that step two's input is the accepted snapshot.

**Reasoning.** Once step two derives a route from the findings, §A's existing validated-input rule applies. Disclosure accurately describes noncompliance; it does not turn that noncompliance into an allowed limit. Changing the acceptance operation so that it pins the accepted blob IDs, checking those IDs against `HEAD` after the record commit, and making step two read `HEAD:<slot>` changes **how the existing condition is established**. It adds no success predicate or closure condition.

The asymmetry has two parts:

- The lack of **any binding** in step one is an omission. The “different consumers” explanation cannot justify it because step two is itself a consumer of finding-derived predicates.
- The lack of a **second structural and eligibility re-run** can remain deliberate. Close condition 4 expressly requires three cumulative facts for the closing commit: path and parent, identity with the validated blobs, and a new structural/eligibility check on committed content (`...loop-rule-consolidation.md:403-415`). Step one's record commit is not the closing commit. If object-ID equality establishes that `HEAD:<slot>` is exactly the already validated input and step two reads that immutable committed content, §A and `CLAUDE.md` are satisfied without copying Close condition 4's third bullet.

## 3. IF REPAIR

Make the two `*_VALIDATED` assignments below the final act of the existing §5 acceptance operation. In the sentence introducing step two, state: **“Step two reads the two committed blobs with `git show "HEAD:$SPEC"` and `git show "HEAD:$QUAL"`; it does not read either worktree path.”** That sentence is necessary: a worktree-only hook rewrite is harmless only if the consumer actually reads `HEAD`.

Replace the current step-one shell with this block. It keeps the plan precondition, guarded `git add`, whole-index `git write-tree` pin, both blob-type checks, tree comparison, all existing failure messages, one shell block, and no `set -e` or `pipefail`:

```bash
NONCE=<this cycle's nonce>; P=<this pass's number>
SPEC=".context/codex-reviews/gate-b-spec-$NONCE-pass-$P.md"
QUAL=".context/codex-reviews/gate-b-quality-$NONCE-pass-$P.md"
PLAN=docs/superpowers/plans/2026-09-14-loop-rule-consolidation.md

# These assignments are the final act of accepting the result under CLAUDE.md §5:
# they pin the exact bytes that were separately validated, before anything is staged.
SPEC_VALIDATED=$(git hash-object "$SPEC") \
  || { echo "pinning the validated blob for $SPEC FAILED — the pass is not accepted; step two does not run"; exit 1; }
QUAL_VALIDATED=$(git hash-object "$QUAL") \
  || { echo "pinning the validated blob for $QUAL FAILED — the pass is not accepted; step two does not run"; exit 1; }

# The plan is not staged here and must be unchanged: HEAD against the index (what the
# commit takes), then the index against the worktree. A difference and a failed
# comparison both stop, and neither says what caused it — report the state.
git diff --quiet --cached HEAD -- "$PLAN" \
  || { echo "plan is not identical between HEAD and the index, or the comparison failed — stop and report the state"; exit 1; }
git diff --quiet -- "$PLAN" \
  || { echo "plan is not identical between the index and the worktree, or the comparison failed — stop and report the state"; exit 1; }

git add "$SPEC" "$QUAL" \
  || { echo "staging FAILED — the pass is not recorded; step two does not run"; exit 1; }

# Pinned after staging, before the commit: the WHOLE index as staged at that moment,
# unrelated paths included.
ITREE=$(git write-tree) \
  || { echo "cannot pin the staged index; step two does not run"; exit 1; }

# A successful add does not mean these paths are present — it stages a removal too.
# Require a blob at each: an existence test would accept a directory at the path.
test "$(git cat-file -t "$ITREE:$SPEC" 2>/dev/null)" = blob \
  || { echo "$SPEC is not a blob in the staged index; the pass is not recorded, step two does not run"; exit 1; }
test "$(git cat-file -t "$ITREE:$QUAL" 2>/dev/null)" = blob \
  || { echo "$QUAL is not a blob in the staged index; the pass is not recorded, step two does not run"; exit 1; }

git commit -m "WIP: pass $P records" \
  || { echo "records commit FAILED — stop here; step two does not run"; exit 1; }

# Any divergence between the pinned index and the resulting commit tree stops here,
# whatever produced it.
test "$(git rev-parse "HEAD^{tree}")" = "$ITREE" \
  || { echo "the commit's tree is not the index that was pinned; step two does not run"; exit 1; }

# Bind what step two will read to the exact blobs accepted above. Guard the reads:
# failed rev-parse commands must not leave two junk or empty values to compare equal.
SPEC_COMMITTED=$(git rev-parse "HEAD:$SPEC") \
  || { echo "reading the committed blob for $SPEC FAILED — step two does not run"; exit 1; }
QUAL_COMMITTED=$(git rev-parse "HEAD:$QUAL") \
  || { echo "reading the committed blob for $QUAL FAILED — step two does not run"; exit 1; }
test "$SPEC_COMMITTED" = "$SPEC_VALIDATED" \
  || { echo "$SPEC is not the validated findings blob; step two does not run"; exit 1; }
test "$QUAL_COMMITTED" = "$QUAL_VALIDATED" \
  || { echo "$QUAL is not the validated findings blob; step two does not run"; exit 1; }
```

This is deliberately smaller than Close condition 4: it adds identity binding and fixes the consumer. It does not add that closure condition's independent post-commit structural/eligibility predicate.

**Verification performed outside the repository.** I substituted `NONCE='test'; P=46` and ran `sh -n`, `dash -n`, `bash -n`, and `shellcheck --shell=sh` on `/tmp/sparring-pass46-step7.sh`; all exited 0. In disposable `/tmp` repositories:

- a pre-commit hook that rewrote only the worktree slot let the block exit 0, while `HEAD` retained `END OF FINDINGS (1 total)` and the worktree contained `rewritten only in worktree`; this confirms why step two must read `HEAD`;
- an edit injected after the validated hashes but before `git add` exited 1 with `.context/codex-reviews/gate-b-spec-test-pass-46.md is not the validated findings blob; step two does not run`;
- a pre-commit hook that rewrote and staged the slot exited 1 with `the commit's tree is not the index that was pinned; step two does not run`.

These executions test the mechanics. **Reasoning:** object-ID equality means the committed bytes are the already accepted bytes; therefore re-running the same structural predicate cannot change the result unless the acceptance-to-hash binding was not actually performed as specified.

## 4. IF NEW OBLIGATION

This is not my verdict. A human choosing the reviewer's stronger remedy would be agreeing that every nonclosing pass-record commit must independently re-run the full findings-file structure and branch-eligibility checks on `HEAD`, even when blob identity already proves that `HEAD` contains the accepted snapshot; neither target §A nor `CLAUDE.md` currently states that extra procedural duty. The cheapest defensible alternatives are the identity binding plus committed-content read in §3, or “disclose the limit and do nothing”; the latter is the current state and knowingly leaves the existing §A condition unenforced when the bytes change.

## 5. COST CHECK

**Observed history.** The recent record shows a high repair-regression rate followed by three stabilizing rounds:

- Pass 40 found that the preceding repair's directory pathspec swept another cycle's files (`.context/codex-reviews/gate-a-plan-om0bdd7udh-resume.md:304`).
- Pass 41 called its only finding “this round's own repair” (`...resume.md:306`).
- Pass 42 says two of three findings were introduced by the preceding narrowing (`...resume.md:308`).
- Pass 43 says the three pass-42 findings were repaired, but its Minor found that the newly added blob check accepted a symlink; the check's addition is recorded immediately before it (`...resume.md:309-310`).
- Passes 44 and 45 say nothing was re-raised against the preceding revisions (`...resume.md:312-314`).
- The thirteenth revision preceding pass 46 changed Resume ancestry and Task 10 diff display (`...resume.md:315`). Pass 46 instead points to the older, expressly disclosed step-one limit (`.context/codex-reviews/gate-a-plan-om0bdd7udh-pass-46.md:1` and plan `:2949-2953`), so it was not created by the pass-45 repair.

That is four repair-created findings in the first four of the last seven repair-to-review transitions, followed by three transitions with none. The headline trend is also 9 → 2 → 1 at passes 44-46 (`...resume.md:312`, `...resume.md:314`, and `...pass-46.md:1-2`).

**Reasoned estimate: about one chance in three, plausibly 25-40%, that the next pass raises a finding created by this repair.** The raw recent rate, four of seven, argues against a low-single-digit estimate; the last three clean descendant checks, the narrow object-ID addition, and the `/tmp` shell and hook checks justify discounting the raw 57%. The remaining likely attack surface is semantic rather than shell portability: whether “the final act of acceptance” binds the human validation tightly enough to the two hashes, and whether step two is stated unambiguously enough to read `HEAD` rather than the worktree.

## Evidence and repository state

- `git rev-parse --verify HEAD` returned `f9bd330b793ea04e883dfcb07d3ca9eff031d6b8`.
- `git diff --exit-code f9bd330 -- CLAUDE.md docs/superpowers/specs/2026-09-10-loop-rule-consolidation-target-text.md docs/superpowers/plans/2026-09-14-loop-rule-consolidation.md .context/codex-reviews/gate-a-plan-om0bdd7udh-resume.md` exited 0, so the cited tracked texts are exactly the versions at the named commit.
- Before this requested report was written, `git status --short` showed only the supplied pass-46 findings file as untracked. No tracked file was edited, staged, or committed.
