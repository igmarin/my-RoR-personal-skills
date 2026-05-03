# Additional Workflows

Extended workflow definitions for specialized scenarios. See SKILL.md for the primary workflows (TDD Feature Loop, Feature standard, Bug fix).

---

## Feature (DDD-first)

skills/context/rails-context-engineering → skills/planning/create-prd → skills/ddd/ddd-ubiquitous-language → skills/ddd/ddd-boundaries-review → skills/ddd/ddd-rails-modeling → skills/planning/generate-tasks → skills/workflows/rails-tdd-loop

Use when: Domain modeling is required before implementation, or the feature involves complex bounded contexts.

---

## Code review + response

Use `skills/workflows/rails-review-flow`:
skills/workflows/rails-review-flow → (orchestrates review → deep dive → response → merge)

---

## New engine

skills/engines/rails-engine-author → **[GATE: engine specs fail]** → implement → skills/engines/rails-engine-docs

---

## Refactoring

skills/code-quality/refactor-safely → **[GATE: characterization tests pass on current code]** → refactor → verify still pass

---

## GraphQL

skills/ddd/ddd-ubiquitous-language → skills/api/rails-graphql-best-practices → skills/workflows/rails-tdd-loop → skills/code-quality/rails-security-review
