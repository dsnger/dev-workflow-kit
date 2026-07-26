# Plan — PR 1: mechanical rung for two prompt-conformance classes

Layer 1 of a two-PR split. **This PR is `scripts/` + the doc sites those checks
directly describe.** It touches no `plugins/**` path, so invariant 12 requires no
version bump here. A's §5 nudge, C's companions, the template sync and the rest of the
housekeeping are PR 2.

Two ledger rows dated 2026-07-25 sit at rung `pending` and name this work as their
resolution vehicle. This PR resolves both.

---

## Task 1 — Check 4a: target model named

**Scope.** Hardens the third `unverified-enforcement-claim` occurrence: a prompt
asserting it follows `docs/prompt-standards.md` while naming no executing model.

**Rule.** For each in-scope file containing the tested assertion spelling
`prompt artifact and follows`:
1. **Count all** `Target model:` declarations; require **exactly one**. Counting all —
   not "exactly one non-empty" — is deliberate: the latter accepts a valid line beside
   any number of empty ones, which is malformed state reported as conforming.
   **One declaration grammar, used for both counting and value validation:** the
   anchored `^Target model:` at column zero. Indented lines, blockquoted ones
   (`> Target model:`) and mid-sentence prose mentions do not count — the column-zero
   anchor excludes them for free. Using one pattern for both counting and validation is
   the point: doing it with two patterns is how a file passes cardinality on one set of
   lines and value-validation on another. Near-miss fixtures: indented, blockquoted,
   prose mention.
   **Fenced blocks are a stated limitation, not a claim.** A column-zero
   `Target model:` inside a ``` fence **does** count — POSIX grep has no fence
   awareness, and specifying one would mean a fence-length/indentation/unclosed-fence
   parser that no other rule here needs. Verified with `/usr/bin/grep`: all four claiming
   files currently carry exactly **one** column-zero declaration each, so nothing in the
   tree depends on the distinction today. If a future template embeds a fenced example
   declaration, the cardinality rule fires — a false positive whose fix is obvious, which
   is the safe direction.
2. That sole value must be non-empty and **begin with** a tested token, matched in
   **ERE (`grep -E`)** with a **portable** boundary — `\b` is a GNU/PCRE extension, not
   POSIX, and this repo has already been bitten once by assuming a non-POSIX regex
   construct (the BSD-sed `\|` alternation documented in `unquote()`):
   `^Target model: *(Claude|Codex|GPT)([^[:alnum:]_]|$)`
   Without the boundary, `ClaudeX`, `Codex2` and `GPTfoo` all pass. Stated
   implementation-neutrally on purpose: the checker runs under `sh` against whatever
   `grep` is on `PATH` — BSD grep locally, GNU grep on `ubuntu-24.04` CI — and only POSIX
   ERE constructs may be assumed. A `\b` that happens to work in both is still the wrong
   thing to write, for the same reason the BSD-sed `\|` alternation in `unquote()` was.
3. **Count distinct recognized tokens in the value; require exactly one.** No separator
   grammar at all. Each of `Claude`, `Codex`, `GPT` is tested for whole-word presence
   with the portable boundary `(^|[^[:alnum:]_])TOKEN([^[:alnum:]_]|$)`; the count of
   *distinct* tokens present must be 1.
   This replaces an earlier separator-enumeration rule (` or `, ` and `, `/`, `,`) and
   its generated 24-case matrix. Enumerating separators was both incomplete — it missed
   GPT-leading values and several orderings — and fragile, since a boundary group
   consumes the separator's leading space and breaks the very pattern meant to find it.
   Counting distinct tokens is mechanically complete over the stated rule instead of
   approximating it. Verified across nine values:

   | Value | distinct | verdict |
   |---|---|---|
   | `Claude via Claude Code` | 1 | accept (same token twice is one model) |
   | `Claude in a chat interface, upstream of Claude Code` | 1 | accept |
   | `Claude via Claude Code or the API` | 1 | accept — one model, two surfaces |
   | `Claude or Codex` / `GPT/Codex` / `Codex, Claude` / `Claude and Codex` | 2 | reject, every separator, no separator rule needed |
   | `Claude or Codex2` | 1 | accept — `Codex2` is not a recognized model |
   | `any capable chat model` | 0 | reject |

   Rules 2 and 3 are both required and neither subsumes the other: the historical defect
   `any capable chat model (… developed with Claude …)` has **one** distinct token and is
   caught only by rule 2's begins-with anchor.

**Why begins-with and not contains.** Presence alone accepts
`Target model: any capable chat model` — the exact PR #12 defect. Token-*anywhere* also
fails: the real defect line read `any capable chat model (the role was developed with
Claude …)` and **contains** `Claude`. Measured: anywhere → 1 match (misses it),
at-start → 0 (catches it).

**Stays instruction-backed, and the ledger row must say so.** A bare
`Target model: Claude` naming no execution surface passes; so does any value whose prose
is wrong in a way no token test sees. An unknown future model fails until the list is
extended — a false positive, the safe direction.

**Files.** `scripts/check-invariants.sh`.

---

## Task 2 — Check 4b: checklist count claims

**Scope.** Hardens the third `docs-drift` occurrence: a prose count contradicting the
checklist it counts.

**Rule — definitions.** Exactly **two** files define a checklist:
`docs/prompt-standards.md` and the template inside
`plugins/dev-workflow/commands/workflow-init.md` (read only — not edited by this PR).
Each must have **exactly one** checklist heading matching the anchored ERE
`^## Checklist([[:space:]].*)?$` — **not** the literal string `## Checklist`, which
matches neither real file: both actually read
`## Checklist (each item must be verifiably true)`, so an exact-literal implementation
rejects the real repository before comparing a single item. Near-miss fixtures must pin
the grammar (`## Checklists`, `### Checklist`, `## Checklist-ish`, and the real
parenthesised form). Its bounded body (that heading →
the next `## `) holds **at least one** item line matching `^[1-9][0-9]*\. \*\*` — a
**canonical decimal** label, so `0.` and leading-zero forms like `01.` are malformed and
fire rather than being silently renumbered into `1..N`. Claims are recognized in **two stages**, because one canonical pattern alone would make
a malformed claim *invisible* rather than rejected: first a **near-claim detector**
`(^|[^[:alnum:]_])all [0-9]+( checklist)? items([^[:alnum:]_]|$)` matches any digit run;
then the matched digits must be canonical `[1-9][0-9]*` or the claim **fails as
malformed**. Without that first stage, `all 012 items` matches no canonical claim, is
silently ignored, and its required reject fixture cannot pass — which is the state an
earlier draft specified. Comparison is done as **strings after canonicalization**, never
by shell arithmetic on an unbounded digit run, so a very long digit string cannot
overflow or error its way into a wrong verdict; uncertainty fires, per invariant 2.
Fixtures: `0.`-labelled, `01.`-labelled, `all 012 items`, and a 40-digit claim. Each
checklist section's labels must additionally form exactly the **contiguous canonical
sequence 1 through N** — so `1, 1, 3` is malformed rather than silently authoritative at
N=3. Zero, empty, duplicate or multiple sections **fail**;
never a silent 0-vs-0 compare. The two counts must be equal, giving one authoritative `N`.

