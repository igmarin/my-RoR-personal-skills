# rails-agent-eval

`rails-agent-eval` is a standalone evaluation engine designed to validate AI agent skills and workflows. It orchestrates side-by-side execution runs (baseline vs. context-hydrated) within isolated Git sandboxes and uses an LLM judge to score the results based on predefined criteria.

This engine is the core validation tool for the [rails-agent-skills](https://github.com/igmarin/rails-agent-skills) library.

## Features

- **Side-by-Side Evaluation**: Compare an agent's performance with and without specific skill context.
- **Isolated Sandboxes**: Every run happens in a temporary Git repository to ensure clean, traceable diffs.
- **LLM-Powered Judging**: Automatic scoring of code changes against task-specific criteria.
- **ReAct Loop**: Uses a sophisticated Thought/Tool/Observation loop for complex multi-step tasks.
- **Support for Skills & Workflows**: Handles both atomic tools and multi-stage instruction sets.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rails-agent-eval', github: 'igmarin/rails-agent-eval'
```

And then execute:

```bash
bundle install
```

## Usage

### 1. Define your Evals

Create an evaluation scenario directory with two files:
- `task.md`: The instruction for the agent.
- `criteria.json`: The scoring rules for the LLM judge.

Example structure:
```text
evals/
└── my-skill/
    └── scenario-1/
        ├── task.md
        └── criteria.json
```

### 2. Run the Evaluator

Use the `evaluate` CLI tool:

```bash
bundle exec evaluate --eval evals/my-skill/scenario-1 --skill skills/my-skill
```

## Development

After cloning the repo, run `bundle install` to install dependencies. Then, run `bundle exec rake test` to run the tests.

## License

The gem is available as open source under the terms of the [MIT License](LICENSE).
