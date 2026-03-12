---
name: rails-migration-safety
description: Plan and review production-safe Rails database migrations. Use when adding columns, indexes, constraints, backfills, renames, table rewrites, concurrent operations, or rollout and rollback strategy for schema changes.
---
# Rails Migration Safety

Use this skill when schema changes must be safe in real environments.

Prefer phased rollouts over one-shot migrations on large or busy tables.

## Review Order

1. Identify the database and table-size risk.
2. Separate schema changes from data backfills.
3. Check lock behavior for indexes, constraints, defaults, and rewrites.
4. Plan deployment order between app code and migration code.
5. Plan rollback or forward-fix strategy.

## Safe Patterns

- add nullable column first, backfill later, enforce `NOT NULL` last
- add indexes concurrently when supported
- backfill in batches outside a long transaction when volume is high
- deploy code that tolerates both old and new schemas during transitions
- use multi-step rollouts for renames, type changes, and unique constraints

If the project uses `strong_migrations`, follow it. If it does not, apply the same safety rules manually.

## Red Flags

- schema change and data backfill combined in one long migration
- column rename with app code assuming immediate cutover
- large-table default, rewrite, or `NOT NULL` change without a phased plan
- foreign key or unique constraint added before cleaning existing data
- destructive remove or drop in the same deploy as the replacement path

## Examples

**Risky (avoid):**

```ruby
# One migration: add column with default and backfill in same transaction
add_column :orders, :status, :string, default: 'pending', null: false
Order.update_all("status = 'pending'")  # long lock on large table
```

- **Risk:** Long lock; table rewrite if default is applied. **Safer:** (1) Add column nullable, (2) Backfill in batches in a separate migration or job, (3) Add `NOT NULL` and default in a later migration after backfill.

**Safe pattern:**

```ruby
# Step 1: add nullable column
add_column :orders, :status, :string

# Step 2 (separate deploy): backfill in batches outside migration
# Step 3 (after backfill): add constraint
change_column_null :orders, :status, false
change_column_default :orders, :status, from: nil, to: 'pending'
```

**Index on large tables (avoid long locks):**

- **PostgreSQL:** use `algorithm: :concurrent` so the index is built without blocking writes. It must run outside a transaction:

```ruby
disable_ddl_transaction!
add_index :orders, :processed_at, algorithm: :concurrent
```

- **MySQL:** use `algorithm: :inplace` so the index is built with online DDL where supported (reduces lock time):

```ruby
add_index :orders, :processed_at, algorithm: :inplace
```

Without `algorithm: :concurrent` (PostgreSQL) or `algorithm: :inplace` (MySQL), adding an index on a large table can hold an exclusive lock and block writes.

## Output Style

List risks first.

For each risk include:

- migration step
- likely failure mode or lock risk
- safer rollout
- rollback or forward-fix note
