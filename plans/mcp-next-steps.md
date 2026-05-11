# MCP Registry Next Steps

## Goal

Register the `rails-agent-skills` MCP server with the official MCP Registry at `registry.modelcontextprotocol.io`, using the existing public Docker image as the distributable package.

This should be done after the Tessl release/eval automation work is merged, so the versioning and tag flow are stable first.

## Current Repo State

- The repo already contains a real stdio MCP server in `mcp_server/`.
- The server runs through Ruby/Bundler locally and through the root `Dockerfile` for containerized use.
- Docker Hub image workflow already publishes `igmarin/rails-agent-skills-mcp`.
- `mcp_server/registry.json` exists, but it is not the official MCP Registry `server.json` format.
- The official MCP Registry is a metadata registry: it stores server metadata pointing at a public package or image. It does not host the server code.

## Required Changes

1. Add the official MCP Registry ownership label to the Docker image:

   ```dockerfile
   LABEL io.modelcontextprotocol.server.name="io.github.igmarin/rails-agent-skills-mcp"
   ```

2. Add root `server.json` using the official schema:

   ```json
   {
     "$schema": "https://static.modelcontextprotocol.io/schemas/2025-12-11/server.schema.json",
     "name": "io.github.igmarin/rails-agent-skills-mcp",
     "title": "Rails Agent Skills",
     "description": "MCP server exposing Rails development skills, docs, and workflows through stdio.",
     "repository": {
       "url": "https://github.com/igmarin/rails-agent-skills",
       "source": "github",
       "subfolder": "mcp_server"
     },
     "version": "VERSION",
     "packages": [
       {
         "registryType": "oci",
         "identifier": "docker.io/igmarin/rails-agent-skills-mcp:VERSION",
         "transport": {
           "type": "stdio"
         }
       }
     ]
   }
   ```

   Replace `VERSION` from the Git tag during release, for example `5.1.1`.

3. Update Docker publishing so semver tags are always available before MCP Registry publish.

   The registry entry should point to a versioned image tag, not only `latest`.

4. Add `.github/workflows/publish-mcp-registry.yml` or extend the Docker publish workflow with a dependent publish job:

   - Trigger on `v*` tags.
   - Build/push the Docker image first.
   - Install `mcp-publisher`.
   - Authenticate with GitHub OIDC:

     ```bash
     ./mcp-publisher login github-oidc
     ```

   - Set `server.json.version` and OCI image identifier from the tag.
   - Publish:

     ```bash
     ./mcp-publisher publish
     ```

   Required workflow permission:

   ```yaml
   permissions:
     id-token: write
     contents: read
   ```

5. Validate before publishing:

   - Validate `server.json` against its `$schema` with a real JSON schema validator.
   - Build the Docker image locally or in CI.
   - Confirm the image label exists on the built image.
   - Confirm the stdio server starts inside Docker:

     ```bash
     docker run --rm -i igmarin/rails-agent-skills-mcp:VERSION
     ```

6. Verify after publishing:

   ```bash
   curl "https://registry.modelcontextprotocol.io/v0.1/servers?search=io.github.igmarin/rails-agent-skills-mcp"
   ```

## Acceptance Criteria

- `server.json` exists at repo root and validates against the official schema.
- Docker image includes `io.modelcontextprotocol.server.name=io.github.igmarin/rails-agent-skills-mcp`.
- CI publishes the Docker image before attempting MCP Registry publish.
- MCP Registry publish uses OIDC, not a long-lived GitHub token.
- Registry search returns `io.github.igmarin/rails-agent-skills-mcp`.

## Notes

- Keep this as a separate PR/commit from the Tessl release automation.
- Do not replace `mcp_server/registry.json` unless Smithery/Glama no longer need it.
- If branch/tag versioning changes in the Tessl work, align `server.json.version` with the final release tag strategy before implementation.
