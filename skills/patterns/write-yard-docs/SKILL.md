---
name: write-yard-docs
license: MIT
description: >
  Use when writing or reviewing inline documentation for Ruby code. Every public method
  MUST include param, return, and raise tags. For self.call methods, the return tag MUST
  specify the return type and structure (e.g., return [Hash] with :success and :response
  keys). List each exception separately with its own raise tag. Trigger words: YARD, inline docs,
  method documentation, API docs, public interface, rdoc, return tag, raise tag.
metadata:
  version: 1.0.0
  user-invocable: "true"
---
# Write YARD Docs

Use this skill when documenting Ruby classes and public methods with YARD.

**Core principle:** Every public class and public method has YARD documentation so the contract is clear and tooling can generate API docs.

## HARD-GATE: After implementation

```
After any feature or fix that adds or changes public Ruby API (classes, modules, public methods):

1. Add or update YARD on those surfaces before the work is considered done.
2. All YARD text must be in English unless user explicitly requests otherwise.

Task lists from generate-tasks MUST include explicit YARD sub-tasks after implementation.
```

## Tag Reference

Canonical examples for common tags: [EXAMPLES.md](./EXAMPLES.md) — includes `@param`, `@return`, and `@raise` tag usage.

| Scope | Rule |
|-------|------|
| Classes | One-line summary; optional `@since` if version matters |
| Public methods | All tags required unless explicitly inapplicable: `@param`, `@option` (for hash params), `@return`, `@raise` |
| Public `initialize` | Add `@param` for constructor inputs when initialization is part of the public contract |
| Private methods | Document only if behavior is non-obvious; same tag rules |

## Standard Tags with Examples

### Class-level

```ruby
# Responsible for validating and executing animal transfers between shelters.
# @since 1.2.0
module AnimalTransfers
  class TransferService
```

### Method-level: params, options, return, and example

Use `@option` for every valid key in hash params. Include at least one `@example` on `.call` or the main public entry point.

```ruby
# Performs the transfer and returns a standardized response.
# @param params [Hash] Transfer parameters
# @option params [Hash] :source_shelter Shelter hash with :shelter_id
# @option params [Hash] :target_shelter Target shelter with :shelter_id
# @return [Hash] Result with :success and :response keys
# @example Basic usage
#   result = TransferService.call(source_shelter: { shelter_id: 1 }, target_shelter: { shelter_id: 2 })
#   result[:success] # => true
def self.call(params)
```

### Method-level: exceptions

Document `@raise` for every exception a method can raise — **even if the method rescues it internally**. One tag per exception class.

```ruby
# Processes the billing update for the given plan.
# @param plan_id [Integer] ID of the target plan
# @raise [InvalidPlanError] when the plan does not exist or is inactive
# @raise [PaymentGatewayError] when the payment provider rejects the charge
# @return [Hash] Result with :success and :response keys
def self.call(plan_id:)
```

### Nullable / conditional returns

```ruby
# Validates source and target shelters and returns the first validation error.
# @param source_id [Integer] Source shelter ID
# @param target_id [Integer] Target shelter ID
# @return [nil, String] nil if valid, error message otherwise
def self.validate_shelters!(source_id, target_id)
```

## Anti-pattern

```ruby
# Updates billing.  (Too vague; no @param/@return/@raise)
def self.call(plan_id:)
```

## Pitfalls

| Pitfall | What to do |
|---------|------------|
| Documenting only the class, not public methods | Callers need param types and return shape for every public method |
| Skipping `@option` for hash params | Without it, consumers don't know valid keys or types |
| Only one `@raise` for multiple exceptions | List EVERY exception type — one `@raise` per class, even if rescued internally |
| YARD text in a language other than English | Write in English unless the user explicitly requests otherwise |

## Inline tagged notes

YARD documents the contract; tagged notes (`TODO:` / `FIXME:` / `HACK:` / `NOTE:` / `OPTIMIZE:`) document the *why* on the same code. Every tag carries actionable context (owner, ticket, next step); naked tags fail review. See [references/tagged-notes.md](references/tagged-notes.md) and **apply-code-conventions**.

## Verification

Run validation before considering documentation complete:

1. `yard stats --list-undoc`
2. `yard doc`
3. If output shows undocumented public surfaces you changed, update YARD and re-run.

For advanced tags (`@abstract`, `@deprecated`, `@api private`, `@yield`, `@overload`) see [ADVANCED_TAGS.md](./ADVANCED_TAGS.md).

## Integration

| Skill | When to chain |
|-------|----------------|
| **create-service-object** | Implementing or documenting service objects |
| **integrate-api-client** | Documenting API client layers (Auth, Client, Fetcher, Builder) |
| **document-engine** | Documenting engine public API or extension points |
| **code-review** | Reviewing that public interfaces are documented |
| **generate-tasks** | Generated task lists include YARD tasks after implementation |