**Rule — claims. Word forms are IN scope, and this is the correction that makes the
resolution honest.** An earlier draft scoped this check to digit spellings only. That
would have been a false hardening: the actual 2026-07-25 `docs-drift` occurrence this
check resolves was **`all ten items`** — a word form (verified in git:
`4f31df2` removed the line "nobody reviews them against all ten items per brief"). A
digit-only check sails straight past the defect it claims to guard, which is the same
mistake made once already on 4a, where a presence-only test accepted
`any capable chat model`.

So the recognized claim grammar is
`(^|[^[:alnum:]_])all (<digits>|<tested word>)( checklist)? items([^[:alnum:]_]|$)`,
where `<tested word>` is the bounded list **one … twenty** mapped to digits. **The outer
boundaries are required, not decorative:** without them the same ERE also matches
`small ten items` and `all ten itemsized` — measured, 3 matches unbounded versus 1
bounded — so an unbounded implementation would reject unrelated prose while the ledger
row claimed a bounded guard. **Every** claim must equal `N`; comparing every
claim to `N` makes conflicting duplicates fail by construction, so no separate
claim-cardinality rule is needed. Fixtures must include the historical
`all ten items` against a 12-item checklist.

Out of scope, stated rather than implied: numbers above twenty in word form, ordinals,
hyphenated compounds (`all twenty-one items`), and claims split across lines. The ledger
row names exactly this boundary.

