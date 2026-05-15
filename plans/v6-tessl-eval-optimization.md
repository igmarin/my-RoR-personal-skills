# V6 Tessl Score-Preserving Optimization Plan

## Summary

Goal: beat the current best main aggregate while selectively keeping only changes that improve individual skills.

Current verified state:

- Main baseline run: `019e21a7-c4ef-768d-846e-e2138334102b`
  - `usage-spec`: `92.0%`
  - baseline: `57.5%`
- Current PR/worktree run: `019e222c-33ad-73cb-8645-f3a46d01e545`
  - `usage-spec`: `87.8%`
  - baseline: `55.7%`
- No files are currently staged; all current edits are unstaged.

## Iterative Checklist

- [x] Create `plans/v6-tessl-eval-optimization.md` with this checklist.
- [x] Treat main run `019e21a7-c4ef-768d-846e-e2138334102b` as the release-quality baseline.
- [x] Treat current worktree changes as optional experimental material, not the baseline.
- [x] Build a score delta table for every changed skill:
  - Main `usage-spec`
  - Current PR/worktree `usage-spec`
  - Delta
  - Keep / revert / rework decision
- [x] Keep only positive-delta worktree changes unless a negative-delta change is clearly needed for a later fix.
- [x] Revert or rework severe regressions first:
  - `apply-stack-conventions`: `81 -> 43`
  - `triage-bug`: `94 -> 60`
  - `implement-calculator-pattern`: `96 -> 71`
  - `release-engine`: `100 -> 77`
  - `integrate-api-client`: `96 -> 80`
- [x] Preserve or port clear PR wins:
  - `apply-code-conventions`: `76 -> 100`
  - `create-prd`: `94 -> 100`
  - `build`: `72 -> 75`
  - `implement-authorization`: `60 -> 65`
  - Any other positive-delta skills after matrix review
- [ ] For each skill loop:
  - Read `tessl-evals/<skill>/scenario-0/criteria.json`.
  - Read both eval scoring reasons from main and current PR.
  - Compare current `SKILL.md` against main's better-scoring wording.
  - Keep critical inline examples where evals require concrete syntax.
  - Avoid "structural purity" edits that remove actionable instructions.
  - Run a focused eval for the changed skill or cluster.
- [ ] After every 3-5 skill decisions, run a full Tessl eval:
  - `tessl eval run . --variant without-context --variant with-context`
- [ ] Final score acceptance:
  - Full `usage-spec` average is greater than main's `92.0%`.
  - Target average is `97%+`.
  - No skill previously at `100%` on main regresses without an explicit reason.
- [x] Final static validation gates run:
  - `ruby scripts/validate-tessl-evals.rb` passes.
  - `./scripts/validate-plugins.sh` passes.
  - `git diff --check` passes.
  - `tessl skill lint tile.json` passes.

## Score Delta Matrix

| Skill | Main | Worktree | Delta | Decision |
| --- | ---: | ---: | ---: | --- |
| apply-code-conventions | 76 | 100 | +24 | Keep |
| apply-stack-conventions | 81 | 43 | -38 | Revert/rework |
| build | 72 | 75 | +3 | Keep |
| code-review | 82 | 73 | -9 | Revert/rework if changed |
| create-engine | 97 | 90 | -7 | Revert |
| create-engine-installer | 95 | 100 | +5 | No current edit |
| create-prd | 94 | 100 | +6 | No current edit |
| create-service-object | 93 | 95 | +2 | Keep |
| define-domain-language | 100 | 100 | 0 | No current edit |
| document-engine | 100 | 100 | 0 | No current edit |
| extract-engine | 97 | 98 | +1 | No current edit |
| generate-api-collection | 100 | 98 | -2 | Revert |
| generate-tasks | 98 | 92 | -6 | Revert/rework if changed |
| implement-authorization | 60 | 65 | +5 | No current edit |
| implement-background-job | 96 | 100 | +4 | Keep |
| implement-calculator-pattern | 96 | 71 | -25 | Revert |
| implement-graphql | 98 | 93 | -5 | Revert |
| implement-hotwire | 100 | 90 | -10 | Revert/rework if changed |
| integrate-api-client | 96 | 80 | -16 | Revert/rework if changed |
| load-context | 94 | 94 | 0 | Revert unless needed |
| model-domain | 83 | 72 | -11 | Revert |
| optimize-performance | 100 | 100 | 0 | No current edit |
| plan-tests | 100 | 91 | -9 | Revert/rework if changed |
| plan-tickets | 86 | 78 | -8 | Revert/rework if changed |
| refactor-code | 90 | 83 | -7 | Revert/rework if changed |
| release-engine | 100 | 77 | -23 | Revert |
| respond-to-review | 82 | 83 | +1 | Keep |
| review-architecture | 80 | 83 | +3 | Keep |
| review-domain-boundaries | 90 | 90 | 0 | No current edit |
| review-engine | 97 | 88 | -9 | Revert/rework if changed |
| review-migration | 100 | 95 | -5 | Revert |
| security-check | 89 | 86 | -3 | Revert/rework if changed |
| seed-database | 92 | 91 | -1 | Revert/rework if changed |
| setup-environment | 88 | 100 | +12 | Keep |
| skill-router | 100 | 81 | -19 | Revert |
| test-engine | 100 | 100 | 0 | No current edit |
| test-service | 100 | 100 | 0 | Revert unless needed |
| triage-bug | 94 | 60 | -34 | Revert |
| upgrade-engine | 90 | 90 | 0 | No current edit |
| version-api | 100 | 100 | 0 | Revert unless needed |
| write-tests | 83 | 92 | +9 | No current edit |
| write-yard-docs | 93 | 90 | -3 | Revert |

## Implementation Rules

- Do not rely on staged changes; there are currently none.
- Do not optimize from the dirty worktree wholesale.
- Prefer "main plus proven PR wins" over "PR plus regression fixes."
- Ignore `personal-evals/` for this plan; this is Tessl-only.
- Root `evals/` remains generated and untracked.
- Treat `plans/lessons-learned-from-tessl.md` as a living lessons-learned article. After each eval iteration, update it with any durable learning about skill design, Tessl behavior, scoring tradeoffs, batching, regression handling, or prompt/output patterns.

## Current Retained Worktree Changes

Initial retained mix was tested in run `019e2289-b68c-745b-a60d-45acf8464378`:

- baseline average: `55.7%`
- with-context average: `88.5%`
- result: failed to beat main's `92.0%`

Because the retained mix did not beat main, the experimental skill and workflow edits were restored to `origin/main`.

Currently retained repo changes:

- `.tesslignore`
- `tile.json` aligned to `origin/main` version `5.1.6`

The individual-skill wins should only be reintroduced one at a time with focused evals.

## Active Single-Skill Loop

### apply-code-conventions

- Status: patched and awaiting Tessl with-context verification.
- Change: strengthened the output contract around the five current Tessl criteria: detect/run/defer linter flow, per-path areas, tests gate, and `test-prof` / `let_it_be` assumptions.
- Static checks after patch:
  - `ruby scripts/validate-tessl-evals.rb`: passed
  - `./scripts/validate-plugins.sh`: passed
  - `git diff --check`: passed
- Focused scenario attempt:
  - `tessl eval run tessl-evals/apply-code-conventions --variant without-context --variant with-context --label apply-code-conventions-targeted`
  - Result: rejected by Tessl because scenario-only `usage-spec` / with-context runs require a tile context fixture.
