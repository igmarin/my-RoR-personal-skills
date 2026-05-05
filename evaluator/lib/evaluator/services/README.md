# Evaluator Services

This module contains service objects that implement the Single Responsibility Principle for the `EvaluateCommand` class. Each service handles a specific aspect of the evaluation workflow with proper error handling and standardized response formats.

## Services Overview

### OptionParserService
Handles parsing of CLI arguments using Ruby's OptionParser. Provides standardized error handling for invalid flags and missing arguments.

**Responsibilities:**
- Parse command-line options (-e, -s, -o)
- Handle help flag (-h/--help) behavior
- Return standardized success/error responses

**Usage:**
```ruby
result = OptionParserService.call(['-e', 'evals/test', '-o', 'output.json'])
# => { success: true, response: { eval: 'evals/test', output: 'output.json' } }
```

### JudgeScoreParserService
Parses judge score responses from evaluation results. Handles JSON strings with optional markdown code blocks, Hash inputs, and provides error handling for malformed data.

**Responsibilities:**
- Parse JSON strings (with or without markdown code blocks)
- Convert Hash inputs with string/symbol keys
- Handle malformed data gracefully

**Usage:**
```ruby
result = JudgeScoreParserService.call('{"baseline_score": 80, "context_score": 90}')
# => { success: true, response: { "baseline_score" => 80, "context_score" => 90 } }
```

### ResultPrinterService
Formats and prints evaluation results to stdout. Handles both successful evaluations and error cases with proper formatting.

**Responsibilities:**
- Print formatted evaluation results with banners
- Display judge scores and reasoning
- Show baseline and context diffs
- Handle parse errors gracefully

**Usage:**
```ruby
result = ResultPrinterService.call(evaluation_result, stdout: string_io)
# => { success: true, response: {} }
```

### OutputPersistenceService
Persists evaluation results to JSON files with proper formatting and directory creation.

**Responsibilities:**
- Create parent directories if needed
- Write formatted JSON output
- Handle file system errors gracefully

**Usage:**
```ruby
result = OutputPersistenceService.call(evaluation_result, output_path: 'output.json')
# => { success: true, response: { message: 'Report saved to output.json' } }
```

## Response Contract

All services follow the standardized response contract:

```ruby
# Success response
{ success: true, response: { <data> } }

# Error response
{ success: false, response: { error: { message: 'human-readable reason' } } }
```

## Error Handling

Each service implements proper error handling:

- **OptionParserService**: Catches `OptionParser::ParseError` and returns standardized error responses
- **JudgeScoreParserService**: Handles `JSON::ParserError` and nil inputs gracefully
- **ResultPrinterService**: Uses JudgeScoreParserService internally and handles parse errors
- **OutputPersistenceService**: Catches `SystemCallError` for file system operations

## Testing

All services have comprehensive test coverage including:

- Success cases with various input formats
- Error cases and edge conditions
- Integration testing with the main EvaluateCommand
- Proper mocking of external dependencies

## Integration

The services are designed to work together within the `EvaluateCommand` class:

```ruby
def call
  # Parse options
  options_result = Services::OptionParserService.call(@argv)
  return 1 unless options_result[:success]
  
  # Run evaluation
  result = Evaluator::Runner.call(...)
  
  # Print results
  Services::ResultPrinterService.call(result, stdout: @stdout)
  
  # Persist output
  Services::OutputPersistenceService.call(result, output_path: options[:output])
  
  # Record history
  Evaluator::HistoryRecorder.record(...)
end
```

## Benefits

This refactoring provides:

1. **Single Responsibility**: Each service has one clear purpose
2. **Testability**: Services can be tested in isolation
3. **Reusability**: Services can be used independently in other contexts
4. **Maintainability**: Changes to specific functionality are isolated
5. **Error Handling**: Consistent error handling across all operations
6. **Documentation**: Comprehensive YARD documentation for all public methods
