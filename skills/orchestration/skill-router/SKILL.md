---
name: skill-router
license: MIT
description: >
  Triages and decomposes complex Ruby on Rails requests into ordered sub-tasks, then delegates to
  specialized skills for testing, code review, engines, DDD, and patterns. Enforces TDD discipline
  across all code-producing work. Use when scope is unclear, the best approach is uncertain, or a
  request spans multiple Rails concerns. Trigger: where do I start, help me plan a Rails feature,
  break this down, what's the best approach for this Rails work, not sure how to approach this,
  multi-step Rails task, complex Rails task, what should I do first.
metadata:
  user-invocable: "true"
  version: 1.0.0
  keywords: rails, ruby, tdd, testing, code-review, engines, ddd, orchestration, entry-point
---
# Skill Router

Triages and decomposes any Ruby on Rails request into ordered sub-tasks, then delegates to the correct specialized skill. Enforces the Tests Gate Implementation mandate across all code-producing work.

When a task arrives, identify the matching skill from the tables below and **name it explicitly as the next skill to use** before responding further. Generated artifacts (YARD docs, Postman collections, READMEs) must be in **English** unless the user explicitly requests another language.

**Invocation example:**
> **User:** "I want to add a payment feature but I'm not sure where to start."
>
> **Claude:** "This is a feature request with unclear scope. I'll start by loading the codebase context, then create a PRD.\n\nNext skill: skills/context/load-context"

## CROSS-CUTTING MANDATE: Tests Gate Implementation

Non-negotiable: no implementation code until a test exists, runs, and fails for the right reason (*feature missing*, not config/syntax).

## Core Skills (Most Common)

| Skill | Use when... |
| ----- | ----------- |
| **load-context** | Before any code/spec/PRD in an existing Rails codebase — load schema, routes, nearest patterns, surface ambiguity |
| **write-tests** | Writing, reviewing, or cleaning up RSpec tests; TDD discipline for all implementation |
| **plan-tests** | Choosing the best first failing spec for a Rails change |
| **triage-bug** | Turning a bug report into a reproduction spec and fix plan |
| **code-review** | Reviewing Rails PRs, controllers, models, migrations, or queries — the subject is a specific file or changeset |
| **review-architecture** | Reviewing structure, boundaries, fat models/controllers — the question is about design or system shape, not a specific PR |
| **apply-stack-conventions** | Writing Rails code for PostgreSQL + Hotwire + Tailwind stack |
| **refactor-code** | Restructuring code while preserving behavior |
| **create-prd** | Planning a feature or writing requirements |
| **generate-tasks** | Breaking a PRD into implementation tasks |

## Skill Priority

When multiple skills could apply: TDD → Planning → Domain discovery → Process (refactor-code) → Domain implementation (rails-\*, ruby-\*). Use plan-tests when the first failing spec is not obvious.

**Key disambiguation signals:**
- `review-architecture` vs `code-review`: use architecture-review when the question is about system shape, service boundaries, or design patterns; use code-review when the subject is a concrete PR, file, or changeset.
- `plan-tests` vs `write-tests`: use tdd-slices when the challenge is *which* test to write first; use write-tests when the challenge is *how* to write or improve a test.
- `load-context` before any other code-producing skill in an unfamiliar or existing codebase.

**Fallback for ambiguous requests:** If no clear skill match, default to `load-context` to load codebase context, then re-evaluate based on findings.

## Routing Examples

> **User:** "There's a bug where orders placed at midnight sometimes get the wrong price."
>
> **Match:** Concrete bug report with a reproduction path. See "Bug fix" workflow below.
>
> **Next skill: skills/testing/triage-bug**

---

> **User:** "Help me improve this Rails app."
>
> **Match:** Vague request, no clear skill. Use fallback: load context first.
>
> **Next skill: skills/context/load-context**

---

> **User:** "I have a PR that adds a new controller, changes the Order model, adds a migration, and introduces a service object."
>
> **Match:** Multi-concern changeset. Load context, then decompose into appropriate review skills.
>
> **Next skill: skills/context/load-context**

For additional routing examples (DDD-first features, GraphQL APIs, engines, edge cases), see [assets/examples.md](assets/examples.md).

## Typical Workflows

Sub-skills are invoked by stating their name as the next skill to apply, e.g. *"Next skill: skills/workflows/tdd-workflow"*, before proceeding with that skill's instructions.

**TDD Feature Loop** *(primary daily workflow)* — use `skills/workflows/tdd-workflow`:
skills/context/load-context → **[CHECK: context loaded]** → skills/workflows/tdd-workflow → PR

**Feature (standard):** skills/context/load-context → **[CHECK: context loaded]** → skills/planning/create-prd → **[CHECK: PRD approved]** → skills/planning/generate-tasks → **[CHECK: tasks complete]** → skills/workflows/tdd-workflow

**Bug fix:** skills/testing/triage-bug → **[GATE: reproduction spec fails]** → skills/workflows/tdd-workflow → fix → verify passes

For additional workflows (DDD-first, code review, engines, refactoring, GraphQL), see [assets/workflows.md](assets/workflows.md).

## Assets

- [assets/examples.md](assets/examples.md) — 20+ routing examples covering ambiguous requests, multi-concern PRs, DDD-first features, engines, and edge cases
- [assets/workflows.md](assets/workflows.md) — Extended workflow definitions for DDD-first, code review, engines, refactoring, and GraphQL
- [docs/reference/skill-catalog.md](../../../docs/reference/skill-catalog.md) — Complete skill catalog with trigger words, descriptions, and stage-based navigation