- Reliable verification run:
  - `tessl eval run . --variant with-context --label apply-code-conventions-single-change`
  - Run ID: `019e2292-3e96-7058-b8ca-328190665383`
  - Result: completed, `usage-spec` average `90.4%`, `apply-code-conventions` `100.0`.
  - Decision: keep the patch as a targeted skill win, but continue low-tail optimization because aggregate still trails main's `92.0%`.

### triage-bug

- Status: reverted after failed Tessl verification.
- Change: strengthened reproduction-first output for the current low-tail scenario, including the exact request spec command and narrow `Orders::CreateOrder` out-of-stock fix path.
- Static checks after patch:
  - `ruby scripts/validate-tessl-evals.rb`: passed
  - `./scripts/validate-plugins.sh`: passed
  - `git diff --check`: passed
- Verification run:
  - `tessl eval run . --variant with-context --label apply-code-plus-triage-bug`
  - Run ID: `019e2298-1fa2-7069-9b74-9f8d8778589c`
  - Result: completed, `usage-spec` average `88.9%`, `triage-bug` `34.0`.
  - Decision: revert `triage-bug` patch because it regressed both aggregate score and the target skill.

### setup-environment

- Status: patched and verified.
- Change: strengthened the Output Style contract around the generic setup-runbook scope, copy-paste artifact, constraints, assumptions, and verification gates.
- Static checks after patch:
  - `ruby scripts/validate-tessl-evals.rb`: passed
  - `./scripts/validate-plugins.sh`: passed
  - `git diff --check`: passed
- Verification run:
  - `tessl eval run . --variant with-context --label apply-code-plus-setup-environment`
  - Run ID: `019e22a0-b9dd-71ca-987c-cda01e51a690`
  - Result: completed, `usage-spec` average `89.9%`, `setup-environment` `100.0`.
  - Decision: keep the patch as a targeted skill win, but continue low-tail optimization because aggregate still trails main's `92.0%`.

### build

- Status: patched and verified.
- Change: strengthened the Output Style contract around scope check, read phase, tests-first evidence, focused pass rerun, full-suite/manual verification, SearchService regression checks, and residual risk.
- Static checks after patch:
  - `ruby scripts/validate-tessl-evals.rb`: passed
  - `./scripts/validate-plugins.sh`: passed
  - `git diff --check`: passed
- Verification run:
  - `tessl eval run . --variant with-context --label apply-code-setup-build`
  - Run ID: `019e22a8-7ec4-74cd-bd04-39e68602bbd6`
  - Result: completed, `usage-spec` average `89.2%`, `build` `88.0`.
  - Decision: keep the patch as a targeted skill win, but aggregate still trails main's `92.0%`.

## Next Batch of 6

Use one batch eval for the next six targeted edits, then bisect into groups of three only if aggregate regresses:

- `respond-to-review` — patched Output Style to require verified feedback table, code evidence, reasoned pushback, per-item tests, and re-review decision.
- `review-architecture` — patched Output Style to require scope, boundary-first lens, code-level evidence for every High finding, and downgrade/remove behavior for unverified findings.
- `create-service-object` — patched Output Style to require spec-first proof, exact response shapes, and class-only stateless pattern.
- `implement-background-job` — patched Output Style to require backend decision, spec-first proof, thin `perform`, retry/discard config, and double-run idempotency verification.
- `integrate-api-client` — patched Output Style to require tests-first proof for every layer, hash factories, FactoryBot `skip_create` / `initialize_with`, and domain entity specs.
- `plan-tickets` — patched Output Style to require create-in-tracker boundary, tracker verification, integration/credentials discipline, create metadata, default status behavior, and creation report.

Static checks after batch:

- `ruby scripts/validate-tessl-evals.rb`: passed
- `./scripts/validate-plugins.sh`: passed
- `git diff --check`: passed

Batch verification:

- Run ID: `019e22af-bf68-7197-a02f-0d627a234104`
- Result: completed, `usage-spec` average `91.0%`.
- Improved over previous retained run `89.2%`, but still below main baseline `92.0%`.
- Kept:
  - `respond-to-review` scored `100.0`.
  - `review-architecture` scored `92.0`.
  - `implement-background-job` scored `100.0`.
- Reverted to `origin/main`:
  - `create-service-object` scored `72.0`, below main baseline.
  - `integrate-api-client` scored `90.0`, below main baseline.
  - `plan-tickets` scored `65.0`, below main baseline.
- Decision: keep the successful half of the batch and rework the reverted half in a later, smaller batch.
- Follow-up verification for the kept-half state:
  - `tessl eval run . --variant with-context --label kept-half-after-batch-six`
  - Run ID: `019e22b9-bc3f-77be-9bf8-f91717b2beb9`
  - Result: completed, `usage-spec` average `90.0%`.
  - Observed recovery after reverting the weak half:
    - `create-service-object` recovered to `95.0`.
    - `integrate-api-client` recovered to `96.0`.
    - `plan-tickets` recovered only to `72.0`.
  - Retained wins:
    - `apply-code-conventions` `100.0`.
    - `respond-to-review` `100.0`.
    - `implement-background-job` `100.0`.
  - Mixed retained results:
    - `review-architecture` `84.0`.
    - `setup-environment` `96.0`.
    - `build` `75.0`.
  - Decision: do not treat the kept-half run as an aggregate win. Next iteration should target the persistent low tail rather than adding more broad Output Style patches.

## Mandatory Lessons-Learned Checkpoint

- File: `plans/lessons-learned-from-tessl.md`
- Purpose: reusable essay/article material for Tessl feedback and a future Medium post.
- Requirement: after every Tessl eval that informs a keep/revert/patch decision, update this document before closing the iteration.
- Update cadence: after every completed eval iteration, partial eval used as evidence, or batch decision.
- Workflow:
  1. Read the current article before writing so new notes continue the existing narrative.
  2. Record what the eval changed in the optimization strategy, not only the score.
  3. Include concrete run IDs and scores when they affected the decision.
  4. Explain why the next patch is broad, tiny, or intentionally skipped.
- What to capture:
  - What improved scores and why.
  - What regressed scores and why it was reverted or bisected.
  - How batch size affected attribution and aggregate signal.
  - Which skill-writing patterns generalized beyond one scenario.
  - Which eval or rubric behaviors surprised us.

## Tessl Folder-Context Caveat

- Treat `SKILL.md` as the primary scoring contract, but do not assume it is the only input that affects behavior.
- Current observed behavior: individual skill scoring appears to weight `SKILL.md`, while Tessl still packages or exposes the full skill folder as context during eval generation/execution.
- Optimization implication: a `SKILL.md`-only patch can create a large score movement because it changes the primary contract, but companion files can still pull the model toward older examples or weaker output shapes.
- Rule: after a `SKILL.md` change that depends on examples, commands, proof templates, or output formats, inspect the directly linked support files for contradiction or drift. Update support files only when needed to preserve the new contract.
- Do not rewrite support folders broadly just because a skill score is low; use scorer reasons to identify whether the miss came from entrypoint wording, companion-resource drift, or eval noise.

Validation status:

- `ruby scripts/validate-tessl-evals.rb`: passed
- `./scripts/validate-plugins.sh`: passed
- `git diff --check`: passed
- `tessl skill lint tile.json`: passed