**Files.** `scripts/check-invariants.sh`.

---

## Task 3 — Scan domains and exclusions, stated per check

**Scope.** Pass 6 found the single exclusion table ambiguous: it was labelled "claim scan
only" while one row said "4a only", leaving no derivable authoritative domain.

**Rule — positive domain first.** Both checks scan **`--include='*.md'` only**, rooted at
the repository root, via `grep -r` (which does **not** follow symlinks; `-R` would — the
non-following form is the intended one, so a checked-in symlink cannot drag an
out-of-tree file into scope). Markdown-only is the right domain because both rules are
about prompt text; the existing invariant-5 scan's wider
`*.yml/*.yaml/*.json/*.toml` set is deliberately **not** reused, since a `Target model:`
line in a JSON fixture is not a prompt claim. Hidden directories are in scope by default,
which is exactly why `.context/` needs an explicit exclusion below rather than relying on
its leading dot.

Then the exclusions — two separate domains.

| | 4a (assertion scan) | 4b (claim scan) |
|---|---|---|
| `source-files/` | excluded — frozen extraction archive, never edited | excluded — same |
| `docs/superpowers/` | excluded — historical artifacts | excluded — its plans legitimately say "all 11 checklist items"; **load-bearing, not tidy** |
| `.context/` | excluded — generated review artifacts; the quality command must not depend on ephemeral review wording | excluded — same |
| `docs/hardening-log.md` | **excluded** — the ledger *quotes* finding text, so a row describing this very defect trips its own check (verified: it matches the phrase and has no `Target model:` line) | **excluded — and this one is a BLOCKER if missed**, see below |

**The ledger exclusion is the one that would otherwise break the build**, and it is the
only self-referential trap left once the domain is Markdown-only. Every exclusion carries
a paired control (Task 5).

**Path-form rule — prefix AND suffix, because the two scans emit different shapes.**
Prefix form varies by `grep` implementation and must not be assumed: write exclusions
prefix-independently, e.g. `(^|/)source-files/` rather than `^\./source-files/`.

The suffix matters just as much, and getting it wrong silently disables an exclusion.
4a's file scan (`grep -rl`) emits **bare paths**, so `(^|/)hardening-log\.md$` works.
4b's claim scan (`grep -rno`) emits **`path:line:match`**, so that same `$`-anchored
pattern matches nothing and the ledger is scanned anyway — reproducing the BLOCKER while
looking excluded. Verified by simulating both checks against the real tree: with the
`$`-anchored pattern 4b still returned 3 claims including the ledger's `all ten items`;
with `(^|/)hardening-log\.md($|:)` it returns 2, both `12`, and the same pattern still
excludes correctly in the bare-path form. **Use the `($|:)` form for every exact-file
exclusion**, and let the paired controls (Task 5) prove each one.

**Real-repo simulation is a required pre-implementation step, not a nicety.** Both
checks were simulated against the actual tree while writing this plan; that is what
caught the anchor defect above. 4a currently passes on all four in-scope files
(1 declaration, 1 valid value each); 4b agrees at N=12 across both definitions.

**Why the ledger must be excluded from 4b as well — the append-only trap.** Once word
forms entered 4b's grammar, the ledger became self-rejecting: `docs/hardening-log.md:27`
is the 2026-07-25 `pending` row, and it *quotes* the historical defect —
`… not reviewed against "all ten items" while its own checklist …`. So 4b sees a claim of
`ten` against a 12-item checklist and fails. The ledger is **append-only** and that row
must stay byte-unchanged, so this would reject the real repository **forever**, making
success criterion 3 unreachable and the resolution row a lie. Measured with
`/usr/bin/grep`: **3** in-domain claims (`hardening-log.md:27` `all ten items`,
`prompt-standards.md:14` `all 12 items`, `AGENTS.md:169` `all 12 checklist items`) →
**2** after the exclusion, both `12`.
The general shape, worth stating because it will recur: **a ledger that quotes defects
cannot be scanned by checks that detect those defects.** Both checks exclude it for the
same reason, and the new ledger rows must record that quoted-evidence blind spot as
instruction-backed.

