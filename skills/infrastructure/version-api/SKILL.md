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

## Quick Reference

| Concern | File |
|---|---|
| Route namespaces | `config/routes.rb` |
| Header versioning | `app/controllers/concerns/api_versioning.rb` |
| Deprecation headers | `app/controllers/concerns/deprecatable.rb` |
| Compatibility specs | `spec/requests/api/backward_compatibility_spec.rb` |

## HARD-GATE

```text
ALWAYS maintain backward compatibility for at least one major version
NEVER remove endpoints without deprecation period
ALWAYS version in URL path (/api/v1/) or Accept header, never in body
```

## Core Process

1. **Choose strategy** — URL path (`/api/v1/`) for public APIs; Accept header for internal/private APIs.
2. **Add route namespace** — Wrap new version resources in a `namespace :v2` block in `config/routes.rb`.
3. **Create controllers** — Inherit from the previous version's controller and override only changed actions.
4. **Apply deprecation** — Include `Deprecatable` in old-version controllers to emit sunset headers.
5. **Run compatibility specs** — Execute `rspec spec/requests/api/backward_compatibility_spec.rb` to confirm no regressions.
6. **Update documentation** — Record the sunset date and migration guide for deprecated endpoints.

## Extended Resources

**Strategies**
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

**Deprecation**
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

**Verification**
After adding a new version, always run the backward compatibility suite before merging:
```bash
bundle exec rspec spec/requests/api/backward_compatibility_spec.rb
```

- [SKILL.md](./SKILL.md)
- [EXAMPLES.md](./EXAMPLES.md)
- [references/workflow.md](./references/workflow.md)
- [references/strategies.md](./references/strategies.md)

## Output Style

1. Define versioning strategy explicitly.
2. Document inheritance strategy.
3. Show route definition and deprecation headers.
4. Include compatibility specs to prevent breakage.
5. Language — Must be in English unless explicitly requested otherwise.

## Integration

| Skill | When to chain |
|-------|---------------|
| **generate-api-collection** | When generating the updated API endpoints |
| **test-engine** | When verifying specs for regressions |
