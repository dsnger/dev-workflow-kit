# Gate A — spec — pass 12 dispositions

Artifact: `docs/superpowers/specs/2026-08-05-hardening-ledger-supersession-design.md`
8 findings: 5 Major, 2 Minor, 1 Nit. **No Blocker.** All read as correct. **None applied.**

Reviewer: `mcp-codex-dev@1.0.1`, `codex-cli 0.144.5`, model `gpt-5.6-sol`.

Passes 4 → 12: **11, 14, 16, 15, 9, 10, 5, 12, 8.**

## Reproduced

| # | Claim | Result |
|---|---|---|
| 4 | the new layout anchor's backticks are unescaped | **Reproduced under `sh` and `dash`.** `:485` reads `"block above the \`Columns:\`"` with **no** backslash escapes, so the shell attempts `Columns:` as a command substitution: it prints `Columns:: command not found` and the anchor degrades to `block above the `. The block still exits 0. Every other backtick-bearing anchor escapes correctly. **My anchor harness could not see this** — it stripped the escapes and did a literal `grep`, never exercising shell expansion. |

| # | Sev | Verdict | Note |
|---|---|---|---|
| 4 | Major | **Valid, reproduced** | The anchor added last round to close a coverage gap validates nothing and fails silently. Same class, mine, again — and the harness blind spot is the interesting part: fence *execution* was added to catch stubs, and it did run, but nothing asserted that a fence's failure output means failure. |
| 3 | Major | **Valid** | Check 1's first fence prints `0` then `1` and exits 0 — it can report its own falsifying observation as success. I flagged this in the pass-12 prompt as "a stated read rather than a gate"; Codex is right that describing it does not excuse it. |
| 6 | Major | **Valid, and the best finding of the pass** | All five fences still pass after the 2026-07-20 row's narration is **edited**, and after the existing first header paragraph is changed identically in both surfaces. So the validation can go green while breaking the absolute append-only rule, story AC 2's every-byte requirement, and §4's "the existing first paragraph is **untouched**". Nothing in §6 pins either. |
| 1 | Major | **Valid** | The prose says "a row appended later can never come under an entry written before it"; the test excludes only *later-dated* rows. Same-day appends (already disclosed) **and backdated appends** (not disclosed) both remain eligible, and §3.1 says a later same-locator row joining the set is *intended* — so prose and procedure disagree in both directions. |
| 2 | Major | **Valid** | §2.1's trigger sanctions an entry when *any* later change falsifies a row, while the same paragraph puts a removed hardening out of scope. An author facing a removal gets both instructions. Prompt-standards item 7. |
| 5 | Minor | **Valid — and it lands on Daniel's phrasing** | "a typo fails the battery pre-merge, and merged history cannot carry an inert entry" overclaims: this assertion is a one-time bespoke check in §6, **not** in `AGENTS.md`'s quality battery, and §8 says no standing check validates future entries. Either wire it into the battery or narrow the sentence. |
| 7 | Minor | **Valid** | Fifth consecutive pass on the unanchored inventory: deleting the inert-entry remedy or the name-the-false-claim instruction from both surfaces leaves all 29 anchors intact. |
| 8 | Nit | **Valid** | §4 quotes the landed wording without its `**` emphasis. |

## Needs Daniel

- **F5** — his own phrasing: wire the assertion into `AGENTS.md`'s battery, or narrow the claim.
- **F1** — backdating: accept and disclose as a second residual, or forbid and validate.
- **F6** — byte-pin the target row and the existing header paragraph, or declare them unvalidated.

## Process note

The reviewer wrote `.context/gate-a-pass12-harness.sh` into the repo during this pass. It is no
longer present and `.context/` is gitignored, so nothing leaked into the worktree — but a gate
call is expected to write only its findings file, and this one did not.
