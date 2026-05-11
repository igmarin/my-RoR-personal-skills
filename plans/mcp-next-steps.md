# MCP Registry Next Steps

## Goal

Register the `rails-agent-skills` MCP server with the official MCP Registry at `registry.modelcontextprotocol.io`, using the public Docker Hub image `docker.io/igmarin/rails-agent-skills-mcp` as the distributable package.

The implementation targets the next `v*` release tag. It does not try to retrofit the registry entry onto an older image tag.

## Current Repo State

- The repo contains a real stdio MCP server in `mcp_server/`.
- The server runs through Ruby/Bundler locally and through the root `Dockerfile` for containerized use.
- Docker Hub publishing is handled by `.github/workflows/docker-publish.yml`.
- Root `server.json` is the official MCP Registry metadata file.
- `mcp_server/registry.json` remains in place for older registry/catalog integrations and should not be removed unless those integrations no longer need it.

## Implemented Changes

1. Docker image ownership verification is declared in the root `Dockerfile`:

   ```dockerfile
   LABEL io.modelcontextprotocol.server.name="io.github.igmarin/rails-agent-skills-mcp"
   ```

2. Root `server.json` uses the official schema and stable MCP server name:

   ```json
   {
     "$schema": "https://static.modelcontextprotocol.io/schemas/2025-12-11/server.schema.json",
     "name": "io.github.igmarin/rails-agent-skills-mcp",
     "title": "Rails Agent Skills",
     "description": "Rails development skills, docs, and workflows exposed through MCP stdio.",
     "repository": {
       "url": "https://github.com/igmarin/rails-agent-skills",
       "source": "github",
       "subfolder": "mcp_server"
     },
     "version": "0.0.0",
    "packages": [
      {
        "registryType": "oci",
        "identifier": "docker.io/igmarin/rails-agent-skills-mcp:0.0.0",
        "transport": {
          "type": "stdio"
        }
       }
     ]
   }
   ```

   The workflow replaces `0.0.0` with the Git tag version before publishing.

3. `.github/workflows/docker-publish.yml` now has a dependent `publish-mcp-registry` job:

   - Runs only for `v*` tags.
   - Waits for the Docker image build/push job to finish.
   - Downloads `mcp-publisher`.
   - Sets `server.json.version` and `packages[0].identifier` from the tag.
   - Leaves the OCI package without a package-level `version` field because the registry requires the OCI version in the image tag.
   - Confirms the versioned Docker image is visible on Docker Hub.
   - Authenticates with GitHub OIDC.
   - Publishes the server metadata to the MCP Registry.

## Release Flow

The expected release flow is:

```bash
git tag vX.Y.Z
git push origin vX.Y.Z
```

The tag triggers:

1. Docker image publish to `docker.io/igmarin/rails-agent-skills-mcp:X.Y.Z`.
2. MCP Registry metadata publish for `io.github.igmarin/rails-agent-skills-mcp` version `X.Y.Z`.

Do not use `latest` in `server.json`; the registry entry must point at a specific immutable image tag.

## Your Remaining Tasks

- Keep Docker Hub repository `igmarin/rails-agent-skills-mcp` public.
- Keep GitHub secrets `DOCKERHUB_USERNAME` and `DOCKERHUB_TOKEN` available.
- Merge the MCP Registry implementation.
- Create and push the next `v*` release tag when ready.
- Watch the first registry publish run. If GitHub namespace authorization fails, complete the authorization step requested by `mcp-publisher`.

## Agent / Repo Tasks

- Maintain `server.json` with the official schema.
- Keep Docker image labels aligned with `server.json.name`.
- Keep the Docker publish job ahead of MCP Registry publish.
- Validate the MCP server and Docker image before release.

## Validation Checklist

Before release:

```bash
cd mcp_server && bundle exec rake test
ruby -rjson -e 'JSON.parse(File.read("server.json")); puts "server.json JSON ok"'
docker build -t rails-agent-skills-mcp:test .
docker image inspect rails-agent-skills-mcp:test --format '{{ index .Config.Labels "io.modelcontextprotocol.server.name" }}'
```

The label inspection should print:

```text
io.github.igmarin/rails-agent-skills-mcp
```

After release:

```bash
curl "https://registry.modelcontextprotocol.io/v0.1/servers?search=io.github.igmarin/rails-agent-skills-mcp"
```

The response should include `io.github.igmarin/rails-agent-skills-mcp`.
