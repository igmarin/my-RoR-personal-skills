# Safe Migration: Adding Non-Nullable Column

## Problem/Feature Description

We need to add a `status` column (string, non-nullable, default: 'active') to our `Users` table. The table currently has **5 million rows** in production. 

Your task is to plan and write the migration following **Rails Migration Safety** principles to avoid downtime or table locks.

## Requirements

1.  Avoid adding a non-nullable column with a default in a single step (which causes a full table rewrite/lock).
2.  Plan a **phased rollout**:
    - Add the column as nullable.
    - Backfill existing rows in batches.
    - Add the `NOT NULL` constraint and default value separately.
3.  Include a "Post-deployment" check or step for the final constraint.
4.  Use `strong_migrations` style safety checks if applicable.

## Output Specification

Produce the following:
- A sequence of migration files (or a single plan with multiple steps).
- A brief explanation of why this phased approach is necessary for a large table.
- A batch backfilling script (ActiveRecord or SQL).
