---
name: ruby-service-objects
description: Create Ruby service objects following project conventions with module namespacing, YARD documentation, frozen_string_literal, constants, factory methods, the .call orchestrator pattern, standardized responses, transactions, and error handling. Use when creating new service classes, adding business logic classes, or refactoring code into service objects.
---

# Ruby Service Objects

## Structure

All service objects live under `app/services/` namespaced by module. Use `frozen_string_literal: true` in every file.

```
app/services/
└── module_name/
    ├── README.md              # Module documentation
    ├── main_service.rb        # Orchestrator service
    ├── validator.rb           # Input validation
    ├── classifier.rb          # Classification / decision logic
    ├── creator.rb             # Record creation / persistence
    ├── response_builder.rb    # API response construction
    ├── auth.rb                # Authentication (if external API)
    ├── client.rb              # HTTP client (if external API)
    ├── fetcher.rb             # Data retrieval / polling
    └── builder.rb             # Response transformation
```

## Core Patterns

### 1. The `.call` Pattern (Orchestrator)

The primary entry point for service objects. Use `self.call` + `new.call`:

```ruby
module AnimalTransfers
  class TransferService
    attr_reader :source_shelter_id, :target_shelter_id

    def self.call(params)
      new(params).call
    end

    def initialize(params)
      @source_shelter_id = params.dig(:source_shelter, :shelter_id)
      @target_shelter_id = params.dig(:target_shelter, :shelter_id)
    end

    def call
      validate_shelters!
      result = process_data
      build_success_response(result)
    rescue ActiveRecord::RecordInvalid => e
      log_error('Validation Error', e)
      build_error_response(e.message, [])
    rescue StandardError => e
      log_error('Processing Error', e, include_backtrace: true)
      build_error_response(e.message, [])
    end
  end
end
```

Variants for bang methods when side effects are the main purpose:

```ruby
def self.call!(promises:)
  new(promises:).call!
end
```

### 2. The `.call` with splat delegation

```ruby
def self.call(*, **)
  new(*, **).call
end

def self.call(**args)
  new(**args).call
end
```

### 3. Standardized Response Format

All services return a hash with `success:` and `response:` or `data:`/`error:`:

```ruby
# Success
{ success: true, response: { successful_items: [...] } }

# Success with data
{ success: true, data: { shelter_id: 1, items: [...], total_count: 5 } }

# Error
{ success: false, response: { error: { message: '...', failed_items: [...] } } }

# Simple error
{ success: false, error: 'shelter_id is required' }

# Partial success (success with error section)
{
  success: true,
  response: {
    successful_transfers: ['TAG001'],
    error: {
      message: 'Some animals were not found...',
      failed_transfers: ['TAG002']
    }
  }
}
```

### 4. Orchestrator Pattern

Main service coordinates sub-services, each with a single responsibility:

```ruby
def call
  validate_shelters!
  validate_shelter_codes!

  return empty_response if items.blank?

  classification = Classifier.classify(items, context)
  return all_failed_response(classification) if all_failed?(classification)

  persistence = Creator.create(classification, context)

  ResponseBuilder.success_response(classification, persistence)
rescue StandardError => e
  log_error('Processing Error', e, include_backtrace: true)
  ResponseBuilder.error_response(e.message)
end
```

### 5. Class-only Services (Static Methods)

When no instance state is needed, use only class methods:

```ruby
class ShelterValidator
  def self.validate_source_shelter!(shelter_id)
    shelter = Shelter.find_by(id: shelter_id)
    raise ArgumentError, 'Source shelter not found' unless shelter
    shelter
  end
end
```

### 6. Classifier Pattern

Separate classification/decision logic into its own service:

```ruby
class AnimalClassifier
  def self.classify_animals(tag_numbers, shelter)
    return empty_result if tag_numbers.empty?

    animals = Animal.where(tag_number: tag_numbers, shelter:).index_by(&:tag_number)
    holding_pens = HoldingPen.where(tag_number: tag_numbers, shelter:).index_by(&:tag_number)

    classify_all(tag_numbers, animals, holding_pens)
  end

  private_class_method :classify_all
end
```

### 7. Response Builder Pattern

Dedicated class for constructing API responses:

```ruby
class ResponseBuilder
  def self.success_response(shelter_id, result)
    { success: true, response: build_base_response(shelter_id, result[:items]) }
  end

  def self.error_response(shelter_id, message, failed_items)
    {
      success: false,
      response: {
        shelter: { shelter_id: },
        successful_items: [],
        error: { message:, failed_items: }
      }
    }
  end
end
```

## Conventions

### Module namespacing

```ruby
# frozen_string_literal: true

module ModuleName
  class ServiceName
    # class body
  end
end
```

Alternative (used for model-adjacent services):

```ruby
# frozen_string_literal: true

class HoldingPen::AnimalActivator
  # class body
end
```

