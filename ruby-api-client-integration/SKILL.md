---
name: ruby-api-client-integration
description: Build Ruby API client integrations using the layered Auth, Client, Fetcher, Builder, and Domain entity pattern. Use when integrating with external APIs, creating HTTP clients, building data pipelines from external services, or adding new API consumers.
---

# Ruby API Client Integration

Follow **ruby-service-objects** for shared conventions (YARD, constants, response format, `app/services/` layout). This skill adds the layered Auth → Client → Fetcher → Builder → Domain Entity pattern for external APIs.

## Architecture

External API integrations follow a 5-layer architecture. Each layer has a single responsibility:

```
Auth → Client → Fetcher → Builder → Domain Entity
```

| Layer | Responsibility | File |
|-------|---------------|------|
| **Auth** | OAuth/token management | `auth.rb` |
| **Client** | HTTP requests & response parsing | `client.rb` |
| **Fetcher** | Query orchestration, polling, pagination | `fetcher.rb` |
| **Builder** | Response → structured data transformation | `builder.rb` |
| **Domain Entity** | Domain-specific config & query definitions | `entity.rb` |

## Layer details

### 1. Auth (`auth.rb`)

Handles authentication. Caches tokens. Provides `self.default` from env vars.

```ruby
module ServiceName
  class Auth
    include HTTParty

    DEFAULT_TIMEOUT = 30

    def self.default
      new(
        client_id: Rails.configuration.secrets[:service_client_id],
        client_secret: Rails.configuration.secrets[:service_client_secret],
        account_id: Rails.configuration.secrets[:service_account_id]
      )
    end

    def initialize(client_id:, client_secret:, account_id:, timeout: DEFAULT_TIMEOUT)
      raise 'Missing required credentials' if [client_id, client_secret, account_id].any?(&:blank?)
      # configure base_uri and options
      @token = nil
    end

    def token
      return @token if @token
      # fetch and cache token
    end

    def authenticated?
      !@token.nil?
    end

    def clear_token
      @token = nil
    end
  end
end
```

### 2. Client (`client.rb`)

Wraps HTTP calls. Validates inputs. Parses responses. Raises `Client::Error`.

```ruby
module ServiceName
  class Client
    include HTTParty

    MISSING_CONFIGURATION_ERROR = 'Missing required configuration'
    DEFAULT_TIMEOUT = 30
    DEFAULT_RETRIES = 3

    class Error < StandardError; end

    def self.default
      token = Auth.default.token
      host = Rails.configuration.secrets[:service_host]
      new(token:, host:)
    end

    def initialize(token:, host:, timeout: DEFAULT_TIMEOUT, max_retries: DEFAULT_RETRIES)
      raise Error, MISSING_CONFIGURATION_ERROR if [token, host].any?(&:blank?)
      # configure HTTParty
    end

    def execute_query(payload)
      # POST, parse JSON, raise on failure
    rescue JSON::ParserError, HTTParty::Error => e
      raise Error, "Request failed: #{e.message}"
    end
  end
end
```

### 3. Fetcher (`fetcher.rb`)

Orchestrates query execution. Handles polling for async APIs. Manages pagination.

```ruby
module ServiceName
  class Fetcher
    MAX_RETRIES = 3
    RETRY_DELAY_IN_SECONDS = 2

    # @param client [#execute_query, #get_statement_status] API client
    # @param data_builder [#build] Object that transforms raw responses
    # @param default_query [String] Default query/payload
    def initialize(client, data_builder:, default_query:)
      @client = client
      @data_builder = data_builder
      @default_query = default_query
    end

    def execute_query(query = @default_query)
      raw_response = @client.execute_query(query)
      # poll if async, paginate if needed
      @data_builder.build(complete_response)
    end
    alias query execute_query
  end
end
```

