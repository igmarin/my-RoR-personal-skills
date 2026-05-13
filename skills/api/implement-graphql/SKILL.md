---
name: implement-graphql
license: MIT
description: >
  Use when building or reviewing GraphQL APIs in Rails with the graphql-ruby gem.
  Covers schema design, N+1 prevention with dataloaders, field-level auth, query
  limits, error handling, and testing resolvers/mutations with RSpec. Trigger words: 
  graphql, graphql-ruby, resolver, mutation, dataloader, schema.
metadata:
  version: 1.0.0
  user-invocable: "true"
---
# Implement GraphQL

Use this skill when **designing, implementing, or reviewing GraphQL APIs** in a Rails application with the `graphql-ruby` gem.

## Quick Reference

| Concern | Required choice |
|---------|-----------------|
| Specs | Use `AppSchema.execute` in `spec/graphql/`; do not dispatch HTTP controller specs |
| Resolver shape | Dedicated resolver/mutation classes, not inline complex field blocks |
| Associations | Use GraphQL dataloader sources, never direct `object.association` loads |
| Collections | Use `Types::*Type.connection_type` for paginated collections |
| Security | Field-level authorization plus depth/complexity limits |

## HARD-GATE

```text
Tests gate implementation — write specs before resolver code (see write-tests).
Before shipping a resolver/mutation slice, ALL of the following must be true:
- N+1 Prevention: use `dataloader.with(Source, Model).load(id)` — NEVER `object.association`
- Authorization: sensitive fields have field-level guards (not type-level alone).
- Type Conventions: paginated collections use Types::*Type.connection_type, not plain arrays.
- Schema safeguards: AppSchema disables introspection in production and sets max_depth / max_complexity.
- TESTING.md: specs in `spec/graphql/` use `AppSchema.execute`. Never use HTTP controller dispatch for GraphQL specs.
- Error Handling: mutations return `{ result, errors }` with rescue blocks — no unhandled exceptions.
- Documentation: `description:` on every field in every type.
- Resolver Structure: dedicated resolver classes, not inline field blocks.
```

## Core Process

1. **SPEC:** Write failing spec (happy path + auth + validation error case) — see [TESTING.md](./TESTING.md).
2. **TYPE:** Define arguments and return types. Use `connection_type` for pagination shapes. Do not leak internal model names.
3. **IMPLEMENT:** Create resolver/mutation class delegating to a service object. Use dedicated classes instead of inline field blocks.
4. **N+1 CHECK:** Ensure dataloader is used on every association load. Use `bullet` and `db-query-matchers` in specs.
   ```ruby
   # ✅ batches loads across all records
   def buyer
     dataloader.with(Sources::RecordById, Buyer).load(object.buyer_id)
   end
   ```
5. **AUTH CHECK:** Apply field-level guards where data is sensitive using Pundit or custom context guards.
   ```ruby
   field :internal_notes, String, null: true do
     guard -> (_obj, _args, ctx) { ctx[:current_user]&.admin? }
   end
   ```
6. **FINAL CHECK:** Verify every HARD-GATE item is met. Ensure your mutations return `{ result, errors }` shapes on failure.
   ```ruby
   rescue ActiveRecord::RecordInvalid => e
     { order: nil, errors: e.record.errors.full_messages }
   ```
7. **RUN:** Ensure the full test suite is green before PR.

**DO NOT proceed to step 3 before step 1 is written and failing.**

## Extended Resources (Progressive Disclosure)

Load these files only when their specific content is needed:

- **[TESTING.md](./TESTING.md)** — For the spec template, paths, and checklist (happy path, unauthenticated, unauthorized, validation errors, N+1 counts, limits).
- **[EXAMPLES.md](EXAMPLES.md)** — For detailed code examples of dataloaders, mutations, and types.

## Output Style

When implementing GraphQL, your output MUST include:

1. **Schema contract** — Types, fields, arguments, nullability, descriptions, and connection shape.
2. **Resolver/mutation structure** — Dedicated class names and service-object delegation points.
3. **N+1 prevention** — Dataloader source and every association load it protects.
4. **Authorization and limits** — Field-level guards, Pundit checks, introspection/depth/complexity decisions.
5. **Error shape** — Mutation `{ result, errors }` or equivalent structured failure behavior.
6. **Verification** — `spec/graphql/` commands covering happy path, auth, validation errors, N+1 counts, and schema limits.
7. **Language** — Must be in English unless explicitly requested otherwise.

## Integration

| Skill | When to chain |
|-------|---------------|
| **define-domain-language** | Type and field naming must match business language |
| **plan-tests** | Choose first failing spec (mutation vs query vs resolver unit) |
| **write-tests** | Full TDD cycle for resolvers and mutations |
| **security-check** | Auth, introspection disable, query depth/complexity limits |