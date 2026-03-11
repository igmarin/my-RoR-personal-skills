---
name: strategy-factory-null-calculator
description: Implement a family of domain calculators using Strategy + Factory + Null Object. Use when building variant-based calculators (e.g. by program type, tenant, plan), when you need a single entry point that picks the right implementation, or when adding a "no-op" fallback (Null Object).
---

# Strategy + Factory + Null Object Calculator Pattern

Implements a **variant-based calculator** system (by program type, tenant, plan, etc.) with a single entry point, concrete strategies, and a no-op fallback (Null Object).

## When to use this pattern

- The result depends on a **variant** of the context (program, tenant, plan type, etc.).
- Logic per variant differs and you want it in separate classes.
- You need a **safe fallback** when no supported variant exists (return `nil` or default without raising).
- The client should use **one API**: `SomethingCalculator::Factory.for(entity).calculate`.

## Example domain (Animal / Shelter)

The skill uses this example to stay domain-agnostic:

- **Context entity**: `Animal` (has `shelter` and e.g. `intake_date`).
- **Variant**: the `Shelter` has a “program” (e.g. `shelter_programs` with names like `"standard"`, `"premium"`, `"foster"`).
- **Calculation**: “eligibility date” for adoption based on the shelter’s program.
- **Services**: `StandardEligibilityService` (intake_date + 30 days), `PremiumEligibilityService` (intake_date + 14 days), `NullService` (always `nil`).

Adapt names and relationships to your domain (e.g. Catalog/Warehouse/Plan, Tenant/Subscription, etc.).

---

## File structure

```
app/services/<calculator_name>/
├── factory.rb           # Entry point: Factory.for(entity)
├── base_service.rb      # Abstract base class
├── null_service.rb      # Fallback that returns nil
├── standard_service.rb  # Concrete strategy (e.g. "standard")
├── premium_service.rb   # Another strategy (e.g. "premium")
└── README.md            # Optional: system documentation
```

---

## 1. Module and Factory

- All classes live under one **module** (e.g. `EligibilityDateCalculator`).
- **Factory** exposes a class method: `.for(entity)`.
- The entity must expose the **variant** (e.g. `entity.shelter`, `shelter.shelter_programs.pluck(:name)` or `shelter.program_type`).

```ruby
# frozen_string_literal: true

module EligibilityDateCalculator
  class Factory
    SERVICE_MAP = {
      'standard' => StandardEligibilityService,
      'premium'  => PremiumEligibilityService
    }.freeze

    # @param animal [Animal] entity with shelter and intake_date
    # @return [BaseService] the chosen service instance
    def self.for(animal)
      shelter = animal.shelter
      return NullService.new(animal) unless shelter&.participates_in_eligibility_program?

      program_names = shelter.shelter_programs.pluck(:name)
      service_class = SERVICE_MAP.find { |name, _| program_names.include?(name) }&.last || NullService
      service_class.new(animal)
    end
  end
end
```

Typical Factory rules:

- If there is no qualifying context (shelter nil or does not participate) → `NullService`.
- If the variant is not in `SERVICE_MAP` → `NullService`.
- If multiple supported variants exist, define **preference order** in `SERVICE_MAP` (first match wins) or explicit logic.

---

## 2. BaseService

- **Constructor**: `initialize(entity)` and store `@entity` and derived data (e.g. `@shelter = entity.shelter`).
- **Public method**: e.g. `#calculate` returning the computed value or `nil`.
- Flow in `#calculate`:
  1. Return `nil` if `should_calculate?` is false.
  2. If the calculation depends on a field (e.g. `intake_date`), return `nil` when it’s blank.
  3. Call the method implemented by subclasses (e.g. `compute_result` or `compute_eligibility_date`).

Methods subclasses override:

- **`should_calculate?`** (private): Does this strategy apply for this entity? Default: check that context exists and “qualifies” (e.g. shelter participates in program).
- **`compute_result`** (private): Concrete calculation logic. Default: `nil`.

```ruby
# frozen_string_literal: true

module EligibilityDateCalculator
  class BaseService
    attr_reader :animal, :shelter

    def initialize(animal)
      @animal = animal
      @shelter = animal.shelter
    end

    # @return [Date, nil]
    def calculate
      return nil unless should_calculate?
      intake_date = animal.intake_date
      return nil if intake_date.blank?

      compute_result(intake_date)
    end

    private

    def should_calculate?
      shelter&.participates_in_eligibility_program?
    end

    def compute_result(_intake_date)
      nil
    end
  end
end
```

If a variant uses **a different data source** (e.g. `Time.current` instead of an entity date), that subclass can override `#calculate` and call its own `compute_result` with no arguments, keeping the rest of the pattern.

---

## 3. NullService

- Inherits from `BaseService`.
- Overrides `should_calculate?` to always return `false`.
- No need to override `compute_result`.

```ruby
# frozen_string_literal: true

module EligibilityDateCalculator
  class NullService < BaseService
    private

    def should_calculate?
      false
    end
  end
end
```

---

## 4. Concrete services

- Inherit from `BaseService`.
- **`should_calculate?`**: call `super` and add the variant condition (e.g. “shelter has program ‘standard’”).
- **`compute_result`**: implement the formula (e.g. intake_date + 30 days).

Example with date thresholds (e.g. a “compliance change date”):

- Define constants for the cutoff date and parameters (months, etc.).
- In `compute_result`, branch on the date and return the appropriate value.

Keep YARD docs (`@param`, `@return`) on public methods and on private methods that are part of the pattern contract.

---

## 5. Usage from the client

```ruby
# Single line to get the value
eligibility_date = EligibilityDateCalculator::Factory.for(animal).calculate

# Or inspect which strategy was used
calculator = EligibilityDateCalculator::Factory.for(animal)
calculator.class # => StandardEligibilityService, PremiumEligibilityService, or NullService
calculator.calculate
```

---

## 6. Tests (RSpec)

- **Factory**: describe `.for` with contexts for each branch:
  - shelter `nil` → NullService.
  - shelter does not participate in program → NullService.
  - unsupported program (not in SERVICE_MAP) → NullService.
  - each supported variant → correct concrete service.
  - multiple variants present → service per preference order.
- **BaseService**: no variant / nil context → `#calculate` nil; default `compute_result` returns nil.
- **NullService**: `#calculate` always nil; `should_calculate?` always false.
- **Concrete services**: `should_calculate?` true only when variant applies; `compute_result` returns expected value for dates/rules; edge cases (cutoff dates, blank data).

Use factories (FactoryBot) to build `animal`, `shelter`, `shelter_programs` and set attributes per context. For calculations using `Time.current`, use `travel_to` in specs.

---

## Responsibility summary

| Component   | Responsibility |
|-------------|-----------------|
| **Factory** | Choose the class from entity and its variant; return that instance or NullService. |
| **BaseService** | Common `#calculate` flow, guards (`should_calculate?`, required data), call to `compute_result`. |
| **NullService** | Never compute; return nil safely. |
| **Concrete** | Variant condition in `should_calculate?` and business logic in `compute_result`. |

Adapt module name, entity, variant, and public method (`calculate` vs `eligible_at`, etc.) to your domain; the Factory + Base + Null + concrete strategies structure stays the same.

---

## Related skills

- **ruby-service-objects:** Same conventions (YARD, constants, `frozen_string_literal`, response style). Use for orchestrators and general service structure.
- **rspec-service-testing** and **rspec-best-practices:** For testing Factory, BaseService, NullService, and concrete strategies (contexts per variant, `travel_to` for time-based calculations).
