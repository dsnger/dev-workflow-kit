# Spec — CI check: a plugin change requires a version bump

## Problem

Changes to `plugins/dev-workflow/**` can merge without changing the plugin's
`version`. An installed copy lives under a version-keyed cache path, so an un-bumped
change never propagates: the machine keeps running the old code with no signal that
it is stale.

Evidence (source `manual`, severity `major`):
1. A machine ran plugin 0.1.0 for days while main was at 0.3.0/0.4.0 — bumps only
   happened when someone remembered to ask.
2. The 0.4.0 bump had to be requested during PR #4 review rather than falling out of
   the process.
3. (Confirmed against git while writing this spec) main is *already* stale: `fe5e296`
   and `793e234` changed `plugins/dev-workflow/commands/{process-pr-review,workflow-init}.md`
   after the 0.4.0 bump, with no bump of their own.

The rule "plugin change ⇒ version bump" exists only as convention. Nothing checks it.

## Rule

A pull request that changes any path under `plugins/<name>/`, **where that directory
still exists at HEAD**, must also change `plugins/<name>/.claude-plugin/plugin.json`'s
`version` field to a value different from the one at the merge-base with the PR's base
branch. If the directory survives but the manifest does not, the run **fails closed** —
a plugin that still ships with no version to key on is a defect, not an exemption.

The "exists at HEAD" clause is the deletion carve-out, and it is about the **directory**
only: a plugin whose whole directory is removed is not enumerated at all, so it has no
version left to bump. **Deleting just the manifest, while the directory keeps shipping,
fails closed** — revised here after Gate B raised it twice. The original carve-out
covered both on the reasoning that a missing manifest leaves nothing to compare; that
was wrong in the case that matters, because the directory's content still reaches users
and "no exemptions" was false while it stood. Removing a plugin is a marketplace-level change — the entry
disappears from `.claude-plugin/marketplace.json` — and this check has nothing to say
about it. **Residual gap, accepted and documented:** deleting a plugin does not force
a bump anywhere, so already-installed copies of the deleted plugin keep working from
their cache. That is out of scope here; no mechanism in this repo addresses it today.

## Scope decision (explicit)

**Every path under `plugins/<name>/` counts. No exemptions — including `examples/`.**

Rationale, worded so it does not collide with invariant 7: everything under the
plugin directory is part of the **package a user receives** when the plugin is added
or updated — the cache copies the directory wholesale. Invariant 7 says something
different and still holds: `examples/` is never *installed into a user's project*,
never copied by a command, never presented as a default. Both are true — it ships,
and it is not scaffolded. A stale shipped example is the same propagation failure as
stale skill text.

The second reason is the one that actually decides it: any exemption list requires the
check to judge which paths "matter", and that judgment is precisely what failed as a
convention.

`plugin.json` is itself under `plugins/<name>/`, so a bump-only commit trivially
satisfies the rule — the changed file *is* the version.

## Mechanism (rung 2 — mechanical check in CI)

New `scripts/check-version-bump.sh`, alongside `scripts/check-invariants.sh`, in the
same style (POSIX `sh`, no `jq`, names every offender rather than the first, header
comment stating its own limits) with a companion `scripts/check-version-bump.test.sh`
of reject/accept pairs.

Invocation: `sh scripts/check-version-bump.sh <base-ref>` — **exactly one argument**.
Zero or more than one prints a usage line and exits non-zero, rather than dying on
`set -u` or silently ignoring the extras.

The script `cd`s to its own repository root first (`cd "$(dirname "$0")/.."`, as
`check-invariants.sh` does): the `plugins/` pathspecs below are relative, so running it
from a subdirectory would otherwise enumerate nothing and exit clean — a false pass.

Every git invocation uses `git --literal-pathspecs`. `--` stops *option* parsing but
does not disable pathspec magic, so a directory name containing `*`, `?`, `[…]` or a
leading `:` would still be interpreted as a pattern.

1. Resolve `mb=$(git merge-base <base-ref> HEAD)`. **Fail closed** (exit non-zero,
   diagnostic naming the ref) if `<base-ref>` does not resolve or there is no
   merge-base — an unavailable base is an operational error, not a clean tree.
