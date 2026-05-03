---
name: rails-architecture-review
license: MIT
description: >
  Use when reviewing Rails application structure, identifying fat models or controllers,
  auditing callbacks, concerns, service extraction, domain boundaries, or general Rails
  architecture decisions. Recommends service object extractions, simplifies callback
  chains, identifies abstraction quality issues, and produces severity-classified
  findings with the smallest credible improvement for each.
---

# Rails Architecture Review

Use this skill when the task is to review or improve the structure of a Rails application or library.

**Core principle:** Prioritize boundary problems over style. Prefer simple objects and explicit flow over hidden behavior.

## Quick Reference

| Area | What to check |
|------|---------------|
| Controllers | Coordinate only — no domain logic |
| Models | Own persistence + cohesive domain rules, not orchestration |
| Services | Create real boundaries, not just moved code |
| Callbacks | Small and unsurprising — no hidden business logic |
| Concerns | One coherent capability per concern |
| External integrations | Behind dedicated collaborators |

## Review Order

1. Identify the main entry points: controllers, jobs, models, services.
2. Check where domain logic lives.
3. Inspect model responsibilities, callbacks, and associations.
4. Inspect controller size and orchestration.
5. Read every concern, helper, and presenter: does it do one coherent thing, or does it mix auditing + notifications + emails + external API calls? Mixed concerns are High or Medium severity depending on blast radius. **Treat any concern used by only one class as a candidate for deletion — inline it instead.**
6. Check whether abstractions clarify the design or only move code around.
7. **Verify each High-severity finding** by reading the actual code — confirm it is a real structural problem, not just a pattern match on file size or line count. If verification reveals the finding is not a genuine structural problem, either downgrade it to Medium/Low with a revised rationale, or remove it entirely. Do not list findings that do not survive code-level confirmation.

## Severity Levels

### High-Severity Findings

- Business logic hidden in callbacks or broad concerns
- Controllers orchestrating multi-step domain workflows inline
- Models coupled directly to HTTP, jobs, mailers, or external APIs
- Abstractions that add indirection without a clear responsibility
- Cross-layer constant reach that makes code hard to change

### Medium-Severity Findings

- Duplicated workflow logic across controllers or jobs
- Scopes or class methods carrying too much query or policy logic
- Helpers or presenters leaking domain behavior
- Service objects wrapping trivial one-liners
- Concerns combining unrelated responsibilities — check EVERY concern in the app

## Output Format and Style

**Begin with entry points.** Open the review by identifying the application's entry points (controllers, jobs, public API surface) before listing findings. Then write findings ordered by review area — boundary problems first, then model/callback issues, then concerns/helpers.

Every finding uses this four-field structure:

```
**Severity:** High
**Affected file:** app/controllers/orders_controller.rb — OrdersController#create
**Risk:** Controller runs a 5-step domain workflow. Partial state on failure; untestable without HTTP.
**Improvement:** Extract to Orders::CreateOrder.call(params). Controller handles response/redirect only.
```

For each finding include: severity, affected files or area, why the structure is risky, and the smallest credible improvement. Then list open assumptions and recommended next refactor steps.

**High-severity callback example:**

```ruby
# Bad — hidden side effects on every save
module Auditable
  included do
    after_create :log_creation
  end
  def log_creation
    AuditLog.create!(...)
    Slack.notify(...)                          # external API in callback
    UserMailer.admin_alert(...).deliver_later  # mailer in callback
  end
end
```

Fix: keep only `AuditLog.create!` in the callback; move Slack/mailer to an explicit service call at the call site.

## Pitfalls

| Pitfall | What to do |
|---------|------------|
| Flagging large files as High severity without reading them | Check whether size reflects legitimate domain complexity before assigning severity; downgrade or remove if no structural problem exists |
| Recommending a service object for every action | Only extract when it creates a real boundary — wrapping a single ActiveRecord call in a service adds indirection without benefit |
| Treating all callbacks as problematic | Callbacks are fine for persistence-scoped side effects (e.g., setting a default value); flag only those with external calls, cross-model orchestration, or hidden branching logic |
| Conflating "concern used in one place" with "concern is bad" | The issue is single-use concerns that add indirection — the fix is inlining, not rewriting |
| Proposing rewrites instead of smallest credible improvements | Each finding should recommend the minimal change that resolves the structural risk, not a full refactor |
| Missing cross-layer constant reach | Check for models referencing controller constants or jobs referencing view helpers — these are High-severity coupling issues that are easy to overlook |
