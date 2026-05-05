# Rails Agent Evaluator

Rails Agent Evaluator is a specialized tool for measuring and comparing how an LLM coding agent performs with and without Rails skill context. It enables data-driven optimization of prompt engineering and skill design by providing empirical scores across isolated evaluation tasks.

## Table of Contents

1. [How It Works](#how-it-works)
2. [Installation](#installation)
3. [Configuration](#configuration)
4. [Usage](#usage)
5. [Documentation](#documentation)
6. [Development](#development)

## How It Works

The evaluator follows a systematic process for each task:
1. **Isolation**: Executes the task in a Git-sandboxed directory.
2. **Baseline Run**: Runs the agent without any extra context.
3. **Hydrated Run**: Injects specific skill/workflow context via XML and runs the agent.
4. **Grading**: Uses a "Judge" LLM to compare both results against a set of `criteria.json` and provide a score.

See [Architecture Guide](docs/architecture.md) for more technical details.

## Installation

Ensure you have Ruby installed, then from the `evaluator/` directory:

```bash
cd evaluator
bundle install
```

To build and install the gem locally:

```bash
gem build agent_evaluator.gemspec
gem install ./agent_evaluator-*.gem
```

## Configuration

The evaluator uses a hierarchical configuration system. It looks for settings in this order of precedence (highest to lowest):

1. **Environment Variables**: `OPENAI_API_KEY`, `GEMINI_API_KEY`, `GEMINI_LOCATION`, etc.
2. **Local Config**: `evaluator.json` in the current working directory.
3. **Global Config**: `~/.evaluator.json` in your home directory.
4. **Code Defaults**: Hardcoded fallbacks in `lib/config.rb`.

### Sample `evaluator.json`

```json
{
  "current_llm_provider": "gemini",
  "providers": {
    "gemini": {
      "model": "gemini-1.5-flash-latest",
      "location": "us-central1",
      "project_id": "your-project-id"
    }
  }
}
```

## Usage

Run an evaluation target with convention-based source inference:

```bash
bin/evaluate --eval ../evals/skills/patterns/ruby-service-objects/call-pattern-and-response-format
```

For more advanced usage and how to write tests, see the [Testing Guide](docs/testing-guide.md).

## Documentation

- [Architecture Guide](docs/architecture.md): Deep dive into internal components.
- [Testing Guide](docs/testing-guide.md): How to create and run evaluation tasks.

## Development

```bash
bundle exec rake test
bundle exec rake rubocop
bundle exec rake package:verify
```

The default rake task runs RuboCop and the test suite. `package:verify` builds the gem and checks that required release files are present. All new code must follow the project's TDD and engineering standards.