2. Enumerate the plugin directories **from HEAD's tree**
   (`git ls-tree -d --name-only HEAD plugins/` — `-d`, because a plain `ls-tree` lists
   blobs too, and a stray `plugins/notes.md` would then be run through the
   directory-name grammar or, worse, processed as if it were a plugin), never from a
   `plugins/*/` filesystem
   glob: a dirty local checkout that deleted a plugin directory would otherwise hide a
   committed un-bumped change, a false local pass CI cannot reproduce. **The
   enumeration's own exit status is checked** — output and status captured separately —
   and a non-zero status fails closed. An unchecked enumeration that errors returns an
   empty list, and an empty list means "no plugins changed", i.e. a false clean exit
   before any of the per-plugin fail-closed branches can run.

   **Every enumerated directory name must match `[A-Za-z0-9._-]+`; anything else fails
   closed**, naming the offending entry. This is a constraint on the repo, not a
   limitation of the checker: plugin directory names are ours to choose, and a name with
   a space, quote, backslash, newline or leading `:` is not something to support here.
   The alternative is worse — `git ls-tree --name-only` emits *C-quoted* pathnames for
   exotic names, so a line-oriented loop would feed a quoted display form back to git as
   a literal path, `diff` would report that non-existent path unchanged, and the plugin
   would be **skipped silently**. A false skip is the dangerous direction; a name the
   loop cannot round-trip must stop the run, not slip through it. (POSIX `sh` cannot
   read NUL-delimited input, so `-z` is not an option.)

   For each enumerated plugin directory:
   - `git diff --quiet "$mb" HEAD -- "plugins/<name>/"`. Exit 0 = unchanged, skip;
     exit 1 = changed, continue; **any other exit = operational error → fail closed**.
   - **Fail closed** if `plugins/<name>/.claude-plugin/plugin.json` is absent **from
     HEAD's tree** while the directory itself is present and changed: the content still
     ships and nothing keys it. (An earlier revision skipped here; that was the
     manifest-only-deletion hole Gate B found.) Tested with
     `git ls-tree HEAD -- <manifest>`, whose
     states are distinguishable: non-zero exit = error (fail closed), zero exit with
     empty output = genuinely absent. `git cat-file -e` cannot be used for this: it
     returns 128 both for an absent path and for a lookup failure, so "new plugin" and
     "broken object database" would be indistinguishable — and the safe direction is
     to fail, not to pass with an empty base version.
   - Read the version at HEAD (`git show "HEAD:<manifest>"`) and at the merge-base
     (`git show "$mb:<manifest>"`). **Both sides are read from commits, never from the
     working tree** — otherwise a dirty local checkout could supply an uncommitted
     bump for a committed change, giving a local result CI cannot reproduce.
     **Each `show`'s output and exit status are captured separately and a non-zero
     status fails closed with a read-error diagnostic** — a partial read that still
     contains a parseable `"version"` must not be accepted as the version, and a
     genuine read failure must not be misreported as a malformed manifest.
   - The manifest missing *at the merge-base* is the legitimate "new plugin" case,
     established the same way (`git ls-tree "$mb" -- <manifest>`, empty output =
     absent) rather than inferred from `git show` failing. New plugin → base version
     empty → any version passes. **Identity is the directory path, full stop** — see
     the rename entry under "does NOT catch", and the note below on why matching by
     manifest `name` was tried and rejected.
   - Version extraction, in two steps: match with
     `grep -o '"version"[[:space:]]*:[[:space:]]*"[^"]*"'`, no `jq`, then **strip the
     key, colon and surrounding whitespace so only the quoted value is compared.**
     Comparing the raw matched fragment would make `"version": "0.4.0"` and
     `"version":"0.4.0"` differ — a reformat of the manifest would read as a bump and
     let an un-bumped plugin change pass, which is the exact failure being hardened.
     Applied to **both** sides. **Exactly one match required in every manifest that
     exists** — the absent merge-base manifest of a genuinely new plugin is the one
     exemption, and it is established by `ls-tree` before extraction is attempted, not
     by extraction returning nothing. Zero or several matches is a fail-closed error
     (an ambiguous manifest is not a checked manifest). This is a line-oriented grep,
     not a JSON parser, so it compares the *spelling* of the value, not the parsed
     value. **A version value containing a backslash fails closed**, one line that
     removes the whole escape-equivalence class: a value spelled with a `\uXXXX`
     escape (e.g. `0.4.\u0030`) parses as `0.4.0` but
     spells differently, so without the guard a manifest could "change version" while
     the plugin's actual version stood still — the failure being hardened, wearing a
     JSON escape. (An escaped *key* — `\u0076ersion` — needs no separate guard: the
     grep finds zero matches and the exactly-one rule already fails closed.)
     Three further ceilings, all stated in the header comment: a nested
     `"version"` key elsewhere in the manifest is matched too, and a manifest that
     splits the key, colon and value across lines — valid JSON — yields zero matches
     and **fails closed** rather than passing. Failing a reformatted manifest is the
     safe direction and the fix is to put the pair back on one line, but a reader
     should not have to discover that from a diagnostic.
   - Equal versions → record a failure naming the plugin and both versions.
