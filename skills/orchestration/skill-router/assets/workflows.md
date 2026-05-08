# Additional Workflows

Extended workflow definitions for specialized scenarios. See SKILL.md for the primary workflows (TDD Feature Loop, Feature standard, Bug fix).

---

## Feature (DDD-first)

skills/context/load-context → skills/planning/create-prd → skills/ddd/define-domain-language → skills/ddd/review-domain-boundaries → skills/ddd/model-domain → skills/planning/generate-tasks → skills/workflows/tdd-workflow

Use when: Domain modeling is required before implementation, or the feature involves complex bounded contexts.

---

## Code review + response

Use `skills/workflows/review-workflow`:
skills/workflows/review-workflow → (orchestrates review → deep dive → response → merge)

---

## New engine

skills/engines/create-engine → **[GATE: engine specs fail]** → implement → skills/engines/document-engine

---

## Refactoring

skills/code-quality/refactor-code → **[GATE: characterization tests pass on current code]** → refactor → verify still pass

---

## GraphQL

skills/ddd/define-domain-language → skills/api/implement-graphql → skills/workflows/tdd-workflow → skills/code-quality/security-check
