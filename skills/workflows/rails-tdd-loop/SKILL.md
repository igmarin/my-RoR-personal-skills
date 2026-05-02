---
name: rails-tdd-loop
license: MIT
description: >
  Complete TDD feature development workflow. Orchestrates context → test → implement
  → document → review cycle. Use for any code-producing task where tests must gate
  implementation. Trigger: start feature, implement with TDD, write code, new feature.
keywords: rails, tdd, workflow, feature, implementation, testing, orchestration
---

# Rails TDD Loop — Complete Feature Workflow

Orchestrates the full test-driven development cycle for Rails features with hard gates at each phase.

## When to Use

- Starting a new feature or task
- Implementing any code-producing change
- Any situation where "tests gate implementation" applies

## Workflow Phases

### Phase 1: Context & Test Design

**Load context first:**
1. **skills/context/rails-context-engineering** — Load schema, routes, nearest patterns
2. **skills/testing/rails-tdd-slices** — Choose the correct first failing spec
3. **skills/testing/rspec-best-practices** — Write the test and verify it FAILS

**HARD GATE — Test Feedback Checkpoint:**
- Test EXISTS (written and saved)
- Test has been RUN
- Test FAILS for the correct reason (feature missing, not typo/config)

**If test feedback is NOT OK:** Return to rspec-best-practices and refine.

---

### Phase 2: Implementation

**Proceed only after test feedback checkpoint passes.**

1. **Implementation Proposal Checkpoint** — Propose approach in plain language:
   - Which classes/methods will change?
   - What's the structure?
   - Any risks or gotchas?

2. **User confirms approach** — Wait for explicit approval

3. **Implement minimal code** to pass the test

4. **Verify test passes** — Run test again

**If test does NOT pass:** Return to implementation (minimal changes, re-verify).

---

### Phase 3: Iterate (Optional)

**Check:** More behaviors to implement?

- **Yes:** Return to Phase 1 (rspec-best-practices) for next behavior
- **No:** Proceed to Phase 4

---

### Phase 4: Finish

1. **Linters + Full Test Suite** — Run rubocop, brakeman, full suite
2. **skills/patterns/yard-documentation** — Document public Ruby API
3. **rails-code-review** — Self-review the PR
4. **Open PR** — Feature complete

---

## Decision Tables

### Best First Spec (from rails-tdd-slices)

| Change Type | Start With |
|-------------|------------|
| Pure domain logic | Model or PORO service spec |
| HTTP endpoint | Request spec |
| Background job | Job spec |
| Cross-layer journey | System spec (sparingly) |
| Bug fix | skills/testing/rails-bug-triage first |
| Engine feature | Engine spec with dummy app |

---

## Integration

| After | Load |
|-------|------|
| This workflow completes | Nothing — PR is ready |
| Bug discovered mid-implementation | skills/testing/rails-bug-triage |
| Security concern in review | skills/code-quality/rails-security-review |
| Architecture issue in review | skills/code-quality/rails-architecture-review |

---

## Output Language

All generated artifacts (YARD docs, READMEs, examples) must be in **English** unless user explicitly requests another language.
