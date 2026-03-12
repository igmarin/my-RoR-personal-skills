---
name: rails-background-jobs
description: Design and implement Rails background jobs with Active Job, Solid Queue (Rails 8), or Sidekiq. Use when adding jobs, configuring queues, recurring jobs, idempotency, retries, or choosing between Solid Queue and Redis-backed adapters. Covers Rails 8 defaults vs Rails 7 and earlier.
---
# Rails Background Jobs

Use this skill when the task is to add, configure, or review background jobs in a Rails application.

Prefer Active Job’s unified API; choose the backend (Solid Queue, Sidekiq, etc.) based on Rails version and scale. Design jobs for idempotency and safe retries.

---

## Rails 8 vs Rails 7 and earlier

| Aspect | Rails 7 and earlier | Rails 8 |
|--------|----------------------|--------|
| **Production default** | No default; you set `config.active_job.queue_adapter` (often Sidekiq or Resque). | **Solid Queue** (database-backed) is the default for new apps. |
| **Development/test** | Often `:async` (in-process) or `:inline` (synchronous). | Same; `:async` or `:inline` in development/test. |
| **Recurring jobs** | Typically external (cron, sidekiq-cron, etc.). | **Solid Queue** supports recurring jobs via `config/recurring.yml`; no separate cron needed. |
| **Dashboard** | Third-party (Sidekiq Web, etc.). | **Mission Control Jobs** works with Solid Queue (and others) for monitoring and retries. |

New Rails 8 apps can skip Solid Queue with `--skip-solid`; existing apps add it with `bundle add solid_queue` and `bin/rails solid_queue:install`.

---

## Choosing the backend

- **Solid Queue (Rails 8 default):** Database-backed (PostgreSQL, MySQL, or SQLite). No Redis. Good for moderate volume (&lt; ~1000 jobs/minute), simpler ops, and apps already on PostgreSQL/MySQL. Uses DB locks (e.g. PostgreSQL `SKIP LOCKED`) for reliable, concurrent processing.
- **Sidekiq + Redis:** Higher throughput, more mature ecosystem. Use when you need very high job volume or existing Redis-based workflows.
- **`:async` / `:inline`:** Only for development or test; not for production.

When the app is on **PostgreSQL or MySQL**, Solid Queue is a good default unless you have high-throughput or existing Redis requirements.

---

## Core rules

1. **Pass serializable arguments:** Pass IDs, strings, numbers, hashes, arrays. Avoid passing live ActiveRecord objects when you can; pass `id` and load in `perform`. If you pass GlobalID, the job will load the record at perform time (and raise `ActiveJob::DeserializationError` if it was deleted).
2. **Design for idempotency:** Jobs may run more than once (retries, at-least-once delivery). Check state before doing work; use unique constraints or “already processed” checks to avoid duplicate side effects (e.g. double charging).
3. **Use retries wisely:** Use `retry_on` for transient errors and `discard_on` for permanent failures. Avoid infinite retries for non-idempotent actions.
4. **Keep jobs small and focused:** One clear responsibility per job; call services or POROs for complex logic.

---

## Active Job basics

- **Enqueue:** `MyJob.perform_later(id, "option")` or `MyJob.set(wait: 5.minutes).perform_later(id)`.
- **Queues:** `queue_as :low` or `queue_as :default`; configure adapter-specific queue names and priorities (e.g. Solid Queue `config/queue.yml` or Sidekiq queues).
- **Arguments:** Only JSON-serializable types and GlobalID. Prefer `perform_later(user_id)` and `User.find(user_id)` in `perform` over passing the whole `User` (avoids stale or deleted records at perform time unless you explicitly want GlobalID).

---

## Idempotency

- Before doing work that must happen once, check “already done?” (e.g. `order.reload; return if order.shipped?`).
- Prefer DB constraints (e.g. unique index on `(job_key, idempotency_key)`) so duplicate runs fail safely.
- For payments or external APIs, use idempotency keys and store processed keys with TTL or in DB.

---

## Retries and errors

