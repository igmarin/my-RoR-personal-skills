# Calling Skills and Workflows

Rails Agent Skills can be invoked in three distinct ways depending on the environment, the user's intent, and the level of autonomy desired. Understanding the syntax and context for each method ensures you get the most out of your AI coding assistant.

## The 3 Execution Contexts

| Method | Syntax | Best For | Level of Autonomy |
|--------|--------|----------|-------------------|
| **MCP `use_skill`** | Autonomous tool call by the agent | Autonomous, multi-step agent workflows where the LLM dynamically loads context | High |
| **Chat Commands** | `@skill-name` or `/skill-name` | Explicitly forcing the agent to follow a specific skill's instructions immediately | Low (Human-directed) |
| **CLI (`gh skill` / `tessl`)** | `gh skill install ...` | Local installation, pinning versions, or running CI/CD evaluations | Manual setup/execution |

---

### 1. MCP (`use_skill`)

When the repository is connected to an MCP (Model Context Protocol) client (like Claude Desktop, Cursor, or Windsurf), the AI agent has access to the library's metadata. 

**Syntax:**
The LLM automatically invokes the `use_skill(skill_name)` tool based on the user's prompt. 
*Example User Prompt:* "Please review this pull request for security vulnerabilities."
*Agent Action:* Autonomously loads `security-check` and `code-review`.

**When to use:**
Use this method when you want the agent to autonomously figure out which skills apply to your broad request. It minimizes the cognitive load on the developer.

---

### 2. Chat Commands (`@` or `/`)

In environments that support explicit context injection (like Cursor, Windsurf, or Gemini CLI), developers can force the agent to use a specific skill immediately.

**Syntax:**
- **Cursor / Windsurf:** `@skill-name` (e.g., `@write-tests Can you add coverage for the new order model?`)
- **Gemini CLI:** `/activate_skill skill-name` or `/skill-name`

**When to use:**
Use this when you know exactly which workflow you want to follow and want to bypass the autonomous discovery phase. It is highly effective for enforcing strict constraints (like the "Tests Gate Implementation" rule) on specific tasks.

---

### 3. CLI (`gh skill` / `tessl`)

For manual installation, version pinning, or evaluation, you can interact with the skills directly via the terminal.

**Syntax:**
*Installing via GitHub CLI:*
```bash
# Install a specific skill for the current project
gh skill install igmarin/rails-agent-skills code-review --scope project
```

*Evaluating via Tessl:*
```bash
# Run evaluations to measure skill quality
tessl eval run .
```

**When to use:**
Use the CLI method when setting up a new project, configuring CI/CD pipelines, or when you need to pin your workspace to a specific release tag of a skill for reproducible results.