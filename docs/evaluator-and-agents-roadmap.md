# Evaluator and Agents Roadmap

This document outlines the step-by-step master plan to restructure the repository, build a custom Ruby evaluator, and transition from simple skills/workflows to fully autonomous agents.

## Phase 1: Structural Separation

**Goal:** Clean up the repository base and prepare for scaling without breaking current integrations.

1. **Create the `workflows/` directory**: At the root of the repository, separating orchestrators from atomic skills.
2. **Migrate Orchestrators**: Move all orchestrator folders from `skills/workflows/` to the new `/workflows/` directory.
3. **Update Manifests**: Modify `tile.json`, `.claude-plugin`, and validation scripts to read `.md` files from both `skills/` and `workflows/`.
4. **Reorganize `evals/` (Structural Mirror)**:
   - Create `evals/skills/` and `evals/workflows/`.
   - Move current test folders to match the source structure (e.g., `evals/api-versioning-with-controller-inheritan` moves to `evals/skills/api/api-versioning/`).

## Phase 2: Ruby Evaluator V1 (One-Shot)

**Goal:** Solve Tessl's context disconnection and gain independence.

1. **Scaffold the Evaluator**: Create an `evaluator/` (or `runner/`) folder at the root, initialized as a standalone Ruby app with its own `Gemfile`.
2. **XML Bundling Logic (Context Hydration)**:
   - Write a script that maps a test (e.g., `workflows/rails-tdd-loop`) to its source folder.
   - Read all `.md` files in that folder (`SKILL.md`, `EXAMPLES.md`, etc.) and bundle them into `<agent_context><file>...</file></agent_context>` tags.
3. **One-Shot Execution**:
   - **Baseline Call**: Send only `task.md` to the LLM API.
   - **With Context Call**: Send `task.md` + the XML context bundle to the LLM API.
4. **The Judge**: Send both responses and `criteria.json` to an LLM judge to obtain the final score.
5. **Transition**: Validate the script locally and deprecate Tessl.

## Phase 3: Consolidation and Extraction

**Goal:** Stabilize the evaluation engine and expand coverage.

1. **Gemification**: Extract the stable `evaluator/` code into an independent Ruby gem (e.g., `agent_evaluator_core`) and install it back into the repository.
2. **Complete Coverage**: Write missing `task.md` and `criteria.json` for all critical workflows and skills, running them constantly through the new gem.

## Phase 4: The Transition to Agents

**Goal:** Move from static prompt execution to an interactive multi-agent system.

1. **Engine Evolution**: Use the evaluator gem's foundation (API calling, parsing, context hydration) to build a custom Agent Framework (or expand the current `mcp_server`).
2. **Interactive Loop**: Modify the engine to run continuous, interactive processes with OS access (reading terminal outputs like RSpec or Bullet).
3. **The Final Rename**: Once the framework can instantiate a "Supervisor" agent to direct a "Developer" agent autonomously, rename the `workflows/` directory to `agents/`.
