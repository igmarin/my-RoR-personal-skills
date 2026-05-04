# Agent Tools (`lib/tools`)

The `Tools` namespace contains the actionable capabilities exposed to the LLM. 

## Structure

### `Base`
- The parent class for all tools.
- **Security Check**: Contains `secure_path`, which ensures any file operations remain strictly within the sandbox directory, mitigating path traversal attacks.

### Available Tools
- **`ReadFile`**: Reads the content of a file within the sandbox.
- **`WriteFile`**: Creates or overwrites a file within the sandbox. It automatically creates parent directories if they don't exist.
- **`RunCommand`**: Executes a shell command (e.g., tests, linters) using `Open3.capture3`. 

## Adding a New Tool
1. Create a new class inheriting from `Evaluator::Tools::Base`.
2. Implement `self.definition` returning the JSON schema required by the LLM.
3. Implement `self.call(..., working_dir_path)` to perform the action.
4. Ensure any file paths are validated using `secure_path`.
5. Register the tool in `Evaluator::Tools.all`.
