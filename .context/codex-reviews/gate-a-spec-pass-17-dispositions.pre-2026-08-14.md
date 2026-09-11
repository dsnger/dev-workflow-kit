# Gate A — spec — pass 17 dispositions

Artifact: `docs/superpowers/specs/2026-08-05-hardening-ledger-supersession-design.md`
6 findings: **1 Major**, 4 Minor, 1 Nit. **No Blocker.** All six valid. **None applied.**

Reviewer: `mcp-codex-dev@1.0.1`, `codex-cli 0.144.5`, model `gpt-5.6-sol`. No stray artifact.

Passes 4 → 17: **11, 14, 16, 15, 9, 10, 5, 12, 8, 6, 3, 4, 7, 6.**

## The composition changed, which matters more than the count

Pass 16: five of seven findings were in §6's shell. Pass 17, with the shell gone: **one Major**,
and it is a claim-versus-reality question about the design, not a mechanism defect. The other five
are a copied value, two miscounts, a wrong cross-reference, and markdown rendering — all mine, all
introduced by the restructure itself.

No finding disputes a settled decision. No finding says a property is undecidable, a falsifying
observation is wired to pass, or an oracle is missing a distinction — which was rider 4's whole
purpose, and the first time that rider has come back empty.

## Verified

| # | Claim | Result |
|---|---|---|
| 5 | the backdating prohibition is in §2.2, not §2.1 | **Confirmed.** It sits at `:148`, inside §2.2 (which begins at `:125`). Both `:298` and `:446` cite §2.1. |
| 6 | anchors 3, 5, 8, 15, 18 render wrong | **Confirmed.** Each is wrapped in single backticks while containing backticks — e.g. `` 15. `block above the `Columns:`` `` renders with a stray trailing backtick. A reader copying the rendered list implements a weaker pattern than the prose requires. |
| 3 | "Five properties" precedes 1a–1f | **Confirmed** — six. |
| 4 | "four things" precedes five bullets | **Confirmed** — five. |

| # | Sev | Verdict | Note |
|---|---|---|---|
| 1 | Major | **Valid — and it needs Daniel** | Two rows sharing `date` **+** `fingerprint` **+** `finding` cannot be separated: the only narrowing device is a fragment of `finding`, which they share. §2.2 says "there is no unresolvable state left for it to stop on" — that is an overclaim in exactly the class this review keeps finding, and it is now the *design* making it rather than a check. Consequence: if only one such row's narration is false, every permitted entry also marks its accurate sibling. Options: narrow the claim and record the limitation (consistent with how §8 is written), or add a discriminator, which means new locator syntax in the shared convention. |
| 2 | Minor | **Valid** | The opening says no profile value is copied into the spec; §6's "Mode" copies `battery+check` from the story header. A confirmed profile change would leave the spec stale while the header is authoritative. |
| 3 | Minor | **Valid, confirmed** | Mine, from the restructure. |
| 4 | Minor | **Valid, confirmed** | Mine — and precisely the coverage-count drift rider 1 exists to catch, committed while writing the rider. |
| 5 | Minor | **Valid, confirmed** | Two sites cite the wrong section for the precondition they rely on. |
| 6 | Nit | **Valid, confirmed** | Mine. The anchors are declared as literal data and five of them do not render as their own content. |

## Read

Five of six are artifacts of the restructure — the cost of moving 226 lines, and all cheap. The
one that isn't is a real limit on the locator, surfaced only once the shell stopped drowning it
out.
