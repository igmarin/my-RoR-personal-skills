---
name: create-service-object
license: MIT
description: >
  Use when creating or refactoring Ruby service classes in Rails. Covers the
  .call pattern, module namespacing, YARD on self.call AND every public method,
  module README requirement, standardized {success:, response:} response contract,
  orchestrator delegation, transaction wrapping, and error handling conventions.
  Trigger words: service object, .call pattern, app/services, service module,
  service README, response hash, success/response shape, YARD on self.call.
metadata:
  version: 1.0.0
  user-invocable: "true"
---
# Create Service Object

## Quick Reference

| Aspect | Rule |
|--------|------|
| Entry point | `def self.call(...)` → `new(...).call` |
| Validation | Validate inputs at top of `call`; return error hash if invalid |
| Error handling | `rescue` → log + error hash; never re-raise to caller |
| Transactions | Only wrap multi-step DB operations that must be atomic |
| `call` length | ≤20 lines; extract sub-services if longer |
| Scope | Return data only (no HTTP); single responsibility per service |
| SQL | `sanitize_sql` for any dynamic queries |
| Shared logic | Extract validators to class-only services (Pattern 3) |

## HARD-GATE

```text
TESTS GATE IMPLEMENTATION:
EVERY service object MUST have its test written and validated BEFORE implementation.
  1. Write the spec for .call (with contexts for success, error, edge cases)
  2. Run the spec — verify it fails because the service does not exist yet
  3. ONLY THEN write the service implementation
The final artifact must include the spec command and the RED failure message
before implementation. Use the observed failure when available; otherwise show
the exact expected failure class/message for the missing service.
See write-tests for the full gate cycle.
```

## Core Process

1. **Write Spec (Test-First):** Create the RSpec file at `spec/services/<module_name>/<service_name>_spec.rb`. Write tests covering success and error paths for `.call`. Run it to ensure it fails.
2. **Define Service Skeleton:** Create the file at `app/services/<module_name>/<service_name>.rb` with the correct module namespace.
3. **Select Pattern:** Decide if this is a standard `.call → new.call` service, a batch processor, a static class-only helper, or an orchestrator (≤20 lines).
4. **Implement Contract:** Implement `self.call` and `#call` methods. Ensure the response strictly returns `{ success: true, response: { ... } }` or `{ success: false, response: { error: { message: '...' } } }`.
5. **Handle Errors and Logging:** Catch `StandardError` (and domain exceptions). Use `Rails.logger.error` to log both the message and backtrace. Use UPPER_SNAKE_CASE constants for error messages.
6. **Add Documentation:** Add YARD tags to `self.call` and every public method.
7. **Write Module README:** Generate `app/services/<module_name>/README.md` explaining the domain context.

## Core Patterns

### 1. The `.call` Pattern
```ruby
def self.call(params)
  new(params).call
end

def call
  # ... processing ...
  { success: true, response: { data: result } }
rescue StandardError => e
  Rails.logger.error("Processing Error: #{e.message}")
  Rails.logger.error(e.backtrace.join("\n"))
  { success: false, response: { error: { message: ERROR_MESSAGE } } }
end
```

### 2. Batch Processing + Per-Item Rescue (Partial Success)
```ruby
def call
  results = @items.each_with_object({ successful: [], failed: [] }) do |item, acc|
    # process...
  rescue StandardError => e
    Rails.logger.error("Unexpected item error: #{e.message}")
    acc[:failed] << { sku: item[:sku], error: e.message }
  end
  { success: true, response: results }
end
```

### 3. Class-only Services (Static Methods)
When no instance state is needed, use ONLY class methods.

```ruby
class Orders::QuantityValidator
  def self.call(quantity:)
    return { success: false, response: { error: { message: INVALID_QUANTITY } } } unless quantity.positive?

    { success: true, response: { valid: true } }
  end
end
```

Use no `initialize` and no instance variables for validators, formatters, or helpers that only transform their arguments.

### 4. Orchestrator Delegation (≤20-line `call`)
```ruby
def call
  user_result = UserCreationService.call(@params)
  return user_result unless user_result[:success]
  # ... continue ...
end
```

## Extended Resources (Progressive Disclosure)

Load these files only when their specific content is needed:

- **[assets/examples.md](assets/examples.md)** — Detailed examples of the 4 core patterns (Standard, Batch, Static, Orchestrator).
- **[assets/service_skeleton.md](assets/service_skeleton.md)** — Basic starting skeleton.
- **[assets/module_readme_template.md](./assets/module_readme_template.md)** — Template for the mandatory module README.

## Output Style

Every service-object task produces these artifacts:

1. **Service file** — at `app/services/<module_name>/<service_name>.rb` (pragma on line 1, class wrapped in a module matching the directory name).
2. **YARD on `self.call`** — `@param` for every argument, `@return [Hash]`, plus `@raise` for any exception class that can escape. The `self.call` wrapper is documented separately from `#call`.
3. **YARD on every other public method** — same `@param` / `@return` / `@raise` discipline.
4. **Error message constants** — user-facing failure strings live in `UPPER_SNAKE_CASE` constants at the top of the class, never inline inside a `rescue`.
5. **Module README** — at `app/services/<module_name>/README.md`. Required even for single-service modules.
6. **Spec file** — at `spec/services/<module_name>/<service_name>_spec.rb` written and failing BEFORE the implementation (see HARD-GATE).
7. **Response contract proof** — Specs must assert the `success:` and `response:` top-level keys and the meaningful payload shape for the service.
8. **Stateless pattern decision** — State whether instance state is required. If not, use the class-only Pattern 3 shape with no `initialize` and no instance variables.
9. **Language** — YARD, README, and error messages in English unless the user requests otherwise.

For class-only services (Pattern 3), the rules apply to the public class methods being documented; if the class returns a non-service shape (e.g. validators returning `nil` / error string), document that explicitly in YARD and the README.

## Integration

| Skill | When to chain |
|-------|---------------|
| **write-yard-docs** | Writing/reviewing inline docs |
| **integrate-api-client** | External API integrations |
| **implement-calculator-pattern** | Variant-based calculators |
| **test-service** | Testing service objects |
| **write-tests** | General RSpec structure |
| **review-architecture** | Architecture review involving service extraction |
