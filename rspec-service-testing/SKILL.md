---
name: rspec-service-testing
description: Write RSpec tests for Ruby service objects using instance_double, FactoryBot hash factories, shared_examples, let blocks, subject, context/describe structure, aggregate_failures, change matchers, and travel_to. Use when writing tests for service classes, API clients, orchestrators, or any business logic in spec/services/.
---

# RSpec Service Testing

## File structure

Tests mirror the source tree:

```
spec/
├── services/
│   └── module_name/
│       ├── main_service_spec.rb
│       ├── validator_spec.rb
│       ├── classifier_spec.rb
│       ├── creator_spec.rb
│       └── response_builder_spec.rb
└── factories/
    └── module_name/
        └── entity_response_factory.rb
```

## Two Testing Styles

### 1. Unit tests (with `instance_double`)

For testing services in isolation. Use when the service has collaborators you want to mock:

```ruby
let(:client) { instance_double(Api::Client) }
let(:builder) { instance_double(Api::Builder) }

before do
  allow(client).to receive(:execute_query).and_return(response)
end
```

### 2. Integration tests (with `create`)

For testing services that interact with the database. Use for orchestrators and services that coordinate persistence:

```ruby
let(:source_shelter) { create(:shelter, :with_animals) }
let(:target_shelter) { create(:shelter, :with_animals) }

before do
  create(:species_info, shelter: target_shelter, species: 'Dog', breed_code: 'LAB')
end
```

## Test File Templates

### Template for `.call` orchestrator services

```ruby
# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ModuleName::MainService do
  describe '.call' do
    subject(:service_call) { described_class.call(params) }

    let(:shelter) { create(:shelter, :with_animals) }
    let(:params) do
      {
        shelter: { shelter_id: shelter.id },
        items: %w[TAG001 TAG002]
      }
    end

    context 'when input is valid' do
      before { create(:animal, tag_number: 'TAG001', shelter:) }

      it 'returns success' do
        expect(service_call[:success]).to be true
        expect(service_call[:response][:successful_items]).to include('TAG001')
      end
    end

    context 'when shelter is invalid' do
      let(:params) { super().merge(shelter: { shelter_id: 999_999 }) }

      it 'returns error response' do
        expect(service_call[:success]).to be false
        expect(service_call[:response][:error][:message]).to eq('Shelter not found')
      end
    end

    context 'when an unexpected error occurs' do
      before do
        allow(ModuleName::Classifier).to receive(:classify)
          .and_raise(StandardError, 'Unexpected error')
      end

      it 'rescues and returns error response' do
        expect(service_call[:success]).to be false
        expect(service_call[:response][:error][:message]).to eq('Unexpected error')
      end
    end
  end

  describe '#initialize' do
    it 'extracts parameters correctly' do
      service = described_class.new(params)
      expect(service.shelter_id).to eq(1)
    end

    context 'when optional params are missing' do
      it 'defaults to empty array' do
        service = described_class.new({ shelter: { shelter_id: 1 } })
        expect(service.items).to eq([])
      end
    end
  end
end
```

### Template for unit-tested services

```ruby
# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ModuleName::Client do
  let(:valid_params) { { token:, host:, warehouse_id: } }
  let(:token) { 'test_token' }
  let(:host) { 'test.example.com' }
  let(:warehouse_id) { 'wh123' }

  describe '#initialize' do
    context 'with valid parameters' do
      it 'creates an instance' do
        expect(described_class.new(**valid_params)).to be_a(described_class)
      end
    end

    context 'with invalid parameters' do
      it 'raises an error when token is blank' do
        expect do
          described_class.new(**valid_params.merge(token: ''))
        end.to raise_error(described_class::Error, described_class::MISSING_CONFIGURATION_ERROR)
      end
    end
  end
end
```

## Conventions

### Use `subject` for the main action under test

```ruby
describe '.call' do
  subject(:service_call) { described_class.call(params) }

  it 'returns success' do
    expect(service_call[:success]).to be true
  end
end

# Or unnamed:
subject { described_class.call(car:, parking_lot:) }
```

### Use `let` for test data, `before` only for stubbing

```ruby
let(:token) { 'test_token' }
let(:valid_params) { { token:, host: } }

before do
  allow(client).to receive(:execute_query).and_return(response)
end
```

### Ruby shorthand hash syntax in `let`

