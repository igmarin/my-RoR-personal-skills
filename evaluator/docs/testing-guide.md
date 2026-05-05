# Testing Guide: Evaluations & Workflows

This guide explains how to run evaluations and how to create new evaluation tasks for skills and workflows.

## Running Evaluations

The primary tool for running evaluations is the `bin/evaluate` script.

### Basic Usage

To run a specific evaluation task:
```bash
bin/evaluate --eval ../evals/skills/api/rails-graphql-best-practices/graphql-n-1-prevention-field-auth-and-mu
```

### Batch Processing

To run all evaluations within a category:
```bash
bin/evaluate --eval ../evals/skills/api
```
The evaluator will recursively find all `task.md` files in the directory and execute them in parallel.

### Overriding Skill Context

By default, the evaluator infers the skill path from the evaluation path. If you need to test an evaluation against a different skill:
```bash
bin/evaluate --eval ../evals/skills/patterns/ruby-service-objects/call-pattern-and-response-format --skill skills/custom-skill
```

## Creating New Evaluations

An evaluation task consists of a directory containing at least two files: `task.md` and `criteria.json`.

### 1. The Task (`task.md`)

This file contains the instructions for the AI agent. It should describe a specific problem to solve or a feature to implement. 

**Best Practices:**
- Provide clear context and requirements.
- Include a description of the current codebase state.
- Specify the desired outcome.

### 2. The Criteria (`criteria.json`)

This file defines the grading rubric used by the LLM Judge.

```json
[
  {
    "name": "Standard usage",
    "description": "The solution implements the .call pattern as specified in the skill.",
    "max_score": 50
  },
  {
    "name": "Error handling",
    "description": "The solution includes appropriate error handling and logging.",
    "max_score": 50
  }
]
```

**Fields:**
- `name`: A short label for the criterion.
- `description`: Detailed explanation of what the judge should look for.
- `max_score`: The maximum points awarded for this criterion (usually summing to 100).
- `conditional` (optional): If `true`, the judge will treat this as an N/A-safe rule.

## Evaluating Workflows vs. Skills

### Atomic Skills
Skills are isolated blocks of logic (e.g., a specific API pattern). Evaluations for skills should focus strictly on the adherence to the patterns defined in the skill's `SKILL.md`.

### Workflows
Workflows are sequences of skills or complex orchestrations (e.g., the full TDD loop). Evaluations for workflows should focus on the process, the ordering of tasks, and the successful completion of a multi-step objective. 

When running a workflow evaluation, ensure the `--eval` path points to the `evals/workflows/` directory.
