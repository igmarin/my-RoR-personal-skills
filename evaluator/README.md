# Rails Agent Evaluator

Rails Agent Evaluator compares how an LLM coding agent performs with and without Rails skill context. It runs each task in an isolated git sandbox, captures the resulting diffs, and asks a judge model to score the baseline and context-hydrated runs.

## Installation

From this repository:

```bash
cd evaluator
bundle install
```

To build the gem locally:

```bash
gem build agent_evaluator.gemspec
```

## Usage

Run an evaluation target with convention-based source inference:

```bash
bin/evaluate --eval ../evals/skills/patterns/ruby-service-objects/call-pattern-and-response-format
```

The evaluator maps `evals/skills/<category>/<skill>/...` to `skills/<category>/<skill>` and `evals/workflows/<workflow>/...` to `workflows/<workflow>`. Use `--skill` only when you need to override that convention:

```bash
bin/evaluate \
  --eval ../evals/workflows/rails-tdd-loop/tdd-workflow-and-test-first-discipline \
  --skill workflows/rails-tdd-loop
```

## Configuration

The evaluator reads provider configuration from environment variables or `evaluator.json`.

- `OPENAI_API_KEY` for OpenAI
- `GEMINI_API_KEY`, `GEMINI_PROJECT_ID`, and `GEMINI_LOCATION` for Gemini

See `lib/config.rb` for the full configuration precedence and defaults.

## Development

```bash
bundle exec rake test
bundle exec rake rubocop
```

The default rake task runs RuboCop and the test suite.
