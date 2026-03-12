---
name: rails-engine-installers
description: Design install and setup flows for Ruby on Rails engines. Use when creating generators, copied migrations, initializer installers, route mount setup, idempotent install tasks, or improving host-app onboarding for an engine.
---
# Rails Engine Installers

Use this skill when the task is to design or review how a host app installs and configures a Rails engine.

Good installation flows are explicit, repeatable, and safe to rerun.

## Primary Goals

- Make host setup obvious.
- Keep setup idempotent.
- Prefer generated files over hidden runtime mutation.
- Keep operational steps documented and testable.

## Typical Responsibilities

- copy migrations into the host app
- create an initializer with configuration defaults
- add or document route mounting
- seed optional setup files or permissions
- expose a single install command when it improves usability

## Rules

- Never make boot-time code silently modify the host app.
- Prefer generators over manual copy-paste instructions when the setup is non-trivial.
- Generators must be safe to run more than once.
- If a route mount is required, either generate it carefully or document it explicitly.
- If migrations are required, treat them as host-owned changes and copy them rather than applying them automatically.

## Generator Checklist

- Files generated into the correct host paths
- No duplicate inserts on rerun
- Sensible defaults that are easy to edit
- Clear output telling the user what remains manual
- Tests that cover generated content and rerun behavior

## Common Patterns

- `install` generator for initializer plus route guidance
- `install:migrations` or copied migrations for persistence changes
- optional feature-specific generators for admin, jobs, or assets

## Review Triggers

Flag these problems:

- setup steps hidden inside initializers
- migrations implied but not installed
- route modifications that are brittle or duplicated
- generators that assume a specific host app layout without checks
- install docs that do not match the generator behavior

## Output Style

When asked to implement setup flow:

1. State what must be generated versus manually configured.
2. Implement the install path with idempotency in mind.
3. Add generator tests and concise user-facing instructions.