3. **Accumulate across plugins**, print every offender, exit 1 once — matching
   `check-invariants.sh`'s "prints every offending line, not just the first".

## CI wiring

- A step gated on `if: github.event_name == 'pull_request'`. The base ref reaches the
  script through an `env:` value, **never interpolated into the shell source**:
  `env: { BASE_REF: "${{ github.base_ref }}" }` and
  `run: sh scripts/check-version-bump.sh "origin/$BASE_REF"`. Git ref names may contain
  `$`, backticks, quotes and semicolons; direct `${{ }}` interpolation would splice a
  branch name into the generated run script as code rather than passing it as data.
- The existing `actions/checkout` step gains `fetch-depth: 0`, so the base branch and
  a merge-base exist at all (default depth 1 has neither). The repo is small.
- The **shellcheck step gains both new files**, `--shell=sh` and **no exclusion for
  either**. The existing suites carry `--exclude=SC2015` for their
  `[ c ] && pass || fail` lines; this suite has none of those, so every rule applies
  as-is. (Written as "matching the existing pair" in an earlier revision; corrected to
  match what shipped, since an unnecessary exclusion is a weakened lint.) Same pinned
  `koalaman/shellcheck:v0.11.0` image; no new action, nothing new to pin.
  Note on attribution: invariant 4 sits under **Hook** and is about the hook running on
  machines we do not control. It does not reach a repo-local CI script, so neither the
  script's header nor the new invariant may claim invariant 4 covers it. The POSIX-`sh`
  requirement for this checker is stated in its own right (it matches
  `check-invariants.sh`, and CI invokes both with `sh`).
- The **test suite runs unconditionally**, in the existing invariant-checks step: it
  builds throwaway git repos in `mktemp -d` and needs no PR context.

**On push to main: skipped, deliberately.** A push to main has no PR base to diff
against. The push event *does* carry a before/after range that could be diffed, so this
is a scope choice, not an impossibility: on main the work has already been gated by its
PR run, and re-checking it there would mostly re-report the same verdict. (An earlier
revision justified this by claiming a push-range check "would fail every direct-to-main
commit" — that is simply false: a docs-only commit or a correctly bumped one would pass.
Reviewed out rather than left standing, since a wrong reason for a right decision is how
the decision gets reversed later for the wrong reason.) The assumption — stated rather
than implied — is that plugin changes arrive through PRs; a direct push is unchecked.

## What this check does NOT catch (honest-claim rule, prompt-standards item 11)

Stated in the script's header comment, in the AGENTS.md invariant, and in the ledger
`ref`:

- **Semantic correctness of the bump.** It verifies a bump is *present*, not that it is
  *right*: a patch bump where a minor was due passes.
- **Direction.** Any different string passes, including a decrease (`0.4.0` → `0.3.9`).
- **Concurrent PRs colliding on the same new version.** Two PRs branched from 0.4.0
  can each bump to 0.4.1 and each pass; after the first merges, the second still
  carries a version already published. The check cannot close this — it only ever sees
  its own merge-base. What closes it is the repo setting "require branches to be up to
  date before merging", which forces the second PR to rebase and re-run against the
  merged 0.4.1. (A merge queue is *not* offered as the fix: a required check would need
  `merge_group` wiring this workflow does not have, and a multi-PR group could still
  contain two identical bumps.) Documented, not fixed, and not claimed to be fixed by
  configuration this repo has not enabled.
- **Anything outside a `pull_request` event** — a commit pushed directly to main
  bypasses the check entirely.
- **Deletion of an entire plugin directory** — see the rule's carve-out. Deleting only
  the manifest is *not* in this list: that fails closed.
