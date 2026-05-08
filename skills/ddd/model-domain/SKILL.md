---
name: model-domain
license: MIT
description: >
  Use when modeling Domain-Driven Design concepts in a Ruby on Rails codebase.
  Covers Rails-first mapping of entities, aggregates, value objects, domain
  services, application services, repositories, and domain events without
  over-engineering or fighting Rails conventions.
metadata:
  version: 1.0.0
  user-invocable: "true"
---
# Model Domain

**Core principle:** Model real domain pressure, not textbook DDD vocabulary.

## HARD-GATE

```text
DO NOT introduce repositories, aggregates, or domain events just to sound "DDD".
DO NOT fight Rails defaults when a normal model or service expresses the domain clearly.
ALWAYS start from domain invariants, ownership, and lifecycle before choosing a pattern.
```

## Modeling Order

1. **List domain concepts:** Entities, values, policies, workflows, and events from the ubiquitous language.
2. **Identify invariants:** Decide which object or boundary must keep each rule true.
3. **Choose the aggregate entry point:** Name the object that guards state transitions and consistency.
4. **Place behavior:** Keep behavior on the entity/aggregate when cohesive; extract a domain service only when behavior spans multiple concepts cleanly.
5. **Pick Rails homes:** Choose the simplest location that matches the boundary and repo conventions.
6. **Verify with tests:** Hand off to `plan-tests` and `write-tests` before implementation.

## Rails-First Mapping

| DDD concept | Rails-first default | Avoid by default | Typical home |
|-------------|---------------------|------------------|--------------|
| Entity | ActiveRecord model when persisted identity matters | Extra wrapper object with no added meaning | `app/models/` |
| Value object | PORO — immutable, equality by value | Shoving logic into helpers or primitives | `app/models/` or near the domain |
| Aggregate root | The model that guards invariants and is the single entry point | Splitting invariants across multiple models | `app/models/` |
| Domain service | PORO for behavior spanning multiple entities | Arbitrary model chosen just to hold code | `app/services/` |
| Application service | Orchestrator for one use case | Fat controller or callback chains | `app/services/` |
| Repository | Only when a real persistence boundary exists beyond ActiveRecord | Repositories for every query | `app/repositories/` (rare) |
| Domain event | Explicit object when multiple downstream consumers justify it | Callback-driven hidden side effects | `app/events/` or project namespace |

## Output Style

When using this skill, return for each domain concept:

1. **Domain concept** — name from the ubiquitous language
2. **Recommended modeling choice** — entity, value object, service, etc.
3. **Suggested Rails home** — file path
4. **Invariant or ownership reason** — why this boundary
5. **Patterns to avoid** — what not to reach for
6. **Next skill to chain** — `generate-tasks`, `plan-tests`, etc.

## Examples

### Value Object — Money (Quick Reference)

```ruby
# app/models/money.rb
class Money
  attr_reader :amount_cents, :currency
  def initialize(amount_cents, currency = "USD")
    @amount_cents, @currency = Integer(amount_cents), currency.upcase.freeze
    freeze
  end
  def ==(other) = other.is_a?(Money) && amount_cents == other.amount_cents && currency == other.currency
end
```

See [assets/examples.md](assets/examples.md) for detailed Application Service and Domain Event examples.

## Common Mistakes

| Mistake | Reality |
|---------|---------|
| Turning every concept into a service | Many behaviors belong naturally on entities or value objects |
| Creating repositories for all reads and writes | ActiveRecord already provides a strong default persistence boundary |
| Treating aggregates as folder names only | Aggregates exist to protect invariants, not to look architectural |
| Adding domain events for one local callback | Events justify their cost only when multiple downstream consumers exist |
| Pattern choice justified only with "DDD says so" | The reason must be an invariant, ownership boundary, or clear coordination need |
| Same invariant enforced from multiple unrelated entry points | Single aggregate root guards state transitions — one entry point per invariant |
| New abstractions that increase indirection without clarifying ownership | If the boundary is unclear after modeling, the abstraction is premature |

## Integration

| Skill | When to chain |
|-------|---------------|
| **define-domain-language** | When the terms are not clear enough to model yet |
| **review-domain-boundaries** | When the modeling problem is really a context boundary problem |
| **generate-tasks** | After the tactical design is clear and ready for implementation planning |
| **plan-tests** | When the next step is choosing the best first failing spec |
| **apply-code-conventions** | When validating the modeling choice against Rails simplicity and repo conventions |

## Assets

- [assets/examples.md](assets/examples.md)
- [assets/modeling_template.md](assets/modeling_template.md)
