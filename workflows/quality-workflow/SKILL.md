---
name: quality-workflow
license: MIT
description: >
  Complete code quality workflow for Rails projects. Enforces naming conventions, reduces duplication,
  extracts methods and service objects, reduces complexity, and generates YARD docstrings and inline
  comments across the full codebase. Use this composite end-to-end workflow instead of individual
  refactoring or documentation skills when the full three-phase production-readiness review is needed
  together in one pass. Use when: code review prep, before PR, full Rails quality sweep, quality audit,
  production-ready review, end-to-end quality check.
keywords: rails, quality, conventions, refactoring, documentation, yard, review
metadata:
  version: 1.0.0
  user-invocable: "true"
---
# Quality Workflow

Orchestrates systematic code quality checks, safe refactoring, and documentation updates across three phases. Use this instead of individual refactoring or documentation skills when full production-readiness is required end-to-end.

## Workflow Phases

### Phase 1: Conventions Review

Check code against Rails standards via **skills/code-quality/apply-code-conventions** (DRY/YAGNI/PORO/CoC/KISS compliance, linter as style source of truth, structured logging) and **skills/code-quality/apply-stack-conventions** (Rails + PostgreSQL patterns, Hotwire + Tailwind conventions, security best practices).

**Example — DRY violation extracted to shared PORO:**
```ruby
# Before: discount logic duplicated across OrderService and CartService
def apply_discount(price, pct) = price - (price * pct / 100.0)

# After
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

Follow **skills/code-quality/refactor-code** (write characterization tests first, extract methods/classes, verify no behavioral changes before continuing).

**HARD GATE — Tests Pass:**
```bash
bundle exec rspec   # All tests must pass before proceeding
```

---

### Phase 3: Documentation

Document public APIs via **skills/patterns/write-yard-docs** (annotate all public methods with params, return values, and examples; update README/diagrams for architecture or API changes).

**Output:** Updated YARD comments, refreshed README sections

---

## When to Use This vs. Individual Skills

- **Full pre-PR sweep (all three phases):** Use this skill.
- **Only fix linting / conventions:** Use `apply-code-conventions`.
- **Only refactor a specific file:** Use `refactor-code`.
- **Only add YARD docs:** Use `write-yard-docs`.
- **Not sure which skill applies:** Use `skill-router`.

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

```markdown
# Quality Report — [Date]

## Conventions Check
- [x] DRY: No duplication found
- [x] PORO: Service objects properly structured
- [ ] YAGNI: Remove unused method `calculate_total`?

## Refactoring
- Characterization tests added, methods extracted, all tests passing

## Documentation
- YARD coverage: 87% (improved from 65%)
- README updated: YES
```
