import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { McpAgent } from "agents/mcp";
import { z } from "zod";
import { DEFAULT_RAW_BASE, listSkillNames, loadSkillContent } from "./skill-content";

export interface Env {
  RailsAgentSkillsMCP: DurableObjectNamespace<RailsAgentSkillsMCP>;
  RAW_BASE?: string;
}

function rawBase(env: Env): string {
  return env.RAW_BASE ?? DEFAULT_RAW_BASE;
}

function json(data: unknown, init: ResponseInit = {}): Response {
  return new Response(JSON.stringify(data, null, 2), {
    ...init,
    headers: {
      "content-type": "application/json; charset=utf-8",
      ...init.headers,
    },
  });
}

function serverCard() {
  return {
    serverInfo: {
      name: "rails-agent-skills",
      version: "5.1.5",
    },
    authentication: {
      required: false,
    },
    tools: [
      {
        name: "use_skill",
        description: "Load and return the full SKILL.md instructions for a named Rails development skill.",
        inputSchema: {
          type: "object",
          properties: {
            skill_name: {
              type: "string",
              description: "The directory name of the skill, such as code-review or write-tests.",
            },
          },
          required: ["skill_name"],
        },
      },
      {
        name: "list_skills",
        description: "List all public Rails Agent Skills available through use_skill.",
        inputSchema: {
          type: "object",
          properties: {},
        },
      },
    ],
    resources: [],
    prompts: [],
  };
}

export class RailsAgentSkillsMCP extends McpAgent<Env> {
  server = new McpServer({
    name: "rails-agent-skills",
    version: "5.1.5",
  });

  async init() {
    this.server.tool(
      "use_skill",
      "Load and return the full SKILL.md instructions for a named Rails development skill.",
      {
        skill_name: z.string().describe("Skill name, for example code-review, write-tests, or build."),
      },
      async ({ skill_name }) => {
        const content = await loadSkillContent(skill_name, fetch, rawBase(this.env));

        if (!content) {
          return {
            isError: true,
            content: [{ type: "text", text: `Skill '${skill_name}' not found.` }],
          };
        }

        return {
          content: [{ type: "text", text: content }],
        };
      },
    );

    this.server.tool("list_skills", "List all public Rails Agent Skills available through use_skill.", {}, async () => {
      const names = await listSkillNames(fetch, rawBase(this.env));
      return {
        content: [{ type: "text", text: names.join("\n") }],
      };
    });
  }
}

const mcpHandler = RailsAgentSkillsMCP.serve("/mcp", { binding: "RailsAgentSkillsMCP" });

export default {
  async fetch(request: Request, env: Env, ctx: ExecutionContext): Promise<Response> {
    const url = new URL(request.url);

    if (url.pathname === "/" || url.pathname === "/health") {
      return json({
        name: "rails-agent-skills",
        transport: "streamable-http",
        endpoint: "/mcp",
        status: "ok",
      });
    }

    if (url.pathname === "/.well-known/mcp/server-card.json") {
      return json(serverCard());
    }

    return mcpHandler.fetch(request, env, ctx);
  },
};
