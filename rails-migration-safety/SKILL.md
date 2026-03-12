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

## Output Style

List risks first.

For each risk include:

- migration step
- likely failure mode or lock risk
- safer rollout
- rollback or forward-fix note