- **Any change to *which directory* the marketplace entry points at** — a rename, a
  copy, or repointing `source` in `.claude-plugin/marketplace.json` at a different
  existing directory. The check's notion of identity is the directory path, so the old
  path reads as a deletion (carve-out) or as unchanged, and the new one as a newly added
  plugin: the delivered plugin changes while an unchanged version passes. The rename is
  only the most obvious member of this class, and the invariant, the script header and
  the ledger all state it as the class, not as "renames".

  This was *specified as closed* in an earlier revision — matching manifest `name`
  across the two trees — and then deliberately reopened. Identity-by-`name` needs its
  own cross-tree enumeration with its own error handling, an exactly-one normalized
  `name` extraction on every candidate manifest, and defined behaviour for duplicate
  names, malformed names, swapped directories and a move onto an occupied path. Review
  raised each of those as a fresh defect in the fix. That is a large, ambiguity-laden
  mechanism for a case that has never occurred in this repo, in a marketplace that
  currently ships exactly one plugin.

  **This is accepted residual risk, not a covered case.** "Bump by hand when you move a
  plugin" is an unenforced convention — the same kind of convention whose failure
  produced this finding — and nothing here makes a reviewer notice the
  `marketplace.json` edit. It is written down so the next person inherits a known gap
  instead of a false sense of coverage. Revisit when the marketplace grows past one
  plugin, or the first time a move actually happens.
- **Whether the version was released or tagged.** It reads the manifest only.

## Test matrix (each row is one assertion in `check-version-bump.test.sh`)

**Policy rejects** (reach the version comparison):
- P1 plugin file changed, version identical
- P2 `examples/` file changed, version identical (pins the scope decision)
- P3 two plugins changed, only one bumped → the unbumped one is named, exit 1
- P4 two plugins changed, *neither* bumped → **both** names appear, one exit 1
  (a first-failure implementation passes P3 but fails here)
- P7 manifest **reformatted** (`"version":"0.4.0"` — whitespace around the colon
  changed, value identical) alongside a plugin change → still rejected; pins that the
  comparison is on the value, not the matched fragment
- P8 the committed plugin change is un-bumped and the **working tree** carries the bump
  (uncommitted) → still rejected; pins the commit-derived read
- P9 the committed plugin change is un-bumped and the working tree has **deleted** the
  plugin directory → still rejected; pins HEAD-tree enumeration over a filesystem glob
- P10 run from a **subdirectory** of the repo with an un-bumped plugin change → still
  rejected; pins the repo-root anchoring

**Operational rejects** (fail closed before any comparison):
- O1 base ref that does not resolve → diagnostic names the ref
- O2 valid ref with no merge-base (unrelated histories) → diagnostic names the cause
- O3 HEAD manifest with no `version` field
- O4 HEAD manifest with two `version` matches
- O5 merge-base manifest with no `version` field
- O6 merge-base manifest with two `version` matches
- O7–O13 **git itself failing**, one row per load-bearing call — the full list, since a
  call without a row is a fail-closed branch nobody proved: `merge-base` resolution,
  directory enumeration (`ls-tree` over `plugins/`), the change test (`diff --quiet`,
  exit >1), the **HEAD** manifest presence lookup, the **merge-base** manifest presence
  lookup, the HEAD manifest read (`show`), the merge-base manifest read.
  Exercised with a `git` wrapper earlier on `PATH`.
  **The wrapper matches on the full argument vector, not the subcommand alone** — the
  enumeration and both presence lookups are all `ls-tree`, so a subcommand-only wrapper
  would trip on the first one and never reach the branches O9–O11 claim to cover, while
  the suite still went green. Each row asserts its own diagnostic, so a wrapper that
  fires at the wrong call is visible.
  Without these rows, an implementation that collapses "git errored" into "absent" or
  "unchanged" satisfies the whole rest of the matrix — which is exactly the fix
  revision 3 made, left unprotected.
- O14 invoked with no argument, and O15 with two → usage diagnostic, non-zero
- O15b a version value carrying a `\uXXXX` escape (`0.4.\u0030`, which parses as
  `0.4.0`) → fail closed, rather than counting as a bump away from `0.4.0`
- O18 the manifest alone deleted while the directory and its changed content remain →
  fail closed ("no version to key on"). A5 (whole directory deleted) stays accepted; the
  asymmetry is deliberate and each row pins one side of it.
- O16 a plugin directory name containing a space → fail closed naming it (rejected by
  the grammar; `ls-tree` does *not* quote spaces, so this row alone does not exercise
  the quoting path)
- O17 a plugin directory name git actually C-quotes — one containing a tab or a
  backslash → fail closed. This is the row that pins the silent-skip regression; O16
  would stay green even if C-quoted names slipped through.

