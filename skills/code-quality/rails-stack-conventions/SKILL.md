---
name: rails-stack-conventions
license: MIT
description: >
  Use when writing new Rails code for a project using the PostgreSQL + Hotwire +
  Tailwind CSS stack. Covers stack-specific patterns only: MVC structure,
  ActiveRecord query conventions, Turbo Frames/Streams wiring, Stimulus
  controllers, and Tailwind component patterns. Not for general Rails design
  principles — this skill is scoped to what changes based on this specific
  technology stack.
---

# Rails Stack Conventions

When **writing or generating** code for this project, follow these conventions. Stack: Ruby on Rails, PostgreSQL, Hotwire (Turbo + Stimulus), Tailwind CSS.

**Style:** If the project uses a linter, treat it as the source of truth for formatting. For cross-cutting design principles (DRY, YAGNI, structured logging, rules by directory), use **rails-code-conventions**.

## HARD-GATE: Tests Gate Implementation

```
ALL new code MUST have its test written and validated BEFORE implementation.
  1. Write the spec: bundle exec rspec spec/[path]_spec.rb
  2. Verify it FAILS — output must show the feature does not exist yet
  3. Write the implementation code
  4. Verify it PASSES — run the same spec and confirm green
  5. Refactor if needed, keeping tests green
See rspec-best-practices for the full gate cycle.
```

## Feature Development Workflow

For a typical feature, compose stack patterns in this order:

1. **Model** — add validations, associations, scopes; eager-load with `includes` for any association used in loops
2. **Service object** — extract non-trivial business logic from the controller (see **ruby-service-objects**)
3. **Controller** — keep actions thin; delegate to services; respond with `turbo_stream` and `html` formats
4. **View / Turbo wiring** — wrap dynamic sections in `<turbo-frame>` tags; broadcast `turbo_stream` responses from the controller
5. **Stimulus** — add a controller only when client-side interactivity cannot be handled by Turbo alone
6. **Tailwind** — apply utility classes to the view; extract repeated patterns into partials or Stimulus targets

Each step should remain testable in isolation before wiring to the next layer.

## Key Code Patterns

### Hotwire: Turbo Frames

```erb
<%# Wrap a section to be replaced without a full page reload %>
<turbo-frame id="order-<%= @order.id %>">
  <%= render "orders/details", order: @order %>
</turbo-frame>

<%# Link that targets only this frame %>
<%= link_to "Edit", edit_order_path(@order), data: { turbo_frame: "order-#{@order.id}" } %>
```

### Hotwire: Turbo Streams (broadcast from controller)

```ruby
respond_to do |format|
  format.turbo_stream do
    render turbo_stream: turbo_stream.replace(
      "order_#{@order.id}",
      partial: "orders/order",
      locals: { order: @order }
    )
  end
  format.html { redirect_to @order }
end
```

### Avoiding N+1 — Eager Loading

```ruby
# BAD — triggers one query per order
@orders = Order.where(user: current_user)
@orders.each { |o| o.line_items.count }

# GOOD — single JOIN via includes
@orders = Order.includes(:line_items).where(user: current_user)
```

### Service Object (complex business logic out of the controller)

```ruby
# Controller stays thin — delegate to service
result = Orders::CreateOrder.call(user: current_user, params: order_params)
if result[:success]
  redirect_to result[:order], notice: "Order created"
else
  @order = Order.new(order_params)
  render :new, status: :unprocessable_entity
end
```

See **ruby-service-objects** for the full `.call` pattern and response format.

## Security

This project uses **Devise** for authentication and **Pundit** for authorization. Apply these on every feature that introduces access-controlled resources.

## Pitfalls to Avoid

| Issue | Correct approach |
|-------|------------------|
| Business logic in views | Use helpers, presenters, or Stimulus controllers |
| N+1 queries in loops | Eager load with `includes` before the loop |
| Skipping FactoryBot for "quick" tests | Fixtures are brittle — always use factories |
| Controller action with 15+ lines of business logic | Extract to a service object |
| Model with no validations on required fields | Add presence/format validations |
| View with 10+ lines of embedded Ruby conditionals | Move logic to a presenter or partial |
| Hardcoded strings that belong in I18n | Use `t()` helpers |

## Integration

| Skill | When to chain |
|-------|---------------|
| **rails-code-conventions** | For design principles, structured logging, and path-specific rules |
| **rails-code-review** | When reviewing existing code against these conventions |
| **ruby-service-objects** | When extracting business logic into service objects |
| **rspec-best-practices** | For testing conventions and full red/green/refactor TDD cycle |
| **rails-architecture-review** | For structural review beyond conventions |
