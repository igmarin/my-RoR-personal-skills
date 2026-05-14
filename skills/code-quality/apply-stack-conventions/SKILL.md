---
name: apply-stack-conventions
license: MIT
description: >
  Use when writing new Rails code for a project using the PostgreSQL + Hotwire +
  Tailwind CSS stack. Covers stack-specific patterns only: MVC structure,
  ActiveRecord query conventions, Turbo Frames/Streams wiring, Stimulus
  controllers, and Tailwind component patterns. Not for general Rails design
  principles — this skill is scoped to what changes based on this specific
  technology stack.
metadata:
  version: 1.0.0
  user-invocable: "true"
---
# Apply Stack Conventions

## Quick Reference

| Stack area | Default convention |
|------------|--------------------|
| Rails MVC | Thin controllers; move non-trivial business logic into service objects |
| PostgreSQL | Avoid N+1s with `includes`; use database constraints for integrity |
| Hotwire | Prefer Turbo Frames/Streams before Stimulus |
| Tailwind | Use utilities in views; extract repeated UI into partials/components |
| Auth | Apply Devise authentication and Pundit authorization to protected resources |

## HARD-GATE

```text
ALL new code MUST have its test written and validated BEFORE implementation.
  1. Write the spec file content, not only the spec path: bundle exec rspec spec/[path]_spec.rb
  2. Verify it FAILS — output must show the observed failure proving the feature does not exist yet
  3. Write the implementation code
  4. Verify it PASSES — run the same spec and include the observed green result line
  5. Refactor if needed, keeping tests green
The final artifact must show the test proof before implementation code.
For each layer, repeat the same spec command after implementation and show
the GREEN result line, not only an arrow or planned verification.
Use copied terminal-output blocks for RED/GREEN proof. Do not express proof as
Ruby comments, `# =>` annotations, or hypothetical expected output.
See write-tests for the full gate cycle.
```

## Core Process

When **writing or generating** code for this project, follow these conventions. Stack: Ruby on Rails, PostgreSQL, Hotwire (Turbo + Stimulus), Tailwind CSS.

**Style:** If the project uses a linter, treat it as the source of truth for formatting. For cross-cutting design principles (DRY, YAGNI, structured logging, rules by directory), use **apply-code-conventions**.

### Feature Development Workflow

For a typical feature, compose stack patterns in this order:

1. **Model** — add validations, associations, scopes; eager-load with `includes` for any association used in loops
2. **Service object** — extract non-trivial business logic from the controller (see **create-service-object**)
3. **Controller** — keep actions thin; delegate to services; respond with `turbo_stream` and `html` formats
4. **View / Turbo wiring** — wrap dynamic sections in `<turbo-frame>` tags; broadcast `turbo_stream` responses from the controller
5. **Stimulus** — add a controller only when client-side interactivity cannot be handled by Turbo alone
6. **Tailwind** — apply utility classes to the view; extract repeated patterns into partials or Stimulus targets

Each step should remain testable in isolation before wiring to the next layer.

### Key Code Patterns

#### Hotwire: Turbo Frames

```erb
<%# Wrap a section to be replaced without a full page reload %>
<turbo-frame id="order-<%= @order.id %>">
  <%= render "orders/details", order: @order %>
</turbo-frame>

<%# Link that targets only this frame %>
<%= link_to "Edit", edit_order_path(@order), data: { turbo_frame: "order-#{@order.id}" } %>
```

#### Hotwire: Turbo Streams (broadcast from controller)

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

#### Avoiding N+1 — Eager Loading

```ruby
# BAD — triggers one query per order
@orders = Order.where(user: current_user)
@orders.each { |o| o.line_items.count }

# GOOD — single JOIN via includes
@orders = Order.includes(:line_items).where(user: current_user)
```

#### Service Object (complex business logic out of the controller)

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

See **create-service-object** for the full `.call` pattern and response format.

### Security

This project uses **Devise** for authentication and **Pundit** for authorization. Apply these on every feature that introduces access-controlled resources.

### Pitfalls to Avoid

| Issue | Correct approach |
|-------|------------------|
| Client-side interactivity reached for before Turbo | Use Turbo Frames/Streams first; add a Stimulus controller only when Turbo cannot handle it |
| N+1 queries in loops over associations | Eager load with `includes` before the loop |
| Controller action with 15+ lines of business logic | Extract to a service object using the `.call` pattern |
| Accessing a protected resource without an authorisation check | Apply a Pundit policy on every action that touches access-controlled data |

## Output Style

When applying stack conventions, your output MUST include:

1. **Stack decisions** — State which Rails, PostgreSQL, Hotwire, Stimulus, Tailwind, auth, and service-object conventions apply.
2. **Tests-first proof before implementation** — Put this section before any implementation code. For each layer, include the actual spec code written or updated, the exact command (`bundle exec rspec spec/[path]_spec.rb`), and the observed RED output proving the feature is absent rather than misconfigured. Put RED proof in a terminal-output block copied from the run; do not use hypothetical `Expected RED:`, Ruby comments, or `# =>` annotations as a substitute.
3. **Layer isolation** — State how model/query, service, controller, view, Stimulus, and Tailwind changes remain independently testable before wiring them together.
4. **Layered implementation** — Separate model/query, service, controller, view, Stimulus, and Tailwind changes when applicable.
5. **Performance and security checks** — Call out N+1 prevention, authorization policy use, and unsafe params/content handling.
6. **Verification** — For every layer, repeat the focused spec command after implementation and show the observed GREEN result line in a terminal-output block, e.g. `1 example, 0 failures`. Then list Rails specs, system tests, linting, and any browser/manual checks run.
7. **Language** — Must be in English unless explicitly requested otherwise.

## Integration

| Skill | When to chain |
|-------|---------------|
| **apply-code-conventions** | For design principles, structured logging, and path-specific rules |
| **code-review** | When reviewing existing code against these conventions |
| **create-service-object** | When extracting business logic into service objects |
| **write-tests** | For testing conventions and full red/green/refactor TDD cycle |
| **review-architecture** | For structural review beyond conventions |
