# Spec review evidence

Range: b18e7db386a20efe0e751111e241a6b88eceb9d6..4972cb18c6bb42c058169eb566fa59a2c7ae87a2. HEAD resolves to the requested head. Reviewed the committed diff and head artifacts, not the implementer's summary as proof.

TESTS: none — static review chosen, as permitted by the brief. The required test runner creates a disposable copy outside this repository; this review honors the user's repository-only work restriction. No battery evidence was supplied, and no passing execution, mutation result, or runtime portability is asserted here.

Discovery: used git grep against the reviewed head for dependents. No graph index matching this historical head was established. No index refresh command is recorded in todos.md § Tooling revalidation; no indexing was performed. The skill's referenced .claude/review-gates.md is absent from this checkout; the explicit findings format in the review brief governs the output.

## Acceptance-criterion mapping

The cited stable-ID story has six criteria. Its design §5 maps those same six criteria; the telemetry story's only change is an open question about low-effort reviews, not a request to implement telemetry here.

| Criterion | Implementation at head | Test or manual check |
|---|---|---|
| AC-1: numbered template | plugins/dev-workflow/skills/intake/SKILL.md:170–174, with draft revalidation at 138–142 | scripts/check-invariants.sh:588–623 scans the fenced template; scripts/check-invariants.test.sh:826–878 contains accept/reject fixtures for identifiers, boundaries, numbering, and scope. Read, not run. |
| AC-2: permanent IDs, additions, withdrawal, narrowing | intake/SKILL.md:201–220 supplies draft/commit distinction, dated withdrawal/rewording, next-unused numbering, and human collision resolution | No automated amendment test; manually checked rules and worked example at 233–243 against design §2. |
| AC-3: citation form and consumers | intake/SKILL.md:221–226 names plans, specs, gate calls, evidence entries and fate tables; gives the legacy-story quotation form | No automated test; prose matches design §2 rule 4 and explicitly preserves record formats. |
| AC-4: older stories | intake/SKILL.md:227–232 preserves existing IDs and delays adoption in unnumbered stories until amendment, with rule line and dated adoption note | No automated test; manual comparison with design §2 rule 5. No mass rewriting of older criteria appears in the diff. |
| AC-5: demonstration | intake/SKILL.md:233–243 shows insertion as AC-4, withdrawal of AC-2 and narrowing of AC-3 while other identifiers remain fixed | Worked example is the explicitly permitted manual demonstration. Check 4d and its fixtures cover template spelling only; prose does not claim they test amendment history. |
| AC-6: identifiers only | Changed shipped behavior is confined to intake; manifest and changelog accompany it. CLAUDE.md, workflow-init, process-pr-review and the gate hook are unchanged | Diff inspection and dependent searches; no gate, pass, record or evidence-entry grammar change found. |

## Specification and invariant checks

Checked the five rule blocks, italic template line, worked example, revalidation and common-mistake addition against design §2. Existing revalidation conditions remain present. The collision exception and legacy citation behavior are explicitly specified, not extra functionality.

Checked check 4d against design §3: required readable file; first fence restricted to the Story template section; closed markdown fence; exactly one of each boundary in order; blank/rule/criterion line classes; one literal rule line; nonempty sequential positive IDs; distinct parser failure. Its row regex requires at least one character after the space, equivalent to the specification's .+ for this unanchored match. The checker deliberately ignores content after the template and rows under section 4. The plan's stricter first-fence and section-end decisions are reflected in the implementation and tests.

Read the fixture initializer, ac_case and inject_case assertions. Reject fixtures require nonzero status plus an AC diagnostic; acceptance fixtures require zero. The parser stub targets the ac-template-scan marker and requires its parser-specific diagnostic. Unreadable-file coverage is explicitly conditional on a non-root user. These are executable assertions, not unconditional successes. Shared fixtures now include a valid intake template so earlier tests are not deliberately invalidated by check 4d.

Verified invariant 12's version change from 0.14.0 to 0.15.0 and corresponding newest changelog entry. Read the actual manifest: metadata only, no convention-loaded component keys introduced (invariant 6). No execution dependency or pin changes (invariant 5), hook changes (invariants 1–4), scaffold changes (8–9), taxonomy changes (10), or examples changes (7).

Reviewed all 12 prompt-standards items for the changed intake text: existing target identification, explicit draft criteria, collision stop condition, concrete template/example, structured rule block, stated reasons, compatibility with existing constraints, deliberate short portable rule line, motivated prohibitions, no added diagnostic state, calibrated narrow-check claims, and ordinary emphasis. Model-specific external guidance was not revalidated because this review prohibits network use.

Reviewed supplemental docs: four-check counts in AGENTS.md, README, CI and checker comments agree; getting-started and coding-workflow describe IDs without claiming mechanical enforcement of amendment behavior. The telemetry question and backlog status are documentation, not extra implemented features. Plan prototype counts are historical evidence, not evidence of tests at this head; the suite's comment separately records its later extra boundary fixture.

## Dependents

CALLERS: intake Story template / section 3 / section 4 boundaries — scripts/check-invariants.sh:585–623 extracts these exact headings; scripts/check-invariants.test.sh:65 and 836–878 construct and mutate them; intake flow steps 8–10 use the template. Headings are preserved.
CALLERS: Acceptance-criterion IDs / italic rule line — intake/SKILL.md:171,196–243; checker AC_RULE at scripts/check-invariants.sh:584; fixture AC_RULE_LINE at scripts/check-invariants.test.sh:54. Literal copies agree; design §2 and plan document the same rule.
CALLERS: ac_template_scan / AC_RULE / AC_FILE / ac_out / ac_st — scripts/check-invariants.sh:584–642; the top-level invocation checks parser status before interpreting output and routes failures through the existing fail mechanism. No external symbol users found.
CALLERS: init_prompt_fixtures — scripts/check-invariants.test.sh:87,296,328,345,406,597,618,643,693,809; each builder receives the valid template via the shared initializer.
CALLERS: ac_rows / ac_skill / AC_RULE_LINE — scripts/check-invariants.test.sh:50–66 and 826–878; fixture generation occurs before checker execution and altered cases replace the generated skill body.
CALLERS: ac_case / AC — scripts/check-invariants.test.sh:803–878; new rejection and acceptance cases use its status and diagnostic checks.
CALLERS: ac-template-scan / inject_case — scripts/check-invariants.sh:589 and scripts/check-invariants.test.sh:640–667,882–884; the marker selects only the new parser invocation for fault injection.
CALLERS: check 4d block markers — scripts/check-invariants.sh:24–53,569,643 and scripts/check-invariants.test.sh:375–377; the existing manual mutation procedure now names the fourth block. Historical mutation counts were not independently rerun.
CALLERS: scripts/check-invariants.sh and its suite — .github/workflows/ci.yml:64–66,110–111; AGENTS.md command table; README.md:162; docs/architecture.md:18. Existing CI invocation reaches the added check without a new job.
CALLERS: plugin manifest version / CHANGELOG 0.15.0 — packaging invariant 12, scripts/check-version-bump.sh and plugin loading; manifest read and committed version delta verified, version checker not executed.
CALLERS: criteria documentation — docs/getting-started.md:13–15 and docs/coding-workflow.md:74–78; workflow-init.md:1956 uses a generic minimum-criteria example, not a competing template or position-based citation rule.
CALLERS: P5 light / stable-ID story path — todos.md:676 onward, design and plan headers; all describe one AC sequence and no shipped plan template. The new telemetry open question is confined to its existing questions section.

Conclusion: no spec-compliance findings. This is a source-and-prompt inspection result, not a claim that the quality battery passed.