**No `.sh` self-exclusion is needed, and requiring one was a contradiction.** An earlier
draft excluded `check-invariants.sh` and `.test.sh` explicitly and demanded fixtures like
`scripts/check-invariants-helper.sh`. Impossible: the scan is `--include='*.md'`, so no
`.sh` file can enter scope at all (verified: 0 `.sh` matches). The domain restriction
already does that job; the explicit exclusion added only unsatisfiable fixtures.

**Measure with `/usr/bin/grep`, not the shell's `grep` — this invalidated four earlier
measurements.** An interactive shell here defines `grep` as a **function shimming to
ugrep** with `--ignore-files`, i.e. it honours `.gitignore`. The checker runs under `sh`
and gets the real `grep`. The two disagree on exactly the things this task depends on:

| | shell `grep` (ugrep shim) | `/usr/bin/grep` (what runs) |
|---|---|---|
| path prefix | no `./` | `./` |
| `.gitignore`d paths | skipped | **scanned** |
| `.context/` review artifacts | invisible | **visible** |

Consequence, and it flips an earlier conclusion: a probe through the shim reported "no
hits" in `.context/`, suggesting that exclusion was merely prudent. With the real grep,
`.context/codex-reviews/gate-a-plan-pass-6.md` **does** match the 4a trigger phrase. The
`.context/` exclusion is load-bearing, not speculative. Verified totals with
`/usr/bin/grep`: 10 candidate files before exclusions, **4** after (`docs/sparring-briefing.md`,
`workflow-init.md`, `harden-finding/SKILL.md`, `intake/SKILL.md`); 4b finds 2 claims,
both `12`.

**Files.** `scripts/check-invariants.sh`.

---

## Task 4 — Mutation evidence: a one-time run, recorded

**Scope.** Show each new check is load-bearing — that its fixtures fail when the check
is removed — as **documented evidence from a development-time run**, not as permanent
machinery.

**Why this shape.** It is the house pattern: every mutation verification in this
repository so far (the hook suite, `check-version-bump`) was an evidenced run recorded as
"reverting X fails exactly assertions Y". Three earlier drafts tried to build an
automated oracle instead, and each attempt produced a defect the next review pass caught —
a test-only path override that was a no-op, a fixed-destination fix that was a no-op one
level down, an expected-delta enumeration that could not include accept fixtures, a
sentinel that would have required sentinel-only behaviour in the *production* checker.
**No path parameterization is needed at all:** a one-time run copies the repo to scratch
and neuters the copy in place, so the suite resolves its sibling checker normally.

**Procedure** (per check; `4a` shown):
```sh
TMP=$(mktemp -d) || exit 1
[ -n "$TMP" ] && [ -d "$TMP" ] || { echo "no scratch dir" >&2; exit 1; }
trap 'rm -rf "$TMP"' EXIT HUP INT TERM      # not just fall-through: an abort otherwise
                                            # leaves a whole repo copy (incl. .git) behind
cp -R . "$TMP/repo"
sed '/BEGIN check 4a/,/END check 4a/d' scripts/check-invariants.sh > "$TMP/repo/scripts/check-invariants.sh"

sh scripts/check-invariants.test.sh > "$TMP/before" 2>&1; base=$?
( cd "$TMP/repo" && sh scripts/check-invariants.test.sh ) > "$TMP/after" 2>&1; mut=$?

# Every status is ASSERTED, not merely captured — an unasserted status is the
# verification-masks-failure class this procedure claims to avoid.
[ "$base" -eq 0 ]  || { echo "VOID: baseline suite not green ($base)" >&2; exit 1; }
[ "$mut"  -ne 0 ]  || { echo "VOID: mutant suite passed — the check is not load-bearing" >&2; exit 1; }
diff "$TMP/before" "$TMP/after" | grep '^> FAIL' | sed 's/^> FAIL - //; s/ (.*)$//' > "$TMP/flipped"
[ -s "$TMP/flipped" ] || { echo "VOID: no assertions flipped" >&2; exit 1; }
cat "$TMP/flipped"        # <- this list is the evidence that gets recorded
```
**What the script asserts, and what it does not — stated precisely, because overclaiming
here is the failure this whole procedure exists to avoid.** The commands reject exactly
three states: a baseline that was already red, a mutant that passed (so the check was not
load-bearing), and an empty flipped set. They do **not** establish that the mutant failed
for the *right* reason: a syntax error in the neutered copy could break accept fixtures
and produce a non-empty flipped list that these checks happily record.

