---
name: review-migration
license: MIT
description: >
  Use when planning or reviewing production database migrations, adding columns, indexes,
  constraints, backfills, renames, table rewrites, or concurrent operations. Covers phased
  rollouts, lock behavior, rollback strategy, strong_migrations compliance, and deployment
  ordering for schema changes.
metadata:
  version: 1.0.0
  user-invocable: "true"
---

# Review Migration

Use this skill when schema changes must be safe in real environments.

## Quick Reference

| Operation | Safe Pattern |
|-----------|-------------|
| Add column | Nullable first, backfill later, enforce NOT NULL last |
| Add index (large table) | `algorithm: :concurrent` (PG) / `:inplace` (MySQL) |
| Backfill data | Batch job, not inside migration transaction |
| Rename column | Add new, copy data, migrate callers, drop old |
| Add NOT NULL | After backfill confirms all rows have values |
| Add foreign key | After cleaning orphaned records |
| Remove column | Remove code references first, then drop column |

## HARD-GATE

```text
DO NOT combine schema change and data backfill in one migration.
DO NOT add NOT NULL on a column that hasn't been fully backfilled.
DO NOT drop columns before all code references are removed.
```

## Core Process

1. Identify the database and table-size risk.
2. Separate schema changes from data backfills.
3. Check lock behavior for indexes, constraints, defaults, and rewrites.
4. Plan deployment order between app code and migration code.
5. Plan rollback or forward-fix strategy.

## Extended Resources

**Safe Patterns**
- Add nullable column first, backfill later, enforce `NOT NULL` last.
- Add indexes concurrently when supported.
- Backfill in batches outside a long transaction when volume is high.
- Deploy code that tolerates both old and new schemas during transitions.
- Use multi-step rollouts for renames, type changes, and unique constraints.
- For every step, state the expected lock or table-rewrite risk explicitly; if negligible, say why.
If the project uses `strong_migrations`, follow it. If it does not, apply the same safety rules manually.

**Common Mistakes**
| Mistake | Reality |
|---------|---------|
| "Table is small, no need for phased migration" | Tables grow. Build the habit for all migrations. |
| Schema change + backfill in one migration | Long transaction, long lock. Always separate them. |
| Column rename with immediate app cutover | App will crash during deploy. Use add-copy-migrate-drop. |
| `add_index` without `algorithm: :concurrent` | Exclusive lock on large PostgreSQL tables blocks writes. |
| Adding NOT NULL before backfill completes | Migration fails or locks table waiting for backfill. |
| Removing column before removing code references | App crashes when accessing the missing column. |

**Examples**
**Risky (avoid):**
```ruby
add_column :orders, :status, :string, default: 'pending', null: false
Order.update_all("status = 'pending'")
```
*Risk: Long lock; table rewrite if default is applied on large table.*

**Safe pattern:**
```ruby
# Step 1: add nullable column
add_column :orders, :status, :string

# Step 2 (separate deploy): backfill in batches outside migration

# Step 3 (after backfill): add constraint
change_column_null :orders, :status, false
change_column_default :orders, :status, from: nil, to: 'pending'
```

**Type change rollout pattern:**

```text
1. Add the new typed column as nullable.
2. Dual-write old and new columns from application code.
3. Backfill in batches outside the migration transaction.
4. Read from the new column after parity checks pass.
5. Stop writing the old column, then drop it in a later deploy.
```

- [PATTERNS.md](./PATTERNS.md)

## Output Style

1. List risks first.
2. For each risk include: Migration step, likely failure mode, explicit lock/table-rewrite risk, safer rollout, rollback or forward-fix note.
3. Ensure backwards compatibility steps are included.
4. Always include explicit phased patterns for column renames, type changes, and unique constraints. If one does not apply, mark it `Not applicable` and explain why.
5. Language — Must be in English unless explicitly requested otherwise.

## Integration

| Skill | When to chain |
|-------|---------------|
| **code-review** | When reviewing PRs that include migrations |
| **implement-background-job** | For backfill jobs that run after schema change |
| **security-check** | When migrations expose or move sensitive data |
