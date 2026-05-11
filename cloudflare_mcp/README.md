# Rails Agent Skills Cloudflare MCP

Cloudflare Workers deployment for a public Streamable HTTP MCP endpoint.

This is separate from the Ruby stdio server in `mcp_server/`. The Worker exposes the same core `use_skill` behavior over HTTP so services such as Smithery can scan and proxy it.

## Routes

| Route | Purpose |
|-------|---------|
| `/mcp` | Streamable HTTP MCP endpoint |
| `/health` | JSON health check |
| `/.well-known/mcp/server-card.json` | Static metadata for scanners such as Smithery |

## Local Setup

```bash
cd cloudflare_mcp
npm install
npm test
npm run typecheck
npm run dev
```

## Deploy

Log in once:

```bash
npx wrangler login
```

Deploy:

```bash
npm run deploy
```

Wrangler prints the Worker URL after deployment. The Smithery MCP Server URL should be:

```text
https://<worker-name>.<account-subdomain>.workers.dev/mcp
```

Current public endpoint:

```text
https://rails-agent-skills-mcp.ismael-marin.workers.dev/mcp
```

If you add a custom Cloudflare domain, use:

```text
https://mcp.your-domain.com/mcp
```

## GitHub Actions

The `Deploy Cloudflare MCP` workflow validates this Worker on pull requests and deploys it on pushes to `main` when files under `cloudflare_mcp/` change.

Add these repository secrets before relying on CI deploys:

```text
CLOUDFLARE_ACCOUNT_ID
CLOUDFLARE_API_TOKEN
```

The Cloudflare API token should be scoped to the account that owns the Worker and include account-level Workers script edit access. If you later attach a custom domain or route, add the necessary zone-level route permissions for that zone.

## Notes

- No API keys or user configuration are required.
- Skill content is fetched from the public GitHub raw URL configured by `RAW_BASE` in `wrangler.jsonc`.
- The Worker is read-only and does not expose repository mutation tools.