That last validation is a **human step, and it is mandatory**: compare the printed
flipped set against the reject cases listed for that check in Task 5's fixture table —
exact set equality, no extras, nothing missing — and confirm the mutant's output carries
no checker abort or syntax diagnostic. The dry-run's three flips were confirmed that way,
by reading them, not by the script proving them. Recording evidence without that
comparison is not permitted, and no wording anywhere may imply the script performs it.

**Validated before implementation.** The procedure was dry-run against the *existing*
invariant-6 block: `base=0`, `mut=1`, and exactly three assertions flipped —
`hooks key rejected`, `skills key rejected`, `key/colon split across lines rejected`.
That also supplies Task 5's load-bearing evidence for the pre-existing checks, so one
procedure serves both purposes.

**Recording the evidence — three places, none of them optional.**
1. **PR body** — each mutant and the exact assertion names it flipped.
2. **A short comment block in `scripts/check-invariants.test.sh`** — the same
   mutant → flipped-assertions mapping, so it travels with the file rather than living
   only in a merged PR.
3. **The checker's header comment** — the re-run procedure and its trigger. The trigger
   must be **broader than "the scan logic"**: the recorded mapping is invalidated by a
   change to either marked check, to the markers themselves, to any of those checks'
   fixtures or assertion names, or to the harness that runs them. A narrow trigger would
   let the evidence comment go stale while claiming no re-run was due — which is the
   dishonesty prompt-standards item 11 forbids, in the very block that documents it.
   After any such run, **both** recorded mappings (PR body and test-file comment) are
   updated together.

**Honest phrasing is part of the deliverable (invariant 11, prompt-standards item 11).**
None of these three may describe the evidence as automated enforcement. Nothing re-runs
it; it is a documented manual step with a stated trigger, and the comment must say so.
Calling it a guard would be precisely the `unverified-enforcement-claim` this PR hardens.

**What this deliberately does not do, and why that is acceptable now.** It does not catch
a *future* checker edit that silently kills fixtures. That guard already exists at the
process level — any `scripts/` change fires full Gate B, and the documented procedure
makes re-running cheap. Permanent machinery to replace a documented manual step needs a
recurrence to justify it: a checker edit that shipped with silently-dead fixtures. None
has happened. If one does, that recurrence is the trigger to build the oracle.

**Files.** `scripts/check-invariants.sh` (header comment + `BEGIN`/`END` markers),
`scripts/check-invariants.test.sh` (evidence comment block).

---

## Task 5 — Prerequisite: one shared fixture initializer, then the fixtures

**Scope.** 4b's cardinality rule is mandatory, so every fixture repo needs a valid
checklist or it fails before reaching its own assertion.

**Rule.** **Four** call sites `cp "$CHECKER"` and build a repo directly — `run_with`,
`sh_case`, and two inline blocks (verified by grep). None creates
`docs/prompt-standards.md` or `workflow-init.md`. Extending `run_with` alone leaves three
broken: accept cases turn red and reject cases start passing for the wrong reason —
exactly the diagnostic-isolation failure the suite's `$5`-substring guard exists to
prevent. Extract **one** initializer installing a valid agreeing checklist pair plus a
matching claim; call it from all four; **then** add enforcement.

**Fixtures.** Following the suite's `expect_reject`/`expect_accept` pattern — every
reject case names a substring of its expected diagnostic, so it cannot pass on an
unrelated violation.

