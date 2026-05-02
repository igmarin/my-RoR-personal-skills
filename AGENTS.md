# Rails Agent Skills — Agent Guidance

This file tells AI agents how to use this repository effectively.

## What This Repository Is

A curated library of 36 AI agent skills for Ruby on Rails development. Each skill encodes specialized workflow knowledge, conventions, and hard gates for a specific Rails domain. Skills are not documentation — they are executable instructions that guide agents through structured workflows.

## How Skills Are Organized

Each skill lives in its own directory with a `SKILL.md` as the entry point. Some skills have supporting files for templates, examples, or extended patterns:

```
skill-name/
├── SKILL.md          # Entry point — always read this first
├── EXAMPLES.md       # Concrete input/output examples (when present)
├── TESTING.md        # Test templates and spec checklists (when present)
├── TASK_TEMPLATES.md # Output templates for generated artifacts (when present)
├── PATTERNS.md       # Extended patterns and factory examples (when present)
└── HEURISTICS.md     # Reference tables too large for inline use (when present)
```

Read `SKILL.md` first. Load supporting files only when the skill links to them and the content is needed.

## Skill Selection

Load the skill that best matches the current task. The bootstrap skill `rails-skills-orchestrator` routes to specialized skills. All skills are organized by category in `skills/<category>/`:

| Category | Path | Skills |
|----------|------|--------|
| **Planning** | `skills/planning/` | `create-prd`, `generate-tasks`, `ticket-planning` |
| **Testing** | `skills/testing/` | `rspec-best-practices`, `rspec-service-testing`, `rails-tdd-slices`, `rails-bug-triage` |
| **Code Quality** | `skills/code-quality/` | `rails-code-review`, `rails-review-response`, `rails-architecture-review`, `rails-security-review`, `rails-stack-conventions`, `rails-code-conventions`, `rails-authorization-policies`, `refactor-safely` |
| **DDD** | `skills/ddd/` | `ddd-ubiquitous-language`, `ddd-boundaries-review`, `ddd-rails-modeling` |
| **Engines** | `skills/engines/` | `rails-engine-author`, `rails-engine-testing`, `rails-engine-reviewer`, `rails-engine-release`, `rails-engine-docs`, `rails-engine-installers`, `rails-engine-extraction`, `rails-engine-compatibility` |
| **Infrastructure** | `skills/infrastructure/` | `rails-migration-safety`, `rails-background-jobs`, `rails-database-seeding`, `rails-performance-optimization`, `rails-api-versioning`, `rails-frontend-hotwire` |
| **API** | `skills/api/` | `api-rest-collection`, `rails-graphql-best-practices`, `ruby-api-client-integration` |
| **Patterns** | `skills/patterns/` | `ruby-service-objects`, `strategy-factory-null-calculator`, `yard-documentation` |
| **Context** | `skills/context/` | `rails-context-engineering`, `rails-project-onboarding` |
| **Orchestration** | `skills/orchestration/` | `rails-skills-orchestrator` |
| **Workflows** | `skills/workflows/` | `rails-tdd-loop`, `rails-review-flow`, `rails-setup-flow`, `rails-quality-flow`, `rails-engines-flow` |

## Non-Negotiable Workflow Rule

**Tests gate implementation.** This applies to every skill that produces code:

```
Write test → Run test → Verify it FAILS for the right reason → Implement → Verify it PASSES
```

Do not write implementation code before the test exists and fails. Every skill that produces code contains a `HARD-GATE` section enforcing this. Honor it.

## Primary Workflows

### Quick Reference

| Goal | Workflow Skill | Atomic Skills |
|------|---------------|---------------|
| Implement feature with TDD | `skills/workflows/rails-tdd-loop` | Full orchestrated cycle |
| Review PR systematically | `skills/workflows/rails-review-flow` | Review → deep dive → response |
| Plan new feature | `skills/planning/create-prd` → `skills/planning/generate-tasks` | Planning only |

### TDD Feature Loop (Recommended)

The default daily workflow — orchestrated by `rails-tdd-loop`:

```
skills/context/rails-context-engineering
  → skills/workflows/rails-tdd-loop (orchestrates below)
    → skills/testing/rails-tdd-slices
    → skills/testing/rspec-best-practices
    → [GATE: test feedback OK]
    → implement
    → [GATE: linters + suite]
    → skills/patterns/yard-documentation
    → skills/code-quality/rails-code-review
    → PR
```

For a full feature from scratch: `skills/context/rails-context-engineering` → `skills/planning/create-prd` → `skills/planning/generate-tasks` → `skills/workflows/rails-tdd-loop`.

See `docs/workflow-guide.md` for all workflow variants (bug fix, GraphQL, engine, migration, refactor, etc.).

## Workflow Chaining

Each skill's **Integration** table names the next skill to load. Follow it. Skills are building blocks; workflows are the unit of value.

## Output Language

All generated artifacts (YARD docs, Postman collections, task lists, PRDs, READMEs, examples) must be in **English** unless the user explicitly requests another language.

## Eval Strategy

Skills are scored on two axes: **skill-specific criteria** AND **model performance baseline-vs-with-context**. A skill that only beats baseline marginally is under-specified — it should change the model's output meaningfully. See `docs/skill-optimization-guide.md` for the optimization loop and per-skill targets.

## Key Constraints

- Do not generate tickets unless the user asks explicitly — `ticket-planning` is optional.
- Do not skip the verify-failure step in the TDD gate.
- Do not add repositories, aggregates, or domain events just because a task looks "DDD" — see `ddd-rails-modeling`.
- Do not use `rails-graphql-best-practices` for REST endpoints or `api-rest-collection` for GraphQL endpoints.
