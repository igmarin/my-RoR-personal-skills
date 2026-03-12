---
name: refactor-safely
description: Plan and execute low-risk refactors in Ruby and Rails codebases. Use when restructuring code, renaming abstractions, extracting services or modules, reducing duplication, or making internal changes while preserving behavior.
---
# Refactor Safely

Use this skill when the task is to change structure without changing intended behavior.

Prefer small, reversible steps over large rewrites. Separate design improvement from behavior change whenever possible.

## Refactoring Order

1. Define the behavior that must stay stable.
2. Add or tighten characterization tests around that behavior.
3. Choose the smallest safe slice.
4. Rename, move, or extract in steps that keep the code runnable.
5. Remove compatibility shims only after the new path is proven.

## Core Rules

- Split behavior changes from structural refactors when practical.
- Keep public interfaces stable until callers are migrated.
- Extract one boundary at a time.
- Prefer adapters, facades, or wrappers for transitional states.
- Stop and simplify if the refactor introduces more indirection than clarity.

## Good First Moves

- rename unclear methods or objects
- isolate duplicated logic behind a shared object
- extract query or service objects from repeated workflows
- wrap external integrations before moving call sites
- add narrow seams before deleting old code paths

## Red Flags

- refactor plan requires touching many unrelated call sites at once
- no tests prove current behavior
- structural cleanup is mixed with new feature work
- old and new paths diverge without a migration plan
- new abstractions exist only to satisfy a pattern, not a real boundary

## Output Style

When asked to refactor:

1. State the stable behavior that must not change.
2. Propose the smallest safe sequence.
3. Add or point to the tests that protect each step.
4. Call out any temporary compatibility code and when to remove it.
