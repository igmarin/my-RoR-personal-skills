---
name: rails-engine-reviewer
description: Review existing Ruby on Rails engines for architecture, coupling, and maintainability. Use when reviewing an engine, mountable engine, engine.rb file, host-app integration, install generators, dummy app coverage, namespace boundaries, or Rails engine best practices.
---
# Rails Engine Reviewer

Use this skill when the task is to review an existing Rails engine or propose improvements.

Prioritize architectural risks over style comments. The main review targets are coupling, unclear host contracts, unsafe initialization, and weak integration coverage.

## Review Order

1. Identify the engine type and purpose.
2. Inspect the namespace and public API surface.
3. Check host-app integration points.
4. Check initialization and reload behavior.
5. Check migrations, generators, and install flow.
6. Check dummy-app and integration tests.
7. Summarize findings by severity.

## What Good Looks Like

- Clear namespace boundaries.
- `isolate_namespace` used when the engine owns routes/controllers/views.
- Small public API and explicit configuration surface.
- Minimal assumptions about host authentication, user model, jobs, assets, and persistence.
- Idempotent generators and documented setup.
- Integration tests through a dummy app.

## High-Severity Findings

Flag these first:

- Hidden dependency on a specific host model or constant.
- Initializers that mutate global state unsafely or perform writes at boot.
- Engine code reaching into host internals without an adapter or configuration seam.
- Migrations or setup steps that are implicit, undocumented, or destructive.
- Reload-unsafe decorators or patches outside `config.to_prepare`.

## Medium-Severity Findings

- Public API spread across many constants or modules.
- Engine routes/controllers not properly namespaced.
- Asset, helper, or route naming collisions.
- Missing generator coverage or weak install story.
- Dummy app present but not used for meaningful integration tests.

## Low-Severity Findings

- Inconsistent file layout.
- Overly clever metaprogramming where plain objects would be clearer.
- Readme/setup docs that drift from the code.

## Output Format

Write findings first. For each finding include:

- severity
- affected file or area
- why it is risky
- the smallest credible fix

Then include:

- open assumptions
- recommended next changes

If no meaningful findings exist, say so explicitly and mention any residual testing gaps.

## Common Fixes To Suggest

- Add a configuration object instead of hardcoded host constants.
- Move host integration behind adapters or service interfaces.
- Add `isolate_namespace`.
- Move reload-sensitive hooks into `config.to_prepare`.
- Add install generators for migrations or initializer setup.
- Add dummy-app request/integration coverage.
