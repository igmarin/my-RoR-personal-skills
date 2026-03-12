---
name: rspec-best-practices
description: Write and review maintainable, deterministic RSpec tests for Ruby and Rails codebases. Use when designing specs, choosing spec types, fixing flaky tests, improving factories, or refactoring test suites for clarity, speed, and confidence.
---

# RSpec Best Practices

Use this skill when the task is to write, review, or clean up RSpec tests.

Prefer behavioral confidence over implementation coupling. Good specs are readable, deterministic, and cheap to maintain.

## Core Rules

- Test observable behavior, not private method structure.
- Use the highest-value spec type for the behavior under test.
- Prefer request specs over controller specs for Rails endpoints.
- Keep factories minimal and explicit.
- Stub external boundaries, not internal code paths, unless isolation is the goal.
- Avoid time, randomness, and global state leaks between examples.

## Spec Selection

- **model or unit specs** for cohesive domain objects
- **request specs** for controller and API behavior
- **system specs** only for critical end-to-end UI flows
- **job specs** for enqueue and execution behavior
- **feature-specific integration specs** when wiring matters more than isolation

**Monolith vs engine:** For a normal Rails app (monolith), this skill applies as-is. When the project under test is a **Rails engine**, use the **rails-engine-testing** skill for dummy-app setup, engine request/routing/generator specs, and host integration; keep using this skill for general RSpec style and structure.

## Coverage

- Cover typical cases and edge cases: invalid inputs, errors, boundary conditions.
- Consider all relevant scenarios for each method or behavior.

## Readability and Clarity

- Use clear, descriptive names for `describe`, `context`, and `it` blocks.
- Prefer **expect** syntax for assertions.
- Keep test code concise; avoid unnecessary complexity or duplication.

## Structure

- **describe** for the class, module, or behavior; **context** for scenarios (e.g. "when valid", "when user is missing").
- Use **subject** for the object under test when it reduces repetition.
- Mirror source paths under `spec/` (e.g. `app/models/user.rb` → `spec/models/user_spec.rb`).

## Test Data

- Use **let** and **let!** for test data; keep setup minimal and necessary.
- Prefer **factories** (e.g. FactoryBot) over fixtures.

## Independence and Isolation

- Each example should be independent; avoid shared mutable state between tests.
- Use **mocks** for external services (APIs, etc.) and **stubs** for predefined return values. Isolate the unit under test, but avoid over-mocking; prefer testing real behavior when practical.

## Avoid Repetition

- Use **shared_examples** / **shared_context** for behavior repeated across contexts.
- Extract repeated setup or expectations into helpers or custom matchers when it improves clarity.

## Common Smells

- brittle assertions on internal calls instead of outcomes
- excessive `let!`, nested contexts, or shared state (prefer `let` over `let!` when the value isn’t needed for setup; this aligns with common RuboCop-RSpec style)
- factories creating large graphs by default
- time-sensitive tests without clock control
- broad stubbing that hides real regressions
- examples that cover multiple behaviors and fail ambiguously

## Review Checklist

- Is the spec type appropriate for the risk?
- Would the test still pass if the implementation changed but behavior stayed correct?
- Are setup and assertions easy to read?
- Is the factory data minimal?
- Is flakiness risk controlled?

## Output Style

When asked to improve tests:

1. Identify the most important missing behavioral coverage.
2. Reduce brittleness before adding more assertions.
3. Prefer simpler setup over clever RSpec abstractions.

## For New Developers

- Write tests that are easy to follow: clear intent, minimal assumptions about the codebase.
- Add brief comments or descriptions where the scenario or assertion is non-obvious.

---

For **service object** specs (`spec/services/`), also apply the patterns from the **rspec-service-testing** skill (e.g. instance_double, FactoryBot hash factories, shared_examples for services).
