# Gate B quality evidence — k051rp95 pass 1

Range: `405738de006e5295443cc938cc3992f6b1a5b04e..770e7e56ec2bd68913ba19fbf6f0465855ca5659`. HEAD was verified as the requested head. Reviewed the diff, the adoption story, design and plan, the pilot story and its changed criterion, AGENTS.md, prompt standards, gate rules, and the connected checker/setup consumers. Existing spec-review output was neither read nor modified.

TESTS: none — assessed tests by inspection, as the review request permits. The required runner makes disposable copies outside this repository, conflicting with this request's repository-only work boundary. Neither the battery nor targeted tests were run; historical green claims in the story are not evidence for this review.

Discovery: direct git searches were used for shell scripts, Markdown and configuration. No graph index tied to this head was established and no index was refreshed. The human refresh command recorded at todos.md:1385 is `codebase-memory-mcp cli index_repository --repo-path <checkout root>`; it was not run. No network access or reads outside the repository were used.

Review hypotheses: fragment parsing could reject previously valid links; copy checking could accept a missing or divergent template; partial adoption could silently overwrite project files or leave reviewers without the rules pointer; moving exclusions to arguments could leave CI and local commands inconsistent. The first yielded the finding; inspection of the other paths did not establish a defect.

CALLERS: anchors(), heading normalization, fence state and duplicate counter — scripts/check-doc-links.sh:74 invokes the helper for Markdown fragments; scripts/check-doc-links.test.sh:38-53 exercises cross-file and local fragments, duplicates, punctuation, explicit attributes, indentation, CRLF, fences and non-Markdown targets. The identical helper is shipped inside workflow-init.md section 2.21. No empty-fragment fixture exists.
CALLERS: files/broken/p/t and skip-prefix argument handling — scripts/check-doc-links.sh:57-78; CI at .github/workflows/ci.yml:131 and AGENTS.md:244,249 now pass all three former exclusions. scripts/check-doc-links.test.sh:61-62 covers presence/absence of a prefix. workflow-init.md:1821-1828 bounds interpolated prefixes, and its closing checklist at 2066-2069 directs projects to add their command to CI and quality after a clean run. docs/setup.md:119 documents the default command.
CALLERS: link-check dl_case fixture helper — scripts/check-doc-links.test.sh:32-63 invokes it with positive and negative expectations; reject cases require both a nonzero exit and the expected diagnostic, while accept cases require zero. Fixture repositories stage their files and invoke the actual checker. The final untracked-file check uses the surviving fixture. No mocks replace link resolution.
CALLERS: check 4l / dl_file / dl_cmd / dl_out / parser status — scripts/check-invariants.sh:1138-1162 reads the repository script and section 2.21, checks one heading/opening/closing fence, then compares extracted bytes using cmp. Its result feeds the existing rc/fail mechanism. AGENTS.md:248,287-288 and docs/reference.md:615-619 describe its byte-comparison scope, not semantic correctness.
CALLERS: init_prompt_fixtures / tpl_sections / DL_SECTION — scripts/check-invariants.test.sh:39-114 supplies both copies to shared fixtures; tpl_sections is reused at lines 54,894,1314,1413,1470. The new invariant dl_case helper at 1533-1554 drives cases 1555-1565 for equality, divergence, missing script, missing heading, duplicate fences and unclosed fence. The mutation comment explicitly says earlier checks were not re-measured after the shared-fixture change.
CALLERS: workflow-init section 2.20 / .claude/living-docs.md presence switch — section 2.21 runs only with the rules present; the CLAUDE.md template pointer at 538 loads them for relevant work; the AGENTS.md interview at 1932-1938 gives Codex and PR reviewers the pointer; the closing checklist at 2061-2069 and report at 2104-2105 expose adoption and incomplete parts. docs/reference.md:155-176 and CHANGELOG.md section 0.42.0 describe this same opt-in and removal behavior.
CALLERS: workflow-init Rules 1-2 and new target decisions — existing different content requires diff and overwrite/merge/skip; section 2.20 retains this route for existing rules, and section 2.21 explicitly applies it to the checker. Completeness checks cover retained differing rules, a missing CLAUDE paragraph, the missing map pointer and a differing checker. No new destructive migration or deletion is instructed.
CALLERS: Living docs homes / provenance / build record / size and effort rules — workflow-init.md:1743-1816; CLAUDE.md pointer and Documentation map route readers here. The build record explicitly covers affected neighbours, top-level homes and both instruction files, and is forwarded in Gate B whatWasImplemented, the PR body and handover. The size alarm is advisory; missing effort is unknown. The user reference and changelog repeat the supported scope and name the unexercised non-goals.
CALLERS: Documentation map / architecture-home sentence — workflow-init.md:568-572 and Step 3:1926-1938 agree on the signpost, including existing suitable architecture homes. README.md:43 and docs/setup.md:76-81 expose the new opt-in; docs/reference.md:195-201 describes the expanded interview and closing checklist.
CALLERS: .claude/ prompt classification — .claude/review-gates.md:6 and plugins/dev-workflow/hooks/codex-gate.sh:1374-1390 include .claude paths in the prompt classification, supporting the new rules-file placement rationale. Hook implementation is unchanged by the range.
CALLERS: plugin version — plugins/dev-workflow/.claude-plugin/plugin.json:4 changes 0.41.0 to 0.42.0; CHANGELOG.md adds its matching release. Read the manifest directly; the diff adds no component redeclarations and changes no execution dependency pins.
CALLERS: packaging and script description — AGENTS.md boundary 5, docs/ARCHITECTURE.md:30,97-100 and docs/reference.md:615-619 distinguish the internal checker from its shipped inline text. No repository runtime module was added; the new files are story/spec/plan records.
CALLERS: adoption story/spec/plan paths — the new records cross-reference each other; CHANGELOG.md section 0.42.0 and the closed todos.md adoption row cite them. The pilot story AC-9 points to the separate adoption story without removing its original no-plugin-change condition. The pilot report's corrected go row cites an explicitly untracked board, which was not independently available in the reviewed tracked evidence.

### Strengths

- The checker tests invoke real shell code in fixture repositories and check rejection diagnostics as well as status.
- Check 4l gives the inline scaffold and repository checker a mechanical equality guard, with failure fixtures.
- Existing-file decisions retain explicit consent and report incomplete adoption; the new rules name their scope and exclusions.
- CI and the documented quality command both receive the former hard-coded skip prefixes, and the plugin version is bumped.

### Issues

Critical: none found. Important: none found. Minor: one empty-fragment regression, recorded in the findings file.

Static trace for the finding: with a tracked README containing `# Heading` and `[top](#)`, t is `#`, p resolves to README, and the target exists. The fragment branch calls anchors, which emits `heading`, then searches for an exact empty line. This fails and adds a broken-fragment diagnostic. A link to `guide.md#` follows the same path. An empty fragment denotes the document top and does not require an empty heading. The base checker skipped bare fragments and stripped fragments for path resolution, so both forms previously passed. This is static evidence, not an executed reproduction.

### Recommendations

Add the two empty-fragment acceptance cases and preserve path-existence checks for file-qualified links. Update both checker copies together. Obtain fresh required quality evidence for this exact head before merging; this review does not establish a green battery.

### Assessment

Ready to merge: with fixes and fresh quality evidence. The inspected implementation follows the adoption design and preserves the touched packaging and scaffolding invariants, but the new fragment lookup rejects a valid link form and execution results were unavailable for this head.
