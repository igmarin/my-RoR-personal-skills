---
name: version-api
license: MIT
description: >
  Implements REST API versioning strategies in Rails, covering URL path versioning,
  header-based versioning, deprecation policies, and maintaining backward
  compatibility across versions. Use when adding a new API version (v1, v2),
  planning API evolution, setting deprecation or sunset policies, or ensuring
  backward compatibility for existing consumers.
metadata:
  version: 1.0.0
  user-invocable: "true"
---
# Version API

Implement versioning strategies for Rails APIs.

**Files:** [SKILL.md](./SKILL.md) · [EXAMPLES.md](./EXAMPLES.md) · [references/workflow.md](./references/workflow.md) · [references/strategies.md](./references/strategies.md)

## HARD-GATE

```text
ALWAYS maintain backward compatibility for at least one major version
NEVER remove endpoints without deprecation period
ALWAYS version in URL path (/api/v1/) or Accept header, never in body
```

## Quick Reference

| Concern | File |
|---|---|
| Route namespaces | `config/routes.rb` |
| Header versioning | `app/controllers/concerns/api_versioning.rb` |
| Deprecation headers | `app/controllers/concerns/deprecatable.rb` |
| Compatibility specs | `spec/requests/api/backward_compatibility_spec.rb` |

## Versioning Workflow

1. **Choose strategy** — URL path (`/api/v1/`) for public APIs; Accept header for internal/private APIs.
2. **Add route namespace** — Wrap new version resources in a `namespace :v2` block in `config/routes.rb`.
3. **Create controllers** — Inherit from the previous version's controller and override only changed actions.
4. **Apply deprecation** — Include `Deprecatable` in old-version controllers to emit sunset headers.
5. **Run compatibility specs** — Execute `rspec spec/requests/api/backward_compatibility_spec.rb` to confirm no regressions.
6. **Update documentation** — Record the sunset date and migration guide for deprecated endpoints.

See [references/workflow.md](references/workflow.md) for the complete annotated workflow.

## Strategies

### URL Path Versioning (Recommended)

```ruby
namespace :v1 do
  resources :users
end

namespace :v2 do
  resources :users
end
```

### Controller Inheritance

Override only actions that change between versions:

```ruby
module V2
  class UsersController < V1::UsersController
    def index
      render json: User.all, only: [:id, :name, :email, :phone]
    end
  end
end
```

See [references/strategies.md](references/strategies.md) for a full URL path vs. Accept header comparison.

## Deprecation

Include the `Deprecatable` concern (defined in `app/controllers/concerns/deprecatable.rb`) in any controller version due for retirement. It emits `Sunset` and `Deprecation` response headers automatically via a `before_action`.

```ruby
module V1
  class UsersController < ApplicationController
    include Deprecatable
    # Override sunset_date on the class to set the retirement date:
    # def self.sunset_date = Date.new(2025, 6, 1)
  end
end
```

See `app/controllers/concerns/deprecatable.rb` for the full implementation with logging.

## Verification

After adding a new version, always run the backward compatibility suite before merging:

```bash
bundle exec rspec spec/requests/api/backward_compatibility_spec.rb
```

All existing v1 contract tests must remain green; a new version should never silently break prior consumers.

## Examples

See [EXAMPLES.md](EXAMPLES.md) for complete code including:
- Controller inheritance patterns
- Deprecatable concern with logging
- Backward compatibility specs
- Client request examples
