# Rails Agent Skills — MCP Server

A Ruby MCP server that exposes the `rails-agent-skills` skill library to AI tools (Windsurf, Cursor, Claude Code, RubyMine, etc.) via the [Model Context Protocol](https://modelcontextprotocol.io) official spec (JSON-RPC 2.0, stdio transport).

Built on the [official Ruby MCP SDK](https://github.com/modelcontextprotocol/ruby-sdk) (`gem 'mcp'`).

---

## Compatibility

| Requirement | Version |
|-------------|---------|
| Ruby | 4.0+ |
| `mcp` gem | 0.15+ |
| Bundler | 2.x |

---

## What it exposes

| Type | Prefix / Name | Source |
|------|---------------|--------|
| **Resources** | `doc/<name>` | All `*.md` files under `docs/`, including nested docs such as `docs/workflows/*.md` |
| **Resources** | `workflow/<name>` | Every workflow directory under `workflows/<workflow>/`, exposed from its `SKILL.md` plus supported companion files |
| **Tool** | `use_skill` | Invocable tool: given a `skill_name`, returns the full `SKILL.md` content |

Individual **Skills** are no longer exposed as resources to prevent context bloat. They are accessed exclusively via the `use_skill` tool.

Adding a new skill directory to the repo automatically makes it available through `use_skill` — no server changes needed.

---

## Architecture

The runtime code lives in `mcp_server/`, while the container build lives at [`../Dockerfile`](../Dockerfile) because the image needs the full repository checkout, including skills, workflows, and docs.

```text
mcp_server/
├── server.rb                          # Entry point: MCP::Server + StdioTransport
├── Gemfile                            # gem 'mcp' (official SDK), minitest, rake
├── Rakefile                           # bundle exec rake test
├── registry.json                      # Metadata for MCP registries (smithery.ai, glama.ai)
├── lib/
│   └── mcp_skills/
│       ├── resource_registry.rb       # Service: discovers published docs and workflows
│       ├── resource_discovery.rb      # Service: resolves published skill/workflow topology
│       ├── skill_resource_builder.rb  # Service: builds MCP::Resource objects for workflow markdown
│       ├── doc_resource_builder.rb    # Service: builds MCP::Resource objects for docs
│       └── skill_tool.rb             # MCP::Tool: 'use_skill' invocable by the agent
└── test/
    ├── test_helper.rb
    ├── resource_registry_test.rb
    ├── skill_resource_builder_test.rb
    ├── doc_resource_builder_test.rb
    └── skill_tool_test.rb
```

**Service objects:**

- **`McpSkills::ResourceRegistry`** — scans the repo for published docs and workflows. Single source of truth for the resource set.
- **`McpSkills::ResourceDiscovery`** — resolves the published topology for root `build/`, nested `skills/`, root `workflows/`, and `docs/`.
- **`McpSkills::SkillResourceBuilder`** — maps a workflow directory path to `MCP::Resource` objects with `file://` URIs and a configurable name prefix.
- **`McpSkills::DocResourceBuilder`** — builds `doc/` resources for markdown files anywhere under `docs/`.
- **`McpSkills::SkillTool`** — `MCP::Tool` subclass. `call(skill_name:)` reads and returns the `SKILL.md` content.

---

## Local Ruby/Bundler (Primary)

```bash
git clone https://github.com/igmarin/rails-agent-skills.git ~/rails-agent-skills
cd ~/rails-agent-skills/mcp_server
bundle install
```

**Run the server manually** (stdio — for debugging):

```bash
bundle exec ruby server.rb
```

**Inspect with the MCP inspector:**

```bash
npx @modelcontextprotocol/inspector bundle exec ruby server.rb
```

---

## Integration with Claude Code

The repo includes a pre-populated `.mcp.json` at the root. When you open the cloned repo as a project in Claude Code, the server is registered automatically — no manual config needed.

For **global** setup (available in every project), add to `~/.claude/mcp.json`:

> **Note:** Always use **absolute paths** to avoid "Gems not found" or timeout errors.

```json
{
  "mcpServers": {
    "rails-agent-skills": {
      "type": "stdio",
      "command": "bundle",
      "args": ["exec", "ruby", "mcp_server/server.rb"],
      "cwd": "/ABSOLUTE/PATH/TO/rails-agent-skills",
      "env": {
        "BUNDLE_GEMFILE": "/ABSOLUTE/PATH/TO/rails-agent-skills/mcp_server/Gemfile"
      }
    }
  }
}
```

---

## Integration with Windsurf

The config goes in your **global** Windsurf MCP file (`~/.codeium/windsurf/mcp_config.json`):

```json
{
  "mcpServers": {
    "rails-agent-skills": {
      "type": "stdio",
      "command": "bundle",
      "args": ["exec", "ruby", "mcp_server/server.rb"],
      "cwd": "/ABSOLUTE/PATH/TO/rails-agent-skills",
      "env": {
        "BUNDLE_GEMFILE": "/ABSOLUTE/PATH/TO/rails-agent-skills/mcp_server/Gemfile"
      }
    }
  }
}
```

---

## Integration with Cursor

Open **Settings → MCP** (or edit `~/.cursor/mcp.json`) and add:

```json
{
  "mcpServers": {
    "rails-agent-skills": {
      "type": "stdio",
      "command": "bundle",
      "args": ["exec", "ruby", "mcp_server/server.rb"],
      "cwd": "/ABSOLUTE/PATH/TO/rails-agent-skills",
      "env": {
        "BUNDLE_GEMFILE": "/ABSOLUTE/PATH/TO/rails-agent-skills/mcp_server/Gemfile"
      }
    }
  }
}
```

---

## Troubleshooting: Gems not found or Timeout

If you encounter errors like `Could not find 'mcp' (>= 0)` or the server times out:

1. **Verify Absolute Paths:** Ensure `cwd` and `BUNDLE_GEMFILE` in your JSON config use absolute paths (e.g., `/Users/name/...` instead of `~/...`).
2. **Pre-install Gems:** Run `cd mcp_server && bundle install` manually in your terminal to ensure the environment is ready.
3. **Manual Test:** Run the following command from any directory to see if it starts without errors:
   `BUNDLE_GEMFILE=/ABSOLUTE/PATH/TO/rails-agent-skills/mcp_server/Gemfile bundle exec ruby /ABSOLUTE/PATH/TO/rails-agent-skills/mcp_server/server.rb`
4. **Environment Mismatch:** If you use a Ruby manager (rvm, rbenv, asdf), ensure the `command` in your config points to the correct `bundle` executable if `bundle` alone doesn't work.

---

## Integration with RubyMine

Open **Settings → Tools → AI Assistant → Model Context Protocol** and add a new server:

- **Command:** `bundle exec ruby mcp_server/server.rb`
- **Working directory:** `/YOUR/PATH/TO/rails-agent-skills`
- **Environment:** `BUNDLE_GEMFILE=/YOUR/PATH/TO/rails-agent-skills/mcp_server/Gemfile`

Restart RubyMine.

---

## Other Providers (OpenCode, AntiGravity, etc.)

For any other tool that supports the Model Context Protocol via stdio, use the following template. **Crucial:** Most external providers fail if you use relative paths or `~`, so always use **absolute paths**.

```json
{
  "mcpServers": {
    "rails-agent-skills": {
      "type": "stdio",
      "command": "bundle",
      "args": ["exec", "ruby", "mcp_server/server.rb"],
      "cwd": "/ABSOLUTE/PATH/TO/rails-agent-skills",
      "env": {
        "BUNDLE_GEMFILE": "/ABSOLUTE/PATH/TO/rails-agent-skills/mcp_server/Gemfile"
      }
    }
  }
}
```

---

## Docker (Fallback)

For environments without Ruby, or for containerized deployment, Docker remains the fallback path. The primary setup for this repo is still local Ruby/Bundler.

```bash
# From the root of the repository:
docker build -t rails-agent-skills-mcp .
docker run --rm -i rails-agent-skills-mcp
```

The container uses stdio transport — wire it up the same way as the Ruby command, replacing `bundle exec ruby server.rb` with `docker run --rm -i rails-agent-skills-mcp`.

**Docker Hub** (published image):

```json
{
  "mcpServers": {
    "rails-agent-skills": {
      "type": "stdio",
      "command": "docker",
      "args": ["run", "--rm", "-i", "igmarin/rails-agent-skills-mcp"]
    }
  }
}
```

---

## End-to-end use case

1. You open any Rails project in Windsurf (or Claude Code, Cursor, etc.).
2. The IDE loads this MCP server from its config.
3. You ask: *"I need to add a GraphQL mutation — which skill should I use?"*
4. The agent calls `tools/call use_skill` with `skill_name: "implement-graphql"`.
5. The server reads `implement-graphql/SKILL.md` and returns the full instructions.
6. The agent follows the skill workflow without loading the entire repo into context.

---

## Running tests

```bash
bundle exec rake test
```

Tests are written with Minitest: each file validates real behavior of a service object, not just structure.

---

## Auto-discovery of new skills

`ResourceRegistry` uses explicit topology discovery for `build/SKILL.md`, `skills/*/*/SKILL.md`, `workflows/*/SKILL.md`, supported Tessl tile mirrors, and `docs/**/*.md`. When you add a published workflow or doc file in those locations, it appears in `resources/list` on the next server start. Published skills become available through `use_skill` without any server code changes.

---

## Public registries

This server is listed on:

- [smithery.ai](https://smithery.ai) — auto-indexed from GitHub
- [glama.ai](https://glama.ai) — submit via their website
- [modelcontextprotocol.io/registry](https://modelcontextprotocol.io) — community servers list

---

## Contributing

- Follow TDD: write the failing test first, then the implementation.
- Service objects live in `lib/mcp_skills/` and must be independently testable (no `MCP::Server` dependency in unit tests).
- All MCP protocol behavior is handled by the `mcp` gem — do not reimplement wire format in service objects.
