---
name: rails-tdd-loop
license: MIT
description: >
  Orchestrates the full Rails test-driven development cycle: generates a failing spec first, implements minimal code to pass, refactors, then produces YARD documentation and a self-reviewed PR. Use when practicing test-driven development, red-green-refactor, TDD workflow, writing tests before code, adding tests first, or building a Rails feature where specs must gate implementation.
metadata:
  version: 1.0.0
  keywords: rails, tdd, workflow, feature, implementation, testing, orchestration
---

# Rails TDD Loop — Complete Feature Workflow

## Workflow Phases

### Phase 1: Context & Test Design

1. **skills/context/rails-context-engineering** — Load schema, routes, nearest patterns (ensures context matches codebase)
2. **skills/testing/rails-tdd-slices** — Choose the correct first failing spec (model→model spec, API→request, UI+DB→system)
3. **skills/testing/rspec-best-practices** — Write the test and verify it FAILS (use `let`/`build`, confirm failure is for missing feature)

**HARD GATE — Test Feedback Checkpoint:**
- Test EXISTS (written and saved)
- Test has been RUN
- Test FAILS for the correct reason (feature missing, not typo/config)

| Failure type | Example | Action |
|-------------|---------|--------|
| Correct | `undefined method 'full_name'` | Proceed to implementation |
| Incorrect | `syntax error`, `factory not registered` | Return to rspec-best-practices |

**If test feedback is NOT OK:** Return to rspec-best-practices and refine.

---

### Phase 2: Implementation

1. **Implementation Proposal Checkpoint** — Propose approach (example: "User#full_name: concatenate first_name + last_name with space")

2. **User confirms approach** — Wait for explicit approval

3. **Implement minimal code** to pass the test (single method, no premature abstractions, simplest thing that works)

4. **Verify test passes** — Run the spec again:
   ```bash
   bundle exec rspec spec/path/to/your_spec.rb
   ```

**If test does NOT pass:** Return to implementation (minimal changes, re-verify).

---

### Phase 3: Iterate (Optional)

**Check:** More behaviors to implement?

- **Yes:** Return to Phase 1 (rspec-best-practices) for next behavior
- **No:** Proceed to Phase 4

---

### Phase 4: Finish

1. **Linters + Full Test Suite:**
   ```bash
   bundle exec rubocop
   bundle exec brakeman --no-pager
   bundle exec rspec
   ```
2. **skills/patterns/yard-documentation** — Document public Ruby API (code documentation)
3. **skills/code-quality/rails-code-review** — Self-review the PR (quality assurance)
4. **Open PR** — Feature complete

---

## Integration

Workflow complete → PR ready. Bug mid-implementation → skills/testing/rails-bug-triage. Security/architecture concerns → skills/code-quality/rails-security-review / skills/code-quality/rails-architecture-review.

---

## Example

Inline example with file structure:

`spec/models/user_spec.rb`:
```ruby
RSpec.describe User do
  describe '#full_name' do
    let(:user) { build(:user, first_name: 'John', last_name: 'Doe') }
    it 'concatenates first and last name' do
      expect(user.full_name).to eq('John Doe')
    end
  end
end
```

`app/models/user.rb`:
```ruby
def full_name
  "#{first_name} #{last_name}"
end
```

See [assets/example.md](assets/example.md) for complete end-to-end walkthrough with commands and phases.
