---
name: create-engine
license: MIT
description: >
  Use when creating, scaffolding, or refactoring a Rails engine. Covers engine
  types (Plain, Railtie, Engine, Mountable), namespace isolation, host-app
  contract definition, and recommended file structure.
metadata:
  user-invocable: "true"
  version: 1.1.0
---
# Create Engine

Use this skill when the task is to create, scaffold, or refactor a Rails engine.

A good engine has a narrow purpose, a clear host-app integration story, and a small public API. Keep this skill focused on structure and design. Use adjacent skills for installer details, deep test coverage, release workflow, or documentation work.

## Quick Reference

| Engine Type | When to Use |
|-------------|-------------|
| Plain gem | No Rails hooks or app directories needed; pure Ruby library |
| Railtie | Needs Rails initialization hooks but not models/controllers/routes/views |
| Engine | Needs Rails autoload paths, initializers, migrations, assets, jobs, or host integration |
| Mountable engine | Needs its own routes, controllers, views, assets, and namespace boundary |

## HARD-GATE

```text
Before engine work is complete, confirm all of the following:

STRUCTURE & CONTRACT:
1. Root file requires only version, configuration, and engine.
2. Public engines use isolate_namespace; configuration exposes .configure block.
3. Host model references are configurable strings (e.g., "User"), never hard-coded ::User.
4. Host-app contract is documented (see Host App Contract section).

SAFETY CHECKS:
5. Engine code never auto-applies migrations at boot (no db:migrate, ActiveRecord::Migrator, or config.paths['db/migrate'] in initializers).
6. Initializers are idempotent and safe in development reloads.
7. Assets and generators are namespaced and idempotent.

VERIFICATION COMMANDS:
8. Dummy app exists: `ls spec/dummy` or `ls test/dummy` should return the app directory.
9. Integration tests pass: `bundle exec rspec` or `bundle exec rake test` exits 0.
10. Routes load correctly: `bundle exec rails routes` inside dummy app shows engine routes.
11. No hard-coded host constants: `grep -r "::User\|::Employee" lib/ app/` returns nothing.
12. No migration auto-apply patterns: `grep -r "db:migrate\|ActiveRecord::Migrator\|config.paths\['db/migrate'\]" lib/` returns nothing.
```

## Workflow

1. Identify the engine type before writing code. Scaffold with the correct generator:
   ```bash
   rails plugin new my_engine --mountable   # mountable engine
   rails plugin new my_engine --full        # full engine (non-isolated)
   rails plugin new my_engine               # plain Railtie/gem
   ```
2. Define the host-app contract (see Host App Contract section).
3. Create the minimal engine structure. **Checkpoint:** `bundle exec rake` inside the engine must pass.
4. Implement features behind the namespace. **Checkpoint:** mount engine in dummy app routes and verify with `bundle exec rails routes`.
5. Plan and write minimum integration coverage through the dummy app.
6. Document the host-app contract clearly enough for follow-on work.

If the user does not specify the engine type, infer it from the requested behavior and say which type you chose.

## Recommended Structure

Use a structure close to this:

```text
my_engine/
  lib/
    my_engine.rb
    my_engine/version.rb
    my_engine/engine.rb
    generators/
  app/
    controllers/
    models/
    jobs/
    views/
  config/
    routes.rb
    locales/
  db/
    migrate/
  spec/ or test/
    dummy/
```

Keep the root module small:
- `lib/my_engine.rb`: requires version, engine, and public configuration entrypoints.
- `lib/my_engine/engine.rb`: engine class, initializers, autoload/eager-load behavior, asset/config hooks.
- `lib/my_engine/version.rb`: version only.

## Host App Contract

This is the single authoritative definition of the engine's integration surface. Define it before implementation and keep it updated throughout.

- **What the host app must add:** mount route, initializer, migrations, credentials, background jobs, or assets.
- **What the engine exposes:** models, controllers, helpers, configuration, rake tasks, generators, middleware, or events.
- **Which extension points are supported:** config block, adapter interface, callbacks, or service objects.

Prefer one explicit configuration surface, for example:

```ruby
MyEngine.configure do |config|
  config.user_class = "User"
  config.audit_events = true
end
```

Do not scatter configuration across unrelated constants and initializers.

## Testing Expectations

Minimum coverage through the dummy app (not just isolated classes):

- Engine integration tests through the mounted dummy app.
- Routing/request tests for all mountable engine endpoints.
- Configuration tests for each supported host customization option.
- Generator tests when install/setup generators exist.

## Examples

**Minimal root module:**

```ruby
# lib/my_engine.rb
require "my_engine/version"
require "my_engine/configuration"
require "my_engine/engine"

module MyEngine
  class << self
    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield(configuration)
    end
  end
end
```

**Minimal mountable engine class:**

```ruby
# lib/my_engine/engine.rb
module MyEngine
  class Engine < ::Rails::Engine
    isolate_namespace MyEngine

    config.generators do |g|
      g.test_framework :rspec
      g.fixture_replacement :factory_bot
    end
  end
end
```

**Routes namespaced under engine:**

```ruby
# config/routes.rb
MyEngine::Engine.routes.draw do
  root to: 'dashboard#index'
  resources :widgets, only: %i[index show]
end
```

## Optional Reference Pattern

For a reusable starter layout and file stubs, read [reference.md](reference.md).

## Integration

| Skill | When to chain |
|-------|----------------|
| test-engine | Dummy app setup, integration tests, regression coverage |
| review-engine | Findings-first audits, structural review |
| document-engine | README, installation guide, host-app contract documentation |
| create-engine-installer | Generator-heavy setup, install scripts, copy migrations |
| generate-api-collection | When the engine exposes HTTP endpoints (generate/update Postman collection) |

## Assets & Resources

- **[EXAMPLES.md](EXAMPLES.md)** — Full worked examples including mountable auth engine, background job engine, and common mistakes
- **[TESTING.md](TESTING.md)** — Comprehensive testing guide with dummy app setup, configuration tests, and CI examples
- **[assets/examples.md](assets/examples.md)** — Code snippets and patterns for engine structure
- **[assets/release-checklist.md](assets/release-checklist.md)** — Release preparation checklist
