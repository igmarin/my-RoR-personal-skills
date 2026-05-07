# Personal Evaluations Framework

This directory contains gold-standard evaluation scenarios for measuring the effectiveness of the skills and workflows in this repository.

## The Goal: Measuring "Lift"

Every evaluation is designed to be run in two modes:
1.  **Baseline:** Raw LLM with no repository context.
2.  **With Context:** LLM provided with the relevant `SKILL.md` (and auxiliary files).

The goal is to prove that our skills provide a significant improvement over the base model's default behavior.

## Scenario Structure

Each evaluation lives in its own directory (e.g., `skill-ruby-service-objects/`) and must contain:

### 1. `task.md` (The Prompt)
A complex, representative scenario that forces the agent to use the skill's specific instructions.
- **Complexity:** Avoid simple tasks. Give the agent "messy" code to refactor or complex requirements to implement.
- **Context:** Provide enough background info to make the task realistic.

### 2. `criteria.json` (The Rubric)
A weighted checklist that evaluates adherence to our **strict conventions** and **hard-gates**.
- **Focus:** Don't just evaluate if the code works. Evaluate *how* it was built.
- **Convention over generic:** Reward specific naming, structure, and documentation requirements defined in the skill.
- **Weighted Scores:** Assign higher points to non-negotiable hard-gates.

## Best Practices

- **Read-Only:** These scenarios are for evaluation only. Do not "fix" the provided messy code in the `task.md` inputs.
- **Representative:** Scenarios should mimic the actual work a Senior Rails Engineer would do.
- **Isolation:** Each folder should test exactly one skill or workflow.

## Running Evaluations

Use the `rails-agent-eval` gem to execute these scenarios.
