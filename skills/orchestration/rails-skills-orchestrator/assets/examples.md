# rails-skills-orchestrator — Routing Examples

Extended routing examples covering common, ambiguous, and edge-case scenarios. Each example shows the user prompt, skill match rationale, and the full workflow chain.

---

## Single-Skill Routes (Clear Intent)

### 1. Write PRD

> **User:** "Write a PRD for adding multi-tenant support to the billing service."
>
> **Match:** Explicit planning request with clear scope.
>
> **Chain:** `rails-context-engineering` → `create-prd`
>
> **Next skill: skills/context/rails-context-engineering**

### 2. Triage Bug

> **User:** "Triage a 500 error observed in orders#create when item_id is nil."
>
> **Match:** Concrete bug with reproduction path. Do not reach for `rails-performance-optimization` or `rails-code-review` until the bug is isolated.
>
> **Chain:** `rails-bug-triage` → `skills/workflows/rails-tdd-loop`
>
> **Next skill: skills/testing/rails-bug-triage**

### 3. Review Rails Engine

> **User:** "Review my mountable engine for host-app integration risks and namespace leakage."
>
> **Match:** Engine-scoped review, not a general code review.
>
> **Chain:** `rails-engine-reviewer`
>
> **Next skill: skills/engines/rails-engine-reviewer**

### 4. Create Service Object

> **User:** "I need a service to sync users from our Salesforce CRM every night."
>
> **Match:** Service extraction + external API integration. Two skills apply.
>
> **Chain:** `rails-context-engineering` → `ruby-api-client-integration` (API layer) → `ruby-service-objects` (orchestration service) → `rspec-best-practices` (spec)
>
> **Next skill: skills/context/rails-context-engineering**

### 5. Safe Migration

> **User:** "I need to add a column to users but we can't afford downtime."
>
> **Match:** Production-safe schema change.
>
> **Chain:** `rails-migration-safety`
>
> **Next skill: skills/infrastructure/rails-migration-safety**

---

## Multi-Concern Routes (Workflow Chains)

### 6. Full Feature from Scratch

> **User:** "I want to add a payment feature but I'm not sure where to start."
>
> **Match:** Scope unclear, no existing PRD, vague starting point.
>
> **Chain:** `rails-context-engineering` → `create-prd` → `generate-tasks` → `rails-tdd-slices` → `skills/workflows/rails-tdd-loop`
>
> **Next skill: skills/context/rails-context-engineering**

### 7. Multi-Concern PR

> **User:** "I have a PR that adds a new controller, changes the Order model, adds a migration, and introduces a service object."
>
> **Match:** Multi-concern changeset. Decompose before reviewing.
>
> **Chain:** `rails-context-engineering` → `rails-code-review` (controller + model) → `rails-migration-safety` (migration) → `ruby-service-objects` (service pattern check) → `rails-security-review` (if auth/input handling touched)
>
> **Next skill: skills/context/rails-context-engineering**

### 8. DDD-First Feature

> **User:** "We're building an invoicing module and need to get the domain language right before coding."
>
> **Match:** Domain modeling before implementation.
>
> **Chain:** `rails-context-engineering` → `ddd-ubiquitous-language` → `ddd-boundaries-review` → `ddd-rails-modeling` → `create-prd` → `generate-tasks` → `skills/workflows/rails-tdd-loop`
>
> **Next skill: skills/context/rails-context-engineering**

### 9. GraphQL API Feature

> **User:** "Build a GraphQL API for our product catalog with filtering and pagination."
>
> **Match:** GraphQL-specific, not REST. Do not use `api-rest-collection`.
>
> **Chain:** `ddd-ubiquitous-language` → `rails-graphql-best-practices` → `skills/workflows/rails-tdd-loop` → `rails-security-review`
>
> **Next skill: skills/ddd/ddd-ubiquitous-language**

### 10. New Rails Engine