## Low-Tail Batch of 6

Use the kept-half run `019e22b9-bc3f-77be-9bf8-f91717b2beb9` as the input signal for this iteration. The lowest retained scores were inspected by scoring reason before editing.

- [x] Review low-tail candidates from the kept-half run:
  - `triage-bug` `51.0`
  - `apply-stack-conventions` `67.0`
  - `model-domain` `70.0`
  - `plan-tickets` `72.0`
  - `build` `75.0`
  - `write-tests` `75.0`
- [x] Skip `triage-bug` for this batch because the previous targeted patch regressed the skill to `34.0`; this needs deeper scenario/skill redesign instead of another output-only edit.
- [x] Patch `apply-stack-conventions` to require RED output, layer-isolation proof, and focused GREEN rerun evidence.
- [x] Patch `model-domain` to require invariant ownership clarity and a test handoff instead of implementation code.
- [x] Patch `write-tests` to require TDD failure proof, verification proof, minimal factories, aggregate failures, and timestamp discipline.
- [x] Patch `build` to make the regression checklist a required task-specific artifact, with an exact SearchService checklist for search/filter/query work.
- [x] Patch `plan-tickets` to preserve draft-only behavior while adding create-in-tracker readiness evidence.
- [x] Run static validation after the low-tail batch:
  - `ruby scripts/validate-tessl-evals.rb`: passed
  - `./scripts/validate-plugins.sh`: passed
  - `git diff --check`: passed
  - `tessl skill lint tile.json`: valid tile; expected orphan warning for local article `plans/lessons-learned-from-tessl.md`
- [x] Run a full with-context Tessl eval for the low-tail batch:
  - Command: `tessl eval run . --variant with-context --label low-tail-evidence-led-batch`
  - Run ID: `019e22d8-b5b8-717b-8d5a-40f87bd5a9fd`
  - Final status: `completed`, `42/42` scenarios completed, final average `89.6%`
- [x] Keep, revert, or bisect based on the available low-tail result:
  - Keep `plan-tickets`: `72.0 -> 92.0`
  - Keep `write-tests`: `75.0 -> 91.0`
  - Keep `model-domain`: `70.0 -> 80.0`
  - Keep `apply-stack-conventions`: `67.0 -> 73.0`
  - Revert the latest `build` checklist tweak: `75.0 -> 70.0`
  - Keep `triage-bug` skipped; run scored `52.0`, confirming it needs deeper redesign rather than another quick output-style edit.
- [x] Re-check final run status once Tessl completes the remaining scenarios.

Final low-tail run notes:

- The run did not beat main baseline `92.0%` or retained state `90.0%`.
- The useful targeted wins were still real:
  - `plan-tickets` recovered strongly to `92.0`.
  - `write-tests` recovered strongly to `91.0`.
  - `model-domain` improved to `80.0`.
  - `apply-stack-conventions` improved to `73.0`.
- The aggregate was dragged down by persistent or unrelated lows:
  - `integrate-api-client` `64.0`
  - `triage-bug` `52.0`
  - `build` `70.0` in the eval run, before the local checklist tweak revert
  - `implement-calculator-pattern` `74.0`
  - `implement-authorization` `75.0`
- Decision: keep the confirmed low-tail wins, keep the local `build` revert, and make the next iteration focus on one of the persistent aggregate anchors rather than broad output-style polishing.

## Aggregate Anchor Diagnostic Pass

- [x] Inspect scorer reasoning for aggregate anchors from run `019e22d8-b5b8-717b-8d5a-40f87bd5a9fd`:
  - `integrate-api-client` `64.0`
  - `triage-bug` `52.0`
  - `implement-calculator-pattern` `74.0`
  - `implement-authorization` `75.0`
- [x] Defer `triage-bug`; scorer confirms it is still solving the wrong scenario and needs deeper redesign.
- [x] Defer `integrate-api-client`; scorer shows a broader multi-layer TDD/spec gap, so it should get its own focused pass rather than being mixed into a small patch.
- [x] Patch `implement-authorization` to require explicit browser or Rails console unauthorized verification, not only automated specs.
- [x] Patch `implement-calculator-pattern` to require per-component RED proof, GREEN checkpoints, and variant context coverage across Factory, NullService, and concrete services.
- [x] Run static validation after the anchor patch:
  - `ruby scripts/validate-tessl-evals.rb`: passed
  - `./scripts/validate-plugins.sh`: passed
  - `git diff --check`: passed
  - `tessl skill lint tile.json`: valid tile; expected orphan warning for local article `plans/lessons-learned-from-tessl.md`
- [ ] Run a full with-context Tessl eval for the anchor patch:
  - Command: `tessl eval run . --variant with-context --label anchor-auth-calculator-output-proof`
  - Run ID: `019e22e5-22d3-72fd-b999-db73e1f51892`
  - Status: superseded by the Sonnet 3-run confidence protocol; do not use this single-run result for keep/revert decisions.

## Evaluation Confidence Protocol

Single Tessl runs are useful for fast iteration, but release decisions should not depend on one probabilistic sample.

- [x] Verify CLI support for confidence controls:
  - `--context-ref`
  - repeatable `--agent`
  - `--runs`
  - scenarios-directory mode requiring `--workspace` and `--agent`
- [ ] Use single-run full tile evals for quick patch feedback:
  - `tessl eval run . --variant with-context --label <iteration-label>`
- [x] Use Sonnet 3x for release-confidence comparisons:
  - `tessl eval run . --variant with-context --agent=claude:claude-sonnet-4-6 --runs 3 --label release-confidence-sonnet-3x`
  - Current run: `019e22eb-6db9-7408-bba4-c69f61927e06`
  - Final status: `completed`
  - Overall mean: `91.1%`
  - Interpretation: better than the previous single-run `89.6%`, but still below main baseline `92.0%`.
  - Confirmed anchor-patch movement:
    - `implement-authorization`: `75.0 -> 85.0`
    - `implement-calculator-pattern`: `74.0 -> 82.7`
  - Remaining aggregate anchors by 3-run mean:
    - `triage-bug`: `49.0`
    - `code-review`: `73.7`
    - `apply-stack-conventions`: `78.7`
    - `release-engine`: `81.0`
    - `integrate-api-client`: `83.7`
    - `security-check`: `88.0`
    - `upgrade-engine`: `88.0`
- [x] Patch stable anchors from scorer reasoning in run `019e22eb-6db9-7408-bba4-c69f61927e06`:
  - `integrate-api-client`: added layer-by-layer tests-first proof, GREEN checkpoints, and entity method coverage for `.fetcher`, `.find`, and `.search`.
  - `apply-stack-conventions`: made tests-first proof appear before implementation code and required visible RED/GREEN command output.
  - `code-review`: added the explicit review principle, generate-tasks handoff requirement, and re-review trigger.
  - `triage-bug`: deferred again because the stable failure is wrong scenario selection, not a missing output line.
  - `release-engine`: deferred because the remaining gaps are narrower release-asset/release-notes details and should not be mixed into this proof-layout batch.
- [x] Run static validation after the stable-anchor patch pass:
  - `ruby scripts/validate-tessl-evals.rb`: passed
  - `./scripts/validate-plugins.sh`: passed
  - `git diff --check`: passed
  - `tessl skill lint tile.json`: valid tile; expected orphan warning for local article `plans/lessons-learned-from-tessl.md`
