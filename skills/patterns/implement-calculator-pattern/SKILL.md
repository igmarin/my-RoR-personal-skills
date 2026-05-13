---
name: implement-calculator-pattern
license: MIT
description: >
  Use when building variant-based calculators with a single entry point that
  picks the right implementation (Strategy + Factory), or when adding a no-op
  fallback (Null Object). Generates variant-based calculator classes, implements
  SERVICE_MAP routing, and scaffolds RSpec tests per variant. Trigger words:
  design pattern, Ruby, dispatch table, polymorphism, no-op default, variant
  calculator, strategy pattern, factory pattern, null object pattern.
metadata:
  version: 1.0.0
  user-invocable: "true"
---

# Implement Calculator Pattern

One API for the client: `Calculator::Factory.for(entity).calculate`. The factory picks the strategy; NullService handles unknown variants safely.

## Quick Reference

| Component | Responsibility |
|-----------|---------------|
| **Factory** | Dispatch to correct service class via SERVICE_MAP; fall back to NullService |
| **BaseService** | Guard with `should_calculate?`; delegate to `compute_result` |
| **NullService** | Always returns nil safely — never raises |
| **Concrete** | Override `should_calculate?` (add variant check on top of `super`) and `compute_result` |

## HARD-GATE

```text
Tests Gate Implementation

For each component (Factory → BaseService → NullService → Concrete):
1. Write the spec — contexts per variant, plus the NullService path
2. Run it — verify it fails because the component does not exist yet
3. Implement the component — minimum code to make the spec pass
4. Run again — confirm green, then proceed to the next component
```

## Core Process

1. Create the **Factory**. No qualifying context or unknown variant → `NullService`.
2. Create the **BaseService**. Define `calculate` that delegates to `compute_result` if `should_calculate?` is true.
3. Create the **NullService**. Always return false for `should_calculate?` and nil for `compute_result`.
4. Create **Concrete** services. Override `should_calculate?` and `compute_result`. Always call `super` in `should_calculate?`.
5. Run the full test suite.
6. Verify the **Single entry point rule:** `Factory.for(entity)` is the **only** permitted access path.

## Extended Resources

**File Structure**
```
app/services/<calculator_name>/
├── factory.rb
├── base_service.rb
├── null_service.rb
├── standard_service.rb
├── premium_service.rb
```

**1. Factory**
```ruby
# frozen_string_literal: true

module PricingCalculator
  class Factory
    SERVICE_MAP = {
      'standard' => StandardPricingService,
      'premium'  => PremiumPricingService
    }.freeze

    def self.for(order)
      plan = order.plan
      return NullService.new(order) unless plan&.active?

      service_class = SERVICE_MAP[plan.name] || NullService
      service_class.new(order)
    end
  end
end
```

**2. BaseService**
```ruby
# frozen_string_literal: true

module PricingCalculator
  class BaseService
    def initialize(order)
      @order = order
    end

    def calculate
      return nil unless should_calculate?

      compute_result
    end

    private

    def should_calculate?
      @order.present?
    end

    def compute_result
      raise NotImplementedError, "#{self.class}#compute_result must be implemented"
    end
  end
end
```

**3. NullService**
```ruby
# frozen_string_literal: true

module PricingCalculator
  class NullService < BaseService
    private

    def should_calculate?
      false
    end

    def compute_result
      nil
    end
  end
end
```

**4. Concrete Service Example**
```ruby
# frozen_string_literal: true

module PricingCalculator
  class StandardPricingService < BaseService
    private

    def should_calculate?
      super && @order.plan.name == 'standard'
    end

    def compute_result
      @order.base_price * 1.0
    end
  end
end
```

**5. Usage**
```ruby
price = PricingCalculator::Factory.for(order).calculate
```

**6. Tests (RSpec)**
Each spec suite must cover: inactive plan, nil plan, each named variant, and unknown variant. Mirror the same context structure across all concrete services.

**Pitfalls**
| Pitfall | Fix |
|---------|-----|
| SERVICE_MAP key mismatch | Verify keys match exactly what is stored in the database — typos cause silent NullService fallbacks |
| Missing NullService spec | Always add a spec context for unknown/nil variants or tests will never catch the fallback regression |
| Direct service instantiation (`ServiceClass.new(entity)`) | Route through `Factory.for(entity)` — it is the sole public entry point; direct instantiation bypasses the NullService safety net |
| Forgetting `super` in concrete `should_calculate?` | Always call `super` — skipping it removes the base nil/presence guard |

- [assets/examples.md](assets/examples.md)
- [IMPLEMENTATION.md](IMPLEMENTATION.md)
- [TESTING.md](TESTING.md)

## Output Style

1. **Single entry point** — Show `Calculator::Factory.for(entity).calculate` as the only public access path.
2. **Component list** — Factory, BaseService, NullService, and every concrete strategy class.
3. **Dispatch map** — `SERVICE_MAP` keys, concrete classes, and unknown/nil fallback to NullService.
4. **Guard behavior** — Base guard, concrete `super` call, and NullService no-op behavior.
5. **Tests-first proof** — Spec order and commands for Factory, BaseService, NullService, and concrete services.
6. **Variant coverage** — Named variants, inactive/nil plan, and unknown variant contexts.
7. Language — Must be in English unless explicitly requested otherwise.

## Integration

| Skill | When to chain |
|-------|---------------|
| **test-service** | For complete Factory, BaseService, NullService, and concrete strategy specs |
| **create-service-object** | For naming conventions, YARD docs, and `frozen_string_literal` baseline |
