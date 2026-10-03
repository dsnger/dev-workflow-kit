# Spec-delta for the Gate-B reviewer — design

**Story:** `docs/superpowers/stories/2026-10-03-spec-delta-for-gate-b-story.md` — read the profile from its header at every gate call.

Vision step 2c, part 3, narrowed on 2026-10-03 to an **explicit baseline comparison**. The epic is
`docs/superpowers/stories/2026-10-02-telemetry-and-review-loop-usefulness-story.md` (criterion 6).

## §1 What it is

`scripts/spec-delta.py` is a read-only report for a Gate-B call. For every relevant spec and plan
(§3), it shows the change from a **given baseline** to the Gate-B candidate. It checks the
baseline's Gate-A metadata and shows any ambiguity. Its claim is exactly: "compared with the given
baseline; Gate-A metadata checked". **It never states that a Gate-A cycle reviewed this file in
this version**, because no record names the file a cycle reviewed.

The output is plain text, made to be pasted into a Gate-B call's `additionalContext` beside the
diff. It writes nothing. It is repo-local and not shipped, like `scripts/ledger-metrics.py`,
`scripts/run-analytics.py` and `scripts/loop-usefulness.py`.

**It informs and obliges nothing** (story, decided 2026-10-03). It changes no pass-validity rule,
floor, closure condition, gate obligation or record format. A non-empty delta reopens nothing.

| Path | Change |
|---|---|
| `scripts/spec-delta.py` | **New.** Python 3.8+, standard library. |
| `scripts/spec-delta.test.sh` | **New.** POSIX-sh suite with a fixture repository. |
| `AGENTS.md`, `.github/workflows/ci.yml`, `README.md` | The suite joins the quality and lint rows and CI; the inventories count the new script. |

Nothing under `plugins/` changes, so invariant 12 does not bind.

## §2 Invocation

```
python3 -B scripts/spec-delta.py [--base <ref>] [--plan <path>]... [--spec <path>]... [--baseline <ref>:<path>]... [<head>]
```

- `<head>` is the Gate-B candidate (default `HEAD`); `--base` is the Gate-B `baseSha`.
- `--plan` names a contributing plan. It is repeatable, and needed when a plan is unchanged in
  `<base>..<head>`, for example under the pre-commit WIP range CLAUDE.md §5 prescribes.
- `--spec` names a relevant spec that no other rule selects, for example one unchanged in the
  range and cited elsewhere than a plan header. It is repeatable; with no `--baseline` for it, it
  shows as "baseline missing — unknown".
- `--baseline` names an artifact's baseline in git's own `<ref>:<path>` form, split on the first
  `:` (a ref name cannot contain one). It is repeatable. Recent plans in this repository record
  their spec's closing commit in the header (for example "closed in `f9aae57`"); older ones do not,
  and then the caller has to find the commit.

`<head>` and `--base` are resolved with `git rev-parse --verify --end-of-options <ref>^{commit}`;
either not resolving is exit 1. A **baseline** ref that does not resolve — for example an original
closing commit lost to a squash merge or missing from this clone — is **not** an exit: that
artifact's state is "baseline commit not available — unknown", and the rest of the report runs.
The same path given twice with different refs is exit 1, "conflicting baselines for <path>".

## §3 Which artifacts are relevant

1. **Contributing plans:** every `--plan`, plus, with `--base`, every `docs/superpowers/plans/*.md`
   path that a commit in `<base>..<head>` changes. They are deduplicated.
1a. **Changed specs:** with `--base`, every `docs/superpowers/specs/*.md` path that a commit in
   `<base>..<head>` changes, whether or not a plan cites it.
2. **Cited specs:** for each contributing plan, every backticked path matching
   `docs/superpowers/specs/*.md` on the plan's **header** `**Spec:**` line. That is the first line
   that starts `**Spec:**` and comes before the plan's first `## ` heading. Task-level `**Spec:**`
   lines later in a plan are not read. The plan is read at `<head>`, or, if it is absent there and
   `--base` is given, at `<base>`. A plan that cannot be read at either is listed as "plan not
   readable" with its specs unknown, and a plan with no header `**Spec:**` line, or one naming no
   spec path, is listed as "no spec header" — both in the plan's own block.
3. Every `--spec` and every `--baseline` path.

The relevant set is the union. Each member gets a block, so a plan that did not change in the range
never hides its specs, and a relevant artifact without a `--baseline` is shown as **baseline
missing — unknown**. The report never substitutes another text, such as a squash commit's, for a
missing baseline.

## §4 Baseline checks and states

For each artifact with a baseline `<path>@<commit>`, the report checks and shows:
- whether the path exists at `<commit>` (if not: "baseline path absent at <commit>", and no
  comparison);
- the cycle records in `<commit>`'s body, **quoted verbatim**, one per line: every line that
  `scripts/ledger-metrics.py`'s `CANDIDATE` matches, each marked "matching kind" when
  `parse_record` returns a curve or skip record whose kind is `Gate-A spec` (for
  `docs/superpowers/specs/`) or `Gate-A plan` (for `docs/superpowers/plans/`), and "unparsed" when
  `parse_record` rejects it. The report joins, pairs or interprets nothing further. A provenance
  line has no kind, and a pre-rule record identifies no cycle, so both are quoted and never
  counted as matches. The reader sees exactly what the commit claims;