- [x] Run a Sonnet 3x confidence eval for the stable-anchor patch pass:
  - Command: `tessl eval run . --variant with-context --agent=claude:claude-sonnet-4-6 --runs 3 --label stable-anchor-proof-layout-3x`
  - Run ID: `019e22fa-90e6-717e-8c43-caee18cfe2bc`
  - Final status: `completed`
  - Overall mean: `93.0%`
  - Interpretation: first confidence run in this iteration to beat main baseline `92.0%` and previous Sonnet 3x `91.1%`.
  - Confirmed stable-anchor movement:
    - `code-review`: `73.7 -> 97.0`
    - `integrate-api-client`: `83.7 -> 96.7`
    - `implement-authorization`: `85.0 -> 93.3`
    - `implement-calculator-pattern`: `82.7 -> 89.0`
    - `apply-stack-conventions`: `78.7 -> 79.7`
  - Remaining low-tail by 3-run mean:
    - `triage-bug`: `59.3`
    - `build`: `77.7`
    - `apply-stack-conventions`: `79.7`
    - `release-engine`: `82.7`
    - `plan-tickets`: `84.3`
    - `plan-tests`: `86.3`
  - Decision: keep the stable-anchor patch pass; next work should target the remaining low-tail without disturbing the now-proven anchor wins.
- [x] Compare release-confidence runs by:
  - mean score across runs
  - per-skill minimum score
  - variance for aggregate anchors
  - whether improvements survive across all three samples

## Post-93 Low-Tail Pass

Use run `019e22fa-90e6-717e-8c43-caee18cfe2bc` as the protected state. Do not touch the proven anchor wins unless a later eval shows a direct regression.

- [x] Inspect scorer reasoning for low-tail candidates:
  - `release-engine`: `82.7`
  - `build`: `77.7`
  - `plan-tests`: `86.3`
  - `plan-tickets`: `84.3`
- [x] Defer `build`; low score came from SearchService-specific rubric items on a non-search `User#admin?` task, so another build patch risks overfitting.
- [x] Patch `release-engine` to make conditional asset loading visible and require GitHub release notes / public release copy.
- [x] Patch `plan-tests` to enforce exactly one opening failing example and move extra cases to follow-up coverage.
- [x] Patch `plan-tickets` to explicitly require tracker create-metadata or equivalent field discovery, explicit approval state, and one-issue validation when uncertain.
- [x] Run static validation after the low-tail patch:
  - `ruby scripts/validate-tessl-evals.rb`: passed
  - `./scripts/validate-plugins.sh`: passed
  - `git diff --check`: passed
  - `tessl skill lint tile.json`: valid tile; expected orphan warning for local article `plans/lessons-learned-from-tessl.md`
- [x] Run a Sonnet 3x confidence eval for the low-tail patch:
  - Command: `tessl eval run . --variant with-context --agent=claude:claude-sonnet-4-6 --runs 3 --label post-93-low-tail-release-plan-3x`
  - Run ID: `019e2353-e579-716e-bf0d-2a499addfe11`
  - Final status: `completed`
  - Overall mean: `92.6%`
  - Interpretation: still above main baseline `92.0%`, but below protected best Sonnet 3x state `93.0%`.
  - Confirmed target movement:
    - `release-engine`: `82.7 -> 96.7`
    - `plan-tests`: `86.3 -> 100.0`
    - `plan-tickets`: `84.3 -> 91.7`
    - `build`: `77.7 -> 84.7` without editing `build`
  - Unrelated downward movement that dragged the aggregate:
    - `implement-calculator-pattern`: `89.0 -> 74.7`
    - `implement-authorization`: `93.3 -> 85.0`
    - `model-domain`: `96.7 -> 83.7`
    - `triage-bug`: `59.3 -> 53.0`
  - Decision: keep the low-tail patch as a targeted improvement, but do not treat this run as the new aggregate best. The protected best remains run `019e22fa-90e6-717e-8c43-caee18cfe2bc` at `93.0%`.
- [x] Audit companion resources for the patched skills:
  - `release-engine`: updated `assets/release_checklist.md`, `assets/release_notes_template.md`, `assets/examples.md`, and `EXAMPLES.md` so optional assets reinforce visible asset usage, GitHub release notes, verification status, dry-run, and gem contents checks.
  - `plan-tickets`: updated `EXAMPLES.md` and `assets/ticket-samples/sample_issue.md` so examples include classification and create-in-tracker readiness.
  - `plan-tests`: no companion resources exist; `SKILL.md` is the only source to update.
- [x] Run static validation after the companion-resource pass:
  - `ruby scripts/validate-tessl-evals.rb`: passed
  - `./scripts/validate-plugins.sh`: passed
  - `git diff --check`: passed
  - `tessl skill lint tile.json`: valid tile; expected orphan warning for local article `plans/lessons-learned-from-tessl.md`
- [x] Run a Sonnet 3x confidence eval for companion-resource alignment:
  - Command: `tessl eval run . --variant with-context --agent=claude:claude-sonnet-4-6 --runs 3 --label companion-resource-alignment-3x`
  - Run ID: `019e2379-e774-7675-b361-c29a598dbe0f`
  - Final status: `completed`
  - Overall mean: `92.5%`
  - Interpretation: still above main baseline `92.0%`, but below protected best Sonnet 3x state `93.0%` and slightly below the previous low-tail run `92.6%`.
  - Confirmed resource-alignment movement:
    - `release-engine`: `96.7 -> 99.3`
    - `plan-tests`: `100.0 -> 100.0`
    - `plan-tickets`: `91.7 -> 86.7`
  - Notable unrelated movement:
    - `apply-stack-conventions`: `98.0 -> 95.3`
    - `build`: `84.7 -> 76.3`
    - `code-review`: `93.0 -> 90.0`
    - `implement-authorization`: `85.0 -> 76.7`
    - `integrate-api-client`: `97.7 -> 90.7`
    - `model-domain`: `83.7 -> 94.3`
    - `respond-to-review`: `92.3 -> 100.0`
  - Decision: keep the companion-resource alignment. It improved the directly affected `release-engine` asset behavior and kept `plan-tests` perfect; `plan-tickets` reasoning still shows the create-readiness behavior, so the score drop is not enough evidence for reverting the support examples.

## Six-Skill Progressive Disclosure Experiment

Hypothesis: correlated RED/GREEN proof failures can be stabilized by aligning `SKILL.md` entrypoints with conditional support files, without bloating always-loaded context.

- [x] Select the tests-first proof cluster:
  - `build`
  - `plan-tests`
  - `write-tests`
  - `test-service`
  - `implement-calculator-pattern`
  - `implement-authorization`
- [x] Keep critical scoring behavior in `SKILL.md`; add support files only when they are conditionally loaded.
- [x] Patch `build`:
  - Added `assets/tdd_proof_template.md`.
  - Linked it from `SKILL.md`.
  - Updated `EXAMPLES.md` to show RED/GREEN proof shape.
- [x] Patch `plan-tests`:
  - Added `assets/first_slice_template.md`.
  - Linked it from `SKILL.md`.
- [x] Patch `write-tests`:
  - Added `assets/tdd_proof_checklist.md`.
  - Linked it from `SKILL.md`.
  - Updated `assets/spec_templates.md` to pair templates with TDD proof.
