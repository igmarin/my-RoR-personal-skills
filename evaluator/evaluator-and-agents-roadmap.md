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
2. Re-integrate it into this repository as a dependency with the same ReAct behavior.
3. Preserve convention-based source resolution and benchmark history during the extraction.

This extraction is intentionally *after* the hardening batch so the gem boundary is cut from stable behavior, not from drifting assumptions.

## Phase 4: Agent Transition Work ✅ READY!

**Goal:** Expand from a hardened ReAct evaluator into richer agent execution only after Phase 3A and Phase 3B are complete. Architecturally, this phase focuses on security, best practices, and observability to elevate the evaluator into a robust agent framework.

### Next steps:

1. **Security & Sandbox Isolation (Host/Guest Pattern)**
   - Implement strict Docker containerization for the Agent's sandbox environment.
   - **Secrets Management:** The `ReactAgent`'s "brain" (LLM client orchestration) must run on the host with the API keys, while its "hands" (shell commands via the `run_shell_command` tool) must execute strictly inside the Docker container.
   - Ensure the container environment is scrubbed of all host secrets (e.g., `OPENAI_API_KEY`, `GEMINI_API_KEY`) to prevent exfiltration during untrusted code execution or prompt injection attempts.

2. **Best Practices & Determinism (Testing)**
   - Introduce strict `VCR` or `WebMock` recording for all LLM network interactions within the evaluator's test suite.
   - Ensure the test suite remains fast, deterministic, offline-capable, and immune to API usage costs or network flakiness.

3. **Observability & Traceability (Debugging)**
   - Enhance the `HistoryRecorder` to generate detailed, structured execution traces (Trace JSON) for each evaluation run.
   - Traces must capture the full prompt history, exact tool inputs and outputs, step-by-step durations, and token usage metrics alongside the final judge score.
   - This provides critical visibility for developers to understand exactly *why* a ReAct loop failed or succeeded.

## Guiding Rule

Do not start Phase 4 work while topology, manifest publication, evaluator source mapping, and roadmap docs still disagree. Hardening comes first, extraction comes second, and agent expansion comes last.
