# Gate-A spec pass 4 — dispositions (cycle awsf1ec771)

Advisory companion. Not a findings file; it participates in no pass validation.
Spec revised at 07c88a1 → this revision. Findings: `gate-a-spec-awsf1ec771-pass-4.md`.

**Scope stop, surfaced and ANSWERED.** Finding 1 opened a new contract question — whether §5
gains a record for accepted obligations — and was surfaced to Daniel with the finding still
open, per §5's scope-stop rule. **Daniel's answer, 2026-09-10: accept.** The change ships a
second label, `Accepted:`, sharing the decline record's form, transport, nonce and carry rules.
This is authorised scope growth beyond the story's §2.

**This cycle writes no `Accepted:` record of its own.** It began before these rules ship and
finishes under the rules it started with, which have no such record. This file and
`gate-a-spec-awsf1ec771-resume.md` are what today's rules provide for that acceptance.

1 | accepted-and-shipped | Third raise, and the D10 dismissal was wrong: D10 settles unavailable-pass-history reporting, not loss of closure state. Surfaced as a scope stop; Daniel accepted. Ships the `Accepted:` label plus the honest residual — a replacement cycle can still close the same artifact, and the record makes that discoverable, not impossible.
2 | fixed | The question-stop resume clause (`b18`) now takes the same aggregate precondition as `b12`. No local "resumes once that question is answered" reading survives.
3 | fixed | Q6 self-contradiction removed. One gap policy: consecutive available passes compare across a gap, visible but weaker evidence; a comparison needing the missing pass as an endpoint is unavailable.
4 | fixed | Q6 partition rebuilt on two observables — slot present/valid, and pass known-accepted. Acceptance-unknown is not counted toward the floor, series `?`, disclosed: crediting an unvalidated pass is the dangerous direction.
5 | fixed | The root-detection claim is withdrawn. A slot written under another root is stated as indistinguishable from an absent one; where the current root cannot be established the cycle stops, and the recovery is to re-run from the correct root.
6 | fixed | The (g) severity paragraph gains its own reciprocal one-contract sentence. All three independently mergeable pieces now name the other two.
7 | fixed | The rollback overclaim is withdrawn. A rollback that removes the fallback text leaves a cycle that stops and is a human's to resolve; it does not close. Residual named: no record identifies the rule revision a cycle started under.
8 | fixed | §8's dissolution claim is narrowed to post-rule and unknown-start cycles. Pre-rule cycles still exist, are bounded and self-terminating, and two observably live ones are serialized by a human rather than by a shipped production.
9 | fixed | `b12` marked **replaced**, with its old immediate-resume condition enumerated and the kept/changed halves stated. `b18` marked replaced for the same reason.
10 | fixed | The 135-condition inventory is committed as `docs/superpowers/specs/2026-09-10-loop-rule-consolidation-condition-inventory.md`, machine-local paths stripped, with a header stating it is a snapshot against 7c0d475 and the id definition the accounting cites.
11 | fixed | "the author's judgement about the fix set" → "about the finding's repair severity", with an explicit clause saying set membership is a separate predicate this must not be read as touching.
12 | fixed | Continue branch: below the floor, and on the current artifact whether revised or not, since Minors and Nits are collected and may leave nothing to revise.
13 | fixed | Discharge clause tied verbatim to the clean predicate — "no in-set Blocker or Major at effective severity" — so duty and predicate cannot drift apart.
14 | fixed | Second raise of a NIT, and the sentence was already being edited: squash carry takes one copy per cycle nonce plus five-field key, byte-identical repeats collapse, conflicting copies stop under the existing rule.
15 | fixed | The parity rationale was mechanically false — `### Mechanics (reference)` is at W:968. The row is re-marked "not deliberate" and W's cross-reference is **aligned** to C's wording as a third (b) edit.
16 | fixed | With the acceptance record shipping, only one thing stays unrecorded: a stuck or two-tell surface and its continue-or-stop answer. Disclosed in one sentence in the shipped block.
17 | fixed | One filled Q6 example added to the shipped text — the three lines over a gapped history plus the root line, six lines, per prompt-standards item 4.
18 | fixed by narrowing | §10 no longer claims every constraint carries an inline why. It names three settled axioms as deliberately unmotivated (D1, the existing zero-finding exit, D6) and says the plan's review reads every other sentence for one.

**Severity correction carried forward:** pass 3's finding 12 was raised MINOR and treated as
MAJOR under the instrument carve-out (a false green in the evidence). Recorded in that pass's
dispositions; noted here because the assert it added is extended by finding 1's disposition.

**Mechanical self-check, this revision.** Every OLD sentence the spec quotes counts 1/1 in both
copies (27 fragments, lines joined), with two deliberate exceptions: the (g) ownership sentence
is 1/0 because only C carries it, and the (b) cross-reference is 1/0 because W says "the
severity rule" — which is the divergence finding 15 aligns. New lead phrases count 0/0. Fences
balanced. No placeholders. Spec 719 lines, under the 720 ceiling.
