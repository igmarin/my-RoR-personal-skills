---
name: rails-stack-conventions
description: Apply Rails, PostgreSQL, Hotwire (Turbo/Stimulus), and Tailwind CSS conventions when writing or generating code. Use when building features, controllers, views, models, or when the user works with this stack (Rails, Hotwire, Tailwind, PostgreSQL).
---

# Rails Stack Conventions

When **writing or generating** code for this project, follow these conventions. Stack: Ruby on Rails, PostgreSQL, Hotwire (Turbo + Stimulus), Tailwind CSS.

## Code Style and Structure

- Concise, idiomatic Ruby; follow Rails conventions
- OOP and functional patterns as appropriate; prefer iteration and modularization over duplication
- Descriptive names: `user_signed_in?`, `calculate_total`
- Structure: MVC, concerns, helpers per Rails conventions

## Naming

- **snake_case:** files, methods, variables
- **CamelCase:** classes, modules
- Rails naming for models, controllers, views

## Ruby and Rails

- Use Ruby 3.x features when helpful (pattern matching, endless methods)
- Prefer Rails built-in helpers and APIs
- Use ActiveRecord effectively; avoid N+1 (eager loading)

## Syntax and Formatting

- Follow [Ruby Style Guide](https://rubystyle.guide/)
- Use expressive Ruby: `unless`, `||=`, `&.`
- **Single quotes** for strings unless interpolation is needed

## Error Handling and Validation

- Exceptions for exceptional cases, not control flow
- Proper error logging and user-friendly messages
- ActiveModel validations in models
- Controllers: handle errors and set appropriate flash messages

## UI and Styling

- **Hotwire:** Turbo and Stimulus for dynamic, SPA-like behavior
- **Tailwind CSS** for responsive layout and styling
- View helpers and partials to keep views DRY

## Performance

- Effective DB indexing; caching (fragment, Russian Doll) where useful
- Eager loading; optimize with `includes`, `joins`, `select` as needed

## Architecture

- RESTful routes; concerns for shared behavior
- **Service objects** for non-trivial business logic
- **Background jobs** (e.g. Sidekiq) for long-running work

## Testing

- RSpec or Minitest; TDD/BDD style
- FactoryBot (or equivalent) for test data

## Security

- Auth/authz (e.g. Devise, Pundit); strong parameters
- Guard against XSS, CSRF, SQL injection

## Reference

Follow the [official Rails guides](https://guides.rubyonrails.org/) for routing, controllers, models, views, and related topics. When **reviewing** existing code, use **rails-code-review** for a structured checklist.
