# Evaluator Core (`lib`)

This directory contains the core logic for the AI Agent Evaluation System.

## Architecture Overview

The system is built around several decoupled domains to ensure maintainability and separation of concerns:

- **`Client`**: A lightweight wrapper around the LLM API (e.g., OpenAI) via Faraday.
- **`ContextHydrator`**: Injects necessary context into the prompt, mapping instructions to XML blocks.
- **`ReactAgent`** (in `lib/react_agent`): Implements the ReAct (Reasoning and Acting) loop, executing thoughts, actions, and observations.
- **`Evaluator`** (in `lib/evaluator`): Manages the testing sandbox and the final evaluation (Judge) logic.
- **`Tools`** (in `lib/tools`): Actionable capabilities the agent can use to interact with its environment.
- **`Runner`**: The central orchestrator that glues these components together to execute a skill evaluation.

## Design Philosophy

- **Service Objects (POODR / Sandi Metz):** The code aims for the Single Responsibility Principle. Complex loops (like ReAct) are broken down into discrete objects like `Step` and `ToolExecutor`.
- **Statelessness:** State is mostly kept in the message history passed back and forth, allowing components to remain pure and stateless where possible.
- **Security First:** Actions interacting with the OS (like `tools`) validate boundaries before execution.