### Constants for configuration

Define attributes, queries, error messages, and defaults as constants:

```ruby
MISSING_CONFIGURATION_ERROR = 'Missing required configuration'
DEFAULT_ERROR_MESSAGE = 'Transfer request not found; check IDs and tag_number for typos'
DEFAULT_TIMEOUT = 30
DESIRED_STATUS = 'new_rdr'
```

### Factory methods with `self.default`

Provide a `self.default` class method for default configuration from env vars:

```ruby
def self.default
  token = Auth.default.token
  host = Rails.configuration.secrets[:service_host]
  new(token:, host:)
end
```

### YARD documentation

Document every public method with `@param`, `@return`, `@raise`, and `@example`:

```ruby
# Main entry point for processing a transfer
# @param params [Hash] Transfer parameters
# @option params [Hash] :source_shelter Shelter hash with :shelter_id
# @option params [Array<String>] :tag_numbers_to_transfer List of animal tag numbers
# @return [Hash] Result hash with :success flag and :response data
def self.call(params)
```

### Input validation

Validate early in `initialize` or a dedicated `validate_params!` method:

```ruby
def initialize(token:, host:, warehouse_id:)
  raise Error, MISSING_CONFIGURATION_ERROR if [token, host, warehouse_id].any?(&:blank?)
end

# Or as a separate step:
def validate_params!
  raise ArgumentError, 'shelter_id is required' if shelter_id.blank?
  raise ArgumentError, 'IDs must be different' if source_id == target_id
end
```

### Bang validation methods

Use `!` suffix for methods that raise on invalid input:

```ruby
def validate_shelters!
  @source_shelter = ShelterValidator.validate_source_shelter!(source_shelter_id)
  @target_shelter = ShelterValidator.validate_target_shelter!(target_shelter_id)
end
```

### Transaction wrapping

Wrap multi-step database operations in transactions:

```ruby
def call
  animal = ActiveRecord::Base.transaction do
    animal = create_animal_from_holding_pen
    HoldingPen::AnimalActivator.call(animal:, holding_pen:)
    animal
  end
  Events::Animal.on_create(animal:)
  animal
end
```

### Graceful error handling

For non-critical operations, rescue and log without raising:

```ruby
def call
  return unless holding_pen
  update_holding_pen
rescue StandardError => e
  Rails.logger.warn("Error activating HoldingPen for tag #{animal.tag_number}: #{e.message}")
  nil
end
```

### Error logging with context

```ruby
def log_error(context, error, include_backtrace: false)
  Rails.logger.error("#{self.class.name} #{context}: #{error.class} - #{error.message}")
  Rails.logger.error(error.backtrace.join("\n")) if include_backtrace
end
```

### Custom error classes

```ruby
class Client
  class Error < StandardError; end
end
```

### SQL sanitization

Always use `ActiveRecord::Base.sanitize_sql` for dynamic queries:

```ruby
def self.find(tag_number:)
  query = ActiveRecord::Base.sanitize_sql(['SELECT * FROM table WHERE tag_number = ?;', tag_number])
  fetcher.execute_query(query)
end
```

### Batch operations with `activerecord-import`

```ruby
records = build_records(classifications)
result = Model.import(records, validate: true)
failed_items = result.failed_instances.map(&:identifier)
```

### Efficient lookups with `index_by`

```ruby
animals = Animal.where(tag_number: tag_numbers, shelter:).index_by(&:tag_number)
existing = Model.where(tag_number: tag_numbers).index_by(&:tag_number)
```

## README Documentation

Every service module should include a `README.md` with:
- Overview and purpose
- Architecture diagram (ASCII art showing component relationships)
- Core components with responsibilities
- Model information (attributes, validations, scopes)
- Automatic updates / side effects
- Rails console examples
- Error handling documentation
- Response structure examples
- Best practices
- Related models
- Testing information

## Checklist for new service objects

- [ ] `frozen_string_literal: true` pragma
- [ ] Module namespace matching directory structure
- [ ] `.call` class method as entry point
- [ ] Constants for error messages and defaults
- [ ] YARD docs on every public method
- [ ] Input validation (raise early on invalid input)
- [ ] Standardized `{ success:, response: }` return format
- [ ] Error wrapping with `rescue` and `log_error`
- [ ] Transaction wrapping for multi-step DB operations
- [ ] Graceful handling for non-critical failures
- [ ] SQL sanitization for dynamic queries
- [ ] `README.md` documenting the module

## Related skills

- **ruby-api-client-integration:** For external API integrations (Auth, Client, Fetcher, Builder, domain entities); same `app/services/` layout.
- **strategy-factory-null-calculator:** For variant-based calculators with a single entry point (Factory + Strategy + Null Object).
- **rspec-service-testing:** For testing service objects; **rspec-best-practices** for general RSpec structure.
