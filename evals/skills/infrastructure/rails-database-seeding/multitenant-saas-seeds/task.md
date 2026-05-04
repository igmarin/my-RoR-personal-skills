# Design Seeds for a Multi-Tenant SaaS App

## Problem/Feature Description

The `WorkflowHub` SaaS application has three tiers of data:
1. **System seeds** — Plans, feature flags, and default settings that must always exist in every environment
2. **Development seeds** — Realistic sample organizations, users, and workflows for local development
3. **Test fixtures** — Minimal, deterministic data for fast tests

The schema is provided below. Extract it before beginning.

=============== FILE: db/schema.rb (excerpt) ===============
ActiveRecord::Schema[7.1].define do
  create_table :plans do |t|
    t.string  :name, null: false        # "starter", "growth", "enterprise"
    t.integer :max_users, null: false
    t.integer :max_workflows, null: false
    t.boolean :active, default: true
    t.timestamps
  end

  create_table :organizations do |t|
    t.string  :name, null: false
    t.integer :plan_id, null: false
    t.string  :subdomain, null: false, index: { unique: true }
    t.timestamps
  end

  create_table :users do |t|
    t.string  :email, null: false, index: { unique: true }
    t.string  :role, default: "member"   # "admin", "member", "viewer"
    t.integer :organization_id, null: false
    t.timestamps
  end

  create_table :workflows do |t|
    t.string  :name, null: false
    t.string  :status, default: "draft"  # "draft", "active", "archived"
    t.integer :organization_id, null: false
    t.integer :created_by_id, null: false  # user_id
    t.timestamps
  end
end
=============== END FILE ===============

## Output Specification

Produce:

- `db/seeds.rb` — The main seed file that calls `Seeds::System.run` and, in development only, `Seeds::Development.run`
- `db/seeds/system.rb` — Creates the 3 plans (starter, growth, enterprise) using `find_or_create_by!` with their correct limits
- `db/seeds/development.rb` — Creates 2 sample organizations (each on a different plan), 3 users per org (1 admin, 2 members), and 2 workflows per org
- `spec/support/fixtures/plans.yml` — YAML fixture for the 3 plans (for use in tests)

Use `find_or_create_by!` throughout so seeds are idempotent. Add `puts` progress messages.
