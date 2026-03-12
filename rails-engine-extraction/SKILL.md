---
name: rails-engine-extraction
description: Extract existing Rails application code into a reusable engine incrementally. Use when moving a feature from a host app into an engine, reducing coupling, defining adapters, preserving behavior during extraction, or planning safe extraction slices.
---
# Rails Engine Extraction

Use this skill when the task is to move existing code out of a Rails app and into an engine.

Prefer incremental extraction over big-bang rewrites. Preserve behavior first, then improve design.

## Extraction Order

1. Identify the bounded feature to extract.
2. List hard dependencies on the host app.
3. Define the future engine boundary and host contract.
4. Move stable domain logic first.
5. Add adapters or configuration seams for host-owned dependencies.
6. Move controllers, routes, views, or jobs only after the seams are clear.
7. Keep regression coverage green throughout.

## What To Extract First

Start with:

- POROs and services
- value objects
- policies or query objects
- engine-local models with limited host coupling

Delay these until later:

- direct references to host app models
- authentication integration
- route ownership changes
- asset and UI integration

## Coupling Strategy

Replace hardcoded host dependencies with:

- configuration values
- adapter objects
- service interfaces
- notifications or callbacks

Do not move code into an engine if it still depends on many private host internals.

## Safe Slice Checklist

- one coherent responsibility
- minimal new public API
- tests proving no regression in host behavior
- clear follow-up slice after the first move

## Red Flags

- engine references many top-level host constants
- extraction introduces circular dependencies
- initialization order becomes fragile
- the dummy app passes but the real host app contract is still implicit

## Examples

**First slice (move PORO, no host model yet):**

Extract `Pricing::Calculator` from `app/services/pricing/calculator.rb` into the engine. It only depends on `LineItem` and `Discount` — move those to the engine as engine models in the same slice, or keep them in the host and inject via an adapter in a later slice.

**Adapter for host dependency:**

```ruby
# In engine: use config instead of hardcoded User
# Before (in app): OrderCreator.new(current_user).call
# After (in engine): OrderCreator.new(MyEngine.config.current_user_provider.call(request)).call
# Host sets in initializer: MyEngine.config.current_user_provider = ->(req) { req.env["current_user"] }
```

**Red flag:** Extracting `OrdersController` in the first slice while it still calls `User`, `Tenant`, and `AuditLog` — too many host ties. Extract the service/PORO first and introduce adapters, then move the controller.

## Output Style

When asked to extract code:

1. Describe the boundary you are extracting.
2. List host dependencies that must be abstracted.
3. Propose the smallest safe first slice.
4. Add regression tests before and after the move.