**Multi-model fixtures follow the distinct-token rule, so the case list is small and
complete.** Because rule 3 counts distinct tokens rather than matching separators, the
fixtures need only pin the rule's boundaries, not a separator matrix: one reject per
distinct pair using a *different* separator each (`Claude or Codex`, `GPT/Codex`,
`Codex, Claude`, `Claude and Codex`) to show the verdict is separator-independent; and
the **four** accepts that define the edges — same token repeated
(`Claude via Claude Code`), the chat-interface form
(`Claude in a chat interface, upstream of Claude Code`), one model with two surfaces
(`Claude via Claude Code or the API`), and a token-prefix non-model
(`Claude or Codex2`, which must **accept** because `Codex2` is not a recognized model).
All **eight** verdicts verified before implementation.

| Check | Reject cases | Accept cases |
|---|---|---|
| 4a | no `Target model:` line; two declarations; one valid + one empty declaration; empty value; `any capable chat model (…Claude…)`; token-prefix near-misses `ClaudeX`, `Codex2`, `GPTfoo` as the *first* token; four two-token rejects, each with a **different** separator to show the verdict is separator-independent — `Claude or Codex`, `GPT/Codex`, `Codex, Claude`, `Claude and Codex` | `Claude via Claude Code` (same token twice = one model); `Claude in a chat interface, upstream of Claude Code`; `Claude via Claude Code or the API` (one model, two surfaces); **`Claude or Codex2`** (a token-prefix in *second* position is not a second model — the settled boundary) |
| 4b | digit claim ≠ N; **word-form claim ≠ N (`all ten items` vs a 12-item checklist — the historical defect)**; checklist section absent; section present but empty; duplicate `## Checklist` heading; non-contiguous labels `1, 1, 3`; the two definitions disagreeing; near-miss headings `## Checklists`, `### Checklist`, `## Checklist-ish` | one valid digit claim matching N; a word-form claim matching N (`all twelve items`); two agreeing claims; the real parenthesised heading `## Checklist (each item must be verifiably true)` |
**Three fixtures are mandatory because they lock this plan's hardest-won lessons into
code rather than into an appendix nobody re-reads.** Each was a BLOCKER found at Gate A,
and each was introduced by the fix for the previous one:
| Lesson | Fixture |
|---|---|
| a ledger that quotes defects self-rejects the check that detects them | a fixture repo whose `docs/hardening-log.md` carries `all ten items` and a quoted assertion phrase — must **accept** |
| an expected-delta set cannot include accept fixtures, which stay `ok` when a check is disabled | an accept fixture that stays `ok` under the 4a mutation, asserted explicitly |
| a canonical-only grammar makes malformed input *invisible* rather than rejected | `all 012 items` — must **reject** as malformed, via the two-stage detector |

Exclusion fixtures are a **per-check matrix**, not one row — 4a and 4b have different
exclusion sets, some entries are directory prefixes and two are exact files:

| Excluded path | Applies to | Excluded fixture (must ACCEPT) | Neighbour (must REJECT) |
|---|---|---|---|
| `source-files/` | 4a, 4b | `source-files/x.md` | `source-filesX/x.md` |
| `docs/superpowers/` | 4a, 4b | `docs/superpowers/x.md` | `docs/superpowersX/x.md` |
| `.context/` | 4a, 4b | `.context/x.md` | `contextX/x.md` |
| `docs/hardening-log.md` | **4a and 4b** | that exact file, carrying both a quoted assertion phrase and `all ten items` | `docs/hardening-log-notes.md` |

Each row carries the **same** violating content on both sides. That pairing is what
proves an exclusion is load-bearing rather than an overbroad filter — or a fixture that
never matched the rule at all. The neighbour column also pins the path-form rule: a
prefix-anchored exclusion that accidentally matches `source-filesX/` fails its own row.

**Mutation evidence lives in Task 4** — a one-time, recorded run, not an oracle built
here. The only thing this task owes it is the **seam**: each new check's body in
`check-invariants.sh` is wrapped in exact marker comments
(`# --- BEGIN check 4a ---` / `# --- END check 4a ---`, likewise 4b) so the `sed` range
delete has something stable to cut. Nothing else keys on the markers.

