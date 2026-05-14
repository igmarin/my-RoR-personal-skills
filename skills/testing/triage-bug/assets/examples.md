# triage-bug compact examples

Example: Reproduce order creation out-of-stock failure

User task: "Creating an order for an out-of-stock product should return a 422 with 'Out of stock', but it currently succeeds or crashes. Create a failing spec that reproduces the bug and produce a minimal fix plan."

Expected triage output (JSON):

{
  "title": "Order creation ignores out-of-stock guard",
  "reproduction_steps": [
    "Create product with stock: 0",
    "POST /orders with quantity: 1",
    "Observe response status/body and whether an order row was created"
  ],
  "failing_command": "bundle exec rspec spec/requests/orders/create_spec.rb",
  "failing_tests": ["POST /orders when product is out of stock returns 422 with Out of stock"],
  "minimal_fix_plan": [
    "Add the failing request spec before touching implementation",
    "Update Orders::CreateOrder to guard stock before creating the order",
    "Return a handled 'Out of stock' error and no persisted order",
    "Run the focused request spec, related order specs, and the full suite"
  ]
}

Use the inline request spec skeleton in SKILL.md for the failing test when the bug is visible through POST /orders. Use `assets/spec-skeletons/reproduction_spec.rb` only for generic service-boundary bugs.
