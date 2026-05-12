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

Use for executing focused implementation tasks from an established plan. **Not for** broad architectural design, planning, or large-scale refactoring.

## Core Process

1. **Read**: Review the pre-defined task, spec, and relevant code. Stop and clarify if the scope is vague or exceeds a single task.
2. **Implement**: Apply the smallest useful code change that satisfies the task requirements.
3. **Verify**:
    - **TDD**: Write/update tests for new behavior or bug fixes.
    - **Reproduction**: For bugs, confirm the failure with a test before fixing.
    - **Full Suite**: Run the strongest available project checks (e.g. `bundle exec rspec`) to prevent regressions.
    - **Manual Check**: Perform task-specific verification (e.g., `curl` an endpoint or check logs).
4. **Final Gate**: Confirm behavior matches the task, no unrelated scope was added, and all tests pass.

### Example: TDD Loop (Code-Level)

Task: "Implement `User#admin?` based on the `role` attribute."

1. **Write failing spec**:
   ```ruby
   # spec/models/user_spec.rb
   it "returns true if the user is an admin" do
     user = User.new(role: "admin")
     expect(user.admin?).to be true
   end
   ```
2. **Run spec → Confirm failure**: `bundle exec rspec spec/models/user_spec.rb` (Fails with `NoMethodError: undefined method 'admin?'`)
3. **Implement (minimal)**:
   ```ruby
   # app/models/user.rb
   def admin?
     role == "admin"
   end
   ```
4. **Run spec → Confirm pass**: `bundle exec rspec spec/models/user_spec.rb` (Passes)

### Example: Bug fix with verification

Task: "Fix 500 error on Search when query is nil"

☐ **Reproduce**: Add a test case to `spec/requests/search_spec.rb` passing `q: nil`.
☐ **Verify Failure**: Run the spec and see it crash in `SearchService`.
☐ **Fix**: Add a null-object or guard in `SearchService`: `query.to_s.strip`.
☐ **Verify Pass**: Re-run the spec.
☐ **Regression check**: Run all search-related specs.

## Rules

- **Explicit Failure**: Handle failure paths explicitly instead of leaving them implicit.
- **Honest Verification**: If a critical check could not be run, state it clearly.

## Output Style

When reporting a completed build task, your output MUST include:

1. **Task completed** — Name the task or behavior implemented.
2. **Tests-first evidence** — State which test was written or updated and that it failed before implementation.
3. **Implementation summary** — List only the files or behavior changed for this task.
4. **Verification** — Report exact commands run and whether they passed.
5. **Residual risk** — Call out skipped checks, blocked verification, or assumptions.

## Integration

| Skill | When to chain |
|-------|---------------|
| **plan-tests** | When the task lacks a clear first failing spec |
| **write-tests** | When test structure or examples are needed |
| **code-review** | After implementation and verification pass |
