---
name: rails-engine-author
license: MIT
description: >
  Use when creating, scaffolding, or refactoring a Rails engine. Covers engine
  types (Plain, Railtie, Engine, Mountable), namespace isolation, host-app
  contract definition, and recommended file structure.
metadata:
  user-invocable: "true"
  version: 1.0.0
---
# Rails Engine Author

Use this skill when the task is to create, scaffold, or refactor a Rails engine.

Favor maintainability over cleverness. A good engine has a narrow purpose, a clear host-app integration story, and a small public API.

Keep this skill focused on structure and design. Use adjacent skills for installer details, deep test coverage, release workflow, or documentation work.

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

1. The root file is minimal: requires version, configuration, and engine only.
2. Public-facing engines use isolate_namespace.
3. The root module exposes .configure yielding a Configuration object.
4. Host model references stay configurable strings (e.g. "User"), never ::User.
5. Engine code never auto-applies migrations at boot (no config.paths['db/migrate'] or ActiveRecord::Migrator).
6. The host contract is documented per the Host App Contract section.
7. Initializers are idempotent and safe in development reloads.
8. Assets and generators are namespaced and idempotent.
9. Dummy app exists and integration tests pass.
10. Mount the engine in the dummy app and verify routes load correctly.
11. Search engine files for hard-coded host constants (::User, ::Employee).
12. Search engine boot code for migration auto-apply patterns (db:migrate, ActiveRecord::Migrator, config.paths['db/migrate']).
13. Expose integration seams through services, adapters, or hooks — not direct host constants.
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
| rails-engine-testing | Dummy app setup, integration tests, regression coverage |
| rails-engine-reviewer | Findings-first audits, structural review |
| rails-engine-docs | README, installation guide, host-app contract documentation |
| rails-engine-installers | Generator-heavy setup, install scripts, copy migrations |
| api-rest-collection | When the engine exposes HTTP endpoints (generate/update Postman collection) |

## Assets

- [assets/examples.md](assets/examples.md)
- [assets/release-checklist.md](assets/release-checklist.md)
