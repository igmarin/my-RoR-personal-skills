---
name: apply-code-conventions
license: MIT
description: >
  A daily checklist for writing clean Rails code, covering design principles
  (DRY, YAGNI, PORO, CoC, KISS), per-path rules (models, services, workers,
  controllers), structured logging, and comment discipline. Defers style and
  formatting to the project's configured linter(s). Use when writing, reviewing,
  or refactoring Ruby on Rails code, or when asked about Rails best practices,
  clean code, or code quality. Trigger words: code review, refactor, RoR,
  clean code, best practices, Ruby on Rails conventions.
metadata:
  version: 1.0.0
  user-invocable: "true"
---
# Apply Code Conventions

**Style source of truth:** Style and formatting defer to the project's configured linter(s). This skill adds **non-style behavior** and **architecture guidance** only. For Hotwire + Tailwind specifics, see **apply-stack-conventions**.

## Quick Reference

| Topic | Rule |
|-------|------|
| Style/format | Project linter(s) — detect and run as above; do not invent style rules here |
| Principles | DRY, YAGNI, PORO where it helps, CoC, KISS |
| Comments / tags | Explain **why**; tagged notes need actionable context |
| Logging | First arg: static string; second arg: hash with `event:` key; no interpolation; backtrace on errors |
| Deep stacks | Chain **apply-stack-conventions** → domain skills (services, jobs, RSpec) |

## HARD-GATE

```text
TESTS GATE IMPLEMENTATION:
When this skill guides new behavior, the tests gate still applies:
PRD → TASKS → TEST (write, run, fail) → IMPLEMENTATION → …
No implementation code before a failing test. See write-tests.
```

## Core Process

When reviewing or refactoring Rails code, follow this sequence:

1. **Run linter** — Detect config (e.g., `.rubocop.yml`), run the appropriate tool, note absence if none found. Do not invent style rules.
2. **Apply area-specific rules** — Check path patterns (e.g., models, background jobs, controllers) and apply targeted guidance.
3. **Verify tests gate** — Confirm failing tests exist before any new behavior; run specs and checkpoints.
4. **Enforce structured logging** — Ensure all `Rails.logger` calls use static strings + structured hashes with an `event:` key, plus backtrace for errors.
5. **Enforce comment discipline** — Ensure all tags (`TODO:`, `FIXME:`) have actionable context (owner, ticket).
6. **Chain to specialised skills** — Use the Integration table to pull in deeper guidance (security, jobs, specs) as needed.

## Sub-Rules

### Comments and tagged notes
Comment **why**, not **what**. Tagged notes — `TODO:` / `FIXME:` / `HACK:` / `NOTE:` / `OPTIMIZE:` — are MANDATORY in these triggers; every tag carries actionable context. Naked tags (`# TODO: fix this`) fail review.
```ruby
# BAD — naked tag, no context
# TODO: fix this

# GOOD — TODO with next step + dependency
# TODO(jsmith, JIRA-1234): replace TIER_RATES with DB-backed lookup once billing API v2 is stable.
```

### Structured Logging
**MANDATORY SHAPE — every `Rails.logger.*` call uses exactly two positional arguments.**
```ruby
Rails.logger.<level>(static_string_message, { event: "dot.namespaced", ...domain_fields })

# GOOD — error path with backtrace
rescue StandardError => e
  Rails.logger.error("order.processing_failed", {
    event: "order.processing_failed",
    error: e.message,
    backtrace: e.backtrace.first(5).join("\n")
  })
  raise
end
```
- **1st arg (string):** static string literal.
- **2nd arg (hash):** first key is always `event:`.

### Apply by area (path patterns)
| Area | Path pattern | Guidance |
|------|--------------|----------|
| **ActiveRecord performance** | `app/models/**/*.rb` | Eager load in loops; prefer `pluck` / `exists?` / `find_each`. |
| **Controllers** | `app/controllers/**/*_controller.rb` | Strong params; thin actions → services; IDOR / PII → **security-check**. |
| **RSpec** | `spec/**/*_spec.rb` | FactoryBot; `let` > `let!` unless eager setup required. |
| **Service objects** | `app/services/**/*.rb` | Single responsibility; `.call` / injected deps. |

### RSpec and `let_it_be` (test-prof)
Only recommend `let_it_be` if `test-prof` is already in `Gemfile.lock`. Otherwise default to `let`; reach for `let!` only when lazy evaluation would break the example. Don't introduce `test-prof` unless asked.

## Extended Resources (Progressive Disclosure)

Load these files only when their specific content is needed:

- **[assets/checklist.md](assets/checklist.md)** — Use for detailed code review checklists.
- **[assets/snippets.md](assets/snippets.md)** — Use for quick code snippets of common patterns.

## Output Style

When applying conventions, your output MUST include:

1. **Comments** — No what-comments; tagged notes (`TODO:` / `FIXME:` / `HACK:` / `NOTE:` / `OPTIMIZE:`) on every assumption, deferred work, or business-rule constant; every tag carries actionable context (owner, ticket id, deadline).
2. **Logging** — Follow Structured Logging rules: static first arg, hash second arg with `event:`, and a backtrace line on every error rescue.
3. **Linter detection noted** — When reviewing or refactoring, state which linter config you detected (or its absence) before any style claim.
4. **Language** — Must be in English unless explicitly requested otherwise.

## Integration

| Skill | When to chain |
|-------|---------------|
| **apply-stack-conventions** | Stack-specific: PostgreSQL, Hotwire, Tailwind |
| **model-domain** | When domain concepts and invariants need clearer Rails-first modeling choices |
| **create-service-object** | Implementing or refining service objects |
| **implement-background-job** | Workers, queues, retries, idempotency |
| **write-tests** | Spec style, **tests gate** (red/green/refactor), request vs controller specs |
| **security-check** | Controllers, params, IDOR, PII |
| **code-review** | Full PR pass before merge |