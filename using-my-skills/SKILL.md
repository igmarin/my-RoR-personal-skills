---
name: using-my-skills
description: >
  Use when starting any conversation involving Rails development. Establishes how to find
  and use available skills, requiring skill invocation before responding when a skill
  might apply.
---

# Using My Skills

This skill library provides specialized knowledge for Ruby on Rails development. When a skill might apply to the current task, invoke it before responding.

## Available Skills

### Planning & Tasks

| Skill | Use when... |
|-------|-------------|
| **create-prd** | User asks to plan a feature, write requirements, or create a PRD |
| **generate-tasks** | User asks for implementation steps, task breakdown, or checklist |

### Rails Code Quality

| Skill | Use when... |
|-------|-------------|
| **rails-code-review** | Reviewing Rails PRs, controllers, models, migrations, queries |
| **rails-architecture-review** | Reviewing app structure, boundaries, fat models/controllers |
| **rails-security-review** | Checking auth, params, redirects, XSS, CSRF, SQLi |
| **rails-migration-safety** | Planning or reviewing database migrations |
| **rails-stack-conventions** | Writing new Rails code (style, naming, patterns) |
| **rails-background-jobs** | Adding or reviewing background jobs |

### Ruby Patterns

| Skill | Use when... |
|-------|-------------|
| **ruby-service-objects** | Creating service classes with .call pattern |
| **ruby-api-client-integration** | Integrating external APIs (Auth/Client/Fetcher/Builder) |
| **strategy-factory-null-calculator** | Building variant-based calculators |

### Testing

| Skill | Use when... |
|-------|-------------|
| **rspec-best-practices** | Writing, reviewing, or cleaning up RSpec tests |
| **rspec-service-testing** | Testing service objects (spec/services/) |

### Rails Engines

| Skill | Use when... |
|-------|-------------|
| **rails-engine-author** | Creating or scaffolding a Rails engine |
| **rails-engine-testing** | Setting up dummy app and engine specs |
| **rails-engine-reviewer** | Reviewing an existing engine |
| **rails-engine-release** | Preparing an engine release |
| **rails-engine-docs** | Writing engine documentation |
| **rails-engine-installers** | Creating install generators |
| **rails-engine-extraction** | Extracting code from host app to engine |
| **rails-engine-compatibility** | Ensuring cross-version compatibility |

### Refactoring

| Skill | Use when... |
|-------|-------------|
| **refactor-safely** | Restructuring code while preserving behavior |

## Skill Priority

When multiple skills could apply:

1. **Planning skills first** (create-prd, generate-tasks) — determine WHAT to build
2. **Process skills second** (refactor-safely, rspec-best-practices) — determine HOW to approach
3. **Domain skills third** (rails-*, ruby-*) — guide specific implementation

## How to Use

1. When a task arrives, check if any skill applies.
2. If a skill applies, read it and follow its instructions.
3. Skills override default behavior but **user instructions always take priority**.
4. If a skill has a HARD-GATE, you must not skip it.
5. When done with a task, check the skill's Integration table for follow-up skills.

## Typical Workflows

**New feature:** create-prd -> generate-tasks -> rails-stack-conventions -> rspec-best-practices -> rails-code-review

**Code review:** rails-code-review + rails-security-review + rails-architecture-review

**New engine:** rails-engine-author -> rails-engine-testing -> rails-engine-docs -> rails-engine-installers

**Refactoring:** refactor-safely -> rspec-best-practices -> rails-code-review

**New service object:** ruby-service-objects -> rspec-service-testing