```ruby
let(:valid_params) { { token:, host:, warehouse_id: } }
```

### Context/describe structure

- `describe` for method grouping (`.class_method` or `#instance_method`)
- `context` for scenarios (`with valid...`, `when request fails...`)

```ruby
describe '.call' do
  context 'when all items succeed' do
    it 'returns success' do ...
  end

  context 'when some items fail' do
    it 'returns partial success' do ...
  end

  context 'when location is invalid' do
    it 'returns error response' do ...
  end
end
```

### `aggregate_failures` for multi-assertion tests

Use metadata or block form:

```ruby
it 'builds data with correct attributes', :aggregate_failures do
  result = fetcher.execute_query
  expect(result).to be_an(Array)
  expect(result.size).to eq(1)
  expect(result.first).to include('field1' => 'value1')
end

# Block form:
it 'validates correctly' do
  aggregate_failures do
    expect(result[:success]).to be true
    expect(result[:data][:items].size).to eq(3)
  end
end
```

### `described_class` for constants

```ruby
expect do
  described_class.new(**invalid_params)
end.to raise_error(described_class::Error, described_class::MISSING_CONFIGURATION_ERROR)
```

### `change` matchers for state verification

```ruby
it 'creates records' do
  expect { service_call }.to change(AnimalTransfer, :count).by(2)
end

it 'does not create duplicates' do
  expect { service_call }.not_to change(AnimalTransfer, :count)
end

# Chained change matchers with .and:
it 'updates status and clears date' do
  expect { subject }
    .to change { record.reload.status }.from('pending').to('transferred')
    .and change { record.reload.transferred_at }.to(be_present)
end

# not_change combined with change:
it 'updates only affected records' do
  expect { subject }
    .to not_change { unaffected_records.pluck(:status) }
    .and change { affected_record.reload.status }.from('old').to('new')
end
```

### `from/to` with complex state changes

```ruby
it 'updates multiple fields' do
  expect { subject }.to change {
    [record.reload.status, record.reload.name, record.reload.tag_number]
  }
    .from(['pending', nil, nil])
    .to(['transferred', 'Max', 'TAG001'])
end
```

### `match_array` for unordered comparison

```ruby
expect(result[:successful_transfers]).to match_array(%w[TAG001 TAG002])
expect(tag_numbers).to contain_exactly('TAG_A', 'TAG_B')
```

### `include` for partial hash matching

```ruby
expect(first_record).to include(
  'tag_number' => 'ANIMAL-001',
  'status' => 'active',
  'shelter_id' => 100
)
```

### Mock HTTP responses with `instance_double`

```ruby
let(:mock_response) do
  instance_double(
    HTTParty::Response,
    body: response_body,
    success?: true,
    code: 200
  )
end
```

### `receive_messages` for multi-stub setup

```ruby
before do
  allow(client).to receive_messages(
    execute_query: { 'statement_id' => statement_id },
    get_statement_status: success_response
  )
end
```

### `have_received` for verifying calls after the fact

```ruby
it 'publishes an event' do
  subject
  expect(Events::Animal).to have_received(:on_create).with(animal:).once
end

it 'does not trigger side effect' do
  subject
  expect(SomeService).not_to have_received(:process!)
end
```

### `travel_to` for time-dependent tests

```ruby
let(:date) { Time.utc(2024, 8, 30, 19, 0, 20) }

before { travel_to date }
```

### Stub constants in tests

```ruby
before { stub_const('ModuleName::Fetcher::RETRY_DELAY_IN_SECONDS', 0) }
```

### Logger expectations

```ruby
before { allow(Rails.logger).to receive(:error) }

it 'logs the error' do
  expect(Rails.logger).to have_received(:error).with(/Processing Error/)
end

it 'logs errors without raising' do
  allow(Model).to receive(:where).and_raise(StandardError, 'SQL Error')
  expect { subject }.not_to raise_error
  expect(Rails.logger).to have_received(:error).with(/SQL Error/)
end
```

## Shared Examples

Use `shared_examples` to DRY up repeated test scenarios:

