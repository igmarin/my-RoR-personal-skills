---
name: implement-background-job
license: MIT
description: >
  Use when adding or reviewing background jobs in Rails. Configures Active Job
  workers, implements idempotency checks, sets up retry/discard strategies,
  selects Solid Queue (Rails 8+) or Sidekiq based on scale, and defines recurring
  jobs via recurring.yml or sidekiq-cron. Trigger words: background job, Active Job,
  Solid Queue, Sidekiq, idempotency, retry, discard, recurring job, queue.
metadata:
  version: 1.0.0
  user-invocable: "true"
---

# Implement Background Job

Use this skill when the task is to add, configure, or review background jobs in a Rails application.

## Quick Reference

| Aspect | Rule |
|--------|------|
| Arguments | Pass IDs, not objects. Load in `perform`. |
| Idempotency | Check "already done?" before doing work |
| Retries | `retry_on` for transient, `discard_on` for permanent errors |
| Job size | Load, guard, delegate. No multi-step orchestration in `perform`. |
| Backend (Rails 8) | Solid Queue (database-backed, no Redis) |
| Backend (Rails 7) | Sidekiq + Redis for high throughput |
| Recurring | `config/recurring.yml` (Solid Queue) or cron/sidekiq-cron |

## HARD-GATE

```text
EVERY job MUST have its test written and validated BEFORE implementation.
  1. Write the job spec (idempotency, retry, error handling)
  2. Run the spec — verify it fails because the job does not exist yet
  3. ONLY THEN write the job class

EVERY job that performs a side effect (charge, email, API call) MUST have
an idempotency check BEFORE the side effect.

EVERY perform method should do only three things:
  1. Load the record from the passed ID
  2. Guard for idempotency / permanent no-op conditions
  3. Delegate the side effect or orchestration to a service object

If perform needs more than that, extract a service.
```

## Core Process

1. Write the job spec first, validating idempotency, retry, and error handling.
2. Run the spec to ensure it fails.
3. Write the job class. Ensure `perform` receives IDs, not full objects.
4. Load the record inside `perform`.
5. Check for idempotency/no-op conditions before acting.
6. Delegate work to a service object.
7. Run the full test suite.
8. Enqueue or perform the job twice and confirm the second run is a no-op.
9. Confirm `retry_on` has an explicit `attempts:` limit and `discard_on` covers at least one permanent error.
10. Confirm recurring jobs live in `config/recurring.yml` (Rails 8) or the chosen scheduler config.

## Extended Resources

**Rails 8 vs Rails 7**
| Aspect | Rails 7 and earlier | Rails 8 |
|--------|---------------------|---------|
| Default | No default; set `queue_adapter` (often Sidekiq) | **Solid Queue** (database-backed) |
| Dev/test | `:async` or `:inline` | Same |
| Recurring | External (cron, sidekiq-cron) | `config/recurring.yml` |
| Dashboard | Third-party (Sidekiq Web) | **Mission Control Jobs** |

**Pitfalls**
| Problem | Correct approach |
|---------|-----------------|
| Passing ActiveRecord objects as arguments | Pass IDs — objects may be deleted or stale by perform time |
| No idempotency check before side effects | Jobs run at-least-once; double-charging and double-emailing result |
| `retry_on` without `attempts` limit | Infinite retries on persistent errors |
| Missing `discard_on` for permanent errors | Job retries forever on `RecordNotFound` |
| Complex business logic in `perform` | Keep `perform` thin — delegate to service objects |
| Using `:inline` or `:async` in production | No persistence, no retry, no monitoring |
| Recurring job defined only in code | Use `recurring.yml` or equivalent for visibility and recoverability |

**Examples**
**Thin job with idempotency and retry:**
```ruby
class SendInvoiceReminderJob < ApplicationJob
  queue_as :default
  retry_on Net::OpenTimeout, wait: :polynomially_longer, attempts: 5
  discard_on ActiveRecord::RecordNotFound

  def perform(invoice_id)
    invoice = Invoice.find(invoice_id)
    return if invoice.reminder_sent_at?

    InvoiceReminders::Send.call(invoice:)
  end
end
```
**Service owns the side effect and state update:**
```ruby
module InvoiceReminders
  class Send
    def self.call(invoice:)
      InvoiceMailer.overdue(invoice).deliver_now
      invoice.update!(reminder_sent_at: Time.current)
    end
  end
end
```

- [BACKENDS.md](./BACKENDS.md)
- [assets/job_patterns.md](assets/job_patterns.md)
- [assets/retry_examples.md](assets/retry_examples.md)

## Output Style

1. Use explicit `retry_on` and `discard_on` configuration.
2. Outline how idempotency is checked for side effects.
3. Show tests covering retries and idempotency explicitly.
4. If the task asks for an ops artifact, record backend, retry, and idempotency decisions in `process_log.md`.
5. Language — Must be in English unless explicitly requested otherwise.

## Integration

| Skill | When to chain |
|-------|---------------|
| **review-migration** | Solid Queue uses DB tables; add migrations safely |
| **security-check** | Jobs receive serialized input; validate like any entry point |
| **write-tests** | TDD gate: write job spec before implementation; use `perform_enqueued_jobs` |
| **create-service-object** | Keep `perform` thin; call service objects for business logic |