- [x] Patch `test-service`:
  - Expanded `SKILL.md` Output Style to require public contract, RED proof, GREEN checkpoint, collaborator strategy, and failure coverage.
  - Updated `assets/testing_checklist.md` and `assets/spec_examples.md`.
- [x] Patch `implement-calculator-pattern`:
  - Corrected `IMPLEMENTATION.md` so `BaseService#compute_result` raises the required `NotImplementedError`.
  - Updated `TESTING.md` with component RED/GREEN proof and nil-plan coverage.
  - Updated `assets/examples.md` with required verification shape.
- [x] Patch `implement-authorization`:
  - Updated `SKILL.md`, `EXAMPLES.md`, and `references/workflow.md` so denied manual checks explicitly call `Pundit.authorize` or `authorize!` and show the expected exception.
- [x] Run static validation after the six-skill expansion:
  - `ruby scripts/validate-tessl-evals.rb`: passed
  - `./scripts/validate-plugins.sh`: passed
  - `git diff --check`: passed
  - `tessl skill lint tile.json`: valid tile; expected orphan warning for local article `plans/lessons-learned-from-tessl.md`
- [x] Run Sonnet 3x confidence eval for the six-skill expansion:
  - Command: `tessl eval run . --variant with-context --agent=claude:claude-sonnet-4-6 --runs 3 --label six-skill-proof-support-3x`
  - Run ID: `019e2401-7e2a-7429-9a25-7e47173af474`
  - Final status: `completed`
  - Overall mean: `92.7%`
  - Interpretation: improved over the companion-resource run `92.5%`, still below the protected best Sonnet 3x state `93.0%`.
  - Target movement from companion-resource run:
    - `build`: `76.3 -> 69.3`
    - `plan-tests`: `100.0 -> 100.0`
    - `write-tests`: `89.3 -> 84.7`
    - `test-service`: `100.0 -> 100.0`
    - `implement-calculator-pattern`: `78.0 -> 93.0`
    - `implement-authorization`: `76.7 -> 96.7`
  - Decision: keep the six-skill support expansion as a partial win, especially `implement-authorization`, `implement-calculator-pattern`, `plan-tests`, and `test-service`.
  - Follow-up:
    - Do not patch `build` further until the SearchService-specific rubric mismatch is addressed.
    - Rework `write-tests` examples/support so outputs show the expected RED failure message and use `aggregate_failures` for related assertions.
- [x] Apply `write-tests` follow-up:
  - Updated `EXAMPLES.md` with a TDD proof header including exact expected RED failure examples.
  - Updated examples to split multi-behavior request specs and use `aggregate_failures` for related assertions.
  - Updated `assets/spec_templates.md` with a concrete expected RED proof example and `aggregate_failures` in templates.
  - Updated `assets/tdd_proof_checklist.md` to require actual expected failure class/message and `aggregate_failures`.
- [x] Do not add another skill cluster yet; first re-measure this targeted correction to keep attribution clear.
- [x] Run static validation after the `write-tests` follow-up:
  - `ruby scripts/validate-tessl-evals.rb`: passed
  - `./scripts/validate-plugins.sh`: passed
  - `git diff --check`: passed
  - `tessl skill lint tile.json`: valid tile; expected orphan warning for local article `plans/lessons-learned-from-tessl.md`
- [x] Run Sonnet 3x confidence eval for the `write-tests` follow-up:
  - Command: `tessl eval run . --variant with-context --agent=claude:claude-sonnet-4-6 --runs 3 --label write-tests-proof-examples-3x`
  - Run ID: `019e2413-132f-77da-b0e5-edb98eecbc90`
  - Final status: `completed`
  - Overall mean: `93.2%`
  - Interpretation: new best Sonnet 3x aggregate, above protected best run `019e22fa-90e6-717e-8c43-caee18cfe2bc` at `93.0%`.
  - Target movement from the previous six-skill expansion:
    - `write-tests`: `84.7 -> 95.3`
    - `implement-calculator-pattern`: `93.0 -> 93.7`
    - `implement-authorization`: `96.7 -> 96.7`
    - `plan-tests`: `100.0 -> 99.3`
    - `test-service`: `100.0 -> 100.0`
    - `build`: `69.3 -> 81.7`
  - Decision: keep the `write-tests` follow-up. The proof-header and `aggregate_failures` support changes produced a direct target win and a new aggregate best.

## Low-Tail Rubric Alignment Batch

Hypothesis: after the new best run, the next useful six-skill batch should target the observed low tail rather than the previously proposed review cluster.

- [x] Select the next six skills from run `019e2413-132f-77da-b0e5-edb98eecbc90`:
  - `triage-bug`: `45.0`
  - `generate-tasks`: `79.3`
  - `build`: `81.7`
  - `skill-router`: `83.3`
  - `upgrade-engine`: `86.7`
  - `implement-graphql`: `87.3`
- [x] Patch `triage-bug`:
  - Replaced the generic pricing example with the canonical `POST /orders` out-of-stock request-boundary example.
  - Added exact command and `Orders::CreateOrder` smallest-fix guidance.
- [x] Patch `generate-tasks`:
  - Required exact `spec/...` and `app/...` paths inside every TDD quadruplet sub-task.
  - Added visible guidance-used reporting for `HEURISTICS.md` and `TASK_TEMPLATES.md`.
- [x] Patch `build`:
  - Strengthened the visible Read phase.
  - Required a SearchService regression checklist section, marked not applicable for non-search tasks.
- [x] Patch `skill-router`:
  - Added multi-concern PR review decomposition and ordered review chains.
  - Expanded examples for multi-concern engine PRs.
- [x] Patch `upgrade-engine`:
  - Added optional integration matrix requirements for jobs, mailers, assets, routes, generators, and dummy app mounts.
- [x] Patch `implement-graphql`:
  - Added explicit dataloader priming guidance for collection resolvers.
  - Added hard-gate checklist visibility for resolver structure, type conventions, and priming.
- [x] Run static validation after the low-tail rubric alignment batch:
  - `ruby scripts/validate-tessl-evals.rb`: passed
  - `./scripts/validate-plugins.sh`: passed
  - `git diff --check`: passed
  - `tessl skill lint tile.json`: valid tile; expected orphan warning for local article `plans/lessons-learned-from-tessl.md`
- [x] Run Sonnet 3x confidence eval for the low-tail rubric alignment batch:
  - Command: `tessl eval run . --variant with-context --agent=claude:claude-sonnet-4-6 --runs 3 --label low-tail-rubric-alignment-3x`
  - Run ID: `019e2423-6260-723c-b243-c4cdc8567b6e`
  - Final status: `completed`
  - Overall mean: `94.9%`
  - Interpretation: excellent historical 42-skill result, but not the current release surface because it was uploaded before CodeRabbit cleanup and before retiring the temporary `build` skill.
  - Target movement from the previous new-best run:
    - `triage-bug`: `45.0 -> 92.3`
    - `generate-tasks`: `79.3 -> 95.0`
    - `build`: `81.7 -> 90.3` *(historical only; `build` is now retired)*
    - `skill-router`: `83.3 -> 91.0`
    - `upgrade-engine`: `86.7 -> 100.0`
    - `implement-graphql`: `87.3 -> 98.7`
  - Decision: keep the non-`build` skill improvements and use the next eval as the first true 41-skill measurement.
  - Follow-up before the 41-skill measurement:
    - `triage-bug`: add exact `{ success: false, error: "Out of stock" }` return contract.
    - `generate-tasks`: make endpoint/controller task ordering request-spec-first.
    - `skill-router`: require the priority rule to be stated explicitly.