**Files.** `scripts/check-invariants.test.sh`.

**Verify.** Suite green. And the pre-existing checks must be shown still load-bearing
after the initializer — but **not** by "re-running the invariant-5/6 mutation": no such
procedure exists in the suite today, so that instruction was unexecutable. Instead, name
concrete pre-existing reject cases and re-verify each still fails **with its own
diagnostic** (the `$5` substring), so a case that survives only because its check was
accidentally disabled is distinguishable from one that genuinely rejects:
- invariant 5: `unpinned npx in a shell script rejected`, `major-only ref rejected`,
  `branch ref rejected`, `ubuntu-latest rejected`;
- invariant 6: `hooks key rejected` (diagnostic substring
  `re-declares a convention-loaded`).

**These names are grep-verified, and two earlier ones were not.** A prior draft of this
task named `unpinned action ref rejected` and `ubuntu-latest runner rejected`; neither
exists (`grep -cF` → 0). The real cases are the ones above. An unverified fixture name is
the same defect class this PR hardens, one layer up — so the implementer must verify each
name before relying on it.

**Verify with the quoted argument, expecting exactly 1.** A bare
`grep -cF 'ubuntu-latest rejected'` returns **3** — the substring also occurs inside
`quoted ubuntu-latest rejected` and `matrix ubuntu-latest rejected`, so a bare
substring count cannot identify which case is meant. Search the quoted assertion
argument (`grep -cF '"ubuntu-latest rejected"'`) and require a count of exactly 1 for
every selected case.

---

## Task 6 — Docs-drift sweep, by claim not phrase

**Scope.** A third and fourth check makes existing descriptions of this script stale.

**Rule.** Verify every sentence describing `check-invariants.sh` against what it now
implements. Known sites — the fourth was missed by the previous sweep list and is why
this searches by claim:

**Files.** `scripts/check-invariants.sh` header ("Both checks"); `AGENTS.md:37`
(layout tree) and `AGENTS.md:234` (Commands row) — both say "invariants 5 and 6";
`docs/architecture.md:18`; `README.md:126` — "(invariants 5 and 6)", contributor-facing;
`.github/workflows/ci.yml:76` (the comment "Invariants 5 and 6 mechanically") **and**
`ci.yml:83` (the step name "Invariant checks (pinning, manifest) + both checker suites")
— two distinct sites in that file, not one.

**Seven locations across five files — and every single pass found one more.** Three in
the previous plan → `docs/architecture.md` (pass 6) → `README.md` (PR1 pass 1) →
`AGENTS.md`'s second site (pass 2) → `ci.yml`'s second site (pass 3). That monotone
escalation *is* the `docs-drift` class this PR hardens, demonstrating itself inside the
plan that hardens it. Which is exactly why the rule searches **by claim** and the final
verify **greps** — this table is a starting point, and its own history says it will be
incomplete again.

**Verify.** `grep -rn` by claim (`check-invariants`, "both checks", "invariant checks",
CI step text) returns no sentence contradicting the implemented checks.

---

## Task 7 — Ledger: two appended rung-2 rows

**Scope.** Resolve the two `pending` rows.

**Rule.**

| fingerprint | source | severity | rung | ref |
|---|---|---|---|---|
| `unverified-enforcement-claim` | `bot` | major | 2 lint | check 4a; **resolves** the 2026-07-25 `pending` row by reference |
| `docs-drift` | `bot` | minor | 2 lint | check 4b; **resolves** the 2026-07-25 `pending` row by reference — and the row must state that the guard covers digit **and** bounded word-form (one…twenty) count claims, because the occurrence being resolved was the word form `all ten items`; above twenty, ordinals, hyphenated compounds and split-line claims stay instruction-backed |

`source` stays `bot` — it records the surfaced finding's provenance, and both pending
rows record `bot`; switching to `manual` would make one finding read as a fresh manual
occurrence. Each row states the exact spelling its check guards, what stays
instruction-backed, **and** the over-escalation warning: `harden-finding` compares
fingerprints only, so a later in-class defect *outside* the guarded spelling will be
proposed for a stronger rung than anything justifies. Accepted deliberately — escalation
is a proposal a human validates, and the row names the guarded spelling for that human.
No row is ever edited; resolution is by appending.