```ruby
shared_examples 'creates animal and updates holding pen' do
  it 'creates an Animal from the HoldingPen record' do
    expect { subject }.to change { Animal.count }.by(1)
    animal = Animal.last
    expect(animal.tag_number).to eq(holding_pen.tag_number)
    expect(animal.name).to eq('Max')
  end

  it 'updates the HoldingPen status to transferred' do
    expect { subject }.to change { holding_pen.reload.status }
      .from('pending').to('transferred')
  end
end

shared_examples 'when error occurs' do
  it 'does not create a record' do
    expect do
      subject
    rescue StandardError
      nil
    end.not_to change { Animal.count }
  end

  it 'does not publish events' do
    begin
      subject
    rescue StandardError
      nil
    end
    expect(Events::Animal).not_to have_received(:on_create)
  end
end

# Using shared examples:
it_behaves_like 'creates animal and updates holding pen'

context 'when shelter not found' do
  let(:shelter_ids) { [9999] }

  it_behaves_like 'when error occurs'

  it 'raises ActiveRecord::RecordNotFound' do
    expect { subject }.to raise_error(ActiveRecord::RecordNotFound)
  end
end
```

## Testing Error Scenarios

Always test these error cases:

### Blank/nil inputs

```ruby
context 'when shelter_id is missing' do
  let(:params) { {} }

  it 'returns error' do
    expect(result[:success]).to be false
    expect(result[:error]).to eq('shelter_id is required')
  end
end
```

### Invalid references

```ruby
context 'when shelter does not exist' do
  let(:params) { { shelter_id: 999_999 } }

  it 'returns error' do
    expect(result[:success]).to be false
  end
end
```

### Failed HTTP requests / JSON parsing / network errors

```ruby
context 'when request fails' do
  let(:error_response) do
    instance_double(HTTParty::Response, body: '{"error": "fail"}', success?: false, code: 400)
  end

  it 'raises an error with response details' do
    expect { action }.to raise_error(Service::Error, /Request failed/)
  end
end

context 'when JSON parsing fails' do
  let(:mock_response) do
    instance_double(HTTParty::Response, body: 'invalid json', success?: true, code: 200)
  end

  it 'raises an error' do
    expect { action }.to raise_error(Service::Error, /Request failed:/)
  end
end
```

### Partial failures

```ruby
context 'when some items fail' do
  it 'returns success with error section' do
    expect(result[:success]).to be true
    expect(result[:response][:successful_items]).to include('TAG001')
    expect(result[:response][:error][:failed_items]).to include('TAG002')
  end
end
```

### Graceful error handling

```ruby
context 'when non-critical operation fails' do
  before do
    allow(Service).to receive(:call).and_raise(StandardError, 'Enrollment failed')
  end

  it 'completes main operation without raising' do
    expect { subject }.to change { Model.count }.by(1)
  end

  it 'logs the error' do
    expect(Rails.logger).to receive(:error).with(/Enrollment failed/)
    subject
  end
end
```

## FactoryBot Hash Factories for API Responses

For external API response fixtures, use FactoryBot with `class: Hash`:

```ruby
FactoryBot.define do
  factory :api_entity_response, class: Hash do
    transient do
      field1 { FFaker::Name.first_name }
      field2 { FFaker::Random.rand(1..1000) }
      statement_id { 'test-statement-id' }
    end

    initialize_with do
      columns = ModuleName::Entity::ATTRIBUTES.map do |attr|
        { 'name' => attr, 'type_text' => 'STRING' }
      end
      data_values = [field1, field2]

      {
        'statement_id' => statement_id,
        'status' => { 'state' => 'SUCCEEDED' },
        'manifest' => { 'schema' => { 'columns' => columns } },
        'result' => { 'data_array' => [data_values] }
      }
    end
  end
end
```

Use in tests: `build(:factory_name, field1: 'custom_value')`

## Checklist for new test files

- [ ] `frozen_string_literal: true` pragma
- [ ] `require 'spec_helper'`
- [ ] `subject` defined for main action
- [ ] `instance_double` for unit tests / `create` for integration tests
- [ ] Test `#initialize` with valid and invalid params
- [ ] Test happy path for each public method
- [ ] Test error/edge cases (blank input, invalid refs, failures)
- [ ] Test partial success scenarios
- [ ] `shared_examples` for repeated test patterns
- [ ] `aggregate_failures` for multi-assertion tests
- [ ] `change` matchers for state verification
- [ ] Logger expectations for error logging
- [ ] Constants referenced via `described_class`
- [ ] FactoryBot hash factory for API responses (if applicable)