## Retire Temporary Root Build Skill

Decision: remove the root-level `build` skill from the published tile. It was originally a temporary bridge while skills were moved into the category folder structure, and later evals showed it had become a low-tail scenario with rubric mismatch risk rather than a distinct Rails skill.

- [x] Remove `build` from the Tessl manifest:
  - Removed `build` from `tile.json`.
  - Updated tile summary from 42 to 41 public skills.
- [x] Remove the skill files:
  - Deleted `build/SKILL.md`.
  - Deleted `build/EXAMPLES.md`.
  - Deleted `build/assets/tdd_proof_template.md`.
- [x] Remove generated eval scenario:
  - Deleted `evals/build/`.
- [x] Remove active references:
  - Updated `AGENTS.md`, `README.md`, `docs/index.md`, `docs/README.md`, and `docs/reference/skill-catalog.md`.
  - Updated `mcp_server/README.md` topology wording.
  - Updated `plans/lessons-learned-from-tessl.md` to show 41 publishable skills and explain that historical `build` score notes refer to the earlier 42-skill surface.
- [x] Remove discovery/tooling special cases:
  - Updated MCP resource discovery and catalog category logic.
  - Updated MCP Ruby tests and fixtures.
  - Updated Cloudflare MCP skill-content tests and user-facing examples.
  - Updated validation scripts to scan `skills/` and `workflows/` instead of root `build/`.
- [x] Run static validation after retiring `build`:
  - `ruby scripts/validate-tessl-evals.rb`: passed for 41 publishable skills
  - `./scripts/validate-plugins.sh`: passed
  - `git diff --check`: passed
  - `tessl skill lint tile.json`: valid tile; expected orphan warning for local article `plans/lessons-learned-from-tessl.md`
  - `bundle exec ruby -Itest test/resource_discovery_test.rb` from `mcp_server/`: passed
  - `npm test` from `cloudflare_mcp/`: passed
- [x] Run the first Sonnet 3x confidence eval for the 41-skill surface:
  - Command: `tessl eval run . --variant with-context --agent=claude:claude-sonnet-4-6 --runs 3 --label post-build-retirement-41-skills-3x`
  - Run ID: `019e2433-e7fa-7179-9303-96f47dae26ad`
  - Final status: `completed`
  - Overall mean: `96.4%`
  - Interpretation: first true 41-skill release-surface measurement after retiring the temporary root `build` skill. This is the new protected best and the cleanest release-candidate signal so far.
  - Confirmed target outcomes:
    - `triage-bug`: `100.0`
    - `generate-tasks`: `98.0`
    - `skill-router`: `90.3`
    - `upgrade-engine`: `100.0`
    - `implement-graphql`: `98.7`
  - Remaining low-tail to watch, without broad edits:
    - `apply-stack-conventions`: `85.7`
    - `review-domain-boundaries`: `86.7`
    - `refactor-code`: `89.0`
    - `security-check`: `89.7`
    - `skill-router`: `90.3`
    - `write-tests`: `91.7`
  - Decision: stop broad batch editing for this iteration. Preserve the `96.4%` state as the candidate baseline; any further change should be tiny, evidence-led, and followed by another Sonnet 3x run.

## Post-Baseline Low-Tail Optimization

Objective: continue toward `98%+` without broad churn. The active 41-skill protected baseline is still run `019e2433-e7fa-7179-9303-96f47dae26ad` at `96.4%`; any new patch must beat that and update `plans/lessons-learned-from-tessl.md`.

- [x] Review potential moderation wording before further eval work:
  - Replaced `whitelist`/`blacklist`-style wording with `allowlist` where it appeared in active skill/support docs.
  - Replaced the expanded "Keep It Simple, Stupid" phrase with "Keep It Simple" in public docs.
  - Targeted scan for offensive/profane/violent terms across `skills`, `docs`, `README.md`, and `tile.json`: no remaining hits.
- [x] Patch the first low-tail cluster from the `96.4%` baseline:
  - `apply-stack-conventions`: require visible RED proof before implementation and GREEN rerun with the same spec command.
  - `review-domain-boundaries`: add Fleet/Billing ownership-direction evidence.
  - `refactor-code`: require actual observed verification output, not expected output.
  - `security-check`: require source evidence and no fabricated file/line findings.
  - `skill-router`: require the next skill as the first substantive line.
  - `write-tests`, `write-yard-docs`, `review-migration`, `create-service-object`, `model-domain`, `generate-tasks`, `seed-database`: small output-contract fixes based on scorer reasons.
- [x] Run Sonnet 3x eval after the first low-tail patch:
  - Command: `tessl eval run . --variant with-context --agent=claude:claude-sonnet-4-6 --runs 3 --label v6-low-tail-100-attempt-3x`
  - Run ID: `019e26d6-1d50-76ae-8067-ba41994938a5`
  - Result while scored: `41/41`, average `97.2%`
  - Decision: keep as a real improvement over `96.4%`, but continue because it missed the `98%` target.
- [x] Run second low-tail attempt and reject broad regressions:
  - Run ID: `019e26db-cbeb-737c-970c-bc0b4f4d4cd1`
  - Result while scored: `41/41`, average `96.49%`
  - Decision: keep direct target wins, but revert the second-pass changes that caused visible regressions in `refactor-code` and `write-tests`.
- [x] Run kept-wins verification:
  - Run ID: `019e26e1-21af-7598-8a67-33ec611558c8`
  - Result while scored: `41/41`, average `97.22%`
  - Decision: new best at that point, but still short of `98%`.
- [x] Patch evidence-contract lows from the `97.22%` run:
  - `review-architecture`: do not fabricate file paths or high findings without source files.
  - `load-context`: include discovery commands used.
  - `implement-hotwire`: require `rails test:system` and links/forms/reload proof.
  - `release-engine`: require named asset-use decision and exact dry-run command.
  - `model-domain`: require both `plan-tests` and `write-tests` handoffs.
  - `review-domain-boundaries`, `skill-router`, `security-check`: tighten exact evidence/ordering requirements.
- [x] Run evidence-contract eval:
  - Command: `tessl eval run . --variant with-context --agent=claude:claude-sonnet-4-6 --runs 3 --label v6-evidence-contract-low-tail-3x`
  - Run ID: `019e26e7-d68d-729d-9613-c2523301fe62`
  - Partial result before moving to the next patch: `39/41`, interim average `98.05%`
  - Low tail at that point: `review-migration` `88.0`, `refactor-code` `88.0`, `review-engine` `91.0`
  - Decision: use the partial as directional evidence only; patch the remaining low-tail reasons because they were generalizable and scorer-supported.
- [x] Patch sub-90 anchors:
  - `refactor-code`: make adapter/facade/wrapper choice first-class; require observed output rather than "required output" wording.
  - `review-migration`: require explicit lock/table-rewrite notes and type-change rollout pattern.
  - `review-engine`: require concrete `grep`/migration-audit commands for namespace isolation and destructive migration checks.
- [x] Run static validation after sub-90 patch:
  - `git diff --check`: passed
  - `ruby scripts/validate-tessl-evals.rb`: passed
  - `./scripts/validate-plugins.sh`: passed
  - `tessl skill lint tile.json`: passed
