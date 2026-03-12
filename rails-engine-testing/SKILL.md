---
name: rails-engine-testing
description: Design and implement tests for Ruby on Rails engines. Use when setting up a dummy app, adding engine request specs, routing specs, generator specs, reload-safety tests, host integration coverage, or improving confidence in a Rails engine.
---
# Rails Engine Testing

Use this skill when the task is to create or improve test coverage for a Rails engine.

Prefer integration confidence over isolated test quantity. The main goal is to prove the engine behaves correctly inside a host app.

## Testing Order

1. Identify the engine type and public behaviors.
2. Decide which behaviors need unit tests versus dummy-app integration tests.
3. Add the smallest integration test that proves mounting and boot work.
4. Add request, routing, configuration, and generator coverage as needed.
5. Add regression tests for coupling or reload bugs before refactoring.

## Minimum Baseline

For a non-trivial engine, aim for:

- one dummy-app boot or integration spec
- one request or routing spec for mounted endpoints
- one configuration spec for host customization
- unit tests for public services or POROs

If generators exist, add generator specs. If decorators or reload hooks exist, add reload-focused coverage.

## What To Test In The Dummy App

Use the dummy app for:

- mounting the engine
- route resolution
- controller and view rendering
- interactions with configured host models or adapters
- initializer-driven setup
- copied migrations or install flow where practical

Do not rely only on isolated unit tests when the behavior depends on Rails integration.

## Good Test Boundaries

- Unit tests: services, value objects, adapters, policy objects.
- Request specs: public engine endpoints.
- Routing specs: engine route expectations and mount behavior.
- System specs: only when the engine ships meaningful UI flows.
- Generator specs: install commands, copied files, idempotency.

## Review Checklist

- Does the dummy app exercise real host integration?
- Are engine routes tested through the engine namespace?
- Are configurable seams covered with at least one non-default case?
- Are generators safe to run twice?
- Are reload-sensitive hooks protected by regression tests?

## Common Gaps To Fix

- Engine boots but no test proves the host app can mount it.
- Request specs exist but use stubs instead of real engine wiring.
- Configuration object exists but default and override behavior are untested.
- Install generators exist without file or route assertions.
- Dummy app exists only as scaffolding and is not used in meaningful specs.

## Examples

**Minimal dummy-app request spec (engine mounted):**

```ruby
# spec/requests/my_engine/root_spec.rb or spec/integration/engine_mount_spec.rb
require 'rails_helper'

RSpec.describe 'MyEngine mount', type: :request do
  it 'mounts the engine and returns success for the engine root' do
    get my_engine.root_path
    expect(response).to have_http_status(:ok)
  end
end
```

**Configuration spec (engine respects host config):**

```ruby
# spec/my_engine/configuration_spec.rb
RSpec.describe MyEngine::Configuration do
  around do |example|
    original = MyEngine.config.widget_count
    MyEngine.config.widget_count = 3
    example.run
    MyEngine.config.widget_count = original
  end

  it 'uses configured value' do
    expect(MyEngine.config.widget_count).to eq(3)
  end
end
```

## Output Style

When asked to help with tests:

1. List the highest-value missing integration tests.
2. Add a minimal passing baseline first.
3. Expand with focused regression coverage for risky seams.
