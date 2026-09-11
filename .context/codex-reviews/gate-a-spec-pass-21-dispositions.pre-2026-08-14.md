# Gate A — spec — pass 21 dispositions

Artifact: `docs/superpowers/specs/2026-08-05-hardening-ledger-supersession-design.md`.
7 findings: 6 Major, 1 Minor. **No Blocker.** All seven valid.
**Five applied. Findings 1 and 2 held for Daniel** — their fix reverses wording he specified.

Reviewer: `mcp-codex-dev@1.0.1`, `codex-cli 0.144.5`, model `gpt-5.6-sol`. Pass file valid:
8 lines, 7 finding lines, terminator exact, no stray artifact.

Passes 4 → 21: **11, 14, 16, 15, 9, 10, 5, 12, 8, 6, 3, 4, 7, 6, 6, 5, 6, 7.**

## The shape that matters more than the count

The count is rising — 5, 6, 7 — and it is rising **inside machinery this cycle added at passes 19
and 20**. Findings 1 and 2 are both about 1d's *second half* and 1f's successor paragraph; pass
20's findings 1, 4 and 6 were too. That clause is generating roughly one Major per pass and each
fix makes it larger. The other four findings this pass are ordinary under-specification of things
the change genuinely does (parsing, comparison domain, the floor's boundary, 1c's input count) and
they closed on one edit each.

## Verdicts

| # | Sev | Verdict | Disposition |
|---|---|---|---|
| 1 | Major | **Valid, and it breaks the clause structurally.** §2.2 admits an inert entry aimed at *a row that never existed*. For that entry no successor naming its intended row can exist — there is no such row — while 1d demands a successor and the entry floor forbids deleting the line. The validation is then permanently unsatisfiable in a state the convention explicitly sanctions. | **HELD.** |
| 2 | Major | **Valid.** "The row the inert one meant to name" is authorial intent the ledger does not encode. Even when the row exists, 1f's fifth confirmation can be asserted but not verified from the artifact, so 1f cannot carry the judgement pass 20 moved out of 1d. | **HELD** — same fix as 1. |
| 3 | Major | **Valid.** The two prose fields are free text and ` · ` is the field separator; nothing forbade or escaped it, so a permitted entry could parse two ways. | Applied: the shared prose now forbids ` · ` inside either field, and the recognition oracle cites that as why the split is unambiguous. |
| 4 | Major | **Valid.** Fragment matching never named its comparison domain — raw cell bytes, rendered text, or an unescaped cell — so a checker and a reader can disagree exactly on the rows carrying `\|` or markup, and agree everywhere else, which is the silent direction. | Applied: shared prose pins **literal, case-sensitive, against the raw `finding` as written**; the matching oracle repeats it and gains `\|`, markup and case fixtures. |
| 5 | Major | **Valid.** §2.1 said protection starts "once the line exists", the shipped prose "once a line exists as an entry" — leaving a saved half-typed line with two defensible verdicts. It also had to be settled for 1d to be *actionable*: 1d fails on an unparseable candidate, and an author who could not repair it would be stuck. | Applied: protection begins at **complete entry shape**; partial or malformed lines are drafting and may be fixed; a complete zero-match entry is protected. **Anchor 35 reworded to match.** |
| 6 | Major | **Valid.** 1c's three-input design uses one base paragraph for both surfaces, so it proves the template untouched only by leaning on the separate fact that the surfaces are byte-identical today. | Applied: four inputs — each surface against its own base — with current parity asserted separately. |
| 7 | Minor | **Valid.** `2026-02-30` is `YYYY-MM-DD`-shaped, sorts correctly, and is not a date; it would satisfy both 1e's ordering and 1d's on-or-before bound. | Applied: calendar validity required in entry recognition and in 1e, with the failure named. |

## Sweep after applying

35 anchors, each exactly once in the convention prose, none a substring of another, no padding
asymmetry; six fence lines, balanced; both count claims read thirty-five; 1d still declares seven
oracles.

## The question put to Daniel

1d's second half — *"no inert added entry stands uncorrected by a later added entry"* — is his own
pass-19 wording. Recommendation: **drop it**, leaving 1d as *"the entry §3.1 mandates matches at
least one row dated on or before its own date"*.

- It still passes §2.2's sanctioned typo-then-correct scenario — the mandated entry **is** the
  corrected one — which was his binding constraint on the rewrite.
- It still fails the mistyped-locator case it was written for: the mandated entry does not match.
- It drops with it the successor rule, the duplicate-alignment oracle pass 20 added, and 1f's fifth
  confirmation — the three sites that have produced four Majors across two passes.
- What it stops covering: an **additional** inert entry appended by the same change goes undetected.
  This change appends exactly one entry, so the state is not reachable here, and §6's checks are
  one-time regardless — §8 already says nothing runs on a future supersession.

The alternative is to keep the clause and add finding 1's no-target exemption plus finding 2's
evidence requirement. That is more machinery in the region that keeps generating findings.
