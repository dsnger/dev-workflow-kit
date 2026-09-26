# Gate A — plan — pass 1 dispositions

19 findings, 13 Major, 6 Minor. All 19 accepted; none dismissed. One reached back into a
committed artifact (the spec's story), which was corrected rather than worked around.

## The finding that mattered most

**1 (MAJOR)** — `${lit:0:60}` is bash-only substring expansion. My pre-commit sweep ran `sh -n`
over every fenced block and passed it, because `sh -n` is a **parse** check and this construct
is syntactically valid; it fails at *runtime* under `dash` with `Bad substitution`. Verified
directly: `dash -c 'lit=abcdef; echo "${lit:0:3}"'` → `dash: 1: Bad substitution`.

The plan now uses `printf '%.Ns'`, and Global Constraints names the class of constructs `sh -n`
cannot catch. The sweep itself was extended: parse under **both** `sh -n` and `dash -n`, then
grep for `${var:o:l}`, `[[ ]]`, `<(...)`, `local`, arrays.

## Fixed — mechanical correctness

- **3 (MAJOR)** — `grep -c` exits 1 on a zero count, so every expected-zero check would abort on
  the correct result. All are now captured with `|| true` and compared numerically.
- **2 (MAJOR)** — Task 2's "only AGENTS.md" grep could never succeed: the spec and the plan both
  quote the phrase, so the check always reached its stop branch. Narrowed to `AGENTS.md` alone,
  with the reason stated — those other occurrences are quotations of the rule, not copies of it.
- **12 (MAJOR)** — the battery includes `check-version-bump.sh main`, which fails on a committed
  `plugins/` change with no bump. With the bump at Task 8, Tasks 2–7 would each have asserted
  "expected exit 0" against a battery that cannot pass. The manifest bump moved into **Task 1**,
  alongside the first `plugins/` change.
- **11 (MINOR)** — six vs seven `todos.md` updates. Corrected everywhere to seven, one new plus
  six existing.
- **13 (MINOR)** — the ledger precondition stopped only on a count that was too high; too low
  equally invalidates the premise. Now requires exact equality on all four and prints the
  matching rows so the stop report can name them.
- **19 (MINOR)** — `FIRST_WIP` could match several commits after a retry. Now asserts exactly one
  anchor and prints the range before any `reset --soft`.

## Fixed — structure and procedure

- **6 (MAJOR)** — the three trigger stories had seven `##` sections; the template allows six. The
  inheritance inventory became a `###` subsection of §1. Verified: all four embedded stories now
  have exactly six.
- **7, 8 (MAJOR)** — the collision procedure classified once up front and left the write
  unspecified. Now each path is classified immediately before its own write, with `set -C` so
  creation fails if an entry appeared meanwhile, and `[ -L ]` tested separately because `[ -e ]`
  is false for a dangling symlink.
- **14 (MAJOR)** — the cross-finding conflict check ran at validation time; the spec requires it
  before any edit. It is now **Task 0**.
- **16 (MAJOR)** — mirror parity ran once before the first commit. Now also in Task 9, after every
  Gate-B fix, and immediately before the closing amend.
- **18 (MINOR)** — `todos.md` mutations were unconditional. Each now has an idempotency guard:
  absent → apply, identical → skip, different → stop.

## Fixed — claims the plan could not support

- **5 (MAJOR)** — `/path/to/final-message.txt` and `/path/to/pr-body.md` were placeholders in a
  plan asserting it had none. Replaced by `.context/evidence-0.8.1.md` with its full template,
  defined in Task 9 Step 1 before any step reads it, and a `<fill` guard that stops the amend if
  the template ships unfilled.
- **15 (MAJOR)** — validation results had no destination and would have died with the session.
  Same evidence file, with a field structure per section.
- **9 (MAJOR)** — a split story claimed §5 would stop on a fabricated profile. It would not: §5
  stops on a malformed or inconsistent profile, not on well-formed values nobody confirmed.
  Reworded in all four stories. An overclaim about what a gate detects, inside the round
  hardening that class.
- **17 (MINOR)** — the plan demanded byte-identical mirrors while checking normalized
  equivalence. Normalized equivalence is now the stated requirement, since the two files wrap at
  different widths and nest at different depths.
- **10 (MINOR)** — the ledger-supersession story omitted invariants 11 and 12, which bind only if
  the design reaches the scaffolded template. Added as explicitly conditional.

## Reached back into a committed artifact

**4 (MAJOR)** — the story's AC 7 still read "before design begins" while the spec and the
amendment log read "resumes". Real drift from the pass-9 spec fix: I corrected the spec and wrote
the amendment entry, and never the criterion itself. Corrected in the story.

My first check for this reported no occurrence — a line-oriented grep against text wrapped across
lines 159–160. The normalized search found it. That is the wrap artifact the §5.3 sweep sentence
names, hit while verifying a finding about wrap-sensitive text.
