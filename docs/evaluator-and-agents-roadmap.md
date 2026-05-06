# Evaluator and Agents Roadmap

This roadmap now reflects the repository as it exists today: the evaluator already runs a ReAct loop, the repo already uses root `workflows/`, and the next step is hardening those foundations before any agent-framework expansion.

## Current State

- `workflows/` is already the published home for callable workflow skills.
- Public Tessl-generated eval scenarios have been removed from the repository; future public eval examples must be original or permissively licensed with clear provenance.
- The evaluator already compares a baseline run against a context-hydrated ReAct run.
- MCP exposure, manifests, and docs are now enforced to match the on-disk topology consistently.
- Phase 3A and 3B are COMPLETE.

## Phase 3A: Hardening and Enforcement Gate ✅ COMPLETE

**Goal:** Make the current evaluator and published skill surface internally consistent before new architecture work begins.

### Completed fixes in this gate

1. **MCP topology enforcement**
   - Discover published skills from `build/` and `skills/<category>/<skill>/`.
   - Discover workflows from `workflows/<workflow>/`.
   - Discover docs from `docs/`.
   - Keep supported Tessl tile discovery only as a compatibility path.

2. **Manifest and inventory enforcement**
   - Publish every callable public skill consistently across `tile.json` and `.claude-plugin/plugin.json`.
   - Keep `scripts/validate-plugins.sh` strict so disk-vs-manifest drift fails immediately.
   - Treat `build/SKILL.md` as a first-class published skill.

3. **Evaluator source-path enforcement**
   - Infer source paths directly from eval targets by convention.
   - Keep `--skill` as an explicit override, not a mandatory input.
   - Record the resolved source path actually used in reports and benchmark history.

4. **Eval provenance enforcement**
   - Keep generated or third-party eval scenarios out of the public repository unless their provenance and license are explicit.
   - Use ignored local folders for private/generated eval runs.
   - Add at least one original public eval example before advertising bundled evaluator fixtures.

5. **Documentation alignment**
   - Remove stale `.windsurf/workflows` assumptions from runtime docs.
   - Describe the evaluator as ReAct-based, not one-shot.
   - Keep roadmap language aligned with the real repo structure and current evaluator behavior.

### Exit criteria

- MCP resources, manifest inventories, evaluator source mapping, and roadmap docs all describe the same topology.
- `scripts/validate-plugins.sh` passes with no inventory exceptions.
- Evaluator and MCP tests cover the enforced conventions.
- Public eval fixtures have documented provenance and are not Tessl-generated outputs.

## Phase 3B: Standalone Evaluator Extraction ✅ COMPLETE

**Goal:** Extract the hardened evaluator into a standalone gem only after the enforcement gate is complete.

1. Extract the stabilized evaluator code into an independent Ruby gem.
2. Move the `evaluator/` directory to its own repository to act as a standalone engine.
3. Re-integrate it into this repository as a dependency with the same ReAct behavior.
4. Preserve convention-based source resolution and benchmark history during the extraction.

This extraction ensures the gem boundary is cut from stable behavior and acts purely as an execution engine, while host repositories own their domain-specific evaluation fixtures.

## Phase 4: Agent Transition Work ✅ READY!

**Goal:** Expand from a hardened ReAct evaluator into richer agent execution. Architecturally, this phase focuses on observability, best practices, and deterministic testing to elevate the evaluator into a robust agent framework.

### Next steps:

1. **Sandbox Isolation (Native Engine Model)**
   - **Decision:** Docker is *not* required for local development and evaluation.
   - **Implementation:** Rely on native Ruby `Dir.mktmpdir` for isolated sandbox environments. This ensures frictionless cross-platform execution and simpler CI integration without the overhead of container management.
   - **Environment:** If the sandbox execution needs specific tools (e.g., Ruby versions, Postgres), it uses the host's existing environment or standard CI ephemeral VMs.

2. **Eval Topology & Ownership**
   - **Responsibility:** The `evaluator` gem is a generic execution engine.
   - **Ownership:** Host repositories (like `rails-agent-skills`) own their specific `evals/` directories containing `task.md` and `criteria.json`. 
   - **Git Tracking:** Gold-standard evaluation scenarios are committed to the host repository, while temporary sandbox runs remain ignored.

3. **Workflow Evaluation**
   - **Unified Engine:** Workflows (multi-step skill sequences) are evaluated using the exact same ReAct agent loop as atomic skills.
   - **Definition:** A workflow evaluation is defined by a broader `task.md` and a more comprehensive `criteria.json` that expects multiple milestones to be completed in a single run.

4. **Best Practices & Determinism (Testing)**
   - Introduce strict `VCR` or `WebMock` recording for all LLM network interactions within the evaluator's test suite.
   - Ensure the test suite remains fast, deterministic, offline-capable, and immune to API usage costs or network flakiness.

5. **Observability & Traceability (Debugging)**
   - Enhance the `HistoryRecorder` to generate detailed, structured execution traces (Trace JSON) for each evaluation run.
   - Traces must capture the full prompt history, exact tool inputs and outputs, step-by-step durations, and token usage metrics alongside the final judge score.

## Repository Relationship & Next Steps

With the completion of Phase 3B, the architecture is now split into two distinct concerns:

### 1. The Engine: `rails-agent-eval`

- **Home:** [igmarin/rails-agent-eval](https://github.com/igmarin/rails-agent-eval)
- **Focus:** Phase 4 implementation (Observability, VCR, Trace JSON, and native sandbox hardening).
- **Usage:** Distributed as a gem for use in any skill library.

### 2. The Library: `rails-agent-skills` (This Repo)

- **Home:** [igmarin/rails-agent-skills](https://github.com/igmarin/rails-agent-skills)
- **Focus:**
    - **Eval Coverage:** Expand the `evals/` directory to cover all 42+ skills and 5 workflows.
    - **Skill Refinement:** Iteratively improve `SKILL.md` instructions based on evaluation scores.
    - **Workflow Chaining:** Design new complex workflows that leverage atomic skills.
    - **Validation:** Use the `rails-agent-eval` gem to maintain a high quality-bar for all published skills.

---
**Status:** All extraction gates complete. Ready for parallel development in both repositories.
