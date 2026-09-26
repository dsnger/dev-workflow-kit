# OpenWolf assessment — context, memory and the dev-workflow kit

**Assessment date:** 2026-09-16. **Status:** advisory documentation draft; no
integration or pilot approved. This is a project-local assessment, not a shipped
prompt, execution plan, or source of permanent workflow rules.

## Authorization and source snapshot

Daniel requested an evidence-based comparison, then asked to preserve the
recommendation and its trade-offs alongside the current plan. He subsequently
authorized the advisor to make these documentation edits directly. That authorizes
this document, an informational plan link, and a parked backlog reference. It does
not authorize installation, a pilot, product implementation, another repair round,
or a new gate call. The recommendations below remain the advisor's recommendations;
recording them does not turn them into approved implementation decisions.

The original comparison inspected local HEAD `df9123a`. Before writing this record,
the advisor rechecked the clean worktree on `loop-rule-consolidation` at
`c1fcdd1ded1860998641808b203aafaf728549e0`. The latest committed plan revision was
`df9123a68cd85e4b54e1c0a2923e4ac94402d98c`. [Pass 39][kit-pass39] reports one Blocker
and one Major; the [working record][kit-resume] leaves cycle `om0bdd7udh` open and
unclean, awaiting Daniel's decision. This is a dated observation, not a second
maintained cycle-status record. The actual repository and gate artifacts govern
later work. The added plan reference was not part of the revision reviewed in pass 39.