**Accepts:**
- A1 plugin file changed, version changed
- A2 nothing under `plugins/` changed (docs-only PR), version identical
- A3 bump-only change (manifest is the sole changed file)
- A4 newly added plugin (no manifest at the merge-base)
- A5 plugin directory deleted at HEAD (carve-out; no manifest to bump)
- A7 two plugins changed, both bumped
- A8 version *decreased* (`0.4.0` → `0.3.9`) — pins the documented "direction is not
  checked" limitation as tested behaviour rather than an unverified claim
- A9 a plugin directory renamed **with** a bump — pins that the rename gap is a gap in
  detection only, and that a renamed-and-bumped plugin is not spuriously rejected
- A10 a **file** directly under `plugins/` whose name violates the directory grammar —
  `plugins/release notes.md` — changed, no bump → accepted and ignored. The name matters:
  with a grammar-conforming name like `plugins/notes.md`, an implementation missing `-d`
  would enumerate the blob, append `/`, diff a path that does not exist, report
  "unchanged" and pass anyway. The spaced name is the one that fails loudly without `-d`.

**Mutation verification** (the exact mutation, so the claim is reproducible): replace
the version comparison `[ "$base_ver" = "$head_ver" ]` with `false`, so the check can
never report a stale version. Expected: **every P row fails and nothing else** — the O
rows never reach the comparison and must stay green, and no accept row changes. The
suite reports policy and operational rejects as separate groups so an ineffective
mutation cannot look convincing.

## Prose half

1. `plugins/dev-workflow/CHANGELOG.md` — one entry for **every version the manifest
   has ever carried in git history**: 0.1.0, 0.2.0, 0.2.1, 0.3.0, 0.4.0, 0.4.1. That
   enumeration is the completeness criterion (checkable: the set of distinct `version`
   values across `git log -- plugins/dev-workflow/.claude-plugin/plugin.json`).
   **Interval definition:** an entry covers every plugin-touching commit *after* the
   commit that introduced the previous version, up to and including the commit that
   first introduced this one. The 0.1.0 entry, having no predecessor, runs from the
   first plugin-touching commit in the repository. **Format:** newest version first,
   `## <version>` headings, a few bullets each, no dates (the manifest carries no
   release dates and inventing them would be fiction). The reproducibility claim is
   scoped to *commit coverage* — which commits belong to which entry — not to wording.
   0.4.1 needs no special rule: `fe5e296` and `793e234` land after the 0.4.0 commit and
   before the 0.4.1 one, so the ordinary interval already claims them. They are worth
   calling out in the entry's text only because they are the un-released plugin changes
   this very check exists to prevent.
   Each entry is verified
   against `git log`, not written from memory.
2. **AGENTS.md → Key invariants → Packaging, as invariant 12** — *not* "the next
   number in the section": Packaging currently ends at 7 and "Prompts and scaffolding"
   runs 8–11, which other documents cite by number. Invariant numbers are stable IDs,
   not an ordering, so the new rule takes the next *global* number and renumbers
   nothing. Its wording must name the PR-only scope, the checker, what "the plugin"
   means for identity (the directory path), and **the accepted-limitation list in
   full** — an unqualified "plugin changes require a bump" would be exactly the
   `unverified-enforcement-claim` this repo already logged once, and a *partial* list
   is the same defect wearing a shorter sentence.

   **One list, three places, identical wording.** The script header, the AGENTS.md
   invariant and the ledger `ref` all carry it:
   semantic correctness · direction · PR-only (direct pushes bypass) · plugin deletion ·
   *any change to which directory the marketplace entry points at (rename, copy, or
   `source` repoint)* · concurrent same-version collisions · release/tag status.
   Two of these were dropped from the invariant and the marketplace-relocation class was
   narrowed back to "rename" in an earlier revision — which is how a limitation list
   quietly becomes an overclaim.
