---
name: rails-engine-compatibility
description: Maintain compatibility for Ruby on Rails engines across Rails and Ruby versions. Use when checking Zeitwerk, autoloading, Rails upgrades, dependency bounds, asset integration, Active Job or Action Mailer hooks, or cross-version engine support.
---
# Rails Engine Compatibility

Use this skill when the task is to make an engine stable across framework versions and host environments.

Compatibility work should reduce surprises for host applications. Prefer explicit support targets over accidental compatibility.

## Core Checks

1. Define supported Ruby and Rails versions.
2. Check autoloading and Zeitwerk expectations.
3. Check initializer behavior across boot and reload.
4. Check dependency bounds in the gemspec.
5. Check optional integrations such as jobs, mailers, assets, and routes.
6. Verify the test matrix matches the claimed support policy.

## Important Areas

- Zeitwerk naming and file paths
- deprecated Rails APIs
- middleware or railtie hooks
- engine assets and precompile expectations
- migration compatibility
- configuration defaults that changed between Rails versions

## Rules

- Do not claim support for versions that are not tested.
- Keep dependency constraints honest and narrow enough to be meaningful.
- Prefer feature detection or adapter seams over version-specific branching when practical.
- If branching by version is necessary, isolate it and test both paths.

## Common Review Findings

- file naming incompatible with Zeitwerk
- broad gemspec constraints without matrix coverage
- deprecated initializer hooks
- assumptions tied to a single asset stack
- tests only on one Rails version while README claims many

## Output Style

When asked to improve compatibility:

1. State the support matrix being targeted.
2. List the most likely breakpoints.
3. Make compatibility changes in isolated, testable seams.
4. Recommend matrix coverage if it does not exist.
