---
name: rails-engine-docs
description: Write and maintain documentation for Ruby on Rails engines. Use when creating or updating an engine README, installation guide, configuration docs, host integration examples, mount instructions, migration notes, or extension-point documentation.
---
# Rails Engine Docs

Use this skill when the task is to write or improve documentation for a Rails engine.

Engine docs should optimize for host-app adoption. Readers need to know what the engine does, how to install it, how to configure it, and where the boundaries are.

## Recommended README Shape

1. Purpose
2. Installation
3. Mounting or initialization
4. Configuration
5. Usage examples
6. Migrations or operational steps
7. Extension points
8. Development and testing

## Documentation Rules

- Document required host-app steps before optional customization.
- Keep examples copyable and close to real code.
- Show the minimum working install path first.
- If the engine assumes any host model, job backend, or auth integration, say so explicitly.
- Document upgrade-impacting changes when setup evolves.

## Must-Have Topics

- gem installation
- mount route or initializer setup
- configuration options with defaults
- migration/install generator steps
- supported Rails/Ruby versions if relevant
- testing or local development instructions when contributors are expected

## Common Documentation Gaps

- README explains the engine but not how to install it
- configuration options exist in code but not in docs
- route mounting is implied rather than shown
- migrations are required but not documented
- examples rely on host app context the reader cannot infer

## Examples

**README snippet (install + mount):**

```markdown
## Installation

Add to your Gemfile:

    gem 'my_engine'

Run:

    bundle install
    rails generate my_engine:install

This creates `config/initializers/my_engine.rb`. Mount the engine in `config/routes.rb`:

    mount MyEngine::Engine, at: '/admin'
```

**Configuration section:**

```markdown
## Configuration

In `config/initializers/my_engine.rb`:

    MyEngine.configure do |config|
      config.user_class = "User"       # required: host model for current user
      config.widget_count = 10         # optional, default 10
    end
```

## Output Style

When asked to write docs:

1. Start with the minimum install path.
2. Show one realistic configuration example.
3. Document operational steps explicitly.
4. Keep sections short and task-oriented.