> **User:** "Extract our notification system into a mountable engine."
>
> **Match:** Engine extraction from existing code, not greenfield authoring.
>
> **Chain:** `rails-context-engineering` → `rails-engine-extraction` → `rails-engine-testing` → `rails-engine-docs` → `rails-engine-release`
>
> **Next skill: skills/context/rails-context-engineering**

---

## Ambiguous & Low-Context Routes

### 11. Vague Request — No Clear Skill

> **User:** "Help me improve this Rails app."
>
> **Match:** No specific concern. Start with context discovery to identify what needs work.
>
> **Chain:** `rails-context-engineering` → (assess findings) → route to appropriate skill
>
> **Next skill: skills/context/rails-context-engineering**

### 12. Ambiguous — Architecture vs Code Review

> **User:** "This codebase feels messy, can you take a look?"
>
> **Match:** "Messy" suggests structural issues, not a specific PR. Use architecture review, not code review.
>
> **Chain:** `rails-context-engineering` → `rails-architecture-review` → (if refactoring needed) `refactor-safely`
>
> **Next skill: skills/context/rails-context-engineering**

### 13. Ambiguous — Which Test Skill?

> **User:** "I need to add tests for the billing module."
>
> **Match:** "Add tests" is ambiguous. If the user doesn't know *what* to test first → `rails-tdd-slices`. If they know what but not *how* → `rspec-best-practices`.
>
> **Disambiguation:** Ask: "Do you know which behavior to test first, or should we figure that out?" If unclear, default to `rails-tdd-slices`.
>
> **Next skill: skills/testing/rails-tdd-slices**

### 14. Ambiguous — Performance vs Bug

> **User:** "The checkout page is really slow sometimes."
>
> **Match:** Could be a performance issue or a latent bug. "Sometimes" suggests intermittent, which leans bug. Clarify, but default to `rails-bug-triage` if there's no profiling data yet.
>
> **Disambiguation:** Ask: "Is it consistently slow or only under specific conditions?" Default to bug triage if intermittent.
>
> **Next skill: skills/testing/rails-bug-triage**

### 15. Zero Context — New to Project

> **User:** "I just joined this team, where do I start?"
>
> **Match:** Onboarding, not planning or coding.
>
> **Chain:** `rails-project-onboarding` → `rails-context-engineering`
>
> **Next skill: skills/context/rails-project-onboarding**

---

## Edge Cases

### 16. User Asks for Tickets Explicitly

> **User:** "Create Jira tickets from this task list."
>
> **Match:** Explicit ticket request. Do not generate tickets unless explicitly asked.
>
> **Chain:** `ticket-planning`
>
> **Next skill: skills/planning/ticket-planning**

### 17. Security Concern Mid-Feature

> **User:** "Wait, does this endpoint have proper authorization?"
>
> **Match:** Security concern interrupting a feature workflow. Route to security review, then return to previous workflow.
>
> **Chain:** `rails-security-review` → (if policies needed) `rails-authorization-policies` → resume prior workflow
>
> **Next skill: skills/code-quality/rails-security-review**

### 18. Refactoring with No Tests

> **User:** "I want to refactor this controller but there are no tests."
>
> **Match:** Refactoring requires characterization tests first. TDD gate applies.
>
> **Chain:** `rails-context-engineering` → `rspec-best-practices` (write characterization tests) → **[GATE: tests pass on current code]** → `refactor-safely`
>
> **Next skill: skills/context/rails-context-engineering**

### 19. Background Job Design

> **User:** "We need to process invoice PDFs asynchronously."
>
> **Match:** Background job with potential service object and external integration.
>
> **Chain:** `rails-context-engineering` → `rails-background-jobs` → `ruby-service-objects` (if job logic is complex) → `rspec-best-practices`
>
> **Next skill: skills/context/rails-context-engineering**

### 20. Hotwire Frontend Work

> **User:** "Make this form submit without a full page reload using Turbo."
>
> **Match:** Frontend-specific, Hotwire/Turbo integration.
>
> **Chain:** `rails-context-engineering` → `rails-frontend-hotwire` → `skills/workflows/rails-tdd-loop` (system specs)
>
> **Next skill: skills/context/rails-context-engineering**
