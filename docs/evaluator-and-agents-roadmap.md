- Public eval fixtures have documented provenance and are not Tessl-generated outputs.

## Phase 4: Agent Transition

**Goal:** Expand from a hardened ReAct evaluator into richer agent execution. Architecturally, this phase focuses on observability, best practices, and deterministic testing to elevate the evaluator into a robust agent framework.

### Next steps:

1. **Sandbox Isolation (Native Engine Model)**
   - **Decision:** Docker is *not* required for local development and evaluation.
   - **Implementation:** Rely on native Ruby `Dir.mktmpdir` for isolated sandbox environments. This ensures frictionless cross-platform execution and simpler CI integration without the overhead of container management.
   - **Environment:** If the sandbox execution needs specific tools (e.g., Ruby versions, Postgres), it uses the host's existing environment or standard CI ephemeral VMs.

2. **Eval Topology & Ownership**
   - **Responsibility:** The evaluation engine is a generic execution tool.
   - **Ownership:** Host repositories (like `rails-agent-skills`) own their specific `evals/` directories containing `task.md` and `criteria.json`. 
   - **Git Tracking:** Gold-standard evaluation scenarios are committed to the host repository, while temporary sandbox runs remain ignored.

3. **Workflow Evaluation**
   - **Unified Engine:** Workflows (multi-step skill sequences) are evaluated using the exact same ReAct agent loop as atomic skills.
   - **Definition:** A workflow evaluation is defined by a broader `task.md` and a more comprehensive `criteria.json` that expects multiple milestones to be completed in a single run.

4. **Best Practices & Determinism (Testing)**
   - Introduce strict `VCR` or `WebMock` recording for all LLM network interactions within the evaluator's test suite.
   - Ensure the test suite remains fast, deterministic, offline-capable, and immune to API usage costs or network flakiness.

5. **Observability & Traceability (Debugging)**
   - Enhance the history recording to generate detailed, structured execution traces (Trace JSON) for each evaluation run.
   - Traces must capture the full prompt history, exact tool inputs and outputs, step-by-step durations, and token usage metrics alongside the final judge score.

---
**Status:** Architecture split into Engine and Library concerns. Ready for parallel development.