**Files.** `docs/hardening-log.md`.

**Verify.** Anchored column-2 grep counts; both `pending` rows byte-unchanged; both new
rows read `bot`.

---

## Task 8 — todos.md: mark the vehicle consumed

**Scope.** The PR #12 entry naming this round as the resolution vehicle.

**Rule.** There is no checker/template "half" — they are **two separate unchecked items**.
Precisely: the standalone item **"Prompt-standards conformance checker — resolves two
`pending` ledger rows (2026-07-25)"** becomes checked, and its now-obsolete
resolution-vehicle text (which names the canvas round and a trigger) is rewritten to name
this PR as what resolved it. The **separate, preceding** "ad-hoc task briefs are prompts
too" template-sync item stays **byte-unchanged** — it is PR 2's. **Edit only.**

**Files.** `todos.md`.

---

## Invariants touched

**2** (directional — every ambiguous checklist shape fires rather than passing), **5**
and **6** (the checks this script already enforces must keep working — evidenced by
re-running the exact named pre-existing reject cases in Task 5 and confirming **each
case's own diagnostic**, *not* by "re-running their mutation": no invariant-5/6 mutation
procedure exists in the suite, so that instruction was unexecutable and is gone from this
plan entirely), **11** (below). **12 does not apply: no `plugins/**` path is modified**,
so no version bump. Hooks are not touched.

## Success criteria

1. **Prompt-standards self-review (invariant 11) — required, and an earlier draft of
   this plan got it wrong.** That draft claimed "no prompt artifact is edited by this PR".
   False: Task 6 edits `AGENTS.md`, and `CLAUDE.md:221-222` classes `CLAUDE.md` and
   `AGENTS.md` themselves as **prompts, not prose**. So the changed instruction text gets
   a full 12-item `docs/prompt-standards.md` review before Gate B, and the `AGENTS.md`
   edit fires full Gate B rather than the prose exemption. (`README.md`, by the same rule,
   *is* prose — it describes the product rather than instructing a model.) A false scope
   claim here would have routed changed model instructions around this repo's only
   prompt-quality gate.
2. The **exact** quality command from `AGENTS.md § Commands`, run verbatim and green —
   not a subset: shellcheck over all six scripts, **all three** regression suites (hook,
   invariant-checker, version-bump-checker), and `claude plugin validate . --strict`.
3. `sh scripts/check-invariants.sh` exits 0 **on the real repository**, not only in
   fixtures — the assertion pass 6's F4 showed a fixture-only check would miss.
4. The mutation run yields **both**: the script's validity assertions passing (baseline
   green, mutant non-zero, non-empty flipped set) **and** the retained exact flipped-assertion
   output, human-compared to the fixture table per Task 4. A prose attestation
   unsupported by that retained output is not evidence and is not acceptable.

---

# Appendix — decisions

**Where plan review stops.** Plan-level review converges on **what** a test proves;
**how** it proves it is code, and code is reviewed at Gate B. Nine Gate-A passes
rediscovered this — three consecutive BLOCKERs, each introduced by the fix for the
previous one (word-forms → ledger self-reject; `CASES_*` derivation → impossible delta;
canonical decimal → `all 012 items` invisible), with finding totals flat across the run:
7, 7, 5, 6, 6, 4, 5, 5, 5. Everything load-bearing here was settled by *running* it
against the real repository; what kept breaking was prose specifying a test procedure.
If this lesson recurs in a later round it graduates to `docs/prompt-standards.md`; until
then it is a decision, not a rule.

**Mutation evidence is a recorded run, not an oracle.** House pattern (the hook suite and
`check-version-bump` were verified the same way). Four attempts to specify an automated
oracle each produced a defect the next pass caught; the recorded run worked first try.

**Both 4a rules are required.** The begins-with anchor and the distinct-token count do
not subsume each other: the historical defect `any capable chat model (… Claude …)` has
exactly one distinct token and is caught only by the anchor.