- [x] Run Sonnet 3x eval after sub-90 patch:
  - Command: `tessl eval run . --variant with-context --agent=claude:claude-sonnet-4-6 --runs 3 --label v6-sub90-anchor-pass-3x`
  - Run ID: `019e26ec-d7e8-70d4-a921-10fff675164f`
  - Result while scored after refresh: `41/41`, average `97.12%` (`status=pending` in Tessl JSON, but all scenarios have scores)
  - Target wins:
    - `review-migration`: `88.0 -> 100.0`
    - `review-engine`: `91.0 -> 99.0`
    - `refactor-code`: `88.0 -> 89.0`
  - Remaining low tail:
    - `apply-stack-conventions`: `74.5`
    - `create-service-object`: `89.0`
    - `refactor-code`: `89.0`
  - Decision: keep the patch because it beats the protected `96.4%` baseline and fixes two target anchors, but do not call it a `98%` release-candidate. The next safe pass should inspect only the remaining sub-90 reasons and avoid editing skills that already hit `99.0+`.
- [x] Run observed-output / response-contract eval:
  - Command: `tessl eval run . --variant with-context --agent=claude:claude-sonnet-4-6 --runs 3 --label v6-observed-output-response-contract-3x`
  - Run ID: `019e26f4-d556-772c-a3e9-6b7a4595bc4d`
  - Result while scored: `41/41`, average `96.32%` (`status=pending` in Tessl JSON, but all scenarios have scores)
  - Target movement:
    - `create-service-object`: `89.0 -> 100.0`
    - `apply-stack-conventions`: `74.5 -> 77.0`
    - `refactor-code`: `89.0 -> 88.0`
  - Unrelated variance:
    - `generate-tasks`: `52.0`, despite no direct edit in that pass.
  - Decision: do not treat this as a new best because it is below the protected `96.4%` baseline and below the current measured best `97.12%`. Keep the `create-service-object` response-contract lesson as valid evidence, but verify with another run before release-candidate decisions.
- [x] Patch full-checklist and terminal-proof misses:
  - `generate-tasks`: forbid checklist summaries and require the complete task artifact; update `TASK_TEMPLATES.md` so Task `0.0` contains the branch checkout command directly.
  - `apply-stack-conventions`: require observed run-output evidence for RED/GREEN proof instead of Ruby comment annotations.
  - `refactor-code`: require observed run-output evidence instead of expected-output annotations.
- [x] Run Sonnet 3x eval after full-checklist / terminal-proof patch:
  - Command: `tessl eval run . --variant with-context --agent=claude:claude-sonnet-4-6 --runs 3 --label v6-full-checklist-terminal-proof-3x`
  - Run ID: `019e26f9-ade8-71b5-b5f8-a6213acc7e49`
  - Result while scored: `40/41`, interim average `95.3%`
  - Target movement:
    - `generate-tasks`: `52.0 -> 100.0`
    - `create-service-object`: stayed `100.0`
    - `refactor-code`: `88.0 -> 94.0`
    - `apply-stack-conventions`: stayed `77.0`
  - Unrelated variance:
    - `create-prd`: `40.0`
    - `setup-environment`: `80.0`
  - Decision: not a new best and not a release-candidate signal. Treat this as evidence that the full-checklist and terminal-proof patches helped their targets, but the eval remains too noisy to decide release status from this sample.
- [x] Update `plans/lessons-learned-from-tessl.md` for this iteration:
  - Capture that the route from `96.4%` to `97.22%` and `97.12%` was driven by evidence contracts, not broad rewrites.
  - Capture that a partial `98%+` run can collapse back under `98%` when the remaining scenarios land.
  - Capture that sub-90 work remains possible, but likely requires repeated samples and narrow anchor patches rather than batch editing.

## Release-Candidate Cleanup

Objective: return the committed release-candidate surface to the measured `v6-sub90-anchor-pass-3x` state while keeping the later noisy runs as lessons, not release evidence.

- [x] Confirm starting tree and branch state:
  - `git status --short --branch`: clean `improve-quality` branch before cleanup.
  - `HEAD`, `main`, and `origin/main` all pointed at `52bde11`.
  - `plans/lessons-learned-from-tessl.md` is the tracked lessons artifact for this cleanup pass.
- [x] Preserve the release-candidate anchors from run `019e26ec-d7e8-70d4-a921-10fff675164f`:
  - `review-migration`: keep explicit lock/table-rewrite and type-change rollout evidence.
  - `review-engine`: keep namespace and destructive-migration audit command requirements.
  - `refactor-code`: keep adapter/facade/wrapper decision and observed-output language.
- [x] Revert post-candidate noisy experiment wording:
  - `create-service-object`: removed the unconfirmed ORM-instance response-payload ban while preserving the normal `success:` / `response:` contract proof.
  - `generate-tasks`: removed checklist-summary/full-artifact pressure and restored the direct Task `0.0` template change to the parent task plus branch-checkout sub-task shape.
  - `apply-stack-conventions`: removed copied-output/comment-annotation proof wording while keeping visible RED/GREEN proof requirements.
  - `refactor-code`: removed copied-output/comment-annotation wording while keeping actual observed command-output evidence requirements.
- [x] Keep the later runs as lessons only:
  - `019e26f4-d556-772c-a3e9-6b7a4595bc4d` showed a `create-service-object` target win but fell below the current measured best.
  - `019e26f9-ade8-71b5-b5f8-a6213acc7e49` showed target movement but included unrelated `create-prd` and `setup-environment` collapse.
- [ ] Confirm the cleaned state:
  - Run static gates and moderation scan.
  - Run `tessl eval run . --variant with-context --agent=claude:claude-sonnet-4-6 --runs 3 --label v6-release-candidate-cleanup-3x`.
  - Accept only if the cleaned state beats the protected `96.4%` 41-skill baseline and avoids unrelated collapse similar to `019e26f9`.

### Cleanup Confirmation Result

- [x] Run cleanup confirmation eval:
  - Command: `tessl eval run . --variant with-context --agent=claude:claude-sonnet-4-6 --runs 3 --label v6-release-candidate-cleanup-3x`
  - Run ID: `019e2a91-4d52-730c-92b0-c259ab25ce31`
  - Result while scored: `41/41`, average `96.17%` (`status=pending` in Tessl JSON, but all scenarios have scores)
  - Decision: reject the cleaned state as a release candidate because it is below the protected `96.4%` 41-skill baseline.
  - Low-tail results:
    - `generate-tasks`: `69.0`
    - `implement-calculator-pattern`: `76.0`
    - `refactor-code`: `82.0`
    - `write-tests`: `87.0`
    - `create-engine`: `89.0`
- [x] Inspect individual skill scorer reasons before further edits:
  - `generate-tasks`: answer summarized the tasks table instead of including the actual checklist, missing `Relevant Files`, `Guidance Used`, `Instructions for Completing Tasks`, and direct branch checkout command.
  - `refactor-code`: answer used `Required output` / `Expected final output` instead of observed evidence.
  - `implement-calculator-pattern`: NullService and concrete services lacked separate RED/GREEN checkpoints and full nil/inactive/unknown variant coverage.
  - `write-tests`: RED proof was a placeholder template, and time-dependent `let` setup could be evaluated inside `travel_to`.
  - `create-engine`: answer omitted `bundle exec rake`, did not make narrow purpose explicit enough, and omitted some host-app contract categories.
