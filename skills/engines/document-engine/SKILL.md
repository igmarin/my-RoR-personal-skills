---
name: document-engine
license: MIT
description: >
  Use when writing or maintaining documentation for Rails engines. Generates README
  templates, writes installation and configuration guides, documents mount points,
  extension APIs, and migration notes for host-app adoption. Trigger words: engine
  README, installation guide, configuration docs, mount instructions, migration notes,
  extension points, host integration examples, setup documentation.
metadata:
  version: 1.0.0
  user-invocable: "true"
---

# Document Engine

Use this skill when writing or maintaining documentation for Rails engines.

## Quick Reference

| Section | Focus |
|---------|-------|
| Installation | gem add, bundle, run install generator |
| Mounting | explicit `mount MyEngine::Engine, at: '/path'` in routes |
| Configuration | all options with defaults, required vs optional |
| Usage | copyable code for typical workflows |
| Migrations | install generator, one-time setup |

## HARD-GATE

```text
All generated documentation (README, guides, examples) MUST explicitly document:
1. Required host-app steps before optional customization.
2. Minimum working install path first.
3. Any assumptions about host models, job backends, or auth integrations.
```

## Core Process

1. Document required host-app steps before optional customization.
2. Keep examples copyable and close to real code.
3. Show the minimum working install path first.
4. If the engine assumes any host model, job backend, or auth integration, say so explicitly.
5. Document upgrade-impacting changes when setup evolves.

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

## Extended Resources

**Recommended README Shape**
1. Purpose — what the engine does and when to use it
2. Installation — gem add, bundle, run install generator
3. Mounting — explicit `mount MyEngine::Engine, at: '/path'` in routes
4. Configuration — all options with defaults, required vs optional
5. Usage examples — copyable code for typical workflows
6. Migrations / operational steps — install generator, one-time setup
7. Extension points — adapters, callbacks, config blocks
8. Development and testing — how to run tests or contribute

**Documentation Gaps to Check**
See [CHECKLIST.md](./CHECKLIST.md) for the full gap checklist. Critical gaps: installation steps, all config options with defaults, explicit mount path, migration timing, host model/auth assumptions.

- [assets/configuration.md](assets/configuration.md)
- [assets/examples.md](assets/examples.md)
- [assets/installation.md](assets/installation.md)

## Output Style

1. Start with the minimum install path.
2. Show one realistic configuration example.
3. Document operational steps explicitly.
4. Keep sections short and task-oriented.
5. Check each row in the Documentation Gaps checklist against the draft. A checklist item **passes** when the docs contain a corresponding section with at least one copyable code example or explicit prose statement. A checklist item **fails** when the section is absent, incomplete, or lacks a concrete example. For each failing item: add the missing section or example, then re-run the checklist from the top. Do not finalize until all critical items pass.
6. Language — Must be in English unless explicitly requested otherwise.

## Integration

| Skill | When to chain |
|-------|----------------|
| create-engine | Host-app contract, structure, extension points to document |
| create-engine-installer | Install generators, setup steps to document |
| release-engine | Changelog, upgrade notes, version documentation |
| generate-api-collection | When documenting or adding API endpoints (keep Postman collection in sync) |
