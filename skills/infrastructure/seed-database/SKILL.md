---
name: seed-database
license: MIT
description: >
  Manage development and test data in Rails. Covers fixtures vs seeds,
  seeding strategies for different environments, test data factories,
  and production-like data generation. Use when the user asks about setting
  up seed data, creating test fixtures, or generating development data in a
  Rails application. Trigger words: seeds, fixtures, seeding, database seed,
  test data, development data, db:seed.
metadata:
  version: 1.0.0
  user-invocable: "true"
---
# Seed Database

Manage development and test data effectively.

**Files:** [SKILL.md](./SKILL.md) · [EXAMPLES.md](./EXAMPLES.md) · [references/workflow.md](./references/workflow.md)

## HARD-GATE

```text
NEVER commit production data to seeds
ALWAYS use factories for test-specific scenarios
ALWAYS make seeds idempotent (can run multiple times safely)
NEVER hardcode credentials (passwords, API keys, secrets) in seeds, factories, or examples
  - Use ENV variables (e.g., ENV.fetch('DEFAULT_SEED_PASSWORD')) or SecureRandom.hex(16) for non-production data
  - Use `rails credentials:edit` to manage production secrets, never commit them in code
```

## Quick Reference

| Use | Solution |
|-----|----------|
| Static reference data | `db/seeds.rb` with `find_or_create_by!` |
| Test scenarios | FactoryBot in `spec/factories/` |
| Complex relationships | Both combined |

## Seeding Workflow

1. **Write idempotent seeds** — use `find_or_create_by!` so re-runs are safe.
2. **Scope by environment** — guard non-production data with `Rails.env` checks.
3. **Run seeds** — execute `rails db:seed` (or `rails db:setup` for a fresh database).
4. **Validate idempotency** — run `rails db:seed` a second time and confirm no duplicates or errors.
5. **Verify data** — open `rails console` and spot-check expected records exist with correct attributes.

See [references/workflow.md](references/workflow.md) for the complete seeding workflow.

## Idempotent Seeds

```ruby
# db/seeds/development.rb
10.times do
  User.find_or_create_by!(email: Faker::Internet.unique.email) do |u|
    u.password = ENV.fetch('DEFAULT_SEED_PASSWORD', SecureRandom.hex(16))
  end
end
```

## Environment-Specific Seeds

```ruby
# db/seeds.rb
if Rails.env.development?
  require Rails.root.join('db/seeds/development')
elsif Rails.env.test?
  require Rails.root.join('db/seeds/test')
end

# db/seeds/development.rb
10.times do
  User.find_or_create_by!(email: Faker::Internet.unique.email) do |u|
    u.password = ENV.fetch('DEFAULT_SEED_PASSWORD', SecureRandom.hex(16))
  end
end
```

## FactoryBot Factory Example

```ruby
# spec/factories/users.rb
FactoryBot.define do
  factory :user do
    email { Faker::Internet.unique.email }
    password { ENV.fetch('DEFAULT_SEED_PASSWORD', SecureRandom.hex(16)) }

    trait :admin do
      admin { true }
    end
  end
end
```

## Examples

See [EXAMPLES.md](EXAMPLES.md) for complete examples including:
- Environment-specific seed structure
- FactoryBot factories with traits
- Idempotent seed patterns
- Troubleshooting common issues

## External References

- [FactoryBot documentation](https://github.com/thoughtbot/factory_bot/blob/main/GETTING_STARTED.md)
- [Faker gem](https://github.com/faker-ruby/faker)
- [Rails Seeding Guide](https://guides.rubyonrails.org/active_record_migrations.html#migrations-and-seed-data)
