# ReactAgent (`lib/react_agent`)

The `ReactAgent` namespace implements the Reasoning and Acting (ReAct) paradigm. It handles the continuous loop of prompting the LLM, parsing its intent, executing tools, and returning observations.

## Components

### `ReactAgent`
- **Purpose**: The main loop driver. It maintains the message history and repeatedly asks the LLM for its next step until a stop condition is met or a max iteration limit is reached.

### `Step`
- **Purpose**: Represents a single interaction turn with the LLM. It sends the current messages and extracts either a final text response or a tool call request.

### `ToolExecutor`
- **Purpose**: Bridges the LLM's requests with actual Ruby code. It takes a tool call definition, finds the corresponding class in `Evaluator::Tools`, executes it securely, and formats the output (or error) back into a message the LLM can understand.
