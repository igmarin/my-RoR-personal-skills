---
name: generate-api-collection
license: MIT
description: >
  Use when creating or modifying REST API endpoints (Rails controllers, engine routes,
  API actions). Requires generating or updating an API Collection file (e.g., Postman
  Collection v2.1) so the new or changed endpoints can be tested. Trigger words:
  endpoint, API route, controller action, API collection, request collection.
metadata:
  user-invocable: "true"
  version: 1.0.0
---
# Generate API Collection

**Core principle:** Every API surface (Rails app or engine) has a single API collection file that stays in sync with its endpoints.

## Quick Reference

| Aspect | Rule |
|--------|------|
| When | Create or update collection when creating or modifying any REST API endpoint (route + controller action) |
| Format | Postman Collection JSON v2.1 (`schema` or `info.schema` references v2.1) |
| Location | One file per app or engine — `docs/api-collections/<app-or-engine-name>.json` or `spec/fixtures/api-collections/`; if a collection folder already exists, update the existing file |
| Language | All request names, descriptions, and variable names must be in **English** |
| Variables | Use `{{base_url}}` for the base URL so the collection works across environments |
| Per request | method, URL, headers, body, **description**, and **test scripts** (e.g. `pm.response.to.have.status(200)`) |
| Folders | Group related endpoints into folders using nested `item` arrays |
| Validation | See validation steps in the HARD-GATE section below |

## HARD-GATE: Generate on Endpoint Change

```
When you create or modify a REST API endpoint (new or changed route and controller action),
you MUST also create or update the corresponding API collection file so the
flow can be tested. Do not leave the collection missing or outdated.

Each request MUST include a description and at least one basic test script (e.g. status code check).

EXCEPTION: GraphQL endpoints — use implement-graphql instead.
```

After generating or updating the collection, validate the output:
- Confirm the JSON is syntactically valid.
- Verify the collection can be imported into a compatible API client (e.g. Postman) without errors.
- Confirm all new or changed endpoints are represented and that `{{base_url}}` (or equivalent) is used consistently.

## Collection Structure (Postman v2.1)

Ensure the collection includes the `info` block, folders (nested `item` arrays), and `event` scripts:

```json
{
  "info": {
    "name": "Products API",
    "schema": "https://schema.getpostman.com/json/collection/v2.1.0/collection.json"
  },
  "item": [
    {
      "name": "Products",
      "item": [
        {
          "name": "List products",
          "request": {
            "method": "GET",
            "header": [],
            "url": "{{base_url}}/api/v1/products",
            "description": "Returns a list of all products in the catalog."
          },
          "event": [
            {
              "listen": "test",
              "script": {
                "exec": ["pm.test('Status code is 200', () => { pm.response.to.have.status(200); });"],
                "type": "text/javascript"
              }
            }
          ]
        }
      ]
    }
  ],
  "variable": [
    { "key": "base_url", "value": "http://localhost:3000" }
  ]
}
```

See [EXAMPLES.md](./EXAMPLES.md) for a multi-endpoint collection with auth token variables.

## Common Mistakes

| Mistake | Reality |
|---------|---------|
| Missing Content-Type or body for POST/PUT | Include headers and example body so the request works out of the box |
| Skipping validation after generation | Always verify the JSON is well-formed and imports correctly before committing (see HARD-GATE) |

## Integration

Chain to **create-engine** when the engine exposes HTTP endpoints.
