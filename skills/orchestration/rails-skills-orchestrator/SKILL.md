---
name: rails-skills-orchestrator
license: MIT
description: >
  Entry point for Rails tasks. Routes to specialized skills (testing, code review,
  engines, DDD, patterns) and enforces TDD discipline. Use when scope is unclear.
  Trigger: where do I start, not sure how to approach this, multi-step Rails task.
keywords: rails, ruby, tdd, testing, code-review, engines, ddd, orchestration, entry-point
---

# Rails Skills Orchestrator

Routes to the correct specialized skill for any Ruby on Rails task and enforces the Tests Gate Implementation mandate across all code-producing work.

When a task arrives, identify the matching skill from the tables below and **name it explicitly as the next skill to use** before responding further. Generated artifacts (YARD docs, Postman collections, READMEs) must be in **English** unless the user explicitly requests another language.

## CROSS-CUTTING MANDATE: Tests Gate Implementation

Non-negotiable across every code-producing skill. Workflow: **PRD → TASKS → TESTS → IMPLEMENTATION → YARD → DOCS → CODE REVIEW → PR**. No implementation code until the test exists, has been run, and fails for the right reason (*feature missing*, not config/syntax). See the TDD Feature Loop below for the per-behavior cycle and checkpoints.

## Available Skills

### Planning & Tasks

| Skill | Use when... |
| ----- | ----------- |
| **create-prd** | Planning a feature or writing requirements |
| **generate-tasks** | Breaking a PRD into implementation tasks |
| **ticket-planning** | Creating tickets from a plan |

### Rails Code Quality

| Skill | Use when... |
| ----- | ----------- |
| **rails-code-review** | Reviewing Rails PRs, controllers, models, migrations, or queries |
| **rails-review-response** | Evaluating or implementing code review feedback |
| **rails-architecture-review** | Reviewing structure, boundaries, fat models/controllers |
| **rails-security-review** | Auditing for XSS, CSRF, SQL injection, auth flaws |
| **rails-migration-safety** | Planning or reviewing production-safe migrations |
| **rails-stack-conventions** | Writing Rails code for PostgreSQL + Hotwire + Tailwind stack |
| **rails-code-conventions** | Daily coding checklist: DRY/YAGNI/PORO/CoC/KISS, linters, structured logging |
| **rails-background-jobs** | Adding or reviewing background jobs |
| **rails-graphql-best-practices** | Building or reviewing GraphQL APIs with `graphql-ruby` |
| **rails-authorization-policies** | Adding or reviewing roles/permissions (Pundit, CanCanCan, policy objects) |
| **rails-performance-optimization** | Investigating N+1s, slow queries, profiling, caching, query plans |
| **rails-api-versioning** | Versioning REST APIs, deprecation policies, v1/v2 routing |
| **rails-database-seeding** | Designing seeds vs fixtures for dev/test data |
| **rails-frontend-hotwire** | Turbo/Stimulus integration, frames, streams |

### DDD & Domain Modeling

| Skill | Use when... |
| ----- | ----------- |
| **ddd-ubiquitous-language** | Clarifying domain terms or building a shared business glossary |
| **ddd-boundaries-review** | Reviewing bounded contexts and language leakage |
| **ddd-rails-modeling** | Mapping DDD concepts to Rails models, services, and value objects |

### Ruby Patterns

| Skill | Use when... |
| ----- | ----------- |
| **ruby-service-objects** | Creating service classes with `.call` pattern |
| **ruby-api-client-integration** | Integrating external APIs with the layered Auth/Client/Fetcher/Builder pattern |
| **strategy-factory-null-calculator** | Building variant-based calculators with SERVICE_MAP dispatch |
| **yard-documentation** | Writing or reviewing YARD docs for Ruby classes and public methods |

### Context & Setup

| Skill | Use when... |
| ----- | ----------- |
| **rails-context-engineering** | Before any code/spec/PRD in an existing Rails codebase — load schema, routes, nearest patterns, surface ambiguity |
| **rails-project-onboarding** | First-time dev environment setup — Docker, env vars, database, test suite |

### Testing

| Skill | Use when... |
| ----- | ----------- |
| **rspec-best-practices** | Writing, reviewing, or cleaning up RSpec tests; TDD discipline for all implementation |
| **rails-tdd-slices** | Choosing the best first failing spec for a Rails change |
| **rails-bug-triage** | Turning a bug report into a reproduction spec and fix plan |
| **rspec-service-testing** | Testing service objects (`spec/services/`) |

### Rails Engines

| Skill | Use when... |
| ----- | ----------- |
| **rails-engine-author** | Creating or scaffolding a Rails engine |
| **rails-engine-testing** | Setting up dummy app and engine specs |
| **rails-engine-reviewer** | Reviewing an existing engine |
| **rails-engine-release** | Preparing an engine release |
| **rails-engine-docs** | Writing engine documentation |
| **rails-engine-installers** | Creating install generators |
| **rails-engine-extraction** | Extracting host app code into an engine |
| **rails-engine-compatibility** | Ensuring cross-version compatibility |
| **api-rest-collection** | Generating or updating Postman collections for REST endpoints |

### Refactoring

| Skill | Use when... |
| ----- | ----------- |
| **refactor-safely** | Restructuring code while preserving behavior |

## Skill Priority

When multiple skills could apply: TDD → Planning → Domain discovery → Process (refactor-safely) → Domain implementation (rails-\*, ruby-\*). Use rails-tdd-slices when the first failing spec is not obvious.

## Typical Workflows

Sub-skills are invoked by stating their name as the next skill to apply, e.g. *"Next skill: skills/testing/rails-tdd-slices"*, before proceeding with that skill's instructions.

**TDD Feature Loop** *(primary daily workflow)*:
skills/context/rails-context-engineering → skills/testing/rails-tdd-slices → **[Test Feedback checkpoint]** → **[Implementation Proposal checkpoint]** → implement → **[Linters + Suite gate]** → skills/patterns/yard-documentation → rails-code-review → skills/code-quality/rails-review-response (on feedback) → PR

**Feature (standard):** skills/context/rails-context-engineering → create-prd → generate-tasks → *TDD Feature Loop*

**Feature (DDD-first):** skills/context/rails-context-engineering → create-prd → skills/ddd/ddd-ubiquitous-language → skills/ddd/ddd-boundaries-review → skills/ddd/ddd-rails-modeling → generate-tasks → *TDD Feature Loop*

**Code review + response:** rails-code-review → skills/code-quality/rails-review-response (on feedback) → re-review if Critical items addressed

**Bug fix:** skills/testing/rails-bug-triage → skills/testing/rails-tdd-slices → **[GATE: reproduction spec fails]** → fix → verify passes

**New engine:** skills/engines/rails-engine-author → **[GATE: engine specs fail]** → implement → skills/engines/rails-engine-docs

**Refactoring:** skills/code-quality/refactor-safely → **[GATE: characterization tests pass on current code]** → refactor → verify still pass

**GraphQL:** skills/ddd/ddd-ubiquitous-language → skills/api/rails-graphql-best-practices → *TDD Feature Loop* → skills/code-quality/rails-security-review

## Assets

- [assets/examples.md](assets/examples.md)