- [x] User approved widening scope to tasks below `90%` and reviewing individual skill qualification.
- [x] Patch sub-90 cleanup run lows:
  - `generate-tasks`: restore full checklist artifact requirement and direct Task `0.0` checkout command in `TASK_TEMPLATES.md`.
  - `refactor-code`: explicitly forbid `Required output`, `Expected output`, and `Expected final output` substitutes; require **Observed output** for actual run evidence.
  - `implement-calculator-pattern`: require per-component RED/GREEN proof and full NullService/concrete service variant contexts.
  - `write-tests`: require concrete RED failure messages, not placeholder templates, and self-audit time-dependent lazy setup.
  - `create-engine`: require narrow purpose, full host-app contract categories, `bundle exec rake`, dummy app, routes, and grep verification checkpoints.
- [ ] Run static validation after the sub-90 repair patch.
- [x] Run static validation after the sub-90 repair patch:
  - `git diff --check`: passed
  - `ruby scripts/validate-tessl-evals.rb`: passed
  - `./scripts/validate-plugins.sh`: passed
  - `tessl skill lint tile.json`: valid tile; existing orphan warning for `docs/workflow-template.md`
- [x] Run Sonnet 3x eval after the sub-90 repair patch:
  - Command: `tessl eval run . --variant with-context --agent=claude:claude-sonnet-4-6 --runs 3 --label v6-sub90-repair-after-cleanup-3x`
  - Run ID: `019e2a9d-3b4a-7198-af60-b01837e8498d`
  - Result while scored: `41/41`, average `97.3%` (`status=pending` in Tessl JSON, but all scenarios have scores)
  - Decision: keep this patch as the new best cleanup-era result. It beats both the protected `96.4%` 41-skill baseline and the `97.12%` `v6-sub90-anchor-pass-3x` candidate.
  - Target movement from the rejected cleanup run:
    - `generate-tasks`: `69.0 -> 96.0`
    - `implement-calculator-pattern`: `76.0 -> 100.0`
    - `create-engine`: `89.0 -> 98.0`
    - `refactor-code`: `82.0 -> 86.5`
    - `write-tests`: `87.0 -> 88.0`
  - Remaining sub-90 lows:
    - `refactor-code`: `86.5`
    - `apply-stack-conventions`: `88.0`
    - `write-tests`: `88.0`
- [x] Inspect remaining sub-90 individual scorer reasons:
  - `apply-stack-conventions`: concrete RED/GREEN lines existed, but scorer still treated some proof as illustrative rather than observed.
  - `refactor-code`: answer still used "must produce 0 failures" style planned evidence instead of **Observed output**.
  - `write-tests`: RED proof still used illustrative `e.g.` failure examples rather than concrete messages.
- [x] Patch remaining evidence-label lows:
  - `apply-stack-conventions`: require **Observed RED output** and **Observed GREEN output** labels, no illustrative `e.g.` verification evidence.
  - `refactor-code`: forbid "must produce 0 failures" / "must still report 0 failures" evidence substitutes.
  - `write-tests`: forbid `e.g.` RED failure messages and make shared-example avoidance explicit.
- [ ] Run static validation after the remaining evidence-label patch.
- [x] Run static validation after the remaining evidence-label patch:
  - `git diff --check`: passed
  - `ruby scripts/validate-tessl-evals.rb`: passed
  - `./scripts/validate-plugins.sh`: passed
  - `tessl skill lint tile.json`: valid tile; existing orphan warning for `docs/workflow-template.md`
- [x] Run Sonnet 3x eval after the remaining evidence-label patch:
  - Command: `tessl eval run . --variant with-context --agent=claude:claude-sonnet-4-6 --runs 3 --label v6-evidence-label-sub90-followup-3x`
  - Run ID: `019e2aa9-ef05-768a-8773-0be3d662e99d`
  - Final status: `completed`
  - Result: `41/41`, average `97.45%`
  - Decision: keep this patch as the new best cleanup pass result. It beats the protected `96.4%` baseline, the earlier `97.12%` candidate, and the `97.3%` sub-90 repair run.
  - Target movement from `019e2a9d-3b4a-7198-af60-b01837e8498d`:
    - `refactor-code`: `86.5 -> 91.33`
    - `write-tests`: `88.0 -> 97.67`
    - `apply-stack-conventions`: `88.0 -> 80.66`
  - Interpretation: the evidence-label wording helped `refactor-code` and `write-tests` but hurt `apply-stack-conventions`. Keep for now because the aggregate set a new best, but do not use this as proof that the `apply-stack-conventions` wording is solved.
  - Remaining sub-90 low:
    - `apply-stack-conventions`: `80.66`

## Sub-94 Tricky Low-Tail Pass

Objective: try to move the remaining low-tail skills toward `94%+` without broad rewrites. Use individual skill qualification from run `019e2aa9-ef05-768a-8773-0be3d662e99d`, not aggregate guessing.

- [x] Inspect sub-94 scorer reasons from run `019e2aa9-ef05-768a-8773-0be3d662e99d`:
  - `apply-stack-conventions`: `80.66`; missing explicit layer-isolation section and view/Stimulus/Tailwind isolation coverage.
  - `review-domain-boundaries`: `90.67`; Fleet/Billing ownership example direction was not directly demonstrated.
  - `refactor-code`: `91.33`; still allowed `required exit condition` / planned verification language and did not restate the stop condition strongly enough.
  - `setup-environment`: `93.33`; database setup command was split instead of `rails db:create db:migrate db:seed`.
  - `code-review`: `93.67`; scorer treated the answer as a simulated PR instead of grounded review of a real branch diff.
  - `skill-router`: `93.67`; fallback behavior existed but was not explicitly labeled as fallback.
- [x] Patch sub-94 scorer-mapped gaps:
  - `apply-stack-conventions`: require a dedicated **Layer isolation** section covering model/query, service, controller/request, view/Turbo, Stimulus, and Tailwind, with "not applicable" for unchanged layers.
  - `review-domain-boundaries`: clarify Billing owns invoice-generation triggers while Fleet owns vehicle state/availability.
  - `refactor-code`: forbid `required exit condition` language and require the characterization-test stop condition before refactor steps.
  - `setup-environment`: keep `rails db:create db:migrate db:seed` as the default database setup command unless a split is justified.
  - `code-review`: require findings to be grounded in an actual diff or provided files; no simulated PR findings as completed review evidence.
  - `skill-router`: label ambiguous-routing fallback as `Fallback: load-context`.
- [ ] Run static validation after sub-94 patch.
- [ ] Run Sonnet 3x eval after sub-94 patch.

- [ ] Use multi-agent evals only for model-sensitivity analysis after Sonnet stabilizes:
  - `claude:claude-sonnet-4-6`
  - `claude:claude-opus-4-6`
  - `claude:claude-haiku-4-5`
- [ ] Prefer tile-root evals (`.`) for this optimization loop because they preserve tile context shape. Use `./evals/ --workspace=<workspace> --agent=... --context-ref=HEAD` only when intentionally testing staged scenarios as scenarios-directory input.

## Assumptions

- The active objective is best release score, not preserving all current edits.
- Current worktree changes may be discarded, selectively reapplied, or rewritten.
- Individual skill improvements matter only when they do not reduce the full-library aggregate.
