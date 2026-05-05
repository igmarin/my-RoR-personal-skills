---
name: build
description: "Implements a single, focused code change by writing or modifying source code, adding unit and integration tests, and running the project's test suite to verify correctness. Use when the user asks to implement a feature, fix a bug, make a code change, add tests to existing code, or deliver any scoped behavioral change. Handles one task at a time rather than large refactors or multi-file architectural overhauls."
user-invocable: true
argument-hint: "<task reference or description> e.g. 'Task 2 from user-auth' or 'add rate limiting to the API'"
---

# Build

## When to use

- Implementing a single task from a plan
- Executing a clear, scoped behavioral change
- Delivering one focused vertical slice

## Process

1. Read the task, spec, and relevant code before editing.
2. If the scope is vague, oversized, or mixes multiple tasks, stop and clarify or break it down.
3. Work in the repo's normal git context.
4. Implement the smallest useful slice that satisfies the task — one task at a time.
5. If the task has several parts, work in small runnable steps and verify each step before continuing.
6. Add tests when behavior changes, bugs are fixed, or interfaces change.
7. Run the strongest project checks available: the full test suite when practical, plus any task-specific verification.

### Example: small runnable step

Task: "add rate limiting to the login endpoint"

☐ Add the middleware
☐ Write a test asserting a 429 response after N requests
☐ Run `pytest tests/test_login.py` (or project equivalent) — confirm passes
☐ Wire up the config option, verify again before moving on

### Example: bug fix with verification

Task: "fix the divide-by-zero crash when the user list is empty"

☐ Reproduce with a failing test: `pytest tests/test_users.py::test_empty_list`
☐ Apply the guard clause in the affected function
☐ Re-run the targeted test — confirm passes
☐ Run full suite: `pytest` — confirm no regression
☐ Call out explicitly if unable to reproduce the original crash before fixing

## Verification

- The behavior matches the task or request
- New or changed behavior is covered by tests where it matters
- Tests pass
- Task-specific verification passes (e.g. `curl` the affected endpoint, run a targeted test file, or check a specific log output)
- No unrelated scope was added

## Rules

- Make the smallest safe change that fully solves the task.
- Preserve contracts unless the task explicitly changes them. If a contract must change, call it out clearly.
- Handle failure paths explicitly instead of leaving them implicit.
- Do not bundle several independent changes into one generation when they can land as working steps.
- Do not hide missing verification. If you could not run something important, say so.
- Do not use this skill as an excuse for unrelated refactors.
