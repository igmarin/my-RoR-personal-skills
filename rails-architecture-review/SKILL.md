---
name: rails-architecture-review
description: Review Ruby on Rails application architecture for maintainability and clear boundaries. Use when reviewing Rails code structure, fat models or controllers, callbacks, concerns, service extraction, domain boundaries, or general Rails best practices.
---
# Rails Architecture Review

Use this skill when the task is to review or improve the structure of a Rails application or library.

Prioritize boundary problems over style. Prefer simple objects and explicit flow over hidden behavior.

## Review Order

1. Identify the main entry points: controllers, jobs, models, services.
2. Check where domain logic lives.
3. Inspect model responsibilities, callbacks, and associations.
4. Inspect controller size and orchestration.
5. Check concerns, helpers, and presenters for mixed responsibilities.
6. Check whether abstractions clarify the design or only move code around.

## What Good Looks Like

- Controllers coordinate request and response flow, not domain policy.
- Models own persistence and cohesive domain rules, not unrelated orchestration.
- Services, query objects, and policies exist where they create a real boundary.
- Callbacks are small and unsurprising.
- Concerns represent one coherent capability.
- External integrations sit behind dedicated collaborators.

## High-Severity Findings

- business logic hidden in callbacks or broad concerns
- controllers orchestrating multi-step domain workflows inline
- models coupled directly to HTTP, jobs, mailers, or external APIs
- abstractions that add indirection without a clear responsibility
- cross-layer constant reach that makes code hard to change

## Medium-Severity Findings

- duplicated workflow logic across controllers or jobs
- scopes or class methods carrying too much query or policy logic
- helpers or presenters leaking domain behavior
- service objects wrapping trivial one-liners
- concerns combining unrelated responsibilities

## Examples

**High-severity finding (controller doing too much):**

```ruby
# Bad: domain workflow in controller
class OrdersController < ApplicationController
  def create
    order = Order.new(order_params)
    Inventory.check!(order.line_items)  # domain rule
    Pricing.apply_promotions!(order)    # domain rule
    order.save!
    NotifyWarehouseJob.perform_later(order.id)  # orchestration
    redirect_to order
  end
end
```

- **Severity:** High. **Area:** `OrdersController#create`. **Risk:** Controllers should coordinate, not run multi-step domain workflows. **Improvement:** Extract to `Orders::CreateOrder.call(params)` and have the controller call it and handle response/redirect.

**Good (single responsibility):**

```ruby
# Good: controller delegates to service
class OrdersController < ApplicationController
  def create
    result = Orders::CreateOrder.call(order_params)
    result[:success] ? redirect_to(result[:order]) : render(:new, status: :unprocessable_entity)
  end
end
```

## Output Style

Write findings first.

For each finding include:

- severity
- affected files or area
- why the structure is risky
- the smallest credible improvement

Then list open assumptions and recommended next refactor steps.
