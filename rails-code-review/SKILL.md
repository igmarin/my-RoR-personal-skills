---
name: rails-code-review
description: Review Ruby on Rails code following "The Rails Way" (Obie Fernandez). Use when reviewing Rails PRs, controllers, models, migrations, routes, or when the user asks for a Rails code review or Rails best practices.
---

# Rails Code Review (The Rails Way)

When **reviewing** Rails code, analyze it against the following areas. Report violations and suggestions; use **Critical** / **Suggestion** / **Nice to have** when giving feedback. When **writing** new code, follow **rails-stack-conventions** for style and structure.

## Configuration & Environments

- Use Rails encrypted credentials for secrets — never commit keys
- Environment-specific settings (development, test, production)
- Zeitwerk autoloading and strict naming conventions
- Logging configured per environment

## Routing

- RESTful: use `resources` and `resource`
- Nest at most one level; prefer shallow nesting
- Named routes; routing concerns for shared patterns
- Constraints for route validation

## Controllers

- Action order: index, show, new, edit, create, update, destroy
- Strong parameters with `permit`; one attribute per line when many
- `before_action` for auth/authz with `only:` or `except:`
- Skinny controllers — no business logic
- `respond_to` for multiple formats

## Action View

- Partials and layouts; avoid logic in views (use helpers/presenters)
- `content_for` / `yield` for flexible layouts
- Prefer Rails helpers over raw HTML

## ActiveRecord Models

- Model structure order: extends, includes, constants, attributes, enums, associations, delegations, validations, scopes, callbacks, class methods, instance methods
- `inverse_of` on associations to avoid extra queries
- Enums with explicit values: `enum status: { active: 0, inactive: 1 }`
- `validates` with options (not `validates_presence_of`)
- Scopes for reusable queries; avoid excessive callbacks (prefer explicit services)
- `has_secure_password` for password auth

## ActiveRecord Associations

- `dependent:` for orphaned records
- `through:` for many-to-many; polymorphic when appropriate
- STI only when justified

## ActiveRecord Queries

- Avoid N+1: use `includes`, `preload`, or `eager_load`
- Prefer `exists?` over `present?` for existence
- `pluck` for attribute arrays; `select` to limit columns
- `find_each` with `batch_size` for large sets
- `insert_all` for bulk inserts; `load_async` for parallel queries (Rails 7+)
- Transactions for atomic operations

## Migrations

- Reversible migrations; prefer `change`
- Indexes for WHERE/JOIN columns; foreign key constraints
- `add_reference` with `foreign_key: true`

## Validations

- Built-in: presence, uniqueness, format, length, numericality
- Conditional: `if:` / `unless:`; custom validators for complex rules
- `validates_with` for reusable validation classes

## I18n

- User-facing strings via I18n; locale files by feature/page
- Lazy lookup in views: `t('.title')`
- Locale from user preferences or request headers

## Cookies & Sessions

- No complex objects in session
- Signed/encrypted cookies for sensitive data
- Flash for temporary messages

## Security

- Strong params; parameterized queries (no SQL injection)
- No unnecessary `raw` / `html_safe` (XSS)
- Keep `protect_from_forgery`; use CSP headers
- Mask sensitive data in logs; keep gems updated

## Caching & Performance

- Fragment caching; Russian doll for nested structures
- Low-level cache: `Rails.cache`; ETags for HTTP caching
- Use `EXPLAIN` for slow queries

## Background Jobs

- Active Job; appropriate backend (Sidekiq, Resque)
- Jobs idempotent and retriable; handle failures

## Testing (RSpec)

- BDD; descriptive `describe` / `context`
- `let` / `let!`; FactoryBot
- Test validations and associations; shared examples; mock external services
