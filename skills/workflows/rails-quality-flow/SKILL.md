---
name: rails-quality-flow
license: MIT
description: >
  Complete code quality workflow for Rails projects. Enforces naming conventions, reduces duplication,
  extracts methods and service objects, reduces complexity, and generates YARD docstrings and inline
  comments across the full codebase. Use this composite workflow instead of individual refactoring or
  documentation skills when a full production-readiness review is needed end-to-end. Use when: code review prep,
  before PR, refactor safely, add documentation, quality check, quality audit, full Rails quality sweep,
  production-ready review.
keywords: rails, quality, conventions, refactoring, documentation, yard, review
---

# Rails Quality Flow — Complete Quality Assurance Workflow

Orchestrates systematic code quality checks, safe refactoring, and documentation updates across three phases. Use this instead of individual refactoring or documentation skills when full production-readiness is required end-to-end.

## Workflow Phases

### Phase 1: Conventions Review

Check code against Rails standards via **skills/code-quality/rails-code-conventions** (DRY/YAGNI/PORO/CoC/KISS compliance, linter as style source of truth, structured logging) and **skills/code-quality/rails-stack-conventions** (Rails + PostgreSQL patterns, Hotwire + Tailwind conventions, security best practices).

**Example violation and fix:**
```ruby
# Violation (DRY): duplicated discount logic across OrderService and CartService
def apply_discount(price, pct)  # repeated verbatim in two classes
  price - (price * pct / 100.0)
end

# Fix: extract to shared PORO
class DiscountCalculator
  def self.apply(price, pct) = price - (price * pct / 100.0)
end
```

**Output:** Convention violations list with severity (must-fix / should-fix / nice-to-have)

---

### Phase 2: Refactoring (Optional)

**Decision Gate — Need Refactoring?**
- High complexity / low readability? → Proceed
- Logic duplication found? → Proceed
- Otherwise → Skip to Phase 3

Follow **skills/code-quality/refactor-safely** (write characterization tests first, extract methods/classes, verify no behavioral changes before continuing).

**HARD GATE — Tests Pass:**
```bash
bundle exec rspec   # All tests must pass before proceeding
```

---

### Phase 3: Documentation

Document public APIs via **skills/patterns/yard-documentation** (annotate all public methods with params, return values, and examples; update README/diagrams for architecture or API changes).

**Output:** Updated YARD comments, refreshed README sections

---

## Quick Reference

```
Before PR?        → rails-code-conventions → yard-documentation
Need to refactor? → refactor-safely → rails-code-conventions
Quality audit?    → rails-code-conventions → rails-stack-conventions
Not sure?         → rails-skills-orchestrator
```

## HARD-GATE: Quality Before Merge

**NEVER open PR before:**
```bash
bundle exec rubocop        # Linter must pass
bundle exec erblint --lint-all  # ERB linter must pass
bundle exec rspec          # All tests must pass
bundle exec brakeman       # Security scan must pass
```
Plus: YARD docs complete for all public APIs.

## Output Style

**Quality Report:**
```markdown
# Quality Report — [Date]

## Conventions Check
- [x] DRY: No duplication found
- [x] PORO: Service objects properly structured
- [ ] YAGNI: Remove unused method `calculate_total`?

## Refactoring
- Characterization tests: 5 added
- Methods extracted: 3
- All tests passing: YES

## Documentation
- YARD coverage: 87% (improved from 65%)
- README updated: YES
```
