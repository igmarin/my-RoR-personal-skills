# Create a Rails Install Generator for the AnalyticsSuite Engine

## Problem/Feature Description

The `AnalyticsSuite` Rails engine needs an install generator so that host applications can bootstrap themselves with a single `rails generate analytics_suite:install` command.

The generator should:
1. Create an initializer at `config/initializers/analytics_suite.rb`
2. Copy the migration `create_analytics_events` into the host app's `db/migrate/`
3. Mount the engine routes in the host app's `config/routes.rb`
4. Print a helpful post-install message to the console

The migration template and routes snippet are provided below. Extract them before beginning.

=============== FILE: lib/generators/analytics_suite/templates/initializer.rb ===============
# frozen_string_literal: true

AnalyticsSuite.configure do |config|
  config.api_key = ENV.fetch('ANALYTICS_SUITE_KEY', nil)
  config.flush_interval = 60 # seconds
end
=============== END FILE ===============

=============== FILE: lib/generators/analytics_suite/templates/create_analytics_events.rb ===============
# frozen_string_literal: true

class CreateAnalyticsEvents < ActiveRecord::Migration[7.1]
  def change
    create_table :analytics_events do |t|
      t.string  :event_name, null: false
      t.jsonb   :properties, default: {}
      t.integer :user_id
      t.timestamps
    end
  end
end
=============== END FILE ===============

## Output Specification

Produce:

- `lib/generators/analytics_suite/install/install_generator.rb` — The Rails install generator class
- `lib/generators/analytics_suite/install/templates/initializer.rb` — (link or copy the provided template)

The generator class must:
- Inherit from `Rails::Generators::Base`
- Include `Rails::Generators::Migration` for migration support
- Implement `self.next_migration_number` correctly
- Use `copy_file` for the initializer and `migration_template` for the migration
- Use `route` to inject the engine mount into `config/routes.rb`
- End with a `say` call that prints the post-install instructions
