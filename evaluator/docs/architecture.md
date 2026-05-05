# Evaluator Architecture

The Rails Agent Evaluator is designed to provide a reproducible and isolated environment for testing AI agents. It consists of several decoupled components that orchestrate the evaluation flow.

## High-Level Flow

1. **`Runner`**: The entry point. It parses CLI arguments, discovers evaluation tasks in the file system, and handles parallel execution across multiple threads.
2. **`AgentRunner`**: Manages a single evaluation scenario (either `baseline` or `context`). It initiates the `Sandbox` and invokes the `ReactAgent`.
3. **`Sandbox`**: Creates a temporary directory, copies the task files into it, and initializes a Git repository. This ensures that every run starts from a clean state and that all modifications can be captured via Git diffs.
4. **`ContextHydrator`**: In the `context` mode, it reads the skill/workflow documentation from the repository and converts it into a standardized XML format injected into the agent's system prompt.
5. **`ReactAgent`**: An autonomous agent that follows the **Reasoning and Acting** loop. It analyzes the task, decides which tools to use, executes them in the sandbox, and observes the results until the task is complete.
6. **`Judge`**: An LLM-based grader. It receives the task description, the criteria, and the resulting diffs from both the baseline and context runs. It provides an objective score and reasoning for each.
7. **`Client`**: A provider-agnostic abstraction layer. It dispatches API calls to different LLM backends (OpenAI, Gemini) and handles standardized error reporting.

## Key Components

### `Evaluator::Runner`

- Handles task discovery using `Dir.glob`.
- Orchestrates parallel execution using the `parallel` gem.
- Aggregates results and generates reports.

### `Evaluator::Sandbox`

- Uses `Dir.mktmpdir` for isolation.
- Captures state changes using `git diff`.
- Cleans up automatically after execution.

### `Evaluator::ReactAgent`

- Implements a stateful loop.
- Supports tool usage (e.g., `read_file`, `write_file`, `run_shell_command`).
- Manages conversation history.

### `Evaluator::Clients::BaseClient`

- Implements the **Template Method** pattern.
- Handles Faraday connection setup and timeouts.
- Centralizes error logging and response normalization.

## Data Structures

The evaluator relies on a strict directory mirroring convention:
- **Source**: `skills/<category>/<skill_name>`
- **Eval**: `private-evals/skills/<category>/<skill_name>/<task_name>` or another local path containing `evals/skills/...`

This mirroring allows the `Runner` to automatically find the correct context to hydrate for any given evaluation task.