- **retry_on:** For transient errors (network, timeouts). Example: `retry_on Net::OpenTimeout, wait: :polynomially_longer, attempts: 5`.
- **discard_on:** For permanent failures (e.g. record not found, invalid input) so the job is not retried forever.
- **Rescue in perform:** Log and re-raise if you want the adapter to retry; return without raising if you handled it and do not want a retry.

---

## Solid Queue (Rails 8)

- **Install (existing app):** `bundle add solid_queue`, `bin/rails solid_queue:install`, `rails db:migrate`. Configure `config.active_job.queue_adapter = :solid_queue` in production.
- **PostgreSQL:** Uses `FOR UPDATE SKIP LOCKED` for lock-free concurrent job claiming. No extra config.
- **MySQL:** Supported; same adapter. For very high concurrency, test lock behavior on your version.
- **Recurring jobs:** Define in `config/recurring.yml` per environment. Schedule format: cron expression (`"0 */2 * * *"`) or natural language (`"every 2 hours"`, `"at 12:03pm every day"`). Scheduler process must be running (e.g. `bin/rails solid_queue:start` or same process as workers).
- **Mission Control Jobs:** Add `mission_control-jobs` gem and mount the dashboard for retries, discards, and queue inspection.

---

## Recurring jobs (Solid Queue)

Example `config/recurring.yml`:

```yaml
production:
  nightly_cleanup:
    class: "NightlyCleanupJob"
    schedule: "0 2 * * *"   # 2 AM daily (cron)
  hourly_sync:
    class: "HourlySyncJob"
    schedule: "every 1 hour"
    queue: low
```

Changes require deploy; the scheduler reads config at startup. Remove a job from the YAML and redeploy to stop it.

---

## Sidekiq (Rails 7 or when you need Redis)

- Set `config.active_job.queue_adapter = :sidekiq`. Run Sidekiq process and Redis.
- Use `sidekiq_options retry: 5, queue: :low` in the job class if you need adapter-specific options.
- Idempotency and argument rules are the same as above.

---

## Examples

**Job with idempotency and retry (Solid Queue or Sidekiq):**

```ruby
class NotifyOrderShippedJob < ApplicationJob
  queue_as :default
  retry_on Net::OpenTimeout, wait: :polynomially_longer, attempts: 5
  discard_on ActiveRecord::RecordNotFound

  def perform(order_id)
    order = Order.find(order_id)
    return if order.shipped_notification_sent?   # idempotency: already done
    OrderMailer.shipped(order).deliver_now
    order.update!(shipped_notification_sent_at: Time.current)
  end
end
```

**Pass IDs, not objects:**

```ruby
# Good
NotifyOrderShippedJob.perform_later(order.id)

# Avoid when possible: GlobalID is OK but record may be deleted before job runs
NotifyOrderShippedJob.perform_later(order)  # can raise DeserializationError
```

**Recurring job class (called from recurring.yml):**

```ruby
class NightlyCleanupJob < ApplicationJob
  queue_as :low
  discard_on StandardError  # or retry_on for transient errors

  def perform
    OldSessionsCleanupService.call
  end
end
```

---

## Red flags

- Job performs non-idempotent side effects (e.g. charge card, send SMS) without “already done?” check or idempotency key.
- Passing large or non-serializable objects as arguments.
- Relying on “run once” semantics; at-least-once delivery can run a job twice.
- Using only `:inline` or `:async` in production.
- Recurring job defined in code without corresponding `recurring.yml` (Solid Queue) or equivalent (cron/Sidekiq cron).

---

## Related skills

- **rails-migration-safety:** Solid Queue and Mission Control use DB tables; add indexes/migrations safely (e.g. concurrent indexes on PostgreSQL).
- **rails-security-review:** Jobs receive serialized input; validate and authorize like any other entry point.
- **ruby-service-objects:** Keep job `perform` thin; call service objects for business logic.
- **rspec-best-practices:** Use `perform_enqueued_jobs` or adapter-specific helpers to test jobs; test idempotency when relevant.
