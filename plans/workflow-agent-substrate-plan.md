# Workflow Agent-Substrate Plan

Status: queued after `plans/v6-tessl-eval-optimization.md`

## Summary

The current workflows are useful orchestration recipes, but they are not yet strong future "agent" entrypoints. They sequence skills well, especially `tdd-workflow`, `review-workflow`, and `engine-workflow`, but they need explicit state, memory, and just-in-time retrieval contracts before they can reliably behave like lightweight agents.

Recommendation: keep workflows as composite skill entrypoints, then harden them with an agent contract layer instead of turning them into large always-loaded documents.

## Implementation Changes

- [ ] Add a shared workflow contract to each workflow:
  - Intent: what job this workflow owns.
  - Inputs: user request, repo state, current diff, existing docs.
  - JIT retrieval: which skill/resource to load only when needed.
  - State: what the workflow must remember during a run.
  - Checkpoint: when to stop, ask, or hand off.
  - Output: the final artifact or report.
- [ ] Add lightweight repo memory conventions:
  - `ARCHITECTURE.md`: stable system shape and boundaries.
  - `DECISIONS.md`: durable technical decisions and tradeoffs.
  - `MEMORY.md`: short-lived project conventions and agent notes.
  - Workflows should read these only through `load-context` or an explicit context checkpoint, not by default.
- [ ] Improve workflows by role:
  - `tdd-workflow`: current behavior, first failing spec, RED reason, GREEN command, next slice.
  - `review-workflow`: finding lifecycle state: discovered, verified, fixed, re-reviewed, deferred.
  - `setup-workflow`: onboarding state separated from CI/CD setup state.
  - `quality-workflow`: scope control so it does not become broad cleanup by default.
  - `engine-workflow`: release-stage state: scaffolded, tested, reviewed, documented, releasable.
- [ ] Keep context efficient:
  - Workflows route to skills and docs; they do not duplicate full skill instructions.
  - Persistent memory files contain stable facts only, not full chat history.
  - Detailed repo context stays just-in-time through `load-context`.

## Test Plan

- [ ] Run static validation:
  - `./scripts/validate-plugins.sh`
  - `tessl skill lint tile.json`
- [ ] Run workflow behavior checks:
  - Dry-review each workflow against one realistic prompt.
  - Confirm each workflow names the next skill and checkpoint clearly.
  - Confirm no workflow skips `load-context` when repo state matters.
  - Confirm no workflow asks agents to load all memory files unconditionally.
- [ ] Add future workflow eval lane:
  - Add workflow-focused scenarios under the custom eval path, not Tessl tile evals.
  - Test whether workflows improve multi-step behavior over individual skill use.

## Assumptions

- Workflows remain excluded from the Tessl tile for now.
- This plan starts only after the current Tessl optimization loop is closed.
- The goal is not to make workflows larger; the goal is to make them more agent-ready.
- Persistent memory should be lightweight and curated, while detailed repo context stays just-in-time.
- `load-context` remains the main gateway for repo-specific facts.
