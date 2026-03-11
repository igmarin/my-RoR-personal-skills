---
name: rspec-best-practices
description: Apply RSpec best practices when generating tests. Use when writing or generating RSpec tests for models, requests, features, services, or when the user asks for tests, specs, or test coverage.
---

# RSpec Best Practices

When **generating RSpec tests**, follow these practices so specs are comprehensive, readable, and maintainable.

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

## For New Developers

- Write tests that are easy to follow: clear intent, minimal assumptions about the codebase.
- Add brief comments or descriptions where the scenario or assertion is non-obvious.

---

For **service object** specs (`spec/services/`), also apply the patterns from the **rspec-service-testing** skill (e.g. instance_double, FactoryBot hash factories, shared_examples for services).