3. **Drift sweep** — this change adds two executables and a fifth CI check, so every
   claim about "the only executables" or the shape of CI goes stale at once. Grep and
   update: AGENTS.md § Boundaries and its architecture tree (plus the new CHANGELOG
   file), `docs/architecture.md`, `README.md` § Contributing, and the explanatory
   comment in `.github/workflows/ci.yml`.
   Also in the sweep, because this change leans on the distinction: **invariant 7's
   wording** ("`examples/` is read-only reference … never installed") and the matching
   architecture shorthand ("read, don't install") are ambiguous between "not scaffolded
   into the user's project" (what is meant) and "not part of the shipped package" (not
   true — the cache copies it). Clarify to *"never scaffolded or copied into a user's
   project, never presented as a default; it does ship inside the plugin package"*,
   without weakening the read-only prohibition. **`plugins/dev-workflow/examples/README.md`
   is in that sweep too** — it is titled "read, don't install" and carries the same
   ambiguity, and it is a shipped file, so leaving it behind would be drift inside the
   package itself.
   **Before editing AGENTS.md or `docs/architecture.md`, run the grep AGENTS.md's own
   Don'ts mandate** — `grep -rniE 'declare[sd]?|convention[- ]load' --include='*.md' . |
   grep -v source-files/` — and read the hits rather than trusting the count. This
   change edits both of the documents that rule was written about, which is exactly
   when an ad-hoc sweep repeats the 0.2.1 failure.
4. **AGENTS.md § Commands** — the `lint` and `quality` rows gain the new files. The
   `test` row stays hook-only: it names the hook's state-machine suite, and the two
   checkers' suites belong with the invariant checks, not with it. Invariant 12 gets its
   **own** row rather than joining the existing `invariant checks (5 pinning, 6
   manifest)` row, because its checker takes an argument and carries a commit-derived
   precondition that rows 5/6 do not — folding it in would bury that precondition in a
   row that has none. (Both details are corrections to an earlier revision, made after
   review found the tracked spec describing something other than what shipped.)
   The PR-only checker's row carries
   the local invocation (`sh scripts/check-version-bump.sh main`) and a note that CI
   passes the PR's base ref instead. **That row also states its precondition**, or it
   gives false assurance: the checker compares *commits*, so run it after the work is
   committed (the WIP commit of the Gate-B cycle is the natural point) and against a
   base ref that is actually current. Run mid-loop with the plugin edits still in the
   working tree, it reports clean — correctly, and uselessly. **The quality row — which claims to be "the whole
   battery, what CI runs" — includes that invocation too**, or it stops being equivalent
   to CI the moment this check lands. Per the repo's own rule, every command listed must
   have been run in the session that documents it.

## Ledger

One row, appended after re-reading the log and re-running the anchored recurrence grep
(`grep -nE '^\| *[0-9-]{10} *\| *artifact-version-not-bumped *\|' docs/hardening-log.md`).
Fields: `source=manual`, `severity=major`, `rung=2 lint`, `ref` naming
`scripts/check-version-bump.sh` + `.test.sh` **and stating what it does not catch** —
the same seven-item list as the invariant and the script header, verbatim, since the
ledger outlives this spec.

Neither taxonomy has a fitting class: `dependency-unpinned` is about *this* repo
consuming a floating dependency; this is about *our own artifact* failing to reach
consumers. Mint `artifact-version-not-bumped` in `docs/hardening-taxonomy.md`
(project-owned, per the skill), with alias hints.

## Invariant 11 (prompt-standards) applicability — decided, not assumed

**Invariant 11 does not formally apply to anything in this change.** Its stated scope
— and `docs/prompt-standards.md`'s — is skills, commands, agent definitions, hook
messages and scaffolded templates. **No file under
`plugins/dev-workflow/{skills,commands,agents,hooks}/` is touched here.** The two shell
files are executables; `CHANGELOG.md`, `README.md` and `docs/architecture.md` are
explanatory prose.

The new AGENTS.md invariant text nonetheless gets a **voluntary** review against item
11 (honest enforcement claims) — AGENTS.md is read directly by Codex at both gates, so
an overclaiming invariant misleads a reviewer the same way a bad prompt does. Calling
that *applicability* would silently widen invariant 11's scope to AGENTS.md, including
in the scaffolded copy every initialized project gets; widening it is a separate
decision, not a side effect of this change.

`MANIFEST.md` is deliberately *not* given a CHANGELOG row: its actual content is an
inventory of `source-files/`, the frozen extraction seed, and the new CHANGELOG has no
seed provenance. But AGENTS.md currently describes MANIFEST.md as "what each shipped
file is and where it comes from", which is what made this look like drift in the first
place — **that one-line description is corrected to name it the extraction-seed
inventory in this change**, since leaving the architecture doc contradicting the file
it describes is precisely the docs-drift the sweep exists for.

## Verification

- `sh scripts/check-version-bump.test.sh` — the matrix above, plus the named mutation.
- The full quality battery from AGENTS.md § Commands (which already ends in
  `claude plugin validate . --strict`), run once, after the battery itself is updated
  to include the new files.
- The check must pass on its own PR — which requires the 0.4.1 bump, making this PR its
  own first live test case.
