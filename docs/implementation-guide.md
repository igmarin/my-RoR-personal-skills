# Implementation Guide — Rails Agent Skills

Step-by-step install and verification for the **`rails-agent-skills`** repository on each supported platform.

- **What this library is:** [README](../README.md)
- **How to chain skills:** [workflow-guide.md](workflow-guide.md)
- **Skill file conventions:** [architecture.md](architecture.md)

The recommended way to use this library is via the **MCP Server Approach**. This provides on-demand access to skills, saving tokens and ensuring your agent always uses the most up-to-date instructions without overwhelming its context window.

---

## MCP Server (Recommended)

The MCP server gives your AI assistant on-demand access to every skill, doc, and workflow. 

### 1. Setup

Clone the repo and install dependencies:

```bash
git clone https://github.com/igmarin/rails-agent-skills.git ~/skills/rails-agent-skills
cd ~/skills/rails-agent-skills/mcp_server
bundle install
```

### 2. Platform Configuration

When configuring the server, **always use absolute paths** to avoid environment errors.

#### Claude Code

Open `~/.claude/mcp.json` (global) or `.mcp.json` in your project root and add:

```json
{
  "mcpServers": {
    "rails-agent-skills": {
      "type": "stdio",
      "command": "bundle",
      "args": ["exec", "ruby", "/Users/YOUR_USER/skills/rails-agent-skills/mcp_server/server.rb"],
      "cwd": "/Users/YOUR_USER/skills/rails-agent-skills",
      "env": {
        "BUNDLE_GEMFILE": "/Users/YOUR_USER/skills/rails-agent-skills/mcp_server/Gemfile"
      }
    }
  }
}
```

#### Cursor & Windsurf

**Windsurf** (`~/.codeium/windsurf/mcp_config.json`):
**Cursor** (`~/.cursor/mcp.json` or **Settings → MCP**):

Add the following configuration:

```json
{
  "mcpServers": {
    "rails-agent-skills": {
      "type": "stdio",
      "command": "bundle",
      "args": ["exec", "ruby", "/Users/YOUR_USER/skills/rails-agent-skills/mcp_server/server.rb"],
      "cwd": "/Users/YOUR_USER/skills/rails-agent-skills",
      "env": {
        "BUNDLE_GEMFILE": "/Users/YOUR_USER/skills/rails-agent-skills/mcp_server/Gemfile"
      }
    }
  }
}
```

#### OpenCode / Codex

Use the CLI to add the server:

```bash
opencode mcp add
```

When prompted for the command, use:
`env BUNDLE_GEMFILE=/Users/YOUR_USER/skills/rails-agent-skills/mcp_server/Gemfile bundle exec ruby /Users/YOUR_USER/skills/rails-agent-skills/mcp_server/server.rb`

#### RubyMine

1. Open **Settings → Tools → AI Assistant → Model Context Protocol**.
2. Add a new server:
   - **Command:** `bundle exec ruby /Users/YOUR_USER/skills/rails-agent-skills/mcp_server/server.rb`
   - **Environment:** `BUNDLE_GEMFILE=/Users/YOUR_USER/skills/rails-agent-skills/mcp_server/Gemfile`

---

## Alternative: The Symlink Approach (Legacy)

If you cannot use MCP, you can symlink the `CLAUDE.md` or `GEMINI.md` files to your agent's global configuration directory.

### Claude Code
```bash
ln -sf ~/skills/rails-agent-skills/CLAUDE.md ~/.claude/CLAUDE.md
```

### Gemini CLI
```bash
ln -s ~/skills/rails-agent-skills/GEMINI.md ~/.gemini/GEMINI.md
```

---

## Session Start Hook

The session-start hook automatically injects the `skill-router` bootstrap skill at the beginning of each session.

| Platform | Integration Method |
|----------|--------------------|
| Claude Code | Handled via `~/.claude/CLAUDE.md` |
| Cursor / Windsurf | Handled via MCP `resources/list` |
| Gemini CLI | Handled via `~/.gemini/GEMINI.md` |

---

## Troubleshooting

| Issue | Solution |
|-------|---------|
| MCP Server Timeout | Ensure you are using **absolute paths** for both the command and `BUNDLE_GEMFILE`. |
| "Gem not found" | Run `bundle install` inside the `mcp_server/` directory. |
| Skills not appearing | Restart your IDE or start a new Claude Code session (`/reset`). |
| Resource Bloat | The server is configured to hide individual skills. Use the `use_skill` tool to load them by name. |