External sources: [OpenWolf's website][ow-site], [repository][ow-repo], and source at
commit `04b75ca9c40d10c345ae4f5157e033d7397f1b7a`, assessed alongside published version
2.5.2. Code links below pin that commit rather than following `main`. Local source
links refer to paths inspected at `c1fcdd1`; later edits to those paths do not
retroactively update this assessment.

**Evidence boundary:** the advisor inspected source, documentation and tests, and
confirmed the successful [published CI run][ow-ci]. The advisor did not install
OpenWolf, execute its suite, or reproduce its native-agent sessions. Test counts
and live-session results below are attributed to the release report. Static
observations and their implications are distinguished from executed checks.

## Recommendation and alternatives

The advisor recommends using selected OpenWolf mechanisms as design references,
and considering a separately authorized external evaluation. Full incorporation
or installation with unchanged defaults is not recommended for the current kit.
OpenWolf manages context transport and visibility; our independent reviews,
closure conditions, quality command and hardening procedure retain their roles.

| Candidate | Existing solution | Expected benefit | Cost or limitation | Advisor recommendation | Evidence / what could change the recommendation |
|---|---|---|---|---|---|
| Entire OpenWolf runtime | Prompt-based workflow plus one shipped POSIX hook | Automated context lifecycle across supported agents | Node runtime, dependencies, adapters, instruction conflicts and update policy | Do not incorporate wholesale | [Architecture][kit-agents], [package][ow-package]; reconsider only with demonstrated benefit and an explicit integration design |
| Evidence-linked handover | Optional resume companions and cycle identity | Faster reconstruction with inspectable sources and explicit gaps | Evidence may be incomplete; exported fields do not all enter active receiver state | Highest-value design inspiration | [Handover][ow-handover]; a pilot must preserve constraints and unresolved work across interruption |
| Memory and bug retrieval | Hardening ledger and recurrence procedure | Find relevant prior mistakes without scanning the entire history | Learned text can acquire unintended authority; a second ledger can diverge | Retrieve existing evidence; retain existing rule and ledger ownership | [Protocol][ow-protocol], [hardening][kit-hardening]; reconsider only with a clear authority boundary |
| Another code index | Codebase-Memory-MCP available in Daniel's environment | Compact navigation in other environments | Duplicate indexing and maintenance; limited extraction is not complete semantic analysis | No second index in the kit now | [Scanner][ow-scanner], [symbols][ow-symbols]; a concrete discovery gap could justify evaluation |
| Automatic output reduction | File-first findings and targeted reads | Less context spent on large outputs | Removed text can contain the condition or finding being reviewed | Exclude automatic evidence truncation from a proposed review-path pilot | [Governor][ow-governor], [output hook][ow-output]; benefit requires preserved review completeness |
| Archive, journal and hook health | Cycle-specific paths; locally tracked review files | Recoverable older context and visible runtime failures | Technical persistence does not establish semantic correctness or gate validity | Reuse ideas when separately commissioned | [Archive][ow-archive], [journal][ow-journal], [heartbeat][ow-shared]; a concrete loss or diagnostic need would motivate work |
| Usage reporting | Review curves and ledger; no comparable provider-usage collector in the shipped hook | Observe actual resource use separately from estimates | Harness coverage, attribution, collection overhead and no counterfactual baseline | Best candidate for an optional external evaluation | [Usage][ow-usage], [estimates][ow-estimates]; require measured net benefit at comparable quality |

This is not evidence that context loss caused the current long plan cycle. The
latest findings concern sequencing and staging. Better context transport might
help an agent work on them; it does not establish correct rule interactions or
adequate review coverage. [Pass 39][kit-pass39] supports that narrower diagnosis.

## Findings and trade-offs

### Handover: references help, summaries do not confer approval

**Source facts.** OpenWolf exports source-linked events and agent-authored
checkpoints, identifies repository/worktree and destination agent, records gaps
and omitted events, and labels the packet as untrusted historical evidence.
Import checks sources and repository state; validation must be rerun against the
receiving worktree. Retrieval and active-state injection can expose a bounded
selection rather than an entire transcript. [Sources][ow-sources],
[handover service][ow-handover], [active state][ow-state].

**Static limitation.** Export includes checkpoint `constraints` and `completed`.
The `importPacket` patch merges objective, next action and unresolved items, but
does not merge those two fields into the receiver's active state. They remain in
the stored packet. Packet availability therefore does not prove that every
restriction reaches the receiving agent's active context. This was observed in
source, not reproduced in a running harness. [Handover service][ow-handover].

**Interpretation.** The useful pattern is a short map to evidence, with provenance
and omissions, rather than another authoritative account of the project. Our
[optional companions and nonce rules][kit-claude] already cover parts of this
problem. The [shipped hook registration][kit-hooks] has no SessionStart,
PreCompact or Stop checkpoint lifecycle comparable to OpenWolf's.

**Recommendation.** Preserve original sources and distinguish user constraints,
agent conclusions and historical test results. Shared context may help independent
reviewers locate evidence; an author's conclusions must not become their accepted
answer. A restored packet cannot restore gate approval by itself.

### Memory authority: implementation and installed instructions differ

**Source facts.** OpenWolf's protected-memory path requires a protected verifier
and an independently provisioned approval snapshot. An ordinary user-writable
installation does not satisfy that authority check. [Trusted memory][ow-trust].
However, the shipped protocol tells the agent to use STATUS.md instead of
reconstructing context from plans/code, respect cerebrum entries, and avoid
rereading unchanged files. Those instructions are broader than treating memory as
untrusted evidence. Initialization rewrites OpenWolf's own protocol and Claude
rule file. [Protocol][ow-protocol], [initialization][ow-init].

**Interpretation.** Guarding automatic instruction reinjection does not eliminate
the authority conflict in separately installed prompts. A mistaken summary or
agent-authored learning could steer work away from current authoritative text.
This is a documented instruction conflict, not a demonstrated exploit.

**Recommendation.** Memories may suggest sources and hypotheses. Permanent rules
still need deliberate review in their established homes. A safe evaluation must
inspect installed instructions, not just configuration switches. Custom edits
also incur maintenance if a later initialization overwrites them; our own
[workflow-init][kit-init] handles differing project files through an explicit
comparison and decision.

### Existing knowledge: avoid a parallel index or ledger

**Source facts.** OpenWolf builds file descriptions, bounded symbol outlines and
import-based navigation. Its scanner distinguishes incomplete refreshes from a
complete scan and preserves unseen entries during partial work.
[Scanner][ow-scanner], [symbol extraction][ow-symbols]. Codebase-Memory-MCP was
available and used in this advisory session. That is an environment capability,
not a feature installed by the kit's [MCP configuration][kit-mcp].

OpenWolf also records bugs for retrieval. Our [hardening procedure][kit-hardening]
instead checks recurrence, proposes a fitting stronger rung, verifies changes
and records the hardening. Neither the presence of a bug entry nor retrieval of
one performs those steps. [Bug tracker][ow-bugs].

**Recommendation.** Reuse existing discovery and make prior ledger evidence easier
to find before adding another index or authoritative bug collection. Durable
delivery of a fixed finding to the ledger is already owned by [Finding A][story-a];
its identity, deduplication and consumption questions remain real design work.

### Output reduction and repository snapshots: retain our review semantics

**Source facts.** OpenWolf's default governor replaces selected large file-print,
grep and git-show outputs; test/build families default to suggestions. Condensation
can remove diff hunks or retain only selected parts of longer output. The output
hook checks whether the original survived caching, but can still emit condensed
text when preservation failed, without claiming a recoverable copy. Actual
replacement depends on harness support. [Configuration][ow-config],
[governor][ow-governor], [output hook][ow-output].

**Interpretation and recommendation.** This may help navigation, but an omitted
middle section can contain a necessary finding or predicate. Keep the
[file-first findings protocol][kit-claude] and exact-source access; evaluate query
hints rather than automatic truncation on the review path. The runtime's default
duplicate-read mode is a warning, which is narrower than the blanket reread
instruction in its protocol. [Read hook][ow-read], [protocol][ow-protocol].

**Separate static finding.** OpenWolf's repository snapshot combines HEAD-related
diff data, dirty-path discovery and contents read from disk. Staged paths are
enumerated, but staged blob contents are not independently hashed as an index
tree. Different staged contents at the same dirty path, with identical HEAD and
worktree, can therefore yield the same snapshot. This inference was not exercised
in a disposable repository. [Repository snapshot][ow-repository].

Our [tree_hash implementation][kit-hook] includes a tree of the effective index
(honoring GIT_INDEX_FILE), a worktree tree and tracked diff data, excluding
`.context/`. Retain that comparison for the hook's invalidation decision. It still
does not prove that a reviewer read a particular revision or that the review was
complete; those claims exceed the comparison.

### Persistence and health: useful engineering patterns with bounded claims

**Source facts.** OpenWolf archives older memory blocks by content hash, verifies
the archive before replacing active text with a pointer, and checks content and
marker when restoring. Its event journal persists events and uses event identities
when reconciling them. Hook heartbeats record success, error and consecutive
failure information even though hooks exit without blocking the agent.
[Archive][ow-archive], [journal][ow-journal], [heartbeat][ow-shared].

**Interpretation.** These are useful patterns for retaining original evidence and
making failed automation visible. They do not establish that a finding was
semantically processed exactly once, or that a gate passed. OpenWolf's memory
archive does not automatically archive our `.context/codex-reviews` artifacts.

Our nonce paths and locally tracked review directory already mitigate some loss.
The [.gitignore][kit-ignore] explicitly documents that tracking review files is a
local divergence from the shipped template. A historical story saying all such
files are ignored is not the present local behavior. Further persistence work
belongs to an explicitly scoped decision; [record durability][story-durability]
does not silently acquire runtime machinery or a changed trigger from this memo.

### Measurement, maintenance and remaining evidence

**Source facts.** OpenWolf separates transcript-derived provider usage, including
coverage/availability, from estimated token effects of its interventions.
[Usage][ow-usage], [estimate accounting][ow-estimates]. Our review curves are
explicitly author-written and unchecked in [CLAUDE.md][kit-claude]; they are not
provider telemetry. [P8][story-p8] permits read-only ledger/git analysis and
explicitly excludes new instrumentation.

**Interpretation.** Recorded consumption alone cannot establish how much the same
task would have consumed without OpenWolf. API price estimates are not necessarily
subscription expenditure; token usage is not remaining context capacity. An
evaluation needs a baseline and comparable task quality, including the context
cost of memory injection and collection.

**Adoption costs.** OpenWolf adds a Node 20+ runtime and dependencies to a kit whose
shipped executable is a POSIX hook. Its default compatible-update policy can select
new runtimes between sessions, despite pinning within a session. That is not our
deliberate exact-version update policy. OpenWolf declares AGPL-3.0-only; this kit
uses MIT. Direct code reuse needs a separate licensing assessment; this memo makes
no legal compatibility determination. [Package][ow-package], [updates][ow-updates],
[our invariants][kit-agents], [our license][kit-license].

**Reported, not reproduced by the advisor.** The 2.5.2 release report describes
322 tests in 72 suites, package/install checks and native Codex recovery after
resume/compaction. It also states that the full live Claude/Codex round trip and
paired long-session quality/token-efficiency evaluation remain outstanding;
Claude model access prevented a successful coding turn. Automatic handover import
stays off. The advisor confirmed the referenced CI run's successful status, not
the general effectiveness of these features in this workflow. [Release report][ow-release].

## Proposed evaluation — parked, not executable

**Activation requires Daniel's explicit authorization of a bounded evaluation.**
Finishing loop-rule-consolidation alone does not activate it. The eventual scope,
project and evaluation budget remain undecided. These are candidate criteria for
that decision, not additional acceptance criteria for the current plan:

- Use an isolated test project and an exact runtime version, with automatic updates
  off and installed instructions inspected for conflicts with project authority.
- Disable automatic output replacement; retain complete review evidence and the
  existing gates. If configuration cannot isolate those behaviors, report the
  adaptation cost before choosing an adapter or fork.
- Compare against existing resume artifacts and graph-assisted discovery. Keep
  task, model/harness and validation comparable and record differences explicitly.
- Exercise interruption/compaction: check objective, constraints and unresolved
  findings against their sources; detect stale or missing sources without reviving
  earlier gate approval. Check journal replay separately from semantic consumption.
- Observe total recorded usage, retrieval effort and review completeness. Include
  memory overhead and unavailable measurements; do not rename estimated savings
  as measured improvement.
- Report lost constraints, concealed evidence, unintended instruction changes or
  falsely restored approval as reasons to stop the trial and reassess. Reduced
  token use alone is insufficient if quality declines.

The evaluation could support optional external use, an independently designed
small feature, or a decision to adopt nothing. No outcome is assumed here.

## Existing work and review boundary

| Existing owner | Relationship | Boundary retained |
|---|---|---|
| [Finding A][story-a] | Fixed findings surviving handoff before ledger consideration | Preserve its exact scope and design questions; do not introduce a second route |
| [Record durability][story-durability] | Evidence surviving session and Git boundaries | Existing trigger, proposed profile and exclusions remain; this memo does not evaluate whether its trigger fired |
| [P8][story-p8] | Analysis of existing ledger/git records | New transcript collection is additional scope, not an already-authorized P8 implementation |
| [Current consolidation plan][kit-plan] | Discovery link to this assessment | No new task, prerequisite, closure condition or repair authorization |

The documentation request preserves a decision basis; it does not approve the
assessment as a spec or settle pass 39. Existing review requirements remain.
The memo and plan-link amendment are not covered by the old pass merely because
their purpose is informational. Until committed through the applicable workflow,
these files are worktree drafts rather than durable Git history.

## Sources

Local references are relative to this document. External code references pin the
assessed revision. The website is background context, not authority for a code claim.

[kit-agents]: ../AGENTS.md
[kit-claude]: ../CLAUDE.md
[kit-plan]: superpowers/plans/2026-09-14-loop-rule-consolidation.md
[kit-resume]: ../.context/codex-reviews/gate-a-plan-om0bdd7udh-resume.md
[kit-pass39]: ../.context/codex-reviews/gate-a-plan-om0bdd7udh-pass-39.md
[kit-hooks]: ../plugins/dev-workflow/hooks/hooks.json
[kit-hook]: ../plugins/dev-workflow/hooks/codex-gate.sh
[kit-init]: ../plugins/dev-workflow/commands/workflow-init.md
[kit-hardening]: ../plugins/dev-workflow/skills/harden-finding/SKILL.md
[kit-mcp]: ../.mcp.json
[kit-ignore]: ../.gitignore
[kit-license]: ../LICENSE
[story-a]: superpowers/stories/2026-08-04-ledger-route-without-pull-requests-story.md
[story-durability]: superpowers/stories/2026-09-10-record-durability-story.md
[story-p8]: superpowers/stories/2026-08-04-passive-metrics-over-the-ledger-story.md
[ow-site]: https://openwolf.com/
[ow-repo]: https://github.com/cytostack/openwolf
[ow-ci]: https://github.com/cytostack/openwolf/actions/runs/34894539164
[ow-package]: https://github.com/cytostack/openwolf/blob/04b75ca9c40d10c345ae4f5157e033d7397f1b7a/package.json
[ow-handover]: https://github.com/cytostack/openwolf/blob/04b75ca9c40d10c345ae4f5157e033d7397f1b7a/src/handoff/service.ts
[ow-sources]: https://github.com/cytostack/openwolf/blob/04b75ca9c40d10c345ae4f5157e033d7397f1b7a/src/handoff/sources.ts
[ow-state]: https://github.com/cytostack/openwolf/blob/04b75ca9c40d10c345ae4f5157e033d7397f1b7a/src/hooks/handoff-state.ts
[ow-trust]: https://github.com/cytostack/openwolf/blob/04b75ca9c40d10c345ae4f5157e033d7397f1b7a/src/hooks/trusted-memory.ts
[ow-protocol]: https://github.com/cytostack/openwolf/blob/04b75ca9c40d10c345ae4f5157e033d7397f1b7a/src/templates/OPENWOLF.md
[ow-init]: https://github.com/cytostack/openwolf/blob/04b75ca9c40d10c345ae4f5157e033d7397f1b7a/src/cli/init.ts
[ow-scanner]: https://github.com/cytostack/openwolf/blob/04b75ca9c40d10c345ae4f5157e033d7397f1b7a/src/scanner/anatomy-scanner.ts
[ow-symbols]: https://github.com/cytostack/openwolf/blob/04b75ca9c40d10c345ae4f5157e033d7397f1b7a/src/anatomy/ts-symbol-extractor.ts
[ow-bugs]: https://github.com/cytostack/openwolf/blob/04b75ca9c40d10c345ae4f5157e033d7397f1b7a/src/buglog/bug-tracker.ts
[ow-config]: https://github.com/cytostack/openwolf/blob/04b75ca9c40d10c345ae4f5157e033d7397f1b7a/src/templates/config.json
[ow-governor]: https://github.com/cytostack/openwolf/blob/04b75ca9c40d10c345ae4f5157e033d7397f1b7a/src/hooks/bash-output-governor.ts
[ow-output]: https://github.com/cytostack/openwolf/blob/04b75ca9c40d10c345ae4f5157e033d7397f1b7a/src/hooks/post-bash.ts
[ow-read]: https://github.com/cytostack/openwolf/blob/04b75ca9c40d10c345ae4f5157e033d7397f1b7a/src/hooks/pre-read.ts
[ow-repository]: https://github.com/cytostack/openwolf/blob/04b75ca9c40d10c345ae4f5157e033d7397f1b7a/src/handoff/repository.ts
[ow-archive]: https://github.com/cytostack/openwolf/blob/04b75ca9c40d10c345ae4f5157e033d7397f1b7a/src/hooks/memory-archive.ts
[ow-journal]: https://github.com/cytostack/openwolf/blob/04b75ca9c40d10c345ae4f5157e033d7397f1b7a/src/hooks/event-journal.ts
[ow-shared]: https://github.com/cytostack/openwolf/blob/04b75ca9c40d10c345ae4f5157e033d7397f1b7a/src/hooks/shared.ts
[ow-usage]: https://github.com/cytostack/openwolf/blob/04b75ca9c40d10c345ae4f5157e033d7397f1b7a/src/tracker/usage.ts
[ow-estimates]: https://github.com/cytostack/openwolf/blob/04b75ca9c40d10c345ae4f5157e033d7397f1b7a/src/hooks/ledger-math.ts
[ow-updates]: https://github.com/cytostack/openwolf/blob/04b75ca9c40d10c345ae4f5157e033d7397f1b7a/src/hooks/runtime-updates.ts
[ow-release]: https://github.com/cytostack/openwolf/blob/04b75ca9c40d10c345ae4f5157e033d7397f1b7a/docs/release-2.5.2.md