Key patterns:
- Accepts dependencies via constructor (DI)
- Delegates HTTP to Client, transformation to Builder
- Handles retry with exponential backoff: `sleep(RETRY_DELAY_IN_SECONDS**retries)`
- Handles pagination by fetching all chunks and combining data

### 4. Builder (`builder.rb`)

Transforms raw API response into an array of attribute-filtered hashes.

```ruby
module ServiceName
  class Builder
    # @param attributes [Array<String>] Whitelist of attributes to include
    def initialize(attributes:)
      @attributes = attributes
    end

    # @param response [Hash] Raw API response
    # @return [Array<Hash>] Array of filtered data hashes
    def build(response)
      schema = response['manifest']['schema']['columns']
      data_array = response['result']['data_array'] || []

      data_array.map do |row|
        data_hash = schema.each_with_index.with_object({}) do |(col, index), hash|
          hash[col['name']] = row[index]
        end.with_indifferent_access

        data_hash.slice(*@attributes)
      end
    end
  end
end
```

### 5. Domain Entity (e.g., `animal.rb`)

Defines domain-specific constants and wires up the layers.

```ruby
module ServiceName
  class Animal
    ATTRIBUTES = %w[tag_number name species_id shelter_id].freeze
    DEFAULT_QUERY = 'SELECT * FROM schema.animals;'
    SEARCH_QUERY = 'SELECT * FROM schema.animals WHERE tag_number = ?;'

    def self.fetcher(client: Client.default)
      data_builder = Builder.new(attributes: ATTRIBUTES)
      Fetcher.new(client, data_builder:, default_query: DEFAULT_QUERY)
    end

    def self.find(tag_number:)
      query = ActiveRecord::Base.sanitize_sql([SEARCH_QUERY, tag_number])
      fetcher.execute_query(query)
    end

    def self.search(search_query:)
      query = ActiveRecord::Base.sanitize_sql([SEARCH_QUERY, search_query])
      fetcher.execute_query(query)
    end
  end
end
```

Domain entity patterns:
- `ATTRIBUTES` constant: whitelist of fields to return
- `DEFAULT_QUERY` constant: full-table query
- `SEARCH_QUERY` constant: parameterized query with `?` placeholders
- `.fetcher` factory method: wires Client + Builder + Fetcher
- `.find` / `.search` class methods: sanitize SQL and delegate to fetcher

## Adding a new domain entity

1. Define `ATTRIBUTES`, `DEFAULT_QUERY`, and optionally `SEARCH_QUERY` constants
2. Implement `.fetcher` class method wiring `Builder` and `Fetcher`
3. Add `.find` or `.search` class methods with `sanitize_sql`
4. Create a FactoryBot hash factory in `spec/factories/module_name/`
5. Write spec in `spec/services/module_name/` covering `.fetcher`, `.find`/`.search`

## Usage from application code

```ruby
# Fetch all records
data = ServiceName::Animal.fetcher.execute_query

# Find by identifier
record = ServiceName::Animal.find(tag_number: 'ANIMAL-001')

# Search with custom query
results = ServiceName::EmployeeLocation.search(search_query: 'john')

# Custom client
client = ServiceName::Client.new(token: custom_token, host: custom_host)
data = ServiceName::Animal.fetcher(client:).execute_query
```

## Checklist for new API integration

- [ ] Create module directory under `app/services/`
- [ ] Implement `Auth` with `self.default` and token caching
- [ ] Implement `Client` with `self.default`, `Error` class, and error wrapping
- [ ] Implement `Fetcher` with polling/pagination if needed
- [ ] Implement `Builder` with attribute filtering
- [ ] Create domain entities with constants and `.fetcher`
- [ ] Add `readme.md` with usage examples and error handling docs
- [ ] Write comprehensive specs for all layers
- [ ] Create FactoryBot hash factories for API responses

## Related skills

- **ruby-service-objects:** Base conventions (`.call`, responses, transactions, README). **rspec-service-testing** and **rspec-best-practices** for specs.
