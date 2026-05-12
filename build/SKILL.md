---
name: build
license: MIT
description: >
  Writes implementation code, runs test suites, and validates changes against
  acceptance criteria for a pre-planned task. Use this skill when the 'Research'
  and 'Strategy' phases are complete and you are ready to apply a single,
  well-defined code change. Trigger words: implement task from plan, execute
  planned change, fix bug in task, add test for task, build feature slice.
metadata:
  version: 1.0.0
  user-invocable: "true"
  argument-hint: "<task reference or description> e.g. 'Task 2 from user-auth' or 'add rate limiting to the API'"
---

# Build

## Quick Reference

```text
Use only after a task is already planned.
Write/adjust the failing test first -> run it -> verify the right failure -> implement -> rerun -> report verification.
Keep the change scoped to the named task; call out any blocked or skipped checks.
```

## HARD-GATE: Tests Gate Implementation

```text
Implementation code CANNOT be written until:
  1. The relevant test exists or has been updated
  2. The test has been run
  3. The test fails for the expected task-related reason
```

## When to use

Use for a single planned implementation task; use planning/review skills for broad design, task creation, or large refactors.

## Core Process

1. **Read**: Review the pre-defined task, spec, and relevant code. Stop and clarify if the scope is vague or exceeds a single task.
2. **Implement**: Apply the smallest useful code change that satisfies the task requirements.
3. **Verify**:
    - **TDD**: Write/update tests for new behavior or bug fixes.
    - **Reproduction**: For bugs, confirm the failure with a test before fixing.
    - **Full Suite**: Run the strongest available project checks (e.g. `bundle exec rspec`) to prevent regressions.
    - **Manual Check**: Perform task-specific verification (e.g., `curl` an endpoint or check logs).
4. **Final Gate**: Confirm behavior matches the task, no unrelated scope was added, and all tests pass.

See [EXAMPLES.md](./EXAMPLES.md) for compact TDD and bug-fix examples.

## Rules

- **Honest Verification**: If a critical check could not be run, state it clearly.

## Output Style

Report: task completed, tests-first evidence, implementation summary, verification commands/results, and residual risk.

## Integration

| Skill | When to chain |
|-------|---------------|
| **plan-tests** | When the task lacks a clear first failing spec |
| **write-tests** | When test structure or examples are needed |
| **code-review** | After implementation and verification pass |
