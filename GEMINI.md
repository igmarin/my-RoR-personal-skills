# Rails Agent Skills — Gemini CLI Context

This plugin provides a library of specialized Rails development skills. When a task arrives, check if any skill applies and read it before responding.

## CROSS-CUTTING MANDATE: Tests Gate Implementation

```text
THIS IS NON-NEGOTIABLE AND APPLIES TO EVERY SKILL THAT PRODUCES CODE.

WORKFLOW: PRD → TASKS → TESTS → IMPLEMENTATION → YARD → DOCS → CODE REVIEW → PR

Tests are a GATE. Implementation code CANNOT be written until:
1. The test EXISTS
2. The test has been RUN
3. The test FAILS for the right reason (feature missing, not a typo)
```

Wrote implementation code before the test? Delete it. Start over. No exceptions.

## Primary Workflow: TDD Feature Loop

For Gemini CLI, **workflow chaining is the primary mechanism**. Skills are building blocks — workflows are the story. The most common daily workflow:

```text
plan-tests → write failing test
  → [CHECKPOINT: Test Feedback — confirm behavior, boundary, edge cases]
  → [CHECKPOINT: Implementation Proposal — confirm approach before coding]
  → implement (minimal code to pass test) → refactor
  → [GATE: Linters + Full Test Suite]
  → write-yard-docs
  → code-review (self-review)
  → respond-to-review (when feedback is received)
  → re-review if Critical findings were addressed
  → PR
```

See [docs/workflow-guide.md](docs/workflow-guide.md) for all workflow diagrams.

## Available Skills

Skills are located in subdirectories of this plugin. Read the relevant `SKILL.md` before responding to any task that matches.

### Planning & Tasks
| Skill | Use when... |
|-------|-------------|
| `create-prd` | User asks to plan a feature or write requirements |
| `generate-tasks` | User asks for implementation steps or task breakdown |
| `plan-tickets` | User wants tickets from a plan |

### Rails Code Quality
| Skill | Use when... |
|-------|-------------|
| `code-review` | Reviewing Rails PRs, controllers, models, migrations — giving a review |
| `respond-to-review` | Received review feedback and need to evaluate, respond, or implement it |
| `review-architecture` | Reviewing app structure, boundaries, fat models/controllers |
| `security-check` | Checking auth, params, XSS, CSRF, SQLi |
| `review-migration` | Planning or reviewing database migrations |
| `apply-stack-conventions` | Writing new Rails code for PostgreSQL + Hotwire + Tailwind stack |
| `apply-code-conventions` | Daily coding checklist: DRY/YAGNI/PORO/CoC/KISS, linter as style SoT, per-path rules |
| `implement-background-job` | Adding or reviewing background jobs |
| `implement-graphql` | Building or reviewing GraphQL APIs with graphql-ruby |
| `implement-authorization` | Adding or reviewing roles/permissions (Pundit, CanCanCan, policy objects) |
| `optimize-performance` | Investigating N+1s, slow queries, profiling, caching, query plans |
| `version-api` | Versioning REST APIs, deprecation policies, v1/v2 routing |
| `seed-database` | Designing seeds vs fixtures for dev/test data |
| `implement-hotwire` | Turbo/Stimulus integration, frames, streams |

### DDD & Domain Modeling
| Skill | Use when... |
|-------|-------------|
| `define-domain-language` | Clarifying domain terms before modeling or refactoring |
| `review-domain-boundaries` | Reviewing bounded contexts and language leakage |
| `model-domain` | Mapping DDD concepts to Rails models, services, value objects |

### Ruby Patterns
| Skill | Use when... |
|-------|-------------|
| `create-service-object` | Creating service classes with `.call` pattern |
| `integrate-api-client` | Integrating external APIs (Auth/Client/Fetcher/Builder) |
| `implement-calculator-pattern` | Building variant-based calculators |
| `write-yard-docs` | Writing or reviewing YARD docs |

### Context & Setup
| Skill | Use when... |
|-------|-------------|
| `load-context` | Before any code/spec/PRD in an existing Rails codebase — loads schema, routes, nearest patterns, surfaces ambiguity |
| `setup-environment` | First-time dev environment setup — Docker, env vars, database, test suite |

### Testing
| Skill | Use when... |
|-------|-------------|
| `write-tests` | Writing, reviewing, or cleaning up RSpec tests |
| `plan-tests` | Choosing the best first failing spec for a Rails change |
| `triage-bug` | Turning a bug report into a failing spec and fix plan |
| `test-service` | Testing service objects |

