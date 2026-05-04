# Evaluator Domain (`lib/evaluator`)

The `Evaluator` namespace is responsible for creating a safe, observable environment in which the agent can be tested, and subsequently judging its performance.

## Components

### `Sandbox`
- **Purpose**: Creates an isolated environment (`mktmpdir`) for the agent to work in.
- **Mechanism**: It copies the target directory, initializes a Git repository, and commits the initial state. This allows the system to easily capture the agent's work via `git diff` at the end of the run.

### `AgentRunner`
- **Purpose**: Sets up the initial system prompt, hydrates context, and kicks off the ReAct loop.
- **Mechanism**: Orchestrates the communication between the `ReactAgent` and the `ContextHydrator`.

### `Judge`
- **Purpose**: Evaluates the outcome of the agent's work.
- **Mechanism**: Compares the resulting `git diff` against the instructions and context, and uses the LLM to score the performance out of 100, providing an explanation for its score.