- **ambiguity**, each case named:
  - no matching-kind record ("no Gate-A record of this kind at the baseline");
  - matching-kind records naming more than one cycle field;
  - the commit changing more than one path of the same kind (specs or plans), so that which file
    a cycle reviewed is not settled by the commit;
  - the commit also carrying a `Gate B` curve — a sign that it may be a squash of a later state
    rather than the original close.

These checks qualify the comparison and never block it. Then:

| State | When | Shown |
|---|---|---|
| **no change** | content at `<commit>` equals content at `<head>` | the checks |
| **changed** | content differs | the checks, then the diff from `<commit>` to `<head>` for the path |
| **renamed or deleted** | the path is absent at `<head>` | the checks; for a rename detected by `git diff --find-renames` between the two commits, the new path and its diff; otherwise the deletion diff |
| **baseline missing — unknown** | a relevant artifact with no `--baseline` | nothing else |
| **baseline path absent** | the path does not exist at `<commit>` | the checks |
| **baseline commit not available — unknown** | the baseline ref does not resolve | the ref as given |

**Git hygiene,** as in `scripts/loop-usefulness.py`:
- remove repository-selecting variables and `GIT_TRACE*`, and set `GIT_TRACE2*` to `0`;
- read with `--no-replace-objects` and an empty graft file;
- disable signature display;
- refuse partial clones (exit 1).

Diffs use `--no-color --no-ext-diff --no-textconv --no-relative`, plus `-c diff.noprefix=false
-c diff.mnemonicPrefix=false -c core.quotePath=true`. These neutralize the settings they name —
colour, external diff drivers, text conversion, relative paths, prefixes and path quoting — and
the list is not exhaustive. A shallow repository is noted in the header, because a baseline commit may be missing
there. A missing baseline commit is that artifact's "baseline commit not available — unknown"
(§2); only `<head>` and `--base` are fatal.

## §5 The report

Plain text on stdout:

1. **Header:**
   - `<head>` and `<base>` (if given) as full shas, and whether history is shallow;
   - the relevant artifacts with their counts per state;
   - the line "compared with given baselines; Gate-A metadata checked; review attribution not
     established; informs and obliges nothing".
2. **One block per artifact**: specs first, then plans, each sorted by path. A block starts with
   `== <path>`, then the baseline, its checks, the state and any diff.
3. **What this report cannot establish:**
   - which file a Gate-A cycle reviewed;
   - whether a change was reviewed or intended;
   - whether a spec still matches the code;
   - an original text lost to a squash merge;
   - relevant artifacts outside the given and discovered set;
   - specs cited elsewhere than the plan header.

Exit 0 on success. Exit 1, with `spec-delta: <reason>` on stderr and nothing on stdout, when:
- `<head>` or `--base` does not resolve, or baselines conflict;
- history cannot be read;
- git is missing or older than 2.36;
- the repository is a partial clone;
- the parser cannot be loaded.

The report is meant to be run under `python3 -B`, so the interpreter's own startup writes no
bytecode either. The script itself turns bytecode off before its first import, as part 2 does.

## §6 Tests and the real Gate-B input

`scripts/spec-delta.test.sh` builds a fixture repository and compares the whole report with
expected text. It covers:
- a spec with a baseline, then edited (**changed**, with the diff), and one untouched (**no
  change**);
- a plan with a baseline, then edited;
- a plan header citing two specs, one with and one without a baseline (**baseline missing**);
- an unchanged plan given by `--plan`, whose specs still appear;
- a plan deleted at `<head>`, read at `<base>`;
- a renamed spec and a deleted spec (with its deletion diff);
- a spec changed in the range that no plan cites (it still appears);
- a baseline ref that does not resolve (that artifact is unknown, the rest runs);
- a plan with no header `**Spec:**` line;
- record quoting: a matching curve, a matching skip record, a provenance line, a pre-rule record,
  a record of another kind, and an unparsed candidate line, each marked as §4 says;
- a spec selected only by `--spec`, without a baseline;
- each ambiguity: no metadata, two cycles, two specs changed in the baseline commit, and a
  baseline commit that also carries a `Gate B` curve;
- a baseline path absent at its commit, and conflicting baselines (exit 1);
- an unresolvable ref and a partial clone (exit 1, nothing on stdout);
- user diff configuration (`diff.noprefix`, `diff.relative`, an external diff driver) that leaves
  the report unchanged;
- the run writes nothing: repository and HOME are unchanged, ignored files included, under
  `python3 -B`;
- a negative control: a copy that reads every `**Spec:**` line instead of the header line picks
  up task-level references, and the suite catches it.

**The real Gate-B input (story criterion 4):** this story's own Gate-B calls carry the report for
this story's spec and plan, with `--baseline` set to their Gate-A closing commits. The evidence
entry records the exact invocation, the `<head>` sha, the report's header line and each
artifact's state line, so a reader can rerun it.

## §7 Story criteria

| Criterion | Where |
|---|---|
| 1 baseline checks, ambiguity shown, no attribution claimed | §1, §4 |
| 2 delta with explicit no-change / renamed or deleted | §4 |
| 3 every relevant spec appears; a missing baseline is unknown | §3 |
| 4 real Gate-B input and fixture check | §6 |
| 5 no rule or record change; stated limits | §1, §5 |