### Rails Engines
| Skill | Use when... |
|-------|-------------|
| `create-engine` | Creating or scaffolding a Rails engine |
| `test-engine` | Setting up dummy app and engine specs |
| `review-engine` | Reviewing an existing engine |
| `release-engine` | Preparing an engine release |
| `document-engine` | Writing engine documentation |
| `create-engine-installer` | Creating install generators |
| `extract-engine` | Extracting code from host app to engine |
| `upgrade-engine` | Ensuring cross-version compatibility |
| `generate-api-collection` | Creating or updating Postman collections for REST API endpoints (not GraphQL) |

### Refactoring
| Skill | Use when... |
|-------|-------------|
| `refactor-code` | Restructuring code while preserving behavior |

### Workflow Skills (Orchestrators)
| Skill | Use when... |
|-------|-------------|
| `tdd-workflow` | Full TDD feature cycle: test → implement → review → PR |
| `review-workflow` | Systematic PR review: review → deep dive → response |
| `setup-workflow` | New project setup: context → onboarding → CI/CD |
| `quality-workflow` | Pre-PR quality check: conventions → refactor → docs |
| `engine-workflow` | Engine development: author → test → review → release |

## Skill Priority

1. **TDD always** — `write-tests` applies whenever code is produced
2. **Planning first** — `create-prd`, `generate-tasks` (optionally `plan-tickets`)
3. **Domain discovery next** — `ddd-*` skills when domain is the hard part
4. **Process skills** — `refactor-code`
5. **Domain skills** — `rails-*`, `ruby-*` for specific implementation

## Typical Workflows

**TDD Feature Loop** *(primary)*:
`plan-tests` → **[Test Feedback checkpoint]** → **[Implementation Proposal checkpoint]** → implement → **[Linters + Suite gate]** → `write-yard-docs` → `code-review` → `respond-to-review` (on feedback) → PR

**New feature:**
`create-prd` → `generate-tasks` → *TDD Feature Loop*

**DDD-first:**
`create-prd` → `define-domain-language` → `review-domain-boundaries` → `model-domain` → `generate-tasks` → *TDD Feature Loop*

**Code review + response:**
`code-review` → `respond-to-review` (on feedback) → re-review if Critical items addressed

**Bug fix:**
`triage-bug` → `plan-tests` → **[GATE: failing reproduction spec]** → fix → verify test passes

**GraphQL feature:**
`define-domain-language` → `implement-graphql` → *TDD Feature Loop* → `security-check`

**New engine:**
`engine-workflow` (or atomic: `create-engine` → **[GATE: engine specs]** → implement → `document-engine`)

**Project setup:**
`setup-workflow` (context → onboarding → CI/CD)

**Quality before PR:**
`quality-workflow` (conventions → refactor → docs)

**Refactoring:**
`refactor-code` → **[GATE: characterization tests pass]** → refactor → verify tests still pass

## Project Constraints

- **The `evals/` directory is READ-ONLY.** These files contain intentional bugs, missing documentation, or non-standard patterns used to evaluate agent performance. Never "fix" or "improve" files in `evals/` unless explicitly instructed to update a test case scenario.
- **Service response format:** Always return `{ success: bool, response: { ... } }` — data under `response:`, errors under `response: { error: { message: '...' } }`.

**Ruby files:** Every `.rb` file begins with `# frozen_string_literal: true`.

**Error logging:** Every `rescue StandardError` block MUST log message AND backtrace: `Rails.logger.error(e.message)` and `Rails.logger.error(e.backtrace.first(5).join("\n"))`.

**YARD @raise:** Add one `@raise` tag per exception class for every public method that can raise — even internally rescued exceptions.

**RSpec time tests:** Time-dependent behavior MUST use `travel_to` — never stub `Time.now` or set dates in the past.

**Background jobs:** Always include `retry_on ExceptionClass, wait: :polynomially_longer, attempts: N` for transient errors and `discard_on` for permanent errors (e.g. `ActiveRecord::RecordNotFound`).

**Task lists (generate-tasks):** Task 0.0 ALWAYS creates the feature branch. Each implementation task MUST have four sub-tasks: (a) write spec, (b) run spec — verify fails, (c) implement, (d) run spec — verify passes. Always include a Relevant Files section.

## Output Language

Generated artifacts (YARD docs, Postman collections, READMEs, task descriptions) must be in **English** unless the user explicitly requests another language.

## Eval Strategy

Skills are scored on two axes: **skill-specific criteria** AND **model performance baseline-vs-with-context**. A skill that only beats baseline marginally is under-specified — it should change the model's output meaningfully. See [docs/skill-optimization-guide.md](docs/skill-optimization-guide.md) for the optimization loop and per-skill targets.

## Canonical Reference

For the complete skill category table, workflow chaining rules, and all constraints, see [AGENTS.md](AGENTS.md) — the single source of truth for agent guidance across all platforms.
